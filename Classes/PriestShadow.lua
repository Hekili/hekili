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


    spec:RegisterPack( "Shadow", 20211101, [[divOzcqiPQ8iPs6scGu2Kk0NiankPsDkPkwfbaVIaAwuIULai2Lu(LaQHjvvogb1Yii9mPIQPrq4AQiABee5BcqACcqCoPckRtaQ5jGCpbAFQi9pPcQ6GsfLfsG6HeinrPICrveyJQi0hjquJKaqNuauRKs4LQiOMPub5MeaTtvq)KGOgQujoQubvwQai5PuyQsv6QsvvBvQqFvQaJLar2RQ6VQYGrDyLwSGESknzIUmPndQptrJMsDAQwTkcYRvbMTq3gs7wXVLmCcDCbGLd8COMUORdY2HOVdHXtGW5vrTEbqQMpL0(r(l8V3VHCt9FOq7NqfwyH7NWnHkuHdiDEa5BKNf1VH4Epyn1VXSO63WWELfIVH4EowR8373axqGR(nSZuehWboWMEAdf2UfAGXokuCtVMlyHZaJD0BG)gHqEmdWZp8Bi3u)hk0(juHfw4(jCtOcv4aIWN8BSqPDb(ggoQG(nSDPuNF43qQ473WWELfcI7cWvCswiKVzfQaIfQqYsIfA)eQWKfKfcQ9oMkoGjlcqiUxe6EaXDSCjX9waGojXiS1H4CbMAs8TGMet8cuIHlWvLnYIaeI7cqtDKelRet8cuIHejgHToeNlWutmXlqj(glSsCwelp7JPLeJlIt7njEGoqXeVaLyC6XiXa9wOO6ivz7BeDCI)9(nKk8cfZFV)df(373yVPxZ3a7rDU63qNnmQYVG)5)qH(79BOZggv5xWFJlWtf473iecgUHSCjCbqBqIeB1kXHqWWnXcHcE(adH9AAqIFJ9MEnFdXk9A(5)Wo)373qNnmQYVG)gL43aR53yVPxZ3a5c8nmQFdKBes)gDtSSYg2ELfIhIciFIRpT0Vh4JjXwTsCUatnBPJQVSEsxjoqbjwiiUhIpsC3elRSHCrfDGFFzbDTBPFpWhtITAL4CbMA2shvFz9KUsCGcsSqI4E(gixWBwu9BiRe)Ge)5)qH4373qNnmQYVG)gL43aR53yVPxZ3a5c8nmQFdKBes)gixGVHrTjRe)Gej(iXDtSSYMurwqaFmFIX1esBPFpWhtITAL4CbMA2shvFz9KUsCGcsSqqCpFdKl4nlQ(n2y8jRe)Ge)5)Wt(79BOZggv5xWFJs8BG18BS30R5BGCb(gg1VbYncPFdSOgJVCbMAIBO(iFyDbeFkXcLybsCiemCdz5s4cG2Ge)gixWBwu9BG1f4J5BCt7eDb67cLfm83qQ4lWftVMVHrUGKyiSpMeBOlWhtIp0nTt0fOeVjXDUajoxGPMyIlaXcHaj2Hj(Cbr8cuI9H4owUeUaO)8FOq6373qNnmQYVG)gL43aR53yVPxZ3a5c8nmQFdKBes)g3QIYcX0qwU8PaiX0RPbjs8rI7M4(igankCbm1gw0wbk(zVa0Ao30aaYffvjXhjUpIVfsD2jBJEbvSasITAL4BvrzHyAIfcf88bgc710ak66dM4afKyZRSHUccIfaiUZj2QvIdHGHBIfcf88bgc710Gej2QvIdlmM4Jed7M25dOORpyIduqIf6jjUNVbYf8Mfv)gIvfFWf4DL4VHuXxGlMEnFdbTQOSqme3LQIe3Xf4ByuTK4(JvjXzrSyvrIdv4cOeV30rUPpMeJSCjCbqBelOqaGoz8mXqyvsCweFRjbvKye26qCweV30rUPsmYYLWfaLyeEAtSp3c1htIxPe3(5)Wa6V3VHoByuLFb)nUapvGVFJqiy4gYYLWfaTbj(n2B618nGDGggRs(Z)HbKFVFdD2WOk)c(BCbEQaF)gHqWWnKLlHlaAds8BS30R5BeQaScoWhZF(pSd7373qNnmQYVG)gxGNkW3VbwuJXxUatnXTOBAN43jeK0evNK4tdsSqj2QvI7M4(igSU8Pi1jBRuIBQGWXjMyRwjgSU8Pi1jBRuIB(q8PehqpjX98n2B618nIUPDIFNqqstuDYVHuXxGlMEnFJ(JvI7qUPDkGyITasAIQtsSdtCARaL4fOeluIlaXOfqjoxGPMyljUaeVsjM4fOJaMeJfxeJpMedxaIrlGsCAVdXb0tIB)8FOW97373qNnmQYVG)gxGNkW3VriemCdz5s4cG2Ge)g7n9A(g7CvCc247UX4p)hkSW)E)g6SHrv(f83yVPxZ34UX4BVPxZl648BeDC(Mfv)gxe3F(puyH(79BOZggv5xWFJ9MEnFda082B618Ioo)grhNVzr1Vb66Zp)53qIA(sGphOj(37)qH)9(n0zdJQ8l4VXSO63qUGdqRAEs9EW7jcLafF15QFJ9MEnFd5coaTQ5j17bVNiucu8vNR(Z)Hc9373qNnmQYVG)gZIQFdm0egRs(wunTpJZVXEtVMVbgAcJvjFlQM2NX5p)h25)E)g6SHrv(f83ywu9BygplA)k43IXoQh30R5BS30R5BygplA)k43IXoQh30R5N)dfIFVFdD2WOk)c(BmlQ(nKaDLWoqFivmwJFJ9MEnFdjqxjSd0hsfJ14p)53aD9537)qH)9(n0zdJQ8l4VXEtVMVXDJX3EtVMx0X534c8ub((ncHGHBHvnVc(L26BXxDKQSbj(nIooFZIQFJWQMF(puO)E)g6SHrv(f834c8ub((n6J4CbMA2C8tmUNvW3yVPxZ3q6yrn(qxt)(Z)HD(V3VHoByuLFb)nUapvGVFdKlW3WO2eRk(GlW7kXeFK4Uj2h8oEEM4tdsSq0pITALyrnBWUoY2EthPs8rIbqJcxatTHTxzHaoUO6te4y0MgaqUOOkj(iX9r8TQOSqmnuFKVW4IZgKiXhjUpIVvfLfIPHTxzH4HOaYNu30UbjsCpeFK4Uj2h8oEEM4afK4aYjj2QvIZnQt2W6c8X8nUPDIUaTPZggvjXhjg5c8nmQnSUaFmFJBANOlqFxOSGHjUhIpsCFeFRkkletd21r2Gej(iXDtCFeFRkkletd1h5lmU4SbjsSvReJf1y8LlWutCd1h5dRlG4tjwOeB1kX9rmaAu4cyQnS9kleWXfvFIahJ20aaYffvjXhjUpIbqJcxatTLBmCLla)WjyZ1urBAaa5IIQK4Ei(iXDtCFeJlOyOpYgYkUPh1hUIi1jB6SHrvsSvRehcbd3qwXn9O(WvePo5ZgcDNYLnirI75BS30R5BGSC5tbqIPxZ3qQ4lWftVMVr)XkXDSCjXNaaKy61qCneFRkkledXIvf9XK4njoQlojwi6hX(G3XZZehcLepvsSdt85cIyeEmsCHub3vKyFW745zI9H4oEInIfG7bkXyiGsm2ELfcyxhzGr9rgQJubeVJKybOpsIfCCXjXoM4Ai(wvuwigIdv4cOe3XtaXomX9UXWvUamXfGyd7vwiGJlQsSJjwdaixuuLnIdWMtbuIfRk6JjXafNa)MEnyIDyIHW(ysSH9kleWXfvjUlahJs8osIfSosfqSJjUGY2p)hke)E)g6SHrv(f834c8ub((ncHGHBWR(mHwG03b3Gej(iX9rSudHGHBiaBAddfFWRcCTbjs8rIXIAm(YfyQjUH6J8H1fqCGiwi(g7n9A(gy7vwiEikG8jU(8nKk(cCX0R5Bia3duIXqaL4ZfeXIqjXqIeB0bbCxiUZm6SUqCneN2kX5cm1KyhM4oaSPnmuK4tCvGRe74ratI3B6ivIryRdXWUPD6JjXchG05eNlWutC7N)dp5V3VHoByuLFb)n2B618nUBm(2B618Ioo)grhNVzr1VXvI)5)qH0V3VHoByuLFb)n2B618nq9r(W6c(g3Z3O(YfyQj(FOWFdPIVaxm9A(gcGUPnXDb4fWZZela9rsSHUaI3B61qCweduyGITjUtvVyIr4PnXyDb(y(g30orxG(nUapvGVFJCJ6KnSUaFmFJBANOlqB6SHrvs8rIXIAm(YfyQjUH6J8H1fq8PeJCb(gg1gQpYhwxW7cLfmmXhjUpILv2W2RSq8qua5tC9PL(9aFmj(iX9r8TQOSqmnyxhzds8N)ddO)E)g6SHrv(f83yVPxZ3qUOZMEnFJ75BuF5cm1e)pu4VHuXxGlMEnFJUauyfqCwedHvI70IoB61qCNz0zDHyhM4DotCNQEj2XepvsmKy7BCbEQaF)g9rmYf4ByuBBm(KvIFqI)8Fya5373qNnmQYVG)gxGNkW3VHOMnyxhzBVPJuj(iXaOrHlGP2W2RSqahxu9jcCmAtdaixuuLeFKyrnBWUoYgqrxFWehOGeBELFJ9MEnFdS9klepefq(K6M2FdPIVaxm9A(g9hReByVYcbXDqbKe3jDtBIDyIHW(ysSH9kleWXfvjUlahJs8osId1rQaIr4XiXQGq0bkXsiGpMeN2kXJkisInVY2p)h2H979BOZggv5xWFJlWtf473OBIVvfLfIPH6J8fgxC2U2lWuXeFkXct8rI7MyPgcbd3SHgtf4J5dz5YgKiXwTsCFeNBuNSzdnMkWhZhYYLnD2WOkjUhITALyrnBWUoYgqrxFWehOGeFxC(shvjwGeBELe3dXhjwuZgSRJST30rQeFKya0OWfWuBy7vwiGJlQ(ebogTPbaKlkQsIpsSOMnyxhzdOORpyIpL47IZx6O63yVPxZ3a1h5lmU48Biv8f4IPxZ3OZIi2ZyIHWkXO(idJloXe7WeFxrrvs8osITHgtf4JjXilxsSJjgsK4DKedH9XKyd7vwiGJlQsCxaogL4DKehQJube7yIHeBetCNjLE61SX4zlj(U4KyuFKHXfNe7WeFUGigrbfLehQednByujolIn1K40wjg4WjXHNjgX6PpMeVeBELTF(pu4(979BOZggv5xWFJlWtf473Wh8oEEM4afK4aYjj(iX5g1jB2qJPc8X8HSCztNnmQsIpsCUrDYgwxGpMVXnTt0fOnD2WOkj(iXyrngF5cm1e3q9r(W6cioqbjwirSvRe3nXDtCUrDYMn0yQaFmFilx20zdJQK4Je3hX5g1jByDb(y(g30orxG20zdJQK4Ei2QvIXIAm(YfyQjUH6J8H1fqCqIfM4E(g7n9A(gilx(cRy(nKk(cCX0R5B0FSsChlxsSGRys8MeB7M2kGyrGxapptmcpTjwaeAmvGpMe3XYLedjsCweleeNlWutSLexaIR0wbeNBuNetCneB0B7N)dfw4FVFdD2WOk)c(BCbEQaF)gDtmqHbk2EdJkXwTsSp4D88mXNsCa9KeB1kX3QIYcX0qwU8LfaOt2ak66dM4afK4oNybaInVsI7H4Je3nX9rmYf4ByuBIvfFWf4DLyITALyFW745zIpniXbKtsCpeFK4UjUpIZnQt2W6c8X8nUPDIUaTPZggvjXwTsC3eNBuNSH1f4J5BCt7eDbAtNnmQsIpsCFeJCb(gg1gwxGpMVXnTt0fOVluwWWe3dX98n2B618nKkYcc4J5tmUMq63qQ4lWftVMVrNQratIHWkXDsrwqaFmjUlX1esj2Hj(Cbr8DhIn1KyFYI4owUeUaOe7do1vAjXfGyhMydDb(ys8HUPDIUaLyhtCUrDsvs8osIr4XiX2EsSofKPnX5cm1e3(5)qHf6V3VHoByuLFb)nUapvGVFdSOgJVCbMAIBO(iFyDbehiI7MyHGybs8TgjKNnPJX1St(0RDP4MoByuLe3dXhj2h8oEEM4afK4aYjj(iX5g1jByDb(y(g30orxG20zdJQKyRwjUpIZnQt2W6c8X8nUPDIUaTPZggv53yVPxZ3az5YxyfZVHuXxGlMEnFJ(JvI7OGjUgIf0orSdt85cIyzncys8OQK4Si(U4K4oPiliGpMe3L4AcPws8osItBfOeVaL4OIXeN27qSqqCUatnXexqjXDFsIr4PnX3AKqE2t7N)dfUZ)9(n0zdJQ8l4VXEtVMVb2ELfIhIciFsDt7VX98nQVCbMAI)hk83qQ4lWftVMVr)XkXg2RSqqChuazatCN0nTj2HjoTvIZfyQjXoM4nSGsIZIyPRexaIpxqeBVivInSxzHaoUOkXDb4yuI1aaYffvjXi80MybOpYqDKkG4cqSH9kleWUosI3B6i1234c8ub((n6M4CbMA2S1nM2nXBsCGiwO9J4JeJf1y8LlWutCd1h5dRlG4arSqqCpeB1kXDtSOMnyxhzBVPJuj(iXaOrHlGP2W2RSqahxu9jcCmAtdaixuuLe3Zp)hkSq879BOZggv5xWFJ9MEnFdmeaOJubVSEORCum(BCpFJ6lxGPM4)Hc)nKk(cCX0R5B0FSsSbeaOJubeNfXcWvokgtCneVeNlWutIt7nj2XeBw(ysCwelDL4njoTvIbUPDsC6OA7BCbEQaF)g5cm1SLoQ(Y6jDL4arSqpjXhjoecgUHSCjCbqBYcX8Z)HcFYFVFdD2WOk)c(BS30R5BGSC5llaqN8BCpFJ6lxGPM4)Hc)nKk(cCX0R5B0FSsChlxsCVfaOtsCnXZe7WeB0bbCxiEhjXDSxIxGs8EthPs8osItBL4CbMAsmIAeWKyPRelHa(ysCAReFT3z0y7BCbEQaF)gixGVHrTjRe)Gej(iXDtCiemCdz5s4cG2KfIHyRwjoecgUHSCjCbqBafD9btCGi(wvuwiMgYYLVWkMnGIU(Gj2QvIfbkYN5v2eUHSC5lSIjXhjUpIdHGHBHXQKriC2a6EtIpsmwuJXxUatnXnuFKpSUaIdeXDoX9q8rI3B6i1NSYgYfv0b(9Lf01M4tds898nQpDuuxXeFKySOgJVCbMAIBO(iFyDbehiI7M4tsSajUBIfselaqCUrDYwIWX5RGFWBQnD2WOkjUhI75N)dfwi979BOZggv5xWFJlWtf473qwzd5Ik6a)(Yc6A3s)EGpMeFK4Ujo3OozdRlWhZ34M2j6c0MoByuLeFKySOgJVCbMAIBO(iFyDbeFkXixGVHrTH6J8H1f8UqzbdtSvRelRSHTxzH4HOaYN46tl97b(ysCpeFK4UjUpIbqJcxatTHTxzHaoUO6te4y0MgaqUOOkj2QvI3B6i1NSYgYfv0b(9Lf01M4tds898nQpDuuxXe3Z3yVPxZ3a1hzOosf8Z)Hchq)9(n0zdJQ8l4VXf4Pc89BaGgfUaMAtC9jeO7bk4jI3iAtdaixuuLeFKyKlW3WO2KvIFqIeFK4CbMA2shvFz9eV5tO9J4tjUBIVvfLfIPHTxzH4HOaYNu30UjHaB61qSaj28kjUNVXEtVMVb2ELfIhIciFsDt7VHuXxGlMEnFJ(JvIn6GaUteJWtBI7Y6tiq3duaXDbVruIHMOIXeN2kX5cm1KyeEmsCOsCOgleel0(fGgXHkCbuItBL4BvrzHyi(wOkM4W9Eq7N)dfoG879BOZggv5xWFJlWtf473aSU8Pi1jBRuIB(q8PelC)(g7n9A(gy7vwiExWIT)gsfFbUy618n6pwj2WELfcIfuWITjUgIf0orm0evmM40wbkXlqjELsmX(CluFmB)8FOWDy)E)g6SHrv(f83yVPxZ3a1h5dRl4BCpFJ6lxGPM4)Hc)n8jvaasmFo83i97b4tdkeFdFsfaGeZNJIQsFt9Bi834AV(8ne(BCbEQaF)gyrngF5cm1e3q9r(W6ci(uIrUaFdJAd1h5dRl4DHYcgM4Jehcbd3Kl4GxAxqM2zds8N)dfA)(9(n0zdJQ8l4VXf4Pc89Becbd3Kl4GxAxqM2zdsK4JeJCb(gg1MSs8dsK4Je3hXHqWWnKLlHlaAds8Biv8f4IPxZ3O)yLybOpsIpX4EM4Si(wdgcvjUtl4aI71UGmTtmXIG6IjUgIn6L4ckXUujUGjUJNyJ4EfYDsitSGwdSdqj2HjoTDmXoM4LyB30wbelc8c45zIt7DigOYktFmjgAIkgtSCbhqCAxqM2jMyht8gwqjXzrC6OkXfu(n8jvaasmFo83i97b4tdkeh7lecgUjxWbV0UGmTZgK43WNubaiX85OOQ03u)gc)nU2RpFdH)g7n9A(gO(iFWX98p)hkuH)9(n0zdJQ8l4VXf4Pc89BGCb(gg1MSs8dsK4Jedwx(uK6Kn0cPIQt28H4tj(U48LoQsSajUFTts8rIXIAm(YfyQjUH6J8H1fqCGiUBIfcIfiXcLybaIZnQt2qDSco30zdJQKybs8EthP(Kv2qUOIoWVVSGU2elaqCUrDYMi(812VVOph00zdJQKybsC3eJf1y8LlWutCd1h5dRlG4t7Wt8jjUhIfaiUBIf1Sb76iB7nDKkXhjgankCbm1g2ELfc44IQprGJrBAaa5IIQK4EiUhIpsC3e3hXaOrHlGP2W2RSqahxu9jcCmAtdaixuuLeB1kX9r8TQOSqmnyxhzdsK4JedGgfUaMAdBVYcbCCr1NiWXOnnaGCrrvsSvReV30rQpzLnKlQOd87llORnXNgK475BuF6OOUIjUNVXEtVMVbQpYxyCX53qQ4lWftVMVr)XkXcqFKel44ItIDyIpxqelRratIhvLeNfXafgOyBI7u1lUrSrwIeFxC6JjXBsSqqCbigTakX5cm1etmcpTj2qxGpMeFOBANOlqjo3OoPkjEhjXNliIxGs8ujXqyFmj2WELfc44IQe3fGJrjUae3f85RTFjUd5ZbnSOgJVCbMAIBO(iFyDbN2H)KeBQjM40wjg1hhfcL4cM4ts8osItBL4bcnubexWeNlWutCJ4olIlljwwepvsSiqXyIr9rggxCsm0KEK4ngjoxGPMyIxGsSSYuLeJWtBI7yVeJWwhIHW(ysm2ELfc44IQelcCmkXomXH6ivaXoM4f56XnmQTF(puOc9373qNnmQYVG)gxGNkW3VbqHbk2EdJkXhjoxGPMT0r1xwpPReFkXcjITAL4Ujo3Oozd1Xk4CtNnmQsIpsSSYg2ELfIhIciFIRpnGcduS9ggvI7HyRwjoecgUbnWqGOpMp5coyumUbj(n2B618nqUOIoWVVSGU2FJ75BuF5cm1e)pu4F(puOD(V3VHoByuLFb)nUapvGVFdGcduS9ggvIpsCUatnBPJQVSEsxj(uIfcIpsCFeNBuNSH6yfCUPZggvjXhjo3OozteF(A73x0NdA6SHrvs8rIXIAm(YfyQjUH6J8H1fq8Pel0VXEtVMVb2ELfIhIciFIRpFdPIVaxm9A(ggI613iX3AKE61qCweJZsK47ItFmj2Odc4UqCnexWWbi5cm1etmcBDig2nTtFmjUZjUaeJwaLyCU3dujXOviM4DKedH9XK4UGpFT9lXDiFoG4DKeFOqUxIfGowbNB)8FOqfIFVFdD2WOk)c(BS30R5BGTxzH4HOaYN46Z34E(g1xUatnX)df(Biv8f4IPxZ34ewvrIn6GaUledjsCneVyIr35mX5cm1et8IjwSWypmQwsSkiUQysmcBDig2nTtFmjUZjUaeJwaLyCU3dujXOviMyeEAtCxWNV2(L4oKph0(gxGNkW3VbqHbk2EdJkXhjoxGPMT0r1xwpPReFkXcbXhjUpIZnQt2qDSco30zdJQK4Je3hXDtCUrDYgwxGpMVXnTt0fOnD2WOkj(iXyrngF5cm1e3q9r(W6ci(uIrUaFdJAd1h5dRl4DHYcgM4Ei(iXDtCFeNBuNSjIpFT97l6ZbnD2WOkj2QvI7M4CJ6Knr85RTFFrFoOPZggvjXhjglQX4lxGPM4gQpYhwxaXbkiXcL4EiUNF(puON8373qNnmQYVG)g7n9A(gO(iFyDbFJ75BuF5cm1e)pu4VHpPcaqI5ZH)gPFpaFAqH(n8jvaasmFokQk9n1VHWFJR96Z3q4VXf4Pc89BGf1y8LlWutCd1h5dRlG4tjg5c8nmQnuFKpSUG3fklyyIpsC3e3hX4ckg6JSHSIB6r9HRisDYMoByuLeB1kX9r8TQOSqmn4OITVGfoBqIe3Zp)hkuH0V3VHoByuLFb)n2B618nq9r(GJ75VHpPcaqI5ZH)gPFpaFAqHES7(cHGHBYfCWlTlit7SbjA16TQOSqmnKLlFHvmBqI98n8jvaasmFokQk9n1VHWFJlWtf473OpIXfum0hzdzf30J6dxrK6KnD2WOkj2QvI7J4BvrzHyAWrfBFblC2Ge)gx71NVHW)8FOqdO)E)g6SHrv(f83yVPxZ3aoQy7lyHZVHpPcaqI5ZH)gPFpaFAqH)g(KkaajMphfvL(M63q4VHuXxGlMEnFJ(JvIpXOITVGfojUGsSlvIlyIrxFi(wvuwigmXzrm66tU(qChR4MEuj2OIi1jjoecgU9nUapvGVFdCbfd9r2qwXn9O(WvePoztNnmQsIpsCFehcbd3qwUeUaOnirIpsCFehcbd3elek45dme2RPbj(Z)HcnG879BOZggv5xWFdPIVaxm9A(g9hReB0bbCNiEXehxCsmqXfij2HjUgItBLy0cP(n2B618nW2RSq8qua5tQBA)Z)HcTd7373qNnmQYVG)gsfFbUy618n6pwj2Odc4Uq8IjoU4KyGIlqsSdtCneN2kXOfsL4DKeB0bbCNi2XexdXcAN(g7n9A(gy7vwiEikG8jU(8ZF(neb6Tqd3837)qH)9(n0zdJQ8l4VXf4Pc89Bau01hmXbI4oVF97BS30R5BiwiuWdrbKp4cKEcj1F(puO)E)g6SHrv(f834c8ub((nWfum0hztecNqr9PaiX0RPPZggvjXwTsmUGIH(iBiR4MEuF4kIuNSPZggv53yVPxZ3aoQy7lyHZF(pSZ)9(n0zdJQ8l4VXf4Pc89B0hXHqWWnS9kleWfaTbj(n2B618nW2RSqaxa0F(pui(9(n0zdJQ8l4VXf4Pc89B4dEhpp3KkSF9K4tjw4t(n2B618nwWDh9LfaOt(Z)HN8373qNnmQYVG)gZIQFdS9kleQ8vGWxb)YcGQt(n2B618nW2RSqOYxbcFf8llaQo5p)hkK(9(n0zdJQ8l4Vrj(nWA(n2B618nqUaFdJ63a5gH0VHq)gixWBwu9BG6J8H1f8Uqzbd)Z)Hb0FVFJ9MEnFdKlQOd87llOR93qNnmQYVG)5p)gxj(37)qH)9(n0zdJQ8l4VXf4Pc89BicCfNnSgHFIfcf88bgc71q8rI7M4qiy4gYYLWfaTbjsSvRe3hX3cPo7KTdod8Di(iX9r8TqQZozB0lOIfqs8rIVvfLfIPHSC5tbqIPxtdOORpyIpniXc3pITALyy30oFafD9btCGi(wvuwiMgYYLpfajMEnnGIU(GjUhIpsC3ed7M25dOORpyIpniX3QIYcX0qwU8PaiX0RPbu01hmXcKyHpjXhj(wvuwiMgYYLpfajMEnnGIU(Gjoqbj28kjwaGyHGyRwjg2nTZhqrxFWeFkX3QIYcX0elek45dme2RPjHaB61qSvRehwymXhjg2nTZhqrxFWehiIVvfLfIPHSC5tbqIPxtdOORpyIfiXcFsITAL4BHuNDY2bNb(oeB1kXHqWWTWyvYieoBqIe3Z3yVPxZ3qSqOGNpWqyVMVHuXxGlMEnFJ(JvI7sHqbehGhyiSxdXi80M4owUeUaOnIfaROKy4cqChlxcxauIVfQIjUGHj(wvuwigI9H40wjEubrsSW9JySERrIjUsBfGWXkXqyL4Ai(kjgAIkgtCARelg3ZkGyhtS4csIlyItBL4dod8Di(wi1zN0sIlaXomXPTcuIr4XiXtLehQeVtL2kG4owUK4taasm9AioTDmXWUPD2iUZYurftIZIy855sCARehxCsSyHqbe7dme2RH4cM40wjg2nTtIZIyKLljwbqIPxdXWfG4PgIpHpd8DWTF(puO)E)g6SHrv(f83ywu9BG9bgk(mJR03Sa4x4kn1xb)GvqD9883qQ4lWftVMVr)XkXcELMkX(GDPsCbtChprIHlaXPTsmSdWjXqyL4cqCnelODI4fovaXPTsmSdWjXqyTrCh4PnXh6M2jXN4QeBxrjXWfG4oEITVXf4Pc89Becbd3qwUeUaOnirITAL40rvIpLyH7hXhjUBI7J4BHuNDY24M25dEvI75BS30R5BG9bgk(mJR03Sa4x4kn1xb)GvqD988p)h25)E)g6SHrv(f834c8ub((n6J4qiy4gYYLWfaTbjs8rI7M4(i(wvuwiMgYYLVSaaDYgKiXwTsCFeNBuNSHSC5llaqNSPZggvjX9q8rI7MyKlW3WO2KvIFqIeFKySOgJVCbMAIBixurh43xwqxBIdsSWeB1kX7nDK6twzd5Ik6a)(Yc6AtCqIXIAm(YfyQjUHCrfDGFFzbDTj(iXyrngF5cm1e3qUOIoWVVSGU2eFkXctCpeB1kXHqWWnKLlHlaAdsK4Je3nX4ckg6JSzckK6ZhKUzb20RPPZggvjXwTsmUGIH(iBWUgLVc(fglmUqXnD2WOkjUNVXEtVMVb8QptOfi9DWFdPIVaxm9A(g9hReFIRsSGm0cK(oyIRHybTtexqj2LkXfmXDSCjCbqBe3FSs8jUkXcYqlq67iXe7dXDSCjCbqj2Hj(CbrS9Iujw90wbelidkKkXb4bPBwGn9AiUaeFIUgLexWel4yHXfkUrChSEsmCbiwwjM4SioujgsK4qfUakX7nDKB6JjXN4QelidTaPVdM4SigDfeoQJvItBL4qiy42p)hke)E)g6SHrv(f83yVPxZ3a1hP5IQ4VX98nQVCbMAI)hk83qQ4lWftVMVr)XkXcqFKMlQIjgHToeVXiXDoXDQ6ft8cuIHeTK4cq85cI4fOe7dXDSCjCbqBeFcgmeqjwaeAmvGpMe3XYLeJWJrIXPhJehQedjsmcBDioTvIVlojoDuLyyFCSTIBeBKLiXqyFmjEtIpPajoxGPMyIr4PnXg6c8XK4dDt7eDbA7BCbEQaF)g(G3XZZehiI7W6hXhjUBI7MyKlW3WO22y8jRe)Gej(iXDtCFeFRkkletdz5YNcGetVMgKiXwTsCFeNBuNSzdnMkWhZhYYLnD2WOkjUhI7HyRwjoecgUHSCjCbqBqIe3dXhjUBI7J4CJ6KnBOXub(y(qwUSPZggvjXwTsSudHGHB2qJPc8X8HSCzdOORpyIpL47IZx6OkXwTsCFehcbd3qwUeUaOnirI7H4Je3nX9rCUrDYgwxGpMVXnTt0fOnD2WOkj2QvIXIAm(YfyQjUH6J8H1fqCGi(Ke3Zp)hEYFVFdD2WOk)c(BCbEQaF)g9rCUrDYMn0yQaFmFilx20zdJQK4JeJCb(gg1MSs8dsKyRwjwQHqWWnBOXub(y(qwUSbjs8rIdHGHBilxcxa0gKiXwTsC3eFRkkletdz5YNcGetVMgqrxFWeFkXc3pITAL4(ig5c8nmQnXQIp4c8UsmX9q8rI7J4qiy4gYYLWfaTbj(n2B618nGg7kE(nfY9Biv8f4IPxZ3O)yL4(p2v8mXhwixIRHybTtwsSDfL(ysCiWv44zIZIyeRNedxaIflekGyFGHWEnexaIxPKyS4IyWTF(pui979BOZggv5xWFJlWtf473OpIdHGHBilxcxa0gKiXhjUpIVvfLfIPHSC5tbqIPxtdsK4JeJf1y8LlWutCd1h5dRlG4tjwyIpsCFeNBuNSH1f4J5BCt7eDbAtNnmQsITAL4UjoecgUHSCjCbqBqIeFKySOgJVCbMAIBO(iFyDbehiIfkXhjUpIZnQt2W6c8X8nUPDIUaTPZggvjXhjUBIfbkYN5v2eUHSC5lSIjXhjUBI7JynaGCrrv2uuXZaDJVciNDUkXwTsCFeNBuNSzdnMkWhZhYYLnD2WOkjUhITALynaGCrrv2uuXZaDJVciNDUkXhj(wvuwiMMIkEgOB8va5SZvBafD9btCGcsSWcjHs8rILAiemCZgAmvGpMpKLlBqIe3dX9qSvRe3nXHqWWnKLlHlaAdsK4JeNBuNSH1f4J5BCt7eDbAtNnmQsI75BS30R5Bew18k4xARVfF1rQYVHuXxGlMEnFJ(JvIRHybTtehcLelc8c4PJvIHW(ysChlxs8jaajMEned7aCAjXomXqyvsSpyxQexWe3XtK4Ai2OxIHWkXlCQaIxIrwUmSIjXWfG4BvrzHyiwHH9RRZ9mX7ijgUaeBdnMkWhtIrwUKyiX0rvIDyIZnQtQY2p)hgq)9(n0zdJQ8l4VXEtVMVXDJX3EtVMx0X53i648nlQ(nsGphOj(N)ddi)E)g6SHrv(f834c8ub((nS1nM2nXBsCGcsCa9KFJ9MEnFdPIfvWM6teSNvWp)53ib(CGM4FV)df(373qNnmQYVG)gZIQFdfv8mq34RaYzNR(nKk(cCX0R5B0FSsCnelODI4oZOZ6cXzrSPMe3PQxIt)EGpMeVJKyvqi6aL4Sio6JsmKiXHAMkGyeEAtChlxcxa0VXf4Pc89BCRkkletdz5YNcGetVMgqrxFWehOGelSqj2QvIVvfLfIPHSC5tbqIPxtdOORpyIpLyHgq)g7n9A(gkQ4zGUXxbKZox9N)df6V3VHoByuLFb)nMfv)g(GVaOCdJ6laG2jHqFsfPF1VHuXxGlMEnFJEbNjolInopxIdWD46eXi80M4ovqHrLyJCVhOsIf0oHj2HjwSWypmQnIfYdXXAmvaXWUPDIjgHN2eJwaL4aChUormewXeVzQOIjXzrm(8CjgHN2eVZzIVsIlaXNqq4KyiSsSNTVXf4Pc89Becbd3qwUeUaOnirIpsCiemCtSqOGNpWqyVMgKiXwTsCyHXeFKyy30oFafD9btCGcsSq7hXwTsCiemCtSqOGNpWqyVMgKiXhj(wvuwiMgYYLpfajMEnnGIU(GjwGel8jj(uIHDt78bu01hmXwTsCiemCdz5s4cG2Gej(iX3QIYcX0elek45dme2RPbu01hmXcKyHpjXNsmSBANpGIU(Gj2QvI7M4BvrzHyAIfcf88bgc710ak66dM4tdsSW9J4JeFRkkletdz5YNcGetVMgqrxFWeFAqIfUFe3dXhjg2nTZhqrxFWeFAqIfUdRFFJ9MEnFdFWxauUHr9faq7KqOpPI0V6p)h25)E)g6SHrv(f83ywu9BGU3neOpSTQ5dfc73VHuXxGlMEnFdJZZLydBvtIfGqy)smcpTjUJLlHla634c8ub((nUvfLfIPHSC5tbqIPxtdOORpyIpLyH733yVPxZ3aDVBiqFyBvZhke2V)8FOq879BOZggv5xWFJzr1VbUGIrntFmFaOWZFJ75BuF5cm1e)pu4VHuXxGlMEnFdJZZL4auqHNjgHN2e3LcHcioapWqyVgIHWRPAjXO7bkXyiGsCweJhxujoTvIJfcfNela2fIZfyQzJ4oWwhIHWQKyeEAtSH9kleQKyHmiK4cM4ElaQoPLeFcbHtIHWkX1qSG2jIxmXOqxBIxmXIfg7HrT9nUapvGVFJqiy4MyHqbpFGHWEnnirITAL4(iwe4koBync)elek45dme2RHyRwjwdaixuuLnS9kleQ8vGWxb)YcGQt(n2B618nWfumQz6J5dafE(N)dp5V3VHoByuLFb)nMfv)gyFGHIpZ4k9nla(fUst9vWpyfuxpp)nKk(cCX0R5B0FSsSGxPPsSpyxQexWe3XtKy4cqCARed7aCsmewjUaexdXcANiEHtfqCARed7aCsmewBeByxGK4RdUqEsSdtmYYLeRaiX0RH4BvrzHyi2XelC)WexaIrlGs8Iyp3(gxGNkW3VXTQOSqmnKLlFkasm9AAafD9bt8Pbjw4(9n2B618nW(adfFMXv6Bwa8lCLM6RGFWkOUEE(N)dfs)E)g6SHrv(f83ywu9BGTxzHqLVce(k4xwauDYVHuXxGlMEnFJ(JvInSxzHqLelKbHexWe3Bbq1jjgHToepvsSpe3XYLWfa1sIlaX(qCOMiuDiUJLljwWvmj(U4etSpe3XYLWfaTrCNHj(e(mW3H4cq8H6fuXcijo6JsSNedjsmcpTjgN79avs8TQOSqm4234c8ub((nUvfLfIPjwiuWZhyiSxtdOORpyIduqIfUFeFK4BvrzHyAilx(uaKy610ak66dM4afKyH7hXhjUBIVfsD2jBJEbvSasITAL4BHuNDY2bNb(oe3dXwTsC3eFlK6St2qQtAFgqSvReFlK6St2g30oFWRsCpeFK4UjUpIdHGHBilxcxa0gKiXwTsSiqr(mVYMWnKLlFHvmjUhITAL4WcJj(iXWUPD(ak66dM4afKyHOFFJ9MEnFdS9kleQ8vGWxb)YcGQt(Z)Hb0FVFdD2WOk)c(Biv8f4IPxZ3O)yL4OJtIlyIRjabcRelx01ujob(CGMyIRjEMyhMybqOXub(ysChlxsCN0qiyyIDmX7nDKQLexaIpxqeVaL4PsIZnQtQsI9jlI9S9n2B618nUBm(2B618Ioo)gxGNkW3Vr3e3hX5g1jB2qJPc8X8HSCztNnmQsITALyPgcbd3SHgtf4J5dz5YgKiX9q8rI7M4qiy4gYYLWfaTbjsSvReFRkkletdz5YNcGetVMgqrxFWeFkXc3pI75BeDC(Mfv)gsuZxc85anX)8Fya5373qNnmQYVG)gxGNkW3VriemCdz5s4cG2Gej2QvIdHGHBIfcf88bgc710Gej2QvIVvfLfIPHSC5tbqIPxtdOORpyIpLyH733yVPxZ3acRppvu83qQ4lWftVMVrNu4fkMedVXy4EpGy4cqmeEdJkXEQO4aM4(JvIRH4BvrzHyi2hIlGubehEM4e4ZbAsmowz7N)8Bew1879FOW)E)g6SHrv(f834c8ub((nWIAm(YfyQjUH6J8H1fqCGcsCN)n2B618nw8vhPkFHXfN)8FOq)9(n0zdJQ8l4VXf4Pc89BGf1y8LlWutCBXxDKQ8nfYL4tjwyIpsmwuJXxUatnXnuFKpSUaIpLyHj(iX9rCUrDYgwxGpMVXnTt0fOnD2WOk)g7n9A(gl(QJuLVPqUFdPIVaxm9A(gc5jEMyiSsCNHV6ivjXhwixIryRdXtLeNBuNuLe7tweBOlWhtIp0nTt0fOexdXcvGeNlWutC7N)8BCrC)9(pu4FVFdD2WOk)c(BaH1hcBpQV7ItFm)hk83yVPxZ3aRlWhZ34M2j6c0VX98nQVCbMAI)hk83qQ4lWftVMVr)XkXg6c8XK4dDt7eDbkXomXNliIr4XiX2EsSofKPnX5cm1et8osI7sHqbehGhyiSxdX7ijUJLlHlakXlqjEQKyGUYZwsCbiolIbkmqX2eB0bbCxiUgItefXfGy0cOeNlWutC7BCbEQaF)gDtmYf4ByuByDb(y(g30orxG(Uqzbdt8rI7JyKlW3WO2eRk(GlW7kXe3dXwTsC3elRSHTxzH4HOaYN46tdOWafBVHrL4JeJf1y8LlWutCd1h5dRlG4tjwyI75N)df6V3VHoByuLFb)nGW6dHTh13DXPpM)df(BS30R5BG1f4J5BCt7eDb634E(g1xUatnX)df(Biv8f4IPxZ3WWUajXcQdUqEsSHUaFmj(q30orxGs8TgPNEneNfXhOQiXgDqa3fIHej2hI7S6e8nUapvGVFJCJ6KnSUaFmFJBANOlqB6SHrvs8rILv2W2RSq8qua5tC9PbuyGIT3WOs8rIXIAm(YfyQjUH6J8H1fq8Pel0F(pSZ)9(n0zdJQ8l4VrnXZVlI73q4VXEtVMVbQpYxyCX53qQ4lWftVMVrnXZVlIlXO7bkM40wjEVPxdX1eptmeEdJkXsiGpMeFT3z0OpMeVJK4PsIxmXlXa1ekUaI3B610(5p)53aPcWEn)dfA)eQW9RdtyH03aXcgFmXFJoOZcqDya(qb5aMyI71wj2rflqsmCbiwafb6Tqd3uajgObaKdujX4cvjEHYcDtvs81Ehtf3il6q(Oel0aMybTgKkivjXciUGIH(iBcsciXzrSaIlOyOpYMGutNnmQsbK4Ufwq0tJSOd5JsSqdyIf0AqQGuLelG4ckg6JSjijGeNfXciUGIH(iBcsnD2WOkfqI3K4tGqUdrC3cli6Prwqw0bDwaQddWhkihWetCV2kXoQybsIHlaXci66JasmqdaihOsIXfQs8cLf6MQK4R9oMkUrw0H8rjUZdyIf0AqQGuLelG4ckg6JSjijGeNfXciUGIH(iBcsnD2WOkfqI7wybrpnYIoKpkXc9KbmXcAnivqQsIfqCbfd9r2eKeqIZIybexqXqFKnbPMoByuLciXDlSGONgzrhYhLyHkKcyIf0AqQGuLelG4ckg6JSjijGeNfXciUGIH(iBcsnD2WOkfqI7wybrpnYIoKpkXcnGgWelO1GubPkjwaXfum0hztqsajolIfqCbfd9r2eKA6SHrvkGe3TWcIEAKfKfDqNfG6Wa8HcYbmXe3RTsSJkwGKy4cqSaELybKyGgaqoqLeJluL4fkl0nvjXx7DmvCJSOd5JsSqkGjwqRbPcsvsSaMaFoqZ2gEB3QIYcXiGeNfXc4TQOSqmTn8kGe3TWcIEAKfKfbyuXcKQK4acX7n9Aio64e3il(gyr9(puONmG8nebfSh1Vrx7kXg2RSqqCxaUItYIU2vIfY3ScvaXcvizjXcTFcvyYcYIU2vIfu7DmvCatw01UsCacX9Iq3diUJLljU3ca0jjgHToeNlWutIVf0KyIxGsmCbUQSrw01UsCacXDbOPosILvIjEbkXqIeJWwhIZfyQjM4fOeFJfwjolILN9X0sIXfXP9MepqhOyIxGsmo9yKyGEluuDKQSrwqw01Us8jqqOxOuLehQWfqj(wOHBsCOA6dUrCNDVQyIjEQjaXEbOWqrI3B61GjUM45gzXEtVgCteO3cnCtbgmWIfcf8qua5dUaPNqs1shoiqrxFWbQZ7x)il2B61GBIa9wOHBkWGbgoQy7lyHtlD4G4ckg6JSjcHtOO(uaKy61y1kUGIH(iBiR4MEuF4kIuNKSyVPxdUjc0BHgUPadgyS9kleWfa1shoyFHqWWnS9kleWfaTbjswS30Rb3eb6Tqd3uGbd8cU7OVSaaDslD4G(G3XZZnPc7xppv4tswS30Rb3eb6Tqd3uGbdmewFEQOwolQgeBVYcHkFfi8vWVSaO6KKf7n9AWnrGEl0WnfyWaJCb(ggvlNfvdI6J8H1f8UqzbdBzjgeRPLi3iKguOKf7n9AWnrGEl0WnfyWaJCrfDGFFzbDTjlil6AxjUlv61Gjl2B61GdI9OoxLSyVPxdoOyLEnw6WbdHGHBilxcxa0gKOvRHqWWnXcHcE(adH9AAqIKf7n9AWcmyGrUaFdJQLZIQbLvIFqIwwIbXAAjYncPb7wwzdBVYcXdrbKpX1Nw63d8X0Q1CbMA2shvFz9KUgOGcrph7wwzd5Ik6a)(Yc6A3s)EGpMwTMlWuZw6O6lRN01afui1dzXEtVgSadgyKlW3WOA5SOAWngFYkXpirllXGynTe5gH0GixGVHrTjRe)Gep2TSYMurwqaFmFIX1esBPFpWhtRwZfyQzlDu9L1t6AGcke9qw0vInYfKedH9XKydDb(ys8HUPDIUaL4njUZfiX5cm1etCbiwieiXomXNliIxGsSpe3XYLWfaLSyVPxdwGbdmYf4ByuTCwuniwxGpMVXnTt0fOVluwWWwwIbXAAjYncPbXIAm(YfyQjUH6J8H1fCQqfyiemCdz5s4cG2Gejl6kXcAvrzHyiUlvfjUJlW3WOAjX9hRsIZIyXQIehQWfqjEVPJCtFmjgz5s4cG2iwqHaaDY4zIHWQK4Si(wtcQiXiS1H4SiEVPJCtLyKLlHlakXi80MyFUfQpMeVsjUrwS30RblWGbg5c8nmQwolQguSQ4dUaVReBzjgeRPLi3iKg8wvuwiMgYYLpfajMEnniXJD3haAu4cyQnSOTcu8ZEbO1CUPbaKlkQYJ9DlK6St2g9cQybKwTERkklettSqOGNpWqyVMgqrxFWbkO5v2qxbHaqNB1AiemCtSqOGNpWqyVMgKOvRHfgFe2nTZhqrxFWbkOqpzpKf7n9AWcmyGHDGggRsAPdhmecgUHSCjCbqBqIKf7n9AWcmyGdvawbh4JPLoCWqiy4gYYLWfaTbjsw0vI7pwjUd5M2PaIj2ciPjQojXomXPTcuIxGsSqjUaeJwaL4CbMAITK4cq8kLyIxGocysmwCrm(ysmCbigTakXP9oehqpjUrwS30RblWGbo6M2j(Dcbjnr1jT0HdIf1y8LlWutCl6M2j(Dcbjnr1jpnOqTAT7(aRlFksDY2kL4MkiCCITAfSU8Pi1jBRuIB(CAa9K9qwS30RblWGbENRItWgF3ngT0Hdgcbd3qwUeUaOnirYI9MEnybgmW3ngF7n9AErhNwolQg8I4swS30RblWGbganV9MEnVOJtlNfvdIU(qwqw01UsCN1LoeXzrmewjgHToel4QgIlyItBL4odF1rQsIDmX7nDKkzXEtVgClSQj4IV6iv5lmU40shoiwuJXxUatnXnuFKpSUGafSZjl6kXc5jEMyiSsCNHV6ivjXhwixIryRdXtLeNBuNuLe7tweBOlWhtIp0nTt0fOexdXcvGeNlWutCJSyVPxdUfw1iWGbEXxDKQ8nfY1shoiwuJXxUatnXTfF1rQY3ui3tf(iwuJXxUatnXnuFKpSUGtf(yF5g1jByDb(y(g30orxG20zdJQKSGSORDLybTtyYIUsC)XkXDPqOaIdWdme2RHyeEAtChlxcxa0gXcGvusmCbiUJLlHlakX3cvXexWWeFRkkledX(qCARepQGijw4(rmwV1iXexPTcq4yLyiSsCneFLednrfJjoTvIfJ7zfqSJjwCbjXfmXPTs8bNb(oeFlK6StAjXfGyhM40wbkXi8yK4PsIdvI3PsBfqChlxs8jaajMEneN2oMyy30oBe3zzQOIjXzrm(8CjoTvIJlojwSqOaI9bgc71qCbtCARed7M2jXzrmYYLeRaiX0RHy4cq8udXNWNb(o4gzXEtVgC7kXbflek45dme2RXshoOiWvC2WAe(jwiuWZhyiSxZXUdHGHBilxcxa0gKOvR9DlK6St2o4mW35yF3cPo7KTrVGkwa5XBvrzHyAilx(uaKy610ak66d(0Gc3pRwHDt78bu01hCGUvfLfIPHSC5tbqIPxtdOORp4Eo2nSBANpGIU(Gpn4TQOSqmnKLlFkasm9AAafD9blqHp5XBvrzHyAilx(uaKy610ak66doqbnVsbaHWQvy30oFafD9bF6TQOSqmnXcHcE(adH9AAsiWMEnwTgwy8ry30oFafD9bhOBvrzHyAilx(uaKy610ak66dwGcFsRwVfsD2jBhCg47y1AiemClmwLmcHZgKypKfDL4(JvIn8OoxL4Aiwq7eXzrSiOUeBOI2qbOlGyI7cOUXfDtVMgzrxjEVPxdUDLybgmWypQZvTmxGPMphoiaAu4cyQnSkAdfGo(jcQBCr30RPPbaKlkQYJDNlWuZMJFRuA1AUatnBsnecgUDxC6JzdO7n7HSORe3FSsSGxPPsSpyxQexWe3XtKy4cqCARed7aCsmewjUaexdXcANiEHtfqCARed7aCsmewBe3bEAt8HUPDs8jUkX2vusmCbiUJNyJSyVPxdUDLybgmWqy95PIA5SOAqSpWqXNzCL(Mfa)cxPP(k4hScQRNNT0Hdgcbd3qwUeUaOnirRwthvpv4(DS7(UfsD2jBJBANp4v7HSORe3FSs8jUkXcYqlq67GjUgIf0orCbLyxQexWe3XYLWfaTrC)XkXN4QelidTaPVJetSpe3XYLWfaLyhM4ZfeX2lsLy1tBfqSGmOqQehGhKUzb20RH4cq8j6AusCbtSGJfgxO4gXDW6jXWfGyzLyIZI4qLyirIdv4cOeV30rUPpMeFIRsSGm0cK(oyIZIy0vq4OowjoTvIdHGHBKf7n9AWTRelWGbgE1Nj0cK(oylD4G9fcbd3qwUeUaOniXJD33TQOSqmnKLlFzba6KnirRw7l3Oozdz5YxwaGoztNnmQYEo2nYf4ByuBYkXpiXJyrngF5cm1e3qUOIoWVVSGU2bf2Q19Mos9jRSHCrfDGFFzbDTdIf1y8LlWutCd5Ik6a)(Yc6AFelQX4lxGPM4gYfv0b(9Lf01(uH7XQ1qiy4gYYLWfaTbjESBCbfd9r2mbfs95ds3SaB6100zdJQ0QvCbfd9r2GDnkFf8lmwyCHIB6SHrv2dzrxjU)yLybOpsZfvXeJWwhI3yK4oN4ov9IjEbkXqIwsCbi(Cbr8cuI9H4owUeUaOnIpbdgcOelacnMkWhtI7y5sIr4XiX40JrIdvIHejgHToeN2kX3fNeNoQsmSpo2wXnInYsKyiSpMeVjXNuGeNlWutmXi80MydDb(ys8HUPDIUaTrwS30Rb3UsSadgyuFKMlQIT8E(g1xUatnXbf2shoOp4D88CG6W63XU7g5c8nmQTngFYkXpiXJD33TQOSqmnKLlFkasm9AAqIwT2xUrDYMn0yQaFmFilx20zdJQSNESAnecgUHSCjCbqBqI9CS7(YnQt2SHgtf4J5dz5YMoByuLwTk1qiy4Mn0yQaFmFilx2ak66d(07IZx6OQvR9fcbd3qwUeUaOniXEo2DF5g1jByDb(y(g30orxG20zdJQ0QvSOgJVCbMAIBO(iFyDbb6K9qw0vI7pwjU)JDfpt8HfYL4Aiwq7KLeBxrPpMehcCfoEM4SigX6jXWfGyXcHci2hyiSxdXfG4vkjglUigCJSyVPxdUDLybgmWqJDfp)Mc5APdhSVCJ6KnBOXub(y(qwUSPZggv5rKlW3WO2KvIFqIwTk1qiy4Mn0yQaFmFilx2Gepgcbd3qwUeUaOnirRw7(wvuwiMgYYLpfajMEnnGIU(Gpv4(z1AFixGVHrTjwv8bxG3vI75yFHqWWnKLlHlaAdsKSORe3FSsCnelODI4qOKyrGxapDSsme2htI7y5sIpbaiX0RHyyhGtlj2HjgcRsI9b7sL4cM4oEIexdXg9smewjEHtfq8smYYLHvmjgUaeFRkkledXkmSFDDUNjEhjXWfGyBOXub(ysmYYLedjMoQsSdtCUrDsv2il2B61GBxjwGbdCyvZRGFPT(w8vhPkT0Hd2xiemCdz5s4cG2Gep23TQOSqmnKLlFkasm9AAqIhXIAm(YfyQjUH6J8H1fCQWh7l3OozdRlWhZ34M2j6c0MoByuLwT2DiemCdz5s4cG2GepIf1y8LlWutCd1h5dRliqc9yF5g1jByDb(y(g30orxG20zdJQ8y3Iaf5Z8kBc3qwU8fwX8y39PbaKlkQYMIkEgOB8va5SZvTATVCJ6KnBOXub(y(qwUSPZggvzpwTQbaKlkQYMIkEgOB8va5SZvpMaFoqZMIkEgOB8va5SZvB3QIYcX0ak66doqbfwij0JsnecgUzdnMkWhZhYYLniXE6XQ1UdHGHBilxcxa0gK4XCJ6KnSUaFmFJBANOlqB6SHrv2dzXEtVgC7kXcmyGVBm(2B618IooTCwunyc85anXKf7n9AWTRelWGbwQyrfSP(eb7zfyPdh0w3yA3eVzGcgqpjzbzrx7kXc6ItI7aBpQelOlo9XK49MEn4gXgAs8MeB7M2kGyrGxapptCweJTlqs81bxipj2NubaiXK4Bnsp9AWexdXcqFKeBOliWNyCptw0vI7pwj2qxGpMeFOBANOlqj2Hj(Cbrmcpgj22tI1PGmTjoxGPMyI3rsCxkekG4a8adH9AiEhjXDSCjCbqjEbkXtLed0vE2sIlaXzrmqHbk2MyJoiG7cX1qCIOiUaeJwaL4CbMAIBKf7n9AWTlIBqSUaFmFJBANOlqTecRpe2EuF3fN(yguylVNVr9LlWutCqHT0Hd2nYf4ByuByDb(y(g30orxG(UqzbdFSpKlW3WO2eRk(GlW7kX9y1A3YkBy7vwiEikG8jU(0akmqX2ByupIf1y8LlWutCd1h5dRl4uH7HSOReByxGKyb1bxipj2qxGpMeFOBANOlqj(wJ0tVgIZI4duvKyJoiG7cXqIe7dXDwDcil2B61GBxexbgmWyDb(y(g30orxGAjewFiS9O(Ulo9XmOWwEpFJ6lxGPM4GcBPdhm3OozdRlWhZ34M2j6c0MoByuLhLv2W2RSq8qua5tC9PbuyGIT3WOEelQX4lxGPM4gQpYhwxWPcLSORext887I4sm6EGIjoTvI3B61qCnXZedH3WOsSec4JjXx7Dgn6JjX7ijEQK4ft8smqnHIlG49MEnnYI9MEn42fXvGbdmQpYxyCXPL1ep)UiUbfMSGSyVPxdUjrnFjWNd0ehecRppvulNfvdkxWbOvnpPEp49eHsGIV6CvYI9MEn4Me18LaFoqtSadgyiS(8urTCwunigAcJvjFlQM2NXjzXEtVgCtIA(sGphOjwGbdmewFEQOwolQg0mEw0(vWVfJDupUPxdzXEtVgCtIA(sGphOjwGbdmewFEQOwolQguc0vc7a9HuXynswqw01UsSaC9H4oRlDiljgBxqrjX3cPciEJrIb7yQyIlyIZfyQjM4DKeJV6SaVWKf7n9AWn01NG3ngF7n9AErhNwolQgmSQXshoyiemClSQ5vWV0wFl(QJuLnirYI9MEn4g66JadgyPJf14dDn9RLoCW(YfyQzZXpX4EwbKfDL4(JvI7y5sIpbaiX0RH4Ai(wvuwigIfRk6JjXBsCuxCsSq0pI9bVJNNjoekjEQKyhM4ZfeXi8yK4cPcURiX(G3XZZe7dXD8eBela3duIXqaLyS9kleWUoYaJ6JmuhPciEhjXcqFKel44ItIDmX1q8TQOSqmehQWfqjUJNaIDyI7DJHRCbyIlaXg2RSqahxuLyhtSgaqUOOkBehGnNcOelwv0htIbkob(n9AWe7WedH9XKyd7vwiGJlQsCxaogL4DKelyDKkGyhtCbLnYI9MEn4g66JadgyKLlFkasm9AS0HdICb(gg1MyvXhCbExj(y3(G3XZZNgui6NvRIA2GDDKT9Mos9iaAu4cyQnS9kleWXfvFIahJ20aaYffv5X(UvfLfIPH6J8fgxC2Gep23TQOSqmnS9klepefq(K6M2niXEo2Tp4D88CGcgqoPvR5g1jByDb(y(g30orxG20zdJQ8iYf4ByuByDb(y(g30orxG(Uqzbd3ZX(UvfLfIPb76iBqIh7UVBvrzHyAO(iFHXfNnirRwXIAm(YfyQjUH6J8H1fCQqTATpa0OWfWuBy7vwiGJlQ(ebogTPbaKlkQYJ9bGgfUaMAl3y4kxa(HtWMRPI20aaYffvzph7UpCbfd9r2qwXn9O(WvePoPvRHqWWnKvCtpQpCfrQt(SHq3PCzdsShYIUsSaCpqjgdbuIpxqelcLedjsSrheWDH4oZOZ6cX1qCAReNlWutIDyI7aWM2WqrIpXvbUsSJhbmjEVPJujgHToed7M2PpMelCasNtCUatnXnYI9MEn4g66JadgyS9klepefq(exFS0Hdgcbd3Gx9zcTaPVdUbjESpPgcbd3qa20ggk(Gxf4Ads8iwuJXxUatnXnuFKpSUGajeKf7n9AWn01hbgmW3ngF7n9AErhNwolQg8kXKfDLybq30M4Ua8c45zIfG(ij2qxaX7n9AiolIbkmqX2e3PQxmXi80MySUaFmFJBANOlqjl2B61GBORpcmyGr9r(W6cS8E(g1xUatnXbf2shoyUrDYgwxGpMVXnTt0fOnD2WOkpIf1y8LlWutCd1h5dRl4uKlW3WO2q9r(W6cExOSGHp2NSYg2ELfIhIciFIRpT0Vh4J5X(UvfLfIPb76iBqIKfDL4UauyfqCwedHvI70IoB61qCNz0zDHyhM4DotCNQEj2XepvsmKyJSyVPxdUHU(iWGbwUOZMEnwEpFJ6lxGPM4GcBPdhSpKlW3WO22y8jRe)Gejl6kX9hReByVYcbXDqbKe3jDtBIDyIHW(ysSH9kleWXfvjUlahJs8osId1rQaIr4XiXQGq0bkXsiGpMeN2kXJkisInVYgzXEtVgCdD9rGbdm2ELfIhIciFsDtBlD4GIA2GDDKT9Mos9iaAu4cyQnS9kleWXfvFIahJ20aaYffv5rrnBWUoYgqrxFWbkO5vsw0vI7SiI9mMyiSsmQpYW4ItmXomX3vuuLeVJKyBOXub(ysmYYLe7yIHejEhjXqyFmj2WELfc44IQe3fGJrjEhjXH6ivaXoMyiXgXe3zsPNEnBmE2sIVlojg1hzyCXjXomXNliIruqrjXHkXqZggvIZIytnjoTvIboCsC4zIrSE6JjXlXMxzJSyVPxdUHU(iWGbg1h5lmU40shoy33QIYcX0q9r(cJloBx7fyQ4tf(y3snecgUzdnMkWhZhYYLnirRw7l3OozZgAmvGpMpKLlB6SHrv2JvRIA2GDDKnGIU(GduW7IZx6OQanVYEokQzd21r22B6i1JaOrHlGP2W2RSqahxu9jcCmAtdaixuuLhf1Sb76iBafD9bF6DX5lDuLSORe3FSsChlxsSGRys8MeB7M2kGyrGxapptmcpTjwaeAmvGpMe3XYLedjsCweleeNlWutSLexaIR0wbeNBuNetCneB0BJSyVPxdUHU(iWGbgz5YxyftlD4G(G3XZZbkya5KhZnQt2SHgtf4J5dz5YMoByuLhZnQt2W6c8X8nUPDIUaTPZggv5rSOgJVCbMAIBO(iFyDbbkOqYQ1U7o3OozZgAmvGpMpKLlB6SHrvESVCJ6KnSUaFmFJBANOlqB6SHrv2JvRyrngF5cm1e3q9r(W6cckCpKfDL4ovJaMedHvI7KISGa(ysCxIRjKsSdt85cI47oeBQjX(KfXDSCjCbqj2hCQR0sIlaXomXg6c8XK4dDt7eDbkXoM4CJ6KQK4DKeJWJrIT9KyDkitBIZfyQjUrwS30Rb3qxFeyWalvKfeWhZNyCnHulD4GDduyGIT3WOA1Qp4D888Pb0tA16TQOSqmnKLlFzba6KnGIU(GduWoxaW8k75y39HCb(gg1MyvXhCbExj2QvFW7455tdgqozph7UVCJ6KnSUaFmFJBANOlqB6SHrvA1A35g1jByDb(y(g30orxG20zdJQ8yFixGVHrTH1f4J5BCt7eDb67cLfmCp9qw0vI7pwjUJcM4Aiwq7eXomXNliIL1iGjXJQsIZI47ItI7KISGa(ysCxIRjKAjX7ijoTvGs8cuIJkgtCAVdXcbX5cm1etCbLe39jjgHN2eFRrc5zpnYI9MEn4g66JadgyKLlFHvmT0HdIf1y8LlWutCd1h5dRliqDlec8wJeYZM0X4A2jF61UuCtNnmQYEo6dEhpphOGbKtEm3OozdRlWhZ34M2j6c0MoByuLwT2xUrDYgwxGpMVXnTt0fOnD2WOkjl6kX9hReByVYcbXDqbKbmXDs30MyhM40wjoxGPMe7yI3WckjolILUsCbi(CbrS9Iuj2WELfc44IQe3fGJrjwdaixuuLeJWtBIfG(id1rQaIlaXg2RSqa76ijEVPJuBKf7n9AWn01hbgmWy7vwiEikG8j1nTT8E(g1xUatnXbf2shoy35cm1SzRBmTBI3mqcTFhXIAm(YfyQjUH6J8H1feiHOhRw7wuZgSRJST30rQhbqJcxatTHTxzHaoUO6te4y0MgaqUOOk7HSORe3FSsSbeaOJubeNfXcWvokgtCneVeNlWutIt7nj2XeBw(ysCwelDL4njoTvIbUPDsC6OAJSyVPxdUHU(iWGbgdba6ivWlRh6khfJT8E(g1xUatnXbf2shoyUatnBPJQVSEsxdKqp5Xqiy4gYYLWfaTjledzrxjU)yL4owUK4ElaqNK4AINj2Hj2Odc4Uq8osI7yVeVaL49MosL4DKeN2kX5cm1Kye1iGjXsxjwcb8XK40wj(AVZOXgzXEtVgCdD9rGbdmYYLVSaaDslVNVr9LlWutCqHT0HdICb(gg1MSs8ds8y3HqWWnKLlHlaAtwigRwdHGHBilxcxa0gqrxFWb6wvuwiMgYYLVWkMnGIU(GTAveOiFMxzt4gYYLVWkMh7lecgUfgRsgHWzdO7npIf1y8LlWutCd1h5dRliqDEph3B6i1NSYgYfv0b(9Lf01(0G3Z3O(0rrDfFelQX4lxGPM4gQpYhwxqG6(KcSBHKaqUrDYwIWX5RGFWBQnD2WOk7PhYI9MEn4g66JadgyuFKH6ivGLoCqzLnKlQOd87llORDl97b(yES7CJ6KnSUaFmFJBANOlqB6SHrvEelQX4lxGPM4gQpYhwxWPixGVHrTH6J8H1f8UqzbdB1QSYg2ELfIhIciFIRpT0Vh4Jzph7Upa0OWfWuBy7vwiGJlQ(ebogTPbaKlkQsRw3B6i1NSYgYfv0b(9Lf01(0G3Z3O(0rrDf3dzrxjU)yLyJoiG7eXi80M4US(ec09afqCxWBeLyOjQymXPTsCUatnjgHhJehQehQXcbXcTFbOrCOcxaL40wj(wvuwigIVfQIjoCVh0il2B61GBORpcmyGX2RSq8qua5tQBABPdheankCbm1M46tiq3duWteVr0MgaqUOOkpICb(gg1MSs8ds8yUatnBPJQVSEI38j0(DA33QIYcX0W2RSq8qua5tQBA3KqGn9AeO5v2dzrxjU)yLyd7vwiiwqbl2M4Aiwq7eXqtuXyItBfOeVaL4vkXe7ZTq9XSrwS30Rb3qxFeyWaJTxzH4Dbl22shoiyD5trQt2wPe385uH7hzr)XkXcqFKeBOlG4Si(wdgcvjUtl4aI71UGmTtmXIG6IjUgI7mH8jOrCVc5ojKjwqRb2bOe7yItBhtSJjEj22nTvaXIaVaEEM40EhIbQSY0htIRH4otiFcigAIkgtSCbhqCAxqM2jMyht8gwqjXzrC6OkXfuswS30Rb3qxFeyWaJ6J8H1fy598nQVCbMAIdkSLoCqSOgJVCbMAIBO(iFyDbNICb(gg1gQpYhwxW7cLfm8Xqiy4MCbh8s7cY0oBqIwETxFckSL(KkaajMphfvL(MAqHT0NubaiX85Wbt)Ea(0GcbzrxjU)yLybOpsIpX4EM4Si(wdgcvjUtl4aI71UGmTtmXIG6IjUgIn6L4ckXUujUGjUJNyJ4EfYDsitSGwdSdqj2HjoTDmXoM4LyB30wbelc8c45zIt7DigOYktFmjgAIkgtSCbhqCAxqM2jMyht8gwqjXzrC6OkXfuswS30Rb3qxFeyWaJ6J8bh3Zw6WbdHGHBYfCWlTlit7SbjEe5c8nmQnzL4hK4X(cHGHBilxcxa0gKOLx71NGcBPpPcaqI5ZrrvPVPguyl9jvaasmFoCW0VhGpnOqCSVqiy4MCbh8s7cY0oBqIKfDL4(JvIfG(ijwWXfNe7WeFUGiwwJaMepQkjolIbkmqX2e3PQxCJyJSej(U40htI3KyHG4cqmAbuIZfyQjMyeEAtSHUaFmj(q30orxGsCUrDsvs8osIpxqeVaL4PsIHW(ysSH9kleWXfvjUlahJsCbiUl4ZxB)sChYNdAyrngF5cm1e3q9r(W6coTd)jj2utmXPTsmQpokekXfmXNK4DKeN2kXdeAOciUGjoxGPM4gXDwexwsSSiEQKyrGIXeJ6JmmU4KyOj9iXBmsCUatnXeVaLyzLPkjgHN2e3XEjgHToedH9XKyS9kleWXfvjwe4yuIDyId1rQaIDmXlY1JByuBKf7n9AWn01hbgmWO(iFHXfNw6WbrUaFdJAtwj(bjEeSU8Pi1jBOfsfvNS5ZP3fNV0rvb2V2jpIf1y8LlWutCd1h5dRliqDlecuOca5g1jBOowbNB6SHrvkW9Mos9jRSHCrfDGFFzbDTfaYnQt2eXNV2(9f95GMoByuLcSBSOgJVCbMAIBO(iFyDbN2H)K9ia0TOMnyxhzBVPJupcGgfUaMAdBVYcbCCr1NiWXOnnaGCrrv2tph7Upa0OWfWuBy7vwiGJlQ(ebogTPbaKlkQsRw77wvuwiMgSRJSbjEeankCbm1g2ELfc44IQprGJrBAaa5IIQ0Q19Mos9jRSHCrfDGFFzbDTpn498nQpDuuxX9qwS30Rb3qxFeyWaJCrfDGFFzbDTT8E(g1xUatnXbf2shoiqHbk2EdJ6XCbMA2shvFz9KUEQqYQ1UZnQt2qDSco30zdJQ8OSYg2ELfIhIciFIRpnGcduS9gg1ESAnecgUbnWqGOpMp5coyumUbjsw0vIne1RVrIV1i90RH4SigNLiX3fN(ysSrheWDH4AiUGHdqYfyQjMye26qmSBAN(ysCNtCbigTakX4CVhOsIrRqmX7ijgc7JjXDbF(A7xI7q(CaX7ij(qHCVelaDSco3il2B61GBORpcmyGX2RSq8qua5tC9XshoiqHbk2EdJ6XCbMA2shvFz9KUEQqCSVCJ6KnuhRGZnD2WOkpMBuNSjIpFT97l6ZbnD2WOkpIf1y8LlWutCd1h5dRl4uHsw0vIpHvvKyJoiG7cXqIexdXlMy0DotCUatnXeVyIflm2dJQLeRcIRkMeJWwhIHDt70htI7CIlaXOfqjgN79avsmAfIjgHN2e3f85RTFjUd5ZbnYI9MEn4g66JadgyS9klepefq(exFS8E(g1xUatnXbf2shoiqHbk2EdJ6XCbMA2shvFz9KUEQqCSVCJ6KnuhRGZnD2WOkp2x35g1jByDb(y(g30orxG20zdJQ8iwuJXxUatnXnuFKpSUGtrUaFdJAd1h5dRl4DHYcgUNJD3xUrDYMi(812VVOph00zdJQ0Q1UZnQt2eXNV2(9f95GMoByuLhXIAm(YfyQjUH6J8H1feOGcTNEil2B61GBORpcmyGr9r(W6cS8E(g1xUatnXbf2shoiwuJXxUatnXnuFKpSUGtrUaFdJAd1h5dRl4DHYcg(y39HlOyOpYgYkUPh1hUIi1jTATVBvrzHyAWrfBFblC2Ge7XYR96tqHT0NubaiX85OOQ03udkSL(KkaajMphoy63dWNguOKf7n9AWn01hbgmWO(iFWX9SLx71NGcBPpPcaqI5ZrrvPVPguyl9jvaasmFoCW0VhGpnOqp2DFHqWWn5co4L2fKPD2GeTA9wvuwiMgYYLVWkMniXES0Hd2hUGIH(iBiR4MEuF4kIuN0Q1(UvfLfIPbhvS9fSWzdsKSORe3FSs8jgvS9fSWjXfuIDPsCbtm66dX3QIYcXGjolIrxFY1hI7yf30JkXgvePojXHqWWnYI9MEn4g66Jadgy4OITVGfoT0HdIlOyOpYgYkUPh1hUIi1jp2xiemCdz5s4cG2Gep2xiemCtSqOGNpWqyVMgKOL(KkaajMphfvL(MAqHT0NubaiX85Wbt)Ea(0Gctw0vI7pwj2Odc4or8IjoU4KyGIlqsSdtCneN2kXOfsLSyVPxdUHU(iWGbgBVYcXdrbKpPUPnzrxjU)yLyJoiG7cXlM44ItIbkUajXomX1qCAReJwivI3rsSrheWDIyhtCnelODISyVPxdUHU(iWGbgBVYcXdrbKpX1hYcYIUsC)XkX1qSG2jI7mJoRleNfXMAsCNQEjo97b(ys8osIvbHOduIZI4OpkXqIehQzQaIr4PnXDSCjCbqjl2B61GBjWNd0ehecRppvulNfvdQOINb6gFfqo7CvlD4G3QIYcX0qwU8PaiX0RPbu01hCGckSqTA9wvuwiMgYYLpfajMEnnGIU(GpvObuYIUsCVGZeNfXgNNlXb4oCDIyeEAtCNkOWOsSrU3dujXcANWe7WelwyShg1gXc5H4ynMkGyy30oXeJWtBIrlGsCaUdxNigcRyI3mvuXK4SigFEUeJWtBI35mXxjXfG4tiiCsmewj2ZgzXEtVgClb(CGMybgmWqy95PIA5SOAqFWxauUHr9faq7KqOpPI0VQLoCWqiy4gYYLWfaTbjEmecgUjwiuWZhyiSxtds0Q1WcJpc7M25dOORp4afuO9ZQ1qiy4MyHqbpFGHWEnniXJ3QIYcX0qwU8PaiX0RPbu01hSaf(KNc7M25dOORpyRwdHGHBilxcxa0gK4XBvrzHyAIfcf88bgc710ak66dwGcFYtHDt78bu01hSvRDFRkklettSqOGNpWqyVMgqrxFWNgu4(D8wvuwiMgYYLpfajMEnnGIU(GpnOW9RNJWUPD(ak66d(0Gc3H1pYIUsSX55sSHTQjXcqiSFjgHN2e3XYLWfaLSyVPxdULaFoqtSadgyiS(8urTCwuni6E3qG(W2QMpuiSFT0HdERkkletdz5YNcGetVMgqrxFWNkC)il6kXgNNlXbOGcptmcpTjUlfcfqCaEGHWEnedHxt1sIr3duIXqaL4SigpUOsCARehlekojwaSleNlWuZgXDGToedHvjXi80Myd7vwiujXczqiXfmX9wauDslj(eccNedHvIRHybTteVyIrHU2eVyIflm2dJAJSyVPxdULaFoqtSadgyiS(8urTCwuniUGIrntFmFaOWZwEpFJ6lxGPM4GcBPdhmecgUjwiuWZhyiSxtds0Q1(ebUIZgwJWpXcHcE(adH9ASAvdaixuuLnS9kleQ8vGWxb)YcGQtsw0vI7pwjwWR0uj2hSlvIlyI74jsmCbioTvIHDaojgcRexaIRHybTteVWPcioTvIHDaojgcRnInSlqs81bxipj2Hjgz5sIvaKy61q8TQOSqme7yIfUFyIlaXOfqjErSNBKf7n9AWTe4ZbAIfyWadH1NNkQLZIQbX(adfFMXv6Bwa8lCLM6RGFWkOUEE2sho4TQOSqmnKLlFkasm9AAafD9bFAqH7hzrxjU)yLyd7vwiujXczqiXfmX9wauDsIryRdXtLe7dXDSCjCbqTK4cqSpehQjcvhI7y5sIfCftIVloXe7dXDSCjCbqBe3zyIpHpd8DiUaeFOEbvSasIJ(Oe7jXqIeJWtBIX5EpqLeFRkkledUrwS30Rb3sGphOjwGbdmewFEQOwolQgeBVYcHkFfi8vWVSaO6Kw6WbVvfLfIPjwiuWZhyiSxtdOORp4afu4(D8wvuwiMgYYLpfajMEnnGIU(GduqH73XUVfsD2jBJEbvSasRwVfsD2jBhCg470JvRDFlK6St2qQtAFgy16TqQZozBCt78bVAph7UVqiy4gYYLWfaTbjA1Qiqr(mVYMWnKLlFHvm7XQ1WcJpc7M25dOORp4afui6hzbzrxjU)yL4OJtIlyIRjabcRelx01ujob(CGMyIRjEMyhMybqOXub(ysChlxsCN0qiyyIDmX7nDKQLexaIpxqeVaL4PsIZnQtQsI9jlI9SrwS30Rb3sGphOjwGbd8DJX3EtVMx0XPLZIQbLOMVe4ZbAIT0Hd2DF5g1jB2qJPc8X8HSCztNnmQsRwLAiemCZgAmvGpMpKLlBqI9CS7qiy4gYYLWfaTbjA16TQOSqmnKLlFkasm9AAafD9bFQW9RhYIUsCNu4fkMedVXy4EpGy4cqmeEdJkXEQO4aM4(JvIRH4BvrzHyi2hIlGubehEM4e4ZbAsmowzJSyVPxdULaFoqtSadgyiS(8urXw6WbdHGHBilxcxa0gKOvRHqWWnXcHcE(adH9AAqIwTERkkletdz5YNcGetVMgqrxFWNkC)(5p)Fa]] )
    

end
