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


    spec:RegisterPack( "Shadow", 20210804, [[di1IAcqivipsqLlPckOnPI8jiknkb0PeiRsfu6vqeZIIYTGiv2LK(LaLHjaDmuuldIQNjrOPjaCnjI2gks13KiOXjrGZHIKADcGMNGQUNGSpvG)Pck0bfu0crr8qikMOGsxuGQAJQGQpIIKmsis0jrrkRKIQxQckQzkqvUjejTtvO(jksmujsDuvqrwkej0tPKPkr5QQGSvjs(QGcJfIu1Eb5VQ0GjDyLwSeESQmzuDzIndQptHrtPonvRgIe8AjQMTq3gs7wQFRy4O0XfOYYbEoutx01vvBhcFhfgpePCEvuRxfuG5tr2pYqmdvgKfFtb6yKhqKZCalbbmaQmZmZLe5mdzLNzfil29v(Aiqw9Ikqww2lFyazXUNJZYHkdYcpFWtGSSZKfhGblygEA)lQVbnyyh9h30N(bw4myyh9fmiRIVhtMwdvazX3uGog5be5mhWsqadGkZmZCjroK1(t7bazz5OidKLTZ5sdvazXf8dYYYE5ddslnWfCsMhMFJpojTenJuKhqKZmzozoYyVTHGdqYCKoslJHSLtAPgNtAzdaiDskdBPjnxGHKK(MFNysxGqk8aEcVsMJ0rAPbsknNu(KysxGq6NLug2stAUadjXKUaH0xCWcP5qk)S3gMrkEinT3K0(xUGjDbcP40JrsbYBqrLMl8kKv0XjgQmilUaV)ycvg0XmdvgK1(sFAilShL(jqwsVfrHdXeOe6yKdvgKL0Bru4qmbY6b8ua(czv8HHRigNdpa06NLutMiT4ddxzhgc46n8h7tx)Sqw7l9PHSyN0NgkHoUeHkdYs6TikCiMaznSqwyjHS2x6tdzHyb(wefileB8lqwbskFYk2E5dJlJbWVSR310FL7TbPMmrAUadjRPJk3CUCxin8HinainisprAGKYNSIyrzDG)U58F210FL7TbPMmrAUadjRPJk3CUCxin8HiLPtAqqwiwWTxubYIpj((zHsOJdaOYGSKElIchIjqwdlKfwsiR9L(0qwiwGVfrbYcXg)cKfIf4BruQ8jX3plPNiLpzLliMpWBJlBCn(sn9x5EBazHyb3ErfiRngV8jX3plucDCjHkdYs6TikCiMaznSqwyjHS2x6tdzHyb(wefileB8lqwywjgV5cmKexr9MFXYci9asroPiH0IpmCfX4C4bGw)SqwCb)aoB6tdzzLlij9J92GulzbEBq6XUHDIUaH0njTercP5cmKet6ainaqcPomPNNpPlqi1Bsl14C4bGczHyb3ErfilSSaVnUTByNOlqUVFoWWqj0XmDOYGSKElIchIjqwdlKfwsiR9L(0qwiwGVfrbYcXg)cK1BMiFy0veJZVc4ZM(01plPNinqspIuW68RGq6SUCoU(zj1KjsbRZVccPZ6Y54k)d20NM0WhIuMdiPMmrkyD(vqiDwxohxbc66nM0dcrkZbKuKqAjj9WsAGKMBu6SA)Bdb4TXfX48Q0Bru4KAYePVbH0BN1Ypd8TjnisdI0tKgiPbskyD(vqiDwxohx9M0dif5bKutMifZkX4nxGHK4kIX5xb8ztFAspiePLK0Gi1KjsZnkDwT)THa824IyCEv6TikCsnzI03Gq6TZA5Nb(2KgePNinqspIuWVf4byivmRTae81EbOtFUkb33zzfoPMmrAGK(MjYhgDLDyiGR3WFSpDfiOR3ysdFisnE8k6I0i9WsAjsQjtKw8HHRSddbC9g(J9PRFwsnzI0IbJj9ePWUHDEbc66nM0WhIuKxssdI0GGS4c(bC20NgYczMjYhgnPLEMiPLAb(wefZi9qyHtAoKYotK0cbEacP7lDeB6TbPigNdpa0kPiZhaKoJNj9JfoP5q6B6emrszylnP5q6(shXMcPigNdpausz4PnPE)guVniD5CCfYcXcU9IkqwSZeVWd4(4yOe64siuzqwsVfrHdXeiRhWtb4lKvXhgUIyCo8aqRFwiR9L(0qwWoqkIZWHsOJlbqLbzj9wefoetGSEapfGVqwfFy4kIX5WdaT(zHS2x6tdzviaSak3BdOe6yMAOYGSKElIchIjqw7l9PHSIUHDIVif(CduPtilUGFaNn9PHSoewin45g2jYIj18p3av6KuhM00wacPlqif5KoasrhGqAUadjXMr6aiD5CmPlqAKnjfZUmAVnifEaKIoaH00EBslHLexHSEapfGVqwywjgV5cmKexJUHDIVif(CduPtspiePiNutMinqspIuW68RGq6SUCoUkinhNysnzIuW68RGq6SUCoU6nPhqAjSKKgeucDmZbeQmilP3IOWHycK1d4Pa8fYQ4ddxrmohEaO1plK1(sFAiRTFcobB8(2yekHoMzMHkdYs6TikCiMazTV0NgY6TX4DFPp9n64eYk6482lQaz9y8GsOJzg5qLbzj9wefoetGS2x6tdzb(9DFPp9n64eYk6482lQazHUEdLqjKfh14MaVlxsmuzqhZmuzqwsVfrHdXeiRErfil(ckhDM(YLx53l7pbc(j9tGS2x6tdzXxq5OZ0xU8k)Ez)jqWpPFcucDmYHkdYs6TikCiMaz1lQazH)DrCg(DrL0(moHS2x6tdzH)DrCg(DrL0(moHsOJlrOYGSKElIchIjqw9IkqwgXZS23b(UySJ6Xn9PHS2x6tdzzepZAFh47IXoQh30NgkHooaGkdYs6TikCiMaz1lQazXbYYHDGCriySeHS2x6tdzXbYYHDGCriySeHsOeYcD9gQmOJzgQmilP3IOWHycK1d4Pa8fYQ4ddxlMPVd8nTL7IFsZfE9ZczTV0NgY6TX4DFPp9n64eYk6482lQazvmtdLqhJCOYGSKElIchIjqwpGNcWxiRJinxGHKvhFzJ7zbazTV0NgYI7ywjErxd)bLqhxIqLbzj9wefoetGS2x6tdzHyC(vaF20NgYIl4hWztFAiRdHfsl14Csd(GpB6tt60K(MjYhgnPSZe92G0njnklojnaciPEJ32ZZKw8ts7jj1Hj988jLHhJKoieWBzj1B82EEMuVjTuhELuK6wUqk(desX2lFya7sZdgQ38cP5cG0T5KIu9MtktIloj1XKonPVzI8HrtAHapaH0sf8RKY0m6biKYot0Bdsbcob(l9PXK6WK(XEBqQL9YhgWXfviT0ahJs62CszI0CbqQJjD(zfY6b8ua(czHyb(weLk7mXl8aUpoM0tKgiPEJ32ZZKEqisdGasQjtKYkzf2LMx3x6iesprk43c8amKk2E5dd44IkxwGJrRsW9DwwHt6jspI03mr(WOROEZVfXfN1plPNi9isFZe5dJUITx(W4Yya8lx20U(zjnisprAGK6nEBpptA4drAjOKKAYeP5gLoRyzbEBCB3WorxGuLElIcN0tKIyb(weLkwwG3g32nSt0fi33phyysdI0tKEePVzI8HrxHDP51plPNinqspI03mr(WOROEZVfXfN1plPMmrkMvIXBUadjXvuV5xSSaspGuKtAqKEI0aj9isXZpw4nVIyIB6r5INicPZQ0Bru4KAYePfFy4kIjUPhLlEIiKoV2F0ThNx)SKgeucDCaavgKL0Bru4qmbYAFPpnKf2E5dJlJbWVSR3qwCb)aoB6tdzHu3YfsXFGq655tk7pj9ZsQvyeGLM0W0kmlnPttAAlKMlWqssDysddWM2W)iPh(kaxi1XnYMKUV0riKYWwAsHDd70BdszgPRejnxGHK4kK1d4Pa8fYQ4ddxHx5A8xa33gx)SKEI0JiLlfFy4kdWM2W)4fEfGl1plPNifZkX4nxGHK4kQ38lwwaPHN0aakHoUKqLbzj9wefoetGS2x6tdz92y8UV0N(gDCczfDCE7fvGSECmucDmthQmilP3IOWHycK1(sFAiluV5xSSaiR35xuU5cmKedDmZqwpGNcWxiRCJsNvSSaVnUTByNOlqQsVfrHt6jsXSsmEZfyijUI6n)ILfq6bKIyb(weLkQ38lwwW99ZbgM0tKEeP8jRy7LpmUmga)YUExt)vU3gKEI0Ji9ntKpm6kSlnV(zHS4c(bC20NgYcP0nSjT0aFaEEMuKQ3CsTKfq6(sFAsZHuGadeSnPHDkdtkdpTjfllWBJB7g2j6ceOe64siuzqwsVfrHdXeiR9L(0qw8fT30NgY6D(fLBUadjXqhZmK1d4Pa8fY6isrSaFlIsDJXlFs89ZczXf8d4SPpnKvPbcSainhs)yH0WUO9M(0KgMwHzPj1HjD7ZKg2PmsDmP9KK(zRqj0XLaOYGSKElIchIjqw7l9PHSW2lFyCzma(LlBAdzXf8d4SPpnK1HWcPw2lFyqAymaoPHv20MuhM0p2BdsTSx(WaoUOcPLg4yus3MtAH0CbqkdpgjvqASoqiL)bEBqAAlK2cslj14XRqwpGNcWxilwjRWU086(shHq6jsb)wGhGHuX2lFyahxu5YcCmAvcUVZYkCsprkRKvyxAEfiOR3ysdFisnECOe6yMAOYGSKElIchIjqw7l9PHSq9MFlIloHS4c(bC20NgYkmJm2Zys)yHuuV5fXfNysDysFllRWjDBoP2)2qaEBqkIX5K6ys)SKUnN0p2BdsTSx(WaoUOcPLg4yus3MtAH0CbqQJj9ZwjL0WKZ90NEJXZMr6BXjPOEZlIloj1Hj988jLX8JCsles)9wefsZHudjjnTfsboCsAXzszSE6TbPlPgpEfY6b8ua(czfiPVzI8Hrxr9MFlIloRp7fyiyspGuMj9ePbskxk(WWv7FBiaVnUigNx)SKAYePhrAUrPZQ9VneG3gxeJZRsVfrHtAqKAYePSswHDP5vGGUEJjn8Hi9T48MoQqksi14XjnisprkRKvyxAEDFPJqi9ePGFlWdWqQy7LpmGJlQCzbogTkb33zzfoPNiLvYkSlnVce01BmPhq6BX5nDubkHoM5acvgKL0Bru4qmbYAFPpnKfIX53IjMqwCb)aoB6tdzDiSqAPgNtktMys6MKA7g2cGuwGpapptkdpTjfP83gcWBdsl14Cs)SKMdPbaP5cmKeBgPdG0jTfaP5gLoXKonPwLvHSEapfGVqwEJ32ZZKg(qKwckjPNin3O0z1(3gcWBJlIX5vP3IOWj9eP5gLoRyzbEBCB3WorxGuLElIcN0tKIzLy8MlWqsCf1B(fllG0WhIuMoPMmrAGKgiP5gLoR2)2qaEBCrmoVk9wefoPNi9isZnkDwXYc8242UHDIUaPk9wefoPbrQjtKIzLy8MlWqsCf1B(fllG0qKYmPbbLqhZmZqLbzj9wefoetGS2x6tdzXfeZh4TXLnUgFbYIl4hWztFAiRWonYMK(XcPHvqmFG3gKw64A8fsDysppFsFBtQHKK6DoKwQX5WdaLuVXPSCZiDaK6WKAjlWBdsp2nSt0fiK6ysZnkDkCs3Mtkdpgj12tsLE(g2KMlWqsCfY6b8ua(czfiPabgiy7TikKAYePEJ32ZZKEaPLWssAqKEI0aj9isrSaFlIsLDM4fEa3hhtQjtK6nEBppt6bHiTeussdI0tKgiPhrAUrPZkwwG3g32nSt0fivP3IOWj1KjsdK0CJsNvSSaVnUTByNOlqQsVfrHt6jspIuelW3IOuXYc8242UHDIUa5((5adtAqKgeucDmZihQmilP3IOWHycK1(sFAileJZVftmHS4c(bC20NgY6qyH0sXesNMuKjSK6WKEE(KYNgztsBr4KMdPVfNKgwbX8bEBqAPJRXxmJ0T5KM2cqiDbcPrbJjnT3M0aG0CbgsIjD(jPbwssz4PnPVP5FpdQcz9aEkaFHSWSsmEZfyijUI6n)ILfqA4jnqsdasrcPVP5FpRChJNE78kp7rWvP3IOWjnisprQ34T98mPHpePLGss6jsZnkDwXYc8242UHDIUaPk9wefoPMmr6rKMBu6SILf4TXTDd7eDbsv6TikCOe6yMlrOYGSKElIchIjqw7l9PHSW2lFyCzma(LlBAdz9o)IYnxGHKyOJzgY6b8ua(czfiP5cmKSAlBmTRSVK0WtkYdiPNifZkX4nxGHK4kQ38lwwaPHN0aG0Gi1KjsdKuwjRWU086(shHq6jsb)wGhGHuX2lFyahxu5YcCmAvcUVZYkCsdcYIl4hWztFAiRdHfsTSx(WG0Wya8aK0WkBAtQdtAAlKMlWqssDmPBX8tsZHuUlKoasppFsTxecPw2lFyahxuH0sdCmkPsW9DwwHtkdpTjfP6nVqAUaiDaKAzV8HbSlnN09LocPcLqhZCaavgKL0Bru4qmbYAFPpnKf(dasZfWnNl6YBbJHSENFr5MlWqsm0Xmdz9aEkaFHSYfyiznDu5MZL7cPHNuKxssprAXhgUIyCo8aqR8HrdzXf8d4SPpnK1HWcPwFaqAUainhsrQlVfmM0PjDjnxGHKKM2BsQJj1y82G0CiL7cPBsAAlKcCd7K00rLkucDmZLeQmilP3IOWHycK1(sFAileJZV5aasNqwVZVOCZfyijg6yMHSEapfGVqwiwGVfrPYNeF)SKEI0CbgswthvU5C5Uq6bKwIKEI0ajT4ddxrmohEaOv(WOj1Kjsl(WWveJZHhaAfiOR3ysdpPVzI8Hrxrmo)wmXSce01BmPbr6js3x6iKlFYkIfL1b(7MZ)ztAisXSsmEZfyijUIyrzDG)U58F2KEIumReJ3CbgsIROEZVyzbKgEsdK0ssksinqsz6KEyjn3O0znz448oWx4nLQ0Bru4KgePbbzXf8d4SPpnK1HWcPLACoPLnaG0jPthptQdtQvyeGLM0T5KwQYiDbcP7lDecPBZjnTfsZfyijPmMgzts5Uqk)d82G00wi9zVDlXkucDmZmDOYGSKElIchIjqwpGNcWxil(KvelkRd83nN)ZUM(RCVni9ePbsAUrPZkwwG3g32nSt0fivP3IOWj9ePywjgV5cmKexr9MFXYci9asrSaFlIsf1B(fll4((5adtQjtKYNSITx(W4Yya8l76Dn9x5EBqAqKEI0aj9isb)wGhGHuX2lFyahxu5YcCmAvcUVZYkCsnzI09Loc5YNSIyrzDG)U58F2KEqisFNFr5kTG6cM0GGS2x6tdzH6nVqAUaGsOJzUecvgKL0Bru4qmbYAFPpnKf2E5dJlJbWVCztBilUGFaNn9PHSoewi1kmcWWskdpTjT0R3fazlxaKwA8grj93rbJjnTfsZfyijPm8yK0cH0cjomif5b8Wqsle4biKM2cPVzI8Hrt6BqfmPf7R8kK1d4Pa8fYc8BbEagsLD9UaiB5c4YI3iAvcUVZYkCsprkIf4BruQ8jX3plPNinxGHK10rLBox2xErEaj9asdK03mr(WORy7LpmUmga)YLnTR8pytFAsrcPgpoPbbLqhZCjaQmilP3IOWHycK1(sFAilS9Yhg3hyX2qwCb)aoB6tdzDiSqQL9YhgKImGfBt60KImHL0FhfmM00wacPlqiD5CmPE)guVnQqwpGNcWxilW68RGq6SUCoU6nPhqkZbekHoMzMAOYGSKElIchIjqwpGNcWxilmReJ3CbgsIROEZVyzbKEaPiwGVfrPI6n)ILfCF)CGHj9ePfFy4kFbLFt75ByN1plKfxWpGZM(0qwhclKIu9MtQLSasZH0304pQqAyxq5KwM98nStmPSG5HjDAsdtMsWVsAzmLWYuifzMg2bOK6ystBhtQJjDj12nSfaPSaFaEEM00EBsbcFY0BdsNM0WKPe8j93rbJjLVGYjnTNVHDIj1XKUfZpjnhsthviD(jK178lk3CbgsIHoMzilVtba(S51HHSs)vo(GqihYY7uaGpBEDuuH7Bkqwmdz9SxVHSygYAFPpnKfQ38lwwaucDmYdiuzqwsVfrHdXeilUGFaNn9PHSoewifP6nN0dpUNjnhsFtJ)OcPHDbLtAz2Z3WoXKYcMhM0Pj1QSkPLXucltHuKzAyhGsQdtAA7ysDmPlP2UHTaiLf4dWZZKM2Btkq4tMEBq6VJcgtkFbLtAApFd7etQJjDlMFsAoKMoQq68tiRhWtb4lKvXhgUYxq530E(g2z9Zs6jsrSaFlIsLpj((zHS8ofa4ZMxhgYk9x54dcH8tVzI8Hrxrmo)wmXS(zHS8ofa4ZMxhfv4(McKfZqwp71BilMHS2x6tdzH6n)ch3Zqj0XiNzOYGSKElIchIjqw7l9PHSq9MFlIloHS4c(bC20NgY6qyHuKQ3CszsCXjPomPNNpP8Pr2K0weoP5qkqGbc2M0WoLHRKALdlPVfNEBq6MKgaKoasrhGqAUadjXKYWtBsTKf4TbPh7g2j6cesZnkDkCs3Mt655t6ces7jj9J92Gul7LpmGJlQqAPbogL0bqAPXNF2(J0GN3LxXSsmEZfyijUI6n)ILfCWHXssQHKystBHuuVD0pkPdmPLK0T5KM2cP9hTqaKoWKMlWqsCL0WmIhZiLpK2tsklqWysr9MxexCs6Vtps6gJKMlWqsmPlqiLpzkCsz4PnPLQmszylnPFS3gKITx(WaoUOcPSahJsQdtAH0CbqQJjDrSEClIsfY6b8ua(czHyb(weLkFs89Zs6jsbRZVccPZk6GqqLoREt6bK(wCEthvifjKgWAjj9ePywjgV5cmKexr9MFXYcin8KgiPbaPiHuKt6HL0CJsNvuhlGZvP3IOWjfjKUV0rix(KvelkRd83nN)ZM0dlP5gLoRS4ZpB)DJExEv6TikCsrcPbskMvIXBUadjXvuV5xSSasp4WiPLK0Gi9WsAGKYkzf2LMx3x6iesprk43c8amKk2E5dd44IkxwGJrRsW9DwwHtAqKgePNinqspIuWVf4byivS9YhgWXfvUSahJwLG77SScNutMi9isFZe5dJUc7sZRFwsprk43c8amKk2E5dd44IkxwGJrRsW9DwwHtQjtKUV0rix(KvelkRd83nN)ZM0dcr678lkxPfuxWKgeucDmYrouzqwsVfrHdXeiR9L(0qwiwuwh4VBo)NnK1d4Pa8fYciWabBVfrH0tKMlWqYA6OYnNl3fspGuMoPMmrAGKMBu6SI6ybCUk9wefoPNiLpzfBV8HXLXa4x217kqGbc2ElIcPbrQjtKw8HHR)g(dIEBC5lO8wW46NfY6D(fLBUadjXqhZmucDmYlrOYGSKElIchIjqw7l9PHSW2lFyCzma(LD9gYIl4hWztFAillw55BK030Cp9PjnhsX5Ws6BXP3gKAfgbyPjDAshyyKUCbgsIjLHT0Kc7g2P3gKwIKoasrhGqko3x5cNu0Pat62Cs)yVniT04ZpB)rAWZ7YjDBoPhZukJuKQJfW5kK1d4Pa8fYciWabBVfrH0tKMlWqYA6OYnNl3fspG0aG0tKEeP5gLoROowaNRsVfrHt6jsZnkDwzXNF2(7g9U8Q0Bru4KEIumReJ3CbgsIROEZVyzbKEaPihkHog5bauzqwsVfrHdXeiR9L(0qwy7LpmUmga)YUEdz9o)IYnxGHKyOJzgY6b8ua(czbeyGGT3IOq6jsZfyiznDu5MZL7cPhqAaq6jspI0CJsNvuhlGZvP3IOWj9ePhrAGKMBu6SILf4TXTDd7eDbsv6TikCsprkMvIXBUadjXvuV5xSSaspGuelW3IOur9MFXYcUVFoWWKgePNinqspI0CJsNvw85NT)UrVlVk9wefoPMmrAGKMBu6SYIp)S93n6D5vP3IOWj9ePywjgV5cmKexr9MFXYcin8Hif5KgePbbzXf8d4SPpnK1Hzryj1kmcWst6NL0PjDXKIU9zsZfyijM0ftk7GXErumJubP9e2Kug2stkSByNEBqAjs6aifDacP4CFLlCsrNcmPm80M0sJp)S9hPbpVlVcLqhJ8scvgKL0Bru4qmbYAFPpnKfQ38lwwaK178lk3CbgsIHoMzilVtba(S51HHSs)vo(GqihYY7uaGpBEDuuH7Bkqwmdz9aEkaFHSWSsmEZfyijUI6n)ILfq6bKIyb(weLkQ38lwwW99ZbgM0tKgiPhrkE(XcV5vetCtpkx8eriDwLElIcNutMi9isFZe5dJUchfS9dSWz9ZsAqqwp71BilMHsOJrothQmilP3IOWHycK1(sFAiluV5x44EgYY7uaGpBEDyiR0FLJpieYpf4rfFy4kFbLFt75ByN1pRjtVzI8Hrxrmo)wmXS(zdcYY7uaGpBEDuuH7Bkqwmdz9SxVHSygY6b8ua(czDeP45hl8MxrmXn9OCXteH0zv6TikCsnzI0Ji9ntKpm6kCuW2pWcN1plucDmYlHqLbzj9wefoetGS2x6tdzbhfS9dSWjKL3PaaF286WqwP)khFqiMHS8ofa4ZMxhfv4(McKfZqwpGNcWxil88JfEZRiM4MEuU4jIq6Sk9wefoPNi9isl(WWveJZHhaA9Zs6jspI0IpmCLDyiGR3WFSpD9ZczXf8d4SPpnK1HWcPhEuW2pWcNKo)e7CH0bMu01BsFZe5dJgtAoKIUENR3KwQjUPhfsTMicPtsl(WWvOe6yKxcGkdYs6TikCiMazXf8d4SPpnK1HWcPwHragwsxmPXfNKce8assDysNM00wifDqiqw7l9PHSW2lFyCzma(LlBAdLqhJCMAOYGSKElIchIjqwCb)aoB6tdzDiSqQvyeGLM0ftACXjPabpGKuhM0PjnTfsrhecPBZj1kmcWWsQJjDAsrMWczTV0NgYcBV8HXLXa4x21BOekHSybYBql2eQmOJzgQmilP3IOWHycK1d4Pa8fYciOR3ysdpPLyadiK1(sFAil2HHaUmga)cpG0ZpxGsOJrouzqwsVfrHdXeiRhWtb4lKfE(XcV5v2po)r5kGpB6txLElIcNutMifp)yH38kIjUPhLlEIiKoRsVfrHdzTV0NgYcoky7hyHtOe64seQmilP3IOWHycK1d4Pa8fY6isl(WWvS9YhgWdaT(zHS2x6tdzHTx(WaEaOqj0XbauzqwsVfrHdXeiRhWtb4lKL34T98CLlW(ZtspGuMljK1(sFAiRf82wU5aasNqj0XLeQmilP3IOWHycKvVOcKf2E5ddHFhqXDGV5aqLoHS2x6tdzHTx(Wq43buCh4BoauPtOe6yMouzqwsVfrHdXeiRHfYcljK1(sFAilelW3IOazHyJFbYc5qwiwWTxubYc1B(fll4((5addLqhxcHkdYAFPpnKfIfL1b(7MZ)zdzj9wefoetGsOeY6XXqLbDmZqLbzj9wefoetGS2x6tdzXomeW1B4p2NgYIl4hWztFAiRdHfsl9WqaKY0A4p2NMugEAtAPgNdpa0kPiLtKtk8aiTuJZHhakPVbvWKoWWK(MjYhgnPEtAAlK2csljL5askwEtZXKoPTay4yH0pwiDAsFCs)DuWystBHu24EwaK6yszxqs6atAAlKw(zGVnPVbH0BNMr6ai1HjnTfGqkdpgjTNK0cH0TN0waKwQX5Kg8bF20NM002XKc7g2zL0WmtbLnjnhsXN7hPPTqACXjPSddbqQ3WFSpnPdmPPTqkSByNKMdPigNtQa(SPpnPWdG0EAspmFg4BJRqwpGNcWxilwGl4SILi8LDyiGR3WFSpnPNinqsl(WWveJZHhaA9ZsQjtKEePVbH0BN1Ypd8Tj9ePhr6Bqi92zTLhyIdGt6jsFZe5dJUIyC(vaF20NUce01BmPheIuMdiPMmrkSByNxGGUEJjn8K(MjYhgDfX48Ra(SPpDfiOR3ysdI0tKgiPWUHDEbc66nM0dcr6BMiFy0veJZVc4ZM(0vGGUEJjfjKYCjj9ePVzI8Hrxrmo)kGpB6txbc66nM0WhIuJhN0dlPbaPMmrkSByNxGGUEJj9asFZe5dJUYomeW1B4p2NUY)Gn9Pj1KjslgmM0tKc7g25fiOR3ysdpPVzI8Hrxrmo)kGpB6txbc66nMuKqkZLKutMi9niKE7Sw(zGVnPMmrAXhgUweNHh)4S(zjniOe6yKdvgKL0Bru4qmbYIl4hWztFAiRdHfszYYnes9g7CH0bM0sD4KcpastBHuyhGts)yH0bq60KImHL0fofaPPTqkSdWjPFSujnm80M0JDd7K0dFfsTNiNu4bqAPo8kKvVOcKf2B4F8AexUV5aW3ILBi3b(clG555ziRhWtb4lKvXhgUIyCo8aqRFwsnzI00rfspGuMdiPNinqspI03Gq6TZA7g25fEfsdcYAFPpnKf2B4F8AexUV5aW3ILBi3b(clG555zOe64seQmilP3IOWHycK1(sFAil4vUg)fW9TXqwCb)aoB6tdzDiSq6HVcPmv)fW9TXKonPityjD(j25cPdmPLACo8aqRKEiSq6HVcPmv)fW9T5ys9M0snohEaOK6WKEE(KAViesfpTfaPmvGbHqktRr4gdytFAshaPhUlroPdmPmjoy8GIRKggRNKcpas5tIjnhsles)SKwiWdqiDFPJytVni9WxHuMQ)c4(2ysZHu0fP5OowinTfsl(WWviRhWtb4lK1rKw8HHRigNdpa06NL0tKgiPhr6BMiFy0veJZV5aasN1plPMmr6rKMBu6SIyC(nhaq6Sk9wefoPbr6jsdKuelW3IOu5tIVFwsprkMvIXBUadjXvelkRd83nN)ZM0qKYmPMmr6(shHC5twrSOSoWF3C(pBsdrkMvIXBUadjXvelkRd83nN)ZM0tKIzLy8MlWqsCfXIY6a)DZ5)Sj9aszM0Gi1Kjsl(WWveJZHhaA9Zs6jsdKu88JfEZRgGbHC9gHBmGn9PRsVfrHtQjtKINFSWBEf2Li)oW3I4GXdkUk9wefoPbbLqhhaqLbzj9wefoetGS2x6tdzH6n3yrfmK178lk3CbgsIHoMziRhWtb4lKL34T98mPHNuM6as6jsdK0ajfXc8Tik1ngV8jX3plPNinqspI03mr(WORigNFfWNn9PRFwsnzI0Jin3O0z1(3gcWBJlIX5vP3IOWjnisdIutMiT4ddxrmohEaO1plPbr6jsdK0Jin3O0z1(3gcWBJlIX5vP3IOWj1Kjs5sXhgUA)Bdb4TXfX48kqqxVXKEaPVfN30rfsnzI0JiT4ddxrmohEaO1plPbr6jsdK0Jin3O0zfllWBJB7g2j6cKQ0Bru4KAYePywjgV5cmKexr9MFXYcin8KwssdcYIl4hWztFAiRdHfsrQEZnwubtkdBPjDJrslrsd7ugM0fiK(znJ0bq655t6ces9M0snohEaOvsd(n(desrk)THa82G0snoNugEmsko9yK0cH0plPmSLM00wi9T4K00rfsH92X2cUsQvoSK(XEBq6MKwsKqAUadjXKYWtBsTKf4TbPh7g2j6cKkucDCjHkdYs6TikCiMazTV0NgY632t88ThelKfxWpGZM(0qwhclKEO2EINj94bXs60KImH1msTNi3BdslaUahptAoKYy9Ku4bqk7WqaK6n8h7tt6aiD5CsXSlJgxHSEapfGVqwbsAGKEePG15xbH0zD5CC9Zs6jsbRZVccPZ6Y54Q3KEaPipGKgePMmrkyD(vqiDwxohxbc66nM0dcrkZLKutMifSo)kiKoRlNJR8pytFAsdpPmxssdI0tKgiPfFy4k7WqaxVH)yF66NLutMi9ntKpm6k7WqaxVH)yF6kqqxVXKEqiszoGKAYePhrklWfCwXse(YomeW1B4p2NM0Gi9ePbs6rKMBu6SA)Bdb4TXfX48Q0Bru4KAYePCP4ddxT)THa824IyCE9ZsQjtKEePfFy4kIX5WdaT(zjniOe6yMouzqwsVfrHdXeiR9L(0qwfZ03b(M2YDXpP5chYIl4hWztFAiRdHfsNMuKjSKw8tszb(a80XcPFS3gKwQX5Kg8bF20NMuyhGtZi1Hj9JfoPEJDUq6atAPoCsNMuRYi9Jfsx4uaKUKIyCEXetsHhaPVzI8HrtQad7px63zs3Mtk8ai1(3gcWBdsrmoN0pB6OcPomP5gLofEfY6b8ua(czDePfFy4kIX5WdaT(zj9ePhr6BMiFy0veJZVc4ZM(01plPNifZkX4nxGHK4kQ38lwwaPhqkZKEI0Jin3O0zfllWBJB7g2j6cKQ0Bru4KAYePbsAXhgUIyCo8aqRFwsprkMvIXBUadjXvuV5xSSasdpPiN0tKEeP5gLoRyzbEBCB3WorxGuLElIcN0tKgiPSabX14XRmxrmo)wmXK0tKgiPhrQeCFNLv4vbL9mq24Da8E7NqQjtKEeP5gLoR2)2qaEBCrmoVk9wefoPbrQjtKkb33zzfEvqzpdKnEhaV3(jKEI03mr(WORck7zGSX7a492pPce01BmPHpePmZ0roPNiLlfFy4Q9VneG3gxeJZRFwsdI0Gi1KjsdK0IpmCfX4C4bGw)SKEI0CJsNvSSaVnUTByNOlqQsVfrHtAqqj0XLqOYGSKElIchIjqw7l9PHSEBmE3x6tFJooHSIooV9IkqwjW7YLedLqjKvc8UCjXqLbDmZqLbzj9wefoetGS4c(bC20NgY6qyH0PjfzclPHPvywAsZHudjjnStzKM(RCVniDBoPcsJ1bcP5qA0BH0plPfsMcGugEAtAPgNdpauiRErfilbL9mq24Da8E7Naz9aEkaFHSEZe5dJUIyC(vaF20NUce01BmPHpePmJCsnzI03mr(WORigNFfWNn9PRabD9gt6bKI8siK1(sFAilbL9mq24Da8E7NaLqhJCOYGSKElIchIjqwCb)aoB6tdzvg4mP5qQ15(rkt7WuyjLHN2Kg25xefsTY9vUWjfzclMuhMu2bJ9IOujLP0KgN2qaKc7g2jMugEAtk6aeszAhMclPFSGjDZuqztsZHu85(rkdpTjD7ZK(4Koasrk8XjPFSqQNviRErfilVXpWp3IOCdU)25h9Yfe(tGSEapfGVqwfFy4kIX5WdaT(zj9ePfFy4k7WqaxVH)yF66NLutMiTyWysprkSByNxGGUEJjn8Hif5bKutMiT4ddxzhgc46n8h7tx)SKEI03mr(WORigNFfWNn9PRabD9gtksiL5ss6bKc7g25fiOR3ysnzI0IpmCfX4C4bGw)SKEI03mr(WORSddbC9g(J9PRabD9gtksiL5ss6bKc7g25fiOR3ysnzI0aj9ntKpm6k7WqaxVH)yF6kqqxVXKEqiszoGKEI03mr(WORigNFfWNn9PRabD9gt6bHiL5asAqKEIuy3WoVabD9gt6bHiLzM6aczTV0NgYYB8d8ZTik3G7VD(rVCbH)eOe64seQmilP3IOWHycKfxWpGZM(0qwwN7hPw2IKKIu)y)rkdpTjTuJZHhakKvVOcKf6(2cGCX2IKx0p2FqwpGNcWxiR3mr(WORigNFfWNn9PRabD9gt6bKYCaHS2x6tdzHUVTaixSTi5f9J9hucDCaavgKL0Bru4qmbYQxubYcp)yuY0BJl4xCgY6D(fLBUadjXqhZmK1(sFAil88JrjtVnUGFXziRhWtb4lKvXhgUYomeW1B4p2NU(zj1KjspIuwGl4SILi8LDyiGR3WFSpnPMmrQeCFNLv4vS9Yhgc)oGI7aFZbGkDczXf8d4SPpnKL15(rksXFXzsz4PnPLEyiaszAn8h7tt6hVgIzKIULlKI)aH0Cif3oRqAAlKghgcojfPS0KMlWqYkPHHT0K(XcNugEAtQL9YhgcNuMcOG0bM0YgaQ0PzKIu4Jts)yH0PjfzclPlMu0)ZM0ftk7GXEruQqj0XLeQmilP3IOWHycKfxWpGZM(0qwhclKYKLBiK6n25cPdmPL6WjfEaKM2cPWoaNK(XcPdG0PjfzclPlCkastBHuyhGts)yPsQL9assFo499KuhMueJZjvaF20NM03mr(WOj1XKYCaXKoasrhGq6YypxHS6fvGSWEd)JxJ4Y9nha(wSCd5oWxybmpppdz9aEkaFHSEZe5dJUIyC(vaF20NUce01BmPheIuMdiK1(sFAilS3W)41iUCFZbGVfl3qUd8fwaZZZZqj0XmDOYGSKElIchIjqwCb)aoB6tdzDiSqQL9YhgcNuMcOG0bM0YgaQ0jPmSLM0Ess9M0snohEaOMr6ai1BslKKHinPLACoPmzIjPVfNys9M0snohEaOviRErfilS9Yhgc)oGI7aFZbGkDcz9aEkaFHSoI0IpmCfX4C4bGw)SKAYePbsklqqCnE8kZveJZVftmjniiR9L(0qwy7Lpme(Daf3b(Mdav6ekHoUecvgKL0Bru4qmbYIl4hWztFAiRdHfsJoojDGjDAKUpwiLVORHqAc8UCjXKoD8mPomPiL)2qaEBqAPgNtAyLIpmmPoM09LocXmshaPNNpPlqiTNK0CJsNcNuVZHupRqw7l9PHSEBmE3x6tFJooHSEapfGVqwbs6rKMBu6SA)Bdb4TXfX48Q0Bru4KAYePCP4ddxT)THa824IyCE9ZsAqKEI0ajT4ddxrmohEaO1plPMmr6BMiFy0veJZVc4ZM(0vGGUEJj9aszoGKgeKv0X5TxubYIJACtG3LljgkHoUeavgKL0Bru4qmbYAFPpnK1hlxpfumKfxWpGZM(0qwHvG3FmjfEJXI9voPWdG0pElIcPEkO4aK0dHfsNM03mr(WOj1BshaxaKwCM0e4D5sskoozfY6b8ua(czv8HHRigNdpa06NLutMiT4ddxzhgc46n8h7tx)SKAYePVzI8Hrxrmo)kGpB6txbc66nM0diL5acLqjKvXmnuzqhZmuzqwsVfrHdXeiRhWtb4lKfMvIXBUadjXvuV5xSSasdFislriR9L(0qwl(jnx43I4ItOe6yKdvgKL0Bru4qmbY6b8ua(czHzLy8MlWqsCDXpP5c)2dIL0diLzsprkMvIXBUadjXvuV5xSSaspGuMjfjKMBu6SILf4TXTDd7eDbsv6TikCiR9L(0qwl(jnx43EqSqjucz9y8Gkd6yMHkdYs6TikCiMaz9XYLHThL7BXP3gqhZmK1(sFAilSSaVnUTByNOlqGSENFr5MlWqsm0Xmdz9aEkaFHScKuelW3IOuXYc8242UHDIUa5((5adt6jspIuelW3IOuzNjEHhW9XXKgePMmrAGKYNSITx(W4Yya8l76DfiWabBVfrH0tKIzLy8MlWqsCf1B(fllG0diLzsdcYIl4hWztFAiRdHfsTKf4TbPh7g2j6cesDysppFsz4XiP2EsQ0Z3WM0CbgsIjDBoPLEyiaszAn8h7tt62Csl14C4bGs6ces7jjfil)SzKoasZHuGadeSnPwHrawAsNM0KXq6aifDacP5cmKexHsOJrouzqwsVfrHdXeiRpwUmS9OCFlo92a6yMHS2x6tdzHLf4TXTDd7eDbcK178lk3CbgsIHoMziRhWtb4lKvUrPZkwwG3g32nSt0fivP3IOWj9eP8jRy7LpmUmga)YUExbcmqW2Brui9ePywjgV5cmKexr9MFXYci9asroKfxWpGZM(0qww2dijfzCW77jPwYc82G0JDd7eDbcPVP5E6ttAoKwUiSKAfgbyPj9ZsQ3KgMtWhkHoUeHkdYs6TikCiMaznD889X4bzXmK1(sFAiluV53I4ItilUGFaNn9PHSMoE((y8ifDlxWKM2cP7l9PjD64zs)4TikKY)aVni9zVDlrVniDBoP9KKUysxsbIXpUas3x6txHsOekHSqiaSpn0XipGiN5awcrotnKfJf0EBGHScJWeP4XmTJzQcqsjTmBHuhLDajPWdGuKLfiVbTytKLuGeCFhiCsXdQq6(ZbDtHt6ZEBdbxjZdEElKI8aKuKzAecifoPilE(XcV5vKEKL0CifzXZpw4nVI0xLElIchzjnqMrAbvjZdEElKI8aKuKzAecifoPilE(XcV5vKEKL0CifzXZpw4nVI0xLElIchzjDtsd(mLGhPbYmslOkzozEyeMifpMPDmtvaskPLzlK6OSdijfEaKISOR3ilPaj4(oq4KIhuH09Nd6McN0N92gcUsMh88wiTedqsrMPriGu4KIS45hl8Mxr6rwsZHuKfp)yH38ksFv6TikCKL0azgPfuLmp45TqkYlzaskYmncbKcNuKfp)yH38kspYsAoKIS45hl8Mxr6RsVfrHJSKgiZiTGQK5bpVfsrotpajfzMgHasHtkYINFSWBEfPhzjnhsrw88JfEZRi9vP3IOWrwsdKzKwqvY8GN3cPiVegGKImtJqaPWjfzXZpw4nVI0JSKMdPilE(XcV5vK(Q0Bru4ilPbYmslOkzozEyeMifpMPDmtvaskPLzlK6OSdijfEaKISpogzjfib33bcNu8GkKU)Cq3u4K(S32qWvY8GN3cPm9aKuKzAecifoPiBc8UCjRBXR(MjYhgnYsAoKISVzI8Hrx3IhYsAGmJ0cQsMtMZ0qzhqkCslbKUV0NM0OJtCLmhYcZkpOJrEjlbqwSGb2JcKv4chPw2lFyqAPbUGtY8WfosdZVXhNKwIMrkYdiYzMmNmpCHJuKXEBdbhGK5HlCKI0rAzmKTCsl14CslBaaPtszylnP5cmKK0387et6cesHhWt4vY8Wfosr6iT0ajLMtkFsmPlqi9ZskdBPjnxGHKysxGq6loyH0CiLF2BdZifpKM2BsA)lxWKUaHuC6XiPa5nOOsZfELmNmpCHJ0GpstE)u4KwiWdqi9nOfBsAHy4nUsAy(EcBIjTNgPZEbOW)iP7l9PXKoD8CLmFFPpnUYcK3GwSjscfm2HHaUmga)cpG0ZpxmZHdbe01BC4lXagqY89L(04klqEdAXMijuWGJc2(bw40mhoeE(XcV5v2po)r5kGpB6tBYeE(XcV5vetCtpkx8eriDsMVV0NgxzbYBql2ejHcg2E5dd4bGAMdh6OIpmCfBV8Hb8aqRFwY89L(04klqEdAXMijuWwWBB5MdaiDAMdhYB82EEUYfy)55bmxsY89L(04klqEdAXMijuW(y56PGAwVOsiS9Yhgc)oGI7aFZbGkDsMVV0NgxzbYBql2ejHcgIf4BrumRxujeQ38lwwW99Zbg2SHnewsZqSXVec5K57l9PXvwG8g0InrsOGHyrzDG)U58F2K5K5HlCKw6j9PXK57l9PXHWEu6NqMVV0NghIDsFAZC4qfFy4kIX5WdaT(znzQ4ddxzhgc46n8h7tx)SK57l9PXijuWqSaFlIIz9IkH4tIVFwZg2qyjndXg)sOa5twX2lFyCzma(LD9UM(RCVnmzkxGHK10rLBoxUlHpuae0Pa5twrSOSoWF3C(p7A6VY92WKPCbgswthvU5C5Ue(qm9GiZ3x6tJrsOGHyb(wefZ6fvcTX4Lpj((znBydHL0meB8lHqSaFlIsLpj((zpXNSYfeZh4TXLnUgFPM(RCVniZdhPw5css)yVni1swG3gKESByNOlqiDtslrKqAUadjXKoasdaKqQdt655t6ces9M0snohEaOK57l9PXijuWqSaFlIIz9IkHWYc8242UHDIUa5((5adB2WgclPzi24xcHzLy8MlWqsCf1B(fll4aKJKIpmCfX4C4bGw)SK5HJuKzMiFy0Kw6zIKwQf4BrumJ0dHfoP5qk7mrsle4biKUV0rSP3gKIyCo8aqRKImFaq6mEM0pw4KMdPVPtWejLHT0KMdP7lDeBkKIyCo8aqjLHN2K69Bq92G0LZXvY89L(0yKekyiwGVfrXSErLqSZeVWd4(4yZg2qyjndXg)sO3mr(WORigNFfWNn9PRF2tbEeyD(vqiDwxohx)SMmbwNFfesN1LZXv(hSPpD4dXCanzcSo)kiKoRlNJRabD9gFqiMdisk5HnWCJsNv7FBiaVnUigNxLElIc3KP3Gq6TZA5Nb(2bf0PadeSo)kiKoRlNJREFaYdOjtywjgV5cmKexrmo)kGpB6tFqOsgKjt5gLoR2)2qaEBCrmoVk9wefUjtVbH0BN1Ypd8Td6uGhb(TapadPIzTfGGV2laD6Zvj4(olRWnzkW3mr(WORSddbC9g(J9PRabD9gh(qgpEfDrAh2s0KPIpmCLDyiGR3WFSpD9ZAYuXGXNGDd78ce01BC4dH8sguqK5HlCKIuucUVdemPWFqAlasbccxyeGKsAzoQ3gKImHftk8ai9y5bM4a4KwSyHt60Kc7g2jPrPnsBs3MtA6OcPabD92BdZiLfmfBr8mP5mKIyIB6rHu4bqQ3iDglQujZdx4iDFPpngjHcgIf4BrumRxuje7mXl8aUpo2SHnewsZqSXVe6ntKpm6kIX5xb8ztF66N9uGhbwNFfesN1LZX1pRjtG15xbH0zD5CCL)bB6th(qmhqtMaRZVccPZ6Y54kqqxVXheI5aIKsEydm3O0z1(3gcWBJlIX5vP3IOWnz6niKE7Sw(zGVDqbDkWabRZVccPZ6Y54Q3hG8aAYeMvIXBUadjXveJZVc4ZM(0heQKbzYuUrPZQ9VneG3gxeJZRsVfrHBY0Bqi92zT8ZaF7Gof4rGFlWdWqQywBbi4R9cqN(CvcUVZYk8tbE0Bqi92zTLhyIdGBYuGbc7g25fiOR3yKKoQe0bHkXsmGNshvcFiKhWaAYuGWUHDEbc66ngjPJkbf(qiVKb8uGWUHDEbc66ngjPJkbDqiKhWaguqMm9MjYhgDLDyiGR3WFSpDfiOR34WhY4XROls7WwIMmv8HHRSddbC9g(J9PRFwtMGDd78ce01BC4dH8sgez((sFAmscfmyhifXz4M5WHk(WWveJZHhaA9ZsMVV0NgJKqbRqaybuU3gM5WHk(WWveJZHhaA9ZsMhospewin45g2jYIj18p3av6KuhM00wacPlqif5KoasrhGqAUadjXMr6aiD5CmPlqAKnjfZUmAVnifEaKIoaH00EBslHLexjZ3x6tJrsOGfDd7eFrk85gOsNM5WHWSsmEZfyijUgDd7eFrk85gOsNhec5Mmf4rG15xbH0zD5CCvqAooXMmbwNFfesN1LZXvVpOewYGiZ3x6tJrsOGT9tWjyJ33gJM5WHk(WWveJZHhaA9ZsMVV0NgJKqb7TX4DFPp9n640SErLqpgpY89L(0yKekyGFF3x6tFJoonRxuje66nzozE4chPHzPdEKMdPFSqkdBPjLjZ0KoWKM2cPHj(jnx4K6ys3x6ieY89L(04AXmDOf)KMl8BrCXPzoCimReJ3CbgsIROEZVyzbHpujsMVV0NgxlMPrsOGT4N0CHF7bXAMdhcZkX4nxGHK46IFsZf(The7bmFcZkX4nxGHK4kQ38lwwWbmJKCJsNvSSaVnUTByNOlqQsVfrHtMtMhUWrkYewmzE4i9qyH0spmeaPmTg(J9PjLHN2KwQX5WdaTsks5e5Kcpasl14C4bGs6BqfmPdmmPVzI8HrtQ3KM2cPTG0sszoGKIL30CmPtAlagowi9JfsNM0hN0FhfmM00wiLnUNfaPoMu2fKKoWKM2cPLFg4Bt6Bqi92PzKoasDystBbiKYWJrs7jjTqiD7jTfaPLACoPbFWNn9PjnTDmPWUHDwjnmZuqztsZHu85(rAAlKgxCsk7WqaK6n8h7tt6atAAlKc7g2jP5qkIX5KkGpB6ttk8aiTNM0dZNb(24kz((sFAC9XXHyhgc46n8h7tBMdhIf4coRyjcFzhgc46n8h7tFkWIpmCfX4C4bGw)SMmD0Bqi92zT8ZaF7th9gesVDwB5bM4a4NEZe5dJUIyC(vaF20NUce01B8bHyoGMmb7g25fiOR34W)MjYhgDfX48Ra(SPpDfiOR34GofiSByNxGGUEJpi0BMiFy0veJZVc4ZM(0vGGUEJrcZL80BMiFy0veJZVc4ZM(0vGGUEJdFiJh)WgaMmb7g25fiOR34dEZe5dJUYomeW1B4p2NUY)Gn9PnzQyW4tWUHDEbc66no8VzI8Hrxrmo)kGpB6txbc66ngjmxstMEdcP3oRLFg4BBYuXhgUweNHh)4S(zdImpCKEiSqQLhL(jKonPityjnhszbZJulH1(FyaYIjT0G5fx0n9PRK5HJ09L(046JJrsOGH9O0pXSCbgsED4qGFlWdWqQyH1(Fya(YcMxCr30NUkb33zzf(PaZfyiz1X3LZnzkxGHKvUu8HHRVfNEBubY(YGiZdhPhclKYKLBiK6n25cPdmPL6WjfEaKM2cPWoaNK(XcPdG0PjfzclPlCkastBHuyhGts)yPsAy4PnPh7g2jPh(kKAproPWdG0sD4vY89L(046JJrsOG9XY1tb1SErLqyVH)XRrC5(MdaFlwUHCh4lSaMNNNnZHdv8HHRigNdpa06N1KP0rLdyoGNc8O3Gq6TZA7g25fELGiZdhPhclKE4Rqkt1FbCFBmPttkYewsNFIDUq6atAPgNdpa0kPhclKE4Rqkt1FbCFBoMuVjTuJZHhakPomPNNpP2lcHuXtBbqktfyqiKY0AeUXa20NM0bq6H7sKt6atktIdgpO4kPHX6jPWdGu(KysZH0cH0plPfc8aes3x6i20Bdsp8viLP6VaUVnM0CifDrAoQJfstBH0IpmCLmFFPpnU(4yKekyWRCn(lG7BJnZHdDuXhgUIyCo8aqRF2tbE0BMiFy0veJZV5aasN1pRjthLBu6SIyC(nhaq6Sk9wefEqNceXc8Tikv(K47N9eMvIXBUadjXvelkRd83nN)ZoeZMmTV0rix(KvelkRd83nN)ZoeMvIXBUadjXvelkRd83nN)Z(eMvIXBUadjXvelkRd83nN)Z(aMdYKPIpmCfX4C4bGw)SNcep)yH38QbyqixVr4gdytF6Q0Bru4MmHNFSWBEf2Li)oW3I4GXdkUk9wefEqK5HJ0dHfsrQEZnwubtkdBPjDJrslrsd7ugM0fiK(znJ0bq655t6ces9M0snohEaOvsd(n(desrk)THa82G0snoNugEmsko9yK0cH0plPmSLM00wi9T4K00rfsH92X2cUsQvoSK(XEBq6MKwsKqAUadjXKYWtBsTKf4TbPh7g2j6cKkz((sFAC9XXijuWq9MBSOc2S35xuU5cmKehIzZC4qEJ32ZZHNPoGNcmqelW3IOu3y8YNeF)SNc8O3mr(WORigNFfWNn9PRFwtMok3O0z1(3gcWBJlIX5vP3IOWdkitMk(WWveJZHhaA9Zg0Papk3O0z1(3gcWBJlIX5vP3IOWnzIlfFy4Q9VneG3gxeJZRabD9gFWBX5nDuXKPJk(WWveJZHhaA9Zg0Papk3O0zfllWBJB7g2j6cKQ0Bru4MmHzLy8MlWqsCf1B(flli8LmiY8Wr6HWcPhQTN4zspEqSKonPitynJu7jY92G0cGlWXZKMdPmwpjfEaKYomeaPEd)X(0KoasxoNum7YOXvY89L(046JJrsOG9B7jE(2dI1mhouGbEeyD(vqiDwxohx)SNaRZVccPZ6Y54Q3hG8agKjtG15xbH0zD5CCfiOR34dcXCjnzcSo)kiKoRlNJR8pytF6WZCjd6uGfFy4k7WqaxVH)yF66N1KP3mr(WORSddbC9g(J9PRabD9gFqiMdOjthXcCbNvSeHVSddbC9g(J9Pd6uGhLBu6SA)Bdb4TXfX48Q0Bru4MmXLIpmC1(3gcWBJlIX51pRjthv8HHRigNdpa06NniY8Wr6HWcPttkYewsl(jPSaFaE6yH0p2Bdsl14Csd(GpB6ttkSdWPzK6WK(XcNuVXoxiDGjTuhoPttQvzK(XcPlCkasxsrmoVyIjPWdG03mr(WOjvGH9Nl97mPBZjfEaKA)Bdb4TbPigNt6NnDuHuhM0CJsNcVsMVV0NgxFCmscfSIz67aFtB5U4N0CHBMdh6OIpmCfX4C4bGw)SNo6ntKpm6kIX5xb8ztF66N9eMvIXBUadjXvuV5xSSGdy(0r5gLoRyzbEBCB3WorxGuLElIc3KPal(WWveJZHhaA9ZEcZkX4nxGHK4kQ38lwwq4r(PJYnkDwXYc8242UHDIUaPk9wef(PazbcIRXJxzUIyC(TyI5PapscUVZYk8QGYEgiB8oaEV9tmz6OCJsNv7FBiaVnUigNxLElIcpitMKG77SScVkOSNbYgVdG3B)KtjW7YLSkOSNbYgVdG3B)K6BMiFy0vGGUEJdFiMz6i)exk(WWv7FBiaVnUigNx)SbfKjtbw8HHRigNdpa06N9uUrPZkwwG3g32nSt0fivP3IOWdImFFPpnU(4yKekyVngV7l9PVrhNM1lQekbExUKyYCY8WfosrMfNKgg2EuifzwC6TbP7l9PXvsTKK0nj12nSfaPSaFaEEM0CifBpGK0NdEFpj17uaGpBs6BAUN(0ysNMuKQ3CsTKfeSdpUNjZdhPhclKAjlWBdsp2nSt0fiK6WKEE(KYWJrsT9KuPNVHnP5cmKet62Csl9WqaKY0A4p2NM0T5KwQX5WdaL0fiK2tskqw(zZiDaKMdPabgiyBsTcJaS0KonPjJH0bqk6aesZfyijUsMVV0NgxFmEHWYc8242UHDIUaXSpwUmS9OCFlo92ieZM9o)IYnxGHK4qmBMdhkqelW3IOuXYc8242UHDIUa5((5adF6ielW3IOuzNjEHhW9XXbzYuG8jRy7LpmUmga)YUExbcmqW2BruoHzLy8MlWqsCf1B(fll4aMdImpCKAzpGKuKXbVVNKAjlWBdsp2nSt0fiK(MM7PpnP5qA5IWsQvyeGLM0plPEtAyobFY89L(046JXdjHcgwwG3g32nSt0fiM9XYLHThL7BXP3gHy2S35xuU5cmKehIzZC4q5gLoRyzbEBCB3WorxGuLElIc)eFYk2E5dJlJbWVSR3vGadeS9weLtywjgV5cmKexr9MFXYcoa5K5HJ0PJNVpgpsr3YfmPPTq6(sFAsNoEM0pElIcP8pWBdsF2B3s0Bds3MtApjPlM0LuGy8JlG09L(0vY89L(046JXdjHcgQ38BrCXPzthpFFmEHyMmNmFFPpnUYrnUjW7YLeh6JLRNcQz9IkH4lOC0z6lxELFVS)ei4N0pHmFFPpnUYrnUjW7YLeJKqb7JLRNcQz9IkHW)Uiod)UOsAFgNK57l9PXvoQXnbExUKyKekyFSC9uqnRxujKr8mR9DGVlg7OECtFAY89L(04kh14MaVlxsmscfSpwUEkOM1lQeIdKLd7a5IqWyjsMtMhUWrksD9M0WS0bpZifBp)iN03GqaKUXiPGTnemPdmP5cmKet62CsXpPxGpyY89L(04k66DO3gJ39L(03OJtZ6fvcvmtBMdhQ4ddxlMPVd8nTL7IFsZfE9ZsMVV0NgxrxVrsOGXDmReVORH)mZHdDuUadjRo(Yg3ZcGmpCKEiSqAPgNtAWh8ztFAsNM03mr(WOjLDMO3gKUjPrzXjPbqaj1B82EEM0IFsApjPomPNNpPm8yK0bHaEllPEJ32ZZK6nPL6WRKIu3YfsXFGqk2E5ddyxAEWq9MxinxaKUnNuKQ3CszsCXjPoM0Pj9ntKpmAsle4biKwQGFLuMMrpaHu2zIEBqkqWjWFPpnMuhM0p2BdsTSx(WaoUOcPLg4yus3MtktKMlasDmPZpRK57l9PXv01BKekyigNFfWNn9PnZHdHyb(weLk7mXl8aUpo(uGEJ32ZZhekacOjtSswHDP519Loc5e43c8amKk2E5dd44IkxwGJrRsW9DwwHF6O3mr(WOROEZVfXfN1p7PJEZe5dJUITx(W4Yya8lx20U(zd6uGEJ32ZZHpujOKMmLBu6SILf4TXTDd7eDbsv6Tik8tiwGVfrPILf4TXTDd7eDbY99ZbgoOth9MjYhgDf2LMx)SNc8O3mr(WOROEZVfXfN1pRjtywjgV5cmKexr9MFXYcoa5bDkWJWZpw4nVIyIB6r5INicPttMk(WWvetCtpkx8eriDET)OBpoV(zdImpCKIu3YfsXFGq655tk7pj9ZsQvyeGLM0W0kmlnPttAAlKMlWqssDysddWM2W)iPh(kaxi1XnYMKUV0riKYWwAsHDd70BdszgPRejnxGHK4kz((sFACfD9gjHcg2E5dJlJbWVSR3M5WHk(WWv4vUg)fW9TX1p7PJ4sXhgUYaSPn8pEHxb4s9ZEcZkX4nxGHK4kQ38lwwq4daY89L(04k66nscfS3gJ39L(03OJtZ6fvc94yY8WrksPBytAPb(a88mPivV5KAjlG09L(0KMdPabgiyBsd7ugMugEAtkwwG3g32nSt0fiK57l9PXv01BKekyOEZVyzbM9o)IYnxGHK4qmBMdhk3O0zfllWBJB7g2j6cKQ0Bru4NWSsmEZfyijUI6n)ILfCaIf4BruQOEZVyzb33phy4thXNSITx(W4Yya8l76Dn9x5EBC6O3mr(WORWU086NLmpCKwAGalasZH0pwinSlAVPpnPHPvywAsDys3(mPHDkJuhtApjPF2kz((sFACfD9gjHcgFr7n9Pn7D(fLBUadjXHy2mho0riwGVfrPUX4Lpj((zjZdhPhclKAzV8HbPHXa4KgwztBsDys)yVni1YE5dd44IkKwAGJrjDBoPfsZfaPm8yKubPX6aHu(h4TbPPTqAliTKuJhVsMVV0NgxrxVrsOGHTx(W4Yya8lx202mhoeRKvyxAEDFPJqob(TapadPITx(WaoUOYLf4y0QeCFNLv4NyLSc7sZRabD9gh(qgpozE4inmJm2Zys)yHuuV5fXfNysDysFllRWjDBoP2)2qaEBqkIX5K6ys)SKUnN0p2BdsTSx(WaoUOcPLg4yus3MtAH0CbqQJj9ZwjL0WKZ90NEJXZMr6BXjPOEZlIloj1Hj988jLX8JCsles)9wefsZHudjjnTfsboCsAXzszSE6TbPlPgpELmFFPpnUIUEJKqbd1B(TiU40mhouGVzI8Hrxr9MFlIloRp7fyi4dy(uGCP4ddxT)THa824IyCE9ZAY0r5gLoR2)2qaEBCrmoVk9wefEqMmXkzf2LMxbc66no8HEloVPJkiX4Xd6eRKvyxAEDFPJqob(TapadPITx(WaoUOYLf4y0QeCFNLv4NyLSc7sZRabD9gFWBX5nDuHmpCKEiSqAPgNtktMys6MKA7g2cGuwGpapptkdpTjfP83gcWBdsl14Cs)SKMdPbaP5cmKeBgPdG0jTfaP5gLoXKonPwLvjZ3x6tJROR3ijuWqmo)wmX0mhoK34T98C4dvck5PCJsNv7FBiaVnUigNxLElIc)uUrPZkwwG3g32nSt0fivP3IOWpHzLy8MlWqsCf1B(flli8Hy6MmfyG5gLoR2)2qaEBCrmoVk9wef(PJYnkDwXYc8242UHDIUaPk9wefEqMmHzLy8MlWqsCf1B(fllieZbrMhosd70iBs6hlKgwbX8bEBqAPJRXxi1Hj988j9TnPgssQ35qAPgNdpaus9gNYYnJ0bqQdtQLSaVni9y3WorxGqQJjn3O0PWjDBoPm8yKuBpjv65BytAUadjXvY89L(04k66nscfmUGy(aVnUSX14lM5WHceiWabBVfrXKjVXB755dkHLmOtbEeIf4BruQSZeVWd4(4ytM8gVTNNpiujOKbDkWJYnkDwXYc8242UHDIUaPk9wefUjtbMBu6SILf4TXTDd7eDbsv6Tik8thHyb(weLkwwG3g32nSt0fi33phy4GcImpCKEiSqAPycPttkYewsDysppFs5tJSjPTiCsZH03ItsdRGy(aVniT0X14lMr62CstBbiKUaH0OGXKM2BtAaqAUadjXKo)K0aljPm80M0308VNbvjZ3x6tJROR3ijuWqmo)wmX0mhoeMvIXBUadjXvuV5xSSGWhyaGK308VNvUJXtVDELN9i4Q0Bru4bDYB82EEo8HkbL8uUrPZkwwG3g32nSt0fivP3IOWnz6OCJsNvSSaVnUTByNOlqQsVfrHtMhospewi1YE5ddsdJbWdqsdRSPnPomPPTqAUadjj1XKUfZpjnhs5Uq6ai988j1EriKAzV8HbCCrfslnWXOKkb33zzfoPm80MuKQ38cP5cG0bqQL9YhgWU0Cs3x6iKkz((sFACfD9gjHcg2E5dJlJbWVCztBZENFr5MlWqsCiMnZHdfyUadjR2Ygt7k7ldpYd4jmReJ3CbgsIROEZVyzbHpacYKPazLSc7sZR7lDeYjWVf4byivS9YhgWXfvUSahJwLG77SScpiY8Wr6HWcPwFaqAUainhsrQlVfmM0PjDjnxGHKKM2BsQJj1y82G0CiL7cPBsAAlKcCd7K00rLkz((sFACfD9gjHcg(dasZfWnNl6YBbJn7D(fLBUadjXHy2mhouUadjRPJk3CUCxcpYl5PIpmCfX4C4bGw5dJMmpCKEiSqAPgNtAzdaiDs60XZK6WKAfgbyPjDBoPLQmsxGq6(shHq62CstBH0CbgsskJPr2KuUlKY)aVninTfsF2B3sSsMVV0NgxrxVrsOGHyC(nhaq60S35xuU5cmKehIzZC4qiwGVfrPYNeF)SNYfyiznDu5MZL7YbL4Pal(WWveJZHhaALpmAtMk(WWveJZHhaAfiOR34W)MjYhgDfX48BXeZkqqxVXbDAFPJqU8jRiwuwh4VBo)NDimReJ3CbgsIRiwuwh4VBo)N9jmReJ3CbgsIROEZVyzbHpWsIKaz6h2CJsN1KHJZ7aFH3uQsVfrHhuqK57l9PXv01BKekyOEZlKMlaZC4q8jRiwuwh4VBo)NDn9x5EBCkWCJsNvSSaVnUTByNOlqQsVfrHFcZkX4nxGHK4kQ38lwwWbiwGVfrPI6n)ILfCF)CGHnzIpzfBV8HXLXa4x217A6VY92iOtbEe43c8amKk2E5dd44IkxwGJrRsW9DwwHBY0(shHC5twrSOSoWF3C(p7dc9o)IYvAb1fCqK5HJ0dHfsTcJamSKYWtBsl96Dbq2YfaPLgVrus)DuWystBH0CbgsskdpgjTqiTqIddsrEapmK0cbEacPPTq6BMiFy0K(gubtAX(kVsMVV0NgxrxVrsOGHTx(W4Yya8lx202mhoe43c8amKk76Dbq2YfWLfVr0QeCFNLv4NqSaFlIsLpj((zpLlWqYA6OYnNl7lVipGhe4BMiFy0vS9YhgxgdGF5YM2v(hSPpnsmE8GiZdhPhclKAzV8HbPidyX2KonPityj93rbJjnTfGq6cesxohtQ3Vb1BJkz((sFACfD9gjHcg2E5dJ7dSyBZC4qG15xbH0zD5CC17dyoGK5HJ0dHfsrQEZj1swaP5q6BA8hvinSlOCslZE(g2jMuwW8WKonPHjtj4xjTmMsyzkKImtd7ausDmPPTJj1XKUKA7g2cGuwGpapptAAVnPaHpz6TbPttAyYuc(K(7OGXKYxq5KM2Z3WoXK6ys3I5NKMdPPJkKo)KmFFPpnUIUEJKqbd1B(fllWS35xuU5cmKehIzZC4qywjgV5cmKexr9MFXYcoaXc8TikvuV5xSSG77Ndm8PIpmCLVGYVP98nSZ6N1SN96DiMnZ7uaGpBEDuuH7BkHy2mVtba(S51HdL(RC8bHqozE4i9qyHuKQ3Csp84EM0Ci9nn(JkKg2fuoPLzpFd7etklyEysNMuRYQKwgtjSmfsrMPHDakPomPPTJj1XKUKA7g2cGuwGpapptAAVnPaHpz6TbP)okymP8fuoPP98nStmPoM0Ty(jP5qA6OcPZpjZ3x6tJROR3ijuWq9MFHJ7zZC4qfFy4kFbLFt75ByN1p7jelW3IOu5tIVFwZE2R3Hy2mVtba(S51rrfUVPeIzZ8ofa4ZMxhou6VYXhec5NEZe5dJUIyC(TyIz9ZsMhospewifP6nNuMexCsQdt655tkFAKnjTfHtAoKceyGGTjnStz4kPw5Ws6BXP3gKUjPbaPdGu0biKMlWqsmPm80MulzbEBq6XUHDIUaH0CJsNcN0T5KEE(KUaH0Ess)yVni1YE5dd44IkKwAGJrjDaKwA85NT)in45D5vmReJ3CbgsIROEZVyzbhCySKKAijM00wif1Bh9Js6atAjjDBoPPTqA)rleaPdmP5cmKexjnmJ4Xms5dP9KKYcemMuuV5fXfNK(70JKUXiP5cmKet6ces5tMcNugEAtAPkJug2st6h7TbPy7LpmGJlQqklWXOK6WKwinxaK6ysxeRh3IOujZ3x6tJROR3ijuWq9MFlIlonZHdHyb(weLkFs89ZEcSo)kiKoROdcbv6S69bVfN30rfKeWAjpHzLy8MlWqsCf1B(flli8bgaib5h2CJsNvuhlGZvP3IOWrY(shHC5twrSOSoWF3C(p7dBUrPZkl(8Z2F3O3LxLElIchjbIzLy8MlWqsCf1B(fll4GdJLmOdBGSswHDP519Loc5e43c8amKk2E5dd44IkxwGJrRsW9DwwHhuqNc8iWVf4byivS9YhgWXfvUSahJwLG77SSc3KPJEZe5dJUc7sZRF2tGFlWdWqQy7LpmGJlQCzbogTkb33zzfUjt7lDeYLpzfXIY6a)DZ5)Spi078lkxPfuxWbrMVV0NgxrxVrsOGHyrzDG)U58F2M9o)IYnxGHK4qmBMdhciWabBVfr5uUadjRPJk3CUCxoGPBYuG5gLoROowaNRsVfrHFIpzfBV8HXLXa4x217kqGbc2ElIsqMmv8HHR)g(dIEBC5lO8wW46NLmpCKAXkpFJK(MM7PpnP5qkohwsFlo92GuRWialnPtt6adJ0LlWqsmPmSLMuy3Wo92G0sK0bqk6aesX5(kx4KIofys3Mt6h7TbPLgF(z7psdEExoPBZj9yMszKIuDSaoxjZ3x6tJROR3ijuWW2lFyCzma(LD92mhoeqGbc2ElIYPCbgswthvU5C5UCqaC6OCJsNvuhlGZvP3IOWpLBu6SYIp)S93n6D5vP3IOWpHzLy8MlWqsCf1B(fll4aKtMhospmlclPwHrawAs)SKonPlMu0TptAUadjXKUyszhm2lIIzKkiTNWMKYWwAsHDd70BdslrshaPOdqifN7RCHtk6uGjLHN2KwA85NT)in45D5vY89L(04k66nscfmS9YhgxgdGFzxVn7D(fLBUadjXHy2mhoeqGbc2ElIYPCbgswthvU5C5UCqaC6OCJsNvuhlGZvP3IOWpDuG5gLoRyzbEBCB3WorxGuLElIc)eMvIXBUadjXvuV5xSSGdqSaFlIsf1B(fll4((5adh0Papk3O0zLfF(z7VB07YRsVfrHBYuG5gLoRS4ZpB)DJExEv6Tik8tywjgV5cmKexr9MFXYccFiKhuqK57l9PXv01BKekyOEZVyzbM9o)IYnxGHK4qmBMdhcZkX4nxGHK4kQ38lwwWbiwGVfrPI6n)ILfCF)CGHpf4r45hl8MxrmXn9OCXteH0Pjth9MjYhgDfoky7hyHZ6NniZE2R3Hy2mVtba(S51rrfUVPeIzZ8ofa4ZMxhou6VYXhec5K57l9PXv01BKekyOEZVWX9Szp717qmBM3PaaF286OOc33ucXSzENca8zZRdhk9x54dcH8tbEuXhgUYxq530E(g2z9ZAY0BMiFy0veJZVftmRF2GmZHdDeE(XcV5vetCtpkx8eriDAY0rVzI8HrxHJc2(bw4S(zjZdhPhclKE4rbB)alCs68tSZfshysrxVj9ntKpmAmP5qk66DUEtAPM4MEui1AIiKojT4ddxjZ3x6tJROR3ijuWGJc2(bw40mhoeE(XcV5vetCtpkx8eriDE6OIpmCfX4C4bGw)SNoQ4ddxzhgc46n8h7tx)SM5DkaWNnVokQW9nLqmBM3PaaF286WHs)vo(GqmtMhospewi1kmcWWs6IjnU4KuGGhqsQdt60KM2cPOdcHmFFPpnUIUEJKqbdBV8HXLXa4xUSPnzE4i9qyHuRWialnPlM04ItsbcEajPomPttAAlKIoies3MtQvyeGHLuht60KImHLmFFPpnUIUEJKqbdBV8HXLXa4x21BYCY8Wr6HWcPttkYewsdtRWS0KMdPgssAyNYin9x5EBq62CsfKgRdesZH0O3cPFwslKmfaPm80M0snohEaOK57l9PX1e4D5sId9XY1tb1SErLqck7zGSX7a492pXmho0BMiFy0veJZVc4ZM(0vGGUEJdFiMrUjtVzI8Hrxrmo)kGpB6txbc66n(aKxcjZdhPLbotAoKADUFKY0omfwsz4PnPHD(frHuRCFLlCsrMWIj1HjLDWyVikvszknPXPneaPWUHDIjLHN2KIoaHuM2HPWs6hlys3mfu2K0CifFUFKYWtBs3(mPpoPdGuKcFCs6hlK6zLmFFPpnUMaVlxsmscfSpwUEkOM1lQeYB8d8ZTik3G7VD(rVCbH)eZC4qfFy4kIX5WdaT(zpv8HHRSddbC9g(J9PRFwtMkgm(eSByNxGGUEJdFiKhqtMk(WWv2HHaUEd)X(01p7P3mr(WORigNFfWNn9PRabD9gJeMl5bWUHDEbc66n2KPIpmCfX4C4bGw)SNEZe5dJUYomeW1B4p2NUce01BmsyUKha7g25fiOR3ytMc8ntKpm6k7WqaxVH)yF6kqqxVXheI5aE6ntKpm6kIX5xb8ztF6kqqxVXheI5ag0jy3WoVabD9gFqiMzQdizE4i16C)i1YwKKuK6h7psz4PnPLACo8aqjZ3x6tJRjW7YLeJKqb7JLRNcQz9IkHq33waKl2wK8I(X(Zmho0BMiFy0veJZVc4ZM(0vGGUEJpG5asMhosTo3psrk(lotkdpTjT0ddbqktRH)yFAs)41qmJu0TCHu8hiKMdP42zfstBH04WqWjPiLLM0CbgswjnmSLM0pw4KYWtBsTSx(Wq4KYuafKoWKw2aqLonJuKcFCs6hlKonPityjDXKI(F2KUyszhm2lIsLmFFPpnUMaVlxsmscfSpwUEkOM1lQecp)yuY0BJl4xC2S35xuU5cmKehIzZC4qfFy4k7WqaxVH)yF66N1KPJybUGZkwIWx2HHaUEd)X(0Mmjb33zzfEfBV8HHWVdO4oW3CaOsNK5HJ0dHfszYYnes9g7CH0bM0sD4KcpastBHuyhGts)yH0bq60KImHL0fofaPPTqkSdWjPFSuj1YEajPph8(EsQdtkIX5KkGpB6tt6BMiFy0K6yszoGyshaPOdqiDzSNRK57l9PX1e4D5sIrsOG9XY1tb1SErLqyVH)XRrC5(MdaFlwUHCh4lSaMNNNnZHd9MjYhgDfX48Ra(SPpDfiOR34dcXCajZdhPhclKAzV8HHWjLPakiDGjTSbGkDskdBPjTNKuVjTuJZHhaQzKoas9M0cjzistAPgNtktMys6BXjMuVjTuJZHhaALmFFPpnUMaVlxsmscfSpwUEkOM1lQecBV8HHWVdO4oW3CaOsNM5WHoQ4ddxrmohEaO1pRjtbYceexJhVYCfX48BXeZGiZdhPhclKgDCs6at60iDFSqkFrxdH0e4D5sIjD64zsDysrk)THa82G0snoN0WkfFyysDmP7lDeIzKoasppFsxGqApjP5gLofoPENdPEwjZ3x6tJRjW7YLeJKqb7TX4DFPp9n640SErLqCuJBc8UCjXM5WHc8OCJsNv7FBiaVnUigNxLElIc3KjUu8HHR2)2qaEBCrmoV(zd6uGfFy4kIX5WdaT(znz6ntKpm6kIX5xb8ztF6kqqxVXhWCadImpCKgwbE)XKu4ngl2x5Kcpas)4TikK6PGIdqspewiDAsFZe5dJMuVjDaCbqAXzstG3LljP44KvY89L(04Ac8UCjXijuW(y56PGInZHdv8HHRigNdpa06N1KPIpmCLDyiGR3WFSpD9ZAY0BMiFy0veJZVc4ZM(0vGGUEJpG5acLqjeea]] )
    

end
