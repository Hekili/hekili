-- PriestShadow.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID


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

    local swp_applied = 0

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID then
            if subtype == "SPELL_AURA_REMOVED" then
                if spellID == 288343 then
                    thought_harvester_consumed = GetTime()
                elseif spellID == 341207 then
                    Hekili:ForceUpdate( subtype, true )
                end

            elseif subtype == "SPELL_AURA_APPLIED" then
                if spellID == 341273 then
                    unfurling_darkness_triggered = GetTime()
                elseif spellID == 341207 then
                    Hekili:ForceUpdate( subtype, true )
                end
            end

            --[[ if spellName == "Shadow Word: Pain" and ( subtype == "SPELL_DAMAGE" or subtype == "SPELL_PERIODIC_DAMAGE" ) then
                local name, id, _, aType, duration, expiration = FindUnitDebuffByID( "target", class.auras.shadow_word_pain.id )
                -- print( name, id, _, aType, duration, applied )
                if expiration then print( "SWP", subtype, duration, ( GetTime() - ( expiration - duration ) ) / class.auras.shadow_word_pain.tick_time, ( expiration - GetTime() ) / class.auras.shadow_word_pain.tick_time ) end
            end

            if spellName == "Shadow Word: Pain" and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" ) then
                swp_applied = GetTime()
            end ]]
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
            summonPet( "fiend", buff.mindbender.remains )
        elseif pet.shadowfiend.active then
            applyBuff( "shadowfiend", pet.shadowfiend.remains )
            buff.shadowfiend.applied = action.shadowfiend.lastCast
            buff.shadowfiend.duration = 15
            buff.shadowfiend.expires = action.shadowfiend.lastCast + 15
            summonPet( "fiend", buff.shadowfiend.remains )
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


    --[[ spec:RegisterHook( 'runHandler', function( action )
        -- Make sure only the correct debuff is applied for channels to help resource forecasting.
        if action == "mind_sear" then
            removeDebuff( "target", "mind_flay" )
        elseif action == "mind_flay" then
            removeDebuff( "target", "mind_sear" )
            removeBuff( "mind_sear_th" )
        else
            local ability = class.abilities[ action ]

            if not ability or not ability.castableWhileCasting then
                removeDebuff( "target", "mind_flay" )
                removeDebuff( "target", "mind_sear" )
                removeBuff( "mind_sear_th" )
            end
        end
    end ) ]]


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
            bind = "ascended_blast",

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
                summonPet( "fiend", 15 )
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

                removeBuff( "anunds_last_breath" )
            end,
        },


        void_eruption = {
            id = 228260,
            cast = function ()
                if pvptalent.void_origins.enabled then return 0 end
                return haste * 1.5 
            end,
            cooldown = 90,
            gcd = "spell",

            startsCombat = true,
            texture = 1386548,

            nobuff = function () return buff.dissonant_echoes.up and "dissonant_echoes" or "voidform" end,
            bind = "void_bolt",

            toggle = "cooldowns",

            cooldown_ready = function ()
                return cooldown.void_eruption.remains == 0 and buff.voidform.down
            end,

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
            known = 325013,
            cast = 0,
            cooldown = 0,
            gcd = "spell", -- actually 1s and not 1.5s...

            startsCombat = true,
            texture = 3528287,

            buff = "boon_of_the_ascended",
            bind = "boon_of_the_ascended",

            handler = function ()
                addStack( "boon_of_the_ascended", nil, active_enemies )
            end
        },

        ascended_blast = {
            id = 325283,
            known = 15407,
            cast = 0,
            cooldown = 3,
            hasteCD = true,
            gcd = "spell", -- actually 1s and not 1.5s...

            startsCombat = true,
            texture = 3528286,

            buff = "boon_of_the_ascended",
            bind = "mind_flay",

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


    spec:RegisterPack( "Shadow", 20200926, [[d0uI(aqiOu9irP6seHiTjvHpjQqnkvPCkvP6vIIMfu0TuLKAxk8lrHHPkXXGswgr0ZGsPPrufxturBdkfFtvs14evW5ic06icyEev19uvTprjhKOk1cjQ8qrPutKiuxKOkPnsuLOpseIQtsecRuu1ljcrzMIsrUPOczNQk9tvjXqjcAPeHiEQIMQQIRQkPSvIq6RIsH9c5VuzWahM0IPWJfzYeUmQndvFMIgnL60swnrvcVwuPztv3gP2Tu)wLHtjhxvsYYb9Cetx46iz7eLVtKgVOuuNhkSErPK5RkA)kncl0h0uObJ(k5ls(YlsqjXMbwsk5RJTsIMbgwmAAPPCvtgnBLMrZPTkoPOPLIH)ub6dAsokyIrt7iSisGmYWScBkJr6OZGu0uEnQRtqfpYGu0PmqtdQYhsenYanfAWOVs(IKV8IeusSzGLKs(6sInOPsf2henNfD2gnTlHGBKbAkyscnZ(cM2Q4KUajewmj28zFbt2kyAdgUajXgmxGKVi5lOPVibb9bnzcH7etqFqFXc9bn1uuxJM0m9bXWD4opvQeobKvAcAYTA4zbsouG(kj6dAQPOUgnn83jChUlSzh3mngOj3QHNfi5qb6l2I(GMAkQRrttkfkkTDhUtZwm8cB0KB1WZcKCOa9vEqFqtUvdplqYHMjyfmSu0KyXEVluOjhKbD1chHv4cY6FbsUGNpxaulHJLXDmuHGmQEbzTaS5f0utrDnAIFjkclCA2IHvWodwPrb6BorFqtUvdplqYHMjyfmSu0KyXEVluOjhKbD1chHv4cY6FbsUGNpxaulHJLXDmuHGmQEbzTaS5f0utrDnAArblCmQ20z4vsGc0xSb9bn5wn8SajhAQPOUgntxN4oGAWchUxPz0mbRGHLIMrrZlq()laRxwWZNlaNY7DqozRqt2ffnVa5VaZKybpFUGqHMCmIIMDX5efVa5VGCIM(QzxsGMydkqFFD0h0utrDnAclllp7Q2rS0eJMCRgEwGKdfOV5a6dAQPOUgnHSAvTPd3R0mbn5wn8SajhkqFLGOpOPMI6A0u6b9czC1oitUw7eJMCRgEwGKdfOVy9c6dAQPOUgndB2r1ghvlC4hmXOj3QHNfi5qbkqtbJRu(a9b9fl0h0utrDnAskp3jgn5wn8SajhkqFLe9bn5wn8SajhAMGvWWsrtdkC8HH)oHNIediRPybpFUGqHMCmIIMDX5efVa5)VGC4Lf885ccfAYXWMvFypSsXcK)cW2CIMAkQRrtRlQRrb6l2I(GMCRgEwGKdnpl0KWbAQPOUgnLPWsn8mAkt9umAkUyqSvXj1j9GcNLw9iQuUvBUGhlqCXqMsBvWk5IJkzpIkLB1MOPmf6ALMrtXfehLfkqFLh0h0KB1WZcKCO5zHMeoqtnf11OPmfwQHNrtzQNIrtXfdITkoPoPhu4S0QhrLYTAZf8ybIlgYuARcwjxCuj7ruPCR2CbpwG4IHGLDuWQnDwE1KIhrLYTAt0uMcDTsZOP69oXfehLfkqFZj6dAYTA4zbso08SqtchOPMI6A0uMcl1WZOPm1tXOjXI9ExOqtoid6QfocRWfK1cKenLPqxR0mAsyfwTPRlt7GwHSlrfhookqFXg0h0KB1WZcKCOzcwbdlfnnOWXhYUsGFq6bLfAQPOUgnXliB4VtGc03xh9bn1uuxJMgmKWWCR2en5wn8SajhkqFZb0h0utrDnA6lt7G4KxqjmP5oqtUvdplqYHc0xji6dAYTA4zbso0mbRGHLIMgu44dzxjWpi9GYcn1uuxJMANysavVlPEpkqFX6f0h0utrDnAAOMUd3fWkLlbn5wn8SajhkqFXcl0h0KB1WZcKCOPMI6A0es1onf11oFrc00xKW1knJM0A1OafOPfKthTHgOpOVyH(GMCRgEwGKdfOVsI(GMCRgEwGKdfOVyl6dAYTA4zbsouG(kpOpOj3QHNfi5qb6BorFqtnf11OP1f11Oj3QHNfi5qb6l2G(GMCRgEwGKdntWkyyPOj2xGbfo(GyRItk(bPhuwOPMI6A0KyRItk(bPrb67RJ(GMCRgEwGKdnBLMrtnBrSvOsC4xhUd3zDsziAQPOUgn1SfXwHkXHFD4oCN1jLHOa9nhqFqtUvdplqYHMNfAs4an1uuxJMYuyPgEgnLPEkgnXcnLPqxR0mAsxTWryf6suXHJJc0xji6dAQPOUgnPRw4m8kjqtUvdplqYHcuGMjbb9b9fl0h0KB1WZcKCOzcwbdlfnnOWXhYUsGFq6bLfAQPOUgnToPm0vnofPUgfOVsI(GMAkQRrtCLDMukuuAtqtUvdplqYHc0xSf9bn5wn8SajhAMGvWWsrZQjAxbglq(lqc(YcESaSVadkC8HSRe4hKEqzHMAkQRrt6QfMkntqb6R8G(GMCRgEwGKdntWkyyPOjulHJLXDmuHGmQEbzTGC(cAQPOUgnPA7ZJHRpzkkqFZj6dAYTA4zbso0mbRGHLIMyFbgu44dzxjWpi9GYAbpwa2xq6oV4K2dzxjCmKYkQRhuwl4XciwS37cfAYbzqxTWryfUGSwawl4XcW(cc1ZDmiScR201LPDqRqEWTA4zXcE(CbVTadkC8HSRe4hKEqzTGhlGyXEVluOjhKbD1chHv4cK)cKCbpwa2xqOEUJbHvy1MUUmTdAfYdUvdplwW7l45Zf82cmOWXhYUsGFq6bL1cESGq9ChdcRWQnDDzAh0kKhCRgEwSG3rtnf11OPXDT7WDHn7usIBblqb6l2G(GMCRgEwGKdn1uuxJMj17DAkQRD(IeOPViHRvAgnzcH7etqb67RJ(GMAkQRrtkc7QGPjOj3QHNfi5qbkqtJ7A0h0xSqFqtUvdplqYHMjyfmSu0KyXEVluOjhKbD1chHv4cK))cWw0utrDnAQKe3cw4m8kjqb6RKOpOj3QHNfi5qZeScgwkA(2ciwS37cfAYbzqxTWryfUGSwGKl4Xcc1ZDmiScR201LPDqRqEWTA4zXcE(CbVTaIf79UqHMCqg0vlCewHliRfG1cESaSVGq9ChdcRWQnDDzAh0kKhCRgEwSG3xW7l4XciwS37cfAYbzOKe3cw46tMUGSwawOPMI6A0ujjUfSW1NmffOanP1QrFqFXc9bn5wn8SajhAMGvWWsrtdkC8HXDT7WDHn7usIBblguwOPMI6A0mPEVttrDTZxKan9fjCTsZOPXDnkqFLe9bn5wn8SajhAMGvWWsrZ3wGNLX(fi)fKZCybpFUG0DEXjThwNug6QgNIuxpOSwW7l4XcQMODfySGS(xG88YcESG3wa2xqOEUJHNn1egUd3f2St2vIb3QHNfl45Zf82cc1ZDm8SPMWWD4UWMDYUsm4wn8SybpwG4IHGLDuWQnDwE1KIhrLYTAZf8(cEhn1uuxJMYUs4yiLvuxJc0xSf9bn5wn8SajhAMGvWWsrtdkC8bUYotkfkkTjdkRf8ybyFbc2GchFifQHnoL3HRmS4bLfAQPOUgnj2Q4K6KEqHZsRgfOVYd6dAYTA4zbso0mbRGHLIMyFbIlgcw2rbR20z5vtkEazCitSvdpJMAkQRrtzxjCgNpqb6BorFqtUvdplqYHMAkQRrZK69onf11oFrc00xKW1knJMjbbfOVyd6dAYTA4zbso0utrDnAku6wJ6A0mbRGHLIMyFbYuyPgEEOEVtCbXrzHMjmsE2fk0Kdc6lwOa991rFqtUvdplqYHMjyfmSu0mup3XWZMAcd3H7cB2j7kXGB1WZIf8ybP78ItApKDLWXqkROUEqzTGhlOAI2vGXc(xawV8cAQPOUgnfSSJcwTPZYRMumkqFZb0h0KB1WZcKCOPMI6A0uWYoky1MolVAsXOzcwbdlfnFBbqghYeB1WZl45Zfunr7kWybzTGxpNl49f8ybVTaplJ9lq(liN5WcE(CbyFbP78ItApSoPm0vnofPUEqzTG3xWJf82cW(cc1ZDmiScR201LPDqRqEWTA4zXcE(CbVTGq9ChdcRWQnDDzAh0kKhCRgEwSGhla7lqMcl1WZdcRWQnDDzAh0kKDjQ4WXxW7l49f8ybVTaSVGq9ChdpBQjmChUlSzNSRedUvdplwWZNl4TfeQN7y4ztnHH7WDHn7KDLyWTA4zXcESadkC8HSRe4hKEioP9cEFbVJMjmsE2fk0Kdc6lwOa9vcI(GMCRgEwGKdn1uuxJMeBvCsDspOWjynSrZeScgwkAgk0KJHnR(WEyLIfi)fi5ll45Zf82cS4yGxClgAkkz8cESaivZ4h0KheBvCsX9kn7SGfHEWVkQYYIfl4D0mHrYZUqHMCqqFXcfOVy9c6dAYTA4zbso0utrDnAsOGqUfm0fNJwfntiOzcwbdlfndfAYXikA2fNtu8cK)cKmNl4XcmOWXhYUsGFq6H4K2OzcJKNDHcn5GG(IfkqFXcl0h0utrDnAsxTWGBbdrtUvdplqYHc0xSKe9bn5wn8SajhAQPOUgnLDLWfheYDGMjyfmSu0uMcl1WZd17DIliokRf8ybyFbgu44dzxjWpi9GYAbpwqOqtogrrZU4CIIxqwlqEqZegjp7cfAYbb9fluG(If2I(GMCRgEwGKdntWkyyPOjKQz8dAYdlTAdiR5YqNfr90d(vrvwwSybpwGmfwQHNhIliokRf8ybHcn5yefn7IZzLcNKVSGSwWBliDNxCs7bXwfNuN0dkCcwd7HGcQrD9cYCbMjXcEhn1uuxJMeBvCsDspOWjynSrb6lwYd6dAYTA4zbso0mbRGHLIMel27DHcn5Gmi2Q4K6sqLyVG)fG1cESG3wq6oV4K2dITkoPUeuj2JKTcnzYc(xa2UGNpxGGnOWXheBvCsDjOsSDc2GchFqzTGNpxGMI66bXwfNuxcQe7r1oCFzAhl45Zfek0KJru0SloNO4fi)fKUZloP9GyRItQlbvI9aNY7DqozRqt2ffnVG3xWJfa1s4yzChdviiJQxqwlaBFbn1uuxJMeBvCsDjOsSrb6lw5e9bn5wn8SajhAMGvWWsrtOwchlJ7yOcbzu9cYAby7ll4XciwS37cfAYbzqSvXj1LGkXEbzTaSqtnf11OjXwfNuxcQeBuG(If2G(GMCRgEwGKdn1uuxJM0vlCewHOzcJKNDHcn5GG(IfAwDWqiLv4kC0mQuUKS(LenRoyiKYkCfnnlkny0el0mbRGHLIMel27DHcn5GmORw4iScxqwlqMcl1WZd6QfocRqxIkoC8f8ybgu44dHcZ1f2hLPDqguwOzYwRgnXcfOVy96OpOj3QHNfi5qtnf11OjD1chUxXanRoyiKYkCfoAgvkxsw)s(iDNxCs7HSReoJZhdkl0S6GHqkRWv00SO0GrtSqZeScgwkAAqHJpekmxxyFuM2bzqzTGhlqMcl1WZdXfehLfAMS1QrtSqb6lw5a6dAYTA4zbso0KIWoP2LNDjLevBI(IfAQPOUgnjScR201LPDqRqgntyK8SluOjhe0xSqZeScgwkA(2cKPWsn88GWkSAtxxM2bTczxIkoC8f8ybVTaplJ9lq(liN5WcE(CbyFbP78ItApSoPm0vnofPUEqzTG3xW7l45Zf82cexmi2Q4K6KEqHZsREazCitSvdpVGhlGyXEVluOjhKbD1chHv4cYAbyTG3rb6lwsq0h0KB1WZcKCOjfHDsTlp7skjQ2e9fl0utrDnAsxTWz4vsGMjyfmSu0uMcl1WZdXfehLfkqFL8f0h0KB1WZcKCOzcwbdlfnLPWsn88qCbXrzTGhlaQLWXY4og0NmMM7yu9cYAbjLeUOO5fK5cEzKZf8ybel27DHcn5GmORw4iScxG8xG8GMAkQRrt6QfodVscuG(kjwOpOj3QHNfi5qtnf11OPmL2QGvYfhvYgntWkyyPOjKXHmXwn88cESGqHMCmIIMDX5efVGSwa2SGNpxWBliup3XGUimeJb3QHNfl4Xcexmi2Q4K6KEqHZsREazCitSvdpVG3xWZNlWGchFq14uqF1MoHcZTzczqzHMjmsE2fk0Kdc6lwOa9vsjrFqtUvdplqYHMjyfmSu0eY4qMyRgEEbpwqOqtogrrZU4CIIxqwlqEwWJfG9feQN7yqxegIXGB1WZIf8ybH65ogwems2vY5Ro3b3QHNfl4XciwS37cfAYbzqxTWryfUGSwGKOPMI6A0KyRItQt6bfolTAuG(kj2I(GMCRgEwGKdn1uuxJMeBvCsDspOWzPvJMjyfmSu0eY4qMyRgEEbpwqOqtogrrZU4CIIxqwlqEwWJfG9feQN7yqxegIXGB1WZIf8ybVTaSVGq9Chdlcgj7k58vN7GB1WZIf885cEBbH65ogwems2vY5Ro3b3QHNfl4XciwS37cfAYbzqxTWryfUa5)VajxW7l4D0mHrYZUqHMCqqFXcfOVskpOpOj3QHNfi5qtnf11OjD1chHviAMWi5zxOqtoiOVyHMvhmeszfUchnJkLljRFjrZQdgcPScxrtZIsdgnXcntWkyyPOjXI9ExOqtoid6QfocRWfK1cKPWsn88GUAHJWk0LOIdhhnt2A1OjwOa9vYCI(GMCRgEwGKdn1uuxJM0vlC4Efd0S6GHqkRWv4OzuPCjz9l5J0DEXjThYUs4moFmOSqZQdgcPScxrtZIsdgnXcnt2A1OjwOa9vsSb9bn1uuxJMeBvCsDspOWzPvJMCRgEwGKdfOafOPmgsQRrFL8fjF5fjOKsIMsvyxTjbnZgYBjs(kr8vICjWcwWhBEbfT1bJfGFWfKJP1QZXlaYVkQcYIfqoAEbkvC0AWIfKS12KjJn)hBEb4N3FsR2Cbkfujlqkd5fqryXcQEbHnVanf11lWxKybguXcKYqEb9fla)OAXcQEbHnVaviUEbcnudLWsGn)cE1laxzNjLcfL2Kn)cE1lqkudBCkVdxzyXB(nVebT1bdwSaSzbAkQRxGVibzS5rtl4HxEgnZ(cM2Q4KUajewmj28zFbt2kyAdgUajXgmxGKVi5lB(nF2xG8A2mNOcwSadg)G8cshTHglWGnRMmwG8oLyRGSG(6xTTcPXP8lqtrDnzbx7XyS51uuxtgwqoD0gA8J7vsUBEnf11KHfKthTHgz(Nb(DInVMI6AYWcYPJ2qJm)ZqPmP5o0OUEZN9fmB1IyFXcGAjwGbfoolwaj0GSadg)G8cshTHglWGnRMSaTflWcYVARlIQnxqrwG4AES51uuxtgwqoD0gAK5FgKwTi2x4iHgKnVMI6AYWcYPJ2qJm)ZW6I66nVMI6AYWcYPJ2qJm)ZGyRItk(bPXSW)XUbfo(GyRItk(bPhuwBEnf11KHfKthTHgz(NbfHDvW0y2kn)RzlITcvId)6WD4oRtkd38AkQRjdliNoAdnY8pdzkSudpJzR08pD1chHvOlrfhooMN1pHdmLPEk(hRnVMI6AYWcYPJ2qJm)ZGUAHZWRKyZV5Z(cKxZM5evWIfWYyiglikAEbHnVanfhCbfzbQmT8QHNhBEnf11KFs55oXBEnf11Km)ZW6I6Aml8FdkC8HH)oHNIediRP45ZqHMCmIIMDX5efl))C4LNpdfAYXWMvFypSsH8X2CU51uuxtY8pdzkSudpJzR08V4cIJYcZZ6NWbMYupf)lUyqSvXj1j9GcNLw9iQuUvB(qCXqMsBvWk5IJkzpIkLB1MBEnf11Km)ZqMcl1WZy2kn)REVtCbXrzH5z9t4atzQNI)fxmi2Q4K6KEqHZsREevk3QnFiUyitPTkyLCXrLShrLYTAZhIlgcw2rbR20z5vtkEevk3Qn38AkQRjz(NHmfwQHNXSvA(NWkSAtxxM2bTczxIkoCCmpRFchykt9u8pXI9ExOqtoid6QfocRWSKCZRPOUMK5Fg4fKn83jWSW)nOWXhYUsGFq6bL1MxtrDnjZ)mmyiHH5wT5MxtrDnjZ)m8LPDqCYlOeM0ChBEnf11Km)Zq7etcO6Dj17XSW)nOWXhYUsGFq6bL1MxtrDnjZ)mmut3H7cyLYLS51uuxtY8pdiv70uux78fjWSvA(NwREZV51uuxtgjb536KYqx14uK6Aml8FdkC8HSRe4hKEqzT51uuxtgjbjZ)mWv2zsPqrPnzZRPOUMmscsM)zqxTWuPzcMf(F1eTRad5lbF5b2nOWXhYUsGFq6bL1MxtrDnzKeKm)ZGQTppgU(KPyw4)qTeowg3XqfcYO6SY5lBEnf11KrsqY8pdJ7A3H7cB2PKe3cwGzH)JDdkC8HSRe4hKEqz9a7P78ItApKDLWXqkROUEqz9GyXEVluOjhKbD1chHvywy9a7H65ogewHvB66Y0oOvip4wn8S45Z3mOWXhYUsGFq6bL1dIf79UqHMCqg0vlCewHYxYhypup3XGWkSAtxxM2bTc5b3QHNfV)85Bgu44dzxjWpi9GY6rOEUJbHvy1MUUmTdAfYdUvdplEFZRPOUMmscsM)zKuV3PPOU25lsGzR08ptiCNyYMp7lqIzCLYhlax9EdnL7cWp4cOiQHNxqfmnrcSGxJWl46fKUZloP9yZRPOUMmscsM)zqryxfmnzZV51uuxtgg31)kjXTGfodVscml8FIf79UqHMCqg0vlCewHY)hB38AkQRjdJ76m)ZqjjUfSW1NmfZc))nIf79UqHMCqg0vlCewHzj5Jq9ChdcRWQnDDzAh0kKhCRgEw885Bel27DHcn5GmORw4iScZcRhypup3XGWkSAtxxM2bTc5b3QHNfV)(dIf79UqHMCqgkjXTGfU(KPzH1MFZRPOUMmycH7et(Pz6dIH7WDEQujCciR0KnVMI6AYGjeUtmjZ)mm83jChUlSzh3mngBEnf11KbtiCNysM)zysPqrPT7WDA2IHxyV51uuxtgmHWDIjz(Nb(LOiSWPzlgwb7myLgZc)NyXEVluOjhKbD1chHvyw)s(8julHJLXDmuHGmQolS5LnVMI6AYGjeUtmjZ)mSOGfogvB6m8kjWSW)jwS37cfAYbzqxTWryfM1VKpFc1s4yzChdviiJQZcBEzZRPOUMmycH7etY8pJ01jUdOgSWH7vAgtF1Slj(Xgml8)OOz5)J1lpFIt59oiNSvOj7IIMLVzs88zOqtogrrZU4CIILFo38AkQRjdMq4oXKm)ZawwwE2vTJyPjEZRPOUMmycH7etY8pdiRwvB6W9knt28AkQRjdMq4oXKm)Zq6b9czC1oitUw7eV51uuxtgmHWDIjz(NryZoQ24OAHd)GjEZV51uuxtg0A1)j17DAkQRD(Iey2kn)BCxJzH)BqHJpmURDhUlSzNssClyXGYAZN9fmXOtlGYAbs0Re4hKEbAlwGeEsz4cKiACksD9cY235fN0MSaTfl4WxafPAZfKnDHeDbw35xq1eTRaJfyW4hKxqsjr1MJnVMI6AYGwR(x2vchdPSI6Aml8)38Sm2l)CMdpFMUZloP9W6KYqx14uK66bL17pQMODfyK1V88YJ3WEOEUJHNn1egUd3f2St2vIb3QHNfpF(wOEUJHNn1egUd3f2St2vIb3QHNfpexmeSSJcwTPZYRMu8iQuUvB((7B(SVGCKMlVacfKxagh1cSOIfqzTGz2qciHlqEpL3s4cUEbHnVGqHMCSGcFbzdOg24u(fiVuzyXlOiDoowGMIsgp28AkQRjdAT6m)ZGyRItQt6bfolTAml8FdkC8bUYotkfkkTjdkRhyxWgu44dPqnSXP8oCLHfpOS28zFbVs7XybueEbs0RelqUZhlOWxGeZYoky1Mlqc9QjfVaXXKohhlOzwSaiJdzInlgBEnf11KbTwDM)zi7kHZ48bMf(p2fxmeSSJcwTPZYRMu8aY4qMyRgEEZRPOUMmO1QZ8pJK69onf11oFrcmBLM)tcYMp7lqcHmodxqClGIWlqIv6wJ66fiVNYBjCbf(c0gJfiX3NfuKf0xSakRXMxtrDnzqRvN5FgcLU1OUgZegjp7cfAYb5hlml8FSltHLA45H69oXfehL1Mp7l41i8cKyw2rbR2CbsOxnP4falt7ybgm(b5fGXrTaZBbvh3c0fKnDHeDbs0Re4hKES51uuxtg0A1z(NHGLDuWQnDwE1KIXSW)d1ZDm8SPMWWD4UWMDYUsm4wn8S4r6oV4K2dzxjCmKYkQRhuwpQMODfy8J1lVS5Z(cK4RZXXcOi8cKyw2rbR2CbsOxnP4fu4laJJAbjTxGjhlO64wGe9kb(bPxq1KGvbMl4GlOWxWKvy1Ml4BzAh0kKxqrwqOEUdwSaTflqA59lWUIfW9rzAVGqHMCqgBEnf11KbTwDM)ziyzhfSAtNLxnPymtyK8SluOjhKFSWSW)FdY4qMyRgE(5ZQjAxbgz96589hV5zzSx(5mhE(e7P78ItApSoPm0vnofPUEqz9(J3WEOEUJbHvy1MUUmTdAfYdUvdplE(8Tq9ChdcRWQnDDzAh0kKhCRgEw8a7YuyPgEEqyfwTPRlt7GwHSlrfho(7V)4nShQN7y4ztnHH7WDHn7KDLyWTA4zXZNVfQN7y4ztnHH7WDHn7KDLyWTA4zXddkC8HSRe4hKEioP97VV5Z(cEncVGPTkoPliBCqHeybsmRH9ck8fe28ccfAYXckYcuJJkwqClqu8co4cW4OwGTkJxW0wfNuCVsZlqcHfHEb8RIQSSyXcKwH9cYrvlm4wWWfCWfmTvXjfV4wSanfLmES51uuxtg0A1z(NbXwfNuN0dkCcwdBmtyK8SluOjhKFSWSW)dfAYXWMvFypSsH8L8LNpFZIJbEXTyOPOKXpGunJFqtEqSvXjf3R0SZcwe6b)QOkllw8(Mp7l41i8cMuqi3cgUG4wqosfntil46fOliuOjhliS1ybfzbMx1MliUfikEbASGWMxaSmTJfefnp28AkQRjdAT6m)ZGqbHClyOlohTkAMqWmHrYZUqHMCq(XcZc)puOjhJOOzxCorXYxYC(WGchFi7kb(bPhItAV51uuxtg0A1z(NbD1cdUfmCZN9f8AeEbs0Rel4ZbHChl4ApglOWxG69lqIVpKfOqEbAkkz8c0wSGWMxqOqtowG0RZXXcefVabfSAZfe28cs2A3SFS51uuxtg0A1z(NHSReU4GqUdmtyK8SluOjhKFSWSW)LPWsn88q9EN4cIJY6b2nOWXhYUsGFq6bL1JqHMCmIIMDX5efNL8S5Z(cEncVGz2qciXlqAf2lqc1QnGSMldxGesup9cOAptiliS5fek0KJfiT8(fyWlWG9N0fi5lsKUadg)G8ccBEbP78ItAVG0rZKfyOPC38AkQRjdAT6m)ZGyRItQt6bfobRHnMf(pKQz8dAYdlTAdiR5YqNfr90d(vrvwwS4HmfwQHNhIliokRhHcn5yefn7IZzLcNKVK1BP78ItApi2Q4K6KEqHtWAypeuqnQRZ0mjEFZN9f8AeEbQ3VGKTcnzYco8fmTvXjDbzBOsSxq1lqxa8KUGRxWSAtpVGqHMCG5co4ck8fe28cmoczbfzbQXrfliUfikES51uuxtg0A1z(NbXwfNuxcQeBml8FIf79UqHMCqgeBvCsDjOsS)X6XBP78ItApi2Q4K6sqLyps2k0Kj)y7ZNc2GchFqSvXj1LGkX2jydkC8bL1ZNAkQRheBvCsDjOsShv7W9LPD88zOqtogrrZU4CIILF6oV4K2dITkoPUeuj2dCkV3b5KTcnzxu087pGAjCSmUJHkeKr1zHTVS5Z(cEncVGPTkoPliBdvI9cUEbzBjEbuTNjKfe2mKxGc5fOcbzbvNo6QnhBEnf11KbTwDM)zqSvXj1LGkXgZc)hQLWXY4ogQqqgvNf2(YdIf79UqHMCqgeBvCsDjOsSZcRnF2xWRr4fKJQwSGjRWfe3csxtOO5fiXkm3f8X(OmTdYcSGxISGRxG8(vKxhl4ZRiXVYcY2xJxq6fuKfe2fzbfzb6cSltBgUalyDWkWybHT2laYIlIQnxW1lqE)kYRlGQ9mHSaHcZDbH9rzAhKfuKfOghvSG4wqu08coQyZRPOUMmO1QZ8pd6QfocRqmtyK8SluOjhKFSWSW)jwS37cfAYbzqxTWryfMLmfwQHNh0vlCewHUevC44pmOWXhcfMRlSpkt7GmOSWmzRv)JfMvhmeszfUIMMfLg8pwywDWqiLv4k8)Os5sY6xYnF2xWRr4fKJQwSa5LEfJfe3csxtOO5fiXkm3f8X(OmTdYcSGxISGRxW8ZybFEfj(vwq2(A8csVGcFbHDrwqrwGUa7Y0MHlWcwhScmwqyR9cGS4IOAZfq1EMqwGqH5UGW(OmTdYckYcuJJkwqClikAEbhvS51uuxtg0A1z(NbD1chUxXaZc)3GchFiuyUUW(OmTdYGY6HmfwQHNhIlioklmt2A1)yHz1bdHuwHROPzrPb)JfMvhmeszfUc)pQuUKS(L8r6oV4K2dzxjCgNpguwB(SVGxJWlyYkSAZf8TmTdAfYlOWxagh1cKwE)cSRybASapRKyby7ccfAYbzbAlwGeEsz4cKiACksD9c0wSaj6vc8dsVafYlOVybqwfyG5co4cIBbqghYe7fmZgsajCbxVGq6TGdUa6dYliuOjhKXMxtrDnzqRvN5FgewHvB66Y0oOviJjfHDsTlp7skjQ28hlmtyK8SluOjhKFSWSW)FtMcl1WZdcRWQnDDzAh0kKDjQ4WXF8MNLXE5NZC45tSNUZloP9W6KYqx14uK66bL17V)85BIlgeBvCsDspOWzPvpGmoKj2QHNFqSyV3fk0KdYGUAHJWkmlSEFZN9f85vK4xzbjBTn5f4pZkTGRxGuBUxqClGIWlOAsODSadVscYMxtrDnzqRvN5Fg0vlCgELeysryNu7YZUKsIQn)XcZc)xMcl1WZdXfehL1Mp7l4ZRiXVYcKOmSWXybHcn5ybj1AZRPOUMmO1QZ8pd6QfodVscml8FzkSudppexqCuwpGAjCSmUJb9jJP5ogvNvsjHlkAoZxg58bXI9ExOqtoid6QfocRq5lpBEnf11KbTwDM)zitPTkyLCXrLSXmHrYZUqHMCq(XcZc)hY4qMyRgE(rOqtogrrZU4CIIZcBE(8Tq9Chd6IWqmgCRgEw8qCXGyRItQt6bfolT6bKXHmXwn887pFAqHJpOACkOVAtNqH52mHmOS28zFbtlovQFbPRfvuxVG4wajoRfKusuT5cMzdjGeUGRxWHJ)QdfAYbzbsT5Eb4LPDuT5cW2fCWfqFqEbKqt5YIfqFgKfOTybuKQnxGesWizxPfKnvDUlqBXc((kFwqoQimeJXMxtrDnzqRvN5FgeBvCsDspOWzPvJzH)dzCitSvdp)iuOjhJOOzxCorXzjppWEOEUJbDryigdUvdplEeQN7yyrWizxjNV6ChCRgEw8GyXEVluOjhKbD1chHvywsU5Z(cKiJzRfmZgsajCbuwl46fOKfqRngliuOjhKfOKfyDesz4zmxaNnNyRybsT5Eb4LPDuT5cW2fCWfqFqEbKqt5YIfqFgKfiTc7fiHems2vAbztvN7yZRPOUMmO1QZ8pdITkoPoPhu4S0QXmHrYZUqHMCq(XcZc)hY4qMyRgE(rOqtogrrZU4CIIZsEEG9q9Chd6IWqmgCRgEw84nShQN7yyrWizxjNV6ChCRgEw885BH65ogwems2vY5Ro3b3QHNfpiwS37cfAYbzqxTWryfk)FjF)9nVMI6AYGwRoZ)mORw4iScXmHrYZUqHMCq(XcZc)NyXEVluOjhKbD1chHvywYuyPgEEqxTWryf6suXHJJzYwR(hlmRoyiKYkCfnnlkn4FSWS6GHqkRWv4)rLYLK1VKBEnf11KbTwDM)zqxTWH7vmWmzRv)JfMvhmeszfUIMMfLg8pwywDWqiLv4k8)Os5sY6xYhP78ItApKDLWzC(yqzT51uuxtg0A1z(NbXwfNuN0dkCwA1OjXItOVsMZCafOaHa]] )


end
