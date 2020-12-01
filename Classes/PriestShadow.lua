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


    spec:RegisterPack( "Shadow", 20201201, [[d80YpbqiOKEevcxsOsf2KKYNuQknkjvoLsjRsPuIxjumlqLBHsvHDPKFjPQHbL4yGILju1ZqPstduvUMqfBdLQ8nuQW4uQQ6CkLsToLsL5rLO7bf7JkPdcQsTqHspuPumrqv1fvQkAJGQeFuOsfnsHkv6KkLsALkvEjkvfzMGQKUjkv0oHs9tLQcdfuflfLQI6PGmvukxvOs2QsvLVQuQAVe(lvnyvomPflKhlXKj6YiBgQ(mQmAj50IwTqLQETsvMTGBJIDR43adNkoUqLYYv1ZHmDkxhvTDuY3PsnEuQkDEqP1Jsv18vk2VulGrWMasQgjWoESepwGjESaZcg2f(yhSBCeqgSoKaYrl7PCKaAugsabvPsGBbKJcBaOsbBcieG)lKaQYmh02vF9CPvXhTkaM6rjdFqTemLxXT6rjtPEbueFgST1rejGKQrcSJhlXJfyIhlWSGHDHp2r8XlGuERc8ciOKzBeqvPusJisajjura5I(GQujWDFWZNeY6DUOp4Nkete99bdC9fpwIhlcOqImKGnbeHq0uiKGnb2WiytaPflbJaIHyapSEaUpWxsPx(KYGeq0OrbskIvycSJxWMaslwcgbuuaaKEaU3QipnedSciA0OajfXkmb2SRGnbKwSemcioE9LPoEaUxz)0dSkbenAuGKIyfMaB4tWMaIgnkqsrScOYNg9PkGqoui4n95idTyYr6rK(95kM(IVVnB671u6jw0ylvkrRC6Z1(ypSiG0ILGraHdk8is6v2p9Pr(iszeMa74iytarJgfiPiwbu5tJ(ufqihke8M(CKHwm5i9is)(CftFX33Mn99Ak9elASLkLOvo95AFShweqAXsWiGC4)eh2C48rbfzctGn7jytarJgfiPiwbKwSemcOcyk0yVAK0Jhugsav(0OpvbKLmuFUetFWGL(2SPpC(qW)uPsFoYBjd1Nl7JRi7BZM(m95iBzjd5nGxMuFUSV4iGc5q(IuaXEctGn7qWMaslwcgb0NoobYNJh5OfsarJgfiPiwHjWE)fSjG0ILGra9K6KdNhpOmesarJgfiPiwHjWEBlytaPflbJaYn4dswuo(NqGrNcjGOrJcKueRWeyddweSjG0ILGrazvKNFIa8J0Jd(cjGOrJcKueRWeMass4kFWeSjWggbBciTyjyeqOmqtHeq0OrbskIvycSJxWMaIgnkqsrScOYNg9PkGI4XXxSaPeh8mlEN(2SPViEC8LdWn9(CW5rjyw8ociTyjyeqoalbJWeyZUc2eq0OrbskIvabCeqiYeqAXsWiGyPFQrbsaXsd8KascSfQsLa3E3Gx6D0Cwww2lhU(Q1NeylwkJt(zXBa(s1YYYE5WjGyPVFugsajbgYZ7imb2WNGnbenAuGKIyfqahbeImbKwSemciw6NAuGeqS0apjGKaBHQujWT3n4LEhnNLLL9YHRVA9jb2ILY4KFw8gGVuTSSSxoC9vRpjWwsIfG)ZHZ7euoEAzzzVC4eqS03pkdjG0qWlbgYZ7imb2XrWMaIgnkqsrSciGJacrMaslwcgbel9tnkqciwAGNeqihke8M(CKHwm5i9is)(CTV47lM(I4XXxSaPeh8mlEhbel99JYqciePFoC(j5Qmg9jFH3a44ctGn7jytarJgfiPiwbeWraHitaPflbJaIL(PgfibelnWtcOcaeKa3ZIfiLE65DSemlEN(Q1xD9H1(EnLEIfn2sLs0I3PVnB671u6jw0ylvkrlj)RwcM(CjM(Gbl9TztFVMspXIgBPsjA9eJMdQpxX0hmyPVy6lo9TT0xD9zAGgBvXpC0NdNNfiLlA0Oaj7BZM(kaw0OJT2d2p1PVT6BR(Q1xD9vxFVMspXIgBPsjALtFU2x8yPVnB6d5qHG30NJm0IfiLE65DSem95kM(ItFB13Mn9zAGgBvXpC0NdNNfiLlA0Oaj7BZM(kaw0OJT2d2p1PVTeqS03pkdjGCaGGhh8(Iejmb2SdbBciA0OajfXkGkFA0NQakIhhFXcKsCWZS4DeqAXsWiGWZNIcaGuycS3FbBciA0OajfXkGkFA0NQakIhhFXcKsCWZS4DeqAXsWiGIOhr)E5Wjmb2BBbBciA0OajfXkGkFA0NQac5qHG30NJm0kKCvgYh3Zl5yOX6Zvm9fFFB20xD9H1(EnLEIfn2sLs0IyFtKH6BZM(EnLEIfn2sLs0kN(CTp2rC6BlbKwSemcOqYvziFCpVKJHgtycSHblc2eq0OrbskIvav(0Opvbuepo(IfiL4GNzX7iG0ILGraPtHq2RbFrdbHjWggyeSjGOrJcKueRaslwcgburdbVwSem(qImbuirMFugsavCxeMaByIxWMaIgnkqsrSciTyjyeqp)41ILGXhsKjGcjY8JYqcignhHjmbKZtfatKAc2eydJGnbenAuGKIyfqLpn6tva9eJMdQpx2h7IfSiG0ILGra5aCtV3n4LECWBPXljHjWoEbBciA0OajfXkGkFA0NQacR9fXJJVqvQe4gh8mlEhbKwSemciuLkbUXbpJWeyZUc2eq0OrbskIvav(0OpvbuoiDsd2LKWZsA95AFWehbKwSemci9l6qEd8pnMWeydFc2eq0OrbskIvankdjGu2pQsFf5XbJ5b4EhGB6fqAXsWiGu2pQsFf5XbJ5b4EhGB6fMa74iytarJgfiPiwbeWraHitaPflbJaIL(PgfibelnWtcO4fqS03pkdjGyYr6rK((cVbWXfMaB2tWMaslwcgbelLXj)S4naFPsarJgfiPiwHjmbeJMJGnb2WiytarJgfiPiwbu5tJ(ufqr844Riay8aCVvrEfvOrsYfVJaczFwmb2WiG0ILGrav0qWRflbJpKitafsK5hLHeqraWimb2XlytaPflbJasMihk4zuUSiGOrJcKueRWeyZUc2eq0OrbskIvav(0Opvbel9tnkqlhai4XbVVir9vRVCq6KgS95kM(GpS0xT(QRVCq6KgS95sm9T)XPVnB6Z0an2cr6NdNFsUkJrFArJgfizF16JL(PgfOfI0pho)KCvgJ(KVWBaC8(2QVA9H1(kaqqcCpl8Kg5I3raPflbJaIfiLE65DSemctGn8jytarJgfiPiwbu5tJ(ufqr844lCL8C86ltDqlEN(Q1hw7tsr844l3VAv48bpUsFslEhbKwSemciuLkbU9UbV07O5imb2XrWMaIgnkqsrSciTyjyeqfne8AXsW4djYeqHez(rziburIeMaB2tWMaIgnkqsrScOYNg9PkGmnqJTqK(5W5NKRYy0Nw0Orbs2xT(qoui4n95idTyYr6rK(95AFS0p1OaTyYr6rK((cVbWX7RwFyTpjWwOkvcC7DdEP3rZzzzzVC46RwFyTVcaeKa3ZcpPrU4DeqAXsWiGyYr6rK(ctGn7qWMaIgnkqsrSciTyjyeqsLzulbJaQ8PrFQciS2hl9tnkqlne8sGH88ocOcSLa5n95idjWggHjWE)fSjGOrJcKueRaQ8PrFQcOCq6KgS95sm9T)XPVA9zAGgBvXpC0NdNNfiLlA0Oaj7RwFMgOXwis)C48tYvzm6tlA0Oaj7RwFihke8M(CKHwm5i9is)(CjM(yV(2SPV66RU(mnqJTQ4ho6ZHZZcKYfnAuGK9vRpS2NPbASfI0pho)KCvgJ(0IgnkqY(2QVnB6d5qHG30NJm0IjhPhr63hM(GPVTeqAXsWiGybsPpcemHjWEBlytarJgfiPiwbKwSemcijXcW)5W5DckhpjGkFA0NQaQU(Ec)juLgfO(2SPVCq6KgS95AFSJ403w9vRV66dR9Xs)uJc0YbacECW7lsuFB20xoiDsd2(CftF7FC6BR(Q1xD9H1(mnqJTqK(5W5NKRYy0Nw0Orbs23Mn9vxFMgOXwis)C48tYvzm6tlA0Oaj7RwFyTpw6NAuGwis)C48tYvzm6t(cVbWX7BR(2savGTeiVPphzib2Wimb2WGfbBciA0OajfXkGkFA0NQac5qHG30NJm0IjhPhr63Nl7RU(GV(IPVcyK8PTKjcbgDmpvQaeArJgfizFB1xT(YbPtAW2NlX03(hN(Q1NPbASfI0pho)KCvgJ(0IgnkqY(2SPpS2NPbASfI0pho)KCvgJ(0IgnkqsbKwSemciwGu6JabtycSHbgbBciA0OajfXkG0ILGraHQujWT3n4LEjPwLaQ8PrFQcO66Z0NJSvfPbRA5uS(CzFXJL(Q1hYHcbVPphzOftospI0Vpx2h813w9TztF11Ndzl8Kg5slwYI6RwFp)q4GNJwOkvcCJhugY78jIzrXn(0XHK9TLaQaBjqEtFoYqcSHrycSHjEbBciA0OajfXkG0ILGraH4)Ngj9Ed4zu5qiKaQ8PrFQcitFoYwwYqEd4Lj1Nl7l(40xT(I4XXxSaPeh8mljW9iGkWwcK30NJmKaByeMaByyxbBciA0OajfXkG0ILGraXcKsVb(Ngtav(0Opvbel9tnkqljWqEEN(Q1NPphzllziVb8YK6Z1(y3(Q1xepo(IfiL4GNzjbUN(Q1NwSKf5LaBXszCYplEdWxQ6dtFihke8M(CKHwSugN8ZI3a8LQ(Q1hYHcbVPphzOftospI0Vpx2xD9fN(IPV66J96BBPptd0ylZDImpa3JRgTOrJcKSVT6Blbub2sG8M(CKHeydJWeydd8jytarJgfiPiwbu5tJ(ufqsGTyPmo5NfVb4lvlll7LdxF16RU(mnqJTqK(5W5NKRYy0Nw0Orbs2xT(qoui4n95idTyYr6rK(95AFS0p1OaTyYr6rK((cVbWX7BZM(KaBHQujWT3n4LEhnNLLL9YHRVTeqAXsWiGyYrgrJKEHjWgM4iytarJgfiPiwbu5tJ(ufqp)q4GNJwoAorpP7rV3bPbMff34thhs2xT(yPFQrbAjbgYZ70xT(m95iBzjd5nG3Py(4XsFU2xD9vaGGe4EwOkvcC7DdEPxsQvTK8VAjy6lM(4kY(2saPflbJacvPsGBVBWl9ssTkHjWgg2tWMaIgnkqsrScOYNg9PkGEnLEIfn2sLs0kN(CTpyWIaslwcgbeQsLa3(YROkHjWgg2HGnbenAuGKIyfqAXsWiGyYr6rK(cOcSLa5n95idjWggbuog9pVJ5tCbKLL9qUIjEbuog9pVJ5tggsMQrciyeqLpn6tvaHCOqWB6ZrgAXKJ0Ji97Z1(yPFQrbAXKJ0Ji99fEdGJ3xT(I4XXxs93ZBvaEUkBX7iGkvAociyeMaBy2FbBciA0OajfXkG0ILGraXKJ0Jhuyfq5y0)8oMpXfqww2d5kM4RvaGGe4EwSaP0hbc2I3raLJr)Z7y(KHHKPAKacgbu5tJ(ufqr844lP(75TkapxLT4D6RwFS0p1OaTKad55DeqLknhbemctGnmBBbBciA0OajfXkGkFA0NQaIL(PgfOLeyipVtF1671u6jw0ylgalIHgBLtFU2xrrM3sgQVy6dlR40xT(QRpKdfcEtFoYqlMCKEePFFUSp4RVA9H1(mnqJTyse9WUOrJcKSVnB6d5qHG30NJm0IjhPhr63Nl7J96RwFMgOXwmjIEyx0Orbs23wciTyjyeqm5i9rbfzctGD8yrWMaIgnkqsrSciTyjyeqSugN8ZI3a8Lkbu5tJ(ufqpH)eQsJcuF16Z0NJSLLmK3aEzs95AFSxFB20xD9zAGgBXKi6HDrJgfizF16tcSfQsLa3E3Gx6D0CwpH)eQsJcuFB13Mn9fXJJV4hC(pKdNxQ)EdHqlEhbub2sG8M(CKHeydJWeyhpmc2eq0OrbskIvav(0Opvb0t4pHQ0Oa1xT(m95iBzjd5nGxMuFU2h81xT(WAFMgOXwmjIEyx0Orbs2xT(mnqJTCqWwQYIpKZElA0Oaj7RwFihke8M(CKHwm5i9is)(CTV4fqAXsWiGqvQe427g8sVJMJWeyhF8c2eq0OrbskIvaPflbJacvPsGBVBWl9oAocOYNg9PkGEc)juLgfO(Q1NPphzllziVb8YK6Z1(GV(Q1hw7Z0an2Ijr0d7IgnkqY(Q1hw7RU(mnqJTqK(5W5NKRYy0Nw0Orbs2xT(qoui4n95idTyYr6rK(95AFS0p1OaTyYr6rK((cVbWX7BR(Q1xD9H1(mnqJTCqWwQYIpKZElA0Oaj7BZM(QRptd0ylheSLQS4d5S3IgnkqY(Q1hYHcbVPphzOftospI0VpxIPV47BR(2savGTeiVPphzib2Wimb2XZUc2eq0OrbskIvaPflbJaIjhPhr6lGkWwcK30NJmKaByeq5y0)8oMpXfqww2d5kM4fq5y0)8oMpzyizQgjGGrav(0OpvbeYHcbVPphzOftospI0Vpx7JL(PgfOftospI03x4naoUaQuP5iGGrycSJh(eSjGOrJcKueRaslwcgbetospEqHvaLJr)Z7y(exazzzpKRyIVwbacsG7zXcKsFeiylEhbuog9pVJ5tggsMQrciyeqLknhbemctGD8XrWMaslwcgbeQsLa3E3Gx6LKAvciA0OajfXkmb2XZEc2eqAXsWiGqvQe427g8sVJMJaIgnkqsrSctycOIejytGnmc2eq0OrbskIvav(0Opvbuepo(IfiL4GNzX7iG0ILGra5aCtVphCEucgHjWoEbBciA0OajfXkG0ILGraHYanfsav(0Opvb0Zpeo45OfICQ4z)iVZdkbLrTemlkUXNooKSVA9vxFM(CKTsKxLY(2SPptFoYwskIhhFvuKLd36jTy9TLaQaBjqEtFoYqcSHrycSzxbBciA0OajfXkG0ILGraHYbNp45cQmvd8iFKk5ipa3JtpOKgScOYNg9PkGI4XXxSaPeh8mlEN(2SPplzO(CTpyWsF16RU(WAFfalA0XwtYvzECL6Blb0OmKacLdoFWZfuzQg4r(ivYrEaUhNEqjnyfMaB4tWMaslwcgbeUsEoE9LPoibenAuGKIyfMa74iytarJgfiPiwbKwSemciMCKCkdHeqLpn6tvaLdsN0GTpx232gl9vRV66JL(PgfOLgcEjWqEEN(2SPViEC8flqkXbpZI3PVTeqfylbYB6ZrgsGnmctGn7jytarJgfiPiwbu5tJ(ufqVMspXIgBPsjALtFU2x8yraPflbJaIFQaby9dGLkmb2SdbBciA0OajfXkGkFA0NQacR9fXJJVybsjo4zw8o9vRpS2xbacsG7zXcKsp98owcMfVtF16d5qHG30NJm0IjhPhr63NR9btF16dR9zAGgBHi9ZHZpjxLXOpTOrJcKSVnB6RU(I4XXxSaPeh8mlEN(Q1hYHcbVPphzOftospI0Vpx2x89vRpS2NPbASfI0pho)KCvgJ(0IgnkqY(2QVnB6RU(I4XXxSaPeh8mlEN(Q1NPbASfI0pho)KCvgJ(0IgnkqY(2saPflbJakcagpa3BvKxrfAKKuycS3FbBciA0OajfXkG0ILGrav0qWRflbJpKitafsK5hLHeqecrtHqctG92wWMaIgnkqsrScOYNg9PkGI4XXxSaPeh8mlEN(2SPViEC8LdWn9(CW5rjyw8ociTyjyeq8iYNgXGeMWeqraWiytGnmc2eq0OrbskIvav(0OpvbeYHcbVPphzOftospI0VpxIPp2vaPflbJasrfAKK0hfuKjmb2XlytarJgfiPiwbu5tJ(ufq11hYHcbVPphzOftospI0Vpx7l((Q1NPbASfI0pho)KCvgJ(0IgnkqY(2SPV66d5qHG30NJm0IjhPhr63NR9btF16dR9zAGgBHi9ZHZpjxLXOpTOrJcKSVT6BR(Q1hYHcbVPphzOLIk0ijPFaS0(CTpyeqAXsWiGuuHgjj9dGLkmHjGkUlc2eydJGnbenAuGKIyfq8iY7UkdKVOilhob2WiG0ILGraHi9ZHZpjxLXOpjGkWwcK30NJmKaByeqLpn6tvavxFS0p1OaTqK(5W5NKRYy0N8fEdGJ3xT(WAFS0p1OaTCaGGhh8(Ie13w9TztF11NeyluLkbU9UbV07O5SEc)juLgfO(Q1hYHcbVPphzOftospI0Vpx7dM(2sycSJxWMaIgnkqsrSciEe5DxLbYxuKLdNaByeqAXsWiGqK(5W5NKRYy0NeqfylbYB6ZrgsGnmcOYNg9PkGmnqJTqK(5W5NKRYy0Nw0Orbs2xT(KaBHQujWT3n4LEhnN1t4pHQ0Oa1xT(qoui4n95idTyYr6rK(95AFXlmb2SRGnbenAuGKIyfqGjaRV4UiGGraPflbJaIjhPpkOityctyciw0JsWiWoESepwGbM4z3fmci36p5WHeqBp8M9zS3wXoUZTRV(yRI6lzCaV1ho47BFz0C23(EkUXNpj7dbyO(uEdWOgj7RuPdhHw9o41CO(GHD3U(2gW)uXizFuCJxdPbBFLkQSxF4pGPV9fdM9Tpd03(IzF7RoyyF3A176DBRmoG3izFSJ(0ILGPVqIm0Q3jGqourGD8Xz)fqopapdKaYf9bvPsG7(GNpjK17CrFWpviMi67dg46lESepw6D9ox03(K9Lk8gj7lIWbp1xbWePwFrexoOvFW7sHCmuFdyyFuPpdoFOpTyjyq9bMaSRENwSemOLZtfatKAXGPEhGB69UbV0JdElnEjbxIJ5jgnhKlzxSGLENwSemOLZtfatKAXGPEuLkbUXbpdCjogSgXJJVqvQe4gh8mlENENwSemOLZtfatKAXGPE9l6qEd8pngCjoMCq6KgSljHNL0CfM4070ILGbTCEQayIulgm1ZJiFAedCJYqyu2pQsFf5XbJ5b4EhGB67DAXsWGwopvamrQfdM6zPFQrbcUrzimm5i9isFFH3a44WbCWGidowAGNWeFVtlwcg0Y5PcGjsTyWuplLXj)S4naFPQ317CrFWdWsWG6DAXsWGWGYanfQ3PflbdcJdWsWaxIJjIhhFXcKsCWZS4D2SjIhhF5aCtVphCEucMfVtVtlwcgumyQNL(Pgfi4gLHWibgYZ7ahWbdIm4yPbEcJeyluLkbU9UbV07O5SSSSxoC1KaBXszCYplEdWxQwww2lhUENwSemOyWupl9tnkqWnkdHrdbVeyipVdCahmiYGJLg4jmsGTqvQe427g8sVJMZYYYE5WvtcSflLXj)S4naFPAzzzVC4Qjb2ssSa8FoCENGYXtlll7LdxVZf9bz6B9XJYHRpis)C46d7KRYy0N6tT(y3y6Z0NJmuFGVp4lM(s8(GfW3N(uF503(bsjo4z6DAXsWGIbt9S0p1Oab3OmegePFoC(j5Qmg9jFH3a44WbCWGidowAGNWGCOqWB6ZrgAXKJ0Ji9Dn(yI4XXxSaPeh8mlENENl6BBaGGe4E6dEaGqF7N(Pgfi46lUqKSpd0Ndae6lIWbp1NwSKLA5W1hlqkXbpZQVTH)FASaS9XJizFgOVcyShe6ZDfn9zG(0ILSuJ6JfiL4GNPp3Pv1xofatoC9PsjA170ILGbfdM6zPFQrbcUrzimoaqWJdEFrIGd4GbrgCS0apHPaabjW9SybsPNEEhlbZI3PwDy91u6jw0ylvkrlENnBEnLEIfn2sLs0sY)QLGXLyGblB28Ak9elASLkLO1tmAoixXadwIjoBl1zAGgBvXpC0NdNNfiLlA0Oaj3SPayrJo2Apy)uNT2QwD19Ak9elASLkLOvoUgpw2Sb5qHG30NJm0IfiLE65DSemUIjoBTzJPbASvf)WrFoCEwGuUOrJcKCZMcGfn6yR9G9tD2Q3Pflbdkgm1JNpffaajCjoMiEC8flqkXbpZI3P3Pflbdkgm1hrpI(9YHdUehtepo(IfiL4GNzX707CrFXfI6dEn5QS9f13oEjhdnwFjEFwf9uF6t9fFFGVpgWt9z6ZrgcU(aFFQuI6tFA2xRpKJ6EYHRpCW3hd4P(SkD6JDeh0Q3Pflbdkgm1hsUkd5J75LCm0yWL4yqoui4n95idTcjxLH8X98sogAmxXe)Mn1H1xtPNyrJTuPeTi23ezOnBEnLEIfn2sLs0khxzhXzRENwSemOyWuVofczVg8fneGlXXeXJJVybsjo4zw8o9oTyjyqXGP(IgcETyjy8HezWnkdHP4U070ILGbfdM6F(XRflbJpKidUrzimmAo9UENl6BBGFuVtlwcg0QiryCaUP3NdopkbdCjoMiEC8flqkXbpZI3P35I(Ile1hugOPq9bM(2g4Vpd0NZdk9brov8S)9f1h88GsqzulbZQ3PflbdAvKOyWupkd0ui4kWwcK30NJmegyGlXX88dHdEoAHiNkE2pY78GsqzulbZIIB8PJdjRvNPphzRe5vPCZgtFoYwskIhhFvuKLd36jTyB17CrFXfI6lwvYr9LdkLuFa8(2p4L(WbFFwf1hE(iRpEe1h47dm9TnWFFkUrFFwf1hE(iRpEeT6B7tRQpStUkRp4fL6RceK9Hd((2p4LvVtlwcg0QirXGPEEe5tJyGBugcdkhC(GNlOYunWJ8rQKJ8aCpo9GsAWcxIJjIhhFXcKsCWZS4D2SXsgYvyWsT6WAbWIgDS1KCvMhxPT6DAXsWGwfjkgm1JRKNJxFzQdQ3PflbdAvKOyWuptosoLHqWvGTeiVPphzimWaxIJjhKoPbRl32yPwDS0p1OaT0qWlbgYZ7Sztepo(IfiL4GNzX7SvVtlwcg0QirXGPE(PceG1pawkCjoMxtPNyrJTuPeTYX14XsVtlwcg0QirXGP(iay8aCVvrEfvOrss4sCmynIhhFXcKsCWZS4DQH1caeKa3ZIfiLE65DSemlENAihke8M(CKHwm5i9isFxHPgwnnqJTqK(5W5NKRYy0Nw0OrbsUztDr844lwGuIdEMfVtnKdfcEtFoYqlMCKEePVlJVgwnnqJTqK(5W5NKRYy0Nw0OrbsU1Mn1fXJJVybsjo4zw8o1mnqJTqK(5W5NKRYy0Nw0OrbsUvVtlwcg0QirXGP(IgcETyjy8HezWnkdHHqiAkeQ35I(GFcx5dwF4AiePL96dh89XJ0Oa1xAedA76lUquFGPVcaeKa3ZQ3PflbdAvKOyWuppI8Prmi4sCmr844lwGuIdEMfVZMnr844lhGB695GZJsWS4D6D9ox0h8gEGx7Za9XJO(CxrtFXcatFa8(SkQp4nQqJKK9LO(0ILSOENwSemOveamyuuHgjj9rbfzWL4yqoui4n95idTyYr6rK(Ued7270ILGbTIaGjgm1ROcnss6halfUehtDihke8M(CKHwm5i9isFxJVMPbASfI0pho)KCvgJ(0IgnkqYnBQd5qHG30NJm0IjhPhr67km1WQPbASfI0pho)KCvgJ(0IgnkqYT2QgYHcbVPphzOLIk0ijPFaSuxHP317CrFXIdV7BFIq0uiuF4GVp45j2hoQvQ6DUOp4NcKr9zvjQpf3OVpOkvcCh0rI6lO8tPQ3PflbdArienfcHHHyapSEaUpWxsPx(KYG6DAXsWGwecrtHqXGP(Oaai9aCVvrEAigy7DAXsWGwecrtHqXGPEoE9LPoEaUxz)0dSQENwSemOfHq0uiumyQhhu4rK0RSF6tJ8rKYaxIJb5qHG30NJm0IjhPhr67kM43S51u6jw0ylvkrRCCL9WsVtlwcg0IqiAkekgm17W)joS5W5JckYGlXXGCOqWB6ZrgAXKJ0Ji9Dft8B28Ak9elASLkLOvoUYEyP3PflbdArienfcfdM6lGPqJ9QrspEqzi4c5q(Ied7bxIJXsgYLyGblB2GZhc(Nkv6ZrElzixYvKB2y6Zr2YsgYBaVmjxgNENwSemOfHq0uiumyQ)thNa5ZXJC0c170ILGbTieIMcHIbt9pPo5W5XdkdH6DAXsWGwecrtHqXGPE3Gpizr54FcbgDkuVtlwcg0IqiAkekgm1BvKNFIa8J0Jd(c176DUOVTrrwFBFvgO(2gfz5W1NwSemOvFqK1NA9vLCv03NZNGpny7Za9HQaV1xj)cFA9LJr)Z7y9vaJmTemO(atFSZCK9br6xp8sqHT35I(Ile1hePFoC9HDYvzm6t9L49blGVp3zi0xvA9rdGNRQptFoYq9PJSp4b4M((2whCEucM(0r23(bsjo4z6tFQVby99KkHfU(aFFgOVNWFcv1h02VDWtFGPpZnOpW3hd4P(m95idT6DAXsWGwf3fmis)C48tYvzm6tWXJiV7Qmq(IISC4WadCfylbYB6ZrgcdmWL4yQJL(PgfOfI0pho)KCvgJ(KVWBaC8AyLL(PgfOLdae84G3xKOT2SPojWwOkvcC7DdEP3rZz9e(tOknkq1qoui4n95idTyYr6rK(UcZw9ox0huf4T(2M8l8P1hePFoC9HDYvzm6t9vaJmTem9zG(2JiN(G2(TdE6J3PVC6dEd2N9oTyjyqRI7smyQhr6NdNFsUkJrFcoEe5DxLbYxuKLdhgyGRaBjqEtFoYqyGbUehJPbASfI0pho)KCvgJ(0IgnkqYAsGTqvQe427g8sVJMZ6j8NqvAuGQHCOqWB6ZrgAXKJ0Ji9Dn(ENl6dmby9f3L(y09iuFwf1NwSem9bMaS9XJ0Oa1NK)ZHRVsLodfYHRpDK9naRpf1N23tC8b97tlwcMvVtlwcg0Q4UedM6zYr6JckYGdmby9f3fmW076DUOp2PMtFWB4bEfU(qva(GSVcGf99PHqFVoCeQpaEFM(CKH6thzFOcn6NauVtlwcg0IrZjgm1x0qWRflbJpKidUrzimraWahY(SyyGbUehtepo(kcagpa3BvKxrfAKKCX7070ILGbTy0CIbt9Ye5qbpJYLLENl6lUquF7hiL9TpFEhlbtFGPVcaeKa3tFoaqihU(uRVaPiRp4dl9LdsN0GTViERVby9L49blGVp3zi0hGf9f1PVCq6KgS9LtF7h8YQp2PUh1hI)P(qvQe4gpPrwptoYiAK03xI6dm9vaGGe4E6lIWbp13(Tpx9oTyjyqlgnhmSaP0tpVJLGbUehdl9tnkqlhai4XbVVir1YbPtAW6kg4dl1QlhKoPbRlXS)XzZgtd0ylePFoC(j5Qmg9PfnAuGK1yPFQrbAHi9ZHZpjxLXOp5l8gahFRAyTaabjW9SWtAKlENENl6JDQ7r9H4FQpyb895WB9X70h02VDWtFWBi4n80hy6ZQO(m95iRVeVVT)vRcNp0h8IsFs9LOzFT(0ILSOvVtlwcg0IrZjgm1JQujWT3n4LEhnh4sCmr844lCL8C86ltDqlENAyvsr844l3VAv48bpUsFslENENwSemOfJMtmyQVOHGxlwcgFirgCJYqyksuVZf9f3n5Q6dE(e8PbBFSZCK9br63NwSem9zG(Ec)juvFWpGnuFUtRQpePFoC(j5Qmg9PENwSemOfJMtmyQNjhPhr6dNPphz(ehJPbASfI0pho)KCvgJ(0IgnkqYAihke8M(CKHwm5i9isFxzPFQrbAXKJ0Ji99fEdGJxdRsGTqvQe427g8sVJMZYYYE5WvdRfaiibUNfEsJCX707CrFWZt403Nb6Jhr9b)kZOwcM(G3qWB4PVeVpDGTp4hWwFjQVby9X7S6DAXsWGwmAoXGPEPYmQLGbUcSLa5n95idHbg4sCmyLL(PgfOLgcEjWqEENENl6lUquF7hiL9fliy9PwFvjxf9958j4td2(CNwvFXD5ho6ZHRV9dKY(4D6Za9bF9z6ZrgcU(aFFaRI((mnqJH6dm9bX2Q3PflbdAXO5edM6zbsPpcem4sCm5G0jnyDjM9po1mnqJTQ4ho6ZHZZcKYfnAuGK1mnqJTqK(5W5NKRYy0Nw0Orbswd5qHG30NJm0IjhPhr67smS3Mn1vNPbASvf)WrFoCEwGuUOrJcKSgwnnqJTqK(5W5NKRYy0Nw0OrbsU1Mnihke8M(CKHwm5i9isFmWSvVZf9b)GzFT(4ruFWpXcW)5W1h8euoEQVeVpyb89v0PpoY6lhd03(bsjo4z6lhKrQeU(aFFjEFqK(5W1h2jxLXOp1xI6Z0angj7thzFUZqOVQ06JgapxvFM(CKHw9oTyjyqlgnNyWuVKyb4)C48obLJNGRaBjqEtFoYqyGbUehtDpH)eQsJc0Mn5G0jnyDLDeNTQvhwzPFQrbA5aabpo49fjAZMCq6KgSUIz)JZw1QdRMgOXwis)C48tYvzm6tlA0Oaj3SPotd0ylePFoC(j5Qmg9PfnAuGK1Wkl9tnkqlePFoC(j5Qmg9jFH3a44BTvVZf9fxiQV9l2(atFBd83xI3hSa((KGzFT(gIK9zG(kkY6d(jwa(phU(GNGYXtW1NoY(Sk6P(0N6lqiuFwLo9bF9z6ZrgQpaV1xDXPp3Pv1xbms(02A170ILGbTy0CIbt9SaP0hbcgCjogKdfcEtFoYqlMCKEePVlRd(IPagjFAlzIqGrhZtLkaHw0OrbsUvTCq6KgSUeZ(hNAMgOXwis)C48tYvzm6tlA0Oaj3SbRMgOXwis)C48tYvzm6tlA0Oaj7DUOV4cr9bvPsG7(2EWl3U(GFsTQ(s8(SkQptFoY6lr9PraERpd0NmP(aFFWc47Rszr9bvPsGB8GYq9bpFIy6JIB8PJdj7ZDAv9XoZrgrJK((aFFqvQe4gpPr2NwSKfT6DAXsWGwmAoXGPEuLkbU9UbV0lj1QGRaBjqEtFoYqyGbUehtDM(CKTQinyvlNI5Y4XsnKdfcEtFoYqlMCKEePVlHVT2SPohYw4jnYLwSKfv75hch8C0cvPsGB8GYqENprmlkUXNooKCRENl6lUquFq8)tJK((mqFStvoec1hy6t7Z0NJS(Sk16lr9XbYHRpd0NmP(uRpRI67tUkRplzOvVtlwcg0IrZjgm1J4)Ngj9Ed4zu5qieCfylbYB6ZrgcdmWL4ym95iBzjd5nGxMKlJpo1I4XXxSaPeh8mljW907CrFXfI6B)aPSp2a)tJ1hycW2xI3h02VDWtF6i7B)yRp9P(0ILSO(0r2Nvr9z6ZrwFUbZ(A9jtQpj)NdxFwf1xPsNHcRENwSemOfJMtmyQNfiLEd8pngCfylbYB6ZrgcdmWL4yyPFQrbAjbgYZ7uZ0NJSLLmK3aEzsUYU1I4XXxSaPeh8mljW9utlwYI8sGTyPmo5NfVb4lvyWGCOqWB6ZrgAXszCYplEdWxQQHCOqWB6ZrgAXKJ0Ji9DzDXjM6yVTftd0ylZDImpa3JRgTOrJcKCRT6DAXsWGwmAoXGPEMCKr0iPhUehJeylwkJt(zXBa(s1YYYE5WvRotd0ylePFoC(j5Qmg9PfnAuGK1qoui4n95idTyYr6rK(UYs)uJc0IjhPhr67l8gahFZgjWwOkvcC7DdEP3rZzzzzVC42Q35I(Ile1h02VDWFFUtRQp4rZj6jDp67dEqAGPp(jqiuFwf1NPphz95odH(IO(IOaWDFXJL4o6lIWbp1Nvr9vaGGe4E6RayiuFrAzVENwSemOfJMtmyQhvPsGBVBWl9ssTk4sCmp)q4GNJwoAorpP7rV3bPbMff34thhswJL(PgfOLeyipVtntFoYwwYqEd4DkMpES4ADfaiibUNfQsLa3E3Gx6LKAvlj)RwcMy4kYT6DUOV4cr9bvPsG7(2Mxrv9bM(2g4Vp(jqiuFwf9uF6t9PsjQVCkaMC4w9oTyjyqlgnNyWupQsLa3(YROk4sCmVMspXIgBPsjALJRWGLENl6lUquFSZCK9br63Nb6Ragepd1h8R)E9XwfGNRYq958GcQpW0h8EFSpx9X2(a(3h9TnGbpFM(suFwvI6lr9P9vLCv03NZNGpny7ZQ0PVNKaZYHRpW0h8EFSp7JFcec1Nu)96ZQa8CvgQVe1Ngb4T(mqFwYq9b4TENwSemOfJMtmyQNjhPhr6dxb2sG8M(CKHWadCjogKdfcEtFoYqlMCKEePVRS0p1OaTyYr6rK((cVbWXRfXJJVK6VN3Qa8Cv2I3bUsLMdgyGlhJ(N3X8jddjt1imWaxog9pVJ5tCmww2d5kM47DUOV4cr9XoZr2h8sqHTpd0xbmiEgQp4x)96JTkapxLH6Z5bfuFGPpi2w9X2(a(3h9TnGbpFM(s8(SQe1xI6t7Rk5QOVpNpbFAW2NvPtFpjbMLdxF8tGqO(K6VxFwfGNRYq9LO(0iaV1Nb6ZsgQpaV170ILGbTy0CIbt9m5i94bfw4sCmr844lP(75TkapxLT4DQXs)uJc0scmKN3bUsLMdgyGlhJ(N3X8jddjt1imWaxog9pVJ5tCmww2d5kM4RvaGGe4EwSaP0hbc2I3P35I(Ile1h7mhzFXguK1xI3hSa((KGzFT(gIK9zG(Ec)juvFWpGn0Qpid40xrrwoC9PwFWxFGVpgWt9z6ZrgQp3Pv1hePFoC9HDYvzm6t9zAGgJKRENwSemOfJMtmyQNjhPpkOidUehdl9tnkqljWqEENAVMspXIgBXayrm0yRCCTOiZBjdfdwwXPwDihke8M(CKHwm5i9isFxcF1WQPbASftIOh2fnAuGKB2GCOqWB6ZrgAXKJ0Ji9Dj7vZ0an2Ijr0d7IgnkqYT6DAXsWGwmAoXGPEwkJt(zXBa(sfCfylbYB6ZrgcdmWL4yEc)juLgfOAM(CKTSKH8gWltYv2BZM6mnqJTyse9WUOrJcKSMeyluLkbU9UbV07O5SEc)juLgfOT2SjIhhFXp48FihoVu)9gcHw8o9ox0hKdvsn0xbmY0sW0Nb6dzaN(kkYYHRpOTF7GN(atFaCC2hM(CKH6ZDfn9HNCvwoC9XU9b((yap1hY0YEKSpgqeQpDK9XJYHRp4bbBPkl9bVMZE9PJSpS3hS1h7mr0d7Q3PflbdAXO5edM6rvQe427g8sVJMdCjoMNWFcvPrbQMPphzllziVb8YKCf(QHvtd0ylMerpSlA0OajRzAGgB5GGTuLfFiN9w0Orbswd5qHG30NJm0IjhPhr67A89ox0h7te50h02VDWtF8o9bM(uuFm6aBFM(CKH6tr95aqOmkqW1hX(wihRp3v00hEYvz5W1h72h47Jb8uFitl7rY(yarO(CNwvFWdc2svw6dEnN9w9oTyjyqlgnNyWupQsLa3E3Gx6D0CGRaBjqEtFoYqyGbUehZt4pHQ0OavZ0NJSLLmK3aEzsUcF1WQPbASftIOh2fnAuGK1WADMgOXwis)C48tYvzm6tlA0OajRHCOqWB6ZrgAXKJ0Ji9DLL(PgfOftospI03x4nao(w1QdRMgOXwoiylvzXhYzVfnAuGKB2uNPbASLdc2svw8HC2BrJgfiznKdfcEtFoYqlMCKEePVlXe)wB170ILGbTy0CIbt9m5i9isF4kWwcK30NJmegyGlXXGCOqWB6ZrgAXKJ0Ji9DLL(PgfOftospI03x4naooCLknhmWaxog9pVJ5tggsMQryGbUCm6FEhZN4ySSShYvmX370ILGbTy0CIbt9m5i94bfw4kvAoyGbUCm6FEhZNmmKmvJWadC5y0)8oMpXXyzzpKRyIVwbacsG7zXcKsFeiylENENl6lUquFqB)2b)9PO(ckY67je4T(s8(atFwf1hdGf170ILGbTy0CIbt9OkvcC7DdEPxsQv17CrFXfI6dA73o4Ppf1xqrwFpHaV1xI3hy6ZQO(yaSO(0r2h02VDWFFjQpW032a)9oTyjyqlgnNyWupQsLa3E3Gx6D0CeMWeca]] )


end
