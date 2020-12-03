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
            aura = "casting",

            last = function ()
                local app = state.buff.casting.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.mind_flay.tick_time ) * class.auras.mind_flay.tick_time
            end,

            stop = function () return not state.buff.casting.v3 or state.buff.casting.v1 ~= class.abilities.mind_flay.id end,
            interval = function () return class.auras.mind_flay.tick_time end,
            value = function () return ( state.talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * 3 end,
        },

        mind_sear = {
            aura = "casting",

            last = function ()
                local app = state.buff.casting.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.mind_sear.tick_time ) * class.auras.mind_sear.tick_time
            end,

            stop = function () return not state.buff.casting.v3 or state.buff.casting.v1 ~= class.abilities.mind_sear.id end,
            interval = function () return class.auras.mind_sear.tick_time end,
            value = function () return state.active_enemies end,
        },

        --[[ need to revise the value of this, void decay ticks up and is impacted by void torrent.
        voidform = {
            aura = "voidform",
            talent = "legacy_of_the_void",

            last = function ()
                local app = state.buff.voidform.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x )
                return x == 0
            end,

            interval = 1,
            value = function ()
                return state.debuff.dispersion.up and 0 or ( -6 - ( 0.8 * state.debuff.voidform.stacks ) )
            end,
        }, ]]

        void_torrent = {
            aura = "void_torrent",

            last = function ()
                local app = state.buff.void_torrent.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x )
                return x == 0
            end,

            interval = function () return class.auras.void_torrent.tick_time end,
            value = 6,
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

        if action.void_bolt.in_flight then
            runHandler( "void_bolt" )
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
            duration = function () return 3 * haste end,
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
            duration = function () return 4 * haste end,
            max_stack = 1,
            tick_time = function () return haste end,
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
                if buff.dark_thought.up then return 0 end
                return 7.5 * haste
            end,
            recharge = function ()
                if buff.dark_thought.up then return 0 end
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
            cast = 3,
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

            toggle = "cooldowns",

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

            debuff = "mind_sear",

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
            cast = function () return buff.unfurling_darkness.up and 0 or 1.5 end,
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
                return cooldown.void_bolt.remains == 0 and ( buff.dissonant_echoes.up or buff.voidform.up )
            end, ]]

            handler = function ()
                removeBuff( "dissonant_echoes" )

                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 3 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 3 end
                if talent.legacy_of_the_void.enabled and debuff.devouring_plague.up then debuff.devouring_plague.expires = query_time + debuff.devouring_plague.duration end

                if talent.hungering_void.enabled then
                    if debuff.hungering_void.up then buff.voidform.expires = buff.voidform.expires + 1 end
                    applyDebuff( "target", "hungering_void", 6 )
                end

                removeBuff( "anunds_last_breath" )
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
            cast = 4,
            channeled = true,
            fixedCast = true,
            cooldown = 45,
            gcd = "spell",

            spend = -6,
            spendType = "insanity",

            startsCombat = true,
            texture = 1386551,

            aura = "void_torrent",
            talent = "void_torrent",

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
            gcd = "spell", -- actually 1s and not 1.5s...

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

            spend = 0.02,
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

        potion = "unbridled_fury",

        package = "Shadow",
    } )


    spec:RegisterSetting( "stm_timer", 22, {
        name = "|T254090:0|t Surrender to Madness Time",
        desc = "|T254090:0|t Surrender to Madness will kill you if your targeted enemy does not die within 25 seconds.  The addon is able to estimate time-to-die, but " ..
            "these values are estimates.  This setting allows you to reserve a little extra time, so you are less likely to cause your own death.\n\n" ..
            "Custom priorities can reference |cFFFFD100settings.stm_timer|r for their decisions.",
        type = "range",
        min = 5,
        max = 25,
        step = 0.1,
        width = "full",
    } )


    spec:RegisterPack( "Shadow", 20201202.1, [[d80nvbqiKcpcPQUKsjKSjLIpbkqJsjvNsjLvbkaVsjXSuQ6wifjTlj(LsPggOOJbQSmrfpdPknnqv11ukPTbkKVHuunoqH6CIkrwhOQ08evQ7bP2hvuhePiwOsspuPenrqv6IifP2iOGmsLsOoPOsOvck9sLsiAMIkrDtKIYork9tqb1qbvXrvkHWsvkHupfKPIu5QivXwfvsFfuvSxI(RidwLdtAXIYJL0KjCzuBgQ(msgTsCAHvdkGEnvKztv3gk7wXVv1WPshxPeSCGNJy6uUoeBhs(ovy8IkbNxPY6rksmFrv7xQLWjPtcjuJL0MdmZbMWLdmZPKd9ct6fMWijKTZLLqUA1jLILqJIXsiOfv8oKqU6o)RcjDsiYJaQSeAXmxc8D7TPcBbjRuFSTjbgIxT4NkqXTTjbwDBjugs4TCXrMjHeQXsAZbM5at4YbM5uYHEHj9ct4xcPi2YdKqqb2wkHwcHGhzMesWKQeI(9bTOI3rFWdiyI1Ws)(GxUYyzmOVC23xoWmhykH8bXis6KqUaU(yzQjPtslCs6Kq8OzEwixvcvbHXGqLqagtJH0xU7JEHjmLqA1IFKqUVdgKC8arc)bwyicwAsAZrsNeIhnZZc5QsOkimgeQeIg9LHGJxilQ4DG)aScIResRw8JeISOI3b(dWKMKw6vsNeIhnZZc5QsOkimgeQekgIoHTRiy8OgwFo3hCBvcPvl(rcPGQoCYEaGhtAsAHFjDsiE0mplKRkHExjeHnjKwT4hjekfeAMNLqOupclHYrcHsbPrXyjewmIeHvqQIypoU0K0UvjDsiTAXpsiukMBaIAYEK6IeIhnZZc5QstAsibgvYaX4eBejDsAHtsNeIhnZZc5QsOrXyjKqboH9)KeC1PuYfXamPYtLLqA1IFKqcf4e2)tsWvNsjxedWKkpvwAsAZrsNeIhnZZc5QsOrXyjebzY8)lskgBl7iMesRw8JeIGmz()fjfJTLDetAsAPxjDsiE0mplKRkHgfJLqu(DUlPhpPesGfE1IFKqA1IFKqu(DUlPhpPesGfE1IFKMKw4xsNeIhnZZc5QsOrXyjKaWQapaCcftiSxcPvl(rcjaSkWdaNqXec7LM0Kqcgxr8MKojTWjPtcPvl(rcrcppvwcXJM5zHCvPjPnhjDsiE0mplKRkHQGWyqOsOmeC8cQpe4paRG42x(89LHGJxCFhmifdocj(PG4kH0Qf)iHCFl(rAsAPxjDsiE0mplKRkHExjeHnjKwT4hjekfeAMNLqOupclHeVvilQ4DKC8arYvJPyr1PyO6BtFI3kOum3ae1K9i1LIfvNIHscHsbPrXyjK4nscXvAsAHFjDsiE0mplKRkHExjeHnjKwT4hjekfeAMNLqOupclHeVvilQ4DKC8arYvJPyr1PyO6BtFI3kOum3ae1K9i1LIfvNIHQVn9jERiyupcigQKRxPq4IfvNIHscHsbPrXyjK69jXBKeIR0K0UvjDsiE0mplKRkHExjeHnjKwT4hjekfeAMNLqOupclHiUS3NmfqXgPGfJiryf0NZ9LtFR0xgcoEb1hc8hGvqCLqOuqAumwcryfedvAcQfdtbCQIypoU0K0cJK0jH4rZ8SqUQe6DLqe2KqA1IFKqOuqOzEwcHs9iSeQ(Vx8oMcQpejgG4AXpfe3(20369rJ(aAismkESIkeKcIBF5Z3hqdrIrXJvuHGueia1IF6l3O7doy2x(89b0qKyu8yfviifaJPXq6Zz09bhm7BL(2AFWa6B9(m1ZJvwqgkgedvc1hIcpAMNf9LpFF1hfp6yfN2bcD6BT(wRVn9TEFR3hqdrIrXJvuHGuIPpN7lhy2x(89rCzVpzkGInsb1hIedqCT4N(CgDFBTV16lF((m1ZJvwqgkgedvc1hIcpAMNf9LpFF1hfp6yfN2bcD6BnjekfKgfJLqU)7t4pivfePjPLMlPtcXJM5zHCvjufegdcvcLHGJxq9Ha)byfexjKwT4hjeEa4m))cPjPfglPtcXJM5zHCvjufegdcvcLHGJxq9Ha)byfexjKwT4hjugdimWPyOKMK2CjjDsiE0mplKRkHQGWyqOsiIl79jtbuSrk(GAXijyGickmES(CgDF50x(89TEF0OpGgIeJIhROcbPW5cbXi9LpFFanejgfpwrfcsjM(CUpA(w7BnjKwT4hjKpOwmscgiIGcJhtAsAHdMs6Kq8OzEwixvcvbHXGqLqzi44fuFiWFawbXvcPvl(rcPtLjgq9PQ69stslCWjPtcXJM5zHCvjKwT4hjuv9(KwT4NKpiMeYhelnkglHQoQstslC5iPtcXJM5zHCvjKwT4hjeazsA1IFs(GysiFqS0OySectJrAstcvDuL0jPfojDsiE0mplKRkHqiCYXs45uvjwmusAHtcPvl(rcryfedvAcQfdtbSeQUR65KPak2isAHtcvbHXGqLqR3hkfeAMNlewbXqLMGAXWuaNQi2JJ33M(OrFOuqOzEU4(VpH)Guvq6BT(YNVV17t8wHSOI3rYXdejxnMcGXbmzrZ8CFB6J4YEFYuafBKcwmIeHvqFo3hC9TM0K0MJKojepAMNfYvLqieo5yj8CQQelgkjTWjH0Qf)iHiScIHknb1IHPawcv3v9CYuafBejTWjHQGWyqOsit98yfcRGyOstqTyykGl8OzEw03M(eVvilQ4DKC8arYvJPayCatw0mp33M(iUS3NmfqXgPGfJiryf0NZ9LJ0K0sVs6Kq8OzEwixvc9JFxQ6OkHGtcPvl(rcHfJiL5vIjnPjHmqmoXgrsNKw4K0jH4rZ8SqUQesRw8JeIXC3by1NEGy0PYsOkimgeQeQ(Vx8oMcQpejgG4AXpfaJPXq6l3O7dUC6lF((YqWXlO(qG)aScIBF5Z3x9FV4DmfuFismaX1IFkagtJH0NZ9LdnxcnkglHym3Daw9PhigDQS0K0MJKojepAMNfYvLqA1IFKqXqQaetZ8CAlGOJHGLemQOYsOkimgeQekdbhVG6db(dWkiU9LpFF1)9I3Xuq9HiXaexl(PaymngsFo3hCWucnkglHIHubiMM550warhdbljyurLLMKw6vsNeIhnZZc5QsiTAXpsimTQzaorwy2syiKOkHQGWyqOsOmeC8cQpe4paRG42x(89v)3lEhtb1hIedqCT4NcGX0yi95CFWbtj0OySectRAgGtKfMTegcjQstsl8lPtcXJM5zHCvj0OySeI8iEpBwmujas2ojuDx1ZjtbuSrK0cNeQccJbHkHYqWXlUVdgKIbhHe)uqCLqA1IFKqKhX7zZIHkbqY2jnjTBvsNeIhnZZc5QsiTAXpsism4i(eLxfHApGKYubfNE8eod(Ay7KqvqymiujugcoEb1hc8hGvqC7lF((Q)7fVJPG6drIbiUw8tbWyAmK(CgDFWbtj0OySeIedoIpr5vrO2diPmvqXPhpHZGVg2oPjPfgjPtcXJM5zHCvjufegdcvcTEF0Opt98yLfKHIbXqLq9HOWJM5zrF5Z3NGZqWXllidfdIHkH6drbXTV16BtFR3xgcoEb1hc8hGvqC7lF((Q)7fVJPG6drIbiUw8tbWyAmK(CUp4GzFRjH0Qf)iHQQ3N0Qf)K8bXKq(GyPrXyjKaJkzGyCInI0K0sZL0jH4rZ8SqUQeQccJbHkHYqWXlO(qG)aScIBF5Z3xgcoEX9DWGum4iK4NcIBF5Z3x9FV4DmfuFismaX1IFkagtJH0NZ9bhmLqA1IFKqieofgJrKM0KqvbrsNKw4K0jH4rZ8SqUQeQccJbHkHYqWXlO(qG)aScIResRw8JeY9DWGum4iK4hPjPnhjDsiE0mplKRkH0Qf)iHiHNNklHQGWyqOsiaYW4pGIle2DbHMcj5c(QxXul(PWBbKW1Lf9TPV17ZuafBLGKuHOV857ZuafBfbNHGJxQkXIHQayTA9TMeQUR65KPak2isAHtAsAPxjDsiE0mplKRkH0Qf)iHiXGJ4tuEveQ9asktfuC6Xt4m4RHTtcvbHXGqLqzi44fuFiWFawbXTV857ZcmUpN7doy23M(wVpA0x9rXJowzcQflHRCFRjHgfJLqKyWr8jkVkc1EajLPcko94jCg81W2jnjTWVKojKwT4hjeUYjkeficDisiE0mplKRknjTBvsNeIhnZZc5QsiTAXpsiSyeukgtKqvqymiujumeDcBxF5UVCjy23M(wVpuki0mpxuVpjEJKqC7lF((YqWXlO(qG)aScIBFRjHQ7QEozkGInIKw4KMKwyKKojepAMNfYvLqvqymiujeqdrIrXJvuHGuIPpN7lhykH0Qf)iHqML3VlnpkvAsAP5s6Kq8OzEwixvcvbHXGqLq0OVmeC8cQpe4paRG423M(OrF1)9I3Xuq9HiXaexl(PG423M(iUS3NmfqXgPGfJiryf0NZ9bxFB6Jg9zQNhRqyfedvAcQfdtbCHhnZZI(YNVV17ldbhVG6db(dWkiU9TPpIl79jtbuSrkyXisewb9L7(YPVn9rJ(m1ZJviScIHknb1IHPaUWJM5zrFR1x(89TEFzi44fuFiWFawbXTVn9zQNhRqyfedvAcQfdtbCHhnZZI(wtcPvl(rcL9)KE8KTWjLu5rWcPjPfglPtcXJM5zHCvjKwT4hjuv9(KwT4NKpiMeYhelnkglHmqmoXgrAstcL9)iPtslCs6Kq8OzEwixvcvbHXGqLqex27tMcOyJuWIrKiSc6l3O7JELqA1IFKqkPYJGfPmVsmPjPnhjDsiE0mplKRkHQGWyqOsO17J4YEFYuafBKcwmIeHvqFo3xo9TPpt98yfcRGyOstqTyykGl8OzEw0x(89TEFex27tMcOyJuWIrKiSc6Z5(GRVn9rJ(m1ZJviScIHknb1IHPaUWJM5zrFR13A9TPpIl79jtbuSrkkPYJGfP5rP95CFWjH0Qf)iHusLhblsZJsLM0KqyAms6K0cNKojepAMNfYvLqvqymiujugcoEj7)j94jBHtkPYJGffexjeXar1K0cNesRw8JeQQEFsRw8tYhetc5dILgfJLqz)pstsBos6KqA1IFKqIG4Y(eMsfvjepAMNfYvLMKw6vsNeIhnZZc5QsOkimgeQecLccnZZf3)9j8hKQcsFB6lgIoHTRpNr3h8dZ(20369fdrNW21xUr3hmER9LpFFM65XkewbXqLMGAXWuax4rZ8SOVn9HsbHM55cHvqmuPjOwmmfWPkI9449TwFB6Jg9v)3lEhtbp4ruqCLqA1IFKqO(qKyaIRf)injTWVKojepAMNfYvLqvqymiujugcoEbx5efIceHoKcIBFB6Jg9j4meC8IdGAl4i(eUYGGliUsiTAXpsiYIkEhjhpqKC1yKMK2TkPtcXJM5zHCvjKwT4hjuv9(KwT4NKpiMeYhelnkglHQcI0K0cJK0jH4rZ8SqUQesRw8JeclgrIWkqcvbHXGqLqM65XkewbXqLMGAXWuax4rZ8SOVn9rCzVpzkGInsblgrIWkOpN7dLccnZZfSyejcRGufXEC8(20hn6t8wHSOI3rYXdejxnMIfvNIHQVn9rJ(Q)7fVJPGh8ikiUsO6UQNtMcOyJiPfoPjPLMlPtcXJM5zHCvjKwT4hjKqXg1IFKqvqymiujen6dLccnZZf17tI3ijexjuDx1ZjtbuSrK0cN0K0cJL0jH4rZ8SqUQeQccJbHkHIHOty76l3O7dgV1(20NPEESYcYqXGyOsO(qu4rZ8SOVn9zQNhRqyfedvAcQfdtbCHhnZZI(20hXL9(KPak2ifSyejcRG(Yn6(Gr9LpFFR3369zQNhRSGmumigQeQpefE0mpl6BtF0Opt98yfcRGyOstqTyykGl8OzEw03A9LpFFex27tMcOyJuWIrKiSc6dDFW13AsiTAXpsiuFiszV3KMK2CjjDsiE0mplKRkH0Qf)iHemQhbedvY1RuiSeQccJbHkHwVpaJdyYIM55(YNVVyi6e2U(CUpA(w7BT(20369rJ(qPGqZ8CX9FFc)bPQG0x(89fdrNW21NZO7dgV1(wRVn9TEF0Opt98yfcRGyOstqTyykGl8OzEw0x(89TEFM65XkewbXqLMGAXWuax4rZ8SOVn9rJ(qPGqZ8CHWkigQ0eulgMc4ufXEC8(wRV1Kq1DvpNmfqXgrslCstslCWusNeIhnZZc5QsOkimgeQeI4YEFYuafBKcwmIeHvqF5UV17d(7BL(Q)iqcRicc5hDSexxEMu4rZ8SOV16BtFXq0jSD9LB09bJ3AFB6ZuppwHWkigQ0eulgMc4cpAMNf9LpFF0Opt98yfcRGyOstqTyykGl8OzEwiH0Qf)iHq9HiL9EtAsAHdojDsiE0mplKRkH0Qf)iHilQ4DKC8arsWQTiHQGWyqOsO17ZuafBLfw92sXTA9L7(YbM9TPpIl79jtbuSrkyXisewb9L7(G)(wRV857B9(CzRGh8ikA1cuCFB6dGmm(dO4czrfVdCVIXjxqqWk8wajCDzrFRjHQ7QEozkGInIKw4KMKw4YrsNeIhnZZc5QsiTAXpsiccaWJGbj7tyQyycrcvbHXGqLqMcOyRybgNSpjcUVC3xoBTVn9LHGJxq9Ha)byfX7yKq1DvpNmfqXgrslCstslC0RKojepAMNfYvLqA1IFKqO(qKSha4XKqvqymiujekfeAMNlI3ije3(20NPak2kwGXj7tIG7Z5(O3(20xgcoEb1hc8hGveVJPVn9PvlqXjXBfukMBaIAYEK6sFO7J4YEFYuafBKckfZnarnzpsDPVn9rCzVpzkGInsblgrIWkOVC3369T1(wPV17dg1hmG(m1ZJvmhbXspEcxnUWJM5zrFR13AsO6UQNtMcOyJiPfoPjPfo4xsNeIhnZZc5QsOkimgeQes8wbLI5gGOMShPUuSO6umu9TPV17ZuppwHWkigQ0eulgMc4cpAMNf9TPpIl79jtbuSrkyXisewb95CFOuqOzEUGfJiryfKQi2JJ3x(89jERqwuX7i54bIKRgtXIQtXq13AsiTAXpsiSyez8iyG0K0c3wL0jH4rZ8SqUQeQccJbHkHaidJ)akU4QXKby1jgKCjQhRWBbKW1Lf9TPpuki0mpxeVrsiU9TPptbuSvSaJt2NCRwkhy2NZ9TEF1)9I3XuilQ4DKC8arsWQTueia1IF6BL(OQI(wtcPvl(rcrwuX7i54bIKGvBrAsAHdgjPtcXJM5zHCvjufegdcvcb0qKyu8yfviiLy6Z5(GdMsiTAXpsiYIkEhPkqjlstslC0CjDsiE0mplKRkH0Qf)iHWIrKiScKq1DvpNmfqXgrslCsOymgaqCTuGlHSO6eXz05iHIXyaaX1sbgglc1yjeCsOkimgeQeI4YEFYuafBKcwmIeHvqFo3hkfeAMNlyXisewbPkI9449TPVmeC8IqboLSLhHAXkiUsO6IgJecoPjPfoySKojepAMNfYvLqA1IFKqyXis4EDNekgJbaexlf4silQorCgDoBQ)7fVJPG6drk79wbXvcfJXaaIRLcmmweQXsi4KqvqymiujugcoErOaNs2YJqTyfe3(20hkfeAMNlI3ijexjuDrJrcbN0K0cxUKKojepAMNfYvLqvqymiujekfeAMNlI3ije3(20hqdrIrXJvWEumgpwjM(CUVQsSKfyCFR0hmlBTVn9TEFex27tMcOyJuWIrKiSc6l39b)9TPpA0NPEEScwqyWUcpAMNf9LpFFex27tMcOyJuWIrKiSc6l39bJ6BtFM65XkybHb7k8OzEw03AsiTAXpsiSyePmVsmPjPnhykPtcXJM5zHCvjKwT4hjekfZnarnzpsDrcvbHXGqLqaghWKfnZZ9TPptbuSvSaJt2Neb3NZ9bJ6lF((wVpt98yfSGWGDfE0mpl6BtFI3kKfv8osoEGi5QXuamoGjlAMN7BT(YNVVmeC8cYGJa8XqLekWPHjKcIReQUR65KPak2isAHtAsAZbojDsiE0mplKRkHQGWyqOsiaJdyYIM55(20NPak2kwGXj7tIG7Z5(G)(20hn6ZuppwblimyxHhnZZI(20NPEESIlzxDjQjFmov4rZ8SOVn9rCzVpzkGInsblgrIWkOpN7lhjKwT4hjezrfVJKJhisUAmstsBo5iPtcXJM5zHCvjKwT4hjezrfVJKJhisUAmsOkimgeQecW4aMSOzEUVn9zkGITIfyCY(Ki4(CUp4VVn9rJ(m1ZJvWccd2v4rZ8SOVn9rJ(wVpt98yfcRGyOstqTyykGl8OzEw03M(iUS3NmfqXgPGfJiryf0NZ9HsbHM55cwmIeHvqQIypoEFR13M(wVpA0NPEESIlzxDjQjFmov4rZ8SOV857B9(m1ZJvCj7Qlrn5JXPcpAMNf9TPpIl79jtbuSrkyXisewb9LB09LtFR13AsO6UQNtMcOyJiPfoPjPnh6vsNeIhnZZc5QsiTAXpsiSyejcRajuDx1ZjtbuSrK0cNekgJbaexlf4silQorCgDosOymgaqCTuGHXIqnwcbNeQccJbHkHiUS3NmfqXgPGfJiryf0NZ9HsbHM55cwmIeHvqQIypoUeQUOXiHGtAsAZb(L0jH4rZ8SqUQesRw8Jeclgrc3R7KqXymaG4APaxczr1jIZOZzt9FV4DmfuFiszV3kiUsOymgaqCTuGHXIqnwcbNeQUOXiHGtAsAZzRs6KqA1IFKqKfv8osoEGijy1wKq8OzEwixvAsAZbgjPtcPvl(rcrwuX7i54bIKRgJeIhnZZc5QstAstcHIbK4hjT5aZCGjC5aZCKqouWedfrcLlI5(aJf9bJ7tRw8tF(GyKsdReYf84HNLq0VpOfv8o6dEabtSgw63h8YvglJb9LZ((YbM5aZg2gw63hnDUaxrmw0xgJ)aUV6JLPwFzmvmKsF0KALDnsFZp0uxuagoIVpTAXpK((XVR0WQvl(HuCbC9XYuBf0B7(oyqYXdej8hyHHi49boAaJPXqYn9cty2WQvl(HuCbC9XYuBf0BtwuX7a)by7dC00idbhVqwuX7a)byfe3gwTAXpKIlGRpwMARGEBfu1Ht2da8y7dC0Xq0jSDfbJh1WCgUT2WQvl(HuCbC9XYuBf0BJsbHM559JIXOXIrKiScsve7XX3)UOjSThL6ry050WQvl(HuCbC9XYuBf0BJsXCdqut2JuxAyByPFFWZBXpKgwTAXpe0KWZtLBy1Qf)qq7(w8Z(ahDgcoEb1hc8hGvqCZNpdbhV4(oyqkgCes8tbXTHvRw8dzf0BJsbHM559JIXOfVrsiU7Fx0e22Js9imAXBfYIkEhjhpqKC1ykwuDkgQnI3kOum3ae1K9i1LIfvNIHQHvRw8dzf0BJsbHM559JIXOvVpjEJKqC3)UOjSThL6ry0I3kKfv8osoEGi5QXuSO6umuBeVvqPyUbiQj7rQlflQofd1gXBfbJ6raXqLC9kfcxSO6umunS0VpitbwFiKyO6dIvqmu9rBqTyykG7tT(O3v6ZuafBK(EqFW)k9f49T7r6tbCFX0xU(Ha)bynSA1IFiRGEBuki0mpVFumgnHvqmuPjOwmmfWPkI9447Fx0e22Js9imAIl79jtbuSrkyXisewboNZkzi44fuFiWFawbXTHL(9TL)7fVJPp45FFF5QccnZZ77JEiSOp77Z9FFFzm(d4(0QfOulgQ(q9Ha)byL(2seaGhZVRpecl6Z((Q)yG33NJfE6Z((0QfOuJ7d1hc8hG1NJWw6lM6JfdvFQqqknSA1IFiRGEBuki0mpVFumgT7)(e(dsvbz)7IMW2EuQhHrx)3lEhtb1hIedqCT4NcI7M1PbqdrIrXJvuHGuqCZNhOHiXO4XkQqqkceGAXp5gnCWmFEGgIeJIhROcbPaymngIZOHdMRSvyaRBQNhRSGmumigQeQpefE0mplYNV(O4rhR40oqOZARTz91bAismkESIkeKsmoNdmZNN4YEFYuafBKcQpejgG4AXpoJERRLpVPEESYcYqXGyOsO(qu4rZ8SiF(6JIhDSIt7aHoR1WQvl(HSc6TXdaN5)xSpWrNHGJxq9Ha)byfe3gwTAXpKvqVDgdimWPyO2h4OZqWXlO(qG)aScIBdl97JEiCF5Yb1Ibds6dwebfgpwFbEF2cd4(ua3xo99G(WEa3NPak2i777b9PcbPpfWdmO1hXvDmXq1h(d6d7bCF2Io9rZ3kP0WQvl(HSc6T9b1IrsWareuy8y7dC0ex27tMcOyJu8b1IrsWareuy8yoJoN85xNganejgfpwrfcsHZfcIrYNhOHiXO4XkQqqkX4mnFRR1WQvl(HSc6T1PYedO(uv9(9bo6meC8cQpe4paRG42WQvl(HSc6TRQ3N0Qf)K8bX2pkgJU6O2WQvl(HSc6TbitsRw8tYheB)OymAmnMg2gw63hnbEYL7Z((qiCFow4PVv)F67X7Zw4(OjKkpcw0xq6tRwGIBy1Qf)qkz)pOvsLhblszELy7dC0ex27tMcOyJuWIrKiScYnA6THvRw8dPK9)Sc6TvsLhblsZJs3h4OxN4YEFYuafBKcwmIeHvGZ5SXuppwHWkigQ0eulgMc4cpAMNf5ZVoXL9(KPak2ifSyejcRaNHBdnm1ZJviScIHknb1IHPaUWJM5zXARTH4YEFYuafBKIsQ8iyrAEuQZW1W2Ws)(2s4L0WQvl(HuQccA33bdsXGJqIF2h4OZqWXlO(qG)aScIBdl97JEiCFqHNNk33p9TLWBF23Nl4R9bXUli0uGbj9bpGV6vm1IFknSA1IFiLQGSc6TjHNNkVVUR65KPak2iOHBFGJgGmm(dO4cHDxqOPqsUGV6vm1IFk8wajCDzXM1nfqXwjijviYN3uafBfbNHGJxQkXIHQayTAR1Ws)(Ohc33QQGI7lgsi4(E8(YvyO(WFqF2c3hEaiwFieUVh03p9TLWBFkUXG(SfUp8aqS(qiCPp4tyl9rBqTy9bdPCFlVx0h(d6lxHHknSA1IFiLQGSc6TriCkmgB)OymAsm4i(eLxfHApGKYubfNE8eod(Ay72h4OZqWXlO(qG)aScIB(8wGXodhm3SonQpkE0XktqTyjCLxRHvRw8dPufKvqVnUYjkeficDinSA1IFiLQGSc6TXIrqPymzFDx1ZjtbuSrqd3(ahDmeDcBxUZLG5M1rPGqZ8Cr9(K4nscXnF(meC8cQpe4paRG4UwdRwT4hsPkiRGEBKz597sZJs3h4ObAismkESIkeKsmoNdmBy1Qf)qkvbzf0BN9)KE8KTWjLu5rWI9boAAKHGJxq9Ha)byfe3n0O(Vx8oMcQpejgG4AXpfe3nex27tMcOyJuWIrKiScCgUn0WuppwHWkigQ0eulgMc4cpAMNf5ZVEgcoEb1hc8hGvqC3qCzVpzkGInsblgrIWki35SHgM65XkewbXqLMGAXWuax4rZ8SyT85xpdbhVG6db(dWkiUBm1ZJviScIHknb1IHPaUWJM5zXAnSA1IFiLQGSc6TRQ3N0Qf)K8bX2pkgJ2aX4eBKg2gw633wQeRp4Zs45(2sLyXq1NwT4hsPpi26tT(wcQfg0NliEqy76Z((ilpW6RgGksy9fJXaaIR1x9hryXpK((PpAwmI(GyfSnmKx31Ws)(Ohc3heRGyO6J2GAXWua3xG33UhPphH333sy9XZJqT0NPak2i9PJOp45DWG(YfhCes8tF6i6lx)qG)aS(ua338wFawf7233d6Z((amoGjl9bbFGVWtF)0N5477b9H9aUptbuSrknSA1IFiLQJkAcRGyOstqTyykG3Jq4KJLWZPQsSyOqd3(6UQNtMcOyJGgU9bo61rPGqZ8CHWkigQ0eulgMc4ufXEC8n0aLccnZZf3)9j8hKQcYA5ZVU4TczrfVJKJhisUAmfaJdyYIM55nex27tMcOyJuWIrKiScCgU1AyPFFqlpW6BldqfjS(GyfedvF0gulgMc4(Q)icl(Pp77ZjMD7dc(aFHN(qC7lM(OjpnDdRwT4hsP6OUc6TjScIHknb1IHPaEpcHtowcpNQkXIHcnC7R7QEozkGIncA42h4On1ZJviScIHknb1IHPaUWJM5zXgXBfYIkEhjhpqKC1ykaghWKfnZZBiUS3NmfqXgPGfJiryf4ConS0VVF87svh1(WuNysF2c3NwT4N((XVRpeIM55(eiGyO6RUOZW(yO6thrFZB9PK(0(amfIxb9Pvl(P0WQvl(HuQoQRGEBSyePmVsS9)43LQoQOHRHTHvRw8dPiWOsgigNyJGgHWPWyS9JIXOfkWjS)NKGRoLsUigGjvEQCdRwT4hsrGrLmqmoXgzf0BJq4uym2(rXy0eKjZ)ViPySTSJynSA1IFifbgvYaX4eBKvqVncHtHXy7hfJrt535UKE8Ksibw4vl(PHvRw8dPiWOsgigNyJSc6TriCkmgB)OymAbGvbEa4ekMqyFdBdl97JMPX0hnbEYL33hz5r8I(Qpkg0N699b0HIj9949zkGInsF6i6Ju5rbXtAy1Qf)qkyAmRGE7Q69jTAXpjFqS9JIXOZ(F2tmqun0WTpWrNHGJxY(FspEYw4KsQ8iyrbXTHvRw8dPGPXSc6TfbXL9jmLkQnS0Vp6HW9LRFi6JMgG4AXp99tF1)9I3X0N7)(yO6tT(8SsS(GFy2xmeDcBxFziwFZB9f49T7r6Zr4999OyqvD7lgIoHTRVy6lxHHk9rZuN4(iiaUpYIkEh4bpITXIrKXJGb9fK((PV6)EX7y6lJXFa3xUstxAy1Qf)qkyAmOr9HiXaexl(zFGJgLccnZZf3)9j8hKQcYMyi6e2oNrd)WCZ6Xq0jSD5gnmER5ZBQNhRqyfedvAcQfdtbCHhnZZInOuqOzEUqyfedvAcQfdtbCQIypo(ABOr9FV4Dmf8GhrbXTHL(9rZuN4(iiaUVDpsFUiwFiU9bbFGVWtF0eiAc803p9zlCFMcOyRVaVp4dqTfCeFFWqkdcUVGmWGwFA1cuCPHvRw8dPGPXSc6TjlQ4DKC8arYvJzFGJodbhVGRCIcrbIqhsbXDdneCgcoEXbqTfCeFcxzqWfe3gwTAXpKcMgZkO3UQEFsRw8tYheB)Oym6QG0Ws)(2IdQL(Ghq8GW21hnlgrFqSc6tRw8tF23hGXbmzPp49PJ0NJWw6JWkigQ0eulgMc4gwTAXpKcMgZkO3glgrIWkyFDx1ZjtbuSrqd3(ahTPEEScHvqmuPjOwmmfWfE0mpl2qCzVpzkGInsblgrIWkWzuki0mpxWIrKiScsve7XX3qdXBfYIkEhjhpqKC1ykwuDkgQn0O(Vx8oMcEWJOG42Ws)(GhaJZG(SVpec3h8QyJAXp9rtGOjWtFbEF6SRp49PRVG038wFiULgwTAXpKcMgZkO3wOyJAXp7R7QEozkGIncA42h4OPbkfeAMNlQ3NeVrsiUnS0Vp6HW9LRFi6B13B9PwFlb1cd6ZfepiSD95iSL(2IrgkgedvF56hI(qC7Z((G)(mfqXgzFFpOV3wyqFM65Xi99tFq0vAy1Qf)qkyAmRGEBuFiszV32h4OJHOty7YnAy8w3yQNhRSGmumigQeQpefE0mpl2yQNhRqyfedvAcQfdtbCHhnZZInex27tMcOyJuWIrKiScYnAyu(8RVUPEESYcYqXGyOsO(qu4rZ8Sydnm1ZJviScIHknb1IHPaUWJM5zXA5ZtCzVpzkGInsblgrIWkanCR1Ws)(G3FGbT(qiCFWlJ6raXq1h84vkeUVaVVDpsFvD6JIT(IX((Y1pe4paRVyigRI999G(c8(GyfedvF0gulgMc4(csFM65XyrF6i6Zr499TewF88iul9zkGInsPHvRw8dPGPXSc6TfmQhbedvY1Rui8(6UQNtMcOyJGgU9bo61bmoGjlAMNZNpgIoHTZzA(wxBZ60aLccnZZf3)9j8hKQcs(8Xq0jSDoJggV112Sonm1ZJviScIHknb1IHPaUWJM5zr(8RBQNhRqyfedvAcQfdtbCHhnZZIn0aLccnZZfcRGyOstqTyykGtve7XXxBTgw63h9q4(Y1v77N(2s4TVaVVDpsFIFGbT(gMf9zFFvLy9bVmQhbedvFWJxPq499PJOpBHbCFkG7ZZesF2Io9b)9zkGInsFpI136BTphHT0x9hbsyRvAy1Qf)qkyAmRGEBuFiszV32h4OjUS3NmfqXgPGfJiryfK71H)vQ)iqcRicc5hDSexxEMu4rZ8SyTnXq0jSD5gnmERBm1ZJviScIHknb1IHPaUWJM5zr(80WuppwHWkigQ0eulgMc4cpAMNfnS0Vp6HW9bTOI3rFWNhiGV9bVSAl9f49zlCFMcOyRVG0NM9iwF23Ni4(EqF7EK(wuuCFqlQ4DG7vmUp4beeS(4Tas46YI(Ce2sF0Syez8iyqFpOpOfv8oWdEe9PvlqXLgwTAXpKcMgZkO3MSOI3rYXdejbR2Y(6UQNtMcOyJGgU9bo61nfqXwzHvVTuCRwUZbMBiUS3NmfqXgPGfJiryfKB4FT85x3LTcEWJOOvlqXBaidJ)akUqwuX7a3RyCYfeeScVfqcxxwSwdl97JEiCFqiaapcg0N99rZuXWesF)0N2NPak26ZwuRVG0h1hdvF23Ni4(uRpBH7deulwFwGXLgwTAXpKcMgZkO3MGaa8iyqY(eMkgMq2x3v9CYuafBe0WTpWrBkGITIfyCY(Ki4CNZw3KHGJxq9Ha)byfX7yAyPFF0dH7lx)q0hDpaWJ13p(D9f49bbFGVWtF6i6lxPRpfW9PvlqX9PJOpBH7ZuafB954hyqRprW9jqaXq1NTW9vx0zyFPHvRw8dPGPXSc6Tr9HizpaWJTVUR65KPak2iOHBFGJgLccnZZfXBKeI7gtbuSvSaJt2Neb7m9UjdbhVG6db(dWkI3XSrRwGItI3kOum3ae1K9i1f0ex27tMcOyJuqPyUbiQj7rQlBiUS3NmfqXgPGfJiryfK7136kRdJGbyQNhRyocILE8eUACHhnZZI1wRHvRw8dPGPXSc6TXIrKXJGb7dC0I3kOum3ae1K9i1LIfvNIHAZ6M65XkewbXqLMGAXWuax4rZ8SydXL9(KPak2ifSyejcRaNrPGqZ8CblgrIWkivrShhpFEXBfYIkEhjhpqKC1ykwuDkgQ1AyPFF0dH7dc(aFH3(Ce2sFWJgtgGvNyqFWdr9y9HmEMq6Zw4(mfqXwFocVVVmUVm2)o6lhyUfvFzm(d4(SfUV6)EX7y6R(ymPVmT6udRwT4hsbtJzf0BtwuX7i54bIKGvBzFGJgGmm(dO4IRgtgGvNyqYLOEScVfqcxxwSbLccnZZfXBKeI7gtbuSvSaJt2NCRwkhy6861)9I3XuilQ4DKC8arsWQTueia1IFwHQkwRHL(9rpeUpOfv8o6BlbkzPVF6BlH3(qgpti9zlmG7tbCFQqq6lM6JfdvPHvRw8dPGPXSc6TjlQ4DKQaLSSpWrd0qKyu8yfviiLyCgoy2Ws)(Ohc3hnlgrFqSc6Z((Q)qqW4(Gxf4uF0T8iulgPpxWxj99tF0eyyA6sF0bddVWW9TL)GhaS(csF2sq6li9P9TeulmOpxq8GW21NTOtFaw8MfdvF)0hnbgMMUpKXZesFcf4uF2YJqTyK(csFA2Jy9zFFwGX99iwdRwT4hsbtJzf0BJfJiryfSVUR65KPak2iOHBFGJM4YEFYuafBKcwmIeHvGZOuqOzEUGfJiryfKQi2JJVjdbhViuGtjB5rOwScI7(6IgdA42hJXaaIRLcmmweQXOHBFmgdaiUwkWrBr1jIZOZPHL(9rpeUpAwmI(GH86U(SVV6peemUp4vbo1hDlpc1Ir6Zf8vsF)0heDL(OdggEHH7Bl)bpay9f49zlbPVG0N23sqTWG(CbXdcBxF2Io9byXBwmu9HmEMq6tOaN6ZwEeQfJ0xq6tZEeRp77ZcmUVhXAy1Qf)qkyAmRGEBSyejCVUBFGJodbhViuGtjB5rOwScI7guki0mpxeVrsiU7RlAmOHBFmgdaiUwkWWyrOgJgU9XymaG4APahTfvNioJoNn1)9I3Xuq9HiL9ERG42Ws)(Ohc3hnlgrFR6vI1xG33UhPpXpWGwFdZI(SVpaJdyYsFW7thP0hK9U9vvIfdvFQ1h833d6d7bCFMcOyJ0NJWw6dIvqmu9rBqTyykG7ZuppglknSA1IFifmnMvqVnwmIuMxj2(ahnkfeAMNlI3ije3nanejgfpwb7rXy8yLyCUQelzbgVcmlBDZ6ex27tMcOyJuWIrKiScYn8VHgM65XkybHb7k8OzEwKppXL9(KPak2ifSyejcRGCdJ2yQNhRGfegSRWJM5zXAnSA1IFifmnMvqVnkfZnarnzpsDzFDx1ZjtbuSrqd3(ahnGXbmzrZ88gtbuSvSaJt2Neb7mmkF(1n1ZJvWccd2v4rZ8SyJ4TczrfVJKJhisUAmfaJdyYIM551YNpdbhVGm4iaFmujHcCAycPG42Ws)(GC5AO((Q)icl(Pp77JyVBFvLyXq1he8b(cp99tFpoonvtbuSr6ZXcp9Hhulwmu9rV99G(WEa3hX0QtSOpSpJ0NoI(qiXq1h8q2vxIAF5YX4uF6i6Jwyy66JMfegSR0WQvl(HuW0ywb92Kfv8osoEGi5QXSpWrdyCatw0mpVXuafBflW4K9jrWod)BOHPEEScwqyWUcpAMNfBm1ZJvCj7Qlrn5JXPcpAMNfBiUS3NmfqXgPGfJiryf4ConS0VVTiz2Tpi4d8fE6dXTVF6tj9HPZU(mfqXgPpL0N7tirMN33hNluzxRphl80hEqTyXq1h923d6d7bCFetRoXI(W(msFocBPp4HSRUe1(YLJXPsdRwT4hsbtJzf0BtwuX7i54bIKRgZ(6UQNtMcOyJGgU9boAaJdyYIM55nMcOyRybgNSpjc2z4Fdnm1ZJvWccd2v4rZ8Sydnw3uppwHWkigQ0eulgMc4cpAMNfBiUS3NmfqXgPGfJiryf4mkfeAMNlyXisewbPkI944RTzDAyQNhR4s2vxIAYhJtfE0mplYNFDt98yfxYU6sut(yCQWJM5zXgIl79jtbuSrkyXisewb5gDoRTwdRwT4hsbtJzf0BJfJiryfSVUR65KPak2iOHBFGJM4YEFYuafBKcwmIeHvGZOuqOzEUGfJiryfKQi2JJVVUOXGgU9XymaG4APadJfHAmA42hJXaaIRLcC0wuDI4m6CAy1Qf)qkyAmRGEBSyejCVUBFDrJbnC7JXyaaX1sbgglc1y0WTpgJbaexlf4OTO6eXz05SP(Vx8oMcQpePS3Bfe3gw63h9q4(GGpWx4TpL0NxjwFaM8aRVaVVF6Zw4(WEuCdRwT4hsbtJzf0BtwuX7i54bIKGvBPHL(9rpeUpi4d8fE6tj95vI1hGjpW6lW77N(SfUpShf3NoI(GGpWx4TVG03p9TLWBdRwT4hsbtJzf0BtwuX7i54bIKRgtdBdl97JEiCF)03wcV9rtGOjWtF23hfB9bVpD9zr1PyO6thrFCUGBa4(SVpFmCFiU9LXMXG(Ce2sF56hc8hG1WQvl(HumqmoXgbncHtHXy7hfJrZyU7aS6tpqm6u59bo66)EX7ykO(qKyaIRf)uamMgdj3OHlN85ZqWXlO(qG)aScIB(81)9I3Xuq9HiXaexl(PaymngIZ5qZByPFFq7MAF5IBraV95iSL(Y1pe4paRHvRw8dPyGyCInYkO3gHWPWyS9JIXOJHubiMM550warhdbljyurL3h4OZqWXlO(qG)aScIB(81)9I3Xuq9HiXaexl(PaymngIZWbZgw63h0UP2h0cZwF0mesu7Zryl9LRFiWFawdRwT4hsXaX4eBKvqVncHtHXy7hfJrJPvndWjYcZwcdHe19bo6meC8cQpe4paRG4MpF9FV4DmfuFismaX1IFkagtJH4mCWSHL(9bTBQ9Tfns2U(Ce2sFWZ7Gb9Llo4iK4N(qikfVVpm1jUpccG7Z((it4Y9zlCF(3btS(2IHN(mfqXwdRwT4hsXaX4eBKvqVncHtHXy7hfJrtEeVNnlgQeajB3(ahDgcoEX9DWGum4iK4NcI7(6UQNtMcOyJGgUgw63h9q4(wvfuCFXqcb33J3xUcd1h(d6Zw4(WdaX6dHW99G((PVTeE7tXng0NTW9HhaI1hcHl9bT8aRVAaQiH1xG3hQpe9Xaexl(PV6)EX7y6li9bhmj99G(WEa3N6q3vAy1Qf)qkgigNyJSc6TriCkmgB)OymAsm4i(eLxfHApGKYubfNE8eod(Ay72h4OZqWXlO(qG)aScIB(81)9I3Xuq9HiXaexl(PaymngIZOHdMnS0Vp6HW95dI13J33p0uriCFcftP4(mqmoXgPVF876lW7BlgzOyqmu9LRFi6dE5meC8(csFA1cu8((EqF7EK(ua338wFM65XyrFXyFFHvAy1Qf)qkgigNyJSc6TRQ3N0Qf)K8bX2pkgJwGrLmqmoXgzFGJEDAyQNhRSGmumigQeQpefE0mplYNxWzi44LfKHIbXqLq9HOG4U2M1ZqWXlO(qG)aScIB(81)9I3Xuq9HiXaexl(PaymngIZWbZ1AyPFFWlJRiERpC17Z0Qt9H)G(qiAMN7lmgJaF7JEiCF)0x9FV4Dm9ftFpqWG(Y21NbIXj26J4FR0WQvl(HumqmoXgzf0BJq4uymgzFGJodbhVG6db(dWkiU5ZNHGJxCFhmifdocj(PG4MpF9FV4DmfuFismaX1IFkagtJH4mCWucrC5QK2C2kmwAstkba]] )


end
