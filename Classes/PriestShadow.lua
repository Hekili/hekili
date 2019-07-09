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


    spec:RegisterPack( "Shadow", 20190709.1600, [[deer8aqiabpcsPUevve2evvnkG4uaPvbu9kfQzbrDlKQAxI8la1WKsogKSmKspdqAAiv5AIQSniL8narJdqOZrvfwhvvsZdsX9ayFifhKQkQwiKQhsvL4IuvrYjPQIuRuHStGYqPQIONQOPcr2RQ(lfdMshM0IjYJPYKrCzuBMO(megTuCAjVMQYSLQBJKDR0Vvz4k44uvrz5GEoHPlCDQY2fLVlQmEQQuNhPY6fv18LsTFO(r9i9tIg8dgTTq5hTaYw(rcfAHcO0dO)mOBG)5G68Pi4FUkf)ZzJsUC)CqPRFk5r6NIZd64F2eXGWVcmWiQOXtk5okGffLxxJ6whuLdGffLd4Fk5v9Wp9(s)KOb)GrBlu(rlGSLFKqHwOOnV8(P6fnh8NZIYV8ZMIq49L(jHfUFI2y7SrjxoS1pjSyrGhH2yBtedc)kWaJOIgpPK7OawuuEDnQBDqvoawuuoGXJqBSDKxNoS1pqgBPTfk)aBPp2IcT8RTAHhHhH2yRFPrxeSWVIhH2yl9Xw)CcHjy7S6864eEeAJT0hB9l3MXWGjyBOqeCykzSvq3gQFNWJqBSL(yRF52mggmbBdfIGJuuuSjodPySnoSnkk2eNHum2MRHHm2Qdd9YPsDo9ZEjcXJ0pf1IOZpspyOEK(P6I62FMDfXWqVHOU9N8QsDM8O)XdgTps)KxvQZKh9F6GvWWs)PKNSCk7kI8bPsKl3(t1f1T)KOqFgv44vu3(XdgqFK(P6I62FMDfXiD94N8QsDM8O)Xdg9EK(jVQuNjp6)0bRGHL(tqWwjpz5u2ve5dsLeH68HT0GT02cB9hBRvOBf0HTOba2MxlSfuSTDBSvYtwoLDfr(GujrOoFylnyliylT5HTJX28WwWXwjpz5Ku)os3tejVbSfuSTDBSfeS15bH8gMAf6wbDgcuRfBbhBr4ijk1VXwWXwGITGIT0GT1k0Tc6(P6I62FsXuhKoZjB6EUIyiqwPeF8GL3J0pvxu3(tP(DeZjBIg2Wltr3p5vL6m5r)Jhm06r6NQlQB)jcpfskDnNSrZNHx08tEvPotE0)4bdiFK(P6I62FkFopbtmA(mSc2iXk1p5vL6m5r)JhmG4J0pvxu3(ZbpyjtxTimsDve)KxvQZKh9pEW8JhPFQUOU9NrdB8wPZBjg5d64FYRk1zYJ(hpyOA9i9t1f1T)0DRJ3aQbtmYDLI)jVQuNjp6F8GHc1J0pvxu3(tynm0ztTgXG64FYRk1zYJ(hpyOO9r6NQlQB)zUd2jzCTgilUvxh)tEvPotE0)4bdfqFK(jVQuNjp6)uDrD7phoNpoev(mX4oQbVqJ6wdHZkh)thScgw6pz)mVAyGjPHZ5JdrLptmUJAWl0OU1q4SYXyR)yliyRKNSCk7kI8bPsIqD(Ww0GTOYdBB3gBbbBDEqiVHPwHUvqNHa1AXwWXweosIs9BSfCSLEylOylnyBTcDRGoSf0FUkf)ZHZ5JdrLptmUJAWl0OU1q4SYXF8GHIEps)KxvQZKh9F6GvWWs)PKNSCQrHzSiyIjAopenHi5nGT(JTU76Kl3MYUIyKUEKGmLwRaBPba2IkLh26p2Q5ZWk4KGvyTimKs7hcpob11h2sdaSf1pvxu3(tQAjgbRWpEWqL3J0p5vL6m5r)NoyfmS0FgffBIZqkgBrd2cuSTDBS1DxNC52KOrjxotUdsmewJMKRrHiyb2caBPfBB3gBbbBD31jxUnjAuYLZK7GedH1Oj5AuicwGTaWwuyR)yR7Uo5YTjrJsUCMChKyiSgnjitP1kWw0GTiCKeL63ylO)uDrD7pfnk5YzYDqIHWA08Xdgk06r6N8QsDM8O)thScgw6pL8KLtzxrKpivseQZh2sd2IQf2ogBbbBr1cBbhBL8KLts97iDprK8gWwq)P6I62Fk8GqEjm0eNHsjlleF8GHciFK(jVQuNjp6)0bRGHL(tOwedNXBKucrKQfBPbBr16NQlQB)jrH(mzxr(4bdfq8r6N8QsDM8O)thScgw6pdTZBKOQLiXlHHjEvPotW22TXwqWwjpz5u2ve5dsLeH68HT0GTOaIyB72yBuuSjodPySfnylQ8Wwq)P6I62FsvlrIxcd)4bdLF8i9tEvPotE0)Pdwbdl9NabSvYtwoLDfr(GujVbSTDBSfeS1DxNC52KOrjxotUdsmewJMKRrHiyb2caBPfB9hBL8KLtzxrKpivseQZh2IgSfvEylO)uDrD7pfnk5YzYDqIHWA08XdgTTEK(jVQuNjp6)0bRGHL(tOwedNXBKucrKQfBPbBZdB9hBHArmCgVrsjerI4b1OUfBrd2sBRFQUOU9NIgLC5moOkA(4bJwups)KxvQZKh9F6GvWWs)zMclvQZjYfcJ3a26p2cc2cc2c1Iy4mEJe1LXu8gPAXwAWwNkctuum2ogBBLYdB9hBHArmCgVrI6YykEJuTylAWw6HTGITTBJTabSn0oVrs0OKlNj3bjMSRijEvPotW22TXwjpz5u2ve5dsLixUfBB3gBL8KLtzxrKpivseQZh2sd2IIEyR)yliyBTcDRGoSfnylq2cBB3gBDnkeblmYq1f1TAhBPbBrLakqXwqX22TXwjpz5u2ve5dsLeH68HTOba2IIEyR)yliyBTcDRGoSfnylA1cBB3gBDnkeblmYq1f1TAhBPbBrLakqXwqXwq)P6I62FsvlXi1vr8XdgT0(i9tEvPotE0)Pdwbdl9NKlsIgLC5m5oiXmO1MGmLwRaBPbBPh26p2sUiLPudfSCM48CnjitP1kWwAWw6HT(JTsEYYPSRiYhKk5n8t1f1T)m7kIjoiK34JhmAb6J0p5vL6m5r)NoyfmS0FczzilAuPoJT(JTrrXM4mKIXwAWw6HT(JTabSn0oVrIQemKUeVQuNjyR)ylqaBdTZBKik0Nj7ksIxvQZKFQUOU9NIgLC5m5oiXmO1(XdgT07r6N8QsDM8O)thScgw6pHSmKfnQuNXw)X2OOytCgsXylnylAHTTBJTGGTH25nsuLGH0L4vL6mbB9hBjxKenk5YzYDqIzqRnbzzilAuPoJTG(t1f1T)mtPgky5mX55A(4bJ28EK(jVQuNjp6)uDrD7pPQLyK7kD)S2GHqVHWuY)mkNpbnaO1FqC31jxUnLDfXiD9i5n0UT7Uo5YTjQAjgPUkIK3aO)S2GHqVHWuuumP0G)jQF6A0A)jQpEWOfTEK(P6I62FkAuYLZK7GeZGw7p5vL6m5r)Jp(5aKDhLKgpspyOEK(jVQuNjp6F8Gr7J0p5vL6m5r)JhmG(i9tEvPotE0)4bJEps)KxvQZKh9pEWY7r6NQlQB)5Wf1T)KxvQZKh9pEWqRhPFYRk1zYJ(pVHFk44NQlQB)zMclvQZ)mt7E8pL73bXwqWwqWw6LYdBhJTA(mScoLRPedmuyozt0WgIsTmjb11h2ck26NaBbbBrHTJX2wjAbsSfCSvZNHvWjbRWAryiL2peECcQRpSfuSf0FMPqZQu8pPQLyK6QimHcrWH4JhmG8r6N8QsDM8O)ZB4Nco(P6I62FMPWsL68pZ0Uh)tqWwuyl9X2wPwaj2co2Q5ZWk4eH1OXenWJfjOU(W2XyBReTyl4yRMpdRGtrZ5HOjmnkmJfbdtqD9HTGITGJTGGTOWw6JTTsT8dSfCSvZNHvWPO58q0eMgfMXIGHjOU(WwWXwnFgwbNeScRfHHuA)q4XjOU(Wwq)zMcnRsX)uKBWeqTcduxFcJRHD((4bdi(i9tEvPotE0)5n8tbh)uDrD7pZuyPsD(NzA3J)jiylkSL(yBRul6HTGJTA(mScofnNhIMW0OWmwemmb11h2sFSTvQvEyl4yRMpdRGtIHkyzVUrhguyf1TIeuxFylO)mtHMvP4FMfMaQvyG66tyCnSZ3hpy(XJ0p5vL6m5r)N3WpfC8t1f1T)mtHLk15FMPDp(NGGTOWw6JTTsTasSfCSvZNHvWjcRrJjAGhlsqD9HT0hBBLAbuSfCSvZNHvWPO58q0eMgfMXIGHjOU(Ww6JTTsTYlpSfCSvZNHvWjXqfSSx3OddkSI6wrcQRpSfuSfCSfeSff2sFSTvQfTaj2co2Q5ZWk4u0CEiActJcZyrWWeuxFyl4yRMpdRGtcwH1IWqkTFi84euxFylO)mtHMvP4FMfgQsycOwHbQRpHX1WoFF8GHQ1J0p5vL6m5r)N3WpfC8t1f1T)mtHLk15FMPDp(NOWw6JTTsTqrpSfCSvZNHvWjbRWAryiL2peECcQRVFMPqZQu8pZcdvjmcIX1WoFF8GHc1J0p5vL6m5r)NoyfmS0FceWwjpz5KOrjxo5dsL8g(P6I62FkAuYLt(GuF8GHI2hPFYRk1zYJ(pDWkyyP)umW9UjuicoejQAjgbRqSfnylTyB72yRMpdRGtrZ5HOjmnkmJfbdtqD9HTaW2w)uDrD7pPQLyK6Qi(4bdfqFK(P6I62FMPudfSCM48Cn)KxvQZKh9p(4Neww96XJ0dgQhPFQUOU9NIQZRJ)jVQuNjp6F8Gr7J0pvxu3(tpbBQGPe)KxvQZKh9pEWa6J0p5vL6m5r)NoyfmS0Fk5jlNK63r6EIibz1fyB72yBuuSjodPySfnaWwGylSTDBSnuicosnS2JM0GlWw0GTanVFQUOU9Ndxu3(Xdg9EK(jVQuNjp6)8g(PGJFQUOU9NzkSuPo)ZmT7X)KCrs0OKlNj3bjMbT2uuoF1IaB9hBjxKYuQHcwotCEUMuuoF1I4Nzk0Skf)tYfcJ3Whpy59i9tEvPotE0)Pdwbdl9NQlQm2WltvSaBPbBr9t1f1T)e6Tg1f1TMEjIF2lrywLI)PRZAg)XdgA9i9tEvPotE0)Pdwbdl9NQlQm2WltvSaBbGTO(P6I62Fc9wJ6I6wtVeXp7LimRsX)uulIo)Xh)01znJFKEWq9i9t1f1T)m7kIHHEdrD7p5vL6m5r)JhmAFK(jVQuNjp6)0bRGHL(tjpz5u2ve5dsLixU9NQlQB)jrH(mQWXROU9JhmG(i9tEvPotE0)Pdwbdl9NabSnkNVArGT(JTA(mScofnNhIMW0OWmwemmb11h2sdaSf1pvxu3(ZmLAOGLZeNNR5Jhm69i9tEvPotE0)Pdwbdl9NsEYYPgfMXIGjMO58q0eIK3Wpvxu3(tQAjgbRWpEWY7r6NQlQB)z2veJ01JFYRk1zYJ(hpyO1J0p5vL6m5r)NoyfmS0Fcc2k5jlNYUIiFqQKiuNpSLgSL2wyR)yBTcDRGoSfnaW28AHTGITTBJTsEYYPSRiYhKkjc15dBPbBbbBPnpSDm2Mh2co2k5jlNK63r6EIi5nGTGITTBJTGGTopiK3WuRq3kOZqGATyl4ylchjrP(n2co2cuSfuSLgSTwHUvq3pvxu3(tkM6G0zozt3ZvedbYkL4JhmG8r6NQlQB)Pu)oI5KnrdB4LPO7N8QsDM8O)Xdgq8r6NQlQB)jcpfskDnNSrZNHx08tEvPotE0)4bZpEK(P6I62FkFopbtmA(mSc2iXk1p5vL6m5r)JhmuTEK(P6I62Fo4blz6QfHrQRI4N8QsDM8O)Xdgkups)uDrD7pJg24TsN3smYh0X)KxvQZKh9pEWqr7J0pvxu3(t3ToEdOgmXi3vk(N8QsDM8O)XdgkG(i9t1f1T)ewddD2uRrmOo(N8QsDM8O)Xdgk69i9t1f1T)m3b7KmUwdKf3QRJ)jVQuNjp6F8GHkVhPFYRk1zYJ(pvxu3(ZHZ5JdrLptmUJAWl0OU1q4SYX)0bRGHL(t2pZRggysA4C(4qu5ZeJ7Og8cnQBneoRCm26p2cc2k5jlNYUIiFqQKiuNpSfnylQ8W22TXwqWwNheYByQvOBf0ziqTwSfCSfHJKOu)gBbhBPh2ck2sd2wRq3kOdBb9NRsX)C4C(4qu5ZeJ7Og8cnQBneoRC8hpyOqRhPFYRk1zYJ(pvxu3(trJsUCMChKyiSgn)0bRGHL(ZOOytCgsXylAWwGITTBJTsEYYPSRiYhKkrUC7pD056SjuicoepyO(4bdfq(i9tEvPotE0)Pdwbdl9NsEYYPSRiYhKkjc15dBPbBr1cBhJTGGTOAHTGJTsEYYjP(DKUNisEdylO)uDrD7pfEqiVegAIZqPKLfIpEWqbeFK(jVQuNjp6)0bRGHL(tOwedNXBKucrKQfBPbBr1cB9hBbbBjxKenk5YzYDqIzqRnbzzilAuPoJTTBJTrrXM4mKIXwAWwG2cBb9NQlQB)jrH(mzxr(4bdLF8i9t1f1T)KQwIeVeg(tEvPotE0)4bJ2wps)KxvQZKh9FQUOU9Nu1smsDve)0bRGHL(tXa37MqHi4qKOQLyeScXw0GTzkSuPoNOQLyK6QimHcrWH4No6CD2ekebhIhmuF8GrlQhPFYRk1zYJ(pDWkyyP)eeSfQfXWz8gjLqePAXwAW28Ww)XwOwedNXBKucrKiEqnQBXw0GT0ITGITTBJTqTigoJ3iPeIir8GAu3IT0GT0(t1f1T)u0OKlNXbvrZhpy0s7J0p5vL6m5r)NQlQB)POrjxotUdsmdAT)0bRGHL(tGa2gAN3irvcgsxIxvQZeS1FSfYYqw0OsDgB9hBJIInXzifJT0GTGGTGGT0hBrLOfBhJTanbuSfCSvmW9UjuicoejQAjgbRqSfuSfCSntHLk15Ki3GjGAfgOU(egxd78HTGJTGGTOWw6JTTsTqrl2co2Q5ZWk4KGvyTimKs7hcpob11h2co2kg4E3ekebhIevTeJGvi2ck2c6pD056SjuicoepyO(4bJwG(i9tEvPotE0)P6I62FMPudfSCM48Cn)0bRGHL(ZOOytCgsXylnyliyliylkSDm2c0eqXwWXwXa37MqHi4qKOQLyeScXwqXwWX2mfwQuNtzHjGAfgOU(egxd78HTGJTGGTOW2XyBReQwyl4yRMpdRGtcwH1IWqkTFi84euxFyl4yRyG7DtOqeCisu1smcwHylOylO)0rNRZMqHi4q8GH6JhmAP3J0p5vL6m5r)NQlQB)zMsnuWYzIZZ18thScgw6pbbBdTZBKOkbdPlXRk1zc26p2gffBIZqkgBPbBbbBbbBrLAHTJXwAtTWwWXwXa37MqHi4qKOQLyeScXwqXwWX2mfwQuNtzHHQeMaQvyG66tyCnSZh2co2cc2MPWsL6CklmuLWiigxd78HTGJTIbU3nHcrWHirvlXiyfITGITGITG(thDUoBcfIGdXdgQpEWOnVhPFYRk1zYJ(pDWkyyP)uYtwoLDfr(GujVHFQUOU9NzxrmXbH8gF8GrlA9i9tEvPotE0)P6I62FsvlXiyf(thDUoBcfIGdXdgQFwBWqO3qyk5FgLZNGga0(ZAdgc9gctrrXKsd(NO(Pdwbdl9NIbU3nHcrWHirvlXiyfIT0GTO(PRrR9NO(4bJwG8r6N8QsDM8O)t1f1T)KQwIrUR09ZAdgc9gctj)ZOC(e0aGw)bXDxNC52u2veJ01JK3q72U76Kl3MOQLyK6QisEdG(ZAdgc9gctrrXKsd(NO(PRrR9NO(4bJwG4J0pvxu3(trJsUCMChKyg0A)jVQuNjp6F8Xh)mJHI62hmABHYpArVwOsOOhqP3pZPWTweIF6NMA4GbtWw6HTQlQBX2Ejcrcp6NdWtU68prBSD2OKlh26NewSiWJqBSTjIbHFfyGrurJNuYDualkkVUg1ToOkhalkkhW4rOn2oYRth26hiJT02cLFGT0hBrHw(1wTWJWJqBS1V0Olcw4xXJqBSL(yRFoHWeSDwDEDCcpcTXw6JT(LBZyyWeSnuicomLm2kOBd1Vt4rOn2sFS1VCBgddMGTHcrWrkkk2eNHum2gh2gffBIZqkgBZ1WqgB1HHE5uPoNWJWJqBS1pLFZoVGjyRelFqgBDhLKgyReJOwrcB9ZDoEiey7El9BuiLSxhBvxu3kW2B70LWJuxu3ksdq2DusAaqURcF4rQlQBfPbi7okjngday57i4rQlQBfPbi7okjngday1dbfVHg1T4rOn2oxDq0Cb2c1IGTsEYYmbBfHgcSvILpiJTUJssdSvIruRaB1LGTdqM(dxe1IaBlb2sULt4rQlQBfPbi7okjngdayXQdIMlmIqdbEK6I6wrAaYUJssJXaaE4I6w8i1f1TI0aKDhLKgJbaCMclvQZiVkfdGQwIrQRIWekebhcKVbacoqot7Ema5(DqqaHEP8gR5ZWk4uUMsmWqH5KnrdBik1YKeuxFG6NaeuJBLOfibxZNHvWjbRWAryiL2peECcQRpqbfpsDrDRinaz3rjPXyaaNPWsL6mYRsXae5gmbuRWa11NW4AyNpKVbacoqot7Emaqqr)wPwaj4A(mScorynAmrd8yrcQRVXTs0cUMpdRGtrZ5HOjmnkmJfbdtqD9bk4GGI(TsT8dW18zyfCkAopenHPrHzSiyycQRpW18zyfCsWkSwegsP9dHhNG66du8i1f1TI0aKDhLKgJbaCMclvQZiVkfdilmbuRWa11NW4AyNpKVbacoqot7Emaqqr)wPw0dCnFgwbNIMZdrtyAuyglcgMG66J(TsTYdCnFgwbNedvWYEDJomOWkQBfjOU(afpsDrDRinaz3rjPXyaaNPWsL6mYRsXaYcdvjmbuRWa11NW4AyNpKVbacoqot7Emaqqr)wPwaj4A(mScorynAmrd8yrcQRp63k1cOGR5ZWk4u0CEiActJcZyrWWeuxF0VvQvE5bUMpdRGtIHkyzVUrhguyf1TIeuxFGcoiOOFRulAbsW18zyfCkAopenHPrHzSiyycQRpW18zyfCsWkSwegsP9dHhNG66du8i1f1TI0aKDhLKgJbaCMclvQZiVkfdilmuLWiigxd78H8naqWbYzA3JbGI(TsTqrpW18zyfCsWkSwegsP9dHhNG66dpsDrDRinaz3rjPXyaalAuYLt(GuixYaacsEYYjrJsUCYhKk5nGhPUOUvKgGS7OK0ymaGPQLyK6QiqUKbig4E3ekebhIevTeJGviAOTDBnFgwbNIMZdrtyAuyglcgMG66dql8i1f1TI0aKDhLKgJbaCMsnuWYzIZZ1GhHhH2yRFk)MDEbtWwoJH0HTrrXyB0WyR6IdITLaB1mT6QuNt4rQlQBfaevNxhJhPUOUvmgaWEc2ubtjWJuxu3kgda4HlQBrUKbi5jlNK63r6EIibz1fTBhffBIZqkgnaaITA3ouicosnS2JM0GlqdqZdpsDrDRymaGZuyPsDg5vPyaKlegVbKVbacoqot7EmaYfjrJsUCMChKyg0Atr58vlc)jxKYuQHcwotCEUMuuoF1IapsDrDRymaGHERrDrDRPxIa5vPyaUoRzmYLma1fvgB4LPkwqdk8i1f1TIXaag6Tg1f1TMEjcKxLIbiQfrNrUKbOUOYydVmvXcaOWJWJuxu3ksUoRzmGSRigg6ne1T4rQlQBfjxN1mEmaGjk0NrfoEf1TixYaK8KLtzxrKpivIC5w8i1f1TIKRZAgpgaWzk1qblNjopxdYLmaGquoF1IWFnFgwbNIMZdrtyAuyglcgMG66JgaOWJuxu3ksUoRz8yaatvlXiyfICjdqYtwo1OWmwemXenNhIMqK8gWJuxu3ksUoRz8yaaNDfXiD9apsDrDRi56SMXJbamftDq6mNSP75kIHazLsGCjdaejpz5u2ve5dsLeH68rdTT8VwHUvqhAaKxlqB3wYtwoLDfr(GujrOoF0acT5nopWL8KLts97iDprK8gaTDBqCEqiVHPwHUvqNHa1AbhHJKOu)gCGckn1k0Tc6WJuxu3ksUoRz8yaal1VJyozt0WgEzk6WJuxu3ksUoRz8yaaJWtHKsxZjB08z4fn4rQlQBfjxN1mEmaGLpNNGjgnFgwbBKyLcpsDrDRi56SMXJba8GhSKPRwegPUkc8i1f1TIKRZAgpgaWrdB8wPZBjg5d6y8i1f1TIKRZAgpgaWUBD8gqnyIrURumEK6I6wrY1znJhdayynm0ztTgXG6y8i1f1TIKRZAgpgaW5oyNKX1AGS4wDDmEK6I6wrY1znJhdaypbBQGPqEvkgWW58XHOYNjg3rn4fAu3AiCw5yKlzaSFMxnmWKek0ciZlV88hejpz5u2ve5dsLeH68Hgu51UniopiK3WuRq3kOZqGATGJWrsuQFdo9aLMAf6wbDGIhPUOUvKCDwZ4Xaaw0OKlNj3bjgcRrdYo6CD2ekebhcaOqUKbeffBIZqkgnaTDBjpz5u2ve5dsLixUfpsDrDRi56SMXJbaSWdc5LWqtCgkLSSqGCjdqYtwoLDfr(GujrOoF0GQ1yqq1cCjpz5Ku)os3tejVbqXJuxu3ksUoRz8yaatuOpt2veKlzaqTigoJ3iPeIivlnOA5piKlsIgLC5m5oiXmO1MGSmKfnQuNB3okk2eNHumnaTfO4rQlQBfjxN1mEmaGPQLiXlHH4rQlQBfjxN1mEmaGPQLyK6Qiq2rNRZMqHi4qaafYLmaXa37MqHi4qKOQLyeScrtMclvQZjQAjgPUkctOqeCiWJuxu3ksUoRz8yaalAuYLZ4GQOb5sgaiqTigoJ3iPeIivln55pulIHZ4nskHisepOg1TOHwqB3gQfXWz8gjLqejIhuJ6wAOfpsDrDRi56SMXJbaSOrjxotUdsmdATi7OZ1ztOqeCiaGc5sgaqi0oVrIQemKUeVQuNj(dzzilAuPo7FuuSjodPyAabe6Jkr7yGMak4IbU3nHcrWHirvlXiyfck4zkSuPoNe5gmbuRWa11NW4AyNpWbbf9BLAHIwW18zyfCsWkSwegsP9dHhNG66dCXa37MqHi4qKOQLyeScbfu8i1f1TIKRZAgpgaWzk1qblNjopxdYo6CD2ekebhcaOqUKbazzilAuPoJCjdikk2eNHumnGacQXanbuWfdCVBcfIGdrIQwIrWkeuWZuyPsDoLfMaQvyG66tyCnSZh4GGACReQwGR5ZWk4KGvyTimKs7hcpob11h4IbU3nHcrWHirvlXiyfckO4rQlQBfjxN1mEmaGZuQHcwotCEUgKD056SjuicoeaqHCjdGCrs0OKlNj3bjMbT2eKLHSOrL6mYLmaqcTZBKOkbdPlXRk1zI)rrXM4mKIPbeqqLAnM2ulWfdCVBcfIGdrIQwIrWkeuWZuyPsDoLfgQsycOwHbQRpHX1WoFGdsMclvQZPSWqvcJGyCnSZh4IbU3nHcrWHirvlXiyfckOGIhPUOUvKCDwZ4Xaao7kIjoiK3a5sgGKNSCk7kI8bPsEd4rQlQBfjxN1mEmaGPQLyeScr2rNRZMqHi4qaafYLmaXa37MqHi4qKOQLyeScPbfYUgTwaOqU2GHqVHWuuumP0GbGc5Adgc9gctjdikNpbnaOfpsDrDRi56SMXJbamvTeJCxPdzxJwlauixBWqO3qykkkMuAWaqHCTbdHEdHPKbeLZNGga06piU76Kl3MYUIyKUEK8gA32DxNC52evTeJuxfrYBau8i1f1TIKRZAgpgaWIgLC5m5oiXmO1IhHhPUOUvKe1IOZaYUIyyO3qu3IhPUOUvKe1IOZJbamrH(mQWXROUf5sgGKNSCk7kI8bPsKl3IhPUOUvKe1IOZJbaC2veJ01d8i1f1TIKOweDEmaGPyQdsN5KnDpxrmeiRucKlzaGi5jlNYUIiFqQKiuNpAOTL)1k0Tc6qdG8AbA72sEYYPSRiYhKkjc15JgqOnVX5bUKNSCsQFhP7jIK3aOTBdIZdc5nm1k0Tc6meOwl4iCKeL63GduqPPwHUvqhEK6I6wrsulIopgaWs97iMt2enSHxMIo8i1f1TIKOweDEmaGr4PqsPR5KnA(m8Ig8i1f1TIKOweDEmaGLpNNGjgnFgwbBKyLcpsDrDRijQfrNhda4bpyjtxTimsDve4rQlQBfjrTi68yaahnSXBLoVLyKpOJXJuxu3ksIAr05Xaa2DRJ3aQbtmYDLIXJuxu3ksIAr05XaagwddD2uRrmOogpsDrDRijQfrNhda4ChStY4AnqwCRUogpsDrDRijQfrNhdaypbBQGPqEvkgWW58XHOYNjg3rn4fAu3AiCw5yKlzaSFMxnmWKek0ciZlV88hejpz5u2ve5dsLeH68Hgu51UniopiK3WuRq3kOZqGATGJWrsuQFdo9aLMAf6wbDGIhPUOUvKe1IOZJbamvTeJGviYLmajpz5uJcZyrWet0CEiAcrYBWF3DDYLBtzxrmsxpsqMsRvqdauP88xZNHvWjbRWAryiL2peECcQRpAaGcpsDrDRijQfrNhdayrJsUCMChKyiSgnixYaIIInXzifJgG2UT7Uo5YTjrJsUCMChKyiSgnjxJcrWca02UniU76Kl3Menk5YzYDqIHWA0KCnkeblaGYF3DDYLBtIgLC5m5oiXqynAsqMsRvGgeosIs9BqXJuxu3ksIAr05Xaaw4bH8syOjodLswwiqUKbi5jlNYUIiFqQKiuNpAq1AmiOAbUKNSCsQFhP7jIK3aO4rQlQBfjrTi68yaatuOpt2veKlzaqTigoJ3iPeIivlnOAHhPUOUvKe1IOZJbamvTejEjme5sgqODEJevTejEjmmXRk1zs72Gi5jlNYUIiFqQKiuNpAqbeB3okk2eNHumAqLhO4rQlQBfjrTi68yaalAuYLZK7GedH1Ob5sgaqqYtwoLDfr(GujVH2TbXDxNC52KOrjxotUdsmewJMKRrHiybaA9xYtwoLDfr(GujrOoFObvEGIhPUOUvKe1IOZJbaSOrjxoJdQIgKlzaqTigoJ3iPeIivln55pulIHZ4nskHisepOg1TOH2w4rQlQBfjrTi68yaatvlXi1vrGCjditHLk15e5cHXBWFqabQfXWz8gjQlJP4ns1sJtfHjkkECRuE(d1Iy4mEJe1LXu8gPArd9aTDBGqODEJKOrjxotUdsmzxrs8QsDM0UTKNSCk7kI8bPsKl32UTKNSCk7kI8bPsIqD(Obf98hKAf6wbDObiB1UTRrHiyHrgQUOUv70GkbuGcA72sEYYPSRiYhKkjc15dnaqrp)bPwHUvqhAqRwTB7AuicwyKHQlQB1onOsafOGckEK6I6wrsulIopgaWzxrmXbH8gixYaixKenk5YzYDqIzqRnbzkTwbn0ZFYfPmLAOGLZeNNRjbzkTwbn0ZFjpz5u2ve5dsL8gWJuxu3ksIAr05Xaaw0OKlNj3bjMbTwKlzaqwgYIgvQZ(hffBIZqkMg65pqi0oVrIQemKUeVQuNj(decTZBKik0Nj7ksIxvQZe8i1f1TIKOweDEmaGZuQHcwotCEUgKlzaqwgYIgvQZ(hffBIZqkMg0QDBqcTZBKOkbdPlXRk1zI)KlsIgLC5m5oiXmO1MGSmKfnQuNbfpsDrDRijQfrNhdayQAjg5UshYUgTwaOqU2GHqVHWuuumP0GbGc5Adgc9gctjdikNpbnaO1FqC31jxUnLDfXiD9i5n0UT7Uo5YTjQAjgPUkIK3aO4rQlQBfjrTi68yaalAuYLZK7GeZGw7pfdS7bJ28aIF8X)]] )


end
