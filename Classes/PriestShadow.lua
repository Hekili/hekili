-- PriestShadow.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local FindUnitBuffByID = ns.FindUnitBuffByID


local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'PRIEST' then
    local spec = Hekili:NewSpecialization( 258, true )

    spec:RegisterResource( Enum.PowerType.Insanity, {
        mind_flay = {
            aura = 'mind_flay',
            debuff = true,

            last = function ()
                local app = state.debuff.mind_flay.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.mind_flay.tick_time ) * class.auras.mind_flay.tick_time
            end,

            interval = function () return class.auras.mind_flay.tick_time end,
            value = function () return ( state.talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * 3 end,
        },

        mind_sear = {
            aura = 'mind_sear',
            debuff = true,

            last = function ()
                local app = state.debuff.mind_sear.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.mind_sear.tick_time ) * class.auras.mind_sear.tick_time
            end,

            interval = function () return class.auras.mind_sear.tick_time end,
            value = function () return ( state.talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * 1.25 * state.active_enemies end,
        },

        -- need to revise the value of this, void decay ticks up and is impacted by void torrent.
        voidform = {
            aura = "voidform",

            last = function ()
                local app = state.buff.voidform.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x )
                return x == 0
            end,

            interval = 1,
            value = function ()
                return ( state.debuff.void_torrent.up or state.debuff.dispersion.up ) and 0 or ( -6 - ( 0.8 * state.debuff.voidform.stacks ) )
            end,
        },

        void_torrent = {
            aura = "void_torrent",

            last = function ()
                local app = state.buff.void_torrent.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x )
                return x == 0
            end,

            interval = 1,
            value = 7.5,
        },

        vamp_touch_t19 = {
            aura = "vampiric_touch",
            set_bonus = "tier19_2pc",
            debuff = true,

            last = function ()
                local app = state.debuff.vampiric_touch.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.vampiric_touch.tick_time ) * class.auras.vampiric_touch.tick_time
            end,

            interval = function () return state.debuff.vampiric_touch.tick_time end,
            value = 1
        },

        mindbender = {
            aura = "mindbender",

            last = function ()
                local app = state.buff.mindbender.expires - 15
                local t = state.query_time

                return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
            end,

            interval = function () return 1.5 * state.haste end,
            value = function () return state.debuff.surrendered_to_madness.up and 0 or ( state.buff.surrender_to_madness.up and 12 or 6 ) end,
        },

        shadowfiend = {
            aura = "shadowfiend",

            last = function ()
                local app = state.buff.shadowfiend.expires - 15
                local t = state.query_time

                return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
            end,

            interval = function () return 1.5 * state.haste end,
            value = function () return state.debuff.surrendered_to_madness.up and 0 or ( state.buff.surrender_to_madness.up and 6 or 3 ) end,
        },
    } )
    spec:RegisterResource( Enum.PowerType.Mana )


    -- Talents
    spec:RegisterTalents( {
        fortress_of_the_mind = 22328, -- 193195
        shadowy_insight = 22136, -- 162452
        shadow_word_void = 22314, -- 205351

        body_and_soul = 22315, -- 64129
        sanlayn = 23374, -- 199855
        intangibility = 21976, -- 288733

        twist_of_fate = 23125, -- 109142
        misery = 23126, -- 238558
        dark_void = 23127, -- 263346

        last_word = 23137, -- 263716
        mind_bomb = 23375, -- 205369
        psychic_horror = 21752, -- 64044

        auspicious_spirits = 22310, -- 155271
        shadow_word_death = 22311, -- 32379
        shadow_crash = 21755, -- 205385

        lingering_insanity = 21718, -- 199849
        mindbender = 21719, -- 200174
        void_torrent = 21720, -- 263165

        legacy_of_the_void = 21637, -- 193225
        dark_ascension = 21978, -- 280711
        surrender_to_madness = 21979, -- 193223
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3476, -- 208683
        adaptation = 3477, -- 214027
        relentless = 3478, -- 196029

        void_shift = 128, -- 108968
        hallucinations = 3736, -- 280752
        psychic_link = 119, -- 199484
        void_origins = 739, -- 228630
        mind_trauma = 113, -- 199445
        edge_of_insanity = 110, -- 199408
        driven_to_madness = 106, -- 199259
        pure_shadow = 103, -- 199131
        void_shield = 102, -- 280749
        psyfiend = 763, -- 211522
        shadow_mania = 764, -- 280750
    } )


    spec:RegisterTotem( "mindbender", 136214 )
    spec:RegisterTotem( "shadowfiend", 136199 )


    local hadShadowform = false

    spec:RegisterHook( "reset_precast", function ()
        if time > 0 then
            applyBuff( "shadowform" )
        end

        if pet.mindbender.active then
            applyBuff( "mindbender", pet.mindbender.remains )
            buff.mindbender.applied = action.mindbender.lastCast
            buff.mindbender.duration = 15
            buff.mindbender.expires = action.mindbender.lastCast + 15
        elseif pet.shadowfiend.active then
            applyBuff( "shadowfiend", pet.shadowfiend.remains )
            buff.shadowfiend.applied = action.shadowfiend.lastCast
            buff.shadowfiend.duration = 15
            buff.shadowfiend.expires = action.shadowfiend.lastCast + 15
        end

        if action.void_bolt.in_flight then
            runHandler( "void_bolt" )
        end
    end )


    spec:RegisterHook( 'pregain', function( amount, resource, overcap )
        if amount > 0 and resource == "insanity" and state.buff.memory_of_lucid_dreams.up then
            amount = amount * 2
        end

        return amount, resource, overcap
    end )


    spec:RegisterHook( 'runHandler', function( ability )
        -- Make sure only the correct debuff is applied for channels to help resource forecasting.
        if ability == "mind_sear" then
            removeDebuff( "target", "mind_flay" )
        elseif ability == "mind_flay" then
            removeDebuff( "target", "mind_sear" )
        else
            removeDebuff( "target", "mind_flay" )
            removeDebuff( "target", "mind_sear" )
        end
    end )


    -- Auras
    spec:RegisterAuras( {
        body_and_soul = {
            id = 65081,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        dispersion = {
            id = 47585,
            duration = 6,
            max_stack = 1,
        },
        fade = {
            id = 586,
            duration = 10,
            max_stack = 1,
        },
        focused_will = {
            id = 45242,
            duration = 8,
            max_stack = 2,
        },
        levitate = {
            id = 111759,
            duration = 600,
            type = "Magic",
            max_stack = 1,
        },
        lingering_insanity = {
            id = 197937,
            duration = 60,
            max_stack = 8,
        },
        mind_bomb = {
            id = 226943,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        mind_flay = {
            id = 15407,
            duration = function () return 3 * haste end,
            max_stack = 1,
            tick_time = function () return 0.75 * haste end,
        },
        mind_sear = {
            id = 48045,
            duration = function () return 3 * haste end,
            max_stack = 1,
            tick_time = function () return 0.75 * haste end,
        },
        mind_vision = {
            id = 2096,
            duration = 60,
            max_stack = 1,
        },
        mindbender = {
            duration = 15,
            max_stack = 1,
        },
        power_word_fortitude = {
            id = 21562,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
            shared = "player", -- use anyone's buff on the player, not just player's.
        },
        power_word_shield = {
            id = 17,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        psychic_horror = {
            id = 64044,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        psychic_scream = {
            id = 8122,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        shackle_undead = {
            id = 9484,
            duration = 50,
            type = "Magic",
            max_stack = 1,
        },
        shadow_word_pain = {
            id = 589,
            duration = 16,
            type = "Magic",
            max_stack = 1,
            tick_time = function () return 2 * haste end,
        },
        shadowfiend = {
            duration = 15,
            max_stack = 1
        },
        shadowform = {
            id = 232698,
            duration = 3600,
            max_stack = 1,
        },
        shadowy_apparitions = {
            id = 78203,
        },
        shadowy_insight = {
            id = 124430,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        silence = {
            id = 15487,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        surrender_to_madness = {
            id = 193223,
            duration = 60,
            max_stack = 1,
        },
        surrendered_to_madness = {
            id = 263406,
            duration = 15,
            max_stack = 1,
        },
        vampiric_embrace = {
            id = 15286,
            duration = 15,
            max_stack = 1,
        },
        vampiric_touch = {
            id = 34914,
            duration = 21,
            type = "Magic",
            max_stack = 1,
            tick_time = function () return 3 * haste end,
        },
        void_bolt = {
            id = 228266,
        },
        void_torrent = {
            id = 263165,
            duration = 4,
            max_stack = 1,
            tick_time = 1,
        },
        voidform = {
            id = 194249,
            duration = 3600,
            max_stack = 99,
            generate = function( t )
                local name, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = FindUnitBuffByID( "player", 194249 )

                if name then
                    t.name = name
                    t.count = max( 1, count )
                    t.applied = max( action.void_eruption.lastCast, action.dark_ascension.lastCast, now )
                    t.expires = t.applied + 3600
                    t.duration = 3600
                    t.caster = "player"
                    t.timeMod = 1
                    t.v1 = v1
                    t.v2 = v2
                    t.v3 = v3
                    t.unit = "player"
                    return
                end

                t.name = nil
                t.count = 0
                t.expires = 0
                t.applied = 0
                t.duration = 3600
                t.caster = 'nobody'
                t.timeMod = 1
                t.v1 = 0
                t.v2 = 0
                t.v3 = 0
                t.unit = 'player'
            end,
            meta = {
                up = function ()
                    return buff.voidform.applied > 0 and buff.voidform.drop_time > query_time
                end,

                drop_time = function ()
                    if buff.voidform.applied == 0 then return 0 end

                    local app = buff.voidform.applied
                    app = app + floor( query_time - app )

                    local drain = 6 + ( 0.8 * buff.voidform.stacks )
                    local amt = insanity.current

                    while ( amt > 0 ) do
                        amt = amt - drain
                        drain = drain + 0.8
                        app = app + 1
                    end

                    return app
                end,

                stacks = function ()
                    return buff.voidform.applied > 0 and ( buff.voidform.count + floor( offset + delay ) ) or 0
                end,

                remains = function ()                    
                    return max( 0, buff.voidform.drop_time - query_time )
                end,
            },
        },
        weakened_soul = {
            id = 6788,
            duration = function () return 7.5 * haste end,
            max_stack = 1,
        },


        -- Azerite Powers
        chorus_of_insanity = {
            id = 279572,
            duration = 120,
            max_stack = 120,
        },

        death_denied = {
            id = 287723,
            duration = 10,
            max_stack = 1,
        },

        depth_of_the_shadows = {
            id = 275544,
            duration = 12,
            max_stack = 30
        },

        --[[ harvested_thoughts = {
            id = 273321,
            duration = 15,
            max_stack = 1,
        }, ]]

        searing_dialogue = {
            id = 288371,
            duration = 1,
            max_stack = 1
        },

        thought_harvester = {
            id = 288343,
            duration = 20,
            max_stack = 1,
            copy = "harvested_thoughts" -- SimC uses this name (carryover from Legion?)
        },

    } )


    spec:RegisterHook( "advance_end", function ()
        if buff.voidform.up and insanity.current == 0 then
            insanity.regen = 0
            removeBuff( "voidform" )
            if buff.surrender_to_madness.up then
                removeBuff( "surrender_to_madness" )
                applyDebuff( "player", "surrendered_to_madness" )
            end
            applyBuff( "shadowform" )
        end
    end )


    spec:RegisterGear( "tier21", 152154, 152155, 152156, 152157, 152158, 152159 )
    spec:RegisterGear( "tier20", 147163, 147164, 147165, 147166, 147167, 147168 )
        spec:RegisterAura( "empty_mind", {
            id = 247226,
            duration = 12,
            max_stack = 10,
        } )
    spec:RegisterGear( "tier19", 138310, 138313, 138316, 138319, 138322, 138370 )


    spec:RegisterGear( "anunds_seared_shackles", 132409 )
        spec:RegisterAura( "anunds_last_breath", {
            id = 215210,
            duration = 15,
            max_stack = 50,
        } )
    spec:RegisterGear( "heart_of_the_void", 151814 )
    spec:RegisterGear( "mangazas_madness", 132864 )
    spec:RegisterGear( "mother_shahrazs_seduction", 132437 )
    spec:RegisterGear( "soul_of_the_high_priest", 151646 )
    spec:RegisterGear( "the_twins_painful_touch", 133973 )
    spec:RegisterGear( "zenkaram_iridis_anadem", 133971 )
    spec:RegisterGear( "zeks_exterminatus", 144438 )
        spec:RegisterAura( "zeks_exterminatus", {
            id = 236546,
            duration = 15,
            max_stack = 1,
        } )


    spec:RegisterStateExpr( "current_insanity_drain", function ()
        return buff.voidform.up and ( 6 + ( 0.8 * buff.voidform.stacks ) ) or 0
    end )


    -- Abilities
    spec:RegisterAbilities( {
        dark_ascension = {
            id = 280711,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = -50,
            spendType = "insanity",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1711336,

            talent = "dark_ascension",

            handler = function ()
                applyBuff( "voidform", nil, ( level < 116 and equipped.mother_shahrazs_seduction ) and 3 or 1 )
            end,
        },


        dark_void = {
            id = 263346,
            cast = 2,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 132851,

            talent = "dark_void",

            handler = function ()
                applyDebuff( "target", "shadow_word_pain" )
                active_dot.shadow_word_pain = max( active_dot.shadow_word_pain, active_enemies )
            end,
        },


        dispel_magic = {
            id = 528,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.016,
            spendType = "mana",

            startsCombat = true,
            texture = 136066,

            usable = function () return buff.dispellable_magic.up end,
            handler = function ()
                removeBuff( "dispellable_magic" )
                gain( 6, "insanity" )
            end,
        },


        dispersion = {
            id = 47585,
            cast = 0,
            cooldown = function () return talent.intangibility.enabled and 90 or 120 end,
            gcd = "spell",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 237563,

            handler = function ()
                applyBuff( "dispersion" )
                setCooldown( "global_cooldown", 6 )
            end,
        },


        fade = {
            id = 586,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 135994,

            handler = function ()
                applyBuff( "fade" )
            end,
        },


        leap_of_faith = {
            id = 73325,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = false,
            texture = 463835,

            handler = function ()
                if azerite.death_denied.enabled then applyBuff( "death_denied" ) end
            end,
        },


        levitate = {
            id = 1706,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135928,

            handler = function ()
                applyBuff( "levitate" )
            end,
        },


        mass_dispel = {
            id = 32375,
            cast = 1.5,
            cooldown = 45,
            gcd = "spell",

            spend = 0.08,
            spendType = "mana",

            startsCombat = true,
            texture = 135739,

            usable = function () return buff.dispellable_magic.up or debuff.dispellable_magic.up end,
            handler = function ()
                removeBuff( "dispellable_magic" )
                removeDebuff( "player", "dispellable_magic" )
                gain( 6, "insanity" )
            end,
        },


        -- SimulationCraft module for Shadow Word: Void automatically substitutes SW:V for MB when talented.
        mind_blast = {
            id = function () return talent.shadow_word_void.enabled and 205351 or 8092 end,
            cast = function () return haste * ( buff.shadowy_insight.up and 0 or 1.5 ) end,
            charges = function ()
                local n = 1
                if talent.shadow_word_void.enabled then n = n + 1 end
                if level < 116 and equipped.mangazas_madness then n = n + 1 end
                return n > 1 and n or nil
            end,
            cooldown = function () return ( talent.shadow_word_void.enabled and 9 or 7.5 ) * haste end,
            recharge = function () return ( talent.shadow_word_void.enabled and 9 or 7.5 ) * haste end,
            gcd = "spell",

            velocity = 15,

            spend = function () return ( talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * ( ( talent.shadow_word_void.enabled and -15 or -12 ) - buff.empty_mind.stack ) * ( buff.surrender_to_madness.up and 2 or 1 ) * ( debuff.surrendered_to_madness.up and 0 or 1 ) end,
            spendType = "insanity",

            startsCombat = true,
            texture = function () return talent.shadow_word_void.enabled and 610679 or 136224 end,

            -- notalent = "shadow_word_void",

            handler = function ()
                removeBuff( "harvested_thoughts" )
                removeBuff( "shadowy_insight" )
                removeBuff( "empty_mind" )
            end,

            copy = { "shadow_word_void", 205351, 8092 },
        },


        mind_bomb = {
            id = 205369,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 136173,

            talent = "mind_bomb",

            handler = function ()
                applyDebuff( "target", "mind_bomb" )
            end,
        },


        --[[ mind_control = {
            id = 605,
            cast = 1.8,
            cooldown = 0,
            gcd = "spell",

            spend = 100,
            spendType = "mana",

            startsCombat = true,
            texture = 136206,

            handler = function ()
            end,
        }, ]]


        mind_flay = {
            id = 15407,
            cast = 3,
            cooldown = 0,
            gcd = "spell",

            spend = 0,
            spendType = "insanity",

            channeled = true,
            breakable = true,
            breakchannel = function ()
                removeDebuff( "target", "mind_flay" )
            end,
            prechannel = true,

            startsCombat = true,
            texture = 136208,

            aura = 'mind_flay',

            start = function ()
                applyDebuff( "target", "mind_flay" )
                channelSpell( "mind_flay" )

                if level < 116 then
                    if equipped.the_twins_painful_touch and action.mind_flay.lastCast < max( action.dark_ascension.lastCast, action.void_eruption.lastCast ) then
                        if debuff.shadow_word_pain.up and active_dot.shadow_word_pain < min( 4, active_enemies ) then
                            active_dot.shadow_word_pain = min( 4, active_enemies )
                        end
                        if debuff.vampiric_touch.up and active_dot.vampiric_touch < min( 4, active_enemies ) then
                            active_dot.vampiric_touch = min( 4, active_enemies )
                        end
                    end

                    if set_bonus.tier20_2pc == 1 then
                        addStack( "empty_mind", nil, 3 )
                    end
                end

                forecastResources( "insanity" )
            end,
        },


        mind_sear = {
            id = 48045,
            cast = 3,
            cooldown = 0,
            gcd = "spell",

            spend = 0,
            spendType = "insanity",

            channeled = true,
            breakable = true,
            breakchannel = function ()
                removeDebuff( "target", "mind_sear" )
            end,            
            prechannel = true,

            startsCombat = true,
            texture = 237565,

            aura = 'mind_sear',

            start = function ()
                applyDebuff( "target", "mind_sear" )
                channelSpell( "mind_sear" )

                if azerite.searing_dialogue.enabled then applyDebuff( "target", "searing_dialogue" ) end
                
                removeBuff( "thought_harvester" )
                forecastResources( "insanity" )
            end,
        },


        --[[ mind_vision = {
            id = 2096,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135934,

            handler = function ()
                -- applies mind_vision (2096)
            end,
        }, ]]


        -- SimulationCraft module: Mindbender and Shadowfiend are interchangeable.
        mindbender = {
            id = function () return talent.mindbender.enabled and 200174 or 34433 end,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( talent.mindbender.enabled and 60 or 180 ) end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = function () return talent.mindbender.enabled and 136214 or 136199 end,

            -- talent = "mindbender",

            handler = function ()
                summonPet( talent.mindbender.enabled and "mindbender" or "shadowfiend", 15 )
                applyBuff( talent.mindbender.enabled and "mindbender" or "shadowfiend" )
            end,

            copy = { "shadowfiend", 200174, 34433 }
        },

        --[[ shadowfiend = {
            id = 34433,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "cooldowns",
            notalent = "mindbender",

            startsCombat = true,
            texture = 136199,

            handler = function ()
                summonPet( "shadowfiend", 15 )
                applyBuff( "shadowfiend" )
            end,
        }, ]]                

        power_word_fortitude = {
            id = 21562,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = false,
            texture = 135987,

            usable = function () return buff.power_word_fortitude.down end,
            handler = function ()
                applyBuff( "power_word_fortitude" )
            end,
        },


        power_word_shield = {
            id = 17,
            cast = 0,
            cooldown = 6,
            hasteCD = true,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            nodebuff = "weakened_soul",

            startsCombat = false,
            texture = 135940,

            handler = function ()
                applyBuff( "power_word_shield" )
                applyDebuff( "weakened_soul" )
                if talent.body_and_soul.enabled then applyBuff( "body_and_soul" ) end
                gain( 6, "insanity" )
            end,
        },


        psychic_horror = {
            id = 64044,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 237568,

            talent = "psychic_horror",

            handler = function ()
                applyDebuff( "target", "psychic_horror" )
            end,
        },


        psychic_scream = {
            id = 8122,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0.012,
            spendType = "mana",

            startsCombat = true,
            texture = 136184,

            notalent = "mind_bomb",

            handler = function ()
                applyDebuff( "target", "psychic_scream" )
            end,
        },


         purify_disease = {
            id = 213634,
            cast = 0,
            charges = 1,
            cooldown = 8,
            recharge = 8,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135935,

            usable = function () return debuff.dispellable_disease.up end,
            handler = function ()
                removeBuff( "player", "dispellable_disease" )
            end,
        },


        --[[ resurrection = {
            id = 2006,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135955,

            handler = function ()
            end,
        }, ]]


        shackle_undead = {
            id = 9484,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.012,
            spendType = "mana",

            startsCombat = true,
            texture = 136091,

            handler = function ()
                applyDebuff( "target", "shackle_undead" )
            end,
        },


        shadow_crash = {
            id = 205385,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = -20,
            spendType = "insanity",

            startsCombat = true,
            texture = 136201,

            handler = function ()
            end,
        },


        shadow_mend = {
            id = 186263,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 136202,

            handler = function ()
                removeBuff( "depth_of_the_shadows" )
            end,
        },


        shadow_word_death = {
            id = 32379,
            cast = 0,
            charges = 2,
            cooldown = 9,
            recharge = 9,
            gcd = "spell",

            spend = 15,
            spendType = "insanity",

            startsCombat = true,
            texture = 136149,

            talent = "shadow_word_death",

            usable = function () return buff.zeks_exterminatus.up or target.health.pct < 20 end,
            handler = function ()
                removeBuff( "zeks_exterminatus" )
            end,
        },


        shadow_word_pain = {
            id = 589,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -4,
            spendType = "insanity",

            startsCombat = true,
            texture = 136207,

            cycle = "shadow_word_pain",

            handler = function ()
                applyDebuff( "target", "shadow_word_pain" )
            end,
        },


        --[[ shadow_word_void = {
            id = 205351,
            cast = 1.5,
            charges = 2,
            cooldown = 9,
            recharge = 9,
            hasteCD = true,
            gcd = "spell",

            velocity = 15,

            spend = function () return ( talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * ( -15 - buff.empty_mind.stack ) * ( buff.surrender_to_madness.up and 2 or 1 ) * ( debuff.surrendered_to_madness.up and 0 or 1 ) end,
            spendType = "insanity",

            startsCombat = true,
            texture = 610679,

            talent = "shadow_word_void",

            handler = function ()
                -- applies voidform (194249)
                -- applies mind_flay (15407)
                -- removes shadow_word_pain (589)
            end,
        }, ]]


        --[[ shadowfiend = {
            id = 34433,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "cooldowns",
            notalent = "mindbender",

            startsCombat = true,
            texture = 136199,

            handler = function ()
                summonPet( "shadowfiend", 15 )
                applyBuff( "shadowfiend" )
            end,
        }, ]]


        shadowform = {
            id = 232698,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136200,

            essential = true,
            nobuff = function () return buff.voidform.up and 'voidform' or 'shadowform' end,

            handler = function ()
                applyBuff( "shadowform" )
            end,
        },


        silence = {
            id = 15487,
            cast = 0,
            cooldown = 45,
            gcd = "off",

            startsCombat = true,
            texture = 458230,

            toggle = "interrupts",
            interrupt = true,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
                applyDebuff( "target", "silence" )
            end,
        },


        surrender_to_madness = {
            id = 193223,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 254090,

            handler = function ()
                applyBuff( "surrender_to_madness" )
            end,
        },


        vampiric_embrace = {
            id = 15286,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 136230,

            handler = function ()
                applyBuff( "vampiric_embrace" )
            end,
        },


        vampiric_touch = {
            id = 34914,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = -6,
            spendType = "insanity",

            startsCombat = true,
            texture = 135978,

            cycle = function () return talent.misery.enabled and 'shadow_word_pain' or 'vampiric_touch' end,

            handler = function ()
                applyDebuff( "target", "vampiric_touch" )
                if talent.misery.enabled then
                    applyDebuff( "target", "shadow_word_pain" )
                end
                -- Thought Harvester is a 20% chance to proc, consumed by Mind Sear.
                -- if azerite.thought_harvester.enabled then applyBuff( "harvested_thoughts" ) end
            end,
        },


        void_bolt = {
            id = 205448,
            known = 228260,
            cast = 0,
            cooldown = function ()
                if level < 116 and set_bonus.tier19_4pc > 0 and query_time - buff.voidform.applied < 2.5 then return 0 end
                return haste * 4.5
            end,
            gcd = "spell",

            spend = function ()
                if debuff.surrendered_to_madness.up then return 0 end
                return buff.surrender_to_madness.up and -40 or -20
            end,
            spendType = "insanity",

            startsCombat = true,
            texture = 1035040,

            velocity = 40,
            buff = "voidform",
            bind = "void_eruption",

            handler = function ()
                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 3 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 3 end
                removeBuff( "anunds_last_breath" )
            end,
        },


        void_eruption = {
            id = 228260,
            cast = function ()
                if pvptalent.void_origins.enabled then return 0 end
                return haste * ( talent.legacy_of_the_void.enabled and 0.6 or 1 ) * 2.5 
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                return talent.legacy_of_the_void.enabled and 60 or 90
            end,
            spendType = "insanity",

            startsCombat = true,
            texture = 1386548,

            nobuff = "voidform",
            bind = "void_bolt",

            -- ready = function () return insanity.current >= ( talent.legacy_of_the_void.enabled and 60 or 90 ) end,
            handler = function ()
                applyBuff( "voidform", nil, ( level < 116 and equipped.mother_shahrazs_seduction ) and 3 or 1 )
                gain( talent.legacy_of_the_void.enabled and 60 or 90, "insanity" )
            end,
        },


        void_torrent = {
            id = 263165,
            cast = 4,
            channeled = true,
            fixedCast = true,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 1386551,

            aura = "void_torrent",
            talent = "void_torrent",
            buff = "voidform",

            handler = function ()
                applyDebuff( "target", "void_torrent" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "unbridled_fury",

        package = "Shadow",
    } )


    spec:RegisterPack( "Shadow", 20200124, [[dOeGbbqifH6ruvPlrvfsBIQQgfsYPqsTkksVsrAwGu3srWUe5xGkdtu1XqvTmkkpdvPMMIixdjyBGK8nKqnoqs5CkIY6uesZdvj3de7dvXbbjvTqkIhsvfnrKq6IuvHQnQiQQgjvviCsqsLvkfntfrv5Mkcr7ejAOkcHNQWubvDvKqSvfrLVQiQYEH8xknyOomPftHhtLjJYLj2ms9zqz0IYPLSAQQq51IkZwQUnQSBv9BvgUI64uvHOLd8Cetx46uLTlL(ovLXtvfCEkQwpiX8Lc7xPr8rWJgmneeLML3S855B2Ks5NmkWN3MHgH5ZcAmRUCkmbnELtqJrMYoFOXSAE)ugcE0GCEaNGgzrmtMOWbhSkY8msUJdosX511OU3bu6aosX5Gdnm8QEa19id0GPHGO0S8MLppFZMuk)Krb(Mrb0q9ISdGgJIZprJSIXKhzGgmH4qd)U4rMYoFlEIaucj2M(DXzrmtMOWbhSkY8msUJdosX511OU3bu6aosX5GBB63f3uFpfy(InJp0l2S8MLFBUn97I9Zm9HjKj620VlEclgQNXe2IhvxENK2M(DXtyX(59Tcie2IdfatcBrVyI5FO(H020VlEcl2pVVvaHWwCOaysKIItSXzzLS44wCuCInolRKf7ltaYI155E5uJUKqJErcccE0GupSUGGhrjFe8OH6I6E0O9kMvaEZrDpAiVA0fgYeuGO0me8OH8QrxyitqdhOcbukAy4rtNAVIrFaUe789OH6I6E0GPGCwL4KNu3JceL8gbpAOUOUhnAVIznUEGgYRgDHHmbfikNecE0qE1OlmKjOH6I6E0WP9UvDrDVTxKan6fjSVYjOHJrqbIskGGhnKxn6cdzcA4aviGsrddpA6uMcAfsimBKDEWYcsYBEX(Vy3DD257tTxXSgxpsaHtRNSyEGSy(jkSy)xScfbuHKiIcQhMLvA)G5jjG(5wmpqwmF0qDrDpAWvpZsefGceLqfcE0qE1OlmKjOHduHakfncfatIuuCInolRKfZRfZ7f3OXID31zNVprYu25Z67amlt0il5YuamHSyil2Sf3OXIPAXU76SZ3Nizk78z9DaMLjAKLCzkaMqwmKfZFX(Vy3DD257tKmLD(S(oaZYenYsaHtRNSyETyyowIt9dlMA0qDrDpAqYu25Z67amlt0idfikPye8OH8QrxyitqdhOcbukAy4rtNAVIrFaUejuxUfZZI5NFXtxmvlMF(fB6In8OPtg97yDpsK8Mxm1OH6I6E0G4baYZeGnolNYEHqqbIsOgcE0qE1OlmKjOHduHakfnaAXSsR8rszmsQ(fZZI5Nhnuxu3JgmfKZ2EfdfikNme8OH8QrxyitqdhOcbukAeAx(iXvpZqEMasYRgDHT4gnwmvl2WJMo1EfJ(aCjsOUClMNfZhQT4gnwCuCInolRKfZRfZNclMA0qDrDpAWvpZqEMaqbIs(5rWJgYRgDHHmbnCGkeqPOXeVydpA6u7vm6dWL8MxCJglMQf7URZoFFIKPSZN13bywMOrwYLPayczXqwSzl2)fB4rtNAVIrFaUejuxUfZRfZNclMA0qDrDpAqYu25Z67amlt0idfik5ZhbpAiVA0fgYe0WbQqaLIgaTywPv(iPmgjv)I5zXuyX(VyGwmR0kFKugJKyEanQ7xmVwSz5rd1f19ObjtzNpRdOKmuGOKVzi4rd5vJUWqMGgoqfcOu0OvbLA0Le7cI1BEX(VyQwmvlgOfZkTYhjURv4Kps1VyEwStjHnkozXtxC(efwS)lgOfZkTYhjURv4Kps1VyET4jTyQxCJglEIxCOD5JejtzNpRVdWSTxXsYRgDHT4gnwSHhnDQ9kg9b4sSZ3V4gnwSHhnDQ9kg9b4sKqD5wmplM)KwS)lMQfxpr)kmFX8AXuC(f3OXIDzkaMqS0a1f19AFX8Sy(jEZ7ft9IB0yXgE00P2Ry0hGlrc1LBX8cYI5pPf7)IPAX1t0VcZxmVwmuLFXnASyxMcGjelnqDrDV2xmplMFI38EXuVyQrd1f19Obx9mRrxjbkquYN3i4rd5vJUWqMGgoqfcOu0GDrIKPSZN13by2zT(eq406jlMNfpPf7)IzxKAvU5cuoBCEUSeq406jlMNfpPf7)In8OPtTxXOpaxYBgnuxu3JgTxXSXbaYhOarj)jHGhnKxn6cdzcA4aviGsrdGqdesMA0Lf7)IJItSXzzLSyEw8KwS)lEIxCOD5JexreG5j5vJUWwS)lEIxCOD5Jetb5STxXsYRgDHHgQlQ7rdsMYoFwFhGzN16rbIs(uabpAiVA0fgYe0WbQqaLIgaHgiKm1Oll2)fhfNyJZYkzX8SyOAXnASyQwCOD5JexreG5j5vJUWwS)lMDrIKPSZN13by2zT(eqObcjtn6YIPgnuxu3JgTk3CbkNnopxgkquYhQqWJgYRgDHHmbnuxu3JgC1ZS0D1C0O(qaaV5Ww0OruUCeEGyM)u5URZoFFQ9kM146rYBUrd3DD257tC1ZSgDLejVzQrJ6dba8MdBXXjSsdbn4JgUmTE0GpkquYNIrWJgQlQ7rdsMYoFwFhGzN16rd5vJUWqMGcuGgmHw96bcEeL8rWJgQlQ7rds1L3jOH8QrxyitqbIsZqWJgQlQ7rdpIyRq4iOH8QrxyitqbIsEJGhnKxn6cdzcA4aviGsrddpA6Kr)ow3JejGOUyXnAS4O4eBCwwjlMxqwmul)IB0yXHcGjrkt0EKLMDXI51I5nfqd1f19OX8f19Oar5KqWJgYRgDHHmbnUz0GibAOUOUhnAvqPgDbnA1UNGgSlsKmLD(S(oaZoR1NIYLREyl2)fZUi1QCZfOC248CzPOC5QhgA0Qa7RCcAWUGy9MrbIskGGhnKxn6cdzcA4aviGsrddpA6u7vm6dWL8Mrd1f19ObDbeJ(DmuGOeQqWJgQlQ7rddbqeqU6HHgYRgDHHmbfikPye8OH6I6E0OxWYcI1pMhdgN8bAiVA0fgYeuGOeQHGhnKxn6cdzcA4aviGsrddpA6u7vm6dWL8Mrd1f19OH(oHeaTBDAVJceLtgcE0qDrDpAyOWShTnaLlhbnKxn6cdzckquYppcE0qE1OlmKjOHduHakfnuxuTIvEHReYI5zX8rd1f19ObW7TQlQ7T9IeOrViH9vobnCDrBfuGOKpFe8OH8QrxyitqdhOcbukAOUOAfR8cxjKfdzX8rd1f19ObW7TQlQ7T9IeOrViH9vobni1dRlOafOXmqChNHgi4ruYhbpAOUOUhnMVOUhnKxn6cdzckquAgcE0qE1OlmKjOXnJgejqd1f19OrRck1OlOrR29e0GUFhyXuTyQw8KsuyXtxScfbuHK8LvKzbqShTnYelt5EHLa6NBXuVy)OlMQfZFXtxC(Kzu8InDXkueqfsIikOEywwP9dMNKa6NBXuVyQrJwfyFLtqdU6zwJUscBOaysqqbIsEJGhnKxn6cdzcACZObrc0qDrDpA0QGsn6cA0QDpbnOAX8x8ewC(uEkEXMUyfkcOcjXenYSrg4escOFUfpDX5tMTytxScfbuHKISZdwwyZuqRqcbKa6NBXuVytxmvlM)INWIZNYpzl20fRqraviPi78GLf2mf0kKqajG(5wSPlwHIaQqserb1dZYkTFW8Keq)ClMA0Ovb2x5e0G4B2gaTclq)CeRltC5qbIYjHGhnKxn6cdzcACZObrc0qDrDpA0QGsn6cA0QDpbnOAX8x8ewC(u(jTytxScfbuHKISZdwwyZuqRqcbKa6NBXtyX5t5PWInDXkueqfsImxHq71T68ScQOUNKa6NBXuJgTkW(kNGgTHnaAfwG(5iwxM4YHceLuabpAiVA0fgYe04MrdIeOH6I6E0OvbLA0f0Ov7EcAq1I5V4jS48P8u8InDXkueqfsIjAKzJmWjKeq)ClEcloFkpVxSPlwHIaQqsr25bllSzkOviHasa9ZT4jS48P8uGcl20fRqravijYCfcTx3QZZkOI6EscOFUft9InDXuTy(lEcloFkVzu8InDXkueqfskYopyzHntbTcjeqcOFUfB6IvOiGkKeruq9WSSs7hmpjb0p3IPgnAvG9vobnAdlxrSbqRWc0phX6YexouGOeQqWJgYRgDHHmbnUz0GibAOUOUhnAvqPgDbnA1UNGg8x8ewC(uE(tAXMUyfkcOcjrefupmlR0(bZtsa9ZHgTkW(kNGgTHLRiwcZ6YexouGOKIrWJgYRgDHHmbnCGkeqPOXeVydpA6ejtzNp6dWL8Mrd1f19ObjtzNp6dWHceLqne8OH8QrxyitqJx5e0qHcjtbkXsFFypA785taOH6I6E0qHcjtbkXsFFypA785taOar5KHGhnKxn6cdzcA4aviGsrdYS072qbWKGK4QNzjIcwmVwSzlUrJfRqraviPi78GLf2mf0kKqajG(5wmKfNhnuxu3JgC1ZSgDLeOarj)8i4rd1f19OrRYnxGYzJZZLHgYRgDHHmbfOanCmccEeL8rWJgYRgDHHmbnCGkeqPObvl2WJMo1EfJ(aCjsOUClMNfBw(f7)IRNOFfMVyEbzXui)IPEXnASydpA6u7vm6dWLiH6YTyEwmvl2mOAXtxmfVytxSHhnDYOFhR7rIK38IPEXnASyQwSZdaKpS1t0VcZTmGw)InDXuTyQwmmhlXP(HfB6InBXuV4PlwDrDFIREM1ORKi5usyJItwm1lM6fZZIRNOFfMJgQlQ7rdoH7aMBpAB3ZvmldikhbfikndbpAOUOUhnm63XShTnYeR8cN5OH8QrxyitqbIsEJGhnKxn6cdzcA4aviGsrddpA6u7vm6dWLiH6YTyEwmFkGgQlQ7rdyEkGv6BpARcfbCrgkquoje8OH8QrxyitqdhOcbukAqMLE3gkaMeKex9mlruWI5bYInBXnASyGwmR0kFKugJKQFX8SyOkpAOUOUhnOpNhrywfkcOcXAikhkqusbe8OH8QrxyitqdhOcbukAqMLE3gkaMeKex9mlruWI5bYInBXnASyGwmR0kFKugJKQFX8SyOkpAOUOUhnM9afT51dZA0vsGceLqfcE0qE1OlmKjOH6I6E0WDVt(aOHWS0DLtqdhOcbukAefNSyEbzX8ZV4gnwmvl2WJMo5YoGhXE026j6xH5jsOUClMhilMpfwS)l2WJMo1EfJ(aCjV5ft9IB0yX0E9UfiUmfatSrXjlMxlgMJT4gnwCuCInolRKfZRftb0OxVyDm0aQqbIskgbpAOUOUhna18CxS1BjZQtqd5vJUWqMGceLqne8OH6I6E0ai6C9WS0DLtiOH8QrxyitqbIYjdbpAOUOUhn8DGoRvQ3ceY967e0qE1OlmKjOarj)8i4rd5vJUWqMGgoqfcOu0GQfB4rtNAVIrFaUK38I9FXgE00jx2b8i2J2wpr)kmprc1LBX8SyZYVyQxCJglwHIaQqsUSd4rShTTEI(vyEcOFUfdzX5rd1f19OHt7DR6I6EBVibA0lsyFLtqdhOcRJrqbIs(8rWJgQlQ7rdpIyRq4iOH8Qrxyitqbkqdxx0wbbpIs(i4rd1f19Or7vmRa8MJ6E0qE1OlmKjOarPzi4rd5vJUWqMGgoqfcOu0WWJMo1EfJ(aCj257rd1f19Obtb5SkXjpPUhfik5ncE0qE1OlmKjOHduHakfnM4fhLlx9WwS)lwHIaQqsr25bllSzkOviHasa9ZTyEGSy(OH6I6E0Ov5Mlq5SX55YqbIYjHGhnKxn6cdzcA4aviGsrddpA6uMcAfsimBKDEWYcsYBgnuxu3JgC1ZSerbOarjfqWJgQlQ7rJ2RywJRhOH8QrxyitqbIsOcbpAiVA0fgYe0qDrDpA40E3QUOU32lsGg9Ie2x5e0WXiOarjfJGhnKxn6cdzcAOUOUhnizk78z9DaMLjAKHgoqfcOu0ikoXgNLvYI51I59IB0yXgE00P2Ry0hGlXoFpA4m31fBOaysqquYhfikHAi4rd5vJUWqMGgoqfcOu0WWJMo1EfJ(aCjsOUClMNfZp)INUyQwm)8l20fB4rtNm63X6EKi5nVyQrd1f19ObXdaKNjaBCwoL9cHGceLtgcE0qE1OlmKjOHduHakfnaAXSsR8rszmsQ(fZZI5NFX(VyQwm7IejtzNpRVdWSZA9jGqdesMA0Lf3OXIJItSXzzLSyEwmVZVyQrd1f19Obtb5STxXqbIs(5rWJgQlQ7rdU6zgYZeaAiVA0fgYeuGOKpFe8OH8Qrxyitqd1f19Obx9mRrxjbA4aviGsrdYS072qbWKGK4QNzjIcwmVwCRck1OljU6zwJUscBOaysqqdN5UUydfatccIs(OarjFZqWJgYRgDHHmbnCGkeqPObvlgOfZkTYhjLXiP6xmplMcl2)fd0IzLw5JKYyKeZdOrD)I51InBXuV4gnwmqlMvALpskJrsmpGg19lMNfBgAOUOUhnizk78zDaLKHceL85ncE0qE1OlmKjOH6I6E0GKPSZN13by2zTE0WbQqaLIgt8IdTlFK4kIampjVA0f2I9FXaHgiKm1Oll2)fhfNyJZYkzX8SyQwmvlEclMFYSfpDX8oX7fB6IjZsVBdfatcsIREMLikyXuVytxCRck1OljIVzBa0kSa9ZrSUmXLBXMUyQwm)fpHfNpLNVzl20fRqravijIOG6HzzL2pyEscOFUfB6IjZsVBdfatcsIREMLikyXuVyQrdN5UUydfatccIs(Oarj)jHGhnKxn6cdzcAOUOUhnAvU5cuoBCEUm0WbQqaLIgaHgiKm1Oll2)fhfNyJZYkzX8SyQwmvlM)INUyEN49InDXKzP3THcGjbjXvpZsefSyQxSPlUvbLA0LuBydGwHfOFoI1LjUCl20ft1I5V4PloFIF(fB6IvOiGkKeruq9WSSs7hmpjb0p3InDXKzP3THcGjbjXvpZsefSyQxm1OHZCxxSHcGjbbrjFuGOKpfqWJgYRgDHHmbnuxu3JgTk3CbkNnopxgA4aviGsrd2fjsMYoFwFhGzN16taHgiKm1Oll2)ft1IdTlFK4kIampjVA0f2I9FXrXj24SSswmplMQft1I5NYV4Pl2Su(fB6IjZsVBdfatcsIREMLikyXuVytxCRck1OlP2WYveBa0kSa9ZrSUmXLBXMUyQwCRck1OlP2WYvelHzDzIl3InDXKzP3THcGjbjXvpZsefSyQxm1lMA0WzURl2qbWKGGOKpkquYhQqWJgYRgDHHmbnCGkeqPOHHhnDQ9kg9b4sEZOH6I6E0O9kMnoaq(afik5tXi4rd5vJUWqMGgQlQ7rdU6zwIOa0O(qaaV5Ww0OruUCeEGygAuFiaG3CylooHvAiObF0WbQqaLIgKzP3THcGjbjXvpZsefSyEwmF0WLP1Jg8rbIs(qne8OH8Qrxyitqd1f19Obx9mlDxnhnQpeaWBoSfnAeLlhHhiM5pvU76SZ3NAVIznUEK8MB0WDxND((ex9mRrxjrYBMA0O(qaaV5WwCCcR0qqd(OHltRhn4JceL8Nme8OH6I6E0GKPSZN13by2zTE0qE1OlmKjOafOHduH1Xii4ruYhbpAiVA0fgYe04vobnuOqYuGsS03h2J2oF(eaAOUOUhnuOqYuGsS03h2J2oF(eakquAgcE0qE1OlmKjOH6I6E0WzURFb4(Yzn6kjqdHMwCH9vobnCM76xaUVCwJUscuGcuGgTcGu3JO0S88Nm(55dvOHpf81dJGgqDCZhie2IHQfRUOUFX9IeK02eniZIdrPzuaQHgZGJU6cA43fpYu25BXteGsiX20VlolIzYefo4GvrMNrYDCWrkoVUg19oGshWrkohCBt)U4M67PaZxSz8HEXML3S8BZTPFxSFMPpmHmr3M(DXtyXq9mMWw8O6Y7K020VlEcl2pVVvaHWwCOaysyl6ftm)d1pK2M(DXtyX(59Tcie2IdfatIuuCInolRKfh3IJItSXzzLSyFzcqwSop3lNA0L02CB63f7h3pioVqyl2qOpGSy3XzOXIney1tslgQ35K5GS4)(jKPaoAV(Ivxu3tw89DZtBt)Uy1f19K0mqChNHgqO7kj320VlwDrDpjnde3XzOXuiWrFhBB63fRUOUNKMbI74m0yke4upyCYhAu3Vn97IhVotYUyXaTyl2WJMwylMeAqwSHqFazXUJZqJfBiWQNSy9zlEgity(IOEylUilMDVK2M(DXQlQ7jPzG4oodnMcboYRZKSlSKqdY2uDrDpjnde3XzOXuiWnFrD)2uDrDpjnde3XzOXuiW1QGsn6c0VYjq4QNzn6kjSHcGjbb6BgcrcOB1UNaHUFhGkQMuIctvOiGkKKVSImlaI9OTrMyzk3lSeq)Cu7hLk(tZNmJInvHIaQqserb1dZYkTFW8Keq)Cut92uDrDpjnde3XzOXuiW1QGsn6c0VYjqi(MTbqRWc0phX6YexoOVziejGUv7EceQ4pH8P8uSPkueqfsIjAKzJmWjKeq)CtZNmZufkcOcjfzNhSSWMPGwHecib0ph1Msf)jKpLFYmvHIaQqsr25bllSzkOviHasa9ZzQcfbuHKiIcQhMLvA)G5jjG(5OEBQUOUNKMbI74m0yke4AvqPgDb6x5eiTHnaAfwG(5iwxM4Yb9ndHib0TA3tGqf)jKpLFsMQqraviPi78GLf2mf0kKqajG(5Mq(uEkyQcfbuHKiZvi0EDRopRGkQ7jjG(5OEBQUOUNKMbI74m0yke4AvqPgDb6x5eiTHLRi2aOvyb6NJyDzIlh03meIeq3QDpbcv8Nq(uEk2ufkcOcjXenYSrg4escOFUjKpLN3MQqraviPi78GLf2mf0kKqajG(5Mq(uEkqbtvOiGkKezUcH2RB15zfurDpjb0ph1Msf)jKpL3mk2ufkcOcjfzNhSSWMPGwHecib0pNPkueqfsIikOEywwP9dMNKa6NJ6TP6I6EsAgiUJZqJPqGRvbLA0fOFLtG0gwUIyjmRltC5G(MHqKa6wT7jq4pH8P88NKPkueqfsIikOEywwP9dMNKa6NBBQUOUNKMbI74m0yke4izk78rFaoOlAitSHhnDIKPSZh9b4sEZBt1f19K0mqChNHgtHaNhrSviCq)kNarHcjtbkXsFFypA785taBt1f19K0mqChNHgtHahx9mRrxjb0fneYS072qbWKGK4QNzjIc4LznAOqraviPi78GLf2mf0kKqajG(5GKFBQUOUNKMbI74m0yke4AvU5cuoBCEUST520Vl2pUFqCEHWwS0kaZxCuCYIJmzXQloWIlYI1wT6QrxsBt1f19eiKQlVt2MQlQ7jtHaNhrSviCKTP6I6EYuiWnFrDp0fnedpA6Kr)ow3JejGOUOrJO4eBCwwj8cculFJgHcGjrkt0EKLMDbV4nf2MQlQ7jtHaxRck1Olq)kNaHDbX6nd9ndHib0TA3tGWUirYu25Z67am7SwFkkxU6H5p7IuRYnxGYzJZZLLIYLREyBt1f19KPqGJUaIr)og0fnedpA6u7vm6dWL8M3MQlQ7jtHaNHaicix9W2MQlQ7jtHaxVGLfeRFmpgmo5JTP6I6EYuiWPVtibq7wN27qx0qm8OPtTxXOpaxYBEBQUOUNmfcCgkm7rBdq5Yr2MQlQ7jtHahW7TQlQ7T9Ieq)kNaX1fTvGUOHOUOAfR8cxjeE4Vnvxu3tMcboG3Bvxu3B7fjG(vobcPEyDb6IgI6IQvSYlCLqGWFBUnNUy)Uykcrw8ePWDaZx8rV4jFEUITykkquoYIbfSSyXgc9bKfB(5TyfilwnoVyXXTyAT3x85fl(Ox8K7kg9b42MQlQ7jjhJaHt4oG52J229CfZYaIYrGUOHqLHhnDQ9kg9b4sKqD54XS8(xpr)kmNxqOqEQB0WWJMo1EfJ(aCjsOUC8qLzq1uk2udpA6Kr)ow3JejVzQB0GkNhaiFyRNOFfMBzaTEtPIkyowIt9dMAg1tvxu3N4QNzn6kjsoLe2O4eQPMN6j6xH5Bt1f19KKJrMcboJ(Dm7rBJmXkVWz(2uDrDpj5yKPqGdMNcyL(2J2QqraxKbDrdXWJMo1EfJ(aCjsOUC8WNcBt1f19KKJrMcbo6Z5reMvHIaQqSgIYbDrdHml9UnuamjijU6zwIOaEGywJgaTywPv(iPmgjvppqv(TP6I6EsYXitHa3ShOOnVEywJUscOlAiKzP3THcGjbjXvpZsefWdeZA0aOfZkTYhjLXiP65bQYVn97IN80kwSglUlkjwmurwSHe(e5xStjr9WwSFo5pTykcrwCKjlMUaKyXoLelgQFa1prS44wmmjwCfl((f7NuuOxCKj)ILwby(IjEgeXpsp5Jf7usSys251zl2qwShryl2xM8l2pZoGhzXh9IH6EI(vy(IlYIvxuTYIpWIRyX(QEFXaXLPayYIRFXrMS4x8dXIH5yqV4dS4itwCOaysS4ISy148Ifh3IzLK2MQlQ7jjhJmfcCU7DYhaneMLURCc096fRJbbQGUOHefNWli8Z3ObvgE00jx2b8i2J2wpr)kmprc1LJhi8PG)gE00P2Ry0hGl5ntDJg0E9UfiUmfatSrXj8cMJ1OruCInolReErHTP6I6EsYXitHahOMN7ITElzwDY2uDrDpj5yKPqGdi6C9WS0DLtiBt1f19KKJrMcboFhOZAL6TaHCV(ozB63ftriYIJmHil2DxND(EYIRFXgs4tKFXMFEGfZNelwF2In7zlEYDfBXMC9yX1VyZppWIn7zlEYDfJ(aCl2xM8l28ZBXzARSy)m7aEKfF0lgQ7j6xH5lwDr1kBt1f19KKJrMcboN27w1f192ErcOFLtG4avyDmc0fneQm8OPtTxXOpaxYB2FdpA6Kl7aEe7rBRNOFfMNiH6YXJz5PUrdfkcOcj5YoGhXE026j6xH5jG(5GKFB63ftrfA1RhlMw7Dd1LBX0hyXEe1OllUcHJmrxmfHil((f7URZoFFABQUOUNKCmYuiW5reBfchzBUnvxu3tsUUOTcK2Rywb4nh19Bt1f19KKRlARmfcCmfKZQeN8K6EOlAigE00P2Ry0hGlXoF)2uDrDpj56I2ktHaxRYnxGYzJZZLbDrdzIJYLREy(RqraviPi78GLf2mf0kKqajG(54bc)TP6I6EsY1fTvMcboU6zwIOaOlAigE00Pmf0kKqy2i78GLfKK382uDrDpj56I2ktHax7vmRX1JTP6I6EsY1fTvMcboN27w1f192ErcOFLtG4yKTP6I6EsY1fTvMcbosMYoFwFhGzzIgzq7m31fBOaysqGWh6IgsuCInolReEX7gnm8OPtTxXOpaxID((TP6I6EsY1fTvMcboIhaipta24SCk7fcb6IgIHhnDQ9kg9b4sKqD54HF(PuXpVPgE00jJ(DSUhjsEZuVn97IPiezXuufKBXtURyl((f7Nu0f79DHqwSYyKfRazX17oU6HT46xm)8KfFGf3fcjTnvxu3tsUUOTYuiWXuqoB7vmOlAiaTywPv(iPmgjvpp8Z7pvSlsKmLD(S(oaZoR1NacnqizQrxA0ikoXgNLvcp8op1Bt1f19KKRlARmfcCC1ZmKNjGTP6I6EsY1fTvMcboU6zwJUscODM76Inuamjiq4dDrdHml9UnuamjijU6zwIOaE1QGsn6sIREM1ORKWgkaMeKTP6I6EsY1fTvMcbosMYoFwhqjzqx0qOcOfZkTYhjLXiP65Hc(d0IzLw5JKYyKeZdOrDpVmJ6gnaAXSsR8rszmsI5b0OUNhZ2MQlQ7jjxx0wzke4izk78z9DaMDwRhAN5UUydfatcce(qx0qM4q7YhjUIiaZtYRgDH5pqObcjtn6I)rXj24SSs4HkQMa)Kzt5DI3MsMLE3gkaMeKex9mlrua1M2QGsn6sI4B2gaTclq)CeRltC5mLk(tiFkpFZmvHIaQqserb1dZYkTFW8Keq)CMsMLE3gkaMeKex9mlrua1uVnvxu3tsUUOTYuiW1QCZfOC248Czq7m31fBOaysqGWh6IgcqObcjtn6I)rXj24SSs4HkQ4pL3jEBkzw6DBOaysqsC1ZSerbuBARck1OlP2WgaTclq)CeRltC5mLk(tZN4N3ufkcOcjrefupmlR0(bZtsa9Zzkzw6DBOaysqsC1ZSerbut92uDrDpj56I2ktHaxRYnxGYzJZZLbTZCxxSHcGjbbcFOlAiSlsKmLD(S(oaZoR1NacnqizQrx8NQq7YhjUIiaZtYRgDH5FuCInolReEOIk(P8tnlL3uYS072qbWKGK4QNzjIcO20wfuQrxsTHLRi2aOvyb6NJyDzIlNPu1QGsn6sQnSCfXsywxM4Yzkzw6DBOaysqsC1ZSerbutn1Bt1f19KKRlARmfcCTxXSXbaYhqx0qm8OPtTxXOpaxYBEBQUOUNKCDrBLPqGJREMLika6Igczw6DBOaysqsC1ZSerb8WhAxMwpe(qxFiaG3CylooHvAiq4dD9HaaEZHTOHeLlhHhiMTnvxu3tsUUOTYuiWXvpZs3vZH2LP1dHp01hca4nh2IJtyLgce(qxFiaG3CylAir5Yr4bIz(tL7Uo789P2RywJRhjV5gnC31zNVpXvpZA0vsK8MPEBQUOUNKCDrBLPqGJKPSZN13by2zT(T52uDrDpj5avyDmcepIyRq4G(vobIcfsMcuIL((WE025ZNa2MQlQ7jjhOcRJrMcbopIyRq4GwOPfxyFLtG4m31VaCF5SgDLeBZTP6I6EsIupSUaP9kMvaEZrD)2uDrDpjrQhwxMcboMcYzvItEsDp0fnedpA6u7vm6dWLyNVFBQUOUNKi1dRltHax7vmRX1JTP6I6EsIupSUmfcCoT3TQlQ7T9Ieq)kNaXXiBt)Uykcrw8ez9SfpefS47x8a(fFF38fx0l28ZBXWKyX6IHp78GLfl2pcf0kKqalEIaCUf7RISfRXI7IsIfZFXdrb1dBXu0s7hmpzXWd0ksBt1f19KePEyDzke44QNzjIcGUOHy4rtNYuqRqcHzJSZdwwqsEZ(7URZoFFQ9kM146rciCA9eEGWprb)vOiGkKeruq9WSSs7hmpjb0phpq4Vn97IPiezXJjpk6Ine6dil2PZZ1dBXUmfatiqV4dS4itwCOaysS4ISy148Ifh3IzLK2MQlQ7jjs9W6YuiWrYu25Z67amlt0id6IgsOaysKIItSXzzLWlE3OH7Uo789jsMYoFwFhGzzIgzjxMcGjeiM1ObvU76SZ3Nizk78z9DaMLjAKLCzkaMqGW3F3DD257tKmLD(S(oaZYenYsaHtRNWlyowIt9duVnvxu3tsK6H1LPqGJ4baYZeGnolNYEHqGUOHy4rtNAVIrFaUejuxoE4NFkv8ZBQHhnDYOFhR7rIK3m1BZPl2VlMIqKftrvqUfp5UIT47xSFsrxS33fczXkJrwScKfxV74Qh2IRFX8Ztw8bwCxiK02uDrDpjrQhwxMcboMcYzBVIbDrdbOfZkTYhjLXiP65HF(TPFxmfHilEISEMH8mbSynwm)jBXhyXChqwmjuxoc0l(alUOxCKjlouamjwSVQ3xmRKfx)I7cHS4it)fZNcK02uDrDpjrQhwxMcboU6zgYZea0fnKq7YhjU6zgYZeqsE1OlSgnOYWJMo1EfJ(aCjsOUC8WhQ1OruCInolReEXNcuVnvxu3tsK6H1LPqGJKPSZN13bywMOrg0fnKj2WJMo1EfJ(aCjV5gnOYDxND((ejtzNpRVdWSmrJSKltbWeceZ83WJMo1EfJ(aCjsOUC8IpfOEB63ftriYIhzk78Ty)eOKSfF)I9tk6I9(UqiloYeGSyfilwzmYIR3DC1dlTnvxu3tsK6H1LPqGJKPSZN1busg0fneGwmR0kFKugJKQNhk4pqlMvALpskJrsmpGg198YS8Bt)Uyt0p3IJmzXJmLD(w8K3byt0fp5UITyxMcGjKftFGfRl2OIfh3IdG5lwF2I12Ryl(AfGtNNRh2IVFXqDpr)kmpTnvxu3tsK6H1LPqGJREM1ORKa6IgsRck1Olj2feR3S)urfqlMvALpsCxRWjFKQNhNscBuCY08jk4pqlMvALpsCxRWjFKQNxtI6gnM4q7YhjsMYoFwFhGzBVILKxn6cRrddpA6u7vm6dWLyNVVrddpA6u7vm6dWLiH6YXd)j5pv1t0VcZ5ffNVrdxMcGjelnqDrDV25HFI38M6gnm8OPtTxXOpaxIeQlhVGWFs(tv9e9RWCEbv5B0WLPaycXsduxu3RDE4N4nVPM6TP6I6EsIupSUmfcCTxXSXbaYhqx0qyxKizk78z9DaMDwRpbeoTEcptYF2fPwLBUaLZgNNllbeoTEcptYFdpA6u7vm6dWL8M3MQlQ7jjs9W6YuiWrYu25Z67am7Swp0fneGqdesMA0f)JItSXzzLWZK8FIdTlFK4kIampjVA0fM)tCOD5Jetb5STxXsYRgDHTnvxu3tsK6H1LPqGRv5Mlq5SX55YGUOHaeAGqYuJU4FuCInolReEGQgnOk0U8rIRicW8K8Qrxy(ZUirYu25Z67am7SwFci0aHKPgDH6TP6I6EsIupSUmfcCC1ZS0D1CODzA9q4dD9HaaEZHT44ewPHaHp01hca4nh2IgsuUCeEGyM)u5URZoFFQ9kM146rYBUrd3DD257tC1ZSgDLejVzQ3MQlQ7jjs9W6YuiWrYu25Z67am7Swpkqbcb]] )


end
