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

        harvested_thoughts = {
            id = 273321,
            duration = 15,
            max_stack = 1,
        },

        searing_dialogue = {
            id = 288371,
            duration = 1,
            max_stack = 1
        },

        thought_harvester = {
            id = 288343,
            duration = 20,
            max_stack = 1
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
                if azerite.thought_harvester.enabled then applyBuff( "harvested_thoughts" ) end
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

        potion = "potion_of_rising_death",

        package = "Shadow",
    } )


    spec:RegisterPack( "Shadow", 20190710.0850, [[deew)aqiPu4rKsXLivvOnrkzuGsNcuzviPELuvZcs1TivLDrLFbsnmH4yKILbP8mqsttkLUMuQ2Muk6BGeghPu6CGezDKQQAEKs19aX(qIoiPQsTqKKhsQQYfjvvWjjvvuRuQYobfdLuvrEQIMkOQ9QQ)sYGPQdtzXe1Jfmzcxg1MH4ZqYOfQtl51KkZwHBtKDRYVvA4sLJtQQKLd8Cetx01rQTlfFxinEqI68iH1tQY8Ls2pu)AE4)PWs(HbTiAGsrGcnrCr022HcOQT)mPOJ)zNf0zO4FEMe)ZzSj2O)SZOySM4H)NKLge4FgNzhr)dn0OQmMw2fwjOjLe9WYAVaWqsOjLua6FktxJu)89Y)uyj)WGwenqPiqHMiUiAB7qbuB7pn6mEb)Cws6VFgxcbFV8pfmj8tTb7NXMyJI96NaftsCpTb7JZSJO)HgAuvgtl7cRe0KsIEyzTxayij0KskanUN2G99OhuG9AIGo2JwenqjSxFyFeTv)3EeCpCpTb71FX2HIj6FCpTb71h2RFleSa7N1GVa7W90gSxFyV(BVggKSa7tdGItvHG9ekU0GYoCpTb71h2R)2RHbjlW(0aO40LLeRYvjkg7Zf7ZsIv5QefJ9rJzaJ9wx3OcM8GD)CuKK8W)tsDOg8d)dJMh(FAHS27NnBjumGUlR9(jFM8GfpvF(WG2d)p5ZKhS4P6NbqLmOSFktJG4A2sGSajNyJE)0czT3pfgqNYib(i1EF(Wa1h(FAHS27NnBjuY7i)jFM8GfpvF(W02h(FYNjpyXt1pTqw79ttpsSbmIczVuTiQUnkd(zaujdk7NWI9Y0iiUMTeilqYr3H9AH9Y0iiUq8cOjQfrvhXUkPWrslOd7Pe7rlc2dh23Qf2B6XGkzxiEb0e1IOQJyxLu4a2Pd7HG9r(5zs8pn9iXgWikK9s1IO62Om4ZhM2F4)jFM8Gfpv)maQKbL9tyXEzAeexZwcKfi5iPf0H9uI9Ofb71c7RJyxLuG9Ahc23EeShoSVvlSxMgbX1SLazbsosAbDypLypSypATJ99X(2XEQXEzAeeN8yxXGMKo6oShoSVvlShwSpqda8LQ6i2vjfkbWQd7Pg7rfeojdkJ9uJ9qf7Hd7Pe7RJyxLu8tlK1E)uILwafQfrnOdLqjaSjr(8HPnF4)PfYAVFkp2vOwevgZk(yjk(jFM8GfpvF(Wafp8)0czT3prrBarzNAruMEmyZ4FYNjpyXt1NpmA7d)pTqw79tKnqtyHY0JbvYkz2K(jFM8GfpvF(WaLE4)PfYAVF2rdkekQdLsEyK8N8zYdw8u95dJMip8)0czT3pZywrFYl9juiliW)KptEWINQpFy0O5H)NwiR9(zyVaFjWswOqgMe)t(m5blEQ(8HrdAp8)0czT3pbvx3Gv1PiDwG)jFM8GfpvF(WObQp8)0czT3pJUGHOHRtbyYE2f4FYNjpyXt1NpmAA7d)p5ZKhS4P6NwiR9(z3g0XjP0JfQWk1rNww7PeCtf4FgavYGY(jRFrxDDSW1TbDCsk9yHkSsD0PL1Ekb3ubg71c7Hf7LPrqCnBjqwGKJUd71c7LPrqCH4fqtulIQoIDvsHJKwqh2tj2JweShoSVvlS30JbvYUq8cOjQfrvhXUkPWbSth2db7J8ZZK4F2TbDCsk9yHkSsD0PL1Ekb3ub(ZhgnT)W)t(m5blEQ(zaujdk7NY0iiUyd0WKKfQmEPrfNehDh2Rf2h2Di2ONRzlHsEhPdWswDeSNsiyVgx7yVwyVPhdQKDe2a1HsjkBSOOzhWoDypLqWEn)0czT3pLQtOiSb(8HrtB(W)t(m5blEQ(zaujdk7NzjXQCvIIXETJ9qf7B1c7d7oeB0ZrInXgvfDbcLGTm2fInakMG9qWE0W(wTWEyX(WUdXg9CKytSrvrxGqjylJDHydGIjypeSxd2Rf2h2Di2ONJeBInQk6cekbBzSdWswDeSx7ypQGWjzqzShUFAHS27NKytSrvrxGqjylJ)8Hrdu8W)t(m5blEQ(zaujdk7NY0iiUMTeilqYrslOd7Pe71eb77J9WI9AIG9uJ9Y0iio5XUIbnjD0DypC)0czT3pj0aaFcgOYvjzIJjKpFy0OTp8)KptEWINQFgavYGY(jWkHIB4lDMqqC1H9uI9AI8tlK1E)uyaDQMTeF(WObk9W)t(m5blEQ(zaujdk7NPn4lDs1jK5tWahFM8GfyFRwypSyVmncIRzlbYcKCK0c6WEkXEnAl23Qf2NLeRYvjkg71o2RPDShUFAHS27Ns1jK5tWGpFyqlYd)p5ZKhS4P6NbqLmOSF2gyVmncIRzlbYcKC0DyFRwypSyFy3HyJEosSj2OQOlqOeSLXUqSbqXeShc2Jg2Rf2ltJG4A2sGSajhjTGoSx7yVM2XE4(PfYAVFsInXgvfDbcLGTm(Zhg008W)t(m5blEQ(zaujdk7NaRekUHV0zcbXvh2tj23o2Rf2dSsO4g(sNjeeNGgyzTh2RDShTi)0czT3pjXMyJQcaJe)5ddAO9W)t(m5blEQ(zaujdk7NngOm5b7eBsu0DyVwypSypSypWkHIB4lDsBdlXx6Qd7Pe7dgjvzjXyFFSpIRDSxlShyLqXn8LoPTHL4lD1H9Ah7Bl2dh23Qf23gyFAd(shj2eBuv0fiunBjC8zYdwG9TAH9Y0iiUMTeilqYj2Oh23Qf2ltJG4A2sGSajhjTGoSNsSxtBXETWEyX(6i2vjfyV2XEOic23Qf2hInakMOqawiR9Sb2tj2RXbvOI9WH9TAH9Y0iiUMTeilqYrslOd71oeSxtBXETWEyX(6i2vjfyV2X(2mc23Qf2hInakMOqawiR9Sb2tj2RXbvOI9WH9W9tlK1E)uQoHsEyK8Zhg0G6d)p5ZKhS4P6NbqLmOSFk20rInXgvfDbcvNvNdWswDeSNsSVTyVwyVytxJj1vGkOYLoe7aSKvhb7Pe7Bl2Rf2ltJG4A2sGSajhD3pTqw79ZMTeQCba(YpFyqRTp8)KptEWINQFgavYGY(jGramj2Khm2Rf2NLeRYvjkg7Pe7Bl2Rf23gyFAd(sNuryafo(m5blWETW(2a7tBWx6egqNQzlHJptEWIFAHS27NKytSrvrxGq1z195ddAT)W)t(m5blEQ(zaujdk7NagbWKytEWyVwyFwsSkxLOySNsSVnX(wTWEyX(0g8LoPIWakC8zYdwG9AH9InDKytSrvrxGq1z15amcGjXM8GXE4(PfYAVF2ysDfOcQCPdXF(WGwB(W)t(m5blEQ(PfYAVFkvNqHmmk(zDjda0DPQq(zwbDekHGMwWg2Di2ONRzlHsEhPJURvRWUdXg9Cs1juYdJKo6o4(zDjda0DPQKKyrzj)tn)meB19tnF(WGgu8W)tlK1E)KeBInQk6ceQoRUFYNjpyXt1NF(ZWGTg(H)HrZd)pTqw79ZMTekgq3L1E)KptEWINQpFyq7H)N8zYdw8u9ZaOsgu2pLPrqCnBjqwGKtSrVFAHS27NcdOtzKaFKAVpFyG6d)p5ZKhS4P6NbqLmOSF2gyFwbD1Hc71c7n9yqLSlJxAuXPk2anmjzGdyNoSNsiyVMFAHS27NnMuxbQGkx6q8NpmT9H)N8zYdw8u9ZaOsgu2pLPrqCXgOHjjluz8sJkojo6UFAHS27Ns1jue2aF(W0(d)pTqw79ZMTek5DK)KptEWINQpFyAZh(FYNjpyXt1pTqw79ttpsSbmIczVuTiQUnkd(zaujdk7NWI9Y0iiUMTeilqYr3H9AH9Y0iiUq8cOjQfrvhXUkPWrslOd7Pe7rlc2dh23Qf2B6XGkzxiEb0e1IOQJyxLu4a2Pd7HG9r(5zs8pn9iXgWikK9s1IO62Om4ZhgO4H)N8zYdw8u9ZaOsgu2pHf7LPrqCnBjqwGKJKwqh2tj2JweSxlSVoIDvsb2RDiyF7rWE4W(wTWEzAeexZwcKfi5iPf0H9uI9WI9O1o23h7Bh7Pg7LPrqCYJDfdAs6O7WE4W(wTWEyX(anaWxQQJyxLuOeaRoSNAShvq4KmOm2tn2dvShoSNsSVoIDvsXpTqw79tjwAbuOwe1GoucLaWMe5ZhgT9H)NwiR9(P8yxHAruzmR4JLO4N8zYdw8u95ddu6H)NwiR9(jkAdik7ulIY0JbBg)t(m5blEQ(8HrtKh(FAHS27NiBGMWcLPhdQKvYSj9t(m5blEQ(8HrJMh(FAHS27ND0GcHI6qPKhgj)jFM8GfpvF(WObTh(FAHS27NzmROp5L(ekKfe4FYNjpyXt1NpmAG6d)pTqw79ZWEb(sGLSqHmmj(N8zYdw8u95dJM2(W)tlK1E)euDDdwvNI0zb(N8zYdw8u95dJM2F4)PfYAVFgDbdrdxNcWK9SlW)KptEWINQpFy00Mp8)KptEWINQFAHS27NDBqhNKspwOcRuhDAzTNsWnvG)zaujdk7NS(fD11Xcx3g0XjP0JfQWk1rNww7PeCtfySxlShwSxMgbX1SLazbso6oSxlSxMgbXfIxanrTiQ6i2vjfosAbDypLypArWE4W(wTWEtpguj7cXlGMOwevDe7QKchWoDypeSpYpptI)z3g0XjP0JfQWk1rNww7PeCtf4pFy0afp8)KptEWINQFAHS27NKytSrvrxGqjylJ)zaujdk7NzjXQCvIIXETJ9qf7B1c7LPrqCnBjqwGKtSrVFgOimyvAauCsEy085dJgT9H)N8zYdw8u9ZaOsgu2pLPrqCnBjqwGKJKwqh2tj2Rjc23h7Hf71eb7Pg7LPrqCYJDfdAs6O7WE4(PfYAVFsOba(emqLRsYehtiF(WObk9W)t(m5blEQ(zaujdk7NaRekUHV0zcbXvh2tj2Rjc2Rf2dl2l20rInXgvfDbcvNvNdWiaMeBYdg7B1c7ZsIv5QefJ9uI9qnc2d3pTqw79tHb0PA2s85ddArE4)PfYAVFkvNqMpbd(jFM8GfpvF(WGMMh(FYNjpyXt1pTqw79tP6ek5HrYFgavYGY(jPJhdvAauCsCs1jue2ayV2X(gduM8GDs1juYdJKQ0aO4K8ZafHbRsdGItYdJMpFyqdTh(FYNjpyXt1pdGkzqz)ewShyLqXn8LotiiU6WEkX(2XETWEGvcf3Wx6mHG4e0alR9WETJ9OH9WH9TAH9aRekUHV0zcbXjObww7H9uI9O9tlK1E)KeBInQkams8NpmOb1h(FYNjpyXt1pTqw79tsSj2OQOlqO6S6(zaujdk7NTb2N2GV0jvegqHJptEWcSxlShWiaMeBYdg71c7ZsIv5QefJ9uI9WI9WI96d714qd77J9q1bvSNASN0XJHknakojoP6ekcBaShoSNASVXaLjpyhjANkbwLkGD6iQqmh0H9uJ9WI9AWE9H9rCr0Gg2tn2B6XGkzhHnqDOuIYglkA2bSth2tn2t64XqLgafNeNuDcfHna2dh2d3pduegSknakojpmA(8HbT2(W)t(m5blEQ(PfYAVF2ysDfOcQCPdX)maQKbL9taJaysSjpySxlSpljwLRsum2tj2dl2dl2Rb77J9q1bvSNASN0XJHknakojoP6ekcBaShoSNASVXaLjpyxtQsGvPcyNoIkeZbDyp1ypSyVgSVp2hXPjc2tn2B6XGkzhHnqDOuIYglkA2bSth2tn2t64XqLgafNeNuDcfHna2dh2d3pduegSknakojpmA(8HbT2F4)jFM8Gfpv)0czT3pBmPUcubvU0H4FgavYGY(Pythj2eBuv0fiuDwDoaJaysSjpySxlShwSpTbFPtQimGchFM8GfyVwyFwsSkxLOySNsShwShwSxJlc23h7rZfb7Pg7jD8yOsdGItItQoHIWga7Hd7Pg7BmqzYd21KkPIOsGvPcyNoIkeZbDyp1ypSyFJbktEWUMujvefrOcXCqh2tn2t64XqLgafNeNuDcfHna2dh2dh2d3pduegSknakojpmA(8HbT28H)N8zYdw8u9ZaOsgu2pLPrqCnBjqwGKJU7NwiR9(zZwcvUaaF5NpmObfp8)KptEWINQFAHS27Ns1jue2a)mqryWQ0aO4K8WO5N1Lmaq3LQc5Nzf0rOecA)SUKba6UuvssSOSK)PMFgavYGY(jPJhdvAauCsCs1jue2aypLyVMFgIT6(PMpFyqtBF4)jFM8Gfpv)0czT3pLQtOqggf)SUKba6Uuvi)mRGocLqqtlyd7oeB0Z1SLqjVJ0r31Qvy3HyJEoP6ek5HrshDhC)SUKba6UuvssSOSK)PMFgIT6(PMpFyqdk9W)tlK1E)KeBInQk6ceQoRUFYNjpyXt1NF(tbJy0J8H)HrZd)pTqw79tsn4lW)KptEWINQpFyq7H)NwiR9(jnHvvYsKFYNjpyXt1Npmq9H)N8zYdw8u9ZaOsgu2pLPrqCYJDfdAs6aSfsSVvlSpljwLRsum2RDiyV2gb7B1c7tdGItxmBJm21fsSx7ypuB)NwiR9(z3M1EF(W02h(FYNjpyXt1p3UFs48NwiR9(zJbktEW)SXg08pfB6iXMyJQIUaHQZQZLvqxDOWETWEXMUgtQRavqLlDi2LvqxDO(zJbuNjX)uSjrr395dt7p8)KptEWINQFgavYGY(PfYQHv8XsftWEkXEn)0czT3pb0NYczTNAuK8NJIKQZK4FggS1WF(W0Mp8)KptEWINQFgavYGY(PfYQHv8XsftWEiyVMFAHS27Na6tzHS2tnks(Zrrs1zs8pj1HAWF(5p7aCyLKT8H)HrZd)p5ZKhS4P6Zhg0E4)jFM8GfpvF(Wa1h(FYNjpyXt1NpmT9H)N8zYdw8u95dt7p8)0czT3p72S27N8zYdw8u95dtB(W)t(m5blEQ(529tcN)0czT3pBmqzYd(Nn2GM)jYyxa2dl2dl23wx7yFFS30JbvYUOXfPJbe1IOYywjmPJfoGD6WE4WE9JypSyVgSVp2hXHguG9uJ9MEmOs2ryduhkLOSXIIMDa70H9WH9W9ZgdOotI)PuDcL8WiPknakojF(Wafp8)KptEWINQFUD)KW5pTqw79ZgduM8G)zJnO5Fcl2Rb71h2hXfbkWEQXEtpguj7eSLXQmgSmXbSth23h7J4qd7Pg7n9yqLSlJxAuXPk2anmjzGdyNoShoSNAShwSxd2RpSpIlcuc7Pg7n9yqLSlJxAuXPk2anmjzGdyNoSNAS30JbvYocBG6qPeLnwu0SdyNoShUF2ya1zs8pjr7ujWQubSthrfI5GUpFy02h(FYNjpyXt1p3UFs48NwiR9(zJbktEW)SXg08pHf71G96d7J4I0wSNAS30JbvYUmEPrfNQyd0WKKboGD6WE9H9rCrAh7Pg7n9yqLSJ0vjJqpuwxNbQS2J4a2Pd7H7NngqDMe)ZMuLaRsfWoDeviMd6(8Hbk9W)t(m5blEQ(529tcN)0czT3pBmqzYd(Nn2GM)jSyVgSxFyFexeOa7Pg7n9yqLStWwgRYyWYehWoDyV(W(iUiqf7Pg7n9yqLSlJxAuXPk2anmjzGdyNoSxFyFexK2Bh7Pg7n9yqLSJ0vjJqpuwxNbQS2J4a2Pd7Hd7Pg7Hf71G96d7J4IGguG9uJ9MEmOs2LXlnQ4ufBGgMKmWbSth2tn2B6XGkzhHnqDOuIYglkA2bSth2d3pBmG6mj(NnPsQiQeyvQa2PJOcXCq3NpmAI8W)t(m5blEQ(529tcN)0czT3pBmqzYd(Nn2GM)PgSxFyFexenTf7Pg7n9yqLSJWgOoukrzJffn7a2P7NngqDMe)ZMujvefrOcXCq3NpmA08W)t(m5blEQ(zaujdk7NTb2ltJG4iXMyJISajhD3pTqw79tsSj2Oilq6ZhgnO9W)t(m5blEQ(zaujdk7NKoEmuPbqXjXjvNqrydG9Ah7rd7B1c7n9yqLSlJxAuXPk2anmjzGdyNoShc2h5NwiR9(PuDcL8Wi5NpmAG6d)pTqw79ZgtQRavqLlDi(N8zYdw8u95NF(ZggqQ9EyqlIgOueOqtexeTT9Fg1axDOi)u)Su3cswG9Tf7Tqw7H9JIKehU3pjDC4HbT212F2bwKAW)uBW(zSj2OyV(jqXKe3tBW(4m7i6FOHgvLX0YUWkbnPKOhww7fagscnPKcqJ7PnyFp6bfyVMiOJ9Ofrduc71h2hrB1)Thb3d3tBWE9xSDOyI(h3tBWE9H963cblW(zn4lWoCpTb71h2R)2RHbjlW(0aO4uviypHIlnOSd3tBWE9H96V9AyqYcSpnakoDzjXQCvIIX(CX(SKyvUkrXyF0ygWyV11nQGjpyhUhUN2G96hGYCGozb2lZilGX(WkjBj2lZOQJ4WE97qG7sc2F7PVydiHqpWElK1EeSFVbfoCplK1EexhGdRKSLqqggrhUNfYApIRdWHvs2Y(qGgzxbUNfYApIRdWHvs2Y(qG2OrjXxAzThUN2G9ZZ6iXBI9aReyVmncclWEsAjb7LzKfWyFyLKTe7Lzu1rWE7eyFhG1x3MzDOW(IG9I9yhUNfYApIRdWHvs2Y(qGMCwhjEtfjTKG7zHS2J46aCyLKTSpeO72S2d3ZczThX1b4WkjBzFiq3yGYKhm6NjXqKQtOKhgjvPbqXjb9TdcHt0BSbndbzSlawyBRR9(MEmOs2fnUiDmGOwevgZkHjDSWbSthC6hHvt)io0GcQn9yqLSJWgOoukrzJffn7a2Pdo4W9Sqw7rCDaoSsYw2hc0ngOm5bJ(zsmes0ovcSkva70ruHyoOd9TdcHt0BSbndbwn6lIlcuqTPhdQKDc2YyvgdwM4a2PRFehAuB6XGkzxgV0OItvSbAysYahWoDWrnSA0xexeOe1MEmOs2LXlnQ4ufBGgMKmWbSth1MEmOs2ryduhkLOSXIIMDa70bhUNfYApIRdWHvs2Y(qGUXaLjpy0ptIH0KQeyvQa2PJOcXCqh6BhecNO3ydAgcSA0xexK2sTPhdQKDz8sJkovXgOHjjdCa70PViUiTtTPhdQKDKUkze6HY66mqL1EehWoDWH7zHS2J46aCyLKTSpeOBmqzYdg9ZKyinPsQiQeyvQa2PJOcXCqh6BhecNO3ydAgcSA0xexeOGAtpguj7eSLXQmgSmXbStN(I4IavQn9yqLSlJxAuXPk2anmjzGdyNo9fXfP92P20JbvYosxLmc9qzDDgOYApIdyNo4Ogwn6lIlcAqb1MEmOs2LXlnQ4ufBGgMKmWbSth1MEmOs2ryduhkLOSXIIMDa70bhUNfYApIRdWHvs2Y(qGUXaLjpy0ptIH0KkPIOicviMd6qF7Gq4e9gBqZq0OViUiAAl1MEmOs2ryduhkLOSXIIMDa70H7zHS2J46aCyLKTSpeOjXMyJISaj0leiTHmncIJeBInkYcKC0D4EwiR9iUoahwjzl7dbAP6ek5Hrs0leiKoEmuPbqXjXjvNqrydOD0A1Y0JbvYUmEPrfNQyd0WKKboGD6Geb3ZczThX1b4WkjBzFiq3ysDfOcQCPdX4E4EAd2RFakZb6Kfyp3WakW(SKySpJzS3c5cW(IG9wJvdtEWoCplK1EeiKAWxGX9Sqw7r6dbAAcRQKLi4EwiR9i9HaD3M1EOxiqKPrqCYJDfdAs6aSfYwTYsIv5QefRDiABKwTsdGItxmBJm21fsTd12X9Sqw7r6db6gduM8Gr)mjgIytIIUd9TdcHt0BSbndrSPJeBInQk6ceQoRoxwbD1HslXMUgtQRavqLlDi2LvqxDOW9Sqw7r6dbAa9PSqw7Pgfjr)mjgsyWwdJEHaXcz1Wk(yPIjuQb3ZczThPpeOb0NYczTNAuKe9ZKyiK6qny0leiwiRgwXhlvmbIgCpCplK1EexyWwddPzlHIb0DzThUNfYApIlmyRH7dbAHb0PmsGpsTh6fcezAeexZwcKfi5eB0d3ZczThXfgS1W9HaDJj1vGkOYLoeJEHaPnYkORouAz6XGkzxgV0OItvSbAysYahWoDucrdUNfYApIlmyRH7dbAP6ekcBa0leiY0iiUyd0WKKfQmEPrfNehDhUNfYApIlmyRH7db6MTek5DK4EwiR9iUWGTgUpeOPjSQswc9ZKyiMEKydyefYEPAruDBugGEHabwzAeexZwcKfi5O70sMgbXfIxanrTiQ6i2vjfosAbDuIwe4A1Y0JbvYUq8cOjQfrvhXUkPWbSthKi4EwiR9iUWGTgUpeOLyPfqHArud6qjucaBse0leiWktJG4A2sGSajhjTGokrlIw1rSRsk0oK2JaxRwY0iiUMTeilqYrslOJsyrR9(TtTmncItESRyqtshDhCTAbBGga4lv1rSRskucGvh1OccNKbLPgQWrzDe7QKcCplK1EexyWwd3hc0YJDfQfrLXSIpwIcCplK1EexyWwd3hc0OOnGOStTiktpgSzmUNfYApIlmyRH7dbAKnqtyHY0JbvYkz2KW9Sqw7rCHbBnCFiq3rdkekQdLsEyKe3ZczThXfgS1W9HaDgZk6tEPpHczbbg3ZczThXfgS1W9HaDyVaFjWswOqgMeJ7zHS2J4cd2A4(qGguDDdwvNI0zbg3ZczThXfgS1W9HaD0fmenCDkat2ZUaJ7zHS2J4cd2A4(qGMMWQkzj0ptIH0TbDCsk9yHkSsD0PL1Ekb3ubg9cbcRFrxDDSWPPnHI2BVDTGvMgbX1SLazbso6oTKPrqCH4fqtulIQoIDvsHJKwqhLOfbUwTm9yqLSleVaAIAru1rSRskCa70bjcUNfYApIlmyRH7dbAsSj2OQOlqOeSLXOhOimyvAauCsGOb9cbswsSkxLOyTd1wTKPrqCnBjqwGKtSrpCplK1EexyWwd3hc0eAaGpbdu5QKmXXec6fcezAeexZwcKfi5iPf0rPMi9HvteQLPrqCYJDfdAs6O7Gd3ZczThXfgS1W9HaTWa6unBjqVqGaSsO4g(sNjeexDuQjIwWk20rInXgvfDbcvNvNdWiaMeBYdUvRSKyvUkrXuc1iWH7zHS2J4cd2A4(qGwQoHmFcgG7zHS2J4cd2A4(qGwQoHsEyKe9afHbRsdGItcenOxiqiD8yOsdGItItQoHIWgq7ngOm5b7KQtOKhgjvPbqXjb3ZczThXfgS1W9Hanj2eBuvayKy0leiWcSsO4g(sNjeexDu2UwaRekUHV0zcbXjObww7PD0GRvlGvcf3Wx6mHG4e0alR9OenCplK1EexyWwd3hc0KytSrvrxGq1z1HEGIWGvPbqXjbIg0leiTrAd(sNuryafo(m5bl0cWiaMeBYdwRSKyvUkrXuclS6tJdT(q1bvQjD8yOsdGItItQoHIWgaoQBmqzYd2rI2PsGvPcyNoIkeZbDudRg9fXfrdAuB6XGkzhHnqDOuIYglkA2bSth1KoEmuPbqXjXjvNqrydahC4EwiR9iUWGTgUpeOBmPUcubvU0Hy0duegSknakojq0GEHabWiaMeBYdwRSKyvUkrXuclSA6dvhuPM0XJHknakojoP6ekcBa4OUXaLjpyxtQsGvPcyNoIkeZbDudRM(rCAIqTPhdQKDe2a1HsjkBSOOzhWoDut64XqLgafNeNuDcfHnaCWH7zHS2J4cd2A4(qGUXK6kqfu5shIrpqryWQ0aO4Kard6fceXMosSj2OQOlqO6S6CagbWKytEWAbBAd(sNuryafo(m5bl0kljwLRsumLWcRgxK(O5IqnPJhdvAauCsCs1jue2aWrDJbktEWUMujvevcSkva70ruHyoOJAyBmqzYd21KkPIOicviMd6OM0XJHknakojoP6ekcBa4GdoCplK1EexyWwd3hc0nBju5ca8LOxiqKPrqCnBjqwGKJUd3ZczThXfgS1W9HaTuDcfHna6bkcdwLgafNeiAqVqGq64XqLgafNeNuDcfHnaLAqpeB1brd61Lmaq3LQssIfLLmenOxxYaaDxQkeizf0rOecA4EwiR9iUWGTgUpeOLQtOqggfOhIT6GOb96sgaO7svjjXIYsgIg0RlzaGUlvfcKSc6iucbnTGnS7qSrpxZwcL8oshDxRwHDhIn65KQtOKhgjD0DWH7zHS2J4cd2A4(qGMeBInQk6ceQoRoCpCplK1EehPoudgsZwcfdO7YApCplK1EehPoudUpeOfgqNYib(i1EOxiqKPrqCnBjqwGKtSrpCplK1EehPoudUpeOB2sOK3rI7zHS2J4i1HAW9HannHvvYsOFMedX0JeBaJOq2lvlIQBJYa0leiWktJG4A2sGSajhDNwY0iiUq8cOjQfrvhXUkPWrslOJs0IaxRwMEmOs2fIxanrTiQ6i2vjfoGD6Geb3ZczThXrQd1G7dbAjwAbuOwe1GoucLaWMeb9cbcSY0iiUMTeilqYrslOJs0IOvDe7QKcTdP9iW1QLmncIRzlbYcKCK0c6Oew0AVF7ultJG4Kh7kg0K0r3bxRwWgOba(svDe7QKcLay1rnQGWjzqzQHkCuwhXUkPa3ZczThXrQd1G7dbA5XUc1IOYywXhlrbUNfYApIJuhQb3hc0OOnGOStTiktpgSzmUNfYApIJuhQb3hc0iBGMWcLPhdQKvYSjH7zHS2J4i1HAW9HaDhnOqOOouk5HrsCplK1EehPoudUpeOZywrFYl9juiliW4EwiR9iosDOgCFiqh2lWxcSKfkKHjX4EwiR9iosDOgCFiqdQUUbRQtr6SaJ7zHS2J4i1HAW9HaD0fmenCDkat2ZUaJ7zHS2J4i1HAW9HannHvvYsOFMedPBd64Ku6XcvyL6OtlR9ucUPcm6fcew)IU66yHttBcfT3E7AbRmncIRzlbYcKC0DAjtJG4cXlGMOwevDe7QKchjTGokrlcCTAz6XGkzxiEb0e1IOQJyxLu4a2PdseCplK1EehPoudUpeOLQtOiSbqVqGitJG4InqdtswOY4LgvCsC0DAf2Di2ONRzlHsEhPdWswDekHOX1UwMEmOs2ryduhkLOSXIIMDa70rjen4EwiR9iosDOgCFiqtInXgvfDbcLGTmg9cbswsSkxLOyTd1wTc7oeB0ZrInXgvfDbcLGTm2fInakMabTwTGnS7qSrphj2eBuv0fiuc2Yyxi2aOycenAf2Di2ONJeBInQk6cekbBzSdWswDeTJkiCsgugoCplK1EehPoudUpeOj0aaFcgOYvjzIJje0leiY0iiUMTeilqYrslOJsnr6dRMiultJG4Kh7kg0K0r3bhUNfYApIJuhQb3hc0cdOt1SLa9cbcWkHIB4lDMqqC1rPMi4EwiR9iosDOgCFiqlvNqMpbdqVqGK2GV0jvNqMpbdC8zYdw0QfSY0iiUMTeilqYrslOJsnABRwzjXQCvII1UM2Hd3ZczThXrQd1G7dbAsSj2OQOlqOeSLXOxiqAdzAeexZwcKfi5O7A1c2WUdXg9CKytSrvrxGqjylJDHydGIjqqtlzAeexZwcKfi5iPf0PDnTdhUNfYApIJuhQb3hc0KytSrvbGrIrVqGaSsO4g(sNjeexDu2UwaRekUHV0zcbXjObww7PD0IG7zHS2J4i1HAW9HaTuDcL8Wij6fcKgduM8GDInjk6oTGfwGvcf3Wx6K2gwIV0vhLbJKQSK4(rCTRfWkHIB4lDsBdlXx6Qt7TfUwTAJ0g8LosSj2OQOlqOA2s44ZKhSOvlzAeexZwcKfi5eB0RvlzAeexZwcKfi5iPf0rPM2QfS1rSRsk0ouePvRqSbqXefcWczTNnOuJdQqfUwTKPrqCnBjqwGKJKwqN2HOPTAbBDe7QKcT3MrA1keBaumrHaSqw7zdk14GkuHdoCplK1EehPoudUpeOB2sOYfa4lrVqGi20rInXgvfDbcvNvNdWswDekBRwInDnMuxbQGkx6qSdWswDekBRwY0iiUMTeilqYr3H7zHS2J4i1HAW9Hanj2eBuv0fiuDwDOxiqamcGjXM8G1kljwLRsumLTvR2iTbFPtQimGchFM8GfA1gPn4lDcdOt1SLWXNjpybUNfYApIJuhQb3hc0nMuxbQGkx6qm6fceaJaysSjpyTYsIv5QeftzB2QfSPn4lDsfHbu44ZKhSqlXMosSj2OQOlqO6S6CagbWKytEWWH7zHS2J4i1HAW9HaTuDcfYWOa9qSvhenOxxYaaDxQkjjwuwYq0GEDjda0DPQqGKvqhHsiOPfSHDhIn65A2sOK3r6O7A1kS7qSrpNuDcL8WiPJUdoCplK1EehPoudUpeOjXMyJQIUaHQZQ7Zp)h]] )


end
