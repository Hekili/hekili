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


    spec:RegisterPack( "Shadow", 20220501, [[dm1u0cqivipsfWLqPcjBss6tOuvJssPtjPyvOuPEfePzrjCluQi7sIFjjyyuj6yuIwgevptfOMgefxdcyBujW3GGQXbbQZHsf16KeL3HsfsnpukDpQu7dI4FOuH6GsIQfIsXdHO0eLe5IujOncbLpIsL0ivbIoPKqSsQKEPkqWmvbs3ecKDQc1pLesdvfuhvfi0srPs8uuzQsQCviiBvfKVkjuJfLkO9Qk)vLgmPdl1IPIhdYKP4YeBguFgvnAk1PfwnkvGxlPQztv3gs7wPFRy4O44uj0YbEoutx01vvBxf9DuY4rPkNhcTEuQqmFkP9J8ZYxDpotNY7yK7sKJCxIaU0YcYTebS0YhxIiJ84yAO6BE5XTnQ844SBZW6XX0i6N28Q7XHNpasEC2zYGRSkub(iT)ofObTc4a977mMfc0WzfWbkufECo)WNvK9584mDkVJrUlroYDjc4slli3seWsxIGFC9pThWJJlqr2hNDymY(CECgbd944SBZWI0ddcbNKRvodi8KIC2zlif5Ue5iNCLCfzT7LxWvg5k7eP1Xs66j9qtyiTUbaKnjLLTSKMnGxssHM)MysBGqk8aGetHCLDI0ddKuwdPMjXK2aH0pdPSSLL0Sb8sIjTbcPq(blKMdPgeJL3csXdPPDNKU)6fmPnqifNH3tkqGguuznIP848boXV6ECODSV6EhB5RUhNSTJxmp284GarkGOFCoFy4IZm7DGVPTCBmKSgXu(mpoCccO8DSLpUgkJzFCqT3FBOmM96dC(48boVBJkpoNz2x(og5V6ECY2oEX8yZJdcePaI(XDePzd4LSe4lJVruapUgkJzFCMaZi(lAZhqV8D8b)Q7XjB74fZJnpUgkJzFCNtyUc4ZKXSpoJGHabtgZ(4qiSq6HMWqQle8zYywsNLuOz8MH1skZm(y5jTts9sJtsrocqAS4EJersRDaKImUKu4bqkB8Zyi1f6HjDwshgzfqnK68ts3jjnGjfX5tkRW7jDofauZqAS4EJersJL0dHWkKIG66fsXFGqkNDBgwWHSMkGGI14iRraK2RHueuSgszJVXjPbM0zjfAgVzyTK6iWdqi9qUqsdys5SBZWc23OcPbMuXf)bdJykKwr43biKYmJpwEsbcobbugZIjnGj9JJLNuo72mSG9nQq6HbbgL0EnKYgzncG0at68ZYJdcePaI(XD2GOD8sHzg)fEaxidM0QKwlPXI7nsejfjUjf5iaPiL0Aj1seGu2nP1skOHKIJFgZv8WKwL0mqfszlPhSljTgsRHuRwjLrYcCiRP0qzCkKwLuWFf4bWlfSDBgwW(gvUmGaJwex8hmmIH0QKEePqZ4ndRTGgR564BCw(mKwL0JifAgVzyTfSDBgwxwdWCnsN2LpdP1qAvsRL0yX9gjIKYw3KIGrasTAL0S9YMfS0Gy5VBWBNOnqkY2oEXqAvspBq0oEPGLgel)DdE7eTbYf6NdmmP1qAvspIuOz8MH1wGdznLpdPvjTwspIu889oXAkNJVZWlx84pLnlY2oEXqQvRK68HHlNJVZWlx84pLnlFgsTALuSKzS84sWVdqU4XFkBsAnV8DmY8Q7XjB74fZJnpUgkJzFCy72mSUSgG5Y0X(4mcgcemzm7Jdb11lKI)aHueNpPm)K0pdPCvCLDysRCUk)WKolPPTqA2aEjjnGjTIbDAd)9KIWAbecPbEz)K0gkJtHuw2YskCWBNXYtQLSthmPzd4LexECqGifq0poNpmCbULl)VbMOxC5ZqAvspIuJ48HHlSaDAd)9x4waHu(mKwLumJ493Sb8sIlOXAUyPbKYwsrMx(ogbE194KTD8I5XMhxdLXSpo0ynxS0Ghheisbe9JlBVSzblniw(7g82jAdKISTJxmKwLumJ493Sb8sIlOXAUyPbKIespBq0oEPGgR5ILgCH(5adtAvspIuZKfSDBgwxwdWCz6ylzavFS8KwL0JifAgVzyTf4qwt5ZqAvsXmI3FZgWljUGgR5ILgqksCtkY84GqeYl3Sb8sIFhB5lFh7cE194KTD8I5XMhxdLXSpoO27VnugZE9boFC(aN3TrLhhKb)Y3Xi8xDpozBhVyES5X1qzm7JdnwZfln4XbHiKxUzd4Le)o2Yhheisbe9JlBVSzblniw(7g82jAdKISTJxmKwLumJ493Sb8sIlOXAUyPbKIespBq0oEPGgR5ILgCH(5adtAvspIuZKfSDBgwxwdWCz6ylzavFS8KwL0JifAgVzyTf4qwt5Z84mcgcemzm7J7Gm4Tj9WGyarIiPiOynKYjnG0gkJzjnhsbcmqW2KwPPomPSI0MuS0Gy5VBWBNOnqE57ye8RUhNSTJxmp284AOmM9XzA0TZy2hheIqE5MnGxs87ylFCqGifq0pUAj1mz5SrzcqaDZ5dzxacmqW2TJxi1QvsntwW2TzyDznaZLPJTaeyGGTBhVqQvRKwlPhrQZhgUGgR5AKZ5deq5ZqAvsJf3BKiskBjfbCjP1qAnKwL0Aj15ddxmnO(BApFE7SGZgQEszlPoFy4IPb1Ft75ZBNf0M9U4SHQNuRwj9isXsEDM9JlziaKJGViNbI0AECgbdbcMmM9XDyGalasZH0pwiTsn62zmlPvoxLFysdys5Q4k7WKoaspuDKgys3jj9Zq6aifX5tkuV7KKc14K0M0DaOTN0kjNZhelpPh238FH0AJfY)nXYtkckwdPvsoNpqaKYagiCnK2RHueNpPScVN0DssHAgsRudQN06SNpVDIjfNnu9ysdys)4y5jToKJGjf5mqLx(oMD(v3Jt22XlMhBECnugZ(4W2TzyDznaZ1iDA)4mcgcemzm7JdHWcPC2TzyrAfpadPvs60M0aM0powEs5SBZWc23OcPhgeyus71qQJSgbqkRW7jvypMaiKA(Gy5jnTfsxH9ss5HmLhheisbe9JJrYcCiRP0qzCkKwLuWFf4bWlfSDBgwW(gvUmGaJwex8hmmIH0QKYizboK1uacAhlMu26MuEidPvjfZiE)nBaVK4cASMlwAaPS1nPi8x(o2sx(Q7XjB74fZJnpUgkJzFCOXAUo(gNpoJGHabtgZ(4QCpRgrmPFSqkASghFJtmPbmPqndJyiTxdP2)LxaXYt65egsdmPFgs71q6hhlpPC2Tzyb7BuH0ddcmkP9Ai1rwJainWK(zkKsALBmrgZ2EpIwqkuJtsrJ144BCsAatkIZNuwZ3Bi1ri9VTJxinhs5LK00wifeWjPoiskRoYy5jTjLhYuECqGifq0pUAjfAgVzyTf0ynxhFJZcKDd4fmPiHuljTkP1sQrC(WWf7)YlGy5VNtykFgsTAL0JinBVSzX(V8ciw(75eMISTJxmKwdPwTskJKf4qwtbiODSyszRBsHACEZavifPKYdziTgsRskJKf4qwtPHY4uiTkPG)kWdGxky72mSG9nQCzabgTiU4pyyedPvjLrYcCiRPae0owmPiHuOgN3mqfsRskMr8(B2aEjXf0ynxS0aszRBsr4KA1kPoFy4IPb1Ft75ZBNLpdPvj15ddxoNWapa0YNH0QKEePqZ4ndRTCoH56m(S8ziTkP1s6rKc(RapaEPGTBZWc23OYLbey0I4I)GHrmKA1kPhrkJKf4qwtPHY4uiTgsRskwYRZSFCjdbGCe8fzyGE57ylT8v3Jt22XlMhBECnugZ(4oNWCDgF(4mcgcemzm7JdHWcPhAcdPSz8jPDsQDWBlaszaXaIerszfPnPhK)LxaXYt6HMWq6NH0CifzinBaVKyliDaKoPTainBVSjM0zjLRUYJdcePaI(XflU3irKu26MuemcqAvsZ2lBwS)lVaIL)EoHPiB74fdPvjnBVSzblniw(7g82jAdKISTJxmKwLumJ493Sb8sIlOXAUyPbKYw3K6ci1QvsRL0AjnBVSzX(V8ciw(75eMISTJxmKwL0JinBVSzblniw(7g82jAdKISTJxmKwdPwTskMr8(B2aEjXf0ynxS0asDtQLKwZlFhBjYF194KTD8I5XMhxdLXSpoJCoFqS8xgFZ)LhNrWqGGjJzFCCmcu0EsRKCoFqS8KEyFZ)fszfPnPCsdILN0JdE7eTbcPSSLL0pU5fsnFqS8KISZ4ndRf)4GarkGOFC1skwYRZSFCjdbGCe8fzyGi1QvsZ2lBwS)lVaIL)EoHPiB74fdP1qAvsZ2lBwWsdIL)UbVDI2aPiB74fdPvjLrYcCiRP0qzCkKwLuWFf4bWlfSDBgwW(gvUmGaJwex8hmmIH0QK68HHlNtyGhaA5ZqAvsXmI3FZgWljUGgR5ILgqkBDtQl4LVJT8GF194KTD8I5XMhxdLXSpoJCoFqS8xgFZ)LhNrWqGGjJzFCvAw2pj9JfsRKCoFqS8KEyFZ)fsdysrC(Kc1lP8ssAS5q6HMWapausJfNsBSG0bqAatkN0Gy5j94G3orBGqAGjnBVSPyiTxdPScVNu7ijv25ZBtA2aEjXLhheisbe9JRwsbcmqW2TJxi1QvsJf3BKisksifHJaKA1kPz7LnlNtyU5aaYMfzBhVyiTkPqZ4ndRTCoH5MdaiBwacAhlMu26M0dMu2nP8qgsRH0QKwlPhr6zdI2XlfMz8x4bCHmysTAL0yX9gjIKIe3KIGrasRH0QKwlPhrA2EzZcwAqS83n4Tt0gifzBhVyi1QvsRL0S9YMfS0Gy5VBWBNOnqkY2oEXqAvspI0ZgeTJxkyPbXYF3G3orBGCH(5adtAnKwZlFhBjY8Q7XjB74fZJnpUgkJzFCNtyUoJpFCgbdbcMmM9XHqyH0dXgsNLuKTsKgWKI48j1ml7NKUIyinhsHACsALKZ5dILN0d7B(VybP9AinTfGqAdes9cgtAA3lPidPzd4Let68tsRfbiLvK2KcnR5hznLhheisbe9JdZiE)nBaVK4cASMlwAaPSL0AjfzifPKcnR5hzXey8S9MxbYEeCr22XlgsRH0QKglU3irKu26MuemcqAvsZ2lBwWsdIL)UbVDI2aPiB74fdPwTs6rKMTx2SGLgel)DdE7eTbsr22XlMx(o2se4v3Jt22XlMhBECnugZ(4W2TzyDznaZ1iDA)4GqeYl3Sb8sIFhB5JdcePaI(XvlPzd4LSylTpTlmqjPSLuK7ssRskMr8(B2aEjXf0ynxS0aszlPidP1qQvRKwlPmswGdznLgkJtH0QKc(RapaEPGTBZWc23OYLbey0I4I)GHrmKwLumJ493Sb8sIlOXAUyPbKYw3KIWjTMhNrWqGGjJzFCiewiLZUndlsR4byQmsRK0PnPbmPPTqA2aEjjnWK2oZpjnhsnHq6aifX5tQDFkKYz3MHfSVrfspmiWOKkU4pyyedPSI0MueuSghzncG0bqkNDBgwWHSgsBOmoLYlFhBPl4v3Jt22XlMhBECnugZ(4WFaqwJaU5CrBZky8JdcriVCZgWlj(DSLpoiqKci6hx2aEjlzGk3CUMqiLTKICxsAvsD(WWLZjmWdaTygw7JZiyiqWKXSpoeclKY9bazncG0Cifb1MvWysNL0M0Sb8ssAA3jPbMu(jwEsZHutiK2jPPTqki4TtsZavkV8DSLi8xDpozBhVyES5X1qzm7J7CcZnhaq28XbHiKxUzd4Le)o2Yhheisbe9J7Sbr74LIzs89ZqAvsRLuNpmC5Ccd8aqlMH1sQvRK68HHlNtyGhaAbiODSyszlPqZ4ndRTCoH56m(Sae0owmPwTskdqoV8qMILLZjmxNXNKwL0Ji15ddxC8Zy8FCwasdLKwLumJ493Sb8sIlOXAUyPbKYwspysRH0QKE2GOD8s5mX3MHXhIH0QKIzeV)MnGxsCbnwZflnGu2sATKIaKIusRLuxaPSBsZ2lBwswboVd8fUtPiB74fdP1qAnpoJGHabtgZ(4qiSq6HMWqADdaiBs6SEejnGjLRIRSdtAVgspuDK2aH0gkJtH0EnKM2cPzd4LKuwZY(jPMqi18bXYtAAlKcz37k(YlFhBjc(v3Jt22XlMhBECqGifq0pUAjnBVSzblniw(7g82jAdKISTJxmKwLumJ493Sb8sIlOXAUyPbKIespBq0oEPGgR5ILgCH(5adtQvRKAMSGTBZW6YAaMlthBjdO6JLN0AiTkPNniAhVuot8Tzy8HyECnugZ(4qJ14iRraV8DSLSZV6ECY2oEX8yZJRHYy2hh2UndRlRbyUgPt7hNrWqGGjJzFCiewiLRIRSkrkRiTj9WDSoaPRxaKEyC7rj9VEbJjnTfsZgWljPScVNuhHuhXpSif5UKDuK6iWdqinTfsHMXBgwlPqdQGj1PHQV84GarkGOFCG)kWdGxkmDSoaPRxaxgC7rlIl(dggXqAvspBq0oEPyMeF)mKwL0Sb8swYavU5CzGYlYDjPiH0AjfAgVzyTfSDBgwxwdWCnsN2fZh0zmlPiLuEidP18Y3Xi3LV6ECY2oEX8yZJRHYy2hh2UndRleOX2poJGHabtgZ(4qiSqkNDBgwKISGgBt6SKISvI0)6fmM00wacPnqiTngmPXcnOXYxECqGifq0poqhMRCkBwAJbxILuKqQLU8LVJrULV6ECY2oEX8yZJdcePaI(XHzeV)MnGxsCbnwZflnGuKq6zdI2Xlf0ynxS0Gl0phyysRsQZhgUyAq930E(82z5Z84mcgcemzm7JdHWcPiOynKYjnG0CifAw8hviTsnOEsRZE(82jMugWaHjDwsR8kQlSqADv0kvrjfzNfoaOKgyst7atAGjTj1o4TfaPmGyarIiPPDVKceZKzS8KolPvEf1fs6F9cgtQPb1tAApFE7etAGjTDMFsAoKMbQq68ZhheIqE5MnGxs87ylFCXMca8zYBa)4YaQEmsCJmpUytba(m5nqrft0P84S8Xbz3X(4S8X1qzm7JdnwZfln4LVJroYF194KTD8I5XMhNrWqGGjJzFCiewifbfRHueMVrK0CifAw8hviTsnOEsRZE(82jMugWaHjDws5QJ05N4WiKoWKEiew5XbbIuar)4C(WWftdQ)M2ZN3olFgsRs6zdI2XlfZK47NH0QKEePoFy4Y5eg4bGw(mKwL0Ji9Sbr74LcZm(l8aUqgmPvjfAgVzyTf0ynxhFJZc837VabYUb8YnduHuK4MuEitbTzVhxSPaaFM8gWpUmGQhJe3it1JC(WWftdQ)M2ZN3olFMhxSPaaFM8gOOIj6uECw(4GS7yFCw(4AOmM9XHgR5c7BeF57yKFWV6ECY2oEX8yZJRHYy2hhASMRJVX5JZiyiqWKXSpoeclKIGI1qkB8nojnGjfX5tQzw2pjDfXqAoKceyGGTjTstD4cPC5WqkuJZy5jTtsrgshaPOdqinBaVKyszfPnPCsdILN0JdE7eTbcPz7LnfdP9AifX5tAdes3jj9JJLNuo72mSG9nQq6HbbgL0bq6HXiczhqKEqJT(cMr8(B2aEjXf0ynxS0aKWogbiLxsmPPTqkASb6hL0bMueG0EnKM2cP7h1raKoWKMnGxsCH0k3Jhli1mKUtskdqWysrJ144BCs6FZWtA79KMnGxsmPnqi1mzkgszfPnPhQoszzllPFCS8KITBZWc23OcPmGaJsAatQJSgbqAGjTp7W3oEP84GarkGOFCNniAhVumtIVFgsRskOdZvoLnlOZPGkBwILuKqkuJZBgOcPiLuxwqasRskMr8(B2aEjXf0ynxS0aszlP1skYqksjf5KYUjnBVSzbnWcaXISTJxmKIusBOmoLRzYYzJYeGa6MZhYMu2nPz7LnlmyeHSdORp26lY2oEXqksjTwsXmI3FZgWljUGgR5ILgqksyhtkcqAnKYUjTwszKSahYAknugNcPvjf8xbEa8sbB3MHfSVrLldiWOfXf)bdJyiTgsRH0QKwlPhrk4Vc8a4Lc2UndlyFJkxgqGrlIl(dggXqQvRKEePqZ4ndRTahYAkFgsRsk4Vc8a4Lc2UndlyFJkxgqGrlIl(dggXqQvRKE2GOD8s5mX3MHXhIH0AE57yKJmV6ECY2oEX8yZJRHYy2h3zJYeGa6MZhY(XbHiKxUzd4Le)o2Yhheisbe9JdiWabB3oEH0QKMnGxYsgOYnNRjesrIBsTebtAvsRLuZKLZgLjab0nNpKDjdO6JLNuRwj9ispBq0oEPCM4BZW4dXqAnKwL0ZgeTJxkOn7DptmPiHuxsQvRKwlPz7LnlObwaiwKTD8IH0QKAMSGTBZW6YAaMlthBbiWabB3oEH0Ai1QvsD(WWL)c)b(y5VMgu)kyC5Z84mcgcemzm7JJDrGbc2M0d1OmbiGiTU5dztkRalEej1PXIH0zjTsn62zmlP9AiDsBbqADTx2exE57yKJaV6ECY2oEX8yZJRHYy2hh2UndRlRbyUmDSpoJGHabtgZ(44yeOO9KcnRjYywsZHuComKc14mwEs5Q4k7WKolPdmm7u2aEjXKYYwwsHdE7mwEspyshaPOdqifNnu9IHu0XbtAVgs)4y5j9WyeHSdispOXwpP9Ai94kADKIGcSaqS84GarkGOFCabgiy72XlKwL0Sb8swYavU5CnHqksifziTkPhrA2EzZcAGfaIfzBhVyiTkPz7LnlmyeHSdORp26lY2oEXqAvsXmI3FZgWljUGgR5ILgqksif5V8DmYDbV6ECY2oEX8yZJRHYy2hh2UndRlRbyUmDSpoieH8YnBaVK43Xw(4GarkGOFCabgiy72XlKwL0Sb8swYavU5CnHqksifziTkPhrA2EzZcAGfaIfzBhVyiTkPhrATKMTx2SGLgel)DdE7eTbsr22XlgsRskMr8(B2aEjXf0ynxS0asrcPNniAhVuqJ1CXsdUq)CGHjTgsRsATKEePz7LnlmyeHSdORp26lY2oEXqQvRKwlPz7LnlmyeHSdORp26lY2oEXqAvsXmI3FZgWljUGgR5ILgqkBDtkYjTgsR5XzemeiyYy2h3bbryiLRIRSdt6NH0zjTXKI2lIKMnGxsmPnMuMbJdhVybPc7bjmjPSSLLu4G3oJLN0dM0bqk6aesXzdvVyifDCWKYksBspmgri7aI0dAS1xE57yKJWF194KTD8I5XMhxdLXSpoyVGTHanC(4Infa4ZK3a(XLbu9yK42YhxSPaaFM8gOOIj6uECw(4GarkGOFC457DI1uohFNHxU4XFkBwKTD8IH0QKEePoFy4Y5eg4bGw(mKwL0Ji15ddxygwc4gl8hhZw(mKwLuNpmC5C8DgE5Ih)PSzbiODSyszlPw6YhNrWqGGjJzFCiewifH5fSneOHtsNFIdJq6atkAhlPqZ4ndRftAoKI2XMDSKEOX3z4fs5g)PSjPoFy4YlFhJCe8RUhNSTJxmp284AOmM9XHgR5ILg84GqeYl3Sb8sIFhB5Jl2uaGptEd4hxgq1JrIBK)4Infa4ZK3afvmrNYJZYhheisbe9JdZiE)nBaVK4cASMlwAaPiH0ZgeTJxkOXAUyPbxOFoWWpoi7o2hNLV8DmYzNF194KTD8I5XMhxdLXSpo0ynxyFJ4Jl2uaGptEd4hxgq1JrIBKxT2JC(WWftdQ)M2ZN3olFgRwHMXBgwB5CcZ1z8z5ZuTwNpmC5Ccd8aqlFgRwpY5ddxmnO(BApFE7S8zQ68HHlMaJNT38kq2JGlFMAQ5XfBkaWNjVbkQyIoLhNLpoi7o2hNLV8D8b7YxDpozBhVyES5XzemeiyYy2hhcHfs5Q4kRsK2ys9nojfi4bKKgWKolPPTqk6CkpUgkJzFCy72mSUSgG5AKoTF574d2YxDpozBhVyES5XzemeiyYy2hhcHfs5Q4k7WK2ys9nojfi4bKKgWKolPPTqk6CkK2RHuUkUYQePbM0zjfzR0JRHYy2hh2UndRlRbyUmDSV8LpoJa3FF(Q7DSLV6ECY2oEX8yZJZiyiqWKXSpoxi7jq)umKkNcarsZavinTfsBOCaKgys7Zo8TJxkpUgkJzFC4WllK8Y3Xi)v3Jt22XlMhBECqGifq0poNpmC5Ccd8aqlFgsTALuNpmCHzyjGBSWFCmB5Z84AOmM9XXmzm7lFhFWV6ECY2oEX8yZJByECyjFCnugZ(4oBq0oE5XD2(V84QLuZKfSDBgwxwdWCz6ylzavFS8KA1kPzd4LSKbQCZ5AcHu26MuKH0AiTkP1sQzYYzJYeGa6MZhYUKbu9XYtQvRKMnGxYsgOYnNRjeszRBsDbKwZJ7Sb3TrLhNzs89Z8Y3XiZRUhNSTJxmp284gMhhwYhxdLXSpUZgeTJxECNT)lpUZgeTJxkMjX3pdPvjTwsntwmY58bXYFz8n)xkzavFS8KA1kPzd4LSKbQCZ5AcHu26MuKH0AECNn4UnQ84AV)AMeF)mV8Dmc8Q7XjB74fZJnpUH5XHL8X1qzm7J7Sbr74Lh3z7)YJdZiE)nBaVK4cASMlwAaPiHuKtksj15ddxoNWapa0YN5XzemeiyYy2hhx2GK0powEs5KgelpPhh82jAdes7K0dgPKMnGxsmPdGuKbPKgWKI48jTbcPXs6HMWapa0h3zdUBJkpoS0Gy5VBWBNOnqUq)CGHF57yxWRUhNSTJxmp284gMhhwYhxdLXSpUZgeTJxECNT)lpUAj9isb)vGhaVuWm2cqWx7gGolIfXf)bdJyiTkPhrk0CkBVzzfiW4hGHuRwjfAgVzyTfMHLaUXc)XXSfGG2XIjLTUjLhYuqB2Ju2nPhmPwTsQZhgUWmSeWnw4poMT8zi1QvsDgmM0QKch825fiODSyszRBsrocqAnpUZgC3gvECqMlAVnVGkB(Y3Xi8xDpozBhVyES5XnmpoSKpUgkJzFCNniAhV84oB)xECygX7Vzd4LexoBuMaeq3C(q2pUZgC3gvECOn7Dpt8lFhJGF194KTD8I5XMh3W84Ws(4AOmM9XD2GOD8YJ7S9F5XHaKIusroPSBsRL0ZgeTJxkqMlAVnVGkBsAvsHMXBgwB5CcZvaFMmMTae0owmPS1nPw6ssRH0QKMTx2Sy)xEbel)9Cctr22XlMhheisbe9JlBVSzblniw(7g82jAdKISTJxmKwLumJ493Sb8sIlOXAUyPbK6Mue(J7Sb3TrLhhAZE3Ze)Y3XSZV6ECY2oEX8yZJByECyjFCnugZ(4oBq0oE5XD2(V84C5JdcePaI(XLTx2SGLgel)DdE7eTbsr22XlgsRskMr8(B2aEjXf0ynxS0asrcPi8h3zdUBJkpo0M9UNj(LVJT0LV6ECY2oEX8yZJByECyjFCnugZ(4oBq0oE5XD2(V84qMhheisbe9JlBVSzblniw(7g82jAdKISTJxmKwLumJ493Sb8sIlOXAUyPbK6MuemPvj9isZ2lBwW2TzyDHan2UiB74fZJ7Sb3TrLhhAZE3Ze)Y3XwA5RUhNSTJxmp284gMhhwYhxdLXSpUZgeTJxECNT)lpUAjfZiE)nBaVK4cASMlwAaPS1nPiaP1qk7MumJ493Sb8sIlOXAUyPbpoiqKci6hNZhgUCoHbEaOLpZJ7Sb3TrLhhAZE3Ze)Y3XwI8xDpozBhVyES5XnmpoSKpUgkJzFCNniAhV84oB)xECU8Xze4(7ZhNLpUZgC3gvECb(EMxMbJdhV8Y3XwEWV6ECY2oEX8yZJByECyjFCnugZ(4oBq0oE5XD2(V84S8XbbIuar)4AOmoLRzYYzJYeGa6MZhYMu2skeIqE5kRGgc(XD2G72OYJlW3Z8YmyC44Lx(o2sK5v3Jt22XlMhBECdZJdl5JRHYy2h3zdI2XlpUZ2)LhxdLXPCntwoBuMaeq3C(q2KIe3KE2GOD8sbTzV7zIj1QvspI0ZgeTJxkb(EMxMbJdhV84oBWDBu5XDM4BZW4dX8Y3XwIaV6ECY2oEX8yZJByECyjFCnugZ(4oBq0oE5XD2(V84GMXBgwB5CcZvaFMmMT8ziTkPNniAhVuGmx0EBEbv28XzemeiyYy2hhYoJ3mSwsp8mEspudI2XlwqkcHfdP5qkZmEsDe4biK2qzC2zS8KEOjmWdaT84oBWDBu5XXmJ)cpGlKb)Y3Xw6cE194KTD8I5XMhheisbe9JZ5ddxygwc4gl8hhZw(mKA1kPqZ4ndRTWmSeWnw4poMTae0owmPiH0gkJzlmdlbCJf(JJzlqZ4ndRLu2jsT0LpUgkJzFCo(zmx4paXx(o2se(RUhNSTJxmp284GarkGOFCoFy4Y5eg4bGw(mpUgkJzFCWbqC8ZyE57ylrWV6ECY2oEX8yZJdcePaI(X58HHlNtyGhaA5Z84AOmM9X5iaSaQpw(x(o2s25xDpozBhVyES5X1qzm7JZh82j(Yo4B4rLnFCgbdbcMmM9XHqyH0dAWBNSpMux)gEuztsdystBbiK2aHuKt6aifDacPzd4LeBbPdG02yWK2azz)KumtZAJLNu4bqk6aest7EjfHJa4YJdcePaI(XHzeV)MnGxsCXh82j(Yo4B4rLnjfjUjf5KA1kP1s6rKc6WCLtzZsBm4IWEboXKA1kPGomx5u2S0gdUelPiHueocqAnV8DmYD5RUhNSTJxmp284GarkGOFCoFy4Y5eg4bGw(mpUgkJzFC9cj4e0(lu79V8DmYT8v3Jt22XlMhBECnugZ(4GAV)2qzm71h48X5dCE3gvECqSGE57yKJ8xDpozBhVyES5X1qzm7Jd83BdLXSxFGZhNpW5DBu5XH2X(Yx(4Gyb9Q7DSLV6ECY2oEX8yZJdcePaI(XHL86m7hxYqaihbFrggisRsQZhgUyAq930E(82z5ZqAvszKSahYAknugNcPvjf8xbEa8sbB3MHfSVrLldiWOfXf)bdJyiTkPhrQZhgUCoHbEaOLpdPvjLrYcIZhCX2TzyvacAhlMu2skCWBNxGG2XIj1QvsD(WWftdQ)M2ZN3olFgsRskJKfeNp4ITBZWQae0owmPSLuEitbTzpsz3KwlPhmPiL0Aj9isD(WWLZjmWdaT8ziTgsz3KAPlG0AiTkPmswqC(Gl2UndRcqq7yXKYwsHdE78ce0ow8JBwpIxiwqpolFCgbdbcMmM9XvhYrWKImStyjjfAwtKXSTNu4bqkYwXilPiOynKYgFJZhxdLXSpo0ynxhFJZx(og5V6ECY2oEX8yZJ7JLll7WlxOgNXY)o2YhxdLXSpoS0Gy5VBWBNOnqECqic5LB2aEjXVJT8XbbIuar)4QL0ZgeTJxkyPbXYF3G3orBGCH(5adtAvspI0ZgeTJxkmZ4VWd4czWKwdPwTsATKAMSGTBZW6YAaMlthBbiWabB3oEH0QKIzeV)MnGxsCbnwZflnGuKqQLKwZJZiyiqWKXSpoeclKYjniwEspo4Tt0giKgWKI48jLv49KAhjPYoFEBsZgWljM0EnKE4HLaiTISWFCmlP9Ai9qtyGhakPnqiDNKuG0geTG0bqAoKceyGGTjLRIRSdt6SKMSgshaPOdqinBaVK4YlFhFWV6ECY2oEX8yZJ7JLll7WlxOgNXY)o2YhxdLXSpoS0Gy5VBWBNOnqECqic5LB2aEjXVJT8XbbIuar)4Y2lBwWsdIL)UbVDI2aPiB74fdPvj1mzbB3MH1L1amxMo2cqGbc2UD8cPvjfZiE)nBaVK4cASMlwAaPiHuK)4mcgcemzm7JJZEajPiBaG(rskN0Gy5j94G3orBGqk0SMiJzjnhsRxegs5Q4k7WK(zinwsR8Xf(Y3XiZRUhNSTJxmp284M1J4fIf0JZYhxdLXSpo0ynxhFJZhNrWqGGjJzFCZ6r8cXcIu0UEbtAAlK2qzmlPZ6rK0pUD8cPMpiwEsHS7DfFS8K2RH0DssBmPnPaH)7BaPnugZwE5lFCqg8RU3Xw(Q7XjB74fZJnpUgkJzFCmdlbCJf(JJzFCgbdbcMmM9XHqyH0dpSeaPvKf(JJzjLvK2KEOjmWdaTq6b54nKcpasp0eg4bGsk0GkyshyysHMXBgwlPXsAAlKUc7LKAPljflqZAWKoPTayfyH0pwiDwsHmK(xVGXKM2cPm(grbqAGjLPbjPdmPPTqA9icIEjfAoLT30cshaPbmPPTaeszfEpP7KK6iK27K2cG0dnHHuxi4ZKXSKM2bMu4G3olKw5zkOmjP5qkgXfI00wi134KuMHLainw4poML0bM00wifo4TtsZH0ZjmKkGptgZsk8aiDNL0dcicIEXLhheisbe9JJbecolyXdFzgwc4gl8hhZsAvsRLuNpmC5Ccd8aqlFgsTAL0JifAoLT3SupIGOxsRs6rKcnNY2Bwwbcm(byiTkPqZ4ndRTCoH5kGptgZwacAhlMuK4MulDjPwTskCWBNxGG2XIjLTKcnJ3mS2Y5eMRa(mzmBbiODSysRH0QKwlPWbVDEbcAhlMuK4MuOz8MH1woNWCfWNjJzlabTJftksj1seG0QKcnJ3mS2Y5eMRa(mzmBbiODSyszRBs5HmKYUjfzi1QvsHdE78ce0owmPiHuOz8MH1wygwc4gl8hhZwmFqNXSKA1kPodgtAvsHdE78ce0owmPSLuOz8MH1woNWCfWNjJzlabTJftksj1seGuRwjfAoLT3SupIGOxsTALuNpmCXXpJX)Xz5ZqAnV8DmYF194KTD8I5XMhNrWqGGjJzFCiewiLnTHxinwCyeshyspecJu4bqAAlKchaCs6hlKoasNLuKTsK2WPainTfsHdaoj9JLcPvCK2KECWBNKIWAHu7XBifEaKEiew5XTnQ84WXc)9xEFBIoha(60gE5oWxybmqrI4JdcePaI(X58HHlNtyGhaA5ZqQvRKMbQqksi1sxsAvsRL0JifAoLT3SSbVDEHBH0AECnugZ(4WXc)9xEFBIoha(60gE5oWxybmqrI4lFhFWV6ECY2oEX8yZJRHYy2hhClx(FdmrV4hNrWqGGjJzFCiewifH1cPSR)gyIEXKolPiBLiD(jomcPdmPhAcd8aqlKIqyHuewlKYU(BGj61Gjnwsp0eg4bGsAatkIZNu7(uivI0waKYUcMtH0kYEg8dOZywshaPiSq8gshyszJFW4bfxiTI7ijfEaKAMetAoK6iK(zi1rGhGqAdLXzNXYtkcRfszx)nWe9IjnhsrB2lqdSqAAlK68HHlpoiqKci6h3rK68HHlNtyGhaA5ZqAvsRL0JifAgVzyTLZjm3CaazZYNHuRwj9isZ2lBwoNWCZbaKnlY2oEXqAnKwL0Aj9Sbr74LIzs89ZqAvsXmI3FZgWljUC2OmbiGU58HSj1nPwsQvRKE2GOD8s5mX3MHXhIH0QKIzeV)MnGxsC5SrzcqaDZ5dztksi1ssRHuRwj15ddxoNWapa0YNH0QKwlP457DI1u4bZPCJ9m4hqNXSfzBhVyi1QvsXZ37eRPahI3Ch4RJFW4bfxKTD8IH0AE57yK5v3Jt22XlMhBECnugZ(4qJ1W3Oc(XbHiKxUzd4Le)o2Yhheisbe9JlwCVrIiPSLu2zxsAvsRL0Aj9Sbr74Ls79xZK47NH0QKwlPhrk0mEZWAlNtyUc4ZKXSLpdPwTs6rKMTx2Sy)xEbel)9Cctr22XlgsRH0Ai1QvsD(WWLZjmWdaT8ziTgsRsATKEePz7Lnl2)LxaXYFpNWuKTD8IHuRwj1ioFy4I9F5fqS83ZjmfGG2XIjfjKc148MbQqQvRKEePoFy4Y5eg4bGw(mKwdPvjTwspI0S9YMfS0Gy5VBWBNOnqkY2oEXqQvRKIzeV)MnGxsCbnwZflnGu2skcqAnpoJGHabtgZ(4qiSqkckwdFJkyszzllPT3t6btALM6WK2aH0pJfKoasrC(K2aH0yj9qtyGhaAHux4I)aH0dY)YlGy5j9qtyiLv49KIZW7j1ri9ZqklBzjnTfsHACsAgOcPWXgyBbxiLlhgs)4y5jTtsraKsA2aEjXKYksBs5KgelpPhh82jAdKYlFhJaV6ECY2oEX8yZJRHYy2h3FThpI3Do7hNrWqGGjJzFCiewifHw7XJiPhpNnPZskYwjli1E8My5j1becShrsZHuwDKKcpaszgwcG0yH)4ywshaPTXqkMPzT4YJdcePaI(XDePz7Lnl2)LxaXYFpNWuKTD8IH0QKE2GOD8sXmj((zi1QvsnIZhgUy)xEbel)9Cct5ZqAvsD(WWLZjmWdaT8zi1QvsRLuOz8MH1woNWCfWNjJzlabTJftksi1sxsQvRKEePNniAhVuyMXFHhWfYGjTgsRs6rK68HHlNtyGhaA5Z8Y3XUGxDpozBhVyES5X1qzm7JZzM9oW30wUngswJyECgbdbcMmM9XHqyH0zjfzRePo)KugqmGidSq6hhlpPhAcdPUqWNjJzjfoa40csdys)yXqAS4WiKoWKEiegPZskxDK(XcPnCkasBspNW4m(Ku4bqk0mEZWAjvGHdOqwiejTxdPWdGu7)YlGy5j9CcdPFMmqfsdysZ2lBkMYJdcePaI(XDePoFy4Y5eg4bGw(mKwL0JifAgVzyTLZjmxb8zYy2YNH0QKIzeV)MnGxsCbnwZflnGuKqQLKwL0JinBVSzblniw(7g82jAdKISTJxmKA1kP1sQZhgUCoHbEaOLpdPvjfZiE)nBaVK4cASMlwAaPSLuKtAvspI0S9YMfS0Gy5VBWBNOnqkY2oEXqAvsRLugGCE5HmfllNtyUoJpjTkP1s6rKkU4pyyetrqzqeiT)oaZ2lKqQvRKEePz7Lnl2)LxaXYFpNWuKTD8IH0Ai1Qvsfx8hmmIPiOmicK2FhGz7fsiTkPqZ4ndRTiOmicK2FhGz7fskabTJftkBDtQLUaKtAvsnIZhgUy)xEbel)9Cct5ZqAnKwdPwTsATK68HHlNtyGhaA5ZqAvsZ2lBwWsdIL)UbVDI2aPiB74fdP18Y3Xi8xDpozBhVyES5X1qzm7JdQ9(BdLXSxFGZhNpW5DBu5XLGyRxs8lFhJGF194KTD8I5XMhheisbe9JZwAFAxyGsszRBsr4iWJRHYy2hNrWmcOt5YaAefWlF5JlbXwVK4xDVJT8v3Jt22XlMhBECgbdbcMmM9XHqyH0eeB9ssAdNcGuMV3tkoBqIjTxdPPTSKolPiBLiTHtbqAA3jP)ndpPioFs5LKuKjTjfNnu9fsRdGiP5qQr8nIKYlzglpPiqAtkoBO6jfEaKcnJ3mSwCHueclK6iWdqiDsBbq6SK(XcP5q6ojPji45faPveKTsK6ijlrwstqS1ljM0AD(8SJRP842gvECyOgGVd8fg0Pa22FXjiGLhheisbe9JRwspIuNpmCbd1a8DGVWGofW2(lobbSCrMYNH0QKMbQqksi1ssRHuRwjTwsD(WWLZjmWdaT8zi1QvsD(WWfMHLaUXc)XXSLpdPwTsk0mEZWAlNtyUc4ZKXSfGG2XIjfjKAPljTgsTALuO5u2EZYg825fULhxdLXSpomudW3b(cd6uaB7V4eeWYlFhJ8xDpozBhVyES5XzemeiyYy2hhcHfsNLuKTsKw5Cv(Hjnhs5LK0kn1rAgq1hlpP9AivypMaiKMdP(yfs)mK6izkaszfPnPhAcd8aqFCBJkpobLbrG0(7amBVqYJdcePaI(XbnJ3mS2Y5eMRa(mzmBbiODSyszRBsTe5KA1kPqZ4ndRTCoH5kGptgZwacAhlMuKqkYr4pUgkJzFCckdIaP93by2EHKx(o(GF194KTD8I5XMhNrWqGGjJzFC1bqK0CiLdXfI0kYbXkrkRiTjTsZ3XlKYLnu9IHuKTsysdyszgmoC8sH0k6sQFwEbqkCWBNyszfPnPOdqiTICqSsK(XcM0otbLjjnhsXiUqKYksBs7frsHmKoaszh8XjPFSqAKLh32OYJlwme4NTJxUU4V38JEnYzajpoiqKci6hNZhgUCoHbEaOLpdPvj15ddxygwc4gl8hhZw(mKA1kPodgtAvsHdE78ce0owmPS1nPi3LKA1kPoFy4cZWsa3yH)4y2YNH0QKcnJ3mS2Y5eMRa(mzmBbiODSysrkPwIaKIesHdE78ce0owmPwTsQZhgUCoHbEaOLpdPvjfAgVzyTfMHLaUXc)XXSfGG2XIjfPKAjcqksifo4TZlqq7yXKA1kP1sk0mEZWAlmdlbCJf(JJzlabTJftksCtQLUK0QKcnJ3mS2Y5eMRa(mzmBbiODSysrIBsT0LKwdPvjfo4TZlqq7yXKIe3KAj7SlFCnugZ(4Ifdb(z74LRl(7n)OxJCgqYlFhJmV6ECY2oEX8yZJZiyiqWKXSpooexis5Sfjjfb9XbePSI0M0dnHbEaOpUTrLhhAd1oa5ITfjVOFCa94GarkGOFCqZ4ndRTCoH5kGptgZwacAhlMuKqQLU8X1qzm7JdTHAhGCX2IKx0poGE57ye4v3Jt22XlMhBECBJkpo889EjZy5VGVdIpoieH8YnBaVK43Xw(4AOmM9XHNV3lzgl)f8Dq8XbbIuar)4C(WWfMHLaUXc)XXSLpdPwTs6rKYacbNfS4HVmdlbCJf(JJzj1Qvsfx8hmmIPGTBZWsm3b4Ch4BoauzZhNrWqGGjJzFCCiUqKYU8DqKuwrAt6HhwcG0kYc)XXSK(XnVybPOD9cP4pqinhsXBWiKM2cP(HLGtspipmPzd4LSqAfBllPFSyiLvK2KYz3MHLyiTIcCiDGjTUbGkBAbPSd(4K0pwiDwsr2krAJjf9dztAJjLzW4WXlLx(o2f8Q7XjB74fZJnpoJGHabtgZ(4qybaNKYf8HNumA79KomzGgSJ0zmlPSI0MuU579sMXYtk7Y3bXh32OYJlTLlCaW5fh8H)XbbIuar)4C(WWLZjmWdaT8zi1QvsD(WWfMHLaUXc)XXSLpdPwTs6rKYacbNfS4HVmdlbCJf(JJzj1QvsHMXBgwB5CcZvaFMmMTae0owmPiHulDjPwTsATKkU4pyyetbpFVxYmw(l47GiPvj9isHMXBgwBbpFVxYmw(l47Gy5ZqAnKA1kPodgtAvsHdE78ce0owmPSLuK7YhxdLXSpU0wUWbaNxCWh(x(ogH)Q7XjB74fZJnpoJGHabtgZ(4qiSqkBAdVqAS4WiKoWKEiegPWdG00wifoa4K0pwiDaKolPiBLiTHtbqAAlKchaCs6hlfs5ShqskuaG(rsAat65egsfWNjJzjfAgVzyTKgysT0LyshaPOdqiTz1iwECBJkpoCSWF)L33MOZbGVoTHxUd8fwaduKi(4GarkGOFCqZ4ndRTCoH5kGptgZwacAhlMuK4MulD5JRHYy2hhow4V)Y7Bt05aWxN2Wl3b(clGbkseF57ye8RUhNSTJxmp284mcgcemzm7JdHWcPC2TzyjgsROahshysRBaOYMKYYwws3jjnwsp0eg4bGAbPdG0yj1rswISKEOjmKYMXNKc14etASKEOjmWdaTqALJj9GaIGOxshaPhlqGXpadP(yfsJK0pdPSI0MuC2q1lgsHMXBgwlU842gvECy72mSeZDao3b(Mdav28XbbIuar)4GMXBgwBHzyjGBSWFCmBbiODSyszRBsT0LKwLuOz8MH1woNWCfWNjJzlabTJftkBDtQLUK0QKwlPqZPS9MLvGaJFagsTALuO5u2EZs9icIEjTgsTAL0AjfAoLT3SCkBAJiGuRwjfAoLT3SSbVDEHBH0AiTkP1s6rK68HHlNtyGhaA5ZqQvRKYaKZlpKPyz5CcZ1z8jP1qQvRK6mymPvjfo4TZlqq7yXKYw3KImU8X1qzm7JdB3MHLyUdW5oW3CaOYMV8Dm78RUhNSTJxmp284AOmM9X1ai7ifOeFJLx2FKiEHgG84mcgcemzm7JdHWcPPDGjDwsr2krk8aifTzpsr2kXU842gvECnaYosbkX3y5L9hjIxObiV8DSLU8v3Jt22XlMhBECnugZ(4(y5gPGIFCgbdbcMmM9XvjbU)(Ku427DAO6jfEaK(XTJxinsbfxzKIqyH0zjfAgVzyTKglPdWiasDqK0eeB9ssk2pz5XbbIuar)4C(WWLZjmWdaT8zi1QvsD(WWfMHLaUXc)XXSLpdPwTsk0mEZWAlNtyUc4ZKXSfGG2XIjfjKAPlF5lFCoZSV6EhB5RUhNSTJxmp284GarkGOFCygX7Vzd4LexqJ1CXsdiLTUj9GFCnugZ(4AmKSgXCD8noF57yK)Q7XjB74fZJnpUgkJzFCngswJyU7C2poJGHabtgZ(4QORhrs)yH0khdjRrmKE8C2KYYwws3jjnBVSPyin2CiLtAqS8KECWBNOnqiDwsrosjnBaVK4YJdcePaI(XHzeV)MnGxsCPXqYAeZDNZMuKqQLKwLumJ493Sb8sIlOXAUyPbKIesTK0QKEePz7LnlyPbXYF3G3orBGuKTD8I5LV8XXaeOb1PZxDVJT8v3Jt22XlMhBECqGifq0poGG2XIjLTKEWU0LpUgkJzFCmdlbCznaZfEazKFJ8Y3Xi)v3Jt22XlMhBECqGifq0po889oXAkmFC(9YvaFMmMTiB74fdPwTskE(ENynLZX3z4LlE8NYMfzBhVyECnugZ(4G9c2gc0W5lFhFWV6ECY2oEX8yZJdcePaI(XDePoFy4c2Undl4bGw(mpUgkJzFCy72mSGha6lFhJmV6ECY2oEX8yZJdcePaI(XflU3irSye4akssrcPwIapUgkJzFCnaQx5MdaiB(Y3XiWRUhNSTJxmp2842gvECy72mSeZDao3b(Mdav28X1qzm7JdB3MHLyUdW5oW3CaOYMV8DSl4v3Jt22XlMhBECdZJdl5JRHYy2h3zdI2XlpUZ2)LhhYFCNn4UnQ84qJ1CXsdUq)CGHF57ye(RUhNSTJxmp284GarkGOFChrA2EzZIPr3oJzlY2oEX84AOmM9XD2OmbiGU58HSF57ye8RUhNSTJxmp284GarkGOFCz7LnlMgD7mMTiB74fZJRHYy2hhASMRJVX5lF5lFCNcahZ(og5Ue5i3LhSLUGhhRgSXYJFCvCLZUCCf5y21kJusRZwinqzgqsk8aiL9tqS1ljM9jfiU4paIHu8GkK2)Cq7umKcz3lVGlKRh0yfsDbvgPi7SNcifdPSFcITEjlTdubAgVzyTSpP5qk7dnJ3mS2s7aX(KwRLSxnfYvY1kUYzxoUICm7ALrkP1zlKgOmdijfEaKY(mabAqD6K9jfiU4paIHu8GkK2)Cq7umKcz3lVGlKRh0yfsrELrkYo7PasXqk7JNV3jwtHDi7tAoKY(457DI1uyhwKTD8IH9jTwlzVAkKRh0yfsrELrkYo7PasXqk7JNV3jwtHDi7tAoKY(457DI1uyhwKTD8IH9jTtsDHv0dkP1Aj7vtHCLCTIRC2LJRihZUwzKsAD2cPbkZassHhaPSpAhl7tkqCXFaedP4bviT)5G2PyifYUxEbxixpOXkKEWvgPi7SNcifdPSpE(ENynf2HSpP5qk7JNV3jwtHDyr22Xlg2N0ATK9QPqUEqJvif5i8kJuKD2tbKIHu2hpFVtSMc7q2N0CiL9XZ37eRPWoSiB74fd7tATwYE1uixjxR4kND54kYXSRvgPKwNTqAGYmGKu4bqk7dzWSpPaXf)bqmKIhuH0(NdANIHui7E5fCHC9GgRqQlOYifzN9uaPyiL9tqS1lzPDGkqZ4ndRL9jnhszFOz8MH1wAhi2N0ATK9QPqUsUwrqzgqkgsr4K2qzmlP(aN4c56JdZiqVJrocGGFCmGbo8YJ7ahGuo72mSi9WGqWj56boaPvodi8KIC2zlif5Ue5iNCLC9ahGuK1UxEbxzKRh4aKYorADSKUEsp0egsRBaaztszzllPzd4LKuO5VjM0giKcpaiXuixpWbiLDI0ddKuwdPMjXK2aH0pdPSSLL0Sb8sIjTbcPq(blKMdPgeJL3csXdPPDNKU)6fmPnqifNH3tkqGguuznIPqUsUEGdqQlK9eOFkgsDe4biKcnOoDsQJWhlUqALdbjmjM0Dw2j7gGc)9K2qzmlM0z9iwixBOmMfxyac0G60jsDxbMHLaUSgG5cpGmYVrSiGDde0owmBpyx6sY1gkJzXfgGanOoDIu3va2lyBiqdNweWUXZ37eRPW8X53lxb8zYywRwXZ37eRPCo(odVCXJ)u2KCTHYywCHbiqdQtNi1DfW2Tzybpaulcy3h58HHly72mSGhaA5ZqU2qzmlUWaeOb1PtK6UcnaQx5MdaiBAra7owCVrIyXiWbuKiXseGCTHYywCHbiqdQtNi1Df(y5gPGAX2OIBSDBgwI5oaN7aFZbGkBsU2qzmlUWaeOb1PtK6UcNniAhVyX2OIB0ynxS0Gl0phyylgg3yjT4S9FXnYjxBOmMfxyac0G60jsDxHZgLjab0nNpKTfbS7JY2lBwmn62zmBr22XlgY1gkJzXfgGanOoDIu3vanwZ1X340Ia2D2EzZIPr3oJzlY2oEXqUsUEasDHSNa9tXqQCkaejnduH00wiTHYbqAGjTp7W3oEPqU2qzml2no8YcjKRh4aKE4jJzXKRnugZIDZmzmRfbSBNpmC5Ccd8aqlFgRwD(WWfMHLaUXc)XXSLpd5AdLXSyK6UcNniAhVyX2OIBZK47NXIHXnwsloB)xCxRzYc2UndRlRbyUmDSLmGQpwERwZgWlzjdu5MZ1ecBDJm1uTwZKLZgLjab0nNpKDjdO6JL3Q1Sb8swYavU5CnHWw3UGAixBOmMfJu3v4Sbr74fl2gvC3E)1mj((zSyyCJL0IZ2)f3NniAhVumtIVFMQ1AMSyKZ5dIL)Y4B(VuYaQ(y5TAnBaVKLmqLBoxtiS1nYud56biLlBqs6hhlpPCsdILN0JdE7eTbcPDs6bJusZgWljM0bqkYGusdysrC(K2aH0yj9qtyGhak5AdLXSyK6UcNniAhVyX2OIBS0Gy5VBWBNOnqUq)CGHTyyCJL0IZ2)f3ygX7Vzd4LexqJ1CXsdqcYrQZhgUCoHbEaOLpd5AdLXSyK6UcNniAhVyX2OIBiZfT3MxqLnTyyCJL0IZ2)f31Ee4Vc8a4LcMXwac(A3a0zrSiU4pyyet1JGMtz7nlRabg)amwTcnJ3mS2cZWsa3yH)4y2cqq7yXS1npKPG2Sh7(GTA15ddxygwc4gl8hhZw(mwT6myCv4G3oVabTJfZw3ihbQHCTHYywmsDxHZgeTJxSyBuXnAZE3ZeBXW4glPfNT)lUXmI3FZgWljUC2OmbiGU58HSjxBOmMfJu3v4Sbr74fl2gvCJ2S39mXwmmUXsAXz7)IBeaPiNDx7zdI2XlfiZfT3MxqLnRcnJ3mS2Y5eMRa(mzmBbiODSy262sxwt1S9YMf7)YlGy5VNtykY2oEXyra7oBVSzblniw(7g82jAdKISTJxmvXmI3FZgWljUGgR5ILg4gHtU2qzmlgPURWzdI2XlwSnQ4gTzV7zITyyCJL0IZ2)f3U0Ia2D2EzZcwAqS83n4Tt0gifzBhVyQIzeV)MnGxsCbnwZflnajiCY1gkJzXi1DfoBq0oEXITrf3On7DptSfdJBSKwC2(V4gzSiGDNTx2SGLgel)DdE7eTbsr22XlMQygX7Vzd4LexqJ1CXsdCJGREu2EzZc2UndRleOX2fzBhVyixBOmMfJu3v4Sbr74fl2gvCJ2S39mXwmmUXsAXz7)I7AXmI3FZgWljUGgR5ILgWw3iqnSBmJ493Sb8sIlOXAUyPbweWUD(WWLZjmWdaT8zixBOmMfJu3v4Sbr74fl2gvCh47zEzgmoC8IfdJBSKwC2(V42Lwye4(7t3wsU2qzmlgPURWzdI2XlwSnQ4oW3Z8YmyC44flgg3yjT4S9FXTLweWUBOmoLRzYYzJYeGa6MZhYMTqic5LRScAiyY1gkJzXi1DfoBq0oEXITrf3Nj(2mm(qmwmmUXsAXz7)I7gkJt5AMSC2OmbiGU58HSrI7ZgeTJxkOn7DptSvRhD2GOD8sjW3Z8YmyC44fY1dqkYoJ3mSwsp8mEspudI2XlwqkcHfdP5qkZmEsDe4biK2qzC2zS8KEOjmWdaTqU2qzmlgPURWzdI2XlwSnQ4Mzg)fEaxid2IHXnwsloB)xCdnJ3mS2Y5eMRa(mzmB5Zu9Sbr74LcK5I2BZlOYMKRnugZIrQ7k44NXCH)aeTiGD78HHlmdlbCJf(JJzlFgRwHMXBgwBHzyjGBSWFCmBbiODSyK0qzmBHzyjGBSWFCmBbAgVzyTStw6sY1gkJzXi1DfGdG44NXyra725ddxoNWapa0YNHCTHYywmsDxbhbGfq9XYBra725ddxoNWapa0YNHC9aKIqyH0dAWBNSpMux)gEuztsdystBbiK2aHuKt6aifDacPzd4LeBbPdG02yWK2azz)KumtZAJLNu4bqk6aest7EjfHJa4c5AdLXSyK6Uc(G3oXx2bFdpQSPfbSBmJ493Sb8sIl(G3oXx2bFdpQSjsCJCRwR9iqhMRCkBwAJbxe2lWj2QvqhMRCkBwAJbxIfjiCeOgY1gkJzXi1Df6fsWjO9xO27TiGD78HHlNtyGhaA5ZqU2qzmlgPURau793gkJzV(aNwSnQ4gIfe5AdLXSyK6UcG)EBOmM96dCAX2OIB0owYvY1dCasR8dFqjnhs)yHuw2YskBMzjDGjnTfsRCmKSgXqAGjTHY4uixBOmMfxCMzD3yiznI564BCAra7gZiE)nBaVK4cASMlwAaBDFWKRhG0k66rK0pwiTYXqYAedPhpNnPSSLL0DssZ2lBkgsJnhs5KgelpPhh82jAdesNLuKJusZgWljUqU2qzmlU4mZIu3vOXqYAeZDNZ2Ia2nMr8(B2aEjXLgdjRrm3DoBKyzvmJ493Sb8sIlOXAUyPbiXYQhLTx2SGLgel)DdE7eTbsr22XlgYvY1dCasr2kHjxpaPiewi9WdlbqAfzH)4ywszfPnPhAcd8aqlKEqoEdPWdG0dnHbEaOKcnOcM0bgMuOz8MH1sASKM2cPRWEjPw6ssXc0SgmPtAlawbwi9JfsNLuidP)1lymPPTqkJVruaKgyszAqs6atAAlKwpIGOxsHMtz7nTG0bqAatAAlaHuwH3t6ojPocP9oPTai9qtyi1fc(mzmlPPDGjfo4TZcPvEMcktsAoKIrCHinTfs9nojLzyjasJf(JJzjDGjnTfsHdE7K0Ci9CcdPc4ZKXSKcpas3zj9GaIGOxCHCTHYywCbYGDZmSeWnw4poM1Ia2ndieCwWIh(YmSeWnw4poMTAToFy4Y5eg4bGw(mwTEe0CkBVzPEebrVvpcAoLT3SScey8dWufAgVzyTLZjmxb8zYy2cqq7yXiXTLU0Qv4G3oVabTJfZwOz8MH1woNWCfWNjJzlabTJfxt1AHdE78ce0owmsCdnJ3mS2Y5eMRa(mzmBbiODSyKAjcufAgVzyTLZjmxb8zYy2cqq7yXS1npKHDJmwTch825fiODSyKanJ3mS2cZWsa3yH)4y2I5d6mM1QvNbJRch825fiODSy2cnJ3mS2Y5eMRa(mzmBbiODSyKAjcy1k0CkBVzPEebrVwT68HHlo(zm(polFMAixpaPiewiLl8YcjKolPiBLinhszadePCcJ9NDe2ht6HbdKVr7mMTqUEasBOmMfxGmyK6Uc4WllKyr2aEjVbSBWFf4bWlfSWy)zhbFzadKVr7mMTiU4pyyet1AZgWlzjW32ySAnBaVKfJ48HHlqnoJLVaKgkRHC9aKIqyHu20gEH0yXHriDGj9qimsHhaPPTqkCaWjPFSq6aiDwsr2krAdNcG00wifoa4K0pwkKwXrAt6XbVDskcRfsThVHu4bq6HqyfY1gkJzXfidgPURWhl3iful2gvCJJf(7V8(2eDoa81Pn8YDGVWcyGIerlcy3oFy4Y5eg4bGw(mwTMbQGelDz1ApcAoLT3SSbVDEHBPgY1dqkcHfsryTqk76VbMOxmPZskYwjsNFIdJq6at6HMWapa0cPiewifH1cPSR)gyIEnysJL0dnHbEaOKgWKI48j1UpfsLiTfaPSRG5uiTISNb)a6mML0bqkcleVH0bMu24hmEqXfsR4ossHhaPMjXKMdPocPFgsDe4biK2qzC2zS8KIWAHu21FdmrVysZHu0M9c0alKM2cPoFy4c5AdLXS4cKbJu3vaULl)VbMOxSfbS7JC(WWLZjmWdaT8zQw7rqZ4ndRTCoH5MdaiBw(mwTEu2EzZY5eMBoaGSzr22XlMAQw7zdI2XlfZK47NPkMr8(B2aEjXLZgLjab0nNpKTBlTA9Sbr74LYzIVndJpetvmJ493Sb8sIlNnktacOBoFiBKyznwT68HHlNtyGhaA5ZuTw889oXAk8G5uUXEg8dOZy2ISTJxmwTINV3jwtboeV5oWxh)GXdkUiB74ftnKRhGueclKIGI1W3OcMuw2YsA79KEWKwPPomPnqi9ZybPdGueNpPnqinwsp0eg4bGwi1fU4pqi9G8V8ciwEsp0egszfEpP4m8EsDes)mKYYwwstBHuOgNKMbQqkCSb2wWfs5YHH0powEs7KueaPKMnGxsmPSI0MuoPbXYt6XbVDI2aPqU2qzmlUazWi1DfqJ1W3Oc2cieH8YnBaVKy3wAra7owCVrIiBzNDz1AR9Sbr74Ls79xZK47NPAThbnJ3mS2Y5eMRa(mzmB5Zy16rz7Lnl2)LxaXYFpNWuKTD8IPMASA15ddxoNWapa0YNPMQ1Eu2EzZI9F5fqS83ZjmfzBhVySA1ioFy4I9F5fqS83ZjmfGG2XIrcuJZBgOIvRh58HHlNtyGhaA5Zut1ApkBVSzblniw(7g82jAdKISTJxmwTIzeV)MnGxsCbnwZflnGTiqnKRhGueclKIqR94rK0JNZM0zjfzRKfKApEtS8K6acb2JiP5qkRossHhaPmdlbqASWFCmlPdG02yifZ0SwCHCTHYywCbYGrQ7k8x7XJ4DNZ2Ia29rz7Lnl2)LxaXYFpNWuKTD8IP6zdI2XlfZK47NXQvJ48HHl2)LxaXYFpNWu(mvD(WWLZjmWdaT8zSATwOz8MH1woNWCfWNjJzlabTJfJelDPvRhD2GOD8sHzg)fEaxidUMQh58HHlNtyGhaA5ZqUEasriSq6SKISvIuNFskdigqKbwi9JJLN0dnHHuxi4ZKXSKchaCAbPbmPFSyinwCyeshyspecJ0zjLRos)yH0gofaPnPNtyCgFsk8aifAgVzyTKkWWbuileIK2RHu4bqQ9F5fqS8KEoHH0ptgOcPbmPz7LnftHCTHYywCbYGrQ7k4mZEh4BAl3gdjRrmweWUpY5ddxoNWapa0YNP6rqZ4ndRTCoH5kGptgZw(mvXmI3FZgWljUGgR5ILgGelREu2EzZcwAqS83n4Tt0gifzBhVySATwNpmC5Ccd8aqlFMQygX7Vzd4LexqJ1CXsdylYREu2EzZcwAqS83n4Tt0gifzBhVyQwldqoV8qMILLZjmxNXNvR9iXf)bdJykckdIaP93by2EHeRwpkBVSzX(V8ciw(75eMISTJxm1y1Q4I)GHrmfbLbrG0(7amBVqs1eeB9sweugebs7VdWS9cjfOz8MH1wacAhlMTUT0fG8QgX5ddxS)lVaIL)EoHP8zQPgRwR15ddxoNWapa0YNPA2EzZcwAqS83n4Tt0gifzBhVyQHCTHYywCbYGrQ7ka1E)THYy2RpWPfBJkUtqS1ljMCTHYywCbYGrQ7kyemJa6uUmGgrbyra72wAFAxyGs26gHJaKRKRh4aKISnojTITdVqkY24mwEsBOmMfxiLtss7Ku7G3waKYaIbejIKMdPy7bKKcfaOFKKgBkaWNjjfAwtKXSysNLueuSgs5KgubeMVrKC9aKwhYrWKImStyjjfAwtKXSTNu4bqkYwXilPiOynKYgFJtY1gkJzXfiwqUrJ1CD8noTywpIxiwqUT0ISb8sEdy3yjVoZ(XLmeaYrWxKHbQQZhgUyAq930E(82z5ZuLrYcCiRP0qzCkvb)vGhaVuW2Tzyb7Bu5YacmArCXFWWiMQh58HHlNtyGhaA5ZuLrYcIZhCX2TzyvacAhlMTWbVDEbcAhl2QvNpmCX0G6VP985TZYNPkJKfeNp4ITBZWQae0owmB5Hmf0M9y31EWiT2JC(WWLZjmWdaT8zQHDBPlOMQmswqC(Gl2UndRcqq7yXSfo4TZlqq7yXKRhGueclKYjniwEspo4Tt0giKgWKI48jLv49KAhjPYoFEBsZgWljM0EnKE4HLaiTISWFCmlP9Ai9qtyGhakPnqiDNKuG0geTG0bqAoKceyGGTjLRIRSdt6SKMSgshaPOdqinBaVK4c5AdLXS4celi3yPbXYF3G3orBGyXhlxw2HxUqnoJL3TLwaHiKxUzd4Le72slcy31E2GOD8sblniw(7g82jAdKl0phy4QhD2GOD8sHzg)fEaxidUgRwR1mzbB3MH1L1amxMo2cqGbc2UD8svmJ493Sb8sIlOXAUyPbiXYAixpaPC2dijfzda0pss5KgelpPhh82jAdesHM1ezmlP5qA9IWqkxfxzhM0pdPXsALpUqY1gkJzXfiwqi1DfWsdIL)UbVDI2aXIpwUSSdVCHACglVBlTacriVCZgWlj2TLweWUZ2lBwWsdIL)UbVDI2aPiB74ftvZKfSDBgwxwdWCz6ylabgiy72XlvXmI3FZgWljUGgR5ILgGeKtUEasN1J4fIfePOD9cM00wiTHYywsN1JiPFC74fsnFqS8Kcz37k(y5jTxdP7KK2ysBsbc)33asBOmMTqU2qzmlUaXccPURaASMRJVXPfZ6r8cXcYTLKRKRh4aKIG6yjTYp8b1csX2Z3BifAofaPT3tkOxEbt6atA2aEjXK2RHumKSnigm5AdLXS4cAhRBO27VnugZE9boTyBuXTZmRf4eeqPBlTiGD78HHloZS3b(M2YTXqYAet5ZqU2qzmlUG2XIu3vWeygXFrB(aYIa29rzd4LSe4lJVruaKRhGueclKEOjmK6cbFMmML0zjfAgVzyTKYmJpwEs7KuV04KuKJaKglU3irK0AhaPiJljfEaKYg)mgsDHEysNL0HrwbudPo)K0DssdysrC(KYk8EsNtba1mKglU3irK0yj9qiScPiOUEHu8hiKYz3MHfCiRPciOynoYAeaP9AifbfRHu24BCsAGjDwsHMXBgwlPoc8aespKlK0aMuo72mSG9nQqAGjvCXFWWiMcPve(DacPmZ4JLNuGGtqaLXSysdys)4y5jLZUndlyFJkKEyqGrjTxdPSrwJainWKo)SqU2qzmlUG2XIu3v4CcZvaFMmM1Ia29zdI2XlfMz8x4bCHm4Q1glU3irejUrocG0ATeby31cAiP44NXCfpC1mqf2EWUSMASALrYcCiRP0qzCkvb)vGhaVuW2Tzyb7Bu5YacmArCXFWWiMQhbnJ3mS2cASMRJVXz5Zu9iOz8MH1wW2TzyDznaZ1iDAx(m1uT2yX9gjIS1ncgbSAnBVSzblniw(7g82jAdKISTJxmvpBq0oEPGLgel)DdE7eTbYf6NdmCnvpcAgVzyTf4qwt5ZuT2JWZ37eRPCo(odVCXJ)u20QvNpmC5C8DgE5Ih)PSz5Zy1kwYmwECj43bix84pLnRHC9aKIG66fsXFGqkIZNuMFs6NHuUkUYomPvoxLFysNL00winBaVKKgWKwXGoTH)EsryTacH0aVSFsAdLXPqklBzjfo4TZy5j1s2PdM0Sb8sIlKRnugZIlODSi1DfW2TzyDznaZLPJ1Ia2TZhgUa3YL)3at0lU8zQEKrC(WWfwGoTH)(lClGqkFMQygX7Vzd4LexqJ1CXsdylYqU2qzmlUG2XIu3vanwZflnWcieH8YnBaVKy3wAra7oBVSzblniw(7g82jAdKISTJxmvXmI3FZgWljUGgR5ILgGKZgeTJxkOXAUyPbxOFoWWvpYmzbB3MH1L1amxMo2sgq1hlF1JGMXBgwBboK1u(mvXmI3FZgWljUGgR5ILgGe3id5AdLXS4cAhlsDxbO27VnugZE9boTyBuXnKbtUEaspidEBspmigqKiskckwdPCsdiTHYywsZHuGadeSnPvAQdtkRiTjflniw(7g82jAdeY1gkJzXf0owK6UcOXAUyPbwaHiKxUzd4Le72slcy3z7LnlyPbXYF3G3orBGuKTD8IPkMr8(B2aEjXf0ynxS0aKC2GOD8sbnwZfln4c9ZbgU6rMjly72mSUSgG5Y0XwYaQ(y5REe0mEZWAlWHSMYNHC9aKEyGalasZH0pwiTsn62zmlPvoxLFysdys5Q4k7WKoaspuDKgys3jj9Zq6aifX5tkuV7KKc14K0M0DaOTN0kjNZhelpPh238FH0AJfY)nXYtkckwdPvsoNpqaKYagiCnK2RHueNpPScVN0DssHAgsRudQN06SNpVDIjfNnu9ysdys)4y5jToKJGjf5mqfY1gkJzXf0owK6UcMgD7mM1cieH8YnBaVKy3wAra7UwZKLZgLjab0nNpKDbiWabB3oEXQvZKfSDBgwxwdWCz6ylabgiy72XlwTw7roFy4cASMRroNpqaLpt1yX9gjISfbCzn1uTwNpmCX0G6VP985TZcoBO6zRZhgUyAq930E(82zbTzVloBO6TA9iSKxNz)4sgca5i4lYzGQHC9aKIqyHuo72mSiTIhGH0kjDAtAat6hhlpPC2Tzyb7BuH0ddcmkP9Ai1rwJaiLv49KkShtaesnFqS8KM2cPRWEjP8qMc5AdLXS4cAhlsDxbSDBgwxwdWCnsN2weWUzKSahYAknugNsvWFf4bWlfSDBgwW(gvUmGaJwex8hmmIPkJKf4qwtbiODSy26MhYufZiE)nBaVK4cASMlwAaBDJWjxpaPvUNvJiM0pwifnwJJVXjM0aMuOMHrmK2RHu7)YlGy5j9CcdPbM0pdP9Ai9JJLNuo72mSG9nQq6HbbgL0EnK6iRraKgys)mfsjTYnMiJzBVhrlifQXjPOXAC8nojnGjfX5tkR57nK6iK(32XlKMdP8ssAAlKcc4KuhejLvhzS8K2KYdzkKRnugZIlODSi1DfqJ1CD8noTiGDxl0mEZWAlOXAUo(gNfi7gWlyKyz1AnIZhgUy)xEbel)9Cct5Zy16rz7Lnl2)LxaXYFpNWuKTD8IPgRwzKSahYAkabTJfZw3qnoVzGkiLhYutvgjlWHSMsdLXPuf8xbEa8sbB3MHfSVrLldiWOfXf)bdJyQYizboK1uacAhlgjqnoVzGkvXmI3FZgWljUGgR5ILgWw3iCRwD(WWftdQ)M2ZN3olFMQoFy4Y5eg4bGw(mvpcAgVzyTLZjmxNXNLpt1Apc8xbEa8sbB3MHfSVrLldiWOfXf)bdJySA9igjlWHSMsdLXPutvSKxNz)4sgca5i4lYWarUEasriSq6HMWqkBgFsANKAh82cGugqmGirKuwrAt6b5F5fqS8KEOjmK(zinhsrgsZgWlj2cshaPtAlasZ2lBIjDws5QRqU2qzmlUG2XIu3v4CcZ1z8PfbS7yX9gjIS1ncgbQMTx2Sy)xEbel)9Cctr22XlMQz7LnlyPbXYF3G3orBGuKTD8IPkMr8(B2aEjXf0ynxS0a262fy1AT1MTx2Sy)xEbel)9Cctr22XlMQhLTx2SGLgel)DdE7eTbsr22XlMASAfZiE)nBaVK4cASMlwAGBlRHC9aKYXiqr7jTsY58bXYt6H9n)xiLvK2KYjniwEspo4Tt0giKYYwws)4Mxi18bXYtkYoJ3mSwm5AdLXS4cAhlsDxbJCoFqS8xgFZ)flcy31IL86m7hxYqaihbFrggiRwZ2lBwS)lVaIL)EoHPiB74ftnvZ2lBwWsdIL)UbVDI2aPiB74ftvgjlWHSMsdLXPuf8xbEa8sbB3MHfSVrLldiWOfXf)bdJyQ68HHlNtyGhaA5ZufZiE)nBaVK4cASMlwAaBD7cixpaPvAw2pj9JfsRKCoFqS8KEyFZ)fsdysrC(Kc1lP8ssAS5q6HMWapausJfNsBSG0bqAatkN0Gy5j94G3orBGqAGjnBVSPyiTxdPScVNu7ijv25ZBtA2aEjXfY1gkJzXf0owK6Ucg5C(Gy5Vm(M)lweWURfiWabB3oEXQ1yX9gjIibHJawTMTx2SCoH5MdaiBwKTD8IPk0mEZWAlNtyU5aaYMfGG2XIzR7dMDZdzQPAThD2GOD8sHzg)fEaxid2Q1yX9gjIiXncgbQPAThLTx2SGLgel)DdE7eTbsr22XlgRwRnBVSzblniw(7g82jAdKISTJxmvp6Sbr74LcwAqS83n4Tt0gixOFoWW1ud56bifHWcPhInKolPiBLinGjfX5tQzw2pjDfXqAoKc14K0kjNZhelpPh238FXcs71qAAlaH0giK6fmM00UxsrgsZgWljM05NKwlcqkRiTjfAwZpYAkKRnugZIlODSi1DfoNWCDgFAra7gZiE)nBaVK4cASMlwAaBRfzqk0SMFKftGXZ2BEfi7rWfzBhVyQPAS4EJer26gbJavZ2lBwWsdIL)UbVDI2aPiB74fJvRhLTx2SGLgel)DdE7eTbsr22XlgY1dqkcHfs5SBZWI0kEaMkJ0kjDAtAatAAlKMnGxssdmPTZ8tsZHutiKoasrC(KA3NcPC2Tzyb7BuH0ddcmkPIl(dggXqkRiTjfbfRXrwJaiDaKYz3MHfCiRH0gkJtPqU2qzmlUG2XIu3vaB3MH1L1amxJ0PTfqic5LB2aEjXUT0Ia2DTzd4LSylTpTlmqjBrUlRIzeV)MnGxsCbnwZflnGTitnwTwlJKf4qwtPHY4uQc(RapaEPGTBZWc23OYLbey0I4I)GHrmvXmI3FZgWljUGgR5ILgWw3i8AixpaPiewiL7daYAeaP5qkcQnRGXKolPnPzd4LK00UtsdmP8tS8KMdPMqiTtstBHuqWBNKMbQuixBOmMfxq7yrQ7kG)aGSgbCZ5I2MvWylGqeYl3Sb8sIDBPfbS7Sb8swYavU5CnHWwK7YQoFy4Y5eg4bGwmdRLC9aKIqyH0dnHH06gaq2K0z9isAatkxfxzhM0EnKEO6iTbcPnugNcP9AinTfsZgWljPSML9tsnHqQ5dILN00wifYU3v8fY1gkJzXf0owK6UcNtyU5aaYMwaHiKxUzd4Le72slcy3NniAhVumtIVFMQ168HHlNtyGhaAXmSwRwD(WWLZjmWdaTae0owmBHMXBgwB5CcZ1z8zbiODSyRwzaY5LhYuSSCoH56m(S6roFy4IJFgJ)JZcqAOSkMr8(B2aEjXf0ynxS0a2EW1u9Sbr74LYzIVndJpetvmJ493Sb8sIlOXAUyPbSTweaP16cy3z7LnljRaN3b(c3PuKTD8IPMAixBOmMfxq7yrQ7kGgRXrwJaSiGDxB2EzZcwAqS83n4Tt0gifzBhVyQIzeV)MnGxsCbnwZflnajNniAhVuqJ1CXsdUq)CGHTA1mzbB3MH1L1amxMo2sgq1hlFnvpBq0oEPCM4BZW4dXqUEasriSqkxfxzvIuwrAt6H7yDasxVai9W42Js6F9cgtAAlKMnGxsszfEpPocPoIFyrkYDj7Oi1rGhGqAAlKcnJ3mSwsHgubtQtdvFHCTHYywCbTJfPURa2UndRlRbyUgPtBlcy3G)kWdGxkmDSoaPRxaxgC7rlIl(dggXu9Sbr74LIzs89ZunBaVKLmqLBoxgO8ICxIKAHMXBgwBbB3MH1L1amxJ0PDX8bDgZIuEitnKRhGueclKYz3MHfPilOX2KolPiBLi9VEbJjnTfGqAdesBJbtASqdAS8fY1gkJzXf0owK6Ucy72mSUqGgBBra7g0H5kNYML2yWLyrILUKC9aKIqyHueuSgs5KgqAoKcnl(JkKwPgupP1zpFE7etkdyGWKolPvEf1fwiTUkALQOKISZchausdmPPDGjnWK2KAh82cGugqmGirK00UxsbIzYmwEsNL0kVI6cj9VEbJj10G6jnTNpVDIjnWK2oZpjnhsZaviD(j5AdLXS4cAhlsDxb0ynxS0alGqeYl3Sb8sIDBPfbSBmJ493Sb8sIlOXAUyPbi5Sbr74LcASMlwAWf6NdmCvNpmCX0G6VP985TZYNXci7ow3wArSPaaFM8gOOIj6uCBPfXMca8zYBa7odO6XiXnYqUEGdqADv0kvrRmsjfzTfO6jnTdmPiOynKIW8nIKgOmEbv2SZywsZHuSiKgWKgjPoaPRht6K2cGuW8ZyfsHS7DfpM0bMueuSgsry(gr2rtkAJiPRigsZHu0UEH00oWK6aKU(MxiDwpIKYAa1tkRiTjnTfsXssQZSFCHC9aKIqyHueuSgsry(grsZHuOzXFuH0k1G6jTo75ZBNyszadeM0zjLRosNFIdJq6at6HqyfY1gkJzXf0owK6UcOXAUW(grlcy3oFy4IPb1Ft75ZBNLpt1ZgeTJxkMjX3pt1JC(WWLZjmWdaT8zQE0zdI2XlfMz8x4bCHm4QqZ4ndRTGgR564BCwG)E)fiq2nGxUzGkiXnpKPG2SNfq2DSUT0Iytba(m5nqrft0P42slInfa4ZK3a2Dgq1JrIBKP6roFy4IPb1Ft75ZBNLpd56bifHWcPiOynKYgFJtsdysrC(KAML9tsxrmKMdPabgiyBsR0uhUqkxomKc14mwEs7KuKH0bqk6aesZgWljMuwrAtkN0Gy5j94G3orBGqA2EztXqAVgsrC(K2aH0Dss)4y5jLZUndlyFJkKEyqGrjDaKEymIq2bePh0yRVGzeV)MnGxsCbnwZflnajSJras5LetAAlKIgBG(rjDGjfbiTxdPPTq6(rDeaPdmPzd4LexiTY94XcsndP7KKYaemMu0yno(gNK(3m8K2EpPzd4LetAdesntMIHuwrAt6HQJuw2Ys6hhlpPy72mSG9nQqkdiWOKgWK6iRraKgys7Zo8TJxkKRnugZIlODSi1DfqJ1CD8noTiGDF2GOD8sXmj((zQc6WCLtzZc6CkOYMLyrcuJZBgOcsDzbbQIzeV)MnGxsCbnwZflnGT1Imif5S7S9YMf0alaelY2oEXG0gkJt5AMSC2OmbiGU58HSz3z7LnlmyeHSdORp26lY2oEXG0AXmI3FZgWljUGgR5ILgGe2XiqnS7AzKSahYAknugNsvWFf4bWlfSDBgwW(gvUmGaJwex8hmmIPMAQw7rG)kWdGxky72mSG9nQCzabgTiU4pyyeJvRhbnJ3mS2cCiRP8zQc(RapaEPGTBZWc23OYLbey0I4I)GHrmwTE2GOD8s5mX3MHXhIPgY1dqk7IadeSnPhQrzcqarADZhYMuwbw8isQtJfdPZsALA0TZyws71q6K2cG06AVSjUqU2qzmlUG2XIu3v4SrzcqaDZ5dzBbeIqE5MnGxsSBlTiGDdeyGGTBhVunBaVKLmqLBoxtiiXTLi4Q1AMSC2OmbiGU58HSlzavFS8wTE0zdI2XlLZeFBggFiMAQE2GOD8sbTzV7zIrIlTAT2S9YMf0alaelY2oEXu1mzbB3MH1L1amxMo2cqGbc2UD8snwT68HHl)f(d8XYFnnO(vW4YNHC9aKYXiqr7jfAwtKXSKMdP4CyifQXzS8KYvXv2HjDwshyy2PSb8sIjLLTSKch82zS8KEWKoasrhGqkoBO6fdPOJdM0EnK(XXYt6HXiczhqKEqJTEs71q6Xv06ifbfybGyHCTHYywCbTJfPURa2UndRlRbyUmDSweWUbcmqW2TJxQMnGxYsgOYnNRjeKGmvpkBVSzbnWcaXISTJxmvZ2lBwyWiczhqxFS1xKTD8IPkMr8(B2aEjXf0ynxS0aKGCY1dq6bbryiLRIRSdt6NH0zjTXKI2lIKMnGxsmPnMuMbJdhVybPc7bjmjPSSLLu4G3oJLN0dM0bqk6aesXzdvVyifDCWKYksBspmgri7aI0dAS1xixBOmMfxq7yrQ7kGTBZW6YAaMlthRfqic5LB2aEjXUT0Ia2nqGbc2UD8s1Sb8swYavU5CnHGeKP6rz7LnlObwaiwKTD8IP6r1MTx2SGLgel)DdE7eTbsr22XlMQygX7Vzd4LexqJ1CXsdqYzdI2Xlf0ynxS0Gl0phy4AQw7rz7LnlmyeHSdORp26lY2oEXy1ATz7LnlmyeHSdORp26lY2oEXufZiE)nBaVK4cASMlwAaBDJ8AQHC9aKIqyHueMxW2qGgojD(jomcPdmPODSKcnJ3mSwmP5qkAhB2Xs6HgFNHxiLB8NYMK68HHlKRnugZIlODSi1DfG9c2gc0WPfbSB889oXAkNJVZWlx84pLnREKZhgUCoHbEaOLpt1JC(WWfMHLaUXc)XXSLptvNpmC5C8DgE5Ih)PSzbiODSy2APlTi2uaGptEduuXeDkUT0Iytba(m5nGDNbu9yK42sY1gkJzXf0owK6UcOXAUyPbwaHiKxUzd4Le72slcy3ygX7Vzd4LexqJ1CXsdqYzdI2Xlf0ynxS0Gl0phyylGS7yDBPfXMca8zYBGIkMOtXTLweBkaWNjVbS7mGQhJe3iNCTHYywCbTJfPURaASMlSVr0ci7ow3wArSPaaFM8gOOIj6uCBPfXMca8zYBa7odO6XiXnYRw7roFy4IPb1Ft75ZBNLpJvRqZ4ndRTCoH56m(S8zQwRZhgUCoHbEaOLpJvRh58HHlMgu)nTNpVDw(mvD(WWftGXZ2BEfi7rWLptn1qUEasriSqkxfxzvI0gtQVXjPabpGK0aM0zjnTfsrNtHCTHYywCbTJfPURa2UndRlRbyUgPtBY1dqkcHfs5Q4k7WK2ys9nojfi4bKKgWKolPPTqk6CkK2RHuUkUYQePbM0zjfzRe5AdLXS4cAhlsDxbSDBgwxwdWCz6yjxjxpaPiewinbXwVKK2WPaiL579KIZgKys71qAAllPZskYwjsB4uaKM2Ds6FZWtkIZNuEjjfzsBsXzdvFH06aisAoKAeFJiP8sMXYtkcK2KIZgQEsHhaPqZ4ndRfxifHWcPoc8aesN0waKolPFSqAoKUtsAccEEbqAfbzRePosYsKL0eeB9sIjTwNpp74AkKRnugZIlji26Le7(JLBKcQfBJkUXqnaFh4lmOtbST)ItqalweWUR9iNpmCbd1a8DGVWGofW2(lobbSCrMYNPAgOcsSSgRwR15ddxoNWapa0YNXQvNpmCHzyjGBSWFCmB5Zy1k0mEZWAlNtyUc4ZKXSfGG2XIrILUSgRwHMtz7nlBWBNx4wixpaPiewiDwsr2krALZv5hM0CiLxssR0uhPzavFS8K2RHuH9ycGqAoK6Jvi9ZqQJKPaiLvK2KEOjmWdaLCTHYywCjbXwVKyK6UcFSCJuqTyBuXTGYGiqA)DaMTxiXIa2n0mEZWAlNtyUc4ZKXSfGG2XIzRBlrUvRqZ4ndRTCoH5kGptgZwacAhlgjihHtUEasRdGiP5qkhIlePvKdIvIuwrAtALMVJxiLlBO6fdPiBLWKgWKYmyC44LcPv0Lu)S8cGu4G3oXKYksBsrhGqAf5GyLi9JfmPDMcktsAoKIrCHiLvK2K2lIKcziDaKYo4Jts)yH0ilKRnugZIlji26LeJu3v4JLBKcQfBJkUJfdb(z74LRl(7n)OxJCgqIfbSBNpmC5Ccd8aqlFMQoFy4cZWsa3yH)4y2YNXQvNbJRch825fiODSy26g5U0QvNpmCHzyjGBSWFCmB5ZufAgVzyTLZjmxb8zYy2cqq7yXi1seajWbVDEbcAhl2QvNpmC5Ccd8aqlFMQqZ4ndRTWmSeWnw4poMTae0owmsTebqcCWBNxGG2XITATwOz8MH1wygwc4gl8hhZwacAhlgjUT0LvHMXBgwB5CcZvaFMmMTae0owmsCBPlRPkCWBNxGG2XIrIBlzNDj56biLdXfIuoBrssrqFCarkRiTj9qtyGhak5AdLXS4scITEjXi1Df(y5gPGAX2OIB0gQDaYfBlsEr)4aYIa2n0mEZWAlNtyUc4ZKXSfGG2XIrILUKC9aKYH4crk7Y3brszfPnPhEyjasRil8hhZs6h38IfKI21lKI)aH0CifVbJqAAlK6hwcoj9G8WKMnGxYcPvSTSK(XIHuwrAtkNDBgwIH0kkWH0bM06gaQSPfKYo4Jts)yH0zjfzRePnMu0pKnPnMuMbJdhVuixBOmMfxsqS1ljgPURWhl3iful2gvCJNV3lzgl)f8Dq0cieH8YnBaVKy3wAra725ddxygwc4gl8hhZw(mwTEedieCwWIh(YmSeWnw4poM1QvXf)bdJyky72mSeZDao3b(Mdav2KC9aKIWcaojLl4dpPy027jDyYanyhPZywszfPnPCZ37LmJLNu2LVdIKRnugZIlji26LeJu3v4JLBKcQfBJkUtB5chaCEXbF4TiGD78HHlNtyGhaA5Zy1QZhgUWmSeWnw4poMT8zSA9igqi4SGfp8LzyjGBSWFCmRvRqZ4ndRTCoH5kGptgZwacAhlgjw6sRwRvCXFWWiMcE(EVKzS8xW3bXQhLGyRxYcE(EVKzS8xW3bXc0mEZWAlFMASA1zW4QWbVDEbcAhlMTi3LKRhGueclKYM2WlKglomcPdmPhcHrk8ainTfsHdaoj9JfshaPZskYwjsB4uaKM2cPWbaNK(XsHuo7bKKcfaOFKKgWKEoHHub8zYywsHMXBgwlPbMulDjM0bqk6aesBwnIfY1gkJzXLeeB9sIrQ7k8XYnsb1ITrf34yH)(lVVnrNdaFDAdVCh4lSagOir0Ia2n0mEZWAlNtyUc4ZKXSfGG2XIrIBlDj56bifHWcPC2TzyjgsROahshysRBaOYMKYYwws3jjnwsp0eg4bGAbPdG0yj1rswISKEOjmKYMXNKc14etASKEOjmWdaTqALJj9GaIGOxshaPhlqGXpadP(yfsJK0pdPSI0MuC2q1lgsHMXBgwlUqU2qzmlUKGyRxsmsDxHpwUrkOwSnQ4gB3MHLyUdW5oW3CaOYMweWUHMXBgwBHzyjGBSWFCmBbiODSy262sxwfAgVzyTLZjmxb8zYy2cqq7yXS1TLUSATqZPS9MLvGaJFagRwHMtz7nl1Jii6TgRwRfAoLT3SCkBAJiWQvO5u2EZYg825fULAQw7roFy4Y5eg4bGw(mwTYaKZlpKPyz5CcZ1z8znwT6myCv4G3oVabTJfZw3iJljxpaPiewinTdmPZskYwjsHhaPOn7rkYwj2fY1gkJzXLeeB9sIrQ7k8XYnsb1ITrf3naYosbkX3y5L9hjIxObiKRhG0kjW93NKc3EVtdvpPWdG0pUD8cPrkO4kJueclKolPqZ4ndRL0yjDagbqQdIKMGyRxssX(jlKRnugZIlji26LeJu3v4JLBKck2Ia2TZhgUCoHbEaOLpJvRoFy4cZWsa3yH)4y2YNXQvOz8MH1woNWCfWNjJzlabTJfJelD5lF57b]] )


end
