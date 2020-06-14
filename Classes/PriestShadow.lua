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


    local thought_harvester_consumed = 0

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_AURA_REMOVED" and spellID == 288343 then
            thought_harvester_consumed = GetTime()
        end
    end )    


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

        -- If we are channeling Mind Flay, see if it started with Thought Harvester.
        local _, _, _, start, finish, _, _, spellID = UnitChannelInfo( "player" )

        if spellID == 48045 then
            start = start / 1000
            finish = finish / 1000

            if start - thought_harvester_consumed < 0.1 then
                applyBuff( "mind_sear_th", finish - start )
                buff.mind_sear_th.applied = start
                buff.mind_sear_th.expires = finish
            else
                removeBuff( "mind_sear_th" )
            end
        else
            removeBuff( "mind_sear_th" )
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
            removeBuff( "mind_sear_th" )
        else
            removeDebuff( "target", "mind_flay" )
            removeDebuff( "target", "mind_sear" )
            removeBuff( "mind_sear_th" )
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
        mind_sear_th = {
            duration = function () return 3 * haste end,
            max_stack = 1,
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
                removeBuff( "mind_sear_th" )
            end,            
            prechannel = true,

            startsCombat = true,
            texture = 237565,

            aura = 'mind_sear',

            start = function ()
                applyDebuff( "target", "mind_sear" )
                channelSpell( "mind_sear" )

                if azerite.searing_dialogue.enabled then applyDebuff( "target", "searing_dialogue" ) end
                
                if buff.thought_harvester.up then
                    removeBuff( "thought_harvester" )
                    applyBuff( "mind_sear_th" )
                end
                
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

            copy = { "shadowfiend", 200174, 34433, 132603 }
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
                removeBuff( "dispellable_disease" )
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


    spec:RegisterPack( "Shadow", 20200606, [[dOKtdbqiPG6rIICjrrf2KOuJcvXPqPAvIsEfOywGs3skWUe5xGQgMOQJHQAzuKEgfrttkuxdLW2Kc5BIIY4ukvDoLsP1Pukmpkc3de7dLYbffvTquLEOuqMikr5IkLIyJkLkLrQukQtIsewPu0mvkfPBIseTtusdvuuPNQKPcQCvuI0wvkv8vLsLSxO(lLgmKdtAXu4Xu1Kr6YeBgfFgKgnvCAjRwuurVwuz2s1TrLDRYVv1WvQoUsPs1YbEoIPlCDQ02LsFNIA8OevNxuy9kLmFLI9RymFmC4fvdbZQP5nnF(gLVrj(MA622y(4vKXUGx7QpNcvWRt5e8A5O03mETRz0FLIHdViVlWl4Lte7KTb8WdTchxJK)5GNuCUDnQ)8aLjGNuCE4Xld3QhSeh2aVOAiywnnVP5Z3O8nkX3ut3wtUT4L6gopaVwfxdHxofLkh2aVOcXJxzAqlhL(MhuMlOesmnZ0GCIyNSnGhEOv44AK8ph8KIZTRr9NhOmb8KIZd)0mtdQP7jdQrWoitZBA(P50mtdQHC0dQq2gtZmnOgmOmpLk0bTQUCEjnnZ0GAWGAO)Afqi0bfkaQe2IzqKmUqz5PPzMgudgud9xRacHoOqbqLiffNyJ3slzqXpOO4eB8wAjdYSJaKbP779YRgDjnnZ0GAWGY8uQqhexDulruGnCgKHldZGIFqA7x0bzaenxDqhelzD0bTefmiVJEN0jdkC0yqkqgKHldJqhKrgdcoN3fQtmOTzf0kKqaj8QxKGGHdVi1bTly4WSYhdhEP(O(dVA)IAfG7Eu)HxYPgDHI5fhywnfdhEjNA0fkMx8YdQqaLIxgUmmP2VOmpGlrFZhEP(O(dVOkiNvjE5i1F4aZQjXWHxQpQ)WR2VOwJVh4LCQrxOyEXbM1gJHdVKtn6cfZlEP(O(dV8AVBvFu)z7fjWRErc7PCcE5PeCGzLfy4Wl5uJUqX8IxEqfcOu8YWLHj5OGwHec1goVluNGKC3hu2dY)FN(MVu7xuRX3Jeq406idInidIFIfdk7bPBjGkKeruqDqT0s7puxjb0l3GydYG4JxQpQ)WlU6OwIOaCGzTry4Wl5uJUqX8IxEqfcOu8kuaujsrXj24T0sgKjgKjh0MndY)FN(MVeXrPVzR5hqTurdNK3rbqfYGGmith0MndINb5)VtFZxI4O03S18dOwQOHtY7OaOczqqge)bL9G8)3PV5lrCu6B2A(bulv0WjbeoToYGmXGG6PjoLLpi2Xl1h1F4fXrPVzR5hqTurdhCGznZWWHxYPgDHI5fV8GkeqP4LHldtQ9lkZd4sKq95geBdIF(bbZG4zq8ZpOSgKHldtYO)pT7sIK7(GyhVuFu)HxexaqoQaSXB5u6jecoWSU9y4Wl5uJUqX8IxEqfcOu8cOf1kTYfjLsjP6geBdIFE8s9r9hErvqoB7xuCGzDBXWHxYPgDHI5fV8GkeqP4vOD5IexDud5OcijNA0f6G2Szq8midxgMu7xuMhWLiH6Zni2ge)TFqB2mOO4eB8wAjdYedIplge74L6J6p8IRoQHCubGdmR8ZJHdVKtn6cfZlE5bviGsXRgEqgUmmP2VOmpGl5UpOnBgepdY)FN(MVeXrPVzR5hqTurdNK3rbqfYGGmithu2dYWLHj1(fL5bCjsO(CdYedIplge74L6J6p8I4O03S18dOwQOHdoWSYNpgo8so1OlumV4LhuHakfVaArTsRCrsPusQUbX2GyXGYEqaTOwPvUiPukjrDbAu)nitmitZJxQpQ)WlIJsFZwpqjo4aZkFtXWHxYPgDHI5fV8GkeqP4vRck1Olj6heR7(GYEq8miEgeqlQvALlsCFRWjxKQBqSniVscBuCYGGzq5tSyqzpiGwuR0kxK4(wHtUiv3GmXGA8GyFqB2mOgEqH2LlsehL(MTMFa12(fnjNA0f6G2SzqgUmmP2VOmpGlrFZ3G2SzqgUmmP2VOmpGlrc1NBqSni(nEqzpiEguDe9QiJbzIbLz5h0MndY7OaOcXYauFu)P9bX2G4NmPjhe7dAZMbz4YWKA)IY8aUejuFUbzcidIFJhu2dINbvhrVkYyqMyqnk)G2SzqEhfaviwgG6J6pTpi2ge)Kjn5GyFqSJxQpQ)WlU6OwJUscCGzLVjXWHxYPgDHI5fV8GkeqP4f9JeXrPVzR5hqT7ADjGWP1rgeBdQXdk7br)i1QC7fO824D9ojGWP1rgeBdQXdk7bz4YWKA)IY8aUK7oEP(O(dVA)IAJhaKlWbMv(ngdhEjNA0fkMx8YdQqaLIxaHbieh1Oldk7bffNyJ3slzqSnOgpOShudpOq7YfjUIiGmsYPgDHoOShudpOq7YfjQcYzB)IMKtn6cfVuFu)HxehL(MTMFa1UR1HdmR8zbgo8so1OlumV4LhuHakfVacdqioQrxgu2dkkoXgVLwYGyBqnAqB2miEguOD5Iexreqgj5uJUqhu2dI(rI4O03S18dO2DTUeqyacXrn6YGyhVuFu)HxTk3EbkVnExVdoWSYVry4Wl5uJUqX8IxQpQ)WlU6OwMUMbEvxiaG7Eylg8kkFocBqmnBE8)3PV5l1(f1A89i5UVzJ))o9nFjU6OwJUsIK7o7zB4YWK4QJAjIcSHtI(Mp8QUqaa39WwCCcT0qWl(4L3rRdV4JdmR8ZmmC4L6J6p8I4O03S18dO2DTo8so1OlumV4ah4fvyu3EGHdZkFmC4L6J6p8IuD58cEjNA0fkMxCGz1umC4L6J6p8YLi2keocEjNA0fkMxCGz1Ky4Wl5uJUqX8IxEqfcOu8YWLHjz0)N2DjrciQpg0MndkkoXgVLwYGmbKbT95h0MndkuaujsoI2dN0UpgKjgKjzbEP(O(dV2)O(dhywBmgo8so1OlumV41VJxejWl1h1F4vRck1Ol4vR2Df8I(rI4O03S18dO2DTUuu(C1bDqzpi6hPwLBVaL3gVR3jfLpxDqXRwfypLtWl6heR7ooWSYcmC4LCQrxOyEXlpOcbukEz4YWKA)IY8aUK7oEP(O(dVykGy0)NIdmRncdhEP(O(dVmeara5QdkEjNA0fkMxCGznZWWHxQpQ)WREb1ji2mNUuOCYf4LCQrxOyEXbM1ThdhEjNA0fkMx8YdQqaLIxgUmmP2VOmpGl5UJxQpQ)Wl98cjaA361Ehhyw3wmC4L6J6p8YqHAFgBakFocEjNA0fkMxCGzLFEmC4LCQrxOyEXlpOcbukEP(OAfRCcxjKbX2G4JxQpQ)WlG7zvFu)z7fjWRErc7PCcE57I2k4aZkF(y4Wl5uJUqX8IxEqfcOu8s9r1kw5eUsidcYG4JxQpQ)WlG7zvFu)z7fjWRErc7PCcErQdAxWboWRDG4FodnWWHzLpgo8s9r9hET)r9hEjNA0fkMxCGz1umC4LCQrxOyEXRFhVisGxQpQ)WRwfuQrxWRwT7k4ft)FWG4zq8mOgNyXGGzq6wcOcjz2Pi7cGyFgB4iwQYDcnb0l3GyFqzogepdI)GGzq5tMMzdkRbPBjGkKeruqDqT0s7puxjb0l3GyFqSJxTkWEkNGxC1rTgDLe2qbqLGGdmRMedhEjNA0fkMx863XlIe4L6J6p8QvbLA0f8Qv7UcEXZG4pOgmO8P8z2GYAq6wcOcjrfnCSHd4fscOxUbbZGYNmDqzniDlbuHKcN3fQtyDuqRqcbKa6LBqSpOSgepdI)GAWGYNYVTdkRbPBjGkKu48UqDcRJcAfsiGeqVCdkRbPBjGkKeruqDqT0s7puxjb0l3GyhVAvG9uobViM3TbqRWc0lhX6DeFoCGzTXy4Wl5uJUqX8Ix)oErKaVuFu)HxTkOuJUGxTA3vWlEge)b1GbLpLVXdkRbPBjGkKu48UqDcRJcAfsiGeqVCdQbdkFkplguwds3savijYEfcJB3Q77kOI6pscOxUbXoE1Qa7PCcE1g2aOvyb6LJy9oIphoWSYcmC4LCQrxOyEXRFhVisGxQpQ)WRwfuQrxWRwT7k4fpdI)GAWGYNYNzdkRbPBjGkKev0WXgoGxijGE5gudgu(uEtoOSgKULaQqsHZ7c1jSokOviHasa9YnOgmO8P8SGfdkRbPBjGkKezVcHXTB19Dfur9hjb0l3GyFqzniEge)b1GbLpL30mBqzniDlbuHKcN3fQtyDuqRqcbKa6LBqzniDlbuHKiIcQdQLwA)H6kjGE5ge74vRcSNYj4vBy5kInaAfwGE5iwVJ4ZHdmRncdhEjNA0fkMx863XlIe4L6J6p8QvbLA0f8Qv7UcEXFqnyq5t5534bL1G0TeqfsIikOoOwAP9hQRKa6LdVAvG9uobVAdlxrSeQ17i(C4aZAMHHdVKtn6cfZlE5bviGsXRgEqgUmmjIJsFZmpGl5UJxQpQ)WlIJsFZmpGdhyw3EmC4LCQrxOyEXRt5e8s3I4OaLyz(lSpJD)nla8s9r9hEPBrCuGsSm)f2NXU)MfaoWSUTy4Wl5uJUqX8IxEqfcOu8ISl9UnuaujijU6OwIOGbzIbz6G2Szq6wcOcjfoVluNW6OGwHecib0l3GGmO84L6J6p8IRoQ1ORKahyw5NhdhEP(O(dVAvU9cuEB8UEh8so1OlumV4ah4LNsWWHzLpgo8so1OlumV4LhuHakfV4zqgUmmP2VOmpGlrc1NBqSnitZpOShuDe9QiJbzcidIf5he7dAZMbXZG8UaGCHToIEvKHLc06guwdINbXZGG6PjoLLpOSgKPdI9bbZGuFu)L4QJAn6kjsELe2O4KbX(GyFqSnO6i6vrg4L6J6p8It4Eqg2NX2D9f1sbIYrWbMvtXWHxQpQ)WlJ()u7ZydhXkNWLbEjNA0fkMxCGz1Ky4Wl5uJUqX8IxEqfcOu8YWLHj1(fL5bCjsO(CdITbXNf4L6J6p8cQRcOLE2NXQBjGpCWbM1gJHdVKtn6cfZlEP(O(dV40Ryes82NXYP0tie8YdQqaLIxKDP3THcGkbjXvh1sefmi2Gmith0MndcOf1kTYfjLsjP6geBdQr5XRt5e8ItVIriXBFglNspHqWbMvwGHdVKtn6cfZlE5bviGsXlYU072qbqLGK4QJAjIcgeBqgKPdAZMbb0IALw5IKsPKuDdITb1O84L6J6p8I59UeHA1TeqfI1quoCGzTry4Wl5uJUqX8IxEqfcOu8ISl9UnuaujijU6OwIOGbXgKbz6G2SzqaTOwPvUiPukjv3GyBqnkpEP(O(dV2Dbftg1b1A0vsGdmRzggo8so1OlumV4L6J6p8Y)NxUaOHqTmDLtWlpOcbukEffNmitazq8ZpOnBgepdYWLHj5DEGlX(m26i6vrgjsO(CdInidIplgu2dYWLHj1(fL5bCj39bX(G2SzqmU9UfiEhfavSrXjdYedcQNoOnBguuCInElTKbzIbXc8QxNy9u8Qr4aZ62JHdVuFu)HxGAFVl26SKD1l4LCQrxOyEXbM1TfdhEP(O(dVaIUxhultx5ecEjNA0fkMxCGzLFEmC4L6J6p8Y8d60wPolqi)PNxWl5uJUqX8IdmR85JHdVKtn6cfZlE5bviGsXlEgKHldtQ9lkZd4sU7dk7bz4YWK8opWLyFgBDe9QiJejuFUbX2Gmn)GyFqB2miDlbuHK8opWLyFgBDe9QiJeqVCdcYGYJxQpQ)WlV27w1h1F2Erc8QxKWEkNGxEqfwpLGdmR8nfdhEP(O(dVCjITcHJGxYPgDHI5fh4aV8GkSEkbdhMv(y4Wl5uJUqX8IxNYj4LUfXrbkXY8xyFg7(Bwa4L6J6p8s3I4OaLyz(lSpJD)nlaCGz1umC4LCQrxOyEXl1h1F4LpdF)dWFL3A0vsGxcdJ4d7PCcE5ZW3)a8x5TgDLe4ah4LVlARGHdZkFmC4L6J6p8Q9lQvaU7r9hEjNA0fkMxCGz1umC4LCQrxOyEXlpOcbukEz4YWKA)IY8aUe9nF4L6J6p8IQGCwL4LJu)HdmRMedhEjNA0fkMx8YdQqaLIxn8GIYNRoOdk7bPBjGkKu48UqDcRJcAfsiGeqVCdInidIpEP(O(dVAvU9cuEB8UEhCGzTXy4Wl5uJUqX8IxEqfcOu8YWLHj5OGwHec1goVluNGKC3Xl1h1F4fxDulruaoWSYcmC4L6J6p8Q9lQ147bEjNA0fkMxCGzTry4Wl5uJUqX8IxQpQ)WlV27w1h1F2Erc8QxKWEkNGxEkbhywZmmC4LCQrxOyEXl1h1F4fXrPVzR5hqTurdh8YdQqaLIxrXj24T0sgKjgKjh0MndYWLHj1(fL5bCj6B(WlFg(UydfavccMv(4aZ62JHdVKtn6cfZlE5bviGsXldxgMu7xuMhWLiH6Zni2ge)8dcMbXZG4NFqznidxgMKr)FA3Lej39bXoEP(O(dViUaGCubyJ3YP0tieCGzDBXWHxYPgDHI5fV8GkeqP4fqlQvALlskLss1ni2ge)8dk7bXZGOFKiok9nBn)aQDxRlbegGqCuJUmOnBguuCInElTKbX2Gmz(bXoEP(O(dVOkiNT9lkoWSYppgo8s9r9hEXvh1qoQaWl5uJUqX8IdmR85JHdVKtn6cfZlEP(O(dV4QJAn6kjWlpOcbukEr2LE3gkaQeKexDulruWGmXGAvqPgDjXvh1A0vsydfavccE5ZW3fBOaOsqWSYhhyw5Bkgo8so1OlumV4LhuHakfV4zqaTOwPvUiPukjv3GyBqSyqzpiGwuR0kxKukLKOUanQ)gKjgKPdI9bTzZGaArTsRCrsPusI6c0O(BqSnitXl1h1F4fXrPVzRhOehCGzLVjXWHxYPgDHI5fVuFu)HxehL(MTMFa1UR1HxEqfcOu8QHhuOD5Iexreqgj5uJUqhu2dcimaH4OgDzqzpOO4eB8wAjdITbXZG4zqnyq8tMoiygKjtMCqzniYU072qbqLGK4QJAjIcge7dkRb1QGsn6sIyE3gaTclqVCeR3r85guwdINbXFqnyq5t55B6GYAq6wcOcjrefuhulT0(d1vsa9YnOSgezx6DBOaOsqsC1rTerbdI9bXoE5ZW3fBOaOsqWSYhhyw53ymC4LCQrxOyEXl1h1F4vRYTxGYBJ317GxEqfcOu8cimaH4OgDzqzpOO4eB8wAjdITbXZG4zq8hemdYKjtoOSgezx6DBOaOsqsC1rTerbdI9bL1GAvqPgDj1g2aOvyb6LJy9oIp3GYAq8mi(dcMbLpXp)GYAq6wcOcjrefuhulT0(d1vsa9YnOSgezx6DBOaOsqsC1rTerbdI9bXoE5ZW3fBOaOsqWSYhhyw5ZcmC4LCQrxOyEXl1h1F4vRYTxGYBJ317GxEqfcOu8I(rI4O03S18dO2DTUeqyacXrn6YGYEq8mOq7YfjUIiGmsYPgDHoOShuuCInElTKbX2G4zq8mi(P8dcMbzAk)GYAqKDP3THcGkbjXvh1sefmi2huwdQvbLA0LuBy5kInaAfwGE5iwVJ4ZnOSgepdQvbLA0LuBy5kILqTEhXNBqzniYU072qbqLGK4QJAjIcge7dI9bXoE5ZW3fBOaOsqWSYhhyw53imC4LCQrxOyEXlpOcbukEz4YWKA)IY8aUK7oEP(O(dVA)IAJhaKlWbMv(zggo8so1OlumV4L6J6p8IRoQLikaVQleaWDpSfdEfLphHniMIx1fca4Uh2IJtOLgcEXhV8GkeqP4fzx6DBOaOsqsC1rTerbdITbXhV8oAD4fFCGzL)2JHdVKtn6cfZlEP(O(dV4QJAz6Ag4vDHaaU7HTyWRO85iSbX0S5X)FN(MVu7xuRX3JK7(Mn()7038L4QJAn6kjsU7SNTHldtIRoQLikWgoj6B(WR6cbaC3dBXXj0sdbV4JxEhTo8IpoWSYFBXWHxQpQ)WlIJsFZwZpGA316Wl5uJUqX8IdCGd8QvaK6pmRMM3085zHPSaVmRGRoOe8ILGB)bHqhuJgK6J6Vb1lsqstt8Ah8mvxWRmnOLJsFZdkZfucjMMzAqorSt2gWdp0kCCns(NdEsX521O(ZduMaEsX5HFAMPb109Kb1iyhKP5nn)0CAMPb1qo6bviBJPzMgudguMNsf6GwvxoVKMMzAqnyqn0FTcie6GcfavcBXmisgxOS800mtdQbdQH(RvaHqhuOaOsKIItSXBPLmO4huuCInElTKbz2raYG099E5vJUKMMzAqnyqzEkvOdIRoQLikWgodYWLHzqXpiT9l6GmaIMRoOdILSo6GwIcgK3rVt6KbfoAmifidYWLHrOdYiJbbNZ7c1jg02ScAfsiG00CAMPbTnHLlE3qOdYqyEGmi)ZzOXGmeO1rsdkZ79YEqg09xdCuahJBFqQpQ)id6VEgPPzMgK6J6psAhi(NZqdimDLKBAMPbP(O(JK2bI)5m0agiWZ8pDAMPbP(O(JK2bI)5m0agiWRUq5Kl0O(BAMPbToDN48XGaArhKHldJqhej0GmidH5bYG8pNHgdYqGwhzq6rh0oqAW(hrDqhurge9pjnnZ0GuFu)rs7aX)CgAade4jNUtC(Wscnitt1h1FK0oq8pNHgWab(9pQ)MMQpQ)iPDG4FodnGbc8TkOuJUa7PCceU6OwJUscBOaOsqG93HqKa2wT7kqy6)d4HNgNybm6wcOcjz2Pi7cGyFgB4iwQYDcnb0lh7zo4Hpm5tMMzzPBjGkKeruqDqT0s7puxjb0lh7SpnvFu)rs7aX)CgAade4BvqPgDb2t5eieZ72aOvyb6LJy9oIphS)oeIeW2QDxbcp8Bq(u(mllDlbuHKOIgo2Wb8cjb0lhm5tMMLULaQqsHZ7c1jSokOviHasa9YXEw8WVb5t532S0TeqfskCExOoH1rbTcjeqcOxUS0TeqfsIikOoOwAP9hQRKa6LJ9PP6J6psAhi(NZqdyGaFRck1OlWEkNaPnSbqRWc0lhX6DeFoy)DiejGTv7UceE43G8P8nolDlbuHKcN3fQtyDuqRqcbKa6LRb5t5zrw6wcOcjr2RqyC7wDFxbvu)rsa9YX(0u9r9hjTde)ZzObmqGVvbLA0fypLtG0gwUIydGwHfOxoI17i(CW(7qisaBR2Dfi8WVb5t5ZSS0TeqfsIkA4ydhWlKeqVCniFkVjZs3saviPW5DH6ewhf0kKqajGE5Aq(uEwWIS0TeqfsISxHW42T6(UcQO(JKa6LJ9S4HFdYNYBAMLLULaQqsHZ7c1jSokOviHasa9YLLULaQqserb1b1slT)qDLeqVCSpnvFu)rs7aX)CgAade4BvqPgDb2t5eiTHLRiwc16DeFoy)DiejGTv7Uce(niFkp)gNLULaQqserb1b1slT)qDLeqVCtt1h1FK0oq8pNHgWabEIJsFZmpGd2IbsdB4YWKiok9nZ8aUK7(0u9r9hjTde)ZzObmqG3Li2keoypLtGOBrCuGsSm)f2NXU)MfW0u9r9hjTde)ZzObmqGNRoQ1ORKa2Ibczx6DBOaOsqsC1rTerbMW0nB0TeqfskCExOoH1rbTcjeqcOxoi5NMQpQ)iPDG4FodnGbc8Tk3EbkVnExVZ0CAMPbTnHLlE3qOdsAfqgdkkozqHJmi1hpyqfzqARwD1OlPPP6J6pces1LZltt1h1FeyGaVlrSviCKPP6J6pcmqGF)J6pylgigUmmjJ()0Uljsar9XMnrXj24T0smbKTp)MnHcGkrYr0E4K29HjmjlMMQpQ)iWab(wfuQrxG9uobc9dI1Dh2FhcrcyB1URaH(rI4O03S18dO2DTUuu(C1bnB6hPwLBVaL3gVR3jfLpxDqNMQpQ)iWabEMcig9)PWwmqmCzysTFrzEaxYDFAQ(O(Jade4neara5Qd60u9r9hbgiW3lOobXM50LcLtUyAQ(O(Jade41ZlKaODRx7DylgigUmmP2VOmpGl5UpnvFu)rGbc8gku7Zydq5ZrMMQpQ)iWabEG7zvFu)z7fjG9uobIVlARaBXar9r1kw5eUsiSXFAQ(O(Jade4bUNv9r9NTxKa2t5eiK6G2fylgiQpQwXkNWvcbc)P50mtdILsKbXskCpiJb9mdABQRVOdILbeLJmiqb1jgKHW8azqz8UdsbYGuJ3ngu8dIr79b9UXGEMbTD(IY8aUPP6J6psYtjq4eUhKH9zSDxFrTuGOCeylgi8y4YWKA)IY8aUejuFo2mnF21r0RImmbewKN9nB4X7caYf26i6vrgwkqRllE4bQNM4uwEwMYomQpQ)sC1rTgDLejVscBuCc7SZwDe9QiJPP6J6psYtjWabEJ()u7ZydhXkNWLX0u9r9hj5PeyGapuxfql9SpJv3saF4aBXaXWLHj1(fL5bCjsO(CSXNftt1h1FKKNsGbc8UeXwHWb7PCceo9kgHeV9zSCk9ecb2Ibczx6DBOaOsqsC1rTerbSbX0nBaArTsRCrsPusQo2Au(PP6J6psYtjWabEM37seQv3saviwdr5GTyGq2LE3gkaQeKexDulruaBqmDZgGwuR0kxKukLKQJTgLFAQ(O(JK8ucmqGF3fumzuhuRrxjbSfdeYU072qbqLGK4QJAjIcydIPB2a0IALw5IKsPKuDS1O8tZmnOTlTIbPXG6IsIb1iYGmKWSi3G8kjQd6GAOTBPbXsjYGchzqmfGedYRKyqz(vMpZDqXpiOsmOkg0FdQHyzWoOWrUbjTciJbrCniY2Dx5Ib5vsmiIZ72PdYqgKlrOdYSJCdQHCEGlzqpZGyjoIEvKXGkYGuFuTYGEWGQyqMREFqaX7OaOYGQBqHJmOty5XGG6PWoOhmOWrguOaOsmOImi14DJbf)GOLKMMQpQ)ijpLade49)5LlaAiultx5ey71jwpfsJGTyGefNyci8ZVzdpgUmmjVZdCj2NXwhrVkYirc1NJni8zr2gUmmP2VOmpGl5UZ(MnmU9UfiEhfavSrXjMaQNUztuCInElTetWIPP6J6psYtjWabEqTV3fBDwYU6LPP6J6psYtjWabEGO71b1Y0voHmnvFu)rsEkbgiWB(bDARuNfiK)0ZltZmniwkrgu4iezq()7038rguDdYqcZICdkJ3fmi(Kyq6rhKPhDqBNVOdI3VhdQUbLX7cgKPhDqBNVOmpGBqMDKBqz8UdYrBLb1qopWLmONzqSehrVkYyqQpQwzAQ(O(JK8ucmqG3R9Uv9r9NTxKa2t5eiEqfwpLaBXaHhdxgMu7xuMhWLC3Z2WLHj5DEGlX(m26i6vrgjsO(CSzAE23Sr3savijVZdCj2NXwhrVkYib0lhK8tZmniwMWOU9yqmAVBO(CdI5bdYLOgDzqviCKTXGyPezq)ni))D6B(stt1h1FKKNsGbc8UeXwHWrMMtt1h1FKKVlARaP9lQvaU7r930u9r9hj57I2kWabEQcYzvIxos9hSfdedxgMu7xuMhWLOV5BAQ(O(JK8DrBfyGaFRYTxGYBJ317aBXaPHJYNRoOzRBjGkKu48UqDcRJcAfsiGeqVCSbH)0u9r9hj57I2kWabEU6OwIOaylgigUmmjhf0kKqO2W5DH6eKK7(0u9r9hj57I2kWab(2VOwJVhtt1h1FKKVlARade49AVBvFu)z7fjG9uobINsMMQpQ)ijFx0wbgiWtCu6B2A(bulv0WbwFg(Uydfavcce(WwmqIItSXBPLyctUzJHldtQ9lkZd4s038nnvFu)rs(UOTcmqGN4caYrfGnElNspHqGTyGy4YWKA)IY8aUejuFo24NhgE4NpldxgMKr)FA3Lej3D2NMzAqSuImiwMcYnOTZx0b93GAiw2GCVUqidsPuYGuGmO68pxDqhuDdIFEYGEWG6cHKMMQpQ)ijFx0wbgiWtvqoB7xuylgiaTOwPvUiPukjvhB8ZNnp0psehL(MTMFa1UR1LacdqioQrx2SjkoXgVLwcBMmp7tt1h1FKKVlARade45QJAihvatt1h1FKKVlARade45QJAn6kjG1NHVl2qbqLGaHpSfdeYU072qbqLGK4QJAjIcmrRck1OljU6OwJUscBOaOsqMMQpQ)ijFx0wbgiWtCu6B26bkXb2IbcpaTOwPvUiPukjvhBSiBGwuR0kxKukLKOUanQ)mHPSVzdqlQvALlskLssuxGg1FSz60u9r9hj57I2kWabEIJsFZwZpGA316G1NHVl2qbqLGaHpSfdKgo0UCrIRiciJKCQrxOzdegGqCuJUKDuCInElTe24HNgWpzkmMmzYSi7sVBdfavcsIRoQLikG9SAvqPgDjrmVBdGwHfOxoI17i(CzXd)gKpLNVPzPBjGkKeruqDqT0s7puxjb0lxwKDP3THcGkbjXvh1sefWo7tt1h1FKKVlARade4BvU9cuEB8UEhy9z47Inuaujiq4dBXabimaH4OgDj7O4eB8wAjSXdp8HXKjtMfzx6DBOaOsqsC1rTerbSNvRck1OlP2WgaTclqVCeR3r85YIh(WKpXpFw6wcOcjrefuhulT0(d1vsa9YLfzx6DBOaOsqsC1rTerbSZ(0u9r9hj57I2kWab(wLBVaL3gVR3bwFg(Uydfavcce(WwmqOFKiok9nBn)aQDxRlbegGqCuJUKnpH2LlsCfrazKKtn6cn7O4eB8wAjSXdp8t5HX0u(Si7sVBdfavcsIRoQLikG9SAvqPgDj1gwUIydGwHfOxoI17i(CzXtRck1OlP2WYvelHA9oIpxwKDP3THcGkbjXvh1sefWo7SpnvFu)rs(UOTcmqGV9lQnEaqUa2IbIHldtQ9lkZd4sU7tt1h1FKKVlARade45QJAjIcGTyGq2LE3gkaQeKexDulruaB8H17O1bHpS1fca4Uh2IJtOLgce(WwxiaG7Eylgir5ZrydIPtt1h1FKKVlARade45QJAz6AgW6D06GWh26cbaC3dBXXj0sdbcFyRleaWDpSfdKO85iSbX0S5X)FN(MVu7xuRX3JK7(Mn()7038L4QJAn6kjsU7SNTHldtIRoQLikWgoj6B(MMQpQ)ijFx0wbgiWtCu6B2A(bu7Uw30CAQ(O(JK8GkSEkbIlrSviCWEkNar3I4OaLyz(lSpJD)nlGPP6J6psYdQW6PeyGaVlrSviCWkmmIpSNYjq8z47Fa(R8wJUsIP50u9r9hjrQdAxG0(f1ka39O(BAQ(O(JKi1bTlWabEQcYzvIxos9hSfdedxgMu7xuMhWLOV5BAQ(O(JKi1bTlWab(2VOwJVhtt1h1FKePoODbgiW71E3Q(O(Z2lsa7PCcepLmnZ0GyPezqSK1rh0suWG(Bql4g0F9mguXmOmE3bbvIbPdcoN3fQtmOTzf0kKqadkZf8(bzUcNbPXG6IsIbXFqlrb1bDqSSs7puxzqWb0kstt1h1FKePoODbgiWZvh1sefaBXaXWLHj5OGwHec1goVluNGKC3Z2)FN(MVu7xuRX3Jeq406iSbHFIfzRBjGkKeruqDqT0s7puxjb0lhBq4pnZ0GyPezqRTlw2GmeMhidYR771bDqEhfaviWoOhmOWrguOaOsmOImi14DJbf)GOLKMMQpQ)ijsDq7cmqGN4O03S18dOwQOHdSfdKqbqLiffNyJ3slXeMCZg))D6B(sehL(MTMFa1sfnCsEhfaviqmDZgE8)3PV5lrCu6B2A(bulv0Wj5DuauHaHF2()7038Liok9nBn)aQLkA4KacNwhXeq90eNYYzFAQ(O(JKi1bTlWabEIlaihva24TCk9ecb2IbIHldtQ9lkZd4sKq95yJFEy4HF(SmCzysg9)PDxsKC3zFAcZGY0GyPezqSmfKBqBNVOd6Vb1qSSb5EDHqgKsPKbPazq15FU6GoO6ge)8Kb9Gb1fcjnnvFu)rsK6G2fyGapvb5STFrHTyGa0IALw5IKsPKuDSXp)0mtdILsKbXswh1qoQagKgdI)2oOhmiUhidIeQphb2b9GbvmdkCKbfkaQedYC17dIwYGQBqDHqgu4O3G4ZcsAAQ(O(JKi1bTlWabEU6OgYrfaSfdKq7YfjU6OgYrfqso1Ol0nB4XWLHj1(fL5bCjsO(CSXF73SjkoXgVLwIj4Zc2NMQpQ)ijsDq7cmqGN4O03S18dOwQOHdSfdKg2WLHj1(fL5bCj39nB4X)FN(MVeXrPVzR5hqTurdNK3rbqfcetZ2WLHj1(fL5bCjsO(CMGplyFAMPbXsjYGwok9npOgcOeNb93GAiw2GCVUqidkCeGmifidsPuYGQZ)C1bnnnvFu)rsK6G2fyGapXrPVzRhOehylgiaTOwPvUiPukjvhBSiBGwuR0kxKukLKOUanQ)mHP5NMzAq8QxUbfoYGwok9npOTRhq3gdA78fDqEhfavidI5bdshKrfdk(bfGmgKE0bPTFrh03kaVUVxh0b93GyjoIEvKrAAQ(O(JKi1bTlWabEU6OwJUscylgiTkOuJUKOFqSU7zZdpaTOwPvUiX9TcNCrQo28kjSrXjWKpXISbArTsRCrI7Bfo5IuDMOXSVztdhAxUirCu6B2A(buB7x0KCQrxOB2y4YWKA)IY8aUe9nFB2y4YWKA)IY8aUejuFo2434S5PoIEvKHjYS8B24DuauHyzaQpQ)0oB8tM0KSVzJHldtQ9lkZd4sKq95mbe(noBEQJOxfzyIgLFZgVJcGkeldq9r9N2zJFYKMKD2NMQpQ)ijsDq7cmqGV9lQnEaqUa2Ibc9JeXrPVzR5hqT7ADjGWP1ryRXzt)i1QC7fO824D9ojGWP1ryRXzB4YWKA)IY8aUK7(0u9r9hjrQdAxGbc8ehL(MTMFa1UR1bBXabimaH4OgDj7O4eB8wAjS14SB4q7YfjUIiGmsYPgDHMDdhAxUirvqoB7x0KCQrxOtt1h1FKePoODbgiW3QC7fO824D9oWwmqacdqioQrxYokoXgVLwcBnAZgEcTlxK4kIaYijNA0fA20psehL(MTMFa1UR1LacdqioQrxyFAQ(O(JKi1bTlWabEU6OwMUMbSEhToi8HTUqaa39WwCCcT0qGWh26cbaC3dBXajkFocBqmnBE8)3PV5l1(f1A89i5UVzJ))o9nFjU6OwJUsIK7o7zB4YWK4QJAjIcSHtI(MVPP6J6psIuh0Uade4jok9nBn)aQDxRdVi7IhZQPSy7XboWya]] )


end
