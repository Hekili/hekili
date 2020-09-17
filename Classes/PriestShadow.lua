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

                if talent.unfurling_darkness.enabled and buff.unfurling_darkness.down and buff.unfurling_darkness_icd.down then
                    applyBuff( "unfurling_darkness" )
                    applyDebuff( "player", "unfurling_darkness_icd" )
                end

                removeBuff( "unfurling_darkness" )                
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


    spec:RegisterPack( "Shadow", 20200915.1, [[dSurYaqirfEKOqxsuvj2KkXNevvQrHIQtHIYReLmlvs3cLeAxk5xeQgMOkhtPQLjk1ZevLPHIuxdLOTHsOVHIOgNOaNtuv16qjjZdLu3tLAFIIoOOGSqcLhIsIMiksUikc1gffuzKIcQ6KOiKvQu6LIQkPzIscUjkcANOGFkQOgkkbpvftff6QIkYwrrKVkQQyVG(lLgmWHjTyH6XImzIUmYMPOptHrtWPL8ArLMTGBJk7wQFRQHlKJJIalhYZHA6uDDu12jKVJsnErbLZRuz9OKuZxPy)kgUhYi8ivNGmKDEzNxE5)EM8AF(NpwMpweE8Dre8ePPCvdcEALJGNJGkF2WtKUl8QeYi8GFEuIGhb3JWSkXf3OCb(4v65ehxC8b1RVti10fhxCjXHNy(k4mrnmgEKQtqgYoVSZlV8FplU2N)SmBwYKHhL3fEe8Ckowj8iusj1Wy4rs4e8KXbCeu5ZEaSaQiSpBZ4aouKtCXeAa7z51bKDEzNh8ekSJHmcpegtDIWqgHmShYi8OjV(gE4iUhTZ(M2aFQKwjIuom8qTghijumOdziBiJWJM86B4jo8V0(MwxGSutC7GhQ14ajHIbDid5dYi8OjV(gEm4vKS02(MwLvtO3fGhQ14ajHIbDidmnKr4HAnoqsOyWtcvoHkfEWruiyDfzqoEXvT0IjfnGmVhq2dyZMbG0sAjru7lvkXRQhqMdGfZdE0KxFdpMFIhtsRYQju5KnMuoOdzGLqgHhQ14ajHIbpju5eQu4bhrHG1vKb54fx1slMu0aY8EazpGnBgaslPLerTVuPeVQEazoawmp4rtE9n8eXJkZDvByJdk2HoKbweYi8qTghijum4rtE9n8K(orTJuNKwZGYrWtcvoHkfE8IJgaRVhW(8gWMndWKpeSikjOidY6fhnawpaJKCaB2maxrgKV8IJS(BLfnawpawcpHQjBscpSi0HmWKHmcpAYRVHhufffiB1wCKMi4HAnoqsOyqhYqgazeE0KxFdpisJQ2WAguocdpuRXbscfd6qgYFiJWJM86B4H9Jcsru1weH)w7ebpuRXbscfd6qg2NhKr4rtE9n84cKLVJF(wAnFuIGhQ14ajHIbDOdpsYu5doKrid7HmcpAYRVHhCfOorWd1ACGKqXGoKHSHmcpuRXbscfdEsOYjuPWtmVP5ko8VmWJ9fI0KpGnBgGRidYxEXrw)TYIgaRVhqgK3a2SzaUImiFjqAWfwrjFaSEa5JLWJM86B4j696BOdziFqgHhQ14ajHIbpFe8GjhE0KxFdpIuuPXbcEePbEcEKVVWcQ8zBz)iPnsRE5vk3QngWLbiFFjs5IkuLS(ZNewELYTAd4rKISTYrWJ8DSLpc6qgyAiJWd1ACGKqXGNpcEWKdpAYRVHhrkQ04abpI0apbpY3xybv(STSFK0gPvV8kLB1gd4YaKVVePCrfQsw)5tclVs5wTXaUma57ljj65rvByJcQbpT8kLB1gWJifzBLJGhneSY3Xw(iOdzGLqgHhQ14ajHIbpFe8GjhE0KxFdpIuuPXbcEePbEcEWruiyDfzqoEXvT0IjfnGmhq2WJifzBLJGhmPOQnSDzi4CkISjE)nnHoKbweYi8qTghijum4rtE9n8G4BRM86BBOWo8ekSBBLJGhoTAOdD4jcrPNlwDiJqg2dzeEOwJdKekg0HmKnKr4HAnoqsOyqhYq(GmcpuRXbscfd6qgyAiJWd1ACGKqXGoKbwczeE0KxFdprVxFdpuRXbscfd6qgyriJWd1ACGKqXGNeQCcvk8KJbeZBAUWcQ8zB(iUfFe8OjV(gEWcQ8zB(ioOdzGjdzeEOwJdKekg80khbpkRglOifBn)2TVPn6zti4rtE9n8OSASGIuS18B3(M2ONnHGoKHmaYi8qTghijum45JGhm5WJM86B4rKIknoqWJinWtWZ(bK1aq8nz(idAroHAnytAiy936cKv0xYfXeWxrrKeEePiBRCe8WvT0Ijfzt8(BAcDid5pKr4rtE9n8WvT0ghuSdpuRXbscfd6qhEssmKrid7HmcpuRXbscfdE0KxFdpjneSAYRVTHc7WtOWUTvocEimM6eHHoKHSHmcpAYRVHhEmzlN4WWd1ACGKqXGo0HhoTAiJqg2dzeEOwJdKekg8KqLtOsHhMpGajIcdG1dGLzWa2SzaP)dYNDVIE2eYwTjpU(EXhnaMnGldOAS2LVBazEpaMoVbCzamFa5yaUgO2xbYqt7SVP1fiROVKlQ14ajhWMndG5dW1a1(kqgAAN9nTUazf9LCrTghi5aUma57ljj65rvByJcQbpT8kLB1gdGzdGzWJM86B4r0xslH4J86BOdziBiJWd1ACGKqXGNeQCcvk8unw7Y3TKKzLkFazEpG9SeE0KxFdpI(sAJ)GdDid5dYi8qTghijum4rtE9n8K0qWQjV(2gkSdpHc72w5i4jjXqhYatdzeEOwJdKekg8OjV(gEKkxRE9n8KqLtOsHNCmarkQ04aT0qWkFhB5JGN0UuGSUImihdzyp0HmWsiJWd1ACGKqXGNeQCcvk84AGAFfidnTZ(MwxGSI(sUOwJdKCaxgq6)G8z3lrFjTeIpYRVx8rd4YaQgRD57gW9a2NxEWJM86B4rsIEEu1g2OGAWtqhYalczeEOwJdKekg8OjV(gEKKONhvTHnkOg8e8KqLtOsHhMpaezIiSGghObSzZaQgRD57gqMdGjZYbWSbCzamFabsefgaRhalZGbSzZaYXas)hKp7Ef9SjKTAtEC99IpAamBaxgaZhqogGRbQ9fMuu1g2UmeCofrlQ14ajhWMndG5dW1a1(ctkQAdBxgcoNIOf1ACGKd4YaYXaePOsJd0ctkQAdBxgcoNIiBI3FtZbWSbWSbCzamFa5yaUgO2xbYqt7SVP1fiROVKlQ14ajhWMndG5dW1a1(kqgAAN9nTUazf9LCrTghi5aUmGyEtZLOVKMpIBjF29ay2ayg8K2LcK1vKb5yid7HoKbMmKr4HAnoqsOyWJM86B4blOYNTL9JKwjPUa8KqLtOsHhxrgKVein4cROKpawpGSZdEs7sbY6kYGCmKH9qhYqgazeEOwJdKekg8OjV(gEW8ie1scz93YPYMWy4jHkNqLcpUImiF5fhz93klAaSEazZYbCzaX8MMlrFjnFe3s(SB4jTlfiRRidYXqg2dDid5pKr4rtE9n8WvTmMAjHGhQ14ajHIbDid7ZdYi8qTghijum4rtE9n8i6lP1FeIAhEsOYjuPWJifvACGwAiyLVJT8rd4YaYXas)hKp7Ej6lPLq8rE99IpAaxgGRidYxEXrw)TYIgqMdGPHN0UuGSUImihdzyp0HmSFpKr4HAnoqsOyWtcvoHkfEq8nz(idAfPvhJinxczJWAGBrmb8vuejhWLbisrLghOL8DSLpAaxgGRidYxcKgCHvuYhqMdiF5bpAYRVHhSGkF2w2psALK6cqhYW(SHmcpuRXbscfdEsOYjuPWdoIcbRRidYXlSGkF22esXcd4Ea7hWLbW8bK(piF29clOYNTnHuSWkjOidcpG7bKVbSzZaKumVP5clOYNTnHuSGvsX8MMl(ObSzZa0KxFVWcQ8zBtiflSQ2AgkdbFaB2maxrgKV8IJS(BLfnawpG0)b5ZUxybv(STjKIfwM8HGfrjbfzqwV4ObWSbCzaiTKwse1(sLs8Q6bK5aYxEWJM86B4blOYNTnHuSa0HmSpFqgHhQ14ajHIbpju5eQu4bPL0sIO2xQuIxvpGmhq(YBaxgaoIcbRRidYXlSGkF22esXcdiZbShE0KxFdpybv(STjKIfGoKH9mnKr4HAnoqsOyWJM86B4HRAPftkcEs7sbY6kYGCmKH9Wt1oHq8rUTmHhVs5IZ8oB4PANqi(i3wCCKSuNGN9WtcvoHkfEWruiyDfzqoEXvT0IjfnGmhGifvACGwCvlTysr2eV)MMd4YaI5nnxsfLR1fEEdbhV4JGNKGwn8Sh6qg2ZsiJWd1ACGKqXGhn513Wdx1sRzq3bpv7ecXh52YeE8kLloZ7SVK(piF29s0xsB8h8fFe8uTtieFKBlooswQtWZE4jHkNqLcpX8MMlPIY16cpVHGJx8rd4YaePOsJd0s(o2YhbpjbTA4zp0HmSNfHmcpuRXbscfdE4XKLTqfiBsXE1gqg2dpAYRVHhmPOQnSDzi4CkIGN0UuGSUImihdzyp8KqLtOsHhMparkQ04aTWKIQ2W2LHGZPiYM4930CaxgaZhqGerHbW6bWYmyaB2mGCmG0)b5ZUxrpBczR2KhxFV4JgaZgaZgWMndG5dq((clOYNTL9JK2iT6fImrewqJd0aUmaCefcwxrgKJxCvlTysrdiZbSFamd6qg2ZKHmcpuRXbscfdE4XKLTqfiBsXE1gqg2dpAYRVHhUQL24GID4jHkNqLcpIuuPXbAjFhB5JGoKH9zaKr4HAnoqsOyWtcvoHkfEePOsJd0s(o2YhnGldaPL0sIO2xCViIJAFv9aYCajf7wV4ObK1aYBXYbCza4ikeSUImihV4QwAXKIgaRhatdpAYRVHhUQL24GIDOdzyF(dzeEOwJdKekg8KqLtOsHhezIiSGghObCzaUImiF5fhz93klAazoaMEaxgqogGRbQ9fxHj0Uf1ACGKd4YaCnqTVIW7scvYgQo3f1ACGKd4YaWruiyDfzqoEXvT0IjfnGmhq2WJM86B4blOYNTL9JK2iTAOdzi78GmcpuRXbscfdE0KxFdpybv(STSFK0gPvdpju5eQu4brMiclOXbAaxgGRidYxEXrw)TYIgqMdGPhWLbKJb4AGAFXvycTBrTghi5aUmaMpGCmaxdu7Ri8UKqLSHQZDrTghi5a2SzamFaUgO2xr4DjHkzdvN7IAnoqYbCza4ikeSUImihV4QwAXKIgaRVhq2dGzdGzWtAxkqwxrgKJHmSh6qgYEpKr4HAnoqsOyWJM86B4rKYfvOkz9Npjapju5eQu4brMiclOXbAaxgGRidYxEXrw)TYIgqMdGfhWMndG5dW1a1(IRWeA3IAnoqYbCzaY3xybv(STSFK0gPvVqKjIWcACGgaZgWMndiM30CX3M8Oq1gwPIYTjmEXhbpPDPazDfzqogYWEOdzi7SHmcpuRXbscfdE0KxFdpCvlTysrWtAxkqwxrgKJHmShEQ2jeIpYTLj84vkxCM3zdpv7ecXh52IJJKL6e8ShEsOYjuPWdoIcbRRidYXlUQLwmPObK5aePOsJd0IRAPftkYM4930eEscA1WZEOdzi78bzeEOwJdKekg8OjV(gE4QwAnd6o4PANqi(i3wMWJxPCXzEN9L0)b5ZUxI(sAJ)GV4JGNQDcH4JCBXXrYsDcE2dpjbTA4zp0HmKntdzeE0KxFdpybv(STSFK0gPvdpuRXbscfd6qh6WJicHRVHmKDEzNxE5)EwcpSvuxTbgEyI4IEKtYbWYbOjV(EaHc741SfEWrucYq2SmdGNi0BwbcEY4aocQ8zpawave2NTzCaziEdESpGSZGRdi78YoVz7SnJdGjodJs8ojhqmz(iAaPNlw9betgvJxdidLsuKJhq)nROGI4m5ddqtE9nEaFh2TMTAYRVXRieLEUy1Vndko3zRM86B8kcrPNlw9SUf38F5SvtE9nEfHO0ZfREw3IR8gCu7QxFpBZ4aoTgHfEFaiTKdiM30KKda7QJhqmz(iAaPNlw9betgvJhG2YbeHiwXO39QngqHhG8BAnB1KxFJxrik9CXQN1T44wJWcVBXU64zRM86B8kcrPNlw9SUfp6967zRM86B8kcrPNlw9SUfhlOYNT5J4UwM35iM30CHfu5Z28rCl(OzRM86B8kcrPNlw9SUfNht2YjURTYr3kRglOifBn)2TVPn6ztOzRM86B8kcrPNlw9SUfxKIknoqxBLJU5QwAXKISjE)nnV(r3yYVksd809(Sq8nz(idAroHAnytAiy936cKv0xYfXeWxrrKC2QjV(gVIqu65IvpRBX5QwAJdk2NTZ2moaM4mmkX7KCaKicTBaEXrdWfObOj)rdOWdqfPvqJd0A2QjV(gFJRa1jA2QjV(gN1T4rVxFFTmVJ5nnxXH)LbESVqKM8nBCfzq(YloY6VvweRVZG82SXvKb5lbsdUWkk5SoFSC2QjV(gN1T4IuuPXb6ARC0T8DSLp66hDJj)QinWt3Y3xybv(STSFK0gPvV8kLB1gxKVVePCrfQsw)5tclVs5wTXSvtE9noRBXfPOsJd01w5OBneSY3Xw(ORF0nM8RI0apDlFFHfu5Z2Y(rsBKw9YRuUvBCr((sKYfvOkz9NpjS8kLB1gxKVVKKONhvTHnkOg80YRuUvBmB1KxFJZ6wCrkQ04aDTvo6gtkQAdBxgcoNIiBI3FtZRF0nM8RI0apDJJOqW6kYGC8IRAPftkkZSNTAYRVXzDloIVTAYRVTHc7xBLJU50QNTZwn5134vsIVtAiy1KxFBdf2V2khDtym1jcpBZ4aykYu5d(am1qiwt5oaZhnaESghObuoXHzvdiNW0a(EaP)dYNDVMTAYRVXRKeN1T48yYwoXHNTZwn5134fHXuNi8nhX9OD230g4tL0krKYHNTAYRVXlcJPor4SUfpo8V0(MwxGSutC7MTAYRVXlcJPor4SUf3GxrYsB7BAvwnHExy2QjV(gVimM6eHZ6wCZpXJjPvz1eQCYgtk31Y8ghrHG1vKb54fx1slMuuM3zVzdslPLerTVuPeVQotwmVzRM86B8IWyQteoRBXJ4rL5UQnSXbf7xlZBCefcwxrgKJxCvlTysrzEN9MniTKwse1(sLs8Q6mzX8MTAYRVXlcJPor4SUfp9DIAhPojTMbLJUgQMSj5nlETmV9IJy99(82SXKpeSikjOidY6fhXAJKCZgxrgKV8IJS(BLfXAwoB1KxFJxegtDIWzDloQIIcKTAlost0SvtE9nErym1jcN1T4isJQ2WAguocpB1KxFJxegtDIWzDlo7hfKIOQTic)T2jA2QjV(gVimM6eHZ6wCxGS8D8Z3sR5Js0SD2MXbC21PbWhnaM0xsZhXnaTLdGfE2eAamrTjpU(EaSY)dYNDJhG2Yb8MdGhxTXayfENjnGO)ddOAS2LVBaXK5JObKuSxTXA2QjV(gV40QVf9L0si(iV((AzEZ8ajIcSMLzWMnP)dYNDVIE2eYwTjpU(EXhXSlvJ1U8DzEZ05DH55W1a1(kqgAAN9nTUazf9LCrTghi5Mnm31a1(kqgAAN9nTUazf9LCrTghi5f57ljj65rvByJcQbpT8kLB1gmJzZwn5134fNwDw3Il6lPn(d(1Y8UAS2LVBjjZkvEM37z5SvtE9nEXPvN1T4jneSAYRVTHc7xBLJUts8SnJdGfqKjHgG)dGhtdGPuUw967bKHoziwyaL5a0E3ayQNXbu4b0Vpa(OzRM86B8ItRoRBXLkxRE9910UuGSUImihFV)AzENdrkQ04aT0qWkFhB5JMTzCa5eMgatrIEEu1gdGfcQbpnauzi4diMmFenGDp)am(buT)dqhaRW7mPbWK(sA(iU1SvtE9nEXPvN1T4ss0ZJQ2WgfudE6AzE7AGAFfidnTZ(MwxGSI(sUOwJdK8s6)G8z3lrFjTeIpYRVx8rxQgRD57U3NxEZ2moaM678BFa8yAamfj65rvBmawiOg80akZbS75hqs7byq(aQ2)bWK(sA(iUbun2jvEDapAaL5aoKIQ2yamugcoNIObu4b4AGANKdqB5ayxHWaekFau)8gcdWvKb541SvtE9nEXPvN1T4ss0ZJQ2WgfudE6AAxkqwxrgKJV3FTmVzoImrewqJd0MnvJ1U8DzYKzjZUW8ajIcSMLzWMn5i9Fq(S7v0ZMq2Qn5X13l(iMDH55W1a1(ctkQAdBxgcoNIOf1ACGKB2WCxdu7lmPOQnSDzi4CkIwuRXbsEjhIuuPXbAHjfvTHTldbNtrKnX7VPjZy2fMNdxdu7RazOPD2306cKv0xYf1ACGKB2WCxdu7RazOPD2306cKv0xYf1ACGKxI5nnxI(sA(iUL8z3mJzZ2moGCctd4iOYN9aYppsYQgatrQlmGYCaUanaxrgKpGcpan(59b4)aKfTMTAYRVXloT6SUfhlOYNTL9JKwjPUW10UuGSUImihFV)AzE7kYG8LaPbxyfLCwNDEZ2moGCctd4WJqulj0a8FamHQSjmEaFpaDaUImiFaUG6dOWdW4R2ya(pazrdq9b4c0aqLHGpaV4O1SvtE9nEXPvN1T4yEeIAjHS(B5uzty810UuGSUImihFV)AzE7kYG8LxCK1FRSiwNnlVeZBAUe9L08rCl5ZUNTAYRVXloT6SUfNRAzm1scnBZ4aYjmnaM0xYbW4Jqu7d47WUbuMdqdHbWupJ4bOiAaAYlr0a0woaxGgGRidYha7VZV9bilAasEu1gdWfObKe0UPWA2QjV(gV40QZ6wCrFjT(Jqu7xt7sbY6kYGC89(RL5TifvACGwAiyLVJT8rxYr6)G8z3lrFjTeIpYRVx8rxCfzq(YloY6VvwuMm9SnJdiNW0ao5hwftnan(frdiF5LFzaz4zHbWwG6bWcA1XisZLqdGfWAGBarpBcnGcpan5LiA2QjV(gV40QZ6wCSGkF2w2psALK6cxlZBeFtMpYGwrA1XisZLq2iSg4wetaFffrYlIuuPXbAjFhB5JU4kYG8LaPbxyfL8mZxEZ2moGCctdqdHbKeuKbHhWBoGJGkF2dGvIuSWaQEa6aqp7b89aovBeOb4kYG8Rd4rdOmhGlqdi(X4bu4bOXpVpa)hGSO1SvtE9nEXPvN1T4ybv(STjKIfUwM34ikeSUImihVWcQ8zBtiflCV)cZt)hKp7EHfu5Z2MqkwyLeuKbHVZ3MnskM30CHfu5Z2MqkwWkPyEtZfF0MnAYRVxybv(STjKIfwvBndLHGVzJRidYxEXrw)TYIyD6)G8z3lSGkF22esXclt(qWIOKGImiRxCeZUG0sAjru7lvkXRQZmF5nBZ4aYjmnGJGkF2dGvIuSWa(EaSsMAa8DGW4b4ceIgGIObOsjEavNEUQnwZwn5134fNwDw3IJfu5Z2Mqkw4AzEJ0sAjru7lvkXRQZmF5DbhrHG1vKb54fwqLpBBcPyHm3pBZ4aYjmnaMWQLd4qkAa(pG03yEoAamLIYDamk88gcoEarOpHhW3didLZmXRbWyoZu58ayLFBwiUbu4b4cfEafEa6aekdbcnGiu9OY3naxq7bGi57E1gd47bKHYzM4bW3bcJhGur5oax45neC8ak8a04N3hG)dWloAapVpB1KxFJxCA1zDlox1slMu010UuGSUImihFV)AzEJJOqW6kYGC8IRAPftkktrkQ04aT4QwAXKISjE)nnVeZBAUKkkxRl88gcoEXhDnjOvFV)A1oHq8rUT44izPoDV)A1oHq8rUTmV9kLloZ7SNTzCa5eMgaty1YbKHlO7gG)di9nMNJgatPOChaJcpVHGJhqe6t4b89aomUgaJ5mtLZdGv(TzH4gqzoaxOWdOWdqhGqziqObeHQhv(Ub4cApaejF3R2ya8DGW4bivuUdWfEEdbhpGcpan(59b4)a8IJgWZ7Zwn5134fNwDw3IZvT0Ag0DxlZ7yEtZLur5ADHN3qWXl(OlIuuPXbAjFhB5JUMe0QV3FTANqi(i3wCCKSuNU3FTANqi(i3wM3ELYfN5D2xs)hKp7Ej6lPn(d(IpA2MXbKtyAahsrvBmagkdbNtr0akZbS75ha7kegGq5dq9beif7diFdWvKb54bOTCaSWZMqdGjQn5X13dqB5aysFjnFe3auenG(9bGivU76aE0a8FaiYeryHbCYpSkwyaFpaN9pGhnaUhrdWvKb541SvtE9nEXPvN1T4ysrvBy7YqW5ueDLhtw2cvGSjf7vBCV)AAxkqwxrgKJV3FTmVzUifvACGwysrvBy7YqW5uezt8(BAEH5bsefynlZGnBYr6)G8z3RONnHSvBYJRVx8rmJzB2WC57lSGkF2w2psAJ0QxiYerybnoqxWruiyDfzqoEXvT0IjfL5EMnBZ4aymNzQCEajbTnObeEJknGVhaBbQhG)dGhtdOASRTpG4GID8SvtE9nEXPvN1T4CvlTXbf7x5XKLTqfiBsXE1g37VwM3IuuPXbAjFhB5JMTzCamMZmvopaMeHkZDdWvKb5diPrZwn5134fNwDw3IZvT0ghuSFTmVfPOsJd0s(o2YhDbPL0sIO2xCViIJAFvDMjf7wV4OSYBXYl4ikeSUImihV4QwAXKIyntpBZ4aoruQ0WasFllV(Ea(paS)rdiPyVAJbCYpSkwyaFpG30Kv0vKb54bWwG6bywgcE1gdiFd4rdG7r0aWUMYLKdG7JXdqB5a4XvBmawaVljuPbWkuDUdqB5ayiNzCamHfMq7wZwn5134fNwDw3IJfu5Z2Y(rsBKw91Y8grMiclOXb6IRidYxEXrw)TYIYKPVKdxdu7lUctODlQ14ajV4AGAFfH3LeQKnuDUlQ14ajVGJOqW6kYGC8IRAPftkkZSNTzCa5xjkAaN8dRIfgaF0a(EakEaCAVBaUImihpafpGOhJR4aDDaugwII8bWwG6bywgcE1gdiFd4rdG7r0aWUMYLKdG7JXdGD5cdGfW7scvAaScvN7A2QjV(gV40QZ6wCSGkF2w2psAJ0QVM2LcK1vKb5479xlZBezIiSGghOlUImiF5fhz93klktM(soCnqTV4kmH2TOwJdK8cZZHRbQ9veExsOs2q15UOwJdKCZgM7AGAFfH3LeQKnuDUlQ14ajVGJOqW6kYGC8IRAPftkI13zZmMnB1KxFJxCA1zDlUiLlQqvY6pFs4AAxkqwxrgKJV3FTmVrKjIWcACGU4kYG8LxCK1FRSOmzXnByURbQ9fxHj0Uf1ACGKxKVVWcQ8zBz)iPnsREHiteHf04aXSnBI5nnx8TjpkuTHvQOCBcJx8rZwn5134fNwDw3IZvT0IjfDnTlfiRRidYX37VwM34ikeSUImihV4QwAXKIYuKIknoqlUQLwmPiBI3FtZRjbT679xR2jeIpYTfhhjl1P79xR2jeIpYTL5TxPCXzEN9SvtE9nEXPvN1T4CvlTMbD31KGw99(Rv7ecXh52IJJKL609(Rv7ecXh52Y82RuU4mVZ(s6)G8z3lrFjTXFWx8rZwn5134fNwDw3IJfu5Z2Y(rsBKwn0Hoec]] )


end
