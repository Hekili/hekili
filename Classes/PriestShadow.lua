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


    spec:RegisterPack( "Shadow", 20220301, [[dm1CYcqivipssvUekviztssFcLQmkjLoLKIvHsL8kiIzrjClQGk7sIFjjyyubogLOLbr1ZKuvMgejxtfkBdLk13GGQXPcvDoQGQwNKO8ouQqQ5HsP7rfTpik)tfQihusuTqukEiePMOKixKkOSriO8ruQOgPkuHtkjKwjvOxIsfQzQcv6MsQQ2je4NscXqvb1rvHkQLIsf5POYuLu5Qqq2QkiFvsOglkvG9Qk)vLgmPdl1IPspgKjtXLj2mO(mQA0uQtlSAuQGETkWSPQBdPDR43knCuCCQGSCGNd10fDDv12vrFhLmEuQQZdHwpkviMpL0(r(z5RUhNPt5HaK7aKJChuFoa5fh4ahWUpgs94sezKhhtdDqZlpUPrLhhNDBwwpoMgr)2MxDpo8(bqYJZotgCLvHkWhP93TaTOvahOFFNXoqGgoRaoqHQWJZ9h(SIop3hNPt5HaK7aKJChuFoa5fh4ahWUpgYFC9pTxWJJlqr6hNDymY8CFCgbd944SBZYI0ddcbNKJ1FdGSj1slif5oa5iNCKCePT7HxWvg5OdhP1Xs6di9qByiTUfaKjjLLTmKMnGxssH2)KysBGqk8cGetHC0HJ0ddKugdPMnXK2aH0pdPSSLH0Sb8sIjTbcPq(flKMlPgeJH3csXlPPDNKo)demPnqifNH3tkqGwuuzmIP848boXV6ECODmV6EiWYxDpozAxVyES5XbbIuar)4C)WWf3DN7cFtB52yizmIP8zEC4eeq5dbw(4AOm25Xb1E)THYyNRpW5JZh48onQ84C3DE5dbi)v3JtM21lMhBECqGifq0pUJinBaVKLaFz8nIc4X1qzSZJZeygXFrB(a6LpeuFV6ECY0UEX8yZJRHYyNh35gMRa(mzSZJZiyiqWKXopoeclKEOnmK6WaFMm2H0DifAxVzznKYSRpgEs7KuV04KuKFmsJb3tKisATlGuKYbKcVaszJFxdPompmP7q6YiJaQHu3Fs6SjPbmPiUFszfEpP7PaGAgsJb3tKisAmKEiewH06Vpqif)bcPC2TzzbhYyQq9hJXvgJaiThdP1FmgszJVXjPbM0DifAxVzznK6kWlqi9qomsdys5SBZYc23OcPbMuXH(bdJykKwr5NfiKYSRpgEsbcobbug7GjnGj9JJHNuo72SSG9nQq6HbbgL0EmKYgzmcG0at6(ZYJdcePaI(XD2GOD9sHzx)fEbxidM0QKwlPXG7jsejfzojf5hJuKqATKA5XiLDrATKcAiP4631CfpmPvjnduHu2sA95asRH0Ai1QvszKSahYyknugNcPvjf8hbEb8sbB3MLfSVrLldiWOfXH(bdJyiTkPhrk0UEZYAkOXyUU(gNLpdPvj9isH21BwwtbB3ML1L1cmxJ0PD5ZqAnKwL0AjngCprIiPS1jPh)Xi1QvsZ2ltwWsdIH)obVDI2aPit76fdPvj9Sbr76LcwAqm83j4Tt0gixOFUWWKwdPvj9isH21BwwtboKXu(mKwL0Aj9isX737gJPCU(odVCXR)uMSit76fdPwTsQ7hgUCU(odVCXR)uMS8zi1QvsXsMXWJlb)Sa5Ix)PmjP18YhcqQxDpozAxVyES5X1qzSZJdB3ML1L1cmxMoMhNrWqGGjJDEC1FFGqk(desrC)KY8ts)mKYvXv2HjTY5Q8dt6oKM2cPzd4LK0aM0kg0Pn83tkcRfqiKg4H9ssBOmofszzldPWbVDgdpPw6WvFKMnGxsC5XbbIuar)4C)WWf4wU8)gyIEWLpdPvj9isnI7hgUWc0Pn83FHBbes5ZqAvsXmI3FZgWljUGgJ5ILgqkBjfPE5dbh7v3JtM21lMhBECnug784qJXCXsdECqGifq0pUS9YKfS0Gy4VtWBNOnqkY0UEXqAvsXmI3FZgWljUGgJ5ILgqkYi9Sbr76LcAmMlwAWf6NlmmPvj9isnBwW2TzzDzTaZLPJPKb0bXWtAvspIuOD9ML1uGdzmLpdPvjfZiE)nBaVK4cAmMlwAaPiZjPi1JdcriVCZgWlj(HalF5dbS7xDpozAxVyES5X1qzSZJdQ9(BdLXoxFGZhNpW5DAu5XbzWV8Hae(RUhNmTRxmp284AOm25XHgJ5ILg84GqeYl3Sb8sIFiWYhheisbe9JlBVmzblnig(7e82jAdKImTRxmKwLumJ493Sb8sIlOXyUyPbKImspBq0UEPGgJ5ILgCH(5cdtAvspIuZMfSDBwwxwlWCz6ykzaDqm8KwL0JifAxVzznf4qgt5Z84mcgcemzSZJ74i4Tj9WGybrIiP1Fmgs5KgqAdLXoKMlPabgiyBsR0whMuwrAtkwAqm83j4Tt0giV8HGJ)v3JtM21lMhBECnug784mn60zSZJdcriVCZgWlj(HalFCqGifq0pUAj1Sz5SrzcqaDZ9dzxacmqW2TRxi1QvsnBwW2TzzDzTaZLPJPaeyGGTBxVqQvRKwlPhrQ7hgUGgJ5AKZ9deq5ZqAvsJb3tKiskBj9yoG0AiTgsRsATK6(HHlMgCWnT3pVDwWzdDaPSLu3pmCX0GdUP9(5TZcAZ(xC2qhqQvRKEePyjVU78XLmeaYp(lYzGiTMhNrWqGGjJDEChgiWcG0Cj9JfsRuJoDg7qALZv5hM0aMuUkUYomPlG0dvhPbM0zts)mKUasrC)Kc1ZSjPqnojTjDwaA7jTsY5(bXWt6H9n)xiT2yG8Ftm8Kw)XyiTsY5(bcGugWcHRH0EmKI4(jLv49KoBskuZqALAWbKwN9(5TtmP4SHoatAat6hhdpP1H8JNuKZavE5dbo8V6ECY0UEX8yZJRHYyNhh2UnlRlRfyUgPt7hNrWqGGjJDECiewiLZUnllsR4fyiTssN2KgWK(XXWtkNDBwwW(gvi9WGaJsApgsDLXiaszfEpPc7ZeaHuZhedpPPTq6iSFskpKP84GarkGOFCmswGdzmLgkJtH0QKc(JaVaEPGTBZYc23OYLbey0I4q)GHrmKwLugjlWHmMcqq7yWKYwNKYdziTkPygX7Vzd4LexqJXCXsdiLTojfH)YhcS0bV6ECY0UEX8yZJRHYyNhhAmMRRVX5JZiyiqWKXopUk3ZQret6hlKIgJX134etAatkuZWigs7XqQ9F4fqm8KEUHH0at6NH0EmK(XXWtkNDBwwW(gvi9WGaJsApgsDLXiasdmPFMcPKw5gtKXoT3JOfKc14Ku0ymU(gNKgWKI4(jL1(9gsDfs)t76fsZLuEjjnTfsbbCsQlIKYQJmgEsBs5HmLhheisbe9JRwsH21BwwtbngZ1134Saz3aEbtkYi1ssRsATKAe3pmCX(p8cig(75gMYNHuRwj9isZ2ltwS)dVaIH)EUHPit76fdP1qQvRKYizboKXuacAhdMu26KuOgN3mqfsrcP8qgsRH0QKYizboKXuAOmofsRsk4pc8c4Lc2UnllyFJkxgqGrlId9dggXqAvszKSahYykabTJbtkYifQX5nduH0QKIzeV)MnGxsCbngZflnGu26KueoPwTsQ7hgUyAWb30E)82z5ZqAvsD)WWLZnmWlaT8ziTkPhrk0UEZYAkNByUURplFgsRsATKEePG)iWlGxky72SSG9nQCzabgTio0pyyedPwTs6rKYizboKXuAOmofsRH0QKIL86UZhxYqai)4Vifd0lFiWslF194KPD9I5XMhxdLXopUZnmx31NpoJGHabtg784qiSq6H2WqkBwFsANKAh82cGugqSGirKuwrAt6XXF4fqm8KEOnmK(zinxsrksZgWlj2csxaPBAlasZ2ltIjDhs5QR84GarkGOFCXG7jsejLToj94pgPvjnBVmzX(p8cig(75gMImTRxmKwL0S9YKfS0Gy4VtWBNOnqkY0UEXqAvsXmI3FZgWljUGgJ5ILgqkBDsk7MuRwjTwsRL0S9YKf7)WlGy4VNBykY0UEXqAvspI0S9YKfS0Gy4VtWBNOnqkY0UEXqAnKA1kPygX7Vzd4LexqJXCXsdi1jPwsAnV8Halr(RUhNmTRxmp284AOm25XzKZ9dIH)Y4B(V84mcgcemzSZJJJrGI2tALKZ9dIHN0d7B(VqkRiTjLtAqm8KIGG3orBGqklBzi9JBEHuZhedpPi9UEZYAWpoiqKci6hxTKIL86UZhxYqai)4VifdePwTsA2EzYI9F4fqm83ZnmfzAxVyiTgsRsA2EzYcwAqm83j4Tt0gifzAxVyiTkPmswGdzmLgkJtH0QKc(JaVaEPGTBZYc23OYLbey0I4q)GHrmKwLu3pmC5Cdd8cqlFgsRskMr8(B2aEjXf0ymxS0aszRtsz3V8HalRVxDpozAxVyES5X1qzSZJZiN7hed)LX38F5XzemeiyYyNhxL2H9ss)yH0kjN7hedpPh238FH0aMue3pPq9qkVKKgtUKEOnmWlaL0yWP0gliDbKgWKYjnigEsrqWBNOnqinWKMTxMumK2JHuwH3tQDKKkZ(5TjnBaVK4YJdcePaI(XvlPabgiy721lKA1kPXG7jsejfzKIWpgPwTsA2EzYY5gMBUaGmzrM21lgsRsk0UEZYAkNByU5caYKfGG2XGjLTojT(iLDrkpKH0AiTkP1s6rKE2GOD9sHzx)fEbxidMuRwjngCprIiPiZjPh)XiTgsRsATKEePz7LjlyPbXWFNG3orBGuKPD9IHuRwjTwsZ2ltwWsdIH)obVDI2aPit76fdPvj9ispBq0UEPGLged)DcE7eTbYf6NlmmP1qAnV8HalrQxDpozAxVyES5X1qzSZJ7CdZ1D95JZiyiqWKXopoeclKEi2q6oKI0vI0aMue3pPMDyVK0redP5skuJtsRKCUFqm8KEyFZ)fliThdPPTaesBGqQxWyst7EifPinBaVKys3FsAThJuwrAtk0oMFK1uECqGifq0pomJ493Sb8sIlOXyUyPbKYwsRLuKIuKqk0oMFKftGX70tEfi7vWfzAxVyiTgsRsAm4EIerszRtsp(JrAvsZ2ltwWsdIH)obVDI2aPit76fdPwTs6rKMTxMSGLged)DcE7eTbsrM21lMx(qGLh7v3JtM21lMhBECnug784W2TzzDzTaZ1iDA)4GqeYl3Sb8sIFiWYhheisbe9JRwsZgWlzXwAFAxyGsszlPi3bKwLumJ493Sb8sIlOXyUyPbKYwsrksRHuRwjTwszKSahYyknugNcPvjf8hbEb8sbB3MLfSVrLldiWOfXH(bdJyiTkPygX7Vzd4LexqJXCXsdiLTojfHtAnpoJGHabtg784qiSqkNDBwwKwXlWuzKwjPtBsdystBH0Sb8ssAGjTD3FsAUKAcH0fqkI7Nu7(uiLZUnllyFJkKEyqGrjvCOFWWigszfPnP1FmgxzmcG0fqkNDBwwWHmgsBOmoLYlFiWs29RUhNmTRxmp284AOm25XH)aGmgbCZ9I2MrW4hheIqE5MnGxs8dbw(4GarkGOFCzd4LSKbQCZ9AcHu2skYDaPvj19ddxo3WaVa0IzznpoJGHabtg784qiSqk3haKXiasZL06VnJGXKUdPnPzd4LK00UtsdmP8Bm8KMlPMqiTtstBHuqWBNKMbQuE5dbwIWF194KPD9I5XMhxdLXopUZnm3CbazYhheIqE5MnGxs8dbw(4GarkGOFCNniAxVumBIVFgsRsATK6(HHlNByGxaAXSSgsTALu3pmC5Cdd8cqlabTJbtkBjfAxVzznLZnmx31NfGG2XGj1QvszaY5LhYuSSCUH56U(K0QKEePUFy4IRFxJ)JZcqAOK0QKIzeV)MnGxsCbngZflnGu2sA9rAnKwL0ZgeTRxkNj(2mm(qmKwLumJ493Sb8sIlOXyUyPbKYwsRL0JrksiTwsz3KYUinBVmzjzf48UWx4oLImTRxmKwdP184mcgcemzSZJdHWcPhAddP1TaGmjP74rK0aMuUkUYomP9yi9q1rAdesBOmofs7XqAAlKMnGxsszTd7LKAcHuZhedpPPTqkKDpJ4lV8Halp(xDpozAxVyES5XbbIuar)4QL0S9YKfS0Gy4VtWBNOnqkY0UEXqAvsXmI3FZgWljUGgJ5ILgqkYi9Sbr76LcAmMlwAWf6NlmmPwTsQzZc2UnlRlRfyUmDmLmGoigEsRH0QKE2GOD9s5mX3MHXhI5X1qzSZJdngJRmgb8YhcS0H)v3JtM21lMhBECnug784W2TzzDzTaZ1iDA)4mcgcemzSZJdHWcPCvCLvjszfPnPhUJXfi9bcG0dJBpkP)XlymPPTqA2aEjjLv49K6kK6k(LfPi3bSJIuxbEbcPPTqk0UEZYAifArfmPUn0bLhheisbe9Jd8hbEb8sHPJXfi9bc4YGBpArCOFWWigsRs6zdI21lfZM47NH0QKMnGxYsgOYn3lduErUdifzKwlPq76nlRPGTBZY6YAbMRr60Uy(GoJDifjKYdziTMx(qaYDWRUhNmTRxmp284AOm25XHTBZY6cbAS9JZiyiqWKXopoeclKYz3MLfPinOX2KUdPiDLi9pEbJjnTfGqAdesBJbtAmqlAm8Lhheisbe9Jd0H5kNYKL2yWLyifzKAPdE5dbi3YxDpozAxVyES5XbbIuar)4WmI3FZgWljUGgJ5ILgqkYi9Sbr76LcAmMlwAWf6NlmmPvj19ddxmn4GBAVFE7S8zECgbdbcMm25XHqyH06pgdPCsdinxsH2b)rfsRudoG06S3pVDIjLbSqys3H0kVI4WkKwxfPsvesr6DGdakPbM00oWKgysBsTdEBbqkdiwqKisAA3dPaXSzgdpP7qALxrCyK(hVGXKAAWbKM27N3oXKgysB39NKMlPzGkKU)8XbHiKxUzd4Le)qGLpUysba(m5nGFCzaDagzorQhxmPaaFM8gOOIj6uECw(4GS7yECw(4AOm25XHgJ5ILg8YhcqoYF194KPD9I5XMhNrWqGGjJDECiewiT(JXqkcZ3isAUKcTd(JkKwPgCaP1zVFE7etkdyHWKUdPC1r6(tCyesxyspecR84GarkGOFCUFy4IPbhCt79ZBNLpdPvj9Sbr76LIzt89ZqAvspIu3pmC5Cdd8cqlFgsRs6rKE2GOD9sHzx)fEbxidM0QKcTR3SSMcAmMRRVXzb(79xGaz3aE5MbQqkYCskpKPG2S)JlMuaGptEd4hxgqhGrMtKQ6rUFy4IPbhCt79ZBNLpZJlMuaGptEduuXeDkpolFCq2DmpolFCnug784qJXCH9nIV8HaKxFV6ECY0UEX8yZJRHYyNhhAmMRRVX5JZiyiqWKXopoeclKw)XyiLn(gNKgWKI4(j1Sd7LKoIyinxsbcmqW2KwPToCHuUCzifQXzm8K2jPifPlGu0fiKMnGxsmPSI0MuoPbXWtkccE7eTbcPz7LjfdP9yifX9tAdesNnj9JJHNuo72SSG9nQq6HbbgL0fq6HXiczhqKECJ5GcMr8(B2aEjXf0ymxS0aKDC6yKYljM00wifnMa9Js6ct6XiThdPPTq68rDfaPlmPzd4LexiTY941csnlPZMKYaemMu0ymU(gNK(Nm8K2EpPzd4LetAdesnBMIHuwrAt6HQJuw2Yq6hhdpPy72SSG9nQqkdiWOKgWK6kJraKgys7Zo8TRxkpoiqKci6h3zdI21lfZM47NH0QKc6WCLtzYc6EkOYKLyifzKc148MbQqksi1bLJrAvsXmI3FZgWljUGgJ5ILgqkBjTwsrksrcPiNu2fPz7LjlObwaiwKPD9IHuKqAdLXPCnBwoBuMaeq3C)q2KYUinBVmzHbJiKDaD9XCqrM21lgsrcP1skMr8(B2aEjXf0ymxS0asr2XjspgP1qk7I0AjLrYcCiJP0qzCkKwLuWFe4fWlfSDBwwW(gvUmGaJweh6hmmIH0AiTgsRsATKEePG)iWlGxky72SSG9nQCzabgTio0pyyedPwTs6rKcTR3SSMcCiJP8ziTkPG)iWlGxky72SSG9nQCzabgTio0pyyedPwTs6zdI21lLZeFBggFigsR5LpeGCK6v3JtM21lMhBECnug784oBuMaeq3C)q2poieH8YnBaVK4hcS8XbbIuar)4acmqW2TRxiTkPzd4LSKbQCZ9AcHuK5KulpEsRsATKA2SC2OmbiGU5(HSlzaDqm8KA1kPhr6zdI21lLZeFBggFigsRH0QKE2GOD9sbTz)7zIjfzK6asTAL0AjnBVmzbnWcaXImTRxmKwLuZMfSDBwwxwlWCz6ykabgiy721lKwdPwTsQ7hgU8h4pWhd)10GdgbJlFMhNrWqGGjJDECStcmqW2KEOgLjabeP1TFiBszfyXJiPUnwmKUdPvQrNoJDiThdPBAlasRR9YK4YlFia5h7v3JtM21lMhBECnug784W2TzzDzTaZLPJ5XzemeiyYyNhhhJafTNuODmrg7qAUKIZLHuOgNXWtkxfxzhM0DiDHHD4YgWljMuw2YqkCWBNXWtA9r6cifDbcP4SHoqmKIUUys7Xq6hhdpPhgJiKDar6XnMdiThdPiOIuhP1FGfaILhheisbe9JdiWabB3UEH0QKMnGxYsgOYn3RjesrgPifPvj9isZ2ltwqdSaqSit76fdPvjnBVmzHbJiKDaD9XCqrM21lgsRskMr8(B2aEjXf0ymxS0asrgPi)LpeGC29RUhNmTRxmp284mcgcemzSZJJDSimKYvXv2Hj9Zq6oK2ysr7brsZgWljM0gtkZIXHRxSGuH9HeMKuw2YqkCWBNXWtA9r6cifDbcP4SHoqmKIUUyszfPnPhgJiKDar6XnMdkpoiqKci6hhqGbc2UD9cPvjnBaVKLmqLBUxtiKImsrksRs6rKMTxMSGgybGyrM21lgsRs6rKwlPz7LjlyPbXWFNG3orBGuKPD9IH0QKIzeV)MnGxsCbngZflnGuKr6zdI21lf0ymxS0Gl0pxyysRH0QKwlPhrA2EzYcdgri7a66J5GImTRxmKA1kP1sA2EzYcdgri7a66J5GImTRxmKwLumJ493Sb8sIlOXyUyPbKYwNKICsRH0AECnug784W2TzzDzTaZLPJ5LpeGCe(RUhNmTRxmp284AOm25Xb7fSneOHZhxmPaaFM8gWpUmGoaJmNw(4Ijfa4ZK3afvmrNYJZYhheisbe9JdVFVBmMY567m8YfV(tzYImTRxmKwL0Ji19ddxo3WaVa0YNH0QKEePUFy4cZYsa3yG)4yNYNH0QK6(HHlNRVZWlx86pLjlabTJbtkBj1sh84mcgcemzSZJdHWcPimVGTHanCs6(tCyesxysr7yifAxVzznysZLu0oMSJH0dT(odVqk36pLjj19ddxE5dbi)4F194KPD9I5XMhheisbe9JdZiE)nBaVK4cAmMlwAaPiJ0ZgeTRxkOXyUyPbxOFUWWpUysba(m5nGFCzaDagzor(JlMuaGptEduuXeDkpolFCq2DmpolFCnug784qJXCXsdE5dbi3H)v3JtM21lMhBECnug784qJXCH9nIpUysba(m5nGFCzaDagzorE1ApY9ddxmn4GBAVFE7S8zSAfAxVzznLZnmx31NLpt1AD)WWLZnmWlaT8zSA9i3pmCX0GdUP9(5TZYNPQ7hgUycmENEYRazVcU8zQPMhxmPaaFM8gOOIj6uECw(4GS7yECw(YhcQph8Q7Xjt76fZJnpoJGHabtg784qiSqkxfxzvI0gtQVXjPabVGK0aM0DinTfsr3t5X1qzSZJdB3ML1L1cmxJ0P9lFiO(S8v3JtM21lMhBECgbdbcMm25XHqyHuUkUYomPnMuFJtsbcEbjPbmP7qAAlKIUNcP9yiLRIRSkrAGjDhsr6k94AOm25XHTBZY6YAbMlthZlF5JZiW93NV6EiWYxDpozAxVyES5XzemeiyYyNhNdJ9fOFkgsLtbGiPzGkKM2cPnuUasdmP9zh(21lLhxdLXopoC4LbsE5dbi)v3JtM21lMhBECqGifq0po3pmC5Cdd8cqlFgsTALu3pmCHzzjGBmWFCSt5Z84AOm25XXSzSZlFiO(E194KPD9I5XMh3Y84Ws(4AOm25XD2GOD9YJ7S9F5XvlPMnly72SSUSwG5Y0XuYa6Gy4j1QvsZgWlzjdu5M71ecPS1jPifP1qAvsRLuZMLZgLjab0n3pKDjdOdIHNuRwjnBaVKLmqLBUxtiKYwNKYUjTMh3zdUtJkpoZM47N5LpeGuV6ECY0UEX8yZJBzECyjFCnug784oBq0UE5XD2(V84oBq0UEPy2eF)mKwL0Aj1SzXiN7hed)LX38FPKb0bXWtQvRKMnGxYsgOYn3RjeszRtsrksR5XD2G70OYJR9(Rzt89Z8Yhco2RUhNmTRxmp284wMhhwYhxdLXopUZgeTRxECNT)lpomJ493Sb8sIlOXyUyPbKImsroPiHu3pmC5Cdd8cqlFMhNrWqGGjJDECCzdss)4y4jLtAqm8KIGG3orBGqANKwFiH0Sb8sIjDbKIuiH0aMue3pPnqingsp0gg4fG(4oBWDAu5XHLged)DcE7eTbYf6Nlm8lFiGD)Q7Xjt76fZJnpUL5XHL8X1qzSZJ7Sbr76Lh3z7)YJRwspIuWFe4fWlfmJTae81UbO7GyrCOFWWigsRs6rKcTNY0twgbcS(fyi1QvsH21BwwtHzzjGBmWFCStbiODmyszRts5Hmf0M9jLDrA9rQvRK6(HHlmllbCJb(JJDkFgsTALu3fJjTkPWbVDEbcAhdMu26KuKFmsR5XD2G70OYJdYCr7P5fuzYx(qac)v3JtM21lMhBEClZJdl5JRHYyNh3zdI21lpUZ2)LhhMr8(B2aEjXLZgLjab0n3pK9J7Sb3PrLhhAZ(3Ze)Yhco(xDpozAxVyES5XTmpoSKpUgkJDECNniAxV84oB)xEChJuKqkYjLDrATKE2GOD9sbYCr7P5fuzssRsk0UEZYAkNByUc4ZKXofGG2XGjLToj1shqAnKwL0S9YKf7)WlGy4VNBykY0UEX84GarkGOFCz7LjlyPbXWFNG3orBGuKPD9IH0QKIzeV)MnGxsCbngZflnGuNKIWFCNn4onQ84qB2)EM4x(qGd)RUhNmTRxmp284wMhhwYhxdLXopUZgeTRxECNT)lpoh84GarkGOFCz7LjlyPbXWFNG3orBGuKPD9IH0QKIzeV)MnGxsCbngZflnGuKrkc)XD2G70OYJdTz)7zIF5dbw6GxDpozAxVyES5XTmpoSKpUgkJDECNniAxV84oB)xECi1JdcePaI(XLTxMSGLged)DcE7eTbsrM21lgsRskMr8(B2aEjXf0ymxS0asDs6XtAvspI0S9YKfSDBwwxiqJTlY0UEX84oBWDAu5XH2S)9mXV8HalT8v3JtM21lMhBEClZJdl5JRHYyNh3zdI21lpUZ2)LhxTKIzeV)MnGxsCbngZflnGu26K0JrAnKYUifZiE)nBaVK4cAmMlwAWJdcePaI(X5(HHlNByGxaA5Z84oBWDAu5XH2S)9mXV8Halr(RUhNmTRxmp284wMhhwYhxdLXopUZgeTRxECNT)lpoh84mcC)95JZYh3zdUtJkpUaFpZlZIXHRxE5dbwwFV6ECY0UEX8yZJBzECyjFCnug784oBq0UE5XD2(V84S8XbbIuar)4AOmoLRzZYzJYeGa6M7hYMu2skeIqE5kJGgc(XD2G70OYJlW3Z8YSyC46Lx(qGLi1RUhNmTRxmp284wMhhwYhxdLXopUZgeTRxECNT)lpUgkJt5A2SC2OmbiGU5(HSjfzoj9Sbr76LcAZ(3ZetQvRKEePNniAxVuc89mVmlghUE5XD2G70OYJ7mX3MHXhI5Lpey5XE194KPD9I5XMh3Y84Ws(4AOm25XD2GOD9YJ7S9F5XbTR3SSMY5gMRa(mzSt5ZqAvspBq0UEPazUO908cQm5JZiyiqWKXopoKExVzznKE4D9KEOgeTRxSGueclgsZLuMD9K6kWlqiTHY4SZy4j9qByGxaA5XD2G70OYJJzx)fEbxid(Lpeyj7(v3JtM21lMhBECqGifq0po3pmC5Cdd8cqlFMhxdLXopo4aiU(DnV8Halr4V6ECY0UEX8yZJdcePaI(X5(HHlNByGxaA5Z84AOm25X5kaSaoig(x(qGLh)RUhNmTRxmp284AOm25X5dE7eFzh(n8OYKpoJGHabtg784qiSq6Xn4Tt2dtQJFdpQmjPbmPPTaesBGqkYjDbKIUaH0Sb8sITG0fqABmysBGmSxskMPznXWtk8cifDbcPPDpKIWpgU84GarkGOFCygX7Vzd4Lex8bVDIVSd)gEuzssrMtsroPwTsATKEePGomx5uMS0gdUiSFGtmPwTskOdZvoLjlTXGlXqkYifHFmsR5LpeyPd)RUhNmTRxmp284GarkGOFCUFy4Y5gg4fGw(mpUgkJDEC9aj4e0(lu79V8HaK7GxDpozAxVyES5X1qzSZJdQ9(BdLXoxFGZhNpW5DAu5XbXc6LpeGClF194KPD9I5XMhxdLXopoWFUnug7C9boFC(aN3PrLhhAhZlF5JJbiqlQBNV6EiWYxDpozAxVyES5XbbIuar)4acAhdMu2sA95ah84AOm25XXSSeWL1cmx4fKr(nYlFia5V6ECY0UEX8yZJdcePaI(XH3V3ngtH5JZVxUc4ZKXofzAxVyi1QvsX737gJPCU(odVCXR)uMSit76fZJRHYyNhhSxW2qGgoF5db13RUhNmTRxmp284GarkGOFChrQ7hgUGTBZYcEbOLpZJRHYyNhh2Unll4fG(YhcqQxDpozAxVyES5XbbIuar)4Ib3tKiwmcCafjPiJulp2JRHYyNhxdG6rU5caYKV8HGJ9Q7Xjt76fZJnpUPrLhh2UnllXCxG7DHV5cqLjFCnug784W2TzzjM7cCVl8nxaQm5lFiGD)Q7Xjt76fZJnpUL5XHL8X1qzSZJ7Sbr76Lh3z7)YJd5pUZgCNgvECOXyUyPbxOFUWWV8Hae(RUhNmTRxmp284GarkGOFChrA2EzYIPrNoJDkY0UEX84AOm25XD2OmbiGU5(HSF5dbh)RUhNmTRxmp284GarkGOFCz7LjlMgD6m2Pit76fZJRHYyNhhAmMRRVX5lF5JdYGF19qGLV6ECY0UEX8yZJRHYyNhhZYsa3yG)4yNhNrWqGGjJDECiewi9WllbqAfDG)4yhszfPnPhAdd8cqlKECSEdPWlG0dTHbEbOKcTOcM0fgMuOD9ML1qAmKM2cPJW(jPw6asXc0ogmPBAlawbwi9Jfs3HuidP)XlymPPTqkJVruaKgyszAqs6ctAAlKEaIGOhsH2tz6jTG0fqAatAAlaHuwH3t6SjPUcP9SPTai9qByi1Hb(mzSdPPDGjfo4TZcPvEMcktsAUKIrCGinTfs9nojLzzjasJb(JJDiDHjnTfsHdE7K0Cj9CddPc4ZKXoKcVasNDiLDmIGOhC5XbbIuar)4yaHGZcw8WxMLLaUXa)XXoKwL0Aj19ddxo3WaVa0YNHuRwj9isH2tz6jlhGii6H0QKEePq7Pm9KLrGaRFbgsRsk0UEZYAkNByUc4ZKXofGG2XGjfzoj1shqQvRKch825fiODmyszlPq76nlRPCUH5kGptg7uacAhdM0AiTkP1skCWBNxGG2XGjfzojfAxVzznLZnmxb8zYyNcqq7yWKIesT8yKwLuOD9ML1uo3WCfWNjJDkabTJbtkBDskpKHu2fPifPwTskCWBNxGG2XGjfzKcTR3SSMcZYsa3yG)4yNI5d6m2HuRwj1DXysRskCWBNxGG2XGjLTKcTR3SSMY5gMRa(mzStbiODmysrcPwEmsTALuO9uMEYYbicIEi1QvsD)WWfx)Ug)hNLpdP18Yhcq(RUhNmTRxmp284mcgcemzSZJdHWcPSPn8cPXGdJq6ct6HqyKcVastBHu4aGts)yH0fq6oKI0vI0gofaPPTqkCaWjPFSuiTIJ0Muee82jPiSwi1E9gsHxaPhcHvECtJkpoCmWF)L33MOZfGVUTHxUl8fwaluKi(4GarkGOFCUFy4Y5gg4fGw(mKA1kPzGkKImsT0bKwL0Aj9isH2tz6jltWBNx4wiTMhxdLXopoCmWF)L33MOZfGVUTHxUl8fwaluKi(YhcQVxDpozAxVyES5X1qzSZJdULl)VbMOh8JZiyiqWKXopoeclKIWAHu25Fdmrpys3HuKUsKU)ehgH0fM0dTHbEbOfsriSqkcRfszN)nWe9yWKgdPhAdd8cqjnGjfX9tQDFkKkrAlaszNb7PqAfDod(f0zSdPlGuewiEdPlmPSXVy8IIlKwXDKKcVasnBIjnxsDfs)mK6kWlqiTHY4SZy4jfH1cPSZ)gyIEWKMlPOn7hObwinTfsD)WWLhheisbe9J7isD)WWLZnmWlaT8ziTkP1s6rKcTR3SSMY5gMBUaGmz5ZqQvRKEePz7LjlNByU5caYKfzAxVyiTgsRsATKE2GOD9sXSj((ziTkPygX7Vzd4LexoBuMaeq3C)q2K6Kulj1QvspBq0UEPCM4BZW4dXqAvsXmI3FZgWljUC2OmbiGU5(HSjfzKAjP1qQvRK6(HHlNByGxaA5ZqAvsRLu8(9UXyk8G9uUXCg8lOZyNImTRxmKA1kP497DJXuGdXBUl811Vy8IIlY0UEXqAnV8HaK6v3JtM21lMhBECnug784qJXW3Oc(XbHiKxUzd4Le)qGLpoiqKci6hxm4EIerszlPo8oG0QKwlP1s6zdI21lL27VMnX3pdPvjTwspIuOD9ML1uo3WCfWNjJDkFgsTAL0JinBVmzX(p8cig(75gMImTRxmKwdP1qQvRK6(HHlNByGxaA5ZqAnKwL0Aj9isZ2ltwS)dVaIH)EUHPit76fdPwTsQrC)WWf7)WlGy4VNBykabTJbtkYifQX5nduHuRwj9isD)WWLZnmWlaT8ziTgsRsATKEePz7LjlyPbXWFNG3orBGuKPD9IHuRwjfZiE)nBaVK4cAmMlwAaPSL0JrAnpoJGHabtg784qiSqA9hJHVrfmPSSLH027jT(iTsBDysBGq6NXcsxaPiUFsBGqAmKEOnmWlaTqQdBWFGq6XXF4fqm8KEOnmKYk8EsXz49K6kK(ziLLTmKM2cPqnojnduHu4ycSTGlKYLldPFCm8K2jPhdjKMnGxsmPSI0MuoPbXWtkccE7eTbs5LpeCSxDpozAxVyES5X1qzSZJ7p2RhX7SN9JZiyiqWKXopoeclKIqJ96rKueSNnP7qksxjli1E9My4j1fecShrsZLuwDKKcVaszwwcG0yG)4yhsxaPTXqkMPzn4YJdcePaI(XDePz7Ljl2)HxaXWFp3WuKPD9IH0QKE2GOD9sXSj((zi1QvsnI7hgUy)hEbed)9Cdt5ZqAvsD)WWLZnmWlaT8zi1QvsRLuOD9ML1uo3WCfWNjJDkabTJbtkYi1shqQvRKEePNniAxVuy21FHxWfYGjTgsRs6rK6(HHlNByGxaA5Z8Yhcy3V6ECY0UEX8yZJRHYyNhN7UZDHVPTCBmKmgX84mcgcemzSZJdHWcP7qksxjsD)jPmGybrgyH0pogEsp0ggsDyGptg7qkCaWPfKgWK(XIH0yWHriDHj9qims3HuU6i9JfsB4uaK2KEUHXD9jPWlGuOD9ML1qQadhqHmqisApgsHxaP2)HxaXWt65ggs)mzGkKgWKMTxMumLhheisbe9J7isD)WWLZnmWlaT8ziTkPhrk0UEZYAkNByUc4ZKXoLpdPvjfZiE)nBaVK4cAmMlwAaPiJuljTkPhrA2EzYcwAqm83j4Tt0gifzAxVyi1QvsRLu3pmC5Cdd8cqlFgsRskMr8(B2aEjXf0ymxS0aszlPiN0QKEePz7LjlyPbXWFNG3orBGuKPD9IH0QKwlPma58Ydzkwwo3WCDxFsAvsRL0JivCOFWWiMIGYGiqA)DbMPhiHuRwj9isZ2ltwS)dVaIH)EUHPit76fdP1qQvRKko0pyyetrqzqeiT)UaZ0dKqAvsH21BwwtrqzqeiT)UaZ0dKuacAhdMu26Kulz3iN0QKAe3pmCX(p8cig(75gMYNH0AiTgsTAL0Aj19ddxo3WaVa0YNH0QKMTxMSGLged)DcE7eTbsrM21lgsR5LpeGWF194KPD9I5XMhxdLXopoO27Vnug7C9boFC(aN3PrLhxcI5ajXV8HGJ)v3JtM21lMhBECqGifq0poBP9PDHbkjLTojfHFShxdLXopoJGzeqNYLb0ikGx(YhxcI5ajXV6EiWYxDpozAxVyES5XzemeiyYyNhhcHfs3HuKUsKw5Cv(Hjnxs5LK0kT1rAgqhedpP9yivyFMaiKMlP(yes)mK6kzkaszfPnPhAdd8cqFCtJkpobLbrG0(7cmtpqYJdcePaI(XbTR3SSMY5gMRa(mzStbiODmyszRtsTe5KA1kPq76nlRPCUH5kGptg7uacAhdMuKrkYr4pUgkJDECckdIaP93fyMEGKx(qaYF194KPD9I5XMhNrWqGGjJDEC1bqK0CjLdXbI0k6X5krkRiTjTs731lKYLn0bIHuKUsysdyszwmoC9sH0kYqQFhEbqkCWBNyszfPnPOlqiTIECUsK(XcM0otbLjjnxsXioqKYksBs7brsHmKUaszh(XjPFSqAKLh30OYJlgme4NTRxUo0VN8JEnYzajpoiqKci6hN7hgUCUHbEbOLpdPvj19ddxywwc4gd8hh7u(mKA1kPUlgtAvsHdE78ce0ogmPS1jPi3bKA1kPUFy4cZYsa3yG)4yNYNH0QKcTR3SSMY5gMRa(mzStbiODmysrcPwEmsrgPWbVDEbcAhdMuRwj19ddxo3WaVa0YNH0QKcTR3SSMcZYsa3yG)4yNcqq7yWKIesT8yKImsHdE78ce0ogmPwTsATKcTR3SSMcZYsa3yG)4yNcqq7yWKImNKAPdiTkPq76nlRPCUH5kGptg7uacAhdMuK5KulDaP1qAvsHdE78ce0ogmPiZjPw6W7GhxdLXopUyWqGF2UE56q)EYp61iNbK8YhcQVxDpozAxVyES5XzemeiyYyNhhhIdePC2IKKw)FCarkRiTj9qByGxa6JBAu5XH2qTlqUyBrYl6hhqpoiqKci6hh0UEZYAkNByUc4ZKXofGG2XGjfzKAPdECnug784qBO2fixSTi5f9JdOx(qas9Q7Xjt76fZJnpUPrLhhE)EVKzm8xW3fXhheIqE5MnGxs8dbw(4AOm25XH3V3lzgd)f8Dr8XbbIuar)4C)WWfMLLaUXa)XXoLpdPwTs6rKYacbNfS4HVmllbCJb(JJDi1Qvsfh6hmmIPGTBZYsm3f4Ex4BUauzYhNrWqGGjJDECCioqKYo9DrKuwrAt6HxwcG0k6a)XXoK(XnVybPO9bcP4pqinxsXtWiKM2cP(LLGtspoomPzd4LSqAfBldPFSyiLvK2KYz3MLLyiTIaCjDHjTUfGktAbPSd)4K0pwiDhsr6krAJjf9dztAJjLzX4W1lLx(qWXE194KPD9I5XMhNrWqGGjJDECiSaGts5c(WtkgT9EsxMmqd2r6m2HuwrAtk3(9EjZy4jLD67I4JBAu5XL2Yfoa48Id(W)4GarkGOFCUFy4Y5gg4fGw(mKA1kPUFy4cZYsa3yG)4yNYNHuRwj9iszaHGZcw8WxMLLaUXa)XXoKA1kPq76nlRPCUH5kGptg7uacAhdMuKrQLoGuRwjTwsfh6hmmIPG3V3lzgd)f8DrK0QKEePq76nlRPG3V3lzgd)f8DrS8ziTgsTALu3fJjTkPWbVDEbcAhdMu2skYDWJRHYyNhxAlx4aGZlo4d)lFiGD)Q7Xjt76fZJnpoJGHabtg784qiSqkBAdVqAm4WiKUWKEiegPWlG00wifoa4K0pwiDbKUdPiDLiTHtbqAAlKchaCs6hlfs5SxqskuaG(rsAat65ggsfWNjJDifAxVzznKgysT0bysxaPOlqiTz1iwECtJkpoCmWF)L33MOZfGVUTHxUl8fwaluKi(4GarkGOFCq76nlRPCUH5kGptg7uacAhdMuK5KulDWJRHYyNhhog4V)Y7Bt05cWx32Wl3f(clGfkseF5dbi8xDpozAxVyES5XzemeiyYyNhhcHfs5SBZYsmKwraUKUWKw3cqLjjLLTmKoBsAmKEOnmWla1csxaPXqQRKSezi9qByiLnRpjfQXjM0yi9qByGxaAH0khtk7yebrpKUasrGabw)cmK6Jrinss)mKYksBsXzdDGyifAxVzzn4YJBAu5XHTBZYsm3f4Ex4BUauzYhheisbe9JdAxVzznfMLLaUXa)XXofGG2XGjLToj1shqAvsH21Bwwt5CdZvaFMm2Pae0ogmPS1jPw6asRsATKcTNY0twgbcS(fyi1QvsH2tz6jlhGii6H0Ai1QvsRLuO9uMEYYPmPnIasTALuO9uMEYYe825fUfsRH0QKwlPhrQ7hgUCUHbEbOLpdPwTskdqoV8qMILLZnmx31NKwdPwTsQ7IXKwLu4G3oVabTJbtkBDsks5GhxdLXopoSDBwwI5Ua37cFZfGkt(Yhco(xDpozAxVyES5X1qzSZJRbq2rkqj(gdVm)ir8cTa5XzemeiyYyNhhcHfst7at6oKI0vIu4fqkAZ(KI0vID6XnnQ84AaKDKcuIVXWlZpseVqlqE5dbo8V6ECY0UEX8yZJZiyiqWKXopoeclKMGyoqssB4uaKY89EsXzdsmP9yinTLH0DifPRePnCkast7oj9pz4jfX9tkVKKIuPnP4SHoOqADaejnxsnIVrKuEjZy4j9yPnP4SHoGu4fqk0UEZYAWLh30OYJdd1a8DHVWGofW0(lobbS84GarkGOFC1s6rK6(HHlyOgGVl8fg0PaM2FXjiGLlsv(mKwL0mqfsrgPwsAnKA1kP1sQ7hgUCUHbEbOLpdPwTsQ7hgUWSSeWng4po2P8zi1QvsH21Bwwt5CdZvaFMm2Pae0ogmPiJulDaP1qQvRKcTNY0twMG3oVWT84AOm25XHHAa(UWxyqNcyA)fNGawE5dbw6GxDpozAxVyES5X1qzSZJ7JLBKck(XzemeiyYyNhxLe4(7tsHBV3THoGu4fq6h3UEH0ifuCLrkcHfs3HuOD9ML1qAmKUaJai1frstqmhijPy)MLhheisbe9JZ9ddxo3WaVa0YNHuRwj19ddxywwc4gd8hh7u(mKA1kPq76nlRPCUH5kGptg7uacAhdMuKrQLo4LV8X5U78Q7HalF194KPD9I5XMhheisbe9JdZiE)nBaVK4cAmMlwAaPS1jP13JRHYyNhxJHKXiMRRVX5lFia5V6ECY0UEX8yZJRHYyNhxJHKXiM7SN9JZiyiqWKXopUkY4rK0pwiTYXqYyedPiypBszzldPZMKMTxMumKgtUKYjnigEsrqWBNOnqiDhsrosinBaVK4YJdcePaI(XHzeV)MnGxsCPXqYyeZD2ZMuKrQLKwLumJ493Sb8sIlOXyUyPbKImsTK0QKEePz7LjlyPbXWFNG3orBGuKPD9I5LV8XbXc6v3dbw(Q7Xjt76fZJnpoiqKci6hhwYR7oFCjdbG8J)IumqKwLu3pmCX0GdUP9(5TZYNH0QKYizboKXuAOmofsRsk4pc8c4Lc2UnllyFJkxgqGrlId9dggXqAvspIu3pmC5Cdd8cqlFgsRskJKfe3p4ITBZYQae0ogmPSLu4G3oVabTJbtQvRK6(HHlMgCWnT3pVDw(mKwLugjliUFWfB3MLvbiODmyszlP8qMcAZ(KYUiTwsRpsrcP1s6rK6(HHlNByGxaA5ZqAnKYUi1s2nP1qAvszKSG4(bxSDBwwfGG2XGjLTKch825fiODm4h3oEeVqSGECw(4mcgcemzSZJRoKF8KIuoCyjjfAhtKXoTNu4fqksxXinP1FmgszJVX5JRHYyNhhAmMRRVX5lFia5V6ECY0UEX8yZJ7JLll7WlxOgNXW)qGLpUgkJDECyPbXWFNG3orBG84GqeYl3Sb8sIFiWYhheisbe9JRwspBq0UEPGLged)DcE7eTbYf6NlmmPvj9ispBq0UEPWSR)cVGlKbtAnKA1kP1sQzZc2UnlRlRfyUmDmfGadeSD76fsRskMr8(B2aEjXf0ymxS0asrgPwsAnpoJGHabtg784qiSqkN0Gy4jfbbVDI2aH0aMue3pPScVNu7ijvM9ZBtA2aEjXK2JH0dVSeaPv0b(JJDiThdPhAdd8cqjTbcPZMKcK2GOfKUasZLuGadeSnPCvCLDys3H0K1s6cifDbcPzd4LexE5db13RUhNmTRxmp284(y5YYo8YfQXzm8pey5JRHYyNhhwAqm83j4Tt0gipoieH8YnBaVK4hcS8XbbIuar)4Y2ltwWsdIH)obVDI2aPit76fdPvj1SzbB3ML1L1cmxMoMcqGbc2UD9cPvjfZiE)nBaVK4cAmMlwAaPiJuK)4mcgcemzSZJJZEbjPiDaG(rskN0Gy4jfbbVDI2aHuODmrg7qAUKEGimKYvXv2Hj9ZqAmKw5Rd7LpeGuV6ECY0UEX8yZJBhpIxiwqpolFCnug784qJXCD9noFCgbdbcMm25XTJhXlelisr7demPPTqAdLXoKUJhrs)421lKA(Gy4jfYUNr8XWtApgsNnjTXK2Kce(VVbK2qzSt5LV8LpUtbGJDEia5oa5wAjYrocVy5JJvdMy4XpUkUYzNqqffbSZvgPKwNTqAGYSGKu4fqk7LGyoqsm7rkqCOFaedP4fviT)5I2PyifYUhEbxihpUXiKESkJuKENtbKIHu2lbXCGKL2fQaTR3SSg2J0CjL9G21BwwtPDHypsR1s2VMc5i5yfx5StiOIIa25kJusRZwinqzwqsk8ciL9yac0I62j7rkqCOFaedP4fviT)5I2PyifYUhEbxihpUXiKI8kJuKENtbKIHu2dVFVBmMc7a2J0CjL9W737gJPWoOit76fd7rATwY(1uihpUXiKI8kJuKENtbKIHu2dVFVBmMc7a2J0CjL9W737gJPWoOit76fd7rANK6WQihxsR1s2VMc5i5yfx5StiOIIa25kJusRZwinqzwqsk8ciL9q7yypsbId9dGyifVOcP9px0ofdPq29Wl4c54XngH06RYifP35uaPyiL9W737gJPWoG9inxszp8(9UXykSdkY0UEXWEKwRLSFnfYXJBmcPihHxzKI07CkGumKYE497DJXuyhWEKMlPShE)E3ymf2bfzAxVyypsR1s2VMc5i5yfx5StiOIIa25kJusRZwinqzwqsk8ciL9Gmy2JuG4q)aigsXlQqA)ZfTtXqkKDp8cUqoECJriLDxzKI07CkGumKYEjiMdKS0UqfOD9ML1WEKMlPSh0UEZYAkTle7rATwY(1uihjhROOmlifdPiCsBOm2HuFGtCHC8XHzeOhcq(Xo(hhdyHdV84Qx9iLZUnllspmieCsowV6rA93aiBsT0csrUdqoYjhjhRx9ifPT7HxWvg5y9QhPoCKwhlPpG0dTHH06waqMKuw2YqA2aEjjfA)tIjTbcPWlasmfYX6vpsD4i9WajLXqQztmPnqi9ZqklBzinBaVKysBGqkKFXcP5sQbXy4TGu8sAA3jPZ)abtAdesXz49KceOffvgJykKJKJ1REK6WyFb6NIHuxbEbcPqlQBNK6k8XGlKw5qqctIjD2XHZUbOWFpPnug7GjDhpIfYXgkJDWfgGaTOUDIeNvGzzjGlRfyUWliJ8BelcyNabTJbZ26ZboGCSHYyhCHbiqlQBNiXzfG9c2gc0WPfbSt8(9UXykmFC(9YvaFMm2XQv8(9UXykNRVZWlx86pLjjhBOm2bxyac0I62jsCwbSDBwwWla1Ia25rUFy4c2Unll4fGw(mKJnug7GlmabArD7ejoRqdG6rU5caYKweWoJb3tKiwmcCafjYS8yKJnug7GlmabArD7ejoRWhl3ifulMgvCITBZYsm3f4Ex4BUauzsYXgkJDWfgGaTOUDIeNv4Sbr76flMgvCIgJ5ILgCH(5cdBXY4elPfNT)loro5ydLXo4cdqGwu3orIZkC2OmbiGU5(HSTiGDEu2EzYIPrNoJDkY0UEXqo2qzSdUWaeOf1TtK4ScOXyUU(gNweWoZ2ltwmn60zStrM21lgYrYX6rQdJ9fOFkgsLtbGiPzGkKM2cPnuUasdmP9zh(21lfYXgkJDWoXHxgiHCSE1J0dVzSdMCSHYyhStMnJDSiGD6(HHlNByGxaA5Zy1Q7hgUWSSeWng4po2P8zihBOm2bJeNv4Sbr76flMgvCA2eF)mwSmoXsAXz7)IZAnBwW2TzzDzTaZLPJPKb0bXWB1A2aEjlzGk3CVMqyRtKQMQ1A2SC2OmbiGU5(HSlzaDqm8wTMnGxYsgOYn3Rje26KDxd5ydLXoyK4ScNniAxVyX0OIZ27VMnX3pJflJtSKwC2(V48Sbr76LIzt89ZuTwZMfJCUFqm8xgFZ)LsgqhedVvRzd4LSKbQCZ9AcHTorQAihRhPCzdss)4y4jLtAqm8KIGG3orBGqANKwFiH0Sb8sIjDbKIuiH0aMue3pPnqingsp0gg4fGso2qzSdgjoRWzdI21lwmnQ4elnig(7e82jAdKl0pxyylwgNyjT4S9FXjMr8(B2aEjXf0ymxS0aKHCK4(HHlNByGxaA5Zqo2qzSdgjoRWzdI21lwmnQ4eYCr7P5fuzslwgNyjT4S9FXzThb(JaVaEPGzSfGGV2naDhelId9dggXu9iO9uMEYYiqG1VaJvRq76nlRPWSSeWng4po2Pae0ogmBDYdzkOn7ZUQpRwD)WWfMLLaUXa)XXoLpJvRUlgxfo4TZlqq7yWS1jYpwnKJnug7GrIZkC2GOD9IftJkorB2)EMylwgNyjT4S9FXjMr8(B2aEjXLZgLjab0n3pKn5ydLXoyK4ScNniAxVyX0OIt0M9VNj2ILXjwsloB)xCEmKGC2vTNniAxVuGmx0EAEbvMSk0UEZYAkNByUc4ZKXofGG2XGzRtlDqnvZ2ltwS)dVaIH)EUHPit76fJfbSZS9YKfS0Gy4VtWBNOnqkY0UEXufZiE)nBaVK4cAmMlwAGteo5ydLXoyK4ScNniAxVyX0OIt0M9VNj2ILXjwsloB)xC6alcyNz7LjlyPbXWFNG3orBGuKPD9IPkMr8(B2aEjXf0ymxS0aKHWjhBOm2bJeNv4Sbr76flMgvCI2S)9mXwSmoXsAXz7)ItKYIa2z2EzYcwAqm83j4Tt0gifzAxVyQIzeV)MnGxsCbngZflnW5Xx9OS9YKfSDBwwxiqJTlY0UEXqo2qzSdgjoRWzdI21lwmnQ4eTz)7zITyzCIL0IZ2)fN1IzeV)MnGxsCbngZflnGTopwnSlmJ493Sb8sIlOXyUyPbweWoD)WWLZnmWlaT8zihBOm2bJeNv4Sbr76flMgvCg47zEzwmoC9IflJtSKwC2(V40bwye4(7tNwso2qzSdgjoRWzdI21lwmnQ4mW3Z8YSyC46flwgNyjT4S9FXPLweWoBOmoLRzZYzJYeGa6M7hYMTqic5LRmcAiyYXgkJDWiXzfoBq0UEXIPrfNNj(2mm(qmwSmoXsAXz7)IZgkJt5A2SC2OmbiGU5(HSrMZZgeTRxkOn7FptSvRhD2GOD9sjW3Z8YSyC46fYX6rksVR3SSgsp8UEspudI21lwqkcHfdP5skZUEsDf4fiK2qzC2zm8KEOnmWlaTqo2qzSdgjoRWzdI21lwmnQ4Kzx)fEbxid2ILXjwsloB)xCcTR3SSMY5gMRa(mzSt5Zu9Sbr76LcK5I2tZlOYKKJnug7GrIZkahaX1VRXIa2P7hgUCUHbEbOLpd5ydLXoyK4ScUcalGdIH3Ia2P7hgUCUHbEbOLpd5y9ifHWcPh3G3ozpmPo(n8OYKKgWKM2cqiTbcPiN0fqk6cesZgWlj2csxaPTXGjTbYWEjPyMM1edpPWlGu0fiKM29qkc)y4c5ydLXoyK4Sc(G3oXx2HFdpQmPfbStmJ493Sb8sIl(G3oXx2HFdpQmjYCICRwR9iqhMRCktwAJbxe2pWj2QvqhMRCktwAJbxIbzi8Jvd5ydLXoyK4Sc9aj4e0(lu79weWoD)WWLZnmWlaT8zihBOm2bJeNvaQ9(BdLXoxFGtlMgvCcXcICSHYyhmsCwbWFUnug7C9boTyAuXjAhd5i5y9QhPv(HpUKMlPFSqklBziLn7oKUWKM2cPvogsgJyinWK2qzCkKJnug7GlU7ooBmKmgXCD9noTiGDIzeV)MnGxsCbngZflnGToRpYX6rAfz8is6hlKw5yizmIHueSNnPSSLH0ztsZ2ltkgsJjxs5KgedpPii4Tt0giKUdPihjKMnGxsCHCSHYyhCXD3bjoRqJHKXiM7SNTfbStmJ493Sb8sIlngsgJyUZE2iZYQygX7Vzd4LexqJXCXsdqMLvpkBVmzblnig(7e82jAdKImTRxmKJKJ1REKI0vctowpsriSq6HxwcG0k6a)XXoKYksBsp0gg4fGwi94y9gsHxaPhAdd8cqjfArfmPlmmPq76nlRH0yinTfshH9tsT0bKIfODmys30waScSq6hlKUdPqgs)JxWystBHugFJOainWKY0GK0fM00wi9aebrpKcTNY0tAbPlG0aM00wacPScVN0ztsDfs7ztBbq6H2WqQdd8zYyhst7atkCWBNfsR8mfuMK0CjfJ4arAAlK6BCskZYsaKgd8hh7q6ctAAlKch82jP5s65ggsfWNjJDifEbKo7qk7yebrp4c5ydLXo4cKb7KzzjGBmWFCSJfbStgqi4SGfp8LzzjGBmWFCSt1AD)WWLZnmWlaT8zSA9iO9uMEYYbicIEQEe0EktpzzeiW6xGPk0UEZYAkNByUc4ZKXofGG2XGrMtlDGvRWbVDEbcAhdMTq76nlRPCUH5kGptg7uacAhdUMQ1ch825fiODmyK5eAxVzznLZnmxb8zYyNcqq7yWiXYJvfAxVzznLZnmxb8zYyNcqq7yWS1jpKHDHuwTch825fiODmyKbTR3SSMcZYsa3yG)4yNI5d6m2XQv3fJRch825fiODmy2cTR3SSMY5gMRa(mzStbiODmyKy5XSAfApLPNSCaIGOhRwD)WWfx)Ug)hNLptnKJ1JueclKYfEzGes3HuKUsKMlPmGfIuoHX(Zoc7Hj9WGfY3ODg7uihRhPnug7GlqgmsCwbC4LbsSiBaVK3a2j4pc8c4LcwyS)SJGVmGfY3ODg7ueh6hmmIPATzd4LSe4BBmwTMnGxYIrC)WWfOgNXWxasdL1qowpsriSqkBAdVqAm4WiKUWKEiegPWlG00wifoa4K0pwiDbKUdPiDLiTHtbqAAlKchaCs6hlfsR4iTjfbbVDskcRfsTxVHu4fq6HqyfYXgkJDWfidgjoRWhl3ifulMgvCIJb(7V8(2eDUa81Tn8YDHVWcyHIerlcyNUFy4Y5gg4fGw(mwTMbQGmlDq1ApcApLPNSmbVDEHBPgYX6rkcHfsryTqk78VbMOhmP7qksxjs3FIdJq6ct6H2WaVa0cPiewifH1cPSZ)gyIEmysJH0dTHbEbOKgWKI4(j1UpfsLiTfaPSZG9uiTIoNb)c6m2H0fqkcleVH0fMu24xmErXfsR4ossHxaPMnXKMlPUcPFgsDf4fiK2qzC2zm8KIWAHu25FdmrpysZLu0M9d0alKM2cPUFy4c5ydLXo4cKbJeNvaULl)VbMOhSfbSZJC)WWLZnmWlaT8zQw7rq76nlRPCUH5Mlaitw(mwTEu2EzYY5gMBUaGmzrM21lMAQw7zdI21lfZM47NPkMr8(B2aEjXLZgLjab0n3pKTtlTA9Sbr76LYzIVndJpetvmJ493Sb8sIlNnktacOBUFiBKzznwT6(HHlNByGxaA5ZuTw8(9UXyk8G9uUXCg8lOZyNImTRxmwTI3V3ngtboeV5UWxx)IXlkUit76ftnKJ1JueclKw)Xy4BubtklBziT9EsRpsR0whM0giK(zSG0fqkI7N0giKgdPhAdd8cqlK6Wg8hiKEC8hEbedpPhAddPScVNuCgEpPUcPFgszzldPPTqkuJtsZavifoMaBl4cPC5Yq6hhdpPDs6XqcPzd4LetkRiTjLtAqm8KIGG3orBGuihBOm2bxGmyK4ScOXy4BubBbeIqE5MnGxsStlTiGDgdUNirKTo8oOAT1E2GOD9sP9(Rzt89ZuT2JG21Bwwt5CdZvaFMm2P8zSA9OS9YKf7)WlGy4VNBykY0UEXutnwT6(HHlNByGxaA5Zut1ApkBVmzX(p8cig(75gMImTRxmwTAe3pmCX(p8cig(75gMcqq7yWidQX5nduXQ1JC)WWLZnmWlaT8zQPAThLTxMSGLged)DcE7eTbsrM21lgRwXmI3FZgWljUGgJ5ILgW2Jvd5y9ifHWcPi0yVEejfb7zt6oKI0vYcsTxVjgEsDbHa7rK0CjLvhjPWlGuMLLaing4po2H0fqABmKIzAwdUqo2qzSdUazWiXzf(J96r8o7zBra78OS9YKf7)WlGy4VNBykY0UEXu9Sbr76LIzt89Zy1QrC)WWf7)WlGy4VNBykFMQUFy4Y5gg4fGw(mwTwl0UEZYAkNByUc4ZKXofGG2XGrMLoWQ1JoBq0UEPWSR)cVGlKbxt1JC)WWLZnmWlaT8zihRhPiewiDhsr6krQ7pjLbeliYalK(XXWt6H2WqQdd8zYyhsHdaoTG0aM0pwmKgdomcPlmPhcHr6oKYvhPFSqAdNcG0M0ZnmURpjfEbKcTR3SSgsfy4akKbcrs7Xqk8ci1(p8cigEsp3Wq6NjduH0aM0S9YKIPqo2qzSdUazWiXzfC3DUl8nTLBJHKXiglcyNh5(HHlNByGxaA5Zu9iOD9ML1uo3WCfWNjJDkFMQygX7Vzd4LexqJXCXsdqMLvpkBVmzblnig(7e82jAdKImTRxmwTwR7hgUCUHbEbOLptvmJ493Sb8sIlOXyUyPbSf5vpkBVmzblnig(7e82jAdKImTRxmvRLbiNxEitXYY5gMR76ZQ1EK4q)GHrmfbLbrG0(7cmtpqIvRhLTxMSy)hEbed)9CdtrM21lMASAvCOFWWiMIGYGiqA)DbMPhiPAcI5ajlckdIaP93fyMEGKc0UEZYAkabTJbZwNwYUrEvJ4(HHl2)HxaXWFp3Wu(m1uJvR16(HHlNByGxaA5ZunBVmzblnig(7e82jAdKImTRxm1qo2qzSdUazWiXzfGAV)2qzSZ1h40IPrfNjiMdKeto2qzSdUazWiXzfmcMraDkxgqJOaSiGDAlTpTlmqjBDIWpg5i5y9QhPiDJtsRy7WlKI0noJHN0gkJDWfs5KK0oj1o4TfaPmGybrIiP5sk2EbjPqba6hjPXKca8zssH2XezSdM0DiT(JXqkN0GkGW8nIKJ1J06q(Xtks5WHLKuODmrg70EsHxaPiDfJ0Kw)XyiLn(gNKJnug7GlqSGCIgJ566BCAXoEeVqSGCAPfzd4L8gWoXsED35JlziaKF8xKIbQQ7hgUyAWb30E)82z5ZuLrYcCiJP0qzCkvb)rGxaVuW2Tzzb7Bu5YacmArCOFWWiMQh5(HHlNByGxaA5ZuLrYcI7hCX2TzzvacAhdMTWbVDEbcAhd2Qv3pmCX0GdUP9(5TZYNPkJKfe3p4ITBZYQae0ogmB5Hmf0M9zx1wFiP2JC)WWLZnmWlaT8zQHDzj7UMQmswqC)Gl2UnlRcqq7yWSfo4TZlqq7yWKJ1JueclKYjnigEsrqWBNOnqinGjfX9tkRW7j1ossLz)82KMnGxsmP9yi9WllbqAfDG)4yhs7Xq6H2WaVausBGq6SjPaPniAbPlG0CjfiWabBtkxfxzhM0DinzTKUasrxGqA2aEjXfYXgkJDWfiwqoXsdIH)obVDI2aXIpwUSSdVCHACgdVtlTacriVCZgWlj2PLweWoR9Sbr76LcwAqm83j4Tt0gixOFUWWvp6Sbr76LcZU(l8cUqgCnwTwRzZc2UnlRlRfyUmDmfGadeSD76LQygX7Vzd4LexqJXCXsdqML1qowps5SxqskshaOFKKYjnigEsrqWBNOnqifAhtKXoKMlPhicdPCvCLDys)mKgdPv(6WihBOm2bxGybHeNvalnig(7e82jAdel(y5YYo8YfQXzm8oT0cieH8YnBaVKyNwAra7mBVmzblnig(7e82jAdKImTRxmvnBwW2TzzDzTaZLPJPaeyGGTBxVufZiE)nBaVK4cAmMlwAaYqo5y9iDhpIxiwqKI2hiystBH0gkJDiDhpIK(XTRxi18bXWtkKDpJ4JHN0EmKoBsAJjTjfi8FFdiTHYyNc5ydLXo4celiK4ScOXyUU(gNwSJhXleliNwsosowV6rA93XqALF4JRfKIT3V3qk0EkasBVNuqp8cM0fM0Sb8sIjThdPyizAqSyYXgkJDWf0ogNqT3FBOm256dCAX0OIt3DhlWjiGsNwAra709ddxC3DUl8nTLBJHKXiMYNHCSHYyhCbTJbjoRGjWmI)I28bKfbSZJYgWlzjWxgFJOaihRhPiewi9qByi1Hb(mzSdP7qk0UEZYAiLzxFm8K2jPEPXjPi)yKgdUNirK0AxaPiLdifEbKYg)UgsDyEys3H0LrgbudPU)K0ztsdysrC)KYk8Es3tba1mKgdUNirK0yi9qiScP1FFGqk(des5SBZYcoKXuH6pgJRmgbqApgsR)ymKYgFJtsdmP7qk0UEZYAi1vGxGq6HCyKgWKYz3MLfSVrfsdmPId9dggXuiTIYplqiLzxFm8KceCccOm2btAat6hhdpPC2Tzzb7BuH0ddcmkP9yiLnYyeaPbM09NfYXgkJDWf0ogK4ScNByUc4ZKXoweWopBq0UEPWSR)cVGlKbxT2yW9ejIiZjYpgsQ1YJXUQf0qsX1VR5kE4QzGkST(Cqn1y1kJKf4qgtPHY4uQc(JaVaEPGTBZYc23OYLbey0I4q)GHrmvpcAxVzznf0ymxxFJZYNP6rq76nlRPGTBZY6YAbMRr60U8zQPATXG7jsezRZJ)ywTMTxMSGLged)DcE7eTbsrM21lMQNniAxVuWsdIH)obVDI2a5c9ZfgUMQhbTR3SSMcCiJP8zQw7r497DJXuoxFNHxU41FktA1Q7hgUCU(odVCXR)uMS8zSAflzgdpUe8ZcKlE9NYK1qowpsR)(aHu8hiKI4(jL5NK(ziLRIRSdtALZv5hM0DinTfsZgWljPbmPvmOtB4VNuewlGqinWd7LK2qzCkKYYwgsHdE7mgEsT0HR(inBaVK4c5ydLXo4cAhdsCwbSDBwwxwlWCz6ySiGD6(HHlWTC5)nWe9GlFMQhze3pmCHfOtB4V)c3ciKYNPkMr8(B2aEjXf0ymxS0a2IuKJnug7GlODmiXzfqJXCXsdSacriVCZgWlj2PLweWoZ2ltwWsdIH)obVDI2aPit76ftvmJ493Sb8sIlOXyUyPbi7Sbr76LcAmMlwAWf6NlmC1JmBwW2TzzDzTaZLPJPKb0bXWx9iOD9ML1uGdzmLptvmJ493Sb8sIlOXyUyPbiZjsro2qzSdUG2XGeNvaQ9(BdLXoxFGtlMgvCczWKJ1J0JJG3M0ddIfejIKw)XyiLtAaPnug7qAUKceyGGTjTsBDyszfPnPyPbXWFNG3orBGqo2qzSdUG2XGeNvangZflnWcieH8YnBaVKyNwAra7mBVmzblnig(7e82jAdKImTRxmvXmI3FZgWljUGgJ5ILgGSZgeTRxkOXyUyPbxOFUWWvpYSzbB3ML1L1cmxMoMsgqhedF1JG21BwwtboKXu(mKJ1J0ddeybqAUK(XcPvQrNoJDiTY5Q8dtAatkxfxzhM0fq6HQJ0at6SjPFgsxaPiUFsH6z2KuOgNK2KolaT9Kwj5C)Gy4j9W(M)lKwBmq(VjgEsR)ymKwj5C)abqkdyHW1qApgsrC)KYk8EsNnjfQziTsn4asRZE)82jMuC2qhGjnGj9JJHN06q(XtkYzGkKJnug7GlODmiXzfmn60zSJfqic5LB2aEjXoT0Ia2zTMnlNnktacOBUFi7cqGbc2UD9IvRMnly72SSUSwG5Y0XuacmqW2TRxSAT2JC)WWf0ymxJCUFGakFMQXG7jsez7XCqn1uTw3pmCX0GdUP9(5TZcoBOdyR7hgUyAWb30E)82zbTz)loBOdSA9iSKx3D(4sgca5h)f5mq1qowpsriSqkNDBwwKwXlWqALKoTjnGj9JJHNuo72SSG9nQq6HbbgL0EmK6kJraKYk8Esf2NjacPMpigEstBH0ry)KuEitHCSHYyhCbTJbjoRa2UnlRlRfyUgPtBlcyNmswGdzmLgkJtPk4pc8c4Lc2UnllyFJkxgqGrlId9dggXuLrYcCiJPae0ogmBDYdzQIzeV)MnGxsCbngZflnGTor4KJ1J0k3ZQret6hlKIgJX134etAatkuZWigs7XqQ9F4fqm8KEUHH0at6NH0EmK(XXWtkNDBwwW(gvi9WGaJsApgsDLXiasdmPFMcPKw5gtKXoT3JOfKc14Ku0ymU(gNKgWKI4(jL1(9gsDfs)t76fsZLuEjjnTfsbbCsQlIKYQJmgEsBs5HmfYXgkJDWf0ogK4ScOXyUU(gNweWoRfAxVzznf0ymxxFJZcKDd4fmYSSATgX9ddxS)dVaIH)EUHP8zSA9OS9YKf7)WlGy4VNBykY0UEXuJvRmswGdzmfGG2XGzRtOgN3mqfKWdzQPkJKf4qgtPHY4uQc(JaVaEPGTBZYc23OYLbey0I4q)GHrmvzKSahYykabTJbJmOgN3mqLQygX7Vzd4LexqJXCXsdyRteUvRUFy4IPbhCt79ZBNLptv3pmC5Cdd8cqlFMQhbTR3SSMY5gMR76ZYNPAThb(JaVaEPGTBZYc23OYLbey0I4q)GHrmwTEeJKf4qgtPHY4uQPkwYR7oFCjdbG8J)IumqKJ1JueclKEOnmKYM1NK2jP2bVTaiLbelisejLvK2KEC8hEbedpPhAddPFgsZLuKI0Sb8sITG0fq6M2cG0S9YKys3HuU6kKJnug7GlODmiXzfo3WCDxFAra7mgCprIiBDE8hRA2EzYI9F4fqm83ZnmfzAxVyQMTxMSGLged)DcE7eTbsrM21lMQygX7Vzd4LexqJXCXsdyRt2TvR1wB2EzYI9F4fqm83ZnmfzAxVyQEu2EzYcwAqm83j4Tt0gifzAxVyQXQvmJ493Sb8sIlOXyUyPboTSgYX6rkhJafTN0kjN7hedpPh238FHuwrAtkN0Gy4jfbbVDI2aHuw2Yq6h38cPMpigEsr6D9ML1GjhBOm2bxq7yqIZkyKZ9dIH)Y4B(Vyra7SwSKx3D(4sgca5h)fPyGSAnBVmzX(p8cig(75gMImTRxm1unBVmzblnig(7e82jAdKImTRxmvzKSahYyknugNsvWFe4fWlfSDBwwW(gvUmGaJweh6hmmIPQ7hgUCUHbEbOLptvmJ493Sb8sIlOXyUyPbS1j7MCSEKwPDyVK0pwiTsY5(bXWt6H9n)xinGjfX9tkupKYljPXKlPhAdd8cqjngCkTXcsxaPbmPCsdIHNuee82jAdesdmPz7LjfdP9yiLv49KAhjPYSFEBsZgWljUqo2qzSdUG2XGeNvWiN7hed)LX38FXIa2zTabgiy721lwTgdUNirezi8Jz1A2EzYY5gMBUaGmzrM21lMQq76nlRPCUH5MlaitwacAhdMToRp2fpKPMQ1E0zdI21lfMD9x4fCHmyRwJb3tKiImNh)XQPAThLTxMSGLged)DcE7eTbsrM21lgRwRnBVmzblnig(7e82jAdKImTRxmvp6Sbr76LcwAqm83j4Tt0gixOFUWW1ud5y9ifHWcPhInKUdPiDLinGjfX9tQzh2ljDeXqAUKc14K0kjN7hedpPh238FXcs7XqAAlaH0giK6fmM00UhsrksZgWljM09NKw7XiLvK2KcTJ5hznfYXgkJDWf0ogK4ScNByUURpTiGDIzeV)MnGxsCbngZflnGT1IuibAhZpYIjW4D6jVcK9k4ImTRxm1ungCprIiBDE8hRA2EzYcwAqm83j4Tt0gifzAxVySA9OS9YKfS0Gy4VtWBNOnqkY0UEXqowpsriSqkNDBwwKwXlWuzKwjPtBsdystBH0Sb8ssAGjTD3FsAUKAcH0fqkI7Nu7(uiLZUnllyFJkKEyqGrjvCOFWWigszfPnP1FmgxzmcG0fqkNDBwwWHmgsBOmoLc5ydLXo4cAhdsCwbSDBwwxwlWCnsN2waHiKxUzd4Le70slcyN1MnGxYIT0(0UWaLSf5oOkMr8(B2aEjXf0ymxS0a2Iu1y1ATmswGdzmLgkJtPk4pc8c4Lc2UnllyFJkxgqGrlId9dggXufZiE)nBaVK4cAmMlwAaBDIWRHCSEKIqyHuUpaiJraKMlP1FBgbJjDhsBsZgWljPPDNKgys53y4jnxsnHqANKM2cPGG3ojnduPqo2qzSdUG2XGeNva)bazmc4M7fTnJGXwaHiKxUzd4Le70slcyNzd4LSKbQCZ9AcHTi3bvD)WWLZnmWlaTywwd5y9ifHWcPhAddP1TaGmjP74rK0aMuUkUYomP9yi9q1rAdesBOmofs7XqAAlKMnGxsszTd7LKAcHuZhedpPPTqkKDpJ4lKJnug7GlODmiXzfo3WCZfaKjTacriVCZgWlj2PLweWopBq0UEPy2eF)mvR19ddxo3WaVa0IzznwT6(HHlNByGxaAbiODmy2cTR3SSMY5gMR76Zcqq7yWwTYaKZlpKPyz5CdZ1D9z1JC)WWfx)Ug)hNfG0qzvmJ493Sb8sIlOXyUyPbST(QP6zdI21lLZeFBggFiMQygX7Vzd4LexqJXCXsdyBThdj1YUzxz7LjljRaN3f(c3PuKPD9IPMAihBOm2bxq7yqIZkGgJXvgJaSiGDwB2EzYcwAqm83j4Tt0gifzAxVyQIzeV)MnGxsCbngZflnazNniAxVuqJXCXsdUq)CHHTA1SzbB3ML1L1cmxMoMsgqhedFnvpBq0UEPCM4BZW4dXqowpsriSqkxfxzvIuwrAt6H7yCbsFGai9W42Js6F8cgtAAlKMnGxsszfEpPUcPUIFzrkYDa7Oi1vGxGqAAlKcTR3SSgsHwubtQBdDqHCSHYyhCbTJbjoRa2UnlRlRfyUgPtBlcyNG)iWlGxkmDmUaPpqaxgC7rlId9dggXu9Sbr76LIzt89ZunBaVKLmqLBUxgO8IChGSAH21BwwtbB3ML1L1cmxJ0PDX8bDg7GeEitnKJ1JueclKYz3MLfPinOX2KUdPiDLi9pEbJjnTfGqAdesBJbtAmqlAm8fYXgkJDWf0ogK4Scy72SSUqGgBBra7e0H5kNYKL2yWLyqMLoGCSEKIqyH06pgdPCsdinxsH2b)rfsRudoG06S3pVDIjLbSqys3H0kVI4WkKwxfPsvesr6DGdakPbM00oWKgysBsTdEBbqkdiwqKisAA3dPaXSzgdpP7qALxrCyK(hVGXKAAWbKM27N3oXKgysB39NKMlPzGkKU)KCSHYyhCbTJbjoRaAmMlwAGfqic5LB2aEjXoT0Ia2jMr8(B2aEjXf0ymxS0aKD2GOD9sbngZfln4c9ZfgUQ7hgUyAWb30E)82z5ZybKDhJtlTiMuaGptEduuXeDkoT0Iysba(m5nGDMb0byK5ePihRx9iTUksLQivgPKI02c0bKM2bM06pgdPimFJiPbkJxqLj7m2H0CjflcPbmPrsQlq6dWKUPTaifS)mgHui7EgXJjDHjT(JXqkcZ3iYoAsrBejDeXqAUKI2hiKM2bMuxG0h08cP74rKuwl4aszfPnPPTqkwssD35JlKJ1JueclKw)XyifH5BejnxsH2b)rfsRudoG06S3pVDIjLbSqys3HuU6iD)jomcPlmPhcHvihBOm2bxq7yqIZkGgJ5c7BeTiGD6(HHlMgCWnT3pVDw(mvpBq0UEPy2eF)mvpY9ddxo3WaVa0YNP6rNniAxVuy21FHxWfYGRcTR3SSMcAmMRRVXzb(79xGaz3aE5MbQGmN8qMcAZ(waz3X40slIjfa4ZK3afvmrNItlTiMuaGptEdyNzaDagzorQQh5(HHlMgCWnT3pVDw(mKJ1JueclKw)XyiLn(gNKgWKI4(j1Sd7LKoIyinxsbcmqW2KwPToCHuUCzifQXzm8K2jPifPlGu0fiKMnGxsmPSI0MuoPbXWtkccE7eTbcPz7LjfdP9yifX9tAdesNnj9JJHNuo72SSG9nQq6HbbgL0fq6HXiczhqKECJ5GcMr8(B2aEjXf0ymxS0aKDC6yKYljM00wifnMa9Js6ct6XiThdPPTq68rDfaPlmPzd4LexiTY941csnlPZMKYaemMu0ymU(gNK(Nm8K2EpPzd4LetAdesnBMIHuwrAt6HQJuw2Yq6hhdpPy72SSG9nQqkdiWOKgWK6kJraKgys7Zo8TRxkKJnug7GlODmiXzfqJXCD9noTiGDE2GOD9sXSj((zQc6WCLtzYc6EkOYKLyqguJZBgOcsCq5yvXmI3FZgWljUGgJ5ILgW2ArkKGC2v2EzYcAGfaIfzAxVyqsdLXPCnBwoBuMaeq3C)q2SRS9YKfgmIq2b01hZbfzAxVyqsTygX7Vzd4LexqJXCXsdq2XPJvd7QwgjlWHmMsdLXPuf8hbEb8sbB3MLfSVrLldiWOfXH(bdJyQPMQ1Ee4pc8c4Lc2UnllyFJkxgqGrlId9dggXy16rq76nlRPahYykFMQG)iWlGxky72SSG9nQCzabgTio0pyyeJvRNniAxVuot8Tzy8HyQHCSEKYojWabBt6HAuMaeqKw3(HSjLvGfpIK62yXq6oKwPgD6m2H0EmKUPTaiTU2ltIlKJnug7GlODmiXzfoBuMaeq3C)q2waHiKxUzd4Le70slcyNabgiy721lvZgWlzjdu5M71ecYCA5XxTwZMLZgLjab0n3pKDjdOdIH3Q1JoBq0UEPCM4BZW4dXut1ZgeTRxkOn7FptmYCGvR1MTxMSGgybGyrM21lMQMnly72SSUSwG5Y0XuacmqW2TRxQXQv3pmC5pWFGpg(RPbhmcgx(mKJ1JuogbkApPq7yIm2H0CjfNldPqnoJHNuUkUYomP7q6cd7WLnGxsmPSSLHu4G3oJHN06J0fqk6cesXzdDGyifDDXK2JH0pogEspmgri7aI0JBmhqApgsrqfPosR)alaelKJnug7GlODmiXzfW2TzzDzTaZLPJXIa2jqGbc2UD9s1Sb8swYavU5EnHGmKQ6rz7LjlObwaiwKPD9IPA2EzYcdgri7a66J5GImTRxmvXmI3FZgWljUGgJ5ILgGmKtowpszhlcdPCvCLDys)mKUdPnMu0EqK0Sb8sIjTXKYSyC46flivyFiHjjLLTmKch82zm8KwFKUasrxGqkoBOdedPORlMuwrAt6HXiczhqKECJ5Gc5ydLXo4cAhdsCwbSDBwwxwlWCz6ySiBaVK3a2jqGbc2UD9s1Sb8swYavU5EnHGmKQ6rz7LjlObwaiwKPD9IP6r1MTxMSGLged)DcE7eTbsrM21lMQygX7Vzd4LexqJXCXsdq2zdI21lf0ymxS0Gl0pxy4AQw7rz7LjlmyeHSdORpMdkY0UEXy1ATz7LjlmyeHSdORpMdkY0UEXufZiE)nBaVK4cAmMlwAaBDI8AQHCSEKIqyHueMxW2qGgojD)jomcPlmPODmKcTR3SSgmP5skAht2Xq6HwFNHxiLB9NYKK6(HHlKJnug7GlODmiXzfG9c2gc0WPfbSt8(9UXykNRVZWlx86pLjREK7hgUCUHbEbOLpt1JC)WWfMLLaUXa)XXoLptv3pmC5C9DgE5Ix)PmzbiODmy2APdSiMuaGptEduuXeDkoT0Iysba(m5nGDMb0byK50sYXgkJDWf0ogK4ScOXyUyPbwKnGxYBa7eZiE)nBaVK4cAmMlwAaYoBq0UEPGgJ5ILgCH(5cdBbKDhJtlTiMuaGptEduuXeDkoT0Iysba(m5nGDMb0byK5e5KJnug7GlODmiXzfqJXCH9nIwaz3X40slIjfa4ZK3afvmrNItlTiMuaGptEdyNzaDagzorE1ApY9ddxmn4GBAVFE7S8zSAfAxVzznLZnmx31NLpt1AD)WWLZnmWlaT8zSA9i3pmCX0GdUP9(5TZYNPQ7hgUycmENEYRazVcU8zQPgYX6rkcHfs5Q4kRsK2ys9nojfi4fKKgWKUdPPTqk6EkKJnug7GlODmiXzfW2TzzDzTaZ1iDAtowpsriSqkxfxzhM0gtQVXjPabVGK0aM0DinTfsr3tH0EmKYvXvwLinWKUdPiDLihBOm2bxq7yqIZkGTBZY6YAbMlthd5i5y9ifHWcP7qksxjsRCUk)WKMlP8ssAL26indOdIHN0EmKkSptaesZLuFmcPFgsDLmfaPSI0M0dTHbEbOKJnug7GljiMdKe78JLBKcQftJkofugebs7VlWm9ajweWoH21Bwwt5CdZvaFMm2Pae0ogmBDAjYTAfAxVzznLZnmxb8zYyNcqq7yWid5iCYX6rADaejnxs5qCGiTIECUsKYksBsR0(D9cPCzdDGyifPReM0aMuMfJdxVuiTImK63HxaKch82jMuwrAtk6cesROhNRePFSGjTZuqzssZLumIdePSI0M0EqKuidPlGu2HFCs6hlKgzHCSHYyhCjbXCGKyK4ScFSCJuqTyAuXzmyiWpBxVCDOFp5h9AKZasSiGD6(HHlNByGxaA5Zu19ddxywwc4gd8hh7u(mwT6UyCv4G3oVabTJbZwNi3bwT6(HHlmllbCJb(JJDkFMQq76nlRPCUH5kGptg7uacAhdgjwEmKbh825fiODmyRwD)WWLZnmWlaT8zQcTR3SSMcZYsa3yG)4yNcqq7yWiXYJHm4G3oVabTJbB1ATq76nlRPWSSeWng4po2Pae0ogmYCAPdQcTR3SSMY5gMRa(mzStbiODmyK50shutv4G3oVabTJbJmNw6W7aYX6rkhIdePC2IKKw)FCarkRiTj9qByGxak5ydLXo4scI5ajXiXzf(y5gPGAX0OIt0gQDbYfBlsEr)4aYIa2j0UEZYAkNByUc4ZKXofGG2XGrMLoGCSEKYH4ark703frszfPnPhEzjasROd8hh7q6h38IfKI2hiKI)aH0CjfpbJqAAlK6xwcoj944WKMnGxYcPvSTmK(XIHuwrAtkNDBwwIH0kcWL0fM06waQmPfKYo8Jts)yH0DifPRePnMu0pKnPnMuMfJdxVuihBOm2bxsqmhijgjoRWhl3ifulMgvCI3V3lzgd)f8Dr0cieH8YnBaVKyNwAra709ddxywwc4gd8hh7u(mwTEedieCwWIh(YSSeWng4po2XQvXH(bdJyky72SSeZDbU3f(MlavMKCSEKIWcaojLl4dpPy027jDzYanyhPZyhszfPnPC737LmJHNu2PVlIKJnug7GljiMdKeJeNv4JLBKcQftJkotB5chaCEXbF4TiGD6(HHlNByGxaA5Zy1Q7hgUWSSeWng4po2P8zSA9igqi4SGfp8LzzjGBmWFCSJvRq76nlRPCUH5kGptg7uacAhdgzw6aRwRvCOFWWiMcE)EVKzm8xW3fXQhLGyoqYcE)EVKzm8xW3fXc0UEZYAkFMASA1DX4QWbVDEbcAhdMTi3bKJ1JueclKYM2WlKgdomcPlmPhcHrk8cinTfsHdaoj9JfsxaP7qksxjsB4uaKM2cPWbaNK(XsHuo7fKKcfaOFKKgWKEUHHub8zYyhsH21BwwdPbMulDaM0fqk6cesBwnIfYXgkJDWLeeZbsIrIZk8XYnsb1IPrfN4yG)(lVVnrNlaFDBdVCx4lSawOir0Ia2j0UEZYAkNByUc4ZKXofGG2XGrMtlDa5y9ifHWcPC2TzzjgsRiaxsxysRBbOYKKYYwgsNnjngsp0gg4fGAbPlG0yi1vswImKEOnmKYM1NKc14etAmKEOnmWlaTqALJjLDmIGOhsxaPiqGaRFbgs9XiKgjPFgszfPnP4SHoqmKcTR3SSgCHCSHYyhCjbXCGKyK4ScFSCJuqTyAuXj2UnllXCxG7DHV5cqLjTiGDcTR3SSMcZYsa3yG)4yNcqq7yWS1PLoOk0UEZYAkNByUc4ZKXofGG2XGzRtlDq1AH2tz6jlJabw)cmwTcTNY0twoarq0tnwTwl0Ektpz5uM0grGvRq7Pm9KLj4TZlCl1uT2JC)WWLZnmWlaT8zSALbiNxEitXYY5gMR76ZASA1DX4QWbVDEbcAhdMTorkhqowpsriSqAAhys3HuKUsKcVasrB2NuKUsStKJnug7GljiMdKeJeNv4JLBKcQftJkoBaKDKcuIVXWlZpseVqlqihRhPiewinbXCGKK2WPaiL579KIZgKys7XqAAldP7qksxjsB4uaKM2Ds6FYWtkI7NuEjjfPsBsXzdDqH06aisAUKAeFJiP8sMXWt6XsBsXzdDaPWlGuOD9ML1GlKJnug7GljiMdKeJeNv4JLBKcQftJkoXqnaFx4lmOtbmT)ItqalweWoR9i3pmCbd1a8DHVWGofW0(lobbSCrQYNPAgOcYSSgRwR19ddxo3WaVa0YNXQv3pmCHzzjGBmWFCSt5Zy1k0UEZYAkNByUc4ZKXofGG2XGrMLoOgRwH2tz6jltWBNx4wihRhPvsG7VpjfU9E3g6asHxaPFC76fsJuqXvgPiewiDhsH21BwwdPXq6cmcGuxejnbXCGKKI9BwihBOm2bxsqmhijgjoRWhl3ifuSfbSt3pmC5Cdd8cqlFgRwD)WWfMLLaUXa)XXoLpJvRq76nlRPCUH5kGptg7uacAhdgzw6Gx(Y3d]] )
    

end
