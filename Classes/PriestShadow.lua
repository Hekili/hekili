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


    spec:RegisterPack( "Shadow", 20190721.2332, [[dCuJ9aqifeEKiuxIcK0MevzuOiNcf1QqP6vqKzbrDlri7Ik)cszysHJHswMi4zkOMMiQUgkW2Oa13qbzCki15erP1rbI5rbCpiSpukhubrAHuqpubjtefuDrkqQgjfiHtkIISsPOzsbs0nfrrTtuOHQGiEQIMkKQRIckBvbr9vkqk7f0FP0GH6WKwmf9yQAYiDzInJQ(mKmAr60sETOYSLQBJk7wv)wLHRqlh45iMUW1fLTlL(ofA8IOW5frwVOQMVcSFLgYcIoCs1qGmMqdwjBdgkbwUego5miHHgoJKgf4Cu95uucC(kNaNZuLEgHZrnP(Pui6Wj5YaEbotJyKyqqdnuvKMz68hhAKIlRRrDVhO8bAKIZJgCAMv9iz6HMWjvdbYycnyLSnyOey5sy4KpCYtoCQzr6bGZzXnuWzArPYdnHtQq8WzIx8mvPNXfpKakHeBZeV40igjge0qdvfPzMo)XHgP4Y6Au37bkFGgP48OTnt8IBM1tAXjWc5fNqdwj7It0IzLSgKHBSn3MjEXdvQ(OeIbzBM4fNOfpKsPcDXZQlVxCBZeV4eT4H6(wbecDXHcqjHT4xmjPp0KHBBM4fNOfpu33kGqOlouakjCrXj24S0swCClokoXgNLwYInMkazX64yV8QzxCWzVibbIoCsQhvxGOdzKfeD4u9rDpC2Ef1kGSXOUhoLxn7cfAimGmMaeD4uE1SluOHWPhuHakfonZ45DTxr5paNJEgF4u9rDpCsvqoRs8YtQ7HbKXHHOdNQpQ7HZ2ROwZRhWP8QzxOqdHbKXKdrhoLxn7cfAiCQ(OUho9AVBvFu3B7fjGZErc7RCcC6PeyazKbq0Ht5vZUqHgcNEqfcOu40mJN3LQGwHec1gPxgQ0G4YgxCEl2FxNEgFx7vuR51dhq406jlMnelMLJbloVfR5lGkehruq9OS0s7hQmXb0p3IzdXIzbNQpQ7HtU6PwIOayaz0GHOdNYRMDHcneo9GkeqPWzOaus4IItSXzPLSydS4Hx8Gbl2FxNEgFhjvPNrRXdqTurJuNpvbOeYIrS4ew8GblMPf7VRtpJVJKQ0ZO14bOwQOrQZNQauczXiwmRfN3I931PNX3rsv6z0A8aulv0i1beoTEYInWIr5PoonzSyMHt1h19WjjvPNrRXdqTurJuyazKHGOdNYRMDHcneo9GkeqPWPzgpVR9kk)b4CKq95wmBlMvJfJ0IzAXSASy2xSzgpVZSFhTNrcx24IzgovFu3dNKmaqEQaSXz5u6lecmGmo0q0Ht5vZUqHgcNEqfcOu4eOf1kTYhoLsjU6xmBlMvd4u9rDpCsvqoB7vuyazmzHOdNYRMDHcneo9GkeqPWzOD5dhx9ut5PcWjVA2f6IhmyXmTyZmEEx7vu(dW5iH6ZTy2wmRHEXdgS4O4eBCwAjl2alMfdwmZWP6J6E4KREQP8ubadiJSAarhoLxn7cfAiC6bviGsHZHyXMz88U2RO8hGZLnU4bdwmtl2FxNEgFhjvPNrRXdqTurJuNpvbOeYIrS4ewCEl2mJN31EfL)aCosO(Cl2alMfdwmZWP6J6E4KKQ0ZO14bOwQOrkmGmYIfeD4uE1SluOHWPhuHakfobArTsR8HtPuIR(fZ2IzWIZBXaTOwPv(WPukXrZaAu3VydS4eAaNQpQ7HtsQspJwpqjPWaYiReGOdNYRMDHcneo9GkeqPWzRck1Slo6feB24IZBXmTyMwmqlQvALpCCxRWjF4QFXSTyVscBuCYIrAXnCmyX5TyGwuR0kF44UwHt(Wv)InWIt(IzEXdgS4HyXH2LpCKuLEgTgpa12Ef1jVA2f6IhmyXMz88U2RO8hGZrpJ)IhmyXMz88U2RO8hGZrc1NBXSTywjFX5TyMwC9e9RiPfBGfZqnw8Gbl2NQaucXYduFu3R9fZ2Iz5gE4fZ8IhmyXMz88U2RO8hGZrc1NBXgaXIzL8fN3IzAX1t0VIKwSbwSb3yXdgSyFQcqjelpq9rDV2xmBlMLB4HxmZlMz4u9rDpCYvp1A2vsadiJSggIoCkVA2fk0q40dQqaLcN0lCKuLEgTgpa1oQ17acNwpzXST4KV48wm9cxRYnwGYBJlZN6acNwpzXST4KV48wSzgpVR9kk)b4CzJWP6J6E4S9kQnoaq(agqgzLCi6WP8QzxOqdHtpOcbukCceEGqsvZUS48wCuCInolTKfZ2It(IZBXdXIdTlF44kIasYjVA2f6IZBXdXIdTlF4OkiNT9kQtE1Slu4u9rDpCssv6z0A8au7OwpmGmYIbq0Ht5vZUqHgcNEqfcOu4ei8aHKQMDzX5T4O4eBCwAjlMTfBWlEWGfZ0IdTlF44kIasYjVA2f6IZBX0lCKuLEgTgpa1oQ17acpqiPQzxwmZWP6J6E4Sv5glq5TXL5tHbKrwgmeD4uE1SluOHWP6J6E4KREQLVRjbN1hcaKng2IhoJYNJWgIeYJj)DD6z8DTxrTMxpCzJdg4VRtpJVJREQ1SRKWLnYmCwFiaq2yylooHwAiWjl40NQ1dNSGbKrwmeeD4u9rDpCssv6z0A8au7OwpCkVA2fk0qyad4Kk8AwpGOdzKfeD4u9rDpCsQU8EboLxn7cfAimGmMaeD4u9rDpCMreBfchboLxn7cfAimGmomeD4uE1SluOHWPhuHakfonZ45DM97O9ms4aI6JfpyWIJItSXzPLSydGyXdDJfpyWIdfGscxQO9i1n6JfBGfpmdGt1h19W54f19WaYyYHOdNYRMDHcneoVr4KibCQ(OUhoBvqPMDboB1EMaN0lCKuLEgTgpa1oQ17IYNREuloVftVW1QCJfO824Y8PUO85QhfC2Qa7RCcCsVGyZgHbKrgarhoLxn7cfAiC6bviGsHt1hvRyLx4kHSy2wml4u9rDpCcYER6J6EBVibC2lsyFLtGtFx0wbgqgnyi6WP8QzxOqdHtpOcbukCQ(OAfR8cxjKfJyXSGt1h19Wji7TQpQ7T9IeWzViH9voboj1JQlWagW5iq8hNPgq0HmYcIoCQ(OUhohVOUhoLxn7cfAimGmMaeD4uE1SluOHW5ncNejGt1h19WzRck1SlWzR2Ze4KVFhyXmTyMwCYDmyXiTynFbuH4mMwKrbqShVnsflv5EH6a6NBXmVydQlMPfZAXiT4gUeyOfZ(I18fqfIJikOEuwAP9dvM4a6NBXmVyMHZwfyFLtGtU6PwZUscBOausqGbKXHHOdNYRMDHcneoVr4KibCQ(OUhoBvqPMDboB1EMaNmTywlorlUHRbdTy2xSMVaQqCurJuBKcoH4a6NBXiT4gUewm7lwZxaviUi9YqLg2uf0kKqaoG(5wmZlM9fZ0IzT4eT4gUgj7IzFXA(cOcXfPxgQ0WMQGwHecWb0p3IzFXA(cOcXrefupklT0(HktCa9ZTyMHZwfyFLtGtIXrBa0kSa9ZrS(uXNdgqgtoeD4uE1SluOHW5ncNejGt1h19WzRck1SlWzR2Ze4KPfZAXjAXnCns(IzFXA(cOcXfPxgQ0WMQGwHecWb0p3It0IB4AWGfZ(I18fqfIJmwHWN1T64OcQOUN4a6NBXmdNTkW(kNaNTHnaAfwG(5iwFQ4ZbdiJmaIoCkVA2fk0q48gHtIeWP6J6E4SvbLA2f4Sv7zcCY0IzT4eT4gUgm0IzFXA(cOcXrfnsTrk4eIdOFUfNOf3W1y4fZ(I18fqfIlsVmuPHnvbTcjeGdOFUfNOf3W1GbmyXSVynFbuH4iJvi8zDRooQGkQ7joG(5wmZlM9fZ0IzT4eT4gUgjWqlM9fR5lGkexKEzOsdBQcAfsiahq)ClM9fR5lGkehruq9OS0s7hQmXb0p3IzgoBvG9voboBdlxrSbqRWc0phX6tfFoyaz0GHOdNYRMDHcneoVr4KibCQ(OUhoBvqPMDboB1EMaNSwCIwCdxdwjFXSVynFbuH4iIcQhLLwA)qLjoG(5GZwfyFLtGZ2WYvelHA9PIphmGmYqq0Ht5vZUqHgcNEqfcOu4CiwSzgpVJKQ0Zi)b4CzJWP6J6E4KKQ0Zi)b4GbKXHgIoCkVA2fk0q48vobo18jPkqjw(7d7XBhpJcaovFu3dNA(KufOel)9H94TJNrbadiJjleD4uE1SluOHWPhuHakfojJsVBdfGscIJREQLikyXgyXjS4bdwSMVaQqCr6LHknSPkOviHaCa9ZTyelUbCQ(OUho5QNAn7kjGbKrwnGOdNQpQ7HZwLBSaL3gxMpfoLxn7cfAimGbC6Pei6qgzbrhoLxn7cfAiC6bviGsHtMwSzgpVR9kk)b4CKq95wmBloHgloVfxpr)ksAXgaXIzqJfZ8IhmyXMz88U2RO8hGZrc1NBXSTyMwCcmyXiTygSy2xSzgpVZSFhTNrcx24IzEXdgSyMwSpdaKpS1t0VIKSuGw)IzFXO8uhNMmwm7lE4fZ8IzBX1t0VIKGt1h19WjNWDGKShVTN5lQLceLJadiJjarhovFu3dNM97O2J3gPIvEHlj4uE1SluOHWaY4Wq0Ht1h19WjQmfql9ThVvZxaxKcNYRMDHcnegqgtoeD4uE1SluOHWPhuHakfojJsVBdfGscIJREQLikyXSHyXjS4bdwmqlQvALpCkLsC1Vy2wSb3aovFu3dN8NpJiuRMVaQqSMIYbdiJmaIoCkVA2fk0q40dQqaLcNKrP3THcqjbXXvp1sefSy2qS4ew8GblgOf1kTYhoLsjU6xmBl2GBaNQpQ7HZXmqXNu9OSMDLeWaYObdrhovFu3dNrQyZEZl7Pw(d4f4uE1SluOHWaYidbrhovFu3dN(79YhaneQLVRCcCkVA2fk0qyazCOHOdNQpQ7Htqno2fB9wYO6f4uE1SluOHWaYyYcrhoLxn7cfAiC6bviGsHtZmEExV4fZ(DuhjuFUfBGfpmCQ(OUhonEGoTvQ3ceY967fyazKvdi6WP8QzxOqdHtpOcbukCY0InZ45DTxr5paNlBCX5TyZmEENp9aze7XBRNOFfj5iH6ZTy2wCcnwmZlEWGfR5lGkeNp9aze7XBRNOFfj5a6NBXiwCd4u9rDpC61E3Q(OU32lsaN9Ie2x5e40dQW6PeyazKfli6WP6J6E4mJi2keocCkVA2fk0qyad403fTvGOdzKfeD4u9rDpC2Ef1kGSXOUhoLxn7cfAimGmMaeD4uE1SluOHWPhuHakfonZ45DTxr5paNJEgF4u9rDpCsvqoRs8YtQ7HbKXHHOdNYRMDHcneo9GkeqPW5qS4O85Qh1IZBXA(cOcXfPxgQ0WMQGwHecWb0p3IzdXIzbNQpQ7HZwLBSaL3gxMpfgqgtoeD4uE1SluOHWPhuHakfonZ45DPkOviHqTr6LHkniUSr4u9rDpCYvp1sefadiJmaIoCQ(OUhoBVIAnVEaNYRMDHcnegqgnyi6WP8QzxOqdHt1h19WPx7DR6J6EBVibC2lsyFLtGtpLadiJmeeD4uE1SluOHWP6J6E4KKQ0ZO14bOwQOrkC6bviGsHZO4eBCwAjl2alE4fpyWInZ45DTxr5paNJEgF40NKVl2qbOKGazKfmGmo0q0Ht5vZUqHgcNEqfcOu40mJN31EfL)aCosO(ClMTfZQXIrAXmTywnwm7l2mJN3z2VJ2ZiHlBCXmdNQpQ7Htsgaipva24SCk9fcbgqgtwi6WP8QzxOqdHtpOcbukCc0IALw5dNsPex9lMTfZQXIZBXmTy6fosQspJwJhGAh16DaHhiKu1SllEWGfhfNyJZslzXST4HBSyMHt1h19Wjvb5STxrHbKrwnGOdNQpQ7HtU6PMYtfaCkVA2fk0qyazKfli6WP8QzxOqdHt1h19Wjx9uRzxjbC6bviGsHtYO072qbOKG44QNAjIcwSbwCRck1SloU6PwZUscBOausqGtFs(UydfGsccKrwWaYiReGOdNYRMDHcneo9GkeqPWjtlgOf1kTYhoLsjU6xmBlMbloVfd0IALw5dNsPehndOrD)InWItyXmV4bdwmqlQvALpCkLsC0mGg19lMTfNaCQ(OUhojPk9mA9aLKcdiJSggIoCkVA2fk0q4u9rDpCssv6z0A8au7OwpC6bviGsHZHyXH2LpCCfraj5Kxn7cDX5TyGWdesQA2LfN3IJItSXzPLSy2wmtlMPfNOfZYLWIrAXd7gEXSVyYO072qbOKG44QNAjIcwmZlM9f3QGsn7IJyC0gaTclq)CeRpv85wm7lMPfZAXjAXnCnyLWIzFXA(cOcXrefupklT0(HktCa9ZTy2xmzu6DBOausqCC1tTerblM5fZmC6tY3fBOausqGmYcgqgzLCi6WP8QzxOqdHt1h19WzRYnwGYBJlZNcNEqfcOu4ei8aHKQMDzX5T4O4eBCwAjlMTfZ0IzAXSwmslEy3WlM9ftgLE3gkaLeehx9ulruWIzEXSV4wfuQzxCTHnaAfwG(5iwFQ4ZTy2xmtlM1IrAXnCSASy2xSMVaQqCerb1JYslTFOYehq)ClM9ftgLE3gkaLeehx9ulruWIzEXmdN(K8DXgkaLeeiJSGbKrwmaIoCkVA2fk0q4u9rDpC2QCJfO824Y8PWPhuHakfoPx4iPk9mAnEaQDuR3beEGqsvZUS48wmtlo0U8HJRicijN8QzxOloVfhfNyJZslzXSTyMwmtlMLRXIrAXj4ASy2xmzu6DBOausqCC1tTerblM5fZ(IBvqPMDX1gwUIydGwHfOFoI1Nk(ClM9fZ0IBvqPMDX1gwUIyjuRpv85wm7lMmk9UnuakjioU6PwIOGfZ8IzEXmdN(K8DXgkaLeeiJSGbKrwgmeD4uE1SluOHWPhuHakfonZ45DTxr5paNlBeovFu3dNTxrTXbaYhWaYilgcIoCkVA2fk0q4u9rDpCYvp1sefaN1hcaKng2IhoJYNJWgIeGZ6dbaYgdBXXj0sdbozbNEqfcOu4Kmk9UnuakjioU6PwIOGfZ2IzbN(uTE4KfmGmYAOHOdNYRMDHcneovFu3dNC1tT8Dnj4S(qaGSXWw8Wzu(Ce2qKqEm5VRtpJVR9kQ186HlBCWa)DD6z8DC1tTMDLeUSrMHZ6dbaYgdBXXj0sdbozbN(uTE4KfmGmYkzHOdNQpQ7HtsQspJwJhGAh16Ht5vZUqHgcdyaNEqfwpLarhYili6WP8QzxOqdHZx5e4uZNKQaLy5VpShVD8mka4u9rDpCQ5tsvGsS83h2J3oEgfamGmMaeD4uE1SluOHWP6J6E4C885KGu5luR)4gZcnQ7TuPT8cCk88IpSVYjWPpjF)cW9L3A2vsadyad4SvaK6EiJj0GvY2GHsGLlHHhgonQGVEue4mzIB8aHqxSbVy1h19lUxKG42MWjzu8qgtGbdnCoco(QlWzIx8mvPNXfpKakHeBZeV40igjge0qdvfPzMo)XHgP4Y6Au37bkFGgP48OTnt8IBM1tAXjWc5fNqdwj7It0IzLSgKHBSn3MjEXdvQ(OeIbzBM4fNOfpKsPcDXZQlVxCBZeV4eT4H6(wbecDXHcqjHT4xmjPp0KHBBM4fNOfpu33kGqOlouakjCrXj24S0swCClokoXgNLwYInMkazX64yV8QzxCBZTzIxSb9KH4ZcHUytH)aYI9hNPgl2uqvpXT4HuVxgdYI)7tuQc44Z6lw9rDpzX33tYTnt8IvFu3tCJaXFCMAGGVRKCBZeVy1h19e3iq8hNPgiHan(7OBZeVy1h19e3iq8hNPgiHanndfN8Hg19BZeV45RJK0lwmql6InZ45f6IjHgKfBk8hqwS)4m1yXMcQ6jlwF6IhbsIgViQh1IlYIP3lUTzIxS6J6EIBei(JZudKqGg51rs6fwsObzBQ(OUN4gbI)4m1ajeOnErD)2u9rDpXnce)XzQbsiqRvbLA2fKFLtqWvp1A2vsydfGsccY3icIei3Q9mbbF)oatmLChdqsZxavioJPfzuae7XBJuXsvUxOoG(5y2GktSqQHlbgIDnFbuH4iIcQhLLwA)qLjoG(5yM5TP6J6EIBei(JZudKqGwRck1Sli)kNGGyC0gaTclq)CeRpv85q(grqKa5wTNjiyIvIA4AWqSR5lGkehv0i1gPGtioG(5qQHlb218fqfIlsVmuPHnvbTcjeGdOFoMzNjwjQHRrYYUMVaQqCr6LHknSPkOviHaCa9ZXUMVaQqCerb1JYslTFOYehq)CmVnvFu3tCJaXFCMAGec0AvqPMDb5x5eeTHnaAfwG(5iwFQ4ZH8nIGibYTAptqWeRe1W1i5SR5lGkexKEzOsdBQcAfsiahq)CjQHRbdyxZxavioYyfcFw3QJJkOI6EIdOFoM3MQpQ7jUrG4potnqcbATkOuZUG8RCcI2WYveBa0kSa9ZrS(uXNd5BebrcKB1EMGGjwjQHRbdXUMVaQqCurJuBKcoH4a6NlrnCngMDnFbuH4I0ldvAytvqRqcb4a6NlrnCnyadyxZxavioYyfcFw3QJJkOI6EIdOFoMzNjwjQHRrcme7A(cOcXfPxgQ0WMQGwHecWb0ph7A(cOcXrefupklT0(HktCa9ZX82u9rDpXnce)XzQbsiqRvbLA2fKFLtq0gwUIyjuRpv85q(grqKa5wTNjiyLOgUgSso7A(cOcXrefupklT0(HktCa9ZTnvFu3tCJaXFCMAGec0iPk9mYFaoKlEedHzgpVJKQ0Zi)b4CzJBt1h19e3iq8hNPgiHaTmIyRq4q(vobHMpjvbkXYFFypE74zuaBt1h19e3iq8hNPgiHanU6PwZUscKlEeKrP3THcqjbXXvp1sefyGegmqZxaviUi9YqLg2uf0kKqaoG(5q0yBQ(OUN4gbI)4m1ajeO1QCJfO824Y8PBZTzIxSb9KH4ZcHUyPvajT4O4KfhPYIvFCGfxKfRTA1vZU42MQpQ7jiivxEVSnvFu3tqcbAzeXwHWr2MQpQ7jiHaTXlQ7rU4ryMXZ7m73r7zKWbe1hdgefNyJZslXaig6gdgekaLeUur7rQB0hgyygSnvFu3tqcbATkOuZUG8RCcc6feB2iY3icIei3Q9mbb9chjvPNrRXdqTJA9UO85QhvE0lCTk3ybkVnUmFQlkFU6rTnvFu3tqcbAGS3Q(OU32lsG8RCccFx0wb5IhH6JQvSYlCLqyJ12u9rDpbjeObYER6J6EBVibYVYjii1JQlix8iuFuTIvEHReccwBZTzIxmdJilozw4oqsl(4xSbLz(IUygoquoYIbfQ0yXMc)bKfN0LTyfilwnVSyXXTyET3x8Lfl(4x8q(kk)b42MQpQ7jopLGGt4oqs2J32Z8f1sbIYrqU4rWKzgpVR9kk)b4CKq95ylHg5vpr)ksYaiyqdMhmWmJN31EfL)aCosO(CSXucmajgWUzgpVZSFhTNrcx2iZdgWKpdaKpS1t0VIKSuGwp7O8uhNMmyFyMzREI(vK02u9rDpX5PeKqGMz)oQ94TrQyLx4sABQ(OUN48ucsiqdvMcOL(2J3Q5lGls3MQpQ7jopLGec04pFgrOwnFbuHynfLd5Ihbzu6DBOausqCC1tTerbSHiHbdaArTsR8HtPuIRE2m4gBt1h19eNNsqcbAJzGIpP6rzn7kjqU4rqgLE3gkaLeehx9ulruaBisyWaGwuR0kF4ukL4QNndUX2u9rDpX5PeKqGwKk2S38YEQL)aEzBQ(OUN48ucsiqZFVx(aOHqT8DLt2MQpQ7jopLGec0a14yxS1BjJQx2MQpQ7jopLGec0mEGoTvQ3ceY967fKlEeMz88UEXlM97OosO(Cgy4TzIxmdJilosfISy)DD6z8jlU(fBkHrr(fN0LbwmlsSy9PloHNU4H8v0fB41Jfx)It6YaloHNU4H8vu(dWTyJPYV4KUSfNQTYIhQ0dKrw8XV4KPNOFfjTy1hvRSnvFu3tCEkbjeO51E3Q(OU32lsG8RCccpOcRNsqU4rWKzgpVR9kk)b4CzJ5zMXZ78PhiJypEB9e9RijhjuFo2sObZdgO5lGkeNp9aze7XBRNOFfj5a6NdrJTzIxmdx41SESyET3nvFUfZFGfNruZUS4keoIbzXmmIS47xS)Uo9m(UTP6J6EIZtjiHaTmIyRq4iBZTP6J6EIZ3fTvq0Ef1kGSXOUFBQ(OUN48DrBfKqGgvb5SkXlpPUh5IhHzgpVR9kk)b4C0Z4VnvFu3tC(UOTcsiqRv5glq5TXL5trU4rmer5ZvpQ808fqfIlsVmuPHnvbTcjeGdOFo2qWABQ(OUN48DrBfKqGgx9ulruaYfpcZmEExQcAfsiuBKEzOsdIlBCBQ(OUN48DrBfKqGw7vuR51JTP6J6EIZ3fTvqcbAET3TQpQ7T9Iei)kNGWtjBt1h19eNVlARGec0iPk9mAnEaQLkAKISpjFxSHcqjbbblKlEerXj24S0smWWdgyMXZ7AVIYFaoh9m(Bt1h19eNVlARGec0izaG8ubyJZYP0xieKlEeMz88U2RO8hGZrc1NJnwnqIjwny3mJN3z2VJ2ZiHlBK5TzIxmdJilMHRGClEiFfDX3V4HIHV4SVleYIvkLSyfilUE)XvpQfx)Iz1GS4dS4UqiUTP6J6EIZ3fTvqcbAufKZ2Eff5IhbqlQvALpCkLsC1ZgRg5Xe9chjvPNrRXdqTJA9oGWdesQA2LbdIItSXzPLW2WnyEBQ(OUN48DrBfKqGgx9ut5PcyBQ(OUN48DrBfKqGgx9uRzxjbY(K8DXgkaLeeeSqU4rqgLE3gkaLeehx9ulruGbAvqPMDXXvp1A2vsydfGscY2u9rDpX57I2kiHansQspJwpqjPix8iycOf1kTYhoLsjU6zJb5b0IALw5dNsPehndOrDVbsG5bdaArTsR8HtPuIJMb0OUNTe2MQpQ7joFx0wbjeOrsv6z0A8au7OwpY(K8DXgkaLeeeSqU4rmeH2LpCCfraj5Kxn7cnpGWdesQA2L8IItSXzPLWgtmLiwUeqAy3WStgLE3gkaLeehx9ulruaZS3QGsn7IJyC0gaTclq)CeRpv85yNjwjQHRbReyxZxavioIOG6rzPL2puzIdOFo2jJsVBdfGscIJREQLikGzM3MQpQ7joFx0wbjeO1QCJfO824Y8Pi7tY3fBOausqqWc5Ihbq4bcjvn7sErXj24S0syJjMyH0WUHzNmk9UnuakjioU6PwIOaMzVvbLA2fxBydGwHfOFoI1Nk(CSZelKA4y1GDnFbuH4iIcQhLLwA)qLjoG(5yNmk9UnuakjioU6PwIOaMzEBQ(OUN48DrBfKqGwRYnwGYBJlZNISpjFxSHcqjbbblKlEe0lCKuLEgTgpa1oQ17acpqiPQzxYJPq7YhoUIiGKCYRMDHMxuCInolTe2yIjwUgiLGRb7KrP3THcqjbXXvp1sefWm7TkOuZU4AdlxrSbqRWc0phX6tfFo2zQvbLA2fxBy5kILqT(uXNJDYO072qbOKG44QNAjIcyMzM3MQpQ7joFx0wbjeO1Ef1ghaiFGCXJWmJN31EfL)aCUSXTP6J6EIZ3fTvqcbAC1tTerbix8iiJsVBdfGscIJREQLikGnwi7t16rWc56dbaYgdBXXj0sdbblKRpeaiBmSfpIO85iSHiHTP6J6EIZ3fTvqcbAC1tT8DnjK9PA9iyHC9HaazJHT44eAPHGGfY1hcaKng2Ihru(Ce2qKqEm5VRtpJVR9kQ186HlBCWa)DD6z8DC1tTMDLeUSrM3MQpQ7joFx0wbjeOrsv6z0A8au7Ow)2CBQ(OUN48GkSEkbrgrSviCi)kNGqZNKQaLy5VpShVD8mkGTP6J6EIZdQW6PeKqGwgrSviCil88IpSVYji8j57xaUV8wZUsIT52u9rDpXrQhvxq0Ef1kGSXOUFBQ(OUN4i1JQliHanQcYzvIxEsDpYfpcZmEEx7vu(dW5ONXFBQ(OUN4i1JQliHaT2ROwZRhBt1h19ehPEuDbjeO51E3Q(OU32lsG8RCccpLSnt8IzyezXjZ1tx8uuWIVFXt0x899KwCXV4KUSfJsIfRlg90ldvASydkuqRqcbS4HeW5xSXksxSglUlkjwmRfpffupQfZWlTFOYKfJoqRWTnvFu3tCK6r1fKqGgx9ulruaYfpcZmEExQcAfsiuBKEzOsdIlBmp)DD6z8DTxrTMxpCaHtRNWgcwogKNMVaQqCerb1JYslTFOYehq)CSHG12mXlMHrKfpnOXWxSPWFazXEDCSEul2NQaucb5fFGfhPYIdfGsIfxKfRMxwS44wmTe32u9rDpXrQhvxqcbAKuLEgTgpa1sfnsrU4rekaLeUO4eBCwAjgy4bd831PNX3rsv6z0A8aulv0i15tvakHGiHbdyYFxNEgFhjvPNrRXdqTurJuNpvbOeccw55VRtpJVJKQ0ZO14bOwQOrQdiCA9edGYtDCAYG5TP6J6EIJupQUGec0izaG8ubyJZYP0xieKlEeMz88U2RO8hGZrc1NJnwnqIjwny3mJN3z2VJ2ZiHlBK5TzIxmdJilMHRGClEiFfDX3V4HIHV4SVleYIvkLSyfilUE)XvpQfx)Iz1GS4dS4UqiUTP6J6EIJupQUGec0OkiNT9kkYfpcGwuR0kF4ukL4QNnwn2MjEXmmIS4K56PMYtfWI1yXSs2fFGfZDazXKq95iiV4dS4IFXrQS4qbOKyXgREFX0swC9lUleYIJu9xmlgqCBt1h19ehPEuDbjeOXvp1uEQaqU4reAx(WXvp1uEQaCYRMDHoyatMz88U2RO8hGZrc1NJnwd9GbrXj24S0smalgW82u9rDpXrQhvxqcbAKuLEgTgpa1sfnsrU4rmeMz88U2RO8hGZLnoyat(760Z47iPk9mAnEaQLkAK68PkaLqqKqEMz88U2RO8hGZrc1NZaSyaZBZeVyggrw8mvPNXfpuaLKU47x8qXWxC23fczXrQaKfRazXkLswC9(JREuUTP6J6EIJupQUGec0iPk9mA9aLKICXJaOf1kTYhoLsjU6zJb5b0IALw5dNsPehndOrDVbsOX2mXl2q9ZT4ivw8mvPNXfBq7audYIhYxrxSpvbOeYI5pWI1fBwXIJBXbiPfRpDXA7v0fFTcWRJJ1JAX3V4KPNOFfj52MQpQ7jos9O6csiqJREQ1SRKa5IhrRck1Slo6feB2yEmXeqlQvALpCCxRWjF4QNnVscBuCcsnCmipGwuR0kF44UwHt(WvVbsoZdgmeH2LpCKuLEgTgpa12Ef1jVA2f6GbMz88U2RO8hGZrpJ)GbMz88U2RO8hGZrc1NJnwjppMQNOFfjzagQXGb(ufGsiwEG6J6ETZgl3WdZ8GbMz88U2RO8hGZrc1NZaiyL88yQEI(vKKbm4gdg4tvakHy5bQpQ71oBSCdpmZmVnvFu3tCK6r1fKqGw7vuBCaG8bYfpc6fosQspJwJhGAh16DaHtRNWwYZJEHRv5glq5TXL5tDaHtRNWwYZZmJN31EfL)aCUSXTP6J6EIJupQUGec0iPk9mAnEaQDuRh5Ihbq4bcjvn7sErXj24S0syl55neH2LpCCfraj5Kxn7cnVHi0U8HJQGC22ROo5vZUq3MQpQ7jos9O6csiqRv5glq5TXL5trU4raeEGqsvZUKxuCInolTe2m4bdyk0U8HJRicijN8QzxO5rVWrsv6z0A8au7OwVdi8aHKQMDH5TP6J6EIJupQUGec04QNA57Asi7t16rWc56dbaYgdBXXj0sdbblKRpeaiBmSfpIO85iSHiH8yYFxNEgFx7vuR51dx24Gb(760Z474QNAn7kjCzJmVnvFu3tCK6r1fKqGgjvPNrRXdqTJA9Wagqia]] )


end
