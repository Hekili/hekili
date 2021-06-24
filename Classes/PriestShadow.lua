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


    spec:RegisterPack( "Shadow", 20210502, [[defBncqiufEKijxcvPKAtQk9juLIrPO0PuuSkvvHELQQAwOQ6wQQcAxk8lkLmmkfDmuvwgQsEMQQOPrPqxtKuBJsb9nrc14OufDokvjTofvP5POQUNiAFQk8pvvbCqrIAHOk6HOkvtKsPUiLQWgvvL8ruLsnsvvPCskfyLuQ8skvjmtvvP6MkQIDQQOFksidLsvDukvjAPQQc0tPOPks5QkQyRkQ0xfjyVQYFvPbtCyjlwrESkMmkxM0Mb1NPWOPKtt1QrvkXRfPA2I62q1UL63knCu54Iez5aphY0fUoiBhk9DOy8uQsDEvvwpQsjz(IW(r(X3lTNjRc99jVSjV4ZMP2M8AWNn0M2tBYRNz8JtFMC1j9YqFMDHRpttRITyEMC1V8wSxApt0cbo6Z0kco08AlBz4Hf004S42c54q5k8TpGcoSfYXp26zob55Wg0VPNjRc99jVSjV4ZMP2M8AWNn0MP4Nzbfwl4zA648(Z0YzmTFtptMIopttRITyiX(axrbz38u)iHx8tcVSjV4JSJSlnmALojZDDgjPTaG2bjyS0MKOagAqYzH6arsbusGxWrzJNz2rb6L2ZeV8(L27t(EP9m1UMYk7XZN5b4Hc86zobbdpM2TVl8nS0BHoAZu2aI7zIcGFI3N89mRt4B)mpvoFRt4BFZokEMzhf3UW1N50U9lEFYRxAptTRPSYE88zEaEOaVEM8GKOagAmC0Llx)uWZSoHV9ZK5ionFXld)8I3N)5lTNP21uwzpE(mRt4B)mXUo7QaiUW3(zYu0b4CHV9ZCoiLK5UoJe7baIl8TjzBso7MzlMMeUDZEBqsfKK1cfKyJ2KeVrv7XpsMGcs6niXHj53crcgpNjzXQGtXrI3OQ94hjEtYC)RbjZtLUscccOKGSk2Ib21MzlCVztAZuajvZizE8MrcpZfkiXrKSnjNDZSfttYKcVaLK5ApgKydm6fOKWTB2Bdsakka(j8TrK4WKaH82GetRITyGZfUsI9bocNKQzKWtTzkGehrYcfJN5b4Hc86zITaEnL1b3U5l8cUhgIKVKmljEJQ2JFK8rssSrBssIeKWPXa21MnQt4yvs(scaQv4fyOdKvXwmW5cxVCahHp0ucY54ugjFjHhKC2nZwm9a3B2DkxOyaXrYxs4bjNDZSftpqwfBXCXSa2LPvynG4izgs(sYSK4nQAp(rY8tsI9m1KKibjrL1ogiTaEBCB3WkWlGo0UMYkJKVKGTaEnL1bslG3g32nSc8cO3duSWWKmdjFjHhKC2nZwm9a21MnG4i5ljZscpi5SBMTy6bU3S7uUqXaIJKejibXP58nkGHgObU3SlslajFqcVizMx8(0gFP9m1UMYk7XZNzDcF7NjYQylMlMfWUCL3ptMIoaNl8TFMZtLUscccOK8BHiHdkibIJeZuyETpjPSzkBFs2MKWsjjkGHgK4WKKcGkSGHYK8xLcCLeh18MGK6eowLemwAtcSByfEBqcF)H)jjrbm0anEMhGhkWRN5eem8aU0RbubyE1ObehjFjHhKW0jiy4bgqfwWq5lCPaxhqCK8LeeNMZ3OagAGg4EZUiTaKmFsSXx8(m1V0EMAxtzL945ZSoHV9Z8u58ToHV9n7O4zMDuC7cxFMhg6fVpTHV0EMAxtzL945ZSoHV9Ze3B2fPf4zE(DY6nkGHgO3N89mpapuGxpZOYAhdKwaVnUTByf4fqhAxtzLrYxsqCAoFJcyObAG7n7I0cqYhKGTaEnL1bU3SlslW9aflmmjFjHhKW2yGSk2I5IzbSlx59i8t6EBqYxs4bjNDZSftpGDTzdiUNjtrhGZf(2pZ)MByrI9b(c84hjZJ3msm1cqsDcFBsILeGcduKfj2EtdrcgpSibPfWBJB7gwbEb0x8(mf)s7zQDnLv2JNpZ6e(2ptwH3v4B)mp)oz9gfWqd07t(EMhGhkWRNjpibBb8AkRJkNVSnqxiUNjtrhGZf(2pt7duyfqsSKaHusSDH3v4BtskBMY2NehMKQ)rIT30iXrK0Bqce34fVpTNV0EMAxtzL945ZSoHV9ZezvSfZfZcyxMwH1ZKPOdW5cF7N5CqkjMwfBXqskSagj2wRWIehMeiK3gKyAvSfdCUWvsSpWr4KunJKjTzkGemEotIAV5CGscdc4TbjHLssR27GeJdB8mpapuGxptongWU2SrDchRsYxsaqTcVadDGSk2Ibox46Ld4i8HMsqohNYi5ljCAmGDTzdGIxEJiz(jjX4WEX7t71xAptTRPSYE88zwNW3(zI7n7oLlu8mzk6aCUW3(zMYzm1pejqiLeCVzt5cfisCysofhNYiPAgjwqTHc82GeSRZiXrKaXrs1msGqEBqIPvXwmW5cxjX(ahHts1msM0MPasCejqCdsijLzmp8TRC(h)KCkuqcU3SPCHcsCys(TqKGzHYmsMusG6AkRKeljgAqsyPKaC4GKPFKGP8WBdsksmoSXZ8a8qbE9mNLKZUz2IPh4EZUt5cfJJvbmuejFqcFK8LKzjHPtqWWdlO2qbEBCXUoBaXrsIeKWdsIkRDmSGAdf4TXf76SH21uwzKmdjjsqcNgdyxB2aO4L3isMFssofkUHJRK8pjghgjZqYxs40ya7AZg1jCSkjFjba1k8cm0bYQylg4CHRxoGJWhAkb5CCkJKVKWPXa21MnakE5nIKpssYPqXnCC9fVp5ZMV0EMAxtzL945ZSoHV9Ze3B2DkxO4zYu0b4CHV9Z0g0OO6i)JeeN2msksW9MrYuUqbjhRcyOKuWHcib76SPnhK4WKaH82GeKvXwmW5cxjHd4iCsQMrcU3SPCHcejfqj5uCCkB8mpapuGxpZZUz2IPh4EZUt5cfJJvbmuejFqcFK8LeongWU2SrDchRsYxsaqTcVadDGSk2Ibox46Ld4i8HMsqohNYi5lj8GKZUz2IPhyxNDN2CmG4EX7t(47L2Zu7AkRShpFM1j8TFMyxNDN2C8mzk6aCUW3(zohKsYCxNrcp3CqsfKy5gwkGeoGVap(rcgpSi5Vb1gkWBdsM76msG4ijwsSrsIcyObIFswajByPasIkRDGizBsmtB8mpapuGxptVrv7XpsMFssSNPMKVKevw7yyb1gkWBJl21zdTRPSYi5ljrL1ogiTaEBCB3WkWlGo0UMYkJKVKG40C(gfWqd0a3B2fPfGK5NKeBijjsqYSKmljrL1ogwqTHc824IDD2q7AkRms(scpijQS2XaPfWBJB7gwbEb0H21uwzKmdjjsqcItZ5BuadnqdCVzxKwassscFKmZlEFYhVEP9m1UMYk7XZNzDcF7NjtXUqaVnUC5YasFMmfDaox4B)mT928MGeiKsITvSleWBdsSFUmGusCys(TqKCQMedniX7yjzURZGxaojEJcTy8tYciXHjXulG3gK8PByf4fqjXrKevw7qzKunJemEotILhKO9czyrsuadnqJN5b4Hc86zoljafgOiRAkRKKibjEJQ2JFK8bjP4utYmK8LKzjHhKGTaEnL1b3U5l8cUhgIKejiXBu1E8JKpssI9m1KmdjFjzws4bjrL1ogiTaEBCB3WkWlGo0UMYkJKejizwsIkRDmqAb8242UHvGxaDODnLvgjFjHhKGTaEnL1bslG3g32nSc8cO3duSWWKmdjZ8I3N89NV0EMAxtzL945ZSoHV9Ze76S70MJNjtrhGZf(2pZ5GusMlpjzBs4DBtIdtYVfIe228MGKwvgjXsYPqbj2wXUqaVniX(5Yas5NKQzKewkqjPakjzfHijSQMeBKKOagAGizHcsMn1KGXdlsoBZG8yMXZ8a8qbE9mrCAoFJcyObAG7n7I0cqY8jzwsSrs(NKZ2mipgmhH2U64QhRvrdTRPSYizgs(sI3OQ94hjZpjj2ZutYxsIkRDmqAb8242UHvGxaDODnLvgjjsqcpijQS2XaPfWBJB7gwbEb0H21uwzV49jF24lTNP21uwzpE(mRt4B)mrwfBXCXSa2LPvy9mp)oz9gfWqd07t(EMhGhkWRN5SKefWqJHLw5WAWDcsMpj8YMK8LeeNMZ3OagAGg4EZUiTaKmFsSrsMHKejizws40ya7AZg1jCSkjFjba1k8cm0bYQylg4CHRxoGJWhAkb5CCkJKzEMmfDaox4B)mNdsjX0QylgssHfWMxsSTwHfjomjHLssuadniXrKutluqsSKWCLKfqYVfIeRcRsIPvXwmW5cxjX(ahHtIMsqohNYibJhwKmpEZM0MPaswajMwfBXa7AZiPoHJvhV49jFP(L2Zu7AkRShpFM1j8TFMiiaqBMcUXEXlwRi0Z887K1BuadnqVp57zEaEOaVEMrbm0yeoUEJ9YCLK5tcVsnjFjzccgEGDDg8cWhSft)mzk6aCUW3(zohKsIjeaOntbKeljZtXAfHizBsksIcyObjHvfK4ismwVnijwsyUssfKewkja3WkijCCD8I3N8zdFP9m1UMYk7XZNzDcF7Nj21z3ybaTJN553jR3OagAGEFY3Z8a8qbE9mXwaVMY6GTb6cXrYxsIcyOXiCC9g7L5kjFqYFsYxsMLKjiy4b21zWlaFWwmnjjsqYeem8a76m4fGpakE5nIK5tYz3mBX0dSRZUtBogafV8grYmK8LK6eow9Y2yGTW5CGFUXcDSijjjionNVrbm0anWw4CoWp3yHowK8LeeNMZ3OagAGg4EZUiTaKmFsMLKutY)Kmlj2qs(JKevw7yeyCuCx4lCf6q7AkRmsMHKzEMmfDaox4B)mNdsjzURZijTfa0oiz78psCysmtH51(KunJK5MgjfqjPoHJvjPAgjHLssuadnibZ28MGeMRKWGaEBqsyPKCSQU184fVp5lf)s7zQDnLv2JNpZdWdf41ZKTXaBHZ5a)CJf6ync)KU3gK8LKzjjQS2XaPfWBJB7gwbEb0H21uwzK8LeeNMZ3OagAGg4EZUiTaK8bjylGxtzDG7n7I0cCpqXcdtsIeKW2yGSk2I5IzbSlx59i8t6EBqYmK8LKzjHhKaGAfEbg6azvSfdCUW1lhWr4dnLGCooLrsIeKuNWXQx2gdSfoNd8ZnwOJfjjjbXP58nkGHgOb2cNZb(5gl0XIKzEM1j8TFM4EZM0MPGx8(Kp75lTNP21uwzpE(mRt4B)mrwfBXCXSa2LPvy9mzk6aCUW3(zohKsIzkmV2MemEyrI9lVNaALUciX(OkJtcuNveIKWsjjkGHgKGXZzsMusM08IHeEztERjzsHxGssyPKC2nZwmnjNfxrKmvN0FMhGhkWRNjaQv4fyOdUY7jGwPRGlhQY4dnLGCooLrYxsWwaVMY6GTb6cXrYxsIcyOXiCC9g7L7exEzts(GKzj5SBMTy6bYQylMlMfWUmTcRbdcuHVnj)tIXHrYmV49jF2RV0EMAxtzL945ZSoHV9ZezvSfZ9akK1ZKPOdW5cF7N5CqkjMwfBXqcVdkKfjBtcVBBsG6SIqKewkqjPakjfJHiX7ZI7TX4zEaEOaVEMGYzxfR2XOym0WBs(Ge(S5lEFYlB(s7zQDnLv2JNpZdWdf41ZeXP58nkGHgObU3SlslajFqc2c41uwh4EZUiTa3duSWWK8LKjiy4bRaPFdRfYWkgqCptMIoaNl8TFMZbPKmpEZiXulajXsYzBeeUsITlq6KKM1czyfis4a7brY2KKYPi7XGK0sr2ofrcVVnSdWjXrKewoIehrsrILByPas4a(c84hjHv1Kau2gH3gKSnjPCkYEqcuNveIewbsNKWAHmScejoIKAAHcsILKWXvswO4zE(DY6nkGHgO3N89m9ouaaIlUo8Zm8t6OpsYRNP3HcaqCX1XXvMxH(m57zESkVFM89mRt4B)mX9MDrAbEX7tEX3lTNP21uwzpE(mzk6aCUW3(zohKsY84nJK)kx)ijwsoBJGWvsSDbsNK0SwidRarchypis2MeZ0gKKwkY2Pis49THDaojomjHLJiXrKuKy5gwkGeoGVap(rsyvnjaLTr4TbjqDwrisyfiDscRfYWkqK4isQPfkijwschxjzHIN5b4Hc86zobbdpyfi9ByTqgwXaIJKVKGTaEnL1bBd0fI7z6DOaaexCD4Nz4N0rFKKxFp7MzlMEGDD2DAZXaI7z6DOaaexCDCCL5vOpt(EMhRY7NjFpZ6e(2ptCVzx4C97fVp5fVEP9m1UMYk7XZNzDcF7NjU3S7uUqXZKPOdW5cF7N5CqkjZJ3ms4zUqbjomj)wisyBZBcsAvzKeljafgOilsS9MgAqIzSCKCku4TbjvqInsYcibFbkjrbm0arcgpSiXulG3gK8PByf4fqjjQS2HYiPAgj)wiskGssVbjqiVniX0Qylg4CHRKyFGJWjzbKyF0VJLFi5V7D6deNMZ3OagAGg4EZUiTaF8hi1KyObIKWsjb3BhhcNKfMKuts1msclLKgcFsbKSWKefWqd0GKuoJw(jHTK0BqchqrisW9MnLluqcuhEMKkNjjkGHgiskGscBJqzKGXdlsMBAKGXsBsGqEBqcYQylg4CHRKWbCeojomjtAZuajoIKcB55AkRJN5b4Hc86zITaEnL1bBd0fIJKVKakNDvSAhd8fRIRDm8MKpi5uO4goUsY)KyZrQj5ljionNVrbm0anW9MDrAbiz(Kmlj2ij)tcVi5pssuzTJbUJuWVH21uwzK8pj1jCS6LTXaBHZ5a)CJf6yrYFKKOYAhdo0VJLFUzVtFODnLvgj)tYSKG40C(gfWqd0a3B2fPfGKp(dqsQjzgs(JKmljCAmGDTzJ6eowLKVKaGAfEbg6azvSfdCUW1lhWr4dnLGCooLrYmKmdjFjzws4bjaOwHxGHoqwfBXaNlC9YbCe(qtjiNJtzKKibj8GKZUz2IPhWU2SbehjFjba1k8cm0bYQylg4CHRxoGJWhAkb5CCkJKejiPoHJvVSngylCoh4NBSqhlssscItZ5BuadnqdSfoNd8ZnwOJfjZ8I3N86pFP9m1UMYk7XZNzDcF7Nj2cNZb(5gl0X6zEaEOaVEMafgOiRAkRK8LKOagAmchxVXEzUsYhKydjjrcsMLKOYAhdChPGFdTRPSYi5ljSngiRITyUywa7YvEpakmqrw1uwjzgssKGKjiy4buddbYEBCzfi9wrObe3Z887K1BuadnqVp57fVp5Ln(s7zQDnLv2JNpZ6e(2ptKvXwmxmlGD5kVFMmfDaox4B)mn50JxzsoBZ8W3MKyjbflhjNcfEBqIzkmV2NKTjzHH)dJcyObIemwAtcSByfEBqYFsYcibFbkjOOoPRmsW3jejvZibc5Tbj2h97y5hs(7ENojvZi5ZuuAKmposb)gpZdWdf41ZeOWafzvtzLKVKefWqJr446n2lZvs(GeBKKVKWdsIkRDmWDKc(n0UMYkJKVKevw7yWH(DS8Zn7D6dTRPSYi5ljionNVrbm0anW9MDrAbi5ds41lEFYRu)s7zQDnLv2JNpZ6e(2ptKvXwmxmlGD5kVFMNFNSEJcyOb69jFpZdWdf41ZeOWafzvtzLKVKefWqJr446n2lZvs(GeBKKVKWdsIkRDmWDKc(n0UMYkJKVKWdsMLKOYAhdKwaVnUTByf4fqhAxtzLrYxsqCAoFJcyObAG7n7I0cqYhKGTaEnL1bU3SlslW9aflmmjZqYxsMLeEqsuzTJbh63XYp3S3Pp0UMYkJKejizwsIkRDm4q)ow(5M9o9H21uwzK8LeeNMZ3OagAGg4EZUiTaKm)KKWlsMHKzEMmfDaox4B)mTxOkhjMPW8AFsG4izBskej4v)JKOagAGiPqKWTiKpLv(jrT3hLlibJL2Ka7gwH3gK8NKSasWxGsckQt6kJe8DcrcgpSiX(OFhl)qYF370hV49jVSHV0EMAxtzL945ZSoHV9Ze3B2fPf4zE(DY6nkGHgO3N89m9ouaaIlUo8Zm8t6OpsYRNP3HcaqCX1XXvMxH(m57zEaEOaVEMionNVrbm0anW9MDrAbi5dsWwaVMY6a3B2fPf4EGIfg(zESkVFM89I3N8kf)s7zQDnLv2JNpZ6e(2ptCVzx4C97z6DOaaexCD4Nz4N0rFKKxFp7MzlMEGDD2DAZXaI7z6DOaaexCDCCL5vOpt(EMhRY7NjFV49jVSNV0EMAxtzL945ZKPOdW5cF7N5CqkjMPW8ABskej5cfKau0ccsCys2MKWsjbFXQpZ6e(2ptKvXwmxmlGDzAfwV49jVSxFP9m1UMYk7XZNjtrhGZf(2pZ5GusmtH51(KuisYfkibOOfeK4WKSnjHLsc(IvjPAgjMPW8ABsCejBtcVB7NzDcF7NjYQylMlMfWUCL3V4fptgUXnaENUgOxAVp57L2Zu7AkRShpFMDHRptwbshF3(Y0t63lhuau0r7J(mRt4B)mzfiD8D7ltpPFVCqbqrhTp6lEFYRxAptTRPSYE88z2fU(mrq9uEx2TW1W6hkEM1j8TFMiOEkVl7w4Ay9dfV495F(s7zQDnLv2JNpZUW1NPr(hN1DHVfc54EUcF7NzDcF7NPr(hN1DHVfc54EUcF7x8(0gFP9m1UMYk7XZNzx46ZKb0Ib7a9Ivrin)mRt4B)mzaTyWoqVyvesZV4fptMcxq54L27t(EP9mRt4B)mrEw7J(m1UMYk7XZx8(KxV0EMAxtzL945Z8a8qbE9mNGGHhyxNbVa8behjjsqYeem8GBXOGR3WqiF7be3ZSoHV9ZKBdF7x8(8pFP9m1UMYk7XZN5Y9mrA8mRt4B)mXwaVMY6ZeBLH0NjBJbYQylMlMfWUCL3JWpP7TbjFjHTXaBHZ5a)CJf6ync)KU3gptSf42fU(mzBGUqCV49Pn(s7zQDnLv2JNpZL7zI04zwNW3(zITaEnL1Nj2kdPpt2gdKvXwmxmlGD5kVhHFs3Bds(scBJb2cNZb(5gl0XAe(jDVni5ljSngmf7cb824YLldiDe(jDVnEMylWTlC9zw58LTb6cX9I3NP(L2Zu7AkRShpFMl3ZePXZSoHV9ZeBb8AkRptSvgsFMionNVrbm0anW9MDrAbi5ds4fj)tYeem8a76m4fGpG4EMmfDaox4B)mnJceKaH82GetTaEBqYNUHvGxaLKki5p)NKOagAGizbKyJ)tIdtYVfIKcOK4njZDDg8cWFMylWTlC9zI0c4TXTDdRaVa69aflm8lEFAdFP9m1UMYk7XZN5Y9mrA8mRt4B)mXwaVMY6ZeBLH0N5z3mBX0dSRZUkaIl8ThqCK8LKzjHhKakNDvSAhJIXqdiossKGeq5SRIv7yumgAWGav4BtY8tscF2KKejibuo7Qy1ogfJHgafV8grYhjjHpBsY)KKAs(JKmljrL1ogwqTHc824IDD2q7AkRmssKGKZIv7QJr6)aE1KmdjZqYxsMLKzjbuo7Qy1ogfJHgEtYhKWlBssIeKG40C(gfWqd0a76SRcG4cFBs(ijjPMKzijrcsIkRDmSGAdf4TXf76SH21uwzKKibjNfR2vhJ0)b8QjzMNjtrhGZf(2ptEF3mBX0Ky)DZKm3c41uw5NK5GugjXsc3UzsMu4fOKuNWXwH3gKGDDg8cWhKW7qaG2r(hjqiLrsSKC2oaBMemwAtsSKuNWXwHsc21zWlaNemEyrI3Nf3BdskgdnEMylWTlC9zYTB(cVG7HHEX7Zu8lTNP21uwzpE(mpapuGxpZjiy4b21zWlaFaX9mRt4B)mHDGoL3L9I3N2ZxAptTRPSYE88zEaEOaVEMtqWWdSRZGxa(aI7zwNW3(zoPaKcs3BJx8(0E9L2Zu7AkRShpFM1j8TFMz3WkqxElqmdCTJNjtrhGZf(2pZ5Gus(7UHvWBqKyheZax7GehMKWsbkjfqjHxKSasWxGssuadnq8tYciPymejfqBEtqcIRW0EBqc8cibFbkjHv1KKItnA8mpapuGxpteNMZ3OagAGgz3WkqxElqmdCTds(ijj8IKejizws4bjGYzxfR2XOym0qT3okqKKibjGYzxfR2XOym0WBs(GKuCQjzMx8(KpB(s7zQDnLv2JNpZdWdf41ZCccgEGDDg8cWhqCpZ6e(2pZQpkkav(EQC(fVp5JVxAptTRPSYE88zwNW3(zEQC(wNW3(MDu8mZokUDHRpZdMZlEFYhVEP9m1UMYk7XZNzDcF7NjaQV1j8TVzhfpZSJIBx46ZeV8(fV4zEWCEP9(KVxAptTRPSYE88zcH0lglpR3tHcVnEFY3ZSoHV9ZePfWBJB7gwbEb0N553jR3OagAGEFY3Z8a8qbE9mNLeSfWRPSoqAb8242UHvGxa9EGIfgMKVKWdsWwaVMY6GB38fEb3ddrYmKKibjZscBJbYQylMlMfWUCL3dGcduKvnLvs(scItZ5BuadnqdCVzxKwas(Ge(izMNjtrhGZf(2pZ5Gusm1c4TbjF6gwbEbusCys(TqKGXZzsS8GeTxidlsIcyObIKQzKy)fJciXg0WqiFBsQMrYCxNbVaCskGssVbjaTy)4NKfqsSKauyGISiXmfMx7tY2Keywswaj4lqjjkGHgOXlEFYRxAptTRPSYE88zcH0lglpR3tHcVnEFY3ZSoHV9ZePfWBJB7gwbEb0N553jR3OagAGEFY3Z8a8qbE9mJkRDmqAb8242UHvGxaDODnLvgjFjHTXazvSfZfZcyxUY7bqHbkYQMYkjFjbXP58nkGHgObU3SlslajFqcVEMmfDaox4B)mnTwqqcV7GdKhKyQfWBds(0nSc8cOKC2M5HVnjXss6QYrIzkmV2Neios8MKuEThV495F(s7zQDnLv2JNpZTZ)UhmNNjFpZ6e(2ptCVz3PCHINjtrhGZf(2pZTZ)UhmhsWR0vejHLssDcFBs2o)JeiunLvsyqaVni5yvDRzVniPAgj9gKuisksaQbuUaKuNW3E8Ix8mpm0lT3N89s7zQDnLv2JNpZ6e(2ptUfJcUEddH8TFMmfDaox4B)mNdsjX(lgfqInOHHq(2KGXdlsM76m4fGpi5VTzgjWlGK5UodEb4KCwCfrYcdtYz3mBX0K4njHLssR27Ge(Sjji9SndrYgwkaJJusGqkjBtYHrcuNveIKWsjX(AUmwejPbkpiH3x8PkizEuMhv4BtIJijQS2HY4NKfqIdtsyPaLemEotsVbjtkjvVHLcizURZiXEaG4cFBsclhrcSByfdss5iuCUGKyjb9RpKewkj5cfKWTyuajEddH8TjzHjjSusGDdRGKyjb76msuaex4Btc8ciP3Me7f)aE1OXZ8a8qbE9m5aUIIbsZWxUfJcUEddH8Tj5ljZsYeem8a76m4fGpG4ijrcs4bjOfkp5nBCw8PkU4kZJk8ThAxtzLrYxso7MzlMEGDD2vbqCHV9aO4L3is(ijj8ztssKGey3WkUafV8grY8j5SBMTy6b21zxfaXf(2dGIxEJizgs(sYSKa7gwXfO4L3is(ijjNDZSftpWUo7QaiUW3Eau8YBej)tcFPMKVKC2nZwm9a76SRcG4cF7bqXlVrKm)KKyCyK8hjXgjjrcsGDdR4cu8YBejFqYz3mBX0dUfJcUEddH8Thmiqf(2KKibjWUHvCbkE5nIK5tYz3mBX0dSRZUkaIl8ThafV8grY)KWxQjjrcsolwTRogP)d4vtsIeKmbbdpMY7YYqOyaXrYmV49jVEP9m1UMYk7XZNjtrhGZf(2pZ5Gus4zXmus8g5mLKfMK5(xKaVasclLeyhGcsGqkjlGKTjH3TnjfCOasclLeyhGcsGq6GKuWdls(0nScs(RsjXAZmsGxajZ9VgpZUW1NjYByO81ixmVIfGUtfZqVl8fwb7XJFpZdWdf41ZCccgEGDDg8cWhqCKKibjHJRK8bj8zts(sYSKWdsolwTRogTByfx4sjzMNzDcF7NjYByO81ixmVIfGUtfZqVl8fwb7XJFV495F(s7zQDnLv2JNpZ6e(2pt4sVgqfG5vJEMmfDaox4B)mNdsj5VkLeEBOcW8QrKSnj8UTjzHcKZuswysM76m4fGpizoiLK)Qus4THkaZRMHiXBsM76m4fGtIdtYVfIeRcRsI6HLciH3gSyvsSbnw3ybv4BtYci5VCnZizHjHN5fHwC0GKuO8Ge4fqcBdejXsYKscehjtk8cusQt4yRWBds(RsjH3gQamVAejXscEzVDChPKewkjtqWWJN5b4Hc86zYdsMGGHhyxNbVa8behjFjzws4bjNDZSftpWUo7glaODmG4ijrcs4bjrL1ogyxNDJfa0ogAxtzLrYmK8LKzjbBb8AkRd2gOlehjFjbXP58nkGHgOb2cNZb(5gl0XIKKKWhjjsqsDchREzBmWw4CoWp3yHowKKKeeNMZ3OagAGgylCoh4NBSqhls(scItZ5BuadnqdSfoNd8ZnwOJfjFqcFKmdjjsqYeem8a76m4fGpG4i5ljZscAHYtEZggGfRE9gRBSGk8ThAxtzLrsIeKGwO8K3SbSRz2DHVt5fHwC0q7AkRmsM5fVpTXxAptTRPSYE88zwNW3(zI7nZOWv0Z887K1BuadnqVp57zEaEOaVEMEJQ2JFKmFsSxTjjFjzwsMLeSfWRPSoQC(Y2aDH4i5ljZscpi5SBMTy6b21zxfaXf(2diossKGeEqsuzTJHfuBOaVnUyxNn0UMYkJKzizgssKGKjiy4b21zWlaFaXrYmK8LKzjHhKevw7yyb1gkWBJl21zdTRPSYijrcsy6eem8WcQnuG3gxSRZgqCKKibj8GKjiy4b21zWlaFaXrYmK8LKzjHhKevw7yG0c4TXTDdRaVa6q7AkRmssKGeeNMZ3OagAGg4EZUiTaKmFssnjZ8mzk6aCUW3(zohKsY84nZOWvejyS0MKkNj5pjX2BAiskGsceh)KSas(TqKuaLeVjzURZGxa(Ge7rJGakj)nO2qbEBqYCxNrIJiPoHJvjzBsclLKOagAqIdtsuzTdLniXmwosGqEBqsfKK6)jjkGHgisW4HfjMAb82GKpDdRaVa64fVpt9lTNP21uwzpE(mRt4B)mHARn)72l26zYu0b4CHV9ZCoiLK50wB(hjFUyls2MeE328tI1MzEBqYeWv48psILemLhKaVas4wmkGeVHHq(2KSaskgJeexHPrJN5b4Hc86zoljZscpibuo7Qy1ogfJHgqCK8Leq5SRIv7yumgA4njFqcVSjjZqsIeKakNDvSAhJIXqdGIxEJi5JKKWxQjjrcsaLZUkwTJrXyObdcuHVnjZNe(snjZqYxsMLKjiy4b3IrbxVHHq(2diossKGKZUz2IPhClgfC9ggc5BpakE5nIKpsscF2KKejiHhKWbCffdKMHVClgfC9ggc5BtYmK8LKzjHhKevw7yyb1gkWBJl21zdTRPSYijrcsy6eem8WcQnuG3gxSRZgqCKKibj8GKjiy4b21zWlaFaXrYmV49Pn8L2Zu7AkRShpFM1j8TFMt723f(gw6TqhTzk7zYu0b4CHV9ZCoiLKTjH3TnjtqbjCaFbE4iLeiK3gKm31zKypaqCHVnjWoaf8tIdtceszK4nYzkjlmjZ9VizBsmtJeiKssbhkGKIeSRZM2Cqc8ci5SBMTyAsuyy)4AF(rs1msGxajwqTHc82GeSRZibIlCCLehMKOYAhkB8mpapuGxptEqYeem8a76m4fGpG4i5lj8GKZUz2IPhyxNDvaex4BpG4i5ljionNVrbm0anW9MDrAbi5ds4JKVKWdsIkRDmqAb8242UHvGxaDODnLvgjjsqYSKmbbdpWUodEb4dios(scItZ5BuadnqdCVzxKwasMpj8IKVKWdsIkRDmqAb8242UHvGxaDODnLvgjFjzws4ak2RXHn4BGDD2DAZbjFjzws4bjAkb5CCkBO4C)aALVlG1vFussKGeEqsuzTJHfuBOaVnUyxNn0UMYkJKzijrcs0ucY54u2qX5(b0kFxaRR(OK8LKZUz2IPhko3pGw57cyD1hDau8YBejZpjj8zd5fjFjHPtqWWdlO2qbEBCXUoBaXrYmKmdjjsqYSKmbbdpWUodEb4dios(ssuzTJbslG3g32nSc8cOdTRPSYizMx8(mf)s7zQDnLv2JNpZ6e(2pZtLZ36e(23SJINz2rXTlC9zgaVtxd0lEXZmaENUgOxAVp57L2Zu7AkRShpFMmfDaox4B)mNdsjzBs4DBtskBMY2NKyjXqdsS9MgjHFs3BdsQMrIAV5CGssSKK9wjbIJKjncfqcgpSizURZGxa(ZSlC9zQ4C)aALVlG1vF0N5b4Hc86zE2nZwm9a76SRcG4cF7bqXlVrKm)KKWhVijrcso7MzlMEGDD2vbqCHV9aO4L3is(GeELIFM1j8TFMko3pGw57cyD1h9fVp51lTNP21uwzpE(mzk6aCUW3(zMg4hjXsI5V(qInWEPTjbJhwKy7fAkRKyg1jDLrcVBBejomjClc5tzDqskQjjVTHcib2nScejy8WIe8fOKydSxABsGqkIKkcfNlijwsq)6djy8WIKQ)rYHrYciH3cekibcPK4X4z2fU(m9gDaqrnL1BkbvDaHFzkw)OpZdWdf41ZCccgEGDDg8cWhqCK8LKjiy4b3IrbxVHHq(2diossKGKPfHi5ljWUHvCbkE5nIK5NKeEztssKGKjiy4b3IrbxVHHq(2dios(sYz3mBX0dSRZUkaIl8ThafV8grY)KWxQj5dsGDdR4cu8YBejjsqYeem8a76m4fGpG4i5ljNDZSftp4wmk46nmeY3Eau8YBej)tcFPMKpib2nSIlqXlVrKKibjZsYz3mBX0dUfJcUEddH8ThafV8grYhjjHpBsYxso7MzlMEGDD2vbqCHV9aO4L3is(ijj8ztsMHKVKa7gwXfO4L3is(ijj8zVAZNzDcF7NP3OdakQPSEtjOQdi8ltX6h9fVp)ZxAptTRPSYE88zYu0b4CHV9Z08xFiX0s1GK5bc5hsW4HfjZDDg8cWFMDHRpt86uta9ISunU4qi)8mpapuGxpZZUz2IPhyxNDvaex4BpakE5nIKpiHpB(mRt4B)mXRtnb0lYs14IdH8ZlEFAJV0EMAxtzL945ZSlC9zIwOCwJWBJlaA63Z887K1BuadnqVp57zEaEOaVEMtqWWdUfJcUEddH8ThqCKKibj8GeoGROyG0m8LBXOGR3WqiF7NzDcF7NjAHYzncVnUaOPFptMIoaNl8TFMM)6dj)bHM(rcgpSiX(lgfqInOHHq(2KaHkdLFsWR0vsqqaLKyjb1oNssyPKKxmkki5VzFsIcyOXlEFM6xAptTRPSYE88zYu0b4CHV9ZCoiLeEwmdLeVrotjzHjzU)fjWlGKWsjb2bOGeiKsYcizBs4DBtsbhkGKWsjb2bOGeiKoiX0AbbjhhCG8GehMeSRZirbqCHVnjNDZSfttIJiHpBIizbKGVaLKct9B8m7cxFMiVHHYxJCX8kwa6ovmd9UWxyfShp(9mpapuGxpZZUz2IPhyxNDvaex4BpakE5nIKpsscF28zwNW3(zI8ggkFnYfZRybO7uXm07cFHvWE843lEFAdFP9m1UMYk7XZNjtrhGZf(2pZ5GusYokizHjz7)qiKscRWldLKa4D6AGiz78psCys(BqTHc82GK5UoJeBRtqWWK4isQt4yv(jzbK8BHiPakj9gKevw7qzK4DSK4X4zwNW3(zEQC(wNW3(MDu8mpapuGxpZzjHhKevw7yyb1gkWBJl21zdTRPSYijrcsy6eem8WcQnuG3gxSRZgqCKmdjFjzwsMGGHhyxNbVa8behjjsqYz3mBX0dSRZUkaIl8ThafV8grYhKWNnjzMNz2rXTlC9zYWnUbW701a9I3NP4xAptTRPSYE88zwNW3(zcH0Rhko6zYu0b4CHV9Z02kCbLdsGRCEQoPtc8cibcvtzLepuC08sYCqkjBtYz3mBX0K4njlGPasM(rsa8oDnibL3y8mpapuGxpZjiy4b21zWlaFaXrsIeKmbbdp4wmk46nmeY3EaXrsIeKC2nZwm9a76SRcG4cF7bqXlVrK8bj8zZx8IN50U9lT3N89s7zQDnLv2JNpZdWdf41ZeXP58nkGHgObU3SlslajZpjj)5ZSoHV9ZSqhTzk7oLlu8I3N86L2Zu7AkRShpFMhGhkWRNzuadngy8WYB7jjFjbXP58nkGHgOrHoAZu2TxSfjFqcFK8LeeNMZ3OagAGg4EZUiTaK8bj8rY)Kevw7yG0c4TXTDdRaVa6q7AkRSNzDcF7NzHoAZu2TxS1lEXZKdONfFQIxAVp57L2Zu7AkRShpFMhGhkWRNjqXlVrKmFs(tBAZNzDcF7Nj3IrbxmlGDHxq4betFX7tE9s7zQDnLv2JNpZdWdf41ZKhKmbbdpqwfBXaVa8be3ZSoHV9ZezvSfd8cWFX7Z)8L2Zu7AkRShpFMhGhkWRNP3OQ943GPW(Xds(Ge(s9ZSoHV9ZSaNQ1BSaG2XlEFAJV0EMAxtzL945ZC5EMinEM1j8TFMylGxtz9zITYq6ZKxptSf42fU(mX9MDrAbUhOyHHFX7Zu)s7zwNW3(zITW5CGFUXcDSEMAxtzL945lEXlEMyvaY3(9jVSjV4ZM2iF)5ZetbAVnqpZuiL)d(Pn4tE75LessZsjXX5wqqc8ciH3CyiEdjanLGCGYibT4kjfuS4vOmsowvBOObz3F3BLeB48scVVnwfekJeEta8oDng10zC2nZwmnVHKyjH3C2nZwm9OMo8gsMLp79mdYoYoBao3ccLrI9KK6e(2KKDuGgKDpteNEEFYRuBpFMCGf2Z6ZmvPIetRITyiX(axrbzxQsfjZt9JeEXpj8YM8IpYoYUuLkssdJwPtYCxNrsAlaODqcglTjjkGHgKCwOoqKuaLe4fCu2GSJSlvPIe7H9wpqHYizsHxGsYzXNQGKj1WB0GKu(CuUarsV9FOvbWHHYKuNW3grY25FdYU6e(2Obhqpl(uf)N0wClgfCXSa2fEbHhqmLFhojqXlVrZ)pTPnj7Qt4BJgCa9S4tv8FsBHSk2IbEb487Wj5Xeem8azvSfd8cWhqCKD1j8TrdoGEw8Pk(pPTkWPA9glaODWVdN0Bu1E8BWuy)4Xh8LAYU6e(2Obhqpl(uf)N0wylGxtzL)UW1K4EZUiTa3duSWW8VCjrAWp2kdPj5fzxDcFB0GdONfFQI)tAlSfoNd8ZnwOJfzhzxQsfj2FdFBezxDcFBusKN1(OKD1j8Trj52W3MFho5eem8a76m4fGpG4sKyccgEWTyuW1ByiKV9aIJSRoHVn6)K2cBb8AkR83fUMKTb6cXX)YLePb)yRmKMKTXazvSfZfZcyxUY7r4N0924lBJb2cNZb(5gl0XAe(jDVni7Qt4BJ(pPTWwaVMYk)DHRjRC(Y2aDH44F5sI0GFSvgstY2yGSk2I5IzbSlx59i8t6EB8LTXaBHZ5a)CJf6ync)KU3gFzBmyk2fc4TXLlxgq6i8t6EBq2LksmJceKaH82GetTaEBqYNUHvGxaLKki5p)NKOagAGizbKyJ)tIdtYVfIKcOK4njZDDg8cWj7Qt4BJ(pPTWwaVMYk)DHRjrAb8242UHvGxa9EGIfgM)Lljsd(XwzinjItZ5BuadnqdCVzxKwGp41)tqWWdSRZGxa(aIJSlvKW77MzlMMe7VBMK5waVMYk)KmhKYijws42ntYKcVaLK6eo2k82GeSRZGxa(GeEhca0oY)ibcPmsILKZ2byZKGXsBsILK6eo2kusWUodEb4KGXdls8(S4EBqsXyObzxDcFB0)jTf2c41uw5VlCnj3U5l8cUhgI)Lljsd(Xwzin5z3mBX0dSRZUkaIl8ThqCFNLhGYzxfR2XOym0aIlrcq5SRIv7yumgAWGav4Bp)K8zZejaLZUkwTJrXyObqXlVrFKKpB(FQ)JZgvw7yyb1gkWBJl21zdTRPSYsK4Sy1U6yK(pGx9mZ8D2zbLZUkwTJrXyOH3FWlBMibItZ5BuadnqdSRZUkaIl8T)izQNjrIOYAhdlO2qbEBCXUoBODnLvwIeNfR2vhJ0)b8QNHSRoHVn6)K2c2b6uExg)oCYjiy4b21zWlaFaXr2vNW3g9FsBnPaKcs3Bd(D4KtqWWdSRZGxa(aIJSlvKmhKsYF3nScEdIe7Gyg4AhK4WKewkqjPakj8IKfqc(cusIcyObIFswajfJHiPaAZBcsqCfM2BdsGxaj4lqjjSQMKuCQrdYU6e(2O)tARSByfOlVfiMbU2b)oCseNMZ3OagAGgz3WkqxElqmdCTJpsYRejMLhGYzxfR2XOym0qT3okqjsakNDvSAhJIXqdV)ifN6zi7Qt4BJ(pPTQ(OOau57PYz(D4KtqWWdSRZGxa(aIJSRoHVn6)K26u58ToHV9n7OG)UW1KhmhYU6e(2O)tAlauFRt4BFZok4VlCnjE5nzhzxQsfjPS9)7KeljqiLemwAtcp3TjzHjjSussz0rBMYiXrKuNWXQKD1j8TrJPD7Kf6Ontz3PCHc(D4KionNVrbm0anW9MDrAbMFY)KSRoHVnAmTB)FsBvOJ2mLD7fBXVdNmkGHgdmEy5T98lItZ5BuadnqJcD0MPSBVyRp47lItZ5BuadnqdCVzxKwGp47)OYAhdKwaVnUTByf4fqhAxtzLr2r2LQurcVBBezxQizoiLe7Vyuaj2Gggc5BtcgpSizURZGxa(GK)2MzKaVasM76m4fGtYzXvejlmmjNDZSfttI3KewkjTAVds4ZMKG0Z2mejByPamosjbcPKSnjhgjqDwrisclLe7R5YyrKKgO8GeEFXNQGK5rzEuHVnjoIKOYAhkJFswajomjHLcusW45mj9gKmPKu9gwkGK5UoJe7baIl8TjjSCejWUHvmijLJqX5csILe0V(qsyPKKluqc3IrbK4nmeY3MKfMKWsjb2nScsILeSRZirbqCHVnjWlGKEBsSx8d4vJgKD1j8TrJddLKBXOGR3WqiFB(D4KCaxrXaPz4l3IrbxVHHq(2FNDccgEGDDg8cWhqCjsWd0cLN8Mnol(ufxCL5rf(2dTRPSY(E2nZwm9a76SRcG4cF7bqXlVrFKKpBMibSByfxGIxEJM)z3mBX0dSRZUkaIl8ThafV8gnZ3zHDdR4cu8YB0hjp7MzlMEGDD2vbqCHV9aO4L3O)5l1Fp7MzlMEGDD2vbqCHV9aO4L3O5N04W(J2yIeWUHvCbkE5n6JZUz2IPhClgfC9ggc5BpyqGk8TtKa2nSIlqXlVrZ)SBMTy6b21zxfaXf(2dGIxEJ(NVuNiXzXQD1Xi9FaV6ejMGGHht5DzziumG4MHSlvKmhKsIPN1(OKSnj8UTjjws4a7HetLZcI3kEdIe7d2tUWRW3Eq2LksQt4BJghg6)K2c5zTpk)rbm046WjbqTcVadDGuoliERqxoWEYfEf(2dnLGCooL9D2OagAmC0TySejIcyOXGPtqWWJtHcVngaToXmKDPIK5Gus4zXmus8g5mLKfMK5(xKaVasclLeyhGcsGqkjlGKTjH3TnjfCOasclLeyhGcsGq6GKuWdls(0nScs(RsjXAZmsGxajZ9VgKD1j8TrJdd9FsBbH0Rhko)DHRjrEddLVg5I5vSa0DQyg6DHVWkypE8JFho5eem8a76m4fGpG4sKiCC9d(S53z5XzXQD1XODdR4cx6mKDPIK5Gus(RsjH3gQamVAejBtcVBBswOa5mLKfMK5UodEb4dsMdsj5VkLeEBOcW8Qzis8MK5UodEb4K4WK8BHiXQWQKOEyPas4TblwLeBqJ1nwqf(2KSas(lxZmswys4zErOfhnijfkpibEbKW2arsSKmPKaXrYKcVaLK6eo2k82GK)Qus4THkaZRgrsSKGx2Bh3rkjHLsYeem8GSRoHVnACyO)tAl4sVgqfG5vJ43HtYJjiy4b21zWlaFaX9DwEC2nZwm9a76SBSaG2XaIlrcEevw7yGDD2nwaq7yODnLv2mFNfBb8AkRd2gOle3xeNMZ3OagAGgylCoh4NBSqhRK8LirDchREzBmWw4CoWp3yHowjrCAoFJcyObAGTW5CGFUXcDS(I40C(gfWqd0aBHZ5a)CJf6y9bFZKiXeem8a76m4fGpG4(olAHYtEZggGfRE9gRBSGk8ThAxtzLLibAHYtEZgWUMz3f(oLxeAXrdTRPSYMHSlvKmhKsY84nZOWvejyS0MKkNj5pjX2BAiskGsceh)KSas(TqKuaLeVjzURZGxa(Ge7rJGakj)nO2qbEBqYCxNrIJiPoHJvjzBsclLKOagAqIdtsuzTdLniXmwosGqEBqsfKK6)jjkGHgisW4HfjMAb82GKpDdRaVa6GSRoHVnACyO)tAlCVzgfUI4)87K1Buadnqj5JFhoP3OQ9438TxT53zNfBb8AkRJkNVSnqxiUVZYJZUz2IPhyxNDvaex4BpG4sKGhrL1ogwqTHc824IDD2q7AkRSzMjrIjiy4b21zWlaFaXnZ3z5ruzTJHfuBOaVnUyxNn0UMYklrcMobbdpSGAdf4TXf76SbexIe8yccgEGDDg8cWhqCZ8DwEevw7yG0c4TXTDdRaVa6q7AkRSejqCAoFJcyObAG7n7I0cm)updzxQizoiLK50wB(hjFUyls2MeE328tI1MzEBqYeWv48psILemLhKaVas4wmkGeVHHq(2KSaskgJeexHPrdYU6e(2OXHH(pPTGARn)72l2IFho5SZYdq5SRIv7yumgAaX9fuo7Qy1ogfJHgE)bVS5mjsakNDvSAhJIXqdGIxEJ(ijFPorcq5SRIv7yumgAWGav4BpF(s9mFNDccgEWTyuW1ByiKV9aIlrIZUz2IPhClgfC9ggc5BpakE5n6JK8zZej4bhWvumqAg(YTyuW1ByiKV9mFNLhrL1ogwqTHc824IDD2q7AkRSejy6eem8WcQnuG3gxSRZgqCjsWJjiy4b21zWlaFaXndzxQizoiLKTjH3TnjtqbjCaFbE4iLeiK3gKm31zKypaqCHVnjWoaf8tIdtceszK4nYzkjlmjZ9VizBsmtJeiKssbhkGKIeSRZM2Cqc8ci5SBMTyAsuyy)4AF(rs1msGxajwqTHc82GeSRZibIlCCLehMKOYAhkBq2vNW3gnom0)jT10U9DHVHLEl0rBMY43HtYJjiy4b21zWlaFaX9LhNDZSftpWUo7QaiUW3EaX9fXP58nkGHgObU3SlslWh89LhrL1ogiTaEBCB3WkWlGo0UMYklrIzNGGHhyxNbVa8be3xeNMZ3OagAGg4EZUiTaZNxF5ruzTJbslG3g32nSc8cOdTRPSY(olhqXEnoSbFdSRZUtBo(olp0ucY54u2qX5(b0kFxaRR(OjsWJOYAhdlO2qbEBCXUoBODnLv2mjsOPeKZXPSHIZ9dOv(Uawx9r)gaVtxJHIZ9dOv(Uawx9rhNDZSftpakE5nA(j5ZgYRVmDccgEyb1gkWBJl21zdiUzMjrIzNGGHhyxNbVa8be33OYAhdKwaVnUTByf4fqhAxtzLndzxDcFB04Wq)N0wNkNV1j8TVzhf83fUMmaENUgiYoYUuLks49cfKKcwEwjH3lu4Tbj1j8Trdsm1GKkiXYnSuajCaFbE8JKyjbzTGGKJdoqEqI3HcaqCbjNTzE4BJizBsMhVzKyQfWw)vU(r2LksMdsjXulG3gK8PByf4fqjXHj53crcgpNjXYds0EHmSijkGHgisQMrI9xmkGeBqddH8TjPAgjZDDg8cWjPakj9gKa0I9JFswajXscqHbkYIeZuyETpjBtsGzjzbKGVaLKOagAGgKD1j8TrJdMtsKwaVnUTByf4fq5hcPxmwEwVNcfEBKKp(p)oz9gfWqdus(43Htol2c41uwhiTaEBCB3WkWlGEpqXcd)LhylGxtzDWTB(cVG7HHMjrIzzBmqwfBXCXSa2LR8EauyGISQPS(fXP58nkGHgObU3SlslWh8ndzxQiX0Abbj8UdoqEqIPwaVni5t3WkWlGsYzBMh(2KeljPRkhjMPW8AFsG4iXBss51Eq2vNW3gnoyo)N0wiTaEBCB3WkWlGYpesVyS8SEpfk82ijF8F(DY6nkGHgOK8XVdNmQS2XaPfWBJB7gwbEb0H21uwzFzBmqwfBXCXSa2LR8EauyGISQPS(fXP58nkGHgObU3SlslWh8ISlvKSD(39G5qcELUIijSusQt4BtY25FKaHQPSscdc4TbjhRQBn7TbjvZiP3GKcrsrcqnGYfGK6e(2dYU6e(2OXbZ5)K2c3B2DkxOG)TZ)UhmNK8r2r2vNW3gny4g3a4D6AGscH0Rhko)DHRjzfiD8D7ltpPFVCqbqrhTpkzxDcFB0GHBCdG3PRb6)K2ccPxpuC(7cxtIG6P8USBHRH1puq2vNW3gny4g3a4D6AG(pPTGq61dfN)UW1Kg5FCw3f(wiKJ75k8Tj7Qt4BJgmCJBa8oDnq)N0wqi96HIZFx4AsgqlgSd0lwfH0mzhzxQsfjZt5njPS9)78tcYAHYmsolwfqsLZKaQ2qrKSWKefWqdejvZibD0Ua(Ii7Qt4BJg4L3)N0wNkNV1j8TVzhf83fUMCA3MFua8tKKp(D4KtqWWJPD77cFdl9wOJ2mLnG4i7Qt4BJg4L3)N0wmhXP5lEz4h(D4K8ikGHgdhD5Y1pfq2LksMdsjzURZiXEaG4cFBs2MKZUz2IPjHB3S3gKubjzTqbj2OnjXBu1E8JKjOGKEdsCys(TqKGXZzswSk4uCK4nQAp(rI3Km3)AqY8uPRKGGakjiRITyGDTz2c3B2K2mfqs1msMhVzKWZCHcsCejBtYz3mBX0KmPWlqjzU2Jbj2aJEbkjC7M92GeGIcGFcFBejomjqiVniX0Qylg4CHRKyFGJWjPAgj8uBMciXrKSqXGSRoHVnAGxENe76SRcG4cFB(D4KylGxtzDWTB(cVG7HH(oR3OQ943hjTrBMibNgdyxB2OoHJv)cGAfEbg6azvSfdCUW1lhWr4dnLGCooL9LhNDZSftpW9MDNYfkgqCF5Xz3mBX0dKvXwmxmlGDzAfwdiUz(oR3OQ9438tAptDIerL1ogiTaEBCB3WkWlGo0UMYk7l2c41uwhiTaEBCB3WkWlGEpqXcdpZxEC2nZwm9a21MnG4(olpo7MzlMEG7n7oLlumG4sKaXP58nkGHgObU3SlslWh8AgYUurY8uPRKGGakj)wis4GcsG4iXmfMx7tskBMY2NKTjjSusIcyObjomjPaOclyOmj)vPaxjXrnVjiPoHJvjbJL2Ka7gwH3gKW3F4FssuadnqdYU6e(2ObE59)jTfYQylMlMfWUCL387WjNGGHhWLEnGkaZRgnG4(YdMobbdpWaQWcgkFHlf46aI7lItZ5BuadnqdCVzxKwG5BJKD1j8Trd8Y7)tARtLZ36e(23SJc(7cxtEyiYUurYFZnSiX(aFbE8JK5XBgjMAbiPoHVnjXscqHbkYIeBVPHibJhwKG0c4TXTDdRaVakzxDcFB0aV8()K2c3B2fPfG)ZVtwVrbm0aLKp(D4KrL1ogiTaEBCB3WkWlGo0UMYk7lItZ5BuadnqdCVzxKwGpWwaVMY6a3B2fPf4EGIfg(lpyBmqwfBXCXSa2LR8Ee(jDVn(YJZUz2IPhWU2SbehzxQiX(afwbKeljqiLeBx4Df(2KKYMPS9jXHjP6FKy7nnsCej9gKaXni7Qt4BJg4L3)N0wScVRW3M)ZVtwVrbm0aLKp(D4K8aBb8AkRJkNVSnqxioYUurYCqkjMwfBXqskSagj2wRWIehMeiK3gKyAvSfdCUWvsSpWr4KunJKjTzkGemEotIAV5CGscdc4TbjHLssR27GeJdBq2vNW3gnWlV)pPTqwfBXCXSa2LPvyXVdNKtJbSRnBuNWXQFbqTcVadDGSk2Ibox46Ld4i8HMsqohNY(YPXa21MnakE5nA(jnomYUurskNXu)qKaHusW9MnLluGiXHj5uCCkJKQzKyb1gkWBdsWUoJehrcehjvZibc5TbjMwfBXaNlCLe7dCeojvZizsBMciXrKaXniHKuMX8W3UY5F8tYPqbj4EZMYfkiXHj53crcMfkZizsjbQRPSssSKyObjHLscWHdsM(rcMYdVniPiX4WgKD1j8Trd8Y7)tAlCVz3PCHc(D4KZE2nZwm9a3B2DkxOyCSkGHI(GVVZY0jiy4HfuBOaVnUyxNnG4sKGhrL1ogwqTHc824IDD2q7AkRSzsKGtJbSRnBau8YB08tEkuCdhx)34WM5lNgdyxB2OoHJv)cGAfEbg6azvSfdCUW1lhWr4dnLGCooL9LtJbSRnBau8YB0hjpfkUHJRKDPIeBqJIQJ8psqCAZiPib3Bgjt5cfKCSkGHssbhkGeSRZM2CqIdtceYBdsqwfBXaNlCLeoGJWjPAgj4EZMYfkqKuaLKtXXPSbzxDcFB0aV8()K2c3B2DkxOGFho5z3mBX0dCVz3PCHIXXQagk6d((YPXa21MnQt4y1VaOwHxGHoqwfBXaNlC9YbCe(qtjiNJtzF5Xz3mBX0dSRZUtBogqCKDPIK5GusM76ms45MdsQGel3WsbKWb8f4XpsW4Hfj)nO2qbEBqYCxNrcehjXsInssuadnq8tYcizdlfqsuzTdejBtIzAdYU6e(2ObE59)jTf21z3Pnh87Wj9gvTh)MFs7zQ)gvw7yyb1gkWBJl21zdTRPSY(gvw7yG0c4TXTDdRaVa6q7AkRSVionNVrbm0anW9MDrAbMFsByIeZoBuzTJHfuBOaVnUyxNn0UMYk7lpIkRDmqAb8242UHvGxaDODnLv2mjsG40C(gfWqd0a3B2fPfijFZq2LksS928MGeiKsITvSleWBdsSFUmGusCys(TqKCQMedniX7yjzURZGxaojEJcTy8tYciXHjXulG3gK8PByf4fqjXrKevw7qzKunJemEotILhKO9czyrsuadnqdYU6e(2ObE59)jTftXUqaVnUC5Yas53HtolqHbkYQMYAIeEJQ2JFFKIt9mFNLhylGxtzDWTB(cVG7HHsKWBu1E87JK2ZupZ3z5ruzTJbslG3g32nSc8cOdTRPSYsKy2OYAhdKwaVnUTByf4fqhAxtzL9LhylGxtzDG0c4TXTDdRaVa69aflm8mZq2LksMdsjzU8KKTjH3Tnjomj)wisyBZBcsAvzKeljNcfKyBf7cb82Ge7NldiLFsQMrsyPaLKcOKKveIKWQAsSrsIcyObIKfkiz2utcgpSi5SndYJzgKD1j8Trd8Y7)tAlSRZUtBo43HtI40C(gfWqd0a3B2fPfy(ZAJ)F2Mb5XG5i02vhx9yTkAODnLv2mF9gvTh)MFs7zQ)gvw7yG0c4TXTDdRaVa6q7AkRSej4ruzTJbslG3g32nSc8cOdTRPSYi7sfjZbPKyAvSfdjPWcyZlj2wRWIehMKWsjjkGHgK4isQPfkijwsyUsYci53crIvHvjX0Qylg4CHRKyFGJWjrtjiNJtzKGXdlsMhVztAZuajlGetRITyGDTzKuNWXQdYU6e(2ObE59)jTfYQylMlMfWUmTcl(p)oz9gfWqdus(43HtoBuadngwALdRb3jMpVS5xeNMZ3OagAGg4EZUiTaZ3gNjrIz50ya7AZg1jCS6xauRWlWqhiRITyGZfUE5aocFOPeKZXPSzi7sfjZbPKycbaAZuajXsY8uSwris2MKIKOagAqsyvbjoIeJ1BdsILeMRKubjHLscWnScschxhKD1j8Trd8Y7)tAleeaOntb3yV4fRveI)ZVtwVrbm0aLKp(D4Krbm0yeoUEJ9YCD(8k1FNGGHhyxNbVa8bBX0KDPIK5GusM76mssBbaTds2o)JehMeZuyETpjvZizUPrsbusQt4yvsQMrsyPKefWqdsWSnVjiH5kjmiG3gKewkjhRQBnpi7Qt4BJg4L3)N0wyxNDJfa0o4)87K1Buadnqj5JFhoj2c41uwhSnqxiUVrbm0yeoUEJ9YC9J)87StqWWdSRZGxa(GTy6ejMGGHhyxNbVa8bqXlVrZ)SBMTy6b21z3PnhdGIxEJM5BDchREzBmWw4CoWp3yHowjrCAoFJcyObAGTW5CGFUXcDS(I40C(gfWqd0a3B2fPfy(ZM6)N1g(hJkRDmcmokUl8fUcDODnLv2mZq2vNW3gnWlV)pPTW9MnPntb87WjzBmWw4CoWp3yHowJWpP7TX3zJkRDmqAb8242UHvGxaDODnLv2xeNMZ3OagAGg4EZUiTaFGTaEnL1bU3SlslW9aflmCIeSngiRITyUywa7YvEpc)KU3gZ8DwEaGAfEbg6azvSfdCUW1lhWr4dnLGCooLLirDchREzBmWw4CoWp3yHowjrCAoFJcyObAGTW5CGFUXcDSMHSlvKmhKsIzkmV2MemEyrI9lVNaALUciX(OkJtcuNveIKWsjjkGHgKGXZzsMusM08IHeEztERjzsHxGssyPKC2nZwmnjNfxrKmvN0j7Qt4BJg4L3)N0wiRITyUywa7Y0kS43HtcGAfEbg6GR8EcOv6k4YHQm(qtjiNJtzFXwaVMY6GTb6cX9nkGHgJWX1BSxUtC5Ln)y2ZUz2IPhiRITyUywa7Y0kSgmiqf(2)BCyZq2LksMdsjX0Qylgs4DqHSizBs4DBtcuNveIKWsbkjfqjPymejEFwCVngKD1j8Trd8Y7)tAlKvXwm3dOqw87WjbLZUkwTJrXyOH3FWNnj7sfjZbPKmpEZiXulajXsYzBeeUsITlq6KKM1czyfis4a7brY2KKYPi7XGK0sr2ofrcVVnSdWjXrKewoIehrsrILByPas4a(c84hjHv1Kau2gH3gKSnjPCkYEqcuNveIewbsNKWAHmScejoIKAAHcsILKWXvswOGSRoHVnAGxE)FsBH7n7I0cW)53jR3OagAGsYh)oCseNMZ3OagAGg4EZUiTaFGTaEnL1bU3SlslW9aflm83jiy4bRaPFdRfYWkgqC8FSkVtYh)EhkaaXfxhhxzEfAs(437qbaiU46Wjd)Ko6JK8ISlvKmhKsY84nJK)kx)ijwsoBJGWvsSDbsNK0SwidRarchypis2MeZ0gKKwkY2Pis49THDaojomjHLJiXrKuKy5gwkGeoGVap(rsyvnjaLTr4TbjqDwrisyfiDscRfYWkqK4isQPfkijwschxjzHcYU6e(2ObE59)jTfU3SlCU(XVdNCccgEWkq63WAHmSIbe3xSfWRPSoyBGUqC8FSkVtYh)EhkaaXfxhhxzEfAs(437qbaiU46Wjd)Ko6JK867z3mBX0dSRZUtBogqCKDPIK5GusMhVzKWZCHcsCys(TqKW2M3eK0QYijwsakmqrwKy7nn0GeZy5i5uOWBdsQGeBKKfqc(cusIcyObIemEyrIPwaVni5t3WkWlGssuzTdLrs1ms(TqKuaLKEdsGqEBqIPvXwmW5cxjX(ahHtYciX(OFhl)qYF370hionNVrbm0anW9MDrAb(4pqQjXqdejHLscU3ooeojlmjPMKQzKewkjne(KcizHjjkGHgObjPCgT8tcBjP3GeoGIqKG7nBkxOGeOo8mjvotsuadnqKuaLe2gHYibJhwKm30ibJL2KaH82GeKvXwmW5cxjHd4iCsCysM0MPasCejf2YZ1uwhKD1j8Trd8Y7)tAlCVz3PCHc(D4KylGxtzDW2aDH4(ckNDvSAhd8fRIRDm8(JtHIB446)2CK6VionNVrbm0anW9MDrAbM)S24)86pgvw7yG7if8BODnLv2)1jCS6LTXaBHZ5a)CJf6y9hJkRDm4q)ow(5M9o9H21uwz)plItZ5BuadnqdCVzxKwGp(dK6z(JZYPXa21MnQt4y1VaOwHxGHoqwfBXaNlC9YbCe(qtjiNJtzZmZ3z5baQv4fyOdKvXwmW5cxVCahHp0ucY54uwIe84SBMTy6bSRnBaX9fa1k8cm0bYQylg4CHRxoGJWhAkb5CCklrI6eow9Y2yGTW5CGFUXcDSsI40C(gfWqd0aBHZ5a)CJf6yndzxDcFB0aV8()K2cBHZ5a)CJf6yX)53jR3OagAGsYh)oCsGcduKvnL1Vrbm0yeoUEJ9YC9dByIeZgvw7yG7if8BODnLv2x2gdKvXwmxmlGD5kVhafgOiRAkRZKiXeem8aQHHazVnUScKERi0aIJSlvKyYPhVYKC2M5HVnjXsckwosofk82GeZuyETpjBtYcd)hgfWqdejyS0Mey3Wk82GK)KKfqc(cusqrDsxzKGVtisQMrceYBdsSp63XYpK839oDsQMrYNPO0izECKc(ni7Qt4BJg4L3)N0wiRITyUywa7YvEZVdNeOWafzvtz9BuadngHJR3yVmx)Wg)YJOYAhdChPGFdTRPSY(gvw7yWH(DS8Zn7D6dTRPSY(I40C(gfWqd0a3B2fPf4dEr2LksSxOkhjMPW8AFsG4izBskej4v)JKOagAGiPqKWTiKpLv(jrT3hLlibJL2Ka7gwH3gK8NKSasWxGsckQt6kJe8DcrcgpSiX(OFhl)qYF370hKD1j8Trd8Y7)tAlKvXwmxmlGD5kV5)87K1Buadnqj5JFhojqHbkYQMY63OagAmchxVXEzU(Hn(LhrL1og4osb)gAxtzL9LhZgvw7yG0c4TXTDdRaVa6q7AkRSVionNVrbm0anW9MDrAb(aBb8AkRdCVzxKwG7bkwy4z(olpIkRDm4q)ow(5M9o9H21uwzjsmBuzTJbh63XYp3S3Pp0UMYk7lItZ5BuadnqdCVzxKwG5NKxZmdzxDcFB0aV8()K2c3B2fPfG)ZVtwVrbm0aLKp(D4KionNVrbm0anW9MDrAb(aBb8AkRdCVzxKwG7bkwyy(pwL3j5JFVdfaG4IRJJRmVcnjF87DOaaexCD4KHFsh9rsEr2vNW3gnWlV)pPTW9MDHZ1p(pwL3j5JFVdfaG4IRJJRmVcnjF87DOaaexCD4KHFsh9rsE99SBMTy6b21z3PnhdioYUurYCqkjMPW8ABskej5cfKau0ccsCys2MKWsjbFXQKD1j8Trd8Y7)tAlKvXwmxmlGDzAfwKDPIK5GusmtH51(KuisYfkibOOfeK4WKSnjHLsc(IvjPAgjMPW8ABsCejBtcVBBYU6e(2ObE59)jTfYQylMlMfWUCL3KDKDPIK5Gus2MeE32KKYMPS9jjwsm0GeBVPrs4N092GKQzKO2BohOKeljzVvsG4izsJqbKGXdlsM76m4fGt2vNW3gncG3PRbkjesVEO483fUMuX5(b0kFxaRR(O87Wjp7MzlMEGDD2vbqCHV9aO4L3O5NKpELiXz3mBX0dSRZUkaIl8ThafV8g9bVsXKDPIK0a)ijwsm)1hsSb2lTnjy8WIeBVqtzLeZOoPRms4DBJiXHjHBriFkRdssrnj5TnuajWUHvGibJhwKGVaLeBG9sBtcesrKurO4CbjXsc6xFibJhwKu9psomswaj8wGqbjqiLepgKD1j8TrJa4D6AG(pPTGq61dfN)UW1KEJoaOOMY6nLGQoGWVmfRFu(D4KtqWWdSRZGxa(aI77eem8GBXOGR3WqiF7bexIetlc9f2nSIlqXlVrZpjVSzIetqWWdUfJcUEddH8ThqCFp7MzlMEGDD2vbqCHV9aO4L3O)5l1Fa7gwXfO4L3OejMGGHhyxNbVa8be33ZUz2IPhClgfC9ggc5BpakE5n6F(s9hWUHvCbkE5nkrIzp7MzlMEWTyuW1ByiKV9aO4L3OpsYNn)E2nZwm9a76SRcG4cF7bqXlVrFKKpBoZxy3WkUafV8g9rs(SxTjzxQiX8xFiX0s1GK5bc5hsW4HfjZDDg8cWj7Qt4BJgbW701a9FsBbH0Rhko)DHRjXRtnb0lYs14IdH8d)oCYZUz2IPhyxNDvaex4BpakE5n6d(SjzxQiX8xFi5pi00psW4Hfj2FXOasSbnmeY3MeiuzO8tcELUscccOKeljO25usclLK8Irrbj)n7tsuadni7Qt4BJgbW701a9FsBbH0Rhko)DHRjrluoRr4TXfan9JFho5eem8GBXOGR3WqiF7bexIe8Gd4kkgindF5wmk46nmeY3M)ZVtwVrbm0aLKpYUurYCqkj8SygkjEJCMsYctYC)lsGxajHLscSdqbjqiLKfqY2KW72MKcouajHLscSdqbjqiDqIP1ccsoo4a5bjomjyxNrIcG4cFBso7MzlMMehrcF2erYcibFbkjfM63GSRoHVnAeaVtxd0)jTfesVEO483fUMe5nmu(AKlMxXcq3PIzO3f(cRG94Xp(D4KNDZSftpWUo7QaiUW3Eau8YB0hj5ZMKDPIK5GusYokizHjz7)qiKscRWldLKa4D6AGiz78psCys(BqTHc82GK5UoJeBRtqWWK4isQt4yv(jzbK8BHiPakj9gKevw7qzK4DSK4XGSRoHVnAeaVtxd0)jT1PY5BDcF7B2rb)DHRjz4g3a4D6AG43HtolpIkRDmSGAdf4TXf76SH21uwzjsW0jiy4HfuBOaVnUyxNnG4M57StqWWdSRZGxa(aIlrIZUz2IPhyxNDvaex4BpakE5n6d(S5mKDPIeBRWfuoibUY5P6KojWlGeiunLvs8qXrZljZbPKSnjNDZSfttI3KSaMciz6hjbW701GeuEJbzxDcFB0iaENUgO)tAliKE9qXr87WjNGGHhyxNbVa8bexIetqWWdUfJcUEddH8ThqCjsC2nZwm9a76SRcG4cF7bqXlVrFWNnFXlEp]] )


end
