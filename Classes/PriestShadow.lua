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


    spec:RegisterPack( "Shadow", 20210729, [[diLsucqivk9irsDjcckBsL0Neb1OeP6uIuwLOkvVckXSOeDlccSlj9lrGHjs0XiOwguQEMkrzAeK6AQezBeK4BIqLXrquNdkj16ej08ev09er7tLW)eHQ4GIQKfcLYdHsQjkc5IIG0gvjQ(ibjzKqjjNueeRKs4LeKuntrvk3ekj2Pkf)KGqdvuHJsqszPIqv6PuyQIkDvrvSvrs(QiuglbbzVQQ)QIbJ6WkwSO8yvzYeDzsBguFMIgnL60uTArOQETOQMTe3gQ2Tu)wPHtOJlsWYbEoKPlCDq2ob(oumEcICEvQwpbbvZNsA)i)f(N73qoH(Vb7Pe7cNYeh2XQRPuil0c5ltO8nI7I63qCE5pM63OhC9ByypYfZ3qCUx2r(Z9BGwiWt)g2riIsXeKatpSHYQVfpbihhQmHV9dmWrcqo(lbFJmiVejK(N9nKtO)BWEkXUWPmXHDS6AkfYcn2XUq5BmqH9c(ggoow)nSDPu7F23qQO33WWEKlgIZbWvuqwybu5oXyhR2sIXEkXUWKfKfyT90Mkkfjlecioxm6KpXPADjX5UaG2bXyS1M4yaMAq8BH6ar8auIHxWtLvYcHaIZbqdTLel3ar8auIHejgJT2ehdWudeXdqj(vwKsCSelV7TPLeJwId7jiUHYxrepaLyu4LcXa9T44Alvz9BuCuG(5(nWhV)5(Vr4FUFdTNSIk)y7B8aEOaF(gzqWW1SD7ZcFcB9mON2svwHe)gZl8T)gVPuoZl8TpfhfFJIJItp463iB3(h)BW(p3VH2twrLFS9nEapuGpFJBjogGPgvhDelZDf8nMx4B)nKosulh8X0F)4FZL9Z9BO9Kvu5hBFJ5f(2FdbRlpkasm8T)gsf9aUy4B)nYdsjovRljoHcGedFBI3M43Uf5IPjwC3I3MepbXfDqbXcDkj2B00ECN4mOG4EdIDyIVVqeJXlfIxbk4nIe7nAApUtS3eNQlVsmwzYxjgbbuIr2JCXa7AltaU3YmTLkG4PLeJv8wsm2kdki2reVnXVDlYfttCMcVaL4uLqReNqm7fOelUBXBtIbkka(l8Tre7WedH82Kyd7rUyGldUsCoaocN4PLeJnTLkGyhr8cf1VXd4Hc85Biya(Kv0Q4ULd8copjI4ReNoXEJM2J7eFrsIf6usSvRelQrf21wwNx4cuIVsmaQv4fyQvK9ixmWLbxpIahHx1uaYffvjXxj(wIF7wKlMUI7T8KvguuHej(kX3s8B3ICX0vK9ixmhmlqEK6e2virItJ4ReNoXEJM2J7eNZKelKVeXwTsCmfTJkshG3MN2nTd8bOvTNSIkj(kXcgGpzfTI0b4T5PDt7aFa65bflmmXPr8vIVL43Uf5IPRWU2YkKiXxjoDIVL43Uf5IPR4ElpzLbfvirITALyKOwkNyaMAGQ4ElpiDaeFbXyN40(X)gH(N73q7jROYp2(gZl8T)gi7rUyoywG8ioE)nKk6bCXW3(BGvM8vIrqaL47leXIqbXqIeBKyPyoioVmYRCq82eh2kXXam1GyhM4edmHnmuH4lFuGRe7OoHdINx4cuIXyRnXWUPD4TjXcleCzehdWudu9B8aEOaF(gzqWWv4rpMqdq6tJQqIeFL4BjwQzqWWvmGjSHHkh4rbUwHej(kXirTuoXam1avX9wEq6aioNel0)4FZL(5(n0EYkQ8JTVX8cF7VXBkLZ8cF7tXrX3O4O40dU(nEs0p(3iu(5(n0EYkQ8JTVX8cF7VbU3YdshW34D)v0tmatnq)Be(B8aEOaF(gXu0oQiDaEBEA30oWhGw1EYkQK4ReJe1s5edWuduf3B5bPdG4liwWa8jROvCVLhKoGZdkwyyIVs8Tel3OISh5I5GzbYJ44Dn8x(EBs8vIVL43Uf5IPRWU2YkK43qQOhWfdF7VbwLBAtCoa(c84oXyfVLeBOdG45f(2ehlXafgOiBIt0MlIymEytmshG3MN2nTd8bO)4FtI7N73q7jROYp2(gZl8T)gYbVNW3(B8U)k6jgGPgO)nc)nEapuGpFJBjwWa8jRO1PuoYnqhiXVHurpGlg(2FJCauyfqCSedHuIt0G3t4BtCEzKx5GyhM4PVtCI2Cj2re3BqmKy9h)BeY)C)gApzfv(X23yEHV93azpYfZbZcKhPoH93qQOhWfdF7VrEqkXg2JCXqCITajXjsNWMyhMyiK3MeBypYfdCzWvIZbWr4epTK4mTLkGymEPqSkKeDGsSec4TjXHTsCRcPGyZNS(nEapuGpFdrnQWU2Y68cxGs8vIbqTcVatTISh5IbUm46re4i8QMcqUOOkj(kXIAuHDTLvGIpEJioNjj28j)X)gS6FUFdTNSIk)y7BmVW3(BG7T8Kvgu8nKk6bCXW3(BKxfmZDeXqiLyCVLzLbfiIDyIFJOOkjEAjX2qTPc82KybRlj2redjs80sIHqEBsSH9ixmWLbxjohahHt80sIZ0wQaIDeXqIvIjoVKsp8TNs5ULe)guqmU3YSYGcIDyIVVqeJzHksIZuIH6jROehlXMAqCyRedC4G4S7eJz8WBtIhInFY634b8qb(8nsN43Uf5IPR4ElpzLbf1N9amveXxqSWeFL40jwQzqWWvBO2ubEBEeSUScjsSvReFlXXu0oQ2qTPc828iyDzv7jROsItJyRwjwuJkSRTScu8XBeX5mjXVbfNWXvIXcXMpjXPr8vIf1Oc7AlRZlCbkXxjga1k8cm1kYEKlg4YGRhrGJWRAka5IIQK4RelQrf21wwbk(4nI4li(nO4eoU(J)ncNYFUFdTNSIk)y7BmVW3(BiyD5jBlX3qQOhWfdF7VrEqkXPADjXyBlbXtqSTBARaIfb(c84oXy8WMySkO2ubEBsCQwxsmKiXXsSqtCmatnqws8ciEdBfqCmfTdeXBtSrU1VXd4Hc85B4nAApUtCotsSq(seFL4ykAhvBO2ubEBEeSUSQ9KvujXxjoMI2rfPdWBZt7M2b(a0Q2twrLeFLyKOwkNyaMAGQ4ElpiDaeNZKelui2QvItN40joMI2r1gQnvG3MhbRlRApzfvs8vIVL4ykAhvKoaVnpTBAh4dqRApzfvsCAeB1kXirTuoXam1avX9wEq6aiojXctCA)4FJWc)Z9BO9Kvu5hBFJ5f(2FdPkyHaEBEelJjK(nKk6bCXW3(BKOTt4GyiKsCIubleWBtIZrzmHuIDyIVVqe)MMytni27yjovRlHxaoXEJcDKws8ci2Hj2qhG3MeFJBAh4dqj2rehtr7qLepTKymEPqSTheR9czAtCmatnq1VXd4Hc85BKoXafgOi7jROeB1kXEJM2J7eFbXjUlrCAeFL40j(wIfmaFYkAvC3YbEbNNerSvRe7nAApUt8fjjwiFjItJ4ReNoX3sCmfTJkshG3MN2nTd8bOvTNSIkj2QvItN4ykAhvKoaVnpTBAh4dqRApzfvs8vIVLybdWNSIwr6a8280UPDGpa98GIfgM40ioTF8VryS)Z9BO9Kvu5hBFJ5f(2FdbRlpzBj(gsf9aUy4B)nYdsjovyJ4TjgRteXomX3xiILBNWbXTQsIJL43GcItKkyHaEBsCokJjKAjXtljoSvGs8auIlkcrCypnXcnXXam1ar8cfeN(LigJh2e)2wc5rA1VXd4Hc85BGe1s5edWuduf3B5bPdG4CsC6el0eJfIFBlH8OkDeA7PJJ(Sxfv1EYkQK40i(kXEJM2J7eNZKelKVeXxjoMI2rfPdWBZt7M2b(a0Q2twrLeB1kX3sCmfTJkshG3MN2nTd8bOvTNSIk)X)gHVSFUFdTNSIk)y7BmVW3(BGSh5I5GzbYJuNW(B8U)k6jgGPgO)nc)nEapuGpFJ0jogGPgvBDkHDv8feNtIXEkj(kXirTuoXam1avX9wEq6aioNel0eNgXwTsC6elQrf21wwNx4cuIVsmaQv4fyQvK9ixmWLbxpIahHx1uaYffvjXP9nKk6bCXW3(BKhKsSH9ixmeNylqMIeNiDcBIDyIdBL4yaMAqSJiEYwOG4yjw6kXlG47leX2JaLyd7rUyGldUsCoaocNynfGCrrvsmgpSjgR4TmtBPciEbeBypYfdSRTK45fUaT(J)ncl0)C)gApzfv(X23yEHV93abbaAlvWj2d(iBfH(gV7VIEIbyQb6FJWFJhWdf4Z3igGPg1WX1tShPReNtIX(Li(kXzqWWvbRlHxaEvUy6VHurpGlg(2FJ8GuInGaaTLkG4yjgRmYwriI3M4H4yaMAqCypbXoIyZ1BtIJLyPRepbXHTsmWnTdIdhxR)4FJWx6N73q7jROYp2(gZl8T)gcwxEIfa0o(gV7VIEIbyQb6FJWFJhWdf4Z3qWa8jROv5gOdKiXxjogGPg1WX1tShPReFbXxgXxjoDIZGGHRcwxcVa8QCX0eB1kXzqWWvbRlHxaEfO4J3iIZjXVDlYftxfSU8KTLOcu8XBeXPr8vINx4c0JCJQGbx0b(7el0ZM4KeJe1s5edWuduvWGl6a)DIf6zt8vIrIAPCIbyQbQI7T8G0bqCojoDIVeXyH40jwOqCEN4ykAh1aJJIZcFGNqRApzfvsCAeN23qQOhWfdF7VrEqkXPADjX5UaG2bXBxUtSdtSrILI5G4PLeNQCjEakXZlCbkXtljoSvIJbyQbXy2oHdILUsSec4TjXHTs8ZE6wl1F8VryHYp3VH2twrLFS9nEapuGpFd5gvbdUOd83jwONDn8x(EBs8vItN4ykAhvKoaVnpTBAh4dqRApzfvs8vIrIAPCIbyQbQI7T8G0bq8felya(Kv0kU3YdshW5bflmmXwTsSCJkYEKlMdMfipIJ31WF57TjXPr8vItN4Bjga1k8cm1kYEKlg4YGRhrGJWRAka5IIQKyRwjEEHlqpYnQcgCrh4VtSqpBIVijXV7VIE0wXDfrCAFJ5f(2FdCVLzAlvWp(3iCI7N73q7jROYp2(gZl8T)gi7rUyoywG8i1jS)gsf9aUy4B)nYdsj2iXsXermgpSjohJ3zaDYxbeNd0uWjgQlkcrCyRehdWudIX4LcXzkXzAzXqm2tPqyeNPWlqjoSvIF7wKlMM43IRiIZMx(1VXd4Hc85BaGAfEbMAvC8odOt(k4iIMcEvtbixuuLeFLybdWNSIwLBGoqIeFL4yaMAudhxpXEeFXb7PK4lioDIF7wKlMUISh5I5GzbYJuNWUkHat4Btmwi28jjoTF8VryH8p3VH2twrLFS9nMx4B)nq2JCXCEGbz)nKk6bCXW3(BKhKsSH9ixmeJ1Gbzt82eJ1jIyOUOieXHTcuIhGs8iLiI9(T4EBw)gpGhkWNVbyC5rfODuhPev9M4liw4u(J)ncJv)Z9BO9Kvu5hBFJhWdf4Z3ajQLYjgGPgOkU3YdshaXxqSGb4twrR4ElpiDaNhuSWWeFL4miy4QCa5Fc7fY0oQqIFdPIEaxm8T)g5bPeJv8wsSHoaIJL432iiCL4enG8jox7fY0oqelc2hI4TjoVeIj0kX5ketKqKySEByhGtSJioSDeXoI4HyB30wbelc8f4XDId7PjgOYncVnjEBIZlHycLyOUOieXYbKpXH9czAhiIDeXt2cfehlXHJReVqX34D)v0tmatnq)Be(B4DOaaKyCC4Vr4V8rxKe7FdVdfaGeJJJJRsFc9Bi834zpE)ne(BmVW3(BG7T8G0b8J)nypL)C)gApzfv(X23qQOhWfdF7VrEqkXyfVLeF5L5oXXs8BBeeUsCIgq(eNR9czAhiIfb7dr82eBKBL4CfIjsismwVnSdWj2HjoSDeXoI4HyB30wbelc8f4XDId7PjgOYncVnjgQlkcrSCa5tCyVqM2bIyhr8KTqbXXsC44kXlu8nEapuGpFJmiy4QCa5Fc7fY0oQqIeFLybdWNSIwLBGoqIFdVdfaGeJJd)nc)Lp6IKy)6B3ICX0vbRlpzBjQqIFdVdfaGeJJJJRsFc9Bi834zpE)ne(BmVW3(BG7T8axM7)4Fd2f(N73q7jROYp2(gZl8T)g4ElpzLbfFdPIEaxm8T)g5bPeJv8wsm2kdki2Hj((crSC7eoiUvvsCSeduyGISjorBUOkXgXks8BqH3MepbXcnXlGy8fOehdWudeXy8WMydDaEBs8nUPDGpaL4ykAhQK4PLeFFHiEakX9gedH82Kyd7rUyGldUsCoaocN4fqCoq3F2(J48M35xrIAPCIbyQbQI7T8G0bCrINlrSPgiIdBLyCVDCiCIxyIVeXtljoSvIBi8mfq8ctCmatnqvIZRcATKy5sCVbXIafHig3BzwzqbXqD4fINsH4yaMAGiEakXYncvsmgpSjov5smgBTjgc5TjXi7rUyGldUsSiWr4e7WeNPTube7iIhbJxMSIw)gpGhkWNVHGb4twrRYnqhirIVsmyC5rfODuXxbkU2r1BIVG43GIt44kXyH4uwVeXxjgjQLYjgGPgOkU3YdshaX5K40jwOjgleJDIZ7ehtr7OI7ifCVQ9KvujXyH45fUa9i3OkyWfDG)oXc9SjoVtCmfTJQi6(Z2FNI35x1EYkQKySqC6eJe1s5edWuduf3B5bPdG4ls8q8LionIZ7eNoXIAuHDTL15fUaL4RedGAfEbMAfzpYfdCzW1JiWr4vnfGCrrvsCAeNgXxjoDIVLyauRWlWuRi7rUyGldUEebocVQPaKlkQsITAL4Bj(TBrUy6kSRTScjs8vIbqTcVatTISh5IbUm46re4i8QMcqUOOkj2QvINx4c0JCJQGbx0b(7el0ZM4lss87(ROhTvCxreN2p(3GDS)Z9BO9Kvu5hBFJ5f(2FdbdUOd83jwON934b8qb(8nakmqr2twrj(kXXam1OgoUEI9iDL4liwOqSvReNoXXu0oQ4osb3RApzfvs8vILBur2JCXCWSa5rC8UcuyGISNSIsCAeB1kXzqWWvOggcu828ihq(TIqviXVX7(RONyaMAG(3i8p(3G9l7N73q7jROYp2(gZl8T)gi7rUyoywG8ioE)nKk6bCXW3(ByiQpFke)2w6HVnXXsmkwrIFdk82KyJelfZbXBt8cdleedWudeXyS1Myy30o82K4lJ4fqm(cuIrX8YxLeJVziINwsmeYBtIZb6(Z2FeN38oFINws8ncXCjgR4ifCV(nEapuGpFdGcduK9KvuIVsCmatnQHJRNypsxj(cIfAIVs8Tehtr7OI7ifCVQ9KvujXxjoMI2rveD)z7VtX78RApzfvs8vIrIAPCIbyQbQI7T8G0bq8feJ9F8Vb7c9p3VH2twrLFS9nMx4B)nq2JCXCWSa5rC8(B8U)k6jgGPgO)nc)nEapuGpFdGcduK9KvuIVsCmatnQHJRNypsxj(cIfAIVs8Tehtr7OI7ifCVQ9KvujXxj(wItN4ykAhvKoaVnpTBAh4dqRApzfvs8vIrIAPCIbyQbQI7T8G0bq8felya(Kv0kU3YdshW5bflmmXPr8vItN4BjoMI2rveD)z7VtX78RApzfvsSvReNoXXu0oQIO7pB)DkENFv7jROsIVsmsulLtmatnqvCVLhKoaIZzsIXoXPrCAFdPIEaxm8T)gc1vvKyJelfZbXqIeVnXdIy8PVtCmatnqepiIfxeYZkQLeRcPNkgeJXwBIHDt7WBtIVmIxaX4lqjgfZlFvsm(MHigJh2eNd09NT)ioV5D(1F8Vb7x6N73q7jROYp2(gZl8T)g4ElpiDaFJ39xrpXam1a9Vr4VH3HcaqIXXH)gH)YhDrsS)n8ouaasmoooUk9j0VHWFJhWdf4Z3ajQLYjgGPgOkU3YdshaXxqSGb4twrR4ElpiDaNhuSWWFJN9493q4F8Vb7cLFUFdTNSIk)y7BmVW3(BG7T8axM7FdVdfaGeJJd)nc)Lp6IKy)6B3ICX0vbRlpzBjQqIFdVdfaGeJJJJRsFc9Bi834zpE)ne(h)BWEI7N73q7jROYp2(gsf9aUy4B)nYdsj2iXsXer8GiUmOGyGIwqqSdt82eh2kX4Ra9BmVW3(BGSh5I5GzbYJuNW(h)BWUq(N73q7jROYp2(gsf9aUy4B)nYdsj2iXsXCq8GiUmOGyGIwqqSdt82eh2kX4RaL4PLeBKyPyIi2reVnXyDI(gZl8T)gi7rUyoywG8ioE)JF8nK4MNa4D(AG(5(Vr4FUFdTNSIk)y7B0dU(nKdiF8D7JuF5FoIqbqrpTF63yEHV93qoG8X3Tps9L)5icfaf90(P)4Fd2)5(n0EYkQ8JTVrp463ab1zLDLNbxd77O4BmVW3(BGG6SYUYZGRH9Du8J)nx2p3VH2twrLFS9n6bx)gML7I2Nf(miKJ7Lj8T)gZl8T)gML7I2Nf(miKJ7Lj8T)X)gH(N73q7jROYp2(g9GRFdjqhjSd0JafH0Y3yEHV93qc0rc7a9iqriT8JF8nKk8avIFU)Be(N73yEHV93a5fTF63q7jROYp2(X)gS)Z9BO9Kvu5hBFJhWdf4Z3idcgUkyDj8cWRqIeB1kXzqWWvXfJcoEddH8TRqIFJ5f(2FdXn8T)X)Ml7N73q7jROYp2(gR43aPX3yEHV93qWa8jROFdbtbs)gPtSCJkYEKlMdMfipIJ31WF57TjXwTsCmatnQHJRNypsxjoNjjwOjonIVsC6el3OkyWfDG)oXc9SRH)Y3BtITAL4yaMAudhxpXEKUsCotsSqH40(gcgWPhC9Bi3aDGe)X)gH(N73q7jROYp2(gR43aPX3yEHV93qWa8jROFdbtbs)gcgGpzfTk3aDGej(kXYnQsvWcb828iwgtiTg(lFVn)gcgWPhC9BmLYrUb6aj(J)nx6N73q7jROYp2(gR43aPX3yEHV93qWa8jROFdbtbs)girTuoXam1avX9wEq6ai(cIXoXyH4miy4QG1LWlaVcj(nKk6bCXW3(Byediigc5TjXg6a82K4BCt7aFakXtq8LHfIJbyQbI4fqSqJfIDyIVVqepaLyVjovRlHxa(3qWao9GRFdKoaVnpTBAh4dqppOyHH)X)gHYp3VH2twrLFS9nwXVbsJVX8cF7VHGb4twr)gcMcK(nE7wKlMUkyD5rbqIHVDfsK4ReNoX3smyC5rfODuhPevHej2QvIbJlpQaTJ6iLOQecmHVnX5mjXcNsITALyW4YJkq7OosjQcu8XBeXxKKyHtjXyH4lrCEN40joMI2r1gQnvG3MhbRlRApzfvsSvRe)wbApDuZ)oWNM40ionIVsC6eNoXGXLhvG2rDKsu1BIVGySNsITALyKOwkNyaMAGQcwxEuaKy4Bt8fjj(seNgXwTsCmfTJQnuBQaVnpcwxw1EYkQKyRwj(Tc0E6OM)DGpnXPr8vItN4Bjga1k8cm1ks0wbk6ypa8TVx1uaYffvjXwTsC6e)2TixmDvCXOGJ3WqiF7kqXhVreNZKeB(Kv8rirCEN4lJyRwjodcgUkUyuWXByiKVDfsKyRwjoBriIVsmSBAhhGIpEJioNjjg7xI40ioTVHurpGlg(2FdSE3ICX0eNJDleNQb4twrTK48GujXXsS4UfIZu4fOepVWfmH3MelyDj8cWReJ1qaG2r5oXqivsCSe)2oaBHym2AtCSepVWfmHsSG1LWlaNymEytS3Vf3BtIhPev)gcgWPhC9BiUB5aVGZtI(X)Me3p3VH2twrLFS9nEapuGpFJmiy4QG1LWlaVcj(nMx4B)nGDGMv2v(J)nc5FUFdTNSIk)y7B8aEOaF(gzqWWvbRlHxaEfs8BmVW3(BKPaKcY3BZF8VbR(N73q7jROYp2(gZl8T)gf30oqNeFiPjU2X3qQOhWfdF7VrEqkX5n30osyeXwajnX1oi2HjoSvGs8auIXoXlGy8fOehdWudKLeVaIhPer8a0oHdIrIdM2BtIHxaX4lqjoSNM4e3Lq1VXd4Hc85BGe1s5edWuduT4M2b6K4djnX1oi(IKeJDITAL40j(wIbJlpQaTJ6iLOQkKCuGi2QvIbJlpQaTJ6iLOQ3eFbXjUlrCA)4FJWP8N73q7jROYp2(gpGhkWNVrgemCvW6s4fGxHe)gZl8T)gt)uuaMY5nLYp(3iSW)C)gApzfv(X23yEHV934nLYzEHV9P4O4BuCuC6bx)gpmVF8VryS)Z9BO9Kvu5hBFJ5f(2FdauFMx4BFkok(gfhfNEW1Vb(49p(X34H59Z9FJW)C)gApzfv(X23acPhm2ErpVbfEB(Vr4VX8cF7VbshG3MN2nTd8bOFJ39xrpXam1a9Vr4VXd4Hc85BKoXcgGpzfTI0b4T5PDt7aFa65bflmmXxj(wIfmaFYkAvC3YbEbNNerCAeB1kXPtSCJkYEKlMdMfipIJ3vGcduK9KvuIVsmsulLtmatnqvCVLhKoaIVGyHjoTVHurpGlg(2FJ8GuIn0b4TjX34M2b(auIDyIVVqeJXlfIT9GyTxitBIJbyQbI4PLeNJfJcioH0WqiFBINwsCQwxcVaCIhGsCVbXaDK3TK4fqCSeduyGISj2iXsXCq82ehywIxaX4lqjogGPgO6p(3G9FUFdTNSIk)y7BaH0dgBVON3GcVn)3i83yEHV93aPdWBZt7M2b(a0VX7(RONyaMAG(3i834b8qb(8nIPODur6a8280UPDGpaTQ9KvujXxjwUrfzpYfZbZcKhXX7kqHbkYEYkkXxjgjQLYjgGPgOkU3YdshaXxqm2)gsf9aUy4B)nmSxqqmw7GhKheBOdWBtIVXnTd8bOe)2w6HVnXXsC(QksSrILI5GyirI9M48AtO)4FZL9Z9BO9Kvu5hBFJTl3ppmVVHWFJ5f(2FdCVLNSYGIVHurpGlg(2FJTl3ppmpIXN8veXHTs88cFBI3UCNyi0KvuILqaVnj(zpDRfVnjEAjX9gepiIhIbQjuzaepVW3U(JF8nEs0p3)nc)Z9BO9Kvu5hBFJ5f(2FdXfJcoEddH8T)gsf9aUy4B)nYdsjohlgfqCcPHHq(2eJXdBIt16s4fGxjgRAlsIHxaXPADj8cWj(T4kI4fgM43Uf5IPj2BIdBL4wfsbXcNsIr6BBjI4nSvaghPedHuI3M4NKyOUOieXHTsSyzURaIDeXIdiiEHjoSvIZ)oWNM43kq7PdljEbe7Weh2kqjgJxke3BqCMs80ByRaIt16sItOaiXW3M4W2red7M2rL48kcfxmiowIr37hXHTsCzqbXIlgfqS3WqiFBIxyIdBLyy30oiowIfSUKyfajg(2edVaI7TjwO(DGpnQ(nEapuGpFdrGROOI0c8rCXOGJ3WqiFBIVsC6eNbbdxfSUeEb4virITAL4Bj(Tc0E6OM)DGpnXxj(TBrUy6QG1Lhfajg(2vGIpEJi(IKelCkj2QvIZweI4Red7M2XbO4J3iIZjXVDlYftxfSU8OaiXW3Ucu8XBeXPr8vItNyy30ooafF8gr8fjj(TBrUy6QG1Lhfajg(2vGIpEJiglel8Li(kXVDlYftxfSU8OaiXW3Ucu8XBeX5mjXMpjX5DIfAITALyy30ooafF8gr8fe)2TixmDvCXOGJ3WqiF7QecmHVnXwTsmSBAhhGIpEJioNe)2TixmDvW6YJcGedF7kqXhVreJfIf(seB1kXVvG2th18Vd8Pj2QvIZGGHRzLDLfiuuHejoTF8Vb7)C)gApzfv(X23qQOhWfdF7VrEqkXyBKMkXEJCPs8ctCQUCIHxaXHTsmSdqbXqiL4fq82eJ1jI4bouaXHTsmSdqbXqiTsCI5HnX34M2bXx(OeBVfjXWlG4uD51Vrp463a5nmu5ywgPpXcqNSrAQNf(aRG95X9VXd4Hc85BKbbdxfSUeEb4virITAL4WXvIVGyHtjXxjoDIVL43kq7PJA7M2XbEuIt7BmVW3(BG8ggQCmlJ0NybOt2in1ZcFGvW(84(p(3Cz)C)gApzfv(X23yEHV93aE0Jj0aK(0OVHurpGlg(2FJ8GuIV8rjwOcAasFAeXBtmwNiIxOa5sL4fM4uTUeEb4vIZdsj(YhLyHkObi9PLiI9M4uTUeEb4e7WeFFHi2EeOeREyRaIfQaRaL4eslWnxWe(2eVaIVCxlsIxyIXwzrOfhvjoXgpigEbel3arCSeNPedjsCMcVaL45fUGj82K4lFuIfQGgG0NgrCSeJpcjh3rkXHTsCgemC9B8aEOaF(g3sCgemCvW6s4fGxHej(kXPt8Te)2TixmDvW6YtSaG2rfsKyRwj(wIJPODufSU8elaODu1EYkQK40i(kXPtSGb4twrRYnqhirIVsmsulLtmatnqvbdUOd83jwONnXjjwyITAL45fUa9i3OkyWfDG)oXc9SjojXirTuoXam1avfm4IoWFNyHE2eFLyKOwkNyaMAGQcgCrh4VtSqpBIVGyHjonITAL4miy4QG1LWlaVcjs8vItNy0cvY8wwnbRa94Ta3Cbt4Bx1EYkQKyRwjgTqLmVLvyxlYZcFYklcT4OQ2twrLeN2p(3i0)C)gApzfv(X23yEHV93a3BP5GROVX7(RONyaMAG(3i834b8qb(8n8gnTh3joNeJvNsIVsC6eNoXcgGpzfToLYrUb6ajs8vItN4Bj(TBrUy6QG1Lhfajg(2virITAL4BjoMI2r1gQnvG3MhbRlRApzfvsCAeNgXwTsCgemCvW6s4fGxHejonIVsC6eFlXXu0oQ2qTPc828iyDzv7jROsITALyPMbbdxTHAtf4T5rW6YkqXhVreFbXVbfNWXvITAL4BjodcgUkyDj8cWRqIeNgXxjoDIVL4ykAhvKoaVnpTBAh4dqRApzfvsSvReJe1s5edWuduf3B5bPdG4Cs8LioTVHurpGlg(2FJ8GuIXkElnhCfrmgBTjEkfIVmIt0MlI4bOedjAjXlG47leXdqj2BIt16s4fGxjoH2iiGsmwfuBQaVnjovRljgJxkeJcVuiotjgsKym2AtCyRe)guqC44kXWE7iBfvj2iwrIHqEBs8eeFjSqCmatnqeJXdBIn0b4TjX34M2b(a06p(3CPFUFdTNSIk)y7BmVW3(Ba12B5(PxbZ3qQOhWfdF7VrEqkX5PT3YDIVzfmeVnXyDISKy7Ti92K4mGRWL7ehlXygpigEbelUyuaXEddH8TjEbepsjXiXbtJQFJhWdf4Z3iDItN4BjgmU8Oc0oQJuIQqIeFLyW4YJkq7OosjQ6nXxqm2tjXPrSvRedgxEubAh1rkrvGIpEJi(IKel8Li2QvIbJlpQaTJ6iLOQecmHVnX5KyHVeXPr8vItN4miy4Q4IrbhVHHq(2virITAL43Uf5IPRIlgfC8ggc5Bxbk(4nI4lssSWPKyRwj(wIfbUIIkslWhXfJcoEddH8TjonIVsC6eFlXXu0oQ2qTPc828iyDzv7jROsITALyPMbbdxTHAtf4T5rW6YkKiXwTs8TeNbbdxfSUeEb4virIt7h)Bek)C)gApzfv(X23yEHV93iB3(SWNWwpd6PTuLFdPIEaxm8T)g5bPeVnXyDIiodkiwe4lWdhPedH82K4uTUK4ekasm8Tjg2bOWsIDyIHqQKyVrUujEHjovxoXBtSrUedHuIh4qbepelyDz2wcIHxaXVDlYfttScd7px73DINwsm8ci2gQnvG3MelyDjXqIHJRe7Wehtr7qL1VXd4Hc85BClXzqWWvbRlHxaEfsK4ReFlXVDlYftxfSU8OaiXW3Ucjs8vIrIAPCIbyQbQI7T8G0bq8felmXxj(wIJPODur6a8280UPDGpaTQ9KvujXwTsC6eNbbdxfSUeEb4virIVsmsulLtmatnqvCVLhKoaIZjXyN4ReFlXXu0oQiDaEBEA30oWhGw1EYkQK4ReNoXIavWX8jRcxfSU8KTLG4ReNoX3sSMcqUOOkRkU4DGoLZcK90pLyRwj(wIJPODuTHAtf4T5rW6YQ2twrLeNgXwTsSMcqUOOkRkU4DGoLZcK90pL4Re)2TixmDvXfVd0PCwGSN(PvGIpEJioNjjwyHc2j(kXsndcgUAd1MkWBZJG1LvirItJ40i2QvItN4miy4QG1LWlaVcjs8vIJPODur6a8280UPDGpaTQ9KvujXP9J)njUFUFdTNSIk)y7BmVW3(B8Ms5mVW3(uCu8nkoko9GRFJa4D(AG(X)gH8p3VH2twrLFS9nMx4B)nGlkY(bg44Biv0d4IHV93ipiL4lVOi7hyGdIxOa5sL4fMy8XBIF7wKlMgrCSeJpEhJ3eNQTmHxuIn2IaTdIZGGHRFJhWdf4Z3aTqLmVLvbBzcVOh0weODu1EYkQK4ReFlXzqWWvbRlHxaEfsK4ReFlXzqWWvXfJcoEddH8TRqI)4hFJa4D(AG(5(Vr4FUFdTNSIk)y7Biv0d4IHV93ipiL4TjgRteX5LrELdIJLytniorBUeh(lFVnjEAjXQqs0bkXXsCXBLyirIZ0iuaXy8WM4uTUeEb4FJEW1VHIlEhOt5Sazp9t)gpGhkWNVXB3ICX0vbRlpkasm8TRafF8grCotsSWyNyRwj(TBrUy6QG1Lhfajg(2vGIpEJi(cIXEI7BmVW3(BO4I3b6uolq2t)0F8Vb7)C)gApzfv(X23qQOhWfdF7VrUG7ehlXg37hXjeHAjIymEytCIwOSIsSrmV8vjXyDIqe7WelUiKNv0kXcXM4Y2MkGyy30oqeJXdBIXxGsCcrOwIigcPiINiuCXG4yjgDVFeJXdBIN(oXpjXlG4eFiuqmesj2J63OhC9B4n6bGIjRONuaA6ac)ivb(t)gpGhkWNVrgemCvW6s4fGxHej(kXzqWWvXfJcoEddH8TRqIeB1kXzlcr8vIHDt74au8XBeX5mjXypLeB1kXzqWWvXfJcoEddH8TRqIeFL43Uf5IPRcwxEuaKy4Bxbk(4nIySqSWxI4lig2nTJdqXhVreB1kXzqWWvbRlHxaEfsK4Re)2TixmDvCXOGJ3WqiF7kqXhVreJfIf(seFbXWUPDCak(4nIyRwjoDIF7wKlMUkUyuWXByiKVDfO4J3iIVijXcNsIVs8B3ICX0vbRlpkasm8TRafF8gr8fjjw4usCAeFLyy30ooafF8gr8fjjwyS6u(nMx4B)n8g9aqXKv0tkanDaHFKQa)P)4FZL9Z9BO9Kvu5hBFdPIEaxm8T)gg37hXg2QgeJvGq(JymEytCQwxcVa8Vrp463aFEtgqpiBvJdoeYFFJhWdf4Z34TBrUy6QG1Lhfajg(2vGIpEJi(cIfoLFJ5f(2Fd85nza9GSvno4qi)9J)nc9p3VH2twrLFS9n6bx)gOfQu0i828aGYU)nE3Ff9edWud0)gH)gZl8T)gOfQu0i828aGYU)nEapuGpFJmiy4Q4IrbhVHHq(2virITAL4Bjwe4kkQiTaFexmk44nmeY3MyRwjwtbixuuLvK9ixmQ8SGSZcFIfGRD8nKk6bCXW3(ByCVFeN4fk7oXy8WM4CSyuaXjKggc5BtmeAmvljgFYxjgbbuIJLyu7IkXHTsCzXOOGySQCqCmatnQeNy2AtmesLeJXdBInSh5IrLelebzeVWeN7cW1oSK4eFiuqmesjEBIX6er8Gigh6zt8GiwCripRO1F8V5s)C)gApzfv(X23qQOhWfdF7VrEqkXyBKMkXEJCPs8ctCQUCIHxaXHTsmSdqbXqiL4fq82eJ1jI4bouaXHTsmSdqbXqiTsSH9ccIFo4b5bXomXcwxsScGedFBIF7wKlMMyhrSWPer8cigFbkXdM5E9B0dU(nqEddvoMLr6tSa0jBKM6zHpWkyFEC)B8aEOaF(gVDlYftxfSU8OaiXW3Ucu8XBeXxKKyHt53yEHV93a5nmu5ywgPpXcqNSrAQNf(aRG95X9F8VrO8Z9BO9Kvu5hBFdPIEaxm8T)g5bPeBypYfJkjwicYiEHjo3fGRDqmgBTjU3GyVjovRlHxaULeVaI9M4mnWOAtCQwxsm22sq8BqbIyVjovRlHxaE9B0dU(nq2JCXOYZcYol8jwaU2X34b8qb(8nUL4miy4QG1LWlaVcjsSvReNoXIavWX8jRcxfSU8KTLG40(gZl8T)gi7rUyu5zbzNf(elax74h)BsC)C)gApzfv(X23qQOhWfdF7VrEqkXfhfeVWeVTqaesjwo4JPsCa8oFnqeVD5oXomXyvqTPc82K4uTUK4ePzqWWe7iINx4culjEbeFFHiEakX9gehtr7qLe7DSe7r9BmVW3(B8Ms5mVW3(uCu8nEapuGpFJ0j(wIJPODuTHAtf4T5rW6YQ2twrLeB1kXsndcgUAd1MkWBZJG1LvirItJ4ReNoXzqWWvbRlHxaEfsKyRwj(TBrUy6QG1Lhfajg(2vGIpEJi(cIfoLeN23O4O40dU(nK4MNa4D(AG(X)gH8p3VH2twrLFS9nMx4B)nGq6Xdfh9nKk6bCXW3(BKifEGkbXWtPKnV8jgEbedHMSIsShkokfjopiL4Tj(TBrUyAI9M4fivaXz3joaENVgeJkBu)gpGhkWNVrgemCvW6s4fGxHej2QvIZGGHRIlgfC8ggc5BxHej2QvIF7wKlMUkyD5rbqIHVDfO4J3iIVGyHt5p(X3iB3(N7)gH)5(n0EYkQ8JTVXd4Hc85BGe1s5edWuduf3B5bPdG4CMK4l7BmVW3(BmON2svEYkdk(X)gS)Z9BO9Kvu5hBFJhWdf4Z3ajQLYjgGPgO6GEAlv5PxbdXxqSWeFLyKOwkNyaMAGQ4ElpiDaeFbXctmwioMI2rfPdWBZt7M2b(a0Q2twrLFJ5f(2FJb90wQYtVcMF8JVHiqFlE2e)C)3i8p3VH2twrLFS9nEapuGpFdGIpEJioNeFzPmLFJ5f(2FdXfJcoywG8aVGWdiP(J)ny)N73q7jROYp2(gpGhkWNVbAHkzElRIqOaQOhfajg(2vTNSIkj2QvIrlujZBzvWwMWl6bTfbAhvTNSIk)gZl8T)gWffz)adC8J)nx2p3VH2twrLFS9nEapuGpFJBjodcgUISh5IbEb4viXVX8cF7VbYEKlg4fG)J)nc9p3VH2twrLFS9nEapuGpFdVrt7X9QuH9NheFbXcFPVX8cF7VXaEtRNybaTJF8V5s)C)gApzfv(X23OhC9BGSh5IrLNfKDw4tSaCTJVX8cF7VbYEKlgvEwq2zHpXcW1o(X)gHYp3VH2twrLFS9nwXVbsJVX8cF7VHGb4twr)gcMcK(nW(3qWao9GRFdCVLhKoGZdkwy4F8VjX9Z9BmVW3(BiyWfDG)oXc9S)gApzfv(X2p(Xp(gcuaY3(Fd2tj2foLjoHX(3aZaAVnrFJelVs8Etc5gHQuKyIZ1wj2Xfxqqm8cioHfb6BXZMiHjgOPaKdujXOfxjEGIfFcvs8ZEAtfvjlYBEReJ9uKySEBbkiujXjmAHkzElRcHsyIJL4egTqLmVLvHqvTNSIktyItxyHuAvYI8M3kXypfjgR3wGccvsCcJwOsM3YQqOeM4yjoHrlujZBzviuv7jROYeM4jioHkeZBeNUWcP0QKfKfjwEL49MeYncvPiXeNRTsSJlUGGy4fqCc)KOeMyGMcqoqLeJwCL4bkw8jujXp7PnvuLSiV5TsSqjfjgR3wGccvsCchaVZxJ6K9QVDlYftNWehlXj8B3ICX01j7LWeNUWcP0QKf5nVvIfYPiXy92cuqOsIty0cvY8wwfcLWehlXjmAHkzElRcHQApzfvMWeNUWcP0QKfKfjeCXfeQKyHmXZl8TjU4Oavjl(gir99Vb7xsi)neblSx0VrQtnXg2JCXqCoaUIcYIuNAITaQCNySJvBjXypLyxyYcYIuNAIXA7PnvukswK6utSqaX5IrN8jovRljo3fa0oigJT2ehdWudIFluhiIhGsm8cEQSswK6utSqaX5aOH2sILBGiEakXqIeJXwBIJbyQbI4bOe)klsjowIL3920sIrlXH9ee3q5RiIhGsmk8sHyG(wCCTLQSswqwK6utCcviPpOqLeNPWlqj(T4ztqCMA6nQsCE9EQyGiU3wiWEa4WqfINx4BJiE7Y9kzX8cFBuveOVfpBcSKmbIlgfCWSa5bEbHhqs1shojqXhVr58YszkjlMx4BJQIa9T4ztGLKjaUOi7hyGdlD4KOfQK5TSkcHcOIEuaKy4BB1kAHkzElRc2YeErpOTiq7GSyEHVnQkc03INnbwsMaK9ixmWla3sho5TzqWWvK9ixmWlaVcjswmVW3gvfb6BXZMaljtWaEtRNybaTdlD4KEJM2J7vPc7ppUq4lrwmVW3gvfb6BXZMaljtaespEO4w2dUMezpYfJkpli7SWNyb4AhKfZl8TrvrG(w8SjWsYeiya(Kvul7bxtI7T8G0bCEqXcdB5kMePHLcMcKMe7KfZl8TrvrG(w8SjWsYeiyWfDG)oXc9SjlilsDQjohB4BJilMx4BJsI8I2pLSyEHVnkP4g(2w6WjZGGHRcwxcVa8kKOvRzqWWvXfJcoEddH8TRqIKfZl8TryjzcemaFYkQL9GRjLBGoqIwUIjrAyPGPaPjtxUrfzpYfZbZcKhXX7A4V8920Q1yaMAudhxpXEKUMZKcDAxtxUrvWGl6a)DIf6zxd)LV3MwTgdWuJA446j2J01CMuOKgzX8cFBewsMabdWNSIAzp4AYPuoYnqhirlxXKinSuWuG0KcgGpzfTk3aDGeVk3OkvbleWBZJyzmH0A4V892KSi1eBediigc5TjXg6a82K4BCt7aFakXtq8LHfIJbyQbI4fqSqJfIDyIVVqepaLyVjovRlHxaozX8cFBewsMabdWNSIAzp4AsKoaVnpTBAh4dqppOyHHTCftI0WsbtbstIe1s5edWuduf3B5bPd4cSJLmiy4QG1LWlaVcjswKAIX6DlYfttCo2TqCQgGpzf1sIZdsLehlXI7wiotHxGs88cxWeEBsSG1LWlaVsmwdbaAhL7edHujXXs8B7aSfIXyRnXXs88cxWekXcwxcVaCIX4HnXE)wCVnjEKsuLSyEHVncljtGGb4twrTShCnP4ULd8copjYYvmjsdlfmfin5B3ICX0vbRlpkasm8TRqIxt)wW4YJkq7OosjQcjA1kyC5rfODuhPevLqGj8TZzsHtPvRGXLhvG2rDKsufO4J3OlskCkXYLY7Phtr7OAd1MkWBZJG1LvTNSIkTA9Tc0E6OM)DGpDAPDn90bJlpQaTJ6iLOQ3xG9uA1ksulLtmatnqvbRlpkasm8TVi5LsZQ1ykAhvBO2ubEBEeSUSQ9KvuPvRVvG2th18Vd8Pt7A63cGAfEbMAfjARafDSha(23RAka5IIQ0Q10F7wKlMUkUyuWXByiKVDfO4J3OCM08jR4JqkVFzwTMbbdxfxmk44nmeY3UcjA1A2IqxHDt74au8XBuotI9lLwAKfZl8TryjzcGDGMv2vAPdNmdcgUkyDj8cWRqIKfZl8TryjzcYuasb57TPLoCYmiy4QG1LWlaVcjswKAIZdsjoV5M2rcJi2ciPjU2bXomXHTcuIhGsm2jEbeJVaL4yaMAGSK4fq8iLiIhG2jCqmsCW0EBsm8cigFbkXH90eN4UeQswmVW3gHLKjO4M2b6K4djnX1oS0HtIe1s5edWuduT4M2b6K4djnX1oUij2TAn9BbJlpQaTJ6iLOQkKCuGSAfmU8Oc0oQJuIQEFrI7sPrwmVW3gHLKjy6NIcWuoVPuS0HtMbbdxfSUeEb4virYI5f(2iSKmbVPuoZl8Tpfhfw2dUM8H5rwmVW3gHLKjaa1N5f(2NIJcl7bxtIpEtwqwK6utCELJ8gXXsmesjgJT2eJTDBIxyIdBL48c90wQsIDeXZlCbkzX8cFBunB3o5GEAlv5jRmOWshojsulLtmatnqvCVLhKoGCM8YilMx4BJQz72yjzcg0tBPkp9kyS0HtIe1s5edWuduDqpTLQ80RG5cHVIe1s5edWuduf3B5bPd4cHXsmfTJkshG3MN2nTd8bOvTNSIkjlilsDQjgRteISi1eNhKsCowmkG4esddH8TjgJh2eNQ1LWlaVsmw1wKedVaIt16s4fGt8BXveXlmmXVDlYfttS3eh2kXTkKcIfoLeJ032seXByRamosjgcPeVnXpjXqDrriIdBLyXYCxbe7iIfhqq8ctCyReN)DGpnXVvG2thws8ci2HjoSvGsmgVuiU3G4mL4P3WwbeNQ1LeNqbqIHVnXHTJig2nTJkX5vekUyqCSeJU3pIdBL4YGcIfxmkGyVHHq(2eVWeh2kXWUPDqCSelyDjXkasm8TjgEbe3BtSq97aFAuLSyEHVnQ(KOKIlgfC8ggc5BBPdNue4kkQiTaFexmk44nmeY3(A6zqWWvbRlHxaEfs0Q1BFRaTNoQ5Fh4tF9TBrUy6QG1Lhfajg(2vGIpEJUiPWP0Q1SfHUc7M2XbO4J3OC(2TixmDvW6YJcGedF7kqXhVrPDnDy30ooafF8gDrY3Uf5IPRcwxEuaKy4Bxbk(4nclcFPRVDlYftxfSU8OaiXW3Ucu8XBuotA(K5DH2Qvy30ooafF8gDXB3ICX0vXfJcoEddH8TRsiWe(2wTc7M2XbO4J3OC(2TixmDvW6YJcGedF7kqXhVryr4lz16BfO90rn)7aFARwZGGHRzLDLfiuuHetJSi1eNhKsSHx0(PeVnXyDIiowIfb7Jydv0gsi8egrCoa7Rm4t4BxjlsnXZl8Tr1NeHLKja5fTFQLXam144WjbqTcVatTIurBiHWrhrW(kd(e(2vnfGCrrvEn9yaMAuD0zKsRwJbyQrvQzqWW13GcVnRaDErAKfPM48GuIX2invI9g5sL4fM4uD5edVaIdBLyyhGcIHqkXlG4TjgRteXdCOaIdBLyyhGcIHqAL4eZdBIVXnTdIV8rj2ElsIHxaXP6YRKfZl8Tr1NeHLKjacPhpuCl7bxtI8ggQCmlJ0NybOt2in1ZcFGvW(84ULoCYmiy4QG1LWlaVcjA1A446fcNYRPF7BfO90rTDt74apAAKfPM48GuIV8rjwOcAasFAeXBtmwNiIxOa5sL4fM4uTUeEb4vIZdsj(YhLyHkObi9PLiI9M4uTUeEb4e7WeFFHi2EeOeREyRaIfQaRaL4eslWnxWe(2eVaIVCxlsIxyIXwzrOfhvjoXgpigEbel3arCSeNPedjsCMcVaL45fUGj82K4lFuIfQGgG0NgrCSeJpcjh3rkXHTsCgemCLSyEHVnQ(KiSKmbWJEmHgG0NgzPdN82miy4QG1LWlaVcjEn9BF7wKlMUkyD5jwaq7OcjA16TXu0oQcwxEIfa0oQApzfvM210fmaFYkAvUb6ajEfjQLYjgGPgOQGbx0b(7el0ZoPWwToVWfOh5gvbdUOd83jwONDsKOwkNyaMAGQcgCrh4VtSqp7RirTuoXam1avfm4IoWFNyHE2xiCAwTMbbdxfSUeEb4viXRPJwOsM3YQjyfOhVf4MlycF7Q2twrLwTIwOsM3YkSRf5zHpzLfHwCuv7jROY0ilsnX5bPeJv8wAo4kIym2At8ukeFzeNOnxeXdqjgs0sIxaX3xiIhGsS3eNQ1LWlaVsCcTrqaLySkO2ubEBsCQwxsmgVuigfEPqCMsmKiXyS1M4Wwj(nOG4WXvIH92r2kQsSrSIedH82K4ji(syH4yaMAGigJh2eBOdWBtIVXnTd8bOvYI5f(2O6tIWsYeG7T0CWvKLV7VIEIbyQbkPWw6Wj9gnTh3ZjwDkVME6cgGpzfToLYrUb6ajEn9BF7wKlMUkyD5rbqIHVDfs0Q1BJPODuTHAtf4T5rW6YQ2twrLPLMvRzqWWvbRlHxaEfsmTRPFBmfTJQnuBQaVnpcwxw1EYkQ0QvPMbbdxTHAtf4T5rW6YkqXhVrx8guCchxTA92miy4QG1LWlaVcjM210VnMI2rfPdWBZt7M2b(a0Q2twrLwTIe1s5edWuduf3B5bPdiNxknYIutCEqkX5PT3YDIVzfmeVnXyDISKy7Ti92K4mGRWL7ehlXygpigEbelUyuaXEddH8TjEbepsjXiXbtJQKfZl8Tr1NeHLKjaQT3Y9tVcglD4KPN(TGXLhvG2rDKsufs8kyC5rfODuhPev9(cSNY0SAfmU8Oc0oQJuIQafF8gDrsHVKvRGXLhvG2rDKsuvcbMW3oNcFP0UMEgemCvCXOGJ3WqiF7kKOvRVDlYftxfxmk44nmeY3Ucu8XB0fjfoLwTERiWvuurAb(iUyuWXByiKVDAxt)2ykAhvBO2ubEBEeSUSQ9KvuPvRsndcgUAd1MkWBZJG1LvirRwVndcgUkyDj8cWRqIPrwKAIZdsjEBIX6erCguqSiWxGhosjgc5TjXPADjXjuaKy4BtmSdqHLe7WedHujXEJCPs8ctCQUCI3MyJCjgcPepWHciEiwW6YSTeedVaIF7wKlMMyfg2FU2V7epTKy4fqSnuBQaVnjwW6sIHedhxj2HjoMI2HkRKfZl8Tr1NeHLKjiB3(SWNWwpd6PTuLw6WjVndcgUkyDj8cWRqIxV9TBrUy6QG1Lhfajg(2viXRirTuoXam1avX9wEq6aUq4R3gtr7OI0b4T5PDt7aFaAv7jROsRwtpdcgUkyDj8cWRqIxrIAPCIbyQbQI7T8G0bKtSF92ykAhvKoaVnpTBAh4dqRApzfvEnDrGk4y(KvHRcwxEY2sCn9B1uaYffvzvXfVd0PCwGSN(PwTEBmfTJQnuBQaVnpcwxw1EYkQmnRw1uaYffvzvXfVd0PCwGSN(PxdG35RrvXfVd0PCwGSN(P13Uf5IPRafF8gLZKcluW(vPMbbdxTHAtf4T5rW6YkKyAPz1A6zqWWvbRlHxaEfs8AmfTJkshG3MN2nTd8bOvTNSIktJSyEHVnQ(KiSKmbVPuoZl8Tpfhfw2dUMmaENVgiYIutCEqkXxErr2pWaheVqbYLkXlmX4J3e)2TixmnI4yjgF8ogVjovBzcVOeBSfbAheNbbdxjlMx4BJQpjcljtaCrr2pWahw6WjrlujZBzvWwMWl6bTfbAhxVndcgUkyDj8cWRqIxVndcgUkUyuWXByiKVDfsKSGSi1PMySEqbXjMTxuIX6bfEBs88cFBuLydniEcITDtBfqSiWxGh3jowIr2lii(5GhKhe7DOaaKyq8BBPh(2iI3MySI3sIn0bKGlVm3jlsnX5bPeBOdWBtIVXnTd8bOe7WeFFHigJxkeB7bXAVqM2ehdWudeXtljohlgfqCcPHHq(2epTK4uTUeEb4epaL4EdIb6iVBjXlG4yjgOWafztSrILI5G4TjoWSeVaIXxGsCmatnqvYI5f(2O6dZljshG3MN2nTd8bOwcH0dgBVON3GcVntkSLV7VIEIbyQbkPWw6WjtxWa8jROvKoaVnpTBAh4dqppOyHHVERGb4twrRI7woWl48KO0SAnD5gvK9ixmhmlqEehVRafgOi7jROxrIAPCIbyQbQI7T8G0bCHWPrwKAInSxqqmw7GhKheBOdWBtIVXnTd8bOe)2w6HVnXXsC(QksSrILI5GyirI9M48AtOKfZl8Tr1hMhwsMaKoaVnpTBAh4dqTecPhm2ErpVbfEBMuylF3Ff9edWudusHT0Htgtr7OI0b4T5PDt7aFaAv7jROYRYnQi7rUyoywG8ioExbkmqr2twrVIe1s5edWuduf3B5bPd4cStwKAI3UC)8W8igFYxreh2kXZl8TjE7YDIHqtwrjwcb82K4N90Tw82K4PLe3Bq8GiEigOMqLbq88cF7kzX8cFBu9H5HLKja3B5jRmOWYTl3ppmVKctwqwmVW3gvL4MNa4D(AGscH0JhkUL9GRjLdiF8D7JuF5FoIqbqrpTFkzX8cFBuvIBEcG35RbcljtaespEO4w2dUMeb1zLDLNbxd77OGSyEHVnQkXnpbW781aHLKjacPhpuCl7bxtAwUlAFw4ZGqoUxMW3MSyEHVnQkXnpbW781aHLKjacPhpuCl7bxtkb6iHDGEeOiKwililsDQjgRmEtCELJ8MLeJSxOIK43kqbepLcXGPnveXlmXXam1ar80sIrpThGViYI5f(2Ok(4DY3ukN5f(2NIJcl7bxtMTBBPdNmdcgUMTBFw4tyRNb90wQYkKizX8cFBufF8gljtG0rIA5GpM(Zsho5TXam1O6OJyzURaYIutCEqkXPADjXjuaKy4Bt82e)2TixmnXI7w82K4jiUOdkiwOtjXEJM2J7eNbfe3BqSdt89fIymEPq8kqbVrKyVrt7XDI9M4uD5vIXkt(kXiiGsmYEKlgyxBzcW9wMPTubepTKySI3sIXwzqbXoI4Tj(TBrUyAIZu4fOeNQeAL4eIzVaLyXDlEBsmqrbWFHVnIyhMyiK3MeBypYfdCzWvIZbWr4epTKySPTube7iIxOOswmVW3gvXhVXsYeiyD5rbqIHVTLoCsbdWNSIwf3TCGxW5jrxt3B00EC)IKcDkTAvuJkSRTSoVWfOxbqTcVatTISh5IbUm46re4i8QMcqUOOkVE7B3ICX0vCVLNSYGIkK41BF7wKlMUISh5I5GzbYJuNWUcjM2109gnTh3ZzsH8LSAnMI2rfPdWBZt7M2b(a0Q2twrLxfmaFYkAfPdWBZt7M2b(a0Zdkwy40UE7B3ICX0vyxBzfs8A63(2TixmDf3B5jRmOOcjA1ksulLtmatnqvCVLhKoGlWEAKfPMySYKVsmccOeFFHiwekigsKyJelfZbX5LrELdI3M4WwjogGPge7WeNyGjSHHkeF5JcCLyh1jCq88cxGsmgBTjg2nTdVnjwyHGlJ4yaMAGQKfZl8Trv8XBSKmbi7rUyoywG8ioEBPdNmdcgUcp6XeAasFAufs86TsndcgUIbmHnmu5apkW1kK4vKOwkNyaMAGQ4ElpiDa5uOjlMx4BJQ4J3yjzcEtPCMx4BFkokSShCn5tIilsnXyvUPnX5a4lWJ7eJv8wsSHoaINx4BtCSeduyGISjorBUiIX4HnXiDaEBEA30oWhGswmVW3gvXhVXsYeG7T8G0by57(RONyaMAGskSLoCYykAhvKoaVnpTBAh4dqRApzfvEfjQLYjgGPgOkU3YdshWfcgGpzfTI7T8G0bCEqXcdF9w5gvK9ixmhmlqEehVRH)Y3BZR3(2TixmDf21wwHejlsnX5aOWkG4yjgcPeNObVNW3M48YiVYbXomXtFN4eT5sSJiU3GyiXkzX8cFBufF8gljtGCW7j8TT8D)v0tmatnqjf2sho5TcgGpzfToLYrUb6ajswKAIZdsj2WEKlgItSfijor6e2e7WedH82Kyd7rUyGldUsCoaocN4PLeNPTubeJXlfIvHKOduILqaVnjoSvIBvifeB(KvYI5f(2Ok(4nwsMaK9ixmhmlqEK6e2w6Wjf1Oc7AlRZlCb6vauRWlWuRi7rUyGldUEebocVQPaKlkQYRIAuHDTLvGIpEJYzsZNKSi1eNxfmZDeXqiLyCVLzLbfiIDyIFJOOkjEAjX2qTPc82KybRlj2redjs80sIHqEBsSH9ixmWLbxjohahHt80sIZ0wQaIDeXqIvIjoVKsp8TNs5ULe)guqmU3YSYGcIDyIVVqeJzHksIZuIH6jROehlXMAqCyRedC4G4S7eJz8WBtIhInFYkzX8cFBufF8gljtaU3YtwzqHLoCY0F7wKlMUI7T8KvguuF2dWurxi810LAgemC1gQnvG3MhbRlRqIwTEBmfTJQnuBQaVnpcwxw1EYkQmnRwf1Oc7AlRafF8gLZKVbfNWXvSy(KPDvuJkSRTSoVWfOxbqTcVatTISh5IbUm46re4i8QMcqUOOkVkQrf21wwbk(4n6I3GIt44kzrQjopiL4uTUKySTLG4ji22nTvaXIaFbECNymEytmwfuBQaVnjovRljgsK4yjwOjogGPgiljEbeVHTcioMI2bI4Tj2i3kzX8cFBufF8gljtGG1LNSTew6Wj9gnTh3ZzsH8LUgtr7OAd1MkWBZJG1LvTNSIkVgtr7OI0b4T5PDt7aFaAv7jROYRirTuoXam1avX9wEq6aYzsHIvRPNEmfTJQnuBQaVnpcwxw1EYkQ86TXu0oQiDaEBEA30oWhGw1EYkQmnRwrIAPCIbyQbQI7T8G0bKu40ilsnXjA7eoigcPeNivWcb82K4CugtiLyhM47leXVPj2udI9owIt16s4fGtS3OqhPLeVaIDyIn0b4TjX34M2b(auIDeXXu0oujXtljgJxkeB7bXAVqM2ehdWuduLSyEHVnQIpEJLKjqQcwiG3MhXYycPw6WjthOWafzpzf1QvVrt7X9lsCxkTRPFRGb4twrRI7woWl48KiRw9gnTh3ViPq(sPDn9BJPODur6a8280UPDGpaTQ9KvuPvRPhtr7OI0b4T5PDt7aFaAv7jROYR3kya(Kv0kshG3MN2nTd8bONhuSWWPLgzrQjopiL4uHnI3MySore7WeFFHiwUDche3QkjowIFdkiorQGfc4TjX5OmMqQLepTK4WwbkXdqjUOieXH90el0ehdWudeXluqC6xIymEyt8BBjKhPvjlMx4BJQ4J3yjzceSU8KTLWshojsulLtmatnqvCVLhKoGCMUqJL32sipQshH2E64Op7vrvTNSIkt7Q3OP94EotkKV01ykAhvKoaVnpTBAh4dqRApzfvA16TXu0oQiDaEBEA30oWhGw1EYkQKSi1eNhKsSH9ixmeNylqMIeNiDcBIDyIdBL4yaMAqSJiEYwOG4yjw6kXlG47leX2JaLyd7rUyGldUsCoaocNynfGCrrvsmgpSjgR4TmtBPciEbeBypYfdSRTK45fUaTswmVW3gvXhVXsYeGSh5I5GzbYJuNW2Y39xrpXam1aLuylD4KPhdWuJQToLWUk(ICI9uEfjQLYjgGPgOkU3Ydshqof60SAnDrnQWU2Y68cxGEfa1k8cm1kYEKlg4YGRhrGJWRAka5IIQmnYIutCEqkXgqaG2sfqCSeJvgzRieXBt8qCmatnioSNGyhrS56TjXXsS0vING4Wwjg4M2bXHJRvYI5f(2Ok(4nwsMaeeaOTubNyp4JSveYY39xrpXam1aLuylD4KXam1OgoUEI9iDnNy)sxZGGHRcwxcVa8QCX0KfPM48GuIt16sIZDbaTdI3UCNyhMyJelfZbXtljov5s8auINx4cuINwsCyRehdWudIXSDchelDLyjeWBtIdBL4N90TwQKfZl8Trv8XBSKmbcwxEIfa0oS8D)v0tmatnqjf2shoPGb4twrRYnqhiXRXam1OgoUEI9iD9Il7A6zqWWvbRlHxaEvUyARwZGGHRcwxcVa8kqXhVr58TBrUy6QG1LNSTevGIpEJs768cxGEKBufm4IoWFNyHE2jrIAPCIbyQbQkyWfDG)oXc9SVIe1s5edWuduf3B5bPdiNPFjSKUqjVhtr7OgyCuCw4d8eAv7jROY0sJSyEHVnQIpEJLKja3BzM2sfyPdNuUrvWGl6a)DIf6zxd)LV3MxtpMI2rfPdWBZt7M2b(a0Q2twrLxrIAPCIbyQbQI7T8G0bCHGb4twrR4ElpiDaNhuSWWwTk3OISh5I5GzbYJ44Dn8x(EBM210Vfa1k8cm1kYEKlg4YGRhrGJWRAka5IIQ0Q15fUa9i3OkyWfDG)oXc9SVi57(ROhTvCxrPrwKAIZdsj2iXsXermgpSjohJ3zaDYxbeNd0uWjgQlkcrCyRehdWudIX4LcXzkXzAzXqm2tPqyeNPWlqjoSvIF7wKlMM43IRiIZMx(vYI5f(2Ok(4nwsMaK9ixmhmlqEK6e2w6WjbqTcVatTkoENb0jFfCertbVQPaKlkQYRcgGpzfTk3aDGeVgdWuJA446j2J4loypLxK(B3ICX0vK9ixmhmlqEK6e2vjeycFBSy(KPrwKAIZdsj2WEKlgIXAWGSjEBIX6ermuxueI4WwbkXdqjEKseXE)wCVnRKfZl8Trv8XBSKmbi7rUyopWGST0HtcgxEubAh1rkrvVVq4uswKAIZdsjgR4TKydDaehlXVTrq4kXjAa5tCU2lKPDGiweSpeXBtCEjetOvIZviMiHiXy92WoaNyhrCy7iIDeXdX2UPTciwe4lWJ7eh2ttmqLBeEBs82eNxcXekXqDrriILdiFId7fY0oqe7iINSfkiowIdhxjEHcYI5f(2Ok(4nwsMaCVLhKoalF3Ff9edWudusHT0HtIe1s5edWuduf3B5bPd4cbdWNSIwX9wEq6aopOyHHVMbbdxLdi)tyVqM2rfs0YN94DsHT07qbaiX4444Q0NqtkSLEhkaajghhoz4V8rxKe7KfPM48GuIXkElj(YlZDIJL432iiCL4enG8jox7fY0oqelc2hI4Tj2i3kX5ketKqKySEByhGtSdtCy7iIDeXdX2UPTciwe4lWJ7eh2ttmqLBeEBsmuxueIy5aYN4WEHmTdeXoI4jBHcIJL4WXvIxOGSyEHVnQIpEJLKja3B5bUm3T0HtMbbdxLdi)tyVqM2rfs8QGb4twrRYnqhirlF2J3jf2sVdfaGeJJJJRsFcnPWw6DOaaKyCC4KH)YhDrsSF9TBrUy6QG1LNSTevirYIutCEqkXyfVLeJTYGcIDyIVVqel3oHdIBvLehlXafgOiBIt0MlQsSrSIe)gu4TjXtqSqt8cigFbkXXam1armgpSj2qhG3MeFJBAh4dqjoMI2HkjEAjX3xiIhGsCVbXqiVnj2WEKlg4YGReNdGJWjEbeNd09NT)ioV5D(vKOwkNyaMAGQ4ElpiDaxK45seBQbI4Wwjg3BhhcN4fM4lr80sIdBL4gcptbeVWehdWuduL48QGwljwUe3BqSiqriIX9wMvguqmuhEH4PuiogGPgiIhGsSCJqLeJXdBItvUeJXwBIHqEBsmYEKlg4YGRelcCeoXomXzAlvaXoI4rW4LjROvYI5f(2Ok(4nwsMaCVLNSYGclD4KcgGpzfTk3aDGeVcgxEubAhv8vGIRDu9(I3GIt44kwsz9sxrIAPCIbyQbQI7T8G0bKZ0fASG98EmfTJkUJuW9Q2twrLyzEHlqpYnQcgCrh4VtSqp78EmfTJQi6(Z2FNI35x1EYkQelPJe1s5edWuduf3B5bPd4IepxkT8E6IAuHDTL15fUa9kaQv4fyQvK9ixmWLbxpIahHx1uaYffvzAPDn9BbqTcVatTISh5IbUm46re4i8QMcqUOOkTA923Uf5IPRWU2YkK4vauRWlWuRi7rUyGldUEebocVQPaKlkQsRwNx4c0JCJQGbx0b(7el0Z(IKV7VIE0wXDfLgzX8cFBufF8gljtGGbx0b(7el0Z2Y39xrpXam1aLuylD4KafgOi7jROxJbyQrnCC9e7r66fcfRwtpMI2rf3rk4Ev7jROYRYnQi7rUyoywG8ioExbkmqr2twrtZQ1miy4kuddbkEBEKdi)wrOkKizrQj2quF(ui(TT0dFBIJLyuSIe)gu4TjXgjwkMdI3M4fgwiigGPgiIXyRnXWUPD4TjXxgXlGy8fOeJI5LVkjgFZqepTKyiK3MeNd09NT)ioV5D(epTK4BeI5smwXrk4ELSyEHVnQIpEJLKjazpYfZbZcKhXXBlD4KafgOi7jROxJbyQrnCC9e7r66fc91BJPODuXDKcUx1EYkQ8AmfTJQi6(Z2FNI35x1EYkQ8ksulLtmatnqvCVLhKoGlWozrQjwOUQIeBKyPyoigsK4TjEqeJp9DIJbyQbI4brS4IqEwrTKyvi9uXGym2AtmSBAhEBs8Lr8cigFbkXOyE5RsIX3meXy8WM4CGU)S9hX5nVZVswmVW3gvXhVXsYeGSh5I5GzbYJ44TLV7VIEIbyQbkPWw6Wjbkmqr2twrVgdWuJA446j2J01le6R3gtr7OI7ifCVQ9Kvu51BtpMI2rfPdWBZt7M2b(a0Q2twrLxrIAPCIbyQbQI7T8G0bCHGb4twrR4ElpiDaNhuSWWPDn9BJPODufr3F2(7u8o)Q2twrLwTMEmfTJQi6(Z2FNI35x1EYkQ8ksulLtmatnqvCVLhKoGCMe7PLgzX8cFBufF8gljtaU3YdshGLV7VIEIbyQbkPWw6WjrIAPCIbyQbQI7T8G0bCHGb4twrR4ElpiDaNhuSWWw(ShVtkSLEhkaajghhhxL(eAsHT07qbaiX44Wjd)Lp6IKyNSyEHVnQIpEJLKja3B5bUm3T8zpENuyl9ouaasmoooUk9j0KcBP3HcaqIXXHtg(lF0fjX(13Uf5IPRcwxEY2suHejlsnX5bPeBKyPyIiEqexguqmqrlii2HjEBIdBLy8vGswmVW3gvXhVXsYeGSh5I5GzbYJuNWMSi1eNhKsSrILI5G4brCzqbXafTGGyhM4TjoSvIXxbkXtlj2iXsXerSJiEBIX6erwmVW3gvXhVXsYeGSh5I5GzbYJ44nzbzrQjopiL4TjgRteX5LrELdIJLytniorBUeh(lFVnjEAjXQqs0bkXXsCXBLyirIZ0iuaXy8WM4uTUeEb4KfZl8Tr1a4D(AGscH0JhkUL9GRjvCX7aDkNfi7PFQLoCY3Uf5IPRcwxEuaKy4Bxbk(4nkNjfg7wT(2TixmDvW6YJcGedF7kqXhVrxG9ehzrQjoxWDIJLyJ79J4eIqTermgpSjorluwrj2iMx(QKySoriIDyIfxeYZkALyHytCzBtfqmSBAhiIX4HnX4lqjoHiulredHueXtekUyqCSeJU3pIX4HnXtFN4NK4fqCIpekigcPe7rLSyEHVnQgaVZxdewsMaiKE8qXTShCnP3OhakMSIEsbOPdi8Juf4p1shozgemCvW6s4fGxHeVMbbdxfxmk44nmeY3UcjA1A2IqxHDt74au8XBuotI9uA1AgemCvCXOGJ3WqiF7kK413Uf5IPRcwxEuaKy4Bxbk(4nclcFPlGDt74au8XBKvRzqWWvbRlHxaEfs86B3ICX0vXfJcoEddH8TRafF8gHfHV0fWUPDCak(4nYQ10F7wKlMUkUyuWXByiKVDfO4J3OlskCkV(2TixmDvW6YJcGedF7kqXhVrxKu4uM2vy30ooafF8gDrsHXQtjzrQj24E)i2Ww1GySceYFeJXdBIt16s4fGtwmVW3gvdG35RbcljtaespEO4w2dUMeFEtgqpiBvJdoeYFw6WjF7wKlMUkyD5rbqIHVDfO4J3OleoLKfPMyJ79J4eVqz3jgJh2eNJfJcioH0WqiFBIHqJPAjX4t(kXiiGsCSeJAxujoSvIllgffeJvLdIJbyQrL4eZwBIHqQKymEytSH9ixmQKyHiiJ4fM4CxaU2HLeN4dHcIHqkXBtmwNiIheX4qpBIheXIlc5zfTswmVW3gvdG35RbcljtaespEO4w2dUMeTqLIgH3Mhau2DlF3Ff9edWudusHT0HtMbbdxfxmk44nmeY3UcjA16TIaxrrfPf4J4IrbhVHHq(2wTQPaKlkQYkYEKlgvEwq2zHpXcW1oilsnX5bPeJTrAQe7nYLkXlmXP6YjgEbeh2kXWoafedHuIxaXBtmwNiIh4qbeh2kXWoafedH0kXg2lii(5GhKhe7WelyDjXkasm8Tj(TBrUyAIDeXcNseXlGy8fOepyM7vYI5f(2OAa8oFnqyjzcGq6Xdf3YEW1KiVHHkhZYi9jwa6Knst9SWhyfSppUBPdN8TBrUy6QG1Lhfajg(2vGIpEJUiPWPKSi1eNhKsSH9ixmQKyHiiJ4fM4CxaU2bXyS1M4EdI9M4uTUeEb4ws8ci2BIZ0aJQnXPADjXyBlbXVbfiI9M4uTUeEb4vYI5f(2OAa8oFnqyjzcGq6Xdf3YEW1Ki7rUyu5zbzNf(elax7Wsho5TzqWWvbRlHxaEfs0Q10fbQGJ5twfUkyD5jBlrAKfPM48GuIlokiEHjEBHaiKsSCWhtL4a4D(AGiE7YDIDyIXQGAtf4TjXPADjXjsZGGHj2repVWfOws8ci((cr8auI7nioMI2Hkj27yj2JkzX8cFBunaENVgiSKmbVPuoZl8Tpfhfw2dUMuIBEcG35RbYshoz63gtr7OAd1MkWBZJG1LvTNSIkTAvQzqWWvBO2ubEBEeSUScjM210ZGGHRcwxcVa8kKOvRVDlYftxfSU8OaiXW3Ucu8XB0fcNY0ilsnXjsHhOsqm8ukzZlFIHxaXqOjROe7HIJsrIZdsjEBIF7wKlMMyVjEbsfqC2DIdG35RbXOYgvYI5f(2OAa8oFnqyjzcGq6XdfhzPdNmdcgUkyDj8cWRqIwTMbbdxfxmk44nmeY3UcjA16B3ICX0vbRlpkasm8TRafF8gDHWP8h)4)b]] )
    

end
