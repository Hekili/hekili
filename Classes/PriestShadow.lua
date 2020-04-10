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

            start = function ()
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


    spec:RegisterPack( "Shadow", 20200410, [[dOuEcbqiPO0JeP0LePq1MKImkKuNcvXQOi9kfPzbsDlrQSlQ6xGkdtu1XqvTmrINrr00ePQRHeSnqs(gsOghiPCoPOQ1jfvmpkc3de7dj6GsrrlevPhksrtejexuKcLnksHWibjvQtcsQALkIzksHOBkffANijdvkk4PkmvqvxfjK2QuuPVcsQyVq(lLgmuhM0IPWJPYKr5YeBgP(mOmAr50swTifsVwuz2s1TrLDRQFRYWvuhhKujlh45iMUW1fX2LsFNIA8IuW5fjTEqI5lf2VsJ4JGhnyAiiQsjFk5ZNE(595BEkKpF6rJi1zbnMvxofMGgVYjOXitzNz0ywtTFkdbpAqUeGtqJSiMjnh4GdwfzjgE3XbhP4s6Au37akDahP4CWHggjvpG6FKbAW0qquLs(uYNp98Z7Z38PV5PafJgAsKDa0yuCPjAKvmM8id0GjehAK2fpYu2zEXndGsiXojTlolIzsZbo4GvrwIH3DCWrkUKUg19oGshWrkohC7K0U4M5mO6lMFEOxCk5tj)ozNK2fNMz6dtinNDsAxC6wCZKXe2IhvxEN43jPDXPBXP59Tcie2IdfatcBrVysQFOPb)ojTloDlonVVvaHWwCOays4JItSXzzLS44wCuCInolRKfBotaYI155E5uJU4rJErcccE0GupSUGGhrfFe8OH6I6E0O9kMvajZrDpAiVA0fgIxuGOkfe8OH8QrxyiErdhOcbukAyKqt7BVIrFaop7m)OH6I6E0GPGCwL4KNu3JcevMebpAOUOUhnAVIznUEGgYRgDHH4ffiQspcE0qE1OlmeVOH6I6E0WP9UvDrDVTxKan6fjSVYjOHJrqbIkkGGhnKxn6cdXlA4aviGsrdJeAAFMcAfsimBKDjWYcIpzEXnTy3DD2z(9TxXSgxp8aHtRNSykHSy(EkS4MwScfbuH4jIcQhMLvA)GLiEG(5wmLqwmF0qDrDpAWvpZsefGcevqfcE0qE1OlmeVOHduHakfncfatcFuCInolRKfBIfBYf3OXID31zN53tYu2z2A(amlt0iZ7YuamHSyiloLf3OXIPEXU76SZ87jzk7mBnFaMLjAK5DzkaMqwmKfZFXnTy3DD2z(9KmLDMTMpaZYenY8aHtRNSytSyyoMNttdlMh0qDrDpAqYu2z2A(amlt0idfiQOye8OH8QrxyiErdhOcbukAyKqt7BVIrFaopjuxUft5I5NFXtxm1lMF(fB6InsOP9g97y9es4tMxmpOH6I6E0GKaaYZeGnolNYEHqqbIkOgcE0qE1OlmeVOHduHakfnaAXSsR8HxzmIV(ft5I5Nhnuxu3JgmfKZ2EfdfiQAEe8OH8QrxyiErdhOcbukAeAx(WZvpZqEMa8YRgDHT4gnwm1l2iHM23EfJ(aCEsOUClMYfZhQT4gnwCuCInolRKfBIfZNclMh0qDrDpAWvpZqEMaqbIk(5rWJgYRgDHH4fnCGkeqPOrZUyJeAAF7vm6dW5tMxCJglM6f7URZoZVNKPSZS18bywMOrM3LPayczXqwCklUPfBKqt7BVIrFaopjuxUfBIfZNclMh0qDrDpAqYu2z2A(amlt0idfiQ4ZhbpAiVA0fgIx0WbQqaLIgaTywPv(WRmgXx)IPCXuyXnTyGwmR0kF4vgJ4zjanQ7xSjwCk5rd1f19ObjtzNzRdOKmuGOIFki4rd5vJUWq8IgoqfcOu0OvbLA0fp7cInzEXnTyQxm1lgOfZkTYhEURv4Kp81VykxStjHnkozXtxCEpfwCtlgOfZkTYhEURv4Kp81VytS40VyEwCJglUzxCOD5dpjtzNzR5dWSTxX8YRgDHT4gnwSrcnTV9kg9b48SZ8V4gnwSrcnTV9kg9b48KqD5wmLlMF6xCtlM6fxpr)ksDXMyXuC(f3OXIDzkaMqS0a1f19AFXuUy(EtAYfZZIB0yXgj00(2Ry0hGZtc1LBXMaYI5N(f30IPEX1t0VIuxSjwmuLFXnASyxMcGjelnqDrDV2xmLlMV3KMCX8SyEqd1f19Obx9mRrxjbkquX3Ki4rd5vJUWq8IgoqfcOu0GDHNKPSZS18by2zTEpq406jlMYfN(f30Izx4BvU5cuoBCjUmpq406jlMYfN(f30InsOP9TxXOpaNpzgnuxu3JgTxXSXbaYhOarf)0JGhnKxn6cdXlA4aviGsrdGqdesMA0Lf30IJItSXzzLSykxC6xCtlUzxCOD5dpxreqQE5vJUWwCtlUzxCOD5dptb5STxX8YRgDHHgQlQ7rdsMYoZwZhGzN16rbIk(uabpAiVA0fgIx0WbQqaLIgaHgiKm1OllUPfhfNyJZYkzXuUyOAXnASyQxCOD5dpxreqQE5vJUWwCtlMDHNKPSZS18by2zTEpqObcjtn6YI5bnuxu3JgTk3CbkNnUexgkquXhQqWJgYRgDHH4fnuxu3JgC1ZS0Dnv0O(qaGK5Ww0OruUCekHKstu7URZoZVV9kM146HpzUrd3DD2z(9C1ZSgDLe(KzEqJ6dbasMdBXXjSsdbn4JgUmTE0GpkquXNIrWJgQlQ7rdsMYoZwZhGzN16rd5vJUWq8IcuGgmHwt6bcEev8rWJgQlQ7rds1L3jOH8QrxyiErbIQuqWJgQlQ7rJeIyRq4iOH8QrxyiErbIktIGhnKxn6cdXlA4aviGsrdJeAAVr)owpHeEGOUyXnAS4O4eBCwwjl2eqwmul)IB0yXHcGjHpt0EK5NDXInXInjfqd1f19OX8f19Oarv6rWJgYRgDHH4fnUz0GibAOUOUhnAvqPgDbnA1EIGgSl8KmLDMTMpaZoR17JYLREylUPfZUW3QCZfOC24sCz(OC5QhgA0Qa7RCcAWUGytMrbIkkGGhnKxn6cdXlA4aviGsrdJeAAF7vm6dW5tMrd1f19ObDbeJ(DmuGOcQqWJgQlQ7rddbqeqU6HHgYRgDHH4ffiQOye8OH6I6E0OxWYcInnAcdgN8bAiVA0fgIxuGOcQHGhnKxn6cdXlA4aviGsrdJeAAF7vm6dW5tMrd1f19OH(oHeaTBDAVJcevnpcE0qDrDpAyOWShTnaLlhbnKxn6cdXlkquXppcE0qE1OlmeVOHduHakfnuxuTIvEHReYIPCX8rd1f19Obi5TQlQ7T9IeOrViH9vobnCDrBfuGOIpFe8OH8QrxyiErdhOcbukAOUOAfR8cxjKfdzX8rd1f19Obi5TQlQ7T9IeOrViH9vobni1dRlOafOXmqChNHgi4ruXhbpAOUOUhnMVOUhnKxn6cdXlkquLccE0qE1OlmeVOXnJgejqd1f19OrRck1OlOrR2te0GUFhyXuVyQxC69uyXtxScfbuH4nNvKzbqShTnYelt5EH5b6NBX8S404lM6fZFXtxCEFku8InDXkueqfINikOEywwP9dwI4b6NBX8SyEqJwfyFLtqdU6zwJUscBOaysqqbIktIGhnKxn6cdXlACZObrc0qDrDpA0QGsn6cA0Q9ebnOEX8xC6wCEFEkEXMUyfkcOcXZenYSrg4eIhOFUfpDX59PSytxScfbuH4JSlbwwyZuqRqcb4b6NBX8Sytxm1lM)It3IZ7Z38l20fRqravi(i7sGLf2mf0kKqaEG(5wSPlwHIaQq8erb1dZYkTFWsepq)ClMh0Ovb2x5e0GyE2gaTclq)CeRltC5qbIQ0JGhnKxn6cdXlACZObrc0qDrDpA0QGsn6cA0Q9ebnOEX8xC6wCEF(0VytxScfbuH4JSlbwwyZuqRqcb4b6NBXPBX595PWInDXkueqfINmxHqN0T68ScQOUN4b6NBX8GgTkW(kNGgTHnaAfwG(5iwxM4YHcevuabpAiVA0fgIx04MrdIeOH6I6E0OvbLA0f0Ov7jcAq9I5V40T48(8u8InDXkueqfINjAKzJmWjepq)CloDloVpVjxSPlwHIaQq8r2LallSzkOviHa8a9ZT40T48(8uGcl20fRqraviEYCfcDs3QZZkOI6EIhOFUfZZInDXuVy(loDloVpFku8InDXkueqfIpYUeyzHntbTcjeGhOFUfB6IvOiGkepruq9WSSs7hSeXd0p3I5bnAvG9vobnAdlxrSbqRWc0phX6YexouGOcQqWJgYRgDHH4fnUz0GibAOUOUhnAvqPgDbnA1EIGg8xC6wCEFE(PFXMUyfkcOcXtefupmlR0(blr8a9ZHgTkW(kNGgTHLRiwcZ6YexouGOIIrWJgYRgDHH4fnCGkeqPOrZUyJeAApjtzNz6dW5tMrd1f19ObjtzNz6dWHcevqne8OH8QrxyiErJx5e0qHcjtbkXsFFypA78zwaOH6I6E0qHcjtbkXsFFypA78zwaOarvZJGhnKxn6cdXlA4aviGsrdYS072qbWKG45QNzjIcwSjwCklUrJfRqravi(i7sGLf2mf0kKqaEG(5wmKfNhnuxu3JgC1ZSgDLeOarf)8i4rd1f19OrRYnxGYzJlXLHgYRgDHH4ffOanCmccEev8rWJgYRgDHH4fnCGkeqPOb1l2iHM23EfJ(aCEsOUClMYfNs(f30IRNOFfPUytazXui)I5zXnASyJeAAF7vm6dW5jH6YTykxm1lofOAXtxmfVytxSrcnT3OFhRNqcFY8I5zXnASyQxSlbaKpS1t0VIuTmGw)InDXuVyQxmmhZZPPHfB6ItzX8S4PlwDrDVNREM1ORKW7usyJItwmplMNft5IRNOFfPIgQlQ7rdoH7aPApABpXvmldikhbfiQsbbpAOUOUhnm63XShTnYeR8cxQOH8QrxyiErbIktIGhnKxn6cdXlA4aviGsrdJeAAF7vm6dW5jH6YTykxmFkGgQlQ7rdyjkGv6BpARcfbCrgkquLEe8OH8QrxyiErd1f19ObN(fTqIZE0woL9cHGgoqfcOu0Gml9UnuamjiEU6zwIOGftjKfNYIB0yXaTywPv(WRmgXx)IPCXqvE04vobn40VOfsC2J2YPSxieuGOIci4rd5vJUWq8IgoqfcOu0Gml9UnuamjiEU6zwIOGftjKfNYIB0yXaTywPv(WRmgXx)IPCXqvE0qDrDpAqFUeIWSkueqfI1quouGOcQqWJgYRgDHH4fnCGkeqPObzw6DBOaysq8C1ZSerblMsiloLf3OXIbAXSsR8HxzmIV(ft5IHQ8OH6I6E0yobu0PwpmRrxjbkqurXi4rd5vJUWq8IgQlQ7rd39o5dGgcZs3vobnCGkeqPOruCYInbKfZp)IB0yXuVyJeAAVl7aje7rBRNOFfP6jH6YTykHSy(uyXnTyJeAAF7vm6dW5tMxmplUrJftN07wG4YuamXgfNSytSyyo2IB0yXrXj24SSswSjwmfqJE9I1XqdOcfiQGAi4rd1f19ObOMN7ITElzwDcAiVA0fgIxuGOQ5rWJgQlQ7rdGOZ1dZs3voHGgYRgDHH4ffiQ4NhbpAOUOUhnmFGoRvQ3ceY967e0qE1OlmeVOarfF(i4rd5vJUWq8IgoqfcOu0G6fBKqt7BVIrFaoFY8IBAXgj00Ex2bsi2J2wpr)ks1tc1LBXuU4uYVyEwCJglwHIaQq8USdKqShTTEI(vKQhOFUfdzX5rd1f19OHt7DR6I6EBVibA0lsyFLtqdhOcRJrqbIk(PGGhnuxu3JgjeXwHWrqd5vJUWq8IcuGgUUOTccEev8rWJgQlQ7rJ2RywbKmh19OH8QrxyiErbIQuqWJgYRgDHH4fnCGkeqPOHrcnTV9kg9b48SZ8JgQlQ7rdMcYzvItEsDpkquzse8OH8QrxyiErdhOcbukA0SlokxU6HT4MwScfbuH4JSlbwwyZuqRqcb4b6NBXuczX8rd1f19OrRYnxGYzJlXLHcevPhbpAiVA0fgIx0WbQqaLIggj00(mf0kKqy2i7sGLfeFYmAOUOUhn4QNzjIcqbIkkGGhnuxu3JgTxXSgxpqd5vJUWq8IcevqfcE0qE1OlmeVOH6I6E0WP9UvDrDVTxKan6fjSVYjOHJrqbIkkgbpAiVA0fgIx0qDrDpAqYu2z2A(amlt0idnCGkeqPOruCInolRKfBIfBYf3OXInsOP9TxXOpaNNDMF0WLQRl2qbWKGGOIpkqub1qWJgYRgDHH4fnCGkeqPOHrcnTV9kg9b48KqD5wmLlMF(fpDXuVy(5xSPl2iHM2B0VJ1tiHpzEX8GgQlQ7rdscaipta24SCk7fcbfiQAEe8OH8QrxyiErdhOcbukAa0IzLw5dVYyeF9lMYfZp)IBAXuVy2fEsMYoZwZhGzN169aHgiKm1OllUrJfhfNyJZYkzXuUytMFX8GgQlQ7rdMcYzBVIHcev8ZJGhnuxu3JgC1ZmKNja0qE1OlmeVOarfF(i4rd5vJUWq8IgQlQ7rdU6zwJUsc0WbQqaLIgKzP3THcGjbXZvpZsefSytS4wfuQrx8C1ZSgDLe2qbWKGGgUuDDXgkaMeeev8rbIk(PGGhnKxn6cdXlA4aviGsrdQxmqlMvALp8kJr81VykxmfwCtlgOfZkTYhELXiEwcqJ6(fBIfNYI5zXnASyGwmR0kF4vgJ4zjanQ7xmLlof0qDrDpAqYu2z26akjdfiQ4Bse8OH8QrxyiErd1f19ObjtzNzR5dWSZA9OHduHakfnA2fhAx(WZvebKQxE1OlSf30IbcnqizQrxwCtlokoXgNLvYIPCXuVyQxC6wmFFklE6InP3Kl20ftMLE3gkaMeepx9mlruWI5zXMU4wfuQrx8eZZ2aOvyb6NJyDzIl3InDXuVy(loDloVpp)uwSPlwHIaQq8erb1dZYkTFWsepq)Cl20ftMLE3gkaMeepx9mlruWI5zX8GgUuDDXgkaMeeev8rbIk(PhbpAiVA0fgIx0qDrDpA0QCZfOC24sCzOHduHakfnacnqizQrxwCtlokoXgNLvYIPCXuVyQxm)fpDXM0BYfB6IjZsVBdfatcINREMLikyX8SytxCRck1Ol(2WgaTclq)CeRltC5wSPlM6fZFXtxCEp)8l20fRqraviEIOG6HzzL2pyjIhOFUfB6IjZsVBdfatcINREMLikyX8SyEqdxQUUydfatccIk(OarfFkGGhnKxn6cdXlAOUOUhnAvU5cuoBCjUm0WbQqaLIgSl8KmLDMTMpaZoR17bcnqizQrxwCtlM6fhAx(WZvebKQxE1OlSf30IJItSXzzLSykxm1lM6fZ3NFXtxCk(8l20ftMLE3gkaMeepx9mlruWI5zXMU4wfuQrx8THLRi2aOvyb6NJyDzIl3InDXuV4wfuQrx8THLRiwcZ6YexUfB6IjZsVBdfatcINREMLikyX8SyEwmpOHlvxxSHcGjbbrfFuGOIpuHGhnKxn6cdXlA4aviGsrdJeAAF7vm6dW5tMrd1f19Or7vmBCaG8bkquXNIrWJgYRgDHH4fnuxu3JgC1ZSerbOr9HaajZHTOrJOC5iucjf0O(qaGK5WwCCcR0qqd(OHduHakfniZsVBdfatcINREMLikyXuUy(OHltRhn4Jcev8HAi4rd5vJUWq8IgQlQ7rdU6zw6UMkAuFiaqYCylA0ikxocLqsPjQD31zN533EfZAC9WNm3OH7Uo7m)EU6zwJUscFYmpOr9HaajZHT44ewPHGg8rdxMwpAWhfiQ438i4rd1f19ObjtzNzR5dWSZA9OH8QrxyiErbkqdhOcRJrqWJOIpcE0qE1OlmeVOXRCcAOqHKPaLyPVpShTD(mla0qDrDpAOqHKPaLyPVpShTD(mlauGOkfe8OH8QrxyiErd1f19OHlvx)cW9LZA0vsGgcnT4c7RCcA4s11VaCF5SgDLeOafOanAfaPUhrvk5tjFE(PKE0WSc(6HrqdOEU5decBXq1Ivxu3V4ErcIFNGgKzXHOkfka1qJzWrxDbns7Ihzk7mV4MbqjKyNK2fNfXmP5ahCWQilXW7oo4ifxsxJ6EhqPd4ifNdUDsAxCZCgu9fZpp0loL8PKFNSts7ItZm9HjKMZojTloDlUzYycBXJQlVt87K0U40T408(wbecBXHcGjHTOxmj1p00GFNK2fNUfNM33kGqylouamj8rXj24SSswCClokoXgNLvYInNjazX68CVCQrx87KDsAxCAS0G4scHTydH(aYIDhNHgl2qGvpXV4MPZjZbzX)9PltbC0j9fRUOUNS477P63jPDXQlQ7j(zG4oodnGq3vsUDsAxS6I6EIFgiUJZqJPqGJ(o2ojTlwDrDpXpde3XzOXuiWPjW4Kp0OUFNK2fpEDMKDXIbAXwSrcnTWwmj0GSydH(aYIDhNHgl2qGvpzX6Zw8mqs38fr9WwCrwm7EXVts7Ivxu3t8ZaXDCgAmfcCKxNjzxyjHgKDI6I6EIFgiUJZqJPqGB(I6(DI6I6EIFgiUJZqJPqGRvbLA0fOFLtGWvpZA0vsydfatcc03meIeq3Q9ebcD)oa1uNEpfMQqraviEZzfzwae7rBJmXYuUxyEG(54jno18NM3NcfBQcfbuH4jIcQhMLvA)GLiEG(54HNDI6I6EIFgiUJZqJPqGRvbLA0fOFLtGqmpBdGwHfOFoI1LjUCqFZqisaDR2teiuZpD595PytvOiGkept0iZgzGtiEG(5MM3NIPkueqfIpYUeyzHntbTcjeGhOFoEmLA(PlVpFZBQcfbuH4JSlbwwyZuqRqcb4b6NZufkcOcXtefupmlR0(blr8a9ZXZorDrDpXpde3XzOXuiW1QGsn6c0VYjqAdBa0kSa9ZrSUmXLd6BgcrcOB1EIaHA(PlVpF6nvHIaQq8r2LallSzkOviHa8a9ZLU8(8uWufkcOcXtMRqOt6wDEwbvu3t8a9ZXZorDrDpXpde3XzOXuiW1QGsn6c0VYjqAdlxrSbqRWc0phX6YexoOVziejGUv7jceQ5NU8(8uSPkueqfINjAKzJmWjepq)CPlVpVjnvHIaQq8r2LallSzkOviHa8a9ZLU8(8uGcMQqraviEYCfcDs3QZZkOI6EIhOFoEmLA(PlVpFkuSPkueqfIpYUeyzHntbTcjeGhOFotvOiGkepruq9WSSs7hSeXd0php7e1f19e)mqChNHgtHaxRck1Olq)kNaPnSCfXsywxM4Yb9ndHib0TAprGWpD5955NEtvOiGkepruq9WSSs7hSeXd0p3orDrDpXpde3XzOXuiWrYu2zM(aCqx0qAwJeAApjtzNz6dW5tM3jQlQ7j(zG4oodnMcbUeIyRq4G(vobIcfsMcuIL((WE025ZSa2jQlQ7j(zG4oodnMcboU6zwJUscOlAiKzP3THcGjbXZvpZsefyIuA0qHIaQq8r2LallSzkOviHa8a9Zbj)orDrDpXpde3XzOXuiW1QCZfOC24sCz7KDsAxCAS0G4scHTyPvaPU4O4KfhzYIvxCGfxKfRTA1vJU43jQlQ7jqivxENStuxu3tMcbUeIyRq4i7e1f19KPqGB(I6EOlAigj00EJ(DSEcj8arDrJgrXj24SSsmbeOw(gncfatcFMO9iZp7ctyskStuxu3tMcbUwfuQrxG(vobc7cInzg6BgcrcOB1EIaHDHNKPSZS18by2zTEFuUC1dRj2f(wLBUaLZgxIlZhLlx9W2jQlQ7jtHahDbeJ(DmOlAigj00(2Ry0hGZNmVtuxu3tMcbodbqeqU6HTtuxu3tMcbUEblli20OjmyCYh7e1f19KPqGtFNqcG2ToT3HUOHyKqt7BVIrFaoFY8orDrDpzke4muy2J2gGYLJStuxu3tMcboqYBvxu3B7fjG(vobIRlARaDrdrDr1kw5fUsiuYFNOUOUNmfcCGK3QUOU32lsa9RCces9W6c0fne1fvRyLx4kHaH)ozNmDXPDXuuIS4MrH7aPU4JEXPrM4k2IPiar5ilguWYIfBi0hqwCQxYIvGSy14sIfh3IP1EFXxsS4JEXn3Ry0hGBNOUOUN4DmceoH7aPApABpXvmldikhb6Igc1gj00(2Ry0hGZtc1LJYuY3u9e9RivtaHc55PrdJeAAF7vm6dW5jH6Yrj1PavtPytnsOP9g97y9es4tM5PrdQDjaG8HTEI(vKQLb06nLAQH5yEonnyAk8mvDrDVNREM1ORKW7usyJIt4HhkRNOFfPUtuxu3t8ogzke4m63XShTnYeR8cxQ7e1f19eVJrMcboyjkGv6BpARcfbCrg0fneJeAAF7vm6dW5jH6YrjFkStuxu3t8ogzke4siITcHd6x5eiC6x0cjo7rB5u2lec0fneYS072qbWKG45QNzjIcOesknAa0IzLw5dVYyeF9ucv53jQlQ7jEhJmfcC0NlHimRcfbuHyneLd6Igczw6DBOaysq8C1ZSerbucjLgnaAXSsR8HxzmIVEkHQ87e1f19eVJrMcbU5eqrNA9WSgDLeqx0qiZsVBdfatcINREMLikGsiP0ObqlMvALp8kJr81tjuLFNK2fd1rRyXAS4UOKyXqfzXgsywKFXoLe1dBXPzAe(ftrjYIJmzX0fGel2PKyXnZrZSzyXXTyysS4kw89lonPiqV4it(flTci1ftsmicuxjYhl2PKyXKSlPZwSHS4eIWwS5m5xCAMDGeYIp6fd1)e9Ri1fxKfRUOALfFGfxXInx9(IbIltbWKfx)IJmzXVKgIfdZXGEXhyXrMS4qbWKyXfzXQXLeloUfZkXVtuxu3t8ogzke4C37KpaAimlDx5eO71lwhdcubDrdjkoXeq4NVrdQnsOP9USdKqShTTEI(vKQNeQlhLq4tHMmsOP9TxXOpaNpzMNgnOt6DlqCzkaMyJItmbmhRrJO4eBCwwjMGc7e1f19eVJrMcboqnp3fB9wYS6KDI6I6EI3XitHahq056HzP7kNq2jQlQ7jEhJmfcCMpqN1k1Bbc5E9DYojTlMIsKfhzcrwS7Uo7m)Kfx)InKWSi)It9salMpjwS(SfNYZwCZ9k2I596XIRFXPEjGfNYZwCZ9kg9b4wS5m5xCQxYIZ0wzXPz2bsil(Oxmu)t0VIuxS6IQv2jQlQ7jEhJmfcCoT3TQlQ7T9Ieq)kNaXbQW6yeOlAiuBKqt7BVIrFaoFYCtgj00Ex2bsi2J2wpr)ks1tc1LJYuYZtJgkueqfI3LDGeI9OT1t0VIu9a9Zbj)ojTlMIi0AspwmT27gQl3IPpWItiQrxwCfchP5Sykkrw89l2DxNDMF)orDrDpX7yKPqGlHi2keoYozNOUOUN4DDrBfiTxXScizoQ73jQlQ7jExx0wzke4ykiNvjo5j19qx0qmsOP9TxXOpaNNDM)DI6I6EI31fTvMcbUwLBUaLZgxIld6IgsZgLlx9WAsHIaQq8r2LallSzkOviHa8a9Zrje(7e1f19eVRlARmfcCC1ZSerbqx0qmsOP9zkOviHWSr2Lalli(K5DI6I6EI31fTvMcbU2RywJRh7e1f19eVRlARmfcCoT3TQlQ7T9Ieq)kNaXXi7e1f19eVRlARmfcCKmLDMTMpaZYenYG2LQRl2qbWKGaHp0fnKO4eBCwwjMWKnAyKqt7BVIrFaop7m)7e1f19eVRlARmfcCKeaqEMaSXz5u2lec0fneJeAAF7vm6dW5jH6Yrj)8tPMFEtnsOP9g97y9es4tM5zNK2ftrjYIPiki3IBUxXw89lonPilo57cHSyLXilwbYIR3DC1dBX1Vy(5jl(alUleIFNOUOUN4DDrBLPqGJPGC22Ryqx0qaAXSsR8HxzmIVEk5NVjQzx4jzk7mBnFaMDwR3deAGqYuJU0OruCInolReknzEE2jQlQ7jExx0wzke44QNzipta7e1f19eVRlARmfcCC1ZSgDLeq7s11fBOaysqGWh6Igczw6DBOaysq8C1ZSerbMOvbLA0fpx9mRrxjHnuamji7e1f19eVRlARmfcCKmLDMToGsYGUOHqnqlMvALp8kJr81tjfAcOfZkTYhELXiEwcqJ6EtKcpnAa0IzLw5dVYyeplbOrDpLPStuxu3t8UUOTYuiWrYu2z2A(am7Swp0UuDDXgkaMeei8HUOH0SH2Lp8CfraP6Lxn6cRjGqdesMA0LMIItSXzzLqj1uNo((uMAsVjnLml9UnuamjiEU6zwIOaEmTvbLA0fpX8SnaAfwG(5iwxM4Yzk18txEFE(PyQcfbuH4jIcQhMLvA)GLiEG(5mLml9UnuamjiEU6zwIOaE4zNOUOUN4DDrBLPqGRv5Mlq5SXL4YG2LQRl2qbWKGaHp0fneGqdesMA0LMIItSXzzLqj1uZFQj9M0uYS072qbWKG45QNzjIc4X0wfuQrx8THnaAfwG(5iwxM4Yzk18NM3ZpVPkueqfINikOEywwP9dwI4b6NZuYS072qbWKG45QNzjIc4HNDI6I6EI31fTvMcbUwLBUaLZgxIldAxQUUydfatcce(qx0qyx4jzk7mBnFaMDwR3deAGqYuJU0e1H2Lp8CfraP6Lxn6cRPO4eBCwwjusn1895NMIpVPKzP3THcGjbXZvpZsefWJPTkOuJU4BdlxrSbqRWc0phX6YexotPUvbLA0fFBy5kILWSUmXLZuYS072qbWKG45QNzjIc4HhE2jQlQ7jExx0wzke4AVIzJdaKpGUOHyKqt7BVIrFaoFY8orDrDpX76I2ktHahx9mlrua0fneYS072qbWKG45QNzjIcOKp0UmTEi8HU(qaGK5WwCCcR0qGWh66dbasMdBrdjkxocLqszNOUOUN4DDrBLPqGJREMLURPcTltRhcFORpeaizoSfhNWknei8HU(qaGK5Ww0qIYLJqjKuAIA3DD2z(9TxXSgxp8jZnA4URZoZVNREM1ORKWNmZZorDrDpX76I2ktHahjtzNzR5dWSZA97KDI6I6EI3bQW6yeijeXwHWb9RCcefkKmfOel99H9OTZNzbStuxu3t8oqfwhJmfcCjeXwHWbTqtlUW(kNaXLQRFb4(Yzn6kj2j7e1f19epPEyDbs7vmRasMJ6(DI6I6EINupSUmfcCmfKZQeN8K6EOlAigj00(2Ry0hGZZoZ)orDrDpXtQhwxMcbU2RywJRh7e1f19epPEyDzke4CAVBvxu3B7fjG(vobIJr2jPDXuuIS4MX6zlEikyX3V4b8l((EQlUOxCQxYIHjXI1fdF2Lallwmu3kOviHawCZa4Cl2CfzlwJf3fLelM)IhIcQh2IPiL2pyjYIHhOv43jQlQ7jEs9W6YuiWXvpZsefaDrdXiHM2NPGwHecZgzxcSSG4tMBYDxNDMFF7vmRX1dpq406jucHVNcnPqraviEIOG6HzzL2pyjIhOFokHWFNK2ftrjYIhqDOil2qOpGSyNopxpSf7YuamHa9IpWIJmzXHcGjXIlYIvJljwCClMvIFNOUOUN4j1dRltHahjtzNzR5dWSmrJmOlAiHcGjHpkoXgNLvIjmzJgU76SZ87jzk7mBnFaMLjAK5DzkaMqGKsJgu7URZoZVNKPSZS18bywMOrM3LPaycbc)MC31zN53tYu2z2A(amlt0iZdeoTEIjG5yEonnWZorDrDpXtQhwxMcboscaipta24SCk7fcb6IgIrcnTV9kg9b48KqD5OKF(PuZpVPgj00EJ(DSEcj8jZ8StMU40Uykkrwmfrb5wCZ9k2IVFXPjfzXjFxiKfRmgzXkqwC9UJREylU(fZppzXhyXDHq87e1f19epPEyDzke4ykiNT9kg0fneGwmR0kF4vgJ4RNs(53jPDXuuIS4MX6zgYZeWI1yX8B(fFGfZDazXKqD5iqV4dS4IEXrMS4qbWKyXMREFXSswC9lUleYIJm9xmFkq87e1f19epPEyDzke44QNziptaqx0qcTlF45QNziptaE5vJUWA0GAJeAAF7vm6dW5jH6YrjFOwJgrXj24SSsmbFkWZorDrDpXtQhwxMcbosMYoZwZhGzzIgzqx0qAwJeAAF7vm6dW5tMB0GA3DD2z(9KmLDMTMpaZYenY8UmfatiqsPjJeAAF7vm6dW5jH6Yzc(uGNDsAxmfLilEKPSZ8IttGsYw89lonPilo57cHS4itaYIvGSyLXilUE3Xvpm)orDrDpXtQhwxMcbosMYoZwhqjzqx0qaAXSsR8HxzmIVEkPqtaTywPv(WRmgXZsaAu3BIuYVts7I5v)CloYKfpYu2zEXqDoaR5S4M7vSf7YuamHSy6dSyDXgvS44wCasDX6ZwS2EfBXxRaC68C9Ww89lgQ)j6xrQ(DI6I6EINupSUmfcCC1ZSgDLeqx0qAvqPgDXZUGytMBIAQbAXSsR8HN7Afo5dF9u6usyJItMM3tHMaAXSsR8HN7Afo5dF9Mi980OrZgAx(WtYu2z2A(amB7vmV8QrxynAyKqt7BVIrFaop7m)nAyKqt7BVIrFaopjuxok5N(MOUEI(vKQjO48nA4YuamHyPbQlQ71oL89M0K80OHrcnTV9kg9b48KqD5mbe(PVjQRNOFfPAcOkFJgUmfatiwAG6I6ETtjFVjnjp8Stuxu3t8K6H1LPqGR9kMnoaq(a6Igc7cpjtzNzR5dWSZA9EGWP1tOm9nXUW3QCZfOC24sCzEGWP1tOm9nzKqt7BVIrFaoFY8orDrDpXtQhwxMcbosMYoZwZhGzN16HUOHaeAGqYuJU0uuCInolRektFtnBOD5dpxreqQE5vJUWAQzdTlF4zkiNT9kMxE1OlSDI6I6EINupSUmfcCTk3CbkNnUexg0fneGqdesMA0LMIItSXzzLqju1Ob1H2Lp8CfraP6Lxn6cRj2fEsMYoZwZhGzN169aHgiKm1Ol8Stuxu3t8K6H1LPqGJREMLURPcTltRhcFORpeaizoSfhNWknei8HU(qaGK5Ww0qIYLJqjKuAIA3DD2z(9TxXSgxp8jZnA4URZoZVNREM1ORKWNmZZorDrDpXtQhwxMcbosMYoZwZhGzN16rbkqia]] )


end
