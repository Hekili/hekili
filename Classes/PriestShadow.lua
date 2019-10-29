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
            if not hadShadowform then
                hadShadowform = buff.voidform.up or buff.shadowform.up
            end

            if hadShadowform then applyBuff( "shadowform" ) end
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
                t.unit = unit                
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

            handler = function ()
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

            handler = function ()
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


    spec:RegisterPack( "Shadow", 20191016, [[dKe9)aqirj1JeL4sIccBsuQrHeDkivRIc8kiYSGOULOq7sKFHegMOQJHuwMuKNHKQPjfvxdjLTPeLVbPuJtjQCoPOyDIc08GuCpiSpKkhuuqTqkOhkkjtujQ6IIcI2iKsknsiLuCsiLKvQeMjKsQ6MsrjTtKQgQOG0tvQPIKCviLyRsrP(QuuI9c1FP0GbDyslMIEmvnzuUmXMrLpdjJMkDAjVwuz2s1Trv7wv)wLHRKooKsQSCGNJy6cxNk2Uu67uOXlkGZlkA9krMVuy)kgtdtfEZ0qW03uEAndT80wwIgT8nr9LH3rMRcEVQ(CkkbVFLxW7TRYoJ49QMz)ugMk8MCoaVG3UrSsYGuqbQkCDmt(JNcsX701OU3duUGcsX7PaVnDQEGw9yt8MPHGPVP80AgA5PTSeT8uRzYVC4T6eUhaV3fFwH3UfJjp2eVzcXJ3zzGBxLDghygkOesmlYYaDJyLKbPGcuv46yM8hpfKI3PRrDVhOCbfKI3tXSildmd7GYHedKwEKhyt5P1mdmJdKw(myEAZIzrwgyw5QpkHKbNfzzGzCGzygtydCxD59sAwKLbMXbMv33kGqydmuakjSf3ajz(HMbsZISmWmoWS6(wbecBGHcqjrkkEXgNLvYaJBGrXl24SSsgOrxbiduxx7Lxn7scV7fjiyQWBs9O6cMkm90WuH3QpQ7X72Rywb4Sg194T8QzxyydXbM(MWuH3YRMDHHneV9GkeqP4TPdhxQ9kg3b4tSZ4J3QpQ7XBMcYzvIxEsDpoW0tDmv4T6J6E8U9kM186bElVA2fg2qCGPV5yQWB5vZUWWgI3QpQ7XBV27w1h192Erc8UxKW(kVG3Egbhy6PgMk8wE1SlmSH4ThuHakfVnD44sUkOviHWSH75GYnijN1bM9a931zNXp1EfZAE9ibeETEYaPdXaPLO2aZEG6scOcjrefupklR0(HYrsa9Znq6qmqA4T6J6E8MVEMLikahy6xgMk8wE1SlmSH4ThuHakfVdfGsIuu8InolRKbIMbs9b2OXa931zNXprCv2z0A8amlt0Wn5DvakHmqedSPb2OXaPCG(76SZ4NiUk7mAnEaMLjA4M8UkaLqgiIbsBGzpq)DD2z8texLDgTgpaZYenCtaHxRNmq0mquEwIxZadeD8w9rDpEtCv2z0A8amlt0Wfhy6rBmv4T8QzxyydXBpOcbukEB6WXLAVIXDa(ejuFUbs3aPLFGinqkhiT8d0GbA6WXLm73X6oKi5Soq0XB1h194nXbaKNjaBCwEL9cHGdm9lhMk8wE1SlmSH4ThuHakfVbAXSsR8rszmsQ(bs3aPLhVvFu3J3mfKZ2Efdhy6Bgmv4T8QzxyydXBpOcbukEhAx(iXxpZuEMasYRMDHnWgngiLd00HJl1EfJ7a8jsO(CdKUbsB5gyJgdmkEXgNLvYarZaPrTbIoER(OUhV5RNzkpta4atpT8yQWB5vZUWWgI3EqfcOu8oRhOPdhxQ9kg3b4toRdSrJbs5a931zNXprCv2z0A8amlt0Wn5DvakHmqedSPbM9anD44sTxX4oaFIeQp3arZaPrTbIoER(OUhVjUk7mAnEaMLjA4Idm90OHPcVLxn7cdBiE7bviGsXBGwmR0kFKugJKQFG0nqQnWShiqlMvALpskJrsmhGg19dendSP84T6J6E8M4QSZO1duIloW0tRjmv4T8QzxyydXBpOcbukE3QGsn7sIDbX6SoWShiLdKYbc0IzLw5Je)1k8YhP6hiDd0RKWgfVmqKgy(e1gy2deOfZkTYhj(Rv4Lps1pq0mWMpq0hyJgdmRhyOD5JeXvzNrRXdWSTxXsYRMDHnWgngOPdhxQ9kg3b4tSZ4pWgngOPdhxQ9kg3b4tKq95giDdKwZhy2dKYbwpr)kYCGOzGOD(b2OXa9UkaLqSCa1h19AFG0nqAjQt9bI(aB0yGMoCCP2RyChGprc1NBGObXaP18bM9aPCG1t0VImhiAg4YYpWgngO3vbOeILdO(OUx7dKUbslrDQpq0hi64T6J6E8MVEM1SRKahy6PrDmv4T8QzxyydXBpOcbukEZUirCv2z0A8am7QwFci8A9Kbs3aB(aZEGSlsTk)AbkVnohVBci8A9Kbs3aB(aZEGMoCCP2RyChGp5SI3QpQ7X72Ry24aa5dCGPNwZXuH3YRMDHHneV9GkeqP4nq4acXvn7YaZEGrXl24SSsgiDdS5dm7bM1dm0U8rIViciZK8Qzxydm7bM1dm0U8rIPGC22Ryj5vZUWWB1h194nXvzNrRXdWSRA94atpnQHPcVLxn7cdBiE7bviGsXBGWbeIRA2LbM9aJIxSXzzLmq6g4YgyJgdKYbgAx(iXxebKzsE1SlSbM9azxKiUk7mAnEaMDvRpbeoGqCvZUmq0XB1h194DRYVwGYBJZX7Idm90wgMk8wE1SlmSH4T6J6E8MVEMLRRzI31hca4Sg2IdVJYNJqhIMYMs)DD2z8tTxXSMxpsoRnA4VRZoJFIVEM1SRKi5SIoExFiaGZAylEEHvAi4nn827Q1J30WbMEAOnMk8w9rDpEtCv2z0A8am7QwpElVA2fg2qCGd8MjCQtpWuHPNgMk8w9rDpEtQU8EbVLxn7cdBioW03eMk8w9rDpE7qeBfcpbVLxn7cdBioW0tDmv4T8QzxyydXBpOcbukEB6WXLm73X6oKibe1hdSrJbgfVyJZYkzGObXaxU8dSrJbgkaLejxr7HBA1hdendK6udVvFu3J3Rxu3Jdm9nhtfElVA2fg2q8(wXBIe4T6J6E8UvbLA2f8Uv7ocEZUirCv2z0A8am7QwFkkFU6rnWShi7IuRYVwGYBJZX7MIYNREu4DRcSVYl4n7cI1zfhy6PgMk8wE1SlmSH4T6J6E8g48w1h192Erc82dQqaLI3QpQwXkVWxczG0nqA4DViH9vEbV9DrBfCGPFzyQWB5vZUWWgI3QpQ7XBGZBvFu3B7fjWBpOcbukER(OAfR8cFjKbIyG0W7Erc7R8cEtQhvxWboW7vG4pEtnWuHPNgMk8w9rDpEVErDpElVA2fg2qCGPVjmv4T8QzxyydX7BfVjsG3QpQ7X7wfuQzxW7wT7i4nx)oWaPCGuoWMNO2arAG6scOcjz0TiRcGypoB4kwMY)clb0p3arFGzigiLdK2arAG5tnH2d0GbQljGkKeruq9OSSs7hkhjb0p3arFGOJ3TkW(kVG381ZSMDLe2qbOKGGdm9uhtfElVA2fg2q8(wXBIe4T6J6E8UvbLA2f8Uv7ocEt5aPnWmoW8P8O9anyG6scOcjXenCTHl4escOFUbI0aZNAAGgmqDjbuHKc3ZbLByDvqRqcbKa6NBGOpqdgiLdK2aZ4aZNY3md0GbQljGkKu4EoOCdRRcAfsiGeq)Cd0GbQljGkKeruq9OSSs7hkhjb0p3arhVBvG9vEbVjgxTbqRWc0phX6DfFoCGPV5yQWB5vZUWWgI33kEtKaVvFu3J3TkOuZUG3TA3rWBkhiTbMXbMpLV5d0GbQljGkKu4EoOCdRRcAfsiGeq)CdmJdmFkp1gObduxsavijYAfcNt3QRRkOI6EscOFUbIoE3Qa7R8cE3g2aOvyb6NJy9UIphoW0tnmv4T8QzxyydX7BfVjsG3QpQ7X7wfuQzxW7wT7i4nLdK2aZ4aZNYJ2d0GbQljGkKet0W1gUGtijG(5gyghy(uEQpqdgOUKaQqsH75GYnSUkOviHasa9ZnWmoW8P8uJAd0GbQljGkKezTcHZPB11vfurDpjb0p3arFGgmqkhiTbMXbMpLVj0EGgmqDjbuHKc3ZbLByDvqRqcbKa6NBGgmqDjbuHKiIcQhLLvA)q5ijG(5gi64DRcSVYl4DBy5lInaAfwG(5iwVR4ZHdm9ldtfElVA2fg2q8(wXBIe4T6J6E8UvbLA2f8Uv7ocEtBGzCG5t5P18bAWa1LeqfsIikOEuwwP9dLJKa6NdVBvG9vEbVBdlFrSeM17k(C4atpAJPcVLxn7cdBiE7bviGsX7SEGMoCCjIRYoJChGp5SI3QpQ7XBIRYoJChGhhy6xomv4T8QzxyydX7x5f8wxI4QaLy5UpShND9mka8w9rDpERlrCvGsSC3h2JZUEgfaoW03myQWB5vZUWWgI3EqfcOu8MSk9Unuakjij(6zwIOGbIMb20aB0yG6scOcjfUNdk3W6QGwHecib0p3armW84T6J6E8MVEM1SRKahy6PLhtfER(OUhVBv(1cuEBCoEx8wE1SlmSH4ah4TNrWuHPNgMk8wE1SlmSH4ThuHakfVPCGMoCCP2RyChGprc1NBG0nWMYpWShy9e9RiZbIgedKA5hi6dSrJbA6WXLAVIXDa(ejuFUbs3aPCGnTSbI0ar7bAWanD44sM97yDhsKCwhi6dSrJbs5a9oaG8HTEI(vKPLb06hObdKYbs5ar5zjEndmqdgytde9bI0avFu3N4RNzn7kjsELe2O4LbI(arFG0nW6j6xrM4T6J6E8Mx4pqM2JZ2D8fZYaIYtWbM(MWuH3QpQ7XBZ(Dm7XzdxXkVWNjElVA2fg2qCGPN6yQWB1h194nkhfWk9ThNvxsax4I3YRMDHHnehy6BoMk8wE1SlmSH4ThuHakfVjRsVBdfGscsIVEMLikyG0HyGnnWgngiqlMvALpskJrs1pq6g4YYJ3QpQ7XBUZ7qeMvxsaviwtr5XbMEQHPcVLxn7cdBiE7bviGsXBYQ072qbOKGK4RNzjIcgiDigytdSrJbc0IzLw5JKYyKu9dKUbUS84T6J6E8E1buCzwpkRzxjboW0Vmmv4T6J6E8oCfRZBEopZYDaVG3YRMDHHnehy6rBmv4T8QzxyydXBpOcbukEhfVmq0GyG0YpWgngiLd00HJl5DpGdXEC26j6xrMjsO(CdKoedKg1gy2d00HJl1EfJ7a8jN1bI(aB0yGCo9UfiExfGsSrXldendeLNnWgngyu8InolRKbIMbsn8w9rDpE7V3lFa0qywUUYl4DVEX6z49YWbM(LdtfER(OUhVb16AxS1BjRQxWB5vZUWWgIdm9ndMk8wE1SlmSH4ThuHakfVnD44s9Itm73XsKq95giAgi1XB1h194TXd0zTs9wGqUxFVGdm90YJPcVLxn7cdBiER(OUhV9AVBvFu3B7fjWBpOcbukEt5anD44sTxX4oaFYzDGzpqthoUK39aoe7XzRNOFfzMiH6Znq6gyt5hi6dSrJbQljGkKK39aoe7XzRNOFfzMa6NBGigyE8UxKW(kVG3EqfwpJGdm90OHPcVvFu3J3oeXwHWtWB5vZUWWgIdCG3(UOTcMkm90WuH3QpQ7X72Rywb4Sg194T8QzxyydXbM(MWuH3YRMDHHneV9GkeqP4TPdhxQ9kg3b4tSZ4J3QpQ7XBMcYzvIxEsDpoW0tDmv4T8QzxyydXBpOcbukEN1dmkFU6rnWShOUKaQqsH75GYnSUkOviHasa9Znq6qmqA4T6J6E8Uv5xlq5TX54DXbM(MJPcVLxn7cdBiE7bviGsXBthoUKRcAfsimB4EoOCdsYzfVvFu3J381ZSerb4atp1WuH3QpQ7X72RywZRh4T8QzxyydXbM(LHPcVLxn7cdBiER(OUhV9AVBvFu3B7fjW7Erc7R8cE7zeCGPhTXuH3YRMDHHneV9GkeqP4Du8InolRKbIMbs9b2OXanD44sTxX4oaFIDgF8w9rDpEtCv2z0A8amlt0WfV9z67Inuakjiy6PHdm9lhMk8wE1SlmSH4ThuHakfVnD44sTxX4oaFIeQp3aPBG0YpqKgiLdKw(bAWanD44sM97yDhsKCwhi64T6J6E8M4aaYZeGnolVYEHqWbM(MbtfElVA2fg2q82dQqaLI3aTywPv(iPmgjv)aPBG0YpWShiLdKDrI4QSZO14by2vT(eq4acXvn7YaB0yGrXl24SSsgiDdK65hi64T6J6E8MPGC22Ry4atpT8yQWB1h194nF9mt5zcaVLxn7cdBioW0tJgMk8wE1SlmSH4ThuHakfVjRsVBdfGscsIVEMLikyGOzGTkOuZUK4RNzn7kjSHcqjbbVvFu3J381ZSMDLe4TptFxSHcqjbbtpnCGPNwtyQWB5vZUWWgI3EqfcOu8MYbc0IzLw5JKYyKu9dKUbsTbM9abAXSsR8rszmsI5a0OUFGOzGnnq0hyJgdeOfZkTYhjLXijMdqJ6(bs3aBcVvFu3J3exLDgTEGsCXbMEAuhtfElVA2fg2q82dQqaLI3z9adTlFK4lIaYmjVA2f2aZEGaHdiex1Sldm7bgfVyJZYkzG0nqkhiLdmJdKwQPbI0aPEI6d0GbswLE3gkaLeKeF9mlruWarFGgmWwfuQzxseJR2aOvyb6NJy9UIp3anyGuoqAdmJdmFkpTMgObduxsavijIOG6rzzL2puoscOFUbAWajRsVBdfGscsIVEMLikyGOpq0XB1h194nXvzNrRXdWSRA94TptFxSHcqjbbtpnCGPNwZXuH3YRMDHHneV9GkeqP4nq4acXvn7YaZEGrXl24SSsgiDdKYbs5aPnqKgi1tuFGgmqYQ072qbOKGK4RNzjIcgi6d0Gb2QGsn7sQnSbqRWc0phX6DfFUbAWaPCG0gisdmFIw(bAWa1LeqfsIikOEuwwP9dLJKa6NBGgmqYQ072qbOKGK4RNzjIcgi6deD8w9rDpE3Q8RfO824C8U4TptFxSHcqjbbtpnCGPNg1WuH3YRMDHHneV9GkeqP4n7IeXvzNrRXdWSRA9jGWbeIRA2LbM9aPCGH2Lps8frazMKxn7cBGzpWO4fBCwwjdKUbs5aPCG0s5hisdSPu(bAWajRsVBdfGscsIVEMLikyGOpqdgyRck1SlP2WYxeBa0kSa9ZrSExXNBGgmqkhyRck1SlP2WYxelHz9UIp3anyGKvP3THcqjbjXxpZsefmq0hi6deD8w9rDpE3Q8RfO824C8U4TptFxSHcqjbbtpnCGPN2YWuH3YRMDHHneV9GkeqP4TPdhxQ9kg3b4toR4T6J6E8U9kMnoaq(ahy6PH2yQWB5vZUWWgI3QpQ7XB(6zwIOa8U(qaaN1WwC4Du(Ce6q0eExFiaGZAylEEHvAi4nn827Q1J30WBpOcbukEtwLE3gkaLeKeF9mlruWaPBG0WbMEAlhMk8wE1SlmSH4T6J6E8MVEMLRRzI31hca4Sg2IdVJYNJqhIMYMs)DD2z8tTxXSMxpsoRnA4VRZoJFIVEM1SRKi5SIoExFiaGZAylEEHvAi4nn827Q1J30WbMEAndMk8w9rDpEtCv2z0A8am7QwpElVA2fg2qCGd82dQW6zemvy6PHPcVLxn7cdBiE)kVG36sexfOel39H94SRNrbG3QpQ7XBDjIRcuIL7(WEC21ZOaWbM(MWuH3YRMDHHneVvFu3J3(m99la3xERzxjbElCCIpSVYl4TptF)cW9L3A2vsGdCGd8UvaK6Em9nLNwZKhTBA5WBJk4RhfbVrR4xpqiSbUSbQ(OUFG9IeK0SaVjRIhtFtuB5W7vWXvDbVZYa3Uk7moWmuqjKywKLb6gXkjdsbfOQW1Xm5pEkifVtxJ6Epq5ckifVNIzrwgyg2bLdjgiT8ipWMYtRzgyghiT8zW80MfZISmWSYvFucjdolYYaZ4aZWmMWg4U6Y7L0SildmJdmRUVvaHWgyOausylUbsY8dndKMfzzGzCGz19Tcie2adfGsIuu8InolRKbg3aJIxSXzzLmqJUcqgOUU2lVA2L0SywKLbMHmdiENqyd0u4oGmq)XBQXanfu1tsdmd79YAqg4FFgDvapNtFGQpQ7jd8(EMPzrwgO6J6EsAfi(J3udeCDLKBwKLbQ(OUNKwbI)4n1ajeuWDhBwKLbQ(OUNKwbI)4n1ajeuOoO4Lp0OUFwKLbUFDL4EXabAXgOPdhNWgij0GmqtH7aYa9hVPgd0uqvpzG6Zg4kqY46fr9Ogyrgi7EjnlYYavFu3tsRaXF8MAGeckiVUsCVWscniZc1h19K0kq8hVPgiHGI1lQ7NfQpQ7jPvG4pEtnqcbfTkOuZUG8R8cc(6zwZUscBOausqq(wrqKa5wT7ii463bOKYMNOgs6scOcjz0TiRcGypoB4kwMY)clb0ph6ziOKgs5tnH2gOljGkKeruq9OSSs7hkhjb0ph6OpluFu3tsRaXF8MAGeckAvqPMDb5x5feeJR2aOvyb6NJy9UIphY3kcIei3QDhbbL0Yy(uE02aDjbuHKyIgU2WfCcjb0phs5tnzGUKaQqsH75GYnSUkOviHasa9ZHUbuslJ5t5Bgd0LeqfskCphuUH1vbTcjeqcOFod0LeqfsIikOEuwwP9dLJKa6Nd9zH6J6EsAfi(J3udKqqrRck1Sli)kVGOnSbqRWc0phX6DfFoKVveejqUv7occkPLX8P8n3aDjbuHKc3ZbLByDvqRqcbKa6NlJ5t5PMb6scOcjrwRq4C6wDDvbvu3tsa9ZH(Sq9rDpjTce)XBQbsiOOvbLA2fKFLxq0gw(IydGwHfOFoI17k(CiFRiisGCR2DeeuslJ5t5rBd0LeqfsIjA4AdxWjKeq)CzmFkp1nqxsaviPW9Cq5gwxf0kKqajG(5Yy(uEQrnd0LeqfsISwHW50T66QcQOUNKa6NdDdOKwgZNY3eABGUKaQqsH75GYnSUkOviHasa9ZzGUKaQqserb1JYYkTFOCKeq)COpluFu3tsRaXF8MAGeckAvqPMDb5x5feTHLViwcZ6DfFoKVveejqUv7occAzmFkpTMBGUKaQqserb1JYYkTFOCKeq)CZc1h19K0kq8hVPgiHGcIRYoJChGh5IdrwB6WXLiUk7mYDa(KZ6Sq9rDpjTce)XBQbsiOWHi2keEKFLxqOlrCvGsSC3h2JZUEgfWSq9rDpjTce)XBQbsiOGVEM1SRKa5Idbzv6DBOausqs81ZSerbOPPgn0LeqfskCphuUH1vbTcjeqcOFoe5NfQpQ7jPvG4pEtnqcbfTk)AbkVnohV7SywKLbMHmdiENqyduAfqMdmkEzGHRmq1hhyGfzGARwD1SlPzH6J6Eccs1L3lZc1h19eKqqHdrSvi8KzH6J6EcsiOy9I6EKloeMoCCjZ(DSUdjsar9rJgrXl24SSsqdILlFJgHcqjrYv0E4Mw9bAOo1MfQpQ7jiHGIwfuQzxq(vEbb7cI1zf5BfbrcKB1UJGGDrI4QSZO14by2vT(uu(C1JkB2fPwLFTaL3gNJ3nfLpx9OMfQpQ7jiHGcGZBvFu3B7fjq(vEbHVlARGCXHq9r1kw5f(si0rBwO(OUNGeckaoVv9rDVTxKa5x5feK6r1fKloeQpQwXkVWxcbbTzXSaPbMLbIwiYaBwf(dK5apUbIwVJVydC5bIYtgiOq5gd0u4oGmWmpNbQazGQ55edmUbYP9(apNyGh3aB2xX4oa)Sq9rDpj5zee8c)bY0EC2UJVywgquEcYfhcknD44sTxX4oaFIeQphDnLp76j6xrMObb1YJEJgMoCCP2RyChGprc1NJokBAziH2gy6WXLm73X6oKi5SIEJgu6Daa5dB9e9RitldO1BaLuIYZs8AgWGMqhj1h19j(6zwZUsIKxjHnkEbD0PREI(vK5Sq9rDpj5zeKqqHz)oM94SHRyLx4ZCwO(OUNK8mcsiOaLJcyL(2JZQljGlCNfQpQ7jjpJGeck4oVdrywDjbuHynfLh5Idbzv6DBOausqs81ZSerb0HOPgnaAXSsR8rszmsQE6ww(zH6J6EsYZiiHGIvhqXLz9OSMDLeixCiiRsVBdfGscsIVEMLikGoen1ObqlMvALpskJrs1t3YYpluFu3tsEgbjeueUI15npNNz5oGxMfzzGnlAfduJb2fLedCzKbAkHrr(b6vsupQbMvO1MgiAHidmCLbYvasmqVsIbMH3z4m0bg3arjXaRyG3pWSA5rEGHR8duAfqMdK4yse06CKpgOxjXajUNtNnqtzGoeHnqJUYpWSY9aoKbECdeT6j6xrMdSidu9r1kd8adSIbAS69bceVRcqjdS(bgUYaFjdedeLNH8apWadxzGHcqjXalYavZZjgyCdKvsAwO(OUNK8mcsiOWFVx(aOHWSCDLxqUxVy9meld5Idru8cAqqlFJguA6WXL8UhWHypoB9e9RiZejuFo6qqJAzB6WXLAVIXDa(KZk6nAW507wG4DvakXgfVGguEwJgrXl24SSsqd1MfQpQ7jjpJGecka16AxS1BjRQxMfQpQ7jjpJGeckmEGoRvQ3ceY967fKloeMoCCPEXjM97yjsO(COH6ZISmq0crgy4kezG(76SZ4tgy9d0ucJI8dmZZbmqAKyG6ZgytpBGn7Ryd0WRhdS(bM55agytpBGn7RyChGFGgDLFGzEod0vBLbMvUhWHmWJBGOvpr)kYCGQpQwzwO(OUNK8mcsiOWR9Uv9rDVTxKa5x5feEqfwpJGCXHGsthoUu7vmUdWNCwZ20HJl5DpGdXEC26j6xrMjsO(C01uE0B0qxsavijV7bCi2JZwpr)kYmb0phI8ZISmWLx4uNEmqoT3nvFUbYDGb6quZUmWkeEsgCGOfImW7hO)Uo7m(PzH6J6EsYZiiHGchIyRq4jZIzH6J6EsY3fTvq0EfZkaN1OUFwO(OUNK8DrBfKqqbtb5SkXlpPUh5IdHPdhxQ9kg3b4tSZ4pluFu3ts(UOTcsiOOv5xlq5TX54DrU4qK1r5ZvpQS1LeqfskCphuUH1vbTcjeqcOFo6qqBwO(OUNK8DrBfKqqbF9mlruaYfhcthoUKRcAfsimB4EoOCdsYzDwO(OUNK8DrBfKqqr7vmR51JzH6J6EsY3fTvqcbfET3TQpQ7T9Iei)kVGWZiZc1h19KKVlARGeckiUk7mAnEaMLjA4ISptFxSHcqjbbbnKloerXl24SSsqd1B0W0HJl1EfJ7a8j2z8NfQpQ7jjFx0wbjeuqCaa5zcWgNLxzVqiixCimD44sTxX4oaFIeQphD0YJeL0YBGPdhxYSFhR7qIKZk6ZISmq0crg4YRGCdSzFfBG3pWSA5hOZ3fczGkJrgOcKbwV)4Rh1aRFG0Ytg4bgyxiK0Sq9rDpj57I2kiHGcMcYzBVIHCXHaOfZkTYhjLXiP6PJw(SPKDrI4QSZO14by2vT(eq4acXvn7sJgrXl24SSsOJ65rFwO(OUNK8DrBfKqqbF9mt5zcywO(OUNK8DrBfKqqbF9mRzxjbY(m9DXgkaLeee0qU4qqwLE3gkaLeKeF9mlruaAAvqPMDjXxpZA2vsydfGscYSq9rDpj57I2kiHGcIRYoJwpqjUixCiOeOfZkTYhjLXiP6PJAzd0IzLw5JKYyKeZbOrDpAAc9gnaAXSsR8rszmsI5a0OUNUMMfQpQ7jjFx0wbjeuqCv2z0A8am7QwpY(m9DXgkaLeee0qU4qK1H2Lps8frazMKxn7clBGWbeIRA2LSJIxSXzzLqhLuMrAPMqI6jQBazv6DBOausqs81ZSerbOBqRck1SljIXvBa0kSa9ZrSExXNZakPLX8P80AYaDjbuHKiIcQhLLvA)q5ijG(5mGSk9Unuakjij(6zwIOa0rFwO(OUNK8DrBfKqqrRYVwGYBJZX7ISptFxSHcqjbbbnKloeaHdiex1SlzhfVyJZYkHokPKgsuprDdiRsVBdfGscsIVEMLikaDdAvqPMDj1g2aOvyb6NJy9UIpNbusdP8jA5nqxsavijIOG6rzzL2puoscOFodiRsVBdfGscsIVEMLikaD0NfQpQ7jjFx0wbjeu0Q8RfO824C8Ui7Z03fBOausqqqd5Idb7IeXvzNrRXdWSRA9jGWbeIRA2LSPm0U8rIViciZK8QzxyzhfVyJZYkHokPKwkpsnLYBazv6DBOausqs81ZSerbOBqRck1SlP2WYxeBa0kSa9ZrSExXNZakBvqPMDj1gw(IyjmR3v85mGSk9Unuakjij(6zwIOa0rh9zH6J6EsY3fTvqcbfTxXSXbaYhixCimD44sTxX4oaFYzDwO(OUNK8DrBfKqqbF9mlruaYfhcYQ072qbOKGK4RNzjIcOJgYExTEe0qU(qaaN1Ww88cR0qqqd56dbaCwdBXHikFocDiAAwO(OUNK8DrBfKqqbF9mlxxZezVRwpcAixFiaGZAylEEHvAiiOHC9HaaoRHT4qeLphHoenLnL(76SZ4NAVIznVEKCwB0WFxNDg)eF9mRzxjrYzf9zH6J6EsY3fTvqcbfexLDgTgpaZUQ1plMfQpQ7jjpOcRNrq4qeBfcpYVYli0LiUkqjwU7d7XzxpJcywO(OUNK8GkSEgbjeu4qeBfcpYchN4d7R8ccFM((fG7lV1SRKywmluFu3tsK6r1feTxXScWznQ7NfQpQ7jjs9O6csiOGPGCwL4LNu3JCXHW0HJl1EfJ7a8j2z8NfQpQ7jjs9O6csiOO9kM186XSq9rDpjrQhvxqcbfET3TQpQ7T9Iei)kVGWZiZISmq0crgyZA9SbUffmW7h4MQbEFpZbwCdmZZzGOKyG6aPY9Cq5gdeTgf0kKqadmdfC(bASc3bQXa7IsIbsBGBrb1JAGlFP9dLJmqQaAfPzH6J6EsIupQUGeck4RNzjIcqU4qy6WXLCvqRqcHzd3ZbLBqsoRz7VRZoJFQ9kM186rci8A9e6qqlrTS1LeqfsIikOEuwwP9dLJKa6NJoe0MfzzGOfImWDZYYpqtH7aYa966A9OgO3vbOecYd8admCLbgkaLedSidunpNyGXnqwjPzH6J6EsIupQUGeckiUk7mAnEaMLjA4ICXHiuakjsrXl24SSsqd1B0WFxNDg)eXvzNrRXdWSmrd3K3vbOecIMA0Gs)DD2z8texLDgTgpaZYenCtExfGsiiOLT)Uo7m(jIRYoJwJhGzzIgUjGWR1tqdkplXRza0NfQpQ7jjs9O6csiOG4aaYZeGnolVYEHqqU4qy6WXLAVIXDa(ejuFo6OLhjkPL3athoUKz)ow3HejNv0NfinWSmq0crg4YRGCdSzFfBG3pWSA5hOZ3fczGkJrgOcKbwV)4Rh1aRFG0Ytg4bgyxiK0Sq9rDpjrQhvxqcbfmfKZ2Efd5IdbqlMvALpskJrs1thT8ZISmq0crgyZA9mt5zcyGAmqAnZapWa5pGmqsO(CeKh4bgyXnWWvgyOausmqJvVpqwjdS(b2fczGHR(dKg1iPzH6J6EsIupQUGeck4RNzkptaixCicTlFK4RNzkptaj5vZUWA0GsthoUu7vmUdWNiH6ZrhTLRrJO4fBCwwjOHg1qFwO(OUNKi1JQliHGcIRYoJwJhGzzIgUixCiYAthoUu7vmUdWNCwB0Gs)DD2z8texLDgTgpaZYenCtExfGsiiAkBthoUu7vmUdWNiH6ZHgAud9zrwgiAHidC7QSZ4aZkGsCh49dmRw(b68DHqgy4kazGkqgOYyKbwV)4RhvAwO(OUNKi1JQliHGcIRYoJwpqjUixCiaAXSsR8rszmsQE6Ow2aTywPv(iPmgjXCaAu3JMMYplYYanu)CdmCLbUDv2zCGnlhGLbhyZ(k2a9UkaLqgi3bgOoqZkgyCdmazoq9zduBVInWRvaEDDTEud8(bIw9e9RiZ0Sq9rDpjrQhvxqcbf81ZSMDLeixCiAvqPMDjXUGyDwZMskbAXSsR8rI)AfE5Ju905vsyJIxqkFIAzd0IzLw5Je)1k8YhP6rtZrVrJSo0U8rI4QSZO14by22Ryj5vZUWA0W0HJl1EfJ7a8j2z8B0W0HJl1EfJ7a8jsO(C0rR5ztz9e9Rit0G25B0W7QaucXYbuFu3RD6OLOo1rVrdthoUu7vmUdWNiH6ZHge0AE2uwpr)kYenllFJgExfGsiwoG6J6ETthTe1Po6OpluFu3tsK6r1fKqqr7vmBCaG8bYfhc2fjIRYoJwJhGzx16taHxRNqxZZMDrQv5xlq5TX54DtaHxRNqxZZ20HJl1EfJ7a8jN1zH6J6EsIupQUGeckiUk7mAnEaMDvRh5Idbq4acXvn7s2rXl24SSsOR5zN1H2Lps8frazMKxn7cl7So0U8rIPGC22Ryj5vZUWMfQpQ7jjs9O6csiOOv5xlq5TX54DrU4qaeoGqCvZUKDu8InolRe6wwJgugAx(iXxebKzsE1SlSSzxKiUk7mAnEaMDvRpbeoGqCvZUG(Sq9rDpjrQhvxqcbf81ZSCDntK9UA9iOHC9HaaoRHT45fwPHGGgY1hca4Sg2Idru(Ce6q0u2u6VRZoJFQ9kM186rYzTrd)DD2z8t81ZSMDLejNv0NfQpQ7jjs9O6csiOG4QSZO14by2vTECGdmga]] )


end
