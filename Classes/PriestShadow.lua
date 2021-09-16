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


    spec:RegisterPack( "Shadow", 20210916, [[di1LBcqivqpsqYLuHe0Mur(eeLgLa6ucKvjqvEfeXSOOClisLDjPFjqzycGJHk1YGO6zseAAcqDnjsTnujX3uHKgNGiDoujfRtaY8eeUNGAFQa)tfsKdkrWcrL4HqumrbPUOGi2OkK6JOsknsis0jrLuTskQEPkKOMPav1nHiPDQc1prLKgQejhvfsOLcrc9ukzQsuUQkeBvIOVkiQXcrQAVG8xvAWKoSslwcpwvMmkxMyZG6Zuy0uQtt1QHibVwIQzl0TH0UL63kgoQ64cuz5aphQPl66QQTdHVJkgpePCEvuRxfsG5tr2pYqCdvgKfBtb6yKhaKZDa4A4MRu5oKgaU5gYkpZlqw87R81qGS6fvGSSSx2WbYIFphNLbvgKfE(GNazzNjpoGcwWm80(xuFdAWWo6pUPp9dSWzWWo6lyqwfFpMC9gQaYITPaDmYdaY5oaCnCZvQChsda3bGRbYA)P9aGSSCuKbYY2zmPHkGSyc(bzzzVSHdPLc4cojZTe(uqleaPCZvmJuKhaKZnzozoYyVTHGdiYCKoslJJSLtAjhNrAzdaiDskhBPjnxGHKK(MFNysxGqk8aEcRsMJ0rAPasknJu2KysxGq6NNuo2stAUadjXKUaH0xCWcP5qk7S3gMrkEinT3K0(xUGjDbcP40JrsbYBqrLMjSkKv0XjgQmilMaV)ycvg0XCdvgK1(sFAilShL(jqwsVfrHbXfOe6yKdvgKL0BruyqCbY6b8ua(czv8HHRigNbpa06NNutMiT4ddx5hoc46n8h7tx)8qw7l9PHS4N0NgkHoUeHkdYs6TikmiUazn8qwyjHS2x6tdzHyb(wefileB8lqwbskBYk2EzdNlNbWU8R310FL7TbPMmrAUadjRPJk3CUmxineHjnGjnisprAGKYMSIyr5DG)U58F210FL7TbPMmrAUadjRPJk3CUmxineHjLRqAqqwiwWTxubYInj((5HsOJdyOYGSKElIcdIlqwdpKfwsiR9L(0qwiwGVfrbYcXg)cKfIf4BruQSjX3ppPNinqsztwzcI5d824YhxJVut)vU3gKAYeP5cmKSMoQCZ5YCH0qeM0aM0GGSqSGBVOcK1gJx2K47NhkHoU0qLbzj9wefgexGSgEilSKqw7l9PHSqSaFlIcKfIn(filmVeJ3CbgsIROEZUyzbKEaPiNuKqAXhgUIyCg8aqRFEilMGFaNp9PHSSYfKK(XEBqQLSaVni9y3WorxGq6MKwIiH0CbgsIjDaKgWiHuhM0ZZN0fiK6nPLCCg8aqHSqSGBVOcKfwwG3g32nSt0fi33phyyOe6yUcuzqwsVfrHbXfiRHhYcljK1(sFAilelW3IOazHyJFbY6ntKnC6kIXzxb85tF66NN0tKgiPhskyD2vqiDwxgdx)8KAYePG1zxbH0zDzmCL9bB6ttAictk3bGutMifSo7kiKoRlJHRabD9gt6bHjL7aqksiT0Kg8inqsZnkDwT)THa824IyCwv6TikmsnzI03Gq6TZA5Nb(2KgePbr6jsdK0ajfSo7kiKoRlJHREt6bKI8aqQjtKI5Ly8MlWqsCfX4SRa(8PpnPheM0stAqKAYeP5gLoR2)2qaEBCrmoRk9wefgPMmr6Bqi92zT8ZaFBsdI0tKgiPhsk43c8amKkM3wac(AVa0PpxLG7788cJutMinqsFZezdNUYpCeW1B4p2NUce01BmPHimPgpwfDrAKg8iTej1Kjsl(WWv(HJaUEd)X(01ppPMmrAXGXKEIuy3WoVabD9gtAictkYlnPbrAqqwmb)aoF6tdzHmZezdNM0sntK0sUaFlIIzKEeSWinhs5NjsAHapaH09LoIn92GueJZGhaALuK5dasNXZK(XcJ0Ci9nDcMiPCSLM0CiDFPJytHueJZGhakPC80MuVFdQ3gKUmgUczHyb3Erfil(zIx4bCFmmucD8rfQmilP3IOWG4cK1d4Pa8fYQ4ddxrmodEaO1ppK1(sFAilyhifXzyqj0XHuOYGSKElIcdIlqwpGNcWxiRIpmCfX4m4bGw)8qw7l9PHSkeawaL7TbucDmxduzqwsVfrHbXfiR9L(0qwr3WoXxKcFMbQ0jKftWpGZN(0qwhblKg8Dd7ezXKA(NzGkDsQdtAAlaH0fiKICshaPOdqinxGHKyZiDaKUmgM0finYMKI5xoT3gKcpasrhGqAAVnPh1sJRqwpGNcWxilmVeJ3CbgsIRr3WoXxKcFMbQ0jPheMuKtQjtKgiPhskyD2vqiDwxgdxfKMJtmPMmrkyD2vqiDwxgdx9M0di9OwAsdckHoM7aavgKL0BruyqCbY6b8ua(czv8HHRigNbpa06NhYAFPpnK12pbNGnEFBmcLqhZn3qLbzj9wefgexGS2x6tdz92y8UV0N(gDCczfDCE7fvGSECEqj0XCJCOYGSKElIcdIlqw7l9PHSa)(UV0N(gDCczfDCE7fvGSqxVHsOeYIHACtG3LljgQmOJ5gQmilP3IOWG4cKvVOcKfBbLJotFzYR87L)Nab)K(jqw7l9PHSylOC0z6ltELFV8)ei4N0pbkHog5qLbzj9wefgexGS6fvGSW)Uiod7UOsAFgNqw7l9PHSW)Uiod7UOsAFgNqj0XLiuzqwsVfrHbXfiRErfilJ4zE77aFxm2r94M(0qw7l9PHSmIN5TVd8DXyh1JB6tdLqhhWqLbzj9wefgexGS6fvGSyazzWoqUiemwIqw7l9PHSyazzWoqUiemwIqjuczHUEdvg0XCdvgKL0BruyqCbY6b8ua(czv8HHRfZ03b(M2YDXpPzcR(5HS2x6tdz92y8UV0N(gDCczfDCE7fvGSkMPHsOJrouzqwsVfrHbXfiRhWtb4lK1HKMlWqYQJV8X9SaGS2x6tdzXCmVeVORH)GsOJlrOYGSKElIcdIlqw7l9PHSqmo7kGpF6tdzXe8d48PpnK1rWcPLCCgPHeWNp9PjDAsFZezdNMu(zIEBq6MKgLfNKgWbGuVXB75zsl(jP9KK6WKEE(KYXJrshec4T8K6nEBpptQ3KwYJUsksDlxif)bcPy7LnCGDPzbd1BwH0mbq62msrQEZiLlXfNK6ysNM03mr2WPjTqGhGqAjdjvs56g9aes5Nj6TbPabNa)L(0ysDys)yVni1YEzdh44IkKwkGJrjDBgPCrAMai1XKo)Scz9aEkaFHSqSaFlIsLFM4fEa3hdt6jsdKuVXB75zspimPbCai1Kjs5LSc7sZQ7lDecPNif8BbEagsfBVSHdCCrLlpWXOvj4(opVWi9ePhs6BMiB40vuVz3I4IZ6NN0tKEiPVzISHtxX2lB4C5ma2LjBAx)8KgePNinqs9gVTNNjneHjnKwAsnzI0CJsNvSSaVnUTByNOlqQsVfrHr6jsrSaFlIsfllWBJB7g2j6cK77NdmmPbr6jspK03mr2WPRWU0S6NN0tKgiPhs6BMiB40vuVz3I4IZ6NNutMifZlX4nxGHK4kQ3SlwwaPhqkYjnisprAGKEiP45hl8MvrmXn9OCXteH0zv6TikmsnzI0IpmCfXe30JYfpresNx7p62JZQFEsdckHooGHkdYs6TikmiUazTV0NgYcBVSHZLZayx(1BilMGFaNp9PHSqQB5cP4pqi988jL)NK(5j1kKdOsrAjyvcLI0PjnTfsZfyijPomPHmytB4FK0JEfGlK64gzts3x6ies5ylnPWUHD6TbPCJ0vIKMlWqsCfY6b8ua(czv8HHRWRCn(lG5BJRFEspr6HKYKIpmCLdytB4F8cVcWL6NN0tKI5Ly8MlWqsCf1B2fllG0qqAadLqhxAOYGSKElIcdIlqw7l9PHSEBmE3x6tFJooHSIooV9IkqwpggkHoMRavgKL0BruyqCbYAFPpnKfQ3SlwwaK178lk3CbgsIHoMBiRhWtb4lKvUrPZkwwG3g32nSt0fivP3IOWi9ePyEjgV5cmKexr9MDXYci9asrSaFlIsf1B2fll4((5adt6jspKu2KvS9YgoxodGD5xVRP)k3Bdspr6HK(MjYgoDf2LMv)8qwmb)aoF6tdzHu6g2KwkGpapptks1BgPwYciDFPpnP5qkqGbc2M0qpLHjLJN2KILf4TXTDd7eDbcucD8rfQmilP3IOWG4cK1(sFAil2I2B6tdz9o)IYnxGHKyOJ5gY6b8ua(czDiPiwGVfrPUX4Lnj((5HSyc(bC(0NgYQuabwaKMdPFSqAOx0EtFAslbRsOuK6WKU9zsd9ugPoM0Ess)8vOe64qkuzqwsVfrHbXfiR9L(0qwy7LnCUCga7YKnTHSyc(bC(0NgY6iyHul7LnCinKhaJ0qlBAtQdt6h7TbPw2lB4ahxuH0sbCmkPBZiTqAMaiLJhJKkinEhiKY(aVninTfsBbPLKA8yviRhWtb4lKfVKvyxAwDFPJqi9ePGFlWdWqQy7LnCGJlQC5bogTkb3355fgPNiLxYkSlnRce01BmPHimPgpgucDmxduzqwsVfrHbXfiR9L(0qwOEZUfXfNqwmb)aoF6tdzvcro7zmPFSqkQ3SI4ItmPomPVLNxyKUnJu7FBiaVnifX4msDmPFEs3Mr6h7TbPw2lB4ahxuH0sbCmkPBZiTqAMai1XK(5RKsAjWyE6tVX4zZi9T4KuuVzfXfNK6WKEE(KYz(rgPfcP)ElIcP5qQHKKM2cPahojT4mPCwp92G0LuJhRcz9aEkaFHScK03mr2WPROEZUfXfN1N9cmemPhqk3KEI0ajLjfFy4Q9VneG3gxeJZQFEsnzI0djn3O0z1(3gcWBJlIXzvP3IOWinisnzIuEjRWU0SkqqxVXKgIWK(wCEthvifjKA8yKgePNiLxYkSlnRUV0riKEIuWVf4byivS9YgoWXfvU8ahJwLG7788cJ0tKYlzf2LMvbc66nM0di9T48MoQaLqhZDaGkdYs6TikmiUazTV0NgYcX4SBXetilMGFaNp9PHSocwiTKJZiLltmjDtsTDdBbqkpWhGNNjLJN2KIu(Bdb4TbPLCCgPFEsZH0aM0CbgsInJ0bq6K2cG0CJsNysNMuRYQqwpGNcWxilVXB75zsdrysdPLM0tKMBu6SA)Bdb4TXfX4SQ0BruyKEI0CJsNvSSaVnUTByNOlqQsVfrHr6jsX8smEZfyijUI6n7ILfqAictkxHutMinqsdK0CJsNv7FBiaVnUigNvLElIcJ0tKEiP5gLoRyzbEBCB3WorxGuLElIcJ0Gi1KjsX8smEZfyijUI6n7ILfqAys5M0GGsOJ5MBOYGSKElIcdIlqw7l9PHSycI5d824YhxJVazXe8d48PpnKvONgzts)yH0qliMpWBdslvCn(cPomPNNpPVTj1qss9ohsl54m4bGsQ34uwMzKoasDysTKf4TbPh7g2j6cesDmP5gLofgPBZiLJhJKA7jPspFdBsZfyijUcz9aEkaFHScKuGadeS9wefsnzIuVXB75zspG0JAPj1KjsFZezdNUIyC2nhaq6Sce01BmPHimPLiPbpsnEmsdI0tKgiPhskIf4BruQ8ZeVWd4(yysnzIuVXB75zspimPH0stAqKEI0aj9qsZnkDwXYc8242UHDIUaPk9wefgPMmrAGKMBu6SILf4TXTDd7eDbsv6Tikmspr6HKIyb(weLkwwG3g32nSt0fi33phyysdI0GGsOJ5g5qLbzj9wefgexGS2x6tdzHyC2TyIjKftWpGZN(0qwhblKwsUq60KImHMuhM0ZZNu20iBsAlcJ0Ci9T4K0qliMpWBdslvCn(IzKUnJ00wacPlqinkymPP92KgWKMlWqsmPZpjnWstkhpTj9nn77zqviRhWtb4lKfMxIXBUadjXvuVzxSSasdbPbsAatksi9nn77zL5y80BNx5zpcUk9wefgPbr6js9gVTNNjneHjnKwAsprAUrPZkwwG3g32nSt0fivP3IOWi1KjspK0CJsNvSSaVnUTByNOlqQsVfrHbLqhZDjcvgKL0BruyqCbYAFPpnKf2EzdNlNbWUmztBiR35xuU5cmKedDm3qwpGNcWxiRajnxGHKvBzJPDL)LKgcsrEai9ePyEjgV5cmKexr9MDXYcineKgWKgePMmrAGKYlzf2LMv3x6iesprk43c8amKk2Ezdh44IkxEGJrRsW9DEEHrAqqwmb)aoF6tdzDeSqQL9YgoKgYdGfqKgAztBsDystBH0CbgssQJjDlMFsAoKYCH0bq655tQ9Iqi1YEzdh44IkKwkGJrjvcUVZZlms54PnPivVzfsZeaPdGul7LnCGDPzKUV0rivOe6yUdyOYGSKElIcdIlqw7l9PHSWFaqAMaU5CrxwlymK178lk3CbgsIHoMBiRhWtb4lKvUadjRPJk3CUmxineKI8st6jsl(WWveJZGhaALnCAilMGFaNp9PHSocwi16dasZeaP5qksDzTGXKonPlP5cmKK00EtsDmPgJ3gKMdPmxiDtstBHuGByNKMoQuHsOJ5U0qLbzj9wefgexGS2x6tdzHyC2nhaq6eY6D(fLBUadjXqhZnK1d4Pa8fYcXc8Tikv2K47NN0tKMlWqYA6OYnNlZfspG0sK0tKgiPfFy4kIXzWdaTYgonPMmrAXhgUIyCg8aqRabD9gtAii9ntKnC6kIXz3IjMvGGUEJjnispr6(shHCztwrSO8oWF3C(pBspimPVZVOCLwqDbt6jsX8smEZfyijUI6n7ILfqAiinqslnPiH0ajLRqAWJ0CJsN1KJJZ7aFH3uQsVfrHrAqKgeKftWpGZN(0qwhblKwYXzKw2aasNKoD8mPomPwHCavks3MrAjlJ0fiKUV0riKUnJ00winxGHKKYzAKnjL5cPSpWBdstBH0N92TeRqj0XCZvGkdYs6TikmiUaz9aEkaFHSytwrSO8oWF3C(p7A6VY92G0tKgiP5gLoRyzbEBCB3WorxGuLElIcJ0tKI5Ly8MlWqsCf1B2fllG0difXc8TikvuVzxSSG77NdmmPMmrkBYk2EzdNlNbWU8R310FL7TbPbr6jsdK0djf8BbEagsfBVSHdCCrLlpWXOvj4(opVWi1Kjs3x6iKlBYkIfL3b(7MZ)zt6bHj9D(fLR0cQlysdcYAFPpnKfQ3ScPzcakHoM7JkuzqwsVfrHbXfiR9L(0qwy7LnCUCga7YKnTHSyc(bC(0NgY6iyHuRqoGcnPC80M0sTExaKTCbqAPWBeL0FhfmM00winxGHKKYXJrsleslK4WHuKhGJcjTqGhGqAAlK(MjYgonPVbvWKwSVYRqwpGNcWxilWVf4byiv(17cGSLlGlpEJOvj4(opVWi9ePiwGVfrPYMeF)8KEI0CbgswthvU5C5F5f5bG0dinqsFZezdNUITx2W5YzaSlt20UY(Gn9PjfjKA8yKgeucDm3HuOYGSKElIcdIlqw7l9PHSW2lB4CFGfBdzXe8d48PpnK1rWcPw2lB4qkYawSnPttkYeAs)DuWystBbiKUaH0LXWK69Bq92Ocz9aEkaFHSaRZUccPZ6Yy4Q3KEaPChaOe6yU5AGkdYs6TikmiUaz9aEkaFHSW8smEZfyijUI6n7ILfq6bKIyb(weLkQ3SlwwW99ZbgM0tKw8HHRSfu(nTNVHDw)8qwmb)aoF6tdzDeSqks1BgPwYcinhsFtJ)OcPHEbLtAz2Z3WoXKYdMhM0PjTe4QHKkPLXvdnxLuKzAyhGsQJjnTDmPoM0LuB3WwaKYd8b45zst7TjfiSjtVniDAslbUAiH0FhfmMu2ckN00E(g2jMuht6wm)K0CinDuH05NqwVZVOCZfyijg6yUHS8ofa4ZNxhgYk9x54dcJCilVtba(851rrfMVPazXnK1ZE9gYIBiR9L(0qwOEZUyzbqj0XipaqLbzj9wefgexGSyc(bC(0NgY6iyHuKQ3msp64EM0Ci9nn(JkKg6fuoPLzpFd7etkpyEysNMuRYQKwgxn0CvsrMPHDakPomPPTJj1XKUKA7g2cGuEGpapptAAVnPaHnz6TbP)okymPSfuoPP98nStmPoM0Ty(jP5qA6OcPZpHSEapfGVqwfFy4kBbLFt75ByN1ppPNifXc8Tikv2K47NhYY7uaGpFEDyiR0FLJpimYp9MjYgoDfX4SBXeZ6NhYY7uaGpFEDuuH5BkqwCdz9SxVHS4gYAFPpnKfQ3SlCCpdLqhJCUHkdYs6TikmiUazTV0NgYc1B2TiU4eYIj4hW5tFAiRJGfsrQEZiLlXfNK6WKEE(KYMgztsBryKMdPabgiyBsd9ugUsQvo8K(wC6TbPBsAat6aifDacP5cmKetkhpTj1swG3gKESByNOlqin3O0PWiDBgPNNpPlqiTNK0p2BdsTSx2WboUOcPLc4yushaPLcF(z7psd(ExEfZlX4nxGHK4kQ3SlwwWbhLknPgsIjnTfsr92r)OKoWKwAs3MrAAlK2F0cbq6atAUadjXvslHiEmJu2qApjP8abJjf1BwrCXjP)o9iPBmsAUadjXKUaHu2KPWiLJN2KwYYiLJT0K(XEBqk2Ezdh44IkKYdCmkPomPfsZeaPoM0fX6XTikviRhWtb4lKfIf4BruQSjX3ppPNifSo7kiKoROdcbv6S6nPhq6BX5nDuHuKqAaQLM0tKI5Ly8MlWqsCf1B2fllG0qqAGKgWKIesroPbpsZnkDwrDSaoxLElIcJuKq6(shHCztwrSO8oWF3C(pBsdEKMBu6SYJp)S93n6D5vP3IOWifjKgiPyEjgV5cmKexr9MDXYci9GJsKwAsdI0GhPbskVKvyxAwDFPJqi9ePGFlWdWqQy7LnCGJlQC5bogTkb3355fgPbrAqKEI0aj9qsb)wGhGHuX2lB4ahxu5YdCmAvcUVZZlmsnzI0dj9ntKnC6kSlnR(5j9ePGFlWdWqQy7LnCGJlQC5bogTkb3355fgPMmr6(shHCztwrSO8oWF3C(pBspimPVZVOCLwqDbtAqqj0Xih5qLbzj9wefgexGS2x6tdzHyr5DG)U58F2qwpGNcWxilGadeS9wefsprAUadjRPJk3CUmxi9as5kKAYePbsAUrPZkQJfW5Q0BruyKEIu2KvS9YgoxodGD5xVRabgiy7TikKgePMmrAXhgU(B4pi6TXLTGYBbJRFEiR35xuU5cmKedDm3qj0XiVeHkdYs6TikmiUazTV0NgYcBVSHZLZayx(1BilMGFaNp9PHSS4LNVrsFtZ80NM0CifNdpPVfNEBqQvihqLI0PjDGHr6YfyijMuo2stkSByNEBqAjs6aifDacP4CFLlmsrNcmPBZi9J92G0sHp)S9hPbFVlN0TzKEmxTmsrQowaNRqwpGNcWxilGadeS9wefsprAUadjRPJk3CUmxi9asdyspr6HKMBu6SI6ybCUk9wefgPNin3O0zLhF(z7VB07YRsVfrHr6jsX8smEZfyijUI6n7ILfq6bKICOe6yKhWqLbzj9wefgexGS2x6tdzHTx2W5YzaSl)6nK178lk3CbgsIHoMBiRhWtb4lKfqGbc2ElIcPNinxGHK10rLBoxMlKEaPbmPNi9qsZnkDwrDSaoxLElIcJ0tKEiPbsAUrPZkwwG3g32nSt0fivP3IOWi9ePyEjgV5cmKexr9MDXYci9asrSaFlIsf1B2fll4((5adtAqKEI0aj9qsZnkDw5XNF2(7g9U8Q0BruyKAYePbsAUrPZkp(8Z2F3O3LxLElIcJ0tKI5Ly8MlWqsCf1B2fllG0qeMuKtAqKgeKftWpGZN(0qwhLfHNuRqoGkfPFEsNM0ftk62NjnxGHKysxmP8dg7frXmsfK2t4ts5ylnPWUHD6TbPLiPdGu0biKIZ9vUWifDkWKYXtBslf(8Z2FKg89U8kucDmYlnuzqwsVfrHbXfiR9L(0qwOEZUyzbqwVZVOCZfyijg6yUHS8ofa4ZNxhgYk9x54dcJCilVtba(851rrfMVPazXnK1d4Pa8fYcZlX4nxGHK4kQ3SlwwaPhqkIf4BruQOEZUyzb33phyysprAGKEiP45hl8MvrmXn9OCXteH0zv6TikmsnzI0dj9ntKnC6kCuW2pWcN1ppPbbz9SxVHS4gkHog5CfOYGSKElIcdIlqw7l9PHSq9MDHJ7zilVtba(851HHSs)vo(GWi)uGhw8HHRSfu(nTNVHDw)8Mm9MjYgoDfX4SBXeZ6NpiilVtba(851rrfMVPazXnK1ZE9gYIBiRhWtb4lK1HKINFSWBwfXe30JYfpresNvP3IOWi1KjspK03mr2WPRWrbB)alCw)8qj0Xi)OcvgKL0BruyqCbYAFPpnKfCuW2pWcNqwENca85ZRddzL(RC8bH5gYY7uaGpFEDuuH5BkqwCdz9aEkaFHSWZpw4nRIyIB6r5INicPZQ0BruyKEI0djT4ddxrmodEaO1ppPNi9qsl(WWv(HJaUEd)X(01ppKftWpGZN(0qwhblKE0rbB)alCs68tSZeshysrxVj9ntKnCAmP5qk66DUEtAjN4MEui1AIiKojT4ddxHsOJrEifQmilP3IOWG4cKftWpGZN(0qwhblKAfYbuOjDXKgxCskqWdij1HjDAstBHu0bHazTV0NgYcBVSHZLZayxMSPnucDmY5AGkdYs6TikmiUazXe8d48PpnK1rWcPwHCavksxmPXfNKce8assDysNM00wifDqiKUnJuRqoGcnPoM0PjfzcnK1(sFAilS9YgoxodGD5xVHsOeYIhiVbTytOYGoMBOYGSKElIcdIlqwpGNcWxilGGUEJjneKwIbiaqw7l9PHS4hoc4YzaSl8asp)mbkHog5qLbzj9wefgexGSEapfGVqw45hl8Mv5)48hLRa(8PpDv6TikmsnzIu88JfEZQiM4MEuU4jIq6Sk9wefgK1(sFAil4OGTFGfoHsOJlrOYGSKElIcdIlqwpGNcWxiRdjT4ddxX2lB4apa06NhYAFPpnKf2Ezdh4bGcLqhhWqLbzj9wefgexGSEapfGVqwEJ32ZZvMa7ppj9as5U0qw7l9PHSwWBB5MdaiDcLqhxAOYGSKElIcdIlqw9Ikqwy7LnCe2Daf3b(Mdav6eYAFPpnKf2EzdhHDhqXDGV5aqLoHsOJ5kqLbzj9wefgexGSgEilSKqw7l9PHSqSaFlIcKfIn(filKdzHyb3ErfiluVzxSSG77NdmmucD8rfQmiR9L(0qwiwuEh4VBo)NnKL0BruyqCbkHsiRhddvg0XCdvgKL0BruyqCbYAFPpnKf)WraxVH)yFAilMGFaNp9PHSocwiTudhbqkxVH)yFAs54PnPLCCg8aqRKIuorgPWdG0soodEaOK(gubt6adt6BMiB40K6nPPTqAliTKuUdaPy5nndt6K2cGJJfs)yH0Pj9Xi93rbJjnTfs5J7zbqQJjLFbjPdmPPTqA5Nb(2K(gesVDAgPdGuhM00wacPC8yK0Essles3EsBbqAjhNrAib85tFAstBhtkSByNvslHmfu(K0CifFUFKM2cPXfNKYpCeaPEd)X(0KoWKM2cPWUHDsAoKIyCgPc4ZN(0Kcpas7Pj9O8zGVnUcz9aEkaFHS4bUGZkwIWx(HJaUEd)X(0KEI0ajT4ddxrmodEaO1ppPMmr6HK(gesVDwl)mW3M0tKEiPVbH0BN1wEGjoagPNi9ntKnC6kIXzxb85tF6kqqxVXKEqys5oaKAYePWUHDEbc66nM0qq6BMiB40veJZUc4ZN(0vGGUEJjnisprAGKc7g25fiOR3yspimPVzISHtxrmo7kGpF6txbc66nMuKqk3LM0tK(MjYgoDfX4SRa(8PpDfiOR3ysdrysnEmsdEKgWKAYePWUHDEbc66nM0di9ntKnC6k)WraxVH)yF6k7d20NMutMiTyWysprkSByNxGGUEJjneK(MjYgoDfX4SRa(8PpDfiOR3ysrcPCxAsnzI03Gq6TZA5Nb(2KAYePfFy4ArCgw8JZ6NN0GGsOJrouzqwsVfrHbXfilMGFaNp9PHSocwiLllZqi1BSZeshysl5rtk8ainTfsHDaoj9JfshaPttkYeAsx4uaKM2cPWoaNK(XsL0q2tBsp2nStsp6vi1EImsHhaPL8ORqw9IkqwyVH)XRrCz(MdaFlwMHCh4lSaMNNNHSEapfGVqwfFy4kIXzWdaT(5j1Kjsthvi9as5oaKEI0aj9qsFdcP3oRTByNx4viniiR9L(0qwyVH)XRrCz(MdaFlwMHCh4lSaMNNNHsOJlrOYGSKElIcdIlqw7l9PHSGx5A8xaZ3gdzXe8d48PpnK1rWcPh9kKY1(xaZ3gt60KImHM05NyNjKoWKwYXzWdaTs6rWcPh9kKY1(xaZ3MHj1Bsl54m4bGsQdt655tQ9Iqiv80waKY1cgecPC9gHBmGn9PjDaKE0UezKoWKYL4GXdkUsAiVEsk8aiLnjM0CiTqi9ZtAHapaH09LoIn92G0JEfs5A)lG5BJjnhsrxKMJ6yH00wiT4ddxHSEapfGVqwhsAXhgUIyCg8aqRFEsprAGKEiPVzISHtxrmo7MdaiDw)8KAYePhsAUrPZkIXz3CaaPZQ0BruyKgePNinqsrSaFlIsLnj((5j9ePyEjgV5cmKexrSO8oWF3C(pBsdtk3KAYeP7lDeYLnzfXIY7a)DZ5)SjnmPyEjgV5cmKexrSO8oWF3C(pBsprkMxIXBUadjXvelkVd83nN)ZM0diLBsdIutMiT4ddxrmodEaO1ppPNinqsXZpw4nRAageY1BeUXa20NUk9wefgPMmrkE(XcVzvyxIS7aFlIdgpO4Q0BruyKgeucDCadvgKL0BruyqCbYAFPpnKfQ3mJfvWqwVZVOCZfyijg6yUHSEapfGVqwEJ32ZZKgcs5AcaPNinqsdKuelW3IOu3y8YMeF)8KEI0aj9qsFZezdNUIyC2vaF(0NU(5j1KjspK0CJsNv7FBiaVnUigNvLElIcJ0GinisnzI0IpmCfX4m4bGw)8KgePNinqspK0CJsNv7FBiaVnUigNvLElIcJutMiLjfFy4Q9VneG3gxeJZQabD9gt6bK(wCEthvi1KjspK0IpmCfX4m4bGw)8KgePNinqspK0CJsNvSSaVnUTByNOlqQsVfrHrQjtKI5Ly8MlWqsCf1B2fllG0qqAPjniilMGFaNp9PHSocwifP6nZyrfmPCSLM0ngjTejn0tzysxGq6N3mshaPNNpPlqi1Bsl54m4bGwjnK04pqifP83gcWBdsl54ms54XiP40Jrsles)8KYXwAstBH03Itsthvif2BhBl4kPw5Wt6h7TbPBsAPrcP5cmKetkhpTj1swG3gKESByNOlqQqj0XLgQmilP3IOWG4cK1(sFAiRFBpXZ3EqSqwmb)aoF6tdzDeSq6rA7jEM0JhelPttkYeAZi1EImVniTa4cC8mP5qkN1tsHhaP8dhbqQ3WFSpnPdG0LXifZVCACfY6b8ua(czfiPbs6HKcwNDfesN1LXW1ppPNifSo7kiKoRlJHREt6bKI8aqAqKAYePG1zxbH0zDzmCfiOR3yspimPCxAsnzIuW6SRGq6SUmgUY(Gn9PjneKYDPjnisprAGKEiP5gLoR2)2qaEBCrmoRk9wefgPMmrktk(WWv7FBiaVnUigNv)8KAYePbs6BMiB40veJZUc4ZN(0vGGUEJj9as5oaKAYePhskIf4BruQ8ZeVWd4(yysdI0tKEiPfFy4kIXzWdaT(5jniOe6yUcuzqwsVfrHbXfiR9L(0qwfZ03b(M2YDXpPzcdYIj4hW5tFAiRJGfsNMuKj0Kw8ts5b(a80XcPFS3gKwYXzKgsaF(0NMuyhGtZi1Hj9JfgPEJDMq6atAjpAsNMuRYi9Jfsx4uaKUKIyCwXetsHhaPVzISHttQad7px63zs3Mrk8ai1(3gcWBdsrmoJ0pF6OcPomP5gLofwfY6b8ua(czDiPfFy4kIXzWdaT(5j9ePhs6BMiB40veJZUc4ZN(01ppPNifZlX4nxGHK4kQ3SlwwaPhqk3KEI0djn3O0zfllWBJB7g2j6cKQ0BruyKAYePbsAXhgUIyCg8aqRFEsprkMxIXBUadjXvuVzxSSasdbPiN0tKEiP5gLoRyzbEBCB3WorxGuLElIcJ0tKgiP8abX14XQCxrmo7wmXK0tKgiPhsQeCFNNxyvbL)mq24DaSE7NqQjtKEiP5gLoR2)2qaEBCrmoRk9wefgPbrQjtKkb3355fwvq5pdKnEhaR3(jKEI03mr2WPRck)zGSX7ay92pPce01BmPHimPCZvqoPNiLjfFy4Q9VneG3gxeJZQFEsdI0Gi1KjsdK0IpmCfX4m4bGw)8KEI0CJsNvSSaVnUTByNOlqQsVfrHrAqqj0XhvOYGSKElIcdIlqw7l9PHSEBmE3x6tFJooHSIooV9IkqwjW7YLedLqjKvc8UCjXqLbDm3qLbzj9wefgexGSyc(bC(0NgY6iyH0PjfzcnPLGvjuksZHudjjn0tzKM(RCVniDBgPcsJ3bcP5qA0BH0ppPfsMcGuoEAtAjhNbpauiRErfilbL)mq24DaSE7Naz9aEkaFHSEZezdNUIyC2vaF(0NUce01BmPHimPCJCsnzI03mr2WPRigNDfWNp9PRabD9gt6bKI8JkK1(sFAilbL)mq24DaSE7NaLqhJCOYGSKElIcdIlqwmb)aoF6tdzvg4mP5qQ15(rkx)OyOjLJN2Kg65xefsTY9vUWifzcnMuhMu(bJ9IOujLR2KgN2qaKc7g2jMuoEAtk6aes56hfdnPFSGjDZuq5tsZHu85(rkhpTjD7ZK(yKoasrk8XjPFSqQNviRErfilVXpWp3IOCdU)25h9Yee(tGSEapfGVqwfFy4kIXzWdaT(5j9ePfFy4k)WraxVH)yF66NNutMiTyWysprkSByNxGGUEJjneHjf5bGutMiT4ddx5hoc46n8h7tx)8KEI03mr2WPRigNDfWNp9PRabD9gtksiL7st6bKc7g25fiOR3ysnzI0IpmCfX4m4bGw)8KEI03mr2WPR8dhbC9g(J9PRabD9gtksiL7st6bKc7g25fiOR3ysnzI0aj9ntKnC6k)WraxVH)yF6kqqxVXKEqys5oaKEI03mr2WPRigNDfWNp9PRabD9gt6bHjL7aqAqKEIuy3WoVabD9gt6bHjLBUMaazTV0NgYYB8d8ZTik3G7VD(rVmbH)eOe64seQmilP3IOWG4cKftWpGZN(0qwwN7hPw2IKKIu)y)rkhpTjTKJZGhakKvVOcKf6(2cGCX2IKx0p2FqwpGNcWxiR3mr2WPRigNDfWNp9PRabD9gt6bKYDaGS2x6tdzHUVTaixSTi5f9J9hucDCadvgKL0BruyqCbYQxubYcp)yuY0BJl4xCgY6D(fLBUadjXqhZnK1(sFAil88JrjtVnUGFXziRhWtb4lKvXhgUYpCeW1B4p2NU(5j1KjspKuEGl4SILi8LF4iGR3WFSpnPMmrQeCFNNxyvS9Ygoc7oGI7aFZbGkDczXe8d48PpnKL15(rksXFXzs54PnPLA4ias56n8h7tt6hVgIzKIULlKI)aH0Cif3oVqAAlKghocojfPSuKMlWqYkPHST0K(XcJuoEAtQL9YgocJuUkOG0bM0YgaQ0PzKIu4Jts)yH0PjfzcnPlMu0)ZM0ftk)GXEruQqj0XLgQmilP3IOWG4cKftWpGZN(0qwhblKYLLziK6n2zcPdmPL8OjfEaKM2cPWoaNK(XcPdG0PjfzcnPlCkastBHuyhGts)yPsQL9assFo499KuhMueJZivaF(0NM03mr2WPj1XKYDaWKoasrhGq6YzpxHS6fvGSWEd)JxJ4Y8nha(wSmd5oWxybmpppdz9aEkaFHSEZezdNUIyC2vaF(0NUce01BmPheMuUdaK1(sFAilS3W)41iUmFZbGVflZqUd8fwaZZZZqj0XCfOYGSKElIcdIlqwmb)aoF6tdzDeSqQL9YgocJuUkOG0bM0YgaQ0jPCSLM0Ess9M0soodEaOMr6ai1BslKKJinPLCCgPCzIjPVfNys9M0soodEaOviRErfilS9Ygoc7oGI7aFZbGkDcz9aEkaFHSoK0IpmCfX4m4bGw)8KAYePbskpqqCnESk3veJZUftmjniiR9L(0qwy7LnCe2Daf3b(Mdav6ekHo(OcvgKL0BruyqCbYIj4hW5tFAiRJGfsJoojDGjDAKUpwiLTORHqAc8UCjXKoD8mPomPiL)2qaEBqAjhNrAOLIpmmPoM09LocXmshaPNNpPlqiTNK0CJsNcJuVZHupRqw7l9PHSEBmE3x6tFJooHSEapfGVqwbs6HKMBu6SA)Bdb4TXfX4SQ0BruyKAYePmP4ddxT)THa824IyCw9ZtAqKEI0ajT4ddxrmodEaO1ppPMmr6BMiB40veJZUc4ZN(0vGGUEJj9as5oaKgeKv0X5TxubYIHACtG3LljgkHooKcvgKL0BruyqCbYAFPpnK1hlxpfumKftWpGZN(0qwHwG3FmjfEJXI9voPWdG0pElIcPEkO4aI0JGfsNM03mr2WPj1BshataKwCM0e4D5sskoozfY6b8ua(czv8HHRigNbpa06NNutMiT4ddx5hoc46n8h7tx)8KAYePVzISHtxrmo7kGpF6txbc66nM0diL7aaLqjKvXmnuzqhZnuzqwsVfrHbXfiRhWtb4lKfMxIXBUadjXvuVzxSSasdryslriR9L(0qwl(jnty3I4ItOe6yKdvgKL0BruyqCbYAFPpnK1IFsZe2ThelKftWpGZN(0qwC1oEM0pwiTeWpPzcJ0JhelPCSLM0EssZnkDkms9ohsTKf4TbPh7g2j6cesNMuKJesZfyijUcz9aEkaFHSW8smEZfyijUU4N0mHD7bXs6bKYnPNifZlX4nxGHK4kQ3SlwwaPhqk3KEI0djn3O0zfllWBJB7g2j6cKQ0Bruyqjucz948Gkd6yUHkdYs6TikmiUaz9XYLJThL7BXP3gqhZnK1(sFAilSSaVnUTByNOlqGSENFr5MlWqsm0XCdz9aEkaFHScKuelW3IOuXYc8242UHDIUa5((5adt6jspKuelW3IOu5NjEHhW9XWKgePMmrAGKYMSITx2W5YzaSl)6DfiWabBVfrH0tKI5Ly8MlWqsCf1B2fllG0diLBsdcYIj4hW5tFAiRJGfsTKf4TbPh7g2j6cesDysppFs54XiP2EsQ0Z3WM0CbgsIjDBgPLA4ias56n8h7tt62msl54m4bGs6ces7jjfil7SzKoasZHuGadeSnPwHCavksNM0KZq6aifDacP5cmKexHsOJrouzqwsVfrHbXfiRpwUCS9OCFlo92a6yUHS2x6tdzHLf4TXTDd7eDbcK178lk3CbgsIHoMBiRhWtb4lKvUrPZkwwG3g32nSt0fivP3IOWi9ePSjRy7LnCUCga7YVExbcmqW2Brui9ePyEjgV5cmKexr9MDXYci9asroKftWpGZN(0qww2dijfzCW77jPwYc82G0JDd7eDbcPVPzE6ttAoKwUi8KAfYbuPi9ZtQ3KwctibkHoUeHkdYs6TikmiUaznD889X5bzXnK1(sFAiluVz3I4ItilMGFaNp9PHSMoE((48ifDlxWKM2cP7l9PjD64zs)4TikKY(aVni9zVDlrVniDBgP9KKUysxsbIXpUas3x6txHsOekHSqiaSpn0XipaiN7aeslrUHS4SG2BdmKvixcifpMRFmxBarkPLzlK6O8dijfEaKIS8a5nOfBISKcKG77aHrkEqfs3FoOBkmsF2BBi4kzEW3BHuKhqKImtJqaPWifzXZpw4nRI0JSKMdPilE(XcVzvK(Q0BruyilPbYnslOkzEW3BHuKhqKImtJqaPWifzXZpw4nRI0JSKMdPilE(XcVzvK(Q0BruyilPBsAiHRg8jnqUrAbvjZjZd5saP4XC9J5AdisjTmBHuhLFajPWdGuKfD9gzjfib33bcJu8GkKU)Cq3uyK(S32qWvY8GV3cPLyarkYmncbKcJuKfp)yH3SkspYsAoKIS45hl8Mvr6RsVfrHHSKgi3iTGQK5bFVfsrEPdisrMPriGuyKIS45hl8Mvr6rwsZHuKfp)yH3SksFv6TikmKL0a5gPfuLmp47TqkY5kbePiZ0ieqkmsrw88JfEZQi9ilP5qkYINFSWBwfPVk9wefgYsAGCJ0cQsMh89wif5h1aIuKzAecifgPilE(XcVzvKEKL0CifzXZpw4nRI0xLElIcdzjnqUrAbvjZjZd5saP4XC9J5AdisjTmBHuhLFajPWdGuK9XWilPaj4(oqyKIhuH09Nd6McJ0N92gcUsMh89wiLReqKImtJqaPWifztG3LlzDlE13mr2WPrwsZHuK9ntKnC66w8qwsdKBKwqvYCYCUok)asHrAiL09L(0KgDCIRK5qwyE5bDmYlDifYIhmWEuGScvOi1YEzdhslfWfCsMhQqrQLWNcAHaiLBUIzKI8aGCUjZjZdvOifzS32qWbezEOcfPiDKwghzlN0sooJ0Ygaq6Kuo2stAUadjj9n)oXKUaHu4b8ewLmpuHIuKoslfqsPzKYMet6ces)8KYXwAsZfyijM0fiK(IdwinhszN92WmsXdPP9MK2)YfmPlqifNEmskqEdkQ0mHvjZjZdvOinKG0K3pfgPfc8aesFdAXMKwigEJRKwcVNWNys7Pr6Sxak8ps6(sFAmPthpxjZ3x6tJR8a5nOfBIKWbJF4iGlNbWUWdi98ZeZC4WabD9ghIsmabGmFFPpnUYdK3GwSjschm4OGTFGfonZHdJNFSWBwL)JZFuUc4ZN(0MmHNFSWBwfXe30JYfpresNK57l9PXvEG8g0Inrs4GHTx2WbEaOM5WHpS4ddxX2lB4apa06NNmFFPpnUYdK3GwSjschSf82wU5aasNM5WH9gVTNNRmb2FEEa3LMmFFPpnUYdK3GwSjschSpwUEkOM1lQegBVSHJWUdO4oW3CaOsNK57l9PXvEG8g0Inrs4GHyb(wefZ6fvcJ6n7ILfCF)CGHnB4dJL0meB8lHroz((sFACLhiVbTytKeoyiwuEh4VBo)NnzozEOcfPLAsFAmz((sFACyShL(jK57l9PXH5N0N2mhoCXhgUIyCg8aqRFEtMk(WWv(HJaUEd)X(01ppz((sFAmschmelW3IOywVOsy2K47N3SHpmwsZqSXVeoq2KvS9YgoxodGD5xVRP)k3BdtMYfyiznDu5MZL5sichWbDkq2KvelkVd83nN)ZUM(RCVnmzkxGHK10rLBoxMlHimxjiY89L(0yKeoyiwGVfrXSErLWBmEztIVFEZg(WyjndXg)syelW3IOuztIVF(tbYMSYeeZh4TXLpUgFPM(RCVnmzkxGHK10rLBoxMlHiCahezEOi1kxqs6h7TbPwYc82G0JDd7eDbcPBsAjIesZfyijM0bqAaJesDysppFsxGqQ3KwYXzWdaLmFFPpngjHdgIf4BrumRxujmwwG3g32nSt0fi33phyyZg(WyjndXg)symVeJ3CbgsIROEZUyzbhGCKu8HHRigNbpa06NNmpuKImZezdNM0sntK0sUaFlIIzKEeSWinhs5NjsAHapaH09LoIn92GueJZGhaALuK5dasNXZK(XcJ0Ci9nDcMiPCSLM0CiDFPJytHueJZGhakPC80MuVFdQ3gKUmgUsMVV0NgJKWbdXc8TikM1lQeMFM4fEa3hdB2WhglPzi24xc)MjYgoDfX4SRa(8PpD9ZFkWdbRZUccPZ6Yy46N3KjW6SRGq6SUmgUY(Gn9PdryUdGjtG1zxbH0zDzmCfiOR34dcZDaqsPdEbMBu6SA)Bdb4TXfX4SQ0BruyMm9gesVDwl)mW3oOGofyGG1zxbH0zDzmC17dqEamzcZlX4nxGHK4kIXzxb85tF6dcx6Gmzk3O0z1(3gcWBJlIXzvP3IOWmz6niKE7Sw(zGVDqNc8qWVf4byivmVTae81EbOtFUkb3355fMjtb(MjYgoDLF4iGR3WFSpDfiOR34qe24XQOlsl4vIMmv8HHR8dhbC9g(J9PRFEtMkgm(eSByNxGGUEJdryKx6GcImpuHIuKIsW9DGGjf(dsBbqkqq4cNaIuslZr92GuKj0ysHhaPhlpWehaJ0IflmsNMuy3WojnkTrAt62msthvifiOR3EBygP8GPylINjnNHuetCtpkKcpas9gPZyrLkzEOcfP7l9PXijCWqSaFlIIz9IkH5NjEHhW9XWMn8HXsAgIn(LWVzISHtxrmo7kGpF6tx)8Nc8qW6SRGq6SUmgU(5nzcSo7kiKoRlJHRSpytF6qeM7ayYeyD2vqiDwxgdxbc66n(GWChaKu6GxG5gLoR2)2qaEBCrmoRk9wefMjtVbH0BN1Ypd8TdkOtbgiyD2vqiDwxgdx9(aKhatMW8smEZfyijUIyC2vaF(0N(GWLoitMYnkDwT)THa824IyCwv6TikmtMEdcP3oRLFg4Bh0Pape8BbEagsfZBlabFTxa60NRsW9DEEHDkWdFdcP3oRT8atCamtMcmqy3WoVabD9gJK0rLGoiCjwIb4u6OsicJ8aeatMce2nSZlqqxVXijDujOqeg5LoaNce2nSZlqqxVXijDujOdcJ8aeGGcYKP3mr2WPR8dhbC9g(J9PRabD9ghIWgpwfDrAbVs0KPIpmCLF4iGR3WFSpD9ZBYeSByNxGGUEJdryKx6GiZ3x6tJrs4Gb7aPiodZmhoCXhgUIyCg8aqRFEY89L(0yKeoyfcalGY92WmhoCXhgUIyCg8aqRFEY8qr6rWcPbF3WorwmPM)zgOsNK6WKM2cqiDbcPiN0bqk6aesZfyij2mshaPlJHjDbsJSjPy(Lt7TbPWdGu0biKM2Bt6rT04kz((sFAmschSOByN4lsHpZav60mhomMxIXBUadjX1OByN4lsHpZav68GWi3KPapeSo7kiKoRlJHRcsZXj2KjW6SRGq6SUmgU69bh1shez((sFAmschSTFcobB8(2y0mhoCXhgUIyCg8aqRFEY89L(0yKeoyVngV7l9PVrhNM1lQe(X5rMVV0NgJKWbd877(sF6B0XPz9IkHrxVjZjZdvOiTekvWN0Ci9Jfs5ylnPCzMM0bM00wiTeWpPzcJuht6(shHqMVV0NgxlMPdV4N0mHDlIlonZHdJ5Ly8MlWqsCf1B2fllieHlrY8qrkxTJNj9Jfslb8tAMWi94bXskhBPjTNK0CJsNcJuVZHulzbEBq6XUHDIUaH0Pjf5iH0CbgsIRK57l9PX1IzAKeoyl(jnty3EqSM5WHX8smEZfyijUU4N0mHD7bXEa3NW8smEZfyijUI6n7ILfCa3Nom3O0zfllWBJB7g2j6cKQ0BruyK5K5HkuKImHgtMhkspcwiTudhbqkxVH)yFAs54PnPLCCg8aqRKIuorgPWdG0soodEaOK(gubt6adt6BMiB40K6nPPTqAliTKuUdaPy5nndt6K2cGJJfs)yH0Pj9Xi93rbJjnTfs5J7zbqQJjLFbjPdmPPTqA5Nb(2K(gesVDAgPdGuhM00wacPC8yK0Essles3EsBbqAjhNrAib85tFAstBhtkSByNvslHmfu(K0CifFUFKM2cPXfNKYpCeaPEd)X(0KoWKM2cPWUHDsAoKIyCgPc4ZN(0Kcpas7Pj9O8zGVnUsMVV0NgxFmCy(HJaUEd)X(0M5WH5bUGZkwIWx(HJaUEd)X(0NcS4ddxrmodEaO1pVjth(gesVDwl)mW3(0HVbH0BN1wEGjoa2P3mr2WPRigNDfWNp9PRabD9gFqyUdGjtWUHDEbc66noeVzISHtxrmo7kGpF6txbc66noOtbc7g25fiOR34dc)MjYgoDfX4SRa(8PpDfiOR3yKWDPp9MjYgoDfX4SRa(8PpDfiOR34qe24XcEbSjtWUHDEbc66n(G3mr2WPR8dhbC9g(J9PRSpytFAtMkgm(eSByNxGGUEJdXBMiB40veJZUc4ZN(0vGGUEJrc3L2KP3Gq6TZA5Nb(2Mmv8HHRfXzyXpoRF(GiZdfPhblKA5rPFcPttkYeAsZHuEW8i1s4T)hfGSyslfyEXfDtF6kzEOiDFPpnU(yyKeoyypk9tmlxGHKxhom43c8amKkw4T)hfGV8G5fx0n9PRsW9DEEHDkWCbgswD8DzmtMYfyizLjfFy46BXP3gvGSVmiY8qr6rWcPCzzgcPEJDMq6atAjpAsHhaPPTqkSdWjPFSq6aiDAsrMqt6cNcG00wif2b4K0pwQKgYEAt6XUHDs6rVcP2tKrk8aiTKhDLmFFPpnU(yyKeoyFSC9uqnRxujm2B4F8AexMV5aW3ILzi3b(clG555zZC4WfFy4kIXzWdaT(5nzkDu5aUdWPap8niKE7S2UHDEHxjiY8qr6rWcPh9kKY1(xaZ3gt60KImHM05NyNjKoWKwYXzWdaTs6rWcPh9kKY1(xaZ3MHj1Bsl54m4bGsQdt655tQ9Iqiv80waKY1cgecPC9gHBmGn9PjDaKE0UezKoWKYL4GXdkUsAiVEsk8aiLnjM0CiTqi9ZtAHapaH09LoIn92G0JEfs5A)lG5BJjnhsrxKMJ6yH00wiT4ddxjZ3x6tJRpggjHdg8kxJ)cy(2yZC4Whw8HHRigNbpa06N)uGh(MjYgoDfX4SBoaG0z9ZBY0H5gLoRigNDZbaKoRsVfrHf0ParSaFlIsLnj((5pH5Ly8MlWqsCfXIY7a)DZ5)SdZTjt7lDeYLnzfXIY7a)DZ5)SdJ5Ly8MlWqsCfXIY7a)DZ5)SpH5Ly8MlWqsCfXIY7a)DZ5)SpG7GmzQ4ddxrmodEaO1p)PaXZpw4nRAageY1BeUXa20NUk9wefMjt45hl8MvHDjYUd8Tioy8GIRsVfrHfezEOi9iyHuKQ3mJfvWKYXwAs3yK0sK0qpLHjDbcPFEZiDaKEE(KUaHuVjTKJZGhaAL0qsJ)aHuKYFBiaVniTKJZiLJhJKItpgjTqi9ZtkhBPjnTfsFlojnDuHuyVDSTGRKALdpPFS3gKUjPLgjKMlWqsmPC80MulzbEBq6XUHDIUaPsMVV0NgxFmmschmuVzglQGn7D(fLBUadjXH52mhoS34T98Ci4AcWPadeXc8Tik1ngVSjX3p)Pap8ntKnC6kIXzxb85tF66N3KPdZnkDwT)THa824IyCwv6TikSGcYKPIpmCfX4m4bGw)8bDkWdZnkDwT)THa824IyCwv6TikmtMysXhgUA)Bdb4TXfX4SkqqxVXh8wCEthvmz6WIpmCfX4m4bGw)8bDkWdZnkDwXYc8242UHDIUaPk9wefMjtyEjgV5cmKexr9MDXYccrPdImpuKEeSq6rA7jEM0JhelPttkYeAZi1EImVniTa4cC8mP5qkN1tsHhaP8dhbqQ3WFSpnPdG0LXifZVCACLmFFPpnU(yyKeoy)2EINV9GynZHdhyGhcwNDfesN1LXW1p)jW6SRGq6SUmgU69bipabzYeyD2vqiDwxgdxbc66n(GWCxAtMaRZUccPZ6Yy4k7d20NoeCx6Gof4H5gLoR2)2qaEBCrmoRk9wefMjtmP4ddxT)THa824IyCw9ZBYuGVzISHtxrmo7kGpF6txbc66n(aUdGjthIyb(weLk)mXl8aUpgoOthw8HHRigNbpa06NpiY8qr6rWcPttkYeAsl(jP8aFaE6yH0p2Bdsl54msdjGpF6ttkSdWPzK6WK(XcJuVXotiDGjTKhnPttQvzK(XcPlCkasxsrmoRyIjPWdG03mr2WPjvGH9Nl97mPBZifEaKA)Bdb4TbPigNr6NpDuHuhM0CJsNcRsMVV0NgxFmmschSIz67aFtB5U4N0mHzMdh(WIpmCfX4m4bGw)8No8ntKnC6kIXzxb85tF66N)eMxIXBUadjXvuVzxSSGd4(0H5gLoRyzbEBCB3WorxGuLElIcZKPal(WWveJZGhaA9ZFcZlX4nxGHK4kQ3Slwwqiq(PdZnkDwXYc8242UHDIUaPk9wef2Pa5bcIRXJv5UIyC2TyI5PapucUVZZlSQGYFgiB8oawV9tmz6WCJsNv7FBiaVnUigNvLElIclitMKG7788cRkO8NbYgVdG1B)KtjW7YLSkO8NbYgVdG1B)K6BMiB40vGGUEJdryU5ki)etk(WWv7FBiaVnUigNv)8bfKjtbw8HHRigNbpa06N)uUrPZkwwG3g32nSt0fivP3IOWcImFFPpnU(yyKeoyVngV7l9PVrhNM1lQeobExUKyYCY8qfksrMfNKgY2EuifzwC6TbP7l9PXvsTKK0nj12nSfaP8aFaEEM0CifBpGK0NdEFpj17uaGpFs6BAMN(0ysNMuKQ3msTKfeSJoUNjZdfPhblKAjlWBdsp2nSt0fiK6WKEE(KYXJrsT9KuPNVHnP5cmKet62msl1WraKY1B4p2NM0TzKwYXzWdaL0fiK2tskqw2zZiDaKMdPabgiyBsTc5aQuKonPjNH0bqk6aesZfyijUsMVV0NgxFCEHXYc8242UHDIUaXSpwUCS9OCFlo92im3M9o)IYnxGHK4WCBMdhoqelW3IOuXYc8242UHDIUa5((5adF6qelW3IOu5NjEHhW9XWbzYuGSjRy7LnCUCga7YVExbcmqW2BruoH5Ly8MlWqsCf1B2fll4aUdImpuKAzpGKuKXbVVNKAjlWBdsp2nSt0fiK(MM5PpnP5qA5IWtQvihqLI0ppPEtAjmHeY89L(046JZdjHdgwwG3g32nSt0fiM9XYLJThL7BXP3gH52S35xuU5cmKehMBZC4W5gLoRyzbEBCB3WorxGuLElIc7eBYk2EzdNlNbWU8R3vGadeS9weLtyEjgV5cmKexr9MDXYcoa5K5HI0PJNVpopsr3YfmPPTq6(sFAsNoEM0pElIcPSpWBdsF2B3s0Bds3MrApjPlM0LuGy8JlG09L(0vY89L(046JZdjHdgQ3SBrCXPzthpFFCEH5MmNmFFPpnUYqnUjW7YLeh(JLRNcQz9IkHzlOC0z6ltELFV8)ei4N0pHmFFPpnUYqnUjW7YLeJKWb7JLRNcQz9IkHX)Uiod7UOsAFgNK57l9PXvgQXnbExUKyKeoyFSC9uqnRxujSr8mV9DGVlg7OECtFAY89L(04kd14MaVlxsmschSpwUEkOM1lQeMbKLb7a5IqWyjsMtMhQqrksD9M0sOubFZifBp)iJ03GqaKUXiPGTnemPdmP5cmKet62msXpPxGpyY89L(04k66D43gJ39L(03OJtZ6fvcxmtBMdhU4ddxlMPVd8nTL7IFsZew9ZtMVV0NgxrxVrs4GXCmVeVORH)mZHdFyUadjRo(Yh3ZcGmpuKEeSqAjhNrAib85tFAsNM03mr2WPjLFMO3gKUjPrzXjPbCai1B82EEM0IFsApjPomPNNpPC8yK0bHaElpPEJ32ZZK6nPL8ORKIu3YfsXFGqk2EzdhyxAwWq9MvintaKUnJuKQ3ms5sCXjPoM0Pj9ntKnCAsle4biKwYqsLuUUrpaHu(zIEBqkqWjWFPpnMuhM0p2BdsTSx2WboUOcPLc4yus3MrkxKMjasDmPZpRK57l9PXv01BKeoyigNDfWNp9PnZHdJyb(weLk)mXl8aUpg(uGEJ32ZZheoGdGjt8swHDPz19Loc5e43c8amKk2Ezdh44IkxEGJrRsW9DEEHD6W3mr2WPROEZUfXfN1p)PdFZezdNUITx2W5YzaSlt20U(5d6uGEJ32ZZHiCiT0MmLBu6SILf4TXTDd7eDbsv6TikStiwGVfrPILf4TXTDd7eDbY99ZbgoOth(MjYgoDf2LMv)8Nc8W3mr2WPROEZUfXfN1pVjtyEjgV5cmKexr9MDXYcoa5bDkWdXZpw4nRIyIB6r5INicPttMk(WWvetCtpkx8eriDET)OBpoR(5dImpuKIu3YfsXFGq655tk)pj9ZtQvihqLI0sWQekfPttAAlKMlWqssDysdzWM2W)iPh9kaxi1XnYMKUV0riKYXwAsHDd70Bds5gPRejnxGHK4kz((sFACfD9gjHdg2EzdNlNbWU8R3M5WHl(WWv4vUg)fW8TX1p)PdzsXhgUYbSPn8pEHxb4s9ZFcZlX4nxGHK4kQ3SlwwqicyY89L(04k66nschS3gJ39L(03OJtZ6fvc)yyY8qrksPBytAPa(a88mPivVzKAjlG09L(0KMdPabgiyBsd9ugMuoEAtkwwG3g32nSt0fiK57l9PXv01BKeoyOEZUyzbM9o)IYnxGHK4WCBMdho3O0zfllWBJB7g2j6cKQ0BruyNW8smEZfyijUI6n7ILfCaIf4BruQOEZUyzb33phy4thYMSITx2W5YzaSl)6Dn9x5EBC6W3mr2WPRWU0S6NNmpuKwkGalasZH0pwin0lAVPpnPLGvjuksDys3(mPHEkJuhtApjPF(kz((sFACfD9gjHdgBr7n9Pn7D(fLBUadjXH52mho8HiwGVfrPUX4Lnj((5jZdfPhblKAzVSHdPH8ayKgAztBsDys)yVni1YEzdh44IkKwkGJrjDBgPfsZeaPC8yKubPX7aHu2h4TbPPTqAliTKuJhRsMVV0NgxrxVrs4GHTx2W5YzaSlt202mhomVKvyxAwDFPJqob(TapadPITx2WboUOYLh4y0QeCFNNxyN4LSc7sZQabD9ghIWgpgzEOiTeIC2Zys)yHuuVzfXfNysDysFlpVWiDBgP2)2qaEBqkIXzK6ys)8KUnJ0p2BdsTSx2WboUOcPLc4yus3MrAH0mbqQJj9ZxjL0sGX80NEJXZMr6BXjPOEZkIloj1Hj988jLZ8Jmsles)9wefsZHudjjnTfsboCsAXzs5SE6TbPlPgpwLmFFPpnUIUEJKWbd1B2TiU40mhoCGVzISHtxr9MDlIloRp7fyi4d4(uGmP4ddxT)THa824IyCw9ZBY0H5gLoR2)2qaEBCrmoRk9wefwqMmXlzf2LMvbc66noeHFloVPJkiX4Xc6eVKvyxAwDFPJqob(TapadPITx2WboUOYLh4y0QeCFNNxyN4LSc7sZQabD9gFWBX5nDuHmpuKEeSqAjhNrkxMys6MKA7g2cGuEGpapptkhpTjfP83gcWBdsl54ms)8KMdPbmP5cmKeBgPdG0jTfaP5gLoXKonPwLvjZ3x6tJROR3ijCWqmo7wmX0mhoS34T98Cichsl9PCJsNv7FBiaVnUigNvLElIc7uUrPZkwwG3g32nSt0fivP3IOWoH5Ly8MlWqsCf1B2fllieH5kMmfyG5gLoR2)2qaEBCrmoRk9wef2PdZnkDwXYc8242UHDIUaPk9wefwqMmH5Ly8MlWqsCf1B2fllim3brMhksd90iBs6hlKgAbX8bEBqAPIRXxi1Hj988j9TnPgssQ35qAjhNbpaus9gNYYmJ0bqQdtQLSaVni9y3WorxGqQJjn3O0PWiDBgPC8yKuBpjv65BytAUadjXvY89L(04k66nschmMGy(aVnU8X14lM5WHdeiWabBVfrXKjVXB755doQL2KP3mr2WPRigNDZbaKoRabD9ghIWLyWZ4Xc6uGhIyb(weLk)mXl8aUpg2KjVXB755dchslDqNc8WCJsNvSSaVnUTByNOlqQsVfrHzYuG5gLoRyzbEBCB3WorxGuLElIc70HiwGVfrPILf4TXTDd7eDbY99ZbgoOGiZdfPhblKwsUq60KImHMuhM0ZZNu20iBsAlcJ0Ci9T4K0qliMpWBdslvCn(IzKUnJ00wacPlqinkymPP92KgWKMlWqsmPZpjnWstkhpTj9nn77zqvY89L(04k66nschmeJZUftmnZHdJ5Ly8MlWqsCf1B2flliebgWi5nn77zL5y80BNx5zpcUk9wefwqN8gVTNNdr4qAPpLBu6SILf4TXTDd7eDbsv6TikmtMom3O0zfllWBJB7g2j6cKQ0BruyK5HI0JGfsTSx2WH0qEaSaI0qlBAtQdtAAlKMlWqssDmPBX8tsZHuMlKoasppFsTxecPw2lB4ahxuH0sbCmkPsW9DEEHrkhpTjfP6nRqAMaiDaKAzVSHdSlnJ09LocPsMVV0NgxrxVrs4GHTx2W5YzaSlt202S35xuU5cmKehMBZC4WbMlWqYQTSX0UY)YqG8aCcZlX4nxGHK4kQ3Slwwqic4GmzkqEjRWU0S6(shHCc8BbEagsfBVSHdCCrLlpWXOvj4(opVWcImpuKEeSqQ1haKMjasZHuK6YAbJjDAsxsZfyijPP9MK6ysngVninhszUq6MKM2cPa3WojnDuPsMVV0NgxrxVrs4GH)aG0mbCZ5IUSwWyZENFr5MlWqsCyUnZHdNlWqYA6OYnNlZLqG8sFQ4ddxrmodEaOv2WPjZdfPhblKwYXzKw2aasNKoD8mPomPwHCavks3MrAjlJ0fiKUV0riKUnJ00winxGHKKYzAKnjL5cPSpWBdstBH0N92TeRK57l9PXv01BKeoyigNDZbaKon7D(fLBUadjXH52mhomIf4BruQSjX3p)PCbgswthvU5CzUCqjEkWIpmCfX4m4bGwzdN2KPIpmCfX4m4bGwbc66noeVzISHtxrmo7wmXSce01BCqN2x6iKlBYkIfL3b(7MZ)zFq435xuUslOUGpH5Ly8MlWqsCf1B2flliebwAKeixj4LBu6SMCCCEh4l8Msv6TikSGcImFFPpnUIUEJKWbd1BwH0mbyMdhMnzfXIY7a)DZ5)SRP)k3BJtbMBu6SILf4TXTDd7eDbsv6TikStyEjgV5cmKexr9MDXYcoaXc8TikvuVzxSSG77NdmSjtSjRy7LnCUCga7YVExt)vU3gbDkWdb)wGhGHuX2lB4ahxu5YdCmAvcUVZZlmtM2x6iKlBYkIfL3b(7MZ)zFq435xuUslOUGdImpuKEeSqQvihqHMuoEAtAPwVlaYwUaiTu4nIs6VJcgtAAlKMlWqss54XiPfcPfsC4qkYdWrHKwiWdqinTfsFZezdNM03Gkysl2x5vY89L(04k66nschmS9YgoxodGDzYM2M5WHb)wGhGHu5xVlaYwUaU84nIwLG7788c7eIf4BruQSjX3p)PCbgswthvU5C5F5f5b4GaFZezdNUITx2W5YzaSlt20UY(Gn9PrIXJfezEOi9iyHul7LnCifzal2M0PjfzcnP)okymPPTaesxGq6Yyys9(nOEBujZ3x6tJROR3ijCWW2lB4CFGfBBMdhgSo7kiKoRlJHREFa3bGmpuKEeSqks1BgPwYcinhsFtJ)OcPHEbLtAz2Z3WoXKYdMhM0PjTe4QHKkPLXvdnxLuKzAyhGsQJjnTDmPoM0LuB3WwaKYd8b45zst7TjfiSjtVniDAslbUAiH0FhfmMu2ckN00E(g2jMuht6wm)K0CinDuH05NK57l9PXv01BKeoyOEZUyzbM9o)IYnxGHK4WCBMdhgZlX4nxGHK4kQ3SlwwWbiwGVfrPI6n7ILfCF)CGHpv8HHRSfu(nTNVHDw)8M9SxVdZTzENca85ZRJIkmFtjm3M5DkaWNpVoC40FLJpimYjZdfPhblKIu9Mr6rh3ZKMdPVPXFuH0qVGYjTm75ByNys5bZdt60KAvwL0Y4QHMRskYmnSdqj1HjnTDmPoM0LuB3WwaKYd8b45zst7TjfiSjtVni93rbJjLTGYjnTNVHDIj1XKUfZpjnhsthviD(jz((sFACfD9gjHdgQ3SlCCpBMdhU4ddxzlO8BApFd7S(5pHyb(weLkBs89ZB2ZE9om3M5DkaWNpVokQW8nLWCBM3PaaF(86WHt)vo(GWi)0BMiB40veJZUftmRFEY8qr6rWcPivVzKYL4ItsDysppFsztJSjPTimsZHuGadeSnPHEkdxj1khEsFlo92G0njnGjDaKIoaH0CbgsIjLJN2KAjlWBdsp2nSt0fiKMBu6uyKUnJ0ZZN0fiK2ts6h7TbPw2lB4ahxuH0sbCmkPdG0sHp)S9hPbFVlVI5Ly8MlWqsCf1B2fll4GJsLMudjXKM2cPOE7OFushyslnPBZinTfs7pAHaiDGjnxGHK4kPLqepMrkBiTNKuEGGXKI6nRiU4K0FNEK0ngjnxGHKysxGqkBYuyKYXtBslzzKYXwAs)yVnifBVSHdCCrfs5bogLuhM0cPzcGuht6Iy94weLkz((sFACfD9gjHdgQ3SBrCXPzoCyelW3IOuztIVF(tG1zxbH0zfDqiOsNvVp4T48MoQGKaul9jmVeJ3CbgsIROEZUyzbHiWagjip4LBu6SI6ybCUk9wefgs2x6iKlBYkIfL3b(7MZ)zh8YnkDw5XNF2(7g9U8Q0BruyijqmVeJ3CbgsIROEZUyzbhCuQ0bf8cKxYkSlnRUV0riNa)wGhGHuX2lB4ahxu5YdCmAvcUVZZlSGc6uGhc(TapadPITx2WboUOYLh4y0QeCFNNxyMmD4BMiB40vyxAw9ZFc8BbEagsfBVSHdCCrLlpWXOvj4(opVWmzAFPJqUSjRiwuEh4VBo)N9bHFNFr5kTG6coiY89L(04k66nschmelkVd83nN)Z2S35xuU5cmKehMBZC4Wabgiy7TikNYfyiznDu5MZL5YbCftMcm3O0zf1Xc4Cv6TikStSjRy7LnCUCga7YVExbcmqW2BrucYKPIpmC93WFq0BJlBbL3cgx)8K5HIulE55BK030mp9PjnhsX5Wt6BXP3gKAfYbuPiDAshyyKUCbgsIjLJT0Kc7g2P3gKwIKoasrhGqko3x5cJu0Pat62ms)yVniTu4ZpB)rAW37YjDBgPhZvlJuKQJfW5kz((sFACfD9gjHdg2EzdNlNbWU8R3M5WHbcmqW2BruoLlWqYA6OYnNlZLdc4thMBu6SI6ybCUk9wef2PCJsNvE85NT)UrVlVk9wef2jmVeJ3CbgsIROEZUyzbhGCY8qr6rzr4j1kKdOsr6NN0PjDXKIU9zsZfyijM0ftk)GXErumJubP9e(Kuo2stkSByNEBqAjs6aifDacP4CFLlmsrNcmPC80M0sHp)S9hPbFVlVsMVV0NgxrxVrs4GHTx2W5YzaSl)6TzVZVOCZfyijom3M5WHbcmqW2BruoLlWqYA6OYnNlZLdc4thMBu6SI6ybCUk9wef2Pddm3O0zfllWBJB7g2j6cKQ0BruyNW8smEZfyijUI6n7ILfCaIf4BruQOEZUyzb33phy4Gof4H5gLoR84ZpB)DJExEv6TikmtMcm3O0zLhF(z7VB07YRsVfrHDcZlX4nxGHK4kQ3SlwwqicJ8GcImFFPpnUIUEJKWbd1B2fllWS35xuU5cmKehMBZC4WyEjgV5cmKexr9MDXYcoaXc8TikvuVzxSSG77Ndm8Papep)yH3SkIjUPhLlEIiKonz6W3mr2WPRWrbB)alCw)8bz2ZE9om3M5DkaWNpVokQW8nLWCBM3PaaF(86WHt)vo(GWiNmFFPpnUIUEJKWbd1B2foUNn7zVEhMBZ8ofa4ZNxhfvy(MsyUnZ7uaGpFED4WP)khFqyKFkWdl(WWv2ck)M2Z3WoRFEtMEZezdNUIyC2TyIz9ZhKzoC4dXZpw4nRIyIB6r5INicPttMo8ntKnC6kCuW2pWcN1ppzEOi9iyH0Joky7hyHtsNFIDMq6atk66nPVzISHtJjnhsrxVZ1Bsl5e30JcPwteH0jPfFy4kz((sFACfD9gjHdgCuW2pWcNM5WHXZpw4nRIyIB6r5INicPZthw8HHRigNbpa06N)0HfFy4k)WraxVH)yF66N3mVtba(851rrfMVPeMBZ8ofa4ZNxhoC6VYXheMBY8qr6rWcPwHCafAsxmPXfNKce8assDysNM00wifDqiK57l9PXv01BKeoyy7LnCUCga7YKnTjZdfPhblKAfYbuPiDXKgxCskqWdij1HjDAstBHu0bHq62msTc5ak0K6ysNMuKj0K57l9PXv01BKeoyy7LnCUCga7YVEtMtMhkspcwiDAsrMqtAjyvcLI0Ci1qssd9ugPP)k3Bds3MrQG04DGqAoKg9wi9ZtAHKPaiLJN2KwYXzWdaLmFFPpnUMaVlxsC4pwUEkOM1lQewq5pdKnEhaR3(jM5WHFZezdNUIyC2vaF(0NUce01BCicZnYnz6ntKnC6kIXzxb85tF6kqqxVXhG8JkzEOiTmWzsZHuRZ9JuU(rXqtkhpTjn0ZVikKAL7RCHrkYeAmPomP8dg7frPskxTjnoTHaif2nStmPC80Mu0biKY1pkgAs)ybt6MPGYNKMdP4Z9JuoEAt62Nj9XiDaKIu4Jts)yHupRK57l9PX1e4D5sIrs4G9XY1tb1SErLWEJFGFUfr5gC)TZp6Lji8NyMdhU4ddxrmodEaO1p)PIpmCLF4iGR3WFSpD9ZBYuXGXNGDd78ce01BCicJ8ayYuXhgUYpCeW1B4p2NU(5p9MjYgoDfX4SRa(8PpDfiOR3yKWDPpa2nSZlqqxVXMmv8HHRigNbpa06N)0BMiB40v(HJaUEd)X(0vGGUEJrc3L(ay3WoVabD9gBYuGVzISHtx5hoc46n8h7txbc66n(GWChGtVzISHtxrmo7kGpF6txbc66n(GWChGGob7g25fiOR34dcZnxtaiZdfPwN7hPw2IKKIu)y)rkhpTjTKJZGhakz((sFACnbExUKyKeoyFSC9uqnRxujm6(2cGCX2IKx0p2FM5WHFZezdNUIyC2vaF(0NUce01B8bChaY8qrQ15(rksXFXzs54PnPLA4ias56n8h7tt6hVgIzKIULlKI)aH0Cif3oVqAAlKghocojfPSuKMlWqYkPHST0K(XcJuoEAtQL9YgocJuUkOG0bM0YgaQ0PzKIu4Jts)yH0PjfzcnPlMu0)ZM0ftk)GXEruQK57l9PX1e4D5sIrs4G9XY1tb1SErLW45hJsMEBCb)IZM9o)IYnxGHK4WCBMdhU4ddx5hoc46n8h7tx)8MmDipWfCwXse(YpCeW1B4p2N2Kjj4(opVWQy7LnCe2Daf3b(Mdav6KmpuKEeSqkxwMHqQ3yNjKoWKwYJMu4bqAAlKc7aCs6hlKoasNMuKj0KUWPainTfsHDaoj9JLkPw2dij95G33tsDysrmoJub85tFAsFZezdNMuhtk3bat6aifDacPlN9CLmFFPpnUMaVlxsmschSpwUEkOM1lQeg7n8pEnIlZ3Ca4BXYmK7aFHfW888SzoC43mr2WPRigNDfWNp9PRabD9gFqyUdazEOi9iyHul7LnCegPCvqbPdmPLnauPts5ylnP9KK6nPLCCg8aqnJ0bqQ3KwijhrAsl54ms5YetsFloXK6nPLCCg8aqRK57l9PX1e4D5sIrs4G9XY1tb1SErLWy7LnCe2Daf3b(Mdav60mho8HfFy4kIXzWdaT(5nzkqEGG4A8yvURigNDlMygezEOi9iyH0OJtshysNgP7Jfszl6AiKMaVlxsmPthptQdtks5VneG3gKwYXzKgAP4ddtQJjDFPJqmJ0bq655t6ces7jjn3O0PWi17Ci1Zkz((sFACnbExUKyKeoyVngV7l9PVrhNM1lQeMHACtG3Llj2mhoCGhMBu6SA)Bdb4TXfX4SQ0BruyMmXKIpmC1(3gcWBJlIXz1pFqNcS4ddxrmodEaO1pVjtVzISHtxrmo7kGpF6txbc66n(aUdqqK5HI0qlW7pMKcVXyX(kNu4bq6hVfrHupfuCar6rWcPtt6BMiB40K6nPdGjaslotAc8UCjjfhNSsMVV0NgxtG3LljgjHd2hlxpfuSzoC4IpmCfX4m4bGw)8Mmv8HHR8dhbC9g(J9PRFEtMEZezdNUIyC2vaF(0NUce01B8bChaOekHGaa]] )
    

end
