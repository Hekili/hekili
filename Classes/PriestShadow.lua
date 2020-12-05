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


    spec:RegisterPack( "Shadow", 20201205, [[dafnCbqivs9icPUKkviAtsL(KkvKrrQYPiv1QuPc1RujmlqQBrirSlP8lvQAyechdKSmvIEMur10GI01ivyBqrvFJurmoOiCosfvwhHOmpPICpO0(KkCqcjSqvsEOurzIQuPlQsf1gjvK(iHePrsQO4KesuRek8svQqQzsQOQBsiQ2jrYpHIOgkuuoQkvizPQuHWtH0ujsDvcr2kHK(kuuzVK8xrnyLomvlMuESkMmsxg1MH4ZemAPQttz1qreVMuPzlYTHQDR43QA4e1XvPcwoWZrmDHRdQTdIVteJNurPZRsz9qrKMpHA)swbLsAfk1dwj1LI4sra1LIqhnOGctXumftOqJBYScv2p66cScDCCwHI270xIcv2VLENQKwHsEyWHvO9ritez3FVGf9WATZJFpXWHtEy)CaosCpXWp3Rq1GTuikpknfk1dwj1LI4sra1LIqhnOG6smftVuH6Wr)duOOgENPq7nkLhLMcLYKJcv01I270xsTygWysuyi6AVlFyCnguRoGU2lfXLIqHMmsqusRqPmIdNcL0kPGsjTc1pH9JcLyjEoScLhxlXu1vQqj1LkPvO84AjMQUsHEawWaZvOAWiiniVrrEaEdwUwXIRvdgbPj)syq2geyI9tdwwH6NW(rHk)H9Jkus15kPvO84AjMQUsH(Ykuchku)e2pkuioWCTeRqH4jywHs)Or6D6ljl5b0SSBtlSJU2iuB3APF0G44YgWo54Hp9TWo6AJGcfIdYJJZku6hKmSSkusHPkPvO84AjMQUsH(Ykuchku)e2pkuioWCTeRqH4jywHs)Or6D6ljl5b0SSBtlSJU2iuB3APF0G44YgWo54Hp9TWo6AJqTDRL(rJYqEyGncz5KlaZTWo6AJGcfIdYJJZkupLY0pizyzvOKshkPvO84AjMQUsH(Ykuchku)e2pkuioWCTeRqH4jywHsK5ukhoqGdsd3gAMWoO2oQ9YAVOwnyeKgK3OipaVblRqH4G844ScLWoWgH8yc9bUd48boEeevOKcZRKwHYJRLyQ6kf6lRqjCOq9ty)OqH4aZ1sScfINGzf65)e9LmniVrZmawoSFAWY12Tw9Q96AbUrZmeEIMtPKgSCTIfxlWnAMHWt0CkL0OWapSFQTtyRfkruRyX1cCJMzi8enNsjnaJ72qQTdS1cLiQ9IA1rT3X1QxTHN4jA9WJadSrid5nAJhxlX0AflU2ZdHhFIMU3aMp1QFT6xB3A1Rw9Qf4gnZq4jAoLsA2uBh1EPiQvS4AjYCkLdhiWbPb5nAMbWYH9tTDGTwDuR(1kwCTHN4jA9WJadSrid5nAJhxlX0AflU2ZdHhFIMU3aMp1QVcfIdYJJZku5)tzKhKpuIkusPtusRq5X1smvDLc9aSGbMRq1GrqAqEJI8a8gSSc1pH9JcfXaSw6FQkusHjusRq5X1smvDLc9aSGbMRq1GrqAqEJI8a8gSSc1pH9JcvJbegORncQqjLoNsAfkpUwIPQRuOhGfmWCfkrMtPC4aboiTKj0hKmMeyQaoprTDGT2lRvS4A1R2RRf4gnZq4jAoLsASoRrcsTIfxlWnAMHWt0CkL0SP2oQvNOJA1xH6NW(rHMmH(GKXKatfW5juHskOeHsAfkpUwIPQRuOhGfmWCfQgmcsdYBuKhG3GLvO(jSFuO(Cysa8u(4PKkusbfukPvO84AjMQUsH6NW(rHE8uk7NW(jNmsOqtgjYJJZk0JKJkusb1LkPvO84AjMQUsH6NW(rHcGNSFc7NCYiHcnzKipooRqXDBuHkuOuCHCaSrxoikPvsbLsAfkpUwIPQRuOJJZkuQd0f))jt5JU5SmCayYHNdRq9ty)OqPoqx8)NmLp6MZYWbGjhEoSkusDPsAfkpUwIPQRuOJJZkuc8OL(NMDCo6VrcfQFc7hfkbE0s)tZooh93iHkus15kPvO84AjMQUsHoooRqfs3K7Zps2jed3sEy)Oq9ty)Oqfs3K7Zps2jed3sEy)OcLuyQsAfkpUwIPQRuOJJZkukGDkIb4meMq4Kc1pH9JcLcyNIyaodHjeoPcvOqXDBusRKckL0kuECTetvxPqpalyG5kunyeKM2)t(rYrpNDYHhktBWYkusaStOKckfQFc7hf6XtPSFc7NCYiHcnzKipooRq1(FuHsQlvsRq9ty)OqPgrMtzCxWokuECTetvxPcLuDUsAfkpUwIPQRuOhGfmWCfkehyUwIBY)NYipiFOKA7wRneFS4wTDGTwmve12Tw9Q1gIpwCR2oHTwmHoQvS4AdpXt0iSdSripMqFG7aUXJRLyATDRfIdmxlXnc7aBeYJj0h4oGZh44rqQv)A7w711E(prFjtdX4H2GLvO(jSFuOqEJMzaSCy)OcLuyQsAfkpUwIPQRuOhGfmWCfQgmcsdX5SaSdOMpKgSCTDR96APSgmcstcWJEe4ugXzGXnyzfQFc7hfkP3PVKSKhqZYUnQqjLousRq5X1smvDLc1pH9Jc94Pu2pH9tozKqHMmsKhhNvOhkrfkPW8kPvO84AjMQUsHEawWaZvOHN4jAe2b2iKhtOpWDa34X1smT2U1sK5ukhoqGdsd3gAMWoO2oQfIdmxlXnCBOzc7G8boEeKA7w711s)Or6D6ljl5b0SSBtlSJU2iuB3AVU2Z)j6lzAigp0gSSc1pH9Jcf3gAMWoqHEUDsCoCGaheLuqPcLu6eL0kuECTetvxPqpalyG5k0RRfIdmxlXnpLY0pizyzfQFc7hfk1XhpSFuONBNeNdhiWbrjfuQqjfMqjTcLhxlXu1vk0dWcgyUc1gIpwCR2oHTwmHoQTBTHN4jA9WJadSrid5nAJhxlX0A7wB4jEIgHDGnc5Xe6dChWnECTetRTBTezoLYHde4G0WTHMjSdQTtyRfZxRyX1QxT6vB4jEIwp8iWaBeYqEJ24X1smT2U1EDTHN4jAe2b2iKhtOpWDa34X1smTw9RvS4AjYCkLdhiWbPHBdntyhul2AHQw9vO(jSFuOqEJM1(uOcLu6CkPvO84AjMQUsHEawWaZvO6vlGramP31sCTIfxRneFS4wTDuRorh1QFTDRvVAVUwioWCTe3K)pLrEq(qj1kwCT2q8XIB12b2AXe6Ow9RTBT6v711gEINOryhyJqEmH(a3bCJhxlX0AflUw9Qn8eprJWoWgH8yc9bUd4gpUwIP12T2RRfIdmxlXnc7aBeYJj0h4oGZh44rqQv)A1xH6NW(rHszipmWgHSCYfGzf652jX5WbcCqusbLkusbLiusRq5X1smvDLc9aSGbMRqjYCkLdhiWbPHBdntyhuBNQvVAX0AVO2ZpuylAuJq(XNiZN(NjnECTetRv)A7wRneFS4wTDcBTycDuB3AdpXt0iSdSripMqFG7aUXJRLyATIfx711gEINOryhyJqEmH(a3bCJhxlXufQFc7hfkK3OzTpfQqjfuqPKwHYJRLyQ6kf6bybdmxHQxTHde4O1ZEk6BYNO2ov7LIO2U1sK5ukhoqGdsd3gAMWoO2ovlMwR(1kwCT6vRmhneJhAZpHbHRTBTa4HrEGa3i9o9LGKCColdmcEJVdWMSmtRvFfQFc7hfkP3PVKSKhqZu2JEf652jX5WbcCqusbLkusb1LkPvO84AjMQUsHEawWaZvOHde4OfgoNJptnU2ov7L6O2U1QbJG0G8gf5b4n6lzuO(jSFuOeyaGhkdYXNXD6WeIc9C7K4C4aboikPGsfkPGQZvsRq5X1smvDLc9aSGbMRqH4aZ1sCJ(bjdlxB3AdhiWrlmCohFMACTDuBNxB3A1GrqAqEJI8a8g9Lm12Tw)egeot)ObXXLnGDYXdF6RfBTezoLYHde4G0G44YgWo54Hp912TwImNs5WbcCqA42qZe2b12PA1RwDu7f1QxTy(AVJRn8eprlKyKi)izep4gpUwIP1QFT6Rq9ty)OqH8gnhpaWtOqp3ojohoqGdIskOuHskOWuL0kuECTetvxPqpalyG5ku6hnioUSbStoE4tFlSJU2iuB3A1R2Wt8enc7aBeYJj0h4oGB84AjMwB3AjYCkLdhiWbPHBdntyhuBh1cXbMRL4gUn0mHDq(ahpcsTIfxl9JgP3PVKSKhqZYUnTWo6AJqT6Rq9ty)OqXTHQXdLbQqjfu6qjTcLhxlXu1vk0dWcgyUcfapmYde4MSBJgGDDzqwM4j8gFhGnzzMwB3AH4aZ1sCJ(bjdlxB3AdhiWrlmCohFw(e5lfrTDuRE1E(prFjtJ070xswYdOzk7rFJcd8W(P2lQv4qRvFfQFc7hfkP3PVKSKhqZu2JEvOKckmVsAfkpUwIPQRuOhGfmWCfkWnAMHWt0CkL0SP2oQfkrOq9ty)Oqj9o9LKpaN0RcLuqPtusRq5X1smvDLc1pH9Jcf3gAMWoqHEUDsCoCGaheLuqPqTjyaawoYgIcnSJUKoWEPc1MGbay5iB44m18GvOqPqp9UnkuOuOhGfmWCfkrMtPC4aboinCBOzc7GA7OwioWCTe3WTHMjSdYh44rqQTBTAWiinQd0nh9pSqF0GLvHskOWekPvO84AjMQUsH6NW(rHIBdnJK8BkuBcgaGLJSHOqd7OlPdSx298FI(sMgK3OzTpfnyzfQnbdaWYr2WXzQ5bRqHsHE6DBuOqPqpalyG5kunyeKg1b6MJ(hwOpAWY12TwioWCTe3OFqYWYQqjfu6CkPvO84AjMQUsHEawWaZvOqCG5AjUr)GKHLRTBTa3Ozgcprd)HW48enBQTJApojYHHZ1ErTIOPJA7wRE1sK5ukhoqGdsd3gAMWoO2ovlMwB3AVU2Wt8enCJWGBnECTetRvS4AjYCkLdhiWbPHBdntyhuBNQfZxB3AdpXt0WncdU14X1smTw9vO(jSFuO42qZAjNeQqj1LIqjTcLhxlXu1vk0dWcgyUcfWiaM07AjU2U1goqGJwy4Co(m14A7OwmFTIfxRE1gEINOHBegCRXJRLyATDRL(rJ070xswYdOzz3MgGramP31sCT6xRyX1QbJG0GheyqYgHm1b6omH0GLvO(jSFuOqCCzdyNC8WNEf652jX5WbcCqusbLkusDjukPvO84AjMQUsHEawWaZvOagbWKExlX12T2WbcC0cdNZXNPgxBh1IP12T2RRn8eprd3im4wJhxlX0A7wB4jEIMm52P3o5Kn624X1smT2U1sK5ukhoqGdsd3gAMWoO2oQ9sfQFc7hfkP3PVKSKhqZYUnQqj1LxQKwHYJRLyQ6kf6bybdmxHcyeat6DTexB3AdhiWrlmCohFMACTDulMwB3AVU2Wt8enCJWGBnECTetRTBTxxRE1gEINOryhyJqEmH(a3bCJhxlX0A7wlrMtPC4aboinCBOzc7GA7OwioWCTe3WTHMjSdYh44rqQv)A7wRE1EDTHN4jAYKBNE7Kt2OBJhxlX0AflUw9Qn8eprtMC70BNCYgDB84AjMwB3AjYCkLdhiWbPHBdntyhuBNWw7L1QFT6Rq9ty)Oqj9o9LKL8aAw2TrHEUDsCoCGaheLuqPcLux25kPvO84AjMQUsH6NW(rHIBdntyhOqp3ojohoqGdIskOuO2emaalhzdrHg2rxshyVuHAtWaaSCKnCCMAEWkuOuONE3gfkuk0dWcgyUcLiZPuoCGahKgUn0mHDqTDulehyUwIB42qZe2b5dC8iiQqj1LyQsAfkpUwIPQRuO(jSFuO42qZij)Mc1MGbay5iBik0Wo6s6a7LDp)NOVKPb5nAw7trdwwHAtWaaSCKnCCMAEWkuOuONE3gfkuQqj1L6qjTc1pH9JcL070xswYdOzk7rVcLhxlXu1vQqj1LyEL0ku)e2pkusVtFjzjpGMLDBuO84AjMQUsfQqHEKCusRKckL0kuECTetvxPqHjCwsVL48XjHnckPGsH6NW(rHsyhyJqEmH(a3bSc9C7K4C4aboikPGsHEawWaZvO6vlehyUwIBe2b2iKhtOpWDaNpWXJGuB3AVUwioWCTe3K)pLrEq(qj1QFTIfxRE1s)Or6D6ljl5b0SSBtdWiaM07AjU2U1sK5ukhoqGdsd3gAMWoO2oQfQA1xfkPUujTcLhxlXu1vkuycNL0BjoFCsyJGskOuO(jSFuOe2b2iKhtOpWDaRqp3ojohoqGdIskOuOhGfmWCfA4jEIgHDGnc5Xe6dChWnECTetRTBT0pAKEN(sYsEanl720amcGj9UwIRTBTezoLYHde4G0WTHMjSdQTJAVufkP6CL0kuECTetvxPq)jDlFKCuOqPq9ty)OqXTHM1sojuHkuOhkrjTskOusRq5X1smvDLc9aSGbMRqbWdJ8abUry5EymPKSm4pjh3d7NgFhGnzzMwB3A1R2WbcC0ms2P0AflU2WbcC0OSgmcs74KWgHgG9tuR(ku)e2pkuIL45Wk0ZTtIZHde4GOKckvOK6sL0kuECTetvxPqhhNvOeBqGtzHKtnpEajR5ubo)izeg8hlUPq9ty)Oqj2GaNYcjNAE8aswZPcC(rYim4pwCtHEawWaZvOAWiiniVrrEaEdwUwXIRnmCU2oQfkruB3A1R2RR98q4XNOnMqFKrCUw9vHsQoxjTcLhxlXu1vk0dWcgyUc96A1GrqAqEJI8a8gSCTDRvVAVU2Z)j6lzAqEJMJha4jAWY1kwCTxxB4jEIgK3O54baEIgpUwIP1QFTIfxRgmcsdYBuKhG3GLRTBT6vl5HtA2qBcGhcNTbIj8apSFA84AjMwRyX1sE4KMn0gIXjA(rYAPNqECsJhxlX0A1xH6NW(rHI4Cwa2buZhIkusHPkPvO84AjMQUsHEawWaZvO2q8XIB12PA15erTDRvVA1RwioWCTe38ukt)GKHLRTBT6v711E(prFjtdYB0mdGLd7NgSCTIfx711gEINO1dpcmWgHmK3OnECTetRv)A1VwXIRvdgbPb5nkYdWBWY1QFTDRvVAVU2Wt8eTE4rGb2iKH8gTXJRLyATIfxlL1GrqA9WJadSrid5nAdwUwXIR96A1GrqAqEJI8a8gSCT6xB3A1R2RRn8eprJWoWgH8yc9bUd4gpUwIP1kwCTezoLYHde4G0WTHMjSdQTt1QJA1xH6NW(rHIBdvWXzIc9C7K4C4aboikPGsfkP0HsAfkpUwIPQRuOhGfmWCfQE1QxTxxlWnAMHWt0CkL0GLRTBTa3OzgcprZPusZMA7O2lfrT6xRyX1cCJMzi8enNsjnaJ72qQTdS1cLoQvS4AbUrZmeEIMtPKgfg4H9tTDQwO0rT6xB3A1RwnyeKM8lHbzBqGj2pny5AflU2Z)j6lzAYVegKTbbMy)0amUBdP2oWwluIOwXIR96ALbgtIgHtiz5xcdY2GatSFQvFfQFc7hfk80)PB55H4QqjfMxjTcLhxlXu1vk0dWcgyUc96A1GrqAqEJI8a8gSCTDR96Ap)NOVKPb5nAMbWYH9tdwU2U1sK5ukhoqGdsd3gAMWoO2oQfQA7w711gEINOryhyJqEmH(a3bCJhxlX0AflUw9QvdgbPb5nkYdWBWY12TwImNs5WbcCqA42qZe2b12PAVS2U1EDTHN4jAe2b2iKhtOpWDa34X1smT2U1kdyizHdTbvdYB0S2NIA1VwXIRvVA1GrqAqEJI8a8gSCTDRn8eprJWoWgH8yc9bUd4gpUwIP1QVc1pH9Jcv7)j)i5ONZo5WdLPQqjLorjTcLhxlXu1vku)e2pk0JNsz)e2p5KrcfAYirECCwHgaB0LdIkuHcna2OlheL0kPGsjTcLhxlXu1vk0XXzfkJlFdWEk)a64ZHvO(jSFuOmU8na7P8dOJphwHEawWaZvON)t0xY0G8gnZay5W(PbyC3gsTDcBTqDzTIfxRgmcsdYBuKhG3GLRvS4Ap)NOVKPb5nAMbWYH9tdW4UnKA7O2l1jQqj1LkPvO84AjMQUsHoooRqTHCaWHRL48Da2Nagptzi2HvO(jSFuO2qoa4W1sC(oa7taJNPme7Wk0dWcgyUcvdgbPb5nkYdWBWY1kwCTN)t0xY0G8gnZay5W(PbyC3gsTDuluIqfkP6CL0kuECTetvxPqhhNvO4(X1aCM0ZCKXHj2rH6NW(rHI7hxdWzspZrghMyhf6bybdmxHQbJG0G8gf5b4ny5AflU2Z)j6lzAqEJMzaSCy)0amUBdP2oQfkrOcLuyQsAfkpUwIPQRuOJJZkuYdNsCe2iKbWA3uONBNeNdhiWbrjfuku)e2pkuYdNsCe2iKbWA3uOhGfmWCfQgmcst(LWGSniWe7NgSCTIfx711kdmMencNqYYVegKTbbMy)OcLu6qjTcLhxlXu1vk0XXzfkXge4uwi5uZJhqYAovGZpsgHb)XIBku)e2pkuIniWPSqYPMhpGK1CQaNFKmcd(Jf3uOhGfmWCfQgmcsdYBuKhG3GLRvS4Ap)NOVKPb5nAMbWYH9tdW4UnKA7aBTqjcvOKcZRKwHYJRLyQ6kfQFc7hf6XtPSFc7NCYiHc9aSGbMRq1R2RRn8eprRhEeyGncziVrB84AjMwRyX1sznyeKwp8iWaBeYqEJ2GLRv)A7wRE1QbJG0G8gf5b4ny5AflU2Z)j6lzAqEJMzaSCy)0amUBdP2oQfkruR(k0KrI844ScLIlKdGn6YbrfkP0jkPvO84AjMQUsHEawWaZvOAWiiniVrrEaEdwUwXIRvdgbPj)syq2geyI9tdwUwXIR98FI(sMgK3Ozgalh2pnaJ72qQTJAHseku)e2pkuycNTGXjQqfkuT)hL0kPGsjTcLhxlXu1vk0dWcgyUcLiZPuoCGahKgUn0mHDqTDcBTDUc1pH9Jc1jhEOmnRLCsOcLuxQKwHYJRLyQ6kf6bybdmxHgoqGJMel6TbtuB3AjYCkLdhiWbP5KdpuMMNhIxBh1cvTDRLiZPuoCGahKgUn0mHDqTDulu1ErTHN4jAe2b2iKhtOpWDa34X1smvH6NW(rH6KdpuMMNhIRcvOqLb85X18qjTskOusRq5X1smvDLc9aSGbMRqbmUBdP2ovBNlcrOq9ty)OqLFjmil5b0mYdclGPSkusDPsAfkpUwIPQRuOhGfmWCf611QbJG0i9o9LG8a8gSSc1pH9JcL070xcYdWvHsQoxjTcLhxlXu1vk0dWcgyUc1gIpwCRrze7yrTDulu6qH6NW(rH6GJpCoEaGNqfkPWuL0kuECTetvxPqFzfkHdfQFc7hfkehyUwIvOq8emRqVuHcXb5XXzfkUn0mHDq(ahpcIkusPdL0ku)e2pkuioUSbStoE4tVcLhxlXu1vQqfQqHcHbe7hLuxkIlfbuxkIlBqPqL4GXgbIcvugx(bbtRftuRFc7NAtgjiTcdfkrMpkPUuhycfQm4rSeRqfDTO9o9LulMbmMefgIU27YhgxJb1QdOR9srCPikmkmeDT3zDw(ahmTwng5bCTNhxZJA1ybBiTAffNdlhKANFeL07aCe4uT(jSFi1(t6wRWWpH9dPjd4ZJR5XfyVx(LWGSKhqZipiSaMYqBiybmUBdPtDUierHHFc7hstgWNhxZJlWEpP3PVeKhGdTHG9AnyeKgP3PVeKhG3GLlm8ty)qAYa(84AECb27DWXhohpaWtaTHG1gIpwCRrze7yrhqPJcd)e2pKMmGppUMhxG9EioWCTed944mwCBOzc7G8boEeeOFzSeoGgINGzSxwy4NW(H0Kb85X184cS3dXXLnGDYXdF6lmkmeDTy2h2pKcd)e2peSelXZHlm8ty)qWk)H9d0gcwnyeKgK3OipaVbllwSgmcst(LWGSniWe7NgSCHHFc7hYfyVhIdmxlXqpooJL(bjdld9lJLWb0q8emJL(rJ070xswYdOzz3MwyhDTrOl9Jgehx2a2jhp8PVf2rxBekm8ty)qUa79qCG5Ajg6XXzSEkLPFqYWYq)YyjCanepbZyPF0i9o9LKL8aAw2TPf2rxBe6s)ObXXLnGDYXdF6BHD01gHU0pAugYddSrilNCbyUf2rxBekmeDTOHdIAHj2iulk7aBeQvktOpWDaxRh125xuB4aboi1(GAX0lQ1qQ92dxRd4ATPwr9nkYdWlm8ty)qUa79qCG5Ajg6XXzSe2b2iKhtOpWDaNpWXJGa9lJLWb0q8emJLiZPuoCGahKgUn0mHDqhxEHgmcsdYBuKhG3GLlmeDTD2)j6lzQfZ(pvRO6aZ1sm01kseMwB81k)FQwng5bCT(jmiEyJqTqEJI8a8wTDgmaWtKUvlmHP1gFTNFcWNQvspp1gFT(jmiEW1c5nkYdWRvIf91AZ5XTrOwNsjTcd)e2pKlWEpehyUwIHECCgR8)PmYdYhkb6xglHdOH4jyg75)e9LmniVrZmawoSFAWYD17AGB0mdHNO5ukPbllwmWnAMHWt0CkL0OWapSF6ewOeHyXa3OzgcprZPusdW4UnKoWcLiUqh3X6fEINO1dpcmWgHmK3OnECTetfl(8q4XNOP7nG5J(63vp9aUrZmeEIMtPKMnDCPielMiZPuoCGahKgK3Ozgalh2pDGvh6lwC4jEIwp8iWaBeYqEJ24X1smvS4ZdHhFIMU3aMp6xy4NW(HCb27rmaRL(NcTHGvdgbPb5nkYdWBWYfg(jSFixG9EngqyGU2iaTHGvdgbPb5nkYdWBWYfgIUwrIW1QZBc9XDIulgWubCEIAnKAJEgW16aU2lR9b1I)aU2WbcCqGU2huRtPKADap3POwISlzSrOwKhul(d4AJEFQvNOdsRWWpH9d5cS3NmH(GKXKatfW5jG2qWsK5ukhoqGdslzc9bjJjbMkGZt0b2lflwVRbUrZmeEIMtPKgRZAKGiwmWnAMHWt0CkL0SPdDIo0VWWpH9d5cS37ZHjbWt5JNsqBiy1GrqAqEJI8a8gSCHHFc7hYfyV)4Pu2pH9tozKa6XXzShjNcd)e2pKlWEpaEY(jSFYjJeqpooJf3TPWOWq01kkWmD(AJVwycxRKEEQ9Q)NAFKAJEUwrb5WdLP1AKA9tyq4cd)e2pKM2)dwNC4HY0SwYjb0gcwImNs5WbcCqA42qZe2bDcBNxy4NW(H00(FUa79o5WdLP55H4qBiydhiWrtIf92Gj6sK5ukhoqGdsZjhEOmnppeVdO6sK5ukhoqGdsd3gAMWoOdOUi8eprJWoWgH8yc9bUd4gpUwIPfgfgIU2o7UKcdrxRir4ArTephU2FQTZUBTXxRm4p1IYY9WysVtKAXmWFsoUh2pTcd)e2pK2HsUa79elXZHH(C7K4C4aboiyHcAdblaEyKhiWncl3dJjLKLb)j54Ey)047aSjlZ0U6foqGJMrYoLkwC4aboAuwdgbPDCsyJqdW(j0VWq01kseU2RCQaxRneJY1(i1kQ60ArEqTrpxlIbirTWeU2hu7p12z3TwhjyqTrpxlIbirTWeUvlMZI(ALYe6JA1PoxB)NO1I8GAfvDARWWpH9dPDOKlWEpmHZwW4qpooJLydcCklKCQ5XdiznNkW5hjJWG)yXnOneSAWiiniVrrEaEdwwS4WW5oGseD176ZdHhFI2yc9rgXz9lmeDTIeHRvN6CTIsHDa18Hu7p12z3T2hoigLR9rQvuFJI8a8wTIeHRvN6CTIsHDa18HsQ1MAf13OipaVwdP2BpCT9oeUw2IEguROuWdHRvuEGycpWd7NAFqT6uJt0AFKAVk9eYJtAfg(jSFiTdLCb27rCola7aQ5dbAdb71AWiiniVrrEaEdwURExF(prFjtdYB0C8aaprdwwS4RdpXt0G8gnhpaWt04X1smvFXI1GrqAqEJI8a8gSCx9ipCsZgAta8q4SnqmHh4H9tJhxlXuXIjpCsZgAdX4en)izT0tipoPXJRLyQ(fgIUwrIW1kYTHk44mPwj98uRNs1251E3xAsToGRfwg6AFqT3E4ADaxRn1kQVrrEaER278qGbCT6mWJadSrOwr9nATgPw)egeU2FQn65AdhiWrTgsTHN4jyARw04LRfMyJqTEuRoUO2WbcCqQvIf91IYoWgHALYe6dChWTcd)e2pK2HsUa7942qfCCMa952jX5WbcCqWcf0gcwBi(yXToPZjIU6PhehyUwIBEkLPFqYWYD176Z)j6lzAqEJMzaSCy)0GLfl(6Wt8eTE4rGb2iKH8gTXJRLyQ(6lwSgmcsdYBuKhG3GL1VRExhEINO1dpcmWgHmK3OnECTetflMYAWiiTE4rGb2iKH8gTbllw81AWiiniVrrEaEdww)U6DD4jEIgHDGnc5Xe6dChWnECTetflMiZPuoCGahKgUn0mHDqN0H(fgIUwrIW1kst)NUvRupeV2FQTZUl012)jQnc1QbmgjDR24RvIBrTipOw5xcdQ1geyI9tTpOwNsRLi7sgsRWWpH9dPDOKlWEp80)PB55H4qBiy1tVRbUrZmeEIMtPKgSCxGB0mdHNO5ukPzthxkc9flg4gnZq4jAoLsAag3TH0bwO0HyXa3OzgcprZPusJcd8W(PtqPd97QNgmcst(LWGSniWe7NgSSyXN)t0xY0KFjmiBdcmX(PbyC3gshyHseIfFTmWys0iCcjl)syq2geyI9J(fgIUwrIW1(tTD2DRvdoQvgypWcJW1ctSrOwr9nAT3zaSCy)ulIbib01Ai1ctyAT2qmkx7JuROQtR9NArLUwycxRJemOwVwiVr1(uulYdQ98FI(sMAzee7y8CUvRp0ArEqT9WJadSrOwiVrRfwomCUwdP2Wt8emTvy4NW(H0ouYfyVx7)j)i5ONZo5WdLPqBiyVwdgbPb5nkYdWBWYDV(8FI(sMgK3Ozgalh2pny5UezoLYHde4G0WTHMjSd6aQUxhEINOryhyJqEmH(a3bCJhxlXuXI1tdgbPb5nkYdWBWYDjYCkLdhiWbPHBdntyh0Pl7ED4jEIgHDGnc5Xe6dChWnECTet7kdyizHdTbvdYB0S2Nc9flwpnyeKgK3OipaVbl3n8eprJWoWgH8yc9bUd4gpUwIP6xy4NW(H0ouYfyV)4Pu2pH9tozKa6XXzSbWgD5Guyuyi6A7mNe1I56TexBN5KWgHA9ty)qA1IYrTEuBVj0ZGALb2dS4wTXxlP)brThdCGTOwBcgaGLJAp)qTW(Hu7p1kYTHwlk7G71Pj)wHHORvKiCTOSdSrOwPmH(a3bCTgsT3E4ALyPuT9wulppSqFTHde4GuRp0AXSxcdQvuEqGj2p16dTwr9nkYdWR1bCTZh1cyNEd6AFqTXxlGramPVwumNidZQ9NAdjFTpOw8hW1goqGdsRWWpH9dPDKCWsyhyJqEmH(a3bm0WeolP3sC(4KWgbSqb952jX5WbcCqWcf0gcw9G4aZ1sCJWoWgH8yc9bUd48boEeKUxdXbMRL4M8)PmYdYhkrFXI1J(rJ070xswYdOzz3MgGramP31sCxImNs5WbcCqA42qZe2bDaL(fgIUw0(he12zg4aBrTOSdSrOwPmH(a3bCTNFOwy)uB81QlZY1II5ezywTWY1AtTII)oxy4NW(H0osoxG9Ec7aBeYJj0h4oGHgMWzj9wIZhNe2iGfkOp3ojohoqGdcwOG2qWgEINOryhyJqEmH(a3bCJhxlX0U0pAKEN(sYsEanl720amcGj9UwI7sK5ukhoqGdsd3gAMWoOJllmeDT)KULpso1I76YKAJEUw)e2p1(t6wTWexlX1sHb2iu7P3NHt2iuRp0ANpQ1j161cyb4KdQ1pH9tRWWpH9dPDKCUa7942qZAjNeq)t6w(i5GfQcJcd)e2pKgfxihaB0LdcwycNTGXHECCgl1b6I))KP8r3Cwgoam5WZHlm8ty)qAuCHCaSrxoixG9EycNTGXHECCglbE0s)tZooh93irHHFc7hsJIlKdGn6Yb5cS3dt4Sfmo0JJZyfs3K7Zps2jed3sEy)uy4NW(H0O4c5ayJUCqUa79WeoBbJd944mwkGDkIb4meMq4uHrHHORvK72uROaZ05HUws)dNO1EEimOwpLQf4JatQ9rQnCGahKA9Hwl5WJdSNuy4NW(H0WDBUa79hpLY(jSFYjJeqpooJv7)bAsaStGfkOneSAWiinT)N8JKJEo7KdpuM2GLlm8ty)qA4UnxG9EQrK5ug3fStHHORvKiCTI6B0AVZay5W(P2FQ98FI(sMAL)pzJqTEuBIDsulMkIATH4Jf3QvdoQD(OwdP2BpCTsSuQ2hcdoUCT2q8XIB1AtTIQoTvRi31LRLad4Aj9o9LGy8qVh3gQgpuguRrQ9NAp)NOVKPwng5bCTI6DUvy4NW(H0WDBWc5nAMbWYH9d0gcwioWCTe3K)pLrEq(qjDTH4Jf36alMkIU6zdXhlU1jSycDiwC4jEIgHDGnc5Xe6dChWnECTet7cXbMRL4gHDGnc5Xe6dChW5dC8ii6396Z)j6lzAigp0gSCHHORvK76Y1sGbCT3E4ALHJAHLRffZjYWSAffOIcmR2FQn65AdhiWrTgsTyoGh9iWPA1PodmUwJm3POw)egeUvy4NW(H0WDBUa79KEN(sYsEanl72aTHGvdgbPH4Cwa2buZhsdwU71uwdgbPjb4rpcCkJ4mW4gSCHHFc7hsd3T5cS3F8uk7NW(jNmsa944m2dLuyi6A1zmH(AXmG9alUvRi3gATOSdQ1pH9tTXxlGramPV27(stQvIf91syhyJqEmH(a3bCHHFc7hsd3T5cS3JBdntyha952jX5WbcCqWcf0gc2Wt8enc7aBeYJj0h4oGB84AjM2LiZPuoCGahKgUn0mHDqhqCG5AjUHBdntyhKpWXJG09A6hnsVtFjzjpGMLDBAHD01gHUxF(prFjtdX4H2GLlmeDTygGryqTXxlmHR9Uo(4H9tTIcurbMvRHuRp3Q9UV01AKANpQfwUvy4NW(H0WDBUa79uhF8W(b6ZTtIZHde4GGfkOneSxdXbMRL4MNsz6hKmSCHHORvKiCTI6B0AV6trTEuBVj0ZGALb2dS4wTsSOVwDg4rGb2iuRO(gTwy5AJVwmT2WbcCqGU2hu7h9mO2Wt8eKA)PwuPBfg(jSFinC3MlWEpK3OzTpfqBiyTH4Jf36ewmHo6gEINO1dpcmWgHmK3OnECTet7gEINOryhyJqEmH(a3bCJhxlX0UezoLYHde4G0WTHMjSd6ewmVyX6Px4jEIwp8iWaBeYqEJ24X1smT71HN4jAe2b2iKhtOpWDa34X1smvFXIjYCkLdhiWbPHBdntyhGfk9lmeDT39N7uulmHR9UmKhgyJqTywYfG5AnKAV9W1E8PwboQ1M4RvuFJI8a8ATHeStHU2huRHulk7aBeQvktOpWDaxRrQn8epbtR1hATsSuQ2ElQLNhwOV2WbcCqAfg(jSFinC3MlWEpLH8WaBeYYjxaMH(C7K4C4aboiyHcAdbREagbWKExlXIfBdXhlU1Horh63vVRH4aZ1sCt()ug5b5dLiwSneFS4whyXe6q)U6DD4jEIgHDGnc5Xe6dChWnECTetflwVWt8enc7aBeYJj0h4oGB84AjM29AioWCTe3iSdSripMqFG7aoFGJhbrF9lmeDTIeHRvuVQ2FQTZUBTgsT3E4AP)CNIAhMP1gFThNe1ExgYddSrOwml5cWm016dT2ONbCToGRnXesTrVp1IP1goqGdsTpCuRE6Owjw0x75hkSf63km8ty)qA4UnxG9EiVrZAFkG2qWsK5ukhoqGdsd3gAMWoOt6HPxC(HcBrJAeYp(ez(0)mPXJRLyQ(DTH4Jf36ewmHo6gEINOryhyJqEmH(a3bCJhxlXuXIVo8eprJWoWgH8yc9bUd4gpUwIPfgIUwrIW1I270xsTyUhqfz1Ex2J(AnKAJEU2WbcCuRrQ11E4O24RLACTpO2BpCT9oeUw0EN(sqsooxlMbmcET8Da2KLzATsSOVwrUnunEOmO2hulAVtFjigp0A9tyq4wHHFc7hsd3T5cS3t6D6ljl5b0mL9Oh6ZTtIZHde4GGfkOneS6foqGJwp7POVjFIoDPi6sK5ukhoqGdsd3gAMWoOtyQ(IfRNmhneJhAZpHbH7cGhg5bcCJ070xcsYX5SmWi4n(oaBYYmv)cdrxRir4ArHbaEOmO24RvK70HjKA)PwV2WbcCuB07rTgPwH3gHAJVwQX16rTrpxlWe6JAddNBfg(jSFinC3MlWEpbga4HYGC8zCNomHa952jX5WbcCqWcf0gc2WbcC0cdNZXNPg3Pl1rxnyeKgK3OipaVrFjtHHORvKiCTI6B0AL(baEIA)jDRwdPwumNidZQ1hATIQ016aUw)egeUwFO1g9CTHde4Owj)CNIAPgxlfgyJqTrpx7P3NHtTcd)e2pKgUBZfyVhYB0C8aapb0NBNeNdhiWbbluqBiyH4aZ1sCJ(bjdl3nCGahTWW5C8zQXD05D1GrqAqEJI8a8g9LmD9tyq4m9Jgehx2a2jhp8PhlrMtPC4aboinioUSbStoE4tFxImNs5WbcCqA42qZe2bDspDCHEy(74Wt8eTqIrI8JKr8GB84AjMQV(fg(jSFinC3MlWEpUnunEOmaAdbl9Jgehx2a2jhp8PVf2rxBe6Qx4jEIgHDGnc5Xe6dChWnECTet7sK5ukhoqGdsd3gAMWoOdioWCTe3WTHMjSdYh44rqelM(rJ070xswYdOzz3MwyhDTrq)cdrxRir4ArXCIS7wRel6RfZCB0aSRldQfZiEcVw4jXesTrpxB4aboQvILs1QX1QXPxsTxkI7iRvJrEaxB0Z1E(prFjtTNhNj1Q5hDlm8ty)qA4UnxG9EsVtFjzjpGMPSh9qBiybWdJ8abUj72ObyxxgKLjEcVX3bytwMPDH4aZ1sCJ(bjdl3nCGahTWW5C8z5tKVueDO35)e9LmnsVtFjzjpGMPSh9nkmWd7Nleou9lmeDTIeHRfT3PVKA7mGt6R9NA7S7wl8KycP2ONbCToGR1PusT2CECBeAfg(jSFinC3MlWEpP3PVK8b4KEOneSa3OzgcprZPusZMoGsefgIUwrIW1kYTHwlk7GAJV2ZpeyCU276aDRv6(hwOpi1kd(dP2FQvuGjFNB1knM8DXKRTZ(bXa41AKAJEJuRrQ1RT3e6zqTYa7bwCR2O3NAbm9JWgHA)PwrbM8DUw4jXesTuhOBTr)dl0hKAnsTU2dh1gFTHHZ1(WrHHFc7hsd3T5cS3JBdntyha952jX5WbcCqWcf0gcwImNs5WbcCqA42qZe2bDaXbMRL4gUn0mHDq(ahpcsxnyeKg1b6MJ(hwOpAWYqF6DBWcf02emaalhzdhNPMhmwOG2MGbay5iBiyd7OlPdSxwyi6AfjcxRi3gAT60KFR24R98dbgNR9Uoq3ALU)Hf6dsTYG)qQ9NArLUvR0yY3ftU2o7hedGxRHuB0BKAnsTET9MqpdQvgypWIB1g9(ulGPFe2iul8KycPwQd0T2O)Hf6dsTgPwx7HJAJV2WW5AF4OWWpH9dPH72Cb27XTHMrs(nOneSAWiinQd0nh9pSqF0GL7cXbMRL4g9dsgwg6tVBdwOG2MGbay5iB44m18GXcf02emaalhzdbByhDjDG9YUN)t0xY0G8gnR9POblxyi6AfjcxRi3gATxLCsuRHu7ThUw6p3PO2HzATXxlGramPV27(stA1IgVCThNe2iuRh1IP1(GAXFaxB4aboi1kXI(ArzhyJqTszc9bUd4AdpXtW0wHHFc7hsd3T5cS3JBdnRLCsaTHGfIdmxlXn6hKmSCxGB0mdHNOH)qyCEIMnDCCsKddNVqenD0vpImNs5WbcCqA42qZe2bDct7ED4jEIgUryWTgpUwIPIftK5ukhoqGdsd3gAMWoOty(UHN4jA4gHb3A84AjMQFHHFc7hsd3T5cS3dXXLnGDYXdF6H(C7K4C4aboiyHcAdblGramP31sC3WbcC0cdNZXNPg3bMxSy9cpXt0WncdU14X1smTl9JgP3PVKSKhqZYUnnaJaysVRLy9flwdgbPbpiWGKnczQd0DycPblxyi6ArL5J5PAp)qTW(P24RLeVCThNe2iulkMtKHz1(tTpcIOKWbcCqQvspp1Iyc9Hnc1251(GAXFaxlj8JUmTw8xJuRp0AHj2iulMrUD6TtT682OBT(qRvkmzPRvKBegCRvy4NW(H0WDBUa79KEN(sYsEanl72aTHGfWiaM07AjUB4aboAHHZ54ZuJ7at7ED4jEIgUryWTgpUwIPDdpXt0Kj3o92jNSr3gpUwIPDjYCkLdhiWbPHBdntyh0XLfgIU27OzwUwumNidZQfwU2FQ1j1I7ZTAdhiWbPwNuR8tiMwIHUwwN9WYrTs65PwetOpSrO2oV2hul(d4AjHF0LP1I)AKALyrFTyg52P3o1QZBJUTcd)e2pKgUBZfyVN070xswYdOzz3gOp3ojohoqGdcwOG2qWcyeat6DTe3nCGahTWW5C8zQXDGPDVo8eprd3im4wJhxlX0UxRx4jEIgHDGnc5Xe6dChWnECTet7sK5ukhoqGdsd3gAMWoOdioWCTe3WTHMjSdYh44rq0VRExhEINOjtUD6TtozJUnECTetflwVWt8enzYTtVDYjB0TXJRLyAxImNs5WbcCqA42qZe2bDc7L6RFHHFc7hsd3T5cS3JBdntyha952jX5WbcCqWcf0gcwImNs5WbcCqA42qZe2bDaXbMRL4gUn0mHDq(ahpcc0NE3gSqbTnbdaWYr2WXzQ5bJfkOTjyaawoYgc2Wo6s6a7Lfg(jSFinC3MlWEpUn0msYVb9P3TbluqBtWaaSCKnCCMAEWyHcABcgaGLJSHGnSJUKoWEz3Z)j6lzAqEJM1(u0GLlmeDTIeHRffZjYUBToP2KtIAbm5brTgsT)uB0Z1I)q4cd)e2pKgUBZfyVN070xswYdOzk7rFHHORvKiCTOyorgMvRtQn5KOwatEquRHu7p1g9CT4peUwFO1II5ez3TwJu7p12z3TWWpH9dPH72Cb27j9o9LKL8aAw2TPWOWq01kseU2FQTZUBTIcurbMvB81kWrT39LU2Wo6AJqT(qRL1zLnaxB81MSHRfwUwnocguRel6RvuFJI8a8cd)e2pKwaSrxoiyHjC2cgh6XXzSmU8na7P8dOJphgAdb75)e9LmniVrZmawoSFAag3TH0jSqDPyXAWiiniVrrEaEdwwS4Z)j6lzAqEJMzaSCy)0amUBdPJl1jfgIUw0BZPwr57OUBTsSOVwr9nkYdWlm8ty)qAbWgD5GCb27HjC2cgh6XXzS2qoa4W1sC(oa7taJNPme7WqBiy1GrqAqEJI8a8gSSyXN)t0xY0G8gnZay5W(PbyC3gshqjIcdrxl6T5ulApZrTICyIDQvIf91kQVrrEaEHHFc7hsla2OlhKlWEpmHZwW4qpooJf3pUgGZKEMJmomXoqBiy1GrqAqEJI8a8gSSyXN)t0xY0G8gnZay5W(PbyC3gshqjIcdrxl6T5u7DeWA3QvIf91IzVeguRO8GatSFQfM4cm01I76Y1sGbCTXxlzmzU2ONRn9sysuRodMvB4abokm8ty)qAbWgD5GCb27HjC2cgh6XXzSKhoL4iSridG1UbTHGvdgbPj)syq2geyI9tdwwS4RLbgtIgHtiz5xcdY2GatSFG(C7K4C4aboiyHQWq01kseU2RCQaxRneJY1(i1kQ60ArEqTrpxlIbirTWeU2hu7p12z3TwhjyqTrpxlIbirTWeUvlA)dIApg4aBrTgsTqEJwldGLd7NAp)NOVKPwJuluIGu7dQf)bCTUe)wRWWpH9dPfaB0LdYfyVhMWzlyCOhhNXsSbboLfso184bKSMtf48JKryWFS4g0gcwnyeKgK3OipaVbllw85)e9LmniVrZmawoSFAag3TH0bwOerHHORvKiCTjJe1(i1(JOeycxl1XDbU2ayJUCqQ9N0TAnKA1zGhbgyJqTI6B0AVlRbJGuRrQ1pHbHHU2hu7ThUwhW1oFuB4jEcMwRnXxRfTcd)e2pKwaSrxoixG9(JNsz)e2p5KrcOhhNXsXfYbWgD5GaTHGvVRdpXt06HhbgyJqgYB0gpUwIPIftznyeKwp8iWaBeYqEJ2GL1VREAWiiniVrrEaEdwwS4Z)j6lzAqEJMzaSCy)0amUBdPdOeH(fgIU27YioCkQfXtjn)OBTipOwyIRL4ATGXjISAfjcx7p1E(prFjtT2u7dOmOwTB1gaB0LJAjPpAfg(jSFiTayJUCqUa79WeoBbJtG2qWQbJG0G8gf5b4nyzXI1GrqAYVegKTbbMy)0GLfl(8FI(sMgK3Ozgalh2pnaJ72q6akrOcvOua]] )


end
