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


    spec:RegisterPack( "Shadow", 20201202, [[d8uH5bqiuv8iOsUeQIG2KkLpHQinkvIoLkjRsfO4vOknlrQBHQsPDPWVqv1Wqf1XGkwMkvEMkvPPbvQUMkbBdvb9nuvIXHQaNdQuO1PcK5PsO7PI2NiXbvbyHOI8quf1efj1fvbQ2iuPOrIQsXjrveTsjLxIQiWmHkLCtvQIDQsQFIQs1qfj5OOkczPOkc1tjQPQc6QQuvBfvH(QkG2li)vIbR0HPSyj5XkAYeUmYMrXNrPrlItt1Qvbk9AuHzlQBdQDl1Vv1WjYXrvjTCGNdz6KUou2ou13rLgpuPuNxfA9qLcMVKQ9lmeoqhcjlmLGU(ooFhNX5ooF3GZ4gXbNlChKSEuIGKLSjhglbj3gmbjlNyINlKSKDm)Ma6qiz0JbMeKCIQsOdIF(zDnbRAmFy(romw2u)7jWyu(ro8KFi5kmpR8KnufKSWuc66748DCgN748DdoJBehCUaoqYgMM8aizzhMNHKtCHGAOkizbHMqY4kw5et8CJnvaNqAudxXMAAsWvei27sh7DC(ooh1IA4k2doUnnXuseBfX8ak25dxzASveR3OrShWCsskk2(B(2edaZGLJ1MQ)nk2VZhhrnBQ(3OHeGMpCLP8EYV0ZLafUpquyEG6kMGs7mNac28gDX7LZCoQzt1)gnKa08HRmL3t(rjM45Y8a40oZjFQWyygOet8CzEa8atkQzt1)gnKa08HRmL3t(nW0AQOpaqTM2zo9gzTRhhcIXNUMcoxiQzt1)gnKa08HRmL3t(XBa3QYu62GPtyVffezGYetFgM0V0jI004TmgDExuZMQ)nAibO5dxzkVN8J3GLCGpl6JntIArnCfBQE1)gf1SP6FJorEM6jf1SP6FJoLE1)oTZCwHXWmW)UG5bWdmP61RWyygspxcu8Mbd5FpWKIA2u9Vr8EYpEd4wvMs3gmDkEfvWKs)sNistJ3Yy0P41bkXep3c3hiksM3d1NC4n7nXRd8gSKd8zrFSzYq9jhEZg1SP6FJ49KF8gWTQmLUny60Y5I4vubtk9lDIinnElJrNIxhOet8ClCFGOizEpuFYH3S3eVoWBWsoWNf9XMjd1NC4n7nXRdbH)XaEZwKYglgnuFYH3SrnCfRSAanwmK3SXktgWB2yV2ztuydqXAAS3lVXQgGLuuSpiwCN3yDMyp(yXAakwVJLhFxW8a4OMnv)BeVN8J3aUvLP0TbtNiYaEZwANnrHnavMy6ZWK(LorKMgVLXOtKeLZf1aSKIgWElkiYaPChVvymmd8VlyEa8atkQHRy55)ZINBhBQ(phlpAa3QYu6yVpIeXQFSs)NJTIyEafRnvhVPEZgl(3fmpaEelpJbauR5JXIHirS6h78Bf85y5MqDS6hRnvhVPuS4FxW8a4y56AsSEpFyVzJ1ec0iQzt1)gX7j)4nGBvzkDBW0P0)5cZdktbk9lDIinnElJrNZ)ZINBpW)UOqamj1)EGjD7s(amxui8uRdtiqdmP61bMlkeEQ1HjeOHadyQ)9fpXHZ1Rdmxui8uRdtiqdabBEJs5ehoZ7foyUuTm16ibRzjG3Sf8VlguBvzsuV(8XtT16GJJa36RU62Lxcmxui8uRdtiqdVt5ooxVosIY5IAawsrd8Vlkeats9Vt58cxvVUAzQ1rcwZsaVzl4FxmO2QYKOE95JNAR1bhhbU1xf1SP6FJ49KFghqv5)fPDMZkmgMb(3fmpaEGjf1SP6FJ49K)kcGiahEZM2zoRWyyg4FxW8a4bMuudxXEFeflULZMO8uuS1WeSWuRX6mXQjeGI1auS3f7dIf(buSQbyjfLo2heRjeOyna18unwKKXT9MnwMhel8dOy1eRJLVCb0iQzt1)gX7j)zNnrrLdwmblm1AAN5ejr5CrnalPOr2ztuu5GftWctTMY5D1RFjFaMlkeEQ1HjeObHB7ifvVoWCrHWtTomHan8of(YfUkQzt1)gX7j)wpjKcSCzA5CAN5ScJHzG)DbZdGhysrnBQ(3iEp5FA5CXMQ)Dj7inDBW05K7mQzt1)gX7j)aSUyt1)UKDKMUny6e28oQf1WvShqQWTIv)yXquSCtOowo9Fh7ZeRMqXEaOj1cseRJI1MQJNIA2u9VrJQ)7tdnPwqIsv2qAAN5ejr5CrnalPObS3IcImWfpV3OMnv)B0O6)M3t(n0KAbjk9J3s7mNxIKOCUOgGLu0a2BrbrgiL7UPwMADGid4nBPD2ef2a0GARktI61Vejr5CrnalPObS3IcImqk4CJpQLPwhiYaEZwANnrHnanO2QYK4QRUHKOCUOgGLu0WqtQfKO0pElfCIArnCflpNAuudxXEFefRSNPEsX(DS8CQJv)yLa)mwzskbd3apffBQa)mBWM6FpIA2u9VrJPaX7j)ipt9KsppoZurnalPOtCs7mNaSMyEalnqKucgUburc8ZSbBQ)9G4RyUKejUDPAawshoQycr96QbyjDiOkmgMX0qQ3Sdazt9QOMnv)B0ykq8EY)0Y5Inv)7s2rA62GPtf4nhKIIArnCflpBin2dmXZuS8SHuVzJ1MQ)nAeRmPXAASjoBcbIvc4pW1JXQFSOKhOXoDWeZ1y9wjaatsJD(TWv)BuSFh794TiwzYa8JBMTJrnCf79ruSYKb8Mn2RD2ef2auSotShFSy565CSjUgl1pgBsSQbyjffR1Iyt1ZLaXYt2myi)7yTwelp(UG5bWXAak2(1ybKjoMo2heR(XcigaHsIv(apOuf73XQC)yFqSWpGIvnalPOruZMQ)nAm5oprKb8MT0oBIcBakngIkCt8mvMgs9M9eN0ZJZmvudWsk6eN0oZ5L4nGBvzAGid4nBPD2ef2auzIPpdZn(G3aUvLPH0)5cZdktb6Q61Vu86aLyINBH7defjZ7bGyaekXQY0nKeLZf1aSKIgWElkiYaPGZvrnCfRCYd0y5zhmXCnwzYaEZg71oBIcBak253cx9VJv)y5GiPyLpWdkvXIjfR3XEa)bpQzt1)gnMCN8EYpImG3SL2ztuydqPXquHBINPY0qQ3SN4KEECMPIAawsrN4K2zovltToqKb8MT0oBIcBaAqTvLjXnXRduIjEUfUpquKmVhaIbqOeRkt3qsuoxudWskAa7TOGidKYDrnCf735JLj3zSWghekwnHI1MQ)DSFNpglgYQYuScmG3SXotSUPS3SXATi2(1ynuSwSaIflBGyTP6FpIA2u9VrJj3jVN8d7TOuLnKM(78XYK78eNOwuZMQ)nAiGzlkWBoifDIHOIReC62GPtHb4a()UiOjhLIeMci0K6jf1SP6FJgcy2Ic8Mdsr8EYpgIkUsWPBdMoryDv(FrXGjn5isJA2u9VrdbmBrbEZbPiEp5hdrfxj40TbtNS5JsjLNPyiKd7zt9VJA2u9VrdbmBrbEZbPiEp5hdrfxj40TbtNcazcghqf8ecr5OwudxXEpM3XEaPc3kDSOKhllID(4jqSwohlWAwcf7ZeRAawsrXATiw0KAd4pkQzt1)gnGnV59K)PLZfBQ(3LSJ00TbtNv)3PrkWN6joPDMZkmgMr1)D5zkAcvm0KAbjgysrnBQ(3ObS5nVN8lCKeLlWgRpJA4k27JOy5X3fXEWbysQ)DSFh78)S452Xk9F2B2ynn2mzinwCNZX6nYAxpgBfMgB)ASotShFSy565CSpEcmnPy9gzTRhJ17y5rCZrS3JXbflcdqXIsmXZLXPwWpS3IkQfeiwhf73Xo)plEUDSveZdOy5Xd(iQzt1)gnGnVpX)UOqamj1)oTZCI3aUvLPH0)5cZdktb6M3iRD9ykN4oNVDP3iRD94fp5bxOED1YuRdezaVzlTZMOWgGguBvzsCdVbCRktdezaVzlTZMOWgGktm9zyU6gFM)Nfp3EW4ulgysrnCf79yCqXIWauShFSyLW0yXKIv(apOuf7biFaPk2VJvtOyvdWsASotShiW0egSCS4MgbCkwh18unwBQoEAe1SP6FJgWM38EYpkXep3c3hiksM3PDMZkmgMbJrfwmdiCRrdmPB8rqvymmdUattyWYfgJaonWKIA2u9VrdyZBEp5FA5CXMQ)Dj7inDBW05uGIA4kw(gNnj2ub8h46XyVhVfXktgiwBQ(3XQFSaIbqOKyt9FikwUUMelImG3SL2ztuydqrnBQ(3ObS5nVN8d7TOGidKEECMPIAawsrN4K2zovltToqKb8MT0oBIcBaAqTvLjXnKeLZf1aSKIgWElkiYaPG3aUvLPbS3IcImqzIPpdZn(iEDGsmXZTW9bIIK59q9jhEZEJpZ)ZINBpyCQfdmPOgUInvaIHaXQFSyik2uBWTP(3XEaYhqQI1zI16JXM6)WyDuS9RXIjnIA2u9VrdyZBEp5xyWTP(3PNhNzQOgGLu0joPDMt(G3aUvLPHLZfXROcMuudxXEFeflp(Uiwo9znwtJnXztiqSsa)bUEmwUUMelFdwZsaVzJLhFxelMuS6hlUhRAawsrPJ9bX(AcbIvTm1kk2VJv(WruZMQ)nAaBEZ7j)4FxuQ(SM2zo9gzTRhV4jp4c3ultTosWAwc4nBb)7Ib1wvMe3ultToqKb8MT0oBIcBaAqTvLjXnKeLZf1aSKIgWElkiYax8KhwV(LxQwMADKG1SeWB2c(3fdQTQmjUXh1YuRdezaVzlTZMOWgGguBvzsCv96ijkNlQbyjfnG9wuqKboX5QOgUIn1FZt1yXquSPMW)yaVzJnvzJfJI1zI94Jf706yzjnwV1pwE8DbZdGJ1BKsMiDSpiwNjwzYaEZg71oBIcBakwhfRAzQvseR1Iy565CSjUgl1pgBsSQbyjfnIA2u9VrdyZBEp5xq4FmG3SfPSXIrPNhNzQOgGLu0joPDMZlbedGqjwvMQx3BK1UEmf(YfU62L8bVbCRktdP)ZfMhuMcu96EJS21JPCYdUWv3UKpQLPwhiYaEZwANnrHnanO2QYKOE9lvltToqKb8MT0oBIcBaAqTvLjXn(G3aUvLPbImG3SL2ztuydqLjM(mmxDvudxXEFeflpYPy)owEo1X6mXE8XIv8npvJTjseR(XonKgBQj8pgWB2ytv2yXO0XATiwnHauSgGIntiuSAI1XI7XQgGLuuSpMg7LxiwUUMe78BbMRxnIA2u9VrdyZBEp5h)7Is1N10oZjsIY5IAawsrdyVffezGlEjUZ78BbMRdHJqFBTwOzYtOb1wvMexDZBK1UE8IN8GlCtTm16argWB2s7SjkSbOb1wvMe1RZh1YuRdezaVzlTZMOWgGguBvzse1WvS3hrXkNyINBSh4dehuSPMmnjwNjwnHIvnalPX6OyTQhtJv)yfof7dI94JfBIHNIvoXepxMSbtXMkGJGJL4RyUKejILRRjXEpElQOwqGyFqSYjM45Y4ulI1MQJNgrnBQ(3ObS5nVN8JsmXZTW9bIIGmnj984mtf1aSKIoXjTZCEPAawshjKL1KH0uV4DC(gsIY5IAawsrdyVffezGlI7xvV(LsKoyCQfdBQoE6gaRjMhWsduIjEUmzdMksahbpi(kMljrIRIA4k27JOyLXaaQfeiw9J9EmrtiuSFhRfRAawsJvtmnwhfl77nBS6hRWPynnwnHIf4SjASQdtJOMnv)B0a28M3t(ryaa1ccu0VaBIMqO0ZJZmvudWsk6eN0oZPAawshQdtf9lcNU4Dx4wfgdZa)7cMhapep3oQHRyVpIILhFxe7HpaqTg735JX6mXkFGhuQI1ArS84HXAakwBQoEkwRfXQjuSQbyjnwUFZt1yfofRad4nBSAcf7mX6MYJOMnv)B0a28M3t(X)UOOpaqTMEECMPIAawsrN4K2zoXBa3QY0q8kQGjDtnalPd1HPI(fHtPCV3QWyyg4FxW8a4H4523SP64PI41bEdwYb(SOp2m58ejr5CrnalPObEdwYb(SOp2m5gsIY5IAawsrdyVffezGlE5f49sE4bJAzQ1HY1rA5zkmMsdQTQmjU6QOMnv)B0a28M3t(H9wurTGaPDMtXRd8gSKd8zrFSzYq9jhEZE7s1YuRdezaVzlTZMOWgGguBvzsCdjr5CrnalPObS3IcImqk4nGBvzAa7TOGiduMy6ZWuVU41bkXep3c3hiksM3d1NC4n7vrnCf79ruSYh4bL6y56AsSPY8Ucqghei2uHSmCSyDMqOy1ekw1aSKglxpNJTIITIYp3yVJZ8egBfX8akwnHID(Fw8C7yNpmHITYMCe1SP6FJgWM38EYpkXep3c3hikcY0K0oZjaRjMhWsdjZ7kazCqGIeYYWdIVI5ssK4gEd4wvMgIxrfmPBQbyjDOomv0Vin1YDCoLlN)Nfp3EGsmXZTW9bIIGmnziWaM6FZl7uCvudxXEFefRCIjEUXYZadLe73XYZPowSotiuSAcbOynafRjeOy9E(WEZoIA2u9VrdyZBEp5hLyINBzcmusAN5eyUOq4PwhMqGgENcoCoQHRyVpII9E8weRmzGy1p253imyk2uBaoI9WKhJnrrXkb(jk2VJ9a47h8rShY3tnFpwE(BghahRJIvtCuSokwl2eNnHaXkb8h46Xy1eRJfqIxvVzJ97ypa((bpwSotiuScdWrSAYJXMOOyDuSw1JPXQFSQdtX(yAuZMQ)nAaBEZ7j)WElkiYaPNhNzQOgGLu0joPDMtKeLZf1aSKIgWElkiYaPG3aUvLPbS3IcImqzIPpdZTkmgMHWaCu0KhJnrhysPNjM3N4K2BLaamjT4WWKWnLoXjT3kbaysAXzovFYbkLZ7IA4k27JOyVhVfXIBMTJXQFSZVryWuSP2aCe7HjpgBIIIvc8tuSFhR8HJypKVNA(ES883moaowNjwnXrX6OyTytC2eceReWFGRhJvtSowajEv9MnwSotiuScdWrSAYJXMOOyDuSw1JPXQFSQdtX(yAuZMQ)nAaBEZ7j)WElkmz7yAN5ScJHzimahfn5Xyt0bM0n8gWTQmneVIkysPNjM3N4K2BLaamjT4WWKWnLoXjT3kbaysAXzovFYbkLZ7Un)plEU9a)7Is1N1bMuudxXEFef794TiwoLnKgRZe7XhlwX38un2MirS6hlGyaekj2u)hIgXkRVuStdPEZgRPXI7X(GyHFafRAawsrXY11KyLjd4nBSx7SjkSbOyvltTsIruZMQ)nAaBEZ7j)WElkvzdPPDMt8gWTQmneVIkys3aMlkeEQ1b8JNGPwhENY0qArDyIxopUWTlrsuoxudWskAa7TOGidCrC)gFultToGDebooO2QYKOEDKeLZf1aSKIgWElkiYaxKhEtTm16a2re44GARktIRIA2u9VrdyZBEp5hVbl5aFw0hBMKEECMPIAawsrN4K2zobedGqjwvMUPgGL0H6Wur)IWPu4H1RFPAzQ1bSJiWXb1wvMe3eVoqjM45w4(arrY8EaigaHsSQmDv96vymmdSMbdK9MTimahnHqdmPOgUIvwIMULJD(TWv)7y1pwK(sXonK6nBSYh4bLQy)o2NHHVvnalPOy5MqDSmoBI6nBS3BSpiw4hqXIuBYbjIf(RqXATiwmK3SXMk0XzIpJf3YBoI1ArSxZ3pm27Xre44iQzt1)gnGnV59KFuIjEUfUpquKmVt7mNaIbqOeRkt3udWs6qDyQOFr4uk4(n(OwMADa7icCCqTvLjXn1YuRdj0XzIplzV5yqTvLjXnKeLZf1aSKIgWElkiYaPCxudxXYtarsXkFGhuQIftk2VJ1qXcB9XyvdWskkwdfR0JqEvMshlHBpjjnwUjuhlJZMOEZg79g7dIf(buSi1MCqIyH)kuSCDnj2uHoot8zS4wEZXiQzt1)gnGnV59KFuIjEUfUpquKmVtppoZurnalPOtCs7mNaIbqOeRkt3udWs6qDyQOFr4uk4(n(OwMADa7icCCqTvLjXn(CPAzQ1bImG3SL2ztuydqdQTQmjUHKOCUOgGLu0a2Brbrgif8gWTQmnG9wuqKbktm9zyU62L8rTm16qcDCM4Zs2BoguBvzsuV(LQLPwhsOJZeFwYEZXGARktIBijkNlQbyjfnG9wuqKbU45DxDvuZMQ)nAaBEZ7j)WElkiYaPNhNzQOgGLu0joPDMtKeLZf1aSKIgWElkiYaPG3aUvLPbS3IcImqzIPpdt6zI59joP9wjaatslommjCtPtCs7TsaaMKwCMt1NCGs58UOMnv)B0a28M3t(H9wuyY2X0ZeZ7tCs7TsaaMKwCyys4MsN4K2BLaamjT4mNQp5aLY5D3M)Nfp3EG)DrP6Z6atkQHRyVpIIv(apOuhRHInBinwaHEGgRZe73XQjuSWpEkQzt1)gnGnV59KFuIjEUfUpqueKPjrnCf79ruSYh4bLQynuSzdPXci0d0yDMy)ownHIf(XtXATiw5d8GsDSok2VJLNtDuZMQ)nAaBEZ7j)Oet8ClCFGOizEh1IA4k27JOy)owEo1XEaYhqQIv)yzjn2u)hgR6to8MnwRfXs42soGIv)yZEtXIjfBfPkbILRRjXYJVlyEaCuZMQ)nAOaV5Gu0jgIkUsWPBdMojyPJaYYLhiARNuAN5C(Fw8C7b(3ffcGjP(3dabBEJU4jo3vVEfgdZa)7cMhapWKQxF(Fw8C7b(3ffcGjP(3dabBEJs5o(sudxXkFSNXYtYtuQJLRRjXYJVlyEaCuZMQ)nAOaV5GueVN8JHOIReC62GPtVrtaMAvzQWxXSwXGlccVpP0oZzfgdZa)7cMhapWKQxF(Fw8C7b(3ffcGjP(3dabBEJsbhoh1WvSYh7zSYjePXEpyiFglxxtILhFxW8a4OMnv)B0qbEZbPiEp5hdrfxj40TbtNW20QaubLqKwGXq(mTZCwHXWmW)UG5bWdmP61N)Nfp3EG)DrHaysQ)9aqWM3OuWHZrnCfR8XEglpXyvhJLRRjXMQNlbILNSzWq(3XIHmwkDSWghuSimafR(XIAxIIvtOyZpxcPXY3KQyvdWsAuZMQ)nAOaV5GueVN8JHOIReC62GPt0JLZKQEZwayvht7mNvymmdPNlbkEZGH8VhysPNhNzQOgGLu0jornCf79ruSCYeSuSEJCbf7ZelpIBglZdIvtOyzCasJfdrX(Gy)owEo1XAmkbIvtOyzCasJfdrJyLtEGg70btmxJ1zIf)7IyjaMK6Fh78)S452X6OyXHZOyFqSWpGI14AhhrnBQ(3OHc8Mdsr8EYpgIkUsWPBdMorEZGLlSzt4M(auPYeSu5zkme4NUEmTZCwHXWmW)UG5bWdmP61N)Nfp3EG)DrHaysQ)9aqWM3OuoXHZrnCf79ruSzhPX(mX(nFlgIIvyWglfRc8MdsrX(D(ySotS8nynlb8MnwE8DrSPMQWyyI1rXAt1XtPJ9bXE8XI1auS9RXQwMALeX6T(X66iQzt1)gnuG3CqkI3t(NwoxSP6FxYost3gmDkGzlkWBoifL2zoVKpQLPwhjynlb8MTG)DXGARktI61fufgdZibRzjG3Sf8VlgysxD7YkmgMb(3fmpaEGjvV(8)S452d8Vlkeats9Vhac28gLcoC(QOgUIn1eJHL1yzSCUYMCelZdIfdzvzkwxjy0bf79ruSFh78)S452X6DSpqqGyRogRc8MdsJfLFDe1SP6FJgkWBoifX7j)yiQ4kbJs7mNvymmd8VlyEa8atQE9kmgMH0ZLafVzWq(3dmP61N)Nfp3EG)DrHaysQ)9aqWM3OuWHZqYzhPiOdHKHnVHoe6ACGoesMARktciobjpbUsa3GKRWyygv)3LNPOjuXqtQfKyGjbjJuGpvORXbs2MQ)nK80Y5Inv)7s2rkKC2rAPnycsU6)gsHU(oOdHKTP6FdjlCKeLlWgRpHKP2QYKaItqk013l0HqYuBvzsaXji5jWvc4gKmEd4wvMgs)NlmpOmfOyVfR3iRD9ySPCglUZ5yVf7LX6nYAxpg7fpJLhCHyRxpw1YuRdezaVzlTZMOWgGguBvzse7TyXBa3QY0argWB2s7SjkSbOYetFgMyVk2BXYNyN)Nfp3EW4ulgysqY2u9VHKX)UOqamj1)gsHUg3HoesMARktciobjpbUsa3GKRWyygmgvyXmGWTgnWKI9wS8jwbvHXWm4cmnHblxymc40atcs2MQ)nKmkXep3c3hiksM3qk01xa6qizQTQmjG4eKSnv)Bi5PLZfBQ(3LSJui5SJ0sBWeK8uGGuOR5HqhcjtTvLjbeNGKTP6Fdjd7TOGidajpbUsa3GKvltToqKb8MT0oBIcBaAqTvLjrS3Ifjr5CrnalPObS3IcImqSPelEd4wvMgWElkiYaLjM(mmXElw(eR41bkXep3c3hiksM3d1NC4nBS3ILpXo)plEU9GXPwmWKGKNhNzQOgGLue014aPqxZxGoesMARktciobjBt1)gswyWTP(3qYtGReWniz(elEd4wvMgwoxeVIkysqYZJZmvudWskc6ACGuOR5bqhcjtTvLjbeNGKNaxjGBqYEJS21JXEXZy5bxi2BXQwMADKG1SeWB2c(3fdQTQmjI9wSQLPwhiYaEZwANnrHnanO2QYKi2BXIKOCUOgGLu0a2Brbrgi2lEglpm261J9YyVmw1YuRJeSMLaEZwW)UyqTvLjrS3ILpXQwMADGid4nBPD2ef2a0GARktIyVk261Jfjr5CrnalPObS3IcImqSNXItSxbjBt1)gsg)7Is1Nvif6ACJqhcjtTvLjbeNGKTP6Fdjli8pgWB2Iu2yXii5jWvc4gK8LXcigaHsSQmfB96X6nYAxpgBkXYxUqSxf7TyVmw(elEd4wvMgs)NlmpOmfOyRxpwVrw76Xyt5mwEWfI9QyVf7LXYNyvltToqKb8MT0oBIcBaAqTvLjrS1Rh7LXQwMADGid4nBPD2ef2a0GARktIyVflFIfVbCRktdezaVzlTZMOWgGktm9zyI9QyVcsEECMPIAawsrqxJdKcDnoCg6qizQTQmjG4eK8e4kbCdsgjr5CrnalPObS3IcImqSxm2lJf3JL3yNFlWCDiCe6BR1cntEcnO2QYKi2RI9wSEJS21JXEXZy5bxi2BXQwMADGid4nBPD2ef2a0GARktIyRxpw(eRAzQ1bImG3SL2ztuydqdQTQmjGKTP6FdjJ)DrP6ZkKcDno4aDiKm1wvMeqCcs2MQ)nKmkXep3c3hikcY0ei5jWvc4gK8LXQgGL0rczznzin1yVyS3X5yVflsIY5IAawsrdyVffezGyVyS4ESxfB96XEzSsKoyCQfdBQoEk2BXcWAI5bS0aLyINlt2GPIeWrWdIVI5ssKi2RGKNhNzQOgGLue014aPqxJZDqhcjtTvLjbeNGKTP6FdjJWaaQfeOOFb2enHqqYtGReWniz1aSKouhMk6xeof7fJ9Ule7TyRWyyg4FxW8a4H452qYZJZmvudWskc6ACGuORX5EHoesMARktciobjBt1)gsg)7II(aa1kK8e4kbCdsgVbCRktdXROcMuS3IvnalPd1HPI(fHtXMsS3BS3ITcJHzG)DbZdGhINBh7TyTP64PI41bEdwYb(SOp2mj2ZyrsuoxudWskAG3GLCGpl6JntI9wSijkNlQbyjfnG9wuqKbI9IXEzSxiwEJ9Yy5HXEWeRAzQ1HY1rA5zkmMsdQTQmjI9QyVcsEECMPIAawsrqxJdKcDno4o0HqYuBvzsaXji5jWvc4gKS41bEdwYb(SOp2mzO(KdVzJ9wSxgRAzQ1bImG3SL2ztuydqdQTQmjI9wSijkNlQbyjfnG9wuqKbInLyXBa3QY0a2BrbrgOmX0NHj261Jv86aLyINBH7defjZ7H6to8Mn2RGKTP6Fdjd7TOIAbbGuORX5cqhcjtTvLjbeNGKNaxjGBqYaSMyEalnKmVRaKXbbksildpi(kMljrIyVflEd4wvMgIxrfmPyVfRAawshQdtf9lstTChNJnLyVm25)zXZThOet8ClCFGOiittgcmGP(3XYBSStrSxbjBt1)gsgLyINBH7defbzAcKcDno8qOdHKP2QYKaItqYtGReWnizG5IcHNADycbA4DSPeloCgs2MQ)nKmkXep3YeyOeif6AC4lqhcjtTvLjbeNGKTP6Fdjd7TOGidajppoZurnalPiORXbs2BLaamjT4mqYQp5aLY5DqYEReaGjPfhgMeUPeKmoqYtGReWnizKeLZf1aSKIgWElkiYaXMsS4nGBvzAa7TOGiduMy6ZWe7TyRWyygcdWrrtEm2eDGjbjptmVHKXbsHUghEa0HqYuBvzsaXjizBQ(3qYWElkmz7iKS3kbaysAXzGKvFYbkLZ7Un)plEU9a)7Is1N1bMeKS3kbaysAXHHjHBkbjJdK8e4kbCdsUcJHzimahfn5Xyt0bMuS3IfVbCRktdXROcMeK8mX8gsghif6ACWncDiKm1wvMeqCcsEcCLaUbjJ3aUvLPH4vubtk2BXcmxui8uRd4hpbtTo8o2uIDAiTOomflVXY5XfI9wSxglsIY5IAawsrdyVffezGyVyS4ES3ILpXQwMADa7icCCqTvLjrS1RhlsIY5IAawsrdyVffezGyVyS8WyVfRAzQ1bSJiWXb1wvMeXEfKSnv)BizyVfLQSHuif6674m0HqYuBvzsaXjizBQ(3qY4nyjh4ZI(yZei5jWvc4gKmGyaekXQYuS3IvnalPd1HPI(fHtXMsS8WyRxp2lJvTm16a2re44GARktIyVfR41bkXep3c3hiksM3daXaiuIvLPyVk261JTcJHzG1myGS3SfHb4OjeAGjbjppoZurnalPiORXbsHU(oCGoesMARktciobjpbUsa3GKbedGqjwvMI9wSQbyjDOomv0ViCk2uIf3J9wS8jw1YuRdyhrGJdQTQmjI9wSQLPwhsOJZeFwYEZXGARktIyVflsIY5IAawsrdyVffezGytj27GKTP6FdjJsmXZTW9bIIK5nKcD9D3bDiKm1wvMeqCcs2MQ)nKmkXep3c3hiksM3qYtGReWnizaXaiuIvLPyVfRAawshQdtf9lcNInLyX9yVflFIvTm16a2re44GARktIyVflFI9YyvltToqKb8MT0oBIcBaAqTvLjrS3Ifjr5CrnalPObS3IcImqSPelEd4wvMgWElkiYaLjM(mmXEvS3I9Yy5tSQLPwhsOJZeFwYEZXGARktIyRxp2lJvTm16qcDCM4Zs2BoguBvzse7TyrsuoxudWskAa7TOGide7fpJ9UyVk2RGKNhNzQOgGLue014aPqxF39cDiKm1wvMeqCcs2MQ)nKmS3IcImaK884mtf1aSKIGUghizVvcaWK0IZajR(KdukN3bj7TsaaMKwCyys4MsqY4ajpbUsa3GKrsuoxudWskAa7TOGideBkXI3aUvLPbS3IcImqzIPpddK8mX8gsghif667WDOdHKP2QYKaItqY2u9VHKH9wuyY2rizVvcaWK0IZajR(KdukN3DB(Fw8C7b(3fLQpRdmjizVvcaWK0Iddtc3ucsghi5zI5nKmoqk013DbOdHKTP6FdjJsmXZTW9bIIGmnbsMARktciobPqxFhpe6qizBQ(3qYOet8ClCFGOizEdjtTvLjbeNGuifswaZwuG3Cqkc6qORXb6qizQTQmjG4eKCBWeKSWaCa)Fxe0KJsrctbeAs9KGKTP6FdjlmahW)3fbn5OuKWuaHMupjif667GoesMARktciobj3gmbjJW6Q8)IIbtAYrKcjBt1)gsgH1v5)ffdM0KJifsHU(EHoesMARktciobj3gmbjZMpkLuEMIHqoSNn1)gs2MQ)nKmB(Ous5zkgc5WE2u)Bif6ACh6qizQTQmjG4eKCBWeKSaqMGXbubpHqugs2MQ)nKSaqMGXbubpHqugsHuizbXyyzf6qORXb6qizBQ(3qYipt9KGKP2QYKaItqk013bDiKm1wvMeqCcsEcCLaUbjxHXWmW)UG5bWdmPyRxp2kmgMH0ZLafVzWq(3dmjizBQ(3qYsV6FdPqxFVqhcjtTvLjbeNGKFjizePqY2u9VHKXBa3QYeKmElJrqYIxhOet8ClCFGOizEpuFYH3SXElwXRd8gSKd8zrFSzYq9jhEZcjJ3aL2GjizXROcMeKcDnUdDiKm1wvMeqCcs(LGKrKcjBt1)gsgVbCRktqY4TmgbjlEDGsmXZTW9bIIK59q9jhEZg7TyfVoWBWsoWNf9XMjd1NC4nBS3Iv86qq4FmG3SfPSXIrd1NC4nlKmEduAdMGKTCUiEfvWKGuORVa0HqYuBvzsaXji5xcsgrkKSnv)Biz8gWTQmbjJ3YyeKmsIY5IAawsrdyVffezGytj27IL3yRWyyg4FxW8a4bMeKmEduAdMGKrKb8MT0oBIcBaQmX0NHbsHUMhcDiKm1wvMeqCcs(LGKrKcjBt1)gsgVbCRktqY4Tmgbjp)plEU9a)7IcbWKu)7bMuS3I9Yy5tSaZffcp16Wec0atk261JfyUOq4PwhMqGgcmGP(3XEXZyXHZXwVESaZffcp16Wec0aqWM3Oyt5mwC4CS8g7fI9Gj2lJvTm16ibRzjG3Sf8VlguBvzseB96XoF8uBTo44iWTo2RI9QyVf7LXEzSaZffcp16Wec0W7ytj274CS1RhlsIY5IAawsrd8Vlkeats9VJnLZyVqSxfB96XQwMADKG1SeWB2c(3fdQTQmjITE9yNpEQTwhCCe4wh7vqY4nqPnycsw6)CH5bLPabPqxZxGoesMARktciobjpbUsa3GKRWyyg4FxW8a4bMeKSnv)Bizghqv5)fqk018aOdHKP2QYKaItqYtGReWni5kmgMb(3fmpaEGjbjBt1)gsUIaicWH3Sqk014gHoesMARktciobjpbUsa3GKrsuoxudWskAKD2efvoyXeSWuRXMYzS3fB96XEzS8jwG5IcHNADycbAq42osrXwVESaZffcp16Wec0W7ytjw(YfI9kizBQ(3qYzNnrrLdwmblm1kKcDnoCg6qizQTQmjG4eK8e4kbCdsUcJHzG)DbZdGhysqY2u9VHKTEsify5Y0Yzif6ACWb6qizQTQmjG4eKSnv)Bi5PLZfBQ(3LSJui5SJ0sBWeK8K7esHUgN7GoesMARktciobjBt1)gsgG1fBQ(3LSJui5SJ0sBWeKmS5nKcPqYsaA(WvMcDi014aDiKm1wvMeqCcsEcCLaUbjdiyZBuSxm27LZCgs2MQ)nKS0ZLafUpquyEG6kMGGuORVd6qizQTQmjG4eK8e4kbCdsMpXwHXWmqjM45Y8a4bMeKSnv)BizuIjEUmpagsHU(EHoesMARktciobjpbUsa3GK9gzTRhhcIXNUgBkXIZfGKTP6FdjBGP1urFaGAfsHUg3HoesMARktciobj)sqYisHKTP6FdjJ3aUvLjiz8wgJGKVdsgVbkTbtqYWElkiYaLjM(mmqk01xa6qizBQ(3qY4nyjh4ZI(yZeizQTQmjG4eKcPqYtbc6qORXb6qizQTQmjG4eKSnv)BizKNPEsqYtGReWnizawtmpGLgiskbd3aQib(z2Gn1)Eq8vmxsIeXEl2lJvnalPdhvmHi261JvnalPdbvHXWmMgs9MDaiBQXEfK884mtf1aSKIGUghif667GoesMARktciobjBt1)gsEA5CXMQ)Dj7ifso7iT0gmbjRaV5GueKcPqYkWBoifbDi014aDiKm1wvMeqCcs2MQ)nKmblDeqwU8arB9KGKNaxjGBqYZ)ZINBpW)UOqamj1)EaiyZBuSx8mwCUl261JTcJHzG)DbZdGhysXwVESZ)ZINBpW)UOqamj1)EaiyZBuSPe7D8fi52Gjizcw6iGSC5bI26jbPqxFh0HqYuBvzsaXjizBQ(3qYEJMam1QYuHVIzTIbxeeEFsqYtGReWni5kmgMb(3fmpaEGjfB96Xo)plEU9a)7IcbWKu)7bGGnVrXMsS4Wzi52GjizVrtaMAvzQWxXSwXGlccVpjif667f6qizQTQmjG4eKSnv)BizyBAvaQGsislWyiFcjpbUsa3GKRWyyg4FxW8a4bMuS1Rh78)S452d8Vlkeats9Vhac28gfBkXIdNHKBdMGKHTPvbOckHiTaJH8jKcDnUdDiKm1wvMeqCcsUnycsg9y5mPQ3Sfaw1ri55XzMkQbyjfbDnoqYtGReWni5kmgMH0ZLafVzWq(3dmjizBQ(3qYOhlNjv9MTaWQocPqxFbOdHKP2QYKaItqY2u9VHKrEZGLlSzt4M(auPYeSu5zkme4NUEesEcCLaUbjxHXWmW)UG5bWdmPyRxp25)zXZTh4FxuiaMK6FpaeS5nk2uoJfhodj3gmbjJ8MblxyZMWn9bOsLjyPYZuyiWpD9iKcDnpe6qizQTQmjG4eK8e4kbCds(Yy5tSQLPwhjynlb8MTG)DXGARktIyRxpwbvHXWmsWAwc4nBb)7IbMuSxf7TyVm2kmgMb(3fmpaEGjfB96Xo)plEU9a)7IcbWKu)7bGGnVrXMsS4W5yVcs2MQ)nK80Y5Inv)7s2rkKC2rAPnycswaZwuG3CqkcsHUMVaDiKm1wvMeqCcsEcCLaUbjxHXWmW)UG5bWdmPyRxp2kmgMH0ZLafVzWq(3dmPyRxp25)zXZTh4FxuiaMK6FpaeS5nk2uIfhodjBt1)gsgdrfxjyeKcPqYv)3qhcDnoqhcjtTvLjbeNGKNaxjGBqYijkNlQbyjfnG9wuqKbI9INXEVqY2u9VHKn0KAbjkvzdPqk013bDiKm1wvMeqCcsEcCLaUbjFzSijkNlQbyjfnG9wuqKbInLyVl2BXQwMADGid4nBPD2ef2a0GARktIyRxp2lJfjr5CrnalPObS3IcImqSPeloXElw(eRAzQ1bImG3SL2ztuydqdQTQmjI9QyVk2BXIKOCUOgGLu0WqtQfKO0pEl2uIfhizBQ(3qYgAsTGeL(XBqkKcjp5oHoe6ACGoesMARktciobjJHOc3eptLPHuVzHUghizBQ(3qYiYaEZwANnrHnabjppoZurnalPiORXbsEcCLaUbjFzS4nGBvzAGid4nBPD2ef2auzIPpdtS3ILpXI3aUvLPH0)5cZdktbk2RITE9yVmwXRduIjEUfUpquKmVhaIbqOeRktXElwKeLZf1aSKIgWElkiYaXMsS4e7vqk013bDiKm1wvMeqCcsgdrfUjEMktdPEZcDnoqY2u9VHKrKb8MT0oBIcBacsEECMPIAawsrqxJdK8e4kbCdswTm16argWB2s7SjkSbOb1wvMeXElwXRduIjEUfUpquKmVhaIbqOeRktXElwKeLZf1aSKIgWElkiYaXMsS3bPqxFVqhcjtTvLjbeNGK)oFSm5oHKXbs2MQ)nKmS3Isv2qkKcPqkKmEcG8VHU(ooFhNX5ooJdKmxd0EZIGK5jHLEGsIy5bXAt1)o2SJu0iQbjJKOj013DbEaKSe4z8mbjJRyLtmXZn2ubCcPrnCfBQPjbxrGyXjDS3X574CulQHRyp4420etjrSveZdOyNpCLPXwrSEJgXEaZjjPOy7V5BtmamdwowBQ(3Oy)oFCe1SP6FJgsaA(WvMY7j)spxcu4(arH5bQRyckTZCciyZB0fVxoZ5OMnv)B0qcqZhUYuEp5hLyINlZdGt7mN8PcJHzGsmXZL5bWdmPOMnv)B0qcqZhUYuEp53atRPI(aa1AAN50BK1UECiigF6Ak4CHOMnv)B0qcqZhUYuEp5hVbCRktPBdMoH9wuqKbktm9zys)sNistJ3Yy05DrnBQ(3OHeGMpCLP8EYpEdwYb(SOp2mjQf1WvSP6v)BuuZMQ)n6e5zQNuuZMQ)n6u6v)70oZzfgdZa)7cMhapWKQxVcJHzi9CjqXBgmK)9atkQzt1)gX7j)4nGBvzkDBW0P4vubtk9lDIinnElJrNIxhOet8ClCFGOizEpuFYH3S3eVoWBWsoWNf9XMjd1NC4nBuZMQ)nI3t(XBa3QYu62GPtlNlIxrfmP0V0jI004TmgDkEDGsmXZTW9bIIK59q9jhEZEt86aVbl5aFw0hBMmuFYH3S3eVoee(hd4nBrkBSy0q9jhEZg1WvSYQb0yXqEZgRmzaVzJ9ANnrHnafRPXEV8gRAawsrX(GyXDEJ1zI94JfRbOy9owE8DbZdGJA2u9Vr8EYpEd4wvMs3gmDIid4nBPD2ef2auzIPpdt6x6erAA8wgJorsuoxudWskAa7TOGidKYD8wHXWmW)UG5bWdmPOgUILN)plEUDSP6)CS8ObCRktPJ9(iseR(Xk9Fo2kI5buS2uD8M6nBS4FxW8a4rS8mgaqTMpglgIeXQFSZVvWNJLBc1XQFS2uD8MsXI)DbZdGJLRRjX698H9MnwtiqJOMnv)BeVN8J3aUvLP0TbtNs)NlmpOmfO0V0jI004TmgDo)plEU9a)7IcbWKu)7bM0Tl5dWCrHWtTomHanWKQxhyUOq4PwhMqGgcmGP(3x8ehoxVoWCrHWtTomHanaeS5nkLtC4mVx4G5s1YuRJeSMLaEZwW)UyqTvLjr96Zhp1wRdoocCRV6QBxEjWCrHWtTomHan8oL74C96ijkNlQbyjfnW)UOqamj1)oLZlCv96QLPwhjynlb8MTG)DXGARktI61NpEQTwhCCe4wFvuZMQ)nI3t(zCavL)xK2zoRWyyg4FxW8a4bMuuZMQ)nI3t(RiaIaC4nBAN5ScJHzG)DbZdGhysrnCf79ruS4woBIYtrXwdtWctTgRZeRMqakwdqXExSpiw4hqXQgGLuu6yFqSMqGI1auZt1yrsg32B2yzEqSWpGIvtSow(YfqJOMnv)BeVN8ND2efvoyXeSWuRPDMtKeLZf1aSKIgzNnrrLdwmblm1AkN3vV(L8byUOq4PwhMqGgeUTJuu96aZffcp16Wec0W7u4lx4QOMnv)BeVN8B9KqkWYLPLZPDMZkmgMb(3fmpaEGjf1SP6FJ49K)PLZfBQ(3LSJ00TbtNtUZOMnv)BeVN8dW6Inv)7s2rA62GPtyZ7OwudxXEaPc3kw9JfdrXYnH6y50)DSptSAcf7bGMulirSokwBQoEkQzt1)gnQ(Vpn0KAbjkvzdPPDMtKeLZf1aSKIgWElkiYax88EJA2u9VrJQ)BEp53qtQfKO0pElTZCEjsIY5IAawsrdyVffezGuU7MAzQ1bImG3SL2ztuydqdQTQmjQx)sKeLZf1aSKIgWElkiYaPGZn(OwMADGid4nBPD2ef2a0GARktIRU6gsIY5IAawsrddnPwqIs)4TuWjQf1WvS8CQrrnCf79ruSYEM6jf73XYZPow9Jvc8ZyLjPemCd8uuSPc8ZSbBQ)9iQzt1)gnMceVN8J8m1tk984mtf1aSKIoXjTZCcWAI5bS0arsjy4gqfjWpZgSP(3dIVI5ssK42LQbyjD4OIje1RRgGL0HGQWyygtdPEZoaKn1RIA2u9VrJPaX7j)tlNl2u9VlzhPPBdMovG3CqkkQf1WvS8SH0ypWeptXYZgs9MnwBQ(3OrSYKgRPXM4SjeiwjG)axpgR(XIsEGg70btmxJ1BLaamjn253cx9VrX(DS3J3IyLjdWpUz2og1WvS3hrXktgWB2yV2ztuydqX6mXE8XILRNZXM4ASu)ySjXQgGLuuSwlInvpxcelpzZGH8VJ1ArS847cMhahRbOy7xJfqM4y6yFqS6hlGyaekjw5d8GsvSFhRY9J9bXc)akw1aSKIgrnBQ(3OXK78ergWB2s7SjkSbO0yiQWnXZuzAi1B2tCsppoZurnalPOtCs7mNxI3aUvLPbImG3SL2ztuydqLjM(mm34dEd4wvMgs)NlmpOmfORQx)sXRduIjEUfUpquKmVhaIbqOeRkt3qsuoxudWskAa7TOGidKcoxf1WvSYjpqJLNDWeZ1yLjd4nBSx7SjkSbOyNFlC1)ow9JLdIKIv(apOuflMuSEh7b8h8OMnv)B0yYDY7j)iYaEZwANnrHnaLgdrfUjEMktdPEZEIt65XzMkQbyjfDItAN5uTm16argWB2s7SjkSbOb1wvMe3eVoqjM45w4(arrY8EaigaHsSQmDdjr5CrnalPObS3IcImqk3f1WvSFNpwMCNXcBCqOy1ekwBQ(3X(D(ySyiRktXkWaEZg7mX6MYEZgR1Iy7xJ1qXAXciwSSbI1MQ)9iQzt1)gnMCN8EYpS3Isv2qA6VZhltUZtCIArnBQ(3OHaMTOaV5Gu0jgIkUsWPBdMofgGd4)7IGMCuksykGqtQNuuZMQ)nAiGzlkWBoifX7j)yiQ4kbNUny6eH1v5)ffdM0KJinQzt1)gneWSff4nhKI49KFmevCLGt3gmDYMpkLuEMIHqoSNn1)oQzt1)gneWSff4nhKI49KFmevCLGt3gmDkaKjyCavWtieLJArnCf79yEh7bKkCR0XIsESSi25JNaXA5CSaRzjuSptSQbyjffR1IyrtQnG)OOMnv)B0a28M3t(NwoxSP6FxYost3gmDw9FNgPaFQN4K2zoRWyygv)3LNPOjuXqtQfKyGjf1SP6FJgWM38EYVWrsuUaBS(mQHRyVpIILhFxe7bhGjP(3X(DSZ)ZINBhR0)zVzJ10yZKH0yXDohR3iRD9ySvyAS9RX6mXE8XILRNZX(4jW0KI1BK1UEmwVJLhXnhXEpghuSimaflkXepxgNAb)WElQOwqGyDuSFh78)S452XwrmpGILhp4JOMnv)B0a28(e)7IcbWKu)70oZjEd4wvMgs)NlmpOmfOBEJS21JPCI7C(2LEJS21Jx8KhCH61vltToqKb8MT0oBIcBaAqTvLjXn8gWTQmnqKb8MT0oBIcBaQmX0NH5QB8z(Fw8C7bJtTyGjf1WvS3JXbflcdqXE8XIvctJftkw5d8GsvShG8bKQy)ownHIvnalPX6mXEGattyWYXIBAeWPyDuZt1yTP64PruZMQ)nAaBEZ7j)Oet8ClCFGOizEN2zoRWyygmgvyXmGWTgnWKUXhbvHXWm4cmnHblxymc40atkQzt1)gnGnV59K)PLZfBQ(3LSJ00TbtNtbkQHRy5BC2KytfWFGRhJ9E8weRmzGyTP6FhR(XcigaHsIn1)HOy56AsSiYaEZwANnrHnaf1SP6FJgWM38EYpS3IcImq65XzMkQbyjfDItAN5uTm16argWB2s7SjkSbOb1wvMe3qsuoxudWskAa7TOGidKcEd4wvMgWElkiYaLjM(mm34J41bkXep3c3hiksM3d1NC4n7n(m)plEU9GXPwmWKIA4k2ubigceR(XIHOytTb3M6Fh7biFaPkwNjwRpgBQ)dJ1rX2VglM0iQzt1)gnGnV59KFHb3M6FNEECMPIAawsrN4K2zo5dEd4wvMgwoxeVIkysrnCf79ruS847Iy50N1ynn2eNnHaXkb8h46Xy56AsS8nynlb8MnwE8DrSysXQFS4ESQbyjfLo2he7Rjeiw1YuROy)ow5dhrnBQ(3ObS5nVN8J)DrP6ZAAN50BK1UE8IN8GlCtTm16ibRzjG3Sf8VlguBvzsCtTm16argWB2s7SjkSbOb1wvMe3qsuoxudWskAa7TOGidCXtEy96xEPAzQ1rcwZsaVzl4FxmO2QYK4gFultToqKb8MT0oBIcBaAqTvLjXv1RJKOCUOgGLu0a2Brbrg4eNRIA4k2u)npvJfdrXMAc)Jb8Mn2uLnwmkwNj2JpwStRJLL0y9w)y5X3fmpaowVrkzI0X(GyDMyLjd4nBSx7SjkSbOyDuSQLPwjrSwlILRNZXM4ASu)ySjXQgGLu0iQzt1)gnGnV59KFbH)XaEZwKYglgLEECMPIAawsrN4K2zoVeqmacLyvzQEDVrw76Xu4lx4QBxYh8gWTQmnK(pxyEqzkq1R7nYAxpMYjp4cxD7s(OwMADGid4nBPD2ef2a0GARktI61VuTm16argWB2s7SjkSbOb1wvMe34dEd4wvMgiYaEZwANnrHnavMy6ZWC1vrnCf79ruS8iNI97y55uhRZe7XhlwX38un2MirS6h70qASPMW)yaVzJnvzJfJshR1Iy1ecqXAak2mHqXQjwhlUhRAawsrX(yASxEHy56AsSZVfyUE1iQzt1)gnGnV59KF8VlkvFwt7mNijkNlQbyjfnG9wuqKbU4L4oVZVfyUoeoc9T1AHMjpHguBvzsC1nVrw76XlEYdUWn1YuRdezaVzlTZMOWgGguBvzsuVoFultToqKb8MT0oBIcBaAqTvLjrudxXEFefRCIjEUXEGpqCqXMAY0KyDMy1ekw1aSKgRJI1QEmnw9Jv4uSpi2JpwSjgEkw5et8CzYgmfBQaocowIVI5ssKiwUUMe794TOIAbbI9bXkNyINlJtTiwBQoEAe1SP6FJgWM38EYpkXep3c3hikcY0K0ZJZmvudWsk6eN0oZ5LQbyjDKqwwtgst9I3X5BijkNlQbyjfnG9wuqKbUiUFv96xkr6GXPwmSP64PBaSMyEalnqjM45YKnyQibCe8G4RyUKejUkQHRyVpIIvgdaOwqGy1p27XenHqX(DSwSQbyjnwnX0yDuSSV3SXQFScNI10y1ekwGZMOXQomnIA2u9VrdyZBEp5hHbauliqr)cSjAcHsppoZurnalPOtCs7mNQbyjDOomv0ViC6I3DHBvymmd8VlyEa8q8C7OgUI9(ikwE8DrSh(aa1ASFNpgRZeR8bEqPkwRfXYJhgRbOyTP64PyTweRMqXQgGL0y5(npvJv4uScmG3SXQjuSZeRBkpIA2u9VrdyZBEp5h)7II(aa1A65XzMkQbyjfDItAN5eVbCRktdXROcM0n1aSKouhMk6xeoLY9ERcJHzG)DbZdGhINBFZMQJNkIxh4nyjh4ZI(yZKtKeLZf1aSKIg4nyjh4ZI(yZKBijkNlQbyjfnG9wuqKbU4LxG3l5HhmQLPwhkxhPLNPWyknO2QYK4QRIA2u9VrdyZBEp5h2Brf1ccK2zofVoWBWsoWNf9XMjd1NC4n7TlvltToqKb8MT0oBIcBaAqTvLjXnKeLZf1aSKIgWElkiYaPG3aUvLPbS3IcImqzIPpdt96IxhOet8ClCFGOizEpuFYH3Sxf1WvS3hrXkFGhuQJLRRjXMkZ7kazCqGytfYYWXI1zcHIvtOyvdWsASC9Co2kk2kk)CJ9ooZtySveZdOy1ek25)zXZTJD(Wek2kBYruZMQ)nAaBEZ7j)Oet8ClCFGOiitts7mNaSMyEalnKmVRaKXbbksildpi(kMljrIB4nGBvzAiEfvWKUPgGL0H6Wur)I0ul3X5uUC(Fw8C7bkXep3c3hikcY0KHadyQ)nVStXvrnCf79ruSYjM45glpdmusSFhlpN6yX6mHqXQjeGI1auSMqGI175d7n7iQzt1)gnGnV59KFuIjEULjWqjPDMtG5IcHNADycbA4Dk4W5OgUI9(ik27XBrSYKbIv)yNFJWGPytTb4i2dtEm2effRe4NOy)o2dGVFWhXEiFp189y55VzCaCSokwnXrX6OyTytC2eceReWFGRhJvtSowajEv9Mn2VJ9a47h8yX6mHqXkmahXQjpgBIII1rXAvpMgR(XQomf7JPrnBQ(3ObS5nVN8d7TOGidKEECMPIAawsrN4K2zorsuoxudWskAa7TOGidKcEd4wvMgWElkiYaLjM(mm3QWyygcdWrrtEm2eDGjLEMyEFItAVvcaWK0Iddtc3u6eN0EReaGjPfN5u9jhOuoVlQHRyVpII9E8welUz2ogR(Xo)gHbtXMAdWrShM8ySjkkwjWprX(DSYhoI9q(EQ57XYZFZ4a4yDMy1ehfRJI1InXztiqSsa)bUEmwnX6ybK4v1B2yX6mHqXkmahXQjpgBIII1rXAvpMgR(XQomf7JPrnBQ(3ObS5nVN8d7TOWKTJPDMZkmgMHWaCu0KhJnrhys3WBa3QY0q8kQGjLEMyEFItAVvcaWK0Iddtc3u6eN0EReaGjPfN5u9jhOuoV728)S452d8VlkvFwhysrnCf79ruS3J3Iy5u2qASotShFSyfFZt1yBIeXQFSaIbqOKyt9FiAeRS(sXonK6nBSMglUh7dIf(buSQbyjfflxxtIvMmG3SXETZMOWgGIvTm1kjgrnBQ(3ObS5nVN8d7TOuLnKM2zoXBa3QY0q8kQGjDdyUOq4PwhWpEcMAD4DktdPf1HjE584c3Uejr5CrnalPObS3IcImWfX9B8rTm16a2re44GARktI61rsuoxudWskAa7TOGidCrE4n1YuRdyhrGJdQTQmjUkQzt1)gnGnV59KF8gSKd8zrFSzs65XzMkQbyjfDItAN5eqmacLyvz6MAawshQdtf9lcNsHhwV(LQLPwhWoIahhuBvzsCt86aLyINBH7defjZ7bGyaekXQY0v1RxHXWmWAgmq2B2IWaC0ecnWKIA4kwzjA6wo253cx9VJv)yr6lf70qQ3SXkFGhuQI97yFgg(w1aSKIILBc1XY4SjQ3SXEVX(GyHFaflsTjhKiw4VcfR1IyXqEZgBQqhNj(mwClV5iwRfXEnF)WyVhhrGJJOMnv)B0a28M3t(rjM45w4(arrY8oTZCcigaHsSQmDtnalPd1HPI(fHtPG734JAzQ1bSJiWXb1wvMe3ultToKqhNj(SK9MJb1wvMe3qsuoxudWskAa7TOGidKYDrnCflpbejfR8bEqPkwmPy)owdflS1hJvnalPOynuSspc5vzkDSeU9KK0y5MqDSmoBI6nBS3BSpiw4hqXIuBYbjIf(RqXY11Kytf64mXNXIB5nhJOMnv)B0a28M3t(rjM45w4(arrY8o984mtf1aSKIoXjTZCcigaHsSQmDtnalPd1HPI(fHtPG734JAzQ1bSJiWXb1wvMe34ZLQLPwhiYaEZwANnrHnanO2QYK4gsIY5IAawsrdyVffezGuWBa3QY0a2BrbrgOmX0NH5QBxYh1YuRdj0XzIplzV5yqTvLjr96xQwMADiHoot8zj7nhdQTQmjUHKOCUOgGLu0a2Brbrg4IN3D1vrnBQ(3ObS5nVN8d7TOGidKEECMPIAawsrN4K2zorsuoxudWskAa7TOGidKcEd4wvMgWElkiYaLjM(mmPNjM3N4K2BLaamjT4WWKWnLoXjT3kbaysAXzovFYbkLZ7IA2u9VrdyZBEp5h2BrHjBhtptmVpXjT3kbaysAXHHjHBkDItAVvcaWK0IZCQ(KdukN3DB(Fw8C7b(3fLQpRdmPOgUI9(ikw5d8GsDSgk2SH0ybe6bASotSFhRMqXc)4POMnv)B0a28M3t(rjM45w4(arrqMMe1WvS3hrXkFGhuQI1qXMnKglGqpqJ1zI97y1ekw4hpfR1IyLpWdk1X6Oy)owEo1rnBQ(3ObS5nVN8JsmXZTW9bIIK5DulQHRyVpII97y55uh7biFaPkw9JLL0yt9FySQp5WB2yTwelHBl5akw9Jn7nflMuSvKQeiwUUMelp(UG5bWrnBQ(3OHc8MdsrNyiQ4kbNUny6KGLocilxEGOTEsPDMZ5)zXZTh4FxuiaMK6FpaeS5n6IN4Cx96vymmd8VlyEa8atQE95)zXZTh4FxuiaMK6FpaeS5nkL74lrnCfR8XEglpjprPowUUMelp(UG5bWrnBQ(3OHc8Mdsr8EYpgIkUsWPBdMo9gnbyQvLPcFfZAfdUii8(Ks7mNvymmd8VlyEa8atQE95)zXZTh4FxuiaMK6FpaeS5nkfC4CudxXkFSNXkNqKg79GH8zSCDnjwE8DbZdGJA2u9Vrdf4nhKI49KFmevCLGt3gmDcBtRcqfucrAbgd5Z0oZzfgdZa)7cMhapWKQxF(Fw8C7b(3ffcGjP(3dabBEJsbhoh1WvSYh7zS8eJvDmwUUMeBQEUeiwEYMbd5FhlgYyP0XcBCqXIWauS6hlQDjkwnHIn)CjKglFtQIvnalPrnBQ(3OHc8Mdsr8EYpgIkUsWPBdMorpwotQ6nBbGvDmTZCwHXWmKEUeO4ndgY)EGjLEECMPIAawsrN4e1WvS3hrXYjtWsX6nYfuSptS8iUzSmpiwnHILXbinwmef7dI97y55uhRXOeiwnHILXbinwmenIvo5bASthmXCnwNjw8VlILaysQ)DSZ)ZINBhRJIfhoJI9bXc)akwJRDCe1SP6FJgkWBoifX7j)yiQ4kbNUny6e5ndwUWMnHB6dqLktWsLNPWqGF66X0oZzfgdZa)7cMhapWKQxF(Fw8C7b(3ffcGjP(3dabBEJs5ehoh1WvS3hrXMDKg7Ze738TyikwHbBSuSkWBoiff735JX6mXY3G1SeWB2y5X3fXMAQcJHjwhfRnvhpLo2he7XhlwdqX2VgRAzQvseR36hRRJOMnv)B0qbEZbPiEp5FA5CXMQ)Dj7inDBW0PaMTOaV5GuuAN58s(OwMADKG1SeWB2c(3fdQTQmjQxxqvymmJeSMLaEZwW)UyGjD1TlRWyyg4FxW8a4bMu96Z)ZINBpW)UOqamj1)EaiyZBuk4W5RIA4k2utmgwwJLXY5kBYrSmpiwmKvLPyDLGrhuS3hrX(DSZ)ZINBhR3X(abbIT6ySkWBoinwu(1ruZMQ)nAOaV5GueVN8JHOIRemkTZCwHXWmW)UG5bWdmP61RWyygspxcu8Mbd5FpWKQxF(Fw8C7b(3ffcGjP(3dabBEJsbhodPqkeea]] )


end
