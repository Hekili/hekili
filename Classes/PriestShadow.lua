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


    -- Tier 28
    spec:RegisterGear( "tier28", 188881, 188880, 188879, 188878, 188875 )
    spec:RegisterSetBonuses( "tier28_2pc", 364424, "tier28_4pc", 363469 )
    -- 2-Set - Darkened Mind - Casting Devouring Plague has a 40% chance to grant Dark Thought. Casting Searing Nightmare has a 25% chance to grant Dark Thought.
    -- 4-Set - Living Shadow - Consuming a Dark Thought causes your shadow to animate after a moment, dealing [(34%20.9% of Spell power) * 6] Shadow damage over 6 sec to all enemies within 10 yards of your target.
    spec:RegisterAura( "living_shadow", {
        id = 363574,
        duration = 8,
        max_stack = 1,
        copy = "your_shadow",
        meta = {
            summonTime = function( t ) return t.applied end,
        }
    } )

    rawset( state.pet, "your_shadow", state.buff.living_shadow )


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
                if buff.dark_thought.up and set_bonus.tier28_4pc > 0 then
                    applyBuff( "living_shadow" )
                end
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

    spec:RegisterSetting( "ignore_solvent", true, {
        name = "Ignore Volatile Solvent for Void Eruption",
        desc = "If disabled, when you have the Volatile Solvent conduit enabled, the addon will not use Void Eruption unless you currently have a Volatile Solvent buff applied (from casting Fleshcraft).",
        type = "toggle",
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


    spec:RegisterPack( "Shadow", 20211227, [[dmLvHcqijLEKKkDjuKOAtQeFcfkJss4ucuRcfiEfkOzrj1TqrsTlH(LaXWuPWXqrTmuiptGutdfPUMkfTnbs8nbqghkqDojveRta4DOirP5jaDpjP9PsP)jPIuhusfwikIhIcvtua1fvjf2ikaFefjzKOaPtkaQvsj5LOirMPajDtvsPDQsYpLurnujfDujvKSuvsr9ukmvjvDvvs1wLu4RcinwuKWEb5VQYGjoSslwqpwftgvxM0Mb1NPOrtPonvRwLuKxljA2sCBiTBf)wQHJshxaXYbEoutx01vvBhI(oegpkGoVkvRhfjkMpLy)idXmu9qg8nvORy0nyeJUbZ3GrrMzWbnZbDDcKrENvHmy3tLRPczmlQczyyV8gbKb7EV0lhQEidC)bhfYWotwCaeKGy6P9pmEA0GGD0FztVNdyHZGGD0tqGmc)EjdWduiKbFtf6kgDdgXOBW8nyuKzgCqZCqh0qg7pTBaKHHJY4qg2oNRduiKbxXhidd7L3iiPMaxXjzvG1JIgQasyuaYAsy0nyeZKvKvmU9oMkoaiRyQjPEe6wjj1ODoj13aGojjiS1HKCbMAsYP)tIjzbkjWn4O8izftnj1eOPoCs4DIjzbkjFwsqyRdj5cm1etYcusoLgRKKnj87(yAnj4MK0EtsMFLkMKfOKGtVuibONgfvhUYJqgfhNyO6Hmyb6Prd3eQEORygQEidD2WIYHycKXb4Pc8fYaOORpyscijb9nUbKXEsVhid2gHcEiAa)b3G0ZpxHsORyeu9qg6SHfLdXeiJdWtf4lKbU)LqF4r2po)f9PGpB69e1zdlkNelwib3)sOp8iYUSPx0hUli1jJ6SHfLdzSN07bYaUOy7dyHtOe6QGgQEidD2WIYHycKXb4Pc8fYOwsc)WWrS9YBeWnan(zHm2t69azGTxEJaUbOqj0vmnu9qg6SHfLdXeiJdWtf4lKHp4D88EKRW(XtsULeMVjKXEsVhiJfC2rFzda6Kqj0v3eQEidD2WIYHycKXSOkKb2E5ncL)Aq4RHFzdq1jHm2t69azGTxEJq5Vge(A4x2auDsOe6QGcu9qg6SHfLdXeiJMfYaRjKXEsVhidKlW3WIczGClFfYGrqgixWBwufYa1h(dRl4D(zdddLqxfGGQhYqNnSOCiMazCaEQaFHmQLKCl6Kr(IoB69e1zdlkhYypP3dKbYfL1b(5L9)ydLqxXGHQhYqNnSOCiMazCaEQaFHmYTOtg5l6SP3tuNnSOCiJ9KEpqgO(WFHLfNqjuczWrnFjWNk1edvp0vmdvpKHoByr5qmbYywufYGVGkr7EEC9u57X(tGIp6CuiJ9KEpqg8fujA3ZJRNkFp2Fcu8rNJcLqxXiO6Hm0zdlkhIjqgZIQqg4)ew6M)wunTVJtiJ9KEpqg4)ew6M)wunTVJtOe6QGgQEidD2WIYHycKXSOkKHz5oR9RHFlg7OEztVhiJ9KEpqgML7S2Vg(TySJ6Ln9EGsORyAO6Hm0zdlkhIjqgZIQqgCGUCyhOpKkgRfiJ9KEpqgCGUCyhOpKkgRfOekHmqxFGQh6kMHQhYqNnSOCiMazCaEQaFHmc)WWXWUNxd)sB9T4JoCLh)Sqg4e4Ne6kMHm2t69azC2s5TN075vCCczuCC(MfvHmc7EGsORyeu9qg6SHfLdXeiJdWtf4lKrTKKlWuZOJFSL9UcGm2t69azWDmRwEORPFGsORcAO6Hm0zdlkhIjqg7j9EGmq2o)PGpB69azWv8b4SP3dKX1Xkj1ODojxdWNn9EiPhsoDx4nIHe2Ul(ysYMKu0fNKWOBsIp4D88ojH)KKPtsCysU3Fsq4LcjnsfCwws8bVJN3jXhsQbdisY1UvQKG)aLed7L3iGDD4b5A9HhQdxbKSdNKR1hojmPS4KehtspKC6UWBedjHkCdusQX1GehMed7L3iGllQsIJjrdKVZYQ8ijbyZPbkjSDx8XKeGItGFsVhmjomjFSpMKyyV8gbCzrvsQjWXOKSdNeMOdxbK4ys6FgHmoapvGVqgixGVHfnY2D5b3G3HJj5cjvqIp4D88oj3wLegDtsSyHewnJWUo84EshPsYfsa)rHBGPgX2lVraxwu9XcCmAudKVZYQCsUqsTKC6UWBete1h(lSS4m(zj5cj1sYP7cVrmrS9YBepenG)46M2XpljbtYfsQGeFW745DscyvsyW3Kelwij3IozeRlWhZ34M2j6c0OoByr5KCHeKlW3WIgX6c8X8nUPDIUa9D(zddtsWKCHKAj50DH3iMiSRdp(zj5cjvqsTKG7Fj0hEezx20l6d3fK6KrD2WIYjXIfsc)WWrKDztVOpCxqQt(S)O70op(zjXIfsWAM(yIJU50a9H7csDsscgkHUIPHQhYqNnSOCiMazSN07bYaBV8gXdrd4p21hidUIpaNn9EGmU2TsLe8hOKCV)KW(ts(SKyeObqnjPomQJAsspKK2kj5cm1KehMKafSPn8VqcdyvGRK44HXss2t6ivsqyRdjWUPD6JjjmZuh0KKlWutCeY4a8ub(cze(HHJWR(m)lG77GJFwsUqsTKW1WpmCebytB4F5bVkW14NLKlKGz1s5LlWutCe1h(dRlGKasctdLqxDtO6Hm0zdlkhIjqg7j9EGmoBP82t698kooHmkooFZIQqghogkHUkOavpKHoByr5qmbYypP3dKbQp8hwxaKX5(POVCbMAIHUIziJdWtf4lKrUfDYiwxGpMVXnTt0fOrD2WIYj5cjywTuE5cm1ehr9H)W6ci5wsqUaFdlAe1h(dRl4D(zddtYfsQLeENrS9YBepenG)yxFIPFQ0htsUqsTKC6UWBete21Hh)SqgCfFaoB69azWG6M2KutG3apVtY16dNedDbKSN07HKSjbOWafBtsG76XKGWtBsW6c8X8nUPDIUafkHUkabvpKHoByr5qmbYypP3dKbFrNn9EGmo3pf9LlWutm0vmdzCaEQaFHmQGeENrKlkRd8Zl7)XocuyGIT3WIsIflKW7mITxEJ4HOb8h76teOWafBVHfLelwiPcsQLKWpmCe1h(JRi7pqbXpljxiXh8oEENKasYnVbjbtsWKCHKkij8ddh5lOYxA3Ft7mIZ9ujjbKKWpmCKVGkFPD)nTZi6YaF4CpvsIflKuljynFH98XX0vaJyWpgXEijyidUIpaNn9EGmQjqHvajztYhRKe4fD207HK6WOoQjjomjgbAautsAaj1OEsCmjtNK8zjPbKCV)KC2z6KKZItswsMgGUfscSIS)aFmjPML18RKuHpNYN7JjjxRpCscSIS)afqclOp4Gjzhoj37pji8sHKPtsolljbEbvss92930oXKGZ9ujMehMKp2htsQNrmysye7jcLqxXGHQhYqNnSOCiMazSN07bYaBV8gXdrd4pUUPnKbxXhGZMEpqgxhRKyyV8gbjbAd4KeyDtBsCys(yFmjXWE5nc4YIQKutGJrjzhojH6Wvaji8sHeLbY6aLe(h4JjjPTsYOmWKeZdpczCaEQaFHmy1mc76WJ7jDKkjxib8hfUbMAeBV8gbCzr1hlWXOrnq(olRYj5cjSAgHDD4rGIU(GjjGvjX8WHsORQtGQhYqNnSOCiMazSN07bYa1h(lSS4eYGR4dWztVhiJ6OGyVJj5Jvsq9HhwwCIjXHj5SSSkNKD4Ky)htf4JjjiBNtIJj5ZsYoCs(yFmjXWE5nc4YIQKutGJrjzhojH6WvajoMKpBKesQdo3tVNTuUBnjNfNKG6dpSS4KehMK79Nee9VWjjuj5pByrjjBsm1KK0wjb4WjjH3jbX6PpMKSKyE4riJdWtf4lKrfKC6UWBete1h(lSS4mESxGPIj5wsyMKlKubjCn8ddhT)JPc8X8HSDE8ZsIflKulj5w0jJ2)Xub(y(q2opQZgwuojbtIflKWQze21Hhbk66dMKawLKZIZx6OkjmKeZdNKGj5cjSAgHDD4X9KosLKlKa(Jc3atnITxEJaUSO6Jf4y0OgiFNLv5KCHewnJWUo8iqrxFWKCljNfNV0rvsSyHKWpmCKVGkFPD)nTZ4NLKlKe(HHJiBNd3a04NLKlKuljNUl8gXer2o)f2Lm(zj5cjvqsTKa(Jc3atnITxEJaUSO6Jf4y0OgiFNLv5KyXcj1scRMryxhECpPJujjysUqcwZxypFCmDfWig8JPzpqj0vmFdO6Hm0zdlkhIjqg7j9EGmq2o)f2LeYGR4dWztVhiJRJvsQr7Csysxss2KeB30wbKWc8g45Dsq4PnjmO)Xub(yssnANtYNLKSjHPjjxGPMyRjPbK0PTcij3IojMKEiXO(iKXb4Pc8fYWh8oEENKawLeg8nj5cj5w0jJ2)Xub(y(q2opQZgwuojxij3IozeRlWhZ34M2j6c0OoByr5KCHemRwkVCbMAIJO(WFyDbKeWQKeuiXIfsQGKkij3Ioz0(pMkWhZhY25rD2WIYj5cj1ssUfDYiwxGpMVXnTt0fOrD2WIYjjysSyHemRwkVCbMAIJO(WFyDbKuLeMjjyOe6kMzgQEidD2WIYHycKXEsVhidUIS)aFmFSL18RqgCfFaoB69aze4EySKKpwjjWkY(d8XKKAwwZVsIdtY9(tYzhsm1KeFYMKA0ohUbOK4do1LBnjnGehMedDb(ysYvUPDIUaLehtsUfDsLtYoCsq4Lcj2EsIo930MKCbMAIJqghGNkWxiJkibOWafBVHfLelwiXh8oEENKBjjaDtsSyHKCl6KrKTZFzda6KrD2WIYj5cjNUl8gXer2o)LnaOtgbk66dMKawLKGMegesmpCscMKlKubj1scYf4ByrJSDxEWn4D4ysSyHeFW745DsUTkjm4BssWKCHKkiPwsYTOtgX6c8X8nUPDIUanQZgwuojwSqsfKKBrNmI1f4J5BCt7eDbAuNnSOCsUqsTKGCb(gw0iwxGpMVXnTt0fOVZpByyscMKGHsORyMrq1dzOZgwuoetGm2t69azGSD(lSljKbxXhGZMEpqgxhRKudMqspKW4bMehMK79NeEpmwsYOkNKSj5S4KKaRi7pWhtsQzzn)Q1KSdNK0wbkjlqjPOymjP9oKW0KKlWutmj9pjPIBsccpTj50d)7zWriJdWtf4lKbMvlLxUatnXruF4pSUascijvqcttcdj50d)7zK7yCp7Kp9y3koQZgwuojbtYfs8bVJN3jjGvjHbFtsUqsUfDYiwxGpMVXnTt0fOrD2WIYjXIfsQLKCl6KrSUaFmFJBANOlqJ6SHfLdLqxXCqdvpKHoByr5qmbYypP3dKb2E5nIhIgWFCDtBiJZ9trF5cm1edDfZqghGNkWxiJkijxGPMrBDlPDK9KKeqsy0ni5cjywTuE5cm1ehr9H)W6cijGKW0KemjwSqsfKWQze21Hh3t6ivsUqc4pkCdm1i2E5nc4YIQpwGJrJAG8DwwLtsWqgCfFaoB69azCDSsIH9YBeKeOnGhaKeyDtBsCyssBLKCbMAsIJjzd7Fss2KWDLKgqY9(tI9IujXWE5nc4YIQKutGJrjrdKVZYQCsq4PnjxRp8qD4kGKgqIH9YBeWUoCs2t6i1iucDfZmnu9qg6SHfLdXeiJ9KEpqg4paOdxbVSFOlFumgY4C)u0xUatnXqxXmKXb4Pc8fYixGPMX0r1x2pURKeqsy0nj5cjHFy4iY25WnanYBedKbxXhGZMEpqgxhRKy8baD4kGKSj5Ax(Oymj9qYssUatnjjT3KehtIz7Jjjztc3vs2KK0wjb4M2jjPJQrOe6kMVju9qg6SHfLdXeiJ9KEpqgiBN)Yga0jHmo3pf9LlWutm0vmdzCaEQaFHmqUaFdlAK3j(9zj5cjvqs4hgoISDoCdqJ8gXqIflKe(HHJiBNd3a0iqrxFWKeqsoDx4nIjISD(lSlzeOORpysSyHewGI8zE4rMJiBN)c7ssYfsQLKWpmCmS0nV8XzeO7jj5cjywTuE5cm1ehr9H)W6cijGKe0KemjxizpPJuF8oJixuwh4Nx2)Jnj3wLKZ9trF6OOUIj5cjywTuE5cm1ehr9H)W6cijGKubj3KegssfKeuiHbHKCl6KXeHJZxd)G3uJ6SHfLtsWKemKbxXhGZMEpqgxhRKuJ25KuFda6KK0t5ojomjgbAauts2HtsnQNKfOKSN0rQKSdNK0wjjxGPMKGOhgljH7kj8pWhtssBLKJ9oJwIqj0vmhuGQhYqNnSOCiMazCaEQaFHm4DgrUOSoWpVS)h7y6Nk9XKKlKubj5w0jJyDb(y(g30orxGg1zdlkNKlKGz1s5LlWutCe1h(dRlGKBjb5c8nSOruF4pSUG35NnmmjwSqcVZi2E5nIhIgWFSRpX0pv6JjjbtYfsQGKAjb8hfUbMAeBV8gbCzr1hlWXOrnq(olRYjXIfs2t6i1hVZiYfL1b(5L9)ytYTvj5C)u0NokQRyscgYypP3dKbQp8qD4kakHUI5aeu9qg6SHfLdXeiJ9KEpqgy7L3iEiAa)X1nTHm4k(aC207bY46yLeJanacmji80MKAU(ec0TsfqsnXBbLK)uumMK0wjjxGPMKGWlfscvsc1sJGegDdMYjjuHBGssARKC6UWBedjNgvXKeUNkJqghGNkWxidWFu4gyQr21NqGUvQGhlElOrnq(olRYj5cjixGVHfnY7e)(SKCHKCbMAgthvFz)yp5Jr3GKBjPcsoDx4nIjITxEJ4HOb8hx30oY)Gn9EiHHKyE4KemucDfZmyO6Hm0zdlkhIjqg7j9EGmW2lVr8oGfBdzWv8b4SP3dKX1Xkjg2lVrqcJdwSnj9qcJhys(trXyssBfOKSaLKLZXK4ZPr9XmczCaEQaFHmaRZFksDY4Y54OpKCljmFdOe6kMRtGQhYqNnSOCiMazSN07bYa1h(dRlaY4C)u0xUatnXqxXmKHpPcaF285WqgPFQeFBvMgYWNubGpB(CuuL7BQqgmdzCaEQaFHmWSAP8YfyQjoI6d)H1fqYTKGCb(gw0iQp8hwxW78ZggMKlKe(HHJ8fu5lT7VPDg)Sqgh71hidMHsORy0nGQhYqNnSOCiMazWv8b4SP3dKX1XkjxRpCsyaL9ojztYPh8hvjjWlOssQ3U)M2jMewqFWK0djg1ts)tSZvsAysQbdiczCaEQaFHmc)WWr(cQ8L2930oJFwsUqcYf4ByrJ8oXVpljxiPwsc)WWrKTZHBaA8ZsYfsQLeKlW3WIgz7U8GBW7WXKCHKt3fEJyIO(WFHLfNr4FP8a6XEbM6lDuLKBRsI5HhrxgiKHpPcaF285WqgPFQeFBvM(sTHFy4iFbv(s7(BANXplKHpPcaF285OOk33uHmygY4yV(azWmKXEsVhiduF4p4YEhkHUIrmdvpKHoByr5qmbYypP3dKbQp8xyzXjKbxXhGZMEpqgxhRKCT(WjHjLfNK4WKCV)KW7HXssgv5KKnjafgOyBscCxposIr2SKCwC6JjjBscttsdibTbkj5cm1etccpTjXqxGpMKCLBANOlqjj3IoPYjzhoj37pjlqjz6KKp2htsmSxEJaUSOkj1e4yusAaj1eF)y7hscQ(uzeZQLYlxGPM4iQp8hwxWT1PVjjMAIjjTvsq9Xr)OK0WKCts2HtsARKmF0qfqsdtsUatnXrsQJcUTMeEtY0jjSafJjb1hEyzXjj)j9cjBPqsUatnXKSaLeENPYjbHN2KuJ6jbHToK8X(ysc2E5nc4YIQKWcCmkjomjH6WvajoMKf56LnSOriJdWtf4lKbYf4ByrJ8oXVpljxibSo)Pi1jJOnsfvNm6dj3sYzX5lDuLegsYnI3KKlKGz1s5LlWutCe1h(dRlGKassfKW0KWqsyejmiKKBrNmI6yfCpQZgwuojmKK9Kos9X7mICrzDGFEz)p2KWGqsUfDYil((X2pVIpvg1zdlkNegssfKGz1s5LlWutCe1h(dRlGKBRttYnjjysyqiPcsy1mc76WJ7jDKkjxib8hfUbMAeBV8gbCzr1hlWXOrnq(olRYjjyscMKlKubj1sc4pkCdm1i2E5nc4YIQpwGJrJAG8DwwLtIflKuljNUl8gXeHDD4Xpljxib8hfUbMAeBV8gbCzr1hlWXOrnq(olRYjXIfs2t6i1hVZiYfL1b(5L9)ytYTvj5C)u0NokQRyscgkHUIrmcQEidD2WIYHycKXEsVhidKlkRd8Zl7)XgY4C)u0xUatnXqxXmKXb4Pc8fYOcsakmqX2Byrj5cj5cm1mMoQ(Y(XDLKBjjOqIflKubj5w0jJOowb3J6SHfLtYfs4DgX2lVr8q0a(JD9jcuyGIT3WIssWKemjxiPcsQLKCl6Kr(IoB69e1zdlkNelwi50DH3iMiFrNn9EIafD9btYTvjH3ze5IY6a)8Y(FSJafD9btIflKC6UWBetKVOZMEprGIU(Gj52QKW7mITxEJ4HOb8h76teOORpyscMelwij8ddh)d8hu8X8XxqLJIXXplKbxXhGZMEpqgxZkmqX2KuJfL1b(HK67)XMeeowl3jjCXkNKEijWl6SP3dj7WjPtBfqs9BrNehHsORyuqdvpKHoByr5qmbYypP3dKb2E5nIhIgWFSRpqgCfFaoB69azyWQhFlKC6H7P3djztcoBwsolo9XKeJanaQjj9qsddZuNlWutmjiS1Hey30o9XKKGMKgqcAdusW5EQu5KG2Hys2HtYh7Jjj1eF)y7hscQ(ujj7Wj5Q6C9KCTowb3JqghGNkWxidGcduS9gwusUqsUatnJPJQVSFCxj5wsyAsUqsTKKBrNmI6yfCpQZgwuojxij3IozKfF)y7NxXNkJ6SHfLtYfsWSAP8YfyQjoI6d)H1fqYTKWiOe6kgX0q1dzOZgwuoetGm2t69azGTxEJ4HOb8h76dKX5(POVCbMAIHUIziJdWtf4lKbqHbk2EdlkjxijxGPMX0r1x2pURKCljmnjxiPwsYTOtgrDScUh1zdlkNKlKuljvqsUfDYiwxGpMVXnTt0fOrD2WIYj5cjywTuE5cm1ehr9H)W6ci5wsqUaFdlAe1h(dRl4D(zddtsWKCHKkiPwsYTOtgzX3p2(5v8PYOoByr5KyXcjvqsUfDYil((X2pVIpvg1zdlkNKlKGz1s5LlWutCe1h(dRlGKawLegrsWKemjxiPcsQLKCl6Kr(IoB69e1zdlkNelwi50DH3iMiFrNn9EIafD9btYTvjH3zeBV8gXdrd4p21NiqrxFWKemKbxXhGZMEpqgmLuLLeJanaQjjFws6HKftc6o3jjxGPMyswmjSng7Hf1Asug4rztsqyRdjWUPD6JjjbnjnGe0gOKGZ9uPYjbTdXKGWtBsQj((X2pKeu9PYiucDfJUju9qg6SHfLdXeiJ9KEpqgO(WFyDbqgN7NI(YfyQjg6kMHm8jva4ZMphgYi9tL4BRYiidFsfa(S5ZrrvUVPczWmKXb4Pc8fYaZQLYlxGPM4iQp8hwxaj3scYf4ByrJO(WFyDbVZpByysUqsfKulj4(xc9Hhr2Ln9I(WDbPozuNnSOCsSyHKAj50DH3iMiCrX2hWcNXpljbdzCSxFGmygkHUIrbfO6Hm0zdlkhIjqg7j9EGmq9H)Gl7DidFsfa(S5ZHHms)uj(2Qm6sf1g(HHJ8fu5lT7VPDg)SwSC6UWBetez78xyxY4N9sfHFy4iY25Wnan(zTyP2WpmCKVGkFPD)nTZ4N9s4hgoYDmUNDYNESBfh)SbhmKHpPcaF285OOk33uHmygY4yV(azWmKXb4Pc8fYOwsW9Ve6dpISlB6f9H7csDYOoByr5KyXcj1sYP7cVrmr4IITpGfoJFwOe6kgfGGQhYqNnSOCiMazSN07bYaUOy7dyHtidFsfa(S5ZHHms)uj(2Qmdz4tQaWNnFokQY9nvidMHmoapvGVqg4(xc9Hhr2Ln9I(WDbPozuNnSOCsUqsTKe(HHJiBNd3a04NLKlKuljHFy4iBJqbpFG)yVN4NfYGR4dWztVhiJRJvsyaffBFalCss)tSZvsAysqxFi50DH3igmjztc66tU(qsn6YMErjXOli1jjj8ddhHsORyedgQEidD2WIYHycKbxXhGZMEpqgxhRKyeObqGjzXKuwCscqXnijXHjPhssBLe0gPczSN07bYaBV8gXdrd4pUUPnucDfJQtGQhYqNnSOCiMazWv8b4SP3dKX1XkjgbAautswmjLfNKauCdssCys6HK0wjbTrQKSdNeJanacmjoMKEiHXdmKXEsVhidS9YBepenG)yxFGsOeY4G4avp0vmdvpKHoByr5qmbY4J1hcBVOVZItFmHUIziJ9KEpqgyDb(y(g30orxGczCUFk6lxGPMyORygY4a8ub(czubjixGVHfnI1f4J5BCt7eDb678ZggMKlKuljixGVHfnY2D5b3G3HJjjysSyHKkiH3zeBV8gXdrd4p21NiqHbk2EdlkjxibZQLYlxGPM4iQp8hwxaj3scZKemKbxXhGZMEpqgxhRKyOlWhtsUYnTt0fOK4WKCV)KGWlfsS9KeD6VPnj5cm1etYoCsQzJqbKeGh4p27HKD4KuJ25WnaLKfOKmDscqx(DRjPbKKnjafgOyBsmc0aOMK0djjIMKgqcAdusYfyQjocLqxXiO6Hm0zdlkhIjqgFS(qy7f9DwC6Jj0vmdzSN07bYaRlWhZ34M2j6cuiJZ9trF5cm1edDfZqghGNkWxiJCl6KrSUaFmFJBANOlqJ6SHfLtYfs4DgX2lVr8q0a(JD9jcuyGIT3WIsYfsWSAP8YfyQjoI6d)H1fqYTKWiidUIpaNn9EGmmSBqscJ7GZ3tsm0f4Jjjx5M2j6cuso9W907HKSjPsvzjXiqdGAsYNLeFiPo6RbucDvqdvpKHoByr5qmbYONY93bXbYGziJ9KEpqgO(WFHLfNqgCfFaoB69az0t5(7G4qc6wPIjjTvs2t69qspL7K8XByrjH)b(ysYXENrl(ysYoCsMojzXKSKauZFzbKSN07jcLqjKrc8PsnXq1dDfZq1dzOZgwuoetGm4k(aC207bY46yLKEiHXdmj1HrDutsYMetnjjWD9KK(PsFmjzhojkdK1bkjztsXhLKpljHAMkGeeEAtsnANd3auiJzrvidfL9oq3YRb8zNJczCaEQaFHmoDx4nIjISD(tbF207jcu01hmjbSkjmZisSyHKt3fEJyIiBN)uWNn9EIafD9btYTKWOaeKXEsVhidfL9oq3YRb8zNJcLqxXiO6Hm0zdlkhIjqgCfFaoB69azup4ojztIX95qsaUovGjbHN2Ke4(hwusmY9uPYjHXdmMehMe2gJ9WIgjPopKu6XubKa7M2jMeeEAtcAduscW1PcmjFSIjzZurztsYMe895qccpTjzN7KC4K0asUM(4KKpwjXZiKXSOkKHp4d4NByrFbYFN8J(4ks)OqghGNkWxiJWpmCez7C4gGg)SKCHKWpmCKTrOGNpWFS3t8ZsIflKe2ymjxib2nTZhqrxFWKeWQKWOBqIflKe(HHJSncf88b(J9EIFwsUqYP7cVrmrKTZFk4ZMEprGIU(GjHHKW8nj5wsGDt78bu01hmjwSqs4hgoISDoCdqJFwsUqYP7cVrmr2gHcE(a)XEprGIU(GjHHKW8nj5wsGDt78bu01hmjwSqsfKC6UWBetKTrOGNpWFS3teOORpysUTkjmFdsUqYP7cVrmrKTZFk4ZMEprGIU(Gj52QKW8nijysUqcSBANpGIU(Gj52QKWCDYnGm2t69az4d(a(5gw0xG83j)OpUI0pkucDvqdvpKHoByr5qmbYGR4dWztVhidJ7ZHedBvtsU2p2pKGWtBsQr7C4gGczmlQczGUNneOpSTQ5d9J9dKXb4Pc8fY40DH3iMiY25pf8ztVNiqrxFWKCljmFdiJ9KEpqgO7zdb6dBRA(q)y)aLqxX0q1dzOZgwuoetGmMfvHmW9Vu0m9X8b(H3Hmo3pf9LlWutm0vmdzSN07bYa3)srZ0hZh4hEhY4a8ub(cze(HHJSncf88b(J9EIFwsSyHKAjHf4koJyTa)yBek45d8h79qIflKObY3zzvEeBV8gHYFni81WVSbO6KqgCfFaoB69azyCFoKCn)dVtccpTjPMncfqsaEG)yVhs(41uTMe0TsLe8hOKKnj4XzvssBLKsJqXjjmO1KKCbMAgjjqT1HKpw5KGWtBsmSxEJq5KuNbHK0WKuFdq1jTMKRPpoj5Jvs6HegpWKSysq)hBswmjSng7HfncLqxDtO6Hm0zdlkhIjqgCfFaoB69azCDSsctwUPsIpyNRK0WKudgajWnGK0wjb2b4KKpwjPbK0djmEGjzHtfqsARKa7aCsYhRrsmSBqsYXbNVNK4WKGSDojk4ZMEpKC6UWBedjoMeMVbMKgqcAduswe79iKXSOkKb2h4F5zwwUVzdWVWLBQVg(bRG(45DiJdWtf4lKXP7cVrmrKTZFk4ZMEprGIU(Gj52QKW8nGm2t69azG9b(xEMLL7B2a8lC5M6RHFWkOpEEhkHUkOavpKHoByr5qmbYGR4dWztVhiJRJvsmSxEJq5KuNbHK0WKuFdq1jjbHToKmDsIpKuJ25Wna1AsAaj(qsOMiuDiPgTZjHjDjj5S4etIpKuJ25WnanssDGjHP0DGVdjnGKR0dOlnGtsXhLepj5ZsccpTjbN7PsLtYP7cVrm4iKXSOkKb2E5ncL)Aq4RHFzdq1jHmoapvGVqgNUl8gXezBek45d8h79ebk66dMKawLeMVbjxi50DH3iMiY25pf8ztVNiqrxFWKeWQKW8ni5cjvqYPrQZozC0dOlnGtIflKCAK6StgR8oW3HKGjXIfsQGKtJuNDYisDs77asSyHKtJuNDY44M25dEvscMKlKubj1ss4hgoISDoCdqJFwsSyHewGI8zE4rMJiBN)c7sssWKyXcjHngtYfsGDt78bu01hmjbSkjm9nGm2t69azGTxEJq5Vge(A4x2auDsOe6Qaeu9qg6SHfLdXeidUIpaNn9EGmUowjP44KKgMKEyQ)yLe(IUMkjjWNk1etspL7K4WKWG(htf4Jjj1ODojbwd)WWK4ys2t6ivRjPbKCV)KSaLKPtsYTOtQCs8jBs8mczSN07bY4SLYBpP3ZR44eYaNa)KqxXmKXb4Pc8fYOcsQLKCl6Kr7)yQaFmFiBNh1zdlkNelwiHRHFy4O9FmvGpMpKTZJFwscMKlKubjHFy4iY25Wnan(zjXIfsoDx4nIjISD(tbF207jcu01hmj3scZ3GKGHmkooFZIQqgCuZxc8PsnXqj0vmyO6Hm0zdlkhIjqg7j9EGm(y95PIIHm4k(aC207bYiWk8(ljjWBPeUNkjbUbK8XByrjXtffhaKCDSsspKC6UWBedj(qsd4kGKW7KKaFQutsWLoJqghGNkWxiJWpmCez7C4gGg)SKyXcjHFy4iBJqbpFG)yVN4NLelwi50DH3iMiY25pf8ztVNiqrxFWKCljmFdOekHmoCmu9qxXmu9qg6SHfLdXeiJ9KEpqgSncf88b(J9EGm4k(aC207bY46yLKA2iuajb4b(J9EibHN2KuJ25WnanscdAx4Ka3asQr7C4gGsYPrvmjnmmjNUl8gXqIpKK2kjJYatsy(gKG1tpCmjDARaeowj5Jvs6HKdNK)uumMK0wjHTS3vajoMe2fKK0WKK2kjvEh47qYPrQZoP1K0asCyssBfOKGWlfsMojjujzNoTvaj1ODojxdWNn9EijTDmjWUPDgjPoYurztsYMe895qsARKuwCscBJqbK4d8h79qsdtsARKa7M2jjztcY25KOGpB69qcCdiz6HeMs3b(o4iKXb4Pc8fYGf4koJyTa)yBek45d8h79qYfsQGKWpmCez7C4gGg)SKyXcj1sYPrQZozSY7aFhsUqsTKCAK6Stgh9a6sd4KCHKt3fEJyIiBN)uWNn9EIafD9btYTvjH5BqIflKa7M25dOORpyscijNUl8gXer2o)PGpB69ebk66dMKGj5cjvqcSBANpGIU(Gj52QKC6UWBetez78Nc(SP3teOORpysyijmFtsUqYP7cVrmrKTZFk4ZMEprGIU(GjjGvjX8WjHbHeMMelwib2nTZhqrxFWKCljNUl8gXezBek45d8h79e5FWMEpKyXcjHngtYfsGDt78bu01hmjbKKt3fEJyIiBN)uWNn9EIafD9btcdjH5BsIflKCAK6StgR8oW3Helwij8ddhdlDZlFCg)SKemucDfJGQhYqNnSOCiMazWv8b4SP3dKX1Xkjmz5Mkj(GDUssdtsnyaKa3assBLeyhGts(yLKgqspKW4bMKfovajPTscSdWjjFSgjjq90MKRCt7KegWQKy3fojWnGKAWaIqgZIQqgyFG)LNzz5(Mna)cxUP(A4hSc6JN3HmoapvGVqgHFy4iY25Wnan(zjXIfsshvj5wsy(gKCHKkiPwsonsD2jJJBANp4vjjyiJ9KEpqgyFG)LNzz5(Mna)cxUP(A4hSc6JN3HsORcAO6Hm0zdlkhIjqg7j9EGmGx9z(xa33bdzWv8b4SP3dKX1XkjmGvjHP6VaUVdMKEiHXdmj9pXoxjPHjPgTZHBaAKKRJvsyaRsct1FbCFhoMeFiPgTZHBakjomj37pj2lsLe1tBfqctfOrQKeGhKUzd207HKgqcdW1cNKgMeMuAmUrXrsc01tsGBaj8oXKKnjHkjFwscv4gOKSN0rUPpMKWawLeMQ)c4(oysYMe0Lb6OowjjTvsc)WWriJdWtf4lKrTKe(HHJiBNd3a04NLKlKubj1sYP7cVrmrKTZFzda6KXpljwSqsTKKBrNmISD(lBaqNmQZgwuojbtYfsQGeKlW3WIg5DIFFwsUqcMvlLxUatnXrKlkRd8Zl7)XMKQKWmjwSqYEshP(4DgrUOSoWpVS)hBsQscMvlLxUatnXrKlkRd8Zl7)XMKlKGz1s5LlWutCe5IY6a)8Y(FSj5wsyMKGjXIfsc)WWrKTZHBaA8ZsYfsQGeC)lH(WJMGgP(8bPB2Gn9EI6SHfLtIflKG7Fj0hEe21c)1WVWsJXnkoQZgwuojbdLqxX0q1dzOZgwuoetGm2t69azG6d3CrvmKX5(POVCbMAIHUIziJdWtf4lKHp4D88ojbKK6KBqYfsQGKkib5c8nSOXTuE8oXVpljxiPcsQLKt3fEJyIiBN)uWNn9EIFwsSyHKAjj3Ioz0(pMkWhZhY25rD2WIYjjyscMelwij8ddhr2ohUbOXpljbtYfsQGKAjj3Ioz0(pMkWhZhY25rD2WIYjXIfs4A4hgoA)htf4J5dz78iqrxFWKCljNfNV0rvsSyHKAjj8ddhr2ohUbOXpljbtYfsQGKAjj3IozeRlWhZ34M2j6c0OoByr5KyXcjywTuE5cm1ehr9H)W6cijGKCtscgYGR4dWztVhiJRJvsUwF4MlQIjbHToKSLcjbnjbURhtYcus(Swtsdi5E)jzbkj(qsnANd3a0ijxJb)bkjmO)Xub(yssnANtccVuibNEPqsOsYNLee26qsARKCwCss6OkjW(4yBfhjXiBws(yFmjztsUjdjjxGPMysq4Pnjg6c8XKKRCt7eDbAekHU6Mq1dzOZgwuoetGm2t69az8h7UC)nnYfYGR4dWztVhiJRJvsU(y3L7KCvJCjPhsy8aBnj2DH7JjjHaxHl3jjBsqSEscCdiHTrOas8b(J9EiPbKSCojy2fXGJqghGNkWxiJAjj3Ioz0(pMkWhZhY25rD2WIYj5cjixGVHfnY7e)(SKyXcjCn8ddhT)JPc8X8HSDE8ZsYfsc)WWrKTZHBaA8ZsIflKubjNUl8gXer2o)PGpB69ebk66dMKBjH5BqIflKuljixGVHfnY2D5b3G3HJjjysUqsTKe(HHJiBNd3a04NfkHUkOavpKHoByr5qmbYypP3dKry3ZRHFPT(w8rhUYHm4k(aC207bY46yLKEiHXdmjH)KewG3apDSsYh7Jjj1ODojxdWNn9Eib2b40AsCys(yLtIpyNRK0WKudgaj9qIr9K8XkjlCQaswsq2opSljjWnGKt3fEJyirHH9JRZ5oj7WjbUbKy)htf4JjjiBNtYNnDuLehMKCl6KkpczCaEQaFHmQLKWpmCez7C4gGg)SKCHKAj50DH3iMiY25pf8ztVN4NLKlKGz1s5LlWutCe1h(dRlGKBjHzsUqsTKKBrNmI1f4J5BCt7eDbAuNnSOCsSyHKkij8ddhr2ohUbOXpljxibZQLYlxGPM4iQp8hwxajbKegrYfsQLKCl6KrSUaFmFJBANOlqJ6SHfLtYfsQGewGI8zE4rMJiBN)c7ssYfsQGKAjrdKVZYQ8OIYEhOB51a(SZrjXIfsQLKCl6Kr7)yQaFmFiBNh1zdlkNKGjXIfs0a57SSkpQOS3b6wEnGp7CusUqYP7cVrmrfL9oq3YRb8zNJgbk66dMKawLeMdkmIKlKW1WpmC0(pMkWhZhY25XpljbtsWKyXcjvqs4hgoISDoCdqJFwsUqsUfDYiwxGpMVXnTt0fOrD2WIYjjyOe6Qaeu9qg6SHfLdXeiJ9KEpqgNTuE7j9EEfhNqgfhNVzrviJe4tLAIHsORyWq1dzOZgwuoetGmoapvGVqg26ws7i7jjjGvjjaDtiJ9KEpqgCfZQGn1hlyVRaOekHmc7EGQh6kMHQhYqNnSOCiMazCaEQaFHmWSAP8YfyQjoI6d)H1fqsaRssqdzSN07bYyXhD4k)fwwCcLqxXiO6Hm0zdlkhIjqg7j9EGmw8rhUYFtJCHm4k(aC207bYOopL7K8Xkj1b(Odx5KCvJCjbHToKmDssUfDsLtIpztIHUaFmj5k30orxGsspKWigssUatnXriJdWtf4lKbMvlLxUatnXXfF0HR830ixsULeMj5cjywTuE5cm1ehr9H)W6ci5wsyMKlKulj5w0jJyDb(y(g30orxGg1zdlkhkHsidUcV)scvp0vmdvpKXEsVhidSx05Oqg6SHfLdXeOe6kgbvpKHoByr5qmbY4a8ub(cze(HHJiBNd3a04NLelwij8ddhzBek45d8h79e)Sqg7j9EGmy707bkHUkOHQhYqNnSOCiMaz0SqgynHm2t69azGCb(gwuidKB5RqgvqcVZi2E5nIhIgWFSRpX0pv6JjjwSqsUatnJPJQVSFCxjjGvjHPjjysUqsfKW7mICrzDGFEz)p2X0pv6JjjwSqsUatnJPJQVSFCxjjGvjjOqsWqgixWBwufYG3j(9zHsORyAO6Hm0zdlkhIjqgnlKbwtiJ9KEpqgixGVHffYa5w(kKbYf4ByrJ8oXVpljxiPcs4Dg5kY(d8X8XwwZVgt)uPpMKyXcj5cm1mMoQ(Y(XDLKawLeMMKGHmqUG3SOkKXwkpEN43NfkHU6Mq1dzOZgwuoetGmAwidSMqg7j9EGmqUaFdlkKbYT8vidmRwkVCbMAIJO(WFyDbKCljmIegss4hgoISDoCdqJFwidUIpaNn9EGmmYfKK8X(ysIHUaFmj5k30orxGsYMKe0mKKCbMAIjPbKW0mKehMK79NKfOK4dj1ODoCdqHmqUG3SOkKbwxGpMVXnTt0fOVZpByyOe6QGcu9qg6SHfLdXeiJMfYaRjKXEsVhidKlW3WIczGClFfY40DH3iMiY25pf8ztVN4NLKlKubj1sc4pkCdm1iM1wbk(zVa0EUh1a57SSkNKlKuljNgPo7KXrpGU0aojwSqYP7cVrmr2gHcE(a)XEprGIU(GjjGvjX8WJOldKegescAsSyHKWpmCKTrOGNpWFS3t8ZsIflKe2ymjxib2nTZhqrxFWKeWQKWOBssWqgCfFaoB69azW4Dx4nIHKA2DHKASaFdlQ1KCDSYjjBsy7UqsOc3aLK9KoYn9XKeKTZHBaAKeg)da6KL7K8XkNKSj50tc6cjiS1HKSjzpPJCtLeKTZHBakji80MeFonQpMKSCooczGCbVzrvid2Ulp4g8oCmucDvacQEidD2WIYHycKXb4Pc8fYi8ddhr2ohUbOXplKXEsVhidyhOHLU5qj0vmyO6Hm0zdlkhIjqghGNkWxiJWpmCez7C4gGg)Sqg7j9EGmcvawbv6JjucDvDcu9qg6SHfLdXeiJ9KEpqgf30oXVRPp3evNeYGR4dWztVhiJRJvscQUPDYyysS6Znr1jjXHjjTvGsYcusyejnGe0gOKKlWutS1K0aswohtYc0HXssWSlIXhtsGBajOnqjjT3HKa0nXriJdWtf4lKbMvlLxUatnXXIBAN4310NBIQtsYTvjHrKyXcjvqsTKawN)uK6KXLZXrLb64etIflKawN)uK6KXLZXrFi5wscq3KKGHsORy(gq1dzOZgwuoetGmoapvGVqgHFy4iY25Wnan(zHm2t69azSZrXjylVZwkqj0vmZmu9qg6SHfLdXeiJ9KEpqgNTuE7j9EEfhNqgfhNVzrviJdIducDfZmcQEidD2WIYHycKXEsVhidWFE7j9EEfhNqgfhNVzrvid01hOekHsidKka79aDfJUbJyMzMzuqdzGybJpMyiJaToUMVkaFftvaqcj1BRK4OSnijbUbKWySa90OHBYyKa0a57aLtcUrvs2F2OBQCso27yQ4izvq1hLegfaKW49GubPYjHXW9Ve6dpYuWyKKnjmgU)LqF4rMIOoByr5mgjvWmdm4izvq1hLegfaKW49GubPYjHXW9Ve6dpYuWyKKnjmgU)LqF4rMIOoByr5mgjBsY1OohujPcMzGbhjRiRc064A(Qa8vmvbajKuVTsIJY2GKe4gqcJHU(WyKa0a57aLtcUrvs2F2OBQCso27yQ4izvq1hLKGoaiHX7bPcsLtcJH7Fj0hEKPGXijBsymC)lH(WJmfrD2WIYzmsQGzgyWrYQGQpkjm6MbajmEpivqQCsymC)lH(WJmfmgjztcJH7Fj0hEKPiQZgwuoJrsfmZadoswfu9rjHrbLaGegVhKkivojmgU)LqF4rMcgJKSjHXW9Ve6dpYue1zdlkNXiPcMzGbhjRcQ(OKWOauaqcJ3dsfKkNegd3)sOp8itbJrs2KWy4(xc9HhzkI6SHfLZyKubZmWGJKvKvbADCnFva(kMQaGesQ3wjXrzBqscCdiHXoCmJrcqdKVduoj4gvjz)zJUPYj5yVJPIJKvbvFusckbajmEpivqQCsySe4tLAg3Wt80DH3iggJKSjHXoDx4nIjUHhgJKkyMbgCKSISkaJY2Gu5KWGjzpP3djfhN4izfKblOH9Iczu36sIH9YBeKutGR4KSQU1LKaRhfnubKWOaK1KWOBWiMjRiRQBDjHXT3XuXbazvDRljm1KupcDRKKA0oNK6BaqNKee26qsUatnj50)jXKSaLe4gCuEKSQU1LeMAsQjqtD4KW7etYcus(SKGWwhsYfyQjMKfOKCknwjjBs439X0AsWnjP9MKm)kvmjlqjbNEPqcqpnkQoCLhjRiRQBDj5AWa1ZpvojHkCdusonA4MKeQM(GJKuhNJYMysMEyQTxak8VqYEsVhmj9uUhjR2t69GJSa90OHBYWQbHTrOGhIgWFWni98ZvRD4QafD9bhWG(g3GSApP3doYc0tJgUjdRge4IITpGfoT2HRI7Fj0hEK9JZFrFk4ZMEpwSG7Fj0hEezx20l6d3fK6KKv7j9EWrwGEA0Wnzy1GGTxEJaUbOw7WvRn8ddhX2lVra3a04NLSApP3doYc0tJgUjdRgKfC2rFzda6Kw7Wv9bVJN3JCf2pEElZ3KSApP3doYc0tJgUjdRgKpwFEQOwplQwfBV8gHYFni81WVSbO6KKv7j9EWrwGEA0Wnzy1GGCb(gwuRNfvRI6d)H1f8o)SHHTUzRI10AKB5Rvzez1EsVhCKfONgnCtgwniixuwh4Nx2)JT1oC1AZTOtg5l6SP3tuNnSOCYQ9KEp4ilqpnA4MmSAqq9H)clloT2HRMBrNmYx0ztVNOoByr5KvKv1TUKuZo9EWKv7j9EWvXErNJswTN07bxLTtVhRD4QHFy4iY25Wnan(zTyj8ddhzBek45d8h79e)SKv7j9EWmSAqqUaFdlQ1ZIQv5DIFFwRB2QynTg5w(A1k4DgX2lVr8q0a(JD9jM(PsFmTyjxGPMX0r1x2pURbSkth8Lk4DgrUOSoWpVS)h7y6Nk9X0ILCbMAgthvFz)4UgWQbLGjR2t69Gzy1GGCb(gwuRNfvRULYJ3j(9zTUzRI10AKB5RvrUaFdlAK3j(9zVubVZixr2FGpMp2YA(1y6Nk9X0ILCbMAgthvFz)4UgWQmDWKv1LeJCbjjFSpMKyOlWhtsUYnTt0fOKSjjbndjjxGPMysAajmndjXHj5E)jzbkj(qsnANd3auYQ9KEpygwniixGVHf16zr1QyDb(y(g30orxG(o)SHHTUzRI10AKB5RvXSAP8YfyQjoI6d)H1fClJyy4hgoISDoCdqJFwYQ6scJ3DH3igsQz3fsQXc8nSOwtY1XkNKSjHT7cjHkCdus2t6i30htsq2ohUbOrsy8paOtwUtYhRCsYMKtpjOlKGWwhsYMK9KoYnvsq2ohUbOKGWtBs850O(ysYY54iz1EsVhmdRgeKlW3WIA9SOAv2Ulp4g8oCS1nBvSMwJClFT6P7cVrmrKTZFk4ZMEpXp7LkQf8hfUbMAeZARaf)SxaAp3JAG8DwwLFP2tJuNDY4OhqxAa3ILt3fEJyISncf88b(J9EIafD9bhWQMhEeDzGmibTflHFy4iBJqbpFG)yVN4N1ILWgJVa7M25dOORp4awLr3myYQ9KEpygwniWoqdlDZT2HRg(HHJiBNd3a04NLSApP3dMHvdsOcWkOsFmT2HRg(HHJiBNd3a04NLSQUKCDSssq1nTtgdtIvFUjQojjomjPTcuswGscJiPbKG2aLKCbMAITMKgqYY5yswGomwscMDrm(yscCdibTbkjP9oKeGUjoswTN07bZWQbP4M2j(Dn95MO6Kw7WvXSAP8YfyQjowCt7e)UM(CtuDYBRYilwQOwW68NIuNmUCooQmqhNylwaRZFksDY4Y54Op3gGUzWKv7j9EWmSAq25O4eSL3zlfRD4QHFy4iY25Wnan(zjR2t69Gzy1GC2s5TN075vCCA9SOA1dIdz1EsVhmdRgeWFE7j9EEfhNwplQwfD9HSISQU1LK6OMbvsYMKpwjbHToKWKUhsAyssBLK6aF0HRCsCmj7jDKkz1EsVhCmS7P6Ip6Wv(lSS40AhUkMvlLxUatnXruF4pSUGawnOjRQlj15PCNKpwjPoWhD4kNKRAKljiS1HKPtsYTOtQCs8jBsm0f4Jjjx5M2j6cus6HegXqsYfyQjoswTN07bhd7Eyy1GS4JoCL)Mg5ATdxfZQLYlxGPM44Ip6Wv(BAK7TmFbZQLYlxGPM4iQp8hwxWTmFP2Cl6KrSUaFmFJBANOlqJ6SHfLtwrwv36scJhymzvDj56yLKA2iuajb4b(J9EibHN2KuJ25WnanscdAx4Ka3asQr7C4gGsYPrvmjnmmjNUl8gXqIpKK2kjJYatsy(gKG1tpCmjDARaeowj5Jvs6HKdNK)uumMK0wjHTS3vajoMe2fKK0WKK2kjvEh47qYPrQZoP1K0asCyssBfOKGWlfsMojjujzNoTvaj1ODojxdWNn9EijTDmjWUPDgjPoYurztsYMe895qsARKuwCscBJqbK4d8h79qsdtsARKa7M2jjztcY25KOGpB69qcCdiz6HeMs3b(o4iz1EsVhC8WXvzBek45d8h79yTdxLf4koJyTa)yBek45d8h79CPIWpmCez7C4gGg)SwSu7PrQZozSY7aFNl1EAK6Stgh9a6sd4xoDx4nIjISD(tbF207jcu01h8Tvz(gwSa7M25dOORp4aE6UWBetez78Nc(SP3teOORp4GVubSBANpGIU(GVT6P7cVrmrKTZFk4ZMEprGIU(GziZ38YP7cVrmrKTZFk4ZMEprGIU(GdyvZdNbHPTyb2nTZhqrxFW3E6UWBetKTrOGNpWFS3tK)bB69yXsyJXxGDt78bu01hCapDx4nIjISD(tbF207jcu01hmdz(MwSCAK6StgR8oW3XILWpmCmS0nV8Xz8ZgmzvDj56yLedVOZrjPhsy8ats2KWc6djgkR9NPmmgMKAc6tzr307jswvxs2t69GJhoMHvdc2l6CuRZfyQ5ZHRc(Jc3atnIvw7ptzWpwqFkl6MEprnq(olRYVurUatnJo(TCUfl5cm1mY1WpmC8S40hZiq3tgmzvDj56yLeMSCtLeFWoxjPHjPgmasGBajPTscSdWjjFSssdiPhsy8atYcNkGK0wjb2b4KKpwJKeOEAtYvUPDscdyvsS7cNe4gqsnyarYQ9KEp44HJzy1G8X6Ztf16zr1QyFG)LNzz5(Mna)cxUP(A4hSc6JN3T2HRg(HHJiBNd3a04N1IL0r1Bz(gxQO2tJuNDY44M25dE1GjRQljxhRKWawLeMQ)c4(oys6HegpWK0)e7CLKgMKA0ohUbOrsUowjHbSkjmv)fW9D4ys8HKA0ohUbOK4WKCV)KyVivsupTvajmvGgPssaEq6MnytVhsAajmaxlCsAysysPX4gfhjjqxpjbUbKW7ets2KeQK8zjjuHBGsYEsh5M(yscdyvsyQ(lG77GjjBsqxgOJ6yLK0wjj8ddhjR2t69GJhoMHvdc8QpZ)c4(oyRD4Q1g(HHJiBNd3a04N9sf1E6UWBetez78x2aGoz8ZAXsT5w0jJiBN)Yga0jJ6SHfLh8LkqUaFdlAK3j(9zVGz1s5LlWutCe5IY6a)8Y(FSRYSfl7jDK6J3ze5IY6a)8Y(FSRIz1s5LlWutCe5IY6a)8Y(FSVGz1s5LlWutCe5IY6a)8Y(FSVL5GTyj8ddhr2ohUbOXp7LkW9Ve6dpAcAK6ZhKUzd207jQZgwuUfl4(xc9HhHDTWFn8lS0yCJIJ6SHfLhmzvDj56yLKR1hU5IQysqyRdjBPqsqtsG76XKSaLKpR1K0asU3FswGsIpKuJ25WnansY1yWFGscd6FmvGpMKuJ25KGWlfsWPxkKeQK8zjbHToKK2kjNfNKKoQscSpo2wXrsmYMLKp2hts2KKBYqsYfyQjMeeEAtIHUaFmj5k30orxGgjR2t69GJhoMHvdcQpCZfvXwFUFk6lxGPM4QmBTdx1h8oEEpG1j34sfvGCb(gw04wkpEN43N9sf1E6UWBetez78Nc(SP3t8ZAXsT5w0jJ2)Xub(y(q2opQZgwuEWbBXs4hgoISDoCdqJF2GVurT5w0jJ2)Xub(y(q2opQZgwuUflCn8ddhT)JPc8X8HSDEeOORp4BploFPJQwSuB4hgoISDoCdqJF2GVurT5w0jJyDb(y(g30orxGg1zdlk3IfmRwkVCbMAIJO(WFyDbb8MbtwvxsUowj56JDxUtYvnYLKEiHXdS1Ky3fUpMKecCfUCNKSjbX6jjWnGe2gHciXh4p27HKgqYY5KGzxedoswTN07bhpCmdRgK)y3L7VPrUw7WvRn3Ioz0(pMkWhZhY25rD2WIYVGCb(gw0iVt87ZAXcxd)WWr7)yQaFmFiBNh)Sxc)WWrKTZHBaA8ZAXsfNUl8gXer2o)PGpB69ebk66d(wMVHfl1ICb(gw0iB3LhCdEhoo4l1g(HHJiBNd3a04NLSQUKCDSsspKW4bMKWFsclWBGNowj5J9XKKA0oNKRb4ZMEpKa7aCAnjomjFSYjXhSZvsAysQbdGKEiXOEs(yLKfovajljiBNh2LKe4gqYP7cVrmKOWW(X15CNKD4Ka3asS)JPc8XKeKTZj5ZMoQsIdtsUfDsLhjR2t69GJhoMHvdsy3ZRHFPT(w8rhUYT2HRwB4hgoISDoCdqJF2l1E6UWBetez78Nc(SP3t8ZEbZQLYlxGPM4iQp8hwxWTmFP2Cl6KrSUaFmFJBANOlqJ6SHfLBXsfHFy4iY25Wnan(zVGz1s5LlWutCe1h(dRliGm6sT5w0jJyDb(y(g30orxGg1zdlk)sfSaf5Z8WJmhr2o)f2L8sf1QbY3zzvEurzVd0T8AaF25OwSuBUfDYO9FmvGpMpKTZJ6SHfLhSflAG8DwwLhvu27aDlVgWNDo6Le4tLAgvu27aDlVgWNDoA80DH3iMiqrxFWbSkZbfgDHRHFy4O9FmvGpMpKTZJF2Gd2ILkc)WWrKTZHBaA8ZEj3IozeRlWhZ34M2j6c0OoByr5btwTN07bhpCmdRgKZwkV9KEpVIJtRNfvRMaFQutmz1EsVhC8WXmSAq4kMvbBQpwWExbw7WvT1TK2r2tgWQbOBswrwv36scJV4KKa12lkjm(ItFmjzpP3dosIHMKSjj2UPTciHf4nWZ7KKnjy7gKKCCW57jj(Kka8ztso9W907btspKCT(WjXqxqqyaL9ozvDj56yLedDb(ysYvUPDIUaLehMK79NeeEPqITNKOt)nTjjxGPMys2HtsnBekGKa8a)XEpKSdNKA0ohUbOKSaLKPtsa6YVBnjnGKSjbOWafBtIrGga1KKEijr0K0asqBGssUatnXrYQ9KEp44bXPkwxGpMVXnTt0fOw)X6dHTx03zXPpMvz26Z9trF5cm1exLzRD4QvGCb(gw0iwxGpMVXnTt0fOVZpBy4l1ICb(gw0iB3LhCdEhooylwQG3zeBV8gXdrd4p21NiqHbk2Edl6fmRwkVCbMAIJO(WFyDb3YCWKv1Led7gKKW4o489KedDb(ysYvUPDIUaLKtpCp9EijBsQuvwsmc0aOMK8zjXhsQJ(AqwTN07bhpiomSAqW6c8X8nUPDIUa16pwFiS9I(olo9XSkZwFUFk6lxGPM4QmBTdxn3IozeRlWhZ34M2j6c0OoByr5x4DgX2lVr8q0a(JD9jcuyGIT3WIEbZQLYlxGPM4iQp8hwxWTmISQUK0t5(7G4qc6wPIjjTvs2t69qspL7K8XByrjH)b(ysYXENrl(ysYoCsMojzXKSKauZFzbKSN07jswTN07bhpiomSAqq9H)clloTUNY93bXPkZKvKv7j9EWroQ5lb(uPM4QFS(8urTEwuTkFbvI29846PY3J9NafF05OKv7j9EWroQ5lb(uPMygwniFS(8urTEwuTk(pHLU5Vfvt774KSApP3doYrnFjWNk1eZWQb5J1NNkQ1ZIQvnl3zTFn8BXyh1lB69qwTN07bh5OMVe4tLAIzy1G8X6Ztf16zr1QCGUCyhOpKkgRfYkYQ6wxsU21hsQJAguTMeSD)lCsonsfqYwkKa2XuXK0WKKlWutmj7WjbF0zbEJjR2t69GJORpvpBP82t698kooTEwuTAy3J14e4NSkZw7Wvd)WWXWUNxd)sB9T4JoCLh)SKv7j9EWr01hgwniChZQLh6A6hRD4Q1MlWuZOJFSL9UciRQljxhRKuJ25KCnaF207HKEi50DH3igsy7U4JjjBssrxCscJUjj(G3XZ7Ke(tsMojXHj5E)jbHxkK0ivWzzjXh8oEENeFiPgmGijx7wPsc(dusmSxEJa21HhKR1hEOoCfqYoCsUwF4KWKYItsCmj9qYP7cVrmKeQWnqjPgxdsCysmSxEJaUSOkjoMenq(olRYJKeGnNgOKW2DXhtsakob(j9EWK4WK8X(ysIH9YBeWLfvjPMahJsYoCsyIoCfqIJjP)zKSApP3doIU(WWQbbz78Nc(SP3J1oCvKlW3WIgz7U8GBW7WXxQWh8oEE)2Qm6MwSWQze21Hh3t6i1lG)OWnWuJy7L3iGllQ(ybognQbY3zzv(LApDx4nIjI6d)fwwCg)SxQ90DH3iMi2E5nIhIgWFCDt74Nn4lv4dEhpVhWQm4BAXsUfDYiwxGpMVXnTt0fOrD2WIYVGCb(gw0iwxGpMVXnTt0fOVZpBy4GVu7P7cVrmryxhE8ZEPIAX9Ve6dpISlB6f9H7csDslwc)WWrKDztVOpCxqQt(S)O70op(zTybRz6Jjo6Mtd0hUli1jdMSQUKCTBLkj4pqj5E)jH9NK8zjXiqdGAssDyuh1KKEijTvsYfyQjjomjbkytB4FHegWQaxjXXdJLKSN0rQKGWwhsGDt70htsyMPoOjjxGPM4iz1EsVhCeD9HHvdc2E5nIhIgWFSRpw7Wvd)WWr4vFM)fW9DWXp7LA5A4hgoIaSPn8V8Gxf4A8ZEbZQLYlxGPM4iQp8hwxqazAYQ9KEp4i66ddRgKZwkV9KEpVIJtRNfvRE4yYQ6scdQBAtsnbEd88ojxRpCsm0fqYEsVhsYMeGcduSnjbURhtccpTjbRlWhZ34M2j6cuYQ9KEp4i66ddRgeuF4pSUaRp3pf9LlWutCvMT2HRMBrNmI1f4J5BCt7eDbAuNnSO8lywTuE5cm1ehr9H)W6cUf5c8nSOruF4pSUG35Nnm8LA5DgX2lVr8q0a(JD9jM(PsFmVu7P7cVrmryxhE8ZswvxsQjqHvajztYhRKe4fD207HK6WOoQjjomjgbAautsAaj1OEsCmjtNK8zjPbKCV)KC2z6KKZItswsMgGUfscSIS)aFmjPML18RKuHpNYN7JjjxRpCscSIS)afqclOp4Gjzhoj37pji8sHKPtsolljbEbvss92930oXKGZ9ujMehMKp2htsQNrmysye7jswTN07bhrxFyy1GWx0ztVhRp3pf9LlWutCvMT2HRwbVZiYfL1b(5L9)yhbkmqX2ByrTyH3zeBV8gXdrd4p21NiqHbk2EdlQflvuB4hgoI6d)XvK9hOG4N9Ip4D88EaV5nco4lve(HHJ8fu5lT7VPDgX5EQmGHFy4iFbv(s7(BANr0Lb(W5EQ0ILAXA(c75JJPRagXGFmI9emzvDj56yLed7L3iijqBaNKaRBAtIdtYh7Jjjg2lVraxwuLKAcCmkj7WjjuhUcibHxkKOmqwhOKW)aFmjjTvsgLbMKyE4rYQ9KEp4i66ddRgeS9YBepenG)46M2w7Wvz1mc76WJ7jDK6fWFu4gyQrS9YBeWLfvFSahJg1a57SSk)cRMryxhEeOORp4aw18WjRQlj1rbXEhtYhRKG6dpSS4etIdtYzzzvoj7WjX(pMkWhtsq2oNehtYNLKD4K8X(ysIH9YBeWLfvjPMahJsYoCsc1HRasCmjF2ijKuhCUNEpBPC3Asolojb1hEyzXjjomj37pji6FHtsOsYF2WIss2KyQjjPTscWHtscVtcI1tFmjzjX8WJKv7j9EWr01hgwniO(WFHLfNw7WvR40DH3iMiQp8xyzXz8yVatfFlZxQGRHFy4O9FmvGpMpKTZJFwlwQn3Ioz0(pMkWhZhY25rD2WIYd2IfwnJWUo8iqrxFWbS6zX5lDuLHMhEWxy1mc76WJ7jDK6fWFu4gyQrS9YBeWLfvFSahJg1a57SSk)cRMryxhEeOORp4BploFPJQwSe(HHJ8fu5lT7VPDg)Sxc)WWrKTZHBaA8ZEP2t3fEJyIiBN)c7sg)SxQOwWFu4gyQrS9YBeWLfvFSahJg1a57SSk3ILAz1mc76WJ7jDKAWxWA(c75JJPRagXGFmn7HSQUKCDSssnANtct6ssYMKy7M2kGewG3apVtccpTjHb9pMkWhtsQr7Cs(SKKnjmnj5cm1eBnjnGKoTvaj5w0jXK0djg1hjR2t69GJORpmSAqq2o)f2L0AhUQp4D88EaRYGV5LCl6Kr7)yQaFmFiBNh1zdlk)sUfDYiwxGpMVXnTt0fOrD2WIYVGz1s5LlWutCe1h(dRliGvdkwSurf5w0jJ2)Xub(y(q2opQZgwu(LAZTOtgX6c8X8nUPDIUanQZgwuEWwSGz1s5LlWutCe1h(dRlOkZbtwvxscCpmwsYhRKeyfz)b(yssnlR5xjXHj5E)j5SdjMAsIpztsnANd3aus8bN6YTMKgqIdtIHUaFmj5k30orxGsIJjj3IoPYjzhoji8sHeBpjrN(BAtsUatnXrYQ9KEp4i66ddRgeUIS)aFmFSL18Rw7WvRaOWafBVHf1IfFW7459Bdq30ILCl6KrKTZFzda6KrD2WIYVC6UWBetez78x2aGozeOORp4awnOzqmp8GVurTixGVHfnY2D5b3G3HJTyXh8oEE)2Qm4Bg8LkQn3IozeRlWhZ34M2j6c0OoByr5wSurUfDYiwxGpMVXnTt0fOrD2WIYVulYf4ByrJyDb(y(g30orxG(o)SHHdoyYQ6sY1Xkj1GjK0djmEGjXHj5E)jH3dJLKmQYjjBsolojjWkY(d8XKKAwwZVAnj7WjjTvGsYcuskkgtsAVdjmnj5cm1ets)tsQ4MKGWtBso9W)EgCKSApP3doIU(WWQbbz78xyxsRD4QywTuE5cm1ehr9H)W6ccyfmndp9W)Eg5og3Zo5tp2TIJ6SHfLh8fFW7459awLbFZl5w0jJyDb(y(g30orxGg1zdlk3ILAZTOtgX6c8X8nUPDIUanQZgwuozvDj56yLed7L3iijqBapaijW6M2K4WKK2kj5cm1KehtYg2)KKSjH7kjnGK79Ne7fPsIH9YBeWLfvjPMahJsIgiFNLv5KGWtBsUwF4H6WvajnGed7L3iGDD4KSN0rQrYQ9KEp4i66ddRgeS9YBepenG)46M2wFUFk6lxGPM4QmBTdxTICbMAgT1TK2r2tgqgDJlywTuE5cm1ehr9H)W6ccithSflvWQze21Hh3t6i1lG)OWnWuJy7L3iGllQ(ybognQbY3zzvEWKv1LKRJvsm(aGoCfqs2KCTlFumMKEizjjxGPMKK2BsIJjXS9XKKSjH7kjBssARKaCt7KK0r1iz1EsVhCeD9HHvdc(da6WvWl7h6YhfJT(C)u0xUatnXvz2AhUAUatnJPJQVSFCxdiJU5LWpmCez7C4gGg5nIHSQUKCDSssnANts9naOtsspL7K4WKyeObqnjzhoj1OEswGsYEshPsYoCssBLKCbMAscIEySKeURKW)aFmjjTvso27mAjswTN07bhrxFyy1GGSD(lBaqN06Z9trF5cm1exLzRD4QixGVHfnY7e)(SxQi8ddhr2ohUbOrEJySyj8ddhr2ohUbOrGIU(Gd4P7cVrmrKTZFHDjJafD9bBXclqr(mp8iZrKTZFHDjVuB4hgogw6Mx(4mc09KxWSAP8YfyQjoI6d)H1feWGo4l7jDK6J3ze5IY6a)8Y(FSVT65(POpDuuxXxWSAP8YfyQjoI6d)H1feWkUjdRiOWGKBrNmMiCC(A4h8MAuNnSO8GdMSApP3doIU(WWQbb1hEOoCfyTdxL3ze5IY6a)8Y(FSJPFQ0hZlvKBrNmI1f4J5BCt7eDbAuNnSO8lywTuE5cm1ehr9H)W6cUf5c8nSOruF4pSUG35NnmSfl8oJy7L3iEiAa)XU(et)uPpMbFPIAb)rHBGPgX2lVraxwu9XcCmAudKVZYQClw2t6i1hVZiYfL1b(5L9)yFB1Z9trF6OOUIdMSQUKCDSsIrGgabMeeEAtsnxFcb6wPciPM4TGsYFkkgtsARKKlWutsq4LcjHkjHAPrqcJUbt5KeQWnqjjTvsoDx4nIHKtJQysc3tLrYQ9KEp4i66ddRgeS9YBepenG)46M2w7Wvb)rHBGPgzxFcb6wPcES4TGg1a57SSk)cYf4ByrJ8oXVp7LCbMAgthvFz)yp5Jr342koDx4nIjITxEJ4HOb8hx30oY)Gn9EyO5HhmzvDj56yLed7L3iiHXbl2MKEiHXdmj)POymjPTcuswGsYY5ys850O(ygjR2t69GJORpmSAqW2lVr8oGfBBTdxfSo)Pi1jJlNJJ(ClZ3GS66yLKR1hojg6cijBso9G)OkjbEbvss92930oXKWc6dMKEiPoQZxJij1xNdCDMegVhyhGsIJjjTDmjoMKLeB30wbKWc8g45Dss7DibO8otFmjPhsQJ681GK)uumMe(cQKK0U)M2jMehtYg2)KKSjjDuLK(NKv7j9EWr01hgwniO(WFyDbwFUFk6lxGPM4QmBTdxfZQLYlxGPM4iQp8hwxWTixGVHfnI6d)H1f8o)SHHVe(HHJ8fu5lT7VPDg)SwFSxFQYS1(Kka8zZNJIQCFtTkZw7tQaWNnFoC10pvIVTkttwv36ss915axNdasiHXT1tLKK2oMKR1hojmGYENehLTOO6KB69qs2KGvLehMepjjeOBLys60wbKa6F6JsYXENrlysAysUwF4KWak7DMYsc6ENKrvojztc6wPssA7yscb6w5AQK0t5ojiAqLKGWtBssBLeSMKe2ZhhjRQljxhRKCT(WjHbu27KKnjNEWFuLKaVGkjPE7(BANysyb9btspKyupj9pXoxjPHjPgmGiz1EsVhCeD9HHvdcQp8hCzVBTdxn8ddh5lOYxA3Ft7m(zVGCb(gw0iVt87ZEP2WpmCez7C4gGg)SxQf5c8nSOr2Ulp4g8oC8Lt3fEJyIO(WFHLfNr4FP8a6XEbM6lDu92QMhEeDzGwFSxFQYS1(Kka8zZNJIQCFtTkZw7tQaWNnFoC10pvIVTktFP2WpmCKVGkFPD)nTZ4NLSQUKCDSsY16dNeMuwCsIdtY9(tcVhgljzuLts2KauyGITjjWD94ijgzZsYzXPpMKSjjmnjnGe0gOKKlWutmji80MedDb(ysYvUPDIUaLKCl6KkNKD4KCV)KSaLKPts(yFmjXWE5nc4YIQKutGJrjPbKut89JTFijO6tLrmRwkVCbMAIJO(WFyDb3wN(MKyQjMK0wjb1hh9JssdtYnjzhojPTsY8rdvajnmj5cm1ehjPok42As4njtNKWcumMeuF4HLfNK8N0lKSLcj5cm1etYcus4DMkNeeEAtsnQNee26qYh7Jjjy7L3iGllQsclWXOK4WKeQdxbK4yswKRx2WIgjR2t69GJORpmSAqq9H)clloT2HRICb(gw0iVt87ZEbSo)Pi1jJOnsfvNm6ZTNfNV0rvgEJ4nVGz1s5LlWutCe1h(dRliGvW0mKrmi5w0jJOowb3J6SHfLZW9Kos9X7mICrzDGFEz)p2mi5w0jJS47hB)8k(uzuNnSOCgwbMvlLxUatnXruF4pSUGBRtFZGzqQGvZiSRdpUN0rQxa)rHBGPgX2lVraxwu9XcCmAudKVZYQ8Gd(sf1c(Jc3atnITxEJaUSO6Jf4y0OgiFNLv5wSu7P7cVrmryxhE8ZEb8hfUbMAeBV8gbCzr1hlWXOrnq(olRYTyzpPJuF8oJixuwh4Nx2)J9Tvp3pf9PJI6koyYQ6sY1ScduSnj1yrzDGFiP((FSjbHJ1YDscxSYjPhsc8IoB69qYoCs60wbKu)w0jXrYQ9KEp4i66ddRgeKlkRd8Zl7)X26Z9trF5cm1exLzRD4QvauyGIT3WIEjxGPMX0r1x2pUR3guSyPICl6KruhRG7rD2WIYVW7mITxEJ4HOb8h76teOWafBVHfn4GVurT5w0jJ8fD207jQZgwuUflNUl8gXe5l6SP3teOORp4BRY7mICrzDGFEz)p2rGIU(GTy50DH3iMiFrNn9EIafD9bFBvENrS9YBepenG)yxFIafD9bhSflHFy44FG)GIpMp(cQCumo(zjRQljgS6X3cjNE4E69qs2KGZMLKZItFmjXiqdGAsspK0WWm15cm1etccBDib2nTtFmjjOjPbKG2aLeCUNkvojODiMKD4K8X(yssnX3p2(HKGQpvsYoCsUQoxpjxRJvW9iz1EsVhCeD9HHvdc2E5nIhIgWFSRpw7WvbkmqX2ByrVKlWuZy6O6l7h31Bz6l1MBrNmI6yfCpQZgwu(LCl6Krw89JTFEfFQmQZgwu(fmRwkVCbMAIJO(WFyDb3YiYQ6sctjvzjXiqdGAsYNLKEizXKGUZDsYfyQjMKftcBJXEyrTMeLbEu2Kee26qcSBAN(yssqtsdibTbkj4CpvQCsq7qmji80MKAIVFS9djbvFQmswTN07bhrxFyy1GGTxEJ4HOb8h76J1N7NI(YfyQjUkZw7WvbkmqX2ByrVKlWuZy6O6l7h31Bz6l1MBrNmI6yfCpQZgwu(LARi3IozeRlWhZ34M2j6c0OoByr5xWSAP8YfyQjoI6d)H1fClYf4ByrJO(WFyDbVZpBy4GVurT5w0jJS47hB)8k(uzuNnSOClwQi3IozKfF)y7NxXNkJ6SHfLFbZQLYlxGPM4iQp8hwxqaRYOGd(sf1MBrNmYx0ztVNOoByr5wSC6UWBetKVOZMEprGIU(GVTkVZi2E5nIhIgWFSRprGIU(GdMSApP3doIU(WWQbb1h(dRlW6Z9trF5cm1exLzRD4QywTuE5cm1ehr9H)W6cUf5c8nSOruF4pSUG35Nnm8LkQf3)sOp8iYUSPx0hUli1jTyP2t3fEJyIWffBFalCg)SbB9XE9PkZw7tQaWNnFokQY9n1QmBTpPcaF285Wvt)uj(2QmISApP3doIU(WWQbb1h(dUS3T(yV(uLzR9jva4ZMphfv5(MAvMT2NubGpB(C4QPFQeFBvgDPIAd)WWr(cQ8L2930oJFwlwoDx4nIjISD(lSlz8ZEPIWpmCez7C4gGg)SwSuB4hgoYxqLV0U)M2z8ZEj8ddh5og3Zo5tp2TIJF2Gd2AhUAT4(xc9Hhr2Ln9I(WDbPoPfl1E6UWBeteUOy7dyHZ4NLSQUKCDSscdOOy7dyHts6FIDUssdtc66djNUl8gXGjjBsqxFY1hsQrx20lkjgDbPojjHFy4iz1EsVhCeD9HHvdcCrX2hWcNw7WvX9Ve6dpISlB6f9H7csDYl1g(HHJiBNd3a04N9sTHFy4iBJqbpFG)yVN4N1AFsfa(S5ZrrvUVPwLzR9jva4ZMphUA6NkX3wLzYQ6sY1XkjgbAaeyswmjLfNKauCdssCys6HK0wjbTrQKv7j9EWr01hgwniy7L3iEiAa)X1nTjRQljxhRKyeObqnjzXKuwCscqXnijXHjPhssBLe0gPsYoCsmc0aiWK4ys6HegpWKv7j9EWr01hgwniy7L3iEiAa)XU(qwrwvxsUowjPhsy8atsDyuh1KKSjXutscCxpjPFQ0hts2HtIYazDGss2Ku8rj5ZssOMPcibHN2KuJ25WnaLSApP3doMaFQutC1pwFEQOwplQwvrzVd0T8AaF25Ow7WvpDx4nIjISD(tbF207jcu01hCaRYmJSy50DH3iMiY25pf8ztVNiqrxFW3YOaezvDjPEWDsYMeJ7ZHKaCDQatccpTjjW9pSOKyK7PsLtcJhymjomjSng7HfnssDEiP0JPcib2nTtmji80Me0gOKeGRtfys(yftYMPIYMKKnj47ZHeeEAtYo3j5WjPbKCn9XjjFSsINrYQ9KEp4yc8PsnXmSAq(y95PIA9SOAvFWhWp3WI(cK)o5h9XvK(rT2HRg(HHJiBNd3a04N9s4hgoY2iuWZh4p27j(zTyjSX4lWUPD(ak66doGvz0nSyj8ddhzBek45d8h79e)SxoDx4nIjISD(tbF207jcu01hmdz(M3c7M25dOORpylwc)WWrKTZHBaA8ZE50DH3iMiBJqbpFG)yVNiqrxFWmK5BElSBANpGIU(GTyPIt3fEJyISncf88b(J9EIafD9bFBvMVXLt3fEJyIiBN)uWNn9EIafD9bFBvMVrWxGDt78bu01h8TvzUo5gKv1LeJ7ZHedBvtsU2p2pKGWtBsQr7C4gGswTN07bhtGpvQjMHvdYhRppvuRNfvRIUNneOpSTQ5d9J9J1oC1t3fEJyIiBN)uWNn9EIafD9bFlZ3GSQUKyCFoKCn)dVtccpTjPMncfqsaEG)yVhs(41uTMe0TsLe8hOKKnj4XzvssBLKsJqXjjmO1KKCbMAgjjqT1HKpw5KGWtBsmSxEJq5KuNbHK0WKuFdq1jTMKRPpoj5Jvs6HegpWKSysq)hBswmjSng7HfnswTN07bhtGpvQjMHvdYhRppvuRNfvRI7FPOz6J5d8dVB95(POVCbMAIRYS1oC1WpmCKTrOGNpWFS3t8ZAXsTSaxXzeRf4hBJqbpFG)yVhlw0a57SSkpITxEJq5Vge(A4x2auDsYQ6sY1Xkjmz5Mkj(GDUssdtsnyaKa3assBLeyhGts(yLKgqspKW4bMKfovajPTscSdWjjFSgjXWUbjjhhC(EsIdtcY25KOGpB69qYP7cVrmK4ysy(gysAajOnqjzrS3JKv7j9EWXe4tLAIzy1G8X6Ztf16zr1QyFG)LNzz5(Mna)cxUP(A4hSc6JN3T2HRE6UWBetez78Nc(SP3teOORp4BRY8niRQljxhRKyyV8gHYjPodcjPHjP(gGQtsccBDiz6KeFiPgTZHBaQ1K0as8HKqnrO6qsnANtct6ssYzXjMeFiPgTZHBaAKK6atctP7aFhsAajxPhqxAaNKIpkjEsYNLeeEAtco3tLkNKt3fEJyWrYQ9KEp4yc8PsnXmSAq(y95PIA9SOAvS9YBek)1GWxd)YgGQtATdx90DH3iMiBJqbpFG)yVNiqrxFWbSkZ34YP7cVrmrKTZFk4ZMEprGIU(GdyvMVXLkonsD2jJJEaDPbClwonsD2jJvEh47eSflvCAK6StgrQtAFhyXYPrQZozCCt78bVAWxQO2WpmCez7C4gGg)SwSWcuKpZdpYCez78xyxYGTyjSX4lWUPD(ak66doGvz6BqwrwvxsUowjP44KKgMKEyQ)yLe(IUMkjjWNk1etspL7K4WKWG(htf4Jjj1ODojbwd)WWK4ys2t6ivRjPbKCV)KSaLKPtsYTOtQCs8jBs8mswTN07bhtGpvQjMHvdYzlL3EsVNxXXP1ZIQv5OMVe4tLAITgNa)Kvz2AhUAf1MBrNmA)htf4J5dz78OoByr5wSW1WpmC0(pMkWhZhY25XpBWxQi8ddhr2ohUbOXpRflNUl8gXer2o)PGpB69ebk66d(wMVrWKv1LKaRW7VKKaVLs4EQKe4gqYhVHfLepvuCaqY1Xkj9qYP7cVrmK4djnGRascVtsc8Psnjbx6mswTN07bhtGpvQjMHvdYhRppvuS1oC1WpmCez7C4gGg)SwSe(HHJSncf88b(J9EIFwlwoDx4nIjISD(tbF207jcu01h8TmFdidmREGUIr3KbdLqjeea]] )
    

end
