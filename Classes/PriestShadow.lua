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


    spec:RegisterPack( "Shadow", 20211123, [[di17zcqiPQ8iPsCjbaLnPc9jcqJsQuNsQIvraWRiGMfLWTiqu7sk)sazyQaogb1Yii9mbqtJGW1ur02eGY3eG04urGZjvuP1jvG5jG6Ec0(ur6Fsfv0bLkklKa1djqAIsf6IsfvTrve6JcamscaDsbiwjLOxQIGAMcq1njaANsv1pfaAOsL0rLkQWsfaKNsHPkvPRQc0wLkYxLkOXsGi7vv9xvzWOoSslwqpwLMmrxM0Mb1NPOrtPonvRwfb51QGMTq3gs7wXVLmCcDCcIwoWZHA6IUoiBhcFhIgpbcNxf16faunFkP9J8x4FVFd5M6VFHEaHkSWcl0aSj0amap5bcOFJ8SO(ne37HRP(nMfv)gg2RSq(ne3ZXAL)E)g4ccC1VHDMI4oiqbY0tBOW2Tqde2rHIB61CblCgiSJEd03ieYJzaz(HFd5M6VFHEaHkSWcl0aSj0amap5bcWVXcL2f4By4Oc63W2LsD(HFdPIVFdd7vwijURaxXjzz)fcfnubelCaAbXc9acvyYsYsb1Ehtf3bKLcYe3lsDpK4ovUK4ElaqNKyK26qCUatnj(wqtIjEbkXWf4QYgzPGmXDfOPosILvIjEbkXqIeJ0whIZfyQjM4fOeFJfwjolILN9X0cIXfXP9MepqhQyIxGsmo9yKyGEluuDKQS9nIooX)E)gxK3FV)(f(373qNnmQYVG)gqy9H02J67U40hZF)c)n2B618nW6c8X8nUPDIUa9BCpFJ6lxGPM4F)c)nUapvGVFJUjgXc8nmQnSUaFmFJBANOlqFxOSGHj(iX9rmIf4ByuBIvfFWf4DLyI7HyRwjUBILv2W2RSq(qwa5tC9PbuyGIT3WOs8rIXIAm(YfyQjUH6J8H1fq8PelmX98nKk(cCX0R5BCqSsSHUaFmjUF30orxGsSdt85cIyKEmsSTNeRtbzAtCUatnXeVJK4UwivaXbKbgc71q8osI7u5s4cGs8cuINkjgOR8SfexaIZIyGcduSnXgDyh0vIRH4ezrCbigTakX5cm1e3(5VFH(79BOZggv5xWFdiS(qA7r9DxC6J5VFH)g7n9A(gyDb(y(g30orxG(nUNVr9LlWut8VFH)gxGNkW3VrUrDYgwxGpMVXnTt0fOnD2WOkj(iXYkBy7vwiFilG8jU(0akmqX2Byuj(iXyrngF5cm1e3q9r(W6ci(uIf63qQ4lWftVMVHHDbsIfuhCH8KydDb(ysC)UPDIUaL4Bnsp9AiolIpuvrIn6WoORedjsSpe3zvN)N)(dWFVFdD2WOk)c(But887I8(ne(BS30R5BG6J8fgxC(nKk(cCX0R5But887I8sm6EOIjoTvI3B61qCnXZedH3WOsSec4JjXx7Dgn6JjX7ijEQK4ft8smqnHIlG49MEnTF(ZVHe18LaFout8V3F)c)79BOZggv5xWFJzr1VHCbhIw18K69W3tekbk(QZv)g7n9A(gYfCiAvZtQ3dFprOeO4Rox9N)(f6V3VHoByuLFb)nMfv)gyOjmwL8TOAAFgNFJ9MEnFdm0egRs(wunTpJZF(7pa)9(n0zdJQ8l4VXSO63WmEw0(vWVfJDupUPxZ3yVPxZ3WmEw0(vWVfJDupUPxZp)9le)E)g6SHrv(f83ywu9Bib6kHDG(qOySg)g7n9A(gsGUsyhOpekgRXF(ZVHuHxOy(793VW)E)g7n9A(gypQZv)g6SHrv(f8p)9l0FVFdD2WOk)c(BCbEQaF)gHqWWneLlHlaAdsKyRwjoecgUjwivWZhyiSxtds8BS30R5BiwPxZp)9hG)E)g6SHrv(f83Oe)gyn)g7n9A(giwGVHr9BGyJq63OBILv2W2RSq(qwa5tC9PL(9qFmj2QvIZfyQzlDu9L1t6kXboiXcbX9q8rI7MyzLnelQOd87llORDl97H(ysSvReNlWuZw6O6lRN0vIdCqIdye3Z3aXcEZIQFdzL4hK4p)9le)E)g6SHrv(f83Oe)gyn)g7n9A(giwGVHr9BGyJq63aXc8nmQnzL4hKiXhjUBILv2KkIcc4J5tmUMqAl97H(ysSvReNlWuZw6O6lRN0vIdCqIfcI75BGybVzr1VXgJpzL4hK4p)9FYFVFdD2WOk)c(BuIFdSMFJ9MEnFdelW3WO(nqSri9BGf1y8LlWutCd1h5dRlG4tjwOelqIdHGHBikxcxa0gK43qQ4lWftVMVHrUGKyiSpMeBOlWhtI73nTt0fOeVjXbOajoxGPMyIlaXcHaj2Hj(Cbr8cuI9H4ovUeUaOFdel4nlQ(nW6c8X8nUPDIUa9DHYcg(N)(dy)E)g6SHrv(f83Oe)gyn)g7n9A(giwGVHr9BGyJq634wvuwiNgIYLpfajMEnnirIpsC3e3hXaOrHlGP2WI2kqXp7fGwZ5MkKqUOOkj(iX9r8TqOZozB0lOIfqsSvReFRkklKttSqQGNpWqyVMgqrxFWeh4GeBELn0vqqSaaXbiXwTsCiemCtSqQGNpWqyVMgKiXwTsCyHXeFKyy30oFafD9btCGdsSqpjX98nKk(cCX0R5BiOvfLfYH4UwvK4oTaFdJQfeFqSkjolIfRksCOcxaL49MoIn9XKyeLlHlaAJybfca0jJNjgcRsIZI4BnjOIeJ0whIZI49MoInvIruUeUaOeJ0tBI95wO(ys8kL423aXcEZIQFdXQIp4c8Us8p)9hq)9(n0zdJQ8l4VXf4Pc89Becbd3quUeUaOniXVXEtVMVbSd0WyvYF(7)e879BOZggv5xWFJlWtf473iecgUHOCjCbqBqIFJ9MEnFJqfGvWH(y(ZF)DU)E)g6SHrv(f83yVPxZ3i6M2j(Dcbjnr1j)gsfFbUy618noiwjoG7M2PaIj2siPjQojXomXPTcuIxGsSqjUaeJwaL4CbMAITG4cq8kLyIxGocysmwCro(ysmCbigTakXP9oehqpjU9nUapvGVFdSOgJVCbMAIBr30oXVtiiPjQojXNgKyHsSvRe3nX9rmyD5trOt2wPe3ubHJtmXwTsmyD5trOt2wPe38H4tjoGEsI75N)(f(a)E)g6SHrv(f834c8ub((ncHGHBikxcxa0gK43yVPxZ3yNRItWgF3ng)5VFHf(373qNnmQYVG)g7n9A(g3ngF7n9AErhNFJOJZ3SO634I8(ZF)cl0FVFdD2WOk)c(BS30R5BaGM3EtVMx0X53i648nlQ(nqxF(5p)gIa9wOHB(793VW)E)g6SHrv(f834c8ub((nak66dM4atCaEGd8n2B618nelKk4HSaYhCbspHK6p)9l0FVFdD2WOk)c(BCbEQaF)g4ckg6JSjcHtOO(uaKy6100zdJQKyRwjgxqXqFKnevCtpQpCfrOt20zdJQ8BS30R5BahvS9fSW5p)9hG)E)g6SHrv(f834c8ub((n6J4qiy4g2ELfs4cG2Ge)g7n9A(gy7vwiHla6p)9le)E)g6SHrv(f834c8ub((n8bVJNNBsf2VEs8Pel8j)g7n9A(gl4UJ(Yca0j)5V)t(79BOZggv5xWFJzr1Vb2ELfsv(kq4RGFzbq1j)g7n9A(gy7vwiv5RaHVc(LfavN8N)(dy)E)g6SHrv(f83Oe)gyn)g7n9A(giwGVHr9BGyJq63qOFdel4nlQ(nq9r(W6cExOSGH)5V)a6V3VXEtVMVbIfv0b(9Lf01(BOZggv5xW)8NFJe4ZHAI)9(7x4FVFdD2WOk)c(Biv8f4IPxZ34GyL4Aiwq7iXDMrN1vIZIytnjUJvVeN(9qFmjEhjXQGq0bkXzrC0hLyirId1mvaXi90M4ovUeUaOFJzr1VHIkEgOB8va5SZv)gxGNkW3VXTQOSqoneLlFkasm9AAafD9btCGdsSWcLyRwj(wvuwiNgIYLpfajMEnnGIU(Gj(uIfAa9BS30R5BOOINb6gFfqo7C1F(7xO)E)g6SHrv(f83qQ4lWftVMVrVGZeNfXgNNlXbKohDKyKEAtChlOWOsSrU3dvjXcAhXe7WelwyShg1gXbWH4ynMkGyy30oXeJ0tBIrlGsCaPZrhjgcRyI3mvuXK4SigFEUeJ0tBI35mXxjXfG4tiiCsmewj2Z23ywu9B4d(cGYnmQpHeANec9jve(v)gxGNkW3VriemCdr5s4cG2Gej(iXHqWWnXcPcE(adH9AAqIeB1kXHfgt8rIHDt78bu01hmXboiXc9aeB1kXHqWWnXcPcE(adH9AAqIeFK4BvrzHCAikx(uaKy610ak66dMybsSWNK4tjg2nTZhqrxFWeB1kXHqWWneLlHlaAdsK4JeFRkklKttSqQGNpWqyVMgqrxFWelqIf(KeFkXWUPD(ak66dMyRwjUBIVvfLfYPjwivWZhyiSxtdOORpyIpniXcFaIps8TQOSqoneLlFkasm9AAafD9bt8Pbjw4dqCpeFKyy30oFafD9bt8Pbjw4o3d8n2B618n8bFbq5gg1NqcTtcH(Kkc)Q)83Fa(79BOZggv5xWFdPIVaxm9A(ggNNlXg2QMelaHW(LyKEAtCNkxcxa0VXSO63aDVBiqFyBvZhke2VFJlWtf4734wvuwiNgIYLpfajMEnnGIU(Gj(uIf(aFJ9MEnFd09UHa9HTvnFOqy)(ZF)cXV3VHoByuLFb)nMfv)g4ckg1m9X8bGcp)nUNVr9LlWut8VFH)g7n9A(g4ckg1m9X8bGcp)nUapvGVFJqiy4MyHubpFGHWEnnirITAL4(iwe4koBync)elKk45dme2RHyRwjwfsixuuLnS9klKQ8vGWxb)YcGQt(nKk(cCX0R5ByCEUehack8mXi90M4UwivaXbKbgc71qmeEnvligDpujgdbuIZIy84IkXPTsCSqQ4KybWUsCUatnBe3H26qmewLeJ0tBInSxzHuLehabHexWe3Bbq1jTG4tiiCsmewjUgIf0os8Ijgf6At8IjwSWypmQTF(7)K)E)g6SHrv(f83qQ4lWftVMVXbXkXcELMkX(GDPsCbtCNorIHlaXPTsmSdWjXqyL4cqCnelODK4fovaXPTsmSdWjXqyTrSHDbsIVo4c5jXomXikxsScGetVgIVvfLfYHyhtSWhatCbigTakXlY9C7BmlQ(nW(adfFMXv6Bwa8lCLM6RGFWkOUEE(BCbEQaF)g3QIYc50quU8PaiX0RPbu01hmXNgKyHpW3yVPxZ3a7dmu8zgxPVzbWVWvAQVc(bRG6655F(7pG979BOZggv5xWFdPIVaxm9A(gheReByVYcPkjoaccjUGjU3cGQtsmsBDiEQKyFiUtLlHlaQfexaI9H4qnrQ6qCNkxsSGRys8DXjMyFiUtLlHlaAJ4odt8j8zGVdXfG4(1lOIfqsC0hLypjgsKyKEAtmo37HQK4BvrzHCWTVXSO63aBVYcPkFfi8vWVSaO6KFJlWtf4734wvuwiNMyHubpFGHWEnnGIU(GjoWbjw4dq8rIVvfLfYPHOC5tbqIPxtdOORpyIdCqIf(aeFK4Uj(wi0zNSn6fuXcij2QvIVfcD2jBhEg47qCpeB1kXDt8TqOZozdHoP9zaXwTs8TqOZozBCt78bVkX9q8rI7M4(ioecgUHOCjCbqBqIeB1kXIafXZ8kBc3quU8fwXK4Ei2QvIdlmM4Jed7M25dOORpyIdCqIfId8n2B618nW2RSqQYxbcFf8llaQo5p)9hq)9(n0zdJQ8l4VHuXxGlMEnFJdIvIJoojUGjUgbziSsSCrxtL4e4ZHAIjUM4zIDyIfaHgtf4JjXDQCjXDudHGHj2XeV30rOwqCbi(Cbr8cuINkjo3OoPkj2NSi2Z23yVPxZ34UX4BVPxZl648BGtGFZF)c)nUapvGVFJUjUpIZnQt2SHgtf4J5dr5YMoByuLeB1kXsnecgUzdnMkWhZhIYLnirI7H4Je3nXHqWWneLlHlaAdsKyRwj(wvuwiNgIYLpfajMEnnGIU(Gj(uIf(ae3Z3i648nlQ(nKOMVe4ZHAI)5V)tWV3VHoByuLFb)n2B618nGW6Ztff)nKk(cCX0R5B0rfEHIjXWBmgU3djgUaedH3WOsSNkkUdi(GyL4Ai(wvuwihI9H4civaXHNjob(COMeJJv2(gxGNkW3VriemCdr5s4cG2Gej2QvIdHGHBIfsf88bgc710Gej2QvIVvfLfYPHOC5tbqIPxtdOORpyIpLyHpWp)534kX)E)9l8V3VHoByuLFb)n2B618nelKk45dme2R5Biv8f4IPxZ34GyL4UwivaXbKbgc71qmspTjUtLlHlaAJybWkkjgUae3PYLWfaL4BHQyIlyyIVvfLfYHyFioTvIhvqKel8bigR3AKyIR0wbiDSsmewjUgIVsIHMOIXeN2kXIX9Sci2XelUGK4cM40wj(WZaFhIVfcD2jTG4cqSdtCARaLyKEms8ujXHkX7uPTciUtLljUZdGetVgItBhtmSBANnI7SmvuXK4SigFEUeN2kXXfNelwivaX(adH9AiUGjoTvIHDt7K4Sigr5sIvaKy61qmCbiEQH4t4ZaFhC7BCbEQaF)gIaxXzdRr4NyHubpFGHWEneFK4UjoecgUHOCjCbqBqIeB1kX9r8TqOZoz7WZaFhIpsCFeFle6St2g9cQybKeFK4BvrzHCAikx(uaKy610ak66dM4tdsSWhGyRwjg2nTZhqrxFWehyIVvfLfYPHOC5tbqIPxtdOORpyI7H4Je3nXWUPD(ak66dM4tds8TQOSqoneLlFkasm9AAafD9btSajw4ts8rIVvfLfYPHOC5tbqIPxtdOORpyIdCqInVsIfaiwii2QvIHDt78bu01hmXNs8TQOSqonXcPcE(adH9AAsiWMEneB1kXHfgt8rIHDt78bu01hmXbM4BvrzHCAikx(uaKy610ak66dMybsSWNKyRwj(wi0zNSD4zGVdXwTsCiemClmwLmcHZgKiX98ZF)c9373qNnmQYVG)gsfFbUy618noiwjwWR0uj2hSlvIlyI70jsmCbioTvIHDaojgcRexaIRHybTJeVWPcioTvIHDaojgcRnI7qpTjUF30oj(exLy7kkjgUae3PtS9nMfv)gyFGHIpZ4k9nla(fUst9vWpyfuxpp)nUapvGVFJqiy4gIYLWfaTbjsSvReNoQs8Pel8bi(iXDtCFeFle6St2g30oFWRsCpFJ9MEnFdSpWqXNzCL(Mfa)cxPP(k4hScQRNN)5V)a8373qNnmQYVG)g7n9A(gWR(mHwG03b)nKk(cCX0R5BCqSs8jUkXbaqlq67GjUgIf0osCbLyxQexWe3PYLWfaTr8bXkXN4QehaaTaPVJetSpe3PYLWfaLyhM4ZfeX2lcLy1tBfqCaaOqOehqgeUzb20RH4cq8j6AusCbtSGJfgxO4gXD46jXWfGyzLyIZI4qLyirIdv4cOeV30rSPpMeFIRsCaa0cK(oyIZIy0vq4OowjoTvIdHGHBFJlWtf473OpIdHGHBikxcxa0gKiXhjUBI7J4BvrzHCAikx(Yca0jBqIeB1kX9rCUrDYgIYLVSaaDYMoByuLe3dXhjUBIrSaFdJAtwj(bjs8rIXIAm(YfyQjUHyrfDGFFzbDTjoiXctSvReV30rOpzLnelQOd87llORnXbjglQX4lxGPM4gIfv0b(9Lf01M4JeJf1y8LlWutCdXIk6a)(Yc6At8PelmX9qSvRehcbd3quUeUaOnirIpsC3eJlOyOpYMjOqOpFq4MfytVMMoByuLeB1kX4ckg6JSb7Au(k4xySW4cf30zdJQK4E(5VFH4373qNnmQYVG)g7n9A(gO(inxuf)nUNVr9LlWut8VFH)gxGNkW3VHp4D88mXbM4o3dq8rI7M4UjgXc8nmQTngFYkXpirIpsC3e3hX3QIYc50quU8PaiX0RPbjsSvRe3hX5g1jB2qJPc8X8HOCztNnmQsI7H4Ei2QvIdHGHBikxcxa0gKiX9q8rI7M4(io3OozZgAmvGpMpeLlB6SHrvsSvRel1qiy4Mn0yQaFmFikx2ak66dM4tj(U48LoQsSvRe3hXHqWWneLlHlaAdsK4Ei(iXDtCFeNBuNSH1f4J5BCt7eDbAtNnmQsITALySOgJVCbMAIBO(iFyDbehyIpjX98nKk(cCX0R5BCqSsSa0hP5IQyIrARdXBmsCasChREXeVaLyirliUaeFUGiEbkX(qCNkxcxa0gXD(bdbuIfaHgtf4JjXDQCjXi9yKyC6XiXHkXqIeJ0whItBL47ItIthvjg2hhBR4gXgzjsme2htI3K4tkqIZfyQjMyKEAtSHUaFmjUF30orxG2(5V)t(79BOZggv5xWFJ9MEnFdOXUINFtHy)gsfFbUy618noiwj(GJDfptC)fIL4Aiwq7OfeBxrPpMehcCfoEM4Sig56jXWfGyXcPci2hyiSxdXfG4vkjglUihC7BCbEQaF)g9rCUrDYMn0yQaFmFikx20zdJQK4JeJyb(gg1MSs8dsKyRwjwQHqWWnBOXub(y(quUSbjs8rIdHGHBikxcxa0gKiXwTsC3eFRkklKtdr5YNcGetVMgqrxFWeFkXcFaITAL4(igXc8nmQnXQIp4c8UsmX9q8rI7J4qiy4gIYLWfaTbj(ZF)bSFVFdD2WOk)c(BS30R5Bew18k4xARVfF1rQYVHuXxGlMEnFJdIvIRHybTJehcLelc8c4PJvIHW(ysCNkxsCNhajMEned7aCAbXomXqyvsSpyxQexWe3PtK4Ai2OxIHWkXlCQaIxIruUmSIjXWfG4BvrzHCiwHH9RRZ9mX7ijgUaeBdnMkWhtIruUKyiX0rvIDyIZnQtQY234c8ub((n6J4qiy4gIYLWfaTbjs8rI7J4BvrzHCAikx(uaKy610Gej(iXyrngF5cm1e3q9r(W6ci(uIfM4Je3hX5g1jByDb(y(g30orxG20zdJQKyRwjUBIdHGHBikxcxa0gKiXhjglQX4lxGPM4gQpYhwxaXbMyHs8rI7J4CJ6KnSUaFmFJBANOlqB6SHrvs8rI7MyrGI4zELnHBikx(cRys8rI7M4(iwfsixuuLnfv8mq34RaYzNRsSvRe3hX5g1jB2qJPc8X8HOCztNnmQsI7HyRwjwfsixuuLnfv8mq34RaYzNRs8rIVvfLfYPPOINb6gFfqo7C1gqrxFWeh4GelCatOeFKyPgcbd3SHgtf4J5dr5YgKiX9qCpeB1kXDtCiemCdr5s4cG2Gej(iX5g1jByDb(y(g30orxG20zdJQK4E(5V)a6V3VHoByuLFb)n2B618nUBm(2B618Ioo)grhNVzr1Vrc85qnX)83)j4373qNnmQYVG)gxGNkW3VHTUX0UjEtIdCqIdON8BS30R5BivSOc2uFIG9Sc(5p)gHvn)E)9l8V3VHoByuLFb)nUapvGVFdSOgJVCbMAIBO(iFyDbeh4GehGFJ9MEnFJfF1rQYxyCX5p)9l0FVFdD2WOk)c(BS30R5BS4Rosv(McX(nKk(cCX0R5BeaN4zIHWkXDg(QJuLe3FHyjgPToepvsCUrDsvsSpzrSHUaFmjUF30orxGsCnelubsCUatnXTVXf4Pc89BGf1y8LlWutCBXxDKQ8nfIL4tjwyIpsmwuJXxUatnXnuFKpSUaIpLyHj(iX9rCUrDYgwxGpMVXnTt0fOnD2WOk)5p)gORp)E)9l8V3VHoByuLFb)nUapvGVFJqiy4wyvZRGFPT(w8vhPkBqIFdCc8B(7x4VXEtVMVXDJX3EtVMx0X53i648nlQ(ncRA(5VFH(79BOZggv5xWFJlWtf473OpIZfyQzZXpX4EwbFJ9MEnFdPJf14dDn97p)9hG)E)g6SHrv(f83yVPxZ3ar5YNcGetVMVHuXxGlMEnFJdIvI7u5sI78aiX0RH4Ai(wvuwihIfRk6JjXBsCuxCsSqCaI9bVJNNjoekjEQKyhM4ZfeXi9yK4cHcURiX(G3XZZe7dXD6eBela3dvIXqaLyS9klKWUoYaH6JmuhPciEhjXcqFKel44ItIDmX1q8TQOSqoehQWfqjUtDEIDyI7DJHRCbyIlaXg2RSqchxuLyhtSkKqUOOkBehqmNcOelwv0htIbkob(n9AWe7WedH9XKyd7vwiHJlQsCxbogL4DKelyDKkGyhtCbLTVXf4Pc89BGyb(gg1MyvXhCbExjM4Je3nX(G3XZZeFAqIfIdqSvRelQzd21r22B6iuIpsmaAu4cyQnS9klKWXfvFIahJ2uHeYffvjXhjUpIVvfLfYPH6J8fgxC2Gej(iX9r8TQOSqonS9klKpKfq(K6M2nirI7H4Je3nX(G3XZZeh4GeFcojXwTsCUrDYgwxGpMVXnTt0fOnD2WOkj(iXiwGVHrTH1f4J5BCt7eDb67cLfmmX9q8rI7J4BvrzHCAWUoYgKiXhjUBI7J4BvrzHCAO(iFHXfNnirITALySOgJVCbMAIBO(iFyDbeFkXcLyRwjUpIbqJcxatTHTxzHeoUO6te4y0MkKqUOOkj(iX9rmaAu4cyQTCJHRCb4hobBUMkAtfsixuuLe3dXhjUBI7JyCbfd9r2quXn9O(WveHoztNnmQsITAL4qiy4gIkUPh1hUIi0jBqIeB1kXyntFmXn3CkG(WveHojX98ZF)cXV3VHoByuLFb)n2B618nW2RSq(qwa5tC95Biv8f4IPxZ3qaUhQeJHakXNliIfHsIHej2Od7GUsCNz0zDL4AioTvIZfyQjXomXDiytByOiXN4Qaxj2XJaMeV30rOeJ0whIHDt70htIfwqoajoxGPM4234c8ub((ncHGHBWR(mHwG03b3Gej(iX9rSudHGHBibBAddfFWRcCTbjs8rIXIAm(YfyQjUH6J8H1fqCGjwi(5V)t(79BOZggv5xWFJ9MEnFJ7gJV9MEnVOJZVr0X5Bwu9BCL4F(7pG979BOZggv5xWFJ9MEnFduFKpSUGVX98nQVCbMAI)9l834c8ub((nYnQt2W6c8X8nUPDIUaTPZggvjXhjglQX4lxGPM4gQpYhwxaXNsmIf4ByuBO(iFyDbVluwWWeFK4(iwwzdBVYc5dzbKpX1Nw63d9XK4Je3hX3QIYc50GDDKniXVHuXxGlMEnFdbq30M4Uc8c45zIfG(ij2qxaX7n9AiolIbkmqX2e3XQxmXi90MySUaFmFJBANOlq)5V)a6V3VHoByuLFb)n2B618nKl6SPxZ34E(g1xUatnX)(f(BCbEQaF)g9rmIf4ByuBBm(KvIFqIFdPIVaxm9A(gDfOWkG4SigcRe3XfD20RH4oZOZ6kXomX7CM4ow9sSJjEQKyiX2p)9Fc(9(n0zdJQ8l4VXEtVMVb2ELfYhYciFsDt7VHuXxGlMEnFJdIvInSxzHK4oSasI7OUPnXomXqyFmj2WELfs44IQe3vGJrjEhjXH6ivaXi9yKyvqi6aLyjeWhtItBL4rfejXMxz7BCbEQaF)gIA2GDDKT9MocL4JedGgfUaMAdBVYcjCCr1NiWXOnviHCrrvs8rIf1Sb76iBafD9btCGdsS5v(ZF)DU)E)g6SHrv(f83yVPxZ3a1h5lmU48Biv8f4IPxZ3OZIi3ZyIHWkXO(idJloXe7WeFxrrvs8osITHgtf4JjXikxsSJjgsK4DKedH9XKyd7vwiHJlQsCxbogL4DKehQJube7yIHeBetCNjLE61SX4zli(U4KyuFKHXfNe7WeFUGigzbfLehQednByujolIn1K40wjg4WjXHNjg56PpMeVeBELTVXf4Pc89B0nX3QIYc50q9r(cJloBx7fyQyIpLyHj(iXDtSudHGHB2qJPc8X8HOCzdsKyRwjUpIZnQt2SHgtf4J5dr5YMoByuLe3dXwTsSOMnyxhzdOORpyIdCqIVloFPJQelqInVsI7H4JelQzd21r22B6iuIpsmaAu4cyQnS9klKWXfvFIahJ2uHeYffvjXhjwuZgSRJSbu01hmXNs8DX5lDu9N)(f(a)E)g6SHrv(f83yVPxZ3ar5YxyfZVHuXxGlMEnFJdIvI7u5sIfCftI3KyB30wbelc8c45zIr6PnXcGqJPc8XK4ovUKyirIZIyHG4CbMAITG4cqCL2kG4CJ6KyIRHyJEBFJlWtf473Wh8oEEM4ahK4tWjj(iX5g1jB2qJPc8X8HOCztNnmQsIpsCUrDYgwxGpMVXnTt0fOnD2WOkj(iXyrngF5cm1e3q9r(W6cioWbjoGrSvRe3nXDtCUrDYMn0yQaFmFikx20zdJQK4Je3hX5g1jByDb(y(g30orxG20zdJQK4Ei2QvIXIAm(YfyQjUH6J8H1fqCqIfM4E(5VFHf(373qNnmQYVG)g7n9A(gsfrbb8X8jgxti9Biv8f4IPxZ3OJ1iGjXqyL4oQikiGpMe314AcPe7WeFUGi(UdXMAsSpzrCNkxcxauI9bN6kTG4cqSdtSHUaFmjUF30orxGsSJjo3OoPkjEhjXi9yKyBpjwNcY0M4CbMAIBFJlWtf473OBIbkmqX2Byuj2QvI9bVJNNj(uIdONKyRwj(wvuwiNgIYLVSaaDYgqrxFWeh4GehGelaqS5vsCpeFK4UjUpIrSaFdJAtSQ4dUaVRetSvRe7dEhppt8Pbj(eCsI7H4Je3nX9rCUrDYgwxGpMVXnTt0fOnD2WOkj2QvI7M4CJ6KnSUaFmFJBANOlqB6SHrvs8rI7JyelW3WO2W6c8X8nUPDIUa9DHYcgM4EiUNF(7xyH(79BOZggv5xWFJ9MEnFdeLlFHvm)gsfFbUy618noiwjUtcM4Aiwq7iXomXNliIL1iGjXJQsIZI47ItI7OIOGa(ysCxJRjKAbX7ijoTvGs8cuIJkgtCAVdXcbX5cm1etCbLe39jjgPN2eFRrc5zpTVXf4Pc89BGf1y8LlWutCd1h5dRlG4atC3eleelqIV1iH8SjDmUMDYNETlf30zdJQK4Ei(iX(G3XZZeh4GeFcojXhjo3OozdRlWhZ34M2j6c0MoByuLeB1kX9rCUrDYgwxGpMVXnTt0fOnD2WOk)5VFHdWFVFdD2WOk)c(BS30R5BGTxzH8HSaYNu30(BCpFJ6lxGPM4F)c)nUapvGVFJUjoxGPMnBDJPDt8MehyIf6bi(iXyrngF5cm1e3q9r(W6cioWelee3dXwTsC3elQzd21r22B6iuIpsmaAu4cyQnS9klKWXfvFIahJ2uHeYffvjX98nKk(cCX0R5BCqSsSH9klKe3Hfq2be3rDtBIDyItBL4CbMAsSJjEdlOK4Siw6kXfG4ZfeX2lcLyd7vwiHJlQsCxbogLyviHCrrvsmspTjwa6JmuhPciUaeByVYcjSRJK49MocT9ZF)cle)E)g6SHrv(f83yVPxZ3adba6ivWlRh6khfJ)g3Z3O(YfyQj(3VWFJlWtf473ixGPMT0r1xwpPRehyIf6jj(iXHqWWneLlHlaAtwiNVHuXxGlMEnFJdIvInGaaDKkG4SiwaUYrXyIRH4L4CbMAsCAVjXoMyZYhtIZIyPReVjXPTsmWnTtIthvB)83VWN8373qNnmQYVG)g7n9A(gikx(Yca0j)g3Z3O(YfyQj(3VWFJlWtf473aXc8nmQnzL4hKiXhjUBIdHGHBikxcxa0MSqoeB1kXHqWWneLlHlaAdOORpyIdmX3QIYc50quU8fwXSbu01hmXwTsSiqr8mVYMWneLlFHvmj(iX9rCiemClmwLmcHZgq3Bs8rIXIAm(YfyQjUH6J8H1fqCGjoajUhIps8EthH(Kv2qSOIoWVVSGU2eFAqIVNVr9PJI6kM4JeJf1y8LlWutCd1h5dRlG4atC3eFsIfiXDtCaJybaIZnQt2sKooFf8dEtTPZggvjX9qCpFdPIVaxm9A(gheRe3PYLe3Bba6Kext8mXomXgDyh0vI3rsCN6L4fOeV30rOeVJK40wjoxGPMeJSgbmjw6kXsiGpMeN2kXx7Dgn2(5VFHdy)E)g6SHrv(f834c8ub((nKv2qSOIoWVVSGU2T0Vh6JjXhjUBIZnQt2W6c8X8nUPDIUaTPZggvjXhjglQX4lxGPM4gQpYhwxaXNsmIf4ByuBO(iFyDbVluwWWeB1kXYkBy7vwiFilG8jU(0s)EOpMe3dXhjUBI7Jya0OWfWuBy7vwiHJlQ(ebogTPcjKlkQsITAL49Moc9jRSHyrfDGFFzbDTj(0GeFpFJ6thf1vmX98n2B618nq9rgQJub)83VWb0FVFdD2WOk)c(BS30R5BGTxzH8HSaYNu30(Biv8f4IPxZ34GyLyJoSd6iXi90M4UU(ec09qfqCxXBeLyOjQymXPTsCUatnjgPhJehQehQXcjXc9abGrCOcxaL40wj(wvuwihIVfQIjoCVh2(gxGNkW3VbaAu4cyQnX1NqGUhQGNiEJOnviHCrrvs8rIrSaFdJAtwj(bjs8rIZfyQzlDu9L1t8MpHEaIpL4Uj(wvuwiNg2ELfYhYciFsDt7MecSPxdXcKyZRK4E(5VFHpb)E)g6SHrv(f83yVPxZ3aBVYc57cwS93qQ4lWftVMVXbXkXg2RSqsSGcwSnX1qSG2rIHMOIXeN2kqjEbkXRuIj2NBH6Jz7BCbEQaF)gG1LpfHozBLsCZhIpLyHpWp)9lCN7V3VHoByuLFb)n2B618nq9r(W6c(g3Z3O(YfyQj(3VWFdFsfaGeZNd)ns)Ei(0GcX3WNubaiX85OOQ03u)gc)nUapvGVFdSOgJVCbMAIBO(iFyDbeFkXiwGVHrTH6J8H1f8Uqzbdt8rIdHGHBYfC4lTlit7Sbj(nU2RpFdH)5VFHEGFVFdD2WOk)c(Biv8f4IPxZ34GyLybOpsIpX4EM4Si(wdgcvjUJl4qI71UGmTtmXIG6IjUgIn6L4ckXUujUGjUtNyJ4EdGDmasSGwdSdqj2HjoTDmXoM4LyB30wbelc8c45zIt7DigOYktFmjgAIkgtSCbhsCAxqM2jMyht8gwqjXzrC6OkXfu(nUapvGVFJqiy4MCbh(s7cY0oBqIeFKyelW3WO2KvIFqIeFK4(ioecgUHOCjCbqBqIFdFsfaGeZNd)ns)Ei(0GcXX(cHGHBYfC4lTlit7Sbj(n8jvaasmFokQk9n1VHWFJR96Z3q4VXEtVMVbQpYhCCp)ZF)cv4FVFdD2WOk)c(BS30R5BG6J8fgxC(nKk(cCX0R5BCqSsSa0hjXcoU4KyhM4ZfeXYAeWK4rvjXzrmqHbk2M4ow9IBeBKLiX3fN(ys8MeleexaIrlGsCUatnXeJ0tBIn0f4JjX97M2j6cuIZnQtQsI3rs85cI4fOepvsme2htInSxzHeoUOkXDf4yuIlaXDfF(A7xId4(CydlQX4lxGPM4gQpYhwxWPDopjXMAIjoTvIr9XrHqjUGj(KeVJK40wjEGqdvaXfmX5cm1e3iUZI4YcILfXtLelcumMyuFKHXfNednPhjEJrIZfyQjM4fOelRmvjXi90M4o1lXiT1HyiSpMeJTxzHeoUOkXIahJsSdtCOosfqSJjErSECdJA7BCbEQaF)giwGVHrTjRe)Gej(iXG1LpfHozdTqOO6KnFi(uIVloFPJQelqIpq7KeFKySOgJVCbMAIBO(iFyDbehyI7MyHGybsSqjwaG4CJ6KnuhRGZnD2WOkjwGeV30rOpzLnelQOd87llORnXcaeNBuNSjIpFT97l6ZHnD2WOkjwGe3nXyrngF5cm1e3q9r(W6ci(0oNeFsI7HybaI7MyrnBWUoY2EthHs8rIbqJcxatTHTxzHeoUO6te4y0MkKqUOOkjUhI7H4Je3nX9rmaAu4cyQnS9klKWXfvFIahJ2uHeYffvjXwTsCFeFRkklKtd21r2Gej(iXaOrHlGP2W2RSqchxu9jcCmAtfsixuuLeB1kX7nDe6twzdXIk6a)(Yc6At8Pbj(E(g1NokQRyI75N)(fQq)9(n0zdJQ8l4VXEtVMVbIfv0b(9Lf01(BCbEQaF)gafgOy7nmQeFK4CbMA2shvFz9KUs8PehWi2QvI7M4CJ6KnuhRGZnD2WOkj(iXYkBy7vwiFilG8jU(0akmqX2ByujUhITAL4qiy4g0adbI(y(Kl4WrX4gK434E(g1xUatnX)(f(N)(fAa(79BOZggv5xWFJ9MEnFdS9klKpKfq(exF(gsfFbUy618nme1RVrIV1i90RH4SigNLiX3fN(ysSrh2bDL4AiUGHfKZfyQjMyK26qmSBAN(ysCasCbigTakX4CVhQsIrRqmX7ijgc7JjXDfF(A7xId4(CiX7ijU)ayVelaDSco3(gxGNkW3VbqHbk2EdJkXhjoxGPMT0r1xwpPReFkXcbXhjUpIZnQt2qDSco30zdJQK4JeNBuNSjIpFT97l6ZHnD2WOkj(iXyrngF5cm1e3q9r(W6ci(uIf6p)9luH4373qNnmQYVG)g7n9A(gy7vwiFilG8jU(8nUNVr9LlWut8VFH)gxGNkW3VbqHbk2EdJkXhjoxGPMT0r1xwpPReFkXcbXhjUpIZnQt2qDSco30zdJQK4Je3hXDtCUrDYgwxGpMVXnTt0fOnD2WOkj(iXyrngF5cm1e3q9r(W6ci(uIrSaFdJAd1h5dRl4DHYcgM4Ei(iXDtCFeNBuNSjIpFT97l6ZHnD2WOkj2QvI7M4CJ6Knr85RTFFrFoSPZggvjXhjglQX4lxGPM4gQpYhwxaXboiXcL4EiUNVHuXxGlMEnFJtyvfj2Od7GUsmKiX1q8IjgDNZeNlWutmXlMyXcJ9WOAbXQG4QIjXiT1Hyy30o9XK4aK4cqmAbuIX5EpuLeJwHyIr6PnXDfF(A7xId4(Cy7N)(f6j)9(n0zdJQ8l4VXEtVMVbQpYhwxW34E(g1xUatnX)(f(B4tQaaKy(C4Vr63dXNguOFdFsfaGeZNJIQsFt9Bi834c8ub((nWIAm(YfyQjUH6J8H1fq8PeJyb(gg1gQpYhwxW7cLfmmXhjUBI7JyCbfd9r2quXn9O(WveHoztNnmQsITAL4(i(wvuwiNgCuX2xWcNnirI75BCTxF(gc)ZF)cnG979BOZggv5xWFJ9MEnFduFKp44E(B4tQaaKy(C4Vr63dXNguOh7UVqiy4MCbh(s7cY0oBqIwTERkklKtdr5YxyfZgKypFdFsfaGeZNJIQsFt9Bi834AV(8ne(BCbEQaF)g9rmUGIH(iBiQ4MEuF4kIqNSPZggvjXwTsCFeFRkklKtdoQy7lyHZgK4p)9l0a6V3VHoByuLFb)n2B618nGJk2(cw48B4tQaaKy(C4Vr63dXNgu4VHpPcaqI5ZrrvPVP(ne(BCbEQaF)g4ckg6JSHOIB6r9HRicDYMoByuLeFK4(ioecgUHOCjCbqBqIeFK4(ioecgUjwivWZhyiSxtds8Biv8f4IPxZ34GyL4tmQy7lyHtIlOe7sL4cMy01hIVvfLfYbtCweJU(KRpe3PkUPhvInQicDsIdHGHB)83Vqpb)E)g6SHrv(f83qQ4lWftVMVXbXkXgDyh0rIxmXXfNeduCbsIDyIRH40wjgTqOFJ9MEnFdS9klKpKfq(K6M2)83Vq7C)9(n0zdJQ8l4VHuXxGlMEnFJdIvIn6WoOReVyIJlojgO4cKe7WexdXPTsmAHqjEhjXgDyh0rIDmX1qSG2XVXEtVMVb2ELfYhYciFIRp)8N)8BGqbyVMF)c9acvyHf(aN8BGCbJpM4Vrh2zbG6pG0FaqhqmX9ARe7OIfijgUaelGIa9wOHBkGeduHeYbQKyCHQeVqzHUPkj(AVJPIBKLbCFuIfAhqSGwdcfKQKybexqXqFKnbjbK4SiwaXfum0hztqQPZggvPasC3cli6PrwgW9rjwODaXcAniuqQsIfqCbfd9r2eKeqIZIybexqXqFKnbPMoByuLciXBsCNpagWjUBHfe90iljl7Wolau)bK(da6aIjUxBLyhvSajXWfGybeD9rajgOcjKdujX4cvjEHYcDtvs81Ehtf3ild4(OehGDaXcAniuqQsIfqCbfd9r2eKeqIZIybexqXqFKnbPMoByuLciXDlSGONgzza3hLyHEYoGybTgekivjXciUGIH(iBcsciXzrSaIlOyOpYMGutNnmQsbK4Ufwq0tJSmG7JsSqdyDaXcAniuqQsIfqCbfd9r2eKeqIZIybexqXqFKnbPMoByuLciXDlSGONgzza3hLyHgq7aIf0AqOGuLelG4ckg6JSjijGeNfXciUGIH(iBcsnD2WOkfqI7wybrpnYsYYoSZca1FaP)aGoGyI71wj2rflqsmCbiwaVsSasmqfsihOsIXfQs8cLf6MQK4R9oMkUrwgW9rjoG1belO1GqbPkjwatGphQzBdVTBvrzHCeqIZIyb8wvuwiN2gEfqI7wybrpnYsYYacQybsvs8jG49MEnehDCIBKLFdrqb7r9B0LUqSH9klKe3vGR4KSSlDH4(lekAOciw4a0cIf6beQWKLKLDPlelO27yQ4oGSSlDHybzI7fPUhsCNkxsCVfaOtsmsBDioxGPMeFlOjXeVaLy4cCvzJSSlDHybzI7kqtDKelRet8cuIHejgPToeNlWutmXlqj(glSsCwelp7JPfeJlIt7njEGouXeVaLyC6XiXa9wOO6ivzJSKSSlDH4oVGqVqPkjouHlGs8Tqd3K4q10hCJ4o7EvXet8uJGS9cqHHIeV30RbtCnXZnYY9MEn4MiqVfA4McmyGelKk4HSaYhCbspHKQfoCqGIU(GdCaEGdqwU30Rb3eb6Tqd3uGbdeCuX2xWcNw4WbXfum0hztecNqr9PaiX0RXQvCbfd9r2quXn9O(WveHojz5EtVgCteO3cnCtbgmqy7vwiHlaQfoCW(cHGHBy7vwiHlaAdsKSCVPxdUjc0BHgUPadgOfC3rFzba6Kw4Wb9bVJNNBsf2VEEQWNKSCVPxdUjc0BHgUPadgiiS(8urTywuni2ELfsv(kq4RGFzbq1jjl3B61GBIa9wOHBkWGbcXc8nmQwmlQge1h5dRl4DHYcg2IsmiwtlqSrinOqjl3B61GBIa9wOHBkWGbcXIk6a)(Yc6Atwsw2LUqCxR0RbtwU30Rbhe7rDUkz5EtVgCqXk9ASWHdgcbd3quUeUaOnirRwdHGHBIfsf88bgc710Gejl3B61GfyWaHyb(ggvlMfvdkRe)GeTOedI10ceBesd2TSYg2ELfYhYciFIRpT0Vh6JPvR5cm1SLoQ(Y6jDnWbfIEo2TSYgIfv0b(9Lf01UL(9qFmTAnxGPMT0r1xwpPRboyaRhYY9MEnybgmqiwGVHr1Izr1GBm(KvIFqIwuIbXAAbIncPbrSaFdJAtwj(bjESBzLnPIOGa(y(eJRjK2s)EOpMwTMlWuZw6O6lRN01ahui6HSSleBKlijgc7JjXg6c8XK4(Dt7eDbkXBsCakqIZfyQjM4cqSqiqIDyIpxqeVaLyFiUtLlHlakz5EtVgSadgielW3WOAXSOAqSUaFmFJBANOlqFxOSGHTOedI10ceBesdIf1y8LlWutCd1h5dRl4uHkWqiy4gIYLWfaTbjsw2fIf0QIYc5qCxRksCNwGVHr1cIpiwLeNfXIvfjouHlGs8EthXM(ysmIYLWfaTrSGcba6KXZedHvjXzr8TMeurIrARdXzr8EthXMkXikxcxauIr6PnX(CluFmjELsCJSCVPxdwGbdeIf4ByuTywunOyvXhCbExj2IsmiwtlqSrin4TQOSqoneLlFkasm9AAqIh7Upa0OWfWuByrBfO4N9cqR5CtfsixuuLh77wi0zNSn6fuXciTA9wvuwiNMyHubpFGHWEnnGIU(GdCqZRSHUccbGa0Q1qiy4MyHubpFGHWEnnirRwdlm(iSBANpGIU(GdCqHEYEil3B61GfyWab7anmwL0choyiemCdr5s4cG2Gejl3B61GfyWafQaSco0htlC4GHqWWneLlHlaAdsKSSleFqSsCa3nTtbetSLqstuDsIDyItBfOeVaLyHsCbigTakX5cm1eBbXfG4vkXeVaDeWKyS4IC8XKy4cqmAbuIt7DioGEsCJSCVPxdwGbdu0nTt87ecsAIQtAHdhelQX4lxGPM4w0nTt87ecsAIQtEAqHA1A39bwx(ue6KTvkXnvq44eB1kyD5trOt2wPe3850a6j7HSCVPxdwGbd0oxfNGn(UBmAHdhmecgUHOCjCbqBqIKL7n9AWcmyGUBm(2B618IooTywun4f5LSCVPxdwGbdeaAE7n9AErhNwmlQgeD9HSKSSlDH4oRRbCIZIyiSsmsBDiwWvnexWeN2kXDg(QJuLe7yI3B6iuYY9MEn4wyvtWfF1rQYxyCXPfoCqSOgJVCbMAIBO(iFyDbboyasw2fIdGt8mXqyL4odF1rQsI7VqSeJ0whINkjo3OoPkj2NSi2qxGpMe3VBANOlqjUgIfQajoxGPM4gz5EtVgClSQrGbd0IV6iv5BkeRfoCqSOgJVCbMAIBl(QJuLVPqSNk8rSOgJVCbMAIBO(iFyDbNk8X(YnQt2W6c8X8nUPDIUaTPZggvjzjzzx6cXcAhXKLDH4dIvI7AHubehqgyiSxdXi90M4ovUeUaOnIfaROKy4cqCNkxcxauIVfQIjUGHj(wvuwihI9H40wjEubrsSWhGySERrIjUsBfG0XkXqyL4Ai(kjgAIkgtCARelg3ZkGyhtS4csIlyItBL4dpd8Di(wi0zN0cIlaXomXPTcuIr6XiXtLehQeVtL2kG4ovUK4opasm9AioTDmXWUPD2iUZYurftIZIy855sCARehxCsSyHube7dme2RH4cM40wjg2nTtIZIyeLljwbqIPxdXWfG4PgIpHpd8DWnYY9MEn42vIdkwivWZhyiSxJfoCqrGR4SH1i8tSqQGNpWqyVMJDhcbd3quUeUaOnirRw77wi0zNSD4zGVZX(UfcD2jBJEbvSaYJ3QIYc50quU8PaiX0RPbu01h8Pbf(awTc7M25dOORp4aFRkklKtdr5YNcGetVMgqrxFW9CSBy30oFafD9bFAWBvrzHCAikx(uaKy610ak66dwGcFYJ3QIYc50quU8PaiX0RPbu01hCGdAELcacHvRWUPD(ak66d(0BvrzHCAIfsf88bgc710KqGn9ASAnSW4JWUPD(ak66doW3QIYc50quU8PaiX0RPbu01hSaf(KwTEle6St2o8mW3XQ1qiy4wySkzecNniXEil7cXheReB4rDUkX1qSG2rIZIyrqDj2qfTHcaxaXe3vqDJl6MEnnYYUq8EtVgC7kXcmyGWEuNRArUatnFoCqa0OWfWuByv0gkaC8teu34IUPxttfsixuuLh7oxGPMnh)wP0Q1CbMA2KAiemC7U40hZgq3B2dzzxi(GyLybVstLyFWUujUGjUtNiXWfG40wjg2b4KyiSsCbiUgIf0os8cNkG40wjg2b4KyiS2iUd90M4(Dt7K4tCvITROKy4cqCNoXgz5EtVgC7kXcmyGGW6Ztf1Izr1GyFGHIpZ4k9nla(fUst9vWpyfuxppBHdhmecgUHOCjCbqBqIwTMoQEQWh4y39Dle6St2g30oFWR2dzzxi(GyL4tCvIdaGwG03btCnelODK4ckXUujUGjUtLlHlaAJ4dIvIpXvjoaaAbsFhjMyFiUtLlHlakXomXNliITxekXQN2kG4aaqHqjoGmiCZcSPxdXfG4t01OK4cMybhlmUqXnI7W1tIHlaXYkXeNfXHkXqIehQWfqjEVPJytFmj(exL4aaOfi9DWeNfXORGWrDSsCARehcbd3il3B61GBxjwGbde8QptOfi9DWw4Wb7lecgUHOCjCbqBqIh7UVBvrzHCAikx(Yca0jBqIwT2xUrDYgIYLVSaaDYMoByuL9CSBelW3WO2KvIFqIhXIAm(YfyQjUHyrfDGFFzbDTdkSvR7nDe6twzdXIk6a)(Yc6AhelQX4lxGPM4gIfv0b(9Lf01(iwuJXxUatnXnelQOd87llOR9Pc3JvRHqWWneLlHlaAds8y34ckg6JSzcke6ZheUzb20RPPZggvPvR4ckg6JSb7Au(k4xySW4cf30zdJQShYYUq8bXkXcqFKMlQIjgPToeVXiXbiXDS6ft8cuIHeTG4cq85cI4fOe7dXDQCjCbqBe35hmeqjwaeAmvGpMe3PYLeJ0JrIXPhJehQedjsmsBDioTvIVlojoDuLyyFCSTIBeBKLiXqyFmjEtIpPajoxGPMyIr6PnXg6c8XK4(Dt7eDbAJSCVPxdUDLybgmqO(inxufBX98nQVCbMAIdkSfoCqFW7455a35EGJD3nIf4ByuBBm(KvIFqIh7UVBvrzHCAikx(uaKy610GeTATVCJ6KnBOXub(y(quUSPZggvzp9y1AiemCdr5s4cG2Ge75y39LBuNSzdnMkWhZhIYLnD2WOkTAvQHqWWnBOXub(y(quUSbu01h8P3fNV0rvRw7lecgUHOCjCbqBqI9CS7(YnQt2W6c8X8nUPDIUaTPZggvPvRyrngF5cm1e3q9r(W6cc8j7HSSleFqSs8bh7kEM4(lelX1qSG2rli2UIsFmjoe4kC8mXzrmY1tIHlaXIfsfqSpWqyVgIlaXRusmwCro4gz5EtVgC7kXcmyGGg7kE(nfI1choyF5g1jB2qJPc8X8HOCztNnmQYJiwGVHrTjRe)GeTAvQHqWWnBOXub(y(quUSbjEmecgUHOCjCbqBqIwT29TQOSqoneLlFkasm9AAafD9bFQWhWQ1(qSaFdJAtSQ4dUaVRe3ZX(cHGHBikxcxa0gKizzxi(GyL4Aiwq7iXHqjXIaVaE6yLyiSpMe3PYLe35bqIPxdXWoaNwqSdtmewLe7d2LkXfmXD6ejUgIn6LyiSs8cNkG4LyeLldRysmCbi(wvuwihIvyy)66Cpt8osIHlaX2qJPc8XKyeLljgsmDuLyhM4CJ6KQSrwU30Rb3UsSadgOWQMxb)sB9T4RosvAHdhSVqiy4gIYLWfaTbjESVBvrzHCAikx(uaKy610GepIf1y8LlWutCd1h5dRl4uHp2xUrDYgwxGpMVXnTt0fOnD2WOkTAT7qiy4gIYLWfaTbjEelQX4lxGPM4gQpYhwxqGf6X(YnQt2W6c8X8nUPDIUaTPZggv5XUfbkIN5v2eUHOC5lSI5XU7tfsixuuLnfv8mq34RaYzNRA1AF5g1jB2qJPc8X8HOCztNnmQYESAvfsixuuLnfv8mq34RaYzNREmb(COMnfv8mq34RaYzNR2UvfLfYPbu01hCGdkCatOhLAiemCZgAmvGpMpeLlBqI90JvRDhcbd3quUeUaOniXJ5g1jByDb(y(g30orxG20zdJQShYY9MEn42vIfyWaD3y8T30R5fDCAXSOAWe4ZHAIjl3B61GBxjwGbdKuXIkyt9jc2ZkWchoOTUX0UjEZahmGEsYsYYU0fIf0fNe3H2EujwqxC6JjX7n9AWnIn0K4nj22nTvaXIaVaEEM4SigBxGK4RdUqEsSpPcaqIjX3AKE61GjUgIfG(ij2qxqGoX4EMSSleFqSsSHUaFmjUF30orxGsSdt85cIyKEmsSTNeRtbzAtCUatnXeVJK4UwivaXbKbgc71q8osI7u5s4cGs8cuINkjgOR8SfexaIZIyGcduSnXgDyh0vIRH4ezrCbigTakX5cm1e3il3B61GBxK3GyDb(y(g30orxGAbewFiT9O(Ulo9XmOWwCpFJ6lxGPM4GcBHdhSBelW3WO2W6c8X8nUPDIUa9DHYcg(yFiwGVHrTjwv8bxG3vI7XQ1ULv2W2RSq(qwa5tC9PbuyGIT3WOEelQX4lxGPM4gQpYhwxWPc3dzzxi2WUajXcQdUqEsSHUaFmjUF30orxGs8TgPNEneNfXhQQiXgDyh0vIHej2hI7SQZtwU30Rb3UiVcmyGW6c8X8nUPDIUa1ciS(qA7r9DxC6JzqHT4E(g1xUatnXbf2choyUrDYgwxGpMVXnTt0fOnD2WOkpkRSHTxzH8HSaYN46tdOWafBVHr9iwuJXxUatnXnuFKpSUGtfkzzxiUM453f5Ly09qftCAReV30RH4AINjgcVHrLyjeWhtIV27mA0htI3rs8ujXlM4LyGAcfxaX7n9AAKL7n9AWTlYRadgiuFKVW4ItlQjE(DrEdkmzjz5EtVgCtIA(sGphQjoiewFEQOwmlQguUGdrRAEs9E47jcLafF15QKL7n9AWnjQ5lb(COMybgmqqy95PIAXSOAqm0egRs(wunTpJtYY9MEn4Me18LaFoutSadgiiS(8urTywunOz8SO9RGFlg7OECtVgYY9MEn4Me18LaFoutSadgiiS(8urTywunOeORe2b6dHIXAKSKSSlDHyb46dXDwxd4wqm2UGIsIVfcfq8gJed2XuXexWeNlWutmX7ijgF1zbEHjl3B61GBORpbVBm(2B618IooTywunyyvJf4e43mOWw4WbdHGHBHvnVc(L26BXxDKQSbjswU30Rb3qxFeyWajDSOgFORPFTWHd2xUatnBo(jg3ZkGSSleFqSsCNkxsCNhajMEnexdX3QIYc5qSyvrFmjEtIJ6ItIfIdqSp4D88mXHqjXtLe7WeFUGigPhJexiuWDfj2h8oEEMyFiUtNyJyb4EOsmgcOeJTxzHe21rgiuFKH6ivaX7ijwa6JKybhxCsSJjUgIVvfLfYH4qfUakXDQZtSdtCVBmCLlatCbi2WELfs44IQe7yIvHeYffvzJ4aI5uaLyXQI(ysmqXjWVPxdMyhMyiSpMeByVYcjCCrvI7kWXOeVJKybRJube7yIlOSrwU30Rb3qxFeyWaHOC5tbqIPxJfoCqelW3WO2eRk(GlW7kXh72h8oEE(0GcXbSAvuZgSRJST30rOhbqJcxatTHTxzHeoUO6te4y0MkKqUOOkp23TQOSqonuFKVW4IZgK4X(UvfLfYPHTxzH8HSaYNu30Ubj2ZXU9bVJNNdCWtWjTAn3OozdRlWhZ34M2j6c0MoByuLhrSaFdJAdRlWhZ34M2j6c03fkly4Eo23TQOSqonyxhzds8y39DRkklKtd1h5lmU4SbjA1kwuJXxUatnXnuFKpSUGtfQvR9bGgfUaMAdBVYcjCCr1NiWXOnviHCrrvESpa0OWfWuB5gdx5cWpCc2Cnv0MkKqUOOk75y39HlOyOpYgIkUPh1hUIi0jTAnecgUHOIB6r9HRicDYgKOvRyntFmXn3CkG(WveHozpKLDHyb4EOsmgcOeFUGiwekjgsKyJoSd6kXDMrN1vIRH40wjoxGPMe7We3HGnTHHIeFIRcCLyhpcys8EthHsmsBDig2nTtFmjwyb5aK4CbMAIBKL7n9AWn01hbgmqy7vwiFilG8jU(yHdhmecgUbV6ZeAbsFhCds8yFsnecgUHeSPnmu8bVkW1gK4rSOgJVCbMAIBO(iFyDbbwiil3B61GBORpcmyGUBm(2B618IooTywun4vIjl7cXcGUPnXDf4fWZZela9rsSHUaI3B61qCweduyGITjUJvVyIr6PnXyDb(y(g30orxGswU30Rb3qxFeyWaH6J8H1fyX98nQVCbMAIdkSfoCWCJ6KnSUaFmFJBANOlqB6SHrvEelQX4lxGPM4gQpYhwxWPiwGVHrTH6J8H1f8UqzbdFSpzLnS9klKpKfq(exFAPFp0hZJ9DRkklKtd21r2Gejl7cXDfOWkG4SigcRe3XfD20RH4oZOZ6kXomX7CM4ow9sSJjEQKyiXgz5EtVgCdD9rGbdKCrNn9AS4E(g1xUatnXbf2choyFiwGVHrTTX4twj(bjsw2fIpiwj2WELfsI7WcijUJ6M2e7WedH9XKyd7vwiHJlQsCxbogL4DKehQJubeJ0JrIvbHOduILqaFmjoTvIhvqKeBELnYY9MEn4g66JadgiS9klKpKfq(K6M2w4Wbf1Sb76iB7nDe6ra0OWfWuBy7vwiHJlQ(ebogTPcjKlkQYJIA2GDDKnGIU(GdCqZRKSSle3zrK7zmXqyLyuFKHXfNyIDyIVROOkjEhjX2qJPc8XKyeLlj2Xedjs8osIHW(ysSH9klKWXfvjURahJs8osId1rQaIDmXqInIjUZKsp9A2y8SfeFxCsmQpYW4ItIDyIpxqeJSGIsIdvIHMnmQeNfXMAsCARedC4K4WZeJC90htIxInVYgz5EtVgCdD9rGbdeQpYxyCXPfoCWUVvfLfYPH6J8fgxC2U2lWuXNk8XULAiemCZgAmvGpMpeLlBqIwT2xUrDYMn0yQaFmFikx20zdJQShRwf1Sb76iBafD9bh4G3fNV0rvbAEL9CuuZgSRJST30rOhbqJcxatTHTxzHeoUO6te4y0MkKqUOOkpkQzd21r2ak66d(07IZx6Okzzxi(GyL4ovUKybxXK4nj22nTvaXIaVaEEMyKEAtSai0yQaFmjUtLljgsK4SiwiioxGPMyliUaexPTcio3OojM4Ai2O3gz5EtVgCdD9rGbdeIYLVWkMw4Wb9bVJNNdCWtWjpMBuNSzdnMkWhZhIYLnD2WOkpMBuNSH1f4J5BCt7eDbAtNnmQYJyrngF5cm1e3q9r(W6ccCWaMvRD3DUrDYMn0yQaFmFikx20zdJQ8yF5g1jByDb(y(g30orxG20zdJQShRwXIAm(YfyQjUH6J8H1feu4Eil7cXDSgbmjgcRe3rfrbb8XK4UgxtiLyhM4ZfeX3Di2utI9jlI7u5s4cGsSp4uxPfexaIDyIn0f4JjX97M2j6cuIDmX5g1jvjX7ijgPhJeB7jX6uqM2eNlWutCJSCVPxdUHU(iWGbsQikiGpMpX4AcPw4Wb7gOWafBVHr1QvFW7455tdON0Q1BvrzHCAikx(Yca0jBafD9bh4GbOaG5v2ZXU7dXc8nmQnXQIp4c8UsSvR(G3XZZNg8eCYEo2DF5g1jByDb(y(g30orxG20zdJQ0Q1UZnQt2W6c8X8nUPDIUaTPZggv5X(qSaFdJAdRlWhZ34M2j6c03fkly4E6HSSleFqSsCNemX1qSG2rIDyIpxqelRratIhvLeNfX3fNe3rfrbb8XK4Ugxti1cI3rsCARaL4fOehvmM40EhIfcIZfyQjM4ckjU7tsmspTj(wJeYZEAKL7n9AWn01hbgmqikx(cRyAHdhelQX4lxGPM4gQpYhwxqG7wie4TgjKNnPJX1St(0RDP4MoByuL9C0h8oEEoWbpbN8yUrDYgwxGpMVXnTt0fOnD2WOkTATVCJ6KnSUaFmFJBANOlqB6SHrvsw2fIpiwj2WELfsI7Wci7aI7OUPnXomXPTsCUatnj2XeVHfusCwelDL4cq85cIy7fHsSH9klKWXfvjURahJsSkKqUOOkjgPN2ela9rgQJubexaInSxzHe21rs8EthH2il3B61GBORpcmyGW2RSq(qwa5tQBABX98nQVCbMAIdkSfoCWUZfyQzZw3yA3eVzGf6boIf1y8LlWutCd1h5dRliWcrpwT2TOMnyxhzBVPJqpcGgfUaMAdBVYcjCCr1NiWXOnviHCrrv2dzzxi(GyLydiaqhPciolIfGRCumM4AiEjoxGPMeN2BsSJj2S8XK4Siw6kXBsCARedCt7K40r1gz5EtVgCdD9rGbdegca0rQGxwp0vokgBX98nQVCbMAIdkSfoCWCbMA2shvFz9KUgyHEYJHqWWneLlHlaAtwihYYUq8bXkXDQCjX9waGojX1eptSdtSrh2bDL4DKe3PEjEbkX7nDekX7ijoTvIZfyQjXiRratILUsSec4JjXPTs81ENrJnYY9MEn4g66JadgieLlFzba6KwCpFJ6lxGPM4GcBHdheXc8nmQnzL4hK4XUdHGHBikxcxa0MSqowTgcbd3quUeUaOnGIU(Gd8TQOSqoneLlFHvmBafD9bB1Qiqr8mVYMWneLlFHvmp2xiemClmwLmcHZgq3BEelQX4lxGPM4gQpYhwxqGdWEoU30rOpzLnelQOd87llOR9PbVNVr9PJI6k(iwuJXxUatnXnuFKpSUGa39jfy3bmbGCJ6KTePJZxb)G3uB6SHrv2tpKL7n9AWn01hbgmqO(id1rQalC4GYkBiwurh43xwqx7w63d9X8y35g1jByDb(y(g30orxG20zdJQ8iwuJXxUatnXnuFKpSUGtrSaFdJAd1h5dRl4DHYcg2QvzLnS9klKpKfq(exFAPFp0hZEo2DFaOrHlGP2W2RSqchxu9jcCmAtfsixuuLwTU30rOpzLnelQOd87llOR9PbVNVr9PJI6kUhYYUq8bXkXgDyh0rIr6PnXDD9jeO7HkG4UI3ikXqtuXyItBL4CbMAsmspgjoujouJfsIf6bcaJ4qfUakXPTs8TQOSqoeFluftC4EpSrwU30Rb3qxFeyWaHTxzH8HSaYNu302choiaAu4cyQnX1NqGUhQGNiEJOnviHCrrvEeXc8nmQnzL4hK4XCbMA2shvFz9eV5tOh40UVvfLfYPHTxzH8HSaYNu30UjHaB61iqZRShYYUq8bXkXg2RSqsSGcwSnX1qSG2rIHMOIXeN2kqjEbkXRuIj2NBH6JzJSCVPxdUHU(iWGbcBVYc57cwSTfoCqW6YNIqNSTsjU5ZPcFaYYdIvIfG(ij2qxaXzr8TgmeQsChxWHe3RDbzANyIfb1ftCne3zbWoFJ4EdGDmasSGwdSdqj2XeN2oMyht8sSTBARaIfbEb88mXP9oeduzLPpMexdXDwaSZtm0evmMy5coK40UGmTtmXoM4nSGsIZI40rvIlOKSCVPxdUHU(iWGbc1h5dRlWI75BuF5cm1ehuylC4GyrngF5cm1e3q9r(W6cofXc8nmQnuFKpSUG3fkly4JHqWWn5co8L2fKPD2GeT4AV(euyl8jvaasmFokQk9n1GcBHpPcaqI5ZHdM(9q8PbfcYYUq8bXkXcqFKeFIX9mXzr8TgmeQsChxWHe3RDbzANyIfb1ftCneB0lXfuIDPsCbtCNoXgX9ga7yaKybTgyhGsSdtCA7yIDmXlX2UPTciwe4fWZZeN27qmqLvM(ysm0evmMy5coK40UGmTtmXoM4nSGsIZI40rvIlOKSCVPxdUHU(iWGbc1h5doUNTWHdgcbd3Kl4WxAxqM2zds8iIf4ByuBYkXpiXJ9fcbd3quUeUaOnirlU2Rpbf2cFsfaGeZNJIQsFtnOWw4tQaaKy(C4GPFpeFAqH4yFHqWWn5co8L2fKPD2Gejl7cXheRela9rsSGJloj2Hj(CbrSSgbmjEuvsCweduyGITjUJvV4gXgzjs8DXPpMeVjXcbXfGy0cOeNlWutmXi90MydDb(ysC)UPDIUaL4CJ6KQK4DKeFUGiEbkXtLedH9XKyd7vwiHJlQsCxbogL4cqCxXNV2(L4aUph2WIAm(YfyQjUH6J8H1fCANZtsSPMyItBLyuFCuiuIlyIpjX7ijoTvIhi0qfqCbtCUatnXnI7SiUSGyzr8ujXIafJjg1hzyCXjXqt6rI3yK4CbMAIjEbkXYktvsmspTjUt9smsBDigc7JjXy7vwiHJlQsSiWXOe7WehQJube7yIxeRh3WO2il3B61GBORpcmyGq9r(cJloTWHdIyb(gg1MSs8ds8iyD5trOt2qlekQozZNtVloFPJQc8aTtEelQX4lxGPM4gQpYhwxqG7wieOqfaYnQt2qDSco30zdJQuG7nDe6twzdXIk6a)(Yc6AlaKBuNSjIpFT97l6ZHnD2WOkfy3yrngF5cm1e3q9r(W6coTZ5j7raOBrnBWUoY2EthHEeankCbm1g2ELfs44IQprGJrBQqc5IIQSNEo2DFaOrHlGP2W2RSqchxu9jcCmAtfsixuuLwT23TQOSqonyxhzds8iaAu4cyQnS9klKWXfvFIahJ2uHeYffvPvR7nDe6twzdXIk6a)(Yc6AFAW75BuF6OOUI7HSCVPxdUHU(iWGbcXIk6a)(Yc6ABX98nQVCbMAIdkSfoCqGcduS9gg1J5cm1SLoQ(Y6jD90aMvRDNBuNSH6yfCUPZggv5rzLnS9klKpKfq(exFAafgOy7nmQ9y1AiemCdAGHarFmFYfC4OyCdsKSSleBiQxFJeFRr6PxdXzrmolrIVlo9XKyJoSd6kX1qCbdliNlWutmXiT1Hyy30o9XK4aK4cqmAbuIX5EpuLeJwHyI3rsme2htI7k(812VehW95qI3rsC)bWEjwa6yfCUrwU30Rb3qxFeyWaHTxzH8HSaYN46JfoCqGcduS9gg1J5cm1SLoQ(Y6jD9uH4yF5g1jBOowbNB6SHrvEm3OozteF(A73x0NdB6SHrvEelQX4lxGPM4gQpYhwxWPcLSSleFcRQiXgDyh0vIHejUgIxmXO7CM4CbMAIjEXelwyShgvliwfexvmjgPToed7M2PpMehGexaIrlGsmo37HQKy0ketmspTjUR4ZxB)sCa3NdBKL7n9AWn01hbgmqy7vwiFilG8jU(yX98nQVCbMAIdkSfoCqGcduS9gg1J5cm1SLoQ(Y6jD9uH4yF5g1jBOowbNB6SHrvESVUZnQt2W6c8X8nUPDIUaTPZggv5rSOgJVCbMAIBO(iFyDbNIyb(gg1gQpYhwxW7cLfmCph7UVCJ6Knr85RTFFrFoSPZggvPvRDNBuNSjIpFT97l6ZHnD2WOkpIf1y8LlWutCd1h5dRliWbfAp9qwU30Rb3qxFeyWaH6J8H1fyX98nQVCbMAIdkSfoCqSOgJVCbMAIBO(iFyDbNIyb(gg1gQpYhwxW7cLfm8XU7dxqXqFKnevCtpQpCfrOtA1AF3QIYc50GJk2(cw4Sbj2Jfx71NGcBHpPcaqI5ZrrvPVPguyl8jvaasmFoCW0VhIpnOqjl3B61GBORpcmyGq9r(GJ7zlU2Rpbf2cFsfaGeZNJIQsFtnOWw4tQaaKy(C4GPFpeFAqHES7(cHGHBYfC4lTlit7SbjA16TQOSqoneLlFHvmBqI9yHdhSpCbfd9r2quXn9O(WveHoPvR9DRkklKtdoQy7lyHZgKizzxi(GyL4tmQy7lyHtIlOe7sL4cMy01hIVvfLfYbtCweJU(KRpe3PkUPhvInQicDsIdHGHBKL7n9AWn01hbgmqWrfBFblCAHdhexqXqFKnevCtpQpCfrOtESVqiy4gIYLWfaTbjESVqiy4MyHubpFGHWEnnirl8jvaasmFokQk9n1GcBHpPcaqI5ZHdM(9q8PbfMSSleFqSsSrh2bDK4ftCCXjXafxGKyhM4AioTvIrlekz5EtVgCdD9rGbde2ELfYhYciFsDtBYYUq8bXkXgDyh0vIxmXXfNeduCbsIDyIRH40wjgTqOeVJKyJoSd6iXoM4Aiwq7iz5EtVgCdD9rGbde2ELfYhYciFIRpKLKLDH4dIvIRHybTJe3zgDwxjolIn1K4ow9sC63d9XK4DKeRccrhOeNfXrFuIHejouZubeJ0tBI7u5s4cGswU30Rb3sGphQjoiewFEQOwmlQgurfpd0n(kGC25Qw4WbVvfLfYPHOC5tbqIPxtdOORp4ahuyHA16TQOSqoneLlFkasm9AAafD9bFQqdOKLDH4EbNjolInopxIdiDo6iXi90M4owqHrLyJCVhQsIf0oIj2HjwSWypmQnIdGdXXAmvaXWUPDIjgPN2eJwaL4asNJosmewXeVzQOIjXzrm(8CjgPN2eVZzIVsIlaXNqq4KyiSsSNnYY9MEn4wc85qnXcmyGGW6Ztf1Izr1G(GVaOCdJ6tiH2jHqFsfHFvlC4GHqWWneLlHlaAds8yiemCtSqQGNpWqyVMgKOvRHfgFe2nTZhqrxFWboOqpGvRHqWWnXcPcE(adH9AAqIhVvfLfYPHOC5tbqIPxtdOORpybk8jpf2nTZhqrxFWwTgcbd3quUeUaOniXJ3QIYc50elKk45dme2RPbu01hSaf(KNc7M25dOORpyRw7(wvuwiNMyHubpFGHWEnnGIU(GpnOWh44TQOSqoneLlFkasm9AAafD9bFAqHpqphHDt78bu01h8PbfUZ9aKLDHyJZZLydBvtIfGqy)smspTjUtLlHlakz5EtVgClb(COMybgmqqy95PIAXSOAq09UHa9HTvnFOqy)AHdh8wvuwiNgIYLpfajMEnnGIU(Gpv4dqw2fInopxIdabfEMyKEAtCxlKkG4aYadH9AigcVMQfeJUhQeJHakXzrmECrL40wjowivCsSayxjoxGPMnI7qBDigcRsIr6PnXg2RSqQsIdGGqIlyI7TaO6Kwq8jeeojgcRexdXcAhjEXeJcDTjEXelwyShg1gz5EtVgClb(COMybgmqqy95PIAXSOAqCbfJAM(y(aqHNT4E(g1xUatnXbf2choyiemCtSqQGNpWqyVMgKOvR9jcCfNnSgHFIfsf88bgc71y1QkKqUOOkBy7vwiv5RaHVc(LfavNKSSleFqSsSGxPPsSpyxQexWe3PtKy4cqCARed7aCsmewjUaexdXcAhjEHtfqCARed7aCsmewBeByxGK4RdUqEsSdtmIYLeRaiX0RH4BvrzHCi2Xel8bWexaIrlGs8ICp3il3B61GBjWNd1elWGbccRppvulMfvdI9bgk(mJR03Sa4x4kn1xb)GvqD98SfoCWBvrzHCAikx(uaKy610ak66d(0GcFaYYUq8bXkXg2RSqQsIdGGqIlyI7TaO6KeJ0whINkj2hI7u5s4cGAbXfGyFioutKQoe3PYLel4kMeFxCIj2hI7u5s4cG2iUZWeFcFg47qCbiUF9cQybKeh9rj2tIHejgPN2eJZ9EOkj(wvuwihCJSCVPxdULaFoutSadgiiS(8urTywuni2ELfsv(kq4RGFzbq1jTWHdERkklKttSqQGNpWqyVMgqrxFWboOWh44TQOSqoneLlFkasm9AAafD9bh4GcFGJDFle6St2g9cQybKwTEle6St2o8mW3PhRw7(wi0zNSHqN0(mWQ1BHqNDY24M25dE1Eo2DFHqWWneLlHlaAds0QvrGI4zELnHBikx(cRy2JvRHfgFe2nTZhqrxFWboOqCaYsYYUq8bXkXrhNexWexJGmewjwUORPsCc85qnXext8mXomXcGqJPc8XK4ovUK4oQHqWWe7yI3B6iuliUaeFUGiEbkXtLeNBuNuLe7twe7zJSCVPxdULaFoutSadgO7gJV9MEnVOJtlMfvdkrnFjWNd1eBbob(ndkSfoCWU7l3OozZgAmvGpMpeLlB6SHrvA1QudHGHB2qJPc8X8HOCzdsSNJDhcbd3quUeUaOnirRwVvfLfYPHOC5tbqIPxtdOORp4tf(a9qw2fI7OcVqXKy4ngd37HedxaIHWByuj2tff3beFqSsCneFRkklKdX(qCbKkG4WZeNaFoutIXXkBKL7n9AWTe4ZHAIfyWabH1NNkk2choyiemCdr5s4cG2GeTAnecgUjwivWZhyiSxtds0Q1BvrzHCAikx(uaKy610ak66d(uHpW3alQ3F)c9KNGF(Z)h]] )
    

end
