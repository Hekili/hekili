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


    spec:RegisterPack( "Shadow", 20201210, [[dafsFbqivcpIqQlbfc0MKQ6tqHOrjvXPOu1QGcP8kvIMfu0TOua2Lu(LkLgguWXajltLupJsrMgHKUMuLABeI03OuqJtLcDoOqY6iKW8KQK7bL2hLkhKqIwOkjpKsrnrvk6IQuqBKsH8rkfqJKsHYjjeHvcs9sOqqMjLcv3KquTtIWpjerdfkuhfkeulfkeWtH0ujIUkHqBLqWxjeL9sXFL0Gv6WclMsESkMmsxg1MH4ZemAPYPjTAOqOxtP0SL42q1Uv8BvnCI64QuGLd8CetNQRdQTdIVtOgpLc05vPA9qHunFI0(fTbkJKguA4SrIRXW1yaQRHcdnmGbBQ3qbLb1VlZgu54yBiWg0jWzdkAxqFXgu54E5dQrsdk5Hbh2G25UmruC7TcQ3bB1op(TefhUeU(Zbei(Tef)CRb1cwlUiXySmO0WzJexJHRXauxJbmQ212egSjr9gnObS39adkQIBZg0oLs5XyzqPm5yqfDUODb9fNlgduM4j0Io3BYhg3Ib5IrHzUxJHRXqcDcTOZvsXCyBUIWR0CL8baE8Cf3XtUEaeyp3Zdpoj3aW5I8GdtBg0IsCIrsdQmGppUv4gjnsaLrsdkpHvHPMRmOhG6mqddkGXdDi52RCTjmGbdACC9hdQ8lMbvXpGwrEGRomLnUrIRnsAq5jSkm1CLb9auNbAyqVixlyeKgPlOVyKhG3GLnOXX1FmOKUG(IrEaUXnsytgjnO8ewfMAUYGEaQZanmO6qIr97nkJOh1Z1UCHQ3g0446pg0aCIHR(da84g3iHOAK0GYtyvyQ5kd6lBqjSBqJJR)yqHeanSkSbfsuGzd61guibOoboBqX1HwjCaQhy)rqmUrIEBK0Gghx)XGcjWLvGEQ(dF6mO8ewfMAUY4g3GsXfQoqhBzNyK0ibugjnO8ewfMAUYGoboBqPbWw8)NkLp2wRYWoGjhEoSbnoU(JbLgaBX)FQu(yBTkd7aMC45Wg3iX1gjnO8ewfMAUYGoboBqjWJv5FAnWzV7oXnOXX1FmOe4XQ8pTg4S3DN4g3iHnzK0GYtyvyQ5kd6e4SbvOCxUR(i1GquCTeU(JbnoU(JbvOCxUR(i1GquCTeU(JXnsiQgjnO8ewfMAUYGoboBqPaoOikGRqycHlg0446pgukGdkIc4keMq4IXnUbLYibCXnsAKakJKg0446pguIw45WguEcRctnxzCJexBK0GYtyvyQ5kd6bOod0WGAbJG0G8kf5b4ny5CLknxlyeKM8lMbvDqGj6pnyzdACC9hdQ876pg3iHnzK0GYtyvyQ5kd6lBqjSBqJJR)yqHeanSkSbfsuGzdk99gPlOV4Q4hqRYHonxp2QJqU9ZL(EdsGlRa9u9h(01C9yRocguibOoboBqPVtQWYg3iHOAK0GYtyvyQ5kd6lBqjSBqJJR)yqHeanSkSbfsuGzdk99gPlOV4Q4hqRYHonxp2QJqU9ZL(EdsGlRa9u9h(01C9yRoc52px67nkd5Hb6iuLlHam3C9yRocguibOoboBqJsPsFNuHLnUrIEBK0GYtyvyQ5kd6lBqjSBqJJR)yqHeanSkSbfsuGzdkrMlLQhab2jnCDOvchGCTl3RZ9YCTGrqAqELI8a8gSSbfsaQtGZguchaDeQJk054bGRhy)rqmUrcrQrsdkpHvHPMRmOVSbLWUbnoU(Jbfsa0WQWguirbMnON)l0x80G8kTYayzx)PblNB)C7j3lYfekTYq4XBbLsAWY5kvAUGqPvgcpElOusJcdcx)j3EHnxOWqUsLMliuALHWJ3ckL0amEOdjx7WMluyi3lZT35Irl3EY1JcpERdEeyGocviVsB8ewfMMRuP5EEi8eJ3S9oqJjx7Z1(C7NBp52tUGqPvgcpElOustNCTl3RXqUsLMlrMlLQhab2jniVsRmaw21FY1oS527CTpxPsZ1JcpERdEeyGocviVsB8ewfMMRuP5EEi8eJ3S9oqJjx7nOqcqDcC2Gk)FPI8G6HsmUrcBOrsdkpHvHPMRmOhG6mqddQfmcsdYRuKhG3GLnOXX1FmOikGTk)tnUrIB0iPbLNWQWuZvg0dqDgOHb1cgbPb5vkYdWBWYg0446pgulgqyGT6iyCJeyugjnO8ewfMAUYGEaQZanmOezUuQEaeyN0kQqNtQyeHPc4845Ah2CVoxPsZTNCVixqO0kdHhVfukPX2GkXj5kvAUGqPvgcpElOustNCTlxByVZ1EdACC9hdArf6CsfJimvaNh34gjGcdgjnO8ewfMAUYGEaQZanmOwWiiniVsrEaEdw2Gghx)XGgZHjoik1tukg3ibuqzK0GYtyvyQ5kdACC9hd6jkLACC9NArjUbTOeVoboBqpIpg3ibuxBK0GYtyvyQ5kdACC9hdkaEQXX1FQfL4g0Is86e4Sbfp0X4g3GEeFmsAKakJKguEcRctnxzqHjCvCNw46jiUocgjGYGghx)XGs4aOJqDuHohpaSb9C)u4Qhab2jgjGYGEaQZanmO9KlKaOHvHBeoa6iuhvOZXdaxpW(JGKB)CVixibqdRc3K)VurEq9qj5AFUsLMBp5sFVr6c6lUk(b0QCOtdWiaM0fwfo3(5sK5sP6bqGDsdxhALWbix7YfQCT34gjU2iPbLNWQWuZvguycxf3PfUEcIRJGrcOmOXX1FmOeoa6iuhvOZXdaBqp3pfU6bqGDIrcOmOhG6mqddQhfE8gHdGoc1rf6C8aWnEcRctZTFU03BKUG(IRIFaTkh60amcGjDHvHZTFUezUuQEaeyN0W1HwjCaY1UCV24gjSjJKguEcRctnxzq)PCVEeFmOqzqJJR)yqX1HwTkbXnUXnOoqhBzNyK0ibugjnO8ewfMAUYGoboBqzC57aok1hqNyoSbnoU(JbLXLVd4OuFaDI5Wg0dqDgOHb98FH(INgKxPvgal76pnaJh6qYTxyZfQRZvQ0Cp)xOV4Pb5vALbWYU(tdW4HoKCTl3RTHg3iX1gjnO8ewfMAUYGoboBq1HCaWEyv46naoghgVszi6HnOXX1FmO6qoaypSkC9gahJdJxPme9Wg0dqDgOHb98FH(INgKxPvgal76pnaJh6qY1UCHcdg3iHnzK0GYtyvyQ5kd6e4SbfpoHfGRKoM9komrpg0446pgu84ewaUs6y2R4We9yqpa1zGgg0Z)f6lEAqELwzaSSR)0amEOdjx7YfkmyCJeIQrsdkpHvHPMRmOtGZguYdxkS76iubWw3nON7Ncx9aiWoXibug0446pguYdxkS76iubWw3nOhG6mqddQfmcst(fZGQoiWe9NgSCUsLM7f5kduM4ncxqQYVygu1bbMO)yCJe92iPbLNWQWuZvg0jWzdkrhe4svOeun8hqQwbvGRpsfHb)r97g0446pguIoiWLQqjOA4pGuTcQaxFKkcd(J63nOhG6mqdd65)c9fpniVsRmaw21FAagp0HKRDyZfkmyCJeIuJKguEcRctnxzqJJR)yqprPuJJR)ulkXnOhG6mqddAp5ErUEu4XBDWJad0rOc5vAJNWQW0CLknxkBbJG06GhbgOJqfYR0gSCU2NB)C7jxlyeKgKxPipaVblNRuP5E(VqFXtdYR0kdGLD9NgGXdDi5AxUqHHCT3GwuIxNaNnOuCHQd0Xw2jg3iHn0iPbLNWQWuZvg0dqDgOHb1cgbPb5vkYdWBWY5kvAUwWiin5xmdQ6Gat0FAWY5kvAUN)l0x80G8kTYayzx)Pby8qhsU2LluyWGghx)XGct4Q6moX4g3GEOeJKgjGYiPbLNWQWuZvg0dqDgOHb1cgbPb5vkYdWBWY5kvAUxKl5Hlw6qBNh3k8kotvpC9NgpHvHP52p3Z)f6lEAqELwzaSSR)0amEOdjx7WMluyixPsZfrf68kGXdDi52RCp)xOV4Pb5vALbWYU(tdW4HoedACC9hdQ8lMbvDqGj6pg3iX1gjnO8ewfMAUYGEaQZanmOa4HrEGa3iSChmgDsvg8NsGhU(tJVbWQSmtZTFU9KRhab2BkPguAUsLMRhab2Bu2cgbPDcIRJqdWXXZ1EdACC9hdkrl8Cyd65(PWvpacStmsaLXnsytgjnO8ewfMAUYGoboBqj6GaxQcLGQH)as1kOcC9rQim4pQF3Gghx)XGs0bbUufkbvd)bKQvqf46JuryWFu)Ub9auNbAyqTGrqAqELI8a8gSCUsLMRR4CU2Lluyi3(52tUxK75HWtmEBuHoVIeCU2BCJeIQrsdkpHvHPMRmOhG6mqdd6f5AbJG0G8kf5b4ny5C7NBp5ErUN)l0x80G8kT6paWJ3GLZvQ0CVixpk84niVsR(da84nEcRctZ1(CLknxlyeKgKxPipaVblNB)C7jxYdxS0H2eapeUQdev4bHR)04jSkmnxPsZL8WflDOneLl06JuTkpH84KgpHvHP5AVbnoU(Jbfj4QaCaOAmeJBKO3gjnO8ewfMAUYGEaQZanmO6qIr9752RCXOWqU9ZTNC7jxibqdRc3IsPsFNuHLZTFU9K7f5E(VqFXtdYR0kdGLD9NgSCUsLM7f56rHhV1bpcmqhHkKxPnEcRctZ1(CTpxPsZ1cgbPb5vkYdWBWY5AFU9ZTNCVixpk84To4rGb6iuH8kTXtyvyAUsLMlLTGrqADWJad0rOc5vAdwoxPsZ9ICTGrqAqELI8a8gSCU2NB)C7j3lY1JcpEJWbqhH6OcDoEa4gpHvHP5kvAUezUuQEaeyN0W1HwjCaYTx527CT3Gghx)XGIRdviWzIb9C)u4Qhab2jgjGY4gjePgjnO8ewfMAUYGEaQZanmO9KBp5ErUGqPvgcpElOusdwo3(5ccLwzi84TGsjnDY1UCVgd5AFUsLMliuALHWJ3ckL0amEOdjx7WMlu9oxPsZfekTYq4XBbLsAuyq46p52RCHQ35AFU9ZTNCTGrqAYVygu1bbMO)0GLZvQ0Cp)xOV4Pj)IzqvheyI(tdW4HoKCTdBUqHHCLkn3lYvgOmXBeUGuLFXmOQdcmr)jx7ZTFU9K7f56rHhV1bpcmqhHkKxPnEcRctZvQ0CPSfmcsRdEeyGocviVsBWY5kvAUxKRfmcsdYRuKhG3GLZ1EdACC9hdk809L715Heg3iHn0iPbLNWQWuZvg0dqDgOHb9ICTGrqAqELI8a8gSCU9Z9ICp)xOV4Pb5vALbWYU(tdwo3(5sK5sP6bqGDsdxhALWbix7YfQC7N7f56rHhVr4aOJqDuHohpaCJNWQW0CLkn3EY1cgbPb5vkYdWBWY52pxImxkvpacStA46qReoa52RCVo3(5ErUEu4XBeoa6iuhvOZXda34jSkmn3(5kdyivHdTbvdYR0Q1x8CTpxPsZTNCTGrqAqELI8a8gSCU9Z1JcpEJWbqhH6OcDoEa4gpHvHP5AVbnoU(Jb16)P(ivVJRb5WdLPg3iXnAK0GYtyvyQ5kdACC9hd6jkLACC9NArjUbTOeVoboBqDGo2YoX4g3GA9)yK0ibugjnO8ewfMAUYGEaQZanmOezUuQEaeyN0W1HwjCaYTxyZ1MmOXX1FmOb5WdLPvRsqCJBK4AJKguEcRctnxzqpa1zGggupacS3eRENo3yU9ZLiZLs1dGa7Kwqo8qzADEirU2Llu52pxImxkvpacStA46qReoa5AxUqL7L56rHhVr4aOJqDuHohpaCJNWQWudACC9hdAqo8qzADEiHXnUbfp0XiPrcOmsAq5jSkm1CLb9auNbAyqTGrqAw)p1hP6DCnihEOmTblBqjoqpUrcOmOXX1FmONOuQXX1FQfL4g0Is86e4Sb16)X4gjU2iPbnoU(JbLQezUuXdb9yq5jSkm1CLXnsytgjnO8ewfMAUYGEaQZanmOqcGgwfUj)FPI8G6HsYTFU6qIr975Ah2CfvmKB)C7jxDiXO(9C7f2CVXENRuP56rHhVr4aOJqDuHohpaCJNWQW0C7NlKaOHvHBeoa6iuhvOZXdaxpW(JGKR952p3lY98FH(INgIYdTblBqJJR)yqH8kTYayzx)X4gjevJKguEcRctnxzqpa1zGggulyeKgsWvb4aq1yiny5C7N7f5szlyeKMyq4DiWLksWaLBWYg0446pgusxqFXvXpGwLdDmUrIEBK0GYtyvyQ5kdACC9hd6jkLACC9NArjUbTOeVoboBqpuIXnsisnsAq5jSkm1CLb9auNbAyq9OWJ3iCa0rOoQqNJhaUXtyvyAU9ZLiZLs1dGa7KgUo0kHdqU2LlKaOHvHB46qReoa1dS)ii52p3lYL(EJ0f0xCv8dOv5qNMRhB1ri3(5ErUN)l0x80quEOnyzdACC9hdkUo0kHdGb9C)u4Qhab2jgjGY4gjSHgjnO8ewfMAUYGEaQZanmOxKlKaOHvHBrPuPVtQWYg0446pguAGpHR)yqp3pfU6bqGDIrcOmUrIB0iPbLNWQWuZvg0dqDgOHbvhsmQFp3EHn3BS352pxpk84To4rGb6iuH8kTXtyvyAU9Z1JcpEJWbqhH6OcDoEa4gpHvHP52pxImxkvpacStA46qReoa52lS5ksZvQ0C7j3EY1JcpERdEeyGocviVsB8ewfMMB)CVixpk84nchaDeQJk054bGB8ewfMMR95kvAUezUuQEaeyN0W1HwjCaYfBUqLR9g0446pguiVsRwFXnUrcmkJKguEcRctnxzqpa1zGgg0EYfWiaM0fwfoxPsZvhsmQFpx7Y1g27CTp3(52tUxKlKaOHvHBY)xQipOEOKCLknxDiXO(9CTdBU3yVZ1(C7NBp5ErUEu4XBeoa6iuhvOZXda34jSkmnxPsZTNC9OWJ3iCa0rOoQqNJhaUXtyvyAU9Z9ICHeanSkCJWbqhH6OcDoEa46b2FeKCTpx7nOXX1FmOugYdd0rOkxcby2GEUFkC1dGa7eJeqzCJeqHbJKguEcRctnxzqpa1zGgguImxkvpacStA46qReoa52RC7jxrn3lZ98dfw9gvjKFIXR8P7zsJNWQW0CTp3(5Qdjg1VNBVWM7n27C7NRhfE8gHdGoc1rf6C8aWnEcRctZvQ0CVixpk84nchaDeQJk054bGB8ewfMAqJJR)yqH8kTA9f34gjGckJKguEcRctnxzqpa1zGgg0EY1dGa7TookExt(452RCVgd52pxImxkvpacStA46qReoa52RCf1CTpxPsZTNCLzVHO8qBXXviCU9ZfapmYde4gPlOVyKsGZvzGsWB8nawLLzAU2BqJJR)yqjDb9fxf)aALYH3zqp3pfU6bqGDIrcOmUrcOU2iPbLNWQWuZvg0dqDgOHb1dGa7nxX5Q)vQY52RCVU352pxlyeKgKxPipaVrFXJbnoU(JbLada8qzq1)kEqhMqmON7Ncx9aiWoXibug3ibu2KrsdkpHvHPMRmOhG6mqddkKaOHvHB03jvy5C7NRhab2BUIZv)RuLZ1UCTPC7NRfmcsdYRuKhG3OV4j3(5ghxHWv67nibUSc0t1F4txU2HnxImxkvpacStAqcCzfONQ)WNUC7NlrMlLQhab2jnCDOvchGC7vU9KBVZ9YC7jxrAUy0Y1JcpEZfReV(ivKW5gpHvHP5AFU2BqJJR)yqH8kT6paWJBqp3pfU6bqGDIrcOmUrcOevJKguEcRctnxzqpa1zGggu67nibUSc0t1F4txZ1JT6iKB)C7jxpk84nchaDeQJk054bGB8ewfMMB)CjYCPu9aiWoPHRdTs4aKRD5cjaAyv4gUo0kHdq9a7pcsUsLMl99gPlOV4Q4hqRYHonxp2QJqU2BqJJR)yqX1HAXdLbg3ibu92iPbLNWQWuZvg0dqDgOHbfapmYde4MCOJfGdBzqvMef8gFdGvzzMMB)CHeanSkCJ(oPclNB)C9aiWEZvCU6Fv(41RXqU2LBp5E(VqFXtJ0f0xCv8dOvkhExJcdcx)j3lZv4qZ1EdACC9hdkPlOV4Q4hqRuo8oJBKakrQrsdkpHvHPMRmOhG6mqddkiuALHWJ3ckL00jx7YfkmyqJJR)yqjDb9fxpGG0zCJeqzdnsAq5jSkm1CLbnoU(JbfxhALWbWGEUFkC1dGa7eJeqzq1Xzaaw2RkIb11JTe7WETbvhNbayzVQ44mvdNnOqzqpDHoguOmOhG6mqddkrMlLQhab2jnCDOvchGCTlxibqdRc3W1HwjCaQhy)rqYTFUwWiinAaST6DpSqN3GLnUrcOUrJKguEcRctnxzqJJR)yqX1HwrkXDdQoodaWYEvrmOUESLyh2R7F(VqFXtdYR0Q1x8gSSbvhNbayzVQ44mvdNnOqzqpDHoguOmOhG6mqddQfmcsJgaBRE3dl05ny5C7NlKaOHvHB03jvyzJBKakmkJKguEcRctnxzqpa1zGgguibqdRc3OVtQWY52pxqO0kdHhVH)qyCE8Mo5AxUNG4vxX5CVmxm06DU9ZTNCjYCPu9aiWoPHRdTs4aKBVYvuZTFUxKRhfE8gUsyW9gpHvHP5kvAUezUuQEaeyN0W1HwjCaYTx5ksZTFUEu4XB4kHb3B8ewfMMR9g0446pguCDOvRsqCJBK4AmyK0GYtyvyQ5kd6bOod0WGcyeat6cRcNB)C9aiWEZvCU6FLQCU2LRinxPsZTNC9OWJ3WvcdU34jSkmn3(5sFVr6c6lUk(b0QCOtdWiaM0fwfox7ZvQ0CTGrqAWdcmOOJqLgaBhMqAWYg0446pguibUSc0t1F4tNb9C)u4Qhab2jgjGY4gjUgkJKguEcRctnxzqpa1zGgguaJaysxyv4C7NRhab2BUIZv)RuLZ1UCf1C7N7f56rHhVHRegCVXtyvyAU9Z1JcpEtMC)0PNArhBB8ewfMMB)CjYCPu9aiWoPHRdTs4aKRD5ETbnoU(JbL0f0xCv8dOv5qhJBK46RnsAq5jSkm1CLb9auNbAyqbmcGjDHvHZTFUEaeyV5kox9Vsvox7YvuZTFUxKRhfE8gUsyW9gpHvHP52p3lYTNC9OWJ3iCa0rOoQqNJhaUXtyvyAU9ZLiZLs1dGa7KgUo0kHdqU2LlKaOHvHB46qReoa1dS)ii5AFU9ZTNCVixpk84nzY9tNEQfDSTXtyvyAUsLMBp56rHhVjtUF60tTOJTnEcRctZTFUezUuQEaeyN0W1HwjCaYTxyZ96CTpx7nOXX1FmOKUG(IRIFaTkh6yqp3pfU6bqGDIrcOmUrIRTjJKguEcRctnxzqJJR)yqX1HwjCamON7Ncx9aiWoXibuguDCgaGL9QIyqD9ylXoSxBq1Xzaaw2Rkoot1Wzdkug0txOJbfkd6bOod0WGsK5sP6bqGDsdxhALWbix7Yfsa0WQWnCDOvchG6b2FeeJBK4Ar1iPbLNWQWuZvg0446pguCDOvKsC3GQJZaaSSxvedQRhBj2H96(N)l0x80G8kTA9fVblBq1Xzaaw2Rkoot1Wzdkug0txOJbfkJBK46EBK0Gghx)XGs6c6lUk(b0kLdVZGYtyvyQ5kJBK4ArQrsdACC9hdkPlOV4Q4hqRYHoguEcRctnxzCJBCdkegq0FmsCngUgdqDngUrdQ4am6iqmOIe4YpWzAU3yUXX1FYTOeN0sOnOYGhrlSbv05I2f0xCUymqzINql6CVjFyClgKlgfM5EngUgdj0j0IoxjfZHT5kcVsZvYha4XZvChp56bqG9Cpp84KCdaNlYdomTLqNql6CVH2G8b2zAUwmYd4CppUv45AXc6qA5kkphw2j5o)ydOla4iWLCJJR)qY9NY9wcDCC9hstgWNh3k8lXER8lMbvXpGwrEGRomLXurWcy8qhsVSjmGHe6446pKMmGppUv4xI9wsxqFXipahtfb7fwWiinsxqFXipaVblNqhhx)H0Kb85XTc)sS3gGtmC1FaGhhtfbRoKyu)EJYi6rD7GQ3j0XX1FinzaFECRWVe7TqcGgwfgZjWzS46qReoa1dS)iiy(YyjSJjKOaZyVoHooU(dPjd4ZJBf(LyVfsGlRa9u9h(0LqNql6CX431Fij0XX1FiyjAHNdNqhhx)HGv(D9hmveSwWiiniVsrEaEdwwQulyeKM8lMbvDqGj6pny5e6446pKlXElKaOHvHXCcCgl9DsfwgZxglHDmHefygl99gPlOV4Q4hqRYHonxp2QJqF67nibUSc0t1F4txZ1JT6iKqhhx)HCj2BHeanSkmMtGZyJsPsFNuHLX8LXsyhtirbMXsFVr6c6lUk(b0QCOtZ1JT6i0N(EdsGlRa9u9h(01C9yRoc9PV3OmKhgOJqvUecWCZ1JT6iKql6Cr9a45ct0rixuoa6iKReQqNJhao3WZ1MUmxpacStY9b5kQxMRIK79ho3aW5QtUIWRuKhGNqhhx)HCj2BHeanSkmMtGZyjCa0rOoQqNJhaUEG9hbbZxglHDmHefyglrMlLQhab2jnCDOvcha7U(slyeKgKxPipaVblNql6CT5)l0x8Klg)FjxriaAyvymZvejmnx)Zv()sUwmYd4CJJRqcxhHCH8kf5b4TCTzyaGhVCpxyctZ1)Cp)4GVKR4oEY1)CJJRqcNZfYRuKhGNRy17YvNZJRJqUbLsAj0XX1FixI9wibqdRcJ5e4mw5)lvKhupucMVmwc7ycjkWm2Z)f6lEAqELwzaSSR)0GL73ZfGqPvgcpElOusdwwQuqO0kdHhVfukPrHbHR)0lSqHbPsbHsRmeE8wqPKgGXdDi2HfkmCzVXO1JhfE8wh8iWaDeQqEL24jSkmvQ0ZdHNy8MT3bAm2BF)E6bekTYq4XBbLsA6y31yqQuImxkvpacStAqELwzaSSR)yh2EBVuPEu4XBDWJad0rOc5vAJNWQWuPsppeEIXB2EhOXyFcDCC9hYLyVfrbSv5FkMkcwlyeKgKxPipaVblNqhhx)HCj2BTyaHb2QJaMkcwlyeKgKxPipaVblNql6CfrcNRnUk05yKKCHgMkGZJNRIKR3Xao3aW5EDUpix8hW56bqGDcM5(GCdkLKBa4bJ0ZLihIhDeYf5b5I)aoxVlMCTH9M0sOJJR)qUe7TfvOZjvmIWubCECmveSezUuQEaeyN0kQqNtQyeHPc4842H9APs75cqO0kdHhVfukPX2GkXjsLccLwzi84TGsjnDSZg2B7tOJJR)qUe7TXCyIdIs9eLcMkcwlyeKgKxPipaVblNqhhx)HCj2BprPuJJR)ulkXXCcCg7r8jHooU(d5sS3cGNACC9NArjoMtGZyXdDsOtOfDUIsm2gpx)ZfMW5kUJNCV6)j3hjxVJZvuso8qzAUkj344keoHooU(dPz9)GnihEOmTAvcIJPIGLiZLs1dGa7KgUo0kHdqVWAtj0XX1FinR)NlXEBqo8qzADEibMkcwpacS3eRENo3yFImxkvpacStAb5WdLP15He2bvFImxkvpacStA46qReoa2b1LEu4XBeoa6iuhvOZXda34jSkmnHoHw05AZ3KKql6CfrcNlg)IzqUIedcmr)jxXQ3LRi8kf5b4TCTX(cnxKhKRi8kf5b45EECMK7JGK75)c9fp5QtUEhN7W2GEUqHHCj85hkj337yGyLW5ct4C)j3dnx4PWesUEhNlgZLq4j5kjiupxB(XTcpxrotvpC9NCvsUEu4XzkM5(GCvKC9ogW5kwlLCN3Z1IZnM37yqUIWR0CVHayzx)jxVtj5IOcDElHooU(dPDOeSYVygu1bbMO)GPIG1cgbPb5vkYdWBWYsLEb5Hlw6qBNh3k8kotvpC9NgpHvHP9p)xOV4Pb5vALbWYU(tdW4Hoe7WcfgKkfrf68kGXdDi968FH(INgKxPvgal76pnaJh6qsOfDUIiHZfvl8C4C)jxB(M56FUYG)Klkl3bJrhJKKlgd(tjWdx)PLqhhx)H0ouYLyVLOfEomMN7Ncx9aiWobluyQiybWdJ8abUry5oym6KQm4pLapC9NgFdGvzzM2VhpacS3usnOuPs9aiWEJYwWiiTtqCDeAaooU9j0IoxrKW5Evqf4C1HOuo3hjxrWgLlYdY174CruaXZfMW5(GC)jxB(M5giodY174CruaXZfMWTCfzQ3LReQqNNRnk4C7(cnxKhKRiyJAj0XX1FiTdLCj2BHjCvDghZjWzSeDqGlvHsq1WFaPAfubU(iveg8h1VJPIG1cgbPb5vkYdWBWYsL6koBhuyOFpxCEi8eJ3gvOZRibBFcTOZvejCU2OGZ1giCaOAmKC)jxB(M5(WorPCUpsUIWRuKhG3YvejCU2OGZ1giCaOAmusU6KRi8kf5b45Qi5E)HZTlGW5YQ3XGCTbcEiCUIedev4bHR)K7dY1gPCHM7JK7vLNqECslHooU(dPDOKlXElsWvb4aq1yiyQiyVWcgbPb5vkYdWBWY975IZ)f6lEAqELw9ha4XBWYsLEHhfE8gKxPv)baE8gpHvHP2lvQfmcsdYRuKhG3GL73d5Hlw6qBcGhcx1bIk8GW1FA8ewfMkvk5Hlw6qBikxO1hPAvEc5XjnEcRctTpHw05kIeoxrUouHaNj5kUJNCJsjxBk3B(ssYnaCUWYyM7dY9(dNBa4C1jxr4vkYdWB5EdhcmGZ1gdEeyGoc5kcVsZvj5ghxHW5(tUEhNRhab2ZvrY1JcpotB5I6VCUWeDeYn8C79L56bqGDsUIvVlxuoa6iKReQqNJhaULqhhx)H0ouYLyVfxhQqGZemp3pfU6bqGDcwOWurWQdjg1V3lmkm0VNEGeanSkClkLk9DsfwUFpxC(VqFXtdYR0kdGLD9NgSSuPx4rHhV1bpcmqhHkKxPnEcRctT3EPsTGrqAqELI8a8gSS9975cpk84To4rGb6iuH8kTXtyvyQuPu2cgbP1bpcmqhHkKxPnyzPsVWcgbPb5vkYdWBWY23VNl8OWJ3iCa0rOoQqNJhaUXtyvyQuPezUuQEaeyN0W1HwjCa6vVTpHw05kIeoxrC6(Y9CL4He5(tU28nXm3UVq1rixlGYiL756FUId1Zf5b5k)IzqU6Gat0FY9b5guAUe5q8qAj0XX1FiTdLCj2BHNUVCVopKatfbBp9CbiuALHWJ3ckL0GL7dcLwzi84TGsjnDS7AmyVuPGqPvgcpElOusdW4Hoe7WcvVLkfekTYq4XBbLsAuyq46p9cQEBF)ESGrqAYVygu1bbMO)0GLLk98FH(INM8lMbvDqGj6pnaJh6qSdluyqQ0lKbkt8gHliv5xmdQ6Gat0FSVFpx4rHhV1bpcmqhHkKxPnEcRctLkLYwWiiTo4rGb6iuH8kTbllv6fwWiiniVsrEaEdw2(eArNRis4C)jxB(M5Ab75kd0hOUs4CHj6iKRi8kn3Biaw21FYfrbehZCvKCHjmnxDikLZ9rYveSr5(tUOsMlmHZnqCgKBKlKxPwFXZf5b5E(VqFXtUmcIEuEo3ZngAUipi3o4rGb6iKlKxP5cl7koNRIKRhfECM2sOJJR)qAhk5sS3A9)uFKQ3X1GC4HYumveSxybJG0G8kf5b4ny5(xC(VqFXtdYR0kdGLD9NgSCFImxkvpacStA46qReoa2bv)l8OWJ3iCa0rOoQqNJhaUXtyvyQuP9ybJG0G8kf5b4ny5(ezUuQEaeyN0W1HwjCa6119VWJcpEJWbqhH6OcDoEa4gpHvHP9LbmKQWH2GQb5vA16lU9sL2JfmcsdYRuKhG3GL77rHhVr4aOJqDuHohpaCJNWQWu7tOJJR)qAhk5sS3EIsPghx)PwuIJ5e4mwhOJTStsOtOfDU2Cq8CfzDAHZ1MdIRJqUXX1FiTCrzp3WZTtf6yqUYa9bQFpx)ZL09ap3JcoWQNRoodaWYEUNFOQR)qY9NCf56qZfLdWT2OsCpHw05kIeoxuoa6iKReQqNJhaoxfj37pCUI1sj3o1ZLNhwOlxpacStYngAUy8lMb5ksmiWe9NCJHMRi8kf5b45gao359CbCqVJzUpix)ZfWiaM0LlQituGX5(tUU4p3hKl(d4C9aiWoPLqhhx)H0oIpyjCa0rOoQqNJhagtycxf3PfUEcIRJawOW8C)u4Qhab2jyHctfbBpqcGgwfUr4aOJqDuHohpaC9a7pcs)lGeanSkCt()sf5b1dLyVuP9qFVr6c6lUk(b0QCOtdWiaM0fwfUprMlLQhab2jnCDOvcha7GY(eArNlA3d8CTzfCGvpxuoa6iKReQqNJhao3Zpu11FY1)CTLz5CrfzIcmoxy5C1jxr5FdtOJJR)qAhXNlXElHdGoc1rf6C8aWyct4Q4oTW1tqCDeWcfMN7Ncx9aiWobluyQiy9OWJ3iCa0rOoQqNJhaUXtyvyAF67nsxqFXvXpGwLdDAagbWKUWQW9jYCPu9aiWoPHRdTs4ay31j0Io3Fk3RhXNCXdBzsUEhNBCC9NC)PCpxysyv4CPWaDeY90fZWfDeYngAUZ75gKCJCbSaCja5ghx)PLqhhx)H0oIpxI9wCDOvRsqCm)PCVEeFWcvcDcDCC9hsJIluDGo2YoblmHRQZ4yoboJLgaBX)FQu(yBTkd7aMC45Wj0XX1FinkUq1b6yl7KlXElmHRQZ4yoboJLapwL)P1aN9U7epHooU(dPrXfQoqhBzNCj2BHjCvDghZjWzScL7YD1hPgeIIRLW1FsOJJR)qAuCHQd0Xw2jxI9wycxvNXXCcCglfWbfrbCfctiCjHoHw05kYdDYvuIX24yMlP7Hl0CppegKBuk5cIrGj5(i56bqGDsUXqZLC4ja6tsOJJR)qA4HoxI92tuk1446p1IsCmNaNXA9)GjXb6XXcfMkcwlyeKM1)t9rQEhxdYHhktBWYj0XX1Fin8qNlXElvjYCPIhc6jHw05kIeoxr4vAU3qaSSR)K7p5E(VqFXtUY)x0ri3WZTWbXZvuXqU6qIr975Ab75oVNRIK79hoxXAPK7dHbNqoxDiXO(9C1jxrWg1YvKh2Y5sGbCUKUG(IruEO3IRd1IhkdYvj5(tUN)l0x8KRfJ8aoxr4g2sOJJR)qA4HoyH8kTYayzx)btfblKaOHvHBY)xQipOEOK(6qIr972HvuXq)E0HeJ637f2BS3sL6rHhVr4aOJqDuHohpaCJNWQW0(qcGgwfUr4aOJqDuHohpaC9a7pcI99V48FH(INgIYdTblNql6Cf5HTCUeyaN79hoxzypxy5CrfzIcmoxrjQOeJZ9NC9ooxpacSNRIKRideEhcCjxBuWaLZvjdgPNBCCfc3sOJJR)qA4HoxI9wsxqFXvXpGwLdDWurWAbJG0qcUkahaQgdPbl3)ckBbJG0edcVdbUurcgOCdwoHooU(dPHh6Cj2BprPuJJR)ulkXXCcCg7HssOfDU2yQqxUymqFG63ZvKRdnxuoa5ghx)jx)ZfWiaM0L7nFjj5kw9UCjCa0rOoQqNJhaoHooU(dPHh6Cj2BX1HwjCaW8C)u4Qhab2jyHctfbRhfE8gHdGoc1rf6C8aWnEcRct7tK5sP6bqGDsdxhALWbWoibqdRc3W1HwjCaQhy)rq6Fb99gPlOV4Q4hqRYHonxp2QJq)lo)xOV4PHO8qBWYj0IoxmgWimix)ZfMW5EZaFcx)jxrjQOeJZvrYnM75EZxYCvsUZ75cl3sOJJR)qA4HoxI9wAGpHR)G55(PWvpacStWcfMkc2lGeanSkClkLk9DsfwoHw05kIeoxr4vAUx9fp3WZTtf6yqUYa9bQFpxXQ3LRng8iWaDeYveELMlSCU(NROMRhab2jyM7dY99ogKRhfECsU)KlQKTe6446pKgEOZLyVfYR0Q1xCmveS6qIr979c7n27(Eu4XBDWJad0rOc5vAJNWQW0(Eu4XBeoa6iuhvOZXda34jSkmTprMlLQhab2jnCDOvchGEHvKkvAp94rHhV1bpcmqhHkKxPnEcRct7FHhfE8gHdGoc1rf6C8aWnEcRctTxQuImxkvpacStA46qReoayHY(eArN7n)bJ0ZfMW5EtgYdd0rixmUecWCUksU3F4CpXKRa75QJ)5kcVsrEaEU6qCoOyM7dYvrYfLdGoc5kHk054bGZvj56rHhNP5gdnxXAPKBN65YZdl0LRhab2jTe6446pKgEOZLyVLYqEyGocv5siaZyEUFkC1dGa7eSqHPIGThaJaysxyvyPs1HeJ63TZg2B773ZfqcGgwfUj)FPI8G6HsKkvhsmQF3oS3yVTVFpx4rHhVr4aOJqDuHohpaCJNWQWuPs7XJcpEJWbqhH6OcDoEa4gpHvHP9Vasa0WQWnchaDeQJk054bGRhy)rqS3(eArNRis4CfHRY9NCT5BMRIK79hox6pyKEUdZ0C9p3tq8CVjd5Hb6iKlgxcbygZCJHMR3Xao3aW5wycjxVlMCf1C9aiWoj3h2ZTNENRy17Y98dfwD7Bj0XX1Fin8qNlXElKxPvRV4yQiyjYCPu9aiWoPHRdTs4a0REe1lp)qHvVrvc5Ny8kF6EM04jSkm1((6qIr979c7n27(Eu4XBeoa6iuhvOZXda34jSkmvQ0l8OWJ3iCa0rOoQqNJhaUXtyvyAcTOZvejCUODb9fNRi7burrU3KdVlxfjxVJZ1dGa75QKCdRh2Z1)CPkN7dY9(dNBxaHZfTlOVyKsGZ5IXaLGNlFdGvzzMMRy17YvKRd1IhkdY9b5I2f0xmIYdn344keULqhhx)H0WdDUe7TKUG(IRIFaTs5W7W8C)u4Qhab2jyHctfbBpEaeyV1XrX7AYhVxxJH(ezUuQEaeyN0W1HwjCa6LOAVuP9iZEdr5H2IJRq4(a4HrEGa3iDb9fJucCUkducEJVbWQSmtTpHw05kIeoxuyaGhkdY1)Cf5bDycj3FYnY1dGa756DHNRsYv41rix)ZLQCUHNR3X5cuHopxxX5wcDCC9hsdp05sS3sGbaEOmO6FfpOdtiyEUFkC1dGa7eSqHPIG1dGa7nxX5Q)vQY966E33cgbPb5vkYdWB0x8Kql6CfrcNRi8knxjFaGhp3Fk3ZvrYfvKjkW4CJHMRiizUbGZnoUcHZngAUEhNRhab2Zv8pyKEUuLZLcd0rixVJZ90fZWLwcDCC9hsdp05sS3c5vA1FaGhhZZ9tHREaeyNGfkmveSqcGgwfUrFNuHL77bqG9MR4C1)kvz7SP(wWiiniVsrEaEJ(IN(XXviCL(EdsGlRa9u9h(0zhwImxkvpacStAqcCzfONQ)WNU(ezUuQEaeyN0W1HwjCa6vp9(YEePy08OWJ3CXkXRpsfjCUXtyvyQ92Nqhhx)H0WdDUe7T46qT4HYamveS03BqcCzfONQ)WNUMRhB1rOFpEu4XBeoa6iuhvOZXda34jSkmTprMlLQhab2jnCDOvcha7GeanSkCdxhALWbOEG9hbrQu67nsxqFXvXpGwLdDAUESvhb7tOfDUIiHZfvKjkUzUIvVlxmo0XcWHTmixmMef8CHNcti56DCUEaeypxXAPKRfNRfxEX5EngWiyUwmYd4C9oo3Z)f6lEY984mjxR4yBcDCC9hsdp05sS3s6c6lUk(b0kLdVdtfblaEyKhiWn5qhlah2YGQmjk4n(gaRYYmTpKaOHvHB03jvy5(EaeyV5kox9VkF861yWUEo)xOV4Pr6c6lUk(b0kLdVRrHbHR)CPWHAFcTOZvejCUODb9fNRndcsxU)KRnFZCHNcti56DmGZnaCUbLsYvNZJRJqlHooU(dPHh6Cj2BjDb9fxpGG0HPIGfekTYq4XBbLsA6yhuyiHw05kIeoxrUo0Cr5aKR)5E(HaJZ5EZayBUs29WcDojxzWFi5(tUIsrYBylxjfjVPizU28pikapxLKR3PKCvsUrUDQqhdYvgOpq9756DXKlGPV76iK7p5kkfjVH5cpfMqYLgaBZ17EyHoNKRsYnSEypx)Z1vCo3h2tOJJR)qA4HoxI9wCDOvchamp3pfU6bqGDcwOWurWsK5sP6bqGDsdxhALWbWoibqdRc3W1HwjCaQhy)rq6BbJG0ObW2Q39WcDEdwgZtxOdwOWuhNbayzVQ44mvdNXcfM64maal7vfbRRhBj2H96eArNRis4Cf56qZ1gvI756FUNFiW4CU3ma2MRKDpSqNtYvg8hsU)KlQKTCLuK8MIK5AZ)GOa8CvKC9oLKRsYnYTtf6yqUYa9bQFpxVlMCbm9DxhHCHNcti5sdGT56DpSqNtYvj5gwpSNR)56koN7d7j0XX1Fin8qNlXElUo0ksjUJPIG1cgbPrdGTvV7Hf68gSCFibqdRc3OVtQWYyE6cDWcfM64maal7vfhNPA4mwOWuhNbayzVQiyD9ylXoSx3)8FH(INgKxPvRV4ny5eArNRis4Cf56qZ9Qsq8CvKCV)W5s)bJ0ZDyMMR)5cyeat6Y9MVKKwUO(lN7jiUoc5gEUIAUpix8hW56bqGDsUIvVlxuoa6iKReQqNJhaoxpk84mTLqhhx)H0WdDUe7T46qRwLG4yQiyHeanSkCJ(oPcl3hekTYq4XB4pegNhVPJDNG4vxX5lXqR397HiZLs1dGa7KgUo0kHdqVe1(x4rHhVHRegCVXtyvyQuPezUuQEaeyN0W1HwjCa6LiTVhfE8gUsyW9gpHvHP2Nqhhx)H0WdDUe7TqcCzfONQ)WNomp3pfU6bqGDcwOWurWcyeat6cRc33dGa7nxX5Q)vQY2jsLkThpk84nCLWG7nEcRct7tFVr6c6lUk(b0QCOtdWiaM0fwf2EPsTGrqAWdcmOOJqLgaBhMqAWYj0Ioxuz(Orj3Zpu11FY1)Cj(lN7jiUoc5IkYefyCU)K7JGydWdGa7KCf3XtUiQqNRJqU2uUpix8hW5s84yltZf)Ti5gdnxyIoc5IXK7No9KRnUo2MBm0CLqKuYCf5kHb3Bj0XX1Fin8qNlXElPlOV4Q4hqRYHoyQiybmcGjDHvH77bqG9MR4C1)kvz7e1(x4rHhVHRegCVXtyvyAFpk84nzY9tNEQfDSTXtyvyAFImxkvpacStA46qReoa2DDcTOZfJqmlNlQituGX5clN7p5gKCXJ5EUEaeyNKBqYv(je1QWyMlBdEyzpxXD8KlIk056iKRnL7dYf)bCUepo2Y0CXFlsUIvVlxmMC)0PNCTX1X2wcDCC9hsdp05sS3s6c6lUk(b0QCOdMN7Ncx9aiWobluyQiybmcGjDHvH77bqG9MR4C1)kvz7e1(x4rHhVHRegCVXtyvyA)l6XJcpEJWbqhH6OcDoEa4gpHvHP9jYCPu9aiWoPHRdTs4ayhKaOHvHB46qReoa1dS)ii23VNl8OWJ3Kj3pD6Pw0X2gpHvHPsL2JhfE8Mm5(Ptp1Io224jSkmTprMlLQhab2jnCDOvchGEH9A7TpHooU(dPHh6Cj2BX1HwjCaW8C)u4Qhab2jyHctfblrMlLQhab2jnCDOvcha7GeanSkCdxhALWbOEG9hbbZtxOdwOWuhNbayzVQ44mvdNXcfM64maal7vfbRRhBj2H96e6446pKgEOZLyVfxhAfPe3X80f6Gfkm1Xzaaw2Rkoot1WzSqHPoodaWYEvrW66XwIDyVU)5)c9fpniVsRwFXBWYj0IoxrKW5IkYef3m3GKBjiEUaM8apxfj3FY174CXFiCcDCC9hsdp05sS3s6c6lUk(b0kLdVlHw05kIeoxurMOaJZni5wcINlGjpWZvrY9NC9oox8hcNBm0CrfzIIBMRsY9NCT5BMqhhx)H0WdDUe7TKUG(IRIFaTkh6KqNql6CfrcN7p5AZ3mxrjQOeJZ1)Cfyp3B(sMRRhB1ri3yO5Y2GYkGZ1)Cl6W5clNRf7odYvS6D5kcVsrEaEcDCC9hsZb6yl7eSWeUQoJJ5e4mwgx(oGJs9b0jMdJPIG98FH(INgKxPvgal76pnaJh6q6fwOUwQ0Z)f6lEAqELwzaSSR)0amEOdXURTHj0Iox07ZjxrcmcFZCfRExUIWRuKhGNqhhx)H0CGo2Yo5sS3ct4Q6moMtGZy1HCaWEyv46naoghgVszi6HXurWE(VqFXtdYR0kdGLD9NgGXdDi2bfgsOfDUO3NtUODm75kYHj6jxXQ3LRi8kf5b4j0XX1FinhOJTStUe7TWeUQoJJ5e4mw84ewaUs6y2R4We9GPIG98FH(INgKxPvgal76pnaJh6qSdkmKql6CrVpNCXiaS19CfRExUy8lMb5ksmiWe9NCHjHaJzU4HTCUeyaNR)5sgvMZ174ClVyM45AJHX56bqG9e6446pKMd0Xw2jxI9wycxvNXXCcCgl5Hlf2DDeQayR7yQiyTGrqAYVygu1bbMO)0GLLk9czGYeVr4csv(fZGQoiWe9hmp3pfU6bqGDcwOsOfDUIiHZ9QGkW5QdrPCUpsUIGnkxKhKR3X5IOaINlmHZ9b5(tU28nZnqCgKR3X5IOaINlmHB5I29ap3JcoWQNRIKlKxP5Yayzx)j3Z)f6lEYvj5cfgi5(GCXFaNBioU3sOJJR)qAoqhBzNCj2BHjCvDghZjWzSeDqGlvHsq1WFaPAfubU(iveg8h1VJPIG98FH(INgKxPvgal76pnaJh6qSdluyiHw05kIeo3Is8CFKC)XgamHZLg4HaNRd0Xw2j5(t5EUksU2yWJad0rixr4vAU3KTGrqYvj5ghxHWyM7dY9(dNBa4CN3Z1JcpotZvh)Zv9wcDCC9hsZb6yl7KlXE7jkLACC9NArjoMtGZyP4cvhOJTStWurW2ZfEu4XBDWJad0rOc5vAJNWQWuPsPSfmcsRdEeyGocviVsBWY23VhlyeKgKxPipaVbllv65)c9fpniVsRmaw21FAagp0HyhuyW(eArN7nzKaU45IeLIvCSnxKhKlmjSkCUQZ4errUIiHZ9NCp)xOV4jxDY9bugKR19CDGo2YEUKY7Te6446pKMd0Xw2jxI9wycxvNXjyQiyTGrqAqELI8a8gSSuPwWiin5xmdQ6Gat0FAWYsLE(VqFXtdYR0kdGLD9NgGXdDi2bfgmOez(yK46EFJg34gd]] )


end
