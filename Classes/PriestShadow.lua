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
        gladiators_medallion = 3476, -- 208683
        adaptation = 3477, -- 214027
        relentless = 3478, -- 196029

        void_shift = 128, -- 108968
        hallucinations = 3736, -- 280752
        psychic_link = 119, -- 199484
        void_origins = 739, -- 228630
        mind_trauma = 113, -- 199445
        edge_of_insanity = 110, -- 199408
        driven_to_madness = 106, -- 199259
        pure_shadow = 103, -- 199131
        void_shield = 102, -- 280749
        psyfiend = 763, -- 211522
        shadow_mania = 764, -- 280750
    } )


    spec:RegisterTotem( "mindbender", 136214 )
    spec:RegisterTotem( "shadowfiend", 136199 )

    do
        -- Shadowfiend/Mindbender "down" is the opposite of other spec pets.
        local mt_pet_fiend = {
            __index = function( t, k )
                local fiend = state.talent.mindbender.enabled and "mindbender" or "shadowfiend"

                if k == "down" then
                    return state.cooldown[ fiend ].down
                end

                return state.pet[ fiend ][ k ]
            end
        }

        state.summonPet( "fiend" )
        setmetatable( state.pet.fiend, mt_shadowpriest_pet )
    end




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

            --[[ if spellName == "Shadow Word: Pain" and ( subtype == "SPELL_DAMAGE" or subtype == "SPELL_PERIODIC_DAMAGE" ) then
                local name, id, _, aType, duration, expiration = FindUnitDebuffByID( "target", class.auras.shadow_word_pain.id )
                -- print( name, id, _, aType, duration, applied )
                if expiration then print( "SWP", subtype, duration, ( GetTime() - ( expiration - duration ) ) / class.auras.shadow_word_pain.tick_time, ( expiration - GetTime() ) / class.auras.shadow_word_pain.tick_time ) end
            end

            if spellName == "Shadow Word: Pain" and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" ) then
                swp_applied = GetTime()
            end ]]
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
            summonPet( "fiend", buff.mindbender.remains )
        elseif pet.shadowfiend.active then
            applyBuff( "shadowfiend", pet.shadowfiend.remains )
            buff.shadowfiend.applied = action.shadowfiend.lastCast
            buff.shadowfiend.duration = 15
            buff.shadowfiend.expires = action.shadowfiend.lastCast + 15
            summonPet( "fiend", buff.shadowfiend.remains )
        end

        if talent.mindbender.enabled then
            cooldown.fiend = cooldown.mindbender
        else
            cooldown.fiend = cooldown.shadowfiend
        end

        if buff.voidform.up then
            state:QueueAuraExpiration( "voidform", ExpireVoidform, buff.voidform.expires )
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
            cast = 1.5,
            cooldown = 45,
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
                if buff.dark_thought.up and ( buff.casting.v1 == class.abilities.mind_flay.id or buff.casting.v1 == class.abilities.mind_sear.id ) then return true end
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
                summonPet( "fiend", 15 )
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
                        power = power + 7.5 * min( debuff.shadow_word_pain.remains, 6 ) / 6
                        if debuff.shadow_word_pain.remains < 6 then removeDebuff( "shadow_word_pain" )
                        else debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires - 6 end
                    end
                    if debuff.vampiric_touch.up then
                        power = power + 7.5 * min( debuff.vampiric_touch.remains, 6 ) / 6
                        if debuff.vampiric_touch.remains < 6 then removeDebuff( "vampiric_touch" )
                        else debuff.vampiric_touch.expires = debuff.vampiric_touch.expires - 6 end
                    end
                    if power > 0 then gain( power, "insanity" ) end
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
            end,

            range = 15,

            auras = {
                unholy_transfusion = {
                    id = 324724,
                    duration = function () return conduit.festering_transfusion.enabled and 17 or 15 end,
                    max_stack = 1,
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

            handler = function ()
                applyBuff( "fae_guardians" )
                summonPet( "wrathful_faerie" )
                applyDebuff( "target", "wrathful_faerie" )
                summonPet( "guardian_faerie" )
                applyBuff( "guardian_faerie" )
                summonPet( "benevolent_faerie" )
                applyBuff( "benevolent_faerie" )
                -- TODO: Check totem/guardian API re: faeries.
            end,

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
            }
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
                    duration = function () return conduit.shattered_perceptions.enabled and 7 or 5 end,
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

        potion = "potion_of_phantom_fire",

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


    spec:RegisterPack( "Shadow", 20210117.1, [[de1bKbqivfEevixsvvrytksFsvjmkIKtrKAvQQQsVsvPMfc6wQQQIDjXVqaddHYXuvzzQk6zQkrtdHQUMIO2MQQsFtvvLXHquNtvjH1PQKAEkICpcSpfHdIqkluvvEivOAIieUOQQcBKku6JQkjAKuHIoPQssRee9sQqbntesv3eHi7KkYprivgkcuhvvvr0sPcf6PiAQubxfHkBfHKVIaPXsfkWEL0FvyWkDyHftLESQmzKUmQndXNj0OvuNM0QvvvuVMkQztv3gs7wQFRYWjQJJaXYbEoutx01b12bPVtqJxvvvDEqy9QQksZNi2pLR)QoujPrYvN(KyF(Jy)(9FLpj2N)(r8vYeczUskhpNdrUs2bkxjjNd6jSskhq4VGwDOsIpyWJRKZzkJ)AcqarnNHDlVdLayff2hPE9deijbWk6Javsxy1NF1U6wjPrYvN(KyF(Jy)(9FLpj2N)(9zLmGZ5dujjvuhVsoRuk3v3kjLXVkPJSLCoONqBjyGY40G0r2cz0WbacB)9FeA7Ne7ZFgKgKoYwheYHZ2suNsT1Hda4oTv4m32MbqKtBFhCNyBdaBlYbEmTuj9koXvhQKYa(DOUrwDO60VQdvsUdxptR)vjFanzGgvsaJgAJTDs2(LeJyvY4L61vs5tidgcpaDGCGutykxZQtFwDOsYD46zA9Vk5dOjd0Os(HTUWiif8CqpHihaTalxjJxQxxjXZb9eICa0AwD6lRouj5oC9mT(xL8b0KbAuj1ghTMquOmI(002jS93KRKXl1RRKb4fnpYda4oRz1jIV6qLK7W1Z06FvYtUsI5SsgVuVUscnaA465kj0WdZvYpRKqdWOduUsIQnDG5amEW5HGuZQttU6qLmEPEDLeAGkRa9nYd(nxj5oC9mT(xnRzLKIkosG2oZjU6q1PFvhQKChUEMw)Rs2bkxjPbWz076bLFopgYWjGXpUFCLmEPEDLKgaNrVRhu(58yidNag)4(X1S60NvhQKChUEMw)Rs2bkxjXWTR)o6iq5CgcCwjJxQxxjXWTR)o6iq5CgcCwZQtFz1Hkj3HRNP1)QKDGYvsrpeYZJdzeySIQ(i1RRKXl1RRKIEiKNhhYiWyfv9rQxxZQteF1Hkj3HRNP1)QKDGYvskGdkIc4bugJzFLmEPEDLKc4GIOaEaLXy2xZAwjrdTRouD6x1Hkj3HRNP1)QKpGMmqJkPlmcsX9UECiJCMhb(XnLPfy5kjob6lRo9RsgVuVUs(cVFeVuVE4vCwj9kohDGYvs376AwD6ZQdvY4L61vsQILz)ane1xLK7W1Z06F1S60xwDOsYD46zA9Vk5dOjd0OscnaA465I8D(bYbgpk22P2QnoAnHW2jeylXtmBNARu2QnoAnHW2jjWwI8KTvIeBZWZDwWCa0wC0Q4CIgaUWD46zQTtTfAa0W1ZfmhaTfhTkoNObGhp48qqSvABNA7h2(UZtpHDbr5MwGLTDQTsz7h2(UZtpHDbvB6W1h4SalBRej2ILzVFKbqKtCbvB6aZbW2jS9tBLUsgVuVUsc9u6GbWYPEDnRor8vhQKChUEMw)Rs(aAYanQKUWiifKGhIWbGQrJlWY2o12pSLYUWiifHGiNrG9dKGbkxGLRKXl1RRK45GEchcpaDihAxZQttU6qLK7W1Z06FvY4L61vYx49J4L61dVIZkPxX5OduUs(O4AwD6FRouj5oC9mT(xLmEPEDLevB6aZbOs(aAYanQKz45olyoaAloAvCordax4oC9m12P2ILzVFKbqKtCbvB6aZbW2jSfAa0W1ZfuTPdmhGXdopeeBNA7h2sVSGNd6jCi8a0HCODj1NZAlA7uB)W23DE6jSlik30cSCL8bXZZJmaICIRo9RMvN(VQdvsUdxptR)vjJxQxxjPbAhPEDL8b0KbAuj)WwObqdxpxcVFqVepGLRKpiEEEKbqKtC1PF1S6erU6qLK7W1Z06FvYhqtgOrLuBC0AcHTtsGTe5jB7uBZWZDwMHBrgOT4a6P0c3HRNP2o12m8CNfmhaTfhTkoNObGlChUEMA7uBXYS3pYaiYjUGQnDG5ay7Key7)ARej2kLTszBgEUZYmClYaTfhqpLw4oC9m12P2(HTz45olyoaAloAvCordax4oC9m1wPTvIeBXYS3pYaiYjUGQnDG5ayRaB)zR0vY4L61vsONshUNpRz1PVIQdvsUdxptR)vjFanzGgvsPSfWiagphUE2wjsSvBC0AcHTty7)nzBL22P2kLTFyl0aOHRNlY35hihy8OyBLiXwTXrRje2oHaBjYt2wPTDQTsz7h2MHN7SG5aOT4OvX5enaCH7W1ZuBLiXwPSndp3zbZbqBXrRIZjAa4c3HRNP2o12pSfAa0W1ZfmhaTfhTkoNObGhp48qqSvABLUsgVuVUsszOhmqBXHSpeH5AwD6hXQouj5oC9mT(xL8b0KbAujXYS3pYaiYjUGQnDG5ay7KSvkBjEB)2231uynlufJVo6CWV5JXfUdxptTvABNAR24O1ecBNKaBjYt22P2MHN7SG5aOT4OvX5enaCH7W1ZuBLiX2pSndp3zbZbqBXrRIZjAa4c3HRNPvY4L61vsONshUNpRz1PF)Qouj5oC9mT(xLmEPEDLeph0t4q4bOdkh5CL8b0KbAujLY2maICwM5WNZf5xA7KS9tIz7uBXYS3pYaiYjUGQnDG5ay7KSL4TvABLiXwPSvMZcIYnTeVuHY2o1waCZihqKl45GEcr8bkpKbkgTWeeyvwMP2kDL8bXZZJmaICIRo9RMvN(9z1Hkj3HRNP1)QKXl1RRKyyaGBkdg5nqdAZyCL8b0KbAujZaiYzjvuEK3GQSTtY2pNSTtT1fgbPa9ukYbql0tyxjFq888idGiN4Qt)Qz1PFFz1Hkj3HRNP1)QKXl1RRKqpLoYda4oRKpGMmqJkj0aOHRNl0lXdyzBNABgarolPIYJ8guLTDcB)sBNARu26cJGuGEkf5aOf6jSTvIeBDHrqkqpLICa0cGrdTX2ojBF35PNWUa9u6W98zbWOH2yBL22P2gVuHYd6LfObQSc03ip43STcSflZE)idGiN4c0avwb6BKh8B22P2ILzVFKbqKtCbvB6aZbW2jzRu2ozB)2wPS9FT9)12m8CNLuOIZXHmqIKlChUEMAR02kDL8bXZZJmaICIRo9RMvN(r8vhQKChUEMw)Rs(aAYanQK0llqduzfOVrEWV5sQpN1w02P2kLTz45olyoaAloAvCordax4oC9m12P2ILzVFKbqKtCbvB6aZbW2jSfAa0W1ZfuTPdmhGXdopeeBLiXw6Lf8CqpHdHhGoKdTlP(CwBrBLUsgVuVUsIQn1LBkdQz1PFtU6qLK7W1Z06FvYhqtgOrLea3mYbe5ICOTlGdNzWqghE0ctqGvzzMA7uBHganC9CHEjEalB7uBZaiYzjvuEK3q(LJpjMTtyRu2(UZtpHDbph0t4q4bOdkh5CHcdIuV22VTv8rTv6kz8s96kjEoONWHWdqhuoY5AwD63)wDOsYD46zA9Vk5dOjd0OsccLoyOCNLGsXfTTDcB)rSkz8s96kjEoONWXde45AwD63)vDOsYD46zA9Vkz8s96kjQ20bMdqL8bXZZJmaICIRo9RsQDYaaSCouKkzQpNXti4ZkP2jdaWY5qrrzQgjxj)vjFanzGgvsSm79JmaICIlOAthyoa2oHTqdGgUEUGQnDG5amEW5HGy7uBDHrqk0a48iNpyX5SalxjFZH2vYF1S60pIC1Hkj3HRNP1)QKXl1RRKOAthi(aIkP2jdaWY5qrQKP(CgpHGpN(UZtpHDb6P0H75ZcSCLu7Kbay5COOOmvJKRK)QKpGMmqJkPlmcsHgaNh58bloNfyzBNAl0aOHRNl0lXdy5k5Bo0Us(RMvN(9vuDOsYD46zA9Vk5dOjd0OscnaA465c9s8aw22P2ccLoyOCNf0dkJYDw022jS9f4CKkkB732sSYKTDQTszlwM9(rgaroXfuTPdmhaBNKTeVTtT9dBZWZDwqvmdGOWD46zQTsKylwM9(rgaroXfuTPdmhaBNKT)RTtTndp3zbvXmaIc3HRNP2kDLmEPEDLevB6W1h4SMvN(KyvhQKChUEMw)RsgVuVUscnqLvG(g5b)MRKpGMmqJkjGramEoC9STtTndGiNLur5rEdQY2oHT)RTsKyRu2MHN7SGQygarH7W1ZuBNAl9YcEoONWHWdqhYH2faJay8C46zBL2wjsS1fgbPa3iWaV2IdAaCUzmUalxjFq888idGiN4Qt)Qz1Pp)vDOsYD46zA9Vk5dOjd0OscyeaJNdxpB7uBZaiYzjvuEK3GQSTtylXB7uB)W2m8CNfufZaikChUEMA7uBZWZDwKXq8M13WRTZfUdxptTDQTyz27hzae5exq1MoWCaSDcB)SsgVuVUsINd6jCi8a0HCODnRo95NvhQKChUEMw)RsgVuVUsINd6jCi8a0HCODL8b0KbAujbmcGXZHRNTDQTzae5SKkkpYBqv22jSL4TDQTFyBgEUZcQIzaefUdxptTDQTFyRu2MHN7SG5aOT4OvX5enaCH7W1ZuBNAlwM9(rgaroXfuTPdmhaBNWwObqdxpxq1MoWCagp48qqSvABNARu2(HTz45olYyiEZ6B4125c3HRNP2krITszBgEUZImgI3S(gETDUWD46zQTtTflZE)idGiN4cQ20bMdGTtsGTFAR02kDL8bXZZJmaICIRo9RMvN(8lRouj5oC9mT(xLmEPEDLevB6aZbOs(G455rgaroXvN(vj1ozaawohksLm1NZ4je8zLu7Kbay5COOOmvJKRK)QKpGMmqJkjwM9(rgaroXfuTPdmhaBNWwObqdxpxq1MoWCagp48qqQKV5q7k5VAwD6tIV6qLK7W1Z06FvY4L61vsuTPdeFarLu7Kbay5COivYuFoJNqWNtF35PNWUa9u6W98zbwUsQDYaaSCouuuMQrYvYFvY3CODL8xnRo95KRoujJxQxxjXZb9eoeEa6GYroxj5oC9mT(xnRo95)wDOsgVuVUsINd6jCi8a0HCODLK7W1Z06F1SMvYNWx1HQt)Qouj5oC9mT(xLegZdHZQNhVaNAlwD6xLmEPEDLeZbqBXrRIZjAa4k5dINNhzae5exD6xL8b0KbAujLYwObqdxpxWCa0wC0Q4CIgaE8GZdbX2P2(HTqdGgUEUiFNFGCGXJITvABLiXwPSLEzbph0t4q4bOd5q7cGramEoC9STtTflZE)idGiN4cQ20bMdGTty7pBLUMvN(S6qLK7W1Z06FvsympeoREE8cCQTy1PFvY4L61vsmhaTfhTkoNObGRKpiEEEKbqKtC1PFvYhqtgOrLmdp3zbZbqBXrRIZjAa4c3HRNP2o1w6Lf8CqpHdHhGoKdTlagbW45W1Z2o1wSm79JmaICIlOAthyoa2oHTFwZQtFz1Hkj3HRNP1)QKx7Hy8e(QK)QKXl1RRKOAthU(aN1SMvYeOTZCIRouD6x1Hkj3HRNP1)QKXl1RRKmQmeao8Jdq7OFCL8b0KbAujF35PNWUa9u6GbWYPEDbWOH2yBNKaB)9PTsKy77op9e2fONshmawo1Rlagn0gB7e2(5)vj7aLRKmQmeao8Jdq7OFCnRo9z1Hkj3HRNP1)QKXl1RRKAJFa4mC98GGahDcJoOmu9XvYhqtgOrL8DNNEc7c0tPdgalN61faJgAJTDcB)rSkzhOCLuB8daNHRNhee4Oty0bLHQpUMvN(YQdvsUdxptR)vjJxQxxjrJx4c4bEM5CGcJ1xL8b0KbAujF35PNWUa9u6GbWYPEDbWOH2yBNW2FeRs2bkxjrJx4c4bEM5CGcJ1xnRor8vhQKChUEMw)Rs2bkxjXhS3ZzQT4aa7crL8bXZZJmaICIRo9Rs(aAYanQKUWiif5tidgAJaJ1RlWY2krITFyRmqzCwWShziFczWqBeySEDLmEPEDLeFWEpNP2IdaSle1S60KRouj5oC9mT(xLmEPEDLeRncSFi6dQg5bWd3GkYJdzGWG7PjevYhqtgOrL8DNNEc7c0tPdgalN61faJgAJTDcb2(JyvYoq5kjwBey)q0hunYdGhUbvKhhYaHb3ttiQz1P)T6qLK7W1Z06FvYhqtgOrLukB)W2m8CNLz4wKbAloGEkTWD46zQTsKylLDHrqkZWTid0wCa9uAbw2wPTDQTszRlmcsb6PuKdGwGLTvIeBF35PNWUa9u6GbWYPEDbWOH2yBNW2FeZwPRKXl1RRKVW7hXl1RhEfNvsVIZrhOCLKIkosG2oZjUMvN(VQdvsUdxptR)vjFanzGgvsxyeKc0tPihaTalBRej26cJGuKpHmyOncmwVUalBRej2(UZtpHDb6P0bdGLt96cGrdTX2oHT)iwLmEPEDLegZdnzuCnRzL8rXvhQo9R6qLK7W1Z06FvYhqtgOrLugOmoly2JmKpHmyOncmwV22P2kLTUWiifONsroaAbw2wjsS9dBXhS3vBAreCq5H2qvXdePEDH7W1ZuBNA7h2IpyVR20Y7qDJCGYunJuVUWD46zQTtT9DNNEc7c0tPdgalN61faJgAJTDcb2(Jy2krITiQ4CoamAOn22jz77op9e2fONshmawo1Rlagn0gBRej2IpyVR20Ii4GYdTHQIhis96c3HRNP2o1wPS1fgbPayQc4xY0r0kAuWz8C22jey7VpTvIeBF35PNWUGe8qeoaunACbWOH2yBNW2FeZwPTv6kz8s96kP8jKbdTrGX611S60NvhQKChUEMw)RsgVuVUsI1gb2pe9bvJ8a4HBqf5XHmqyW90eIk5dOjd0Os6cJGuGEkf5aOfyzBLiX2urzBNW2FeZ2P2kLTFy77GYD0zPvX5CGeSTsxj7aLRKyTrG9drFq1ipaE4gurECidegCpnHOMvN(YQdvsUdxptR)vjFanzGgvYpS1fgbPa9ukYbqlWY2o1wPS9dBF35PNWUa9u6ipaG7SalBRej2(HTz45olqpLoYda4olChUEMAR02krITUWiifONsroaAbw22P2kLT4d27QnTicoO8qBOQ4bIuVUWD46zQTsKyl(G9UAtlik7PJdz46pm(qXfUdxptTv6kz8s96kjsWdr4aq1OX1S6eXxDOsYD46zA9Vkz8s96kjQ2uXaLXvYhqtgOrLuBC0AcHTtY2VcIz7uBLYwPSfAa0W1ZLW7h0lXdyzBNARu2(HTV780tyxGEkDWay5uVUalBRej2(HTz45olZWTid0wCa9uAH7W1ZuBL2wPTvIeBDHrqkqpLICa0cSSTsB7uBLY2pSndp3zzgUfzG2IdONslChUEMARej2szxyeKYmClYaTfhqpLwGLTvIeB)WwxyeKc0tPihaTalBR02o1wPS9dBZWZDwWCa0wC0Q4CIgaUWD46zQTsKylwM9(rgaroXfuTPdmhaBNKTt2wPRKpiEEEKbqKtC1PF1S60KRouj5oC9mT(xL8b0KbAujLYwPS9dBbHshmuUZsqP4cSSTtTfekDWq5olbLIlAB7e2(jXSvABLiXwqO0bdL7SeukUay0qBSTtiW2Ft2wjsSfekDWq5olbLIluyqK612ojB)nzBL22P2kLTUWiif5tidgAJaJ1RlWY2krITV780tyxKpHmyOncmwVUay0qBSTtiW2FeZwjsS9dBLbkJZcM9id5tidgAJaJ1RTvABNARu2(HTz45olZWTid0wCa9uAH7W1ZuBLiXwk7cJGuMHBrgOT4a6P0cSSTsKy7h26cJGuGEkf5aOfyzBLUsgVuVUsc3ZNhIrFqJAwD6FRouj5oC9mT(xL8b0KbAuj)WwxyeKc0tPihaTalB7uB)W23DE6jSlqpLoyaSCQxxGLTDQTyz27hzae5exq1MoWCaSDcB)z7uB)W2m8CNfmhaTfhTkoNObGlChUEMARej2kLTUWiifONsroaAbw22P2ILzVFKbqKtCbvB6aZbW2jz7N2o12pSndp3zbZbqBXrRIZjAa4c3HRNP2o1wPSvgWqhIpA5xb6P0H75tBNARu2(HTmbbwLLzAHrLHaWHFCaAh9JTvIeB)W2m8CNLz4wKbAloGEkTWD46zQTsBRej2YeeyvwMPfgvgcah(XbOD0p22P2(UZtpHDHrLHaWHFCaAh9Jlagn0gB7Key7V)9tBNAlLDHrqkZWTid0wCa9uAbw2wPTvABLiXwPS1fgbPa9ukYbqlWY2o12m8CNfmhaTfhTkoNObGlChUEMAR0vY4L61vs376XHmYzEe4h3uMwZQt)x1Hkj3HRNP1)QKXl1RRKVW7hXl1RhEfNvsVIZrhOCLmbA7mN4AwZkP7DD1HQt)Qouj5oC9mT(xL8b0KbAujXYS3pYaiYjUGQnDG5ay7Key7xwjJxQxxjd8JBkthU(aN1S60NvhQKChUEMw)Rs(aAYanQKzae5SiuZzTjY2o1wSm79JmaICIlb(XnLPJ(Gg2oHT)SDQTyz27hzae5exq1MoWCaSDcB)z732MHN7SG5aOT4OvX5enaCH7W1Z0kz8s96kzGFCtz6OpOrnRzLKYibSpRouD6x1Hkz8s96kjw9C)4kj3HRNP1)Qz1PpRouj5oC9mT(xL8b0KbAujDHrqkqpLICa0cSSTsKyRlmcsr(eYGH2iWy96cSCLmEPEDLu(s96AwD6lRouj5oC9mT(xL8KRKyoRKXl1RRKqdGgUEUscn8WCLKEzbph0t4q4bOd5q7sQpN1w02P2sVSanqLvG(g5b)MlP(CwBXkj0am6aLRK0lXdy5AwDI4Rouj5oC9mT(xL8KRKyoRKXl1RRKqdGgUEUscn8WCLKEzbph0t4q4bOd5q7sQpN1w02P2sVSanqLvG(g5b)MlP(CwBrBNAl9YcLHEWaTfhY(qeMlP(CwBXkj0am6aLRKH3pOxIhWY1S60KRouj5oC9mT(xL8KRKyoRKXl1RRKqdGgUEUscn8WCLelZE)idGiN4cQ20bMdGTty7N2(TTUWiifONsroaAbwUscnaJoq5kjMdG2IJwfNt0aWJhCEii1S60)wDOsYD46zA9Vk5jxjXCwjJxQxxjHganC9CLeA4H5k57op9e2fONshmawo1RlWY2o1wPS9dBbHshmuUZsqP4cSSTsKyliu6GHYDwckfxOWGi1RTDscS9hXSvIeBbHshmuUZsqP4cGrdTX2oHaB)rmB)22jB7)RTszBgEUZYmClYaTfhqpLw4oC9m1wjsS9Dq5o6S4meanABL2wPTDQTszRu2ccLoyOCNLGsXfTTDcB)Ky2krITyz27hzae5exGEkDWay5uV22jey7KTvABLiX2m8CNLz4wKbAloGEkTWD46zQTsKy77GYD0zXziaA02kDLeAagDGYvs578dKdmEuCnRo9FvhQKChUEMw)Rs(aAYanQKUWiifONsroaAbwUsgVuVUsIOa21FhTMvNiYvhQKChUEMw)Rs(aAYanQKUWiifONsroaAbwUsgVuVUs6YamdCwBXAwD6RO6qLK7W1Z06FvYhqtgOrLelZE)idGiN4IxfNt84FgMkIYDA7ecS9tBLiXwPS9dBbHshmuUZsqP4c))vCITvIeBbHshmuUZsqP4I22oHT)3KTv6kz8s96kPxfNt84FgMkIYDwZQt)iw1Hkj3HRNP1)QKpGMmqJkPlmcsb6PuKdGwGLRKXl1RRKr)yCcc)4fEFnRo97x1Hkj3HRNP1)QKXl1RRKVW7hXl1RhEfNvsVIZrhOCL8j8vZQt)(S6qLK7W1Z06FvY4L61vsaCpIxQxp8koRKEfNJoq5kjAODnRznRKqzawVU60Ne7ZFe73V)RskmaT2I4kjbLO5y0PVQtFLFTT26WmBRIkFG0wKdy7xGgA)f2cyccScyQT4dLTnGZdnsMA7BoArgxmij61MT93x(1264haWVKP2Yee4WRje2(M5NZ2IaouB)cbc(cBZZ2VqWxyRu)()sxminijOenhJo9vD6R8RT1whMzBvu5dK2ICaB)Ihf)f2cyccScyQT4dLTnGZdnsMA7BoArgxmij61MT9F)ABD8RHYGKP2(fjqBN5S4yq5DNNEc7VW28S9lE35PNWU4yWxyRu)()sxmiDyMTf58(tO2I2gWGaBRqgW2cJzQTABBoZ2gVuV2wVItBDHtBfYa22(sBro4MAR22MZSTbLETT0id3aZFTbPT)p2cyQc4xY0r0kAyqAq(vrLpqYuBjY2gVuV2wVItCXGSskdoe1Zvshzl5CqpH2sWaLXPbPJSfYOHdae2(7)i02pj2N)miniDKToiKdNTLOoLARdhaWDARWzUTndGiN2(o4oX2ga2wKd8yAXG0G0r2(p()8dozQTUmYbyBFhQBK26YIAJl2s0EpwoX22x))mhaueyVTXl1RX2EThIIbz8s9ACrgWVd1nYVfqa5tidgcpaDGCGutyktOIiaWOH24j9LeJygKXl1RXfza)ou3i)wabWZb9eICaucvebF4cJGuWZb9eICa0cSSbz8s9ACrgWVd1nYVfqGa8IMh5baCNeQic0ghTMquOmI(0CIFt2GmEPEnUid43H6g53cia0aOHRNjSduwaQ20bMdW4bNhccHNSamNecn8WSGpniJxQxJlYa(DOUr(TacanqLvG(g5b)MniniDKTe8L61ydY4L61yby1Z9JniJxQxJfiFPEnHkIaxyeKc0tPihaTallrIlmcsr(eYGH2iWy96cSSbz8s9A83cia0aOHRNjSduwa9s8awMWtwaMtcHgEywa9YcEoONWHWdqhYH2LuFoRT4u6LfObQSc03ip43Cj1NZAlAqgVuVg)TacanaA46zc7aLfeE)GEjEalt4jlaZjHqdpmlGEzbph0t4q4bOd5q7sQpN1wCk9Yc0avwb6BKh8BUK6ZzTfNsVSqzOhmqBXHSpeH5sQpN1w0G0r2sMbiTfgRTOTKCa0w0wNuX5enaSTrA7x(TTzae5eB7bSL4)2wfXwioyBdaBR22suNsroaQbz8s9A83cia0aOHRNjSduwaMdG2IJwfNt0aWJhCEiieEYcWCsi0WdZcWYS3pYaiYjUGQnDG5amXNF7cJGuGEkf5aOfyzdshzRJFNNEcBBj4782subqdxptOTehMP2MNTY35T1LroaBB8sfAKAlAl0tPihaTyRJddaCNEiSfgZuBZZ231j482kCMBBZZ24Lk0izBHEkf5aO2kuZzB1(DOAlABqP4Ibz8s9A83cia0aOHRNjSduwG8D(bYbgpkMWtwaMtcHgEywW7op9e2fONshmawo1RlWYtL6dqO0bdL7SeukUallrciu6GHYDwckfxOWGi1RNKGFetIeqO0bdL7SeukUay0qB8ec(rSVN8)Ruz45olZWTid0wCa9uAH7W1ZujsEhuUJolodbqJwAPNkLuGqPdgk3zjOuCr7j(KysKGLzVFKbqKtCb6P0bdGLt96jemzPLijdp3zzgUfzG2IdONslChUEMkrY7GYD0zXziaA0sBqgVuVg)TacGOa21FhLqfrGlmcsb6PuKdGwGLniJxQxJ)wabCzaMboRTiHkIaxyeKc0tPihaTalBq6iBjomBlrVkoNFb2wiHPIOCN2Qi2MZmGTnaSTFA7bSf9aSTzae5etOThW2GsX2gaU)I0wSCiS1w0wKdyl6byBZ5OT9)MmUyqgVuVg)Tac4vX5ep(NHPIOCNeQicWYS3pYaiYjU4vX5ep(NHPIOCNti4tjsK6dqO0bdL7SeukUW)FfNyjsaHshmuUZsqP4I2t8FtwAdY4L614VfqGOFmobHF8cVNqfrGlmcsb6PuKdGwGLniJxQxJ)wabEH3pIxQxp8kojSduwWt4ZGmEPEn(Bbeaa3J4L61dVItc7aLfGgABqAq6iBjAemrVT5zlmMTv4m32(3DTThIT5mBlrd)4MYuBvSTXlvOSbz8s9ACX9UwqGFCtz6W1h4KqfrawM9(rgaroXfuTPdmhGjj4lniJxQxJlU31FlGab(XnLPJ(GgeQicYaiYzrOMZAtKNILzVFKbqKtCjWpUPmD0h0yIFtXYS3pYaiYjUGQnDG5amXVVZWZDwWCa0wC0Q4CIgaUWD46zQbPbPJS1XjcSbPJSL4WSTe8jKb2(vBeySETTc1C2wI6ukYbql26yEEQTihWwI6ukYbqT9DOm22dbX23DE6jSTvBBZz22M))PT)iMTy(DnfB7LZmqOIzBHXSTxB7JAlC7zm22CMTLGzFiEyBDaeAARJFOUrAlrIPAgPETTk22m8CNmLqBpGTkIT5mdyBfQEVT9L26Y2g9LZmWwI6uQT)daSCQxBBoRyBruX5SyqgVuVgxEuSa5tidgAJaJ1RjureidugNfm7rgYNqgm0gbgRxpvkxyeKc0tPihaTallrYh4d27QnTicoO8qBOQ4bIuVUWD46z60pWhS3vBA5DOUroqzQMrQxx4oC9mD67op9e2fONshmawo1Rlagn0gpHGFetIeevCohagn0gpP3DE6jSlqpLoyaSCQxxamAOnwIe8b7D1MwebhuEOnuv8arQxx4oC9mDQuUWiifatva)sMoIwrJcoJNZti43NsK8UZtpHDbj4HiCaOA04cGrdTXt8JyslTbPJSL4WSTKQN7hB71264eHT5zRm4E2sYYZW)t)cSTem4E(ans96IbPJSnEPEnU8O4VfqaS65(XeMbqKZHIiaa3mYbe5cMLNH)NIhYG75d0i1RlmbbwLLz6uPYaiYzrXJGsLijdGiNfk7cJGuEbo1wSa44LsBq6iBjomB7FbvKTvBSszBpeBjkhRTihW2CMTfrb40wymB7bS9ABDCIW2ajzGT5mBlIcWPTWyUylbvZzBDsfNtBDSbB785P2ICaBjkhBXGmEPEnU8O4Vfqaymp0KrjSduwawBey)q0hunYdGhUbvKhhYaHb3ttiiure4cJGuGEkf5aOfyzjssfLN4hXMk1hVdk3rNLwfNZbsWsBq6iBjomBRJnyB)kHdavJgB71264eHThCIvkB7HylrDkf5aOfBjomBRJnyB)kHdavJMITvBBjQtPiha1wfXwioyBNdOSTSMZmW2VsWbLT9R2qvXdePETThWwhRYEQThIT)5pm(qXfdY4L614YJI)wabqcEichaQgnMqfrWhUWiifONsroaAbwEQuF8UZtpHDb6P0rEaa3zbwwIKpYWZDwGEkDKhaWDw4oC9mvAjsCHrqkqpLICa0cS8uPWhS3vBAreCq5H2qvXdePEDH7W1ZujsWhS3vBAbrzpDCidx)HXhkUWD46zQ0gKoYwIdZ2sK0MkgOm2wHZCBB492(L2seNdyBdaBlSmH2EaBH4GTnaSTABlrDkf5aOfB)hnggW26yc3ImqBrBjQtP2QyBJxQqzBV22CMTndGiN2Qi2MHN7KPfBjZt2wyS2I2gPTt(BBZaiYj2wHAoBljhaTfT1jvCordaxmiJxQxJlpk(BbeavBQyGYycFq888idGiNyb)iureOnoAnHysFfeBQusbnaA465s49d6L4bS8uP(4DNNEc7c0tPdgalN61fyzjs(idp3zzgUfzG2IdONslChUEMkT0sK4cJGuGEkf5aOfyzPNk1hz45olZWTid0wCa9uAH7W1ZujsOSlmcszgUfzG2IdONslWYsK8Hlmcsb6PuKdGwGLLEQuFKHN7SG5aOT4OvX5enaCH7W1ZujsWYS3pYaiYjUGQnDG5amPjlTbPJSL4WSTexpFEiS1PdAy71264ebH2oFEQ2I26cugXdHT5zRWqtBroGTYNqgyR2iWy9ABpGTbLAlwoe24Ibz8s9AC5rXFlGaW985Hy0h0GqfrGus9biu6GHYDwckfxGLNccLoyOCNLGsXfTN4tIjTejGqPdgk3zjOuCbWOH24je8BYsKacLoyOCNLGsXfkmis96j9BYspvkxyeKI8jKbdTrGX61fyzjsE35PNWUiFczWqBeySEDbWOH24je8JysK8HmqzCwWShziFczWqBeySET0tL6Jm8CNLz4wKbAloGEkTWD46zQeju2fgbPmd3ImqBXb0tPfyzjs(WfgbPa9ukYbqlWYsBq6iBjomB71264eHTUWPTYa9aAQy2wyS2I2suNsT9FaGLt9ABruaoj0wfXwymtTvBSszBpeBjkhRTxBlPd2cJzBdKKb2g2c9uQ75tBroGTV780tyBlJGOpL7he2gn1wKdy7mClYaTfTf6PuBHLtfLTvrSndp3jtlgKXl1RXLhf)Tac4ExpoKroZJa)4MYucvebF4cJGuGEkf5aOfy5PF8UZtpHDb6P0bdGLt96cS8uSm79JmaICIlOAthyoat8B6hz45olyoaAloAvCordax4oC9mvIePCHrqkqpLICa0cS8uSm79JmaICIlOAthyoat6ZPFKHN7SG5aOT4OvX5enaCH7W1Z0PsjdyOdXhT8Ra9u6W985uP(GjiWQSmtlmQmeao8Jdq7OFSejFKHN7Smd3ImqBXb0tPfUdxptLwIeMGaRYYmTWOYqa4WpoaTJ(XttG2oZzHrLHaWHFCaAh9JlV780tyxamAOnEsc(9VFoLYUWiiLz4wKbAloGEkTallT0sKiLlmcsb6PuKdGwGLNMHN7SG5aOT4OvX5enaCH7W1ZuPniJxQxJlpk(Bbe4fE)iEPE9WR4KWoqzbjqBN5eBqAq6iBD8aN2sqNvpBRJh4uBrBJxQxJl2sYPTrA7SkoZaBLb6b0ecBZZw88bsBFk4bRPTANmaalN2(UMQPEn22RTLiPn1wsoaeWX6dimiDKTehMTLKdG2I26KkoNObGTvrSfId2wHQ3B7SM2Y9bloBBgaroX2gn1wc(eYaB)QncmwV22OP2suNsroaQTbGTTV0wahuii02dyBE2cyeaJNTLKG(1eSTxBBk8S9a2IEa22maICIlgKXl1RXLNWNamhaTfhTkoNObGjegZdHZQNhVaNAlk4hHpiEEEKbqKtSGFeQicKcAa0W1ZfmhaTfhTkoNObGhp48qqM(b0aOHRNlY35hihy8OyPLirk6Lf8CqpHdHhGoKdTlagbW45W1ZtXYS3pYaiYjUGQnDG5amXpPniDKTKZhiT1XvWdwtBj5aOTOToPIZjAayBFxt1uV228S1zMLTLKG(1eSTWY2QTTeT7FyqgVuVgxEcFFlGayoaAloAvCordatimMhcNvppEbo1wuWpcFq888idGiNyb)iureKHN7SG5aOT4OvX5enaCH7W1Z0P0ll45GEchcpaDihAxamcGXZHRNNILzVFKbqKtCbvB6aZbyIpniDKTx7Hy8e(SfnCMX2MZSTXl1RT9Ape2cJdxpBlfgOTOTV5OB2RTOTrtTTV02aBBylGfH9bW24L61fdY4L614Yt47BbeavB6W1h4KWR9qmEcFc(zqAqgVuVgxOOIJeOTZCIfaJ5HMmkHDGYcObWz076bLFopgYWjGXpUFSbz8s9ACHIkosG2oZj(BbeagZdnzuc7aLfGHBx)D0rGY5me40GmEPEnUqrfhjqBN5e)TacaJ5HMmkHDGYce9qippoKrGXkQ6JuV2GmEPEnUqrfhjqBN5e)TacaJ5HMmkHDGYcOaoOikGhqzmM9gKgKoYwIuOTTencMONqBXZhSNA77GYaBdV3wq0Im22dX2maICITnAQT4h3bqpSbz8s9ACbn0(Bbe4fE)iEPE9WR4KWoqzbU31eItG(sb)iure4cJGuCVRhhYiN5rGFCtzAbw2GmEPEnUGgA)TacqvSm7hOHO(miDKTehMTLOoLA7)aalN612ETTV780tyBR8DETfTnsB9CGtBjEIzR24O1ecBDHtB7lTvrSfId2wHQ3B7bLbVq2wTXrRje2QTTeLJTylrkCMTfddyBXZb9eIOCtjaQ2uxUPmW2OP2sK0MA7F(aN2QyBV223DE6jST1LroaBlr9pkgKXl1RXf0qBbqpLoyaSCQxtOIiaAa0W1Zf578dKdmEu8uTXrRjetiG4j2uP0ghTMqmjbe5jlrsgEUZcMdG2IJwfNt0aWfUdxptNcnaA465cMdG2IJwfNt0aWJhCEiisp9J3DE6jSlik30cS8uP(4DNNEc7cQ20HRpWzbwwIeSm79JmaICIlOAthyoat8P0gKoYwIu4mBlggW2cXbBRmCAlSSTKe0VMGTLOrs0iyBV22CMTndGiN2Qi2sqbroJa7T1XgmqzBvC)fPTXlvOCXGmEPEnUGgA)TacGNd6jCi8a0HCOnHkIaxyeKcsWdr4aq1OXfy5PFqzxyeKIqqKZiW(bsWaLlWYgKXl1RXf0q7VfqGx49J4L61dVItc7aLf8OydshzRJPkoBlbd0dOje2sK0MAljhaBJxQxBBE2cyeaJNTLiohW2kuZzBXCa0wC0Q4CIga2GmEPEnUGgA)TacGQnDG5aq4dINNhzae5el4hHkIGm8CNfmhaTfhTkoNObGlChUEMoflZE)idGiN4cQ20bMdWeqdGgUEUGQnDG5amEW5HGm9d6Lf8CqpHdHhGoKdTlP(CwBXPF8UZtpHDbr5MwGLniDKTemGryGT5zlmMTLic0os9ABjAKenc2wfX2OHWwI4CWwfBBFPTWYfdY4L614cAO93cianq7i1Rj8bXZZJmaICIf8JqfrWhqdGgUEUeE)GEjEalBq6iBjomBlrDk12)oFABK2oRIZmWwzGEanHWwHAoBRJjClYaTfTLOoLAlSST5zlXBBgaroXeA7bS9YzgyBgEUtSTxBlPdfdY4L614cAO93cia0tPd3ZNeQic0ghTMqmjbe5jpndp3zzgUfzG2IdONslChUEMondp3zbZbqBXrRIZjAa4c3HRNPtXYS3pYaiYjUGQnDG5amjb)RejsjvgEUZYmClYaTfhqpLw4oC9mD6hz45olyoaAloAvCordax4oC9mvAjsWYS3pYaiYjUGQnDG5ai4N0gKoYwI46ViTfgZ2sem0dgOTOTeSpeHzBveBH4GT9fTTICAR25zlrDkf5aO2Qno5GsOThWwfXwsoaAlARtQ4CIga2wfBBgEUtMAB0uBfQEVTZAAl3hS4STzae5exmiJxQxJlOH2FlGaug6bd0wCi7dryMqfrGuagbW45W1ZsKOnoAnHyI)BYspvQpGganC9Cr(o)a5aJhflrI24O1eIjeqKNS0tL6Jm8CNfmhaTfhTkoNObGlChUEMkrIuz45olyoaAloAvCordax4oC9mD6hqdGgUEUG5aOT4OvX5ena84bNhcI0sBq6iBjomBlr9NTxBRJte2Qi2cXbBl96ViTTzMABE2(cCAlrWqpyG2I2sW(qeMj02OP2MZmGTnaSTEgJTnNJ2wI32maICIT9GtBLAY2kuZzBFxtH1u6Ibz8s9ACbn0(Bbea6P0H75tcvebyz27hzae5exq1MoWCaMKue)3VRPWAwOkgFD05GFZhJlChUEMk9uTXrRjetsarEYtZWZDwWCa0wC0Q4CIgaUWD46zQejFKHN7SG5aOT4OvX5enaCH7W1ZudshzlXHzBjNd6j0wc6bOFTTebh5STkIT5mBBgaroTvX2gUhCABE2sv22dylehSTZbu2wY5GEcr8bkBlbdumQTmbbwLLzQTc1C2wIK2uxUPmW2dyl5CqpHik3uBJxQq5Ibz8s9ACbn0(Bbeaph0t4q4bOdkh5mHpiEEEKbqKtSGFeQicKkdGiNLzo85Cr(Lt6tInflZE)idGiN4cQ20bMdWKiEPLirkzolik30s8sfkpfa3mYbe5cEoONqeFGYdzGIrlmbbwLLzQ0gKoYwIdZ2scdaCtzGT5zlrkOnJX2ETTHTzae502CosBvSTIN2I2MNTuLTnsBZz2wGkoN2MkkxmiJxQxJlOH2FlGayyaGBkdg5nqdAZymHpiEEEKbqKtSGFeQicYaiYzjvuEK3GQ8K(CYtDHrqkqpLICa0c9e2gKoYwIdZ2suNsT1Hda4oT9Ape2Qi2ssq)Ac22OP2suoyBayBJxQqzBJMABoZ2MbqKtBfE9xK2sv2wkmqBrBZz223C0n7lgKXl1RXf0q7VfqaONsh5baCNe(G455rgaroXc(rOIiaAa0W1Zf6L4bS80maICwsfLh5nOkpXxovkxyeKc0tPihaTqpHTejUWiifONsroaAbWOH24j9UZtpHDb6P0H75ZcGrdTXspnEPcLh0llqduzfOVrEWVzbcWYS3pYaiYjUanqLvG(g5b)MNILzVFKbqKtCbvB6aZbyssn5VL6F)FZWZDwsHkohhYajsUWD46zQ0sBqgVuVgxqdT)wabq1M6YnLbeQicOxwGgOYkqFJ8GFZLuFoRT4uPYWZDwWCa0wC0Q4CIgaUWD46z6uSm79JmaICIlOAthyoatanaA465cQ20bMdW4bNhcIej0ll45GEchcpaDihAxs95S2IsBq6iBjomBljb9RjcBfQ5STeCOTlGdNzGTemo8O2c3EgJTnNzBZaiYPTcvV3wx2wx2FcT9tI9pHTUmYbyBZz223DE6jST9DOm2w345Sbz8s9ACbn0(Bbeaph0t4q4bOdkh5mHkIaaCZihqKlYH2UaoCMbdzC4rlmbbwLLz6uObqdxpxOxIhWYtZaiYzjvuEK3q(LJpj2es9UZtpHDbph0t4q4bOdkh5CHcdIuV(BXhvAdshzlXHzBjNd6j0whhe4zBV2whNiSfU9mgBBoZa22aW2guk2wTFhQ2IfdY4L614cAO93ciaEoONWXde4zcvebGqPdgk3zjOuCr7j(rmdshzlXHzBjsAtTLKdGT5z77AmmkBlreaNT1H5dwCoX2kdUh22RTLOr09pk26arhrq0zRJFnIcqTvX2MZk2wfBBy7SkoZaBLb6b0ecBZ5OTfW0ltTfT9ABjAeD)dBHBpJX2sdGZ2MZhS4CITvX2gUhCABE2MkkB7bNgKXl1RXf0q7VfqauTPdmhacFq888idGiNyb)iureGLzVFKbqKtCbvB6aZbycObqdxpxq1MoWCagp48qqM6cJGuObW5roFWIZzbwMW3COTGFeQDYaaSCouuuMQrYc(rO2jdaWY5qreK6Zz8ec(0G0r2sCy2wIK2uBDS(acBZZ231yyu2wIiaoBRdZhS4CITvgCpSTxBlPdfBDGOJii6S1XVgrbO2Qi2MZk2wfBBy7SkoZaBLb6b0ecBZ5OTfW0ltTfTfU9mgBlnaoBBoFWIZj2wfBB4EWPT5zBQOSThCAqgVuVgxqdT)wabq1Moq8beeQicCHrqk0a48iNpyX5SalpfAa0W1Zf6L4bSmHV5qBb)iu7Kbay5COOOmvJKf8JqTtgaGLZHIii1NZ4je8503DE6jSlqpLoCpFwGLniDKTehMTLiPn12)8boTvrSfId2w61FrABZm128SfWiagpBlrCoGl2sMNSTVaNAlABK2s82EaBrpaBBgaroX2kuZzBj5aOTOToPIZjAayBZWZDY0Ibz8s9ACbn0(BbeavB6W1h4Kqfra0aOHRNl0lXdy5PGqPdgk3zb9GYOCNfTN4f4CKkk)nXktEQuyz27hzae5exq1MoWCaMeXp9Jm8CNfufZaikChUEMkrcwM9(rgaroXfuTPdmhGj9VtZWZDwqvmdGOWD46zQ0gKXl1RXf0q7VfqaObQSc03ip43mHpiEEEKbqKtSGFeQicamcGXZHRNNMbqKZsQO8iVbv5j(xjsKkdp3zbvXmaIc3HRNPtPxwWZb9eoeEa6qo0UayeaJNdxplTejUWiif4gbg41wCqdGZnJXfyzdshzlPm)0WB77AQM612MNT48KT9f4uBrBjjOFnbB712Eii)pzae5eBRWzUTfrfNtTfT9lT9a2IEa2wCgpNzQTONl22OP2cJ1w0wcgdXBwF2s0RTZ2gn1wNi6CWwIKIzaefdY4L614cAO93ciaEoONWHWdqhYH2eQicamcGXZHRNNMbqKZsQO8iVbv5ji(PFKHN7SGQygarH7W1Z0Pz45olYyiEZ6B4125c3HRNPtXYS3pYaiYjUGQnDG5amXNgKoYwhdzw2wsc6xtW2clB712gyBrJgcBZaiYj22aBR8HXQRNj0w())y50wHZCBlIkoNAlA7xA7bSf9aST4mEoZuBrpxSTc1C2wcgdXBwF2s0RTZfdY4L614cAO93ciaEoONWHWdqhYH2e(G455rgaroXc(rOIiaWiagphUEEAgarolPIYJ8guLNG4N(rgEUZcQIzaefUdxptN(Huz45olyoaAloAvCordax4oC9mDkwM9(rgaroXfuTPdmhGjGganC9CbvB6aZby8GZdbr6Ps9rgEUZImgI3S(gETDUWD46zQejsLHN7SiJH4nRVHxBNlChUEMoflZE)idGiN4cQ20bMdWKe8P0sBqgVuVgxqdT)wabq1MoWCai8bXZZJmaICIf8JqfrawM9(rgaroXfuTPdmhGjGganC9CbvB6aZby8GZdbHW3COTGFeQDYaaSCouuuMQrYc(rO2jdaWY5qreK6Zz8ec(0GmEPEnUGgA)TacGQnDG4dii8nhAl4hHANmaalNdffLPAKSGFeQDYaaSCouebP(CgpHGpN(UZtpHDb6P0H75ZcSSbPJSL4WSTKe0VMiSnW26dCAlGXhiTvrS9ABZz2w0dkBqgVuVgxqdT)wabWZb9eoeEa6GYroBq6iBjomBljb9RjyBdST(aN2cy8bsBveBV22CMTf9GY2gn1wsc6xte2QyBV2whNimiJxQxJlOH2FlGa45GEchcpaDihABqAq6iBjomB71264eHTensIgbBBE2kYPTeX5GTP(CwBrBJMAl))LvaBBE261MTfw2wxotgyRqnNTLOoLICaudY4L614sc02zoXcGX8qtgLWoqzbmQmeao8Jdq7OFmHkIG3DE6jSlqpLoyaSCQxxamAOnEsc(9PejV780tyxGEkDWay5uVUay0qB8eF(FgKoYwsi6NTF1)jjcBfQ5STe1PuKdGAqgVuVgxsG2oZj(BbeagZdnzuc7aLfOn(bGZW1ZdccC0jm6GYq1htOIi4DNNEc7c0tPdgalN61faJgAJN4hXmiDKTKq0pBjNzoTLibJ1NTc1C2wI6ukYbqniJxQxJljqBN5e)TacaJ5HMmkHDGYcqJx4c4bEM5CGcJ1hHkIG3DE6jSlqpLoyaSCQxxamAOnEIFeZG0r2scr)S1XiSle2kuZzBj4tidS9R2iWy9ABHXHitOTOHZSTyyaBBE2IBvMTnNzB9NqgN26ysW2MbqKtdY4L614sc02zoXFlGaWyEOjJsyhOSa8b79CMAloaWUqqOIiWfgbPiFczWqBeySEDbwwIKpKbkJZcM9id5tidgAJaJ1Rj8bXZZJmaICIf8ZG0r2sCy22)cQiBR2yLY2Ei2suowBroGT5mBlIcWPTWy22dy71264eHTbsYaBZz2wefGtBHXCXwY5dK2(uWdwtBveBHEk1wgalN612(UZtpHTTk22FedB7bSf9aSTHWaIIbz8s9ACjbA7mN4Vfqaymp0KrjSduwawBey)q0hunYdGhUbvKhhYaHb3ttiiure8UZtpHDb6P0bdGLt96cGrdTXti4hXmiDKTehMT1R402dX2R)FGXST0anezBtG2oZj22R9qyRIyRJjClYaTfTLOoLAlrWUWii2QyBJxQqzcT9a2cXbBBayB7lTndp3jtTv78SvZIbz8s9ACjbA7mN4VfqGx49J4L61dVItc7aLfqrfhjqBN5etOIiqQpYWZDwMHBrgOT4a6P0c3HRNPsKqzxyeKYmClYaTfhqpLwGLLEQuUWiifONsroaAbwwIK3DE6jSlqpLoyaSCQxxamAOnEIFetAdshzlrWibSpTfj8E345STihWwyC46zB1KrXFTTehMT9ABF35PNW2wTT9augyRle2MaTDMtBX(llgKXl1RXLeOTZCI)wabGX8qtgftOIiWfgbPa9ukYbqlWYsK4cJGuKpHmyOncmwVUallrY7op9e2fONshmawo1Rlagn0gpXpIvjXY8R60NtMixZAwRa]] )

end
