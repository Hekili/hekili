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
            value = 12,
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
            duration = 4,
            max_stack = 1,
            tick_time = 1,
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
            id = 205385,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = -20,
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

            spend = 90,
            spendType = "insanity",

            startsCombat = true,
            texture = 1386548,

            nobuff = "voidform",
            bind = "void_bolt",

            handler = function ()
                applyBuff( "voidform" )
                if talent.legacy_of_the_void.enabled then gain( 90, "insanity" ) end
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


    spec:RegisterPack( "Shadow", 20200614, [[dOKidbqirvQhrr0LeLuytIsnkuQofQIvjk6vGIzbkDlrvSlr(fOQHjfogQQLjk8mrjMMOQCnus2MsP8nrjzCIQkNdLuzDIQQmpkc3de7dLYbfLuTquLEOOkzIOKIlkQQk2OsPszKIQQQtQuQYkLIMPOQQ0nvkv1orjgQOKspvjtfu5QOKsBvPuXxvkvYEH6VuAWqomPftHhtLjJ0Lj2mk(minAQYPLSArjf9ArLzlv3gv2Tk)wvdxP64kLkvlh45iMUW1PQ2Uu67uuJhLu15PiTELsMVsX(vmMpgo8IQHGzjJgz0OX24NVeFwLr(Xp)WRW0DbV2vxofQGxNYj41YtPVz8AxnT)kfdhErEFGtWlVi2j5p4HhAfE(gj3ZbpP487Au)5aktapP4CWJxg(vp2Eh2aVOAiywYOrgnASn(5lXNvzKF83gEP(H3dWRvXLx4LxrPYHnWlQqC4Ljh0YtPV5bL1ckHetttoiVi2j5p4HhAfE(gj3ZbpP487Au)5aktapP4CWpnn5GA6FYG4NpyhugnYOX0CAAYbLxE6bvi5VPPjhuEguwNsf6GwvxoNKMMMCq5zq51FTcie6GcfavcBXmiIPxOS(000KdkpdkV(RvaHqhuOaOsKIItSXBPLmO4huuCInElTKbz2taYG099E5uJUKMMMCq5zqzDkvOdIRoQLikWgEdYWNHzqXpiT9l6GmaIMRoOdA7xhDqlrbdY5P3jDYGcpngKcKbz4ZWi0bzy6GGZ79H6fdk)xbTcjeqcV6fjiy4WlsDq7cgoml8XWHxQlQ)WR2VOwb4Vh1F4LCQrxOyEXbMLmWWHxYPgDHI5fVCGkeqP4LHpdtQ9lkZd4s038HxQlQ)WlQcYzvItos9hoWSKfmC4L6I6p8Q9lQ147bEjNA0fkMxCGzjFy4Wl5uJUqX8IxQlQ)WlN27w1f1F2Erc8QxKWEkNGxokbhywyfgo8so1OlumV4LduHakfVm8zysEkOviHqTH37d1lij)9bL9GC)3PV5l1(f1A89ibeoToYGydYG4Ny1GYEq6wcOcjrefuhulT0(d1xsa9Yni2Gmi(4L6I6p8IRoQLikahyw2ggo8so1OlumV4LduHakfVcfavIuuCInElTKbzIbLLbTzZGC)3PV5lr8u6B2A(bulv0Wl58uauHmiidkJbTzZGyFqU)7038LiEk9nBn)aQLkA4LCEkaQqgeKbXFqzpi3)D6B(sepL(MTMFa1sfn8saHtRJmitmiOoAItz9dIh8sDr9hEr8u6B2A(bulv0WdhywYkmC4LCQrxOyEXlhOcbukEz4ZWKA)IY8aUejuxUbX2G43yqWmi2he)gdkZbz4ZWKm6)t7(Ki5VpiEWl1f1F4fXhaKJkaB8woLEcHGdml5hgo8so1OlumV4LduHakfVaArTsRCrsPusQUbX2G43aVuxu)HxufKZ2(ffhywyDy4Wl5uJUqX8IxoqfcOu8k0UCrIRoQHCubKKtn6cDqB2mi2hKHpdtQ9lkZd4sKqD5geBdIF(nOnBguuCInElTKbzIbXNvdIh8sDr9hEXvh1qoQaWbMf(nWWHxYPgDHI5fVCGkeqP4vEpidFgMu7xuMhWL83h0MndI9b5(VtFZxI4P03S18dOwQOHxY5PaOczqqgugdk7bz4ZWKA)IY8aUejuxUbzIbXNvdIh8sDr9hEr8u6B2A(bulv0Wdhyw4ZhdhEjNA0fkMx8YbQqaLIxaTOwPvUiPukjv3GyBqSAqzpiGwuR0kxKukLKO(anQ)gKjgugnWl1f1F4fXtPVzRdOepCGzHFgy4Wl5uJUqX8IxoqfcOu8QvbLA0Le9dI1FFqzpi2he7dcOf1kTYfjUVv4Kls1ni2gKtjHnkozqWmOgjwnOSheqlQvALlsCFRWjxKQBqMyq5Bq8mOnBguEpOq7YfjINsFZwZpGAB)IMKtn6cDqB2midFgMu7xuMhWLOV5BqB2midFgMu7xuMhWLiH6Yni2ge)8nOShe7dQoIEvy6GmXGYQgdAZMb58uauHyzaQlQ)0(GyBq8tzjldINbTzZGm8zysTFrzEaxIeQl3GmbKbXpFdk7bX(GQJOxfMoitmOT1yqB2miNNcGkeldqDr9N2heBdIFklzzq8miEWl1f1F4fxDuRrxjboWSWply4Wl5uJUqX8IxoqfcOu8I(rI4P03S18dO2DTUeq406idITbLVbL9GOFKAvU9cuoB8(oVeq406idITbLVbL9Gm8zysTFrzEaxYFhVuxu)HxTFrTXdaYf4aZc)8HHdVKtn6cfZlE5aviGsXlGWaeINA0LbL9GIItSXBPLmi2gu(gu2dkVhuOD5IexreGPj5uJUqhu2dkVhuOD5Ievb5STFrtYPgDHIxQlQ)WlINsFZwZpGA316WbMf(ScdhEjNA0fkMx8YbQqaLIxaHbiep1Oldk7bffNyJ3slzqSnOTnOnBge7dk0UCrIRicW0KCQrxOdk7br)ir8u6B2A(bu7UwxcimaH4PgDzq8GxQlQ)WRwLBVaLZgVVZdhyw4VnmC4LCQrxOyEXl1f1F4fxDultxnfVQleaWFpSfdEfLlhHnizKn7U)7038LA)IAn(EK833SX9FN(MVexDuRrxjrYFNh8QUqaa)9WwCCcT0qWl(4LZtRdV4Jdml8ZkmC4L6I6p8I4P03S18dO2DTo8so1OlumV4ah4fvyu)EGHdZcFmC4L6I6p8IuD5CcEjNA0fkMxCGzjdmC4L6I6p8YNi2keocEjNA0fkMxCGzjly4Wl5uJUqX8IxoqfcOu8YWNHjz0)N29jrciQlg0MndkkoXgVLwYGmbKbLFng0MndkuaujsEI2dV0UlgKjguwyfEPUO(dV2)O(dhywYhgo8so1OlumV41VJxejWl1f1F4vRck1Ol4vR29f8I(rI4P03S18dO2DTUuuUC1bDqzpi6hPwLBVaLZgVVZlfLlxDqXRwfypLtWl6heR)ooWSWkmC4LCQrxOyEXlhOcbukEz4ZWKA)IY8aUK)oEPUO(dVykGy0)NIdmlBddhEPUO(dVmeara5QdkEjNA0fkMxCGzjRWWHxQlQ)WREb1li2SM(uOCYf4LCQrxOyEXbML8ddhEjNA0fkMx8YbQqaLIxg(mmP2VOmpGl5VJxQlQ)Wl9CcjaA360EhhywyDy4Wl1f1F4LHc1(m2auUCe8so1OlumV4aZc)gy4Wl5uJUqX8IxoqfcOu8sDr1kw5eUsidITbXhVuxu)Hxa)ZQUO(Z2lsGx9Ie2t5e8Y1fTvWbMf(8XWHxYPgDHI5fVCGkeqP4L6IQvSYjCLqgeKbXhVuxu)Hxa)ZQUO(Z2lsGx9Ie2t5e8Iuh0UGdCGx7aX9CgAGHdZcFmC4L6I6p8A)J6p8so1OlumV4aZsgy4Wl5uJUqX8Ix)oErKaVuxu)HxTkOuJUGxTA3xWlM()GbX(GyFq5lXQbbZG0TeqfsYSxr2faX(m2WtSuL7eAcOxUbXZGYAmi2he)bbZGAKYiRguMds3savijIOG6GAPL2FO(scOxUbXZG4bVAvG9uobV4QJAn6kjSHcGkbbhywYcgo8so1OlumV41VJxejWl1f1F4vRck1Ol4vR29f8I9bXFq5zqnsnYQbL5G0TeqfsIkA4zdpWlKeqVCdcMb1iLXGYCq6wcOcjfEVpuVW6PGwHecib0l3G4zqzoi2he)bLNb1i1G1nOmhKULaQqsH37d1lSEkOviHasa9YnOmhKULaQqserb1b1slT)q9LeqVCdIh8Qvb2t5e8IyE3gaTclqVCeRZtC5WbML8HHdVKtn6cfZlE974frc8sDr9hE1QGsn6cE1QDFbVyFq8huEguJuJ8nOmhKULaQqsH37d1lSEkOviHasa9YnO8mOgPgSAqzoiDlbuHKi7vim(DRUVRGkQ)ijGE5gep4vRcSNYj4vBydGwHfOxoI15jUC4aZcRWWHxYPgDHI5fV(D8IibEPUO(dVAvqPgDbVA1UVGxSpi(dkpdQrQrwnOmhKULaQqsurdpB4bEHKa6LBq5zqnsnYYGYCq6wcOcjfEVpuVW6PGwHecib0l3GYZGAKAWkwnOmhKULaQqsK9keg)Uv33vqf1FKeqVCdINbL5GyFq8huEguJuJmYQbL5G0Teqfsk8EFOEH1tbTcjeqcOxUbL5G0TeqfsIikOoOwAP9hQVKa6LBq8GxTkWEkNGxTHLRi2aOvyb6LJyDEIlhoWSSnmC4LCQrxOyEXRFhVisGxQlQ)WRwfuQrxWRwT7l4f)bLNb1i1GF(guMds3savijIOG6GAPL2FO(scOxo8Qvb2t5e8QnSCfXsOwNN4YHdmlzfgo8so1OlumV4LduHakfVY7bz4ZWKiEk9nZ8aUK)oEPUO(dViEk9nZ8aoCGzj)WWHxYPgDHI5fVoLtWlDlINcuIL5VW(m293SaWl1f1F4LUfXtbkXY8xyFg7(Bwa4aZcRddhEjNA0fkMx8YbQqaLIxKDP3THcGkbjXvh1sefmitmOmg0Mnds3saviPW79H6fwpf0kKqajGE5geKb1aVuxu)HxC1rTgDLe4aZc)gy4Wl1f1F4vRYTxGYzJ335HxYPgDHI5fh4aVCucgoml8XWHxYPgDHI5fVCGkeqP4f7dYWNHj1(fL5bCjsOUCdITbLrJbL9GQJOxfMoitazqSQXG4zqB2mi2hKZhaKlS1r0RctTuGw3GYCqSpi2heuhnXPS(bL5GYyq8miygK6I6VexDuRrxjrYPKWgfNmiEgepdITbvhrVkmfVuxu)HxCc3dm1(m2UVROwkquocoWSKbgo8sDr9hEz0)NAFgB4jw5eotXl5uJUqX8IdmlzbdhEjNA0fkMx8YbQqaLIxg(mmP2VOmpGlrc1LBqSni(ScVuxu)Hxq9vaT0Z(mwDlb8HhoWSKpmC4LCQrxOyEXl1f1F4fNEfJqI3(mwoLEcHGxoqfcOu8ISl9UnuaujijU6OwIOGbXgKbLXG2SzqaTOwPvUiPukjv3GyBqBRbEDkNGxC6vmcjE7Zy5u6jecoWSWkmC4LCQrxOyEXlhOcbukEr2LE3gkaQeKexDulruWGydYGYyqB2miGwuR0kxKukLKQBqSnOT1aVuxu)HxmVZNiuRULaQqSgIYHdmlBddhEjNA0fkMx8YbQqaLIxKDP3THcGkbjXvh1sefmi2GmOmg0MndcOf1kTYfjLsjP6geBdABnWl1f1F41UpOymToOwJUscCGzjRWWHxYPgDHI5fVuxu)HxU)CYfaneQLPRCcE5aviGsXRO4KbzcidIFJbTzZGyFqg(mmjN3d8j2NXwhrVkmnrc1LBqSbzq8z1GYEqg(mmP2VOmpGl5VpiEg0MndIXV3TaX5PaOInkozqMyqqD0bTzZGIItSXBPLmitmiwHx96eRJIxBdhywYpmC4L6I6p8cu77DXwNLSRobVKtn6cfZloWSW6WWHxQlQ)WlGO71b1Y0voHGxYPgDHI5fhyw43adhEPUO(dVm)GoTvQZceYF65e8so1OlumV4aZcF(y4Wl5uJUqX8IxoqfcOu8I9bz4ZWKA)IY8aUK)(GYEqg(mmjN3d8j2NXwhrVkmnrc1LBqSnOmAmiEg0Mnds3savijN3d8j2NXwhrVkmnb0l3GGmOg4L6I6p8YP9UvDr9NTxKaV6fjSNYj4LduH1rj4aZc)mWWHxQlQ)WlFIyRq4i4LCQrxOyEXboWlhOcRJsWWHzHpgo8so1OlumV41PCcEPBr8uGsSm)f2NXU)MfaEPUO(dV0TiEkqjwM)c7Zy3FZcahywYadhEjNA0fkMx8sDr9hE5m11)a8x5SgDLe4LWWiUWEkNGxotD9pa)voRrxjboWbE56I2ky4WSWhdhEPUO(dVA)IAfG)Eu)HxYPgDHI5fhywYadhEjNA0fkMx8YbQqaLIxg(mmP2VOmpGlrFZhEPUO(dVOkiNvjo5i1F4aZswWWHxYPgDHI5fVCGkeqP4vEpOOC5Qd6GYEq6wcOcjfEVpuVW6PGwHecib0l3GydYG4JxQlQ)WRwLBVaLZgVVZdhywYhgo8so1OlumV4LduHakfVm8zysEkOviHqTH37d1lij)D8sDr9hEXvh1sefGdmlScdhEPUO(dVA)IAn(EGxYPgDHI5fhyw2ggo8so1OlumV4L6I6p8YP9UvDr9NTxKaV6fjSNYj4LJsWbMLScdhEjNA0fkMx8sDr9hEr8u6B2A(bulv0WdVCGkeqP4vuCInElTKbzIbLLbTzZGm8zysTFrzEaxI(Mp8YzQRl2qbqLGGzHpoWSKFy4Wl5uJUqX8IxoqfcOu8YWNHj1(fL5bCjsOUCdITbXVXGGzqSpi(nguMdYWNHjz0)N29jrYFFq8GxQlQ)WlIpaihva24TCk9ecbhywyDy4Wl5uJUqX8IxoqfcOu8cOf1kTYfjLsjP6geBdIFJbL9GyFq0psepL(MTMFa1UR1LacdqiEQrxg0MndkkoXgVLwYGyBqzPXG4bVuxu)HxufKZ2(ffhyw43adhEPUO(dV4QJAihva4LCQrxOyEXbMf(8XWHxYPgDHI5fVuxu)HxC1rTgDLe4LduHakfVi7sVBdfavcsIRoQLikyqMyqTkOuJUK4QJAn6kjSHcGkbbVCM66Inuaujiyw4Jdml8ZadhEjNA0fkMx8YbQqaLIxSpiGwuR0kxKukLKQBqSniwnOSheqlQvALlskLssuFGg1FdYedkJbXZG2SzqaTOwPvUiPukjr9bAu)ni2gug4L6I6p8I4P03S1buIhoWSWply4Wl5uJUqX8IxQlQ)WlINsFZwZpGA316WlhOcbukEL3dk0UCrIRicW0KCQrxOdk7bbegGq8uJUmOShuuCInElTKbX2GyFqSpO8mi(PmgemdklPSmOmhezx6DBOaOsqsC1rTerbdINbL5GAvqPgDjrmVBdGwHfOxoI15jUCdkZbX(G4pO8mOgPg8ZyqzoiDlbuHKiIcQdQLwA)H6ljGE5guMdISl9UnuaujijU6OwIOGbXZG4bVCM66Inuaujiyw4Jdml8Zhgo8so1OlumV4L6I6p8Qv52lq5SX778WlhOcbukEbegGq8uJUmOShuuCInElTKbX2GyFqSpi(dcMbLLuwguMdISl9UnuaujijU6OwIOGbXZGYCqTkOuJUKAdBa0kSa9YrSopXLBqzoi2he)bbZGAK43yqzoiDlbuHKiIcQdQLwA)H6ljGE5guMdISl9UnuaujijU6OwIOGbXZG4bVCM66Inuaujiyw4Jdml8zfgo8so1OlumV4L6I6p8Qv52lq5SX778WlhOcbukEr)ir8u6B2A(bu7UwxcimaH4PgDzqzpi2huOD5IexreGPj5uJUqhu2dkkoXgVLwYGyBqSpi2he)uJbbZGYi1yqzoiYU072qbqLGK4QJAjIcgepdkZb1QGsn6sQnSCfXgaTclqVCeRZtC5guMdI9b1QGsn6sQnSCfXsOwNN4YnOmhezx6DBOaOsqsC1rTerbdINbXZG4bVCM66Inuaujiyw4Jdml83ggo8so1OlumV4LduHakfVm8zysTFrzEaxYFhVuxu)HxTFrTXdaYf4aZc)ScdhEjNA0fkMx8sDr9hEXvh1sefGx1fca4Vh2IbVIYLJWgKmY2WNHjXvh1sefydVe9nF4vDHaa(7HT44eAPHGx8XlhOcbukEr2LE3gkaQeKexDulruWGyBq8XlNNwhEXhhyw4NFy4Wl5uJUqX8IxQlQ)WlU6OwMUAkEvxiaG)Eylg8kkxocBqYiB2D)3PV5l1(f1A89i5VVzJ7)o9nFjU6OwJUsIK)op4vDHaa(7HT44eAPHGx8XlNNwhEXhhyw4Z6WWHxQlQ)WlINsFZwZpGA316Wl5uJUqX8IdCGd8QvaK6pmlz0iJgn2wJTHxMvWvhucET942Fqi0bTTbPUO(Bq9IeK00eV2bpt1f8YKdA5P038GYAbLqIPPjhKxe7K8h8WdTcpFJK75GNuC(DnQ)CaLjGNuCo4NMMCqn9pzq8ZhSdkJgz0yAonn5GYlp9GkK8300KdkpdkRtPcDqRQlNtstttoO8mO86VwbecDqHcGkHTygeX0luwFAAAYbLNbLx)1kGqOdkuaujsrXj24T0sgu8dkkoXgVLwYGm7jazq6(EVCQrxstttoO8mOSoLk0bXvh1sefydVbz4ZWmO4hK2(fDqgarZvh0bT9RJoOLOGb5807KozqHNgdsbYGm8zye6GmmDqW59(q9IbL)RGwHecinnNMMCq5Fy9IZpe6GmeMhidY9CgAmidbADK0GY6oNShKbD)LhpfWX43hK6I6pYG(RBAAAAYbPUO(JK2bI75m0actxj5MMMCqQlQ)iPDG4EodnGbc8m)tNMMCqQlQ)iPDG4EodnGbc8Qpuo5cnQ)MMMCqRt3jEFmiGw0bz4ZWi0brcnidYqyEGmi3ZzOXGmeO1rgKE0bTdK8S)ruh0bvKbr)tstttoi1f1FK0oqCpNHgWabEYP7eVpSKqdY0uDr9hjTde3ZzObmqGF)J6VPP6I6psAhiUNZqdyGaFRck1OlWEkNaHRoQ1ORKWgkaQeey)DiejGTv7(ceM()a2zpFjwbJULaQqsM9kYUai2NXgEILQCNqta9YXtwd25dtJugzvM6wcOcjrefuhulT0(d1xsa9YXdptt1f1FK0oqCpNHgWab(wfuQrxG9uobcX8UnaAfwGE5iwNN4Yb7VdHibSTA3xGWo)80i1iRYu3savijQOHNn8aVqsa9YbtJugzQBjGkKu49(q9cRNcAfsiGeqVC8Kj78ZtJudwxM6wcOcjfEVpuVW6PGwHecib0lxM6wcOcjrefuhulT0(d1xsa9YXZ0uDr9hjTde3ZzObmqGVvbLA0fypLtG0g2aOvyb6LJyDEIlhS)oeIeW2QDFbc78ZtJuJ8LPULaQqsH37d1lSEkOviHasa9YLNgPgSktDlbuHKi7vim(DRUVRGkQ)ijGE54zAQUO(JK2bI75m0agiW3QGsn6cSNYjqAdlxrSbqRWc0lhX68exoy)DiejGTv7(ce25NNgPgzvM6wcOcjrfn8SHh4fscOxU80i1ilzQBjGkKu49(q9cRNcAfsiGeqVC5PrQbRyvM6wcOcjr2Rqy87wDFxbvu)rsa9YXtMSZppnsnYiRYu3saviPW79H6fwpf0kKqajGE5Yu3savijIOG6GAPL2FO(scOxoEMMQlQ)iPDG4EodnGbc8TkOuJUa7PCcK2WYvelHADEIlhS)oeIeW2QDFbc)80i1GF(Yu3savijIOG6GAPL2FO(scOxUPP6I6psAhiUNZqdyGapXtPVzMhWbBXajVn8zysepL(MzEaxYFFAQUO(JK2bI75m0agiW7teBfchSNYjq0TiEkqjwM)c7Zy3FZcyAQUO(JK2bI75m0agiWZvh1A0vsaBXaHSl9UnuaujijU6OwIOatKXMn6wcOcjfEVpuVW6PGwHecib0lhKgtt1f1FK0oqCpNHgWab(wLBVaLZgVVZBAonn5GY)W6fNFi0bjTcW0bffNmOWtgK6IhmOImiTvRUA0L00uDr9hbcP6Y5KPP6I6pcmqG3Ni2keoY0uDr9hbgiWV)r9hSfdedFgMKr)FA3NejGOUyZMO4eB8wAjMas(1yZMqbqLi5jAp8s7UWezHvtt1f1FeyGaFRck1OlWEkNaH(bX6Vd7VdHibSTA3xGq)ir8u6B2A(bu7UwxkkxU6GMn9JuRYTxGYzJ335LIYLRoOtt1f1FeyGaptbeJ()uylgig(mmP2VOmpGl5Vpnvxu)rGbc8gcGiGC1bDAQUO(Jade47fuVGyZA6tHYjxmnvxu)rGbc865esa0U1P9oSfdedFgMu7xuMhWL83NMQlQ)iWabEdfQ9zSbOC5itt1f1FeyGapW)SQlQ)S9IeWEkNaX1fTvGTyGOUOAfRCcxje24pnvxu)rGbc8a)ZQUO(Z2lsa7PCcesDq7cSfde1fvRyLt4kHaH)0CAAYbXAjYG2(c3dmDqpZGY)67k6Gynar5idcuq9IbzimpqgKPV)GuGmi149Jbf)Gy0EFqVFmONzqBNVOmpGBAQUO(JKCuceoH7bMAFgB33vulfikhb2Ibc7g(mmP2VOmpGlrc1LJTmAKDDe9QWutaHvn4zZg2D(aGCHToIEvyQLc06YKD2H6OjoL1Nzg8aJ6I6VexDuRrxjrYPKWgfNWdpSvhrVkmDAQUO(JKCucmqG3O)p1(m2WtSYjCMonvxu)rsokbgiWd1xb0sp7Zy1TeWhEWwmqm8zysTFrzEaxIeQlhB8z10uDr9hj5OeyGaVprSviCWEkNaHtVIriXBFglNspHqGTyGq2LE3gkaQeKexDulruaBqYyZgGwuR0kxKukLKQJTT1yAQUO(JKCucmqGN5D(eHA1TeqfI1quoylgiKDP3THcGkbjXvh1sefWgKm2SbOf1kTYfjLsjP6yBBnMMQlQ)ijhLade439bfJP1b1A0vsaBXaHSl9UnuaujijU6OwIOa2GKXMnaTOwPvUiPukjvhBBRX00KdA7sRyqAmOUOKyqBJmidjmlYniNsI6GoO8A7wAqSwImOWtgetbiXGCkjguwFL1ZAhu8dcQedQIb93GYlwdSdk8KBqsRamDqeFdISD3xUyqoLedI49(D6GmKb5te6Gm7j3GYlVh4tg0ZmOT3r0RcthurgK6IQvg0dgufdYC17dciopfavguDdk8KbDcRpgeuhf2b9GbfEYGcfavIbvKbPgVFmO4heTK00uDr9hj5OeyGaV7pNCbqdHAz6kNaBVoX6Oq2gSfdKO4etaHFJnBy3WNHj58EGpX(m26i6vHPjsOUCSbHpRY2WNHj1(fL5bCj)DE2SHXV3TaX5PaOInkoXeqD0nBIItSXBPLycwnnvxu)rsokbgiWdQ99UyRZs2vNmnvxu)rsokbgiWdeDVoOwMUYjKPP6I6psYrjWabEZpOtBL6SaH8NEozAAYbXAjYGcpHidY9FN(MpYGQBqgsywKBqM((GbXNedsp6GY4OdA78fDq8(9yq1nitFFWGY4OdA78fL5bCdYSNCdY03FqEARmO8Y7b(Kb9mdA7De9QW0bPUOALPP6I6psYrjWabEN27w1f1F2ErcypLtG4avyDucSfde2n8zysTFrzEaxYFpBdFgMKZ7b(e7ZyRJOxfMMiH6YXwgn4zZgDlbuHKCEpWNyFgBDe9QW0eqVCqAmnn5GyncJ63JbXO9UH6YniMhmiFIA0LbvHWrYFdI1sKb93GC)3PV5lnnvxu)rsokbgiW7teBfchzAonvxu)rsUUOTcK2VOwb4Vh1Ftt1f1FKKRlARade4PkiNvjo5i1FWwmqm8zysTFrzEaxI(MVPP6I6psY1fTvGbc8Tk3EbkNnEFNhSfdK8okxU6GMTULaQqsH37d1lSEkOviHasa9YXge(tt1f1FKKRlARade45QJAjIcGTyGy4ZWK8uqRqcHAdV3hQxqs(7tt1f1FKKRlARade4B)IAn(Emnvxu)rsUUOTcmqG3P9UvDr9NTxKa2t5eiokzAQUO(JKCDrBfyGapXtPVzR5hqTurdpyDM66Inuaujiq4dBXajkoXgVLwIjYYMng(mmP2VOmpGlrFZ30uDr9hj56I2kWabEIpaihva24TCk9ecb2IbIHpdtQ9lkZd4sKqD5yJFdyyNFJmn8zysg9)PDFsK835zAAYbXAjYGynki3G2oFrh0FdkVyndY)6cHmiLsjdsbYGQZ9C1bDq1ni(nid6bdQlesAAQUO(JKCDrBfyGapvb5STFrHTyGa0IALw5IKsPKuDSXVr2St)ir8u6B2A(bu7UwxcimaH4PgDzZMO4eB8wAjSLLg8mnvxu)rsUUOTcmqGNRoQHCubmnvxu)rsUUOTcmqGNRoQ1ORKawNPUUydfavcce(Wwmqi7sVBdfavcsIRoQLikWeTkOuJUK4QJAn6kjSHcGkbzAQUO(JKCDrBfyGapXtPVzRdOepylgiSd0IALw5IKsPKuDSXQSbArTsRCrsPusI6d0O(ZezWZMnaTOwPvUiPukjr9bAu)Xwgtt1f1FKKRlARade4jEk9nBn)aQDxRdwNPUUydfavcce(WwmqY7q7YfjUIiattYPgDHMnqyacXtn6s2rXj24T0syJD2Zd)ugWKLuwYKSl9UnuaujijU6OwIOaEYSvbLA0LeX8UnaAfwGE5iwNN4YLj78ZtJud(zKPULaQqserb1b1slT)q9LeqVCzs2LE3gkaQeKexDulruap8mnvxu)rsUUOTcmqGVv52lq5SX778G1zQRl2qbqLGaHpSfdeGWaeINA0LSJItSXBPLWg7SZhMSKYsMKDP3THcGkbjXvh1sefWtMTkOuJUKAdBa0kSa9YrSopXLlt25dtJe)gzQBjGkKeruqDqT0s7puFjb0lxMKDP3THcGkbjXvh1sefWdptt1f1FKKRlARade4BvU9cuoB8(opyDM66Inuaujiq4dBXaH(rI4P03S18dO2DTUeqyacXtn6s2ShAxUiXvebyAso1Ol0SJItSXBPLWg7SZp1aMmsnYKSl9UnuaujijU6OwIOaEYSvbLA0LuBy5kInaAfwGE5iwNN4YLj7TkOuJUKAdlxrSeQ15jUCzs2LE3gkaQeKexDulruap8WZ0uDr9hj56I2kWab(2VO24ba5cylgig(mmP2VOmpGl5Vpnvxu)rsUUOTcmqGNRoQLika2Ibczx6DBOaOsqsC1rTerbSXhwNNwhe(WwxiaG)EylooHwAiq4dBDHaa(7HTyGeLlhHnizKTHpdtIRoQLikWgEj6B(MMQlQ)ijxx0wbgiWZvh1Y0vtH15P1bHpS1fca4Vh2IJtOLgce(WwxiaG)Eylgir5YrydsgzZU7)o9nFP2VOwJVhj)9nBC)3PV5lXvh1A0vsK835zAQUO(JKCDrBfyGapXtPVzR5hqT7ADtZPP6I6psYbQW6Oei(eXwHWb7PCceDlINcuIL5VW(m293SaMMQlQ)ijhOcRJsGbc8(eXwHWbRWWiUWEkNaXzQR)b4VYzn6kjMMtt1f1FKePoODbs7xuRa83J6VPP6I6psIuh0Uade4PkiNvjo5i1FWwmqm8zysTFrzEaxI(MVPP6I6psIuh0Uade4B)IAn(Emnvxu)rsK6G2fyGaVt7DR6I6pBVibSNYjqCuY00KdI1sKbT9RJoOLOGb93GwWnO)6MoOIzqM((dcQedsheCEVpuVyq5)kOviHaguwl4DdYCfEdsJb1fLedI)GwIcQd6GynL2FO(YGGdOvKMMQlQ)ijsDq7cmqGNRoQLika2IbIHpdtYtbTcjeQn8EFOEbj5VNT7)o9nFP2VOwJVhjGWP1rydc)eRYw3savijIOG6GAPL2FO(scOxo2GWFAAYbXAjYGwBxSMbzimpqgKt33Rd6GCEkaQqGDqpyqHNmOqbqLyqfzqQX7hdk(brljnnvxu)rsK6G2fyGapXtPVzR5hqTurdpylgiHcGkrkkoXgVLwIjYYMnU)7038LiEk9nBn)aQLkA4LCEkaQqGKXMnS7(VtFZxI4P03S18dOwQOHxY5PaOcbc)SD)3PV5lr8u6B2A(bulv0WlbeoToIjG6OjoL1ZZ0uDr9hjrQdAxGbc8eFaqoQaSXB5u6jecSfdedFgMu7xuMhWLiH6YXg)gWWo)gzA4ZWKm6)t7(Ki5VZZ0eMbzYbXAjYGynki3G2oFrh0FdkVyndY)6cHmiLsjdsbYGQZ9C1bDq1ni(nid6bdQlesAAQUO(JKi1bTlWabEQcYzB)IcBXabOf1kTYfjLsjP6yJFJPPjheRLidA7xh1qoQagKgdIpRBqpyqCpqgejuxocSd6bdQygu4jdkuaujgK5Q3heTKbv3G6cHmOWtVbXNvK00uDr9hjrQdAxGbc8C1rnKJkaylgiH2LlsC1rnKJkGKCQrxOB2WUHpdtQ9lkZd4sKqD5yJF(TztuCInElTetWNv8mnvxu)rsK6G2fyGapXtPVzR5hqTurdpylgi5THpdtQ9lkZd4s(7B2WU7)o9nFjINsFZwZpGAPIgEjNNcGkeizKTHpdtQ9lkZd4sKqD5mbFwXZ00KdI1sKbT8u6BEq5fqjEd6VbLxSMb5FDHqgu4jazqkqgKsPKbvN75QdAAAQUO(JKi1bTlWabEINsFZwhqjEWwmqaArTsRCrsPusQo2yv2aTOwPvUiPukjr9bAu)zImAmnn5G4vVCdk8KbT8u6BEqBxpGM)g025l6GCEkaQqgeZdgKoiJkgu8dkaMoi9OdsB)IoOVvaoDFVoOd6VbT9oIEvyAAAQUO(JKi1bTlWabEU6OwJUscylgiTkOuJUKOFqS(7zZo7aTOwPvUiX9TcNCrQo2CkjSrXjW0iXQSbArTsRCrI7Bfo5IuDMiF8SztEhAxUir8u6B2A(buB7x0KCQrxOB2y4ZWKA)IY8aUe9nFB2y4ZWKA)IY8aUejuxo24NVSzVoIEvyQjYQgB248uauHyzaQlQ)0oB8tzjl8SzJHpdtQ9lkZd4sKqD5mbe(5lB2RJOxfMAIT1yZgNNcGkeldqDr9N2zJFklzHhEMMQlQ)ijsDq7cmqGV9lQnEaqUa2Ibc9JeXtPVzR5hqT7ADjGWP1rylFzt)i1QC7fOC249DEjGWP1rylFzB4ZWKA)IY8aUK)(0uDr9hjrQdAxGbc8epL(MTMFa1UR1bBXabimaH4PgDj7O4eB8wAjSLVSZ7q7YfjUIiattYPgDHMDEhAxUirvqoB7x0KCQrxOtt1f1FKePoODbgiW3QC7fOC249DEWwmqacdqiEQrxYokoXgVLwcBBBZg2dTlxK4kIamnjNA0fA20psepL(MTMFa1UR1LacdqiEQrx4zAQUO(JKi1bTlWabEU6OwMUAkSopToi8HTUqaa)9WwCCcT0qGWh26cba83dBXajkxocBqYiB2D)3PV5l1(f1A89i5VVzJ7)o9nFjU6OwJUsIK)optt1f1FKePoODbgiWt8u6B2A(bu7UwhEr2fhMLmyv(HdCGXa]] )


end
