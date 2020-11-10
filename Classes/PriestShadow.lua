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
            cast = 4.5,
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


        shadow_crash = PTR and {
            id = 205385,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = -20,
            spendType = "insanity",

            startsCombat = true,
            texture = 136201,
        } or {
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


    spec:RegisterPack( "Shadow", 20201106, [[d4uKobqiLQ8iuv1LukLGnjQ8juvPgLOOtjkSkLsj6vIsMfKYTGes2Ls(LsrddvkhdsAzkL8mujzAOcCnuH2gQu13qLunoLs15GefRdseZdvI7Hc7tuQdcjQwOsHhcjstevQCrirPncjKAKkLsLtIkP0kvQ8sLsPQzIkP4MOQs2jQOFcjedfsWsvkLqpfIPIQYvvkfBfvv4Rqc1Ej8xIgSkhwyXs4XsAYK6YiBgkFMeJwIonvRwPukVwPQMTi3MK2Tu)g0WrPJJkOLd8CvnDkxhQ2oQY3rrJxPusNhs16rvfnFrv7xXcuf8jq0Hrco3IBBXnurLBC)ART4kUNd4OaXqNLeiSrD)qHeiDOsceKYqdzkqyd0tWql4tG8qCqLeiLMX(OKn3uXTs8IvfQU57Q4PWCyxbbMT57Q1nfif4EY4ABrHarhgj4ClUTf3qfvUX9RT2IR4EoqGe4wjeiqqCvuQaP01AQffcen9vbc)NdPm0qMZHcaNEB2X)54eYJuliWCCpAZTf32IBcKK)2l4tGq)tDLEbFcorvWNajQMdBbIkPcbOlHyYeE11snGc1xGqDuKiTydHj4ClbFcKOAoSfifjiulHysRKKutQOlqOoksKwSHWeCYvc(eir1CylquWdG2JwcXKb)KaqRuGqDuKiTydHj4Kde8jqOoksKwSHaPcCJaEiqEwkLKwaui7xQERLpfG5YMXCBnx(8ZbcxljEuBRqR)L3ZL9CCp3eir1CylqWGv8N0YGFsa3izbfQctWjhf8jqOoksKwSHaPcCJaEiqEwkLKwaui7xQERLpfG5YMXCBnx(8ZbcxljEuBRqR)L3ZL9CCp3eir1CylqyXbog6ERilsXBctWj3l4tGqDuKiTydbsunh2cKkSRuBGWiTelfQKaPcCJaEiqmxLMJlmMdvUnx(8ZHHNssavldGcjnxLMJlZPu1ZLp)CwauiBzUkjnOu70CCzookqsEtYQwGW9ctWjxxWNajQMdBbcWzztK0B5ZgvsGqDuKiTydHj4C7c(eir1CylqauW6TIelfQ0lqOoksKwSHWeCIYi4tGevZHTaHjeK08iVLa6HD0vsGqDuKiTydHj4evUj4tGevZHTaXkjjExaXBTedcQKaH6OirAXgctycenHf4jtWNGtuf8jqIQ5WwG8EI6kjqOoksKwSHWeCULGpbc1rrI0IneivGBeWdbsbog2QibH6e(BlafvBU85NZcGczlZvjPbLANMJlmMB7CBU85NZcGczRsksw5ITAZXL54kokqIQ5WwGWcnh2ctWjxj4tGqDuKiTydbcKvG8KjqIQ5WwGWlaEuKibcViHtcen0wFzOHmLmHaTKn8EzEDFVvMl3CAOT4fQSoWRsdIxlxMx33BfbcVai7qLeiAO9sCwHj4Kde8jqOoksKwSHabYkqEYeir1Cylq4fapksKaHxKWjbIgARVm0qMsMqGwYgEVmVUV3kZLBon0w8cvwh4vPbXRLlZR77TYC5MtdTLM4bXbERiztHcoTmVUV3kceEbq2HkjqIusQH2lXzfMGtok4tGqDuKiTydbcKvG8KjqIQ5WwGWlaEuKibcViHtcKNLsjPfafY(LQ3A5tbyUSNJRei8cGSdvsG8ua8wr2UsPPgaswXnigMWeCY9c(eiuhfjsl2qGazfipzcKOAoSfi8cGhfjsGWls4KajZ5ybo926PeMKfYKasVXWFh2ZLp)Ca8MWGafAzm9(LqmPvsYhVLSaNEJ(FrCiUZYs65YyUCZLiEuAUSzmhh3(C5MRcHjnKzVyHmjG0Bm83H9cNDU85NlZ5sepknhxMJJBFU85NBV5ybo926PeMKfYKasVXWFh2ZLBU9MdG3egeOqlJP3VeIjTss(4TKf40B0)lIdXDwwspxgZLBUkeM0qM9Ih01scGZAoSx4SceEbq2HkjqyDjei5HjF07QScBTBoSfMGtUUGpbc1rrI0IneivGBeWdbsMZXcC6T1tjmjlKjbKEJH)oSNlF(5a4nHbbk0Yy69lHysRKKpElzbo9g9)I4qCNLL0ZLXC5Mlr8O0CzZyooU95Ynxbog2IfYKasVXWFh2lC25YNFUmNlr8O0CCzooU95YNFU9MJf40BRNsyswitci9gd)DypxU52BoaEtyqGcTmME)siM0kj5J3swGtVr)Vioe3zzj9CzmxU5kWXWw8GUgdcux4ScKOAoSfiyoGksqOwyco3UGpbc1rrI0IneivGBeWdbsMZXcC6T1tjmjlKjbKEJH)oSNlF(5a4nHbbk0Yy69lHysRKKpElzbo9g9)I4qCNLL0ZLXC5Mlr8O0CzZyooU95Ynxbog2IfYKasVXWFh2lC25YNFUmNlr8O0CCzooU95YNFU9MJf40BRNsyswitci9gd)DypxU52BoaEtyqGcTmME)siM0kj5J3swGtVr)Vioe3zzj9CzmxU5kWXWw8GUgdcux4ScKOAoSfife4jW(ERimbNOmc(eiuhfjsl2qGubUrapeiplLsslakK9RKRuAVCBdxROsTnx2mMBR5YNFUmNBV5aHRLepQTvO1)I2w93(5YNFoq4AjXJABfA9V8EUSNJRZX5YqGevZHTaj5kL2l32W1kQuBctWjQCtWNaH6OirAXgcKkWnc4HajZ5ybo926PeMKfYKasVXWFh2ZLp)Ca8MWGafAzm9(LqmPvsYhVLSaNEJ(FrCiUZYs65YyUCZLiEuAUSzmhh3(C5MRahdBXczsaP3y4Vd7fo7C5ZpxMZLiEuAoUmhh3(C5Zp3EZXcC6T1tjmjlKjbKEJH)oSNl3C7nhaVjmiqHwgtVFjetALK8XBjlWP3O)xehI7SSKEUmMl3Cf4yylEqxJbbQlCwbsunh2cKOR0BGijRrkjmbNOIQGpbc1rrI0Ineir1CylqQrkjJQ5WwM83eij)nzhQKaPYSkmbNOULGpbc1rrI0Ineir1Cylqa4TmQMdBzYFtGK83KDOsce1WBHjmbclGQq1IWe8j4evbFceQJIePfBiqQa3iGhceaPgE)ZXL54kUXnbsunh2cewitcizcbAjgeyUHRjHj4ClbFceQJIePfBiqQa3iGhcK9MRahdB9LHgYedcux4ScKOAoSfiFzOHmXGavHj4KRe8jqOoksKwSHaPdvsGe8ZVmaXlXGTjHyswitciqIQ5WwGe8ZVmaXlXGTjHyswitcimbNCGGpbc1rrI0IneiqwbYtMajQMdBbcVa4rrIei8IeojqqvGWlaYoujbIQ3A5tbqwXnigMWeCYrbFcKOAoSfi8cvwh4vPbXRLceQJIePfBimHjqudVf8j4evbFceQJIePfBiqQa3iGhcKcCmSvbe2siM0kjz8vQ1KEHZkqEd4vtWjQcKOAoSfi1iLKr1Cylt(BcKK)MSdvsGuaHTWeCULGpbsunh2ceT)SusQgkEvGqDuKiTydHj4KRe8jqOoksKwSHaPcCJaEiq4fapks0I1LqGKhM8rVRYkS1U5WEUCZ59hTBOpx2mMJd4MajQMdBbcpORLeaN1CylmbNCGGpbc1rrI0IneivGBeWdbsbog2cliPcEa0E0)cNDUCZT3CAQahdBXeewjgEsIfeWPfoRajQMdBbYxgAitjtiqlzdVfMGtok4tGqDuKiTydbsunh2cKAKsYOAoSLj)nbsYFt2HkjqQ6xyco5EbFceQJIePfBiqIQ5WwGO6Tw(uaeivGBeWdbIfjQT1tbWBfz7kLMAaOf1rrI0ZLBUNLsjPfafY(LQ3A5tbyUSNlZ54fapks0s1BT8PaiR4gedBUSMd15YyUCZT3CAOT(YqdzkzcbAjB49Y86(ERmxU52BUkeM0qM9s1BDb1AcSWzfiv0RjsAbqHSxWjQctWjxxWNaH6OirAXgcKOAoSfi6qTdZHTaPcCJaEiq2BoEbWJIeTIusQH2lXzfiv0RjsAbqHSxWjQctW52f8jqOoksKwSHaPcCJaEiq8(J2n0NJlmMB7CCUCZL5CzoNfjQTvjERqaVvK8GUErDuKi9C5M7zPusAbqHSFP6Tw(uaMJlZXX5YyU85N7zPusAbqHSFP6Tw(uaMJXCOoxgcKOAoSfi8GUwwatMWeCIYi4tGqDuKiTydbsunh2cenXdId8wrYMcfCsGubUrapeizohGWa0xgfjAU85NZ7pA3qFUSNJRZX5YyUCZT3C8cGhfjAX6siqYdt(O3vzf2A3CypxU5YCU9MZIe126Pa4TISDLstna0I6Oir65YNFUmNZIe126Pa4TISDLstna0I6Oir65Yn3EZXlaEuKO1tbWBfz7kLMAaizf3GyyZLXCziqQOxtK0cGczVGtufMGtu5MGpbc1rrI0IneivGBeWdbYZsPK0cGcz)s1BT8PamhxMlZ54G5YAUkS14UT0()WoAts1si9lQJIePNlJ5YnN3F0UH(CCHXCBNJcKOAoSfi8GUwwatMWeCIkQc(eiuhfjsl2qGevZHTa5ldnKPKjeOLAkSsbsf4gb8qGK5CwauiBvsrYkxSvBoUm3wCBUCZ9SukjTaOq2Vu9wlFkaZXL54G5YyU85NlZ5yjBH5uRxr1CE0C5MdG3egeOqRVm0qMyPqLKSa)vxehI7SSKEUmeiv0RjsAbqHSxWjQctWjQBj4tGqDuKiTydbsunh2cKhhaOwtaPbLQHUP)fivGBeWdbIfafYwMRssdk1onhxMBlooxU5kWXWw8GUgdcuxAiZwGurVMiPfafYEbNOkmbNOYvc(eiuhfjsl2qGubUrapeiAOT4fQSoWRsdIxlxMx33BL5YnxMZL5CwKO2wpfaVvKTRuAQbGwuhfjspxU5EwkLKwaui7xQERLpfG5YEUmNJxa8OirlvV1YNcGSIBqmS5YAouNlJ5YyU85NtdT1xgAitjtiqlzdVxMx33BL5YqGevZHTar1BDb1AcimbNOYbc(eiuhfjsl2qGevZHTaHh01sdcauBcKkWnc4HaHxa8Oirln0Ejo7C5MZcGczlZvjPbLANMl754Q5Ynxbog2Ih01yqG6sdz2ZLBUNLsjPfafY(LQ3A5tbyoUmxMZXX5YAUmNJ7NBB5CwKO2wgt)njetIfgTOoksKEUmMldbsf9AIKwaui7fCIQWeCIkhf8jqOoksKwSHaPcCJaEiqa4nHbbk0In8UaqX(eqY(rsDrCiUZYs65YnhVa4rrIwAO9sC25YnNfafYwMRssdkzRMClUnx2ZL5CvimPHm71xgAitjtiql1uyLlnoimh2ZL1Ckv9CziqIQ5WwG8LHgYuYec0snfwPWeCIk3l4tGqDuKiTydbsf4gb8qGacxljEuBRqR)L3ZL9COYnbsunh2cKVm0qMYki(sHj4evUUGpbc1rrI0Ineir1Cylqu9wlFkacKk61ejTaOq2l4evbI3gba4SM0XeiMx3)ZMXwceVncaWznPRQsApmsGGQaPcCJaEiqEwkLKwaui7xQERLpfG5YEoEbWJIeTu9wlFkaYkUbXWMl3Cf4yylDa2xALqCLsBHZkqQLH3ceufMGtu3UGpbc1rrI0Ineir1Cylqu9wlXsb6ceVncaWznPJjqmVU)NnJTYvHWKgYSx8GUwwat2cNvG4TraaoRjDvvs7HrceufivGBeWdbsbog2shG9LwjexP0w4SZLBoEbWJIeT0q7L4ScKAz4TabvHj4evugbFceQJIePfBiqQa3iGhceEbWJIeT0q7L4SZLBoq4AjXJABPc5rQuBlVNl75QXBsZvP5YAoUT44C5MlZ5EwkLKwaui7xQERLpfG54YCCWC5Zp3EZzrIAB9ua8wr2UsPPgaArDuKi9CziqIQ5WwGO6TwwKI3eMGZT4MGpbc1rrI0Ineir1Cylq4fQSoWRsdIxlfivGBeWdbcGWa0xgfjAUCZzbqHSL5QK0GsTtZL9CC)C5ZpxMZzrIABP6pbqFrDuKi9C5MtdT1xgAitjtiqlzdVxacdqFzuKO5YyU85NRahdBH3y4GK3ksDa2VP)x4ScKk61ejTaOq2l4evHj4Cluf8jqOoksKwSHaPcCJaEiqaegG(YOirZLBolakKTmxLKguQDAUSNJdMl3C7nNfjQTLQ)ea9f1rrI0ZLBolsuBl2h9APxLjV3FrDuKi9C5M7zPusAbqHSFP6Tw(uaMl752sGevZHTa5ldnKPKjeOLSH3ctW5wBj4tGqDuKiTydbsunh2cKVm0qMsMqGwYgElqQa3iGhceaHbOVmks0C5MZcGczlZvjPbLANMl754G5Yn3EZzrIABP6pbqFrDuKi9C5MBV5YColsuBRNcG3kY2vkn1aqlQJIePNl3CplLsslakK9lvV1YNcWCzpxMZXlaEuKOLQ3A5tbqwXnig2CznhQZLXCzmxU5YCU9MZIe12I9rVw6vzY79xuhfjspx(8ZL5CwKO2wSp61sVktEV)I6Oir65Yn3ZsPK0cGcz)s1BT8Pamhxym3wZLXCziqQOxtK0cGczVGtufMGZT4kbFceQJIePfBiqIQ5WwGO6Tw(uaeiv0RjsAbqHSxWjQceVncaWznPJjqmVU)NnJTeiEBeaGZAsxvL0EyKabvbsf4gb8qG8SukjTaOq2Vu9wlFkaZL9C8cGhfjAP6Tw(uaKvCdIHjqQLH3ceufMGZT4abFceQJIePfBiqIQ5WwGO6TwILc0fiEBeaGZAshtGyED)pBgBLRcHjnKzV4bDTSaMSfoRaXBJaaCwt6QQK2dJeiOkqQLH3ceufMGZT4OGpbsunh2cKVm0qMsMqGwQPWkfiuhfjsl2qyco3I7f8jqIQ5WwG8LHgYuYec0s2WBbc1rrI0IneMWeiv9l4tWjQc(eiuhfjsl2qGubUrapeif4yylEqxJbbQlCwbsunh2cewitci9gd)DylmbNBj4tGqDuKiTydbsunh2cK3tuxjbsf4gb8qGaWBcdcuO1tSL48ZxYcG1uOgMd7fXH4ollPNl3CzoNfafYw(ldTEU85NZcGczlnvGJHTQXBERSauuT5YqGurVMiPfafYEbNOkmbNCLGpbsunh2ceSGKk4bq7r)ceQJIePfBimbNCGGpbc1rrI0Ineir1Cylqu9wReQ0lqQa3iGhceV)ODd954YCOmCBUCZL5C8cGhfjAfPKudTxIZox(8ZvGJHT4bDngeOUWzNldbsf9AIKwaui7fCIQWeCYrbFceQJIePfBiqQa3iGhceq4AjXJABfA9V8EUSNBlUjqIQ5WwGG3LWe6YgYleMGtUxWNaH6OirAXgcKkWnc4HazV5kWXWw8GUgdcux4SZLBU9MRcHjnKzV4bDTKa4SMd7fo7C5M7zPusAbqHSFP6Tw(uaMl75qDUCZT3CwKO2wpfaVvKTRuAQbGwuhfjspx(8ZL5Cf4yylEqxJbbQlC25Yn3ZsPK0cGcz)s1BT8PamhxMBR5Yn3EZzrIAB9ua8wr2UsPPgaArDuKi9Czmx(8ZL5Cf4yylEqxJbbQlC25YnNfjQT1tbWBfz7kLMAaOf1rrI0ZLHajQMdBbsbe2siM0kjz8vQ1Kwyco56c(eiuhfjsl2qGevZHTaPgPKmQMdBzYFtGK83KDOsce6FQR0lmbNBxWNajQMdBbc(ts3i1xGqDuKiTydHjmbsbe2c(eCIQGpbc1rrI0IneivGBeWdbYZsPK0cGcz)s1BT8PamhxymhxjqIQ5WwGeFLAnPLfP4nHj4ClbFceQJIePfBiqQa3iGhcKmN7zPusAbqHSFP6Tw(uaMl752AUCZzrIAB9ua8wr2UsPPgaArDuKi9C5ZpxMZ9SukjTaOq2Vu9wlFkaZL9COoxU52BolsuBRNcG3kY2vkn1aqlQJIePNlJ5YyUCZ9SukjTaOq2VIVsTM0YgYlMl75qvGevZHTaj(k1AslBiVqyctGuzwf8j4evbFceQJIePfBiqWFsYS0tKSgV5TIGtufir1CylqEkaERiBxP0udajqQOxtK0cGczVGtufivGBeWdbsMZXlaEuKO1tbWBfz7kLMAaizf3GyyZLBU9MJxa8OirlwxcbsEyYh9UkRWw7Md75YyU85NlZ50qB9LHgYuYec0s2W7fGWa0xgfjAUCZ9SukjTaOq2Vu9wlFkaZL9COoxgctW5wc(eiuhfjsl2qGG)KKzPNiznEZBfbNOkqIQ5WwG8ua8wr2UsPPgasGurVMiPfafYEbNOkqQa3iGhcelsuBRNcG3kY2vkn1aqlQJIePNl3CAOT(YqdzkzcbAjB49cqya6lJIenxU5EwkLKwaui7xQERLpfG5YEUTeMGtUsWNaH6OirAXgceyNqxwzwfiOkqIQ5WwGO6TwwKI3eMWeMaHhbEh2co3IBBXnu5gxXnbcZa0ER8ceUwvwiWi9CC95IQ5WEUK)2VMDcKNLQco3IJBxGWcGyEIei8FoKYqdzohkaC6Tzh)NJtipsTGaZX9On3wCBlUn7MD8Fou2TvQIBKEUccdcO5Qq1IWMRGu8(xZHYRvI1(5AyJIQmaQy4P5IQ5W(Nd2j0xZUOAoS)flGQq1IWYIXMSqMeqYec0smiWCdxtO5ymaKA49ZfUIBCB2fvZH9VybufQwewwm28ldnKjgeOIMJXyVcCmS1xgAitmiqDHZo7IQ5W(xSaQcvlcllgBI)K0nsfToujgb)8ldq8smyBsiMKfYKaZUOAoS)flGQq1IWYIXM8cGhfjcToujgQERLpfazf3GyyObzz8KHgViHtmqD2fvZH9VybufQwewwm2KxOY6aVkniETC2n74)COa0Cy)ZUOAoSFgVNOUsZUOAoS)SySjl0CyJMJXOahdBvKGqDc)TfGIQLpVfafYwMRssdk1oXfgBNB5ZBbqHSvjfjRCXwnUWvCC2fvZH9NfJn5fapkseADOsm0q7L4SObzz8KHgViHtm0qB9LHgYuYec0s2W7L5199wjNgAlEHkRd8Q0G41YL5199wz2fvZH9NfJn5fapkseADOsmIusQH2lXzrdYY4jdnErcNyOH26ldnKPKjeOLSH3lZR77Tson0w8cvwh4vPbXRLlZR77Tson0wAIheh4TIKnfk40Y86(ERm7IQ5W(ZIXM8cGhfjcToujgpfaVvKTRuAQbGKvCdIHHgKLXtgA8IeoX4zPusAbqHSFP6Tw(uaYMRMD8Fo(ra8OirZzW5EMUvlNRGmMe1Z9O3vVvMRcHjnKzph(hk0CgCouaYKaZX12y4Vd75GG54hqxphklaN1CypNMyPw7TYCmljRKaZXcC6n5tjmjlKjbKEJH)oSNZ)58Eo8NMdcMJjnNg28BBUYGhnhlKjbMZBm83H9CjkanPxZUOAoS)SySjVa4rrIqRdvIbRlHajpm5JExLvyRDZHnAqwgpzOXls4eJmzbo926PeMKfYKasVXWFh25ZdWBcdcuOLX07xcXKwjjF8wYcC6n6)fXH4ollPZixI4rPSzWXTNRcHjnKzVyHmjG0Bm83H9cNnF(mtepkXfoU9853Jf40BRNsyswitci9gd)DyNBpaEtyqGcTmME)siM0kj5J3swGtVr)Vioe3zzjDg5Qqysdz2lEqxljaoR5WEHZo74)CBlgvps)SlQMd7plgBI5aQibHA0CmgzYcC6T1tjmjlKjbKEJH)oSZNhG3egeOqlJP3VeIjTss(4TKf40B0)lIdXDwwsNrUeXJszZGJBpxbog2IfYKasVXWFh2lC285Zmr8Oex442ZNFpwGtVTEkHjzHmjG0Bm83HDU9a4nHbbk0Yy69lHysRKKpElzbo9g9)I4qCNLL0zKRahdBXd6AmiqDHZo7IQ5W(ZIXMfe4jW(ERGMJXitwGtVTEkHjzHmjG0Bm83HD(8a8MWGafAzm9(LqmPvsYhVLSaNEJ(FrCiUZYs6mYLiEukBgCC75kWXWwSqMeq6ng(7WEHZMpFMjIhL4ch3E(87XcC6T1tjmjlKjbKEJH)oSZThaVjmiqHwgtVFjetALK8XBjlWP3O)xehI7SSKoJCf4yylEqxJbbQlC2zh)NBBEAoUgxP043)C7W1kQuBZ5yZzLeGMla0CBnhemNkeqZzbqHShT5GG5cT(NlauZVT5E2Gz7TYCyqWCQqanNvg9CCDo(Rzxunh2Fwm2m5kL2l32W1kQuBO5ymEwkLKwaui7xjxP0E52gUwrLAlBgBLpFM7bcxljEuBRqR)fTT6V95ZdcxljEuBRqR)L3zZ15ygZUOAoS)SySz0v6nqKK1iLqZXyKjlWP3wpLWKSqMeq6ng(7WoFEaEtyqGcTmME)siM0kj5J3swGtVr)Vioe3zzjDg5sepkLndoU9Cf4yylwitci9gd)DyVWzZNpZeXJsCHJBpF(9ybo926PeMKfYKasVXWFh252dG3egeOqlJP3VeIjTss(4TKf40B0)lIdXDwwsNrUcCmSfpORXGa1fo7SlQMd7plgBwJusgvZHTm5VHwhQeJkZ6SlQMd7plgBcWBzunh2YK)gADOsmudVNDZo(phkL7(zxunh2)QQFgSqMeq6ng(7WgnhJrbog2Ih01yqG6cND2X)52MNMdXtuxP5G9COuUBodohlawNdHylX5N87FouaaRPqnmh2Rzxunh2)QQ)SyS57jQReAv0RjsAbqHSNbQO5yma4nHbbk06j2sC(5lzbWAkudZH9I4qCNLL05Y0cGczl)LHwNpVfafYwAQahdBvJ38wzbOOAzm7IQ5W(xv9NfJnXcsQGhaTh9p7IQ5W(xv9NfJnv9wReQ0Jwf9AIKwaui7zGkAogdV)ODdDUGYWTCzYlaEuKOvKssn0EjoB(8f4yylEqxJbbQlC2mMDr1Cy)RQ(ZIXM4DjmHUSH8c0CmgGW1sIh12k06F5D2BXTzxunh2)QQ)SySzbe2siM0kjz8vQ1KgnhJXEf4yylEqxJbbQlC2C7vHWKgYSx8GUwsaCwZH9cNn3ZsPK0cGcz)s1BT8PaKnQ52ZIe126Pa4TISDLstna0I6Oir685ZSahdBXd6AmiqDHZM7zPusAbqHSFP6Tw(ua4Yw52ZIe126Pa4TISDLstna0I6Oir6mYNpZcCmSfpORXGa1foBolsuBRNcG3kY2vkn1aqlQJIePZy2fvZH9VQ6plgBwJusgvZHTm5VHwhQed6FQR0p74)CChHf4jBoSiLkI6(ZHbbZH)rrIMZns9rjZTnpnhSNRcHjnKzVMDr1Cy)RQ(ZIXM4pjDJu)z3SJ)ZHYrbUM5m4C4pnhZsQNBdiSNdInNvsZHY)k1AspN)ZfvZ5rZUOAoS)vbe2mIVsTM0YIu8gAogJNLsjPfafY(LQ3A5tbGlm4Qzxunh2)Qac7SySz8vQ1Kw2qEbAogJmFwkLKwaui7xQERLpfGS3kNfjQT1tbWBfz7kLMAaOf1rrI05ZN5ZsPK0cGcz)s1BT8PaKnQ52ZIe126Pa4TISDLstna0I6Oir6mYi3ZsPK0cGcz)k(k1AslBiViBuNDZo(p3gyO85qz)N6k9ZHbbZHcacffBy1Yzh)NJ7Oez0CwP)ZfygbMdPm0qMPO1)CPaVRLZUOAoS)f9p1v6zOsQqa6siMmHxDTudOq9NDr1Cy)l6FQR0NfJnlsqOwcXKwjjPMurF2fvZH9VO)PUsFwm2ubpaApAjetg8tcaTYzxunh2)I(N6k9zXytmyf)jTm4NeWnswqHkAogJNLsjPfafY(LQ3A5tbiBgBLppiCTK4rTTcT(xENn3ZTzxunh2)I(N6k9zXytwCGJHU3kYIu8gAogJNLsjPfafY(LQ3A5tbiBgBLppiCTK4rTTcT(xENn3ZTzxunh2)I(N6k9zXyZkSRuBGWiTelfQeAjVjzvZG7rZXyyUkXfgOYT85XWtjjGQLbqHKMRsCrPQZN3cGczlZvjPbLAN4chNDr1Cy)l6FQR0NfJnbolBIKElF2OsZUOAoS)f9p1v6ZIXMaky9wrILcv6NDr1Cy)l6FQR0NfJnzcbjnpYBjGEyhDLMDr1Cy)l6FQR0NfJnTssI3fq8wlXGGkn7MD8FouA82CO4sprZHsJ38wzUOAoS)1CiKnxyZv6kLeyowGdbUH(CgCUVecS5QoOI72CEBeaGZAZvHT2nh2)CWEo(L365qOaSjk6uG(SJ)ZTnpnhcfaVvMJtxP0udanNJnh6q85y6P0CLUnh1qCLY5SaOq2px065qbitcmhxBJH)oSNlA9C8dORXGa15canxdT5auOrhT5GG5m4CacdqF5CiOyuckmhSNZycNdcMtfcO5SaOq2VMDr1Cy)RkZkJNcG3kY2vkn1aqOH)KKzPNiznEZBfgOIwf9AIKwaui7zGkAogJm5fapks06Pa4TISDLstnaKSIBqmSC7XlaEuKOfRlHajpm5JExLvyRDZHDg5ZNPgARVm0qMsMqGwYgEVaegG(YOir5EwkLKwaui7xQERLpfGSrnJzh)NdPecS5qPoOI72Ciua8wzooDLstna0CvyRDZH9CgCU9jIDoeumkbfMdNDoVNdLdrzNDr1Cy)RkZAwm28Pa4TISDLstnaeA4pjzw6jswJ38wHbQOvrVMiPfafYEgOIMJXWIe126Pa4TISDLstna0I6Oir6CAOT(YqdzkzcbAjB49cqya6lJIeL7zPusAbqHSFP6Tw(uaYERzh)Nd2j0LvM15uJ9PFoRKMlQMd75GDc95W)OirZPXbERmxTm6MsERmx065AOnx8ZfZbif8uaMlQMd71SlQMd7FvzwZIXMQERLfP4n0GDcDzLzLbQZUzh)NJFfEphkhf4AqBUVeIN0ZvH8iWCrknhiAf6NdInNfafY(5Iwp3xPoao8NDr1Cy)l1W7SySznsjzunh2YK)gADOsmkGWgT3aE1yGkAogJcCmSvbe2siM0kjz8vQ1KEHZo7IQ5W(xQH3zXytT)SusQgkED2X)5qqVRZHZoh)a6AmiqDUO1ZHcqMeyoU2gd)DyphkfctAiZ(NlA9CqS5WFVvMJRbA8J5yHW0CE)r7g6ZvqyqanxnEZBL1SlQMd7FPgENfJn5bDTKa4SMdB0Cmg8cGhfjAX6siqYdt(O3vzf2A3CyNZ7pA3qpBgCa3MD8Fo(vSpn3JdO5qhIphlUnho7CiOyuckmhkhbLJcZb75SsAolakKnNJnhkgewjgEAou0bbCAo)B(TnxunNhTMDr1Cy)l1W7SyS5xgAitjtiqlzdVrZXyuGJHTWcsQGhaTh9VWzZTNMkWXWwmbHvIHNKybbCAHZo7IQ5W(xQH3zXyZAKsYOAoSLj)n06qLyu1)SJ)ZTTZvkNdfaoe4g6ZXV8wphcfG5IQ5WEodohGWa0xoh3b57NJPBLZ9ua8wr2UsPPgaA2fvZH9VudVZIXMQERLpfa0QOxtK0cGczpdurZXyyrIAB9ua8wr2UsPPgaArDuKiDUNLsjPfafY(LQ3A5tbi7m5fapks0s1BT8PaiR4gedlluZi3EAOT(YqdzkzcbAjB49Y86(ERKBVkeM0qM9s1BDb1AcSWzND8Fouaqyeyodoh(tZXDHAhMd75q5iOCuyohBUOrFoUdY3C(pxdT5WzxZUOAoS)LA4Dwm2uhQDyoSrRIEnrslakK9mqfnhJXE8cGhfjAfPKudTxIZo74)CBZtZXpGUEUnGjBUWMR0vkjWCSahcCd95y6w5CB7WBfc4TYC8dORNdNDodohhmNfafYE0MdcMdALeyolsuB)CWEoe(wZUOAoS)LA4Dwm2Kh01YcyYqZXy49hTBOZfgBNJ5YmtlsuBRs8wHaERi5bD9I6Oir6CplLsslakK9lvV1YNcax4yg5Z)SukjTaOq2Vu9wlFkamqnJzh)NJ7Gn)2Md)P54oIheh4TYCOqkuWP5CS5qhIpxn65uiBoVn4C8dORXGa158(nk0OnhemNJnhcfaVvMJtxP0udanN)ZzrIAJ0ZfTEoMEknxPBZrnexPColakK9Rzxunh2)sn8olgBQjEqCG3ks2uOGtOvrVMiPfafYEgOIMJXitaHbOVmksu(8E)r7g6zZ15yg52Jxa8OirlwxcbsEyYh9UkRWw7Md7CzUNfjQT1tbWBfz7kLMAaOf1rrI05ZNPfjQT1tbWBfz7kLMAaOf1rrI052Jxa8OirRNcG3kY2vkn1aqYkUbXWYiJzh)NBBEAo(XgZb75qPC3Co2COdXNtdB(TnxtKEodoxnEBoUJ4bXbERmhkKcfCcT5IwpNvsaAUaqZLO)NZkJEooyolakK9ZbXT5YKJZX0TY5QWwJ7wgRzxunh2)sn8olgBYd6AzbmzO5ymEwkLKwaui7xQERLpfaUKjhKvf2AC3wA)FyhTjPAjK(f1rrI0zKZ7pA3qNlm2ohND8FUT5P5qkdnK5COyiqJsMJ7OWkNZXMZkP5SaOq2C(pxuaXT5m4CANMdcMdDi(CLbpAoKYqdzILcvAoua4V6CehI7SSKEoMUvoh)YBDb1AcmhemhszOHmXCQ1ZfvZ5rRzxunh2)sn8olgB(LHgYuYec0snfwjAv0RjsAbqHSNbQO5ymY0cGczRsksw5ITACzlUL7zPusAbqHSFP6Tw(ua4chKr(8zYs2cZPwVIQ58OCa8MWGafA9LHgYelfQKKf4V6I4qCNLL0zm74)CBZtZHGdauRjWCgCo(vOB6)5G9CXCwauiBoRmS58FofO3kZzW50onxyZzL0CaxP0MZCvAn7IQ5W(xQH3zXyZhhaOwtaPbLQHUP)rRIEnrslakK9mqfnhJHfafYwMRssdk1oXLT4yUcCmSfpORXGa1LgYSNDr1Cy)l1W7SySPQ36cQ1eanhJHgAlEHkRd8Q0G41YL5199wjxMzArIAB9ua8wr2UsPPgaArDuKiDUNLsjPfafY(LQ3A5tbi7m5fapks0s1BT8PaiR4gedlluZiJ851qB9LHgYuYec0s2W7L5199wjJzh)NBBEAo(b01ZXheaO2Md2j0NZXMdbfJsqH5Iwph)GV5canxunNhnx065SsAolakKnhtyZVT50onNgh4TYCwjnxTm6MsRzxunh2)sn8olgBYd6APbbaQn0QOxtK0cGczpdurZXyWlaEuKOLgAVeNnNfafYwMRssdk1oLnxLRahdBXd6AmiqDPHm7CplLsslakK9lvV1YNcaxYKJzLj3VT0Ie12Yy6VjHysSWOf1rrI0zKXSJ)ZTnpnhckgLWDZX0TY5qHW7caf7tG5qHpsQZH3j6)5SsAolakKnhtpLMRGMRGsqMZTf32wyUccdcO5SsAUkeM0qM9CvOk9Zve19NDr1Cy)l1W7SyS5xgAitjtiql1uyLO5yma4nHbbk0In8UaqX(eqY(rsDrCiUZYs6C8cGhfjAPH2lXzZzbqHSL5QK0Gs2Qj3IBzNzfctAiZE9LHgYuYec0snfw5sJdcZHDwkvDgZo(p3280CiLHgYCouki(Y5G9COuUBo8or)pNvsaAUaqZfA9pN3vOQ3kRzxunh2)sn8olgB(LHgYuwbXxIMJXaeUws8O2wHw)lVZgvUn74)CBZtZXV8wphcfG5m4Cvy)4Q0CCxa2Fo(kH4kL2phlaw)5G9COCueu21C8HIWDOiZHsHnMduNZ)5Ss)NZ)5I5kDLscmhlWHa3qFoRm65aKgAM3kZb75q5OiOSZH3j6)50by)5SsiUsP9Z5)Crbe3MZGZzUknhe3MDr1Cy)l1W7SySPQ3A5tbaTk61ejTaOq2Zav0CmgplLsslakK9lvV1YNcq28cGhfjAP6Tw(uaKvCdIHLRahdBPdW(sReIRuAlCw0QLH3mqfnVncaWznPRQsApmIbQO5TraaoRjDmgMx3)ZMXwZo(p3280C8lV1ZHIofOpNbNRc7hxLMJ7cW(ZXxjexP0(5ybW6phSNdHV1C8HIWDOiZHsHnMduNZXMZk9Fo)NlMR0vkjWCSahcCd95SYONdqAOzERmhENO)NthG9NZkH4kL2pN)ZffqCBodoN5Q0CqCB2fvZH9VudVZIXMQERLyPaD0Cmgf4yylDa2xALqCLsBHZMJxa8Oirln0EjolA1YWBgOIM3gba4SM0vvjThgXav082iaaN1KogdZR7)zZyRCvimPHm7fpORLfWKTWzND8FUT5P54xERNBJu82Co2COdXNtdB(TnxtKEodohGWa0xoh3b57xZHyq25QXBERmxyZXbZbbZPcb0Cwaui7NJPBLZHqbWBL540vkn1aqZzrIAJ0Rzxunh2)sn8olgBQ6TwwKI3qZXyWlaEuKOLgAVeNnhiCTK4rTTuH8ivQTL3zxJ3KMRszXTfhZL5ZsPK0cGcz)s1BT8PaWfoiF(9SirTTEkaERiBxP0udaTOoksKoJzxunh2)sn8olgBYluzDGxLgeVwIwf9AIKwaui7zGkAogdaHbOVmksuolakKTmxLKguQDkBUpF(mTirTTu9NaOVOoksKoNgARVm0qMsMqGwYgEVaegG(YOirzKpFbog2cVXWbjVvK6aSFt)VWzND8FoewQ6rAUkS1U5WEodo3Bq25QXBERmhckgLGcZb75GyyOOSaOq2phZsQNdZvknVvMJRMdcMtfcO5ElQ7t65uHf)CrRNd)9wzou4rVw6154A8E)5IwphNOi8nh)YFcG(A2fvZH9VudVZIXMFzOHmLmHaTKn8gnhJbGWa0xgfjkNfafYwMRssdk1oLnhKBplsuBlv)ja6lQJIePZzrIABX(Oxl9Qm59(lQJIePZ9SukjTaOq2Vu9wlFkazV1SJ)ZTTNi25qqXOeuyoC25G9CXpNA0OpNfafY(5IFow4)ErIqBoABTsS2CmlPEomxP08wzoUAoiyoviGM7TOUpPNtfw8ZX0TY5qHh9APxNJRX79xZUOAoS)LA4Dwm28ldnKPKjeOLSH3OvrVMiPfafYEgOIMJXaqya6lJIeLZcGczlZvjPbLANYMdYTNfjQTLQ)ea9f1rrI052ltlsuBRNcG3kY2vkn1aqlQJIePZ9SukjTaOq2Vu9wlFkazNjVa4rrIwQERLpfazf3GyyzHAgzKlZ9SirTTyF0RLEvM8E)f1rrI05ZNPfjQTf7JET0RYK37VOoksKo3ZsPK0cGcz)s1BT8PaWfgBLrgZUOAoS)LA4Dwm2u1BT8PaGwf9AIKwaui7zGkAogJNLsjPfafY(LQ3A5tbiBEbWJIeTu9wlFkaYkUbXWqRwgEZav082iaaN1KUQkP9WigOIM3gba4SM0XyyED)pBgBn7IQ5W(xQH3zXytvV1sSuGoA1YWBgOIM3gba4SM0vvjThgXav082iaaN1KogdZR7)zZyRCvimPHm7fpORLfWKTWzND8FUT5P5qqXOeUBU4NlfVnhGEiWMZXMd2ZzL0CQqE0SlQMd7FPgENfJn)YqdzkzcbAPMcRC2X)52MNMdbfJsqH5IFUu82Ca6HaBohBoypNvsZPc5rZfTEoeumkH7MZ)5G9COuUB2fvZH9VudVZIXMFzOHmLmHaTKn8wyctia]] )


end
