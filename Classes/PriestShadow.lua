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


    spec:RegisterPack( "Shadow", 20220307, [[dmveZcqivipssvDjcviztssFIqLgLKsNssXQiuvEfePzrjCljHWUK4xscggvsDmkrlJqXZKeLPbr4Aqq2gvs4BQqLXPcsNtsvI1jjQEhHkKAEekDpQu7dIY)iuH6GsQIfcr1dHiAIsICrQKOnQcv9rcvKrkPkPtsOQALujEPKqKzkPk1nvbXoHa)usinuvOCujHOwkHkQNsKPkPYvHGARQG6Rsc1yjub2RQ8xvAWKoSulMkEmitMIlJAZG6Ze1OPuNwy1eQGETkWSPQBdPDR43knCcoovsA5aphQPl66QQTRI(oHmEcv58qO1tOcX8PK2pYplF19KmDYpeigxlgX46kZ1hxXYdfjQmlp0NuIOa)KeAOdAz(jnnk)KKSBZk6jj0i6328Q7jH3paIFs2zkGR8kub5iT)ofOfTc4a977m2bc0WzfWbkufEso)WNI)558KmDYpeigxlgX46kZ1hxXYdfjQmlpUNu)t7f8KKcuK8jzhgdppNNKHXqpjj72SIi9yGGXj5YH0aiBspolivmUwmIHCHCbjT7rMXvo5sfbP1jI7di9WByiTUfa4jjvKnpKMnqMtsH2)KysBatk8cGytHCPIG0Jb4KhdPMnXK2aM0VaPIS5H0SbYCIjTbmPq(fZKMlPgeJr2csXlPPDNKo)dymPnGjfNH3tkGHwuuEmSP8K8boXV6EsODmV6EiWYxDpjEAhpBEi)jbbIKbr)KC(WWfNDN7cFtB(2yiEmSP8fEs4eeq5dbw(KAOm25jb1E)THYyNRpW5tYh48onk)KC2DE5dbI5v3tIN2XZMhYFsqGizq0pPJinBGmNLaFf8nIm4j1qzSZtYeyb2FrB5a6LpeuzV6Es80oE28q(tQHYyNN05gMld(czSZtYWyiqiKXopjegZKE4nmK6kbFHm2H0DifAxVzfnKkSRpgzs7Kup34KuXGqKgdUNirK0AxaPiHRjfEbKIC)UgsDLEys3H0vGhgudPo)K0ztsdysrC)Kkk8Es3tga1cKgdUNirK0yi9WhFH0dPpGjf)bmPs2Tzfbh8yQWHeJXHhddiThdPhsmgsrUVXjPbM0DifAxVzfnK6WWlGj9WUssdysLSBZkc23OmPbMu2v)HGaBkKk(LNfWKkSRpgzsbmobbug7GjnGj9JJrMuj72SIG9nkt6XabgL0EmKICEmmG0at6(ZYtccejdI(jD2GOD8Cryx)fEbxidM0QKwlPXG7jsejfzUjvmiePiL0Aj1seIuXhP1skOH4IJFxZL9WKwL0mqzsflPvMRjTgsRHuRwjvGZcCWJP0qzCYKwLuWFy4fiZfSDBwrW(gLVcGaJwyx9hccSH0QKEePq76nROPGgJ564BCw(cKwL0JifAxVzfnfSDBwrxrlWCnCN2LVaP1qAvsRL0yW9ejIKkw3KEOiePwTsA2EEYcMBqmY3jKTt0gWfEAhpBiTkPNniAhpxWCdIr(oHSDI2a(c9ZfgM0AiTkPhrk0UEZkAkWbpMYxG0QKwlPhrkE)ENymLZ13z45lE9N8KfEAhpBi1QvsD(WWLZ13z45lE9N8KLVaPwTskMZmgzCjKNfWx86p5jjTMx(qas8Q7jXt74zZd5pPgkJDEsy72SIUIwG5k0X8KmmgceczSZt6q6dysXFatkI7NuHFs6xGuPkUYpgP1Ju9Cms3H00MjnBGmNKgWKwXGoTH)Esp(MbbtAGhXnjTHY4KjvKnpKchY2zmYKAzfrLrA2azoXLNeeisge9tY5ddxGB(k)BGj6bx(cKwL0Ji1WoFy4IiqN2WF)fUzqWLVaPvjflWE)nBGmN4cAmMlMBaPILuK4LpeGqV6Es80oE28q(tQHYyNNeAmMlMBWtccejdI(jLTNNSG5geJ8Dcz7eTbCHN2XZgsRskwG9(B2azoXf0ymxm3asrgPNniAhpxqJXCXCdUq)CHHjTkPhrQzZc2UnROROfyUcDmLmGoigzsRs6rKcTR3SIMcCWJP8fiTkPyb27VzdK5exqJXCXCdifzUjfjEsqic55B2azoXpey5lFiWv8Q7jXt74zZd5pPgkJDEsqT3FBOm256dC(K8boVtJYpjid(LpeCCV6Es80oE28q(tQHYyNNeAmMlMBWtccripFZgiZj(HalFsqGizq0pPS98Kfm3GyKVtiBNOnGl80oE2qAvsXcS3FZgiZjUGgJ5I5gqkYi9Sbr745cAmMlMBWf6NlmmPvj9isnBwW2TzfDfTaZvOJPKb0bXitAvspIuOD9Mv0uGdEmLVWtYWyiqiKXopP61q2M0JbIfejIKEiXyivIBaPnug7qAUKcyyaJTjTsBDysffPnPyUbXiFNq2orBa)Yhco0xDpjEAhpBEi)j1qzSZtY0OtNXopjieH88nBGmN4hcS8jbbIKbr)KQLuZMLZgviab0n3pKDbWWagB3oEMuRwj1SzbB3Mv0v0cmxHoMcGHbm2UD8mPwTsATKEePoFy4cAmMRHp3pGbLVaPvjngCprIiPILueY1KwdP1qAvsRLuNpmCX0GdUP9(LTZcoBOdivSK68HHlMgCWnT3VSDwqBX7IZg6asTAL0JifZ51zNpUKbdeZHEfJaeP18KmmgceczSZt6yagMbKMlPFmtALA0PZyhsRhP65yKgWKkvXv(XiDbKE46inWKoBs6xG0fqkI7NuOEMnjfQXjPnPZcqBpPvIp3pigzspMVL)mP1gdK)BIrM0djgdPvIp3pGbKkawiCnK2JHue3pPIcVN0ztsHAbsRudoG06S3VSDIjfNn0bysdys)4yKjToXCOKkgbOYlFiOE5v3tIN2XZMhYFsnug78KW2TzfDfTaZ1WDA)KmmgceczSZtcHXmPs2TzfrAfVadPvI70M0aM0pogzsLSBZkc23OmPhdeyus7XqQdpggqQOW7jLfpHaWKA(GyKjnTzshw8ssLHmLNeeisge9tsGZcCWJP0qzCYKwLuWFy4fiZfSDBwrW(gLVcGaJwyx9hccSH0QKkWzbo4XuamAhdMuX6MuzidPvjflWE)nBGmN4cAmMlMBaPI1nPh3lFiWsx)Q7jXt74zZd5pPgkJDEsOXyUo(gNpjdJHaHqg78KQhVOgrmPFmtkAmghFJtmPbmPqTGaBiThdP2)rMbXit65ggsdmPFbs7Xq6hhJmPs2Tzfb7BuM0JbcmkP9yi1HhddinWK(fkKsA9ymrg70EpIwqkuJtsrJX44BCsAatkI7Nur73Bi1Hj9pTJNjnxsL5K00MjfeWjPoisQOoYyKjTjvgYuEsqGizq0pPAjfAxVzfnf0ymxhFJZcKDdKzmPiJuljTkP1sQHD(WWf7)iZGyKVNBykFbsTAL0JinBppzX(pYmig575gMcpTJNnKwdPwTsQaNf4GhtbWODmysfRBsHACEZaLjfPKkdziTgsRsQaNf4GhtPHY4KjTkPG)WWlqMly72SIG9nkFfabgTWU6peeydPvjvGZcCWJPay0ogmPiJuOgN3mqzsRskwG9(B2azoXf0ymxm3asfRBsposTALuNpmCX0GdUP9(LTZYxG0QK68HHlNByGxaA5lqAvspIuOD9Mv0uo3WCDwFw(cKwL0Aj9isb)HHxGmxW2Tzfb7Bu(kacmAHD1FiiWgsTAL0JivGZcCWJP0qzCYKwdPvjfZ51zNpUKbdeZHErcbOx(qGLw(Q7jXt74zZd5pPgkJDEsNByUoRpFsggdbcHm25jHWyM0dVHHuKV(K0oj1oKTzaPcGybrIiPII0M061)iZGyKj9WByi9lqAUKIeKMnqMtSfKUas30MbKMTNNet6oKkvx5jbbIKbr)KIb3tKisQyDt6HIqKwL0S98Kf7)iZGyKVNByk80oE2qAvsZ2ZtwWCdIr(oHSDI2aUWt74zdPvjflWE)nBGmN4cAmMlMBaPI1nPUcsTAL0AjTwsZ2ZtwS)JmdIr(EUHPWt74zdPvj9isZ2ZtwWCdIr(oHSDI2aUWt74zdP1qQvRKIfyV)MnqMtCbngZfZnGu3KAjP18YhcSumV6Es80oE28q(tQHYyNNKHp3pig5RGVL)8tYWyiqiKXopjjbgkApPvIp3pigzspMVL)mPII0MujUbXitkccz7eTbmPIS5H0pULzsnFqmYKIK76nROb)KGarYGOFs1skMZRZoFCjdgiMd9IecqKA1kPz75jl2)rMbXiFp3Wu4PD8SH0AiTkPz75jlyUbXiFNq2orBax4PD8SH0QKkWzbo4XuAOmozsRsk4pm8cK5c2UnRiyFJYxbqGrlSR(dbb2qAvsD(WWLZnmWlaT8fiTkPyb27VzdK5exqJXCXCdivSUj1v8YhcSSYE19K4PD8S5H8NudLXopjdFUFqmYxbFl)5NKHXqGqiJDEsvAhXnj9JzsReFUFqmYKEmFl)zsdysrC)Kc1dPYCsAm5s6H3WaVausJbNCBSG0fqAatQe3GyKjfbHSDI2aM0atA2EEs2qApgsffEpP2rskp7x2M0SbYCIlpjiqKmi6NuTKcyyaJTBhptQvRKgdUNirKuKr6XHqKA1kPz75jlNByU5ca8KfEAhpBiTkPq76nROPCUH5MlaWtwamAhdMuX6M0kJuXhPYqgsRH0QKwlPhr6zdI2XZfHD9x4fCHmysTAL0yW9ejIKIm3KEOieP1qAvsRL0JinBppzbZnig57eY2jAd4cpTJNnKA1kP1sA2EEYcMBqmY3jKTt0gWfEAhpBiTkPhr6zdI2XZfm3GyKVtiBNOnGVq)CHHjTgsR5Lpeyjs8Q7jXt74zZd5pPgkJDEsNByUoRpFsggdbcHm25jHWyM0dJCs3HuKSsKgWKI4(j1SJ4MKomBinxsHACsAL4Z9dIrM0J5B5pBbP9yinTzatAdys9mgtAA3dPibPzdK5et6(tsRfHivuK2KcTJ5hznLNeeisge9tclWE)nBGmN4cAmMlMBaPIL0AjfjifPKcTJ5hzXey8o9KxgYEzCHN2XZgsRH0QKgdUNirKuX6M0dfHiTkPz75jlyUbXiFNq2orBax4PD8SHuRwj9isZ2ZtwWCdIr(oHSDI2aUWt74zZlFiWse6v3tIN2XZMhYFsnug78KW2TzfDfTaZ1WDA)KGqeYZ3SbYCIFiWYNeeisge9tQwsZgiZzXMBFAxeGssflPIX1KwLuSa793SbYCIlOXyUyUbKkwsrcsRHuRwjTwsf4Sah8yknugNmPvjf8hgEbYCbB3MveSVr5RaiWOf2v)HGaBiTkPyb27VzdK5exqJXCXCdivSUj94iTMNKHXqGqiJDEsimMjvYUnRisR4fyQCsRe3PnPbmPPntA2azojnWK2o7pjnxsnbt6cifX9tQDFYKkz3MveSVrzspgiWOKYU6peeydPII0M0djgJdpggq6civYUnRi4GhdPnugNC5LpeyPR4v3tIN2XZMhYFsnug78KWFaGhddU5ErBZWy8tccripFZgiZj(HalFsqGizq0pPSbYCwYaLV5EnbtQyjvmUM0QK68HHlNByGxaAXSIMNKHXqGqiJDEsimMjv6da8yyaP5s6H0MHXys3H0M0SbYCsAA3jPbMu5ngzsZLutWK2jPPntkiKTtsZaLlV8HalpUxDpjEAhpBEi)j1qzSZt6CdZnxaGN8jbHiKNVzdK5e)qGLpjiqKmi6N0zdI2XZfZM47xG0QKwlPoFy4Y5gg4fGwmROHuRwj15ddxo3WaVa0cGr7yWKkwsH21Bwrt5CdZ1z9zbWODmysTALubaFELHmfllNByUoRpjTkPhrQZhgU44314)4Sa4gkjTkPyb27VzdK5exqJXCXCdivSKwzKwdPvj9Sbr745YzIVTGGpydPvjflWE)nBGmN4cAmMlMBaPIL0AjfHifPKwlPUcsfFKMTNNSKIcCEx4lCNCHN2XZgsRH0AEsggdbcHm25jHWyM0dVHH06waGNK0D8isAatQufx5hJ0EmKE46iTbmPnugNmP9yinTzsZgiZjPI2rCtsnbtQ5dIrM00MjfYUNH9Lx(qGLh6RUNepTJNnpK)KGarYGOFs1sA2EEYcMBqmY3jKTt0gWfEAhpBiTkPyb27VzdK5exqJXCXCdifzKE2GOD8CbngZfZn4c9ZfgMuRwj1SzbB3Mv0v0cmxHoMsgqheJmP1qAvspBq0oEUCM4Bli4d28KAOm25jHgJXHhddE5dbwwV8Q7jXt74zZd5pPgkJDEsy72SIUIwG5A4oTFsggdbcHm25jHWyMuPkUYRePII0M0J1X4a4(agq6XWThL0)4zmM00MjnBGmNKkk8EsDysDy)kIuX4AXrrQddVaM00MjfAxVzfnKcTOmMuNg6GYtccejdI(jb(ddVazUi0X4a4(agCfWThTWU6peeydPvj9Sbr745Izt89lqAvsZgiZzjdu(M7vakVIX1KImsRLuOD9Mv0uW2TzfDfTaZ1WDAxmFqNXoKIusLHmKwZlFiqmU(v3tIN2XZMhYFsnug78KW2TzfDHan2(jzymeieYyNNecJzsLSBZkIuKe0yBs3HuKSsK(hpJXKM2mGjTbmPTXGjngOfng5YtccejdI(jb6WC5tEYsBm4smKImsT01V8HaXy5RUNepTJNnpK)KGarYGOFsyb27VzdK5exqJXCXCdifzKE2GOD8CbngZfZn4c9ZfgM0QK68HHlMgCWnT3VSDw(cpjdJHaHqg78Kqymt6HeJHujUbKMlPq7G)OmPvQbhqAD27x2oXKkawimP7qA9urDLfsRRIwPkkPi5oWbaL0atAAhysdmPnP2HSndivaelisejnT7HuaB2mJrM0DiTEQOUss)JNXysnn4ast79lBNysdmPTZ(tsZL0mqzs3F(KGqeYZ3SbYCIFiWYNumjdaFH8gWpPmGoaJm3iXtkMKbGVqEduu2eDYpjlFsq2DmpjlFsnug78KqJXCXCdE5dbIrmV6Es80oE28q(tYWyiqiKXopjegZKEiXyi949nIKMlPq7G)OmPvQbhqAD27x2oXKkawimP7qQuDKU)ehgM0fM0dF8LNeeisge9tY5ddxmn4GBAVFz7S8fiTkPNniAhpxmBIVFbsRs6rK68HHlNByGxaA5lqAvspI0ZgeTJNlc76VWl4czWKwLuOD9Mv0uqJXCD8nolWFV)cyi7giZ3mqzsrMBsLHmf0w8EsXKma8fYBa)KYa6amYCJevpY5ddxmn4GBAVFz7S8fEsXKma8fYBGIYMOt(jz5tcYUJ5jz5tQHYyNNeAmMlSVr8LpeiMk7v3tIN2XZMhYFsnug78KqJXCD8noFsggdbcHm25jHWyM0djgdPi334K0aMue3pPMDe3K0HzdP5skGHbm2M0kT1HlKkLRaPqnoJrM0ojfjiDbKIUaM0SbYCIjvuK2KkXnigzsrqiBNOnGjnBppjBiThdPiUFsBat6SjPFCmYKkz3MveSVrzspgiWOKUaspggri7aI06DmhuWcS3FZgiZjUGgJ5I5gGmXXiePYCIjnTzsrJjq)OKUWKIqK2JH00MjD(OomG0fM0SbYCIlKwpE8AbPML0ztsfamgtkAmghFJts)tgEsBVN0SbYCIjTbmPMnt2qQOiTj9W1rQiBEi9JJrMuSDBwrW(gLjvaeyusdysD4XWasdmP9zh(2XZLNeeisge9t6Sbr745Izt89lqAvsbDyU8jpzbDpzuEYsmKImsHACEZaLjfPK66ccrAvsXcS3FZgiZjUGgJ5I5gqQyjTwsrcsrkPIHuXhPz75jlObMbiw4PD8SHuKsAdLXjFnBwoBuHaeq3C)q2Kk(inBppzraJiKDaD9XCqHN2XZgsrkP1skwG9(B2azoXf0ymxm3asrM4ysrisRHuXhP1sQaNf4GhtPHY4KjTkPG)WWlqMly72SIG9nkFfabgTWU6peeydP1qAnKwL0Aj9isb)HHxGmxW2Tzfb7Bu(kacmAHD1FiiWgsTAL0JifAxVzfnf4Ght5lqAvsb)HHxGmxW2Tzfb7Bu(kacmAHD1FiiWgsTAL0ZgeTJNlNj(2cc(GnKwZlFiqmiXRUNepTJNnpK)KAOm25jD2OcbiGU5(HSFsqic55B2azoXpey5tccejdI(jbyyaJTBhptAvsZgiZzjdu(M71emPiZnPwEOKwL0Aj1Sz5SrfcqaDZ9dzxYa6GyKj1QvspI0ZgeTJNlNj(2cc(GnKwdPvj9Sbr745cAlE3ZetkYi11KA1kP1sA2EEYcAGzaIfEAhpBiTkPMnly72SIUIwG5k0XuammGX2TJNjTgsTALuNpmC5pWFGpg5RPbhmmgx(cpjdJHaHqg78KeNzyaJTj9WnQqacisRB)q2KkkWShrsDAmBiDhsRuJoDg7qApgs30MbKwx75jXLx(qGyqOxDpjEAhpBEi)j1qzSZtcB3Mv0v0cmxHoMNKHXqGqiJDEsscmu0EsH2XezSdP5skoxbsHACgJmPsvCLFms3H0fgUIiBGmNysfzZdPWHSDgJmPvgPlGu0fWKIZg6a2qk66GjThdPFCmYKEmmIq2beP17yoG0EmKIGkADKEibMbiwEsqGizq0pjaddySD74zsRsA2azolzGY3CVMGjfzKIeKwL0JinBppzbnWmaXcpTJNnKwL0S98KfbmIq2b01hZbfEAhpBiTkPyb27VzdK5exqJXCXCdifzKkMx(qGyCfV6Es80oE28q(tYWyiqiKXopPksmlqQufx5hJ0VaP7qAJjfThejnBGmNysBmPclghoE2cszXdIfssfzZdPWHSDgJmPvgPlGu0fWKIZg6a2qk66GjvuK2KEmmIq2beP17yoO8KGarYGOFsaggWy72XZKwL0SbYCwYaLV5EnbtkYifjiTkPhrA2EEYcAGzaIfEAhpBiTkPhrATKMTNNSG5geJ8Dcz7eTbCHN2XZgsRskwG9(B2azoXf0ymxm3asrgPNniAhpxqJXCXCdUq)CHHjTgsRsATKEePz75jlcyeHSdORpMdk80oE2qQvRKwlPz75jlcyeHSdORpMdk80oE2qAvsXcS3FZgiZjUGgJ5I5gqQyDtQyiTgsR5j1qzSZtcB3Mv0v0cmxHoMx(qGyoUxDpjEAhpBEi)j1qzSZtc2ZyBiqdNpPysga(c5nGFszaDagzUT8jftYaWxiVbkkBIo5NKLpjiqKmi6NeE)ENymLZ13z45lE9N8KfEAhpBiTkPhrQZhgUCUHbEbOLVaPvj9isD(WWfHvedUXa)XXoLVaPvj15ddxoxFNHNV41FYtwamAhdMuXsQLU(jzymeieYyNNecJzspEpJTHanCs6(tCyysxysr7yifAxVzfnysZLu0oMSJH0dV(odptQ06p5jj15ddxE5dbI5qF19K4PD8S5H8Neeisge9tclWE)nBGmN4cAmMlMBaPiJ0ZgeTJNlOXyUyUbxOFUWWpPysga(c5nGFszaDagzUfZtkMKbGVqEduu2eDYpjlFsq2DmpjlFsnug78KqJXCXCdE5dbIPE5v3tIN2XZMhYFsnug78KqJXCH9nIpPysga(c5nGFszaDagzUft1ApY5ddxmn4GBAVFz7S8fSAfAxVzfnLZnmxN1NLVq1AD(WWLZnmWlaT8fSA9iNpmCX0GdUP9(LTZYxOQZhgUycmENEYldzVmU8fQPMNumjdaFH8gOOSj6KFsw(KGS7yEsw(YhcQmx)Q7jXt74zZd5pjdJHaHqg78KqymtQufx5vI0gtQVXjPagVGK0aM0DinTzsr3t(j1qzSZtcB3Mv0v0cmxd3P9lFiOYS8v3tIN2XZMhYFsggdbcHm25jHWyMuPkUYpgPnMuFJtsbmEbjPbmP7qAAZKIUNmP9yivQIR8krAGjDhsrYk9KAOm25jHTBZk6kAbMRqhZlF5tYWW93NV6EiWYxDpjEAhpBEi)jzymeieYyNNKRu8yOFYgs5tgGiPzGYKM2mPnuUasdmP9zh(2XZLNudLXopjC45bIF5dbI5v3tIN2XZMhYFsqGizq0pjNpmC5Cdd8cqlFbsTALuNpmCryfXGBmWFCSt5l8KAOm25jjSzSZlFiOYE19K4PD8S5H8N0k8KWC(KAOm25jD2GOD88t6S9F(jvlPMnly72SIUIwG5k0XuYa6GyKj1QvsZgiZzjdu(M71emPI1nPibP1qAvsRLuZMLZgviab0n3pKDjdOdIrMuRwjnBGmNLmq5BUxtWKkw3K6kiTMN0zdUtJYpjZM47x4LpeGeV6Es80oE28q(tAfEsyoFsnug78KoBq0oE(jD2(p)KoBq0oEUy2eF)cKwL0Aj1SzXWN7heJ8vW3YFUKb0bXitQvRKMnqMZsgO8n3RjysfRBsrcsR5jD2G70O8tQ9(Rzt89l8YhcqOxDpjEAhpBEi)jTcpjmNpPgkJDEsNniAhp)KoB)NFsyb27VzdK5exqJXCXCdifzKkgsrkPoFy4Y5gg4fGw(cpjdJHaHqg78KKYgKK(XXitQe3GyKjfbHSDI2aM0ojTYqkPzdK5et6cifjqkPbmPiUFsBatAmKE4nmWla9jD2G70O8tcZnig57eY2jAd4l0pxy4x(qGR4v3tIN2XZMhYFsRWtcZ5tQHYyNN0zdI2XZpPZ2)5NuTKEePG)WWlqMlybBgW4RDdq3bXc7Q)qqGnKwL0JifAp5PNSmmey9lWqQvRKcTR3SIMIWkIb3yG)4yNcGr7yWKkw3KkdzkOT4rQ4J0kJuRwj15ddxewrm4gd8hh7u(cKA1kPolgtAvsHdz78cy0ogmPI1nPIbHiTMN0zdUtJYpjiZfTNwMr5jF5dbh3RUNepTJNnpK)KwHNeMZNudLXopPZgeTJNFsNT)ZpjSa793SbYCIlNnQqacOBUFi7N0zdUtJYpj0w8UNj(LpeCOV6Es80oE28q(tAfEsyoFsnug78KoBq0oE(jD2(p)KqisrkPIHuXhP1s6zdI2XZfiZfTNwMr5jjTkPq76nROPCUH5YGVqg7uamAhdMuX6MulDnP1qAvsZ2ZtwS)JmdIr(EUHPWt74zZtccejdI(jLTNNSG5geJ8Dcz7eTbCHN2XZgsRskwG9(B2azoXf0ymxm3asDt6X9KoBWDAu(jH2I39mXV8HG6LxDpjEAhpBEi)jTcpjmNpPgkJDEsNniAhp)KoB)NFsU(jbbIKbr)KY2ZtwWCdIr(oHSDI2aUWt74zdPvjflWE)nBGmN4cAmMlMBaPiJ0J7jD2G70O8tcTfV7zIF5dbw66xDpjEAhpBEi)jTcpjmNpPgkJDEsNniAhp)KoB)NFsiXtccejdI(jLTNNSG5geJ8Dcz7eTbCHN2XZgsRskwG9(B2azoXf0ymxm3asDt6HsAvspI0S98KfSDBwrxiqJTl80oE28KoBWDAu(jH2I39mXV8HalT8v3tIN2XZMhYFsRWtcZ5tQHYyNN0zdI2XZpPZ2)5NuTKIfyV)MnqMtCbngZfZnGuX6MueI0Aiv8rkwG9(B2azoXf0ymxm3GNeeisge9tY5ddxo3WaVa0Yx4jD2G70O8tcTfV7zIF5dbwkMxDpjEAhpBEi)jTcpjmNpPgkJDEsNniAhp)KoB)NFsU(jzy4(7ZNKLpPZgCNgLFsb(EMxHfJdhp)YhcSSYE19K4PD8S5H8N0k8KWC(KAOm25jD2GOD88t6S9F(jz5tccejdI(j1qzCYxZMLZgviab0n3pKnPILuieH88Lhgny8t6Sb3Pr5NuGVN5vyX4WXZV8HalrIxDpjEAhpBEi)jTcpjmNpPgkJDEsNniAhp)KoB)NFsnugN81Sz5SrfcqaDZ9dztkYCt6zdI2XZf0w8UNjMuRwj9ispBq0oEUe47zEfwmoC88t6Sb3Pr5N0zIVTGGpyZlFiWse6v3tIN2XZMhYFsRWtcZ5tQHYyNN0zdI2XZpPZ2)5Ne0UEZkAkNByUm4lKXoLVaPvj9Sbr745cK5I2tlZO8KpjdJHaHqg78KqYD9Mv0q6X21t6HBq0oE2csrymBinxsf21tQddVaM0gkJZoJrM0dVHbEbOLN0zdUtJYpjHD9x4fCHm4x(qGLUIxDpjEAhpBEi)jbbIKbr)KC(WWLZnmWlaT8fEsnug78KGda74318YhcS84E19K4PD8S5H8Neeisge9tY5ddxo3WaVa0Yx4j1qzSZtYHbygCqmYV8Halp0xDpjEAhpBEi)j1qzSZtYhY2j(ko8BKr5jFsggdbcHm25jHWyM06DiBNIlMux(gzuEssdystBgWK2aMuXq6cifDbmPzdK5eBbPlG02yWK2aEe3KuSqlAIrMu4fqk6cyst7Ei94qiC5jbbIKbr)KWcS3FZgiZjU4dz7eFfh(nYO8KKIm3KkgsTAL0Aj9isbDyU8jpzPngCHfVaNysTALuqhMlFYtwAJbxIHuKr6XHqKwZlFiWY6LxDpjEAhpBEi)jbbIKbr)KC(WWLZnmWlaT8fEsnug78K6bIXjO9xO27F5dbIX1V6Es80oE28q(tQHYyNNeu793gkJDU(aNpjFGZ70O8tcse0lFiqmw(Q7jXt74zZd5pPgkJDEsG)CBOm256dC(K8boVtJYpj0oMx(YNeKiOxDpey5RUNepTJNnpK)KGarYGOFsyoVo78XLmyGyo0lsiarAvsD(WWftdo4M27x2olFbsRsQaNf4GhtPHY4KjTkPG)WWlqMly72SIG9nkFfabgTWU6peeydPvj9isD(WWLZnmWlaT8fiTkPcCwqC)Gl2UnROcGr7yWKkwsHdz78cy0ogmPwTsQZhgUyAWb30E)Y2z5lqAvsf4SG4(bxSDBwrfaJ2XGjvSKkdzkOT4rQ4J0AjTYifPKwlPhrQZhgUCUHbEbOLVaP1qQ4JulDfKwdPvjvGZcI7hCX2TzfvamAhdMuXskCiBNxaJ2XGFs74r8cjc6jz5tYWyiqiKXopP6eZHsksurG5KuODmrg70EsHxaPizfJKKEiXyif5(gNpPgkJDEsOXyUo(gNV8HaX8Q7jXt74zZd5pPpMVISdpFHACgJ8dbw(KAOm25jH5geJ8Dcz7eTb8tccripFZgiZj(HalFsqGizq0pPAj9Sbr745cMBqmY3jKTt0gWxOFUWWKwL0Ji9Sbr745IWU(l8cUqgmP1qQvRKwlPMnly72SIUIwG5k0XuammGX2TJNjTkPyb27VzdK5exqJXCXCdifzKAjP18KmmgceczSZtcHXmPsCdIrMueeY2jAdysdysrC)Kkk8EsTJKuE2VSnPzdK5etApgsp2kIbKk(h4po2H0EmKE4nmWlaL0gWKoBskGBdIwq6cinxsbmmGX2KkvXv(XiDhstrlPlGu0fWKMnqMtC5LpeuzV6Es80oE28q(t6J5Ri7WZxOgNXi)qGLpPgkJDEsyUbXiFNq2orBa)KGqeYZ3SbYCIFiWYNeeisge9tkBppzbZnig57eY2jAd4cpTJNnKwLuZMfSDBwrxrlWCf6ykaggWy72XZKwLuSa793SbYCIlOXyUyUbKImsfZtYWyiqiKXopjj7fKKIKba6hjPsCdIrMueeY2jAdysH2XezSdP5s6bmlqQufx5hJ0VaPXqA9SUYx(qas8Q7jXt74zZd5pPD8iEHeb9KS8j1qzSZtcngZ1X348jzymeieYyNN0oEeVqIGifTpGXKM2mPnug7q6oEej9JBhptQ5dIrMui7Eg2hJmP9yiD2K0gtAtkGL)(gqAdLXoLx(YNeKb)Q7HalF19K4PD8S5H8NudLXopjHvedUXa)XXopjdJHaHqg78Kqymt6XwrmGuX)a)XXoKkksBsp8gg4fGwiTED9gsHxaPhEdd8cqjfArzmPlmmPq76nROH0yinTzshw8ssT01KIzODmys30MbIcmt6hZKUdPqgs)JNXystBMubFJidinWKk0GK0fM00Mj9aebrpKcTN80tAbPlG0aM00MbmPIcVN0ztsDys7ztBgq6H3WqQRe8fYyhst7atkCiBNfsRNmzuHK0CjfJ4arAAZK6BCsQWkIbKgd8hh7q6ctAAZKchY2jP5s65ggszWxiJDifEbKo7qAfjebrp4YtccejdI(jjacgNfm7HVcRigCJb(JJDiTkP1sQZhgUCUHbEbOLVaPwTs6rKcTN80twoarq0dPvj9isH2tE6jlddbw)cmKwLuOD9Mv0uo3WCzWxiJDkagTJbtkYCtQLUMuRwjfoKTZlGr7yWKkwsH21Bwrt5CdZLbFHm2Pay0ogmP1qAvsRLu4q2oVagTJbtkYCtk0UEZkAkNByUm4lKXofaJ2XGjfPKAjcrAvsH21Bwrt5CdZLbFHm2Pay0ogmPI1nPYqgsfFKIeKA1kPWHSDEbmAhdMuKrk0UEZkAkcRigCJb(JJDkMpOZyhsTALuNfJjTkPWHSDEbmAhdMuXsk0UEZkAkNByUm4lKXofaJ2XGjfPKAjcrQvRKcTN80twoarq0dPwTsQZhgU44314)4S8fiTMx(qGyE19K4PD8S5H8NKHXqGqiJDEsimMjf5TrMjngCyysxysp8Xtk8cinTzsHdaoj9JzsxaP7qkswjsB4KbKM2mPWbaNK(XCH0kosBsrqiBNKE8ntQ96nKcVasp8XxEstJYpjCmWF)v23MOZfGVoTrMVl8fMbluKi(KGarYGOFsoFy4Y5gg4fGw(cKA1kPzGYKImsT01KwL0Aj9isH2tE6jltiBNx4MjTMNudLXopjCmWF)v23MOZfGVoTrMVl8fMbluKi(YhcQSxDpjEAhpBEi)j1qzSZtcU5R8VbMOh8tYWyiqiKXopjegZKE8ntQ40VbMOhmP7qkswjs3FIddt6ct6H3WaVa0cPimMj94BMuXPFdmrpgmPXq6H3WaVausdysrC)KA3NmPCK2mGuXjWEYKk(NZqEbDg7q6ci94d2BiDHjf5(fJxuCH0kUJKu4fqQztmP5sQdt6xGuhgEbmPnugNDgJmPhFZKko9BGj6btAUKI2IxGgyM00Mj15ddxEsqGizq0pPJi15ddxo3WaVa0YxG0QKwlPhrk0UEZkAkNByU5ca8KLVaPwTs6rKMTNNSCUH5MlaWtw4PD8SH0AiTkP1s6zdI2XZfZM47xG0QKIfyV)MnqMtC5SrfcqaDZ9dztQBsTKuRwj9Sbr745YzIVTGGpydPvjflWE)nBGmN4YzJkeGa6M7hYMuKrQLKwdPwTsQZhgUCUHbEbOLVaPvjTwsX737eJPid2t(gZziVGoJDk80oE2qQvRKI3V3jgtboyV5UWxh)IXlkUWt74zdP18YhcqIxDpjEAhpBEi)j1qzSZtcngJCJY4NeeIqE(MnqMt8dbw(KGarYGOFsXG7jsejvSKwV4AsRsATKwlPNniAhpxAV)A2eF)cKwL0Aj9isH21Bwrt5CdZLbFHm2P8fi1QvspI0S98Kf7)iZGyKVNByk80oE2qAnKwdPwTsQZhgUCUHbEbOLVaP1qAvsRL0JinBppzX(pYmig575gMcpTJNnKA1kPg25ddxS)JmdIr(EUHPay0ogmPiJuOgN3mqzsTAL0Ji15ddxo3WaVa0YxG0AiTkP1s6rKMTNNSG5geJ8Dcz7eTbCHN2XZgsTALuSa793SbYCIlOXyUyUbKkwsrisR5jzymeieYyNNecJzspKymYnkJjvKnpK2EpPvgPvARdtAdys)cwq6cifX9tAdysJH0dVHbEbOfsDLd(dysRx)JmdIrM0dVHHurH3tkodVNuhM0VaPIS5H00MjfQXjPzGYKchtGTzCHuPCfi9JJrM0ojfHqkPzdK5etQOiTjvIBqmYKIGq2orBaxE5dbi0RUNepTJNnpK)KAOm25j9h71J4D2Z(jzymeieYyNNecJzsr4XE9iskc2ZM0DifjRKfKAVEtmYK6acg2JiP5sQOossHxaPcRigqAmWFCSdPlG02yifl0IgC5jbbIKbr)KoI0S98Kf7)iZGyKVNByk80oE2qAvspBq0oEUy2eF)cKA1kPg25ddxS)JmdIr(EUHP8fiTkPoFy4Y5gg4fGw(cKA1kP1sk0UEZkAkNByUm4lKXofaJ2XGjfzKAPRj1QvspI0ZgeTJNlc76VWl4czWKwdPvj9isD(WWLZnmWlaT8fE5dbUIxDpjEAhpBEi)j1qzSZtYz35UW30MVngIhdBEsggdbcHm25jHWyM0DifjRePo)KubqSGidmt6hhJmPhEddPUsWxiJDifoa40csdys)y2qAm4WWKUWKE4JN0DivQos)yM0gozaPnPNByCwFsk8cifAxVzfnKYWWbuWdeIK2JHu4fqQ9FKzqmYKEUHH0VqgOmPbmPz75jzt5jbbIKbr)KoIuNpmC5Cdd8cqlFbsRs6rKcTR3SIMY5gMld(czSt5lqAvsXcS3FZgiZjUGgJ5I5gqkYi1ssRs6rKMTNNSG5geJ8Dcz7eTbCHN2XZgsTAL0Aj15ddxo3WaVa0YxG0QKIfyV)MnqMtCbngZfZnGuXsQyiTkPhrA2EEYcMBqmY3jKTt0gWfEAhpBiTkP1sQaGpVYqMILLZnmxN1NKwL0Aj9iszx9hccSPWOcic42FxGz6bIj1QvspI0S98Kf7)iZGyKVNByk80oE2qAnKA1kPSR(dbb2uyubebC7VlWm9aXKwLuOD9Mv0uyubebC7VlWm9aXfaJ2XGjvSUj1sxHyiTkPg25ddxS)JmdIr(EUHP8fiTgsRHuRwjTwsD(WWLZnmWlaT8fiTkPz75jlyUbXiFNq2orBax4PD8SH0AE5dbh3RUNepTJNnpK)KAOm25jb1E)THYyNRpW5tYh48onk)KsqmhWj(LpeCOV6Es80oE28q(tccejdI(jzZTpTlcqjPI1nPhhc9KAOm25jzySad6KVcGgrg8Yx(KsqmhWj(v3dbw(Q7jXt74zZd5pjdJHaHqg78KqymtAcI5aojTHtgqQW37jfNniXK2JH00Mhs3HuKSsK2WjdinT7K0)KHNue3pPYCsksK2KIZg6GcP1bqK0Cj1W(grsL5mJrMuekTjfNn0bKcVasH21BwrdUqkcJzsDy4fWKUPndiDhs)yM0CjD2K0eeYYmGuXpswjsD4ueZdPjiMd4etAToFzXX1uEstJYpjmudW3f(cd6Kbt7V4eeW8tccejdI(jvlPhrQZhgUGHAa(UWxyqNmyA)fNGaMVir5lqAvsZaLjfzKAjP1qQvRKwlPoFy4Y5gg4fGw(cKA1kPoFy4IWkIb3yG)4yNYxGuRwjfAxVzfnLZnmxg8fYyNcGr7yWKImsT01KwdPwTsk0EYtpzzcz78c38tQHYyNNegQb47cFHbDYGP9xCccy(LpeiMxDpjEAhpBEi)jzymeieYyNNecJzs3HuKSsKwps1ZXinxsL5K0kT1rAgqheJmP9yiLfpHaWKMlP(yys)cK6WzYasffPnPhEdd8cqFstJYpjgvara3(7cmtpq8tccejdI(jbTR3SIMY5gMld(czStbWODmysfRBsTumKA1kPq76nROPCUH5YGVqg7uamAhdMuKrQyoUNudLXopjgvara3(7cmtpq8lFiOYE19K4PD8S5H8NKHXqGqiJDEs1bqK0CjvcXbIuXFf5krQOiTjTs73XZKkLn0bSHuKSsysdysfwmoC8CH0k6qQFhzgqkCiBNysffPnPOlGjv8xrUsK(XmM0otgvijnxsXioqKkksBs7brsHmKUasfh(XjPFmtAKLN00O8tkgme4NTJNVU6VN8JEn8zaXpjiqKmi6NKZhgUCUHbEbOLVaPvj15ddxewrm4gd8hh7u(cKA1kPolgtAvsHdz78cy0ogmPI1nPIX1KA1kPoFy4IWkIb3yG)4yNYxG0QKcTR3SIMY5gMld(czStbWODmysrkPwIqKImsHdz78cy0ogmPwTsQZhgUCUHbEbOLVaPvjfAxVzfnfHvedUXa)XXofaJ2XGjfPKAjcrkYifoKTZlGr7yWKA1kP1sk0UEZkAkcRigCJb(JJDkagTJbtkYCtQLUM0QKcTR3SIMY5gMld(czStbWODmysrMBsT01KwdPvjfoKTZlGr7yWKIm3KAz9IRFsnug78KIbdb(z745RR(7j)OxdFgq8lFiajE19K4PD8S5H8NKHXqGqiJDEssioqKkzZCs6H8XbePII0M0dVHbEbOpPPr5NeAd1oa(ITzoVOFCa9KGarYGOFsq76nROPCUH5YGVqg7uamAhdMuKrQLU(j1qzSZtcTHAhaFX2mNx0poGE5dbi0RUNepTJNnpK)KMgLFs4979CMXiFbFheFsqic55B2azoXpey5tQHYyNNeE)EpNzmYxW3bXNeeisge9tY5ddxewrm4gd8hh7u(cKA1kPhrQaiyCwWSh(kSIyWng4po2HuRwjLD1FiiWMc2UnRi2CxGZDHV5cq5jFsggdbcHm25jjH4arQ483brsffPnPhBfXasf)d8hh7q6h3YSfKI2hWKI)aM0CjfpHatAAZK6xrmojTE9yKMnqMZcPvSnpK(XSHurrAtQKDBwrSH0kkWH0fM06wakpPfKko8Jts)yM0DifjRePnMu0pKnPnMuHfJdhpxE5dbUIxDpjEAhpBEi)jzymeieYyNN0XhaCsQuihEsXOT3t6kKbAiosNXoKkksBsL2V3ZzgJmPIZFheFstJYpP0MVWbaNxCih(Neeisge9tY5ddxo3WaVa0YxGuRwj15ddxewrm4gd8hh7u(cKA1kPhrQaiyCwWSh(kSIyWng4po2HuRwjfAxVzfnLZnmxg8fYyNcGr7yWKImsT01KA1kP1sk7Q)qqGnf8(9EoZyKVGVdIKwL0JifAxVzfnf8(9EoZyKVGVdILVaP1qQvRK6SymPvjfoKTZlGr7yWKkwsfJRFsnug78KsB(chaCEXHC4F5dbh3RUNepTJNnpK)KmmgceczSZtcHXmPiVnYmPXGddt6ct6HpEsHxaPPntkCaWjPFmt6ciDhsrYkrAdNmG00Mjfoa4K0pMlKkzVGKuOaa9JK0aM0ZnmKYGVqg7qk0UEZkAinWKAPRXKUasrxatAlQrS8KMgLFs4yG)(RSVnrNlaFDAJmFx4lmdwOir8jbbIKbr)KG21Bwrt5CdZLbFHm2Pay0ogmPiZnPw66NudLXopjCmWF)v23MOZfGVoTrMVl8fMbluKi(Yhco0xDpjEAhpBEi)jzymeieYyNNecJzsLSBZkInKwrboKUWKw3cq5jjvKnpKoBsAmKE4nmWla1csxaPXqQdNIyEi9WByif5RpjfQXjM0yi9WByGxaAH06btAfjebrpKUasradbw)cmK6JHjnss)cKkksBsXzdDaBifAxVzfn4YtAAu(jHTBZkIn3f4Cx4BUauEYNeeisge9tcAxVzfnfHvedUXa)XXofaJ2XGjvSUj1sxtAvsH21Bwrt5CdZLbFHm2Pay0ogmPI1nPw6AsRsATKcTN80twggcS(fyi1QvsH2tE6jlhGii6H0Ai1QvsRLuO9KNEYYjpPnIasTALuO9KNEYYeY25fUzsRH0QKwlPhrQZhgUCUHbEbOLVaPwTsQaGpVYqMILLZnmxN1NKwdPwTsQZIXKwLu4q2oVagTJbtQyDtks46NudLXopjSDBwrS5UaN7cFZfGYt(YhcQxE19K4PD8S5H8NudLXopPgazhjdL4BmY88JeXl0c4NKHXqGqiJDEsimMjnTdmP7qkswjsHxaPOT4rkswjX5N00O8tQbq2rYqj(gJmp)ir8cTa(LpeyPRF19K4PD8S5H8NudLXopPpMVrYO4NKHXqGqiJDEsvIH7VpjfU9ENg6asHxaPFC74zsJKrXvoPimMjDhsH21BwrdPXq6cmmGuhejnbXCaNKI9BwEsqGizq0pjNpmC5Cdd8cqlFbsTALuNpmCryfXGBmWFCSt5lqQvRKcTR3SIMY5gMld(czStbWODmysrgPw66x(YNKZUZRUhcS8v3tIN2XZMhYFsqGizq0pjSa793SbYCIlOXyUyUbKkw3KwzpPgkJDEsngIhdBUo(gNV8HaX8Q7jXt74zZd5pPgkJDEsngIhdBUZE2pjdJHaHqg78KQOJhrs)yM06bdXJHnKIG9SjvKnpKoBsA2EEs2qAm5sQe3GyKjfbHSDI2aM0DivmiL0SbYCIlpjiqKmi6NewG9(B2azoXLgdXJHn3zpBsrgPwsAvsXcS3FZgiZjUGgJ5I5gqkYi1ssRs6rKMTNNSG5geJ8Dcz7eTbCHN2XZMx(YNKaGHwuNoF19qGLV6Es80oE28q(tccejdI(jby0ogmPIL0kZ1U(j1qzSZtsyfXGROfyUWliJ8B4x(qGyE19K4PD8S5H8Neeisge9tcVFVtmMIWhNFpFzWxiJDk80oE2qQvRKI3V3jgt5C9DgE(Ix)jpzHN2XZMNudLXopjypJTHanC(YhcQSxDpjEAhpBEi)jbbIKbr)KoIuNpmCbB3Mve8cqlFHNudLXopjSDBwrWla9LpeGeV6Es80oE28q(tccejdI(jfdUNirSyy4akssrgPwIqpPgkJDEsnaQh(MlaWt(YhcqOxDpjEAhpBEi)jnnk)KW2TzfXM7cCUl8nxakp5tQHYyNNe2UnRi2CxGZDHV5cq5jF5dbUIxDpjEAhpBEi)jTcpjmNpPgkJDEsNniAhp)KoB)NFsI5jD2G70O8tcngZfZn4c9Zfg(LpeCCV6Es80oE28q(tccejdI(jDePz75jlMgD6m2PWt74zZtQHYyNN0zJkeGa6M7hY(LpeCOV6Es80oE28q(tccejdI(jLTNNSyA0PZyNcpTJNnpPgkJDEsOXyUo(gNV8LV8jDYaCSZdbIX1IrmUUYCTLpjrnyIrg)KQ46rCgbIFeiov5KsAD2mPbQWcssHxaPIBcI5aoXIlPa2v)bGnKIxuM0(NlANSHui7EKzCHCPEhdtQROYjfj35KbjBivCtqmhWzPDGkq76nROrCjnxsfxOD9Mv0uAhiXL0ATu8QPqUqUuX1J4mce)iqCQYjL06SzsduHfKKcVasfxbadTOoDkUKcyx9ha2qkErzs7FUODYgsHS7rMXfYL6DmmPIPYjfj35KbjBivCX737eJPioqCjnxsfx8(9oXykIdk80oE2iUKwRLIxnfYL6DmmPIPYjfj35KbjBivCX737eJPioqCjnxsfx8(9oXykIdk80oE2iUK2jPUYkA9M0ATu8QPqUqUuX1J4mce)iqCQYjL06SzsduHfKKcVasfx0ogXLua7Q)aWgsXlktA)ZfTt2qkKDpYmUqUuVJHjTYQCsrYDozqYgsfx8(9oXykIdexsZLuXfVFVtmMI4GcpTJNnIlP1AP4vtHCPEhdtQyoUkNuKCNtgKSHuXfVFVtmMI4aXL0CjvCX737eJPioOWt74zJ4sATwkE1uixixQ46rCgbIFeiov5KsAD2mPbQWcssHxaPIlKblUKcyx9ha2qkErzs7FUODYgsHS7rMXfYL6DmmPUIkNuKCNtgKSHuXnbXCaNL2bQaTR3SIgXL0CjvCH21BwrtPDGexsR1sXRMc5c5I4hvybjBi94iTHYyhs9boXfYLNewGHEiqmi0H(KealC45Nu9RpPs2Tzfr6XabJtYL6xFspKgazt6XzbPIX1IrmKlKl1V(KIK29iZ4kNCP(1N0kcsRte3hq6H3WqADlaWtsQiBEinBGmNKcT)jXK2aMu4faXMc5s9RpPveKEmaN8yi1SjM0gWK(fivKnpKMnqMtmPnGjfYVyM0Cj1GymYwqkEjnT7K05FaJjTbmP4m8Esbm0IIYJHnfYfYL6xFsDLIhd9t2qQddVaMuOf1PtsDy5yWfsRhiiwiXKo7ury3au4VN0gkJDWKUJhXc5sdLXo4IaGHwuNorQ7kiSIyWv0cmx4fKr(nSfbSBaJ2XGfBL5AxtU0qzSdUiayOf1PtK6UcWEgBdbA40Ia2nE)ENymfHpo)E(YGVqg7y1kE)ENymLZ13z45lE9N8KKlnug7GlcagArD6ePURa2UnRi4fGAra7(iNpmCbB3Mve8cqlFbYLgkJDWfbadTOoDIu3vObq9W3CbaEslcy3XG7jselggoGIezwIqKlnug7GlcagArD6ePURWhZ3izulMgLDJTBZkIn3f4Cx4BUauEsYLgkJDWfbadTOoDIu3v4Sbr74zlMgLDJgJ5I5gCH(5cdBXk4gZPfNT)ZUfd5sdLXo4IaGHwuNorQ7kC2OcbiGU5(HSTiGDFu2EEYIPrNoJDk80oE2qU0qzSdUiayOf1PtK6UcOXyUo(gNweWUZ2Ztwmn60zStHN2XZgYfYL6tQRu8yOFYgs5tgGiPzGYKM2mPnuUasdmP9zh(2XZfYLgkJDWUXHNhiMCP(1N0JTzSdMCPHYyhSBHnJDSiGD78HHlNByGxaA5ly1QZhgUiSIyWng4po2P8fixAOm2bJu3v4Sbr74zlMgLDB2eF)cwScUXCAXz7)S7AnBwW2TzfDfTaZvOJPKb0bXiB1A2azolzGY3CVMGfRBKOMQ1A2SC2OcbiGU5(HSlzaDqmYwTMnqMZsgO8n3RjyX62vud5sdLXoyK6UcNniAhpBX0OS727VMnX3VGfRGBmNwC2(p7(Sbr745Izt89luTwZMfdFUFqmYxbFl)5sgqheJSvRzdK5SKbkFZ9AcwSUrIAixQpPszdss)4yKjvIBqmYKIGq2orBatANKwziL0SbYCIjDbKIeiL0aMue3pPnGjngsp8gg4fGsU0qzSdgPURWzdI2XZwmnk7gZnig57eY2jAd4l0pxyylwb3yoT4S9F2nwG9(B2azoXf0ymxm3aKjgK68HHlNByGxaA5lqU0qzSdgPURWzdI2XZwmnk7gYCr7PLzuEslwb3yoT4S9F2DThb(ddVazUGfSzaJV2naDhelSR(dbb2u9iO9KNEYYWqG1VaJvRq76nROPiSIyWng4po2Pay0ogSyDldzkOT4j(QmRwD(WWfHvedUXa)XXoLVGvRolgxfoKTZlGr7yWI1TyqOAixAOm2bJu3v4Sbr74zlMgLDJ2I39mXwScUXCAXz7)SBSa793SbYCIlNnQqacOBUFiBYLgkJDWi1DfoBq0oE2IPrz3OT4DptSfRGBmNwC2(p7gHqQyeF1E2GOD8CbYCr7PLzuEYQq76nROPCUH5YGVqg7uamAhdwSUT011unBppzX(pYmig575gMcpTJNnweWUZ2ZtwWCdIr(oHSDI2aUWt74ztvSa793SbYCIlOXyUyUbUpoYLgkJDWi1DfoBq0oE2IPrz3OT4DptSfRGBmNwC2(p721weWUZ2ZtwWCdIr(oHSDI2aUWt74ztvSa793SbYCIlOXyUyUbi74ixAOm2bJu3v4Sbr74zlMgLDJ2I39mXwScUXCAXz7)SBKWIa2D2EEYcMBqmY3jKTt0gWfEAhpBQIfyV)MnqMtCbngZfZnW9Hw9OS98KfSDBwrxiqJTl80oE2qU0qzSdgPURWzdI2XZwmnk7gTfV7zITyfCJ50IZ2)z31IfyV)MnqMtCbngZfZnqSUrOAeFyb27VzdK5exqJXCXCdSiGD78HHlNByGxaA5lqU0qzSdgPURWzdI2XZwmnk7oW3Z8kSyC44zlwb3yoT4S9F2TRTWWW93NUTKCPHYyhmsDxHZgeTJNTyAu2DGVN5vyX4WXZwScUXCAXz7)SBlTiGD3qzCYxZMLZgviab0n3pKTyHqeYZxEy0GXKlnug7GrQ7kC2GOD8SftJYUpt8Tfe8bBSyfCJ50IZ2)z3nugN81Sz5SrfcqaDZ9dzJm3NniAhpxqBX7EMyRwp6Sbr745sGVN5vyX4WXZKl1NuKCxVzfnKESD9KE4geTJNTGuegZgsZLuHD9K6WWlGjTHY4SZyKj9WByGxaAHCPHYyhmsDxHZgeTJNTyAu2TWU(l8cUqgSfRGBmNwC2(p7gAxVzfnLZnmxg8fYyNYxO6zdI2XZfiZfTNwMr5jjxAOm2bJu3vaoaSJFxJfbSBNpmC5Cdd8cqlFbYLgkJDWi1DfCyaMbheJSfbSBNpmC5Cdd8cqlFbYL6tkcJzsR3HSDkUysD5BKr5jjnGjnTzatAdysfdPlGu0fWKMnqMtSfKUasBJbtAd4rCtsXcTOjgzsHxaPOlGjnT7H0JdHWfYLgkJDWi1Df8HSDIVId)gzuEslcy3yb27VzdK5ex8HSDIVId)gzuEsK5wmwTw7rGomx(KNS0gdUWIxGtSvRGomx(KNS0gdUedYooeQgYLgkJDWi1Df6bIXjO9xO27TiGD78HHlNByGxaA5lqU0qzSdgPURau793gkJDU(aNwmnk7gsee5sdLXoyK6UcG)CBOm256dCAX0OSB0ogYfYL6xFsRNJvVjnxs)yMur28qkY3DiDHjnTzsRhmepg2qAGjTHY4KjxAOm2bxC2DC3yiEmS564BCAra7glWE)nBGmN4cAmMlMBGyDxzKl1N0k64rK0pMjTEWq8yydPiypBsfzZdPZMKMTNNKnKgtUKkXnigzsrqiBNOnGjDhsfdsjnBGmN4c5sdLXo4IZUdsDxHgdXJHn3zpBlcy3yb27VzdK5exAmepg2CN9SrMLvXcS3FZgiZjUGgJ5I5gGmlREu2EEYcMBqmY3jKTt0gWfEAhpBixixQF9jfjReMCP(KIWyM0JTIyaPI)b(JJDivuK2KE4nmWlaTqA966nKcVasp8gg4fGsk0IYysxyysH21BwrdPXqAAZKoS4LKAPRjfZq7yWKUPndefyM0pMjDhsHmK(hpJXKM2mPc(grgqAGjvObjPlmPPnt6bicIEifAp5PN0csxaPbmPPndysffEpPZMK6WK2ZM2mG0dVHHuxj4lKXoKM2bMu4q2olKwpzYOcjP5skgXbI00Mj134KuHveding4po2H0fM00MjfoKTtsZL0ZnmKYGVqg7qk8ciD2H0ksicIEWfYLgkJDWfid2TWkIb3yG)4yhlcy3cGGXzbZE4RWkIb3yG)4yNQ168HHlNByGxaA5ly16rq7jp9KLdqee9u9iO9KNEYYWqG1VatvOD9Mv0uo3WCzWxiJDkagTJbJm3w6ARwHdz78cy0ogSyH21Bwrt5CdZLbFHm2Pay0ogCnvRfoKTZlGr7yWiZn0UEZkAkNByUm4lKXofaJ2XGrQLiuvOD9Mv0uo3WCzWxiJDkagTJblw3YqgXhsy1kCiBNxaJ2XGrg0UEZkAkcRigCJb(JJDkMpOZyhRwDwmUkCiBNxaJ2XGfl0UEZkAkNByUm4lKXofaJ2XGrQLiKvRq7jp9KLdqee9y1QZhgU44314)4S8fQHCP(KIWyMuPWZdet6oKIKvI0CjvaSqKkXc2FXrexmPhdSq(gTZyNc5s9jTHYyhCbYGrQ7kGdppqSfzdK58gWUb)HHxGmxWSG9xCe8vaSq(gTZyNc7Q)qqGnvRnBGmNLaFBJXQ1SbYCwmSZhgUa14mg5cGBOSgYL6tkcJzsrEBKzsJbhgM0fM0dF8KcVastBMu4aGts)yM0fq6oKIKvI0gozaPPntkCaWjPFmxiTIJ0MueeY2jPhFZKAVEdPWlG0dF8fYLgkJDWfidgPURWhZ3izulMgLDJJb(7VY(2eDUa81PnY8DHVWmyHIerlcy3oFy4Y5gg4fGw(cwTMbkJmlDD1ApcAp5PNSmHSDEHBUgYL6tkcJzsp(MjvC63at0dM0DifjReP7pXHHjDHj9WByGxaAHuegZKE8ntQ40VbMOhdM0yi9WByGxakPbmPiUFsT7tMuosBgqQ4eypzsf)ZziVGoJDiDbKE8b7nKUWKIC)IXlkUqAf3rsk8ci1SjM0Cj1Hj9lqQddVaM0gkJZoJrM0JVzsfN(nWe9GjnxsrBXlqdmtAAZK68HHlKlnug7GlqgmsDxb4MVY)gyIEWweWUpY5ddxo3WaVa0YxOAThbTR3SIMY5gMBUaapz5ly16rz75jlNByU5ca8KfEAhpBQPATNniAhpxmBIVFHQyb27VzdK5exoBuHaeq3C)q2UT0Q1ZgeTJNlNj(2cc(GnvXcS3FZgiZjUC2OcbiGU5(HSrML1y1QZhgUCUHbEbOLVq1AX737eJPid2t(gZziVGoJDk80oE2y1kE)ENymf4G9M7cFD8lgVO4cpTJNn1qUuFsrymt6HeJrUrzmPIS5H027jTYiTsBDysBat6xWcsxaPiUFsBatAmKE4nmWlaTqQRCWFatA96FKzqmYKE4nmKkk8EsXz49K6WK(fivKnpKM2mPqnojnduMu4ycSnJlKkLRaPFCmYK2jPiesjnBGmNysffPnPsCdIrMueeY2jAd4c5sdLXo4cKbJu3vangJCJYylGqeYZ3SbYCIDBPfbS7yW9ejIITEX1vRT2ZgeTJNlT3FnBIVFHQ1Ee0UEZkAkNByUm4lKXoLVGvRhLTNNSy)hzgeJ89CdtHN2XZMAQXQvNpmC5Cdd8cqlFHAQw7rz75jl2)rMbXiFp3Wu4PD8SXQvd78HHl2)rMbXiFp3WuamAhdgzqnoVzGYwTEKZhgUCUHbEbOLVqnvR9OS98Kfm3GyKVtiBNOnGl80oE2y1kwG9(B2azoXf0ymxm3aXIq1qUuFsrymtkcp2RhrsrWE2KUdPizLSGu71BIrMuhqWWEejnxsf1rsk8civyfXasJb(JJDiDbK2gdPyHw0GlKlnug7GlqgmsDxH)yVEeVZE2weWUpkBppzX(pYmig575gMcpTJNnvpBq0oEUy2eF)cwTAyNpmCX(pYmig575gMYxOQZhgUCUHbEbOLVGvR1cTR3SIMY5gMld(czStbWODmyKzPRTA9OZgeTJNlc76VWl4czW1u9iNpmC5Cdd8cqlFbYL6tkcJzs3HuKSsK68tsfaXcImWmPFCmYKE4nmK6kbFHm2Hu4aGtlinGj9JzdPXGddt6ct6HpEs3HuP6i9JzsB4KbK2KEUHXz9jPWlGuOD9Mv0qkddhqbpqisApgsHxaP2)rMbXit65ggs)czGYKgWKMTNNKnfYLgkJDWfidgPURGZUZDHVPnFBmepg2yra7(iNpmC5Cdd8cqlFHQhbTR3SIMY5gMld(czSt5luflWE)nBGmN4cAmMlMBaYSS6rz75jlyUbXiFNq2orBax4PD8SXQ1AD(WWLZnmWlaT8fQIfyV)MnqMtCbngZfZnqSIP6rz75jlyUbXiFNq2orBax4PD8SPATca(8kdzkwwo3WCDwFwT2Jyx9hccSPWOcic42FxGz6bITA9OS98Kf7)iZGyKVNByk80oE2uJvRSR(dbb2uyubebC7VlWm9aXvtqmhWzHrfqeWT)UaZ0dexG21BwrtbWODmyX62sxHyQAyNpmCX(pYmig575gMYxOMASATwNpmC5Cdd8cqlFHQz75jlyUbXiFNq2orBax4PD8SPgYLgkJDWfidgPURau793gkJDU(aNwmnk7obXCaNyYLgkJDWfidgPURGHXcmOt(kaAezGfbSBBU9PDrakfR7JdHixixQF9jfjBCsAfBhEMuKSXzmYK2qzSdUqQeNK2jP2HSndivaelisejnxsX2lijfkaq)ijnMKbGVqsk0oMiJDWKUdPhsmgsL4guHJ33isUuFsRtmhkPirfbMtsH2XezSt7jfEbKIKvmss6HeJHuK7BCsU0qzSdUajcYnAmMRJVXPf74r8cjcYTLwKnqMZBa7gZ51zNpUKbdeZHErcbOQoFy4IPbhCt79lBNLVqvbolWbpMsdLXjxf8hgEbYCbB3MveSVr5RaiWOf2v)HGaBQEKZhgUCUHbEbOLVqvboliUFWfB3MvubWODmyXchY25fWODmyRwD(WWftdo4M27x2olFHQcCwqC)Gl2UnROcGr7yWIvgYuqBXt8vBLH0ApY5ddxo3WaVa0YxOgXNLUIAQkWzbX9dUy72SIkagTJblw4q2oVagTJbtUuFsrymtQe3GyKjfbHSDI2aM0aMue3pPIcVNu7ijLN9lBtA2azoXK2JH0JTIyaPI)b(JJDiThdPhEdd8cqjTbmPZMKc42GOfKUasZLuaddySnPsvCLFms3H0u0s6cifDbmPzdK5exixAOm2bxGeb5gZnig57eY2jAdyl(y(kYo88fQXzmYUT0cieH88nBGmNy3wAra7U2ZgeTJNlyUbXiFNq2orBaFH(5cdx9OZgeTJNlc76VWl4czW1y1ATMnly72SIUIwG5k0XuammGX2TJNRIfyV)MnqMtCbngZfZnazwwd5s9jvYEbjPizaG(rsQe3GyKjfbHSDI2aMuODmrg7qAUKEaZcKkvXv(Xi9lqAmKwpRRKCPHYyhCbseesDxbm3GyKVtiBNOnGT4J5Ri7WZxOgNXi72slGqeYZ3SbYCIDBPfbS7S98Kfm3GyKVtiBNOnGl80oE2u1SzbB3Mv0v0cmxHoMcGHbm2UD8CvSa793SbYCIlOXyUyUbitmKl1N0D8iEHebrkAFaJjnTzsBOm2H0D8is6h3oEMuZheJmPq29mSpgzs7Xq6SjPnM0Mual)9nG0gkJDkKlnug7GlqIGqQ7kGgJ564BCAXoEeVqIGCBj5c5s9RpPhshdP1ZXQ3wqk2E)EdPq7jdiT9Esb9iZysxysZgiZjM0EmKIH4PbXIjxAOm2bxq7yCd1E)THYyNRpWPftJYUD2DSaNGakDBPfbSBNpmCXz35UW30MVngIhdBkFbYLgkJDWf0ogK6UcMalW(lAlhqweWUpkBGmNLaFf8nImGCP(KIWyM0dVHHuxj4lKXoKUdPq76nROHuHD9XitANK65gNKkgeI0yW9ejIKw7cifjCnPWlGuK731qQR0dt6oKUc8WGAi15NKoBsAatkI7NurH3t6EYaOwG0yW9ejIKgdPh(4lKEi9bmP4pGjvYUnRi4GhtfoKymo8yyaP9yi9qIXqkY9nojnWKUdPq76nROHuhgEbmPh2vsAatQKDBwrW(gLjnWKYU6peeytHuXV8SaMuHD9XitkGXjiGYyhmPbmPFCmYKkz3MveSVrzspgiWOK2JHuKZJHbKgys3FwixAOm2bxq7yqQ7kCUH5YGVqg7yra7(Sbr745IWU(l8cUqgC1AJb3tKiIm3IbHqATwIqIVAbnexC87AUShUAgOSyRmxxtnwTkWzbo4XuAOmo5QG)WWlqMly72SIG9nkFfabgTWU6peeyt1JG21BwrtbngZ1X34S8fQEe0UEZkAky72SIUIwG5A4oTlFHAQwBm4EIerX6(qriRwZ2ZtwWCdIr(oHSDI2aUWt74zt1ZgeTJNlyUbXiFNq2orBaFH(5cdxt1JG21Bwrtbo4Xu(cvR9i8(9oXykNRVZWZx86p5jTA15ddxoxFNHNV41FYtw(cwTI5mJrgxc5zb8fV(tEYAixQpPhsFatk(dysrC)Kk8ts)cKkvXv(XiTEKQNJr6oKM2mPzdK5K0aM0kg0Pn83t6X3miysd8iUjPnugNmPIS5Hu4q2oJrMulRiQmsZgiZjUqU0qzSdUG2XGu3vaB3Mv0v0cmxHoglcy3oFy4cCZx5Fdmrp4YxO6rg25ddxeb60g(7VWndcU8fQIfyV)MnqMtCbngZfZnqSib5sdLXo4cAhdsDxb0ymxm3alGqeYZ3SbYCIDBPfbS7S98Kfm3GyKVtiBNOnGl80oE2uflWE)nBGmN4cAmMlMBaYoBq0oEUGgJ5I5gCH(5cdx9iZMfSDBwrxrlWCf6ykzaDqmYvpcAxVzfnf4Ght5luflWE)nBGmN4cAmMlMBaYCJeKlnug7GlODmi1DfGAV)2qzSZ1h40IPrz3qgm5s9jTEnKTj9yGybrIiPhsmgsL4gqAdLXoKMlPaggWyBsR0whMurrAtkMBqmY3jKTt0gWKlnug7GlODmi1DfqJXCXCdSacripFZgiZj2TLweWUZ2ZtwWCdIr(oHSDI2aUWt74ztvSa793SbYCIlOXyUyUbi7Sbr745cAmMlMBWf6NlmC1JmBwW2TzfDfTaZvOJPKb0bXix9iOD9Mv0uGdEmLVa5s9j9yagMbKMlPFmtALA0PZyhsRhP65yKgWKkvXv(XiDbKE46inWKoBs6xG0fqkI7NuOEMnjfQXjPnPZcqBpPvIp3pigzspMVL)mP1gdK)BIrM0djgdPvIp3pGbKkawiCnK2JHue3pPIcVN0ztsHAbsRudoG06S3VSDIjfNn0bysdys)4yKjToXCOKkgbOc5sdLXo4cAhdsDxbtJoDg7ybeIqE(MnqMtSBlTiGDxRzZYzJkeGa6M7hYUayyaJTBhpB1QzZc2UnROROfyUcDmfaddySD74zRwR9iNpmCbngZ1WN7hWGYxOAm4EIerXIqUUMAQwRZhgUyAWb30E)Y2zbNn0bI15ddxmn4GBAVFz7SG2I3fNn0bwTEeMZRZoFCjdgiMd9kgbOAixQpPimMjvYUnRisR4fyiTsCN2KgWK(XXitQKDBwrW(gLj9yGaJsApgsD4XWasffEpPS4jeaMuZheJmPPnt6WIxsQmKPqU0qzSdUG2XGu3vaB3Mv0v0cmxd3PTfbSBbolWbpMsdLXjxf8hgEbYCbB3MveSVr5RaiWOf2v)HGaBQkWzbo4XuamAhdwSULHmvXcS3FZgiZjUGgJ5I5giw3hh5s9jTE8IAeXK(XmPOXyC8noXKgWKc1ccSH0EmKA)hzgeJmPNByinWK(fiThdPFCmYKkz3MveSVrzspgiWOK2JHuhEmmG0at6xOqkP1JXezSt79iAbPqnojfngJJVXjPbmPiUFsfTFVHuhM0)0oEM0CjvMtstBMuqaNK6GiPI6iJrM0MuzitHCPHYyhCbTJbPURaAmMRJVXPfbS7AH21BwrtbngZ1X34Saz3azgJmlRwRHD(WWf7)iZGyKVNBykFbRwpkBppzX(pYmig575gMcpTJNn1y1QaNf4GhtbWODmyX6gQX5ndugPYqMAQkWzbo4XuAOmo5QG)WWlqMly72SIG9nkFfabgTWU6peeytvbolWbpMcGr7yWidQX5nduUkwG9(B2azoXf0ymxm3aX6(4SA15ddxmn4GBAVFz7S8fQ68HHlNByGxaA5lu9iOD9Mv0uo3WCDwFw(cvR9iWFy4fiZfSDBwrW(gLVcGaJwyx9hccSXQ1Je4Sah8yknugNCnvXCED25JlzWaXCOxKqaICP(KIWyM0dVHHuKV(K0oj1oKTzaPcGybrIiPII0M061)iZGyKj9WByi9lqAUKIeKMnqMtSfKUas30MbKMTNNet6oKkvxHCPHYyhCbTJbPURW5gMRZ6tlcy3XG7jsefR7dfHQMTNNSy)hzgeJ89CdtHN2XZMQz75jlyUbXiFNq2orBax4PD8SPkwG9(B2azoXf0ymxm3aX62vy1AT1MTNNSy)hzgeJ89CdtHN2XZMQhLTNNSG5geJ8Dcz7eTbCHN2XZMASAflWE)nBGmN4cAmMlMBGBlRHCP(KkjWqr7jTs85(bXit6X8T8NjvuK2KkXnigzsrqiBNOnGjvKnpK(XTmtQ5dIrMuKCxVzfnyYLgkJDWf0ogK6Ucg(C)GyKVc(w(ZweWURfZ51zNpUKbdeZHErcbiRwZ2ZtwS)JmdIr(EUHPWt74ztnvZ2ZtwWCdIr(oHSDI2aUWt74ztvbolWbpMsdLXjxf8hgEbYCbB3MveSVr5RaiWOf2v)HGaBQ68HHlNByGxaA5luflWE)nBGmN4cAmMlMBGyD7kixQpPvAhXnj9JzsReFUFqmYKEmFl)zsdysrC)Kc1dPYCsAm5s6H3WaVausJbNCBSG0fqAatQe3GyKjfbHSDI2aM0atA2EEs2qApgsffEpP2rskp7x2M0SbYCIlKlnug7GlODmi1Dfm85(bXiFf8T8NTiGDxlGHbm2UD8SvRXG7jser2XHqwTMTNNSCUH5MlaWtw4PD8SPk0UEZkAkNByU5ca8KfaJ2XGfR7kt8jdzQPAThD2GOD8Cryx)fEbxid2Q1yW9ejIiZ9HIq1uT2JY2ZtwWCdIr(oHSDI2aUWt74zJvR1MTNNSG5geJ8Dcz7eTbCHN2XZMQhD2GOD8CbZnig57eY2jAd4l0pxy4AQHCP(KIWyM0dJCs3HuKSsKgWKI4(j1SJ4MKomBinxsHACsAL4Z9dIrM0J5B5pBbP9yinTzatAdys9mgtAA3dPibPzdK5et6(tsRfHivuK2KcTJ5hznfYLgkJDWf0ogK6UcNByUoRpTiGDJfyV)MnqMtCbngZfZnqS1IeifAhZpYIjW4D6jVmK9Y4cpTJNn1ungCprIOyDFOiu1S98Kfm3GyKVtiBNOnGl80oE2y16rz75jlyUbXiFNq2orBax4PD8SHCP(KIWyMuj72SIiTIxGPYjTsCN2KgWKM2mPzdK5K0atA7S)K0Cj1emPlGue3pP29jtQKDBwrW(gLj9yGaJsk7Q)qqGnKkksBspKymo8yyaPlGuj72SIGdEmK2qzCYfYLgkJDWf0ogK6Ucy72SIUIwG5A4oTTacripFZgiZj2TLweWURnBGmNfBU9PDrakfRyCDvSa793SbYCIlOXyUyUbIfjQXQ1Af4Sah8yknugNCvWFy4fiZfSDBwrW(gLVcGaJwyx9hccSPkwG9(B2azoXf0ymxm3aX6(4QHCP(KIWyMuPpaWJHbKMlPhsBggJjDhsBsZgiZjPPDNKgysL3yKjnxsnbtANKM2mPGq2ojnduUqU0qzSdUG2XGu3va)baEmm4M7fTndJXwaHiKNVzdK5e72slcy3zdK5SKbkFZ9AcwSIX1vD(WWLZnmWlaTywrd5s9jfHXmPhEddP1TaapjP74rK0aMuPkUYpgP9yi9W1rAdysBOmozs7XqAAZKMnqMtsfTJ4MKAcMuZheJmPPntkKDpd7lKlnug7GlODmi1Dfo3WCZfa4jTacripFZgiZj2TLweWUpBq0oEUy2eF)cvR15ddxo3WaVa0IzfnwT68HHlNByGxaAbWODmyXcTR3SIMY5gMRZ6ZcGr7yWwTka4ZRmKPyz5CdZ1z9z1JC(WWfh)Ug)hNfa3qzvSa793SbYCIlOXyUyUbITYQP6zdI2XZLZeFBbbFWMQyb27VzdK5exqJXCXCdeBTiesR1vi(Y2ZtwsrboVl8fUtUWt74ztn1qU0qzSdUG2XGu3vangJdpggyra7U2S98Kfm3GyKVtiBNOnGl80oE2uflWE)nBGmN4cAmMlMBaYoBq0oEUGgJ5I5gCH(5cdB1QzZc2UnROROfyUcDmLmGoig5AQE2GOD8C5mX3wqWhSHCP(KIWyMuPkUYRePII0M0J1X4a4(agq6XWThL0)4zmM00MjnBGmNKkk8EsDysDy)kIuX4AXrrQddVaM00MjfAxVzfnKcTOmMuNg6Gc5sdLXo4cAhdsDxbSDBwrxrlWCnCN2weWUb)HHxGmxe6yCaCFadUc42Jwyx9hccSP6zdI2XZfZM47xOA2azolzGY3CVcq5vmUgz1cTR3SIMc2UnROROfyUgUt7I5d6m2bPYqMAixQpPimMjvYUnRisrsqJTjDhsrYkr6F8mgtAAZaM0gWK2gdM0yGw0yKlKlnug7GlODmi1DfW2TzfDHan22Ia2nOdZLp5jlTXGlXGmlDn5s9jfHXmPhsmgsL4gqAUKcTd(JYKwPgCaP1zVFz7etQayHWKUdP1tf1vwiTUkALQOKIK7ahausdmPPDGjnWK2KAhY2mGubqSGirK00UhsbSzZmgzs3H06PI6kj9pEgJj10GdinT3VSDIjnWK2o7pjnxsZaLjD)j5sdLXo4cAhdsDxb0ymxm3alGqeYZ3SbYCIDBPfbSBSa793SbYCIlOXyUyUbi7Sbr745cAmMlMBWf6NlmCvNpmCX0GdUP9(LTZYxWci7og3wArmjdaFH8gOOSj6KDBPfXKma8fYBa7odOdWiZnsqUu)6tADv0kvrRCsjfjTzOdinTdmPhsmgspEFJiPbQGNr5j7m2H0CjfZmPbmPrsQdG7dWKUPndifS)mgMui7Eg2JjDHj9qIXq6X7BefhnPOnIKomBinxsr7dyst7atQdG7dAzM0D8isQOfCaPII0M00MjfZjPo78XfYL6tkcJzspKymKE8(grsZLuODWFuM0k1GdiTo79lBNysfaleM0DivQos3FIddt6ct6Hp(c5sdLXo4cAhdsDxb0ymxyFJOfbSBNpmCX0GdUP9(LTZYxO6zdI2XZfZM47xO6roFy4Y5gg4fGw(cvp6Sbr745IWU(l8cUqgCvOD9Mv0uqJXCD8nolWFV)cyi7giZ3mqzK5wgYuqBXZci7og3wArmjdaFH8gOOSj6KDBPfXKma8fYBa7odOdWiZnsu9iNpmCX0GdUP9(LTZYxGCP(KIWyM0djgdPi334K0aMue3pPMDe3K0HzdP5skGHbm2M0kT1HlKkLRaPqnoJrM0ojfjiDbKIUaM0SbYCIjvuK2KkXnigzsrqiBNOnGjnBppjBiThdPiUFsBat6SjPFCmYKkz3MveSVrzspgiWOKUaspggri7aI06DmhuWcS3FZgiZjUGgJ5I5gGmXXiePYCIjnTzsrJjq)OKUWKIqK2JH00MjD(OomG0fM0SbYCIlKwpE8AbPML0ztsfamgtkAmghFJts)tgEsBVN0SbYCIjTbmPMnt2qQOiTj9W1rQiBEi9JJrMuSDBwrW(gLjvaeyusdysD4XWasdmP9zh(2XZfYLgkJDWf0ogK6UcOXyUo(gNweWUpBq0oEUy2eF)cvbDyU8jpzbDpzuEYsmidQX5ndugPUUGqvXcS3FZgiZjUGgJ5I5gi2ArcKkgXx2EEYcAGzaIfEAhpBqAdLXjFnBwoBuHaeq3C)q2IVS98KfbmIq2b01hZbfEAhpBqATyb27VzdK5exqJXCXCdqM4yeQgXxTcCwGdEmLgkJtUk4pm8cK5c2UnRiyFJYxbqGrlSR(dbb2utnvR9iWFy4fiZfSDBwrW(gLVcGaJwyx9hccSXQ1JG21Bwrtbo4Xu(cvb)HHxGmxW2Tzfb7Bu(kacmAHD1FiiWgRwpBq0oEUCM4Bli4d2ud5s9jvCMHbm2M0d3OcbiGiTU9dztQOaZEej1PXSH0DiTsn60zSdP9yiDtBgqADTNNexixAOm2bxq7yqQ7kC2OcbiGU5(HSTacripFZgiZj2TLweWUbmmGX2TJNRMnqMZsgO8n3RjyK52YdTATMnlNnQqacOBUFi7sgqheJSvRhD2GOD8C5mX3wqWhSPMQNniAhpxqBX7EMyK5ARwRnBppzbnWmaXcpTJNnvnBwW2TzfDfTaZvOJPayyaJTBhpxJvRoFy4YFG)aFmYxtdoyymU8fixQpPscmu0EsH2XezSdP5skoxbsHACgJmPsvCLFms3H0fgUIiBGmNysfzZdPWHSDgJmPvgPlGu0fWKIZg6a2qk66GjThdPFCmYKEmmIq2beP17yoG0EmKIGkADKEibMbiwixAOm2bxq7yqQ7kGTBZk6kAbMRqhJfbSBaddySD745QzdK5SKbkFZ9Acgzir1JY2ZtwqdmdqSWt74zt1S98KfbmIq2b01hZbfEAhpBQIfyV)MnqMtCbngZfZnazIHCP(KwrIzbsLQ4k)yK(fiDhsBmPO9GiPzdK5etAJjvyX4WXZwqklEqSqsQiBEifoKTZyKjTYiDbKIUaMuC2qhWgsrxhmPII0M0JHreYoGiTEhZbfYLgkJDWf0ogK6Ucy72SIUIwG5k0Xyr2azoVbSBaddySD745QzdK5SKbkFZ9Acgzir1JY2ZtwqdmdqSWt74zt1JQnBppzbZnig57eY2jAd4cpTJNnvXcS3FZgiZjUGgJ5I5gGSZgeTJNlOXyUyUbxOFUWW1uT2JY2ZtweWiczhqxFmhu4PD8SXQ1AZ2ZtweWiczhqxFmhu4PD8SPkwG9(B2azoXf0ymxm3aX6wm1ud5s9jfHXmPhVNX2qGgojD)jommPlmPODmKcTR3SIgmP5skAht2Xq6HxFNHNjvA9N8KK68HHlKlnug7GlODmi1DfG9m2gc0WPfbSB8(9oXykNRVZWZx86p5jREKZhgUCUHbEbOLVq1JC(WWfHvedUXa)XXoLVqvNpmC5C9DgE(Ix)jpzbWODmyXAPRTiMKbGVqEduu2eDYUT0Iysga(c5nGDNb0byK52sYLgkJDWf0ogK6UcOXyUyUbwKnqMZBa7glWE)nBGmN4cAmMlMBaYoBq0oEUGgJ5I5gCH(5cdBbKDhJBlTiMKbGVqEduu2eDYUT0Iysga(c5nGDNb0byK5wmKlnug7GlODmi1DfqJXCH9nIwaz3X42slIjza4lK3afLnrNSBlTiMKbGVqEdy3zaDagzUft1ApY5ddxmn4GBAVFz7S8fSAfAxVzfnLZnmxN1NLVq1AD(WWLZnmWlaT8fSA9iNpmCX0GdUP9(LTZYxOQZhgUycmENEYldzVmU8fQPgYL6tkcJzsLQ4kVsK2ys9nojfW4fKKgWKUdPPntk6EYKlnug7GlODmi1DfW2TzfDfTaZ1WDAtUuFsrymtQufx5hJ0gtQVXjPagVGK0aM0DinTzsr3tM0EmKkvXvELinWKUdPizLixAOm2bxq7yqQ7kGTBZk6kAbMRqhd5c5s9jfHXmPjiMd4K0gozaPcFVNuC2GetApgstBEiDhsrYkrAdNmG00Uts)tgEsrC)KkZjPirAtkoBOdkKwharsZLud7BejvMZmgzsrO0MuC2qhqk8cifAxVzfn4cPimMj1HHxat6M2mG0Di9JzsZL0ztstqilZasf)izLi1HtrmpKMGyoGtmP168LfhxtHCPHYyhCjbXCaNy3FmFJKrTyAu2ngQb47cFHbDYGP9xCccy2Ia2DTh58HHlyOgGVl8fg0jdM2FXjiG5lsu(cvZaLrML1y1AToFy4Y5gg4fGw(cwT68HHlcRigCJb(JJDkFbRwH21Bwrt5CdZLbFHm2Pay0ogmYS011y1k0EYtpzzcz78c3m5s9jfHXmP7qkswjsRhP65yKMlPYCsAL26indOdIrM0EmKYINqaysZLuFmmPFbsD4mzaPII0M0dVHbEbOKlnug7GljiMd4eJu3v4J5BKmQftJYUzubebC7VlWm9aXweWUH21Bwrt5CdZLbFHm2Pay0ogSyDBPySAfAxVzfnLZnmxg8fYyNcGr7yWitmhh5s9jToaIKMlPsioqKk(RixjsffPnPvA)oEMuPSHoGnKIKvctAatQWIXHJNlKwrhs97iZasHdz7etQOiTjfDbmPI)kYvI0pMXK2zYOcjP5skgXbIurrAtApiskKH0fqQ4Wpoj9JzsJSqU0qzSdUKGyoGtmsDxHpMVrYOwmnk7ogme4NTJNVU6VN8JEn8zaXweWUD(WWLZnmWlaT8fQ68HHlcRigCJb(JJDkFbRwDwmUkCiBNxaJ2XGfRBX4ARwD(WWfHvedUXa)XXoLVqvOD9Mv0uo3WCzWxiJDkagTJbJulriKbhY25fWODmyRwD(WWLZnmWlaT8fQcTR3SIMIWkIb3yG)4yNcGr7yWi1seczWHSDEbmAhd2Q1AH21BwrtryfXGBmWFCStbWODmyK52sxxfAxVzfnLZnmxg8fYyNcGr7yWiZTLUUMQWHSDEbmAhdgzUTSEX1Kl1NujehisLSzoj9q(4aIurrAt6H3WaVauYLgkJDWLeeZbCIrQ7k8X8nsg1IPrz3Onu7a4l2M58I(XbKfbSBOD9Mv0uo3WCzWxiJDkagTJbJmlDn5s9jvcXbIuX5VdIKkksBsp2kIbKk(h4po2H0pULzlifTpGjf)bmP5skEcbM00Mj1VIyCsA96XinBGmNfsRyBEi9JzdPII0Muj72SIydPvuGdPlmP1TauEslivC4hNK(XmP7qkswjsBmPOFiBsBmPclghoEUqU0qzSdUKGyoGtmsDxHpMVrYOwmnk7gVFVNZmg5l47GOfqic55B2azoXUT0Ia2TZhgUiSIyWng4po2P8fSA9ibqW4SGzp8vyfXGBmWFCSJvRSR(dbb2uW2TzfXM7cCUl8nxakpj5s9j94daojvkKdpPy027jDfYanehPZyhsffPnPs7375mJrMuX5VdIKlnug7GljiMd4eJu3v4J5BKmQftJYUtB(chaCEXHC4TiGD78HHlNByGxaA5ly1QZhgUiSIyWng4po2P8fSA9ibqW4SGzp8vyfXGBmWFCSJvRq76nROPCUH5YGVqg7uamAhdgzw6ARwRLD1FiiWMcE)EpNzmYxW3bXQhLGyoGZcE)EpNzmYxW3bXc0UEZkAkFHASA1zX4QWHSDEbmAhdwSIX1Kl1NuegZKI82iZKgdommPlmPh(4jfEbKM2mPWbaNK(XmPlG0DifjRePnCYastBMu4aGts)yUqQK9cssHca0pssdysp3Wqkd(czSdPq76nROH0atQLUgt6cifDbmPTOgXc5sdLXo4scI5aoXi1Df(y(gjJAX0OSBCmWF)v23MOZfGVoTrMVl8fMbluKiAra7gAxVzfnLZnmxg8fYyNcGr7yWiZTLUMCP(KIWyMuj72SIydPvuGdPlmP1TauEssfzZdPZMKgdPhEdd8cqTG0fqAmK6WPiMhsp8ggsr(6tsHACIjngsp8gg4fGwiTEWKwrcrq0dPlGueWqG1VadP(yysJK0VaPII0MuC2qhWgsH21BwrdUqU0qzSdUKGyoGtmsDxHpMVrYOwmnk7gB3MveBUlW5UW3CbO8KweWUH21BwrtryfXGBmWFCStbWODmyX62sxxfAxVzfnLZnmxg8fYyNcGr7yWI1TLUUATq7jp9KLHHaRFbgRwH2tE6jlhGii6PgRwRfAp5PNSCYtAJiWQvO9KNEYYeY25fU5AQw7roFy4Y5gg4fGw(cwTka4ZRmKPyz5CdZ1z9znwT6SyCv4q2oVagTJblw3iHRjxQpPimMjnTdmP7qkswjsHxaPOT4rkswjXzYLgkJDWLeeZbCIrQ7k8X8nsg1IPrz3naYosgkX3yK55hjIxOfWKl1N0kXW93NKc3EVtdDaPWlG0pUD8mPrYO4kNuegZKUdPq76nROH0yiDbggqQdIKMGyoGtsX(nlKlnug7GljiMd4eJu3v4J5BKmk2Ia2TZhgUCUHbEbOLVGvRoFy4IWkIb3yG)4yNYxWQvOD9Mv0uo3WCzWxiJDkagTJbJmlD9lF57ba]] )
    

end
