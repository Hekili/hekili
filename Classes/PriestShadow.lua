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

            usable = function () return debuff.dispellable_magic.up end,
            handler = function ()
                removeDebuff( "target", "dispellable_magic" )
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

            usable = function () return debuff.dispellable_magic.up end,
            handler = function ()
                removeDebuff( "target", "dispellable_magic" )
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


        --[[ purify_disease = {
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

            handler = function ()
                gain( 6, "insanity" )
            end,
        },


        resurrection = {
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
            nobuff = 'shadowform',

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

            cycle = 'vampiric_touch',

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


    spec:RegisterPack( "Shadow", 20190317.2057, [[deuFTaqiHu8iirUKqkPnjKmkvvofeSkvLELI0SuvClvjTls(LQudtu5yq0Yiv6zKkmnrv6AqcBtuf9nvjmovjY5evH1bjkZtiv3tvSpHOdkKsSqiPhkKsDrvjkoPQevwPI4MQsu1ovv1qvLO0tvyQqO9QYFP0GfCyIftrpwKjJ4YO2Su6ZkQrtkNwYRjvnBP62uy3G(nWWLILR0ZHA6uDDHA7IY3HuJhsuDEsfTErvnFHW(r6d5H4niIZ3FDZHmpYPdKVqPBou8cKV0nCD2W3Ors6Lz(gqXGVXqtia03Or0zhiKdXBGbXBIVHM7nyu273ZLRfBQsaJ34YiUlEbGPvA934Yi9(gMXv3F5GN5niIZ3FDZHmpYPdKVqPBou8cK55nKyxdS3yugr7BOvecdpZBqyC6gOenm0ecann8YUfJD6euIg0CVbJYE)EUCTytvcy8gxgXDXlamTsR)gxgP30jOen8YlBsJgq(Ip0GU5qMh0WR0GU5qzOqx6e6euIgI2AcCMXOm6euIgELgIwieMqdJQZWeROtqjA4vAiAdGz86mHgCzNz3wT0awNqxq5QB0lSJpeVbUGZD(q8(J8q8gsYla8gzGIy5nUXla8gmum7m5q987VUhI3GHIzNjhQ3iTLZBj3WmUTvLbkslynueaA4nKKxa4niYQ3k4edXfaE(9xhhI3qsEbG3idueRjO73GHIzNjhQNF)Z7H4nyOy2zYH6nsB58wYnmJBBvAYMXyNjwxdepR5yvCdnefnKaGobGgQYafXAc6UAzdPGyAiYhAaPcf0qu0GKpVLZkmlBbNTKs6G5ywTcupne5dnG8gsYla8ggfKyXSSNF)rXH4nyOy2zYH6nsB58wYnCzNzx5LbBDGLumneDAqh0qerqdjaOtaOHkSMqaOTOblXsyX1ujnzNzmn8qd6sdrebn8JgsaqNaqdvynHaqBrdwILWIRPsAYoZyA4HgqsdrrdjaOtaOHkSMqaOTOblXsyX1ulBifetdrNgMteLHGYPbeUHK8caVbwtia0w0GLyjS4ANF)ZZdXBWqXSZKd1BK2Y5TKByg32QYafPfSgkSlj90qK0aYC0WuA4hnGmhn8LgmJBBvMDaG0JXUkUHgq4gsYla8g44DziHxRdSgcbYy853)xCiEdgkMDMCOEJ0woVLCJvkILZyORecbRkinejnGm3nKKxa4niYQ3MbkY53)x6q8gsYla8ggfKyYqcV3GHIzNjhQNF)ZJdXBWqXSZKd1BK2Y5TKBen0GzCBRkduKwWAOIBOHiIGg(rdjaOtaOHkSMqaOTOblXsyX1ujnzNzmn8qd6sdrrdMXTTQmqrAbRHc7sspneDAajkObeUHK8caVbwtia0w0GLyjS4ANF)rM7q8gmum7m5q9gPTCEl5gRuelNXqxjecwvqAisAaf0qu0WkfXYzm0vcHGvK4v8caPHOtd6M7gsYla8gynHaqBtRG1o)(Je5H4nyOy2zYH6nsB58wYnYKTeZoRiahBJBUHK8caVHrbjwZUG9ZV)i19q8gmum7m5q9gPTCEl5geGRWAcbG2IgSeBJuq1YgsbX0qK0qEPHOObcWvzIrtTvY6G4KMAzdPGyAisAiV0qu0GzCBRkduKwWAOIBUHK8caVrgOiwhSld9ZV)i1XH4nyOy2zYH6nsB58wYnwUDzSMy2zAikAWLDMDLxgS1bwsX0qK0qEPHOOHOHgCPZqxzuyE1PIHIzNj0qu0q0qdU0zORiYQ3MbkIIHIzNj3qsEbG3aRjeaAlAWsSnsbp)(JmVhI3GHIzNjhQ3iTLZBj3y52LXAIzNPHOObx2z2vEzWwhyjftdrsd5jnere0WpAWLodDLrH5vNkgkMDMqdrrdeGRWAcbG2IgSeBJuq1YTlJ1eZotdiCdj5faEJmXOP2kzDqCs787psuCiEdgkMDMCOEdj5faEdJcsSTDrN3OGoVBCJBR2B4vspoYhDJ6xca6eaAOkdueRjO7Q4MiIibaDcanuzuqI1Slyxf3GWnkOZ7g342YWGjL48nqEJKMuWBG887pY88q8gsYla8gynHaqBrdwITrk4nyOy2zYH65NFJMLtadtXpeV)ipeVbdfZotoup)(R7H4nyOy2zYH653FDCiEdgkMDMCOE(9pVhI3GHIzNjhQNF)rXH4nKKxa4nAaEbG3GHIzNjhQNF)ZZdXBWqXSZKd1BaAUbM9BijVaWBKjBjMD(gzspMVrBhawA4hn8JgYRcf0WuAqYN3YzfATc3Wl2cATUgBjIbKjQvG6PbeOHOvA4hnGKgMsd5u6(cA4lni5ZB5ScZYwWzlPKoyoMvRa1tdiqdiCJmzTqXGVHrbjwZUGDRl7m74ZV)V4q8gmum7m5q9gGMBGz)gsYla8gzYwIzNVrM0J5B8JgqsdVsd5u5Ebn8LgK85TCwryX1SU2cySAfOEAyknKtPln8LgK85TCw5AG4zn3QjBgJDEvRa1tdiqdFPHF0asA4vAiNkxEqdFPbjFElNvUgiEwZTAYMXyNx1kq90WxAqYN3YzfMLTGZwsjDWCmRwbQNgq4gzYAHIbFdm6gRVs52vG6X2KgN0F(9)LoeVbdfZotouVbO5gy2VHK8caVrMSLy25BKj9y(g)ObK0WR0qovU8sdFPbjFElNvUgiEwZTAYMXyNx1kq90WR0qovouqdFPbjFElNv4MY524UvAAKT8caXQvG6PbeUrMSwOyW3iZT(kLBxbQhBtACs)53)84q8gmum7m5q9gGMBGz)gsYla8gzYwIzNVrM0J5B8JgqsdVsd5u5Ebn8LgK85TCwryX1SU2cySAfOEA4vAiNkNoOHV0GKpVLZkxdepR5wnzZySZRAfOEA4vAiNkhkqbn8LgK85TCwHBkNBJ7wPPr2YlaeRwbQNgqGg(sd)ObK0WR0qovoDFbn8LgK85TCw5AG4zn3QjBgJDEvRa1tdFPbjFElNvyw2coBjL0bZXSAfOEAaHBKjRfkg8nYCRrHT(kLBxbQhBtACs)53FK5oeVbdfZotouVbO5gy2VHK8caVrMSLy25BKj9y(giPHxPHCQCiZln8LgK85TCwHzzl4SLushmhZQvG6VrMSwOyW3iZTgf2Ij2KgN0F(9hjYdXBWqXSZKd1BK2Y5TKBen0GzCBRcRjea6wWAOIBUHK8caVbwtia0TG1487psDpeVbdfZotouVrAlN3sUbUH7DRl7m7yLrbjwmllneDAqxAiIiObjFElNvUgiEwZTAYMXyNx1kq90WdnK7gsYla8ggfKyn7c2p)(JuhhI3qsEbG3itmAQTswheN0UbdfZotoup)8Bq4wjU7hI3FKhI3qsEbG3axDgM4BWqXSZKd1ZV)6EiEdj5faEJymBlNnW3GHIzNjhQNF)1XH4nyOy2zYH6nsB58wYnmJBBvMDaG0JXUAzj50qerqdUSZSR8YGToWskMgI(dn8s5OHiIGgCzNzxPXs31unjNgIonOduCdj5faEJgGxa453)8EiEdgkMDMCOEdqZnWSFdj5faEJmzlXSZ3it6X8niaxH1ecaTfnyj2gPGkVs6l4mnefnqaUktmAQTswheN0uEL0xW5BKjRfkg8niahBJBo)(JIdXBWqXSZKd1BK2Y5TKBijVYyldzJIX0qK0aYBijVaWBSXqRK8caT9c73Oxy3cfd(gPolz853)88q8gmum7m5q9gPTCEl5gsYRm2Yq2Oymn8qdiVHK8caVXgdTsYla02lSFJEHDlum4BGl4CNp)8BK6SKXhI3FKhI3qsEbG3iduelVXnEbG3GHIzNjhQNF)19q8gmum7m5q9gPTCEl5gMXTTQmqrAbRHIaqdVHK8caVbrw9wbNyiUaWZV)64q8gmum7m5q9gPTCEl5grdn4vsFbNPHOObjFElNvUgiEwZTAYMXyNx1kq90qKp0aYBijVaWBKjgn1wjRdItANF)Z7H4nyOy2zYH6nsB58wYnmJBBvAYMXyNjwxdepR5yvCZnKKxa4nmkiXIzzp)(JIdXBijVaWBKbkI1e09BWqXSZKd1ZV)55H4nyOy2zYH6nsB58wYnCzNzx5LbBDGLumneDAqh0qerqdMXTTQmqrAbRHIaqdVHK8caVbwtia0w0GLyjS4ANF)FXH4nyOy2zYH6nsB58wYnmJBBvzGI0cwdf2LKEAisAazoAykn8JgqMJg(sdMXTTkZoaq6Xyxf3qdiCdj5faEdC8UmKWR1bwdHazm(87)lDiEdgkMDMCOEJ0woVLCJvkILZyORecbRkinejnGmhnefn8JgiaxH1ecaTfnyj2gPGQLBxgRjMDMgIicAWLDMDLxgS1bwsX0qK0GoYrdiCdj5faEdIS6TzGIC(9ppoeVHK8caVHrbjMmKW7nyOy2zYH653FK5oeVbdfZotouVrAlN3sUbUH7DRl7m7yLrbjwmllneDAit2sm7SYOGeRzxWU1LDMD8nKKxa4nmkiXA2fSF(9hjYdXBWqXSZKd1BK2Y5TKB8JgwPiwoJHUsieSQG0qK0akOHOOHvkILZyORecbRiXR4fasdrNg0LgqGgIicAyLIy5mg6kHqWks8kEbG0qK0GU3qsEbG3aRjeaABAfS253FK6EiEdgkMDMCOEdj5faEdSMqaOTOblX2if8gPTCEl5grdn4sNHUYOW8QtfdfZotOHOOHF0WYTlJ1eZotdrrdUSZSR8YGToWskMgIKg(rd)OHxPbKkDPHP0Gou6Gg(sd4gU3TUSZSJvgfKyXSS0ac0WxAit2sm7ScJUX6RuUDfOESnPXj90WxA4hnGKgELgYPYHuxA4lni5ZB5ScZYwWzlPKoyoMvRa1tdFPbCd37wx2z2XkJcsSywwAabAabAaHBK0zQZwx2z2X3FKNF)rQJdXBWqXSZKd1BijVaWBKjgn1wjRdItA3iTLZBj3y52LXAIzNPHOOHF0Gl7m7kVmyRdSKIPHiPHF0WpAajnmLg0Hsh0WxAa3W9U1LDMDSYOGelMLLgqGg(sdzYwIzNvzU1xPC7kq9yBsJt6PHV0WpAajnmLgYPqMJg(sds(8woRWSSfC2skPdMJz1kq90WxAa3W9U1LDMDSYOGelMLLgqGgqGgq4gjDM6S1LDMD89h553FK59q8gmum7m5q9gsYla8gzIrtTvY6G4K2nsB58wYniaxH1ecaTfnyj2gPGQLBxgRjMDMgIIg(rd)Obx6m0vgfMxDQyOy2zcnefn4YoZUYld26alPyAisA4hn8JgqQYrdtPbDv5OHV0aUH7DRl7m7yLrbjwmllnGan8LgYKTeZoRYCRrHT(kLBxbQhBtACspn8Lg(rdzYwIzNvzU1OWwmXM04KEA4lnGB4E36YoZowzuqIfZYsdiqdiqdiqdiCJKotD26YoZo((J887psuCiEdgkMDMCOEJ0woVLCdZ42wvgOiTG1qf3Cdj5faEJmqrSoyxg6NF)rMNhI3GHIzNjhQ3qsEbG3WOGelML9gf05DJBCB1EdVs6Xr(O7nkOZ7g342YWGjL48nqEJ0woVLCdCd37wx2z2XkJcsSywwAisAa5nsAsbVbYZV)iFXH4nyOy2zYH6nKKxa4nmkiX22fDEJc68UXnUTAVHxj94iF0nQFjaOtaOHQmqrSMGURIBIiIea0ja0qLrbjwZUGDvCdc3OGoVBCJBlddMuIZ3a5nsAsbVbYZV)iFPdXBijVaWBG1ecaTfnyj2gPG3GHIzNjhQNF(53iJxCbG3FDZH8LqQRoYP0fjY84gOLfwWz8nE5mAaRZeAiV0GK8caPHEHDSIo5gnlOT68nqjAyOjeaAA4LDlg70jOenO5EdgL9(9C5AXMQeW4nUmI7IxayALw)nUmsVPtqjA4Lx2KgnG8fFObDZHmpOHxPbDZHYqHU0j0jOeneT1e4mJrz0jOen8kneTqimHggvNHjwrNGs0WR0q0gaZ41zcn4YoZUTAPbSoHUGYv0j0jOen8YGY5uSZeAWKBbltdjGHP40GjpxqSIgIwsjUXX0aeaFvtwJ24onijVaqmnaGDDQOtKKxaiw1SCcyyk(tBxW6PtKKxaiw1SCcyyk(0N3TaaHorsEbGyvZYjGHP4tFElXZgm0fVaq6euIggqPbRbCAyLIqdMXTTmHgWU4yAWKBbltdjGHP40Gjpxqmniqcn0S8Rna3l4mnuyAGaGSIorsEbGyvZYjGHP4tFEJHsdwd4wSloMorsEbGyvZYjGHP4tFE3a8caPtKKxaiw1SCcyyk(0N3zYwIzN)afd(XOGeRzxWU1LDMD8hqZdM9pzspMFA7aW(7xEvOyQKpVLZk0AfUHxSf0ADn2sedituRa1Jq06pKtZP09fFL85TCwHzzl4SLushmhZQvG6rab6ej5faIvnlNagMIp95DMSLy25pqXGFWOBS(kLBxbQhBtACs)hqZdM9pzspMF(H81CQCV4RKpVLZkclUM11waJvRa1pnNs3Vs(8woRCnq8SMB1KnJXoVQvG6r47pKVMtLlp(k5ZB5SY1aXZAUvt2mg78QwbQ)RKpVLZkmlBbNTKs6G5ywTcupc0jsYlaeRAwobmmfF6Z7mzlXSZFGIb)K5wFLYTRa1JTjnoP)dO5bZ(NmPhZp)q(AovU8(vYN3YzLRbIN1CRMSzm25vTcu)R5u5qXxjFElNv4MY524UvAAKT8caXQvG6rGorsEbGyvZYjGHP4tFENjBjMD(dum4Nm3AuyRVs52vG6X2KgN0)b08Gz)tM0J5NFiFnNk3l(k5ZB5SIWIRzDTfWy1kq9VMtLthFL85TCw5AG4zn3QjBgJDEvRa1)AovouGIVs(8woRWnLZTXDR00iB5faIvRa1JW3FiFnNkNUV4RKpVLZkxdepR5wnzZySZRAfO(Vs(8woRWSSfC2skPdMJz1kq9iqNijVaqSQz5eWWu8PpVZKTeZo)bkg8tMBnkSftSjnoP)dO5bZ(NmPhZpiFnNkhY8(vYN3YzfMLTGZwsjDWCmRwbQNorsEbGyvZYjGHP4tFEJ1ecaDlyn(uTprJzCBRcRjea6wWAOIBOtKKxaiw1SCcyyk(0N3gfKyn7c2)uTp4gU3TUSZSJvgfKyXSSrx3iIqYN3YzLRbIN1CRMSzm25vTcu)to6ej5faIvnlNagMIp95DMy0uBLSoioPrNqNGs0WldkNtXotOboJxDsdEzW0GRX0GKCWsdfMgKmP6IzNv0jsYlae)GRodtmDIK8caXtFEhJzB5SbMorsEbG4PpVBaEbGFQ2hZ42wLzhai9ySRwwsEer4YoZUYld26alP4O)8s5Iicx2z2vAS0DnvtYJUoqbDIK8caXtFENjBjMD(dum4hcWX24MpGMhm7FYKEm)qaUcRjeaAlAWsSnsbvEL0xW5OiaxLjgn1wjRdItAkVs6l4mDIK8caXtFEVXqRK8caT9c7FGIb)K6SKXFQ2hj5vgBziBumosK0jsYlaep959gdTsYla02lS)bkg8dUGZD(t1(ijVYyldzJIXpiPtOtKKxaiwL6SKXpzGIy5nUXlaKorsEbGyvQZsgp95nrw9wbNyiUaWpv7JzCBRkduKwWAOia0q6ej5faIvPolz80N3zIrtTvY6G4K2NQ9jA8kPVGZrj5ZB5SY1aXZAUvt2mg78QwbQpYhK0jsYlaeRsDwY4PpVnkiXIzz)uTpMXTTknzZySZeRRbIN1CSkUHorsEbGyvQZsgp95DgOiwtq3PtKKxaiwL6SKXtFEJ1ecaTfnyjwclU2NQ9XLDMDLxgS1bwsXrxhreHzCBRkduKwWAOia0q6ej5faIvPolz80N344DziHxRdSgcbYy8NQ9XmUTvLbkslynuyxs6JezUP)qM7RzCBRYSdaKEm2vXniqNijVaqSk1zjJN(8MiREBgOiFQ2NvkILZyORecbRkyKiZf1pcWvynHaqBrdwITrkOA52LXAIzNJicx2z2vEzWwhyjfhPoYHaDIK8caXQuNLmE6ZBJcsmziHx6ej5faIvPolz80N3gfKyn7c2)uTp4gU3TUSZSJvgfKyXSSrpt2sm7SYOGeRzxWU1LDMDmDIK8caXQuNLmE6ZBSMqaOTPvWAFQ2NFRuelNXqxjecwvWirruRuelNXqxjecwrIxXlam66IqerSsrSCgdDLqiyfjEfVaWi1LorsEbGyvQZsgp95nwtia0w0GLyBKc(jPZuNTUSZSJFq(PAFIgx6m0vgfMxDQyOy2zsu)wUDzSMy25OCzNzx5LbBDGLuCK)(9ksLUt1HshFXnCVBDzNzhRmkiXIzzr4BMSLy2zfgDJ1xPC7kq9yBsJt6)(d5R5u5qQ7xjFElNvyw2coBjL0bZXSAfO(V4gU3TUSZSJvgfKyXSSiGac0jsYlaeRsDwY4PpVZeJMARK1bXjTpjDM6S1LDMD8dYpv7ZYTlJ1eZoh1px2z2vEzWwhyjfh5VFiNQdLo(IB4E36YoZowzuqIfZYIW3mzlXSZQm36RuUDfOESnPXj9F)HCAofYCFL85TCwHzzl4SLushmhZQvG6)IB4E36YoZowzuqIfZYIaciqNijVaqSk1zjJN(8otmAQTswheN0(K0zQZwx2z2Xpi)uTpeGRWAcbG2IgSeBJuq1YTlJ1eZoh1VFU0zORmkmV6uXqXSZKOCzNzx5LbBDGLuCK)(HuLBQUQCFXnCVBDzNzhRmkiXIzzr4BMSLy2zvMBnkS1xPC7kq9yBsJt6)(lt2sm7SkZTgf2Ij2KgN0)f3W9U1LDMDSYOGelMLfbeqab6ej5faIvPolz80N3zGIyDWUm0)uTpMXTTQmqrAbRHkUHorsEbGyvQZsgp95Trbjwml7NQ9b3W9U1LDMDSYOGelMLnsKFsAsbFq(PGoVBCJBlddMuIZpi)uqN3nUXTv7Jxj94iF0LorsEbGyvQZsgp95Trbj22UOZpjnPGpi)uqN3nUXTLHbtkX5hKFkOZ7g342Q9XRKECKp6g1Vea0ja0qvgOiwtq3vXnrerca6eaAOYOGeRzxWUkUbb6ej5faIvPolz80N3ynHaqBrdwITrkiDcDIK8caXkCbN78tgOiwEJB8caPtKKxaiwHl4CNN(8MiRERGtmexa4NQ9XmUTvLbkslynueaAiDIK8caXkCbN780N3zGIynbDNorsEbGyfUGZDE6ZBJcsSyw2pv7JzCBRst2mg7mX6AG4znhRIBIkbaDcanuLbkI1e0D1YgsbXr(GuHIOK85TCwHzzl4SLushmhZQvG6J8bjDIK8caXkCbN780N3ynHaqBrdwILWIR9PAFCzNzx5LbBDGLuC01rerKaGobGgQWAcbG2IgSelHfxtL0KDMXp6gre)saqNaqdvynHaqBrdwILWIRPsAYoZ4hKrLaGobGgQWAcbG2IgSelHfxtTSHuqC0NteLHGYrGorsEbGyfUGZDE6ZBC8UmKWR1bwdHazm(t1(yg32QYafPfSgkSlj9rIm30FiZ91mUTvz2baspg7Q4geOtKKxaiwHl4CNN(8MiREBgOiFQ2NvkILZyORecbRkyKiZrNijVaqScxW5op95TrbjMmKWlDIK8caXkCbN780N3ynHaqBrdwILWIR9PAFIgZ42wvgOiTG1qf3ere)saqNaqdvynHaqBrdwILWIRPsAYoZ4hDJYmUTvLbkslynuyxs6JosuGaDIK8caXkCbN780N3ynHaqBtRG1(uTpRuelNXqxjecwvWirruRuelNXqxjecwrIxXlam66MJorsEbGyfUGZDE6ZBJcsSMDb7FQ2NmzlXSZkcWX24g6ej5faIv4co35PpVZafX6GDzO)PAFiaxH1ecaTfnyj2gPGQLnKcIJmVrraUktmAQTswheN0ulBifehzEJYmUTvLbkslynuXn0jsYlaeRWfCUZtFEJ1ecaTfnyj2gPGFQ2NLBxgRjMDokx2z2vEzWwhyjfhzEJkACPZqxzuyE1PIHIzNjrfnU0zORiYQ3MbkIIHIzNj0jsYlaeRWfCUZtFENjgn1wjRdItAFQ2NLBxgRjMDokx2z2vEzWwhyjfhzEgre)CPZqxzuyE1PIHIzNjrraUcRjeaAlAWsSnsbvl3Umwtm7mc0jsYlaeRWfCUZtFEBuqITTl68tstk4dYpf05DJBCBzyWKsC(b5Nc68UXnUTAF8kPhh5JUr9lbaDcanuLbkI1e0DvCterKaGobGgQmkiXA2fSRIBqGorsEbGyfUGZDE6ZBSMqaOTOblX2if8g4goD)1ffV05NFha]] )


end
