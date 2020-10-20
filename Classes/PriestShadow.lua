-- PriestShadow.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID


local PTR = ns.PTR


-- Conduits
-- [x] dissonant_echoes
-- [-] haunting_apparitions
-- [x] mind_devourer
-- [x] rabid_shadows

-- Covenant
-- [-] courageous_ascension
-- [x] shattered_perceptions
-- [x] festering_transfusion
-- [x] fae_fermata

-- Endurance
-- [x] charitable_soul
-- [x] lights_inspiration
-- [x] translucent_image

-- Finesse
-- [x] clear_mind
-- [x] mental_recovery
-- [-] move_with_grace
-- [x] power_unto_others


if UnitClassBase( "player" ) == "PRIEST" then
    local spec = Hekili:NewSpecialization( 258, true )

    spec:RegisterResource( Enum.PowerType.Insanity, {
        mind_flay = {
            aura = "mind_flay",
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
            aura = "mind_sear",
            debuff = true,

            last = function ()
                local app = state.debuff.mind_sear.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.mind_sear.tick_time ) * class.auras.mind_sear.tick_time
            end,

            interval = function () return class.auras.mind_sear.tick_time end,
            value = function () return state.active_enemies end,
        },

        --[[ need to revise the value of this, void decay ticks up and is impacted by void torrent.
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
        }, ]]

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

            interval = function () return 1.5 * state.haste * ( state.conduit.rabid_shadows.enabled and 0.85 or 1 ) end,
            value = function () return ( state.buff.surrender_to_madness.up and 12 or 6 ) end,
        },

        shadowfiend = {
            aura = "shadowfiend",

            last = function ()
                local app = state.buff.shadowfiend.expires - 15
                local t = state.query_time

                return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
            end,

            interval = function () return 1.5 * state.haste * ( state.conduit.rabid_shadows.enabled and 0.85 or 1 ) end,
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
            value = 10,
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
        hungering_void = 21978, -- 345218
        -- legacy_of_the_void = 21978, -- 193225
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


    spec:RegisterHook( "pregain", function( amount, resource, overcap )
        if amount > 0 and resource == "insanity" and state.buff.memory_of_lucid_dreams.up then
            amount = amount * 2
        end

        return amount, resource, overcap
    end )


    spec:RegisterStateTable( "priest", {
        self_power_infusion = true
    } )


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
        shadow_mend = {
            id = 342992,
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
            duration = 15, -- function () return talent.legacy_of_the_void.enabled and 3600 or 15 end,
            max_stack = 1,
            --[[ generate = function( t )
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
                t.caster = "nobody"
                t.timeMod = 1
                t.v1 = 0
                t.v2 = 0
                t.v3 = 0
                t.unit = "player"
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
            }, ]]
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


        -- Conduits
        dissonant_echoes = {
            id = 343144,
            duration = 10,
            max_stack = 1,
        },

    } )


    --[[ spec:RegisterHook( "advance_end", function ()
        if buff.voidform.up and talent.legacy_of_the_void.enabled and insanity.current == 0 then
            insanity.regen = 0
            removeBuff( "voidform" )
            applyBuff( "shadowform" )
        end
    end ) ]]


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

            -- TODO: Set up cycle.
            -- cycle = function ()
            
            handler = function ()
                applyDebuff( "target", "shadow_word_pain" )
                applyDebuff( "target", "vampiric_touch" )
                applyDebuff( "target", "devouring_plague" )

                if talent.unfurling_darkness.enabled and debuff.unfurling_darkness_icd.down then
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
                if conduit.lights_inspiration.enabled then applyBuff( "lights_inspiration" ) end
            end,

            auras = {
                -- Conduit
                lights_inspiration = {
                    id = 337749,
                    duration = 5,
                    max_stack = 1
                }
            }
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

            spend = function () return 0.016 * ( 1 + conduit.clear_mind.mod * 0.01 ) end,
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
                if conduit.translucent_image.enabled then applyBuff( "translucent_image" ) end
            end,

            auras = {
                -- Conduit
                translucent_image = {
                    id = 337661,
                    duration = 5,
                    max_stack = 1
                }
            }
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

            spend = function () return 0.08 * ( 1 + ( conduit.clear_mind.mod * 0.01 ) ) end,
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

            spend = function () return ( talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * ( -7 - buff.empty_mind.stack ) * ( buff.surrender_to_madness.up and 2 or 1 ) end,
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

            aura = "mind_flay",

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

            aura = "mind_sear",

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
            cooldown = function () return 120 - ( conduit.power_unto_others.mod and group and conduit.power_unto_others.mod or 0 ) end,
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
                -- charitable_soul triggered by casting on others; not modeled.
            end,

            auras = {
                -- Conduit
                charitable_soul = {
                    id = 337716,
                    duration = 10,
                    max_stack = 1
                }
            }
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

            auras = {
                -- Conduit
                mental_recovery = {
                    id = 337956,
                    duration = 5,
                    max_stack = 1
                }
            }
        },


         purify_disease = {
            id = 213634,
            cast = 0,
            cooldown = 8,
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
                if level > 55 then addStack( "shadow_mend", nil, 1 ) end
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

                if legendary.painbreaker_psalm.enabled then
                    local power = 0
                    if debuff.shadow_word_pain.up then
                        power = power + 7.5 * min( debuff.shadow_word_pain.remains, 6 ) / 6
                        if debuff.shadow_word_pain.remains < 6 then removeDebuff( "shadow_word_pain" )
                        else debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires - 6 end
                    end
                    if debuff.vampiric_touch.up then
                        power = power + 7.5 * min( debuff.vampiric_touch.remains, 6 ) / 6
                        if debuff.vampiric_touch.remains < 6 then removeDebuff( "vampiric_touch" )
                        else debuff.vampiric_touch.expires = debuff.vampiric_touch.expires - 6 end
                    end
                    if power > 0 then gain( power, "insanity" ) end
                end

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
            nobuff = function () return buff.voidform.up and "voidform" or "shadowform" end,

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

            cycle = function () return talent.misery.enabled and "shadow_word_pain" or "vampiric_touch" end,

            handler = function ()
                applyDebuff( "target", "vampiric_touch" )

                if talent.misery.enabled then
                    applyDebuff( "target", "shadow_word_pain" )
                end

                if talent.unfurling_darkness.enabled then
                    removeBuff( "unfurling_darkness" )
                    if debuff.unfurling_darkness_icd.down then
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
                return buff.surrender_to_madness.up and -24 or -12
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
                if talent.legacy_of_the_void.enabled and debuff.devouring_plague.up then debuff.devouring_plague.expires = query_time + debuff.devouring_plague.duration end

                if talent.hungering_void.enabled then
                    if debuff.hungering_void.up then buff.voidform.expires = buff.voidform.expires + 1 end
                    applyDebuff( "target", "hungering_void", 6 )
                end

                removeBuff( "anunds_last_breath" )
            end,

            auras = {
                hungering_void = {
                    id = 345219,
                    duration = 6,
                    max_stack = 1
                }
            }
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
                    duration = function () return conduit.festering_transfusion.enabled and 17 or 15 end,
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
                applyBuff( "fae_guardians" )
                summonPet( "wrathful_faerie" )
                applyDebuff( "target", "wrathful_faerie" )
                summonPet( "guardian_faerie" )
                applyBuff( "guardian_faerie" )
                summonPet( "benevolent_faerie" )
                applyBuff( "benevolent_faerie" )
                -- TODO: Check totem/guardian API re: faeries.
            end,

            auras = {
                fae_guardians = {
                    id = 327661,
                    duration = 20,
                    max_stack = 1,
                },
                wrathful_faerie = {
                    id = 342132,
                    duration = 20,
                    max_stack = 1,
                },
                wrathful_faerie_fermata = {
                    id = 345452,
                    duration = function () return conduit.fae_fermata.enabled and ( conduit.fae_fermata.mod * 0.001 ) or 3 end,
                    max_stack = 1
                },
                guardian_faerie = {
                    id = 327694,
                    duration = 20,
                    max_stack = 1,
                },
                guardian_faerie_fermata = {
                    id = 345451,
                    duration = function () return conduit.fae_fermata.enabled and ( conduit.fae_fermata.mod * 0.001 ) or 3 end,
                    max_stack = 1
                },
                benevolent_faerie = {
                    id = 327710,
                    duration = 20,
                    max_stack = 1,
                },
                benevolent_faerie_fermata = {
                    id = 345453,
                    duration = function () return conduit.fae_fermata.enabled and ( conduit.fae_fermata.mod * 0.001 ) or 3 end,
                    max_stack = 1
                },
            }
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
                    duration = function () return conduit.shattered_perceptions.enabled and 7 or 5 end,
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


    spec:RegisterPack( "Shadow", 20201018, [[dWuqnbqisP8ifvCjsPsXMKu(ePujJsr4ukIEfQQMLkv3IuQuTlf(LKWWuP4yksltsYZqr00uPuxtskBdvL6BKsfJdvfoNKuvRJuQY8qr6EQK9jj6GkQelKuYdjLQAIssLlIIq2OIkjgPIkPojkc1kvuEjPuP0mvuPYnvuPStuOFIQIAOOQKNQIPIcUQkL0wrrWxLKQSxO(lHbd6Wuwmv5XsmzIUmYMrPptsJMQ60IwTIkj9AfvnBQCBuz3s9BvnCs1XrvrwoWZHmDHRtITtk(oQY4vuPQZJIA9QuI5lPA)knEkMb8rAbHzSQBQ6MP3mLpgtV9nvnT6JpbZ6e(OBL5nvcFAJJWNJVjFE4JUXS7njMb8b9kGcHp(rOJ0EvuHAg(kEJYZvbk5uCwKFxagBubk5kvGpEkPlyIBSh(iTGWmw1nvDZ0BMYhJP3(MQMIpMs4)a85KCAF8XpLsQXE4JKqf8zol84BYN3c5lqsOyNnNfYNlX7rGfoLpUVWQUPQBWhxIceMb8HqiQlecZaMXPygWhRe534dhX9aMfpRWPusPqciJdHpuBEosI1chygRcZa(yLi)gF8C)lfpRi8jb1ehZ4d1MNJKyTWbMrMeZa(yLi)gFuvmGmTw8Sc7wiWh(4d1MNJKyTWbMXBJzaFO28CKeRf(uazqG0WhKo5CIWaQuGgCzlfiYalSYRfw1cRxFHalLcsd1XWKs0i7fw5c57BWhRe534d7xuqKuy3cbYGeEKXHdmJvdZa(qT55ijwl8PaYGaPHpiDY5eHbuPan4YwkqKbwyLxlSQfwV(cbwkfKgQJHjLOr2lSYfY33GpwjYVXhDfqYYC2QcpNHcCGzKVXmGpuBEosI1cFSsKFJpLVluhaliPG1zCe(uazqG0WNi5OfY0Rfo9MfwV(czvCobGk(gqLerYrlKPluTixy96lmmGkfJi5ir8czslKPlSA4JlBsuK4dFJdmJAhmd4JvI8B8bK66osKTaPBfcFO28CKeRfoWmYhygWhRe534dGm9SvfSoJJq4d1MNJKyTWbMXQpMb8Xkr(n(W7boPgkBbGqFBDHWhQnphjXAHdmJtVbZa(yLi)gFcFsO0EVslfSpOq4d1MNJKyTWbMXPtXmGpwjYVXhoI7bmlEwHtPKsHeqghcFO28CKeRfoWmoTkmd4JvI8B8XZ9Vu8SIWNeutCmJpuBEosI1chygNYKygWhRe534JQIbKP1INvy3cb(WhFO28CKeRfoWmo92ygWhQnphjXAHpfqgein8bPtoNimGkfObx2sbImWcR8AHvTW61xiWsPG0qDmmPenYEHvUq((g8Xkr(n(W(ffejf2TqGmiHhzC4aZ40QHzaFO28CKeRf(uazqG0WhKo5CIWaQuGgCzlfiYalSYRfw1cRxFHalLcsd1XWKs0i7fw5c57BWhRe534JUcizzoBvHNZqboWmoLVXmGpuBEosI1cFSsKFJpLVluhaliPG1zCe(uazqG0WNi5OfY0Rfo9MfwV(czvCobGk(gqLerYrlKPluTixy96lmmGkfJi5ir8czslKPlSA4JlBsuK4dFJdmJt1oygWhRe534di11DKiBbs3ke(qT55ijwlCGzCkFGzaFSsKFJpaY0ZwvW6mocHpuBEosI1chygNw9XmGpwjYVXhEpWj1qzlae6BRle(qT55ijwlCGzSQBWmGpwjYVXNWNekT3R0sb7dke(qT55ijwlCGd8rsSMIlWmGzCkMb8Xkr(n(Gsh1fcFO28CKeRfoWmwfMb8HAZZrsSw4tbKbbsdF8uyzhEU)LofumaKvIfwV(cddOsXisoseVqM0cz61c5JBwy96lmmGkfdFYCH)qVelKPlKjRg(yLi)gF0)i)ghygzsmd4d1MNJKyTWNxhFquGpwjYVXhnginphHpAmNcHpYpgiFt(8e8EGuOBzpISmF2QlS2cLFm0yC6jilI4vk(JilZNTk(OXaI24i8r(bsOOJdmJ3gZa(qT55ijwl851Xhef4JvI8B8rJbsZZr4JgZPq4J8JbY3KppbVhif6w2JilZNT6cRTq5hdngNEcYIiELI)iYY8zRUWAlu(XqsAEfq2QcDNPQqJilZNTk(OXaI24i8XCoH8dKqrhhygRgMb8HAZZrsSw4ZRJpikWhRe534JgdKMNJWhnMtHWhKo5CIWaQuGgCzlfiYalSYfwf(OXaI24i8brgiBvrNQ(bNbirrjEwwCGzKVXmGpuBEosI1cFED8brb(yLi)gF0yG08Ce(OXCke(mXc1bjHIbICSc9NhbezZQGYVxy96leO0e7duPrWlBK4zfHpjqkTqhKekieAq8jLuxNKlCYfwBHosd5wyLxlSA8XcRTWY)o5ZRh6ppciYMvbLFpu0xy96lCIf6inKBHmDHvJpwy96luBluhKekgiYXk0FEeqKnRck)EH1wO2wiqPj2hOsJGx2iXZkcFsGuAHoijuqi0G4tkPUojx4KlS2cl)7KpVEO5tPGak6r(9qrhF0yarBCe(ONIhi0Wkqm3fr5Bzg534aZO2bZa(qT55ijwl8PaYGaPHpEkSSdnFkzFa3qrhFSsKFJpSjG8C)lXbMr(aZa(yLi)gF8iaIaZNTk(qT55ijwlCGzS6JzaFSsKFJpUu1pqI5QksvoQd8HAZZrsSw4aZ40BWmGpuBEosI1cFkGmiqA4JNcl7qZNs2hWnu0XhRe534J1fcfaZjkMZHdmJtNIzaFSsKFJpEMQ4zfbilZJWhQnphjXAHdmJtRcZa(qT55ijwl8Xkr(n(umNtyLi)w4suGpUefI24i8PWRGdmJtzsmd4d1MNJKyTWhRe534dqPfwjYVfUef4JlrHOnocF4SSXboWhDavEoplWmGzCkMb8HAZZrsSw4tbKbbsdFaeNLnAHmDHm5n3GpwjYVXh9Nhbe8EGuW(GidfjHdmJvHzaFO28CKeRf(uazqG0WhTTqpfw2bY3Kpp2hWnu0XhRe534dY3Kpp2hWHdmJmjMb8HAZZrsSw4tBCe(y3cY3agsW(DiEwH(ZJa4JvI8B8XUfKVbmKG97q8Sc9NhbWbMXBJzaFO28CKeRf(864dIc8Xkr(n(OXaP55i8rJ5ui8zk(OXaI24i8HlBPargquuINLfhygRgMb8Xkr(n(OX40tqweXRu8XhQnphjXAHdCGpCw2ygWmofZa(yLi)gFqPJ6cHpuBEosI1chygRcZa(qT55ijwl8PaYGaPHpEkSSdV)BXZkcFsyOc1ssou0XhuaYsGzCk(yLi)gFkMZjSsKFlCjkWhxIcrBCe(49FJdmJmjMb8Xkr(n(itKo5eCMAwWhQnphjXAHdmJ3gZa(qT55ijwl8PaYGaPHpAmqAEoAONIhi0Wkqm3fr5Bzg53lS2cZgzDgmVWkVw4TVbFSsKFJpA(ukiGIEKFJdmJvdZa(qT55ijwl8PaYGaPHpEkSSdwJeQkgqMwJgk6lS2c12cLKNcl7GhWcFwfNG1iqsdfD8Xkr(n(G8n5ZtW7bsHULnoWmY3ygWhQnphjXAHpwjYVXNI5CcRe53cxIc8XLOq0ghHpfjchyg1oygWhQnphjXAHpfqgein8jmh1XargiBvrNQ(bNbOb1MNJKlS2cr6KZjcdOsbAWLTuGidSWkx4eluJbsZZrdUSLcezarrjEw2fY)cNUWjxyTfQTfk)yG8n5ZtW7bsHUL9iYY8zRUWAluBlS8Vt(86bx2spQLeyOOJpwjYVXhUSLcezaCGzKpWmGpuBEosI1cFkGmiqA4t2iRZG5fY0RfYhvBH1w4elCIfgMJ6y4R0QeiBvHMpLdQnphjxyTfI0jNtegqLc0GlBPargyHmDHvBHtUW61xisNCoryavkqdUSLcezGfETWPlCs8Xkr(n(O5tPW7DboWmw9XmGpuBEosI1cFSsKFJpsJRTi)gFkGmiqA4J2wOgdKMNJgMZjKFGek64tH5IJeHbuPaHzCkoWmo9gmd4d1MNJKyTWNcidcKg(KnY6myEHm9AH8r1wyTfoXcNyHH5Oog(kTkbYwvO5t5GAZZrYfwBHiDY5eHbuPan4YwkqKbwitxy1w4KlSE9fI0jNtegqLc0GlBPargyHxlC6cNeFSsKFJpA(uk8ExGdmJtNIzaFO28CKeRf(yLi)gFKKMxbKTQq3zQke(uazqG0WNjwiGybeY38C0cRxFHzJSodMxyLlu7uTfo5cRTqTTqnginphn0tXdeAyfiM7IO8TmJ87fwBHtSqTTWWCuhdezGSvfDQ6hCgGguBEosUW61x4elmmh1XargiBvrNQ(bNbOb1MNJKlS2c12c1yG08C0argiBvrNQ(bNbirrjEw2fo5cNeFkmxCKimGkfimJtXbMXPvHzaFO28CKeRf(uazqG0WhKo5CIWaQuGgCzlfiYalKPlCIfE7fY)clFlvYyite6BRdbv8FcnO28CKCHtUWAlmBK1zW8cz61c5JQHpwjYVXhnFkfEVlWbMXPmjMb8HAZZrsSw4JvI8B8b5BYNNG3dKcjzHp(uazqG0WNWaQum8jZf(d9sSqMUWQUzH1RVWjwOofd2KA5WkrQHwyTfcuAI9bQ0a5BYNhRZ4iHoirCdIpPK66KCHtIpfMlosegqLceMXP4aZ40BJzaFO28CKeRf(yLi)gFqkaa1sciIxWzYMqi8PaYGaPHpHbuPyejhjIxitAHmDHvvTfwBHEkSSdnFkzFa3q(8A8PWCXrIWaQuGWmofhygNwnmd4d1MNJKyTWNcidcKg(i)yOX40tqweXRu8hrwMpB1fwBHtSWjwyyoQJbImq2QIov9dodqdQnphjxyTfI0jNtegqLc0GlBPargyHvUWjwOgdKMNJgCzlfiYaIIs8SSlK)foDHtUWjxy96lu(Xa5BYNNG3dKcDl7rKL5ZwDHtIpwjYVXhUSLEuljaoWmoLVXmGpuBEosI1cFkGmiqA4JgdKMNJgMZjKFGek6lS2c12c9uyzhA(uY(aUHI(cRTWWaQumIKJeXlKjTWkx4TXhRe534JMpLI4baQdCGzCQ2bZa(qT55ijwl8PaYGaPHpaLMyFGkn0TS9aKnpbe6iZXni(KsQRtYfwBHAmqAEoAi)aju0xyTfggqLIrKCKiEHEjevDZcRCHtSWY)o5ZRhiFt(8e8EGuijl8hsfGf53lK)fQwKlCs8Xkr(n(G8n5ZtW7bsHKSWhhygNYhygWhQnphjXAHpfqgein8bPtoNimGkfObY3Kpprbyi)fETWPlS2cNyHL)DYNxpq(M85jkad5pk(gqLql8AHm5cRxFHsYtHLDG8n5ZtuagYxijpfw2HI(cRxFHwjYVhiFt(8efGH8hzlyDPQFSW61xyyavkgrYrI4fYKwitxy5FN851dKVjFEIcWq(dwfNtaOIVbujrKC0cNCH1wiWsPG0qDmmPenYEHvUqM8g8Xkr(n(G8n5ZtuagYhhygNw9XmGpuBEosI1cFkGmiqA4dWsPG0qDmmPenYEHvUqM8MfwBHiDY5eHbuPanq(M85jkad5VWkx4u8Xkr(n(G8n5ZtuagYhhygR6gmd4d1MNJKyTWhRe534dx2sbIma(KDqaGIEisw8jYY8OkVQcFYoiaqrpejhhjtli8zk(uazqG0WhKo5CIWaQuGgCzlfiYalSYfQXaP55Obx2sbImGOOepl7cRTqpfw2H0aZlc)xr1pqdfD8P4BzJptXbMXQMIzaFO28CKeRf(yLi)gF4YwkyDgZ4t2bbak6HizXNilZJQ8QQAL)DYNxp08Pu49UyOOJpzheaOOhIKJJKPfe(mfFkGmiqA4JNcl7qAG5fH)RO6hOHI(cRTqnginphnKFGek64tX3YgFMIdmJvvfMb8HAZZrsSw4tbKbbsdF0yG08C0q(bsOOVWAleyPuqAOogCVgIJ6yK9cRCHfdfIi5OfY)cVzuTfwBHiDY5eHbuPan4YwkqKbwitx4TXhRe534dx2sHNZqboWmwftIzaFO28CKeRf(yLi)gF0yC6jilI4vk(4tbKbbsdFaelGq(MNJwyTfggqLIrKCKiEHmPfw5c57fwV(cNyHH5OogCjIampO28CKCH1wO8JbY3KppbVhif6w2daXciKV55Ofo5cRxFHEkSSdLMvb4YwvinW8nHqdfD8PWCXrIWaQuGWmofhygR62ygWhQnphjXAHpfqgein8bqSac5BEoAH1wyyavkgrYrI4fYKwyLl82lS2c12cdZrDm4sebyEqT55i5cRTWWCuhdDeZf)SiCzp)GAZZrYfwBHiDY5eHbuPan4YwkqKbwyLlSk8Xkr(n(G8n5ZtW7bsHULnoWmwv1WmGpuBEosI1cFSsKFJpiFt(8e8EGuOBzJpfqgein8bqSac5BEoAH1wyyavkgrYrI4fYKwyLl82lS2c12cdZrDm4sebyEqT55i5cRTqTTWjwyyoQJbImq2QIov9dodqdQnphjxyTfI0jNtegqLc0GlBPargyHvUWjwOgdKMNJgCzlfiYaIIs8SSlK)foDHtUWjxyTfoXc12cdZrDm0rmx8ZIWL98dQnphjxy96lCIfgMJ6yOJyU4NfHl75huBEosUWAlePtoNimGkfObx2sbImWcz61cRAHtUWjXNcZfhjcdOsbcZ4uCGzSk(gZa(qT55ijwl8Xkr(n(WLTuGidGpzheaOOhIKfFISmpQYRQWNSdcau0drYXrY0ccFMIpfqgein8bPtoNimGkfObx2sbImWcRCHAmqAEoAWLTuGidikkXZYIpfFlB8zkoWmwL2bZa(qT55ijwl8Xkr(n(WLTuW6mMXNSdcau0drYIprwMhv5vv1k)7KpVEO5tPW7DXqrhFYoiaqrpejhhjtli8zk(u8TSXNP4aZyv8bMb8Xkr(n(G8n5ZtW7bsHULn(qT55ijwlCGd8PirygWmofZa(qT55ijwl8PaYGaPHpEkSSdnFkzFa3qrhFSsKFJp6ppciYMvbLFJdmJvHzaFO28CKeRf(uazqG0WhGstSpqLgis3x5wqcDWxCgNf53dIpPK66KCH1w4elmmGkfJejmPCH1RVqj5PWYokgkYwDaiRelCs8Xkr(n(Gsh1fchygzsmd4JvI8B8H1iHQIbKP1i8HAZZrsSw4aZ4TXmGpuBEosI1cFkGmiqA4t2iRZG5fY0fw9VzH1w4eluJbsZZrdZ5eYpqcf9fwV(c9uyzhA(uY(aUHI(cNeFSsKFJpCzlvnocHdmJvdZa(qT55ijwl8PaYGaPHpalLcsd1XWKs0i7fw5cR6g8Xkr(n(O0(VJzr)AmCGzKVXmGpuBEosI1cFkGmiqA4J2wONcl7qZNs2hWnu0xyTfQTfw(3jFE9qZNsbbu0J87HI(cRTqKo5CIWaQuGgCzlfiYalSYfoDH1wO2wyyoQJbImq2QIov9dodqdQnphjxy96lCIf6PWYo08PK9bCdf9fwBHiDY5eHbuPan4YwkqKbwitxyvlS2c12cdZrDmqKbYwv0PQFWzaAqT55i5cNCH1RVWjwONcl7qZNs2hWnu0xyTfgMJ6yGidKTQOtv)GZa0GAZZrYfoj(yLi)gF8(VfpRi8jHHkuljjoWmQDWmGpuBEosI1cFSsKFJpfZ5ewjYVfUef4JlrHOnocFieI6cHWbMr(aZa(yLi)gFuqKidIdHpuBEosI1ch4aF8(VXmGzCkMb8HAZZrsSw4tbKbbsdFq6KZjcdOsbAWLTuGidSqMETqMeFSsKFJpgQqTKKcpNHcCGzSkmd4d1MNJKyTWNcidcKg(mXcr6KZjcdOsbAWLTuGidSWkxyvlS2cdZrDmqKbYwv0PQFWzaAqT55i5cRxFHtSqKo5CIWaQuGgCzlfiYalSYfoDH1wO2wyyoQJbImq2QIov9dodqdQnphjx4KlCYfwBHiDY5eHbuPanmuHAjjf9RXwyLlCk(yLi)gFmuHAjjf9RXWboWNcVcMbmJtXmGpuBEosI1cFuqKGNF6irXqr2QygNIpwjYVXhezGSvfDQ6hCgGWNcZfhjcdOsbcZ4u8PaYGaPHptSqnginphnqKbYwv0PQFWzasuuINLDH1wO2wOgdKMNJg6P4bcnSceZDru(wMr(9cNCH1RVWjwO8JbY3KppbVhif6w2daXciKV55OfwBHiDY5eHbuPan4YwkqKbwyLlC6cNehygRcZa(qT55ijwl8rbrcE(PJefdfzRIzCk(yLi)gFqKbYwv0PQFWzacFkmxCKimGkfimJtXNcidcKg(eMJ6yGidKTQOtv)GZa0GAZZrYfwBHYpgiFt(8e8EGuOBzpaelGq(MNJwyTfI0jNtegqLc0GlBPargyHvUWQWbMrMeZa(qT55ijwl85BhZIcVc(mfFSsKFJpCzlfEodf4ah4aF0qau(nMXQUPQBMEZ0BJp8mqNTkcFyI50FqqYfQDwOvI87f6suGg7m8rh8SPJWN5SWJVjFElKVajHID2CwiFUeVhbw4u(4(cR6MQUzNTZMZczIM7PIsqYf6rSpGwy558SyHEKA2OXcNlLcPhOf2FRD33aCSkUfALi)gTWVDmp2zwjYVrdDavEopl4)Qc9Nhbe8EGuW(GidfjDpzVaeNLnIPm5n3SZSsKFJg6aQ8CEwW)vfiFt(8yFa39K9sBEkSSdKVjFESpGBOOVZSsKFJg6aQ8CEwW)vfkisKbXDVno6YUfKVbmKG97q8Sc9Nhb2zwjYVrdDavEopl4)QcnginphDVno6IlBPargquuINL9(RFHO4UgZPqxt3zwjYVrdDavEopl4)QcngNEcYIiELI)oBNnNfYen3tfLGKlK0qaMxyKC0cdFAHwjEWct0cnnw6mphn2zwjYVrxO0rDH2zwjYVr8FvH(h533t2lpfw2HN7FPtbfdazLOE9WaQumIKJeXlKjX0l(4M61ddOsXWNmx4p0lbtzYQTZSsKFJ4)QcnginphDVno6s(bsOOF)1VquCxJ5uOl5hdKVjFEcEpqk0TShrwMpB1AYpgAmo9eKfr8kf)rKL5ZwDNzLi)gX)vfAmqAEo6EBC0L5Cc5hiHI(9x)crXDnMtHUKFmq(M85j49aPq3YEezz(SvRj)yOX40tqweXRu8hrwMpB1AYpgssZRaYwvO7mvfAezz(Sv3zwjYVr8FvHgdKMNJU3ghDHidKTQOtv)GZaKOOepl79x)crXDnMtHUq6KZjcdOsbAWLTuGiduzv7S5SqMGbsZZrlm(fI4LrXFHEuWJOEHiM7s2QlS8Vt(86fQGmvAHXVq(65rGfYe3SkO87f(GfYe(uUqMiGIEKFVqjPtTmB1fYZNcFcSqDqsOqGihRq)5rar2SkO87fMOfM9cvq0cFWc5rlu(T2vSqFtdTq9Nhbwy2SkO87f6id0KCSZSsKFJ4)QcnginphDVno6spfpqOHvGyUlIY3YmYVV)6xikURXCk01e6GKqXarowH(ZJaISzvq531RduAI9bQ0i4Lns8SIWNeiLwOdscfecni(KsQRtYjR5inKRYRQXh1k)7KpVEO)8iGiBwfu(9qrVE9jCKgYX0QXh1RRnDqsOyGihRq)5rar2SkO87AAdO0e7duPrWlBK4zfHpjqkTqhKekieAq8jLuxNKtwR8Vt(86HMpLccOOh53df9DMvI8Be)xvWMaYZ9V8EYE5PWYo08PK9bCdf9DMvI8Be)xv4raebMpB1DMvI8Be)xv4sv)ajMRQiv5Oo2zwjYVr8FvH1fcfaZjkMZDpzV8uyzhA(uY(aUHI(oZkr(nI)Rk8mvXZkcqwMhTZSsKFJ4)QII5CcRe53cxII7TXrxfELDMvI8Be)xvauAHvI8BHlrX924Olol7D2oZkr(nAuKOl9NhbezZQGYVVNSxEkSSdnFkzFa3qrFNzLi)gnkse)xvGsh1f6EYEbuAI9bQ0ar6(k3csOd(IZ4Si)Eq8jLuxNK1MimGkfJejmPSEDj5PWYokgkYwDaiRetUZSsKFJgfjI)RkynsOQyazAnANzLi)gnkse)xvWLTu14i09K9kBK1zWmtR(3uBcnginphnmNti)aju0Rx3tHLDO5tj7d4gk6tUZSsKFJgfjI)RkuA)3XSOFn29K9cyPuqAOogMuIgzxzv3SZSsKFJgfjI)Rk8(VfpRi8jHHkulj59K9sBEkSSdnFkzFa3qrVM2k)7KpVEO5tPGak6r(9qrVgsNCoryavkqdUSLcezGkNwtBH5OogiYazRk6u1p4manO28CKSE9j8uyzhA(uY(aUHIEnKo5CIWaQuGgCzlfiYamTQAAlmh1XargiBvrNQ(bNbOb1MNJKtwV(eEkSSdnFkzFa3qrVwyoQJbImq2QIov9dodqdQnphjNCNzLi)gnkse)xvumNtyLi)w4suCVno6IqiQleANnNfwDeRP4IfYAoNNvMFHSpyHkiZZrlmdIdP9w4TIOf(9cl)7KpVESZSsKFJgfjI)RkuqKidIdTZ2zwjYVrdV)7ldvOwssHNZqX9K9cPtoNimGkfObx2sbImatVyYDMvI8B0W7)M)RkmuHAjjf9RXUNSxtG0jNtegqLc0GlBPargOYQQfMJ6yGidKTQOtv)GZa0GAZZrY61NaPtoNimGkfObx2sbImqLtRPTWCuhdezGSvfDQ6hCgGguBEoso5K1q6KZjcdOsbAyOc1ssk6xJv50D2oZkr(nAqie1fcDXrCpGzXZkCkLukKaY4q7mRe53ObHquxie)xv45(xkEwr4tcQjoM3zwjYVrdcHOUqi(VQqvXaY0AXZkSBHaF4VZSsKFJgecrDHq8Fvb7xuqKuy3cbYGeEKXDpzVq6KZjcdOsbAWLTuGidu5vv1RdSukinuhdtkrJSRKVVzNzLi)gnieI6cH4)QcDfqYYC2QcpNHI7j7fsNCoryavkqdUSLcezGkVQQEDGLsbPH6yysjAKDL89n7mRe53ObHquxie)xvu(UqDaSGKcwNXr3DztII8IVVNSxrYrm9A6n1RZQ4Ccav8nGkjIKJyQArwVEyavkgrYrI4fYKyA12zwjYVrdcHOUqi(VQaK66osKTaPBfANzLi)gnieI6cH4)Qcaz6zRkyDghH2zwjYVrdcHOUqi(VQG3dCsnu2caH(26cTZSsKFJgecrDHq8Fvr4tcL27vAPG9bfANTZMZcVveTWdzGSvxiJPQFWzaAHj7cz(vwiV05wOFglK6xr1FHHbuPaTqRLlKVEEeyHmXnRck)EHwlxit4tj7d4wObOf2FSqazsMVVWhSW4xiGybeYFHNQN2JVw43lm49l8blK7b0cddOsbASZSsKFJgfELlezGSvfDQ6hCgGURGibp)0rIIHISvVMEVWCXrIWaQuGUMEpzVMqJbsZZrdezGSvfDQ6hCgGefL4zzRPnnginphn0tXdeAyfiM7IO8TmJ87jRxFc5hdKVjFEcEpqk0TShaIfqiFZZr1q6KZjcdOsbAWLTuGidu50j3zZzHh)helu7NGIsgl8qgiB1fYyQ6hCgGwy5Bzg53lm(fopr6l8u90E81cv0xy2lCU8mr7mRe53OrHxH)RkqKbYwv0PQFWza6UcIe88thjkgkYw9A69cZfhjcdOsb6A69K9kmh1XargiBvrNQ(bNbOb1MNJK1KFmq(M85j49aPq3YEaiwaH8nphvdPtoNimGkfObx2sbImqLvTZMZc)2XSOWRSqoBEcTWWNwOvI87f(TJ5fQGmphTqPciB1fw8TUjx2Ql0A5c7pwOHwOTqaPQ4mWcTsKFp2zwjYVrJcVc)xvWLTu45muC)BhZIcVY10D2oZkr(nAqie1fcDXrCpGzXZkCkLukKaY4q7mRe53ObHquxie)xv45(xkEwr4tcQjoM3zwjYVrdcHOUqi(VQqvXaY0AXZkSBHaF4VZSsKFJgecrDHq8Fvb7xuqKuy3cbYGeEKXDpzVq6KZjcdOsbAWLTuGidu5vv1RdSukinuhdtkrJSRKVVzNzLi)gnieI6cH4)QcDfqYYC2QcpNHI7j7fsNCoryavkqdUSLcezGkVQQEDGLsbPH6yysjAKDL89n7mRe53ObHquxie)xvu(UqDaSGKcwNXr3DztII8IVVNSxrYrm9A6n1RZQ4Ccav8nGkjIKJyQArwVEyavkgrYrI4fYKyA12zwjYVrdcHOUqi(VQaK66osKTaPBfANzLi)gnieI6cH4)Qcaz6zRkyDghH2zwjYVrdcHOUqi(VQG3dCsnu2caH(26cTZSsKFJgecrDHq8Fvr4tcL27vAPG9bfANTZSsKFJgCw2xO0rDH2zwjYVrdolB(VQOyoNWkr(TWLO4EBC0L3)9DuaYsCn9EYE5PWYo8(VfpRi8jHHkulj5qrFNzLi)gn4SS5)QczI0jNGZuZYoBol8WCxwOI(czcFkzFa3cTwUq(65rGfYe3SkO87fQ9)3jFEnAHwlx4ZUqfu2QlCU7dMWc1)3TWSrwNbZl0JyFaTWIHISvh7mRe53ObNL9LMpLccOOh533t2lnginphn0tXdeAyfiM7IO8TmJ87AzJSodMR8623SZMZcNB280crkaAHm)kluxjwOI(cpvpThFTW5YzUWxl87fg(0cddOsXct2fw9aw4ZQ4w4CfJajTWe1AxXcTsKAOXoZkr(nAWzzZ)vfiFt(8e8EGuOBzFpzV8uyzhSgjuvmGmTgnu0RPnj5PWYo4bSWNvXjyncK0qrFNzLi)gn4SS5)QII5CcRe53cxII7TXrxfjANnNfoxNQ(lKVa5dYG5fo3YwUWdzGfALi)EHXVqaXciK)cRUNb0c5LH)cpKbYwDHmMQ(bNbODMvI8B0GZYM)Rk4YwkqKbUNSxH5OogiYazRk6u1p4manO28CKSgsNCoryavkqdUSLcezGkNqJbsZZrdUSLcezarrjEww(NoznTj)yG8n5ZtW7bsHUL9iYY8zRwtBL)DYNxp4Yw6rTKadf9D2Cw4TIOfYe(uUqTExSqlwOFQ6tGfQdYhKbZlKxg(lCUwPvjq2QlKj8PCHk6lm(fE7fggqLc09f(Gf(HpbwyyoQd0c)EHhgg7mRe53ObNLn)xvO5tPW7DX9K9kBK1zWmtV4JQvBIjcZrDm8vAvcKTQqZNYb1MNJK1q6KZjcdOsbAWLTuGidW0Qnz96iDY5eHbuPan4YwkqKbUMo5oBolKVaelbwy8lubrlS6mU2I87foxoZf(AHj7cTM5fwDpdlmrlS)yHk6JDMvI8B0GZYM)RkKgxBr(99cZfhjcdOsb6A69K9sBAmqAEoAyoNq(bsOOVZMZcVveTqMWNYfQ17IfAXc9tvFcSqDq(GmyEH8YWFHZ1kTkbYwDHmHpLlurFHXVWBVWWaQuGUVWhSWp8jWcdZrDGw43l8WWyNzLi)gn4SS5)QcnFkfEVlUNSxzJSodMz6fFuTAtmryoQJHVsRsGSvfA(uoO28CKSgsNCoryavkqdUSLcezaMwTjRxhPtoNimGkfObx2sbImW10j3zZzHv33AxXcvq0cRosZRaYwDH8LZuvOfMSlK5xzHfRxOkflm74xit4tj7d4wy2OGm59f(GfMSl8qgiB1fYyQ6hCgGwyIwyyoQdsUqRLlKx6Cl0pJfs9RO6VWWaQuGg7mRe53ObNLn)xvijnVciBvHUZuvO7fMlosegqLc0107j71eaIfqiFZZr1RNnY6myUsTt1MSM20yG08C0qpfpqOHvGyUlIY3YmYVRnH2cZrDmqKbYwv0PQFWzaAqT55iz96teMJ6yGidKTQOtv)GZa0GAZZrYAAtJbsZZrdezGSvfDQ6hCgGefL4zzNCYD2Cw4TIOfYe0AHFVqTF1TWKDHm)klu(T2vSWMi5cJFHfdflS6inVciB1fYxotvHUVqRLlm8jaTqdql0ri0cdFRx4Txyyavkql8vIfor1wiVm8xy5BPsgto2zwjYVrdolB(VQqZNsH37I7j7fsNCoryavkqdUSLcezaMoXT5V8TujJHmrOVToeuX)j0GAZZrYjRLnY6myMPx8r12zZzH3kIw4X3KpVfw9EGu7TWQJSWFHj7cdFAHHbuPyHjAHM3Relm(fktAHpyHm)kl030ql84BYNhRZ4OfYxGeXTqIpPK66KCH8YWFHZTSLEuljWcFWcp(M85XMulxOvIudn2zwjYVrdolB(VQa5BYNNG3dKcjzH)9cZfhjcdOsb6A69K9kmGkfdFYCH)qVemTQBQxFcDkgSj1YHvIudvdO0e7duPbY3KppwNXrcDqI4geFsj11j5K7S5SWBfrl8OaauljWcJFHZnt2ecTWVxOTWWaQuSWW3IfMOfQ(zRUW4xOmPfAXcdFAHGu1pwyKC0yNzLi)gn4SS5)QcKcaqTKaI4fCMSje6EH5IJeHbuPaDn9EYEfgqLIrKCKiEHmjMwv1Q5PWYo08PK9bCd5ZR3zwjYVrdolB(VQGlBPh1scCpzVKFm0yC6jilI4vk(JilZNTATjMimh1XargiBvrNQ(bNbOb1MNJK1q6KZjcdOsbAWLTuGidu5eAmqAEoAWLTuGidikkXZYY)0jNSED5hdKVjFEcEpqk0TShrwMpB1j3zZzH3kIwit4t5cz4baQJf(TJ5fMSl0CUfwDpdOfAaAHwjsn0cTwUWWNwyyavkwiVV1UIfktAHsfq2Qlm8Pfw8TUj3yNzLi)gn4SS5)QcnFkfXdauh3t2RP3t2lnginphnmNti)aju0RPnpfw2HMpLSpGBOOxlmGkfJi5ir8czsvE7D2Cw4TIOfEQEAVQBH8YWFH8LLThGS5jWc5lK54wOs7ieAHHpTWWaQuSqEPZTqpAHEK75TWQUr7Mf6rSpGwy4tlS8Vt(86fwEocTqpRm)oZkr(nAWzzZ)vfiFt(8e8EGuijl8VNSxaLMyFGkn0TS9aKnpbe6iZXni(KsQRtYAAmqAEoAi)aju0RfgqLIrKCKiEHEjevDtLtu(3jFE9a5BYNNG3dKcjzH)qQaSi)MF1ICYD2Cw4TIOfAo3cl(gqLql8zx4X3KpVfQ9bgYFHzVqBHGN3c)EHNSvD0cddOsX9f(GfMSlm8Pf69i0ct0cnVxjwy8luM0yNzLi)gn4SS5)QcKVjFEIcWq(3t2lKo5CIWaQuGgiFt(8efGH8VMwBIY)o5ZRhiFt(8efGH8hfFdOsOlMSEDj5PWYoq(M85jkad5lKKNcl7qrVEDRe53dKVjFEIcWq(JSfSUu1pQxpmGkfJi5ir8czsmT8Vt(86bY3Kpprbyi)bRIZjauX3aQKisoAYAalLcsd1XWKs0i7kzYB2zZzH3kIw4X3KpVfQ9bgYFHFVqTF1TqL2ri0cdFcql0a0cnPeTWSlpx2QJDMvI8B0GZYM)Rkq(M85jkad5FpzVawkfKgQJHjLOr2vYK3udPtoNimGkfObY3Kpprbyi)kNUZMZcVveTW5w2YfEidSW4xy5BKchTWQZaZVqg8Ffv)aTqDWxql87fox4ZmrJfYaFU64Zlu7)nBc4wyIwy4NOfMOfAl0pv9jWc1b5dYG5fg(wVqaj)iYwDHFVW5cFMjAHkTJqOfknW8lm8Ffv)aTWeTqZ7vIfg)cJKJw4Re7mRe53ObNLn)xvWLTuGidCpzVMEpzVq6KZjcdOsbAWLTuGiduPgdKMNJgCzlfiYaIIs8SS18uyzhsdmVi8Ffv)anu0Vx8TSVMEp7Gaaf9qKCCKmTGUMEp7Gaaf9qKSxrwMhv5vv7S5SWBfrlCULTCHZvCgZlm(fw(gPWrlS6mW8lKb)xr1pqluh8f0c)EHhgglKb(C1XNxO2)B2eWTWKDHHFIwyIwOTq)u1NaluhKpidMxy4B9cbK8JiB1fQ0ocHwO0aZVWW)vu9d0ct0cnVxjwy8lmsoAHVsSZSsKFJgCw28Fvbx2sbRZy(EYE5PWYoKgyEr4)kQ(bAOOxtJbsZZrd5hiHI(9IVL9107zheaOOhIKJJKPf0107zheaOOhIK9kYY8OkVQQw5FN851dnFkfEVlgk67S5Sqg4ZvhFEHmbcKSmVWWaQuSWIPVZSsKFJgCw28Fvbx2sHNZqX9K9sJbsZZrd5hiHIEnGLsbPH6yW9AioQJr2vwmuiIKJ4)Mr1QH0jNtegqLc0GlBPargGP3ENzLi)gn4SS5)QcngNEcYIiELI)9cZfhjcdOsb6A69K9cqSac5BEoQwyavkgrYrI4fYKQKVRxFIWCuhdUeraMhuBEoswt(Xa5BYNNG3dKcDl7bGybeY38C0K1R7PWYouAwfGlBvH0aZ3ecnu03zZzHhDQKMBHLVLzKFVW4xikE9fwmuKT6cpvpThFTWVx4ZYQDpmGkfOfYZN6fYMQ(r2QlKjx4dwi3dOfIcRmpjxi37HwO1YfQGYwDH8fI5IFww4Cx2ZVqRLlKr(mdlCULicW8yNzLi)gn4SS5)QcKVjFEcEpqk0TSVNSxaIfqiFZZr1cdOsXisoseVqMuL3UM2cZrDm4sebyEqT55izTWCuhdDeZf)SiCzp)GAZZrYAiDY5eHbuPan4YwkqKbQSQD2CwO2TePVWt1t7XxlurFHFVqdTqoRzEHHbuPaTqdTq9hHsphDFH0CFH0JfYZN6fYMQ(r2QlKjx4dwi3dOfIcRmpjxi37HwiVm8xiFHyU4NLfo3L98JDMvI8B0GZYM)Rkq(M85j49aPq3Y(EH5IJeHbuPaDn9EYEbiwaH8nphvlmGkfJi5ir8czsvE7AAlmh1XGlreG5b1MNJK102eH5OogiYazRk6u1p4manO28CKSgsNCoryavkqdUSLcezGkNqJbsZZrdUSLcezarrjEww(No5K1MqBH5Oog6iMl(zr4YE(b1MNJK1RpryoQJHoI5IFweUSNFqT55iznKo5CIWaQuGgCzlfiYam9QQjNCNzLi)gn4SS5)QcUSLcezG7j7107j7fsNCoryavkqdUSLcezGk1yG08C0GlBPargquuINL9EX3Y(A69Sdcau0drYXrY0c6A69Sdcau0drYEfzzEuLxvTZSsKFJgCw28Fvbx2sbRZy(EX3Y(A69Sdcau0drYXrY0c6A69Sdcau0drYEfzzEuLxvvR8Vt(86HMpLcV3fdf9DMvI8B0GZYM)Rkq(M85j49aPq3YgFq6ubZyvvJpWboWya]] )


end
