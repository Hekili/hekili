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

        potion = "unbridled_fury",

        package = "Shadow",
    } )


    spec:RegisterPack( "Shadow", 20190728, [[dC0K9aqiQsLhrHQlHcQ0MevzuOiNcf1QOGEfezwqu3IcLDrLFbPmmPWXqPwgf4zOattuvUgkjBtbvFtbLXrvQ6CuLsRdfuMhkPUhe2hkXbfvv0cPqEOOQQjIcsxefuvJefuHtsvkYkLIMjkOIUjvPO2jk0qfvv4PkAQqQUkki2QOQsFffuL9c6VuAWqDyslMIESitgPltSzu1NHKrtvDAjVwuz2s1TrLDRQFRYWvOLd8Cetx46IY2LsFNQy8uLcNNQK1RGmFfy)knKneD4KQHaz0GgS92gdZaV3zaBw1Wa4m8AuGZrnLtrjW5RCcCo9v65bohvV6NsHOdNKldKe40pIrcddn0qvHFMPlDCOrkUSUg19jGYhOrkUeAWPzw1dVPhAcNuneiJg0GT32yyg49odyZQgShoCQzH)bGZzXL)WPFrPYdnHtQqsWPXx80xPNNfNFakHeBtJVy)igjmm0qdvf(zMU0XHgP4Y6Au3NakFGgP4sOTnn(IBM19AXg49iVydAW2BxSXwSbSzy5ZB3MBtJV483xFucHHTnn(In2IZpPuHU4z1LpjUTPXxSXwC(FFRacHU4qbOKWw8lM41hQ3WTnn(In2IZ)7Bfqi0fhkaLeUO4eBCwAjloUfhfNyJZslzXE8fGSyDCSxj1Slo4SxKGarhoj1JQlq0HmYgIoCQPOUhoBVIAfq2yu3dNYRMDHcncgqgnaIoCkVA2fk0i4mbQqaLcNMz88U2RO8hGZrpppCQPOUhoPkiNvjj5j19WaYidGOdNAkQ7HZ2ROwZRhWP8QzxOqJGbKX8brhoLxn7cfAeCQPOUhotAVB1uu3B7fjGZErc7RCcCMOeyazKvq0Ht5vZUqHgbNjqfcOu40mJN35RGwHec1g(xgk)G4YgxCEloDxNEEEx7vuR51dhq406jlMfelMTJvloVfRdjGkehruq9OS0s7hQmXb0p3IzbXIzdNAkQ7HtU6PwIOayazC4q0Ht5vZUqHgbNjqfcOu4muakjCrXj24S0swmRxmdw8GbloDxNEEEhXxPNhRNdqTurdFxYxbOeYIrSydw8GblMPfNURtppVJ4R0ZJ1ZbOwQOHVl5RauczXiwm7fN3It31PNN3r8v65X65aulv0W3beoTEYIz9IrLOoo1BSyMHtnf19WjXxPNhRNdqTurdFyazCyq0Ht5vZUqHgbNjqfcOu40mJN31EfL)aCosOPClMLfZUXIrAXmTy2nwSHl2mJN3z2VJ2ZiHlBCXmdNAkQ7Htsgaipva24SCk9fcbgqg9Ei6WP8QzxOqJGZeOcbukCc0IALw5dNsPex9lMLfZUbCQPOUhoPkiNT9kkmGm6Tq0Ht5vZUqHgbNjqfcOu4m0U8HJREQP8ub4Kxn7cDXdgSyMwSzgpVR9kk)b4CKqt5wmllMT3V4bdwCuCInolTKfZ6fZMvlMz4utrDpCYvp1uEQaGbKr2nGOdNYRMDHcncotGkeqPWP3TyZmEEx7vu(dW5Ygx8GblMPfNURtppVJ4R0ZJ1ZbOwQOHVl5RauczXiwSbloVfBMXZ7AVIYFaohj0uUfZ6fZMvlMz4utrDpCs8v65X65aulv0WhgqgzZgIoCkVA2fk0i4mbQqaLcNaTOwPv(WPukXv)IzzXSAX5TyGwuR0kF4ukL4OzanQ7xmRxSbnGtnf19WjXxPNhBcOeFyazKTbq0Ht5vZUqHgbNjqfcOu4SvbLA2fh9cInBCX5TyMwmtlgOf1kTYhoURv4KpC1VywwCsjHnkozXiT4gowT48wmqlQvALpCCxRWjF4QFXSEX5BXmV4bdwS3T4q7YhoIVsppwphGABVI6Kxn7cDXdgSyZmEEx7vu(dW5ONNFXdgSyZmEEx7vu(dW5iHMYTywwm78T48wmtlUEI(v41Iz9IhwJfpyWIt(kaLqS8anf19AFXSSy2ogWGfZ8IhmyXMz88U2RO8hGZrcnLBXSgXIzNVfN3IzAX1t0VcVwmRx8WBS4bdwCYxbOeILhOPOUx7lMLfZ2XagSyMxmZWPMI6E4KREQ1SRKagqgzZai6WP8QzxOqJGZeOcbukCsVWr8v65X65au7OwVdiCA9KfZYIZ3IZBX0lCTk3ybQKnUSKVdiCA9KfZYIZ3IZBXMz88U2RO8hGZLncNAkQ7HZ2RO24aa5dyazKD(GOdNYRMDHcncotGkeqPWjq4bcXxn7YIZBXrXj24S0swmlloFloVf7Dlo0U8HJRicWlN8QzxOloVf7Dlo0U8HJQGC22ROo5vZUqHtnf19WjXxPNhRNdqTJA9WaYiBwbrhoLxn7cfAeCMaviGsHtGWdeIVA2LfN3IJItSXzPLSyww8Wx8GblMPfhAx(WXveb4LtE1Sl0fN3IPx4i(k98y9CaQDuR3beEGq8vZUSyMHtnf19WzRYnwGkzJll5ddiJShoeD4uE1SluOrWPMI6E4KREQLVREbN1hcaKng2IhoJkLJWccdYJP0DD655DTxrTMxpCzJdgKURtppVJREQ1SRKWLnYmCwFiaq2yylooHwAiWjB4m5R1dNSHbKr2ddIoCQPOUhoj(k98y9CaQDuRhoLxn7cfAemGbCsfEnRhq0HmYgIoCQPOUhojvx(KaNYRMDHcncgqgnaIoCQPOUhoZiITcHJaNYRMDHcncgqgzaeD4uE1SluOrWzcuHakfonZ45DM97O9ms4aIMIfpyWIJItSXzPLSywJyXEFJfpyWIdfGscNVO9W3nMIfZ6fZawbNAkQ7HZXlQ7HbKX8brhoLxn7cfAeCEJWjrc4utrDpC2QGsn7cC2Q9mboPx4i(k98y9CaQDuR3fvkx9OwCElMEHRv5glqLSXLL8DrLYvpk4Svb2x5e4KEbXMncdiJScIoCkVA2fk0i4mbQqaLcNAkQwXkVWvczXSSy2WPMI6E4eK9wnf192Erc4SxKW(kNaNPUOTcmGmoCi6WP8QzxOqJGZeOcbukCQPOAfR8cxjKfJyXSHtnf19Wji7TAkQ7T9IeWzViH9voboj1JQlWagW5iqshNPgq0HmYgIoCQPOUhohVOUhoLxn7cfAemGmAaeD4uE1SluOrW5ncNejGtnf19WzRck1SlWzR2Ze4KVFhyXmTyMwC(CSAXiTyDibuH484xKrbqShVn8flv5EH6a6NBXmVygUlMPfZEXiT4godg2InCX6qcOcXrefupklT0(HktCa9ZTyMxmZWzRcSVYjWjx9uRzxjHnuakjiWaYidGOdNYRMDHcncoVr4KibCQPOUhoBvqPMDboB1EMaNmTy2l2ylUHRXWwSHlwhsavioQOHVn8bNqCa9ZTyKwCdNbl2WfRdjGkex4FzO8dRVcAfsiahq)ClM5fB4IzAXSxSXwCdxdVDXgUyDibuH4c)ldLFy9vqRqcb4a6NBXgUyDibuH4iIcQhLLwA)qLjoG(5wmZWzRcSVYjWjXZOnaAfwG(5i2KVKYbdiJ5dIoCkVA2fk0i48gHtIeWPMI6E4SvbLA2f4Sv7zcCY0IzVyJT4gUg5BXgUyDibuH4c)ldLFy9vqRqcb4a6NBXgBXnCny1InCX6qcOcXrgRq4Z6wDCubvu3tCa9ZTyMHZwfyFLtGZ2WgaTclq)CeBYxs5GbKrwbrhoLxn7cfAeCEJWjrc4utrDpC2QGsn7cC2Q9mbozAXSxSXwCdxJHTydxSoKaQqCurdFB4doH4a6NBXgBXnCnyWInCX6qcOcXf(xgk)W6RGwHecWb0p3In2IB4AWkwTydxSoKaQqCKXke(SUvhhvqf19ehq)ClM5fB4IzAXSxSXwCdxddg2InCX6qcOcXf(xgk)W6RGwHecWb0p3InCX6qcOcXrefupklT0(HktCa9ZTyMHZwfyFLtGZ2WYveBa0kSa9ZrSjFjLdgqghoeD4uE1SluOrW5ncNejGtnf19WzRck1SlWzR2Ze4K9In2IB4AWoFl2WfRdjGkehruq9OS0s7hQmXb0phC2Qa7RCcC2gwUIyjuBYxs5GbKXHbrhoLxn7cfAeCMaviGsHtVBXMz88oIVspp8hGZLncNAkQ7HtIVspp8hGdgqg9Ei6WP8QzxOqJGZx5e4uhI4RaLy5VpShVD88ia4utrDpCQdr8vGsS83h2J3oEEeamGm6Tq0Ht5vZUqHgbNjqfcOu4Kmk9UnuakjioU6PwIOGfZ6fBWIhmyX6qcOcXf(xgk)W6RGwHecWb0p3IrS4gWPMI6E4KREQ1SRKagqgz3aIoCQPOUhoBvUXcujBCzjF4uE1SluOrWagWzIsGOdzKneD4uE1SluOrWzcuHakfozAXMz88U2RO8hGZrcnLBXSSydAS48wC9e9RWRfZAelMvnwmZlEWGfBMXZ7AVIYFaohj0uUfZYIzAXgm8fJ0Ih2InCXMz88oZ(D0EgjCzJlM5fpyWIzAXPmaq(Wwpr)k8YsbA9l2WfJkrDCQ3yXgUygSyMxmllUEI(v4fCQPOUho5eUd4L94T9SurTuGOCeyaz0ai6WPMI6E40SFh1E82WxSYlCEbNYRMDHcncgqgzaeD4utrDpCIktb0sF7XB1HeWf(WP8QzxOqJGbKX8brhoLxn7cfAeCMaviGsHtYO072qbOKG44QNAjIcwmliwSblEWGfd0IALw5dNsPex9lMLfp8gWPMI6E4K)szeHA1HeqfI1uuoyazKvq0Ht5vZUqHgbNjqfcOu4Kmk9UnuakjioU6PwIOGfZcIfBWIhmyXaTOwPv(WPukXv)IzzXdVbCQPOUhohZafVx1JYA2vsadiJdhIoCQPOUhodFXM9Mx2tT8hijWP8QzxOqJGbKXHbrho1uu3dNP7tYhaneQLVRCcCkVA2fk0iyaz07HOdNAkQ7Htqno2fB9wYOMe4uE1SluOrWaYO3crhoLxn7cfAeCMaviGsHtZmEExV4fZ(Duhj0uUfZ6fZa4utrDpC65aDARuVfiK71pjWaYi7gq0Ht5vZUqHgbNjqfcOu4KPfBMXZ7AVIYFaox24IZBXMz88UK)bYi2J3wpr)k8YrcnLBXSSydASyMx8GblwhsaviUK)bYi2J3wpr)k8Yb0p3IrS4gWPMI6E4mP9UvtrDVTxKao7fjSVYjWzcuHnrjWaYiB2q0Htnf19WzgrSviCe4uE1SluOrWagWzQlARarhYiBi6WPMI6E4S9kQvazJrDpCkVA2fk0iyaz0ai6WP8QzxOqJGZeOcbukCAMXZ7AVIYFaoh988WPMI6E4KQGCwLKKNu3ddiJmaIoCkVA2fk0i4mbQqaLcNE3IJkLREuloVfRdjGkex4FzO8dRVcAfsiahq)ClMfelMnCQPOUhoBvUXcujBCzjFyazmFq0Ht5vZUqHgbNjqfcOu40mJN35RGwHec1g(xgk)G4YgHtnf19Wjx9ulruamGmYki6WPMI6E4S9kQ186bCkVA2fk0iyazC4q0Ht5vZUqHgbNAkQ7HZK27wnf192Erc4SxKW(kNaNjkbgqghgeD4uE1SluOrWPMI6E4K4R0ZJ1ZbOwQOHpCMaviGsHZO4eBCwAjlM1lMblEWGfBMXZ7AVIYFaoh988WzYRuxSHcqjbbYiByaz07HOdNYRMDHcncotGkeqPWPzgpVR9kk)b4CKqt5wmllMDJfJ0IzAXSBSydxSzgpVZSFhTNrcx24Izgo1uu3dNKmaqEQaSXz5u6lecmGm6Tq0Ht5vZUqHgbNjqfcOu4eOf1kTYhoLsjU6xmllMDJfN3IzAX0lCeFLEESEoa1oQ17acpqi(Qzxw8GblokoXgNLwYIzzXmOXIzgo1uu3dNufKZ2Effgqgz3aIoCQPOUho5QNAkpvaWP8QzxOqJGbKr2SHOdNYRMDHcnco1uu3dNC1tTMDLeWzcuHakfojJsVBdfGscIJREQLikyXSEXTkOuZU44QNAn7kjSHcqjbbotEL6InuakjiqgzddiJSnaIoCkVA2fk0i4mbQqaLcNmTyGwuR0kF4ukL4QFXSSywT48wmqlQvALpCkLsC0mGg19lM1l2GfZ8IhmyXaTOwPv(WPukXrZaAu3VywwSbWPMI6E4K4R0ZJnbuIpmGmYMbq0Ht5vZUqHgbNAkQ7HtIVsppwphGAh16HZeOcbukC6Dlo0U8HJRicWlN8QzxOloVfdeEGq8vZUS48wCuCInolTKfZYIzAXmTyJTy2odwmslMbogSydxmzu6DBOausqCC1tTerblM5fB4IBvqPMDXr8mAdGwHfOFoIn5lPCl2WfZ0IzVyJT4gUgSnyXgUyDibuH4iIcQhLLwA)qLjoG(5wSHlMmk9UnuakjioU6PwIOGfZ8IzgotEL6InuakjiqgzddiJSZheD4uE1SluOrWPMI6E4Sv5glqLSXLL8HZeOcbukCceEGq8vZUS48wCuCInolTKfZYIzAXmTy2lgPfZahdwSHlMmk9UnuakjioU6PwIOGfZ8InCXTkOuZU4AdBa0kSa9ZrSjFjLBXgUyMwm7fJ0IB4y3yXgUyDibuH4iIcQhLLwA)qLjoG(5wSHlMmk9UnuakjioU6PwIOGfZ8IzgotEL6InuakjiqgzddiJSzfeD4uE1SluOrWPMI6E4Sv5glqLSXLL8HZeOcbukCsVWr8v65X65au7OwVdi8aH4RMDzX5TyMwCOD5dhxreGxo5vZUqxCElokoXgNLwYIzzXmTyMwmBxJfJ0InW1yXgUyYO072qbOKG44QNAjIcwmZl2Wf3QGsn7IRnSCfXgaTclq)CeBYxs5wSHlMPf3QGsn7IRnSCfXsO2KVKYTydxmzu6DBOausqCC1tTerblM5fZ8IzgotEL6InuakjiqgzddiJShoeD4uE1SluOrWzcuHakfonZ45DTxr5paNlBeo1uu3dNTxrTXbaYhWaYi7HbrhoLxn7cfAeCQPOUho5QNAjIcGZ6dbaYgdBXdNrLYrybHbWz9HaazJHT44eAPHaNSHZeOcbukCsgLE3gkaLeehx9ulruWIzzXSHZKVwpCYggqgz79q0Ht5vZUqHgbNAkQ7HtU6Pw(U6fCwFiaq2yylE4mQuoclimipMs31PNN31Ef1AE9WLnoyq6Uo988oU6PwZUscx2iZWz9HaazJHT44eAPHaNSHZKVwpCYggqgz7Tq0Htnf19WjXxPNhRNdqTJA9WP8QzxOqJGbmGZeOcBIsGOdzKneD4uE1SluOrW5RCcCQdr8vGsS83h2J3oEEeaCQPOUho1Hi(kqjw(7d7XBhppcagqgnaIoCkVA2fk0i4utrDpCoEPCsqQHeQnDCJzHg19wQ0wjbofEEjf2x5e4m5vQFb4(kzn7kjGbmGbC2kasDpKrdAW2BBmmdy7mGbmWa40Jc(6rrGtVjUXdecDXdFXAkQ7xCVibXTnHtYOKGmAaR8E4CeC8vxGtJV4PVspplo)aucj2MgFX(rmsyyOHgQk8ZmDPJdnsXL11OUpbu(ansXLqBBA8f3mR71InW7rEXg0GT3UyJTydyZWYN3Un3MgFX5VV(OecdBBA8fBSfNFsPcDXZQlFsCBtJVyJT48)(wbecDXHcqjHT4xmXRpuVHBBA8fBSfN)33kGqOlouakjCrXj24S0swCClokoXgNLwYI94lazX64yVsQzxCBZTPXxmdFVHKYcHUytH)aYIthNPgl2uqvpXT48ZusgdYI)7nMVc44Z6lwtrDpzX339YTnn(I1uu3tCJajDCMAGGVRKCBtJVynf19e3iqshNPgiHan(7OBtJVynf19e3iqshNPgiHanndfN8Hg19BtJV45RJe)lwmql6InZ45f6IjHgKfBk8hqwC64m1yXMcQ6jlwF6IhbIXgViQh1IlYIP3lUTPXxSMI6EIBeiPJZudKqGg51rI)fwsObzBQPOUN4gbs64m1ajeOnErD)2utrDpXncK0XzQbsiqRvbLA2fKFLtqWvp1A2vsydfGsccY3icIei3Q9mbbF)oatmLphRqshsaviop(fzuae7XBdFXsvUxOoG(5yMHltSrQHZGHzOoKaQqCerb1JYslTFOYehq)CmZ82utrDpXncK0XzQbsiqRvbLA2fKFLtqq8mAdGwHfOFoIn5lPCiFJiisGCR2ZeemX2ynCngMH6qcOcXrfn8THp4eIdOFoKA4mWqDibuH4c)ldLFy9vqRqcb4a6NJzdzITXA4A4TgQdjGkex4FzO8dRVcAfsiahq)CgQdjGkehruq9OS0s7hQmXb0phZBtnf19e3iqshNPgiHaTwfuQzxq(vobrBydGwHfOFoIn5lPCiFJiisGCR2ZeemX2ynCnYNH6qcOcXf(xgk)W6RGwHecWb0pNXA4AWkd1HeqfIJmwHWN1T64OcQOUN4a6NJ5TPMI6EIBeiPJZudKqGwRck1Sli)kNGOnSCfXgaTclq)CeBYxs5q(grqKa5wTNjiyITXA4Ammd1HeqfIJkA4BdFWjehq)CgRHRbdmuhsaviUW)Yq5hwFf0kKqaoG(5mwdxdwXkd1HeqfIJmwHWN1T64OcQOUN4a6NJzdzITXA4AyWWmuhsaviUW)Yq5hwFf0kKqaoG(5muhsavioIOG6rzPL2puzIdOFoM3MAkQ7jUrGKootnqcbATkOuZUG8RCcI2WYvelHAt(skhY3icIei3Q9mbbBJ1W1GD(muhsavioIOG6rzPL2puzIdOFUTPMI6EIBeiPJZudKqGgXxPNh(dWHCXJW7mZ45DeFLEE4paNlBCBQPOUN4gbs64m1ajeOLreBfchYVYji0Hi(kqjw(7d7XBhppcyBQPOUN4gbs64m1ajeOXvp1A2vsGCXJGmk9UnuakjioU6PwIOawBWGb6qcOcXf(xgk)W6RGwHecWb0phIgBtnf19e3iqshNPgiHaTwLBSavYgxwYFBUnn(Iz47nKuwi0flTcWRfhfNS4WxwSMIdS4ISyTvRUA2f32utrDpbbP6YNKTPMI6EcsiqlJi2keoY2utrDpbjeOnErDpYfpcZmEENz)oApJeoGOPyWGO4eBCwAjSgH33yWGqbOKW5lAp8DJPG1mGvBtnf19eKqGwRck1Sli)kNGGEbXMnI8nIGibYTAptqqVWr8v65X65au7OwVlQuU6rLh9cxRYnwGkzJll57IkLREuBtnf19eKqGgi7TAkQ7T9Iei)kNGi1fTvqU4rOPOAfR8cxjewyVn1uu3tqcbAGS3QPOU32lsG8RCccs9O6cYfpcnfvRyLx4kHGG92CBI0In(IziezXEZc3b8AXh)Iz4mlv0fZqbIYrwmOq5hl2u4pGSyVUSfRazXQ5LfloUfZR9(IVSyXh)IZVxr5pa32utrDpXLOeeCc3b8YE82EwQOwkquocYfpcMmZ45DTxr5paNJeAkhlg0iV6j6xHxSgbRAW8GbMz88U2RO8hGZrcnLJfMmy4inmdnZ45DM97O9ms4YgzEWaMszaG8HTEI(v4LLc06nevI64uVHHmGzwQNOFfETn1uu3tCjkbjeOz2VJApEB4lw5foV2MAkQ7jUeLGec0qLPaAPV94T6qc4c)TPMI6EIlrjiHan(lLreQvhsaviwtr5qU4rqgLE3gkaLeehx9ulrualimyWaGwuR0kF4ukL4QNLH3yBQPOUN4sucsiqBmdu8EvpkRzxjbYfpcYO072qbOKG44QNAjIcybHbdga0IALw5dNsPex9Sm8gBtnf19exIsqcbAHVyZEZl7Pw(dKKTPMI6EIlrjiHaT09j5dGgc1Y3vozBQPOUN4sucsiqduJJDXwVLmQjzBQPOUN4sucsiqZZb60wPElqi3RFsqU4ryMXZ76fVy2VJ6iHMYXAgSnn(IziezXHVqKfNURtpppzX1Vytj8iYVyVUmWIztIfRpDXg80fNFVIUyJUES46xSxxgyXg80fNFVIYFaUf7Xx(f71LTyFTvwC(7FGmYIp(f7n9e9RWRfRPOALTPMI6EIlrjiHaTK27wnf192ErcKFLtqKavytucYfpcMmZ45DTxr5paNlBmpZmEExY)aze7XBRNOFfE5iHMYXIbnyEWaDibuH4s(hiJypEB9e9RWlhq)CiASnn(IzOcVM1JfZR9UPMYTy(dS4mIA2LfxHWryylMHqKfF)It31PNN3Tn1uu3tCjkbjeOLreBfchzBUn1uu3tCPUOTcI2ROwbKng19Btnf19exQlARGec0OkiNvjj5j19ix8imZ45DTxr5paNJEE(TPMI6EIl1fTvqcbATk3ybQKnUSKpYfpcVlQuU6rLNoKaQqCH)LHYpS(kOviHaCa9ZXcc2Btnf19exQlARGec04QNAjIcqU4ryMXZ78vqRqcHAd)ldLFqCzJBtnf19exQlARGec0AVIAnVESn1uu3tCPUOTcsiqlP9UvtrDVTxKa5x5eejkzBQPOUN4sDrBfKqGgXxPNhRNdqTurdFKtEL6InuakjiiyJCXJikoXgNLwcRzWGbMz88U2RO8hGZrpp)2utrDpXL6I2kiHansgaipva24SCk9fcb5IhHzgpVR9kk)b4CKqt5yHDdKyIDddnZ45DM97O9ms4YgzEBA8fZqiYIzOki3IZVxrx89lo)zOlo77cHSyLsjlwbYIRpDC1JAX1Vy2nil(alUleIBBQPOUN4sDrBfKqGgvb5STxrrU4ra0IALw5dNsPex9SWUrEmrVWr8v65X65au7OwVdi8aH4RMDzWGO4eBCwAjSWGgmVn1uu3tCPUOTcsiqJREQP8ubSn1uu3tCPUOTcsiqJREQ1SRKa5KxPUydfGsccc2ix8iiJsVBdfGscIJREQLikG1TkOuZU44QNAn7kjSHcqjbzBQPOUN4sDrBfKqGgXxPNhBcOeFKlEemb0IALw5dNsPex9SWQ8aArTsR8HtPuIJMb0OUN1gW8GbaTOwPv(WPukXrZaAu3ZIbBtnf19exQlARGec0i(k98y9CaQDuRh5KxPUydfGsccc2ix8i8Uq7YhoUIiaVCYRMDHMhq4bcXxn7sErXj24S0syHjMmgBNbiXahdmKmk9UnuakjioU6PwIOaMnSvbLA2fhXZOnaAfwG(5i2KVKYzitSnwdxd2gyOoKaQqCerb1JYslTFOYehq)CgsgLE3gkaLeehx9ulruaZmVn1uu3tCPUOTcsiqRv5glqLSXLL8ro5vQl2qbOKGGGnYfpcGWdeIVA2L8IItSXzPLWctmXgjg4yGHKrP3THcqjbXXvp1sefWSHTkOuZU4AdBa0kSa9ZrSjFjLZqMyJudh7ggQdjGkehruq9OS0s7hQmXb0pNHKrP3THcqjbXXvp1sefWmZBtnf19exQlARGec0AvUXcujBCzjFKtEL6InuakjiiyJCXJGEHJ4R0ZJ1ZbO2rTEhq4bcXxn7sEmfAx(WXveb4LtE1Sl08IItSXzPLWctmX21ajdCnmKmk9UnuakjioU6PwIOaMnSvbLA2fxBy5kInaAfwG(5i2KVKYzitTkOuZU4AdlxrSeQn5lPCgsgLE3gkaLeehx9ulruaZmZ82utrDpXL6I2kiHaT2RO24aa5dKlEeMz88U2RO8hGZLnUn1uu3tCPUOTcsiqJREQLika5Ihbzu6DBOausqCC1tTerbSWg5KVwpc2ixFiaq2yylooHwAiiyJC9HaazJHT4revkhHfegSn1uu3tCPUOTcsiqJREQLVREHCYxRhbBKRpeaiBmSfhNqlneeSrU(qaGSXWw8iIkLJWccdYJP0DD655DTxrTMxpCzJdgKURtppVJREQ1SRKWLnY82utrDpXL6I2kiHanIVsppwphGAh163MBtnf19excuHnrjiYiITcHd5x5ee6qeFfOel)9H94TJNhbSn1uu3tCjqf2eLGec0YiITcHdzHNxsH9vobrYRu)cW9vYA2vsSn3MAkQ7jos9O6cI2ROwbKng19Btnf19ehPEuDbjeOrvqoRssYtQ7rU4ryMXZ7AVIYFaoh988Btnf19ehPEuDbjeO1Ef1AE9yBQPOUN4i1JQliHaTK27wnf192ErcKFLtqKOKTPXxmdHil2BUE6INIcw89lEI(IVV71Il(f71LTyusSyDXO7FzO8JfZWHcAfsiGfNFaU0I9uH)I1yXDrjXIzV4POG6rTygAP9dvMSy0bAfUTPMI6EIJupQUGec04QNAjIcqU4ryMXZ78vqRqcHAd)ldLFqCzJ5LURtppVR9kQ186HdiCA9ewqW2XQ80HeqfIJikOEuwAP9dvM4a6NJfeS3MgFXmeIS4jdpg6Inf(diloPJJ1JAXjFfGsiiV4dS4WxwCOausS4ISy18YIfh3IPL42MAkQ7jos9O6csiqJ4R0ZJ1ZbOwQOHpYfpIqbOKWffNyJZslH1myWG0DD655DeFLEESEoa1sfn8DjFfGsiimyWaMs31PNN3r8v65X65aulv0W3L8vakHGGDEP760ZZ7i(k98y9CaQLkA47acNwpH1OsuhN6nyEBQPOUN4i1JQliHansgaipva24SCk9fcb5IhHzgpVR9kk)b4CKqt5yHDdKyIDddnZ45DM97O9ms4YgzEBI0In(IziezXmufKBX53ROl((fN)m0fN9DHqwSsPKfRazX1NoU6rT46xm7gKfFGf3fcXTn1uu3tCK6r1fKqGgvb5STxrrU4ra0IALw5dNsPex9SWUX204lMHqKf7nxp1uEQawSglMT3U4dSyUdilMeAkhb5fFGfx8lo8LfhkaLel2t17lMwYIRFXDHqwC4R)IzZkIBBQPOUN4i1JQliHanU6PMYtfaYfpIq7YhoU6PMYtfGtE1Sl0bdyYmJN31EfL)aCosOPCSW27hmikoXgNLwcRzZkM3MAkQ7jos9O6csiqJ4R0ZJ1ZbOwQOHpYfpcVZmJN31EfL)aCUSXbdykDxNEEEhXxPNhRNdqTurdFxYxbOeccdYZmJN31EfL)aCosOPCSMnRyEBA8fZqiYIN(k98S48hOe)fF)IZFg6IZ(Uqilo8fGSyfilwPuYIRpDC1JYTn1uu3tCK6r1fKqGgXxPNhBcOeFKlEeaTOwPv(WPukXvplSkpGwuR0kF4ukL4OzanQ7zTbn2MgFXgPFUfh(YIN(k98SygEhGYWwC(9k6It(kaLqwm)bwSUyZkwCCloaETy9PlwBVIU4RvajDCSEul((f7n9e9RWl32utrDpXrQhvxqcbAC1tTMDLeix8iAvqPMDXrVGyZgZJjMaArTsR8HJ7Afo5dx9SKusyJItqQHJv5b0IALw5dh31kCYhU6zD(yEWaVl0U8HJ4R0ZJ1ZbO22ROo5vZUqhmWmJN31EfL)aCo655hmWmJN31EfL)aCosOPCSWoF5Xu9e9RWlwpSgdgK8vakHy5bAkQ71olSDmGbmpyGzgpVR9kk)b4CKqt5ync25lpMQNOFfEX6H3yWGKVcqjelpqtrDV2zHTJbmGzM3MAkQ7jos9O6csiqR9kQnoaq(a5Ihb9chXxPNhRNdqTJA9oGWP1tyjF5rVW1QCJfOs24Ys(oGWP1tyjF5zMXZ7AVIYFaox242utrDpXrQhvxqcbAeFLEESEoa1oQ1JCXJai8aH4RMDjVO4eBCwAjSKV88Uq7YhoUIiaVCYRMDHMN3fAx(WrvqoB7vuN8QzxOBtnf19ehPEuDbjeO1QCJfOs24Ys(ix8iacpqi(QzxYlkoXgNLwcldFWaMcTlF44kIa8YjVA2fAE0lCeFLEESEoa1oQ17acpqi(QzxyEBQPOUN4i1JQliHanU6Pw(U6fYjFTEeSrU(qaGSXWwCCcT0qqWg56dbaYgdBXJiQuoclimipMs31PNN31Ef1AE9WLnoyq6Uo988oU6PwZUscx2iZBtnf19ehPEuDbjeOr8v65X65au7OwpmGbec]] )


end
