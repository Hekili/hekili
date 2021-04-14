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


    spec:RegisterPack( "Shadow", 20210413, [[deLlfcqiOepsKOlbLkjBsvPpbLkgLIkNsrPvPQkXRuvvZIs4wkkq7sHFHIQHrjPJHISmOuEgLennuuCnrQSnuuQVPOGgNibDoffW6uvKMNQI6EIO9POQ)jsGCqvfXcHs6HqPQjsjLlsjbBuvv4JqPsnsvvrojkkzLuIEPib0mvvL0nvuODQQWpPKqdLsQoQibyPIeOEkQmvrkxvKQ2QII(QiH2Rk(RknyIdlzXkYJvLjtXLjTzq9zuA0uQtt1QHsL41IKMTOUnuTBP(TsdhvDCvvPwoWZHmDHRdY2HIVJcJxvvuNxvL1dLkPMViSFKpmDs7WzQqpFGnRInMSkZWKvoWg2ygMTvYSpCXpE9WXxVulw9W1fUE44SlZY4WXx)YBzoPD4qle4Pho7i4rFkZzoRh2qtJ3IZCKJdLRW3(bk4G5ih)X8d3eKNdMvFMoCMk0ZhyZQyJjRYmmzLdSHnMHzBLw5HRGc7fC44CCS)Wz7gJ2NPdNrrVdhNDzwgKyDGROGS8t4bEMeMSslibBwfBmrwswMgdTsLKzUUHK0waq7Geg2Atsuawni5TqDGiPakjWl4PMXHl7OaDs7Wzu4ckhN0oFW0jTdx9cF7dhYZA)0dN21uwnhSEIZhy7K2Ht7AkRMdwpCpGhkWRd3eem8aZ6g4fGpG4jjrcsMGGHh8ldfC9ggc5BpG4pC1l8TpC8B4BFIZhw5jTdN21uwnhSE4w(dhsJdx9cF7dhMc41uwpCyQmKE4mBmq2LzzCzSaZLV8Ee(lvVzj5ljMngykCEh4VBSqp7r4Vu9M9WHPa3UW1dNzd0fI)eNpyMtAhoTRPSAoy9WT8hoKghU6f(2homfWRPSE4Wuzi9Wz2yGSlZY4YybMlF59i8xQEZsYxsmBmWu48oWF3yHE2JWFP6nljFjXSXWOywiG3Sx(CXcPJWFP6n7HdtbUDHRhUkNVMnqxi(tC(iDN0oCAxtz1CW6HB5pCinoC1l8TpCykGxtz9WHPYq6HdXR58nkaRgObU3MlslajZtc2i5FsMGGHhyw3aVa8be)HZOOhW5dF7dhxuGGeiK3SKWPfWBws(WzTd8cOKubjw5)KefGvdejlGeM5FsCys(TqKuaLeVjzMRBGxa(HdtbUDHRhoKwaVzVTZAh4fqVpOyHHpX5dM9jTdN21uwnhSE4w(dhsJdx9cF7dhMc41uwpCyQmKE4E7MnlJEGzDZvbq8HV9aINKVKmhjyHeq5MRIr7yugdAaXtsIeKak3CvmAhJYyqddeOcFBs(CssyYQKKibjGYnxfJ2XOmg0aO4L3isMpjjmzvs(NK0rYFHK5ijQS2XWgQzvG3SxmRBgAxtz1qsIeK8wmAxDms9hWRMKzjzws(sYCKmhjGYnxfJ2XOmg0WBsMNeSzvssKGeeVMZ3OaSAGgyw3CvaeF4BtY8jjjDKmljjsqsuzTJHnuZQaVzVyw3m0UMYQHKeji5Ty0U6yK6pGxnjZE4mk6bC(W3(WH97MnlJMeRVBMKzwaVMYQfKKEKAijws43ntYKcVaLK6foMk8MLemRBGxa(GeShca0oY)ibcPgsILK32byZKWWwBsILK6foMkusWSUbEb4KWWdBs8(T4EZsszmOXHdtbUDHRho(DZx4fCFg0joFmdpPD40UMYQ5G1d3d4Hc86WnbbdpWSUbEb4di(dx9cF7dhSd0P8UMtC(ifEs7WPDnLvZbRhUhWdf41HBccgEGzDd8cWhq8hU6f(2hUjfGuqQEZEIZhZaN0oCAxtz1CW6HREHV9Hl7S2b6IDbYWIRDC4mk6bC(W3(WLEKsYF1zTdSdIelHmS4AhK4WKe2kqjPakjyJKfqc(cusIcWQbYcswajLXGiPaAJDcsq8fJ2BwsGxaj4lqjjSRMKzy6qJd3d4Hc86WH41C(gfGvd0i7S2b6IDbYWIRDqY8jjbBKKibjZrcwibuU5Qy0ogLXGg6F2rbIKejibuU5Qy0ogLXGgEtY8KmdthjZEIZhmz1tAhoTRPSAoy9W9aEOaVoCtqWWdmRBGxa(aI)WvVW3(Wv9trbOY3xLZN48btmDs7WPDnLvZbRhU6f(2hUxLZ36f(23SJIdx2rXTlC9W9y8oX5dMW2jTdN21uwnhSE4Qx4BF4aq9TEHV9n7O4WLDuC7cxpC4L3N4ehodo7naENQgOtANpy6K2Ht7AkRMdwpCDHRhotbsfF3(A0xQ3lpuau0t7NE4Qx4BF4mfiv8D7RrFPEV8qbqrpTF6joFGTtAhoTRPSAoy9W1fUE4qq9uExZTW1W(hkoC1l8TpCiOEkVR5w4Ay)dfN48HvEs7WPDnLvZbRhUUW1dhB(hV9DHVfc54EUcF7dx9cF7dhB(hV9DHVfc54EUcF7tC(GzoPD40UMYQ5G1dxx46HZa0Ya7a9IrrinF4Qx4BF4maTmWoqVyuesZN4eho8Y7tANpy6K2Ht7AkRMdwpCpGhkWRd3eem8yA3(UW3WwVf6PTrndi(dhka(loFW0HREHV9H7v58TEHV9n7O4WLDuC7cxpCt72N48b2oPD40UMYQ5G1d3d4Hc86WHfsIcWQXWrx(C9tbhU6f(2hoJJ418fVy93joFyLN0oCAxtz1CW6HREHV9HdZ6MRcG4dF7dNrrpGZh(2hU0JusM56gsScai(W3MKTj5TB2SmAs43n7nljvqswluqcZyvs8gvTh)izckiP3GehMKFlejm8CMKfJcEfpjEJQ2JFK4njZ8pgKmJvQkjiiGscYUmldyxBdZX92mPTrbKuTHKz0BdjynxOGehrY2K82nBwgnjtk8cusMPvyqcZITxGsc)UzVzjbOOa4VW3grIdtceYBws4SlZYaox4kjwh4iCsQ2qcw12OasCejlumoCpGhkWRdhMc41uwh87MVWl4(mis(sYCK4nQAp(rY8jjHzSkjjsqcVgdyxBZOEHJrj5ljaOwHxaRoq2LzzaNlC9YdCe(q)BiNNxnK8LeSqYB3Szz0dCVn3PCHIbepjFjblK82nBwg9azxMLXLXcmxJwH9aINKzj5ljZrI3OQ94hjFojjPW0rsIeKevw7yG0c4n7TDw7aVa6q7AkRgs(scMc41uwhiTaEZEBN1oWlGEFqXcdtYSK8LeSqYB3Szz0dyxBZaINKVKmhjyHK3UzZYOh4EBUt5cfdiEssKGeeVMZ3OaSAGg4EBUiTaKmpjyJKzpX5dM5K2Ht7AkRMdwpC1l8TpCi7YSmUmwG5YxEF4mk6bC(W3(WnJvQkjiiGsYVfIeEOGeiEs4sXp16K8jCFI1jzBscBLKOaSAqIdtskcQWggktYFukWvsCuJDcsQx4yusyyRnjWoRD4nljmndALKefGvd04W9aEOaVoCtqWWd4sVSqfW4vJgq8K8LeSqIrNGGHhmavyddLVWLcCDaXtYxsq8AoFJcWQbAG7T5I0cqYNjHzoX5J0Ds7WPDnLvZbRhU6f(2hUxLZ36f(23SJIdx2rXTlC9W9mOtC(GzFs7WPDnLvZbRhU6f(2hoCVnxKwGd373lR3OaSAGoFW0H7b8qbED4IkRDmqAb8M92oRDGxaDODnLvdjFjbXR58nkaRgObU3MlslajZtcMc41uwh4EBUiTa3huSWWK8LeSqIzJbYUmlJlJfyU8L3JWFP6nljFjblK82nBwg9a212mG4pCgf9aoF4BF4(toRnjwh4lWJFKmJEBiHtlaj1l8Tjjwsakmqr2KyTnnejm8WMeKwaVzVTZAh4fqpX5Jz4jTdN21uwnhSE4Qx4BF4mfExHV9H797L1BuawnqNpy6W9aEOaVoCyHemfWRPSoQC(A2aDH4pCgf9aoF4BF4SoqHvajXscesjXAfExHVnjFc3NyDsCysQ(hjwBtJehrsVbjq8JtC(ifEs7WPDnLvZbRhU6f(2hoCVn3PCHIdNrrpGZh(2hoMvJIQJ8psq8ABiPib3Bdjt5cfK8SlaRssbhkGemRBM2CqIdtceYBwsq2LzzaNlCLeEGJWjPAdj4EBMYfkqKuaLKxXZRMXH7b8qbED4E7MnlJEG7T5oLlumE2fGvrKmpjmrYxs41ya7ABg1lCmkjFjba1k8cy1bYUmld4CHRxEGJWh6Fd588QHKVKGfsE7MnlJEGzDZDAZXaI)eNpMboPD40UMYQ5G1dx9cF7dhM1n3PnhhoJIEaNp8TpCPhPKmZ1nKG1nhKubj2oRTciHh4lWJFKWWdBs(tqnRc8MLKzUUHeiEsILeMHKOaSAGSGKfqYg2kGKOYAhis2MeU0ghUhWdf41HZBu1E8JKpNKKuy6i5ljrL1og2qnRc8M9IzDZq7AkRgs(ssuzTJbslG3S32zTd8cOdTRPSAi5ljiEnNVrby1anW92CrAbi5ZjjHztsIeKmhjZrsuzTJHnuZQaVzVyw3m0UMYQHKVKGfsIkRDmqAb8M92oRDGxaDODnLvdjZssIeKG41C(gfGvd0a3BZfPfGKKKWejZEIZhmz1tAhoTRPSAoy9WvVW3(WzumleWB2lFUyH0dNrrpGZh(2hoRTn2jibcPKynfZcb8MLeRNlwiLehMKFlejVQjHvds8owsM56g4fGtI3OqlJfKSasCys40c4nljF4S2bEbusCejrL1oudjvBiHHNZKy7bjAVqS2KefGvd04W9aEOaVoCZrcqHbkYUMYkjjsqI3OQ94hjZtYmmDKmljFjzosWcjykGxtzDWVB(cVG7ZGijrcs8gvTh)iz(KKKcthjZsYxsMJeSqsuzTJbslG3S32zTd8cOdTRPSAijrcsMJKOYAhdKwaVzVTZAh4fqhAxtz1qYxsWcjykGxtzDG0c4n7TDw7aVa69bflmmjZsYSN48btmDs7WPDnLvZbRhU6f(2homRBUtBooCgf9aoF4BF4spsjzMyLKTjb7Tgjomj)wismBJDcsAvnKeljVcfKynfZcb8MLeRNlwi1csQ2qsyRaLKcOKKveIKWUAsygsIcWQbIKfkizU0rcdpSj5TTbYJzhhUhWdf41HdXR58nkaRgObU3MlslajFMK5iHzi5FsEBBG8yyCeA7QJR(Sxfn0UMYQHKzj5ljEJQ2JFK85KKKcthjFjjQS2XaPfWB2B7S2bEb0H21uwnKKibjyHKOYAhdKwaVzVTZAh4fqhAxtz1CIZhmHTtAhoTRPSAoy9WvVW3(WHSlZY4YybMRrRW(W9(9Y6nkaRgOZhmD4EapuGxhU5ijkaRgdBTYH9G)fK8zsWMvj5ljiEnNVrby1anW92CrAbi5ZKWmKmljjsqYCKWRXa212mQx4yus(scaQv4fWQdKDzwgW5cxV8ahHp0)gY55vdjZE4mk6bC(W3(WLEKscNDzwgKKIlW8PKynTcBsCyscBLKOaSAqIJiPMwOGKyjX4kjlGKFlej2fgLeo7YSmGZfUsI1bocNe9VHCEE1qcdpSjzg92mPTrbKSas4SlZYa212qs9chJooX5dMSYtAhoTRPSAoy9WvVW3(WHGaaTnk4g7fVmTIqhU3VxwVrby1aD(GPd3d4Hc86WffGvJr446n2RXvs(mjylDK8LKjiy4bM1nWlaFywg9HZOOhW5dF7dx6rkjCqaG2gfqsSKmJLPveIKTjPijkaRgKe2vqIJiHD9MLKyjX4kjvqsyRKaCw7GKWX1XjoFWeZCs7WPDnLvZbRhU6f(2homRBUXcaAhhU3VxwVrby1aD(GPd3d4Hc86WHPaEnL1Hzd0fINKVKefGvJr446n2RXvsMNeRKKVKmhjtqWWdmRBGxa(WSmAssKGKjiy4bM1nWlaFau8YBejFMK3UzZYOhyw3CN2CmakE5nIKzj5lj1lCm61SXatHZ7a)DJf6ztsssq8AoFJcWQbAGPW5DG)UXc9Sj5ljiEnNVrby1anW92CrAbi5ZKmhjPJK)jzosy2K8xijQS2Xiy4O4UWx4k0H21uwnKmljZE4mk6bC(W3(WLEKsYmx3qsAlaODqY25FK4WKWLIFQ1jPAdjZmnskGss9chJss1gscBLKOaSAqcJTXobjgxjXab8MLKWwj5zxDR5XjoFWu6oPD40UMYQ5G1d3d4Hc86Wz2yGPW5DG)UXc9ShH)s1Bws(sYCKevw7yG0c4n7TDw7aVa6q7AkRgs(scIxZ5BuawnqdCVnxKwasMNemfWRPSoW92CrAbUpOyHHjjrcsmBmq2LzzCzSaZLV8Ee(lvVzjzws(sYCKGfsaqTcVawDGSlZYaox46Lh4i8H(3qopVAijrcsQx4y0RzJbMcN3b(7gl0ZMKKKG41C(gfGvd0atHZ7a)DJf6ztYShU6f(2hoCVntABuWjoFWeZ(K2Ht7AkRMdwpC1l8TpCi7YSmUmwG5A0kSpCgf9aoF4BF4spsjHlf)uRrcdpSjX6L3taTsvbKyDuLXjbQZkcrsyRKefGvdsy45mjtkjtAEzqc2Sk2vKmPWlqjjSvsE7MnlJMK3IRisMQxQhUhWdf41Hda1k8cy1bF59eqRuvWLhvz8H(3qopVAi5ljykGxtzDy2aDH4j5ljrby1yeoUEJ9Y)Il2SkjZtYCK82nBwg9azxMLXLXcmxJwH9WabQW3MK)jH9ziz2tC(GPz4jTdN21uwnhSE4Qx4BF4q2LzzCFGczF4mk6bC(W3(WLEKscNDzwgKG9GcztY2KG9wJeOoRiejHTcuskGsszmis8(T4EZooCpGhkWRdhOCZvXODmkJbn8MK5jHjREIZhmLcpPD40UMYQ5G1d3d4Hc86WH41C(gfGvd0a3BZfPfGK5jbtb8AkRdCVnxKwG7dkwyys(sYeem8WuGuVH9cXAhdi(dNrrpGZh(2hU0JusMrVnKWPfGKyj5TnccxjXAfivssZEHyTdej8G9HizBs(eROvyqsAwrRzfjb73g2b4K4iscBhrIJiPiX2zTvaj8aFbE8JKWUAsaQzJWBws2MKpXkAfibQZkcrIPaPssyVqS2bIehrsnTqbjXss44kjluC4E)Ez9gfGvd05dMoCEhkaaXhxh(Wf(lv08jX2HZ7qbai(4644QXRqpCmD4E2L3hoMoC1l8TpC4EBUiTaN48btZaN0oCAxtz1CW6HZOOhW5dF7dx6rkjZO3gs(JC9JKyj5TnccxjXAfivssZEHyTdej8G9HizBs4sBqsAwrRzfjb73g2b4K4WKe2oIehrsrITZARas4b(c84hjHD1KauZgH3SKa1zfHiXuGujjSxiw7arIJiPMwOGKyjjCCLKfkoCpGhkWRd3eem8WuGuVH9cXAhdiEs(scMc41uwhMnqxi(dN3Hcaq8X1HpCH)sfnFsS99TB2Sm6bM1n3Pnhdi(dN3Hcaq8X1XXvJxHE4y6W9SlVpCmD4Qx4BF4W92CHZ1VtC(aBw9K2Ht7AkRMdwpC1l8TpC4EBUt5cfhoJIEaNp8TpCPhPKmJEBibR5cfK4WK8BHiXSn2jiPv1qsSKauyGISjXABAObjCXYtYRqH3SKubjmdjlGe8fOKefGvdejm8WMeoTaEZsYhoRDGxaLKOYAhQHKQnK8BHiPakj9gKaH8MLeo7YSmGZfUsI1bocNKfqI1r)E2(JK)Q3Poq8AoFJcWQbAG7T5I0cmFkO0rcRgiscBLeCVDCiCswysshjvBijSvsAi8jfqYctsuawnqJd3d4Hc86WHPaEnL1Hzd0fINKVKak3CvmAhd8fJIRDm8MK5j5vO4goUsY)Ky1r6i5ljiEnNVrby1anW92CrAbi5ZKmhjmdj)tc2i5VqsuzTJbUJuWVH21uwnK8pj1lCm61SXatHZ7a)DJf6ztYFHKOYAhdE0VNT)UzVtDODnLvdj)tYCKG41C(gfGvd0a3BZfPfGK5tbrs6izws(lKmhj8AmGDTnJ6fogLKVKaGAfEbS6azxMLbCUW1lpWr4d9VHCEE1qYSKm7joFGnMoPD40UMYQ5G1dx9cF7dhMcN3b(7gl0Z(W9aEOaVoCafgOi7AkRK8LKOaSAmchxVXEnUsY8KWSjjrcsMJKOYAhdChPGFdTRPSAi5ljMngi7YSmUmwG5YxEpakmqr21uwjzwssKGKjiy4buddbYEZEnfi1wrObe)H797L1BuawnqNpy6eNpWg2oPD40UMYQ5G1dx9cF7dhYUmlJlJfyU8L3hoJIEaNp8TpCC86ZRmjVTnE4BtsSKGILNKxHcVzjHlf)uRtY2KSWWZGrby1arcdBTjb2zTdVzjXkjzbKGVaLeuuVuvdj47eIKQnKaH8MLeRJ(9S9hj)vVtLKQnK8HvmnsMrhPGFJd3d4Hc86WbuyGISRPSsYxsIcWQXiCC9g714kjZtcZqYxsWcjrL1og4osb)gAxtz1qYxsIkRDm4r)E2(7M9o1H21uwnK8LeeVMZ3OaSAGg4EBUiTaKmpjy7eNpWMvEs7WPDnLvZbRhU6f(2hoKDzwgxglWC5lVpCVFVSEJcWQb68bthUhWdf41HdOWafzxtzLKVKefGvJr446n2RXvsMNeMHKVKGfsIkRDmWDKc(n0UMYQHKVKGfsMJKOYAhdKwaVzVTZAh4fqhAxtz1qYxsq8AoFJcWQbAG7T5I0cqY8KGPaEnL1bU3MlslW9bflmmjZsYxsMJeSqsuzTJbp63Z2F3S3Po0UMYQHKejizosIkRDm4r)E2(7M9o1H21uwnK8LeeVMZ3OaSAGg4EBUiTaK85KKGnsMLKzpCgf9aoF4BF4sbQkpjCP4NADsG4jzBskej4v)JKOaSAGiPqKWViKpLvlir)ZpLpiHHT2Ka7S2H3SKyLKSasWxGsckQxQQHe8DcrcdpSjX6OFpB)rYF17uhN48b2yMtAhoTRPSAoy9WvVW3(WH7T5I0cC4E)Ez9gfGvd05dMoCEhkaaXhxh(Wf(lv08jX2HZ7qbai(4644QXRqpCmD4EapuGxhoeVMZ3OaSAGg4EBUiTaKmpjykGxtzDG7T5I0cCFqXcdF4E2L3hoMoX5dSLUtAhoTRPSAoy9WvVW3(WH7T5cNRFhoVdfaG4JRdF4c)LkA(Ky77B3Szz0dmRBUtBogq8hoVdfaG4JRJJRgVc9WX0H7zxEF4y6eNpWgZ(K2Ht7AkRMdwpCgf9aoF4BF4spsjHlf)uRrsHijxOGeGIwqqIdtY2Ke2kj4lg9WvVW3(WHSlZY4YybMRrRW(eNpW2m8K2Ht7AkRMdwpCgf9aoF4BF4spsjHlf)uRtsHijxOGeGIwqqIdtY2Ke2kj4lgLKQnKWLIFQ1iXrKSnjyV1oC1l8TpCi7YSmUmwG5YxEFItC44b6BXNQ4K25dMoPD40UMYQ5G1d3d4Hc86Wbu8YBejFMeR0Qw9WvVW3(WXVmuWLXcmx4feEaz0tC(aBN0oCAxtz1CW6H7b8qbED4WcjtqWWdKDzwgWlaFaXF4Qx4BF4q2LzzaVa8tC(WkpPD40UMYQ5G1d3d4Hc86W5nQAp(nmkS)8GK5jHP0D4Qx4BF4kWRA9glaODCIZhmZjTdN21uwnhSE4w(dhsJdx9cF7dhMc41uwpCyQmKE4W2HdtbUDHRhoCVnxKwG7dkwy4tC(iDN0oC1l8TpCykCEh4VBSqp7dN21uwnhSEItC4Eg0jTZhmDs7WPDnLvZbRhU6f(2ho(LHcUEddH8TpCgf9aoF4BF4spsjX6ldfqcZQHHq(2KWWdBsM56g4fGpi5pTzdjWlGKzUUbEb4K8wCfrYcdtYB3Szz0K4njHTssR)5GeMSkji9TTbrYg2kGHJusGqkjBtYZqcuNveIKWwjX6AUyxejPbkpib7x8PkizgvJhv4BtIJijQS2HASGKfqIdtsyRaLegEotsVbjtkjvVHTcizMRBiXkaG4dFBscBhrcSZAhds(KiuC(GKyjb9RFKe2kj5cfKWVmuajEddH8TjzHjjSvsGDw7GKyjbZ6gsuaeF4Btc8ciP3MKuG)aE1OXH7b8qbED44bUIIbsZWx(LHcUEddH8Tj5ljZrYeem8aZ6g4fGpG4jjrcsWcjOfkp5Tz8w8PkU4QXJk8ThAxtz1qYxsE7MnlJEGzDZvbq8HV9aO4L3isMpjjmzvssKGeyN1oUafV8grYNj5TB2Sm6bM1nxfaXh(2dGIxEJizws(sYCKa7S2XfO4L3isMpjjVDZMLrpWSU5Qai(W3Eau8YBej)tctPJKVK82nBwg9aZ6MRcG4dF7bqXlVrK85KKW(mK8xiHzijrcsGDw74cu8YBejZtYB3Szz0d(LHcUEddH8Thgiqf(2KKibjWoRDCbkE5nIKptYB3Szz0dmRBUkaIp8ThafV8grY)KWu6ijrcsElgTRogP(d4vtsIeKmbbdpMY7AYqOyaXtYSN48b2oPD40UMYQ5G1dNrrpGZh(2hU0JusWAzyvs8g5gLKfMKz(hKaVascBLeyhGcsGqkjlGKTjb7TgjfCOascBLeyhGcsGq6GKu0dBs(WzTds(JsjXEZgsGxajZ8pghUUW1dhYByO8LnxgVIfGUtLHvVl8fwb7ZJFhUhWdf41HBccgEGzDd8cWhq8KKibjHJRKmpjmzvs(sYCKGfsElgTRogTZAhx4sjz2dx9cF7dhYByO8LnxgVIfGUtLHvVl8fwb7ZJFN48HvEs7WPDnLvZbRhU6f(2ho4sVSqfW4vJoCgf9aoF4BF4spsj5pkLeSBOcy8QrKSnjyV1izHcKBuswysM56g4fGpij9iLK)OusWUHkGXR2GiXBsM56g4fGtIdtYVfIe7cJsI6HTcib7gSyusywngNDbv4BtYci5pCnBizHjbR5fHwC0GKuS8Ge4fqIzdejXsYKscepjtk8cusQx4yQWBws(Jsjb7gQagVAejXscE9NDChPKe2kjtqWWJd3d4Hc86WHfsMGGHhyw3aVa8bepjFjzosWcjVDZMLrpWSU5glaODmG4jjrcsWcjrL1ogyw3CJfa0ogAxtz1qYSK8LK5ibtb8AkRdZgOlepjFjbXR58nkaRgObMcN3b(7gl0ZMKKKWejjsqs9chJEnBmWu48oWF3yHE2KKKeeVMZ3OaSAGgykCEh4VBSqpBs(scIxZ5BuawnqdmfoVd83nwONnjZtctKmljjsqYeem8aZ6g4fGpG4j5ljZrcAHYtEBgSGfJE9gJZUGk8ThAxtz1qsIeKGwO8K3MbSRzZDHVt5fHwC0q7AkRgsM9eNpyMtAhoTRPSAoy9WvVW3(WH7THTWv0H797L1BuawnqNpy6W9aEOaVoCEJQ2JFK8zsMbSkjFjzosMJemfWRPSoQC(A2aDH4j5ljZrcwi5TB2Sm6bM1nxfaXh(2diEssKGeSqsuzTJHnuZQaVzVyw3m0UMYQHKzjzwssKGKjiy4bM1nWlaFaXtYSK8LK5iblKevw7yyd1SkWB2lM1ndTRPSAijrcsm6eem8WgQzvG3SxmRBgq8KKibjyHKjiy4bM1nWlaFaXtYSK8LK5iblKevw7yG0c4n7TDw7aVa6q7AkRgssKGeeVMZ3OaSAGg4EBUiTaK8zsshjZE4mk6bC(W3(WLEKsYm6THTWvejmS1MKkNjXkjXABAiskGsceVfKSas(TqKuaLeVjzMRBGxa(GeRqJGakj)jOMvbEZsYmx3qIJiPEHJrjzBscBLKOaSAqIdtsuzTd1miHlwEsGqEZssfKKU)jjkaRgisy4HnjCAb8MLKpCw7aVa64eNps3jTdN21uwnhSE4Qx4BF4GA7n)72lM6Wzu0d48HV9Hl9iLK032B(hjFSyks2MeS3AwqI9MnEZsYeWv48psILegLhKaVas4xgkGeVHHq(2KSaskJHeeFXOrJd3d4Hc86WnhjZrcwibuU5Qy0ogLXGgq8K8Leq5MRIr7yugdA4njZtc2SkjZssIeKak3CvmAhJYyqdGIxEJiz(KKWu6ijrcsaLBUkgTJrzmOHbcuHVnjFMeMshjZsYxsMJKjiy4b)YqbxVHHq(2diEssKGK3UzZYOh8ldfC9ggc5BpakE5nIK5tsctwLKejiblKWdCffdKMHV8ldfC9ggc5BtYSK8LK5iblKevw7yyd1SkWB2lM1ndTRPSAijrcsm6eem8WgQzvG3SxmRBgq8KKibjyHKjiy4bM1nWlaFaXtYSN48bZ(K2Ht7AkRMdwpC1l8TpCt723f(g26TqpTnQ5Wzu0d48HV9Hl9iLKTjb7Tgjtqbj8aFbE4iLeiK3SKmZ1nKyfaq8HVnjWoafwqIdtcesnK4nYnkjlmjZ8pizBs4sJeiKssbhkGKIemRBM2Cqc8ci5TB2SmAsuyy)5A)(rs1gsGxaj2qnRc8MLemRBibIpCCLehMKOYAhQzC4EapuGxhoSqYeem8aZ6g4fGpG4j5ljyHK3UzZYOhyw3CvaeF4BpG4j5ljiEnNVrby1anW92CrAbizEsyIKVKGfsIkRDmqAb8M92oRDGxaDODnLvdjjsqYCKmbbdpWSUbEb4diEs(scIxZ5BuawnqdCVnxKwas(mjyJKVKGfsIkRDmqAb8M92oRDGxaDODnLvdjFjzos4bkMl7ZmyAGzDZDAZbjFjzosWcj6Fd588QzO48)aALVlW0v)ussKGeSqsuzTJHnuZQaVzVyw3m0UMYQHKzjjrcs0)gY55vZqX5)b0kFxGPR(PK8LK3UzZYOhko)pGw57cmD1pDau8YBejFojjmXSXgjFjXOtqWWdBOMvbEZEXSUzaXtYSKmljjsqYCKmbbdpWSUbEb4diEs(ssuzTJbslG3S32zTd8cOdTRPSAiz2tC(ygEs7WPDnLvZbRhU6f(2hUxLZ36f(23SJIdx2rXTlC9WfaVtvd0joXHlaENQgOtANpy6K2Ht7AkRMdwpCgf9aoF4BF4spsjzBsWERrYNW9jwNKyjHvdsS2MgjH)s1BwsQ2qI(N5DGssSKK9wjbINKjncfqcdpSjzMRBGxa(HRlC9WP48)aALVlW0v)0d3d4Hc86W92nBwg9aZ6MRcG4dF7bqXlVrK85KKWe2ijrcsE7MnlJEGzDZvbq8HV9aO4L3isMNeSndpC1l8TpCko)pGw57cmD1p9eNpW2jTdN21uwnhSE4mk6bC(W3(WLg4hjXsc3V(rcZkfG1iHHh2KyTfAkRKWf1lv1qc2Bnejomj8lc5tzDqIvSjjVnRcib2zTdejm8WMe8fOKWSsbynsGqkIKkcfNpijwsq)6hjm8WMKQ)rYZqYcib7cekibcPK4X4W1fUE48g9aqrnL17FdvDaHFnkg)PhUhWdf41HBccgEGzDd8cWhq8K8LKjiy4b)YqbxVHHq(2diEssKGKPfHi5ljWoRDCbkE5nIKpNKeSzvssKGKjiy4b)YqbxVHHq(2diEs(sYB3Szz0dmRBUkaIp8ThafV8grY)KWu6izEsGDw74cu8YBejjsqYeem8aZ6g4fGpG4j5ljVDZMLrp4xgk46nmeY3Eau8YBej)tctPJK5jb2zTJlqXlVrKKibjZrYB3Szz0d(LHcUEddH8ThafV8grY8jjHjRsYxsE7MnlJEGzDZvbq8HV9aO4L3isMpjjmzvsMLKVKa7S2XfO4L3isMpjjmndy1dx9cF7dN3OhakQPSE)BOQdi8RrX4p9eNpSYtAhoTRPSAoy9Wzu0d48HV9HJ7x)iHZw1GKzec5psy4HnjZCDd8cWpCDHRho86vta9ISvnU4qi)D4EapuGxhU3UzZYOhyw3CvaeF4BpakE5nIK5jHjRE4Qx4BF4WRxnb0lYw14IdH83joFWmN0oCAxtz1CW6HRlC9WHwOCwJWB2laA63H797L1BuawnqNpy6W9aEOaVoCtqWWd(LHcUEddH8Thq8KKibjyHeEGROyG0m8LFzOGR3WqiF7dx9cF7dhAHYzncVzVaOPFhoJIEaNp8TpCC)6hjPGHM(rcdpSjX6ldfqcZQHHq(2KaHkw1csWRuvsqqaLKyjb1oVssyRKKxgkki5pzDsIcWQXjoFKUtAhoTRPSAoy9Wzu0d48HV9Hl9iLeSwgwLeVrUrjzHjzM)bjWlGKWwjb2bOGeiKsYcizBsWERrsbhkGKWwjb2bOGeiKoiHZEbbjph8G8GehMemRBirbq8HVnjVDZMLrtIJiHjRIizbKGVaLKIr9BC46cxpCiVHHYx2Cz8kwa6ovgw9UWxyfSpp(D4EapuGxhU3UzZYOhyw3CvaeF4BpakE5nIK5tsctw9WvVW3(WH8ggkFzZLXRybO7uzy17cFHvW(843joFWSpPD40UMYQ5G1dNrrpGZh(2hU0JusYokizHjz7zqiKsIPWlwLKa4DQAGiz78psCys(tqnRc8MLKzUUHeRPtqWWK4isQx4yulizbK8BHiPakj9gKevw7qnK4DSK4X4WvVW3(W9QC(wVW3(MDuC4EapuGxhU5iblKevw7yyd1SkWB2lM1ndTRPSAijrcsm6eem8WgQzvG3SxmRBgq8KmljFjzosMGGHhyw3aVa8bepjjsqYB3Szz0dmRBUkaIp8ThafV8grY8KWKvjz2dx2rXTlC9WzWzVbW7u1aDIZhZWtAhoTRPSAoy9WvVW3(WbH0Rhko6Wzu0d48HV9HZAkCbLdsGRCEQEPsc8cibcvtzLepuC0Nss6rkjBtYB3Szz0K4njlWOasM(rsa8ovnibL3yC4EapuGxhUjiy4bM1nWlaFaXtsIeKmbbdp4xgk46nmeY3EaXtsIeK82nBwg9aZ6MRcG4dF7bqXlVrKmpjmz1tCId30U9jTZhmDs7WPDnLvZbRhUhWdf41HdXR58nkaRgObU3MlslajFojjw5HREHV9HRqpTnQ5oLluCIZhy7K2Ht7AkRMdwpCpGhkWRdxuawngm8W27uijFjbXR58nkaRgOrHEABuZTxmfjZtctK8LeeVMZ3OaSAGg4EBUiTaKmpjmrY)Kevw7yG0c4n7TDw7aVa6q7AkRMdx9cF7dxHEABuZTxm1joXH7X4Ds78btN0oCAxtz1CW6HdcPxg2EwVVcfEZE(GPdx9cF7dhslG3S32zTd8cOhU3VxwVrby1aD(GPd3d4Hc86WnhjykGxtzDG0c4n7TDw7aVa69bflmmjFjblKGPaEnL1b)U5l8cUpdIKzjjrcsMJeZgdKDzwgxglWC5lVhafgOi7AkRK8LeeVMZ3OaSAGg4EBUiTaKmpjmrYShoJIEaNp8TpCPhPKWPfWBws(WzTd8cOK4WK8BHiHHNZKy7bjAVqS2KefGvdejvBiX6ldfqcZQHHq(2KuTHKzUUbEb4KuaLKEdsaAz(zbjlGKyjbOWafztcxk(PwNKTjjySKSasWxGssuawnqJtC(aBN0oCAxtz1CW6HdcPxg2EwVVcfEZE(GPdx9cF7dhslG3S32zTd8cOhU3VxwVrby1aD(GPd3d4Hc86Wfvw7yG0c4n7TDw7aVa6q7AkRgs(sIzJbYUmlJlJfyU8L3dGcduKDnLvs(scIxZ5BuawnqdCVnxKwasMNeSD4mk6bC(W3(WXzVGGeS3bpipiHtlG3SK8HZAh4fqj5TTXdFBsILKuvLNeUu8tTojq8K4njFYAfoX5dR8K2Ht7AkRMdwpCBN)DFmEhoMoC1l8TpC4EBUt5cfhoJIEaNp8TpCBN)DFmEKGxPQiscBLK6f(2KSD(hjqOAkRKyGaEZsYZU6wZEZss1gs6niPqKuKauwOCbiPEHV94eN4ehomka5BF(aBwfBmzvMXQw5HJrbAVzrhUu8tsb)bZ6dS7pLessZwjXX5xqqc8cib78miSdja9VHCGAibT4kjfuS4vOgsE2vZQObz5F1BLeM9Nsc2VngfeQHeSta8ovng10B82nBwgn2HKyjb782nBwg9OMEyhsMJP)8SdYsYsMfo)cc1qskKK6f(2KKDuGgKLhoeV(oFGT0LcpC8Gf2Z6HlLPKeo7YSmiX6axrbzzktjjFcpWZKWKvAbjyZQyJjYsYYuMsssJHwPsYmx3qsAlaODqcdBTjjkaRgK8wOoqKuaLe4f8uZGSKSmLPKeRWFwFqHAizsHxGsYBXNQGKjL1B0GKp59u(arsV9mODbWHHYKuVW3grY25FdYY6f(2ObpqFl(uf)NK58ldfCzSaZfEbHhqg1chojqXlVrF2kTQvjlRx4BJg8a9T4tv8FsMJSlZYaEb4w4WjXYeem8azxMLb8cWhq8KL1l8TrdEG(w8Pk(pjZlWRA9glaODyHdN0Bu1E8Byuy)5X8mLoYY6f(2ObpqFl(uf)NK5ykGxtz1IUW1K4EBUiTa3huSWWwS8jrAybMkdPjXgzz9cFB0GhOVfFQI)tYCmfoVd83nwONnzjzzktjjwFdFBezz9cFBusKN1(PKL1l8Trj53W32cho5eem8aZ6g4fGpG4tKyccgEWVmuW1ByiKV9aINSSEHVn6)Kmhtb8AkRw0fUM0Sb6cXBXYNePHfyQmKM0SXazxMLXLXcmx(Y7r4Vu9M9RzJbMcN3b(7gl0ZEe(lvVzjlRx4BJ(pjZXuaVMYQfDHRjRC(A2aDH4Ty5tI0WcmvgstA2yGSlZY4YybMlF59i8xQEZ(1SXatHZ7a)DJf6zpc)LQ3SFnBmmkMfc4n7LpxSq6i8xQEZswMss4IceKaH8MLeoTaEZsYhoRDGxaLKkiXk)NKOaSAGizbKWm)tIdtYVfIKcOK4njZCDd8cWjlRx4BJ(pjZXuaVMYQfDHRjrAb8M92oRDGxa9(GIfg2ILpjsdlWuzinjIxZ5BuawnqdCVnxKwG5X2)tqWWdmRBGxa(aINSmLKG97MnlJMeRVBMKzwaVMYQfKKEKAijws43ntYKcVaLK6foMk8MLemRBGxa(GeShca0oY)ibcPgsILK32byZKWWwBsILK6foMkusWSUbEb4KWWdBs8(T4EZsszmObzz9cFB0)jzoMc41uwTOlCnj)U5l8cUpdYILpjsdlWuzin5B3Szz0dmRBUkaIp8Thq8FNdlGYnxfJ2XOmg0aIprcq5MRIr7yugdAyGav4B)5Kmz1ejaLBUkgTJrzmObqXlVrZNKjR(F6(lZfvw7yyd1SkWB2lM1ndTRPSAsK4Ty0U6yK6pGx9SZ(DU5aLBUkgTJrzmOH3ZJnRMibIxZ5BuawnqdmRBUkaIp8TNpz6MnrIOYAhdBOMvbEZEXSUzODnLvtIeVfJ2vhJu)b8QNLSSEHVn6)Kmh2b6uExJfoCYjiy4bM1nWlaFaXtwwVW3g9FsMpPaKcs1BwlC4KtqWWdmRBGxa(aINSmLKKEKsYF1zTdSdIelHmS4AhK4WKe2kqjPakjyJKfqc(cusIcWQbYcswajLXGiPaAJDcsq8fJ2BwsGxaj4lqjjSRMKzy6qdYY6f(2O)tY8SZAhOl2fidlU2HfoCseVMZ3OaSAGgzN1oqxSlqgwCTJ5tITejMdlGYnxfJ2XOmg0q)Zokqjsak3CvmAhJYyqdVNFgMUzjlRx4BJ(pjZR(POau57RYzlC4KtqWWdmRBGxa(aINSSEHVn6)Km)v58TEHV9n7OWIUW1KpgpYY6f(2O)tYCauFRx4BFZokSOlCnjE5nzjzzktjjFI1)RKeljqiLeg2Atcw3TjzHjjSvs(e0tBJAiXrKuVWXOKL1l8TrJPD7Kf6PTrn3PCHclC4KiEnNVrby1anW92CrAb(CsRKSSEHVnAmTB)FsMxON2g1C7ftzHdNmkaRgdgEy7Dk8lIxZ5BuawnqJc902OMBVyQ5z6lIxZ5BuawnqdCVnxKwG5z6)OYAhdKwaVzVTZAh4fqhAxtz1qwswMYusc2Bnezzkjj9iLeRVmuajmRggc5BtcdpSjzMRBGxa(GK)0MnKaVasM56g4fGtYBXvejlmmjVDZMLrtI3Ke2kjT(NdsyYQKG032gejByRagosjbcPKSnjpdjqDwriscBLeRR5IDrKKgO8GeSFXNQGKzunEuHVnjoIKOYAhQXcswajomjHTcusy45mj9gKmPKu9g2kGKzUUHeRaaIp8TjjSDejWoRDmi5tIqX5dsILe0V(rsyRKKluqc)YqbK4nmeY3MKfMKWwjb2zTdsILemRBirbq8HVnjWlGKEBssb(d4vJgKL1l8TrJNbLKFzOGR3WqiFBlC4K8axrXaPz4l)YqbxVHHq(2FNBccgEGzDd8cWhq8jsGf0cLN82mEl(ufxC14rf(2dTRPSA((2nBwg9aZ6MRcG4dF7bqXlVrZNKjRMibSZAhxGIxEJ(8B3Szz0dmRBUkaIp8ThafV8gn735GDw74cu8YB08jF7MnlJEGzDZvbq8HV9aO4L3O)zkDFF7MnlJEGzDZvbq8HV9aO4L3OpNK9z(lmtIeWoRDCbkE5nA(3UzZYOh8ldfC9ggc5BpmqGk8TtKa2zTJlqXlVrF(TB2Sm6bM1nxfaXh(2dGIxEJ(NP0LiXBXOD1Xi1FaV6ejMGGHht5DnziumG4NLSmLKKEKscNN1(PKSnjyV1ijws4b7JeoL3gc7ASdIeRd2xUWRW3EqwMssQx4BJgpd6)Kmh5zTFQfrby146WjbqTcVawDGuEBiSRrxEW(YfEf(2d9VHCEE18DUOaSAmC0TmMejIcWQXWOtqWWJxHcVzhaTEXSKLPKK0JusWAzyvs8g5gLKfMKz(hKaVascBLeyhGcsGqkjlGKTjb7TgjfCOascBLeyhGcsGq6GKu0dBs(WzTds(JsjXEZgsGxajZ8pgKL1l8TrJNb9FsMdH0RhkUfDHRjrEddLVS5Y4vSa0DQmS6DHVWkyFE8Zcho5eem8aZ6g4fGpG4tKiCCDEMS635WYBXOD1XODw74cx6SKLPKK0Jus(Jsjb7gQagVAejBtc2BnswOa5gLKfMKzUUbEb4dsspsj5pkLeSBOcy8Qnis8MKzUUbEb4K4WK8BHiXUWOKOEyRasWUblgLeMvJXzxqf(2KSas(dxZgswysWAErOfhnijflpibEbKy2arsSKmPKaXtYKcVaLK6foMk8MLK)OusWUHkGXRgrsSKGx)zh3rkjHTsYeem8GSSEHVnA8mO)tYC4sVSqfW4vJSWHtILjiy4bM1nWlaFaX)DoS82nBwg9aZ6MBSaG2XaIprcSevw7yGzDZnwaq7yODnLvZSFNdtb8AkRdZgOle)xeVMZ3OaSAGgykCEh4VBSqp7KmLir9chJEnBmWu48oWF3yHE2jr8AoFJcWQbAGPW5DG)UXc9S)I41C(gfGvd0atHZ7a)DJf6zpptZMiXeem8aZ6g4fGpG4)ohAHYtEBgSGfJE9gJZUGk8ThAxtz1KibAHYtEBgWUMn3f(oLxeAXrdTRPSAMLSmLKKEKsYm6THTWvejmS1MKkNjXkjXABAiskGsceVfKSas(TqKuaLeVjzMRBGxa(GeRqJGakj)jOMvbEZsYmx3qIJiPEHJrjzBscBLKOaSAqIdtsuzTd1miHlwEsGqEZssfKKU)jjkaRgisy4HnjCAb8MLKpCw7aVa6GSSEHVnA8mO)tYCCVnSfUIS497L1BuawnqjzYchoP3OQ943NNbS635Mdtb8AkRJkNVMnqxi(VZHL3UzZYOhyw3CvaeF4BpG4tKalrL1og2qnRc8M9IzDZq7AkRMzNnrIjiy4bM1nWlaFaXp735WsuzTJHnuZQaVzVyw3m0UMYQjrcJobbdpSHAwf4n7fZ6MbeFIeyzccgEGzDd8cWhq8Z(DoSevw7yG0c4n7TDw7aVa6q7AkRMejq8AoFJcWQbAG7T5I0c850nlzzkjj9iLK032B(hjFSyks2MeS3AwqI9MnEZsYeWv48psILegLhKaVas4xgkGeVHHq(2KSaskJHeeFXOrdYY6f(2OXZG(pjZHA7n)72lMYcho5CZHfq5MRIr7yugdAaX)fuU5Qy0ogLXGgEpp2S6Sjsak3CvmAhJYyqdGIxEJMpjtPlrcq5MRIr7yugdAyGav4B)zMs3SFNBccgEWVmuW1ByiKV9aIprI3UzZYOh8ldfC9ggc5BpakE5nA(Kmz1ejWcpWvumqAg(YVmuW1ByiKV9SFNdlrL1og2qnRc8M9IzDZq7AkRMejm6eem8WgQzvG3SxmRBgq8jsGLjiy4bM1nWlaFaXplzzkjj9iLKTjb7Tgjtqbj8aFbE4iLeiK3SKmZ1nKyfaq8HVnjWoafwqIdtcesnK4nYnkjlmjZ8pizBs4sJeiKssbhkGKIemRBM2Cqc8ci5TB2SmAsuyy)5A)(rs1gsGxaj2qnRc8MLemRBibIpCCLehMKOYAhQzqwwVW3gnEg0)jz(0U9DHVHTEl0tBJASWHtILjiy4bM1nWlaFaX)flVDZMLrpWSU5Qai(W3EaX)fXR58nkaRgObU3MlslW8m9flrL1ogiTaEZEBN1oWlGo0UMYQjrI5MGGHhyw3aVa8be)xeVMZ3OaSAGg4EBUiTaFgBFXsuzTJbslG3S32zTd8cOdTRPSA(ohpqXCzFMbtdmRBUtBo(ohw0)gY55vZqX5)b0kFxGPR(PjsGLOYAhdBOMvbEZEXSUzODnLvZSjsO)nKZZRMHIZ)dOv(Uatx9t)gaVtvJHIZ)dOv(Uatx9thVDZMLrpakE5n6ZjzIzJTVgDccgEyd1SkWB2lM1ndi(zNnrI5MGGHhyw3aVa8be)3OYAhdKwaVzVTZAh4fqhAxtz1mlzz9cFB04zq)NK5VkNV1l8TVzhfw0fUMmaENQgiYsYYuMssW(cfKKI2Ewjb7lu4nlj1l8Trds40GKkiX2zTvaj8aFbE8JKyjbzVGGKNdEqEqI3Hcaq8bjVTnE4BJizBsMrVnKWPfG5)rU(rwMssspsjHtlG3SK8HZAh4fqjXHj53crcdpNjX2ds0EHyTjjkaRgisQ2qI1xgkGeMvddH8TjPAdjZCDd8cWjPakj9gKa0Y8ZcswajXscqHbkYMeUu8tTojBtsWyjzbKGVaLKOaSAGgKL1l8TrJhJxsKwaVzVTZAh4fqTacPxg2EwVVcfEZMKjlE)Ez9gfGvdusMSWHtohMc41uwhiTaEZEBN1oWlGEFqXcd)flykGxtzDWVB(cVG7ZGMnrI5mBmq2LzzCzSaZLV8EauyGISRPS(fXR58nkaRgObU3MlslW8mnlzzkjHZEbbjyVdEqEqcNwaVzj5dN1oWlGsYBBJh(2KeljPQkpjCP4NADsG4jXBs(K1kqwwVW3gnEmE)NK5iTaEZEBN1oWlGAbesVmS9SEFfk8Mnjtw8(9Y6nkaRgOKmzHdNmQS2XaPfWB2B7S2bEb0H21uwnFnBmq2LzzCzSaZLV8EauyGISRPS(fXR58nkaRgObU3MlslW8yJSmLKSD(39X4rcELQIijSvsQx4BtY25FKaHQPSsIbc4nljp7QBn7nljvBiP3GKcrsrcqzHYfGK6f(2dYY6f(2OXJX7)Kmh3BZDkxOWITZ)UpgVKmrwswwVW3gnm4S3a4DQAGscH0RhkUfDHRjnfiv8D7RrFPEV8qbqrpTFkzz9cFB0WGZEdG3PQb6)KmhcPxpuCl6cxtIG6P8UMBHRH9puqwwVW3gnm4S3a4DQAG(pjZHq61df3IUW1KS5F823f(wiKJ75k8TjlRx4BJggC2Ba8ovnq)NK5qi96HIBrx4AsdqldSd0lgfH0mzjzzktjjZy5njFI1)RwqcYEHYgsElgfqsLZKaQMvrKSWKefGvdejvBib90Ua(IilRx4BJg4L3)NK5VkNV1l8TVzhfw0fUMCA32cua8xKKjlC4KtqWWJPD77cFdB9wON2g1mG4jlRx4BJg4L3)NK5ghXR5lEX6plC4KyjkaRgdhD5Z1pfqwMssspsjzMRBiXkaG4dFBs2MK3UzZYOjHF3S3SKubjzTqbjmJvjXBu1E8JKjOGKEdsCys(TqKWWZzswmk4v8K4nQAp(rI3KmZ)yqYmwPQKGGakji7YSmGDTnmh3BZK2gfqs1gsMrVnKG1CHcsCejBtYB3Szz0KmPWlqjzMwHbjml2Ebkj87M9MLeGIcG)cFBejomjqiVzjHZUmld4CHRKyDGJWjPAdjyvBJciXrKSqXGSSEHVnAGxENeZ6MRcG4dFBlC4KykGxtzDWVB(cVG7ZG(oN3OQ9438jzgRMibVgdyxBZOEHJr)cGAfEbS6azxMLbCUW1lpWr4d9VHCEE18flVDZMLrpW92CNYfkgq8FXYB3Szz0dKDzwgxglWCnAf2di(z)oN3OQ943NtMctxIerL1ogiTaEZEBN1oWlGo0UMYQ5lMc41uwhiTaEZEBN1oWlGEFqXcdp7xS82nBwg9a212mG4)ohwE7MnlJEG7T5oLlumG4tKaXR58nkaRgObU3MlslW8yBwYYusYmwPQKGGakj)wis4HcsG4jHlf)uRtYNW9jwNKTjjSvsIcWQbjomjPiOcByOmj)rPaxjXrn2jiPEHJrjHHT2Ka7S2H3SKW0mOvssuawnqdYY6f(2ObE59)jzoYUmlJlJfyU8L3w4WjNGGHhWLEzHkGXRgnG4)IfJobbdpyaQWggkFHlf46aI)lIxZ5BuawnqdCVnxKwGpZmKL1l8Trd8Y7)tY8xLZ36f(23SJcl6cxt(miYYusYFYzTjX6aFbE8JKz0BdjCAbiPEHVnjXscqHbkYMeRTPHiHHh2KG0c4n7TDw7aVakzz9cFB0aV8()Kmh3BZfPfWI3VxwVrby1aLKjlC4KrL1ogiTaEZEBN1oWlGo0UMYQ5lIxZ5BuawnqdCVnxKwG5XuaVMY6a3BZfPf4(GIfg(lwmBmq2LzzCzSaZLV8Ee(lvVz)IL3UzZYOhWU2MbepzzkjX6afwbKeljqiLeRv4Df(2K8jCFI1jXHjP6FKyTnnsCej9gKaXpilRx4BJg4L3)NK5McVRW32I3VxwVrby1aLKjlC4Kybtb8AkRJkNVMnqxiEYYuscZQrr1r(hjiETnKuKG7THKPCHcsE2fGvjPGdfqcM1ntBoiXHjbc5nlji7YSmGZfUscpWr4KuTHeCVnt5cfiskGsYR45vZGSSEHVnAGxE)FsMJ7T5oLluyHdN8TB2Sm6bU3M7uUqX4zxawfnptF51ya7ABg1lCm6xauRWlGvhi7YSmGZfUE5bocFO)nKZZRMVy5TB2Sm6bM1n3PnhdiEYYuss6rkjZCDdjyDZbjvqITZARas4b(c84hjm8WMK)euZQaVzjzMRBibINKyjHzijkaRgilizbKSHTcijQS2bIKTjHlTbzz9cFB0aV8()KmhZ6M70MdlC4KEJQ2JFFozkmDFJkRDmSHAwf4n7fZ6MH21uwnFJkRDmqAb8M92oRDGxaDODnLvZxeVMZ3OaSAGg4EBUiTaFojZorI5MlQS2XWgQzvG3SxmRBgAxtz18flrL1ogiTaEZEBN1oWlGo0UMYQz2ejq8AoFJcWQbAG7T5I0cKKPzjltjjwBBStqcesjXAkMfc4nljwpxSqkjomj)wisEvtcRgK4DSKmZ1nWlaNeVrHwglizbK4WKWPfWBws(WzTd8cOK4isIkRDOgsQ2qcdpNjX2ds0EHyTjjkaRgObzz9cFB0aV8()Km3OywiG3Sx(CXcPw4WjNdOWafzxtznrcVrv7XV5NHPB2VZHfmfWRPSo43nFHxW9zqjs4nQAp(nFYuy6M97CyjQS2XaPfWB2B7S2bEb0H21uwnjsmxuzTJbslG3S32zTd8cOdTRPSA(IfmfWRPSoqAb8M92oRDGxa9(GIfgE2zjltjjPhPKmtSsY2KG9wJehMKFlejMTXobjTQgsILKxHcsSMIzHaEZsI1ZflKAbjvBijSvGssbusYkcrsyxnjmdjrby1arYcfKmx6iHHh2K822a5XSdYY6f(2ObE59)jzoM1n3Pnhw4Wjr8AoFJcWQbAG7T5I0c855yM)FBBG8yyCeA7QJR(Sxfn0UMYQz2VEJQ2JFFozkmDFJkRDmqAb8M92oRDGxaDODnLvtIeyjQS2XaPfWB2B7S2bEb0H21uwnKLPKK0Jus4SlZYGKuCbMpLeRPvytIdtsyRKefGvdsCej10cfKeljgxjzbK8BHiXUWOKWzxMLbCUWvsSoWr4KO)nKZZRgsy4HnjZO3MjTnkGKfqcNDzwgWU2gsQx4y0bzz9cFB0aV8()KmhzxMLXLXcmxJwHTfVFVSEJcWQbkjtw4WjNlkaRgdBTYH9G)fFgBw9lIxZ5BuawnqdCVnxKwGpZmZMiXC8AmGDTnJ6fog9laQv4fWQdKDzwgW5cxV8ahHp0)gY55vZSKLPKK0Jus4GaaTnkGKyjzgltRiejBtsrsuawnijSRGehrc76nljXsIXvsQGKWwjb4S2bjHJRdYY6f(2ObE59)jzocca02OGBSx8Y0kczX73lR3OaSAGsYKfoCYOaSAmchxVXEnU(zSLUVtqWWdmRBGxa(WSmAYYuss6rkjZCDdjPTaG2bjBN)rIdtcxk(PwNKQnKmZ0iPakj1lCmkjvBijSvsIcWQbjm2g7eKyCLedeWBwscBLKND1TMhKL1l8Trd8Y7)tYCmRBUXcaAhw8(9Y6nkaRgOKmzHdNetb8AkRdZgOle)3OaSAmchxVXEnUoVv(DUjiy4bM1nWlaFywgDIetqWWdmRBGxa(aO4L3Op)2nBwg9aZ6M70MJbqXlVrZ(TEHJrVMngykCEh4VBSqp7KiEnNVrby1anWu48oWF3yHE2Fr8AoFJcWQbAG7T5I0c855s3)ZXS)lrL1ogbdhf3f(cxHo0UMYQz2zjlRx4BJg4L3)NK54EBM02OalC4KMngykCEh4VBSqp7r4Vu9M97CrL1ogiTaEZEBN1oWlGo0UMYQ5lIxZ5BuawnqdCVnxKwG5XuaVMY6a3BZfPf4(GIfgorcZgdKDzwgxglWC5lVhH)s1B2z)ohwaqTcVawDGSlZYaox46Lh4i8H(3qopVAsKOEHJrVMngykCEh4VBSqp7KiEnNVrby1anWu48oWF3yHE2ZswMssspsjHlf)uRrcdpSjX6L3taTsvbKyDuLXjbQZkcrsyRKefGvdsy45mjtkjtAEzqc2Sk2vKmPWlqjjSvsE7MnlJMK3IRisMQxQKL1l8Trd8Y7)tYCKDzwgxglWCnAf2w4WjbqTcVawDWxEpb0kvfC5rvgFO)nKZZRMVykGxtzDy2aDH4)gfGvJr446n2l)lUyZQZp3B3Szz0dKDzwgxglWCnAf2ddeOcF7)zFMzjltjjPhPKWzxMLbjypOq2KSnjyV1ibQZkcrsyRaLKcOKugdIeVFlU3SdYY6f(2ObE59)jzoYUmlJ7duiBlC4KGYnxfJ2XOmg0W75zYQKLPKK0JusMrVnKWPfGKyj5TnccxjXAfivssZEHyTdej8G9HizBs(eROvyqsAwrRzfjb73g2b4K4iscBhrIJiPiX2zTvaj8aFbE8JKWUAsaQzJWBws2MKpXkAfibQZkcrIPaPssyVqS2bIehrsnTqbjXss44kjluqwwVW3gnWlV)pjZX92CrAbS497L1BuawnqjzYchojIxZ5BuawnqdCVnxKwG5XuaVMY6a3BZfPf4(GIfg(7eem8WuGuVH9cXAhdiElE2L3jzYcVdfaG4JRJJRgVcnjtw4DOaaeFCD4KH)sfnFsSrwMssspsjzg92qYFKRFKeljVTrq4kjwRaPssA2leRDGiHhSpejBtcxAdssZkAnRijy)2WoaNehMKW2rK4isksSDwBfqcpWxGh)ijSRMeGA2i8MLeOoRiejMcKkjH9cXAhisCej10cfKeljHJRKSqbzz9cFB0aV8()Kmh3BZfox)SWHtobbdpmfi1ByVqS2XaI)lMc41uwhMnqxiElE2L3jzYcVdfaG4JRJJRgVcnjtw4DOaaeFCD4KH)sfnFsS99TB2Sm6bM1n3PnhdiEYYuss6rkjZO3gsWAUqbjomj)wismBJDcsAvnKeljafgOiBsS2MgAqcxS8K8ku4nljvqcZqYcibFbkjrby1arcdpSjHtlG3SK8HZAh4fqjjQS2HAiPAdj)wiskGssVbjqiVzjHZUmld4CHRKyDGJWjzbKyD0VNT)i5V6DQdeVMZ3OaSAGg4EBUiTaZNckDKWQbIKWwjb3BhhcNKfMK0rs1gscBLKgcFsbKSWKefGvd0GSSEHVnAGxE)FsMJ7T5oLluyHdNetb8AkRdZgOle)xq5MRIr7yGVyuCTJH3Z)kuCdhx)3QJ09fXR58nkaRgObU3MlslWNNJz(hB)LOYAhdChPGFdTRPSA(VEHJrVMngykCEh4VBSqp7)suzTJbp63Z2F3S3Po0UMYQ5)5q8AoFJcWQbAG7T5I0cmFkO0n7FzoEngWU2Mr9chJ(fa1k8cy1bYUmld4CHRxEGJWh6Fd588Qz2zjlRx4BJg4L3)NK5ykCEh4VBSqpBlE)Ez9gfGvdusMSWHtcuyGISRPS(nkaRgJWX1BSxJRZZStKyUOYAhdChPGFdTRPSA(A2yGSlZY4YybMlF59aOWafzxtzD2ejMGGHhqnmei7n71uGuBfHgq8KLPKeoE95vMK32gp8TjjwsqXYtYRqH3SKWLIFQ1jzBswy4zWOaSAGiHHT2Ka7S2H3SKyLKSasWxGsckQxQQHe8Dcrs1gsGqEZsI1r)E2(JK)Q3Pss1gs(WkMgjZOJuWVbzz9cFB0aV8()KmhzxMLXLXcmx(YBlC4KafgOi7AkRFJcWQXiCC9g71468mZxSevw7yG7if8BODnLvZ3OYAhdE0VNT)UzVtDODnLvZxeVMZ3OaSAGg4EBUiTaZJnYYusskqv5jHlf)uRtcepjBtsHibV6FKefGvdejfIe(fH8PSAbj6F(P8bjmS1MeyN1o8MLeRKKfqc(cusqr9svnKGVtisy4Hnjwh97z7ps(REN6GSSEHVnAGxE)FsMJSlZY4YybMlF5TfVFVSEJcWQbkjtw4Wjbkmqr21uw)gfGvJr446n2RX15zMVyjQS2Xa3rk43q7AkRMVyzUOYAhdKwaVzVTZAh4fqhAxtz18fXR58nkaRgObU3MlslW8ykGxtzDG7T5I0cCFqXcdp735WsuzTJbp63Z2F3S3Po0UMYQjrI5IkRDm4r)E2(7M9o1H21uwnFr8AoFJcWQbAG7T5I0c85KyB2zjlRx4BJg4L3)NK54EBUiTaw8(9Y6nkaRgOKmzHdNeXR58nkaRgObU3MlslW8ykGxtzDG7T5I0cCFqXcdBXZU8ojtw4DOaaeFCDCC14vOjzYcVdfaG4JRdNm8xQO5tInYY6f(2ObE59)jzoU3MlCU(zXZU8ojtw4DOaaeFCDCC14vOjzYcVdfaG4JRdNm8xQO5tITVVDZMLrpWSU5oT5yaXtwMssspsjHlf)uRrsHijxOGeGIwqqIdtY2Ke2kj4lgLSSEHVnAGxE)FsMJSlZY4YybMRrRWMSmLKKEKscxk(PwNKcrsUqbjafTGGehMKTjjSvsWxmkjvBiHlf)uRrIJizBsWERrwwVW3gnWlV)pjZr2LzzCzSaZLV8MSKSmLKKEKsY2KG9wJKpH7tSojXscRgKyTnnsc)LQ3SKuTHe9pZ7aLKyjj7TscepjtAekGegEytYmx3aVaCYY6f(2Ora8ovnqjHq61df3IUW1Kko)pGw57cmD1p1cho5B3Szz0dmRBUkaIp8ThafV8g95KmHTejE7MnlJEGzDZvbq8HV9aO4L3O5X2mKSmLKKg4hjXsc3V(rcZkfG1iHHh2KyTfAkRKWf1lv1qc2Bnejomj8lc5tzDqIvSjjVnRcib2zTdejm8WMe8fOKWSsbynsGqkIKkcfNpijwsq)6hjm8WMKQ)rYZqYcib7cekibcPK4XGSSEHVnAeaVtvd0)jzoesVEO4w0fUM0B0daf1uwV)nu1be(1Oy8NAHdNCccgEGzDd8cWhq8FNGGHh8ldfC9ggc5BpG4tKyArOVWoRDCbkE5n6ZjXMvtKyccgEWVmuW1ByiKV9aI)7B3Szz0dmRBUkaIp8ThafV8g9ptPBEyN1oUafV8gLiXeem8aZ6g4fGpG4)(2nBwg9GFzOGR3WqiF7bqXlVr)Zu6Mh2zTJlqXlVrjsm3B3Szz0d(LHcUEddH8ThafV8gnFsMS633UzZYOhyw3CvaeF4BpakE5nA(Kmz1z)c7S2XfO4L3O5tY0mGvjltjjC)6hjC2QgKmJqi)rcdpSjzMRBGxaozz9cFB0iaENQgO)tYCiKE9qXTOlCnjE9QjGEr2QgxCiK)SWHt(2nBwg9aZ6MRcG4dF7bqXlVrZZKvjltjjC)6hjPGHM(rcdpSjX6ldfqcZQHHq(2KaHkw1csWRuvsqqaLKyjb1oVssyRKKxgkki5pzDsIcWQbzz9cFB0iaENQgO)tYCiKE9qXTOlCnjAHYzncVzVaOPFw4WjNGGHh8ldfC9ggc5BpG4tKal8axrXaPz4l)YqbxVHHq(2w8(9Y6nkaRgOKmrwMssspsjbRLHvjXBKBuswysM5Fqc8cijSvsGDakibcPKSas2MeS3AKuWHcijSvsGDakibcPds4SxqqYZbpipiXHjbZ6gsuaeF4BtYB3Szz0K4isyYQiswaj4lqjPyu)gKL1l8TrJa4DQAG(pjZHq61df3IUW1KiVHHYx2Cz8kwa6ovgw9UWxyfSpp(zHdN8TB2Sm6bM1nxfaXh(2dGIxEJMpjtwLSmLKKEKss2rbjlmjBpdcHusmfEXQKeaVtvdejBN)rIdtYFcQzvG3SKmZ1nKynDccgMehrs9chJAbjlGKFlejfqjP3GKOYAhQHeVJLepgKL1l8TrJa4DQAG(pjZFvoFRx4BFZokSOlCnPbN9gaVtvdKfoCY5WsuzTJHnuZQaVzVyw3m0UMYQjrcJobbdpSHAwf4n7fZ6Mbe)SFNBccgEGzDd8cWhq8js82nBwg9aZ6MRcG4dF7bqXlVrZZKvNLSmLKynfUGYbjWvopvVujbEbKaHQPSsIhko6tjj9iLKTj5TB2SmAs8MKfyuajt)ijaENQgKGYBmilRx4BJgbW7u1a9FsMdH0RhkoYcho5eem8aZ6g4fGpG4tKyccgEWVmuW1ByiKV9aIprI3UzZYOhyw3CvaeF4BpakE5nAEMS6joX5aa]] )

end
