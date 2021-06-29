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


    spec:RegisterPack( "Shadow", 20210628, [[deLemcqivu9ifrUeHus2Kk0NiKIrjs5uIKwLIuQxrimlcv3srkXUu4xIadteYXiuwgHONrPOMgLICnfbBJsb9nfPOXrPqoNIusRtffMNIq3teTpvG)Pif0bfjYcjK8qcPAIIGUOiuSrvuYhjKsnsvukNKsHALuk9sfPaZufLQBQII2PkOFkcLgQiHJQifYsvKc1tPOPQi5QkIARks1xfHQ9QQ(RQmyuhwYIvupwLMmrxM0Mb1NPWOPKtt1QjKs8ArQMTOUnuTBP(TsdNGJlsulh45qMUW1bz7qPVdfJNsboVkY6jKsQ5tPA)i)f7p13uwH(puKjsKILiBOiTrdrAZ2SnlsB6BgNe0VPqDtVm0Vzx46300QKlMVPqDkVL8p13eTqGR(nTIqaDgjibgEybnpUlEcqoouUcF7lOGJeGC8Bc(MZqEoSX9F(BkRq)hkYejsXsKnuK2OHiTzB2MtKn)nlOWAbFtthx0)MwUuQ9F(Bkv09BAAvYfdXPa4kkiBTfQvIfPnsCIfzIePyKTKTtHrR0jE6RljEQfa0oigJL2ehfWqdIVluhiIlGsm8cUQC8nZokq)P(Mxm3)u)df7p13u7AoRYVO(Mqi9HXYZ67wOWBJ)HI9nRB4B)nrAb8241UHvGxa9BEpDZ6lkGHgO)HI9nVapuGxFZ0igBb8AoRdKwaVnETByf4fqFxOyHHj(iXNtm2c41Cwhc7MFWl4DLiItLy72jonILBmqwLCX8WSa5tO8EauyGISQ5Ss8rIrcAo)IcyObAG7T8H0cq8belgXP(nLk6cCHW3(BozKsSPwaVni(q3WkWlGsSdt8PfIymEotSLheR9czyrCuadnqexTK4uSyuaX24ggc5BtC1sIN(6s4fGtCbuI7nigOL8K4eVaIJLyGcduKfXMj(zKcI3M4aZs8cigFbkXrbm0an(X)qr(N6BQDnNv5xuFtiK(Wy5z9Dlu4TX)qX(M1n8T)MiTaEB8A3WkWlG(nVNUz9ffWqd0)qX(MxGhkWRVzuzTJbslG3gV2nSc8cOdTR5Skj(iXYngiRsUyEywG8juEpakmqrw1Cwj(iXibnNFrbm0anW9w(qAbi(aIf53uQOlWfcF7VPP1ccIfDhCH8GytTaEBq8HUHvGxaL472sp8TjowItxvbInt8ZifedjqS3eNsBI5h)dT5)uFtTR5Sk)I6BUD(07I5(nf7Bw3W3(BI7T8nNlu8nLk6cCHW3(BUD(07I5smELUIioSuIRB4Bt825tedHQ5SsSec4TbXxRQBn7TbXvljU3G4crCrmqnGYfG46g(2JF8JVPe34faVtxd0FQ)HI9N6BQDnNv5xuFZUW1VPSaPJVB)K6n93takak6Q9v)M1n8T)MYcKo(U9tQ30FpbOaOOR2x9h)df5FQVP21CwLFr9n7cx)MiOEoVR8v4AyDcfFZ6g(2FteupN3v(kCnSoHIF8p0M)t9n1UMZQ8lQVzx4630iFsW6TWVcHCCpxHV93SUHV930iFsW6TWVcHCCpxHV9p(hAt)P(MAxZzv(f13SlC9BkbAjHDG(WQiKM)M1n8T)MsGwsyhOpSkcP5F8JVPuHlOC8N6FOy)P(M1n8T)MipR9v)MAxZzv(f1p(hkY)uFtTR5Sk)I6BEbEOaV(MZqWWdSRlHxa(asGy72jEgcgEiSyuWZByiKV9as4Bw3W3(BkSHV9p(hAZ)P(MAxZzv(f13Cf(Min(M1n8T)MylGxZz9BITYq63uUXazvYfZdZcKpHY7r43092G4Jel3yGTWfCGFFXcDTgHFt3BJVj2c86cx)MYnqpiHF8p0M(t9n1UMZQ8lQV5k8nrA8nRB4B)nXwaVMZ63eBLH0VPCJbYQKlMhMfiFcL3JWVP7TbXhjwUXaBHl4a)(If6Anc)MU3geFKy5gdPIDHaEB8eYLbKoc)MU3gFtSf41fU(nRC(j3a9Ge(X)Wj8N6BQDnNv5xuFZv4BI04Bw3W3(BITaEnN1Vj2kdPFtKGMZVOagAGg4ElFiTaeFaXIKyrq8mem8a76s4fGpGe(MsfDbUq4B)nnJceedH82GytTaEBq8HUHvGxaL4ki2MfbXrbm0ar8ci2MebXomXNwiIlGsS3ep91LWla)BITaVUW1VjslG3gV2nSc8cOVluSWW)4FOn8p13u7AoRYVO(MRW3ePX3SUHV93eBb8AoRFtSvgs)M3DZYftpWUU8PaiHW3Eajq8rItJ4ZjguU8Py1ogLuIgqceB3oXGYLpfR2XOKs0qcbQW3M4jMKyXseX2TtmOC5tXQDmkPenakE5nI4dssSyjIyrq8eiEAtCAehvw7yyb1gkWBJh21LdTR5Skj2UDIVlwTRogPFc4vtCQeNkXhjonItJyq5YNIv7yusjA4nXhqSiteX2TtmsqZ5xuadnqdSRlFkasi8Tj(GKepbItLy72joQS2XWcQnuG3gpSRlhAxZzvsSD7eFxSAxDms)eWRM4uj(iXPr85edGAfEbg6ajyPaf9Ska(2NgAkd5ccQKy72jonIV7MLlMEiSyuWZByiKV9aO4L3iINysInUYbEzdiEAtSntSD7epdbdpewmk45nmeY3EajqSD7epVieXhjg2nSIhqXlVrepXKelYjqCQeN63uQOlWfcF7VPOVBwUyAItXUzINEb8AoRIt8KrQK4yjwy3mXZk8cuIRB4yRWBdIXUUeEb4dIfDiaq7iFIyiKkjowIVBhGntmglTjowIRB4yRqjg76s4fGtmgpSi277I7TbXLuIgFtSf41fU(nf2n)GxW7kr)4F408p13u7AoRYVO(MxGhkWRV5mem8a76s4fGpGe(M1n8T)MWoqNZ7k)X)qB0FQVP21CwLFr9nVapuGxFZziy4b21LWlaFaj8nRB4B)nNvasbP7TXp(hoT(N6BQDnNv5xuFZ6g(2FZSByfONOfiPbU2X3uQOlWfcF7V5KrkXND3WkeniITfsAGRDqSdtCyPaL4cOelsIxaX4lqjokGHgiXjEbexsjI4cOTOjigjuyAVnigEbeJVaL4WQAINMtan(MxGhkWRVjsqZ5xuadnqJSByfONOfiPbU2bXhKKyrsSD7eNgXNtmOC5tXQDmkPenuBGJceX2TtmOC5tXQDmkPen8M4diEAobIt9h)dflr)P(MAxZzv(f138c8qbE9nNHGHhyxxcVa8bKW3SUHV93S6RIcqLF3kN)X)qXe7p13u7AoRYVO(M1n8T)M3kNF1n8TFzhfFZSJIxx4638I5(J)HIjY)uFtTR5Sk)I6Bw3W3(BcG6xDdF7x2rX3m7O41fU(nXlV)Xp(Mca9U4Zv8N6FOy)P(MAxZzv(f138c8qbE9nbkE5nI4jsSnNOe9nRB4B)nfwmk4HzbYh8ccpGK6p(hkY)uFtTR5Sk)I6BEbEOaV(MNt8mem8azvYfd8cWhqcFZ6g(2FtKvjxmWla)h)dT5)uFtTR5Sk)I6BEbEOaV(MEJQ2JtdPc7xpi(aIfBcFZ6g(2FZcCRwFXcaAh)4FOn9N6BQDnNv5xuFZv4BI04Bw3W3(BITaEnN1Vj2kdPFtr(nXwGxx463e3B5dPf4DHIfg(h)dNWFQVzDdF7Vj2cxWb(9fl016BQDnNv5xu)4hFZa4D6AG(t9puS)uFtTR5Sk)I6Bkv0f4cHV93CYiL4Tjw0tiXPKzkLcIJLydnioH7ueh(nDVniUAjXQnqWbkXXsC2BLyibIN1iuaXy8WI4PVUeEb4FZUW1VPIlCcOv(Tazx9v)MxGhkWRV5D3SCX0dSRlFkasi8ThafV8gr8etsSyIKy72j(UBwUy6b21Lpfaje(2dGIxEJi(aIf508Bw3W3(BQ4cNaALFlq2vF1F8puK)P(MAxZzv(f13uQOlWfcF7V5uGtehlXMN6lX24PrjKymEyrCcxO5SsSzu30vjXIEcre7WelSiKpN1bXj2M482gkGyy3WkqeJXdlIXxGsSnEAucjgcPiIRiuCHG4yjgDQVeJXdlIR(eXxjXlGyrlqOGyiKsShJVzx4630B0faf1CwFPmu1be(tQy9R(nVapuGxFZziy4b21LWlaFajq8rINHGHhclgf88ggc5BpGei2UDINxeI4Jed7gwXdO4L3iINysIfzIi2UDINHGHhclgf88ggc5BpGei(iX3DZYftpWUU8PaiHW3Eau8YBeXIGyXMaXhqmSByfpGIxEJi2UDINHGHhyxxcVa8bKaXhj(UBwUy6HWIrbpVHHq(2dGIxEJiweel2ei(aIHDdR4bu8YBeX2TtCAeF3nlxm9qyXOGN3WqiF7bqXlVreFqsIflreFK47Uz5IPhyxx(uaKq4BpakE5nI4dssSyjI4uj(iXWUHv8akE5nI4dssSytRj6Bw3W3(B6n6cGIAoRVugQ6ac)jvS(v)X)qB(p13u7AoRYVO(MsfDbUq4B)nnp1xInTuni(mHq(LymEyr80xxcVa8Vzx463eVU1mqFilvJhoeYVFZlWdf4138UBwUy6b21Lpfaje(2dGIxEJi(aIflrFZ6g(2Ft86wZa9HSunE4qi)(J)H20FQVP21CwLFr9n7cx)MOfkN1i824bGMp9nVNUz9ffWqd0)qX(MxGhkWRV5mem8qyXOGN3WqiF7bKaX2Tt85elaCffdKMHFclgf88ggc5B)nRB4B)nrluoRr4TXdanF6Bkv0f4cHV9308uFjEAm08jIX4HfXPyXOaITXnmeY3MyiuzOItmELUsmccOehlXO2fuIdlL48IrrbXNTuqCuadn(X)Wj8N6BQDnNv5xuFtPIUaxi8T)MtgPelQsAOe7nYLkXlmXt)SigEbehwkXWoafedHuIxaXBtSONqIl4qbehwkXWoafedH0bXMwlii(6GlKhe7WeJDDjXkasi8Tj(UBwUyAIDeXILieXlGy8fOexyQtJVzx463e5nmu(zKlPxXcqV5sAOVf(bRG96XPV5f4Hc86BE3nlxm9a76YNcGecF7bqXlVreFqsIflrFZ6g(2FtK3Wq5NrUKEfla9MlPH(w4hSc2RhN(X)qB4FQVP21CwLFr9nLk6cCHW3(BozKsC2rbXlmXBpTaHuILfEzOehaVtxdeXBNprSdt8zdQnuG3gep91LeNqDgcgMyhrCDdhRkoXlG4tleXfqjU3G4OYAhQKyVJLypgFZ6g(2FZBLZV6g(2VSJIV5f4Hc86BMgXNtCuzTJHfuBOaVnEyxxo0UMZQKy72jwQZqWWdlO2qbEB8WUUCajqCQeFK40iEgcgEGDDj8cWhqceB3oX3DZYftpWUU8PaiHW3Eau8YBeXhqSyjI4u)MzhfVUW1VPe34faVtxd0p(hon)t9n1UMZQ8lQVzDdF7VjesFEO4OVPurxGle(2FZeQWfuoigUY556MoXWlGyiunNvI9qXrNbXtgPeVnX3DZYfttS3eVaPciE(eXbW701GyuEJX38c8qbE9nNHGHhyxxcVa8bKaX2Tt8mem8qyXOGN3WqiF7bKaX2Tt8D3SCX0dSRlFkasi8ThafV8gr8belwI(Xp(Mxj6p1)qX(t9n1UMZQ8lQVzDdF7VPWIrbpVHHq(2FtPIUaxi8T)MtgPeNIfJci2g3WqiFBIX4HfXtFDj8cWheF22SKy4fq80xxcVaCIVlUIiEHHj(UBwUyAI9M4WsjUvBqqSyjIyKE3wIiEdlfGXrkXqiL4Tj(kjgQZkcrCyPelKRtkGyhrSqbcIxyIdlL40pb8Qj(Uy1U6qCIxaXomXHLcuIX45mX9gepRex9gwkG4PVUK4edasi8TjoSCeXWUHvmioLIqXfcIJLy0P(sCyPeNluqSWIrbe7nmeY3M4fM4Wsjg2nScIJLySRljwbqcHVnXWlG4EBINgCc4vJgFZlWdf413ua4kkgind)ewmk45nmeY3M4JeNgXZqWWdSRlHxa(asGy72j(CIVlwTRogPFc4vt8rIV7MLlMEGDD5tbqcHV9aO4L3iIpijXILiITBN45fHi(iXWUHv8akE5nI4js8D3SCX0dSRlFkasi8ThafV8grCQeFK40ig2nSIhqXlVreFqsIV7MLlMEGDD5tbqcHV9aO4L3iIfbXInbIps8D3SCX0dSRlFkasi8ThafV8gr8etsSXvs80MyBIy72jg2nSIhqXlVreFaX3DZYftpewmk45nmeY3EiHav4BtSD7ed7gwXdO4L3iINiX3DZYftpWUU8PaiHW3Eau8YBeXIGyXMaX2Tt8DXQD1Xi9taVAITBN4ziy4XCExzgcfdibIt9h)df5FQVP21CwLFr9nLk6cCHW3(BozKsSOkPHsS3ixQeVWep9ZIy4fqCyPed7auqmesjEbeVnXIEcjUGdfqCyPed7auqmesheN4Eyr8HUHvq8zvkXwBwsm8ciE6N14B2fU(nrEddLFg5s6vSa0BUKg6BHFWkyVEC6BEbEOaV(MZqWWdSRlHxa(asGy72joCCL4diwSer8rItJ4Zj(Uy1U6y0UHv8GlL4u)M1n8T)MiVHHYpJCj9kwa6nxsd9TWpyfSxpo9J)H28FQVP21CwLFr9nRB4B)nHl9zavaPxn6Bkv0f4cHV93CYiL4ZQuIfTHkG0Rgr82el6jK4fkqUujEHjE6RlHxa(G4jJuIpRsjw0gQasVAjIyVjE6RlHxaoXomXNwiITkSkXQhwkGyrBWIvj2g3yDJfuHVnXlG4ZY1SK4fMyrLxeAXrdIt8YdIHxaXYnqehlXZkXqcepRWlqjUUHJTcVni(SkLyrBOci9QrehlX4LnWXDKsCyPepdbdp(MxGhkWRV55epdbdpWUUeEb4dibIpsCAeFoX3DZYftpWUU8flaODmGei2UDIpN4OYAhdSRlFXcaAhdTR5SkjovIpsCAeJTaEnN1HCd0dsG4JeJe0C(ffWqd0aBHl4a)(If6ArCsIfJy72jUUHJvFYngylCbh43xSqxlItsmsqZ5xuadnqdSfUGd87lwORfXhjgjO58lkGHgOb2cxWb(9fl01I4diwmItLy72jEgcgEGDDj8cWhqceFK40igTq5zVLddWIvFEJ1nwqf(2dTR5Skj2UDIrluE2B5a21S8TWV58IqloAODnNvjXP(J)H20FQVP21CwLFr9nRB4B)nX9wAu4k6BEpDZ6lkGHgO)HI9nVapuGxFtVrv7XjINiXtRjI4JeNgXPrm2c41Cwhvo)KBGEqceFK40i(CIV7MLlMEGDD5tbqcHV9asGy72j(CIJkRDmSGAdf4TXd76YH21CwLeNkXPsSD7epdbdpWUUeEb4dibItL4JeNgXNtCuzTJHfuBOaVnEyxxo0UMZQKy72jwQZqWWdlO2qbEB8WUUCau8YBeXhq8TqXlCCLy72j(CINHGHhyxxcVa8bKaXPs8rItJ4ZjoQS2XaPfWBJx7gwbEb0H21CwLeB3oXibnNFrbm0anW9w(qAbiEIepbIt9Bkv0f4cHV93CYiL4Z0BPrHRiIXyPnXvotSntCc3PqexaLyibXjEbeFAHiUakXEt80xxcVa8bXjMgbbuIpBqTHc82G4PVUKymEotmk8CM4zLyibIXyPnXHLs8TqbXHJRed7TJSu0GyZyfigc5TbXvq8eebXrbm0armgpSi2ulG3geFOByf4fqh)4F4e(t9n1UMZQ8lQVzDdF7VjuBT5tVEXwFtPIUaxi8T)MtgPep52AZNi(WfBr82el6juCIT2S0BdINbUcNprCSeJP8Gy4fqSWIrbe7nmeY3M4fqCjLeJekmnA8nVapuGxFZ0ionIpNyq5YNIv7yusjAajq8rIbLlFkwTJrjLOH3eFaXImreNkX2TtmOC5tXQDmkPenakE5nI4dssSytGy72jguU8Py1ogLuIgsiqf(2eprIfBceNkXhjonINHGHhclgf88ggc5BpGei2UDIV7MLlMEiSyuWZByiKV9aO4L3iIpijXILiITBN4Zjwa4kkgind)ewmk45nmeY3M4uj(iXPr85ehvw7yyb1gkWBJh21LdTR5Skj2UDIL6mem8WcQnuG3gpSRlhqceB3oXNt8mem8a76s4fGpGeio1F8p0g(N6BQDnNv5xuFZ6g(2FZ5D73c)cl9vOR2sv(nLk6cCHW3(BozKs82el6jK4zOGybGVapCKsmeYBdIN(6sItmaiHW3MyyhGcXj2HjgcPsI9g5sL4fM4PFweVnXMtrmesjUGdfqCrm21LZBoigEbeF3nlxmnXkmSFDTVNiUAjXWlGylO2qbEBqm21LedjeoUsSdtCuzTdvo(MxGhkWRV55epdbdpWUUeEb4dibIps85eF3nlxm9a76YNcGecF7bKaXhjgjO58lkGHgObU3YhslaXhqSyeFK4ZjoQS2XaPfWBJx7gwbEb0H21CwLeB3oXPr8mem8a76s4fGpGei(iXibnNFrbm0anW9w(qAbiEIelsIps85ehvw7yG0c4TXRDdRaVa6q7AoRsIpsCAelauSpJRCi2a76Y38MdIpsCAeFoXAkd5ccQCO4cNaALFlq2vFvITBN4ZjoQS2XWcQnuG3gpSRlhAxZzvsCQeB3oXAkd5ccQCO4cNaALFlq2vFvIps8D3SCX0dfx4eqR8BbYU6RoakE5nI4jMKyXSHIK4Jel1ziy4HfuBOaVnEyxxoGeiovItLy72jonINHGHhyxxcVa8bKaXhjoQS2XaPfWBJx7gwbEb0H21CwLeN6p(hon)t9n1UMZQ8lQVzDdF7V5TY5xDdF7x2rX3m7O41fU(ndG3PRb6h)4BoVB)N6FOy)P(MAxZzv(f138c8qbE9nrcAo)IcyObAG7T8H0cq8etsSn)nRB4B)nl0vBPkFZ5cf)4FOi)t9n1UMZQ8lQV5f4Hc86BIe0C(ffWqd0OqxTLQ81l2I4diwmIpsmsqZ5xuadnqdCVLpKwaIpGyXiweehvw7yG0c4TXRDdRaVa6q7AoRYVzDdF7VzHUAlv5RxS1p(X3eV8(p1)qX(t9n1UMZQ8lQV5f4Hc86BodbdpM3TFl8lS0xHUAlv5as4Bw3W3(BERC(v3W3(LDu8nZokEDHRFZ5D7F8puK)P(MAxZzv(f138c8qbE9npN4OagAmC0tixNuW3SUHV93u6ibn)Wld)(J)H28FQVP21CwLFr9nRB4B)nXUU8PaiHW3(Bkv0f4cHV93CYiL4PVUK4edasi8TjEBIV7MLlMMyHDZEBqCfeN1cfeBtjIyVrv7XjINHcI7ni2Hj(0crmgpNjEXQGBjqS3OQ94eXEt80pRbXNzLUsmccOeJSk5Ib21wMaCVLZAlvaXvlj(m9wsSOYfki2reVnX3DZYftt8ScVaL4PNygeBJn6fOelSB2BdIbkka(n8Tre7WedH82GytRsUyGZfUsCkaocN4QLelkTLkGyhr8cfJV5f4Hc86BITaEnN1HWU5h8cExjI4JeNgXEJQ2JteFqsITPerSD7elOXa21woQB4yvIpsmaQv4fyOdKvjxmW5cxFcahHp0ugYfeujXhj(CIV7MLlMEG7T8nNlumGei(iXNt8D3SCX0dKvjxmpmlq(KAfwdibItL4JeNgXEJQ2JtepXKeBJMaX2TtCuzTJbslG3gV2nSc8cOdTR5Skj(iXylGxZzDG0c4TXRDdRaVa67cflmmXPs8rIpN47Uz5IPhWU2YbKaXhjonIpN47Uz5IPh4ElFZ5cfdibITBNyKGMZVOagAGg4ElFiTaeFaXIK4u)X)qB6p13u7AoRYVO(M1n8T)MiRsUyEywG8juE)nLk6cCHW3(BEMv6kXiiGs8PfIybOGyibInt8ZifeNsMPukiEBIdlL4OagAqSdtCIdQWcgkt8zvkWvIDulAcIRB4yvIXyPnXWUHv4TbXInTyZehfWqd04BEbEOaV(MZqWWd4sFgqfq6vJgqceFK4ZjwQZqWWdmGkSGHYp4sbUoGei(iXibnNFrbm0anW9w(qAbiEIeBt)4F4e(t9n1UMZQ8lQVzDdF7V5TY5xDdF7x2rX3m7O41fU(nVs0p(hAd)t9n1UMZQ8lQVzDdF7VjU3YhslW38E6M1xuadnq)df7BEbEOaV(MrL1ogiTaEB8A3WkWlGo0UMZQK4JeJe0C(ffWqd0a3B5dPfG4digBb8AoRdCVLpKwG3fkwyyIps85el3yGSk5I5HzbYNq59i8B6EBq8rIpN47Uz5IPhWU2YbKW3uQOlWfcF7V5zZnSiofaFbECI4Z0BjXMAbiUUHVnXXsmqHbkYI4eUtHigJhweJ0c4TXRDdRaVa6p(hon)t9n1UMZQ8lQVzDdF7VPSW7k8T)M3t3S(IcyOb6FOyFZlWdf4138CIXwaVMZ6OY5NCd0ds4Bkv0f4cHV93mfafwbehlXqiL4ew4Df(2eNsMPuki2HjU6teNWDkIDeX9gedjm(X)qB0FQVP21CwLFr9nRB4B)nrwLCX8WSa5tQvy9nLk6cCHW3(BozKsSPvjxmeN4lqsCc1kSi2Hjgc5TbXMwLCXaNlCL4uaCeoXvljEwBPcigJNZeR2abhOelHaEBqCyPe3Qnii24khFZlWdf413uqJbSRTCu3WXQeFKyauRWlWqhiRsUyGZfU(eaocFOPmKliOsIpsSGgdyxB5aO4L3iINysInUYF8pCA9p13u7AoRYVO(M1n8T)M4ElFZ5cfFtPIUaxi8T)MPugtDcrmesjg3B5CUqbIyhM4BjiOsIRwsSfuBOaVnig76sIDeXqcexTKyiK3geBAvYfdCUWvItbWr4exTK4zTLkGyhrmKWGyItjP0dF7kNpjoX3cfeJ7TCoxOGyhM4tleXywOSK4zLyOUMZkXXsSHgehwkXahoiE(eXykp82G4IyJRC8nVapuGxFZ0i(UBwUy6bU3Y3CUqX4Avadfr8belgXhjonIL6mem8WcQnuG3gpSRlhqceB3oXNtCuzTJHfuBOaVnEyxxo0UMZQK4uj2UDIf0ya7AlhafV8gr8ets8TqXlCCLyrqSXvsCQeFKybngWU2YrDdhRs8rIbqTcVadDGSk5Ibox46ta4i8HMYqUGGkj(iXcAmGDTLdGIxEJi(aIVfkEHJR)4FOyj6p13u7AoRYVO(M1n8T)Myxx(M3C8nLk6cCHW3(BozKs80xxsSO2CqCfeB5gwkGybGVapormgpSi(Sb1gkWBdIN(6sIHeiowITjIJcyObsCIxaXByPaIJkRDGiEBInNA8nVapuGxFtVrv7XjINysITrtG4Jehvw7yyb1gkWBJh21LdTR5Skj(iXrL1ogiTaEB8A3WkWlGo0UMZQK4JeJe0C(ffWqd0a3B5dPfG4jMKyBiX2TtCAeNgXrL1ogwqTHc824HDD5q7AoRsIps85ehvw7yG0c4TXRDdRaVa6q7AoRsItLy72jgjO58lkGHgObU3YhslaXjjwmIt9h)dftS)uFtTR5Sk)I6Bw3W3(BkvSleWBJNqUmG0VPurxGle(2FZeUTOjigcPeNqf7cb82G4uKldiLyhM4tleX3Qj2qdI9owIN(6s4fGtS3OqlP4eVaIDyIn1c4TbXh6gwbEbuIDeXrL1oujXvljgJNZeB5bXAVqgwehfWqd04BEbEOaV(MPrmqHbkYQMZkX2TtS3OQ94eXhq80CceNkXhjonIpNySfWR5Soe2n)GxW7kreB3oXEJQ2JteFqsITrtG4uj(iXPr85ehvw7yG0c4TXRDdRaVa6q7AoRsITBN40ioQS2XaPfWBJx7gwbEb0H21CwLeFK4ZjgBb8AoRdKwaVnETByf4fqFxOyHHjovIt9h)dftK)P(MAxZzv(f13SUHV93e76Y38MJVPurxGle(2FZjJuINUOiEBIf9esSdt8PfIy52IMG4wvjXXs8TqbXjuXUqaVniof5YasfN4QLehwkqjUakXzfHioSQMyBI4OagAGiEHcItBceJXdlIVBlH8i1X38c8qbE9nrcAo)IcyObAG7T8H0cq8ejonITjIfbX3TLqEmKocTD1XtVwRIgAxZzvsCQeFKyVrv7XjINysITrtG4Jehvw7yG0c4TXRDdRaVa6q7AoRsITBN4ZjoQS2XaPfWBJx7gwbEb0H21CwL)4FOy28FQVP21CwLFr9nRB4B)nrwLCX8WSa5tQvy9nVNUz9ffWqd0)qX(MxGhkWRVzAehfWqJHLw5WAiCdINiXImreFKyKGMZVOagAGg4ElFiTaeprITjItLy72jonIf0ya7Alh1nCSkXhjga1k8cm0bYQKlg4CHRpbGJWhAkd5ccQK4u)MsfDbUq4B)nNmsj20QKlgIt8fipdItOwHfXomXHLsCuadni2rexZluqCSelDL4fq8PfIyRcRsSPvjxmW5cxjofahHtSMYqUGGkjgJhweFMElN1wQaIxaXMwLCXa7AljUUHJvh)4FOy20FQVP21CwLFr9nRB4B)nrqaG2sf8I9HxYwrOV590nRVOagAG(hk238c8qbE9nJcyOXiCC9f7t6kXtKyrobIps8mem8a76s4fGpKlM(Bkv0f4cHV93CYiLytiaqBPciowIpZs2kcr82exehfWqdIdRki2reBSEBqCSelDL4kioSuIbUHvqC4464h)dfBc)P(MAxZzv(f13SUHV93e76YxSaG2X38E6M1xuadnq)df7BEbEOaV(MylGxZzDi3a9Gei(iXrbm0yeoU(I9jDL4di2Mj(iXPr8mem8a76s4fGpKlMMy72jEgcgEGDDj8cWhafV8gr8ej(UBwUy6b21LV5nhdGIxEJiovIpsCDdhR(KBmWw4coWVVyHUweNKyKGMZVOagAGgylCbh43xSqxlIpsmsqZ5xuadnqdCVLpKwaINiXPr8eiweeNgX2qIN2ehvw7yeyCu8w4hCf6q7AoRsItL4u)MsfDbUq4B)nNmsjE6RljEQfa0oiE78jIDyInt8ZifexTK4PpfXfqjUUHJvjUAjXHLsCuadnigZ2IMGyPRelHaEBqCyPeFTQU184h)dfZg(N6BQDnNv5xuFZlWdf413uUXaBHl4a)(If6Anc)MU3geFK40ioQS2XaPfWBJx7gwbEb0H21CwLeFKyKGMZVOagAGg4ElFiTaeFaXylGxZzDG7T8H0c8UqXcdtSD7el3yGSk5I5HzbYNq59i8B6EBqCQeFK40i(CIbqTcVadDGSk5Ibox46ta4i8HMYqUGGkj2UDIRB4y1NCJb2cxWb(9fl01I4dss890nRpTvCxreN63SUHV93e3B5S2sf8J)HInn)t9n1UMZQ8lQVzDdF7VjYQKlMhMfiFsTcRVPurxGle(2FZjJuInt8ZiHeJXdlItr59mqR0vaXPavzCIH6SIqehwkXrbm0GymEot8Ss8SMxmelYejAfXZk8cuIdlL47Uz5IPj(U4kI456M(4BEbEOaV(MaOwHxGHoekVNbALUcEcOkJp0ugYfeujXhjgBb8AoRd5gOhKaXhjokGHgJWX1xSpHB8ezIi(aItJ47Uz5IPhiRsUyEywG8j1kSgsiqf(2elcInUsIt9h)dfZg9N6BQDnNv5xuFZ6g(2FtKvjxmVlOqwFtPIUaxi8T)MtgPeBAvYfdXIoOqweVnXIEcjgQZkcrCyPaL4cOexsjIyVVlU3gJV5f4Hc86Bckx(uSAhJskrdVj(aIflr)4FOytR)P(MAxZzv(f138c8qbE9nrcAo)IcyObAG7T8H0cq8beJTaEnN1bU3YhslW7cflmmXhjEgcgEilq6VWAHmSIbKW3uQOlWfcF7V5KrkXNP3sIn1cqCSeF3gbHReNWcKoXtzTqgwbIybWEreVnXPuInXmiEQeBctSel6Bd7aCIDeXHLJi2rexeB5gwkGybGVaporCyvnXavUr4TbXBtCkLytmed1zfHiwwG0joSwidRarSJiUMxOG4yjoCCL4fk(M3t3S(IcyOb6FOyFtVdfaGeINd)nd)Mo6GKI8B6DOaaKq8CCCv6vOFtX(MxRY7VPyFZ6g(2FtCVLpKwGF8puKj6p13u7AoRYVO(MsfDbUq4B)nNmsj(m9ws8zLRtehlX3Trq4kXjSaPt8uwlKHvGiwaSxeXBtS5udINkXMWelXI(2WoaNyhM4WYre7iIlITCdlfqSaWxGhNioSQMyGk3i82GyOoRieXYcKoXH1czyfiIDeX18cfehlXHJReVqX38c8qbE9nNHGHhYcK(lSwidRyajq8rIXwaVMZ6qUb6bj8n9ouaasiEo83m8B6OdskYJ3DZYftpWUU8nV5yaj8n9ouaasiEooUk9k0VPyFZRv593uSVzDdF7VjU3YhCUo9J)HIuS)uFtTR5Sk)I6Bw3W3(BI7T8nNlu8nLk6cCHW3(BozKs8z6TKyrLluqSdt8PfIy52IMG4wvjXXsmqHbkYI4eUtHgeBgRaX3cfEBqCfeBteVaIXxGsCuadnqeJXdlIn1c4TbXh6gwbEbuIJkRDOsIRws8PfI4cOe3BqmeYBdInTk5Ibox4kXPa4iCIxaXPaD6A5xIp7EN(ajO58lkGHgObU3YhslWbtdNaXgAGioSuIX92XHWjEHjEcexTK4WsjUHWNvaXlmXrbm0anioLYOvCILlX9gelaueIyCVLZ5cfed1HNjUYzIJcyObI4cOel3iujXy8WI4PpfXyS0MyiK3geJSk5Ibox4kXcahHtSdt8S2sfqSJiUWwEUMZ64BEbEOaV(MylGxZzDi3a9Gei(iXGYLpfR2XaFXQ4AhdVj(aIVfkEHJRelcIt0yceFKyKGMZVOagAGg4ElFiTaeprItJyBIyrqSijEAtCuzTJbUJuWPH21CwLelcIRB4y1NCJb2cxWb(9fl01I4PnXrL1ogcOtxl)(YEN(q7AoRsIfbXPrmsqZ5xuadnqdCVLpKwaIpyAiXtG4ujEAtCAelOXa21woQB4yvIpsmaQv4fyOdKvjxmW5cxFcahHp0ugYfeujXPsCQeFK40i(CIbqTcVadDGSk5Ibox46ta4i8HMYqUGGkj2UDIpN47Uz5IPhWU2YbKaXhjga1k8cm0bYQKlg4CHRpbGJWhAkd5ccQKy72jUUHJvFYngylCbh43xSqxlIpijX3t3S(0wXDfrCQ)4FOif5FQVP21CwLFr9nRB4B)nXw4coWVVyHUwFZlWdf413eOWafzvZzL4JehfWqJr446l2N0vIpGyBiX2TtCAehvw7yG7ifCAODnNvjXhjwUXazvYfZdZcKpHY7bqHbkYQMZkXPsSD7epdbdpGAyiq2BJNSaP3kcnGe(M3t3S(IcyOb6FOy)4FOiT5)uFtTR5Sk)I6Bw3W3(BISk5I5HzbYNq593uQOlWfcF7VPPGE9kt8DBPh(2ehlXOyfi(wOWBdInt8ZifeVnXlm80suadnqeJXsBIHDdRWBdITzIxaX4lqjgf1nDvsm(oJiUAjXqiVniofOtxl)s8z370jUAjXhMyNI4Z0rk404BEbEOaV(MafgOiRAoReFK4OagAmchxFX(KUs8beBteFK4ZjoQS2Xa3rk40q7AoRsIpsCuzTJHa601YVVS3Pp0UMZQK4JeJe0C(ffWqd0a3B5dPfG4diwK)4FOiTP)uFtTR5Sk)I6Bw3W3(BISk5I5HzbYNq5938E6M1xuadnq)df7BEbEOaV(MafgOiRAoReFK4OagAmchxFX(KUs8beBteFK4ZjoQS2Xa3rk40q7AoRsIps85eNgXrL1ogiTaEB8A3WkWlGo0UMZQK4JeJe0C(ffWqd0a3B5dPfG4digBb8AoRdCVLpKwG3fkwyyItL4JeNgXNtCuzTJHa601YVVS3Pp0UMZQKy72jonIJkRDmeqNUw(9L9o9H21CwLeFKyKGMZVOagAGg4ElFiTaepXKelsItL4u)MsfDbUq4B)nNgOQaXMj(zKcIHeiEBIleX4vFI4OagAGiUqelSiKpNvXjwTbxviigJL2ed7gwH3geBZeVaIXxGsmkQB6QKy8DgrmgpSiofOtxl)s8z370h)4FOiNWFQVP21CwLFr9nRB4B)nX9w(qAb(M3t3S(IcyOb6FOyFtVdfaGeINd)nd)Mo6GKI8B6DOaaKq8CCCv6vOFtX(MxGhkWRVjsqZ5xuadnqdCVLpKwaIpGySfWR5SoW9w(qAbExOyHH)MxRY7VPy)4FOiTH)P(MAxZzv(f13SUHV93e3B5doxN(MEhkaajeph(Bg(nD0bjf5X7Uz5IPhyxx(M3CmGe(MEhkaajephhxLEf63uSV51Q8(Bk2p(hkYP5FQVP21CwLFr9nLk6cCHW3(BozKsSzIFgjK4crCUqbXafTGGyhM4TjoSuIXxS63SUHV93ezvYfZdZcKpPwH1p(hksB0FQVP21CwLFr9nLk6cCHW3(BozKsSzIFgPG4crCUqbXafTGGyhM4TjoSuIXxSkXvlj2mXpJesSJiEBIf9e(nRB4B)nrwLCX8WSa5tO8(h)4hFtSka5B)puKjsKILiBOiNMFtmfO92a9nt8uAA8H24dfTpdIjEklLyhxybbXWlGyrZvIened0ugYbQKy0IRexqXIxHkj(AvTHIgKTNDVvITHNbXI(2yvqOsIfnbW701yuZ3XD3SCX0IgIJLyrZD3SCX0JA(kAionXSbPoiBjBTX4cliujX2iIRB4BtC2rbAq2(nfalSN1V5KMeXMwLCXqCkaUIcY2jnjITfQvIfPnsCIfzIePyKTKTtAsepfgTsN4PVUK4Pwaq7GymwAtCuadni(UqDGiUakXWl4QYbzlz7KMeXjgBGEHcvs8ScVaL47IpxbXZQH3ObXP09QcbI4E7PfRcGddLjUUHVnI4TZNgKT1n8TrdbGEx85kerYeiSyuWdZcKp4feEajvXD4KafV8gnrBorjISTUHVnAia07IpxHisMaKvjxmWlaxCho55ZqWWdKvjxmWlaFajq2w3W3gnea6DXNRqejtqbUvRVybaTdXD4KEJQ2JtdPc7xpoqSjq2w3W3gnea6DXNRqejta2c41CwfVlCnjU3YhslW7cflmS4RqsKgIJTYqAsrs2w3W3gnea6DXNRqejta2cxWb(9fl01ISLSDstI4uSHVnISTUHVnkjYZAFvY26g(2OKcB4BlUdNCgcgEGDDj8cWhqc2Tpdbdpewmk45nmeY3Eajq2w3W3gjIKjaBb8AoRI3fUMuUb6bji(kKePH4yRmKMuUXazvYfZdZcKpHY7r430924OCJb2cxWb(9fl01Ae(nDVniBRB4BJerYeGTaEnNvX7cxtw58tUb6bji(kKePH4yRmKMuUXazvYfZdZcKpHY7r430924OCJb2cxWb(9fl01Ae(nDVnok3yivSleWBJNqUmG0r43092GSDseBgfiigc5TbXMAb82G4dDdRaVakXvqSnlcIJcyObI4fqSnjcIDyIpTqexaLyVjE6RlHxaozBDdFBKisMaSfWR5SkEx4AsKwaVnETByf4fqFxOyHHfFfsI0qCSvgstIe0C(ffWqd0a3B5dPf4arkIziy4b21LWlaFajq2ojIf9DZYfttCk2nt80lGxZzvCINmsLehlXc7MjEwHxGsCDdhBfEBqm21LWlaFqSOdbaAh5tedHujXXs8D7aSzIXyPnXXsCDdhBfkXyxxcVaCIX4HfXEFxCVniUKs0GSTUHVnsejta2c41CwfVlCnPWU5h8cExjs8vijsdXXwzin5D3SCX0dSRlFkasi8Thqcht7Cq5YNIv7yusjAajy3oOC5tXQDmkPenKqGk8TNysXsKD7GYLpfR2XOKs0aO4L3OdskwIeXeM2Pfvw7yyb1gkWBJh21LdTR5SkTB)Uy1U6yK(jGxDQPEmT0aLlFkwTJrjLOH3hiYez3osqZ5xuadnqdSRlFkasi8Tpi5es1U9OYAhdlO2qbEB8WUUCODnNvPD73fR2vhJ0pb8Qt9yANdGAfEbg6ajyPaf9Ska(2NgAkd5ccQ0U90U7MLlMEiSyuWZByiKV9aO4L3OjM04kh4LnyABZ2Tpdbdpewmk45nmeY3Eajy3(8IqhHDdR4bu8YB0etkYjKAQKT1n8TrIizcGDGoN3vkUdNCgcgEGDDj8cWhqcKT1n8TrIizcMvasbP7TH4oCYziy4b21LWlaFajq2ojINmsj(S7gwHObrSTqsdCTdIDyIdlfOexaLyrs8cigFbkXrbm0ajoXlG4skrexaTfnbXiHct7TbXWlGy8fOehwvt80CcObzBDdFBKisMGSByfONOfiPbU2H4oCsKGMZVOagAGgz3WkqprlqsdCTJdsks72t7Cq5YNIv7yusjAO2ahfi72bLlFkwTJrjLOH3hmnNqQKT1n8TrIizcQ(QOau53TYzXD4KZqWWdSRlHxa(asGSTUHVnsejtWTY5xDdF7x2rH4DHRjVyUKT1n8TrIizcaq9RUHV9l7Oq8UW1K4L3KTKTtAseNsP4StCSedHuIXyPnXIA3M4fM4WsjoLqxTLQKyhrCDdhRs2w3W3gnM3TtwOR2sv(MZfke3HtIe0C(ffWqd0a3B5dPfyIjTzY26g(2OX8UTisMGcD1wQYxVylXD4KibnNFrbm0ank0vBPkF9IToqSJibnNFrbm0anW9w(qAboqmrevw7yG0c4TXRDdRaVa6q7AoRsYwY2jnjIf9eIiBNeXtgPeNIfJci2g3WqiFBIX4HfXtFDj8cWheF22SKy4fq80xxcVaCIVlUIiEHHj(UBwUyAI9M4WsjUvBqqSyjIyKE3wIiEdlfGXrkXqiL4Tj(kjgQZkcrCyPelKRtkGyhrSqbcIxyIdlL40pb8Qj(Uy1U6qCIxaXomXHLcuIX45mX9gepRex9gwkG4PVUK4edasi8TjoSCeXWUHvmioLIqXfcIJLy0P(sCyPeNluqSWIrbe7nmeY3M4fM4Wsjg2nScIJLySRljwbqcHVnXWlG4EBINgCc4vJgKT1n8TrJReLuyXOGN3WqiFBXD4KcaxrXaPz4NWIrbpVHHq(2htBgcgEGDDj8cWhqc2TF(DXQD1Xi9taV6J3DZYftpWUU8PaiHW3Eau8YB0bjflr2TpVi0ry3WkEafV8gnX7Uz5IPhyxx(uaKq4BpakE5nk1JPb7gwXdO4L3OdsE3nlxm9a76YNcGecF7bqXlVrIqSjC8UBwUy6b21Lpfaje(2dGIxEJMysJRCABt2Td7gwXdO4L3OdU7MLlMEiSyuWZByiKV9qcbQW32UDy3WkEafV8gnX7Uz5IPhyxx(uaKq4BpakE5nseInb72VlwTRogPFc4vB3(mem8yoVRmdHIbKqQKTtI4jJuIn9S2xL4Tjw0tiXXsSayVeBQcwqIwlAqeNcWEZfEf(2dY2jrCDdFB04krIizcqEw7RkEuadnEoCsauRWlWqhivWcs0A0taS3CHxHV9qtzixqqLhtlkGHgdh9kP0U9OagAmK6mem84wOWBJbqRBKkz7KiEYiLyrvsdLyVrUujEHjE6NfXWlG4Wsjg2bOGyiKs8ciEBIf9esCbhkG4Wsjg2bOGyiKoioX9WI4dDdRG4ZQuIT2SKy4fq80pRbzBDdFB04krIizcGq6Zdfx8UW1KiVHHYpJCj9kwa6nxsd9TWpyfSxpojUdNCgcgEGDDj8cWhqc2ThoUEGyj6yANFxSAxDmA3WkEWLMkz7KiEYiL4ZQuIfTHkG0Rgr82el6jK4fkqUujEHjE6RlHxa(G4jJuIpRsjw0gQasVAjIyVjE6RlHxaoXomXNwiITkSkXQhwkGyrBWIvj2g3yDJfuHVnXlG4ZY1SK4fMyrLxeAXrdIt8YdIHxaXYnqehlXZkXqcepRWlqjUUHJTcVni(SkLyrBOci9QrehlX4LnWXDKsCyPepdbdpiBRB4BJgxjsejtaCPpdOci9QrI7WjpFgcgEGDDj8cWhqcht787Uz5IPhyxx(Ifa0ogqc2TFEuzTJb21LVybaTJH21CwLPEmnSfWR5SoKBGEqchrcAo)IcyObAGTWfCGFFXcDTskMD71nCS6tUXaBHl4a)(If6ALejO58lkGHgOb2cxWb(9fl016isqZ5xuadnqdSfUGd87lwOR1bILQD7ZqWWdSRlHxa(as4yAOfkp7TCyawS6ZBSUXcQW3EODnNvPD7Ofkp7TCa7Aw(w43CErOfhn0UMZQmvY2jr8KrkXNP3sJcxreJXsBIRCMyBM4eUtHiUakXqcIt8ci(0crCbuI9M4PVUeEb4dItmnccOeF2GAdf4TbXtFDjXy8CMyu45mXZkXqceJXsBIdlL4BHcIdhxjg2BhzPObXMXkqmeYBdIRG4jicIJcyObIymEyrSPwaVni(q3WkWlGoiBRB4BJgxjsejtaU3sJcxrIFpDZ6lkGHgOKIjUdN0Bu1ECAItRj6yAPHTaEnN1rLZp5gOhKWX0o)UBwUy6b21Lpfaje(2dib72ppQS2XWcQnuG3gpSRlhAxZzvMAQ2TpdbdpWUUeEb4diHupM25rL1ogwqTHc824HDD5q7AoRs72L6mem8WcQnuG3gpSRlhafV8gDWTqXlCC1U9ZNHGHhyxxcVa8bKqQht78OYAhdKwaVnETByf4fqhAxZzvA3osqZ5xuadnqdCVLpKwGjoHujBNeXtgPep52AZNi(WfBr82el6juCIT2S0BdINbUcNprCSeJP8Gy4fqSWIrbe7nmeY3M4fqCjLeJekmnAq2w3W3gnUsKisMaO2AZNE9ITe3HtMwANdkx(uSAhJskrdiHJGYLpfR2XOKs0W7dezIs1UDq5YNIv7yusjAau8YB0bjfBc2Tdkx(uSAhJskrdjeOcF7jk2es9yAZqWWdHfJcEEddH8Thqc2TF3nlxm9qyXOGN3WqiF7bqXlVrhKuSez3(5caxrXaPz4NWIrbpVHHq(2PEmTZJkRDmSGAdf4TXd76YH21CwL2Tl1ziy4HfuBOaVnEyxxoGeSB)8ziy4b21LWlaFajKkz7KiEYiL4Tjw0tiXZqbXcaFbE4iLyiK3gep91LeNyaqcHVnXWoafItSdtmesLe7nYLkXlmXt)SiEBInNIyiKsCbhkG4IySRlN3Cqm8ci(UBwUyAIvyy)6AFprC1sIHxaXwqTHc82GySRljgsiCCLyhM4OYAhQCq2w3W3gnUsKisMG5D73c)cl9vOR2svkUdN88ziy4b21LWlaFajC887Uz5IPhyxx(uaKq4BpGeoIe0C(ffWqd0a3B5dPf4aXoEEuzTJbslG3gV2nSc8cOdTR5SkTBpTziy4b21LWlaFajCejO58lkGHgObU3YhslWef5XZJkRDmqAb8241UHvGxaDODnNv5X0eak2NXvoeBGDD5BEZXX0oxtzixqqLdfx4eqR8BbYU6RA3(5rL1ogwqTHc824HDD5q7AoRYuTBxtzixqqLdfx4eqR8BbYU6REmaENUgdfx4eqR8BbYU6RoU7MLlMEau8YB0etkMnuKhL6mem8WcQnuG3gpSRlhqcPMQD7PndbdpWUUeEb4diHJrL1ogiTaEB8A3WkWlGo0UMZQmvY26g(2OXvIerYeCRC(v3W3(LDuiEx4AYa4D6AGiBjBN0Kiw0luqCIB5zLyrVqH3gex3W3gni2udIRGyl3Wsbela8f4XjIJLyK1ccIVo4c5bXEhkaajeeF3w6HVnI4Tj(m9wsSPwGeCw56ez7KiEYiLytTaEBq8HUHvGxaLyhM4tleXy8CMylpiw7fYWI4OagAGiUAjXPyXOaITXnmeY3M4QLep91LWlaN4cOe3Bqmql5jXjEbehlXafgOilInt8ZifeVnXbML4fqm(cuIJcyObAq2w3W3gnUyUjrAb8241UHvGxavCiK(Wy5z9Dlu4TrsXe)E6M1xuadnqjftChozAylGxZzDG0c4TXRDdRaVa67cflm8XZXwaVMZ6qy38dEbVReLQD7Pj3yGSk5I5HzbYNq59aOWafzvZz9isqZ5xuadnqdCVLpKwGdelvY2jrSP1ccIfDhCH8GytTaEBq8HUHvGxaL472sp8TjowItxvbInt8ZifedjqS3eNsBIHSTUHVnACXCfrYeG0c4TXRDdRaVaQ4qi9HXYZ67wOWBJKIj(90nRVOagAGskM4oCYOYAhdKwaVnETByf4fqhAxZzvEuUXazvYfZdZcKpHY7bqHbkYQMZ6rKGMZVOagAGg4ElFiTahisY2jr825tVlMlX4v6kI4WsjUUHVnXBNprmeQMZkXsiG3geFTQU1S3gexTK4EdIleXfXa1akxaIRB4BpiBRB4BJgxmxrKmb4ElFZ5cfIVD(07I5MumYwY26g(2OHe34faVtxdusiK(8qXfVlCnPSaPJVB)K6n93takak6Q9vjBRB4BJgsCJxa8oDnqIizcGq6Zdfx8UW1KiOEoVR8v4AyDcfKT1n8TrdjUXlaENUgirKmbqi95HIlEx4AsJ8jbR3c)keYX9Cf(2KT1n8TrdjUXlaENUgirKmbqi95HIlEx4AsjqljSd0hwfH0mzlz7KMeXNz5nXPuko7ItmYAHYsIVlwfqCLZedQ2qreVWehfWqdeXvljgD1Ua(IiBRB4BJg4L3jVvo)QB4B)YokeVlCn58UT4oCYziy4X8U9BHFHL(k0vBPkhqcKT1n8Trd8YBrKmbshjO5hEz4xXD4KNhfWqJHJEc56KciBNeXtgPep91LeNyaqcHVnXBt8D3SCX0elSB2BdIRG4SwOGyBkre7nQApor8muqCVbXomXNwiIX45mXlwfClbI9gvThNi2BIN(zni(mR0vIrqaLyKvjxmWU2YeG7TCwBPciUAjXNP3sIfvUqbXoI4Tj(UBwUyAINv4fOep9eZGyBSrVaLyHDZEBqmqrbWVHVnIyhMyiK3geBAvYfdCUWvItbWr4exTKyrPTube7iIxOyq2w3W3gnWlVfrYeGDD5tbqcHVT4oCsSfWR5Soe2n)GxW7krhtZBu1EC6GK2uISBxqJbSRTCu3WXQhbqTcVadDGSk5Ibox46ta4i8HMYqUGGkpE(D3SCX0dCVLV5CHIbKWXZV7MLlMEGSk5I5HzbYNuRWAajK6X08gvThNMysB0eSBpQS2XaPfWBJx7gwbEb0H21CwLhXwaVMZ6aPfWBJx7gwbEb03fkwy4upE(D3SCX0dyxB5as4yANF3nlxm9a3B5BoxOyajy3osqZ5xuadnqdCVLpKwGdezQKTtI4ZSsxjgbbuIpTqelafedjqSzIFgPG4uYmLsbXBtCyPehfWqdIDyItCqfwWqzIpRsbUsSJArtqCDdhRsmglTjg2nScVniwSPfBM4OagAGgKT1n8Trd8YBrKmbiRsUyEywG8juElUdNCgcgEax6ZaQasVA0as445sDgcgEGbuHfmu(bxkW1bKWrKGMZVOagAGg4ElFiTat0MiBRB4BJg4L3IizcUvo)QB4B)YokeVlCn5vIiBNeXNn3WI4ua8f4XjIptVLeBQfG46g(2ehlXafgOilIt4ofIymEyrmslG3gV2nSc8cOKT1n8Trd8YBrKmb4ElFiTaIFpDZ6lkGHgOKIjUdNmQS2XaPfWBJx7gwbEb0H21CwLhrcAo)IcyObAG7T8H0cCa2c41Cwh4ElFiTaVluSWWhpxUXazvYfZdZcKpHY7r430924453DZYftpGDTLdibY2jrCkakSciowIHqkXjSW7k8TjoLmtPuqSdtC1NioH7ue7iI7nigsyq2w3W3gnWlVfrYeil8UcFBXVNUz9ffWqdusXe3HtEo2c41Cwhvo)KBGEqcKTtI4jJuInTk5IH4eFbsItOwHfXomXqiVni20QKlg4CHReNcGJWjUAjXZAlvaXy8CMy1gi4aLyjeWBdIdlL4wTbbXgx5GSTUHVnAGxElIKjazvYfZdZcKpPwHL4oCsbngWU2YrDdhREea1k8cm0bYQKlg4CHRpbGJWhAkd5ccQ8OGgdyxB5aO4L3OjM04kjBNeXPugtDcrmesjg3B5CUqbIyhM4BjiOsIRwsSfuBOaVnig76sIDeXqcexTKyiK3geBAvYfdCUWvItbWr4exTK4zTLkGyhrmKWGyItjP0dF7kNpjoX3cfeJ7TCoxOGyhM4tleXywOSK4zLyOUMZkXXsSHgehwkXahoiE(eXykp82G4IyJRCq2w3W3gnWlVfrYeG7T8nNluiUdNmT7Uz5IPh4ElFZ5cfJRvbmu0bIDmnPodbdpSGAdf4TXd76YbKGD7Nhvw7yyb1gkWBJh21LdTR5Skt1UDbngWU2YbqXlVrtm5TqXlCCvegxzQhf0ya7Alh1nCS6rauRWlWqhiRsUyGZfU(eaocFOPmKliOYJcAmGDTLdGIxEJo4wO4foUs2ojINmsjE6RljwuBoiUcITCdlfqSaWxGhNigJhweF2GAdf4TbXtFDjXqcehlX2eXrbm0ajoXlG4nSuaXrL1oqeVnXMtniBRB4BJg4L3IizcWUU8nV5qChoP3OQ940etAJMWXOYAhdlO2qbEB8WUUCODnNv5XOYAhdKwaVnETByf4fqhAxZzvEejO58lkGHgObU3YhslWetAdTBpT0IkRDmSGAdf4TXd76YH21CwLhppQS2XaPfWBJx7gwbEb0H21CwLPA3osqZ5xuadnqdCVLpKwGKILkz7KioHBlAcIHqkXjuXUqaVniof5Yasj2Hj(0cr8TAIn0GyVJL4PVUeEb4e7nk0skoXlGyhMytTaEBq8HUHvGxaLyhrCuzTdvsC1sIX45mXwEqS2lKHfXrbm0aniBRB4BJg4L3IizcKk2fc4TXtixgqQ4oCY0akmqrw1CwTB3Bu1EC6GP5es9yANJTaEnN1HWU5h8cExjYUDVrv7XPdsAJMqQht78OYAhdKwaVnETByf4fqhAxZzvA3EArL1ogiTaEB8A3WkWlGo0UMZQ845ylGxZzDG0c4TXRDdRaVa67cflmCQPs2ojINmsjE6II4Tjw0tiXomXNwiILBlAcIBvLehlX3cfeNqf7cb82G4uKldivCIRwsCyPaL4cOeNveI4WQAITjIJcyObI4fkioTjqmgpSi(UTeYJuhKT1n8Trd8YBrKmbyxx(M3CiUdNejO58lkGHgObU3YhslWetZMeXDBjKhdPJqBxD80R1QOH21CwLPE0Bu1ECAIjTrt4yuzTJbslG3gV2nSc8cOdTR5SkTB)8OYAhdKwaVnETByf4fqhAxZzvs2ojINmsj20QKlgIt8fipdItOwHfXomXHLsCuadni2rexZluqCSelDL4fq8PfIyRcRsSPvjxmW5cxjofahHtSMYqUGGkjgJhweFMElN1wQaIxaXMwLCXa7AljUUHJvhKT1n8Trd8YBrKmbiRsUyEywG8j1kSe)E6M1xuadnqjftChozArbm0yyPvoSgc3yIImrhrcAo)IcyObAG7T8H0cmrBkv72ttqJbSRTCu3WXQhbqTcVadDGSk5Ibox46ta4i8HMYqUGGktLSDsepzKsSjeaOTubehlXNzjBfHiEBIlIJcyObXHvfe7iInwVniowILUsCfehwkXa3WkioCCDq2w3W3gnWlVfrYeGGaaTLk4f7dVKTIqIFpDZ6lkGHgOKIjUdNmkGHgJWX1xSpPRtuKt44mem8a76s4fGpKlMMSDsepzKs80xxs8ulaODq825te7WeBM4NrkiUAjXtFkIlGsCDdhRsC1sIdlL4OagAqmMTfnbXsxjwcb82G4Wsj(AvDR5bzBDdFB0aV8wejta21LVybaTdXVNUz9ffWqdusXe3HtITaEnN1HCd0ds4yuadngHJRVyFsxpWMpM2mem8a76s4fGpKlM2U9ziy4b21LWlaFau8YB0eV7MLlMEGDD5BEZXaO4L3Oupw3WXQp5gdSfUGd87lwORvsKGMZVOagAGgylCbh43xSqxRJibnNFrbm0anW9w(qAbMyAtqePzdN2rL1ogbghfVf(bxHo0UMZQm1ujBRB4BJg4L3IizcW9woRTubI7WjLBmWw4coWVVyHUwJWVP7TXX0IkRDmqAb8241UHvGxaDODnNv5rKGMZVOagAGg4ElFiTahGTaEnN1bU3YhslW7cflmSD7YngiRsUyEywG8juEpc)MU3gPEmTZbqTcVadDGSk5Ibox46ta4i8HMYqUGGkTBVUHJvFYngylCbh43xSqxRdsEpDZ6tBf3vuQKTtI4jJuInt8ZiHeJXdlItr59mqR0vaXPavzCIH6SIqehwkXrbm0GymEot8Ss8SMxmelYejAfXZk8cuIdlL47Uz5IPj(U4kI456M(GSTUHVnAGxElIKjazvYfZdZcKpPwHL4oCsauRWlWqhcL3ZaTsxbpbuLXhAkd5ccQ8i2c41CwhYnqpiHJrbm0yeoU(I9jCJNit0bPD3nlxm9azvYfZdZcKpPwH1qcbQW3wegxzQKTtI4jJuInTk5IHyrhuilI3MyrpHed1zfHioSuGsCbuIlPerS33f3BJbzBDdFB0aV8wejtaYQKlM3fuilXD4KGYLpfR2XOKs0W7delrKTtI4jJuIptVLeBQfG4yj(UnccxjoHfiDINYAHmSceXcG9IiEBItPeBIzq8uj2eMyjw03g2b4e7iIdlhrSJiUi2YnSuaXcaFbECI4WQAIbQCJWBdI3M4ukXMyigQZkcrSSaPtCyTqgwbIyhrCnVqbXXsC44kXluq2w3W3gnWlVfrYeG7T8H0ci(90nRVOagAGskM4oCsKGMZVOagAGg4ElFiTahGTaEnN1bU3YhslW7cflm8Xziy4HSaP)cRfYWkgqcIFTkVtkM4EhkaajephhxLEfAsXe37qbaiH45Wjd)Mo6GKIKSDsepzKs8z6TK4ZkxNiowIVBJGWvItybsN4PSwidRarSayViI3MyZPgepvInHjwIf9THDaoXomXHLJi2rexeB5gwkGybGVaporCyvnXavUr4TbXqDwriILfiDIdRfYWkqe7iIR5fkiowIdhxjEHcY26g(2ObE5TisMaCVLp4CDsCho5mem8qwG0FH1czyfdiHJylGxZzDi3a9Gee)AvENumX9ouaasiEooUk9k0KIjU3HcaqcXZHtg(nD0bjf5X7Uz5IPhyxx(M3CmGeiBNeXtgPeFMEljwu5cfe7WeFAHiwUTOjiUvvsCSeduyGISioH7uObXMXkq8TqH3gexbX2eXlGy8fOehfWqdeXy8WIytTaEBq8HUHvGxaL4OYAhQK4QLeFAHiUakX9gedH82GytRsUyGZfUsCkaocN4fqCkqNUw(L4ZU3PpqcAo)IcyObAG7T8H0cCW0WjqSHgiIdlLyCVDCiCIxyINaXvljoSuIBi8zfq8ctCuadnqdItPmAfNy5sCVbXcafHig3B5CUqbXqD4zIRCM4OagAGiUakXYncvsmgpSiE6trmglTjgc5TbXiRsUyGZfUsSaWr4e7WepRTube7iIlSLNR5SoiBRB4BJg4L3IizcW9w(MZfke3HtITaEnN1HCd0ds4iOC5tXQDmWxSkU2XW7dUfkEHJRIirJjCejO58lkGHgObU3YhslWetZMeHiN2rL1og4osbNgAxZzvkI6gow9j3yGTWfCGFFXcDTM2rL1ogcOtxl)(YEN(q7AoRsrKgsqZ5xuadnqdCVLpKwGdMgoHuN2PjOXa21woQB4y1JaOwHxGHoqwLCXaNlC9jaCe(qtzixqqLPM6X0oha1k8cm0bYQKlg4CHRpbGJWhAkd5ccQ0U9ZV7MLlMEa7AlhqchbqTcVadDGSk5Ibox46ta4i8HMYqUGGkTBVUHJvFYngylCbh43xSqxRdsEpDZ6tBf3vuQKT1n8Trd8YBrKmbylCbh43xSqxlXVNUz9ffWqdusXe3HtcuyGISQ5SEmkGHgJWX1xSpPRhydTBpTOYAhdChPGtdTR5Skpk3yGSk5I5HzbYNq59aOWafzvZznv72NHGHhqnmei7TXtwG0BfHgqcKTtIytb96vM472sp8TjowIrXkq8TqH3geBM4NrkiEBIxy4PLOagAGigJL2ed7gwH3geBZeVaIXxGsmkQB6QKy8DgrC1sIHqEBqCkqNUw(L4ZU3PtC1sIpmXofXNPJuWPbzBDdFB0aV8wejtaYQKlMhMfiFcL3I7Wjbkmqrw1CwpgfWqJr446l2N01dSPJNhvw7yG7ifCAODnNv5XOYAhdb0PRLFFzVtFODnNv5rKGMZVOagAGg4ElFiTahisY2jr80avfi2mXpJuqmKaXBtCHigV6tehfWqdeXfIyHfH85SkoXQn4QcbXyS0Myy3Wk82GyBM4fqm(cuIrrDtxLeJVZiIX4HfXPaD6A5xIp7EN(GSTUHVnAGxElIKjazvYfZdZcKpHYBXVNUz9ffWqdusXe3HtcuyGISQ5SEmkGHgJWX1xSpPRhythppQS2Xa3rk40q7AoRYJNNwuzTJbslG3gV2nSc8cOdTR5SkpIe0C(ffWqd0a3B5dPf4aSfWR5SoW9w(qAbExOyHHt9yANhvw7yiGoDT87l7D6dTR5SkTBpTOYAhdb0PRLFFzVtFODnNv5rKGMZVOagAGg4ElFiTatmPitnvY26g(2ObE5TisMaCVLpKwaXVNUz9ffWqdusXe3HtIe0C(ffWqd0a3B5dPf4aSfWR5SoW9w(qAbExOyHHf)AvENumX9ouaasiEooUk9k0KIjU3HcaqcXZHtg(nD0bjfjzBDdFB0aV8wejtaU3YhCUoj(1Q8oPyI7DOaaKq8CCCv6vOjftCVdfaGeINdNm8B6OdskYJ3DZYftpWUU8nV5yajq2ojINmsj2mXpJesCHioxOGyGIwqqSdt82ehwkX4lwLSTUHVnAGxElIKjazvYfZdZcKpPwHfz7KiEYiLyZe)msbXfI4CHcIbkAbbXomXBtCyPeJVyvIRwsSzIFgjKyhr82el6jKSTUHVnAGxElIKjazvYfZdZcKpHYBYwY2jr8KrkXBtSONqItjZukfehlXgAqCc3Pio8B6EBqC1sIvBGGduIJL4S3kXqcepRrOaIX4HfXtFDj8cWjBRB4BJgbW701aLecPppuCX7cxtQ4cNaALFlq2vFvXD4K3DZYftpWUU8PaiHW3Eau8YB0etkMiTB)UBwUy6b21Lpfaje(2dGIxEJoqKttY2jr8uGtehlXMN6lX24PrjKymEyrCcxO5SsSzu30vjXIEcre7WelSiKpN1bXj2M482gkGyy3WkqeJXdlIXxGsSnEAucjgcPiIRiuCHG4yjgDQVeJXdlIR(eXxjXlGyrlqOGyiKsShdY26g(2Ora8oDnqIizcGq6Zdfx8UW1KEJUaOOMZ6lLHQoGWFsfRFvXD4KZqWWdSRlHxa(as44mem8qyXOGN3WqiF7bKGD7ZlcDe2nSIhqXlVrtmPitKD7ZqWWdHfJcEEddH8ThqchV7MLlMEGDD5tbqcHV9aO4L3iri2eoa2nSIhqXlVr2TpdbdpWUUeEb4diHJ3DZYftpewmk45nmeY3Eau8YBKieBcha7gwXdO4L3i72t7UBwUy6HWIrbpVHHq(2dGIxEJoiPyj64D3SCX0dSRlFkasi8ThafV8gDqsXsuQhHDdR4bu8YB0bjfBAnrKTtIyZt9LytlvdIptiKFjgJhwep91LWlaNSTUHVnAeaVtxdKisMaiK(8qXfVlCnjEDRzG(qwQgpCiKFf3HtE3nlxm9a76YNcGecF7bqXlVrhiwIiBNeXMN6lXtJHMprmgpSioflgfqSnUHHq(2edHkdvCIXR0vIrqaL4yjg1UGsCyPeNxmkki(SLcIJcyObzBDdFB0iaENUgirKmbqi95HIlEx4As0cLZAeEB8aqZNe3Htodbdpewmk45nmeY3Eajy3(5caxrXaPz4NWIrbpVHHq(2IFpDZ6lkGHgOKIr2ojINmsjwuL0qj2BKlvIxyIN(zrm8cioSuIHDakigcPeVaI3MyrpHexWHcioSuIHDakigcPdInTwqq81bxipi2Hjg76sIvaKq4Bt8D3SCX0e7iIflriIxaX4lqjUWuNgKT1n8TrJa4D6AGerYeaH0NhkU4DHRjrEddLFg5s6vSa0BUKg6BHFWkyVECsCho5D3SCX0dSRlFkasi8ThafV8gDqsXsez7KiEYiL4SJcIxyI3EAbcPell8YqjoaENUgiI3oFIyhM4ZguBOaVniE6RljoH6memmXoI46gowvCIxaXNwiIlGsCVbXrL1oujXEhlXEmiBRB4BJgbW701ajIKj4w58RUHV9l7Oq8UW1KsCJxa8oDnqI7Wjt78OYAhdlO2qbEB8WUUCODnNvPD7sDgcgEyb1gkWBJh21LdiHupM2mem8a76s4fGpGeSB)UBwUy6b21Lpfaje(2dGIxEJoqSeLkz7KioHkCbLdIHRCEUUPtm8cigcvZzLypuC0zq8KrkXBt8D3SCX0e7nXlqQaINprCa8oDnigL3yq2w3W3gncG3PRbsejtaesFEO4iXD4KZqWWdSRlHxa(asWU9ziy4HWIrbpVHHq(2dib72V7MLlMEGDD5tbqcHV9aO4L3OdelrFtKGE)hkYjyJ(Xp(Fa]] )


end
