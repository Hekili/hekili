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

            handler = function ()
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


    spec:RegisterPack( "Shadow", 20200828, [[d00idbqiGcEKufUerrkBsQsFsPIAuevDkIkRsO4vaXSaQULqj7sKFHKmmrLJrrwgrPNjuQPPuHRruyBaf9nIIACuuLZbuQwhqjMhfvUha7dj6GaL0crs9qkQQjsuexKOiPnkvruFKOivJuPIuNuPIyLIQMjqP4MaLs7ejmuPkclvQIipvjtfiDvPkQTcuiFfOqTxi)LsdgQdtAXu4XcMmHlJAZi1Nb0OfLtlz1efjETq1SLYTjYUv53GgUs54kvKSCv9CetNQRlKTlv(UuvJxQI05POSELknFLQ2VIrMqGIwc1zefYMt2C5mpznVKSX2eyMBhOLB2gJwBAiUcKrRtLy0ALPcyF0AtnRbvbcu0IaJ(aJwzUVralurfWYZImsbOevKskQPEbVWR0ovKskqfAzevnFNCid0sOoJOq2CYMlN5jR5LKn2MKHjzrlnYZGpATkjZhTYkHGpKbAjysaT6XGxzQa2FW9eFXeFY3JbdwJagr8blR5b(GLnNS5M8t(EmyZptpGmbSm57XGJ1GbRcblg8QA8f40KVhdowd28Hxh)olgSRpq2Tf9GjMDU2ttt(Em4ynyZhED87SyWU(azp5LeBDOvu8GD4G9sITo0kkEW9Z4NhSUT1QGA040KVhdowdgSkeSyWs1jSewFRNnyJiA6b7WbRDWsmyJN141bCWGT1jg8I1FWHm9oUrgSNP(G1NhSrennlgSHzdg0myeWmFW7063XeN)eA1kItqGIwK6a2yeOikmHafT0GxWdT6GLWYF0MxWdT4tnASarnYruilcu0Ip1OXce1Ov4lN)srRNPFMKPgngT0GxWdTeChm6RdODRPaJyKJOi2iqrl(uJglquJwHVC(lfTmIOPtDWsqdFPKa2)qln4f8qlH(XTkjWhPGhYruSdeOOLg8cEOvhSewdyZrl(uJglquJCefYabkAXNA0ybIA0sdEbp0kOTMvdEbpBRioA1kIBpvIrRGGGCefGjcu0Ip1OXce1Ov4lN)srlJiA6uM(DmXzH1ZGraZCskABW9o4ae2eW(xQdwcRbS5PNL06idMsad2usgdU3bR7YF5CIW6xhqRO0geyeNE9IpykbmytOLg8cEOLuDclH1h5ikKzeOOfFQrJfiQrRWxo)LIwU(azpLXAZZsBbFWMBWYMdT0GxWdTizQa232h(cRGvpd5ikmpeOOfFQrJfiQrRWxo)LIwgr00PoyjOHVuI4Ai(GPCWMYnyqgS8d2uUbhZGnIOPtgniu0IiEkABWYHwAWl4HwKO)5tWV1HwjvCmHGCefGDeOOfFQrJfiQrRWxo)LIwVwcl3XNNuHGKQBWuoyt5qln4f8qlH(XTDWsGCefMYHafT4tnASarnAf(Y5Vu0Y1gFEsQoHbFc(t8Pgnwm497hS8d2iIMo1blbn8LsexdXhmLd2K5n497hSxsS1HwrXd2Cd2KmgSCOLg8cEOLuDcd(e8JCefMmHafT4tnASarnAf(Y5Vu061sy5o(8KkeKuDdMYblJb37GFTewUJppPcbjjIE1l4nyZnyzZHwAWl4HwKmva7BdVsYqoIctYIafT4tnASarnAf(Y5Vu0Qt)snACsaDInABW9oy5hS8d(1sy5o(8KeSJL4Zt1nykhCqjU1ljEWGm4Cjzm4Eh8RLWYD85jjyhlXNNQBWMBW7yWYn497hmyyWU24ZtKmva7B7dFHTdwIeFQrJfdE)(bBertN6GLGg(sjbS)n497hSrenDQdwcA4lLiUgIpykhSPDm4EhS8dUoIELB2Gn3GL5CdE)(bhY0hitS0Vg8cEABWuoytPyh7bl3G3VFWgr00PoyjOHVuI4Ai(GnhGbBAhdU3bl)GRJOx5MnyZnyWm3G3VFWHm9bYel9RbVGN2gmLd2uk2XEWYny5qln4f8qlP6ewJMsCKJOWuSrGIw8PgnwGOgTcF58xkAjGEIKPcyFBF4lSBADPNL06idMYbVJb37Gfqp1PsB1xbRdJczPNL06idMYbVJb37GnIOPtDWsqdFPu0gAPbVGhA1blH1H)ZNJCefM2bcu0Ip1OXce1Ov4lN)srRNPFMKPgnEW9oyVKyRdTIIhmLdEhdU3bdggSRn(8Kur43SeFQrJfdU3bdggSRn(8Kq)42oyjs8PgnwGwAWl4HwKmva7B7dFHDtRd5ikmjdeOOfFQrJfiQrRWxo)LIwpt)mjtnA8G7DWEjXwhAffpykhmyo497hS8d21gFEsQi8BwIp1OXIb37GfqprYubSVTp8f2nTU0Z0ptYuJgpy5qln4f8qRovAR(kyDyuid5ikmbMiqrl(uJglquJwAWl4Hws1jS0n1m0QoN)pAZTfnA5vioHsaY2R8biSjG9VuhSewdyZtrB73hGWMa2)ss1jSgnL4POn5qR6C()On3wssSOuNrltOvitRdTmHCefMKzeOOLg8cEOfjtfW(2(Wxy306ql(uJglquJCKJwcMwJAocuefMqGIwAWl4HwKQXxGrl(uJglquJCefYIafT0GxWdTIiSTCwIGw8PgnwGOg5ikIncu0Ip1OXce1Ov4lN)srlJiA6KrdcfTiINEwd(G3VFWEjXwhAffpyZbyWMxUbVF)GD9bYEkJ1MNL2c(Gn3GJTmqln4f8qRnOxWd5ik2bcu0Ip1OXce1OfCdTiSJwAWl4HwD6xQrJrRoTfXOLa6jsMkG9T9HVWUP1L8keVoGdU3blGEQtL2QVcwhgfYsEfIxhq0QtF7PsmAjGoXgTHCefYabkAXNA0ybIA0k8LZFPOLrenDQdwcA4lLI2qln4f8ql66zJgekqoIcWebkAPbVGhAzWpH)41beT4tnASarnYruiZiqrln4f8qRwbmZjwzkrcGs85OfFQrJfiQroIcZdbkAXNA0ybIA0k8LZFPOLrenDQdwcA4lLI2qln4f8ql9cmXFTzdARHCefGDeOOLg8cEOLHc0cPT(xH4e0Ip1OXce1ihrHPCiqrl(uJglquJwHVC(lfT0GxDSLpwQyYGPCWMqln4f8qRp6SAWl4zBfXrRwrC7PsmAfAS2XihrHjtiqrl(uJglquJwHVC(lfT0GxDSLpwQyYGbmytOLg8cEO1hDwn4f8STI4OvRiU9ujgTi1bSXih5O12ZbOKH6iqruycbkAPbVGhATb9cEOfFQrJfiQroIczrGIw8PgnwGOgTGBOfHD0sdEbp0Qt)snAmA1PTigTOBq4py5hS8dEhjzmyqgSUl)LZP(zfzJFIfsB9m2kuPJfPxV4dwUbltBWYpytdgKbNljRmp4ygSUl)LZjcRFDaTIsBqGrC61l(GLBWYHwD6BpvIrlP6ewJMsCRRpq2jihrrSrGIw8PgnwGOgTGBOfHD0sdEbp0Qt)snAmA1PTigTKFWMgCSgCUuozEWXmyDx(lNtcw9mRN9qMKE9IpyqgCUKSdoMbR7YF5CYZGraZCBM(DmX5p96fFWYn4ygS8d20GJ1GZLYb2hCmdw3L)Y5KNbJaM52m97yIZF61l(GJzW6U8xoNiS(1b0kkTbbgXPxV4dwo0QtF7PsmAr6Vz9xl3(6fNydzCioYruSdeOOfFQrJfiQrl4gAryhT0GxWdT60VuJgJwDAlIrl5hSPbhRbNlLBhdoMbR7YF5CYZGraZCBM(DmX5p96fFWXAW5s5KXGJzW6U8xoNiBLZ0rnRUTPF5f8iPxV4dwo0QtF7PsmA15w)1YTVEXj2qghIJCefYabkAXNA0ybIA0cUHwe2rln4f8qRo9l1OXOvN2Iy0s(bBAWXAW5s5K5bhZG1D5VCojy1ZSE2dzs61l(GJ1GZLYf7bhZG1D5VCo5zWiGzUnt)oM48NE9Ip4yn4CPCYqgdoMbR7YF5CISvoth1S62M(LxWJKE9Ipy5gCmdw(bBAWXAW5s5KvMhCmdw3L)Y5KNbJaM52m97yIZF61l(GJzW6U8xoNiS(1b0kkTbbgXPxV4dwo0QtF7PsmA15wPIy9xl3(6fNydzCioYruaMiqrl(uJglquJwWn0IWoAPbVGhA1PFPgngT60weJwMgCSgCUuot7yWXmyDx(lNtew)6aAfL2GaJ40RxC0QtF7PsmA15wPIyjcBiJdXroIczgbkAXNA0ybIA0k8LZFPOfyyWgr00jsMkG9PHVukAdT0GxWdTizQa2Ng(sihrH5HafT4tnASarnADQeJw6UKm9vILgEUfsB3G95hT0GxWdT0Djz6Reln8ClK2Ub7ZpYrua2rGIw8PgnwGOgTcF58xkAr24wZ66dKDssQoHLW6pyZnyzh8(9dw3L)Y5KNbJaM52m97yIZF61l(Gbm4COLg8cEOLuDcRrtjoYruykhcu0sdEbp0QtL2QVcwhgfYql(uJglquJCKJwbbbbkIctiqrl(uJglquJwHVC(lfTKFWgr00PoyjOHVuI4Ai(GPCWYMBW9o46i6vUzd2CagSmYny5g8(9dw(bhI(Np3whrVYnZkETUbhZGLFWYpyGbrss7PdoMbl7GLBWGmyn4f8ss1jSgnL4PGsCRxs8GLBWYnykhCDe9k3m0sdEbp0sILGVzwiTTffkHv8SkrqoIczrGIwAWl4HwgniuyH0wpJT8XsMHw8PgnwGOg5ikIncu0Ip1OXce1Ov4lN)srlJiA6uhSe0WxkrCneFWuoytYaT0GxWdTagPVO0ZcPT6U8d9mKJOyhiqrl(uJglquJwAWl4Hws6v0mXHwiTvsfhtiOv4lN)srlYg3AwxFGStss1jSew)btjGbl7G3VFWVwcl3XNNuHGKQBWuoyWmhADQeJws6v0mXHwiTvsfhtiihrHmqGIw8PgnwGOgTcF58xkAr24wZ66dKDssQoHLW6pykbmyzh8(9d(1sy5o(8KkeKuDdMYbdM5qln4f8qlAyiIWcRUl)LZwdwLqoIcWebkAXNA0ybIA0k8LZFPOfzJBnRRpq2jjP6ewcR)GPeWGLDW73p4xlHL74ZtQqqs1nykhmyMdT0GxWdT2I(I2S6aAnAkXroIczgbkAXNA0ybIA0sdEbp0kaVaF(RolS0nvIrRWxo)LIwEjXd2CagSPCdE)(bl)GnIOPtHm4hrSqABDe9k3SeX1q8btjGbBsgdU3bBertN6GLGg(sPOTbl3G3VFW0rTM95qM(azRxs8Gn3GbgedE)(b7LeBDOvu8Gn3GLbA1QJTbbAbMihrH5HafT0GxWdT(ABRX26SKnnWOfFQrJfiQroIcWocu0sdEbp06zDRoGw6MkXe0Ip1OXce1ihrHPCiqrln4f8qR(WVj646SptGNEbgT4tnASarnYruyYecu0Ip1OXce1Ov4lN)srl5hSrenDQdwcA4lLI2gCVd2iIMofYGFeXcPT1r0RCZsexdXhmLdw2CdwUbVF)G1D5VCofYGFeXcPT1r0RCZsVEXhmGbNdT0GxWdTcARz1GxWZ2kIJwTI42tLy0k8LBdccYruysweOOLg8cEOveHTLZse0Ip1OXce1ih5Ov4l3geeeOikmHafT4tnASarnADQeJw6UKm9vILgEUfsB3G95hT0GxWdT0Djz6Reln8ClK2Ub7ZpYruilcu0Ip1OXce1OLg8cEOvWSqd6p8QG1OPehTyAAo42tLy0kywOb9hEvWA0uIJCKJwHgRDmcuefMqGIwAWl4HwDWsy5pAZl4Hw8PgnwGOg5ikKfbkAPbVGhAry9RdO9kGzUK(mAXNA0ybIAKJOi2iqrl(uJglquJwHVC(lfTEM(zsMA0y0sdEbp0sWDWOVoG2TMcmIroIIDGafT4tnASarnAf(Y5Vu0YiIMo1blbn8Lscy)dT0GxWdTe6h3QKaFKcEihrHmqGIw8PgnwGOgTcF58xkAbggSxH41bCW9oyDx(lNtEgmcyMBZ0VJjo)PxV4dMsad2eAPbVGhA1PsB1xbRdJczihrbyIafT4tnASarnAf(Y5Vu0YiIMoLPFhtCwy9myeWmNKI2qln4f8qlP6ewcRpYruiZiqrln4f8qRoyjSgWMJw8PgnwGOg5ikmpeOOfFQrJfiQrln4f8qRG2Awn4f8STI4OvRiU9ujgTcccYrua2rGIw8PgnwGOgT0GxWdTizQa232h(cRGvpdTcF58xkA56dK9ugRnplTf8bBUblBo0kywOXwxFGStquyc5ikmLdbkAXNA0ybIA0k8LZFPOLrenDQdwcA4lLiUgIpykhSPCdgKbl)GnLBWXmyJiA6KrdcfTiINI2gSCOLg8cEOfj6F(e8BDOvsfhtiihrHjtiqrl(uJglquJwHVC(lfTETewUJppPcbjv3GPCWMYn4EhS8dwa9ejtfW(2(Wxy306spt)mjtnA8G3VFWEjXwhAffpykhCSZny5qln4f8qlH(XTDWsGCefMKfbkAPbVGhAjvNWGpb)OfFQrJfiQroIctXgbkAXNA0ybIA0sdEbp0sQoH1OPehTcF58xkAr24wZ66dKDssQoHLW6pyZn4o9l1OXjP6ewJMsCRRpq2jOvWSqJTU(azNGOWeYruyAhiqrl(uJglquJwHVC(lfTKFWVwcl3XNNuHGKQBWuoyzm4Eh8RLWYD85jviijr0REbVbBUbl7GLBW73p4xlHL74ZtQqqsIOx9cEdMYbllAPbVGhArYubSVn8kjd5ikmjdeOOfFQrJfiQrln4f8qlsMkG9T9HVWUP1HwHVC(lfTadd21gFEsQi8BwIp1OXIb37GFM(zsMA04b37G9sITo0kkEWuoy5hS8dowd2us2bdYGJDk2doMbt24wZ66dKDssQoHLW6py5gCmdUt)snACI0FZ6VwU91loXgY4q8bhZGLFWMgCSgCUuotYo4ygSUl)LZjcRFDaTIsBqGrC61l(GJzWKnU1SU(azNKKQtyjS(dwUblhAfml0yRRpq2jikmHCefMateOOfFQrJfiQrln4f8qRovAR(kyDyuidTcF58xkA9m9ZKm1OXdU3b7LeBDOvu8GPCWYpy5hSPbdYGJDk2doMbt24wZ66dKDssQoHLW6py5gCmdUt)snACQZT(RLBF9ItSHmoeFWXmy5hSPbdYGZLmLBWXmyDx(lNtew)6aAfL2GaJ40Rx8bhZGjBCRzD9bYojjvNWsy9hSCdwo0kywOXwxFGStquyc5ikmjZiqrl(uJglquJwAWl4HwDQ0w9vW6WOqgAf(Y5Vu0sa9ejtfW(2(Wxy306spt)mjtnA8G7DWYpyxB85jPIWVzj(uJglgCVd2lj26qRO4bt5GLFWYpytPCdgKblBk3GJzWKnU1SU(azNKKQtyjS(dwUbhZG70VuJgN6CRurS(RLBF9ItSHmoeFWXmy5hCN(LA04uNBLkILiSHmoeFWXmyYg3AwxFGStss1jSew)bl3GLBWYHwbZcn266dKDcIctihrHjZdbkAXNA0ybIA0k8LZFPOLrenDQdwcA4lLI2qln4f8qRoyjSo8F(CKJOWeyhbkAXNA0ybIA0sdEbp0sQoHLW6Jw158)rBUTOrlVcXjucq2EnIOPts1jSewFRNLeW(hAvNZ)hT52ssIfL6mAzcTcF58xkAr24wZ66dKDssQoHLW6pykhSj0kKP1HwMqoIczZHafT4tnASarnAPbVGhAjvNWs3uZqR6C()On3w0OLxH4ekbiBVYhGWMa2)sDWsynGnpfTTFFacBcy)ljvNWA0uINI2KdTQZ5)J2CBjjXIsDgTmHwHmTo0YeYruiRjeOOLg8cEOfjtfW(2(Wxy306ql(uJglquJCKJC0QJFsbpefYMt2C5att7aT6R)vhqcAbgdw7jrXoHcz6GLbpyqZ4bxsBW3hmn8h8otQdyJ35b)8ovu9SyWeOepynYHsQZIbhY0ditstEWM64bhBWYG75JeTTbFNfdwdEbVbVZc9JBvsGpsbVDon5bBQJhmyhSm4E(irBBW3zXG1GxWBW7Sq)42oyj250KFYdgdw7jrXoHcz6GLbpyqZ4bxsBW3hmn8h8ohAS2X78GFENkQEwmycuIhSg5qj1zXGdz6bKjPjpytD8G3byzW98rI22GVZIbRbVG3G3zH(XTkjWhPG3oNM8Gn1Xd2KjWYG75JeTTbFNfdwdEbVbVZc9JB7GLyNtt(j)orAd(olgmyoyn4f8gCRiojn5rRThsxngT6XGxzQa2FW9eFXeFY3JbdwJagr8blR5b(GLnNS5M8t(EmyZptpGmbSm57XGJ1GbRcblg8QA8f40KVhdowd28Hxh)olgSRpq2Tf9GjMDU2ttt(Em4ynyZhED87SyWU(azp5LeBDOvu8GD4G9sITo0kkEW9Z4NhSUT1QGA040KVhdowdgSkeSyWs1jSewFRNnyJiA6b7WbRDWsmyJN141bCWGT1jg8I1FWHm9oUrgSNP(G1NhSrennlgSHzdg0myeWmFW7063XeN)0KFY3JbltTNYHiNfd2GPHpp4auYq9bBWaRJKgmyne4nNm4dEXktFj6O2G1GxWJmy41mln57XG1GxWJK2EoaLmuhaDtjXN89yWAWl4rsBphGsgQdcaQOHqXKVhdwdEbpsA75auYqDqaqLgbuIpx9cEt(Em41PBKmOp4xlXGnIOPzXGjU6KbBW0WNhCakzO(GnyG1rgSEIbV9CS2GUxhWbxKblGhNM89yWAWl4rsBphGsgQdcaQiNUrYGUL4QtM8AWl4rsBphGsgQdcaQ2GEbVjVg8cEK02ZbOKH6GaGQo9l1OXGFQedqQoH1OPe366dKDc4Wnae2bVtBrma6ge(Yl)osYaeDx(lNt9ZkYg)elK26zSvOshlsVEXLtMM8MajxswzogDx(lNtew)6aAfL2GaJ40RxC5KBYRbVGhjT9CakzOoiaOQt)snAm4NkXai93S(RLBF9ItSHmoehC4gac7G3PTigG8MIvUuozogDx(lNtcw9mRN9qMKE9IdsUKSXO7YF5CYZGraZCBM(DmX5p96fxUyK3uSYLYb2Jr3L)Y5KNbJaM52m97yIZF61lEm6U8xoNiS(1b0kkTbbgXPxV4Yn51GxWJK2EoaLmuheau1PFPgng8tLyaDU1FTC7RxCInKXH4Gd3aqyh8oTfXaK3uSYLYTJy0D5VCo5zWiGzUnt)oM48NE9IhRCPCYigDx(lNtKTYz6OMv320V8cEK0RxC5M8AWl4rsBphGsgQdcaQ60VuJgd(PsmGo3kveR)A52xV4eBiJdXbhUbGWo4DAlIbiVPyLlLtMJr3L)Y5KGvpZ6zpKjPxV4XkxkxSJr3L)Y5KNbJaM52m97yIZF61lESYLYjdzeJUl)LZjYw5mDuZQBB6xEbps61lUCXiVPyLlLtwzogDx(lNtEgmcyMBZ0VJjo)PxV4XO7YF5CIW6xhqRO0geyeNE9Il3KxdEbpsA75auYqDqaqvN(LA0yWpvIb05wPIyjcBiJdXbhUbGWo4DAlIbykw5s5mTJy0D5VCory9RdOvuAdcmItVEXN8AWl4rsBphGsgQdcaQizQa2Ng(sGx0aadgr00jsMkG9PHVukABYRbVGhjT9CakzOoiaOkIW2YzjWpvIbO7sY0xjwA45wiTDd2N)jVg8cEK02ZbOKH6GaGkP6ewJMsCWlAaKnU1SU(azNKKQtyjS(Mt2971D5VCo5zWiGzUnt)oM48NE9Idi3KxdEbpsA75auYqDqaqvNkTvFfSomkKn5N89yWYu7PCiYzXG5o(nBWEjXd2Z4bRbh(dUidw70QPgnon51GxWJaGun(c8KxdEbpciaOkIW2YzjYKxdEbpciaOAd6f8aVObyertNmAqOOfr80ZAW3V3lj26qROyZbW8YTFVRpq2tzS28S0wWnxSLXKxdEbpciaOQt)snAm4NkXaeqNyJ2ahUbGWo4DAlIbiGEIKPcyFBF4lSBADjVcXRdyVcON6uPT6RG1HrHSKxH41bCYRbVGhbeaurxpB0Gqb4fnaJiA6uhSe0WxkfTn51GxWJacaQm4NWF86ao51GxWJacaQAfWmNyLPejakXNp51GxWJacaQ0lWe)1MnOTg4fnaJiA6uhSe0WxkfTn51GxWJacaQmuGwiT1)keNm51GxWJacaQ(OZQbVGNTveh8tLyaHgRDm4fnan4vhB5JLkMqPPjVg8cEeqaq1hDwn4f8STI4GFQedGuhWgdErdqdE1Xw(yPIjamn5N89yW9mHhmyllbFZgmKEWGnrHsmyzYZQezWFbmZhSbtdFEWMbJgS(8GvdyKpyhoyAT1gmmYhmKEWGrWsqdFPjVg8cEKuqqaiXsW3mlK22IcLWkEwLiGx0aK3iIMo1blbn8LsexdXPu2C9whrVYnZCaKro52Vx(q0)8526i6vUzwXR1fJ8YdmissApngzLden4f8ss1jSgnL4PGsCRxsSCYrzDe9k3SjVg8cEKuqqabavgniuyH0wpJT8XsMn51GxWJKccciaOcyK(IsplK2Q7Yp0ZaVObyertN6GLGg(sjIRH4uAsgtEn4f8iPGGacaQIiSTCwc8tLyas6v0mXHwiTvsfhtiGx0aiBCRzD9bYojjvNWsy9PeGS73)AjSChFEsfcsQokbZCtEn4f8iPGGacaQOHHiclS6U8xoBnyvc8IgazJBnRRpq2jjP6ewcRpLaKD)(xlHL74ZtQqqs1rjyMBYRbVGhjfeeqaq1w0x0MvhqRrtjo4fnaYg3AwxFGStss1jSewFkbi7(9Vwcl3XNNuHGKQJsWm3KVhdgmwlFWQp4gReFWGjzWgS3N5BWbL41bCWMFp50G7zcpypJhmD9eFWbL4dgSUaR9ed2Hdgi7dU8bdVbB(YeWhSNX3G5o(nBWKidcVtfXNp4Gs8btYGrnXGn4bhryXG7NX3Gn)m4hrgmKEW7KJOx5Mn4Imyn4vhpy4p4YhC)Q1g8ZHm9bYdUUb7z8GpUN6dgyqa(GH)G9mEWU(azFWfzWQbmYhSdhSO40KxdEbpskiiGaGQa8c85V6SWs3ujg8wDSniaaMGx0a8sInhat52VxEJiA6uid(relK2whrVYnlrCneNsaMKrVgr00PoyjOHVukAtU97PJAn7ZHm9bYwVKyZbmi2V3lj26qROyZjJjVg8cEKuqqabavFTT1yBDwYMg4jVg8cEKuqqabavpRB1b0s3ujMm51GxWJKccciaOQp8BIoUo7Ze4PxGN89yW9mHhSNXeEWbiSjG9pYGRBWgS3N5BWMbJ(bBI4dwpXGL9edgmcwIbtnS5dUUbBgm6hSSNyWGrWsqdFPb3pJVbBgmAWzAhpyZpd(rKbdPh8o5i6vUzdwdE1XtEn4f8iPGGacaQcARz1GxWZ2kId(PsmGWxUniiGx0aK3iIMo1blbn8LsrB9AertNczWpIyH026i6vUzjIRH4ukBo52Vx3L)Y5uid(relK2whrVYnl96fhqUjFpgSmHP1OMpyAT1m0q8btd)bhruJgp4YzjcyzW9mHhm8gCacBcy)ln51GxWJKccciaOkIW2YzjYKFYRbVGhjfAS2Xa6GLWYF0MxWBYRbVGhjfAS2XGaGkcRFDaTxbmZL0NN8AWl4rsHgRDmiaOsWDWOVoG2TMcmIbVOb8m9ZKm1OXtEn4f8iPqJ1ogeauj0pUvjb(if8aVObyertN6GLGg(sjbS)n51GxWJKcnw7yqaqvNkTvFfSomkKbErdam4viEDa7v3L)Y5KNbJaM52m97yIZF61loLamn51GxWJKcnw7yqaqLuDclH1h8IgGrenDkt)oM4SW6zWiGzojfTn51GxWJKcnw7yqaqvhSewdyZN8AWl4rsHgRDmiaOkOTMvdEbpBRio4NkXaccYKxdEbpsk0yTJbbavKmva7B7dFHvWQNbEWSqJTU(azNaWe4fnaxFGSNYyT5zPTGBozZn51GxWJKcnw7yqaqfj6F(e8BDOvsfhtiGx0amIOPtDWsqdFPeX1qCknLde5nLlgJiA6KrdcfTiINI2KBY3Jb3ZeEWYe9JpyWiyjgm8gS5ltgC01yczWQqqgS(8GRlaLQd4GRBWMYrgm8hCJjK0KxdEbpsk0yTJbbavc9JB7GLa8IgWRLWYD85jviiP6O0uUELxa9ejtfW(2(Wxy306spt)mjtnA8(9EjXwhAfftzSZj3KxdEbpsk0yTJbbavs1jm4tW)KxdEbpsk0yTJbbavs1jSgnL4Ghml0yRRpq2jambErdGSXTM11hi7KKuDclH13CD6xQrJts1jSgnL4wxFGStM8AWl4rsHgRDmiaOIKPcyFB4vsg4fna5FTewUJppPcbjvhLYO3xlHL74ZtQqqsIOx9cEMtw52V)1sy5o(8KkeKKi6vVGhLYo51GxWJKcnw7yqaqfjtfW(2(Wxy306apywOXwxFGStayc8IgayW1gFEsQi8BwIp1OXIEFM(zsMA04E9sITo0kkMs5LpwMsYcsStXogYg3AwxFGStss1jSewF5IPt)snACI0FZ6VwU91loXgY4q8yK3uSYLYzs2y0D5VCory9RdOvuAdcmItVEXJHSXTM11hi7KKuDclH1xo5M8AWl4rsHgRDmiaOQtL2QVcwhgfYapywOXwxFGStayc8IgWZ0ptYuJg3RxsS1HwrXukV8Maj2PyhdzJBnRRpq2jjP6ewcRVCX0PFPgno15w)1YTVEXj2qghIhJ8MajxYuUy0D5VCory9RdOvuAdcmItVEXJHSXTM11hi7KKuDclH1xo5M8AWl4rsHgRDmiaOQtL2QVcwhgfYapywOXwxFGStayc8IgGa6jsMkG9T9HVWUP1LEM(zsMA04EL31gFEsQi8BwIp1OXIE9sITo0kkMs5L3ukhiYMYfdzJBnRRpq2jjP6ewcRVCX0PFPgno15wPIy9xl3(6fNydzCiEmY3PFPgno15wPIyjcBiJdXJHSXTM11hi7KKuDclH1xo5KBYRbVGhjfAS2XGaGQoyjSo8F(CWlAagr00PoyjOHVukABYRbVGhjfAS2XGaGkP6ewcRp4fnaYg3AwxFGStss1jSewFknbEitRdGjWRZ5)J2CBjjXIsDgGjWRZ5)J2CBrdWRqCcLaKTxJiA6KuDclH136zjbS)n51GxWJKcnw7yqaqLuDclDtnd8qMwhatGxNZ)hT52ssIfL6matGxNZ)hT52IgGxH4ekbiBVYhGWMa2)sDWsynGnpfTTFFacBcy)ljvNWA0uINI2KBYRbVGhjfAS2XGaGksMkG9T9HVWUP1n5N8AWl4rsHVCBqqaeryB5Se4NkXa0Djz6Reln8ClK2Ub7Z)KxdEbpsk8LBdcciaOkIW2YzjWzAAo42tLyabZcnO)WRcwJMs8j)KxdEbpsIuhWgdOdwcl)rBEbVjVg8cEKePoGngeauj4oy0xhq7wtbgXGx0aEM(zsMA04jVg8cEKePoGngeauj0pUvjb(if8aVObyertN6GLGg(sjbS)n51GxWJKi1bSXGaGQoyjSgWMp51GxWJKi1bSXGaGQG2Awn4f8STI4GFQediiit(Em4EMWdgSToXGxS(dgEdEb6GHxZSbx0d2my0GbY(G1bdAgmcyMp4DA97yIZ)G7jEyyW9lpBWQp4gReFWMg8I1VoGdwMuAdcmIhmOVwEAYRbVGhjrQdyJbbavs1jSewFWlAagr00Pm97yIZcRNbJaM5Ku0wVbiSjG9VuhSewdyZtplP1rOeGPKm6v3L)Y5eH1VoGwrPniWio96fNsaMM89yW9mHh8cmwMmydMg(8Gd62wDahCitFGmb8bd)b7z8GD9bY(GlYGvdyKpyhoyrXPjVg8cEKePoGngeaurYubSVTp8fwbREg4fnaxFGSNYyT5zPTGBozZn51GxWJKi1bSXGaGks0)8j436qRKkoMqaVObyertN6GLGg(sjIRH4uAkhiYBkxmgr00jJgekArepfTj3KhKb3Jb3ZeEWYe9JpyWiyjgm8gS5ltgC01yczWQqqgS(8GRlaLQd4GRBWMYrgm8hCJjK0KxdEbpsIuhWgdcaQe6h32blb4fnGxlHL74ZtQqqs1rPPCt(Em4EMWdgSToHbFc(hS6d2eyFWWFWsWNhmX1qCc4dg(dUOhSNXd21hi7dUF1Adwu8GRBWnMqgSNP3GnjdsAYRbVGhjrQdyJbbavs1jm4tWp4fnaxB85jP6eg8j4pXNA0yX(9YBertN6GLGg(sjIRH4uAY82V3lj26qROyZzsgYn57XG7zcp4vMkG9hS5)kjBWWBWMVmzWrxJjKb7z8ZdwFEWQqqgCDbOuDattEn4f8ijsDaBmiaOIKPcyFB4vsg4fnGxlHL74ZtQqqs1rPm691sy5o(8KkeKKi6vVGN5Kn3KVhdMA9IpypJh8ktfW(dgmg(cWYGbJGLyWHm9bYKbtd)bRd2O8b7Wb7VzdwpXG1oyjgmSJ)GUTvhWbdVbVtoIELBwAYRbVGhjrQdyJbbavs1jSgnL4Gx0a60VuJgNeqNyJ26vE5FTewUJppjb7yj(8uDuguIB9sIbjxsg9(AjSChFEsc2Xs85P6m3oKB)EWGRn(8ejtfW(2(Wxy7GLiXNA0yX(9gr00PoyjOHVusa7F73BertN6GLGg(sjIRH4uAAh9kFDe9k3mZjZ52VpKPpqMyPFn4f80gLMsXo2YTFVrenDQdwcA4lLiUgIBoaM2rVYxhrVYnZCGzU97dz6dKjw6xdEbpTrPPuSJTCYn51GxWJKi1bSXGaGQoyjSo8F(CWlAacONizQa232h(c7Mwx6zjTocL7Oxb0tDQ0w9vW6WOqw6zjTocL7OxJiA6uhSe0WxkfTn51GxWJKi1bSXGaGksMkG9T9HVWUP1bErd4z6NjzQrJ71lj26qROyk3rVGbxB85jPIWVzj(uJgl6fm4AJppj0pUTdwIeFQrJftEn4f8ijsDaBmiaOQtL2QVcwhgfYaVOb8m9ZKm1OX96LeBDOvumLG5(9Y7AJppjve(nlXNA0yrVcONizQa232h(c7Mwx6z6NjzQrJLBYRbVGhjrQdyJbbavs1jS0n1mWdzADambEDo)F0MBljjwuQZambEDo)F0MBlAaEfItOeGS9kFacBcy)l1blH1a28u02(9biSjG9VKuDcRrtjEkAtUjVg8cEKePoGngeaurYubSVTp8f2nTo0ISXbefYkdZd5ihHaa]] )


end
