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
            cooldown = function () return talent.mindbender.enabled and 60 or 180 end,
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


    spec:RegisterPack( "Shadow", 20190401.1434, [[dauvWaqiiv6rqQ4skkjTjcQrPO6uQeRcI6vQKMLkv3cs0Ui6xQugMu4yqyzsrEMuutdI01Gi2MqQ6Bkk14uuIZjKsRtifMhKW9uH9rqoOqQ0cfsEOqQ4IkkjoPIsQwPI0oHKgQIskpvHPcPSxq)vWGP4WKwmL6XIAYiUmQnlIpRIgnLCAjVwiMTuDBcTBGFRQHlLwUsphPPt11fPTluFNaJxifDEivTEffZxrSFOgIaIgCquNHO2uderBdK2aHebsBgPn1mC4OVLHJwnhrpz4aOImCmSuYlaoAv03FLardoOF6Mz4WY9wA042TZYTsTL5x8gTet7QxpiVAIFJwI5BWHDA19zDa0goiQZquBQbIOTbsBGqIaPnJ0gZcCOPU1VWXOeJoWHvrimaAdheMMHd0bBgwk5fGnZABXuhpfDWgl3BPrJB3ol3k1wMFXB0smTRE9G8Qj(nAjMVHNIoyt0TDRo2G4o20uderl2GsSPr0gnAgj4P4POd2eDSuWjtJg4POd2GsSj6simbBgvNbzwINIoydkXMOZdI51zc246EYEOsWgk6bUgnLWrVOofIgCqlWzNHObrfben4qZE9a4i(lsG30wVEaCWa1UZeyuqhIAtq0GdgO2DMaJcoYB58wkCyNMKiJ)IK8ROK8caWHM96bWbr3ibLMzaTEa0HO2men4qZE9a4i(lsW(7oCWa1UZeyuqhIksHObhmqT7mbgfCK3Y5Tu4WonjrAPBmtDMeCRp90YPY0wSrySj)FN8caY4Vib7V7YLf1cqXgHoWgesKGncJn6m8wolPSUf4mqkT)NPSCvqeSrOdSbbCOzVEaCiwasGY6cDiQibIgCWa1UZeyuWrElN3sHdx3t2LEjYb)dKIXguGnnJntMGn5)7KxaqsTuYlii4xsGWQBjZw6EYuS5aBAcBMmbBMJn5)7KxaqsTuYlii4xsGWQBjZw6EYuS5aBqGncJn5)7KxaqsTuYlii4xsGWQBjxwulafBqb2CMjsrnAInxGdn71dGdQLsEbbb)scewDlOdrn6HObhmqT7mbgfCK3Y5Tu4Wonjrg)fj5xrj11CeSriSbrdS5k2mhBq0aBqgBSttsK29)j9uQltBXMlWHM96bWbnDxgq4n4FqujaMsHoe1zdrdoyGA3zcmk4iVLZBPWXQfjWXmWLkHqLfaBecBq0ao0Sxpaoi6gje)fb6quNfiAWbdu7otGrbh5TCElfoCTZaxkwaIndi8kzGA3zc2mzc2mhBSttsKXFrs(vusDnhbBecBqmlyZKjyJxICW)aPySbfydcKGnxGdn71dGdXcqSzaHxOdrnAHObhmqT7mbgfCK3Y5Tu4aDXg70Kez8xKKFfLPTyZKjyZCSj)FN8casQLsEbbb)scewDlz2s3tMInhyttyJWyJDAsIm(lsYVIsQR5iydkWgeibBUahA2RhahulL8ccc(LeiS6wqhIkIgq0GdgO2DMaJcoYB58wkCSArcCmdCPsiuzbWgHWgKGncJnRwKahZaxQecvssx1RhGnOaBAQbCOzVEaCqTuYliKxLAbDiQiqardoyGA3zcmk4iVLZBPWrSULA3zj5DAiTfBegBMJnZXMvlsGJzGlf)ywKbUSayJqytwPEWlrgBUInnKibBegBwTiboMbUu8Jzrg4YcGnOaBqk2CbBMmbBqxSX1odCj1sjVGGGFjH4VisgO2DMGntMGn2PjjY4Vij)kkjVaa2mzc2yNMKiJ)IK8ROK6Aoc2ie2GaPyJWyZCSPaufuo6XguGnZUb2mzc2KT09KPHKvZE9aTJncHniKn3m2CbBMmbBSttsKXFrs(vusDnhbBqXb2GaPyJWyZCSPaufuo6XguGnrFdSzYeSjBP7jtdjRM96bAhBecBqiBUzS5c2Cbo0Sxpaoelajy3vQdDiQiAcIgCWa1UZeyuWrElN3sHdY7sQLsEbbb)scTAbKllQfGIncHnifBegBiVlJvX2ARCW)0SLCzrTauSriSbPyJWyJDAsIm(lsYVIY0w4qZE9a4i(lsW)DzGdDiQiAgIgCWa1UZeyuWrElN3sHJLtwMAP2DgBegBCDpzx6Lih8pqkgBecBqk2im2GUyJRDg4sXIYl6LmqT7mbBegBqxSX1odCjr3iH4VisgO2DMahA2RhahulL8ccc(LeA1caDiQiqken4GbQDNjWOGJ8woVLchlNSm1sT7m2im246EYU0lro4FGum2ie2e9yZKjyZCSX1odCPyr5f9sgO2DMGncJnK3LulL8ccc(LeA1cixozzQLA3zS5cCOzVEaCeRIT1w5G)PzlOdrfbsGObhmqT7mbgfCOzVEaCiwasiPROhokGZ7M26Hkbo8khHk0rtcpp)FN8caY4Vib7V7Y02jtY)3jVaGuSaKGDxPUmT9cCuaN3nT1dLOitk1z4abCKT0cahiGoeverpen4qZE9a4GAPKxqqWVKqRwa4GbQDNjWOGo0HJ2LZVOT6q0GOIaIgCWa1UZeyuqhIAtq0GdgO2DMaJc6quBgIgCWa1UZeyuqhIksHObhmqT7mbgf0HOIeiAWHM96bWr771dGdgO2DMaJc6quJEiAWbdu7otGrbhFlCqzho0SxpaoI1Tu7odhXApLHJK()l2mhBMJnivIeS5k2OZWB5SuGvrB5Lg(KGBXbIkcyICvqeS5c2mRInZXgeyZvSPHSPzJniJn6m8wolPSUf4mqkT)NPSCvqeS5c2CboI1naurgoelajy3vQhCDpzNcDiQZgIgCWa1UZeyuWX3chu2Hdn71dGJyDl1UZWrS2tz4yo2GaBqj20q2y2ydYyJodVLZscRUvWT2NPYvbrWMRytdztydYyJodVLZs36tpT8GLUXm15vUkic2CbBqgBMJniWguInnKnIwSbzSrNH3YzPB9PNwEWs3yM68kxfebBqgB0z4TCwszDlWzGuA)ptz5QGiyZf4iw3aqfz4GkOn4RwEyvqeAiBX5iqhI6SardoyGA3zcmk44BHdk7WHM96bWrSULA3z4iw7PmCmhBqGnOeBAiBGuSbzSrNH3YzPB9PNwEWs3yM68kxfebBqj20q2ajydYyJodVLZsAB5CsApOTT6wE9aQCvqeS5cCeRBaOImCe7bF1YdRcIqdzlohb6quJwiAWbdu7otGrbhFlCqzho0SxpaoI1Tu7odhXApLHJ5ydcSbLytdzJzJniJn6m8woljS6wb3AFMkxfebBqj20q2OzSbzSrNH3YzPB9PNwEWs3yM68kxfebBqj20q2ajibBqgB0z4TCwsBlNts7bTTv3YRhqLRcIGnxWgKXM5ydcSbLytdzJMMn2Gm2OZWB5S0T(0tlpyPBmtDELRcIGniJn6m8wolPSUf4mqkT)NPSCvqeS5cCeRBaOImCe7bXIg8vlpSkicnKT4CeOdrfrdiAWbdu7otGrbhFlCqzho0SxpaoI1Tu7odhXApLHdeydkXMgYgiqk2Gm2OZWB5SKY6wGZaP0(FMYYvbrGJyDdavKHJypiw0aLeYwCoc0HOIaben4GbQDNjWOGJ8woVLchOl2yNMKiPwk5fK8ROmTfo0SxpaoOwk5fK8Ri0HOIOjiAWbdu7otGrbh5TCElfoOTCVhCDpzNkflajqzDXguGnnHntMGn6m8wolDRp90Ydw6gZuNx5QGiyZb20ao0Sxpaoelajy3vQdDiQiAgIgCOzVEaCeRIT1w5G)Pzl4GbQDNjWOGo0HdcNOPDhIgeveq0Gdn71dGdA1zqMHdgO2DMaJc6quBcIgCOzVEaCKs5q5SifoyGA3zcmkOdrTziAWbdu7otGrbh5TCElfoSttsK29)j9uQlxwZo2mzc24Lih8pqkgBqXb2mlnWMjtWgx3t2LwS2DlzB2XguGnnJe4qZE9a4O996bqhIksHObhmqT7mbgfC8TWbLD4qZE9a4iw3sT7mCeR9ugoiVlPwk5fee8lj0Qfq6vosboXgHXgY7YyvST2kh8pnBj9khPaNWrSUbGkYWb5DAiTf6qurcen4GbQDNjWOGJ8woVLchA2RyoWawSyk2ie2Gao0Sxpao2uqqZE9GqVOoC0lQhaQidh5oRXm0HOg9q0GdgO2DMaJcoYB58wkCOzVI5adyXIPyZb2Gao0Sxpao2uqqZE9GqVOoC0lQhaQidh0cC2zOdD4i3znMHObrfben4qZE9a4i(lsG30wVEaCWa1UZeyuqhIAtq0GdgO2DMaJcoYB58wkCyNMKiJ)IK8ROK8caWHM96bWbr3ibLMzaTEa0HO2men4GbQDNjWOGJ8woVLchOl24vosboXgHXgDgElNLU1NEA5blDJzQZRCvqeSrOdSbbCOzVEaCeRIT1w5G)PzlOdrfPq0GdgO2DMaJcoYB58wkCyNMKiT0nMPotcU1NEA5uzAlCOzVEaCiwasGY6cDiQibIgCOzVEaCe)fjy)DhoyGA3zcmkOdrn6HObhmqT7mbgfCK3Y5Tu4W19KDPxICW)aPySbfytZyZKjyJDAsIm(lsYVIsYlaahA2RhahulL8ccc(LeiS6wqhI6SHObhmqT7mbgfCK3Y5Tu4Wonjrg)fj5xrj11CeSriSbrdS5k2mhBq0aBqgBSttsK29)j9uQltBXMlWHM96bWbnDxgq4n4FqujaMsHoe1zbIgCWa1UZeyuWrElN3sHJvlsGJzGlvcHkla2ie2GOb2im2mhBiVlPwk5fee8lj0QfqUCYYul1UZyZKjyJxICW)aPySriSP5gyZf4qZE9a4GOBKq8xeOdrnAHObhA2RhahIfGyZacVWbdu7otGrbDiQiAardoyGA3zcmk4iVLZBPWbTL79GR7j7uPybibkRl2GcSjw3sT7SuSaKGDxPEW19KDkCOzVEaCiwasWURuh6qurGaIgCWa1UZeyuWrElN3sHJ5yZQfjWXmWLkHqLfaBecBqc2im2SArcCmdCPsiujjDvVEa2GcSPjS5c2mzc2SArcCmdCPsiujjDvVEa2ie20eCOzVEaCqTuYliKxLAbDiQiAcIgCWa1UZeyuWHM96bWb1sjVGGGFjHwTaWrElN3sHd0fBCTZaxkwuErVKbQDNjyJWyZCSz5KLPwQDNXgHXgx3t2LEjYb)dKIXgHWM5yZCSbLydcztyZvSPzzZydYydTL79GR7j7uPybibkRl2CbBqgBI1Tu7olPcAd(QLhwfeHgYwCoc2Gm2mhBqGnOeBAiBGOjSbzSrNH3YzjL1TaNbsP9)mLLRcIGniJn0wU3dUUNStLIfGeOSUyZfS5c2CboYOp35GR7j7uiQiGoevendrdoyGA3zcmk4qZE9a4iwfBRTYb)tZwWrElN3sHJLtwMAP2DgBegBMJnUUNSl9sKd(hifJncHnZXM5ydcS5k20SSzSbzSH2Y9EW19KDQuSaKaL1fBUGniJnX6wQDNLXEWxT8WQGi0q2IZrWgKXM5ydcS5k20qIOb2Gm2OZWB5SKY6wGZaP0(FMYYvbrWgKXgAl37bx3t2PsXcqcuwxS5c2CbBUahz0N7CW19KDkeveqhIkcKcrdoyGA3zcmk4qZE9a4iwfBRTYb)tZwWrElN3sHdY7sQLsEbbb)scTAbKlNSm1sT7m2im2mhBMJnU2zGlflkVOxYa1UZeSrySX19KDPxICW)aPySriSzo2mhBqiBGnxXMMKnWgKXgAl37bx3t2PsXcqcuwxS5c2Gm2eRBP2Dwg7bXIg8vlpSkicnKT4CeSbzSzo2eRBP2Dwg7bXIgOKq2IZrWgKXgAl37bx3t2PsXcqcuwxS5c2CbBUGnxGJm6ZDo46EYofIkcOdrfbsGObhmqT7mbgfCK3Y5Tu4Wonjrg)fj5xrzAlCOzVEaCe)fj4)UmWHoeverpen4GbQDNjWOGdn71dGdXcqcuwx4OaoVBARhQe4WRCeQqhnbhfW5DtB9qjkYKsDgoqah5TCElfoOTCVhCDpzNkflajqzDXgHWgeWr2slaCGa6qurmBiAWbdu7otGrbhA2RhahIfGes6k6HJc48UPTEOsGdVYrOcD0KWZZ)3jVaGm(lsW(7UmTDYK8)DYlaiflajy3vQltBVahfW5DtB9qjkYKsDgoqahzlTaWbcOdrfXSardo0SxpaoOwk5fee8lj0QfaoyGA3zcmkOdDOdhX8sRharTPgiI2gnJy2YMAGKzdhc0fuGtkCmRl2(RZeSbPyJM96bytVOovINchT7NuDgoqhSzyPKxa2mRTftD8u0bBSCVLgnUD7SCRuBz(fVrlX0U61dYRM43OLy(gEk6Gnr32T6ydI7yttnqeTydkXMgrB0OzKGNINIoyt0XsbNmnAGNIoydkXMOlHWeSzuDgKzjEk6GnOeBIopiMxNjyJR7j7HkbBOOh4A0uININIoyZSs0KZPotWgBo5xgBYVOT6yJnFwaQeBIU5m36uSb8auAPRysAhB0SxpGInpOJEjEQM96buz7Y5x0w9JKUsJGNQzVEav2UC(fTv)6XTK)j4PA2RhqLTlNFrB1VECttpfzGRE9a8u0bBgaTLA9o2SArWg70KeMGnuxDk2yZj)Yyt(fTvhBS5ZcqXgfqWM2Lrz77EboXMIInKhWs8un71dOY2LZVOT6xpUrbAl169a1vNINQzVEav2UC(fTv)6XT23RhGNQzVEav2UC(fTv)6XTyDl1UZ3bQiFiwasWURup46EYo9(3Eqz)ES2t5JK()785ivIKR6m8wolfyv0wEPHpj4wCGOIaMixfe5YS6CexBiBA2iRZWB5SKY6wGZaP0(FMYYvbrUCbpvZE9aQSD58lAR(1JBX6wQDNVdur(GkOn4RwEyvqeAiBX5i3)2dk73J1EkFmhbkBiBmBK1z4TCwsy1TcU1(mvUkiY1gYMqwNH3YzPB9PNwEWs3yM68kxfe5cYZrGYgYgrlY6m8wolDRp90Ydw6gZuNx5QGiiRZWB5SKY6wGZaP0(FMYYvbrUGNQzVEav2UC(fTv)6XTyDl1UZ3bQiFe7bF1YdRcIqdzloh5(3Eqz)ES2t5J5iqzdzdKISodVLZs36tpT8GLUXm15vUkickBiBGeK1z4TCwsBlNts7bTTv3YRhqLRcICbpvZE9aQSD58lAR(1JBX6wQDNVdur(i2dIfn4RwEyvqeAiBX5i3)2dk73J1EkFmhbkBiBmBK1z4TCwsy1TcU1(mvUkickBiB0mY6m8wolDRp90Ydw6gZuNx5QGiOSHSbsqcY6m8wolPTLZjP9G22QB51dOYvbrUG8CeOSHSrtZgzDgElNLU1NEA5blDJzQZRCvqeK1z4TCwszDlWzGuA)ptz5QGixWt1SxpGkBxo)I2QF94wSULA357avKpI9GyrdusiBX5i3)2dk73J1EkFGaLnKnqGuK1z4TCwszDlWzGuA)ptz5QGi4PA2RhqLTlNFrB1VECJAPKxqYVI3RKd01onjrsTuYli5xrzAlEQM96buz7Y5x0w9Rh3elajy3vQFVsoOTCVhCDpzNkflajqzDrrttMOZWB5S0T(0tlpyPBmtDELRcIC0apvZE9aQSD58lAR(1JBXQyBTvo4FA2cpfpfDWMzLOjNtDMGnCmVOhB8sKXg3IXgn7)InffB0yT6QDNL4PA2RhqpOvNbzgpvZE9a61JBPuouolsXt1SxpGE94w771dUxjh2Pjjs7()KEk1LlRzFYeVe5G)bsXO4ywAmzIR7j7slw7ULSn7OOzKGNQzVEa96XTyDl1UZ3bQiFqENgsBV)Thu2VhR9u(G8UKAPKxqqWVKqRwaPx5if4uyY7YyvST2kh8pnBj9khPaN4PA2RhqVECBtbbn71dc9I63bQiFK7SgZ3RKdn7vmhyalwmvie4PA2RhqVECBtbbn71dc9I63bQiFqlWzNVxjhA2RyoWawSy6bc8u8un71dOYCN1y(i(lsG30wVEaEQM96buzUZAmF94gr3ibLMzaTEW9k5Wonjrg)fj5xrj5faWt1SxpGkZDwJ5Rh3IvX2ARCW)0S19k5aD9khPaNcRZWB5S0T(0tlpyPBmtDELRcIi0bc8un71dOYCN1y(6XnXcqcuw37vYHDAsI0s3yM6mj4wF6PLtLPT4PA2RhqL5oRX81JBXFrc2F3Xt1SxpGkZDwJ5Rh3Owk5fee8ljqy1TUxjhUUNSl9sKd(hifJIMNmXonjrg)fj5xrj5faWt1SxpGkZDwJ5Rh3OP7YacVb)dIkbWu69k5Wonjrg)fj5xrj11CeHq046Cenq2onjrA3)N0tPUmT9cEQM96buzUZAmF94gr3iH4Vi3RKJvlsGJzGlvcHklGqiAi8CY7sQLsEbbb)scTAbKlNSm1sT78KjEjYb)dKIfQ5gxWt1SxpGkZDwJ5Rh3elaXMbeEXt1SxpGkZDwJ5Rh3elajy3vQFVsoOTCVhCDpzNkflajqzDrrSULA3zPybib7Us9GR7j7u8un71dOYCN1y(6XnQLsEbH8QuR7vYX8vlsGJzGlvcHklGqir4vlsGJzGlvcHkjPR61dqrtxMmz1Ie4yg4sLqOss6QE9aHAcpvZE9aQm3znMVECJAPKxqqWVKqRwG7z0N7CW19KD6bI7vYb66ANbUuSO8IEjdu7oteE(YjltTu7olSR7j7sVe5G)bsXcnFokriB6AZYMrM2Y9EW19KDQuSaKaL19cYX6wQDNLubTbF1YdRcIqdzlohb55iqzdzdenHSodVLZskRBbodKs7)zklxfebzAl37bx3t2PsXcqcuw3lxUGNQzVEavM7SgZxpUfRIT1w5G)PzR7z0N7CW19KD6bI7vYXYjltTu7ol8Cx3t2LEjYb)dKIfA(CexBw2mY0wU3dUUNStLIfGeOSUxqow3sT7Sm2d(QLhwfeHgYwCocYZrCTHerdK1z4TCwszDlWzGuA)ptz5QGiitB5Ep46EYovkwasGY6E5Yf8un71dOYCN1y(6XTyvST2kh8pnBDpJ(CNdUUNStpqCVsoiVlPwk5fee8lj0QfqUCYYul1UZcpFURDg4sXIYl6LmqT7mryx3t2LEjYb)dKIfA(CeYgxBs2azAl37bx3t2PsXcqcuw3lihRBP2Dwg7bXIg8vlpSkicnKT4CeKNhRBP2Dwg7bXIgOKq2IZrqM2Y9EW19KDQuSaKaL19YLlxWt1SxpGkZDwJ5Rh3I)Ie8Fxg43RKd70Kez8xKKFfLPT4PA2RhqL5oRX81JBIfGeOSU3RKdAl37bx3t2PsXcqcuwxHqCpBPf4aX9c48UPTEOefzsPoFG4EbCE30wpujhELJqf6Oj8un71dOYCN1y(6XnXcqcjDf93ZwAboqCVaoVBARhkrrMuQZhiUxaN3nT1dvYHx5iuHoAs455)7Kxaqg)fjy)DxM2ozs()o5faKIfGeS7k1LPTxWt1SxpGkZDwJ5Rh3Owk5fee8lj0QfapfpvZE9aQKwGZoFe)fjWBARxpapvZE9aQKwGZoF94gr3ibLMzaTEW9k5Wonjrg)fj5xrj5faWt1SxpGkPf4SZxpUf)fjy)DhpvZE9aQKwGZoF94MybibkR79k5WonjrAPBmtDMeCRp90YPY0wHZ)3jVaGm(lsW(7UCzrTauHoqirIW6m8wolPSUf4mqkT)NPSCvqeHoqGNQzVEavslWzNVECJAPKxqqWVKaHv36ELC46EYU0lro4FGumkAEYK8)DYlaiPwk5fee8ljqy1TKzlDpz6rttMmp)FN8casQLsEbbb)scewDlz2s3tMEGq48)DYlaiPwk5fee8ljqy1TKllQfGIIZmrkQrZl4PA2RhqL0cC25Rh3OP7YacVb)dIkbWu69k5Wonjrg)fj5xrj11CeHq046Cenq2onjrA3)N0tPUmT9cEQM96bujTaND(6XnIUrcXFrUxjhRwKahZaxQecvwaHq0apvZE9aQKwGZoF94Mybi2mGW79k5W1odCPybi2mGWRKbQDNjtMm3onjrg)fj5xrj11CeHqmltM4Lih8pqkgfiqYf8un71dOsAbo781JBulL8ccc(LeiS6w3RKd01onjrg)fj5xrzA7KjZZ)3jVaGKAPKxqqWVKaHv3sMT09KPhnjSDAsIm(lsYVIsQR5iOabsUGNQzVEavslWzNVECJAPKxqiVk16ELCSArcCmdCPsiuzbecjcVArcCmdCPsiujjDvVEakAQbEQM96bujTaND(6XnXcqc2DL63RKJyDl1UZsY70qARWZNVArcCmdCP4hZImWLfqOSs9GxI81gsKi8QfjWXmWLIFmlYaxwauG0ltMGUU2zGlPwk5fee8lje)frYa1UZKjtSttsKXFrs(vusEbGjtSttsKXFrs(vusDnhrieiv45fGQGYrpkMDJjtYw6EY0qYQzVEG2fcHS5MVmzIDAsIm(lsYVIsQR5iO4absfEEbOkOC0JIOVXKjzlDpzAiz1Sxpq7cHq2CZxUGNQzVEavslWzNVECl(lsW)DzGFVsoiVlPwk5fee8lj0QfqUSOwaQqivyY7YyvST2kh8pnBjxwulaviKkSDAsIm(lsYVIY0w8un71dOsAbo781JBulL8ccc(LeA1cCVsowozzQLA3zHDDpzx6Lih8pqkwiKkm66ANbUuSO8IEjdu7otegDDTZaxs0nsi(lIKbQDNj4PA2RhqL0cC25Rh3IvX2ARCW)0S19k5y5KLPwQDNf219KDPxICW)aPyHI(jtM7ANbUuSO8IEjdu7oteM8UKAPKxqqWVKqRwa5YjltTu7oFbpvZE9aQKwGZoF94MybiHKUI(7zlTahiUxaN3nT1dLOitk15de3lGZ7M26Hk5WRCeQqhnj888)DYlaiJ)IeS)UltBNmj)FN8casXcqc2DL6Y02l4PA2RhqL0cC25Rh3Owk5fee8lj0QfaoOTCgIAtizwGo0Hq]] )


end
