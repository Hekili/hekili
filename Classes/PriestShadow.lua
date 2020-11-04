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


    spec:RegisterPack( "Shadow", 20201030, [[d4KyrbqiLQ6ruP4sqIIAtsWNOsjnkQeNIe1QGef5vuPAwqf3csuYUuYVukAyqLCmiPLPuYZukvtdvuDnuPSnLsPVPuLACkvX5GkLSoOsX8qf5Eqv7JkPdcvQSqLcpuPkzIOsLlcvk1gHeLAKuPuPtcvQQvQu5LuPuHzcvQYnPsj2jQKFsLszOqISuQuQONcXujrUQsPyROsv(kKOAVe9xcdwLdlSyj6XsAYK6YiBgkFgvnAQ40IwnKOWRHeMnvDBsA3k(nOHJshhvuwoWZv10PCDuSDs47qQXtLsvNhvy9OsvnFj0(LAjQsLKi6WijxBHRTWfQ4A74AHkUqDV3IZLighSKeHnQOi4jjYeQKebXj0q0se2Gdpm0sLKipKbujjIJzSpUzZn5tZHPCvHQB(PkJpSeovqGzB(PADtjsjt6nC)rwkr0HrsU2cxBHluX12X1cvCH6EV12LibJ5abseKuDVKioPwtJSuIOPVkrCtFioHgIUpucK0B9o30NBRAWsc032Xfo9TfU2cxseF(2lvsIq)ttLEPssUqvQKejQwchjIkPcbCiGycptn1cnGc1xIqtu6jTCdPj5AlPssKOAjCKiLEiulGycZHe0qQCirOjk9KwUH0KCTDPssKOAjCKi8mbqNXiGyIG7taO5irOjk9KwUH0KCX5sLKi0eLEsl3qIubPrGmKipl59cla8K9l1C0INcqFUIVVT6RyX(arQfKcASvO1)kN(CTVTfxsKOAjCKiyWkZtArW9jqAKOKcvPj5IBsLKi0eLEsl3qIubPrGmKipl59cla8K9l1C0INcqFUIVVT6RyX(arQfKcASvO1)kN(CTVTfxsKOAjCKiSmGeJJC4fL(4nPj5ABLkjrOjk9KwUHejQwchjsfovAmqyKwG5dvsIubPrGmKiwQs9Xj89HkU6RyX(Wy8EbGQobGNewQs9XP(4R6(kwSpla8KTSuLeguOtQpo1h3Ki(Cirvlr2wPj5AVLkjrIQLWrIaswwpjYr8SrLKi0eLEsl3qAsU2JujjsuTeoseafS5WlW8Hk9seAIspPLBinjx4wsLKir1s4irqdbETckhbGE4etLKi0eLEsl3qAsUqfxsLKir1s4irmhsWmLqMrlWGGkjrOjk9KwUH0KMertybJ3Kkj5cvPssKOAjCKiF6PPsseAIspPLBinjxBjvsIqtu6jTCdjsfKgbYqIuYGHTk9qO2Z82cqr16RyX(SaWt2YsvsyqHoP(4e((2dU6RyX(SaWt2YHcV5SyRwFCQVTZnjsuTeosewOLWrAsU2UujjcnrPN0YnKiqwjYtMejQwchjIIaKrPNKikcpdjr0qB9oHgIwGgc0c2iNLLvuKdFFf6tdTLIqLnbzvyqMQZYYkkYHxIOiaIjujjIgAVGHvAsU4CPsseAIspPLBirGSsKNmjsuTeosefbiJspjrueEgsIOH26DcneTaneOfSrollROih((k0NgAlfHkBcYQWGmvNLLvuKdFFf6tdTLMuaza5Wly9bpdTSSIIC4LikcGycvsIeEVqdTxWWknjxCtQKeHMO0tA5gseiRe5jtIevlHJerraYO0tsefHNHKipl59cla8K9l1C0INcqFU232LikcGycvsI8uaYHxmjVJPgasuzmigM0KCTTsLKi0eLEsl3qIazLipzsKOAjCKikcqgLEsIOi8mKeXL(ybj926jpMGfIMaICWy(eo9vSyFaMHWGaEAzOZ5fqmH5qINzeSGKEJ(FrCgtYYs6(uUVc95jfKVpxX3h32tFf6RcHEne9SyHOjGihmMpHZIHTVIf7ZL(8KcY3hN6JB7PVIf7B)(ybj926jpMGfIMaICWy(eo9vOV97dWmegeWtldDoVaIjmhs8mJGfK0B0)lIZyswws3NY9vOVke61q0Zsbm1ccWWAjCwmSsefbqmHkjrytbeiuGjEoMQOchDAjCKMKR9wQKeHMO0tA5gsKkincKHeXL(ybj926jpMGfIMaICWy(eo9vSyFaMHWGaEAzOZ5fqmH5qINzeSGKEJ(FrCgtYYs6(uUVc95jfKVpxX3h32tFf6RKbdBXcrtaroymFcNfdBFfl2Nl95jfKVpo1h32tFfl23(9Xcs6T1tEmblenbe5GX8jC6RqF73hGzimiGNwg6CEbetyoK4zgbliP3O)xeNXKSSKUpL7RqFLmyylfWuJbbQlgwjsuTeoseSeqLEiulnjx7rQKeHMO0tA5gsKkincKHeXL(ybj926jpMGfIMaICWy(eo9vSyFaMHWGaEAzOZ5fqmH5qINzeSGKEJ(FrCgtYYs6(uUVc95jfKVpxX3h32tFf6RKbdBXcrtaroymFcNfdBFfl2Nl95jfKVpo1h32tFfl23(9Xcs6T1tEmblenbe5GX8jC6RqF73hGzimiGNwg6CEbetyoK4zgbliP3O)xeNXKSSKUpL7RqFLmyylfWuJbbQlgwjsuTeosKsc8eaf5Wlnjx4wsLKi0eLEsl3qIubPrGmKipl59cla8K9lFY7yVaLbJMxLgRpxX33w9vSyFU03(9bIulif0yRqR)f52NV99vSyFGi1csbn2k06FLtFU23EZT(uwIevlHJeXN8o2lqzWO5vPXKMKluXLujjcnrPN0YnKivqAeidjIl9Xcs6T1tEmblenbe5GX8jC6RyX(amdHbb80YqNZlGycZHepZiybj9g9)I4mMKLL09PCFf6ZtkiFFUIVpUTN(k0xjdg2IfIMaICWy(eolg2(kwSpx6ZtkiFFCQpUTN(kwSV97JfK0BRN8ycwiAciYbJ5t40xH(2VpaZqyqapTm058ciMWCiXZmcwqsVr)VioJjzzjDFk3xH(kzWWwkGPgdcuxmSsKOAjCKiXuP3aHxudVxAsUqfvPsseAIspPLBirIQLWrIudVxevlHJWNVjr85BIjujjsfDvAsUqDlPsseAIspPLBirIQLWrIaygruTeocF(MeXNVjMqLKiQrostAsewavHQLHjvsYfQsLKi0eLEsl3qIubPrGmKiasnY57Jt9TDCHljsuTeosewiAciqdbAbgeyPXOjPj5AlPsseAIspPLBirQG0iqgsK97RKbdB9oHgIgdcuxmSsKOAjCKiVtOHOXGavPj5A7sLKi0eLEsl3qImHkjrcU)7eG4fyWXeqmblenbKir1s4ircU)7eG4fyWXeqmblenbKMKloxQKeHMO0tA5gseiRe5jtIevlHJerraYO0tsefHNHKiOkrueaXeQKernhT4PaiQmgedtAsU4MujjsuTeosefHkBcYQWGmvhjcnrPN0YnKM0KiQrosLKCHQujjcnrPN0YnKivqAeidjsjdg2QechbetyoKi(knAsVyyLiVbYQj5cvjsuTeosKA49IOAjCe(8njIpFtmHkjrkHWrAsU2sQKejQwchjIoFwYlud(SkrOjk9KwUH0KCTDPsseAIspPLBirQG0iqgsefbiJspTytbeiuGjEoMQOchDAjC6RqF58XKgh95k((4CCjrIQLWrIOaMAbbyyTeostYfNlvsIqtu6jTCdjsfKgbYqIuYGHTWcsWZeaDgZVyy7RqF73NMkzWWwObH5GX4fybbsAXWkrIQLWrI8oHgIwGgc0c2ihPj5IBsLKi0eLEsl3qIevlHJePgEViQwchHpFtI4Z3etOssKQ(LMKRTvQKeHMO0tA5gsKOAjCKiQ5OfpfajsfKgbYqIyHNgB9uaYHxmjVJPgaArtu6jDFf67zjVxybGNSFPMJw8ua6Z1(CPpfbiJspTuZrlEkaIkJbXW6Z9(qTpL7RqF73NgAR3j0q0c0qGwWg5SSSIIC47RqF73xfc9Ai6zPMJUKgnbwmSsKkhvpjSaWt2l5cvPj5AVLkjrOjk9KwUHejQwchjIouNWs4irQG0iqgsK97traYO0tRW7fAO9cgwjsLJQNewa4j7LCHQ0KCThPsseAIspPLBirQG0iqgsKC(ysJJ(4e((2d36RqFU0Nl9zHNgB5Wm8eihEHcyQx0eLEs3xH(EwY7fwa4j7xQ5OfpfG(4uFCRpL7RyX(EwY7fwa4j7xQ5OfpfG(W3hQ9PSejQwchjIcyQfLqVjnjx4wsLKi0eLEsl3qIevlHJertkGmGC4fS(GNHKivqAeidjIl9bima9orPN6RyX(Y5Jjno6Z1(2BU1NY9vOV97traYO0tl2uabcfyINJPkQWrNwcN(k0Nl9TFFw4PXwpfGC4ftY7yQbGw0eLEs3xXI95sFw4PXwpfGC4ftY7yQbGw0eLEs3xH(2VpfbiJspTEka5WlMK3XudajQmgedRpL7tzjsLJQNewa4j7LCHQ0KCHkUKkjrOjk9KwUHePcsJazirEwY7fwa4j7xQ5OfpfG(4uFU0hN3N79vHJMjTLo)hoXycQ6aPFrtu6jDFk3xH(Y5Jjno6Jt47BpCtIevlHJerbm1IsO3KMKlurvQKeHMO0tA5gsKOAjCKiVtOHOfOHaTqtH5irQG0iqgsex6Zcapzlhk8MZITA9XP(2cx9vOVNL8EHfaEY(LAoAXtbOpo1hN3NY9vSyFU0hlzlSKg9kQwQG6RqFaMHWGaEA9oHgIgZhQKGfKV6I4mMKLL09PSePYr1tcla8K9sUqvAsUqDlPsseAIspPLBirIQLWrI8maanAcimOqn0d9VePcsJazirSaWt2YsvsyqHoP(4uFBXT(k0xjdg2sbm1yqG6sdrpsKkhvpjSaWt2l5cvPj5c1TlvsIqtu6jTCdjsfKgbYqIOH2srOYMGSkmit1zzzff5W3xH(CPpx6Zcpn26PaKdVysEhtna0IMO0t6(k03ZsEVWcapz)snhT4Pa0NR95sFkcqgLEAPMJw8uaevgdIH1N79HAFk3NY9vSyFAOTENqdrlqdbAbBKZYYkkYHVpLLir1s4iruZrxsJMastYfQCUujjcnrPN0YnKir1s4iruatTWGaanMePcsJazirueGmk90sdTxWW2xH(SaWt2YsvsyqHoP(CTVT3xH(kzWWwkGPgdcuxAi6PVc99SK3lSaWt2VuZrlEka9XP(CPpU1N795sFBBFOm1NfEASLHoFtaXeyHrlAIspP7t5(uwIu5O6jHfaEYEjxOknjxOYnPsseAIspPLBirQG0iqgseaZqyqapTyJCkbuGcciy)WRUioJjzzjDFf6traYO0tln0EbdBFf6ZcapzllvjHbfSvtSfU6Z1(CPVke61q0Z6DcneTaneOfAkmNLMbewcN(CVp(QUpLLir1s4irENqdrlqdbAHMcZrAsUqDBLkjrOjk9KwUHePcsJazirEwY7fwa4j7xVtOHOfvq8o9HVpu7RqFU0xfc9Ai6z9oHgIwubX7SQobGN((W3327RyX(0ujdg26DcneTOcI3rOPsgmSfdBFfl2xuTeoR3j0q0IkiENvocmFY7y9vSyFwa4jBzPkjmOqNuFCQVke61q0Z6DcneTOcI3zHX49cavDcapjSuL6t5(k0hisTGuqJTcT(x50NR9TDCjrIQLWrI8oHgIwubX7injxOU3sLKi0eLEsl3qIubPrGmKiGi1csbn2k06FLtFU232XvFf67zjVxybGNSF9oHgIwubX70NR9HQejQwchjY7eAiArfeVJ0KCH6EKkjrOjk9KwUHejQwchjIAoAXtbqIu5O6jHfaEYEjxOkrYXiaGH1ejMeXYkkExXVLejhJaagwtKQQKodJKiOkrQG0iqgsKNL8EHfaEY(LAoAXtbOpx7traYO0tl1C0INcGOYyqmS(k0xjdg2shauimhidVJTyyLivNihjcQstYfQ4wsLKi0eLEsl3qIevlHJernhTaZhCirYXiaGH1ejMeXYkkExXVvHke61q0Zsbm1IsO3wmSsKCmcayynrQQs6mmsIGQePcsJazirkzWWw6aGcH5az4DSfdBFf6traYO0tln0EbdReP6e5irqvAsU2cxsLKi0eLEsl3qIubPrGmKikcqgLEAPH2lyy7RqFGi1csbn2sfQGuPXw50NR9vJ3ewQs95EF4AXT(k0Nl99SK3lSaWt2VuZrlEka9XP(48(kwSV97Zcpn26PaKdVysEhtna0IMO0t6(uwIevlHJernhTO0hVjnjxBHQujjcnrPN0YnKir1s4irueQSjiRcdYuDKivqAeidjcGWa07eLEQVc9zbGNSLLQKWGcDs95AFBBFfl2Nl9zHNgBPMpb4yrtu6jDFf6tdT17eAiAbAiqlyJCwacdqVtu6P(uUVIf7RKbdBXmymaFo8cDaqXq)VyyLivoQEsybGNSxYfQstY1wBjvsIqtu6jTCdjsfKgbYqIaima9orPN6RqFwa4jBzPkjmOqNuFU2hN3xH(2Vpl80yl18jahlAIspP7RqFw4PXwSphvNSk85GIfnrPN09vOVNL8EHfaEY(LAoAXtbOpx7BljsuTeosK3j0q0c0qGwWg5injxBTDPsseAIspPLBirIQLWrI8oHgIwGgc0c2ihjsfKgbYqIaima9orPN6RqFwa4jBzPkjmOqNuFU2hN3xH(2Vpl80yl18jahlAIspP7RqF73Nl9zHNgB9uaYHxmjVJPgaArtu6jDFf67zjVxybGNSFPMJw8ua6Z1(CPpfbiJspTuZrlEkaIkJbXW6Z9(qTpL7t5(k0Nl9TFFw4PXwSphvNSk85GIfnrPN09vSyFU0NfEASf7Zr1jRcFoOyrtu6jDFf67zjVxybGNSFPMJw8ua6Jt47BR(uUpLLivoQEsybGNSxYfQstY1wCUujjcnrPN0YnKir1s4iruZrlEkasKkhvpjSaWt2l5cvjsogbamSMiXKiwwrX7k(TKi5yeaWWAIuvL0zyKebvjsfKgbYqI8SK3lSaWt2VuZrlEka95AFkcqgLEAPMJw8uaevgdIHjrQoroseuLMKRT4MujjcnrPN0YnKir1s4iruZrlW8bhsKCmcayynrIjrSSII3v8BvOcHEne9SuatTOe6TfdRejhJaagwtKQQKodJKiOkrQoroseuLMKRT2wPssKOAjCKiVtOHOfOHaTqtH5irOjk9KwUH0KCT1ElvsIevlHJe5DcneTaneOfSroseAIspPLBinPjrQ6xQKKluLkjrOjk9KwUHePcsJazirkzWWwkGPgdcuxmSsKOAjCKiSq0eqKdgZNWrAsU2sQKeHMO0tA5gsKOAjCKiF6PPssKkincKHebWmegeWtRNyDy4(VGfaR(qnSeolIZyswws3xH(CPpla8KTYxeADFfl2NfaEYwAQKbdBvJ3YHFbOOA9PSePYr1tcla8K9sUqvAsU2UujjsuTeoseSGe8mbqNX8seAIspPLBinjxCUujjcnrPN0YnKir1s4iruZrZhQ0lrQG0iqgsKC(ysJJ(4uF4w4QVc95sFkcqgLEAfEVqdTxWW2xXI9vYGHTuatngeOUyy7tzjsLJQNewa4j7LCHQ0KCXnPsseAIspPLBirQG0iqgseqKAbPGgBfA9VYPpx7BlCjrIQLWrIWmoqphIbQiKMKRTvQKeHMO0tA5gsKkincKHez)(kzWWwkGPgdcuxmS9vOV97RcHEne9SuatTGamSwcNfdBFf67zjVxybGNSFPMJw8ua6Z1(qTVc9TFFw4PXwpfGC4ftY7yQbGw0eLEs3xXI95sFLmyylfWuJbbQlg2(k03ZsEVWcapz)snhT4Pa0hN6BR(k03(9zHNgB9uaYHxmjVJPgaArtu6jDFk3xXI95sFLmyylfWuJbbQlg2(k0NfEAS1tbihEXK8oMAaOfnrPN09PSejQwchjsjeociMWCir8vA0KwAsU2BPsseAIspPLBirIQLWrIudVxevlHJWNVjr85BIjujjc9pnv6LMKR9ivsIevlHJeH5jrAK6lrOjk9KwUH0KMePechPssUqvQKeHMO0tA5gsKkincKHe5zjVxybGNSFPMJw8ua6Jt47B7sKOAjCKiXxPrtArPpEtAsU2sQKeHMO0tA5gsKkincKHeXL(EwY7fwa4j7xQ5OfpfG(CTVT6RqFw4PXwpfGC4ftY7yQbGw0eLEs3xXI95sFpl59cla8K9l1C0INcqFU2hQ9vOV97Zcpn26PaKdVysEhtna0IMO0t6(uUpL7RqFpl59cla8K9R4R0OjTyGkI(CTpuLir1s4irIVsJM0IbQiKM0Kiv0vPssUqvQKeHMO0tA5gseMNeODspjQXB5Wl5cvjsuTeosKNcqo8Ij5Dm1aqsKkhvpjSaWt2l5cvjsfKgbYqI4sFkcqgLEA9uaYHxmjVJPgasuzmigwFf6B)(ueGmk90InfqGqbM45yQIkC0PLWPpL7RyX(CPpn0wVtOHOfOHaTGnYzbima9orPN6RqFpl59cla8K9l1C0INcqFU2hQ9PS0KCTLujjcnrPN0YnKimpjq7KEsuJ3YHxYfQsKOAjCKipfGC4ftY7yQbGKivoQEsybGNSxYfQsKkincKHeXcpn26PaKdVysEhtna0IMO0t6(k0NgAR3j0q0c0qGwWg5SaegGENO0t9vOVNL8EHfaEY(LAoAXtbOpx7BlPj5A7sLKi0eLEsl3qIahphIk6QebvjsuTeose1C0IsF8M0KM0KikiWNWrY1w4AlCHkU2Apse0byYH)Li4(QSqGr6(27(IQLWPpF(2V6Dsewael9KeXn9H4eAi6(qjqsV17CtFUTQbljqFBhx403w4AlC176DUPpCB3EQYyKUVscdcO(Qq1YW6RK4Z5x9H7QvI1((g4GYYjaQym((IQLW57doEow9UOAjC(flGQq1YWCh)MSq0eqGgc0cmiWsJrt4Ky4bKAKZZPTJlC17IQLW5xSaQcvldZD8B(oHgIgdcuXjXWVFjdg26DcnengeOUyy7Dr1s48lwavHQLH5o(nzEsKgPIZeQe(G7)obiEbgCmbetWcrtGExuTeo)IfqvOAzyUJFtfbiJspHZeQeE1C0INcGOYyqmmCGS4FYWrr4zi8O27IQLW5xSaQcvldZD8BQiuztqwfgKP6076DUPpucAjC(ExuTeop(p90uPExuTeoV743KfAjCWjXWxYGHTk9qO2Z82cqr1kw0capzllvjHbf6K4e(9GRIfTaWt2YHcV5SyRgN2o36Dr1s48UJFtfbiJspHZeQeEn0Ebdloqw8pz4Oi8meEn0wVtOHOfOHaTGnYzzzff5WxqdTLIqLnbzvyqMQZYYkkYHV3fvlHZ7o(nveGmk9eotOs4dVxOH2lyyXbYI)jdhfHNHWRH26DcneTaneOfSrollROih(cAOTueQSjiRcdYuDwwwrro8f0qBPjfqgqo8cwFWZqllROih(ExuTeoV743uraYO0t4mHkH)PaKdVysEhtnaKOYyqmmCGS4FYWrr4zi8pl59cla8K9l1C0INcGRBV35M(4EbiJsp1Nb77rNw1PVsYqt003ZXuZHVVke61q0tFmFWt9zW(qjiAc0hU)GX8jC6dc6J7btDF42agwlHtFAILgDo89H2Hmhc0hliP3ep5XeSq0eqKdgZNWPV87lN(yEQpiOp0uFA44wT(CcfuFSq0eOVCWy(eo95PamKE17IQLW5Dh)MkcqgLEcNjuj8SPacekWephtvuHJoTeo4azX)KHJIWZq4DHfK0BRN8ycwiAciYbJ5t4uSiGzimiGNwg6CEbetyoK4zgbliP3O)xeNXKSSKw5cEsb5Dfp32tHke61q0ZIfIMaICWy(eolg2IfDXtkipN42EkwCFwqsVTEYJjyHOjGihmMpHtH9bmdHbb80YqNZlGycZHepZiybj9g9)I4mMKLL0kxOcHEne9SuatTGamSwcNfdBVZn952zuZW)9UOAjCE3XVjwcOspeQXjXW7cliP3wp5XeSq0eqKdgZNWPyraZqyqapTm058ciMWCiXZmcwqsVr)VioJjzzjTYf8KcY7kEUTNcLmyylwiAciYbJ5t4Syylw0fpPG8CIB7PyX9zbj926jpMGfIMaICWy(eof2hWmegeWtldDoVaIjmhs8mJGfK0B0)lIZyswwsRCHsgmSLcyQXGa1fdBVlQwcN3D8BwsGNaOihECsm8UWcs6T1tEmblenbe5GX8jCkweWmegeWtldDoVaIjmhs8mJGfK0B0)lIZyswwsRCbpPG8UINB7Pqjdg2IfIMaICWy(eolg2IfDXtkipN42EkwCFwqsVTEYJjyHOjGihmMpHtH9bmdHbb80YqNZlGycZHepZiybj9g9)I4mMKLL0kxOKbdBPaMAmiqDXW27CtFBZt9H7L8oMB97BhJMxLgRVeRpZHauFbG6BR(GG(uHaQpla8K940he0xO1FFbGg3Q13ZgONC47ddc6tfcO(mNy6BV52V6Dr1s48UJFtFY7yVaLbJMxLgdNed)ZsEVWcapz)YN8o2lqzWO5vPXCf)wfl6Y(Gi1csbn2k06FrU95BFXIGi1csbn2k06FLJR7n3uU3fvlHZ7o(nJPsVbcVOgEpojgExybj926jpMGfIMaICWy(eoflcygcdc4PLHoNxaXeMdjEMrWcs6n6)fXzmjllPvUGNuqExXZT9uOKbdBXcrtaroymFcNfdBXIU4jfKNtCBpflUpliP3wp5XeSq0eqKdgZNWPW(aMHWGaEAzOZ5fqmH5qINzeSGKEJ(FrCgtYYsALluYGHTuatngeOUyy7Dr1s48UJFZA49IOAjCe(8nCMqLWxrx7Dr1s48UJFtaZiIQLWr4Z3WzcvcVAKtVR35M(2lU77Dr1s48RQ(XZcrtaroymFchCsm8LmyylfWuJbbQlg2ENB6BBEQpK0ttL6do9TxCxFgSpwaS2hcX6WW9DRFFOeaw9HAyjCw9UOAjC(vv)UJFZp90ujCQCu9KWcapzpEuXjXWdygcdc4P1tSomC)xWcGvFOgwcNfXzmjllPl4IfaEYw5lcTUyrla8KT0ujdg2QgVLd)cqr1uU3fvlHZVQ63D8BIfKGNja6mMV3fvlHZVQ63D8BQMJMpuPhNkhvpjSaWt2JhvCsm858XKghCc3cxfCrraYO0tRW7fAO9cg2IflzWWwkGPgdcuxmSk37IQLW5xv97o(nzghONdXave4Ky4brQfKcASvO1)khx3cx9UOAjC(vv)UJFZsiCeqmH5qI4R0Ojnojg(9lzWWwkGPgdcuxmSf2VcHEne9SuatTGamSwcNfdBHNL8EHfaEY(LAoAXtbWvulSVfEAS1tbihEXK8oMAaOfnrPN0fl6sjdg2sbm1yqG6IHTWZsEVWcapz)snhT4PaWPTkSVfEAS1tbihEXK8oMAaOfnrPN0kxSOlLmyylfWuJbbQlg2cw4PXwpfGC4ftY7yQbGw0eLEsRCVlQwcNFv1V743SgEViQwchHpFdNjuj80)0uPV35M(4ocly8wFyH3xgvu0hge0hZhLEQV0i1h30328uFWPVke61q0ZQ3fvlHZVQ63D8BY8Kins97D9o30hUdLW96ZG9X8uFODOPVnGWPpiwFMd1hU7R0OjDF53xuTub17IQLW5xLq4Gp(knAslk9XB4Ky4FwY7fwa4j7xQ5OfpfaoHF79UOAjC(vjeoUJFZ4R0OjTyGkcCsm8U8SK3lSaWt2VuZrlEkaUUvbl80yRNcqo8Ij5Dm1aqlAIspPlw0LNL8EHfaEY(LAoAXtbWvulSVfEAS1tbihEXK8oMAaOfnrPN0kRCHNL8EHfaEY(v8vA0KwmqfHRO276DUPVnWWD9HB)pnv67ddc6dLaekl2WQo9o30h3rEYO(mN87lWmc0hItOHO9XO)(8bZuD6Dr1s48l6FAQ0JxLuHaoeqmHNPMAHgqH637IQLW5x0)0uP3D8Bw6HqTaIjmhsqdPYrVlQwcNFr)ttLE3XVjpta0zmciMi4(eaAo9UOAjC(f9pnv6Dh)MyWkZtArW9jqAKOKcvCsm8pl59cla8K9l1C0INcGR43QyrqKAbPGgBfA9VYX1Tfx9UOAjC(f9pnv6Dh)MSmGeJJC4fL(4nCsm8pl59cla8K9l1C0INcGR43QyrqKAbPGgBfA9VYX1Tfx9UOAjC(f9pnv6Dh)Mv4uPXaHrAbMpujC85qIQg)2ItIH3svIt4rfxflIX49cavDcapjSuL4eFvxSOfaEYwwQscdk0jXjU17IQLW5x0)0uP3D8BcswwpjYr8SrL6Dr1s48l6FAQ07o(nbuWMdVaZhQ037IQLW5x0)0uP3D8BIgc8Afuoca9WjMk17IQLW5x0)0uP3D8BAoKGzkHmJwGbbvQ317CtF7v8wFOCN0t9TxXB5W3xuTeo)QpeY6lS(CsEhc0hliHG04Opd237abwF1euzsRVCmcayyT(QWrNwcNVp40NBjhDFiua2eLTp4O35M(2MN6dHcqo89XvY7yQbG6lX6JditFOtVVpN06JgidVtFwa4j77lgDFOeenb6d3FWy(eo9fJUpUhm1yqGAFbG6BGwFak0CGtFqqFgSpaHbO3PpeuoUbL6do9zOH9bb9PcbuFwa4j7x9UOAjC(vfDf)tbihEXK8oMAaiCyEsG2j9KOgVLdpEuXPYr1tcla8K94rfNedVlkcqgLEA9uaYHxmjVJPgasuzmigwH9veGmk90InfqGqbM45yQIkC0PLWr5IfDrdT17eAiAbAiqlyJCwacdqVtu6Pcpl59cla8K9l1C0INcGROQCVZn9H4abwF7vcQmP1hcfGC47JRK3Xuda1xfo60s40Nb7dfeX2hckh3Gs9XW2xo9H7G429UOAjC(vfD1D8B(uaYHxmjVJPgachMNeODspjQXB5WJhvCQCu9KWcapzpEuXjXWBHNgB9uaYHxmjVJPgaArtu6jDbn0wVtOHOfOHaTGnYzbima9orPNk8SK3lSaWt2VuZrlEkaUUvVZn9bhphIk6AFQbkOVpZH6lQwcN(GJNJ(y(O0t9Pza5W3x1jMH85W3xm6(gO1x89f9biEgFa6lQwcNvVlQwcNFvrxDh)MQ5OfL(4nCGJNdrfDfpQ9UENB6ZTe50hUdLW9WPV3bY419vHkiqFH33higE67dI1NfaEY((Ir33xPjaj87Dr1s48l1ih3XVzn8EruTeocF(gotOs4lHWbN3az1WJkojg(sgmSvjeociMWCir8vA0KEXW27IQLW5xQroUJFtD(SKxOg8zT35M(q4yQ9XW2h3dMAmiqTVy09Hsq0eOpC)bJ5t403EbHEne989fJUpiwFmFo89H7bnUxFSqOVVC(ysJJ(kjmiG6RgVLd)Q3fvlHZVuJCCh)MkGPwqagwlHdojgEfbiJspTytbeiuGjEoMQOchDAjCkKZhtAC4kEohx9o30NBjqb13ZaO(4aY0hlJ1hdBFiOCCdk1hUdb3Hs9bN(mhQpla8K1xI1hkheMdgJVpu2bbsQV8h3Q1xuTubT6Dr1s48l1ih3XV57eAiAbAiqlyJCWjXWxYGHTWcsWZeaDgZVyylSVMkzWWwObH5GX4fybbsAXW27IQLW5xQroUJFZA49IOAjCe(8nCMqLWx1FVZn952n5D6dLajeKgh95wYr3hcfG(IQLWPpd2hGWa070h3bv67dDAo99uaYHxmjVJPgaQ3fvlHZVuJCCh)MQ5OfpfaCQCu9KWcapzpEuXjXWBHNgB9uaYHxmjVJPgaArtu6jDHNL8EHfaEY(LAoAXtbWvxueGmk90snhT4PaiQmgedZDuvUW(AOTENqdrlqdbAbBKZYYkkYHVW(vi0RHONLAo6sA0eyXW27CtFOeGWiqFgSpMN6J7c1jSeo9H7qWDOuFjwFXWrFChuP(YVVbA9XWU6Dr1s48l1ih3XVPouNWs4GtLJQNewa4j7XJkojg(9veGmk90k8EHgAVGHT35M(2MN6J7btDFBa9wFH1NtY7qG(ybjeKgh9HonN(C7Ym8eih((4EWu3hdBFgSpoVpla8K940he0h0CiqFw4PX((GtFikT6Dr1s48l1ih3XVPcyQfLqVHtIHpNpM04Gt43d3k4Ilw4PXwomdpbYHxOaM6fnrPN0fEwY7fwa4j7xQ5OfpfaoXnLlw8zjVxybGNSFPMJw8uaWJQY9o30h3bh3Q1hZt9XDKcidih((qjFWZq9Ly9XbKPVAm9XtwF5yW(4EWuJbbQ9LZBuOXPpiOVeRpeka5W3hxjVJPgaQV87ZcpngP7lgDFOtVVpN06JgidVtFwa4j7x9UOAjC(LAKJ743utkGmGC4fS(GNHWPYr1tcla8K94rfNedVlacdqVtu6PIfZ5JjnoCDV5MYf2xraYO0tl2uabcfyINJPkQWrNwcNcUSVfEAS1tbihEXK8oMAaOfnrPN0fl6IfEAS1tbihEXK8oMAaOfnrPN0f2xraYO0tRNcqo8Ij5Dm1aqIkJbXWuw5ENB6BBEQpU3g9bN(2lURVeRpoGm9PHJB16Bis3Nb7RgV1h3rkGmGC47dL8bpdHtFXO7ZCia1xaO(80)9zoX0hN3NfaEY((GmwFUWT(qNMtFv4Ozst5vVlQwcNFPg54o(nvatTOe6nCsm8pl59cla8K9l1C0INcaNCHZDVchntAlD(pCIXeu1bs)IMO0tALlKZhtACWj87HB9o30328uFioHgIUpuoeOXn9XDuyo9Ly9zouFwa4jRV87lkHmwFgSpDs9bb9XbKPpNqb1hItOHOX8Hk1hkbYxTpIZyswws3h60C6ZTKJUKgnb6dc6dXj0q0yjn6(IQLkOvVlQwcNFPg54o(nFNqdrlqdbAHMcZbNkhvpjSaWt2JhvCsm8UybGNSLdfEZzXwnoTfUk8SK3lSaWt2VuZrlEkaCIZvUyrxyjBHL0Oxr1sfubaZqyqapTENqdrJ5dvsWcYxDrCgtYYsAL7DUPVT5P(qyaaA0eOpd2NBj0d9FFWPVOpla8K1N5ewF53hpmh((myF6K6lS(mhQpqY7y9zPkT6Dr1s48l1ih3XV5Zaa0OjGWGc1qp0)4u5O6jHfaEYE8OItIH3capzllvjHbf6K40wCRqjdg2sbm1yqG6sdrp9UOAjC(LAKJ743unhDjnAcGtIHxdTLIqLnbzvyqMQZYYkkYHVGlUyHNgB9uaYHxmjVJPgaArtu6jDHNL8EHfaEY(LAoAXtbWvxueGmk90snhT4PaiQmgedZDuvw5If1qB9oHgIwGgc0c2iNLLvuKdVY9o30328uFCpyQ7tjiaqJ1hC8C0xI1hckh3Gs9fJUpUNs9faQVOAPcQVy09zouFwa4jRp0WXTA9PtQpndih((mhQVQtmd5x9UOAjC(LAKJ743ubm1cdca0y4u5O6jHfaEYE8OItIHxraYO0tln0EbdBbla8KTSuLeguOtY1TxOKbdBPaMAmiqDPHONcpl59cla8K9l1C0INcaNCHBU7Y2IYKfEASLHoFtaXeyHrlAIspPvw5ENB6BBEQpeuoUH76dDAo9HsroLakqbb6dL(WR2hZ4P)7ZCO(SaWtwFOtVVVsQVsYdr33w4cL5(kjmiG6ZCO(QqOxdrp9vHQ03xzurrVlQwcNFPg54o(nFNqdrlqdbAHMcZbNedpGzimiGNwSroLakqbbeSF4vxeNXKSSKUGIaKrPNwAO9cg2cwa4jBzPkjmOGTAITWLRUuHqVgIEwVtOHOfOHaTqtH5S0mGWs44oFvRCVZn9Tnp1x499vDcap99bX6dXj0q09TxG4D6lN(I(aq09bN(qYH3t9zbGNmC6dc6lX6ZCO(kH)3x(9fLqgRpd2NoPvVlQwcNFPg54o(nFNqdrlQG4DWjXW)SK3lSaWt2VENqdrlQG4DWJAbxQqOxdrpR3j0q0IkiENv1ja80JF7flQPsgmS17eAiArfeVJqtLmyylg2IfJQLWz9oHgIwubX7SYrG5tEhRyrla8KTSuLeguOtItvi0RHON17eAiArfeVZcJX7faQ6eaEsyPkPCbqKAbPGgBfA9VYX1TJRENB6BBEQpeNqdr33EbI3Pp403EXD9XmE6)(mhcq9faQVqR)(YPcvZHF17IQLW5xQroUJFZ3j0q0IkiEhCsm8Gi1csbn2k06FLJRBhxfEwY7fwa4j7xVtOHOfvq8oUIAVZn9Tnp1NBjhDFiua6ZG9vHZZOs9XDbaf9PKdKH3X((ybW63hC6d352WTx9PKBJ7CB9TxWblbQ9LFFMt(9LFFrFojVdb6JfKqqAC0N5etFasdnlh((GtF4o3gUDFmJN(VpDaqrFMdKH3X((YVVOeYy9zW(SuL6dYy9UOAjC(LAKJ743unhT4PaGtLJQNewa4j7XJkojg(NL8EHfaEY(LAoAXtbWvfbiJspTuZrlEkaIkJbXWkuYGHT0bafcZbYW7ylgwCQoro4rfNCmcayynrQQs6mmcpQ4KJraadRjsm8wwrX7k(T6DUPVT5P(Cl5O7dLTp4Opd2xfopJk1h3fau0NsoqgEh77JfaRFFWPpeLw9PKBJ7CB9TxWblbQ9Ly9zo53x(9f95K8oeOpwqcbPXrFMtm9bin0SC47Jz80)9Pdak6ZCGm8o23x(9fLqgRpd2NLQuFqgR3fvlHZVuJCCh)MQ5Ofy(GdCsm8LmyylDaqHWCGm8o2IHTGIaKrPNwAO9cgwCQoro4rfNCmcayynrQQs6mmcpQ4KJraadRjsm8wwrX7k(TkuHqVgIEwkGPwuc92IHT35M(2MN6ZTKJUVn8XB9Ly9XbKPpnCCRwFdr6(myFacdqVtFChuPF1hIbz7RgVLdFFH1hN3he0Nkeq9zbGNSVp0P50hcfGC47JRK3Xuda1NfEAmsV6Dr1s48l1ih3XVPAoArPpEdNedVIaKrPNwAO9cg2cGi1csbn2sfQGuPXw54AnEtyPk5oUwCRGlpl59cla8K9l1C0INcaN48If33cpn26PaKdVysEhtna0IMO0tAL7Dr1s48l1ih3XVPIqLnbzvyqMQdovoQEsybGNShpQ4Ky4begGENO0tfSaWt2YsvsyqHojx32IfDXcpn2snFcWXIMO0t6cAOTENqdrlqdbAbBKZcqya6DIspPCXILmyylMbJb4ZHxOdakg6)fdBVZn9HWs1m89vHJoTeo9zW(EdY2xnElh((qq54guQp40heddLLfaEY((q7qtFyjVJLdFFBVpiOpviG67TOIcs3NkS87lgDFmFo89HsphvNS2hUxoOOVy09XLBtP(Cl5taow9UOAjC(LAKJ7438DcneTaneOfSro4Ky4begGENO0tfSaWt2YsvsyqHojx58c7BHNgBPMpb4yrtu6jDbl80yl2NJQtwf(CqXIMO0t6cpl59cla8K9l1C0INcGRB17CtFUDqeBFiOCCdk1hdBFWPV47tngo6ZcapzFFX3hl8)S0t40h52xjwRp0o00hwY7y5W3327dc6tfcO(ElQOG09Pcl)(qNMtFO0Zr1jR9H7Ldkw9UOAjC(LAKJ7438DcneTaneOfSro4u5O6jHfaEYE8OItIHhqya6DIspvWcapzllvjHbf6KCLZlSVfEASLA(eGJfnrPN0f23fl80yRNcqo8Ij5Dm1aqlAIspPl8SK3lSaWt2VuZrlEkaU6IIaKrPNwQ5OfpfarLXGyyUJQYkxWL9TWtJTyFoQozv4ZbflAIspPlw0fl80yl2NJQtwf(CqXIMO0t6cpl59cla8K9l1C0INcaNWVLYk37IQLW5xQroUJFt1C0INcaovoQEsybGNShpQ4Ky4FwY7fwa4j7xQ5OfpfaxveGmk90snhT4PaiQmgeddNQtKdEuXjhJaagwtKQQKodJWJko5yeaWWAIedVLvu8UIFRExuTeo)snYXD8BQMJwG5doWP6e5GhvCYXiaGH1ePQkPZWi8OItogbamSMiXWBzffVR43Qqfc9Ai6zPaMArj0Blg2ENB6BBEQpeuoUH76l((8XB9bOhcS(sS(GtFMd1Nkub17IQLW5xQroUJFZ3j0q0c0qGwOPWC6DUPVT5P(qq54guQV47ZhV1hGEiW6lX6do9zouFQqfuFXO7dbLJB4U(YVp403EXD9UOAjC(LAKJ7438DcneTaneOfSrosKNLQsU2IB7rAstkb]] )


end
