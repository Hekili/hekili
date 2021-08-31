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


    spec:RegisterPack( "Shadow", 20210831, [[diLoBcqivqpsq0LKiu0Mur(eeLgLa6ucKvPcj9kiIzrr5wqKk7ss)sGQHjaDmuPwgevptIGPHkPUMerBtGcFtfsmobaNdvsQ1jaAEcsUNGAFQa)tIqPdkqPfIkXdHOyIcsDrjczJQqQpIkjzKqKOtka0kPO6LseQAMcu0nHiPDQc1prLedvIuhvIqLLcrc9ukzQsuUQkeBvIKVki0yHivTxq(RknyshwPflHhRktgLltSzq9zkmAk1PPA1qKGxlr1Sf62qA3s9BfdhvDCbblh45qnDrxxvTDi8DuX4HiLZRIA9sekmFkY(rgIBOYGSyBkqhJ8aICUdyaOe4UgqU6sYnxZ1qw5zEbYIFFLVgcKvVOcKLL9Ygoqw8754SmOYGSWZh8eil7m5XbyWdUHN2)I6Bqdo2r)Xn9PFGfodo2rFbhYQ47Xma2qfqwSnfOJrEaro3bmaucCxdixDj5g5ihYA)P9aGSSCuKbYY2zmPHkGSyc(bzzzVSHdPLg4cojZd2VXhNKwcCBgPipGiNBYCYCKXEBdbhGK5iDKwghzlN0snoJ0Ygaq6Kuo2stAUadjj9n)oXKUaHu4b8ewLmhPJ0sdKuAgPSjXKUaH0ppPCSLM0CbgsIjDbcPV4GfsZHu2zVnmJu8qAAVjP9VCbt6cesXPhJKcK3GIkntyviROJtmuzqwmbE)XeQmOJ5gQmiR9L(0qwypk9tGSKElIcdIlqj0XihQmilP3IOWG4cK1d4Pa8fYQ4ddxrmodEaO1ppPMmrAXhgUYpCeW1B4p2NU(5HS2x6tdzXpPpnucDCjavgKL0BruyqCbYA4HSWsczTV0NgYcXc8Tikqwi24xGScKu2KvS9YgoxodGD5xVRP)k3BdsnzI0CbgswthvU5CzUqAOctkxtAqKEI0ajLnzfXIY7a)DZ5)SRP)k3BdsnzI0CbgswthvU5CzUqAOctAWG0GGSqSGBVOcKfBs89ZdLqhZ1qLbzj9wefgexGSgEilSKqw7l9PHSqSaFlIcKfIn(filelW3IOuztIVFEsprAGKYMSYeeZh4TXLpUgFPM(RCVni1KjsZfyiznDu5MZL5cPHkmPCnPbbzHyb3ErfiRngVSjX3ppucDCjHkdYs6TikmiUazn8qwyjHS2x6tdzHyb(wefileB8lqwyEjgV5cmKexr9MDXYci9asroPiH0IpmCfX4m4bGw)8qwmb)aoF6tdzzLlij9J92GulzbEBq6XUHDIUaH0njTeqcP5cmKet6aiLRrcPomPNNpPlqi1Bsl14m4bGczHyb3ErfilSSaVnUTByNOlqUVFoWWqj0XbdOYGSKElIcdIlqwdpKfwsiR9L(0qwiwGVfrbYcXg)cK1BMiB40veJZUc4ZN(01ppPNinqspKuW6SRGq6SUmgU(5j1KjsbRZUccPZ6Yy4k7d20NM0qfMuUdiPMmrkyD2vqiDwxgdxbc66nM0dctk3bKuKqAjj9OsAGKMBu6SA)Bdb4TXfX4SQ0BruyKAYePVbH0BN1Ypd8TjnisdI0tKgiPbskyD2vqiDwxgdx9M0dif5bKutMifZlX4nxGHK4kIXzxb85tFAspimPLK0Gi1KjsZnkDwT)THa824IyCwv6TikmsnzI03Gq6TZA5Nb(2KgePNinqspKuWVf4byivmVTae81EbOtFUkHW355fgPMmrAGK(MjYgoDLF4iGR3WFSpDfiOR3ysdvysnESk6I0i9OsAjqQjtKw8HHR8dhbC9g(J9PRFEsnzI0IbJj9ePWUHDEbc66nM0qfMuKxssdI0GGSyc(bC(0NgYczMjYgonPLEMiPLAb(wefZi9iyHrAoKYptK0cbEacP7lDeB6TbPigNbpa0kPiZhaKoJNj9JfgP5q6B6emrs5ylnP5q6(shXMcPigNbpaus54PnPE)guVniDzmCfYcXcU9Ikqw8ZeVWd4(yyOe64JcuzqwsVfrHbXfiRhWtb4lKvXhgUIyCg8aqRFEiR9L(0qwWoqkIZWGsOJdaqLbzj9wefgexGSEapfGVqwfFy4kIXzWdaT(5HS2x6tdzviaSak3BdOe6yUAOYGSKElIcdIlqw7l9PHSIUHDIVif(mduPtilMGFaNp9PHSocwiny6g2jYIj18pZav6KuhM00wacPlqif5KoasrhGqAUadjXMr6aiDzmmPlqAKnjfZVCAVnifEaKIoaH00EBspkLexHSEapfGVqwyEjgV5cmKexJUHDIVif(mduPtspimPiNutMinqspKuW6SRGq6SUmgUkinhNysnzIuW6SRGq6SUmgU6nPhq6rPKKgeucDm3beQmilP3IOWG4cK1d4Pa8fYQ4ddxrmodEaO1ppK1(sFAiRTFcobB8(2yekHoMBUHkdYs6TikmiUazTV0NgY6TX4DFPp9n64eYk6482lQaz948GsOJ5g5qLbzj9wefgexGS2x6tdzb(9DFPp9n64eYk6482lQazHUEdLqjKfd14MaVlxsmuzqhZnuzqwsVfrHbXfiRErfil2ckhDM(YKx53l)pbc(j9tGS2x6tdzXwq5OZ0xM8k)E5)jqWpPFcucDmYHkdYs6TikmiUaz1lQazH)DrCg2DrL0(moHS2x6tdzH)DrCg2DrL0(moHsOJlbOYGSKElIcdIlqw9IkqwgXZ823b(UySJ6Xn9PHS2x6tdzzepZBFh47IXoQh30NgkHoMRHkdYs6TikmiUaz1lQazXaYYGDGCriySeHS2x6tdzXaYYGDGCriySeHsOeYcD9gQmOJ5gQmilP3IOWG4cK1d4Pa8fYQ4ddxlMPVd8nTL7IFsZew9ZdzTV0NgY6TX4DFPp9n64eYk6482lQazvmtdLqhJCOYGSKElIcdIlqwpGNcWxiRdjnxGHKvhF5J7zbazTV0NgYI5yEjErxd)bLqhxcqLbzj9wefgexGS2x6tdzHyC2vaF(0NgYIj4hW5tFAiRJGfsl14mslrGpF6tt60K(MjYgonP8Ze92G0njnklojLRdiPEJ32ZZKw8ts7jj1Hj988jLJhJKoieWB5j1B82EEMuVjTuhDLuK6wUqk(desX2lB4a7sZcoQ3ScPzcG0TzKIu9MrkxIloj1XKonPVzISHttAHapaH0svIQKgan6biKYpt0Bdsbcob(l9PXK6WK(XEBqQL9YgoWXfviT0ahJs62ms5I0mbqQJjD(zfY6b8ua(czHyb(weLk)mXl8aUpgM0tKgiPEJ32ZZKEqys56asQjtKYlzf2LMv3x6iesprk43c8amKk2Ezdh44IkxEGJrRsi8DEEHr6jspK03mr2WPROEZUfXfN1ppPNi9qsFZezdNUITx2W5YzaSlt20U(5jnisprAGK6nEBpptAOctAaOKKAYeP5gLoRyzbEBCB3WorxGuLElIcJ0tKIyb(weLkwwG3g32nSt0fi33phyysdI0tKEiPVzISHtxHDPz1ppPNinqspK03mr2WPROEZUfXfN1ppPMmrkMxIXBUadjXvuVzxSSaspGuKtAqKEI0aj9qsXZpw4nRIyIB6r5INicPZQ0BruyKAYePfFy4kIjUPhLlEIiKoV2F0ThNv)8KgeucDmxdvgKL0BruyqCbYAFPpnKf2EzdNlNbWU8R3qwmb)aoF6tdzHu3YfsXFGq655tk)pj9ZtQvigGLM0G1kylnPttAAlKMlWqssDysdrWM2W)iPh9kaxi1XnYMKUV0riKYXwAsHDd70Bds5gPReinxGHK4kK1d4Pa8fYQ4ddxHx5A8xaZ3gx)8KEI0djLjfFy4khWM2W)4fEfGl1ppPNifZlX4nxGHK4kQ3SlwwaPHIuUgkHoUKqLbzj9wefgexGS2x6tdz92y8UV0N(gDCczfDCE7fvGSEmmucDCWaQmilP3IOWG4cK1(sFAiluVzxSSaiR35xuU5cmKedDm3qwpGNcWxiRCJsNvSSaVnUTByNOlqQsVfrHr6jsX8smEZfyijUI6n7ILfq6bKIyb(weLkQ3SlwwW99ZbgM0tKEiPSjRy7LnCUCga7YVExt)vU3gKEI0dj9ntKnC6kSlnR(5HSyc(bC(0NgYcP0nSjT0aFaEEMuKQ3msTKfq6(sFAsZHuGadeSnPHEkdtkhpTjfllWBJB7g2j6ceOe64JcuzqwsVfrHbXfiR9L(0qwSfT30NgY6D(fLBUadjXqhZnK1d4Pa8fY6qsrSaFlIsDJXlBs89ZdzXe8d48PpnKvPbcSainhs)yH0qVO9M(0KgSwbBPj1HjD7ZKg6PmsDmP9KK(5Rqj0XbaOYGSKElIcdIlqw7l9PHSW2lB4C5ma2LjBAdzXe8d48PpnK1rWcPw2lB4qAioagPHw20MuhM0p2BdsTSx2WboUOcPLg4yus3MrAH0mbqkhpgjvqA8oqiL9bEBqAAlK2cslj14XQqwpGNcWxilEjRWU0S6(shHq6jsb)wGhGHuX2lB4ahxu5YdCmAvcHVZZlmsprkVKvyxAwfiOR3ysdvysnEmOe6yUAOYGSKElIcdIlqw7l9PHSq9MDlIloHSyc(bC(0NgYkyJC2Zys)yHuuVzfXfNysDysFlpVWiDBgP2)2qaEBqkIXzK6ys)8KUnJ0p2BdsTSx2WboUOcPLg4yus3MrAH0mbqQJj9ZxjL0GLX80NEJXZMr6BXjPOEZkIloj1Hj988jLZ8Jmsles)9wefsZHudjjnTfsboCsAXzs5SE6TbPlPgpwfY6b8ua(czfiPVzISHtxr9MDlIloRp7fyiyspGuUj9ePbsktk(WWv7FBiaVnUigNv)8KAYePhsAUrPZQ9VneG3gxeJZQsVfrHrAqKAYeP8swHDPzvGGUEJjnuHj9T48MoQqksi14XinisprkVKvyxAwDFPJqi9ePGFlWdWqQy7LnCGJlQC5bogTkHW355fgPNiLxYkSlnRce01BmPhq6BX5nDubkHoM7acvgKL0BruyqCbYAFPpnKfIXz3IjMqwmb)aoF6tdzDeSqAPgNrkxMys6MKA7g2cGuEGpapptkhpTjfP83gcWBdsl14ms)8KMdPCnP5cmKeBgPdG0jTfaP5gLoXKonPwLvHSEapfGVqwEJ32ZZKgQWKgakjPNin3O0z1(3gcWBJlIXzvP3IOWi9eP5gLoRyzbEBCB3WorxGuLElIcJ0tKI5Ly8MlWqsCf1B2fllG0qfM0GbPMmrAGKgiP5gLoR2)2qaEBCrmoRk9wefgPNi9qsZnkDwXYc8242UHDIUaPk9wefgPbrQjtKI5Ly8MlWqsCf1B2fllG0WKYnPbbLqhZn3qLbzj9wefgexGS2x6tdzXeeZh4TXLpUgFbYIj4hW5tFAiRqpnYMK(XcPHwqmFG3gKw64A8fsDysppFsFBtQHKK6DoKwQXzWdaLuVXPSmZiDaK6WKAjlWBdsp2nSt0fiK6ysZnkDkms3Mrkhpgj12tsLE(g2KMlWqsCfY6b8ua(czfiPabgiy7TikKAYePEJ32ZZKEaPhLssAqKEI0aj9qsrSaFlIsLFM4fEa3hdtQjtK6nEBppt6bHjnaussdI0tKgiPhsAUrPZkwwG3g32nSt0fivP3IOWi1KjsdK0CJsNvSSaVnUTByNOlqQsVfrHr6jspKuelW3IOuXYc8242UHDIUa5((5adtAqKgeucDm3ihQmilP3IOWG4cK1(sFAileJZUftmHSyc(bC(0NgY6iyH0sXfsNMuKj0K6WKEE(KYMgztsBryKMdPVfNKgAbX8bEBqAPJRXxmJ0TzKM2cqiDbcPrbJjnT3MuUM0CbgsIjD(jPbwss54PnPVPzFpdQcz9aEkaFHSW8smEZfyijUI6n7ILfqAOinqs5AsrcPVPzFpRmhJNE78kp7rWvP3IOWinisprQ34T98mPHkmPbGss6jsZnkDwXYc8242UHDIUaPk9wefgPMmr6HKMBu6SILf4TXTDd7eDbsv6TikmOe6yUlbOYGSKElIcdIlqw7l9PHSW2lB4C5ma2LjBAdz9o)IYnxGHKyOJ5gY6b8ua(czfiP5cmKSAlBmTR8VK0qrkYdiPNifZlX4nxGHK4kQ3SlwwaPHIuUM0Gi1KjsdKuEjRWU0S6(shHq6jsb)wGhGHuX2lB4ahxu5YdCmAvcHVZZlmsdcYIj4hW5tFAiRJGfsTSx2WH0qCaSaK0qlBAtQdtAAlKMlWqssDmPBX8tsZHuMlKoasppFsTxecPw2lB4ahxuH0sdCmkPsi8DEEHrkhpTjfP6nRqAMaiDaKAzVSHdSlnJ09LocPcLqhZnxdvgKL0BruyqCbYAFPpnKf(dasZeWnNl6YAbJHSENFr5MlWqsm0XCdz9aEkaFHSYfyiznDu5MZL5cPHIuKxssprAXhgUIyCg8aqRSHtdzXe8d48PpnK1rWcPwFaqAMainhsrQlRfmM0PjDjnxGHKKM2BsQJj1y82G0CiL5cPBsAAlKcCd7K00rLkucDm3LeQmilP3IOWG4cK1(sFAileJZU5aasNqwVZVOCZfyijg6yUHSEapfGVqwiwGVfrPYMeF)8KEI0CbgswthvU5CzUq6bKwcKEI0ajT4ddxrmodEaOv2WPj1Kjsl(WWveJZGhaAfiOR3ysdfPVzISHtxrmo7wmXSce01BmPbr6js3x6iKlBYkIfL3b(7MZ)zt6bHj9D(fLR0cQlysprkMxIXBUadjXvuVzxSSasdfPbsAjjfjKgiPbdspQKMBu6SMCCCEh4l8Msv6TikmsdI0GGSyc(bC(0NgY6iyH0snoJ0Ygaq6K0PJNj1Hj1kedWst62mslvzKUaH09LocH0TzKM2cP5cmKKuotJSjPmxiL9bEBqAAlK(S3ULyfkHoM7GbuzqwsVfrHbXfiRhWtb4lKfBYkIfL3b(7MZ)zxt)vU3gKEI0ajn3O0zfllWBJB7g2j6cKQ0BruyKEIumVeJ3CbgsIROEZUyzbKEaPiwGVfrPI6n7ILfCF)CGHj1KjsztwX2lB4C5ma2LF9UM(RCVninisprAGKEiPGFlWdWqQy7LnCGJlQC5bogTkHW355fgPMmr6(shHCztwrSO8oWF3C(pBspimPVZVOCLwqDbtAqqw7l9PHSq9Mvintaqj0XCFuGkdYs6TikmiUazTV0NgYcBVSHZLZayxMSPnKftWpGZN(0qwhblKAfIbyOjLJN2Kw617cGSLlaslnEJOK(7OGXKM2cP5cmKKuoEmsAHqAHehoKI8awIjPfc8aestBH03mr2WPj9nOcM0I9vEfY6b8ua(czb(TapadPYVExaKTCbC5XBeTkHW355fgPNifXc8Tikv2K47NN0tKMlWqYA6OYnNl)lVipGKEaPbs6BMiB40vS9YgoxodGDzYM2v2hSPpnPiHuJhJ0GGsOJ5oaavgKL0BruyqCbYAFPpnKf2EzdN7dSyBilMGFaNp9PHSocwi1YEzdhsrgWITjDAsrMqt6VJcgtAAlaH0fiKUmgMuVFdQ3gviRhWtb4lKfyD2vqiDwxgdx9M0diL7acLqhZnxnuzqwsVfrHbXfiRhWtb4lKfMxIXBUadjXvuVzxSSaspGuelW3IOur9MDXYcUVFoWWKEI0IpmCLTGYVP98nSZ6NhYIj4hW5tFAiRJGfsrQEZi1swaP5q6BA8hvin0lOCslZE(g2jMuEW8WKonPblxPevjTmUsO5kKImtd7ausDmPPTJj1XKUKA7g2cGuEGpapptAAVnPaHnz6TbPttAWYvkrK(7OGXKYwq5KM2Z3WoXK6ys3I5NKMdPPJkKo)eY6D(fLBUadjXqhZnKL3PaaF(86WqwP)khFqyKdz5DkaWNpVokQW8nfilUHSE2R3qwCdzTV0NgYc1B2fllakHog5beQmilP3IOWG4cKftWpGZN(0qwhblKIu9Mr6rh3ZKMdPVPXFuH0qVGYjTm75ByNys5bZdt60KAvwL0Y4kHMRqkYmnSdqj1HjnTDmPoM0LuB3WwaKYd8b45zst7TjfiSjtVni93rbJjLTGYjnTNVHDIj1XKUfZpjnhsthviD(jK1d4Pa8fYQ4ddxzlO8BApFd7S(5j9ePiwGVfrPYMeF)8qwENca85ZRddzL(RC8bHr(P3mr2WPRigNDlMyw)8qwENca85ZRJIkmFtbYIBiRN96nKf3qw7l9PHSq9MDHJ7zOe6yKZnuzqwsVfrHbXfiR9L(0qwOEZUfXfNqwmb)aoF6tdzDeSqks1BgPCjU4KuhM0ZZNu20iBsAlcJ0CifiWabBtAONYWvsTYHN03ItVniDts5AshaPOdqinxGHKys54PnPwYc82G0JDd7eDbcP5gLofgPBZi988jDbcP9KK(XEBqQL9YgoWXfviT0ahJs6aiT04ZpB)rAW07YRyEjgV5cmKexr9MDXYcoOeBjj1qsmPPTqkQ3o6hL0bM0ss62mstBH0(JwiashysZfyijUsAWgXJzKYgs7jjLhiymPOEZkIloj93PhjDJrsZfyijM0fiKYMmfgPC80M0svgPCSLM0p2BdsX2lB4ahxuHuEGJrj1HjTqAMai1XKUiwpUfrPcz9aEkaFHSqSaFlIsLnj((5j9ePG1zxbH0zfDqiOsNvVj9asFloVPJkKIesdyTKKEIumVeJ3CbgsIROEZUyzbKgksdKuUMuKqkYj9OsAUrPZkQJfW5Q0BruyKIes3x6iKlBYkIfL3b(7MZ)zt6rL0CJsNvE85NT)UrVlVk9wefgPiH0ajfZlX4nxGHK4kQ3SlwwaPhuIL0ssAqKEujnqs5LSc7sZQ7lDecPNif8BbEagsfBVSHdCCrLlpWXOvje(opVWinisdI0tKgiPhsk43c8amKk2Ezdh44IkxEGJrRsi8DEEHrQjtKEiPVzISHtxHDPz1ppPNif8BbEagsfBVSHdCCrLlpWXOvje(opVWi1Kjs3x6iKlBYkIfL3b(7MZ)zt6bHj9D(fLR0cQlysdckHog5ihQmilP3IOWG4cK1(sFAilelkVd83nN)ZgY6b8ua(czbeyGGT3IOq6jsZfyiznDu5MZL5cPhqAWGutMinqsZnkDwrDSaoxLElIcJ0tKYMSITx2W5YzaSl)6DfiWabBVfrH0Gi1Kjsl(WW1Fd)brVnUSfuElyC9Zdz9o)IYnxGHKyOJ5gkHog5LauzqwsVfrHbXfiR9L(0qwy7LnCUCga7YVEdzXe8d48PpnKLfV88ns6BAMN(0KMdP4C4j9T40BdsTcXaS0KonPdmmsxUadjXKYXwAsHDd70BdslbshaPOdqifN7RCHrk6uGjDBgPFS3gKwA85NT)iny6D5KUnJ0J5kLrks1Xc4CfY6b8ua(czbeyGGT3IOq6jsZfyiznDu5MZL5cPhqkxt6jspK0CJsNvuhlGZvP3IOWi9eP5gLoR84ZpB)DJExEv6TikmsprkMxIXBUadjXvuVzxSSaspGuKdLqhJCUgQmilP3IOWG4cK1(sFAilS9YgoxodGD5xVHSENFr5MlWqsm0XCdz9aEkaFHSacmqW2Brui9eP5cmKSMoQCZ5YCH0diLRj9ePhsAUrPZkQJfW5Q0BruyKEI0djnqsZnkDwXYc8242UHDIUaPk9wefgPNifZlX4nxGHK4kQ3SlwwaPhqkIf4BruQOEZUyzb33phyysdI0tKgiPhsAUrPZkp(8Z2F3O3LxLElIcJutMinqsZnkDw5XNF2(7g9U8Q0BruyKEIumVeJ3CbgsIROEZUyzbKgQWKICsdI0GGSyc(bC(0NgYQeVi8KAfIbyPj9Zt60KUysr3(mP5cmKet6IjLFWyVikMrQG0EcFskhBPjf2nStVniTeiDaKIoaHuCUVYfgPOtbMuoEAtAPXNF2(J0GP3LxHsOJrEjHkdYs6TikmiUazTV0NgYc1B2fllaY6D(fLBUadjXqhZnKL3PaaF(86WqwP)khFqyKdz5DkaWNpVokQW8nfilUHSEapfGVqwyEjgV5cmKexr9MDXYci9asrSaFlIsf1B2fll4((5adt6jsdK0djfp)yH3SkIjUPhLlEIiKoRsVfrHrQjtKEiPVzISHtxHJc2(bw4S(5jniiRN96nKf3qj0XipyavgKL0BruyqCbYAFPpnKfQ3SlCCpdz5DkaWNpVomKv6VYXheg5Nc8WIpmCLTGYVP98nSZ6N3KP3mr2WPRigNDlMyw)8bbz5DkaWNpVokQW8nfilUHSE2R3qwCdz9aEkaFHSoKu88JfEZQiM4MEuU4jIq6Sk9wefgPMmr6HK(MjYgoDfoky7hyHZ6NhkHog5hfOYGSKElIcdIlqw7l9PHSGJc2(bw4eYY7uaGpFEDyiR0FLJpim3qwENca85ZRJIkmFtbYIBiRhWtb4lKfE(XcVzvetCtpkx8eriDwLElIcJ0tKEiPfFy4kIXzWdaT(5j9ePhsAXhgUYpCeW1B4p2NU(5HSyc(bC(0NgY6iyH0Joky7hyHtsNFIDMq6atk66nPVzISHtJjnhsrxVZ1Bsl1e30JcPwteH0jPfFy4kucDmYdaqLbzj9wefgexGSyc(bC(0NgY6iyHuRqmadnPlM04ItsbcEajPomPttAAlKIoieiR9L(0qwy7LnCUCga7YKnTHsOJroxnuzqwsVfrHbXfilMGFaNp9PHSocwi1kedWst6IjnU4KuGGhqsQdt60KM2cPOdcH0TzKAfIbyOj1XKonPitOHS2x6tdzHTx2W5YzaSl)6nucLqw8a5nOfBcvg0XCdvgKL0BruyqCbY6b8ua(czbe01BmPHI0siGbeYAFPpnKf)WraxodGDHhq65Njqj0XihQmilP3IOWG4cK1d4Pa8fYcp)yH3Sk)hN)OCfWNp9PRsVfrHrQjtKINFSWBwfXe30JYfpresNvP3IOWGS2x6tdzbhfS9dSWjucDCjavgKL0BruyqCbY6b8ua(czDiPfFy4k2Ezdh4bGw)8qw7l9PHSW2lB4apauOe6yUgQmilP3IOWG4cK1d4Pa8fYYB82EEUYey)5jPhqk3LeYAFPpnK1cEBl3CaaPtOe64scvgKL0BruyqCbYQxubYcBVSHJWUdO4oW3CaOsNqw7l9PHSW2lB4iS7akUd8nhaQ0jucDCWaQmilP3IOWG4cK1WdzHLeYAFPpnKfIf4BruGSqSXVazHCilel42lQazH6n7ILfCF)CGHHsOJpkqLbzTV0NgYcXIY7a)DZ5)SHSKElIcdIlqjucz9yyOYGoMBOYGSKElIcdIlqw7l9PHS4hoc46n8h7tdzXe8d48PpnK1rWcPLE4iasdGn8h7ttkhpTjTuJZGhaALuKYjYifEaKwQXzWdaL03GkyshyysFZezdNMuVjnTfsBbPLKYDajflVPzysN0waCCSq6hlKonPpgP)okymPPTqkFCplasDmP8lijDGjnTfsl)mW3M03Gq6TtZiDaK6WKM2cqiLJhJK2tsAHq62tAlasl14mslrGpF6ttAA7ysHDd7SsAWMPGYNKMdP4Z9J00winU4Ku(HJai1B4p2NM0bM00wif2nStsZHueJZivaF(0NMu4bqApnPL4pd8TXviRhWtb4lKfpWfCwXse(YpCeW1B4p2NM0tKgiPfFy4kIXzWdaT(5j1KjspK03Gq6TZA5Nb(2KEI0dj9niKE7S2YdmXbWi9ePVzISHtxrmo7kGpF6txbc66nM0dctk3bKutMif2nSZlqqxVXKgksFZezdNUIyC2vaF(0NUce01BmPbr6jsdKuy3WoVabD9gt6bHj9ntKnC6kIXzxb85tF6kqqxVXKIes5UKKEI03mr2WPRigNDfWNp9PRabD9gtAOctQXJr6rLuUMutMif2nSZlqqxVXKEaPVzISHtx5hoc46n8h7txzFWM(0KAYePfdgt6jsHDd78ce01BmPHI03mr2WPRigNDfWNp9PRabD9gtksiL7ssQjtK(gesVDwl)mW3MutMiT4ddxlIZWIFCw)8KgeucDmYHkdYs6TikmiUazXe8d48PpnK1rWcPCzzgcPEJDMq6atAPoAsHhaPPTqkSdWjPFSq6aiDAsrMqt6cNcG00wif2b4K0pwQKgIEAt6XUHDs6rVcP2tKrk8aiTuhDfYQxubYc7n8pEnIlZ3Ca4BXYmK7aFHfW888mK1d4Pa8fYQ4ddxrmodEaO1ppPMmrA6OcPhqk3bK0tKgiPhs6Bqi92zTDd78cVcPbbzTV0NgYc7n8pEnIlZ3Ca4BXYmK7aFHfW888mucDCjavgKL0BruyqCbYAFPpnKf8kxJ)cy(2yilMGFaNp9PHSocwi9OxHuUQ)cy(2ysNMuKj0Ko)e7mH0bM0snodEaOvspcwi9OxHuUQ)cy(2mmPEtAPgNbpausDysppFsTxecPIN2cGuUkWGqina2iCJbSPpnPdG0J2LiJ0bMuUehmEqXvsdX1tsHhaPSjXKMdPfcPFEsle4biKUV0rSP3gKE0Rqkx1FbmFBmP5qk6I0CuhlKM2cPfFy4kK1d4Pa8fY6qsl(WWveJZGhaA9Zt6jsdK0dj9ntKnC6kIXz3CaaPZ6NNutMi9qsZnkDwrmo7MdaiDwLElIcJ0Gi9ePbskIf4BruQSjX3ppPNifZlX4nxGHK4kIfL3b(7MZ)ztAys5MutMiDFPJqUSjRiwuEh4VBo)NnPHjfZlX4nxGHK4kIfL3b(7MZ)zt6jsX8smEZfyijUIyr5DG)U58F2KEaPCtAqKAYePfFy4kIXzWdaT(5j9ePbskE(XcVzvdWGqUEJWngWM(0vP3IOWi1KjsXZpw4nRc7sKDh4BrCW4bfxLElIcJ0GGsOJ5AOYGSKElIcdIlqw7l9PHSq9MzSOcgY6D(fLBUadjXqhZnK1d4Pa8fYYB82EEM0qrkxDaj9ePbsAGKIyb(weL6gJx2K47NN0tKgiPhs6BMiB40veJZUc4ZN(01ppPMmr6HKMBu6SA)Bdb4TXfX4SQ0BruyKgePbrQjtKw8HHRigNbpa06NN0Gi9ePbs6HKMBu6SA)Bdb4TXfX4SQ0BruyKAYePmP4ddxT)THa824IyCwfiOR3yspG03IZB6OcPMmr6HKw8HHRigNbpa06NN0Gi9ePbs6HKMBu6SILf4TXTDd7eDbsv6TikmsnzIumVeJ3CbgsIROEZUyzbKgksljPbbzXe8d48PpnK1rWcPivVzglQGjLJT0KUXiPLaPHEkdt6ces)8Mr6ai988jDbcPEtAPgNbpa0kPLOg)bcPiL)2qaEBqAPgNrkhpgjfNEmsAHq6NNuo2stAAlK(wCsA6OcPWE7yBbxj1khEs)yVniDtsljsinxGHKys54PnPwYc82G0JDd7eDbsfkHoUKqLbzj9wefgexGS2x6tdz9B7jE(2dIfYIj4hW5tFAiRJGfspsBpXZKE8GyjDAsrMqBgP2tK5TbPfaxGJNjnhs5SEsk8aiLF4ias9g(J9PjDaKUmgPy(LtJRqwpGNcWxiRajnqspKuW6SRGq6SUmgU(5j9ePG1zxbH0zDzmC1BspGuKhqsdIutMifSo7kiKoRlJHRabD9gt6bHjL7ssQjtKcwNDfesN1LXWv2hSPpnPHIuUljPbr6jsdK0djn3O0z1(3gcWBJlIXzvP3IOWi1KjszsXhgUA)Bdb4TXfX4S6NNutMinqsFZezdNUIyC2vaF(0NUce01BmPhqk3bKutMi9qsrSaFlIsLFM4fEa3hdtAqKEI0djT4ddxrmodEaO1ppPbbLqhhmGkdYs6TikmiUazTV0NgYQyM(oW30wUl(jntyqwmb)aoF6tdzDeSq60KImHM0IFskpWhGNowi9J92G0snoJ0se4ZN(0Kc7aCAgPomPFSWi1BSZeshysl1rt60KAvgPFSq6cNcG0LueJZkMysk8ai9ntKnCAsfyy)5s)ot62msHhaP2)2qaEBqkIXzK(5thvi1Hjn3O0PWQqwpGNcWxiRdjT4ddxrmodEaO1ppPNi9qsFZezdNUIyC2vaF(0NU(5j9ePyEjgV5cmKexr9MDXYci9as5M0tKEiP5gLoRyzbEBCB3WorxGuLElIcJutMinqsl(WWveJZGhaA9Zt6jsX8smEZfyijUI6n7ILfqAOif5KEI0djn3O0zfllWBJB7g2j6cKQ0BruyKEI0ajLhiiUgpwL7kIXz3IjMKEI0aj9qsLq4788cRkO8NbYgVdG1B)esnzI0djn3O0z1(3gcWBJlIXzvP3IOWinisnzIuje(opVWQck)zGSX7ay92pH0tK(MjYgoDvq5pdKnEhaR3(jvGGUEJjnuHjL7GbYj9ePmP4ddxT)THa824IyCw9ZtAqKgePMmrAGKw8HHRigNbpa06NN0tKMBu6SILf4TXTDd7eDbsv6TikmsdckHo(OavgKL0BruyqCbYAFPpnK1BJX7(sF6B0XjKv0X5TxubYkbExUKyOekHSsG3LljgQmOJ5gQmilP3IOWG4cKftWpGZN(0qwhblKonPitOjnyTc2stAoKAijPHEkJ00FL7TbPBZivqA8oqinhsJElK(5jTqYuaKYXtBsl14m4bGcz1lQazjO8NbYgVdG1B)eiRhWtb4lK1BMiB40veJZUc4ZN(0vGGUEJjnuHjLBKtQjtK(MjYgoDfX4SRa(8PpDfiOR3yspGuKFuGS2x6tdzjO8NbYgVdG1B)eOe6yKdvgKL0BruyqCbYIj4hW5tFAiRYaNjnhsTo3psdGL4cnPC80M0qp)IOqQvUVYfgPitOXK6WKYpySxeLkPCLM040gcGuy3WoXKYXtBsrhGqAaSexOj9JfmPBMckFsAoKIp3ps54PnPBFM0hJ0bqksHpoj9Jfs9Scz1lQaz5n(b(5weLBi83o)OxMGWFcK1d4Pa8fYQ4ddxrmodEaO1ppPNiT4ddx5hoc46n8h7tx)8KAYePfdgt6jsHDd78ce01BmPHkmPipGKAYePfFy4k)WraxVH)yF66NN0tK(MjYgoDfX4SRa(8PpDfiOR3ysrcPCxsspGuy3WoVabD9gtQjtKw8HHRigNbpa06NN0tK(MjYgoDLF4iGR3WFSpDfiOR3ysrcPCxsspGuy3WoVabD9gtQjtKgiPVzISHtx5hoc46n8h7txbc66nM0dctk3bK0tK(MjYgoDfX4SRa(8PpDfiOR3yspimPChqsdI0tKc7g25fiOR3yspimPCZvhqiR9L(0qwEJFGFUfr5gc)TZp6Lji8NaLqhxcqLbzj9wefgexGSyc(bC(0NgYY6C)i1YwKKuK6h7ps54PnPLACg8aqHS6fvGSq33waKl2wK8I(X(dY6b8ua(cz9MjYgoDfX4SRa(8PpDfiOR3yspGuUdiK1(sFAil09Tfa5ITfjVOFS)GsOJ5AOYGSKElIcdIlqw9Ikqw45hJsMEBCb)IZqwVZVOCZfyijg6yUHS2x6tdzHNFmkz6TXf8lodz9aEkaFHSk(WWv(HJaUEd)X(01ppPMmr6HKYdCbNvSeHV8dhbC9g(J9Pj1KjsLq4788cRITx2Wry3buCh4BoauPtilMGFaNp9PHSSo3psrk(lotkhpTjT0dhbqAaSH)yFAs)41qmJu0TCHu8hiKMdP425fstBH04WrWjPiLLM0CbgswjneTLM0pwyKYXtBsTSx2WryKYvafKoWKw2aqLonJuKcFCs6hlKonPitOjDXKI(F2KUys5hm2lIsfkHoUKqLbzj9wefgexGSyc(bC(0NgY6iyHuUSmdHuVXotiDGjTuhnPWdG00wif2b4K0pwiDaKonPitOjDHtbqAAlKc7aCs6hlvsTShqs6ZbVVNK6WKIyCgPc4ZN(0K(MjYgonPoMuUdiM0bqk6aesxo75kKvVOcKf2B4F8AexMV5aW3ILzi3b(clG555ziRhWtb4lK1BMiB40veJZUc4ZN(0vGGUEJj9GWKYDaHS2x6tdzH9g(hVgXL5Boa8TyzgYDGVWcyEEEgkHooyavgKL0BruyqCbYIj4hW5tFAiRJGfsTSx2WryKYvafKoWKw2aqLojLJT0K2tsQ3KwQXzWda1mshaPEtAHKCePjTuJZiLltmj9T4etQ3KwQXzWdaTcz1lQazHTx2Wry3buCh4BoauPtiRhWtb4lK1HKw8HHRigNbpa06NNutMinqs5bcIRXJv5UIyC2TyIjPbbzTV0NgYcBVSHJWUdO4oW3CaOsNqj0XhfOYGSKElIcdIlqwmb)aoF6tdzDeSqA0XjPdmPtJ09XcPSfDnestG3LljM0PJNj1HjfP83gcWBdsl14msdTu8HHj1XKUV0riMr6ai988jDbcP9KKMBu6uyK6DoK6zfYAFPpnK1BJX7(sF6B0XjK1d4Pa8fYkqspK0CJsNv7FBiaVnUigNvLElIcJutMiLjfFy4Q9VneG3gxeJZQFEsdI0tKgiPfFy4kIXzWdaT(5j1KjsFZezdNUIyC2vaF(0NUce01BmPhqk3bK0GGSIooV9IkqwmuJBc8UCjXqj0XbaOYGSKElIcdIlqw7l9PHS(y56PGIHSyc(bC(0NgYk0c8(JjPWBmwSVYjfEaK(XBrui1tbfhGKEeSq60K(MjYgonPEt6aycG0IZKMaVlxssXXjRqwpGNcWxiRIpmCfX4m4bGw)8KAYePfFy4k)WraxVH)yF66NNutMi9ntKnC6kIXzxb85tF6kqqxVXKEaPChqOekHSkMPHkd6yUHkdYs6TikmiUaz9aEkaFHSW8smEZfyijUI6n7ILfqAOctAjazTV0NgYAXpPzc7wexCcLqhJCOYGSKElIcdIlqw7l9PHSw8tAMWU9GyHSyc(bC(0NgYIR0XZK(XcPbl(jntyKE8GyjLJT0K2tsAUrPtHrQ35qQLSaVni9y3WorxGq60KICKqAUadjXviRhWtb4lKfMxIXBUadjX1f)KMjSBpiwspGuUj9ePyEjgV5cmKexr9MDXYci9as5M0tKEiP5gLoRyzbEBCB3WorxGuLElIcdkHsiRhNhuzqhZnuzqwsVfrHbXfiRpwUCS9OCFlo92a6yUHS2x6tdzHLf4TXTDd7eDbcK178lk3CbgsIHoMBiRhWtb4lKvGKIyb(weLkwwG3g32nSt0fi33phyyspr6HKIyb(weLk)mXl8aUpgM0Gi1KjsdKu2KvS9YgoxodGD5xVRabgiy7TikKEIumVeJ3CbgsIROEZUyzbKEaPCtAqqwmb)aoF6tdzDeSqQLSaVni9y3WorxGqQdt655tkhpgj12tsLE(g2KMlWqsmPBZiT0dhbqAaSH)yFAs3MrAPgNbpausxGqApjPazzNnJ0bqAoKceyGGTj1kedWst60KMCgshaPOdqinxGHK4kucDmYHkdYs6TikmiUaz9XYLJThL7BXP3gqhZnK1(sFAilSSaVnUTByNOlqGSENFr5MlWqsm0XCdz9aEkaFHSYnkDwXYc8242UHDIUaPk9wefgPNiLnzfBVSHZLZayx(17kqGbc2ElIcPNifZlX4nxGHK4kQ3SlwwaPhqkYHSyc(bC(0NgYYYEajPiJdEFpj1swG3gKESByNOlqi9nnZtFAsZH0YfHNuRqmalnPFEs9M0GDkrqj0XLauzqwsVfrHbXfiRPJNVpopilUHS2x6tdzH6n7wexCczXe8d48PpnK10XZ3hNhPOB5cM00wiDFPpnPthpt6hVfrHu2h4TbPp7TBj6TbPBZiTNK0ft6skqm(Xfq6(sF6kucLqjKfcbG9PHog5be5ChWaa3bailolO92adzfIblsXJdGhZvfGKsAz2cPok)assHhaPilpqEdAXMilPaje(oqyKIhuH09Nd6McJ0N92gcUsMhm9wif5biPiZ0ieqkmsrw88JfEZQi9ilP5qkYINFSWBwfPVk9wefgYsAGCJ0cQsMhm9wif5biPiZ0ieqkmsrw88JfEZQi9ilP5qkYINFSWBwfPVk9wefgYs6MKwI4kbtsdKBKwqvYCY8qmyrkECa8yUQaKuslZwi1r5hqsk8aifzrxVrwsbsi8DGWifpOcP7ph0nfgPp7TneCLmpy6TqAjeGKImtJqaPWifzXZpw4nRI0JSKMdPilE(XcVzvK(Q0BruyilPbYnslOkzEW0BHuKxYaKuKzAecifgPilE(XcVzvKEKL0CifzXZpw4nRI0xLElIcdzjnqUrAbvjZdMElKI8GraskYmncbKcJuKfp)yH3SkspYsAoKIS45hl8Mvr6RsVfrHHSKgi3iTGQK5btVfsr(rjajfzMgHasHrkYINFSWBwfPhzjnhsrw88JfEZQi9vP3IOWqwsdKBKwqvYCY8qmyrkECa8yUQaKuslZwi1r5hqsk8aifzFmmYskqcHVdegP4bviD)5GUPWi9zVTHGRK5btVfsdgbiPiZ0ieqkmsr2e4D5sw3Ix9ntKnCAKL0CifzFZezdNUUfpKL0a5gPfuLmNmpaIYpGuyKgaiDFPpnPrhN4kzoKfMxEqhJ8sgaGS4bdShfiRqgssTSx2WH0sdCbNK5HmKKgSFJpojTe42msrEaro3K5K5HmKKIm2BBi4aKmpKHKuKoslJJSLtAPgNrAzdaiDskhBPjnxGHKK(MFNysxGqk8aEcRsMhYqskshPLgiP0msztIjDbcPFEs5ylnP5cmKet6cesFXblKMdPSZEBygP4H00Ets7F5cM0fiKItpgjfiVbfvAMWQK5K5HmKKwIqAY7NcJ0cbEacPVbTytsledVXvsd23t4tmP90iD2laf(hjDFPpnM0PJNRK57l9PXvEG8g0Inrs4GZpCeWLZayx4bKE(zIzoCyGGUEJdvjeWasMVV0Ngx5bYBql2ejHdoCuW2pWcNM5WHXZpw4nRY)X5pkxb85tFAtMWZpw4nRIyIB6r5INicPtY89L(04kpqEdAXMijCWX2lB4apauZC4Whw8HHRy7LnCGhaA9ZtMVV0Ngx5bYBql2ejHd(cEBl3CaaPtZC4WEJ32ZZvMa7pppG7ssMVV0Ngx5bYBql2ejHd(hlxpfuZ6fvcJTx2Wry3buCh4BoauPtY89L(04kpqEdAXMijCWrSaFlIIz9IkHr9MDXYcUVFoWWMn8HXsAgIn(LWiNmFFPpnUYdK3GwSjschCelkVd83nN)ZMmNmpKHK0spPpnMmFFPpnom2Js)eY89L(04W8t6tBMdhU4ddxrmodEaO1pVjtfFy4k)WraxVH)yF66NNmFFPpngjHdoIf4BrumRxujmBs89ZB2WhglPzi24xchiBYk2EzdNlNbWU8R310FL7THjt5cmKSMoQCZ5YCjuH56GofiBYkIfL3b(7MZ)zxt)vU3gMmLlWqYA6OYnNlZLqfoyeez((sFAmschCelW3IOywVOs4ngVSjX3pVzdFySKMHyJFjmIf4BruQSjX3p)PaztwzcI5d824YhxJVut)vU3gMmLlWqYA6OYnNlZLqfMRdImpKKALlij9J92GulzbEBq6XUHDIUaH0njTeqcP5cmKet6aiLRrcPomPNNpPlqi1Bsl14m4bGsMVV0NgJKWbhXc8TikM1lQegllWBJB7g2j6cK77NdmSzdFySKMHyJFjmMxIXBUadjXvuVzxSSGdqosk(WWveJZGhaA9ZtMhssrMzISHttAPNjsAPwGVfrXmspcwyKMdP8ZejTqGhGq6(shXMEBqkIXzWdaTskY8baPZ4zs)yHrAoK(MobtKuo2stAoKUV0rSPqkIXzWdaLuoEAtQ3Vb1BdsxgdxjZ3x6tJrs4GJyb(wefZ6fvcZpt8cpG7JHnB4dJL0meB8lHFZezdNUIyC2vaF(0NU(5pf4HG1zxbH0zDzmC9ZBYeyD2vqiDwxgdxzFWM(0Hkm3b0KjW6SRGq6SUmgUce01B8bH5oGiPKh1aZnkDwT)THa824IyCwv6TikmtMEdcP3oRLFg4BhuqNcmqW6SRGq6SUmgU69bipGMmH5Ly8MlWqsCfX4SRa(8Pp9bHlzqMmLBu6SA)Bdb4TXfX4SQ0BruyMm9gesVDwl)mW3oOtbEi43c8amKkM3wac(AVa0PpxLq4788cZKPaFZezdNUYpCeW1B4p2NUce01BCOcB8yv0fPDulbtMk(WWv(HJaUEd)X(01pVjtfdgFc2nSZlqqxVXHkmYlzqbrMhYqsksrje(oqWKc)bPTaifiiCHtaskPL5OEBqkYeAmPWdG0JLhyIdGrAXIfgPttkSByNKgL2iTjDBgPPJkKce01BVnmJuEWuSfXZKMZqkIjUPhfsHhaPEJ0zSOsLmpKHK09L(0yKeo4iwGVfrXSErLW8ZeVWd4(yyZg(WyjndXg)s43mr2WPRigNDfWNp9PRF(tbEiyD2vqiDwxgdx)8MmbwNDfesN1LXWv2hSPpDOcZDanzcSo7kiKoRlJHRabD9gFqyUdisk5rnWCJsNv7FBiaVnUigNvLElIcZKP3Gq6TZA5Nb(2bf0PadeSo7kiKoRlJHREFaYdOjtyEjgV5cmKexrmo7kGpF6tFq4sgKjt5gLoR2)2qaEBCrmoRk9wefMjtVbH0BN1Ypd8Td6uGhc(TapadPI5TfGGV2laD6Zvje(opVWof4HVbH0BN1wEGjoaMjtbgiSByNxGGUEJrs6OsqheUekHaEkDujuHrEadOjtbc7g25fiOR3yKKoQeuOcJ8sgWtbc7g25fiOR3yKKoQe0bHrEadyqbzY0BMiB40v(HJaUEd)X(0vGGUEJdvyJhRIUiTJAjyYuXhgUYpCeW1B4p2NU(5nzc2nSZlqqxVXHkmYlzqK57l9PXijCWHDGueNHzMdhU4ddxrmodEaO1ppz((sFAmsch8cbGfq5EByMdhU4ddxrmodEaO1ppzEij9iyH0GPByNilMuZ)mduPtsDystBbiKUaHuKt6aifDacP5cmKeBgPdG0LXWKUaPr2Kum)YP92Gu4bqk6aest7Tj9OusCLmFFPpngjHdE0nSt8fPWNzGkDAMdhgZlX4nxGHK4A0nSt8fPWNzGkDEqyKBYuGhcwNDfesN1LXWvbP54eBYeyD2vqiDwxgdx9(GJsjdImFFPpngjHd(2pbNGnEFBmAMdhU4ddxrmodEaO1ppz((sFAmsch83gJ39L(03OJtZ6fvc)48iZ3x6tJrs4Gd(9DFPp9n640SErLWOR3K5K5HmKKgSLoysAoK(XcPCSLMuUmtt6atAAlKgS4N0mHrQJjDFPJqiZ3x6tJRfZ0Hx8tAMWUfXfNM5WHX8smEZfyijUI6n7ILfeQWLazEijLR0XZK(XcPbl(jntyKE8GyjLJT0K2tsAUrPtHrQ35qQLSaVni9y3WorxGq60KICKqAUadjXvY89L(04AXmnsch8f)KMjSBpiwZC4WyEjgV5cmKexx8tAMWU9GypG7tyEjgV5cmKexr9MDXYcoG7thMBu6SILf4TXTDd7eDbsv6TikmYCY8qgssrMqJjZdjPhblKw6HJaina2WFSpnPC80M0snodEaOvsrkNiJu4bqAPgNbpausFdQGjDGHj9ntKnCAs9M00wiTfKwsk3bKuS8MMHjDsBbWXXcPFSq60K(yK(7OGXKM2cP8X9Sai1XKYVGK0bM00wiT8ZaFBsFdcP3onJ0bqQdtAAlaHuoEmsApjPfcPBpPTaiTuJZiTeb(8PpnPPTJjf2nSZkPbBMckFsAoKIp3pstBH04Its5hocGuVH)yFAshystBHuy3WojnhsrmoJub85tFAsHhaP90KwI)mW3gxjZ3x6tJRpgom)WraxVH)yFAZC4W8axWzflr4l)WraxVH)yF6tbw8HHRigNbpa06N3KPdFdcP3oRLFg4BF6W3Gq6TZAlpWeha70BMiB40veJZUc4ZN(0vGGUEJpim3b0Kjy3WoVabD9ghQ3mr2WPRigNDfWNp9PRabD9gh0PaHDd78ce01B8bHFZezdNUIyC2vaF(0NUce01Bms4UKNEZezdNUIyC2vaF(0NUce01BCOcB8yhvU2Kjy3WoVabD9gFWBMiB40v(HJaUEd)X(0v2hSPpTjtfdgFc2nSZlqqxVXH6ntKnC6kIXzxb85tF6kqqxVXiH7sAY0Bqi92zT8ZaFBtMk(WW1I4mS4hN1pFqK5HK0JGfsT8O0pH0PjfzcnP5qkpyEKAj82)smqwmPLgmV4IUPpDLmpKKUV0NgxFmmschCShL(jMLlWqYRdhg8BbEagsfl82)smWxEW8Il6M(0vje(opVWofyUadjRo(UmMjt5cmKSYKIpmC9T40BJkq2xgezEij9iyHuUSmdHuVXotiDGjTuhnPWdG00wif2b4K0pwiDaKonPitOjDHtbqAAlKc7aCs6hlvsdrpTj9y3Woj9OxHu7jYifEaKwQJUsMVV0NgxFmmsch8pwUEkOM1lQeg7n8pEnIlZ3Ca4BXYmK7aFHfW888SzoC4IpmCfX4m4bGw)8MmLoQCa3b8uGh(gesVDwB3WoVWReezEij9iyH0JEfs5Q(lG5BJjDAsrMqt68tSZeshysl14m4bGwj9iyH0JEfs5Q(lG5BZWK6nPLACg8aqj1Hj988j1EriKkEAlas5QadcH0ayJWngWM(0KoaspAxImshys5sCW4bfxjnexpjfEaKYMetAoKwiK(5jTqGhGq6(shXMEBq6rVcPCv)fW8TXKMdPOlsZrDSqAAlKw8HHRK57l9PX1hdJKWbhELRXFbmFBSzoC4dl(WWveJZGhaA9ZFkWdFZezdNUIyC2nhaq6S(5nz6WCJsNveJZU5aasNvP3IOWc6uGiwGVfrPYMeF)8NW8smEZfyijUIyr5DG)U58F2H52KP9Loc5YMSIyr5DG)U58F2HX8smEZfyijUIyr5DG)U58F2NW8smEZfyijUIyr5DG)U58F2hWDqMmv8HHRigNbpa06N)uG45hl8Mvnadc56nc3yaB6txLElIcZKj88JfEZQWUez3b(wehmEqXvP3IOWcImpKKEeSqks1BMXIkys5ylnPBmsAjqAONYWKUaH0pVzKoasppFsxGqQ3KwQXzWdaTsAjQXFGqks5VneG3gKwQXzKYXJrsXPhJKwiK(5jLJT0KM2cPVfNKMoQqkS3o2wWvsTYHN0p2Bds3K0sIesZfyijMuoEAtQLSaVni9y3WorxGujZ3x6tJRpggjHdoQ3mJfvWM9o)IYnxGHK4WCBMdh2B82EEouC1b8uGbIyb(weL6gJx2K47N)uGh(MjYgoDfX4SRa(8PpD9ZBY0H5gLoR2)2qaEBCrmoRk9wefwqbzYuXhgUIyCg8aqRF(Gof4H5gLoR2)2qaEBCrmoRk9wefMjtmP4ddxT)THa824IyCwfiOR34dEloVPJkMmDyXhgUIyCg8aqRF(Gof4H5gLoRyzbEBCB3WorxGuLElIcZKjmVeJ3CbgsIROEZUyzbHQKbrMhsspcwi9iT9ept6XdIL0PjfzcTzKAprM3gKwaCboEM0CiLZ6jPWdGu(HJai1B4p2NM0bq6YyKI5xonUsMVV0NgxFmmsch8FBpXZ3EqSM5WHdmWdbRZUccPZ6Yy46N)eyD2vqiDwxgdx9(aKhWGmzcSo7kiKoRlJHRabD9gFqyUlPjtG1zxbH0zDzmCL9bB6thkUlzqNc8WCJsNv7FBiaVnUigNvLElIcZKjMu8HHR2)2qaEBCrmoR(5nzkW3mr2WPRigNDfWNp9PRabD9gFa3b0KPdrSaFlIsLFM4fEa3hdh0Pdl(WWveJZGhaA9ZhezEij9iyH0PjfzcnPf)KuEGpapDSq6h7TbPLACgPLiWNp9Pjf2b40msDys)yHrQ3yNjKoWKwQJM0Pj1Qms)yH0fofaPlPigNvmXKu4bq6BMiB40KkWW(ZL(DM0TzKcpasT)THa82GueJZi9ZNoQqQdtAUrPtHvjZ3x6tJRpggjHdEXm9DGVPTCx8tAMWmZHdFyXhgUIyCg8aqRF(th(MjYgoDfX4SRa(8PpD9ZFcZlX4nxGHK4kQ3SlwwWbCF6WCJsNvSSaVnUTByNOlqQsVfrHzYuGfFy4kIXzWdaT(5pH5Ly8MlWqsCf1B2flliui)0H5gLoRyzbEBCB3WorxGuLElIc7uG8abX14XQCxrmo7wmX8uGhkHW355fwvq5pdKnEhaR3(jMmDyUrPZQ9VneG3gxeJZQsVfrHfKjtsi8DEEHvfu(ZazJ3bW6TFYPe4D5swfu(ZazJ3bW6TFs9ntKnC6kqqxVXHkm3bdKFIjfFy4Q9VneG3gxeJZQF(GcYKPal(WWveJZGhaA9ZFk3O0zfllWBJB7g2j6cKQ0BruybrMVV0NgxFmmsch83gJ39L(03OJtZ6fvcNaVlxsmzozEidjPiZItsdrBpkKImlo92G09L(04kPwss6MKA7g2cGuEGpapptAoKIThqs6ZbVVNK6DkaWNpj9nnZtFAmPttks1BgPwYcc(rh3ZK5HK0JGfsTKf4TbPh7g2j6cesDysppFs54XiP2EsQ0Z3WM0CbgsIjDBgPLE4iasdGn8h7tt62msl14m4bGs6ces7jjfil7SzKoasZHuGadeSnPwHyawAsNM0KZq6aifDacP5cmKexjZ3x6tJRpoVWyzbEBCB3WorxGy2hlxo2EuUVfNEBeMBZENFr5MlWqsCyUnZHdhiIf4BruQyzbEBCB3WorxGCF)CGHpDiIf4BruQ8ZeVWd4(y4Gmzkq2KvS9YgoxodGD5xVRabgiy7TikNW8smEZfyijUI6n7ILfCa3brMhssTShqskY4G33tsTKf4TbPh7g2j6cesFtZ80NM0CiTCr4j1kedWst6NNuVjnyNsez((sFAC9X5HKWbhllWBJB7g2j6ceZ(y5YX2JY9T40BJWCB278lk3CbgsIdZTzoC4CJsNvSSaVnUTByNOlqQsVfrHDInzfBVSHZLZayx(17kqGbc2ElIYjmVeJ3CbgsIROEZUyzbhGCY8qs60XZ3hNhPOB5cM00wiDFPpnPthpt6hVfrHu2h4TbPp7TBj6TbPBZiTNK0ft6skqm(Xfq6(sF6kz((sFAC9X5HKWbh1B2TiU40SPJNVpoVWCtMtMVV0NgxzOg3e4D5sId)XY1tb1SErLWSfuo6m9LjVYVx(Fce8t6NqMVV0NgxzOg3e4D5sIrs4G)XY1tb1SErLW4FxeNHDxujTpJtY89L(04kd14MaVlxsmsch8pwUEkOM1lQe2iEM3(oW3fJDupUPpnz((sFACLHACtG3LljgjHd(hlxpfuZ6fvcZaYYGDGCriySejZjZdzijfPUEtAWw6GPzKITNFKr6Bqias3yKuW2gcM0bM0CbgsIjDBgP4N0lWhmz((sFACfD9o8BJX7(sF6B0XPz9IkHlMPnZHdx8HHRfZ03b(M2YDXpPzcR(5jZ3x6tJROR3ijCWzoMxIx01WFM5WHpmxGHKvhF5J7zbqMhsspcwiTuJZiTeb(8PpnPtt6BMiB40KYpt0Bds3K0OS4KuUoGK6nEBpptAXpjTNKuhM0ZZNuoEms6GqaVLNuVXB75zs9M0sD0vsrQB5cP4pqifBVSHdSlnl4OEZkKMjas3Mrks1BgPCjU4Kuht60K(MjYgonPfc8aeslvjQsAa0OhGqk)mrVnifi4e4V0NgtQdt6h7TbPw2lB4ahxuH0sdCmkPBZiLlsZeaPoM05NvY89L(04k66nschCeJZUc4ZN(0M5WHrSaFlIsLFM4fEa3hdFkqVXB755dcZ1b0KjEjRWU0S6(shHCc8BbEagsfBVSHdCCrLlpWXOvje(opVWoD4BMiB40vuVz3I4IZ6N)0HVzISHtxX2lB4C5ma2LjBAx)8bDkqVXB755qfoaustMYnkDwXYc8242UHDIUaPk9wef2jelW3IOuXYc8242UHDIUa5((5adh0PdFZezdNUc7sZQF(tbE4BMiB40vuVz3I4IZ6N3KjmVeJ3CbgsIROEZUyzbhG8Gof4H45hl8MvrmXn9OCXteH0PjtfFy4kIjUPhLlEIiKoV2F0ThNv)8brMhssrQB5cP4pqi988jL)NK(5j1kedWstAWAfSLM0PjnTfsZfyijPomPHiytB4FK0JEfGlK64gzts3x6ies5ylnPWUHD6TbPCJ0vcKMlWqsCLmFFPpnUIUEJKWbhBVSHZLZayx(1BZC4WfFy4k8kxJ)cy(246N)0HmP4ddx5a20g(hVWRaCP(5pH5Ly8MlWqsCf1B2flliuCnz((sFACfD9gjHd(BJX7(sF6B0XPz9IkHFmmzEijfP0nSjT0aFaEEMuKQ3msTKfq6(sFAsZHuGadeSnPHEkdtkhpTjfllWBJB7g2j6ceY89L(04k66nschCuVzxSSaZENFr5MlWqsCyUnZHdNBu6SILf4TXTDd7eDbsv6TikStyEjgV5cmKexr9MDXYcoaXc8TikvuVzxSSG77Ndm8PdztwX2lB4C5ma2LF9UM(RCVnoD4BMiB40vyxAw9ZtMhsslnqGfaP5q6hlKg6fT30NM0G1kylnPomPBFM0qpLrQJjTNK0pFLmFFPpnUIUEJKWbNTO9M(0M9o)IYnxGHK4WCBMdh(qelW3IOu3y8YMeF)8K5HK0JGfsTSx2WH0qCamsdTSPnPomPFS3gKAzVSHdCCrfslnWXOKUnJ0cPzcGuoEmsQG04DGqk7d82G00wiTfKwsQXJvjZ3x6tJROR3ijCWX2lB4C5ma2LjBABMdhMxYkSlnRUV0riNa)wGhGHuX2lB4ahxu5YdCmAvcHVZZlSt8swHDPzvGGUEJdvyJhJmpKKgSro7zmPFSqkQ3SI4ItmPomPVLNxyKUnJu7FBiaVnifX4msDmPFEs3Mr6h7TbPw2lB4ahxuH0sdCmkPBZiTqAMai1XK(5RKsAWYyE6tVX4zZi9T4KuuVzfXfNK6WKEE(KYz(rgPfcP)ElIcP5qQHKKM2cPahojT4mPCwp92G0LuJhRsMVV0NgxrxVrs4GJ6n7wexCAMdhoW3mr2WPROEZUfXfN1N9cme8bCFkqMu8HHR2)2qaEBCrmoR(5nz6WCJsNv7FBiaVnUigNvLElIclitM4LSc7sZQabD9ghQWVfN30rfKy8ybDIxYkSlnRUV0riNa)wGhGHuX2lB4ahxu5YdCmAvcHVZZlSt8swHDPzvGGUEJp4T48MoQqMhsspcwiTuJZiLltmjDtsTDdBbqkpWhGNNjLJN2KIu(Bdb4TbPLACgPFEsZHuUM0CbgsInJ0bq6K2cG0CJsNysNMuRYQK57l9PXv01BKeo4igNDlMyAMdh2B82EEouHdaL8uUrPZQ9VneG3gxeJZQsVfrHDk3O0zfllWBJB7g2j6cKQ0BruyNW8smEZfyijUI6n7ILfeQWbdtMcmWCJsNv7FBiaVnUigNvLElIc70H5gLoRyzbEBCB3WorxGuLElIclitMW8smEZfyijUI6n7ILfeM7GiZdjPHEAKnj9JfsdTGy(aVniT0X14lK6WKEE(K(2Mudjj17CiTuJZGhakPEJtzzMr6ai1Hj1swG3gKESByNOlqi1XKMBu6uyKUnJuoEmsQTNKk98nSjnxGHK4kz((sFACfD9gjHdotqmFG3gx(4A8fZC4WbceyGGT3IOyYK34T988bhLsg0PapeXc8Tikv(zIx4bCFmSjtEJ32ZZheoauYGof4H5gLoRyzbEBCB3WorxGuLElIcZKPaZnkDwXYc8242UHDIUaPk9wef2PdrSaFlIsfllWBJB7g2j6cK77NdmCqbrMhsspcwiTuCH0PjfzcnPomPNNpPSPr2K0wegP5q6BXjPHwqmFG3gKw64A8fZiDBgPPTaesxGqAuWyst7TjLRjnxGHKysNFsAGLKuoEAt6BA23ZGQK57l9PXv01BKeo4igNDlMyAMdhgZlX4nxGHK4kQ3SlwwqOcKRrYBA23ZkZX4P3oVYZEeCv6TikSGo5nEBpphQWbGsEk3O0zfllWBJB7g2j6cKQ0BruyMmDyUrPZkwwG3g32nSt0fivP3IOWiZdjPhblKAzVSHdPH4aybiPHw20MuhM00winxGHKK6ys3I5NKMdPmxiDaKEE(KAViesTSx2WboUOcPLg4yusLq4788cJuoEAtks1BwH0mbq6ai1YEzdhyxAgP7lDesLmFFPpnUIUEJKWbhBVSHZLZayxMSPTzVZVOCZfyijom3M5WHdmxGHKvBzJPDL)LHc5b8eMxIXBUadjXvuVzxSSGqX1bzYuG8swHDPz19Loc5e43c8amKk2Ezdh44IkxEGJrRsi8DEEHfezEij9iyHuRpaintaKMdPi1L1cgt60KUKMlWqsst7nj1XKAmEBqAoKYCH0njnTfsbUHDsA6OsLmFFPpnUIUEJKWbh)baPzc4MZfDzTGXM9o)IYnxGHK4WCBMdhoxGHK10rLBoxMlHc5L8uXhgUIyCg8aqRSHttMhsspcwiTuJZiTSbaKojD64zsDysTcXaS0KUnJ0svgPlqiDFPJqiDBgPPTqAUadjjLZ0iBskZfszFG3gKM2cPp7TBjwjZ3x6tJROR3ijCWrmo7MdaiDA278lk3CbgsIdZTzoCyelW3IOuztIVF(t5cmKSMoQCZ5YC5Gs4uGfFy4kIXzWdaTYgoTjtfFy4kIXzWdaTce01BCOEZezdNUIyC2TyIzfiOR34GoTV0rix2KvelkVd83nN)Z(GWVZVOCLwqDbFcZlX4nxGHK4kQ3SlwwqOcSKijWGXrn3O0zn5448oWx4nLQ0Bruybfez((sFACfD9gjHdoQ3ScPzcWmhomBYkIfL3b(7MZ)zxt)vU3gNcm3O0zfllWBJB7g2j6cKQ0BruyNW8smEZfyijUI6n7ILfCaIf4BruQOEZUyzb33phyytMytwX2lB4C5ma2LF9UM(RCVnc6uGhc(TapadPITx2WboUOYLh4y0QecFNNxyMmTV0rix2KvelkVd83nN)Z(GWVZVOCLwqDbhezEij9iyHuRqmadnPC80M0sVExaKTCbqAPXBeL0FhfmM00winxGHKKYXJrsleslK4WHuKhWsmjTqGhGqAAlK(MjYgonPVbvWKwSVYRK57l9PXv01BKeo4y7LnCUCga7YKnTnZHdd(TapadPYVExaKTCbC5XBeTkHW355f2jelW3IOuztIVF(t5cmKSMoQCZ5Y)YlYd4bb(MjYgoDfBVSHZLZayxMSPDL9bB6tJeJhliY8qs6rWcPw2lB4qkYawSnPttkYeAs)DuWystBbiKUaH0LXWK69Bq92OsMVV0NgxrxVrs4GJTx2W5(al22mhomyD2vqiDwxgdx9(aUdizEij9iyHuKQ3msTKfqAoK(Mg)rfsd9ckN0YSNVHDIjLhmpmPttAWYvkrvslJReAUcPiZ0WoaLuhtAA7ysDmPlP2UHTaiLh4dWZZKM2BtkqytMEBq60KgSCLseP)okymPSfuoPP98nStmPoM0Ty(jP5qA6OcPZpjZ3x6tJROR3ijCWr9MDXYcm7D(fLBUadjXH52mhomMxIXBUadjXvuVzxSSGdqSaFlIsf1B2fll4((5adFQ4ddxzlO8BApFd7S(5n7zVEhMBZ8ofa4ZNxhfvy(MsyUnZ7uaGpFED4WP)khFqyKtMhsspcwifP6nJ0JoUNjnhsFtJ)OcPHEbLtAz2Z3WoXKYdMhM0Pj1QSkPLXvcnxHuKzAyhGsQdtAA7ysDmPlP2UHTaiLh4dWZZKM2BtkqytMEBq6VJcgtkBbLtAApFd7etQJjDlMFsAoKMoQq68tY89L(04k66nschCuVzx44E2mhoCXhgUYwq530E(g2z9ZFcXc8Tikv2K47N3SN96DyUnZ7uaGpFEDuuH5BkH52mVtba(851HdN(RC8bHr(P3mr2WPRigNDlMyw)8K5HK0JGfsrQEZiLlXfNK6WKEE(KYMgztsBryKMdPabgiyBsd9ugUsQvo8K(wC6TbPBskxt6aifDacP5cmKetkhpTj1swG3gKESByNOlqin3O0PWiDBgPNNpPlqiTNK0p2BdsTSx2WboUOcPLg4yushaPLgF(z7psdMExEfZlX4nxGHK4kQ3SlwwWbLyljPgsIjnTfsr92r)OKoWKwss3MrAAlK2F0cbq6atAUadjXvsd2iEmJu2qApjP8abJjf1BwrCXjP)o9iPBmsAUadjXKUaHu2KPWiLJN2KwQYiLJT0K(XEBqk2Ezdh44IkKYdCmkPomPfsZeaPoM0fX6XTikvY89L(04k66nschCuVz3I4ItZC4WiwGVfrPYMeF)8NaRZUccPZk6GqqLoREFWBX5nDubjbSwYtyEjgV5cmKexr9MDXYccvGCnsq(rn3O0zf1Xc4Cv6TikmKSV0rix2KvelkVd83nN)Z(OMBu6SYJp)S93n6D5vP3IOWqsGyEjgV5cmKexr9MDXYcoOeBjd6OgiVKvyxAwDFPJqob(TapadPITx2WboUOYLh4y0QecFNNxybf0Pape8BbEagsfBVSHdCCrLlpWXOvje(opVWmz6W3mr2WPRWU0S6N)e43c8amKk2Ezdh44IkxEGJrRsi8DEEHzY0(shHCztwrSO8oWF3C(p7dc)o)IYvAb1fCqK57l9PXv01BKeo4iwuEh4VBo)NTzVZVOCZfyijom3M5WHbcmqW2BruoLlWqYA6OYnNlZLdcgMmfyUrPZkQJfW5Q0BruyNytwX2lB4C5ma2LF9UceyGGT3IOeKjtfFy46VH)GO3gx2ckVfmU(5jZdjPw8YZ3iPVPzE6ttAoKIZHN03ItVni1kedWst60KoWWiD5cmKetkhBPjf2nStVniTeiDaKIoaHuCUVYfgPOtbM0TzK(XEBqAPXNF2(J0GP3Lt62mspMRugPivhlGZvY89L(04k66nschCS9YgoxodGD5xVnZHddeyGGT3IOCkxGHK10rLBoxMlhW1Nom3O0zf1Xc4Cv6TikSt5gLoR84ZpB)DJExEv6TikStyEjgV5cmKexr9MDXYcoa5K5HK0s8IWtQvigGLM0ppPtt6IjfD7ZKMlWqsmPlMu(bJ9IOygPcs7j8jPCSLMuy3Wo92G0sG0bqk6aesX5(kxyKIofys54PnPLgF(z7psdMExELmFFPpnUIUEJKWbhBVSHZLZayx(1BZENFr5MlWqsCyUnZHddeyGGT3IOCkxGHK10rLBoxMlhW1Nom3O0zf1Xc4Cv6TikSthgyUrPZkwwG3g32nSt0fivP3IOWoH5Ly8MlWqsCf1B2fll4aelW3IOur9MDXYcUVFoWWbDkWdZnkDw5XNF2(7g9U8Q0BruyMmfyUrPZkp(8Z2F3O3LxLElIc7eMxIXBUadjXvuVzxSSGqfg5bfez((sFACfD9gjHdoQ3SlwwGzVZVOCZfyijom3M5WHX8smEZfyijUI6n7ILfCaIf4BruQOEZUyzb33phy4tbEiE(XcVzvetCtpkx8eriDAY0HVzISHtxHJc2(bw4S(5dYSN96DyUnZ7uaGpFEDuuH5BkH52mVtba(851HdN(RC8bHroz((sFACfD9gjHdoQ3SlCCpB2ZE9om3M5DkaWNpVokQW8nLWCBM3PaaF(86WHt)vo(GWi)uGhw8HHRSfu(nTNVHDw)8Mm9MjYgoDfX4SBXeZ6NpiZC4WhINFSWBwfXe30JYfpresNMmD4BMiB40v4OGTFGfoRFEY8qs6rWcPhDuW2pWcNKo)e7mH0bMu01BsFZezdNgtAoKIUENR3KwQjUPhfsTMicPtsl(WWvY89L(04k66nschC4OGTFGfonZHdJNFSWBwfXe30JYfpresNNoS4ddxrmodEaO1p)Pdl(WWv(HJaUEd)X(01pVzENca85ZRJIkmFtjm3M5DkaWNpVoC40FLJpim3K5HK0JGfsTcXam0KUysJlojfi4bKK6WKonPPTqk6GqiZ3x6tJROR3ijCWX2lB4C5ma2LjBAtMhsspcwi1kedWst6IjnU4KuGGhqsQdt60KM2cPOdcH0TzKAfIbyOj1XKonPitOjZ3x6tJROR3ijCWX2lB4C5ma2LF9MmNmpKKEeSq60KImHM0G1kylnP5qQHKKg6Pmst)vU3gKUnJubPX7aH0Cin6Tq6NN0cjtbqkhpTjTuJZGhakz((sFACnbExUK4WFSC9uqnRxujSGYFgiB8oawV9tmZHd)MjYgoDfX4SRa(8PpDfiOR34qfMBKBY0BMiB40veJZUc4ZN(0vGGUEJpa5hfY8qsAzGZKMdPwN7hPbWsCHMuoEAtAONFrui1k3x5cJuKj0ysDys5hm2lIsLuUstACAdbqkSByNys54PnPOdqinawIl0K(XcM0ntbLpjnhsXN7hPC80M0Tpt6Jr6aifPWhNK(XcPEwjZ3x6tJRjW7YLeJKWb)JLRNcQz9IkH9g)a)ClIYne(BNF0ltq4pXmhoCXhgUIyCg8aqRF(tfFy4k)WraxVH)yF66N3KPIbJpb7g25fiOR34qfg5b0KPIpmCLF4iGR3WFSpD9ZF6ntKnC6kIXzxb85tF6kqqxVXiH7sEaSByNxGGUEJnzQ4ddxrmodEaO1p)P3mr2WPR8dhbC9g(J9PRabD9gJeUl5bWUHDEbc66n2KPaFZezdNUYpCeW1B4p2NUce01B8bH5oGNEZezdNUIyC2vaF(0NUce01B8bH5oGbDc2nSZlqqxVXheMBU6asMhssTo3psTSfjjfP(X(JuoEAtAPgNbpauY89L(04Ac8UCjXijCW)y56PGAwVOsy09Tfa5ITfjVOFS)mZHd)MjYgoDfX4SRa(8PpDfiOR34d4oGK5HKuRZ9JuKI)IZKYXtBsl9WraKgaB4p2NM0pEneZifDlxif)bcP5qkUDEH00winoCeCskszPjnxGHKvsdrBPj9JfgPC80Mul7LnCegPCfqbPdmPLnauPtZifPWhNK(XcPttkYeAsxmPO)NnPlMu(bJ9IOujZ3x6tJRjW7YLeJKWb)JLRNcQz9IkHXZpgLm924c(fNn7D(fLBUadjXH52mhoCXhgUYpCeW1B4p2NU(5nz6qEGl4SILi8LF4iGR3WFSpTjtsi8DEEHvX2lB4iS7akUd8nhaQ0jzEij9iyHuUSmdHuVXotiDGjTuhnPWdG00wif2b4K0pwiDaKonPitOjDHtbqAAlKc7aCs6hlvsTShqs6ZbVVNK6WKIyCgPc4ZN(0K(MjYgonPoMuUdiM0bqk6aesxo75kz((sFACnbExUKyKeo4FSC9uqnRxujm2B4F8AexMV5aW3ILzi3b(clG555zZC4WVzISHtxrmo7kGpF6txbc66n(GWChqY8qs6rWcPw2lB4ims5kGcshyslBaOsNKYXwAs7jj1Bsl14m4bGAgPdGuVjTqsoI0KwQXzKYLjMK(wCIj1Bsl14m4bGwjZ3x6tJRjW7YLeJKWb)JLRNcQz9IkHX2lB4iS7akUd8nhaQ0PzoC4dl(WWveJZGhaA9ZBYuG8abX14XQCxrmo7wmXmiY8qs6rWcPrhNKoWKons3hlKYw01qinbExUKysNoEMuhMuKYFBiaVniTuJZin0sXhgMuht6(shHygPdG0ZZN0fiK2tsAUrPtHrQ35qQNvY89L(04Ac8UCjXijCWFBmE3x6tFJoonRxujmd14MaVlxsSzoC4apm3O0z1(3gcWBJlIXzvP3IOWmzIjfFy4Q9VneG3gxeJZQF(GofyXhgUIyCg8aqRFEtMEZezdNUIyC2vaF(0NUce01B8bChWGiZdjPHwG3FmjfEJXI9voPWdG0pElIcPEkO4aK0JGfsNM03mr2WPj1BshataKwCM0e4D5sskoozLmFFPpnUMaVlxsmsch8pwUEkOyZC4WfFy4kIXzWdaT(5nzQ4ddx5hoc46n8h7tx)8Mm9MjYgoDfX4SRa(8PpDfiOR34d4oGqjucbb]] )
    

end
