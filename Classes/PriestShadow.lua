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
                        power = power + 15 * min( debuff.shadow_word_pain.remains, 8 ) / 8
                        if debuff.shadow_word_pain.remains < 8 then removeDebuff( "shadow_word_pain" )
                        else debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires - 8 end
                    end
                    if debuff.vampiric_touch.up then
                        power = power + 15 * min( debuff.vampiric_touch.remains, 8 ) / 8
                        if debuff.vampiric_touch.remains <= 8 then removeDebuff( "vampiric_touch" )
                        else debuff.vampiric_touch.expires = debuff.vampiric_touch.expires - 8 end
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

        potion = "potion_of_spectral_intellect",

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


    spec:RegisterPack( "Shadow", 20210310, [[defT)bqiqHhjbCjkPa2KQsFcucJsjLtPK0Quvf6vQQQzrjClvfi7sP(fLeddLQogkLLbk1ZKiPPHsfxtjrBtIe(gOenokPOZjrISoLeAEQk09Kq7tvr)JskuhuvbTqqrpeustKsQUikvQnQQk5JsKOgPQQGtIsLSskrVKskKzQQkLBsjL2PsQ(PQcyOus6OusbAPQkq5POyQsexvIuBvc0xvsWEvXFvLbt6WIwSs8yvAYO6YeBgkFMcJMsDAQwnLuqVwcA2s62q1UL63kgofDCvvrlh45qMUW1bz7GQVJsgVQQuDEvvwVQcunFjQ9J8HTtjhgEgYzDyZEyZg7lv2y)M9LsSdSK9WYdt8ZuomM5TW0qomDIlhgg7KpSomM5V6K8tjhg0abUYHXoct0kAfRy4Hn0Y(o4wb54q1m8PVGelScYXVw5WSa51GD1NLddpd5SoSzpSzJ9LkBSFZ(sj2bwY(vEysOWEahgghhwpm2oNl9z5WWf09WWyN8HfPwf4ckilT2eCTjLn2BbPWM9WMnYsYYsyjzHKwWX5KwYaashKYYwAsJeyibP3bQdePjqifBaxHVpmvhfOtjhg807tjN1z7uYHr6CPk8dmpmxGhcWZdZceg2EzM(nyVWwEj6knx4BiZddka(noRZ2HjVHp9H5M16lVHp9R6O4WuDu86exomlZ0N4SoSpLCyYB4tFy4oYuQp80WVhgPZLQWpW8eN1l1tjhgPZLQWpW8WK3WN(WaFC(taqMHp9HHlOlWndF6dtPrcPfCCoPSBaKz4tt60KENPYhwnPMZu92G0miTkjkiLDypPEJY2JFKUafK2tqQJr6VbIuwETs6axa30KuVrz7Xps9M0c(xBsT2SqHueeqifzN8HfMln3k4EZxKMlasZMtQ16nNuywtuqQJiDAsVZu5dRM0fbBacPfKDVjLDz0dqi1CMQ3gKceua8B4tJi1Xifc5TbPm2jFyHvtCHuRcCeoPzZjfMsZfaPoI0bk2hMlWdb45HbEc8CPkBZzQpSb8UCePFjDns9gLTh)i9ZIKYoSN0YLj1uInMlnFN3WHlK(LuaulydWq2i7KpSWQjU8mbocFl)jKBAkCs)skmi9otLpS6nU383snrXgYK0VKcdsVZu5dREJSt(W6XAa8hxYWEdzs6QK(L01i1Bu2E8J0pwKuR5kjTCzsJSkDSrsc8241UHDGNazlDUufoPFjfEc8CPkBKKaVnETByh4jqExOyWWiDvs)skmi9otLpS6nMlnFdzs6xsxJuyq6DMkFy1BCV5VLAIInKjPLltkYuQ1xKadjqBCV5pKKas)Kuyt6QN4So7Ck5WiDUuf(bMhM8g(0hgKDYhwpwdG)mtVpmCbDbUz4tFyS2SqHueeqi93arQjuqkKjPmRWkAvs)qMp0QKonPHTqAKadji1XiDfazyJbvj9Vsb4cPoQHfbP5nC4cPSSLMum3Wo82Gu2(GkvsJeyibAFyUapeGNhMfimSnwkpdOeW9SrBits)skmiLllqyyBwGmSXGQpSuaUSHmj9lPitPwFrcmKaTX9M)qsci9JKYoN4S(kpLCyKoxQc)aZdtEdF6dZnR1xEdF6x1rXHP6O41jUCyUC0joRxkoLCyKoxQc)aZdtEdF6ddU38hssWH5(7wLxKadjqN1z7WCbEiappmrwLo2ijbEB8A3WoWtGSLoxQcN0VKImLA9fjWqc0g3B(djjG0pjfEc8CPkBCV5pKKG3fkgmms)skmiLpXgzN8H1J1a4pZ07D43c92G0VKcdsVZu5dREJ5sZ3qMhgUGUa3m8Ppm)b3WMuRc8b4XpsTwV5KYijG08g(0KgdPabdiiBsT(ucIuwEytkssG3gV2nSd8eiN4SoS8uYHr6CPk8dmpm5n8Ppm8eVZWN(WC)DRYlsGHeOZ6SDyUapeGNhgyqk8e45sv2zT(4tGEqMhgUGUa3m8PpmwfiycG0yifcjKA9eVZWNM0pK5dTkPogPz)JuRpLqQJiTNGuiZ9joRBnpLCyKoxQc)aZdtEdF6ddU383snrXHHlOlWndF6dd7Qrr2r9hPitP5KMKI7nN0LAIcsV2jWqinXcbqk8X5ltni1Xifc5TbPi7KpSWQjUqQjWr4KMnNuCV5l1efistGq6nnnf((WCbEiappm3zQ8HvVX9M)wQjk2x7eyiis)Ku2i9lPMsSXCP578goCH0VKcGAbBagYgzN8HfwnXLNjWr4B5pHCttHt6xsHbP3zQ8HvVHpo)Tm1ydzEIZ6LsNsomsNlvHFG5HjVHp9Hb(483YuJddxqxGBg(0hMsJesl44CsH5udsZGuB3WwaKAc8b4Xpsz5HnP)bO2qaEBqAbhNtkKjPXqk7qAKadjqwq6aiDcBbqAKvPdePttktj7dZf4Ha88W4nkBp(r6hlsQ1CLK(L0iRshBBO2qaEB8GpoFlDUufoPFjnYQ0XgjjWBJx7g2bEcKT05sv4K(LuKPuRVibgsG24EZFijbK(XIKwkiTCzsxJ01inYQ0X2gQneG3gp4JZ3sNlvHt6xsHbPrwLo2ijbEB8A3WoWtGSLoxQcN0vjTCzsrMsT(IeyibAJ7n)HKeqArszJ0vpXzD2y)PKdJ05sv4hyEyYB4tFy4c8bc4TXZSMgqYHHlOlWndF6dJ1NgweKcHesTUaFGaEBqQvRPbKqQJr6VbI0B2KAibPEhdPfCCo2aWj1Buij3cshaPogPmsc82G01Dd7apbcPoI0iRshcN0S5KYYRvsT9GuPhidBsJeyibAFyUapeGNhM1ifiyabzNlvH0YLj1Bu2E8J0pjfwUssxL0VKUgPWGu4jWZLQSnNP(WgW7YrKwUmPEJY2JFK(zrsTMRK0vj9lPRrkminYQ0XgjjWBJx7g2bEcKT05sv4KwUmPRrAKvPJnssG3gV2nSd8eiBPZLQWj9lPWGu4jWZLQSrsc8241UHDGNa5DHIbdJ0vjD1tCwNn2oLCyKoxQc)aZdtEdF6dd8X5VLPghgUGUa3m8PpmLgjKwqys60KcRwNuhJ0FdeP8PHfbPTiCsJH0BIcsTUaFGaEBqQvRPbKybPzZjnSfGqAcesRccrAyNnPSdPrcmKar6afKU2kjLLh2KENMd5XQ7dZf4Ha88WGmLA9fjWqc0g3B(djjG0ps6AKYoK(pP3P5qES5ocnD2XtU2JG2sNlvHt6QK(LuVrz7Xps)yrsTMRK0VKgzv6yJKe4TXRDd7apbYw6CPkCslxMuyqAKvPJnssG3gV2nSd8eiBPZLQWpXzD2G9PKdJ05sv4hyEyYB4tFyq2jFy9yna(JlzyFyU)Uv5fjWqc0zD2omxGhcWZdZAKgjWqITTK1WEBEds)iPWM9K(LuKPuRVibgsG24EZFijbK(rszhsxL0YLjDnsnLyJ5sZ35nC4cPFjfa1c2amKnYo5dlSAIlptGJW3YFc5MMcN0vpmCbDbUz4tFyknsiLXo5dlsxHbWxrsTUKHnPogPHTqAKadji1rKMlduqAmKYDH0bq6VbIu7eUqkJDYhwy1exi1QahHtQ8NqUPPWjLLh2KATEZxKMlashaPm2jFyH5sZjnVHdx2N4SoBL6PKdJ05sv4hyEyYB4tFyqqaG0Cb8I5HN8wqOdZ93TkVibgsGoRZ2H5c8qaEEyIeyiXoCC5fZJ7cPFKuyVss)s6ceg2g(4CSbGV5dR(WWf0f4MHp9HP0iHugiaqAUaingsT2K3ccr60KMKgjWqcsd7mi1rKAmEBqAmKYDH0minSfsbUHDqA44Y(eN1zJDoLCyKoxQc)aZdtEdF6dd8X5VyaaPJdZ93TkVibgsGoRZ2H5c8qaEEyGNapxQYMpb6bzs6xsJeyiXoCC5fZJ7cPFsAPs6xsxJ0fimSn8X5ydaFZhwnPLlt6ceg2g(4CSbGVbcE6nI0ps6DMkFy1B4JZFltn2abp9gr6QK(L08goC5XNydpXnDGFFXaDTjTiPitPwFrcmKaTHN4MoWVVyGU2K(LuKPuRVibgsG24EZFijbK(rsxJ0vs6)KUgPLcs)JKgzv6yhSCu8gShwgYw6CPkCsxL0vpmCbDbUz4tFyknsiTGJZjTKbaKoiD66psDmszwHv0QKMnN0cwcPjqinVHdxinBoPHTqAKadjiL10WIGuUlKYHaEBqAylKETZUL6(eN1zBLNsomsNlvHFG5H5c8qaEEy4tSHN4MoWVVyGU27WVf6TbPFjDnsJSkDSrsc8241UHDGNazlDUufoPFjfzk16lsGHeOnU38hssaPFsk8e45sv24EZFijbVlumyyKwUmP8j2i7KpSESga)zMEVd)wO3gKUkPFjDnsHbPaOwWgGHSr2jFyHvtC5zcCe(w(ti30u4KwUmP5nC4YJpXgEIB6a)(Ib6AtArsrMsT(IeyibAdpXnDGFFXaDTjD1dtEdF6ddU38fP5c4eN1zRuCk5WiDUuf(bMhM8g(0hgKDYhwpwdG)4sg2hgUGUa3m8PpmLgjKYScRO1jLLh2KA107fGKfkasTkkR4Kc1vbHinSfsJeyibPS8AL0fH0fPoSif2S3AasxeSbiKg2cP3zQ8Hvt6DWfePl5TWdZf4Ha88WaGAbBagY2m9EbizHc4zIYk(w(ti30u4K(Lu4jWZLQS5tGEqMK(L0ibgsSdhxEX8mVXd2SN0pjDnsVZu5dREJSt(W6XAa8hxYWEZHaz4tt6)KAC5KU6joRZgS8uYHr6CPk8dmpm5n8Ppmi7KpSExqISpmCbDbUz4tFyknsiLXo5dlsHvqISjDAsHvRtkuxfeI0WwacPjqin5CePEFhCVn2hMlWdb45HbKo)jWLo2jNJ2Et6NKYg7pXzD2SMNsomsNlvHFG5H5c8qaEEyqMsT(IeyibAJ7n)HKeq6NKcpbEUuLnU38hssW7cfdggPFjDbcdBZtqHVWEGmSJnK5HHlOlWndF6dtPrcPwR3CszKeqAmKENgbHlKA9euiPLypqg2bIutWCrKonPF4hGDVjTKpG1)aKcRtJ5aCsDePHTJi1rKMKA7g2cGutGpap(rAyNnPaHpr4TbPtt6h(by3Kc1vbHiLNGcjnShid7arQJinxgOG0yinCCH0bkom3F3Q8Ieyib6SoBhgVdbaGmJNJDyc)wi6ZIW(W4DiaaKz8CCCH7zihg2omx707ddBhM8g(0hgCV5pKKGtCwNTsPtjhgPZLQWpW8WWf0f4MHp9HP0iHuR1BoP)vn)rAmKENgbHlKA9euiPLypqg2bIutWCrKonPmLSjTKpG1)aKcRtJ5aCsDmsdBhrQJinj12nSfaPMaFaE8J0WoBsbcFIWBdsH6QGqKYtqHKg2dKHDGi1rKMlduqAmKgoUq6afhMlWdb45HzbcdBZtqHVWEGmSJnKjPFjfEc8CPkB(eOhK5HX7qaaiZ45yhMWVfI(SiS)ENPYhw9g(483YuJnK5HX7qaaiZ4544c3ZqomSDyU2P3hg2om5n8Ppm4EZFy183joRdB2Fk5WiDUuf(bMhM8g(0hgCV5VLAIIddxqxGBg(0hMsJesTwV5KcZAIcsDms)nqKYNgweK2IWjngsbcgqq2KA9Pe0MuMymj9MOWBdsZGu2H0bqk(aesJeyibIuwEytkJKaVniDD3WoWtGqAKvPdHtA2Cs)nqKMaH0EcsHqEBqkJDYhwy1exi1QahHt6ai1QOFxB)s6FZ7c3itPwFrcmKaTX9M)qsc(0A8kj1qcePHTqkU3ooeoPdgPRK0S5Kg2cPne(IaiDWinsGHeO9H5c8qaEEyGNapxQYMpb6bzs6xsbPZFcCPJn(axWLo2Et6NKEtu8chxi9Fsz)ELK(LuKPuRVibgsG24EZFijbK(rsxJu2H0)jf2K(hjnYQ0Xg3rc43w6CPkCs)N08goC5XNydpXnDGFFXaDTj9psAKvPJTj6312VVQ3fULoxQcN0)jDnsrMsT(IeyibAJ7n)HKeq6NwJjDLKUkP)rsxJutj2yU08DEdhUq6xsbqTGnadzJSt(WcRM4YZe4i8T8NqUPPWjDvsx9eN1HnBNsomsNlvHFG5HjVHp9HbEIB6a)(Ib6AFyUapeGNhgGGbeKDUufs)sAKadj2HJlVyECxi9tslfKwUmPRrAKvPJnUJeWVT05sv4K(Lu(eBKDYhwpwdG)mtV3abdii7CPkKUkPLlt6ceg2gQXGavVnE8euyli0gY8WC)DRYlsGHeOZ6SDIZ6Wg2NsomsNlvHFG5HjVHp9HbzN8H1J1a4pZ07ddxqxGBg(0hggt56zL070Cp8PjngsrXys6nrH3gKYScROvjDAshmSpOibgsGiLLT0KI5g2H3gKwQKoasXhGqkkYBHcNu8zbrA2CsHqEBqQvr)U2(L0)M3fsA2Csx)ducPwRJeWV9H5c8qaEEyacgqq25svi9lPrcmKyhoU8I5XDH0pjLDi9lPWG0iRshBChjGFBPZLQWj9lPrwLo2MOFxB)(QEx4w6CPkCs)skYuQ1xKadjqBCV5pKKas)KuyFIZ6WUupLCyKoxQc)aZdtEdF6ddYo5dRhRbWFMP3hM7VBvErcmKaDwNTdZf4Ha88WaemGGSZLQq6xsJeyiXoCC5fZJ7cPFsk7q6xsHbPrwLo24osa)2sNlvHt6xsHbPRrAKvPJnssG3gV2nSd8eiBPZLQWj9lPitPwFrcmKaTX9M)qsci9tsHNapxQYg3B(djj4DHIbdJ0vj9lPRrkminYQ0X2e97A73x17c3sNlvHtA5YKUgPrwLo2MOFxB)(QEx4w6CPkCs)skYuQ1xKadjqBCV5pKKas)yrsHnPRs6QhgUGUa3m8PpmwJeXKuMvyfTkPqMKonPjIu8S)rAKadjqKMisnheYxQIfKk)9RygKYYwAsXCd7WBdslvshaP4dqiff5TqHtk(SGiLLh2KAv0VRTFj9V5DH7tCwh2SZPKdJ05sv4hyEyYB4tFyW9M)qscom3F3Q8Ieyib6SoBhgVdbaGmJNJDyc)wi6ZIW(W4DiaaKz8CCCH7zihg2omxGhcWZddYuQ1xKadjqBCV5pKKas)Ku4jWZLQSX9M)qscExOyWWomx707ddBN4SoSx5PKdJ05sv4hyEyYB4tFyW9M)WQ5VdJ3HaaqMXZXomHFle9zry)9otLpS6n8X5VLPgBiZdJ3HaaqMXZXXfUNHCyy7WCTtVpmSDIZ6WUuCk5WiDUuf(bMhgUGUa3m8PpmLgjKYScRO1jnrKwtuqkqqdii1XiDAsdBHu8bUCyYB4tFyq2jFy9yna(JlzyFIZ6WgwEk5WiDUuf(bMhgUGUa3m8PpmLgjKYScROvjnrKwtuqkqqdii1XiDAsdBHu8bUqA2CszwHv06K6isNMuy16hM8g(0hgKDYhwpwdG)mtVpXjomCCJxa8UqjqNsoRZ2PKdJ05sv4hyEy6exom8eui(m9Jl3cFptOaiOR0x5WK3WN(WWtqH4Z0pUCl89mHcGGUsFLtCwh2NsomsNlvHFG5HPtC5WGG6L6m8xIlH9puCyYB4tFyqq9sDg(lXLW(hkoXz9s9uYHr6CPk8dmpmDIlhgJ6pt73G9seYX9Ag(0hM8g(0hgJ6pt73G9seYX9Ag(0N4So7Ck5WiDUuf(bMhMoXLddhijhZbYdUGqs9WK3WN(WWbsYXCG8GliKupXjomCblHQXPKZ6SDk5WK3WN(WG8Q0x5WiDUuf(bMN4SoSpLCyKoxQc)aZdZf4Ha88WSaHHTHpohBa4BitslxM0fimST5WsapVXGq(0BiZdtEdF6dJ5e(0N4SEPEk5WiDUuf(bMhMX8WGK4WK3WN(WapbEUuLdd8Scjhg(eBKDYhwpwdG)mtV3HFl0Bds)skFIn8e30b(9fd01Eh(TqVnomWtWRtC5WWNa9GmpXzD25uYHr6CPk8dmpmJ5HbjXHjVHp9HbEc8CPkhg4zfsom8j2i7KpSESga)zMEVd)wO3gK(Lu(eB4jUPd87lgOR9o8BHEBq6xs5tS5c8bc4TXZSMgqYo8BHEBCyGNGxN4YHjR1hFc0dY8eN1x5PKdJ05sv4hyEygZddsIdtEdF6dd8e45svomWZkKCyqMsT(IeyibAJ7n)HKeq6NKcBs)N0fimSn8X5ydaFdzEy4c6cCZWN(WWejiifc5TbPmsc82G01Dd7apbcPzqAP(pPrcmKar6aiLD(NuhJ0FdePjqi1Bsl44CSbGFyGNGxN4YHbjjWBJx7g2bEcK3fkgmStCwVuCk5WiDUuf(bMhMX8WGK4WK3WN(WapbEUuLdd8ScjhM7mv(WQ3WhN)eaKz4tVHmj9lPRrkmifKo)jWLo2jNJ2qMKwUmPG05pbU0Xo5C0MdbYWNM0pwKu2ypPLltkiD(tGlDStohTbcE6nI0plskBSN0)jDLK(hjDnsJSkDSTHAdb4TXd(48T05sv4KwUmP3bU0zh7c)b8SjDvsxL0VKUgPRrkiD(tGlDStohT9M0pjf2SN0YLjfzk16lsGHeOn8X5pbazg(0K(zrsxjPRsA5YKgzv6yBd1gcWBJh8X5BPZLQWjTCzsVdCPZo2f(d4zt6QhgUGUa3m8PpmW6mv(WQj1QZujTGjWZLQybPLgjCsJHuZzQKUiydqinVHdpdVnif(4CSbGVjfwHaaPJ6psHqcN0yi9oDaMkPSSLM0yinVHdpdHu4JZXgaoPS8WMuVVdU3gKMCoAFyGNGxN4YHXCM6dBaVlhDIZ6WYtjhgPZLQWpW8WCbEiappmlqyyB4JZXga(gY8WK3WN(WG5azPod)eN1TMNsomsNlvHFG5H5c8qaEEywGWW2WhNJna8nK5HjVHp9HzraibuO3gN4SEP0PKdJ05sv4hyEyYB4tFyQUHDGEwdH4g4shhgUGUa3m8PpmLgjK(3Cd7awGi1siUbU0bPogPHTaestGqkSjDaKIpaH0ibgsGSG0bqAY5istG0WIGuKzYQ92GuSbqk(aesd7SjfwUs0(WCbEiappmitPwFrcmKaTRUHDGEwdH4g4shK(zrsHnPLlt6AKcdsbPZFcCPJDY5OT83DuGiTCzsbPZFcCPJDY5OT3K(jPWYvs6QN4SoBS)uYHr6CPk8dmpmxGhcWZdZceg2g(4CSbGVHmpm5n8PpmzFfuaY67M16joRZgBNsomsNlvHFG5HjVHp9H5M16lVHp9R6O4WuDu86exomxw3tCwNnyFk5WiDUuf(bMhM8g(0hgau)YB4t)QokomvhfVoXLddE69joXH5Y6Ek5SoBNsomsNlvHFG5Hbcjpw2EvE3efEBCwNTdtEdF6ddssG3gV2nSd8eihM7VBvErcmKaDwNTdZf4Ha88WSgPWtGNlvzJKe4TXRDd7apbY7cfdggPFjfgKcpbEUuLT5m1h2aExoI0vjTCzsxJu(eBKDYhwpwdG)mtV3abdii7CPkK(LuKPuRVibgsG24EZFijbK(jPSr6QhgUGUa3m8PpmLgjKYijWBdsx3nSd8eiK6yK(BGiLLxRKA7bPspqg2KgjWqcePzZj1Qdlbqk7QXGq(0KMnN0coohBa4KMaH0EcsbsY)zbPdG0yifiyabztkZkSIwL0PjnynKoasXhGqAKadjq7tCwh2NsomsNlvHFG5Hbcjpw2EvE3efEBCwNTdtEdF6ddssG3gV2nSd8eihM7VBvErcmKaDwNTdZf4Ha88Wezv6yJKe4TXRDd7apbYw6CPkCs)skFInYo5dRhRbWFMP3BGGbeKDUufs)skYuQ1xKadjqBCV5pKKas)KuyFy4c6cCZWN(WWypGGuy1bxipiLrsG3gKUUByh4jqi9on3dFAsJH0cfXKuMvyfTkPqMK6nPF4WUpXz9s9uYHr6CPk8dmpmtx)9USUhg2om5n8Ppm4EZFl1efhgUGUa3m8Ppmtx)9USUKINfkisdBH08g(0KoD9hPqOCPkKYHaEBq61o7wQEBqA2Cs7jinrKMKcedOAcinVHp9(eN4WC5OtjN1z7uYHr6CPk8dmpm5n8PpmMdlb88gdc5tFy4c6cCZWN(WuAKqQvhwcGu2vJbH8PjLLh2KwWX5ydaFt6FyQCsXgaPfCCo2aWj9o4cI0bdJ07mv(WQj1BsdBH0w(7bPSXEsrYDAoI0jSfalhjKcHesNM0lNuOUkiePHTqQvLAAmislbKEqkSo4lzqQ1kCpYWNMuhrAKvPdHBbPdGuhJ0WwacPS8AL0EcsxesZEcBbqAbhNtk7gazg(0Kg2oIum3Wo2K(Hri4MbPXqk6xFjnSfsRjki1Cyjas9gdc5tt6GrAylKI5g2bPXqk8X5KkaiZWNMuSbqApnPwJ(b8Sr7dZf4Ha88WycCbfBKuXEMdlb88gdc5tt6xsxJ0fimSn8X5ydaFdzsA5YKcdsrduDXB((o4lz8WfUhz4tVLoxQcN0VKENPYhw9g(48NaGmdF6nqWtVrK(zrszJ9KwUmPyUHD8acE6nI0ps6DMkFy1B4JZFcaYm8P3abp9gr6QK(L01iDzqis)skMByhpGGNEJi9ZIKENPYhw9g(48NaGmdF6nqWtVrK(pPSTss)s6DMkFy1B4JZFcaYm8P3abp9gr6hlsQXLt6FKu2H0YLjDzqis)skMByhpGGNEJi9tsVZu5dREBoSeWZBmiKp9MdbYWNM0YLjDzqis)skMByhpGGNEJi9JKENPYhw9g(48NaGmdF6nqWtVrK(pPSTsslxM07ax6SJDH)aE2KU6joRd7tjhgPZLQWpW8WWf0f4MHp9HP0iHuyMCdHuVroxiDWiTG)fPydG0WwifZbOGuiKq6aiDAsHvRtAIfcG0WwifZbOGuiKSjDf8WM01Dd7G0)kfsTNkNuSbqAb)R9HPtC5WG8gdQ(mQj3ZyaO3sYnK3G9WeWC943H5c8qaEEywGWW2WhNJna8nKjPLltA44cPFskBSN0VKUgPWG07ax6SJD7g2Xdlfsx9WK3WN(WG8gdQ(mQj3ZyaO3sYnK3G9WeWC943joRxQNsomsNlvHFG5HjVHp9HblLNbuc4E2OddxqxGBg(0hMsJes)RuiTugkbCpBePttkSADshOa5CH0bJ0coohBa4Bslnsi9VsH0szOeW9S5is9M0coohBa4K6yK(BGi1oHlKkEylaslLbdCHu2vd3ngqg(0Koas)lxQCshmsHzDqObhTpmxGhcWZddmiDbcdBdFCo2aW3qMK(L01ifgKENPYhw9g(48xmaG0XgYK0YLjfgKgzv6ydFC(lgaq6ylDUufoPRsA5YKUaHHTHpohBa4Bits)s6AKIgO6I38TbyGlpVH7gdidF6T05sv4KwUmPObQU4nFJ5sL)gS3sDqObhTLoxQcN0vpXzD25uYHr6CPk8dmpm5n8Ppm4EZnsCbDyU)Uv5fjWqc0zD2omxGhcWZdJ3OS94hPFK0sj2t6xsxJ01ifEc8CPk7SwF8jqpits)s6AKcdsVZu5dREdFC(taqMHp9gYK0YLjfgKgzv6yBd1gcWBJh8X5BPZLQWjDvsxL0YLjDbcdBdFCo2aW3qMKUkPFjDnsHbPrwLo22qTHa824bFC(w6CPkCslxMuUSaHHTTHAdb4TXd(48nKjPLltkmiDbcdBdFCo2aW3qMKUkPFjDnsHbPrwLo2ijbEB8A3WoWtGSLoxQcN0YLjfzk16lsGHeOnU38hssaPFK0vs6QhgUGUa3m8PpmLgjKATEZnsCbrklBPjnRvslvsT(ucI0eiKczAbPdG0FdePjqi1Bsl44CSbGVjLD3iiGq6FaQneG3gKwWX5K6isZB4WfsNM0WwinsGHeK6yKgzv6q4BszIXKuiK3gKMbPR8FsJeyibIuwEytkJKaVniDD3WoWtGSpXz9vEk5WiDUuf(bMhM8g(0hgO2EQ)E9appmCbDbUz4tFyknsiT0T9u)r66d8K0PjfwTUfKApvU3gKUaCbR(J0yiLv6bPydGuZHLai1BmiKpnPdG0KZjfzMSA0(WCbEiappmRr6AKcdsbPZFcCPJDY5OnKjPFjfKo)jWLo2jNJ2Et6NKcB2t6QKwUmPG05pbU0Xo5C0gi4P3is)SiPSTsslxMuq68Nax6yNCoAZHaz4tt6hjLTvs6QK(L01iDbcdBBoSeWZBmiKp9gYK0YLj9otLpS6T5WsapVXGq(0BGGNEJi9ZIKYg7jTCzsHbPMaxqXgjvSN5WsapVXGq(0KUkPFjDnsHbPrwLo22qTHa824bFC(w6CPkCslxMuUSaHHTTHAdb4TXd(48nKjPLltkmiDbcdBdFCo2aW3qMKU6joRxkoLCyKoxQc)aZdtEdF6dZYm9BWEHT8s0vAUWpmCbDbUz4tFyknsiDAsHvRt6cuqQjWhGhosifc5TbPfCCoPSBaKz4ttkMdqHfK6yKcHeoPEJCUq6GrAb)lsNMuMsifcjKMyHainjf(48LPgKInasVZu5dRMubdZVU03FKMnNuSbqQnuBiaVnif(4CsHmdhxi1XinYQ0HW3hMlWdb45HbgKUaHHTHpohBa4Bits)skmi9otLpS6n8X5pbazg(0Bits)skYuQ1xKadjqBCV5pKKas)Ku2i9lPWG0iRshBKKaVnETByh4jq2sNlvHtA5YKUgPlqyyB4JZXga(gYK0VKImLA9fjWqc0g3B(djjG0pskSj9lPWG0iRshBKKaVnETByh4jq2sNlvHt6xsxJutGa)zC5B22WhN)wMAq6xsxJuyqQ8NqUPPW3cU5pGK13a4D2xH0YLjfgKgzv6yBd1gcWBJh8X5BPZLQWjDvslxMu5pHCttHVfCZFajRVbW7SVcPFj9otLpS6TGB(diz9naEN9v2abp9gr6hlskBLcyt6xs5Yceg22gQneG3gp4JZ3qMKUkPRsA5YKUgPlqyyB4JZXga(gYK0VKgzv6yJKe4TXRDd7apbYw6CPkCsx9eN1HLNsomsNlvHFG5HjVHp9H5M16lVHp9R6O4WuDu86exombW7cLaDItCycG3fkb6uYzD2oLCyKoxQc)aZddxqxGBg(0hMsJesNMuy16K(HmFOvjngsnKGuRpLqA43c92G0S5Kk)DthiKgdPvVfsHmjDrIqaKYYdBsl44CSbGFy6exomcU5pGK13a4D2x5WCbEiappm3zQ8HvVHpo)jaiZWNEde80BePFSiPSbBslxM07mv(WQ3WhN)eaKz4tVbcE6nI0pjf2WYdtEdF6dJGB(diz9naEN9voXzDyFk5WiDUuf(bMhgUGUa3m8Ppmm)6lPSlRbToPS8WM0coohBa4hMoXLdJ3OlakYLQ8(tOSdi8hxG7x5WCbEiappm3zQ8HvVHpo)jaiZWNEde80BePFskBS)WK3WN(W4n6cGICPkV)ek7ac)Xf4(voXz9s9uYHr6CPk8dmpmCbDbUz4tFyy(1xszSfji1AHq(LuwEytAbhNJna8dtN4YHbpV5cqEiBrIhoeYVhMlWdb45H5otLpS6n8X5pbazg(0BGGNEJi9tszJ9hM8g(0hg88Mla5HSfjE4qi)EIZ6SZPKdJ05sv4hyEy6exomObQwLi824bGw(DyU)Uv5fjWqc0zD2omxGhcWZdZceg22CyjGN3yqiF6nKjPLltkmi1e4ck2iPI9mhwc45ngeYN(WK3WN(WGgOAvIWBJhaA53HHlOlWndF6ddZV(s6hmOLFKYYdBsT6WsaKYUAmiKpnPqO0qSGu8SqHueeqingsrTBkKg2cP1HLGcs)dwL0ibgsCIZ6R8uYHr6CPk8dmpmCbDbUz4tFyknsifMj3qi1BKZfshmsl4Frk2ainSfsXCakifcjKoasNMuy16KMyHainSfsXCakifcjBszShqq61bxipi1Xif(4CsfaKz4tt6DMkFy1K6iszJ9ishaP4dqinzL)2hMoXLddYBmO6ZOMCpJbGElj3qEd2dtaZ1JFhMlWdb45H5otLpS6n8X5pbazg(0BGGNEJi9ZIKYg7pm5n8PpmiVXGQpJAY9mga6TKCd5nypmbmxp(DIZ6LItjhgPZLQWpW8WWf0f4MHp9HP0iH0QJcshmsN(dccjKYt80qinaExOeisNU(JuhJ0)auBiaVniTGJZj16YceggPoI08goCXcshaP)gistGqApbPrwLoeoPEhdPESpm5n8Ppm3SwF5n8PFvhfhMlWdb45HznsHbPrwLo22qTHa824bFC(w6CPkCslxMuUSaHHTTHAdb4TXd(48nKjPRs6xsxJ0fimSn8X5ydaFdzsA5YKENPYhw9g(48NaGmdF6nqWtVrK(jPSXEsx9WuDu86exomCCJxa8UqjqN4SoS8uYHr6CPk8dmpm5n8Ppmqi55HGJomCbDbUz4tFySUGLq1GuSSwxYBHKInasHq5svi1dbhTIKwAKq60KENPYhwnPEt6a4cG0LFKgaVlucsr1j2hMlWdb45HzbcdBdFCo2aW3qMKwUmPlqyyBZHLaEEJbH8P3qMKwUmP3zQ8HvVHpo)jaiZWNEde80BePFskBS)eN4WSmtFk5SoBNsomsNlvHFG5H5c8qaEEyqMsT(IeyibAJ7n)HKeq6hlsAPEyYB4tFys0vAUWFl1efN4SoSpLCyKoxQc)aZdZf4Ha88WejWqInlpS92As6xsrMsT(IeyibANOR0CH)6bEs6NKYgPFjfzk16lsGHeOnU38hssaPFskBK(pPrwLo2ijbEB8A3WoWtGSLoxQc)WK3WN(WKOR0CH)6bEEItCymbYDWxY4uYzD2oLCyKoxQc)aZdZf4Ha88Wae80BePFK0sL9S)WK3WN(WyoSeWJ1a4pSbeEaXLtCwh2NsomsNlvHFG5H5c8qaEEyGbPlqyyBKDYhwydaFdzEyYB4tFyq2jFyHna8tCwVupLCyKoxQc)aZdZf4Ha88W4nkBp(T5cMF9G0pjLTvEyYB4tFysWnB5fdaiDCIZ6SZPKdJ05sv4hyEygZddsIdtEdF6dd8e45svomWZkKCyG9HbEcEDIlhgCV5pKKG3fkgmStCwFLNsom5n8PpmWtCth43xmqx7dJ05sv4hyEItCIddCbG8PpRdB2dB2yFPYEy5HHvcAVnqhMv4d)GTo7A9s5vKuslXwi1Xnhqqk2aifwC5iybPa5pHCGWjfn4cPjum4ziCsV2zBiOnz5FZBH0sXkskSonCbecNuyra8Uqj25YDFNPYhwnSG0yifwCNPYhw9oxUWcsxJT)(QBYsYs2fU5acHtQ1K08g(0KwDuG2KLhgKPCpRd7vAnpmMGbZRYHPafGug7KpSi1QaxqbzzbkaPwBcU2KYg7TGuyZEyZgzjzzbkaPLWsYcjTGJZjTKbaKoiLLT0KgjWqcsVduhistGqk2aUcFtwswwGcqk7(VlxOq4KUiydqi9o4lzq6Iy4nAt6hEVIzGiTN(dYob4yqvsZB4tJiD66VnzzEdFA02ei3bFjJ)lAfZHLaESga)HnGWdiUyHJvei4P3OpwQSN9KL5n8PrBtGCh8Lm(VOvq2jFyHnaClCSIWybcdBJSt(WcBa4BitYY8g(0OTjqUd(sg)x0kj4MT8IbaKoSWXk6nkBp(T5cMF94t2wjzzEdFA02ei3bFjJ)lAf4jWZLQyrN4srCV5pKKG3fkgmmlgZIijSaEwHKIWMSmVHpnABcK7GVKX)fTc8e30b(9fd01MSKSSafGuRoHpnISmVHpnQiYRsFfYY8g(0OIMt4tBHJvCbcdBdFCo2aW3qMLlVaHHTnhwc45ngeYNEdzswM3WNg9FrRapbEUufl6exkYNa9GmTymlIKWc4zfskYNyJSt(W6XAa8Nz69o8BHEB8LpXgEIB6a)(Ib6AVd)wO3gKL5n8Pr)x0kWtGNlvXIoXLIzT(4tGEqMwmMfrsyb8Scjf5tSr2jFy9yna(Zm9Eh(TqVn(YNydpXnDGFFXaDT3HFl0BJV8j2Cb(ab824zwtdizh(TqVnillaPmrccsHqEBqkJKaVniDD3WoWtGqAgKwQ)tAKadjqKoaszN)j1Xi93arAces9M0coohBa4KL5n8Pr)x0kWtGNlvXIoXLIijbEB8A3WoWtG8UqXGHzXywejHfWZkKuezk16lsGHeOnU38hssWNW()fimSn8X5ydaFdzswwasH1zQ8HvtQvNPsAbtGNlvXcslns4KgdPMZujDrWgGqAEdhEgEBqk8X5ydaFtkScbash1FKcHeoPXq6D6amvszzlnPXqAEdhEgcPWhNJnaCsz5HnPEFhCVnin5C0MSmVHpn6)IwbEc8CPkw0jUu0CM6dBaVlhzXywejHfWZkKu8otLpS6n8X5pbazg(0BiZVRbdq68Nax6yNCoAdzwUmiD(tGlDStohT5qGm8P)yr2yF5YG05pbU0Xo5C0gi4P3OplYg7)FL)X1ISkDSTHAdb4TXd(48T05sv4LlFh4sNDSl8hWZE1v)U2AG05pbU0Xo5C027pHn7lxgzk16lsGHeOn8X5pbazg(0FwCLRwUCKvPJTnuBiaVnEWhNVLoxQcVC57ax6SJDH)aE2RswM3WNg9FrRG5azPod3chR4ceg2g(4CSbGVHmjlZB4tJ(VOvweasaf6THfowXfimSn8X5ydaFdzswwaslnsi9V5g2bSarQLqCdCPdsDmsdBbiKMaHuyt6aifFacPrcmKazbPdG0KZrKMaPHfbPiZKv7TbPydGu8biKg2ztkSCLOnzzEdFA0)fTs1nSd0ZAie3ax6WchRiYuQ1xKadjq7QByhON1qiUbU0XNfHD5YRbdq68Nax6yNCoAl)DhfOYLbPZFcCPJDY5OT3Fclx5QKL5n8Pr)x0kzFfuaY67M1QfowXfimSn8X5ydaFdzswM3WNg9FrRCZA9L3WN(vDuyrN4sXlRlzzEdFA0)fTcaQF5n8PFvhfw0jUuep9MSKSSafG0p0Q)nsJHuiKqklBPjfMZ0KoyKg2cPFi6knx4K6isZB4WfYY8g(0O9YmDXeDLMl83snrHfowrKPuRVibgsG24EZFijbFSyPswM3WNgTxMP)VOvs0vAUWF9apTWXkgjWqInlpS92A(fzk16lsGHeODIUsZf(Rh45NS9fzk16lsGHeOnU38hssWNS9FKvPJnssG3gV2nSd8eiBPZLQWjljllqbifwToISSaKwAKqQvhwcGu2vJbH8PjLLh2KwWX5ydaFt6FyQCsXgaPfCCo2aWj9o4cI0bdJ07mv(WQj1BsdBH0w(7bPSXEsrYDAoI0jSfalhjKcHesNM0lNuOUkiePHTqQvLAAmislbKEqkSo4lzqQ1kCpYWNMuhrAKvPdHBbPdGuhJ0WwacPS8AL0EcsxesZEcBbqAbhNtk7gazg(0Kg2oIum3Wo2K(Hri4MbPXqk6xFjnSfsRjki1Cyjas9gdc5tt6GrAylKI5g2bPXqk8X5KkaiZWNMuSbqApnPwJ(b8SrBYY8g(0O9LJkAoSeWZBmiKpTfowrtGlOyJKk2ZCyjGN3yqiF6VRTaHHTHpohBa4BiZYLHbAGQlEZ33bFjJhUW9idF6T05sv4FVZu5dREdFC(taqMHp9gi4P3OplYg7lxgZnSJhqWtVrF8otLpS6n8X5pbazg(0BGGNEJw97Aldc9fZnSJhqWtVrFw8otLpS6n8X5pbazg(0BGGNEJ(NTv(9otLpS6n8X5pbazg(0BGGNEJ(yrJl)pYoLlVmi0xm3WoEabp9g95DMkFy1BZHLaEEJbH8P3Ciqg(0LlVmi0xm3WoEabp9g9X7mv(WQ3WhN)eaKz4tVbcE6n6F2wz5Y3bU0zh7c)b8SxLSSaKwAKqkJxL(kKonPWQ1jngsnbZLugX0g6doSarQvbZTM4z4tVjllaP5n8Pr7lh9FrRG8Q0xXIibgs8CSIaOwWgGHSrIPn0hC0Zem3AINHp9w(ti30u4FxlsGHeBh9soVC5ibgsS5Yceg2(MOWBJnqYBSkzzbiT0iHuyMCdHuVroxiDWiTG)fPydG0WwifZbOGuiKq6aiDAsHvRtAIfcG0WwifZbOGuiKSjDf8WM01Dd7G0)kfsTNkNuSbqAb)RnzzEdFA0(Yr)x0kqi55HGBrN4srK3yq1Nrn5Egda9wsUH8gShMaMRh)SWXkUaHHTHpohBa4BiZYLdhx(Kn2)DnyCh4sNDSB3WoEyPSkzzbiT0iH0)kfslLHsa3Zgr60KcRwN0bkqoxiDWiTGJZXga(M0sJes)RuiTugkbCpBoIuVjTGJZXgaoPogP)gisTt4cPIh2cG0szWaxiLD1WDJbKHpnPdG0)YLkN0bJuywheAWrBYY8g(0O9LJ(VOvWs5zaLaUNnYchRimwGWW2WhNJna8nK531GXDMkFy1B4JZFXaashBiZYLHrKvPJn8X5VyaaPJT05sv4RwU8ceg2g(4CSbGVHm)UgAGQlEZ3gGbU88gUBmGm8P3sNlvHxUmAGQlEZ3yUu5Vb7TuheAWrBPZLQWxLSSaKwAKqQ16n3iXfePSSLM0SwjTuj16tjistGqkKPfKoas)nqKMaHuVjTGJZXga(Mu2DJGacP)bO2qaEBqAbhNtQJinVHdxiDAsdBH0ibgsqQJrAKvPdHVjLjgtsHqEBqAgKUY)jnsGHeisz5HnPmsc82G01Dd7apbYMSmVHpnAF5O)lAfCV5gjUGS4(7wLxKadjqfzZchRO3OS943hlLy)31wdEc8CPk7SwF8jqpiZVRbJ7mv(WQ3WhN)eaKz4tVHmlxggrwLo22qTHa824bFC(w6CPk8vxTC5fimSn8X5ydaFdzU631GrKvPJTnuBiaVnEWhNVLoxQcVCzUSaHHTTHAdb4TXd(48nKz5YWybcdBdFCo2aW3qMR(Dnyezv6yJKe4TXRDd7apbYw6CPk8YLrMsT(IeyibAJ7n)HKe8XvUkzzbiT0iH0s32t9hPRpWtsNMuy16wqQ9u5EBq6cWfS6psJHuwPhKInasnhwcGuVXGq(0KoastoNuKzYQrBYY8g(0O9LJ(VOvGA7P(71d80chR4ARbdq68Nax6yNCoAdz(fKo)jWLo2jNJ2E)jSz)QLldsN)e4sh7KZrBGGNEJ(SiBRSCzq68Nax6yNCoAZHaz4t)r2w5QFxBbcdBBoSeWZBmiKp9gYSC57mv(WQ3Mdlb88gdc5tVbcE6n6ZISX(YLHHjWfuSrsf7zoSeWZBmiKp9QFxdgrwLo22qTHa824bFC(w6CPk8YL5Yceg22gQneG3gp4JZ3qMLldJfimSn8X5ydaFdzUkzzbiT0iH0PjfwToPlqbPMaFaE4iHuiK3gKwWX5KYUbqMHpnPyoafwqQJrkes4K6nY5cPdgPf8ViDAszkHuiKqAIfcG0Ku4JZxMAqk2ai9otLpSAsfmm)6sF)rA2CsXgaP2qTHa82Gu4JZjfYmCCHuhJ0iRshcFtwM3WNgTVC0)fTYYm9BWEHT8s0vAUWTWXkcJfimSn8X5ydaFdz(fg3zQ8HvVHpo)jaiZWNEdz(fzk16lsGHeOnU38hssWNS9fgrwLo2ijbEB8A3WoWtGSLoxQcVC51wGWW2WhNJna8nK5xKPuRVibgsG24EZFijbFe2FHrKvPJnssG3gV2nSd8eiBPZLQW)UMjqG)mU8nBB4JZFltn(UgmK)eYnnf(wWn)bKS(gaVZ(kLldJiRshBBO2qaEB8GpoFlDUuf(QLll)jKBAk8TGB(diz9naEN9v(gaVluITGB(diz9naEN9v23zQ8HvVbcE6n6JfzRua7VCzbcdBBd1gcWBJh8X5BiZvxTC51wGWW2WhNJna8nK53iRshBKKaVnETByh4jq2sNlvHVkzzEdFA0(Yr)x0k3SwF5n8PFvhfw0jUumaExOeiYsYYcuasH1efKUc2Evifwtu4TbP5n8PrBszKG0mi12nSfaPMaFaE8J0yifzpGG0RdUqEqQ3HaaqMbP3P5E4tJiDAsTwV5KYijWk)vn)rwwaslnsiLrsG3gKUUByh4jqi1Xi93arklVwj12dsLEGmSjnsGHeisZMtQvhwcGu2vJbH8PjnBoPfCCo2aWjnbcP9eKcKK)ZcshaPXqkqWacYMuMvyfTkPttAWAiDaKIpaH0ibgsG2KL5n8Pr7lRBrKKaVnETByh4jqSacjpw2EvE3efEBuKnlU)Uv5fjWqcur2SWXkUg8e45sv2ijbEB8A3WoWtG8UqXGH9fgWtGNlvzBot9HnG3LJwTC514tSr2jFy9yna(Zm9EdemGGSZLQ8fzk16lsGHeOnU38hssWNSTkzzbiLXEabPWQdUqEqkJKaVniDD3WoWtGq6DAUh(0KgdPfkIjPmRWkAvsHmj1Bs)WHDtwM3WNgTVSU)x0kijbEB8A3WoWtGybesESS9Q8Ujk82OiBwC)DRYlsGHeOISzHJvmYQ0XgjjWBJx7g2bEcKT05sv4F5tSr2jFy9yna(Zm9EdemGGSZLQ8fzk16lsGHeOnU38hssWNWMSSaKoD937Y6skEwOGinSfsZB4tt601FKcHYLQqkhc4TbPx7SBP6TbPzZjTNG0erAskqmGQjG08g(0BYY8g(0O9L19)Iwb3B(BPMOWIPR)Exw3ISrwswM3WNgT54gVa4DHsGkcHKNhcUfDIlf5jOq8z6hxUf(EMqbqqxPVczzEdFA0MJB8cG3fkb6)IwbcjppeCl6exkIG6L6m8xIlH9puqwM3WNgT54gVa4DHsG(VOvGqYZdb3IoXLIg1FM2Vb7LiKJ71m8PjlZB4tJ2CCJxa8Uqjq)x0kqi55HGBrN4sroqsoMdKhCbHKkzjzzbkaPwB6nPFOv)BwqkYEGQCsVdCbqAwRKcY2qqKoyKgjWqcePzZjfDLob(GilZB4tJ24P3)x0k3SwF5n8PFvhfw0jUuCzM2cua8BuKnlCSIlqyy7Lz63G9cB5LOR0CHVHmjlZB4tJ24P3)x0kChzk1hEA4xYYcqAPrcPfCCoPSBaKz4tt60KENPYhwnPMZu92G0miTkjkiLDypPEJY2JFKUafK2tqQJr6VbIuwETs6axa30KuVrz7Xps9M0c(xBsT2SqHueeqifzN8HfMln3k4EZxKMlasZMtQ16nNuywtuqQJiDAsVZu5dRM0fbBacPfKDVjLDz0dqi1CMQ3gKceua8B4tJi1Xifc5TbPm2jFyHvtCHuRcCeoPzZjfMsZfaPoI0bk2KL5n8PrB807IWhN)eaKz4tBHJveEc8CPkBZzQpSb8UC0318gLTh)(Si7W(YLnLyJ5sZ35nC4YxaulydWq2i7KpSWQjU8mbocFl)jKBAk8VW4otLpS6nU383snrXgY8lmUZu5dREJSt(W6XAa8hxYWEdzU6318gLTh)(yrR5klxoYQ0XgjjWBJx7g2bEcKT05sv4FHNapxQYgjjWBJx7g2bEcK3fkgmSv)cJ7mv(WQ3yU08nK531GXDMkFy1BCV5VLAIInKz5YitPwFrcmKaTX9M)qsc(e2RswwasT2SqHueeqi93arQjuqkKjPmRWkAvs)qMp0QKonPHTqAKadji1XiDfazyJbvj9Vsb4cPoQHfbP5nC4cPSSLMum3Wo82Gu2(GkvsJeyibAtwM3WNgTXtV)VOvq2jFy9yna(Zm92chR4ceg2glLNbuc4E2OnK5xyWLfimSnlqg2yq1hwkax2qMFrMsT(IeyibAJ7n)HKe8r2HSmVHpnAJNE)FrRCZA9L3WN(vDuyrN4sXlhrwwas)dUHnPwf4dWJFKATEZjLrsaP5n8Pjngsbcgqq2KA9PeePS8WMuKKaVnETByh4jqilZB4tJ24P3)x0k4EZFijbwC)DRYlsGHeOISzHJvmYQ0XgjjWBJx7g2bEcKT05sv4FrMsT(IeyibAJ7n)HKe8j8e45sv24EZFijbVlumyyFHbFInYo5dRhRbWFMP37WVf6TXxyCNPYhw9gZLMVHmjllaPwfiycG0yifcjKA9eVZWNM0pK5dTkPogPz)JuRpLqQJiTNGuiZnzzEdFA0gp9()IwHN4Dg(0wC)DRYlsGHeOISzHJvegWtGNlvzN16Jpb6bzswwaszxnkYoQ)ifzknN0KuCV5KUutuq61obgcPjwiasHpoFzQbPogPqiVnifzN8HfwnXfsnbocN0S5KI7nFPMOarAcesVPPPW3KL5n8PrB807)lAfCV5VLAIclCSI3zQ8HvVX9M)wQjk2x7eyiOpz7RPeBmxA(oVHdx(cGAbBagYgzN8HfwnXLNjWr4B5pHCttH)fg3zQ8HvVHpo)Tm1ydzswwaslnsiTGJZjfMtnindsTDdBbqQjWhGh)iLLh2K(hGAdb4TbPfCCoPqMKgdPSdPrcmKazbPdG0jSfaPrwLoqKonPmLSjlZB4tJ24P3)x0kWhN)wMAyHJv0Bu2E87JfTMR8BKvPJTnuBiaVnEWhNVLoxQc)BKvPJnssG3gV2nSd8eiBPZLQW)ImLA9fjWqc0g3B(djj4JflfLlV2ArwLo22qTHa824bFC(w6CPk8VWiYQ0XgjjWBJx7g2bEcKT05sv4RwUmYuQ1xKadjqBCV5pKKGISTkzzbi16tdlcsHqcPwxGpqaVni1Q10asi1Xi93ar6nBsnKGuVJH0coohBa4K6nkKKBbPdGuhJugjbEBq66UHDGNaHuhrAKvPdHtA2Csz51kP2EqQ0dKHnPrcmKaTjlZB4tJ24P3)x0kCb(ab824zwtdiXchR4Aabdii7CPkLl7nkBp(9jSCLR(DnyapbEUuLT5m1h2aExoQCzVrz7XVplAnx5QFxdgrwLo2ijbEB8A3WoWtGSLoxQcVC51ISkDSrsc8241UHDGNazlDUuf(xyapbEUuLnssG3gV2nSd8eiVlumyyRUkzzbiT0iH0cctsNMuy16K6yK(BGiLpnSiiTfHtAmKEtuqQ1f4deWBdsTAnnGelinBoPHTaestGqAvqisd7SjLDinsGHeishOG01wjPS8WM070CipwDtwM3WNgTXtV)VOvGpo)Tm1WchRiYuQ1xKadjqBCV5pKKGpUg78)DAoKhBUJqtND8KR9iOT05sv4R(1Bu2E87JfTMR8BKvPJnssG3gV2nSd8eiBPZLQWlxggrwLo2ijbEB8A3WoWtGSLoxQcNSSaKwAKqkJDYhwKUcdGVIKADjdBsDmsdBH0ibgsqQJinxgOG0yiL7cPdG0FdeP2jCHug7KpSWQjUqQvbocNu5pHCttHtklpSj1A9MVinxaKoaszSt(WcZLMtAEdhUSjlZB4tJ24P3)x0ki7KpSESga)XLmST4(7wLxKadjqfzZchR4ArcmKyBlznS3M34JWM9FrMsT(IeyibAJ7n)HKe8r2z1YLxZuInMlnFN3WHlFbqTGnadzJSt(WcRM4YZe4i8T8NqUPPWxLSSaKwAKqkdeainxaKgdPwBYBbHiDAstsJeyibPHDgK6isngVnings5UqAgKg2cPa3WoinCCztwM3WNgTXtV)VOvqqaG0Cb8I5HN8wqilU)Uv5fjWqcur2SWXkgjWqID44YlMh3Lpc7v(DbcdBdFCo2aW38HvtwwaslnsiTGJZjTKbaKoiD66psDmszwHv0QKMnN0cwcPjqinVHdxinBoPHTqAKadjiL10WIGuUlKYHaEBqAylKETZUL6MSmVHpnAJNE)FrRaFC(lgaq6WI7VBvErcmKavKnlCSIWtGNlvzZNa9Gm)gjWqID44YlMh3Lpl1VRTaHHTHpohBa4B(WQlxEbcdBdFCo2aW3abp9g9X7mv(WQ3WhN)wMASbcE6nA1V5nC4YJpXgEIB6a)(Ib6Axezk16lsGHeOn8e30b(9fd01(lYuQ1xKadjqBCV5pKKGpU2k)FTsXFmYQ0Xoy5O4nypSmKT05sv4RUkzzEdFA0gp9()Iwb3B(I0CbyHJvKpXgEIB6a)(Ib6AVd)wO3gFxlYQ0XgjjWBJx7g2bEcKT05sv4FrMsT(IeyibAJ7n)HKe8j8e45sv24EZFijbVlumyyLlZNyJSt(W6XAa8Nz69o8BHEBS631GbaQfSbyiBKDYhwy1exEMahHVL)eYnnfE5Y5nC4YJpXgEIB6a)(Ib6Axezk16lsGHeOn8e30b(9fd01EvYYcqAPrcPmRWkADsz5HnPwn9EbizHcGuRIYkoPqDvqisdBH0ibgsqklVwjDriDrQdlsHn7TgG0fbBacPHTq6DMkFy1KEhCbr6sElKSmVHpnAJNE)FrRGSt(W6XAa8hxYW2chRiaQfSbyiBZ07fGKfkGNjkR4B5pHCttH)fEc8CPkB(eOhK53ibgsSdhxEX8mVXd2S)Z1UZu5dREJSt(W6XAa8hxYWEZHaz4t)VXLVkzzbiT0iHug7KpSifwbjYM0PjfwToPqDvqisdBbiKMaH0KZrK69DW92ytwM3WNgTXtV)VOvq2jFy9UGezBHJveKo)jWLo2jNJ2E)jBSNSSaKwAKqQ16nNugjbKgdP3Prq4cPwpbfsAj2dKHDGi1emxePtt6h(by3Bsl5dy9paPW60yoaNuhrAy7isDePjP2UHTai1e4dWJFKg2ztkq4teEBq60K(HFa2nPqDvqis5jOqsd7bYWoqK6isZLbkingsdhxiDGcYY8g(0OnE69)fTcU38hssGf3F3Q8IeyibQiBw4yfrMsT(IeyibAJ7n)HKe8j8e45sv24EZFijbVlumyyFxGWW28eu4lShid7ydzAX1o9UiBw4DiaaKz8CCCH7zifzZcVdbaGmJNJvm8BHOplcBYYcqAPrcPwR3Cs)RA(J0yi9onccxi16jOqslXEGmSdePMG5IiDAszkztAjFaR)bifwNgZb4K6yKg2oIuhrAsQTBylasnb(a84hPHD2Kce(eH3gKc1vbHiLNGcjnShid7arQJinxgOG0yinCCH0bkilZB4tJ24P3)x0k4EZFy18NfowXfimSnpbf(c7bYWo2qMFHNapxQYMpb6bzAX1o9UiBw4DiaaKz8CCCH7zifzZcVdbaGmJNJvm8BHOplc7V3zQ8HvVHpo)Tm1ydzswwaslnsi1A9MtkmRjki1Xi93arkFAyrqAlcN0yifiyabztQ1NsqBszIXK0BIcVnindszhshaP4dqinsGHeisz5HnPmsc82G01Dd7apbcPrwLoeoPzZj93arAces7jifc5TbPm2jFyHvtCHuRcCeoPdGuRI(DT9lP)nVlCJmLA9fjWqc0g3B(djj4tRXRKudjqKg2cP4E74q4KoyKUssZMtAylK2q4lcG0bJ0ibgsG2KL5n8PrB807)lAfCV5VLAIclCSIWtGNlvzZNa9Gm)csN)e4shB8bUGlDS9(ZBIIx44Y)SFVYVitPwFrcmKaTX9M)qsc(4ASZ)W(pgzv6yJ7ib8BlDUuf()5nC4YJpXgEIB6a)(Ib6A)hJSkDSnr)U2(9v9UWT05sv4)VgYuQ1xKadjqBCV5pKKGpTgVYv)JRzkXgZLMVZB4WLVaOwWgGHSr2jFyHvtC5zcCe(w(ti30u4RUkzzEdFA0gp9()IwbEIB6a)(Ib6ABX93TkVibgsGkYMfowrGGbeKDUuLVrcmKyhoU8I5XD5Zsr5YRfzv6yJ7ib8BlDUuf(x(eBKDYhwpwdG)mtV3abdii7CPkRwU8ceg2gQXGavVnE8euyli0gYKSSaKYykxpRKENM7HpnPXqkkgtsVjk82GuMvyfTkPtt6GH9bfjWqcePSSLMum3Wo82G0sL0bqk(aesrrElu4KIplisZMtkeYBdsTk6312VK(38UqsZMt66FGsi1ADKa(TjlZB4tJ24P3)x0ki7KpSESga)zMEBHJveiyabzNlv5BKadj2HJlVyECx(KD(cJiRshBChjGFBPZLQW)gzv6yBI(DT97R6DHBPZLQW)ImLA9fjWqc0g3B(djj4tytwwasTgjIjPmRWkAvsHmjDAsteP4z)J0ibgsGinrKAoiKVufliv(7xXmiLLT0KI5g2H3gKwQKoasXhGqkkYBHcNu8zbrklpSj1QOFxB)s6FZ7c3KL5n8PrB807)lAfKDYhwpwdG)mtVT4(7wLxKadjqfzZchRiqWacYoxQY3ibgsSdhxEX84U8j78fgrwLo24osa)2sNlvH)fgRfzv6yJKe4TXRDd7apbYw6CPk8VitPwFrcmKaTX9M)qsc(eEc8CPkBCV5pKKG3fkgmSv)UgmISkDSnr)U2(9v9UWT05sv4LlVwKvPJTj6312VVQ3fULoxQc)lYuQ1xKadjqBCV5pKKGpwe2RUkzzEdFA0gp9()Iwb3B(djjWI7VBvErcmKavKnlCSIitPwFrcmKaTX9M)qsc(eEc8CPkBCV5pKKG3fkgmmlU2P3fzZcVdbaGmJNJJlCpdPiBw4DiaaKz8CSIHFle9zrytwM3WNgTXtV)VOvW9M)WQ5plU2P3fzZcVdbaGmJNJJlCpdPiBw4DiaaKz8CSIHFle9zry)9otLpS6n8X5VLPgBitYYcqAPrcPmRWkADsteP1efKce0acsDmsNM0WwifFGlKL5n8PrB807)lAfKDYhwpwdG)4sg2KLfG0sJeszwHv0QKMisRjkifiObeK6yKonPHTqk(axinBoPmRWkADsDePttkSADYY8g(0OnE69)fTcYo5dRhRbWFMP3KLKLfG0sJesNMuy16K(HmFOvjngsnKGuRpLqA43c92G0S5Kk)DthiKgdPvVfsHmjDrIqaKYYdBsl44CSbGtwM3WNgTdG3fkbQiesEEi4w0jUuuWn)bKS(gaVZ(kw4yfVZu5dREdFC(taqMHp9gi4P3OpwKnyxU8DMkFy1B4JZFcaYm8P3abp9g9jSHLKLfGuMF9Lu2L1GwNuwEytAbhNJnaCYY8g(0ODa8Uqjq)x0kqi55HGBrN4srVrxauKlv59Nqzhq4pUa3VIfowX7mv(WQ3WhN)eaKz4tVbcE6n6t2ypzzbiL5xFjLXwKGuRfc5xsz5HnPfCCo2aWjlZB4tJ2bW7cLa9FrRaHKNhcUfDIlfXZBUaKhYwK4HdH8RfowX7mv(WQ3WhN)eaKz4tVbcE6n6t2ypzzbiL5xFj9dg0Ypsz5HnPwDyjaszxngeYNMuiuAiwqkEwOqkcciKgdPO2nfsdBH06WsqbP)bRsAKadjilZB4tJ2bW7cLa9FrRaHKNhcUfDIlfrduTkr4TXdaT8ZchR4ceg22CyjGN3yqiF6nKz5YWWe4ck2iPI9mhwc45ngeYN2I7VBvErcmKavKnYYcqAPrcPWm5gcPEJCUq6GrAb)lsXgaPHTqkMdqbPqiH0bq60KcRwN0eleaPHTqkMdqbPqiztkJ9acsVo4c5bPogPWhNtQaGmdFAsVZu5dRMuhrkBShr6aifFacPjR83MSmVHpnAhaVluc0)fTcesEEi4w0jUue5ngu9zutUNXaqVLKBiVb7HjG56XplCSI3zQ8HvVHpo)jaiZWNEde80B0NfzJ9KLfG0sJesRokiDWiD6piiKqkpXtdH0a4DHsGiD66psDms)dqTHa82G0cooNuRllqyyK6isZB4WfliDaK(BGinbcP9eKgzv6q4K6DmK6XMSmVHpnAhaVluc0)fTYnR1xEdF6x1rHfDIlf54gVa4DHsGSWXkUgmISkDSTHAdb4TXd(48T05sv4LlZLfimSTnuBiaVnEWhNVHmx97AlqyyB4JZXga(gYSC57mv(WQ3WhN)eaKz4tVbcE6n6t2y)QKLfGuRlyjuniflR1L8wiPydGuiuUufs9qWrRiPLgjKonP3zQ8HvtQ3KoaUaiD5hPbW7cLGuuDInzzEdFA0oaExOeO)lAfiK88qWrw4yfxGWW2WhNJna8nKz5YlqyyBZHLaEEJbH8P3qMLlFNPYhw9g(48NaGmdF6nqWtVrFYg7pXjoha]] )

end
