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


    spec:RegisterPack( "Shadow", 20210701, [[divSpcqivu9irQ6sOGuztQqFseuJsKYPejTkvqXRqbMfLOBPckzxk8lrGHHIQJHISmuOEMIs10eHY1uuLTjcsFtKkzCOOKZHIIADkkL5POQUNiAFQa)teQIdksflefYdrb1efHCrrqSrvq1hrrrgjki5KOOuRKs4LIqvAMIuPUjki2Pkk)ueQmurIoQiuvTurOQ8ukAQkQCvfLSvvq(QibJffKYEvL)QQgmXHLAXkYJvPjJQltAZG6Zuy0uQtt1QvbL61kkMTOUnuTBj)wPHJshxKqlh45qMUW1bz7qX3HsJhffoVkY6rbPQ5tjTFKFm9M7zY7qFNXyMZyMyE6I5mnyoZA2zotm9mJtS6ZKTVZ0g6ZSAC9zAA38f7ZKTpL3M)M7zIwiWvFM2rWIMTeKadpSHMg3fpbihhk3HV1f0Wrcqo(nbpZjiphm76n9m5DOVZymZzmtmpDXCMgmNzn7mN5mZpZgkSxWZ00Xz4NPTZ5A9MEMCfDFMM2nFXsskbUIcYclGYNiHjljHXmNXmrwqwmhwTNHKdToNK5waqRGeS2Ars0adni5UqvGiPbkjWl4Q8XZm7Oa9M7zEXEFZ9oJP3CptT6PSYFm6zcH0pwBpR)BJcVmENX0ZSVHV1ZePnWlJF5g2bEd0N590nR)ObgAGENX0Z8c8qbE)mtJemnW7PSoqAd8Y4xUHDG3a9FHIfgMKJKCojyAG3tzDWUB(dVG)LJijvsSALK0iHVXaz38f7h7c4F22RbqHbkYUNYkjhjbXQ58pAGHgObUx8psBajhqctKK6ZKROlWzdFRN5SqkjMAd8YGKZCd7aVbkjomjNwisW65mj2EqIwlKHnjrdm0arsxCss5IvbKWSlyiKVfjDXj5qRZHxaojnqjP2GeG28twsYcijwsakmqr2KyMcZwkjzlscSljlGe8fOKenWqd04fVZy8BUNPw9uw5pg9mHq6hRTN1)TrHxgVZy6z23W36zI0g4LXVCd7aVb6Z8E6M1F0adnqVZy6zEbEOaVFMrN1kgiTbEz8l3WoWBGo0QNYkNKJKW3yGSB(I9JDb8pB71aOWafz3tzLKJKGy1C(hnWqd0a3l(hPnGKdiHXptUIUaNn8TEMM2liiHHDWfYdsm1g4LbjN5g2bEdusUBX9W3IKyjzgvzjXmfMTusceljErs6SjKx8oB2FZ9m1QNYk)XON5w5t)l27ZKPNzFdFRNjUx8)uUrXZKROlWzdFRN5w5t)l2lj49mkIKWwjPVHVfjBLprceQNYkjCiGxgKCT7Q0SxgK0fNKAdsAejnja1ak3as6B4BnEXlEMCCJFa8AgnqV5ENX0BUNPw9uw5pg9mRgxFM8gmd(U1NR3z(FwOaOORwx9z23W36zYBWm47wFUEN5)zHcGIUAD1x8oJXV5EMA1tzL)y0ZSAC9zIGQP8U8FJRH9ju8m7B4B9mrq1uEx(VX1W(ekEX7Sz)n3ZuREkR8hJEMvJRptJ8jw7)c)BeYX9Ch(wpZ(g(wptJ8jw7)c)BeYX9Ch(wV4DwI9M7zQvpLv(JrpZQX1NjhOnh2b6hJIqA(z23W36zYbAZHDG(XOiKMFXlEMCfUHYXBU3zm9M7z23W36zI8Swx9zQvpLv(JrV4DgJFZ9m1QNYk)XON5f4Hc8(zobbdpWSohEb4diwsSALKjiy4b7IvbFVGHq(wdi2NzFdFRNj7g(wV4D2S)M7zQvpLv(JrpZL9zI04z23W36zIPbEpL1NjModPpt(gdKDZxSFSlG)zBVgHFNXldsoscFJbMgN1b(9hl01Ee(DgVmEMyAWVAC9zY3a9HyFX7Se7n3ZuREkR8hJEMl7ZePXZSVHV1Zetd8EkRptmDgsFM8ngi7MVy)yxa)Z2Enc)oJxgKCKe(gdmnoRd87pwOR9i87mEzqYrs4Bm4kMfc4LXNn3gq6i87mEz8mX0GF146ZSZ5pFd0hI9fVZM3BUNPw9uw5pg9mx2NjsJNzFdFRNjMg49uwFMy6mK(mrSAo)JgyObAG7f)J0gqYbKWysyajtqWWdmRZHxa(aI9zYv0f4SHV1Z0mAqqceYldsm1g4LbjN5g2bEdus6GKzNbKenWqdejlGKeJbK4WKCAHiPbkjErYHwNdVa8NjMg8RgxFMiTbEz8l3WoWBG(VqXcd)I3zj03CptT6PSYFm6zUSptKgpZ(g(wptmnW7PS(mX0zi9zE3nZxS1aZ68VcGydFRbeljhjjnsoNeq78VIrRy0CoAaXsIvRKaAN)vmAfJMZrdoeOdFlsMFssyI5Ky1kjG25FfJwXO5C0aO4TxisoijjmXCsyajZJKddjPrs0zTIHnuzOaVm(ywNp0QNYkNeRwj5Uy0QRymZjG3fjPssQKCKK0ijnsaTZ)kgTIrZ5OHxKCajmM5Ky1kjiwnN)rdm0anWSo)Rai2W3IKdssY8ijvsSALKOZAfdBOYqbEz8XSoFOvpLvojwTsYDXOvxXyMtaVlssLKJKKgjNtcaQu4fyOdeRTcu03Ub4BDAOPiKZYQCsSALK0i5UBMVyRb7IvbFVGHq(wdGI3EHiz(jjX4Yh4nZGKddjZojwTsYeem8GDXQGVxWqiFRbeljwTsY0IqKCKey3Wo(afV9crY8tscJNhjPssQptUIUaNn8TEMm8Uz(ITijL7Mj5qnW7PSAjjZcPCsILe2DZKmPWlqjPVHJPdVmibZ6C4fGpiHHHaaTI8jsGqkNKyj5Uva2mjyT1IKyjPVHJPdLemRZHxaojy9WMeVUlUxgK0CoA8mX0GF146ZKD38hEb)lh9I3zPR3CptT6PSYFm6zEbEOaVFMtqWWdmRZHxa(aI9z23W36zc7aDkVl)fVZywV5EMA1tzL)y0Z8c8qbE)mNGGHhywNdVa8be7ZSVHV1ZCsbifmJxgV4DgZ8BUNPw9uw5pg9m7B4B9mZUHDG(h2qCdCTINjxrxGZg(wpZzHuss3UHDKWisSaIBGRvqIdtsyRaLKgOKWyswaj4lqjjAGHgiljzbK0CoIKgOvchKGyBSLxgKaVasWxGssy3fjPR5HgpZlWdf49ZeXQ58pAGHgOr2nSd0)WgIBGRvqYbjjHXKy1kjPrY5KaAN)vmAfJMZrdLz4OarIvRKaAN)vmAfJMZrdVi5assxZJKuFX7mMy(BUNPw9uw5pg9mVapuG3pZjiy4bM15WlaFaX(m7B4B9m76QOa05)TZ5x8oJjMEZ9m1QNYk)XONzFdFRN5TZ5FFdFRF2rXZm7O4xnU(mVyVV4Dgtm(n3ZuREkR8hJEM9n8TEMaO633W36NDu8mZok(vJRpt82Rx8INjlqVl(uhV5ENX0BUNPw9uw5pg9mVapuG3ptGI3EHiz(Km7mN5pZ(g(wpt2fRc(yxa)dVGWdiU(I3zm(n3ZuREkR8hJEMxGhkW7NjAHYtEXhSqOakRFfaXg(wdT6PSYjXQvsqluEYl(aZM7WZ6hTzmAfdT6PSYFM9n8TEMWzfzFbnC8I3zZ(BUNPw9uw5pg9mVapuG3pZZjzccgEGSB(IfEb4di2NzFdFRNjYU5lw4fG)I3zj2BUNPw9uw5pg9mVapuG3ptVqD5XPbxH9RhKCajmnVNzFdFRNzdUDP)ybaTIx8oBEV5EMA1tzL)y0ZCzFMinEM9n8TEMyAG3tz9zIPZq6ZKXptmn4xnU(mX9I)rAd(xOyHHFX7Se6BUNzFdFRNjMgN1b(9hl01(zQvpLv(JrV4fpZa41mAGEZ9oJP3CptT6PSYFm6zYv0f4SHV1ZCwiLKTiHHtejPJz6KssILednijr7CKe(DgVmiPlojkZG1bkjXss2lLeiwsM0iuajy9WMKdTohEb4pZQX1NPIZEcOD(VaE11vFMxGhkW7N5D3mFXwdmRZ)kaIn8TgafV9crY8tsctmMeRwj5UBMVyRbM15FfaXg(wdGI3EHi5asyC66z23W36zQ4SNaAN)lGxDD1x8oJXV5EMA1tzL)y0ZKROlWzdFRN5CGtKeljMNQljm7e)jIeSEytsIwOPSsIz03zuojmCIqK4WKWUiKpL1bjjUIK8wgkGey3WoqKG1dBsWxGscZoXFIibcPis6iuC2GKyjbDQUKG1dBs66ejxojlGKdBiuqcesjXJXZSAC9z6f6cGIEkR)ueQRac)Zvm(vFMxGhkW7N5eem8aZ6C4fGpGyj5ijtqWWd2fRc(EbdH8TgqSKy1kjtlcrYrsGDd74du82lejZpjjmM5Ky1kjtqWWd2fRc(EbdH8TgqSKCKK7Uz(ITgywN)vaeB4BnakE7fIegqctZJKdib2nSJpqXBVqKy1kjtqWWdmRZHxa(aILKJKC3nZxS1GDXQGVxWqiFRbqXBVqKWasyAEKCajWUHD8bkE7fIeRwjjnsU7M5l2AWUyvW3lyiKV1aO4TxisoijjmXCsosYD3mFXwdmRZ)kaIn8TgafV9crYbjjHjMtsQKCKey3Wo(afV9crYbjjHjMzM)m7B4B9m9cDbqrpL1Fkc1vaH)5kg)QV4D2S)M7zQvpLv(JrptUIUaNn8TEMMNQljM2QgKWqGq(LeSEytYHwNdVa8Nz146ZeVV9eq)iBvJpoeYVpZlWdf49Z8UBMVyRbM15FfaXg(wdGI3EHi5asyI5pZ(g(wpt8(2ta9JSvn(4qi)(I3zj2BUNPw9uw5pg9mRgxFMOfkN1i8Y4dGMo9mVNUz9hnWqd07mMEMxGhkW7N5eem8GDXQGVxWqiFRbeljwTsY5KWcCffdKMH)Slwf89cgc5B9m7B4B9mrluoRr4LXhanD6zYv0f4SHV1Z08uDjjXh00jsW6HnjPCXQasy2fmeY3IeiuBOwscEpJscccOKeljOYzvscBLK8IvrbjmuPKKObgA8I3zZ7n3ZuREkR8hJEMCfDboB4B9mNfsjHrn3qjXlKZvswyso0Htc8cijSvsGDakibcPKSas2IegorK0WHcijSvsGDakibcPdsmTxqqY1bxipiXHjbZ6CsuaeB4BrYD3mFXwK4isyI5iswaj4lqjPX2NgpZQX1NjYlyO83i3CVJfG(tn3q)l8hwb71JtpZlWdf49Z8UBMVyRbM15FfaXg(wdGI3EHi5GKKWeZFM9n8TEMiVGHYFJCZ9owa6p1Cd9VWFyfSxpo9I3zj03CptT6PSYFm6zYv0f4SHV1ZCwiLKSJcswys26WccPKWB82qjjaEnJgis2kFIehMegkOYqbEzqYHwNtsI0jiyysCej9nCmQLKSasoTqK0aLKAdsIoRvOCs8kws8y8m7B4B9mVDo)7B4B9ZokEMxGhkW7NzAKCojrN1kg2qLHc8Y4JzD(qREkRCsSALeUobbdpSHkdf4LXhZ68beljPsYrssJKjiy4bM15WlaFaXsIvRKC3nZxS1aZ68VcGydFRbqXBVqKCajmXCss9zMDu8RgxFMCCJFa8AgnqV4Dw66n3ZuREkR8hJEM9n8TEMqi97HIJEMCfDboB4B9mtKc3q5Ge4oNN67mKaVasGq9uwjXdfhnBKmlKsYwKC3nZxSfjErYc4kGKPtKeaVMrdsq5ngpZlWdf49ZCccgEGzDo8cWhqSKy1kjtqWWd2fRc(EbdH8TgqSKy1kj3DZ8fBnWSo)Rai2W3Aau82lejhqctm)fV4zE5O3CVZy6n3ZuREkR8hJEM9n8TEMSlwf89cgc5B9m5k6cC2W36zolKsskxSkGeMDbdH8TibRh2KCO15WlaFqcd1M5KaVaso06C4fGtYDXvejlmmj3DZ8fBrIxKe2kjLYmcsyI5KG07wCejByRaSosjbcPKSfjxojqvwriscBLe2CFsbK4isyBqqYctsyRKmZjG3fj3fJwDfwsYciXHjjSvGscwpNjP2GKjLKU2WwbKCO15KKqaqSHVfjHTJib2nSJbjPtekoBqsSKGovxscBLKCJcsyxSkGeVGHq(wKSWKe2kjWUHDqsSKGzDojkaIn8TibEbKuBrsI3taVl04zEbEOaVFMSaxrXaPz4p7IvbFVGHq(wKCKK0izccgEGzDo8cWhqSKy1kjNtYDXOvxXyMtaVlsosYD3mFXwdmRZ)kaIn8TgafV9crYbjjHjMtIvRKmTiejhjb2nSJpqXBVqKmFsU7M5l2AGzD(xbqSHV1aO4TxissLKJKKgjWUHD8bkE7fIKdssYD3mFXwdmRZ)kaIn8TgafV9crcdiHP5rYrsU7M5l2AGzD(xbqSHV1aO4TxisMFssmUCsomKKyKy1kjWUHD8bkE7fIKdi5UBMVyRb7IvbFVGHq(wdoeOdFlsSALey3Wo(afV9crY8j5UBMVyRbM15FfaXg(wdGI3EHiHbKW08iXQvsUlgT6kgZCc4DrIvRKmbbdpMY7YZqOyaXssQV4DgJFZ9m1QNYk)XONjxrxGZg(wpZzHusyuZnus8c5CLKfMKdD4KaVascBLeyhGcsGqkjlGKTiHHtejnCOascBLeyhGcsGq6GKuWdBsoZnSdso8wjXEZCsGxajh6WhpZQX1NjYlyO83i3CVJfG(tn3q)l8hwb71JtpZlWdf49ZCccgEGzDo8cWhqSKy1kjHJRKCajmXCsossAKCoj3fJwDfJYnSJpCRKK6ZSVHV1Ze5fmu(BKBU3Xcq)PMBO)f(dRG96XPx8oB2FZ9m1QNYk)XONzFdFRNjCRFdOgW9UqptUIUaNn8TEMZcPKC4TscZeud4Exis2IegorKSqbY5kjlmjhADo8cWhKmlKsYH3kjmtqnG7DXrK4fjhADo8cWjXHj50crIDJrjr9WwbKWmbwmkjm7cJBSGo8TizbKC4UM5KSWKWO8IqloAqsk0Eqc8ciHVbIKyjzsjbILKjfEbkj9nCmD4LbjhERKWmb1aU3fIKyjbVzgoUJuscBLKjiy4XZ8c8qbE)mpNKjiy4bM15WlaFaXsYrssJKZj5UBMVyRbM15)ybaTIbeljwTsY5KeDwRyGzD(pwaqRyOvpLvojPsYrssJemnW7PSo4BG(qSKCKeeRMZ)ObgAGgyACwh43FSqxBsssctKy1kj9nCm6NVXatJZ6a)(Jf6AtsssqSAo)JgyObAGPXzDGF)XcDTj5ijiwnN)rdm0anW04SoWV)yHU2KCajmrsQKy1kjtqWWdmRZHxa(aILKJKKgjOfkp5fFyawm63lmUXc6W3AOvpLvojwTscAHYtEXhWUM5)f(pLxeAXrdT6PSYjj1x8olXEZ9m1QNYk)XONzFdFRNjUxCJgxrpZ7PBw)rdm0a9oJPN5f4Hc8(z6fQlporY8jHzM5KCKK0ijnsW0aVNY6OZ5pFd0hILKJKKgjNtYD3mFXwdmRZ)kaIn8TgqSKy1kjNts0zTIHnuzOaVm(ywNp0QNYkNKujjvsSALKjiy4bM15WlaFaXssQKCKK0i5CsIoRvmSHkdf4LXhZ68Hw9uw5Ky1kjCDccgEydvgkWlJpM15dGI3EHi5asUnk(HJRKy1kjNtYeem8aZ6C4fGpGyjjvsossAKCojrN1kgiTbEz8l3WoWBGo0QNYkNeRwjbXQ58pAGHgObUx8psBajZNK5rsQptUIUaNn8TEMZcPKWq8IB04kIeS2ArsNZKm7KKODoejnqjbI1sswajNwisAGsIxKCO15WlaFqscPqqaLegkOYqbEzqYHwNtcwpNjbfEotYKsceljyT1IKWwj52OGKWXvsG9Yr2kAqIzSSKaH8YGKoizEmGKObgAGibRh2KyQnWldsoZnSd8gOJx8oBEV5EMA1tzL)y0ZSVHV1ZeQS38PFTy6NjxrxGZg(wpZzHusMvzV5tKC2IPjzlsy4ezjj2BM7LbjtaxHZNijwsW2Eqc8ciHDXQas8cgc5BrYciP5CsqSn2cnEMxGhkW7NzAKKgjNtcOD(xXOvmAohnGyj5ijG25FfJwXO5C0WlsoGegZCssLeRwjb0o)Ry0kgnNJgafV9crYbjjHP5rIvRKaAN)vmAfJMZrdoeOdFlsMpjmnpssLKJKKgjtqWWd2fRc(EbdH8TgqSKy1kj3DZ8fBnyxSk47fmeY3Aau82lejhKKeMyojwTsY5KWcCffdKMH)Slwf89cgc5BrsQKCKK0i5CsIoRvmSHkdf4LXhZ68Hw9uw5Ky1kjCDccgEydvgkWlJpM15diwsSALKZjzccgEGzDo8cWhqSKK6lENLqFZ9m1QNYk)XONzFdFRN50U1FH)HT(B0vlUYFMCfDboB4B9mNfsjzlsy4erYeuqclWxGhosjbc5LbjhADojjeaeB4BrcSdqHLK4WKaHuojEHCUsYctYHoCs2IeZ5ibcPK0WHciPjbZ68PnhKaVasU7M5l2Iefg2VUw3tK0fNe4fqInuzOaVmibZ6CsGydhxjXHjj6SwHYhpZlWdf49Z8CsMGGHhywNdVa8beljhj5CsU7M5l2AGzD(xbqSHV1aILKJKGy1C(hnWqd0a3l(hPnGKdiHjsosY5KeDwRyG0g4LXVCd7aVb6qREkRCsSALK0izccgEGzDo8cWhqSKCKeeRMZ)ObgAGg4EX)iTbKmFsymjhj5CsIoRvmqAd8Y4xUHDG3aDOvpLvojhjjnsybkMVXLpyAGzD(FAZbjhjjnsoNenfHCwwLpuC2taTZ)fWRUUkjwTsY5KeDwRyydvgkWlJpM15dT6PSYjjvsSALenfHCwwLpuC2taTZ)fWRUUkjhj5UBMVyRHIZEcOD(VaE11vhafV9crY8tsctjugtYrs46eem8WgQmuGxgFmRZhqSKKkjPsIvRKKgjtqWWdmRZHxa(aILKJKeDwRyG0g4LXVCd7aVb6qREkRCss9fVZsxV5EMA1tzL)y0ZSVHV1Z8258VVHV1p7O4zMDu8RgxFMbWRz0a9I3zmR3CptT6PSYFm6z23W36zcNvK9f0WXZKROlWzdFRN5SqkjhEwr2xqdhKSqbY5kjlmj4TxKC3nZxSfIKyjbV9kAVi5qBUdpRKyUzmAfKmbbdpEMxGhkW7NjAHYtEXhy2ChEw)OnJrRyOvpLvojhj5CsMGGHhywNdVa8beljhj5CsMGGHhSlwf89cgc5BnGyFXlEMt7wV5ENX0BUNPw9uw5pg9mVapuG3pteRMZ)ObgAGg4EX)iTbKm)KKm7pZ(g(wpZgD1IR8)uUrXlENX43CptT6PSYFm6zEbEOaVFMiwnN)rdm0anA0vlUY)1IPj5asyIKJKGy1C(hnWqd0a3l(hPnGKdiHjsyajrN1kgiTbEz8l3WoWBGo0QNYk)z23W36z2ORwCL)Rft)Ix8mXBVEZ9oJP3CptT6PSYFm6zEbEOaVFMtqWWJPDR)c)dB93ORwCLpGyFM9n8TEM3oN)9n8T(zhfpZSJIF146ZCA36fVZy8BUNPw9uw5pg9mVapuG3pZZjjAGHgdh9zZ9jf8m7B4B9m5oIvZF82WVV4D2S)M7zQvpLv(JrpZ(g(wptmRZ)kaIn8TEMCfDboB4B9mNfsj5qRZjjHaGydFls2IK7Uz(ITiHD3SxgK0bjzTrbjjgZjXluxECIKjOGKAdsCysoTqKG1Zzswmk42SK4fQlporIxKCOdFqcdPNrjbbbusq2nFXc7AXtaUx8jT4kGKU4KWq8ItcJYnkiXrKSfj3DZ8fBrYKcVaLKdLqgKWSnQfOKWUB2ldsakka(n8TqK4WKaH8YGet7MVyHZnUsskbocNKU4KWiT4kGehrYcfJN5f4Hc8(zIPbEpL1b7U5p8c(xoIKJKKgjEH6YJtKCqsssmMtIvRKWQXa21Ip6B4yusoscaQu4fyOdKDZxSW5gx)SahHp0ueYzzvojhj5CsU7M5l2AG7f)pLBumGyj5ijNtYD3mFXwdKDZxSFSlG)5Ah2diwssLKJKKgjEH6YJtKm)KKWSMhjwTss0zTIbsBGxg)YnSd8gOdT6PSYj5ijyAG3tzDG0g4LXVCd7aVb6)cflmmjPsYrsoNK7Uz(ITgWUw8beljhjjnsoNK7Uz(ITg4EX)t5gfdiwsSALeeRMZ)ObgAGg4EX)iTbKCajmMKuFX7Se7n3ZuREkR8hJEM9n8TEMi7MVy)yxa)Z2E9m5k6cC2W36zYq6zusqqaLKtlejSqbjqSKyMcZwkjjDmtNusYwKe2kjrdm0GehMKua0HnmuMKdVvGRK4OkHds6B4yusWARfjWUHD4LbjmDyn7KenWqd04zEbEOaVFMtqWWd4w)gqnG7DHgqSKCKKZjHRtqWWdSGoSHHYF4wbUoGyj5ijiwnN)rdm0anW9I)rAdiz(KKyV4D28EZ9m1QNYk)XONzFdFRN5TZ5FFdFRF2rXZm7O4xnU(mVC0lENLqFZ9m1QNYk)XONzFdFRNjUx8psBWZ8E6M1F0adnqVZy6zEbEOaVFMrN1kgiTbEz8l3WoWBGo0QNYkNKJKGy1C(hnWqd0a3l(hPnGKdibtd8EkRdCV4FK2G)fkwyysosY5KW3yGSB(I9JDb8pB71i87mEzqYrsoNK7Uz(ITgWUw8be7ZKROlWzdFRNjdLBytskb(c84ejmeV4KyQnGK(g(wKeljafgOiBss0ohIeSEytcsBGxg)YnSd8gOV4Dw66n3ZuREkR8hJEM9n8TEM8gV6W36zEpDZ6pAGHgO3zm9mVapuG3pZZjbtd8EkRJoN)8nqFi2NjxrxGZg(wpZucuyfqsSKaHussuJxD4Brs6yMoPKehMKUorsI25iXrKuBqce74fVZywV5EMA1tzL)y0ZSVHV1Zez38f7h7c4FU2H9ZKROlWzdFRN5SqkjM2nFXsskSaojjs7WMehMeiKxgKyA38flCUXvssjWr4K0fNKjT4kGeSEotIYmyDGschc4LbjHTssPmJGeJlF8mVapuG3ptwngWUw8rFdhJsYrsaqLcVadDGSB(Ifo346Nf4i8HMIqolRYj5ijSAmGDT4dGI3EHiz(jjX4YFX7mM53CptT6PSYFm6z23W36zI7f)pLBu8m5k6cC2W36zMozS9jejqiLeCV4t5gfisCysUnlRYjPloj2qLHc8YGemRZjXrKaXssxCsGqEzqIPDZxSW5gxjjLahHtsxCsM0IRasCejqSdsijD4Cp8T6C(KLKCBuqcUx8PCJcsCysoTqKGDHYCsMusGQEkRKeljgAqsyRKaC4GKPtKGT9WldsAsmU8XZ8c8qbE)mtJK7Uz(ITg4EX)t5gfJRDdmuejhqctKCKK0iHRtqWWdBOYqbEz8XSoFaXsIvRKCojrN1kg2qLHc8Y4JzD(qREkRCssLeRwjHvJbSRfFau82lejZpjj3gf)WXvsyajgxojPsYrsy1ya7AXh9nCmkjhjbavk8cm0bYU5lw4CJRFwGJWhAkc5SSkNKJKWQXa21IpakE7fIKdi52O4hoU(I3zmX83CptT6PSYFm6z23W36zIzD(FAZXZKROlWzdFRN5SqkjhADojmAZbjDqITByRasyb(c84ejy9WMegkOYqbEzqYHwNtceljXssIrs0adnqwsYcizdBfqs0zTcejBrI5CJN5f4Hc8(z6fQlporY8tscZAEKCKKOZAfdBOYqbEz8XSoFOvpLvojhjj6SwXaPnWlJF5g2bEd0Hw9uw5KCKeeRMZ)ObgAGg4EX)iTbKm)KKKqjXQvssJK0ij6SwXWgQmuGxgFmRZhA1tzLtYrsoNKOZAfdK2aVm(LByh4nqhA1tzLtsQKy1kjiwnN)rdm0anW9I)rAdijjjmrsQV4Dgtm9M7zQvpLv(JrpZ(g(wptUIzHaEz8zZTbK(m5k6cC2W36zMOTs4GeiKssIumleWldsszUnGusCysoTqKC7IedniXRyj5qRZHxaojEHcT5wsYciXHjXuBGxgKCMByh4nqjXrKeDwRq5K0fNeSEotIThKO1czyts0adnqJN5f4Hc8(zMgjafgOi7EkRKy1kjEH6YJtKCajPR5rsQKCKK0i5CsW0aVNY6GD38hEb)lhrIvRK4fQlporYbjjHznpssLKJKKgjNts0zTIbsBGxg)YnSd8gOdT6PSYjXQvssJKOZAfdK2aVm(LByh4nqhA1tzLtYrsoNemnW7PSoqAd8Y4xUHDG3a9FHIfgMKujj1x8oJjg)M7zQvpLv(JrpZ(g(wptmRZ)tBoEMCfDboB4B9mNfsj5qmIKTiHHtejomjNwis4BLWbjLQCsILKBJcssKIzHaEzqskZTbKAjjDXjjSvGssdusYkcrsy3fjjgjrdm0arYcfKK28ibRh2KC3Id5rQJN5f4Hc8(zIy1C(hnWqd0a3l(hPnGK5tsAKKyKWasUBXH8yWDeARUIVETxfn0QNYkNKuj5ijEH6YJtKm)KKWSMhjhjj6SwXaPnWlJF5g2bEd0Hw9uw5Ky1kjNts0zTIbsBGxg)YnSd8gOdT6PSYFX7mMM93CptT6PSYFm6z23W36zISB(I9JDb8px7W(zEpDZ6pAGHgO3zm9mVapuG3pZ0ijAGHgdBTZH9G9gKmFsymZj5ijiwnN)rdm0anW9I)rAdiz(KKyKKkjwTssAKWQXa21Ip6B4yusoscaQu4fyOdKDZxSW5gx)SahHp0ueYzzvojP(m5k6cC2W36zolKsIPDZxSKKclGpBKKiTdBsCyscBLKObgAqIJiPNwOGKyjH7kjlGKtlej2ngLet7MVyHZnUsskbocNenfHCwwLtcwpSjHH4fFslUcizbKyA38flSRfNK(gogD8I3zmLyV5EMA1tzL)y0ZSVHV1ZebbaAXvWp2pEZlfHEM3t3S(JgyOb6DgtpZlWdf49ZmAGHgJWX1FSFURKmFsy88i5ijtqWWdmRZHxa(GVyRNjxrxGZg(wpZzHusmHaaT4kGKyjHH08sris2IKMKObgAqsy3bjoIeJ1ldsILeURK0bjHTscWnSdschxhV4DgtZ7n3ZuREkR8hJEM9n8TEMywN)Jfa0kEM3t3S(JgyOb6DgtpZlWdf49Zetd8EkRd(gOpeljhjjAGHgJWX1FSFURKCajZojhjjnsMGGHhywNdVa8bFXwKy1kjtqWWdmRZHxa(aO4TxisMpj3DZ8fBnWSo)pT5yau82lejPsYrs6B4y0pFJbMgN1b(9hl01MKKKGy1C(hnWqd0atJZ6a)(Jf6AtYrsqSAo)JgyObAG7f)J0gqY8jjnsMhjmGK0ijHsYHHKOZAfJaRJI)c)H7qhA1tzLtsQKK6ZKROlWzdFRN5SqkjhADojZTaGwbjBLprIdtIzkmBPKKU4KCO5iPbkj9nCmkjDXjjSvsIgyObjy3kHds4Uschc4LbjHTsY1URsZJx8oJPe6BUNPw9uw5pg9mVapuG3pt(gdmnoRd87pwOR9i87mEzqYrssJKOZAfdK2aVm(LByh4nqhA1tzLtYrsqSAo)JgyObAG7f)J0gqYbKGPbEpL1bUx8psBW)cflmmjwTscFJbYU5l2p2fW)STxJWVZ4LbjPsYrssJKZjbavk8cm0bYU5lw4CJRFwGJWhAkc5SSkNeRwjPVHJr)8ngyACwh43FSqxBsoijj3t3S(1sXDfrsQpZ(g(wptCV4tAXvWlENXu66n3ZuREkR8hJEM9n8TEMi7MVy)yxa)Z1oSFMCfDboB4B9mNfsjXmfMTercwpSjjLTxtaTNrbKKsuNXjbQYkcrsyRKenWqdsW65mjtkjtAEXscJzodDKmPWlqjjSvsU7M5l2IK7IRisM67mJN5f4Hc8(zcGkfEbg6GT9AcO9mk4ZI6m(qtriNLv5KCKemnW7PSo4BG(qSKCKKObgAmchx)X(zVXNXmNKdijnsU7M5l2AGSB(I9JDb8px7WEWHaD4BrcdiX4Yjj1x8oJjM1BUNPw9uw5pg9m7B4B9mr2nFX(VGgz)m5k6cC2W36zolKsIPDZxSKWWGgztYwKWWjIeOkRiejHTcusAGssZ5is86U4EzmEMxGhkW7NjOD(xXOvmAohn8IKdiHjM)I3zmXm)M7zQvpLv(JrpZlWdf49ZeXQ58pAGHgObUx8psBajhqcMg49uwh4EX)iTb)luSWWKCKKjiy4bVbZ8d7fYWogqSptUIUaNn8TEMZcPKWq8ItIP2asILK7wiiCLKe1Gzizo7fYWoqKWc2lIKTijDsCjKbjZL4suIJegElyhGtIJijSDejoIKMeB3WwbKWc8f4Xjsc7UibO8ncVmizlssNexcHeOkRiej8gmdjH9czyhisCej90cfKeljHJRKSqXZ8E6M1F0adnqVZy6z6vOaaeB8D4Nz43zqhKKXptVcfaGyJVJJRCVd9zY0Z8A3E9mz6z23W36zI7f)J0g8I3zmM5V5EMA1tzL)y0ZKROlWzdFRN5SqkjmeV4KC45(ejXsYDleeUssIAWmKmN9czyhisyb7frYwKyo3GK5sCjkXrcdVfSdWjXHjjSDejoIKMeB3WwbKWc8f4Xjsc7UibO8ncVmibQYkcrcVbZqsyVqg2bIehrspTqbjXss44kjlu8mVapuG3pZjiy4bVbZ8d7fYWogqSKCKemnW7PSo4BG(qSptVcfaGyJVd)md)od6GKm(4D3mFXwdmRZ)tBogqSptVcfaGyJVJJRCVd9zY0Z8A3E9mz6z23W36zI7f)dN7tV4DgJz6n3ZuREkR8hJEM9n8TEM4EX)t5gfptUIUaNn8TEMZcPKWq8ItcJYnkiXHj50crcFReoiPuLtsSKauyGISjjr7CObjMXYsYTrHxgK0bjjgjlGe8fOKenWqdejy9WMetTbEzqYzUHDG3aLKOZAfkNKU4KCAHiPbkj1gKaH8YGet7MVyHZnUsskbocNKfqskrNU2(LK0TxZmqSAo)JgyObAG7f)J0gCqIN5rIHgiscBLeCVCCiCswysMhjDXjjSvski8jfqYcts0adnqdssNmATKe(ssTbjSafHib3l(uUrbjqv4zs6CMKObgAGiPbkj8ncLtcwpSj5qZrcwBTibc5Lbji7MVyHZnUsclWr4K4WKmPfxbK4isAmTN7PSoEMxGhkW7NjMg49uwh8nqFiwsoscOD(xXOvmWxmkUwXWlsoGKBJIF44kjmGeMpMhjhjbXQ58pAGHgObUx8psBajZNK0ijXiHbKWysomKeDwRyG7ifCAOvpLvojmGK(gog9Z3yGPXzDGF)XcDTj5Wqs0zTIbl6012V)SxZm0QNYkNegqsAKGy1C(hnWqd0a3l(hPnGKds8qY8ijvsomKKgjSAmGDT4J(gogLKJKaGkfEbg6az38flCUX1plWr4dnfHCwwLtsQKKkjhjjnsoNeauPWlWqhi7MVyHZnU(zbocFOPiKZYQCsSALKZj5UBMVyRbSRfFaXsYrsaqLcVadDGSB(Ifo346Nf4i8HMIqolRYjXQvs6B4y0pFJbMgN1b(9hl01MKdssY90nRFTuCxrKK6lENXyg)M7zQvpLv(JrpZ(g(wptmnoRd87pwOR9Z8c8qbE)mbkmqr29uwj5ijrdm0yeoU(J9ZDLKdijHsIvRKKgjrN1kg4osbNgA1tzLtYrs4Bmq2nFX(XUa(NT9AauyGIS7PSssQKy1kjtqWWdOcgcK9Y4ZBWmLIqdi2N590nR)ObgAGENX0lENX4z)n3ZuREkR8hJEM9n8TEMi7MVy)yxa)Z2E9m5k6cC2W36zAYQxVZKC3I7HVfjXsckwwsUnk8YGeZuy2sjjBrYcdFyfnWqdejyT1Iey3Wo8YGKzNKfqc(cusqrFNr5KGVtis6ItceYldssj6012VKKU9Ags6ItYzjU5iHH4ifCA8mVapuG3ptGcduKDpLvsoss0adngHJR)y)Cxj5assmsosY5KeDwRyG7ifCAOvpLvojhjj6SwXGfD6A73F2RzgA1tzLtYrsqSAo)JgyObAG7f)J0gqYbKW4x8oJXj2BUNPw9uw5pg9m7B4B9mr2nFX(XUa(NT96zEpDZ6pAGHgO3zm9mVapuG3ptGcduKDpLvsoss0adngHJR)y)Cxj5assmsosY5KeDwRyG7ifCAOvpLvojhj5CssJKOZAfdK2aVm(LByh4nqhA1tzLtYrsqSAo)JgyObAG7f)J0gqYbKGPbEpL1bUx8psBW)cflmmjPsYrssJKZjj6SwXGfD6A73F2RzgA1tzLtIvRKKgjrN1kgSOtxB)(ZEnZqREkRCsoscIvZ5F0adnqdCV4FK2asMFssymjPssQptUIUaNn8TEMjEvLLeZuy2sjjqSKSfjnIe8Uors0adnqK0isyxeYNYQLKOmJRYgKG1wlsGDd7WldsMDswaj4lqjbf9DgLtc(oHibRh2KKs0PRTFjjD71mJx8oJXZ7n3ZuREkR8hJEM9n8TEM4EX)iTbpZ7PBw)rdm0a9oJPNPxHcaqSX3HFMHFNbDqsg)m9kuaaIn(ooUY9o0NjtpZlWdf49ZeXQ58pAGHgObUx8psBajhqcMg49uwh4EX)iTb)luSWWpZRD71ZKPx8oJXj03CptT6PSYFm6z23W36zI7f)dN7tptVcfaGyJVd)md)od6GKm(4D3mFXwdmRZ)tBogqSptVcfaGyJVJJRCVd9zY0Z8A3E9mz6fVZyC66n3ZuREkR8hJEMCfDboB4B9mNfsjXmfMTersJij3OGeGIwqqIdtYwKe2kj4lg9z23W36zISB(I9JDb8px7W(fVZymZ6n3ZuREkR8hJEMCfDboB4B9mNfsjXmfMTussJij3OGeGIwqqIdtYwKe2kj4lgLKU4KyMcZwIiXrKSfjmCIEM9n8TEMi7MVy)yxa)Z2E9Ix8INjgfG8TENXyMZyMyEcLXmZptSnO8Ya9mtH0jX3zm7ZyMMnsizoBLehNDbbjWlGKeMfO3fFQJeMeGMIqoq5KGwCLKgkw8ouojx7Umu0GSiD7LscJNnsy4TWOGq5KKWOfkp5fFWqlHjjwssy0cLN8IpyOn0QNYkpHjjnMygPoils3EPKW4zJegElmkiuojjmAHYtEXhm0sysILKegTq5jV4dgAdT6PSYtys6GKesIlDtsAmXmsDqwqwKcPtIVZy2NXmnBKqYC2kjoo7ccsGxajj8LJsysaAkc5aLtcAXvsAOyX7q5KCT7YqrdYI0Txkjj0zJegElmkiuojjCa8Agng90DC3nZxSvctsSKKW3DZ8fBn6PBctsAmXmsDqwKU9sjHznBKWWBHrbHYjjHrluEYl(GHwctsSKKWOfkp5fFWqBOvpLvEctsAmXmsDqwqwWSXzxqOCsywK03W3IKSJc0GS4zYcwypRpZ0NEsmTB(ILKucCffKfPp9Kybu(ejmzjjmM5mMjYcYI0NEsMdR2ZqYHwNtYClaOvqcwBTijAGHgKCxOkqK0aLe4fCv(GSGSi9PNKecZqVqHYjzsHxGsYDXN6GKj1Wl0GK05Ev2arsT1HLDdWHHYK03W3crYw5tdYI(g(wOblqVl(uhmizcyxSk4JDb8p8ccpG4QLoCsGI3EHM)SZCMtw03W3cnyb6DXN6GbjtaCwr2xqdhw6WjrluEYl(Gfcfqz9Rai2W3YQv0cLN8IpWS5o8S(rBgJwbzrFdFl0GfO3fFQdgKmbi7MVyHxaULoCYZNGGHhi7MVyHxa(aILSOVHVfAWc07Ip1bdsMGgC7s)XcaAfw6Wj9c1LhNgCf2VECatZJSOVHVfAWc07Ip1bdsMamnW7PSAz14AsCV4FK2G)fkwyylx2KinSetNH0KmMSOVHVfAWc07Ip1bdsMamnoRd87pwORnzbzr6tpjPCdFlezrFdFlusKN16QKf9n8Tqjz3W3Ysho5eem8aZ6C4fGpGyTADccgEWUyvW3lyiKV1aILSOVHVfIbjtaMg49uwTSACnjFd0hI1YLnjsdlX0zinjFJbYU5l2p2fW)STxJWVZ4LXr(gdmnoRd87pwOR9i87mEzqw03W3cXGKjatd8EkRwwnUMSZ5pFd0hI1YLnjsdlX0zinjFJbYU5l2p2fW)STxJWVZ4LXr(gdmnoRd87pwOR9i87mEzCKVXGRywiGxgF2CBaPJWVZ4Lbzr6jXmAqqceYldsm1g4LbjN5g2bEdus6GKzNbKenWqdejlGKeJbK4WKCAHiPbkjErYHwNdVaCYI(g(wigKmbyAG3tz1YQX1KiTbEz8l3WoWBG(VqXcdB5YMePHLy6mKMeXQ58pAGHgObUx8psBWbmMbtqWWdmRZHxa(aILSi9KWW7M5l2IKuUBMKd1aVNYQLKmlKYjjwsy3ntYKcVaLK(goMo8YGemRZHxa(Geggca0kYNibcPCsILK7wbyZKG1wlsILK(goMousWSohEb4KG1dBs86U4EzqsZ5ObzrFdFledsMamnW7PSAz14As2DZF4f8VCKLlBsKgwIPZqAY7Uz(ITgywN)vaeB4BnGypM25G25FfJwXO5C0aI1Qvq78VIrRy0CoAWHaD4Bn)KmXCRwbTZ)kgTIrZ5ObqXBVqhKKjMZG5Dysl6SwXWgQmuGxgFmRZhA1tzLB16DXOvxXyMtaVRut9yAPbAN)vmAfJMZrdVoGXm3QveRMZ)ObgAGgywN)vaeB4BDqY5LQvRrN1kg2qLHc8Y4JzD(qREkRCRwVlgT6kgZCc4DL6X0ohavk8cm0bI1wbk6B3a8Ton0ueYzzvUvRPD3nZxS1GDXQGVxWqiFRbqXBVqZpPXLpWBMXHz2TADccgEWUyvW3lyiKV1aI1Q1PfHoc7g2XhO4TxO5NKXZl1ujl6B4BHyqYea7aDkVl3sho5eem8aZ6C4fGpGyjl6B4BHyqYemPaKcMXldlD4KtqWWdmRZHxa(aILSi9KmlKss62nSJegrIfqCdCTcsCyscBfOK0aLegtYcibFbkjrdm0azjjlGKMZrK0aTs4GeeBJT8YGe4fqc(cusc7UijDnp0GSOVHVfIbjtq2nSd0)WgIBGRvyPdNeXQ58pAGHgOr2nSd0)WgIBGRvCqsgB1AANdAN)vmAfJMZrdLz4Oaz1kOD(xXOvmAohn86G018sLSOVHVfIbjtqxxffGo)VDoBPdNCccgEGzDo8cWhqSKf9n8TqmizcUDo)7B4B9ZokSSACn5f7LSOVHVfIbjtaaQ(9n8T(zhfwwnUMeV9ISGSi9PNK0jLPBsILeiKscwBTiHr7wKSWKe2kjPd6Qfx5K4is6B4yuYI(g(wOX0UvYgD1IR8)uUrHLoCseRMZ)ObgAGg4EX)iTbZp5Stw03W3cnM2TyqYe0ORwCL)RftBPdNeXQ58pAGHgOrJUAXv(Vwm9bmDeXQ58pAGHgObUx8psBWbmXGOZAfdK2aVm(LByh4nqhA1tzLtwqwK(0tcdNiezr6jzwiLKuUyvajm7cgc5BrcwpSj5qRZHxa(GegQnZjbEbKCO15WlaNK7IRiswyysU7M5l2IeVijSvskLzeKWeZjbP3T4is2WwbyDKscesjzlsUCsGQSIqKe2kjS5(KciXrKW2GGKfMKWwjzMtaVlsUlgT6kSKKfqIdtsyRaLeSEotsTbjtkjDTHTci5qRZjjHaGydFlscBhrcSByhdssNiuC2GKyjbDQUKe2kj5gfKWUyvajEbdH8TizHjjSvsGDd7GKyjbZ6CsuaeB4Brc8ciP2IKeVNaExObzrFdFl04YrjzxSk47fmeY3YshojlWvumqAg(ZUyvW3lyiKV1X0MGGHhywNdVa8beRvRNFxmA1vmM5eW764D3mFXwdmRZ)kaIn8TgafV9cDqsMyUvRtlcDe2nSJpqXBVqZ)UBMVyRbM15FfaXg(wdGI3EHs9yAWUHD8bkE7f6GK3DZ8fBnWSo)Rai2W3Aau82ledyAEhV7M5l2AGzD(xbqSHV1aO4TxO5N04YpmjMvRWUHD8bkE7f6G7Uz(ITgSlwf89cgc5Bn4qGo8TSAf2nSJpqXBVqZ)UBMVyRbM15FfaXg(wdGI3EHyatZZQ17IrRUIXmNaExwTobbdpMY7YZqOyaXMkzr6jzwiLetpR1vjzlsy4ersSKWc2ljMkRned9jmIKuc2BUX7W3AqwKEs6B4BHgxoIbjtaYZADvlJgyOX3HtcGkfEbg6aPS2qm0J(SG9MB8o8TgAkc5SSk)yArdm0y4OFZ5wTgnWqJbxNGGHh3gfEzmaAFJujlspjZcPKWOMBOK4fY5kjlmjh6WjbEbKe2kjWoafKaHuswajBrcdNisA4qbKe2kjWoafKaH0bjPGh2KCMByhKC4TsI9M5KaVaso0Hpil6B4BHgxoIbjtaes)EO4wwnUMe5fmu(BKBU3Xcq)PMBO)f(dRG96XjlD4KtqWWdmRZHxa(aI1Q1WX1dyI5ht787IrRUIr5g2XhU1ujlspjZcPKC4TscZeud4Exis2IegorKSqbY5kjlmjhADo8cWhKmlKsYH3kjmtqnG7DXrK4fjhADo8cWjXHj50crIDJrjr9WwbKWmbwmkjm7cJBSGo8TizbKC4UM5KSWKWO8IqloAqsk0Eqc8ciHVbIKyjzsjbILKjfEbkj9nCmD4LbjhERKWmb1aU3fIKyjbVzgoUJuscBLKjiy4bzrFdFl04YrmizcGB9Ba1aU3fYsho55tqWWdmRZHxa(aI9yANF3nZxS1aZ68FSaGwXaI1Q1ZJoRvmWSo)hlaOvm0QNYkp1JPHPbEpL1bFd0hI9iIvZ5F0adnqdmnoRd87pwORDsMSATVHJr)8ngyACwh43FSqx7KiwnN)rdm0anW04SoWV)yHU2hrSAo)JgyObAGPXzDGF)XcDTpGPuTADccgEGzDo8cWhqShtdTq5jV4ddWIr)EHXnwqh(wdT6PSYTAfTq5jV4dyxZ8)c)NYlcT4OHw9uw5PswKEsMfsjHH4f3OXvejyT1IKoNjz2jjr7CisAGsceRLKSasoTqK0aLeVi5qRZHxa(GKesHGakjmuqLHc8YGKdToNeSEotck8CMKjLeiwsWARfjHTsYTrbjHJRKa7LJSv0GeZyzjbc5LbjDqY8yajrdm0arcwpSjXuBGxgKCMByh4nqhKf9n8TqJlhXGKja3lUrJRilVNUz9hnWqdusMS0Ht6fQlponFMzMFmT0W0aVNY6OZ5pFd0hI9yANF3nZxS1aZ68VcGydFRbeRvRNhDwRyydvgkWlJpM15dT6PSYtnvRwNGGHhywNdVa8beBQht78OZAfdBOYqbEz8XSoFOvpLvUvRCDccgEydvgkWlJpM15dGI3EHo42O4hoUA165tqWWdmRZHxa(aIn1JPDE0zTIbsBGxg)YnSd8gOdT6PSYTAfXQ58pAGHgObUx8psBW8NxQKfPNKzHusMvzV5tKC2IPjzlsy4ezjj2BM7LbjtaxHZNijwsW2Eqc8ciHDXQas8cgc5BrYciP5CsqSn2cnil6B4BHgxoIbjtauzV5t)AX0w6WjtlTZbTZ)kgTIrZ5Obe7rq78VIrRy0CoA41bmM5PA1kOD(xXOvmAohnakE7f6GKmnpRwbTZ)kgTIrZ5Obhc0HV18zAEPEmTjiy4b7IvbFVGHq(wdiwRwV7M5l2AWUyvW3lyiKV1aO4TxOdsYeZTA9CwGROyG0m8NDXQGVxWqiFRupM25rN1kg2qLHc8Y4JzD(qREkRCRw56eem8WgQmuGxgFmRZhqSwTE(eem8aZ6C4fGpGytLSi9KmlKsYwKWWjIKjOGewGVapCKsceYldso06Cssiai2W3IeyhGcljXHjbcPCs8c5CLKfMKdD4KSfjMZrcesjPHdfqstcM15tBoibEbKC3nZxSfjkmSFDTUNiPlojWlGeBOYqbEzqcM15KaXgoUsIdts0zTcLpil6B4BHgxoIbjtW0U1FH)HT(B0vlUYT0HtE(eem8aZ6C4fGpGypE(D3mFXwdmRZ)kaIn8TgqShrSAo)JgyObAG7f)J0gCathpp6SwXaPnWlJF5g2bEd0Hw9uw5wTM2eem8aZ6C4fGpGypIy1C(hnWqd0a3l(hPny(m(45rN1kgiTbEz8l3WoWBGo0QNYk)yASafZ34YhmnWSo)pT54yANRPiKZYQ8HIZEcOD(VaE11vTA98OZAfdBOYqbEz8XSoFOvpLvEQwTQPiKZYQ8HIZEcOD(VaE11vpgaVMrJHIZEcOD(VaE11vh3DZ8fBnakE7fA(jzkHY4JCDccgEydvgkWlJpM15di2ut1Q10MGGHhywNdVa8be7XOZAfdK2aVm(LByh4nqhA1tzLNkzrFdFl04YrmizcUDo)7B4B9ZokSSACnza8AgnqKfPNKzHuso8SISVGgoizHcKZvswysWBVi5UBMVylejXscE7v0ErYH2ChEwjXCZy0kizccgEqw03W3cnUCedsMa4SISVGgoS0HtIwO8Kx8bMn3HN1pAZy0koE(eem8aZ6C4fGpGypE(eem8GDXQGVxWqiFRbelzbzr6tpjmCJcssbBpRKWWnk8YGK(g(wObjMAqshKy7g2kGewGVaporsSKGSxqqY1bxipiXRqbai2GK7wCp8TqKSfjmeV4KyQnibhEUprwKEsMfsjXuBGxgKCMByh4nqjXHj50crcwpNjX2ds0AHmSjjAGHgis6ItskxSkGeMDbdH8TiPlojhADo8cWjPbkj1gKa0MFYsswajXscqHbkYMeZuy2sjjBrsGDjzbKGVaLKObgAGgKf9n8TqJl2BsK2aVm(LByh4nqTecPFS2Ew)3gfEzKKjlVNUz9hnWqdusMS0HtMgMg49uwhiTbEz8l3WoWBG(VqXcdF8CmnW7PSoy3n)HxW)YrPA1AA8ngi7MVy)yxa)Z2Enakmqr29uwpIy1C(hnWqd0a3l(hPn4aMsLSi9KyAVGGeg2bxipiXuBGxgKCMByh4nqj5Uf3dFlsILKzuLLeZuy2sjjqSK4fjPZMqil6B4BHgxSxgKmbiTbEz8l3WoWBGAjes)yT9S(Vnk8YijtwEpDZ6pAGHgOKmzPdNm6SwXaPnWlJF5g2bEd0Hw9uw5h5Bmq2nFX(XUa(NT9AauyGIS7PSEeXQ58pAGHgObUx8psBWbmMSi9KSv(0)I9scEpJIijSvs6B4BrYw5tKaH6PSschc4Lbjx7Ukn7LbjDXjP2GKgrstcqnGYnGK(g(wdYI(g(wOXf7LbjtaUx8)uUrHLBLp9VyVjzISGSOVHVfAWXn(bWRz0aLecPFpuClRgxtYBWm47wFUEN5)zHcGIUADvYI(g(wObh34haVMrdedsMaiK(9qXTSACnjcQMY7Y)nUg2NqbzrFdFl0GJB8dGxZObIbjtaes)EO4wwnUM0iFI1(VW)gHCCp3HVfzrFdFl0GJB8dGxZObIbjtaes)EO4wwnUMKd0Md7a9JrrintwqwK(0tcdP9IK0jLPBljbzVqzoj3fJciPZzsaDzOiswysIgyObIKU4KGUA1aFrKf9n8Tqd82RK3oN)9n8T(zhfwwnUMCA3Ysho5eem8yA36VW)Ww)n6Qfx5diwYI(g(wObE7fdsMaUJy18hVn8RLoCYZJgyOXWrF2CFsbKfPNKzHuso06Cssiai2W3IKTi5UBMVylsy3n7LbjDqswBuqsIXCs8c1LhNizckiP2GehMKtlejy9CMKfJcUnljEH6YJtK4fjh6WhKWq6zusqqaLeKDZxSWUw8eG7fFslUciPlojmeV4KWOCJcsCejBrYD3mFXwKmPWlqj5qjKbjmBJAbkjS7M9YGeGIcGFdFlejomjqiVmiX0U5lw4CJRKKsGJWjPlojmslUciXrKSqXGSOVHVfAG3EXGKjaZ68VcGydFllD4KyAG3tzDWUB(dVG)LJoMMxOU840bjtmMB1kRgdyxl(OVHJrpcGkfEbg6az38flCUX1plWr4dnfHCwwLF887Uz(ITg4EX)t5gfdi2JNF3nZxS1az38f7h7c4FU2H9aIn1JP5fQlpon)KmR5z1A0zTIbsBGxg)YnSd8gOdT6PSYpIPbEpL1bsBGxg)YnSd8gO)luSWWPE887Uz(ITgWUw8be7X0o)UBMVyRbUx8)uUrXaI1QveRMZ)ObgAGg4EX)iTbhW4ujlspjmKEgLeeeqj50crcluqceljMPWSLssshZ0jLKSfjHTss0adniXHjjfaDyddLj5WBf4kjoQs4GK(gogLeS2ArcSByhEzqcthwZojrdm0anil6B4BHg4Txmizcq2nFX(XUa(NT9Ysho5eem8aU1Vbud4ExObe7XZ56eem8alOdByO8hUvGRdi2JiwnN)rdm0anW9I)rAdMFIrw03W3cnWBVyqYeC7C(33W36NDuyz14AYlhrwKEsyOCdBssjWxGhNiHH4fNetTbK03W3IKyjbOWafztsI25qKG1dBsqAd8Y4xUHDG3aLSOVHVfAG3EXGKja3l(hPnWY7PBw)rdm0aLKjlD4KrN1kgiTbEz8l3WoWBGo0QNYk)iIvZ5F0adnqdCV4FK2GdW0aVNY6a3l(hPn4FHIfg(458ngi7MVy)yxa)Z2Enc)oJxghp)UBMVyRbSRfFaXswKEssjqHvajXscesjjrnE1HVfjPJz6KssCys66ejjANJehrsTbjqSdYI(g(wObE7fdsMaEJxD4Bz590nR)ObgAGsYKLoCYZX0aVNY6OZ5pFd0hILSi9KmlKsIPDZxSKKclGtsI0oSjXHjbc5LbjM2nFXcNBCLKucCeojDXjzslUcibRNZKOmdwhOKWHaEzqsyRKukZiiX4YhKf9n8Tqd82lgKmbi7MVy)yxa)Z1oST0HtYQXa21Ip6B4y0JaOsHxGHoq2nFXcNBC9ZcCe(qtriNLv5hz1ya7AXhafV9cn)Kgxozr6jjDYy7tisGqkj4EXNYnkqK4WKCBwwLtsxCsSHkdf4LbjywNtIJibILKU4KaH8YGet7MVyHZnUsskbocNKU4KmPfxbK4isGyhKqs6W5E4B158jlj52OGeCV4t5gfK4WKCAHib7cL5KmPKav9uwjjwsm0GKWwjb4WbjtNibB7HxgK0KyC5dYI(g(wObE7fdsMaCV4)PCJclD4KPD3nZxS1a3l(Fk3OyCTBGHIoGPJPX1jiy4HnuzOaVm(ywNpGyTA98OZAfdBOYqbEz8XSoFOvpLvEQwTYQXa21IpakE7fA(jVnk(HJRmW4Yt9iRgdyxl(OVHJrpcGkfEbg6az38flCUX1plWr4dnfHCwwLFKvJbSRfFau82l0b3gf)WXvYI0tYSqkjhADojmAZbjDqITByRasyb(c84ejy9WMegkOYqbEzqYHwNtceljXssIrs0adnqwsYcizdBfqs0zTcejBrI5CdYI(g(wObE7fdsMamRZ)tBoS0Ht6fQlpon)KmR5Dm6SwXWgQmuGxgFmRZhA1tzLFm6SwXaPnWlJF5g2bEd0Hw9uw5hrSAo)JgyObAG7f)J0gm)KjuRwtlTOZAfdBOYqbEz8XSoFOvpLv(XZJoRvmqAd8Y4xUHDG3aDOvpLvEQwTIy1C(hnWqd0a3l(hPnijtPswKEss0wjCqcesjjrkMfc4LbjPm3gqkjomjNwisUDrIHgK4vSKCO15WlaNeVqH2CljzbK4WKyQnWldsoZnSd8gOK4isIoRvOCs6ItcwpNjX2ds0AHmSjjAGHgObzrFdFl0aV9IbjtaxXSqaVm(S52asT0HtMgqHbkYUNYQvREH6YJthKUMxQht7CmnW7PSoy3n)HxW)YrwT6fQlpoDqsM18s9yANhDwRyG0g4LXVCd7aVb6qREkRCRwtl6SwXaPnWlJF5g2bEd0Hw9uw5hphtd8EkRdK2aVm(LByh4nq)xOyHHtnvYI0tYSqkjhIrKSfjmCIiXHj50crcFReoiPuLtsSKCBuqsIumleWldsszUnGuljPlojHTcusAGsswrisc7UijXijAGHgiswOGK0Mhjy9WMK7wCipsDqw03W3cnWBVyqYeGzD(FAZHLoCseRMZ)ObgAGg4EX)iTbZpTeJb3T4qEm4ocTvxXxV2RIgA1tzLN6rVqD5XP5NKznVJrN1kgiTbEz8l3WoWBGo0QNYk3Q1ZJoRvmqAd8Y4xUHDG3aDOvpLvozr6jzwiLet7MVyjjfwaF2ijrAh2K4WKe2kjrdm0GehrspTqbjXsc3vswajNwisSBmkjM2nFXcNBCLKucCeojAkc5SSkNeSEytcdXl(KwCfqYciX0U5lwyxloj9nCm6GSOVHVfAG3EXGKjaz38f7h7c4FU2HTL3t3S(JgyObkjtw6WjtlAGHgdBTZH9G9gZNXm)iIvZ5F0adnqdCV4FK2G5NyPA1AASAmGDT4J(gog9iaQu4fyOdKDZxSW5gx)SahHp0ueYzzvEQKfPNKzHusmHaaT4kGKyjHH08sris2IKMKObgAqsy3bjoIeJ1ldsILeURK0bjHTscWnSdschxhKf9n8Tqd82lgKmbiiaqlUc(X(XBEPiKL3t3S(JgyObkjtw6WjJgyOXiCC9h7N768z88oobbdpWSohEb4d(ITilspjZcPKCO15Km3caAfKSv(ejomjMPWSLss6ItYHMJKgOK03WXOK0fNKWwjjAGHgKGDReoiH7kjCiGxgKe2kjx7Uknpil6B4BHg4TxmizcWSo)hlaOvy590nR)ObgAGsYKLoCsmnW7PSo4BG(qShJgyOXiCC9h7N76bZ(X0MGGHhywNdVa8bFXwwTobbdpWSohEb4dGI3EHM)D3mFXwdmRZ)tBogafV9cL6X(gog9Z3yGPXzDGF)XcDTtIy1C(hnWqd0atJZ6a)(Jf6AFeXQ58pAGHgObUx8psBW8tBEmiTe6Hj6SwXiW6O4VWF4o0Hw9uw5PMkzrFdFl0aV9IbjtaUx8jT4kWshojFJbMgN1b(9hl01Ee(DgVmoMw0zTIbsBGxg)YnSd8gOdT6PSYpIy1C(hnWqd0a3l(hPn4amnW7PSoW9I)rAd(xOyHHTALVXaz38f7h7c4F22Rr43z8Yi1JPDoaQu4fyOdKDZxSW5gx)SahHp0ueYzzvUvR9nCm6NVXatJZ6a)(Jf6AFqY7PBw)AP4UIsLSi9KmlKsIzkmBjIeSEytskBVMaApJcijLOoJtcuLveIKWwjjAGHgKG1ZzsMusM08ILegZCg6izsHxGssyRKC3nZxSfj3fxrKm13zgKf9n8Tqd82lgKmbi7MVy)yxa)Z1oST0HtcGkfEbg6GT9AcO9mk4ZI6m(qtriNLv5hX0aVNY6GVb6dXEmAGHgJWX1FSF2B8zmZpiT7Uz(ITgi7MVy)yxa)Z1oShCiqh(wmW4YtLSi9KmlKsIPDZxSKWWGgztYwKWWjIeOkRiejHTcusAGssZ5is86U4Ezmil6B4BHg4Txmizcq2nFX(VGgzBPdNe0o)Ry0kgnNJgEDatmNSi9KmlKscdXlojMAdijwsUBHGWvssudMHK5Sxid7arclyVis2IK0jXLqgKmxIlrjosy4TGDaojoIKW2rK4isAsSDdBfqclWxGhNijS7IeGY3i8YGKTijDsCjesGQSIqKWBWmKe2lKHDGiXrK0tluqsSKeoUsYcfKf9n8Tqd82lgKmb4EX)iTbwEpDZ6pAGHgOKmzPdNeXQ58pAGHgObUx8psBWbyAG3tzDG7f)J0g8VqXcdFCccgEWBWm)WEHmSJbeRLx72RKmzPxHcaqSX3XXvU3HMKjl9kuaaIn(oCYWVZGoijJjlspjZcPKWq8ItYHN7tKelj3Tqq4kjjQbZqYC2lKHDGiHfSxejBrI5CdsMlXLOehjm8wWoaNehMKW2rK4isAsSDdBfqclWxGhNijS7IeGY3i8YGeOkRiej8gmdjH9czyhisCej90cfKeljHJRKSqbzrFdFl0aV9IbjtaUx8pCUpzPdNCccgEWBWm)WEHmSJbe7rmnW7PSo4BG(qSwETBVsYKLEfkaaXgFhhx5EhAsMS0Rqbai247Wjd)od6GKm(4D3mFXwdmRZ)tBogqSKfPNKzHusyiEXjHr5gfK4WKCAHiHVvchKuQYjjwsakmqr2KKODo0GeZyzj52OWlds6GKeJKfqc(cusIgyObIeSEytIP2aVmi5m3WoWBGss0zTcLtsxCsoTqK0aLKAdsGqEzqIPDZxSW5gxjjLahHtYcijLOtxB)ss62RzgiwnN)rdm0anW9I)rAdoiXZ8iXqdejHTscUxooeojlmjZJKU4Ke2kjfe(KcizHjjAGHgObjPtgTwscFjP2GewGIqKG7fFk3OGeOk8mjDots0adnqK0aLe(gHYjbRh2KCO5ibRTwKaH8YGeKDZxSW5gxjHf4iCsCysM0IRasCejnM2Z9uwhKf9n8Tqd82lgKmb4EX)t5gfw6WjX0aVNY6GVb6dXEe0o)Ry0kg4lgfxRy41b3gf)WXvgW8X8oIy1C(hnWqd0a3l(hPny(PLymGXhMOZAfdChPGtdT6PSYzqFdhJ(5BmW04SoWV)yHU2hMOZAfdw0PRTF)zVMzOvpLvodsdXQ58pAGHgObUx8psBWbjEMxQhM0y1ya7AXh9nCm6rauPWlWqhi7MVyHZnU(zbocFOPiKZYQ8ut9yANdGkfEbg6az38flCUX1plWr4dnfHCwwLB1653DZ8fBnGDT4di2JaOsHxGHoq2nFXcNBC9ZcCe(qtriNLv5wT23WXOF(gdmnoRd87pwOR9bjVNUz9RLI7kkvYI(g(wObE7fdsMamnoRd87pwORTL3t3S(JgyObkjtw6Wjbkmqr29uwpgnWqJr446p2p31dsOwTMw0zTIbUJuWPHw9uw5h5Bmq2nFX(XUa(NT9AauyGIS7PSMQvRtqWWdOcgcK9Y4ZBWmLIqdiwYI0tIjRE9otYDlUh(wKeljOyzj52OWldsmtHzlLKSfjlm8Hv0adnqKG1wlsGDd7WldsMDswaj4lqjbf9DgLtc(oHiPlojqiVmijLOtxB)ss62RziPlojNL4MJegIJuWPbzrFdFl0aV9IbjtaYU5l2p2fW)STxw6Wjbkmqr29uwpgnWqJr446p2p31dsSJNhDwRyG7ifCAOvpLv(XOZAfdw0PRTF)zVMzOvpLv(reRMZ)ObgAGg4EX)iTbhWyYI0tsIxvzjXmfMTusceljBrsJibVRtKenWqdejnIe2fH8PSAjjkZ4QSbjyT1Iey3Wo8YGKzNKfqc(cusqrFNr5KGVtisW6HnjPeD6A7xss3EnZGSOVHVfAG3EXGKjaz38f7h7c4F22llVNUz9hnWqdusMS0HtcuyGIS7PSEmAGHgJWX1FSFURhKyhpp6SwXa3rk40qREkR8JNNw0zTIbsBGxg)YnSd8gOdT6PSYpIy1C(hnWqd0a3l(hPn4amnW7PSoW9I)rAd(xOyHHt9yANhDwRyWIoDT97p71mdT6PSYTAnTOZAfdw0PRTF)zVMzOvpLv(reRMZ)ObgAGg4EX)iTbZpjJtnvYI(g(wObE7fdsMaCV4FK2alVNUz9hnWqdusMS0HtIy1C(hnWqd0a3l(hPn4amnW7PSoW9I)rAd(xOyHHT8A3ELKjl9kuaaIn(ooUY9o0KmzPxHcaqSX3Htg(Dg0bjzmzrFdFl0aV9IbjtaUx8pCUpz51U9kjtw6vOaaeB8DCCL7DOjzYsVcfaGyJVdNm87mOdsY4J3DZ8fBnWSo)pT5yaXswKEsMfsjXmfMTersJij3OGeGIwqqIdtYwKe2kj4lgLSOVHVfAG3EXGKjaz38f7h7c4FU2Hnzr6jzwiLeZuy2sjjnIKCJcsakAbbjomjBrsyRKGVyus6ItIzkmBjIehrYwKWWjISOVHVfAG3EXGKjaz38f7h7c4F22lYcYI0tYSqkjBrcdNisshZ0jLKeljgAqsI25ij87mEzqsxCsuMbRdusILKSxkjqSKmPrOasW6HnjhADo8cWjl6B4BHgbWRz0aLecPFpuClRgxtQ4SNaAN)lGxDDvlD4K3DZ8fBnWSo)Rai2W3Aau82l08tYeJTA9UBMVyRbM15FfaXg(wdGI3EHoGXPlYI0tYCGtKeljMNQljm7e)jIeSEytsIwOPSsIz03zuojmCIqK4WKWUiKpL1bjjUIK8wgkGey3WoqKG1dBsWxGscZoXFIibcPis6iuC2GKyjbDQUKG1dBs66ejxojlGKdBiuqcesjXJbzrFdFl0iaEnJgigKmbqi97HIBz14AsVqxau0tz9NIqDfq4FUIXVQLoCYjiy4bM15WlaFaXECccgEWUyvW3lyiKV1aI1Q1PfHoc7g2XhO4TxO5NKXm3Q1jiy4b7IvbFVGHq(wdi2J3DZ8fBnWSo)Rai2W3Aau82ledyAEha7g2XhO4TxiRwNGGHhywNdVa8be7X7Uz(ITgSlwf89cgc5BnakE7fIbmnVdGDd74du82lKvRPD3nZxS1GDXQGVxWqiFRbqXBVqhKKjMF8UBMVyRbM15FfaXg(wdGI3EHoijtmp1JWUHD8bkE7f6GKmXmZCYI0tI5P6sIPTQbjmeiKFjbRh2KCO15WlaNSOVHVfAeaVMrdedsMaiK(9qXTSACnjEF7jG(r2QgFCiKFT0HtE3nZxS1aZ68VcGydFRbqXBVqhWeZjlspjMNQljj(GMorcwpSjjLlwfqcZUGHq(wKaHAd1ssW7zusqqaLKyjbvoRssyRKKxSkkiHHkLKenWqdYI(g(wOra8AgnqmizcGq63df3YQX1KOfkN1i8Y4dGMozPdNCccgEWUyvW3lyiKV1aI1Q1ZzbUIIbsZWF2fRc(EbdH8TS8E6M1F0adnqjzISi9KmlKscJAUHsIxiNRKSWKCOdNe4fqsyRKa7auqcesjzbKSfjmCIiPHdfqsyRKa7auqceshKyAVGGKRdUqEqIdtcM15KOai2W3IK7Uz(ITiXrKWeZrKSasWxGssJTpnil6B4BHgbWRz0aXGKjacPFpuClRgxtI8cgk)nYn37ybO)uZn0)c)HvWE94KLoCY7Uz(ITgywN)vaeB4BnakE7f6GKmXCYI0tYSqkjzhfKSWKS1HfesjH34THssa8AgnqKSv(ejomjmuqLHc8YGKdToNKePtqWWK4is6B4yuljzbKCAHiPbkj1gKeDwRq5K4vSK4XGSOVHVfAeaVMrdedsMGBNZ)(g(w)SJclRgxtYXn(bWRz0azPdNmTZJoRvmSHkdf4LXhZ68Hw9uw5wTY1jiy4HnuzOaVm(ywNpGyt9yAtqWWdmRZHxa(aI1Q17Uz(ITgywN)vaeB4BnakE7f6aMyEQKfPNKePWnuoibUZ5P(odjWlGeiupLvs8qXrZgjZcPKSfj3DZ8fBrIxKSaUciz6ejbWRz0GeuEJbzrFdFl0iaEnJgigKmbqi97HIJS0HtobbdpWSohEb4diwRwNGGHhSlwf89cgc5BnGyTA9UBMVyRbM15FfaXg(wdGI3EHoGjM)mrS69DgJNhZ6fV49aa]] )
    

end
