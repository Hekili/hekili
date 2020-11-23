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
            aura = "mind_flay",
            debuff = true,

            last = function ()
                local app = state.debuff.mind_flay.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.mind_flay.tick_time ) * class.auras.mind_flay.tick_time
            end,

            interval = function () return class.auras.mind_flay.tick_time end,
            value = function () return ( state.talent.fortress_of_the_mind.enabled and 1.2 or 1 ) * 3 end,
        },

        mind_sear = {
            aura = "mind_sear",
            debuff = true,

            last = function ()
                local app = state.debuff.mind_sear.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.mind_sear.tick_time ) * class.auras.mind_sear.tick_time
            end,

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
                applyBuff( "surrender_to_madness" )
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


    spec:RegisterPack( "Shadow", 20201123.1, [[d80zpbqiOOEKa4scfvytsKpPuvAukLCkjQwLsPKELqPzbfUfkvf2Ls(LeLHbLQJbeltOYZGsPPbLIRjaTnuQY3qPsnoLQkNtPuQ1PuQAEcfUhqTpb0bHIuluOQhQukMikvCrLQI2iuK4JOuvuJuOOsNuOOQvQu5LOuvKzcfjDtuQKDcL8tLQcdfkILkuurpfWurPCvHISvLQQ(QsPYEr1FPYGv5WKwSqESKMmrxgzZO4ZemAjCArRwPuIxRuLztv3gQ2TIFdA4c64cfLLRQNdz6uUoH2ok57c04rPQ05bsRhLQQ5RuSFPMdcNnoGunIJvCypoSdciXHTlqcyabjoq4agOHehiuR7PcehyuCIdauOsyqoqOcQhQsoBCaeu8RehOWSq02xwzcPvigTQq8YqjUOxTeo1xzSYqjETmoqKy6Ty(HhXbKQrCSId7XHDqajoSDbsadiiGGnCav0kGphaiX3goqrkL0WJ4ascv5abOpGcvcd2hM8jHSExa6dlilcpI((IdBXOV4WECyNd4tKH4SXbieIMkH4SXXceoBCaTAjC4a4eo8b1bzCEXAkDYNuCehGgnYtsE8CJJvCC24aA1s4WbI8qO0bzCwb5OHWbLdqJg5jjpEUXXcB5SXb0QLWHdiiQVm1XbzCk7NEOvWbOrJ8KKhp34yHnC24a0OrEsYJNdu)0OpvoakK8ENPVazOfEoshI0VVab3xC9TztFVMshXIgBPsjALtFb2h7HDoGwTeoCagyversNY(PpnYfrko34yfqoBCaA0ipj5XZbQFA0NkhafsEVZ0xGm0cphPdr63xGG7lU(2SPVxtPJyrJTuPeTYPVa7J9WohqRwchoqO4NmGMJGlYRiJBCSypoBCaA0ipj5XZb0QLWHduHtLg7vJKogVItCG6Ng9PYbSeN6lgG7deS33Mn9Xi69UNQf6lqolXP(IrFcvzFB20NPVazllXjNbDYK6lg9fqoGphYvLCa2JBCSy3C24aA1s4Wb(mm0tUCCOqTsCaA0ipj5XZnow7hNnoGwTeoCGN0WCeCmEfNqCaA0ipj5XZnowBBoBCaTAjC4abHVxYIYX9eco6ujoanAKNK845ghlqWoNnoGwTeoCaRGCIteuCKog4xjoanAKNK845g34asIrf9gNnowGWzJdOvlHdhaLEAQehGgnYtsE8CJJvCC24a0OrEsYJNdu)0OpvoqKidZIfmLmWhFjg23Mn9fjYWScHbP3LdJikHZsmKdOvlHdhieAjC4ghlSLZghGgnYtsE8CayiharghqRwchoal9tnYtCawQxK4asOTqfQeg0fe(sxOMZYY6E5i0xP(KqBXsXdZpRodkwlwww3lhboal9DJItCaj0qoXqUXXcB4SXbOrJ8KKhphagYbqKXb0QLWHdWs)uJ8ehGL6fjoGeAluHkHbDbHV0fQ5SSSUxoc9vQpj0wSu8W8ZQZGI1ILL19YrOVs9jH2ssSGIFocUqVkisllR7LJahGL(UrXjoG69oj0qoXqUXXkGC24a0OrEsYJNdad5aiY4aA1s4WbyPFQrEIdWs9IehafsEVZ0xGm0cphPdr63xG9fxFX2xKidZIfmLmWhFjgYbyPVBuCIdGi9ZrWnPqHHRp5QIgKHHBCSypoBCaA0ipj5XZbGHCaezCaTAjC4aS0p1ipXbyPErIduHqVegCwSGP0rVyOLWzjg2xP(2Qpm33RP0rSOXwQuIwIH9TztFVMshXIgBPsjAjfF1s40xma3hiyVVnB671u6iw0ylvkrRNW1Cq9fi4(ab79fBFbSVT1(2Qpt90yRcXrG(CeCSGPCrJg5jzFB20xfYIgDS1EG(Po9vEFL3xP(2QVT671u6iw0ylvkrRC6lW(Id79TztFOqY7DM(cKHwSGP0rVyOLWPVab3xa7R8(2SPpt90yRcXrG(CeCSGPCrJg5jzFB20xfYIgDS1EG(Po9vohGL(UrXjoqie6DmW3vLiUXXIDZzJdqJg5jjpEoq9tJ(u5arImmlwWuYaF8LyihqRwchoat(uKhcLCJJ1(XzJdqJg5jjpEoq9tJ(u5arImmlwWuYaF8LyihqRwchoqe9i63lhbUXXABZzJdqJg5jjpEoq9tJ(u5aOqY7DM(cKHw(uOWqUTfrPaonwFbcUV46BZM(2Qpm33RP0rSOXwQuIwe7BImuFB203RP0rSOXwQuIw50xG9XUdyFLZb0QLWHd4tHcd52weLc40yCJJfiyNZghGgnYtsE8CG6Ng9PYbIezywSGPKb(4lXqoGwTeoCaDQeYE17QQ3ZnowGacNnoanAKNK845aA1s4WbQQ370QLWX5tKXb8jYCJItCGAWk34ybsCC24a0OrEsYJNdOvlHdh4fhNwTeooFImoGprMBuCIdGR5WnUXbcFQcXJuJZghlq4SXbOrJ8KKhphO(PrFQCGNW1Cq9fJ(WwSJDoGwTeoCGqyq6DbHV0XaFlnrjXnowXXzJdqJg5jjpEoq9tJ(u5ayUVirgMfQqLWGmWhFjgYb0QLWHdGkujmid8X5ghlSLZghGgnYtsE8CG6Ng9PYbYbPtAGUKetwtRVa7dKaYb0QLWHdOFvhYzW)PX4ghlSHZghGgnYtsE8CGrXjoGY(rf6RihdCmhKXfcdsphqRwchoGY(rf6RihdCmhKXfcdsp34yfqoBCaA0ipj5XZbGHCaezCaTAjC4aS0p1ipXbyPErIdehhGL(UrXjoaEoshI03vfnidd34yXEC24aA1s4WbyP4H5NvNbfRfCaA0ipj5XZnUXbQbRC24ybcNnoanAKNK845aIiYfSi9KRQilhbowGWb0QLWHdGi9ZrWnPqHHRpXbQGw9KZ0xGmehlq4a1pn6tLdSvFS0p1ipTqK(5i4MuOWW1NCvrdYW0xP(WCFS0p1ipTcHqVJb(UQe1x59TztFB1NeAluHkHbDbHV0fQ5SEI5juHg5P(k1hkK8ENPVazOfEoshI0VVa7dK(kNBCSIJZghGgnYtsE8Care5cwKEYvvKLJahlq4aA1s4WbqK(5i4MuOWW1N4avqREYz6lqgIJfiCG6Ng9PYbm1tJTqK(5i4MuOWW1Nw0OrEs2xP(KqBHkujmOli8LUqnN1tmpHk0ip1xP(qHK37m9fidTWZr6qK(9fyFXXnowylNnoanAKNK845aWXdQRgSYbaHdOvlHdhaphPlYRiJBCJduLioBCSaHZghGgnYtsE8CG6Ng9PYbIezywSGPKb(4lXqoGwTeoCGqyq6D5WiIs4WnowXXzJdqJg5jjpEoGwTeoCau6PPsCG6Ng9PYbEXHyGVaTquyHi7h5cFy1R4QLWzrXmXmmKK9vQVT6Z0xGSvICQu23Mn9z6lq2ssrImmRQISCewpPvRVY5avqREYz6lqgIJfiCJJf2YzJdqJg5jjpEoGwTeoCauomIENGxLPAWh5IuPa5Gmog6H10aLdu)0OpvoqKidZIfmLmWhFjg23Mn9zjo1xG9bc27RuFB1hM7RczrJo2AsHcZXOuFLZbgfN4aOCye9obVkt1GpYfPsbYbzCm0dRPbk34yHnC24aA1s4WbyuYjiQVm1bXbOrJ8KKhp34yfqoBCaA0ipj5XZb0QLWHdGNJuqXjehO(PrFQCGCq6KgO9fJ(22yVVs9TvFS0p1ipTuV3jHgYjg23Mn9fjYWSybtjd8XxIH9vohOcA1totFbYqCSaHBCSypoBCaA0ipj5XZbQFA0Nkh41u6iw0ylvkrRC6lW(Id7CaTAjC4aItb0dQBGSuUXXIDZzJdqJg5jjpEoq9tJ(u5ayUVirgMflykzGp(smSVs9H5(QqOxcdolwWu6Oxm0s4Sed7RuFOqY7DM(cKHw45iDis)(cSpq6RuFyUpt90ylePFocUjfkmC9PfnAKNK9TztFB1xKidZIfmLmWhFjg2xP(qHK37m9fidTWZr6qK(9fJ(IRVs9H5(m1tJTqK(5i4MuOWW1Nw0OrEs2x59TztFB1xKidZIfmLmWhFjg2xP(m1tJTqK(5i4MuOWW1Nw0OrEs2x5CaTAjC4arq44GmoRGCkQsJKKCJJ1(XzJdqJg5jjpEoGwTeoCGQ69oTAjCC(ezCaFIm3O4ehGqiAQeIBCS22C24aA1s4WberKlnchXbOrJ8KKhp34ghicchoBCSaHZghGgnYtsE8CG6Ng9PYbqHK37m9fidTWZr6qK(9fdW9HTCaTAjC4akQsJKKUiVImUXXkooBCaA0ipj5XZbQFA0NkhyR(qHK37m9fidTWZr6qK(9fyFX1xP(m1tJTqK(5i4MuOWW1Nw0OrEs23Mn9TvFOqY7DM(cKHw45iDis)(cSpq6RuFyUpt90ylePFocUjfkmC9PfnAKNK9vEFL3xP(qHK37m9fidTuuLgjjDdKL2xG9bchqRwchoGIQ0ijPBGSuUXnoaUMdNnowGWzJdqJg5jjpEoq9tJ(u5arImmRiiCCqgNvqofvPrsYLyihazFwnowGWb0QLWHduvV3PvlHJZNiJd4tK5gfN4arq4WnowXXzJdOvlHdhqMOqY7WvHSYbOrJ8KKhp34yHTC24a0OrEsYJNdu)0Opvoal9tnYtRqi07yGVRkr9vQVCq6KgO9fi4(WgS3xP(2QVCq6KgO9fdW9TFbSVnB6Zupn2cr6NJGBsHcdxFArJg5jzFL6JL(Pg5PfI0phb3KcfgU(KRkAqgM(kVVs9H5(QqOxcdolMKg5smKdOvlHdhGfmLo6fdTeoCJJf2WzJdqJg5jjpEoq9tJ(u5arImmlgLCcI6ltDqlXW(k1hM7tsrImmRGVAfmIEhJsFslXqoGwTeoCauHkHbDbHV0fQ5WnowbKZghGgnYtsE8CaTAjC4av17DA1s448jY4a(ezUrXjoqvI4ghl2JZghGgnYtsE8CG6Ng9PYbm1tJTqK(5i4MuOWW1Nw0OrEs2xP(qHK37m9fidTWZr6qK(9fyFS0p1ipTWZr6qK(UQObzy6RuFyUpj0wOcvcd6ccFPluZzzzDVCe6RuFyUVke6LWGZIjPrUed5aA1s4WbWZr6qK(CJJf7MZghGgnYtsE8CaTAjC4asfFulHdhO(PrFQCam3hl9tnYtl17DsOHCIHCGkOvp5m9fidXXceUXXA)4SXbOrJ8KKhphO(PrFQCGCq6KgO9fdW9TFbSVs9zQNgBvioc0NJGJfmLlA0ipj7RuFM6PXwis)CeCtkuy46tlA0ipj7RuFOqY7DM(cKHw45iDis)(Ib4(yV(2SPVT6BR(m1tJTkehb6ZrWXcMYfnAKNK9vQpm3NPEASfI0phb3KcfgU(0IgnYtY(kVVnB6dfsEVZ0xGm0cphPdr63h4(aPVY5aA1s4WbybtPlc6nUXXABZzJdqJg5jjpEoGwTeoCajXck(5i4c9QGiXbQFA0NkhyR(EI5juHg5P(2SPVCq6KgO9fyFS7a2x59vQVT6dZ9Xs)uJ80kec9og47QsuFB20xoiDsd0(ceCF7xa7R8(k13w9H5(m1tJTqK(5i4MuOWW1Nw0OrEs23Mn9TvFM6PXwis)CeCtkuy46tlA0ipj7RuFyUpw6NAKNwis)CeCtkuy46tUQObzy6R8(kNdubT6jNPVaziowGWnowGGDoBCaA0ipj5XZbQFA0NkhafsEVZ0xGm0cphPdr63xm6BR(WM(ITVkCKIPTKjcbhDmhvlGeArJg5jzFL3xP(YbPtAG2xma33(fW(k1NPEASfI0phb3KcfgU(0IgnYtY(2SPpm3NPEASfI0phb3KcfgU(0IgnYtsoGwTeoCawWu6IGEJBCSabeoBCaA0ipj5XZb0QLWHdGkujmOli8LojPwbhO(PrFQCGT6Z0xGSvbPERyfwT(IrFXH9(k1hkK8ENPVazOfEoshI0VVy0h20x59TztFB1xizlMKg5sRwYI6RuFV4qmWxGwOcvcdY4vCYf(jcFrXmXmmKK9vohOcA1totFbYqCSaHBCSajooBCaA0ipj5XZb0QLWHdGe)Ngj9od6Wv5qiehO(PrFQCatFbYwwItod6Kj1xm6lUa2xP(IezywSGPKb(4ljm4WbQGw9KZ0xGmehlq4ghlqWwoBCaA0ipj5XZb0QLWHdWcMsNb)NgJdu)0Opvoal9tnYtlj0qoXW(k1NPVazllXjNbDYK6lW(W2(k1xKidZIfmLmWhFjHbN(k1NwTKf5KqBXsXdZpRodkwl6dCFOqY7DM(cKHwSu8W8ZQZGI1I(k1hkK8ENPVazOfEoshI0VVy03w9fW(ITVT6J96BBTpt90yllyImhKXXOgTOrJ8KSVY7RCoqf0QNCM(cKH4ybc34ybc2WzJdqJg5jjpEoq9tJ(u5asOTyP4H5NvNbfRfllR7LJqFL6BR(m1tJTqK(5i4MuOWW1Nw0OrEs2xP(qHK37m9fidTWZr6qK(9fyFS0p1ipTWZr6qK(UQObzy6BZM(KqBHkujmOli8LUqnNLL19YrOVY5aA1s4WbWZrgrJKEUXXcKaYzJdqJg5jjpEoq9tJ(u5aV4qmWxGwHAorpP7rVlePE8ffZeZWqs2xP(yPFQrEAjHgYjg2xP(m9fiBzjo5mOlSAU4WEFb23w9vHqVegCwOcvcd6ccFPtsQvSKIVAjC6l2(eQY(kNdOvlHdhavOsyqxq4lDssTcUXXce2JZghGgnYtsE8CG6Ng9PYbEnLoIfn2sLs0kN(cSpqWohqRwchoaQqLWGU6ROcUXXce2nNnoanAKNK845aA1s4WbWZr6qK(CGkOvp5m9fidXXceoqog9VyO5sgoGL19qbcoooqog9VyO5sCCsMQrCaq4a1pn6tLdGcjV3z6lqgAHNJ0Hi97lW(yPFQrEAHNJ0Hi9DvrdYW0xP(Iezyws93ZzfqrHcBjgYbQfAoCaq4ghlq2poBCaA0ipj5XZb0QLWHdGNJ0X4vq5a5y0)IHMlz4aww3dfi44kvHqVegCwSGP0fb92smKdKJr)lgAUehNKPAehaeoq9tJ(u5arImmlP(75ScOOqHTed7RuFS0p1ipTKqd5ed5a1cnhoaiCJJfiBBoBCaA0ipj5XZbQFA0NkhGL(Pg5PLeAiNyyFL671u6iw0ylCilcNgBLtFb2xvrMZsCQVy7d7Ra2xP(2Qpui59otFbYql8CKoePFFXOpSPVs9H5(m1tJTWte9GUOrJ8KSVnB6dfsEVZ0xGm0cphPdr63xm6J96RuFM6PXw4jIEqx0OrEs2x5CaTAjC4a45iDrEfzCJJvCyNZghGgnYtsE8CaTAjC4aSu8W8ZQZGI1coq9tJ(u5apX8eQqJ8uFL6Z0xGSLL4KZGozs9fyFSxFB203w9zQNgBHNi6bDrJg5jzFL6tcTfQqLWGUGWx6c1CwpX8eQqJ8uFL33Mn9fjYWSehgX3NJGtQ)EdHqlXqoqf0QNCM(cKH4ybc34yfhiC24a0OrEsYJNdu)0OpvoWtmpHk0ip1xP(m9fiBzjo5mOtMuFb2h20xP(WCFM6PXw4jIEqx0OrEs2xP(m1tJTcrGwlYQZNZElA0ipj7RuFOqY7DM(cKHw45iDis)(cSV44aA1s4WbqfQeg0fe(sxOMd34yfxCC24a0OrEsYJNdOvlHdhavOsyqxq4lDHAoCG6Ng9PYbEI5juHg5P(k1NPVazllXjNbDYK6lW(WM(k1hM7Zupn2cpr0d6IgnYtY(k1hM7BR(m1tJTqK(5i4MuOWW1Nw0OrEs2xP(qHK37m9fidTWZr6qK(9fyFS0p1ipTWZr6qK(UQObzy6R8(k13w9H5(m1tJTcrGwlYQZNZElA0ipj7BZM(2Qpt90yRqeO1IS685S3IgnYtY(k1hkK8ENPVazOfEoshI0VVyaUV46R8(kNdubT6jNPVaziowGWnowXHTC24a0OrEsYJNdOvlHdhaphPdr6ZbQGw9KZ0xGmehlq4a5y0)IHMlz4aww3dfi444a5y0)IHMlXXjzQgXbaHdu)0OpvoakK8ENPVazOfEoshI0VVa7JL(Pg5PfEoshI03vfniddhOwO5WbaHBCSIdB4SXbOrJ8KKhphqRwchoaEoshJxbLdKJr)lgAUKHdyzDpuGGJRufc9syWzXcMsxe0BlXqoqog9VyO5sCCsMQrCaq4a1cnhoaiCJJvCbKZghqRwchoaQqLWGUGWx6KKAfCaA0ipj5XZnowXXEC24aA1s4WbqfQeg0fe(sxOMdhGgnYtsE8CJBCJdWIEuchowXH94WoiGeh2YbcQ)KJaIdSDy6yoXkMhl2N3((6JTcQVepe(wFmWVV9fxZzF77PyMy(KSpeeN6tfniUAKSVAHoceA17WuZH6deSD77BBG)tvJK9rXmr1NgO9vlO6E9X8q8(2xWG33(myF7l49TVTaH9T8vVR3fZJhcFJK9XU7tRwcN(8jYqREhhi8HmPN4abOpGcvcd2hM8jHSExa6dlilcpI((IdBXOV4WECyV317cqF7t2xQkAKSViIb(uFviEKA9frc5Gw9HPRvk0q9nWH9rH(4mI((0QLWb1hC8GU6DA1s4GwHpvH4rQfl4YcHbP3fe(shd8T0eLegjd4NW1CqXaBXo27DA1s4GwHpvH4rQfl4YqfQegKb(4yKmGXCKidZcvOsyqg4JVed7DA1s4GwHpvH4rQfl4Y0VQd5m4)0yyKmGZbPtAGUKetwtlqqcyVtRwch0k8PkepsTybxMiICPr4ymkobwz)Oc9vKJboMdY4cHbPV3PvlHdAf(ufIhPwSGlJL(Pg5jmgfNaJNJ0Hi9DvrdYWGbmemImmyPErcCC9oTAjCqRWNQq8i1IfCzSu8W8ZQZGI1IExVla9HjqlHdQ3PvlHdcmk90uPENwTeoiWHqlHdgjd4irgMflykzGp(smCZMirgMvimi9UCyerjCwIH9oTAjCqXcUmw6NAKNWyuCcSeAiNyigWqWiYWGL6fjWsOTqfQeg0fe(sxOMZYY6E5iuscTflfpm)S6mOyTyzzDVCe6DA1s4GIfCzS0p1ipHXO4ey17DsOHCIHyadbJiddwQxKalH2cvOsyqxq4lDHAollR7LJqjj0wSu8W8ZQZGI1ILL19YrOKeAljXck(5i4c9QGiTSSUxoc9Ua0hGPV1NikhH(ai9ZrOpSsHcdxFQp16dBJTptFbYq9b)(WMy7lz6duOyF6t9LtF7pmLmWhV3PvlHdkwWLXs)uJ8egJItGrK(5i4MuOWW1NCvrdYWGbmemImmyPErcmkK8ENPVazOfEoshI0pW4InsKHzXcMsg4JVed7DbOVTbc9syWPpmbc99T)6NAKNWOVycrY(myFHqOVViIb(uFA1swQLJqFSGPKb(4R(2gX)PX8G2NiIK9zW(QWXEOVVGf00Nb7tRwYsnQpwWuYaF8(cMwrF5uH45i0NkLOvVtRwchuSGlJL(Pg5jmgfNahcHEhd8DvjcdyiyezyWs9Ie4ke6LWGZIfmLo6fdTeolXWsBH5xtPJyrJTuPeTed3S51u6iw0ylvkrlP4RwcNyageSVzZRP0rSOXwQuIwpHR5Gcemiyp2aUTULPEASvH4iqFocowWuUOrJ8KCZMkKfn6yR9a9tDkV8sBT1RP0rSOXwQuIw5eyCyFZgui59otFbYqlwWu6Oxm0s4ei4aw(MnM6PXwfIJa95i4ybt5IgnYtYnBQqw0OJT2d0p1P8ENwTeoOybxgt(uKhcLyKmGJezywSGPKb(4lXWENwTeoOybxwe9i63lhbmsgWrImmlwWuYaF8LyyVla9ftiQpm1uOW2xuF7eLc40y9Lm9zf0t9Pp1xC9b)(WHp1NPVazim6d(9PsjQp9PzFT(qHAWjhH(yGFF4WN6Zk0Pp2DarRENwTeoOybxMpfkmKBBrukGtJHrYagfsEVZ0xGm0YNcfgYTTikfWPXceCCB2SfMFnLoIfn2sLs0IyFtKH2S51u6iw0ylvkrRCcKDhWY7DA1s4GIfCz6ujK9Q3vvVhJKbCKidZIfmLmWhFjg270QLWbfl4YQQ370QLWX5tKHXO4e4AWAVtRwchuSGl7fhNwTeooFImmgfNaJR5076DbOVTHDq9oTAjCqRQeboegKExomIOeoyKmGJezywSGPKb(4lXWExa6lMquFaPNMk1hC6BByN(myFHpS2hafwiY(3xuFyYdREfxTeoRENwTeoOvvIIfCzO0ttLWOcA1totFbYqGbbJKb8loed8fOfIclez)ix4dREfxTeolkMjMHHKS0wM(cKTsKtLYnBm9fiBjPirgMvvrwocRN0QvEVla9ftiQV4vPa1xoOus9bz6B)Xu6Jb(9zfuFm5JS(eruFWVp4032Wo9Pmg99zfuFm5JS(er0QVTlTI(WkfkS(WuuQVcOx2hd87B)Xuw9oTAjCqRQefl4YerKlnchJrXjWOCye9obVkt1GpYfPsbYbzCm0dRPbkgjd4irgMflykzGp(smCZglXPabb7L2cZvilA0XwtkuyogLkV3PvlHdAvLOybxgJsobr9LPoOENwTeoOvvIIfCz45ifuCcHrf0QNCM(cKHadcgjd4Cq6KgOXyBJ9sBXs)uJ80s9ENeAiNy4MnrImmlwWuYaF8Lyy59oTAjCqRQefl4YeNcOhu3azPyKmGFnLoIfn2sLs0kNaJd79oTAjCqRQefl4YIGWXbzCwb5uuLgjjXizaJ5irgMflykzGp(smSeMRqOxcdolwWu6Oxm0s4SedlHcjV3z6lqgAHNJ0Hi9deKsy2upn2cr6NJGBsHcdxFArJg5j5MnBfjYWSybtjd8XxIHLqHK37m9fidTWZr6qK(XiUsy2upn2cr6NJGBsHcdxFArJg5jz5B2SvKidZIfmLmWhFjgwYupn2cr6NJGBsHcdxFArJg5jz59oTAjCqRQefl4YQQ370QLWX5tKHXO4eycHOPsOExa6JDigv0B9XOEFKw3Rpg43NisJ8uFPr4OTVVycr9bN(QqOxcdoRENwTeoOvvIIfCzIiYLgHJ6D9Ua0hMgtWu7ZG9jIO(cwqtFXdHtFqM(ScQpmnQsJKK9LO(0QLSOENwTeoOveeoGvuLgjjDrEfzyKmGrHK37m9fidTWZr6qK(Xam2270QLWbTIGWjwWLPOknss6gilfJKb8wOqY7DM(cKHw45iDis)aJRKPEASfI0phb3KcfgU(0IgnYtYnB2cfsEVZ0xGm0cphPdr6hiiLWSPEASfI0phb3KcfgU(0IgnYtYYlVekK8ENPVazOLIQ0ijPBGS0abP317cqFXZGP7BFIq0ujuFmWVpm5j2hHQvl6DbOp2H8Kr9zfjQpLXOVpGcvcd61rI6ZRItTO3PvlHdArienvcbgNWHpOoiJZlwtPt(KIJ6DA1s4GwecrtLqXcUSipekDqgNvqoAiCq7DA1s4GwecrtLqXcUmbr9LPooiJtz)0dTIENwTeoOfHq0ujuSGlJbwfrK0PSF6tJCrKIJrYagfsEVZ0xGm0cphPdr6hi442S51u6iw0ylvkrRCcK9WEVtRwch0IqiAQekwWLfk(jdO5i4I8kYWizaJcjV3z6lqgAHNJ0Hi9deCCB28AkDelASLkLOvobYEyV3PvlHdArienvcfl4YQWPsJ9QrshJxXjm85qUQem7HrYa2sCkgGbb7B2Wi69UNQf6lqolXPyiuLB2y6lq2YsCYzqNmPyeWENwTeoOfHq0ujuSGl7ZWqp5YXHc1k170QLWbTieIMkHIfCzpPH5i4y8koH6DA1s4GwecrtLqXcUSGW3lzr54EcbhDQuVtRwch0IqiAQekwWLzfKtCIGIJ0Xa)k176DbOVTrrwFBxr6P(2gfz5i0NwTeoOvFaK1NA9vKcf03x4NWpnq7ZG9HkGV1xn)QyA9LJr)lgA9vHJmTeoO(GtFSRCK9bq6xgMIxbT3fG(Ije1haPFoc9Hvkuy46t9Lm9bkuSVGP33xrA9rduuOOptFbYq9PJSpmbgK((I5hgrucN(0r23(dtjd8X7tFQVbA99KkbfJ(GFFgSVNyEcv0hW2T9ysFWPpliSp43ho8P(m9fidT6DA1s4Gw1GvWis)CeCtkuy46tyiIixWI0tUQISCeadcgvqREYz6lqgcmiyKmG3IL(Pg5PfI0phb3KcfgU(KRkAqgMsyML(Pg5Pvie6DmW3vLOY3Szlj0wOcvcd6ccFPluZz9eZtOcnYtLqHK37m9fidTWZr6qK(bcs59Ua0hqb8T(2M8RIP1haPFoc9Hvkuy46t9vHJmTeo9zW(2JOW(a2UTht6tmSVC6dtd3N9oTAjCqRAWASGldr6NJGBsHcdxFcdre5cwKEYvvKLJayqWOcA1totFbYqGbbJKbSPEASfI0phb3KcfgU(0IgnYtYssOTqfQeg0fe(sxOMZ6jMNqfAKNkHcjV3z6lqgAHNJ0Hi9dmUExa6doEqD1G1(W19iuFwb1NwTeo9bhpO9jI0ip1Nu8ZrOVAHod5ZrOpDK9nqRpf1N23tcIE97tRwcNvVtRwch0QgSgl4YWZr6I8kYWaoEqD1GvWG076DbOp2LMtFyAmbtfJ(qfqrVSVkKf99PEFFVoceQpitFM(cKH6thzFOkn6NquVtRwch0cxZjwWLvvV3PvlHJZNidJrXjWrq4GbY(SAGbbJKbCKidZkcchhKXzfKtrvAKKCjg270QLWbTW1CIfCzYefsEhUkK1Exa6lMquF7pmL9TpFXqlHtFWPVke6LWGtFHqOphH(uRppPiRpSb79LdsN0aTVirRVbA9Lm9bkuSVGP33hKf9vnSVCq6KgO9LtF7pMYQp2LUh1hs8P(qfQegKjPrwgEoYiAK03xI6do9vHqVegC6lIyGp13(Vpx9oTAjCqlCnhWSGP0rVyOLWbJKbml9tnYtRqi07yGVRkrLYbPtAGgiySb7L2khKoPbAmaVFbCZgt90ylePFocUjfkmC9PfnAKNKLyPFQrEAHi9ZrWnPqHHRp5QIgKHP8syUcHEjm4SysAKlXWExa6JDP7r9HeFQpqHI9fkA9jg2hW2T9ysFyAamnM0hC6ZkO(m9fiRVKPVT7vRGr03hMIsFs9LOzFT(0QLSOvVtRwch0cxZjwWLHkujmOli8LUqnhmsgWrImmlgLCcI6ltDqlXWsywsrImmRGVAfmIEhJsFslXWENwTeoOfUMtSGlRQEVtRwchNprggJItGRsuVla9fZnfk6dt(e(PbAFSRCK9bq63NwTeo9zW(EI5jurFSdKnuFbtROpePFocUjfkmC9PENwTeoOfUMtSGldphPdr6JHPVazUKbSPEASfI0phb3KcfgU(0IgnYtYsOqY7DM(cKHw45iDis)azPFQrEAHNJ0Hi9DvrdYWucZsOTqfQeg0fe(sxOMZYY6E5iucZvi0lHbNftsJCjg27cqFyYtm03Nb7ter9Xok(OwcN(W0ayAmPVKPpDaTp2bYwFjQVbA9jgU6DA1s4Gw4AoXcUmPIpQLWbJkOvp5m9fidbgemsgWyML(Pg5PL69oj0qoXWExa6lMquF7pmL9fp0B9PwFfPqb99f(j8td0(cMwrFXCfhb6ZrOV9hMY(ed7ZG9Hn9z6lqgcJ(GFFqRG((m1tJH6do9bW2Q3PvlHdAHR5el4YybtPlc6nmsgW5G0jnqJb49lGLm1tJTkehb6ZrWXcMYfnAKNKLm1tJTqK(5i4MuOWW1Nw0OrEswcfsEVZ0xGm0cphPdr6hdWS3MnBTLPEASvH4iqFocowWuUOrJ8KSeMn1tJTqK(5i4MuOWW1Nw0OrEsw(MnOqY7DM(cKHw45iDisFWGuEVla9XoWzFT(eruFSdXck(5i0hM4vbrQVKPpqHI9v1PpbY6lhd23(dtjd8X7lhKrQeJ(GFFjtFaK(5i0hwPqHHRp1xI6Zupngj7thzFbtVVVI06JgOOqrFM(cKHw9oTAjCqlCnNybxMKybf)CeCHEvqKWOcA1totFbYqGbbJKb8wpX8eQqJ80Mn5G0jnqdKDhWYlTfMzPFQrEAfcHEhd8DvjAZMCq6KgObcE)cy5L2cZM6PXwis)CeCtkuy46tlA0ipj3Szlt90ylePFocUjfkmC9PfnAKNKLWml9tnYtlePFocUjfkmC9jxv0GmmLxEVla9ftiQV9p((GtFBd70xY0hOqX(KWzFT(gIK9zW(QkY6JDiwqXphH(WeVkisy0NoY(Sc6P(0N6ZtiuFwHo9Hn9z6lqgQpOO13wbSVGPv0xfosX0kF170QLWbTW1CIfCzSGP0fb9ggjdyui59otFbYql8CKoePFm2cBITchPyAlzIqWrhZr1ciHw0OrEswEPCq6KgOXa8(fWsM6PXwis)CeCtkuy46tlA0ipj3SbZM6PXwis)CeCtkuy46tlA0ipj7DbOVycr9buOsyW(2o4l3((yhsTI(sM(ScQptFbY6lr9PrqrRpd2NmP(GFFGcf7Rqzr9buOsyqgVIt9HjFIW7JIzIzyij7lyAf9XUYrgrJK((GFFafQegKjPr2NwTKfT6DA1s4Gw4AoXcUmuHkHbDbHV0jj1kWOcA1totFbYqGbbJKb8wM(cKTki1BfRWQfJ4WEjui59otFbYql8CKoePFmWMY3SzRqYwmjnYLwTKfv6fhIb(c0cvOsyqgVItUWpr4lkMjMHHKS8Exa6lMquFaI)tJK((myFSlvoec1hC6t7Z0xGS(Sc16lr9jaZrOpd2NmP(uRpRG67tHcRplXPvVtRwch0cxZjwWLHe)Ngj9od6Wv5qiegvqREYz6lqgcmiyKmGn9fiBzjo5mOtMumIlGLIezywSGPKb(4ljm407cqFXeI6B)HPSp2G)tJ1hC8G2xY0hW2T9ysF6i7B)zRp9P(0QLSO(0r2Nvq9z6lqwFbHZ(A9jtQpP4NJqFwb1xTqNH8RENwTeoOfUMtSGlJfmLod(pnggvqREYz6lqgcmiyKmGzPFQrEAjHgYjgwY0xGSLL4KZGozsbITLIezywSGPKb(4ljm4usRwYICsOTyP4H5NvNbfRfGbJcjV3z6lqgAXsXdZpRodkwlkHcjV3z6lqgAHNJ0Hi9JXwbm2TyVTvt90yllyImhKXXOgTOrJ8KS8Y7DA1s4Gw4AoXcUm8CKr0iPhJKbSeAlwkEy(z1zqXAXYY6E5iuAlt90ylePFocUjfkmC9PfnAKNKLqHK37m9fidTWZr6qK(bYs)uJ80cphPdr67QIgKHzZgj0wOcvcd6ccFPluZzzzDVCekV3fG(Ije1hW2T9StFbtROpmrZj6jDp67dtqQhVpXXtiuFwb1NPVaz9fm9((IO(IipmyFXH9yo6lIyGp1Nvq9vHqVegC6RcXjuFrADVENwTeoOfUMtSGldvOsyqxq4lDssTcmsgWV4qmWxGwHAorpP7rVlePE8ffZeZWqswIL(Pg5PLeAiNyyjtFbYwwItod6cRMloSh4wvi0lHbNfQqLWGUGWx6KKAflP4RwcNyfQYY7DbOVycr9buOsyW(2Mxrf9bN(2g2PpXXtiuFwb9uF6t9PsjQVCQq8Cew9oTAjCqlCnNybxgQqLWGU6ROcmsgWVMshXIgBPsjALtGGG9Exa6lMquFSRCK9bq63Nb7RchKio1h7O)E9XwbuuOWq9f(WkQp40hMEFSpx9X2(GD2h9TnWHjF8(suFwrI6lr9P9vKcf03x4NWpnq7Zk0PVNKqZYrOp40hMEFSp7tC8ec1Nu)96ZkGIcfgQVe1NgbfT(myFwIt9bfTENwTeoOfUMtSGldphPdr6Jrf0QNCM(cKHadcgjdyui59otFbYql8CKoePFGS0p1ipTWZr6qK(UQObzykfjYWSK6VNZkGIcf2smeJAHMdyqWihJ(xm0Cjoojt1iWGGrog9VyO5sgWww3dfi446DbOVycr9XUYr2hMIxbTpd2xfoirCQp2r)96JTcOOqHH6l8HvuFWPpa2w9X2(GD2h9TnWHjF8(sM(SIe1xI6t7RifkOVVWpHFAG2NvOtFpjHMLJqFIJNqO(K6VxFwbuuOWq9LO(0iOO1Nb7ZsCQpOO170QLWbTW1CIfCz45iDmEfumsgWrImmlP(75ScOOqHTedlXs)uJ80scnKtmeJAHMdyqWihJ(xm0Cjoojt1iWGGrog9VyO5sgWww3dfi44kvHqVegCwSGP0fb92smS3fG(Ije1h7khzFX7vK1xY0hOqX(KWzFT(gIK9zW(EI5jurFSdKn0Qpadg2xvrwoc9PwFytFWVpC4t9z6lqgQVGPv0haPFoc9Hvkuy46t9zQNgJKRENwTeoOfUMtSGldphPlYRidJKbml9tnYtlj0qoXWsVMshXIgBHdzr40yRCcSQiZzjofl2xbS0wOqY7DM(cKHw45iDis)yGnLWSPEASfEIOh0fnAKNKB2GcjV3z6lqgAHNJ0Hi9Jb7vYupn2cpr0d6IgnYtYY7DA1s4Gw4AoXcUmwkEy(z1zqXAbgvqREYz6lqgcmiyKmGFI5juHg5PsM(cKTSeNCg0jtkq2BZMTm1tJTWte9GUOrJ8KSKeAluHkHbDbHV0fQ5SEI5juHg5PY3SjsKHzjomIVphbNu)9gcHwIH9Ua0hqivt13xfoY0s40Nb7dzWW(QkYYrOpGTB7XK(GtFqgg2hM(cKH6lybn9XKcfwoc9HT9b)(WHp1hY06EKSpCyeQpDK9jIYrOpmbbATiR9HPMZE9PJSpS2hS1h7kr0d6Q3PvlHdAHR5el4YqfQeg0fe(sxOMdgjd4NyEcvOrEQKPVazllXjNbDYKceBkHzt90yl8erpOlA0ipjlzQNgBfIaTwKvNpN9w0OrEswcfsEVZ0xGm0cphPdr6hyC9Ua0h7tef2hW2T9ysFIH9bN(uuF46aAFM(cKH6tr9fcrOmYty0hX(wPqRVGf00htkuy5i0h22h87dh(uFitR7rY(WHrO(cMwrFycc0Arw7dtnN9w9oTAjCqlCnNybxgQqLWGUGWx6c1CWOcA1totFbYqGbbJKb8tmpHk0ipvY0xGSLL4KZGozsbInLWSPEASfEIOh0fnAKNKLW8wM6PXwis)CeCtkuy46tlA0ipjlHcjV3z6lqgAHNJ0Hi9dKL(Pg5PfEoshI03vfnidt5L2cZM6PXwHiqRfz15ZzVfnAKNKB2SLPEASvic0ArwD(C2BrJg5jzjui59otFbYql8CKoePFmahx5L370QLWbTW1CIfCz45iDisFmQGw9KZ0xGmeyqWizaJcjV3z6lqgAHNJ0Hi9dKL(Pg5PfEoshI03vfniddg1cnhWGGrog9VyO5sCCsMQrGbbJCm6FXqZLmGTSUhkqWX170QLWbTW1CIfCz45iDmEfumQfAoGbbJCm6FXqZL44KmvJadcg5y0)IHMlzaBzDpuGGJRufc9syWzXcMsxe0BlXWExa6lMquFaB32Zo9PO(8kY67je8T(sM(GtFwb1hoKf170QLWbTW1CIfCzOcvcd6ccFPtsQv07cqFXeI6dy72EmPpf1NxrwFpHGV1xY0hC6ZkO(WHSO(0r2hW2T9StFjQp4032Wo9oTAjCqlCnNybxgQqLWGUGWx6c1C4aOqQYXkUaUFCJBCo]] )


end
