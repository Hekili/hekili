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
                if state.spec.shadow then gain( 6, "insanity" ) end
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


    spec:RegisterPack( "Shadow", 20200922, [[dSeG5aqiuuEKOuDjvjvPnjQ6tQsQQrPQsNsvfVsuYSuv1TefO2Lc)su0WevCmuWYOu5zIk10qrLRjkLTjkOVjkunorL4CQskRtuOmpuv6EQk7dvvhuvsQfsPQhkketevfUikQsBuvssnsvjj5KOOQALQIEPQKQyMIcKBIIQYorr(POsAOOQONQOPIcDvvjXwffWxvLuzVG(lfdg4WKwmL8yrMmHlJSzu5Ze1OPQoTKxRkXSPYTrPDl1Vvz4uLJJIQy5qEoutx46ez7OkFNsz8QssCEvPwVOqA(Qc7xPHmazeofAqqMSlh7YjNxZo7g2L7CEn7yo4mE7rWPNMErLj4SvwcoN(Q4SbNE6B3PciJWj(Kqjco9JWdNXYmt5k8LSgPJntCXk50OUoHuUitCXMYeoTKkxW83ql4uObbzYUCSlNCEn7YbovPW)qW5SyZiWPFjeudTGtbHtWz2xW0xfNTfWNOIWX(m7lysEbXArOfyxo)xGD5yxoWPRWbgYiCsym1jcdzeYedqgHtnf11WjlXEO3MJZ4KsLWiqKYIHtQvlhjG2ddit2bzeo1uuxdNwU7eMJZe(KHAI9nCsTA5ib0Eyazk3qgHtnf11WPSKIeL2MJZOzucDHpCsTA5ib0EyazI5GmcNuRwosaThotOkiuPWj2JCotOizkWd2QfgmPOfW)3cSBbpESaKwcdXJ6yOcbEu9c4FbzyoWPMI6A4K7ssysy0mkHQGmwKYcditzdYiCsTA5ib0E4mHQGqLcNypY5mHIKPapyRwyWKIwa)FlWUf84XcqAjmepQJHke4r1lG)fKH5aNAkQRHtpjuX9UAzJLtXbmGmLHqgHtQvlhjG2dNAkQRHZ01jQdKgKWW5uwcotOkiuPWzuS0c473cyiNf84Xc4KCodIs(ksMmrXslGVlqojwWJhliuKmfJOyjtCgrrlGVliBWPRAYKeWzgcditzCiJWPMI6A4evEEoYuTb7PjcoPwTCKaApmGmLlqgHtnf11WjIuVQLnCoLLWWj1QLJeq7HbKPxdYiCQPOUgoTDiNGhvTbr4R1orWj1QLJeq7HbKjgYbYiCQPOUgodFYi1wNulmChkrWj1QLJeq7HbmGtbXPsUaYiKjgGmcNAkQRHtC5OorWj1QLJeq7HbKj7GmcNuRwosaThotOkiuPWPLeh3WYDNWjHJbI0uSGhpwqOizkgrXsM4mIIwaF)wqUKZcE8ybHIKPy4tQl8hEPyb8Db5oBWPMI6A407I6Ayazk3qgHtQvlhjG2dNNhCIPao1uuxdN8uuPwoco5PojcofxmW(Q4SzSDiHXtREev6LQLxq(fiUyWtz9kuLmXjL8hrLEPAz4KNImTYsWP4cSrYdgqMyoiJWj1QLJeq7HZZdoXuaNAkQRHtEkQulhbN8uNebNIlgyFvC2m2oKW4PvpIk9s1Yli)cexm4PSEfQsM4Ks(JOsVuT8cYVaXfdbX7KqvlB8CQSenIk9s1YWjpfzALLGt15mIlWgjpyazkBqgHtQvlhjG2dNNhCIPao1uuxdN8uuPwoco5PojcoXEKZzcfjtbEWwTWGjfTa(xGDWjpfzALLGtmPOQLnDj7hSkImjP444GbKPmeYiCsTA5ib0E4utrDnCIKAJMI6AJRWbC6kCyALLGtwTAyad40drPJ1sdiJqMyaYiCsTA5ib0EyazYoiJWj1QLJeq7HbKPCdzeoPwTCKaApmGmXCqgHtQvlhjG2dditzdYiCQPOUgo9UOUgoPwTCKaApmGmLHqgHtQvlhjG2dNjufeQu4KzlWsIJBG9vXzJ7qSdjp4utrDnCI9vXzJ7qSWaYughYiCsTA5ib0E4Svwco1mk2xrk2WDDyooJ3zJqWPMI6A4uZOyFfPyd31H54mENncbdit5cKr4KA1YrcO9W55bNykGtnf11WjpfvQLJGtEQtIGtgwqwlaj1e3HKPbfeQvNjPoNjot4tgExjgeZJu55rc4KNImTYsWjB1cdMuKjjfhhhmGm9AqgHtnf11WjB1cJLtXbCsTA5ib0Eyad4mjWqgHmXaKr4KA1YrcO9WzcvbHkfoTK44g8UsWDi2HKhCQPOUgo9oBeYunNeUUggqMSdYiCQPOUgo5uYilPirPngoPwTCKaApmGmLBiJWj1QLJeq7HZeQccvkCwnw7kEVa(UGxlNfKFbmBbwsCCdExj4oe7qYdo1uuxdNSvlKvwcdditmhKr4KA1YrcO9WzcvbHkforAjmepQJHke4r1lG)fKTCGtnf11WPu7FU3M(4PWaYu2GmcNuRwosaThotOkiuPWjZwGLeh3G3vcUdXoK8wq(fWSfKUZjoB9G3vcdHK8I66HK3cYVaSh5CMqrYuGhSvlmysrlG)fWWcYVaMTGqDuhdmPOQLnDj7hSkIguRwosSGhpwWVlWsIJBW7kb3HyhsEli)cWEKZzcfjtbEWwTWGjfTa(Ua7wq(fWSfeQJ6yGjfvTSPlz)Gvr0GA1YrIf8ZcE8yb)UaljoUbVReChIDi5TG8liuh1XatkQAztxY(bRIOb1QLJel4h4utrDnCADxBoot4tgfNOwqcyazkdHmcNuRwosaTho1uuxdNj15mAkQRnUchWPRWHPvwcojmM6eHHbKPmoKr4utrDnCkHjtfelgoPwTCKaApmGbCADxdzeYedqgHtQvlhjG2dNjufeQu4e7roNjuKmf4bB1cdMu0c473cYnCQPOUgovCIAbjmwofhWaYKDqgHtQvlhjG2dNjufeQu483fG9iNZeksMc8GTAHbtkAb8Va7wq(feQJ6yGjfvTSPlz)Gvr0GA1YrIf84Xc(DbypY5mHIKPapyRwyWKIwa)lGHfKFbmBbH6OogysrvlB6s2pyvenOwTCKyb)SGFwq(fG9iNZeksMc8qXjQfKW0hpDb8VagGtnf11WPItuliHPpEkmGbCYQvdzeYedqgHtQvlhjG2dNjufeQu40sIJByDxBoot4tgfNOwqIHKhCQPOUgotQZz0uuxBCfoGtxHdtRSeCADxddit2bzeoPwTCKaApCMqvqOsHZFxGJ4rUfW3fKTCzbpESG0DoXzRhENnczQMtcxxpK8wWpli)cQgRDfVxa)FlG5Yzb5xWVlGzliuh1XWrYA6T54mHpz4DLyqTA5iXcE8yb)UGqDuhdhjRP3MJZe(KH3vIb1QLJeli)cexmeeVtcvTSXZPYs0iQ0lvlVGFwWpWPMI6A4K3vcdHK8I6Ayazk3qgHtQvlhjG2dNjufeQu4SAS2v8EiiUkvXc4)BbmKn4utrDnCY7kHX6CbmGmXCqgHtQvlhjG2dNAkQRHZK6Cgnf11gxHd40v4W0klbNjbggqMYgKr4KA1YrcO9WPMI6A4uOSTg11WzcvbHkfoz2c4POsTC0qDoJ4cSrYdotVtoYeksMcmKjgGbKPmeYiCsTA5ib0E4mHQGqLcNH6OogoswtVnhNj8jdVRedQvlhjwq(fKUZjoB9G3vcdHK8I66HK3cYVGQXAxX7f8TagYjh4utrDnCkiENeQAzJNtLLiyazkJdzeoPwTCKaApCQPOUgofeVtcvTSXZPYseCMqvqOsHZFxaI4qe2xTC0cE8ybvJ1UI3lG)fKXZ2c(zb5xWVlWr8i3c47cYwUSGhpwaZwq6oN4S1dVZgHmvZjHRRhsEl4NfKFb)UaMTGqDuhdmPOQLnDj7hSkIguRwosSGhpwWVliuh1XatkQAztxY(bRIOb1QLJeli)cy2c4POsTC0atkQAztxY(bRIitskooUf8Zc(zb5xWVlGzliuh1XWrYA6T54mHpz4DLyqTA5iXcE8yb)UGqDuhdhjRP3MJZe(KH3vIb1QLJeli)cSK44g8UsWDi2H4S1l4Nf8dCMENCKjuKmfyitmadit5cKr4KA1YrcO9WPMI6A4e7RIZMX2HegbPHpCMqvqOsHZqrYum8j1f(dVuSa(Ua7YbotVtoYeksMcmKjgGbKPxdYiCsTA5ib0E4utrDnCILqiQfeYeNHvfnHXWzcvbHkfodfjtXikwYeNru0c47cSlBli)cSK44g8UsWDi2H4S1Wz6DYrMqrYuGHmXamGmXqoqgHtnf11WjB1clQfecoPwTCKaApmGmXadqgHtQvlhjG2dNAkQRHtExjmXHquhWzcvbHkfo5POsTC0qDoJ4cSrYBb5xaZwq6oN4S1dExjmesYlQRhsEli)ccfjtXikwYeNru0c4FbmhCMENCKjuKmfyitmaditmyhKr4KA1YrcO9WzcvbHkforsnXDizA4PvBHi9fcz8WQJDqmpsLNhjwq(fWtrLA5OH4cSrYBb5xqOizkg(K6c)Hxkwa)li35aNAkQRHtSVkoBgBhsyeKg(WaYed5gYiCsTA5ib0E4mHQGqLcNypY5mHIKPapW(Q4Szsif7VGVfWWcYVGFxq6oN4S1dSVkoBMesX(JKVIKj8c(wqUxWJhlqqwsCCdSVkoBMesX(gbzjXXnK8wWJhlqtrD9a7RIZMjHuS)OAdNRK9Jf84XccfjtXikwYeNru0c47cs35eNTEG9vXzZKqk2FWj5CgeL8vKmzIILwWpli)cqAjmepQJHke4r1lG)fK7CGtnf11Wj2xfNntcPyFyazIbMdYiCsTA5ib0E4mHQGqLcNiTegIh1Xqfc8O6fW)cYDoli)cWEKZzcfjtbEG9vXzZKqk2Fb8VagGtnf11Wj2xfNntcPyFyazIHSbzeoPwTCKaApCQPOUgozRwyWKIGZ07KJmHIKPadzIb4S6GqijVWuCWzuPxW8)zhCwDqiKKxykwwsuAqWjdWzcvbHkfoXEKZzcfjtbEWwTWGjfTa(xapfvQLJgSvlmysrMKuCCCli)cSK44gcf9Ij8pjz)apK8GZKVwnCYamGmXqgczeoPwTCKaApCQPOUgozRwy4C6B4S6GqijVWuCWzuPxW8)zx(0DoXzRh8UsySoxmK8GZQdcHK8ctXYsIsdcozaotOkiuPWPLeh3qOOxmH)jj7h4HK3cYVaEkQulhnexGnsEWzYxRgozagqMyiJdzeoPwTCKaApCkHjJn)YrMKIJQLHmXaCQPOUgoXKIQw20LSFWQicotVtoYeksMcmKjgGZeQccvkC(7c4POsTC0atkQAztxY(bRIitskooUfKFb)UahXJClGVliB5YcE8ybmBbP7CIZwp8oBeYunNeUUEi5TGFwWpl4XJf87cexmW(Q4SzSDiHXtREGioeH9vlhTG8la7roNjuKmf4bB1cdMu0c4FbmSGFGbKjgYfiJWj1QLJeq7HtjmzS5xoYKuCuTmKjgGtnf11WjB1cJLtXbCMqvqOsHtEkQulhnexGnsEWaYedVgKr4KA1YrcO9WzcvbHkfo5POsTC0qCb2i5TG8laPLWq8OogShpIL6yu9c4FbjfhMOyPfK1cYzKTfKFbypY5mHIKPapyRwyWKIwaFxaZbNAkQRHt2QfglNIdyazYUCGmcNuRwosaThotOkiuPWjI4qe2xTC0cYVGqrYumIILmXzefTa(xaZTG8lGzliuh1XGTWe69GA1YrIfKFbH6OogE43j)kzCv)YGA1YrIfKFbypY5mHIKPapyRwyWKIwa)lWo4utrDnCI9vXzZy7qcJNwnmGmzhdqgHtQvlhjG2dNAkQRHtSVkoBgBhsy80QHZeQccvkCIioeH9vlhTG8liuKmfJOyjtCgrrlG)fWCli)cy2cc1rDmylmHEpOwTCKyb5xWVlGzliuh1XWd)o5xjJR6xguRwosSGhpwWVliuh1XWd)o5xjJR6xguRwosSG8la7roNjuKmf4bB1cdMu0c473cSBb)SGFGZ07KJmHIKPadzIbyazYo7GmcNuRwosaTho1uuxdN8uwVcvjtCsjF4mHQGqLcNiIdryF1Yrli)ccfjtXikwYeNru0c4Fbz4cE8yb)UGqDuhd2ctO3dQvlhjwq(fiUyG9vXzZy7qcJNw9arCic7RwoAb)SGhpwGLeh3qQ5KqUQLncf9sty8qYdotVtoYeksMcmKjgGbKj7YnKr4KA1YrcO9WPMI6A4KTAHbtkcotVtoYeksMcmKjgGZQdcHK8ctXbNrLEbZ)NDWz1bHqsEHPyzjrPbbNmaNjufeQu4e7roNjuKmf4bB1cdMu0c4Fb8uuPwoAWwTWGjfzssXXXbNjFTA4KbyazYoMdYiCsTA5ib0E4utrDnCYwTWW503Wz1bHqsEHP4GZOsVG5)ZU8P7CIZwp4DLWyDUyi5bNvhecj5fMILLeLgeCYaCM81QHtgGbKj7YgKr4utrDnCI9vXzZy7qcJNwnCsTA5ib0EyadyaN8ieUUgYKD5yxo58A2LdCAtrD1Yy4K5N17qbjwqgUanf11lWv4ap2NWj2JsqMSlB5cC6HoUYrWz2xW0xfNTfWNOIWX(m7lysEbXArOfyxo)xGD5yxo7Z9z2xaZ7RcLKcsSalI7q0cshRLglWIKRgpwWRoLiVaVG(6myFfXYj5wGMI6A8cU29ESp1uuxJhEikDSwA8X5u8l7tnf114HhIshRLgz9Lj3DI9PMI6A8WdrPJ1sJS(YuLKzPo0OUEFM9fmB1d7FXcqAjwGLehhjwao0aValI7q0cshRLglWIKRgVaTflWdrzWExevlVGcVaX10yFQPOUgp8qu6yT0iRVmXT6H9VWGdnW7tnf114HhIshRLgz9LP3f117tnf114HhIshRLgz9Lj2xfNnUdX(V4(yMLeh3a7RIZg3HyhsE7tnf114HhIshRLgz9LPeMmvqS)BLL(0mk2xrk2WDDyooJ3zJq7tnf114HhIshRLgz9LjpfvQLJ(3kl9XwTWGjfzssXXX9)8(Wu8NN6KOpgYcj1e3HKPbfeQvNjPoNjot4tgExjgeZJu55rI9PMI6A8WdrPJ1sJS(YKTAHXYP4yFUpZ(cyEFvOKuqIfq8i07feflTGWNwGMIdTGcVaLNwo1YrJ9PMI6A8hUCuNO9PMI6ACwFz6DrD9)I7ZsIJBy5Ut4KWXarAkE8iuKmfJOyjtCgrr89lxY5XJqrYum8j1f(dVuW3CNT9PMI6ACwFzYtrLA5O)TYsFIlWgjV)N3hMI)8uNe9jUyG9vXzZy7qcJNw9iQ0lvlNxCXGNY6vOkzItk5pIk9s1Y7tnf114S(YKNIk1Yr)BLL(uNZiUaBK8(FEFyk(ZtDs0N4Ib2xfNnJTdjmEA1JOsVuTCEXfdEkRxHQKjoPK)iQ0lvlNxCXqq8oju1YgpNklrJOsVuT8(utrDnoRVm5POsTC0)wzPpmPOQLnDj7hSkImjP444(FEFyk(ZtDs0h2JCotOizkWd2QfgmPi(TBFQPOUgN1xMiP2OPOU24kC8Vvw6JvREFUp1uuxJhjb(Z7Srit1Cs466)f3NLeh3G3vcUdXoK82NAkQRXJKaN1xMCkzKLuKO0gVp1uuxJhjboRVmzRwiRSe(FX9vnw7kEZ3xlN8mZsIJBW7kb3HyhsE7tnf114rsGZ6ltP2)CVn9Xt)xCFiTegIh1Xqfc8OA(Zwo7tnf114rsGZ6ltR7AZXzcFYO4e1cs8V4(yMLeh3G3vcUdXoK8YZS0DoXzRh8UsyiKKxuxpK8YJ9iNZeksMc8GTAHbtkIFgYZSqDuhdmPOQLnDj7hSkIguRwos84XVwsCCdExj4oe7qYlp2JCotOizkWd2QfgmPi(AxEMfQJ6yGjfvTSPlz)Gvr0GA1YrIFE84xljoUbVReChIDi5Lpuh1XatkQAztxY(bRIOb1QLJe)Sp1uuxJhjb(lPoNrtrDTXv44FRS0hHXuNi8(m7lGpiovYflGtDoln9Yc4o0cKWQLJwqfeloJTGxbtl46fKUZjoB9yFQPOUgpscCwFzkHjtfelEFUp1uuxJhw31FkorTGeglNIJ)f3h2JCotOizkWd2QfgmPi((L79PMI6A8W6UoRVmvCIAbjm9Xt)xCF)I9iNZeksMc8GTAHbtkIF7YhQJ6yGjfvTSPlz)Gvr0GA1YrIhp(f7roNjuKmf4bB1cdMue)mKNzH6OogysrvlB6s2pyvenOwTCK4NFYJ9iNZeksMc8qXjQfKW0hpLFg2N7tnf114bHXuNi8hlXEO3MJZ4KsLWiqKYI3NAkQRXdcJPor4S(Y0YDNWCCMWNmutSV3NAkQRXdcJPor4S(YuwsrIsBZXz0mkHUWFFQPOUgpimM6eHZ6ltUljHjHrZOeQcYyrk7)I7d7roNjuKmf4bB1cdMue)F294bslHH4rDmuHapQM)mmN9PMI6A8GWyQteoRVm9Kqf37QLnwofh)lUpSh5CMqrYuGhSvlmysr8)z3JhiTegIh1Xqfc8OA(ZWC2NAkQRXdcJPor4S(YmDDI6aPbjmCoLL(7QMmjXxg(V4(IIL47hd584bNKZzquYxrYKjkwIVYjXJhHIKPyeflzIZikIVzBFQPOUgpimM6eHZ6ltu555it1gSNMO9PMI6A8GWyQteoRVmrK6vTSHZPSeEFQPOUgpimM6eHZ6ltBhYj4rvBqe(ATt0(utrDnEqym1jcN1xMHpzKARtQfgUdLO95(utrDnEWQv)LuNZOPOU24kC8Vvw6Z6U(FX9zjXXnSURnhNj8jJItuliXqYBFM9fmF3Pfi5TGmWvcUdXUaTflGppBeAbm)nNeUUEbzK7CIZwJxG2IfCClqcxT8cYGUidSaV7ClOAS2v8Ebwe3HOfKuCuT8yFQPOUgpy1QZ6ltExjmesYlQR)xCF)6iEKJVzlxE8iDNtC26H3zJqMQ5KW11djVFYxnw7kEZ)hZLt(FzwOoQJHJK10BZXzcFYW7kXGA1YrIhp(nuh1XWrYA6T54mHpz4DLyqTA5irEXfdbX7KqvlB8CQSenIk9s1Y)8Z(utrDnEWQvN1xM8UsySox8V4(QgRDfVhcIRsvW)hdzBFQPOUgpy1QZ6lZK6Cgnf11gxHJ)TYsFjbEFM9fWNiIJqliUfiHPfWhkBRrD9cE1ZxnFUGIBbA)Eb8XX4ck8c6lwGK3(utrDnEWQvN1xMcLT1OU(F6DYrMqrYuG)y4FX9XmEkQulhnuNZiUaBK82NzFbVcMwaFq8oju1YlGpDQSeTauj7hlWI4oeTG3N0cKVfuDClqxqg0fzGfKbUsWDi2X(utrDnEWQvN1xMcI3jHQw245uzj6FX9fQJ6y4izn92CCMWNm8UsmOwTCKiF6oN4S1dExjmesYlQRhsE5RgRDfV)yiNC2NzFb8X1V(XcKW0c4dI3jHQwEb8PtLLOfuCl49jTGK2lqMIfuDClidCLG7qSlOACqQ4)co0ckUfmjfvT8cyQK9dwfrlOWliuh1bjwG2IfyRCUf4xXcO(KK9xqOizkWJ9PMI6A8GvRoRVmfeVtcvTSXZPYs0)07KJmHIKPa)XW)I77xeXHiSVA5OhpQgRDfV5pJNTFY)RJ4ro(MTC5XdMLUZjoB9W7Srit1Cs466HK3p5)LzH6OogysrvlB6s2pyvenOwTCK4XJFd1rDmWKIQw20LSFWQiAqTA5irEMXtrLA5ObMuu1YMUK9dwfrMKuCCC)8t(FzwOoQJHJK10BZXzcFYW7kXGA1YrIhp(nuh1XWrYA6T54mHpz4DLyqTA5irEljoUbVReChIDioB9p)SpZ(cEfmTGPVkoBl41DirgBb8bPH)ckUfe(0ccfjtXck8cuRtkwqClqu0yFQPOUgpy1QZ6ltSVkoBgBhsyeKg()tVtoYeksMc8hd)lUVqrYum8j1f(dVuWx7YzFM9f8kyAbtjeIAbHwqClG5tfnHXl46fOliuKmfli81ybfEbYx1YliUfikAbASGWNwaQK9Jfefln2NAkQRXdwT6S(YelHquliKjodRkAcJ)NENCKjuKmf4pg(xCFHIKPyeflzIZikIV2LT8wsCCdExj4oe7qC269PMI6A8GvRoRVmzRwyrTGq7ZSVGxbtlidCLybmEie1XcU29Ebf3cuNBb8XXiEbkIwGMIIhTaTfli8PfeksMIfy76x)ybIIwGqcvT8ccFAbjFTBYn2NAkQRXdwT6S(YK3vctCie1X)07KJmHIKPa)XW)I7JNIk1Yrd15mIlWgjV8mlDNtC26bVRegcj5f11djV8HIKPyeflzIZikIFMBFM9f8kyAbZxxgJpwGAD8OfK7CE9UGxv85cS5t9c4tTAlePVqOfWNy1XUaVZgHwqHxGMIIhTp1uuxJhSA1z9Lj2xfNnJTdjmcsd))f3hsQjUdjtdpTAlePVqiJhwDSdI5rQ88irEEkQulhnexGnsE5dfjtXWNux4p8sb)5oN9z2xWRGPfOo3cs(ksMWl44wW0xfNTfKrqk2FbvVaDbOZ2cUEbZQLD0ccfjtX)fCOfuCli8PfyDy8ck8cuRtkwqClqu0yFQPOUgpy1QZ6ltSVkoBMesX()lUpSh5CMqrYuGhyFvC2mjKI9)yi)VP7CIZwpW(Q4Szsif7ps(ksMWF5(XdbzjXXnW(Q4Szsif7BeKLeh3qY7Xdnf11dSVkoBMesX(JQnCUs2pE8iuKmfJOyjtCgrr8nDNtC26b2xfNntcPy)bNKZzquYxrYKjkw6N8iTegIh1Xqfc8OA(ZDo7ZSVGxbtly6RIZ2cYiif7VGRxqgHpwGu7imEbHpHOfOiAbQqGxq1PJTA5X(utrDnEWQvN1xMyFvC2mjKI9)xCFiTegIh1Xqfc8OA(ZDo5XEKZzcfjtbEG9vXzZKqk2NFg2NzFbVcMwaZx1IfmjfTG4wq6ASelTa(qrVSag9pjz)aVap0LWl46f8QZvM3Xcymx5JCDbzKR5ke7ck8cc)cVGcVaDb(LSpHwGhQoufVxq4R9cqK4IOA5fC9cE15kZ7cKAhHXlqOOxwq4FsY(bEbfEbQ1jfliUfeflTGtk2NAkQRXdwT6S(YKTAHbtk6F6DYrMqrYuG)y4FX9H9iNZeksMc8GTAHbtkIFEkQulhnyRwyWKImjP444YBjXXnek6ft4FsY(bEi59p5Rv)XW)QdcHK8ctXYsIsd6JH)vhecj5fMI7lQ0ly()SBFM9f8kyAbmFvlwWRAN(EbXTG01yjwAb8HIEzbm6FsY(bEbEOlHxW1lyY4ybmMR8rUUGmY1CfIDbf3cc)cVGcVaDb(LSpHwGhQoufVxq4R9cqK4IOA5fi1ocJxGqrVSGW)KK9d8ck8cuRtkwqClikwAbNuSp1uuxJhSA1z9LjB1cdNtF)V4(SK44gcf9Ij8pjz)apK8YZtrLA5OH4cSrY7FYxR(JH)vhecj5fMILLeLg0hd)RoiesYlmf3xuPxW8)zx(0DoXzRh8UsySoxmK82NzFbVcMwWKuu1YlGPs2pyveTGIBbVpPfyRCUf4xXc0ybosXXcY9ccfjtbEbAlwaFE2i0cy(BojCD9c0wSGmWvcUdXUafrlOVybisfV)VGdTG4waI4qe2FbZxxgJpxW1liSDl4qlG9q0ccfjtbESp1uuxJhSA1z9LjMuu1YMUK9dwfr)LWKXMF5itsXr1YFm8p9o5itOizkWFm8V4((LNIk1YrdmPOQLnDj7hSkImjP444Y)RJ4ro(MTC5XdMLUZjoB9W7Srit1Cs466HK3p)84XVIlgyFvC2m2oKW4PvpqehIW(QLJYJ9iNZeksMc8GTAHbtkIFg(zFM9fWyUYh56cs(AltlWDYvAbxVaB(uVG4wGeMwq14q7ybwofh49PMI6A8GvRoRVmzRwySCko(lHjJn)YrMKIJQL)y4FX9XtrLA5OH4cSrYBFM9fWyUYh56cYaeQ4EVGqrYuSGK6Tp1uuxJhSA1z9LjB1cJLtXX)I7JNIk1YrdXfyJKxEKwcdXJ6yWE8iwQJr18NuCyIILYkNr2YJ9iNZeksMc8GTAHbtkIVm3(m7ly6rPsDliDTOI66fe3cWX5TGKIJQLxW81LX4ZfC9cooUm4qrYuGxGnFQxaxj7hvlVGCVGdTa2drlahA6fsSa2ZcVaTflqcxT8c4t87KFLwqgu1VSaTflGPCLXfW8vyc9ESp1uuxJhSA1z9Lj2xfNnJTdjmEA1)lUpeXHiSVA5O8HIKPyeflzIZikIFMlpZc1rDmylmHEpOwTCKiFOoQJHh(DYVsgx1VmOwTCKip2JCotOizkWd2QfgmPi(TBFM9f86HiVfmFDzm(CbsEl46fO4fWQ97feksMc8cu8c8omUSC0)fqVkjYlwGnFQxaxj7hvlVGCVGdTa2drlahA6fsSa2ZcVaBv4Va(e)o5xPfKbv9lJ9PMI6A8GvRoRVmX(Q4SzSDiHXtR(F6DYrMqrYuG)y4FX9HioeH9vlhLpuKmfJOyjtCgrr8ZC5zwOoQJbBHj07b1QLJe5)LzH6OogE43j)kzCv)YGA1YrIhp(nuh1XWd)o5xjJR6xguRwosKh7roNjuKmf4bB1cdMueF)S7NF2NAkQRXdwT6S(YKNY6vOkzItk5)p9o5itOizkWFm8V4(qehIW(QLJYhksMIruSKjoJOi(ZWhp(nuh1XGTWe69GA1YrI8IlgyFvC2m2oKW4PvpqehIW(QLJ(5XdljoUHuZjHCvlBek6LMW4HK3(utrDnEWQvN1xMSvlmysr)tVtoYeksMc8hd)lUpSh5CMqrYuGhSvlmysr8ZtrLA5ObB1cdMuKjjfhh3)KVw9hd)RoiesYlmflljknOpg(xDqiKKxykUVOsVG5)ZU9PMI6A8GvRoRVmzRwy4C67)jFT6pg(xDqiKKxykwwsuAqFm8V6GqijVWuCFrLEbZ)ND5t35eNTEW7kHX6CXqYBFQPOUgpy1QZ6ltSVkoBgBhsy80QHbmGqa]] )


end
