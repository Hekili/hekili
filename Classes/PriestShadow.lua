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


    spec:RegisterPack( "Shadow", 20210712, [[difjtcqivKEKusDjuqQSjvOpjcQrjf5usrTkPuPEfkWSOeULuOQ2Lu9luunmPahdfzzOq9mvqzAIGCnvq2MuOY3eb04qrPohkkP1jLkMNuQ6EIO9Pc8prOuoOuOSquipefutueYffbyJQGQpIIsmsuqYjfHIvsj6LIqjMPuQKBIcIDQI4NOOWqLc5OIqjTurOu9ukmvPexvkjBvkOVkc0yrbPSxv1FvPbtCyflwKESQmzuDzsBguFMIgnL60uTAPqvETukZwu3gQ2TKFR0WrPJlcvlh45qMUW1bz7qPVdfJhffDEvuRhfKQMpL0(r(Z0VLVbFc9FcJBaJzQbjqMyCVbmBMywtiM93ioZQFd2512yQFJAW1VHH9WxmFd25CEh(VLVbAHap9ByhblQDyoZn9WgkT)wCMJCCO8e(wpWahmh54pM)nsH8CKyQF63GpH(pHXnGXm1GeitmU3aMntmRhgZ63yGc7f8nmCCg(By7CUw)0VbxrVVHH9WxmK0iGROGS0sO8zsyIXwqcJBaJzISKSSfm60gjnCDojTSaGwbjyS1IKyaMAqYBHQarYausGxWt59Vr2rb63Y3GfOVfpDIFl)ty63Y3qRjnR8pJ(gpGhkWNVbqXhVqK0EsoSg0GVX8cFRVb7IrbxmlGFHxq4bex)X)eg)B5BO1KMv(NrFJhWdf4Z3aTq5uV4DwiuaL1RcGydFRUwtAw5Ky1kjOfkN6fVJDZt4z9I2mwTIUwtAw5FJ5f(wFd4SISFGbo(X)Kd73Y3qRjnR8pJ(gpGhkWNVXPKKcbd3r2dFXaVa8oe73yEHV13azp8fd8cW)X)Ke63Y3qRjnR8pJ(gpGhkWNVHxOP84CNRW(ZdsoGeMo03yEHV13yaVP0BSaGwXp(NCOFlFdTM0SY)m6BudU(nq2dFXO87csVl8nwaUwX3yEHV13azp8fJYVli9UW3yb4Af)4FsJ73Y3qRjnR8pJ(gl73aPX3yEHV13a7a8jnRFdStgs)gm(BGDa3AW1VbUx8lshW9bflm8p(NKa)T8nMx4B9nWo4SoWF3yHE2FdTM0SY)m6h)4BWXnVbWR20a9B5Fct)w(gAnPzL)z03OgC9BWhqB47wxU(A7EzHcGIEA90VX8cFRVbFaTHVBD56RT7Lfkak6P1t)X)eg)B5BO1KMv(NrFJAW1VbcQsZ7YVdUg2NrX3yEHV13abvP5D53bxd7ZO4h)toSFlFdTM0SY)m6BudU(nmZNzTVl8Dqih3Zt4B9nMx4B9nmZNzTVl8Dqih3Zt4B9J)jj0VLVHwtAw5Fg9nQbx)gCGoCyhOxSkcP5VX8cFRVbhOdh2b6fRIqA(h)4BGpE9B5Fct)w(gAnPzL)z034b8qb(8nsHGH7P7w3f(g26DqpT4kVdX(nMx4B9nEtoFNx4BDZok(gzhf3AW1Vr6U1p(NW4FlFdTM0SY)m6B8aEOaF(gNssmatn6o6YMNZk4BmVW36BWDeRMV4JP)(X)Kd73Y3qRjnR8pJ(gZl8T(gyxNFvaeB4B9n4k6bC2W36B0kKssdxNtscaaXg(wKSfjVDZ8ftrc7UzVmjzcsY6GcssOgqIxOP84mjPqbj1gK4WKCEHibJNZKSyvWByjXl0uECMeViPHhENegY0MscccOKGSh(Ib21IZCCV4PAXvajtXjHH4fNegLhuqIJizlsE7M5lMIKufEbkjnmb0jjXywlqjHD3SxMKauua8x4BHiXHjbc5Ljjg2dFXaNhCLKgbCeojtXjHrAXvajoIKfk6FJhWdf4Z3a7a8jnRD2DZx4fCFCejhjPjs8cnLhNj5GKKKqnGeRwjHvJoSRfVpVWXQKCKeauPWlWu7i7HVyGZdUEzbocVRjoKZYQCsosYPK82nZxmvh3l(nnpOOdXsYrsoLK3Uz(IP6i7HVyUywa)Y1jS7qSK0mjhjPjs8cnLhNjP9jjHzFisSALKyYAfDKoaVmVLBAh4dq7AnPzLtYrsWoaFsZAhPdWlZB5M2b(a07dkwyysAMKJKCkjVDZ8ft1HDT4DiwsosstKCkjVDZ8ft1X9IFtZdk6qSKy1kjiwnNVXam1a1X9IFr6ai5asymjn)J)jj0VLVHwtAw5Fg9nMx4B9nq2dFXCXSa(LD86BWv0d4SHV13GHmTPKGGakjNxisyHcsGyjXibBNgrsJz0ynIKTijSvsIbyQbjomjjiycByOmjh(OaxjXrvchKmVWXQKGXwlsGDt7WltsyQX)WijgGPgO(34b8qb(8nsHGH7WJEnHga3Nc1Hyj5ijNscxtHGH7yatyddLVWJcCTdXsYrsqSAoFJbyQbQJ7f)I0bqs7jjH(X)Kd9B5BO1KMv(NrFJ5f(wFJ3KZ35f(w3SJIVr2rXTgC9B84OF8pPX9B5BO1KMv(NrFJ5f(wFdCV4xKoGVX78lR3yaMAG(NW034b8qb(8nIjRv0r6a8Y8wUPDGpaTR1KMvojhjbXQ58ngGPgOoUx8lshajhqc2b4tAw74EXViDa3huSWWKCKKtjHVrhzp8fZfZc4x2XRE4V28YKKJKCkjVDZ8ft1HDT4Di2VbxrpGZg(wFdgk30MKgb8f4XzsyiEXjXqhajZl8Tijwsakmqr2KKOTfejy8WMeKoaVmVLBAh4dq)X)Ke4VLVHwtAw5Fg9nMx4B9n4dEnHV134D(L1Bmatnq)ty6B8aEOaF(gNsc2b4tAw7toF5BGUqSFdUIEaNn8T(gncOWkGKyjbcPKKObVMW3IKgZOXAejomjtDMKeTTqIJiP2Gei2(p(NWS)T8n0AsZk)ZOVX8cFRVbYE4lMlMfWVCDc7VbxrpGZg(wFJwHusmSh(IHKeCbCssKoHnjomjqiVmjXWE4lg48GRK0iGJWjzkojPAXvajy8CMeLzY6aLeoeWltscBLKszMbjMpE)B8aEOaF(gSA0HDT495fowLKJKaGkfEbMAhzp8fdCEW1llWr4DnXHCwwLtYrsy1Od7AX7afF8crs7tsI5J)J)jmR)w(gAnPzL)z03yEHV13a3l(nnpO4BWv0d4SHV13OXYyMZisGqkj4EXtZdkqK4WK8gwwLtYuCsSHktf4LjjyxNtIJibILKP4KaH8YKed7HVyGZdUssJaocNKP4KKQfxbK4isGy7KqsJX5E4Bn58zli5nOGeCV4P5bfK4WKCEHibZcL5KKQKavtAwjjwsm1GKWwjb4WbjPNjbZ4HxMKmKy(49VXd4Hc85B0ejVDZ8ft1X9IFtZdk6p7byQisoGeMi5ijnrcxtHGH72qLPc8Y8IDDEhILeRwj5usIjRv0THktf4L5f768UwtAw5K0mjwTscRgDyxlEhO4JxisAFssEdkUHJRKWasmFCsAMKJKWQrh21I3Nx4yvsoscaQu4fyQDK9WxmW5bxVSahH31ehYzzvojhjHvJoSRfVdu8XlejhqYBqXnCC9h)tyQb)w(gAnPzL)z03yEHV13a768B6MJVbxrpGZg(wFJwHusA46Csy0MdsMGeB30wbKWc8f4XzsW4HnjmuqLPc8YKKgUoNeiwsILKeIKyaMAGSGKfqYg2kGKyYAfis2IeJw6FJhWdf4Z3Wl0uECMK2NKeM9Hi5ijXK1k62qLPc8Y8IDDExRjnRCsossmzTIoshGxM3YnTd8bODTM0SYj5ijiwnNVXam1a1X9IFr6aiP9jjPXrIvRK0ejnrsmzTIUnuzQaVmVyxN31AsZkNKJKCkjXK1k6iDaEzEl30oWhG21AsZkNKMjXQvsqSAoFJbyQbQJ7f)I0bqsssyIKM)X)eMy63Y3qRjnR8pJ(gZl8T(gCf7cb8Y8YMhti9BWv0d4SHV13irBLWbjqiLKePyxiGxMK0O8ycPK4WKCEHi5nfjMAqIxXssdxNdVaCs8cf6WTGKfqIdtIHoaVmj5e30oWhGsIJijMSwHYjzkojy8CMeBpirRfY0MKyaMAG6FJhWdf4Z3Ojsakmqr2tAwjXQvs8cnLhNj5assGhIKMj5ijnrYPKGDa(KM1o7U5l8cUpoIeRwjXl0uECMKdsscZ(qK0mjhjPjsoLKyYAfDKoaVmVLBAh4dq7AnPzLtIvRK0ejXK1k6iDaEzEl30oWhG21AsZkNKJKCkjyhGpPzTJ0b4L5TCt7aFa69bflmmjntsZ)4Fctm(3Y3qRjnR8pJ(gZl8T(gyxNFt3C8n4k6bC2W36B0kKssdzejBrcdNisCysoVqKW3kHdskv5KeljVbfKKif7cb8YKKgLhti1csMItsyRaLKbOKKveIKWEkssisIbyQbIKfkiPPdrcgpSj5TfhYJM7FJhWdf4Z3aXQ58ngGPgOoUx8lshajTNKMijHiHbK82Id5rN7i0wtfx9zVkQR1KMvojntYrs8cnLhNjP9jjHzFisossmzTIoshGxM3YnTd8bODTM0SYjXQvsoLKyYAfDKoaVmVLBAh4dq7AnPzL)J)jmDy)w(gAnPzL)z03yEHV13azp8fZfZc4xUoH934D(L1Bmatnq)ty6B8aEOaF(gnrsmatn626Kd7o7liP9KW4gqYrsqSAoFJbyQbQJ7f)I0bqs7jjHiPzsSALKMiHvJoSRfVpVWXQKCKeauPWlWu7i7HVyGZdUEzbocVRjoKZYQCsA(BWv0d4SHV13OviLed7HVyijbxaVDijr6e2K4WKe2kjXam1GehrYKUqbjXsc3vswajNxisShSkjg2dFXaNhCLKgbCeojAId5SSkNemEytcdXlEQwCfqYciXWE4lgyxlojZlCSA)h)tykH(T8n0AsZk)ZOVX8cFRVbcca0IRGBSx8Hxkc9nENFz9gdWud0)eM(gpGhkWNVrmatn6HJR3yVCxjP9KW4drYrssHGH7yxNdVa8oFXuFdUIEaNn8T(gTcPKyabaAXvajXscdz4LIqKSfjdjXam1GKWEcsCejMRxMKeljCxjzcscBLeGBAhKeoU2)X)eMo0VLVHwtAw5Fg9nMx4B9nWUo)glaOv8nENFz9gdWud0)eM(gpGhkWNVb2b4tAw78nqxiwsossmatn6HJR3yVCxj5asomsosstKKcbd3XUohEb4D(IPiXQvssHGH7yxNdVa8oqXhVqK0EsE7M5lMQJDD(nDZrhO4JxisAMKJKmVWXQx(gDSdoRd83nwONnjjjbXQ58ngGPgOo2bN1b(7gl0ZMKJKGy1C(gdWuduh3l(fPdGK2tstKCisyajnrsJJK2njXK1k6bghf3f(cpH21AsZkNKMjP5VbxrpGZg(wFJwHusA46CsAzbaTcs2kFMehMeJeSDAejtXjPHTqYausMx4yvsMItsyRKedWudsWSvchKWDLeoeWltscBLKN9uLM7)4FctnUFlFdTM0SY)m6B8aEOaF(g8n6yhCwh4VBSqp7E4V28YKKJK0ejXK1k6iDaEzEl30oWhG21AsZkNKJKGy1C(gdWuduh3l(fPdGKdib7a8jnRDCV4xKoG7dkwyysSALe(gDK9WxmxmlGFzhV6H)AZltsAMKJK0ejNscaQu4fyQDK9WxmW5bxVSahH31ehYzzvojwTsY8chRE5B0Xo4SoWF3yHE2KCqssENFz9QLI7kIKM)gZl8T(g4EXt1IRGF8pHPe4VLVHwtAw5Fg9nMx4B9nq2dFXCXSa(LRty)n4k6bC2W36B0kKsIrc2ojIemEytsJgVsb60MciPrOjJtcuLveIKWwjjgGPgKGXZzssvss18IHeg3ag6ijvHxGssyRK82nZxmfjVfxrKKoV26FJhWdf4Z3aavk8cm1o74vkqN2uWLfnz8UM4qolRYj5ijyhGpPzTZ3aDHyj5ijXam1OhoUEJ9Y(IlJBajhqstK82nZxmvhzp8fZfZc4xUoHDNdbMW3IegqI5JtsZ)4Fctm7FlFdTM0SY)m6BmVW36BGSh(I5(adY(BWv0d4SHV13OviLed7HVyiHHbdYMKTiHHtejqvwriscBfOKmaLKHZrK41BX9YS)nEapuGpFdW48RIvROpCoQ7fjhqctn4h)tyIz93Y3qRjnR8pJ(gpGhkWNVbIvZ5BmatnqDCV4xKoasoGeSdWN0S2X9IFr6aUpOyHHj5ijPqWWD(aA7g2lKPD0Hy)gCf9aoB4B9nAfsjHH4fNedDaKeljVTqq4kjjAaTrsl2lKPDGiHfSpejBrsJXmsaDsAHzKiMbjm8wWoaNehrsy7isCejdj2UPTciHf4lWJZKe2trcq5BeEzsYwK0ymJeajqvwris4dOnsc7fY0oqK4isM0fkijwschxjzHIVX78lR3yaMAG(NW03WRqbai246WFJWFTHoijJ)gEfkaaXgxhhx5(e63GPVXZE86BW03yEHV13a3l(fPd4h)tyCd(T8n0AsZk)ZOVbxrpGZg(wFJwHusyiEXj5WZZzsILK3wiiCLKenG2iPf7fY0oqKWc2hIKTiXOLojTWmseZGegElyhGtIdtsy7isCejdj2UPTciHf4lWJZKe2trcq5BeEzscuLveIe(aAJKWEHmTdejoIKjDHcsILKWXvswO4B8aEOaF(gPqWWD(aA7g2lKPD0Hyj5ijyhGpPzTZ3aDHy)gEfkaaXgxh(Be(Rn0bjz8X3Uz(IP6yxNFt3C0Hy)gEfkaaXgxhhx5(e63GPVXZE86BW03yEHV13a3l(fopN)X)egZ0VLVHwtAw5Fg9nMx4B9nW9IFtZdk(gCf9aoB4B9nAfsjHH4fNegLhuqIdtY5fIe(wjCqsPkNKyjbOWafztsI2wqDsmILLK3GcVmjzcssiswaj4lqjjgGPgisW4Hnjg6a8YKKtCt7aFakjXK1kuojtXj58crYausQnibc5Ljjg2dFXaNhCLKgbCeojlGKgHo)S9hjTlVARJy1C(gdWuduh3l(fPd4GeBhIetnqKe2kj4E54q4KSWKCisMItsyRKuq4PkGKfMKyaMAG6K0yz0Abj8LKAdsybkcrcUx808GcsGQWZKm5mjXam1arYaus4BekNemEytsdBHem2ArceYltsq2dFXaNhCLewGJWjXHjjvlUciXrKmyhppPzT)nEapuGpFdSdWN0S25BGUqSKCKeW48RIvROJVyvCTIUxKCajVbf3WXvsyajnOFisoscIvZ5BmatnqDCV4xKoasApjnrscrcdiHXK0UjjMSwrh3rk4CxRjnRCsyajZlCS6LVrh7GZ6a)DJf6zts7MKyYAfDw05NT)UzVARR1KMvojmGKMibXQ58ngGPgOoUx8lshajhKyJKdrsZK0UjPjsy1Od7AX7ZlCSkjhjbavk8cm1oYE4lg48GRxwGJW7AId5SSkNKMjPzsosstKCkjaOsHxGP2r2dFXaNhC9YcCeExtCiNLv5Ky1kjNsYB3mFXuDyxlEhILKJKaGkfEbMAhzp8fdCEW1llWr4DnXHCwwLtIvRKmVWXQx(gDSdoRd83nwONnjhKKK35xwVAP4UIiP5F8pHXm(3Y3qRjnR8pJ(gZl8T(gyhCwh4VBSqp7VXd4Hc85BauyGISN0SsYrsIbyQrpCC9g7L7kjhqsJJeRwjPjsIjRv0XDKco31AsZkNKJKW3OJSh(I5Izb8l74vhOWafzpPzLKMjXQvssHGH7qfmei7L5LpG2kfH6qSFJ35xwVXam1a9pHPF8pHXh2VLVHwtAw5Fg9nMx4B9nq2dFXCXSa(LD86BWv0d4SHV13WGvF(Kj5Tf3dFlsILeuSSK8gu4Ljjgjy70is2IKfgUXpgGPgisWyRfjWUPD4LjjhgjlGe8fOKGI51MYjbFtrKmfNeiKxMK0i05NT)iPD5vBKmfNKtygTqcdXrk4C)B8aEOaF(gafgOi7jnRKCKKyaMA0dhxVXE5UsYbKKqKCKKtjjMSwrh3rk4CxRjnRCsossmzTIol68Z2F3SxT11AsZkNKJKGy1C(gdWuduh3l(fPdGKdiHX)4FcJtOFlFdTM0SY)m6BmVW36BGSh(I5Izb8l74134D(L1Bmatnq)ty6B8aEOaF(gafgOi7jnRKCKKyaMA0dhxVXE5UsYbKKqKCKKtjjMSwrh3rk4CxRjnRCsosYPK0ejXK1k6iDaEzEl30oWhG21AsZkNKJKGy1C(gdWuduh3l(fPdGKdib7a8jnRDCV4xKoG7dkwyysAMKJK0ejNssmzTIol68Z2F3SxT11AsZkNeRwjPjsIjRv0zrNF2(7M9QTUwtAw5KCKeeRMZ3yaMAG64EXViDaK0(KKWysAMKM)gCf9aoB4B9nsSOkljgjy70isGyjzlsgej4tDMKyaMAGizqKWUiKNMvlirzMpLnibJTwKa7M2HxMKCyKSasWxGsckMxBkNe8nfrcgpSjPrOZpB)rs7YR26)4FcJp0VLVHwtAw5Fg9nMx4B9nW9IFr6a(gVZVSEJbyQb6FctFdVcfaGyJRd)nc)1g6GKm(B4vOaaeBCDCCL7tOFdM(gpGhkWNVbIvZ5BmatnqDCV4xKoasoGeSdWN0S2X9IFr6aUpOyHH)gp7XRVbt)4FcJBC)w(gAnPzL)z03yEHV13a3l(fopN)gEfkaaXgxh(Be(Rn0bjz8X3Uz(IP6yxNFt3C0Hy)gEfkaaXgxhhx5(e63GPVXZE86BW0p(NW4e4VLVHwtAw5Fg9n4k6bC2W36B0kKsIrc2ojIKbrsEqbjafTGGehMKTijSvsWxS63yEHV13azp8fZfZc4xUoH9p(NWyM9VLVHwtAw5Fg9n4k6bC2W36B0kKsIrc2onIKbrsEqbjafTGGehMKTijSvsWxSkjtXjXibBNerIJizlsy4e9nMx4B9nq2dFXCXSa(LD86h)4B8W8(T8pHPFlFdTM0SY)m6BaH0lgBpR33GcVm)NW03yEHV13aPdWlZB5M2b(a0VX78lR3yaMAG(NW034b8qb(8nAIeSdWN0S2r6a8Y8wUPDGpa9(GIfgMKJKCkjyhGpPzTZUB(cVG7JJiPzsSALKMiHVrhzp8fZfZc4x2XRoqHbkYEsZkjhjbXQ58ngGPgOoUx8lshajhqctK083GROhWzdFRVrRqkjg6a8YKKtCt7aFakjomjNxisW45mj2EqIwlKPnjXam1arYuCsA0IrbKKykyiKVfjtXjPHRZHxaojdqjP2GeGo8ZwqYcijwsakmqr2KyKGTtJizlscmljlGe8fOKedWudu)h)ty8VLVHwtAw5Fg9nGq6fJTN17BqHxM)ty6BmVW36BG0b4L5TCt7aFa634D(L1Bmatnq)ty6B8aEOaF(gXK1k6iDaEzEl30oWhG21AsZkNKJKW3OJSh(I5Izb8l74vhOWafzpPzLKJKGy1C(gdWuduh3l(fPdGKdiHXFdUIEaNn8T(gg2liiHHDWdYdsm0b4LjjN4M2b(ausEBX9W3IKyjPnvzjXibBNgrceljErsJTjGF8p5W(T8n0AsZk)ZOVXw5Z3hM33GPVX8cFRVbUx8BAEqX3GROhWzdFRVXw5Z3hMhj4tBkIKWwjzEHVfjBLptceAsZkjCiGxMK8SNQ0SxMKmfNKAdsgejdja1ekpasMx4B1)Xp(gbWR20a9B5Fct)w(gAnPzL)z03GROhWzdFRVrRqkjBrcdNisAmJgRrKeljMAqsI2wij8xBEzsYuCsuMjRdusILKSxkjqSKKQrOasW4HnjnCDo8cW)g1GRFdfN9mqN8Db8AQN(nEapuGpFJ3Uz(IP6yxNFvaeB4B1bk(4fIK2NKeMymjwTsYB3mFXuDSRZVkaIn8T6afF8crYbKW4e43yEHV13qXzpd0jFxaVM6P)4FcJ)T8n0AsZk)ZOVbxrpGZg(wFJwaNjjwsmoxpssmjwtejy8WMKeTqPzLeJyETPCsy4eHiXHjHDripnRDsygfj5TmvajWUPDGibJh2KGVaLKetI1ercesrKmrO4SbjXsc6C9ibJh2Km1zsECswajnEqOGeiKsIh9Vrn463Wl0daftAwVjo0ube(LRy9N(nEapuGpFJuiy4o215WlaVdXsYrssHGH7SlgfC9cgc5B1HyjXQvssxeIKJKa7M2XfO4JxisAFssyCdiXQvssHGH7SlgfC9cgc5B1Hyj5ijVDZ8ft1XUo)Qai2W3Qdu8XlejmGeMoejhqcSBAhxGIpEHiXQvssHGH7yxNdVa8oeljhj5TBMVyQo7IrbxVGHq(wDGIpEHiHbKW0Hi5asGDt74cu8XlejwTsstK82nZxmvNDXOGRxWqiFRoqXhVqKCqssyQbKCKK3Uz(IP6yxNFvaeB4B1bk(4fIKdssctnGKMj5ijWUPDCbk(4fIKdssctmRn4BmVW36B4f6bGIjnR3ehAQac)YvS(t)X)Kd73Y3qRjnR8pJ(gCf9aoB4B9nmoxpsmSvniHHaH8hjy8WMKgUohEb4FJAW1Vb(8MuGEr2QgxCiK)(gpGhkWNVXB3mFXuDSRZVkaIn8T6afF8crYbKWud(gZl8T(g4ZBsb6fzRACXHq(7h)tsOFlFdTM0SY)m6BudU(nqluoRr4L5faLE(B8o)Y6ngGPgO)jm9nMx4B9nqluoRr4L5faLE(B8aEOaF(gPqWWD2fJcUEbdH8T6qSKy1kjNsclWvu0rAg(YUyuW1lyiKVfjwTsIM4qolRY7i7HVyu(DbP3f(glaxR4BWv0d4SHV13W4C9ijXou6zsW4HnjnAXOassmfmeY3Iei0yQwqc(0MscccOKeljOYzvscBLK8IrrbjmunIKyaMA0jjbT1IeiKYjbJh2Kyyp8fJYjHzasjzHjPLfGRvybjnEqOGeiKsYwKWWjIKbrco0ZMKbrc7IqEAw7)4FYH(T8n0AsZk)ZOVbxrpGZg(wFJwHusy0Wnvs8c5CLKfMKgE4KaVascBLeyhGcsGqkjlGKTiHHtejdCOascBLeyhGcsGqANed7feK8CWdYdsCysWUoNefaXg(wK82nZxmfjoIeMAaIKfqc(cusgmZ5(3OgC9BG8cgkFnZd3NybOB6Wn17cFHvW(84834b8qb(8nE7M5lMQJDD(vbqSHVvhO4Jxisoijjm1GVX8cFRVbYlyO81mpCFIfGUPd3uVl8fwb7ZJZ)4FsJ73Y3qRjnR8pJ(gCf9aoB4B9nAfsjXWE4lgLtcZaKsYctsllaxRGem2ArsTbjErsdxNdVaClizbK4fjPAGr1IKgUoNegT5GK3GcejErsdxNdVa8(3OgC9BGSh(Ir53fKEx4BSaCTIVXd4Hc85BCkjPqWWDSRZHxaEhILeRwjPjsybk2R5J3zQJDD(nDZbjn)nMx4B9nq2dFXO87csVl8nwaUwXp(NKa)T8n0AsZk)ZOVbxrpGZg(wFJwHusYokizHjzRgFiKscFWhtLKa4vBAGizR8zsCysyOGktf4LjjnCDojjstHGHjXrKmVWXQwqYci58crYausQnijMSwHYjXRyjXJ(3yEHV134n58DEHV1n7O4B8aEOaF(gnrYPKetwROBdvMkWlZl215DTM0SYjXQvs4AkemC3gQmvGxMxSRZ7qSK0mjhjPjssHGH7yxNdVa8oeljwTsYB3mFXuDSRZVkaIn8T6afF8crYbKWudiP5Vr2rXTgC9BWXnVbWR20a9J)jm7FlFdTM0SY)m6BmVW36BaH0Rhko6BWv0d4SHV13irk8aLdsGNCoDETrc8cibcnPzLepuCu7qsRqkjBrYB3mFXuK4fjlGRassptsa8QnnibL3O)nEapuGpFJuiy4o215WlaVdXsIvRKKcbd3zxmk46fmeY3QdXsIvRK82nZxmvh768RcGydFRoqXhVqKCajm1GF8JVXJJ(T8pHPFlFdTM0SY)m6BmVW36BWUyuW1lyiKV13GROhWzdFRVrRqkjnAXOassmfmeY3IemEytsdxNdVa8ojmuBMtc8ciPHRZHxaojVfxrKSWWK82nZxmfjErsyRKukZmiHPgqcsFBXrKSHTcW4iLeiKsYwK84KavzfHijSvsyZZzfqIJiHDabjlmjHTssBNb(uK8wSAnvybjlGehMKWwbkjy8CMKAdssvsMAdBfqsdxNtscaaXg(wKe2oIey30o6K0yrO4SbjXsc6C9ijSvsYdkiHDXOas8cgc5BrYctsyRKa7M2bjXsc215KOai2W3Ie4fqsTfjjwod8Pq9VXd4Hc85BWcCffDKMHVSlgfC9cgc5BrYrsAIKuiy4o215WlaVdXsIvRKCkjVfRwtf92od8Pi5ijVDZ8ft1XUo)Qai2W3Qdu8XlejhKKeMAajwTss6IqKCKey30oUafF8crs7j5TBMVyQo215xfaXg(wDGIpEHiPzsosstKa7M2XfO4JxisoijjVDZ8ft1XUo)Qai2W3Qdu8XlejmGeMoejhj5TBMVyQo215xfaXg(wDGIpEHiP9jjX8XjPDtscrIvRKa7M2XfO4JxisoGK3Uz(IP6SlgfC9cgc5B15qGj8TiXQvsGDt74cu8XlejTNK3Uz(IP6yxNFvaeB4B1bk(4fIegqcthIeRwj5Ty1AQO32zGpfjwTsskemCpnVlpdHIoeljn)J)jm(3Y3qRjnR8pJ(gCf9aoB4B9nAfsjHrd3ujXlKZvswysA4Htc8cijSvsGDakibcPKSas2IegorKmWHcijSvsGDakibcPDssqpSj5e30oi5WhLe7nZjbEbK0WdV)nQbx)giVGHYxZ8W9jwa6MoCt9UWxyfSppo)nEapuGpFJuiy4o215WlaVdXsIvRKeoUsYbKWudi5ijnrYPK8wSAnv0l30oUWJssZFJ5f(wFdKxWq5RzE4(elaDthUPEx4lSc2NhN)X)Kd73Y3qRjnR8pJ(gZl8T(gWJEnHga3Nc9n4k6bC2W36B0kKsYHpkjmlqdG7tHizlsy4erYcfiNRKSWK0W15WlaVtsRqkjh(OKWSanaUpfhrIxK0W15WlaNehMKZlej2dwLe1dBfqcZcyXQKKykSU5cMW3IKfqYH7AMtYctcJYlcT4Oojj44bjWlGe(gisILKuLeiwssv4fOKmVWXoHxMKC4JscZc0a4(uisILe8Hz64osjjSvssHGH7FJhWdf4Z34ussHGH7yxNdVa8oeljhjPjsoLK3Uz(IP6yxNFJfa0k6qSKy1kjNssmzTIo2153ybaTIUwtAw5K0mjhjPjsWoaFsZANVb6cXsYrsqSAoFJbyQbQJDWzDG)UXc9SjjjjmrIvRKmVWXQx(gDSdoRd83nwONnjjjbXQ58ngGPgOo2bN1b(7gl0ZMKJKGy1C(gdWuduh7GZ6a)DJf6ztYbKWejntIvRKKcbd3XUohEb4DiwsosstKGwOCQx8UjyXQxVW6MlycFRUwtAw5Ky1kjOfkN6fVd7AMFx4BAErOfh11AsZkNKM)X)Ke63Y3qRjnR8pJ(gZl8T(g4EXnhCf9nENFz9gdWud0)eM(gpGhkWNVHxOP84mjTNeM1gqYrsAIKMib7a8jnR9jNV8nqxiwsosstKCkjVDZ8ft1XUo)Qai2W3QdXsIvRKCkjXK1k62qLPc8Y8IDDExRjnRCsAMKMjXQvssHGH7yxNdVa8oeljntYrsAIKtjjMSwr3gQmvGxMxSRZ7AnPzLtIvRKW1uiy4UnuzQaVmVyxN3bk(4fIKdi5nO4goUsIvRKCkjPqWWDSRZHxaEhILKMj5ijnrYPKetwROJ0b4L5TCt7aFaAxRjnRCsSALeeRMZ3yaMAG64EXViDaK0Esoejn)n4k6bC2W36B0kKscdXlU5GRisWyRfjtotYHrsI2wqKmaLeiwlizbKCEHizakjErsdxNdVa8ojjGcbbusyOGktf4LjjnCDojy8CMeu45mjPkjqSKGXwlscBLK3Gcschxjb2lhzROojgXYsceYltsMGKdXasIbyQbIemEytIHoaVmj5e30oWhG2)X)Kd9B5BO1KMv(NrFJ5f(wFdOYEZNV1ID(gCf9aoB4B9nAfsjPvL9MptYjl2HKTiHHtKfKyVzUxMKKcCfoFMKyjbZ4bjWlGe2fJciXlyiKVfjlGKHZjbXoyku)B8aEOaF(gnrstKCkjGX5xfRwrF4CuhILKJKagNFvSAf9HZrDVi5asyCdiPzsSALeW48RIvROpCoQdu8XlejhKKeMoejwTscyC(vXQv0hoh15qGj8TiP9KW0HiPzsosstKKcbd3zxmk46fmeY3QdXsIvRK82nZxmvNDXOGRxWqiFRoqXhVqKCqssyQbKy1kjNsclWvu0rAg(YUyuW1lyiKVfjntYrsAIKtjjMSwr3gQmvGxMxSRZ7AnPzLtIvRKW1uiy4UnuzQaVmVyxN3HyjXQvsoLKuiy4o215WlaVdXssZ)4FsJ73Y3qRjnR8pJ(gZl8T(gP7w3f(g26DqpT4k)BWv0d4SHV13OviLKTiHHtejPqbjSaFbE4iLeiKxMK0W15KKaaqSHVfjWoafwqIdtces5K4fY5kjlmjn8WjzlsmAHeiKsYahkGKHeSRZt3Cqc8ci5TBMVyksuyy)5A9otYuCsGxaj2qLPc8YKeSRZjbInCCLehMKyYAfkV)nEapuGpFJtjjfcgUJDDo8cW7qSKCKKtj5TBMVyQo215xfaXg(wDiwsoscIvZ5BmatnqDCV4xKoasoGeMi5ijNssmzTIoshGxM3YnTd8bODTM0SYjXQvsAIKuiy4o215WlaVdXsYrsqSAoFJbyQbQJ7f)I0bqs7jHXKCKKtjjMSwrhPdWlZB5M2b(a0UwtAw5KCKKMiHfOyVMpENPo21530nhKCKKMi5us0ehYzzvExXzpd0jFxaVM6PKy1kjNssmzTIUnuzQaVmVyxN31AsZkNKMjXQvs0ehYzzvExXzpd0jFxaVM6PKCKK3Uz(IP6ko7zGo57c41upTdu8XlejTpjjm14ymjhjHRPqWWDBOYubEzEXUoVdXssZK0mjwTsstKKcbd3XUohEb4DiwsossmzTIoshGxM3YnTd8bODTM0SYjP5F8pjb(B5BO1KMv(NrFJ5f(wFJ3KZ35f(w3SJIVr2rXTgC9BeaVAtd0p(NWS)T8n0AsZk)ZOVX8cFRVbCwr2pWahFdUIEaNn8T(gTcPKC4zfz)adCqYcfiNRKSWKGpErYB3mFXuisILe8XRy8IKgU5j8SsIXMXQvqskemC)B8aEOaF(gOfkN6fVJDZt4z9I2mwTIUwtAw5KCKKtjjfcgUJDDo8cW7qSKCKKtjjfcgUZUyuW1lyiKVvhI9h)4BKUB9B5Fct)w(gAnPzL)z034b8qb(8nqSAoFJbyQbQJ7f)I0bqs7tsYH9nMx4B9ng0tlUYVP5bf)4FcJ)T8n0AsZk)ZOVXd4Hc85BGy1C(gdWuduFqpT4k)wl2HKdiHjsoscIvZ5BmatnqDCV4xKoasoGeMiHbKetwROJ0b4L5TCt7aFaAxRjnR8VX8cFRVXGEAXv(TwSZp(X3GRWduo(T8pHPFlFJ5f(wFdKN16PFdTM0SY)m6h)ty8VLVHwtAw5Fg9nEapuGpFJuiy4o215WlaVdXsIvRKKcbd3zxmk46fmeY3QdX(nMx4B9ny3W36h)toSFlFdTM0SY)m6BSSFdKgFJ5f(wFdSdWN0S(nWozi9BW3OJSh(I5Izb8l74vp8xBEzsYrs4B0Xo4SoWF3yHE29WFT5L53a7aU1GRFd(gOle7p(NKq)w(gAnPzL)z03yz)gin(gZl8T(gyhGpPz9BGDYq63GVrhzp8fZfZc4x2XRE4V28YKKJKW3OJDWzDG)UXc9S7H)AZltsoscFJoxXUqaVmVS5Xes7H)AZlZVb2bCRbx)gtoF5BGUqS)4FYH(T8n0AsZk)ZOVXY(nqA8nMx4B9nWoaFsZ63a7KH0VbIvZ5BmatnqDCV4xKoasoGegtcdijfcgUJDDo8cW7qSFdUIEaNn8T(ggXacsGqEzsIHoaVmj5e30oWhGsYeKCymGKyaMAGizbKKqmGehMKZlejdqjXlsA46C4fG)nWoGBn463aPdWlZB5M2b(a07dkwy4F8pPX9B5BO1KMv(NrFJL9BG04BmVW36BGDa(KM1Vb2jdPFJ3Uz(IP6yxNFvaeB4B1Hyj5ijnrYPKagNFvSAf9HZrDiwsSALeW48RIvROpCoQZHat4Brs7tsctnGeRwjbmo)Qy1k6dNJ6afF8crYbjjHPgqcdi5qK0UjPjsIjRv0THktf4L5f768UwtAw5Ky1kjVfRwtf92od8PiPzsAMKJK0ejnrcyC(vXQv0hoh19IKdiHXnGeRwjbXQ58ngGPgOo215xfaXg(wKCqssoejntIvRKetwROBdvMkWlZl215DTM0SYjXQvsElwTMk6TDg4trsZKCKKMi5usaqLcVatTJyTvGIU2daFRZDnXHCwwLtIvRK0ejVDZ8ft1zxmk46fmeY3Qdu8XlejTpjjMpEhFyMK0Uj5WiXQvssHGH7SlgfC9cgc5B1HyjXQvssxeIKJKa7M2XfO4JxisAFssy8HiPzsA(BWv0d4SHV13GH3nZxmfjnA3mjnCa(KMvliPviLtsSKWUBMKufEbkjZlCSt4LjjyxNdVa8ojmmeaOvKptces5KeljVTcWMjbJTwKeljZlCStOKGDDo8cWjbJh2K41BX9YKKHZr9Vb2bCRbx)gS7MVWl4(4OF8pjb(B5BO1KMv(NrFJhWdf4Z3ifcgUJDDo8cW7qSFJ5f(wFdyhOP5D5)4FcZ(3Y3qRjnR8pJ(gpGhkWNVrkemCh76C4fG3Hy)gZl8T(gPkaPG28Y8h)tyw)T8n0AsZk)ZOVX8cFRVr2nTd0TXdIBIRv8n4k6bC2W36B0kKss7YnTJegrILqCtCTcsCyscBfOKmaLegtYcibFbkjXam1azbjlGKHZrKmaTs4Gee7GP8YKe4fqc(cusc7PijbEiu)B8aEOaF(giwnNVXam1a1ZUPDGUnEqCtCTcsoijjmMeRwjPjsoLeW48RIvROpCoQRmthfisSALeW48RIvROpCoQ7fjhqsc8qK08p(NWud(T8n0AsZk)ZOVXd4Hc85BKcbd3XUohEb4Di2VX8cFRVXupffGjFFto)J)jmX0VLVHwtAw5Fg9nMx4B9nEtoFNx4BDZok(gzhf3AW1VXdZ7h)tyIX)w(gAnPzL)z03yEHV13aav35f(w3SJIVr2rXTgC9BGpE9JF8JVbwfG8T(NW4gWyMAqcSbm9nWmGYlt03ibBSe7NKyoHzPDiHKwSvsCC2feKaVassywG(w80jsysaAId5aLtcAXvsgOyXNq5K8SNYurDYY2LxkjmUDiHH3cRccLtscJwOCQx8odTeMKyjjHrluo1lENHwxRjnR8eMKMyIz2CNSSD5LscJBhsy4TWQGq5KKWOfkN6fVZqlHjjwssy0cLt9I3zO11AsZkpHjzcssamJ2fjnXeZS5ozjzzc2yj2pjXCcZs7qcjTyRK44SliibEbKKWpokHjbOjoKduojOfxjzGIfFcLtYZEktf1jlBxEPK04Ahsy4TWQGq5KKWbWR20OpPV(B3mFXujmjXssc)2nZxmvFsFjmjnXeZS5ozz7YlLeMD7qcdVfwfekNKegTq5uV4DgAjmjXsscJwOCQx8odTUwtAw5jmjnXeZS5ozjzzIbNDbHYjHztY8cFlsYokqDYYVblyH9S(nADRjXWE4lgsAeWvuqw26wtILq5ZKWeJTGeg3agZezjzzRBnjTGrN2iPHRZjPLfa0kibJTwKedWudsElufisgGsc8cEkVtwsw26wtscGzQpOq5KKQWlqj5T4PtqsQA6fQtsJ9EkBGiP2QX3Ea4WqzsMx4BHizR85oz58cFluNfOVfpDcgKK5SlgfCXSa(fEbHhqC1chojqXhVqT)WAqdilNx4BH6Sa9T4PtWGKmhoRi7hyGdlC4KOfkN6fVZcHcOSEvaeB4Bz1kAHYPEX7y38eEwVOnJvRGSCEHVfQZc03INobdsYCK9WxmWla3cho5PPqWWDK9WxmWlaVdXswoVW3c1zb6BXtNGbjz(aEtP3ybaTclC4KEHMYJZDUc7ppoGPdrwoVW3c1zb6BXtNGbjzoesVEO4wudUMezp8fJYVli9UW3yb4AfKLZl8TqDwG(w80jyqsMJDa(KMvlQbxtI7f)I0bCFqXcdBXYMePHfyNmKMKXKLZl8TqDwG(w80jyqsMJDWzDG)UXc9SjljlBDRjPrB4BHilNx4BHsI8SwpLSCEHVfkj7g(ww4WjtHGH7yxNdVa8oeRvRPqWWD2fJcUEbdH8T6qSKLZl8TqmijZXoaFsZQf1GRj5BGUqSwSSjrAyb2jdPj5B0r2dFXCXSa(LD8Qh(RnVmpY3OJDWzDG)UXc9S7H)AZltYY5f(wigKK5yhGpPz1IAW1KtoF5BGUqSwSSjrAyb2jdPj5B0r2dFXCXSa(LD8Qh(RnVmpY3OJDWzDG)UXc9S7H)AZlZJ8n6Cf7cb8Y8YMhtiTh(RnVmjlBnjgXacsGqEzsIHoaVmj5e30oWhGsYeKCymGKyaMAGizbKKqmGehMKZlejdqjXlsA46C4fGtwoVW3cXGKmh7a8jnRwudUMePdWlZB5M2b(a07dkwyylw2KinSa7KH0KiwnNVXam1a1X9IFr6aoGXmifcgUJDDo8cW7qSKLTMegE3mFXuK0ODZK0Wb4tAwTGKwHuojXsc7Uzssv4fOKmVWXoHxMKGDDo8cW7KWWqaGwr(mjqiLtsSK82kaBMem2ArsSKmVWXoHsc215WlaNemEytIxVf3ltsgoh1jlNx4BHyqsMJDa(KMvlQbxtYUB(cVG7JJSyztI0WcStgst(2nZxmvh768RcGydFRoe7XMofmo)Qy1k6dNJ6qSwTcgNFvSAf9HZrDoeycFR2NKPgy1kyC(vXQv0hoh1bk(4f6GKm1agCO2DtXK1k62qLPc8Y8IDDExRjnRCRwFlwTMk6TDg4t1CZhBQjW48RIvROpCoQ71bmUbwTIy1C(gdWuduh768RcGydFRdsEOMTAnMSwr3gQmvGxMxSRZ7AnPzLB16BXQ1urVTZaFQMp20PaOsHxGP2rS2kqrx7bGV15UM4qolRYTATP3Uz(IP6SlgfC9cgc5B1bk(4fQ9jnF8o(WmB3hMvRPqWWD2fJcUEbdH8T6qSwTMUi0ry30oUafF8c1(Km(qn3mz58cFledsYCyhOP5D5w4WjtHGH7yxNdVa8oelz58cFledsY8ufGuqBEzAHdNmfcgUJDDo8cW7qSKLTMKwHusAxUPDKWisSeIBIRvqIdtsyRaLKbOKWyswaj4lqjjgGPgilizbKmCoIKbOvchKGyhmLxMKaVasWxGssypfjjWdH6KLZl8TqmijZZUPDGUnEqCtCTclC4KiwnNVXam1a1ZUPDGUnEqCtCTIdsYyRwB6uW48RIvROpCoQRmthfiRwbJZVkwTI(W5OUxhKapuZKLZl8TqmijZN6POam57BYzlC4KPqWWDSRZHxaEhILSCEHVfIbjz(BY578cFRB2rHf1GRjFyEKLZl8TqmijZbq1DEHV1n7OWIAW1K4JxKLKLTU1K0ynQDrsSKaHusWyRfjmA3IKfMKWwjPXqpT4kNehrY8chRswoVW3c1t3TsoONwCLFtZdkSWHtIy1C(gdWuduh3l(fPdO9jpmYY5f(wOE6UfdsY8b90IR8BTyhlC4KiwnNVXam1a1h0tlUYV1IDoGPJiwnNVXam1a1X9IFr6aoGjgetwROJ0b4L5TCt7aFaAxRjnRCYsYYw3Asy4eHilBnjTcPK0OfJcijXuWqiFlsW4HnjnCDo8cW7KWqTzojWlGKgUohEb4K8wCfrYcdtYB3mFXuK4fjHTssPmZGeMAaji9TfhrYg2kaJJusGqkjBrYJtcuLveIKWwjHnpNvajoIe2beKSWKe2kjTDg4trYBXQ1uHfKSasCyscBfOKGXZzsQnijvjzQnSvajnCDojjaaeB4Brsy7isGDt7OtsJfHIZgKeljOZ1JKWwjjpOGe2fJciXlyiKVfjlmjHTscSBAhKeljyxNtIcGydFlsGxaj1wKKy5mWNc1jlNx4BH6pokj7IrbxVGHq(ww4WjzbUIIosZWx2fJcUEbdH8To2ukemCh76C4fG3HyTA903IvRPIEBNb(uhF7M5lMQJDD(vbqSHVvhO4JxOdsYudSAnDrOJWUPDCbk(4fQ9VDZ8ft1XUo)Qai2W3Qdu8XluZhBc2nTJlqXhVqhK8TBMVyQo215xfaXg(wDGIpEHyath64B3mFXuDSRZVkaIn8T6afF8c1(KMpE7oHSAf2nTJlqXhVqh82nZxmvNDXOGRxWqiFRohcmHVLvRWUPDCbk(4fQ9VDZ8ft1XUo)Qai2W3Qdu8Xledy6qwT(wSAnv0B7mWNYQ1uiy4EAExEgcfDi2MjlBnjTcPKy4zTEkjBrcdNisILewW(iXqzTHyOpHrK0iW(Yd(e(wDYYwtY8cFlu)XrmijZrEwRNArmatnUoCsauPWlWu7iL1gIHE0LfSV8GpHVvxtCiNLv5hBkgGPgDhDho3Q1yaMA05AkemC)nOWlZoqNx0mzzRjPviLegnCtLeVqoxjzHjPHhojWlGKWwjb2bOGeiKsYcizlsy4erYahkGKWwjb2bOGeiK2jjb9WMKtCt7GKdFusS3mNe4fqsdp8oz58cFlu)XrmijZHq61df3IAW1KiVGHYxZ8W9jwa6MoCt9UWxyfSppoBHdNmfcgUJDDo8cW7qSwTgoUEatn4ytN(wSAnv0l30oUWJ2mzzRjPviLKdFusywGga3NcrYwKWWjIKfkqoxjzHjPHRZHxaENKwHuso8rjHzbAaCFkoIeViPHRZHxaojomjNxisShSkjQh2kGeMfWIvjjXuyDZfmHVfjlGKd31mNKfMegLxeAXrDssWXdsGxaj8nqKeljPkjqSKKQWlqjzEHJDcVmj5WhLeMfObW9PqKelj4dZ0XDKssyRKKcbd3jlNx4BH6poIbjzo8OxtObW9Pqw4WjpnfcgUJDDo8cW7qShB603Uz(IP6yxNFJfa0k6qSwTEAmzTIo2153ybaTIUwtAw5nFSjSdWN0S25BGUqShrSAoFJbyQbQJDWzDG)UXc9StYKvRZlCS6LVrh7GZ6a)DJf6zNeXQ58ngGPgOo2bN1b(7gl0Z(iIvZ5BmatnqDSdoRd83nwON9bm1SvRPqWWDSRZHxaEhI9ytOfkN6fVBcwS61lSU5cMW3QR1KMvUvROfkN6fVd7AMFx4BAErOfh11AsZkVzYYwtsRqkjmeV4MdUIibJTwKm5mjhgjjABbrYausGyTGKfqY5fIKbOK4fjnCDo8cW7KKakeeqjHHcQmvGxMK0W15KGXZzsqHNZKKQKaXscgBTijSvsEdkijCCLeyVCKTI6KyelljqiVmjzcsoedijgGPgisW4Hnjg6a8YKKtCt7aFaANSCEHVfQ)4igKK54EXnhCfzX78lR3yaMAGsYKfoCsVqt5X52ZS2GJn1e2b4tAw7toF5BGUqShB603Uz(IP6yxNFvaeB4B1HyTA90yYAfDBOYubEzEXUoVR1KMvEZnB1AkemCh76C4fG3HyB(ytNgtwROBdvMkWlZl215DTM0SYTALRPqWWDBOYubEzEXUoVdu8Xl0bVbf3WXvRwpnfcgUJDDo8cW7qSnFSPtJjRv0r6a8Y8wUPDGpaTR1KMvUvRiwnNVXam1a1X9IFr6aA)HAMSS1K0kKssRk7nFMKtwSdjBrcdNiliXEZCVmjjf4kC(mjXscMXdsGxajSlgfqIxWqiFlswajdNtcIDWuOoz58cFlu)XrmijZHk7nF(wl2XchoztnDkyC(vXQv0hoh1HypcgNFvSAf9HZrDVoGXnOzRwbJZVkwTI(W5OoqXhVqhKKPdz1kyC(vXQv0hoh15qGj8TApthQ5JnLcbd3zxmk46fmeY3QdXA16B3mFXuD2fJcUEbdH8T6afF8cDqsMAGvRNYcCffDKMHVSlgfC9cgc5B18XMonMSwr3gQmvGxMxSRZ7AnPzLB1kxtHGH72qLPc8Y8IDDEhI1Q1ttHGH7yxNdVa8oeBZKLTMKwHus2IegorKKcfKWc8f4HJusGqEzssdxNtscaaXg(wKa7auybjomjqiLtIxiNRKSWK0WdNKTiXOfsGqkjdCOasgsWUopDZbjWlGK3Uz(IPirHH9NR17mjtXjbEbKydvMkWltsWUoNei2WXvsCysIjRvO8oz58cFlu)XrmijZt3TUl8nS17GEAXvUfoCYttHGH7yxNdVa8oe7XtF7M5lMQJDD(vbqSHVvhI9iIvZ5BmatnqDCV4xKoGdy64PXK1k6iDaEzEl30oWhG21AsZk3Q1MsHGH7yxNdVa8oe7reRMZ3yaMAG64EXViDaTNXhpnMSwrhPdWlZB5M2b(a0UwtAw5hBIfOyVMpENPo21530nhhB6unXHCwwL3vC2ZaDY3fWRPEQvRNgtwROBdvMkWlZl215DTM0SYB2QvnXHCwwL3vC2ZaDY3fWRPE6Xa4vBA0vC2ZaDY3fWRPEA)TBMVyQoqXhVqTpjtnogFKRPqWWDBOYubEzEXUoVdX2CZwT2ukemCh76C4fG3HypgtwROJ0b4L5TCt7aFaAxRjnR8MjlNx4BH6poIbjz(BY578cFRB2rHf1GRjdGxTPbISS1K0kKsYHNvK9dmWbjluGCUsYctc(4fjVDZ8ftHijwsWhVIXlsA4MNWZkjgBgRwbjPqWWDYY5f(wO(JJyqsMdNvK9dmWHfoCs0cLt9I3XU5j8SErBgRwXXttHGH7yxNdVa8oe7XttHGH7SlgfC9cgc5B1HyjljlBDRjHHhuqscA7zLegEqHxMKmVW3c1jXqdsMGeB30wbKWc8f4XzsILeK9ccsEo4b5bjEfkaaXgK82I7HVfIKTiHH4fNedDam)WZZzYYwtsRqkjg6a8YKKtCt7aFakjomjNxisW45mj2EqIwlKPnjXam1arYuCsA0IrbKKykyiKVfjtXjPHRZHxaojdqjP2GeGo8ZwqYcijwsakmqr2KyKGTtJizlscmljlGe8fOKedWuduNSCEHVfQ)W8sI0b4L5TCt7aFaQfqi9IX2Z69nOWlZKmzX78lR3yaMAGsYKfoCYMWoaFsZAhPdWlZB5M2b(a07dkwy4JNIDa(KM1o7U5l8cUpoQzRwBIVrhzp8fZfZc4x2XRoqHbkYEsZ6reRMZ3yaMAG64EXViDahWuZKLTMed7feKWWo4b5bjg6a8YKKtCt7aFakjVT4E4BrsSK0MQSKyKGTtJibILeViPX2eaz58cFlu)H5XGKmhPdWlZB5M2b(aulGq6fJTN17BqHxMjzYI35xwVXam1aLKjlC4KXK1k6iDaEzEl30oWhG21AsZk)iFJoYE4lMlMfWVSJxDGcduK9KM1JiwnNVXam1a1X9IFr6aoGXKLTMKTYNVpmpsWN2uejHTsY8cFls2kFMei0KMvs4qaVmj5zpvPzVmjzkoj1gKmisgsaQjuEaKmVW3QtwoVW3c1FyEmijZX9IFtZdkSyR857dZljtKLKLZl8TqDoU5naE1MgOKqi96HIBrn4As(aAdF36Y1xB3lluau0tRNswoVW3c154M3a4vBAGyqsMdH0RhkUf1GRjrqvAEx(DW1W(mkilNx4BH6CCZBa8QnnqmijZHq61df3IAW1KM5ZS23f(oiKJ75j8TilNx4BH6CCZBa8QnnqmijZHq61df3IAW1KCGoCyhOxSkcPzYsYYw3AsyiJxK0ynQDzbji7fkZj5TyvajtotcyktfrYctsmatnqKmfNe0tRb4lISCEHVfQJpEL8n58DEHV1n7OWIAW1KP7ww4WjtHGH7P7w3f(g26DqpT4kVdXswoVW3c1XhVyqsMZDeRMV4JP)SWHtEAmatn6o6YMNZkGSS1K0kKssdxNtscaaXg(wKSfjVDZ8ftrc7UzVmjzcsY6GcssOgqIxOP84mjPqbj1gK4WKCEHibJNZKSyvWByjXl0uECMeViPHhENegY0MscccOKGSh(Ib21IZCCV4PAXvajtXjHH4fNegLhuqIJizlsE7M5lMIKufEbkjnmb0jjXywlqjHD3SxMKauua8x4BHiXHjbc5Ljjg2dFXaNhCLKgbCeojtXjHrAXvajoIKfk6KLZl8TqD8XlgKK5yxNFvaeB4BzHdNe7a8jnRD2DZx4fCFC0XM8cnLhNpizc1aRwz1Od7AX7ZlCS6rauPWlWu7i7HVyGZdUEzbocVRjoKZYQ8JN(2nZxmvh3l(nnpOOdXE803Uz(IP6i7HVyUywa)Y1jS7qSnFSjVqt5X52NKzFiRwJjRv0r6a8Y8wUPDGpaTR1KMv(rSdWN0S2r6a8Y8wUPDGpa9(GIfgU5JN(2nZxmvh21I3Hyp20PVDZ8ft1X9IFtZdk6qSwTIy1C(gdWuduh3l(fPd4ag3mzzRjHHmTPKGGakjNxisyHcsGyjXibBNgrsJz0ynIKTijSvsIbyQbjomjjiycByOmjh(OaxjXrvchKmVWXQKGXwlsGDt7WltsyQX)WijgGPgOoz58cFluhF8IbjzoYE4lMlMfWVSJxw4WjtHGH7WJEnHga3Nc1HypEkxtHGH7yatyddLVWJcCTdXEeXQ58ngGPgOoUx8lshq7tiYY5f(wOo(4fdsY83KZ35f(w3SJclQbxt(4iYYwtcdLBAtsJa(c84mjmeV4KyOdGK5f(wKeljafgOiBss02cIemEytcshGxM3YnTd8bOKLZl8TqD8XlgKK54EXViDaw8o)Y6ngGPgOKmzHdNmMSwrhPdWlZB5M2b(a0UwtAw5hrSAoFJbyQbQJ7f)I0bCa2b4tAw74EXViDa3huSWWhpLVrhzp8fZfZc4x2XRE4V28Y84PVDZ8ft1HDT4DiwYYwtsJakScijwsGqkjjAWRj8TiPXmASgrIdtYuNjjrBlK4isQnibITtwoVW3c1XhVyqsMZh8AcFllENFz9gdWudusMSWHtEk2b4tAw7toF5BGUqSKLTMKwHusmSh(IHKeCbCssKoHnjomjqiVmjXWE4lg48GRK0iGJWjzkojPAXvajy8CMeLzY6aLeoeWltscBLKszMbjMpENSCEHVfQJpEXGKmhzp8fZfZc4xUoHTfoCswn6WUw8(8chREeavk8cm1oYE4lg48GRxwGJW7AId5SSk)iRgDyxlEhO4JxO2N08XjlBnjnwgZCgrcesjb3lEAEqbIehMK3WYQCsMItInuzQaVmjb76CsCejqSKmfNeiKxMKyyp8fdCEWvsAeWr4KmfNKuT4kGehrceBNesAmo3dFRjNpBbjVbfKG7fpnpOGehMKZlejywOmNKuLeOAsZkjXsIPgKe2kjahoij9mjygp8YKKHeZhVtwoVW3c1XhVyqsMJ7f)MMhuyHdNSP3Uz(IP64EXVP5bf9N9amv0bmDSjUMcbd3THktf4L5f768oeRvRNgtwROBdvMkWlZl215DTM0SYB2Qvwn6WUw8oqXhVqTp5BqXnCCLbMpEZhz1Od7AX7ZlCS6rauPWlWu7i7HVyGZdUEzbocVRjoKZYQ8JSA0HDT4DGIpEHo4nO4goUsw2AsAfsjPHRZjHrBoizcsSDtBfqclWxGhNjbJh2KWqbvMkWltsA46CsGyjjwssisIbyQbYcswajByRasIjRvGizlsmAPtwoVW3c1XhVyqsMJDD(nDZHfoCsVqt5X52NKzFOJXK1k62qLPc8Y8IDDExRjnR8JXK1k6iDaEzEl30oWhG21AsZk)iIvZ5BmatnqDCV4xKoG2NSXz1AtnftwROBdvMkWlZl215DTM0SYpEAmzTIoshGxM3YnTd8bODTM0SYB2QveRMZ3yaMAG64EXViDajzQzYYwtsI2kHdsGqkjjsXUqaVmjPr5XesjXHj58crYBksm1GeVILKgUohEb4K4fk0HBbjlGehMedDaEzsYjUPDGpaLehrsmzTcLtYuCsW45mj2EqIwlKPnjXam1a1jlNx4BH64JxmijZ5k2fc4L5LnpMqQfoCYMakmqr2tAwTA1l0uEC(Ge4HA(ytNIDa(KM1o7U5l8cUpoYQvVqt5X5dsYSpuZhB60yYAfDKoaVmVLBAh4dq7AnPzLB1AtXK1k6iDaEzEl30oWhG21AsZk)4PyhGpPzTJ0b4L5TCt7aFa69bflmCZntw2AsAfsjPHmIKTiHHtejomjNxis4BLWbjLQCsILK3GcssKIDHaEzssJYJjKAbjtXjjSvGsYausYkcrsypfjjejXam1arYcfK00HibJh2K82Id5rZDYY5f(wOo(4fdsYCSRZVPBoSWHtIy1C(gdWuduh3l(fPdO9nLqm4TfhYJo3rOTMkU6ZEvuxRjnR8Mp6fAkpo3(Km7dDmMSwrhPdWlZB5M2b(a0UwtAw5wTEAmzTIoshGxM3YnTd8bODTM0SYjlBnjTcPKyyp8fdjj4c4TdjjsNWMehMKWwjjgGPgK4isM0fkijws4UsYci58crI9GvjXWE4lg48GRK0iGJWjrtCiNLv5KGXdBsyiEXt1IRaswajg2dFXa7AXjzEHJv7KLZl8TqD8XlgKK5i7HVyUywa)Y1jST4D(L1BmatnqjzYchoztXam1OBRtoS7SVO9mUbhrSAoFJbyQbQJ7f)I0b0(eQzRwBIvJoSRfVpVWXQhbqLcVatTJSh(Ibop46Lf4i8UM4qolRYBMSS1K0kKsIbeaOfxbKeljmKHxkcrYwKmKedWudsc7jiXrKyUEzssSKWDLKjijSvsaUPDqs44ANSCEHVfQJpEXGKmhbbaAXvWn2l(WlfHS4D(L1BmatnqjzYchozmatn6HJR3yVCxBpJp0Xuiy4o215WlaVZxmfzzRjPviLKgUoNKwwaqRGKTYNjXHjXibBNgrYuCsAylKmaLK5fowLKP4Ke2kjXam1GemBLWbjCxjHdb8YKKWwj5zpvP5oz58cFluhF8Ibjzo2153ybaTclENFz9gdWudusMSWHtIDa(KM1oFd0fI9ymatn6HJR3yVCxp4Wo2ukemCh76C4fG35lMYQ1uiy4o215WlaVdu8Xlu7F7M5lMQJDD(nDZrhO4JxOMpoVWXQx(gDSdoRd83nwONDseRMZ3yaMAG6yhCwh4VBSqp7JiwnNVXam1a1X9IFr6aAFthIbn14A3XK1k6bghf3f(cpH21AsZkV5MjlNx4BH64JxmijZX9INQfxbw4Wj5B0Xo4SoWF3yHE29WFT5L5XMIjRv0r6a8Y8wUPDGpaTR1KMv(reRMZ3yaMAG64EXViDahGDa(KM1oUx8lshW9bflmSvR8n6i7HVyUywa)YoE1d)1MxMnFSPtbqLcVatTJSh(Ibop46Lf4i8UM4qolRYTADEHJvV8n6yhCwh4VBSqp7ds(o)Y6vlf3vuZKLTMKwHusmsW2jrKGXdBsA04vkqN2uajncnzCsGQSIqKe2kjXam1GemEotsQssQMxmKW4gWqhjPk8cuscBLK3Uz(IPi5T4kIK051wNSCEHVfQJpEXGKmhzp8fZfZc4xUoHTfoCsauPWlWu7SJxPaDAtbxw0KX7AId5SSk)i2b4tAw78nqxi2JXam1OhoUEJ9Y(IlJBWbn92nZxmvhzp8fZfZc4xUoHDNdbMW3IbMpEZKLTMKwHusmSh(IHeggmiBs2IegorKavzfHijSvGsYausgohrIxVf3lZoz58cFluhF8IbjzoYE4lM7dmiBlC4KGX5xfRwrF4Cu3RdyQbKLTMKwHusyiEXjXqhajXsYBleeUssIgqBK0I9czAhisyb7drYwK0ymJeqNKwygjIzqcdVfSdWjXrKe2oIehrYqITBARasyb(c84mjH9uKau(gHxMKSfjngZibqcuLveIe(aAJKWEHmTdejoIKjDHcsILKWXvswOGSCEHVfQJpEXGKmh3l(fPdWI35xwVXam1aLKjlC4KiwnNVXam1a1X9IFr6aoa7a8jnRDCV4xKoG7dkwy4JPqWWD(aA7g2lKPD0HyT4zpELKjl8kuaaInUooUY9j0KmzHxHcaqSX1Htg(Rn0bjzmzzRjPviLegIxCso88CMKyj5TfccxjjrdOnsAXEHmTdejSG9HizlsmAPtslmJeXmiHH3c2b4K4WKe2oIehrYqITBARasyb(c84mjH9uKau(gHxMKavzfHiHpG2ijSxit7arIJizsxOGKyjjCCLKfkilNx4BH64JxmijZX9IFHZZzlC4KPqWWD(aA7g2lKPD0HypIDa(KM1oFd0fI1IN94vsMSWRqbai24644k3NqtYKfEfkaaXgxhoz4V2qhKKXhF7M5lMQJDD(nDZrhILSS1K0kKscdXlojmkpOGehMKZlej8Ts4GKsvojXscqHbkYMKeTTG6KyelljVbfEzsYeKKqKSasWxGssmatnqKGXdBsm0b4LjjN4M2b(ausIjRvOCsMItY5fIKbOKuBqceYltsmSh(Ibop4kjnc4iCswajncD(z7psAxE1whXQ58ngGPgOoUx8lshWbj2oejMAGijSvsW9YXHWjzHj5qKmfNKWwjPGWtvajlmjXam1a1jPXYO1cs4lj1gKWcueIeCV4P5bfKavHNjzYzsIbyQbIKbOKW3iuojy8WMKg2cjyS1IeiKxMKGSh(Ibop4kjSahHtIdtsQwCfqIJizWoEEsZANSCEHVfQJpEXGKmh3l(nnpOWchoj2b4tAw78nqxi2JGX5xfRwrhFXQ4AfDVo4nO4goUYGg0p0reRMZ3yaMAG64EXViDaTVPeIbmUDhtwROJ7ifCUR1KMvodMx4y1lFJo2bN1b(7gl0ZUDhtwROZIo)S93n7vBDTM0SYzqtiwnNVXam1a1X9IFr6aoiX2HAUD3eRgDyxlEFEHJvpcGkfEbMAhzp8fdCEW1llWr4DnXHCwwL3CZhB6uauPWlWu7i7HVyGZdUEzbocVRjoKZYQCRwp9TBMVyQoSRfVdXEeavk8cm1oYE4lg48GRxwGJW7AId5SSk3Q15fow9Y3OJDWzDG)UXc9Spi578lRxTuCxrntwoVW3c1XhVyqsMJDWzDG)UXc9ST4D(L1BmatnqjzYchojqHbkYEsZ6XyaMA0dhxVXE5UEqJZQ1MIjRv0XDKco31AsZk)iFJoYE4lMlMfWVSJxDGcduK9KM1MTAnfcgUdvWqGSxMx(aARueQdXsw2Asmy1NpzsEBX9W3IKyjbflljVbfEzsIrc2onIKTizHHB8JbyQbIem2ArcSBAhEzsYHrYcibFbkjOyETPCsW3uejtXjbc5LjjncD(z7psAxE1gjtXj5eMrlKWqCKco3jlNx4BH64JxmijZr2dFXCXSa(LD8YchojqHbkYEsZ6XyaMA0dhxVXE5UEqcD80yYAfDChPGZDTM0SYpgtwROZIo)S93n7vBDTM0SYpIy1C(gdWuduh3l(fPd4agtw2AssSOkljgjy70isGyjzlsgej4tDMKyaMAGizqKWUiKNMvlirzMpLnibJTwKa7M2HxMKCyKSasWxGsckMxBkNe8nfrcgpSjPrOZpB)rs7YR26KLZl8TqD8XlgKK5i7HVyUywa)YoEzX78lR3yaMAGsYKfoCsGcduK9KM1JXam1OhoUEJ9YD9Ge64PXK1k64osbN7AnPzLF80MIjRv0r6a8Y8wUPDGpaTR1KMv(reRMZ3yaMAG64EXViDahGDa(KM1oUx8lshW9bflmCZhB60yYAfDw05NT)UzVARR1KMvUvRnftwROZIo)S93n7vBDTM0SYpIy1C(gdWuduh3l(fPdO9jzCZntwoVW3c1XhVyqsMJ7f)I0byX78lR3yaMAGsYKfoCseRMZ3yaMAG64EXViDahGDa(KM1oUx8lshW9bflmSfp7XRKmzHxHcaqSX1XXvUpHMKjl8kuaaInUoCYWFTHoijJjlNx4BH64JxmijZX9IFHZZzlE2JxjzYcVcfaGyJRJJRCFcnjtw4vOaaeBCD4KH)AdDqsgF8TBMVyQo21530nhDiwYYwtsRqkjgjy7Kisgej5bfKau0ccsCys2IKWwjbFXQKLZl8TqD8XlgKK5i7HVyUywa)Y1jSjlBnjTcPKyKGTtJizqKKhuqcqrliiXHjzlscBLe8fRsYuCsmsW2jrK4is2IegorKLZl8TqD8XlgKK5i7HVyUywa)YoErwsw2AsAfsjzlsy4ersJz0ynIKyjXudss02cjH)AZltsMItIYmzDGssSKK9sjbILKuncfqcgpSjPHRZHxaoz58cFlupaE1MgOKqi96HIBrn4AsfN9mqN8Db8AQNAHdN8TBMVyQo215xfaXg(wDGIpEHAFsMySvRVDZ8ft1XUo)Qai2W3Qdu8Xl0bmobsw2AsAbCMKyjX4C9ijXKynrKGXdBss0cLMvsmI51MYjHHteIehMe2fH80S2jHzuKK3YubKa7M2bIemEytc(cussmjwtejqifrYeHIZgKeljOZ1JemEytYuNj5XjzbK04bHcsGqkjE0jlNx4BH6bWR20aXGKmhcPxpuClQbxt6f6bGIjnR3ehAQac)YvS(tTWHtMcbd3XUohEb4Di2JPqWWD2fJcUEbdH8T6qSwTMUi0ry30oUafF8c1(KmUbwTMcbd3zxmk46fmeY3QdXE8TBMVyQo215xfaXg(wDGIpEHyath6ay30oUafF8cz1AkemCh76C4fG3Hyp(2nZxmvNDXOGRxWqiFRoqXhVqmGPdDaSBAhxGIpEHSATP3Uz(IP6SlgfC9cgc5B1bk(4f6GKm1GJVDZ8ft1XUo)Qai2W3Qdu8Xl0bjzQbnFe2nTJlqXhVqhKKjM1gqw2AsmoxpsmSvniHHaH8hjy8WMKgUohEb4KLZl8Tq9a4vBAGyqsMdH0RhkUf1GRjXN3Kc0lYw14IdH8NfoCY3Uz(IP6yxNFvaeB4B1bk(4f6aMAazzRjX4C9ijXou6zsW4HnjnAXOassmfmeY3Iei0yQwqc(0MscccOKeljOYzvscBLK8IrrbjmunIKyaMA0jjbT1IeiKYjbJh2Kyyp8fJYjHzasjzHjPLfGRvybjnEqOGeiKsYwKWWjIKbrco0ZMKbrc7IqEAw7KLZl8Tq9a4vBAGyqsMdH0RhkUf1GRjrluoRr4L5faLE2I35xwVXam1aLKjlC4KPqWWD2fJcUEbdH8T6qSwTEklWvu0rAg(YUyuW1lyiKVLvRAId5SSkVJSh(Ir53fKEx4BSaCTcYYwtsRqkjmA4MkjEHCUsYctsdpCsGxajHTscSdqbjqiLKfqYwKWWjIKbouajHTscSdqbjqiTtIH9ccsEo4b5bjomjyxNtIcGydFlsE7M5lMIehrctnarYcibFbkjdM5CNSCEHVfQhaVAtdedsYCiKE9qXTOgCnjYlyO81mpCFIfGUPd3uVl8fwb7ZJZw4WjF7M5lMQJDD(vbqSHVvhO4JxOdsYudilBnjTcPKyyp8fJYjHzasjzHjPLfGRvqcgBTiP2GeViPHRZHxaUfKSas8IKunWOArsdxNtcJ2CqYBqbIeViPHRZHxaENSCEHVfQhaVAtdedsYCiKE9qXTOgCnjYE4lgLFxq6DHVXcW1kSWHtEAkemCh76C4fG3HyTATjwGI9A(4DM6yxNFt3C0mzzRjPviLKSJcswys2QXhcPKWh8XujjaE1Mgis2kFMehMegkOYubEzssdxNtsI0uiyysCejZlCSQfKSasoVqKmaLKAdsIjRvOCs8kws8OtwoVW3c1dGxTPbIbjz(BY578cFRB2rHf1GRj54M3a4vBAGSWHt20PXK1k62qLPc8Y8IDDExRjnRCRw5AkemC3gQmvGxMxSRZ7qSnFSPuiy4o215WlaVdXA16B3mFXuDSRZVkaIn8T6afF8cDatnOzYYwtsIu4bkhKap5C68AJe4fqceAsZkjEO4O2HKwHus2IK3Uz(IPiXlswaxbKKEMKa4vBAqckVrNSCEHVfQhaVAtdedsYCiKE9qXrw4WjtHGH7yxNdVa8oeRvRPqWWD2fJcUEbdH8T6qSwT(2nZxmvh768RcGydFRoqXhVqhWud(giw99pHXhIz)JF8)]] )
    

end
