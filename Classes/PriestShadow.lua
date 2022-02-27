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
        },
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


    spec:RegisterPack( "Shadow", 20211227.1, [[dmfSUcqivqpsQsUekviztsL(ekvzusv1PKQYQOscVcI0SOeUfvsKDjLFrLudtQOogLOLbr8mPkvtdIQUgeKTrLK8nPkLXPcvDoQKOwNur8ouQqQ5HsP7rLAFqu(NkuihuQiTqukEievMOuHUOubzJQqPpIsfzKQqbNuQGALujEjkvOMPku0nvHk7ec8tQKudvfOJIsfILIsf1trLPkvXvHGARQa(Qubglkvq7vv(RknyshwYIPIhdYKP4YeBguFgvnAk1PfwnkvGxRcz2u1TH0Uv8BLgokookv1YbEoutx01vvBxf9DuY4rPsNhcTEvOqnFkP9J8ZYxppotLYdbiPZibjDgjiP3AwIKEV36mY)4sezKhhtbDuXlpUPqLhhNDzwwpoMcr)wMxppo8(bqYJZotgCN4AxZhP93PbTOUghOFFLXoqGcoDnoqHC9JZ5h(SdppNhNPs5HaK0zKGKoJeK0BnlrsV3BDgjpU6N2l4XXfOi3JZomgzEopoJGHECC2Lzzr6bbHGtYLJvCa)cGiPiP3SGuK0zKGeYfYfKZUgEb3jKlUsK2dlPoI0dSHH0EwaqMKuw2YqAwaEjjfA)tIjTacPWlasmnYfxjspiqszmKA2etAbes)mKYYwgsZcWljM0ciKc5xSqAUKAqmgElifVKM2vs68psWKwaHuCgEpPabArrLXiM2JZh4e)65XHwX865HalF984KPC8I5XMhheisbe1JZ5dd3C2DUl8nTLBHHKXiM2N5XHtqaLpey5JRGYyNhhu593ckJDU(aNpoFGZ7uOYJZz35LpeGKxppozkhVyES5XbbIuar94oK0Sa8s2c8LXxikGhxbLXopotGze)fT4dOx(qqV)65Xjt54fZJnpUckJDECNByUc4ZKXopoJGHabtg784qySq6b2WqAhc8zYyhs3HuOD9ML1qkZU(y4jTss9sHtsrccrAm4AIersD(jPZMKgWKI4(jLv49KUNcaQyingCnrIiPXq6bo2gPhxDKqk(des5SlZYcoKX46JlgJJmgbqAngspUymKYgFHtsdmP7qk0UEZYAi1rGxGq6b6qKgWKYzxMLfSVqfsdmPc7)dggX0iTdZplqiLzxFm8KceCccOm2btAat6hhdpPC2Lzzb7luH0dccmkP1yiLnYyeaPbM09NThheisbe1J7Sar54LgZU(l8cUqgmPDjTFsJbxtKiskYCtksqisTALugjBWHmMwbLXPqAxsb)rGxaV0W2Lzzb7lu5YacmAty)FWWigs7s6HKcTR3SSMgAmMRJVWz7ZqAxspKuOD9ML10W2LzzDzTaZ1ivA3(mK2hPDjTFsJbxtKiskBDt6XJqKA1kPz5LjByPaXWFNG3orlG0KPC8IH0UKEwGOC8sdlfig(7e82jAbKl0pxyys7J0UKEiPq76nlRPbhYyAFgs7sA)KEiP497DIX0oxFLHxU41Fkt2KPC8IHuRwj15dd3oxFLHxU41Fkt2(mKA1kPyjZy4XTGFwGCXR)uMK0(E5dbi)RNhNmLJxmp284kOm25XHTlZY6YAbMltfZJZiyiqWKXopUJRosif)bcPiUFsz(jPFgs56Go5GK2PCD6bjDhstBH0Sa8ssAatAhaQ0g(7j9ylbecPbEyVK0ckJtHuw2YqkCWBNXWtQLUs9oPzb4Le3ECqGifqupoNpmCdUKl)VaMOgC7ZqAxspKuJ48HHBSavAd)9x4saH0(mK2LumJ493Sa8sIBOXyUyPaKYwsr(x(qac965Xjt54fZJnpUckJDECOXyUyPapoiqKciQhxwEzYgwkqm83j4Tt0cinzkhVyiTlPygX7Vzb4Le3qJXCXsbifzKEwGOC8sdngZflf4c9ZfgM0UKEiPMnBy7YSSUSwG5YuX0Ya6Oy4jTlPhsk0UEZYAAWHmM2NH0UKIzeV)MfGxsCdngZflfGuK5MuK)XbHiKxUzb4Le)qGLV8Hax1RNhNmLJxmp284kOm25XbvE)TGYyNRpW5JZh48ofQ84Gm4x(qqV965Xjt54fZJnpUckJDECOXyUyPapoieH8YnlaVK4hcS8XbbIuar94YYlt2WsbIH)obVDIwaPjt54fdPDjfZiE)nlaVK4gAmMlwkaPiJ0ZceLJxAOXyUyPaxOFUWWK2L0dj1SzdBxML1L1cmxMkMwgqhfdpPDj9qsH21BwwtdoKX0(mpoJGHabtg784ogcEBspiiwqKis6XfJHuoPaKwqzSdP5skqGbc2M0oU9GjLvK2KILced)DcE7eTaYlFi44F984KPC8I5XMhxbLXopotHovg784GqeYl3Sa8sIFiWYhheisbe1JRFsnB2oluMaeq3C)q2nGadeSD54fsTALuZMnSDzwwxwlWCzQyAabgiy7YXlKA1kP9t6HK68HHBOXyUg5C)ab0(mK2L0yW1ejIKYwsrOotAFK2hPDjTFsD(WWntbo6M27N3oB4SGoIu2sQZhgUzkWr30E)82zdTy3lolOJi1QvspKuSKxND(4wgcajh)fjmqK23JZiyiqWKXopUdceybqAUK(XcPDSqNkJDiTt560dsAatkxh0jhK0fq6b6H0at6SjPFgsxaPiUFsHQz2KuOcNKwKolaT8K2r5C)Gy4j9G(I)lK2Fmq(VjgEspUymK2r5C)abqkdyHW9rAngsrC)KYk8EsNnjfQyiTJf4is7XE)82jMuCwqhHjnGj9JJHN0EqYXtksyGAV8Hax5xppozkhVyES5XvqzSZJdBxML1L1cmxJuP9JZiyiqWKXopoeglKYzxMLfPDWcmK2rPsBsdys)4y4jLZUmllyFHkKEqqGrjTgdPoYyeaPScVNuHDzcGqQ5dIHN00wiDe2njLhY0ECqGifqupogjBWHmMwbLXPqAxsb)rGxaV0W2Lzzb7lu5YacmAty)FWWigs7skJKn4qgtdiOvmyszRBs5HmK2LumJ493Sa8sIBOXyUyPaKYw3K2BV8Hal78RNhNmLJxmp284kOm25XHgJ564lC(4mcgcemzSZJRt9SkeXK(XcPOXyC8foXKgWKcvmmIH0AmKA)hEbedpPNByinWK(ziTgdPFCm8KYzxMLfSVqfspiiWOKwJHuhzmcG0at6NPrkPDQXezSt59iAbPqfojfngJJVWjPbmPiUFszTFVHuhH0)uoEH0CjLxsstBHuqaNK6GiPSQiJHN0IuEit7XbbIuar946NuOD9ML10qJXCD8foBq2fGxWKImsTK0UK2pPgX5dd3S)dVaIH)EUHP9zi1QvspK0S8YKn7)WlGy4VNByAYuoEXqAFKA1kPms2GdzmnGGwXGjLTUjfQW5nduHuKskpKH0(iTlPms2GdzmTckJtH0UKc(JaVaEPHTlZYc2xOYLbey0MW()GHrmK2LugjBWHmMgqqRyWKImsHkCEZaviTlPygX7Vzb4Le3qJXCXsbiLTUjT3i1QvsD(WWntbo6M27N3oBFgs7sQZhgUDUHbEbOTpdPDj9qsH21Bwwt7CdZ1z9z7ZqAxs7N0djf8hbEb8sdBxMLfSVqLldiWOnH9)bdJyi1QvspKugjBWHmMwbLXPqAFK2LuSKxND(4wgcajh)f5zGE5dbwA5RNhNmLJxmp284kOm25XDUH56S(8XzemeiyYyNhhcJfspWggszZ6tsRKu7G3waKYaIfejIKYksBspg(dVaIHN0dSHH0pdP5skYtAwaEjXwq6ciDtBbqAwEzsmP7qkxpThheisbe1JlgCnrIiPS1nPhpcrAxsZYlt2S)dVaIH)EUHPjt54fdPDjnlVmzdlfig(7e82jAbKMmLJxmK2LumJ493Sa8sIBOXyUyPaKYw3K6Qi1Qvs7N0(jnlVmzZ(p8cig(75gMMmLJxmK2L0djnlVmzdlfig(7e82jAbKMmLJxmK2hPwTskMr8(BwaEjXn0ymxSuasDtQLK23lFiWsK865Xjt54fZJnpUckJDECg5C)Gy4Vm(I)lpoJGHabtg7844yeOO8K2r5C)Gy4j9G(I)lKYksBs5KcedpPii4Tt0ciKYYwgs)4Ixi18bXWtkYTR3SSg8JdcePaI6X1pPyjVo78XTmeaso(lYZarQvRKMLxMSz)hEbed)9CdttMYXlgs7J0UKMLxMSHLced)DcE7eTastMYXlgs7skJKn4qgtRGY4uiTlPG)iWlGxAy7YSSG9fQCzabgTjS)pyyedPDj15dd3o3WaVa02NH0UKIzeV)MfGxsCdngZflfGu26Mux1lFiWYE)1ZJtMYXlMhBECfug784mY5(bXWFz8f)xECgbdbcMm25X1XDyVK0pwiTJY5(bXWt6b9f)xinGjfX9tkunKYljPXKlPhydd8cqjngCkLXcsxaPbmPCsbIHNuee82jAbesdmPz5LjfdP1yiLv49KAhjPYSFEBsZcWljU94GarkGOEC9tkqGbc2UC8cPwTsAm4AIersrgP9gcrQvRKMLxMSDUH5Mlait2KPC8IH0UKcTR3SSM25gMBUaGmzdiOvmyszRBs7DsDfKYdziTps7sA)KEiPNfikhV0y21FHxWfYGj1QvsJbxtKiskYCt6XJqK2hPDjTFspK0S8YKnSuGy4VtWBNOfqAYuoEXqQvRK2pPz5LjByPaXWFNG3orlG0KPC8IH0UKEiPNfikhV0WsbIH)obVDIwa5c9ZfgM0(iTVx(qGLi)RNhNmLJxmp284kOm25XDUH56S(8XzemeiyYyNhhcJfspaBiDhsrUosAatkI7NuZoSxs6iIH0CjfQWjPDuo3pigEspOV4)IfKwJH00wacPfqi1lymPPDnKI8KMfGxsmP7pjTFeIuwrAtk0oMFK91ECqGifqupomJ493Sa8sIBOXyUyPaKYws7NuKNuKsk0oMFKntGX7utEfi7vWnzkhVyiTps7sAm4AIerszRBspEeI0UKMLxMSHLced)DcE7eTastMYXlgsTAL0djnlVmzdlfig(7e82jAbKMmLJxmV8HalrOxppozkhVyES5XvqzSZJdBxML1L1cmxJuP9JdcriVCZcWlj(HalFCqGifqupU(jnlaVKnBP8PDJbkjLTKIKotAxsXmI3FZcWljUHgJ5ILcqkBjf5jTpsTAL0(jLrYgCiJPvqzCkK2LuWFe4fWlnSDzwwW(cvUmGaJ2e2)hmmIH0UKIzeV)MfGxsCdngZflfGu26M0EJ0(ECgbdbcMm25XHWyHuo7YSSiTdwGPtiTJsL2KgWKM2cPzb4LK0atA5S)K0Cj1ecPlGue3pP21PqkNDzwwW(cvi9GGaJsQW()GHrmKYksBspUymoYyeaPlGuo7YSSGdzmKwqzCkTx(qGLUQxppozkhVyES5XvqzSZJd)bazmc4M7fTmJGXpoieH8YnlaVK4hcS8XbbIuar94YcWlzldu5M71ecPSLuK0zs7sQZhgUDUHbEbOnZYAECgbdbcMm25XHWyHuUpaiJraKMlPhxzgbJjDhslsZcWljPPDLKgys53y4jnxsnHqALKM2cPGG3ojnduP9YhcSS3E984KPC8I5XMhxbLXopUZnm3CbazYhheIqE5MfGxs8dbw(4GarkGOECNfikhV0mBIVFgs7sA)K68HHBNByGxaAZSSgsTALuNpmC7Cdd8cqBabTIbtkBjfAxVzznTZnmxN1NnGGwXGj1QvszaY5LhY0SSDUH56S(K0UKEiPoFy4MJFxJ)JZgqkOK0UKIzeV)MfGxsCdngZflfGu2sAVtAFK2L0ZceLJxANj(wmm(qmK2LumJ493Sa8sIBOXyUyPaKYws7NueIuKsA)K6Qi1vqAwEzYwYkW5DHVWvknzkhVyiTps77XzemeiyYyNhhcJfspWggs7zbazss3XJiPbmPCDqNCqsRXq6b6H0ciKwqzCkKwJH00winlaVKKYAh2lj1ecPMpigEstBHui7AgX3E5dbwE8VEECYuoEX8yZJdcePaI6X1pPz5LjByPaXWFNG3orlG0KPC8IH0UKIzeV)MfGxsCdngZflfGuKr6zbIYXln0ymxSuGl0pxyysTALuZMnSDzwwxwlWCzQyAzaDum8K2hPDj9Sar54L2zIVfdJpeZJRGYyNhhAmghzmc4LpeyPR8RNhNmLJxmp284kOm25XHTlZY6YAbMRrQ0(XzemeiyYyNhhcJfs56GoPJKYksBspyfJdqQJeaPhexEus)JxWystBH0Sa8sskRW7j1ri1r8llsrsNzhfPoc8cestBHuOD9ML1qk0IkysDkOJApoiqKciQhh4pc8c4LgtfJdqQJeWLbxE0MW()GHrmK2L0ZceLJxAMnX3pdPDjnlaVKTmqLBUxgO8IKotkYiTFsH21BwwtdBxML1L1cmxJuPDZ8bvg7qksjLhYqAFV8HaK05xppozkhVyES5XvqzSZJdBxML1fcuy7hNrWqGGjJDECimwiLZUmllsroqHTjDhsrUos6F8cgtAAlaH0ciKwgdM0yGw0y4BpoiqKciQhhOcZvoLjBLXGBXqkYi1Yo)YhcqILVEECYuoEX8yZJdcePaI6XHzeV)MfGxsCdngZflfGuKr6zbIYXln0ymxSuGl0pxyys7sQZhgUzkWr30E)82z7Z84mcgcemzSZJdHXcPhxmgs5KcqAUKcTd(JkK2XcCeP9yVFE7etkdyHWKUdPDQRUd1iThxDhD1KIC7ahausdmPPDGjnWKwKAh82cGugqSGirK00UgsbIzZmgEs3H0o1v3Hi9pEbJj1uGJinT3pVDIjnWKwo7pjnxsZaviD)5JdcriVCZcWlj(HalFCXKca8zYBa)4Ya6imYCJ8pUysba(m5nqrftuP84S8XbzxX84S8XvqzSZJdngZflf4LpeGeK865Xjt54fZJnpoJGHabtg784qySq6XfJH0J1xisAUKcTd(JkK2XcCeP9yVFE7etkdyHWKUdPC9q6(tCyesxyspWX2ECqGifqupoNpmCZuGJUP9(5TZ2NH0UKEwGOC8sZSj((ziTlPhsQZhgUDUHbEbOTpdPDj9qsplquoEPXSR)cVGlKbtAxsH21BwwtdngZ1Xx4Sb)9(lqGSlaVCZavifzUjLhY0ql29XftkaWNjVb8JldOJWiZnY39qNpmCZuGJUP9(5TZ2N5XftkaWNjVbkQyIkLhNLpoi7kMhNLpUckJDECOXyUW(cXx(qas69xppozkhVyES5XvqzSZJdngZ1Xx48XzemeiyYyNhhcJfspUymKYgFHtsdysrC)KA2H9sshrmKMlPabgiyBs742dUrkxUmKcv4mgEsRKuKN0fqk6cesZcWljMuwrAtkNuGy4jfbbVDIwaH0S8YKIH0AmKI4(jTacPZMK(XXWtkNDzwwW(cvi9GGaJs6ci9GyeHSdispMXCudZiE)nlaVK4gAmMlwkaYogHqKYljM00wifnMa9Js6ctkcrAngstBH05J6iasxysZcWljUrAN6XRfKAwsNnjLbiymPOXyC8foj9pz4jT8EsZcWljM0ciKA2mfdPSI0M0d0dPSSLH0pogEsX2Lzzb7luHugqGrjnGj1rgJainWKwNv4lhV0ECqGifqupUZceLJxAMnX3pdPDjfuH5kNYKn09uqLjBXqkYifQW5nduHuKsANBiePDjfZiE)nlaVK4gAmMlwkaPSL0(jf5jfPKIesDfKMLxMSHgybGytMYXlgsrkPfugNY1Sz7SqzcqaDZ9dztQRG0S8YKngmIq2b01hZrnzkhVyifPK2pPygX7Vzb4Le3qJXCXsbifzhJifHiTpsDfK2pPms2GdzmTckJtH0UKc(JaVaEPHTlZYc2xOYLbey0MW()GHrmK2hP9rAxs7N0djf8hbEb8sdBxMLfSVqLldiWOnH9)bdJyi1QvspKuOD9ML10GdzmTpdPDjf8hbEb8sdBxMLfSVqLldiWOnH9)bdJyi1QvsplquoEPDM4BXW4dXqAFV8HaKG8VEECYuoEX8yZJRGYyNh3zHYeGa6M7hY(XbHiKxUzb4Le)qGLpoiqKciQhhqGbc2UC8cPDjnlaVKTmqLBUxtiKIm3KA5XtAxs7NuZMTZcLjab0n3pKDldOJIHNuRwj9qsplquoEPDM4BXW4dXqAFK2L0ZceLJxAOf7EptmPiJ0otQvRK2pPz5LjBObwai2KPC8IH0UKA2SHTlZY6YAbMltftdiWabBxoEH0(i1QvsD(WWT)a)b(y4VMcC0iyC7Z84mcgcemzSZJJDwGbc2M0duOmbiGiTN9dztkRalEej1PWIH0DiTJf6uzSdP1yiDtBbqApLxMe3E5dbibHE984KPC8I5XMhxbLXopoSDzwwxwlWCzQyECgbdbcMm25XXXiqr5jfAhtKXoKMlP4CzifQWzm8KY1bDYbjDhsxyyxPSa8sIjLLTmKch82zm8K27KUasrxGqkolOJedPORdM0AmK(XXWt6bXiczhqKEmJ5isRXqkcC19q6XfybGy7XbbIuar94acmqW2LJxiTlPzb4LSLbQCZ9AcHuKrkYtAxspK0S8YKn0alaeBYuoEXqAxsZYlt2yWiczhqxFmh1KPC8IH0UKIzeV)MfGxsCdngZflfGuKrksE5dbiXv965Xjt54fZJnpoJGHabtg784yhlcdPCDqNCqs)mKUdPfMu0AqK0Sa8sIjTWKYSyC44flivyxiHjjLLTmKch82zm8K27KUasrxGqkolOJedPORdMuwrAt6bXiczhqKEmJ5O2JdcePaI6XbeyGGTlhVqAxsZcWlzldu5M71ecPiJuKN0UKEiPz5LjBObwai2KPC8IH0UKEiP9tAwEzYgwkqm83j4Tt0cinzkhVyiTlPygX7Vzb4Le3qJXCXsbifzKEwGOC8sdngZflf4c9ZfgM0(iTlP9t6HKMLxMSXGreYoGU(yoQjt54fdPwTsA)KMLxMSXGreYoGU(yoQjt54fdPDjfZiE)nlaVK4gAmMlwkaPS1nPiH0(iTVhxbLXopoSDzwwxwlWCzQyE5dbiP3E984KPC8I5XMhxbLXopoyVGTHafC(4Ijfa4ZK3a(XLb0ryK52YhxmPaaFM8gOOIjQuECw(4GarkGOEC497DIX0oxFLHxU41Fkt2KPC8IH0UKEiPoFy425gg4fG2(mK2L0dj15dd3ywwc4gd8hh70(mK2LuNpmC7C9vgE5Ix)PmzdiOvmyszlPw25hNrWqGGjJDECimwi9y9c2gcuWjP7pXHriDHjfTIHuOD9ML1GjnxsrRyYkgspW6Rm8cPCR)uMKuNpmC7LpeGKJ)1ZJtMYXlMhBECqGifqupomJ493Sa8sIBOXyUyPaKImsplquoEPHgJ5ILcCH(5cd)4Ijfa4ZK3a(XLb0ryK5gjpUysba(m5nqrftuP84S8XbzxX84S8XvqzSZJdngZflf4LpeGex5xppozkhVyES5XvqzSZJdngZf2xi(4Ijfa4ZK3a(XLb0ryK5gjD7)qNpmCZuGJUP9(5TZ2NXQvOD9ML10o3WCDwF2(mD735dd3o3WaVa02NXQ1dD(WWntbo6M27N3oBFMUoFy4MjW4DQjVcK9k42NPV(ECXKca8zYBGIkMOs5Xz5JdYUI5Xz5lFiO378RNhNmLJxmp284mcgcemzSZJdHXcPCDqN0rslmP(cNKce8cssdys3H00wifDpLhxbLXopoSDzwwxwlWCnsL2V8HGE3YxppozkhVyES5XzemeiyYyNhhcJfs56Go5GKwys9fojfi4fKKgWKUdPPTqk6EkKwJHuUoOt6iPbM0Dif564JRGYyNhh2UmlRlRfyUmvmV8LpoJaxFF(65HalF984KPC8I5XMhNrWqGGjJDECDi2vG(PyivofaIKMbQqAAlKwq5cinWKwNv4lhV0ECfug784WHxgi5LpeGKxppozkhVyES5XbbIuar94C(WWTZnmWlaT9zi1QvsD(WWnMLLaUXa)XXoTpZJRGYyNhhZMXoV8HGE)1ZJtMYXlMhBEClZJdl5JRGYyNh3zbIYXlpUZY)Lhx)KA2SHTlZY6YAbMltftldOJIHNuRwjnlaVKTmqLBUxtiKYw3KI8K2hPDjTFsnB2oluMaeq3C)q2TmGokgEsTAL0Sa8s2YavU5EnHqkBDtQRI0(ECNf4ofQ84mBIVFMx(qaY)65Xjt54fZJnpUL5XHL8XvqzSZJ7Sar54Lh3z5)YJ7Sar54LMzt89ZqAxs7NuZMnJCUFqm8xgFX)LwgqhfdpPwTsAwaEjBzGk3CVMqiLTUjf5jTVh3zbUtHkpUY7VMnX3pZlFiaHE984KPC8I5XMh3Y84Ws(4kOm25XDwGOC8YJ7S8F5XHzeV)MfGxsCdngZflfGuKrksifPK68HHBNByGxaA7Z84mcgcemzSZJJllqs6hhdpPCsbIHNuee82jAbesRK0EhPKMfGxsmPlGuKhPKgWKI4(jTacPXq6b2WaVa0h3zbUtHkpoSuGy4VtWBNOfqUq)CHHF5dbUQxppozkhVyES5XTmpoSKpUckJDECNfikhV84ol)xEC9t6HKc(JaVaEPHzSfGGV2faDheBc7)dggXqAxspKuO9uMAY2iqG1VadPwTsk0UEZYAAmllbCJb(JJDAabTIbtkBDtkpKPHwSlPUcs7DsTALuNpmCJzzjGBmWFCSt7ZqQvRK6SymPDjfo4TZlqqRyWKYw3KIeeI0(ECNf4ofQ84Gmx0AkEbvM8Lpe0BVEECYuoEX8yZJBzECyjFCfug784olquoE5XDw(V84WmI3FZcWljUDwOmbiGU5(HSFCNf4ofQ84ql29EM4x(qWX)65Xjt54fZJnpUL5XHL8XvqzSZJ7Sar54Lh3z5)YJdHifPKIesDfK2pPNfikhV0Gmx0AkEbvMK0UKcTR3SSM25gMRa(mzStdiOvmyszRBsTSZK2hPDjnlVmzZ(p8cig(75gMMmLJxmpoiqKciQhxwEzYgwkqm83j4Tt0cinzkhVyiTlPygX7Vzb4Le3qJXCXsbi1nP92J7Sa3PqLhhAXU3Ze)YhcCLF984KPC8I5XMh3Y84Ws(4kOm25XDwGOC8YJ7S8F5X15hheisbe1JllVmzdlfig(7e82jAbKMmLJxmK2LumJ493Sa8sIBOXyUyPaKIms7Th3zbUtHkpo0IDVNj(LpeyzNF984KPC8I5XMh3Y84Ws(4kOm25XDwGOC8YJ7S8F5XH8poiqKciQhxwEzYgwkqm83j4Tt0cinzkhVyiTlPygX7Vzb4Le3qJXCXsbi1nPhpPDj9qsZYlt2W2LzzDHaf2Ujt54fZJ7Sa3PqLhhAXU3Ze)YhcS0YxppozkhVyES5XTmpoSKpUckJDECNfikhV84ol)xEC9tkMr8(BwaEjXn0ymxSuaszRBsris7JuxbPygX7Vzb4Le3qJXCXsbECqGifqupoNpmC7Cdd8cqBFMh3zbUtHkpo0IDVNj(LpeyjsE984KPC8I5XMh3Y84Ws(4kOm25XDwGOC8YJ7S8F5X15hNrGRVpFCw(4olWDku5Xf47zEzwmoC8YlFiWYE)1ZJtMYXlMhBEClZJdl5JRGYyNh3zbIYXlpUZY)LhNLpoiqKciQhxbLXPCnB2oluMaeq3C)q2KYwsHqeYlxze0qWpUZcCNcvECb(EMxMfJdhV8YhcSe5F984KPC8I5XMh3Y84Ws(4kOm25XDwGOC8YJ7S8F5XvqzCkxZMTZcLjab0n3pKnPiZnPNfikhV0ql29EMysTAL0dj9Sar54LwGVN5LzX4WXlpUZcCNcvECNj(wmm(qmV8HalrOxppozkhVyES5XTmpoSKpUckJDECNfikhV84ol)xECq76nlRPDUH5kGptg70(mK2L0ZceLJxAqMlAnfVGkt(4mcgcemzSZJd521BwwdPhCxpPhOar54flifHXIH0CjLzxpPoc8ceslOmoRmgEspWgg4fG2ECNf4ofQ84y21FHxWfYGF5dbw6QE984KPC8I5XMhheisbe1JZ5dd3o3WaVa02N5XvqzSZJdoaIJFxZlFiWYE71ZJtMYXlMhBECqGifqupoNpmC7Cdd8cqBFMhxbLXopohbGfWrXW)YhcS84F984KPC8I5XMhxbLXopoFWBN4l7GVHhvM8XzemeiyYyNhhcJfspMbVDYEysD5B4rLjjnGjnTfGqAbesrcPlGu0fiKMfGxsSfKUaslJbtAbKH9ssXmfRjgEsHxaPOlqinTRH0EdHWThheisbe1JdZiE)nlaVK4Mp4Tt8LDW3WJktskYCtksi1Qvs7N0djfuH5kNYKTYyWnHDdCIj1QvsbvyUYPmzRmgClgsrgP9gcrAFV8HalDLF984KPC8I5XMhheisbe1JZ5dd3o3WaVa02N5XvqzSZJRgibNGYFHkV)LpeGKo)65Xjt54fZJnpUckJDECqL3FlOm256dC(48boVtHkpoiwqV8HaKy5RNhNmLJxmp284kOm25Xb(ZTGYyNRpW5JZh48ofQ84qRyE5lFCqSGE98qGLVEECYuoEX8yZJdcePaI6XHL86SZh3Yqai54VipdePDj15dd3mf4OBAVFE7S9ziTlPms2GdzmTckJtH0UKc(JaVaEPHTlZYc2xOYLbey0MW()GHrmK2L0dj15dd3o3WaVa02NH0UKYizdX9dUy7YSSAabTIbtkBjfo4TZlqqRyWKA1kPoFy4MPahDt79ZBNTpdPDjLrYgI7hCX2Lzz1acAfdMu2skpKPHwSlPUcs7N0ENuKsA)KEiPoFy425gg4fG2(mK2hPUcsT0vrAFK2LugjBiUFWfBxMLvdiOvmyszlPWbVDEbcAfd(XTJhXlelOhNLpoJGHabtg7846bjhpPiVRewssH2XezSt5jfEbKICDaYr6XfJHu24lC(4kOm25XHgJ564lC(YhcqYRNhNmLJxmp284(y5YYo8YfQWzm8pey5JRGYyNhhwkqm83j4Tt0cipoieH8YnlaVK4hcS8XbbIuar946N0ZceLJxAyPaXWFNG3orlGCH(5cdtAxspK0ZceLJxAm76VWl4czWK2hPwTsA)KA2SHTlZY6YAbMltftdiWabBxoEH0UKIzeV)MfGxsCdngZflfGuKrQLK23JZiyiqWKXopoeglKYjfigEsrqWBNOfqinGjfX9tkRW7j1ossLz)82KMfGxsmP1yi9GllbqAhEG)4yhsRXq6b2WaVauslGq6SjPaPmiAbPlG0CjfiWabBtkxh0jhK0DinzTKUasrxGqAwaEjXTx(qqV)65Xjt54fZJnpUpwUSSdVCHkCgd)dbw(4kOm25XHLced)DcE7eTaYJdcriVCZcWlj(HalFCqGifqupUS8YKnSuGy4VtWBNOfqAYuoEXqAxsnB2W2LzzDzTaZLPIPbeyGGTlhVqAxsXmI3FZcWljUHgJ5ILcqkYifjpoJGHabtg7844SxqskYfaOFKKYjfigEsrqWBNOfqifAhtKXoKMlPhjcdPCDqNCqs)mKgdPD62HE5dbi)RNhNmLJxmp2842XJ4fIf0JZYhxbLXopo0ymxhFHZhNrWqGGjJDEC74r8cXcIu06ibtAAlKwqzSdP74rK0pUC8cPMpigEsHSRzeFm8KwJH0ztslmPfPaH)7laPfug70E5lFCqg8RNhcS81ZJtMYXlMhBECfug784ywwc4gd8hh784mcgcemzSZJdHXcPhCzjas7Wd8hh7qkRiTj9aByGxaAJ0JH1BifEbKEGnmWlaLuOfvWKUWWKcTR3SSgsJH00wiDe2nj1YotkwG2XGjDtBbWkWcPFSq6oKczi9pEbJjnTfsz8fIcG0atktbssxystBH0Jqee1qk0EktnPfKUasdystBbiKYk8EsNnj1riTMnTfaPhyddPDiWNjJDinTdmPWbVD2iTtZuqzssZLumIdePPTqQVWjPmllbqAmWFCSdPlmPPTqkCWBNKMlPNByivaFMm2Hu4fq6SdPSJree1GBpoiqKciQhhdieC2WIh(YSSeWng4po2H0UK2pPoFy425gg4fG2(mKA1kPhsk0Ektnz7iebrnK2L0djfApLPMSncey9lWqAxsH21Bwwt7CdZvaFMm2Pbe0kgmPiZnPw2zsTALu4G3oVabTIbtkBjfAxVzznTZnmxb8zYyNgqqRyWK2hPDjTFsHdE78ce0kgmPiZnPq76nlRPDUH5kGptg70acAfdMuKsQLiePDjfAxVzznTZnmxb8zYyNgqqRyWKYw3KYdzi1vqkYtQvRKch825fiOvmysrgPq76nlRPXSSeWng4po2Pz(GkJDi1QvsDwmM0UKch825fiOvmyszlPq76nlRPDUH5kGptg70acAfdMuKsQLiePwTsk0Ektnz7iebrnKA1kPoFy4MJFxJ)JZ2NH0(E5dbi51ZJtMYXlMhBECgbdbcMm25XHWyHu2ugEH0yWHriDHj9ahlPWlG00wifoa4K0pwiDbKUdPixhjTGtbqAAlKchaCs6hlns7GiTjfbbVDs6XwcP2R3qk8ci9ahB7XnfQ84WXa)9xEFzIkxa(6ugE5UWxybSqrI4JdcePaI6X58HHBNByGxaA7ZqQvRKMbQqkYi1YotAxs7N0djfApLPMSnbVDEHlH0(ECfug784WXa)9xEFzIkxa(6ugE5UWxybSqrI4lFiO3F984KPC8I5XMhxbLXopo4sU8)cyIAWpoJGHabtg784qySq6XwcPSt)cyIAWKUdPixhjD)jomcPlmPhydd8cqBKIWyH0JTeszN(fWe1yWKgdPhydd8cqjnGjfX9tQDDkKkrAlaszNa7PqAhEod(fuzSdPlG0JneVH0fMu24xmErXns7GkssHxaPMnXKMlPocPFgsDe4fiKwqzCwzm8KESLqk70VaMOgmP5skAXUbAGfstBHuNpmC7XbbIuar94oKuNpmC7Cdd8cqBFgs7sA)KEiPq76nlRPDUH5Mlait2(mKA1kPhsAwEzY25gMBUaGmztMYXlgs7J0UK2pPNfikhV0mBIVFgs7skMr8(BwaEjXTZcLjab0n3pKnPUj1ssTAL0ZceLJxANj(wmm(qmK2LumJ493Sa8sIBNfktacOBUFiBsrgPwsAFKA1kPoFy425gg4fG2(mK2L0(jfVFVtmMgpypLBmNb)cQm2Pjt54fdPwTskE)ENymn4q8M7cFD8lgVO4MmLJxmK23lFia5F984KPC8I5XMhxbLXopo0ym8fQGFCqic5LBwaEjXpey5JdcePaI6XfdUMirKu2sQRCNjTlP9tA)KEwGOC8sR8(Rzt89ZqAxs7N0djfAxVzznTZnmxb8zYyN2NHuRwj9qsZYlt2S)dVaIH)EUHPjt54fdP9rAFKA1kPoFy425gg4fG2(mK2hPDjTFspK0S8YKn7)WlGy4VNByAYuoEXqQvRKAeNpmCZ(p8cig(75gMgqqRyWKImsHkCEZavi1QvspKuNpmC7Cdd8cqBFgs7J0UK2pPhsAwEzYgwkqm83j4Tt0cinzkhVyi1QvsXmI3FZcWljUHgJ5ILcqkBjfHiTVhNrWqGGjJDECimwi94IXWxOcMuw2YqA59K27K2XThmPfqi9ZybPlGue3pPfqingspWgg4fG2iTdn4pqi9y4p8cigEspWggszfEpP4m8EsDes)mKYYwgstBHuOcNKMbQqkCmb2wWns5YLH0pogEsRKuecPKMfGxsmPSI0MuoPaXWtkccE7eTas7LpeGqVEECYuoEX8yZJRGYyNh3FSxpI3zpRhNrWqGGjJDECimwifHh71JiPiypls3HuKRJwqQ96nXWtQdieypIKMlPSQijfEbKYSSeaPXa)XXoKUaslJHumtXAWThheisbe1J7qsZYlt2S)dVaIH)EUHPjt54fdPDj9Sar54LMzt89ZqQvRKAeNpmCZ(p8cig(75gM2NH0UK68HHBNByGxaA7ZqQvRK2pPq76nlRPDUH5kGptg70acAfdMuKrQLDMuRwj9qsplquoEPXSR)cVGlKbtAFK2L0dj15dd3o3WaVa02N5Lpe4QE984KPC8I5XMhxbLXopoNDN7cFtB5wyizmI5XzemeiyYyNhhcJfs3HuKRJK68tszaXcImWcPFCm8KEGnmK2HaFMm2Hu4aGtlinGj9JfdPXGdJq6ct6bows3HuUEi9Jfsl4uaKwKEUHXz9jPWlGuOD9ML1qQadhqHmqisAngsHxaP2)HxaXWt65ggs)mzGkKgWKMLxMumThheisbe1J7qsD(WWTZnmWlaT9ziTlPhsk0UEZYAANByUc4ZKXoTpdPDjfZiE)nlaVK4gAmMlwkaPiJuljTlPhsAwEzYgwkqm83j4Tt0cinzkhVyi1Qvs7NuNpmC7Cdd8cqBFgs7skMr8(BwaEjXn0ymxSuaszlPiH0UKEiPz5LjByPaXWFNG3orlG0KPC8IH0UK2pPma58YdzAw2o3WCDwFsAxs7N0djvy)FWWiMMGYGiqk)DbMPgiHuRwj9qsZYlt2S)dVaIH)EUHPjt54fdP9rQvRKkS)pyyettqzqeiL)UaZudKqAxsH21BwwttqzqeiL)UaZudK0acAfdMu26MulDviH0UKAeNpmCZ(p8cig(75gM2NH0(iTpsTAL0(j15dd3o3WaVa02NH0UKMLxMSHLced)DcE7eTastMYXlgs77Lpe0BVEECYuoEX8yZJRGYyNhhu593ckJDU(aNpoFGZ7uOYJlbXCKK4x(qWX)65Xjt54fZJnpoiqKciQhNTu(0UXaLKYw3K2Bi0JRGYyNhNrWmcOs5YakefWlF5JlbXCKK4xppey5RNhNmLJxmp284mcgcemzSZJdHXcP7qkY1rs7uUo9GKMlP8ssAh3EindOJIHN0AmKkSltaesZLuFmcPFgsDKmfaPSI0M0dSHbEbOpUPqLhNGYGiqk)DbMPgi5XbbIuar94G21Bwwt7CdZvaFMm2Pbe0kgmPS1nPwIesTALuOD9ML10o3WCfWNjJDAabTIbtkYifj92JRGYyNhNGYGiqk)DbMPgi5LpeGKxppozkhVyES5XzemeiyYyNhxpaejnxs5qCGiTdZoshjLvK2K2X974fs5Yc6iXqkY1rmPbmPmlghoEPrQREi1VdVaifo4TtmPSI0Mu0fiK2HzhPJK(XcM0ktbLjjnxsXioqKYksBsRbrsHmKUaszh8XjPFSqAKTh3uOYJlgme4NLJxUS)VM8JEnYzajpoiqKciQhNZhgUDUHbEbOTpdPDj15dd3ywwc4gd8hh70(mKA1kPolgtAxsHdE78ce0kgmPS1nPiPZKA1kPoFy4gZYsa3yG)4yN2NH0UKcTR3SSM25gMRa(mzStdiOvmysrkPwIqKImsHdE78ce0kgmPwTsQZhgUDUHbEbOTpdPDjfAxVzznnMLLaUXa)XXonGGwXGjfPKAjcrkYifo4TZlqqRyWKA1kP9tk0UEZYAAmllbCJb(JJDAabTIbtkYCtQLDM0UKcTR3SSM25gMRa(mzStdiOvmysrMBsTSZK2hPDjfo4TZlqqRyWKIm3KAPRCNFCfug784Ibdb(z54Ll7)Rj)OxJCgqYlFiO3F984KPC8I5XMhNrWqGGjJDECCioqKYzlss6X9XbePSI0M0dSHbEbOpUPqLhhAbvoa5ITfjVOFCa94GarkGOECq76nlRPDUH5kGptg70acAfdMuKrQLD(XvqzSZJdTGkhGCX2IKx0poGE5dbi)RNhNmLJxmp284McvEC4979sMXWFbFheFCqic5LBwaEjXpey5JRGYyNhhE)EVKzm8xW3bXhheisbe1JZ5dd3ywwc4gd8hh70(mKA1kPhskdieC2WIh(YSSeWng4po2HuRwjvy)FWWiMg2UmllXCxGZDHV5cqLjFCgbdbcMm25XXH4ark783brszfPnPhCzjas7Wd8hh7q6hx8IfKIwhjKI)aH0CjfpbJqAAlK6xwcoj9y4GKMfGxYgPDGTmK(XIHuwrAtkNDzwwIHuxnWH0fM0EwaQmPfKYo4Jts)yH0Dif56iPfMu0pKnPfMuMfJdhV0E5dbi0RNhNmLJxmp284mcgcemzSZJ7ydaojLl4dpPy0Y7jDzYanogxzSdPSI0MuU979sMXWtk783bXh3uOYJlTLlCaW5fh8H)XbbIuar94C(WWTZnmWlaT9zi1QvsD(WWnMLLaUXa)XXoTpdPwTs6HKYacbNnS4HVmllbCJb(JJDi1QvsH21Bwwt7CdZvaFMm2Pbe0kgmPiJul7mPwTsA)KkS)pyyetdVFVxYmg(l47GiPDj9qsH21BwwtdVFVxYmg(l47Gy7ZqAFKA1kPolgtAxsHdE78ce0kgmPSLuK05hxbLXopU0wUWbaNxCWh(x(qGR61ZJtMYXlMhBECgbdbcMm25XHWyHu2ugEH0yWHriDHj9ahlPWlG00wifoa4K0pwiDbKUdPixhjTGtbqAAlKchaCs6hlns5SxqskuaG(rsAat65ggsfWNjJDifAxVzznKgysTSZysxaPOlqiTyvi2ECtHkpoCmWF)L3xMOYfGVoLHxUl8fwaluKi(4GarkGOECq76nlRPDUH5kGptg70acAfdMuK5Mul78JRGYyNhhog4V)Y7ltu5cWxNYWl3f(clGfkseF5db92RNhNmLJxmp284mcgcemzSZJdHXcPC2LzzjgsD1ahsxys7zbOYKKYYwgsNnjngspWgg4fGAbPlG0yi1rswImKEGnmKYM1NKcv4etAmKEGnmWlaTrANIjLDmIGOgsxaPiqGaRFbgs9XiKgjPFgszfPnP4SGosmKcTR3SSgC7XnfQ84W2LzzjM7cCUl8nxaQm5JdcePaI6XbTR3SSMgZYsa3yG)4yNgqqRyWKYw3KAzNjTlPq76nlRPDUH5kGptg70acAfdMu26Mul7mPDjTFsH2tzQjBJabw)cmKA1kPq7Pm1KTJqee1qAFKA1kP9tk0Ektnz7uM0graPwTsk0EktnzBcE78cxcP9rAxs7N0dj15dd3o3WaVa02NHuRwjLbiNxEitZY25gMRZ6ts7JuRwj1zXys7skCWBNxGGwXGjLTUjf578JRGYyNhh2UmllXCxGZDHV5cqLjF5dbh)RNhNmLJxmp284kOm25Xvai7ifOeFJHxMFKiEHwG84mcgcemzSZJdHXcPPDGjDhsrUosk8cifTyxsrUoYo)4McvECfaYosbkX3y4L5hjIxOfiV8Hax5xppozkhVyES5XvqzSZJ7JLBKck(XzemeiyYyNhxhf467tsHlV3PGoIu4fq6hxoEH0ifuCNqkcJfs3HuOD9ML1qAmKUaJai1brstqmhjjPy)MThheisbe1JZ5dd3o3WaVa02NHuRwj15dd3ywwc4gd8hh70(mKA1kPq76nlRPDUH5kGptg70acAfdMuKrQLD(LV8X5S7865HalF984KPC8I5XMhheisbe1JdZiE)nlaVK4gAmMlwkaPS1nP9(JRGYyNhxHHKXiMRJVW5lFiajVEECYuoEX8yZJRGYyNhxHHKXiM7SN1JZiyiqWKXopox94rK0pwiTtXqYyedPiyplszzldPZMKMLxMumKgtUKYjfigEsrqWBNOfqiDhsrcsjnlaVK42JdcePaI6XHzeV)MfGxsCRWqYyeZD2ZIuKrQLK2LumJ493Sa8sIBOXyUyPaKImsTK0UKEiPz5LjByPaXWFNG3orlG0KPC8I5LV8XXaeOf1PYxppey5RNhNmLJxmp284GarkGOECabTIbtkBjT37CNFCfug784ywwc4YAbMl8cYi)g5LpeGKxppozkhVyES5XbbIuar94W737eJPX8X53lxb8zYyNMmLJxmKA1kP497DIX0oxFLHxU41Fkt2KPC8I5XvqzSZJd2lyBiqbNV8HGE)1ZJtMYXlMhBECqGifqupUdj15dd3W2LzzbVa02N5XvqzSZJdBxMLf8cqF5dbi)RNhNmLJxmp284GarkGOECXGRjseBgboGIKuKrQLi0JRGYyNhxbGQrU5caYKV8Hae61ZJtMYXlMhBECtHkpoSDzwwI5UaN7cFZfGkt(4kOm25XHTlZYsm3f4Cx4BUauzYx(qGR61ZJtMYXlMhBEClZJdl5JRGYyNh3zbIYXlpUZY)LhhsECNf4ofQ84qJXCXsbUq)CHHF5db92RNhNmLJxmp284GarkGOEChsAwEzYMPqNkJDAYuoEX84kOm25XDwOmbiGU5(HSF5dbh)RNhNmLJxmp284GarkGOECz5LjBMcDQm2Pjt54fZJRGYyNhhAmMRJVW5lF5lFCNcah78qas6msS0sKGKE7XXQatm84hxh0PSZiOdJa2PoHus7Xwinqzwqsk8ciL9sqmhjjM9ifiS)paIHu8IkKw)CrRumKczxdVGBKlhZyesrOoHuKBNtbKIHu2lbXCKKTYbQbTR3SSg2J0CjL9G21BwwtRCGyps73s2TVg5c5sh0PSZiOdJa2PoHus7Xwinqzwqsk8ciL9yac0I6uj7rkqy)FaedP4fviT(5IwPyifYUgEb3ixoMXiKIKoHuKBNtbKIHu2dVFVtmMg7q2J0CjL9W737eJPXoSjt54fd7rA)wYU91ixoMXiKIKoHuKBNtbKIHu2dVFVtmMg7q2J0CjL9W737eJPXoSjt54fd7rALK2HC1hts73s2TVg5c5sh0PSZiOdJa2PoHus7Xwinqzwqsk8ciL9qRyypsbc7)dGyifVOcP1px0kfdPq21Wl4g5YXmgH0EVtif525uaPyiL9W737eJPXoK9inxszp8(9oXyASdBYuoEXWEK2VLSBFnYLJzmcPiP36esrUDofqkgszp8(9oXyASdzpsZLu2dVFVtmMg7WMmLJxmShP9Bj72xJCHCPd6u2ze0Hra7uNqkP9ylKgOmlijfEbKYEqgm7rkqy)FaedP4fviT(5IwPyifYUgEb3ixoMXiK6Q6esrUDofqkgszVeeZrs2khOg0UEZYAypsZLu2dAxVzznTYbI9iTFlz3(AKlKlDyuMfKIH0EJ0ckJDi1h4e3ixECygb6HaKGqh)JJbSWHxEC9QxKYzxMLfPheecojx6vVi9yfhWVaisks6nlifjDgjiHCHCPx9IuKZUgEb3jKl9QxK6krApSK6ispWggs7zbazsszzldPzb4LKuO9pjM0ciKcVaiX0ix6vVi1vI0dcKugdPMnXKwaH0pdPSSLH0Sa8sIjTacPq(flKMlPgeJH3csXlPPDLKo)JemPfqifNH3tkqGwuuzmIPrUqU0RErAhIDfOFkgsDe4fiKcTOovsQJWhdUrANcbjmjM0zhxj7cGc)9KwqzSdM0D8i2ixkOm2b3yac0I6ujsD7AMLLaUSwG5cVGmYVrSiGDde0kgmB79o3zYLckJDWngGaTOovIu3Ug2lyBiqbNweWUX737eJPX8X53lxb8zYyhRwX737eJPDU(kdVCXR)uMKCPGYyhCJbiqlQtLi1TRX2LzzbVaulcy3h68HHBy7YSSGxaA7ZqUuqzSdUXaeOf1PsK621faQg5MlaitAra7ogCnrIyZiWbuKiZseICPGYyhCJbiqlQtLi1TR)y5gPGAXuOIBSDzwwI5UaN7cFZfGktsUuqzSdUXaeOf1PsK621NfikhVyXuOIB0ymxSuGl0pxyylwg3yjT4S8FXnsixkOm2b3yac0I6ujsD76ZcLjab0n3pKTfbS7dZYlt2mf6uzSttMYXlgYLckJDWngGaTOovIu3UgngZ1Xx40Ia2DwEzYMPqNkJDAYuoEXqUqU0ls7qSRa9tXqQCkaejnduH00wiTGYfqAGjToRWxoEPrUuqzSd2no8YajKl9QxKEWnJDWKlfug7GDZSzSJfbSBNpmC7Cdd8cqBFgRwD(WWnMLLaUXa)XXoTpd5sbLXoyK621NfikhVyXuOIBZM47NXILXnwslol)xC3VzZg2UmlRlRfyUmvmTmGokgERwZcWlzldu5M71ecBDJ891TFZMTZcLjab0n3pKDldOJIH3Q1Sa8s2YavU5EnHWw3UQ(ixkOm2bJu3U(Sar54flMcvCxE)1Sj((zSyzCJL0IZY)f3NfikhV0mBIVFMU9B2SzKZ9dIH)Y4l(V0Ya6Oy4TAnlaVKTmqLBUxtiS1nY3h5sViLllqs6hhdpPCsbIHNuee82jAbesRK0EhPKMfGxsmPlGuKhPKgWKI4(jTacPXq6b2WaVauYLckJDWi1TRplquoEXIPqf3yPaXWFNG3orlGCH(5cdBXY4glPfNL)lUXmI3FZcWljUHgJ5ILcGmKGuNpmC7Cdd8cqBFgYLckJDWi1TRplquoEXIPqf3qMlAnfVGktAXY4glPfNL)lU7)qWFe4fWlnmJTae81UaO7Gyty)FWWiMUhcTNYut2gbcS(fySAfAxVzznnMLLaUXa)XXonGGwXGzRBEitdTyxxrVB1QZhgUXSSeWng4po2P9zSA1zX4UWbVDEbcAfdMTUrcc1h5sbLXoyK621NfikhVyXuOIB0IDVNj2ILXnwslol)xCJzeV)MfGxsC7SqzcqaDZ9dztUuqzSdgPUD9zbIYXlwmfQ4gTy37zITyzCJL0IZY)f3iesrIRO)ZceLJxAqMlAnfVGkt2fAxVzznTZnmxb8zYyNgqqRyWS1TLDUVUz5LjB2)HxaXWFp3W0KPC8IXIa2DwEzYgwkqm83j4Tt0cinzkhVy6IzeV)MfGxsCdngZflfWDVrUuqzSdgPUD9zbIYXlwmfQ4gTy37zITyzCJL0IZY)f3D2Ia2DwEzYgwkqm83j4Tt0cinzkhVy6IzeV)MfGxsCdngZflfaz9g5sbLXoyK621NfikhVyXuOIB0IDVNj2ILXnwslol)xCJ8weWUZYlt2WsbIH)obVDIwaPjt54ftxmJ493Sa8sIBOXyUyPaUp(UhMLxMSHTlZY6cbkSDtMYXlgYLckJDWi1TRplquoEXIPqf3Of7EptSflJBSKwCw(V4UFmJ493Sa8sIBOXyUyPaS1nc1NRaZiE)nlaVK4gAmMlwkGfbSBNpmC7Cdd8cqBFgYLckJDWi1TRplquoEXIPqf3b(EMxMfJdhVyXY4glPfNL)lU7SfgbU((0TLKlfug7GrQBxFwGOC8IftHkUd89mVmlghoEXILXnwslol)xCBPfbS7ckJt5A2SDwOmbiGU5(HSzleIqE5kJGgcMCPGYyhmsD76ZceLJxSykuX9zIVfdJpeJflJBSKwCw(V4UGY4uUMnBNfktacOBUFiBK5(Sar54LgAXU3ZeB16HNfikhV0c89mVmlghoEHCPxKIC76nlRH0dURN0duGOC8IfKIWyXqAUKYSRNuhbEbcPfugNvgdpPhydd8cqBKlfug7GrQBxFwGOC8IftHkUz21FHxWfYGTyzCJL0IZY)f3q76nlRPDUH5kGptg70(mDplquoEPbzUO1u8cQmj5sbLXoyK621WbqC87ASiGD78HHBNByGxaA7ZqUuqzSdgPUDTJaWc4Oy4TiGD78HHBNByGxaA7ZqU0lsrySq6Xm4Tt2dtQlFdpQmjPbmPPTaeslGqksiDbKIUaH0Sa8sITG0fqAzmyslGmSxskMPynXWtk8cifDbcPPDnK2BieUrUuqzSdgPUDTp4Tt8LDW3WJktAra7gZiE)nlaVK4Mp4Tt8LDW3WJktIm3iXQ1(peuH5kNYKTYyWnHDdCITAfuH5kNYKTYyWTyqwVHq9rUuqzSdgPUDDnqcobL)cvEVfbSBNpmC7Cdd8cqBFgYLckJDWi1TRHkV)wqzSZ1h40IPqf3qSGixkOm2bJu3Ug8NBbLXoxFGtlMcvCJwXqUqU0RErANEWJjP5s6hlKYYwgszZUdPlmPPTqANIHKXigsdmPfugNc5sbLXo4MZUJ7cdjJrmxhFHtlcy3ygX7Vzb4Le3qJXCXsbyR7ENCPxK6QhpIK(XcPDkgsgJyifb7zrklBziD2K0S8YKIH0yYLuoPaXWtkccE7eTacP7qksqkPzb4Le3ixkOm2b3C2DqQBxxyizmI5o7zzra7gZiE)nlaVK4wHHKXiM7SNfYSSlMr8(BwaEjXn0ymxSuaKzz3dZYlt2WsbIH)obVDIwaPjt54fd5c5sV6fPixhXKl9IueglKEWLLaiTdpWFCSdPSI0M0dSHbEbOnspgwVHu4fq6b2WaVausHwubt6cdtk0UEZYAingstBH0ry3Kul7mPybAhdM0nTfaRalK(XcP7qkKH0)4fmM00wiLXxikasdmPmfijDHjnTfspcrqudPq7Pm1Kwq6cinGjnTfGqkRW7jD2KuhH0A20waKEGnmK2HaFMm2H00oWKch82zJ0ontbLjjnxsXioqKM2cP(cNKYSSeaPXa)XXoKUWKM2cPWbVDsAUKEUHHub8zYyhsHxaPZoKYogrqudUrUuqzSdUbzWUzwwc4gd8hh7yra7MbecoByXdFzwwc4gd8hh70TFNpmC7Cdd8cqBFgRwpeApLPMSDeIGOMUhcTNYut2gbcS(fy6cTR3SSM25gMRa(mzStdiOvmyK52YoB1kCWBNxGGwXGzl0UEZYAANByUc4ZKXonGGwXG7RB)WbVDEbcAfdgzUH21Bwwt7CdZvaFMm2Pbe0kgmsTeH6cTR3SSM25gMRa(mzStdiOvmy26MhY4kqERwHdE78ce0kgmYG21BwwtJzzjGBmWFCStZ8bvg7y1QZIXDHdE78ce0kgmBH21Bwwt7CdZvaFMm2Pbe0kgmsTeHSAfApLPMSDeIGOgRwD(WWnh)Ug)hNTptFKl9IueglKYfEzGes3HuKRJKMlPmGfIuoHX(FmM9WKEqWc5l0kJDAKl9I0ckJDWnidgPUDno8YajwKfGxYBa7g8hbEb8sdlm2)JX4ldyH8fALXonH9)bdJy62FwaEjBb(wgJvRzb4LSzeNpmCdQWzm8nGuqzFKl9IueglKYMYWlKgdomcPlmPh4yjfEbKM2cPWbaNK(XcPlG0Dif56iPfCkastBHu4aGts)yPrAhePnPii4Ttsp2si1E9gsHxaPh4yBKlfug7GBqgmsD76pwUrkOwmfQ4ghd83F59LjQCb4Rtz4L7cFHfWcfjIweWUD(WWTZnmWlaT9zSAndubzw25U9Fi0EktnzBcE78cxsFKl9IueglKESLqk70VaMOgmP7qkY1rs3FIdJq6ct6b2WaVa0gPimwi9ylHu2PFbmrngmPXq6b2WaVausdysrC)KAxNcPsK2cGu2jWEkK2HNZGFbvg7q6ci9ydXBiDHjLn(fJxuCJ0oOIKu4fqQztmP5sQJq6NHuhbEbcPfugNvgdpPhBjKYo9lGjQbtAUKIwSBGgyH00wi15dd3ixkOm2b3GmyK621WLC5)fWe1GTiGDFOZhgUDUHbEbOTpt3(peAxVzznTZnm3CbazY2NXQ1dZYlt2o3WCZfaKjBYuoEX0x3(plquoEPz2eF)mDXmI3FZcWljUDwOmbiGU5(HSDBPvRNfikhV0ot8Tyy8Hy6IzeV)MfGxsC7SqzcqaDZ9dzJml7ZQvNpmC7Cdd8cqBFMU9J3V3jgtJhSNYnMZGFbvg70KPC8IXQv8(9oXyAWH4n3f(64xmErXnzkhVy6JCPxKIWyH0JlgdFHkyszzldPL3tAVtAh3EWKwaH0pJfKUasrC)KwaH0yi9aByGxaAJ0o0G)aH0JH)WlGy4j9aByiLv49KIZW7j1ri9ZqklBzinTfsHkCsAgOcPWXeyBb3iLlxgs)4y4jTssriKsAwaEjXKYksBs5KcedpPii4Tt0cinYLckJDWnidgPUDnAmg(cvWwaHiKxUzb4Le72slcy3XGRjsezRRCN72F)NfikhV0kV)A2eF)mD7)qOD9ML10o3WCfWNjJDAFgRwpmlVmzZ(p8cig(75gMMmLJxm91NvRoFy425gg4fG2(m91T)dZYlt2S)dVaIH)EUHPjt54fJvRgX5dd3S)dVaIH)EUHPbe0kgmYGkCEZavSA9qNpmC7Cdd8cqBFM(62)Hz5LjByPaXWFNG3orlG0KPC8IXQvmJ493Sa8sIBOXyUyPaSfH6JCPxKIWyHueESxpIKIG9SiDhsrUoAbP2R3edpPoGqG9isAUKYQIKu4fqkZYsaKgd8hh7q6ciTmgsXmfRb3ixkOm2b3GmyK621)XE9iEN9SSiGDFywEzYM9F4fqm83ZnmnzkhVy6EwGOC8sZSj((zSA1ioFy4M9F4fqm83ZnmTptxNpmC7Cdd8cqBFgRw7hAxVzznTZnmxb8zYyNgqqRyWiZYoB16HNfikhV0y21FHxWfYG7R7HoFy425gg4fG2(mKl9IueglKUdPixhj15NKYaIfezGfs)4y4j9aByiTdb(mzSdPWbaNwqAat6hlgsJbhgH0fM0dCSKUdPC9q6hlKwWPaiTi9CdJZ6tsHxaPq76nlRHubgoGczGqK0AmKcVasT)dVaIHN0ZnmK(zYavinGjnlVmPyAKlfug7GBqgmsD7ANDN7cFtB5wyizmIXIa29HoFy425gg4fG2(mDpeAxVzznTZnmxb8zYyN2NPlMr8(BwaEjXn0ymxSuaKzz3dZYlt2WsbIH)obVDIwaPjt54fJvR978HHBNByGxaA7Z0fZiE)nlaVK4gAmMlwkaBrs3dZYlt2WsbIH)obVDIwaPjt54ft3(zaY5LhY0SSDUH56S(SB)hkS)pyyettqzqeiL)UaZudKy16Hz5LjB2)HxaXWFp3W0KPC8IPpRwf2)hmmIPjOmicKYFxGzQbs6MGyosYMGYGiqk)DbMPgiPbTR3SSMgqqRyWS1TLUkK01ioFy4M9F4fqm83ZnmTptF9z1A)oFy425gg4fG2(mDZYlt2WsbIH)obVDIwaPjt54ftFKlfug7GBqgmsD7AOY7Vfug7C9boTykuXDcI5ijXKlfug7GBqgmsD7AJGzeqLYLbuikalcy32s5t7gduYw39gcrUqU0RErkYv4K0oWo8cPixHZy4jTGYyhCJuojjTssTdEBbqkdiwqKisAUKITxqskuaG(rsAmPaaFMKuODmrg7GjDhspUymKYjfW1hRVqKCPxK2dsoEsrExjSKKcTJjYyNYtk8cif56aKJ0JlgdPSXx4KCPGYyhCdIfKB0ymxhFHtl2XJ4fIfKBlTilaVK3a2nwYRZoFCldbGKJ)I8mqDD(WWntbo6M27N3oBFMUms2GdzmTckJtPl4pc8c4Lg2UmllyFHkxgqGrBc7)dggX09qNpmC7Cdd8cqBFMUms2qC)Gl2UmlRgqqRyWSfo4TZlqqRyWwT68HHBMcC0nT3pVD2(mDzKSH4(bxSDzwwnGGwXGzlpKPHwSRRO)EhP9FOZhgUDUHbEbOTptFUclDv91LrYgI7hCX2Lzz1acAfdMTWbVDEbcAfdMCPxKIWyHuoPaXWtkccE7eTacPbmPiUFszfEpP2rsQm7N3M0Sa8sIjTgdPhCzjas7Wd8hh7qAngspWgg4fGsAbesNnjfiLbrliDbKMlPabgiyBs56Go5GKUdPjRL0fqk6cesZcWljUrUuqzSdUbXcYnwkqm83j4Tt0ciw8XYLLD4LluHZy4DBPfqic5LBwaEjXUT0Ia2D)NfikhV0WsbIH)obVDIwa5c9ZfgU7HNfikhV0y21FHxWfYG7ZQ1(nB2W2LzzDzTaZLPIPbeyGGTlhV0fZiE)nlaVK4gAmMlwkaYSSpYLErkN9cssrUaa9JKuoPaXWtkccE7eTacPq7yIm2H0Cj9iryiLRd6Kds6NH0yiTt3oe5sbLXo4geliK621yPaXWFNG3orlGyXhlxw2HxUqfoJH3TLwaHiKxUzb4Le72slcy3z5LjByPaXWFNG3orlG0KPC8IPRzZg2UmlRlRfyUmvmnGadeSD54LUygX7Vzb4Le3qJXCXsbqgsix6fP74r8cXcIu06ibtAAlKwqzSdP74rK0pUC8cPMpigEsHSRzeFm8KwJH0ztslmPfPaH)7laPfug70ixkOm2b3GybHu3UgngZ1Xx40ID8iEHyb52sYfYLE1lspUkgs70dEmTGuS9(9gsH2tbqA59KcQHxWKUWKMfGxsmP1yifdjtbIftUuqzSdUHwX4gQ8(BbLXoxFGtlMcvC7S7ybobbu62slcy3oFy4MZUZDHVPTClmKmgX0(mKlfug7GBOvmi1TRnbMr8x0IpGSiGDFywaEjBb(Y4lefa5sVifHXcPhyddPDiWNjJDiDhsH21BwwdPm76JHN0kj1lfojfjiePXGRjsej15NKoBsAatkI7NuwH3t6EkaOIH0yW1ejIKgdPh4yBKEC1rcP4pqiLZUmll4qgJRpUymoYyeaP1yi94IXqkB8fojnWKUdPq76nlRHuhbEbcPhOdrAatkNDzwwW(cvinWKkS)pyyetJ0om)SaHuMD9XWtkqWjiGYyhmPbmPFCm8KYzxMLfSVqfspiiWOKwJHu2iJraKgys3F2ixkOm2b3qRyqQBxFUH5kGptg7yra7(Sar54LgZU(l8cUqgC3(JbxtKiIm3ibHSALrYgCiJPvqzCkDb)rGxaV0W2Lzzb7lu5YacmAty)FWWiMUhcTR3SSMgAmMRJVWz7Z09qOD9ML10W2LzzDzTaZ1ivA3(m91T)yW1ejIS19XJqwTMLxMSHLced)DcE7eTastMYXlMUNfikhV0WsbIH)obVDIwa5c9ZfgUVUhcTR3SSMgCiJP9z62)H497DIX0oxFLHxU41FktA1QZhgUDU(kdVCXR)uMS9zSAflzgdpUf8ZcKlE9NYK9rU0lspU6iHu8hiKI4(jL5NK(ziLRd6KdsANY1PhK0DinTfsZcWljPbmPDaOsB4VN0JTeqiKg4H9sslOmofszzldPWbVDgdpPw6k17KMfGxsCJCPGYyhCdTIbPUDn2UmlRlRfyUmvmweWUD(WWn4sU8)cyIAWTpt3dnIZhgUXcuPn83FHlbes7Z0fZiE)nlaVK4gAmMlwkaBrEYLckJDWn0kgK621OXyUyPawaHiKxUzb4Le72slcy3z5LjByPaXWFNG3orlG0KPC8IPlMr8(BwaEjXn0ymxSuaKDwGOC8sdngZflf4c9ZfgU7HMnBy7YSSUSwG5YuX0Ya6Oy47Ei0UEZYAAWHmM2NPlMr8(BwaEjXn0ymxSuaK5g5jxkOm2b3qRyqQBxdvE)TGYyNRpWPftHkUHmyYLEr6XqWBt6bbXcIerspUymKYjfG0ckJDinxsbcmqW2K2XThmPSI0MuSuGy4VtWBNOfqixkOm2b3qRyqQBxJgJ5ILcybeIqE5MfGxsSBlTiGDNLxMSHLced)DcE7eTastMYXlMUygX7Vzb4Le3qJXCXsbq2zbIYXln0ymxSuGl0pxy4UhA2SHTlZY6YAbMltftldOJIHV7Hq76nlRPbhYyAFgYLEr6bbcSainxs)yH0owOtLXoK2PCD6bjnGjLRd6Kds6ci9a9qAGjD2K0pdPlGue3pPq1mBskuHtslsNfGwEs7OCUFqm8KEqFX)fs7pgi)3edpPhxmgs7OCUFGaiLbSq4(iTgdPiUFszfEpPZMKcvmK2XcCeP9yVFE7etkolOJWKgWK(XXWtApi54jfjmqnYLckJDWn0kgK621McDQm2XcieH8YnlaVKy3wAra7UFZMTZcLjab0n3pKDdiWabBxoEXQvZMnSDzwwxwlWCzQyAabgiy7YXlwT2)HoFy4gAmMRro3pqaTpt3yW1ejISfH6CF91TFNpmCZuGJUP9(5TZgolOJyRZhgUzkWr30E)82zdTy3lolOJSA9qSKxND(4wgcajh)fjmq9rU0lsrySqkNDzwwK2blWqAhLkTjnGj9JJHNuo7YSSG9fQq6bbbgL0AmK6iJraKYk8Esf2LjacPMpigEstBH0ry3KuEitJCPGYyhCdTIbPUDn2UmlRlRfyUgPsBlcy3ms2GdzmTckJtPl4pc8c4Lg2UmllyFHkxgqGrBc7)dggX0LrYgCiJPbe0kgmBDZdz6IzeV)MfGxsCdngZflfGTU7nYLErAN6zviIj9JfsrJX44lCIjnGjfQyyedP1yi1(p8cigEsp3WqAGj9ZqAngs)4y4jLZUmllyFHkKEqqGrjTgdPoYyeaPbM0ptJus7uJjYyNY7r0csHkCskAmghFHtsdysrC)KYA)EdPocP)PC8cP5skVKKM2cPGaoj1brszvrgdpPfP8qMg5sbLXo4gAfdsD7A0ymxhFHtlcy39dTR3SSMgAmMRJVWzdYUa8cgzw2TFJ48HHB2)HxaXWFp3W0(mwTEywEzYM9F4fqm83ZnmnzkhVy6ZQvgjBWHmMgqqRyWS1nuHZBgOcs5Hm91LrYgCiJPvqzCkDb)rGxaV0W2Lzzb7lu5YacmAty)FWWiMUms2GdzmnGGwXGrguHZBgOsxmJ493Sa8sIBOXyUyPaS1DVz1QZhgUzkWr30E)82z7Z015dd3o3WaVa02NP7Hq76nlRPDUH56S(S9z62)HG)iWlGxAy7YSSG9fQCzabgTjS)pyyeJvRhYizdoKX0kOmoL(6IL86SZh3Yqai54Vipde5sVifHXcPhyddPSz9jPvsQDWBlaszaXcIerszfPnPhd)HxaXWt6b2Wq6NH0Cjf5jnlaVKyliDbKUPTainlVmjM0DiLRNg5sbLXo4gAfdsD76ZnmxN1NweWUJbxtKiYw3hpc1nlVmzZ(p8cig(75gMMmLJxmDZYlt2WsbIH)obVDIwaPjt54ftxmJ493Sa8sIBOXyUyPaS1TRYQ1(7plVmzZ(p8cig(75gMMmLJxmDpmlVmzdlfig(7e82jAbKMmLJxm9z1kMr8(BwaEjXn0ymxSua3w2h5sViLJrGIYtAhLZ9dIHN0d6l(VqkRiTjLtkqm8KIGG3orlGqklBzi9JlEHuZhedpPi3UEZYAWKlfug7GBOvmi1TRnY5(bXWFz8f)xSiGD3pwYRZoFCldbGKJ)I8mqwTMLxMSz)hEbed)9CdttMYXlM(6MLxMSHLced)DcE7eTastMYXlMUms2GdzmTckJtPl4pc8c4Lg2UmllyFHkxgqGrBc7)dggX015dd3o3WaVa02NPlMr8(BwaEjXn0ymxSua262vrU0ls74oSxs6hlK2r5C)Gy4j9G(I)lKgWKI4(jfQgs5LK0yYL0dSHbEbOKgdoLYybPlG0aMuoPaXWtkccE7eTacPbM0S8YKIH0AmKYk8EsTJKuz2pVnPzb4Le3ixkOm2b3qRyqQBxBKZ9dIH)Y4l(Vyra7UFGadeSD54fRwJbxtKiISEdHSAnlVmz7CdZnxaqMSjt54ftxOD9ML10o3WCZfaKjBabTIbZw39URGhY0x3(p8Sar54LgZU(l8cUqgSvRXGRjserM7JhH6RB)hMLxMSHLced)DcE7eTastMYXlgRw7plVmzdlfig(7e82jAbKMmLJxmDp8Sar54Lgwkqm83j4Tt0cixOFUWW91h5sVifHXcPhGnKUdPixhjnGjfX9tQzh2ljDeXqAUKcv4K0okN7hedpPh0x8FXcsRXqAAlaH0ciK6fmM00UgsrEsZcWljM09NK2pcrkRiTjfAhZpY(AKlfug7GBOvmi1TRp3WCDwFAra7gZiE)nlaVK4gAmMlwkaB7h5rk0oMFKntGX7utEfi7vWnzkhVy6RBm4AIer26(4rOUz5LjByPaXWFNG3orlG0KPC8IXQ1dZYlt2WsbIH)obVDIwaPjt54fd5sVifHXcPC2LzzrAhSatNqAhLkTjnGjnTfsZcWljPbM0Yz)jP5sQjesxaPiUFsTRtHuo7YSSG9fQq6bbbgLuH9)bdJyiLvK2KECXyCKXiasxaPC2LzzbhYyiTGY4uAKlfug7GBOvmi1TRX2LzzDzTaZ1ivABbeIqE5MfGxsSBlTiGD3FwaEjB2s5t7gduYwK05UygX7Vzb4Le3qJXCXsbylY3NvR9ZizdoKX0kOmoLUG)iWlGxAy7YSSG9fQCzabgTjS)pyyetxmJ493Sa8sIBOXyUyPaS1DV1h5sVifHXcPCFaqgJainxspUYmcgt6oKwKMfGxsst7kjnWKYVXWtAUKAcH0kjnTfsbbVDsAgOsJCPGYyhCdTIbPUDn(daYyeWn3lAzgbJTacriVCZcWlj2TLweWUZcWlzldu5M71ecBrsN768HHBNByGxaAZSSgYLErkcJfspWggs7zbazss3XJiPbmPCDqNCqsRXq6b6H0ciKwqzCkKwJH00winlaVKKYAh2lj1ecPMpigEstBHui7AgX3ixkOm2b3qRyqQBxFUH5MlaitAbeIqE5MfGxsSBlTiGDFwGOC8sZSj((z62VZhgUDUHbEbOnZYASA15dd3o3WaVa0gqqRyWSfAxVzznTZnmxN1NnGGwXGTALbiNxEitZY25gMRZ6ZUh68HHBo(Dn(poBaPGYUygX7Vzb4Le3qJXCXsbyBV3x3ZceLJxANj(wmm(qmDXmI3FZcWljUHgJ5ILcW2(riK2VRYvKLxMSLScCEx4lCLstMYXlM(6JCPGYyhCdTIbPUDnAmghzmcWIa2D)z5LjByPaXWFNG3orlG0KPC8IPlMr8(BwaEjXn0ymxSuaKDwGOC8sdngZflf4c9Zfg2QvZMnSDzwwxwlWCzQyAzaDum8919Sar54L2zIVfdJped5sVifHXcPCDqN0rszfPnPhSIXbi1rcG0dIlpkP)XlymPPTqAwaEjjLv49K6iK6i(LfPiPZSJIuhbEbcPPTqk0UEZYAifArfmPof0rnYLckJDWn0kgK621y7YSSUSwG5AKkTTiGDd(JaVaEPXuX4aK6ibCzWLhTjS)pyyet3ZceLJxAMnX3pt3Sa8s2YavU5EzGYls6mY6hAxVzznnSDzwwxwlWCnsL2nZhuzSds5Hm9rU0lsrySqkNDzwwKICGcBt6oKICDK0)4fmM00wacPfqiTmgmPXaTOXW3ixkOm2b3qRyqQBxJTlZY6cbkSTfbSBqfMRCkt2kJb3Ibzw2zYLErkcJfspUymKYjfG0CjfAh8hviTJf4is7XE)82jMugWcHjDhs7uxDhQrApU6o6Qjf52boaOKgyst7atAGjTi1o4TfaPmGybrIiPPDnKceZMzm8KUdPDQRUdr6F8cgtQPahrAAVFE7etAGjTC2FsAUKMbQq6(tYLckJDWn0kgK621OXyUyPawaHiKxUzb4Le72slcy3ygX7Vzb4Le3qJXCXsbq2zbIYXln0ymxSuGl0pxy4UoFy4MPahDt79ZBNTpJfq2vmUT0Iysba(m5nqrftuP42slIjfa4ZK3a2DgqhHrMBKNCPx9I0EC1D0v3jKskYzlqhrAAhyspUymKES(crsdugVGktwzSdP5skwesdysJKuhGuhHjDtBbqky)zmcPq21mIht6ct6XfJH0J1xiYoAsrlejDeXqAUKIwhjKM2bMuhGuhv8cP74rKuwl4iszfPnPPTqkwssD25JBKl9IueglKECXyi9y9fIKMlPq7G)OcPDSahrAp27N3oXKYawimP7qkxpKU)ehgH0fM0dCSnYLckJDWn0kgK621OXyUW(crlcy3oFy4MPahDt79ZBNTpt3ZceLJxAMnX3pt3dD(WWTZnmWlaT9z6E4zbIYXlnMD9x4fCHm4Uq76nlRPHgJ564lC2G)E)fiq2fGxUzGkiZnpKPHwSRfq2vmUT0Iysba(m5nqrftuP42slIjfa4ZK3a2DgqhHrMBKV7HoFy4MPahDt79ZBNTpd5sVifHXcPhxmgszJVWjPbmPiUFsn7WEjPJigsZLuGadeSnPDC7b3iLlxgsHkCgdpPvskYt6cifDbcPzb4LetkRiTjLtkqm8KIGG3orlGqAwEzsXqAngsrC)KwaH0zts)4y4jLZUmllyFHkKEqqGrjDbKEqmIq2bePhZyoQHzeV)MfGxsCdngZflfazhJqis5LetAAlKIgtG(rjDHjfHiTgdPPTq68rDeaPlmPzb4Le3iTt941csnlPZMKYaemMu0ymo(cNK(Nm8KwEpPzb4LetAbesnBMIHuwrAt6b6Huw2Yq6hhdpPy7YSSG9fQqkdiWOKgWK6iJraKgysRZk8LJxAKlfug7GBOvmi1TRrJXCD8foTiGDFwGOC8sZSj((z6cQWCLtzYg6EkOYKTyqguHZBgOcs7CdH6IzeV)MfGxsCdngZflfGT9J8ifjUIS8YKn0alaeBYuoEXG0ckJt5A2SDwOmbiGU5(HSDfz5LjBmyeHSdORpMJAYuoEXG0(XmI3FZcWljUHgJ5ILcGSJriuFUI(zKSbhYyAfugNsxWFe4fWlnSDzwwW(cvUmGaJ2e2)hmmIPV(62)HG)iWlGxAy7YSSG9fQCzabgTjS)pyyeJvRhcTR3SSMgCiJP9z6c(JaVaEPHTlZYc2xOYLbey0MW()GHrmwTEwGOC8s7mX3IHXhIPpYLErk7SadeSnPhOqzcqarAp7hYMuwbw8isQtHfdP7qAhl0PYyhsRXq6M2cG0EkVmjUrUuqzSdUHwXGu3U(SqzcqaDZ9dzBbeIqE5MfGxsSBlTiGDdeyGGTlhV0nlaVKTmqLBUxtiiZTLhF3(nB2oluMaeq3C)q2TmGokgERwp8Sar54L2zIVfdJpetFDplquoEPHwS79mXiRZwT2FwEzYgAGfaInzkhVy6A2SHTlZY6YAbMltftdiWabBxoEPpRwD(WWT)a)b(y4VMcC0iyC7ZqU0ls5yeOO8KcTJjYyhsZLuCUmKcv4mgEs56Go5GKUdPlmSRuwaEjXKYYwgsHdE7mgEs7DsxaPOlqifNf0rIHu01btAngs)4y4j9GyeHSdispMXCeP1yifbU6Ei94cSaqSrUuqzSdUHwXGu3UgBxML1L1cmxMkglcy3abgiy7YXlDZcWlzldu5M71ecYq(UhMLxMSHgybGytMYXlMUz5LjBmyeHSdORpMJAYuoEX0fZiE)nlaVK4gAmMlwkaYqc5sViLDSimKY1bDYbj9Zq6oKwysrRbrsZcWljM0ctkZIXHJxSGuHDHeMKuw2YqkCWBNXWtAVt6cifDbcP4SGosmKIUoyszfPnPheJiKDar6XmMJAKlfug7GBOvmi1TRX2LzzDzTaZLPIXISa8sEdy3abgiy7YXlDZcWlzldu5M71ecYq(UhMLxMSHgybGytMYXlMUh2FwEzYgwkqm83j4Tt0cinzkhVy6IzeV)MfGxsCdngZflfazNfikhV0qJXCXsbUq)CHH7RB)hMLxMSXGreYoGU(yoQjt54fJvR9NLxMSXGreYoGU(yoQjt54ftxmJ493Sa8sIBOXyUyPaS1ns6RpYLErkcJfspwVGTHafCs6(tCyesxysrRyifAxVzznysZLu0kMSIH0dS(kdVqk36pLjj15dd3ixkOm2b3qRyqQBxd7fSneOGtlcy3497DIX0oxFLHxU41Fkt29qNpmC7Cdd8cqBFMUh68HHBmllbCJb(JJDAFMUoFy4256Rm8YfV(tzYgqqRyWS1YoBrmPaaFM8gOOIjQuCBPfXKca8zYBa7odOJWiZTLKlfug7GBOvmi1TRrJXCXsbSilaVK3a2nMr8(BwaEjXn0ymxSuaKDwGOC8sdngZflf4c9Zfg2ci7kg3wArmPaaFM8gOOIjQuCBPfXKca8zYBa7odOJWiZnsixkOm2b3qRyqQBxJgJ5c7leTaYUIXTLwetkaWNjVbkQyIkf3wArmPaaFM8gWUZa6imYCJKU9FOZhgUzkWr30E)82z7Zy1k0UEZYAANByUoRpBFMU978HHBNByGxaA7Zy16HoFy4MPahDt79ZBNTptxNpmCZey8o1KxbYEfC7Z0xFKl9IueglKY1bDshjTWK6lCskqWlijnGjDhstBHu09uixkOm2b3qRyqQBxJTlZY6YAbMRrQ0MCPxKIWyHuUoOtoiPfMuFHtsbcEbjPbmP7qAAlKIUNcP1yiLRd6KosAGjDhsrUosUuqzSdUHwXGu3UgBxML1L1cmxMkgYfYLErkcJfs3HuKRJK2PCD6bjnxs5LK0oU9qAgqhfdpP1yivyxMaiKMlP(yes)mK6izkaszfPnPhydd8cqjxkOm2b3sqmhjj29hl3ifulMcvClOmicKYFxGzQbsSiGDdTR3SSM25gMRa(mzStdiOvmy262sKy1k0UEZYAANByUc4ZKXonGGwXGrgs6nYLErApaejnxs5qCGiTdZoshjLvK2K2X974fs5Yc6iXqkY1rmPbmPmlghoEPrQREi1VdVaifo4TtmPSI0Mu0fiK2HzhPJK(XcM0ktbLjjnxsXioqKYksBsRbrsHmKUaszh8XjPFSqAKnYLckJDWTeeZrsIrQBx)XYnsb1IPqf3XGHa)SC8YL9)1KF0RrodiXIa2TZhgUDUHbEbOTptxNpmCJzzjGBmWFCSt7Zy1QZIXDHdE78ce0kgmBDJKoB1QZhgUXSSeWng4po2P9z6cTR3SSM25gMRa(mzStdiOvmyKAjcHm4G3oVabTIbB1QZhgUDUHbEbOTptxOD9ML10ywwc4gd8hh70acAfdgPwIqido4TZlqqRyWwT2p0UEZYAAmllbCJb(JJDAabTIbJm3w25Uq76nlRPDUH5kGptg70acAfdgzUTSZ91fo4TZlqqRyWiZTLUYDMCPxKYH4arkNTijPh3hhqKYksBspWgg4fGsUuqzSdULGyossmsD76pwUrkOwmfQ4gTGkhGCX2IKx0poGSiGDdTR3SSM25gMRa(mzStdiOvmyKzzNjx6fPCioqKYo)DqKuwrAt6bxwcG0o8a)XXoK(XfVybPO1rcP4pqinxsXtWiKM2cP(LLGtspgoiPzb4LSrAhyldPFSyiLvK2KYzxMLLyi1vdCiDHjTNfGktAbPSd(4K0pwiDhsrUosAHjf9dztAHjLzX4WXlnYLckJDWTeeZrsIrQBx)XYnsb1IPqf34979sMXWFbFheTacriVCZcWlj2TLweWUD(WWnMLLaUXa)XXoTpJvRhYacbNnS4HVmllbCJb(JJDSAvy)FWWiMg2UmllXCxGZDHV5cqLjjx6fPhBaWjPCbF4jfJwEpPltgOXX4kJDiLvK2KYTFVxYmgEszN)oisUuqzSdULGyossmsD76pwUrkOwmfQ4oTLlCaW5fh8H3Ia2TZhgUDUHbEbOTpJvRoFy4gZYsa3yG)4yN2NXQ1dzaHGZgw8WxMLLaUXa)XXowTcTR3SSM25gMRa(mzStdiOvmyKzzNTATFH9)bdJyA4979sMXWFbFhe7EycI5ijB4979sMXWFbFheBq76nlRP9z6ZQvNfJ7ch825fiOvmy2IKotU0lsrySqkBkdVqAm4WiKUWKEGJLu4fqAAlKchaCs6hlKUas3HuKRJKwWPainTfsHdaoj9JLgPC2lijfkaq)ijnGj9CddPc4ZKXoKcTR3SSgsdmPw2zmPlGu0fiKwSkeBKlfug7GBjiMJKeJu3U(JLBKcQftHkUXXa)9xEFzIkxa(6ugE5UWxybSqrIOfbSBOD9ML10o3WCfWNjJDAabTIbJm3w2zYLErkcJfs5SlZYsmK6QboKUWK2ZcqLjjLLTmKoBsAmKEGnmWla1csxaPXqQJKSezi9aByiLnRpjfQWjM0yi9aByGxaAJ0oftk7yebrnKUasrGabw)cmK6Jrinss)mKYksBsXzbDKyifAxVzzn4g5sbLXo4wcI5ijXi1TR)y5gPGAXuOIBSDzwwI5UaN7cFZfGktAra7gAxVzznnMLLaUXa)XXonGGwXGzRBl7CxOD9ML10o3WCfWNjJDAabTIbZw3w25U9dTNYut2gbcS(fySAfApLPMSDeIGOM(SATFO9uMAY2PmPnIaRwH2tzQjBtWBNx4s6RB)h68HHBNByGxaA7Zy1kdqoV8qMMLTZnmxN1N9z1QZIXDHdE78ce0kgmBDJ8DMCPxKIWyH00oWKUdPixhjfEbKIwSlPixhzNjxkOm2b3sqmhjjgPUD9hl3ifulMcvCxai7ifOeFJHxMFKiEHwGqU0ls7OaxFFskC59of0rKcVas)4YXlKgPGI7esrySq6oKcTR3SSgsJH0fyeaPoisAcI5ijjf73SrUuqzSdULGyossmsD76pwUrkOylcy3oFy425gg4fG2(mwT68HHBmllbCJb(JJDAFgRwH21Bwwt7CdZvaFMm2Pbe0kgmYSSZV8LVha]] )
    

end
