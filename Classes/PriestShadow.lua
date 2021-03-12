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
            channel = "mind_flay",

            last = function ()
                local app = state.buff.casting.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.mind_flay.tick_time ) * class.auras.mind_flay.tick_time
            end,

            interval = function () return class.auras.mind_flay.tick_time end,
            value = function () return ( state.talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * 3 end,
        },

        mind_sear = {
            channel = "mind_sear",

            last = function ()
                local app = state.buff.casting.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.mind_sear.tick_time ) * class.auras.mind_sear.tick_time
            end,

            interval = function () return class.auras.mind_sear.tick_time end,
            value = function () return state.active_enemies end,
        },

        void_torrent = {
            channel = "void_torrent",

            last = function ()
                local app = state.buff.casting.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = function () return class.abilities.void_torrent.tick_time end,
            value = 15,
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


    local ExpireVoidform = setfenv( function()
        applyBuff( "shadowform" )
        if Hekili.ActiveDebug then Hekili:Debug( "Voidform expired, Shadowform applied.  Did it stick?  %s.", buff.voidform.up and "Yes" or "No" ) end
    end, state )

    spec:RegisterHook( "reset_precast", function ()
        if buff.voidform.up or time > 0 then
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

        if talent.mindbender.enabled then
            cooldown.fiend = cooldown.mindbender
            pet.fiend = pet.mindbender
        else
            cooldown.fiend = cooldown.shadowfiend
            pet.fiend = pet.mindbender
        end

        if buff.voidform.up then
            state:QueueAuraExpiration( "voidform", ExpireVoidform, buff.voidform.expires )
        end

        -- If we are channeling Mind Sear, see if it started with Thought Harvester.
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

        if settings.pad_void_bolt and cooldown.void_bolt.remains > 0 then
            reduceCooldown( "void_bolt", latency * 2 )
        end

        if settings.pad_ascended_blast and cooldown.ascended_blast.remains > 0 then
            reduceCooldown( "ascended_blast", latency * 2 )
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
            duration = function () return 4.5 * haste end,
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
            duration = 3,
            max_stack = 1,
            tick_time = 1,
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

        measured_contemplation = {
            id = 341824,
            duration = 3600,
            max_stack = 4
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
            charges = function () return legendary.vault_of_heavens.enabled and 2 or nil end,
            recharge = function () return legendary.vault_of_heavens.enabled and 90 or nil end,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = false,
            texture = 463835,

            handler = function ()
                if azerite.death_denied.enabled then applyBuff( "death_denied" ) end
                if legendary.vault_of_heavens.enabled then setDistance( 5 ) end
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
                return 7.5 * haste
            end,
            recharge = function ()
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
            cast = 4.5,
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

            toggle = function () return not talent.mindbender.enabled and "cooldowns" or nil end,

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
            cooldown = function () return 120 - ( conduit.power_unto_others.mod and group and conduit.power_unto_others.mod or 0 ) end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135939,

            indicator = function () return group and legendary.twins_of_the_sun_priestess.enabled and "cycle" or nil end,

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

            channeling = "mind_sear",

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
            id = 205385,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = -20,
            spendType = "insanity",

            startsCombat = true,
            texture = 136201,
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
                removeBuff( "measured_contemplation" )
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

            usable = function ()
                if settings.sw_death_protection == 0 then return true end
                return health.percent >= settings.sw_death_protection, "health percent [ " .. health.percent .. " ] is below user setting [ " .. settings.sw_death_protection .. " ]"
            end,

            handler = function ()
                removeBuff( "zeks_exterminatus" )

                if legendary.painbreaker_psalm.enabled then
                    local power = 0
                    if debuff.shadow_word_pain.up then
                        power = power + 15 * min( debuff.shadow_word_pain.remains, 8 ) / 8
                        if debuff.shadow_word_pain.remains < 8 then removeDebuff( "shadow_word_pain" )
                        else debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires - 8 end
                    end
                    if debuff.vampiric_touch.up then
                        power = power + 15 * min( debuff.vampiric_touch.remains, 8 ) / 8
                        if debuff.vampiric_touch.remains <= 8 then removeDebuff( "vampiric_touch" )
                        else debuff.vampiric_touch.expires = debuff.vampiric_touch.expires - 8 end
                    end
                    if power > 0 then gain( power, "insanity" ) end
                end

                if legendary.shadowflame_prism.enabled then
                    if pet.fiend.active then pet.fiend.expires = pet.fiend.expires + 1 end
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

            usable = function () return target.time_to_die < settings.stm_timer, format( "time_to_die %.2f > %.2f", target.time_to_die, settings.stm_timer ) end,
            handler = function ()
                applyBuff( "voidform" )
                applyBuff( "surrender_to_madness" )
                applyDebuff( "target", "surrender_to_madness" )
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
            cast = function () return buff.unfurling_darkness.up and 0 or 1.5 * haste end,
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

            --[[ cooldown_ready = function ()
                return buff.dissonant_echoes.up or buff.voidform.up
            end, ]]

            handler = function ()
                removeBuff( "dissonant_echoes" )

                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 3 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 3 end
                if talent.legacy_of_the_void.enabled and debuff.devouring_plague.up then debuff.devouring_plague.expires = query_time + debuff.devouring_plague.duration end

                removeBuff( "anunds_last_breath" )
            end,

            impact = function ()
                if talent.hungering_void.enabled then
                    if debuff.hungering_void.up then buff.voidform.expires = buff.voidform.expires + 1 end
                    applyDebuff( "target", "hungering_void", 6 )
                end
            end,

            copy = 343355,

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
            cast = 3,
            channeled = true,
            fixedCast = true,
            cooldown = 30,
            gcd = "spell",

            spend = -15,
            spendType = "insanity",

            startsCombat = true,
            texture = 1386551,

            aura = "void_torrent",
            talent = "void_torrent",

            tick_time = function ()
                return class.auras.void_torrent.tick_time
            end,

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
            gcd = "totem", -- actually 1s and not 1.5s...

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

            range = 15,

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

            spend = 0.002,
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

        potion = "potion_of_spectral_intellect",

        package = "Shadow",
    } )


    spec:RegisterSetting( "pad_void_bolt", true, {
        name = "Pad |T1035040:0|t Void Bolt Cooldown",
        desc = "If checked, the addon will treat |T1035040:0|t Void Bolt's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Voidform.",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "pad_ascended_blast", true, {
        name = "Pad |T3528286:0|t Ascended Blast Cooldown",
        desc = "If checked, the addon will treat |T3528286:0|t Ascended Blast's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Boon of the Ascended.",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "sw_death_protection", 50, {
        name = "|T136149:0|t Shadow Word: Death Health Threshold",
        desc = "If set above 0, the addon will not recommend |T136149:0|t Shadow Word: Death while your health percentage is below this threshold.  This setting can help keep you from killing yourself.",
        type = "range",
        min = 0,
        max = 100,
        step = 0.1,
        width = "full",
    } )

    spec:RegisterSetting( "stm_timer", 20, {
        name = "|T254090:0|t Surrender to Madness Time",
        desc = "|T254090:0|t Surrender to Madness will kill you if your targeted enemy does not die within 25 seconds.  The addon is able to estimate time-to-die, but " ..
            "these values are estimates and fight circumstances can change quickly.  This setting allows you to reserve a little extra time, so you are less likely to cause your own death.\n\n" ..
            "Custom priorities can reference |cFFFFD100settings.stm_timer|r for their decisions.",
        type = "range",
        min = 5,
        max = 25,
        step = 0.1,
        width = "full",
    } )


    spec:RegisterPack( "Shadow", 20210311, [[deLI)bqiqHhjbCjvfOAtQQ8jqPyukroLsOvPQk0RuvvZIs4wsKK2Ls9luQAyusCmuklduYZKiX0qPIRPe02OKI(Mej14qPsDovfiRtjqZtvHUNeAFQk6FusbDqvf0cbf9qqPAIus1frPs2OQQOpkrsmsvvbNeukTskrVKskKzQQkLBsjL2Psu)uvbmukjDukPaTuvfO8uumvjIRkrQTkb6RkbSxv8xvzWKoSOfRKESknzuDzIndLptHrtPonvRMskuVwcA2s62q1UL63kgofDCvvjlh45qMUW1bz7GQVJsgVQQuDEvLwpLuaZxIA)iFy7uYHHNHCwgwwbwSzLsHn22w5dcwSByXohM4RPCymZBHPHCy6exomm2jFyDymZV1j5NsomObcCLdJDeMOfK9S3WdBO19DWzpYXHQz4tFbjwWEKJFz)HzfYRbSTpRhgEgYzzyzfyXMvkf2yBBLpiyXUHvPCysOWEahgghh2pm2oNl9z9WWf09WWyN8HfPwf4ckilT2eCTjLn2SGuyzfyXgzjzzjSKSqsl44CslzaaPdszzlnPrcmKG07a1bI0eiKInGRW3hMQJc0PKddxWsOACk5SmBNsom5n8PpmiVk9vomsNRvHFG5joldRtjhgPZ1QWpW8WCbEiappmRqyyB4JZXga(gYK0YLjDfcdBBoSeWZBmiKp9gY8WK3WN(WyoHp9jolxkNsomsNRvHFG5Hzmpmijom5n8PpmWtGNRv5WapRqYHHpXgzN8H1J1a4pZ07D43c92G0FKYNydpXnDGFFXaDT3HFl0BJdd8e86exom8jqpiZtCwMDoLCyKoxRc)aZdZyEyqsCyYB4tFyGNapxRYHbEwHKddFInYo5dRhRbWFMP37WVf6TbP)iLpXgEIB6a)(Ib6AVd)wO3gK(Ju(eBUaFGaEB8mRPbKSd)wO3ghg4j41jUCyYA9XNa9GmpXz5fEk5WiDUwf(bMhMX8WGK4WK3WN(WapbEUwLdd8ScjhgKPuRVibgsG24EZFijbK(jPWI0)jDfcdBdFCo2aW3qMhgUGUa3m8PpmmrccsHqEBqkJKaVniDz3WoWtGqAgKwk)tAKadjqKoaszN)j1Xi97arAces9M0coohBa4hg4j41jUCyqsc8241UHDGNa5DHIbd7eNLTMNsomsNRvHFG5Hzmpmijom5n8PpmWtGNRv5WapRqYH5otLpS6n8X5pbazg(0Bits)r6sKcdsbPZFcCPJDY5OnKjPLltkiD(tGlDStohT5qGm8Pj9JfjLnRqA5YKcsN)e4sh7KZrBGGNEJi9ZIKYMvi9FsxiP)rsxI0iRshBBO2qaEB8GpoFlDUwfoPLlt6DGlD2XUWVapBsxK0fj9hPlr6sKcsN)e4sh7KZrBVj9tsHLviTCzsrMsT(IeyibAdFC(taqMHpnPFwK0fs6IKwUmPrwLo22qTHa824bFC(w6CTkCslxM07ax6SJDHFbE2KU4HHlOlWndF6ddSptLpSAsT6mvslyc8CTkwqAPrcN0yi1CMkPRc2aesZB4WZWBdsHpohBa4BsHDiaq6O(LuiKWjngsVthGPsklBPjngsZB4WZqif(4CSbGtklpSj177G7TbPjNJ2hg4j41jUCymNP(WgW7YrN4SCP(uYHr6CTk8dmpmxGhcWZdZkeg2g(4CSbGVHmpm5n8PpmyoqwRZWpXzz29PKdJ05Av4hyEyUapeGNhMvimSn8X5ydaFdzEyYB4tFywfasaf6TXjol)bDk5WiDUwf(bMhM8g(0hMQByhON1yiUbU0XHHlOlWndF6dtPrcP)n3WoGnisTeIBGlDqQJrAylaH0eiKclshaP4dqinsGHeiliDaKMCoI0einSjifzMSAVnifBaKIpaH0WoBsl1leTpmxGhcWZddYuQ1xKadjq7QByhON1yiUbU0bPFwKuyrA5YKUePWGuq68Nax6yNCoAl)DhfislxMuq68Nax6yNCoA7nPFsAPEHKU4jolZMvoLCyKoxRc)aZdZf4Ha88WScHHTHpohBa4BiZdtEdF6dt2xbfGS(UzTEIZYSX2PKdJ05Av4hyEyYB4tFyUzT(YB4t)QokomvhfVoXLdZL19eNLzdwNsomsNRvHFG5HjVHp9Hba1V8g(0VQJIdt1rXRtC5WGNEFItCy44gVa4DHsGoLCwMTtjhgPZ1QWpW8W0jUCy4jOq8z6hxUf(EMqbqqxPVYHjVHp9HHNGcXNPFC5w47zcfabDL(kN4SmSoLCyKoxRc)aZdtN4YHbb1R1z4Vexc7VO4WK3WN(WGG616m8xIlH9xuCIZYLYPKdJ05Av4hyEy6exomg1VM2Vb7LiKJ71m8Ppm5n8Ppmg1VM2Vb7LiKJ71m8PpXzz25uYHr6CTk8dmpmDIlhgoqsoMdKhCbHK6HjVHp9HHdKKJ5a5bxqiPEItCyWtVpLCwMTtjhgPZ1QWpW8WCbEiappmRqyy71z63G9cB5LOR0CHVHmpmOa434SmBhM8g(0hMBwRV8g(0VQJIdt1rXRtC5WSotFIZYW6uYHjVHp9HH7itP(Wtd)EyKoxRc)aZtCwUuoLCyKoxRc)aZdtEdF6dd8X5pbazg(0hgUGUa3m8PpmLgjKwWX5KYUaqMHpnPtt6DMkFy1KAot1BdsZG0QKOGu2XkK6nkBp(s6kuqApbPogPFhisz51kPdCbCtts9gLThFj1Bsl4FUj1AZcfsrqaHuKDYhwyU0C2J7nFvAUainBoPwR3CsHznrbPoI0Pj9otLpSAsxfSbiKwq21MuyRrpaHuZzQEBqkqqbWVHpnIuhJuiK3gKYyN8HfwnXfsTkWr4KMnNuyknxaK6ishOyFyUapeGNhg4jWZ1QSnNP(WgW7YrK(J0Li1Bu2E8L0plsk7yfslxMutj2yU08DEdhUq6psbqTGnadzJSt(WcRM4YZe4i8T8xqUPPWj9hPWG07mv(WQ34EZFR1efBits)rkmi9otLpS6nYo5dRhRbWFCjd7nKjPls6psxIuVrz7Xxs)yrsz3lK0YLjnYQ0XgjjWBJx7g2bEcKT05Av4K(Ju4jWZ1QSrsc8241UHDGNa5DHIbdJ0fj9hPWG07mv(WQ3yU08nKjP)iDjsHbP3zQ8HvVX9M)wRjk2qMKwUmPitPwFrcmKaTX9M)qsci9tsHfPlEIZYSZPKdJ05Av4hyEyYB4tFyq2jFy9yna(Zm9(WWf0f4MHp9HXAZcfsrqaH0VdePMqbPqMKYSalOvj9dz(qRs60Kg2cPrcmKGuhJ0faKHnguL0)mfGlK6Og2eKM3WHlKYYwAsXCd7WBdszRuTuinsGHeO9H5c8qaEEywHWW2yP8mGsa3ZgTHmj9hPWGuUScHHTzbYWgdQ(Wsb4YgYK0FKImLA9fjWqc0g3B(djjG0psk7CIZYl8uYHr6CTk8dmpm5n8Ppm3SwF5n8PFvhfhMQJIxN4YH5YrN4SS18uYHr6CTk8dmpm5n8Ppm4EZFijbhM73BvErcmKaDwMTdZf4Ha88Wezv6yJKe4TXRDd7apbYw6CTkCs)rkYuQ1xKadjqBCV5pKKas)Ku4jWZ1QSX9M)qscExOyWWi9hPWGu(eBKDYhwpwdG)mtV3HFl0Bds)rkmi9otLpS6nMlnFdzEy4c6cCZWN(W8hCdBsTkWhGhFj1A9MtkJKasZB4ttAmKcemGGSj16tjisz5HnPijbEB8A3WoWtGCIZYL6tjhgPZ1QWpW8WK3WN(WWt8odF6dZ97TkVibgsGolZ2H5c8qaEEyGbPWtGNRvzN16Jpb6bzEy4c6cCZWN(WyvGGjasJHuiKqQ1t8odFAs)qMp0QK6yKM9xsT(ucPoI0EcsHm3N4Sm7(uYHr6CTk8dmpm5n8Ppm4EZFR1efhgUGUa3m8PpmW2gfzh1VKImLMtAskU3CsxRjki9ANadH0eleaPWhNVo1GuhJuiK3gKISt(WcRM4cPMahHtA2CsX9MVwtuGinbcP300u47dZf4Ha88WCNPYhw9g3B(BTMOyFTtGHGi9tszJ0FKAkXgZLMVZB4Wfs)rkaQfSbyiBKDYhwy1exEMahHVL)cYnnfoP)ifgKENPYhw9g(4836uJnK5jol)bDk5WiDUwf(bMhM8g(0hg4JZFRtnomCbDbUz4tFyknsiTGJZjfMtnindsTDdBbqQjWhGhFjLLh2K(hGAdb4TbPfCCoPqMKgdPSdPrcmKazbPdG0jSfaPrwLoqKonPmLSpmxGhcWZdJ3OS94lPFSiPS7fs6psJSkDSTHAdb4TXd(48T05Av4K(J0iRshBKKaVnETByh4jq2sNRvHt6psrMsT(IeyibAJ7n)HKeq6hlsQ1K0YLjDjsxI0iRshBBO2qaEB8GpoFlDUwfoP)ifgKgzv6yJKe4TXRDd7apbYw6CTkCsxK0YLjfzk16lsGHeOnU38hssaPfjLnsx8eNLzZkNsomsNRvHFG5HjVHp9HHlWhiG3gpZAAajhgUGUa3m8PpmwFAytqkesi16c8bc4TbPwTMgqcPogPFhisVztQHeK6DmKwWX5ydaNuVrHKCliDaK6yKYijWBdsx2nSd8eiK6isJSkDiCsZMtklVwj12dsLEGmSjnsGHeO9H5c8qaEEywIuGGbeKDUwfslxMuVrz7Xxs)K0s9cjDrs)r6sKcdsHNapxRY2CM6dBaVlhrA5YK6nkBp(s6NfjLDVqsxK0FKUePWG0iRshBKKaVnETByh4jq2sNRvHtA5YKUePrwLo2ijbEB8A3WoWtGSLoxRcN0FKcdsHNapxRYgjjWBJx7g2bEcK3fkgmmsxK0fpXzz2y7uYHr6CTk8dmpm5n8PpmWhN)wNACy4c6cCZWN(WuAKqAbHjPttkSBDsDms)oqKYNg2eK2IWjngsVjki16c8bc4TbPwTMgqIfKMnN0WwacPjqiTkiePHD2KYoKgjWqcePduq6slKuwEyt6DAoKhlUpmxGhcWZddYuQ1xKadjqBCV5pKKas)iPlrk7q6)KENMd5XM7i00zhp5ApcAlDUwfoPls6ps9gLThFj9JfjLDVqs)rAKvPJnssG3gV2nSd8eiBPZ1QWjTCzsHbPrwLo2ijbEB8A3WoWtGSLoxRc)eNLzdwNsomsNRvHFG5HjVHp9HbzN8H1J1a4pUKH9H5(9wLxKadjqNLz7WCbEiappmlrAKadj22swd7T5ni9JKclRq6psrMsT(IeyibAJ7n)HKeq6hjLDiDrslxM0Li1uInMlnFN3WHlK(JuaulydWq2i7KpSWQjU8mbocFl)fKBAkCsx8WWf0f4MHp9HP0iHug7KpSiDbgaFbj16sg2K6yKg2cPrcmKGuhrAUoqbPXqk3fshaPFhisTt4cPm2jFyHvtCHuRcCeoPYFb5MMcNuwEytQ16nFvAUaiDaKYyN8HfMlnN08goCzFIZYSvkNsomsNRvHFG5HjVHp9HbbbasZfWlMhEYBbHom3V3Q8Ieyib6SmBhMlWdb45HjsGHe7WXLxmpUlK(rsH1cj9hPRqyyB4JZXga(MpS6ddxqxGBg(0hMsJeszGaaP5cG0yi1AtEliePttAsAKadjinSZGuhrQX4TbPXqk3fsZG0Wwif4g2bPHJl7tCwMn25uYHr6CTk8dmpm5n8PpmWhN)IbaKoom3V3Q8Ieyib6SmBhMlWdb45HbEc8CTkB(eOhKjP)insGHe7WXLxmpUlK(jPLcP)iDjsxHWW2WhNJna8nFy1KwUmPRqyyB4JZXga(gi4P3is)iP3zQ8HvVHpo)To1yde80BePls6psZB4WLhFIn8e30b(9fd01M0IKImLA9fjWqc0gEIB6a)(Ib6At6psrMsT(IeyibAJ7n)HKeq6hjDjsxiP)t6sKAnj9psAKvPJDWYrXBWEyziBPZ1QWjDrsx8WWf0f4MHp9HP0iH0cooN0sgaq6G0PRFj1XiLzbwqRsA2CslyjKMaH08goCH0S5Kg2cPrcmKGuwtdBcs5Uqkhc4TbPHTq61o7wQ7tCwMTfEk5WiDUwf(bMhMlWdb45HHpXgEIB6a)(Ib6AVd)wO3gK(J0LinYQ0XgjjWBJx7g2bEcKT05Av4K(JuKPuRVibgsG24EZFijbK(jPWtGNRvzJ7n)HKe8UqXGHrA5YKYNyJSt(W6XAa8Nz69o8BHEBq6IK(J0LifgKcGAbBagYgzN8HfwnXLNjWr4B5VGCttHtA5YKM3WHlp(eB4jUPd87lgORnPfjfzk16lsGHeOn8e30b(9fd01M0fpm5n8Ppm4EZxLMlGtCwMnR5PKdJ05Av4hyEyYB4tFyq2jFy9yna(JlzyFy4c6cCZWN(WuAKqkZcSGwNuwEytQvtVxbswOai1QOSItkuxfeI0WwinsGHeKYYRvsxfsxL6WIuyzLp4KUkydqinSfsVZu5dRM07GlisxZBHhMlWdb45Hba1c2amKTz69kqYcfWZeLv8T8xqUPPWj9hPWtGNRvzZNa9Gmj9hPrcmKyhoU8I5zEJhSScPFs6sKENPYhw9gzN8H1J1a4pUKH9MdbYWNM0)j14YjDXtCwMTs9PKdJ05Av4hyEyYB4tFyq2jFy9UGezFy4c6cCZWN(WuAKqkJDYhwKc7Gezt60Kc7wNuOUkiePHTaestGqAY5is9(o4EBSpmxGhcWZddiD(tGlDStohT9M0pjLnRCIZYSXUpLCyKoxRc)aZdZf4Ha88WGmLA9fjWqc0g3B(djjG0pjfEc8CTkBCV5pKKG3fkgmms)r6keg2MNGcFH9azyhBiZddxqxGBg(0hMsJesTwV5KYijG0yi9onccxi16jOqslXEGmSdePMG5IiDAs)Wpa7AtAjFaR)bif2NgZb4K6isdBhrQJinj12nSfaPMaFaE8L0WoBsbcFIWBdsNM0p8dWUifQRccrkpbfsAypqg2bIuhrAUoqbPXqA44cPduCyUFVv5fjWqc0zz2omEhcaazgph7We(Tq0NfH1HX7qaaiZ4544c3ZqomSDyU2P3hg2om5n8Ppm4EZFijbN4SmBFqNsomsNRvHFG5HHlOlWndF6dtPrcPwR3Cs)ZA(L0yi9onccxi16jOqslXEGmSdePMG5IiDAszkztAjFaR)bif2NgZb4K6yKg2oIuhrAsQTBylasnb(a84lPHD2Kce(eH3gKc1vbHiLNGcjnShid7arQJinxhOG0yinCCH0bkomxGhcWZdZkeg2MNGcFH9azyhBits)rk8e45Av28jqpiZdJ3HaaqMXZXomHFle9zry97otLpS6n8X5V1PgBiZdJ3HaaqMXZXXfUNHCyy7WCTtVpmSDyYB4tFyW9M)WQ53tCwgww5uYHr6CTk8dmpm5n8Ppm4EZFR1efhgUGUa3m8PpmLgjKATEZjfM1efK6yK(DGiLpnSjiTfHtAmKcemGGSj16tjOnPmXys6nrH3gKMbPSdPdGu8biKgjWqcePS8WMugjbEBq6YUHDGNaH0iRshcN0S5K(DGinbcP9eKcH82Gug7KpSWQjUqQvbocN0bqQvrFV2(L0)M3fUrMsT(IeyibAJ7n)HKe8P1WfsQHeisdBHuCVDCiCshmsxiPzZjnSfsBi8vbq6GrAKadjq7dZf4Ha88WapbEUwLnFc0dYK0FKcsN)e4shB8bUGlDS9M0pj9MO4foUq6)KAL9cj9hPitPwFrcmKaTX9M)qsci9JKUePSdP)tkSi9psAKvPJnUJeW3T05Av4K(pP5nC4YJpXgEIB6a)(Ib6At6FK0iRshBt03RTFFvVlClDUwfoP)t6sKImLA9fjWqc0g3B(djjG0pTgs6cjDrs)JKUePMsSXCP578goCH0FKcGAbBagYgzN8HfwnXLNjWr4B5VGCttHt6IKU4joldl2oLCyKoxRc)aZdtEdF6dd8e30b(9fd01(WCbEiappmabdii7CTkK(J0ibgsSdhxEX84Uq6NKAnjTCzsxI0iRshBChjGVBPZ1QWj9hP8j2i7KpSESga)zMEVbcgqq25AviDrslxM0vimSnuJbbQEB84jOWwqOnK5H5(9wLxKadjqNLz7eNLHfSoLCyKoxRc)aZdtEdF6ddYo5dRhRbWFMP3hgUGUa3m8PpmmMY1ZkP3P5E4ttAmKIIXK0BIcVniLzbwqRs60KoyyLQrcmKarklBPjfZnSdVniTuiDaKIpaHuuK3cfoP4ZkI0S5KcH82GuRI(ET9lP)nVlK0S5KU8hOesTwhjGV7dZf4Ha88WaemGGSZ1Qq6psJeyiXoCC5fZJ7cPFsk7q6psHbPrwLo24osaF3sNRvHt6psJSkDSnrFV2(9v9UWT05Av4K(JuKPuRVibgsG24EZFijbK(jPW6eNLHvPCk5WiDUwf(bMhM8g(0hgKDYhwpwdG)mtVpm3V3Q8Ieyib6SmBhMlWdb45HbiyabzNRvH0FKgjWqID44YlMh3fs)Ku2H0FKcdsJSkDSXDKa(ULoxRcN0FKcdsxI0iRshBKKaVnETByh4jq2sNRvHt6psrMsT(IeyibAJ7n)HKeq6NKcpbEUwLnU38hssW7cfdggPls6psxIuyqAKvPJTj6712VVQ3fULoxRcN0YLjDjsJSkDSnrFV2(9v9UWT05Av4K(JuKPuRVibgsG24EZFijbK(XIKclsxK0fpmCbDbUz4tFySgjIjPmlWcAvsHmjDAsteP4z)L0ibgsGinrKAoiKVwfliv(7xXmiLLT0KI5g2H3gKwkKoasXhGqkkYBHcNu8zfrklpSj1QOVxB)s6FZ7c3N4SmSyNtjhgPZ1QWpW8WK3WN(WG7n)HKeCyUFVv5fjWqc0zz2omEhcaazgph7We(Tq0NfH1HX7qaaiZ4544c3ZqomSDyUapeGNhgKPuRVibgsG24EZFijbK(jPWtGNRvzJ7n)HKe8UqXGHDyU2P3hg2oXzzyTWtjhgPZ1QWpW8WK3WN(WG7n)HvZVhgVdbaGmJNJDyc)wi6ZIW63DMkFy1B4JZFRtn2qMhgVdbaGmJNJJlCpd5WW2H5ANEFyy7eNLHL18uYHr6CTk8dmpmCbDbUz4tFyknsiLzbwqRtAIiTMOGuGGgqqQJr60Kg2cP4dC5WK3WN(WGSt(W6XAa8hxYW(eNLHvP(uYHr6CTk8dmpmCbDbUz4tFyknsiLzbwqRsAIiTMOGuGGgqqQJr60Kg2cP4dCH0S5KYSalO1j1rKonPWU1pm5n8Ppmi7KpSESga)zMEFItCymbYDWxZ4uYzz2oLCyKoxRc)aZdZf4Ha88Wae80BePFK0sXkw5WK3WN(WyoSeWJ1a4pSbeEaXLtCwgwNsomsNRvHFG5H5c8qaEEyGbPRqyyBKDYhwydaFdzEyYB4tFyq2jFyHna8tCwUuoLCyKoxRc)aZdZf4Ha88W4nkBp(U5cMF9G0pjLTfEyYB4tFysWnB5fdaiDCIZYSZPKdJ05Av4hyEygZddsIdtEdF6dd8e45AvomWZkKCyG1HbEcEDIlhgCV5pKKG3fkgmStCwEHNsom5n8PpmWtCth43xmqx7dJ05Av4hyEItCyUC0PKZYSDk5WiDUwf(bMhM8g(0hgZHLaEEJbH8PpmCbDbUz4tFyknsi1QdlbqkSTXGq(0KYYdBsl44CSbGVj9pmvoPydG0coohBa4KEhCbr6GHr6DMkFy1K6nPHTqAl)9Gu2ScPi5onhr6e2cGLJesHqcPtt6LtkuxfeI0Wwi1QsnngePLaspif2h81mi1AfUhz4ttQJinYQ0HWTG0bqQJrAylaHuwETsApbPRcPzpHTaiTGJZjLDbGmdFAsdBhrkMByhBs)WieCZG0yif9TVKg2cP1efKAoSeaPEJbH8PjDWinSfsXCd7G0yif(4CsfaKz4ttk2aiTNMuRrFbE2O9H5c8qaEEymbUGInsQypZHLaEEJbH8Pj9hPlr6keg2g(4CSbGVHmjTCzsHbPObQU6nFFh81mE4c3Jm8P3sNRvHt6psVZu5dREdFC(taqMHp9gi4P3is)SiPSzfslxMum3WoEabp9gr6hj9otLpS6n8X5pbazg(0BGGNEJiDrs)r6sKI5g2Xdi4P3is)SiP3zQ8HvVHpo)jaiZWNEde80BeP)tkBlK0FKENPYhw9g(48NaGmdF6nqWtVrK(XIKAC5K(hjLDiTCzsXCd74be80BePFs6DMkFy1BZHLaEEJbH8P3Ciqg(0KwUmPyUHD8acE6nI0ps6DMkFy1B4JZFcaYm8P3abp9gr6)KY2cjTCzsVdCPZo2f(f4zt6IN4SmSoLCyKoxRc)aZddxqxGBg(0hMsJesHzYnes9g5CH0bJ0c(NKInasdBHumhGcsHqcPdG0Pjf2ToPjwiasdBHumhGcsHqYM0fWdBsx2nSds)Zui1EQCsXgaPf8p3hMoXLddYBmO6ZOMCpJbGERj3qEd2dtaZ1JVhMlWdb45HzfcdBdFCo2aW3qMKwUmPHJlK(jPSzfs)r6sKcdsVdCPZo2TByhpSuiDXdtEdF6ddYBmO6ZOMCpJbGERj3qEd2dtaZ1JVN4SCPCk5WiDUwf(bMhM8g(0hgSuEgqjG7zJomCbDbUz4tFyknsi9ptH0sfOeW9SrKonPWU1jDGcKZfshmsl44CSbGVjT0iH0)mfslvGsa3ZMJi1Bsl44CSbGtQJr63bIu7eUqQ4HTaiTubmWfsHTnC3yaz4tt6ai9pDPYjDWifM1bHgC0(WCbEiappmWG0vimSn8X5ydaFdzs6psxIuyq6DMkFy1B4JZFXaashBitslxMuyqAKvPJn8X5VyaaPJT05Av4KUiPLlt6keg2g(4CSbGVHmj9hPlrkAGQREZ3gGbU88gUBmGm8P3sNRvHtA5YKIgO6Q38nMlv(BWER1bHgC0w6CTkCsx8eNLzNtjhgPZ1QWpW8WK3WN(WG7n3iXf0H5(9wLxKadjqNLz7WCbEiappmEJY2JVK(rs)GScP)iDjsxIu4jWZ1QSZA9XNa9Gmj9hPlrkmi9otLpS6n8X5pbazg(0BitslxMuyqAKvPJTnuBiaVnEWhNVLoxRcN0fjDrslxM0vimSn8X5ydaFdzs6IK(J0LifgKgzv6yBd1gcWBJh8X5BPZ1QWjTCzs5Ykeg22gQneG3gp4JZ3qMKwUmPWG0vimSn8X5ydaFdzs6IK(J0LifgKgzv6yJKe4TXRDd7apbYw6CTkCslxMuKPuRVibgsG24EZFijbK(rsxiPlEy4c6cCZWN(WuAKqQ16n3iXfePSSLM0SwjTui16tjistGqkKPfKoas)oqKMaHuVjTGJZXga(Mu2vJGacP)bO2qaEBqAbhNtQJinVHdxiDAsdBH0ibgsqQJrAKvPdHVjLjgtsHqEBqAgKUW)jnsGHeisz5HnPmsc82G0LDd7apbY(eNLx4PKdJ05Av4hyEyYB4tFyGA7P(91d88WWf0f4MHp9HP0iH0s32t9lPlpWtsNMuy36wqQ9u5EBq6kWfS6xsJHuwPhKInasnhwcGuVXGq(0KoastoNuKzYQr7dZf4Ha88WSePlrkmifKo)jWLo2jNJ2qMK(Juq68Nax6yNCoA7nPFskSScPlsA5YKcsN)e4sh7KZrBGGNEJi9ZIKY2cjTCzsbPZFcCPJDY5OnhcKHpnPFKu2wiPls6psxI0vimST5WsapVXGq(0BitslxM07mv(WQ3Mdlb88gdc5tVbcE6nI0plskBwH0YLjfgKAcCbfBKuXEMdlb88gdc5tt6IK(J0LifgKgzv6yBd1gcWBJh8X5BPZ1QWjTCzs5Ykeg22gQneG3gp4JZ3qMKwUmPWG0vimSn8X5ydaFdzs6IN4SS18uYHr6CTk8dmpm5n8PpmRZ0Vb7f2YlrxP5c)WWf0f4MHp9HP0iH0Pjf2ToPRqbPMaFaE4iHuiK3gKwWX5KYUaqMHpnPyoafwqQJrkes4K6nY5cPdgPf8pjDAszkHuiKqAIfcG0Ku4JZxNAqk2ai9otLpSAsfmm)6sF)sA2CsXgaP2qTHa82Gu4JZjfYmCCHuhJ0iRshcFFyUapeGNhgyq6keg2g(4CSbGVHmj9hPWG07mv(WQ3WhN)eaKz4tVHmj9hPitPwFrcmKaTX9M)qsci9tszJ0FKcdsJSkDSrsc8241UHDGNazlDUwfoPLlt6sKUcHHTHpohBa4Bits)rkYuQ1xKadjqBCV5pKKas)iPWI0FKcdsJSkDSrsc8241UHDGNazlDUwfoP)iDjsnbc8NXLVzBdFC(BDQbP)iDjsHbPYFb5MMcFl4MFbswFdG3zFfslxMuyqAKvPJTnuBiaVnEWhNVLoxRcN0fjTCzsL)cYnnf(wWn)cKS(gaVZ(kK(J07mv(WQ3cU5xGK13a4D2xzde80BePFSiPSznHfP)iLlRqyyBBO2qaEB8GpoFdzs6IKUiPLlt6sKUcHHTHpohBa4Bits)rAKvPJnssG3gV2nSd8eiBPZ1QWjDXtCwUuFk5WiDUwf(bMhM8g(0hMBwRV8g(0VQJIdt1rXRtC5WeaVluc0joXHjaExOeOtjNLz7uYHr6CTk8dmpmCbDbUz4tFyknsiDAsHDRt6hY8HwL0yi1qcsT(ucPHFl0BdsZMtQ83nDGqAmKw9wifYK0vjcbqklpSjTGJZXga(HPtC5Wi4MFbswFdG3zFLdZf4Ha88WCNPYhw9g(48NaGmdF6nqWtVrK(XIKYgSiTCzsVZu5dREdFC(taqMHp9gi4P3is)KuyvQpm5n8PpmcU5xGK13a4D2x5eNLH1PKdJ05Av4hyEy4c6cCZWN(WW8TVKcBTg06KYYdBsl44CSbGFy6exomEJUaOixRY7VGYoGWFCbUFLdZf4Ha88WCNPYhw9g(48NaGmdF6nqWtVrK(jPSzLdtEdF6dJ3OlakY1Q8(lOSdi8hxG7x5eNLlLtjhgPZ1QWpW8WWf0f4MHp9HH5BFjLXwKGuRfc5xsz5HnPfCCo2aWpmDIlhg88MRa5HSfjE4qi)EyUapeGNhM7mv(WQ3WhN)eaKz4tVbcE6nI0pjLnRCyYB4tFyWZBUcKhYwK4HdH87jolZoNsomsNRvHFG5HPtC5WGgOAvIWBJhaA97H5(9wLxKadjqNLz7WCbEiappmRqyyBZHLaEEJbH8P3qMKwUmPWGutGlOyJKk2ZCyjGN3yqiF6dtEdF6ddAGQvjcVnEaO1VhgUGUa3m8PpmmF7lPFWGw)sklpSj1QdlbqkSTXGq(0KcHsdXcsXZcfsrqaH0yif1UPqAylKwhwcki9pyvsJeyiXjolVWtjhgPZ1QWpW8WWf0f4MHp9HP0iHuyMCdHuVroxiDWiTG)jPydG0WwifZbOGuiKq6aiDAsHDRtAIfcG0WwifZbOGuiKSjLXEabPxhCH8GuhJu4JZjvaqMHpnP3zQ8HvtQJiLnRGiDaKIpaH0Kv(DFy6exomiVXGQpJAY9mga6TMCd5nypmbmxp(EyUapeGNhM7mv(WQ3WhN)eaKz4tVbcE6nI0plskBw5WK3WN(WG8gdQ(mQj3ZyaO3AYnK3G9WeWC947jolBnpLCyKoxRc)aZddxqxGBg(0hMsJesRokiDWiD6sviKqkpXtdH0a4DHsGiD66xsDms)dqTHa82G0cooNuRlRqyyK6isZB4WfliDaK(DGinbcP9eKgzv6q4K6DmK6X(WK3WN(WCZA9L3WN(vDuCyUapeGNhMLifgKgzv6yBd1gcWBJh8X5BPZ1QWjTCzs5Ykeg22gQneG3gp4JZ3qMKUiP)iDjsxHWW2WhNJna8nKjPLlt6DMkFy1B4JZFcaYm8P3abp9gr6NKYMviDXdt1rXRtC5WWXnEbW7cLaDIZYL6tjhgPZ1QWpW8WK3WN(WaHKNhco6WWf0f4MHp9HX6cwcvdsXYADnVfsk2aifcLRvHupeC0csAPrcPtt6DMkFy1K6nPdGlasx)sAa8UqjifvNyFyUapeGNhMvimSn8X5ydaFdzsA5YKUcHHTnhwc45ngeYNEdzsA5YKENPYhw9g(48NaGmdF6nqWtVrK(jPSzLtCIdZ6m9PKZYSDk5WiDUwf(bMhMlWdb45Hbzk16lsGHeOnU38hssaPFSiPLYHjVHp9HjrxP5c)TwtuCIZYW6uYHr6CTk8dmpmxGhcWZdtKadj2S8W2B2nP)ifzk16lsGHeODIUsZf(Rh4jPFskBK(JuKPuRVibgsG24EZFijbK(jPSr6)Kgzv6yJKe4TXRDd7apbYw6CTk8dtEdF6dtIUsZf(Rh45joXH5Y6Ek5SmBNsomsNRvHFG5Hbcjpw2EvE3efEBCwMTdtEdF6ddssG3gV2nSd8eihM73BvErcmKaDwMTdZf4Ha88WSePWtGNRvzJKe4TXRDd7apbY7cfdggP)ifgKcpbEUwLT5m1h2aExoI0fjTCzsxIu(eBKDYhwpwdG)mtV3abdii7CTkK(JuKPuRVibgsG24EZFijbK(jPSr6IhgUGUa3m8PpmLgjKYijWBdsx2nSd8eiK6yK(DGiLLxRKA7bPspqg2KgjWqcePzZj1QdlbqkSTXGq(0KMnN0coohBa4KMaH0EcsbsY)AbPdG0yifiyabztkZcSGwL0PjnynKoasXhGqAKadjq7tCwgwNsomsNRvHFG5Hbcjpw2EvE3efEBCwMTdtEdF6ddssG3gV2nSd8eihM73BvErcmKaDwMTdZf4Ha88Wezv6yJKe4TXRDd7apbYw6CTkCs)rkFInYo5dRhRbWFMP3BGGbeKDUwfs)rkYuQ1xKadjqBCV5pKKas)KuyDy4c6cCZWN(WWypGGuy3bxipiLrsG3gKUSByh4jqi9on3dFAsJH0cfXKuMfybTkPqMK6nPF4WUoXz5s5uYHr6CTk8dmpmtx)(USUhg2om5n8Ppm4EZFR1efhgUGUa3m8Ppmtx)(USUKINfkisdBH08g(0KoD9lPqOCTkKYHaEBq61o7wQEBqA2Cs7jinrKMKcedOAcinVHp9(eN4ehg4ca5tFwgwwbwSzLsHnRCyyLG2Bd0Hzb(WpyldBxUuzbjL0sSfsDCZbeKInasHnxoc2qkq(lihiCsrdUqAcfdEgcN0RD2gcAtw(38wi1AUGKc7tdxaHWjf2eaVluIDUE33zQ8HvdBingsHn3zQ8HvVZ1lSH0Ly7VV4MSKSe2IBoGq4KYUjnVHpnPvhfOnz5Hbzk3ZYWAHS7dJjyW8QCykqbiLXo5dlsTkWfuqwwGcqQ1MGRnPSXMfKclRal2iljllqbiTewswiPfCCoPLmaG0bPSSLM0ibgsq6DG6arAcesXgWv4BYsYYcuaszx)D5cfcN0vbBacP3bFndsxfdVrBs)W7vmdeP90LQ2jahdQsAEdFAePtx)UjlZB4tJ2Ma5o4Rz8Fr2BoSeWJ1a4pSbeEaXflCSIabp9g9XsXkwHSmVHpnABcK7GVMX)fzpYo5dlSbGBHJvegRqyyBKDYhwydaFdzswM3WNgTnbYDWxZ4)ISpb3SLxmaG0HfowrVrz7X3nxW8RhFY2cjlZB4tJ2Ma5o4Rz8Fr2dpbEUwfl6exkI7n)HKe8UqXGHzXywejHfWZkKuewKL5n8PrBtGCh81m(Vi7HN4MoWVVyGU2KLKLfOaKA1j8PrKL5n8PrfrEv6RqwM3WNgv0CcFAlCSIRqyyB4JZXga(gYSC5vimST5WsapVXGq(0BitYY8g(0O)lYE4jWZ1QyrN4sr(eOhKPfJzrKewapRqsr(eBKDYhwpwdG)mtV3HFl0BJF8j2WtCth43xmqx7D43c92GSmVHpn6)IShEc8CTkw0jUumR1hFc0dY0IXSisclGNviPiFInYo5dRhRbWFMP37WVf6TXp(eB4jUPd87lgOR9o8BHEB8JpXMlWhiG3gpZAAaj7WVf6TbzzbiLjsqqkeYBdszKe4TbPl7g2bEcesZG0s5FsJeyibI0bqk78pPogPFhistGqQ3KwWX5ydaNSmVHpn6)IShEc8CTkw0jUuejjWBJx7g2bEcK3fkgmmlgZIijSaEwHKIitPwFrcmKaTX9M)qsc(ew)VcHHTHpohBa4BitYYcqkSptLpSAsT6mvslyc8CTkwqAPrcN0yi1CMkPRc2aesZB4WZWBdsHpohBa4BsHDiaq6O(LuiKWjngsVthGPsklBPjngsZB4WZqif(4CSbGtklpSj177G7TbPjNJ2KL5n8Pr)xK9WtGNRvXIoXLIMZuFyd4D5ilgZIijSaEwHKI3zQ8HvVHpo)jaiZWNEdz(BjyasN)e4sh7KZrBiZYLbPZFcCPJDY5OnhcKHp9hlYMvkxgKo)jWLo2jNJ2abp9g9zr2SY)l8pUuKvPJTnuBiaVnEWhNVLoxRcVC57ax6SJDHFbE2lU4VLwcKo)jWLo2jNJ2E)jSSs5YitPwFrcmKaTHpo)jaiZWN(ZIlCXYLJSkDSTHAdb4TXd(48T05Av4LlFh4sNDSl8lWZErYY8g(0O)lYEmhiR1z4w4yfxHWW2WhNJna8nKjzzEdFA0)fz)QaqcOqVnSWXkUcHHTHpohBa4BitYYcqAPrcP)n3WoGnisTeIBGlDqQJrAylaH0eiKclshaP4dqinsGHeiliDaKMCoI0einSjifzMSAVnifBaKIpaH0WoBsl1leTjlZB4tJ(Vi7RUHDGEwJH4g4shw4yfrMsT(IeyibAxDd7a9SgdXnWLo(SiSkxEjyasN)e4sh7KZrB5V7OavUmiD(tGlDStohT9(Zs9cxKSmVHpn6)ISp7RGcqwF3SwTWXkUcHHTHpohBa4BitYY8g(0O)lY(BwRV8g(0VQJcl6exkEzDjlZB4tJ(Vi7bq9lVHp9R6OWIoXLI4P3KLKLfOaK(Hw9VrAmKcHeszzlnPWCMM0bJ0Wwi9drxP5cNuhrAEdhUqwM3WNgTxNPlMOR0CH)wRjkSWXkImLA9fjWqc0g3B(djj4JflfYY8g(0O96m9)fzFIUsZf(Rh4PfowXibgsSz5HT3S7FitPwFrcmKaTt0vAUWF9ap)KTFitPwFrcmKaTX9M)qsc(KT)JSkDSrsc8241UHDGNazlDUwfozjzzbkaPWU1rKLfG0sJesT6WsaKcBBmiKpnPS8WM0coohBa4Bs)dtLtk2aiTGJZXgaoP3bxqKoyyKENPYhwnPEtAylK2YFpiLnRqksUtZrKoHTay5iHuiKq60KE5Kc1vbHinSfsTQutJbrAjG0dsH9bFndsTwH7rg(0K6isJSkDiCliDaK6yKg2cqiLLxRK2tq6QqA2tylasl44CszxaiZWNM0W2rKI5g2XM0pmcb3mingsrF7lPHTqAnrbPMdlbqQ3yqiFAshmsdBHum3WoingsHpoNubazg(0KInas7Pj1A0xGNnAtwM3WNgTVCurZHLaEEJbH8PTWXkAcCbfBKuXEMdlb88gdc5t)BPvimSn8X5ydaFdzwUmmqduD1B((o4Rz8WfUhz4tVLoxRc)3DMkFy1B4JZFcaYm8P3abp9g9zr2Ss5YyUHD8acE6n6J3zQ8HvVHpo)jaiZWNEde80B0I)wcZnSJhqWtVrFw8otLpS6n8X5pbazg(0BGGNEJ(NTf(7otLpS6n8X5pbazg(0BGGNEJ(yrJl)pYoLlJ5g2Xdi4P3OpVZu5dREBoSeWZBmiKp9MdbYWNUCzm3WoEabp9g9X7mv(WQ3WhN)eaKz4tVbcE6n6F2wy5Y3bU0zh7c)c8SxKSSaKwAKqkJxL(kKonPWU1jngsnbZLugX0gYAaydIuRcMBnXZWNEtwwasZB4tJ2xo6)ISh5vPVIfrcmK45yfbqTGnadzJetBiRbqptWCRjEg(0B5VGCttH)BPibgsSD0l58YLJeyiXMlRqyy7BIcVn2ajVXIKLfG0sJesHzYnes9g5CH0bJ0c(NKInasdBHumhGcsHqcPdG0Pjf2ToPjwiasdBHumhGcsHqYM0fWdBsx2nSds)Zui1EQCsXgaPf8p3KL5n8Pr7lh9Fr2dHKNhcUfDIlfrEJbvFg1K7zma0Bn5gYBWEycyUE81chR4keg2g(4CSbGVHmlxoCC5t2SYVLGXDGlD2XUDd74HLYIKLfG0sJes)ZuiTubkbCpBePttkSBDshOa5CH0bJ0coohBa4Bslnsi9ptH0sfOeW9S5is9M0coohBa4K6yK(DGi1oHlKkEylaslvadCHuyBd3ngqg(0Koas)txQCshmsHzDqObhTjlZB4tJ2xo6)IShlLNbuc4E2ilCSIWyfcdBdFCo2aW3qM)wcg3zQ8HvVHpo)fdaiDSHmlxggrwLo2WhN)IbaKo2sNRvHVy5YRqyyB4JZXga(gY83sObQU6nFBag4YZB4UXaYWNElDUwfE5YObQU6nFJ5sL)gS3ADqObhTLoxRcFrYYcqAPrcPwR3CJexqKYYwAsZAL0sHuRpLGinbcPqMwq6ai97arAces9M0coohBa4BszxncciK(hGAdb4TbPfCCoPoI08goCH0PjnSfsJeyibPogPrwLoe(MuMymjfc5TbPzq6c)N0ibgsGiLLh2KYijWBdsx2nSd8eiBYY8g(0O9LJ(Vi7X9MBK4cYI73BvErcmKavKnlCSIEJY2JVF8dYk)wAj4jWZ1QSZA9XNa9Gm)TemUZu5dREdFC(taqMHp9gYSCzyezv6yBd1gcWBJh8X5BPZ1QWxCXYLxHWW2WhNJna8nK5I)wcgrwLo22qTHa824bFC(w6CTk8YL5Ykeg22gQneG3gp4JZ3qMLldJvimSn8X5ydaFdzU4VLGrKvPJnssG3gV2nSd8eiBPZ1QWlxgzk16lsGHeOnU38hssWhx4IKLfG0sJeslDBp1VKU8apjDAsHDRBbP2tL7TbPRaxWQFjngszLEqk2ai1Cyjas9gdc5tt6ain5CsrMjRgTjlZB4tJ2xo6)IShQTN63xpWtlCSIlTemaPZFcCPJDY5OnK5pq68Nax6yNCoA79NWYklwUmiD(tGlDStohTbcE6n6ZISTWYLbPZFcCPJDY5OnhcKHp9hzBHl(BPvimST5WsapVXGq(0BiZYLVZu5dREBoSeWZBmiKp9gi4P3OplYMvkxggMaxqXgjvSN5WsapVXGq(0l(Bjyezv6yBd1gcWBJh8X5BPZ1QWlxMlRqyyBBO2qaEB8GpoFdzwUmmwHWW2WhNJna8nK5IKLfG0sJesNMuy36KUcfKAc8b4HJesHqEBqAbhNtk7cazg(0KI5auybPogPqiHtQ3iNlKoyKwW)K0PjLPesHqcPjwiastsHpoFDQbPydG07mv(WQjvWW8Rl99lPzZjfBaKAd1gcWBdsHpoNuiZWXfsDmsJSkDi8nzzEdFA0(Yr)xK9RZ0Vb7f2YlrxP5c3chRimwHWW2WhNJna8nK5pyCNPYhw9g(48NaGmdF6nK5pKPuRVibgsG24EZFijbFY2pyezv6yJKe4TXRDd7apbYw6CTk8YLxAfcdBdFCo2aW3qM)qMsT(IeyibAJ7n)HKe8ry9dgrwLo2ijbEB8A3WoWtGSLoxRc)3sMab(Z4Y3STHpo)To143sWq(li30u4Bb38lqY6Ba8o7RuUmmISkDSTHAdb4TXd(48T05Av4lwUS8xqUPPW3cU5xGK13a4D2x5xa8Uqj2cU5xGK13a4D2xzFNPYhw9gi4P3OpwKnRjS(XLvimSTnuBiaVnEWhNVHmxCXYLxAfcdBdFCo2aW3qM)ISkDSrsc8241UHDGNazlDUwf(IKL5n8Pr7lh9Fr2FZA9L3WN(vDuyrN4sXa4DHsGiljllqbif2tuq6cy7vHuyprH3gKM3WNgTjLrcsZGuB3WwaKAc8b4XxsJHuK9acsVo4c5bPEhcaazgKENM7HpnI0Pj1A9MtkJKa2)N18lzzbiT0iHugjbEBq6YUHDGNaHuhJ0VdePS8ALuBpiv6bYWM0ibgsGinBoPwDyjasHTngeYNM0S5KwWX5ydaN0eiK2tqkqs(xliDaKgdPabdiiBszwGf0QKonPbRH0bqk(aesJeyibAtwM3WNgTVSUfrsc8241UHDGNaXciK8yz7v5Dtu4Trr2S4(9wLxKadjqfzZchR4sWtGNRvzJKe4TXRDd7apbY7cfdg2pyapbEUwLT5m1h2aExoAXYLxIpXgzN8H1J1a4pZ07nqWacYoxRYpKPuRVibgsG24EZFijbFY2IKLfGug7beKc7o4c5bPmsc82G0LDd7apbcP3P5E4ttAmKwOiMKYSalOvjfYKuVj9dh2fzzEdFA0(Y6(Fr2JKe4TXRDd7apbIfqi5XY2RY7MOWBJISzX97TkVibgsGkYMfowXiRshBKKaVnETByh4jq2sNRvH)JpXgzN8H1J1a4pZ07nqWacYoxRYpKPuRVibgsG24EZFijbFclYYcq601VVlRlP4zHcI0WwinVHpnPtx)skekxRcPCiG3gKETZULQ3gKMnN0EcstePjPaXaQMasZB4tVjlZB4tJ2xw3)lYECV5V1AIclMU(9DzDlYgzjzzEdFA0MJB8cG3fkbQiesEEi4w0jUuKNGcXNPFC5w47zcfabDL(kKL5n8PrBoUXlaExOeO)lYEiK88qWTOtCPicQxRZWFjUe2FrbzzEdFA0MJB8cG3fkb6)IShcjppeCl6exkAu)AA)gSxIqoUxZWNMSmVHpnAZXnEbW7cLa9Fr2dHKNhcUfDIlf5aj5yoqEWfesQKLKLfOaKATP3K(Hw9VzbPi7bQYj9oWfaPzTskiBdbr6GrAKadjqKMnNu0v6e4dISmVHpnAJNE)Fr2FZA9L3WN(vDuyrN4sX1zAlqbWVrr2SWXkUcHHTxNPFd2lSLxIUsZf(gYKSmVHpnAJNE)Fr2ZDKPuF4PHFjllaPLgjKwWX5KYUaqMHpnPtt6DMkFy1KAot1BdsZG0QKOGu2XkK6nkBp(s6kuqApbPogPFhisz51kPdCbCtts9gLThFj1Bsl4FUj1AZcfsrqaHuKDYhwyU0C2J7nFvAUainBoPwR3CsHznrbPoI0Pj9otLpSAsxfSbiKwq21MuyRrpaHuZzQEBqkqqbWVHpnIuhJuiK3gKYyN8HfwnXfsTkWr4KMnNuyknxaK6ishOytwM3WNgTXtVlcFC(taqMHpTfowr4jWZ1QSnNP(WgW7Yr)wYBu2E89ZISJvkx2uInMlnFN3WHl)aqTGnadzJSt(WcRM4YZe4i8T8xqUPPW)bJ7mv(WQ34EZFR1efBiZFW4otLpS6nYo5dRhRbWFCjd7nK5I)wYBu2E89Jfz3lSC5iRshBKKaVnETByh4jq2sNRvH)dEc8CTkBKKaVnETByh4jqExOyWWw8hmUZu5dREJ5sZ3qM)wcg3zQ8HvVX9M)wRjk2qMLlJmLA9fjWqc0g3B(djj4tyTizzbi1AZcfsrqaH0VdePMqbPqMKYSalOvj9dz(qRs60Kg2cPrcmKGuhJ0faKHnguL0)mfGlK6Og2eKM3WHlKYYwAsXCd7WBdszRuTuinsGHeOnzzEdFA0gp9()IShzN8H1J1a4pZ0BlCSIRqyyBSuEgqjG7zJ2qM)GbxwHWW2SazyJbvFyPaCzdz(dzk16lsGHeOnU38hssWhzhYY8g(0OnE69)fz)nR1xEdF6x1rHfDIlfVCezzbi9p4g2KAvGpap(sQ16nNugjbKM3WNM0yifiyabztQ1NsqKYYdBsrsc8241UHDGNaHSmVHpnAJNE)Fr2J7n)HKeyX97TkVibgsGkYMfowXiRshBKKaVnETByh4jq2sNRvH)dzk16lsGHeOnU38hssWNWtGNRvzJ7n)HKe8UqXGH9dg8j2i7KpSESga)zMEVd)wO3g)GXDMkFy1BmxA(gYKSSaKAvGGjasJHuiKqQ1t8odFAs)qMp0QK6yKM9xsT(ucPoI0EcsHm3KL5n8PrB807)lYEEI3z4tBX97TkVibgsGkYMfowryapbEUwLDwRp(eOhKjzzbif22Oi7O(LuKP0CstsX9Mt6AnrbPx7eyiKMyHaif(481PgK6yKcH82GuKDYhwy1exi1e4iCsZMtkU381AIcePjqi9MMMcFtwM3WNgTXtV)Vi7X9M)wRjkSWXkENPYhw9g3B(BTMOyFTtGHG(KTFMsSXCP578goC5haQfSbyiBKDYhwy1exEMahHVL)cYnnf(pyCNPYhw9g(4836uJnKjzzbiT0iH0cooNuyo1G0mi12nSfaPMaFaE8LuwEyt6FaQneG3gKwWX5KczsAmKYoKgjWqcKfKoasNWwaKgzv6ar60KYuYMSmVHpnAJNE)Fr2dFC(BDQHfowrVrz7X3pwKDVWFrwLo22qTHa824bFC(w6CTk8FrwLo2ijbEB8A3WoWtGSLoxRc)hYuQ1xKadjqBCV5pKKGpw0AwU8slfzv6yBd1gcWBJh8X5BPZ1QW)bJiRshBKKaVnETByh4jq2sNRvHVy5YitPwFrcmKaTX9M)qsckY2IKLfGuRpnSjifcjKADb(ab82GuRwtdiHuhJ0VdeP3Sj1qcs9ogsl44CSbGtQ3OqsUfKoasDmszKe4TbPl7g2bEcesDePrwLoeoPzZjLLxRKA7bPspqg2KgjWqc0MSmVHpnAJNE)Fr2Zf4deWBJNznnGelCSIlbemGGSZ1QuUS3OS947NL6fU4VLGb8e45Av2MZuFyd4D5OYL9gLThF)Si7EHl(Bjyezv6yJKe4TXRDd7apbYw6CTk8YLxkYQ0XgjjWBJx7g2bEcKT05Av4)Gb8e45Av2ijbEB8A3WoWtG8UqXGHT4IKLfG0sJeslimjDAsHDRtQJr63bIu(0WMG0weoPXq6nrbPwxGpqaVni1Q10asSG0S5Kg2cqinbcPvbHinSZMu2H0ibgsGiDGcsxAHKYYdBsVtZH8yXnzzEdFA0gp9()ISh(4836udlCSIitPwFrcmKaTX9M)qsc(4sSZ)3P5qES5ocnD2XtU2JG2sNRvHV4pVrz7X3pwKDVWFrwLo2ijbEB8A3WoWtGSLoxRcVCzyezv6yJKe4TXRDd7apbYw6CTkCYYcqAPrcPm2jFyr6cma(csQ1LmSj1XinSfsJeyibPoI0CDGcsJHuUlKoas)oqKANWfszSt(WcRM4cPwf4iCsL)cYnnfoPS8WMuR1B(Q0Cbq6aiLXo5dlmxAoP5nC4YMSmVHpnAJNE)Fr2JSt(W6XAa8hxYW2I73BvErcmKavKnlCSIlfjWqITTK1WEBEJpclR8dzk16lsGHeOnU38hssWhzNflxEjtj2yU08DEdhU8da1c2amKnYo5dlSAIlptGJW3YFb5MMcFrYYcqAPrcPmqaG0CbqAmKATjVfeI0PjnjnsGHeKg2zqQJi1y82G0yiL7cPzqAylKcCd7G0WXLnzzEdFA0gp9()IShbbasZfWlMhEYBbHS4(9wLxKadjqfzZchRyKadj2HJlVyECx(iSw4VvimSn8X5ydaFZhwnzzbiT0iH0cooN0sgaq6G0PRFj1XiLzbwqRsA2CslyjKMaH08goCH0S5Kg2cPrcmKGuwtdBcs5Uqkhc4TbPHTq61o7wQBYY8g(0OnE69)fzp8X5VyaaPdlUFVv5fjWqcur2SWXkcpbEUwLnFc0dY8xKadj2HJlVyECx(Su(T0keg2g(4CSbGV5dRUC5vimSn8X5ydaFde80B0hVZu5dREdFC(BDQXgi4P3Of)L3WHlp(eB4jUPd87lgORDrKPuRVibgsG2WtCth43xmqx7FitPwFrcmKaTX9M)qsc(4sl8)LSM)XiRsh7GLJI3G9WYq2sNRvHV4IKL5n8PrB807)lYECV5RsZfGfowr(eB4jUPd87lgOR9o8BHEB8BPiRshBKKaVnETByh4jq2sNRvH)dzk16lsGHeOnU38hssWNWtGNRvzJ7n)HKe8UqXGHvUmFInYo5dRhRbWFMP37WVf6TXI)wcgaOwWgGHSr2jFyHvtC5zcCe(w(li30u4LlN3WHlp(eB4jUPd87lgORDrKPuRVibgsG2WtCth43xmqx7fjllaPLgjKYSalO1jLLh2KA107vGKfkasTkkR4Kc1vbHinSfsJeyibPS8AL0vH0vPoSifww5doPRc2aesdBH07mv(WQj9o4cI018wizzEdFA0gp9()IShzN8H1J1a4pUKHTfowraulydWq2MP3RajluaptuwX3YFb5MMc)h8e45Av28jqpiZFrcmKyhoU8I5zEJhSSYNlDNPYhw9gzN8H1J1a4pUKH9MdbYWN(FJlFrYYcqAPrcPm2jFyrkSdsKnPttkSBDsH6QGqKg2cqinbcPjNJi177G7TXMSmVHpnAJNE)Fr2JSt(W6DbjY2chRiiD(tGlDStohT9(t2SczzbiT0iHuR1BoPmscingsVtJGWfsTEckK0sShid7arQjyUisNM0p8dWU2KwYhW6FasH9PXCaoPoI0W2rK6istsTDdBbqQjWhGhFjnSZMuGWNi82G0Pj9d)aSlsH6QGqKYtqHKg2dKHDGi1rKMRduqAmKgoUq6afKL5n8PrB807)lYECV5pKKalUFVv5fjWqcur2SWXkImLA9fjWqc0g3B(djj4t4jWZ1QSX9M)qscExOyWW(TcHHT5jOWxypqg2XgY0IRD6Dr2SW7qaaiZ4544c3ZqkYMfEhcaazgphRy43crFwewKLfG0sJesTwV5K(N18lPXq6DAeeUqQ1tqHKwI9azyhisnbZfr60KYuYM0s(aw)dqkSpnMdWj1XinSDePoI0KuB3WwaKAc8b4Xxsd7Sjfi8jcVnifQRccrkpbfsAypqg2bIuhrAUoqbPXqA44cPduqwM3WNgTXtV)Vi7X9M)WQ5xlCSIRqyyBEck8f2dKHDSHm)bpbEUwLnFc0dY0IRD6Dr2SW7qaaiZ4544c3ZqkYMfEhcaazgphRy43crFwew)UZu5dREdFC(BDQXgYKSSaKwAKqQ16nNuywtuqQJr63bIu(0WMG0weoPXqkqWacYMuRpLG2KYeJjP3efEBqAgKYoKoasXhGqAKadjqKYYdBszKe4TbPl7g2bEcesJSkDiCsZMt63bI0eiK2tqkeYBdszSt(WcRM4cPwf4iCshaPwf99A7xs)BEx4gzk16lsGHeOnU38hssWNwdxiPgsGinSfsX92XHWjDWiDHKMnN0WwiTHWxfaPdgPrcmKaTjlZB4tJ24P3)xK94EZFR1efw4yfHNapxRYMpb6bz(dKo)jWLo24dCbx6y79N3efVWXL)TYEH)qMsT(IeyibAJ7n)HKe8XLyN)H1FmYQ0Xg3rc47w6CTk8)ZB4WLhFIn8e30b(9fd01(pgzv6yBI(ET97R6DHBPZ1QW)FjKPuRVibgsG24EZFijbFAnCHl(hxYuInMlnFN3WHl)aqTGnadzJSt(WcRM4YZe4i8T8xqUPPWxCrYY8g(0OnE69)fzp8e30b(9fd012I73BvErcmKavKnlCSIabdii7CTk)IeyiXoCC5fZJ7YNwZYLxkYQ0Xg3rc47w6CTk8F8j2i7KpSESga)zMEVbcgqq25AvwSC5vimSnuJbbQEB84jOWwqOnKjzzbiLXuUEwj9on3dFAsJHuumMKEtu4TbPmlWcAvsNM0bdRunsGHeiszzlnPyUHD4TbPLcPdGu8biKII8wOWjfFwrKMnNuiK3gKAv03RTFj9V5DHKMnN0L)aLqQ16ib8DtwM3WNgTXtV)Vi7r2jFy9yna(Zm92chRiqWacYoxRYVibgsSdhxEX84U8j78dgrwLo24osaF3sNRvH)lYQ0X2e99A73x17c3sNRvH)dzk16lsGHeOnU38hssWNWISSaKAnsetszwGf0QKczs60KMisXZ(lPrcmKarAIi1CqiFTkwqQ83VIzqklBPjfZnSdVniTuiDaKIpaHuuK3cfoP4ZkIuwEytQvrFV2(L0)M3fUjlZB4tJ24P3)xK9i7KpSESga)zMEBX97TkVibgsGkYMfowrGGbeKDUwLFrcmKyhoU8I5XD5t25hmISkDSXDKa(ULoxRc)hmwkYQ0XgjjWBJx7g2bEcKT05Av4)qMsT(IeyibAJ7n)HKe8j8e45Av24EZFijbVlumyyl(Bjyezv6yBI(ET97R6DHBPZ1QWlxEPiRshBt03RTFFvVlClDUwf(pKPuRVibgsG24EZFijbFSiSwCrYY8g(0OnE69)fzpU38hssGf3V3Q8IeyibQiBw4yfrMsT(IeyibAJ7n)HKe8j8e45Av24EZFijbVlumyywCTtVlYMfEhcaazgphhx4Egsr2SW7qaaiZ45yfd)wi6ZIWISmVHpnAJNE)Fr2J7n)HvZVwCTtVlYMfEhcaazgphhx4Egsr2SW7qaaiZ45yfd)wi6ZIW63DMkFy1B4JZFRtn2qMKLfG0sJeszwGf06KMisRjkifiObeK6yKonPHTqk(axilZB4tJ24P3)xK9i7KpSESga)XLmSjllaPLgjKYSalOvjnrKwtuqkqqdii1XiDAsdBHu8bUqA2CszwGf06K6isNMuy36KL5n8PrB807)lYEKDYhwpwdG)mtVjljllaPLgjKonPWU1j9dz(qRsAmKAibPwFkH0WVf6TbPzZjv(7MoqingsRElKczs6QeHaiLLh2KwWX5ydaNSmVHpnAhaVlucuriK88qWTOtCPOGB(fiz9naEN9vSWXkENPYhw9g(48NaGmdF6nqWtVrFSiBWQC57mv(WQ3WhN)eaKz4tVbcE6n6tyvQjllaPmF7lPWwRbToPS8WM0coohBa4KL5n8Pr7a4DHsG(Vi7HqYZdb3IoXLIEJUaOixRY7VGYoGWFCbUFflCSI3zQ8HvVHpo)jaiZWNEde80B0NSzfYYcqkZ3(skJTibPwleYVKYYdBsl44CSbGtwM3WNgTdG3fkb6)IShcjppeCl6exkIN3CfipKTiXdhc5xlCSI3zQ8HvVHpo)jaiZWNEde80B0NSzfYYcqkZ3(s6hmO1VKYYdBsT6WsaKcBBmiKpnPqO0qSGu8SqHueeqingsrTBkKg2cP1HLGcs)dwL0ibgsqwM3WNgTdG3fkb6)IShcjppeCl6exkIgOAvIWBJhaA9RfowXvimST5WsapVXGq(0BiZYLHHjWfuSrsf7zoSeWZBmiKpTf3V3Q8IeyibQiBKLfG0sJesHzYnes9g5CH0bJ0c(NKInasdBHumhGcsHqcPdG0Pjf2ToPjwiasdBHumhGcsHqYMug7beKEDWfYdsDmsHpoNubazg(0KENPYhwnPoIu2ScI0bqk(aestw53nzzEdFA0oaExOeO)lYEiK88qWTOtCPiYBmO6ZOMCpJbGERj3qEd2dtaZ1JVw4yfVZu5dREdFC(taqMHp9gi4P3OplYMvillaPLgjKwDuq6Gr60LQqiHuEINgcPbW7cLar601VK6yK(hGAdb4TbPfCCoPwxwHWWi1rKM3WHlwq6ai97arAces7jinYQ0HWj17yi1JnzzEdFA0oaExOeO)lY(BwRV8g(0VQJcl6exkYXnEbW7cLazHJvCjyezv6yBd1gcWBJh8X5BPZ1QWlxMlRqyyBBO2qaEB8GpoFdzU4VLwHWW2WhNJna8nKz5Y3zQ8HvVHpo)jaiZWNEde80B0NSzLfjllaPwxWsOAqkwwRR5TqsXgaPqOCTkK6HGJwqslnsiDAsVZu5dRMuVjDaCbq66xsdG3fkbPO6eBYY8g(0ODa8Uqjq)xK9qi55HGJSWXkUcHHTHpohBa4BiZYLxHWW2Mdlb88gdc5tVHmlx(otLpS6n8X5pbazg(0BGGNEJ(KnRCItCoa]] )

end
