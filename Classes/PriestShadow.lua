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


    spec:RegisterPack( "Shadow", 20201208, [[daLYEbqivcpIqQlbfjOnjv6tqrsJIsLtrP0QGIu8kvIMfi1TiKuSlP8lvknmOOogizzQu8mkfzAuk4AsfzBec13iePXPskohuKQ1rirZtQOUhuAFsfoiHKSqvsEiLIAIQKQlQsk1gPuiFKqsPrsPq5KecXkHcVeksiZKsHQBsiIDsK8tcH0qHI4Oqrc1sHIe4PqAQePUkHGTsiQVsiH9sXFf1Gv6WclMsESkMmsxg1MH4ZemAPQttA1qrIEnLQMTi3gQ2TIFRQHtuhxLuYYbEoIPt11b12bX3juJNqs15vPA9qrknFIy)s2aLrAdknC2i1ny(gmd1ny(AAqHPBtxZny6gu)UmBqLJJ9HaBqNaNnOO9b9fBqLJ7PpOgPnOKhgCydAV7Yer5T3kOEpSv7843suC4u46phqG43su8ZTgulyn5IiJXYGsdNnsDdMVbZqDdMVMguIuOePy2MmObS3)adkQIBZg0ELs5XyzqPm5yqfDTO9b9fxlMauM4fgIU2RZhg3Ib1Enqx7ny(gmBqtkXjgPnOhXhJ0gPGYiTbLNWkXuZvguycNf3RjoFcIRJGrkOmOXX1FmOeoa6iKhvO3XdaBqp3pjo7bqGDIrkOmOhG6mqddQD1cjaAyL4gHdGoc5rf6D8aW5dS)ii12T2lQfsa0WkXn5)tzKhKpusT2wRej1AxT03BK(G(IZIFanlh60amcGj9HvIRTBTezoLYEaeyN0W1HMjCaQTJAHQwBnUrQBmsBq5jSsm1CLbfMWzX9AIZNG46iyKckdACC9hdkHdGoc5rf6D8aWg0Z9tIZEaeyNyKckd6bOod0WG6rIhVr4aOJqEuHEhpaCJNWkX0A7wl99gPpOV4S4hqZYHonaJaysFyL4A7wlrMtPShab2jnCDOzchGA7O2BmUrkBYiTbLNWkXuZvg0Fs3ZhXhdkug0446pguCDOzRuqCJBCdkfxi7aDSNDIrAJuqzK2GYtyLyQ5kd6e4SbLga7X)FYu(yFold7aMC45Wg0446pguAaSh))jt5J95SmSdyYHNdBCJu3yK2GYtyLyQ5kd6e4SbLapwP)P5aN9(7e3Gghx)XGsGhR0)0CGZE)DIBCJu2KrAdkpHvIPMRmOtGZguH0D5(8JKdcrX1u46pg0446pguH0D5(8JKdcrX1u46pg3iLnyK2GYtyLyQ5kd6e4SbLc4GIOaodHjeozqJJR)yqPaoOikGZqycHtg34gu8qhJ0gPGYiTbLNWkXuZvg0dqDgOHb1cgbPz9)KFKS3Z5GC4HY0gSSbL4a94gPGYGghx)XGEIukhhx)jNuIBqtkXZtGZguR)hJBK6gJ0g0446pguQsK5ugpe0JbLNWkXuZvg3iLnzK2GYtyLyQ5kd6bOod0WGcjaAyL4M8)PmYdYhkP2U1Qdjg1VxBhyR1gWCTDR1UA1HeJ63RTZyR9A6uTsKuRhjE8gHdGoc5rf6D8aWnEcRetRTBTqcGgwjUr4aOJqEuHEhpaC(a7pcsT2wB3AVO2Z)j6lEAikp0gSSbnoU(JbfYR0mdGLD9hJBKYgmsBq5jSsm1CLb9auNbAyqTGrqAibNfGdavJH0GLRTBTxulLTGrqAIbH3JaNYibduUblBqJJR)yqj9b9fNf)aAwo0X4gP6KrAdkpHvIPMRmOXX1FmONiLYXX1FYjL4g0Ks88e4Sb9qjg3iLi2iTbLNWkXuZvg0446pguCDOzchad6bOod0WG6rIhVr4aOJqEuHEhpaCJNWkX0A7wlrMtPShab2jnCDOzchGA7OwibqdRe3W1HMjCaYhy)rqQTBTxul99gPpOV4S4hqZYHonxp2RJqTDR9IAp)NOV4PHO8qBWYg0Z9tIZEaeyNyKckJBKsKAK2GYtyLyQ5kdACC9hdknWNW1FmOhG6mqdd6f1cjaAyL4wKsz67KmSSb9C)K4Shab2jgPGY4gPUgJ0guEcRetnxzqpa1zGgguDiXO(9A7m2AVMovB3A9iXJ36HhbgOJqgYR0gpHvIP12Twps84nchaDeYJk074bGB8ewjMwB3AjYCkL9aiWoPHRdnt4auBNXwRiUwjsQ1UATRwps84TE4rGb6iKH8kTXtyLyATDR9IA9iXJ3iCa0ripQqVJhaUXtyLyAT2wRej1sK5uk7bqGDsdxhAMWbOwS1cvT2AqJJR)yqH8knB9j34gPW0nsBq5jSsm1CLbnoU(JbLYqEyGocz5uiaZg0dqDgOHb1UAbmcGj9HvIRvIKA1HeJ63RTJAfPDQwBRTBT2v7f1cjaAyL4M8)PmYdYhkPwjsQvhsmQFV2oWw710PATT2U1AxTxuRhjE8gHdGoc5rf6D8aWnEcRetRvIKATRwps84nchaDeYJk074bGB8ewjMwB3AVOwibqdRe3iCa0ripQqVJhaoFG9hbPwBR1wd65(jXzpacStmsbLXnsbfMnsBq5jSsm1CLb9auNbAyqjYCkL9aiWoPHRdnt4auBNR1UATHAVS2Zpuy1BuLq(jgpZN(NjnEcRetR12A7wRoKyu)ETDgBTxtNQTBTEK4XBeoa6iKhvO3Xda34jSsmTwjsQ9IA9iXJ3iCa0ripQqVJhaUXtyLyQbnoU(JbfYR0S1NCJBKckOmsBq5jSsm1CLbnoU(JbL0h0xCw8dOzkhEVb9auNbAyqTRwpacS365i59n5JxBNR9gmxB3AjYCkL9aiWoPHRdnt4auBNR1gQ12ALiPw7QvM9gIYdTfhxHW12Twa8WipqGBK(G(IrsboNLbkbVXxlyvwMP1ARb9C)K4Shab2jgPGY4gPG6gJ0guEcRetnxzqJJR)yqjWaapugK9pJh0Hjed6bOod0WG6bqG9MR4C2)mv5A7CT30PA7wRfmcsdYRuKhG3OV4XGEUFsC2dGa7eJuqzCJuqztgPnO8ewjMAUYGghx)XGc5vA2FaGh3GEaQZanmOqcGgwjUrFNKHLRTBTEaeyV5koN9ptvU2oQ1MQTBTwWiiniVsrEaEJ(INA7wBCCfcNPV3Ge4Ykqpz)Hp91ITwImNszpacStAqcCzfONS)WN(A7wlrMtPShab2jnCDOzchGA7CT2vBNQ9YATRwrCTyAQ1JepEZfRep)izKW5gpHvIP1ABT2Aqp3pjo7bqGDIrkOmUrkOSbJ0guEcRetnxzqpa1zGggu67nibUSc0t2F4tFZ1J96iuB3ATRwps84nchaDeYJk074bGB8ewjMwB3AjYCkL9aiWoPHRdnt4auBh1cjaAyL4gUo0mHdq(a7pcsTsKul99gPpOV4S4hqZYHonxp2RJqT2AqJJR)yqX1HAXdLbg3ifuDYiTbLNWkXuZvg0dqDgOHbfapmYde4MCOJfGd7zqwMej8gFTGvzzMwB3AHeanSsCJ(ojdlxB3A9aiWEZvCo7Fw(45BWCTDuRD1E(prFXtJ0h0xCw8dOzkhEFJcdcx)P2lRv4qR1wdACC9hdkPpOV4S4hqZuo8EJBKckrSrAdkpHvIPMRmOhG6mqddkiuAMHWJ3ckL00P2oQfkmBqJJR)yqj9b9fNpGG0BCJuqjsnsBq5jSsm1CLbnoU(JbfxhAMWbWGEUFsC2dGa7eJuqzq1Xzaaw2ZkIb11J9KoWEJbvhNbayzpR44mvdNnOqzqpa1zGgguImNszpacStA46qZeoa12rTqcGgwjUHRdnt4aKpW(JGuB3ATGrqA0ayF27FyHEVblBqp9HoguOmUrkOUgJ0guEcRetnxzqJJR)yqX1HMrsXDdQoodaWYEwrmOUESN0b2B6E(prFXtdYR0S1N8gSSbvhNbayzpR44mvdNnOqzqpa1zGggulyeKgna2N9(hwO3BWY12TwibqdRe3OVtYWYg0tFOJbfkJBKckmDJ0guEcRetnxzqpa1zGgguibqdRe3OVtYWY12TwqO0mdHhVH)qyCE8Mo12rTNG4zxX5AVSwm36uTDR1UAjYCkL9aiWoPHRdnt4auBNR1gQTBTxuRhjE8gUsyW9gpHvIP1krsTezoLYEaeyN0W1HMjCaQTZ1kIRTBTEK4XB4kHb3B8ewjMwRTg0446pguCDOzRuqCJBK6gmBK2GYtyLyQ5kdACC9hdkKaxwb6j7p8P3GEaQZanmOagbWK(WkX12TwpacS3CfNZ(NPkxBh1kIRvIKATRwps84nCLWG7nEcRetRTBT03BK(G(IZIFanlh60amcGj9HvIR12ALiPwlyeKg8Gads6iKPbW(HjKgSSb9C)K4Shab2jgPGY4gPUbkJ0guEcRetnxzqpa1zGgguaJaysFyL4A7wRhab2BUIZz)ZuLRTJATHA7w7f16rIhVHRegCVXtyLyATDR1JepEtMC)0RNCsh7B8ewjMwB3AjYCkL9aiWoPHRdnt4auBh1EJbnoU(JbL0h0xCw8dOz5qhJBK6MBmsBq5jSsm1CLbnoU(JbL0h0xCw8dOz5qhd6bOod0WGcyeat6dRexB3A9aiWEZvCo7FMQCTDuRnuB3AVOwps84nCLWG7nEcRetRTBTxuRD16rIhVr4aOJqEuHEhpaCJNWkX0A7wlrMtPShab2jnCDOzchGA7OwibqdRe3W1HMjCaYhy)rqQ12A7wRD1ErTEK4XBYK7NE9Kt6yFJNWkX0ALiPw7Q1JepEtMC)0RNCsh7B8ewjMwB3AjYCkL9aiWoPHRdnt4auBNXw7n1ABT2Aqp3pjo7bqGDIrkOmUrQBSjJ0guEcRetnxzqJJR)yqX1HMjCamON7NeN9aiWoXifuguDCgaGL9SIyqD9ypPdS3yq1Xzaaw2Zkoot1Wzdkug0dqDgOHbLiZPu2dGa7KgUo0mHdqTDulKaOHvIB46qZeoa5dS)iig0tFOJbfkJBK6gBWiTbLNWkXuZvg0446pguCDOzKuC3GQJZaaSSNvedQRh7jDG9MUN)t0x80G8knB9jVblBq1Xzaaw2Zkoot1Wzdkug0tFOJbfkJBK6MozK2Gghx)XGs6d6lol(b0mLdV3GYtyLyQ5kJBK6grSrAdACC9hdkPpOV4S4hqZYHoguEcRetnxzCJBqLb85XTc3iTrkOmsBq5jSsm1CLb9auNbAyqbmEOdP2oxRnHzmBqJJR)yqLFXmil(b0mYdC1HPSXnsDJrAdkpHvIPMRmOhG6mqdd6f1AbJG0i9b9fJ8a8gSSbnoU(JbL0h0xmYdWnUrkBYiTbLNWkXuZvg0dqDgOHbvhsmQFVrze9OETDuluDYGghx)XGgGtmC2FaGh34gPSbJ0guEcRetnxzqFzdkHDdACC9hdkKaOHvInOqIemBqVXGcja5jWzdkUo0mHdq(a7pcIXns1jJ0g0446pguibUSc0t2F4tVbLNWkXuZvg34guhOJ9StmsBKckJ0guEcRetnxzqJJR)yqzC57aos5hqNyoSb9auNbAyqp)NOV4Pb5vAMbWYU(tdW4HoKA7m2AH6MALiP2Z)j6lEAqELMzaSSR)0amEOdP2oQ9grQbDcC2GY4Y3bCKYpGoXCyJBK6gJ0guEcRetnxzqJJR)yq1HCaWEyL481coghgptzi6HnOhG6mqdd65)e9fpniVsZmaw21FAagp0HuBh1cfMnOtGZguDihaShwjoFTGJXHXZugIEyJBKYMmsBq5jSsm1CLbnoU(JbfpoHfGZKEM9momrpg0dqDgOHb98FI(INgKxPzgal76pnaJh6qQTJAHcZg0jWzdkECclaNj9m7zCyIEmUrkBWiTbLNWkXuZvg0jWzdk5Htj2DDeYayR7g0Z9tIZEaeyNyKckd6bOod0WGAbJG0KFXmiRdcmr)PblxRej1ErTYaLjEJWjKS8lMbzDqGj6pg0446pguYdNsS76iKbWw3nUrQozK2GYtyLyQ5kdACC9hdkrhe4uwifun8hqYwbvGZpsgHb)r97g0dqDgOHb98FI(INgKxPzgal76pnaJh6qQTdS1cfMnOtGZguIoiWPSqkOA4pGKTcQaNFKmcd(J63nUrkrSrAdkpHvIPMRmOhG6mqddQD1ErTEK4XB9WJad0rid5vAJNWkX0ALiPwkBbJG06HhbgOJqgYR0gSCT2wB3ATRwlyeKgKxPipaVblxRej1E(prFXtdYR0mdGLD9NgGXdDi12rTqH5AT1Gghx)XGEIukhhx)jNuIBqtkXZtGZgukUq2b6yp7eJBKsKAK2GYtyLyQ5kd6bOod0WGAbJG0G8kf5b4ny5ALiPwlyeKM8lMbzDqGj6pny5ALiP2Z)j6lEAqELMzaSSR)0amEOdP2oQfkmBqJJR)yqHjCwDgNyCJBqpuIrAJuqzK2GYtyLyQ5kd6bOod0WGAbJG0G8kf5b4ny5ALiP2lQL8WjlDOTZJBfEgNPQhU(tJNWkX0A7w75)e9fpniVsZmaw21FAagp0HuBhyRfkmxRej1IOc9EgW4HoKA7CTN)t0x80G8knZayzx)Pby8qhIbnoU(Jbv(fZGSoiWe9hJBK6gJ0guEcRetnxzqJJR)yqjAINdBqpa1zGggua8WipqGBewUhgtljld(tkWdx)PXxlyvwMP12Tw7Q1dGa7nLKdkTwjsQ1dGa7nkBbJG0obX1rOb4441ARb9C)K4Shab2jgPGY4gPSjJ0guEcRetnxzqJJR)yqj6GaNYcPGQH)as2kOcC(rYim4pQF3GEaQZanmOwWiiniVsrEaEdwUwjsQ1vCU2oQfkmxB3ATR2lQ98q4jgVnQqVNrcUwBnOtGZguIoiWPSqkOA4pGKTcQaNFKmcd(J63nUrkBWiTbLNWkXuZvg0dqDgOHb9IATGrqAqELI8a8gSCTDR1UAVO2Z)j6lEAqELM9ha4XBWY1krsTxuRhjE8gKxPz)baE8gpHvIP1ABTsKuRfmcsdYRuKhG3GLRTBT2vl5Htw6qBcGhcN1bIk8GW1FA8ewjMwRej1sE4KLo0gIYjA(rYwPNqECsJNWkX0AT1Gghx)XGIeCwaoaungIXns1jJ0guEcRetnxzqJJR)yqX1Hke4mXGEaQZanmO6qIr97125AX0XCTDR1UATRwibqdRe3IuktFNKHLRTBT2v7f1E(prFXtdYR0mdGLD9NgSCTsKu7f16rIhV1dpcmqhHmKxPnEcRetR12ATTwjsQ1cgbPb5vkYdWBWY1ABTDR1UAVOwps84TE4rGb6iKH8kTXtyLyATsKulLTGrqA9WJad0rid5vAdwUwjsQ9IATGrqAqELI8a8gSCT2wB3ATR2lQ1JepEJWbqhH8Oc9oEa4gpHvIP1krsTezoLYEaeyN0W1HMjCaQTZ12PAT1GEUFsC2dGa7eJuqzCJuIyJ0guEcRetnxzqpa1zGggu7Q1UAVOwqO0mdHhVfukPblxB3AbHsZmeE8wqPKMo12rT3G5ATTwjsQfeknZq4XBbLsAagp0HuBhyRfQovRej1ccLMzi84TGsjnkmiC9NA7CTq1PATT2U1AxTwWiin5xmdY6Gat0FAWY1krsTN)t0x80KFXmiRdcmr)Pby8qhsTDGTwOWCTsKu7f1kduM4ncNqYYVygK1bbMO)uRT12Tw7Q9IA9iXJ36HhbgOJqgYR0gpHvIP1krsTu2cgbP1dpcmqhHmKxPny5ALiP2lQ1cgbPb5vkYdWBWY1ARbnoU(JbfE6)0988qcJBKsKAK2GYtyLyQ5kd6bOod0WGErTwWiiniVsrEaEdwU2U1ErTN)t0x80G8knZayzx)PblxB3AjYCkL9aiWoPHRdnt4auBh1cvTDR9IA9iXJ3iCa0ripQqVJhaUXtyLyATsKuRD1AbJG0G8kf5b4ny5A7wlrMtPShab2jnCDOzchGA7CT3uB3AVOwps84nchaDeYJk074bGB8ewjMwB3ALbmKSWH2GQb5vA26tET2wRej1AxTwWiiniVsrEaEdwU2U16rIhVr4aOJqEuHEhpaCJNWkX0AT1Gghx)XGA9)KFKS3Z5GC4HYuJBK6AmsBq5jSsm1CLbnoU(Jb9ePuooU(toPe3GMuINNaNnOoqh7zNyCJBqT(FmsBKckJ0guEcRetnxzqpa1zGgguImNszpacStA46qZeoa12zS1Atg0446pg0GC4HY0SvkiUXnsDJrAdkpHvIPMRmOhG6mqddQhab2BIvVxNRP2U1sK5uk7bqGDslihEOmnppKO2oQfQA7wlrMtPShab2jnCDOzchGA7OwOQ9YA9iXJ3iCa0ripQqVJhaUXtyLyQbnoU(JbnihEOmnppKW4g3GszKao5gPnsbLrAdACC9hdkrt8CydkpHvIPMRmUrQBmsBq5jSsm1CLb9auNbAyqTGrqAqELI8a8gSCTsKuRfmcst(fZGSoiWe9NgSSbnoU(Jbv(D9hJBKYMmsBq5jSsm1CLb9LnOe2nOXX1FmOqcGgwj2GcjsWSbL(EJ0h0xCw8dOz5qNMRh71rO2U1sFVbjWLvGEY(dF6BUESxhbdkKaKNaNnO03jzyzJBKYgmsBq5jSsm1CLb9LnOe2nOXX1FmOqcGgwj2GcjsWSbL(EJ0h0xCw8dOz5qNMRh71rO2U1sFVbjWLvGEY(dF6BUESxhHA7wl99gLH8WaDeYYPqaMBUESxhbdkKaKNaNnOrkLPVtYWYg3ivNmsBq5jSsm1CLb9LnOe2nOXX1FmOqcGgwj2GcjsWSbLiZPu2dGa7KgUo0mHdqTDu7n1EzTwWiiniVsrEaEdw2Gcja5jWzdkHdGoc5rf6D8aW5dS)iig3iLi2iTbLNWkXuZvg0x2Gsy3Gghx)XGcjaAyLydkKibZg0Z)j6lEAqELMzaSSR)0GLRTBT2v7f1ccLMzi84TGsjny5ALiPwqO0mdHhVfukPrHbHR)uBNXwluyUwjsQfeknZq4XBbLsAagp0HuBhyRfkmx7L12PAX0uRD16rIhV1dpcmqhHmKxPnEcRetRvIKAppeEIXB2FhOXuRT1ABTDR1UATRwqO0mdHhVfukPPtTDu7nyUwjsQLiZPu2dGa7KgKxPzgal76p12b2A7uT2wRej16rIhV1dpcmqhHmKxPnEcRetRvIKAppeEIXB2FhOXuRTguibipboBqL)pLrEq(qjg3iLi1iTbLNWkXuZvg0dqDgOHb1cgbPb5vkYdWBWYg0446pguefWwP)Pg3i11yK2GYtyLyQ5kd6bOod0WGAbJG0G8kf5b4nyzdACC9hdQfdimWEDemUrkmDJ0guEcRetnxzqpa1zGgguImNszpacStAjvO3jzmLWubCE8A7aBT3uRej1AxTxuliuAMHWJ3ckL0yrDL4KALiPwqO0mdHhVfukPPtTDuRiTt1ARbnoU(JbnPc9ojJPeMkGZJBCJuqHzJ0guEcRetnxzqpa1zGggulyeKgKxPipaVblBqJJR)yqJ5WeheP8jsjJBKckOmsBq5jSsm1CLbnoU(Jb9ePuooU(toPe3GMuINNaNnOhXhJBKcQBmsBq5jSsm1CLbnoU(Jbfap5446p5KsCdAsjEEcC2GIh6yCJBCdkegq0FmsDdMVbZqDdM7udkdQ4am6iqmOIi4YpWzATxtTXX1FQnPeN0kmmOYGhrtSbv01I2h0xCTycqzIxyi6AVoFyClgu71aDT3G5BWCHrHHOR9AlQZhyNP1AXipGR984wHxRflOdPvRO6CyzNu78JOM(aGJaNQnoU(dP2Fs3BfgXX1FinzaFECRWVe7TYVygKf)aAg5bU6WugAfblGXdDiD2MWmMlmIJR)qAYa(84wHFj2Bj9b9fJ8aCOveSxybJG0i9b9fJ8a8gSCHrCC9hstgWNh3k8lXEBaoXWz)baECOveS6qIr97nkJOh17aQovyehx)H0Kb85XTc)sS3cjaAyLyONaNXIRdnt4aKpW(JGa9lJLWo0qIemJ9McJ446pKMmGppUv4xI9wibUSc0t2F4tFHrHHORftEx)Huyehx)HGLOjEoCHrCC9hcw531FGwrWAbJG0G8kf5b4nyzjsSGrqAYVygK1bbMO)0GLlmIJR)qUe7TqcGgwjg6jWzS03jzyzOFzSe2HgsKGzS03BK(G(IZIFanlh60C9yVocDPV3Ge4Ykqpz)Hp9nxp2RJqHrCC9hYLyVfsa0WkXqpboJnsPm9Dsgwg6xglHDOHejygl99gPpOV4S4hqZYHonxp2RJqx67nibUSc0t2F4tFZ1J96i0L(EJYqEyGocz5uiaZnxp2RJqHHORf1dGxlmrhHAr5aOJqTsPc9oEa4AdVwB6YA9aiWoP2huRnCzTksT3F4AdaxRo1kYVsrEaEHrCC9hYLyVfsa0WkXqpboJLWbqhH8Oc9oEa48b2FeeOFzSe2HgsKGzSezoLYEaeyN0W1HMjCa64MlTGrqAqELI8a8gSCHHOR1M)prFXtTyY)PAf5aOHvIHUwrGW0A9Vw5)t1AXipGRnoUcjCDeQfYRuKhG3Q1MHbaE809AHjmTw)R98Jd(uTI75Pw)RnoUcjCUwiVsrEaETIvVVwDopUoc1gukPvyehx)HCj2BHeanSsm0tGZyL)pLrEq(qjq)YyjSdnKibZyp)NOV4Pb5vAMbWYU(tdwURDxacLMzi84TGsjnyzjsaHsZmeE8wqPKgfgeU(tNXcfMLibeknZq4XBbLsAagp0H0bwOW8LDctJDEK4XB9WJad0rid5vAJNWkXujsopeEIXB2FhOXyRTDTZoqO0mdHhVfukPPth3GzjsiYCkL9aiWoPb5vAMbWYU(thy7KTsK4rIhV1dpcmqhHmKxPnEcRetLi58q4jgVz)DGgJTfgXX1FixI9wefWwP)PqRiyTGrqAqELI8a8gSCHrCC9hYLyV1IbegyVocqRiyTGrqAqELI8a8gSCHHORveiCT24QqVJPsQfdyQaopETksTEpd4Adax7n1(GAXFaxRhab2jqx7dQnOusTbGhmvVwICiE0rOwKhul(d4A9(yQvK2jsRWioU(d5sS3MuHENKXuctfW5XHwrWsK5uk7bqGDslPc9ojJPeMkGZJ3b2BKiXUlaHsZmeE8wqPKglQReNirciuAMHWJ3ckL00PdrANSTWioU(d5sS3gZHjois5tKsqRiyTGrqAqELI8a8gSCHrCC9hYLyV9ePuooU(toPeh6jWzShXNcJ446pKlXElaEYXX1FYjL4qpboJfp0PWOWq01kQWeB8A9VwycxR4EEQ9Q)NAFKA9EUwrf5WdLP1QKAJJRq4cJ446pKM1)d2GC4HY0Svkio0kcwImNszpacStA46qZeoaDgRnvyehx)H0S(FUe7Tb5WdLP55HeqRiy9aiWEtS696CnDjYCkL9aiWoPfKdpuMMNhs0buDjYCkL9aiWoPHRdnt4a0bux6rIhVr4aOJqEuHEhpaCJNWkX0cJcdrxRnFDsHHORveiCTyYlMb1kImiWe9NAfREFTI8RuKhG3Q1g7t0ArEqTI8RuKhGx75XzsTpcsTN)t0x8uRo169CTdlQ71cfMRLWNFOKAFVNbIvcxlmHR9NAp0AHNeti169CTycNcHNuR0Gq9AT5h3k8Afjmv9W1FQvj16rIhNPqx7dQvrQ17zaxRynLQDEVwlU2yEVNb1kYVsR9AdGLD9NA9ELulIk07TcJ446pK2HsWk)IzqwheyI(d0kcwlyeKgKxPipaVbllrYfKhozPdTDECRWZ4mv9W1FA8ewjM298FI(INgKxPzgal76pnaJh6q6aluywIeevO3Zagp0H05Z)j6lEAqELMzaSSR)0amEOdPWq01kceUwunXZHR9NAT5RxR)1kd(tTOSCpmMwmvsTyc4pPapC9NwHrCC9hs7qjxI9wIM45WqFUFsC2dGa7eSqbTIGfapmYde4gHL7HX0sYYG)Kc8W1FA81cwLLzAx78aiWEtj5GsLiXdGa7nkBbJG0obX1rOb4442wyi6Afbcx7vbvGRvhIs5AFKAfzBuTipOwVNRfrbeVwycx7dQ9NAT5RxBG4mOwVNRfrbeVwyc3QvuOEFTsPc9ET2OGRT)t0ArEqTISnQvyehx)H0ouYLyVfMWz1zCONaNXs0bboLfsbvd)bKSvqf48JKryWFu)o0kcwlyeKgKxPipaVbllrIR4ChqH5U2DX5HWtmEBuHEpJeSTfgIUwrGW1AJcUwrTWbGQXqQ9NAT5Rx7d7eLY1(i1kYVsrEaERwrGW1AJcUwrTWbGQXqj1QtTI8RuKhGxRIu79hU2(acxlREpdQvul4HW1kImquHheU(tTpOwBKYjATpsTxLEc5XjTcJ446pK2HsUe7TibNfGdavJHaTIG9clyeKgKxPipaVbl31Ulo)NOV4Pb5vA2FaGhVbllrYfEK4XBqELM9ha4XB8ewjMARejwWiiniVsrEaEdwURDKhozPdTjaEiCwhiQWdcx)PXtyLyQejKhozPdTHOCIMFKSv6jKhN04jSsm12cdrxRiq4Afj6qfcCMuR4EEQnsPATPAV(lnP2aW1cldDTpO27pCTbGRvNAf5xPipaVv71EiWaUwBm4rGb6iuRi)kTwLuBCCfcx7p169CTEaeyVwfPwps84mTvlQ)Y1ct0rO2WRTtxwRhab2j1kw9(Ar5aOJqTsPc9oEa4wHrCC9hs7qjxI9wCDOcbotG(C)K4Shab2jyHcAfbRoKyu)ENX0XCx7Sdsa0WkXTiLY03jzy5U2DX5)e9fpniVsZmaw21FAWYsKCHhjE8wp8iWaDeYqEL24jSsm1wBLiXcgbPb5vkYdWBWY221Ul8iXJ36HhbgOJqgYR0gpHvIPsKqzlyeKwp8iWaDeYqEL2GLLi5clyeKgKxPipaVblBBx7UWJepEJWbqhH8Oc9oEa4gpHvIPsKqK5uk7bqGDsdxhAMWbOZDY2cdrxRiq4AfHP)t3RvQhsu7p1AZxh6A7)evhHATakJKUxR)1kouVwKhuR8lMb1Qdcmr)P2huBqP1sKdXdPvyehx)H0ouYLyVfE6)0988qcOveS2z3fGqPzgcpElOusdwUliuAMHWJ3ckL00PJBWSTsKacLMzi84TGsjnaJh6q6aluDsIeqO0mdHhVfukPrHbHR)0zO6KTDTZcgbPj)IzqwheyI(tdwwIKZ)j6lEAYVygK1bbMO)0amEOdPdSqHzjsUqgOmXBeoHKLFXmiRdcmr)X2U2DHhjE8wp8iWaDeYqEL24jSsmvIekBbJG06HhbgOJqgYR0gSSejxybJG0G8kf5b4nyzBlmeDTIaHR9NAT5RxRfSxRmqFG6kHRfMOJqTI8R0AV2ayzx)PwefqCORvrQfMW0A1HOuU2hPwr2gv7p1IkDTWeU2aXzqTrTqELA9jVwKhu75)e9fp1Yii6r55CV2yO1I8GA7HhbgOJqTqELwlSSR4CTksTEK4XzARWioU(dPDOKlXER1)t(rYEpNdYHhktHwrWEHfmcsdYRuKhG3GL7EX5)e9fpniVsZmaw21FAWYDjYCkL9aiWoPHRdnt4a0buDVWJepEJWbqhH8Oc9oEa4gpHvIPsKyNfmcsdYRuKhG3GL7sK5uk7bqGDsdxhAMWbOZ309cps84nchaDeYJk074bGB8ewjM2vgWqYchAdQgKxPzRp52krIDwWiiniVsrEaEdwURhjE8gHdGoc5rf6D8aWnEcRetTTWioU(dPDOKlXE7jsPCCC9NCsjo0tGZyDGo2ZoPWOWq01AZbXRvu0RjUwBoiUoc1ghx)H0QfL9AdV2EvONb1kd0hO(9A9Vws)d8Apk4aRET64maal71E(HQU(dP2FQvKOdTwuoa3AJsX9cdrxRiq4Ar5aOJqTsPc9oEa4AvKAV)W1kwtPA7vVwEEyH(A9aiWoP2yO1IjVyguRiYGat0FQngATI8RuKhGxBa4AN3RfWb9o01(GA9VwaJaysFTOIcrjMu7p16I)AFqT4pGR1dGa7KwHrCC9hs7i(GLWbqhH8Oc9oEayOHjCwCVM48jiUocyHc6Z9tIZEaeyNGfkOveS2bjaAyL4gHdGoc5rf6D8aW5dS)iiDVasa0WkXn5)tzKhKpuITsKyh99gPpOV4S4hqZYHonaJaysFyL4UezoLYEaeyN0W1HMjCa6akBlmeDTO9pWR1MvWbw9Ar5aOJqTsPc9oEa4Ap)qvx)Pw)R1EMLRfvuikXKAHLRvNAfv)1UWioU(dPDeFUe7Teoa6iKhvO3XdadnmHZI71eNpbX1raluqFUFsC2dGa7eSqbTIG1JepEJWbqhH8Oc9oEa4gpHvIPDPV3i9b9fNf)aAwo0Pbyeat6dRe3LiZPu2dGa7KgUo0mHdqh3uyi6A)jDpFeFQfpSNj169CTXX1FQ9N09AHjHvIRLcd0rO2tFmdN0rO2yO1oVxBqQnQfWcWPauBCC9NwHrCC9hs7i(Cj2BX1HMTsbXH(N098r8blufgfgXX1FinkUq2b6yp7eSWeoRoJd9e4mwAaSh))jt5J95SmSdyYHNdxyehx)H0O4czhOJ9StUe7TWeoRoJd9e4mwc8yL(NMdC27Vt8cJ446pKgfxi7aDSNDYLyVfMWz1zCONaNXkKUl3NFKCqikUMcx)PWioU(dPrXfYoqh7zNCj2BHjCwDgh6jWzSuahuefWzimHWPcJcdrxRij0PwrfMyJdDTK(horR98qyqTrkvligbMu7JuRhab2j1gdTwYHNaOpPWioU(dPHh6Cj2BprkLJJR)KtkXHEcCgR1)d0ehOhhluqRiyTGrqAw)p5hj79CoihEOmTblxyehx)H0WdDUe7TuLiZPmEiONcdrxRiq4Af5xP1ETbWYU(tT)u75)e9fp1k)FshHAdV2eheVwBaZ1Qdjg1VxRfSx78ETksT3F4AfRPuTpegCc5A1HeJ63RvNAfzBuRwrsypxlbgW1s6d6lgr5HElUoulEOmOwLu7p1E(prFXtTwmYd4Af5RDRWioU(dPHh6GfYR0mdGLD9hOveSqcGgwjUj)FkJ8G8Hs6Qdjg1V3bwBaZDTthsmQFVZyVMojrIhjE8gHdGoc5rf6D8aWnEcRet7cjaAyL4gHdGoc5rf6D8aW5dS)ii229IZ)j6lEAikp0gSCHHORvKe2Z1sGbCT3F4ALH9AHLRfvuikXKAfvOIkmP2FQ175A9aiWETksTIcq49iWPATrbduUwLmyQETXXviCRWioU(dPHh6Cj2Bj9b9fNf)aAwo0bAfbRfmcsdj4SaCaOAmKgSC3lOSfmcstmi8Ee4ugjyGYny5cJ446pKgEOZLyV9ePuooU(toPeh6jWzShkPWq01AJPc91Ija9bQFVwrIo0Ar5auBCC9NA9VwaJaysFTx)LMuRy17RLWbqhH8Oc9oEa4cJ446pKgEOZLyVfxhAMWba6Z9tIZEaeyNGfkOveSEK4XBeoa6iKhvO3Xda34jSsmTlrMtPShab2jnCDOzchGoGeanSsCdxhAMWbiFG9hbP7f03BK(G(IZIFanlh60C9yVocDV48FI(INgIYdTblxyi6AXeaJWGA9Vwycx71d8jC9NAfvOIkmPwfP2yUx71FPRvj1oVxlSCRWioU(dPHh6Cj2BPb(eU(d0N7NeN9aiWobluqRiyVasa0WkXTiLY03jzy5cdrxRiq4Af5xP1E1N8AdV2EvONb1kd0hO(9AfREFT2yWJad0rOwr(vATWY16FT2qTEaeyNaDTpO237zqTEK4Xj1(tTOs3kmIJR)qA4HoxI9wiVsZwFYHwrWQdjg1V3zSxtN66rIhV1dpcmqhHmKxPnEcRet76rIhVr4aOJqEuHEhpaCJNWkX0UezoLYEaeyN0W1HMjCa6mwrSej2zNhjE8wp8iWaDeYqEL24jSsmT7fEK4XBeoa6iKhvO3Xda34jSsm1wjsiYCkL9aiWoPHRdnt4aGfkBlmeDTx)hmvVwycx71zipmqhHAXKuiaZ1Qi1E)HR9etTcSxRo(xRi)kf5b41QdX5GcDTpOwfPwuoa6iuRuQqVJhaUwLuRhjECMwBm0AfRPuT9QxlppSqFTEaeyN0kmIJR)qA4HoxI9wkd5Hb6iKLtHamd95(jXzpacStWcf0kcw7amcGj9HvILirhsmQFVdrANSTRDxajaAyL4M8)PmYdYhkrIeDiXO(9oWEnDY2U2DHhjE8gHdGoc5rf6D8aWnEcRetLiXops84nchaDeYJk074bGB8ewjM29cibqdRe3iCa0ripQqVJhaoFG9hbXwBlmeDTIaHRvKVQ2FQ1MVETksT3F4AP)GP61omtR1)ApbXR96mKhgOJqTyskeGzORngATEpd4AdaxBIjKA9(yQ1gQ1dGa7KAFyVw76uTIvVV2Zpuy1TTvyehx)H0WdDUe7TqELMT(KdTIGLiZPu2dGa7KgUo0mHdqNTZgU88dfw9gvjKFIXZ8P)zsJNWkXuB7Qdjg1V3zSxtN66rIhVr4aOJqEuHEhpaCJNWkXujsUWJepEJWbqhH8Oc9oEa4gpHvIPfgIUwrGW1I2h0xCTIIhqfL1EDo8(AvKA9EUwpacSxRsQnSEyVw)RLQCTpO27pCT9beUw0(G(IrsboxlMaucET81cwLLzATIvVVwrIoulEOmO2hulAFqFXikp0AJJRq4wHrCC9hsdp05sS3s6d6lol(b0mLdVh6Z9tIZEaeyNGfkOveS25bqG9wphjVVjF8oFdM7sK5uk7bqGDsdxhAMWbOZ2GTsKyNm7neLhAloUcH7cGhg5bcCJ0h0xmskW5Smqj4n(AbRYYm12cdrxRiq4ArHbaEOmOw)RvKe0HjKA)P2OwpacSxR3hETkPwHxhHA9VwQY1gETEpxlqf69ADfNBfgXX1Fin8qNlXElbga4HYGS)z8GomHa95(jXzpacStWcf0kcwpacS3CfNZ(NPk35B6uxlyeKgKxPipaVrFXtHHORveiCTI8R0AL(baE8A)jDVwfPwurHOetQngATIS01gaU244keU2yO169CTEaeyVwX)GP61svUwkmqhHA9EU2tFmdNAfgXX1Fin8qNlXElKxPz)baECOp3pjo7bqGDcwOGwrWcjaAyL4g9DsgwURhab2BUIZz)ZuL7WM6AbJG0G8kf5b4n6lE6ghxHWz67nibUSc0t2F4tpwImNszpacStAqcCzfONS)WN(UezoLYEaeyN0W1HMjCa6SDD6s7eXyA8iXJ3CXkXZpsgjCUXtyLyQT2wyehx)H0WdDUe7T46qT4HYaOveS03BqcCzfONS)WN(MRh71rORDEK4XBeoa6iKhvO3Xda34jSsmTlrMtPShab2jnCDOzchGoGeanSsCdxhAMWbiFG9hbrIe67nsFqFXzXpGMLdDAUESxhbBlmeDTIaHRfvuikVETIvVVwmj0XcWH9mOwmHej8AHNeti169CTEaeyVwXAkvRfxRfNEX1EdMXuyTwmYd4A9EU2Z)j6lEQ984mPwR4yFHrCC9hsdp05sS3s6d6lol(b0mLdVhAfblaEyKhiWn5qhlah2ZGSmjs4n(AbRYYmTlKaOHvIB03jzy5UEaeyV5koN9plF88nyUd7o)NOV4Pr6d6lol(b0mLdVVrHbHR)CPWHABHHORveiCTO9b9fxRndcsFT)uRnF9AHNeti169mGRnaCTbLsQvNZJRJqRWioU(dPHh6Cj2Bj9b9fNpGG0dTIGfeknZq4XBbLsA60buyUWq01kceUwrIo0Ar5auR)1E(HaJZ1E9ayFTs3)Wc9oPwzWFi1(tTIkr0RDRwPfrVUiAT28pikaVwLuR3RKAvsTrT9QqpdQvgOpq97169XulGPV76iu7p1kQerV21cpjMqQLga7R17FyHENuRsQnSEyVw)R1vCU2h2lmIJR)qA4HoxI9wCDOzchaOp3pjo7bqGDcwOGwrWsK5uk7bqGDsdxhAMWbOdibqdRe3W1HMjCaYhy)rq6AbJG0ObW(S3)Wc9Edwg6tFOdwOGwhNbayzpR44mvdNXcf064maal7zfbRRh7jDG9McdrxRiq4Afj6qR1gLI716FTNFiW4CTxpa2xR09pSqVtQvg8hsT)ulQ0TALwe96IO1AZ)GOa8AvKA9ELuRsQnQTxf6zqTYa9bQFVwVpMAbm9DxhHAHNeti1sdG9169pSqVtQvj1gwpSxR)16kox7d7fgXX1Fin8qNlXElUo0mskUdTIG1cgbPrdG9zV)Hf69gSCxibqdRe3OVtYWYqF6dDWcf064maal7zfhNPA4mwOGwhNbayzpRiyD9ypPdS3098FI(INgKxPzRp5ny5cdrxRiq4Afj6qR9Quq8AvKAV)W1s)bt1RDyMwR)1cyeat6R96V0KwTO(lx7jiUoc1gET2qTpOw8hW16bqGDsTIvVVwuoa6iuRuQqVJhaUwps84mTvyehx)H0WdDUe7T46qZwPG4qRiyHeanSsCJ(ojdl3feknZq4XB4pegNhVPthNG4zxX5lXCRtDTJiZPu2dGa7KgUo0mHdqNTHUx4rIhVHRegCVXtyLyQejezoLYEaeyN0W1HMjCa6SiURhjE8gUsyW9gpHvIP2wyehx)H0WdDUe7TqcCzfONS)WNEOp3pjo7bqGDcwOGwrWcyeat6dRe31dGa7nxX5S)zQYDiILiXops84nCLWG7nEcRet7sFVr6d6lol(b0SCOtdWiaM0hwj2wjsSGrqAWdcmiPJqMga7hMqAWYfgIUwuz(OrQ2Zpu11FQ1)Aj(lx7jiUoc1IkkeLysT)u7JGiQXdGa7KAf3ZtTiQqVRJqT2uTpOw8hW1s84yptRf)Ti1gdTwyIoc1IjK7NE9uRnUo2xBm0ALsev6AfjkHb3BfgXX1Fin8qNlXElPpOV4S4hqZYHoqRiybmcGj9HvI76bqG9MR4C2)mv5oSHUx4rIhVHRegCVXtyLyAxps84nzY9tVEYjDSVXtyLyAxImNszpacStA46qZeoaDCtHHORftrmlxlQOquIj1clx7p1gKAXJ5ETEaeyNuBqQv(je1kXqxllQFyzVwX98ulIk076iuRnv7dQf)bCTepo2Z0AXFlsTIvVVwmHC)0RNATX1X(wHrCC9hsdp05sS3s6d6lol(b0SCOd0N7NeN9aiWobluqRiybmcGj9HvI76bqG9MR4C2)mv5oSHUx4rIhVHRegCVXtyLyA3lSZJepEJWbqhH8Oc9oEa4gpHvIPDjYCkL9aiWoPHRdnt4a0bKaOHvIB46qZeoa5dS)ii221Ul8iXJ3Kj3p96jN0X(gpHvIPsKyNhjE8Mm5(Pxp5Ko234jSsmTlrMtPShab2jnCDOzchGoJ9gBTTWioU(dPHh6Cj2BX1HMjCaG(C)K4Shab2jyHcAfblrMtPShab2jnCDOzchGoGeanSsCdxhAMWbiFG9hbb6tFOdwOGwhNbayzpR44mvdNXcf064maal7zfbRRh7jDG9McJ446pKgEOZLyVfxhAgjf3H(0h6GfkO1Xzaaw2Zkoot1WzSqbToodaWYEwrW66XEshyVP75)e9fpniVsZwFYBWYfgIUwrGW1IkkeLxV2GuBkiETaM8aVwfP2FQ175AXFiCHrCC9hsdp05sS3s6d6lol(b0mLdVVWq01kceUwurHOetQni1McIxlGjpWRvrQ9NA9EUw8hcxBm0ArffIYRxRsQ9NAT5Rxyehx)H0WdDUe7TK(G(IZIFanlh6uyuyi6Afbcx7p1AZxVwrfQOctQ1)AfyV2R)sxRRh71rO2yO1YI6YkGR1)At6W1clxRf7odQvS691kYVsrEaEHrCC9hsZb6yp7eSWeoRoJd9e4mwgx(oGJu(b0jMddTIG98FI(INgKxPzgal76pnaJh6q6mwOUrIKZ)j6lEAqELMzaSSR)0amEOdPJBePfgIUw07ZPwremfF9AfREFTI8RuKhGxyehx)H0CGo2Zo5sS3ct4S6mo0tGZy1HCaWEyL481coghgptzi6HHwrWE(prFXtdYR0mdGLD9NgGXdDiDafMlmeDTO3NtTO9m71ksGj6PwXQ3xRi)kf5b4fgXX1FinhOJ9StUe7TWeoRoJd9e4mw84ewaot6z2Z4We9aTIG98FI(INgKxPzgal76pnaJh6q6akmxyi6ArVpNAXuaS19AfREFTyYlMb1kImiWe9NAHjHadDT4H9CTeyaxR)1sgvMR175AtVyM41AJHj16bqG9cJ446pKMd0XE2jxI9wycNvNXHEcCgl5Htj2DDeYayR7qRiyTGrqAYVygK1bbMO)0GLLi5czGYeVr4esw(fZGSoiWe9hOp3pjo7bqGDcwOkmeDTIaHR9QGkW1QdrPCTpsTISnQwKhuR3Z1IOaIxlmHR9b1(tT281RnqCguR3Z1IOaIxlmHB1I2)aV2JcoWQxRIulKxP1Yayzx)P2Z)j6lEQvj1cfMj1(GAXFaxBioU3kmIJR)qAoqh7zNCj2BHjCwDgh6jWzSeDqGtzHuq1WFajBfubo)izeg8h1VdTIG98FI(INgKxPzgal76pnaJh6q6aluyUWq01kceU2Ks8AFKA)rudmHRLg4HaxRd0XE2j1(t6ETksT2yWJad0rOwr(vATxNTGrqQvj1ghxHWqx7dQ9(dxBa4AN3R1JepotRvh)Rv9wHrCC9hsZb6yp7KlXE7jsPCCC9NCsjo0tGZyP4czhOJ9StGwrWA3fEK4XB9WJad0rid5vAJNWkXujsOSfmcsRhEeyGocziVsBWY221olyeKgKxPipaVbllrY5)e9fpniVsZmaw21FAagp0H0buy22cdrx71zKao51IePKvCSVwKhulmjSsCTQZ4erzTIaHR9NAp)NOV4PwDQ9buguR19ADGo2ZETK07TcJ446pKMd0XE2jxI9wycNvNXjqRiyTGrqAqELI8a8gSSejwWiin5xmdY6Gat0FAWYsKC(prFXtdYR0mdGLD9NgGXdDiDafMnOez(yK6MoDng34gda]] )


end
