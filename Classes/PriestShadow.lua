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

            interval = function () return 1.5 * state.haste * ( conduit.rabid_shadows.enabled and 0.8 or 1 ) end,
            value = function () return ( state.buff.surrender_to_madness.up and 12 or 6 ) end,
        },

        shadowfiend = {
            aura = "shadowfiend",

            last = function ()
                local app = state.buff.shadowfiend.expires - 15
                local t = state.query_time

                return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
            end,

            interval = function () return 1.5 * state.haste * ( conduit.rabid_shadows.enabled and 0.8 or 1 ) end,
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


    spec:RegisterPack( "Shadow", 20201011, [[dWKBjbqisbpssQUePqj2KKQprkumkuOofkKxraZcfClvkLAxk8lsrdtLIJPcwMKKNPsjtJuixtfHTHIIVHIsgNKu6CsIsRJuOAEsICpvY(KeoOKOQfsGEOKOYeLKIlQsPYgvPuWijfkPtQsPQvkP8svkfAMQuk6MQis7uLQFIIkgkkQ6PkAQQOUkkk1wLefFvfrSxi)LKbd1HPSys1JPYKj6YiBgL(mvz0uvNw0Qjfk1RvrA2sCBuz3s9BvnCcDCuuPLd65atx46OQTtk9DcA8Quk58OiRxfrnFvO9R0OdOZOP0ccDVQBQ6Md3C4WOQBU5whobAgmjsOPO5o18i0SnocnN(M8fIMIgtL3KOZOj45Hocn9JqeOX1utVm851hUNttqYXxSi)2bn2qtqY50en15ZsC7BKoAkTGq3R6MQU5WnhomQ6MBU1nml004d)hIMZKRYHM(PusnshnLeWHMvFXtFt(cxmZdtceBTQVyMJlEDcU4dhyyXvDtv3GMLeea0z0KaaQDeaDgD)a6mAAUi)gn5iUhYK6zvfExkvsizCa0KAtVqsKGOaDVk0z00Cr(nAQx(xQEwv4tkQjoMqtQn9cjrcIc09BHoJMMlYVrtpEdktRvpRYozc(HpAsTPxijsquGURrOZOj1MEHKibrthmdcMgAcePsrfg0JcWGlBPcqgCXvCT4Qw8XJlgAPurAPogMucgzV4kwmZCdAAUi)gnzFhpGKk7KjygKsNmouGUFc0z0KAtVqsKGOPdMbbtdnbIuPOcd6rbyWLTubidU4kUwCvl(4XfdTuQiTuhdtkbJSxCflMzUbnnxKFJMI8WKLPS9u6fdeOaDNzqNrtQn9cjrcIMMlYVrt33oQdOfKuXwmocnDWmiyAOzKC0IR01IpCZIpECXS8LIcsoFd6rQi5OfxPf75Kl(4Xfhg0JIrKCKkELmPfxPfFc0SKnPCs0Kzqb6oZcDgnnxKFJMWuuSqQSvarZrOj1MEHKibrb6E1IoJMMlYVrtizIz7PylghbqtQn9cjrcIc09kl6mAAUi)gnf(WIulLTcsGVT2rOj1MEHKibrb6(HBqNrtZf53Oz4tk(w)5BPI9HocnP20lKejikq3pCaDgnnxKFJMCe3dzs9SQcVlLkjKmoaAsTPxijsquGUFOk0z00Cr(nAQx(xQEwv4tkQjoMqtQn9cjrcIc09d3cDgnnxKFJME8guMwREwLDYe8dF0KAtVqsKGOaD)GgHoJMuB6fsIeenDWmiyAOjqKkfvyqpkadUSLkazWfxX1IRAXhpUyOLsfPL6yysjyK9IRyXmZnOP5I8B0K9D8asQStMGzqkDY4qb6(HtGoJMuB6fsIeenDWmiyAOjqKkfvyqpkadUSLkazWfxX1IRAXhpUyOLsfPL6yysjyK9IRyXmZnOP5I8B0uKhMSmLTNsVyGafO7hyg0z0KAtVqsKGOP5I8B009TJ6aAbjvSfJJqthmdcMgAgjhT4kDT4d3S4JhxmlFPOGKZ3GEKksoAXvAXEo5IpECXHb9OyejhPIxjtAXvAXNanlztkNenzguGUFGzHoJMMlYVrtykkwiv2kGO5i0KAtVqsKGOaD)q1IoJMMlYVrtizIz7PylghbqtQn9cjrcIc09dvw0z00Cr(nAk8HfPwkBfKaFBTJqtQn9cjrcIc09QUbDgnnxKFJMHpP4B9NVLk2h6i0KAtVqsKGOafOPKyn(sGoJUFaDgnnxKFJMGSqTJqtQn9cjrcIc09QqNrtQn9cjrcIMoygemn0uNNLDOx(xw4bXasMlw8XJlomOhfJi5iv8kzslUsxlUAVzXhpU4WGEum8jRe(drxS4kT4BDc00Cr(nAk(r(nkq3Vf6mAsTPxijsq08frtafOP5I8B0uRbttVqOPwRWtOP8JbW3KVqLWhkvIw2JiDNMT3IRVy5hdTgNyctNkEEN)is3Pz7HMAnOQnocnLFau8IOaDxJqNrtQn9cjrcIMViAcOannxKFJMAnyA6fcn1AfEcnLFma(M8fQe(qPs0YEeP70S9wC9fl)yO14ety6uXZ78hr6onBVfxFXYpgss7ZdZ2tjwmpEAeP70S9qtTgu1ghHMwPOKFau8IOaD)eOZOj1MEHKibrZxenbuGMMlYVrtTgmn9cHMATcpHMarQuuHb9Oam4YwQaKbxCflUk0uRbvTXrOjGmy2EQo98dodskhF8SSOaDNzqNrtQn9cjrcIMViAcOannxKFJMAnyA6fcn1AfEcnz8IfHjbIbGkSkXxibvzZYdYVx8XJlgY3e7d9OrimBG6zvHpPa8TseMeiiayqmx(uuKKlMrlU(IlKwQS4kUw8jQ2fxFXU)lYxypeFHeuLnlpi)EWlU4JhxmJxCH0sLfxPfFIQDXhpUynSyrysGyaOcRs8fsqv2S8G87fxFXAyXq(MyFOhncHzdupRk8jfGVvIWKabbadI5YNIIKCXmAX1xS7)I8f2dTFkveKxmYVh8IOPwdQAJJqtXu9qLwwfGP2PCFlZi)gfO7ml0z0KAtVqsKGOPdMbbtdn15zzhA)uY(qUbViAAUi)gnztiPx(xIc09QfDgnnxKFJM6eeqWtZ2dnP20lKejikq3RSOZOP5I8B0SKE(bqPXMx6XrDGMuB6fsIeefO7hUbDgnP20lKejiA6GzqW0qtDEw2H2pLSpKBWlIMMlYVrtRDeiGwr5SsbfO7hoGoJMMlYVrtDZt9SQaMUtbOj1MEHKibrb6(HQqNrtQn9cjrcIMMlYVrtNvkkZf53Qscc0SKGq1ghHMoHouGUF4wOZOj1MEHKibrtZf53OjKVvMlYVvLeeOzjbHQnocn5SSrbkqtri5EoDlqNr3pGoJMuB6fsIeefO7vHoJMuB6fsIeefO73cDgnP20lKejikq31i0z0KAtVqsKGOaD)eOZOP5I8B0u8J8B0KAtVqsKGOaDNzqNrtQn9cjrcIMoygemn0udlwNNLDa8n5lK9HCdEr00Cr(nAc8n5lK9HCOaDNzHoJMuB6fsIeenBJJqt7Kb(g0ak2Vd1ZQeFHeennxKFJM2jd8nObuSFhQNvj(cjikq3Rw0z0KAtVqsKGO5lIMakqtZf53OPwdMMEHqtTwHNqZdOPwdQAJJqtUSLkazqLJpEwwuGUxzrNrtZf53OPwJtmHPtfpVZhnP20lKejikqbA6e6qNr3pGoJMuB6fsIeen5bKsOFwiLZar2EO7hqtZf53OjGmy2EQo98dodsOPJjxHuHb9OaGUFanDWmiyAOjJxSwdMMEHgaYGz7P60Zp4miPC8XZYU46lwdlwRbttVqdXu9qLwwfGP2PCFlZi)EXmAXhpUygVy5hdGVjFHkHpuQeTShqIfsaFtVqlU(IbIuPOcd6rbyWLTubidU4kw8HfZiuGUxf6mAsTPxijsq0KhqkH(zHuodez7HUFannxKFJMaYGz7P60Zp4miHMoMCfsfg0Jca6(b00bZGGPHMHvOogaYGz7P60Zp4minO20lKCX1xS8JbW3KVqLWhkvIw2diXcjGVPxOfxFXarQuuHb9Oam4YwQaKbxCflUkuGUFl0z0KAtVqsKGO53fMuoHo08aAAUi)gn5YwQ0lgiqbkqtNeGoJUFaDgnP20lKejiA6GzqW0qtDEw2H2pLSpKBWlIMMlYVrtXxibvzZYdYVrb6EvOZOj1MEHKibrthmdcMgAc5BI9HE0aqI(8NmqjcFxX4Si)Eqmx(uuKKlU(Iz8Idd6rXibktkx8XJlws68SSdNbIS9gqYCXIzeAAUi)gnbzHAhHc09BHoJMMlYVrtwJuE8guMwdqtQn9cjrcIc0DncDgnP20lKejiA6GzqW0qZSbwNbtlUslUYEZIRVygVyTgmn9cnSsrj)aO4fx8XJlwNNLDO9tj7d5g8IlMrOP5I8B0KlBPNXrauGUFc0z0KAtVqsKGOPdMbbtdnHwkvKwQJHjLGr2lUIfx1nOP5I8B0KV9)ctQ(1AOaDNzqNrtQn9cjrcIMoygemn0udlwNNLDO9tj7d5g8IlU(I1WID)xKVWEO9tPIG8Ir(9GxCX1xmqKkfvyqpkadUSLkazWfxXIpS46lwdloSc1XaqgmBpvNE(bNbPb1MEHKl(4XfZ4fRZZYo0(PK9HCdEXfxFXarQuuHb9Oam4YwQaKbxCLwCvlU(I1WIdRqDmaKbZ2t1PNFWzqAqTPxi5Iz0IpECXmEX68SSdTFkzFi3GxCX1xCyfQJbGmy2EQo98dodsdQn9cjxmJqtZf53OP()T6zvHpPmGJAjjrb6oZcDgnP20lKejiAAUi)gnDwPOmxKFRkjiqZsccvBCeAsaa1ocGc09QfDgnnxKFJM8asLbXbqtQn9cjrcIcuGM6)3OZO7hqNrtQn9cjrcIMoygemn0eisLIkmOhfGbx2sfGm4IR01IVfAAUi)gnnGJAjjv6fdeOaDVk0z0KAtVqsKGOPdMbbtdnz8IbIuPOcd6rbyWLTubidU4kwCvlU(IdRqDmaKbZ2t1PNFWzqAqTPxi5IpECXmEXarQuuHb9Oam4YwQaKbxCfl(WIRVynS4WkuhdazWS9uD65hCgKguB6fsUygTygT46lgisLIkmOhfGHbCuljPQFT2IRyXhqtZf53OPbCuljPQFTgkqbAYzzJoJUFaDgnnxKFJMGSqTJqtQn9cjrcIc09QqNrtQn9cjrcIMoygemn0uNNLDO)FREwv4tkd4OwsYbViAccy6c09dOP5I8B00zLIYCr(TQKGanljiuTXrOP()nkq3Vf6mAAUi)gnLjqKkkoZlDOj1MEHKibrb6UgHoJMuB6fsIeenDWmiyAOPwdMMEHgIP6HkTSkatTt5(wMr(9IRV4SbwNbtlUIRfRr3GMMlYVrtTFkveKxmYVrb6(jqNrtQn9cjrcIMoygemn0uNNLDWAKYJ3GY0AWGxCX1xSgwSK05zzhcHw4ZYxuSgbtAWlIMMlYVrtGVjFHkHpuQeTSrb6oZGoJMuB6fsIeennxKFJMoRuuMlYVvLeeOzjbHQnocnDsakq3zwOZOj1MEHKibrthmdcMgAgwH6yaidMTNQtp)GZG0GAtVqYfxFXarQuuHb9Oam4YwQaKbxCflMXlwRbttVqdUSLkazqLJpEw2flWIpSygT46lwdlw(Xa4BYxOs4dLkrl7rKUtZ2BX1xSgwS7)I8f2dUSL6ulj4GxennxKFJMCzlvaYGOaDVArNrtQn9cjrcIMMlYVrtPX1wKFJMoygemn0udlwRbttVqdRuuYpakEr00XKRqQWGEuaq3pGc09kl6mAsTPxijsq00Cr(nAkjTppmBpLyX84j00bZGGPHMmEXqIfsaFtVql(4XfNnW6myAXvSyM1jwmJwC9fRHfR1GPPxOHyQEOslRcWu7uUVLzKFV46lMXlwdloSc1XaqgmBpvNE(bNbPb1MEHKl(4XfZ4fhwH6yaidMTNQtp)GZG0GAtVqYfxFXAyXAnyA6fAaidMTNQtp)GZGKYXhpl7Iz0IzeA6yYvivyqpkaO7hqb6(HBqNrtQn9cjrcIMoygemn0eisLIkmOhfGbx2sfGm4IR0Iz8I1OflWIDFl5Zyita4BRdf58FcmO20lKCXmAX1xC2aRZGPfxPRfxTNannxKFJMA)uQ0)sGc09dhqNrtQn9cjrcIMMlYVrtGVjFHkHpuQKKf(OPdMbbtdndd6rXWNSs4peDXIR0IR6MfF84Iz8IfPyWMulhMlsT0IRVyiFtSp0JgaFt(czlghPeHjGBqmx(uuKKlMrOPJjxHuHb9OaGUFafO7hQcDgnP20lKejiAAUi)gnb8qi1scQIxXzYMaa00bZGGPHMHb9OyejhPIxjtAXvAXvDIfxFX68SSdTFkzFi3q(cB00XKRqQWGEuaq3pGc09d3cDgnnxKFJMCzl1Pwsq0KAtVqsKGOaD)GgHoJMuB6fsIeenDWmiyAOPwdMMEHgwPOKFau8IlU(I1WI15zzhA)uY(qUbV4IRV4WGEumIKJuXRKjT4kwSgHMMlYVrtTFkvXdHuhOaD)WjqNrtQn9cjrcIMoygemn0eY3e7d9OHOLToKStjOseyfUbXC5trrsU46lwRbttVqd5hafV4IRV4WGEumIKJuXReDHQQBwCflMXl29Fr(c7bW3KVqLWhkvsYc)HKhAr(9IfyXEo5IzeAAUi)gnb(M8fQe(qPssw4Jc09dmd6mAsTPxijsq00bZGGPHMarQuuHb9Oama(M8fQCqd4V4RfFyX1xmJxS7)I8f2dGVjFHkh0a(dNVb9iWIVw8Tw8XJlws68SSdGVjFHkh0a(kjPZZYo4fx8XJl2Cr(9a4BYxOYbnG)iBfBj98JfF84Idd6rXisosfVsM0IR0ID)xKVWEa8n5lu5GgWFWYxkki58nOhPIKJwmJwC9fdTuQiTuhdtkbJSxCfl(w3GMMlYVrtGVjFHkh0a(OaD)aZcDgnP20lKejiA6GzqW0qtOLsfPL6yysjyK9IRyX36MfxFXarQuuHb9Oama(M8fQCqd4V4kw8b00Cr(nAc8n5lu5GgWhfO7hQw0z0KAtVqsKGOP5I8B0KlBPcqgenZoiiKxmujlAgP7uqfxvHMzheeYlgQKJJKPfeAEanDWmiyAOjqKkfvyqpkadUSLkazWfxXI1AW00l0GlBPcqgu54JNLDX1xSopl7qAWtvH)Z75hGbViA68TSrZdOaD)qLfDgnP20lKejiAAUi)gn5YwQylgtOz2bbH8IHkzrZiDNcQ4QQ6U)lYxyp0(PuP)LyWlIMzheeYlgQKJJKPfeAEanDWmiyAOPopl7qAWtvH)Z75hGbV4IRVyTgmn9cnKFau8IOPZ3YgnpGc09QUbDgnP20lKejiA6GzqW0qtTgmn9cnKFau8IlU(IHwkvKwQJb3RL4OogzV4kwSZaHksoAXcS4BgNyX1xmqKkfvyqpkadUSLkazWfxPfRrOP5I8B0KlBPsVyGafO7vDaDgnP20lKejiAAUi)gn1ACIjmDQ45D(OPdMbbtdnHelKa(MEHwC9fhg0JIrKCKkELmPfxXIzMfF84Iz8IdRqDm4sabzAqTPxi5IRVy5hdGVjFHkHpuQeTShqIfsaFtVqlMrl(4XfRZZYo4BwEyjBpL0GN2eam4frthtUcPcd6rbaD)akq3RQk0z0KAtVqsKGOPdMbbtdnHelKa(MEHwC9fhg0JIrKCKkELmPfxXI1OfxFXAyXHvOogCjGGmnO20lKCX1xCyfQJHiGjNF6uLSpDqTPxi5IRVyGivkQWGEuagCzlvaYGlUIfxfAAUi)gnb(M8fQe(qPs0YgfO7vDl0z0KAtVqsKGOP5I8B0e4BYxOs4dLkrlB00bZGGPHMqIfsaFtVqlU(Idd6rXisosfVsM0IRyXA0IRVynS4WkuhdUeqqMguB6fsU46lwdlMXloSc1XaqgmBpvNE(bNbPb1MEHKlU(IbIuPOcd6rbyWLTubidU4kwmJxSwdMMEHgCzlvaYGkhF8SSlwGfFyXmAXmAX1xmJxSgwCyfQJHiGjNF6uLSpDqTPxi5IpECXmEXHvOogIaMC(PtvY(0b1MEHKlU(IbIuPOcd6rbyWLTubidU4kDT4QwmJwmJqthtUcPcd6rbaD)akq3RsJqNrtQn9cjrcIMMlYVrtUSLkazq0m7GGqEXqLSOzKUtbvCvfAMDqqiVyOsoosMwqO5b00bZGGPHMarQuuHb9Oam4YwQaKbxCflwRbttVqdUSLkazqLJpEww005BzJMhqb6EvNaDgnP20lKejiAAUi)gn5YwQylgtOz2bbH8IHkzrZiDNcQ4QQ6U)lYxyp0(PuP)LyWlIMzheeYlgQKJJKPfeAEanD(w2O5buGUxfZGoJMMlYVrtGVjFHkHpuQeTSrtQn9cjrcIcuGc0ulbb53O7vDtv3CtLTkMbnfAWoBpaAE75eFyqYfZSwS5I87fxsqagBn0eiso09Qor1IMIWNnleAw9fp9n5lCXmpmjqS1Q(IzoU41j4IpCGHfx1nvDZwBRv9fF7UTihFqYfRtSpKwS750TyX6Kx2GXIR8ohjgGf3FFB7Bqow(YInxKFdw83fMgBnZf53GHiKCpNUfxSfdC6wZCr(nyicj3ZPBHaxAY(VCRzUi)gmeHK750TqGlnnEpoQdlYV3AvFXZ2eb(FSyOLYfRZZYsYfdclalwNyFiTy3ZPBXI1jVSbl2A5IfH0TT4hr2Eloblw(nn2AMlYVbdri5EoDle4stqBIa)puGWcWwZCr(nyicj3ZPBHaxAk(r(9wZCr(nyicj3ZPBHaxAc8n5lK9HCmKSxAqNNLDa8n5lK9HCdEXTM5I8BWqesUNt3cbU0KhqQmiogAJJUStg4BqdOy)oupRs8fsWTM5I8BWqesUNt3cbU0uRbttVqm0ghDXLTubidQC8XZYYWlEbOGbTwHNUoS1mxKFdgIqY9C6wiWLMAnoXeMov88o)T2wR6l(2DBro(GKlM0sqMwCKC0IdFAXMlE4ItWInTwwm9cn2AMlYVbxGSqTJ2AMlYVbcCPP4h53mKSx68SSd9Y)YcpigqYCXXJHb9OyejhPIxjtQsxv7nhpgg0JIHpzLWFi6IkDRtS1mxKFde4stTgmn9cXqBC0L8dGIxKHx8cqbdATcpDj)ya8n5luj8HsLOL9is3Pz7vx(XqRXjMW0PIN35pI0DA2EBnZf53abU0uRbttVqm0ghDzLIs(bqXlYWlEbOGbTwHNUKFma(M8fQe(qPs0YEeP70S9Ql)yO14ety6uXZ78hr6onBV6Ypgss7ZdZ2tjwmpEAeP70S92AMlYVbcCPPwdMMEHyOno6cqgmBpvNE(bNbjLJpEwwgEXlafmO1k80fqKkfvyqpkadUSLkazWkQARv9fxzmyA6fAXXVyGWmC(lwNcHe1lgWu7Y2BXU)lYxyVyEG5rlo(fZ8VqcU4BFZYdYVx8dxCL5t5IVDqEXi)EXssKAQLz7TyH(u4tWflctcekavyvIVqcQYMLhKFV4eS4SxmpGw8dxSqAXYV1yIf7BAPfl(cj4IZMLhKFV4czWMKJTM5I8BGaxAQ1GPPxigAJJUet1dvAzvaMANY9TmJ8BgEXlafmO1k80fJfHjbIbGkSkXxibvzZYdYVpEeY3e7d9OrimBG6zvHpPa8TseMeiiayqmx(uuKKmQEH0sLkUor1w39Fr(c7H4lKGQSz5b53dEXJhzCH0sLkDIQ94rnictcedavyvIVqcQYMLhKFxxdq(MyFOhncHzdupRk8jfGVvIWKabbadI5YNIIKKr1D)xKVWEO9tPIG8Ir(9GxCRzUi)giWLMSjK0l)lzizV05zzhA)uY(qUbV4wZCr(nqGln1jiGGNMT3wZCr(nqGlnlPNFauAS5LECuhBnZf53abU00AhbcOvuoRuyizV05zzhA)uY(qUbV4wZCr(nqGln1np1ZQcy6ofS1mxKFde4stNvkkZf53QsccgAJJUCcDBnZf53abU0eY3kZf53QsccgAJJU4SS3ABnZf53GHtcUeFHeuLnlpi)MHK9sNNLDO9tj7d5g8IBnZf53GHtce4stqwO2rmKSxq(MyFOhnaKOp)jduIW3vmolYVheZLpffjzDghg0JIrcuMuE8OK05zzhodez7nGK5cgT1mxKFdgojqGlnzns5XBqzAnyRzUi)gmCsGaxAYLT0Z4iadj7v2aRZGPkvzVPoJ1AW00l0WkfL8dGIx84rDEw2H2pLSpKBWlYOTM5I8BWWjbcCPjF7)fMu9R1yizVGwkvKwQJHjLGr2vu1nBnZf53GHtce4st9)B1ZQcFszah1ssYqYEPbDEw2H2pLSpKBWlwxdU)lYxyp0(PurqEXi)EWlwhisLIkmOhfGbx2sfGmyfhQRHWkuhdazWS9uD65hCgKguB6fsE8iJ15zzhA)uY(qUbVyDGivkQWGEuagCzlvaYGvQQ6AiSc1XaqgmBpvNE(bNbPb1MEHKm64rgRZZYo0(PK9HCdEX6HvOogaYGz7P60Zp4minO20lKKrBnZf53GHtce4stNvkkZf53QsccgAJJUiaGAhb2AvFXvdXA8LyXSwPOBUtxm7dxmpW0l0IZG4aA8fZSb0I)EXU)lYxyp2AMlYVbdNeiWLM8asLbXb2ABnZf53GH()9LbCuljPsVyGGHK9cisLIkmOhfGbx2sfGmyLUU1wZCr(nyO)FlWLMgWrTKKQ(1AmKSxmgisLIkmOhfGbx2sfGmyfvvpSc1XaqgmBpvNE(bNbPb1MEHKhpYyGivkQWGEuagCzlvaYGvCOUgcRqDmaKbZ2t1PNFWzqAqTPxijJyuDGivkQWGEuaggWrTKKQ(1AvCyRT1mxKFdgeaqTJaxCe3dzs9SQcVlLkjKmoWwZCr(nyqaa1ociWLM6L)LQNvf(KIAIJPTM5I8BWGaaQDeqGln94nOmTw9Sk7Kj4h(BnZf53Gbbau7iGaxAY(oEajv2jtWmiLozCmKSxarQuuHb9Oam4YwQaKbR4QQJhHwkvKwQJHjLGr2vWm3S1mxKFdgeaqTJacCPPipmzzkBpLEXabdj7fqKkfvyqpkadUSLkazWkUQ64rOLsfPL6yysjyKDfmZnBnZf53Gbbau7iGaxA6(2rDaTGKk2IXrmuYMuo5fZWqYEfjhvPRd3C8ilFPOGKZ3GEKksoQsEo5XJHb9OyejhPIxjtQsNyRzUi)gmiaGAhbe4stykkwiv2kGO5OTM5I8BWGaaQDeqGlnHKjMTNITyCeyRzUi)gmiaGAhbe4stHpSi1szRGe4BRD0wZCr(nyqaa1ociWLMHpP4B9NVLk2h6OT2wR6lMzdOfpjdMT3IVNE(bNbPfNSlMPNFXcZszX(zSyQFEp)fhg0JcWITwUyM)fsWfF7BwEq(9ITwU4kZNs2hYTydslU)yXqYKmXWIF4IJFXqIfsa)fppjACMFXFV4q4V4hUyUhslomOhfGXwZCr(ny4e6UaKbZ2t1PNFWzqIbEaPe6Nfs5mqKT31bgCm5kKkmOhfGRdmKSxmwRbttVqdazWS9uD65hCgKuo(4zzRRbTgmn9cnet1dvAzvaMANY9TmJ8BgD8iJLFma(M8fQe(qPs0YEajwib8n9cvhisLIkmOhfGbx2sfGmyfhy0wR6lE6)WyXvUe64ZyXtYGz7T47PNFWzqAXUVLzKFV44x8PejU45jrJZ8lMxCXzV4k)F72AMlYVbdNqNaxAcidMTNQtp)GZGed8asj0plKYzGiBVRdm4yYvivyqpkaxhyizVcRqDmaKbZ2t1PNFWzqAqTPxizD5hdGVjFHkHpuQeTShqIfsaFtVq1bIuPOcd6rbyWLTubidwrvBTQV4VlmPCcDlMZoLalo8PfBUi)EXFxyAX8atVqlwYdZ2BXoFRBQKT3ITwU4(JfBGfBlgsE8fdUyZf53JTM5I8BWWj0jWLMCzlv6fdem8DHjLtO76WwBRzUi)gmiaGAhbU4iUhYK6zvfExkvsizCGTM5I8BWGaaQDeqGln1l)lvpRk8jf1ehtBnZf53Gbbau7iGaxA6XBqzAT6zv2jtWp83AMlYVbdcaO2rabU0K9D8asQStMGzqkDY4yizVaIuPOcd6rbyWLTubidwXvvhpcTuQiTuhdtkbJSRGzUzRzUi)gmiaGAhbe4strEyYYu2Ek9Ibcgs2lGivkQWGEuagCzlvaYGvCv1XJqlLksl1XWKsWi7kyMB2AMlYVbdcaO2rabU009TJ6aAbjvSfJJyOKnPCYlMHHK9ksoQsxhU54rw(srbjNVb9ivKCuL8CYJhdd6rXisosfVsMuLoXwZCr(nyqaa1ociWLMWuuSqQSvarZrBnZf53Gbbau7iGaxAcjtmBpfBX4iWwZCr(nyqaa1ociWLMcFyrQLYwbjW3w7OTM5I8BWGaaQDeqGlndFsX36pFlvSp0rBTTM5I8BWGZY(cKfQD0wZCr(nyWzzlWLMoRuuMlYVvLeem0ghDP)FZaiGPlUoWqYEPZZYo0)VvpRk8jLbCulj5GxCRzUi)gm4SSf4stzcePIIZ8s3wR6lEYu7wmV4IRmFkzFi3ITwUyM)fsWfF7BwEq(9IRC)xKVWgSyRLl(zxmpiBVfFB(rLzXI)xwC2aRZGPfRtSpKwSZar2EJTM5I8BWGZY(s7Nsfb5fJ8Bgs2lTgmn9cnet1dvAzvaMANY9TmJ876zdSodMQ4sJUzRv9fFsTtPfd4H0Iz65xSiFSyEXfppjACMFXv(zLN5x83lo8Pfhg0JIfNSl(KaTWNLVS4BdgbtAXjO1yIfBUi1sJTM5I8BWGZYwGlnb(M8fQe(qPs0YMHK9sNNLDWAKYJ3GY0AWGxSUgKKopl7qi0cFw(II1iysdEXTM5I8BWGZYwGlnDwPOmxKFRkjiyOno6YjbBTQVynwtp)fZ8W8HzW0IpPzlx8Km4InxKFV44xmKyHeWFXvZFgSyHz4V4jzWS9w890Zp4miT1mxKFdgCw2cCPjx2sfGmidj7vyfQJbGmy2EQo98dodsdQn9cjRdePsrfg0JcWGlBPcqgScgR1GPPxObx2sfGmOYXhplRahyuDni)ya8n5luj8HsLOL9is3Pz7vxdU)lYxyp4YwQtTKGdEXTw1xmZdjwcU44xmpGwC1yCTf53lUYpR8m)It2fBntlUA(ZloblU)yX8IJTM5I8BWGZYwGlnLgxBr(ndoMCfsfg0JcW1bgs2lnO1GPPxOHvkk5hafV4wR6lUA(wJjwmpGwC1qAFEy2ElM5lMhpT4KDXm98l2z9I9OyXzh)IRmFkzFi3IZgeKjzyXpCXj7INKbZ2BX3tp)GZG0ItWIdRqDqYfBTCXcZszX(zSyQFEp)fhg0JcWyRzUi)gm4SSf4stjP95Hz7PelMhpXGJjxHuHb9OaCDGHK9IXqIfsaFtVqhpMnW6myQcM1jyuDnO1GPPxOHyQEOslRcWu7uUVLzKFxNXAiSc1XaqgmBpvNE(bNbPb1MEHKhpY4WkuhdazWS9uD65hCgKguB6fswxdAnyA6fAaidMTNQtp)GZGKYXhpllJy0wR6lMzdOfxzeCXFV4kx1S4KDXm98lw(TgtS4Mi5IJFXodelUAiTppmBVfZ8fZJNyyXwlxC4tqAXgKwCHaGfh(wVynAXHb9OaS4NpwmJpXIfMH)IDFl5ZGrJTM5I8BWGZYwGln1(PuP)LGHK9cisLIkmOhfGbx2sfGmyLySgjG7BjFgdzcaFBDOiN)tGb1MEHKmQE2aRZGPkDvTNyRv9fZSb0IN(M8fU4tYdLA8fxnKf(lozxC4tlomOhflobl20F(yXXVyzsl(HlMPNFX(MwAXtFt(czlghTyMhMaUftmx(uuKKlwyg(l(KMTuNAjbx8dx803KVq2KA5InxKAPXwZCr(nyWzzlWLMaFt(cvcFOujjl8zWXKRqQWGEuaUoWqYEfg0JIHpzLWFi6Ikv1nhpYyrkgSj1YH5IulvhY3e7d9ObW3KVq2IXrkryc4geZLpffjjJ2AvFXmBaT4jpesTKGlo(fFsnztaWI)EX2Idd6rXIdFlwCcwS3NT3IJFXYKwSflo8Pfdtp)yXrYrJTM5I8BWGZYwGlnb8qi1scQIxXzYMaagCm5kKkmOhfGRdmKSxHb9OyejhPIxjtQsvDI668SSdTFkzFi3q(c7TM5I8BWGZYwGln5YwQtTKGBTQVyMnGwCL5t5Ip)qi1XI)UW0It2fBLYIRM)myXgKwS5IulTyRLlo8Pfhg0JIfl8BnMyXYKwSKhMT3IdFAXoFRBQm2AMlYVbdolBbU0u7Nsv8qi1bdj71bgs2lTgmn9cnSsrj)aO4fRRbDEw2H2pLSpKBWlwpmOhfJi5iv8kzsvOrBTQVyMnGw88KOXRMflmd)fZ8w26qYoLGlM5bwHBX8DHaGfh(0Idd6rXIfMLYI1PfRtLx4IR6gnwwSoX(qAXHpTy3)f5lSxS75iWI1n3PBnZf53GbNLTaxAc8n5luj8HsLKSWNHK9cY3e7d9OHOLToKStjOseyfUbXC5trrswxRbttVqd5hafVy9WGEumIKJuXReDHQQBQGXU)lYxypa(M8fQe(qPssw4pK8qlYVfWZjz0wR6lMzdOfBLYID(g0Jal(zx803KVWfx5GgWFXzVyBXWx4I)EXZS9k0Idd6rbdl(HlozxC4tlw)bGfNGfB6pFS44xSmPXwZCr(nyWzzlWLMaFt(cvoOb8zizVaIuPOcd6rbya8n5lu5GgW)6qDg7(ViFH9a4BYxOYbnG)W5BqpcCDRJhLKopl7a4BYxOYbnGVss68SSdEXJhnxKFpa(M8fQCqd4pYwXwsp)44XWGEumIKJuXRKjvj3)f5lShaFt(cvoOb8hS8LIcsoFd6rQi5igvhAPurAPogMucgzxXTUzRv9fZSb0IN(M8fU4kh0a(l(7fx5QMfZ3fcawC4tqAXgKwSjLGfNT75Y2BS1mxKFdgCw2cCPjW3KVqLdAaFgs2lOLsfPL6yysjyKDf36M6arQuuHb9Oama(M8fQCqd4xXHTw1xmZgql(KMTCXtYGlo(f7(gWZrlUAm4Pl(S)Z75hGflcFhyXFV4kpZ52nw8zMt1WCwCL7B2eYT4eS4Wpblobl2wSF65tWflcZhMbtlo8TEXqs(rKT3I)EXvEMZTBX8DHaGfln4Plo8FEp)aS4eSyt)5Jfh)IJKJw8ZhBnZf53GbNLTaxAYLTubidYqYEDGHK9cisLIkmOhfGbx2sfGmyfAnyA6fAWLTubidQC8XZYwxNNLDin4PQW)598dWGxKbNVL91bgYoiiKxmujhhjtlORdmKDqqiVyOs2RiDNcQ4QQTw1xmZgql(KMTCX3gkgtlo(f7(gWZrlUAm4Pl(S)Z75hGflcFhyXFV455XIpZCQgMZIRCFZMqUfNSlo8tWItWITf7NE(eCXIW8HzW0IdFRxmKKFez7Ty(UqaWILg80fh(pVNFawCcwSP)8XIJFXrYrl(5JTM5I8BWGZYwGln5YwQylgtmKSx68SSdPbpvf(pVNFag8I11AW00l0q(bqXlYGZ3Y(6adzheeYlgQKJJKPf01bgYoiiKxmuj7vKUtbvCvvD3)f5lShA)uQ0)sm4f3AvFXNzovdZzXvgcMSmT4WGEuSyNjU1mxKFdgCw2cCPjx2sLEXabdj7LwdMMEHgYpakEX6qlLksl1XG71sCuhJSRWzGqfjhjWnJtuhisLIkmOhfGbx2sfGmyL0OTM5I8BWGZYwGln1ACIjmDQ45D(m4yYvivyqpkaxhyizVGelKa(MEHQhg0JIrKCKkELmPkyMJhzCyfQJbxciitdQn9cjRl)ya8n5luj8HsLOL9asSqc4B6fIrhpQZZYo4BwEyjBpL0GN2eam4f3AvFXtrYLwzXUVLzKFV44xmiEXf7mqKT3INNenoZV4Vx8ZYEBhg0JcWIf6t9Iztp)iBVfFRf)WfZ9qAXGWCNsYfZ96GfBTCX8GS9wmZdyY5NUfFBM9Pl2A5IVZCoV4tAciitJTM5I8BWGZYwGlnb(M8fQe(qPs0YMHK9csSqc4B6fQEyqpkgrYrQ4vYKQqJQRHWkuhdUeqqMguB6fswpSc1XqeWKZpDQs2NoO20lKSoqKkfvyqpkadUSLkazWkQARv9fFBKiXfppjACMFX8Il(7fBGfZzntlomOhfGfBGfl(aqQxigwmDB5iXyXc9PEXSPNFKT3IV1IF4I5EiTyqyUtj5I5EDWIfMH)IzEato)0T4BZSpDS1mxKFdgCw2cCPjW3KVqLWhkvIw2m4yYvivyqpkaxhyizVGelKa(MEHQhg0JIrKCKkELmPk0O6AiSc1XGlbeKPb1MEHK11aJdRqDmaKbZ2t1PNFWzqAqTPxizDGivkQWGEuagCzlvaYGvWyTgmn9cn4YwQaKbvo(4zzf4aJyuDgRHWkuhdrato)0PkzF6GAtVqYJhzCyfQJHiGjNF6uLSpDqTPxizDGivkQWGEuagCzlvaYGv6QkgXOTM5I8BWGZYwGln5YwQaKbzizVoWqYEbePsrfg0JcWGlBPcqgScTgmn9cn4YwQaKbvo(4zzzW5BzFDGHSdcc5fdvYXrY0c66adzheeYlgQK9ks3PGkUQARzUi)gm4SSf4stUSLk2IXedoFl7RdmKDqqiVyOsoosMwqxhyi7GGqEXqLSxr6ofuXvv1D)xKVWEO9tPs)lXGxCRzUi)gm4SSf4stGVjFHkHpuQeTSrbkqi]] )


end
