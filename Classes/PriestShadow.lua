-- PriestShadow.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

if Hekili.IsDragonflight() then return end

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

                return app + floor( ( t - app ) / class.abilities.void_torrent.tick_time ) * class.abilities.void_torrent.tick_time
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

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
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
    end, false )


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

            dual_cast = function ()
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
            dual_cast = true,

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


    spec:RegisterPack( "Shadow", 20220821, [[Hekili:T3xEZTTrwI)zr1uldPLcdj1HDYkYP8r8KKnXr)I8eV)LOabbjXyqaU4qkAlv8Z((EV(Ur3aqs2zsMFtv7MXIOpF97(O7RgF17V6YLbLrx9UjJMmz0lMmE44VE0zJF(vxwE3UORUCxq4hdwd)J0GTW)9YnblZUf)57sYcwIDViRkpe(0MYYDfFZx9vRJl3uTyyy22VQiEBvsqzCwAyEWQs8Vd)QRUCrvCs53NE1c3Z9KRUmOQCtwomDXBFnmYXlxgXAEurOyrS)6lYJJkk3)dVSADf8)E9KXhb)hyS2)d7)HxVjiDDuX3S)h(Y9x)(BJc(4(R)1S4LWFKLNhLcT)2nrP7VUmiFDe8xHzvPLf7VoipA)1RYG90YHuNVipQmkf64Ym53R2z2DXVhMKva)pLzqRVloDnSGkG)D5MaygsR(yKOHfLXjj7VopcGtBHrhMSRUmjUOSaHP7OFFrqj8hVJoKIsdwKeT8QxD1LH5XLr5XbxDzE02G4uyipF)1hpAea3crGn0)SBJYNFBw(Y5WoPmUSAz0vLaG27qbNIjlItxoChakRsIMhLxTdhSH8MV)67Vh3m8MDtgEWcTRil5gaAkAMAnSkjQydDUJZ8XEN5d2F9IQvRgwqNQWYD7WQDQHr9Z4WCI3HbGdbPXL3nCz0Q4WyaCpB)1Jpvnqb5HbPrZlzN(4GDQ1GXqXzty0Y5z5lMNTc7WwSdwRO6nagXZSgXmyJueP13BcGfl8v8FLub)ptOFBoBQ3cq25frWFhwvMTAfoKpVjaxzqcc7xgSnnq)WsFc3UlopoewLvHBWb8fEhW2hnAbUijOa3TW2cr)AgfLoAxKLLsqQnrZdkczO74HCrjS0kX(lNIWGKK5S)yospWOk4aiCGAgp(abf5W4I57scUlkxn2lJl2fLmFBW64qxiLsGgWNqsaW46KhZ)J)osFZyK8T8wS)A8)pmllbWlG)1o4Fb0(aLoGfMefq8MoD)1cu09x3plF)1NmI4ZS)6xLKLHdxYk2iLTlknkFasxGCnYG)tm8P7YQaMoeBJSBIaS5D6dzm0XF9Td3F9pf8rK)sfYLHXPCvmaX)QFco7wGGEygdq2z4pGtoT(IlS3flIGfhUx)w20ZhRe4GG18O)NQ4D7qUKx)9RtP2k355rSJwa6uW6Evb9bJrbyGxSLVAEfFPrlKQYH6hQcQMH44JC0MhUeAwpaqQdcMnLbNpK(9XW)6z0)kpimA4ceippcHXq)kJX5NyBU)6b0)hYEBhG3qqRHiQWnruBZRsrqX6iblkCXpFhU2hkGbudpqb(gQOugIYkS(kBGymOxgfuUHA0G6BPZHT0loLT44KNi)bauopnE9MYTGWefhAO3sqvTMX5PiMg9LdBlZxN9PV1kJE2AIiVR1eCKiPfrLLWAOyymHFi(oSeCXl3K)kd4SdzWysaQJFtKe7qQeCkV8dFZf7V(Lx(Yly4Ya7gL4Deh8d5aOEvfqa92aaZIWJt)c4JItBMi9viiJWwh)LhlLWpSgBTvbrZxxfKVmoiTq7yEze95B5Z28v0KjAaYckzUyqLS8jSXtCjwYG5l2uh8SBgPW7uotdHXw4JC3Kvo0(izyzC4hjiutys(N2P4w9YW7cbKg(3rHaoKG2jXca3axIkDb4SNY)4dkTq))oyzrCoZYjoemU4xsRb2gMP(zE0kGjm003K9(cuUr5gKG0AV5sHaP0sHEand26Z2xMkAmKp94GY4f4CVxRvmMpe5dbexgDdyEruUaLsJZ4(RpvY7MX2I62YG8pckAKvb7WHfLG5luBR)TTb)2C(3Xz(aID18fzPvfWzsu(KxmFYUqKxL5bayoWkuqfcKRqLbEJaoj49qsljErO09F99mHAKCCCBG)iX4c0hL(XqscCa2K8Tba3P3q7AcP4IKG1vWK0ponmPAj9BSJ83WbnadW8SWIbC5OAAjWh8D4smh2MVNTZlqRpG9TPG53p5fG0ZDHdruIVUdSMj5wUuosyE2hGwHlZaeZRlQai0oHT6J(naFcAXsoKG4MNg9BWEAD4sdUXpnX2QERSNAknjTWVgA0ZrO14rnX4HPUSjC6Lj3gCxbh)bBf1i(bcCIrlncMSPcSILbaUHu6erLqSi6RDfIY6eOOgGIUCzmUia(P3DKa3tUe010e0aGgcORPmkueLNeMsNf5XRG)5cGw82GyM8YG6Nn9DRuu4geGwWSstqaZfCk3ZZXTSuBcL9ownqYFUMwCghO4wDotXVd5hVdSqa(eH(mZyYAfhstvkdouCEECDSIxYTnUMKcYCLfzjLMQW1TDahYwhgWGn14jEYoY0PX2M8zy7eUy8B30RGVYmoAdihIXbtioJjN67uy9SUGBme77eP6yhXyKMvsdadXGBdZLVFOlpdO0MUxRys96O62nEWEMuMw)UmHh0L5KJI7DENsKtK(1JTTswkyxiEbnqEn6fcJtkGDAyShXqSJNlzRV9x)oXcuO6CvrWAnE2VMJIwyXrWfwLHronqH31JMNgvTtIUMpTjyUpxk0cm)nzKDim9jQd2LmLbvg4SGJtr6HFLVcjnJkJcwYjlivqCCkHccyqpPegM02nOhZIsrgpUT4PVuLsL2AAMEdSXmntL4dWD2MX5IjBlrlm4uFmz5UghAgdnpUbWALWPX17y74lC602BypZvsJwzZOc9zMBZmkFfJv2RFJ2H)sgssAeUqWtFMW7A4lhXpzrwJrC)nNevuq(HovNjk5QfyNFQGYomlDzvC5aJJ(MSyTpnChk75WLXffG2fPLZJc3Kfvyt72e34woG6WjjbX9zaTdTxBXWgURe3efKuUz4UWsAppzulCdiyYajw1tJtuB6oyBFsnDW)gdLWnDkcgoIfeoafYc0LisZt2eCtKBDlvRpgwJURfXUR52rHVviZkg7Z6(IkKla0FGFW8TbltbS12mwNozqnSW(qRC1rJj3BKBJtGKywz7(FInVmcVafqIf8geuToJzjIaufOufgWd3tEvKTr95kcDEEnVbLSyWOonxPyx9TMHN44)UEKHCONO8ZK6Y5r3mhvBFSQfcgDm33JUonPQa7xqyzRi)hlO1L7HBGTayvtsCR400Eu6d3ZibbCI(YBrp(KTA(QGstnICscyfSVS0K70nnN4qI2MtShfeMc(MQt)BzmDPZBdtrblystJsyN3(dQsxLQ8iDSKxxRiDRK)JctdvzeW0U5Pz()h(M3iymCbSswainFePXUOiizlAmPqwKouMucbT1CrucY4AYO)dviiyWBzKjcZ2IwoUii8JgYPuSu3PM357WP1KLQtAllokaZ(5i3KzeIydEUhqk4E)rAvjfIkFofGpcH5bfn6(KxJnqPfGgytkupyjQ)tCkaqGJAtyragclYB8yRgIHhcn1EeT28hVUhjAyp32V6A)P7WssjMS0Iku4ITtQi3AXaaV8N)2HWN(538ZOnfPRIjnEjOb(FjXyUSMKPVtEeCoZCqbFWuGZL0KwkNuljIml4H)0fZAqf8OCmgGZJxbsKacUIztpX433UnAzmMJdxIm33qrZySlptJNk22R5d292KG76oS7Y3tBGI4L4ozffLWAHYWLFhCsLCGF)r4pkDUCa0QkaplpI5hiUNsMXC7g6AwFq3Eh4gp7bcZb9zUJG5(SxZRR70ohELLhZQPFUHp4be4llZ2X0ApweE4tyAmTLXNtOvUFZSTmEJMx6dm3l73FGzeh47c3edwA)JXPFCOhs9z)1tjtmfSOHpeVTAld35uDrKPvBxqQ8TsU0Hn5ltkYocbg81eOEbsOP5IXQ0YyGBFaYYxULPnbsNQuReLolCRaTVk03x7y7le6R7MZGBcIti0Ww1MsJh52SBIWK4qWN00xHJgEAxuBHzi0eDDw2gxeLFNsq)HcvnMxpMj69Bh7KAEcEqP37(nPPWFLoGgiI79tWUJbMgq3ToXTrZDWa7(q4wRrMqvVgtBMMlnQzTHBmQl4N00d5en(fciGJ4BjvVIVP9SOnzKIHC6MsMdIhz70bBuLEDjMzd0u(VkDvvoM(fZrUJOPm1La)lcos)kF7GAit4EGY1rOgYlckWzhLCOfylION7R13Z81kP47KUyRTJG4l9Xi62Gy2CGCmlm5qYJIgMtmRw9Lk2JwHP)yDMOuSTWTW2SffMXjXG)h)tV7NFpYpNG9pySeIMVNUNjCCk2ijDlA(pHaYEnBUgq(jJ33PD0bD3zzps9jD49o3WptAOhomgDIYeNgr(FffjZPekSTizakili9oD5wO2wzffXWCDeg1YWODLpmuuUTsgcNPZDFErql1kDRM04guikVwkF6pfFAwHp63zPAAmW7PawBwXSYAC19kbyjIdfRERCNzP0k2rLOLcg3c8hlPp8R8PcoWe5yeTeiWOVeCqP9DxvUFsNGRpguEnnvXLSplWvkV6zb2RVtfKV)ENrlSxF7Z27V3z)7X(rBF7wTBWGoO7nMQL2Md7ZXbi9etnrGzvwox)Az6CHkQ1KdjWPY26wNt1fDAQ4cjylnros(630alykVydVnS50I1DaW8yfn9HNGYCnqfJJkydr(Cw)nOqjMxZnCvyJRoFJd3IoHwPhl0J15AIP864Z0JnFNwGxDj6HV5iKhX9moZPCB5KVSGLM)PIeGGN(TV(dV2WIopP7CTKoUQiA(TBq(BC9vmYJ5AIfBnydDiOsnAOTkGdTR3ylsMh7lScoSi1k1KDfirov0fOOI9x)9CzfcFWkdHPYo28OGL3XdLPHH0kfclVnZHPZdDLw3FspO6Kwpp5dGj26lVH4p9648Wkea76GWsv6pAP)ckM8LzFRRmV1GYPvpGiAnk)LkOfIBjRBc)SxvW2McpMZDwoZTh4PoDmhW8BxE06Qev(loKXdTe65hJO6HPgJ06yM8wdJXQsYhGviYiOOvUe9RKujt4pvE7yb3H7rccnM8h9ju2sIQPH(DmN7UTLrKN3whX9M4PYwXzLi1pb6fTSeEWMB6uwkpg)LcVJaR71RjQcCrTiQ82iQQI4BEGCEr16)kgpwE1PegKxqbbjheZMdCXMJzA)QilMjcMREB)8te8U5(EJr1l5HuN1SuaGdv(WVzQHHS(H0ZkQXJKtriiDfvLyirbH5iTgjP3nPd2W1XfehXSSXuM0AVj794MLB3oHsiYXqSnaYzeJsbofkz5Hi5fkomqCceTD3Da)PK5aHnSbcnG8TbdqZngpPZWlWcajqP(86GvNPypbE7L3LcuRF))pzCzEtwfrEEPWqKx)McgNCHPmac8pdGXKSuc7Ke1knvHXYLgpaBgPVaa22DCFMxqZgRLKTsymrqQJ)bvLEe(FCPeJg2RH5vL4wy()tfGruTft73ytaRtTxAcBCrg61XE1uJHm4BuZyZ9A)W5qwbMmZVAs2lw5iAnHDBi73HbGCA1OoT8fnDGlqe9XVwRCcB4iYH0etbxeYWLBIqkWFcwWH(OR2gegSalseSTZ3In9HqzXcULs6LJrR0Bj)bwcNWyQppVAXDU0aqYBQEBnrs9GpEa5X6Ocu1HKvZnBfRjYcQIP6GJsq0bO9xQwitBYAkyrPJ3rmb1751mdrIMgVlIl4ob6esx(DxiDj0(R)a3T7kNXFjFnb8fYxWSj)9SL1rgu2s5RWzYwYZI6EiH0pZ2Dwg7Q3gNJJ1LXRrjYfBPOeKbFCB8)l3zK8fK6GGbfeNMyvgUchL5f4G0mxK2eQ1HJToHzkPIvhYwiscT7vHA2Qbc7JAK7gYCtHSAdkkRxKm1fF(QGLyoCcJNwid5k4qymRyhrSJ7ChQuz0gmUxmTxdfAVIcAUHspJizjuQcVpAM94rf6A3hCBWDsbgRtcqFmKbQiSaxQpiUetnztuBSkRxpm(crVlAbHJ)yfTzQIlNiVmt1uYtpBOd55)VwxWyPb)0)1DWolL193ffMNLq1vbtDfeAIOf8Y7rioxPhARv1SdyNp5lN3D5lAnTVUUEQ1VHoGFKVhhOjSJ)j0zEBUl3NsJMUk2n9T7eCQnkjSg1gz7OhNv9TpN1fKhcwdhfwwaaZ1rPaUpy4uwUDY)YmGzJY9sCInYPjV(n)I4m0)4v2qrOGw)c9ABHDkhhTkOcbeRawSlu2WimDJ6Z3WTJXIcLqhPqUI8TK2EvKKvwp3cEq8BBdXsKdliM7sN2gk23MtGlqEnXLMkMa0FFxgwcmeyr5McE6hroKXeMOvIsiYFreAsEb36pmaBAYirLInsfkwXQZy)Tla5xMjsxtb5Ha9xljV5PdKwbFHjrvqk3Gt7cvNHLrO6i7L6QTZujGCk6og4rjStUEwXt3XS6SXjyvk(Vy8TmtI8MeL2RbZopWbVIEM)SgRLoWFsO)lo41fH2wVLSCCO4CB9LRLFhwJYIq7zuq5CSuN53OavwP1I6cTTk4RxNSRLeZQmeL0rPBMP)PxpJpq0VVJHD(wu4Wgnc43QegIGPK52c)jpoeLNfc8vBNlMYTjJ0Ka5ucLMuKomZomRxg4p9ko3z8ZW57VjAHcKzMaykgC170slTq0CWllHWJIzSw(B5u8r((0BIxNjq2qa9BJJqGootVkbq8Y2IUd7dbOUk0jb7E0b5Eqfx4oLBYOqBeWuP3ERWc43VfVnMjUmseIpTtkFH5OVJcMtu5jA8yAS0vKe9oZLitN5ANypSQYcNLoMs02dGH358TfLb0DnE0a8cuNmMbmx2Wv4rfI8TqCqP2UUmTx33WRbsPwss)y9Q1(RLKj6WqSS(TYW9ANusMs1pQAOoX8cSCKBb(ggCaCxuQg8GvjlgF11PjTLQDPPKn7upXN5NeNlc7qiRNpwCjaqHjOAhx9bvUdAz1X3MY8uqTQWKPLb)QRsq7YVgSOu0M0BGbjwfNgxSjsL2J8CWbD3(PhUV9CDCOl)1ivQnf4SF380SBcCbh(70NHbd(UGj4rmPb0KSa0dzvc37O3Q4mvxLh4VcwUepncU1szM2rF65IzHFCkDVAwtCt)2fvR5OHgJsypN4OU8mJaC76cCQjpVtxCr80WMR2RgAKsDus69r753oaiiZwBaSvygmtkbWf8hWu7Kzg3k94UasNwH3(xrPH3XDXp99AvrpUaO7XOv7LPuBNKK0mZPA8XRfw1EpaoaovhUPP4CkxM66uW4h5T6Fy8QKURQw4hEaSIXg20aPRmCTpB5uHZy7q)uqdAokw96cOzGlpLjigA8QOrg1shossHDzuqHyz8PDp1buv7IW4EnFxoD9Lrg7s38znNsjnLIBhR5vco9R)eBOwlDWM9N5H5ncDsfRzc2TAEatLT6SYv2vyRrk8jkbcnu5PgRhncQpjKCmW8sMtrAnMZF7VffwrBSOBIOWSrStercplVEYORmbawiHTCDm(qCCIUlpO)xhgq0(frOV0gXirNDLYOKJY0uWPTKL23yCgPtJ6YqKlW0z(k06UXx1tIlo7sXVBlVtSwEAkU6srL2xInM(hKD31KqBf)NsYlrIA(WbPfQR1X66AH4LNCOMjD1u)tFl6lpKCPPq77xM8eTmwBh66QI5BcY3MLENJRspFonUdUPwpNZoUDVo2yWIp16KpC58TbPbRJe()1wqr7WIMm2Z4cbLvWaUeM0(KCQw5OOBYLX6VZEIsfT4gL3)GtvQMUjtEUhyHTd3Bhwm6t36AM)1vnFW3(c7KpDlm86uWwANwTMQoHCV2TL31(AVFl5vVSwK80QMe45BvAlYS9v5yl16LxkLKNl8nppCbOKVRCxxxOBwj3KeLgTng9AIAsJlG5CUi(40C)Wf31WCJ(Kws6llajBBeTwfARp96fV0XLRr7lUMTxYnBjlrDVwAF3fW)cREjwNoI8G5sMD87Op5YvIsFBOVX0nlM2z2I0c7uED0Q4OzY8A0QfkJw)sZGsZUQAxvLt(cU2DjrtenshfhNhrddnc(neX)iSikVikh1lIgcFX4mHsmS5)JQLRDCUrof4hXM8faK4h4nYiYvKgit2xpvEps69fMNROARLCddDMUsRduvE)8tBY2bR1jJUyI0oXdmQguQI5J(T4cbPINQP)5NU3tX(3fimACBrzoyQlArjnmnAZXBI5rMLfqerW4(U7aZfl3GPmnEd3cl6BZd2vGjHDjGfKOsCInQwo)wzd1xSAiHEACzNQt9s2LIcEoXTp6ymHoc4UXNNDeHWGlBTIAW5fer9BQg52IKvMTAEywscSeX)AvvzvEK9TogDuqr8K5tC1Td6yUIn1v9hoLptL0QonoaBHcU1WQPSH6nV5732BPKxZB1Vckv7TVixOR4xx7WrbflC(dUWOV(QlVnihPNaq1hE5V8UV)D)TVbVKiFpc6J3UJsBhIs7leo24lW81guvphz7wKHw9gawfSnGSgoK9QlmC)p8Ju(PC23qxydWetFwmkddwek5)9fSJ0VqYjf(i8B9h)BdgIVKdTSWKVvcpSv2eRvMmMi)3I1J6xeQoPwvpPXanl7B)5FS7Br8m8HT7o(XTYm3Dp)jniTURa5UpSn1NcKPVNwcy3F(EznlqV7gWNXeuiBvmQ7YF5VOUjweVZi4V58Tgb)G69gb)RN0BocFa(96DhrSdu(0sOdfJUc)71Xunn8YqS6wlOm84lrd3PltDgyKI2miTz)pW)7HskZdN(vUErsokE1uUAsNF8OrU7OQwxXM79zk5(79woRUhxEbZHPMhmUSIEu9BO6Do7M5Ric21yRhEKzJp1DxfjI1riJ5PEYNm3DvOKmRR21o6rz7McQGFePV90j(gcD7cO9m3iXAV3hUhav9aHD2FFbKjDCPo6Fu5CoL7Fugo5fzmul5xzU4exb2kwD)9Eutx03AWrU77mbF9BYlO3FFDnaoF6jd613VxpD3NZg4FDP5ArZ1MTxnztRp)z6BXshqFwCEO)TKpxjAU)8DJ0m5WA(d37mzygP1r7bT79XEhu3VJAfpTBJ8oFk3FJp7yFyHWVdgx3ZW)INpDYPnGgWnwVjqKLX(pSH60dN8S(Un)UxZEe88PJhnOxJ(buJhHx3z1ZZ590N)a3jJEkZ2Sh6SDYtz2M(IEh0GZ5EGlL(EMLZNE6GN55BU4D(aN2XK4dthP5Fim9TK5iH9XPJRo3WHz(hCn3t1XrE2uB3HD)9h4XryeRYpvoFY)Mq3vuM7cV(oRNBcx95q5gj5rUd2sTWABgB8857QVC8i9Pu62P2qYuExYDl)l8ut83rFhPV8S8weP5ztUtA20j3FpiEXPlKU)(6UpA2Zn58B6liVWKhTlG0Nlt9qD7NhCfmsDm87I)C8Vg97tfCD23PFDoFCV6Q)m7SrdCQw0zgOX2oJHRzXTH6nYYPlc2LG(qC7PE5f)iBZrhwmR2EvMrI0RsDccEqSSuAFJ58XuZ01OoMOgp)JPdSpFzMH5kdXA1tiJ6lnJppBSxbWJvIe9g5lHv2VPqHv(VRFJFpQFd1PoiDAQPCa8m3FnD482fYQicCPVDlAFod0(8(7n1KU5Ea2Nz08z(KRY)(HJpTvnGbn(F2jwlJzTvngoTcO11ckK2aOXnYqVQlgOilUKBaTmBmj9tYZW6WoA3MQ)xuE6fWFNeSLXWK6R2Pm6Ee2GCeJADo6PgLTt0OumFN(yinGQpN9kOjfiStYTLNWE8BGLH0njU2I(3)IbXaVUU7zAVqnC7ecuQYSXJ61)G6LcI2(9)pSqnSb4gfZIYjCAqtciM5SMnaojnuTgabFnFL0KLZthF)9YoOzsrJDA24bCcrJLChQcdnNv6Tcm0Wv(xQS63glqwkjhzujjmBmf(w98VgiOuhPAoiRgkIMnskCe3(OyGJZpaZP5oD)9nwqiZKfdI4M0Z9G7vtha3WJ(DNQHs8zRahQXvuvOf6(m2nSPNnrNpGL4cf0GZz)we7Js9vgQRBZ8GE1a1kq1FURjb7ZdxvIHBEN(PlEkkIdht1MjFiStAF4613v9haKj(lxGwPQV)E)DUNiMH1lZaj4s5KZZM0Zh(lY7OoKOTT7a7Jt3wAkV9VSATDPbGh8Qsj48Pp)uPDsep7pSHUsuFT8cNNpAiJ5Y9EEb(iBjSVWoe3WNiAn)wMJR0I65C4RO3LaKU7HDFlQTlVnCQwyMex0CGSaLAOUU5m53oPwxzP23yM96YTLzDoj98CfuEUHw8CjjUwdU6RiEb9p(W(1ft8SXNnOBtRMw)omG)pwxnJMNZ1OroQ210iCU7qNaLAa(cQuppsjak22Uyg9ZAKh2Spz3dJgqd0GRhl8OnEo9E075j0w(Z(19OnKWjhabJTFkGGFx8JhrCPONOw0qRCUwX5uwySx)nPGVeqHLaiktJRkscn1nlyuo7r4LoyyjdmZS42H0xJufahrKrDmctNVnyDCixTjHnXC3ejPBTv)G8TKu1be)vQGDseXvhliHyzLv3Ncl7ioV1xHUeagUKvSrkBxuAu(aU2pm)0AYuaHD0BeTAijdhadKVw)P2x7nD7R0FV3iyR57HsH9Uqy14V(TSP349jbBUuGnWcADk1w5oppIDmWe50L3r6xP9CGa2tpS2XJHcr45Jt(f96lajZMo50d7p(0N1ppa0uGfyLOKv9qf2o)4rOYapsPnsTouy9MkVv7kUMzhH0YOPV4u0hlTWdOvEMd0MsX72bOgM3KQrA5K1v8oQiVmWGX0zP4BmoO64ueA4oeZSsYIKDPDMjm(ugVGvyKnGTpLXrVnaugJWDOi7WDCETlD)XF5XUe)WXcS5jkPYnCmbDAW1c8w(ca9Ldm)nP77j1MovayFmmX9XJwfltRKccw0nKilUoT9nftRVx8eGKLm9r(UyubJlKAuQ)IFjKByO6aZpg87WmBqWF6aKem4cyZfXvrI9Q(QEmvyO4QNIqYHKVNXVI9moTtZxoHGOu2d5pYCnaBs(wpppZaBHWKkMlayqDwJyA4NfwmyV27gLwqhija2pIyuC0m55sA2pzxyDQjzMG5uNnhPhLMgi3FFB6OGrxLibPtNL8nfI1kzeEkWgMhXbdTWzrdS(VJb)N(gyqznJkGTOUh15jc6hOIqu7XuTnjrcHKmiT42g24zKKfUj0EGgzqrS(PWT8OKZu7rQNcGHxUxyg4GrWm52G7k4iW4xj5tCmcaLHQwtAJwZzgiUmIgR)870kyI1PHy(c)YLcRgtqRnyi)YLGUwmmDaj)wMY0cfP5wZE5wJWWwJpMi0LKAqm3oypaCZuCSVlzZS3RUIzJ713NRb6GdkCCCi9B4HWsBWJ041AJRYDKnCw7X2128OK8ne5GUS2aOI9EAqpxgZBRAm7(X0TVkyImQ5rBeXdrcup01Cdw5rvLD8ui8KNhfeX9NHtObvTAoP3A1)p(peod4W1V5bVvNPnWRVJNkmF9ZWt7FDjbw5Jkrl56KwQ3Qh6K2bNpoQKo7aZPNXY6M)q(483n4UHmuP9mpxzZaHQBf(SEUJ6MKx1XpJ4r13TFw0MhGIPBX8OFBnrZNoEnHrtI9)0F)8BMLIpeU(NCyBVJ(d65IFudG2wH(U1Z5pgVA8DqNixQBYD3IMVXNmYVPAOJbFCCs8ltvx7XplpZ81HmoEd9DBHebB0Z(na4yYtKCBJLC4p)VK6UPzeLAJJTs96HO(2WoeVUZ6g9xfFq9mxXKIz)H1BHVxmGJh0RdjuGgL)Ph2)SNXjvD(s3pyGt9vzuqCS(hN2h(T91JHzCBFDVf1q8)D9LGVdSkmYIj)Vr81cJTDMKYEB4N1VbN0jY4lsB(6CyF4pU7(2Eu5dq7S6jz84rMjrY()09SR)WC(Zdg)2zGdpIE3cXrS(7AO5Vcmt5pl5SGtGqkQAxF9MOWpkat6pA7XB3LqjQFGYnyfrCLirT8imYcPLk5amGQ9vopYcwKnud5)jgwM70vQH9wFWMAA0i12zmTbe0pkOijsjkeTm9YTrvE6VY8Up8WxVsPRwTT5SgLNJ8AWTZ6DzSE93y(zIk16XCi7(TN3gU9VFv4)d9RcFlo9PgcO7hjELFvoC0Wt9lv)KdNieQB(okFitpjh1NKO9UElJp0xbFbhpdE2Jtjw0RPD1do1dAq36Ol9eysf)u(GKxx)rZAE2Hed9WGxxX4zth)IMlT3dCUZ6zxHzZgPmX1epO1OZlYrrNVU7Mo15puVL6DkCBTa(pr6ZllGwdKiTKnd)Z9v9UDGYdhh1lq6GpdgeO5nhxaFfw(d5O58Pt09DZN63a8AaDpxPe2XY2LUh0VuRkk75ow4ctnhp6bOLX4pZQ8(iu8zsdkY9igTF)FIYTnjTlp83TAnPXG(KEnXBLRa)s1GvkM5)R9dDRcyi(0uRkZX3Jdl5de(f5sJV6T9y1OJRm41)13qRjN(aTY0swXp7RLg6FAFuARdTo0UsMQLPZiCQTQBB8Kw3XtyXi(p2pYSDa(e79XnvALQUiaF4hoVEpg5dFQLYl8WXNoZv6fRVq8vRH(hI(T0fSWk7qTxoONvXuo(Rz(zQ9361oCC44HBTDewHNU(t5tIAhak2pfOU0eWhI5b(lqxTkLOGVxQDDu9xW6e8X(KS2HTwP5tuQlAo)mLBCV1kkdqr491yfuQMTIR)mSkhxq1cN09t0C76N(6A9tZJPAhozSR91oqgov3JZ)j6vsTdqdpeigafF3ouTYwLAsF338ugv(9aIlU5tJQl9og0REzL4oUwUrHNEIXT)H3NM0oa48(QLYYTIptVcPnUWkEyCzALrcDzdhE17MC6lOlA1R()(d]] )


end
