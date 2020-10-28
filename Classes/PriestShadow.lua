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
            duration = 10,
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

            spend = function () return ( talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * ( ( PTR and -8 or -7 ) - buff.empty_mind.stack ) * ( buff.surrender_to_madness.up and 2 or 1 ) end,
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

            spend = PTR and 30 or 35,
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
                    if buff.unfurling_darkness.up then
                        removeBuff( "unfurling_darkness" )
                    elseif debuff.unfurling_darkness_icd.down then
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

            breakchannel = function ()
                removeDebuff( "target", "void_torrent" )
            end,

            start = function ()
                applyDebuff( "target", "void_torrent" )
                applyDebuff( "target", "devouring_plague" )                
                if debuff.vampiric_touch.up then applyDebuff( "target", "vampiric_touch" ) end -- This should refresh/pandemic properly.
                if debuff.shadow_word_pain.up then applyDebuff( "target", "shadow_word_pain" ) end -- This should refresh/pandemic properly.
            end,

            tick = function ()
                if debuff.vampiric_touch.up then applyDebuff( "target", "vampiric_touch" ) end -- This should refresh/pandemic properly.
                if debuff.shadow_word_pain.up then applyDebuff( "target", "shadow_word_pain" ) end -- This should refresh/pandemic properly.
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


    spec:RegisterPack( "Shadow", 20201028, [[d40NqbqiijpIeLlrIQcBsc(KsvWOOiDkkkRIevLEffvZcQ4wqsf2Ls(LsrdJa5yqILPuYZiannckDncuBtPu13iaACkLY5irfRdsknpcO7bvTpkIdsayHkfEOsv0ejOQlsqf2iKurJuPkuojbv0kvQ8ssuv0mHKkDtsuLDsq(jbvAOkvPLQufQEketLe5QkLkBfsQ6RqsXEj6VOAWQCyHflrpwstMuxgzZq5ZeA0u40IwnjQQETsvnBkDBsA3k(nOHJshNGILd8CvnDQUok2oj8Di14vQc58qLwpjQ08Lq7xQLOivsIOdNKcTLG2sqOiOT22sqkhuuocw5irCCzjjcBu3pejjYeQKebXi0q0se2axlm0sLKipKbujjIH7SpQDZnft3GPCvHQB(PkJn8eovqG5B(PADtjsjtADHZrwkr0HtsH2sqBjiue0wBBjiLdkOGIYrIemUbeirqs19uIyKAnnYsjIM(Qerz9HyeAi6(2liP37DkRpHB1HLeOVT2go9TLG2sqseB((lvsIq)ttLEPssHqrQKejQEchjIkPcb4YHyCltn1CnGc1xIqtuAjTCdPlfAlPssKO6jCKiLwiuZHyC3G40qQ4krOjkTKwUH0LcjGsLKir1t4irezcGoJHdX4HYLaq3qIqtuAjTCdPlfsyLkjrOjkTKwUHePcsNazirEwYA5Eaej)xQ5O5pfG(mbFFB1xXI9bIuZjf04RqR)vo9zsFBVGKir1t4irWGvMN08q5sG0jEjfQsxkKGLkjrOjkTKwUHePcsNazirEwYA5Eaej)xQ5O5pfG(mbFFB1xXI9bIuZjf04RqR)vo9zsFBVGKir1t4iryzajgU5iYlTX7sxk02lvsIqtuAjTCdjsu9eosKkCQ04GWjnhZgQKePcsNazir8uL6tG47dfb1xXI9HXyTCavncGiX9uL6tG9jw19vSyFEaejF5PkXDixNuFcSpblrS5q8QwIS9sxkKauQKejQEchjcizzTeph(ZgvsIqtuAjTCdPlfABsLKir1t4irauWMJihZgQ0lrOjkTKwUH0LcPCKkjrIQNWrIGgcSAfuoCa9WjMkjrOjkTKwUH0LcHIGKkjrIQNWrI4geNzkHmJMJbbvsIqtuAjTCdPlDjIMWcgRlvskeksLKir1t4ir(0stLKi0eLwsl3q6sH2sQKeHMO0sA5gsKkiDcKHePKbdBvAHqTL59fGIQ3xXI95bqK8LNQe3HCDs9jq89Tnb1xXI95bqK8Lbfw3yXw9(eyFcOGLir1t4iryHEchPlfsaLkjrOjkTKwUHebYkrEYLir1t4irueGmkTKerryzijIg6R3i0q0C0qGMZg5S8SUFoI9vOpn0xkcv2eKvUdzQglpR7NJOerra4tOssen0FodR0LcjSsLKi0eLwsl3qIazLip5sKO6jCKikcqgLwsIOiSmKerd91BeAiAoAiqZzJCwEw3phX(k0Ng6lfHkBcYk3HmvJLN19ZrSVc9PH(stkGmGCe5S2qKHwEw3phrjIIaWNqLKiH1Y1q)5mSsxkKGLkjrOjkTKwUHebYkrEYLir1t4irueGmkTKerryzijYZswl3dGi5)snhn)Pa0Nj9jGsefbGpHkjrEka5iYNu0WvdaXRmoedt6sH2EPsseAIslPLBirGSsKNCjsu9eosefbiJsljruewgsIyAFSGKEF9KfJZcrtaEoymFcN(kwSpaZqyqGiTC058Cig3ni(ZmCwqsVt)ViHHjzzjDFM1xH(SKcY2Nj47tWBRVc9vHqRgIEwSq0eGNdgZNWzXW2xXI9zAFwsbz7tG9j4T1xXI9HQ(ybj9(6jlgNfIMa8CWy(eo9vOpu1hGzimiqKwo6CEoeJ7ge)zgoliP3P)xKWWKSSKUpZ6RqFvi0QHONLcyQ5eGH1t4SyyLikcaFcvsIWMCiGRaJ)4ovEfo60t4iDPqcqPsseAIslPLBirQG0jqgset7JfK07RNSyCwiAcWZbJ5t40xXI9bygcdcePLJoNNdX4UbXFMHZcs6D6)fjmmjllP7ZS(k0NLuq2(mbFFcEB9vOVsgmSflenb45GX8jCwmS9vSyFM2NLuq2(eyFcEB9vSyFOQpwqsVVEYIXzHOjaphmMpHtFf6dv9bygcdcePLJoNNdX4UbXFMHZcs6D6)fjmmjllP7ZS(k0xjdg2sbm1yqG6IHvIevpHJeblbuPfc1sxk02KkjrOjkTKwUHePcsNazirmTpwqsVVEYIXzHOjaphmMpHtFfl2hGzimiqKwo6CEoeJ7ge)zgoliP3P)xKWWKSSKUpZ6RqFwsbz7Ze89j4T1xH(kzWWwSq0eGNdgZNWzXW2xXI9zAFwsbz7tG9j4T1xXI9HQ(ybj9(6jlgNfIMa8CWy(eo9vOpu1hGzimiqKwo6CEoeJ7ge)zgoliP3P)xKWWKSSKUpZ6RqFLmyylfWuJbbQlgwjsu9eosKsc8ey)CeLUuiLJujjcnrPL0YnKivq6eidjYZswl3dGi5)YMIg(Zv(z0IQ049zc((2QVIf7Z0(qvFGi1Csbn(k06Fr7r57FFfl2hisnNuqJVcT(x50Nj9jafCFMjrIQNWrIytrd)5k)mArvACPlfcfbjvsIqtuAjTCdjsfKobYqIyAFSGKEF9KfJZcrtaEoymFcN(kwSpaZqyqGiTC058Cig3ni(ZmCwqsVt)ViHHjzzjDFM1xH(SKcY2Nj47tWBRVc9vYGHTyHOjaphmMpHZIHTVIf7Z0(SKcY2Na7tWBRVIf7dv9Xcs691twmolenb45GX8jC6RqFOQpaZqyqGiTC058Cig3ni(ZmCwqsVt)ViHHjzzjDFM1xH(kzWWwkGPgdcuxmSsKO6jCKiXuP3bHLxdRv6sHqbfPsseAIslPLBirIQNWrIudRLhvpHd3MVlrS578jujjsfDv6sHqzlPsseAIslPLBirIQNWrIaygEu9eoCB(UeXMVZNqLKiQrosx6sewavHQLHlvskeksLKi0eLwsl3qIubPtGmKiasnY57tG9jGcsqsKO6jCKiSq0eGJgc0CmiWtNrtsxk0wsLKi0eLwsl3qIubPtGmKiOQVsgmS1BeAiAmiqDXWkrIQNWrI8gHgIgdcuLUuibuQKeHMO0sA5gsKjujjsOCFJaephdoohIXzHOjGejQEchjsOCFJaephdoohIXzHOjG0LcjSsLKi0eLwsl3qIazLip5sKO6jCKikcqgLwsIOiSmKebfjIIaWNqLKiQ5O5pfaELXHyysxkKGLkjrIQNWrIOiuztqw5oKPAirOjkTKwUH0LUePIUkvskeksLKi0eLwsl3qIW8ehTrAjEnEphrPqOirIQNWrI8uaYrKpPOHRgasIuXTAjUharYFPqOirQG0jqgset7traYO0sRNcqoI8jfnC1aq8kJdXW6RqFOQpfbiJslTytoeWvGXFCNkVchD6jC6ZS(kwSpt7td91BeAiAoAiqZzJCwacdqVruAP(k03Zswl3dGi5)snhn)Pa0Nj9HsFMjDPqBjvsIqtuAjTCdjcZtC0gPL4149CeLcHIejQEchjYtbihr(KIgUAaijsf3QL4Eaej)LcHIePcsNazir8WsJVEka5iYNu0WvdaTOjkTKUVc9PH(6ncnenhneO5SrolaHbO3ikTuFf67zjRL7bqK8FPMJM)ua6ZK(2s6sHeqPsseAIslPLBirGJfxEfDvIGIejQEchjIAoAEPnEx6sxIu1VujPqOivsIqtuAjTCdjsfKobYqIuYGHTuatngeOUyyLir1t4iryHOjaphmMpHJ0LcTLujjcnrPL0YnKir1t4ir(0stLKivq6eidjcGzimiqKwpXAWOCFolawTHA4jCwKWWKSSKUVc9zAFEaejFLpp06(kwSppaIKV0ujdg2QgVNJ4cqr17Zmjsf3QL4Eaej)LcHI0LcjGsLKir1t4irWcIlYeaDgZlrOjkTKwUH0LcjSsLKi0eLwsl3qIevpHJernhTyOsVePcsNazirY5JjDC7tG9PCeuFf6Z0(ueGmkT0kSwUg6pNHTVIf7RKbdBPaMAmiqDXW2NzsKkUvlX9ais(lfcfPlfsWsLKi0eLwsl3qIubPtGmKiGi1Csbn(k06FLtFM03wcsIevpHJeHzmGwC5duriDPqBVujjcnrPL0YnKivq6eidjcQ6RKbdBPaMAmiqDXW2xH(qvFvi0QHONLcyQ5eGH1t4Syy7RqFplzTCpaIK)l1C08NcqFM0hk9vOpu1NhwA81tbihr(KIgUAaOfnrPL09vSyFM2xjdg2sbm1yqG6IHTVc99SK1Y9ais(VuZrZFka9jW(2QVc9HQ(8WsJVEka5iYNu0WvdaTOjkTKUpZ6RyX(mTVsgmSLcyQXGa1fdBFf6Zdln(6PaKJiFsrdxna0IMO0s6(mtIevpHJePechoeJ7gep(knAslDPqcqPsseAIslPLBirIQNWrIudRLhvpHd3MVlrS578jujjc9pnv6LUuOTjvsIevpHJeH5jE6K6lrOjkTKwUH0LUePechPssHqrQKeHMO0sA5gsKkiDcKHe5zjRL7bqK8FPMJM)ua6tG47taLir1t4irIVsJM08sB8U0LcTLujjcnrPL0YnKivq6eidjIP99SK1Y9ais(VuZrZFka9zsFB1xH(8WsJVEka5iYNu0WvdaTOjkTKUVIf7Z0(EwYA5Eaej)xQ5O5pfG(mPpu6RqFOQppS04RNcqoI8jfnC1aqlAIslP7ZS(mRVc99SK1Y9ais(VIVsJM08bQi6ZK(qrIevpHJej(knAsZhOIq6sxIOg5ivskeksLKi0eLwsl3qIubPtGmKiLmyyRsiC4qmUBq84R0Oj9IHvI8oiRUuiuKir1t4irQH1YJQNWHBZ3Li28D(eQKePechPlfAlPssKO6jCKi68zjlxneZQeHMO0sA5gsxkKakvsIqtuAjTCdjsfKobYqIOiazuAPfBYHaUcm(J7u5v4OtpHtFf6lNpM0XTptW3NWkijsu9eosefWuZjadRNWr6sHewPsseAIslPLBirQG0jqgsKsgmSfwqCrMaOZy(fdBFf6dv9PPsgmSfAq4gymwowqGKwmSsKO6jCKiVrOHO5OHanNnYr6sHeSujjcnrPL0YnKir1t4irQH1YJQNWHBZ3Li28D(eQKePQFPlfA7LkjrOjkTKwUHejQEchjIAoA(tbqIubPtGmKiEyPXxpfGCe5tkA4QbGw0eLws3xH(EwYA5Eaej)xQ5O5pfG(mPpt7traYO0sl1C08NcaVY4qmS(mVpu6ZS(k0hQ6td91BeAiAoAiqZzJCwEw3phX(k0hQ6RcHwne9SuZrxsJMalgwjsf3QL4Eaej)LcHI0LcjaLkjrOjkTKwUHejQEchjIouNWt4irQG0jqgseu1NIaKrPLwH1Y1q)5mSsKkUvlX9ais(lfcfPlfABsLKi0eLwsl3qIubPtGmKi58XKoU9jq89Tnb3xH(mTpt7Zdln(YGzejqoICfWuVOjkTKUVc99SK1Y9ais(VuZrZFka9jW(eCFM1xXI99SK1Y9ais(VuZrZFka9HVpu6Zmjsu9eosefWuZlHwx6sHuosLKi0eLwsl3qIevpHJertkGmGCe5S2qKHKivq6eidjIP9bima9grPL6RyX(Y5JjDC7ZK(eGcUpZ6RqFOQpfbiJslTytoeWvGXFCNkVchD6jC6RqFM2hQ6Zdln(6PaKJiFsrdxna0IMO0s6(kwSpt7Zdln(6PaKJiFsrdxna0IMO0s6(k0hQ6traYO0sRNcqoI8jfnC1aq8kJdXW6ZS(mtIuXTAjUharYFPqOiDPqOiiPsseAIslPLBirQG0jqgsKNLSwUharY)LAoA(tbOpb2NP9jS9zEFv4OzsFPZ)HtmoNQgq6x0eLws3Nz9vOVC(ysh3(ei((2MGLir1t4iruatnVeADPlfcfuKkjrOjkTKwUHejQEchjYBeAiAoAiqZ1u4gsKkiDcKHeX0(8ais(YGcRBSyREFcSVTeuFf67zjRL7bqK8FPMJM)ua6tG9jS9zwFfl2NP9Xs(clPrVIQNkO(k0hGzimiqKwVrOHOXSHkXzb5RUiHHjzzjDFMjrQ4wTe3dGi5VuiuKUuiu2sQKeHMO0sA5gsKO6jCKipdaqJMaChYvd9q)lrQG0jqgsepaIKV8uL4oKRtQpb23wcUVc9vYGHTuatngeOU0q0JePIB1sCpaIK)sHqr6sHqraLkjrOjkTKwUHePcsNazir0qFPiuztqw5oKPAS8SUFoI9vOpt7Z0(8WsJVEka5iYNu0WvdaTOjkTKUVc99SK1Y9ais(VuZrZFka9zsFM2NIaKrPLwQ5O5pfaELXHyy9zEFO0Nz9zwFfl2Ng6R3i0q0C0qGMZg5S8SUFoI9zMejQEchjIAo6sA0eq6sHqryLkjrOjkTKwUHejQEchjIcyQ5oeaOXLivq6eidjIIaKrPLwAO)Cg2(k0NharYxEQsChY1j1Nj9jS9vOVsgmSLcyQXGa1LgIE6RqFplzTCpaIK)l1C08NcqFcSpt7tW9zEFM2323NY3(8WsJVC057CighlCArtuAjDFM1NzsKkUvlX9ais(lfcfPlfcfblvsIqtuAjTCdjsfKobYqIaygcdcePfBKtjGI9jaN9dR6IegMKLL09vOpfbiJslT0q)5mS9vOppaIKV8uL4oKZwD(wcQpt6Z0(QqOvdrpR3i0q0C0qGMRPWnwAgq4jC6Z8(eR6(mtIevpHJe5ncnenhneO5AkCdPlfcLTxQKeHMO0sA5gsKkiDcKHe5zjRL7bqK8F9gHgIMxbXB0h((qPVc9zAFvi0QHON1BeAiAEfeVXQAear67dFFcyFfl2NMkzWWwVrOHO5vq8gCnvYGHTyy7RyX(IQNWz9gHgIMxbXBSYHJztrdVVIf7ZdGi5lpvjUd56K6tG9vHqRgIEwVrOHO5vq8glmgRLdOQraejUNQuFM1xH(arQ5KcA8vO1)kN(mPpbuqsKO6jCKiVrOHO5vq8gsxkekcqPsseAIslPLBirQG0jqgseqKAoPGgFfA9VYPpt6tafuFf67zjRL7bqK8F9gHgIMxbXB0Nj9HIejQEchjYBeAiAEfeVH0LcHY2KkjrOjkTKwUHejQEchjIAoA(tbqIuXTAjUharYFPqOirYXjaGH15jMeXZ6(Vj43sIKJtaadRZtvvsNHtseuKivq6eidjYZswl3dGi5)snhn)Pa0Nj9PiazuAPLAoA(tbGxzCigwFf6RKbdBPdW(C3aYiA4lgwjs1iYrIGI0LcHIYrQKeHMO0sA5gsKO6jCKiQ5O5y2axjsoobamSopXKiEw3)nb)wfQqOvdrplfWuZlHwFXWkrYXjaGH15PQkPZWjjcksKkiDcKHePKbdBPdW(C3aYiA4lg2(k0NIaKrPLwAO)Cgwjs1iYrIGI0LcTLGKkjrOjkTKwUHePcsNazirueGmkT0sd9NZW2xH(arQ5KcA8LkubPsJVYPpt6RgVZ9uL6Z8(e0sW9vOVNLSwUharY)LAoA(tbOpb2NWkrIQNWrIOMJMxAJ3LUuOTqrQKeHMO0sA5gsKO6jCKikcv2eKvUdzQgsKkiDcKHebqya6nIsl1xH(8ais(YtvI7qUoP(mPVTVVIf7Z0(8WsJVuZNa4UOjkTKUVc9PH(6ncnenhneO5SrolaHbO3ikTuFM1xXI9vYGHTygmgGnhrUoa7p0)lgwjsf3QL4Eaej)LcHI0LcT1wsLKi0eLwsl3qIubPtGmKiacdqVruAP(k0NharYxEQsChY1j1Nj9jS9vOpu1NhwA8LA(ea3fnrPL09vOppS04l2h3Qrw52C2FrtuAjDFf67zjRL7bqK8FPMJM)ua6ZK(2sIevpHJe5ncnenhneO5Srosxk0wcOujjcnrPL0YnKir1t4irEJqdrZrdbAoBKJePcsNaziraegGEJO0s9vOppaIKV8uL4oKRtQpt6ty7RqFOQppS04l18jaUlAIslP7RqFOQpt7Zdln(6PaKJiFsrdxna0IMO0s6(k03Zswl3dGi5)snhn)Pa0Nj9zAFkcqgLwAPMJM)ua4vghIH1N59HsFM1Nz9vOpt7dv95HLgFX(4wnYk3MZ(lAIslP7RyX(mTppS04l2h3Qrw52C2FrtuAjDFf67zjRL7bqK8FPMJM)ua6tG47BR(mRpZKivCRwI7bqK8xkeksxk0wcRujjcnrPL0YnKir1t4iruZrZFkasKkUvlX9ais(lfcfjsoobamSopXKiEw3)nb)wsKCCcayyDEQQs6mCsIGIePcsNazirEwYA5Eaej)xQ5O5pfG(mPpfbiJslTuZrZFka8kJdXWKivJihjcksxk0wcwQKeHMO0sA5gsKO6jCKiQ5O5y2axjsoobamSopXKiEw3)nb)wfQqOvdrplfWuZlHwFXWkrYXjaGH15PQkPZWjjcksKQrKJebfPlfARTxQKejQEchjYBeAiAoAiqZ1u4gseAIslPLBiDPqBjaLkjrIQNWrI8gHgIMJgc0C2ihjcnrPL0YnKU0LUerbb(eosH2sqBjiueekBtIGoatoIVer4uLfcCs3NaSVO6jC6ZMV)RENe5zPQuOTe82KiSaiwAjjIY6dXi0q09TxqsV37uwFc3QdljqFBTnC6BlbTLG6D9oL1NWXEevzCs3xjHbbuFvOAz49vsI58R(ea1kX6FFdCqDyeavmgBFr1t489bhlURExu9eo)IfqvOAz4MJFtwiAcWrdbAoge4PZOjCsm8asnY5fOakib17IQNW5xSaQcvld3C8B(gHgIgdcuXjXWJQsgmS1BeAiAmiqDXW27IQNW5xSaQcvld3C8BY8epDsfNjuj8HY9ncq8Cm44CigNfIMa9UO6jC(flGQq1YWnh)MkcqgLwcNjuj8Q5O5pfaELXHyy4azX)KJJIWYq4rP3fvpHZVybufQwgU543urOYMGSYDit1O317uwF7f6jC(Exu9eop(pT0uPExu9eoV543Kf6jCWjXWxYGHTkTqO2Y8(cqr1lw0dGi5lpvjUd56Kei(TjOIf9ais(YGcRBSyRUafqb37IQNW5nh)MkcqgLwcNjuj8AO)CgwCGS4FYXrryzi8AOVEJqdrZrdbAoBKZYZ6(5iwqd9LIqLnbzL7qMQXYZ6(5i27IQNW5nh)MkcqgLwcNjuj8H1Y1q)5mS4azX)KJJIWYq41qF9gHgIMJgc0C2iNLN19ZrSGg6lfHkBcYk3HmvJLN19ZrSGg6lnPaYaYrKZAdrgA5zD)Ce7Dr1t48MJFtfbiJslHZeQe(NcqoI8jfnC1aq8kJdXWWbYI)jhhfHLHW)SK1Y9ais(VuZrZFkaMiG9oL1hQpazuAP(CyFp60Rg9vsoAIM(ECNAoI9vHqRgIE6J5drQph23EHOjqFcNdgZNWPpiOpupm19jCayy9eo9PjwA05i2hAdYniqFSGKEN)KfJZcrtaEoymFcN(YVVC6J5P(GG(qt9PHZEW7Ziuq9XcrtG(YbJ5t40NLcWq6vVlQEcN3C8BQiazuAjCMqLWZMCiGRaJ)4ovEfo60t4GdKf)tookcldH3uwqsVVEYIXzHOjaphmMpHtXIaMHWGarA5OZ55qmUBq8Nz4SGKEN(FrcdtYYsAZkyjfK1e8cEBfQqOvdrplwiAcWZbJ5t4Syylw0ulPGScuWBRyruXcs691twmolenb45GX8jCkGkaZqyqGiTC058Cig3ni(ZmCwqsVt)ViHHjzzjTzfQqOvdrplfWuZjadRNWzXW27uwF7XJAg2V3fvpHZBo(nXsavAHqnojgEtzbj9(6jlgNfIMa8CWy(eoflcygcdcePLJoNNdX4UbXFMHZcs6D6)fjmmjllPnRGLuqwtWl4TvOKbdBXcrtaEoymFcNfdBXIMAjfKvGcEBflIkwqsVVEYIXzHOjaphmMpHtbubygcdcePLJoNNdX4UbXFMHZcs6D6)fjmmjllPnRqjdg2sbm1yqG6IHT3fvpHZBo(nljWtG9ZreNedVPSGKEF9KfJZcrtaEoymFcNIfbmdHbbI0YrNZZHyC3G4pZWzbj9o9)IegMKLL0MvWskiRj4f82kuYGHTyHOjaphmMpHZIHTyrtTKcYkqbVTIfrfliP3xpzX4Sq0eGNdgZNWPaQamdHbbI0YrNZZHyC3G4pZWzbj9o9)IegMKLL0MvOKbdBPaMAmiqDXW27uwFB3t9H6MIg(E47BhJwuLgVVeRp3GauFbG6BR(GG(uHaQppaIK)40he0xO1FFbGM9G33ZgONCe7ddc6tfcO(CJy6tak4F17IQNW5nh)M2u0WFUYpJwuLghNed)Zswl3dGi5)YMIg(Zv(z0IQ04MGFRIfnfvGi1Csbn(k06Fr7r57FXIGi1Csbn(k06FLJjcqbBwVlQEcN3C8BgtLEhewEnSwCsm8MYcs691twmolenb45GX8jCkweWmegeislhDophIXDdI)mdNfK070)lsyyswwsBwblPGSMGxWBRqjdg2IfIMa8CWy(eolg2Ifn1skiRaf82kwevSGKEF9KfJZcrtaEoymFcNcOcWmegeislhDophIXDdI)mdNfK070)lsyyswwsBwHsgmSLcyQXGa1fdBVlQEcN3C8BwdRLhvpHd3MVJZeQe(k6AVlQEcN3C8BcygEu9eoCB(ootOs4vJC6D9oL13Ek8FVlQEcNFv1pEwiAcWZbJ5t4GtIHVKbdBPaMAmiqDXW27uwFB3t9HKwAQuFWPV9u47ZH9XcG1(qiwdgL7E47BVay1gQHNWz17IQNW5xv9Bo(n)0stLWPIB1sCpaIK)4rbNedpGzimiqKwpXAWOCFolawTHA4jCwKWWKSSKUGPEaejFLpp06If9ais(stLmyyRA8EoIlafv3SExu9eo)QQFZXVjwqCrMaOZy(Exu9eo)QQFZXVPAoAXqLECQ4wTe3dGi5pEuWjXWNZht64kqLJGkyQIaKrPLwH1Y1q)5mSflwYGHTuatngeOUyynR3fvpHZVQ63C8BYmgqlU8bQiWjXWdIuZjf04RqR)voMSLG6Dr1t48RQ(nh)MLq4WHyC3G4XxPrtACsm8OQKbdBPaMAmiqDXWwavvi0QHONLcyQ5eGH1t4Syyl8SK1Y9ais(VuZrZFkaMGsbu5HLgF9uaYrKpPOHRgaArtuAjDXIMwYGHTuatngeOUyyl8SK1Y9ais(VuZrZFkacCRcOYdln(6PaKJiFsrdxna0IMO0sAZkw00sgmSLcyQXGa1fdBbpS04RNcqoI8jfnC1aqlAIslPnR3fvpHZVQ63C8BwdRLhvpHd3MVJZeQeE6FAQ037uwFcpHfmwVpSWAlJ6(9Hbb9X8rPL6lDs9rT9TDp1hC6RcHwne9S6Dr1t48RQ(nh)MmpXtNu)ExVtz9ja2lQBFoSpMN6dTbn9Tbeo9bX6ZnO(eaFLgnP7l)(IQNkOExu9eo)Qech8XxPrtAEPnEhNed)Zswl3dGi5)snhn)Paiq8cyVlQEcNFvcHJ543m(knAsZhOIaNedVPplzTCpaIK)l1C08NcGjBvWdln(6PaKJiFsrdxna0IMO0s6Ifn9zjRL7bqK8FPMJM)uambLcOYdln(6PaKJiFsrdxna0IMO0sAZmRWZswl3dGi5)k(knAsZhOIWeu6D9oL13gycG(eo(NMk99Hbb9TxaH6Gn8QrVtz9j8KLCQp3i)(cmNa9HyeAiABm6VpBWmvJExu9eo)I(NMk94vjviaxoeJBzQPMRbuO(9UO6jC(f9pnv6nh)MLwiuZHyC3G40qQ427IQNW5x0)0uP3C8BkYeaDgdhIXdLlbGUrVlQEcNFr)ttLEZXVjgSY8KMhkxcKoXlPqfNed)Zswl3dGi5)snhn)Payc(TkweePMtkOXxHw)RCmz7fuVlQEcNFr)ttLEZXVjldiXWnhrEPnEhNed)Zswl3dGi5)snhn)Payc(TkweePMtkOXxHw)RCmz7fuVlQEcNFr)ttLEZXVzfovACq4KMJzdvchBoeVQXV94Ky49uLeiEueuXIymwlhqvJaisCpvjbkw1fl6bqK8LNQe3HCDscuW9UO6jC(f9pnv6nh)MGKL1s8C4pBuPExu9eo)I(NMk9MJFtafS5iYXSHk99UO6jC(f9pnv6nh)MOHaRwbLdhqpCIPs9UO6jC(f9pnv6nh)MUbXzMsiZO5yqqL6D9oL13EgV3hQXiTuF7z8EoI9fvpHZV6dH8(cVpJu0Ga9XcsiiDC7ZH99gqG3xnbvM07lhNaagwVVkC0PNW57do9P8Yr3hcfGnrDAdC7DkRVT7P(qOaKJyFcLIgUAaO(sS(WfY0h60A7Zi9(ObYiA0NharY)(Ir33EHOjqFcNdgZNWPVy09H6HPgdcu7lauFd07dqHgxC6dc6ZH9bima9g9HGAqT7Tp40NJg2he0Nkeq95bqK8F17IQNW5xv0v8pfGCe5tkA4QbGWH5joAJ0s8A8EoI4rbNkUvlX9ais(JhfCsm8MQiazuAP1tbihr(KIgUAaiELXHyyfqLIaKrPLwSjhc4kW4pUtLxHJo9eoMvSOPAOVEJqdrZrdbAoBKZcqya6nIslv4zjRL7bqK8FPMJM)uambfZ6DkRpediW7BptqLj9(qOaKJyFcLIgUAaO(QWrNEcN(CyF7teBFiOgu7E7JHTVC6taafo6Dr1t48Rk6Q5438PaKJiFsrdxnaeompXrBKwIxJ3Zrepk4uXTAjUharYF8OGtIH3dln(6PaKJiFsrdxna0IMO0s6cAOVEJqdrZrdbAoBKZcqya6nIslv4zjRL7bqK8FPMJM)uamzRENY6dowC5v01(uJ9PVp3G6lQEcN(GJf3(y(O0s9Pza5i2x1iMHS5i2xm6(gO3x89f9birgBa6lQEcNvVlQEcNFvrxnh)MQ5O5L24DCGJfxEfDfpk9UENY6t5f50NayVOU403BazS6(QqfeOVWA7deJi99bX6ZdGi5FFXO77R0eGe(9UO6jC(LAKJ543SgwlpQEchUnFhNjuj8Lq4GZ7GS64rbNedFjdg2QechoeJ7gep(knAsVyy7Dr1t48l1ihZXVPoFwYYvdXS27uwFi4o1(yy7d1dtngeO2xm6(2lenb6t4CWy(eo9TNqOvdrpFFXO7dI1hZNJyFOUqh13hleA7lNpM0XTVscdcO(QX75iU6Dr1t48l1ihZXVPcyQ5eGH1t4GtIHxraYO0sl2KdbCfy8h3PYRWrNEcNc58XKoUMGxyfuVtz9P8I9P(Ega1hUqM(yz8(yy7db1GA3BFcaebWE7do95guFEaejVVeRpudiCdmgBFOodcKuF5p7bVVO6PcA17IQNW5xQroMJFZ3i0q0C0qGMZg5GtIHVKbdBHfexKja6mMFXWwavAQKbdBHgeUbgJLJfeiPfdBVlQEcNFPg5yo(nRH1YJQNWHBZ3XzcvcFv)9oL13ESu0OV9csiiDC7t5LJUpeka9fvpHtFoSpaHbO3OpHhQ03h60n67PaKJiFsrdxnauVlQEcNFPg5yo(nvZrZFka4uXTAjUharYF8OGtIH3dln(6PaKJiFsrdxna0IMO0s6cplzTCpaIK)l1C08NcGjMQiazuAPLAoA(tbGxzCigM5OywbuPH(6ncnenhneO5SrolpR7NJybuvHqRgIEwQ5OlPrtGfdBVtz9TxaHrG(CyFmp1NWhQt4jC6taGia2BFjwFXGBFcpuP(YVVb69XWU6Dr1t48l1ihZXVPouNWt4Gtf3QL4Eaej)XJcojgEuPiazuAPvyTCn0FodBVtz9TDp1hQhM6(2aA9(cVpJu0Ga9XcsiiDC7dD6g9ThJzejqoI9H6HPUpg2(CyFcBFEaej)XPpiOpOBqG(8WsJ)9bN(quA17IQNW5xQroMJFtfWuZlHwhNedFoFmPJRaXVnbxWut9WsJVmygrcKJixbm1lAIslPl8SK1Y9ais(VuZrZFkacuWMvS4Zswl3dGi5)snhn)PaGhfZ6DkRpHho7bVpMN6t4jfqgqoI9TxBiYq9Ly9HlKPVAm9jsEF54W(q9WuJbbQ9LZ7uOXPpiOVeRpeka5i2NqPOHRgaQV87ZdlnoP7lgDFOtRTpJ07JgiJOrFEaej)x9UO6jC(LAKJ543utkGmGCe5S2qKHWPIB1sCpaIK)4rbNedVPacdqVruAPIfZ5JjDCnrakyZkGkfbiJslTytoeWvGXFCNkVchD6jCkykQ8WsJVEka5iYNu0WvdaTOjkTKUyrt9WsJVEka5iYNu0WvdaTOjkTKUaQueGmkT06PaKJiFsrdxnaeVY4qmmZmR3PS(2UN6d1VrFWPV9u47lX6dxitFA4Sh8(gI095W(QX79j8KcidihX(2RneziC6lgDFUbbO(ca1NL(Vp3iM(e2(8ais(3hKX7Zub3h60n6Rchnt6MT6Dr1t48l1ihZXVPcyQ5LqRJtIH)zjRL7bqK8FPMJM)uaeOPcR5v4OzsFPZ)HtmoNQgq6x0eLwsBwHC(yshxbIFBcU3PS(2UN6dXi0q09HAGanQTpHNc3OVeRp3G6ZdGi59LFFrjKX7ZH9PtQpiOpCHm9zekO(qmcnenMnuP(2liF1(iHHjzzjDFOt3OpLxo6sA0eOpiOpeJqdrJL0O7lQEQGw9UO6jC(LAKJ5438ncnenhneO5AkCdCQ4wTe3dGi5pEuWjXWBQharYxguyDJfB1f4wcQWZswl3dGi5)snhn)PaiqH1SIfnLL8fwsJEfvpvqfamdHbbI06ncnenMnujoliF1fjmmjllPnR3PS(2UN6dHbaOrtG(CyFkVqp0)9bN(I(8aisEFUr49LFFIWCe7ZH9PtQVW7ZnO(aPOH3NNQ0Q3fvpHZVuJCmh)MpdaqJMaChYvd9q)Jtf3QL4Eaej)XJcojgEpaIKV8uL4oKRtsGBj4cLmyylfWuJbbQlne907IQNW5xQroMJFt1C0L0OjaojgEn0xkcv2eKvUdzQglpR7NJybtn1dln(6PaKJiFsrdxna0IMO0s6cplzTCpaIK)l1C08NcGjMQiazuAPLAoA(tbGxzCigM5OyMzflQH(6ncnenhneO5SrolpR7NJOz9oL1329uFOEyQ7tjiaqJ3hCS42xI1hcQb1U3(Ir3hQxP(ca1xu9ub1xm6(CdQppaIK3hA4Sh8(0j1NMbKJyFUb1x1iMHSRExu9eo)snYXC8BQaMAUdbaACCQ4wTe3dGi5pEuWjXWRiazuAPLg6pNHTGharYxEQsChY1jzIWwOKbdBPaMAmiqDPHONcplzTCpaIK)l1C08NcGanvWMB62R81dln(YrNVZHyCSWPfnrPL0MzwVtz9TDp1hcQb1k89HoDJ(2BKtjGI9jqF79dRAFmJL(Vp3G6ZdGi59HoT2(kP(kjleDFBjiLp6RKWGaQp3G6RcHwne90xfQsFFLrD)Exu9eo)snYXC8B(gHgIMJgc0CnfUbojgEaZqyqGiTyJCkbuSpb4SFyvxKWWKSSKUGIaKrPLwAO)Cg2cEaejF5PkXDiNT68TeKjMwHqRgIEwVrOHO5OHanxtHBS0mGWt4yUyvBwVtz9TDp1xyT9vncGi99bX6dXi0q09TNG4n6lN(I(aq09bN(qYr0s95bqKCC6dc6lX6ZnO(kH)3x(9fLqgVph2NoPvVlQEcNFPg5yo(nFJqdrZRG4nWjXW)SK1Y9ais(VEJqdrZRG4nWJsbtRqOvdrpR3i0q08kiEJv1iaI0JxalwutLmyyR3i0q08kiEdUMkzWWwmSflgvpHZ6ncnenVcI3yLdhZMIgEXIEaejF5PkXDixNKaRqOvdrpR3i0q08kiEJfgJ1Ybu1iaIe3tvYScGi1Csbn(k06FLJjcOG6DkRVT7P(qmcneDF7jiEJ(GtF7PW3hZyP)7Znia1xaO(cT(7lNkunhXvVlQEcNFPg5yo(nFJqdrZRG4nWjXWdIuZjf04RqR)voMiGcQWZswl3dGi5)6ncnenVcI3Weu6DkRVT7P(uE5O7dHcqFoSVkCEgvQpHpa73Nsgqgrd)7JfaRFFWPpbGWv4y1NscxHx423EchSeO2x(95g53x(9f9zKIgeOpwqcbPJBFUrm9bin09Ce7do9jaeUch9Xmw6)(0by)(CdiJOH)9LFFrjKX7ZH95Pk1hKX7Dr1t48l1ihZXVPAoA(tbaNkUvlX9ais(JhfCsm8plzTCpaIK)l1C08NcGjkcqgLwAPMJM)ua4vghIHvOKbdBPdW(C3aYiA4lgwCQgro4rbNCCcayyDEQQs6mCcpk4KJtaadRZtm8Ew3)nb)w9oL1329uFkVC09H60g42Nd7RcNNrL6t4dW(9PKbKr0W)(ybW63hC6drPvFkjCfEHBF7jCWsGAFjwFUr(9LFFrFgPObb6JfKqq642NBetFasdDphX(ygl9FF6aSFFUbKr0W)(YVVOeY495W(8uL6dY49UO6jC(LAKJ543unhnhZg4ItIHVKbdBPdW(C3aYiA4lg2ckcqgLwAPH(ZzyXPAe5GhfCYXjaGH15PQkPZWj8OGtoobamSopXW7zD)3e8BvOcHwne9SuatnVeA9fdBVtz9PKWv4fU9H6jqIHBFEaejVVAW27IQNW5xQroMJFt1C08sB8oojgEfbiJslT0q)5mSfarQ5KcA8LkubPsJVYXKA8o3tvYCbTeCHNLSwUharY)LAoA(tbqGcBVlQEcNFPg5yo(nveQSjiRChYunWPIB1sCpaIK)4rbNedpGWa0BeLwQGharYxEQsChY1jzY2xSOPEyPXxQ5taCx0eLwsxqd91BeAiAoAiqZzJCwacdqVruAjZkwSKbdBXmymaBoICDa2FO)xmS9oL1hclvZW2xfo60t40Nd77DiBF149Ce7db1GA3BFWPpiggQdpaIK)9H2GM(WsrdphX(eW(GG(uHaQV3J6(KUpvy53xm6(y(Ce7BVpUvJS2hQBo73xm6(es4QuFkV8jaURExu9eo)snYXC8B(gHgIMJgc0C2ihCsm8acdqVruAPcEaejF5PkXDixNKjcBbu5HLgFPMpbWDrtuAjDbpS04l2h3Qrw52C2FrtuAjDHNLSwUharY)LAoA(tbWKT6DkRpLpjITpeudQDV9XW2hC6l((uJb3(8ais(3x89Xc)plTeo9r7rvI17dTbn9HLIgEoI9jG9bb9PcbuFVh19jDFQWYVp0PB03EFCRgzTpu3C2F17IQNW5xQroMJFZ3i0q0C0qGMZg5Gtf3QL4Eaej)XJcojgEaHbO3ikTubpaIKV8uL4oKRtYeHTaQ8WsJVuZNa4UOjkTKUaQm1dln(6PaKJiFsrdxna0IMO0s6cplzTCpaIK)l1C08NcGjMQiazuAPLAoA(tbGxzCigM5OyMzfmfvEyPXxSpUvJSYT5S)IMO0s6Ifn1dln(I9XTAKvUnN9x0eLwsx4zjRL7bqK8FPMJM)uaei(TmZSExu9eo)snYXC8BQMJM)uaWPIB1sCpaIK)4rbNed)Zswl3dGi5)snhn)PayIIaKrPLwQ5O5pfaELXHyy4unICWJco54eaWW68uvL0z4eEuWjhNaagwNNy49SU)Bc(T6Dr1t48l1ihZXVPAoAoMnWfNQrKdEuWjhNaagwNNQQKodNWJco54eaWW68edVN19FtWVvHkeA1q0Zsbm18sO1xmS9oL1329uFiOguRW3x89zJ37dqpe49Ly9bN(CdQpvOcQ3fvpHZVuJCmh)MVrOHO5OHanxtHB07uwFB3t9HGAqT7TV47ZgV3hGEiW7lX6do95guFQqfuFXO7db1GAf((YVp403Ek89UO6jC(LAKJ5438ncnenhneO5Srosx6sja]] )


end
