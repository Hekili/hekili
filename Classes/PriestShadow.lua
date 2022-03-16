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


    spec:RegisterPack( "Shadow", 20220316, [[dmvsZcqivipssvDjcviztssFIqvnkjLoLKIvrOs9kisZIs4wubODjXVKemmQGogLOLbr1ZKeLPbr4AqG2gHk6Bqq14Ga6CeQeRtsu9ocvi18iu6Eur7dIY)iuH6GsQIfsO4HqenrjrUivaTriO8rQayKsQs6KscXkPc9sjvjmtjvPUjeGDQc1pLesdvfuhLqfILsOs6PezQsQCviiBvfKVkjuJLqfyVQYFvPbt6WsTyQ0JvvtMIlJAZG6Ze1OPuNwy1eQGETkWSPQBdPDR43knCcoovGwoWZHA6IUoiBxf9Dcz8eQY5HqRxsvIMpL0(r(z5RUNKPt(DmYDiYrUdRmlfNfhkU4qKOYqGpPerb(jj0)dAz(jnnk)KKSBZk6jj0i6328Q7jHxiWNFs2zkGR8kub5iTHCl)fTc4afY3zSZh0WzfWb6VcpjxOWNvK55(KmDYVJrUdroYDyLzP4S4qXfhIevgs8KAO0EbpjPafjFs2HXWZZ9jzy8)jjz3MvePhgemojhran4BtQLItlif5oe5iNCKCejT7rMXvo5OdiP1jI7di9qByiTUfa4jjvKnpKMnqMts)l0KysBatk8c(SPqo6as6HbCYJHuZMysBatkKaPIS5H0SbYCIjTbmPF)IzsZLudIXiBbP4L00UtshOdymPnGjfNH3tkG)lkkpg2uEs(aN4xDpj0oMxDVJT8v3tIN21ZMNyEsFqKmi6NKlemCXD35UW30MVn(ZJHnfiHNeobXpFhB5tQ)zSZt63E)T)zSZ1h48j5dCENgLFsU7oV8DmYF19K4PD9S5jMN0hejdI(jDePzdK5Se4RGVrKbpP(NXopjtGfy)fTLJ)lFhxzV6Es80UE28eZtQ)zSZt6CdZLbqczSZtYW4pieYyNNecHzsp0ggsDGaiHm2H0Di9VR3SIgsf21hJmPDsQNBCskYrqsJb3tKisATlGuKWHKcVasfJFxdPoqpmP7q6kWddQHuxOK0ztsdysrCHivu49KUNm43cKgdUNirK0yi9qiScPiG(aMumeGjvYUnRi4GhtfqaXyC5XWas7XqkcigdPIX34K0at6oK(31BwrdPUm8cyspKdK0aMuj72SIG9nktAGjLDqOqqGnfsRiYZcysf21hJmPagNG4NXoysdysHWXitQKDBwrW(gLj9WGaJsApgsfdpggqAGjDHYYt6dIKbr)KoBq0UEUiSR)cVG73GjTkP1sAm4EIersrMtsrocsksjTwsTebjvCtATKc6pxC97AUShM0QKMbktQyjTYCiP1qAnKA1kPcCwGdEmL(NXjtAvsbqddVazUGTBZkc23O8vaey0c7GqHGaBiTkPhr6FxVzfnf0ymxxFJZcKaPvj9is)76nROPGTBZk6kAbMRH70UajqAnKwL0AjngCprIiPI1jPiqeKuRwjnBppzbZnig57eY2jAd4cpTRNnKwL0ZgeTRNlyUbXiFNq2orBaF)q5cdtAnKwL0Ji9VR3SIMcCWJPajqAvsRL0JifVqE3ymLZ13z45lE9N8KfEAxpBi1QvsDHGHlNRVZWZx86p5jlqcKA1kPyoZyKXLqEwaFXR)KNK0AE57yK4v3tIN21ZMNyEs9pJDEsy72SIUIwG5k0X8Kmm(dcHm25jHa6dysXqaMuexisfGssHeivQIR8dtA9ivphM0DinTzsZgiZjPbmPvmOtByipPiSMbbtAGhXpjT)zCYKkYMhsHdz7mgzsT0bSYinBGmN4Yt6dIKbr)KCHGHlWnFLHAGj6bxGeiTkPhrQHDHGHlIaDAdd5VWndcUajqAvsXcS3FZgiZjUGgJ5I5gqQyjfjE57ye8v3tIN21ZMNyEs9pJDEsOXyUyUbpPpisge9tkBppzbZnig57eY2jAd4cpTRNnKwLuSa793SbYCIlOXyUyUbKImspBq0UEUGgJ5I5gC)q5cdtAvspIuZMfSDBwrxrlWCf6ykz8pigzsRs6rK(31Bwrtbo4XuGeiTkPyb27VzdK5exqJXCXCdifzojfjEsFe)E(MnqMt87ylF57yX5RUNepTRNnpX8K6Fg78K(T3F7Fg7C9boFs(aN3Pr5N03GF57ye(RUNepTRNnpX8K6Fg78KqJXCXCdEsFe)E(MnqMt87ylFsFqKmi6Nu2EEYcMBqmY3jKTt0gWfEAxpBiTkPyb27VzdK5exqJXCXCdifzKE2GOD9CbngZfZn4(HYfgM0QKEePMnly72SIUIwG5k0XuY4FqmYKwL0Ji9VR3SIMcCWJPaj8Kmm(dcHm25jvVgY2KEyqSGirKueqmgsL4gqA)ZyhsZLuaddySnPvARdtQOiTjfZnig57eY2jAd4x(ogb(Q7jXt76zZtmpP(NXopjtJoDg78K(i(98nBGmN43Xw(K(Gizq0pPAj1Sz5Srfcq8V5c9TlaggWy721ZKA1kPMnly72SIUIwG5k0XuammGX2TRNj1QvsRL0Ji1fcgUGgJ5A4ZfcWGcKaPvjngCprIiPILue0HKwdP1qAvsRLuxiy4IPbhCt7fs2ol4S)hqQyj1fcgUyAWb30EHKTZcAlExC2)di1QvspIumNx3DGWLmyaYrGxKl8jTMNKHXFqiKXopPddyygqAUKcHzsRuJoDg7qA9ivphM0aMuPkUYpmPlG0dvhPbM0ztsHeiDbKI4cr6VNzts)nojTjDwaA7jTs85cbIrM0d7BziM0AJ57HmXitkcigdPvIpxiadivaSFCnK2JHuexisffEpPZMK(BbsRudoG06Sxiz7etko7)bysdysHWXitADihbskYf(Lx(owC5v3tIN21ZMNyEs9pJDEsy72SIUIwG5A4oTFsgg)bHqg78KqimtQKDBwrKwXlWqAL4oTjnGjfchJmPs2Tzfb7BuM0ddcmkP9yi1Lhddivu49KYINqaysnqGyKjnTzshw8ssL)MYt6dIKbr)Ke4Sah8yk9pJtM0QKcGggEbYCbB3MveSVr5RaiWOf2bHcbb2qAvsf4Sah8ykagTJbtQyDsQ83qAvsXcS3FZgiZjUGgJ5I5gqQyDskc)LVJT0HV6Es80UE28eZtQ)zSZtcngZ11348jzy8heczSZtQE8IAeXKcHzsrJX46BCIjnGj93ccSH0EmKAdnYmigzsp3WqAGjfsG0EmKcHJrMuj72SIG9nkt6HbbgL0EmK6YJHbKgysHekKsA9ymrg70EpIwq6VXjPOXyC9nojnGjfXfIurlK3qQltk00UEM0CjvMtstBMuqaNK6IiPI6iJrM0Mu5VP8K(Gizq0pPAj9VR3SIMcAmMRRVXz5B3azgtkYi1ssRsATKAyxiy4In0iZGyKVNBykqcKA1kPhrA2EEYIn0iZGyKVNByk80UE2qAnKA1kPcCwGdEmfaJ2XGjvSoj9348Mbktksjv(BiTgsRsQaNf4GhtP)zCYKwLua0WWlqMly72SIG9nkFfabgTWoiuiiWgsRsQaNf4GhtbWODmysrgP)gN3mqzsRskwG9(B2azoXf0ymxm3asfRtsr4KA1kPUqWWftdo4M2lKSDwGeiTkPUqWWLZnmWlaTajqAvspI0)UEZkAkNByUURplqcKwL0Aj9isbqddVazUGTBZkc23O8vaey0c7GqHGaBi1QvspIubolWbpMs)Z4KjTgsRskMZR7oq4sgma5iWlsi8F57ylT8v3tIN21ZMNyEs9pJDEsNByUURpFsgg)bHqg78Kqimt6H2WqQywFsANKAhY2mGubqSGirKurrAtA9k0iZGyKj9qByifsG0CjfjinBGmNyliDbKUPndinBppjM0DivQUYt6dIKbr)KIb3tKisQyDskcebjTkPz75jl2qJmdIr(EUHPWt76zdPvjnBppzbZnig57eY2jAd4cpTRNnKwLuSa793SbYCIlOXyUyUbKkwNKkoj1QvsRL0AjnBppzXgAKzqmY3ZnmfEAxpBiTkPhrA2EEYcMBqmY3jKTt0gWfEAxpBiTgsTALuSa793SbYCIlOXyUyUbK6KuljTMx(o2sK)Q7jXt76zZtmpP(NXopjdFUqGyKVc(wgIFsgg)bHqg78KKe4F0EsReFUqGyKj9W(wgIjvuK2KkXnigzspoKTt0gWKkYMhsHWTmtQbceJmPi5UEZkAWpPpisge9tQwsXCED3bcxYGbihbErcHpPwTsA2EEYIn0iZGyKVNByk80UE2qAnKwL0S98Kfm3GyKVtiBNOnGl80UE2qAvsf4Sah8yk9pJtM0QKcGggEbYCbB3MveSVr5RaiWOf2bHcbb2qAvsDHGHlNByGxaAbsG0QKIfyV)MnqMtCbngZfZnGuX6KuX5lFhBzL9Q7jXt76zZtmpP(NXopjdFUqGyKVc(wgIFsgg)bHqg78KQ0oIFskeMjTs85cbIrM0d7BziM0aMuexis)9qQmNKgtUKEOnmWlaL0yWj3gliDbKgWKkXnigzspoKTt0gWKgysZ2ZtYgs7XqQOW7j1oss5zHKTjnBGmN4Yt6dIKbr)KQLuaddySD76zsTAL0yW9ejIKImsr4iiPwTsA2EEYY5gMBUaapzHN21ZgsRs6FxVzfnLZnm3CbaEYcGr7yWKkwNKwzKkUjv(BiTgsRsATKEePNniAxpxe21FHxW9BWKA1kPXG7jsejfzojfbIGKwdPvjTwspI0S98Kfm3GyKVtiBNOnGl80UE2qQvRKwlPz75jlyUbXiFNq2orBax4PD9SH0QKEePNniAxpxWCdIr(oHSDI2a((HYfgM0AiTMx(o2sK4v3tIN21ZMNyEs9pJDEsNByUURpFsgg)bHqg78Kqimt6HedP7qkswjsdysrCHi1SJ4NKomBinxs)nojTs85cbIrM0d7Bzi2cs7XqAAZaM0gWK6zmM00UhsrcsZgiZjM0fkjTweKurrAt6FhduK1uEsFqKmi6NewG9(B2azoXf0ymxm3asflP1sksqksj9VJbkYIjW4D6jV83EzCHN21ZgsRH0QKgdUNirKuX6KueicsAvsZ2ZtwWCdIr(oHSDI2aUWt76zdPwTs6rKMTNNSG5geJ8Dcz7eTbCHN21ZMx(o2se8v3tIN21ZMNyEs9pJDEsy72SIUIwG5A4oTFsFe)E(MnqMt87ylFsFqKmi6NuTKMnqMZIn3(0Ui8tsflPi3HKwLuSa793SbYCIlOXyUyUbKkwsrcsRHuRwjTwsf4Sah8yk9pJtM0QKcGggEbYCbB3MveSVr5RaiWOf2bHcbb2qAvsXcS3FZgiZjUGgJ5I5gqQyDskcN0AEsgg)bHqg78KqimtQKDBwrKwXlWu5KwjUtBsdystBM0SbYCsAGjTDxOK0Cj1emPlGuexisT7tMuj72SIG9nkt6HbbgLu2bHcbb2qQOiTjfbeJXLhddiDbKkz3MveCWJH0(NXjxE57ylfNV6Es80UE28eZtQ)zSZtcdba8yyWn3lABggJFsFe)E(MnqMt87ylFsFqKmi6Nu2azolzGY3CVMGjvSKIChsAvsDHGHlNByGxaAXSIMNKHXFqiKXopjecZKkbba8yyaP5skcOndJXKUdPnPzdK5K00UtsdmPYBmYKMlPMGjTtstBMuqiBNKMbkxE57ylr4V6Es80UE28eZtQ)zSZt6CdZnxaGN8j9r875B2azoXVJT8j9brYGOFsNniAxpxmBIVqcKwL0Aj1fcgUCUHbEbOfZkAi1QvsDHGHlNByGxaAbWODmysflP)D9Mv0uo3WCDxFwamAhdMuRwjvaWNx5VPyz5CdZ1D9jPvj9isDHGHlU(DnEiCwaC)tsRskwG9(B2azoXf0ymxm3asflPvgP1qAvspBq0UEUCM4Bli4d2qAvsXcS3FZgiZjUGgJ5I5gqQyjTwsrqsrkP1sQ4KuXnPz75jlPOaN3f(c3jx4PD9SH0AiTMNKHXFqiKXopjecZKEOnmKw3ca8KKUJhrsdysLQ4k)WK2JH0dvhPnGjT)zCYK2JH00MjnBGmNKkAhXpj1emPgiqmYKM2mPF7Eg2xE57ylrGV6Es80UE28eZt6dIKbr)KQL0S98Kfm3GyKVtiBNOnGl80UE2qAvsXcS3FZgiZjUGgJ5I5gqkYi9Sbr765cAmMlMBW9dLlmmPwTsQzZc2UnROROfyUcDmLm(heJmP1qAvspBq0UEUCM4Bli4d28K6Fg78KqJX4YJHbV8DSLIlV6Es80UE28eZtQ)zSZtcB3Mv0v0cmxd3P9tYW4pieYyNNecHzsLQ4kVsKkksBspChJlG7dyaPhg3EusHgpJXKM2mPzdK5KurH3tQltQl7xrKIChkoksDz4fWKM2mP)D9Mv0q6FrzmPU9)GYt6dIKbr)KaqddVazUi0X4c4(agCfWThTWoiuiiWgsRs6zdI21ZfZM4lKaPvjnBGmNLmq5BUxHFErUdjfzKwlP)D9Mv0uW2TzfDfTaZ1WDAxmqGoJDifPKk)nKwZlFhJCh(Q7jXt76zZtmpP(NXopjSDBwr3pOX2pjdJ)GqiJDEsieMjvYUnRisrsqJTjDhsrYkrk04zmM00MbmPnGjTngmPX8x0yKlpPpisge9tc0H5YN8KL2yWLyifzKAPdF57yKB5RUNepTRNnpX8K(Gizq0pjSa793SbYCIlOXyUyUbKImspBq0UEUGgJ5I5gC)q5cdtAvsDHGHlMgCWnTxiz7Saj8Kmm(dcHm25jHqyMueqmgsL4gqAUK(3bdHYKwPgCaP1zVqY2jMubW(XKUdP1tf1bwiTUkALQOKIK7ahausdmPPDGjnWK2KAhY2mGubqSGirK00UhsbSzZmgzs3H06PI6ajfA8mgtQPbhqAAVqY2jM0atA7UqjP5sAgOmPlu(K(i(98nBGmN43Xw(KIjzaasiVb8tkJ)byK5ejEsXKmaajK3afLnrN8tYYN03UJ5jz5tQ)zSZtcngZfZn4LVJroYF19K4PD9S5jMNKHXFqiKXopjecZKIaIXqkcZ3isAUK(3bdHYKwPgCaP1zVqY2jMubW(XKUdPs1r6cL4WWKUWKEiew5j9brYGOFsUqWWftdo4M2lKSDwGeiTkPNniAxpxmBIVqcKwL0Ji1fcgUCUHbEbOfibsRs6rKE2GOD9Cryx)fEb3VbtAvs)76nROPGgJ566BCwGH8(lG)2nqMVzGYKImNKk)nf0w8EsXKmaajK3a(jLX)amYCIevpYfcgUyAWb30EHKTZcKWtkMKbaiH8gOOSj6KFsw(K(2DmpjlFs9pJDEsOXyUW(gXx(og5v2RUNepTRNnpX8K6Fg78KqJXCD9noFsgg)bHqg78KqimtkcigdPIX34K0aMuexisn7i(jPdZgsZLuaddySnPvARdxivkxbs)noJrM0ojfjiDbKIUaM0SbYCIjvuK2KkXnigzspoKTt0gWKMTNNKnK2JHuexisBat6SjPq4yKjvYUnRiyFJYKEyqGrjDbKEymIF74tA9oMdkyb27VzdK5exqJXCXCdqM4yeKuzoXKM2mPOXeOqOKUWKIGK2JH00MjDGqDzaPlmPzdK5exiTE841csnlPZMKkaymMu0ymU(gNKcnz4jT9EsZgiZjM0gWKA2mzdPII0M0dvhPIS5HuiCmYKITBZkc23OmPcGaJsAatQlpggqAGjTp7W3UEU8K(Gizq0pPZgeTRNlMnXxibsRskOdZLp5jlO7jJYtwIHuKr6VX5nduMuKsQdliiPvjflWE)nBGmN4cAmMlMBaPIL0AjfjifPKICsf3KMTNNSGgygGyHN21ZgsrkP9pJt(A2SC2Ocbi(3CH(2KkUjnBppzraJ43o(xFmhu4PD9SHuKsATKIfyV)MnqMtCbngZfZnGuKjoMueK0AivCtATKkWzbo4Xu6FgNmPvjfanm8cK5c2UnRiyFJYxbqGrlSdcfccSH0AiTgsRsATKEePaOHHxGmxW2Tzfb7Bu(kacmAHDqOqqGnKA1kPhr6FxVzfnf4GhtbsG0QKcGggEbYCbB3MveSVr5RaiWOf2bHcbb2qQvRKE2GOD9C5mX3wqWhSH0AE57yKJeV6Es80UE28eZtQ)zSZt6Srfcq8V5c9TFsFe)E(MnqMt87ylFsFqKmi6NeGHbm2UD9mPvjnBGmNLmq5BUxtWKImNKAjcK0QKwlPMnlNnQqaI)nxOVDjJ)bXitQvRKEePNniAxpxot8Tfe8bBiTgsRs6zdI21Zf0w8UNjMuKrQdj1QvsRL0S98Kf0aZael80UE2qAvsnBwW2TzfDfTaZvOJPayyaJTBxptAnKA1kPUqWWfObgc4Jr(AAWbdJXfiHNKHXFqiKXopjXvggWyBspuJkeG4tADl03MurbM9isQBJzdP7qALA0PZyhs7Xq6M2mG06AppjU8Y3XihbF19K4PD9S5jMNu)ZyNNe2UnROROfyUcDmpjdJ)GqiJDEssc8pApP)Dmrg7qAUKIZvG0FJZyKjvQIR8dt6oKUWWoGzdK5etQiBEifoKTZyKjTYiDbKIUaMuC2)dydPORlM0EmKcHJrM0dJr8BhFsR3XCaP9yi94kADKIacmdqS8K(Gizq0pjaddySD76zsRsA2azolzGY3CVMGjfzKIeKwL0JinBppzbnWmaXcpTRNnKwL0S98KfbmIF74F9XCqHN21ZgsRskwG9(B2azoXf0ymxm3asrgPi)LVJrU48v3tIN21ZMNyEs9pJDEsy72SIUIwG5k0X8K(i(98nBGmN43Xw(K(Gizq0pjaddySD76zsRsA2azolzGY3CVMGjfzKIeKwL0JinBppzbnWmaXcpTRNnKwL0JiTwsZ2ZtwWCdIr(oHSDI2aUWt76zdPvjflWE)nBGmN4cAmMlMBaPiJ0ZgeTRNlOXyUyUb3puUWWKwdPvjTwspI0S98KfbmIF74F9XCqHN21ZgsTAL0AjnBppzraJ43o(xFmhu4PD9SH0QKIfyV)MnqMtCbngZfZnGuX6KuKtAnKwZtYW4pieYyNNu9cMfivQIR8dtkKaP7qAJjfThejnBGmNysBmPclghUE2cszX7ZcjPIS5Hu4q2oJrM0kJ0fqk6cysXz)pGnKIUUysffPnPhgJ43o(KwVJ5GYlFhJCe(RUNepTRNnpX8K6Fg78KG9m2(dA48jftYaaKqEd4Nug)dWiZPLpPysgaGeYBGIYMOt(jz5t6dIKbr)KWlK3ngt5C9DgE(Ix)jpzHN21ZgsRs6rK6cbdxo3WaVa0cKaPvj9isDHGHlcRigCJbgch7uGeiTkPUqWWLZ13z45lE9N8KfaJ2XGjvSKAPdFsgg)bHqg78KqimtkcZZy7pOHtsxOehgM0fMu0ogs)76nRObtAUKI2XKDmKEO13z4zsLw)jpjPUqWWLx(og5iWxDpjEAxpBEI5j1)m25jHgJ5I5g8K(i(98nBGmN43Xw(KIjzaasiVb8tkJ)byK5e5pPysgaGeYBGIYMOt(jz5t6dIKbr)KWcS3FZgiZjUGgJ5I5gqkYi9Sbr765cAmMlMBW9dLlm8t6B3X8KS8LVJrU4YRUNepTRNnpX8K6Fg78KqJXCH9nIpPysgaGeYBa)KY4FagzorE1ApYfcgUyAWb30EHKTZcKGvR)D9Mv0uo3WCDxFwGeQwRlemC5Cdd8cqlqcwTEKlemCX0GdUP9cjBNfiHQUqWWftGX70tE5V9Y4cKqn18KIjzaasiVbkkBIo5NKLpPVDhZtYYx(oUYC4RUNepTRNnpX8Kmm(dcHm25jHqyMuPkUYRePnMuFJtsbmEbjPbmP7qAAZKIUN8tQ)zSZtcB3Mv0v0cmxd3P9lFhxzw(Q7jXt76zZtmpjdJ)GqiJDEsieMjvQIR8dtAJj134KuaJxqsAat6oKM2mPO7jtApgsLQ4kVsKgys3HuKSspP(NXopjSDBwrxrlWCf6yE5lFsggUH85RU3Xw(Q7jXt76zZtmpjdJ)GqiJDEsoqXJ)qjBiLpzaIKMbktAAZK2)CbKgys7Zo8TRNlpP(NXopjC455ZV8DmYF19K4PD9S5jMN0hejdI(j5cbdxo3WaVa0cKaPwTsQlemCryfXGBmWq4yNcKWtQ)zSZtsyZyNx(oUYE19K4PD9S5jMN0k8KWC(K6Fg78KoBq0UE(jD2Ei(jvlPMnly72SIUIwG5k0XuY4FqmYKA1kPzdK5SKbkFZ9AcMuX6KuKG0AiTkP1sQzZYzJkeG4FZf6BxY4FqmYKA1kPzdK5SKbkFZ9AcMuX6KuXjP18KoBWDAu(jz2eFHeE57yK4v3tIN21ZMNyEsRWtcZ5tQ)zSZt6Sbr765N0z7H4N0zdI21ZfZM4lKaPvjTwsnBwm85cbIr(k4BziUKX)GyKj1QvsZgiZzjdu(M71emPI1jPibP18KoBWDAu(j1E)1Sj(cj8Y3Xi4RUNepTRNnpX8KwHNeMZNu)ZyNN0zdI21ZpPZ2dXpjSa793SbYCIlOXyUyUbKImsroPiLuxiy4Y5gg4fGwGeEsgg)bHqg78KKYgKKcHJrMujUbXit6XHSDI2aM0ojTYqkPzdK5et6cifjqkPbmPiUqK2aM0yi9qByGxa6t6Sb3Pr5NeMBqmY3jKTt0gW3puUWWV8DS48v3tIN21ZMNyEsRWtcZ5tQ)zSZt6Sbr765N0z7H4NuTKEePaOHHxGmxWc2mGXx7gGUdIf2bHcbb2qAvspI0)EYtpzz4py9lWqQvRK(31BwrtryfXGBmWq4yNcGr7yWKkwNKk)nf0w8ivCtALrQvRK6cbdxewrm4gdmeo2PajqQvRK6UymPvjfoKTZlGr7yWKkwNKICeK0AEsNn4onk)K(MlApTmJYt(Y3Xi8xDpjEAxpBEI5jTcpjmNpP(NXopPZgeTRNFsNThIFsyb27VzdK5exoBuHae)BUqF7N0zdUtJYpj0w8UNj(LVJrGV6Es80UE28eZtAfEsyoFs9pJDEsNniAxp)KoBpe)KqqsrkPiNuXnP1s6zdI21ZLV5I2tlZO8KKwL0)UEZkAkNByUmasiJDkagTJbtQyDsQLoK0AiTkPz75jl2qJmdIr(EUHPWt76zZt6dIKbr)KY2ZtwWCdIr(oHSDI2aUWt76zdPvjflWE)nBGmN4cAmMlMBaPojfH)KoBWDAu(jH2I39mXV8DS4YRUNepTRNnpX8KwHNeMZNu)ZyNN0zdI21ZpPZ2dXpjh(K(Gizq0pPS98Kfm3GyKVtiBNOnGl80UE2qAvsXcS3FZgiZjUGgJ5I5gqkYifH)KoBWDAu(jH2I39mXV8DSLo8v3tIN21ZMNyEsRWtcZ5tQ)zSZt6Sbr765N0z7H4Nes8K(Gizq0pPS98Kfm3GyKVtiBNOnGl80UE2qAvsXcS3FZgiZjUGgJ5I5gqQtsrGKwL0JinBppzbB3Mv09dASDHN21ZMN0zdUtJYpj0w8UNj(LVJT0YxDpjEAxpBEI5jTcpjmNpP(NXopPZgeTRNFsNThIFs1skwG9(B2azoXf0ymxm3asfRtsrqsRHuXnPyb27VzdK5exqJXCXCdEsFqKmi6NKlemC5Cdd8cqlqcpPZgCNgLFsOT4Dpt8lFhBjYF19K4PD9S5jMN0k8KWC(K6Fg78KoBq0UE(jD2Ei(j5WNKHHBiF(KS8jD2G70O8tkW3Z8kSyC465x(o2Yk7v3tIN21ZMNyEsRWtcZ5tQ)zSZt6Sbr765N0z7H4NKLpPpisge9tQ)zCYxZMLZgviaX)Ml03MuXs6hXVNV8WObJFsNn4onk)Kc89mVclghUE(LVJTejE19K4PD9S5jMN0k8KWC(K6Fg78KoBq0UE(jD2Ei(j1)mo5RzZYzJkeG4FZf6BtkYCs6zdI21Zf0w8UNjMuRwj9ispBq0UEUe47zEfwmoC98t6Sb3Pr5N0zIVTGGpyZlFhBjc(Q7jXt76zZtmpPv4jH58j1)m25jD2GOD98t6S9q8t6VR3SIMY5gMldGeYyNcKaPvj9Sbr765Y3Cr7PLzuEYNKHXFqiKXopjKCxVzfnKE4D9KEOgeTRNTGuecZgsZLuHD9K6YWlGjT)zC2zmYKEOnmWlaT8KoBWDAu(jjSR)cVG73GF57ylfNV6Es80UE28eZt6dIKbr)KCHGHlNByGxaAbs4j1)m25jbha21VR5LVJTeH)Q7jXt76zZtmpPpisge9tYfcgUCUHbEbOfiHNu)ZyNNKldWm4GyKF57ylrGV6Es80UE28eZtQ)zSZtYhY2j(koeYiJYt(Kmm(dcHm25jHqyM06DiBNIpMuhHmYO8KKgWKM2mGjTbmPiN0fqk6cysZgiZj2csxaPTXGjTb8i(jPyHw0eJmPWlGu0fWKM29qkchbXLN0hejdI(jHfyV)MnqMtCXhY2j(koeYiJYtskYCskYj1QvsRL0Jif0H5YN8KL2yWfw8cCIj1QvsbDyU8jpzPngCjgsrgPiCeK0AE57ylfxE19K4PD9S5jMN0hejdI(j5cbdxo3WaVa0cKWtQ)zSZtQNpJtq7V)27F57yK7WxDpjEAxpBEI5j1)m25j9BV)2)m256dC(K8boVtJYpPVO)lFhJClF19K4PD9S5jMNu)ZyNNeaAU9pJDU(aNpjFGZ70O8tcTJ5LV8jja4)I625RU3Xw(Q7jXt76zZtmpPpisge9tcWODmysflPvMdD4tQ)zSZtsyfXGROfyUWliJeYWV8DmYF19K4PD9S5jMN0hejdI(jHxiVBmMIaeoH88LbqczStHN21ZgsTALu8c5DJXuoxFNHNV41FYtw4PD9S5j1)m25jb7zS9h0W5lFhxzV6Es80UE28eZt6dIKbr)KoIuxiy4c2UnRi4fGwGeEs9pJDEsy72SIGxa6lFhJeV6Es80UE28eZt6dIKbr)KIb3tKiwmmC8JKuKrQLi4tQ)zSZtQb)E4BUaap5lFhJGV6Es80UE28eZtAAu(jHTBZkIn3f4Ex4BUauEYNu)ZyNNe2UnRi2CxG7DHV5cq5jF57yX5RUNepTRNnpX8KwHNeMZNu)ZyNN0zdI21ZpPZ2dXpjK)KoBWDAu(jHgJ5I5gC)q5cd)Y3Xi8xDpjEAxpBEI5j9brYGOFshrA2EEYIPrNoJDk80UE28K6Fg78KoBuHae)BUqF7x(ogb(Q7jXt76zZtmpPpisge9tkBppzX0OtNXofEAxpBEs9pJDEsOXyUU(gNV8LpPVb)Q7DSLV6Es80UE28eZtQ)zSZtsyfXGBmWq4yNNKHXFqiKXopjecZKE4vediTImWq4yhsffPnPhAdd8cqlKwVUEdPWlG0dTHbEbOK(xugt6cdt6FxVzfnKgdPPnt6WIxsQLoKum)3XGjDtBgikWmPqyM0Di9BifA8mgtAAZKk4BezaPbMuHgKKUWKM2mPhGii6H0)EYtpPfKUasdystBgWKkk8EsNnj1LjTNnTzaPhAddPoqaKqg7qAAhysHdz7SqA9KjJkKKMlPyeNpPPntQVXjPcRigqAmWq4yhsxystBMu4q2ojnxsp3WqkdGeYyhsHxaPZoKwVarq0dU8K(Gizq0pjbqW4SGzp8vyfXGBmWq4yhsRsATK6cbdxo3WaVa0cKaPwTs6rK(3tE6jlhGii6H0QKEeP)9KNEYYWFW6xGH0QK(31Bwrt5CdZLbqczStbWODmysrMtsT0HKA1kPWHSDEbmAhdMuXs6FxVzfnLZnmxgajKXofaJ2XGjTgsRsATKchY25fWODmysrMts)76nROPCUH5YaiHm2Pay0ogmPiLulrqsRs6FxVzfnLZnmxgajKXofaJ2XGjvSojv(BivCtksqQvRKchY25fWODmysrgP)D9Mv0uewrm4gdmeo2PyGaDg7qQvRK6UymPvjfoKTZlGr7yWKkws)76nROPCUH5YaiHm2Pay0ogmPiLulrqsTAL0)EYtpz5aebrpKA1kPUqWWfx)UgpeolqcKwZlFhJ8xDpjEAxpBEI5jzy8heczSZtcHWmPIPnYmPXGddt6ct6HqyKcVastBMu4aGtsHWmPlG0DifjRePnCYastBMu4aGtsHWCH0kosBspoKTtsryntQ96nKcVaspecR8KMgLFs4yGH8xzFBIoxa(62gz(UWxygS)ir8j9brYGOFsUqWWLZnmWlaTajqQvRKMbktkYi1shsAvsRL0Ji9VN80twMq2oVWntAnpP(NXopjCmWq(RSVnrNlaFDBJmFx4lmd2FKi(Y3Xv2RUNepTRNnpX8K6Fg78KGB(kd1at0d(jzy8heczSZtcHWmPiSMj1baQbMOhmP7qkswjsxOehgM0fM0dTHbEbOfsrimtkcRzsDaGAGj6XGjngsp0gg4fGsAatkIleP29jtkhPndi1baSNmPvK5mKxqNXoKUasryb7nKUWKkg)IXlkUqAf3rsk8ci1SjM0Cj1LjfsGuxgEbmP9pJZoJrMuewZK6aa1at0dM0CjfTfVanWmPPntQlemC5j9brYGOFshrQlemC5Cdd8cqlqcKwL0Aj9is)76nROPCUH5MlaWtwGei1QvspI0S98KLZnm3CbaEYcpTRNnKwdPvjTwspBq0UEUy2eFHeiTkPyb27VzdK5exoBuHae)BUqFBsDsQLKA1kPNniAxpxot8Tfe8bBiTkPyb27VzdK5exoBuHae)BUqFBsrgPwsAnKA1kPUqWWLZnmWlaTajqAvsRLu8c5DJXuKb7jFJ5mKxqNXofEAxpBi1QvsXlK3ngtboyV5UWxx)IXlkUWt76zdP18Y3XiXRUNepTRNnpX8K6Fg78KqJXi3Om(j9r875B2azoXVJT8j9brYGOFsXG7jsejvSKkU4qsRsATKwlPNniAxpxAV)A2eFHeiTkP1s6rK(31Bwrt5CdZLbqczStbsGuRwj9isZ2ZtwSHgzgeJ89CdtHN21ZgsRH0Ai1QvsDHGHlNByGxaAbsG0AiTkP1s6rKMTNNSydnYmig575gMcpTRNnKA1kPg2fcgUydnYmig575gMcGr7yWKIms)noVzGYKA1kPhrQlemC5Cdd8cqlqcKwdPvjTwspI0S98Kfm3GyKVtiBNOnGl80UE2qQvRKIfyV)MnqMtCbngZfZnGuXskcsAnpjdJ)GqiJDEsieMjfbeJrUrzmPIS5H027jTYiTsBDysBatkKGfKUasrCHiTbmPXq6H2WaVa0cPoWbdbysRxHgzgeJmPhAddPIcVNuCgEpPUmPqcKkYMhstBM0FJtsZaLjfoMaBZ4cPs5kqkeogzs7KueePKMnqMtmPII0MujUbXit6XHSDI2aU8Y3Xi4RUNepTRNnpX8K6Fg78KGg71J4D2Z(jzy8heczSZtcHWmPi0yVEej949SjDhsrYkzbP2R3eJmPUGGH9isAUKkQJKu4fqQWkIbKgdmeo2H0fqABmKIfArdU8K(Gizq0pPJinBppzXgAKzqmY3ZnmfEAxpBiTkPNniAxpxmBIVqcKA1kPg2fcgUydnYmig575gMcKaPvj1fcgUCUHbEbOfibsTAL0Aj9VR3SIMY5gMldGeYyNcGr7yWKImsT0HKA1kPhr6zdI21ZfHD9x4fC)gmP1qAvspIuxiy4Y5gg4fGwGeE57yX5RUNepTRNnpX8K6Fg78KC3DUl8nT5BJ)8yyZtYW4pieYyNNecHzs3HuKSsK6cLKkaIfezGzsHWXit6H2WqQdeajKXoKchaCAbPbmPqy2qAm4WWKUWKEiegP7qQuDKcHzsB4KbK2KEUHXD9jPWlG0)UEZkAiLHHJFWZhrs7Xqk8ci1gAKzqmYKEUHHuiHmqzsdysZ2ZtYMYt6dIKbr)KoIuxiy4Y5gg4fGwGeiTkPhr6FxVzfnLZnmxgajKXofibsRskwG9(B2azoXf0ymxm3asrgPwsAvspI0S98Kfm3GyKVtiBNOnGl80UE2qQvRKwlPUqWWLZnmWlaTajqAvsXcS3FZgiZjUGgJ5I5gqQyjf5KwL0JinBppzbZnig57eY2jAd4cpTRNnKwL0AjvaWNx5VPyz5CdZ1D9jPvjTwspIu2bHcbb2uyubebC7VlWm98zsTAL0JinBppzXgAKzqmY3ZnmfEAxpBiTgsTALu2bHcbb2uyubebC7VlWm98zsRs6FxVzfnfgvara3(7cmtpFUay0ogmPI1jPwkoroPvj1WUqWWfBOrMbXiFp3WuGeiTgsRHuRwjTwsDHGHlNByGxaAbsG0QKMTNNSG5geJ8Dcz7eTbCHN21ZgsR5LVJr4V6Es80UE28eZtQ)zSZt63E)T)zSZ1h48j5dCENgLFsjiMd4e)Y3XiWxDpjEAxpBEI5j9brYGOFs2C7t7IWpjvSojfHJGpP(NXopjdJfyqN8va0iYGx(YNucI5aoXV6EhB5RUNepTRNnpX8Kmm(dcHm25jHqyM0eeZbCsAdNmGubiVNuC2GetApgstBEiDhsrYkrAdNmG00UtsHMm8KI4crQmNKIePnP4S)huiToaIKMlPg23isQmNzmYKIGPnP4S)hqk8ci9VR3SIgCHuecZK6YWlGjDtBgq6oKcHzsZL0ztstqilZasRiizLi1LtrmpKMGyoGtmP16cjloUMYtAAu(jH)naFx4lmOtgmT)ItqaZpPpisge9tQwspIuxiy4c(3a8DHVWGozW0(lobbmFrIcKaPvjnduMuKrQLKwdPwTsATK6cbdxo3WaVa0cKaPwTsQlemCryfXGBmWq4yNcKaPwTs6FxVzfnLZnmxgajKXofaJ2XGjfzKAPdjTgsTAL0)EYtpzzcz78c38tQ)zSZtc)Ba(UWxyqNmyA)fNGaMF57yK)Q7jXt76zZtmpjdJ)GqiJDEsieMjDhsrYkrA9ivphM0CjvMtsR0whPz8pigzs7XqklEcbGjnxs9XWKcjqQlNjdivuK2KEOnmWla9jnnk)KyubebC7VlWm985N0hejdI(j931Bwrt5CdZLbqczStbWODmysfRtsTe5KA1kP)D9Mv0uo3WCzaKqg7uamAhdMuKrkYr4pP(NXopjgvara3(7cmtpF(LVJRSxDpjEAxpBEI5jzy8heczSZtQoaIKMlPsioFsRiIJujsffPnPvAHC9mPsz)pGnKIKvctAatQWIXHRNlKwrhs97iZasHdz7etQOiTjfDbmPveXrQePqygtANjJkKKMlPyeNpPII0M0EqK0VH0fqQ4qiCskeMjnYYtAAu(jfd(dGY21ZxheQNec9A4Z4ZpPpisge9tYfcgUCUHbEbOfibsRsQlemCryfXGBmWq4yNcKaPwTsQ7IXKwLu4q2oVagTJbtQyDskYDiPwTsQlemCryfXGBmWq4yNcKaPvj9VR3SIMY5gMldGeYyNcGr7yWKIusTebjfzKchY25fWODmysTALuxiy4Y5gg4fGwGeiTkP)D9Mv0uewrm4gdmeo2Pay0ogmPiLulrqsrgPWHSDEbmAhdMuRwjTws)76nROPiSIyWngyiCStbWODmysrMtsT0HKwL0)UEZkAkNByUmasiJDkagTJbtkYCsQLoK0AiTkPWHSDEbmAhdMuK5KulfxC4tQ)zSZtkg8haLTRNVoiupje61WNXNF57yK4v3tIN21ZMNyEsgg)bHqg78KKqC(KkzZCskcachFsffPnPhAdd8cqFstJYpj0(3Ua(ITzoVOq44)K(Gizq0pP)UEZkAkNByUmasiJDkagTJbtkYi1sh(K6Fg78Kq7F7c4l2M58IcHJ)lFhJGV6Es80UE28eZtAAu(jHxiVNZmg5laYfXN0hXVNVzdK5e)o2YNu)ZyNNeEH8EoZyKVaixeFsFqKmi6NKlemCryfXGBmWq4yNcKaPwTs6rKkacgNfm7HVcRigCJbgch7qQvRKYoiuiiWMc2UnRi2CxG7DHV5cq5jFsgg)bHqg78KKqC(KkUc5IiPII0M0dVIyaPvKbgch7qkeULzlifTpGjfdbysZLu8ecmPPntQFfX4K061dtA2azolKwX28qkeMnKkksBsLSBZkInKwrbUKUWKw3cq5jTGuXHq4Kuimt6oKIKvI0gtkk03M0gtQWIXHRNlV8DS48v3tIN21ZMNyEsgg)bHqg78KqybaNKkfYHNumA79KUczGg1l7m2HurrAtQ0c59CMXitQ4kKlIpPPr5NuAZx4aGZloKd)t6dIKbr)KCHGHlNByGxaAbsGuRwj1fcgUiSIyWngyiCStbsGuRwj9isfabJZcM9WxHvedUXadHJDi1Qvs)76nROPCUH5YaiHm2Pay0ogmPiJulDiPwTsATKYoiuiiWMcEH8EoZyKVaixejTkPhr6FxVzfnf8c59CMXiFbqUiwGeiTgsTALu3fJjTkPWHSDEbmAhdMuXskYD4tQ)zSZtkT5lCaW5fhYH)LVJr4V6Es80UE28eZtYW4pieYyNNecHzsftBKzsJbhgM0fM0dHWifEbKM2mPWbaNKcHzsxaP7qkswjsB4KbKM2mPWbaNKcH5cPs2lij9hGpuKKgWKEUHHugajKXoK(31BwrdPbMulDiM0fqk6cysBrnILN00O8tchdmK)k7Bt05cWx32iZ3f(cZG9hjIpPpisge9t6VR3SIMY5gMldGeYyNcGr7yWKImNKAPdFs9pJDEs4yGH8xzFBIoxa(62gz(UWxygS)ir8LVJrGV6Es80UE28eZtYW4pieYyNNecHzsLSBZkInKwrbUKUWKw3cq5jjvKnpKoBsAmKEOnmWla1csxaPXqQlNIyEi9qByivmRpj934etAmKEOnmWlaTqA9GjTEbIGOhsxaPhZFW6xGHuFmmPrskKaPII0MuC2)dydP)D9Mv0GlpPPr5Ne2UnRi2CxG7DHV5cq5jFsFqKmi6N0FxVzfnfHvedUXadHJDkagTJbtQyDsQLoK0QK(31Bwrt5CdZLbqczStbWODmysfRtsT0HKwL0Aj9VN80twg(dw)cmKA1kP)9KNEYYbicIEiTgsTAL0Aj9VN80two5jTreqQvRK(3tE6jltiBNx4MjTgsRsATKEePUqWWLZnmWlaTajqQvRKka4ZR83uSSCUH56U(K0Ai1QvsDxmM0QKchY25fWODmysfRtsrch(K6Fg78KW2TzfXM7cCVl8nxakp5lFhlU8Q7jXt76zZtmpP(NXopPg8TJK)j(gJmpqrI49Va(jzy8heczSZtcHWmPPDGjDhsrYkrk8cifTfpsrYkjU(KMgLFsn4Bhj)t8ngzEGIeX7Fb8lFhBPdF19K4PD9S5jMNu)ZyNNeeMVrYO4NKHXFqiKXopPkXWnKpjfU9E3(FaPWlGuiC76zsJKrXvoPieMjDhs)76nROH0yiDbggqQlIKMGyoGtsX(nlpPpisge9tYfcgUCUHbEbOfibsTALuxiy4IWkIb3yGHWXofibsTAL0)UEZkAkNByUmasiJDkagTJbtkYi1sh(Yx(KC3DE19o2YxDpjEAxpBEI5j9brYGOFsyb27VzdK5exqJXCXCdivSojTYEs9pJDEsn(ZJHnxxFJZx(og5V6Es80UE28eZtQ)zSZtQXFEmS5o7z)Kmm(dcHm25jvrhpIKcHzsRh8NhdBi949SjvKnpKoBsA2EEs2qAm5sQe3GyKj94q2orBat6oKICKsA2azoXLN0hejdI(jHfyV)MnqMtCPXFEmS5o7ztkYi1ssRskwG9(B2azoXf0ymxm3asrgPwsAvspI0S98Kfm3GyKVtiBNOnGl80UE28Yx(K(I(V6EhB5RUNepTRNnpX8K(Gizq0pjmNx3DGWLmyaYrGxKq4tAvsDHGHlMgCWnTxiz7SajqAvsf4Sah8yk9pJtM0QKcGggEbYCbB3MveSVr5RaiWOf2bHcbb2qAvspIuxiy4Y5gg4fGwGeiTkPcCwqCHaxSDBwrfaJ2XGjvSKchY25fWODmysTALuxiy4IPbhCt7fs2olqcKwLuboliUqGl2UnROcGr7yWKkwsL)McAlEKkUjTwsRmsrkP1s6rK6cbdxo3WaVa0cKaP1qQ4MulfNKwdPvjvGZcIle4ITBZkQay0ogmPILu4q2oVagTJb)K2XJ49l6)KS8jzy8heczSZtQoKJajfjCaXCs6FhtKXoTNu4fqkswXijPiGymKkgFJZNu)ZyNNeAmMRRVX5lFhJ8xDpjEAxpBEI5jbH5Ri7WZ3FJZyKFhB5tQ)zSZtcZnig57eY2jAd4N0hXVNVzdK5e)o2YN0hejdI(jvlPNniAxpxWCdIr(oHSDI2a((HYfgM0QKEePNniAxpxe21FHxW9BWKwdPwTsATKA2SGTBZk6kAbMRqhtbWWagB3UEM0QKIfyV)MnqMtCbngZfZnGuKrQLKwZtYW4pieYyNNecHzsL4geJmPhhY2jAdysdysrCHivu49KAhjP8SqY2KMnqMtmP9yi9WRigqAfzGHWXoK2JH0dTHbEbOK2aM0ztsbCBq0csxaP5skGHbm2MuPkUYpmP7qAkAjDbKIUaM0SbYCIlV8DCL9Q7jXt76zZtmpjimFfzhE((BCgJ87ylFs9pJDEsyUbXiFNq2orBa)K(i(98nBGmN43Xw(K(Gizq0pPS98Kfm3GyKVtiBNOnGl80UE2qAvsnBwW2TzfDfTaZvOJPayyaJTBxptAvsXcS3FZgiZjUGgJ5I5gqkYif5pjdJ)GqiJDEss2lijfjdWhkssL4geJmPhhY2jAdys)7yIm2H0Cj9aMfivQIR8dtkKaPXqA9SoWx(ogjE19K4PD9S5jMN0oEeVFr)NKLpP(NXopj0ymxxFJZNKHXFqiKXopPD8iE)I(KI2hWystBM0(NXoKUJhrsHWTRNj1abIrM0VDpd7JrM0EmKoBsAJjTjfWYq(gqA)ZyNYlF5lFsNmah78og5oe5i3HvMdr4pjrnyIrg)KQ46rC94kYXoavoPKwNntAGkSGKu4fqQ4NGyoGtS4tkGDqOaWgsXlktAdLlANSH0VDpYmUqowVJHjvCw5KIK7CYGKnKk(jiMd4S0U)YFxVzfnIpP5sQ4)31BwrtPD)IpP1AP4vtHCKCSIRhX1JRih7au5KsAD2mPbQWcssHxaPIVaG)lQBNIpPa2bHcaBifVOmPnuUODYgs)29iZ4c5y9ogMuKx5KIK7CYGKnKk(4fY7gJPioq8jnxsfF8c5DJXuehu4PD9Sr8jTwlfVAkKJ17yysrELtksUZjds2qQ4JxiVBmMI4aXN0Cjv8XlK3ngtrCqHN21ZgXN0oj1bwrR3KwRLIxnfYrYXkUEexpUICSdqLtkP1zZKgOclijfEbKk(ODmIpPa2bHcaBifVOmPnuUODYgs)29iZ4c5y9ogM0kRYjfj35KbjBiv8XlK3ngtrCG4tAUKk(4fY7gJPioOWt76zJ4tATwkE1uihR3XWKICeELtksUZjds2qQ4JxiVBmMI4aXN0Cjv8XlK3ngtrCqHN21ZgXN0ATu8QPqosowX1J46XvKJDaQCsjToBM0avybjPWlGuX)BWIpPa2bHcaBifVOmPnuUODYgs)29iZ4c5y9ogMuXzLtksUZjds2qQ4NGyoGZs7(l)D9Mv0i(KMlPI)FxVzfnL29l(KwRLIxnfYrYXkcQWcs2qkcN0(NXoK6dCIlKJpjSa)FhJCeeb(KealC45Nu9RpPs2Tzfr6HbbJtYX6xFsran4BtQLItlif5oe5iNCKCS(1NuK0Uhzgx5KJ1V(K6asADI4(asp0ggsRBbaEssfzZdPzdK5K0)cnjM0gWKcVGpBkKJ1V(K6as6HbCYJHuZMysBatkKaPIS5H0SbYCIjTbmPF)IzsZLudIXiBbP4L00UtshOdymPnGjfNH3tkG)lkkpg2uihjhRF9j1bkE8hkzdPUm8cys)lQBNK6YYXGlKwp)plKysNDCaTBakmKN0(NXoys3XJyHCS)zSdUia4)I62jsDwbHvedUIwG5cVGmsidBra7eWODmyXwzo0HKJ9pJDWfba)xu3orQZka7zS9h0WPfbSt8c5DJXueGWjKNVmasiJDSAfVqE3ymLZ13z45lE9N8KKJ9pJDWfba)xu3orQZkGTBZkcEbOweWopYfcgUGTBZkcEbOfibYX(NXo4IaG)lQBNi1zfAWVh(MlaWtAra7mgCprIyXWWXpsKzjcso2)m2bxea8FrD7ePoRaeMVrYOwmnk7eB3MveBUlW9UW3CbO8KKJ9pJDWfba)xu3orQZkC2GOD9SftJYorJXCXCdUFOCHHTyfCI50IZ2dXoro5y)ZyhCraW)f1TtK6ScNnQqaI)nxOVTfbSZJY2Ztwmn60zStHN21ZgYX(NXo4IaG)lQBNi1zfqJXCD9noTiGDMTNNSyA0PZyNcpTRNnKJKJ1NuhO4XFOKnKYNmarsZaLjnTzs7FUasdmP9zh(21ZfYX(NXoyN4WZZNjhRF9j9WBg7Gjh7Fg7GDkSzSJfbStxiy4Y5gg4fGwGeSA1fcgUiSIyWngyiCStbsGCS)zSdgPoRWzdI21Zwmnk70Sj(cjyXk4eZPfNThIDwRzZc2UnROROfyUcDmLm(heJSvRzdK5SKbkFZ9AcwSorIAQwRzZYzJkeG4FZf6BxY4FqmYwTMnqMZsgO8n3RjyX6uCwd5y)ZyhmsDwHZgeTRNTyAu2z79xZM4lKGfRGtmNwC2Ei25zdI21ZfZM4lKq1AnBwm85cbIr(k4BziUKX)GyKTAnBGmNLmq5BUxtWI1jsud5y9jvkBqskeogzsL4geJmPhhY2jAdys7K0kdPKMnqMtmPlGuKaPKgWKI4crAdysJH0dTHbEbOKJ9pJDWi1zfoBq0UE2IPrzNyUbXiFNq2orBaF)q5cdBXk4eZPfNThIDIfyV)MnqMtCbngZfZnazihPUqWWLZnmWlaTajqo2)m2bJuNv4Sbr76zlMgLD(nx0EAzgLN0IvWjMtloBpe7S2JaqddVazUGfSzaJV2naDhelSdcfccSP6r)9KNEYYWFW6xGXQ1)UEZkAkcRigCJbgch7uamAhdwSoL)McAlEI7kZQvxiy4IWkIb3yGHWXofibRwDxmUkCiBNxaJ2XGfRtKJG1qo2)m2bJuNv4Sbr76zlMgLDI2I39mXwScoXCAXz7HyNyb27VzdK5exoBuHae)BUqFBYX(NXoyK6ScNniAxpBX0OSt0w8UNj2IvWjMtloBpe7ebrkYf31E2GOD9C5BUO90Ymkpz1)UEZkAkNByUmasiJDkagTJblwNw6WAQMTNNSydnYmig575gMcpTRNnweWoZ2ZtwWCdIr(oHSDI2aUWt76ztvSa793SbYCIlOXyUyUbor4KJ9pJDWi1zfoBq0UE2IPrzNOT4DptSfRGtmNwC2Ei2PdTiGDMTNNSG5geJ8Dcz7eTbCHN21ZMQyb27VzdK5exqJXCXCdqgcNCS)zSdgPoRWzdI21Zwmnk7eTfV7zITyfCI50IZ2dXorclcyNz75jlyUbXiFNq2orBax4PD9SPkwG9(B2azoXf0ymxm3aNiWQhLTNNSGTBZk6(bn2UWt76zd5y)ZyhmsDwHZgeTRNTyAu2jAlE3ZeBXk4eZPfNThIDwlwG9(B2azoXf0ymxm3aX6ebRrCJfyV)MnqMtCbngZfZnWIa2PlemC5Cdd8cqlqcKJ9pJDWi1zfoBq0UE2IPrzNb(EMxHfJdxpBXk4eZPfNThID6qlmmCd5tNwso2)m2bJuNv4Sbr76zlMgLDg47zEfwmoC9SfRGtmNwC2Ei2PLweWo7FgN81Sz5Srfcq8V5c9Tf7hXVNV8WObJjh7Fg7GrQZkC2GOD9SftJYopt8Tfe8bBSyfCI50IZ2dXo7FgN81Sz5Srfcq8V5c9TrMZZgeTRNlOT4DptSvRhD2GOD9CjW3Z8kSyC46zYX6tksUR3SIgsp8UEspudI21ZwqkcHzdP5sQWUEsDz4fWK2)mo7mgzsp0gg4fGwih7Fg7GrQZkC2GOD9SftJYof21FHxW9BWwScoXCAXz7HyN)D9Mv0uo3WCzaKqg7uGeQE2GOD9C5BUO90Ymkpj5y)ZyhmsDwb4aWU(DnweWoDHGHlNByGxaAbsGCS)zSdgPoRGldWm4GyKTiGD6cbdxo3WaVa0cKa5y9jfHWmP17q2ofFmPoczKr5jjnGjnTzatAdysroPlGu0fWKMnqMtSfKUasBJbtAd4r8tsXcTOjgzsHxaPOlGjnT7HueocIlKJ9pJDWi1zf8HSDIVIdHmYO8KweWoXcS3FZgiZjU4dz7eFfhczKr5jrMtKB1AThb6WC5tEYsBm4clEboXwTc6WC5tEYsBm4smidHJG1qo2)m2bJuNvONpJtq7V)27TiGD6cbdxo3WaVa0cKa5y)ZyhmsDwHF793(NXoxFGtlMgLD(f9jh7Fg7GrQZkaGMB)ZyNRpWPftJYor7yihjhRF9jTEoC9M0CjfcZKkYMhsfZUdPlmPPntA9G)8yydPbM0(NXjto2)m2bxC3DC24ppg2CD9noTiGDIfyV)MnqMtCbngZfZnqSoRmYX6tAfD8iskeMjTEWFEmSH0J3ZMur28q6SjPz75jzdPXKlPsCdIrM0Jdz7eTbmP7qkYrkPzdK5exih7Fg7GlU7oi1zfA8NhdBUZE2weWoXcS3FZgiZjU04ppg2CN9SrMLvXcS3FZgiZjUGgJ5I5gGmlREu2EEYcMBqmY3jKTt0gWfEAxpBihjhRF9jfjReMCS(KIqyM0dVIyaPvKbgch7qQOiTj9qByGxaAH0611BifEbKEOnmWlaL0)IYysxyys)76nROH0yinTzshw8ssT0HKI5)ogmPBAZarbMjfcZKUdPFdPqJNXystBMubFJidinWKk0GK0fM00Mj9aebrpK(3tE6jTG0fqAatAAZaMurH3t6SjPUmP9SPndi9qByi1bcGeYyhst7atkCiBNfsRNmzuHK0CjfJ48jnTzs9nojvyfXasJbgch7q6ctAAZKchY2jP5s65ggszaKqg7qk8ciD2H06ficIEWfYX(NXo4Y3GDkSIyWngyiCSJfbStbqW4SGzp8vyfXGBmWq4yNQ16cbdxo3WaVa0cKGvRh93tE6jlhGii6P6r)9KNEYYWFW6xGP6FxVzfnLZnmxgajKXofaJ2XGrMtlDOvRWHSDEbmAhdwS)D9Mv0uo3WCzaKqg7uamAhdUMQ1chY25fWODmyK58VR3SIMY5gMldGeYyNcGr7yWi1seS6FxVzfnLZnmxgajKXofaJ2XGfRt5VrCJewTchY25fWODmyK931BwrtryfXGBmWq4yNIbc0zSJvRUlgxfoKTZlGr7yWI9VR3SIMY5gMldGeYyNcGr7yWi1se0Q1)EYtpz5aebrpwT6cbdxC97A8q4Sajud5y9jfHWmPsHNNpt6oKIKvI0CjvaSFsLybBO6LIpM0dd2VVr7m2PqowFs7Fg7GlFdgPoRao888zlYgiZ5nGDcGggEbYCbZc2q1lXxbW(9nANXof2bHcbb2uT2SbYCwc8TngRwZgiZzXWUqWWLFJZyKlaU)znKJ1NuecZKkM2iZKgdommPlmPhcHrk8cinTzsHdaojfcZKUas3HuKSsK2WjdinTzsHdaojfcZfsR4iTj94q2ojfH1mP2R3qk8ci9qiSc5y)ZyhC5BWi1zfGW8nsg1IPrzN4yGH8xzFBIoxa(62gz(UWxygS)ir0Ia2PlemC5Cdd8cqlqcwTMbkJmlDy1Ap6VN80twMq2oVWnxd5y9jfHWmPiSMj1baQbMOhmP7qkswjsxOehgM0fM0dTHbEbOfsrimtkcRzsDaGAGj6XGjngsp0gg4fGsAatkIleP29jtkhPndi1baSNmPvK5mKxqNXoKUasryb7nKUWKkg)IXlkUqAf3rsk8ci1SjM0Cj1LjfsGuxgEbmP9pJZoJrMuewZK6aa1at0dM0CjfTfVanWmPPntQlemCHCS)zSdU8nyK6ScWnFLHAGj6bBra78ixiy4Y5gg4fGwGeQw7r)D9Mv0uo3WCZfa4jlqcwTEu2EEYY5gMBUaapzHN21ZMAQw7zdI21ZfZM4lKqvSa793SbYCIlNnQqaI)nxOVTtlTA9Sbr765YzIVTGGpytvSa793SbYCIlNnQqaI)nxOVnYSSgRwDHGHlNByGxaAbsOAT4fY7gJPid2t(gZziVGoJDk80UE2y1kEH8UXykWb7n3f(66xmErXfEAxpBQHCS(KIqyMueqmg5gLXKkYMhsBVN0kJ0kT1HjTbmPqcwq6cifXfI0gWKgdPhAdd8cqlK6ahmeGjTEfAKzqmYKEOnmKkk8EsXz49K6YKcjqQiBEinTzs)nojnduMu4ycSnJlKkLRaPq4yKjTtsrqKsA2azoXKkksBsL4geJmPhhY2jAd4c5y)ZyhC5BWi1zfqJXi3Om2IpIFpFZgiZj2PLweWoJb3tKikwXfhwT2ApBq0UEU0E)1Sj(cjuT2J(76nROPCUH5YaiHm2Pajy16rz75jl2qJmdIr(EUHPWt76ztn1y1QlemC5Cdd8cqlqc1uT2JY2ZtwSHgzgeJ89CdtHN21ZgRwnSlemCXgAKzqmY3ZnmfaJ2XGr2VX5ndu2Q1JCHGHlNByGxaAbsOMQ1Eu2EEYcMBqmY3jKTt0gWfEAxpBSAflWE)nBGmN4cAmMlMBGyrWAihRpPieMjfHg71JiPhVNnP7qkswjli1E9MyKj1femShrsZLurDKKcVasfwrmG0yGHWXoKUasBJHuSqlAWfYX(NXo4Y3GrQZkan2RhX7SNTfbSZJY2ZtwSHgzgeJ89CdtHN21ZMQNniAxpxmBIVqcwTAyxiy4In0iZGyKVNBykqcvDHGHlNByGxaAbsWQ1A)76nROPCUH5YaiHm2Pay0ogmYS0HwTE0zdI21ZfHD9x4fC)gCnvpYfcgUCUHbEbOfibYX6tkcHzs3HuKSsK6cLKkaIfezGzsHWXit6H2WqQdeajKXoKchaCAbPbmPqy2qAm4WWKUWKEiegP7qQuDKcHzsB4KbK2KEUHXD9jPWlG0)UEZkAiLHHJFWZhrs7Xqk8ci1gAKzqmYKEUHHuiHmqzsdysZ2ZtYMc5y)ZyhC5BWi1zfC3DUl8nT5BJ)8yyJfbSZJCHGHlNByGxaAbsO6r)D9Mv0uo3WCzaKqg7uGeQIfyV)MnqMtCbngZfZnazww9OS98Kfm3GyKVtiBNOnGl80UE2y1ATUqWWLZnmWlaTajuflWE)nBGmN4cAmMlMBGyrE1JY2ZtwWCdIr(oHSDI2aUWt76zt1Afa85v(Bkwwo3WCDxFwT2JyhekeeytHrfqeWT)UaZ0ZNTA9OS98KfBOrMbXiFp3Wu4PD9SPgRwzhekeeytHrfqeWT)UaZ0ZNRMGyoGZcJkGiGB)DbMPNpx(76nROPay0ogSyDAP4e5vnSlemCXgAKzqmY3ZnmfiHAQXQ1ADHGHlNByGxaAbsOA2EEYcMBqmY3jKTt0gWfEAxpBQHCS)zSdU8nyK6Sc)27V9pJDU(aNwmnk7mbXCaNyYX(NXo4Y3GrQZkyySad6KVcGgrgyra70MBFAxe(PyDIWrqYrYX6xFsrYgNKwX2HNjfjBCgJmP9pJDWfsL4K0oj1oKTzaPcGybrIiP5sk2EbjP)a8HIK0ysgaGess)7yIm2bt6oKIaIXqQe3GkGW8nIKJ1N06qocKuKWbeZjP)Dmrg70EsHxaPizfJKKIaIXqQy8nojh7Fg7GlFrFNOXyUU(gNwSJhX7x03PLwKnqMZBa7eZ51DhiCjdgGCe4fje(vDHGHlMgCWnTxiz7SajuvGZcCWJP0)mo5QaOHHxGmxW2Tzfb7Bu(kacmAHDqOqqGnvpYfcgUCUHbEbOfiHQcCwqCHaxSDBwrfaJ2XGflCiBNxaJ2XGTA1fcgUyAWb30EHKTZcKqvboliUqGl2UnROcGr7yWIv(BkOT4jURTYqATh5cbdxo3WaVa0cKqnIBlfN1uvGZcIle4ITBZkQay0ogSyHdz78cy0ogm5y9jfHWmPsCdIrM0Jdz7eTbmPbmPiUqKkk8EsTJKuEwizBsZgiZjM0EmKE4vediTImWq4yhs7Xq6H2WaVausBat6SjPaUniAbPlG0CjfWWagBtQufx5hM0DinfTKUasrxatA2azoXfYX(NXo4Yx03jMBqmY3jKTt0gWwaH5Ri7WZ3FJZyKDAPfFe)E(MnqMtStlTiGDw7zdI21Zfm3GyKVtiBNOnGVFOCHHRE0zdI21ZfHD9x4fC)gCnwTwRzZc2UnROROfyUcDmfaddySD765Qyb27VzdK5exqJXCXCdqML1qowFsLSxqsksgGpuKKkXnigzspoKTt0gWK(3XezSdP5s6bmlqQufx5hMuibsJH06zDGKJ9pJDWLVOpsDwbm3GyKVtiBNOnGTacZxr2HNV)gNXi70sl(i(98nBGmNyNwAra7mBppzbZnig57eY2jAd4cpTRNnvnBwW2TzfDfTaZvOJPayyaJTBxpxflWE)nBGmN4cAmMlMBaYqo5y9jDhpI3VOpPO9bmM00MjT)zSdP74rKuiC76zsnqGyKj9B3ZW(yKjThdPZMK2ysBsbSmKVbK2)m2Pqo2)m2bx(I(i1zfqJXCD9noTyhpI3VOVtljhjhRF9jfb0XqA9C46TfKITxiVH0)EYasBVNuqpYmM0fM0SbYCIjThdP4ppniwm5y)ZyhCbTJX5V9(B)ZyNRpWPftJYoD3DSaNG4NoT0Ia2PlemCXD35UW30MVn(ZJHnfibYX(NXo4cAhdsDwbtGfy)fTLJVfbSZJYgiZzjWxbFJidihRpPieMj9qByi1bcGeYyhs3H0)UEZkAivyxFmYK2jPEUXjPihbjngCprIiP1Uasrchsk8civm(DnK6a9WKUdPRapmOgsDHssNnjnGjfXfIurH3t6EYGFlqAm4EIersJH0dHWkKIa6dysXqaMuj72SIGdEmvabeJXLhddiThdPiGymKkgFJtsdmP7q6FxVzfnK6YWlGj9qoqsdysLSBZkc23OmPbMu2bHcbb2uiTIiplGjvyxFmYKcyCcIFg7GjnGjfchJmPs2Tzfb7BuM0ddcmkP9yivm8yyaPbM0fklKJ9pJDWf0ogK6ScNByUmasiJDSiGDE2GOD9Cryx)fEb3VbxT2yW9ejIiZjYrqKwRLiO4Uwq)5IRFxZL9WvZaLfBL5WAQXQvbolWbpMs)Z4KRcGggEbYCbB3MveSVr5RaiWOf2bHcbb2u9O)UEZkAkOXyUU(gNfiHQh931BwrtbB3Mv0v0cmxd3PDbsOMQ1gdUNiruSorGiOvRz75jlyUbXiFNq2orBax4PD9SP6zdI21Zfm3GyKVtiBNOnGVFOCHHRP6r)D9Mv0uGdEmfiHQ1EeEH8UXykNRVZWZx86p5jTA1fcgUCU(odpFXR)KNSajy1kMZmgzCjKNfWx86p5jRHCS(KIa6dysXqaMuexisfGssHeivQIR8dtA9ivphM0DinTzsZgiZjPbmPvmOtByipPiSMbbtAGhXpjT)zCYKkYMhsHdz7mgzsT0bSYinBGmN4c5y)ZyhCbTJbPoRa2UnROROfyUcDmweWoDHGHlWnFLHAGj6bxGeQEKHDHGHlIaDAdd5VWndcUajuflWE)nBGmN4cAmMlMBGyrcYX(NXo4cAhdsDwb0ymxm3al(i(98nBGmNyNwAra7mBppzbZnig57eY2jAd4cpTRNnvXcS3FZgiZjUGgJ5I5gGSZgeTRNlOXyUyUb3puUWWvpYSzbB3Mv0v0cmxHoMsg)dIrU6r)D9Mv0uGdEmfiHQyb27VzdK5exqJXCXCdqMtKGCS)zSdUG2XGuNv43E)T)zSZ1h40IPrzNFdMCS(KwVgY2KEyqSGirKueqmgsL4gqA)ZyhsZLuaddySnPvARdtQOiTjfZnig57eY2jAdyYX(NXo4cAhdsDwb0ymxm3al(i(98nBGmNyNwAra7mBppzbZnig57eY2jAd4cpTRNnvXcS3FZgiZjUGgJ5I5gGSZgeTRNlOXyUyUb3puUWWvpYSzbB3Mv0v0cmxHoMsg)dIrU6r)D9Mv0uGdEmfibYX6t6HbmmdinxsHWmPvQrNoJDiTEKQNdtAatQufx5hM0fq6HQJ0at6SjPqcKUasrCHi93ZSjP)gNK2KolaT9Kwj(CHaXit6H9TmetATX89qMyKjfbeJH0kXNleGbKka2pUgs7XqkIlePIcVN0zts)TaPvQbhqAD2lKSDIjfN9)amPbmPq4yKjToKJajf5c)c5y)ZyhCbTJbPoRGPrNoJDS4J43Z3SbYCIDAPfbSZAnBwoBuHae)BUqF7cGHbm2UD9SvRMnly72SIUIwG5k0XuammGX2TRNTAT2JCHGHlOXyUg(CHamOajungCprIOyrqhwtnvR1fcgUyAWb30EHKTZco7)bI1fcgUyAWb30EHKTZcAlExC2)dSA9imNx3DGWLmyaYrGxKl8RHCS(KIqyMuj72SIiTIxGH0kXDAtAatkeogzsLSBZkc23OmPhgeyus7XqQlpggqQOW7jLfpHaWKAGaXitAAZKoS4LKk)nfYX(NXo4cAhdsDwbSDBwrxrlWCnCN2weWof4Sah8yk9pJtUkaAy4fiZfSDBwrW(gLVcGaJwyhekeeytvbolWbpMcGr7yWI1P83uflWE)nBGmN4cAmMlMBGyDIWjhRpP1JxuJiMuimtkAmgxFJtmPbmP)wqGnK2JHuBOrMbXit65ggsdmPqcK2JHuiCmYKkz3MveSVrzspmiWOK2JHuxEmmG0atkKqHusRhJjYyN27r0cs)nojfngJRVXjPbmPiUqKkAH8gsDzsHM21ZKMlPYCsAAZKcc4KuxejvuhzmYK2Kk)nfYX(NXo4cAhdsDwb0ymxxFJtlcyN1(31BwrtbngZ1134S8TBGmJrMLvR1WUqWWfBOrMbXiFp3WuGeSA9OS98KfBOrMbXiFp3Wu4PD9SPgRwf4Sah8ykagTJblwN)gN3mqzKk)n1uvGZcCWJP0)mo5QaOHHxGmxW2Tzfb7Bu(kacmAHDqOqqGnvf4Sah8ykagTJbJSFJZBgOCvSa793SbYCIlOXyUyUbI1jc3Qvxiy4IPbhCt7fs2olqcvDHGHlNByGxaAbsO6r)D9Mv0uo3WCDxFwGeQw7raOHHxGmxW2Tzfb7Bu(kacmAHDqOqqGnwTEKaNf4GhtP)zCY1ufZ51DhiCjdgGCe4fje(KJ1NuecZKEOnmKkM1NK2jP2HSndivaelisejvuK2KwVcnYmigzsp0ggsHeinxsrcsZgiZj2csxaPBAZasZ2ZtIjDhsLQRqo2)m2bxq7yqQZkCUH56U(0Ia2zm4EIerX6ebIGvZ2ZtwSHgzgeJ89CdtHN21ZMQz75jlyUbXiFNq2orBax4PD9SPkwG9(B2azoXf0ymxm3aX6uCA1AT1MTNNSydnYmig575gMcpTRNnvpkBppzbZnig57eY2jAd4cpTRNn1y1kwG9(B2azoXf0ymxm3aNwwd5y9jvsG)r7jTs85cbIrM0d7BziMurrAtQe3GyKj94q2orBatQiBEifc3YmPgiqmYKIK76nRObto2)m2bxq7yqQZky4ZfceJ8vW3YqSfbSZAXCED3bcxYGbihbErcHVvRz75jl2qJmdIr(EUHPWt76ztnvZ2ZtwWCdIr(oHSDI2aUWt76ztvbolWbpMs)Z4KRcGggEbYCbB3MveSVr5RaiWOf2bHcbb2u1fcgUCUHbEbOfiHQyb27VzdK5exqJXCXCdeRtXj5y9jTs7i(jPqyM0kXNleigzspSVLHysdysrCHi93dPYCsAm5s6H2WaVausJbNCBSG0fqAatQe3GyKj94q2orBatAGjnBppjBiThdPIcVNu7ijLNfs2M0SbYCIlKJ9pJDWf0ogK6Scg(CHaXiFf8TmeBra7SwaddySD76zRwJb3tKiImeocA1A2EEYY5gMBUaapzHN21ZMQ)D9Mv0uo3WCZfa4jlagTJblwNvM4w(BQPAThD2GOD9Cryx)fEb3VbB1Am4EIerK5ebIG1uT2JY2ZtwWCdIr(oHSDI2aUWt76zJvR1MTNNSG5geJ8Dcz7eTbCHN21ZMQhD2GOD9CbZnig57eY2jAd47hkxy4AQHCS(KIqyM0djgs3HuKSsKgWKI4crQzhXpjDy2qAUK(BCsAL4ZfceJmPh23YqSfK2JH00MbmPnGj1ZymPPDpKIeKMnqMtmPlusATiiPII0M0)ogOiRPqo2)m2bxq7yqQZkCUH56U(0Ia2jwG9(B2azoXf0ymxm3aXwlsG0)ogOilMaJ3PN8YF7LXfEAxpBQPAm4EIerX6ebIGvZ2ZtwWCdIr(oHSDI2aUWt76zJvRhLTNNSG5geJ8Dcz7eTbCHN21ZgYX6tkcHzsLSBZkI0kEbMkN0kXDAtAatAAZKMnqMtsdmPT7cLKMlPMGjDbKI4crQDFYKkz3MveSVrzspmiWOKYoiuiiWgsffPnPiGymU8yyaPlGuj72SIGdEmK2)mo5c5y)ZyhCbTJbPoRa2UnROROfyUgUtBl(i(98nBGmNyNwAra7S2SbYCwS52N2fHFkwK7WQyb27VzdK5exqJXCXCdelsuJvR1kWzbo4Xu6FgNCva0WWlqMly72SIG9nkFfabgTWoiuiiWMQyb27VzdK5exqJXCXCdeRteEnKJ1NuecZKkbba8yyaP5skcOndJXKUdPnPzdK5K00UtsdmPYBmYKMlPMGjTtstBMuqiBNKMbkxih7Fg7GlODmi1zfWqaapggCZ9I2MHXyl(i(98nBGmNyNwAra7mBGmNLmq5BUxtWIf5oSQlemC5Cdd8cqlMv0qowFsrimt6H2WqADlaWts6oEejnGjvQIR8dtApgspuDK2aM0(NXjtApgstBM0SbYCsQODe)KutWKAGaXitAAZK(T7zyFHCS)zSdUG2XGuNv4CdZnxaGN0IpIFpFZgiZj2PLweWopBq0UEUy2eFHeQwRlemC5Cdd8cqlMv0y1QlemC5Cdd8cqlagTJbl2)UEZkAkNByUURplagTJbB1QaGpVYFtXYY5gMR76ZQh5cbdxC97A8q4Sa4(NvXcS3FZgiZjUGgJ5I5gi2kRMQNniAxpxot8Tfe8bBQIfyV)MnqMtCbngZfZnqS1IGiTwXP4oBppzjff48UWx4o5cpTRNn1ud5y)ZyhCbTJbPoRaAmgxEmmWIa2zTz75jlyUbXiFNq2orBax4PD9SPkwG9(B2azoXf0ymxm3aKD2GOD9CbngZfZn4(HYfg2QvZMfSDBwrxrlWCf6ykz8pig5AQE2GOD9C5mX3wqWhSHCS(KIqyMuPkUYRePII0M0d3X4c4(agq6HXThLuOXZymPPntA2azojvu49K6YK6Y(vePi3HIJIuxgEbmPPnt6FxVzfnK(xugtQB)pOqo2)m2bxq7yqQZkGTBZk6kAbMRH702Ia2jaAy4fiZfHogxa3hWGRaU9Of2bHcbb2u9Sbr765Izt8fsOA2azolzGY3CVc)8IChISA)76nROPGTBZk6kAbMRH70UyGaDg7Gu5VPgYX6tkcHzsLSBZkIuKe0yBs3HuKSsKcnEgJjnTzatAdysBJbtAm)fng5c5y)ZyhCbTJbPoRa2UnRO7h0yBlcyNGomx(KNS0gdUedYS0HKJ1NuecZKIaIXqQe3asZL0)oyiuM0k1GdiTo7fs2oXKka2pM0DiTEQOoWcP1vrRufLuKCh4aGsAGjnTdmPbM0Mu7q2MbKkaIfejIKM29qkGnBMXit6oKwpvuhiPqJNXysnn4ast7fs2oXKgysB3fkjnxsZaLjDHsYX(NXo4cAhdsDwb0ymxm3al(i(98nBGmNyNwAra7elWE)nBGmN4cAmMlMBaYoBq0UEUGgJ5I5gC)q5cdx1fcgUyAWb30EHKTZcKGfF7ogNwArmjdaqc5nqrzt0j70slIjzaasiVbSZm(hGrMtKGCS(1N06QOvQIw5KsksAZ)dinTdmPiGymKIW8nIKgOcEgLNSZyhsZLumZKgWKgjPUaUpat6M2mGuWcLXWK(T7zypM0fMueqmgsry(grXrtkAJiPdZgsZLu0(aM00oWK6c4(GwMjDhpIKkAbhqQOiTjnTzsXCsQ7oq4c5y9jfHWmPiGymKIW8nIKMlP)DWqOmPvQbhqAD2lKSDIjvaSFmP7qQuDKUqjommPlmPhcHvih7Fg7GlODmi1zfqJXCH9nIweWoDHGHlMgCWnTxiz7Saju9Sbr765Izt8fsO6rUqWWLZnmWlaTaju9OZgeTRNlc76VWl4(n4Q)D9Mv0uqJXCD9nolWqE)fWF7giZ3mqzK5u(BkOT4zX3UJXPLwetYaaKqEduu2eDYoT0IysgaGeYBa7mJ)byK5ejQEKlemCX0GdUP9cjBNfibYX6tkcHzsraXyivm(gNKgWKI4crQzhXpjDy2qAUKcyyaJTjTsBD4cPs5kq6VXzmYK2jPibPlGu0fWKMnqMtmPII0MujUbXit6XHSDI2aM0S98KSH0EmKI4crAdysNnjfchJmPs2Tzfb7BuM0ddcmkPlG0dJr8BhFsR3XCqblWE)nBGmN4cAmMlMBaYehJGKkZjM00MjfnMafcL0fMueK0EmKM2mPdeQldiDHjnBGmN4cP1JhVwqQzjD2KubaJXKIgJX134KuOjdpPT3tA2azoXK2aMuZMjBivuK2KEO6ivKnpKcHJrMuSDBwrW(gLjvaeyusdysD5XWasdmP9zh(21ZfYX(NXo4cAhdsDwb0ymxxFJtlcyNNniAxpxmBIVqcvbDyU8jpzbDpzuEYsmi7348MbkJuhwqWQyb27VzdK5exqJXCXCdeBTibsrU4oBppzbnWmaXcpTRNniT)zCYxZMLZgviaX)Ml03wCNTNNSiGr8Bh)RpMdk80UE2G0AXcS3FZgiZjUGgJ5I5gGmXXiynI7Af4Sah8yk9pJtUkaAy4fiZfSDBwrW(gLVcGaJwyhekeeytn1uT2JaqddVazUGTBZkc23O8vaey0c7GqHGaBSA9O)UEZkAkWbpMcKqva0WWlqMly72SIG9nkFfabgTWoiuiiWgRwpBq0UEUCM4Bli4d2ud5y9jvCLHbm2M0d1Ocbi(Kw3c9TjvuGzpIK62y2q6oKwPgD6m2H0EmKUPndiTU2ZtIlKJ9pJDWf0ogK6ScNnQqaI)nxOVTfFe)E(MnqMtStlTiGDcyyaJTBxpxnBGmNLmq5BUxtWiZPLiWQ1A2SC2Ocbi(3CH(2Lm(heJSvRhD2GOD9C5mX3wqWhSPMQNniAxpxqBX7EMyK5qRwRnBppzbnWmaXcpTRNnvnBwW2TzfDfTaZvOJPayyaJTBxpxJvRUqWWfObgc4Jr(AAWbdJXfibYX6tQKa)J2t6FhtKXoKMlP4Cfi934mgzsLQ4k)WKUdPlmSdy2azoXKkYMhsHdz7mgzsRmsxaPOlGjfN9)a2qk66IjThdPq4yKj9Wye)2XN06DmhqApgspUIwhPiGaZaelKJ9pJDWf0ogK6Scy72SIUIwG5k0Xyra7eWWagB3UEUA2azolzGY3CVMGrgsu9OS98Kf0aZael80UE2unBppzraJ43o(xFmhu4PD9SPkwG9(B2azoXf0ymxm3aKHCYX6tA9cMfivQIR8dtkKaP7qAJjfThejnBGmNysBmPclghUE2cszX7ZcjPIS5Hu4q2oJrM0kJ0fqk6cysXz)pGnKIUUysffPnPhgJ43o(KwVJ5Gc5y)ZyhCbTJbPoRa2UnROROfyUcDmw8r875B2azoXoT0Ia2jGHbm2UD9C1SbYCwYaLV5EnbJmKO6rz75jlObMbiw4PD9SP6r1MTNNSG5geJ8Dcz7eTbCHN21ZMQyb27VzdK5exqJXCXCdq2zdI21Zf0ymxm3G7hkxy4AQw7rz75jlcye)2X)6J5GcpTRNnwTwB2EEYIagXVD8V(yoOWt76ztvSa793SbYCIlOXyUyUbI1jYRPgYX6tkcHzsryEgB)bnCs6cL4WWKUWKI2Xq6FxVzfnysZLu0oMSJH0dT(odptQ06p5jj1fcgUqo2)m2bxq7yqQZka7zS9h0WPfbSt8c5DJXuoxFNHNV41FYtw9ixiy4Y5gg4fGwGeQEKlemCryfXGBmWq4yNcKqvxiy4Y567m88fV(tEYcGr7yWI1shArmjdaqc5nqrzt0j70slIjzaasiVbSZm(hGrMtljh7Fg7GlODmi1zfqJXCXCdS4J43Z3SbYCIDAPfbStSa793SbYCIlOXyUyUbi7Sbr765cAmMlMBW9dLlmSfF7ogNwArmjdaqc5nqrzt0j70slIjzaasiVbSZm(hGrMtKto2)m2bxq7yqQZkGgJ5c7BeT4B3X40slIjzaasiVbkkBIozNwArmjdaqc5nGDMX)amYCI8Q1EKlemCX0GdUP9cjBNfibRw)76nROPCUH56U(SajuTwxiy4Y5gg4fGwGeSA9ixiy4IPbhCt7fs2olqcvDHGHlMaJ3PN8YF7LXfiHAQHCS(KIqyMuPkUYRePnMuFJtsbmEbjPbmP7qAAZKIUNm5y)ZyhCbTJbPoRa2UnROROfyUgUtBYX6tkcHzsLQ4k)WK2ys9nojfW4fKKgWKUdPPntk6EYK2JHuPkUYRePbM0DifjRe5y)ZyhCbTJbPoRa2UnROROfyUcDmKJKJ1NuecZKMGyoGtsB4KbKka59KIZgKys7XqAAZdP7qkswjsB4KbKM2Dsk0KHNuexisL5KuKiTjfN9)GcP1bqK0Cj1W(grsL5mJrMuemTjfN9)asHxaP)D9Mv0GlKIqyMuxgEbmPBAZas3HuimtAUKoBsAcczzgqAfbjRePUCkI5H0eeZbCIjTwxizXX1uih7Fg7GljiMd4e7ecZ3izulMgLDI)naFx4lmOtgmT)ItqaZweWoR9ixiy4c(3a8DHVWGozW0(lobbmFrIcKq1mqzKzznwTwRlemC5Cdd8cqlqcwT6cbdxewrm4gdmeo2Pajy16FxVzfnLZnmxgajKXofaJ2XGrMLoSgRw)7jp9KLjKTZlCZKJ1NuecZKUdPizLiTEKQNdtAUKkZjPvARJ0m(heJmP9yiLfpHaWKMlP(yysHei1LZKbKkksBsp0gg4fGso2)m2bxsqmhWjgPoRaeMVrYOwmnk7KrfqeWT)UaZ0ZNTiGD(31Bwrt5CdZLbqczStbWODmyX60sKB16FxVzfnLZnmxgajKXofaJ2XGrgYr4KJ1N06aisAUKkH48jTIiosLivuK2KwPfY1ZKkL9)a2qkswjmPbmPclghUEUqAfDi1VJmdifoKTtmPII0Mu0fWKwrehPsKcHzmPDMmQqsAUKIrC(KkksBs7brs)gsxaPIdHWjPqyM0ilKJ9pJDWLeeZbCIrQZkaH5BKmQftJYoJb)bqz765Rdc1tcHEn8z8zlcyNUqWWLZnmWlaTaju1fcgUiSIyWngyiCStbsWQv3fJRchY25fWODmyX6e5o0Qvxiy4IWkIb3yGHWXofiHQ)D9Mv0uo3WCzaKqg7uamAhdgPwIGidoKTZlGr7yWwT6cbdxo3WaVa0cKq1)UEZkAkcRigCJbgch7uamAhdgPwIGidoKTZlGr7yWwTw7FxVzfnfHvedUXadHJDkagTJbJmNw6WQ)D9Mv0uo3WCzaKqg7uamAhdgzoT0H1ufoKTZlGr7yWiZPLIloKCS(KkH48jvYM5Kueaeo(KkksBsp0gg4fGso2)m2bxsqmhWjgPoRaeMVrYOwmnk7eT)TlGVyBMZlkeo(weWo)76nROPCUH5YaiHm2Pay0ogmYS0HKJ1NujeNpPIRqUisQOiTj9WRigqAfzGHWXoKcHBz2csr7dysXqaM0CjfpHatAAZK6xrmojTE9WKMnqMZcPvSnpKcHzdPII0Muj72SIydPvuGlPlmP1TauEslivCieojfcZKUdPizLiTXKIc9TjTXKkSyC465c5y)ZyhCjbXCaNyK6Scqy(gjJAX0OSt8c59CMXiFbqUiAXhXVNVzdK5e70slcyNUqWWfHvedUXadHJDkqcwTEKaiyCwWSh(kSIyWngyiCSJvRSdcfccSPGTBZkIn3f4Ex4BUauEsYX6tkcla4KuPqo8KIrBVN0vid0OEzNXoKkksBsLwiVNZmgzsfxHCrKCS)zSdUKGyoGtmsDwbimFJKrTyAu2zAZx4aGZloKdVfbStxiy4Y5gg4fGwGeSA1fcgUiSIyWngyiCStbsWQ1JeabJZcM9WxHvedUXadHJDSA9VR3SIMY5gMldGeYyNcGr7yWiZshA1ATSdcfccSPGxiVNZmg5laYfXQhLGyoGZcEH8EoZyKVaixel)D9Mv0uGeQXQv3fJRchY25fWODmyXIChsowFsrimtQyAJmtAm4WWKUWKEiegPWlG00Mjfoa4Kuimt6ciDhsrYkrAdNmG00Mjfoa4KuimxivYEbjP)a8HIK0aM0ZnmKYaiHm2H0)UEZkAinWKAPdXKUasrxatAlQrSqo2)m2bxsqmhWjgPoRaeMVrYOwmnk7ehdmK)k7Bt05cWx32iZ3f(cZG9hjIweWo)76nROPCUH5YaiHm2Pay0ogmYCAPdjhRpPieMjvYUnRi2qAff4s6ctADlaLNKur28q6SjPXq6H2WaVauliDbKgdPUCkI5H0dTHHuXS(K0FJtmPXq6H2WaVa0cP1dM06ficIEiDbKEm)bRFbgs9XWKgjPqcKkksBsXz)pGnK(31BwrdUqo2)m2bxsqmhWjgPoRaeMVrYOwmnk7eB3MveBUlW9UW3CbO8KweWo)76nROPiSIyWngyiCStbWODmyX60shw9VR3SIMY5gMldGeYyNcGr7yWI1PLoSAT)9KNEYYWFW6xGXQ1)EYtpz5aebrp1y1AT)9KNEYYjpPnIaRw)7jp9KLjKTZlCZ1uT2JCHGHlNByGxaAbsWQvbaFEL)MILLZnmx31N1y1Q7IXvHdz78cy0ogSyDIeoKCS(KIqyM00oWKUdPizLifEbKI2IhPizLexjh7Fg7GljiMd4eJuNvacZ3izulMgLD2GVDK8pX3yK5bkseV)fWKJ1N0kXWnKpjfU9E3(FaPWlGuiC76zsJKrXvoPieMjDhs)76nROH0yiDbggqQlIKMGyoGtsX(nlKJ9pJDWLeeZbCIrQZkaH5BKmk2Ia2PlemC5Cdd8cqlqcwT6cbdxewrm4gdmeo2Pajy16FxVzfnLZnmxgajKXofaJ2XGrMLo8LV89a]] )
    

end
