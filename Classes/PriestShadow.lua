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


    spec:RegisterPack( "Shadow", 20201013, [[dWeBjbqisepsfkxsLsH2KKYNirkgLkkNsfvVIe1Sqb3IePKDPWVKenmvkoMkyzssEMkLmnuu5AQq12qrPVjjeJtskohjsADscL5jj4EQK9rk1bLKkwiPKhkjKMOKu6IQukTrvkfmssKqojjs0kvrEjjsOMjjsWnLKkTtuOFIIIgkkQ6PkAQQuDvuuyRKivFvsOAVq9xcdgYHPSyQYJPYKj6YiBgL(mPA0uvNw0Qjrk1RvHmBjUnQSBP(TQgojDCvkvlh45GMUW1rvBNu8Dsy8Quk68OiRxsQA(sQ2VsJpGVJNslimJvDtv3C4Md3ACJsTQQ5whWZGjvcpvn3rMoHNTXr4503KVc8u1yQ8MeFhpHppWr4PFeQWkwLvQNHpV3W9Cvcto(If53oGXgvctoxL4PhFwcLYg7HNslimJvDtv3C4Md3ACJsTQQPkLkEA8H)dWZzYvrXt)ukPg7HNsc6WZJTOPVjFflI5bjbJ90XweZ0fVhbw0HBXWIQ6MQUbpljmG474jbHu7ii(oMXd474P5I8B8KJ4EatINvu4DPuibKXbXtQnVcjXAHdmJvHVJNMlYVXtVY)sXZkcFsqnXXeEsT5vijwlCGz8w474P5I8B8uN3aY0AXZkSQNaF4JNuBEfsI1chygzo8D8KAZRqsSw4PdKbbsdpHQuPicdOtbCWLTuajdSiTVwuvlQE9fbSukinuhdtkHJSxK2lIzVbpnxKFJNSVJhssHv9eids4rghoWmEC8D8KAZRqsSw4PdKbbsdpHQuPicdOtbCWLTuajdSiTVwuvlQE9fbSukinuhdtkHJSxK2lIzVbpnxKFJNQ8GKLPS1fEfdg4aZiZIVJNuBEfsI1cpnxKFJNUVDuhaliPGTyCeE6azqG0WZi5OfvHRfD4MfvV(Iy5lfbGC(gqNerYrlQcls3jxu96lkmGofJi5ir8czslQcl644zjBs4K4jZIdmJve8D80Cr(nEcsv1cjYwavnhHNuBEfsI1chygRg8D80Cr(nEcitnBDbBX4iiEsT5vijwlCGzuPIVJNMlYVXtfpOi1qzlae8BRDeEsT5vijwlCGz8Wn474P5I8B8m8jbF798TuW(ahHNuBEfsI1chygpCaFhpnxKFJNCe3dys8SIcVlLcjGmoiEsT5vijwlCGz8qv474P5I8B80R8Vu8SIWNeutCmHNuBEfsI1chygpCl8D80Cr(nEQZBazAT4zfw1tGp8XtQnVcjXAHdmJhyo8D8KAZRqsSw4PdKbbsdpHQuPicdOtbCWLTuajdSiTVwuvlQE9fbSukinuhdtkHJSxK2lIzVbpnxKFJNSVJhssHv9eids4rghoWmE44474j1MxHKyTWthidcKgEcvPsregqNc4GlBPasgyrAFTOQwu96lcyPuqAOogMuchzViTxeZEdEAUi)gpv5bjltzRl8kgmWbMXdml(oEsT5vijwl80Cr(nE6(2rDaSGKc2IXr4PdKbbsdpJKJwufUw0HBwu96lILVueaY5BaDsejhTOkSiDNCr1RVOWa6umIKJeXlKjTOkSOJJNLSjHtINmloWmEOIGVJNMlYVXtqQQwir2cOQ5i8KAZRqsSw4aZ4HQbFhpnxKFJNaYuZwxWwmocINuBEfsI1chygpOuX3XtZf534PIhuKAOSfac(T1ocpP28kKeRfoWmw1n474P5I8B8m8jbF798TuW(ahHNuBEfsI1ch4apLeRXxc8DmJhW3XtZf534jmlu7i8KAZRqsSw4aZyv474j1MxHKyTWthidcKgE6XZYo8k)ll8WyaiZflQE9ffgqNIrKCKiEHmPfvHRfvn3SO61xuyaDkg(Kvc)HQlwufw0TooEAUi)gpv)i)ghygVf(oEsT5vijwl88vXtif4P5I8B8uJbsZRq4PgRWt4P8Jb03KVcHIhifQw2JiDhLT(IQTi5hdngNAcsNiEEN)is3rzRJNAmGOnocpLFaf8Q4aZiZHVJNuBEfsI1cpFv8esbEAUi)gp1yG08keEQXk8eEk)ya9n5RqO4bsHQL9is3rzRVOAls(XqJXPMG0jIN35pI0Du26lQ2IKFmKKMNhKTUqTy680is3rzRJNAmGOnocpTsri)ak4vXbMXJJVJNuBEfsI1cpFv8esbEAUi)gp1yG08keEQXk8eEcvPsregqNc4GlBPasgyrAVOQWtngq0ghHNqYazRl6u3p4majC8XZYIdmJml(oEsT5vijwl88vXtif4P5I8B8uJbsZRq4PgRWt45zlsfKemgqQWkuFfeqKnlpm)Er1RViaFtSpqNgHISHINve(KaY3cvqsWGGWbD78PQkjx05lQ2IkKgQSiTVw0XRMfvBrU)lYxrpuFfeqKnlpm)EWRUO61x0zlQqAOYIQWIoE1SO61xKswKkijymGuHvO(kiGiBwEy(9IQTiLSiaFtSpqNgHISHINve(KaY3cvqsWGGWbD78PQkjx05lQ2IC)xKVIEO5tPGa8Qr(9Gxfp1yarBCeEQMIhi0WkGm1oH7Bzg534aZyfbFhpP28kKeRfE6azqG0WtpEw2HMpLSpGBWRINMlYVXt2eqEL)L4aZy1GVJNMlYVXtpcajWrzRJNuBEfsI1chygvQ474P5I8B8SK6(buO0MxQZrDGNuBEfsI1chygpCd(oEsT5vijwl80bYGaPHNE8SSdnFkzFa3GxfpnxKFJNw7iyaSIWzLcoWmE4a(oEAUi)gp9mDXZkcq6ocINuBEfsI1chygpuf(oEsT5vijwl80Cr(nE6SsryUi)wusyGNLegI24i80PWHdmJhUf(oEsT5vijwl80Cr(nEc4BH5I8BrjHbEwsyiAJJWtolBCGd8ufqUNZZc8DmJhW3XtQnVcjXAHNoqgein8ujlYJNLDa9n5RG9bCdEv80Cr(nEc9n5RG9bC4aZyv474j1MxHKyTWZ24i80QEOVbmOG97q8Sc1xbbWtZf534Pv9qFdyqb73H4zfQVccGdmJ3cFhpP28kKeRfE(Q4jKc80Cr(nEQXaP5vi8uJv4j88aEQXaI24i8KlBPasgq44JNLfhygzo8D80Cr(nEQX4utq6eXZ78XtQnVcjXAHdCGNofo8DmJhW3XtQnVcjXAHN8qsOWplKWzWiBDmJhWtZf534jKmq26Io19dodq4PJjxHeHb0PaIz8aE6azqG0WZZwKgdKMxHgqYazRl6u3p4majC8XZYUOAlsjlsJbsZRqd1u8aHgwbKP2jCFlZi)ErNVO61x0zls(Xa6BYxHqXdKcvl7bGybe038k0IQTiOkvkIWa6uahCzlfqYals7fDyrNJdmJvHVJNuBEfsI1cp5HKqHFwiHZGr26ygpGNMlYVXtizGS1fDQ7hCgGWthtUcjcdOtbeZ4b80bYGaPHNHvOogqYazRl6u3p4manO28kKCr1wK8Jb03KVcHIhifQw2daXciOV5vOfvBrqvQueHb0Pao4YwkGKbwK2lQkCGz8w474j1MxHKyTWZVlmjCkC45b80Cr(nEYLTu4vmyGdCGNojeFhZ4b8D8KAZRqsSw4PdKbbsdp94zzhA(uY(aUbVkEAUi)gpvFfeqKnlpm)ghygRcFhpP28kKeRfE6azqG0WtaFtSpqNgqs1NV6HcvW7kgNf53d625tvvsUOAl6SffgqNIrcfMuUO61xKK84zzhodgzRpaK5IfDoEAUi)gpHzHAhHdmJ3cFhpnxKFJNSgj05nGmTgINuBEfsI1chygzo8D8KAZRqsSw4PdKbbsdpZgADgmTOkSiL6nlQ2IoBrAmqAEfAyLIq(buWRUO61xKhpl7qZNs2hWn4vx054P5I8B8KlBPUXrqCGz84474j1MxHKyTWthidcKgEcSukinuhdtkHJSxK2lQQBWtZf534jF7)fMe9RXWbMrMfFhpP28kKeRfE6azqG0WtLSipEw2HMpLSpGBWRUOAlsjlY9Fr(k6HMpLccWRg53dE1fvBrqvQueHb0Pao4YwkGKbwK2l6WIQTiLSOWkuhdizGS1fDQ7hCgGguBEfsUO61x0zlYJNLDO5tj7d4g8QlQ2IGQuPicdOtbCWLTuajdSOkSOQwuTfPKffwH6yajdKTUOtD)GZa0GAZRqYfD(IQxFrNTipEw2HMpLSpGBWRUOAlkSc1XasgiBDrN6(bNbOb1MxHKl6C80Cr(nE69FlEwr4tcd6OwssCGzSIGVJNuBEfsI1cpnxKFJNoRueMlYVfLeg4zjHHOnocpjiKAhbXbMXQbFhpnxKFJN8qsKbXbXtQnVcjXAHdCGNE)347ygpGVJNuBEfsI1cpDGmiqA4juLkfryaDkGdUSLcizGfvHRfDl80Cr(nEAqh1ssk8kgmWbMXQW3XtQnVcjXAHNoqgein88SfbvPsregqNc4GlBPasgyrAVOQwuTffwH6yajdKTUOtD)GZa0GAZRqYfvV(IoBrqvQueHb0Pao4YwkGKbwK2l6WIQTiLSOWkuhdizGS1fDQ7hCgGguBEfsUOZx05lQ2IGQuPicdOtbCyqh1ssk6xJTiTx0b80Cr(nEAqh1ssk6xJHdCGNCw247ygpGVJNMlYVXtywO2r4j1MxHKyTWbMXQW3XtQnVcjXAHNoqgein80JNLD49FlEwr4tcd6OwsYbVkEcdq6cmJhWtZf534PZkfH5I8BrjHbEwsyiAJJWtV)BCGz8w474P5I8B8uMqvQi4m90HNuBEfsI1chygzo8D8KAZRqsSw4PdKbbsdp1yG08k0qnfpqOHvazQDc33YmYVxuTfLn06myArAFTiM7g80Cr(nEQ5tPGa8Qr(noWmEC8D8KAZRqsSw4PdKbbsdp94zzhSgj05nGmTgo4vxuTfPKfjjpEw2HcGf(S8fbRrGKg8Q4P5I8B8e6BYxHqXdKcvlBCGzKzX3XtQnVcjXAHNMlYVXtNvkcZf53Iscd8SKWq0ghHNojehygRi474j1MxHKyTWthidcKgEgwH6yajdKTUOtD)GZa0GAZRqYfvBrqvQueHb0Pao4YwkGKbwK2l6SfPXaP5vObx2sbKmGWXhpl7IuErhw05lQ2IuYIKFmG(M8viu8aPq1YEeP7OS1xuTfPKf5(ViFf9GlBPh1scm4vXtZf534jx2sbKmaoWmwn474j1MxHKyTWtZf534P04AlYVXthidcKgEQKfPXaP5vOHvkc5hqbVkE6yYviryaDkGygpGdmJkv8D8KAZRqsSw4P5I8B8usAEEq26c1IPZt4PdKbbsdppBraIfqqFZRqlQE9fLn06myArAVOkYXx05lQ2IuYI0yG08k0qnfpqOHvazQDc33YmYVxuTfD2IuYIcRqDmGKbYwx0PUFWzaAqT5vi5IQxFrNTOWkuhdizGS1fDQ7hCgGguBEfsUOAlsjlsJbsZRqdizGS1fDQ7hCgGeo(4zzx05l6C80XKRqIWa6uaXmEahygpCd(oEsT5vijwl80bYGaPHNqvQueHb0Pao4YwkGKbwufw0zlI5wKYlY9TKpJHmHWVToeKZ)j4GAZRqYfD(IQTOSHwNbtlQcxlQAooEAUi)gp18Pu49LahygpCaFhpP28kKeRfEAUi)gpH(M8viu8aPqsw4JNoqgein8mmGofdFYkH)q1flQclQQBwu96l6SfPsXGnPwomxKAOfvBra(MyFGonG(M8vWwmosOcsi3GUD(uvLKl6C80XKRqIWa6uaXmEahygpuf(oEsT5vijwl80Cr(nEc5baQLeqeVGZKnbH4PdKbbsdpddOtXisoseVqM0IQWIQ64lQ2I84zzhA(uY(aUH8v04PJjxHeHb0PaIz8aoWmE4w474j1MxHKyTWthidcKgEk)yOX4utq6eXZ78hr6okB9fvBrNTOZwuyfQJbKmq26Io19dodqdQnVcjxuTfbvPsregqNc4GlBPasgyrAVOZwKgdKMxHgCzlfqYachF8SSls5fDyrNVOZxu96ls(Xa6BYxHqXdKcvl7rKUJYwFrNJNMlYVXtUSLEuljaoWmEG5W3XtQnVcjXAHNoqgein8uJbsZRqdRueYpGcE1fvBrkzrE8SSdnFkzFa3GxDr1wuyaDkgrYrI4fYKwK2lI5WtZf534PMpLI4baQdCGz8WXX3XtQnVcjXAHNoqgein8eW3e7d0PHQLThGSJiGqfAfUbD78PQkjxuTfPXaP5vOH8dOGxDr1wuyaDkgrYrI4fQUqu1nls7fD2IC)xKVIEa9n5RqO4bsHKSWFi5bwKFViLxKUtUOZXtZf534j03KVcHIhifsYcFCGz8aZIVJNuBEfsI1cpDGmiqA4juLkfryaDkGdOVjFfchWG(l6ArhwuTfD2IC)xKVIEa9n5Rq4ag0F48nGobx01IU1IQxFrsYJNLDa9n5Rq4ag0xijpEw2bV6IQxFrMlYVhqFt(keoGb9hzlylPUFSO61xuyaDkgrYrI4fYKwufwK7)I8v0dOVjFfchWG(dw(sraiNVb0jrKC0IoFr1weWsPG0qDmmPeoYErAVOBDdEAUi)gpH(M8viCad6JdmJhQi474j1MxHKyTWthidcKgEcSukinuhdtkHJSxK2l6w3SOAlcQsLIimGofWb03KVcHdyq)fP9IoGNMlYVXtOVjFfchWG(4aZ4HQbFhpP28kKeRfEAUi)gp5YwkGKbWZSdca4vdrYINr6ocQ9vv4z2bba8QHi54izAbHNhWthidcKgEcvPsregqNc4GlBPasgyrAVinginVcn4YwkGKbeo(4zzxuTf5XZYoKg4ir4)86(bCWRINoFlB88aoWmEqPIVJNuBEfsI1cpnxKFJNCzlfSfJj8m7GaaE1qKS4zKUJGAFvvn3)f5ROhA(uk8(sm4vXZSdca4vdrYXrY0ccppGNoqgein80JNLDinWrIW)519d4GxDr1wKgdKMxHgYpGcEv805BzJNhWbMXQUbFhpP28kKeRfE6azqG0WtnginVcnKFaf8QlQ2IawkfKgQJb3RH4OogzViTxKZGHisoArkVOBghFr1weuLkfryaDkGdUSLcizGfvHfXC4P5I8B8KlBPWRyWahygR6a(oEsT5vijwl80Cr(nEQX4utq6eXZ78XthidcKgEciwab9nVcTOAlkmGofJi5ir8czsls7fXSlQE9fD2IcRqDm4sibyAqT5vi5IQTi5hdOVjFfcfpqkuTShaIfqqFZRql68fvV(I84zzh8nlpOKTUqAGJAcch8Q4PJjxHeHb0PaIz8aoWmwvv474j1MxHKyTWthidcKgEciwab9nVcTOAlkmGofJi5ir8czsls7fXClQ2IuYIcRqDm4sibyAqT5vi5IQTOWkuhdvito)0jkzF0GAZRqYfvBrqvQueHb0Pao4YwkGKbwK2lQk80Cr(nEc9n5RqO4bsHQLnoWmw1TW3XtQnVcjXAHNMlYVXtOVjFfcfpqkuTSXthidcKgEciwab9nVcTOAlkmGofJi5ir8czsls7fXClQ2IuYIcRqDm4sibyAqT5vi5IQTiLSOZwuyfQJbKmq26Io19dodqdQnVcjxuTfbvPsregqNc4GlBPasgyrAVOZwKgdKMxHgCzlfqYachF8SSls5fDyrNVOZxuTfD2IuYIcRqDmuHm58tNOK9rdQnVcjxu96l6SffwH6yOczY5Norj7JguBEfsUOAlcQsLIimGofWbx2sbKmWIQW1IQArNVOZXthtUcjcdOtbeZ4bCGzSkMdFhpP28kKeRfEAUi)gp5YwkGKbWZSdca4vdrYINr6ocQ9vv4z2bba8QHi54izAbHNhWthidcKgEcvPsregqNc4GlBPasgyrAVinginVcn4YwkGKbeo(4zzXtNVLnEEahygR64474j1MxHKyTWtZf534jx2sbBXycpZoiaGxnejlEgP7iO2xvvZ9Fr(k6HMpLcVVedEv8m7GaaE1qKCCKmTGWZd4PZ3YgppGdmJvXS474P5I8B8e6BYxHqXdKcvlB8KAZRqsSw4ah4ap1qay(nMXQUPQBoCZHd4Pcd0zRdXtLso1heKCrvKfzUi)ErLegWXEcpHQKdZyvhVAWtvWZMfcpp2IM(M8vSiMhKem2thBrmtx8EeyrhUfdlQQBQ6M90E6yl62EBso(GKlYJyFaTi3Z5zXI8i9SHJfvDCosnGlQ)wPLVb4y5llYCr(nCrFxyASNmxKFdhQaY9CEwO8vLqFt(kyFahdj7Ls84zzhqFt(kyFa3GxDpzUi)goubK758Sq5Rk5HKidIJH24OlR6H(gWGc2VdXZkuFfeypzUi)goubK758Sq5Rk1yG08kedTXrxCzlfqYachF8SSm8QxqkyqJv4PRd7jZf53WHkGCpNNfkFvPgJtnbPtepVZFpTNo2IUT3MKJpi5IineGPffjhTOWNwK5IhSOeUitJLfZRqJ9K5I8B4fmlu7O9K5I8BOYxvQ(r(ndj7Lhpl7WR8VSWdJbGmxuVEyaDkgrYrI4fYKQWv1Ct96Hb0Py4twj8hQUOc3647jZf53qLVQuJbsZRqm0ghDj)ak4vz4vVGuWGgRWtxYpgqFt(kekEGuOAzpI0Du261KFm0yCQjiDI45D(JiDhLT(EYCr(nu5Rk1yG08kedTXrxwPiKFaf8Qm8QxqkyqJv4Pl5hdOVjFfcfpqkuTShr6okB9AYpgAmo1eKor88o)rKUJYwVM8JHK088GS1fQftNNgr6okB99K5I8BOYxvQXaP5vigAJJUGKbYwx0PUFWzas44JNLLHx9csbdAScpDbvPsregqNc4GlBPasgq7Q2thBrkDdKMxHwu8lcQidN)I8Oqbr9IGm1US1xK7)I8v0lIhA60IIFrm)RGalsPSz5H53l6blsP)PCr3waVAKFVijPsTmB9fPWNcFcSivqsWqaPcRq9vqar2S8W87fLWfL9I4H0IEWIuqls(TstSiFtdTi1xbbwu2S8W87fvid0KCSNmxKFdv(QsnginVcXqBC0LAkEGqdRaYu7eUVLzKFZWREbPGbnwHNUotfKemgqQWkuFfeqKnlpm)UEDaFtSpqNgHISHINve(KaY3cvqsWGGWbD78PQkjpVwH0qfTVoE1uZ9Fr(k6H6RGaISz5H53dE161pRqAOsfoE1uVUsubjbJbKkSc1xbbezZYdZVRPeaFtSpqNgHISHINve(KaY3cvqsWGGWbD78PQkjpVM7)I8v0dnFkfeGxnYVh8Q7jZf53qLVQKnbKx5Fjdj7Lhpl7qZNs2hWn4v3tMlYVHkFvPhbGe4OS13tMlYVHkFvzj19dOqPnVuNJ6ypzUi)gQ8vLw7iyaSIWzLcdj7Lhpl7qZNs2hWn4v3tMlYVHkFvPNPlEwras3rW9K5I8BOYxv6SsryUi)wusyWqBC0LtHBpzUi)gQ8vLa(wyUi)wusyWqBC0fNL9EApzUi)goCs4L6RGaISz5H53mKSxE8SSdnFkzFa3GxDpzUi)goCsOYxvcZc1oIHK9cW3e7d0PbKu95REOqf8UIXzr(9GUD(uvLK1olmGofJekmPSEDj5XZYoCgmYwFaiZfNVNmxKFdhoju5RkznsOZBazAnCpzUi)goCsOYxvYLTu34iidj7v2qRZGPkOuVP2zAmqAEfAyLIq(buWRwVUhpl7qZNs2hWn4vpFpzUi)goCsOYxvY3(FHjr)Amgs2lGLsbPH6yysjCKT2vDZEYCr(nC4KqLVQ07)w8SIWNeg0rTKKmKSxkXJNLDO5tj7d4g8Q1uI7)I8v0dnFkfeGxnYVh8Q1GQuPicdOtbCWLTuajdO9HAkjSc1XasgiBDrN6(bNbOb1MxHK1RFMhpl7qZNs2hWn4vRbvPsregqNc4GlBPasgOcvvtjHvOogqYazRl6u3p4manO28kK8861pZJNLDO5tj7d4g8Q1cRqDmGKbYwx0PUFWzaAqT5vi557jZf53WHtcv(QsNvkcZf53IscdgAJJUiiKAhb3thBrvlXA8LyrSwP4zUJwe7dwep08k0IYG4GvSfXmG0I(ErU)lYxrp2tMlYVHdNeQ8vL8qsKbXb3t7jZf53WH3)9LbDuljPWRyWGHK9cQsLIimGofWbx2sbKmqfUU1EYCr(nC49FR8vLg0rTKKI(1ymKSxNbvPsregqNc4GlBPasgq7QQfwH6yajdKTUOtD)GZa0GAZRqY61pdQsLIimGofWbx2sbKmG2hQPKWkuhdizGS1fDQ7hCgGguBEfsE(51GQuPicdOtbCyqh1ssk6xJP9H90EYCr(nCqqi1ocEXrCpGjXZkk8UukKaY4G7jZf53WbbHu7iOYxv6v(xkEwr4tcQjoM2tMlYVHdccP2rqLVQuN3aY0AXZkSQNaF4VNmxKFdheesTJGkFvj774HKuyvpbYGeEKXXqYEbvPsregqNc4GlBPasgq7RQQxhyPuqAOogMuchzRnZEZEYCr(nCqqi1ocQ8vLQ8GKLPS1fEfdgmKSxqvQueHb0Pao4YwkGKb0(QQ61bwkfKgQJHjLWr2AZS3SNmxKFdheesTJGkFvP7Bh1bWcskylghXqjBs4Kxmldj7vKCufUoCt96S8LIaqoFdOtIi5OkO7K1RhgqNIrKCKiEHmPkC89K5I8B4GGqQDeu5RkbPQAHezlGQMJ2tMlYVHdccP2rqLVQeqMA26c2IXrW9K5I8B4GGqQDeu5Rkv8GIudLTaqWVT2r7jZf53WbbHu7iOYxvg(KGV9E(wkyFGJ2t7PJTiMbKw0Kmq26lIXu3p4maTOKDrm98lsrwklYpJfr9ZR7VOWa6uaxK1YfX8VccSiLYMLhMFViRLlsP)PK9bClYa0I6pweGmjtmSOhSO4xeGybe0FrZkEfJ5x03lku8l6blI7b0IcdOtbCSNmxKFdhofUlizGS1fDQ7hCgGyGhscf(zHeodgzRFDGbhtUcjcdOtb86adj71zAmqAEfAajdKTUOtD)GZaKWXhplBnLOXaP5vOHAkEGqdRaYu7eUVLzKFFE96Nj)ya9n5RqO4bsHQL9aqSac6BEfQguLkfryaDkGdUSLcizaTpC(E6ylA6)Gyrv0e44ZyrtYazRVigtD)GZa0ICFlZi)ErXVOJisDrZkEfJ5xeV6IYErvN)2UNmxKFdhofoLVQesgiBDrN6(bNbig4HKqHFwiHZGr26xhyWXKRqIWa6uaVoWqYEfwH6yajdKTUOtD)GZa0GAZRqYAYpgqFt(kekEGuOAzpaelGG(MxHQbvPsregqNc4GlBPasgq7Q2thBrFxys4u4weNDebxu4tlYCr(9I(UW0I4HMxHwKKhKT(IC(w3ujB9fzTCr9hlYGlYweG05lgyrMlYVh7jZf53WHtHt5Rk5Ywk8kgmy47ctcNc31H90EYCr(nCqqi1ocEXrCpGjXZkk8UukKaY4G7jZf53WbbHu7iOYxv6v(xkEwr4tcQjoM2tMlYVHdccP2rqLVQuN3aY0AXZkSQNaF4VNmxKFdheesTJGkFvj774HKuyvpbYGeEKXXqYEbvPsregqNc4GlBPasgq7RQQxhyPuqAOogMuchzRnZEZEYCr(nCqqi1ocQ8vLQ8GKLPS1fEfdgmKSxqvQueHb0Pao4YwkGKb0(QQ61bwkfKgQJHjLWr2AZS3SNmxKFdheesTJGkFvP7Bh1bWcskylghXqjBs4Kxmldj7vKCufUoCt96S8LIaqoFdOtIi5OkO7K1RhgqNIrKCKiEHmPkC89K5I8B4GGqQDeu5RkbPQAHezlGQMJ2tMlYVHdccP2rqLVQeqMA26c2IXrW9K5I8B4GGqQDeu5Rkv8GIudLTaqWVT2r7jZf53WbbHu7iOYxvg(KGV9E(wkyFGJ2t7jZf53WbNL9fmlu7O9K5I8B4GZYw5RkDwPimxKFlkjmyOno6Y7)MbyasxCDGHK9YJNLD49FlEwr4tcd6OwsYbV6EYCr(nCWzzR8vLYeQsfbNPNU90Xw0KP2TiE1fP0)uY(aUfzTCrm)RGalsPSz5H53lQI(Fr(kA4ISwUONDr8WS1xKsHpu6ls9)YIYgADgmTipI9b0ICgmYwFSNmxKFdhCw2xA(ukiaVAKFZqYEPXaP5vOHAkEGqdRaYu7eUVLzKFxlBO1zWK2xm3n7PJTOQRDeTiipGwetp)Iu5JfXRUOzfVIX8lQ6mRom)I(ErHpTOWa6uSOKDrvCGf(S8LfDBWiqslkHTstSiZfPgASNmxKFdhCw2kFvj03KVcHIhifQw2mKSxE8SSdwJe68gqMwdh8Q1uIK84zzhkaw4ZYxeSgbsAWRUNmxKFdhCw2kFvPZkfH5I8BrjHbdTXrxojCpDSfPuuQ7ViMhKpidMwu1nB5IMKbwK5I87ff)IaelGG(lQA)7WfPid)fnjdKT(Iym19dodq7jZf53WbNLTYxvYLTuajdWqYEfwH6yajdKTUOtD)GZa0GAZRqYAqvQueHb0Pao4YwkGKb0(mnginVcn4YwkGKbeo(4zzv(W51uI8Jb03KVcHIhifQw2JiDhLTEnL4(ViFf9GlBPh1scm4v3thBrmpGyjWIIFr8qArvRX1wKFVOQZS6W8lkzxK1mTOQ9VVOeUO(JfXRo2tMlYVHdolBLVQuACTf53m4yYviryaDkGxhyizVuIgdKMxHgwPiKFaf8Q7PJTOQ9BLMyr8qArvlP55bzRViMVy680Is2fX0ZViN1lsNIfLD8lsP)PK9bClkByqMKHf9GfLSlAsgiB9fXyQ7hCgGwucxuyfQdsUiRLlsrwklYpJfr9ZR7VOWa6uah7jZf53WbNLTYxvkjnppiBDHAX05jgCm5kKimGofWRdmKSxNbiwab9nVcvVE2qRZGjTRih)8AkrJbsZRqd1u8aHgwbKP2jCFlZi)U2zkjSc1XasgiBDrN6(bNbOb1MxHK1RFwyfQJbKmq26Io19dodqdQnVcjRPenginVcnGKbYwx0PUFWzas44JNL98Z3thBrmdiTiLUwl67fvrR2fLSlIPNFrYVvAIf1ejxu8lYzWyrvlP55bzRViMVy68edlYA5IcFcqlYa0IkeeUOW36fXClkmGofWf98XIo74lsrg(lY9TKpJZh7jZf53WbNLTYxvQ5tPW7lbdj7fuLkfryaDkGdUSLcizGkCgZPS7BjFgdzcHFBDiiN)tWb1MxHKNxlBO1zWufUQMJVNo2IygqArtFt(kwuf)bYk2IQwYc)fLSlk8PffgqNIfLWfzEpFSO4xKmPf9GfX0ZViFtdTOPVjFfSfJJweZdsi3IOBNpvvj5IuKH)IQUzl9OwsGf9Gfn9n5RGnPwUiZfPgASNmxKFdhCw2kFvj03KVcHIhifsYcFgCm5kKimGofWRdmKSxHb0Py4twj8hQUOcvDt96NPsXGnPwomxKAOAa(MyFGonG(M8vWwmosOcsi3GUD(uvLKNVNo2IygqArtEaGAjbwu8lQ6AYMGWf99ISffgqNIff(wSOeUi9pB9ff)IKjTilwu4tlcK6(XIIKJg7jZf53WbNLTYxvc5baQLeqeVGZKnbHm4yYviryaDkGxhyizVcdOtXisoseVqMufQ64184zzhA(uY(aUH8v07jZf53WbNLTYxvYLT0JAjbyizVKFm0yCQjiDI45D(JiDhLTETZolSc1XasgiBDrN6(bNbOb1MxHK1GQuPicdOtbCWLTuajdO9zAmqAEfAWLTuajdiC8XZYQ8HZpVED5hdOVjFfcfpqkuTShr6okB9Z3thBrmdiTiL(NYfD)baQJf9DHPfLSlYkLfvT)D4ImaTiZfPgArwlxu4tlkmGoflsX3knXIKjTijpiB9ff(0IC(w3uzSNmxKFdhCw2kFvPMpLI4baQdgs2RdmKSxAmqAEfAyLIq(buWRwtjE8SSdnFkzFa3GxTwyaDkgrYrI4fYK0M52thBrmdiTOzfVIvTlsrg(lI5TS9aKDebweZdTc3I47cbHlk8PffgqNIfPilLf5rlYJkVIfv1n3gxKhX(aArHpTi3)f5ROxK75i4I8m3r7jZf53WbNLTYxvc9n5RqO4bsHKSWNHK9cW3e7d0PHQLThGSJiGqfAfUbD78PQkjRPXaP5vOH8dOGxTwyaDkgrYrI4fQUqu1nAFM7)I8v0dOVjFfcfpqkKKf(djpWI8BL1DYZ3thBrmdiTiRuwKZ3a6eCrp7IM(M8vSOkkWG(lk7fzlc8kw03lAMTEHwuyaDkyyrpyrj7IcFArEpeUOeUiZ75Jff)IKjn2tMlYVHdolBLVQe6BYxHWbmOpdj7fuLkfryaDkGdOVjFfchWG(xhQDM7)I8v0dOVjFfchWG(dNVb0j41TQxxsE8SSdOVjFfchWG(cj5XZYo4vRx3Cr(9a6BYxHWbmO)iBbBj19J61ddOtXisoseVqMufC)xKVIEa9n5Rq4ag0FWYxkca58nGojIKJoVgWsPG0qDmmPeoYw7BDZE6ylIzaPfn9n5RyrvuGb9x03lQIwTlIVleeUOWNa0ImaTitkHlkB3ZLT(ypzUi)go4SSv(QsOVjFfchWG(mKSxalLcsd1XWKs4iBTV1n1GQuPicdOtbCa9n5Rq4ag0x7d7PJTiMbKwu1nB5IMKbwu8lY9nKNJwu1AGJw0D)Nx3pGlsf8o4I(ErvhM5TDSO7mZQLzUOk63SjGBrjCrHFcxucxKTi)u3NalsfKpidMwu4B9IaK8JiB9f99IQomZB7I47cbHlsAGJwu4)86(bCrjCrM3Zhlk(ffjhTONp2tMlYVHdolBLVQKlBPasgGHK96adj7fuLkfryaDkGdUSLcizaT1yG08k0GlBPasgq44JNLTMhpl7qAGJeH)ZR7hWbVkdoFl7RdmKDqaaVAisoosMwqxhyi7GaaE1qKSxr6ocQ9vv7PJTiMbKwu1nB5IUnumMwu8lY9nKNJwu1AGJw0D)Nx3pGlsf8o4I(ErZ7JfDNzwTmZfvr)MnbClkzxu4NWfLWfzlYp19jWIub5dYGPff(wViaj)iYwFr8DHGWfjnWrlk8FED)aUOeUiZ75Jff)IIKJw0Zh7jZf53WbNLTYxvYLTuWwmMyizV84zzhsdCKi8FED)ao4vRPXaP5vOH8dOGxLbNVL91bgYoiaGxnejhhjtlORdmKDqaaVAis2RiDhb1(QQAU)lYxrp08Pu49LyWRUNo2IUZmRwM5Iu6eizzArHb0PyrotDpzUi)go4SSv(QsUSLcVIbdgs2lnginVcnKFaf8Q1awkfKgQJb3RH4OogzRTZGHisos5BghVguLkfryaDkGdUSLcizGkWC7jZf53WbNLTYxvQX4utq6eXZ78zWXKRqIWa6uaVoWqYEbiwab9nVcvlmGofJi5ir8czsAZS1RFwyfQJbxcjatdQnVcjRj)ya9n5RqO4bsHQL9aqSac6BEf686194zzh8nlpOKTUqAGJAcch8Q7PJTOPk5sRSi33YmYVxu8lcgV6ICgmYwFrZkEfJ5x03l6zzvAfgqNc4Iu4t9IytD)iB9fDRf9GfX9aArWWChrYfX9EWfzTCr8WS1xeZdzY5NUfPui7JwK1YfXiZ8(IQUjKamn2tMlYVHdolBLVQe6BYxHqXdKcvlBgs2laXciOV5vOAHb0PyejhjIxitsBMRMscRqDm4sibyAqT5vizTWkuhdvito)0jkzF0GAZRqYAqvQueHb0Pao4YwkGKb0UQ90XwKsXePUOzfVIX8lIxDrFVidUioRzArHb0PaUidUi1hctVcXWIOBthPglsHp1lIn19JS1x0Tw0dwe3dOfbdZDejxe37bxKIm8xeZdzY5NUfPui7Jg7jZf53WbNLTYxvc9n5RqO4bsHQLndoMCfsegqNc41bgs2laXciOV5vOAHb0PyejhjIxitsBMRMscRqDm4sibyAqT5viznLCwyfQJbKmq26Io19dodqdQnVcjRbvPsregqNc4GlBPasgq7Z0yG08k0GlBPasgq44JNLv5dNFETZusyfQJHkKjNF6eLSpAqT5viz96NfwH6yOczY5Norj7JguBEfswdQsLIimGofWbx2sbKmqfUQ68Z3tMlYVHdolBLVQKlBPasgGHK96adj7fuLkfryaDkGdUSLcizaT1yG08k0GlBPasgq44JNLLbNVL91bgYoiaGxnejhhjtlORdmKDqaaVAis2RiDhb1(QQ9K5I8B4GZYw5Rk5Ywkylgtm48TSVoWq2bba8QHi54izAbDDGHSdca4vdrYEfP7iO2xvvZ9Fr(k6HMpLcVVedE19K5I8B4GZYw5RkH(M8viu8aPq1Ygh4aJb]] )


end
