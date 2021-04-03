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


    spec:RegisterPack( "Shadow", 20210403, [[de19ecqiOepsKOlbLIuBsvPpbLcJsrLtPO0Quvf5vQQQzrjClffODPWVqr1WOK4yOildkvptKqtdffxtKkBJsk13uuqJdfL6CkkG1PQinpvf19er7trv)JskrhuvrSqOKEiuknrkjDrkPWgvvf(iukQrQQkQtIIswjLOxsjLKzQQkPBQOq7uvHFsjfnukP6OusjSukPK6POYufPCvrQARkk6RIeSxv8xvzWehwYIvKhRstMIltAZG6ZO0OPuNMQvdLI41IKMTOUnuTBP(TsdhvDCvvPwoWZHmDHRdY2HIVJcJxvvIZRQY6HsrY8fH9J8HPtAhotf65dSBfSZKvygRKIdMyIzy2mZHl(XRho(6MAXQhUUW1dhNDzwgho(6xElZjTdhAHax9Wzhbp6tzoZz9WgAACxCMJCCOCf(2xqbhmh54xMF4MG8CWS6Z0HZuHE(a7wb7mzfMXkP4GjMygMDkYSpCfuyVGdhNJJThoB3y0(mD4mk6E44SlZYGeRdCffKLFcpWZKGDlib7wb7mrwswMgdTsLKzUUHK0waq7Geg2Atsuawni5UqDGiPakjWl4QMXHl7OaDs7WDzCpPD(GPtAhoTRPSAoy9WbH0hdBpRVBHcVzpFW0HRUHV9HdPfWB2x7S2bEb0d393nRVOaSAGoFW0H7c8qbED4MJemfWRPSoqAb8M91oRDGxa9DHIfgMKVKGfsWuaVMY6GF38dEbVRbrYSKKibjZrIzJbYUmlJhJfyE8L3dGcduKDnLvs(scIxZ5xuawnqdCVnpKwasMNeMiz2dNrrxGZh(2hU0Jus40c4nljF4S2bEbusCys(TqKWWZzsS9GeTxiwBsIcWQbIKQnKy9LHciHz1WqiFBsQ2qYmx3aVaCskGssVbjaTm)SGKfqsSKauyGISjHlf(uRtY2Kemwswaj4lqjjkaRgOXjoFG9tAhoTRPSAoy9WbH0hdBpRVBHcVzpFW0HRUHV9HdPfWB2x7S2bEb0d393nRVOaSAGoFW0H7c8qbED4IkRDmqAb8M91oRDGxaDODnLvdjFjXSXazxMLXJXcmp(Y7bqHbkYUMYkjFjbXR58lkaRgObU3MhslajZtc2pCgfDboF4BF44Sxqqc26GlKhKWPfWBws(WzTd8cOKC324HVnjXssQQYtcxk8PwNeiEs8MKpzTgN48rkEs7WPDnLvZbRhUTZ)Exg3dhthU6g(2hoCVnVPCHIdNrrxGZh(2hUTZ)ExgxsWRuvejHTssDdFBs2o)JeiunLvsmqaVzj5AxDRzVzjPAdj9gKuisksakluUaKu3W3ECItC4m4SVa4DQAGoPD(GPtAhoTRPSAoy9W1fUE4mfiv8D7NrVP(E8qbqrxTV6HRUHV9HZuGuX3TFg9M67XdfafD1(QN48b2pPD40UMYQ5G1dxx46Hdb1t5DnVcxd7FO4Wv3W3(WHG6P8UMxHRH9puCIZhP4jTdN21uwnhSE46cxpCS5F82Vf(viKJ75k8TpC1n8TpCS5F82Vf(viKJ75k8TpX5dM5K2Ht7AkRMdwpCDHRhodqldSd0hgfH08HRUHV9HZa0Ya7a9HrrinFItC4mkCbLJtANpy6K2HRUHV9Hd5zTV6Ht7AkRMdwpX5dSFs7WPDnLvZbRhUlWdf41HBccgEGzDd8cWhq8KKibjtqWWd(LHcEEddH8Thq8hU6g(2ho(n8TpX5Ju8K2Ht7AkRMdwpCl)HdPXHRUHV9Hdtb8AkRhomvgspCMngi7YSmEmwG5XxEpc)MQ3SK8LeZgdmfoVd87lwOR9i8BQEZE4WuGxx46HZSb6bXFIZhmZjTdN21uwnhSE4w(dhsJdxDdF7dhMc41uwpCyQmKE4mBmq2Lzz8ySaZJV8Ee(nvVzj5ljMngykCEh43xSqx7r43u9MLKVKy2yyumleWB2hFUyH0r43u9M9WHPaVUW1dxLZpZgOhe)joFKUtAhoTRPSAoy9WT8hoKghU6g(2homfWRPSE4Wuzi9WH41C(ffGvd0a3BZdPfGK5jb7K8pjtqWWdmRBGxa(aI)Wzu0f48HV9HJlkqqceYBws40c4nljF4S2bEbusQGKu8FsIcWQbIKfqcZ8pjomj)wiskGsI3KmZ1nWla)WHPaVUW1dhslG3SV2zTd8cOVluSWWN48H1(K2Ht7AkRMdwpCl)HdPXHRUHV9Hdtb8AkRhomvgspC3DZMLrpWSU5Pai(W3EaXtYxsMJeSqcOCZtXODmkJbnG4jjrcsaLBEkgTJrzmOHbcuHVnjFojjmzfssKGeq5MNIr7yugdAau8YBejZNKeMScj)ts6i5prYCKevw7yyd1SkWB2hM1ndTRPSAijrcsUlgTRogP(d4vtYSKmljFjzosMJeq5MNIr7yugdA4njZtc2TcjjsqcIxZ5xuawnqdmRBEkaIp8Tjz(KKKosMLKejijQS2XWgQzvG3SpmRBgAxtz1qsIeKCxmAxDms9hWRMKzpCgfDboF4BF4W2DZMLrtI13ntYmlGxtz1csspsnKelj87MjzsHxGssDdhtfEZscM1nWlaFqc2cbaAh5FKaHudjXsYD7aSzsyyRnjXssDdhtfkjyw3aVaCsy4HnjEFxCVzjPmg04WHPaVUW1dh)U5h8cExd6eNpMHN0oCAxtz1CW6H7c8qbED4MGGHhyw3aVa8be)HRUHV9Hd2b6uExZjoFWSpPD40UMYQ5G1d3f4Hc86WnbbdpWSUbEb4di(dxDdF7d3KcqkivVzpX5JzGtAhoTRPSAoy9Wv3W3(WLDw7a9WMazyX1ooCgfDboF4BF4spsj5V6S2b2arILqgwCTdsCyscBfOKuaLeStYcibFbkjrby1azbjlGKYyqKuaTXgbji(Ir7nljWlGe8fOKe2vtYmmDOXH7c8qbED4q8Ao)IcWQbAKDw7a9WMazyX1oiz(KKGDssKGK5iblKak38umAhJYyqd9V4OarsIeKak38umAhJYyqdVjzEsMHPJKzpX5dMSYjTdN21uwnhSE4UapuGxhUjiy4bM1nWlaFaXF4QB4BF4Q(QOau53TY5tC(GjMoPD40UMYQ5G1dxDdF7d3TY5xDdF7x2rXHl7O41fUE4UmUN48bty)K2Ht7AkRMdwpC1n8TpCaO(v3W3(LDuC4YokEDHRho8Y7tCIdhpqVl(ufN0oFW0jTdN21uwnhSE4UapuGxhoGIxEJi5ZKKIwXkhU6g(2ho(LHcEmwG5bVGWdiJEIZhy)K2Ht7AkRMdwpCxGhkWRdhwizccgEGSlZYaEb4di(dxDdF7dhYUmld4fGFIZhP4jTdN21uwnhSE4UapuGxhoVrv7XVHrH9RhKmpjmLUdxDdF7dxbUvRVybaTJtC(GzoPD40UMYQ5G1d3YF4qAC4QB4BF4WuaVMY6HdtLH0dh2pCykWRlC9WH7T5H0c8UqXcdFIZhP7K2HRUHV9HdtHZ7a)(If6AF40UMYQ5G1tCIdxa8ovnqN0oFW0jTdN21uwnhSE4mk6cC(W3(WLEKsY2KGTwLKpH7tSojXscRgKy1nnsc)MQ3SKuTHe9VW7aLKyjj7TscepjtAekGegEytYmx3aVa8dxx46HtX5)b0k)wGPR(QhUlWdf41H7UB2Sm6bM1npfaXh(2dGIxEJi5ZjjHjStsIeKC3nBwg9aZ6MNcG4dF7bqXlVrKmpjyFgE4QB4BF4uC(FaTYVfy6QV6joFG9tAhoTRPSAoy9Wzu0f48HV9HlnWpsILeUF9LeML1cRscdpSjXQl0uwjHlQBQQHeS1QisCys4xeYNY6GeRztsEBwfqcSZAhisy4Hnj4lqjHzzTWQKaHuejvekoFqsSKG(1xsy4Hnjv)JKRHKfqc2eiuqcesjXJXHRlC9W5n6cGIAkRV)gQ6ac)zum(vpCxGhkWRd3eem8aZ6g4fGpG4j5ljtqWWd(LHcEEddH8Thq8KKibjtlcrYxsGDw74bu8YBejFojjy3kKKibjtqWWd(LHcEEddH8Thq8K8LK7UzZYOhyw38uaeF4BpakE5nIK)jHP0rY8Ka7S2XdO4L3issKGKjiy4bM1nWlaFaXtYxsU7MnlJEWVmuWZByiKV9aO4L3is(NeMshjZtcSZAhpGIxEJijrcsMJK7UzZYOh8ldf88ggc5BpakE5nIK5tsctwHKVKC3nBwg9aZ6MNcG4dF7bqXlVrKmFssyYkKmljFjb2zTJhqXlVrKmFssyAgWkhU6g(2hoVrxauutz993qvhq4pJIXV6joFKIN0oCAxtz1CW6HZOOlW5dF7dh3V(scNTQbjZieYVKWWdBsM56g4fGF46cxpC41TMa6dzRA8WHq(9WDbEOaVoC3DZMLrpWSU5Pai(W3Eau8YBejZtctw5Wv3W3(WHx3AcOpKTQXdhc53tC(GzoPD40UMYQ5G1dxx46HdTq5SgH3Spa00Vd393nRVOaSAGoFW0H7c8qbED4MGGHh8ldf88ggc5BpG4jjrcsWcj8axrXaPz4h)YqbpVHHq(2hU6g(2ho0cLZAeEZ(aqt)oCgfDboF4BF44(1xsSwdn9JegEytI1xgkGeMvddH8TjbcvSQfKGxPQKGGakjXscQDELKWwjjVmuuqYF26KefGvJtC(iDN0oCAxtz1CW6HZOOlW5dF7dx6rkjyTmSkjEJCJsYctYm)dsGxajHTscSdqbjqiLKfqY2KGTwLKcouajHTscSdqbjqiDqcN9ccsUo4c5bjomjyw3qIcG4dFBsU7MnlJMehrctwbrYcibFbkjfJ634W1fUE4qEddLFS5Y4vSa0BQmS6BHFWkyVE87WDbEOaVoC3DZMLrpWSU5Pai(W3Eau8YBejZNKeMSYHRUHV9Hd5nmu(XMlJxXcqVPYWQVf(bRG96XVtC(WAFs7WPDnLvZbRhoJIUaNp8TpCPhPKKDuqYctY2ZGqiLetHxSkjbW7u1arY25FK4WK8NHAwf4nljZCDdjwvNGGHjXrKu3WXOwqYci53crsbus6nijQS2HAiX7yjXJXHRUHV9H7w58RUHV9l7O4WDbEOaVoCZrcwijQS2XWgQzvG3SpmRBgAxtz1qsIeKy0jiy4HnuZQaVzFyw3mG4jzws(sYCKmbbdpWSUbEb4diEssKGK7UzZYOhyw38uaeF4BpakE5nIK5jHjRqYShUSJIxx46HZGZ(cG3PQb6eNpMHN0oCAxtz1CW6HRUHV9HdcPppuC0HZOOlW5dF7dNvv4ckhKax58uDtLe4fqceQMYkjEO4OpLK0Jus2MK7UzZYOjXBswGrbKm9JKa4DQAqckVX4WDbEOaVoCtqWWdmRBGxa(aINKejizccgEWVmuWZByiKV9aINKeji5UB2Sm6bM1npfaXh(2dGIxEJizEsyYkN4ehURbDs78btN0oCAxtz1CW6HRUHV9HJFzOGN3WqiF7dNrrxGZh(2hU0JusS(YqbKWSAyiKVnjm8WMKzUUbEb4ds(ZB2qc8cizMRBGxaoj3fxrKSWWKC3nBwgnjEtsyRK06FjiHjRqcsVBBqKSHTcy4iLeiKsY2KCnKa1zfHijSvsSUMl2frsAGYdsW2fFQcsMr14rf(2K4isIkRDOglizbK4WKe2kqjHHNZK0BqYKss1ByRasM56gsSgai(W3MKW2rKa7S2XGKpjcfNpijwsq)6ljHTssUqbj8ldfqI3WqiFBswyscBLeyN1oijwsWSUHefaXh(2KaVas6TjXA1pGxnAC4UapuGxhoEGROyG0m8JFzOGN3WqiFBs(sYCKmbbdpWSUbEb4diEssKGeSqcAHYtEBg3fFQIhUA8OcF7H21uwnK8LK7UzZYOhyw38uaeF4BpakE5nIK5tsctwHKejib2zTJhqXlVrK8zsU7MnlJEGzDZtbq8HV9aO4L3isMLKVKmhjWoRD8akE5nIK5tsYD3Szz0dmRBEkaIp8ThafV8grY)KWu6i5lj3DZMLrpWSU5Pai(W3Eau8YBejFojjSxdj)jsygssKGeyN1oEafV8grY8KC3nBwg9GFzOGN3WqiF7HbcuHVnjjsqcSZAhpGIxEJi5ZKC3nBwg9aZ6MNcG4dF7bqXlVrK8pjmLossKGK7Ir7QJrQ)aE1KKibjtqWWJP8UMmekgq8Km7joFG9tAhoTRPSAoy9Wzu0f48HV9Hl9iLeSwgwLeVrUrjzHjzM)bjWlGKWwjb2bOGeiKsYcizBsWwRssbhkGKWwjb2bOGeiKoijf8WMKpCw7GK)OusS3SHe4fqYm)JXHRlC9WH8ggk)yZLXRybO3uzy13c)GvWE943H7c8qbED4MGGHhyw3aVa8bepjjsqs44kjZtctwHKVKmhjyHK7Ir7QJr7S2XdUusM9Wv3W3(WH8ggk)yZLXRybO3uzy13c)GvWE943joFKIN0oCAxtz1CW6HRUHV9HdU0hlubmE1OdNrrxGZh(2hU0Jus(JsjbBgQagVAejBtc2AvswOa5gLKfMKzUUbEb4dsspsj5pkLeSzOcy8Qnis8MKzUUbEb4K4WK8BHiXUWOKOEyRasWMblgLeMvJXzxqf(2KSas(dxZgswysWAErOfhnijfkpibEbKy2arsSKmPKaXtYKcVaLK6goMk8MLK)OusWMHkGXRgrsSKGx)fh3rkjHTsYeem84WDbEOaVoCyHKjiy4bM1nWlaFaXtYxsMJeSqYD3Szz0dmRBEXcaAhdiEssKGeSqsuzTJbM1nVybaTJH21uwnKmljFjzosWuaVMY6WSb6bXtYxsq8Ao)IcWQbAGPW5DGFFXcDTjjjjmrsIeKu3WXOpZgdmfoVd87lwORnjjjbXR58lkaRgObMcN3b(9fl01MKVKG41C(ffGvd0atHZ7a)(If6AtY8KWejZssIeKmbbdpWSUbEb4diEs(sYCKGwO8K3MblyXOpVX4SlOcF7H21uwnKKibjOfkp5Tza7A28w43uErOfhn0UMYQHKzpX5dM5K2Ht7AkRMdwpC1n8TpC4EBylCfD4U)Uz9ffGvd05dMoCxGhkWRdN3OQ94hjFMKzaRqYxsMJK5ibtb8AkRJkNFMnqpiEs(sYCKGfsU7MnlJEGzDZtbq8HV9aINKejiblKevw7yyd1SkWB2hM1ndTRPSAizwsMLKejizccgEGzDd8cWhq8KmljFjzosWcjrL1og2qnRc8M9HzDZq7AkRgssKGeJobbdpSHAwf4n7dZ6MbepjjsqcwizccgEGzDd8cWhq8KmljFjzosWcjrL1ogiTaEZ(AN1oWlGo0UMYQHKejibXR58lkaRgObU3MhslajFMK0rYShoJIUaNp8TpCPhPKmJEBylCfrcdBTjPYzssrsS6MgIKcOKaXBbjlGKFlejfqjXBsM56g4fGpiXA0iiGsYFgQzvG3SKmZ1nK4isQB4yus2MKWwjjkaRgK4WKevw7qnds4ILNeiK3SKubjP7FsIcWQbIegEytcNwaVzj5dN1oWlGooX5J0Ds7WPDnLvZbRhU6g(2hoO2EZ)E9IPoCgfDboF4BF4spsjj9T9M)rYhlMIKTjbBTQfKyVzJ3SKmbCfo)JKyjHr5bjWlGe(LHciXByiKVnjlGKYyibXxmA04WDbEOaVoCZrYCKGfsaLBEkgTJrzmObepjFjbuU5Py0ogLXGgEtY8KGDRqYSKKibjGYnpfJ2XOmg0aO4L3isMpjjmLossKGeq5MNIr7yugdAyGav4BtYNjHP0rYSK8LK5izccgEWVmuWZByiKV9aINKeji5UB2Sm6b)YqbpVHHq(2dGIxEJiz(KKWKvijrcsWcj8axrXaPz4h)YqbpVHHq(2KmljFjzosWcjrL1og2qnRc8M9HzDZq7AkRgssKGeJobbdpSHAwf4n7dZ6MbepjjsqcwizccgEGzDd8cWhq8Km7joFyTpPD40UMYQ5G1dxDdF7d30U9BHFHT(k0vBJAoCgfDboF4BF4spsjzBsWwRsYeuqcpWxGhosjbc5nljZCDdjwdaeF4BtcSdqHfK4WKaHudjEJCJsYctYm)ds2MeU0ibcPKuWHciPibZ6MPnhKaVasU7MnlJMefg2VU23FKuTHe4fqInuZQaVzjbZ6gsG4dhxjXHjjQS2HAghUlWdf41HdlKmbbdpWSUbEb4diEs(scwi5UB2Sm6bM1npfaXh(2diEs(scIxZ5xuawnqdCVnpKwasMNeMi5ljyHKOYAhdKwaVzFTZAh4fqhAxtz1qsIeKmhjtqWWdmRBGxa(aINKVKG41C(ffGvd0a3BZdPfGKptc2j5ljyHKOYAhdKwaVzFTZAh4fqhAxtz1qYxsMJeEGI5XEndMgyw38M2CqYxsMJeSqI(3qopVAgko)pGw53cmD1xLKejiblKevw7yyd1SkWB2hM1ndTRPSAizwssKGe9VHCEE1muC(FaTYVfy6QVkjFj5UB2Sm6HIZ)dOv(Tatx9vhafV8grYNtsctwBStYxsm6eem8WgQzvG3SpmRBgq8KmljZssIeKmhjtqWWdmRBGxa(aINKVKevw7yG0c4n7RDw7aVa6q7AkRgsM9eNpMHN0oCAxtz1CW6HRUHV9H7w58RUHV9l7O4WLDu86cxpCbW7u1aDItC4M2TpPD(GPtAhoTRPSAoy9WDbEOaVoCiEnNFrby1anW928qAbi5ZjjjfpC1n8TpCf6QTrnVPCHItC(a7N0oCAxtz1CW6H7c8qbED4IcWQXGHh2EZSj5ljiEnNFrby1ank0vBJAE9IPizEsyIKVKG41C(ffGvd0a3BZdPfGK5jHjs(NKOYAhdKwaVzFTZAh4fqhAxtz1C4QB4BF4k0vBJAE9IPoXjoC4L3N0oFW0jTdN21uwnhSE4UapuGxhUjiy4X0U9BHFHT(k0vBJAgq8houa8BC(GPdxDdF7d3TY5xDdF7x2rXHl7O41fUE4M2TpX5dSFs7Wv3W3(WzCeVMF4fRFpCAxtz1CW6joFKIN0oCAxtz1CW6HRUHV9HdZ6MNcG4dF7dNrrxGZh(2hU0JusM56gsSgai(W3MKTj5UB2SmAs43n7nljvqswluqcZyfs8gvTh)izckiP3GehMKFlejm8CMKfJcUfpjEJQ2JFK4njZ8pgKmJvQkjiiGscYUmldyxBdZX92mPTrbKuTHKz0BdjynxOGehrY2KC3nBwgnjtk8cusMP1yqcZITxGsc)UzVzjbOOa43W3grIdtceYBws4SlZYaox4kjwh4iCsQ2qcw12OasCejlumoCxGhkWRdhMc41uwh87MFWl4Dnis(sYCK4nQAp(rY8jjHzScjjsqcVgdyxBZOUHJrj5ljaOwHxaRoq2LzzaNlC9XdCe(q)BiNNxnK8LeSqYD3Szz0dCVnVPCHIbepjFjblKC3nBwg9azxMLXJXcmpJwH9aINKzj5ljZrI3OQ94hjFojjm70rsIeKevw7yG0c4n7RDw7aVa6q7AkRgs(scMc41uwhiTaEZ(AN1oWlG(UqXcdtYSK8LeSqYD3Szz0dyxBZaINKVKmhjyHK7UzZYOh4EBEt5cfdiEssKGeeVMZVOaSAGg4EBEiTaKmpjyNKzpX5dM5K2Ht7AkRMdwpC1n8TpCi7YSmEmwG5XxEF4mk6cC(W3(WnJvQkjiiGsYVfIeEOGeiEs4sHp16K8jCFI1jzBscBLKOaSAqIdtskaQWggktYFukWvsCuJncsQB4yusyyRnjWoRD4nljmndMIKefGvd04WDbEOaVoCtqWWd4sFSqfW4vJgq8K8LeSqIrNGGHhmavyddLFWLcCDaXtYxsq8Ao)IcWQbAG7T5H0cqYNjHzoX5J0Ds7WPDnLvZbRhU6g(2hUBLZV6g(2VSJIdx2rXRlC9WDnOtC(WAFs7WPDnLvZbRhU6g(2hoCVnpKwGd393nRVOaSAGoFW0H7c8qbED4IkRDmqAb8M91oRDGxaDODnLvdjFjbXR58lkaRgObU3MhslajZtcMc41uwh4EBEiTaVluSWWK8LeSqIzJbYUmlJhJfyE8L3JWVP6nljFjblKC3nBwg9a212mG4pCgfDboF4BF4(ZoRnjwh4lWJFKmJEBiHtlaj1n8Tjjwsakmqr2Ky1nnejm8WMeKwaVzFTZAh4fqpX5Jz4jTdN21uwnhSE4QB4BF4mfExHV9H7(7M1xuawnqNpy6WDbEOaVoCyHemfWRPSoQC(z2a9G4pCgfDboF4BF4SoqHvajXscesjXQfExHVnjFc3NyDsCysQ(hjwDtJehrsVbjq8JtC(GzFs7WPDnLvZbRhU6g(2hoCVnVPCHIdNrrxGZh(2hoMvJIQJ8psq8ABiPib3Bdjt5cfKCTlaRssbhkGemRBM2CqIdtceYBwsq2LzzaNlCLeEGJWjPAdj4EBMYfkqKuaLKBXZRMXH7c8qbED4U7MnlJEG7T5nLlumU2fGvrKmpjmrYxs41ya7ABg1nCmkjFjba1k8cy1bYUmld4CHRpEGJWh6Fd588QHKVKGfsU7MnlJEGzDZBAZXaI)eNpMboPD40UMYQ5G1dxDdF7dhM1nVPnhhoJIUaNp8TpCPhPKmZ1nKG1nhKubj2oRTciHh4lWJFKWWdBs(ZqnRc8MLKzUUHeiEsILeMHKOaSAGSGKfqYg2kGKOYAhis2MeU0ghUlWdf41HZBu1E8JKpNKeMD6i5ljrL1og2qnRc8M9HzDZq7AkRgs(ssuzTJbslG3SV2zTd8cOdTRPSAi5ljiEnNFrby1anW928qAbi5ZjjXAtsIeKmhjZrsuzTJHnuZQaVzFyw3m0UMYQHKVKGfsIkRDmqAb8M91oRDGxaDODnLvdjZssIeKG41C(ffGvd0a3BZdPfGKKKWejZEIZhmzLtAhoTRPSAoy9Wv3W3(WzumleWB2hFUyH0dNrrxGZh(2hoRUn2iibcPKyvfZcb8MLeRNlwiLehMKFlej3QjHvds8owsM56g4fGtI3OqlJfKSasCys40c4nljF4S2bEbusCejrL1oudjvBiHHNZKy7bjAVqS2KefGvd04WDbEOaVoCZrcqHbkYUMYkjjsqI3OQ94hjZtYmmDKmljFjzosWcjykGxtzDWVB(bVG31Gijrcs8gvTh)iz(KKWSthjZsYxsMJeSqsuzTJbslG3SV2zTd8cOdTRPSAijrcsMJKOYAhdKwaVzFTZAh4fqhAxtz1qYxsWcjykGxtzDG0c4n7RDw7aVa67cflmmjZsYSN48btmDs7WPDnLvZbRhU6g(2homRBEtBooCgfDboF4BF4spsjzMyLKTjbBTkjomj)wismBJncsAvnKelj3cfKyvfZcb8MLeRNlwi1csQ2qsyRaLKcOKKveIKWUAsygsIcWQbIKfkizU0rcdpSj5UTbYJzhhUlWdf41HdXR58lkaRgObU3MhslajFMK5iHzi5FsUBBG8yyCeA7QJNETxfn0UMYQHKzj5ljEJQ2JFK85KKWSthjFjjQS2XaPfWB2x7S2bEb0H21uwnKKibjyHKOYAhdKwaVzFTZAh4fqhAxtz1CIZhmH9tAhoTRPSAoy9Wv3W3(WHSlZY4XybMNrRW(WD)DZ6lkaRgOZhmD4UapuGxhU5ijkaRgdBTYH9G)gK8zsWUvi5ljiEnNFrby1anW928qAbi5ZKWmKmljjsqYCKWRXa212mQB4yus(scaQv4fWQdKDzwgW5cxF8ahHp0)gY55vdjZE4mk6cC(W3(WLEKscNDzwgKKclW8PKyvTcBsCyscBLKOaSAqIJiPMwOGKyjX4kjlGKFlej2fgLeo7YSmGZfUsI1bocNe9VHCEE1qcdpSjzg92mPTrbKSas4SlZYa212qsDdhJooX5dMsXtAhoTRPSAoy9Wv3W3(WHGaaTnk4f7dVmTIqhU7VBwFrby1aD(GPd3f4Hc86WffGvJr446l2NXvs(mjypDK8LKjiy4bM1nWlaFywg9HZOOlW5dF7dx6rkjCqaG2gfqsSKmJLPveIKTjPijkaRgKe2vqIJiHD9MLKyjX4kjvqsyRKaCw7GKWX1XjoFWeZCs7WPDnLvZbRhU6g(2homRBEXcaAhhU7VBwFrby1aD(GPd3f4Hc86WHPaEnL1Hzd0dINKVKefGvJr446l2NXvsMNKuKKVKmhjtqWWdmRBGxa(WSmAssKGKjiy4bM1nWlaFau8YBejFMK7UzZYOhyw38M2CmakE5nIKzj5lj1nCm6ZSXatHZ7a)(If6Atsssq8Ao)IcWQbAGPW5DGFFXcDTj5ljiEnNFrby1anW928qAbi5ZKmhjPJK)jzosS2K8NijQS2Xiy4O4TWp4k0H21uwnKmljZE4mk6cC(W3(WLEKsYmx3qsAlaODqY25FK4WKWLcFQ1jPAdjZmnskGssDdhJss1gscBLKOaSAqcJTXgbjgxjXab8MLKWwj5AxDR5XjoFWu6oPD40UMYQ5G1d3f4Hc86Wz2yGPW5DGFFXcDThHFt1Bws(sYCKevw7yG0c4n7RDw7aVa6q7AkRgs(scIxZ5xuawnqdCVnpKwasMNemfWRPSoW928qAbExOyHHjjrcsmBmq2Lzz8ySaZJV8Ee(nvVzjzws(sYCKGfsaqTcVawDGSlZYaox46Jh4i8H(3qopVAijrcsQB4y0NzJbMcN3b(9fl01MKKKG41C(ffGvd0atHZ7a)(If6AtYShU6g(2hoCVntABuWjoFWK1(K2Ht7AkRMdwpC1n8TpCi7YSmEmwG5z0kSpCgfDboF4BF4spsjHlf(uRscdpSjX6L3taTsvbKyDuLXjbQZkcrsyRKefGvdsy45mjtkjtAEzqc2Tc20KmPWlqjjSvsU7MnlJMK7IRisMQBQhUlWdf41Hda1k8cy1bF59eqRuvWJhvz8H(3qopVAi5ljykGxtzDy2a9G4j5ljrby1yeoU(I9XFJh2TcjZtYCKC3nBwg9azxMLXJXcmpJwH9WabQW3MK)jH9Aiz2tC(GPz4jTdN21uwnhSE4QB4BF4q2Lzz8UGczF4mk6cC(W3(WLEKscNDzwgKGTGcztY2KGTwLeOoRiejHTcuskGsszmis8(U4EZooCxGhkWRdhOCZtXODmkJbn8MK5jHjRCIZhmXSpPD40UMYQ5G1d3f4Hc86WH41C(ffGvd0a3BZdPfGK5jbtb8AkRdCVnpKwG3fkwyys(sYeem8WuGuFH9cXAhdi(dNrrxGZh(2hU0JusMrVnKWPfGKyj5UnccxjXQfivssZEHyTdej8G9IizBs(eRP1yqsAwtRAnjbB3g2b4K4iscBhrIJiPiX2zTvaj8aFbE8JKWUAsaQzJWBws2MKpXAAnibQZkcrIPaPssyVqS2bIehrsnTqbjXss44kjluC4U)Uz9ffGvd05dMoCEhkaaXhph(Wf(nv08jX(HZ7qbai(4544QXRqpCmD4U2L3hoMoC1n8TpC4EBEiTaN48btZaN0oCAxtz1CW6HZOOlW5dF7dx6rkjZO3gs(JC9JKyj5UnccxjXQfivssZEHyTdej8G9IizBs4sBqsAwtRAnjbB3g2b4K4WKe2oIehrsrITZARas4b(c84hjHD1KauZgH3SKa1zfHiXuGujjSxiw7arIJiPMwOGKyjjCCLKfkoCxGhkWRd3eem8WuGuFH9cXAhdiEs(scMc41uwhMnqpi(dN3Hcaq8XZHpCHFtfnFsS)9UB2Sm6bM1nVPnhdi(dN3Hcaq8XZXXvJxHE4y6WDTlVpCmD4QB4BF4W928GZ1VtC(a7w5K2Ht7AkRMdwpC1n8TpC4EBEt5cfhoJIUaNp8TpCPhPKmJEBibR5cfK4WK8BHiXSn2iiPv1qsSKauyGISjXQBAObjCXYtYTqH3SKubjmdjlGe8fOKefGvdejm8WMeoTaEZsYhoRDGxaLKOYAhQHKQnK8BHiPakj9gKaH8MLeo7YSmGZfUsI1bocNKfqI1r)U2(LK)Q3Poq8Ao)IcWQbAG7T5H0cmV1Y0rcRgiscBLeCVDCiCswysshjvBijSvsAi8jfqYctsuawnqJd3f4Hc86WHPaEnL1Hzd0dINKVKak38umAhd8fJIRDm8MK5j5wO4foUsY)KyLr6i5ljiEnNFrby1anW928qAbi5ZKmhjmdj)tc2j5prsuzTJbUJuWVH21uwnK8pj1nCm6ZSXatHZ7a)(If6AtYFIKOYAhdE0VRTFFzVtDODnLvdj)tYCKG41C(ffGvd0a3BZdPfGK5Twss6izws(tKmhj8AmGDTnJ6gogLKVKaGAfEbS6azxMLbCUW1hpWr4d9VHCEE1qYSKm7joFGDMoPD40UMYQ5G1dxDdF7dhMcN3b(9fl01(WDbEOaVoCafgOi7AkRK8LKOaSAmchxFX(mUsY8KyTjjrcsMJKOYAhdChPGFdTRPSAi5ljMngi7YSmEmwG5XxEpakmqr21uwjzwssKGKjiy4buddbYEZ(mfi1wrObe)H7(7M1xuawnqNpy6eNpWo2pPD40UMYQ5G1dxDdF7dhYUmlJhJfyE8L3hoJIUaNp8TpCC861Rmj3TnE4BtsSKGILNKBHcVzjHlf(uRtY2KSWWZGrby1arcdBTjb2zTdVzjjfjzbKGVaLeuu3uvdj47eIKQnKaH8MLeRJ(DT9lj)vVtLKQnK8H1mnsMrhPGFJd3f4Hc86WbuyGISRPSsYxsIcWQXiCC9f7Z4kjZtcZqYxsWcjrL1og4osb)gAxtz1qYxsIkRDm4r)U2(9L9o1H21uwnK8LeeVMZVOaSAGg4EBEiTaKmpjy)eNpWEkEs7WPDnLvZbRhU6g(2hoKDzwgpglW84lVpC3F3S(IcWQb68bthUlWdf41HdOWafzxtzLKVKefGvJr446l2NXvsMNeMHKVKGfsIkRDmWDKc(n0UMYQHKVKGfsMJKOYAhdKwaVzFTZAh4fqhAxtz1qYxsq8Ao)IcWQbAG7T5H0cqY8KGPaEnL1bU3MhslW7cflmmjZsYxsMJeSqsuzTJbp6312VVS3Po0UMYQHKejizosIkRDm4r)U2(9L9o1H21uwnK8LeeVMZVOaSAGg4EBEiTaK85KKGDsMLKzpCgfDboF4BF4SwPkpjCPWNADsG4jzBskej4v)JKOaSAGiPqKWViKpLvlir)lxLpiHHT2Ka7S2H3SKKIKSasWxGsckQBQQHe8DcrcdpSjX6OFxB)sYF17uhN48b2zMtAhoTRPSAoy9Wv3W3(WH7T5H0cC4U)Uz9ffGvd05dMoCEhkaaXhph(Wf(nv08jX(HZ7qbai(4544QXRqpCmD4UapuGxhoeVMZVOaSAGg4EBEiTaKmpjykGxtzDG7T5H0c8UqXcdF4U2L3hoMoX5dSNUtAhoTRPSAoy9Wv3W3(WH7T5bNRFhoVdfaG4JNdF4c)MkA(Ky)7D3Szz0dmRBEtBogq8hoVdfaG4JNJJRgVc9WX0H7AxEF4y6eNpWU1(K2Ht7AkRMdwpCgfDboF4BF4spsjHlf(uRssHijxOGeGIwqqIdtY2Ke2kj4lg9Wv3W3(WHSlZY4XybMNrRW(eNpW(m8K2Ht7AkRMdwpCgfDboF4BF4spsjHlf(uRtsHijxOGeGIwqqIdtY2Ke2kj4lgLKQnKWLcFQvjXrKSnjyRvpC1n8TpCi7YSmEmwG5XxEFItCIdhgfG8TpFGDRGDMSskYethogfO9MfD4sHpXA9hmRpWM)usijnBLehNFbbjWlGeSX1GWgKa0)gYbQHe0IRKuqXIxHAi5AxnRIgKL)vVvsS2Fkjy72yuqOgsWgbW7u1yut3XD3Szz0ydsILeSXD3Szz0JA6InizoM(lZoiljlzw48liudjmBsQB4Bts2rbAqwE44blSN1dxktjjC2LzzqI1bUIcYYuMss(eEGNjb7wqc2Tc2zISKSmLPKK0yOvQKmZ1nKK2caAhKWWwBsIcWQbj3fQdejfqjbEbx1miljltzkjXA8x0luOgsMu4fOKCx8Pkizsz9gni5tUxLpqK0BpdAxaCyOmj1n8TrKSD(3GSSUHVnAWd07IpvX)jzo)YqbpglW8Gxq4bKrTWHtcu8YB0NtrRyfYY6g(2ObpqVl(uf)NK5i7YSmGxaUfoCsSmbbdpq2LzzaVa8bepzzDdFB0GhO3fFQI)tY8cCRwFXcaAhw4Wj9gvTh)ggf2VEmptPJSSUHVnAWd07IpvX)jzoMc41uwTOlCnjU3MhslW7cflmSflFsKgwGPYqAsStww3W3gn4b6DXNQ4)KmhtHZ7a)(If6AtwswMYusI13W3grww3W3gLe5zTVkzzDdFBus(n8TTWHtobbdpWSUbEb4di(ejMGGHh8ldf88ggc5BpG4jlRB4BJ(pjZXuaVMYQfDHRjnBGEq8wS8jrAybMkdPjnBmq2Lzz8ySaZJV8Ee(nvVz)A2yGPW5DGFFXcDThHFt1BwYY6g(2O)tYCmfWRPSArx4AYkNFMnqpiElw(KinSatLH0KMngi7YSmEmwG5XxEpc)MQ3SFnBmWu48oWVVyHU2JWVP6n7xZgdJIzHaEZ(4ZflKoc)MQ3SKLPKeUOabjqiVzjHtlG3SK8HZAh4fqjPcssX)jjkaRgiswajmZ)K4WK8BHiPakjEtYmx3aVaCYY6g(2O)tYCmfWRPSArx4AsKwaVzFTZAh4fqFxOyHHTy5tI0WcmvgstI41C(ffGvd0a3BZdPfyES))eem8aZ6g4fGpG4jltjjy7UzZYOjX67MjzMfWRPSAbjPhPgsILe(DZKmPWlqjPUHJPcVzjbZ6g4fGpibBHaaTJ8psGqQHKyj5UDa2mjmS1MKyjPUHJPcLemRBGxaojm8WMeVVlU3SKugdAqww3W3g9FsMJPaEnLvl6cxtYVB(bVG31GSy5tI0WcmvgstE3nBwg9aZ6MNcG4dF7be)35WcOCZtXODmkJbnG4tKauU5Py0ogLXGggiqf(2Fojtwjrcq5MNIr7yugdAau8YB08jzYk)NU)0CrL1og2qnRc8M9HzDZq7AkRMejUlgTRogP(d4vp7SFNBoq5MNIr7yugdA498y3kjsG41C(ffGvd0aZ6MNcG4dF75tMUztKiQS2XWgQzvG3SpmRBgAxtz1KiXDXOD1Xi1FaV6zjlRB4BJ(pjZHDGoL31yHdNCccgEGzDd8cWhq8KL1n8Tr)NK5tkaPGu9M1cho5eem8aZ6g4fGpG4jltjjPhPK8xDw7aBGiXsidlU2bjomjHTcuskGsc2jzbKGVaLKOaSAGSGKfqszmiskG2yJGeeFXO9MLe4fqc(cusc7QjzgMo0GSSUHVn6)Kmp7S2b6HnbYWIRDyHdNeXR58lkaRgOr2zTd0dBcKHfx7y(KyprI5WcOCZtXODmkJbn0)IJcuIeGYnpfJ2XOmg0W75NHPBwYY6g(2O)tY8QVkkav(DRC2cho5eem8aZ6g4fGpG4jlRB4BJ(pjZVvo)QB4B)YokSOlCn5LXLSSUHVn6)Kmha1V6g(2VSJcl6cxtIxEtwswMYusYNy9)kjXscesjHHT2KG1DBswyscBLKpbD12OgsCej1nCmkzzDdFB0yA3ozHUABuZBkxOWchojIxZ5xuawnqdCVnpKwGpNmfjlRB4BJgt72)NK5f6QTrnVEXuw4WjJcWQXGHh2EZS)I41C(ffGvd0OqxTnQ51lMAEM(I41C(ffGvd0a3BZdPfyEM(pQS2XaPfWB2x7S2bEb0H21uwnKLKLPmLKGTwfrwMssspsjX6ldfqcZQHHq(2KWWdBsM56g4fGpi5pVzdjWlGKzUUbEb4KCxCfrYcdtYD3Szz0K4njHTssR)LGeMScji9UTbrYg2kGHJusGqkjBtY1qcuNveIKWwjX6AUyxejPbkpibBx8PkizgvJhv4BtIJijQS2HASGKfqIdtsyRaLegEotsVbjtkjvVHTcizMRBiXAaG4dFBscBhrcSZAhds(KiuC(GKyjb9RVKe2kj5cfKWVmuajEddH8TjzHjjSvsGDw7GKyjbZ6gsuaeF4Btc8ciP3MeRv)aE1ObzzDdFB04Aqj5xgk45nmeY32chojpWvumqAg(XVmuWZByiKV935MGGHhyw3aVa8beFIeybTq5jVnJ7IpvXdxnEuHV9q7AkRMV3DZMLrpWSU5Pai(W3Eau8YB08jzYkjsa7S2XdO4L3OpF3nBwg9aZ6MNcG4dF7bqXlVrZ(DoyN1oEafV8gnFY7UzZYOhyw38uaeF4BpakE5n6FMs337UzZYOhyw38uaeF4BpakE5n6ZjzVM)eZKibSZAhpGIxEJM)UB2Sm6b)YqbpVHHq(2ddeOcF7ejGDw74bu8YB0NV7MnlJEGzDZtbq8HV9aO4L3O)zkDjsCxmAxDms9hWRorIjiy4XuExtgcfdi(zjltjjPhPKW5zTVkjBtc2AvsILeEWEjHt5THWMcBGiX6G9Ml8k8ThKLPKK6g(2OX1G(pjZrEw7RAruawnEoCsauRWlGvhiL3gcBk0JhS3CHxHV9q)BiNNxnFNlkaRgdh9kJjrIOaSAmm6eem84wOWB2bqRBmlzzkjj9iLeSwgwLeVrUrjzHjzM)bjWlGKWwjb2bOGeiKsYcizBsWwRssbhkGKWwjb2bOGeiKoijf8WMKpCw7GK)OusS3SHe4fqYm)JbzzDdFB04Aq)NK5qi95HIBrx4AsK3Wq5hBUmEfla9MkdR(w4hSc2Rh)SWHtobbdpWSUbEb4di(ejchxNNjR8DoSCxmAxDmAN1oEWLolzzkjj9iLK)OusWMHkGXRgrY2KGTwLKfkqUrjzHjzMRBGxa(GK0Jus(JsjbBgQagVAdIeVjzMRBGxaojomj)wisSlmkjQh2kGeSzWIrjHz1yC2fuHVnjlGK)W1SHKfMeSMxeAXrdssHYdsGxajMnqKeljtkjq8KmPWlqjPUHJPcVzj5pkLeSzOcy8QrKelj41FXXDKssyRKmbbdpilRB4BJgxd6)KmhU0hlubmE1ilC4KyzccgEGzDd8cWhq8FNdl3DZMLrpWSU5flaODmG4tKalrL1ogyw38Ifa0ogAxtz1m735WuaVMY6WSb6bX)fXR58lkaRgObMcN3b(9fl01ojtjsu3WXOpZgdmfoVd87lwORDseVMZVOaSAGgykCEh43xSqx7ViEnNFrby1anWu48oWVVyHU2ZZ0SjsmbbdpWSUbEb4di(VZHwO8K3MblyXOpVX4SlOcF7H21uwnjsGwO8K3MbSRzZBHFt5fHwC0q7AkRMzjltjjPhPKmJEBylCfrcdBTjPYzssrsS6MgIKcOKaXBbjlGKFlejfqjXBsM56g4fGpiXA0iiGsYFgQzvG3SKmZ1nK4isQB4yus2MKWwjjkaRgK4WKevw7qnds4ILNeiK3SKubjP7FsIcWQbIegEytcNwaVzj5dN1oWlGoilRB4BJgxd6)Kmh3BdBHRilU)Uz9ffGvdusMSWHt6nQAp(95zaR8DU5WuaVMY6OY5Nzd0dI)7Cy5UB2Sm6bM1npfaXh(2di(ejWsuzTJHnuZQaVzFyw3m0UMYQz2ztKyccgEGzDd8cWhq8Z(DoSevw7yyd1SkWB2hM1ndTRPSAsKWOtqWWdBOMvbEZ(WSUzaXNibwMGGHhyw3aVa8be)SFNdlrL1ogiTaEZ(AN1oWlGo0UMYQjrceVMZVOaSAGg4EBEiTaFoDZswMssspsjj9T9M)rYhlMIKTjbBTQfKyVzJ3SKmbCfo)JKyjHr5bjWlGe(LHciXByiKVnjlGKYyibXxmA0GSSUHVnACnO)tYCO2EZ)E9IPSWHto3CybuU5Py0ogLXGgq8FbLBEkgTJrzmOH3ZJDRmBIeGYnpfJ2XOmg0aO4L3O5tYu6sKauU5Py0ogLXGggiqf(2FMP0n735MGGHh8ldf88ggc5BpG4tK4UB2Sm6b)YqbpVHHq(2dGIxEJMpjtwjrcSWdCffdKMHF8ldf88ggc5Bp735WsuzTJHnuZQaVzFyw3m0UMYQjrcJobbdpSHAwf4n7dZ6MbeFIeyzccgEGzDd8cWhq8ZswMssspsjzBsWwRsYeuqcpWxGhosjbc5nljZCDdjwdaeF4BtcSdqHfK4WKaHudjEJCJsYctYm)ds2MeU0ibcPKuWHciPibZ6MPnhKaVasU7MnlJMefg2VU23FKuTHe4fqInuZQaVzjbZ6gsG4dhxjXHjjQS2HAgKL1n8TrJRb9FsMpTB)w4xyRVcD12OglC4KyzccgEGzDd8cWhq8FXYD3Szz0dmRBEkaIp8Thq8Fr8Ao)IcWQbAG7T5H0cmptFXsuzTJbslG3SV2zTd8cOdTRPSAsKyUjiy4bM1nWlaFaX)fXR58lkaRgObU3MhslWNX(xSevw7yG0c4n7RDw7aVa6q7AkRMVZXdump2RzW0aZ6M30MJVZHf9VHCEE1muC(FaTYVfy6QVAIeyjQS2XWgQzvG3SpmRBgAxtz1mBIe6Fd588QzO48)aALFlW0vF1VbW7u1yO48)aALFlW0vF1XD3Szz0dGIxEJ(CsMS2y)RrNGGHh2qnRc8M9HzDZaIF2ztKyUjiy4bM1nWlaFaX)nQS2XaPfWB2x7S2bEb0H21uwnZsww3W3gnUg0)jz(TY5xDdF7x2rHfDHRjdG3PQbISKSmLPKeSTqbjPGTNvsW2cfEZssDdFB0GeoniPcsSDwBfqcpWxGh)ijwsq2lii56GlKhK4DOaaeFqYDBJh(2is2MKz0BdjCAby(FKRFKLPKK0Jus40c4nljF4S2bEbusCys(TqKWWZzsS9GeTxiwBsIcWQbIKQnKy9LHciHz1WqiFBsQ2qYmx3aVaCskGssVbjaTm)SGKfqsSKauyGISjHlf(uRtY2Kemwswaj4lqjjkaRgObzzDdFB04Y4MePfWB2x7S2bEbulGq6JHTN13TqH3SjzYI7VBwFrby1aLKjlC4KZHPaEnL1bslG3SV2zTd8cOVluSWWFXcMc41uwh87MFWl4DnOztKyoZgdKDzwgpglW84lVhafgOi7AkRFr8Ao)IcWQbAG7T5H0cmptZswMss4Sxqqc26GlKhKWPfWBws(WzTd8cOKC324HVnjXssQQYtcxk8PwNeiEs8MKpzTgKL1n8TrJlJ7)jzoslG3SV2zTd8cOwaH0hdBpRVBHcVztYKf3F3S(IcWQbkjtw4WjJkRDmqAb8M91oRDGxaDODnLvZxZgdKDzwgpglW84lVhafgOi7AkRFr8Ao)IcWQbAG7T5H0cmp2jltjjBN)9UmUKGxPQiscBLK6g(2KSD(hjqOAkRKyGaEZsY1U6wZEZss1gs6niPqKuKauwOCbiPUHV9GSSUHVnACzC)pjZX928MYfkSy78V3LXnjtKLKL1n8Trddo7laENQgOKqi95HIBrx4AstbsfF3(z0BQVhpuau0v7Rsww3W3gnm4SVa4DQAG(pjZHq6Zdf3IUW1KiOEkVR5v4Ay)dfKL1n8Trddo7laENQgO)tYCiK(8qXTOlCnjB(hV9BHFfc54EUcFBYY6g(2OHbN9faVtvd0)jzoesFEO4w0fUM0a0Ya7a9HrrintwswMYusYmwEtYNy9)QfKGSxOSHK7IrbKu5mjGQzvejlmjrby1ars1gsqxTlGViYY6g(2ObE59)jz(TY5xDdF7x2rHfDHRjN2TTafa)gjzYcho5eem8yA3(TWVWwFf6QTrndiEYY6g(2ObE59)jzUXr8A(HxS(LSmLKKEKsYmx3qI1aaXh(2KSnj3DZMLrtc)UzVzjPcsYAHcsygRqI3OQ94hjtqbj9gK4WK8BHiHHNZKSyuWT4jXBu1E8JeVjzM)XGKzSsvjbbbusq2Lzza7AByoU3MjTnkGKQnKmJEBibR5cfK4is2MK7UzZYOjzsHxGsYmTgdsywS9cus43n7nljaffa)g(2isCysGqEZscNDzwgW5cxjX6ahHts1gsWQ2gfqIJizHIbzzDdFB0aV8ojM1npfaXh(2w4WjXuaVMY6GF38dEbVRb9DoVrv7XV5tYmwjrcEngWU2MrDdhJ(fa1k8cy1bYUmld4CHRpEGJWh6Fd588Q5lwU7MnlJEG7T5nLlumG4)IL7UzZYOhi7YSmEmwG5z0kShq8Z(DoVrv7XVpNKzNUejIkRDmqAb8M91oRDGxaDODnLvZxmfWRPSoqAb8M91oRDGxa9DHIfgE2Vy5UB2Sm6bSRTzaX)DoSC3nBwg9a3BZBkxOyaXNibIxZ5xuawnqdCVnpKwG5X(SKLPKKzSsvjbbbus(TqKWdfKaXtcxk8PwNKpH7tSojBtsyRKefGvdsCyssbqf2Wqzs(JsbUsIJASrqsDdhJscdBTjb2zTdVzjHPzWuKKOaSAGgKL1n8Trd8Y7)tYCKDzwgpglW84lVTWHtobbdpGl9XcvaJxnAaX)flgDccgEWauHnmu(bxkW1be)xeVMZVOaSAGg4EBEiTaFMzilRB4BJg4L3)NK53kNF1n8TFzhfw0fUM8AqKLPKK)SZAtI1b(c84hjZO3gs40cqsDdFBsILeGcduKnjwDtdrcdpSjbPfWB2x7S2bEbuYY6g(2ObE59)jzoU3MhslGf3F3S(IcWQbkjtw4WjJkRDmqAb8M91oRDGxaDODnLvZxeVMZVOaSAGg4EBEiTaZJPaEnL1bU3MhslW7cflm8xSy2yGSlZY4XybMhF59i8BQEZ(fl3DZMLrpGDTndiEYYusI1bkScijwsGqkjwTW7k8Tj5t4(eRtIdts1)iXQBAK4is6nibIFqww3W3gnWlV)pjZnfExHVTf3F3S(IcWQbkjtw4WjXcMc41uwhvo)mBGEq8KLPKeMvJIQJ8psq8ABiPib3Bdjt5cfKCTlaRssbhkGemRBM2CqIdtceYBwsq2LzzaNlCLeEGJWjPAdj4EBMYfkqKuaLKBXZRMbzzDdFB0aV8()Kmh3BZBkxOWcho5D3Szz0dCVnVPCHIX1UaSkAEM(YRXa212mQB4y0VaOwHxaRoq2LzzaNlC9XdCe(q)BiNNxnFXYD3Szz0dmRBEtBogq8KLPKK0JusM56gsW6MdsQGeBN1wbKWd8f4Xpsy4Hnj)zOMvbEZsYmx3qcepjXscZqsuawnqwqYcizdBfqsuzTdejBtcxAdYY6g(2ObE59)jzoM1nVPnhw4Wj9gvTh)(CsMD6(gvw7yyd1SkWB2hM1ndTRPSA(gvw7yG0c4n7RDw7aVa6q7AkRMViEnNFrby1anW928qAb(CsRDIeZnxuzTJHnuZQaVzFyw3m0UMYQ5lwIkRDmqAb8M91oRDGxaDODnLvZSjsG41C(ffGvd0a3BZdPfijtZswMssS62yJGeiKsIvvmleWBwsSEUyHusCys(TqKCRMewniX7yjzMRBGxaojEJcTmwqYciXHjHtlG3SK8HZAh4fqjXrKevw7qnKuTHegEotIThKO9cXAtsuawnqdYY6g(2ObE59)jzUrXSqaVzF85IfsTWHtohqHbkYUMYAIeEJQ2JFZpdt3SFNdlykGxtzDWVB(bVG31GsKWBu1E8B(Km70n735WsuzTJbslG3SV2zTd8cOdTRPSAsKyUOYAhdKwaVzFTZAh4fqhAxtz18flykGxtzDG0c4n7RDw7aVa67cflm8SZswMssspsjzMyLKTjbBTkjomj)wismBJncsAvnKelj3cfKyvfZcb8MLeRNlwi1csQ2qsyRaLKcOKKveIKWUAsygsIcWQbIKfkizU0rcdpSj5UTbYJzhKL1n8Trd8Y7)tYCmRBEtBoSWHtI41C(ffGvd0a3BZdPf4ZZXm)F32a5XW4i02vhp9AVkAODnLvZSF9gvTh)(CsMD6(gvw7yG0c4n7RDw7aVa6q7AkRMejWsuzTJbslG3SV2zTd8cOdTRPSAiltjjPhPKWzxMLbjPWcmFkjwvRWMehMKWwjjkaRgK4isQPfkijwsmUsYci53crIDHrjHZUmld4CHRKyDGJWjr)BiNNxnKWWdBsMrVntABuajlGeo7YSmGDTnKu3WXOdYY6g(2ObE59)jzoYUmlJhJfyEgTcBlU)Uz9ffGvdusMSWHtoxuawng2ALd7b)n(m2TYxeVMZVOaSAGg4EBEiTaFMzMnrI541ya7ABg1nCm6xauRWlGvhi7YSmGZfU(4bocFO)nKZZRMzjltjjPhPKWbbaABuajXsYmwMwris2MKIKOaSAqsyxbjoIe21BwsILeJRKubjHTscWzTdschxhKL1n8Trd8Y7)tYCeeaOTrbVyF4LPveYI7VBwFrby1aLKjlC4Krby1yeoU(I9zC9ZypDFNGGHhyw3aVa8Hzz0KLPKK0JusM56gssBbaTds2o)JehMeUu4tTojvBizMPrsbusQB4yusQ2qsyRKefGvdsySn2iiX4kjgiG3SKe2kjx7QBnpilRB4BJg4L3)NK5yw38Ifa0oS4(7M1xuawnqjzYchojMc41uwhMnqpi(Vrby1yeoU(I9zCD(u87CtqWWdmRBGxa(WSm6ejMGGHhyw3aVa8bqXlVrF(UB2Sm6bM1nVPnhdGIxEJM9BDdhJ(mBmWu48oWVVyHU2jr8Ao)IcWQbAGPW5DGFFXcDT)I41C(ffGvd0a3BZdPf4ZZLU)NZA)NIkRDmcgokEl8dUcDODnLvZSZsww3W3gnWlV)pjZX92mPTrbw4WjnBmWu48oWVVyHU2JWVP6n735IkRDmqAb8M91oRDGxaDODnLvZxeVMZVOaSAGg4EBEiTaZJPaEnL1bU3MhslW7cflmCIeMngi7YSmEmwG5XxEpc)MQ3SZ(DoSaGAfEbS6azxMLbCUW1hpWr4d9VHCEE1KirDdhJ(mBmWu48oWVVyHU2jr8Ao)IcWQbAGPW5DGFFXcDTNLSmLKKEKscxk8PwLegEytI1lVNaALQciX6OkJtcuNveIKWwjjkaRgKWWZzsMusM08YGeSBfSPjzsHxGssyRKC3nBwgnj3fxrKmv3ujlRB4BJg4L3)NK5i7YSmEmwG5z0kSTWHtcGAfEbS6GV8EcOvQk4XJQm(q)BiNNxnFXuaVMY6WSb6bX)nkaRgJWX1xSp(B8WUvMFU7UzZYOhi7YSmEmwG5z0kShgiqf(2)ZEnZswMssspsjHZUmldsWwqHSjzBsWwRscuNveIKWwbkjfqjPmgejEFxCVzhKL1n8Trd8Y7)tYCKDzwgVlOq2w4WjbLBEkgTJrzmOH3ZZKviltjjPhPKmJEBiHtlajXsYDBeeUsIvlqQKKM9cXAhis4b7frY2K8jwtRXGK0SMw1Asc2UnSdWjXrKe2oIehrsrITZARas4b(c84hjHD1KauZgH3SKSnjFI10AqcuNveIetbsLKWEHyTdejoIKAAHcsILKWXvswOGSSUHVnAGxE)FsMJ7T5H0cyX93nRVOaSAGsYKfoCseVMZVOaSAGg4EBEiTaZJPaEnL1bU3MhslW7cflm83jiy4HPaP(c7fI1ogq8wCTlVtYKfEhkaaXhphhxnEfAsMSW7qbai(45Wjd)MkA(KyNSmLKKEKsYm6THK)ix)ijwsUBJGWvsSAbsLK0Sxiw7arcpyVis2MeU0gKKM10QwtsW2THDaojomjHTJiXrKuKy7S2kGeEGVap(rsyxnja1Sr4nljqDwrismfivsc7fI1oqK4isQPfkijwschxjzHcYY6g(2ObE59)jzoU3MhCU(zHdNCccgEykqQVWEHyTJbe)xmfWRPSomBGEq8wCTlVtYKfEhkaaXhphhxnEfAsMSW7qbai(45Wjd)MkA(Ky)7D3Szz0dmRBEtBogq8KLPKK0JusMrVnKG1CHcsCys(TqKy2gBeK0QAijwsakmqr2Ky1nn0GeUy5j5wOWBwsQGeMHKfqc(cusIcWQbIegEytcNwaVzj5dN1oWlGssuzTd1qs1gs(TqKuaLKEdsGqEZscNDzwgW5cxjX6ahHtYciX6OFxB)sYF17uhiEnNFrby1anW928qAbM3Az6iHvdejHTscU3ooeojlmjPJKQnKe2kjne(KcizHjjkaRgObzzDdFB0aV8()Kmh3BZBkxOWchojMc41uwhMnqpi(VGYnpfJ2XaFXO4AhdVN)wO4foU(VvgP7lIxZ5xuawnqdCVnpKwGpphZ8p2)trL1og4osb)gAxtz18FDdhJ(mBmWu48oWVVyHU2)POYAhdE0VRTFFzVtDODnLvZ)ZH41C(ffGvd0a3BZdPfyERLPB2)0C8AmGDTnJ6gog9laQv4fWQdKDzwgW5cxF8ahHp0)gY55vZSZsww3W3gnWlV)pjZXu48oWVVyHU2wC)DZ6lkaRgOKmzHdNeOWafzxtz9BuawngHJRVyFgxN3ANiXCrL1og4osb)gAxtz181SXazxMLXJXcmp(Y7bqHbkYUMY6SjsmbbdpGAyiq2B2NPaP2kcnG4jltjjC861Rmj3TnE4BtsSKGILNKBHcVzjHlf(uRtY2KSWWZGrby1arcdBTjb2zTdVzjjfjzbKGVaLeuu3uvdj47eIKQnKaH8MLeRJ(DT9lj)vVtLKQnK8H1mnsMrhPGFdYY6g(2ObE59)jzoYUmlJhJfyE8L3w4Wjbkmqr21uw)gfGvJr446l2NX15zMVyjQS2Xa3rk43q7AkRMVrL1og8OFxB)(YEN6q7AkRMViEnNFrby1anW928qAbMh7KLPKeRvQYtcxk8PwNeiEs2MKcrcE1)ijkaRgiskej8lc5tz1cs0)Yv5dsyyRnjWoRD4nljPijlGe8fOKGI6MQAibFNqKWWdBsSo6312VK8x9o1bzzDdFB0aV8()KmhzxMLXJXcmp(YBlU)Uz9ffGvdusMSWHtcuyGISRPS(nkaRgJWX1xSpJRZZmFXsuzTJbUJuWVH21uwnFXYCrL1ogiTaEZ(AN1oWlGo0UMYQ5lIxZ5xuawnqdCVnpKwG5XuaVMY6a3BZdPf4DHIfgE2VZHLOYAhdE0VRTFFzVtDODnLvtIeZfvw7yWJ(DT97l7DQdTRPSA(I41C(ffGvd0a3BZdPf4ZjX(SZsww3W3gnWlV)pjZX928qAbS4(7M1xuawnqjzYchojIxZ5xuawnqdCVnpKwG5XuaVMY6a3BZdPf4DHIfg2IRD5DsMSW7qbai(4544QXRqtYKfEhkaaXhphoz43urZNe7KL1n8Trd8Y7)tYCCVnp4C9ZIRD5DsMSW7qbai(4544QXRqtYKfEhkaaXhphoz43urZNe7FV7MnlJEGzDZBAZXaINSmLKKEKscxk8PwLKcrsUqbjafTGGehMKTjjSvsWxmkzzDdFB0aV8()KmhzxMLXJXcmpJwHnzzkjj9iLeUu4tTojfIKCHcsakAbbjomjBtsyRKGVyusQ2qcxk8PwLehrY2KGTwLSSUHVnAGxE)FsMJSlZY4XybMhF5nzjzzkjj9iLKTjbBTkjFc3NyDsILewniXQBAKe(nvVzjPAdj6FH3bkjXss2BLeiEsM0iuajm8WMKzUUbEb4KL1n8TrJa4DQAGscH0NhkUfDHRjvC(FaTYVfy6QVQfoCY7UzZYOhyw38uaeF4BpakE5n6Zjzc7jsC3nBwg9aZ6MNcG4dF7bqXlVrZJ9zizzkjjnWpsILeUF9LeML1cRscdpSjXQl0uwjHlQBQQHeS1QisCys4xeYNY6GeRztsEBwfqcSZAhisy4Hnj4lqjHzzTWQKaHuejvekoFqsSKG(1xsy4Hnjv)JKRHKfqc2eiuqcesjXJbzzDdFB0iaENQgO)tYCiK(8qXTOlCnP3OlakQPS((BOQdi8NrX4x1cho5eem8aZ6g4fGpG4)obbdp4xgk45nmeY3EaXNiX0IqFHDw74bu8YB0NtIDRKiXeem8GFzOGN3WqiF7be)37UzZYOhyw38uaeF4BpakE5n6FMs38WoRD8akE5nkrIjiy4bM1nWlaFaX)9UB2Sm6b)YqbpVHHq(2dGIxEJ(NP0npSZAhpGIxEJsKyU7UzZYOh8ldf88ggc5BpakE5nA(KmzLV3DZMLrpWSU5Pai(W3Eau8YB08jzYkZ(f2zTJhqXlVrZNKPzaRqwMss4(1xs4SvnizgHq(LegEytYmx3aVaCYY6g(2Ora8ovnq)NK5qi95HIBrx4As86wta9HSvnE4qi)AHdN8UB2Sm6bM1npfaXh(2dGIxEJMNjRqwMss4(1xsSwdn9JegEytI1xgkGeMvddH8TjbcvSQfKGxPQKGGakjXscQDELKWwjjVmuuqYF26KefGvdYY6g(2Ora8ovnq)NK5qi95HIBrx4As0cLZAeEZ(aqt)SWHtobbdp4xgk45nmeY3EaXNibw4bUIIbsZWp(LHcEEddH8TT4(7M1xuawnqjzISmLKKEKscwldRsI3i3OKSWKmZ)Ge4fqsyRKa7auqcesjzbKSnjyRvjPGdfqsyRKa7auqceshKWzVGGKRdUqEqIdtcM1nKOai(W3MK7UzZYOjXrKWKvqKSasWxGssXO(nilRB4BJgbW7u1a9FsMdH0NhkUfDHRjrEddLFS5Y4vSa0BQmS6BHFWkyVE8Zcho5D3Szz0dmRBEkaIp8ThafV8gnFsMSczzkjj9iLKSJcswys2EgecPKyk8IvjjaENQgis2o)JehMK)muZQaVzjzMRBiXQ6eemmjoIK6gog1cswaj)wiskGssVbjrL1oudjEhljEmilRB4BJgbW7u1a9FsMFRC(v3W3(LDuyrx4Asdo7laENQgilC4KZHLOYAhdBOMvbEZ(WSUzODnLvtIegDccgEyd1SkWB2hM1ndi(z)o3eem8aZ6g4fGpG4tK4UB2Sm6bM1npfaXh(2dGIxEJMNjRmlzzkjXQkCbLdsGRCEQUPsc8cibcvtzLepuC0Nss6rkjBtYD3Szz0K4njlWOasM(rsa8ovnibL3yqww3W3gncG3PQb6)KmhcPppuCKfoCYjiy4bM1nWlaFaXNiXeem8GFzOGN3WqiF7beFIe3DZMLrpWSU5Pai(W3Eau8YB08mzLdhIxVNpWE6y2N4eNda]] )


end
