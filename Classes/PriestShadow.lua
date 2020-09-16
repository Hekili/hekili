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
            id = 341273,
            duration = 15,
            max_stack = 1,
        },
        unfurling_darkness_icd = {
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
            
            spend = 50,
            spendType = "insanity",
            
            startsCombat = true,
            texture = 252997,

            cycle = "devouring_plague",
            
            handler = function ()
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
            cast = 1.5,
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

                removeBuff( "unfurling_darkness" )
                
                if talent.unfurling_darkness.enabled and buff.unfurling_darkness_icd.down then
                    applyBuff( "unfurling_darkness" )
                    applyBuff( "unfurling_darkness_icd" )
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
            buff = "voidform",
            bind = "void_eruption",

            handler = function ()
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

            nobuff = "voidform",
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
                    max_stack = 10 -- ???
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
            -- hasteCD = true, -- ???
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


    spec:RegisterPack( "Shadow", 20200915, [[dSubYaqikv6ruQ4sQcL0Muf9juujJIsrNIsHxjkAwQQCluuP2Ls(fLQgMOshtvQLjk8mvHmnuK6AIs12qrvFtukmovb6COOuRdfvmpvbDpvL9jk5GIsrlKsPhIIsMikcxefj1gvfkvJuvOuojks0kfv9svHsmtuuWnrrs2jk4NIsPHIIONQutvvvxvvaBvvO6RQcf7f0FPyWahM0If0JfzYeDzKntjFMqJMGtl51IkMTq3gv2Tu)wLHlWXrrclhYZHA6uDDuA7OQ(oQY4rrHoVQK1JIIMpk0(vm8n8pClvNGmKrUzKBUm73zFLrUzpJCFd3(RacUd0uoQib3TYrW9wqLhp4oqFfpvc)d34JfLi4wW9amZXE7flxGnCLoo7XfhBu966esTC7XfxYE4oKTIotzddHBP6eKHmYnJCZLz)o7RmYn7VZoZgUvwx4qW9U4ywWTqjLuddHBjHtWTDgWwqLhVbWKOIW(K3odytboXfsOb8o7)gqg5MrUWDSWog(hUjmM6eHH)Hm8g(hU1Kxxd3Ce3HEzoltKnvsJerkhgUPwdJKeAl0HmKb8pCRjVUgUdJ3jnNLXfid1e3l4MAnmssOTqhYWJG)HBn511WTiRIKL2MZYOmtcDUaCtTggjj0wOdzGPH)HBQ1WijH2c3ju5eQu4ghqXOXvKi54fx1sdMu0aY6BazmagzCaiTKgIp1(sLs8Q6bK1ay(CHBn511WT1LyXK0OmtcvozcjLd6qgYo8pCtTggjj0w4oHkNqLc34akgnUIejhV4QwAWKIgqwFdiJbWiJdaPL0q8P2xQuIxvpGSgaZNlCRjVUgUdyrL1RQfnHrf7qhYaZd)d3uRHrscTfU1Kxxd3PRtu7i1jPXkQCeCNqLtOsHBV4Ob8WVb8o3bWiJdWIngnikjOirY4fhnGhoaXKCamY4aCfjs(YloY4Nrw0aE4aYoChRMmjjCZ8qhYq2a(hU1Kxxd3OkiisMQn4anrWn1AyKKqBHoKHhe(hU1Kxxd3isdQw0yfvocd3uRHrscTf6qgy2W)WTM86A4M3HIs(u1geHVw7eb3uRHrscTf6qgENl8pCRjVUgUDbYW2HhBlnwhkrWn1AyKKqBHo0HBjzPSrh(hYWB4F4wtEDnCJRi1jcUPwdJKeAl0HmKb8pCtTggjj0w4oHkNqLc3HSwwRW4DYil2xist(ayKXb4ksK8LxCKXpJSOb8WVb8G5oagzCaUIejFjqA0fwbjFapCapk7WTM86A4o486AOdz4rW)Wn1AyKKqBH7laUXKd3AYRRHB(kQ0Wib381ilb3YZxybvE8m8oK0eOvV8kLt1Id45aKNV4RCbfQsg)ytclVs5uTiCZxrMw5i4wEo2WgaDidmn8pCtTggjj0w4(cGBm5WTM86A4MVIknmsWnFnYsWT88fwqLhpdVdjnbA1lVs5uT4aEoa55l(kxqHQKXp2KWYRuovloGNdqE(ss8pwu1IMGOkYslVs5uTiCZxrMw5i4wJrJ8CSHna6qgYo8pCtTggjj0w4(cGBm5WTM86A4MVIknmsWnFnYsWnoGIrJRirYXlUQLgmPObK1aYaU5RitRCeCJjfvTOPlrbNtrKjX6NLf0HmW8W)Wn1AyKKqBHBn511WnITnAYRRnXc7WDSWUPvocU50QHo0H7aeLoUq1H)Hm8g(hUPwdJKeAl0HmKb8pCtTggjj0wOdz4rW)Wn1AyKKqBHoKbMg(hUPwdJKeAl0HmKD4F4wtEDnChCEDnCtTggjj0wOdzG5H)HBQ1WijH2c3ju5eQu42UdiK1YAHfu5XZ6qCl2a4wtEDnCJfu5XZ6qCqhYq2a(hUPwdJKeAlC3khb3kZelOifBSU2nNLj44ri4wtEDnCRmtSGIuSX6A3CwMGJhHGoKHhe(hUPwdJKeAlCFbWnMC4wtEDnCZxrLggj4MVgzj4(9aYCai2MSoKiTiNqTgnjngn(zCbYW)k5IykyRGasc38vKPvocU5QwAWKImjw)SSGoKbMn8pCRjVUgU5QwAcJk2HBQ1WijH2cDOd3jjg(hYWB4F4MAnmssOTWTM86A4oPXOrtEDTjwyhUJf2nTYrWnHXuNim0HmKb8pCRjVUgUzXKPCIdd3uRHrscTf6qhU50QH)Hm8g(hUPwdJKeAlCNqLtOsH70Dr5XRxbhpczQ2IfxxVydgWZbunw7YFnGS(gatN7aEoaBoa7oaxJu7RijQPxMZY4cKH)vYf1AyKKdGrghGnhGRrQ9vKe10lZzzCbYW)k5IAnmsYb8CaYZxsI)XIQw0eevrwA5vkNQfhGngGnGBn511Wn)RKgcXg411qhYqgW)Wn1AyKKqBH7eQCcvkCB3bipFjj(hlQArtqufzPfISqewqdJeCRjVUgU5FL0eErh6qgEe8pCtTggjj0w4wtEDnCN0y0OjVU2elSd3Xc7Mw5i4ojXqhYatd)d3AYRRHBPY1Qxxd3uRHrscTf6qgYo8pCtTggjj0w4oHkNqLc3UgP2xrsutVmNLXfid)RKlQ1WijhWZbKUlkpE9I)vsdHyd866fBWaEoGQXAx(Rb8nG35MlCRjVUgULe)JfvTOjiQISe0HmW8W)Wn1AyKKqBHBn511WTK4FSOQfnbrvKLG7eQCcvkCBZbGileHf0WinagzCavJ1U8xdiRbKnY(aSXaEoa7oG0Dr5XRxbhpczQ2IfxxVydgWZbyZby3b4AKAFHjfvTOPlrbNtr0IAnmsYbWiJdWMdW1i1(ctkQArtxIcoNIOf1AyKKd45aS7a4ROsdJ0ctkQArtxIcoNIitI1plRbyJbyJb8Ca2Ca2DaUgP2xrsutVmNLXfid)RKlQ1WijhaJmoaBoaxJu7RijQPxMZY4cKH)vYf1AyKKd45aczTSw8VsADiUL841dWgdWgWD6vksgxrIKJHm8g6qgYgW)Wn1AyKKqBHBn511WnwqLhpdVdjnssDb4oHkNqLc3UIejFjqA0fwbjFapCazKlCNELIKXvKi5yidVHoKHhe(hUPwdJKeAlCRjVUgUXSie1scz8ZWPYMWy4oHkNqLc3UIejF5fhz8ZilAapCazK9b8CaHSwwl(xjToe3sE8A4o9kfjJRirYXqgEdDidmB4F4wtEDnCZvTmKAjHGBQ1WijH2cDidVZf(hUPwdJKeAlCRjVUgU5FL04hcrTd3ju5eQu4MVIknmslngnYZXg2Gb8Ca2DaP7IYJxV4FL0qi2aVUEXgmGNdWvKi5lV4iJFgzrdiRbW0WD6vksgxrIKJHm8g6qgE)g(hUPwdJKeAlCNqLtOsHBeBtwhsKwbA1HisZHqMaSg5wetbBfeqYb8Ca8vuPHrAjphBydgWZb4ksK8LaPrxyfK8bK1aEuUWTM86A4glOYJNH3HKgjPUa0Hm8od4F4MAnmssOTWDcvoHkfUXbumACfjsoEHfu5XZKqkwyaFd49aEoaBoG0Dr5XRxybvE8mjKIfwjbfjs4b8nGhnagzCaskK1YAHfu5XZKqkwWiPqwlRfBWayKXbOjVUEHfu5XZKqkwyvTXkwIc(ayKXb4ksK8LxCKXpJSOb8WbKUlkpE9clOYJNjHuSWYIngnikjOirY4fhnaBmGNdaPL0q8P2xQuIxvpGSgWJYfU1Kxxd3ybvE8mjKIfGoKH3pc(hUPwdJKeAlCNqLtOsHBKwsdXNAFPsjEv9aYAapk3b8Ca4akgnUIejhVWcQ84zsiflmGSgWB4wtEDnCJfu5XZKqkwa6qgEZ0W)Wn1AyKKqBHBn511Wnx1sdMueCNELIKXvKi5yidVH7QDcHydCtzb3ELYbN1xgWD1oHqSbUP44izPob3VH7eQCcvkCJdOy04ksKC8IRAPbtkAazna(kQ0WiT4QwAWKImjw)SSgWZbeYAzTKkkhJlCSIcoEXga3jbTA4(n0Hm8o7W)Wn1AyKKqBHBn511Wnx1sJvuFb3v7ecXg4MYcU9kLdoRVmEMUlkpE9I)vst4f9fBaCxTtieBGBkooswQtW9B4oHkNqLc3HSwwlPIYX4chROGJxSbd45a4ROsdJ0sEo2Wga3jbTA4(n0Hm8M5H)HBQ1WijH2c3SyYWtOIKjPyVAridVHBn511WnMuu1IMUefCofrWD6vksgxrIKJHm8gUtOYjuPWTnhaFfvAyKwysrvlA6suW5uezsS(zznGNdWUdiDxuE86vWXJqMQTyX11l2GbyJbWiJdWMdqE(clOYJNH3HKMaT6fISqewqdJ0aEoaCafJgxrIKJxCvlnysrdiRb8Ea2a6qgENnG)HBQ1WijH2c3SyYWtOIKjPyVAridVHBn511Wnx1styuXoCNqLtOsHB(kQ0WiTKNJnSbqhYW7he(hUPwdJKeAlCNqLtOsHB(kQ0WiTKNJnSbd45aqAjneFQ9f3XN4O2xvpGSgqsXUXloAazoGCxzFaphaoGIrJRirYXlUQLgmPOb8WbW0WTM86A4MRAPjmQyh6qgEZSH)HBQ1WijH2c3ju5eQu4grwiclOHrAaphGRirYxEXrg)mYIgqwdGPhWZby3b4AKAFXvyc9ArTggj5aEoaxJu7Ra8RKqLmXQZzrTggj5aEoaCafJgxrIKJxCvlnysrdiRbKbCRjVUgUXcQ84z4DiPjqRg6qgYix4F4MAnmssOTWTM86A4glOYJNH3HKMaTA4oHkNqLc3iYcrybnmsd45aCfjs(YloY4Nrw0aYAam9aEoa7oaxJu7lUctOxlQ1WijhWZbyZby3b4AKAFfGFLeQKjwDolQ1WijhaJmoaBoaxJu7Ra8RKqLmXQZzrTggj5aEoaCafJgxrIKJxCvlnysrd4HFdiJbyJbyd4o9kfjJRirYXqgEdDidz8g(hUPwdJKeAlCRjVUgU5RCbfQsg)ytcWDcvoHkfUrKfIWcAyKgWZb4ksK8LxCKXpJSObK1ay(bWiJdWMdW1i1(IRWe61IAnmsYb8CaYZxybvE8m8oK0eOvVqKfIWcAyKgGngaJmoGqwlRfBBXIIvlAKkkNMW4fBaCNELIKXvKi5yidVHoKHmYa(hUPwdJKeAlCRjVUgU5QwAWKIG70RuKmUIejhdz4nCxTtieBGBkl42Ruo4S(YaUR2jeInWnfhhjl1j4(nCNqLtOsHBCafJgxrIKJxCvlnysrdiRbWxrLggPfx1sdMuKjX6NLfCNe0QH73qhYqgpc(hUPwdJKeAlCRjVUgU5QwASI6l4UANqi2a3uwWTxPCWz9LXZ0Dr5XRx8VsAcVOVydG7QDcHydCtXXrYsDcUFd3jbTA4(n0HmKbtd)d3AYRRHBSGkpEgEhsAc0QHBQ1WijH2cDOdD4MpHW11qgYi3mYn3hmJheU5POUArmCZuYfCiNKdi7dqtED9aIf2XRjpCJdOeKHmY(dc3bOZQIeCBNbSfu5XBamjQiSp5TZaYMSISyFaz8G)gqg5MrUt(jVDgatnZiLyDsoGqY6q0ashxO6diKeRgVgq2mLOahpG(AMBbfXzXghGM86A8aUo(An51KxxJxbikDCHQ)zfvCotEn5114vaIshxO6z(zV1DYjVM86A8karPJlu9m)Sxzf5O2vVUEYBNbSBnalC(aqAjhqiRLfjha2vhpGqY6q0ashxO6diKeRgpaTLdiarm3bN7vloGcpa510AYRjVUgVcqu64cvpZp7XTgGfo3GD1XtEn5114vaIshxO6z(zFW511tEn5114vaIshxO6z(zpwqLhpRdX9RS(SBiRL1clOYJN1H4wSbtEn5114vaIshxO6z(zplMmLtC)ALJ(uMjwqrk2yDTBoltWXJqtEn5114vaIshxO6z(zpFfvAyK(1kh9XvT0GjfzsS(zz97c(WK)JVgzPV3zIyBY6qI0ICc1A0K0y04NXfid)RKlIPGTcci5KxtEDnEfGO0XfQEMF2ZvT0egvSp5N82zam1mJuI1j5ai(e61a8IJgGlqdqt(HgqHhGYxROggP1KxtEDn(dxrQt0KxtEDnoZp7doVU(xz9fYAzTcJ3jJSyFHin5mYORirYxEXrg)mYIE43dMlJm6ksK8LaPrxyfK8h(OSp51KxxJZ8ZE(kQ0Wi9Rvo6tEo2Wg87c(WK)JVgzPp55lSGkpEgEhsAc0QxELYPAXNYZx8vUGcvjJFSjHLxPCQwCYRjVUgN5N98vuPHr6xRC0NgJg55ydBWVl4dt(p(AKL(KNVWcQ84z4DiPjqRE5vkNQfFkpFXx5ckuLm(XMewELYPAXNYZxsI)XIQw0eevrwA5vkNQfN8AYRRXz(zpFfvAyK(1kh9HjfvTOPlrbNtrKjX6NL1Vl4dt(p(AKL(WbumACfjsoEXvT0GjfLvgtEn5114m)ShX2gn511MyH9FTYrFCA1t(jVM86A8kjXFjngnAYRRnXc7)ALJ(imM6eHN82zambzPSrFawAmgQPCgG1HgalwdJ0akN4WmNb8ayAaxpG0Dr5XRxtEn5114vsIZ8ZEwmzkN4Wt(jVM86A8IWyQte(JJ4o0lZzzISPsAKis5WtEn5114fHXuNiCMF2hgVtAolJlqgQjUxtEn5114fHXuNiCMF2lYQizPT5SmkZKqNlm51KxxJxegtDIWz(zV1LyXK0OmtcvozcjL7xz9HdOy04ksKC8IRAPbtkkRVmyKrKwsdXNAFPsjEvDwmFUtEn5114fHXuNiCMF2hWIkRxvlAcJk2)vwF4akgnUIejhV4QwAWKIY6ldgzePL0q8P2xQuIxvNfZN7KxtEDnErym1jcN5N9PRtu7i1jPXkQC0Vy1Kjj)y(FL1NxC0d)ENlJmAXgJgeLeuKiz8IJEOysYiJUIejF5fhz8Zil6HzFYRjVUgVimM6eHZ8ZEufeejt1gCGMOjVM86A8IWyQteoZp7rKguTOXkQCeEYRjVUgVimM6eHZ8ZEEhkk5tvBqe(ATt0KxtEDnErym1jcN5N9Uazy7WJTLgRdLOj)K3ody)QtdGnyap(vsRdXnaTLdGjpEeAamLTflUUEamR7IYJxJhG2YbCwdGfxT4aygo)XhqWDXbunw7YFnGqY6q0ask2RwCn51KxxJxCA1F8VsAieBGxx)RS(s3fLhVEfC8iKPAlwCD9In4z1yTl)vwFmDUpTPDDnsTVIKOMEzolJlqg(xjxuRHrsYiJ201i1(ksIA6L5SmUaz4FLCrTggj5t55ljX)yrvlAcIQilT8kLt1I2WgtE7mGSTJVgalMgWJFLCa2ErFaL1aycI)XIQwCamzufzPbipc3mx(aAIKdarwiclqY1KxtEDnEXPvN5N98VsAcVO)RS(SR88LK4FSOQfnbrvKLwiYcrybnmstEn5114fNwDMF2N0y0OjVU2elS)Rvo6ljXtE7maMerweAa(nawmnaMq5A1RRhq2CNnzYbuwdq7xdGjU)dOWdOpFaSbtEn5114fNwDMF2lvUw966FPxPizCfjso(79ND5ROsdJ0sJrJ8CSHnyYBNb8ayAambX)yrvloaMmQIS0aqLOGpGqY6q0aEDSdq8gq1(naDamdN)4d4XVsADiU1KxtEDnEXPvN5N9sI)XIQw0eevrw6xz95AKAFfjrn9YCwgxGm8VsUOwdJK8z6UO841l(xjneInWRRxSbpRgRD5V(ENBUtE7maM4AMlFaSyAambX)yrvloaMmQIS0akRb86yhqs7bis(aQ2Vb84xjToe3aQg7Kk)nGdnGYAaBsrvloagkrbNtr0ak8aCnsTtYbOTCa8QyCacLpaQpwrHb4ksKC8AYRjVUgV40QZ8ZEjX)yrvlAcIQil9l9kfjJRirYXFV)vwF2erwiclOHrIrgRgRD5VYkBKDB80UP7IYJxVcoEeYuTflUUEXg80M211i1(ctkQArtxIcoNIOf1AyKKmYOnDnsTVWKIQw00LOGZPiArTggj5t7YxrLggPfMuu1IMUefCofrMeRFww2WgpTPDDnsTVIKOMEzolJlqg(xjxuRHrsYiJ201i1(ksIA6L5SmUaz4FLCrTggj5ZqwlRf)RKwhIBjpETnSXK3od4bW0a2cQ84nGhZHKmNbWeK6cdOSgGlqdWvKi5dOWdqdpwFa(nazrRjVM86A8ItRoZp7XcQ84z4DiPrsQl8l9kfjJRirYXFV)vwFUIejFjqA0fwbj)HzK7K3od4bW0a2Sie1scna)gatLkBcJhW1dqhGRirYhGlO(ak8aeVQfhGFdqw0auFaUanaujk4dWloAn51KxxJxCA1z(zpMfHOwsiJFgov2eg)l9kfjJRirYXFV)vwFUIejF5fhz8Zil6HzK9NHSwwl(xjToe3sE86jVM86A8ItRoZp75QwgsTKqtE7mGhatd4XVsoG)hcrTpGRJVgqznanghatC)Xdqr0a0Kx8PbOTCaUanaxrIKpaExZC5dqw0aKSOQfhGlqdijODtX1KxtEDnEXPvN5N98VsA8dHO2)LELIKXvKi54V3)kRp(kQ0WiT0y0iphBydEA30Dr5XRx8VsAieBGxxVydE6ksK8LxCKXpJSOSy6jVDgWdGPbSFmmhMyaA4XNgWJY9X6aESXKdGNa1dGj1QdrKMdHgatI1i3acoEeAafEaAYl(0KxtEDnEXPvN5N9ybvE8m8oK0ij1f(vwFi2MSoKiTc0QdrKMdHmbynYTiMc2kiGKp5ROsdJ0sEo2Wg80vKi5lbsJUWki5z9OCN82zapaMgGgJdijOircpGZAaBbvE8gaZcPyHbu9a0bGoEd46bSRwmsdWvKi5)gWHgqznaxGgq4HXdOWdqdpwFa(nazrRjVM86A8ItRoZp7XcQ84zsifl8RS(WbumACfjsoEHfu5XZKqkw479tBMUlkpE9clOYJNjHuSWkjOirc)9igzusHSwwlSGkpEMesXcgjfYAzTydyKrn511lSGkpEMesXcRQnwXsuWzKrxrIKV8IJm(zKf9W0Dr5XRxybvE8mjKIfwwSXObrjbfjsgV4iB8ePL0q8P2xQuIxvN1JYDYBNb8ayAaBbvE8gaZcPyHbC9aywmXay7iHXdWfienafrdqLs8aQoDCvlUM8AYRRXloT6m)ShlOYJNjHuSWVY6dPL0q8P2xQuIxvN1JY9joGIrJRirYXlSGkpEMesXcz9EYBNb8ayAamvvlhWMu0a8BaPRXSC0aycfLZa(lCSIcoEabOlHhW1diBMTm1Rb8pBzISDamRRTke3ak8aCHcpGcpaDacLOaHgqaQou5VgGlO9aqK8CVAXbC9aYMzlt9ay7iHXdqQOCgGlCSIcoEafEaA4X6dWVb4fhnGJ1N8AYRRXloT6m)SNRAPbtk6x6vksgxrIKJ)E)RS(WbumACfjsoEXvT0GjfLfFfvAyKwCvlnysrMeRFwwpdzTSwsfLJXfowrbhVyd(Le0Q)E)RANqi2a3uCCKSuN(E)RANqi2a3uwFELYbN1xgtE7mGhatdGPQA5aESh1xdWVbKUgZYrdGjuuod4VWXkk44beGUeEaxpG9)1a(NTmr2oaM11wfIBaL1aCHcpGcpaDacLOaHgqaQou5VgGlO9aqK8CVAXbW2rcJhGur5max4yffC8ak8a0WJ1hGFdWloAahRp51KxxJxCA1z(zpx1sJvuF9RS(czTSwsfLJXfowrbhVydEYxrLggPL8CSHn4xsqR(79VQDcHydCtXXrYsD679VQDcHydCtz95vkhCwFz8mDxuE86f)RKMWl6l2GjVDgWdGPbSjfvT4ayOefCofrdOSgWRJDa8QyCacLpa1hqKuSpGhnaxrIKJhG2YbWKhpcnaMY2IfxxpaTLd4XVsADiUbOiAa95darQ81VbCOb43aqKfIWcdy)yyom5aUEaoVBahAaChIgGRirYXRjVM86A8ItRoZp7XKIQw00LOGZPi6hlMm8eQizsk2Rw879V0RuKmUIejh)9(xz9zt(kQ0WiTWKIQw00LOGZPiYKy9ZY6PDt3fLhVEfC8iKPAlwCD9InWgmYOnLNVWcQ84z4DiPjqREHileHf0Wi9ehqXOXvKi54fx1sdMuuwVTXK3od4F2Yez7ascAlsdiEIvAaxpaEcupa)galMgq1yxBFaHrf74jVM86A8ItRoZp75QwAcJk2)XIjdpHksMKI9Qf)E)RS(4ROsdJ0sEo2Wgm5TZa(NTmr2oGhNqL1Rb4ksK8bK0GjVM86A8ItRoZp75QwAcJk2)vwF8vuPHrAjphBydEI0sAi(u7lUJpXrTVQoRKIDJxCuM5UY(tCafJgxrIKJxCvlnysrpKPN82za7akvACaPRLLxxpa)ga2VGbKuSxT4a2pgMdtoGRhWzzXC7ksKC8a4jq9aSkrbVAXb8ObCObWDiAayxt5qYbWDH4bOTCaS4QfhatIFLeQ0aygQoNbOTCamKT)hatvHj0R1KxtEDnEXPvN5N9ybvE8m8oK0eOv)RS(qKfIWcAyKE6ksK8LxCKXpJSOSy6N211i1(IRWe61IAnmsYNUgP2xb4xjHkzIvNZIAnmsYN4akgnUIejhV4QwAWKIYkJjVDgWJfIcgW(XWCyYbWgmGRhGIhaN2VgGRirYXdqXdi4W4kms)gaXmMOaFa8eOEawLOGxT4aE0ao0a4oenaSRPCi5a4Uq8a4vUWays8RKqLgaZq15SM8AYRRXloT6m)ShlOYJNH3HKMaT6FPxPizCfjso(79VY6drwiclOHr6PRirYxEXrg)mYIYIPFAxxJu7lUctOxlQ1WijFAt76AKAFfGFLeQKjwDolQ1WijzKrB6AKAFfGFLeQKjwDolQ1WijFIdOy04ksKC8IRAPbtk6HFzydBm51KxxJxCA1z(zpFLlOqvY4hBs4x6vksgxrIKJ)E)RS(qKfIWcAyKE6ksK8LxCKXpJSOSyEgz0MUgP2xCfMqVwuRHrs(uE(clOYJNH3HKMaT6fISqewqdJKnyKXqwlRfBBXIIvlAKkkNMW4fBWKxtEDnEXPvN5N9Cvlnysr)sVsrY4ksKC837FL1hoGIrJRirYXlUQLgmPOS4ROsdJ0IRAPbtkYKy9ZY6xsqR(79VQDcHydCtXXrYsD679VQDcHydCtz95vkhCwFzm51KxxJxCA1z(zpx1sJvuF9ljOv)9(x1oHqSbUP44izPo99(x1oHqSbUPS(8kLdoRVmEMUlkpE9I)vst4f9fBWKxtEDnEXPvN5N9ybvE8m8oK0eOvdDOdHa]] )


end
