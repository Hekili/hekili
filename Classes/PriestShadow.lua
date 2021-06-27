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


    spec:RegisterPack( "Shadow", 20210627, [[deL9kcqiucpsKIlrPaQnPk6tOKIrjs1PuuSkvPuELQunluQULQuq7sHFrPOHjc5yOuwgkjptvqMMiixtKsBJsb9nusPXrPqDorqvRtvqnpvbUNiAFkQ6FIGkoOirwikrpeLunrrGlkckBuvk5JukqJuvk0jPuiRKsPxQkfWmvLs1nvLI2PQq)ueknurchveuPLQkfONsrtvrPRQOITQOsFveQ2RQ6VQ0GjoSKfRipwftgvxM0Mb1NPWOPKtt1QPuaETiPzlQBdv7wQFR0WrXXfjQLd8Citx46GSDO03HIXlcfNxvY6Puaz(uQ2pYF2(Z(n5vO)hzvIyfBjYgYkw7GnwlB24hkH)BgVy0VjtDsTm0Vzx46300Q4lMVjt9kVf)p73eTqGJ(nTIGb9W20MgEybnnolUnroouUcF7dOGdBIC8Jn)MtqEoSr9F6BYRq)pYQeXk2sKnKvS2bBSw2SXpKn(BwqH1c(MMooR)nTCox7)03KROZ300Q4lgssbWvuq2AluRKWkwl7KWQeXk2iBjBNfJwPsYCxNtYSlaODqcglTjjkGHgKCwOoqKuaLe4fCu(4BMDuG(Z(n5kCbLJ)S)hz7p73SoHV93e5zTp63u7AkR8pl)X)rw9N9BQDnLv(NLFZdWdf413CccgEGDDo8cWhqmKy3ojtqWWdMfJcUEddH8ThqmFZ6e(2FtMn8T)X)Xh6p73u7AkR8pl)MlZ3ePX3SoHV93eBb8AkRFtSvgs)M8ngiRIVyUywa)YuEpc)KQ3gK8Ke(gdSfoJd8ZnwOJ1i8tQEB8nXwGBx463KVb6cX8J)Jj0F2VP21uw5Fw(nxMVjsJVzDcF7Vj2c41uw)MyRmK(n5BmqwfFXCXSa(LP8Ee(jvVni5jj8ngylCgh4NBSqhRr4Nu92GKNKW3yWvSleWBJltUmG0r4Nu924BITa3UW1VzLZx(gOleZp(pM2)SFtTRPSY)S8BUmFtKgFZ6e(2FtSfWRPS(nXwzi9BIy0C(gfWqd0a3B(fPfGK5jHvK8ojtqWWdSRZHxa(aI5BYv0b4mHV930mkqqceYBdsm1c4Tbjp6gwbEbusQGKh6DsIcyObIKfqsc9ojomjVwiskGsI3Km315Wla)BITa3UW1VjslG3g32nSc8cO3duSWW)4)On8p73u7AkR8pl)MlZ3ePX3SoHV93eBb8AkRFtSvgs)MNDZ8ftpWUo)QaiMW3EaXqYtssNewqcOC(vXQDmkohnGyiXUDsaLZVkwTJrX5ObhcuHVnjpijjSLisSBNeq58RIv7yuCoAau8YBejZNKe2sejVtsAj5Trs6Kevw7yyb1gkWBJl215dTRPSYjXUDsolwTRogP(c4vtYmKmdjpjjDssNeq58RIv7yuCoA4njZtcRsej2TtcIrZ5BuadnqdSRZVkaIj8Tjz(KKKwsMHe72jjQS2XWcQnuG3gxSRZhAxtzLtID7KCwSAxDms9fWRMKz(MCfDaot4B)nz9DZ8fttsk2ntYClGxtzLDsMds5Keljm7MjzsHxGssDchBfEBqc215WlaFqcRdbaAh5xKaHuojXsYz7aSzsWyPnjXssDchBfkjyxNdVaCsW4HfjEFwCVniP4C04BITa3UW1VjZU5l8cUho6h)hzT)z)MAxtzL)z538a8qbE9nNGGHhyxNdVa8beZ3SoHV93e2b6uEx(p(pAJ)Z(n1UMYk)ZYV5b4Hc86BobbdpWUohEb4diMVzDcF7V5KcqkivVn(X)Xe()SFtTRPSY)S8BwNW3(BMDdRaDTbaXnW1o(MCfDaot4B)nNdsj5T7gwbRbrITqCdCTdsCysclfOKuaLewrYcibFbkjrbm0aXojlGKIZrKuaTznbjiMct7TbjWlGe8fOKewvtcRnTOX38a8qbE9nrmAoFJcyObAKDdRaDTbaXnW1oiz(KKWksSBNK0jHfKakNFvSAhJIZrdnX4OarID7KakNFvSAhJIZrdVjzEsyTPLKz(X)r2s0F2VP21uw5Fw(npapuGxFZjiy4b215WlaFaX8nRt4B)nR(OOau57PY5F8FKn2(Z(n1UMYk)ZYVzDcF7V5PY5BDcF7B2rX3m7O42fU(npyo)4)iBS6p73u7AkR8pl)M1j8T)MaO(wNW3(MDu8nZokUDHRFt8Y7F8JVjh34gaVtvd0F2)JS9N9BQDnLv(NLFZUW1VjVaPIVBF56j17Lbkak6O9r)M1j8T)M8cKk(U9LRNuVxgOaOOJ2h9h)hz1F2VP21uw5Fw(n7cx)MiOEkVl)w4Ay9cfFZ6e(2FteupL3LFlCnSEHIF8F8H(Z(n1UMYk)ZYVzx4630i)IX6UW3cHCCpxHV93SoHV930i)IX6UW3cHCCpxHV9p(pMq)z)MAxtzL)z53SlC9BYbAXHDGEXQiKM)M1j8T)MCGwCyhOxSkcP5F8JVjE59F2)JS9N9BQDnLv(NLFZdWdf413CccgEmTBFx4ByP3cD0MR8beZ3SoHV938u58ToHV9n7O4BMDuC7cx)Mt72)4)iR(Z(n1UMYk)ZYV5b4Hc86BYcsIcyOXWrxMC9sbFZ6e(2FtUJy08fVm8Zp(p(q)z)MAxtzL)z53SoHV93e768RcGycF7VjxrhGZe(2FZ5GusM76CssyaiMW3MKTj5SBMVyAsy2n7TbjvqswluqscLis8gvThVizckiP3GehMKxlejy8CMKfRcofdjEJQ2JxK4njZ9TgK8MvQkjiiGscYQ4lgyxBUnX9MpPnxbKunNK30BojSmxOGehrY2KC2nZxmnjtk8cusMBcBqInYOxGscZUzVnibOOa4NW3grIdtceYBdsmTk(Ibox4kjPa4iCsQMtcl1MRasCejlum(MhGhkWRVj2c41uwhm7MVWl4E4isEss6K4nQApErY8jjjHsej2TtcJgdyxB(OoHJvj5jjaOwHxGHoqwfFXaNlC9YaCe(qtziNHr5K8KewqYz3mFX0dCV53PCHIbedjpjHfKC2nZxm9azv8fZfZc4xUwH1aIHKzi5jjPtI3OQ94fjpijj240sID7Kevw7yG0c4TXTDdRaVa6q7AkRCsEsc2c41uwhiTaEBCB3WkWlGEpqXcdtYmK8KewqYz3mFX0dyxB(aIHKNKKojSGKZUz(IPh4EZVt5cfdigsSBNeeJMZ3OagAGg4EZViTaKmpjSIKz(X)Xe6p73u7AkR8pl)M1j8T)MiRIVyUywa)YuE)n5k6aCMW3(B(MvQkjiiGsYRfIegOGeigsmt8hofKKsMPukizBsclLKOagAqIdtsIdQWcgktYBvkWvsCuZAcsQt4yvsWyPnjWUHv4TbjS9g(qKefWqd04BEaEOaV(MtqWWd4sVgqfG7vJgqmK8KewqcxNGGHhyavybdLVWLcCDaXqYtsqmAoFJcyObAG7n)I0cqYdijH(X)X0(N9BQDnLv(NLFZ6e(2FZtLZ36e(23SJIVz2rXTlC9BE4OF8F0g(N9BQDnLv(NLFZ6e(2FtCV5xKwGV551jR3OagAG(pY238a8qbE9nJkRDmqAb8242UHvGxaDODnLvojpjbXO58nkGHgObU38lslajZtc2c41uwh4EZViTa3duSWWK8KewqcFJbYQ4lMlMfWVmL3JWpP6TbjpjHfKC2nZxm9a21MpGy(MCfDaot4B)nFJUHfjPa4lWJxK8MEZjXulaj1j8TjjwsakmqrwKKGDwejy8WIeKwaVnUTByf4fq)X)rw7F2VP21uw5Fw(nRt4B)n5fExHV93886K1Buadnq)hz7BEaEOaV(MSGeSfWRPSoQC(Y3aDHy(MCfDaot4B)ntbqHvajXscesjjbfExHVnjPKzkLcsCysQ(fjjyNLehrsVbjqmJF8F0g)N9BQDnLv(NLFZ6e(2FtKvXxmxmlGF5AfwFtUIoaNj8T)MZbPKyAv8fdjj(c4KKaTclsCysGqEBqIPvXxmW5cxjjfahHts1CsM0MRasW45mjAIHXbkjCiG3gKewkjTMycsmo8X38a8qbE9nz0ya7AZh1jCSkjpjba1k8cm0bYQ4lg4CHRxgGJWhAkd5mmkNKNKWOXa21MpakE5nIKhKKeJd)h)ht4)Z(n1UMYk)ZYVzDcF7VjU387uUqX3KROdWzcF7VzkLXuVqKaHusW9MpLluGiXHj5ummkNKQ5Kyb1gkWBdsWUoNehrcedjvZjbc5TbjMwfFXaNlCLKuaCeojvZjzsBUciXrKaXmiHKuIZ9W3UY5xStYPqbj4EZNYfkiXHj51crcMfkZjzsjbQRPSssSKyObjHLscWHdsMErcMYdVniPiX4WhFZdWdf413mDso7M5lMEG7n)oLlumowfWqrKmpjSrYtssNeUobbdpSGAdf4TXf768bedj2TtclijQS2XWcQnuG3gxSRZhAxtzLtYmKy3ojmAmGDT5dGIxEJi5bjj5uO4goUsY7KyC4KmdjpjHrJbSRnFuNWXQK8KeauRWlWqhiRIVyGZfUEzaocFOPmKZWOCsEscJgdyxB(aO4L3isMNKtHIB446p(pYwI(Z(n1UMYk)ZYVzDcF7Vj2153PnhFtUIoaNj8T)MZbPKm315KWYnhKubjwUHLciHb4lWJxKGXdlsEJqTHc82GK5UoNeigsILKeIKOagAGyNKfqYgwkGKOYAhis2MeZzhFZdWdf4130Bu1E8IKhKKeBCAj5jjrL1ogwqTHc824IDD(q7AkRCsEssuzTJbslG3g32nSc8cOdTRPSYj5jjignNVrbm0anW9MFrAbi5bjjXgsID7KKojPtsuzTJHfuBOaVnUyxNp0UMYkNKNKWcsIkRDmqAb8242UHvGxaDODnLvojZqID7KGy0C(gfWqd0a3B(fPfGKKKWgjZ8J)JSX2F2VP21uw5Fw(nRt4B)n5k2fc4TXLjxgq63KROdWzcF7Vzc2M1eKaHussGIDHaEBqskYLbKsIdtYRfIKt1KyObjEhljZDDo8cWjXBuOfNDswajomjMAb82GKhDdRaVakjoIKOYAhkNKQ5KGXZzsS8GeTxidlsIcyObA8npapuGxFZ0jbOWafzvtzLe72jXBu1E8IK5jH1MwsMHKNKKojSGeSfWRPSoy2nFHxW9WrKy3ojEJQ2JxKmFssSXPLKzi5jjPtclijQS2XaPfWBJB7gwbEb0H21uw5Ky3ojPtsuzTJbslG3g32nSc8cOdTRPSYj5jjSGeSfWRPSoqAb8242UHvGxa9EGIfgMKzizMF8FKnw9N9BQDnLv(NLFZ6e(2FtSRZVtBo(MCfDaot4B)nNdsjzUSKKTjH1tajomjVwis4BZAcsAv5KeljNcfKKaf7cb82GKuKldiLDsQMtsyPaLKcOKKveIKWQAssisIcyObIKfkij90scgpSi5SnhYJzgFZdWdf413eXO58nkGHgObU38lslajpGK0jjHi5DsoBZH8yWDeA7QJRESwfn0UMYkNKzi5jjEJQ2JxK8GKKyJtljpjjQS2XaPfWBJB7gwbEb0H21uw5Ky3ojSGKOYAhdKwaVnUTByf4fqhAxtzL)J)JS9q)z)MAxtzL)z53SoHV93ezv8fZfZc4xUwH13886K1Buadnq)hz7BEaEOaV(MPtsuadngwALdRbZji5bKWQerYtsqmAoFJcyObAG7n)I0cqYdijHizgsSBNK0jHrJbSRnFuNWXQK8KeauRWlWqhiRIVyGZfUEzaocFOPmKZWOCsM5BYv0b4mHV93CoiLetRIVyijXxa)HjjbAfwK4WKewkjrbm0GehrsnTqbjXsc3vswajVwisSkSkjMwfFXaNlCLKuaCeojAkd5mmkNemEyrYB6nFsBUcizbKyAv8fdSRnNK6eowD8J)JSLq)z)MAxtzL)z53SoHV93ebbaAZvWn2lEXBfH(MNxNSEJcyOb6)iBFZdWdf413mkGHgJWX1BSxURK8asyvAj5jjtqWWdSRZHxa(GVy6VjxrhGZe(2FZ5GusmHaaT5kGKyj5nlERiejBtsrsuadnijSQGehrIX6TbjXsc3vsQGKWsjb4gwbjHJRJF8FKT0(N9BQDnLv(NLFZ6e(2FtSRZVXcaAhFZZRtwVrbm0a9FKTV5b4Hc86BITaEnL1bFd0fIHKNKefWqJr446n2l3vsMNKhIKNKKojtqWWdSRZHxa(GVyAsSBNKjiy4b215WlaFau8YBejpGKZUz(IPhyxNFN2CmakE5nIKzi5jj1jCS6LVXaBHZ4a)CJf6yrsssqmAoFJcyObAGTWzCGFUXcDSi5jjignNVrbm0anW9MFrAbi5bKKojPLK3jjDsSHK82ijQS2XiW4O4UWx4k0H21uw5KmdjZ8n5k6aCMW3(BohKsYCxNtYSlaODqY25xK4WKyM4pCkiPAojZDwskGssDchRss1CsclLKOagAqcMTznbjCxjHdb82GKWsj5yvDR5Xp(pYMn8p73u7AkR8pl)MhGhkWRVjFJb2cNXb(5gl0XAe(jvVni5jjPtsuzTJbslG3g32nSc8cOdTRPSYj5jjignNVrbm0anW9MFrAbizEsWwaVMY6a3B(fPf4EGIfgMe72jHVXazv8fZfZc4xMY7r4Nu92GKzi5jjPtcliba1k8cm0bYQ4lg4CHRxgGJWhAkd5mmkNe72jPoHJvV8ngylCgh4NBSqhlssscIrZ5BuadnqdSfoJd8ZnwOJfjZ8nRt4B)nX9MpPnxb)4)iBS2)SFtTRPSY)S8BwNW3(BISk(I5Izb8lxRW6BYv0b4mHV93CoiLeZe)Htajy8WIKuuEpb0kvfqskqvgNeOoRiejHLssuadnibJNZKmPKmP5fdjSkr2atYKcVaLKWsj5SBMVyAsolUIizQoPo(MhGhkWRVjaQv4fyOdMY7jGwPQGldQY4dnLHCggLtYtsWwaVMY6GVb6cXqYtsIcyOXiCC9g7L5exwLisMNK0j5SBMVy6bYQ4lMlMfWVCTcRbhcuHVnjVtIXHtYm)4)iB24)SFtTRPSY)S8BwNW3(BISk(I5EafY6BYv0b4mHV93CoiLetRIVyiH1bfYIKTjH1tajqDwrisclfOKuaLKIZrK49zX92y8npapuGxFtq58RIv7yuCoA4njZtcBj6h)hzlH)p73u7AkR8pl)MhGhkWRVjIrZ5BuadnqdCV5xKwasMNeSfWRPSoW9MFrAbUhOyHHj5jjtqWWdEbs9gwlKHvmGy(MCfDaot4B)nNdsj5n9MtIPwasILKZ2iiCLKeuGujzwRfYWkqKWa2dIKTjjLsSjSbjZMytqILewFByhGtIJijSCejoIKIel3WsbKWa8f4XlscRQjbO8ncVnizBssPeBcJeOoRiej8cKkjH1czyfisCej10cfKeljHJRKSqX3886K1Buadnq)hz7B6DOaaetCD4Vz4NurZNKvFtVdfaGyIRJJRCVc9BY238yvE)nz7BwNW3(BI7n)I0c8J)JSkr)z)MAxtzL)z53KROdWzcF7V5CqkjVP3CsERC9IKyj5SnccxjjbfivsM1AHmScejmG9GizBsmNDqYSj2eKyjH13g2b4K4WKewoIehrsrILByPasya(c84fjHv1Kau(gH3gKa1zfHiHxGujjSwidRarIJiPMwOGKyjjCCLKfk(MhGhkWRV5eem8GxGuVH1czyfdigsEsc2c41uwh8nqxiMVP3HcaqmX1H)MHFsfnFsw98SBMVy6b2153PnhdiMVP3HcaqmX1XXvUxH(nz7BESkV)MS9nRt4B)nX9MFHZ1RF8FKvS9N9BQDnLv(NLFZ6e(2FtCV53PCHIVjxrhGZe(2FZ5GusEtV5KWYCHcsCysETqKW3M1eK0QYjjwsakmqrwKKGDw0GeZyzi5uOWBdsQGKeIKfqc(cusIcyObIemEyrIPwaVni5r3WkWlGssuzTdLts1CsETqKuaLKEdsGqEBqIPvXxmW5cxjjfahHtYcijfOxhl)qYB37uhignNVrbm0anW9MFrAbMpHtAjXqdejHLscU3ooeojlmjPLKQ5Kewkjne(KcizHjjkGHgObjPugTStcFjP3GegGIqKG7nFkxOGeOo8mjvotsuadnqKuaLe(gHYjbJhwKm3zjbJL2KaH82GeKvXxmW5cxjHb4iCsCysM0MRasCejf2YZ1uwhFZdWdf413eBb8AkRd(gOledjpjbuo)Qy1og4lwfx7y4njZtYPqXnCCLK3jjrJ0sYtsqmAoFJcyObAG7n)I0cqYdijDssisENewrYBJKOYAhdChPGxdTRPSYj5DsQt4y1lFJb2cNXb(5gl0XIK3gjrL1ogmOxhl)CZEN6q7AkRCsENK0jbXO58nkGHgObU38lslajZNWHK0sYmK82ijDsy0ya7AZh1jCSkjpjba1k8cm0bYQ4lg4CHRxgGJWhAkd5mmkNKzizgsEss6KWcsaqTcVadDGSk(Ibox46Lb4i8HMYqodJYjXUDsybjNDZ8ftpGDT5digsEscaQv4fyOdKvXxmW5cxVmahHp0ugYzyuoj2TtsDchRE5BmWw4moWp3yHowKKKeeJMZ3OagAGgylCgh4NBSqhlsM5h)hzfR(Z(n1UMYk)ZYVzDcF7Vj2cNXb(5gl0X6BEaEOaV(MafgOiRAkRK8KKOagAmchxVXE5UsY8KydjXUDssNKOYAhdChPGxdTRPSYj5jj8ngiRIVyUywa)YuEpakmqrw1uwjzgsSBNKjiy4buddbYEBC5fi1wrObeZ3886K1Buadnq)hz7h)hz1d9N9BQDnLv(NLFZ6e(2FtKvXxmxmlGFzkV)MCfDaot4B)nnz0JxzsoBZ9W3MKyjbfldjNcfEBqIzI)WPGKTjzHHFdJcyObIemwAtcSByfEBqYdrYcibFbkjOOoPQCsW3jejvZjbc5TbjPa96y5hsE7ENkjvZj5Xe7SK8MosbVgFZdWdf413eOWafzvtzLKNKefWqJr446n2l3vsMNKeIKNKWcsIkRDmWDKcEn0UMYkNKNKevw7yWGEDS8Zn7DQdTRPSYj5jjignNVrbm0anW9MFrAbizEsy1p(pYQe6p73u7AkR8pl)M1j8T)MiRIVyUywa)YuE)npVoz9gfWqd0)r2(MhGhkWRVjqHbkYQMYkjpjjkGHgJWX1BSxURKmpjjejpjHfKevw7yG7if8AODnLvojpjHfKKojrL1ogiTaEBCB3WkWlGo0UMYkNKNKGy0C(gfWqd0a3B(fPfGK5jbBb8AkRdCV5xKwG7bkwyysMHKNKKojSGKOYAhdg0RJLFUzVtDODnLvoj2Tts6Kevw7yWGEDS8Zn7DQdTRPSYj5jjignNVrbm0anW9MFrAbi5bjjHvKmdjZ8n5k6aCMW3(B(gqvgsmt8hofKaXqY2KuisWR(fjrbm0arsHiHzriFkRStIMyoktqcglTjb2nScVni5HizbKGVaLeuuNuvoj47eIemEyrskqVow(HK3U3Po(X)rwL2)SFtTRPSY)S8BwNW3(BI7n)I0c8npVoz9gfWqd0)r2(MEhkaaXexh(Bg(jv08jz1307qbaiM4644k3Rq)MS9npapuGxFteJMZ3OagAGg4EZViTaKmpjylGxtzDG7n)I0cCpqXcd)npwL3Ft2(X)rwzd)Z(n1UMYk)ZYVzDcF7VjU38lCUE9n9ouaaIjUo83m8tQO5tYQNNDZ8ftpWUo)oT5yaX8n9ouaaIjUooUY9k0VjBFZJv593KTF8FKvS2)SFtTRPSY)S8BYv0b4mHV93CoiLeZe)HtajfIKCHcsakAbbjomjBtsyPKGVy1VzDcF7VjYQ4lMlMfWVCTcRF8FKv24)SFtTRPSY)S8BYv0b4mHV93CoiLeZe)HtbjfIKCHcsakAbbjomjBtsyPKGVyvsQMtIzI)WjGehrY2KW6j4BwNW3(BISk(I5Izb8lt59p(X3KbONfFQI)S)hz7p73u7AkR8pl)MhGhkWRVjqXlVrK8asEOeLOVzDcF7VjZIrbxmlGFHxq4bex)X)rw9N9BQDnLv(NLFZdWdf413KfKmbbdpqwfFXaVa8beZ3SoHV93ezv8fd8cW)X)Xh6p73u7AkR8pl)MhGhkWRVP3OQ941GRW(XdsMNe2s73SoHV93SaNQ1BSaG2Xp(pMq)z)MAxtzL)z53Cz(Min(M1j8T)MylGxtz9BITYq63KvFtSf42fU(nX9MFrAbUhOyHH)X)X0(N9BwNW3(BITWzCGFUXcDS(MAxtzL)z5p(X38Wr)z)pY2F2VP21uw5Fw(nRt4B)nzwmk46nmeY3(BYv0b4mHV93CoiLKuSyuaj2Oggc5BtcgpSizURZHxa(GK34M5KaVasM76C4fGtYzXvejlmmjNDZ8fttI3KewkjTMycsylrKG0Z2CejByPamosjbcPKSnjhojqDwrisclLeMC9sbK4isykqqYctsyPKK6lGxnjNfR2vhStYciXHjjSuGscgpNjP3GKjLKQ3WsbKm315KKWaqmHVnjHLJib2nSIbjPuekotqsSKGE1hsclLKCHcsywmkGeVHHq(2KSWKewkjWUHvqsSKGDDojkaIj8TjbEbK0BtYBGxaVA04BEaEOaV(MmaxrXaPz4lZIrbxVHHq(2K8KK0jzccgEGDDo8cWhqmKy3ojSGKZIv7QJrQVaE1K8KKZUz(IPhyxNFvaet4BpakE5nIK5tscBjIe72jzArisEscSByfxGIxEJi5bKC2nZxm9a768RcGycF7bqXlVrKmdjpjjDsGDdR4cu8YBejZNKKZUz(IPhyxNFvaet4BpakE5nIK3jHT0sYtso7M5lMEGDD(vbqmHV9aO4L3isEqssmoCsEBKKqKy3ojWUHvCbkE5nIK5j5SBMVy6bZIrbxVHHq(2doeOcFBsSBNey3WkUafV8grYdi5SBMVy6b215xfaXe(2dGIxEJi5DsylTKy3ojNfR2vhJuFb8QjXUDsMGGHht5D5ziumGyizMF8FKv)z)MAxtzL)z53KROdWzcF7V5CqkjSS4gkjEJCUsYctYCFlsGxajHLscSdqbjqiLKfqY2KW6jGKcouajHLscSdqbjqiDqsI7Hfjp6gwbjVvPKyTzojWlGK5(wJVzx463e5nmu(AKlUxXcq3PIBO3f(cRG94XRV5b4Hc86BobbdpWUohEb4digsSBNKWXvsMNe2sejpjjDsybjNfR2vhJ2nSIlCPKmZ3SoHV93e5nmu(AKlUxXcq3PIBO3f(cRG94XRF8F8H(Z(n1UMYk)ZYVzDcF7VjCPxdOcW9QrFtUIoaNj8T)MZbPK8wLsIniub4E1is2MewpbKSqbY5kjlmjZDDo8cWhKmhKsYBvkj2GqfG7vZrK4njZDDo8cWjXHj51crIvHvjr9WsbKydcwSkj2OgRBSGk8TjzbK8wUM5KSWKWY8IqloAqsIxEqc8ciHVbIKyjzsjbIHKjfEbkj1jCSv4TbjVvPKydcvaUxnIKyjbVsmoUJusclLKjiy4X38a8qbE9nzbjtqWWdSRZHxa(aIHKNKKojSGKZUz(IPhyxNFJfa0ogqmKy3ojSGKOYAhdSRZVXcaAhdTRPSYjzgsEss6KGTaEnL1bFd0fIHKNKGy0C(gfWqd0aBHZ4a)CJf6yrsssyJe72jPoHJvV8ngylCgh4NBSqhlssscIrZ5BuadnqdSfoJd8ZnwOJfjpjbXO58nkGHgOb2cNXb(5gl0XIK5jHnsMHe72jzccgEGDDo8cWhqmK8KK0jbTq5jV5ddWIvVEJ1nwqf(2dTRPSYjXUDsqluEYB(a21m)UW3P8IqloAODnLvojZ8J)Jj0F2VP21uw5Fw(nRt4B)nX9MBu4k6BYv0b4mHV93CoiLK30BUrHRisWyPnjvotYdrsc2zrKuaLeig2jzbK8AHiPakjEtYCxNdVa8bjjSgbbusEJqTHc82GK5UoNemEotck8CMKjLeigsWyPnjHLsYPqbjHJRKa7TJSu0GeZyzibc5TbjvqsAFNKOagAGibJhwKyQfWBdsE0nSc8cOJV5b4Hc86B6nQApErYdijHprK8KK0jjDsWwaVMY6OY5lFd0fIHKNKKojSGKZUz(IPhyxNFvaet4BpGyiXUDsybjrL1ogwqTHc824IDD(q7AkRCsMHKziXUDsMGGHhyxNdVa8bedjZqYtssNewqsuzTJHfuBOaVnUyxNp0UMYkNe72jHRtqWWdlO2qbEBCXUoFau8YBejZtYPqXnCCLe72jHfKmbbdpWUohEb4digsMHKNKKojSGKOYAhdKwaVnUTByf4fqhAxtzLtID7KGy0C(gfWqd0a3B(fPfGKhqsAjzMF8FmT)z)MAxtzL)z53SoHV93eQT28RBVyRVjxrhGZe(2FZ5GusMtBT5xK84ITizBsy9eWojwBM7TbjtaxHZVijwsWuEqc8ciHzXOas8ggc5BtYciP4CsqmfMgn(MhGhkWRVz6KKojSGeq58RIv7yuCoAaXqYtsaLZVkwTJrX5OH3KmpjSkrKmdj2TtcOC(vXQDmkohnakE5nIK5tscBPLe72jbuo)Qy1ogfNJgCiqf(2K8asylTKmdjpjjDsMGGHhmlgfC9ggc5BpGyiXUDso7M5lMEWSyuW1ByiKV9aO4L3isMpjjSLisSBNewqcdWvumqAg(YSyuW1ByiKVnjZqYtssNewqsuzTJHfuBOaVnUyxNp0UMYkNe72jHRtqWWdlO2qbEBCXUoFaXqID7KWcsMGGHhyxNdVa8bedjZ8J)J2W)SFtTRPSY)S8BwNW3(BoTBFx4ByP3cD0MR8VjxrhGZe(2FZ5Gus2MewpbKmbfKWa8f4HJusGqEBqYCxNtscdaXe(2Ka7auWojomjqiLtI3iNRKSWKm33IKTjXCwsGqkjfCOasksWUoFAZbjWlGKZUz(IPjrHH9JR95fjvZjbEbKyb1gkWBdsWUoNeiMWXvsCysIkRDO8X38a8qbE9nzbjtqWWdSRZHxa(aIHKNKWcso7M5lMEGDD(vbqmHV9aIHKNKGy0C(gfWqd0a3B(fPfGK5jHnsEsclijQS2XaPfWBJB7gwbEb0H21uw5Ky3ojPtYeem8a76C4fGpGyi5jjignNVrbm0anW9MFrAbi5bKWksEsclijQS2XaPfWBJB7gwbEb0H21uw5K8KK0jHbOyVgh(GTb2153PnhK8KK0jHfKOPmKZWO8HIZ8cOv(UaEx9rjXUDsybjrL1ogwqTHc824IDD(q7AkRCsMHe72jrtziNHr5dfN5fqR8Db8U6JsYtso7M5lMEO4mVaALVlG3vF0bqXlVrK8GKKWMnKvK8KeUobbdpSGAdf4TXf768bedjZqYmKy3ojPtYeem8a76C4fGpGyi5jjrL1ogiTaEBCB3WkWlGo0UMYkNKz(X)rw7F2VP21uw5Fw(nRt4B)npvoFRt4BFZok(Mzhf3UW1Vza8ovnq)4hFZa4DQAG(Z(FKT)SFtTRPSY)S8BYv0b4mHV93CoiLKTjH1tajPKzkLcsILednijb7SKe(jvVniPAojAIHXbkjXss2BLeigsM0iuajy8WIK5UohEb4FZUW1VPIZ8cOv(UaEx9r)MhGhkWRV5z3mFX0dSRZVkaIj8ThafV8grYdsscBSIe72j5SBMVy6b215xfaXe(2dGIxEJizEsyfR9BwNW3(BQ4mVaALVlG3vF0F8FKv)z)MAxtzL)z53KROdWzcF7V5SGxKeljMV6dj2OeUjGemEyrscwOPSsIzuNuvojSEcqK4WKWSiKpL1bjj2MK82gkGey3WkqKGXdlsWxGsInkHBcibcPisQiuCMGKyjb9QpKGXdlsQ(fjhojlGeBaqOGeiKsIhJVzx4630B0baf1uwVPmu1be(LRy9J(npapuGxFZjiy4b215WlaFaXqYtsMGGHhmlgfC9ggc5BpGyiXUDsMweIKNKa7gwXfO4L3isEqssyvIiXUDsMGGHhmlgfC9ggc5BpGyi5jjNDZ8ftpWUo)QaiMW3Eau8YBejVtcBPLK5jb2nSIlqXlVrKy3ojtqWWdSRZHxa(aIHKNKC2nZxm9GzXOGR3WqiF7bqXlVrK8ojSLwsMNey3WkUafV8grID7KKojNDZ8ftpywmk46nmeY3Eau8YBejZNKe2sejpj5SBMVy6b215xfaXe(2dGIxEJiz(KKWwIizgsEscSByfxGIxEJiz(KKWwcFI(M1j8T)MEJoaOOMY6nLHQoGWVCfRF0F8F8H(Z(n1UMYk)ZYVjxrhGZe(2FtZx9HetlvdsEtiKFibJhwKm315Wla)B2fU(nXRtnb0lYs14IdH8Z38a8qbE9np7M5lMEGDD(vbqmHV9aO4L3isMNe2s03SoHV93eVo1eqVilvJloeYp)4)yc9N9BQDnLv(NLFZUW1VjAHYzncVnUaOPxFZZRtwVrbm0a9FKTV5b4Hc86Bobbdpywmk46nmeY3EaXqID7KWcsyaUIIbsZWxMfJcUEddH8T)M1j8T)MOfkN1i824cGME9n5k6aCMW3(BA(QpK8geA6fjy8WIKuSyuaj2Oggc5BtceQmu2jbVsvjbbbusILeu7mkjHLssEXOOGK3ykijkGHg)4)yA)Z(n1UMYk)ZYVjxrhGZe(2FZ5GusyzXnus8g5CLKfMK5(wKaVasclLeyhGcsGqkjlGKTjH1tajfCOasclLeyhGcsGq6GetRfeKCCWbYdsCysWUoNefaXe(2KC2nZxmnjoIe2seIKfqc(cuskm1RX3SlC9BI8ggkFnYf3RybO7uXn07cFHvWE84138a8qbE9np7M5lMEGDD(vbqmHV9aO4L3isMpjjSLOVzDcF7VjYByO81ixCVIfGUtf3qVl8fwb7XJx)4)On8p73u7AkR8pl)MCfDaot4B)nNdsjj7OGKfMKTFdHqkj8cVmuscG3PQbIKTZViXHj5nc1gkWBdsM76CssGobbdtIJiPoHJvzNKfqYRfIKcOK0BqsuzTdLtI3XsIhJVzDcF7V5PY5BDcF7B2rX38a8qbE9ntNewqsuzTJHfuBOaVnUyxNp0UMYkNe72jHRtqWWdlO2qbEBCXUoFaXqYmK8KK0jzccgEGDDo8cWhqmKy3ojNDZ8ftpWUo)QaiMW3Eau8YBejZtcBjIKz(Mzhf3UW1Vjh34gaVtvd0p(pYA)Z(n1UMYk)ZYVzDcF7VjesVEO4OVjxrhGZe(2FZeOWfuoibUY5P6KkjWlGeiunLvs8qXrpmjZbPKSnjNDZ8fttI3KSaUciz6fjbW7u1GeuEJX38a8qbE9nNGGHhyxNdVa8bedj2TtYeem8GzXOGR3WqiF7bedj2TtYz3mFX0dSRZVkaIj8ThafV8grY8KWwI(Xp(Mt72)z)pY2F2VP21uw5Fw(npapuGxFteJMZ3OagAGg4EZViTaK8GKK8qFZ6e(2FZcD0MR87uUqXp(pYQ)SFtTRPSY)S8BEaEOaV(MignNVrbm0ank0rBUYV9ITizEsyJKNKGy0C(gfWqd0a3B(fPfGK5jHnsENKOYAhdKwaVnUTByf4fqhAxtzL)nRt4B)nl0rBUYV9IT(Xp(MhmN)S)hz7p73u7AkR8pl)Mqi9IXYZ69uOWBJ)JS9nRt4B)nrAb8242UHvGxa9BEEDY6nkGHgO)JS9npapuGxFZ0jbBb8AkRdKwaVnUTByf4fqVhOyHHj5jjSGeSfWRPSoy2nFHxW9WrKmdj2Tts6KW3yGSk(I5Izb8lt59aOWafzvtzLKNKGy0C(gfWqd0a3B(fPfGK5jHnsM5BYv0b4mHV93CoiLetTaEBqYJUHvGxaLehMKxlejy8CMelpir7fYWIKOagAGiPAojPyXOasSrnmeY3MKQ5Km315WlaNKcOK0Bqcql(l2jzbKeljafgOilsmt8hofKSnjbMLKfqc(cusIcyObA8J)JS6p73u7AkR8pl)Mqi9IXYZ69uOWBJ)JS9nRt4B)nrAb8242UHvGxa9BEEDY6nkGHgO)JS9npapuGxFZOYAhdKwaVnUTByf4fqhAxtzLtYts4BmqwfFXCXSa(LP8EauyGISQPSsYtsqmAoFJcyObAG7n)I0cqY8KWQVjxrhGZe(2FttRfeKW6o4a5bjMAb82GKhDdRaVakjNT5E4BtsSKKQQmKyM4pCkibIHeVjjL2e2p(p(q)z)MAxtzL)z53C78R7bZ5BY23SoHV93e3B(DkxO4BYv0b4mHV93C78R7bZHe8kvfrsyPKuNW3MKTZVibcvtzLeoeWBdsowv3A2BdsQMtsVbjfIKIeGAaLlaj1j8Th)4h)4BIvbiF7)JSkrSITeL2eXQVjMc0EBG(MjEk9g8rB0J2GpmjKmRLsIJZSGGe4fqcR5WrSgsaAkd5aLtcAXvskOyXRq5KCSQ2qrdY23U3kj2WhMewFBSkiuojSMa4DQAmQPZ4SBMVyAwdjXscR5SBMVy6rnDynKKoBjMzgKTKT2iCMfekNeBmj1j8Tjj7OaniB)Mig98FKvP1g)nzalSN1VzAsdjMwfFXqskaUIcY20KgsSfQvsyfRLDsyvIyfBKTKTPjnKmlgTsLK5UoNKzxaq7GemwAtsuadni5SqDGiPakjWl4O8bzlzBAsdjjSeJEGcLtYKcVaLKZIpvbjtQH3ObjP05OmbIKE73qRcGddLjPoHVnIKTZVgKT1j8TrdgGEw8PkEpPnzwmk4Izb8l8ccpG4k7oCsGIxEJEWdLOer2wNW3gnya6zXNQ49K2ezv8fd8cWz3HtYIjiy4bYQ4lg4fGpGyiBRt4BJgma9S4tv8EsBwGt16nwaq7GDhoP3OQ941GRW(XJ5zlTKT1j8TrdgGEw8PkEpPnXwaVMYk7DHRjX9MFrAbUhOyHHzFzsI0GDSvgstYkY26e(2Obdqpl(ufVN0MylCgh4NBSqhlYwY20KgssXg(2iY26e(2OKipR9rjBRt4BJsYSHVn7oCYjiy4b215WlaFaXy3(eem8GzXOGR3WqiF7bedzBDcFB07jTj2c41uwzVlCnjFd0fIH9Ljjsd2XwzinjFJbYQ4lMlMfWVmL3JWpP6TXt(gdSfoJd8ZnwOJ1i8tQEBq2wNW3g9EsBITaEnLv27cxtw58LVb6cXW(YKePb7yRmKMKVXazv8fZfZc4xMY7r4Nu924jFJb2cNXb(5gl0XAe(jvVnEY3yWvSleWBJltUmG0r4Nu92GSnnKygfiibc5TbjMAb82GKhDdRaVakjvqYd9ojrbm0arYcijHENehMKxlejfqjXBsM76C4fGt2wNW3g9EsBITaEnLv27cxtI0c4TXTDdRaVa69aflmm7ltsKgSJTYqAseJMZ3OagAGg4EZViTaZZQ3NGGHhyxNdVa8bedzBAiH13nZxmnjPy3mjZTaEnLv2jzoiLtsSKWSBMKjfEbkj1jCSv4TbjyxNdVa8bjSoeaODKFrces5KeljNTdWMjbJL2Kelj1jCSvOKGDDo8cWjbJhwK49zX92GKIZrdY26e(2O3tAtSfWRPSYEx4AsMDZx4fCpCe7ltsKgSJTYqAYZUz(IPhyxNFvaet4BpGyEMolaLZVkwTJrX5ObeJD7GY5xfR2XO4C0GdbQW3(bjzlr2TdkNFvSAhJIZrdGIxEJMpjBj690(2spQS2XWcQnuG3gxSRZhAxtzLB3(zXQD1Xi1xaV6zM5z6PdkNFvSAhJIZrdVNNvjYUDeJMZ3OagAGgyxNFvaet4BpFY0oJD7rL1ogwqTHc824IDD(q7AkRC72plwTRogP(c4vpdzBDcFB07jTjSd0P8UC2D4KtqWWdSRZHxa(aIHSToHVn69K2CsbifKQ3gS7WjNGGHhyxNdVa8bedzBAizoiLK3UByfSgej2cXnW1oiXHjjSuGssbusyfjlGe8fOKefWqde7KSaskohrsb0M1eKGykmT3gKaVasWxGssyvnjS20IgKT1j8TrVN0Mz3WkqxBaqCdCTd2D4KignNVrbm0anYUHvGU2aG4g4AhZNKv2TNolaLZVkwTJrX5OHMyCuGSBhuo)Qy1ogfNJgEppRnTZq2wNW3g9EsBw9rrbOY3tLZS7WjNGGHhyxNdVa8bedzBDcFB07jT5PY5BDcF7B2rb7DHRjpyoKT1j8TrVN0MaO(wNW3(MDuWEx4As8YBYwY20KgssPu82jjwsGqkjyS0MewUBtYctsyPKKsOJ2CLtIJiPoHJvjBRt4BJgt72jl0rBUYVt5cfS7WjrmAoFJcyObAG7n)I0c8GKpezBDcFB0yA3(9K2SqhT5k)2l2IDhojIrZ5BuadnqJcD0MR8BVyR5z7jIrZ5BuadnqdCV5xKwG5z79OYAhdKwaVnUTByf4fqhAxtzLt2s2MM0qcRNaezBAizoiLKuSyuaj2Oggc5BtcgpSizURZHxa(GK34M5KaVasM76C4fGtYzXvejlmmjNDZ8fttI3KewkjTMycsylrKG0Z2CejByPamosjbcPKSnjhojqDwrisclLeMC9sbK4isykqqYctsyPKK6lGxnjNfR2vhStYciXHjjSuGscgpNjP3GKjLKQ3WsbKm315KKWaqmHVnjHLJib2nSIbjPuekotqsSKGE1hsclLKCHcsywmkGeVHHq(2KSWKewkjWUHvqsSKGDDojkaIj8TjbEbK0BtYBGxaVA0GSToHVnAC4OKmlgfC9ggc5BZUdNKb4kkgindFzwmk46nmeY3(z6tqWWdSRZHxa(aIXUDwCwSAxDms9fWR(5z3mFX0dSRZVkaIj8ThafV8gnFs2sKD7tlc9e2nSIlqXlVrp4SBMVy6b215xfaXe(2dGIxEJM5z6WUHvCbkE5nA(KNDZ8ftpWUo)QaiMW3Eau8YB07SL2NNDZ8ftpWUo)QaiMW3Eau8YB0dsAC4VTeYUDy3WkUafV8gn)z3mFX0dMfJcUEddH8ThCiqf(22Td7gwXfO4L3OhC2nZxm9a768RcGycF7bqXlVrVZwATB)Sy1U6yK6lGxTD7tqWWJP8U8mekgqmZq2MgsMdsjX0ZAFus2MewpbKeljmG9qIPYybzdeRbrska7jx4v4BpiBtdj1j8TrJdh9EsBI8S2hL9OagACD4KaOwHxGHoqkJfKnqOldyp5cVcF7HMYqodJYFMEuadngo6wCUD7rbm0yW1jiy4XPqH3gdGwNygY20qYCqkjSS4gkjEJCUsYctYCFlsGxajHLscSdqbjqiLKfqY2KW6jGKcouajHLscSdqbjqiDqsI7Hfjp6gwbjVvPKyTzojWlGK5(wdY26e(2OXHJEpPnHq61dfN9UW1KiVHHYxJCX9kwa6ovCd9UWxyfShpEXUdNCccgEGDDo8cWhqm2ThoUopBj6z6S4Sy1U6y0UHvCHlDgY20qYCqkjVvPKydcvaUxnIKTjH1tajluGCUsYctYCxNdVa8bjZbPK8wLsIniub4E1CejEtYCxNdVaCsCysETqKyvyvsupSuaj2GGfRsInQX6glOcFBswajVLRzojlmjSmVi0IJgKK4LhKaVas4BGijwsMusGyizsHxGssDchBfEBqYBvkj2GqfG7vJijwsWReJJ7iLKWsjzccgEq2wNW3gnoC07jTjCPxdOcW9QrS7WjzXeem8a76C4fGpGyEMolo7M5lMEGDD(nwaq7yaXy3olIkRDmWUo)glaODm0UMYkFMNPJTaEnL1bFd0fI5jIrZ5BuadnqdSfoJd8ZnwOJvs2SBVoHJvV8ngylCgh4NBSqhRKignNVrbm0anWw4moWp3yHowprmAoFJcyObAGTWzCGFUXcDSMNTzSBFccgEGDDo8cWhqmpthTq5jV5ddWIvVEJ1nwqf(2dTRPSYTBhTq5jV5dyxZ87cFNYlcT4OH21uw5Zq2MgsMdsj5n9MBu4kIemwAtsLZK8qKKGDwejfqjbIHDswajVwiskGsI3Km315WlaFqscRrqaLK3iuBOaVnizURZjbJNZKGcpNjzsjbIHemwAtsyPKCkuqs44kjWE7ilfniXmwgsGqEBqsfKK23jjkGHgisW4HfjMAb82GKhDdRaVa6GSToHVnAC4O3tAtCV5gfUIy3Ht6nQApE9Ge(e9m90XwaVMY6OY5lFd0fI5z6S4SBMVy6b215xfaXe(2dig72zruzTJHfuBOaVnUyxNp0UMYkFMzSBFccgEGDDo8cWhqmZ8mDwevw7yyb1gkWBJl215dTRPSYTBNRtqWWdlO2qbEBCXUoFau8YB08Ncf3WXv72zXeem8a76C4fGpGyM5z6SiQS2XaPfWBJB7gwbEb0H21uw52TJy0C(gfWqd0a3B(fPf4bPDgY20qYCqkjZPT28lsECXwKSnjSEcyNeRnZ92GKjGRW5xKeljykpibEbKWSyuajEddH8TjzbKuCojiMctJgKT1j8TrJdh9EsBc1wB(1TxSf7oCY0tNfGY5xfR2XO4C0aI5jOC(vXQDmkohn8EEwLOzSBhuo)Qy1ogfNJgafV8gnFs2sRD7GY5xfR2XO4C0GdbQW3(bSL2zEM(eem8GzXOGR3WqiF7beJD7NDZ8ftpywmk46nmeY3Eau8YB08jzlr2TZcgGROyG0m8LzXOGR3WqiF7zEMolIkRDmSGAdf4TXf768H21uw52TZ1jiy4HfuBOaVnUyxNpGySBNftqWWdSRZHxa(aIzgY20qYCqkjBtcRNasMGcsya(c8WrkjqiVnizURZjjHbGycFBsGDakyNehMeiKYjXBKZvswysM7BrY2KyoljqiLKcouajfjyxNpT5Ge4fqYz3mFX0KOWW(X1(8IKQ5KaVasSGAdf4TbjyxNtcet44kjomjrL1ou(GSToHVnAC4O3tAZPD77cFdl9wOJ2CLZUdNKftqWWdSRZHxa(aI5jlo7M5lMEGDD(vbqmHV9aI5jIrZ5BuadnqdCV5xKwG5z7jlIkRDmqAb8242UHvGxaDODnLvUD7PpbbdpWUohEb4diMNignNVrbm0anW9MFrAbEaREYIOYAhdKwaVnUTByf4fqhAxtzL)mDgGI9AC4d2gyxNFN2C8mDwOPmKZWO8HIZ8cOv(UaEx9rTBNfrL1ogwqTHc824IDD(q7AkR8zSBxtziNHr5dfN5fqR8Db8U6J(maENQgdfN5fqR8Db8U6Joo7M5lMEau8YB0dsYMnKvp56eem8WcQnuG3gxSRZhqmZmJD7PpbbdpWUohEb4diMNrL1ogiTaEBCB3WkWlGo0UMYkFgY26e(2OXHJEpPnpvoFRt4BFZokyVlCnza8ovnqKTKTPjnKW6fkijXT8SscRxOWBdsQt4BJgKyQbjvqILByPasya(c84fjXscYAbbjhhCG8GeVdfaGycsoBZ9W3grY2K8MEZjXulGnFRC9ISnnKmhKsIPwaVni5r3WkWlGsIdtYRfIemEotILhKO9czyrsuadnqKunNKuSyuaj2Oggc5Bts1CsM76C4fGtsbus6nibOf)f7KSasILeGcduKfjMj(dNcs2MKaZsYcibFbkjrbm0aniBRt4BJghmNKiTaEBCB3WkWlGYoesVyS8SEpfk82ijBSFEDY6nkGHgOKSXUdNmDSfWRPSoqAb8242UHvGxa9EGIfg(jlWwaVMY6Gz38fEb3dhnJD7PZ3yGSk(I5Izb8lt59aOWafzvtz9jIrZ5BuadnqdCV5xKwG5zBgY20qIP1ccsyDhCG8GetTaEBqYJUHvGxaLKZ2Cp8Tjjwssvvgsmt8hofKaXqI3KKsBcJSToHVnACWCEpPnrAb8242UHvGxaLDiKEXy5z9Eku4Trs2y)86K1BuadnqjzJDhozuzTJbslG3g32nSc8cOdTRPSYFY3yGSk(I5Izb8lt59aOWafzvtz9jIrZ5BuadnqdCV5xKwG5zfzBAiz78R7bZHe8kvfrsyPKuNW3MKTZVibcvtzLeoeWBdsowv3A2BdsQMtsVbjfIKIeGAaLlaj1j8ThKT1j8TrJdMZ7jTjU387uUqb7BNFDpyojzJSLSToHVnAWXnUbW7u1aLecPxpuC27cxtYlqQ472xUEs9EzGcGIoAFuY26e(2Obh34gaVtvd07jTjesVEO4S3fUMeb1t5D53cxdRxOGSToHVnAWXnUbW7u1a9EsBcH0Rhko7DHRjnYVySUl8Tqih3Zv4Bt2wNW3gn44g3a4DQAGEpPnHq61dfN9UW1KCGwCyhOxSkcPzYwY20KgsEZYBssPu82zNeK1cL5KCwSkGKkNjbuTHIizHjjkGHgisQMtc6ODb8fr2wNW3gnWlVtEQC(wNW3(MDuWEx4AYPDB2D4KtqWWJPD77cFdl9wOJ2CLpGyiBRt4BJg4L3VN0MChXO5lEz4h2D4KSikGHgdhDzY1lfq2MgsMdsjzURZjjHbGycFBs2MKZUz(IPjHz3S3gKubjzTqbjjuIiXBu1E8IKjOGKEdsCysETqKGXZzswSk4umK4nQApErI3Km33AqYBwPQKGGakjiRIVyGDT52e3B(K2Cfqs1CsEtV5KWYCHcsCejBtYz3mFX0KmPWlqjzUjSbj2iJEbkjm7M92GeGIcGFcFBejomjqiVniX0Q4lg4CHRKKcGJWjPAojSuBUciXrKSqXGSToHVnAGxE)EsBIDD(vbqmHVn7oCsSfWRPSoy2nFHxW9Wrpt3Bu1E8A(KjuISBNrJbSRnFuNWXQpbqTcVadDGSk(Ibox46Lb4i8HMYqodJYFYIZUz(IPh4EZVt5cfdiMNS4SBMVy6bYQ4lMlMfWVCTcRbeZmpt3Bu1E86bjTXP1U9OYAhdKwaVnUTByf4fqhAxtzL)eBb8AkRdKwaVnUTByf4fqVhOyHHN5jlo7M5lMEa7AZhqmptNfNDZ8ftpW9MFNYfkgqm2TJy0C(gfWqd0a3B(fPfyEwndzBAi5nRuvsqqaLKxlejmqbjqmKyM4pCkijLmtPuqY2Kewkjrbm0GehMKehuHfmuMK3QuGRK4OM1eKuNWXQKGXsBsGDdRWBdsy7n8HijkGHgObzBDcFB0aV8(9K2ezv8fZfZc4xMYB2D4KtqWWd4sVgqfG7vJgqmpzbxNGGHhyavybdLVWLcCDaX8eXO58nkGHgObU38lslWdsiY26e(2ObE597jT5PY5BDcF7B2rb7DHRjpCezBAi5n6gwKKcGVapErYB6nNetTaKuNW3MKyjbOWafzrsc2zrKGXdlsqAb8242UHvGxaLSToHVnAGxE)EsBI7n)I0cW(51jR3OagAGsYg7oCYOYAhdKwaVnUTByf4fqhAxtzL)eXO58nkGHgObU38lslW8ylGxtzDG7n)I0cCpqXcd)Kf8ngiRIVyUywa)YuEpc)KQ3gpzXz3mFX0dyxB(aIHSnnKKcGcRasILeiKssck8UcFBssjZukfK4WKu9lssWoljoIKEdsGygKT1j8Trd8Y73tAtEH3v4BZ(51jR3OagAGsYg7oCswGTaEnL1rLZx(gOledzBAizoiLetRIVyijXxaNKeOvyrIdtceYBdsmTk(Ibox4kjPa4iCsQMtYK2CfqcgpNjrtmmoqjHdb82GKWsjP1etqIXHpiBRt4BJg4L3VN0MiRIVyUywa)Y1kSy3HtYOXa21MpQt4y1NaOwHxGHoqwfFXaNlC9YaCe(qtziNHr5pz0ya7AZhafV8g9GKghozBAijLYyQxisGqkj4EZNYfkqK4WKCkggLts1CsSGAdf4TbjyxNtIJibIHKQ5KaH82GetRIVyGZfUsskaocNKQ5KmPnxbK4isGygKqskX5E4Bx58l2j5uOGeCV5t5cfK4WK8AHibZcL5KmPKa11uwjjwsm0GKWsjb4WbjtVibt5H3gKuKyC4dY26e(2ObE597jTjU387uUqb7oCY0p7M5lMEG7n)oLlumowfWqrZZ2Z056eem8WcQnuG3gxSRZhqm2TZIOYAhdlO2qbEBCXUoFODnLv(m2TZOXa21MpakE5n6bjpfkUHJRVBC4Z8KrJbSRnFuNWXQpbqTcVadDGSk(Ibox46Lb4i8HMYqodJYFYOXa21MpakE5nA(tHIB44kzBAizoiLK5UoNewU5GKkiXYnSuajmaFbE8IemEyrYBeQnuG3gKm315KaXqsSKKqKefWqde7KSas2WsbKevw7arY2Kyo7GSToHVnAGxE)EsBIDD(DAZb7oCsVrv7XRhK0gN2NrL1ogwqTHc824IDD(q7AkR8NrL1ogiTaEBCB3WkWlGo0UMYk)jIrZ5BuadnqdCV5xKwGhK0gA3E6Phvw7yyb1gkWBJl215dTRPSYFYIOYAhdKwaVnUTByf4fqhAxtzLpJD7ignNVrbm0anW9MFrAbsY2mKTPHKeSnRjibcPKKaf7cb82GKuKldiLehMKxlejNQjXqds8owsM76C4fGtI3Oqlo7KSasCysm1c4Tbjp6gwbEbusCejrL1ouojvZjbJNZKy5bjAVqgwKefWqd0GSToHVnAGxE)EsBYvSleWBJltUmGu2D4KPduyGISQPSA3U3OQ9418S20oZZ0zb2c41uwhm7MVWl4E4i729gvThVMpPnoTZ8mDwevw7yG0c4TXTDdRaVa6q7AkRC72tpQS2XaPfWBJB7gwbEb0H21uw5pzb2c41uwhiTaEBCB3WkWlGEpqXcdpZmKTPHK5GusMlljzBsy9eqIdtYRfIe(2SMGKwvojXsYPqbjjqXUqaVnijf5YaszNKQ5KewkqjPakjzfHijSQMKeIKOagAGizHcsspTKGXdlsoBZH8yMbzBDcFB0aV8(9K2e76870Md2D4KignNVrbm0anW9MFrAbEq6j07NT5qEm4ocTD1XvpwRIgAxtzLpZtVrv7XRhK0gN2NrL1ogiTaEBCB3WkWlGo0UMYk3UDwevw7yG0c4TXTDdRaVa6q7AkRCY20qYCqkjMwfFXqsIVa(dtsc0kSiXHjjSusIcyObjoIKAAHcsILeURKSasETqKyvyvsmTk(Ibox4kjPa4iCs0ugYzyuojy8WIK30B(K2CfqYciX0Q4lgyxBoj1jCS6GSToHVnAGxE)EsBISk(I5Izb8lxRWI9ZRtwVrbm0aLKn2D4KPhfWqJHLw5WAWCIhWQe9eXO58nkGHgObU38lslWdsOzSBpDgngWU28rDchR(ea1k8cm0bYQ4lg4CHRxgGJWhAkd5mmkFgY20qYCqkjMqaG2CfqsSK8MfVveIKTjPijkGHgKewvqIJiXy92GKyjH7kjvqsyPKaCdRGKWX1bzBDcFB0aV8(9K2ebbaAZvWn2lEXBfHy)86K1BuadnqjzJDhozuadngHJR3yVCxFaRs7Zjiy4b215WlaFWxmnzBAizoiLK5UoNKzxaq7GKTZViXHjXmXF4uqs1CsM7SKuaLK6eowLKQ5Kewkjrbm0GemBZAcs4Uschc4TbjHLsYXQ6wZdY26e(2ObE597jTj2153ybaTd2pVoz9gfWqdus2y3HtITaEnL1bFd0fI5zuadngHJR3yVCxN)HEM(eem8a76C4fGp4lM2U9jiy4b215WlaFau8YB0do7M5lMEGDD(DAZXaO4L3OzEwNWXQx(gdSfoJd8ZnwOJvseJMZ3OagAGgylCgh4NBSqhRNignNVrbm0anW9MFrAbEq6P990THVTOYAhJaJJI7cFHRqhAxtzLpZmKT1j8Trd8Y73tAtCV5tAZva7oCs(gdSfoJd8ZnwOJ1i8tQEB8m9OYAhdKwaVnUTByf4fqhAxtzL)eXO58nkGHgObU38lslW8ylGxtzDG7n)I0cCpqXcdB3oFJbYQ4lMlMfWVmL3JWpP6TXmptNfaOwHxGHoqwfFXaNlC9YaCe(qtziNHr52TxNWXQx(gdSfoJd8ZnwOJvseJMZ3OagAGgylCgh4NBSqhRziBtdjZbPKyM4pCcibJhwKKIY7jGwPQassbQY4Ka1zfHijSusIcyObjy8CMKjLKjnVyiHvjYgysMu4fOKewkjNDZ8fttYzXvejt1j1bzBDcFB0aV8(9K2ezv8fZfZc4xUwHf7oCsauRWlWqhmL3taTsvbxguLXhAkd5mmk)j2c41uwh8nqxiMNrbm0yeoUEJ9YCIlRs08PF2nZxm9azv8fZfZc4xUwH1GdbQW3(DJdFgY20qYCqkjMwfFXqcRdkKfjBtcRNasG6SIqKewkqjPakjfNJiX7ZI7TXGSToHVnAGxE)EsBISk(I5EafYIDhojOC(vXQDmkohn8EE2sezBAizoiLK30BojMAbijwsoBJGWvssqbsLKzTwidRarcdypis2MKukXMWgKmBInbjwsy9THDaojoIKWYrK4isksSCdlfqcdWxGhVijSQMeGY3i82GKTjjLsSjmsG6SIqKWlqQKewlKHvGiXrKutluqsSKeoUsYcfKT1j8Trd8Y73tAtCV5xKwa2pVoz9gfWqdus2y3HtIy0C(gfWqd0a3B(fPfyESfWRPSoW9MFrAbUhOyHHFobbdp4fi1ByTqgwXaIH9Jv5Ds2y37qbaiM4644k3RqtYg7EhkaaXexhoz4NurZNKvKTPHK5GusEtV5K8w56fjXsYzBeeUssckqQKmR1czyfisya7brY2Kyo7GKztSjiXscRVnSdWjXHjjSCejoIKIel3WsbKWa8f4XlscRQjbO8ncVnibQZkcrcVaPssyTqgwbIehrsnTqbjXss44kjluq2wNW3gnWlVFpPnX9MFHZ1l2D4KtqWWdEbs9gwlKHvmGyEITaEnL1bFd0fIH9Jv5Ds2y37qbaiM4644k3RqtYg7EhkaaXexhoz4NurZNKvpp7M5lMEGDD(DAZXaIHSnnKmhKsYB6nNewMluqIdtYRfIe(2SMGKwvojXscqHbkYIKeSZIgKygldjNcfEBqsfKKqKSasWxGssuadnqKGXdlsm1c4Tbjp6gwbEbusIkRDOCsQMtYRfIKcOK0BqceYBdsmTk(Ibox4kjPa4iCswajPa96y5hsE7EN6aXO58nkGHgObU38lslW8jCsljgAGijSusW92XHWjzHjjTKunNKWsjPHWNuajlmjrbm0anijLYOLDs4lj9gKWaueIeCV5t5cfKa1HNjPYzsIcyObIKcOKW3iuojy8WIK5oljyS0MeiK3gKGSk(Ibox4kjmahHtIdtYK2CfqIJiPWwEUMY6GSToHVnAGxE)EsBI7n)oLluWUdNeBb8AkRd(gOleZtq58RIv7yGVyvCTJH3ZFkuCdhxFprJ0(eXO58nkGHgObU38lslWdspHENvVTOYAhdChPGxdTRPSYFVoHJvV8ngylCgh4NBSqhR3wuzTJbd61XYp3S3Po0UMYk)90rmAoFJcyObAG7n)I0cmFcN0oZBlDgngWU28rDchR(ea1k8cm0bYQ4lg4CHRxgGJWhAkd5mmkFMzEMolaqTcVadDGSk(Ibox46Lb4i8HMYqodJYTBNfNDZ8ftpGDT5diMNaOwHxGHoqwfFXaNlC9YaCe(qtziNHr52TxNWXQx(gdSfoJd8ZnwOJvseJMZ3OagAGgylCgh4NBSqhRziBRt4BJg4L3VN0MylCgh4NBSqhl2pVoz9gfWqdus2y3HtcuyGISQPS(mkGHgJWX1BSxURZBdTBp9OYAhdChPGxdTRPSYFY3yGSk(I5Izb8lt59aOWafzvtzDg72NGGHhqnmei7TXLxGuBfHgqmKTPHetg94vMKZ2Cp8TjjwsqXYqYPqH3gKyM4pCkizBswy43WOagAGibJL2Ka7gwH3gK8qKSasWxGsckQtQkNe8Dcrs1CsGqEBqskqVow(HK3U3Pss1CsEmXoljVPJuWRbzBDcFB0aV8(9K2ezv8fZfZc4xMYB2D4KafgOiRAkRpJcyOXiCC9g7L768j0twevw7yG7if8AODnLv(ZOYAhdg0RJLFUzVtDODnLv(teJMZ3OagAGg4EZViTaZZkY20qYBavziXmXF4uqcedjBtsHibV6xKefWqdejfIeMfH8PSYojAI5OmbjyS0Mey3Wk82GKhIKfqc(cusqrDsv5KGVtisW4HfjPa96y5hsE7EN6GSToHVnAGxE)EsBISk(I5Izb8lt5n7NxNSEJcyObkjBS7Wjbkmqrw1uwFgfWqJr446n2l315tONSiQS2Xa3rk41q7AkR8NSi9OYAhdKwaVnUTByf4fqhAxtzL)eXO58nkGHgObU38lslW8ylGxtzDG7n)I0cCpqXcdpZZ0zruzTJbd61XYp3S3Po0UMYk3U90JkRDmyqVow(5M9o1H21uw5prmAoFJcyObAG7n)I0c8GKSAMziBRt4BJg4L3VN0M4EZViTaSFEDY6nkGHgOKSXUdNeXO58nkGHgObU38lslW8ylGxtzDG7n)I0cCpqXcdZ(XQ8ojBS7DOaaetCDCCL7vOjzJDVdfaGyIRdNm8tQO5tYkY26e(2ObE597jTjU38lCUEX(XQ8ojBS7DOaaetCDCCL7vOjzJDVdfaGyIRdNm8tQO5tYQNNDZ8ftpWUo)oT5yaXq2MgsMdsjXmXF4eqsHijxOGeGIwqqIdtY2Kewkj4lwLSToHVnAGxE)EsBISk(I5Izb8lxRWISnnKmhKsIzI)WPGKcrsUqbjafTGGehMKTjjSusWxSkjvZjXmXF4eqIJizBsy9eq2wNW3gnWlVFpPnrwfFXCXSa(LP8MSLSnnKmhKsY2KW6jGKuYmLsbjXsIHgKKGDwsc)KQ3gKunNenXW4aLKyjj7TscedjtAekGemEyrYCxNdVaCY26e(2Ora8ovnqjHq61dfN9UW1KkoZlGw57c4D1hLDho5z3mFX0dSRZVkaIj8ThafV8g9GKSXk72p7M5lMEGDD(vbqmHV9aO4L3O5zfRLSnnKml4fjXsI5R(qInkHBcibJhwKKGfAkRKyg1jvLtcRNaejomjmlc5tzDqsITjjVTHcib2nScejy8WIe8fOKyJs4MasGqkIKkcfNjijwsqV6djy8WIKQFrYHtYciXgaekibcPK4XGSToHVnAeaVtvd07jTjesVEO4S3fUM0B0baf1uwVPmu1be(LRy9JYUdNCccgEGDDo8cWhqmpNGGHhmlgfC9ggc5BpGySBFArONWUHvCbkE5n6bjzvISBFccgEWSyuW1ByiKV9aI55z3mFX0dSRZVkaIj8ThafV8g9oBPDEy3WkUafV8gz3(eem8a76C4fGpGyEE2nZxm9GzXOGR3WqiF7bqXlVrVZwANh2nSIlqXlVr2TN(z3mFX0dMfJcUEddH8ThafV8gnFs2s0ZZUz(IPhyxNFvaet4BpakE5nA(KSLOzEc7gwXfO4L3O5tYwcFIiBtdjMV6djMwQgK8Mqi)qcgpSizURZHxaozBDcFB0iaENQgO3tAtiKE9qXzVlCnjEDQjGErwQgxCiKFy3HtE2nZxm9a768RcGycF7bqXlVrZZwIiBtdjMV6djVbHMErcgpSijflgfqInQHHq(2KaHkdLDsWRuvsqqaLKyjb1oJssyPKKxmkki5nMcsIcyObzBDcFB0iaENQgO3tAtiKE9qXzVlCnjAHYzncVnUaOPxS7WjNGGHhmlgfC9ggc5BpGySBNfmaxrXaPz4lZIrbxVHHq(2SFEDY6nkGHgOKSr2MgsMdsjHLf3qjXBKZvswysM7Brc8cijSusGDakibcPKSas2MewpbKuWHcijSusGDakibcPdsmTwqqYXbhipiXHjb76Csuaet4BtYz3mFX0K4isylriswaj4lqjPWuVgKT1j8TrJa4DQAGEpPnHq61dfN9UW1KiVHHYxJCX9kwa6ovCd9UWxyfShpEXUdN8SBMVy6b215xfaXe(2dGIxEJMpjBjISnnKmhKss2rbjlmjB)gcHus4fEzOKeaVtvdejBNFrIdtYBeQnuG3gKm315KKaDccgMehrsDchRYojlGKxlejfqjP3GKOYAhkNeVJLepgKT1j8TrJa4DQAGEpPnpvoFRt4BFZokyVlCnjh34gaVtvde7oCY0zruzTJHfuBOaVnUyxNp0UMYk3UDUobbdpSGAdf4TXf768beZmptFccgEGDDo8cWhqm2TF2nZxm9a768RcGycF7bqXlVrZZwIMHSnnKKafUGYbjWvopvNujbEbKaHQPSsIhko6HjzoiLKTj5SBMVyAs8MKfWvajtVijaENQgKGYBmiBRt4BJgbW7u1a9EsBcH0RhkoIDho5eem8a76C4fGpGySBFccgEWSyuW1ByiKV9aIXU9ZUz(IPhyxNFvaet4BpakE5nAE2s0p(X)da]] )


end
