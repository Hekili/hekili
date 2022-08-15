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


    spec:RegisterPack( "Shadow", 20220809, [[Hekili:T3162TTrs6NfDYzziTuyiPeLD8kY5yBfpjzsC8oYt8(lbbcckIXGaCWfPO5OdF23QQ(c6Ur3aGs2ox25pjYen6lvxx(QQRc9LJV8DxEXs)IWlFZKrtMm6zJpz4KXtE60ND5ff3Tn8Yl26h8b)RH)iXFd8FVyT)Y0BXF(U4u)L4RNNwMfapADrX28N)1F91rfRlxmmiDZxNhTPm2ViknjiZFvb(Vd(6lVyrzuCX3NC5cRJ9jNE5f(LfRtZGHlAZRGEoA5YqwZdZdetIDx92SOW8ID)WlkVUe()x9nhT7kSR29d7(HxT2p56W8NV7h(QDx9UBd9)WUR(L0OLW)inllmbA(TRdt2DvHF21HW)kiTmPiF3v(zH7UAvkSKwoKE53MfweMaV4Yu5Zl3Q)6IFpionh(FfPqRVlk5AycLd)DXAFyesk)qOOH5frXX7UkleitBGEhgSlViokVihjPb3ga)V3q7oHj(lIdxE5lHFolQimlYhO5HfElstkZhwefMn5zENSny3v92D1IYvRgU0p7dEabS861fdXPk8GTHfdxfbJ0q)GIOBcPFmRmjewQxhomNiPRIHnzVTzr5Bgg(VkJ2UnCj1Wd498nafeEHnQ96DW(Vh79hMfUXpkbwKNb0Wiy49K)Y933YSZv)CDWYHB8)1Dx9KDx1F3vhV7QdP)W6CAa1SXNs)1(mbV8I0K478qk)fJzmAzrBrw3lV4DtE2URo5RYzSjjlJWF2pMyt2D1RE)R2D1pfHCiVm2pVa4EdyV3g4h9wq)wbWKBSBwMh6D76O4qVaOfaZcUHlF38q)m438sWj5gGNb2(VlaAmNHJACfdbqpUbEbSZhw7v9cklsxTsStkB4200ypyn4fSmNiy4EuFIrNZq4DBA2sVTabcOCRYcHFfErQJY3gghlMndPLkoW7UAoq)HEZGg(pq5IlyZSDx9gXuB3vrW8c2Ha5jsIyDeqKdtqUdvHlK6(20BdH()7twvMd9j)x)f(2pxWkjTafR8xEhi7HBpOSiFUdtG3)83c)mk3EBk75BsXxtSoWnQJ)uUrv4hdkFQVhnKpGeT9rVbmXG6FbOnfOlVkklOejW22iKC2mA2hcd3kiyOKve87Vi9Brc0jgeinjhlm)6ZfrRbsVpPqSynm6Sxd3BIVdgWC2YCzjBAgaAZtcJP)M21PTzFKZa3DVgSYKj6dCpegtuQUzLOK2JfPPjEPRafsHE(5bmvXLBH91ISOGcTT6aFGGZ(hEOUAMgBpMLrSJSjMxnEhiyZggL7Tn2)UWSQ(EzeUF6TX)6OaBmHI2HA78cZk5eZ6YymJCFlVfmM9aqqhyMG)cf5zurG(fh6JMnNmf3DZ9tIkasFFuO4KrCLBVmonf7U4vSEkDBysy2au1BbFxWqao9MWSa)TQDjY68lVEiOLe2Wbg3sKDJzeNmj91O2ZfiPpJV9QOofE9CZvXc0QfUw)w2WFrL1lwZfgVGX87VoHARCLdcr0wlqDYzVoOobFGwV8w0iiF28s(uJMiLfdv3uDOmThPiTIemFgJoZmDnEQWAwMFq4Wfir2lmMPHUichFW(0XJiLYC9YpAd4cY3WkjtH5x1NQQ3zzOFXAHDvZL0zWs6ztztUoPvRdgOguB6WwY85jZQpa4mEbSgal)i4sqvBEA8n44lhnjyJAnb7j8PGXCuvE(WiI)q8C0WLfnCsL9gkLneav5VjrITOusPup6lU4fcZpRdRGEI8GVpdi1RkbbOx7dCweFCYxwWuQH72m4MeMfIBD8xDSIzlt1AR8d9UU0pBzKFsUY28Yq6X3YhnVv0GjAGttka34jiDzQd6ISP7TPUMSIjzyK)SbsgR2jlIc(arHAItY9WodxQ1nHdl(tDS4B0SaOnaF3N2bc3Jf1WNFsPb7)3fHG2anNPzKgcMw8lcRSnBah7803LJ2nkwJcKM4OaY2ZCq2w6VjXNt9BgvmUUUXFZ2iqLVxrAzWADGuOUG2HBXbglC5GiIldVbCSimtWsPOzC3vtL6UzQTQ75tEb4zn126pdC3XJ)CCKpGuxP7W3e0Hptq2GRQRc5yElrWaNlOtcDpK1sgiyOD)Y7yg1i744Ya)rsXvaG3c)XaYcSp2KSnOlpNtRAIP4TX(xxcds)OKG4YL0VX2YpNtAafGzPb5d42rvqjW78T4umdwMVJTYZrpJH1TUHzY)lybtOZ)MoOAMSBz1beEKdEp0kCA6JCEDbcGaDcB2h(Ra)Kc8usBEs4VwW8wvLf8Xz2U6TRCCDgniTOVgA0trQ14rnP4Xg88xeFR)D5C(hSvuJ4BiWogn1iAY6YKRdzeGBiqNiReYfrpTRuu2lba1aw0LcxRJrV3y8EYPGkstaba1fWRMWKqrwEYykTxKfTc(ZfGS4T(rm7L(13B6Bhue4SbqqZfEYYeG5goLRzpCjlrtCGecKrdK6NRHItBdfxQEmGFhY3EhyWa8rI9zU2G1kpulXTXAqHuTuqURSinUqhcx3wbCkBDAaJ2yliyepVPlFA(oHtg3(n9s4PmNJwd2HyAWeMZy2P(UkUE2RGlmK77ejCmEKhslOoGXyW9H5I3PXbwhnDVw5K61r42nUXEQ0Mw)UmGh0LXKZI7CCNXdmeUfz6LS0WUW8c6GmyDXmogBddICygIT9ylYgmOZL5(xROZ(vCw0Cdnc2dTQItoniH31TMhNuTvHUM3TjAURqk0cn)8uYpegEI6KDPszaYaxfCuckpufyoGlVi0FjxSGGGylqG5cQN0cJ7qcAQhVgAnfxVb1y6UPs6bkyhdG2(IUAlrl00uFm55UIg6(nftvJzcxgx9fBNFHlN2Ed7PptA0lBMuOl3CBwr5lzQYE15kB(lzmjjH4eb39zgVRXVCeFNfvngYdzBCyoffqK)PsjkfQfyLpvizJXNSmQyG2wFtES2N6UdLV5WLr55a6IKcVWG1PH5MYUnPnULnOoStsuCxoqBb9Alo2WdL46q)4I1d3guqR5jJArBartQc1)JttuByhSFiakyWFUgiC9GIGb3DbXdqhNggseP7jR9Vj0o2YQ5hJRrn0I4RRe2rrSvi3kg7Y7(8sula8(G(aVn(ltaU12CwN2zqew47qZ8QTgDT3O2gRejXOYw9)eBCzcE(vej2blIKQRtzEIiiv(vqHb(WDuufzluxHIqvNxZlqPkg8er9Qa2vFPPfjo(VREeCwWjQDGHBZcVXdHTpUQfcfDSW3JHonUmhFp)GIwz(pwiRlxd3albWRM4Ow5PP1OmgUNsgc4c9f3Ir8jDL3k)cDerwfbmoiA2zEu5Ao7CTEhx9OqWuO3SA3)wMsxA)wZvu(XLW2VnJHIHwK20U1ejP5al5m0kYWk5ERq3rvMamTAECU))(NFUqXWBHzYcGP5dOm2BZ9J3GotkSfPsLjqiOVMlcJrfxtg9FvDeem6T8Kjcs3GEoUWp4dA2PQuPUTAC92IdRUkvRYwgAuaL9EO2K5eJydrUhyk4r)r6vjDevUckaVhcY8ZBm8jVcBqfkafYM0OU)se)tucqqGTADAHpEewu04XwnepEi0v7r0CRHKE4HXg2ZU)R2wFQbSKaXKMKxIgxmdsffwlgb4f)83oeE0pF(pJ(uKSkIq8sud8)sMXS5njdVtwiSpZcqbVZQiNlPbTqoOgwezEWd)tBkRbi4Hz4za6fTcSibcC5ZNDI2VVzt4Yim9BWtTf0yGNMH553srMg3vm9xZfT71X(31DA3fVJwa5rlXvYk6ucRDug2I7GvPexjPIB459ShaOvLaFwwiloq8iLmFMmtuCrD7DGD(S9KMd4zUJO5U8xZzO7u2hEPreZQHpxlg8ad8ffPBzO2Jehp8jwsqIMCZ2W5nACRYjJgIhykPb(UG1rGN2)yuYhg6quF(Fzk5IPqfn8GOnLBy8otvnrMuUzbb5BLCQdlYxeNNEesm4ZjaEbkOPeIXYKIiqBVpQYxUKPfbkNwbReTolcRaTUYvxxBzRlK6RgMt)B8JIj2WwrtPOJCt6nHBW)GRNupwHJgoTlWwyocnrfZYMO8WS7Qm0FOaQHx9Zmr992Y2P8IXnk13UFtif(l0g0aX5E)i87yGUd0D7L4(Oz)Wa7Exyh1iZOQtNP1OKnJS2mhFS5kbQjA8ZeualNVLeEfFr7ysRRifpYPBkybiEKzqhmzv61LZmBGc4)YKvLzy6x4HAhrxzQBb(Vl0i9l8LdIqM49aW1Hic5f(54OJwouoylsONhR13XI1kb8Dsx812YH4lJXOrcrLRRHSkvYaugFvL6rJJP)yvLO0zBHlHnPlY1pNen9F8h9MF(DO(CI2V3CjKmFp1ityzxSrr6wq(pHiYoDBUgr(rZ33Pv0bDpyzpq8KwIEND6NUm0(tJXGOmXQtK)nJCZJedqdz(j3PA3crBLMNhbJ1r4PwgeUTy)yr5(kPzCM23DffHva211u2E7aM04gaevb1V9u8PzaF0VVftyuViE(IACMvg9RAujaprSaS61YvMbOv8fRmTKZ0wG)yb9GFHpuWgMihJOPargDLGdvOV7k4(jDIU(qy5vqQItzxEGxbE1XeSxFRaKV)ERNwyV(M7T3FV13Vh7hnJTB52bd6a2BmvlnDh2vGdq5jgmrqzfLqTr80IKHgfaQ1uajWHY07wRd1B70qXnsWMAICK8vN3GkykVy3s1CWc)IMtowv5HJhnQQxzcvuNc7lfrfLldBoVxLcZBlZlkbEzr6RQRQSvzERkzSKQSbQzClXCWH1XyJmjq4pBlN)cQDkTdxgUkkapnkmCftR6i)Sa)KqzWtTKOCSKbJnGHl9sZwqjDmm0u0w1Nr1BGLSplDlvgiQ4mzYV4FfJNI3e6345HwnHAljLMgHJB2sMPv13fma2AjDTcmtGTg6nfVAj(0cWY9hcP6HPgBADPgERbzIvfuCwkrp4aJzzYYhOGm7jIzfVDSaOZ96J8yLI53jugPHMcXy7KXdPXYqk6gxhYJyZuzR4zlT0ga8w00seLqo800e(5Owi8afM3xFnvvd4KAryXTHuvfXx8aaIfLx)xWZ8IZbf4NLtbAoduLLL4h7HzZ8QqJ46k58D1EVte2d5X3GD48sul1nSkbZBXSk(mDT4szC1mpz8i5qeaAWq11djSzyEOQif4CrArptDEbXwmlJ3Kjg05PVdxSCFJiwcrECHTbWLfYqtb7cfSC9I80Ntde7aHB2ExwimLanGWciqJY3gnaH0nEsNPxakljrP(4Ar1NEzlj4BV4Uea723))iJ995PLes7leG9E155mlmc4Iad8pdKX40eI7KalkHdYqks9hWnJYxabBZwECjZPrJ1scpkg3zu64FsfPhX)hvi5OH1AqwzbUe8(xLahr5gm1kJ0jSwX51e34I0Cwa(mkdncu9OM5M71(MZHSK4FU7YCZCYk7rJbSBDz)o0buGbg1PPVOPdSrIOh(nkM8BylYIDtDNPjMHlwhIsG)emHdCjxTXpWFbMi(yB92GnDFKSyhGqL1el9MBZYaYJyMsDVSYf3zdZTu3u92QZK6GF8akQGH5OtPXR80BfRjYIwXjmblK2)E5czQPvRa5OuE6iwHwTJxxcKiAs02qouYy4Lq5YV7Ts3U3D175H2SkGNxWNtGEHSfm)EEhBADKMKT0(k6okf9gvVqhAdjJ2Q61rzyFDr01Of58nuKytHhUj6FZd4dFcvTrWOcIDtSsUwH9Ixo2jnRfPnJADyBRtCMsP4QnzdgjHNRvhNNrdO50Gw0UHk3QywnjfwW8v385l9xI5jh0FkhldhGdXXSITfX2UZSaPsRn4zlWQ(War1hIgAUHoc8qzzQvDeQORmJhLRguc)B9VRcces(J9Uo2hDNlfqkSaNXeEHWSuaF(D7LIJz6Ao6s3BbQRRdl1MeJiemSYNlPsxOid5suGcQMxQb8mXw5vWt1a(P)2DWInH96VjmilnMYWDgOgKMJmp8cTqy0VcTAR(NyHC6Yk0zD3kKst7RIiSA(RHu8d814aftI8hHUjU(Umxql1dANDTa2t1K2K3WQfAuN8FZvytaFhxde3GICGyEDyciHCNxqAMzAyYCZzDLJ(CrsQ04F15)DXEO7(ROHYbaRXz4T2KBM8NHR8lrcXkqr8IkpDefOl9opN7TJHCmXosh(fQDt6HwECAr9t5DV0k3gJLiBcqo3Lw9GupAgIbWgjVMrvD4lG833LIfJarwQY5vEIGqrmwNMOuSiiZFEiEod5CFeXJ6qXskcDwlPuyLnmtj5wFuRAQiX5eIhc2FL0TLNygkLEdMol(jC3snlzygxgXQJQxQdUNbCGcp1wg5PYKOC(SIN4zP1v2t0Qe8Vy6T0tN3Mm42RbNtpWIUIE6)SIQLoOFsGsg786gAB7TLQCSaVUT3L7lqhMJYYb6j0XJyzQo3TRdv5hulGkABwWNVwvxlfMRYvpcjt3CM)JpAK3tYVVHXD(A04WAfb4x)qXzyNNSk4kJuSaz1c1EdbXv(HOv7VwpjdC8(RIwurY0tfNkfC1FPLgOquY0ewQ5ggXuT8xZOiv)9j3eDDQGzdj0Vokej64i9YyGXlDdg0S37JyvODc2xBhu7bvMxBRcMgLXa(mG)Mlf2rV8RrBIyMldfh2ILOcB6HEFlLUKOgau0X0yreif6TMvh6h)IzkwWQpgCu6yYPA2bAXWZ1sugM9RXTgqxq1oJJ4XVc3QqMVfInQQLRTaaOgr3RbrPwsx6i16M9BKIjQ0qSaRnY14A7usLs13QAOIDCsSSCkVU6gSdSxEGA6GRsBh(SRtdAl1DqtP9ZuhzF8pj2xe(Hq(yFSOCSPSDQClh(qvwCz41X3MWINqT6HJHYG)bUsi7Y)yzrjllHBGrjwfLeLVoSkb04zdbgu(PhUR9SoBOTO6ib1MaA2VZlj9gFB0H)b9yOZGNlucEeZAanilaCiRI5Xq92knt1H8a)l)LlXDd)BnaZ0o7tpBklCZtPFk2gMB63UPALWr4oXihiqozom2IFJGCB7tPttXNN(eYWtiwoSxf2Ok4OK17J2XRtBKKzIgaBfMlPeiaUHFFgStMBCRupDgW60k8C8ctcUJFqa0ZRvpZ4eG(IYSANm5g7KLKMvovtpU(5Wpw0fDtdGv4WnneNrzvsxhcM(iN1HbtxLmOw1oKI9qvm2WM6ivWW1ESrqfoLTcDlbnO5Z6QxxindSfpnHWqJFuqKNTzJNzQwPDHfuLYjodsvBdXthZBBg9HKIC2L(gu18hoWMs2OJvIkbx(19NVUAT0IA2FM)X8kedsfRzc1TkraRkVHzfoQTClgLWNuzqOHAauB(Oiq9rrKJrMxYcksRNm93(RHbL0cl8Mq6W4i1jf8V3zPz1tl4kxaGjsqljwX(e4e1qEq)Floq0Ekf0VTk6H85XsY7rbktbGtBPTQR(4ucttvAnWnyAdgA7Rgx1Xgo5mlk6Un9oXy6PaC1gqL2NInMaMKF31SqBCkrfuuIezFVfrleR1XQyTq(YtouXLUAW)uxI1KvusWK9pNvQLt3BXqxL7T2pBtAYDw(OM5kOXDim1QFzrpU9Oo24rkp1yNpyP3g)e)RdfX)10qr70IMC2tl1EyPUTnJjTpitvkmavxU0M)DosuvNPCJ27TKzqpWu1fnl6GwygW92PfJ(4nVM7EEvlg8TpXo5J3edlSDtRDkv9x1oK95UP9U2N79BjdNLvfIJw1KbpxZsttMTplhBaRx(5bKICHRXz)nGsXUYEf2GHzLctsys4MimQjvdAuomMEItrNg793CxdJngtAPOVSuqm9r0ywOm)uRC3clFMdAFY1S)s2vlzyQ7vs)7El8xyDKWEPJOiyUK5h)w6r2cLOm2gQlmv3IPvMPjTGoL9hTAoA(oXxVwJwu506xPFo1SpAORkZOybxRQ(BsOrgO4OSqQBOEWTJiU7HfHz5HziUiQlCDgNXu6J59plxETL9nkOa)i2KVeOe)aVrANCfHazYU61J4rYOVWICfvLJuyyO90vkVavVTpDAt(oympzYftK(jEGwD5r1UC4VgLlevCuxZpD6ohLDDxOWOZT5fzGRUOhLu30OphNhXpzw2bIiomUV7oWDXI14hgB8BnkmPVnZFBo(D1Pa4cIRsVI1vT07wzdvNSkmHoACrNQy4c2NNcCFI7F0XyAF4ZdJpp7icGox26kPbRLQF9VziYLfzRmDLxqACmmfX)1QYIYSqZV)t0wbDINSyIx9DACmhytDO)WU8PvP2QvNdWwur3Ay2u0qL)28xA0BPuCZzDicGQD(UOwOl5jEnSvqNfo)wzy0KlV4w)muEcivV)f)9389V5V(C8Z137qsF0MTuY9qsAFPiWgFjw3cau9muTBEk61Rp4vWgFYB4a2DZWWD)Wps5NYPpNkDEyGPhl6LH(lcK6)(s2w6xk1Kcpe(T(J)1bdX77HwMyYQEy)MztmMzYZe5)vmFQ(fb0PQz1JQpq3Y(2F(h7(se3d3Vv3XpSzM(Q7PpQoP1vfy3D)wuFmyM(EAkGV(t3j)Y1s3ohWJXeuiDveID5l(IQVjgIlJe83SDHKG)E1Lsc(VEuxmj8o4Z1LtIyfufslbekMyf(VVoIk8HxeGLzyoLGhFf63o9vTMrfPdBgm2S7h4)7HsbZdN912kTOJIwnJJs6SJhnY(lwvpqyZDwVr3FVZAmYE)wvGqy)YQ(mTAjY(RPxoq4RgzubrZhp1(RkYdRJq9YZCKoz2Fvbgz2RAwVphLUDgGa)icU9SjU6cv3cO1SRc3XEhuvep4l7(DbMjvEPogEu5yoJhEugp5BtzSwYNYIWjodmXvD)9oqPlE3A0rE070jF9BkiO3FFDaaNn7Kb967oON2FNth4EEPezr95MzqnzdRRWz6AYsBqFsIDO7LKRijQV(C9PbzYH1chUZrsZlsJT2dAp4J9oOEyhvQIv7(4D2mE4gFYXU4cHFh8TUNw4fpB2KPnWgW9vVjsKHV(7xxn9WjpPVDVV71CabpB24rd61yyav0r4mAw9CSFp7P75kz0Jz0MVVJ2jpMrB2Z6DqdXMBpNk9DmkNnB6GN44z20DUNd7yY8HEC0C3f6HwsVNW3XACRotlEzU7CLOt1XEE(mZOHD)9h4ioyKQYpwXEY9Iqnsu6RcNHoRNDbx1XOkksYTClQLAr12Cw)5k0vF14rQdPmQtTXKvfCj7T8l4zM4NXqhPo9mcweH8SPOjnF2K7VhmVyncs3FF9Ohn)P6A(1dfKtAYdocqQJLoou7H5bNbJQ2g(Seoh3Zr3HubNN9TgwNZg3Ro8N5NoAGvyrNQXgBglgoYIBduBKrmxeQlb8qC)PEXB)r2IJ2SyET9YuT8OVkZji6bPYQc9nMYhZ0ZwJ6CIk68pM2W(0Lyg6ZmKRvnFmQp10E88XonapUYKOZd(s4L955vCL)NY34Zr5BuTRdwNMPBha3ZDxshw)mVyudb2WB3c6Z5a6Z7VxhjDZVb4FMwZN7YUk)5hoEARiGbe)p5eJPX82kgdREb06CbnsRr04ozOw0fdQelUG7aTmzmj8jzPyXAhUDD5)gTN(w4Fh7VHPWKExLDzm8iSo5iM0QhgPMkFNOEj3BRAFiDGQpx9kGKcm2j12YZxp(3yTH0N0zLj9N)AbrJVUE4zAVonShec0QY8XJ61)G6vcIY69)hwNgMeCTAzPkiCkutIiMATKnanjnuSgGaFTyL0KNZZgF)9YxqXLIgFP5JhWfe1MYDOimucwPZcWqHx5pvj1VjxGSssosRqsy(ykIT6zFdiqvTLQeGSASik(ivXJypgfdSS)bCon)s3FFJ1dYCzTGi(KMzVZDI0b4nCGVBQclXNS6BOMwXQ6SqnMX2Pn9mf6CrSeFz300C2VfZ(Ov)kh1v9zEqVAK6ks1FSljbZ9dBfIHDDNULlEmaXHTPAJKlg2jT3D96BR8daXe3vlqRs13FV7xUN4idRxLbsYvvqopDspx8VOUJ6uI2wUdm3oT7PP8teMrRnRmaCJVQscoB2tNk9tI0z)(103MYxj)YFZ7nuXCXohxfAKVeMFvpeFQfr2A(xoxoOLQVR(Fn9bIhL72VlvFLv5TbZuoMjXTjoylOcgQT7Wl(NjsJVDKMFhQ71LVf011Kq9dyvnZJ9ws(dnu8Clj2Md2ExX5f0)4d7x3mXtgF6GUnSkO(T4aVX139VX3)(67Z1KroQ2DXpSVBbtqfmaxhQuphwjaj22(0w7w1i)yZ(ODz7RrnqhUEO0J20507bVMNql5p53P)MucRAaek2(jFI(92F8islfDxHIoALXrfNrzHXo1lha(uanwcKOufTQOi0m7QGr7ShXUm5zKzMh3wS(QLQaypIkQvUX)5WMe(eZdtKuU9)CN(N)P(o9V22JgGiC)XQ(IE9fKK5ZMm9W(JN(K(63P)9qaBND8iemWd0AJe1rfxVo4TAFRHz(ri9mA2ZMIXyPfDaTQZCGYqkUafayyotQgPNt1Ud(bhySF)7Z0G(B29OFnUatDIsPCZly)Eh48Q13j23tQnCvha7drjUlD0vNLPrsbbt6gsKfB72UgIz1xlooGKLm8iFCVR4)dhHKOb)z)6AVUjpX6ZkMnlPhLccK7VVnmk4PRsIG0UJY1ZFpPIWPGAy(jou)Y4)S6)U8I4hCOSMtfWsunI688a9t7vlFJkOiv)0XT8GSZu72cNoadNAVWmWbpbZ)CFFXBxZI8Cw7BZ2m)cKF(4E9DfAGoeGclBhY4gEim1g8aDETw)wfoYg2RD47ABrusEzoCqxMBavXCnnONnN5nHg)z4AB3oarC9PfeAaQvZj9wRX)X9MWPGgU(n35TgmTboJD8mH7RFcUJ1RBjWiFujzjB70sCRoKtANC(WKs6CamNDklRB(D5TKE3O7A2qL(Z80kFgiwDJJpRN9tDtQR64Nq6O6BpolkJdiX0TZ8OFBnrjMooDHrXI9V5xK5nRsXfdx)toSTl08b9SPpQbsBRuF74C(9X13DhWezdUjpClkXgFYi3UQHbg8HPjXTnvv0JFsUVVRtzSCzMB3djI2OM9BaXrxNif2gd7WF6VsRTlZik1gllL61dr9LH5r8ApRBuVEYb4z2otkM)hgxk5o5aoEqVoKqbks(tpS)PpHlQA9khFWaR4vzsqCU(hg6d3((6WXmUVV2xIkm(FwVsU7GQcTSyY9L1DTJX2mtszxs3Z73qq6ez8fHMVUg29)w221YJkFaALvpjJhpspjs29hU7)69l4p7n)T1do8i6cKd7X6xWC6)kOmLF)qZoCcKsrf76Rwhg8bbzs92ZoAZ2ykr99RcdwEihejIYJ4iZLEQKb0aQ0x56iZzNSrvx(FJhlZDQGAyxiiSHM6nc2otPnWG(bHejjkrhrldxUjRYJ)6(2(MhEnckd1QPpN1K8SKxd2dwVnN1RFzFpxuPwpKnz7xc4M0T)Z1Z9VRVEUBjOp1yaTFBDxfxLdhnCQBR6NC4eHrD9l02dz4KSuFsI2B7sL9qxf8fS9m4jpmqSyut7AeCQFObD7fTHtGzv8J5ndDD8J618SflgQhdEDGXZNn(znxAVhyDL1ZScZMpQYfxD(GwpDErokA9A2wpOo)U6sTUth3wlK)tKX8YGO1GislzZWVTxVYTtu2FEuNePd(e4qGs0CSr8R4Y3NTMZMnrn2nFSVmMRr0D8jLW8SSTH9G(LAvrzp7NfUWvZXJ2dugJ)ed59ba8zsda5Ea92N)7kAtxs7YnWCREtQ1PpQR15w1kW)OAWkfZS)CFB4wrmepAMrL546gKLIbc)d5sJxnU9y1OJTm419NVHwto9bkLPLSIF2vln0)4EZ1wNADOzLmvltNr6uBv324jTUINWoJ4FFFt02b6tKZBavPxQQMaCXFy9Z7Xix8tTuEHhoE6CBPxS6eXvTg6Ul63YRGfwzhQ9Yb9mkMYXFdlotTFHW2HTdl3URTZWkI01FiV3u7arX8(c1gsaxmMh4UaDvQuIC(AP2NJQVaRtWh692AhwAf63JP2K5CRuUX1wRSmGeHZRSvaunBgx)UAv2Va0cRY9tuc76h)6A9JZnUAh2z6yjW2UcdZWFBtIz3V3U3u7cbYUmJgrX1hmQw10snPV9pgvAfd(asXU(LLQnOid6vVstSFux25QNDI2heeNxwPDGW58EmLLUfFIUxsBCILVFkEAv3c95ho4Y3mz6ZOp9Qx()n]] )


end
