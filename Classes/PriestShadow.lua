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
        driven_to_madness = 106, -- 199259
        greater_fade = 3753, -- 213602
        improved_mass_dispel = 5380, -- 341167
        megalomania = 5446, -- 357701
        mind_trauma = 113, -- 199445
        psyfiend = 763, -- 211522
        thoughtsteal = 5381, -- 316262
        void_origins = 739, -- 228630
        void_shield = 102, -- 280749
        void_shift = 128, -- 108968
        void_volley = 5447, -- 357711
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

        if IsActiveSpell( 356532 ) then
            applyBuff( "direct_mask", class.abilities.fae_guardians.lastCast + 20 - now )
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
            cast = function () return pvptalent.improved_mass_dispel.enabled and 0.5 or 1.5 end,
            cooldown = function () return pvptalent.improved_mass_dispel.enabled and 30 or 45 end,
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
                if buff.dark_thought.up and ( buff.casting.v1 == class.abilities.mind_flay.id or buff.casting.v1 == class.abilities.mind_sear.id or buff.casting.v1 == class.abilities.void_torrent.id ) then return true end
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

                if legendary.pallid_command.enabled then applyBuff( "pallid_command" ) end
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
            end,

            range = 15,

            auras = {
                unholy_transfusion = {
                    id = 324724,
                    duration = function () return conduit.festering_transfusion.enabled and 17 or 15 end,
                    max_stack = 1,
                },
                pallid_command = {
                    id = 356418,
                    duration = 20,
                    max_stack = 1
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
            nobuff = "direct_mask",

            handler = function ()
                applyBuff( "fae_guardians" )
                summonPet( "wrathful_faerie" )
                applyDebuff( "target", "wrathful_faerie" )
                summonPet( "guardian_faerie" )
                applyBuff( "guardian_faerie" )
                summonPet( "benevolent_faerie" )
                applyBuff( "benevolent_faerie" )

                if legendary.bwonsamdis_pact.enabled then
                    applyBuff( "direct_mask" )
                    applyDebuff( "target", "haunted_mask" )
                end
                -- TODO: Check totem/guardian API re: faeries.
            end,

            bind = "direct_mask",

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
                haunted_mask = {
                    id = 356968,
                    duration = 20,
                    max_stack = 1,
                },
                direct_mask = {
                    duration = 20,
                    max_stack = 1,
                }
            }
        },

        direct_mask = {
            id = 356532,
            cast = 0,
            cooldown = 0,
            gcd = "off",

            buff = "direct_mask",
            bind = "fae_guardians",

            handler = function ()
                applyDebuff( "target", "haunted_mask" )
            end,
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
                    duration = function () return ( conduit.shattered_perceptions.enabled and 7 or 5 ) + ( legendary.shadow_word_manipulation.enabled and 3 or 0 ) end,
                    max_stack = 1,
                },
                shadow_word_manipulation = {
                    id = 357028,
                    duration = 10,
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


    spec:RegisterPack( "Shadow", 20210818, [[diLvBcqivqpsq0LqLufBsf5tquAucOtjqwLkK0RGiMffLBbrQSlj9lbQgMa0XqLAzqu9mjcnnbGRjrQTHkP8nbHmoujX5GibRta08eKCpb1(ub(NkKqhuqWcrL4HqumrbPUOGqTrvi1hrLuzKqKOtkqHvsr1lvHemtbk6MqK0ovH6NOssdvIKJIkPQwkej0tPKPkr5QQqSvjI(QebJfIu1Eb5VQ0GjDyLwSeESQmzuUmXMb1NPWOPuNMQvRcj61sunBHUnK2Tu)wXWrvhxGslh45qnDrxxvTDi8DuX4HiLZRIA9OsQsZNISFKH4gQmil2Mc0XipGiN7aYv4MRurEalXqeY5kqw5zEbYIFFLVgcKvVOcKLL9Ygoqw8754SmOYGSWZh8eil7m5XbyWdUHN2)I6Bqdo2r)Xn9PFGfodo2rFbhYQ47Xmy0qfqwSnfOJrEaro3bKRWnxPI8awIHiKZ1GS2FApaillhfzGSSDgtAOcilMGFqww2lB4qAPaUGtY8q4B8XjPCZvmJuKhqKZnzozoYyVTHGdqYCKoslJJSLtAjhNrAzdaiDskhBPjnxGHKK(MFNysxGqk8aEcRsMJ0rAPasknJu2KysxGq6NNuo2stAUadjXKUaH0xCWcP5qk7S3gMrkEinT3K0(xUGjDbcP40JrsbYBqrLMjSkKv0XjgQmil01BOYGoMBOYGSKElIcdIlqwpGNcWxiRIpmCTyM(oW30wUl(jnty1ppK1(sFAiR3gJ39L(03OJtiROJZBVOcKvXmnucDmYHkdYs6TikmiUaz9aEkaFHSoK0CbgswD8LpUNfaK1(sFAilMJ5L4fDn8hucDCjcvgKL0BruyqCbYAFPpnKfIXzxb85tFAilMGFaNp9PHSocwiTKJZined(8PpnPtt6BMiB40KYpt0Bds3K0OS4K0aiGK6nEBpptAXpjTNKuhM0ZZNuoEms6GqaVLNuVXB75zs9M0sE0vsrQB5cP4pqifBVSHdSlnl4OEZkKMjas3Mrks1BgPCjU4Kuht60K(MjYgonPfc8aeslziUsAWWOhGqk)mrVnifi4e4V0NgtQdt6h7TbPw2lB4ahxuH0sbCmkPBZiLlsZeaPoM05NviRhWtb4lKfIf4BruQ8ZeVWd4(yysprAGK6nEBppt6bHjnaciPMmrkVKvyxAwDFPJqi9ePGFlWdWqQy7LnCGJlQC5bogTkb7355fgPNi9qsFZezdNUI6n7wexCw)8KEI0dj9ntKnC6k2EzdNlNbWUmzt76NN0Gi9ePbsQ34T98mPHkmPCLstQjtKMBu6SILf4TXTDd7eDbsv6TikmsprkIf4BruQyzbEBCB3WorxGCF)CGHjnispr6HK(MjYgoDf2LMv)8KEI0aj9qsFZezdNUI6n7wexCw)8KAYePyEjgV5cmKexr9MDXYci9asroPbr6jsdK0djfp)yH3SkIjUPhLlEIiKoRsVfrHrQjtKw8HHRiM4MEuU4jIq68A)r3ECw9ZtAqqj0XbauzqwsVfrHbXfiR9L(0qwy7LnCUCga7YVEdzXe8d48PpnKfsDlxif)bcPNNpP8)K0ppPwLqawksdbRqOuKonPPTqAUadjj1HjTeaBAd)JKE0RaCHuh3iBs6(shHqkhBPjf2nStVniLBKUsK0CbgsIRqwpGNcWxiRIpmCfELRXFbmFBC9Zt6jspKuMu8HHRCaBAd)Jx4vaUu)8KEIumVeJ3CbgsIROEZUyzbKgksdaOe64sdvgKL0BruyqCbYAFPpnK1BJX7(sF6B0XjKv0X5TxubY6XWqj0XCnOYGSKElIcdIlqw7l9PHSq9MDXYcGSENFr5MlWqsm0XCdz9aEkaFHSYnkDwXYc8242UHDIUaPk9wefgPNifZlX4nxGHK4kQ3SlwwaPhqkIf4BruQOEZUyzb33phyyspr6HKYMSITx2W5YzaSl)6Dn9x5EBq6jspK03mr2WPRWU0S6NhYIj4hW5tFAilKs3WM0sb8b45zsrQEZi1swaP7l9PjnhsbcmqW2Kg6PmmPC80MuSSaVnUTByNOlqGsOJdrqLbzj9wefgexGS2x6tdzXw0EtFAiR35xuU5cmKedDm3qwpGNcWxiRdjfXc8Tik1ngVSjX3ppKftWpGZN(0qwLciWcG0Ci9Jfsd9I2B6ttAiyfcLIuhM0TptAONYi1XK2ts6NVcLqhZvGkdYs6TikmiUazTV0NgYcBVSHZLZayxMSPnKftWpGZN(0qwhblKAzVSHdPLWayKgAztBsDys)yVni1YEzdh44IkKwkGJrjDBgPfsZeaPC8yKubPX7aHu2h4TbPPTqAliTKuJhRcz9aEkaFHS4LSc7sZQ7lDecPNif8BbEagsfBVSHdCCrLlpWXOvjy)opVWi9eP8swHDPzvGGUEJjnuHj14XGsOJrkavgKL0BruyqCbYAFPpnKfQ3SBrCXjKftWpGZN(0qwHqKZEgt6hlKI6nRiU4etQdt6B55fgPBZi1(3gcWBdsrmoJuht6NN0TzK(XEBqQL9YgoWXfviTuahJs62mslKMjasDmPF(kPKgcmMN(0BmE2msFlojf1BwrCXjPomPNNpPCMFKrAHq6V3IOqAoKAijPPTqkWHtslotkN1tVniDj14XQqwpGNcWxiRaj9ntKnC6kQ3SBrCXz9zVadbt6bKYnPNinqszsXhgUA)Bdb4TXfX4S6NNutMi9qsZnkDwT)THa824IyCwv6TikmsdIutMiLxYkSlnRce01BmPHkmPVfN30rfsrcPgpgPbr6js5LSc7sZQ7lDecPNif8BbEagsfBVSHdCCrLlpWXOvjy)opVWi9eP8swHDPzvGGUEJj9asFloVPJkqj0XChqOYGSKElIcdIlqw7l9PHSqmo7wmXeYIj4hW5tFAiRJGfsl54ms5Yets3KuB3WwaKYd8b45zs54PnPiL)2qaEBqAjhNr6NN0CinainxGHKyZiDaKoPTain3O0jM0Pj1QSkK1d4Pa8fYYB82EEM0qfMuUsPj9eP5gLoR2)2qaEBCrmoRk9wefgPNin3O0zfllWBJB7g2j6cKQ0BruyKEIumVeJ3CbgsIROEZUyzbKgQWKY1i1KjsdK0ajn3O0z1(3gcWBJlIXzvP3IOWi9ePhsAUrPZkwwG3g32nSt0fivP3IOWinisnzIumVeJ3CbgsIROEZUyzbKgMuUjniOe6yU5gQmilP3IOWG4cK1(sFAilMGy(aVnU8X14lqwmb)aoF6tdzf6Pr2K0pwin0cI5d82G0sfxJVqQdt655t6BBsnKKuVZH0soodEaOK6noLLzgPdGuhMulzbEBq6XUHDIUaHuhtAUrPtHr62ms54XiP2EsQ0Z3WM0CbgsIRqwpGNcWxiRajfiWabBVfrHutMi1B82EEM0dinevAsdI0tKgiPhskIf4BruQ8ZeVWd4(yysnzIuVXB75zspimPCLstAqKEI0aj9qsZnkDwXYc8242UHDIUaPk9wefgPMmrAGKMBu6SILf4TXTDd7eDbsv6Tikmspr6HKIyb(weLkwwG3g32nSt0fi33phyysdI0GGsOJ5g5qLbzj9wefgexGS2x6tdzHyC2TyIjKftWpGZN(0qwhblKwsUq60KImHMuhM0ZZNu20iBsAlcJ0Ci9T4K0qliMpWBdslvCn(IzKUnJ00wacPlqinkymPP92KgaKMlWqsmPZpjnWstkhpTj9nn77zqviRhWtb4lKfMxIXBUadjXvuVzxSSasdfPbsAaqksi9nn77zL5y80BNx5zpcUk9wefgPbr6js9gVTNNjnuHjLRuAsprAUrPZkwwG3g32nSt0fivP3IOWi1KjspK0CJsNvSSaVnUTByNOlqQsVfrHbLqhZDjcvgKL0BruyqCbYAFPpnKf2EzdNlNbWUmztBiR35xuU5cmKedDm3qwpGNcWxiRajnxGHKvBzJPDL)LKgksrEaj9ePyEjgV5cmKexr9MDXYcinuKgaKgePMmrAGKYlzf2LMv3x6iesprk43c8amKk2Ezdh44IkxEGJrRsW(DEEHrAqqwmb)aoF6tdzDeSqQL9YgoKwcdGfGKgAztBsDystBH0CbgssQJjDlMFsAoKYCH0bq655tQ9Iqi1YEzdh44IkKwkGJrjvc2VZZlms54PnPivVzfsZeaPdGul7LnCGDPzKUV0rivOe6yUdaOYGSKElIcdIlqw7l9PHSWFaqAMaU5CrxwlymK178lk3CbgsIHoMBiRhWtb4lKvUadjRPJk3CUmxinuKI8st6jsl(WWveJZGhaALnCAilMGFaNp9PHSocwi16dasZeaP5qksDzTGXKonPlP5cmKK00EtsDmPgJ3gKMdPmxiDtstBHuGByNKMoQuHsOJ5U0qLbzj9wefgexGS2x6tdzHyC2nhaq6eY6D(fLBUadjXqhZnK1d4Pa8fYcXc8Tikv2K47NN0tKMlWqYA6OYnNlZfspG0sK0tKgiPfFy4kIXzWdaTYgonPMmrAXhgUIyCg8aqRabD9gtAOi9ntKnC6kIXz3IjMvGGUEJjnispr6(shHCztwrSO8oWF3C(pBsdtkMxIXBUadjXvelkVd83nN)ZM0tKI5Ly8MlWqsCf1B2fllG0qrAGKwAsrcPbskxJ0JkP5gLoRjhhN3b(cVPuLElIcJ0GiniilMGFaNp9PHSocwiTKJZiTSbaKojD64zsDysTkHaSuKUnJ0swgPlqiDFPJqiDBgPPTqAUadjjLZ0iBskZfszFG3gKM2cPp7TBjwHsOJ5MRbvgKL0BruyqCbY6b8ua(czXMSIyr5DG)U58F210FL7TbPNinqsZnkDwXYc8242UHDIUaPk9wefgPNifZlX4nxGHK4kQ3SlwwaPhqkIf4BruQOEZUyzb33phyysnzIu2KvS9YgoxodGD5xVRP)k3BdsdI0tKgiPhsk43c8amKk2Ezdh44IkxEGJrRsW(DEEHrQjtKUV0rix2KvelkVd83nN)ZM0dct678lkxPfuxWKgeK1(sFAiluVzfsZeaucDm3HiOYGSKElIcdIlqw7l9PHSW2lB4C5ma2LjBAdzXe8d48PpnK1rWcPwLqagAs54PnPLA9UaiB5cG0sH3ikP)okymPPTqAUadjjLJhJKwiKwiXHdPipGC9qAHapaH00wi9ntKnCAsFdQGjTyFLxHSEapfGVqwGFlWdWqQ8R3fazlxaxE8grRsW(DEEHr6jsrSaFlIsLnj((5j9eP5cmKSMoQCZ5Y)YlYdiPhqAGK(MjYgoDfBVSHZLZayxMSPDL9bB6ttksi14XiniOe6yU5kqLbzj9wefgexGS2x6tdzHTx2W5(al2gYIj4hW5tFAiRJGfsTSx2WHuKbSyBsNMuKj0K(7OGXKM2cqiDbcPlJHj173G6TrfY6b8ua(czbwNDfesN1LXWvVj9as5oGqj0XCJuaQmilP3IOWG4cK1d4Pa8fYcZlX4nxGHK4kQ3SlwwaPhqkIf4BruQOEZUyzb33phyysprAXhgUYwq530E(g2z9ZdzXe8d48PpnK1rWcPivVzKAjlG0Ci9nn(JkKg6fuoPLzpFd7etkpyEysNM0qGRgIRKwgxn0CvsrMPHDakPoM002XK6ysxsTDdBbqkpWhGNNjnT3MuGWMm92G0Pjne4QHys)DuWyszlOCst75ByNysDmPBX8tsZH00rfsNFcz9o)IYnxGHKyOJ5gYY7uaGpFEDyiR0FLJpimYHS8ofa4ZNxhfvy(McKf3qwp71BilUHS2x6tdzH6n7ILfaLqhJ8acvgKL0BruyqCbYIj4hW5tFAiRJGfsrQEZi9OJ7zsZH0304pQqAOxq5KwM98nStmP8G5HjDAsTkRsAzC1qZvjfzMg2bOK6WKM2oMuht6sQTBylas5b(a88mPP92Kce2KP3gK(7OGXKYwq5KM2Z3WoXK6ys3I5NKMdPPJkKo)eY6b8ua(czv8HHRSfu(nTNVHDw)8KEIuelW3IOuztIVFEilVtba(851HHSs)vo(GWi)0BMiB40veJZUftmRFEilVtba(851rrfMVPazXnK1ZE9gYIBiR9L(0qwOEZUWX9mucDmY5gQmilP3IOWG4cK1(sFAiluVz3I4ItilMGFaNp9PHSocwifP6nJuUexCsQdt655tkBAKnjTfHrAoKceyGGTjn0tz4kPw5Wt6BXP3gKUjPbaPdGu0biKMlWqsmPC80MulzbEBq6XUHDIUaH0CJsNcJ0TzKEE(KUaH0Ess)yVni1YEzdh44IkKwkGJrjDaKwk85NT)iny6D5vmVeJ3CbgsIROEZUyzbhCuS0KAijM00wif1Bh9Js6atAPjDBgPPTqA)rleaPdmP5cmKexjneI4XmszdP9KKYdemMuuVzfXfNK(70JKUXiP5cmKet6cesztMcJuoEAtAjlJuo2st6h7TbPy7LnCGJlQqkpWXOK6WKwintaK6ysxeRh3IOuHSEapfGVqwiwGVfrPYMeF)8KEIuW6SRGq6SIoieuPZQ3KEaPVfN30rfsrcPbSwAsprkMxIXBUadjXvuVzxSSasdfPbsAaqksif5KEujn3O0zf1Xc4Cv6TikmsrcP7lDeYLnzfXIY7a)DZ5)Sj9OsAUrPZkp(8Z2F3O3LxLElIcJuKqAGKI5Ly8MlWqsCf1B2fllG0doksAPjnispQKgiP8swHDPz19LocH0tKc(TapadPITx2WboUOYLh4y0QeSFNNxyKgePbr6jsdK0djf8BbEagsfBVSHdCCrLlpWXOvjy)opVWi1KjspK03mr2WPRWU0S6NN0tKc(TapadPITx2WboUOYLh4y0QeSFNNxyKAYeP7lDeYLnzfXIY7a)DZ5)Sj9GWK(o)IYvAb1fmPbbLqhJCKdvgKL0BruyqCbYAFPpnKfIfL3b(7MZ)zdz9aEkaFHSacmqW2Brui9eP5cmKSMoQCZ5YCH0diLRrQjtKgiP5gLoROowaNRsVfrHr6jsztwX2lB4C5ma2LF9UceyGGT3IOqAqKAYePfFy46VH)GO3gx2ckVfmU(5HSENFr5MlWqsm0XCdLqhJ8seQmilP3IOWG4cK1(sFAilS9YgoxodGD5xVHSyc(bC(0NgYYIxE(gj9nnZtFAsZHuCo8K(wC6TbPwLqawksNM0bggPlxGHKys5ylnPWUHD6TbPLiPdGu0biKIZ9vUWifDkWKUnJ0p2Bdslf(8Z2FKgm9UCs3Mr6XC1YifP6ybCUcz9aEkaFHSacmqW2Brui9eP5cmKSMoQCZ5YCH0dinai9ePhsAUrPZkQJfW5Q0BruyKEI0CJsNvE85NT)UrVlVk9wefgPNifZlX4nxGHK4kQ3SlwwaPhqkYHsOJrEaavgKL0BruyqCbYAFPpnKf2EzdNlNbWU8R3qwVZVOCZfyijg6yUHSEapfGVqwabgiy7TikKEI0CbgswthvU5CzUq6bKgaKEI0djn3O0zf1Xc4Cv6Tikmspr6HKgiP5gLoRyzbEBCB3WorxGuLElIcJ0tKI5Ly8MlWqsCf1B2fllG0difXc8TikvuVzxSSG77NdmmPbr6jsdK0djn3O0zLhF(z7VB07YRsVfrHrQjtKgiP5gLoR84ZpB)DJExEv6TikmsprkMxIXBUadjXvuVzxSSasdvysroPbrAqqwmb)aoF6tdzDuqeEsTkHaSuK(5jDAsxmPOBFM0CbgsIjDXKYpySxefZivqApHpjLJT0Kc7g2P3gKwIKoasrhGqko3x5cJu0PatkhpTjTu4ZpB)rAW07YRqj0XiV0qLbzj9wefgexGS2x6tdzH6n7ILfaz9o)IYnxGHKyOJ5gYY7uaGpFEDyiR0FLJpimYHS8ofa4ZNxhfvy(McKf3qwpGNcWxilmVeJ3CbgsIROEZUyzbKEaPiwGVfrPI6n7ILfCF)CGHj9ePbs6HKINFSWBwfXe30JYfpresNvP3IOWi1KjspK03mr2WPRWrbB)alCw)8KgeK1ZE9gYIBOe6yKZ1GkdYs6TikmiUazTV0NgYc1B2foUNHS8ofa4ZNxhgYk9x54dcJ8tbEyXhgUYwq530E(g2z9ZBY0BMiB40veJZUftmRF(GGS8ofa4ZNxhfvy(McKf3qwp71BilUHSEapfGVqwhskE(XcVzvetCtpkx8eriDwLElIcJutMi9qsFZezdNUchfS9dSWz9ZdLqhJ8qeuzqwsVfrHbXfiR9L(0qwWrbB)alCcz5DkaWNpVomKv6VYXheMBilVtba(851rrfMVPazXnK1d4Pa8fYcp)yH3SkIjUPhLlEIiKoRsVfrHr6jspK0IpmCfX4m4bGw)8KEI0djT4ddx5hoc46n8h7tx)8qwmb)aoF6tdzDeSq6rhfS9dSWjPZpXotiDGjfD9M03mr2WPXKMdPOR356nPLCIB6rHuRjIq6K0IpmCfkHog5CfOYGSKElIcdIlqwmb)aoF6tdzDeSqQvjeGHM0ftACXjPabpGKuhM0PjnTfsrhecK1(sFAilS9YgoxodGDzYM2qj0XihPauzqwsVfrHbXfilMGFaNp9PHSocwi1QecWsr6IjnU4KuGGhqsQdt60KM2cPOdcH0TzKAvcbyOj1XKonPitOHS2x6tdzHTx2W5YzaSl)6nucLqwmuJBc8UCjXqLbDm3qLbzj9wefgexGS6fvGSylOC0z6ltELFV8)ei4N0pbYAFPpnKfBbLJotFzYR87L)Nab)K(jqj0XihQmilP3IOWG4cKvVOcKf(3fXzy3fvs7Z4eYAFPpnKf(3fXzy3fvs7Z4ekHoUeHkdYs6TikmiUaz1lQazzepZBFh47IXoQh30NgYAFPpnKLr8mV9DGVlg7OECtFAOe64aaQmilP3IOWG4cKvVOcKfdild2bYfHGXseYAFPpnKfdild2bYfHGXsekHsilMaV)ycvg0XCdvgK1(sFAilShL(jqwsVfrHbXfOe6yKdvgKL0BruyqCbY6b8ua(czv8HHRigNbpa06NNutMiT4ddx5hoc46n8h7tx)8qw7l9PHS4N0NgkHoUeHkdYs6TikmiUazn8qwyjHS2x6tdzHyb(wefileB8lqwbskBYk2EzdNlNbWU8R310FL7TbPMmrAUadjRPJk3CUmxinuHjnainisprAGKYMSIyr5DG)U58F210FL7TbPMmrAUadjRPJk3CUmxinuHjLRrAqqwiwWTxubYInj((5HsOJdaOYGSKElIcdIlqwdpKfwsiR9L(0qwiwGVfrbYcXg)cKfIf4BruQSjX3ppPNinqsztwzcI5d824YhxJVut)vU3gKAYeP5cmKSMoQCZ5YCH0qfM0aG0GGSqSGBVOcK1gJx2K47NhkHoU0qLbzj9wefgexGSgEilSKqw7l9PHSqSaFlIcKfIn(filmVeJ3CbgsIROEZUyzbKEaPiNuKqAXhgUIyCg8aqRFEilMGFaNp9PHSSYfKK(XEBqQLSaVni9y3WorxGq6MKwIiH0CbgsIjDaKgaiHuhM0ZZN0fiK6nPLCCg8aqHSqSGBVOcKfwwG3g32nSt0fi33phyyOe6yUguzqwsVfrHbXfiRHhYcljK1(sFAilelW3IOazHyJFbY6ntKnC6kIXzxb85tF66NN0tKgiPhskyD2vqiDwxgdx)8KAYePG1zxbH0zDzmCL9bB6ttAOctk3bKutMifSo7kiKoRlJHRabD9gt6bHjL7asksiT0KEujnqsZnkDwT)THa824IyCwv6TikmsnzI03Gq6TZA5Nb(2KgePbr6jsdK0ajfSo7kiKoRlJHREt6bKI8asQjtKI5Ly8MlWqsCfX4SRa(8PpnPheM0stAqKAYeP5gLoR2)2qaEBCrmoRk9wefgPMmr6Bqi92zT8ZaFBsdI0tKgiPhsk43c8amKkM3wac(AVa0PpxLG9788cJutMinqsFZezdNUYpCeW1B4p2NUce01BmPHkmPgpwfDrAKEujTej1Kjsl(WWv(HJaUEd)X(01ppPMmrAXGXKEIuy3WoVabD9gtAOctkYlnPbrAqqwmb)aoF6tdzHmZezdNM0sntK0sUaFlIIzKEeSWinhs5NjsAHapaH09LoIn92GueJZGhaALuK5dasNXZK(XcJ0Ci9nDcMiPCSLM0CiDFPJytHueJZGhakPC80MuVFdQ3gKUmgUczHyb3Erfil(zIx4bCFmmucDCicQmilP3IOWG4cK1d4Pa8fYQ4ddxrmodEaO1ppK1(sFAilyhifXzyqj0XCfOYGSKElIcdIlqwpGNcWxiRIpmCfX4m4bGw)8qw7l9PHSkeawaL7TbucDmsbOYGSKElIcdIlqw7l9PHSIUHDIVhLFMbQ0jKftWpGZN(0qwhblKgmDd7ezXKA(NzGkDsQdtAAlaH0fiKICshaPOdqinxGHKyZiDaKUmgM0finYMKI5xoT3gKcpasrhGqAAVnPHOsJRqwpGNcWxilmVeJ3CbgsIRr3WoX3JYpZav6K0dctkYj1KjsdK0djfSo7kiKoRlJHRcsZXjMutMifSo7kiKoRlJHREt6bKgIknPbbLqhZDaHkdYs6TikmiUaz9aEkaFHSk(WWveJZGhaA9ZdzTV0NgYA7NGtWgVVngHsOJ5MBOYGSKElIcdIlqw7l9PHSEBmE3x6tFJooHSIooV9IkqwpopOe6yUrouzqwsVfrHbXfiR9L(0qwGFF3x6tFJooHSIooV9IkqwOR3qjucz948Gkd6yUHkdYs6TikmiUaz9XYLJThL7BXP3gqhZnK1(sFAilSSaVnUTByNOlqGSENFr5MlWqsm0XCdz9aEkaFHScKuelW3IOuXYc8242UHDIUa5((5adt6jspKuelW3IOu5NjEHhW9XWKgePMmrAGKYMSITx2W5YzaSl)6DfiWabBVfrH0tKI5Ly8MlWqsCf1B2fllG0diLBsdcYIj4hW5tFAiRJGfsTKf4TbPh7g2j6cesDysppFs54XiP2EsQ0Z3WM0CbgsIjDBgPLA4iasdgn8h7tt62msl54m4bGs6ces7jjfil7SzKoasZHuGadeSnPwLqawksNM0KZq6aifDacP5cmKexHsOJrouzqwsVfrHbXfiRpwUCS9OCFlo92a6yUHS2x6tdzHLf4TXTDd7eDbcK178lk3CbgsIHoMBiRhWtb4lKvUrPZkwwG3g32nSt0fivP3IOWi9ePSjRy7LnCUCga7YVExbcmqW2Brui9ePyEjgV5cmKexr9MDXYci9asroKftWpGZN(0qww2dijfzCW77jPwYc82G0JDd7eDbcPVPzE6ttAoKwUi8KAvcbyPi9ZtQ3KgctigkHoUeHkdYs6TikmiUaznD889X5bzXnK1(sFAiluVz3I4ItilMGFaNp9PHSMoE((48ifDlxWKM2cP7l9PjD64zs)4TikKY(aVni9zVDlrVniDBgP9KKUysxsbIXpUas3x6txHsOeY6XWqLbDm3qLbzj9wefgexGS2x6tdzXpCeW1B4p2NgYIj4hW5tFAiRJGfsl1WraKgmA4p2NMuoEAtAjhNbpa0kPiLtKrk8aiTKJZGhakPVbvWKoWWK(MjYgonPEtAAlK2csljL7askwEtZWKoPTa44yH0pwiDAsFms)DuWystBHu(4EwaK6ys5xqs6atAAlKw(zGVnPVbH0BNMr6ai1HjnTfGqkhpgjTNK0cH0TN0waKwYXzKgIbF(0NM002XKc7g2zL0qitbLpjnhsXN7hPPTqACXjP8dhbqQ3WFSpnPdmPPTqkSByNKMdPigNrQa(8PpnPWdG0EAspkCg4BJRqwpGNcWxilEGl4SILi8LF4iGR3WFSpnPNinqsl(WWveJZGhaA9ZtQjtKEiPVbH0BN1Ypd8Tj9ePhs6Bqi92zTLhyIdGr6jsFZezdNUIyC2vaF(0NUce01BmPheMuUdiPMmrkSByNxGGUEJjnuK(MjYgoDfX4SRa(8PpDfiOR3ysdI0tKgiPWUHDEbc66nM0dct6BMiB40veJZUc4ZN(0vGGUEJjfjKYDPj9ePVzISHtxrmo7kGpF6txbc66nM0qfMuJhJ0JkPbaPMmrkSByNxGGUEJj9asFZezdNUYpCeW1B4p2NUY(Gn9Pj1KjslgmM0tKc7g25fiOR3ysdfPVzISHtxrmo7kGpF6txbc66nMuKqk3LMutMi9niKE7Sw(zGVnPMmrAXhgUweNHf)4S(5jniOe6yKdvgKL0BruyqCbYIj4hW5tFAiRJGfs5YYmes9g7mH0bM0sE0KcpastBHuyhGts)yH0bq60KImHM0fofaPPTqkSdWjPFSujTe80M0JDd7K0JEfsTNiJu4bqAjp6kKvVOcKf2B4F8AexMV5aW3ILzi3b(clG555ziRhWtb4lKvXhgUIyCg8aqRFEsnzI00rfspGuUdiPNinqspK03Gq6TZA7g25fEfsdcYAFPpnKf2B4F8AexMV5aW3ILzi3b(clG555zOe64seQmilP3IOWG4cK1(sFAil4vUg)fW8TXqwmb)aoF6tdzDeSq6rVcPCD)fW8TXKonPitOjD(j2zcPdmPLCCg8aqRKEeSq6rVcPCD)fW8Tzys9M0soodEaOK6WKEE(KAViesfpTfaPCDGbHqAWOr4gdytFAshaPhTlrgPdmPCjoy8GIRKwcRNKcpasztIjnhsles)8KwiWdqiDFPJytVni9OxHuUU)cy(2ysZHu0fP5OowinTfsl(WWviRhWtb4lK1HKw8HHRigNbpa06NN0tKgiPhs6BMiB40veJZU5aasN1ppPMmr6HKMBu6SIyC2nhaq6Sk9wefgPbr6jsdKuelW3IOuztIVFEsprkMxIXBUadjXvelkVd83nN)ZM0WKYnPMmr6(shHCztwrSO8oWF3C(pBsdtkMxIXBUadjXvelkVd83nN)ZM0tKI5Ly8MlWqsCfXIY7a)DZ5)Sj9as5M0Gi1Kjsl(WWveJZGhaA9Zt6jsdKu88JfEZQgGbHC9gHBmGn9PRsVfrHrQjtKINFSWBwf2Li7oW3I4GXdkUk9wefgPbbLqhhaqLbzj9wefgexGS2x6tdzH6nZyrfmK178lk3CbgsIHoMBiRhWtb4lKL34T98mPHIuKcbK0tKgiPbskIf4BruQBmEztIVFEsprAGKEiPVzISHtxrmo7kGpF6tx)8KAYePhsAUrPZQ9VneG3gxeJZQsVfrHrAqKgePMmrAXhgUIyCg8aqRFEsdI0tKgiPhsAUrPZQ9VneG3gxeJZQsVfrHrQjtKYKIpmC1(3gcWBJlIXzvGGUEJj9asFloVPJkKAYePhsAXhgUIyCg8aqRFEsdI0tKgiPhsAUrPZkwwG3g32nSt0fivP3IOWi1KjsX8smEZfyijUI6n7ILfqAOiT0KgeKftWpGZN(0qwhblKIu9MzSOcMuo2st6gJKwIKg6PmmPlqi9ZBgPdG0ZZN0fiK6nPLCCg8aqRKgIB8hiKIu(Bdb4TbPLCCgPC8yKuC6XiPfcPFEs5ylnPPTq6BXjPPJkKc7TJTfCLuRC4j9J92G0njT0iH0CbgsIjLJN2KAjlWBdsp2nSt0fivOe64sdvgKL0BruyqCbYAFPpnK1VTN45BpiwilMGFaNp9PHSocwi9iT9ept6XdIL0PjfzcTzKAprM3gKwaCboEM0CiLZ6jPWdGu(HJai1B4p2NM0bq6YyKI5xonUcz9aEkaFHScK0aj9qsbRZUccPZ6Yy46NN0tKcwNDfesN1LXWvVj9asrEajnisnzIuW6SRGq6SUmgUce01BmPheMuUlnPMmrkyD2vqiDwxgdxzFWM(0Kgks5U0KgePNinqspK0CJsNv7FBiaVnUigNvLElIcJutMiLjfFy4Q9VneG3gxeJZQFEsnzI0aj9ntKnC6kIXzxb85tF6kqqxVXKEaPChqsnzI0djfXc8Tikv(zIx4bCFmmPbr6jspK0IpmCfX4m4bGw)8KgeucDmxdQmilP3IOWG4cK1(sFAiRIz67aFtB5U4N0mHbzXe8d48PpnK1rWcPttkYeAsl(jP8aFaE6yH0p2Bdsl54msdXGpF6ttkSdWPzK6WK(XcJuVXotiDGjTKhnPttQvzK(XcPlCkasxsrmoRyIjPWdG03mr2WPjvGH9Nl97mPBZifEaKA)Bdb4TbPigNr6NpDuHuhM0CJsNcRcz9aEkaFHSoK0IpmCfX4m4bGw)8KEI0dj9ntKnC6kIXzxb85tF66NN0tKI5Ly8MlWqsCf1B2fllG0diLBspr6HKMBu6SILf4TXTDd7eDbsv6TikmsnzI0ajT4ddxrmodEaO1ppPNifZlX4nxGHK4kQ3SlwwaPHIuKt6jspK0CJsNvSSaVnUTByNOlqQsVfrHr6jsdKuEGG4A8yvURigNDlMys6jsdK0djvc2VZZlSQGYFgiB8oawV9ti1KjspK0CJsNv7FBiaVnUigNvLElIcJ0Gi1KjsLG9788cRkO8NbYgVdG1B)espr6BMiB40vbL)mq24DaSE7Nubc66nM0qfMuU5AiN0tKYKIpmC1(3gcWBJlIXz1ppPbrAqKAYePbsAXhgUIyCg8aqRFEsprAUrPZkwwG3g32nSt0fivP3IOWiniOe64qeuzqwsVfrHbXfiR9L(0qwVngV7l9PVrhNqwrhN3ErfiRe4D5sIHsOeYkbExUKyOYGoMBOYGSKElIcdIlqwmb)aoF6tdzDeSq60KImHM0qWkekfP5qQHKKg6Pmst)vU3gKUnJubPX7aH0Cin6Tq6NN0cjtbqkhpTjTKJZGhakKvVOcKLGYFgiB8oawV9tGSEapfGVqwVzISHtxrmo7kGpF6txbc66nM0qfMuUroPMmr6BMiB40veJZUc4ZN(0vGGUEJj9asrEicYAFPpnKLGYFgiB8oawV9tGsOJrouzqwsVfrHbXfilMGFaNp9PHSkdCM0Ci16C)inyW1p0KYXtBsd98lIcPw5(kxyKImHgtQdtk)GXEruQKYvBsJtBiasHDd7etkhpTjfDacPbdU(HM0pwWKUzkO8jP5qk(C)iLJN2KU9zsFmshaPhLFCs6hlK6zfYQxubYYB8d8ZTik3G9VD(rVmbH)eiRhWtb4lKvXhgUIyCg8aqRFEsprAXhgUYpCeW1B4p2NU(5j1KjslgmM0tKc7g25fiOR3ysdvysrEaj1Kjsl(WWv(HJaUEd)X(01ppPNi9ntKnC6kIXzxb85tF6kqqxVXKIes5U0KEaPWUHDEbc66nMutMiT4ddxrmodEaO1ppPNi9ntKnC6k)WraxVH)yF6kqqxVXKIes5U0KEaPWUHDEbc66nMutMinqsFZezdNUYpCeW1B4p2NUce01BmPheMuUdiPNi9ntKnC6kIXzxb85tF6kqqxVXKEqys5oGKgePNif2nSZlqqxVXKEqys5gPqaHS2x6tdz5n(b(5weLBW(3o)OxMGWFcucDCjcvgKL0BruyqCbYIj4hW5tFAilRZ9JulBrssrQFS)iLJN2KwYXzWdafYQxubYcDFBbqUyBrYl6h7piRhWtb4lK1BMiB40veJZUc4ZN(0vGGUEJj9as5oGqw7l9PHSq33waKl2wK8I(X(dkHooaGkdYs6TikmiUaz1lQazHNFmkz6TXf8lodz9o)IYnxGHKyOJ5gYAFPpnKfE(XOKP3gxWV4mK1d4Pa8fYQ4ddx5hoc46n8h7tx)8KAYePhskpWfCwXse(YpCeW1B4p2NMutMivc2VZZlSk2EzdhHDhqXDGV5aqLoHSyc(bC(0NgYY6C)ifP4V4mPC80M0snCeaPbJg(J9Pj9JxdXmsr3YfsXFGqAoKIBNxinTfsJdhbNKIuwksZfyizL0sWwAs)yHrkhpTj1YEzdhHrkxfuq6atAzdav60mspk)4K0pwiDAsrMqt6Ijf9)SjDXKYpySxeLkucDCPHkdYs6TikmiUazXe8d48PpnK1rWcPCzzgcPEJDMq6atAjpAsHhaPPTqkSdWjPFSq6aiDAsrMqt6cNcG00wif2b4K0pwQKAzpGK0NdEFpj1HjfX4msfWNp9Pj9ntKnCAsDmPChqmPdGu0biKUC2ZviRErfilS3W)41iUmFZbGVflZqUd8fwaZZZZqwpGNcWxiR3mr2WPRigNDfWNp9PRabD9gt6bHjL7aczTV0NgYc7n8pEnIlZ3Ca4BXYmK7aFHfW888mucDmxdQmilP3IOWG4cKftWpGZN(0qwhblKAzVSHJWiLRckiDGjTSbGkDskhBPjTNKuVjTKJZGhaQzKoas9M0cj5istAjhNrkxMys6BXjMuVjTKJZGhaAfYQxubYcBVSHJWUdO4oW3CaOsNqwpGNcWxiRdjT4ddxrmodEaO1ppPMmrAGKYdeexJhRYDfX4SBXetsdcYAFPpnKf2EzdhHDhqXDGV5aqLoHsOJdrqLbzj9wefgexGSyc(bC(0NgY6iyH0OJtshysNgP7Jfszl6AiKMaVlxsmPthptQdtks5VneG3gKwYXzKgAP4ddtQJjDFPJqmJ0bq655t6ces7jjn3O0PWi17Ci1ZkK1(sFAiR3gJ39L(03OJtiRhWtb4lKvGKEiP5gLoR2)2qaEBCrmoRk9wefgPMmrktk(WWv7FBiaVnUigNv)8KgePNinqsl(WWveJZGhaA9ZtQjtK(MjYgoDfX4SRa(8PpDfiOR3yspGuUdiPbbzfDCE7fvGSyOg3e4D5sIHsOJ5kqLbzj9wefgexGS2x6tdz9XY1tbfdzXe8d48PpnKvOf49htsH3ySyFLtk8ai9J3IOqQNckoaj9iyH0Pj9ntKnCAs9M0bWeaPfNjnbExUKKIJtwHSEapfGVqwfFy4kIXzWdaT(5j1Kjsl(WWv(HJaUEd)X(01ppPMmr6BMiB40veJZUc4ZN(0vGGUEJj9as5oGqjuczvmtdvg0XCdvgKL0BruyqCbY6b8ua(czH5Ly8MlWqsCf1B2fllG0qfM0seYAFPpnK1IFsZe2TiU4ekHog5qLbzj9wefgexGS2x6tdzT4N0mHD7bXczXe8d48PpnKfxTJNj9Jfsdb8tAMWi94bXskhBPjTNK0CJsNcJuVZHulzbEBq6XUHDIUaH0Pjf5iH0CbgsIRqwpGNcWxilmVeJ3CbgsIRl(jnty3EqSKEaPCt6jsX8smEZfyijUI6n7ILfq6bKYnPNi9qsZnkDwXYc8242UHDIUaPk9wefgucLqw8a5nOfBcvg0XCdvgKL0BruyqCbY6b8ua(czbe01BmPHI0smGbeYAFPpnKf)WraxodGDHhq65Njqj0XihQmilP3IOWG4cK1d4Pa8fYcp)yH3Sk)hN)OCfWNp9PRsVfrHrQjtKINFSWBwfXe30JYfpresNvP3IOWGS2x6tdzbhfS9dSWjucDCjcvgKL0BruyqCbY6b8ua(czDiPfFy4k2Ezdh4bGw)8qw7l9PHSW2lB4apauOe64aaQmilP3IOWG4cK1d4Pa8fYYB82EEUYey)5jPhqk3LgYAFPpnK1cEBl3CaaPtOe64sdvgKL0BruyqCbYQxubYcBVSHJWUdO4oW3CaOsNqw7l9PHSW2lB4iS7akUd8nhaQ0jucDmxdQmilP3IOWG4cK1WdzHLeYAFPpnKfIf4BruGSqSXVazHCilel42lQazH6n7ILfCF)CGHHsOJdrqLbzTV0NgYcXIY7a)DZ5)SHSKElIcdIlqjucLqwiea2Ng6yKhqKZDa5kbmaGS4SG2BdmKvjecifpoyCmxxaskPLzlK6O8dijfEaKIS8a5nOfBISKcKG97aHrkEqfs3FoOBkmsF2BBi4kzEW0BHuKhGKImtJqaPWifzXZpw4nRI0JSKMdPilE(XcVzvK(Q0BruyilPbYnslOkzEW0BHuKhGKImtJqaPWifzXZpw4nRI0JSKMdPilE(XcVzvK(Q0BruyilPBsAiMRgmjnqUrAbvjZjZlHqaP4XbJJ56cqsjTmBHuhLFajPWdGuKfD9gzjfib73bcJu8GkKU)Cq3uyK(S32qWvY8GP3cPLyaskYmncbKcJuKfp)yH3SkspYsAoKIS45hl8Mvr6RsVfrHHSKgi3iTGQK5btVfsrEPdqsrMPriGuyKIS45hl8Mvr6rwsZHuKfp)yH3SksFv6TikmKL0a5gPfuLmpy6TqkY5AbiPiZ0ieqkmsrw88JfEZQi9ilP5qkYINFSWBwfPVk9wefgYsAGCJ0cQsMhm9wif5HOaKuKzAecifgPilE(XcVzvKEKL0CifzXZpw4nRI0xLElIcdzjnqUrAbvjZjZlHqaP4XbJJ56cqsjTmBHuhLFajPWdGuK9XWilPajy)oqyKIhuH09Nd6McJ0N92gcUsMhm9wiLRfGKImtJqaPWifztG3LlzDlE13mr2WPrwsZHuK9ntKnC66w8qwsdKBKwqvYCY8Gbk)asHrkxH09L(0KgDCIRK5qwyE5bDmYlnxbYIhmWEuGSczij1YEzdhslfWfCsMhYqsAi8n(4KuU5kMrkYdiY5MmNmpKHKuKXEBdbhGK5HmKKI0rAzCKTCsl54mslBaaPts5ylnP5cmKK0387et6cesHhWtyvY8qgssr6iTuajLMrkBsmPlqi9ZtkhBPjnxGHKysxGq6loyH0CiLD2BdZifpKM2BsA)lxWKUaHuC6XiPa5nOOsZewLmNmpKHK0qmstE)uyKwiWdqi9nOfBsAHy4nUsAi8EcFIjTNgPZEbOW)iP7l9PXKoD8CLmFFPpnUYdK3GwSjschC(HJaUCga7cpG0ZptmZHdde01BCOkXagqY89L(04kpqEdAXMijCWHJc2(bw40mhomE(XcVzv(po)r5kGpF6tBYeE(XcVzvetCtpkx8eriDsMVV0Ngx5bYBql2ejHdo2Ezdh4bGAMdh(WIpmCfBVSHd8aqRFEY89L(04kpqEdAXMijCWxWBB5MdaiDAMdh2B82EEUYey)55bCxAY89L(04kpqEdAXMijCW)y56PGAwVOsyS9Ygoc7oGI7aFZbGkDsMVV0Ngx5bYBql2ejHdoIf4BrumRxujmQ3SlwwW99Zbg2SHpmwsZqSXVeg5K57l9PXvEG8g0Inrs4GJyr5DG)U58F2K5K5HmKKwQj9PXK57l9PXHXEu6NqMVV0NghMFsFAZC4WfFy4kIXzWdaT(5nzQ4ddx5hoc46n8h7tx)8K57l9PXijCWrSaFlIIz9IkHztIVFEZg(WyjndXg)s4aztwX2lB4C5ma2LF9UM(RCVnmzkxGHK10rLBoxMlHkCae0PaztwrSO8oWF3C(p7A6VY92WKPCbgswthvU5CzUeQWCTGiZ3x6tJrs4GJyb(wefZ6fvcVX4Lnj((5nB4dJL0meB8lHrSaFlIsLnj((5pfiBYktqmFG3gx(4A8LA6VY92WKPCbgswthvU5CzUeQWbqqK5HKuRCbjPFS3gKAjlWBdsp2nSt0fiKUjPLisinxGHKyshaPbasi1Hj988jDbcPEtAjhNbpauY89L(0yKeo4iwGVfrXSErLWyzbEBCB3WorxGCF)CGHnB4dJL0meB8lHX8smEZfyijUI6n7ILfCaYrsXhgUIyCg8aqRFEY8qskYmtKnCAsl1mrsl5c8TikMr6rWcJ0CiLFMiPfc8aes3x6i20BdsrmodEaOvsrMpaiDgpt6hlmsZH030jyIKYXwAsZH09LoInfsrmodEaOKYXtBs9(nOEBq6Yy4kz((sFAmschCelW3IOywVOsy(zIx4bCFmSzdFySKMHyJFj8BMiB40veJZUc4ZN(01p)PapeSo7kiKoRlJHRFEtMaRZUccPZ6Yy4k7d20NouH5oGMmbwNDfesN1LXWvGGUEJpim3bejL(OgyUrPZQ9VneG3gxeJZQsVfrHzY0Bqi92zT8ZaF7Gc6uGbcwNDfesN1LXWvVpa5b0KjmVeJ3CbgsIRigNDfWNp9PpiCPdYKPCJsNv7FBiaVnUigNvLElIcZKP3Gq6TZA5Nb(2bDkWdb)wGhGHuX82cqWx7fGo95QeSFNNxyMmf4BMiB40v(HJaUEd)X(0vGGUEJdvyJhRIUiTJAjAYuXhgUYpCeW1B4p2NU(5nzQyW4tWUHDEbc66nouHrEPdkiY8qgssrkkb73bcMu4piTfaPabHlCcqsjTmh1BdsrMqJjfEaKES8atCamslwSWiDAsHDd7K0O0gPnPBZinDuHuGGUE7THzKYdMITiEM0CgsrmXn9Oqk8ai1BKoJfvQK5HmKKUV0NgJKWbhXc8TikM1lQeMFM4fEa3hdB2WhglPzi24xc)MjYgoDfX4SRa(8PpD9ZFkWdbRZUccPZ6Yy46N3KjW6SRGq6SUmgUY(Gn9PdvyUdOjtG1zxbH0zDzmCfiOR34dcZDarsPpQbMBu6SA)Bdb4TXfX4SQ0BruyMm9gesVDwl)mW3oOGofyGG1zxbH0zDzmC17dqEanzcZlX4nxGHK4kIXzxb85tF6dcx6Gmzk3O0z1(3gcWBJlIXzvP3IOWmz6niKE7Sw(zGVDqNc8qWVf4byivmVTae81EbOtFUkb7355f2Pap8niKE7S2YdmXbWmzkWaHDd78ce01Bmsshvc6GWLyjgWtPJkHkmYdyanzkqy3WoVabD9gJK0rLGcvyKx6aEkqy3WoVabD9gJK0rLGoimYdyadkitMEZezdNUYpCeW1B4p2NUce01BCOcB8yv0fPDulrtMk(WWv(HJaUEd)X(01pVjtWUHDEbc66nouHrEPdImFFPpngjHdoSdKI4mmZC4WfFy4kIXzWdaT(5jZ3x6tJrs4GxiaSak3BdZC4WfFy4kIXzWdaT(5jZdjPhblKgmDd7ezXKA(NzGkDsQdtAAlaH0fiKICshaPOdqinxGHKyZiDaKUmgM0finYMKI5xoT3gKcpasrhGqAAVnPHOsJRK57l9PXijCWJUHDIVhLFMbQ0PzoCymVeJ3CbgsIRr3WoX3JYpZav68GWi3KPapeSo7kiKoRlJHRcsZXj2KjW6SRGq6SUmgU69bHOshez((sFAmsch8TFcobB8(2y0mhoCXhgUIyCg8aqRFEY89L(0yKeo4VngV7l9PVrhNM1lQe(X5rMVV0NgJKWbh877(sF6B0XPz9IkHrxVjZjZdzijnekvWK0Ci9Jfs5ylnPCzMM0bM00wineWpPzcJuht6(shHqMVV0NgxlMPdV4N0mHDlIlonZHdJ5Ly8MlWqsCf1B2flliuHlrY8qskxTJNj9Jfsdb8tAMWi94bXskhBPjTNK0CJsNcJuVZHulzbEBq6XUHDIUaH0Pjf5iH0CbgsIRK57l9PX1IzAKeo4l(jnty3EqSM5WHX8smEZfyijUU4N0mHD7bXEa3NW8smEZfyijUI6n7ILfCa3Nom3O0zfllWBJB7g2j6cKQ0BruyK5K5HmKKImHgtMhsspcwiTudhbqAWOH)yFAs54PnPLCCg8aqRKIuorgPWdG0soodEaOK(gubt6adt6BMiB40K6nPPTqAliTKuUdiPy5nndt6K2cGJJfs)yH0Pj9Xi93rbJjnTfs5J7zbqQJjLFbjPdmPPTqA5Nb(2K(gesVDAgPdGuhM00wacPC8yK0Essles3EsBbqAjhNrAig85tFAstBhtkSByNvsdHmfu(K0CifFUFKM2cPXfNKYpCeaPEd)X(0KoWKM2cPWUHDsAoKIyCgPc4ZN(0Kcpas7Pj9OWzGVnUsMVV0NgxFmCy(HJaUEd)X(0M5WH5bUGZkwIWx(HJaUEd)X(0NcS4ddxrmodEaO1pVjth(gesVDwl)mW3(0HVbH0BN1wEGjoa2P3mr2WPRigNDfWNp9PRabD9gFqyUdOjtWUHDEbc66nouVzISHtxrmo7kGpF6txbc66noOtbc7g25fiOR34dc)MjYgoDfX4SRa(8PpDfiOR3yKWDPp9MjYgoDfX4SRa(8PpDfiOR34qf24XoQbGjtWUHDEbc66n(G3mr2WPR8dhbC9g(J9PRSpytFAtMkgm(eSByNxGGUEJd1BMiB40veJZUc4ZN(0vGGUEJrc3L2KP3Gq6TZA5Nb(2Mmv8HHRfXzyXpoRF(GiZdjPhblKA5rPFcPttkYeAsZHuEW8i1s4T)C9ISyslfyEXfDtF6kzEijDFPpnU(yyKeo4ypk9tmlxGHKxhom43c8amKkw4T)C9IV8G5fx0n9PRsW(DEEHDkWCbgswD8DzmtMYfyizLjfFy46BXP3gvGSVmiY8qs6rWcPCzzgcPEJDMq6atAjpAsHhaPPTqkSdWjPFSq6aiDAsrMqt6cNcG00wif2b4K0pwQKwcEAt6XUHDs6rVcP2tKrk8aiTKhDLmFFPpnU(yyKeo4FSC9uqnRxujm2B4F8AexMV5aW3ILzi3b(clG555zZC4WfFy4kIXzWdaT(5nzkDu5aUd4Pap8niKE7S2UHDEHxjiY8qs6rWcPh9kKY19xaZ3gt60KImHM05NyNjKoWKwYXzWdaTs6rWcPh9kKY19xaZ3MHj1Bsl54m4bGsQdt655tQ9Iqiv80waKY1bgecPbJgHBmGn9PjDaKE0UezKoWKYL4GXdkUsAjSEsk8aiLnjM0CiTqi9ZtAHapaH09LoIn92G0JEfs56(lG5BJjnhsrxKMJ6yH00wiT4ddxjZ3x6tJRpggjHdo8kxJ)cy(2yZC4Whw8HHRigNbpa06N)uGh(MjYgoDfX4SBoaG0z9ZBY0H5gLoRigNDZbaKoRsVfrHf0ParSaFlIsLnj((5pH5Ly8MlWqsCfXIY7a)DZ5)SdZTjt7lDeYLnzfXIY7a)DZ5)SdJ5Ly8MlWqsCfXIY7a)DZ5)SpH5Ly8MlWqsCfXIY7a)DZ5)SpG7GmzQ4ddxrmodEaO1p)PaXZpw4nRAageY1BeUXa20NUk9wefMjt45hl8MvHDjYUd8Tioy8GIRsVfrHfezEij9iyHuKQ3mJfvWKYXwAs3yK0sK0qpLHjDbcPFEZiDaKEE(KUaHuVjTKJZGhaAL0qCJ)aHuKYFBiaVniTKJZiLJhJKItpgjTqi9ZtkhBPjnTfsFlojnDuHuyVDSTGRKALdpPFS3gKUjPLgjKMlWqsmPC80MulzbEBq6XUHDIUaPsMVV0NgxFmmschCuVzglQGn7D(fLBUadjXH52mhoS34T98COqkeWtbgiIf4BruQBmEztIVF(tbE4BMiB40veJZUc4ZN(01pVjthMBu6SA)Bdb4TXfX4SQ0BruybfKjtfFy4kIXzWdaT(5d6uGhMBu6SA)Bdb4TXfX4SQ0BruyMmXKIpmC1(3gcWBJlIXzvGGUEJp4T48MoQyY0HfFy4kIXzWdaT(5d6uGhMBu6SILf4TXTDd7eDbsv6TikmtMW8smEZfyijUI6n7ILfeQshezEij9iyH0J02t8mPhpiwsNMuKj0MrQ9ezEBqAbWf44zsZHuoRNKcpas5hocGuVH)yFAshaPlJrkMF504kz((sFAC9XWijCW)T9epF7bXAMdhoWapeSo7kiKoRlJHRF(tG1zxbH0zDzmC17dqEadYKjW6SRGq6SUmgUce01B8bH5U0MmbwNDfesN1LXWv2hSPpDO4U0bDkWdZnkDwT)THa824IyCwv6TikmtMysXhgUA)Bdb4TXfX4S6N3KPaFZezdNUIyC2vaF(0NUce01B8bChqtMoeXc8Tikv(zIx4bCFmCqNoS4ddxrmodEaO1pFqK5HK0JGfsNMuKj0Kw8ts5b(a80XcPFS3gKwYXzKgIbF(0NMuyhGtZi1Hj9JfgPEJDMq6atAjpAsNMuRYi9Jfsx4uaKUKIyCwXetsHhaPVzISHttQad7px63zs3Mrk8ai1(3gcWBdsrmoJ0pF6OcPomP5gLofwLmFFPpnU(yyKeo4fZ03b(M2YDXpPzcZmho8HfFy4kIXzWdaT(5pD4BMiB40veJZUc4ZN(01p)jmVeJ3CbgsIROEZUyzbhW9PdZnkDwXYc8242UHDIUaPk9wefMjtbw8HHRigNbpa06N)eMxIXBUadjXvuVzxSSGqH8thMBu6SILf4TXTDd7eDbsv6TikStbYdeexJhRYDfX4SBXeZtbEOeSFNNxyvbL)mq24DaSE7NyY0H5gLoR2)2qaEBCrmoRk9wefwqMmjb7355fwvq5pdKnEhaR3(jNsG3Llzvq5pdKnEhaR3(j13mr2WPRabD9ghQWCZ1q(jMu8HHR2)2qaEBCrmoR(5dkitMcS4ddxrmodEaO1p)PCJsNvSSaVnUTByNOlqQsVfrHfez((sFAC9XWijCWFBmE3x6tFJoonRxujCc8UCjXK5K5HmKKImlojTeS9OqkYS40Bds3x6tJRKAjjPBsQTBylas5b(a88mP5qk2EajPph8(EsQ3PaaF(K030mp9PXKonPivVzKAjli4hDCptMhsspcwi1swG3gKESByNOlqi1Hj988jLJhJKA7jPspFdBsZfyijM0TzKwQHJainy0WFSpnPBZiTKJZGhakPlqiTNKuGSSZMr6ainhsbcmqW2KAvcbyPiDAstodPdGu0biKMlWqsCLmFFPpnU(48cJLf4TXTDd7eDbIzFSC5y7r5(wC6TryUn7D(fLBUadjXH52mhoCGiwGVfrPILf4TXTDd7eDbY99Zbg(0HiwGVfrPYpt8cpG7JHdYKPaztwX2lB4C5ma2LF9UceyGGT3IOCcZlX4nxGHK4kQ3SlwwWbChezEij1YEajPiJdEFpj1swG3gKESByNOlqi9nnZtFAsZH0YfHNuRsialfPFEs9M0qycXK57l9PX1hNhschCSSaVnUTByNOlqm7JLlhBpk33ItVncZTzVZVOCZfyijom3M5WHZnkDwXYc8242UHDIUaPk9wef2j2KvS9YgoxodGD5xVRabgiy7TikNW8smEZfyijUI6n7ILfCaYjZdjPthpFFCEKIULlystBH09L(0KoD8mPF8wefszFG3gK(S3ULO3gKUnJ0EssxmPlPaX4hxaP7l9PRK57l9PX1hNhschCuVz3I4ItZMoE((48cZnzoz((sFACLHACtG3Lljo8hlxpfuZ6fvcZwq5OZ0xM8k)E5)jqWpPFcz((sFACLHACtG3LljgjHd(hlxpfuZ6fvcJ)DrCg2DrL0(mojZ3x6tJRmuJBc8UCjXijCW)y56PGAwVOsyJ4zE77aFxm2r94M(0K57l9PXvgQXnbExUKyKeo4FSC9uqnRxujmdild2bYfHGXsKmNmpKHKuK66nPHqPcMMrk2E(rgPVbHaiDJrsbBBiyshysZfyijM0TzKIFsVaFWK57l9PXv017WVngV7l9PVrhNM1lQeUyM2mhoCXhgUwmtFh4BAl3f)KMjS6NNmFFPpnUIUEJKWbN5yEjErxd)zMdh(WCbgswD8LpUNfazEij9iyH0sooJ0qm4ZN(0KonPVzISHttk)mrVniDtsJYItsdGasQ34T98mPf)K0EssDysppFs54XiPdcb8wEs9gVTNNj1Bsl5rxjfPULlKI)aHuS9YgoWU0SGJ6nRqAMaiDBgPivVzKYL4ItsDmPtt6BMiB40KwiWdqiTKH4kPbdJEacP8Ze92GuGGtG)sFAmPomPFS3gKAzVSHdCCrfslfWXOKUnJuUintaK6ysNFwjZ3x6tJROR3ijCWrmo7kGpF6tBMdhgXc8Tikv(zIx4bCFm8Pa9gVTNNpiCaeqtM4LSc7sZQ7lDeYjWVf4byivS9YgoWXfvU8ahJwLG9788c70HVzISHtxr9MDlIloRF(th(MjYgoDfBVSHZLZayxMSPD9Zh0Pa9gVTNNdvyUsPnzk3O0zfllWBJB7g2j6cKQ0BruyNqSaFlIsfllWBJB7g2j6cK77NdmCqNo8ntKnC6kSlnR(5pf4HVzISHtxr9MDlIloRFEtMW8smEZfyijUI6n7ILfCaYd6uGhINFSWBwfXe30JYfpresNMmv8HHRiM4MEuU4jIq68A)r3ECw9ZhezEijfPULlKI)aH0ZZNu(Fs6NNuRsialfPHGviuksNM00winxGHKK6WKwcGnTH)rsp6vaUqQJBKnjDFPJqiLJT0Kc7g2P3gKYnsxjsAUadjXvY89L(04k66nschCS9YgoxodGD5xVnZHdx8HHRWRCn(lG5BJRF(thYKIpmCLdytB4F8cVcWL6N)eMxIXBUadjXvuVzxSSGqfaK57l9PXv01BKeo4VngV7l9PVrhNM1lQe(XWK5HKuKs3WM0sb8b45zsrQEZi1swaP7l9PjnhsbcmqW2Kg6PmmPC80MuSSaVnUTByNOlqiZ3x6tJROR3ijCWr9MDXYcm7D(fLBUadjXH52mhoCUrPZkwwG3g32nSt0fivP3IOWoH5Ly8MlWqsCf1B2fll4aelW3IOur9MDXYcUVFoWWNoKnzfBVSHZLZayx(17A6VY9240HVzISHtxHDPz1ppzEijTuabwaKMdPFSqAOx0EtFAsdbRqOuK6WKU9zsd9ugPoM0Ess)8vY89L(04k66nschC2I2B6tB278lk3CbgsIdZTzoC4drSaFlIsDJXlBs89ZtMhsspcwi1YEzdhslHbWin0YM2K6WK(XEBqQL9YgoWXfviTuahJs62mslKMjas54XiPcsJ3bcPSpWBdstBH0wqAjPgpwLmFFPpnUIUEJKWbhBVSHZLZayxMSPTzoCyEjRWU0S6(shHCc8BbEagsfBVSHdCCrLlpWXOvjy)opVWoXlzf2LMvbc66nouHnEmY8qsAie5SNXK(XcPOEZkIloXK6WK(wEEHr62msT)THa82GueJZi1XK(5jDBgPFS3gKAzVSHdCCrfslfWXOKUnJ0cPzcGuht6NVskPHaJ5Pp9gJNnJ03Itsr9MvexCsQdt655tkN5hzKwiK(7TikKMdPgssAAlKcC4K0IZKYz90BdsxsnESkz((sFACfD9gjHdoQ3SBrCXPzoC4aFZezdNUI6n7wexCwF2lWqWhW9PazsXhgUA)Bdb4TXfX4S6N3KPdZnkDwT)THa824IyCwv6TikSGmzIxYkSlnRce01BCOc)wCEthvqIXJf0jEjRWU0S6(shHCc8BbEagsfBVSHdCCrLlpWXOvjy)opVWoXlzf2LMvbc66n(G3IZB6OczEij9iyH0sooJuUmXK0nj12nSfaP8aFaEEMuoEAtks5VneG3gKwYXzK(5jnhsdasZfyij2mshaPtAlasZnkDIjDAsTkRsMVV0NgxrxVrs4GJyC2TyIPzoCyVXB755qfMRu6t5gLoR2)2qaEBCrmoRk9wef2PCJsNvSSaVnUTByNOlqQsVfrHDcZlX4nxGHK4kQ3SlwwqOcZ1mzkWaZnkDwT)THa824IyCwv6TikSthMBu6SILf4TXTDd7eDbsv6TikSGmzcZlX4nxGHK4kQ3SlwwqyUdImpKKg6Pr2K0pwin0cI5d82G0sfxJVqQdt655t6BBsnKKuVZH0soodEaOK6noLLzgPdGuhMulzbEBq6XUHDIUaHuhtAUrPtHr62ms54XiP2EsQ0Z3WM0CbgsIRK57l9PXv01BKeo4mbX8bEBC5JRXxmZHdhiqGbc2ElIIjtEJ32ZZheIkDqNc8qelW3IOu5NjEHhW9XWMm5nEBppFqyUsPd6uGhMBu6SILf4TXTDd7eDbsv6TikmtMcm3O0zfllWBJB7g2j6cKQ0BruyNoeXc8TikvSSaVnUTByNOlqUVFoWWbfezEij9iyH0sYfsNMuKj0K6WKEE(KYMgztsBryKMdPVfNKgAbX8bEBqAPIRXxmJ0TzKM2cqiDbcPrbJjnT3M0aG0CbgsIjD(jPbwAs54PnPVPzFpdQsMVV0NgxrxVrs4GJyC2TyIPzoCymVeJ3CbgsIROEZUyzbHkWaajVPzFpRmhJNE78kp7rWvP3IOWc6K34T98COcZvk9PCJsNvSSaVnUTByNOlqQsVfrHzY0H5gLoRyzbEBCB3WorxGuLElIcJmpKKEeSqQL9YgoKwcdGfGKgAztBsDystBH0CbgssQJjDlMFsAoKYCH0bq655tQ9Iqi1YEzdh44IkKwkGJrjvc2VZZlms54PnPivVzfsZeaPdGul7LnCGDPzKUV0rivY89L(04k66nschCS9YgoxodGDzYM2M9o)IYnxGHK4WCBMdhoWCbgswTLnM2v(xgkKhWtyEjgV5cmKexr9MDXYccvaeKjtbYlzf2LMv3x6iKtGFlWdWqQy7LnCGJlQC5bogTkb7355fwqK5HK0JGfsT(aG0mbqAoKIuxwlymPtt6sAUadjjnT3KuhtQX4TbP5qkZfs3K00wif4g2jPPJkvY89L(04k66nschC8haKMjGBox0L1cgB278lk3CbgsIdZTzoC4CbgswthvU5CzUekKx6tfFy4kIXzWdaTYgonzEij9iyH0sooJ0Ygaq6K0PJNj1Hj1QecWsr62mslzzKUaH09LocH0TzKM2cP5cmKKuotJSjPmxiL9bEBqAAlK(S3ULyLmFFPpnUIUEJKWbhX4SBoaG0PzVZVOCZfyijom3M5WHrSaFlIsLnj((5pLlWqYA6OYnNlZLdkXtbw8HHRigNbpa0kB40Mmv8HHRigNbpa0kqqxVXH6ntKnC6kIXz3IjMvGGUEJd60(shHCztwrSO8oWF3C(p7WyEjgV5cmKexrSO8oWF3C(p7tyEjgV5cmKexr9MDXYccvGLgjbY1oQ5gLoRjhhN3b(cVPuLElIclOGiZ3x6tJROR3ijCWr9MvintaM5WHztwrSO8oWF3C(p7A6VY924uG5gLoRyzbEBCB3WorxGuLElIc7eMxIXBUadjXvuVzxSSGdqSaFlIsf1B2fll4((5adBYeBYk2EzdNlNbWU8R310FL7TrqNc8qWVf4byivS9YgoWXfvU8ahJwLG9788cZKP9Loc5YMSIyr5DG)U58F2he(D(fLR0cQl4GiZdjPhblKAvcbyOjLJN2KwQ17cGSLlaslfEJOK(7OGXKM2cP5cmKKuoEmsAHqAHehoKI8aY1dPfc8aestBH03mr2WPj9nOcM0I9vELmFFPpnUIUEJKWbhBVSHZLZayxMSPTzoCyWVf4byiv(17cGSLlGlpEJOvjy)opVWoHyb(weLkBs89ZFkxGHK10rLBox(xErEapiW3mr2WPRy7LnCUCga7YKnTRSpytFAKy8ybrMhsspcwi1YEzdhsrgWITjDAsrMqt6VJcgtAAlaH0fiKUmgMuVFdQ3gvY89L(04k66nschCS9Ygo3hyX2M5WHbRZUccPZ6Yy4Q3hWDajZdjPhblKIu9MrQLSasZH0304pQqAOxq5KwM98nStmP8G5HjDAsdbUAiUsAzC1qZvjfzMg2bOK6ystBhtQJjDj12nSfaP8aFaEEM00EBsbcBY0BdsNM0qGRgIj93rbJjLTGYjnTNVHDIj1XKUfZpjnhsthviD(jz((sFACfD9gjHdoQ3SlwwGzVZVOCZfyijom3M5WHX8smEZfyijUI6n7ILfCaIf4BruQOEZUyzb33phy4tfFy4kBbLFt75ByN1pVzp717WCBM3PaaF(86OOcZ3ucZTzENca85ZRdho9x54dcJCY8qs6rWcPivVzKE0X9mP5q6BA8hvin0lOCslZE(g2jMuEW8WKonPwLvjTmUAO5QKImtd7ausDystBhtQJjDj12nSfaP8aFaEEM00EBsbcBY0Bds)DuWyszlOCst75ByNysDmPBX8tsZH00rfsNFsMVV0NgxrxVrs4GJ6n7ch3ZM5WHl(WWv2ck)M2Z3WoRF(tiwGVfrPYMeF)8M9SxVdZTzENca85ZRJIkmFtjm3M5DkaWNpVoC40FLJpimYp9MjYgoDfX4SBXeZ6NNmpKKEeSqks1BgPCjU4KuhM0ZZNu20iBsAlcJ0CifiWabBtAONYWvsTYHN03ItVniDtsdashaPOdqinxGHKys54PnPwYc82G0JDd7eDbcP5gLofgPBZi988jDbcP9KK(XEBqQL9YgoWXfviTuahJs6aiTu4ZpB)rAW07YRyEjgV5cmKexr9MDXYco4OyPj1qsmPPTqkQ3o6hL0bM0st62mstBH0(JwiashysZfyijUsAieXJzKYgs7jjLhiymPOEZkIloj93PhjDJrsZfyijM0fiKYMmfgPC80M0swgPCSLM0p2BdsX2lB4ahxuHuEGJrj1HjTqAMai1XKUiwpUfrPsMVV0NgxrxVrs4GJ6n7wexCAMdhgXc8Tikv2K47N)eyD2vqiDwrhecQ0z17dEloVPJkijG1sFcZlX4nxGHK4kQ3SlwwqOcmaqcYpQ5gLoROowaNRsVfrHHK9Loc5YMSIyr5DG)U58F2h1CJsNvE85NT)UrVlVk9wefgsceZlX4nxGHK4kQ3SlwwWbhflDqh1a5LSc7sZQ7lDeYjWVf4byivS9YgoWXfvU8ahJwLG9788clOGof4HGFlWdWqQy7LnCGJlQC5bogTkb7355fMjth(MjYgoDf2LMv)8Na)wGhGHuX2lB4ahxu5YdCmAvc2VZZlmtM2x6iKlBYkIfL3b(7MZ)zFq435xuUslOUGdImFFPpnUIUEJKWbhXIY7a)DZ5)Sn7D(fLBUadjXH52mhomqGbc2ElIYPCbgswthvU5CzUCaxZKPaZnkDwrDSaoxLElIc7eBYk2EzdNlNbWU8R3vGadeS9weLGmzQ4ddx)n8he924Ywq5TGX1ppzEij1IxE(gj9nnZtFAsZHuCo8K(wC6TbPwLqawksNM0bggPlxGHKys5ylnPWUHD6TbPLiPdGu0biKIZ9vUWifDkWKUnJ0p2Bdslf(8Z2FKgm9UCs3Mr6XC1YifP6ybCUsMVV0NgxrxVrs4GJTx2W5YzaSl)6TzoCyGadeS9weLt5cmKSMoQCZ5YC5Ga40H5gLoROowaNRsVfrHDk3O0zLhF(z7VB07YRsVfrHDcZlX4nxGHK4kQ3SlwwWbiNmpKKEuqeEsTkHaSuK(5jDAsxmPOBFM0CbgsIjDXKYpySxefZivqApHpjLJT0Kc7g2P3gKwIKoasrhGqko3x5cJu0PatkhpTjTu4ZpB)rAW07YRK57l9PXv01BKeo4y7LnCUCga7YVEB278lk3CbgsIdZTzoCyGadeS9weLt5cmKSMoQCZ5YC5Ga40H5gLoROowaNRsVfrHD6WaZnkDwXYc8242UHDIUaPk9wef2jmVeJ3CbgsIROEZUyzbhGyb(weLkQ3SlwwW99ZbgoOtbEyUrPZkp(8Z2F3O3LxLElIcZKPaZnkDw5XNF2(7g9U8Q0BruyNW8smEZfyijUI6n7ILfeQWipOGiZ3x6tJROR3ijCWr9MDXYcm7D(fLBUadjXH52mhomMxIXBUadjXvuVzxSSGdqSaFlIsf1B2fll4((5adFkWdXZpw4nRIyIB6r5INicPttMo8ntKnC6kCuW2pWcN1pFqM9SxVdZTzENca85ZRJIkmFtjm3M5DkaWNpVoC40FLJpimYjZ3x6tJROR3ijCWr9MDHJ7zZE2R3H52mVtba(851rrfMVPeMBZ8ofa4ZNxhoC6VYXheg5Nc8WIpmCLTGYVP98nSZ6N3KP3mr2WPRigNDlMyw)8bzMdh(q88JfEZQiM4MEuU4jIq60KPdFZezdNUchfS9dSWz9ZtMhsspcwi9OJc2(bw4K05NyNjKoWKIUEt6BMiB40ysZHu017C9M0soXn9OqQ1eriDsAXhgUsMVV0NgxrxVrs4GdhfS9dSWPzoCy88JfEZQiM4MEuU4jIq680HfFy4kIXzWdaT(5pDyXhgUYpCeW1B4p2NU(5nZ7uaGpFEDuuH5BkH52mVtba(851HdN(RC8bH5MmpKKEeSqQvjeGHM0ftACXjPabpGKuhM0PjnTfsrhecz((sFACfD9gjHdo2EzdNlNbWUmztBY8qs6rWcPwLqawksxmPXfNKce8assDysNM00wifDqiKUnJuRsiadnPoM0Pjfzcnz((sFACfD9gjHdo2EzdNlNbWU8R3K5K5HK0JGfsNMuKj0KgcwHqPinhsnKK0qpLrA6VY92G0TzKkinEhiKMdPrVfs)8Kwizkas54PnPLCCg8aqjZ3x6tJRjW7YLeh(JLRNcQz9IkHfu(ZazJ3bW6TFIzoC43mr2WPRigNDfWNp9PRabD9ghQWCJCtMEZezdNUIyC2vaF(0NUce01B8biperMhssldCM0Ci16C)inyW1p0KYXtBsd98lIcPw5(kxyKImHgtQdtk)GXEruQKYvBsJtBiasHDd7etkhpTjfDacPbdU(HM0pwWKUzkO8jP5qk(C)iLJN2KU9zsFmshaPhLFCs6hlK6zLmFFPpnUMaVlxsmsch8pwUEkOM1lQe2B8d8ZTik3G9VD(rVmbH)eZC4WfFy4kIXzWdaT(5pv8HHR8dhbC9g(J9PRFEtMkgm(eSByNxGGUEJdvyKhqtMk(WWv(HJaUEd)X(01p)P3mr2WPRigNDfWNp9PRabD9gJeUl9bWUHDEbc66n2KPIpmCfX4m4bGw)8NEZezdNUYpCeW1B4p2NUce01Bms4U0ha7g25fiOR3ytMc8ntKnC6k)WraxVH)yF6kqqxVXheM7aE6ntKnC6kIXzxb85tF6kqqxVXheM7ag0jy3WoVabD9gFqyUrkeqY8qsQ15(rQLTijPi1p2FKYXtBsl54m4bGsMVV0NgxtG3LljgjHd(hlxpfuZ6fvcJUVTaixSTi5f9J9NzoC43mr2WPRigNDfWNp9PRabD9gFa3bKmpKKADUFKIu8xCMuoEAtAPgocG0Grd)X(0K(XRHygPOB5cP4pqinhsXTZlKM2cPXHJGtsrklfP5cmKSsAjylnPFSWiLJN2KAzVSHJWiLRckiDGjTSbGkDAgPhLFCs6hlKonPitOjDXKI(F2KUys5hm2lIsLmFFPpnUMaVlxsmsch8pwUEkOM1lQegp)yuY0BJl4xC2S35xuU5cmKehMBZC4WfFy4k)WraxVH)yF66N3KPd5bUGZkwIWx(HJaUEd)X(0Mmjb7355fwfBVSHJWUdO4oW3CaOsNK5HK0JGfs5YYmes9g7mH0bM0sE0KcpastBHuyhGts)yH0bq60KImHM0fofaPPTqkSdWjPFSuj1YEajPph8(EsQdtkIXzKkGpF6tt6BMiB40K6ys5oGyshaPOdqiD5SNRK57l9PX1e4D5sIrs4G)XY1tb1SErLWyVH)XRrCz(MdaFlwMHCh4lSaMNNNnZHd)MjYgoDfX4SRa(8PpDfiOR34dcZDajZdjPhblKAzVSHJWiLRckiDGjTSbGkDskhBPjTNKuVjTKJZGhaQzKoas9M0cj5istAjhNrkxMys6BXjMuVjTKJZGhaALmFFPpnUMaVlxsmsch8pwUEkOM1lQegBVSHJWUdO4oW3CaOsNM5WHpS4ddxrmodEaO1pVjtbYdeexJhRYDfX4SBXeZGiZdjPhblKgDCs6at60iDFSqkBrxdH0e4D5sIjD64zsDysrk)THa82G0sooJ0qlfFyysDmP7lDeIzKoasppFsxGqApjP5gLofgPENdPEwjZ3x6tJRjW7YLeJKWb)TX4DFPp9n640SErLWmuJBc8UCjXM5WHd8WCJsNv7FBiaVnUigNvLElIcZKjMu8HHR2)2qaEBCrmoR(5d6uGfFy4kIXzWdaT(5nz6ntKnC6kIXzxb85tF6kqqxVXhWDadImpKKgAbE)XKu4ngl2x5Kcpas)4TikK6PGIdqspcwiDAsFZezdNMuVjDambqAXzstG3LljP44KvY89L(04Ac8UCjXijCW)y56PGInZHdx8HHRigNbpa06N3KPIpmCLF4iGR3WFSpD9ZBY0BMiB40veJZUc4ZN(0vGGUEJpG7acLqjee]] )
    

end
