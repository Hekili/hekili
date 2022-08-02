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


    spec:RegisterPack( "Shadow", 20220802, [[Hekili:T31EZTTrs(plQsDmKwkmKuI2o(e5w(r8MKnXwxK347VefiiijwdcWfpKS2If)SFD3ZdmZGzaaLS9MKBR6UnweZZE6N)MEM5QHx9URUCHxEWvVz0GrJg80bJ6p4PJFYzdV6Y872gC1LB98)G3k4Fe7Tb(FVCT3IKBXF(UOeVfy1Zsks9HpTopFB2Z(2VDvy(6I599t28TzHBkI8YdtI9t9wMJ)T)3E1LZlcJY)X4RMBRVhma6BVI81jPq3fU5LqlhUyraR4bz(IbX(RVinmilF)p98IvfW)96rNa))qtT)N2)tVCTx8QGSNT)N(M9x)UBd8(W(R)TKWfWFKKMgedf)21bX7Vo3lDva8x(jfX5z7V2lny)1ltGP0I(uLVinipigQ4Ie53l2QxDXV7hLKb)N8eO03fgVcgqzW)oFTh0dXfFiquWS8WOO9xNgaKPnqRdD2vxgfMLNHK0T0Vp3lh(J3qRrbXEZJcwC1lU6s)0W8G0qVRUmnyJxym0KNV)6thmaiB(iTgQFYTbPZUnjDXmyMKhMxSi4QCGo7SPGfXO5HXl6VfOKfrbZcsl2InwFEX3F9UD4KHxSBsW1vOCzjr3autrXkhdlJcYwtl7ypFQZE(O9xpVy5Y(z0IkmC30VyBzZu(ZyZCMZMbOdEXH531FrWYq)qGCpD)1dhx2qEP(EXbZYzR(yJn2OXyC4SomyXSK05ZswIvydwbJru1caT4JnAXeyIKfOu3B8Gbl8v8Ffva)Nr0VnJ11Bak7SSa4V9lYtwUeBYNuhHl3lcP9l82e7PUyP2HB2gMg6dJYc)1yd(uNnyZTgnaNh5LHZwyAHSF1ZIslTZtsIjk16GzEz(m2DCrolhgA5y9LDHVxu0m2FmdLhysfCce2q1ZhFKqISFy2STrE3fKw22lcZ2genBJ3QqFBmLsIgONqkaWu6KgY)J)okFZuK898sS)A8)3pjjc4lG)1w4FbY(GKoWfgf4rQMgV)Abl6(R7MKU)6Zgq6z2F9lIssWMlAjRLs2gehK2dLlqTgjW)ti8P7skaLoKAJKBcaU5TQnziuXF7193F9V49bu)sbQLHPOCziqX)2Fbw7MJKEOh9q1z4pGDon(cZmNfZdGbhox)Ew3ZBRiyHGv8G)zr42TOwYR)XvXuzLZ80a2slqDYyvViJ(GwRa6VZ2WhnVGp0ObsrEF1fvHutFS9rnAZ8xafRdqivjbtNWOZht)(q4F9i6FL65h0FosKNfG0yOE5Hy)tQn3FDp6)dvVTf4BiQvFKv4MaQSPfXiPyvGqffo4NTfh79f0aQGhvs(6xkP0hTvy8vwdXuqViWlFnvOEvNsNdtPNoMn44INO(bGuoloC168nGXKsn0qTLKQkfJRtr0nQdh2uMpo7sFRrf9SXejExPiylrwlcYZHXqw)qI)q8DyiytxUU(vgXzlQGrxauL)Mej2IsjyxE57F2f7V(5x(8ly8YG6MsZ7ip47tbs9Ycqa61EaNfXhh)1WhfR2mt6lrsgXTo8BovAHVFf1Al9cMTQWlDrOxCMYY8Ia6Z3Y7TzlPotuaufu0mrJkv5tCJNzZSuff01Zb4S9NQWDyAPro0tY7Bs)7Nh6)bICuhBJ7UDcoV0nHGFbMy35dmn8QGgbSybTvMfaTb2mv2MUuN36hakkPwkjLe)yQiVKMhSwJ5BxAWsqdhu0xL8UmuPC(AKB3yz5palD2CiqATu4hqJKnWd5LOUBK0uG2hFLOQcXrYacjEIg8(T3X0ZtM2q(h8hjzzWfn6h9jJsEyrs34bcSVk4gimdAQCrK3QcOt6gg7hvSG(n2cfRq4izBAIFwpUPffdN8gFloetHicE36KcyLidDihc0r3w17g9uWGYwFnj)UmkTUFv95meinKP6Z6QrLsX01sAlOL1f8jGqOsXqW(RhlnvX0stvBbmna)QOzrFAoqLT63249Xz8VJ98rK25zZtIlYaUKG0rpDgmv5QM)UwOAMSBzZ5ir0zVhkfUM4HchTXfaH3jSLQGpceyOel4l7K284GpclGR8xOTM8WmBxw7Y4PMqDsd6RHc9eKAnCqDkEyUlRtNEE0TE3LXfwWsrfIZ9bSN0qJOjRlGOyzeGBiNor5gK7G(ABPOSkboQbYJlweIdcqF6DNie0KdbvpnbpaOMaQAmJLfLVjJP0ArA4s4FohyoV1lKzV0R6Atx7of5VgjOzSO0eC0CdNY58mCkl9MOmEhJcivHwXloTfuCQoJ543X8L3EgmaFIyFMQ1znYdP4kLMilxja3hRWf8yJROmNcxzEsuUUlCTBgWPSvPbmAtfLeNTLcDAOziFAXoHdg3Xn9c4RSGJwdMbzQRfwCzMs)HsUEwvWjgY9DM0DStywnsYPgGXyWJH5Y313gYaLEt3ProPoT0D7AxyFSujF320Hh1M(KZI7SFNqItKs8HMrjlnSlSLIbiVcrHqBLcuN6h6WMlB55s24B)1VrmafUoxK5TsrN9l5SOzgAeSXvPfKtns4TDP5HjvBvOR(vBIM7csHgO5VkHIdH58uvYUuPm4FexfCymkp8B8ri5QqEG3cUyb5VLLvj0qaJ6jTWWS2Ugrmligv8ypINUsVElDFrj0BqnMEyQKEaoyBARl6QTeLqtt9PuK7kAOzk0CadGXiHlJRwXM5x4YPnxWo6JKAJYMjf6km36vu(cMQSx(kLf)fmMK4aCGGR(mJ3v4xoHVYIQgd44nhfKLr4qhRQeLGAbM5Jfs2(jXlkcZ7PT0xxeRDPM7yzn7Vimld8UioFwG)6KGmtz360g3WculwjjkUza0149Adb2uXF2NP5qRoadi0(Zj6jb)pcVGmUM1E3ey3pTsToSvavy6WQRaHNaNct5soGNRd8IYx3FRFoTYmAqd6SOvUEsE)hM(YM8WHjl4k6(SculamNb9bZ24Tig4wB5IJOMmQ(VWQlt4XRCXHTbm4s0Qew0eILiVs3zbEP9eYG91JCNOU4VJJoQsLKxD7eOEnAI6ckcvDETBcASNvjXr3PgonjOJXtts5IvoH4Fjb4wMUdA0Rfrf4iECCqKD8wXD8AwPtLvNSAOaY)D1DLYIpQYptUQNgCZmmKHHLLqOKLT1biSTrfzy988ZBKL(uHEg5C4gykaruff2iNknhL4h)yYiexHt(TiAtjlNT0lx3BmgJT7nvPTwvUNy)4eRbjYpUjh6bQYu6qZMhw4)V)zVsOm7cyKmhw4(akFErMx0gmysHTiv2tYjemwZ5brOY2rd(Vk3ccgJQCNj8t2Groo3Z)dASTLkR2w2VZ2IDRUYkR83gY5GA0zOm(uIzOgK7bPjouxYOkPTOYfOa8wWp1lRw4tEjwGsVauiBsJ6Elq)FcJbccSuRtl8WTWIqJhlvFC7HWqThqJn37x39KnSJ94xTn)uXuLCIjjoRaniAIihHHhJa883(99Hp92x9wmMI4LHKhVe1a)FjtV2IMK5VtAaSoZaOG3yLKZfuNMl7udR4Si4H)0MYAWf8GuCpaNfUeStacCztNCM2VVztWIqmfhUekpOQf3nJH2qMgxvCVRMoXgWkN8rUXmW9oPzdKMLfaVqAadRgoAgtzqJH4j6E191rE31(v3lFhrIZcxG06L0(y6I625i78zhinh8J5oIM7kEnNq3PmlFHbIzv8pxBBcag4lZt2Y8ApuS9WNX8YBdtpNWRC3HzBe8g1V0hyyP7gpWesd8D(RdHiT)5W4p03HO(0)YyketHkA4dHBk2WwzgR6BrCXM5KBQlLdDys(8OSKtqIbFmbM4rbnfiglIZdbT9EOkF5uMMeOCAPRWOBncyfO5vM68AlBEHuFvyo9UXlmIyXB0JgfDKBsUjatIdHEsDSch0FCBCDGfi0iv)g2eMfKExPH(Jf(OnR6MiOwVTSvQzr4cLAT7wNNc)fAbQNyFVFaE03tpa62vjEmA23FW23e29CJzu1zW06P5stEw)RcbZFJxp0dBAja8Zla9WEUxg2RO6jLnZI495qo(ogKJ6wDvriPQpfK33Oc0HpvqCTSxssp340th0dD9)427Ctod75bM4zyYf2Pn7pvpfF7lIxwKIz2XmuXlgHfFVdh1MyTTSj(smgrydczexuJzMUgs(wgI5eZYLFtP6rJTP)uvLO0MCHZYnjZZ03Nen9F8p9M3(ouForGo4LssMVJkYewi11ks3GN)JiISZWMRqKBGV)VfeiZtcAFxrEAu5Sx8DQ6Ir7ZjzzHqhEcUtC(bBZpmYo3)FndoFEiVh1EK7UNo3Abkr7lM6sDh(coIvYOYOkh5cfbLuR0UBsdD7quvNzETS1mCddJtVuDEgtcf)XC6d)gpTFagkrE9qklUYwAL6onIQ3Hv63zPZAiOekdg2g7lMr7QI(apAhxj4qP33T15(rTXrZhyWu0q2ve4LoV6ya2PRvhK3TZ6Uf2PRjDF3oR1Vd7hnX2TyBVETGKGPAPz4WUaoa19WCte0pKKY9VwMoxOJA1bib2vMr3ATRUOvDf3ibBOjYrYx(QAubt5fR)T(2slwTbcLDjN9nzSCppwSR88Cc9LV)LAHzC1LiYFZWg2GhZ6wP5iEC6dpa3cRrwfBviAK0zS6RjhsMmMPb8xTJoxTdpUtH)TNk8i26yI5g8WhRUl)TAa6iDNRK0XfzbZUDnQ7H7VIwEmxXsuJgNzCM220o9K)12w1X5tVavuU)6FKRPuapSCtclJumnWBXD8nlulu1sxUYVnXsWPMB(ql2kSAHEOCdiA2L0gmHl24BZy6)uVqD5AszXldt9lW1cBRzg(1(bdhVq7Npp57V6qZqWhmnAKTmVvt1sJiGikn6laDGwiTLSQj2GIIm2OrSvd8DzGb7bYtsmHEmC7sdwvevMIL9z6qZHA(Ha68Wurrk)KA47LMrGYNcMCsbLNZWSoFP5MRtcw8Md6KL5eiHfOSe41AQu6jN8Vva4kVCSDoIdzbjfsawFgLXNOpViWKPC0UweqaFTkGd34yzP4Q1Lotb1IgwciU5bvMeZtcGCb8jW4E1ksOghuZdYVnGo2rCQdi5mVy1FPNPyPqLOtA0SZeAC546XKFKsJvvOkvBBXDm8B6Eyip)qQzf1WbYUWhSUIUs0Ny0XCKwrK05cRf1WmEHGnBVd0PfndKkGM13kpGyPLLtQYSz7vjVdPc8OUjwbrYhILb4AdysTa1pNLGIe8uCIJkLVjAa6H)WrTMEbraijkvNHwu1Xigq19tlYXFD2)SaiYfBWulnScvrY4E5DXG88p()i35MxLuqcWxkcR7LVkJzjseyiWb)wGEgLetSNKjuzGFmtgu7bSZOagq52SLJQEg1BSssrEI7AckE8pOJXhjaeMxnH7n95OoUX5jiQJDQ48bfJ1G65M708IZXSdyYu3o3yoyLTOrh2UMSBlAaczPbTA4lkApBKi6JFNYXjSg(jlwt4NLnpFV54z(yDa4H6gyO6BAgL4cUe)o4QlwGhIKfBZTkTEzP7ZDEK)GOuJy6SNLwm)UM9aGg6)AXCzglwXZlkt4oHzJCp)4Qq8(XHBd42mJGkHm8)Wfsaq2F975iExIdodoF8VFB6CwO5VJDMdprtKrA5cihBi0mvbYPQ4KdjNJiS1Hbg4ls0Yz6LIve5r)kJp0CFyjnjT5vpJhSfb8WbUmmnlFww4QWidk(RXVaKc8tarCdT5bjWh3e(V4GZYjwLDiBfQETinzuRfeJwXzkLIljDgugHFYLB1Srber1uR2nu5wj13KMMx9qYWLaWPu0SvrEy47jG135Elwfq2Gdst8dZVZMb1xGfIYPlL9UJ7QdXHVKTSXyptT4CLwzWTiJ5BTVW3A0IZnukWeipTLLzcagr(WbzQHP4DRNoqUnU8mrxZrBif5vp1mnC4HDTp)2KQfiTYo5NXL6dfj3zSIJGQPuTp)qeOufCd5GF6VDhqlIzv)nb(Pjr0HZG5AdsNrEl(XysyXV0xvRKtxwHoV9wHukAxvpclhGAEk(b(KONIjr(NqO)wFxQlxl1XW1Uwa7PIutYB4HBBGjCqwpB4UG0Zl1hIOpWppdiMRcIb2Ei8QKu7rXSUeekUCgbiYlF1VkybD3E51CuvWyKHATjZmXKdw6vGeILGg35LbYicWJQZZ4bZyiCs8B0gZIA3KbGLfL0KVDnPvUjglrMUGqXTWAeKI5TEhyJKxXYUUpkGa2pKGhugISuc1cpjLiaq0PjkhKjK5plaXkiJhciU)JkMZrhJ1syk2rANP5BRhQQmrKiQcXdb7VsQGZtAiLZahMQvEX8Oonpo7mUmIvh1Fu11DM3le0PBzKNstIYXZsEcvMuvdorRIX)ftXKUkM6m42PMGtpYIUIo6)SIQLwOFs4Lm24vn02uTLQCS4EDt1LhlqlgJYJQ2JODlZYqDQ7qhkZDTgCQOPrbF8AvDTuyUmxojpzChmFBmb)fXBK3tI6VHXi)A0oYAfz9x3cTyLGRmqXcKvluhSliUYDjTZLU1D8d7V)QOeL0b9KWQubx1kTWWndfqQzP6Eqit1YFnL2fLFm(MWvjcMnK696WaKsI90lIagVKniMyV3dDgHiVSBBhu7bDee3wIvgTTfEmp8nNkSTO8JHBczMldSSPKU2cJUwowDIZNIIoMApGlsHERzCKoYSMP)d7SBH9sltEzZgqddpxtr5wYUcxAaDbLRm67KTSGlXLkK5BUyHQC6AdaaveKxbc0Tmv()frXf()sX4DQ4q2tWQxSLBvRmX3m8297JzXAx5ieYm(XV3LeSu87Wjk)IjZzm51LHXHzRdkZzpEcKGqbp(49nNOEUoaI7V(7K6buzsWB3aJKTVcROuRBvEXAoUCo5gSKvdUAgSbSF2C1mYuMZC8rxR60go0p1LZDJ5mGUscPIyqD9DZItUXZgd3FN(mSQbFxOe8eMkEA1Co4hYYiocP3wQzQQlpWF5Tyboy9mJxQzQBhBklCtYvX(SI5MUnBQwboIA3vUowxcTHFJGCB7AEQoy4PR3iEYAZD7vrET0DuYK8j753HaijZ0epwkmlIjl7CR5Em3ozHXTuDZxaRtlX7iSGy)7449tFVYzThha0TD0Y9YeVTvwsQx2TIE8kBJzNdqaXQ7W11fNtjzuB7cM4QZZPdtuwcQvLnP4a0uHfSUgs1z4kF2auHhZMHULG6v)ED1PnKME2Wttimu7fwJCVnTaKuj3L2b6dpgDk3MDGu12aC3XMTnLUKZOGDP7hTAVp2Qn3ZovbvcU8R70FOsjTOM9T8ndoarHIvmH6wfiUkZPD2HA22(PJs4JkT8wZ5tvB8Oiq9jrKJrMxWafPXu857)yGFbnXcUjG2QnsDIy)YtsRMY6LHaade)gU0gpeGtuH8G(VwcGO5RRqxPPHwolBlxojGYuS)3uEp7QnEmfOu5vMi3GP1SAOXzJRZ5io4mpW(TB4DMXWtXVoBoQ08qS2C5GI7UIfALU3vo5yUDw5essItpIfXp0X3tvD8f5Dp7yLW(Q4lUnpfAE(YSNOKnABrORYMT2lDts8DwUW9CbAClGPwnFYoTzuhRDlLhBSY7Vy2gVyVvbc8Fnnu0mTOUG90U2qz5(VnJjn3jJvo0kQrKOn(BnsuL7PCT27Tn6p0uHQURaLNydW9MPfd(SoUM666IQ5b2zFwhy49WGPbqLdPQ2DRGP9UMh7DBiH3LNyjhLQHPUTauQCZ308OCydDZr7lVnljWmO(5WnGsyxz)0FHWSsWKeehSjernPCefMbdOzITYN67d3Cxn9nIjTu0xEwImJr0yuOm(upv55wUcoAEWvF8s2vlPocuJF1W82lLX9Db8VWd9fRXoHq2Cbl((T0NSbXOeCjAMzAsZVv5urJMJMkZ(rJsug063OVp1Sl02LfPewWvUXjQrcPeO4W0aQzOwWDGiUBH5bPzbPOFrut4ApoJOKdB2)OyXkxBh(pJf5RbkXpXlK2oxrExmAF10r(ej6lmicPtGlbddT2TuPc0zb)jJRl2bJXjtUyKmoXJ0oZO05Qp4JHzcrfhN5(NiGPQYvcqBOWyWTz5PqOUyeLuZ4AVmR)os9wkbOQCiZfvgC5YzDrE0R4x53qGm0oLYUZ(hJxw)36LIuBqS79p)xFZp(M)6ZWlAW3Hr5eUzlLph06Wxlc79RXC(fCKlff(YsWyI8a)s34rXk5ZU5(7V)N(zk9eE8ZOd9p0X0NfTsFV5(sPJVMje)1s5m4JWV1D4h71hFnaAyGjVV9pSr2iJrMeX8)xX4P8xewrlhvpO2aDi)7F7p3(PiUgEyZUtVFJm9z3tEqnsJZkqz)HnP(uWm9J0qaR(t2lZ7D6TBa(mU91jldrlBF1xvEBEiEQkWFZ2Zvb(7Lpzf4F9GE2k4nWxQNUcXmOeWdHHuMyf(3RcPSE)5(4HjnJ2()VbJQJUpUzurARiJUdAo(F3xkyE8KV12JAXjHlNWTHE(PdgyVILhxsS4oFPl2TZ5Pv0E7YpPuyIzbTl7CZv(BOTFRvt)HOaRAOXBxX0HJTxvrw6CcQxEIJKnYEvfEqXQQ5Ho8KKTta)ZoHCgBYixnHQtJ0CMhUqLNmc7nq5rkbRS76cmtQ8sTe8mzFoHdEgJN8IegRL8Rm8VWrGPv3D7C4dNOUvOJCSD0jFDRdISD7QID05toRxNUUHeZEDECp3JlfCN0hBMqEX6wxGD5AWslqFwqnY9uYfww6ZpxxQjJoUcyPo7jTymmwApQzOP6CuvqPuo)T2Ja48jCWOE0PU4cHFhI8QJg4tNpz04Ayd4rYvhjYisWdRPgF8Oh11ESzDQhUOZNmCqVo1csKIocNaB0XX69KNCGZKbpKEB6H2BN9q6TjpTZr1atZbou66OxoFY4EpYX3SP78a72HK5dDivC3e6apO3syDSIQX5AOP4UXvWUOLT80jMyLSB3roqjHuv(Pcbc3tcv4p0NfobwPJDbx1(OeJb5sUf1snOABkR9CbSX3mCGAxkXKOjMSsOhSxYVIN3AFbbwqD4zaLa55zDynmDYOD7aZlwXxy3UQylm9j6A(1bkOjQNjwbClF36RwidmbeIZG9AU)(p)IFMX7sBXllQIxKOLfWL77l5Tgjsv6DiUH1t03R5QukfDsNsRRF(2wz9rgsvv3n5QdnTppDOtdedlvz7eJEruGVkRK59)K85Fjs(8YvDq75eD9u4AU7es36fOIrgqBZFWg8oAk4D0UD6E6vFnG4h0k(ux695F)4HJB0dnWJ0hDMXWyAtPsUvVuBCSGgr0iACNGvtz8ELIfxYdWtMkzK9Z0e88KgSDDX)c13Fb83rEByXws1vzvgdFN1iNWKwNHiju6Bp1kzZ2Q2gsh87YJkcS0dkJLbjXZ2i(LmrF6clwzq)Lp9014RRcFqZzzU9GKXGbNoCqNUhvnp2vMV))WSm3KGRLj(LGePqnjIO9eoh0KutQMdc8vILVUi7MmC3ozfuC5T2knDypUGO2qUfPqUcyAotFCfEL)uL73MCbY8G)eT0GNfdKa7VZ)oqGQCjvbaNkSik(WxYJypg6Eww)aoN6R0UD1MS3tLj6T4YcZEJ70thG3WH)DJvyj(SLD2v0kwML4QyAAN20XuOZfXsCNPPP5SBdM9rR(LbsQgtxVovi1LKQ)yNq1MRh2sJC76oDlx8qCehwMQ0tUyyh1CZ1PRTKNgetCNRZnkvVBN7k3rSLwvZrAj5QeeUhpQJl(xu3rvkrtt3EMlN2J0uE)fzuAZ8Agx4lZd6ZN8KXY4KiD2VFnDdu(s5DQnV1qfZ57D8iJrXsyErdiUedr2A(D3f3PLYBS(VLUyZr5Ud727tzwER)eLTbrCxAb2ckDd12v6h)cy04wz08Q8RtBUg)QQjPJJ7gVZ18INBjX2yWwDf4z390J7w1mXJg(4ETRBv863sa8)(6UXtFDUImYjvUj6G1Dl(eu6gGRn9OJdReGeBtxrCUvnY3wNpz3UDAudmGR7l9OjDoDU3Z5r0u(Z(nANjLWQgaHITFXJOFx8ZNqAPOxHtmqRuUxXPuwcSx9A3NpeqJLajkrrRkkcnXUky0o7jSNPDgzMfXT93QF9wevuR8w6ZDBsetmhMiPCRP7he2ssxh(pVw(FcET8RS8O5qeU(yvFrNUcsY0jJgFC3HJFux9xl)oOdBNF6a0zG7P1gPxhLC96oVv5w8LfhHmYOjpDmIXsd6aAuNzpLUu80eaUH5mPpKrov51ThcGX(lBptd6)2EH6RWfyQtukLB(0135iNpA9o999SkDx5geEFuI7shD5ETzK0kWGUMeTW2QTRUys15IJnizbZFKpTpu8)HJqs0G)S)QVx1KNy(z1NnlPVJIhi721Kpk4U)rIG0QJYlbFhPIWXGAy(oou9DF)8Q)U8nFhcOSsqfWuufrDEEk(59rBVwfuKQFA7wUx2zQ8oCtBGHtTxygIG7G5FUFj2TRzrUpRDTzBM)0SpDyNUUGgOfauyz5qIB4XWqR39m41kTBjCK1Sw7i21Mqus(mjCuBgBavXCo1RJTG5nDn(lWdIUDheX5Ngi0GRw1NuwnI)J7fHhdA46wFJ3iyA9CID8er4RFgE9YRAjWiFjjzjBR0s)wDiN0m58(jL0AamN8yIQ97Z3F82r31SHkJN5jLXmqS6gBFwh776Mux1PpI0r11oolk9diX0U98OBtfrbthNHWOyX(F7pr41RsXfdx3ZoUPNk8EDSPpQgsBJuF7(587JhZ7w4tKn3n5WTOGn(ObUdvdbg8(PjXTnvvVh)S8kCxLYy5zc3EeseTrnP1bIJUorc2gd7WF(FLTTlZiokiwMkvZx)QtdZT41Ew3O(4BdUNzBpPyXFy8KB7Kd40EDArcfOi5p(4Up(rCrvRpO296z1FvMeeNR)(59H7yFDeygp2x7trfg)VOp21TqvHwwm5(zWUY2y3XqMH98xpTBnG0jY4lYB(QAyp83VAxtpk92Pzw1KGftEy1Kiz)F4EzPpmWFoy(BRBC4j0tZg2IvF620)vqzk)LxMT5eiLIomMVCDG)heKj1x95WnBJOej3RegSSaUtKOxEehzMmsLuGgqhntUoYm2oBu2K)342YCNQtnS3ubwxtTg52otPnWG(bHejjkrBrlZVCtwLh(ZuT9fp8b6tc1QzmNvK8SKxd2bR3wW6vFIUNkojr3Nfz7pV2M0T)ZdF9VRF4RBa0NkmG2FhSlXv54b9h72Q(zhpsyux)1z9yMFswo)mIYB7fs9yxhijy5P3JUFoXIOM2weCQUPbTRI28tGzv8t5JnDv)h1ptUwSyOUn4vDmE6KHpT(JE6rwNzDmpbuthugIRoFqJ7oVihfT(ktRdQZVREUOB12T1a5)mjMxgeTAerAiBg(37J8CZeLdNh1jr6OpdbeOGMJnIFjx(HS0C(KrQy38P(jxUcr3XvEG5EzBZ3d6xQCk)6yFVWfHAoCWb4LXWpZU8EpC8zunoYDpATV8VcZMHK2M324gJMuRrFqpyYnQvGFPpqD2F2FQoljgIpnX4K5469VKWaHFrJu7d7zh2z0Xwg86(6fOXKtVNYX0sEIF2xjn0)0(8AwLADS5jzQsMoJ0PMoDBdh14mEeBpI)99RKzlOpHoF)gLrPQAcWf)H1RFIbU4NA44fE8WXtTLEXQdexN1q3nr3gQcEWkBXzVSxhJdt5WVJHZuZVzLTy5WYBtzZmScKU(d5tpzlikMV2H28eWfJ5rUpGUkNuIm(CPY1L0xHNtW77ZlzlMA56VcJ2K5CRuU25wJSmGeHZhCsWPA2iU6lnPSDbxlSk3psb21p9NR1pnpcKTyLPLhb2Mvyyc)TnjM9)E7zDSnei7YmAefxxOrnQPLksx7xwsAhg8EKID9N6rBUI0Rt1tAI9T6Yox9KZuwiR5PwSfeoNVcJS0T4Z0RQyTdSSdtXtJ6wOlpv)REZOXpLUAqV6)7d]] )


end
