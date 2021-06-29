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


    spec:RegisterPack( "Shadow", 20210629, [[divwocqivu9irsDjuOKAtQqFsfLAuIuoLivRsrvPxHcmluu3srvr7sHFrPOHjc5yOildf0ZurrtteORPOuBJsb9nrOyCukuNdfk16uuvnprsUNiAFQa)trvHoOirTquipefQMOiOlkcWgvrHpsPqmsuOOtkcOvsP0lPui1mrHc3ufLStvq)ueknurchvrvblffkjpLIMQIkxvrjBvrv(QiunwkfsAVQQ)QkdM4WsTyf5XQ0Kr1LjTzq9zkmAk50uTAuOeVwrXSf1THQDl53knCu64Iez5aphY0fUoiBhk9DOy8ukW5vrwpLcjMpLQ9J8NP)CFtEh6)qgMigYuISHmKXEWuIHjMyid)MXjw9BY23zAd9BwnU(nnTA(I5BY2NYBZ)Z9nrle4QFtRiyrZVnTPHhwqtJ7IBtKJdL7W36cA4WMih)AZV5eKNJey9N(M8o0)HmmrmKPezdziJ9GPedtmXWVzdfwl4BA64m(30Y5CT(tFtUIUFttRMVyijfaxrbzRTqLscdzSzMegMigYezlz7Cy0EgsM36CsMBbaTcsWyPfjrdm0GK7cvbIKgOKaVGRYhFZSJc0FUVjlqVl(uh)5(hY0FUVPw9uw5Fg9nVapuG3FtGI3EHijvKCMjkrFZ(g(wFt2fJcEywa)bVGWdiU(J)Hm8p33uREkR8pJ(MxGhkW7V55KmbbdpqwnFXaVa8be73SVHV13ez18fd8cW)X)WZ8p33uREkR8pJ(MxGhkW7VPxOU840GRW(1dsoGeMM93SVHV13Sb3U0xSaGwXp(hMG)5(MA1tzL)z03Cz)Min(M9n8T(MyBG3tz9BITZq63KHFtSn4vnU(nX9I)qAdExOyHH)X)Wz)N7B23W36BITXzDGFFXcDT(MA1tzL)z0p(X3KJB8cGxZOb6p3)qM(Z9n1QNYk)ZOVz1463K3GzW3TEC9oZ7XcfafD16QFZ(g(wFtEdMbF36X17mVhluau0vRR(J)Hm8p33uREkR8pJ(MvJRFteunL3L)ACnSoHIVzFdFRVjcQMY7YFnUgwNqXp(hEM)5(MA1tzL)z03SAC9BAKpXA9w4xJqoUN7W36B23W36BAKpXA9w4xJqoUN7W36h)dtW)CFtT6PSY)m6BwnU(n5aT5WoqFyvesZFZ(g(wFtoqBoSd0hwfH08p(X3eV96p3)qM(Z9n1QNYk)ZOV5f4Hc8(BobbdpM2TEl8lS0xJUAXv(aI9B23W36BE7C(13W36LDu8nZokEvJRFZPDRF8pKH)5(MA1tzL)z038c8qbE)npNKObgAmC0Jn3NuW3SVHV13K7iwn)WBd)(J)HN5FUVPw9uw5Fg9n7B4B9nXUo)Pai2W36BYv0f4SHV13CwiLK5ToNKeaaIn8TizlsU7M5lMIe2DZEzqshKK1gfKKGjIeVqD5XjsMGcsQniXHj50crcgpNjzXQGBZsIxOU84ejErY8oJbjNvpJscccOKGSA(Ib21IBtCV4tAXvajDXj5S8ItcJYnkiXrKSfj3DZ8ftrYKcVaLK5LagKKanQfOKWUB2ldsakka(n8TqK4WKaH8YGetRMVyGZnUsskaocNKU4KWiT4kGehrYcfJV5f4Hc8(BITbEpL1b7U5h8cExoIKJKKgjEH6YJtKCqsssWerID7KWQXa21Ip6B4yvsoscaQu4fyOdKvZxmW5gxFSahHp0ucYzzvojhj5CsU7M5lMAG7f)nLBumGyj5ijNtYD3mFXudKvZxmpmlG)4AhwdiwssNKJKKgjEH6YJtKKQKKyJNnj2Tts0zTIbsBGxgVYnSc8gOdT6PSYj5ijyBG3tzDG0g4LXRCdRaVb67cflmmjPtYrsoNK7Uz(IPgWUw8beljhjjnsoNK7Uz(IPg4EXFt5gfdiwsSBNeeRMZVObgAGg4EXFiTbKCajmKK0)X)We8p33uREkR8pJ(M9n8T(MiRMVyEywa)X2E9n5k6cC2W36BEw9mkjiiGsYPfIewOGeiwsmt85pfKKYMPCkizlsclLKObgAqIdtsId6WcgktYz0kWvsCuD2bj9nCSkjyS0Iey3Wk8YGeMMpptsIgyObA8nVapuG3FZjiy4bCRpdOgW9UqdiwsosY5KW1jiy4bgqhwWq5hCRaxhqSKCKeeRMZVObgAGg4EXFiTbKKkssWF8pC2)5(MA1tzL)z03SVHV138258RVHV1l7O4BMDu8Qgx)Mxo6h)dTH)5(MA1tzL)z03SVHV13e3l(dPn4BEpDZ6lAGHgO)Hm9nVapuG3FZOZAfdK2aVmELByf4nqhA1tzLtYrsqSAo)IgyObAG7f)H0gqYbKGTbEpL1bUx8hsBW7cflmmjhj5Cs4BmqwnFX8WSa(JT9Ae(DgVmi5ijNtYD3mFXudyxl(aI9BYv0f4SHV13KX0nSijfaFbECIKZYlojMAdiPVHVfjXscqHbkYIKeUZHibJhwKG0g4LXRCdRaVb6p(hMy(Z9n1QNYk)ZOVzFdFRVjVXRo8T(M3t3S(IgyOb6FitFZlWdf4938CsW2aVNY6OZ5hFd0dI9BYv0f4SHV13mfafwbKeljqiLKe24vh(wKKYMPCkiXHjPRtKKWDosCej1gKaXo(X)qB8FUVPw9uw5Fg9n7B4B9nrwnFX8WSa(JRDy9n5k6cC2W36BolKsIPvZxmKK4lGtsc1oSiXHjbc5LbjMwnFXaNBCLKuaCeojDXjzslUcibJNZKO2awhOKWHaEzqsyPKuQniiX4YhFZlWdf493KvJbSRfF03WXQKCKeauPWlWqhiRMVyGZnU(ybocFOPeKZYQCsoscRgdyxl(aO4TxissvssmU8F8pKX(p33uREkR8pJ(M9n8T(M4EXFt5gfFtUIUaNn8T(MPCgtFcrcesjb3l(uUrbIehMKBZYQCs6ItIfuzOaVmib76CsCejqSK0fNeiKxgKyA18fdCUXvssbWr4K0fNKjT4kGehrce7Gesszo3dFRoNpXmj3gfKG7fFk3OGehMKtlejywOmNKjLeOQNYkjXsIHgKewkjahoiz6ejyAp8YGKMeJlF8nVapuG3FZ0i5UBMVyQbUx83uUrX4A1adfrYbKWejhjjns46eem8WcQmuGxgpSRZhqSKy3ojNts0zTIHfuzOaVmEyxNp0QNYkNK0jXUDsy1ya7AXhafV9crsQssYTrXlCCLegqIXLts6KCKewngWUw8rFdhRsYrsaqLcVadDGSA(Ibo346Jf4i8HMsqolRYj5ijSAmGDT4dGI3EHi5asUnkEHJR)4Fitj6p33uREkR8pJ(M9n8T(MyxN)M2C8n5k6cC2W36BolKsY8wNtcJ2CqshKy5gwkGewGVaporcgpSiHXeQmuGxgKmV15KaXssSKKGKenWqdeZKSas2WsbKeDwRarYwKyo34BEbEOaV)MEH6YJtKKQKKyJNnjhjj6SwXWcQmuGxgpSRZhA1tzLtYrsIoRvmqAd8Y4vUHvG3aDOvpLvojhjbXQ58lAGHgObUx8hsBajPkjj2qsSBNK0ijnsIoRvmSGkdf4LXd768Hw9uw5KCKKZjj6SwXaPnWlJx5gwbEd0Hw9uw5KKoj2TtcIvZ5x0adnqdCV4pK2asssctKK(p(hYet)5(MA1tzL)z03SVHV13KRyxiGxgp2CBaPFtUIUaNn8T(MjCRZoibcPKKqf7cb8YGKuKBdiLehMKtlej3UiXqds8kwsM36C4fGtIxOqBoZKSasCysm1g4Lbjh6gwbEdusCejrN1kuojDXjbJNZKy5bjATqgwKenWqd04BEbEOaV)MPrcqHbkYQNYkj2TtIxOU84ejhqsIz2KKojhjjnsoNeSnW7PSoy3n)GxW7YrKy3ojEH6YJtKCqssSXZMK0j5ijPrY5KeDwRyG0g4LXRCdRaVb6qREkRCsSBNK0ij6SwXaPnWlJx5gwbEd0Hw9uw5KCKKZjbBd8EkRdK2aVmELByf4nqFxOyHHjjDss)h)dzIH)5(MA1tzL)z03SVHV13e76830MJVjxrxGZg(wFZzHusMhJizlsy8esIdtYPfIe(wNDqsPkNKyj52OGKeQyxiGxgKKICBaPmtsxCsclfOK0aLKSIqKewDrscss0adnqKSqbjPnBsW4Hfj3T4qEK(4BEbEOaV)MiwnNFrdm0anW9I)qAdijvKKgjjijmGK7wCipgChH2QR4PxRvrdT6PSYjjDsosIxOU84ejPkjj24ztYrsIoRvmqAd8Y4vUHvG3aDOvpLvoj2TtY5KeDwRyG0g4LXRCdRaVb6qREkR8F8pKPZ8p33uREkR8pJ(M9n8T(MiRMVyEywa)X1oS(M3t3S(IgyOb6FitFZlWdf493mnsIgyOXWs7CynyVbjPIegMisoscIvZ5x0adnqdCV4pK2assfjjijPtID7KKgjSAmGDT4J(gowLKJKaGkfEbg6az18fdCUX1hlWr4dnLGCwwLts6FtUIUaNn8T(MZcPKyA18fdjj(c4Zpjju7WIehMKWsjjAGHgK4is6Pfkijws4UsYci50crIvJvjX0Q5lg4CJRKKcGJWjrtjiNLv5KGXdlsolV4tAXvajlGetRMVyGDT4K03WXQJF8pKPe8p33uREkR8pJ(M9n8T(MiiaqlUcEX(WBEPi038E6M1x0adnq)dz6BEbEOaV)Mrdm0yeoU(I9XDLKurcdNnjhjzccgEGDDo8cWh8ft9n5k6cC2W36BolKsIjeaOfxbKeljNvZlfHizlsAsIgyObjHvhK4ismwVmijws4UsshKewkja3WkijCCD8J)Hmn7)CFtT6PSY)m6B23W36BIDD(lwaqR4BEpDZ6lAGHgO)Hm9nVapuG3FtSnW7PSo4BGEqSKCKKObgAmchxFX(4UsYbKCMKCKK0izccgEGDDo8cWh8ftrID7KmbbdpWUohEb4dGI3EHijvKC3nZxm1a76830MJbqXBVqKKojhjPVHJvF8ngyBCwh43xSqxlssscIvZ5x0adnqdSnoRd87lwORfjhjbXQ58lAGHgObUx8hsBajPIK0iz2KWassJeBijZxsIoRvmcmokEl8dUdDOvpLvojPts6FtUIUaNn8T(MZcPKmV15Km3caAfKSv(ejomjMj(8Ncs6ItY8MJKgOK03WXQK0fNKWsjjAGHgKGzRZoiH7kjCiGxgKewkjxRUknp(X)qMSH)5(MA1tzL)z038c8qbE)n5BmW24SoWVVyHUwJWVZ4LbjhjjnsIoRvmqAd8Y4vUHvG3aDOvpLvojhjbXQ58lAGHgObUx8hsBajhqc2g49uwh4EXFiTbVluSWWKy3oj8ngiRMVyEywa)X2Enc)oJxgKKojhjjnsoNeauPWlWqhiRMVyGZnU(ybocFOPeKZYQCsSBNK(gow9X3yGTXzDGFFXcDTi5GKKCpDZ6tlf3vejP)n7B4B9nX9IpPfxb)4FitjM)CFtT6PSY)m6B23W36BISA(I5Hzb8hx7W6BYv0f4SHV13CwiLeZeF(tijy8WIKu0Enb0EgfqskqDgNeOkRiejHLss0adnibJNZKmPKmP5fdjmmrmwtYKcVaLKWsj5UBMVyksUlUIizQVZm(MxGhkW7VjaQu4fyOd22RjG2ZOGhlQZ4dnLGCwwLtYrsW2aVNY6GVb6bXsYrsIgyOXiCC9f7J9gpgMisoGK0i5UBMVyQbYQ5lMhMfWFCTdRbhc0HVfjmGeJlNK0)X)qMSX)5(MA1tzL)z03SVHV13ez18fZ7cAK13KROlWzdFRV5SqkjMwnFXqcJdAKfjBrcJNqsGQSIqKewkqjPbkjnNJiXR7I7LX4BEbEOaV)MG25pfRwXO5C0WlsoGeMs0p(hYeJ9FUVPw9uw5Fg9nVapuG3FteRMZVObgAGg4EXFiTbKCajyBG3tzDG7f)H0g8UqXcdtYrsMGGHh8gmZlSwidRyaX(n5k6cC2W36BolKsYz5fNetTbKelj3Tqq4kjjSbZqYCwlKHvGiHfSxejBrskNytadsMlXMWeljm(wWoaNehrsy5isCejnjwUHLciHf4lWJtKewDrcq5BeEzqYwKKYj2eajqvwris4nygscRfYWkqK4is6PfkijwschxjzHIV590nRVObgAG(hY030Rqbai245WFZWVZGoijd)MEfkaaXgphhx5Eh63KPV51Q96BY03SVHV13e3l(dPn4h)dzyI(Z9n1QNYk)ZOVjxrxGZg(wFZzHusolV4KCg5(ejXsYDleeUsscBWmKmN1czyfisyb7frYwKyo3GK5sSjmXscJVfSdWjXHjjSCejoIKMel3WsbKWc8f4XjscRUibO8ncVmibQYkcrcVbZqsyTqgwbIehrspTqbjXss44kjlu8nVapuG3FZjiy4bVbZ8cRfYWkgqSKCKeSnW7PSo4BGEqSFtVcfaGyJNd)nd)od6GKm84D3mFXudSRZFtBogqSFtVcfaGyJNJJRCVd9BY038A1E9nz6B23W36BI7f)bN7t)4Fidz6p33uREkR8pJ(M9n8T(M4EXFt5gfFtUIUaNn8T(MZcPKCwEXjHr5gfK4WKCAHiHV1zhKuQYjjwsakmqrwKKWDo0GeZyzj52OWlds6GKeKKfqc(cusIgyObIemEyrIP2aVmi5q3WkWBGss0zTcLtsxCsoTqK0aLKAdsGqEzqIPvZxmW5gxjjfahHtYcijfOtxl)scJHxZmqSAo)IgyObAG7f)H0gCW8XztIHgisclLeCVCCiCswysMnjDXjjSuski8jfqYcts0adnqdss5mAzMe(ssTbjSafHib3l(uUrbjqv4zs6CMKObgAGiPbkj8ncLtcgpSizEZrcglTibc5LbjiRMVyGZnUsclWr4K4WKmPfxbK4isASTN7PSo(MxGhkW7Vj2g49uwh8nqpiwsoscOD(tXQvmWxSkUwXWlsoGKBJIx44kjmGKenMnjhjbXQ58lAGHgObUx8hsBajPIK0ijbjHbKWqsMVKeDwRyG7ifCAOvpLvojmGK(gow9X3yGTXzDGFFXcDTiz(ss0zTIbl601YVVSxZm0QNYkNegqsAKGy1C(fnWqd0a3l(dPnGKdMpsYSjjDsMVKKgjSAmGDT4J(gowLKJKaGkfEbg6az18fdCUX1hlWr4dnLGCwwLts6KKojhjjnsoNeauPWlWqhiRMVyGZnU(ybocFOPeKZYQCsSBNKZj5UBMVyQbSRfFaXsYrsaqLcVadDGSA(Ibo346Jf4i8HMsqolRYjXUDs6B4y1hFJb2gN1b(9fl01IKdssY90nRpTuCxrKK(p(hYqg(N7BQvpLv(NrFZ(g(wFtSnoRd87lwOR138c8qbE)nbkmqrw9uwj5ijrdm0yeoU(I9XDLKdiXgsID7KKgjrN1kg4osbNgA1tzLtYrs4BmqwnFX8WSa(JT9AauyGIS6PSss6Ky3ojtqWWdOcgcK9Y4XBWmLIqdi2V590nRVObgAG(hY0p(hYWZ8p33uREkR8pJ(M9n8T(MiRMVyEywa)X2E9n5k6cC2W36BAYQxVZKC3I7HVfjXsckwwsUnk8YGeZeF(tbjBrYcdpFgnWqdejyS0Iey3Wk8YGKZKKfqc(cusqrFNr5KGVtis6ItceYldssb601YVKWy41mK0fNKdtSZrYz5ifCA8nVapuG3FtGcduKvpLvsoss0adngHJRVyFCxj5assqsosY5KeDwRyG7ifCAOvpLvojhjj6SwXGfD6A53x2RzgA1tzLtYrsqSAo)IgyObAG7f)H0gqYbKWWF8pKHj4FUVPw9uw5Fg9n7B4B9nrwnFX8WSa(JT96BEpDZ6lAGHgO)Hm9nVapuG3FtGcduKvpLvsoss0adngHJRVyFCxj5assqsosY5KeDwRyG7ifCAOvpLvojhj5CssJKOZAfdK2aVmELByf4nqhA1tzLtYrsqSAo)IgyObAG7f)H0gqYbKGTbEpL1bUx8hsBW7cflmmjPtYrssJKZjj6SwXGfD6A53x2RzgA1tzLtID7KKgjrN1kgSOtxl)(YEnZqREkRCsoscIvZ5x0adnqdCV4pK2assvssyijPts6FtUIUaNn8T(M2OvLLeZeF(tbjqSKSfjnIe8Uors0adnqK0isyxeYNYkZKO2GRYgKGXslsGDdRWldsotswaj4lqjbf9DgLtc(oHibJhwKKc0PRLFjHXWRzg)4FidN9FUVPw9uw5Fg9n7B4B9nX9I)qAd(M3t3S(IgyOb6FitFtVcfaGyJNd)nd)od6GKm8B6vOaaeB8CCCL7DOFtM(MxGhkW7VjIvZ5x0adnqdCV4pK2asoGeSnW7PSoW9I)qAdExOyHH)MxR2RVjt)4FidTH)5(MA1tzL)z03SVHV13e3l(do3N(MEfkaaXgph(Bg(Dg0bjz4X7Uz(IPgyxN)M2CmGy)MEfkaaXgphhx5Eh63KPV51Q96BY0p(hYWeZFUVPw9uw5Fg9n5k6cC2W36BolKsIzIp)jKKgrsUrbjafTGGehMKTijSusWxS63SVHV13ez18fZdZc4pU2H1p(hYqB8FUVPw9uw5Fg9n5k6cC2W36BolKsIzIp)PGKgrsUrbjafTGGehMKTijSusWxSkjDXjXmXN)esIJizlsy8e(n7B4B9nrwnFX8WSa(JT96h)4BEXC)Z9pKP)CFtT6PSY)m6BcH0hglpRVBJcVm(hY03SVHV13ePnWlJx5gwbEd0V590nRVObgAG(hY038c8qbE)ntJeSnW7PSoqAd8Y4vUHvG3a9DHIfgMKJKCojyBG3tzDWUB(bVG3LJijDsSBNK0iHVXaz18fZdZc4p22RbqHbkYQNYkjhjbXQ58lAGHgObUx8hsBajhqctKK(3KROlWzdFRV5SqkjMAd8YGKdDdRaVbkjomjNwisW45mjwEqIwlKHfjrdm0arsxCssXIrbKKalyiKVfjDXjzERZHxaojnqjP2GeG28tmtYcijwsakmqrwKyM4ZFkizlscmljlGe8fOKenWqd04h)dz4FUVPw9uw5Fg9nHq6dJLN13TrHxg)dz6B23W36BI0g4LXRCdRaVb638E6M1x0adnq)dz6BEbEOaV)MrN1kgiTbEz8k3WkWBGo0QNYkNKJKW3yGSA(I5Hzb8hB71aOWafz1tzLKJKGy1C(fnWqd0a3l(dPnGKdiHHFtUIUaNn8T(MMwliiHXDWfYdsm1g4Lbjh6gwbEdusUBX9W3IKyjzgvzjXmXN)uqceljErskVjGF8p8m)Z9n1QNYk)ZOV5w5tVlM73KPVzFdFRVjUx83uUrX3KROlWzdFRV5w5tVlMlj49mkIKWsjPVHVfjBLprceQNYkjCiGxgKCT6Q0SxgK0fNKAdsAejnja1ak3as6B4Bn(Xp(MbWRz0a9N7Fit)5(MA1tzL)z03KROlWzdFRV5SqkjBrcJNqsszZuofKeljgAqsc35ij87mEzqsxCsuBaRdusILKSxkjqSKmPrOasW4HfjZBDo8cW)MvJRFtfN9eq78Bb8QRR(nVapuG3FZ7Uz(IPgyxN)uaeB4BnakE7fIKuLKeMyij2TtYD3mFXudSRZFkaIn8TgafV9crYbKWWeZ3SVHV13uXzpb0o)waV66Q)4Fid)Z9n1QNYk)ZOVjxrxGZg(wFZ5aNijwsmpvxssGZhsijy8WIKeUqtzLeZOVZOCsy8eIiXHjHDriFkRdssSfj5TmuajWUHvGibJhwKGVaLKe48HescesrK0rO4SbjXsc6uDjbJhwK01jsUCswajmwGqbjqiLepgFZQX1VPxOlak6PS(sjOUci8hxX6x9BEbEOaV)MtqWWdSRZHxa(aILKJKmbbdpyxmk45fmeY3AaXsID7KmTiejhjb2nSIhqXBVqKKQKKWWerID7Kmbbdpyxmk45fmeY3AaXsYrsU7M5lMAGDD(tbqSHV1aO4TxisyajmnBsoGey3WkEafV9crID7KmbbdpWUohEb4diwsosYD3mFXud2fJcEEbdH8TgafV9crcdiHPztYbKa7gwXdO4TxisSBNK0i5UBMVyQb7IrbpVGHq(wdGI3EHi5GKKWuIi5ij3DZ8ftnWUo)Pai2W3Aau82lejhKKeMsejPtYrsGDdR4bu82lejhKKeMySt03SVHV130l0faf9uwFPeuxbe(JRy9R(J)HN5FUVPw9uw5Fg9n5k6cC2W36BAEQUKyAPAqYzbH8ljy8WIK5TohEb4FZQX1VjEF7jG(qwQgpCiKF)MxGhkW7V5D3mFXudSRZFkaIn8TgafV9crYbKWuI(M9n8T(M49TNa6dzPA8WHq(9h)dtW)CFtT6PSY)m6BwnU(nrluoRr4LXdanD6BEpDZ6lAGHgO)Hm9nVapuG3FZjiy4b7IrbpVGHq(wdiwsSBNKZjHf4kkgind)yxmk45fmeY36B23W36BIwOCwJWlJhaA603KROlWzdFRVP5P6scJvqtNibJhwKKIfJcijbwWqiFlsGqTHYmj49mkjiiGssSKGkNvjjSusYlgffKWyMcsIgyOXp(ho7)CFtT6PSY)m6BYv0f4SHV13CwiLeg1CdLeVqoxjzHjzENbjWlGKWsjb2bOGeiKsYcizlsy8essdhkGKWsjb2bOGeiKoiX0AbbjxhCH8GehMeSRZjrbqSHVfj3DZ8ftrIJiHPeHizbKGVaLKgtFA8nRgx)MiVGHYpJCZ9owa6n1Cd9TWpyfSxpo9nVapuG3FZ7Uz(IPgyxN)uaeB4BnakE7fIKdssctj6B23W36BI8cgk)mYn37ybO3uZn03c)GvWE940p(hAd)Z9n1QNYk)ZOVjxrxGZg(wFZzHusYokizHjzR5tiKscVXBdLKa41mAGizR8jsCysymHkdf4LbjZBDojjuNGGHjXrK03WXQmtYci50crsdusQnij6SwHYjXRyjXJX3SVHV138258RVHV1l7O4BEbEOaV)MPrY5KeDwRyybvgkWlJh215dT6PSYjXUDs46eem8WcQmuGxgpSRZhqSKKojhjjnsMGGHhyxNdVa8belj2TtYD3mFXudSRZFkaIn8TgafV9crYbKWuIij9Vz2rXRAC9BYXnEbWRz0a9J)HjM)CFtT6PSY)m6B23W36BcH0Nhko6BYv0f4SHV13mHkCdLdsG7CEQVZqc8cibc1tzLepuC08tYSqkjBrYD3mFXuK4fjlGRasMorsa8AgnibL3y8nVapuG3FZjiy4b215WlaFaXsID7Kmbbdpyxmk45fmeY3AaXsID7KC3nZxm1a768NcGydFRbqXBVqKCajmLOF8JV5LJ(Z9pKP)CFtT6PSY)m6B23W36BYUyuWZlyiKV13KROlWzdFRV5SqkjPyXOassGfmeY3IemEyrY8wNdVa8bjmMBMtc8cizERZHxaoj3fxrKSWWKC3nZxmfjErsyPKuQniiHPercsVBXrKSHLcW4iLeiKsYwKC5KavzfHijSusyZ9jfqIJiHTbbjlmjHLsYmNaExKCxSA1vWmjlGehMKWsbkjy8CMKAdsMus6AdlfqY8wNtscaaXg(wKewoIey3WkgKKYrO4SbjXsc6uDjjSusYnkiHDXOas8cgc5BrYctsyPKa7gwbjXsc215KOai2W3Ie4fqsTfj2Opb8UqJV5f4Hc8(BYcCffdKMHFSlgf88cgc5BrYrssJKjiy4b215WlaFaXsID7KCoj3fRwDfJzob8Ui5ij3DZ8ftnWUo)Pai2W3Aau82lejhKKeMsej2TtY0IqKCKey3WkEafV9crsQi5UBMVyQb215pfaXg(wdGI3EHijDsossAKa7gwXdO4Txisoijj3DZ8ftnWUo)Pai2W3Aau82lejmGeMMnjhj5UBMVyQb215pfaXg(wdGI3EHijvjjX4Yjz(sscsID7Ka7gwXdO4TxisoGK7Uz(IPgSlgf88cgc5Bn4qGo8TiXUDsGDdR4bu82lejPIK7Uz(IPgyxN)uaeB4BnakE7fIegqctZMe72j5Uy1QRymZjG3fj2TtYeem8ykVlpdHIbeljP)J)Hm8p33uREkR8pJ(MCfDboB4B9nNfsjHrn3qjXlKZvswysM3zqc8cijSusGDakibcPKSas2IegpHK0WHcijSusGDakibcPdssCpSi5q3Wki5mALeRnZjbEbKmVZy8nRgx)MiVGHYpJCZ9owa6n1Cd9TWpyfSxpo9nVapuG3FZjiy4b215WlaFaXsID7KeoUsYbKWuIi5ijPrY5KCxSA1vmk3WkEWTss6FZ(g(wFtKxWq5NrU5Ehla9MAUH(w4hSc2RhN(X)WZ8p33uREkR8pJ(M9n8T(MWT(mGAa37c9n5k6cC2W36BolKsYz0kj2iqnG7DHizlsy8esYcfiNRKSWKmV15WlaFqYSqkjNrRKyJa1aU3fhrIxKmV15WlaNehMKtlejwnwLe1dlfqIncyXQKKalSUXc6W3IKfqYz4AMtYctcJYlcT4ObjjE7bjWlGe(gisILKjLeiwsMu4fOK03WX2HxgKCgTsIncud4ExisILe82g44osjjSusMGGHhFZlWdf4938CsMGGHhyxNdVa8beljhjjnsoNK7Uz(IPgyxN)Ifa0kgqSKy3ojNts0zTIb215VybaTIHw9uw5KKojhjjnsW2aVNY6GVb6bXsYrsqSAo)IgyObAGTXzDGFFXcDTijjjmrID7K03WXQp(gdSnoRd87lwORfjjjbXQ58lAGHgOb2gN1b(9fl01IKJKGy1C(fnWqd0aBJZ6a)(If6ArYbKWejPtID7KmbbdpWUohEb4diwsossAKGwO8Kx8HbyXQpVW6glOdFRHw9uw5Ky3ojOfkp5fFa7AM)w43uErOfhn0QNYkNK0)X)We8p33uREkR8pJ(M9n8T(M4EXnACf9nVNUz9fnWqd0)qM(MxGhkW7VPxOU84ejPIeg7erYrssJK0ibBd8EkRJoNF8nqpiwsossAKCoj3DZ8ftnWUo)Pai2W3AaXsID7KCojrN1kgwqLHc8Y4HDD(qREkRCssNK0jXUDsMGGHhyxNdVa8beljPtYrssJKZjj6SwXWcQmuGxgpSRZhA1tzLtID7KW1jiy4HfuzOaVmEyxNpakE7fIKdi52O4foUsID7KCojtqWWdSRZHxa(aILK0j5ijPrY5KeDwRyG0g4LXRCdRaVb6qREkRCsSBNeeRMZVObgAGg4EXFiTbKKksMnjP)n5k6cC2W36BolKsYz5f3OXvejyS0IKoNj5mjjH7CisAGscelZKSasoTqK0aLeVizERZHxa(GKeqHGakjmMqLHc8YGK5ToNemEotck8CMKjLeiwsWyPfjHLsYTrbjHJRKa7LJSu0GeZyzjbc5LbjDqYSzajrdm0arcgpSiXuBGxgKCOByf4nqh)4F4S)Z9n1QNYk)ZOVzFdFRVjuzT5tVAX2FtUIUaNn8T(MZcPKmRYAZNi5WfBtYwKW4jKzsS2m3ldsMaUcNprsSKGP9Ge4fqc7IrbK4fmeY3IKfqsZ5KGyBmfA8nVapuG3FZ0ijnsoNeq78NIvRy0CoAaXsYrsaTZFkwTIrZ5OHxKCajmmrKKoj2TtcOD(tXQvmAohnakE7fIKdssctZMe72jb0o)Py1kgnNJgCiqh(wKKksyA2KKojhjjnsMGGHhSlgf88cgc5BnGyjXUDsU7M5lMAWUyuWZlyiKV1aO4TxisoijjmLisSBNKZjHf4kkgind)yxmk45fmeY3IK0j5ijPrY5KeDwRyybvgkWlJh215dT6PSYjXUDs46eem8WcQmuGxgpSRZhqSKy3ojNtYeem8a76C4fGpGyjj9F8p0g(N7BQvpLv(NrFZ(g(wFZPDR3c)cl91ORwCL)n5k6cC2W36BolKsYwKW4jKKjOGewGVapCKsceYldsM36Cssaai2W3IeyhGcMjXHjbcPCs8c5CLKfMK5DgKSfjMZrcesjPHdfqstc215tBoibEbKC3nZxmfjkmSFDTUNiPlojWlGelOYqbEzqc215KaXgoUsIdts0zTcLp(MxGhkW7V55KmbbdpWUohEb4diwsosY5KC3nZxm1a768NcGydFRbeljhjbXQ58lAGHgObUx8hsBajhqctKCKKZjj6SwXaPnWlJx5gwbEd0Hw9uw5Ky3ojPrYeem8a76C4fGpGyj5ijiwnNFrdm0anW9I)qAdijvKWqsosY5KeDwRyG0g4LXRCdRaVb6qREkRCsossAKWcuSpJlFW0a76830MdsossAKCojAkb5SSkFO4SNaANFlGxDDvsSBNKZjj6SwXWcQmuGxgpSRZhA1tzLts6Ky3ojAkb5SSkFO4SNaANFlGxDDvsosYD3mFXudfN9eq78Bb8QRRoakE7fIKuLKeMSHmKKJKW1jiy4HfuzOaVmEyxNpGyjjDssNe72jjnsMGGHhyxNdVa8beljhjj6SwXaPnWlJx5gwbEd0Hw9uw5KK(p(hMy(Z9n1QNYk)ZOVzFdFRV5TZ5xFdFRx2rX3m7O4vnU(ndGxZOb6h)dTX)5(MA1tzL)z03SVHV13eoRiRlOHJVjxrxGZg(wFZzHusoJSISUGgoizHcKZvswysWBVi5UBMVykejXscE7v0ErY82ChEwjXCZy1kizccgE8nVapuG3Ft0cLN8IpWU5o8S(qBgRwXqREkRCsosYeem8a7M7WZ6dTzSAfpli8UwNpakE7fIKurctjIKJKCojtqWWdSRZHxa(aILKJKCojtqWWd2fJcEEbdH8TgqS)4hFZPDR)C)dz6p33uREkR8pJ(MxGhkW7VjIvZ5x0adnqdCV4pK2assvssoZVzFdFRVzJUAXv(Bk3O4h)dz4FUVPw9uw5Fg9nVapuG3FteRMZVObgAGgn6Qfx5VAX2KCajmrYrsqSAo)IgyObAG7f)H0gqYbKWejmGKOZAfdK2aVmELByf4nqhA1tzL)n7B4B9nB0vlUYF1IT)Xp(MCfUHYXFU)Hm9N7B23W36BI8Swx9BQvpLv(Nr)4Fid)Z9n1QNYk)ZOV5f4Hc8(BobbdpWUohEb4diwsSBNKjiy4b7IrbpVGHq(wdi2VzFdFRVj7g(w)4F4z(N7BQvpLv(NrFZL9BI04B23W36BITbEpL1Vj2odPFt(gdKvZxmpmlG)yBVgHFNXldsoscFJb2gN1b(9fl01Ae(DgVm(MyBWRAC9BY3a9Gy)X)We8p33uREkR8pJ(Ml73ePX3SVHV13eBd8EkRFtSDgs)M8ngiRMVyEywa)X2Enc)oJxgKCKe(gdSnoRd87lwOR1i87mEzqYrs4Bm4k2fc4LXJn3gq6i87mEz8nX2Gx1463SZ5hFd0dI9h)dN9FUVPw9uw5Fg9nx2VjsJVzFdFRVj2g49uw)My7mK(nrSAo)IgyObAG7f)H0gqYbKWqsyajtqWWdSRZHxa(aI9BYv0f4SHV130mAqqceYldsm1g4Lbjh6gwbEdus6GKZKbKenWqdejlGKeKbK4WKCAHiPbkjErY8wNdVa8Vj2g8Qgx)MiTbEz8k3WkWBG(UqXcd)J)H2W)CFtT6PSY)m6BUSFtKgFZ(g(wFtSnW7PS(nX2zi9BE3nZxm1a768NcGydFRbeljhjjnsoNeq78NIvRy0CoAaXsID7KaAN)uSAfJMZrdoeOdFlssvssykrKy3ojG25pfRwXO5C0aO4TxisoijjmLisyajZMK5ljPrs0zTIHfuzOaVmEyxNp0QNYkNe72j5Uy1QRymZjG3fjPts6KCKK0ijnsaTZFkwTIrZ5OHxKCajmmrKy3ojiwnNFrdm0anWUo)Pai2W3IKdssYSjjDsSBNKOZAfdlOYqbEz8WUoFOvpLvoj2TtYDXQvxXyMtaVlssNKJKKgjNtcaQu4fyOdeRLcu0ZQb4BDAOPeKZYQCsSBNK0i5UBMVyQb7IrbpVGHq(wdGI3EHijvjjX4Yh4TnGK5ljNjj2TtYeem8GDXOGNxWqiFRbelj2TtY0IqKCKey3WkEafV9crsQsscdNnjPts6FtUIUaNn8T(Mm(Uz(IPijf7MjzEnW7PSYmjZcPCsILe2DZKmPWlqjPVHJTdVmib76C4fGpiHXHaaTI8jsGqkNKyj5Uva2mjyS0IKyjPVHJTdLeSRZHxaojy8WIeVUlUxgK0CoA8nX2Gx1463KD38dEbVlh9J)HjM)CFtT6PSY)m6BEbEOaV)MtqWWdSRZHxa(aI9B23W36Bc7aDkVl)h)dTX)5(MA1tzL)z038c8qbE)nNGGHhyxNdVa8be73SVHV13CsbifmJxg)4FiJ9FUVPw9uw5Fg9n7B4B9nZUHvGEmwG4g4AfFtUIUaNn8T(MZcPKWy4gwXzJiXwiUbUwbjomjHLcusAGscdjzbKGVaLKObgAGyMKfqsZ5isAGwNDqcITXuEzqc8cibFbkjHvxKKyMnA8nVapuG3FteRMZVObgAGgz3WkqpglqCdCTcsoijjmKe72jjnsoNeq78NIvRy0CoAO2ahfisSBNeq78NIvRy0CoA4fjhqsIz2KK(p(hYuI(Z9n1QNYk)ZOV5f4Hc8(BobbdpWUohEb4di2VzFdFRVzxxffGo)UDo)J)HmX0FUVPw9uw5Fg9n7B4B9nVDo)6B4B9Yok(MzhfVQX1V5fZ9h)dzIH)5(MA1tzL)z03SVHV13eavV(g(wVSJIVz2rXRAC9BI3E9JF8JVjwfG8T(hYWeXqMsKnKH24VjMguEzG(MjEkZy1HjWdTrMFsizolLehNDbbjWlGKZ(YrNnjanLGCGYjbT4kjnuS4DOCsUwDzOObzlJHxkj2W5NegFlSkiuojNDa8Agng90DC3nZxm1ztsSKC23DZ8ftn6P7ztsAmzdsFq2Yy4LsInE(jHX3cRccLtYzJwO8Kx8HnQNnjXsYzJwO8Kx8HnQdT6PSYpBssJjBq6dYwY2eio7ccLtInMK(g(wKKDuGgKTFtwWc7z9BM6utIPvZxmKKcGROGSn1PMeBHkLegYyZmjmmrmKjYwY2uNAsMdJ2ZqY8wNtYClaOvqcglTijAGHgKCxOkqK0aLe4fCv(GSLSn1PMKeGnqVqHYjzsHxGsYDXN6GKj1Wl0GKu(Ev2arsT18PvdWHHYK03W3crYw5tdY2(g(wOblqVl(uhmiPnzxmk4Hzb8h8ccpG4kZoCsGI3EHs1zMOer223W3cnyb6DXN6GbjTjYQ5lg4fGZSdN88jiy4bYQ5lg4fGpGyjB7B4BHgSa9U4tDWGK2Sb3U0xSaGwbZoCsVqD5XPbxH9RhhW0SjB7B4BHgSa9U4tDWGK2eBd8EkRmxnUMe3l(dPn4DHIfgM5LnjsdMX2zinjdjB7B4BHgSa9U4tDWGK2eBJZ6a)(If6Ar2s2M6utsk2W3cr223W3cLe5zTUkzBFdFlus2n8Ty2HtobbdpWUohEb4diw72NGGHhSlgf88cgc5BnGyjB7B4BHyqsBITbEpLvMRgxtY3a9GyzEztI0GzSDgstY3yGSA(I5Hzb8hB71i87mEzCKVXaBJZ6a)(If6Anc)oJxgKT9n8TqmiPnX2aVNYkZvJRj7C(X3a9GyzEztI0GzSDgstY3yGSA(I5Hzb8hB71i87mEzCKVXaBJZ6a)(If6Anc)oJxgh5Bm4k2fc4LXJn3gq6i87mEzq2MAsmJgeKaH8YGetTbEzqYHUHvG3aLKoi5mzajrdm0arYcijbzajomjNwisAGsIxKmV15WlaNSTVHVfIbjTj2g49uwzUACnjsBGxgVYnSc8gOVluSWWmVSjrAWm2odPjrSAo)IgyObAG7f)H0gCadzWeem8a76C4fGpGyjBtnjm(Uz(IPijf7MjzEnW7PSYmjZcPCsILe2DZKmPWlqjPVHJTdVmib76C4fGpiHXHaaTI8jsGqkNKyj5Uva2mjyS0IKyjPVHJTdLeSRZHxaojy8WIeVUlUxgK0CoAq223W3cXGK2eBd8EkRmxnUMKD38dEbVlhX8YMePbZy7mKM8UBMVyQb215pfaXg(wdi2JPDoOD(tXQvmAohnGyTBh0o)Py1kgnNJgCiqh(wPkjtjYUDq78NIvRy0CoAau82l0bjzkrmy2Z30IoRvmSGkdf4LXd768Hw9uw52TFxSA1vmM5eW7k90pMwAG25pfRwXO5C0WRdyyISBhXQ58lAGHgOb215pfaXg(whKC2PB3E0zTIHfuzOaVmEyxNp0QNYk3U97IvRUIXmNaExPFmTZbqLcVadDGyTuGIEwnaFRtdnLGCwwLB3EA3DZ8ftnyxmk45fmeY3Aau82luQsAC5d82gmFpt72NGGHhSlgf88cgc5BnGyTBFArOJWUHv8akE7fkvjz4StpDY2(g(wigK0MWoqNY7Yz2HtobbdpWUohEb4diwY2(g(wigK0MtkaPGz8YGzho5eem8a76C4fGpGyjBtnjZcPKWy4gwXzJiXwiUbUwbjomjHLcusAGscdjzbKGVaLKObgAGyMKfqsZ5isAGwNDqcITXuEzqc8cibFbkjHvxKKyMnAq223W3cXGK2m7gwb6XybIBGRvWSdNeXQ58lAGHgOr2nSc0JXce3axR4GKm0U90oh0o)Py1kgnNJgQnWrbYUDq78NIvRy0CoA41bjMzNozBFdFledsAZUUkkaD(D7CMzho5eem8a76C4fGpGyjB7B4BHyqsBE7C(13W36LDuWC14AYlMlzBFdFledsAtau96B4B9YokyUACnjE7fzlzBQtnjPCkymijwsGqkjyS0IegTBrYctsyPKKYORwCLtIJiPVHJvjB7B4BHgt7wjB0vlUYFt5gfm7WjrSAo)IgyObAG7f)H0gKQKNjzBFdFl0yA3IbjTzJUAXv(RwSnZoCseRMZVObgAGgn6Qfx5VAX2hW0reRMZVObgAGg4EXFiTbhWedIoRvmqAd8Y4vUHvG3aDOvpLvozlzBQtnjmEcrKTPMKzHussXIrbKKalyiKVfjy8WIK5TohEb4dsym3mNe4fqY8wNdVaCsUlUIizHHj5UBMVyks8IKWsjPuBqqctjIeKE3IJizdlfGXrkjqiLKTi5YjbQYkcrsyPKWM7tkGehrcBdcswysclLKzob8Ui5Uy1QRGzswajomjHLcusW45mj1gKmPK01gwkGK5ToNKeaaIn8TijSCejWUHvmijLJqXzdsILe0P6ssyPKKBuqc7IrbK4fmeY3IKfMKWsjb2nScsILeSRZjrbqSHVfjWlGKAlsSrFc4DHgKT9n8TqJlhLKDXOGNxWqiFlMD4KSaxrXaPz4h7IrbpVGHq(whtBccgEGDDo8cWhqS2TF(DXQvxXyMtaVRJ3DZ8ftnWUo)Pai2W3Aau82l0bjzkr2TpTi0ry3WkEafV9cLQ7Uz(IPgyxN)uaeB4BnakE7fk9JPb7gwXdO4TxOdsE3nZxm1a768NcGydFRbqXBVqmGPzF8UBMVyQb215pfaXg(wdGI3EHsvsJlF(MG2Td7gwXdO4TxOdU7M5lMAWUyuWZlyiKV1Gdb6W3YUDy3WkEafV9cLQ7Uz(IPgyxN)uaeB4BnakE7fIbmnB72VlwT6kgZCc4Dz3(eem8ykVlpdHIbeB6KTPMKzHusm9SwxLKTiHXtijXsclyVKyQSwq2OC2issbyV5gVdFRbzBQjPVHVfAC5igK0MipR1vzoAGHgphojaQu4fyOdKYAbzJc6Xc2BUX7W3AOPeKZYQ8JPfnWqJHJEnNB3E0adngCDccgECBu4LXaO9nsNSn1KmlKscJAUHsIxiNRKSWKmVZGe4fqsyPKa7auqcesjzbKSfjmEcjPHdfqsyPKa7auqceshKK4EyrYHUHvqYz0kjwBMtc8cizENXGSTVHVfAC5igK0Mqi95HIZC14AsKxWq5NrU5Ehla9MAUH(w4hSc2RhNy2HtobbdpWUohEb4diw72dhxpGPeDmTZVlwT6kgLByfp4wtNSn1KmlKsYz0kj2iqnG7DHizlsy8esYcfiNRKSWKmV15WlaFqYSqkjNrRKyJa1aU3fhrIxKmV15WlaNehMKtlejwnwLe1dlfqIncyXQKKalSUXc6W3IKfqYz4AMtYctcJYlcT4ObjjE7bjWlGe(gisILKjLeiwsMu4fOK03WX2HxgKCgTsIncud4ExisILe82g44osjjSusMGGHhKT9n8TqJlhXGK2eU1Nbud4ExiMD4KNpbbdpWUohEb4di2JPD(D3mFXudSRZFXcaAfdiw72pp6SwXa768xSaGwXqREkR80pMg2g49uwh8nqpi2JiwnNFrdm0anW24SoWVVyHUwjzYU9(gow9X3yGTXzDGFFXcDTsIy1C(fnWqd0aBJZ6a)(If6ADeXQ58lAGHgOb2gN1b(9fl016aMs3U9jiy4b215WlaFaXEmn0cLN8Ipmalw95fw3ybD4Bn0QNYk3UD0cLN8IpGDnZFl8BkVi0IJgA1tzLNozBQjzwiLKZYlUrJRisWyPfjDotYzssc35qK0aLeiwMjzbKCAHiPbkjErY8wNdVa8bjjGcbbusymHkdf4LbjZBDojy8CMeu45mjtkjqSKGXslsclLKBJcschxjb2lhzPObjMXYsceYlds6GKzZasIgyObIemEyrIP2aVmi5q3WkWBGoiB7B4BHgxoIbjTjUxCJgxrmFpDZ6lAGHgOKmXSdN0luxECkvm2j6yAPHTbEpL1rNZp(gOhe7X0o)UBMVyQb215pfaXg(wdiw72pp6SwXWcQmuGxgpSRZhA1tzLNE62TpbbdpWUohEb4di20pM25rN1kgwqLHc8Y4HDD(qREkRC7256eem8WcQmuGxgpSRZhafV9cDWTrXlCC1U9ZNGGHhyxNdVa8beB6ht78OZAfdK2aVmELByf4nqhA1tzLB3oIvZ5x0adnqdCV4pK2Gun70jBtnjZcPKmRYAZNi5WfBtYwKW4jKzsS2m3ldsMaUcNprsSKGP9Ge4fqc7IrbK4fmeY3IKfqsZ5KGyBmfAq223W3cnUCedsAtOYAZNE1ITz2HtMwANdAN)uSAfJMZrdi2JG25pfRwXO5C0WRdyyIs3UDq78NIvRy0CoAau82l0bjzA22TdAN)uSAfJMZrdoeOdFRuX0St)yAtqWWd2fJcEEbdH8TgqS2TF3nZxm1GDXOGNxWqiFRbqXBVqhKKPez3(5SaxrXaPz4h7IrbpVGHq(wPFmTZJoRvmSGkdf4LXd768Hw9uw52TZ1jiy4HfuzOaVmEyxNpGyTB)8jiy4b215WlaFaXMozBQjzwiLKTiHXtijtqbjSaFbE4iLeiKxgKmV15KKaaqSHVfjWoafmtIdtces5K4fY5kjlmjZ7mizlsmNJeiKssdhkGKMeSRZN2Cqc8ci5UBMVyksuyy)6ADprsxCsGxajwqLHc8YGeSRZjbInCCLehMKOZAfkFq223W3cnUCedsAZPDR3c)cl91ORwCLZSdN88jiy4b215WlaFaXE887Uz(IPgyxN)uaeB4BnGypIy1C(fnWqd0a3l(dPn4aMoEE0zTIbsBGxgVYnSc8gOdT6PSYTBpTjiy4b215WlaFaXEeXQ58lAGHgObUx8hsBqQy4XZJoRvmqAd8Y4vUHvG3aDOvpLv(X0ybk2NXLpyAGDD(BAZXX0oxtjiNLv5dfN9eq78Bb8QRRA3(5rN1kgwqLHc8Y4HDD(qREkR80TBxtjiNLv5dfN9eq78Bb8QRREmaEnJgdfN9eq78Bb8QRRoU7M5lMAau82luQsYKnKHh56eem8WcQmuGxgpSRZhqSPNUD7PnbbdpWUohEb4di2JrN1kgiTbEz8k3WkWBGo0QNYkpDY2(g(wOXLJyqsBE7C(13W36LDuWC14AYa41mAGiBtnjZcPKCgzfzDbnCqYcfiNRKSWKG3ErYD3mFXuisILe82RO9IK5T5o8SsI5MXQvqYeem8GSTVHVfAC5igK0MWzfzDbnCWSdNeTq5jV4dSBUdpRp0MXQvCCccgEGDZD4z9H2mwTINfeExRZhafV9cLkMs0XZNGGHhyxNdVa8be7XZNGGHhSlgf88cgc5BnGyjBjBtDQjHXBuqsIB5zLegVrHxgK03W3cniXuds6Gel3WsbKWc8f4XjsILeK1ccsUo4c5bjEfkaaXgKC3I7HVfIKTi5S8ItIP2aBEg5(ezBQjzwiLetTbEzqYHUHvG3aLehMKtlejy8CMelpirRfYWIKObgAGiPlojPyXOassGfmeY3IKU4KmV15WlaNKgOKuBqcqB(jMjzbKeljafgOilsmt85pfKSfjbMLKfqc(cusIgyObAq223W3cnUyUjrAd8Y4vUHvG3aLziK(Wy5z9DBu4LrsMy(E6M1x0adnqjzIzhozAyBG3tzDG0g4LXRCdRaVb67cflm8XZX2aVNY6GD38dEbVlhLUD7PX3yGSA(I5Hzb8hB71aOWafz1tz9iIvZ5x0adnqdCV4pK2GdykDY2utIP1ccsyChCH8GetTbEzqYHUHvG3aLK7wCp8TijwsMrvwsmt85pfKaXsIxKKYBcGSTVHVfACXCzqsBI0g4LXRCdRaVbkZqi9HXYZ672OWlJKmX890nRVObgAGsYeZoCYOZAfdK2aVmELByf4nqhA1tzLFKVXaz18fZdZc4p22RbqHbkYQNY6reRMZVObgAGg4EXFiTbhWqY2utYw5tVlMlj49mkIKWsjPVHVfjBLprceQNYkjCiGxgKCT6Q0SxgK0fNKAdsAejnja1ak3as6B4BniB7B4BHgxmxgK0M4EXFt5gfmVv(07I5MKjYwY2(g(wObh34faVMrdusiK(8qXzUACnjVbZGVB946DM3Jfkak6Q1vjB7B4BHgCCJxa8AgnqmiPnHq6ZdfN5QX1KiOAkVl)14AyDcfKT9n8TqdoUXlaEnJgigK0Mqi95HIZC14AsJ8jwR3c)AeYX9Ch(wKT9n8TqdoUXlaEnJgigK0Mqi95HIZC14AsoqBoSd0hwfH0mzlzBQtnjNv7fjPCkymyMeK1cL5KCxSkGKoNjb0LHIizHjjAGHgis6Itc6Qvd8fr223W3cnWBVsE7C(13W36LDuWC14AYPDlMD4KtqWWJPDR3c)cl91ORwCLpGyjB7B4BHg4TxmiPn5oIvZp82WVm7WjppAGHgdh9yZ9jfq2MAsMfsjzERZjjbaGydFls2IK7Uz(IPiHD3SxgK0bjzTrbjjyIiXluxECIKjOGKAdsCysoTqKGXZzswSk42SK4fQlporIxKmVZyqYz1ZOKGGakjiRMVyGDT42e3l(KwCfqsxCsolV4KWOCJcsCejBrYD3mFXuKmPWlqjzEjGbjjqJAbkjS7M9YGeGIcGFdFlejomjqiVmiX0Q5lg4CJRKKcGJWjPlojmslUciXrKSqXGSTVHVfAG3EXGK2e768NcGydFlMD4KyBG3tzDWUB(bVG3LJoMMxOU840bjtWez3oRgdyxl(OVHJvpcGkfEbg6az18fdCUX1hlWr4dnLGCwwLF887Uz(IPg4EXFt5gfdi2JNF3nZxm1az18fZdZc4pU2H1aIn9JP5fQlpoLQK24zB3E0zTIbsBGxgVYnSc8gOdT6PSYpITbEpL1bsBGxgVYnSc8gOVluSWWPF887Uz(IPgWUw8be7X0o)UBMVyQbUx83uUrXaI1UDeRMZVObgAGg4EXFiTbhWW0jBtnjNvpJscccOKCAHiHfkibILeZeF(tbjPSzkNcs2IKWsjjAGHgK4WKK4GoSGHYKCgTcCLehvNDqsFdhRscglTib2nScVmiHP5ZZKKObgAGgKT9n8Tqd82lgK0MiRMVyEywa)X2EXSdNCccgEa36ZaQbCVl0aI945CDccgEGb0Hfmu(b3kW1be7reRMZVObgAGg4EXFiTbPkbjB7B4BHg4TxmiPnVDo)6B4B9YokyUACn5LJiBtnjmMUHfjPa4lWJtKCwEXjXuBaj9n8TijwsakmqrwKKWDoejy8WIeK2aVmELByf4nqjB7B4BHg4TxmiPnX9I)qAdy(E6M1x0adnqjzIzhoz0zTIbsBGxgVYnSc8gOdT6PSYpIy1C(fnWqd0a3l(dPn4aSnW7PSoW9I)qAdExOyHHpEoFJbYQ5lMhMfWFSTxJWVZ4LXXZV7M5lMAa7AXhqSKTPMKuauyfqsSKaHussyJxD4BrskBMYPGehMKUorsc35iXrKuBqce7GSTVHVfAG3EXGK2K34vh(wmFpDZ6lAGHgOKmXSdN8CSnW7PSo6C(X3a9GyjBtnjZcPKyA18fdjj(c4KKqTdlsCysGqEzqIPvZxmW5gxjjfahHtsxCsM0IRasW45mjQnG1bkjCiGxgKewkjLAdcsmU8bzBFdFl0aV9IbjTjYQ5lMhMfWFCTdlMD4KSAmGDT4J(gow9iaQu4fyOdKvZxmW5gxFSahHp0ucYzzv(rwngWUw8bqXBVqPkPXLt2MAss5mM(eIeiKscUx8PCJcejomj3MLv5K0fNelOYqbEzqc215K4isGyjPlojqiVmiX0Q5lg4CJRKKcGJWjPlojtAXvajoIei2bjKKYCUh(wDoFIzsUnkib3l(uUrbjomjNwisWSqzojtkjqvpLvsILednijSusaoCqY0jsW0E4Lbjnjgx(GSTVHVfAG3EXGK2e3l(Bk3OGzhozA3DZ8ftnW9I)MYnkgxRgyOOdy6yACDccgEybvgkWlJh215diw72pp6SwXWcQmuGxgpSRZhA1tzLNUD7SAmGDT4dGI3EHsvYBJIx44kdmU80pYQXa21Ip6B4y1JaOsHxGHoqwnFXaNBC9XcCe(qtjiNLv5hz1ya7AXhafV9cDWTrXlCCLSn1KmlKsY8wNtcJ2CqshKy5gwkGewGVaporcgpSiHXeQmuGxgKmV15KaXssSKKGKenWqdeZKSas2WsbKeDwRarYwKyo3GSTVHVfAG3EXGK2e76830MdMD4KEH6YJtPkPnE2hJoRvmSGkdf4LXd768Hw9uw5hJoRvmqAd8Y4vUHvG3aDOvpLv(reRMZVObgAGg4EXFiTbPkPn0U90sl6SwXWcQmuGxgpSRZhA1tzLF88OZAfdK2aVmELByf4nqhA1tzLNUD7iwnNFrdm0anW9I)qAdsYu6KTPMKeU1zhKaHussOIDHaEzqskYTbKsIdtYPfIKBxKyObjEfljZBDo8cWjXluOnNzswajomjMAd8YGKdDdRaVbkjoIKOZAfkNKU4KGXZzsS8GeTwidlsIgyObAq223W3cnWBVyqsBYvSleWlJhBUnGuMD4KPbuyGIS6PSA3UxOU840bjMzN(X0ohBd8EkRd2DZp4f8UCKD7EH6YJthK0gp70pM25rN1kgiTbEz8k3WkWBGo0QNYk3U90IoRvmqAd8Y4vUHvG3aDOvpLv(XZX2aVNY6aPnWlJx5gwbEd03fkwy40tNSn1KmlKsY8yejBrcJNqsCysoTqKW36Sdskv5Kelj3gfKKqf7cb8YGKuKBdiLzs6ItsyPaLKgOKKveIKWQlssqsIgyObIKfkijTztcgpSi5UfhYJ0hKT9n8Tqd82lgK0MyxN)M2CWSdNeXQ58lAGHgObUx8hsBqQslbzWDloKhdUJqB1v80R1QOHw9uw5PF0luxECkvjTXZ(y0zTIbsBGxgVYnSc8gOdT6PSYTB)8OZAfdK2aVmELByf4nqhA1tzLt2MAsMfsjX0Q5lgss8fWNFssO2HfjomjHLss0adniXrK0tluqsSKWDLKfqYPfIeRgRsIPvZxmW5gxjjfahHtIMsqolRYjbJhwKCwEXN0IRaswajMwnFXa7AXjPVHJvhKT9n8Tqd82lgK0MiRMVyEywa)X1oSy(E6M1x0adnqjzIzhozArdm0yyPDoSgS3ivmmrhrSAo)IgyObAG7f)H0gKQemD72tJvJbSRfF03WXQhbqLcVadDGSA(Ibo346Jf4i8HMsqolRYtNSn1KmlKsIjeaOfxbKeljNvZlfHizlsAsIgyObjHvhK4ismwVmijws4UsshKewkja3WkijCCDq223W3cnWBVyqsBIGaaT4k4f7dV5LIqmFpDZ6lAGHgOKmXSdNmAGHgJWX1xSpURPIHZ(4eem8a76C4fGp4lMISn1KmlKsY8wNtYClaOvqYw5tK4WKyM4ZFkiPlojZBosAGssFdhRssxCsclLKObgAqcMTo7GeURKWHaEzqsyPKCT6Q08GSTVHVfAG3EXGK2e768xSaGwbZ3t3S(IgyObkjtm7WjX2aVNY6GVb6bXEmAGHgJWX1xSpURhCMhtBccgEGDDo8cWh8ftz3(eem8a76C4fGpakE7fkv3DZ8ftnWUo)nT5yau82lu6h7B4y1hFJb2gN1b(9fl01kjIvZ5x0adnqdSnoRd87lwOR1reRMZVObgAGg4EXFiTbPkTzZG0SHZ3OZAfJaJJI3c)G7qhA1tzLNE6KT9n8Tqd82lgK0M4EXN0IRaMD4K8ngyBCwh43xSqxRr43z8Y4yArN1kgiTbEz8k3WkWBGo0QNYk)iIvZ5x0adnqdCV4pK2GdW2aVNY6a3l(dPn4DHIfg2UD(gdKvZxmpmlG)yBVgHFNXlJ0pM25aOsHxGHoqwnFXaNBC9XcCe(qtjiNLv52T33WXQp(gdSnoRd87lwOR1bjVNUz9PLI7kkDY2utYSqkjMj(8NqsW4HfjPO9AcO9mkGKuG6mojqvwrisclLKObgAqcgpNjzsjzsZlgsyyIySMKjfEbkjHLsYD3mFXuKCxCfrYuFNzq223W3cnWBVyqsBISA(I5Hzb8hx7WIzhojaQu4fyOd22RjG2ZOGhlQZ4dnLGCwwLFeBd8EkRd(gOhe7XObgAmchxFX(yVXJHj6G0U7M5lMAGSA(I5Hzb8hx7WAWHaD4BXaJlpDY2utYSqkjMwnFXqcJdAKfjBrcJNqsGQSIqKewkqjPbkjnNJiXR7I7LXGSTVHVfAG3EXGK2ez18fZ7cAKfZoCsq78NIvRy0CoA41bmLiY2utYSqkjNLxCsm1gqsSKC3cbHRKKWgmdjZzTqgwbIewWErKSfjPCInbmizUeBctSKW4Bb7aCsCejHLJiXrK0Ky5gwkGewGVaporsy1fjaLVr4LbjBrskNytaKavzfHiH3GzijSwidRarIJiPNwOGKyjjCCLKfkiB7B4BHg4TxmiPnX9I)qAdy(E6M1x0adnqjzIzhojIvZ5x0adnqdCV4pK2GdW2aVNY6a3l(dPn4DHIfg(4eem8G3GzEH1czyfdiwMVwTxjzIzVcfaGyJNJJRCVdnjtm7vOaaeB8C4KHFNbDqsgs2MAsMfsj5S8ItYzK7tKelj3Tqq4kjjSbZqYCwlKHvGiHfSxejBrI5CdsMlXMWeljm(wWoaNehMKWYrK4isAsSCdlfqclWxGhNijS6IeGY3i8YGeOkRiej8gmdjH1czyfisCej90cfKeljHJRKSqbzBFdFl0aV9IbjTjUx8hCUpXSdNCccgEWBWmVWAHmSIbe7rSnW7PSo4BGEqSmFTAVsYeZEfkaaXgphhx5EhAsMy2Rqbai245Wjd)od6GKm84D3mFXudSRZFtBogqSKTPMKzHusolV4KWOCJcsCysoTqKW36Sdskv5KeljafgOilss4ohAqIzSSKCBu4LbjDqscsYcibFbkjrdm0arcgpSiXuBGxgKCOByf4nqjj6SwHYjPlojNwisAGssTbjqiVmiX0Q5lg4CJRKKcGJWjzbKKc0PRLFjHXWRzgiwnNFrdm0anW9I)qAdoy(4SjXqdejHLscUxooeojlmjZMKU4Kewkjfe(KcizHjjAGHgObjPCgTmtcFjP2GewGIqKG7fFk3OGeOk8mjDots0adnqK0aLe(gHYjbJhwKmV5ibJLwKaH8YGeKvZxmW5gxjHf4iCsCysM0IRasCejn22Z9uwhKT9n8Tqd82lgK0M4EXFt5gfm7WjX2aVNY6GVb6bXEe0o)Py1kg4lwfxRy41b3gfVWXvgKOXSpIy1C(fnWqd0a3l(dPnivPLGmGHZ3OZAfdChPGtdT6PSYzqFdhR(4BmW24SoWVVyHUwZ3OZAfdw0PRLFFzVMzOvpLvodsdXQ58lAGHgObUx8hsBWbZhND6Z30y1ya7AXh9nCS6rauPWlWqhiRMVyGZnU(ybocFOPeKZYQ80t)yANdGkfEbg6az18fdCUX1hlWr4dnLGCwwLB3(53DZ8ftnGDT4di2JaOsHxGHoqwnFXaNBC9XcCe(qtjiNLv52T33WXQp(gdSnoRd87lwOR1bjVNUz9PLI7kkDY2(g(wObE7fdsAtSnoRd87lwORfZ3t3S(IgyObkjtm7Wjbkmqrw9uwpgnWqJr446l2h31dSH2TNw0zTIbUJuWPHw9uw5h5BmqwnFX8WSa(JT9AauyGIS6PSMUD7tqWWdOcgcK9Y4XBWmLIqdiwY2utIjRE9otYDlUh(wKeljOyzj52OWldsmt85pfKSfjlm88z0adnqKGXslsGDdRWldsotswaj4lqjbf9DgLtc(oHiPlojqiVmijfOtxl)scJHxZqsxCsomXohjNLJuWPbzBFdFl0aV9IbjTjYQ5lMhMfWFSTxm7Wjbkmqrw9uwpgnWqJr446l2h31dsWJNhDwRyG7ifCAOvpLv(XOZAfdw0PRLFFzVMzOvpLv(reRMZVObgAGg4EXFiTbhWqY2utInAvzjXmXN)uqceljBrsJibVRtKenWqdejnIe2fH8PSYmjQn4QSbjyS0Iey3Wk8YGKZKKfqc(cusqrFNr5KGVtisW4HfjPaD6A5xsym8AMbzBFdFl0aV9IbjTjYQ5lMhMfWFSTxmFpDZ6lAGHgOKmXSdNeOWafz1tz9y0adngHJRVyFCxpibpEE0zTIbUJuWPHw9uw5hppTOZAfdK2aVmELByf4nqhA1tzLFeXQ58lAGHgObUx8hsBWbyBG3tzDG7f)H0g8UqXcdN(X0op6SwXGfD6A53x2RzgA1tzLB3EArN1kgSOtxl)(YEnZqREkR8JiwnNFrdm0anW9I)qAdsvsgME6KT9n8Tqd82lgK0M4EXFiTbmFpDZ6lAGHgOKmXSdNeXQ58lAGHgObUx8hsBWbyBG3tzDG7f)H0g8UqXcdZ81Q9kjtm7vOaaeB8CCCL7DOjzIzVcfaGyJNdNm87mOdsYqY2(g(wObE7fdsAtCV4p4CFI5Rv7vsMy2Rqbai24544k37qtYeZEfkaaXgphoz43zqhKKHhV7M5lMAGDD(BAZXaILSn1KmlKsIzIp)jKKgrsUrbjafTGGehMKTijSusWxSkzBFdFl0aV9IbjTjYQ5lMhMfWFCTdlY2utYSqkjMj(8NcsAej5gfKau0ccsCys2IKWsjbFXQK0fNeZeF(tijoIKTiHXtizBFdFl0aV9IbjTjYQ5lMhMfWFSTxKTKTPMKzHus2IegpHKKYMPCkijwsm0GKeUZrs43z8YGKU4KO2awhOKeljzVusGyjzsJqbKGXdlsM36C4fGt223W3cncGxZObkjesFEO4mxnUMuXzpb0o)waV66Qm7WjV7M5lMAGDD(tbqSHV1aO4TxOuLKjgA3(D3mFXudSRZFkaIn8TgafV9cDadtmKTPMK5aNijwsmpvxssGZhsijy8WIKeUqtzLeZOVZOCsy8eIiXHjHDriFkRdssSfj5TmuajWUHvGibJhwKGVaLKe48HescesrK0rO4SbjXsc6uDjbJhwK01jsUCswajmwGqbjqiLepgKT9n8TqJa41mAGyqsBcH0NhkoZvJRj9cDbqrpL1xkb1vaH)4kw)Qm7WjNGGHhyxNdVa8be7Xjiy4b7IrbpVGHq(wdiw72Nwe6iSByfpGI3EHsvsgMi72NGGHhSlgf88cgc5BnGypE3nZxm1a768NcGydFRbqXBVqmGPzFaSByfpGI3EHSBFccgEGDDo8cWhqShV7M5lMAWUyuWZlyiKV1aO4TxigW0Spa2nSIhqXBVq2TN2D3mFXud2fJcEEbdH8TgafV9cDqsMs0X7Uz(IPgyxN)uaeB4BnakE7f6GKmLO0pc7gwXdO4TxOdsYeJDIiBtnjMNQljMwQgKCwqi)scgpSizERZHxaozBFdFl0iaEnJgigK0Mqi95HIZC14As8(2ta9HSunE4qi)YSdN8UBMVyQb215pfaXg(wdGI3EHoGPer2MAsmpvxsyScA6ejy8WIKuSyuajjWcgc5BrceQnuMjbVNrjbbbusILeu5SkjHLssEXOOGegZuqs0adniB7B4BHgbWRz0aXGK2ecPppuCMRgxtIwOCwJWlJhaA6eZoCYjiy4b7IrbpVGHq(wdiw72pNf4kkgind)yxmk45fmeY3I57PBwFrdm0aLKjY2utYSqkjmQ5gkjEHCUsYctY8odsGxajHLscSdqbjqiLKfqYwKW4jKKgouajHLscSdqbjqiDqIP1ccsUo4c5bjomjyxNtIcGydFlsU7M5lMIehrctjcrYcibFbkjnM(0GSTVHVfAeaVMrdedsAtiK(8qXzUACnjYlyO8Zi3CVJfGEtn3qFl8dwb71Jtm7WjV7M5lMAGDD(tbqSHV1aO4TxOdsYuIiBtnjZcPKKDuqYctYwZNqiLeEJ3gkjbWRz0arYw5tK4WKWycvgkWldsM36CssOobbdtIJiPVHJvzMKfqYPfIKgOKuBqs0zTcLtIxXsIhdY2(g(wOra8AgnqmiPnVDo)6B4B9YokyUACnjh34faVMrdeZoCY0op6SwXWcQmuGxgpSRZhA1tzLB3oxNGGHhwqLHc8Y4HDD(aIn9JPnbbdpWUohEb4diw72V7M5lMAGDD(tbqSHV1aO4TxOdykrPt2MAssOc3q5Ge4oNN67mKaVasGq9uwjXdfhn)KmlKsYwKC3nZxmfjErYc4kGKPtKeaVMrdsq5ngKT9n8TqJa41mAGyqsBcH0NhkoIzho5eem8a76C4fGpGyTBFccgEWUyuWZlyiKV1aI1U97Uz(IPgyxN)uaeB4BnakE7f6aMs03eXQ3)HmC224F8J)ha]] )
    

end
