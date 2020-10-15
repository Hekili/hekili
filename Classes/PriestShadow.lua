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

            interval = function () return 1.5 * state.haste * ( state.conduit.rabid_shadows.enabled and 0.8 or 1 ) end,
            value = function () return ( state.buff.surrender_to_madness.up and 12 or 6 ) end,
        },

        shadowfiend = {
            aura = "shadowfiend",

            last = function ()
                local app = state.buff.shadowfiend.expires - 15
                local t = state.query_time

                return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
            end,

            interval = function () return 1.5 * state.haste * ( state.conduit.rabid_shadows.enabled and 0.8 or 1 ) end,
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
                    duration = function () return conduit.festering_transfusion.enabled and 20 or 15 end,
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
                    duration = function () return conduit.shattered_perceptions.enabled and 8 or 5 end,
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


    spec:RegisterPack( "Shadow", 20201014, [[dWuflbqisKEKIexcfvLSjjLprQkLrPi1Puu8ksuZcfClsvPQDPWVKenmvkDmfXYKK8muumnvkCnjPABOO03ivLmosvvNtsk16ivvmpse3tLSpjHdQijwiPkpKuvPjkjfxurs1gvKKyKKQsLtIIQQvQO6LOOQuZefvf3urszNOq)efvzOKQINQIPQs1vvPO2kkQ4Rssj7fQ)syWqomLflHhtLjt0Lr2mk9zsA0s0PfTAfjj9AfLMnvDBuz3s9BvnCs54OOslh45GMUW1rvBNu57KW4vKK68OiRxLImFjv7xPXtW3XhPfeMXQUTQBNC7KBmMWStQoZuTXNGjncF0m3SMkHpTXr4ZP0KVc8rZyY)MeFhFGppWr4tzeAq9tLvQMrjFXW9CvctoEVf53oGXgvctoxL4tbF6dM)gxGpslimJvDBv3o52j3ymHzNu9j6p(y8r5dWNtYPFXNYukPgxGpsc6WNPSOtPjFflsFajbJD(uweZZfFbbw0KBWWIQ62QUfF8jmG474dbHu7ii(oMXj474J5I8B8HJ4EatINv45DPuibKXbXhQTcpjX6HdmJvHVJpMlYVXNc))sXZkIssqnXXe(qTv4jjwpCGzKzW3XhZf534JkVbKP1INvy3eb(OeFO2k8KeRhoWmEd8D8HARWtsSE4JdKbbsdFGAK3lcdOsbCWLTuajdSOkUwuvlQE9fbSukiDuhdtkHJSxuflIzVfFmxKFJpSVJhssHDteidsuqghoWmwD8D8HARWtsSE4JdKbbsdFGAK3lcdOsbCWLTuajdSOkUwuvlQE9fbSukiDuhdtkHJSxuflIzVfFmxKFJpA8GKLPSvffEdg4aZiZIVJpuBfEsI1dFmxKFJpUVDuhaliPG1BCe(4azqG0WNi5OfPKRfn52fvV(Iy59EbGCLgqLerYrlsjls1jxu96lkmGkfJi5ir8czslsjlQ64JpBs4K4dZIdmJ6l8D8XCr(n(asnnpjYwa1mhHpuBfEsI1dhyg1F8D8XCr(n(aitlBvbR34ii(qTv4jjwpCGzSAJVJpMlYVXhfpWl1rzlae8BRDe(qTv4jjwpCGzCYT474J5I8B8jkjbFx88TuW(ahHpuBfEsI1dhygNmbFhFmxKFJpCe3dys8ScpVlLcjGmoi(qTv4jjwpCGzCsv474J5I8B8PW)Vu8SIOKeutCmHpuBfEsI1dhygNWm474J5I8B8rL3aY0AXZkSBIaFuIpuBfEsI1dhygNCd8D8HARWtsSE4JdKbbsdFGAK3lcdOsbCWLTuajdSOkUwuvlQE9fbSukiDuhdtkHJSxuflIzVfFmxKFJpSVJhssHDteidsuqghoWmoP6474d1wHNKy9WhhidcKg(a1iVxegqLc4GlBPasgyrvCTOQwu96lcyPuq6OogMuchzVOkweZEl(yUi)gF04bjltzRkk8gmWbMXjml(o(qTv4jjwp8XCr(n(4(2rDaSGKcwVXr4JdKbbsdFIKJwKsUw0KBxu96lIL37faYvAavsejhTiLSivNCr1RVOWaQumIKJeXlKjTiLSOQJp(SjHtIpmloWmorFHVJpMlYVXhqQP5jr2cOM5i8HARWtsSE4aZ4e9hFhFmxKFJpaY0YwvW6nocIpuBfEsI1dhygNuTX3XhZf534JIh4L6OSfac(T1ocFO2k8KeRhoWmw1T474J5I8B8jkjbFx88TuW(ahHpuBfEsI1dh4aFKeRX7d8DmJtW3XhZf534dm9u7i8HARWtsSE4aZyv474d1wHNKy9WhhidcKg(uWZYok8)l98WyaiZflQE9ffgqLIrKCKiEHmPfPKRfP)3UO61xuyavkgLK5JYHMlwKsweZuD8XCr(n(O9r(noWmYm474d1wHNKy9WNxdFGuGpMlYVXhDgiTcpHp6mppHpYpgWst(kekEGuOzzpI0nB2QlQ2IKFm0zCAjiDI45DLJiDZMTk(OZaI24i8r(buWRHdmJ3aFhFO2k8KeRh(8A4dKc8XCr(n(OZaPv4j8rN55j8r(XawAYxHqXdKcnl7rKUzZwDr1wK8JHoJtlbPtepVRCePB2SvxuTfj)yijDppiBvHM3u5PrKUzZwfF0zarBCe(yEVq(buWRHdmJvhFhFO2k8KeRh(8A4dKc8XCr(n(OZaPv4j8rN55j8bQrEVimGkfWbx2sbKmWIQyrvHp6mGOnocFGKbYwv0PAzWzas44JNLfhygzw8D8HARWtsSE4ZRHpqkWhZf534JodKwHNWhDMNNWNPxKgijymGKNvO9kiGiBwEy(9IQxFra(MyFGkncfzdfpRikjbKVfAGKGbbHdI5YNAAKCrZSOAlYt6i)IQ4Arvx)xuTf5(3lFf9q7vqar2S8W87bV2IQxFrtVipPJ8lsjlQ66)IQxFrkDrAGKGXasEwH2RGaISz5H53lQ2Iu6Ia8nX(avAekYgkEwrusciFl0ajbdccheZLp10i5IMzr1wK7FV8v0dDFkfeGxlYVh8A4JodiAJJWhTu8aHowbKP2jCFlZi)ghyg1x474d1wHNKy9WhhidcKg(uWZYo09PK9bCdEn8XCr(n(WMaQW)Vehyg1F8D8XCr(n(uqaibMnBv8HARWtsSE4aZy1gFhFmxKFJp(uTmGIPQ8svoQd8HARWtsSE4aZ4KBX3XhQTcpjX6Hpoqgein8PGNLDO7tj7d4g8A4J5I8B8XAhbdG5foZ7XbMXjtW3XhZf534tHPkEwras3Sq8HARWtsSE4aZ4KQW3XhQTcpjX6HpMlYVXhN59cZf53cFcd8XNWq0ghHpofoCGzCcZGVJpuBfEsI1dFmxKFJpa(wyUi)w4tyGp(egI24i8HZYgh4aF0aK75kSaFhZ4e8D8HARWtsSE4JdKbbsdFu6Ik4zzhWst(kyFa3GxdFmxKFJpWst(kyFahoWmwf(o(qTv4jjwp8PnocFSBcwAadky)oepRq7vqa8XCr(n(y3eS0aguW(DiEwH2RGa4aZiZGVJpuBfEsI1dFEn8bsb(yUi)gF0zG0k8e(OZ88e(mbF0zarBCe(WLTuajdiC8XZYIdmJ3aFhFmxKFJp6moTeKor88Us8HARWtsSE4ah4JtHdFhZ4e8D8HARWtsSE4dpKekktpjCgmYwfZ4e8XCr(n(ajdKTQOt1YGZae(4yY5jryavkGygNGpoqgein8z6fPZaPv4PbKmq2QIovldodqchF8SSlQ2Iu6I0zG0k80qlfpqOJvazQDc33YmYVx0mlQE9fn9IKFmGLM8viu8aPqZYEaiwablTcpTOAlcQrEVimGkfWbx2sbKmWIQyrtw0m4aZyv474d1wHNKy9WhEijuuMEs4myKTkMXj4J5I8B8bsgiBvrNQLbNbi8XXKZtIWaQuaXmobFCGmiqA4tyEQJbKmq2QIovldodqdQTcpjxuTfj)yaln5RqO4bsHML9aqSacwAfEAr1weuJ8EryavkGdUSLcizGfvXIQchygzg8D8HARWtsSE4Z3EMeofo8zc(yUi)gF4Ywkk8gmWboWhNeIVJzCc(o(qTv4jjwp8XbYGaPHpf8SSdDFkzFa3GxdFmxKFJpAVcciYMLhMFJdmJvHVJpuBfEsI1dFCGmiqA4dGVj2hOsdiPvYFtqHg4DEJZI87bXC5tnnsUOAlA6ffgqLIrcfMuUO61xKKk4zzhodgzRoaK5Ifnd(yUi)gFGPNAhHdmJmd(o(yUi)gFynsOYBazAneFO2k8KeRhoWmEd8D8HARWtsSE4JdKbbsdFYgADgmTiLSOQ9TlQ2IMEr6mqAfEAyEVq(buWRTO61xubpl7q3Ns2hWn41w0m4J5I8B8HlBPQXrqCGzS6474d1wHNKy9WhhidcKg(aSukiDuhdtkHJSxuflQQBXhZf534dFx(EMe9RZWbMrMfFhFO2k8KeRh(4azqG0WhLUOcEw2HUpLSpGBWRTOAlsPlY9Vx(k6HUpLccWRf53dETfvBrqnY7fHbuPao4YwkGKbwuflAYIQTiLUOW8uhdizGSvfDQwgCgGguBfEsUO61x00lQGNLDO7tj7d4g8AlQ2IGAK3lcdOsbCWLTuajdSiLSOQwuTfP0ffMN6yajdKTQOt1YGZa0GARWtYfnZIQxFrtVOcEw2HUpLSpGBWRTOAlkmp1XasgiBvrNQLbNbOb1wHNKlAg8XCr(n(u8FlEwruscd6OwssCGzuFHVJpuBfEsI1dFmxKFJpoZ7fMlYVf(eg4JpHHOnocFiiKAhbXbMr9hFhFmxKFJp8qsKbXbXhQTcpjX6HdCGpf)347ygNGVJpuBfEsI1dFCGmiqA4duJ8EryavkGdUSLcizGfPKRfXm4J5I8B8XGoQLKuu4nyGdmJvHVJpuBfEsI1dFCGmiqA4Z0lcQrEVimGkfWbx2sbKmWIQyrvTOAlkmp1XasgiBvrNQLbNbOb1wHNKlQE9fn9IGAK3lcdOsbCWLTuajdSOkw0KfvBrkDrH5PogqYazRk6uTm4manO2k8KCrZSOzwuTfb1iVxegqLc4WGoQLKu0VoBrvSOj4J5I8B8XGoQLKu0Vodh4aF4SSX3XmobFhFmxKFJpW0tTJWhQTcpjX6HdmJvHVJpuBfEsI1dFCGmiqA4tbpl7O4)w8SIOKeg0rTKKdEn8bgG0fygNGpMlYVXhN59cZf53cFcd8XNWq0ghHpf)34aZiZGVJpMlYVXhzc1iVGZuth(qTv4jjwpCGz8g474d1wHNKy9WhhidcKg(OZaPv4PHwkEGqhRaYu7eUVLzKFVOAlkBO1zW0IQ4Ar34w8XCr(n(O7tPGa8Ar(noWmwD8D8HARWtsSE4JdKbbsdFk4zzhSgju5nGmTgo41wuTfP0fjPcEw2HcGfLS8EbRrGKg8A4J5I8B8bwAYxHqXdKcnlBCGzKzX3XhQTcpjX6HpMlYVXhN59cZf53cFcd8XNWq0ghHpojehyg1x474d1wHNKy9WhhidcKg(eMN6yajdKTQOt1YGZa0GARWtYfvBrqnY7fHbuPao4YwkGKbwuflA6fPZaPv4Pbx2sbKmGWXhpl7IuErtw0mlQ2Iu6IKFmGLM8viu8aPqZYEePB2SvxuTfP0f5(3lFf9GlBzb1scm41WhZf534dx2sbKmaoWmQ)474d1wHNKy9WhZf534J04AlYVXhhidcKg(O0fPZaPv4PH59c5hqbVg(4yY5jryavkGygNGdmJvB8D8HARWtsSE4JdKbbsdFYgADgmTiLCTi9V6lQ2IMErtVOW8uhJs(wLazRk09PCqTv4j5IQTiOg59IWaQuahCzlfqYalsjlQ6lAMfvV(IGAK3lcdOsbCWLTuajdSORfnzrZGpMlYVXhDFkffVpWbMXj3IVJpuBfEsI1dFmxKFJpss3ZdYwvO5nvEcFCGmiqA4Z0lcqSacwAfEAr1RVOSHwNbtlQIfPVQ(IMzr1wKsxKodKwHNgAP4bcDScitTt4(wMr(9IQTOPxKsxuyEQJbKmq2QIovldodqdQTcpjxu96lA6ffMN6yajdKTQOt1YGZa0GARWtYfvBrkDr6mqAfEAajdKTQOt1YGZaKWXhpl7IMzrZGpoMCEsegqLciMXj4aZ4Kj474d1wHNKy9WhhidcKg(a1iVxegqLc4GlBPasgyrkzrtVOBSiLxK7BjFgdzcHFBDiix5tWb1wHNKlAMfvBrzdTodMwKsUwK(xD8XCr(n(O7tPO49boWmoPk8D8HARWtsSE4J5I8B8bwAYxHqXdKcjzrj(4azqG0WNWaQumkjZhLdnxSiLSOQUDr1RVOPxKgfd2KA5WCrQJwuTfb4BI9bQ0awAYxbR34iHgiHCdI5YNAAKCrZGpoMCEsegqLciMXj4aZ4eMbFhFO2k8KeRh(yUi)gFG8aa1sciIxWzYMGq8XbYGaPHpHbuPyejhjIxitArkzrvv9fvBrf8SSdDFkzFa3q(kA8XXKZtIWaQuaXmobhygNCd8D8HARWtsSE4JdKbbsdFKFm0zCAjiDI45DLJiDZMT6IQTOPx00lkmp1XasgiBvrNQLbNbOb1wHNKlQ2IGAK3lcdOsbCWLTuajdSOkw00lsNbsRWtdUSLcizaHJpEw2fP8IMSOzw0mlQE9fj)yaln5RqO4bsHML9is3SzRUOzWhZf534dx2YcQLeahygNuD8D8HARWtsSE4JdKbbsdF0zG0k80W8EH8dOGxBr1wKsxubpl7q3Ns2hWn41wuTffgqLIrKCKiEHmPfvXIUb(yUi)gF09PuepaqDGdmJtyw8D8HARWtsSE4JdKbbsdFa8nX(avAOzzxaiBwci0GMNBqmx(utJKlQ2I0zG0k80q(buWRTOAlkmGkfJi5ir8cnxiQ62fvXIMErU)9YxrpGLM8viu8aPqswuoK8alYVxKYls1jx0m4J5I8B8bwAYxHqXdKcjzrjoWmorFHVJpuBfEsI1dFCGmiqA4duJ8EryavkGdyPjFfchWGLl6ArtwuTfn9IC)7LVIEaln5Rq4agSC4knGkbx01IyMfvV(IKubpl7awAYxHWbmyPqsf8SSdETfvV(ImxKFpGLM8viCadwoYwW6t1Yyr1RVOWaQumIKJeXlKjTiLSi3)E5ROhWst(keoGblhS8EVaqUsdOsIi5OfnZIQTiGLsbPJ6yysjCK9IQyrmZT4J5I8B8bwAYxHWbmyjoWmor)X3XhQTcpjX6Hpoqgein8byPuq6OogMuchzVOkweZC7IQTiOg59IWaQuahWst(keoGblxuflAc(yUi)gFGLM8viCadwIdmJtQ2474d1wHNKy9WhZf534dx2sbKma(KDqaaVwisw8js3SWkUQcFYoiaGxlejhhjtli8zc(4azqG0WhOg59IWaQuahCzlfqYalQIfPZaPv4Pbx2sbKmGWXhpl7IQTOcEw2H0aZkIYNxTmGdEn8XvAzJptWbMXQUfFhFO2k8KeRh(yUi)gF4Ywky9gt4t2bba8AHizXNiDZcR4QQAU)9Yxrp09Puu8(yWRHpzheaWRfIKJJKPfe(mbFCGmiqA4tbpl7qAGzfr5ZRwgWbV2IQTiDgiTcpnKFaf8A4JR0YgFMGdmJvnbFhFO2k8KeRh(4azqG0WhDgiTcpnKFaf8AlQ2IawkfKoQJb3RJ4OogzVOkwKZGHisoArkVOBhvFr1weuJ8EryavkGdUSLcizGfPKfDd8XCr(n(WLTuu4nyGdmJvvf(o(qTv4jjwp8XCr(n(OZ40sq6eXZ7kXhhidcKg(aiwablTcpTOAlkmGkfJi5ir8czslQIfXSlQE9fn9IcZtDm4sibyAqTv4j5IQTi5hdyPjFfcfpqk0SShaIfqWsRWtlAMfvV(Ik4zzh8nlpWNTQqAGzBcch8A4JJjNNeHbuPaIzCcoWmwfZGVJpuBfEsI1dFCGmiqA4dGybeS0k80IQTOWaQumIKJeXlKjTOkw0nwuTfP0ffMN6yWLqcW0GARWtYfvBrH5PogAqMCLPt4ZE2b1wHNKlQ2IGAK3lcdOsbCWLTuajdSOkwuv4J5I8B8bwAYxHqXdKcnlBCGzSQBGVJpuBfEsI1dFmxKFJpWst(kekEGuOzzJpoqgein8bqSacwAfEAr1wuyavkgrYrI4fYKwufl6glQ2Iu6IcZtDm4sibyAqTv4j5IQTiLUOPxuyEQJbKmq2QIovldodqdQTcpjxuTfb1iVxegqLc4GlBPasgyrvSOPxKodKwHNgCzlfqYachF8SSls5fnzrZSOzwuTfn9Iu6IcZtDm0Gm5ktNWN9SdQTcpjxu96lA6ffMN6yObzYvMoHp7zhuBfEsUOAlcQrEVimGkfWbx2sbKmWIuY1IQArZSOzWhhtopjcdOsbeZ4eCGzSQQJVJpuBfEsI1dFmxKFJpCzlfqYa4t2bba8AHizXNiDZcR4Qk8j7GaaETqKCCKmTGWNj4JdKbbsdFGAK3lcdOsbCWLTuajdSOkwKodKwHNgCzlfqYachF8SS4JR0YgFMGdmJvXS474d1wHNKy9WhZf534dx2sbR3ycFYoiaGxlejl(ePBwyfxvvZ9Vx(k6HUpLII3hdEn8j7GaaETqKCCKmTGWNj4JR0YgFMGdmJvPVW3XhZf534dS0KVcHIhifAw24d1wHNKy9WboWb(OJaW8BmJvDBv3o52jmd(OWaD2Qq8H5Nt7bbjxK(ArMlYVxKpHbCSZXhOg5Wmwv11F8rd8SPNWNPSOtPjFflsFajbJD(uweZZfFbbw0KBWWIQ62QUDNVZNYIM6t1KJpi5Iki2hqlY9CfwSOcsnB4yrtfNJ0c4I6V13xAaowE)ImxKFdx03EMg7CZf53WHgGCpxHfkFvjS0KVc2hWXqYEP0cEw2bS0KVc2hWn4125MlYVHdna5EUclu(QsEijYG4yOno6YUjyPbmOG97q8ScTxbb25MlYVHdna5EUclu(QsDgiTcpXqBC0fx2sbKmGWXhplldV2fKcg0zEE6AYo3Cr(nCObi3ZvyHYxvQZ40sq6eXZ7k3578PSOP(un54dsUishbyArrYrlkkPfzU4blkHlY0zP3k80yNBUi)gEbtp1oANBUi)gQ8vLAFKFZqYEvWZYok8)l98WyaiZf1RhgqLIrKCKiEHmjLCP)3wVEyavkgLK5JYHMlucZu9DU5I8BOYxvQZaPv4jgAJJUKFaf8Am8AxqkyqN55Pl5hdyPjFfcfpqk0SShr6MnB1AYpg6moTeKor88UYrKUzZwDNBUi)gQ8vL6mqAfEIH24OlZ7fYpGcEngETlifmOZ880L8JbS0KVcHIhifAw2JiDZMTAn5hdDgNwcsNiEEx5is3SzRwt(Xqs6EEq2QcnVPYtJiDZMT6o3Cr(nu5Rk1zG0k8edTXrxqYazRk6uTm4majC8XZYYWRDbPGbDMNNUGAK3lcdOsbCWLTuajdurv78PSiMJbsRWtlk(fbvKHRCrfuOGOErqMAx2QlY9Vx(k6fXdnvArXVi95vqGfX83S8W87f9GfXC(uUOPoGxlYVxKK0OwMT6IuusrjbwKgijyiGKNvO9kiGiBwEy(9Is4IYEr8qArpyrkOfj)wFlwuPPJwK2RGalkBwEy(9I8KbAso25MlYVHkFvPodKwHNyOno6slfpqOJvazQDc33YmYVz41UGuWGoZZtxtRbscgdi5zfAVcciYMLhMFxVoGVj2hOsJqr2qXZkIssa5BHgijyqq4GyU8PMgjNPMN0r(kUQU(xZ9Vx(k6H2RGaISz5H53dET61N2t6iVsQU(xVUs1ajbJbK8ScTxbbezZYdZVRPuaFtSpqLgHISHINveLKaY3cnqsWGGWbXC5tnnsotn3)E5ROh6(ukiaVwKFp4125MlYVHkFvjBcOc))sgs2RcEw2HUpLSpGBWRTZnxKFdv(QYccajWSzRUZnxKFdv(QsFQwgqXuvEPkh1Xo3Cr(nu5RkT2rWayEHZ8Egs2RcEw2HUpLSpGBWRTZnxKFdv(QYctv8SIaKUzH7CZf53qLVQ0zEVWCr(TWNWGH24OlNc3o3Cr(nu5Rkb8TWCr(TWNWGH24Olol7D(o3Cr(nC4KWlTxbbezZYdZVzizVk4zzh6(uY(aUbV2o3Cr(nC4KqLVQeMEQDedj7fGVj2hOsdiPvYFtqHg4DEJZI87bXC5tnnswB6WaQumsOWKY61Lubpl7WzWiB1bGmxmZo3Cr(nC4KqLVQK1iHkVbKP1WDU5I8B4WjHkFvjx2svJJGmKSxzdTodMus1(2AtRZaPv4PH59c5hqbVw96f8SSdDFkzFa3GxBMDU5I8B4WjHkFvjFx(EMe9RZyizVawkfKoQJHjLWr2vu1T7CZf53WHtcv(QYI)BXZkIssyqh1ssYqYEP0cEw2HUpLSpGBWRvtPU)9Yxrp09PuqaETi)EWRvdQrEVimGkfWbx2sbKmqftQP0W8uhdizGSvfDQwgCgGguBfEswV(0f8SSdDFkzFa3GxRguJ8EryavkGdUSLcizaLuvnLgMN6yajdKTQOt1YGZa0GARWtYzQxF6cEw2HUpLSpGBWRvlmp1XasgiBvrNQLbNbOb1wHNKZSZnxKFdhoju5RkDM3lmxKFl8jmyOno6IGqQDeCNpLfvneRX7JfXAEFH5MDrSpyr8qRWtlkdIdQFw0ndPf99IC)7LVIESZnxKFdhoju5Rk5HKidIdUZ35MlYVHJI)7ld6OwssrH3Gbdj7fuJ8EryavkGdUSLcizaLCXm7CZf53WrX)TYxvAqh1ssk6xNXqYEnnuJ8EryavkGdUSLcizGkQQwyEQJbKmq2QIovldodqdQTcpjRxFAOg59IWaQuahCzlfqYavmPMsdZtDmGKbYwv0PAzWzaAqTv4j5mZudQrEVimGkfWHbDuljPOFDwft257CZf53WbbHu7i4fhX9aMepRWZ7sPqciJdUZnxKFdheesTJGkFvzH)FP4zfrjjOM4yANBUi)goiiKAhbv(QsvEditRfpRWUjc8r5o3Cr(nCqqi1ocQ8vLSVJhssHDteidsuqghdj7fuJ8EryavkGdUSLcizGkUQQEDGLsbPJ6yysjCKDfm7T7CZf53WbbHu7iOYxvQXdswMYwvu4nyWqYEb1iVxegqLc4GlBPasgOIRQQxhyPuq6OogMuchzxbZE7o3Cr(nCqqi1ocQ8vLUVDuhaliPG1BCed(SjHtEXSmKSxrYrk5AYT1RZY79ca5knGkjIKJuIQtwVEyavkgrYrI4fYKus135MlYVHdccP2rqLVQeKAAEsKTaQzoANBUi)goiiKAhbv(QsazAzRky9ghb35MlYVHdccP2rqLVQuXd8sDu2cab)2AhTZnxKFdheesTJGkFvzusc(U45BPG9boANVZNYIUziTOdzGSvxeJPAzWzaArj7Iy65xKI07xuzglI6NxTCrHbuPaUiRLlsFEfeyrm)nlpm)ErwlxeZ5tj7d4wKbOf1FSiazsMyyrpyrXViaXciy5Iovl9J(SOVxuO4x0dwe3dOffgqLc4yNBUi)goCkCxqYazRk6uTm4maXapKekktpjCgmYw9AcdoMCEsegqLc41egs2RP1zG0k80asgiBvrNQLbNbiHJpEw2AkvNbsRWtdTu8aHowbKP2jCFlZi)EM61Nw(XawAYxHqXdKcnl7bGybeS0k8unOg59IWaQuahCzlfqYavmzMD(uw0P8bXI0VjWXNXIoKbYwDrmMQLbNbOf5(wMr(9IIFrZsK2Iovl9J(SiETfL9IMk)uFNBUi)goCkCkFvjKmq2QIovldodqmWdjHIY0tcNbJSvVMWGJjNNeHbuPaEnHHK9kmp1XasgiBvrNQLbNbOb1wHNK1KFmGLM8viu8aPqZYEaiwablTcpvdQrEVimGkfWbx2sbKmqfvTZNYI(2ZKWPWTioBwcUOOKwK5I87f9TNPfXdTcpTijpiB1f5kTUjF2QlYA5I6pwKbxKTiaPY7nWImxKFp25MlYVHdNcNYxvYLTuu4nyWW3EMeofURj78DU5I8B4GGqQDe8IJ4EatINv45DPuibKXb35MlYVHdccP2rqLVQSW)Vu8SIOKeutCmTZnxKFdheesTJGkFvPkVbKP1INvy3eb(OCNBUi)goiiKAhbv(Qs23XdjPWUjcKbjkiJJHK9cQrEVimGkfWbx2sbKmqfxvvVoWsPG0rDmmPeoYUcM92DU5I8B4GGqQDeu5Rk14bjltzRkk8gmyizVGAK3lcdOsbCWLTuajduXvv1RdSukiDuhdtkHJSRGzVDNBUi)goiiKAhbv(Qs33oQdGfKuW6noIbF2KWjVywgs2Ri5iLCn5261z59EbGCLgqLerYrkr1jRxpmGkfJi5ir8czskP67CZf53WbbHu7iOYxvcsnnpjYwa1mhTZnxKFdheesTJGkFvjGmTSvfSEJJG7CZf53WbbHu7iOYxvQ4bEPokBbGGFBTJ25MlYVHdccP2rqLVQmkjbFx88TuW(ahTZ35MlYVHdol7ly6P2r7CZf53WbNLTYxv6mVxyUi)w4tyWqBC0vX)ndWaKU4Acdj7vbpl7O4)w8SIOKeg0rTKKdETDU5I8B4GZYw5RkLjuJ8cotnD78PSOdtTBr8AlI58PK9bClYA5I0NxbbweZFZYdZVxK(9FV8v0WfzTCrp7I4HzRUiMpFWCwK2)(fLn06myArfe7dOf5myKT6yNBUi)go4SSV09PuqaETi)MHK9sNbsRWtdTu8aHowbKP2jCFlZi)Uw2qRZGPkUUXT78PSOPMnlTiipGwetp)I04JfXRTOt1s)OplAQCMk6ZI(ErrjTOWaQuSOKDrvlGfLS8(fnvXiqslkHT(wSiZfPoASZnxKFdhCw2kFvjS0KVcHIhifAw2mKSxf8SSdwJeQ8gqMwdh8A1uQKk4zzhkawuYY7fSgbsAWRTZnxKFdhCw2kFvPZ8EH5I8BHpHbdTXrxojCNpLfPVlvlxK(aYhKbtlAQLTCrhYalYCr(9IIFraIfqWYfvn)D4IuKr5IoKbYwDrmMQLbNbODU5I8B4GZYw5Rk5YwkGKbyizVcZtDmGKbYwv0PAzWzaAqTv4jznOg59IWaQuahCzlfqYavmTodKwHNgCzlfqYachF8SSkpzMAkv(XawAYxHqXdKcnl7rKUzZwTMsD)7LVIEWLTSGAjbg8A78PSi9bqSeyrXViEiTOQX4AlYVx0u5mv0NfLSlYAMwu183xucxu)XI41g7CZf53WbNLTYxvknU2I8BgCm58KimGkfWRjmKSxkvNbsRWtdZ7fYpGcETD(uw0ndPfXC(uUi9EFSilwuzQwsGfPbYhKbtlsrgLlsFhFRsGSvxeZ5t5I41wu8l6glkmGkfqgw0dw0hLeyrH5PoGl67fDUp25MlYVHdolBLVQu3NsrX7dgs2RSHwNbtk5s)RETPNomp1XOKVvjq2QcDFkhuBfEswdQrEVimGkfWbx2sbKmGsQ(m1Rd1iVxegqLc4GlBPasg4AYm78PSOQ5B9Tyr8qArvdP75bzRUi9XBQ80Is2fX0ZViN1lsLIfLD8lI58PK9bClkByqMKHf9GfLSl6qgiB1fXyQwgCgGwucxuyEQdsUiRLlsr69lQmJfr9ZRwUOWaQuah7CZf53WbNLTYxvkjDppiBvHM3u5jgCm58KimGkfWRjmKSxtdiwablTcpvVE2qRZGPk0xvFMAkvNbsRWtdTu8aHowbKP2jCFlZi)U20knmp1XasgiBvrNQLbNbOb1wHNK1RpDyEQJbKmq2QIovldodqdQTcpjRPuDgiTcpnGKbYwv0PAzWzas44JNLDMz25tzr3mKweZrVf99I0VvZIs2fX0ZVi536BXIAIKlk(f5mySOQH098GSvxK(4nvEIHfzTCrrjbOfzaArEccxuuA9IUXIcdOsbCrpFSOPR(IuKr5ICFl5ZyMXo3Cr(nCWzzR8vL6(ukkEFWqYEb1iVxegqLc4GlBPasgqjtFdLDFl5Zyiti8BRdb5kFcoO2k8KCMAzdTodMuYL(x9D(uw0ndPfDkn5RyrvRhi1plQAilkxuYUOOKwuyavkwucxKv88XIIFrYKw0dwetp)IknD0IoLM8vW6noAr6diHClIyU8PMgjxKImkx0ulBzb1scSOhSOtPjFfSj1YfzUi1rJDU5I8B4GZYw5RkHLM8viu8aPqswuYGJjNNeHbuPaEnHHK9kmGkfJsY8r5qZfkPQBRxFAnkgSj1YH5IuhvdW3e7duPbS0KVcwVXrcnqc5geZLp10i5m78PSOBgsl6WdauljWIIFrtnt2eeUOVxKTOWaQuSOO0IfLWfP(zRUO4xKmPfzXIIsArGuTmwuKC0yNBUi)go4SSv(QsipaqTKaI4fCMSjiKbhtopjcdOsb8Acdj7vyavkgrYrI4fYKusvvVwbpl7q3Ns2hWnKVIENBUi)go4SSv(QsUSLfuljadj7L8JHoJtlbPtepVRCePB2SvRn90H5PogqYazRk6uTm4manO2k8KSguJ8EryavkGdUSLcizGkMwNbsRWtdUSLcizaHJpEwwLNmZm1Rl)yaln5RqO4bsHML9is3SzRoZoFkl6MH0IyoFkx09haOow03EMwuYUiZ7xu183HlYa0ImxK6OfzTCrrjTOWaQuSifFRVflsM0IK8GSvxuuslYvADt(Xo3Cr(nCWzzR8vL6(ukIhaOoyizVMWqYEPZaPv4PH59c5hqbVwnLwWZYo09PK9bCdETAHbuPyejhjIxitQIBSZNYIUziTOt1s)unlsrgLlsFSSlaKnlbwK(anp3I4BpbHlkkPffgqLIfPi9(fvqlQG8VIfv1TmFTOcI9b0IIsArU)9YxrVi3ZrWfvyUz35MlYVHdolBLVQewAYxHqXdKcjzrjdj7fGVj2hOsdnl7cazZsaHg08CdI5YNAAKSModKwHNgYpGcETAHbuPyejhjIxO5crv3wX0U)9YxrpGLM8viu8aPqswuoK8alYVvw1jNzNpLfDZqArM3VixPbuj4IE2fDkn5Ryr6xGblxu2lYwe4vSOVx0jBvpTOWaQuWWIEWIs2ffL0IkEiCrjCrwXZhlk(fjtASZnxKFdhCw2kFvjS0KVcHdyWsgs2lOg59IWaQuahWst(keoGblVMuBA3)E5ROhWst(keoGblhUsdOsWlMPEDjvWZYoGLM8viCadwkKubpl7GxREDZf53dyPjFfchWGLJSfS(uTmQxpmGkfJi5ir8czskX9Vx(k6bS0KVcHdyWYblV3laKR0aQKisoAMAalLcsh1XWKs4i7kyMB35tzr3mKw0P0KVIfPFbgSCrFVi9B1Si(2tq4IIscqlYa0ImPeUOSDpx2QJDU5I8B4GZYw5RkHLM8viCadwYqYEbSukiDuhdtkHJSRGzUTguJ8EryavkGdyPjFfchWGLvmzNpLfDZqArtTSLl6qgyrXVi33qEoArvJbMDr3lFE1YaUinW7Gl67fnvyEt9XIUZ8QgM3I0VFZMaUfLWffLjCrjCr2Ikt1scSinq(GmyArrP1lcqYpISvx03lAQW8M6lIV9eeUiPbMDrr5ZRwgWfLWfzfpFSO4xuKC0IE(yNBUi)go4SSv(QsUSLcizags2RjmKSxqnY7fHbuPao4YwkGKbQqNbsRWtdUSLcizaHJpEw2Af8SSdPbMveLpVAzah8Am4kTSVMWq2bba8AHi54izAbDnHHSdca41crYEfPBwyfxvTZNYIUziTOPw2YfnvXBmTO4xK7BiphTOQXaZUO7LpVAzaxKg4DWf99Io3hl6oZRAyEls)(nBc4wuYUOOmHlkHlYwuzQwsGfPbYhKbtlkkTEras(rKT6I4BpbHlsAGzxuu(8QLbCrjCrwXZhlk(ffjhTONp25MlYVHdolBLVQKlBPG1BmXqYEvWZYoKgywru(8QLbCWRvtNbsRWtd5hqbVgdUsl7RjmKDqaaVwisoosMwqxtyi7GaaETqKSxr6MfwXvv1C)7LVIEO7tPO49XGxBNpLfDN5vnmVfXCiqYY0IcdOsXICM2o3Cr(nCWzzR8vLCzlffEdgmKSx6mqAfEAi)ak41QbSukiDuhdUxhXrDmYUcNbdrKCKY3oQEnOg59IWaQuahCzlfqYak5g7CZf53WbNLTYxvQZ40sq6eXZ7kzWXKZtIWaQuaVMWqYEbiwablTcpvlmGkfJi5ir8czsvWS1RpDyEQJbxcjatdQTcpjRj)yaln5RqO4bsHML9aqSacwAfEAM61l4zzh8nlpWNTQqAGzBcch8A78PSOJg5sZVi33YmYVxu8lcgV2ICgmYwDrNQL(rFw03l6zz13hgqLc4Iuus9Iyt1YiB1fXml6blI7b0IGH5MLKlI7lGlYA5I4HzRUi9bYKRmDlI5t2ZUiRLlIrM39fn1sibyASZnxKFdhCw2kFvjS0KVcHIhifAw2mKSxaIfqWsRWt1cdOsXisoseVqMuf3OMsdZtDm4sibyAqTv4jzTW8uhdnitUY0j8zp7GARWtYAqnY7fHbuPao4YwkGKbQOQD(uweZ3ePTOt1s)OplIxBrFVidUioRzArHbuPaUidUiThcZcpXWIOPAhPflsrj1lInvlJSvxeZSOhSiUhqlcgMBwsUiUVaUifzuUi9bYKRmDlI5t2Zo25MlYVHdolBLVQewAYxHqXdKcnlBgCm58KimGkfWRjmKSxaIfqWsRWt1cdOsXisoseVqMuf3OMsdZtDm4sibyAqTv4jznLoDyEQJbKmq2QIovldodqdQTcpjRb1iVxegqLc4GlBPasgOIP1zG0k80GlBPasgq44JNLv5jZmtTPvAyEQJHgKjxz6e(SNDqTv4jz96thMN6yObzYvMoHp7zhuBfEswdQrEVimGkfWbx2sbKmGsUQAMz25MlYVHdolBLVQKlBPasgGHK9Acdj7fuJ8EryavkGdUSLcizGk0zG0k80GlBPasgq44JNLLbxPL91egYoiaGxlejhhjtlORjmKDqaaVwis2RiDZcR4QQDU5I8B4GZYw5Rk5Ywky9gtm4kTSVMWq2bba8AHi54izAbDnHHSdca41crYEfPBwyfxvvZ9Vx(k6HUpLII3hdETDU5I8B4GZYw5RkHLM8viu8aPqZYgh4aJb]] )


end
