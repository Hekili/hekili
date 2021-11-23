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


    spec:RegisterPack( "Shadow", 20211105, [[difXzcqiPQ8iPs6ssvfKnPc9jsGgLuPoLufRIeaVIe0SOeDlsiQDjLFjGAysL4yKOwgjsptQQ00ir4AQiABKiQVjaX4KQk6CKisRtaQ5jGCpbAFQi9pPQc1bLkOfsc1djH0eLkYfvrGnQIqFKermssiYjfazLucVufb1mfG0njb0ovb9tbqnuPI6OsvfYsLQkWtPWuLQ0vLQQ2QuH(QubgljaTxv1FvLbJ6WkTyb9yvAYK6YeBguFMIgnL60uTAveKxRcmBHUnK2TIFlz4K0XfawoWZHA6IUoiBhcFhIgpjeoVkQ1lvvqnFkP9J8x5FVFd9MY)qL2fLQSYk3fLCRlkP9RsO83ipRkFd19EWAkFJzrLVHH9QlKFd19CSw9V3VbUGax5ByNPkoGdCGn90gkSDl0aJDuO4MEnxWcNbg7O3a)ncH8ygGMF43qVP8puPDrPkRSYDrj36IsA)QeDjG8nwO0UaFddhvr)g2UwlZp8BOf89ByyV6cjXDg4cojloSqiOHcG4tAjXkTlkvzYcYcf1EhtbhWKfkYe3lszpG4owUM4ElaqMKyK2YqCUatjj(wqtIjEbcXWf4k6gzHImXDgiPmAI1vIjEbcXqQeJ0wgIZfykjM4fieFJfwiolI1N9X0sIXfXP9MepqhiyIxGqmo9yKyGCluuz0IU9nIooX)E)gQa5wOHB(79FOY)E)gYSHrr)v834c8ua((nac66dM4arC)2LU8n2B618nulKc4HSa6hCbspH0Yp)hQ0FVFdz2WOO)k(BCbEkaF)g4ckg6JUPcHtOO8eaKA610KzdJIMyRwjgxqXqF0nevCtpkpCfrit2KzdJI(BS30R5BahfS9fSW5p)h2V)E)gYSHrr)v834c8ua((n6J4qiy4g2E1fs4cG2Gu)g7n9A(gy7vxiHla6p)hQe)E)gYSHrr)v834c8ua((n8bVJNNBAb2VEs8PeR8j)g7n9A(gl4UJ8YcaKj)5)Wt(79BiZggf9xXFJzrLVb2E1fsr)kq4RGFzbqLj)g7n9A(gy7vxif9RaHVc(LfavM8N)dvY)E)gYSHrr)v83Ou)gyj)g7n9A(giwGVHr5BGyJqY3qPFdel4nlQ8nq9r)WYcExOSGH)5)WaYV3VXEtVMVbIfv1b(9Lf01(BiZggf9xX)8NFdnQ5lb(CGK4FV)dv(373qMnmk6VI)gZIkFd9coaTQ5PL7bVNkuce8vMR8n2B618n0l4a0QMNwUh8EQqjqWxzUYp)hQ0FVFdz2WOO)k(BmlQ8nWqtySk9BrL0(mo)g7n9A(gyOjmwL(TOsAFgN)8Fy)(79BiZggf9xXFJzrLVHz8SQ9RGFlg7OECtVMVXEtVMVHz8SQ9RGFlg7OECtVMF(puj(9(nKzdJI(R4VXSOY3qdKvd7a5HqWyj(n2B618n0az1WoqEiemwI)8NFd01NFV)dv(373qMnmk6VI)gxGNcW3VriemClSQ5vWV0wEl(kJw0ni1VXEtVMVXDJX3EtVMx0X53i648nlQ8ncRA(5)qL(79BiZggf9xXFJlWtb473OpIZfykzZXp14EwaFJ9MEnFdTJvL4dDn97p)h2V)E)gYSHrr)v83yVPxZ3ar56NaGutVMVHwWxGRMEnFJ(JfI7y5AIpbai10RH4Ai(wvuxihIvRk6JjXBsCuwCsSs0fI9bVJNNjoekjEQKyhM4ZfeXi9yK4cHaURkX(G3XZZe7dXD8eBeRa3deIXqaHyS9QlKWUm6aJ6JougTaiEhnXkqF0eR44ItIDmX1q8TQOUqoehkWfqiUJNaIDyI7DJHREbyIlaXg2RUqchxuHyhtSeaqUQQOBehGmNcieRwv0htIbcob(n9AWe7WedH9XKyd7vxiHJlQqCNbogL4D0eRyz0cGyhtCbLTVXf4Pa89BGyb(ggLMAvXhCbExnM4Je3nX(G3XZZeFAqIvIUqSvReRkzd2Lr32B6ieIpsmaAe4cyknS9QlKWXfvEQahJ2KaaYvvfnXhjUpIVvf1fYPH6J(fgxC2Guj(iX9r8TQOUqonS9QlKpKfq)0YM2nivI7H4Je3nX(G3XZZehOGe3ppjXwTsCUrzYgwwGpMVXnTt0finz2WOOj(iXiwGVHrPHLf4J5BCt7eDbY7cLfmmX9q8rI7J4BvrDHCAWUm6gKkXhjUBI7J4BvrDHCAO(OFHXfNnivITALySQeJVCbMsIBO(OFyzbeFkXkLyRwjUpIbqJaxatPHTxDHeoUOYtf4y0MeaqUQQOj(iX9rmaAe4cykTCJHREb4hobBUMcAtcaixvv0e3dXhjUBI7JyCbfd9r3quXn9O8WveHmztMnmkAITAL4qiy4gIkUPhLhUIiKjBqQeB1kXyjtFmXn3CkG8WveHmjX98Z)HkXV3VHmByu0Ff)n2B618nW2RUq(qwa9tD95BOf8f4QPxZ3qbUhieJHacXNliIvHsIHuj2Odc4otChA0HDM4AioTfIZfykjXomXDaytByOiXN4kaxi2XJcMeV30rieJ0wgIHDt70htIvwrUFjoxGPK4234c8ua((ncHGHBWR8mHwG23b3Guj(iX9rSwcHGHBibBAddfFWRaCPbPs8rIXQsm(YfykjUH6J(HLfqCGiwj(5)Wt(79BiZggf9xXFJ9MEnFJ7gJV9MEnVOJZVr0X5Bwu5BC14F(puj)79BiZggf9xXFJ9MEnFduF0pSSGVX98nkVCbMsI)hQ834c8ua((nYnkt2WYc8X8nUPDIUaPjZggfnXhjgRkX4lxGPK4gQp6hwwaXNsmIf4ByuAO(OFyzbVluwWWeFK4(iwxzdBV6c5dzb0p11Nw63d8XK4Je3hX3QI6c50GDz0ni1VHwWxGRMEnFdfj30M4od8c45zIvG(Oj2qwaX7n9AiolIbcmqW2e3PQxmXi90MySSaFmFJBANOlq(5)WaYV3VHmByu0Ff)n2B618n0l6SPxZ34E(gLxUatjX)dv(BCbEkaF)g9rmIf4ByuABm(0vIFqQFdTGVaxn9A(gDgiWcG4Sigcle3PfD20RH4o0Od7mXomX7CM4ov9sSJjEQKyi12p)h2p)9(nKzdJI(R4VXEtVMVb2E1fYhYcOFAzt7VHwWxGRMEnFJ(JfInSxDHK4oOaAI7KSPnXomXqyFmj2WE1fs44Ike3zGJrjEhnXHYOfaXi9yKyrrO6aHyneWhtItBH4ruejXMxD7BCbEkaF)gQs2GDz0T9MocH4JedGgbUaMsdBV6cjCCrLNkWXOnjaGCvvrt8rIvLSb7YOBabD9btCGcsS5v)Z)HkP)E)gYSHrr)v83yVPxZ3a1h9lmU48BOf8f4QPxZ3OdJi3ZyIHWcXO(OdJloXe7WeFxvvrt8oAITHgtb4JjXikxtSJjgsL4D0edH9XKyd7vxiHJlQqCNbogL4D0ehkJwae7yIHuBetChQ1E61SX4zlj(U4KyuF0HXfNe7WeFUGigzbf1ehkednByuiolInLK40wig4WjXHNjg56PpMeVeBE1TVXf4Pa89B0nX3QI6c50q9r)cJloBx7fykyIpLyLj(iXDtSwcHGHB2qJPa8X8HOCDdsLyRwjUpIZnkt2SHgtb4J5dr56MmByu0e3dXwTsSQKnyxgDdiORpyIduqIVloFPJkeRqInVAI7H4JeRkzd2Lr32B6ieIpsmaAe4cyknS9QlKWXfvEQahJ2KaaYvvfnXhjwvYgSlJUbe01hmXNs8DX5lDu5N)dvUl)E)gYSHrr)v83yVPxZ3ar56xyfZVHwWxGRMEnFJ(JfI7y5AIvCftI3KyB30waeRc8c45zIr6PnXksqJPa8XK4owUMyivIZIyLG4CbMsITK4cqCL2cG4CJYKyIRHyJEBFJlWtb473Wh8oEEM4afK4(5jj(iX5gLjB2qJPa8X8HOCDtMnmkAIpsCUrzYgwwGpMVXnTt0finz2WOOj(iXyvjgF5cmLe3q9r)WYcioqbjwjtSvRe3nXDtCUrzYMn0ykaFmFikx3KzdJIM4Je3hX5gLjByzb(y(g30orxG0KzdJIM4Ei2QvIXQsm(YfykjUH6J(HLfqCqIvM4E(5)qLv(373qMnmk6VI)g7n9A(gAbrbb8X8Pgxti5BOf8f4QPxZ3Ot1OGjXqyH4ojikiGpMe354Acje7WeFUGi(UdXMssSpzrChlxdxauI9bNYQTK4cqSdtSHSaFmj(q30orxGqSJjo3OmPOjEhnXi9yKyBpjwMcY0M4CbMsIBFJlWtb473OBIbcmqW2Byui2QvI9bVJNNj(uIdiNKyRwj(wvuxiNgIY1VSaazYgqqxFWehOGe3VeRaqS5vtCpeFK4UjUpIrSaFdJstTQ4dUaVRgtSvRe7dEhppt8PbjUFEsI7H4Je3nX9rCUrzYgwwGpMVXnTt0finz2WOOj2QvI7M4CJYKnSSaFmFJBANOlqAYSHrrt8rI7JyelW3WO0WYc8X8nUPDIUa5DHYcgM4EiUNF(puzL(79BiZggf9xXFJ9MEnFdeLRFHvm)gAbFbUA618n6pwiUJkM4Aiwr7eXomXNliI11OGjXJiAIZI47ItI7KGOGa(ysCNJRjKyjX7OjoTfGq8ceIJcgtCAVdXkbX5cmLetCbLe39jjgPN2eFRrd5zpTVXf4Pa89BGvLy8LlWusCd1h9dllG4arC3eReeRqIV1OH8SPDmUMDYNCTlb3KzdJIM4Ei(iX(G3XZZehOGe3ppjXhjo3OmzdllWhZ34M2j6cKMmByu0eB1kX9rCUrzYgwwGpMVXnTt0finz2WOO)5)qL73FVFdz2WOO)k(BS30R5BGTxDH8HSa6Nw20(BCpFJYlxGPK4)Hk)nUapfGVFJUjoxGPKnBzJPDt9MehiIvAxi(iXyvjgF5cmLe3q9r)WYcioqeRee3dXwTsC3eRkzd2Lr32B6ieIpsmaAe4cyknS9QlKWXfvEQahJ2KaaYvvfnX98n0c(cC10R5B0FSqSH9QlKe3bfqhWe3jztBIDyItBH4CbMssSJjEdlOK4Siw7cXfG4ZfeX2lcHyd7vxiHJlQqCNbogLyjaGCvvrtmspTjwb6JougTaiUaeByV6cjSlJM49MocP9Z)HkRe)E)gYSHrr)v83yVPxZ3adbaYOfWlRh6QhbJ)g3Z3O8Yfykj(FOYFJlWtb473ixGPKT0rLxwpTlehiIv6jj(iXHqWWneLRHlaAtxiNVHwWxGRMEnFJ(JfInGaaz0cG4SiwbU6rWyIRH4L4CbMssCAVjXoMyZYhtIZIyTleVjXPTqmWnTtIthvA)8FOYN8373qMnmk6VI)g7n9A(gikx)YcaKj)g3Z3O8Yfykj(FOYFJlWtb473aXc8nmknDL4hKkXhjUBIdHGHBikxdxa0MUqoeB1kXHqWWneLRHlaAdiORpyIdeX3QI6c50quU(fwXSbe01hmXwTsSkqq8mV6MYneLRFHvmj(iX9rCiemClmwLocHZgq2Bs8rIXQsm(YfykjUH6J(HLfqCGiUFjUhIps8EthH80v2qSOQoWVVSGU2eFAqIVNVr5jJG6cM4JeJvLy8LlWusCd1h9dllG4arC3eFsIviXDtSsMyfaIZnkt2sKooFf8dEtPjZggfnX9qCpFdTGVaxn9A(g9hle3XY1e3BbaYKext8mXomXgDqa3zI3rtCh7L4fieV30rieVJM40wioxGPKeJSgfmjw7cXAiGpMeN2cXx7Dgj2(5)qLvY)E)gYSHrr)v834c8ua((n0v2qSOQoWVVSGU2T0Vh4JjXhjUBIZnkt2WYc8X8nUPDIUaPjZggfnXhjgRkX4lxGPK4gQp6hwwaXNsmIf4ByuAO(OFyzbVluwWWeB1kX6kBy7vxiFilG(PU(0s)EGpMe3dXhjUBI7Jya0iWfWuAy7vxiHJlQ8ubogTjbaKRQkAITAL49Moc5PRSHyrvDGFFzbDTj(0GeFpFJYtgb1fmX98n2B618nq9rhkJwa)8FOYbKFVFdz2WOO)k(BS30R5BGTxDH8HSa6Nw20(BOf8f4QPxZ3O)yHyJoiG7eXi90M4oV(ecK9abqCNXBeLyOjkymXPTqCUatjjgPhJehkehkXcjXkTl9drCOaxaH40wi(wvuxihIVfQGjoCVh0(gxGNcW3VbaAe4cykn11NqGShiGNkEJOnjaGCvvrt8rIrSaFdJstxj(bPs8rIZfykzlDu5L1t9MpL2fIpL4Uj(wvuxiNg2E1fYhYcOFAzt7MgcSPxdXkKyZRM4E(5)qL7N)E)gYSHrr)v83yVPxZ3aBV6c57cwS93ql4lWvtVMVr)XcXg2RUqsSIcwSnX1qSI2jIHMOGXeN2cqiEbcXRwJj2NBH6Jz7BCbEkaF)gG11pbHmzB1ACZhIpLyL7Yp)hQSs6V3VHmByu0Ff)n2B618nq9r)WYc(g3Z3O8Yfykj(FOYFdFsbaGuZNd)ns)Ea(0GkX3WNuaai185OOI23u(gk)nUapfGVFdSQeJVCbMsIBO(OFyzbeFkXiwGVHrPH6J(HLf8Uqzbdt8rIdHGHB6fCWlTlit7SbP(nU2RpFdL)5)qL2LFVFdz2WOO)k(BOf8f4QPxZ3O)yHyfOpAIpX4EM4Si(wdgcviUtl4aI71UGmTtmXQG6IjUgIn6L4ckXUwiUGjUJNyJ4EdWDkatSIwdSdqj2HjoTDmXoM4LyB30waeRc8c45zIt7Digi6ktFmjgAIcgtSEbhqCAxqM2jMyht8gwqjXzrC6OcXfu(nUapfGVFJqiy4MEbh8s7cY0oBqQeFKyelW3WO00vIFqQeFK4(ioecgUHOCnCbqBqQFdFsbaGuZNd)ns)Ea(0GkXX(cHGHB6fCWlTlit7SbP(n8jfaasnFokQO9nLVHYFJR96Z3q5VXEtVMVbQp6hCCp)Z)Hkv5FVFdz2WOO)k(BS30R5BG6J(fgxC(n0c(cC10R5B0FSqSc0hnXkoU4KyhM4ZfeX6AuWK4renXzrmqGbc2M4ov9IBeBKLkX3fN(ys8MeReexaIrlGqCUatjXeJ0tBInKf4JjXh6M2j6ceIZnktkAI3rt85cI4fiepvsme2htInSxDHeoUOcXDg4yuIlaXDgF(A7xIdO(CqdRkX4lxGPK4gQp6hwwWP9JpjXMsIjoTfIr9XrHqjUGj(KeVJM40wiEGqdfaXfmX5cmLe3iUdJ4YsI1fXtLeRcemMyuF0HXfNednPhjEJrIZfykjM4fieRRmfnXi90M4o2lXiTLHyiSpMeJTxDHeoUOcXQahJsSdtCOmAbqSJjErSECdJs7BCbEkaF)giwGVHrPPRe)Guj(iXG11pbHmzdTqiOYKnFi(uIVloFPJkeRqI7s7KeFKySQeJVCbMsIBO(OFyzbehiI7MyLGyfsSsjwbG4CJYKnuhlGZnz2WOOjwHeV30ripDLnelQQd87llORnXkaeNBuMSPIpFT97l6Zbnz2WOOjwHe3nXyvjgF5cmLe3q9r)WYci(0(XeFsI7HyfaI7MyvjBWUm62EthHq8rIbqJaxatPHTxDHeoUOYtf4y0MeaqUQQOjUhI7H4Je3nX9rmaAe4cyknS9QlKWXfvEQahJ2KaaYvvfnXwTsCFeFRkQlKtd2Lr3Guj(iXaOrGlGP0W2RUqchxu5PcCmAtcaixvv0eB1kX7nDeYtxzdXIQ6a)(Yc6At8Pbj(E(gLNmcQlyI75N)dvQs)9(nKzdJI(R4VXEtVMVbIfv1b(9Lf01(BCbEkaF)gabgiy7nmkeFK4CbMs2shvEz90Uq8PeRKj2QvI7M4CJYKnuhlGZnz2WOOj(iX6kBy7vxiFilG(PU(0acmqW2ByuiUhITAL4qiy4g0adbI(y(0l4GrW4gK634E(gLxUatjX)dv(N)dvA)(79BiZggf9xXFJ9MEnFdS9QlKpKfq)uxF(gAbFbUA618nmuLRVrIV1O90RH4SigNLkX3fN(ysSrheWDM4AiUGHvKZfykjMyK2YqmSBAN(ysC)sCbigTacX4CVhiAIrRqmX7Ojgc7JjXDgF(A7xIdO(CaX7Oj(WaCVeRaDSao3(gxGNcW3VbqGbc2EdJcXhjoxGPKT0rLxwpTleFkXkbXhjUpIZnkt2qDSao3KzdJIM4JeNBuMSPIpFT97l6Zbnz2WOOj(iXyvjgF5cmLe3q9r)WYci(uIv6p)hQuL4373qMnmk6VI)g7n9A(gy7vxiFilG(PU(8nUNVr5LlWus8)qL)gxGNcW3VbqGbc2EdJcXhjoxGPKT0rLxwpTleFkXkbXhjUpIZnkt2qDSao3KzdJIM4Je3hXDtCUrzYgwwGpMVXnTt0finz2WOOj(iXyvjgF5cmLe3q9r)WYci(uIrSaFdJsd1h9dll4DHYcgM4Ei(iXDtCFeNBuMSPIpFT97l6Zbnz2WOOj2QvI7M4CJYKnv85RTFFrFoOjZggfnXhjgRkX4lxGPK4gQp6hwwaXbkiXkL4EiUNVHwWxGRMEnFJtyruj2Odc4otmKkX1q8IjgDNZeNlWusmXlMy1cJ9WOyjXII4kQjXiTLHyy30o9XK4(L4cqmAbeIX5Epq0eJwHyIr6PnXDgF(A7xIdO(Cq7N)dv6j)9(nKzdJI(R4VXEtVMVbQp6hwwW34E(gLxUatjX)dv(B4tkaaKA(C4Vr63dWNguPFdFsbaGuZNJIkAFt5BO834c8ua((nWQsm(YfykjUH6J(HLfq8PeJyb(ggLgQp6hwwW7cLfmmXhjUBI7JyCbfd9r3quXn9O8WveHmztMnmkAITAL4(i(wvuxiNgCuW2xWcNnivI75BCTxF(gk)Z)Hkvj)79BiZggf9xXFJ9MEnFduF0p44E(B4tkaaKA(C4Vr63dWNguPh7UVqiy4MEbh8s7cY0oBqQwTERkQlKtdr56xyfZgKApFdFsbaGuZNJIkAFt5BO834AV(8nu(BCbEkaF)g9rmUGIH(OBiQ4MEuE4kIqMSjZggfnXwTsCFeFRkQlKtdoky7lyHZgK6p)hQ0aYV3VHmByu0Ff)n2B618nGJc2(cw48B4tkaaKA(C4Vr63dWNgu5VHpPaaqQ5ZrrfTVP8nu(BCbEkaF)g4ckg6JUHOIB6r5HRiczYMmByu0eFK4(ioecgUHOCnCbqBqQeFK4(ioecgUPwifWZhyiSxtds9BOf8f4QPxZ3O)yH4tmky7lyHtIlOe7AH4cMy01hIVvf1fYbtCweJU(KRpe3XkUPhfInQiczsIdHGHB)8FOs7N)E)gYSHrr)v83ql4lWvtVMVr)XcXgDqa3jIxmXXfNedeCbsIDyIRH40wigTqiFJ9MEnFdS9QlKpKfq)0YM2)8FOsvs)9(nKzdJI(R4VHwWxGRMEnFJ(JfIn6GaUZeVyIJlojgi4cKe7WexdXPTqmAHqiEhnXgDqa3jIDmX1qSI2PVXEtVMVb2E1fYhYcOFQRp)8NFJlY7V3)Hk)79BiZggf9xXFdiS8qA7r5DxC6J5)qL)g7n9A(gyzb(y(g30orxG8nUNVr5LlWus8)qL)gxGNcW3Vr3eJyb(ggLgwwGpMVXnTt0fiVluwWWeFK4(igXc8nmkn1QIp4c8UAmX9qSvRe3nX6kBy7vxiFilG(PU(0acmqW2Byui(iXyvjgF5cmLe3q9r)WYci(uIvM4E(gAbFbUA618n6pwi2qwGpMeFOBANOlqi2Hj(Cbrmspgj22tILPGmTjoxGPKyI3rtCNlKcG4a0adH9AiEhnXDSCnCbqjEbcXtLedKvF2sIlaXzrmqGbc2MyJoiG7mX1qCISiUaeJwaH4CbMsIB)8FOs)9(nKzdJI(R4VbewEiT9O8Ulo9X8FOYFJ9MEnFdSSaFmFJBANOlq(g3Z3O8Yfykj(FOYFJlWtb473i3OmzdllWhZ34M2j6cKMmByu0eFKyDLnS9QlKpKfq)uxFAabgiy7nmkeFKySQeJVCbMsIBO(OFyzbeFkXk9BOf8f4QPxZ3WWUajXkQdUqEsSHSaFmj(q30orxGq8TgTNEneNfXhiIkXgDqa3zIHuj2hI7W6e8Z)H97V3VHmByu0Ff)nQjE(DrE)gk)n2B618nq9r)cJlo)gAbFbUA618nQjE(DrEjgDpqWeN2cX7n9AiUM4zIHWByuiwdb8XK4R9oJe9XK4D0epvs8IjEjgiMqXfq8EtVM2p)53ib(CGK4FV)dv(373qMnmk6VI)gAbFbUA618n6pwiUgIv0orChA0HDM4Si2usI7u1lXPFpWhtI3rtSOiuDGqCweh9rigsL4qjtbqmspTjUJLRHla63ywu5BiOQNbYgFfqp7CLVXf4Pa89BCRkQlKtdr56NaGutVMgqqxFWehOGeRSsj2QvIVvf1fYPHOC9taqQPxtdiORpyIpLyLgq(g7n9A(gcQ6zGSXxb0Zox5N)dv6V3VHmByu0Ff)n0c(cC10R5B0l4mXzrSX55sCaQFuNigPN2e3PckmkeBK79artSI2jmXomXQfg7HrPrCaEiowJPaig2nTtmXi90My0ciehG6h1jIHWcM4ntbvnjolIXNNlXi90M4Dot8vtCbi(eccNedHfI9S9nMfv(g(GVaOCdJYlaG2jHqFAbHFLVXf4Pa89Becbd3quUgUaOnivIpsCiemCtTqkGNpWqyVMgKkXwTsCyHXeFKyy30oFabD9btCGcsSs7cXwTsCiemCtTqkGNpWqyVMgKkXhj(wvuxiNgIY1pbaPMEnnGGU(GjwHeR8jj(uIHDt78be01hmXwTsCiemCdr5A4cG2Guj(iX3QI6c50ulKc45dme2RPbe01hmXkKyLpjXNsmSBANpGGU(Gj2QvI7M4BvrDHCAQfsb88bgc710ac66dM4tdsSYDH4JeFRkQlKtdr56NaGutVMgqqxFWeFAqIvUle3dXhjg2nTZhqqxFWeFAqIvwjTlFJ9MEnFdFWxauUHr5faq7KqOpTGWVYp)h2V)E)gYSHrr)v83ql4lWvtVMVHX55sSHTijXkqiSFjgPN2e3XY1Wfa9BmlQ8nq37gcKh2wK8HcH9734c8ua((nUvf1fYPHOC9taqQPxtdiORpyIpLyL7Y3yVPxZ3aDVBiqEyBrYhke2V)8FOs879BiZggf9xXFJzrLVbUGIrjtFmFaOWZFJ75BuE5cmLe)pu5VXEtVMVbUGIrjtFmFaOWZFJlWtb473iecgUPwifWZhyiSxtdsLyRwjUpIvbUGZgwIWp1cPaE(adH9Ai2QvILaaYvvfDdBV6cPOFfi8vWVSaOYKFdTGVaxn9A(ggNNlX9dGcptmspTjUZfsbqCaAGHWEnedHxtXsIr3deIXqaH4SigpUQqCAlehlKcojwrQZeNlWuYgXDGTmedHfnXi90Myd7vxifnXbyqiXfmX9wauzslj(eccNedHfIRHyfTteVyIrHU2eVyIvlm2dJs7N)dp5V3VHmByu0Ff)n0c(cC10R5B0FSqSIxTPqSpyxlexWe3XtKy4cqCAled7aCsmewiUaexdXkANiEHtbqCAled7aCsmewAeByxGK4RdUqEsSdtmIY1elai10RH4BvrDHCi2XeRCxWexaIrlGq8ICp3(gZIkFdSpWqXNzC1(Mfa)cxTP8k4hSaQRNN)gxGNcW3VXTQOUqoneLRFcasn9AAabD9bt8Pbjw5U8n2B618nW(adfFMXv7Bwa8lC1MYRGFWcOUEE(N)dvY)E)gYSHrr)v83ql4lWvtVMVr)XcXg2RUqkAIdWGqIlyI7TaOYKeJ0wgINkj2hI7y5A4cGAjXfGyFiousKIme3XY1eR4kMeFxCIj2hI7y5A4cG2iUdXeFcFg47qCbi(q5cQyb0eh9ri2tIHujgPN2eJZ9EGOj(wvuxihC7BmlQ8nW2RUqk6xbcFf8llaQm534c8ua((nUvf1fYPPwifWZhyiSxtdiORpyIduqIvUleFK4BvrDHCAikx)eaKA610ac66dM4afKyL7cXhjUBIVfcz2jBJCbvSaAITAL4BHqMDY2bNb(oe3dXwTsC3eFleYSt2qitAFgqSvReFleYSt2g30oFWRqCpeFK4UjUpIdHGHBikxdxa0gKkXwTsSkqq8mV6MYneLRFHvmjUhITAL4WcJj(iXWUPD(ac66dM4afKyLOlFJ9MEnFdS9QlKI(vGWxb)YcGkt(Z)HbKFVFdz2WOO)k(BOf8f4QPxZ3O)yH4OJtIlyIRrrgcleRx01uiob(CGKyIRjEMyhMyfjOXua(ysChlxtCNKqiyyIDmX7nDeILexaIpxqeVaH4PsIZnktkAI9jlI9S9n2B618nUBm(2B618Ioo)gxGNcW3Vr3e3hX5gLjB2qJPa8X8HOCDtMnmkAITALyTecbd3SHgtb4J5dr56gKkX9q8rI7M4qiy4gIY1WfaTbPsSvReFRkQlKtdr56NaGutVMgqqxFWeFkXk3fI75BeDC(Mfv(gAuZxc85ajX)8Fy)8373qMnmk6VI)g7n9A(gqy55PGI)gAbFbUA618n6KaVqXKy4ngd37bedxaIHWByui2tbfhWe3FSqCneFRkQlKdX(qCb0cG4WZeNaFoqsIXXkBFJlWtb473iecgUHOCnCbqBqQeB1kXHqWWn1cPaE(adH9AAqQeB1kX3QI6c50quU(jai10RPbe01hmXNsSYD5N)8BC14FV)dv(373qMnmk6VI)g7n9A(gQfsb88bgc718n0c(cC10R5B0FSqCNlKcG4a0adH9AigPN2e3XY1WfaTrSIuf1edxaI7y5A4cGs8TqfmXfmmX3QI6c5qSpeN2cXJOisIvUleJLBnAmXvAlaKowigclexdXxnXqtuWyItBHy14Ewae7yIvxqsCbtCAleFWzGVdX3cHm7KwsCbi2HjoTfGqmspgjEQK4qH4DQ0wae3XY1eFcaqQPxdXPTJjg2nTZgXDyMcQAsCweJppxItBH44ItIvlKcGyFGHWEnexWeN2cXWUPDsCweJOCnXcasn9AigUaep1q8j8zGVdU9nUapfGVFdvGl4SHLi8tTqkGNpWqyVgIpsC3ehcbd3quUgUaOnivITAL4(i(wiKzNSDWzGVdXhjUpIVfcz2jBJCbvSaAIps8TQOUqoneLRFcasn9AAabD9bt8Pbjw5UqSvRed7M25diORpyIdeX3QI6c50quU(jai10RPbe01hmX9q8rI7Myy30oFabD9bt8Pbj(wvuxiNgIY1pbaPMEnnGGU(GjwHeR8jj(iX3QI6c50quU(jai10RPbe01hmXbkiXMxnXkaeReeB1kXWUPD(ac66dM4tj(wvuxiNMAHuapFGHWEnnneytVgITAL4WcJj(iXWUPD(ac66dM4ar8TQOUqoneLRFcasn9AAabD9btScjw5tsSvReFleYSt2o4mW3HyRwjoecgUfgRshHWzdsL4E(5)qL(79BiZggf9xXFdTGVaxn9A(g9hleR4vBke7d21cXfmXD8ejgUaeN2cXWoaNedHfIlaX1qSI2jIx4uaeN2cXWoaNedHLgXDGN2eFOBANeFIRqSDf1edxaI74j2(gZIkFdSpWqXNzC1(Mfa)cxTP8k4hSaQRNN)gxGNcW3VriemCdr5A4cG2Guj2QvIthvi(uIvUleFK4UjUpIVfcz2jBJBANp4viUNVXEtVMVb2hyO4ZmUAFZcGFHR2uEf8dwa11ZZ)8Fy)(79BiZggf9xXFJ9MEnFd4vEMqlq77G)gAbFbUA618n6pwi(exHyLeOfO9DWexdXkANiUGsSRfIlyI7y5A4cG2iU)yH4tCfIvsGwG23rJj2hI7y5A4cGsSdt85cIy7fHqS4PTaiwjbuieIdqdc3SaB61qCbi(eDjQjUGjwXXcJluCJ4oy9Ky4cqSUsmXzrCOqmKkXHcCbeI3B6i20htIpXviwjbAbAFhmXzrm6QiCuhleN2cXHqWWTVXf4Pa89B0hXHqWWneLRHlaAdsL4Je3nX9r8TQOUqoneLRFzbaYKnivITAL4(io3Omzdr56xwaGmztMnmkAI7H4Je3nXiwGVHrPPRe)Guj(iXyvjgF5cmLe3qSOQoWVVSGU2ehKyLj2QvI3B6iKNUYgIfv1b(9Lf01M4GeJvLy8LlWusCdXIQ6a)(Yc6At8rIXQsm(YfykjUHyrvDGFFzbDTj(uIvM4Ei2QvIdHGHBikxdxa0gKkXhjUBIXfum0hDZeuiKNpiCZcSPxttMnmkAITALyCbfd9r3GDjQFf8lmwyCHIBYSHrrtCp)8FOs879BiZggf9xXFJ9MEnFduF0MlQG)g3Z3O8Yfykj(FOYFJlWtb473Wh8oEEM4arSsAxi(iXDtC3eJyb(ggL2gJpDL4hKkXhjUBI7J4BvrDHCAikx)eaKA610Guj2QvI7J4CJYKnBOXua(y(quUUjZggfnX9qCpeB1kXHqWWneLRHlaAdsL4Ei(iXDtCFeNBuMSzdnMcWhZhIY1nz2WOOj2QvI1siemCZgAmfGpMpeLRBabD9bt8PeFxC(shvi2QvI7J4qiy4gIY1WfaTbPsCpeFK4UjUpIZnkt2WYc8X8nUPDIUaPjZggfnXwTsmwvIXxUatjXnuF0pSSaIdeXNK4E(gAbFbUA618n6pwiwb6J2CrfmXiTLH4ngjUFjUtvVyIxGqmKQLexaIpxqeVaHyFiUJLRHlaAJ4tWGHacXksqJPa8XK4owUMyKEmsmo9yK4qHyivIrAldXPTq8DXjXPJked7JJTfCJyJSujgc7JjXBs8jviX5cmLetmspTj2qwGpMeFOBANOlqA)8F4j)9(nKzdJI(R4VXEtVMVb0yxXZVPqSFdTGVaxn9A(g9hle3)XUINj(WcXsCneRODYsITRO2htIdbUahptCweJC9Ky4cqSAHuae7dme2RH4cq8Q1eJvxKdU9nUapfGVFJ(io3OmzZgAmfGpMpeLRBYSHrrt8rIrSaFdJstxj(bPsSvReRLqiy4Mn0ykaFmFikx3Guj(iXHqWWneLRHlaAdsLyRwjUBIVvf1fYPHOC9taqQPxtdiORpyIpLyL7cXwTsCFeJyb(ggLMAvXhCbExnM4Ei(iX9rCiemCdr5A4cG2Gu)5)qL8V3VHmByu0Ff)n2B618ncRAEf8lTL3IVYOf93ql4lWvtVMVr)XcX1qSI2jIdHsIvbEb80XcXqyFmjUJLRj(eaGutVgIHDaoTKyhMyiSOj2hSRfIlyI74jsCneB0lXqyH4fofaXlXikxhwXKy4cq8TQOUqoelWW(1L5EM4D0edxaITHgtb4JjXikxtmKA6OcXomX5gLjfD7BCbEkaF)g9rCiemCdr5A4cG2Guj(iX9r8TQOUqoneLRFcasn9AAqQeFKySQeJVCbMsIBO(OFyzbeFkXkt8rI7J4CJYKnSSaFmFJBANOlqAYSHrrtSvRe3nXHqWWneLRHlaAdsL4JeJvLy8LlWusCd1h9dllG4arSsj(iX9rCUrzYgwwGpMVXnTt0finz2WOOj(iXDtSkqq8mV6MYneLRFHvmj(iXDtCFelbaKRQk6MGQEgiB8va9SZvi2QvI7J4CJYKnBOXua(y(quUUjZggfnX9qSvRelbaKRQk6MGQEgiB8va9SZvi(iX3QI6c50eu1ZazJVcONDUsdiORpyIduqIvwjRuIpsSwcHGHB2qJPa8X8HOCDdsL4EiUhITAL4UjoecgUHOCnCbqBqQeFK4CJYKnSSaFmFJBANOlqAYSHrrtCp)8Fya5373qMnmk6VI)g7n9A(g3ngF7n9AErhNFJOJZ3SOY3ib(CGK4F(pSF(79BiZggf9xXFJlWtb473Ww2yA3uVjXbkiXbKt(n2B618n0cwvaBkpvWEwa)8NFJWQMFV)dv(373qMnmk6VI)gxGNcW3VbwvIXxUatjXnuF0pSSaIduqI73VXEtVMVXIVYOf9lmU48N)dv6V3VHmByu0Ff)n2B618nw8vgTOFtHy)gAbFbUA618ncWt8mXqyH4oeFLrlAIpSqSeJ0wgINkjo3OmPOj2NSi2qwGpMeFOBANOlqiUgIvQcjoxGPK4234c8ua((nWQsm(YfykjUT4RmAr)McXs8PeRmXhjgRkX4lxGPK4gQp6hwwaXNsSYeFK4(io3OmzdllWhZ34M2j6cKMmByu0)8NFdTaVqX837)qL)9(n2B618nWEuMR8nKzdJI(R4F(puP)E)gYSHrr)v834c8ua((ncHGHBikxdxa0gKkXwTsCiemCtTqkGNpWqyVMgK63yVPxZ3qTsVMF(pSF)9(nKzdJI(R4VrP(nWs(n2B618nqSaFdJY3aXgHKVr3eRRSHTxDH8HSa6N66tl97b(ysSvReNlWuYw6OYlRN2fIduqIvcI7H4Je3nX6kBiwuvh43xwqx7w63d8XKyRwjoxGPKT0rLxwpTlehOGeRKjUNVbIf8Mfv(g6kXpi1F(puj(9(nKzdJI(R4VrP(nWs(n2B618nqSaFdJY3aXgHKVbIf4ByuA6kXpivIpsC3eRRSPfefeWhZNACnHKw63d8XKyRwjoxGPKT0rLxwpTlehOGeRee3Z3aXcEZIkFJngF6kXpi1F(p8K)E)gYSHrr)v83Ou)gyj)g7n9A(giwGVHr5BGyJqY3aRkX4lxGPK4gQp6hwwaXNsSsjwHehcbd3quUgUaOni1VHwWxGRMEnFdJCbjXqyFmj2qwGpMeFOBANOlqiEtI7xfsCUatjXexaIvcfsSdt85cI4fie7dXDSCnCbq)giwWBwu5BGLf4J5BCt7eDbY7cLfm8p)hQK)9(nKzdJI(R4VrP(nWs(n2B618nqSaFdJY3aXgHKVXTQOUqoneLRFcasn9AAqQeFK4UjUpIbqJaxatPHvTfGGF2laTMZnjaGCvvrt8rI7J4BHqMDY2ixqflGMyRwj(wvuxiNMAHuapFGHWEnnGGU(Gjoqbj28QBORIGyfaI7xITAL4qiy4MAHuapFGHWEnnivITAL4WcJj(iXWUPD(ac66dM4afKyLEsI75BOf8f4QPxZ3qrRkQlKdXDUQiXDCb(ggfljU)yrtCweRwvK4qbUacX7nDeB6JjXikxdxa0gXkkeaitgptmew0eNfX3AsqfjgPTmeNfX7nDeBkeJOCnCbqjgPN2e7ZTq9XK4vRXTVbIf8Mfv(gQvfFWf4D14F(pmG879BiZggf9xXFJlWtb473iecgUHOCnCbqBqQFJ9MEnFdyhiHXQ0)8Fy)8373qMnmk6VI)gxGNcW3VriemCdr5A4cG2Gu)g7n9A(gHcalGd8X8N)dvs)9(nKzdJI(R4VXEtVMVr0nTt87ecsBIkt(n0c(cC10R5B0FSqCa1nTtfetSfqAtuzsIDyItBbieVaHyLsCbigTacX5cmLeBjXfG4vRXeVazuWKyS6IC8XKy4cqmAbeIt7DioGCsC7BCbEkaF)gyvjgF5cmLe3IUPDIFNqqAtuzsIpniXkLyRwjUBI7JyW66NGqMSTAnUjkchNyITALyW66NGqMSTAnU5dXNsCa5Ke3Zp)hQCx(9(nKzdJI(R4VXf4Pa89Becbd3quUgUaOni1VXEtVMVXoxbNGn(UBm(Z)HkR8V3VHmByu0Ff)n2B618nUBm(2B618Ioo)grhNVzrLVXf59N)dvwP)E)gYSHrr)v83yVPxZ3aanV9MEnVOJZVr0X5Bwu5BGU(8ZF(ZVbcbG9A(hQ0UOuLvw5UO83a5cgFmXFJoOd7hCya6qLKaMyI71wi2rvlqsmCbiwbvbYTqd3ubjgibaKdenX4cviEHYcDtrt81Ehtb3ilcO(ieR0aMyfTgecifnXkiUGIH(OBkGkiXzrScIlOyOp6McytMnmkAfK4Uvwr0tJSiG6JqSsdyIv0AqiGu0eRG4ckg6JUPaQGeNfXkiUGIH(OBkGnz2WOOvqI3K4tqaoGsC3kRi6Prwqw0bDy)GddqhQKeWetCV2cXoQAbsIHlaXki66JcsmqcaihiAIXfQq8cLf6MIM4R9oMcUrweq9riUFdyIv0AqiGu0eRG4ckg6JUPaQGeNfXkiUGIH(OBkGnz2WOOvqI7wzfrpnYIaQpcXk9KbmXkAnieqkAIvqCbfd9r3uavqIZIyfexqXqF0nfWMmByu0kiXDRSIONgzra1hHyLQKdyIv0AqiGu0eRG4ckg6JUPaQGeNfXkiUGIH(OBkGnz2WOOvqI7wzfrpnYIaQpcXknGeWeRO1GqaPOjwbXfum0hDtbubjolIvqCbfd9r3uaBYSHrrRGe3TYkIEAKfKfDqh2p4Wa0HkjbmXe3RTqSJQwGKy4cqScE1yfKyGeaqoq0eJluH4fkl0nfnXx7DmfCJSiG6JqSsoGjwrRbHasrtScMaFoqY2gEB3QI6c5OGeNfXk4TQOUqoTn8QGe3TYkIEAKfKfbiu1cKIM4(jX7n9Aio64e3il(gQGc2JY3ORDLyd7vxijUZaxWjzrx7kXhwie0qbq8jTKyL2fLQmzbzrx7kXkQ9oMcoGjl6AxjwrM4Erk7be3XY1e3BbaYKeJ0wgIZfykjX3cAsmXlqigUaxr3il6AxjwrM4odKugnX6kXeVaHyivIrAldX5cmLet8ceIVXcleNfX6Z(yAjX4I40EtIhOdemXlqigNEmsmqUfkQmAr3ilil6Axj(eOiKlukAIdf4cieFl0Wnjoum9b3iUdVxrnXep1OiBVauyOiX7n9AWext8CJSyVPxdUPcKBHgUPcdgy1cPaEilG(bxG0tiTyPdheiORp4a1VDPlKf7n9AWnvGCl0WnvyWadhfS9fSWPLoCqCbfd9r3uHWjuuEcasn9ASAfxqXqF0nevCtpkpCfritswS30Rb3ubYTqd3uHbdm2E1fs4cGAPdhSVqiy4g2E1fs4cG2Gujl2B61GBQa5wOHBQWGbEb3DKxwaGmPLoCqFW7455MwG9RNNQ8jjl2B61GBQa5wOHBQWGbgclppfulNfvcITxDHu0Vce(k4xwauzsYI9MEn4MkqUfA4MkmyGrSaFdJILZIkbr9r)WYcExOSGHTSudIL0seBescQuYI9MEn4MkqUfA4MkmyGrSOQoWVVSGU2KfKfDTRe35k9AWKf7n9AWbXEuMRqwS30RbhuTsVglD4GHqWWneLRHlaAds1Q1qiy4MAHuapFGHWEnnivYI9MEnyfgmWiwGVHrXYzrLG6kXpivll1GyjTeXgHKGDRRSHTxDH8HSa6N66tl97b(yA1AUatjBPJkVSEAxcuqLONJDRRSHyrvDGFFzbDTBPFpWhtRwZfykzlDu5L1t7sGcQK7HSyVPxdwHbdmIf4ByuSCwuj4gJpDL4hKQLLAqSKwIyJqsqelW3WO00vIFqQh7wxztlikiGpMp14AcjT0Vh4JPvR5cmLSLoQ8Y6PDjqbvIEil6kXg5csIHW(ysSHSaFmj(q30orxGq8Me3VkK4CbMsIjUaeRekKyhM4ZfeXlqi2hI7y5A4cGswS30RbRWGbgXc8nmkwolQeellWhZ34M2j6cK3fklyyll1GyjTeXgHKGyvjgF5cmLe3q9r)WYcovPkmecgUHOCnCbqBqQKfDLyfTQOUqoe35QIe3Xf4ByuSK4(JfnXzrSAvrIdf4cieV30rSPpMeJOCnCbqBeROqaGmz8mXqyrtCweFRjbvKyK2YqCweV30rSPqmIY1WfaLyKEAtSp3c1htIxTg3il2B61GvyWaJyb(ggflNfvcQwv8bxG3vJTSudIL0seBescERkQlKtdr56NaGutVMgK6XU7dancCbmLgw1wac(zVa0Ao3KaaYvvf9X(Ufcz2jBJCbvSaARwVvf1fYPPwifWZhyiSxtdiORp4af08QBORIqbOFTAnecgUPwifWZhyiSxtds1Q1WcJpc7M25diORp4afuPNShYI9MEnyfgmWWoqcJvPT0Hdgcbd3quUgUaOnivYI9MEnyfgmWHcalGd8X0shoyiemCdr5A4cG2Gujl6kX9hlehqDt7ubXeBbK2evMKyhM40wacXlqiwPexaIrlGqCUatjXwsCbiE1AmXlqgfmjgRUihFmjgUaeJwaH40EhIdiNe3il2B61GvyWahDt7e)oHG0MOYKw6WbXQsm(YfykjUfDt7e)oHG0MOYKNguPwT2DFG11pbHmzB1ACtueooXwTcwx)eeYKTvRXnFonGCYEil2B61GvyWaVZvWjyJV7gJw6WbdHGHBikxdxa0gKkzXEtVgScdg47gJV9MEnVOJtlNfvcErEjl2B61GvyWadGM3EtVMx0XPLZIkbrxFilil6AxjUd7CaL4SigcleJ0wgIvCvdXfmXPTqChIVYOfnXoM49MocHSyVPxdUfw1eCXxz0I(fgxCAPdheRkX4lxGPK4gQp6hwwqGc2VKfDL4a8eptmewiUdXxz0IM4dlelXiTLH4PsIZnktkAI9jlInKf4JjXh6M2j6ceIRHyLQqIZfykjUrwS30Rb3cRAuyWaV4RmAr)McXAPdheRkX4lxGPK42IVYOf9Bke7PkFeRkX4lxGPK4gQp6hwwWPkFSVCJYKnSSaFmFJBANOlqAYSHrrtwqw01UsSI2jmzrxjU)yH4oxifaXbObgc71qmspTjUJLRHlaAJyfPkQjgUae3XY1WfaL4BHkyIlyyIVvf1fYHyFioTfIhrrKeRCxigl3A0yIR0waiDSqmewiUgIVAIHMOGXeN2cXQX9Sai2XeRUGK4cM40wi(GZaFhIVfcz2jTK4cqSdtCAlaHyKEms8ujXHcX7uPTaiUJLRj(eaGutVgItBhtmSBANnI7Wmfu1K4SigFEUeN2cXXfNeRwifaX(adH9AiUGjoTfIHDt7K4Sigr5AIfaKA61qmCbiEQH4t4ZaFhCJSyVPxdUD14GQfsb88bgc71yPdhuf4coByjc)ulKc45dme2R5y3HqWWneLRHlaAds1Q1(Ufcz2jBhCg47CSVBHqMDY2ixqflG(4TQOUqoneLRFcasn9AAabD9bFAqL7IvRWUPD(ac66doq3QI6c50quU(jai10RPbe01hCph7g2nTZhqqxFWNg8wvuxiNgIY1pbaPMEnnGGU(GvOYN84TQOUqoneLRFcasn9AAabD9bhOGMxTcGsy1kSBANpGGU(Gp9wvuxiNMAHuapFGHWEnnneytVgRwdlm(iSBANpGGU(Gd0TQOUqoneLRFcasn9AAabD9bRqLpPvR3cHm7KTdod8DSAnecgUfgRshHWzdsThYIUsC)XcXgEuMRqCneRODI4SiwfuxInevBO(HvqmXDgu34IUPxtJSOReV30Rb3UAScdgyShL5kwMlWuYNdheancCbmLgwuTH6hg)ub1nUOB610KaaYvvf9XUZfykzZXVvRTAnxGPKnTecbd3Ulo9XSbK9M9qw0vI7pwiwXR2ui2hSRfIlyI74jsmCbioTfIHDaojgclexaIRHyfTteVWPaioTfIHDaojgclnI7apTj(q30oj(exHy7kQjgUae3XtSrwS30Rb3UAScdgyiS88uqTCwuji2hyO4ZmUAFZcGFHR2uEf8dwa11ZZw6WbdHGHBikxdxa0gKQvRPJkNQCxo2DF3cHm7KTXnTZh8k9qw0vI7pwi(exHyLeOfO9DWexdXkANiUGsSRfIlyI7y5A4cG2iU)yH4tCfIvsGwG23rJj2hI7y5A4cGsSdt85cIy7fHqS4PTaiwjbuieIdqdc3SaB61qCbi(eDjQjUGjwXXcJluCJ4oy9Ky4cqSUsmXzrCOqmKkXHcCbeI3B6i20htIpXviwjbAbAFhmXzrm6QiCuhleN2cXHqWWnYI9MEn42vJvyWadVYZeAbAFhSLoCW(cHGHBikxdxa0gK6XU77wvuxiNgIY1VSaazYgKQvR9LBuMSHOC9llaqMSjZggfDph7gXc8nmknDL4hK6rSQeJVCbMsIBiwuvh43xwqx7GkB16EthH80v2qSOQoWVVSGU2bXQsm(YfykjUHyrvDGFFzbDTpIvLy8LlWusCdXIQ6a)(Yc6AFQY9y1AiemCdr5A4cG2Gup2nUGIH(OBMGcH88bHBwGn9AAYSHrrB1kUGIH(OBWUe1Vc(fglmUqXnz2WOO7HSORe3FSqSc0hT5IkyIrAldXBmsC)sCNQEXeVaHyivljUaeFUGiEbcX(qChlxdxa0gXNGbdbeIvKGgtb4JjXDSCnXi9yKyC6XiXHcXqQeJ0wgItBH47ItIthvig2hhBl4gXgzPsme2htI3K4tQqIZfykjMyKEAtSHSaFmj(q30orxG0il2B61GBxnwHbdmQpAZfvWwEpFJYlxGPK4GkBPdh0h8oEEoqkPD5y3DJyb(ggL2gJpDL4hK6XU77wvuxiNgIY1pbaPMEnnivRw7l3OmzZgAmfGpMpeLRBYSHrr3tpwTgcbd3quUgUaOni1Eo2DF5gLjB2qJPa8X8HOCDtMnmkARw1siemCZgAmfGpMpeLRBabD9bF6DX5lDuXQ1(cHGHBikxdxa0gKAph7UVCJYKnSSaFmFJBANOlqAYSHrrB1kwvIXxUatjXnuF0pSSGaDYEil6kX9hle3)XUINj(WcXsCneRODYsITRO2htIdbUahptCweJC9Ky4cqSAHuae7dme2RH4cq8Q1eJvxKdUrwS30Rb3UAScdgyOXUINFtHyT0Hd2xUrzYMn0ykaFmFikx3KzdJI(iIf4ByuA6kXpivRw1siemCZgAmfGpMpeLRBqQhdHGHBikxdxa0gKQvRDFRkQlKtdr56NaGutVMgqqxFWNQCxSATpelW3WO0uRk(GlW7QX9CSVqiy4gIY1WfaTbPsw0vI7pwiUgIv0orCiusSkWlGNowigc7JjXDSCnXNaaKA61qmSdWPLe7WedHfnX(GDTqCbtChprIRHyJEjgcleVWPaiEjgr56WkMedxaIVvf1fYHybg2VUm3ZeVJMy4cqSn0ykaFmjgr5AIHuthvi2Hjo3OmPOBKf7n9AWTRgRWGboSQ5vWV0wEl(kJw0w6Wb7lecgUHOCnCbqBqQh77wvuxiNgIY1pbaPMEnni1JyvjgF5cmLe3q9r)WYcov5J9LBuMSHLf4J5BCt7eDbstMnmkARw7oecgUHOCnCbqBqQhXQsm(YfykjUH6J(HLfeiLESVCJYKnSSaFmFJBANOlqAYSHrrFSBvGG4zE1nLBikx)cRyES7(KaaYvvfDtqvpdKn(kGE25kwT2xUrzYMn0ykaFmFikx3KzdJIUhRwLaaYvvfDtqvpdKn(kGE25khtGphiztqvpdKn(kGE25kTBvrDHCAabD9bhOGkRKv6rTecbd3SHgtb4J5dr56gKAp9y1A3HqWWneLRHlaAds9yUrzYgwwGpMVXnTt0finz2WOO7HSyVPxdUD1yfgmW3ngF7n9AErhNwolQemb(CGKyYI9MEn42vJvyWaRfSQa2uEQG9SaS0HdAlBmTBQ3mqbdiNKSGSORDLyfDXjXDGThfIv0fN(ys8EtVgCJydjjEtITDtBbqSkWlGNNjolIX2fij(6GlKNe7tkaaKAs8TgTNEnyIRHyfOpAInKfe4tmUNjl6kX9hleBilWhtIp0nTt0fie7WeFUGigPhJeB7jXYuqM2eNlWusmX7OjUZfsbqCaAGHWEneVJM4owUgUaOeVaH4PsIbYQpBjXfG4SigiWabBtSrheWDM4AiorwexaIrlGqCUatjXnYI9MEn42f5niwwGpMVXnTt0fiwcHLhsBpkV7ItFmdQSL3Z3O8YfykjoOYw6Wb7gXc8nmknSSaFmFJBANOlqExOSGHp2hIf4ByuAQvfFWf4D14ESATBDLnS9QlKpKfq)uxFAabgiy7nmkhXQsm(YfykjUH6J(HLfCQY9qw0vInSlqsSI6GlKNeBilWhtIp0nTt0fieFRr7PxdXzr8bIOsSrheWDMyivI9H4oSobKf7n9AWTlYRcdgySSaFmFJBANOlqSeclpK2EuE3fN(yguzlVNVr5LlWusCqLT0HdMBuMSHLf4J5BCt7eDbstMnmk6J6kBy7vxiFilG(PU(0acmqW2ByuoIvLy8LlWusCd1h9dll4uLsw0vIRjE(DrEjgDpqWeN2cX7n9AiUM4zIHWByuiwdb8XK4R9oJe9XK4D0epvs8IjEjgiMqXfq8EtVMgzXEtVgC7I8QWGbg1h9lmU40YAINFxK3GktwqwS30Rb30OMVe4ZbsIdcHLNNcQLZIkb1l4a0QMNwUh8EQqjqWxzUczXEtVgCtJA(sGphijwHbdmewEEkOwolQeednHXQ0Vfvs7Z4KSyVPxdUPrnFjWNdKeRWGbgclppfulNfvcAgpRA)k43IXoQh30RHSyVPxdUPrnFjWNdKeRWGbgclppfulNfvcQbYQHDG8qiySejlil6AxjwbU(qCh25aQLeJTlOOM4BHqaeVXiXGDmfmXfmX5cmLet8oAIXxzwGxyYI9MEn4g66tW7gJV9MEnVOJtlNfvcgw1yPdhmecgUfw18k4xAlVfFLrl6gKkzXEtVgCdD9rHbdS2XQs8HUM(1shoyF5cmLS54NACplaYIUsC)XcXDSCnXNaaKA61qCneFRkQlKdXQvf9XK4njoklojwj6cX(G3XZZehcLepvsSdt85cIyKEmsCHqa3vLyFW745zI9H4oEInIvG7bcXyiGqm2E1fsyxgDGr9rhkJwaeVJMyfOpAIvCCXjXoM4Ai(wvuxihIdf4cie3XtaXomX9UXWvVamXfGyd7vxiHJlQqSJjwcaixvv0nIdqMtbeIvRk6JjXabNa)MEnyIDyIHW(ysSH9QlKWXfviUZahJs8oAIvSmAbqSJjUGYgzXEtVgCdD9rHbdmIY1pbaPMEnw6WbrSaFdJstTQ4dUaVRgFSBFW7455tdQeDXQvvjBWUm62EthHCeancCbmLg2E1fs44IkpvGJrBsaa5QQI(yF3QI6c50q9r)cJloBqQh77wvuxiNg2E1fYhYcOFAzt7gKAph72h8oEEoqb7NN0Q1CJYKnSSaFmFJBANOlqAYSHrrFeXc8nmknSSaFmFJBANOlqExOSGH75yF3QI6c50GDz0ni1JD33TQOUqonuF0VW4IZgKQvRyvjgF5cmLe3q9r)WYcovPwT2haAe4cyknS9QlKWXfvEQahJ2KaaYvvf9X(aqJaxatPLBmC1la)WjyZ1uqBsaa5QQIUNJD3hUGIH(OBiQ4MEuE4kIqM0Q1qiy4gIkUPhLhUIiKjBqQwTILm9Xe3CZPaYdxreYK9qw0vIvG7bcXyiGq85cIyvOKyivIn6GaUZe3HgDyNjUgItBH4CbMssSdtCha20ggks8jUcWfID8OGjX7nDecXiTLHyy30o9XKyLvK7xIZfykjUrwS30Rb3qxFuyWaJTxDH8HSa6N66JLoCWqiy4g8kptOfO9DWni1J9PLqiy4gsWM2WqXh8kaxAqQhXQsm(YfykjUH6J(HLfeiLGSyVPxdUHU(OWGb(UX4BVPxZl640YzrLGxnMSOReRi5M2e3zGxapptSc0hnXgYciEVPxdXzrmqGbc2M4ov9IjgPN2eJLf4J5BCt7eDbczXEtVgCdD9rHbdmQp6hwwGL3Z3O8YfykjoOYw6WbZnkt2WYc8X8nUPDIUaPjZggf9rSQeJVCbMsIBO(OFyzbNIyb(ggLgQp6hwwW7cLfm8X(0v2W2RUq(qwa9tD9PL(9aFmp23TQOUqonyxgDdsLSORe3zGalaIZIyiSqCNw0ztVgI7qJoSZe7WeVZzI7u1lXoM4PsIHuBKf7n9AWn01hfgmW6fD20RXY75BuE5cmLehuzlD4G9Hyb(ggL2gJpDL4hKkzrxjU)yHyd7vxijUdkGM4ojBAtSdtme2htInSxDHeoUOcXDg4yuI3rtCOmAbqmspgjwueQoqiwdb8XK40wiEefrsS5v3il2B61GBORpkmyGX2RUq(qwa9tlBABPdhuvYgSlJUT30rihbqJaxatPHTxDHeoUOYtf4y0MeaqUQQOpQkzd2Lr3ac66doqbnVAYIUsChgrUNXedHfIr9rhgxCIj2Hj(UQQIM4D0eBdnMcWhtIruUMyhtmKkX7Ojgc7JjXg2RUqchxuH4odCmkX7OjougTai2XedP2iM4ouR90RzJXZws8DXjXO(OdJloj2Hj(CbrmYckQjouigA2WOqCweBkjXPTqmWHtIdptmY1tFmjEj28QBKf7n9AWn01hfgmWO(OFHXfNw6Wb7(wvuxiNgQp6xyCXz7AVatbFQYh7wlHqWWnBOXua(y(quUUbPA1AF5gLjB2qJPa8X8HOCDtMnmk6ESAvvYgSlJUbe01hCGcExC(shvuO5v3ZrvjBWUm62EthHCeancCbmLg2E1fs44IkpvGJrBsaa5QQI(OQKnyxgDdiORp4tVloFPJkKfDL4(JfI7y5AIvCftI3KyB30waeRc8c45zIr6PnXksqJPa8XK4owUMyivIZIyLG4CbMsITK4cqCL2cG4CJYKyIRHyJEBKf7n9AWn01hfgmWikx)cRyAPdh0h8oEEoqb7NN8yUrzYMn0ykaFmFikx3KzdJI(yUrzYgwwGpMVXnTt0finz2WOOpIvLy8LlWusCd1h9dlliqbvYwT2D35gLjB2qJPa8X8HOCDtMnmk6J9LBuMSHLf4J5BCt7eDbstMnmk6ESAfRkX4lxGPK4gQp6hwwqqL7HSORe3PAuWKyiSqCNeefeWhtI7CCnHeIDyIpxqeF3Hytjj2NSiUJLRHlakX(Gtz1wsCbi2Hj2qwGpMeFOBANOlqi2XeNBuMu0eVJMyKEmsSTNeltbzAtCUatjXnYI9MEn4g66JcdgyTGOGa(y(uJRjKyPdhSBGadeS9ggfRw9bVJNNpnGCsRwVvf1fYPHOC9llaqMSbe01hCGc2VkaMxDph7UpelW3WO0uRk(GlW7QXwT6dEhppFAW(5j75y39LBuMSHLf4J5BCt7eDbstMnmkARw7o3OmzdllWhZ34M2j6cKMmByu0h7dXc8nmknSSaFmFJBANOlqExOSGH7PhYIUsC)XcXDuXexdXkANi2Hj(CbrSUgfmjEertCweFxCsCNeefeWhtI7CCnHeljEhnXPTaeIxGqCuWyIt7DiwjioxGPKyIlOK4UpjXi90M4BnAip7PrwS30Rb3qxFuyWaJOC9lSIPLoCqSQeJVCbMsIBO(OFyzbbQBLqH3A0qE20ogxZo5tU2LGBYSHrr3ZrFW7455afSFEYJ5gLjByzb(y(g30orxG0KzdJI2Q1(Ynkt2WYc8X8nUPDIUaPjZggfnzrxjU)yHyd7vxijUdkGoGjUtYM2e7WeN2cX5cmLKyht8gwqjXzrS2fIlaXNliITxecXg2RUqchxuH4odCmkXsaa5QQIMyKEAtSc0hDOmAbqCbi2WE1fsyxgnX7nDesJSyVPxdUHU(OWGbgBV6c5dzb0pTSPTL3Z3O8YfykjoOYw6Wb7oxGPKnBzJPDt9MbsPD5iwvIXxUatjXnuF0pSSGaPe9y1A3Qs2GDz0T9Moc5iaAe4cyknS9QlKWXfvEQahJ2KaaYvvfDpKfDL4(JfInGaaz0cG4SiwbU6rWyIRH4L4CbMssCAVjXoMyZYhtIZIyTleVjXPTqmWnTtIthvAKf7n9AWn01hfgmWyiaqgTaEz9qx9iySL3Z3O8YfykjoOYw6WbZfykzlDu5L1t7sGu6jpgcbd3quUgUaOnDHCil6kX9hle3XY1e3BbaYKext8mXomXgDqa3zI3rtCh7L4fieV30rieVJM40wioxGPKeJSgfmjw7cXAiGpMeN2cXx7Dgj2il2B61GBORpkmyGruU(LfaitA598nkVCbMsIdQSLoCqelW3WO00vIFqQh7oecgUHOCnCbqB6c5y1AiemCdr5A4cG2ac66doq3QI6c50quU(fwXSbe01hSvRQabXZ8QBk3quU(fwX8yFHqWWTWyv6ieoBazV5rSQeJVCbMsIBO(OFyzbbQF754EthH80v2qSOQoWVVSGU2Ng8E(gLNmcQl4JyvjgF5cmLe3q9r)WYccu3NuHDRKvaYnkt2sKooFf8dEtPjZggfDp9qwS30Rb3qxFuyWaJ6JougTaS0HdQRSHyrvDGFFzbDTBPFpWhZJDNBuMSHLf4J5BCt7eDbstMnmk6JyvjgF5cmLe3q9r)WYcofXc8nmknuF0pSSG3fklyyRw1v2W2RUq(qwa9tD9PL(9aFm75y39bGgbUaMsdBV6cjCCrLNkWXOnjaGCvvrB16EthH80v2qSOQoWVVSGU2Ng8E(gLNmcQl4Eil6kX9hleB0bbCNigPN2e351NqGShiaI7mEJOednrbJjoTfIZfykjXi9yK4qH4qjwijwPDPFiIdf4cieN2cX3QI6c5q8TqfmXH79GgzXEtVgCdD9rHbdm2E1fYhYcOFAztBlD4GaOrGlGP0uxFcbYEGaEQ4nI2KaaYvvf9relW3WO00vIFqQhZfykzlDu5L1t9MpL2Lt7(wvuxiNg2E1fYhYcOFAzt7MgcSPxJcnV6Eil6kX9hleByV6cjXkkyX2exdXkANigAIcgtCAlaH4fieVAnMyFUfQpMnYI9MEn4g66JcdgyS9QlKVlyX2w6WbbRRFcczY2Q14MpNQCxil6pwiwb6JMydzbeNfX3AWqOcXDAbhqCV2fKPDIjwfuxmX1qChgGpbnI7na3PamXkAnWoaLyhtCA7yIDmXlX2UPTaiwf4fWZZeN27qmq0vM(ysCne3Hb4taXqtuWyI1l4aIt7cY0oXe7yI3WckjolIthviUGsYI9MEn4g66JcdgyuF0pSSalVNVr5LlWusCqLT0HdIvLy8LlWusCd1h9dll4uelW3WO0q9r)WYcExOSGHpgcbd30l4GxAxqM2zds1YR96tqLT0Nuaai185OOI23ucQSL(KcaaPMphoy63dWNgujil6kX9hleRa9rt8jg3ZeNfX3AWqOcXDAbhqCV2fKPDIjwfuxmX1qSrVexqj21cXfmXD8eBe3BaUtbyIv0AGDakXomXPTJj2XeVeB7M2cGyvGxapptCAVdXarxz6JjXqtuWyI1l4aIt7cY0oXe7yI3WckjolIthviUGsYI9MEn4g66JcdgyuF0p44E2shoyiemCtVGdEPDbzANni1JiwGVHrPPRe)Gup2xiemCdr5A4cG2GuT8AV(euzl9jfaasnFokQO9nLGkBPpPaaqQ5ZHdM(9a8PbvIJ9fcbd30l4GxAxqM2zdsLSORe3FSqSc0hnXkoU4KyhM4ZfeX6AuWK4renXzrmqGbc2M4ov9IBeBKLkX3fN(ys8MeReexaIrlGqCUatjXeJ0tBInKf4JjXh6M2j6ceIZnktkAI3rt85cI4fiepvsme2htInSxDHeoUOcXDg4yuIlaXDgF(A7xIdO(CqdRkX4lxGPK4gQp6hwwWP9JpjXMsIjoTfIr9XrHqjUGj(KeVJM40wiEGqdfaXfmX5cmLe3iUdJ4YsI1fXtLeRcemMyuF0HXfNednPhjEJrIZfykjM4fieRRmfnXi90M4o2lXiTLHyiSpMeJTxDHeoUOcXQahJsSdtCOmAbqSJjErSECdJsJSyVPxdUHU(OWGbg1h9lmU40shoiIf4ByuA6kXpi1JG11pbHmzdTqiOYKnFo9U48LoQOWU0o5rSQeJVCbMsIBO(OFyzbbQBLqHkvbi3Omzd1Xc4CtMnmkAfU30ripDLnelQQd87llORTcqUrzYMk(812VVOph0KzdJIwHDJvLy8LlWusCd1h9dll40(XNShfGUvLSb7YOB7nDeYra0iWfWuAy7vxiHJlQ8ubogTjbaKRQk6E65y39bGgbUaMsdBV6cjCCrLNkWXOnjaGCvvrB1AF3QI6c50GDz0ni1JaOrGlGP0W2RUqchxu5PcCmAtcaixvv0wTU30ripDLnelQQd87llOR9PbVNVr5jJG6cUhYI9MEn4g66JcdgyelQQd87llORTL3Z3O8YfykjoOYw6WbbcmqW2ByuoMlWuYw6OYlRN2LtvYwT2DUrzYgQJfW5MmByu0h1v2W2RUq(qwa9tD9PbeyGGT3WO0JvRHqWWnObgce9X8PxWbJGXnivYIUsSHQC9ns8TgTNEneNfX4Suj(U40htIn6GaUZexdXfmSICUatjXeJ0wgIHDt70htI7xIlaXOfqigN79artmAfIjEhnXqyFmjUZ4ZxB)sCa1NdiEhnXhgG7LyfOJfW5gzXEtVgCdD9rHbdm2E1fYhYcOFQRpw6WbbcmqW2ByuoMlWuYw6OYlRN2LtvIJ9LBuMSH6ybCUjZggf9XCJYKnv85RTFFrFoOjZggf9rSQeJVCbMsIBO(OFyzbNQuYIUs8jSiQeB0bbCNjgsL4AiEXeJUZzIZfykjM4ftSAHXEyuSKyrrCf1KyK2YqmSBAN(ysC)sCbigTacX4CVhiAIrRqmXi90M4oJpFT9lXbuFoOrwS30Rb3qxFuyWaJTxDH8HSa6N66JL3Z3O8YfykjoOYw6WbbcmqW2ByuoMlWuYw6OYlRN2LtvIJ9LBuMSH6ybCUjZggf9X(6o3OmzdllWhZ34M2j6cKMmByu0hXQsm(YfykjUH6J(HLfCkIf4ByuAO(OFyzbVluwWW9CS7(Ynkt2uXNV2(9f95GMmByu0wT2DUrzYMk(812VVOph0KzdJI(iwvIXxUatjXnuF0pSSGafuP90dzXEtVgCdD9rHbdmQp6hwwGL3Z3O8YfykjoOYw6WbXQsm(YfykjUH6J(HLfCkIf4ByuAO(OFyzbVluwWWh7UpCbfd9r3quXn9O8WveHmPvR9DRkQlKtdoky7lyHZgKApwETxFcQSL(KcaaPMphfv0(MsqLT0Nuaai185Wbt)Ea(0GkLSyVPxdUHU(OWGbg1h9doUNT8AV(euzl9jfaasnFokQO9nLGkBPpPaaqQ5ZHdM(9a8Pbv6XU7lecgUPxWbV0UGmTZgKQvR3QI6c50quU(fwXSbP2JLoCW(Wfum0hDdrf30JYdxreYKwT23TQOUqon4OGTVGfoBqQKfDL4(JfIpXOGTVGfojUGsSRfIlyIrxFi(wvuxihmXzrm66tU(qChR4MEui2OIiKjjoecgUrwS30Rb3qxFuyWadhfS9fSWPLoCqCbfd9r3quXn9O8WveHm5X(cHGHBikxdxa0gK6X(cHGHBQfsb88bgc710GuT0Nuaai185OOI23ucQSL(KcaaPMphoy63dWNguzYIUsC)XcXgDqa3jIxmXXfNedeCbsIDyIRH40wigTqiKf7n9AWn01hfgmWy7vxiFilG(PLnTjl6kX9hleB0bbCNjEXehxCsmqWfij2HjUgItBHy0cHq8oAIn6GaUte7yIRHyfTtKf7n9AWn01hfgmWy7vxiFilG(PU(qwqw0vI7pwiUgIv0orChA0HDM4Si2usI7u1lXPFpWhtI3rtSOiuDGqCweh9rigsL4qjtbqmspTjUJLRHlakzXEtVgClb(CGK4Gqy55PGA5SOsqbv9mq24Ra6zNRyPdh8wvuxiNgIY1pbaPMEnnGGU(GduqLvQvR3QI6c50quU(jai10RPbe01h8PknGqw0vI7fCM4Si248Cjoa1pQteJ0tBI7ubfgfInY9EGOjwr7eMyhMy1cJ9WO0ioapehRXuaed7M2jMyKEAtmAbeIdq9J6eXqybt8MPGQMeNfX4ZZLyKEAt8oNj(QjUaeFcbHtIHWcXE2il2B61GBjWNdKeRWGbgclppfulNfvc6d(cGYnmkVaaANec9Pfe(vS0Hdgcbd3quUgUaOni1JHqWWn1cPaE(adH9AAqQwTgwy8ry30oFabD9bhOGkTlwTgcbd3ulKc45dme2RPbPE8wvuxiNgIY1pbaPMEnnGGU(GvOYN8uy30oFabD9bB1AiemCdr5A4cG2GupERkQlKttTqkGNpWqyVMgqqxFWku5tEkSBANpGGU(GTAT7BvrDHCAQfsb88bgc710ac66d(0Gk3LJ3QI6c50quU(jai10RPbe01h8PbvUl9Ce2nTZhqqxFWNguzL0Uqw0vInopxInSfjjwbcH9lXi90M4owUgUaOKf7n9AWTe4ZbsIvyWadHLNNcQLZIkbr37gcKh2wK8HcH9RLoCWBvrDHCAikx)eaKA610ac66d(uL7czrxj248CjUFau4zIr6PnXDUqkaIdqdme2RHyi8Akwsm6EGqmgcieNfX4XvfItBH4yHuWjXksDM4CbMs2iUdSLHyiSOjgPN2eByV6cPOjoadcjUGjU3cGktAjXNqq4KyiSqCneRODI4ftmk01M4ftSAHXEyuAKf7n9AWTe4ZbsIvyWadHLNNcQLZIkbXfumkz6J5dafE2Y75BuE5cmLehuzlD4GHqWWn1cPaE(adH9AAqQwT2NkWfC2Wse(PwifWZhyiSxJvRsaa5QQIUHTxDHu0Vce(k4xwauzsYIUsC)XcXkE1McX(GDTqCbtChprIHlaXPTqmSdWjXqyH4cqCneRODI4fofaXPTqmSdWjXqyPrSHDbsIVo4c5jXomXikxtSaGutVgIVvf1fYHyhtSYDbtCbigTacXlY9CJSyVPxdULaFoqsScdgyiS88uqTCwuji2hyO4ZmUAFZcGFHR2uEf8dwa11ZZw6WbVvf1fYPHOC9taqQPxtdiORp4tdQCxil6kX9hleByV6cPOjoadcjUGjU3cGktsmsBziEQKyFiUJLRHlaQLexaI9H4qjrkYqChlxtSIRys8DXjMyFiUJLRHlaAJ4oet8j8zGVdXfG4dLlOIfqtC0hHypjgsLyKEAtmo37bIM4BvrDHCWnYI9MEn4wc85ajXkmyGHWYZtb1YzrLGy7vxif9RaHVc(LfavM0sho4TQOUqon1cPaE(adH9AAabD9bhOGk3LJ3QI6c50quU(jai10RPbe01hCGcQCxo29TqiZozBKlOIfqB16TqiZoz7GZaFNESAT7BHqMDYgczs7ZaRwVfcz2jBJBANp4v65y39fcbd3quUgUaOnivRwvbcIN5v3uUHOC9lSIzpwTgwy8ry30oFabD9bhOGkrxilil6kX9hlehDCsCbtCnkYqyHy9IUMcXjWNdKetCnXZe7WeRibnMcWhtI7y5AI7KecbdtSJjEVPJqSK4cq85cI4fiepvsCUrzsrtSpzrSNnYI9MEn4wc85ajXkmyGVBm(2B618IooTCwujOg18LaFoqsSLoCWU7l3OmzZgAmfGpMpeLRBYSHrrB1QwcHGHB2qJPa8X8HOCDdsTNJDhcbd3quUgUaOnivRwVvf1fYPHOC9taqQPxtdiORp4tvUl9qw0vI7KaVqXKy4ngd37bedxaIHWByui2tbfhWe3FSqCneFRkQlKdX(qCb0cG4WZeNaFoqsIXXkBKf7n9AWTe4ZbsIvyWadHLNNck2shoyiemCdr5A4cG2GuTAnecgUPwifWZhyiSxtds1Q1BvrDHCAikx)eaKA610ac66d(uL7Y3aRk3)Hk9K9ZF(Z)ha]] )
    

end
