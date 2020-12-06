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


    spec:RegisterPack( "Shadow", 20201205.1, [[dafUEbqivsEeHuxsLkcTjPsFsLkQrjv0PKkSkvQi9kvcZcK6weIQSlj9lvQAyqrDmqYYuj1ZisPPriPRrKQTrikFJifnoOi5CuQIADesyEuQQ7bL2hLkhKqIwOkrpKsvAIQuPlQsfAJuQcFKquvJKif6KeIkRek8svQiQzsPkYnjeYojs(juKQHcfXrvPIGLQsfrEkKMkLIRsiyReI8vcHAVu8xPmyLoSWIPKhRIjJ0LrTzi(mbJwQ60KwnuKIxtP0SL42q1Uv8BvnCI64Qublh45iMovxhuBheFNigprk48QuwpuKsZNqTFrBGYyJbLgoBK6AmFnMH6Aml9kus71slusRb1VjZgu54yBiWg0jWzdkAFqFjgu54w5dQXgdk5Hbh2G27UmruC)9cQ3dBvpp(9efhUeU(Zbei(9ef)CVb1cwlUi3ySmO0WzJuxJ5RXmuxJzPxHsAV(AOKUbnG9(hyqrvC71G2RukpgldkLjhdQOZfTpOVKCXeGYepXq05Ex(W4wmixPdDUxJ5RXSbTOeNySXGIh6ySXifugBmO8ewfMAU0GEaQZanmOwWiivR)N2J08EUfKdpuMwHLnOehOh3ifug0446pg0tukT446pTIsCdArjEBcC2GA9)yCJuxBSXGghx)XGsvImxA4HGEmO8ewfMAU04gPKwJnguEcRctnxAqpa1zGgguibqdRcxL)V0qEq7qj52nxDiXO(TCTdBUIkMZTBUDMRoKyu)wU2hBUykPNRyX56rHhVs4aOJqBuHEhpaCLNWQW0C7MlKaOHvHReoa6i0gvO3Xda3oW(JGKBh52n3RY98FH(sMkIYdTclBqJJR)yqH8kTXayzx)X4gPevJnguEcRctnxAqpa1zGggulyeKksWnb4aq1yivy5C7M7v5szlyeKQeq49iWLgsWaLRWYg0446pgusFqFjnjpG2KdDmUrkPBSXGYtyvyQ5sdACC9hd6jkLwCC9NwrjUbTOeVnboBqpuIXnsjYm2yq5jSkm1CPbnoU(JbfxhAJWbWGEaQZanmOEu4XReoa6i0gvO3Xdax5jSkmn3U5sK5sP5bqGDsfxhAJWbix7Yfsa0WQWvCDOnchG2b2FeKC7M7v5sFVs6d6lPj5b0MCOt11JT6iKB3CVk3Z)f6lzQikp0kSSb9C7u4Mhab2jgPGY4gPKMgBmO8ewfMAU0Gghx)XGsd8jC9hd6bOod0WGEvUqcGgwfUgLsJ(oPblBqp3ofU5bqGDIrkOmUrkmLXgdkpHvHPMlnOhG6mqddQoKyu)wU2hBUykPNB3C9OWJx7HhbgOJqdYR0kpHvHP52nxpk84vchaDeAJk074bGR8ewfMMB3CjYCP08aiWoPIRdTr4aKR9XMRilxXIZTZC7mxpk841E4rGb6i0G8kTYtyvyAUDZ9QC9OWJxjCa0rOnQqVJhaUYtyvyAUDKRyX5sK5sP5bqGDsfxhAJWbixS5cvUDyqJJR)yqH8kTz9f34gPSNn2yq5jSkm1CPbnoU(JbLYqEyGocn5siaZg0dqDgOHbTZCbmcGj9HvHZvS4C1HeJ63Y1UCLMsp3oYTBUDM7v5cjaAyv4Q8)LgYdAhkjxXIZvhsmQFlx7WMlMs652rUDZTZCVkxpk84vchaDeAJk074bGR8ewfMMRyX52zUEu4XReoa6i0gvO3Xdax5jSkmn3U5EvUqcGgwfUs4aOJqBuHEhpaC7a7pcsUDKBhg0ZTtHBEaeyNyKckJBKckmBSXGYtyvyQ5sd6bOod0WGsK5sP5bqGDsfxhAJWbix7NBN5kQ5ErUNFOWQxPkH8tmEJp9ptQ8ewfMMBh52nxDiXO(TCTp2CXusp3U56rHhVs4aOJqBuHEhpaCLNWQW0Cflo3RY1JcpELWbqhH2Oc9oEa4kpHvHPg0446pguiVsBwFXnUrkOGYyJbLNWQWuZLg0446pgusFqFjnjpG2OC49g0dqDgOHbTZC9aiWETNJI3xLpEU2p3RXCUDZLiZLsZdGa7KkUo0gHdqU2pxrn3oYvS4C7mxz2Rikp0ACCfcNB3CbWdJ8abUs6d6lbPe4CtgOe8kFhGvzzMMBhg0ZTtHBEaeyNyKckJBKcQRn2yq5jSkm1CPbnoU(JbLada8qzqZ)gEqhMqmOhG6mqddQhab2RUIZn)BuLZ1(5ET0ZTBUwWiiviVsrEaEL(sgd652PWnpacStmsbLXnsbL0ASXGYtyvyQ5sdACC9hdkKxPn)baECd6bOod0WGcjaAyv4k9Dsdwo3U56bqG9QR4CZ)gv5CTlxPn3U5AbJGuH8kf5b4v6lzYTBUXXviCJ(EfsGlRa908h(0Nl2CjYCP08aiWoPcjWLvGEA(dF6ZTBUezUuAEaeyNuX1H2iCaY1(52zUsp3lYTZCfz5ENMRhfE8QlrjE7rAiHZvEcRctZTJC7WGEUDkCZdGa7eJuqzCJuqjQgBmO8ewfMAU0GEaQZanmO03RqcCzfONM)WN(QRhB1ri3U52zUEu4XReoa6i0gvO3Xdax5jSkmn3U5sK5sP5bqGDsfxhAJWbix7Yfsa0WQWvCDOnchG2b2FeKCflox67vsFqFjnjpG2KdDQUESvhHC7WGghx)XGIRd1IhkdmUrkOKUXgdkpHvHPMlnOhG6mqddkaEyKhiWv5qhlah2YGMmjk4v(oaRYYmn3U5cjaAyv4k9Dsdwo3U56bqG9QR4CZ)M8XBxJ5CTl3oZ98FH(sMkPpOVKMKhqBuo8(kfgeU(tUxKRWHMBhg0446pgusFqFjnjpG2OC49g3ifuImJnguEcRctnxAqpa1zGgguqO0gdHhVgukPQtU2Lluy2Gghx)XGs6d6lPDabP34gPGsAASXGYtyvyQ5sdACC9hdkUo0gHdGb9C7u4Mhab2jgPGYGQJZaaSS3uedQRhBj2H9AdQoodaWYEtXXzQgoBqHYGEaQZanmOezUuAEaeyNuX1H2iCaY1UCHeanSkCfxhAJWbODG9hbj3U5AbJGuPbW2M3)Wc9Efw2GE6dDmOqzCJuqHPm2yq5jSkm1CPbnoU(JbfxhAdPe3mO64maal7nfXG66XwIDyVU75)c9LmviVsBwFXRWYguDCgaGL9MIJZunC2GcLb9auNbAyqTGrqQ0ayBZ7FyHEVclNB3CHeanSkCL(oPblBqp9HoguOmUrkOSNn2yq5jSkm1CPb9auNbAyqHeanSkCL(oPblNB3CbHsBmeE8k(dHX5XR6KRD5EcI3CfNZ9ICXCv652n3oZLiZLsZdGa7KkUo0gHdqU2pxrn3U5EvUEu4XR4kHb3Q8ewfMMRyX5sK5sP5bqGDsfxhAJWbix7NRil3U56rHhVIRegCRYtyvyAUDyqJJR)yqX1H2SkbXnUrQRXSXgdkpHvHPMlnOXX1FmOqcCzfONM)WNEd6bOod0WGcyeat6dRcNB3C9aiWE1vCU5FJQCU2LRilxXIZTZC9OWJxXvcdUv5jSkmn3U5sFVs6d6lPj5b0MCOtfWiaM0hwfo3oYvS4CTGrqQWdcmOOJqJgaBhMqQWYg0ZTtHBEaeyNyKckJBK6AOm2yq5jSkm1CPb9auNbAyqbmcGj9HvHZTBUEaeyV6ko38Vrvox7YvuZTBUxLRhfE8kUsyWTkpHvHP52nxpk84vzYTtVEAfDSTYtyvyAUDZLiZLsZdGa7KkUo0gHdqU2L71g0446pgusFqFjnjpG2KdDmUrQRV2yJbLNWQWuZLg0446pgusFqFjnjpG2KdDmOhG6mqddkGramPpSkCUDZ1dGa7vxX5M)nQY5AxUIAUDZ9QC9OWJxXvcdUv5jSkmn3U5EvUDMRhfE8kHdGocTrf6D8aWvEcRctZTBUezUuAEaeyNuX1H2iCaY1UCHeanSkCfxhAJWbODG9hbj3oYTBUDM7v56rHhVktUD61tROJTvEcRctZvS4C7mxpk84vzYTtVEAfDSTYtyvyAUDZLiZLsZdGa7KkUo0gHdqU2hBUxNBh52Hb9C7u4Mhab2jgPGY4gPUwAn2yq5jSkm1CPbnoU(JbfxhAJWbWGEUDkCZdGa7eJuqzq1Xzaaw2BkIb11JTe7WETbvhNbayzVP44mvdNnOqzqpa1zGgguImxknpacStQ46qBeoa5AxUqcGgwfUIRdTr4a0oW(JGyqp9HoguOmUrQRfvJnguEcRctnxAqJJR)yqX1H2qkXndQoodaWYEtrmOUESLyh2R7E(VqFjtfYR0M1x8kSSbvhNbayzVP44mvdNnOqzqp9HoguOmUrQRLUXgdACC9hdkPpOVKMKhqBuo8EdkpHvHPMlnUrQRfzgBmOXX1FmOK(G(sAsEaTjh6yq5jSkm1CPXnUbLIl0CGo2YoXyJrkOm2yq5jSkm1CPbDcC2GsdGT4)pnkFST1KHDato8CydACC9hdkna2I))0O8X2wtg2bm5WZHnUrQRn2yq5jSkm1CPbDcC2GsGhRY)0wGZE)nIBqJJR)yqjWJv5FAlWzV)gXnUrkP1yJbLNWQWuZLg0jWzdQq5MCF7rAbHO4AjC9hdACC9hdQq5MCF7rAbHO4AjC9hJBKsun2yq5jSkm1CPbDcC2GsbCqrua3GWecxmOXX1FmOuahuefWnimHWfJBCdkLrc4IBSXifugBmOXX1FmOeTWZHnO8ewfMAU04gPU2yJbLNWQWuZLg0dqDgOHb1cgbPc5vkYdWRWY5kwCUwWiiv5xcdA6Gat0FQWYg0446pgu531FmUrkP1yJbLNWQWuZLg0x2Gsy3Gghx)XGcjaAyvydkKOaZgu67vsFqFjnjpG2KdDQUESvhHC7Ml99kKaxwb6P5p8PV66XwDemOqcqBcC2GsFN0GLnUrkr1yJbLNWQWuZLg0x2Gsy3Gghx)XGcjaAyvydkKOaZgu67vsFqFjnjpG2KdDQUESvhHC7Ml99kKaxwb6P5p8PV66XwDeYTBU03RugYdd0rOjxcbyU66XwDemOqcqBcC2GgLsJ(oPblBCJus3yJbLNWQWuZLg0x2Gsy3Gghx)XGcjaAyvydkKOaZguImxknpacStQ46qBeoa5AxUxN7f5AbJGuH8kf5b4vyzdkKa0MaNnOeoa6i0gvO3Xda3oW(JGyCJuImJnguEcRctnxAqFzdkHDdACC9hdkKaOHvHnOqIcmBqp)xOVKPc5vAJbWYU(tfwo3U52zUxLliuAJHWJxdkLuHLZvS4CbHsBmeE8AqPKkfgeU(tU2hBUqH5CfloxqO0gdHhVgukPcy8qhsU2HnxOWCUxKR0Z9on3oZ1JcpEThEeyGocniVsR8ewfMMRyX5EEi8eJxT9gqJj3oYTJC7MBN52zUGqPngcpEnOusvNCTl3RXCUIfNlrMlLMhab2jviVsBmaw21FY1oS5k9C7ixXIZ1JcpEThEeyGocniVsR8ewfMMRyX5EEi8eJxT9gqJj3omOqcqBcC2Gk)FPH8G2HsmUrkPPXgdkpHvHPMlnOhG6mqddQfmcsfYRuKhGxHLnOXX1FmOikGTk)tnUrkmLXgdkpHvHPMlnOhG6mqddQfmcsfYRuKhGxHLnOXX1FmOwmGWaB1rW4gPSNn2yq5jSkm1CPb9auNbAyqjYCP08aiWoPwuHEN0W0atfW5XZ1oS5EDUIfNBN5EvUGqPngcpEnOusLLguItYvS4CbHsBmeE8AqPKQo5AxUstPNBhg0446pg0Ik07KgMgyQaopUXnsbfMn2yq5jSkm1CPb9auNbAyqTGrqQqELI8a8kSSbnoU(JbnMdtCquANOumUrkOGYyJbLNWQWuZLg0446pg0tukT446pTIsCdArjEBcC2GEKCmUrkOU2yJbLNWQWuZLg0446pgua80IJR)0kkXnOfL4TjWzdkEOJXnUbvgWNh3kCJngPGYyJbLNWQWuZLg0dqDgOHbfW4HoKCTFUslMXSbnoU(Jbv(LWGMKhqBipWvhMYg3i11gBmO8ewfMAU0GEaQZanmOxLRfmcsL0h0xcYdWRWYg0446pgusFqFjipa34gPKwJnguEcRctnxAqpa1zGgguDiXO(TkLr0J65AxUqjDdACC9hdAaoXWn)baECJBKsun2yq5jSkm1CPb9LnOe2nOXX1FmOqcGgwf2GcjkWSb9AdkKa0MaNnO46qBeoaTdS)iig3iL0n2yqJJR)yqHe4Ykqpn)Hp9guEcRctnxACJBqpuIXgJuqzSXGYtyvyQ5sd6bOod0WGAbJGuH8kf5b4vy5Cflo3RYL8WflDO1ZJBfEdNPQhU(tLNWQW0C7M75)c9LmviVsBmaw21FQagp0HKRDyZfkmNRyX5IOc9EdW4HoKCTFUN)l0xYuH8kTXayzx)Pcy8qhIbnoU(Jbv(LWGMoiWe9hJBK6AJnguEcRctnxAqJJR)yqjAHNdBqpa1zGggua8WipqGRewUhgtlPjd(tjWdx)PY3byvwMP52n3oZ1dGa7vL0cknxXIZ1dGa7vkBbJGupbX1rOc44452Hb9C7u4Mhab2jgPGY4gPKwJnguEcRctnxAqJJR)yqj6GaxAcLGQH)asZkOcC7rAim4pQFZGEaQZanmOwWiiviVsrEaEfwoxXIZ1vCox7YfkmNB3C7m3RY98q4jgVoQqV3qco3omOtGZguIoiWLMqjOA4pG0ScQa3EKgcd(J63mUrkr1yJbLNWQWuZLg0dqDgOHb9QCTGrqQqELI8a8kSCUDZTZCVk3Z)f6lzQqEL28ha4XRWY5kwCUxLRhfE8kKxPn)baE8kpHvHP52rUIfNRfmcsfYRuKhGxHLZTBUDMl5Hlw6qRcGhc30bIk8GW1FQ8ewfMMRyX5sE4ILo0kIYfA7rAwLNqECsLNWQW0C7WGghx)XGIeCtaoaungIXnsjDJnguEcRctnxAqJJR)yqX1Hke4mXGEaQZanmO6qIr9B5A)CTNXCUDZTZC7mxibqdRcxJsPrFN0GLZTBUDM7v5E(VqFjtfYR0gdGLD9NkSCUIfN7v56rHhV2dpcmqhHgKxPvEcRctZTJC7ixXIZ1cgbPc5vkYdWRWY52rUDZTZCVkxpk841E4rGb6i0G8kTYtyvyAUIfNlLTGrqQ9WJad0rOb5vAfwoxXIZ9QCTGrqQqELI8a8kSCUDKB3C7m3RY1JcpELWbqhH2Oc9oEa4kpHvHP5kwCUezUuAEaeyNuX1H2iCaY1(5k9C7WGEUDkCZdGa7eJuqzCJuImJnguEcRctnxAqpa1zGgg0oZTZCVkxqO0gdHhVgukPclNB3CbHsBmeE8AqPKQo5AxUxJ5C7ixXIZfekTXq4XRbLsQagp0HKRDyZfkPNRyX5ccL2yi841GsjvkmiC9NCTFUqj9C7i3U52zUwWiiv5xcdA6Gat0FQWY5kwCUN)l0xYuLFjmOPdcmr)Pcy8qhsU2HnxOWCUIfN7v5kduM4vcxqAYVeg00bbMO)KBhg0446pgu4P)l3AZdjmUrkPPXgdkpHvHPMlnOhG6mqdd6v5AbJGuH8kf5b4vy5C7M7v5E(VqFjtfYR0gdGLD9NkSCUDZLiZLsZdGa7KkUo0gHdqU2Llu52n3RY1JcpELWbqhH2Oc9oEa4kpHvHP5kwCUDMRfmcsfYRuKhGxHLZTBUezUuAEaeyNuX1H2iCaY1(5EDUDZ9QC9OWJxjCa0rOnQqVJhaUYtyvyAUDZvgWqAchAfQkKxPnRV452rUIfNBN5AbJGuH8kf5b4vy5C7MRhfE8kHdGocTrf6D8aWvEcRctZTddACC9hdQ1)t7rAEp3cYHhktnUrkmLXgdkpHvHPMlnOXX1FmONOuAXX1FAfL4g0Is82e4Sb1b6yl7eJBCdQd0Xw2jgBmsbLXgdkpHvHPMlnOXX1FmOmU8nahL2dOtmh2GEaQZanmON)l0xYuH8kTXayzx)Pcy8qhsU2hBUqDDUIfNRfmcsfYRuKhGxHLZvS4Cp)xOVKPc5vAJbWYU(tfW4HoKCTl3RLMg0jWzdkJlFdWrP9a6eZHnUrQRn2yq5jSkm1CPbnoU(JbvhYba7HvHB3b4yCy8gLHOh2GEaQZanmOwWiiviVsrEaEfwoxXIZ98FH(sMkKxPngal76pvaJh6qY1UCHcZg0jWzdQoKda2dRc3UdWX4W4nkdrpSXnsjTgBmO8ewfMAU0Gghx)XGIhNWcWnspZEdhMOhd6bOod0WGAbJGuH8kf5b4vy5Cflo3Z)f6lzQqEL2yaSSR)ubmEOdjx7YfkmBqNaNnO4XjSaCJ0ZS3WHj6X4gPevJnguEcRctnxAqNaNnOKhUuy31rObGTUzqp3ofU5bqGDIrkOmOhG6mqddQfmcsv(LWGMoiWe9NkSCUIfN7v5kduM4vcxqAYVeg00bbMO)yqJJR)yqjpCPWURJqdaBDZ4gPKUXgdkpHvHPMlnOXX1FmOeDqGlnHsq1WFaPzfubU9ineg8h1Vzqpa1zGggulyeKkKxPipaVclNRyX5E(VqFjtfYR0gdGLD9NkGXdDi5Ah2CHcZg0jWzdkrhe4stOeun8hqAwbvGBpsdHb)r9Bg3iLiZyJbLNWQWuZLg0dqDgOHbTZCVkxpk841E4rGb6i0G8kTYtyvyAUIfNlLTGrqQ9WJad0rOb5vAfwo3oYTBUDMRfmcsfYRuKhGxHLZvS4Cp)xOVKPc5vAJbWYU(tfW4HoKCTlxOWCUDyqJJR)yqprP0IJR)0kkXnOfL4TjWzdkfxO5aDSLDIXnsjnn2yq5jSkm1CPb9auNbAyqTGrqQqELI8a8kSCUIfNRfmcsv(LWGMoiWe9NkSCUIfN75)c9LmviVsBmaw21FQagp0HKRD5cfMnOXX1FmOWeUPoJtmUXnOw)pgBmsbLXgdkpHvHPMlnOhG6mqddkrMlLMhab2jvCDOnchGCTp2CLwdACC9hdAqo8qzAZQee34gPU2yJbLNWQWuZLg0dqDgOHb1dGa7vjQ3RdMk3U5sK5sP5bqGDsnihEOmTnpKix7YfQC7MlrMlLMhab2jvCDOnchGCTlxOY9IC9OWJxjCa0rOnQqVJhaUYtyvyQbnoU(JbnihEOmTnpKW4g3GEKCm2yKckJnguEcRctnxAqHjCtsVw42jiUocgPGYGghx)XGs4aOJqBuHEhpaSb9C7u4Mhab2jgPGYGEaQZanmODMlKaOHvHReoa6i0gvO3Xda3oW(JGKB3CVkxibqdRcxL)V0qEq7qj52rUIfNBN5sFVs6d6lPj5b0MCOtfWiaM0hwfo3U5sK5sP5bqGDsfxhAJWbix7YfQC7W4gPU2yJbLNWQWuZLguyc3K0RfUDcIRJGrkOmOXX1FmOeoa6i0gvO3XdaBqp3ofU5bqGDIrkOmOhG6mqddQhfE8kHdGocTrf6D8aWvEcRctZTBU03RK(G(sAsEaTjh6ubmcGj9HvHZTBUezUuAEaeyNuX1H2iCaY1UCV24gPKwJnguEcRctnxAq)PCRDKCmOqzqJJR)yqX1H2SkbXnUXnUbfcdi6pgPUgZxJzOUgZs3GkjaJocedQihU8dCMMlMk3446p5wuItQjgguImFmsDT0XuguzWJOf2Gk6Cr7d6ljxmbOmXtmeDU3LpmUfdYv6qN71y(AmNyKyi6CVJsd8b2zAUwmYd4CppUv45AXc6qQ5kkphw2j5o)iYRpa4iWLCJJR)qY9NYTAIrCC9hsvgWNh3k8lWEV8lHbnjpG2qEGRomLHwrWcy8qhI9LwmJ5eJ446pKQmGppUv4xG9EsFqFjipahAfb7vwWiivsFqFjipaVclNyehx)HuLb85XTc)cS3hGtmCZFaGhhAfbRoKyu)wLYi6rD7Gs6jgXX1FivzaFECRWVa79qcGgwfg6jWzS46qBeoaTdS)iiq)YyjSdnKOaZyVoXioU(dPkd4ZJBf(fyVhsGlRa908h(0NyKyi6CXK31FijgXX1FiyjAHNdNyehx)HGv(D9hOveSwWiiviVsrEaEfwwSylyeKQ8lHbnDqGj6pvy5eJ446pKlWEpKaOHvHHEcCgl9Dsdwg6xglHDOHefygl99kPpOVKMKhqBYHovxp2QJqx67vibUSc0tZF4tF11JT6iKyehx)HCb27HeanSkm0tGZyJsPrFN0GLH(LXsyhAirbMXsFVs6d6lPj5b0MCOt11JT6i0L(EfsGlRa908h(0xD9yRocDPVxPmKhgOJqtUecWC11JT6iKyi6Cr9a45ct0rixuoa6iKRuQqVJhao3WZvAVixpacStY9b5kQxKRIK7Tho3aW5QtUI0RuKhGNyehx)HCb27HeanSkm0tGZyjCa0rOnQqVJhaUDG9hbb6xglHDOHefyglrMlLMhab2jvCDOncha7U(clyeKkKxPipaVclNyi6CT3)l0xYKlM8FjxrkaAyvyOZveimnx)Zv()sUwmYd4CJJRqcxhHCH8kf5b41CTxyaGhVClxyctZ1)Cp)4GVKRKEEY1)CJJRqcNZfYRuKhGNRe17ZvNZJRJqUbLsQjgXX1FixG9EibqdRcd9e4mw5)lnKh0ouc0Vmwc7qdjkWm2Z)f6lzQqEL2yaSSR)uHL725vGqPngcpEnOusfwwSyqO0gdHhVgukPsHbHR)yFSqHzXIbHsBmeE8AqPKkGXdDi2HfkmFH0Vt70JcpEThEeyGocniVsR8ewfMkw85HWtmE12BanMo6OBNDccL2yi841GsjvDS7AmlwmrMlLMhab2jviVsBmaw21FSdR07qSypk841E4rGb6i0G8kTYtyvyQyXNhcpX4vBVb0y6iXioU(d5cS3JOa2Q8pfAfbRfmcsfYRuKhGxHLtmIJR)qUa79wmGWaB1raAfbRfmcsfYRuKhGxHLtmeDUIaHZ1Esf697mjxmGPc4845Qi569mGZnaCUxN7dYf)bCUEaeyNaDUpi3Gsj5gaEUZEUe5qYOJqUipix8hW569XKR0u6KAIrCC9hYfyVVOc9oPHPbMkGZJdTIGLiZLsZdGa7KArf6DsdtdmvaNh3oSxlwCNxbcL2yi841GsjvwAqjorSyqO0gdHhVgukPQJDstP3rIrCC9hYfyVpMdtCquANOuGwrWAbJGuH8kf5b4vy5eJ446pKlWE)jkLwCC9Nwrjo0tGZypsojgXX1FixG9Ea80IJR)0kkXHEcCglEOtIrIHOZvuIj2t56FUWeoxj98K7L)p5(i569CUIsYHhktZvj5ghxHWjgXX1FivR)hSb5WdLPnRsqCOveSezUuAEaeyNuX1H2iCaSpwPnXioU(dPA9)Cb27dYHhktBZdjGwrW6bqG9Qe171bt1LiZLsZdGa7KAqo8qzABEiHDq1LiZLsZdGa7KkUo0gHdGDqDHhfE8kHdGocTrf6D8aWvEcRcttmsmeDU27DjjgIoxrGW5IjVegKRi3Gat0FYvI695ksVsrEaEnxPXVqZf5b5ksVsrEaEUNhNj5(ii5E(VqFjtU6KR3Z5oS0GNluyoxcF(HsY99EgirjCUWeo3FY9qZfEkmHKR3Z5IjCjeEsU2ac1Z1EFCRWZveXu1dx)jxLKRhfECMcDUpixfjxVNbCUs0sj359CT4CJ59EgKRi9kn37iaw21FY17vsUiQqVxtmIJR)qQhkbR8lHbnDqGj6pqRiyTGrqQqELI8a8kSSyXxrE4ILo065XTcVHZu1dx)PYtyvyA3Z)f6lzQqEL2yaSSR)ubmEOdXoSqHzXIruHEVby8qhI9p)xOVKPc5vAJbWYU(tfW4HoKedrNRiq4Cr1cpho3FY1EVBU(NRm4p5IYY9WyAVZKCXeWFkbE46p1eJ446pK6HsUa79eTWZHH(C7u4Mhab2jyHcAfblaEyKhiWvcl3dJPL0Kb)Pe4HR)u57aSklZ0UD6bqG9QsAbLkwShab2Ru2cgbPEcIRJqfWXX7iXq05kceo3ldQaNRoeLY5(i5ks2JCrEqUEpNlIciEUWeo3hK7p5AV3n3aXzqUEpNlIciEUWeUMRiw9(CLsf69CThbNB)xO5I8GCfj7rnXioU(dPEOKlWEpmHBQZ4qpboJLOdcCPjucQg(dinRGkWThPHWG)O(nOveSwWiiviVsrEaEfwwSyxXz7GcZD78QZdHNy86Oc9Edj4osmeDUIaHZ1EeCUI8HdavJHK7p5AV3n3h2jkLZ9rYvKELI8a8AUIaHZ1EeCUI8HdavJHsYvNCfPxPipapxfj3BpCU9beoxw9EgKRiFWdHZvKBGOcpiC9NCFqU2dLl0CFKCVS8eYJtQjgXX1Fi1dLCb27rcUjahaQgdbAfb7vwWiiviVsrEaEfwUBNxD(VqFjtfYR0M)aapEfwwS4R8OWJxH8kT5paWJx5jSkmTdXITGrqQqELI8a8kSC3ojpCXshAva8q4MoquHheU(tLNWQWuXIjpCXshAfr5cT9inRYtipoPYtyvyAhjgIoxrGW5kI0Hke4mjxj98KBuk5kT5E33gsUbGZfwg6CFqU3E4CdaNRo5ksVsrEaEn374qGbCUsJWJad0rixr6vAUkj344keo3FY175C9aiWEUksUEu4XzAnxu)LZfMOJqUHNR0VixpacStYvI695IYbqhHCLsf6D8aW1eJ446pK6HsUa7946qfcCMa952PWnpacStWcf0kcwDiXO(n7BpJ5UD2jKaOHvHRrP0OVtAWYD78QZ)f6lzQqEL2yaSSR)uHLfl(kpk841E4rGb6i0G8kTYtyvyAhDiwSfmcsfYRuKhGxHL7OBNx5rHhV2dpcmqhHgKxPvEcRctflMYwWii1E4rGb6i0G8kTcllw8vwWiiviVsrEaEfwUJUDELhfE8kHdGocTrf6D8aWvEcRctflMiZLsZdGa7KkUo0gHdG9LEhjgIoxrGW5kct)xULRupKi3FY1EVl052)fQoc5AbugPClx)ZvsOEUipix5xcdYvheyI(tUpi3GsZLihsgsnXioU(dPEOKlWEp80)LBT5HeqRiy7SZRaHsBmeE8AqPKkSCxqO0gdHhVgukPQJDxJ5oelgekTXq4XRbLsQagp0HyhwOKUyXGqPngcpEnOusLcdcx)X(qj9o62Pfmcsv(LWGMoiWe9NkSSyXN)l0xYuLFjmOPdcmr)Pcy8qhIDyHcZIfFLmqzIxjCbPj)syqtheyI(thjgIoxrGW5(tU27DZ1c2ZvgOpqDLW5ct0rixr6vAU3raSSR)KlIcio05Qi5ctyAU6qukN7JKRizpY9NCrTjxycNBG4mi3ixiVsT(INlYdY98FH(sMCzee9O8CULBm0CrEqU9WJad0rixiVsZfw2vCoxfjxpk84mTMyehx)HupuYfyV36)P9inVNBb5WdLPqRiyVYcgbPc5vkYdWRWYDV68FH(sMkKxPngal76pvy5UezUuAEaeyNuX1H2iCaSdQUx5rHhVs4aOJqBuHEhpaCLNWQWuXI70cgbPc5vkYdWRWYDjYCP08aiWoPIRdTr4ay)R7ELhfE8kHdGocTrf6D8aWvEcRct7kdyinHdTcvfYR0M1x8oelUtlyeKkKxPipaVcl31JcpELWbqhH2Oc9oEa4kpHvHPDKyehx)HupuYfyV)eLsloU(tROeh6jWzSoqhBzNKyKyi6CT3G45kI71cNR9gexhHCJJR)qQ5IYEUHNBVk0ZGCLb6du)wU(NlP)bEUhfCGvpxDCgaGL9Cp)qvx)HK7p5kI0HMlkhG7ThL4wIHOZveiCUOCa0rixPuHEhpaCUksU3E4CLOLsU9QNlppSqFUEaeyNKBm0CXKxcdYvKBqGj6p5gdnxr6vkYdWZnaCUZ75c4GEd6CFqU(NlGramPpxurSOatY9NCDjFUpix8hW56bqGDsnXioU(dPEKCWs4aOJqBuHEhpam0WeUjPxlC7eexhbSqb952PWnpacStWcf0kc2oHeanSkCLWbqhH2Oc9oEa42b2FeKUxbjaAyv4Q8)LgYdAhkPdXI7K(EL0h0xstYdOn5qNkGramPpSkCxImxknpacStQ46qBeoa2bvhjgIox0(h45AVk4aREUOCa0rixPuHEhpaCUNFOQR)KR)5AlZY5IkIffysUWY5QtUIY)oMyehx)HupsoxG9EchaDeAJk074bGHgMWnj9AHBNG46iGfkOp3ofU5bqGDcwOGwrW6rHhVs4aOJqBuHEhpaCLNWQW0U03RK(G(sAsEaTjh6ubmcGj9HvH7sK5sP5bqGDsfxhAJWbWURtmeDU)uU1oso5Ih2YKC9Eo3446p5(t5wUWKWQW5sHb6iK7PpMHl6iKBm0CN3Zni5g5cyb4saYnoU(tnXioU(dPEKCUa7946qBwLG4q)t5w7i5GfQeJeJ446pKkfxO5aDSLDcwyc3uNXHEcCglna2I))0O8X2wtg2bm5WZHtmIJR)qQuCHMd0Xw2jxG9Eyc3uNXHEcCglbESk)tBbo793iEIrCC9hsLIl0CGo2Yo5cS3dt4M6mo0tGZyfk3K7BpsliefxlHR)Kyehx)HuP4cnhOJTStUa79WeUPoJd9e4mwkGdkIc4geMq4sIrIHOZvef6KROetSNGoxs)dxO5EEimi3OuYfeJatY9rY1dGa7KCJHMl5Wta0NKyehx)HuXdDUa79NOuAXX1FAfL4qpboJ16)bAId0JJfkOveSwWiivR)N2J08EUfKdpuMwHLtmIJR)qQ4HoxG9EQsK5sdpe0tIHOZveiCUI0R0CVJayzx)j3FY98FH(sMCL)VOJqUHNBHdINROI5C1HeJ63Y1c2ZDEpxfj3BpCUs0sj3hcdoHCU6qIr9B5QtUIK9OMRikSLZLad4Cj9b9LGO8qVhxhQfpugKRsY9NCp)xOVKjxlg5bCUI0DSMyehx)HuXdDWc5vAJbWYU(d0kcwibqdRcxL)V0qEq7qjD1HeJ63SdROI5UDQdjg1VzFSykPlwShfE8kHdGocTrf6D8aWvEcRct7cjaAyv4kHdGocTrf6D8aWTdS)iiD09QZ)f6lzQikp0kSCIHOZvef2Y5sGbCU3E4CLH9CHLZfvelkWKCfLOIsmj3FY175C9aiWEUksUIyq49iWLCThbduoxLm3zp344keUMyehx)HuXdDUa79K(G(sAsEaTjh6aTIG1cgbPIeCtaoaungsfwU7vu2cgbPkbeEpcCPHemq5kSCIrCC9hsfp05cS3FIsPfhx)PvuId9e4m2dLKyi6CLgvH(CXeG(a1VLRishAUOCaYnoU(tU(NlGramPp37(2qYvI695s4aOJqBuHEhpaCIrCC9hsfp05cS3JRdTr4aa952PWnpacStWcf0kcwpk84vchaDeAJk074bGR8ewfM2LiZLsZdGa7KkUo0gHdGDqcGgwfUIRdTr4a0oW(JG09k67vsFqFjnjpG2KdDQUESvhHUxD(VqFjtfr5HwHLtmeDUycGryqU(NlmHZ9Ub(eU(tUIsurjMKRIKBm3Y9UVn5QKCN3ZfwUMyehx)HuXdDUa790aFcx)b6ZTtHBEaeyNGfkOveSxbjaAyv4Aukn67KgSCIHOZveiCUI0R0CV8lEUHNBVk0ZGCLb6du)wUsuVpxPr4rGb6iKRi9knxy5C9pxrnxpacStGo3hK779mixpk84KC)jxuBQjgXX1Fiv8qNlWEpKxPnRV4qRiy1HeJ63SpwmL076rHhV2dpcmqhHgKxPvEcRct76rHhVs4aOJqBuHEhpaCLNWQW0UezUuAEaeyNuX1H2iCaSpwrMyXD2PhfE8Ap8iWaDeAqELw5jSkmT7vEu4XReoa6i0gvO3Xdax5jSkmTdXIjYCP08aiWoPIRdTr4aGfQosmeDU39N7SNlmHZ9UmKhgOJqUysjeG5CvKCV9W5EIjxb2Zvh)ZvKELI8a8C1H4CqHo3hKRIKlkhaDeYvkvO3XdaNRsY1JcpotZngAUs0sj3E1ZLNhwOpxpacStQjgXX1Fiv8qNlWEpLH8WaDeAYLqaMH(C7u4Mhab2jyHcAfbBNagbWK(WQWIfRdjg1VzN0u6D0TZRGeanSkCv()sd5bTdLiwSoKyu)MDyXusVJUDELhfE8kHdGocTrf6D8aWvEcRctflUtpk84vchaDeAJk074bGR8ewfM29kibqdRcxjCa0rOnQqVJhaUDG9hbPJosmeDUIaHZvKUm3FY1EVBUksU3E4CP)CN9ChMP56FUNG45ExgYdd0rixmPecWm05gdnxVNbCUbGZTWesUEFm5kQ56bqGDsUpSNBNspxjQ3N75hkS6DutmIJR)qQ4HoxG9EiVsBwFXHwrWsK5sP5bqGDsfxhAJWbW(DkQxC(HcRELQeYpX4n(0)mPYtyvyAhD1HeJ63SpwmL076rHhVs4aOJqBuHEhpaCLNWQWuXIVYJcpELWbqhH2Oc9oEa4kpHvHPjgIoxrGW5I2h0xsUI4hqff5Exo8(CvKC9EoxpacSNRsYnSEypx)ZLQCUpi3BpCU9beox0(G(sqkboNlMaucEU8DawLLzAUsuVpxrKoulEOmi3hKlAFqFjikp0CJJRq4AIrCC9hsfp05cS3t6d6lPj5b0gLdVh6ZTtHBEaeyNGfkOveSD6bqG9AphfVVkFC7FnM7sK5sP5bqGDsfxhAJWbW(IAhIf3Pm7veLhAnoUcH7cGhg5bcCL0h0xcsjW5Mmqj4v(oaRYYmTJedrNRiq4CrHbaEOmix)Zvef0HjKC)j3ixpacSNR3hEUkjxHxhHC9pxQY5gEUEpNlqf69CDfNRjgXX1Fiv8qNlWEpbga4HYGM)n8GomHa952PWnpacStWcf0kcwpacSxDfNB(3OkB)RLExlyeKkKxPipaVsFjtIHOZveiCUI0R0CT5baE8C)PClxfjxurSOatYngAUIKn5gao344keo3yO569CUEaeypxj)CN9CPkNlfgOJqUEpN7PpMHl1eJ446pKkEOZfyVhYR0M)aapo0NBNc38aiWobluqRiyHeanSkCL(oPbl31dGa7vxX5M)nQY2jTDTGrqQqELI8a8k9LmDJJRq4g99kKaxwb6P5p8PhlrMlLMhab2jvibUSc0tZF4tFxImxknpacStQ46qBeoa2VtPFrNIS7upk84vxIs82J0qcNR8ewfM2rhjgXX1Fiv8qNlWEpUoulEOmaAfbl99kKaxwb6P5p8PV66XwDe62PhfE8kHdGocTrf6D8aWvEcRct7sK5sP5bqGDsfxhAJWbWoibqdRcxX1H2iCaAhy)rqelM(EL0h0xstYdOn5qNQRhB1rOJedrNRiq4CrfXII7MRe17ZftcDSaCyldYftirbpx4PWesUEpNRhab2ZvIwk5AX5AXLxsUxJ57eZ1IrEaNR3Z5E(VqFjtUNhNj5AfhBtmIJR)qQ4HoxG9EsFqFjnjpG2OC49qRiybWdJ8abUkh6yb4Wwg0KjrbVY3byvwMPDHeanSkCL(oPbl31dGa7vxX5M)n5J3UgZ2155)c9LmvsFqFjnjpG2OC49vkmiC9Nleo0osmeDUIaHZfTpOVKCTxqq6Z9NCT37Ml8uycjxVNbCUbGZnOusU6CECDeQjgXX1Fiv8qNlWEpPpOVK2beKEOveSGqPngcpEnOusvh7GcZjgIoxrGW5kI0HMlkhGC9p3ZpeyCo37gaBZ1M(hwO3j5kd(dj3FYvuIPFhR5AdM(DX0Z1E)brb45QKC9ELKRsYnYTxf6zqUYa9bQFlxVpMCbm9DxhHC)jxrjM(Dmx4PWesU0ayBUE)dl07KCvsUH1d756FUUIZ5(WEIrCC9hsfp05cS3JRdTr4aa952PWnpacStWcf0kcwImxknpacStQ46qBeoa2bjaAyv4kUo0gHdq7a7pcsxlyeKkna228(hwO3RWYqF6dDWcf064maal7nfhNPA4mwOGwhNbayzVPiyD9ylXoSxNyi6CfbcNRishAU2JsClx)Z98dbgNZ9UbW2CTP)Hf6DsUYG)qY9NCrTPMRny63ftpx79hefGNRIKR3RKCvsUrU9QqpdYvgOpq9B569XKlGPV76iKl8uycjxAaSnxV)Hf6DsUkj3W6H9C9pxxX5CFypXioU(dPIh6Cb27X1H2qkXnOveSwWiivAaST59pSqVxHL7cjaAyv4k9Dsdwg6tFOdwOGwhNbayzVP44mvdNXcf064maal7nfbRRhBj2H96UN)l0xYuH8kTz9fVclNyi6CfbcNRishAUxwcINRIK7Thox6p3zp3HzAU(NlGramPp37(2qQ5I6VCUNG46iKB45kQ5(GCXFaNRhab2j5kr9(Cr5aOJqUsPc9oEa4C9OWJZ0AIrCC9hsfp05cS3JRdTzvcIdTIGfsa0WQWv67KgSCxqO0gdHhVI)qyCE8Qo2DcI3CfNVaZvP3TtImxknpacStQ46qBeoa2xu7ELhfE8kUsyWTkpHvHPIftK5sP5bqGDsfxhAJWbW(ISUEu4XR4kHb3Q8ewfM2rIrCC9hsfp05cS3djWLvGEA(dF6H(C7u4Mhab2jyHcAfblGramPpSkCxpacSxDfNB(3OkBNitS4o9OWJxXvcdUv5jSkmTl99kPpOVKMKhqBYHovaJaysFyv4oel2cgbPcpiWGIocnAaSDycPclNyi6CrL5JgLCp)qvx)jx)ZL4VCUNG46iKlQiwuGj5(tUpcIippacStYvspp5IOc9Uoc5kT5(GCXFaNlXJJTmnx83IKBm0CHj6iKlMqUD61tU2t6yBUXqZvkmDBYvePegCRMyehx)HuXdDUa79K(G(sAsEaTjh6aTIGfWiaM0hwfURhab2RUIZn)BuLTtu7ELhfE8kUsyWTkpHvHPD9OWJxLj3o96Pv0X2kpHvHPDjYCP08aiWoPIRdTr4ay31jgIo37KzwoxurSOatYfwo3FYni5IhZTC9aiWoj3GKR8tiQvHHoxwA4WYEUs65jxevO31rixPn3hKl(d4CjECSLP5I)wKCLOEFUyc52Pxp5ApPJT1eJ446pKkEOZfyVN0h0xstYdOn5qhOp3ofU5bqGDcwOGwrWcyeat6dRc31dGa7vxX5M)nQY2jQDVYJcpEfxjm4wLNWQW0Ux1PhfE8kHdGocTrf6D8aWvEcRct7sK5sP5bqGDsfxhAJWbWoibqdRcxX1H2iCaAhy)rq6OBNx5rHhVktUD61tROJTvEcRctflUtpk84vzYTtVEAfDSTYtyvyAxImxknpacStQ46qBeoa2h71D0rIrCC9hsfp05cS3JRdTr4aa952PWnpacStWcf0kcwImxknpacStQ46qBeoa2bjaAyv4kUo0gHdq7a7pcc0N(qhSqbToodaWYEtXXzQgoJfkO1Xzaaw2Bkcwxp2sSd71jgXX1Fiv8qNlWEpUo0gsjUb9Pp0bluqRJZaaSS3uCCMQHZyHcADCgaGL9MIG11JTe7WED3Z)f6lzQqEL2S(IxHLtmeDUIaHZfvelkUBUbj3sq8Cbm5bEUksU)KR3Z5I)q4eJ446pKkEOZfyVN0h0xstYdOnkhEFIHOZveiCUOIyrbMKBqYTeepxatEGNRIK7p569CU4peo3yO5IkIff3nxLK7p5AV3nXioU(dPIh6Cb27j9b9L0K8aAto0jXiXq05kceo3FY1EVBUIsurjMKR)5kWEU39Tjxxp2QJqUXqZLLgKvaNR)5w0HZfwoxl2DgKRe17ZvKELI8a8eJ446pKQd0Xw2jyHjCtDgh6jWzSmU8nahL2dOtmhgAfb75)c9LmviVsBmaw21FQagp0HyFSqDTyXwWiiviVsrEaEfwwS4Z)f6lzQqEL2yaSSR)ubmEOdXURLMjgIox0BZjxrU7eUBUsuVpxr6vkYdWtmIJR)qQoqhBzNCb27HjCtDgh6jWzS6qoaypSkC7oahJdJ3Ome9WqRiyTGrqQqELI8a8kSSyXN)l0xYuH8kTXayzx)Pcy8qhIDqH5edrNl6T5KlApZEUIiyIEYvI695ksVsrEaEIrCC9hs1b6yl7KlWEpmHBQZ4qpboJfpoHfGBKEM9gomrpqRiyTGrqQqELI8a8kSSyXN)l0xYuH8kTXayzx)Pcy8qhIDqH5edrNl6T5K7DsWw3YvI695IjVegKRi3Gat0FYfMecm05Ih2Y5sGbCU(NlzuzoxVNZT8syINR0iMKRhab2tmIJR)qQoqhBzNCb27HjCtDgh6jWzSKhUuy31rObGTUbTIG1cgbPk)syqtheyI(tfwwS4RKbkt8kHlin5xcdA6Gat0FG(C7u4Mhab2jyHkXq05kceo3ldQaNRoeLY5(i5ks2JCrEqUEpNlIciEUWeo3hK7p5AV3n3aXzqUEpNlIciEUWeUMlA)d8Cpk4aREUksUqELMldGLD9NCp)xOVKjxLKluyMK7dYf)bCUHK4wnXioU(dP6aDSLDYfyVhMWn1zCONaNXs0bbU0ekbvd)bKMvqf42J0qyWFu)g0kcwlyeKkKxPipaVcllw85)c9LmviVsBmaw21FQagp0HyhwOWCIHOZveiCUfL45(i5(JipycNlnWdboxhOJTStY9NYTCvKCLgHhbgOJqUI0R0CVlBbJGKRsYnoUcHHo3hK7Tho3aW5oVNRhfECMMRo(NR61eJ446pKQd0Xw2jxG9(tukT446pTIsCONaNXsXfAoqhBzNaTIGTZR8OWJx7HhbgOJqdYR0kpHvHPIftzlyeKAp8iWaDeAqELwHL7OBNwWiiviVsrEaEfwwS4Z)f6lzQqEL2yaSSR)ubmEOdXoOWChjgIo37YibCXZfjkfR4yBUipixysyv4CvNXjIICfbcN7p5E(VqFjtU6K7dOmixRB56aDSL9CjL3RjgXX1FivhOJTStUa79WeUPoJtGwrWAbJGuH8kf5b4vyzXITGrqQYVeg00bbMO)uHLfl(8FH(sMkKxPngal76pvaJh6qSdkmBCJBma]] )


end
