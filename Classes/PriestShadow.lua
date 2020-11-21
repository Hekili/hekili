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


    spec:RegisterPack( "Shadow", 20201113, [[d40NtbqiLk9iHcxsiiLnjK(KsPIrju6ucvwLsPuELqvZcQYTecs2LK(Lsjdds0XGKwMsrptiKPbvkxdQkBtiuFdQuzCqcDoLsjRdQenpOQ6EqQ9jeDqOsvluPWdvkvnrHaxuPuPncjqJuii4KcbrRuPQxkeKQzkuKCtHGANOu(jKagkujTuHGqpfIPIs1vfkQTcjOVcvc7LO)sQbRYHPSyj8yLmzsUmYMHYNrLrlrNw0Qfks9ALkMTGBtWUv8BqdhvDCLsXYv1ZbMovxhfBhL8Dcz8kLs15HkwVqrmFc1(LAjQs2LikZjjBBIYnrjQOIkUvr52cLr8M4tI44WtseEBTJXrsKXeijcsPPGIKi8gobOPKSlraqMFrsKs35b4YT2Il9sMI6ckSfifycMNWz9gMVfifwBjrkyYGhHCKfseL5KKTnr5MOevurf3QOCBHs8HsCNeXy8s4lrqsHTxIuMkfnYcjIIaljsm6dP0uqr9HRFsaV3hJ(ydYIekOVpuJi86BtuUjkLiHe4aj7secaOzraj7s2qvYUeXwEchjIajaFC0qmDGzLkT6jtairOXkcKsUH0LSTPKDjIT8eosKIaeQ0qmTxsAAibCKi0yfbsj3q6s2Iij7seB5jCKiCm2RsB0qmTftOh6LseASIaPKBiDjB4MKDjcnwrGuYnKiRpD6ttIa4Pqq72ZroOkKJsdi77ls09TzFIf33BPstSOXRMsbQ50xK9fXOuIylpHJebdUyaKsBXe6tN0fKjiDjB4tYUeHgRiqk5gsK1No9Pjra8uiOD75ihufYrPbK99fj6(2SpXI77TuPjw04vtPa1C6lY(IyukrSLNWrIWZ8jgo5WPlcgWLUKTiwYUeHgRiqk5gseB5jCKil4SOXFZjLglycKez9PtFAsepfO(Wp6(qfL9jwCFymHG(PvP9CK2tbQp83h3s1NyX952ZrE1tbs7qTkP(WFF4tIeYH0lLejILUKnCNKDjIT8eosKp55dKohnG3wKeHgRiqk5gsxYgkkzxIylpHJe5jJphonwWeiGeHgRiqk5gsxY22sYUeXwEchjIi4huSOC0pbGJnlsIqJveiLCdPlzdvukzxIylpHJeXljnZuazgLgd(lsIqJveiLCdPlDjIIWmMGlzxYgQs2Li2Yt4irazGMfjrOXkcKsUH0LSTPKDjcnwrGuYnKiRpD6ttIuWGHvlcqOkWa86t2Y7tS4(C75iV6PaPDOwLuF4hDFOik7tS4(C75iVwswWlR8lVp83xeHpjIT8eoseEONWr6s2Iij7seASIaPKBirG8sea5seB5jCKiSSpTIajryzbgsIOGEfuAkOiTi4R08wovpx7KdxFr7tb9kltGp)CPDiZQS65ANC4KiSSxpMajruqhOz4LUKnCtYUeHgRiqk5gseiVebqUeXwEchjcl7tRiqsewwGHKikOxbLMckslc(knVLt1Z1o5W1x0(uqVYYe4ZpxAhYSkREU2jhU(I2Nc6vfXcY85WP5dghdv9CTtoCsew2RhtGKiwiOvqhOz4LUKn8jzxIqJveiLCdjcKxIaixIylpHJeHL9PveijcllWqseapfcA3EoYbvHCuAazFFr23M9fFFfmyyvwWuHbFHkdVeHL96XeijcGSpho9KCLUG9KEX4qmmPlzlILSlrOXkcKsUHebYlraKlrSLNWrIWY(0kcKeHLfyijYccdkOOPYcMkn9m8EcNkdFFr7l2(2TV3sLMyrJxnLcuz47tS4(ElvAIfnE1ukqvX8MNWPp8JUpurzFIf33BPstSOXRMsbQpjy5a6ls09Hkk7l((WxFBB9fBFUfOXRLmdh95WPzbtvLgRiqQ(elUVfKfn241DW5tB6lU(IRVO9fBFX23BPstSOXRMsbQ50xK9Tjk7tS4(a8uiOD75ihuzbtLMEgEpHtFrIUp81xC9jwCFUfOXRLmdh95WPzbtvLgRiqQ(elUVfKfn241DW5tB6lojcl71JjqseEimOXGVEPasxYgUtYUeHgRiqk5gsK1No9PjrITp(pjGxbuatZdfrVohmgqcN(elUVNzim4Zrvxuoanet7LKgWmA(pjGtaqL2gMKNNu9fxFr7lqSOqFrIUp8HI9fTVcgmSkpue96CWyajCQm89jwCFX2xGyrH(WFF4df7tS4(2Tp(pjGxbuatZdfrVohmgqcN(I23U99mdHbFoQ6IYbOHyAVK0aMrZ)jbCcaQ02WK88KQV46lAFfmyyvwWuHbFHkdVeXwEchjcw(uracvsxYgkkzxIqJveiLCdjY6tN(0KiX2h)NeWRakGP5HIOxNdgdiHtFIf33Zmeg85OQlkhGgIP9ssdygn)NeWjaOsBdtYZtQ(IRVO9fiwuOVir3h(qX(I2xbdgwLhkIEDoymGeovg((elUVy7lqSOqF4Vp8HI9jwCF72h)NeWRakGP5HIOxNdgdiHtFr7B3(EMHWGphvDr5a0qmTxsAaZO5)KaobavABysEEs1xC9fTVcgmSklyQWGVqLHxIylpHJePGEa97KdN0LSTTKSlrOXkcKsUHez9PtFAseapfcA3EoYb1qYv6aDmnJItGgVVir33M9jwCFX23U99wQ0elA8QPuGkTTNah0NyX99wQ0elA8QPuGAo9fzF4o81xCseB5jCKiHKR0b6yAgfNanU0LSHkkLSlrOXkcKsUHez9PtFAsKy7J)tc4vafW08qr0RZbJbKWPpXI77zgcd(Cu1fLdqdX0EjPbmJM)tc4eauPTHj55jvFX1x0(celk0xKO7dFOyFr7RGbdRYdfrVohmgqcNkdFFIf3xS9fiwuOp83h(qX(elUVD7J)tc4vafW08qr0RZbJbKWPVO9TBFpZqyWNJQUOCaAiM2ljnGz08FsaNaGkTnmjppP6lU(I2xbdgwLfmvyWxOYWlrSLNWrIyZIa(Bb9YcbPlzdvuLSlrOXkcKsUHeXwEchjYYcbTT8eo6qcCjsibUEmbsISeTKUKnu3uYUeHgRiqk5gseB5jCKipZOTLNWrhsGlrcjW1JjqseblhPlDjc)tlOqH5s2LSHQKDjcnwrGuYnKiRpD6ttI8KGLdOp83xeHsukrSLNWrIWdfrVwe8vAm47PZOiPlzBtj7seASIaPKBirwF60NMez3(kyWWQGstbfHbFHkdVeXwEchjcO0uqryWxq6s2Iij7seASIaPKBirgtGKiwmbuAVb0yWX1qmnpue9seB5jCKiwmbuAVb0yWX1qmnpue9sxYgUjzxIqJveiLCdjcKxIaixIylpHJeHL9PveijcllWqsKnLiSSxpMajreYrPbK96fJdXWKUKn8jzxIylpHJeHLjWNFU0oKzvkrOXkcKsUH0LUezjAjzxYgQs2Li0yfbsj3qIWaiTOYmq6Lb8C4KSHQeXwEchjcGSpho9KCLUG9KezHZkqA3EoYbs2qvIS(0PpnjsS9XY(0kcufq2NdNEsUsxWEsVyCigwFr7B3(yzFAfbQYdHbng81lfOV46tS4(ITpf0RGstbfPfbFLM3YP(e2tGsRiq9fTpapfcA3EoYbvHCuAazFFr2hQ9fN0LSTPKDjcnwrGuYnKimaslQmdKEzaphojBOkrSLNWrIai7ZHtpjxPlypjrw4ScK2TNJCGKnuLiRpD6ttI4wGgVci7ZHtpjxPlypvPXkcKQVO9PGEfuAkOiTi4R08wo1NWEcuAfbQVO9b4Pqq72ZroOkKJsdi77lY(2u6s2Iij7seASIaPKBirGtah9s0sIGQeXwEchjIqokDrWaU0LUezPas2LSHQKDjcnwrGuYnKiRpD6ttIuWGHvzbtfg8fQm8seB5jCKi8qr0RZbJbKWr6s22uYUeHgRiqk5gseB5jCKiGmqZIKiRpD6ttI8mdHbFoQci(sMycqZ)WvWempHtL2gMKNNu9fTVy7ZTNJ8Ac0Ms1NyX952ZrEvrfmyy1Lb8C4QpzlVV4KilCwbs72ZroqYgQsxYwejzxIqJveiLCdjIT8eosegaPtNeKiRpD6ttIuWGHvzbtfg8fQm89jwCFEkq9fzFOIY(I2xS9TBFlilASXRtYv6AmJ6lojYycKebKdgtqZfmvAo8b6ctXrAiMgJE4kDCKUKnCtYUeXwEchjcMrAog7vPnajcnwrGuYnKUKn8jzxIqJveiLCdjIT8eoseHCuCMabKiRpD6ttIKdWM0XPp8332cL9fTVy7JL9PveOQfcAf0bAg((elUVcgmSklyQWGVqLHVV4KilCwbs72ZroqYgQsxYwelzxIqJveiLCdjY6tN(0KiVLknXIgVAkfOMtFr23MOuIylpHJeHzkHbC0dKLjDjB4oj7seASIaPKBirwF60NMez3(kyWWQSGPcd(cvg((I23U9TGWGckAQSGPstpdVNWPYW3x0(a8uiOD75ihufYrPbK99fzFO2x0(2Tp3c04vazFoC6j5kDb7PknwrGu9jwCFX2xbdgwLfmvyWxOYW3x0(a8uiOD75ihufYrPbK99H)(2SVO9TBFUfOXRaY(C40tYv6c2tvASIaP6lU(elUVy7RGbdRYcMkm4luz47lAFUfOXRaY(C40tYv6c2tvASIaP6lojIT8eosKciC0qmTxsAdSOrrkPlzdfLSlrOXkcKsUHeXwEchjYYcbTT8eo6qcCjsibUEmbsIqaanlciDjBBlj7seB5jCKimasNojaKi0yfbsj3q6sxIuaHJKDjBOkzxIqJveiLCdjY6tN(0KiaEke0U9CKdQc5O0aY((Wp6(IijIT8eosedSOrrkDrWaU0LSTPKDjcnwrGuYnKiRpD6ttIeBFaEke0U9CKdQc5O0aY((ISVn7lAFUfOXRaY(C40tYv6c2tvASIaP6tS4(ITpapfcA3EoYbvHCuAazFFr2hQ9fTVD7ZTanEfq2NdNEsUsxWEQsJveivFX1xC9fTpapfcA3EoYbvdSOrrk9azz9fzFOkrSLNWrIyGfnksPhilt6sxIiy5izxYgQs2Li0yfbsj3qIS(0PpnjsbdgwTachnet7LK2alAuKQYWlra(NlxYgQseB5jCKille02Yt4OdjWLiHe46XeijsbeosxY2Ms2Li2Yt4irujGNcAbJlxseASIaPKBiDjBrKKDjcnwrGuYnKiRpD6ttIWY(0kcuLhcdAm4RxkqFr7lhGnPJtFrIUpCdL9fTVy7lhGnPJtF4hDFOi(6tS4(ClqJxbK95WPNKR0fSNQ0yfbs1x0(yzFAfbQci7ZHtpjxPlypPxmoedRV46lAF8KxXsAuvfu0irSLNWrIWcMkn9m8EchPlzd3KSlrOXkcKsUHez9PtFAsKcgmSkMrAog7vPnGkdFFr7B3(uubdgwv0BEjgtqJz0NuLHxIylpHJebuAkOiTi4R08wosxYg(KSlrOXkcKsUHeXwEchjYYcbTT8eo6qcCjsibUEmbsISuaPlzlILSlrOXkcKsUHeXwEchjIqoknGSxIS(0PpnjIBbA8kGSpho9KCLUG9uLgRiqQ(I2hGNcbTBph5GQqoknGSVVi7JL9PveOQqoknGSxVyCigwFr7B3(uqVcknfuKwe8vAElNQNRDYHRVO9XtEflPrvvqrJezHZkqA3EoYbs2qv6s2WDs2Li0yfbsj3qIylpHJerzcJ5jCKiRpD6ttISBFSSpTIavTqqRGoqZWlrw4ScK2TNJCGKnuLUKnuuYUeHgRiqk5gsK1No9PjrYbyt640h(r3hkIV(I2NBbA8AjZWrFoCAwWuvPXkcKQVO95wGgVci7ZHtpjxPlypvPXkcKQVO9b4Pqq72ZroOkKJsdi77d)O7lI7tS4(ITVy7ZTanETKz4OphonlyQQ0yfbs1x0(2Tp3c04vazFoC6j5kDb7PknwrGu9fxFIf3hGNcbTBph5GQqoknGSVp09HAFXjrSLNWrIWcMkDbm4sxY22sYUeHgRiqk5gsK1No9PjrITVNWEcuAfbQpXI7lhGnPJtFr2hUdF9fxFr7l2(2Tpw2NwrGQ8qyqJbF9sb6tS4(Ybyt640xKO7dfXxFX1x0(ITVD7ZTanEfq2NdNEsUsxWEQsJveivFIf3xS95wGgVci7ZHtpjxPlypvPXkcKQVO9TBFSSpTIavbK95WPNKR0fSN0lghIH1xC9fNeXwEchjIIybz(C408bJJHKUKnurPKDjcnwrGuYnKiRpD6ttIa4Pqq72ZroOkKJsdi77d)9fBF4wFX33cokM0RQeaGJnUMwLqcuPXkcKQV46lAF5aSjDC6d)O7dfXxFr7ZTanEfq2NdNEsUsxWEQsJveivFIf33U95wGgVci7ZHtpjxPlypvPXkcKsIylpHJeHfmv6cyWLUKnurvYUeHgRiqk5gseB5jCKiGstbfPfbFLwrMxkrwF60NMej2(C75iVwswWlR8lVp833MOSVO9b4Pqq72ZroOkKJsdi77d)9HB9fxFIf3xS9XtEflPrvTLNSO(I23Zmeg85OkO0uqrybtG08FceQ02WK88KQV4KilCwbs72ZroqYgQsxYgQBkzxIqJveiLCdjIT8eoseaZ)0OOx7qTGPgcaKiRpD6ttI42ZrE1tbs7qTkP(WFFBIV(I2xbdgwLfmvyWxOQGIgjYcNvG0U9CKdKSHQ0LSHAejzxIqJveiLCdjIT8eosewWuPD4)04sK1No9PjryzFAfbQQGoqZW3x0(C75iV6PaPDOwLuFr2xe1x0(kyWWQSGPcd(cvfu00x0(SLNSiTc6vwMaF(5s7qMvzFO7dDFaEke0U9CKdQSmb(8ZL2HmRY(I2hGNcbTBph5GQqoknGSVp83xS9HV(IVVy7lI7BBRp3c04vxucCnetJzovPXkcKQV46lojYcNvG0U9CKdKSHQ0LSHkUjzxIqJveiLCdjY6tN(0KikOxzzc85NlTdzwLvpx7KdxFr7l2(ClqJxbK95WPNKR0fSNQ0yfbs1x0(a8uiOD75ihufYrPbK99fzFSSpTIavfYrPbK96fJdXW6tS4(uqVcknfuKwe8vAElNQNRDYHRV4Ki2Yt4ireYrvqJIEPlzdv8jzxIqJveiLCdjY6tN(0KipZqyWNJQ8wofpz7qVMhybHkTnmjppP6lAFSSpTIavvqhOz47lAFU9CKx9uG0ouZVC9MOSVi7l2(wqyqbfnvqPPGI0IGVsRiZlRkM38eo9fFFClvFXjrSLNWrIaknfuKwe8vAfzEP0LSHAelzxIqJveiLCdjY6tN(0KiVLknXIgVAkfOMtFr2hQOuIylpHJebuAkOi96nqP0LSHkUtYUeHgRiqk5gseB5jCKic5O0aYEjYcNvG0U9CKdKSHQejhN(NH31jMeXZ1oGirVPejhN(NH31PGaPsZjjcQsK1No9Pjra8uiOD75ihufYrPbK99fzFSSpTIavfYrPbK96fJdXW6lAFfmyyvL97O9sidxPxz4LiRslhjcQsxYgQOOKDjcnwrGuYnKi2Yt4ireYrPXcgosKCC6FgExNysepx7aIe9MrxqyqbfnvwWuPlGbVYWlrYXP)z4DDkiqQ0CsIGQez9PtFAsKcgmSQY(D0EjKHR0Rm89fTpw2NwrGQkOd0m8sKvPLJebvPlzd1TLKDjcnwrGuYnKiRpD6ttIWY(0kcuvbDGMHVVO99wQ0elA8QaKfjqJxZPVi7Bzax7Pa1x89HYk(6lAFX2hGNcbTBph5GQqoknGSVp83hU1x0(2Tp3c04vHeqpovASIaP6tS4(a8uiOD75ihufYrPbK99H)(I4(I2NBbA8QqcOhNknwrGu9fNeXwEchjIqokDrWaU0LSTjkLSlrOXkcKsUHeXwEchjcltGp)CPDiZQuIS(0PpnjYtypbkTIa1x0(C75iV6PaPDOwLuFr2xe3NyX9fBFUfOXRcjGECQ0yfbs1x0(uqVcknfuKwe8vAElN6typbkTIa1xC9jwCFfmyyvMbJ5d5WPv2VZqaqLHxISWzfiTBph5ajBOkDjBBIQKDjcnwrGuYnKiRpD6ttI8e2tGsRiq9fTp3EoYREkqAhQvj1xK9HB9fTVD7ZTanEvib0JtLgRiqQ(I2NBbA8kpaNvzU0HC2PsJveivFr7dWtHG2TNJCqvihLgq23xK9TPeXwEchjcO0uqrArWxP5TCKUKTn3uYUeHgRiqk5gseB5jCKiGstbfPfbFLM3YrIS(0PpnjYtypbkTIa1x0(C75iV6PaPDOwLuFr2hU1x0(2Tp3c04vHeqpovASIaP6lAF72xS95wGgVci7ZHtpjxPlypvPXkcKQVO9b4Pqq72ZroOkKJsdi77lY(yzFAfbQkKJsdi71lghIH1xC9fTVy7B3(ClqJx5b4SkZLoKZovASIaP6tS4(ITp3c04vEaoRYCPd5StLgRiqQ(I2hGNcbTBph5GQqoknGSVp8JUVn7lU(ItISWzfiTBph5ajBOkDjBBgrs2Li0yfbsj3qIylpHJerihLgq2lrw4ScK2TNJCGKnuLi540)m8UoXKiEU2bej6nLi540)m8UofeivAojrqvIS(0PpnjcGNcbTBph5GQqoknGSVVi7JL9PveOQqoknGSxVyCigMezvA5irqv6s22e3KSlrOXkcKsUHeXwEchjIqoknwWWrIKJt)ZW76etI45AhqKO3m6ccdkOOPYcMkDbm4vgEjsoo9pdVRtbbsLMtseuLiRslhjcQsxY2M4tYUeXwEchjcO0uqrArWxPvK5LseASIaPKBiDjBBgXs2Li2Yt4iraLMckslc(knVLJeHgRiqk5gsx6sxIWIEqchjBBIYnrjQOIkQser2p5WbKirif4HVtQ(WD9zlpHtFHe4GAVxIW)qSmqsKy0hsPPGI6dx)KaEVpg9XgKfjuqFFOgr413MOCtu2779XOVT72oTyCs1xbHbFQVfuOW8(kiUCa1(W9RfX7G(g4eHQ0EbmMqF2Yt4a6dobCQ9EB5jCav(NwqHcZJh9w8qr0RfbFLgd(E6mkcVed9tcwoa8hrOeL9EB5jCav(NwqHcZJh9wGstbfHbFb8sm07wWGHvbLMckcd(cvg(EVT8eoGk)tlOqH5XJElgaPtNeWBmbcTftaL2BangCCnetZdfrFV3wEchqL)PfuOW84rVfl7tRiq4nMaHwihLgq2RxmoeddpipAa54XYcme6n792Yt4aQ8pTGcfMhp6Tyzc85NlTdzwL9(EFm6dxHEchqV3wEchaAqgOzr9EB5jCaXJElEONWbVedDbdgwTiaHQadWRpzlxSy3EoYREkqAhQvjHF0Oikfl2TNJ8AjzbVSYVC8hr4R3BlpHdiE0BXY(0kceEJjqOvqhOz4XdYJgqoESSadHwb9kO0uqrArWxP5TCQEU2jhUOkOxzzc85NlTdzwLvpx7KdxV3wEchq8O3IL9Pvei8gtGqBHGwbDGMHhpipAa54XYcmeAf0RGstbfPfbFLM3YP65ANC4IQGELLjWNFU0oKzvw9CTtoCrvqVQiwqMphonFW4yOQNRDYHR3hJ(qC79(ya5W1hczFoC9XwYv6c2t9zEFru8952ZroOp43hUfFFjwF4az6ZEQVC6dfctfg8f692Yt4aIh9wSSpTIaH3yceAazFoC6j5kDb7j9IXHyy4b5rdihpwwGHqd4Pqq72ZroOkKJsdi7JCZ4lyWWQSGPcd(cvg(EFm6B7HWGckA6dxHWqFOq7tRiq41xmdivFoSpEim0xbHbFQpB5jlZZHRpwWuHbFHAFBpZ)04bC6JbqQ(CyFl44pm0NOsA6ZH9zlpzzo1hlyQWGVqFIsVSVCwqHC46ZukqT3BlpHdiE0BXY(0kceEJjqO5HWGgd(6LcGhKhnGC8yzbgc9ccdkOOPYcMkn9m8EcNkdF0y39TuPjw04vtPavgEXIFlvAIfnE1ukqvX8MNWb)OrfLIf)wQ0elA8QPuG6tcwoGirJkkJhFBBX6wGgVwYmC0NdNMfmvvASIaPelEbzrJnEDhC(0M4IlASX(wQ0elA8QPuGAorUjkflgWtHG2TNJCqLfmvA6z49eorIgFXjwSBbA8AjZWrFoCAwWuvPXkcKsS4fKfn241DW5tBIR3hJ(Iq0wPfa9EB5jCaXJElS8PIaeQWlXqhl)NeWRakGP5HIOxNdgdiHJyXpZqyWNJQUOCaAiM2ljnGz08FsaNaGkTnmjppPIlAGyrHirJpumAbdgwLhkIEDoymGeovgEXIJnqSOa(Xhkkw8U8FsaVcOaMMhkIEDoymGeor39zgcd(Cu1fLdqdX0EjPbmJM)tc4eauPTHj55jvCrlyWWQSGPcd(cvg(EVT8eoG4rVvb9a63jho8sm0XY)jb8kGcyAEOi615GXas4iw8Zmeg85OQlkhGgIP9ssdygn)NeWjaOsBdtYZtQ4Igiwuis04dfJwWGHv5HIOxNdgdiHtLHxS4ydelkGF8HIIfVl)NeWRakGP5HIOxNdgdiHt0DFMHWGphvDr5a0qmTxsAaZO5)KaobavABysEEsfx0cgmSklyQWGVqLHV3hJ(Iza1xmvYv6BhqF7zuCc049Ly95L0t9zp13M9b)(eGp1NBph5a86d(9zkfOp7Pz749b4nrtoC9Hb)(eGp1NxAtF4o8bQ9EB5jCaXJERqYv6aDmnJItGghVednGNcbTBph5GAi5kDGoMMrXjqJhj6nflo2DFlvAIfnE1ukqL22tGdel(TuPjw04vtPa1CIe3HV4692Yt4aIh9w2SiG)wqVSqaVedDS8FsaVcOaMMhkIEDoymGeoIf)mdHbFoQ6IYbOHyAVK0aMrZ)jbCcaQ02WK88KkUObIffIen(qXOfmyyvEOi615GXas4uz4flo2aXIc4hFOOyX7Y)jb8kGcyAEOi615GXas4eD3Nzim4Zrvxuoanet7LKgWmA(pjGtaqL2gMKNNuXfTGbdRYcMkm4luz4792Yt4aIh9wlle02Yt4OdjWXBmbc9s0Q3BlpHdiE0B9mJ2wEchDiboEJjqOfSC699(y032hbGEVT8eoG6sbqZdfrVohmgqch8sm0fmyyvwWuHbFHkdFVpg9fZaQpKmqZI6do9T9rqFoSp(hU6dH4lzIjBhqF46dxbtW8eo1EVT8eoG6sbIh9wGmqZIWBHZkqA3EoYbOrfVed9Zmeg85OkG4lzIjan)dxbtW8eovABysEEsfnw3EoYRjqBkLyXU9CKxvubdgwDzaphU6t2YJR3hJ(Iza13gMIJ6lhqQO(Gy9Hcrb7dd(95LuFy5d8(yauFWVp4032hb9zyo995LuFy5d8(yauTpCr6L9XwYv69HcAuFLWGQpm43hkefS27TLNWbuxkq8O3Ibq60jb8gtGqdYbJjO5cMknh(aDHP4inetJrpCLoo4LyOlyWWQSGPcd(cvgEXI9uGIevugn2Dxqw0yJxNKR01ygfxV3wEchqDPaXJElmJ0Cm2RsBa9EB5jCa1Lcep6TeYrXzceaVfoRaPD75ihGgv8sm05aSjDCW)2cLrJLL9PveOQfcAf0bAgEXIlyWWQSGPcd(cvg(4692Yt4aQlfiE0BXmLWao6bYYWlXq)wQ0elA8QPuGAorUjk792Yt4aQlfiE0BvaHJgIP9ssBGfnksHxIHE3cgmSklyQWGVqLHp6UlimOGIMklyQ00ZW7jCQm8rb8uiOD75ihufYrPbK9rIA0DDlqJxbK95WPNKR0fSNQ0yfbsjwCSfmyyvwWuHbFHkdFuapfcA3EoYbvHCuAazp(3m6UUfOXRaY(C40tYv6c2tvASIaPItS4ylyWWQSGPcd(cvg(OUfOXRaY(C40tYv6c2tvASIaPIR3BlpHdOUuG4rV1YcbTT8eo6qcC8gtGqtaanlc07JrFraHzmbVpmlekS1o9Hb)(yawrG6lDsaGl7lMbuFWPVfeguqrtT3BlpHdOUuG4rVfdG0PtcGEFVpg9H7X1yQ(CyFmaQprL003gq40heRpVK6d3dw0OivFjOpB5jlQ3BlpHdOwaHdAdSOrrkDrWaoEjgAapfcA3EoYbvHCuAazp(rhr9EB5jCa1ciCIh9wgyrJIu6bYYWlXqhlGNcbTBph5GQqoknGSpYnJ6wGgVci7ZHtpjxPlypvPXkcKsS4yb8uiOD75ihufYrPbK9rIA0DDlqJxbK95WPNKR0fSNQ0yfbsfxCrb8uiOD75ihunWIgfP0dKLfjQ9(EFm6BdmCFFBxaGMfb6dd(9HRpfHI38vzVpg9fbuGCQpVmb9zyo99HuAkOOGnkqFbJzwL9EB5jCavcaOzra0cKa8XrdX0bMvQ0QNmbqV3wEchqLaaAweiE0BveGqLgIP9sstdjGtV3wEchqLaaAweiE0BXXyVkTrdX0wmHEOx27TLNWbujaGMfbIh9wyWfdGuAlMqF6KUGmb8sm0aEke0U9CKdQc5O0aY(irVPyXVLknXIgVAkfOMtKrmk792Yt4aQeaqZIaXJElEMpXWjhoDrWaoEjgAapfcA3EoYbvHCuAazFKO3uS43sLMyrJxnLcuZjYigL9EB5jCavcaOzrG4rV1colA83CsPXcMaHxihsVuOJy8sm0Ekq4hnQOuSymMqq)0Q0Eos7PaHFULsSy3EoYREkqAhQvjHF817TLNWbujaGMfbIh9wFYZhiDoAaVTOEVT8eoGkba0Siq8O36jJphonwWeiqV3wEchqLaaAweiE0Bjc(bflkh9ta4yZI692Yt4aQeaqZIaXJElVK0mtbKzuAm4VOEFVpg9T9gW7dxuMbQVT3aEoC9zlpHdO2hc59zEFLjxj99X)j8thN(CyFGs479TYFXKEF540)m8EFl4OspHdOp40xeohvFiK9BHcgmC69XOVygq9Hq2NdxFSLCLUG9uFjwF4az6tugc9vMEF0az4k7ZTNJCqF2O6dxHIOVViKdgdiHtF2O6dfctfg8f6ZEQVb699KPWbV(GFFoSVNWEcu2hcUaxIR9bN(CrW(GFFcWN6ZTNJCqT3BlpHdOUeTqdi7ZHtpjxPlypHhdG0IkZaPxgWZHdnQ4TWzfiTBph5a0OIxIHoww2NwrGQaY(C40tYv6c2t6fJdXWIUll7tRiqvEimOXGVEPaXjwCSkOxbLMckslc(knVLt9jSNaLwrGIc4Pqq72ZroOkKJsdi7Je1469XOpKs479T95VysVpeY(C46JTKR0fSN6Bbhv6jC6ZH9Tdr89HGlWL4AFm89LtF4E42T3BlpHdOUeTIh9waY(C40tYv6c2t4XaiTOYmq6Lb8C4qJkElCwbs72ZroanQ4LyODlqJxbK95WPNKR0fSNQ0yfbsfvb9kO0uqrArWxP5TCQpH9eO0kcuuapfcA3EoYbvHCuAazFKB27JrFWjGJEjA1NGTdb6ZlP(SLNWPp4eWPpgGveO(umFoC9TkTzOqoC9zJQVb69zG(S(EIJjyFF2Yt4u792Yt4aQlrR4rVLqokDrWaoEWjGJEjAHg1EFVpg9fHTC6d3JRXu41hOeYeu9TGSOVple67THJa9bX6ZTNJCqF2O6dSOX(ec692Yt4aQcwoXJERLfcAB5jC0He44nMaHUach8a(NlhnQ4LyOlyWWQfq4OHyAVK0gyrJIuvg(EVT8eoGQGLt8O3sLaEkOfmUC17JrFXmG6dfctvFB3NH3t40hC6BbHbfu00hpegYHRpZ7lqgW7d3qzF5aSjDC6RGX7BGEFjwF4az6tugc9bzr)Y47lhGnPJtF50hkefS2xe22H6dW8uFGstbfHL0O2sihvbnk67lb9bN(wqyqbfn9vqyWN6dfUDR9EB5jCavblh0SGPstpdVNWbVednl7tRiqvEimOXGVEParZbyt64ejACdLrJnhGnPJd(rJI4tSy3c04vazFoC6j5kDb7PknwrGurzzFAfbQci7ZHtpjxPlypPxmoedlUO8KxXsAuvfu007JrFryBhQpaZt9HdKPpEgVpg((qWf4sCTpCpcUhx7do95LuFU9CK3xI1hU4nVeJj0hkOrFs9LGz749zlpzr1EVT8eoGQGLt8O3cuAkOiTi4R08wo4LyOlyWWQygP5ySxL2aQm8r3vrfmyyvrV5LymbnMrFsvg(EVT8eoGQGLt8O3AzHG2wEchDiboEJjqOxkqVpg9fHqYv2hU(j8thN(IW5O6dHSVpB5jC6ZH99e2tGY(Iai7G(eLEzFaY(C40tYv6c2t9EB5jCavblN4rVLqoknGShVfoRaPD75ihGgv8sm0UfOXRaY(C40tYv6c2tvASIaPIc4Pqq72ZroOkKJsdi7JKL9PveOQqoknGSxVyCigw0DvqVcknfuKwe8vAElNQNRDYHlkp5vSKgvvbfn9(y0hU(eg995W(yauFrGjmMNWPpCpcUhx7lX6ZgC6lcGS3xc6BGEFm81EVT8eoGQGLt8O3szcJ5jCWBHZkqA3EoYbOrfVed9USSpTIavTqqRGoqZW37JrFXmG6dfctvFBadEFM3xzYvsFF8Fc)0XPprPx2xecmdh95W1hkeMQ(y47ZH9HB952ZroaV(GFFqVK((ClqJd6do9HWET3BlpHdOky5ep6TybtLUagC8sm05aSjDCWpAueFrDlqJxlzgo6ZHtZcMQknwrGurDlqJxbK95WPNKR0fSNQ0yfbsffWtHG2TNJCqvihLgq2JF0rSyXXgRBbA8AjZWrFoCAwWuvPXkcKk6UUfOXRaY(C40tYv6c2tvASIaPItSyapfcA3EoYbvHCuAazpAuJR3hJ(Ia4SD8(yauFraXcY85W1hUgmogQVeRpCGm9TSPpoY7lhh2hkeMkm4l0xoaNmfE9b)(sS(qi7ZHRp2sUsxWEQVe0NBbACs1NnQ(eLHqFLP3hnqgUY(C75ihu792Yt4aQcwoXJElfXcY85WP5dghdHNBph56edDSpH9eO0kcKyX5aSjDCIe3HV4Ig7USSpTIav5HWGgd(6LciwCoaBshNirJI4lUOXURBbA8kGSpho9KCLUG9uLgRiqkXIJ1TanEfq2NdNEsUsxWEQsJveiv0DzzFAfbQci7ZHtpjxPlypPxmoedlU469XOVygq9Hc3Op4032hb9Ly9HdKPpfC2oEFdrQ(CyFld49fbeliZNdxF4AW4yi86ZgvFEj9uF2t9fiaOpV0M(WT(C75ih0hKX7lw81NO0l7Bbhft6Xv792Yt4aQcwoXJElwWuPlGbhVednGNcbTBph5GQqoknGSh)XIBXVGJIj9Qkba4yJRPvjKavASIaPIlAoaBshh8JgfXxu3c04vazFoC6j5kDb7PknwrGuIfVRBbA8kGSpho9KCLUG9uLgRiqQEFm6lMbuFiLMckQpCb8v4Y(IaY8Y(sS(8sQp3EoY7lb9zfqgVph2NkP(GFF4az6R0yr9HuAkOiSGjq9HRFce6J2gMKNNu9jk9Y(IW5OkOrrFFWVpKstbfHL0O6ZwEYIQ9EB5jCavblN4rVfO0uqrArWxPvK5L4TWzfiTBph5a0OIxIHow3EoYRLKf8Yk)YX)MOmkGNcbTBph5GQqoknGSh)4wCIfhlp5vSKgv1wEYII(mdHbFoQcknfuewWein)NaHkTnmjppPIR3hJ(Iza1hcZ)0OOVph2xe2udba9bN(S(C75iVpV08(sqFCWC46ZH9PsQpZ7ZlP((KR07ZtbQ27TLNWbufSCIh9waM)PrrV2HAbtneaG3cNvG0U9CKdqJkEjgA3EoYREkqAhQvjH)nXx0cgmSklyQWGVqvbfn9(y0xmdO(qHWu1h7W)PX7dobC6lX6dbxGlX1(Sr1hkK9(SN6ZwEYI6ZgvFEj1NBph59jcoBhVpvs9Py(C46ZlP(wL2muO27TLNWbufSCIh9wSGPs7W)PXXBHZkqA3EoYbOrfVednl7tRiqvf0bAg(OU9CKx9uG0ouRskYikAbdgwLfmvyWxOQGIMO2YtwKwb9kltGp)CPDiZQenAapfcA3EoYbvwMaF(5s7qMvzuapfcA3EoYbvHCuAazp(JfFXhBeVT5wGgV6IsGRHyAmZPknwrGuXfxV3wEchqvWYjE0BjKJQGgf94LyOvqVYYe4ZpxAhYSkREU2jhUOX6wGgVci7ZHtpjxPlypvPXkcKkkGNcbTBph5GQqoknGSpsw2NwrGQc5O0aYE9IXHyyIfRGEfuAkOiTi4R08wovpx7KdxC9(y0xmdO(qWf4YiOprPx2hUA5u8KTd99HRali0hZeiaOpVK6ZTNJ8(eLHqFfuFfuakQVnrzeA9vqyWN6ZlP(wqyqbfn9TGceOVcBTtV3wEchqvWYjE0BbknfuKwe8vAfzEjEjg6Nzim4ZrvElNINSDOxZdSGqL2gMKNNurzzFAfbQQGoqZWh1TNJ8QNcK2HA(LR3eLrg7ccdkOOPcknfuKwe8vAfzEzvX8MNWjEULkUEFm6lMbuFiLMckQVT)nqzFWPVTpc6Jzcea0Nxsp1N9uFMsb6lNfuihUAV3wEchqvWYjE0BbknfuKE9gOeVed9BPstSOXRMsbQ5ejQOS3hJ(Iza1xeohvFiK995W(wWbWiq9fb2VtFSxcz4kDqF8pCb6do9H7rb2U1(yhficqb6B7Hdw(c9LG(8Ye0xc6Z6Rm5kPVp(pHF640NxAtFpPGUNdxFWPpCpkW2TpMjqaqFk73PpVeYWv6G(sqFwbKX7ZH95Pa1hKX792Yt4aQcwoXJElHCuAazpElCwbs72ZroanQ4LyOb8uiOD75ihufYrPbK9rYY(0kcuvihLgq2RxmoedlAbdgwvz)oAVeYWv6vgE8wLwoOrfVCC6FgExNccKknNqJkE540)m8UoXq75AhqKO3S3hJ(Iza1xeohvFOGbdN(CyFl4ayeO(Ia73Pp2lHmCLoOp(hUa9bN(qyV2h7OarakqFBpCWYxOVeRpVmb9LG(S(ktUs67J)t4Noo95L203tkO75W1hZeiaOpL970Nxcz4kDqFjOpRaY495W(8uG6dY49EB5jCavblN4rVLqoknwWWbVedDbdgwvz)oAVeYWv6vg(OSSpTIavvqhOz4XBvA5Ggv8YXP)z4DDkiqQ0CcnQ4LJt)ZW76edTNRDarIEZOlimOGIMklyQ0fWGxz479XOVygq9fHZr13gbd49Ly9HdKPpfC2oEFdrQ(CyFpH9eOSViaYoO2hId57BzaphU(mVpCRp43Na8P(C75ih0NO0l7dHSphU(yl5kDb7P(ClqJtQAV3wEchqvWYjE0BjKJsxemGJxIHML9PveOQc6andF03sLMyrJxfGSibA8AorUmGR9uGIhLv8fnwapfcA3EoYbvHCuAazp(XTO76wGgVkKa6XPsJveiLyXaEke0U9CKdQc5O0aYE8hXrDlqJxfsa94uPXkcKkUEVT8eoGQGLt8O3ILjWNFU0oKzvI3cNvG0U9CKdqJkEjg6NWEcuAfbkQBph5vpfiTd1QKImIflow3c04vHeqpovASIaPIQGEfuAkOiTi4R08wo1NWEcuAfbkoXIlyWWQmdgZhYHtRSFNHaGkdFVpg9HWtR0c9TGJk9eo95W(aoKVVLb8C46dbxGlX1(GtFqmSiuU9CKd6tujn9HLCLEoC9fr9b)(eGp1hWT1oKQpbybOpBu9XaYHRpCfGZQmx9ftLZo9zJQp2qbyVViCcOhNAV3wEchqvWYjE0BbknfuKwe8vAElh8sm0pH9eO0kcuu3EoYREkqAhQvjfjUfDx3c04vHeqpovASIaPI6wGgVYdWzvMlDiNDQ0yfbsffWtHG2TNJCqvihLgq2h5M9(y0xe6eX3hcUaxIR9XW3hC6Za9jydo952ZroOpd0hpeaYIaHxF02(I49(evstFyjxPNdxFruFWVpb4t9bCBTdP6tawa6tu6L9HRaCwL5QVyQC2P27TLNWbufSCIh9wGstbfPfbFLM3YbVfoRaPD75ihGgv8sm0pH9eO0kcuu3EoYREkqAhQvjfjUfDx3c04vHeqpovASIaPIUBSUfOXRaY(C40tYv6c2tvASIaPIc4Pqq72ZroOkKJsdi7JKL9PveOQqoknGSxVyCigwCrJDx3c04vEaoRYCPd5StLgRiqkXIJ1TanELhGZQmx6qo7uPXkcKkkGNcbTBph5GQqoknGSh)O3mU4692Yt4aQcwoXJElHCuAazpElCwbs72ZroanQ4LyOb8uiOD75ihufYrPbK9rYY(0kcuvihLgq2RxmoeddVvPLdAuXlhN(NH31PGaPsZj0OIxoo9pdVRtm0EU2bej6n792Yt4aQcwoXJElHCuASGHdERslh0OIxoo9pdVRtbbsLMtOrfVCC6FgExNyO9CTdis0BgDbHbfu0uzbtLUag8kdFVpg9fZaQpeCbUmc6Za9fmG33ta479Ly9bN(8sQpbilQ3BlpHdOky5ep6TaLMckslc(kTImVS3hJ(Iza1hcUaxIR9zG(cgW77ja89(sS(GtFEj1NaKf1NnQ(qWf4YiOVe0hC6B7JGEVT8eoGQGLt8O3cuAkOiTi4R08woseapTKSTj(qrPlDPe]] )


end
