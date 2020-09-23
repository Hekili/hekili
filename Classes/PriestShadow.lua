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
            value = function () return state.active_enemies end,
        },

        -- need to revise the value of this, void decay ticks up and is impacted by void torrent.
        voidform = {
            aura = "voidform",
            talent = "legacy_of_the_void",

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
                return state.debuff.dispersion.up and 0 or ( -6 - ( 0.8 * state.debuff.voidform.stacks ) )
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

            interval = function () return class.auras.void_torrent.tick_time end,
            value = 6,
        },

        mindbender = {
            aura = "mindbender",

            last = function ()
                local app = state.buff.mindbender.expires - 15
                local t = state.query_time

                return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
            end,

            interval = function () return 1.5 * state.haste end,
            value = function () return ( state.buff.surrender_to_madness.up and 12 or 6 ) end,
        },

        shadowfiend = {
            aura = "shadowfiend",

            last = function ()
                local app = state.buff.shadowfiend.expires - 15
                local t = state.query_time

                return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
            end,

            interval = function () return 1.5 * state.haste end,
            value = function () return ( state.buff.surrender_to_madness.up and 6 or 3 ) end,
        },

        death_and_madness = {
            aura = "death_and_madness",

            last = function ()
                local app = state.buff.death_and_madness.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 1,
        }
    } )
    spec:RegisterResource( Enum.PowerType.Mana )


    -- Talents
    spec:RegisterTalents( {
        fortress_of_the_mind = 22328, -- 193195
        death_and_madness = 22136, -- 321291
        unfurling_darkness = 22314, -- 341273

        body_and_soul = 22315, -- 64129
        sanlayn = 23374, -- 199855
        intangibility = 21976, -- 288733

        twist_of_fate = 23125, -- 109142
        misery = 23126, -- 238558
        searing_nightmare = 23127, -- 341385

        last_word = 23137, -- 263716
        mind_bomb = 23375, -- 205369
        psychic_horror = 21752, -- 64044

        auspicious_spirits = 22310, -- 155271
        psychic_link = 22311, -- 199484
        shadow_crash = 21755, -- 205385

        damnation = 21718, -- 341374
        mindbender = 21719, -- 200174
        void_torrent = 21720, -- 263165

        ancient_madness = 21637, -- 341240
        legacy_of_the_void = 21978, -- 193225
        surrender_to_madness = 21979, -- 319952
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
    local unfurling_darkness_triggered = 0

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID then
            if subtype == "SPELL_AURA_REMOVED" and spellID == 288343 then
                thought_harvester_consumed = GetTime()
            elseif subtype == "SPELL_AURA_APPLIED" and spellID == 341273 then
                unfurling_darkness_triggered = GetTime()
            end
        end
    end )


    local hadShadowform = false

    spec:RegisterHook( "reset_precast", function ()
        if time > 0 then
            applyBuff( "shadowform" )
        end

        if unfurling_darkness_triggered > 0 and now - unfurling_darkness_triggered < 15 then
            applyBuff( "unfurling_darkness_icd", now - unfurling_darkness_triggered )
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
        dark_thought = {
            id = 341207,
            duration = 6,
            max_stack = 1,
            copy = "dark_thoughts"
        },
        death_and_madness = {
            id = 321973,
            duration = 4,
            max_stack = 1,
        },
        desperate_prayer = {
            id = 19236,
            duration = 10,
            max_stack = 1,
        },
        devouring_plague = {
            id = 335467,
            duration = 6,
            type = "Disease",
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
        mind_bomb = {
            id = 226943,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        mind_flay = {
            id = 15407,
            duration = function () return 4.5 * haste end,
            max_stack = 1,
            tick_time = function () return 0.75 * haste end,
        },
        mind_sear = {
            id = 48045,
            duration = function () return 4.5 * haste end,
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
        power_infusion = {
            id = 10060,
            duration = 20,
            max_stack = 1
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
        shadow_crash_debuff = {
            id = 342385,
            duration = 15,
            max_stack = 2
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
        silence = {
            id = 15487,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        surrender_to_madness = {
            id = 319952,
            duration = 25,
            max_stack = 1,
        },
        twist_of_fate = {
            id = 123254,
            duration = 8,
            max_stack = 1,
        },
        unfurling_darkness = {
            id = 341282,
            duration = 15,
            max_stack = 1,
        },
        unfurling_darkness_icd = {
            id = 341291,
            duration = 15,
            max_stack = 1
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
            duration = function () return 4 * haste end,
            max_stack = 1,
            tick_time = function () return haste end,
        },
        voidform = {
            id = 194249,
            duration = function () return talent.legacy_of_the_void.enabled and 3600 or 15 end,
            max_stack = 1,
            generate = function( t )
                local name, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = FindUnitBuffByID( "player", 194249 )

                if name then
                    t.name = name
                    t.count = max( 1, count )
                    t.applied = max( action.void_eruption.lastCast, now )
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


        -- Legendaries (Shadowlands)
        mind_devourer = {
            id = 338333,
            duration = 15,
            max_stack = 1,
        },

        dissonant_echoes = {
            id = 343144,
            duration = 10,
            max_stack = 1,
        },

    } )


    spec:RegisterHook( "advance_end", function ()
        if buff.voidform.up and talent.legacy_of_the_void.enabled and insanity.current == 0 then
            insanity.regen = 0
            removeBuff( "voidform" )
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
        damnation = {
            id = 341374,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            talent = "damnation",
            
            startsCombat = true,
            texture = 236295,
            
            handler = function ()
                applyDebuff( "target", "shadow_word_pain" )
                applyDebuff( "target", "vampiric_touch" )
                applyDebuff( "target", "devouring_plague" )

                if talent.unfurling_darkness.enabled and query_time - action.vampiric_touch.lastCast > 8 then
                    applyBuff( "unfurling_darkness" )
                    applyDebuff( "player", "unfurling_darkness_icd" )
                end
            end,
        },
        
        
        desperate_prayer = {
            id = 19236,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = true,
            texture = 237550,
            
            handler = function ()                
                health.max = health.max * 1.25
                gain( 0.8 * health.max, "health" )
            end,
        },


        devouring_plague = {
            id = 335467,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return buff.mind_devourer.up and 0 or 50 end,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 252997,

            cycle = "devouring_plague",
            
            handler = function ()
                removeBuff( "mind_devourer" )
                applyDebuff( "target", "devouring_plague" )
            end,
        },


        dispel_magic = {
            id = 528,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = false,
            texture = 136066,

            usable = function () return buff.dispellable_magic.up end,
            handler = function ()
                removeBuff( "dispellable_magic" )
                if time > 0 then gain( 6, "insanity" ) end
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
                if time > 0 then gain( 6, "insanity" ) end
            end,
        },


        mind_blast = {
            id = 8092,
            cast = function () return buff.dark_thought.up and 0 or ( 1.5 * haste ) end,
            charges = function () return 1 + ( buff.voidform.up and 1 or 0 ) + ( buff.dark_thought.up and 1 or 0 ) end,
            cooldown = function ()
                if buff.dark_thought.up then return 0 end
                return 7.5 * haste
            end,
            recharge = function ()
                if buff.dark_thought.up then return 0 end
                return 7.5 * haste
            end,
            gcd = "spell",
            castableWhileCasting = function ()
                if buff.dark_thought.up and ( buff.casting.v1 == class.abilities.mind_flay.id or buff.casting.v1 == class.abilities.mind_sear.id ) then return true end
                return nil
            end,

            velocity = 15,

            spend = function () return ( talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * ( -8 - buff.empty_mind.stack ) * ( buff.surrender_to_madness.up and 2 or 1 ) end,
            spendType = "insanity",

            startsCombat = true,
            texture = 136224,

            handler = function ()
                removeBuff( "dark_thought" )
                removeBuff( "harvested_thoughts" )
                removeBuff( "empty_mind" )
            end,
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

            tick_time = function () return class.auras.mind_flay.tick_time end,

            startsCombat = true,
            texture = 136208,

            aura = 'mind_flay',

            nobuff = "boon_of_the_ascended",

            start = function ()
                applyDebuff( "target", "mind_flay" )
                channelSpell( "mind_flay" )
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

            tick_time = function () return class.auras.mind_flay.tick_time end,

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

        
        power_infusion = {
            id = 10060,
            cast = 0,
            cooldown = 120,
            gcd = "off",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 135939,
            
            handler = function ()
                applyBuff( "power_infusion" )
                stat.haste = stat.haste + 0.25
            end,
        },


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
            cooldown = 0,
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
                if time > 0 then gain( 6, "insanity" ) end
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

            spend = 0.01,
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
                if time > 0 then gain( 6, "insanity" ) end
            end,
        },


        searing_nightmare = {
            id = 341385,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            castableWhileCasting = true,

            talent = "searing_nightmare",
            
            spend = 30,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 1022950,

            debuff = "mind_sear",
            
            handler = function ()
                applyDebuff( "target", "shadow_word_pain" )
                active_dot.shadow_word_pain = max( active_enemies, active_dot.shadow_word_pain )
            end,
        },

        shackle_undead = {
            id = 9484,
            cast = 1.275,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136091,

            handler = function ()
                applyDebuff( "target", "shackle_undead" )
            end,
        },


        shadow_crash = {
            id = 342834,
            cast = 0,
            charges = 3,
            cooldown = 45,
            recharge = 45,
            hasteCD = true,
            gcd = "spell",

            spend = -8,
            spendType = "insanity",

            velocity = 10,

            startsCombat = true,
            texture = 136201,

            impact = function ()
                if active_enemies == 1 then addStack( "shadow_crash_debuff", nil, 1 ) end
            end,
        },


        shadow_mend = {
            id = 186263,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
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
            cooldown = 20,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 136149,

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
            id = 319952,
            cast = 0,
            cooldown = 90,
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
                if time > 0 then gain( 6, "insanity" ) end
            end,
        },


        vampiric_touch = {
            id = 34914,
            cast = function () return buff.unfurling_darkness.up and 0 or 1.5 end,
            cooldown = 0,
            gcd = "spell",

            spend = -5,
            spendType = "insanity",

            startsCombat = true,
            texture = 135978,

            cycle = function () return talent.misery.enabled and 'shadow_word_pain' or 'vampiric_touch' end,

            handler = function ()
                applyDebuff( "target", "vampiric_touch" )

                if talent.misery.enabled then
                    applyDebuff( "target", "shadow_word_pain" )
                end

                if talent.unfurling_darkness.enabled then
                    if buff.unfurling_darkness.up and query_time - action.vampiric_touch.lastCast < 8 then
                        removeBuff( "unfurling_darkness" )
                    elseif debuff.unfurling_darkness_icd.down and query_time - action.vampiric_touch.lastCast > 8 then
                        applyBuff( "unfurling_darkness" )
                        applyDebuff( "player", "unfurling_darkness_icd" )
                    end
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
                return haste * 4.5
            end,
            gcd = "spell",

            spend = function ()
                return buff.surrender_to_madness.up and -40 or -20
            end,
            spendType = "insanity",

            startsCombat = true,
            texture = 1035040,

            velocity = 40,
            buff = function () return buff.dissonant_echoes.up and "dissonant_echoes" or "voidform" end,
            bind = "void_eruption",

            cooldown_ready = function ()
                return cooldown.void_bolt.remains == 0 and ( buff.dissonant_echoes.up or buff.voidform.up )
            end,

            handler = function ()
                removeBuff( "dissonant_echoes" )

                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 3 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 3 end
                if debuff.devouring_plague.up then debuff.devouring_plague.expires = debuff.devouring_plague.expires + 3 end

                removeBuff( "anunds_last_breath" )
            end,
        },


        void_eruption = {
            id = 228260,
            cast = function ()
                if pvptalent.void_origins.enabled then return 0 end
                return haste * 1.5 
            end,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1386548,

            nobuff = function () return buff.dissonant_echoes.up and "dissonant_echoes" or "voidform" end,
            bind = "void_bolt",

            toggle = "cooldowns",

            handler = function ()
                applyBuff( "voidform" )
            end,
        },


        void_torrent = {
            id = 263165,
            cast = 4,
            channeled = true,
            fixedCast = true,
            cooldown = 45,
            gcd = "spell",

            spend = -6,
            spendType = "insanity",

            startsCombat = true,
            texture = 1386551,

            aura = "void_torrent",
            talent = "void_torrent",

            start = function ()
                applyDebuff( "target", "void_torrent" )
            end,
        },


        -- Priest - Kyrian    - 325013 - boon_of_the_ascended (Boon of the Ascended)
        boon_of_the_ascended = {
            id = 325013,
            cast = 1.5,
            cooldown = 180,
            gcd = "spell",

            startsCombat = false,
            texture = 3565449,

            toggle = "essences",

            handler = function ()
                applyBuff( "boon_of_the_ascended" )
            end,

            auras = {
                boon_of_the_ascended = {
                    id = 325013,
                    duration = 10,
                    max_stack = 20 -- ???
                }
            }
        },

        ascended_nova = {
            id = 325020,
            cast = 0,
            cooldown = 0,
            gcd = "spell", -- actually 1s and not 1.5s...

            startsCombat = true,
            texture = 3528287,

            buff = "boon_of_the_ascended",

            handler = function ()
                addStack( "boon_of_the_ascended", nil, active_enemies )
            end
        },

        ascended_blast = {
            id = 325283,
            cast = 0,
            cooldown = 3,
            hasteCD = true,
            gcd = "spell", -- actually 1s and not 1.5s...

            startsCombat = true,
            texture = 3528286,

            buff = "boon_of_the_ascended",

            handler = function ()
                addStack( "boon_of_the_ascended", nil, 5 )
                if spec.shadow then gain( 6, "insanity" ) end
            end,
        },

        -- Priest - Necrolord - 324724 - unholy_nova          (Unholy Nova)
        unholy_nova = {
            id = 324724,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = true,
            texture = 3578229,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "unholy_transfusion" )
                active_dot.unholy_transfusion = active_enemies
            end,

            auras = {
                unholy_transfusion = {
                    id = 324724,
                    duration = 15,
                    max_stack = 1,
                }
            }
        },

        -- Priest - Night Fae - 327661 - fae_guardians        (Fae Guardians)
        fae_guardians = {
            id = 327661,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            toggle = "essences",

            handler = function ()
                summonPet( "wrathful_faerie" )
                summonPet( "guardian_faerie" )
                summonPet( "benevolent_faerie" )
                -- TODO: Check totem/guardian API re: faeries.
            end,
        },

        -- Priest - Venthyr   - 323673 - mindgames            (Mindgames)
        mindgames = {
            id = 323673,
            cast = 1.5,
            cooldown = 45,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "mindgames" )
            end,

            auras = {
                mindgames = {
                    id = 323673,
                    duration = 5,
                    max_stack = 1,
                },
            },
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


    spec:RegisterPack( "Shadow", 20200920, [[dSuI5aqiuu9irP6sOOO0Mev9juuunkvQ6uQu5vIIMfk4wOQs1Uu4xIcdtuXXuPSmrjptuPMMksDnuv12qrPVjkLACIkX5evsRtukAEOQ09uj7JsXbrrHwiLspuukmruv0frvbTruuqnsuuqojQkuRuf6LOOOyMOQs5MOQq2jkYpvrIHIQkEQIMkk0vvrsBfvvYxrrr2lO)sXGbomPftjpwKjt4YiBgv(mrnAQQtl51QiMnvUnkTBP(TQgov54OQalhYZHA6cxNiBhv57uQgpkkW5vrTErPK5Rc2VsdVbzeofAqqMYkNSYjNCnRCg5KRNMzpnZcNXzpco900jQmbNTYsW50xfVD40tp7EvazeoXVekrWPFeE4SzgzixHVK1i9SzGlwjNg13jKYfzGl2ugWPLu5c(4gAbNcniitzLtw5KtUMvoJCY1tZS5MzHtvk8FeCol2SbC6xcb1ql4uq4eCM9fm9vXBFb8dQiCShZ(cMKxqSweAbzLddliRCYkh40v4adzeojmM6eHHmcz6gKr4utr9nCYsSp6S55moPujmcePSy4KA1YrcOTWaYuwqgHtnf13WPL7FH55mHpzOMypdNuRwosaTfgqMYnKr4utr9nCklPirPT55mA2IqF4dNuRwosaTfgqMonKr4KA1YrcOTWzcvbHkfoXEKZzcfjtbEWwTWGjfTaBUwqwl4WHfG0syiEuhdviWJQxGnlGzZbo1uuFdNCFsctcJMTiufKXIuwyazI)qgHtQvlhjG2cNjufeQu4e7roNjuKmf4bB1cdMu0cS5AbzTGdhwaslHH4rDmuHapQEb2SaMnh4utr9nC6jHkUZvlBSCkoGbKjMfYiCsTA5ib0w4utr9nCM(orDG0GegoNYsWzcvbHkfoJILwaFVwWTCwWHdlGtY5mik5RizYeflTa(Ua5KybhoSGqrYumIILmXBefTa(Ua(dNUQjtsaNmlmGmLTHmcNAkQVHtu555it1gSNMi4KA1YrcOTWaYuUazeo1uuFdNis9Qw2W5uwcdNuRwosaTfgqMYviJWPMI6B40(JCcEu1geH)w7ebNuRwosaTfgqMULdKr4utr9nCg(KrQTEPwy4EuIGtQvlhjG2cdyaNcItLCbKrit3GmcNAkQVHtC5OorWj1QLJeqBHbKPSGmcNuRwosaTfotOkiuPWPLeh3WY9VWjHJbI0uSGdhwqOizkgrXsM4nIIwaFVwqUKZcoCybHIKPy4tQl8hEPyb8Db5M)WPMI6B407J6Byazk3qgHtQvlhjG2cNVhCIPao1uuFdN8uuPwoco5PojcofFmW(Q4TBS)iHXtREev6KQLxq(fi(yWtz9kuLmXlL8hrLoPAz4KNImTYsWP4dSrYdgqMonKr4KA1YrcOTW57bNykGtnf13WjpfvQLJGtEQtIGtXhdSVkE7g7psy80QhrLoPA5fKFbIpg8uwVcvjt8sj)ruPtQwEb5xG4JHG49sOQLnEovwIgrLoPAz4KNImTYsWP6CgXhyJKhmGmXFiJWj1QLJeqBHZ3doXuaNAkQVHtEkQulhbN8uNebNypY5mHIKPapyRwyWKIwGnlil4KNImTYsWjMuu1YMUK9dwfrMKu8CCWaYeZczeoPwTCKaAlCQPO(gorsTrtr9TXv4aoDfomTYsWjRwnmGbC6HO0ZAPbKrit3GmcNuRwosaTfgqMYcYiCsTA5ib0wyazk3qgHtQvlhjG2cditNgYiCsTA5ib0wyazI)qgHtnf13WP3h13Wj1QLJeqBHbKjMfYiCsTA5ib0w4mHQGqLcNmFbwsCCdSVkE7CpIDi5bNAkQVHtSVkE7CpIfgqMY2qgHtQvlhjG2cNTYsWPMTW(ksXgUVdZZz8E7eco1uuFdNA2c7RifB4(ompNX7TtiyazkxGmcNuRwosaTfoFp4etbCQPO(go5POsTCeCYtDseCEBbzUaKutCpsMguqOwDMK6CM4nHpz49Lyq8bsLNhjGtEkY0klbNSvlmysrMKu8CCWaYuUczeo1uuFdNSvlmwofhWj1QLJeqBHbmGZKadzeY0niJWj1QLJeqBHZeQccvkCAjXXn49LG7rSdjp4utr9nC692jKPAojC9nmGmLfKr4utr9nCYPKrwsrIsBmCsTA5ib0wyazk3qgHtQvlhjG2cNjufeQu4SAS2vCEb8Db5Aoli)cy(cSK44g8(sW9i2HKhCQPO(gozRwiRSeggqMonKr4KA1YrcOTWzcvbHkforAjmepQJHke4r1lWMfW)CGtnf13WPu7)UZM(5PWaYe)HmcNuRwosaTfotOkiuPWjZxGLeh3G3xcUhXoK8wq(fW8fK(3jE79G3xcdHK8I67HK3cYVaSh5CMqrYuGhSvlmysrlWMfCBb5xaZxqOoQJbMuu1YMUK9dwfrdQvlhjwWHdl4(fyjXXn49LG7rSdjVfKFbypY5mHIKPapyRwyWKIwaFxqwli)cy(cc1rDmWKIQw20LSFWQiAqTA5iXcUBbhoSG7xGLeh3G3xcUhXoK8wq(feQJ6yGjfvTSPlz)Gvr0GA1YrIfChCQPO(goT(VnpNj8jJItulibmGmXSqgHtQvlhjG2cNAkQVHZK6Cgnf13gxHd40v4W0klbNegtDIWWaYu2gYiCQPO(goLWKPcIfdNuRwosaTfgWaoT(VHmcz6gKr4KA1YrcOTWzcvbHkfoXEKZzcfjtbEWwTWGjfTa(ETGCdNAkQVHtfNOwqcJLtXbmGmLfKr4KA1YrcOTWzcvbHkfoVFbypY5mHIKPapyRwyWKIwGnliRfKFbH6OogysrvlB6s2pyvenOwTCKybhoSG7xa2JCotOizkWd2QfgmPOfyZcUTG8lG5liuh1XatkQAztxY(bRIOb1QLJel4UfC3cYVaSh5CMqrYuGhkorTGeM(5PlWMfCdo1uuFdNkorTGeM(5PWagWjRwnKrit3GmcNuRwosaTfotOkiuPWPLeh3W6)28CMWNmkorTGedjp4utr9nCMuNZOPO(24kCaNUchMwzj406)ggqMYcYiCsTA5ib0w4mHQGqLcN3VahXJClGVlG)5YcoCybP)DI3Ep8E7eYunNeU(Ei5TG7wq(funw7koVaBUwWPZzb5xW9lG5liuh1XWrYA6S55mHpz49LyqTA5iXcoCyb3VGqDuhdhjRPZMNZe(KH3xIb1QLJeli)ceFmeeVxcvTSXZPYs0iQ0jvlVG7wWDWPMI6B4K3xcdHK8I6Byazk3qgHtQvlhjG2cNjufeQu4SAS2vCEiiUkvXcS5Ab34pCQPO(go59LWy9UagqMonKr4KA1YrcOTWPMI6B4mPoNrtr9TXv4aoDfomTYsWzsGHbKj(dzeoPwTCKaAlCQPO(gofkBRr9nCMqvqOsHtMVaEkQulhnuNZi(aBK8GZ05KJmHIKPadz6gmGmXSqgHtQvlhjG2cNjufeQu4muh1XWrYA6S55mHpz49LyqTA5iXcYVG0)oXBVh8(syiKKxuFpK8wq(funw7koVGRfClNCGtnf13WPG49sOQLnEovwIGbKPSnKr4KA1YrcOTWPMI6B4uq8Eju1YgpNklrWzcvbHkfoVFbiIdryF1Yrl4WHfunw7koVaBwq2M)l4UfKFb3VahXJClGVlG)5YcoCybmFbP)DI3Ep8E7eYunNeU(Ei5TG7wq(fC)cy(cc1rDmWKIQw20LSFWQiAqTA5iXcoCyb3VGqDuhdmPOQLnDj7hSkIguRwosSG8lG5lGNIk1YrdmPOQLnDj7hSkImjP454wWDl4UfKFb3VaMVGqDuhdhjRPZMNZe(KH3xIb1QLJel4WHfC)cc1rDmCKSMoBEot4tgEFjguRwosSG8lWsIJBW7lb3JyhI3EVG7wWDWz6CYrMqrYuGHmDdgqMYfiJWj1QLJeqBHtnf13Wj2xfVDJ9hjmcsdF4mHQGqLcNHIKPy4tQl8hEPyb8DbzLdCMoNCKjuKmfyit3GbKPCfYiCsTA5ib0w4utr9nCILqiQfeYeVHvfnHXWzcvbHkfodfjtXikwYeVru0c47cYI)li)cSK44g8(sW9i2H4T3Wz6CYrMqrYuGHmDdgqMULdKr4utr9nCYwTWIAbHGtQvlhjG2cdit3UbzeoPwTCKaAlCQPO(go59LWepcrDaNjufeQu4KNIk1Yrd15mIpWgjVfKFbmFbP)DI3Ep49LWqijVO(Ei5TG8liuKmfJOyjt8grrlWMfCA4mDo5itOizkWqMUbdit3YcYiCsTA5ib0w4mHQGqLcNiPM4EKmn80QTqKEcHmEy1Xoi(aPYZJeli)c4POsTC0q8b2i5TG8liuKmfdFsDH)WlflWMfK7CGtnf13Wj2xfVDJ9hjmcsdFyaz6wUHmcNuRwosaTfotOkiuPWj2JCotOizkWdSVkE7MesX(l4Ab3wq(fC)cs)7eV9EG9vXB3Kqk2FK8vKmHxW1cY9coCybcYsIJBG9vXB3Kqk23iiljoUHK3coCybAkQVhyFv82njKI9hvB4CLSFSGdhwqOizkgrXsM4nIIwaFxq6FN4T3dSVkE7MesX(dojNZGOKVIKjtuS0cUBb5xaslHH4rDmuHapQEb2SGCNdCQPO(goX(Q4TBsif7ddit3onKr4KA1YrcOTWzcvbHkforAjmepQJHke4r1lWMfK7Cwq(fG9iNZeksMc8a7RI3UjHuS)cSzb3Gtnf13Wj2xfVDtcPyFyaz6g)HmcNuRwosaTfo1uuFdNSvlmysrWz6CYrMqrYuGHmDdoRoiesYlmfhCgv6eSnxzbNvhecj5fMILLeLgeCEdotOkiuPWj2JCotOizkWd2QfgmPOfyZc4POsTC0GTAHbtkYKKINJBb5xGLeh3qOOtmH)lj7h4HKhCM81QHZBWaY0nMfYiCsTA5ib0w4utr9nCYwTWW50ZWz1bHqsEHP4GZOsNGT5kR8P)DI3Ep49LWy9Uyi5bNvhecj5fMILLeLgeCEdotOkiuPWPLeh3qOOtmH)lj7h4HK3cYVaEkQulhneFGnsEWzYxRgoVbdit3Y2qgHtQvlhjG2cNsyYy3VCKjP4OAzit3Gtnf13WjMuu1YMUK9dwfrWz6CYrMqrYuGHmDdotOkiuPW59lGNIk1YrdmPOQLnDj7hSkImjP454wq(fC)cCepYTa(Ua(Nll4WHfW8fK(3jE79W7Ttit1Cs467HK3cUBb3TGdhwW9lq8Xa7RI3UX(JegpT6bI4qe2xTC0cYVaSh5CMqrYuGhSvlmysrlWMfCBb3bdit3YfiJWj1QLJeqBHtjmzS7xoYKuCuTmKPBWPMI6B4KTAHXYP4aotOkiuPWjpfvQLJgIpWgjpyaz6wUczeoPwTCKaAlCMqvqOsHtEkQulhneFGnsEli)cqAjmepQJb7ZJyPogvVaBwqsXHjkwAbzUGCg8Fb5xa2JCotOizkWd2QfgmPOfW3fCA4utr9nCYwTWy5uCaditzLdKr4KA1YrcOTWzcvbHkforehIW(QLJwq(feksMIruSKjEJOOfyZco9cYVaMVGqDuhd2ctOZdQvlhjwq(feQJ6y4HpN8RKXv9jdQvlhjwq(fG9iNZeksMc8GTAHbtkAb2SGSGtnf13Wj2xfVDJ9hjmEA1WaYuw3GmcNuRwosaTfo1uuFdNyFv82n2FKW4PvdNjufeQu4erCic7RwoAb5xqOizkgrXsM4nIIwGnl40li)cy(cc1rDmylmHopOwTCKyb5xW9lG5liuh1XWdFo5xjJR6tguRwosSGdhwW9liuh1XWdFo5xjJR6tguRwosSG8la7roNjuKmf4bB1cdMu0c471cYAb3TG7GZ05KJmHIKPadz6gmGmLvwqgHtQvlhjG2cNAkQVHtEkRxHQKjEPKpCMqvqOsHteXHiSVA5OfKFbHIKPyeflzI3ikAb2SaMDbhoSG7xqOoQJbBHj05b1QLJeli)ceFmW(Q4TBS)iHXtREGioeH9vlhTG7wWHdlWsIJBi1Csix1YgHIoPjmEi5bNPZjhzcfjtbgY0nyazkRCdzeoPwTCKaAlCQPO(gozRwyWKIGZ05KJmHIKPadz6gCwDqiKKxyko4mQ0jyBUYcoRoiesYlmflljkni48gCMqvqOsHtSh5CMqrYuGhSvlmysrlWMfWtrLA5ObB1cdMuKjjfphhCM81QHZBWaYuwNgYiCsTA5ib0w4utr9nCYwTWW50ZWz1bHqsEHP4GZOsNGT5kR8P)DI3Ep49LWy9Uyi5bNvhecj5fMILLeLgeCEdot(A1W5nyazkl(dzeo1uuFdNyFv82n2FKW4PvdNuRwosaTfgWagWjpcHRVHmLvozLto56n(pUbN2vuxTmgo5Jz9EuqIfWSlqtr99cCfoWJ9iCI9OeKPS4FUaNEONRCeCM9fm9vXBFb8dQiCShZ(cMKxqSweAbzLddliRCYkN94Em7lGpKzaLKcsSalI7r0cspRLglWIKRgpwaZykrEbEb9387(kILtYTanf134f8T78ypQPO(gp8qu6zT04IZP4t2JAkQVXdpeLEwlnY8kdU)f7rnf134HhIspRLgzELHkjZsDOr99Em7ly2Qh2)JfG0sSaljoosSaCObEbwe3JOfKEwlnwGfjxnEbAlwGhI439(iQwEbfEbIVPXEutr9nE4HO0ZAPrMxzGB1d7)HbhAG3JAkQVXdpeLEwlnY8kdVpQV3JAkQVXdpeLEwlnY8kdSVkE7CpILHI7I5wsCCdSVkE7CpIDi5Th1uuFJhEik9SwAK5vgsyYubXYqRS0LMTW(ksXgUVdZZz8E7eApQPO(gp8qu6zT0iZRm4POsTCedTYsxSvlmysrMKu8CCm8ExykyGN6KORBzIKAI7rY0Gcc1QZKuNZeVj8jdVVedIpqQ88iXEutr9nE4HO0ZAPrMxzWwTWy5uCSh3JzFb8HmdOKuqIfq8i05feflTGWNwGMIhTGcVaLNwo1YrJ9OMI6B8fUCuNO9OMI6BCMxz49r9ndf3LLeh3WY9VWjHJbI0uC4qOizkgrXsM4nII47vUKZHdHIKPy4tQl8hEPGV5M)7rnf134mVYGNIk1Yrm0klDj(aBK8y49UWuWap1jrxIpgyFv82n2FKW4PvpIkDs1Y5fFm4PSEfQsM4Ls(JOsNuT8Eutr9noZRm4POsTCedTYsxQZzeFGnsEm8ExykyGN6KOlXhdSVkE7g7psy80QhrLoPA58Ipg8uwVcvjt8sj)ruPtQwoV4JHG49sOQLnEovwIgrLoPA59OMI6BCMxzWtrLA5igALLUWKIQw20LSFWQiYKKINJJH37ctbd8uNeDH9iNZeksMc8GTAHbtkYMS2JAkQVXzELbsQnAkQVnUchm0klDXQvVh3JAkQVXJKaF592jKPAojC9ndf3LLeh3G3xcUhXoK82JAkQVXJKaN5vgCkzKLuKO0gVh1uuFJhjboZRmyRwiRSeMHI7QAS2vCMV5Ao5zULeh3G3xcUhXoK82JAkQVXJKaN5vgsT)7oB6NNYqXDH0syiEuhdviWJQTH)5Sh1uuFJhjboZRmS(VnpNj8jJItulibdf3fZTK44g8(sW9i2HKxEMN(3jE79G3xcdHK8I67HKxESh5CMqrYuGhSvlmysr2ClpZd1rDmWKIQw20LSFWQiAqTA5iXHd3BjXXn49LG7rSdjV8ypY5mHIKPapyRwyWKI4Bw5zEOoQJbMuu1YMUK9dwfrdQvlhjU7WH7TK44g8(sW9i2HKx(qDuhdmPOQLnDj7hSkIguRwosC3Eutr9nEKe4RK6Cgnf13gxHdgALLUimM6eH3JzFb8jXPsUybCQZzPPtwa3JwGewTC0cQGyXzZfCQyAbFVG0)oXBVh7rnf134rsGZ8kdjmzQGyX7X9OMI6B8W6)(sXjQfKWy5uCWqXDH9iNZeksMc8GTAHbtkIVx5EpQPO(gpS(VZ8kdfNOwqct)8ugkUR7XEKZzcfjtbEWwTWGjfztw5d1rDmWKIQw20LSFWQiAqTA5iXHd3J9iNZeksMc8GTAHbtkYMB5zEOoQJbMuu1YMUK9dwfrdQvlhjU7U8ypY5mHIKPapuCIAbjm9ZtT52ECpQPO(gpimM6eHVyj2hD28CgNuQegbIuw8Eutr9nEqym1jcN5vgwU)fMNZe(KHAI98Eutr9nEqym1jcN5vgYsksuABEoJMTi0h(7rnf134bHXuNiCMxzW9jjmjmA2IqvqglszzO4UWEKZzcfjtbEWwTWGjfzZvwhoG0syiEuhdviWJQTHzZzpQPO(gpimM6eHZ8kdpjuXDUAzJLtXbdf3f2JCotOizkWd2QfgmPiBUY6WbKwcdXJ6yOcbEuTnmBo7rnf134bHXuNiCMxzK(orDG0GegoNYsm4QMmjXfZYqXDfflX3RB5C4aNKZzquYxrYKjkwIVYjXHdHIKPyeflzI3ikIV8FpQPO(gpimM6eHZ8kdu555it1gSNMO9OMI6B8GWyQteoZRmqK6vTSHZPSeEpQPO(gpimM6eHZ8kd7pYj4rvBqe(BTt0Eutr9nEqym1jcN5vgHpzKARxQfgUhLO94Eutr9nEWQvFLuNZOPO(24kCWqRS0L1)ndf3LLeh3W6)28CMWNmkorTGedjV9y2xW8CNwGK3c4xFj4Ee7c0wSa(5TtOfWh3Cs467fKn(3jE7nEbAlwWZTajC1YlGF7d(1c8(3TGQXAxX5fyrCpIwqsXr1YJ9OMI6B8GvRoZRm49LWqijVO(MHI76EhXJC8L)5YHdP)DI3Ep8E7eYunNeU(Ei5Dx(QXAxXzBUoDo5VN5H6OogoswtNnpNj8jdVVedQvlhjoC4(qDuhdhjRPZMNZe(KH3xIb1QLJe5fFmeeVxcvTSXZPYs0iQ0jvlF3D7rnf134bRwDMxzW7lHX6Dbdf3v1yTR48qqCvQcBUUX)9OMI6B8GvRoZRmsQZz0uuFBCfoyOvw6kjW7XSVa(brCeAbXVajmTa(uzBnQVxaZ4KzKFwqXTaTpVa(8zCbfEb9hlqYBpQPO(gpy1QZ8kdHY2AuFZq6CYrMqrYuGVUXqXDXCEkQulhnuNZi(aBK82JzFbNkMwaFs8Eju1YlGFCQSeTauj7hlWI4EeTGZV0cK)fuD8lqxa)2h8RfWV(sW9i2XEutr9nEWQvN5vgcI3lHQw245uzjIHI7kuh1XWrYA6S55mHpz49LyqTA5ir(0)oXBVh8(syiKKxuFpK8Yxnw7koFDlNC2JzFb853mZJfiHPfWNeVxcvT8c4hNklrlO4wW5xAbjTxGmflO64xa)6lb3Jyxq14Gubdl4rlO4wWKuu1YlGPs2pyveTGcVGqDuhKybAlwG9Y5wGFflG6xs2FbHIKPap2JAkQVXdwT6mVYqq8Eju1YgpNklrmKoNCKjuKmf4RBmuCx3JioeH9vlhD4q1yTR4SnzB(Fx(7DepYXx(NlhoW80)oXBVhEVDczQMtcxFpK8Ul)9mpuh1XatkQAztxY(bRIOb1QLJehoCFOoQJbMuu1YMUK9dwfrdQvlhjYZCEkQulhnWKIQw20LSFWQiYKKINJ7U7YFpZd1rDmCKSMoBEot4tgEFjguRwosC4W9H6OogoswtNnpNj8jdVVedQvlhjYBjXXn49LG7rSdXBVV7U9y2xWPIPfm9vXBFbmtpsKnxaFsA4VGIBbHpTGqrYuSGcVa16LIfe)cefn2JAkQVXdwT6mVYa7RI3UX(JegbPHpdPZjhzcfjtb(6gdf3vOizkg(K6c)Hxk4Bw5ShZ(covmTGPecrTGqli(fWhPIMW4f89c0feksMIfe(ASGcVa5VA5fe)cefTanwq4tlavY(XcIILg7rnf134bRwDMxzGLqiQfeYeVHvfnHXmKoNCKjuKmf4RBmuCxHIKPyeflzI3ikIVzX)8wsCCdEFj4Ee7q8279OMI6B8GvRoZRmyRwyrTGq7XSVGtftlGF9Lybm(ie1Xc(2DEbf3cuNBb85ZiEbkIwGMIIhTaTfli8PfeksMIfy)BM5XcefTaHeQA5fe(0cs(A3KBSh1uuFJhSA1zELbVVeM4riQdgsNtoYeksMc81ngkUlEkQulhnuNZi(aBK8YZ80)oXBVh8(syiKKxuFpK8YhksMIruSKjEJOiBo9Em7l4uX0cMmtzt(CbQ1ZJwqUZHz2fWme)Sa7(uVa(rR2cr6jeAb8dwDSlW7TtOfu4fOPO4r7rnf134bRwDMxzG9vXB3y)rcJG0WNHI7cj1e3JKPHNwTfI0tiKXdRo2bXhivEEKippfvQLJgIpWgjV8HIKPy4tQl8hEPWMCNZEm7l4uX0cuNBbjFfjt4f8Cly6RI3(cYgif7VGQxGUa0BFbFVGz1YoAbHIKPGHf8OfuCli8Pfy9y8ck8cuRxkwq8lqu0ypQPO(gpy1QZ8kdSVkE7MesX(muCxypY5mHIKPapW(Q4TBsif7FDl)9P)DI3EpW(Q4TBsif7ps(ksMWx5(WbbzjXXnW(Q4TBsif7BeKLeh3qY7Wbnf13dSVkE7MesX(JQnCUs2poCiuKmfJOyjt8grr8n9Vt827b2xfVDtcPy)bNKZzquYxrYKjkw6U8iTegIh1Xqfc8OABYDo7XSVGtftly6RI3(cYgif7VGVxq2GpxGu7imEbHpHOfOiAbQqGxq1PNTA5XEutr9nEWQvN5vgyFv82njKI9zO4UqAjmepQJHke4r12K7CYJ9iNZeksMc8a7RI3UjHuSVn32JzFbNkMwaFu1IfmjfTG4xq6BSelTa(urNSag9Fjz)aVap0NWl47fWmEk8HJfW4PWNNYcYgFZvi2fu4fe(fEbfEb6c8lzFcTapu9OkoVGWx7fGiXhr1Yl47fWmEk8HlqQDegVaHIozbH)lj7h4fu4fOwVuSG4xquS0cEPypQPO(gpy1QZ8kd2QfgmPigsNtoYeksMc81ngkUlSh5CMqrYuGhSvlmysr2WtrLA5ObB1cdMuKjjfphxEljoUHqrNyc)xs2pWdjpgs(A1x3yO6GqijVWuSSKO0GUUXq1bHqsEHP4UIkDc2MRS2JzFbNkMwaFu1IfWmStpVG4xq6BSelTa(urNSag9Fjz)aVap0NWl47fmzCSagpf(8uwq24BUcXUGIBbHFHxqHxGUa)s2NqlWdvpQIZli81Ebis8ruT8cKAhHXlqOOtwq4)sY(bEbfEbQ1lfli(feflTGxk2JAkQVXdwT6mVYGTAHHZPNzO4USK44gcfDIj8Fjz)apK8YZtrLA5OH4dSrYJHKVw91ngQoiesYlmflljknORBmuDqiKKxykUROsNGT5kR8P)DI3Ep49LWy9Uyi5ThZ(covmTGjPOQLxatLSFWQiAbf3co)slWE5ClWVIfOXcCKIJfK7feksMc8c0wSa(5TtOfWh3Cs467fOTyb8RVeCpIDbkIwq)XcqKkoZWcE0cIFbiIdry)fmzMYM8Zc(EbH9FbpAbSpIwqOizkWJ9OMI6B8GvRoZRmWKIQw20LSFWQiIbjmzS7xoYKuCuT81ngsNtoYeksMc81ngkUR75POsTC0atkQAztxY(bRIitskEoU837iEKJV8pxoCG5P)DI3Ep8E7eYunNeU(Ei5D3DhoCV4Jb2xfVDJ9hjmEA1deXHiSVA5O8ypY5mHIKPapyRwyWKIS52D7XSVagpf(8uwqYxBzAbUxUsl47fy3N6fe)cKW0cQghAhlWYP4aVh1uuFJhSA1zELbB1cJLtXbdsyYy3VCKjP4OA5RBmuCx8uuPwoAi(aBK82JzFbmEk85PSa(fHkUZliuKmfliPE7rnf134bRwDMxzWwTWy5uCWqXDXtrLA5OH4dSrYlpslHH4rDmyFEel1XOABskomrXszMZG)5XEKZzcfjtbEWwTWGjfX3tVhZ(cMEuQu3csFlQO(EbXVaC8EliP4OA5fmzMYM8Zc(Ebphh)EOizkWlWUp1lGRK9JQLxqUxWJwa7JOfGdnDcjwa7BHxG2IfiHRwEb8d(CYVslGFR6twG2IfW0PW4c4JkmHop2JAkQVXdwT6mVYa7RI3UX(JegpTAgkUleXHiSVA5O8HIKPyeflzI3ikYMtNN5H6OogSfMqNhuRwosKpuh1XWdFo5xjJR6tguRwosKh7roNjuKmf4bB1cdMuKnzThZ(cyMHiVfmzMYM8ZcK8wW3lqXlGv7ZliuKmf4fO4f49yCz5igwaXmirEXcS7t9c4kz)OA5fK7f8OfW(iAb4qtNqIfW(w4fyVc)fWp4Zj)kTa(TQpzSh1uuFJhSA1zELb2xfVDJ9hjmEA1mKoNCKjuKmf4RBmuCxiIdryF1Yr5dfjtXikwYeVruKnNopZd1rDmylmHopOwTCKi)9mpuh1XWdFo5xjJR6tguRwosC4W9H6OogE4Zj)kzCvFYGA1YrI8ypY5mHIKPapyRwyWKI47vw3D3Eutr9nEWQvN5vg8uwVcvjt8sjFgsNtoYeksMc81ngkUleXHiSVA5O8HIKPyeflzI3ikYgM9WH7d1rDmylmHopOwTCKiV4Jb2xfVDJ9hjmEA1deXHiSVA5O7oCWsIJBi1Csix1YgHIoPjmEi5Th1uuFJhSA1zELbB1cdMuedPZjhzcfjtb(6gdf3f2JCotOizkWd2QfgmPiB4POsTC0GTAHbtkYKKINJJHKVw91ngQoiesYlmflljknORBmuDqiKKxykUROsNGT5kR9OMI6B8GvRoZRmyRwy4C6zgs(A1x3yO6GqijVWuSSKO0GUUXq1bHqsEHP4UIkDc2MRSYN(3jE79G3xcJ17IHK3Eutr9nEWQvN5vgyFv82n2FKW4PvddyaHa]] )


end
