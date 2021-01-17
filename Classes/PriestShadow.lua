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


    spec:RegisterPack( "Shadow", 20210117, [[devUJbqivfEerIlPQskSjfPpPQinkQKofvkRsvLk9kvLAwqs3svLk2Le)csyyqQCmqyzQk5zQkktdsvDnfrTnvvkFdsKgNQIQZrKewNQkX8ue5EeyFkchesPSqvv8qIKAIqkCrvvs2irs6JQkcnsvfbNuvr0kbrVuvLu0mHuQ6MqIQDsL4NqkvgkKIokrsKwkrsupfQMkrQRcPkBfsjFfsuglrse7vs)vHbR0Hfwmv8yvzYiDzuBgIptOrROonPvRQsQEnvQMnvDBOSBP(TkdNOooKiwoWZrmDrxhuBhK(obnEvvQ68QQA9QQKsZNi2pLRquLUItJKRU8f6(cc0bbeO0c6KkM8NJ(OFfp)lZvC545EiYv8oW4ko(CqpHvC54V)cAv6ko5GbpUIpNPm5xqbke1Cg2P8omuqumyFK61pqGKOGOypuuXDGvF(j7QtfNgjxD5l09feOdciqPf0jvm5ph9)QIhW58bQ44kMuxXNvkL7QtfNYKxfxk2Iph0tOTOjqzsAqkfBHmA4a83wiqPOA7xO7liminiLITslKd3TfToLAR0haWDARWzUTndGiN2(o4oj2ga2wKd8yAPI7vssQsxXLb87WCISkD1fiQsxX5oC8mT(tf)b0KbAuXbmwOnX2jz7NHo0vXJxQxxXLpHmyi8a0bYbsnHPCnRU8vv6ko3HJNP1FQ4pGMmqJk(h26aJGuiZb9eICaScSCfpEPEDfNmh0tiYbWQz1LpRkDfN7WXZ06pv8hqtgOrfxBs0A(Vqze9PPTtyletUIhVuVUIhGx08ipaG7SMvxq)Q0vCUdhptR)uXp5koHZkE8s96ko0aOHJNR4qdpmxX)QIdnaJoW4koM20bHdW4bNhcsnRUm5Q0v84L61vCObMSc03ip43CfN7WXZ06p1SMvCkM4ibA7oNKQ0vxGOkDfN7WXZ06pv8oW4konaUJDxpO8Z9Xqgobm5X9JR4Xl1RR40a4o2D9GYp3hdz4eWKh3pUMvx(QkDfN7WXZ06pv8oW4kobUD83rhbgNZ)jzfpEPEDfNa3o(7OJaJZ5)KSMvx(SQ0vCUdhptR)uX7aJR4I()YZJdzeeIIP(i1RR4Xl1RR4I()YZJdzeeIIP(i1RRz1f0VkDfN7WXZ06pv8oW4kofWbfrb8aktiSVIhVuVUItbCqruapGYec7RznR4yH2vPRUarv6ko3HJNP1FQ4pGMmqJkUdmcsX5UECiJCMhb5XnLPfy5kojb6lRUarfpEPEDf)fE)iEPE9WRKSI7vso6aJR4o311S6YxvPR4Xl1RR4uLiZ(bwiQVko3HJNP1FQz1LpRkDfN7WXZ06pv8hqtgOrfhAa0WXZf578dKdmEuITtTvBs0A(32jeyl6JoBNARR2QnjAn)B7Key7NpzBLiX2m8CNfchaTfhTkoNybGlChoEMA7uBHganC8CHWbqBXrRIZjwa4XdopeeBDZ2P2(HTV780tyxquUPfyzBNARR2(HTV780tyxW0MoC8bjlWY2krITez27hzae5KuW0MoiCaSDcB)Yw3Q4Xl1RR4qpLoyaSCQxxZQlOFv6ko3HJNP1FQ4pGMmqJkUdmcsbj4HiCaOA0KcSSTtT9dBPSdmcsriiYzey)ajyGYfy5kE8s96kozoONWHWdqhYH21S6YKRsxX5oC8mT(tfpEPEDf)fE)iEPE9WRKSI7vso6aJR4pkPMvx(TQ0vCUdhptR)uXJxQxxXX0MoiCaQ4pGMmqJkEgEUZcHdG2IJwfNtSaWfUdhptTDQTez27hzae5KuW0MoiCaSDcBHganC8CbtB6GWby8GZdbX2P2(HT0llK5GEchcpaDihAxs95U2I2o12pS9DNNEc7cIYnTalxXF)FEEKbqKts1fiQz1fuAv6ko3HJNP1FQ4Xl1RR40aRJuVUI)aAYanQ4Fyl0aOHJNlH3pOxsgWYv83)NNhzae5KuDbIAwD5ZRsxX5oC8mT(tf)b0KbAuX1MeTM)TDscS9ZNSTtTndp3zzgUfzG2IdONslChoEMA7uBZWZDwiCa0wC0Q4CIfaUWD44zQTtTLiZE)idGiNKcM20bHdGTtsGT)MTsKyRR26QTz45olZWTid0wCa9uAH7WXZuBNA7h2MHN7Sq4aOT4OvX5elaCH7WXZuBDZwjsSLiZE)idGiNKcM20bHdGTcSfcBDRIhVuVUId9u6W58znRUivuLUIZD44zA9Nk(dOjd0OI7QTagbWK5WXZ2krITAtIwZ)2oHTO0jBRB2o1wxT9dBHganC8Cr(o)a5aJhLyRej2QnjAn)B7ecS9ZNSTUz7uBD12pSndp3zHWbqBXrRIZjwa4c3HJNP2krITUABgEUZcHdG2IJwfNtSaWfUdhptTDQTFyl0aOHJNleoaAloAvCoXcapEW5HGyRB26wfpEPEDfNYqpyG2IdzFicZ1S6ceORkDfN7WXZ06pv8hqtgOrfNiZE)idGiNKcM20bHdGTtYwxTf9T9BBFxtH1Sqvc56OZb)MpMu4oC8m1w3SDQTAtIwZ)2ojb2(5t22P2MHN7Sq4aOT4OvX5elaCH7WXZuBLiX2pSndp3zHWbqBXrRIZjwa4c3HJNPv84L61vCONshoNpRz1fiGOkDfN7WXZ06pv84L61vCYCqpHdHhGoOCKZv8hqtgOrf3vBZaiYzzMdFoxKFPTtY2VqNTtTLiZE)idGiNKcM20bHdGTtYw03w3SvIeBD1wzolik30s8sfkB7uBbWnJCarUqMd6jeXhy8qgOeScJsGvzzMARBv83)NNhzae5KuDbIAwDbIVQsxX5oC8mT(tfpEPEDfNadaCtzWiVbwqBMqQ4pGMmqJkEgarolPIXJ8guLTDs2(1KTDQToWiifONsroawHEc7k(7)ZZJmaICsQUarnRUaXNvLUIZD44zA9NkE8s96ko0tPJ8aaUZk(dOjd0OIdnaA445c9sYaw22P2MbqKZsQy8iVbvzBNW2pZ2P26QToWiifONsroawHEcBBLiXwhyeKc0tPihaRaySqBITtY23DE6jSlqpLoCoFwamwOnXw3SDQTXlvO8GEzbAGjRa9nYd(nBRaBjYS3pYaiYjPanWKvG(g5b)MTDQTez27hzae5KuW0MoiCaSDs26QTt22VT1vB)nB)DTndp3zjfQKCCidKi5c3HJNP26MTUvXF)FEEKbqKts1fiQz1fiq)Q0vCUdhptR)uXFanzGgvC6LfObMSc03ip43Cj1N7AlA7uBD12m8CNfchaTfhTkoNybGlChoEMA7uBjYS3pYaiYjPGPnDq4ay7e2cnaA445cM20bHdW4bNhcITsKyl9YczoONWHWdqhYH2LuFURTOTUvXJxQxxXX0M6WnLb1S6cetUkDfN7WXZ06pv8hqtgOrfha3mYbe5ICOTdGd3zWqMeEScJsGvzzMA7uBHganC8CHEjzalB7uBZaiYzjvmEK3q(LJVqNTtyRR2(UZtpHDHmh0t4q4bOdkh5CHcdIuV22VTv8rT1TkE8s96kozoONWHWdqhuoY5AwDbIFRkDfN7WXZ06pv8hqtgOrfhekDWq5olbLskAB7e2cb6Q4Xl1RR4K5GEchpqqMRz1fiqPvPR4ChoEMw)PIhVuVUIJPnDq4auXF)FEEKbqKts1fiQ4ANmaalNdfPIN6ZDYec(QIRDYaaSCoummMQrYvCiQ4pGMmqJkorM9(rgarojfmTPdchaBNWwObqdhpxW0MoiCagp48qqSDQToWiifAaCFKZhS4CwGLR4V5q7koe1S6ceFEv6ko3HJNP1FQ4Xl1RR4yAthi(4Ffx7Kbay5COiv8uFUtMqWxtF35PNWUa9u6W58zbwUIRDYaaSCoummMQrYvCiQ4pGMmqJkUdmcsHga3h58bloNfyzBNAl0aOHJNl0ljdy5k(Bo0UIdrnRUaHurv6ko3HJNP1FQ4pGMmqJko0aOHJNl0ljdyzBNAliu6GHYDwWoOmg3zrBBNW2xqYrQySTFBl6kt22P26QTez27hzae5KuW0MoiCaSDs2I(2o12pSndp3zbtjm4FH7WXZuBLiXwIm79JmaICskyAtheoa2ojB)nBNABgEUZcMsyW)c3HJNP26wfpEPEDfhtB6WXhKSMvx(cDvPR4ChoEMw)PIhVuVUIdnWKvG(g5b)MR4pGMmqJkoGramzoC8STtTndGiNLuX4rEdQY2oHT)MTsKyRR2MHN7SGPeg8VWD44zQTtTLEzHmh0t4q4bOd5q7cGramzoC8STUzRej26aJGuGBeyGxBXbnaU3mHuGLR4V)pppYaiYjP6ce1S6YxquLUIZD44zA9Nk(dOjd0OIdyeatMdhpB7uBZaiYzjvmEK3GQSTtyl6B7uB)W2m8CNfmLWG)fUdhptTDQTz45olYK)Vz9n8A7EH7WXZuBNAlrM9(rgarojfmTPdchaBNW2VQ4Xl1RR4K5GEchcpaDihAxZQlF9vv6ko3HJNP1FQ4Xl1RR4K5GEchcpaDihAxXFanzGgvCaJayYC44zBNABgarolPIXJ8guLTDcBrFBNA7h2MHN7SGPeg8VWD44zQTtT9dBD12m8CNfchaTfhTkoNybGlChoEMA7uBjYS3pYaiYjPGPnDq4ay7e2cnaA445cM20bHdW4bNhcITUz7uBD12pSndp3zrM8)nRVHxB3lChoEMARej26QTz45olYK)Vz9n8A7EH7WXZuBNAlrM9(rgarojfmTPdchaBNKaB)Yw3S1Tk(7)ZZJmaICsQUarnRU81NvLUIZD44zA9NkE8s96koM20bHdqf)9)55rgarojvxGOIRDYaaSCouKkEQp3jti4RkU2jdaWY5qXWyQgjxXHOI)aAYanQ4ez27hzae5KuW0MoiCaSDcBHganC8CbtB6GWby8GZdbPI)MdTR4quZQlFH(vPR4ChoEMw)PIhVuVUIJPnDG4J)vCTtgaGLZHIuXt95ozcbFn9DNNEc7c0tPdNZNfy5kU2jdaWY5qXWyQgjxXHOI)MdTR4quZQlFn5Q0v84L61vCYCqpHdHhGoOCKZvCUdhptR)uZQlF9BvPR4Xl1RR4K5GEchcpaDihAxX5oC8mT(tnRzf)j8vLU6cevPR4ChoEMw)PIdt4HWz1ZJxqsTfRUarfpEPEDfNWbqBXrRIZjwa4k(7)ZZJmaICsQUarf)b0KbAuXD1wObqdhpxiCa0wC0Q4CIfaE8GZdbX2P2(HTqdGgoEUiFNFGCGXJsS1nBLiXwxTLEzHmh0t4q4bOd5q7cGramzoC8STtTLiZE)idGiNKcM20bHdGTtyle26wnRU8vv6ko3HJNP1FQ4WeEiCw984fKuBXQlquXJxQxxXjCa0wC0Q4CIfaUI)()88idGiNKQlquXFanzGgv8m8CNfchaTfhTkoNybGlChoEMA7uBPxwiZb9eoeEa6qo0UayeatMdhpB7uBjYS3pYaiYjPGPnDq4ay7e2(vnRU8zvPR4ChoEMw)PIFT))4j8vXHOIhVuVUIJPnD44dswZAwXtG2UZjPkD1fiQsxX5oC8mT(tfpEPEDfNXK)d4WpoaTJ(Xv8hqtgOrf)DNNEc7c0tPdgalN61faJfAtSDscSfIVSvIeBF35PNWUa9u6GbWYPEDbWyH2eBNW2VqPv8oW4koJj)hWHFCaAh9JRz1LVQsxX5oC8mT(tfpEPEDfxBYdaNHJNhOe4OtySbLHQpUI)aAYanQ4V780tyxGEkDWay5uVUaySqBITtyleORI3bgxX1M8aWz445bkbo6egBqzO6JRz1LpRkDfN7WXZ06pv84L61vCS4foaEqMzohyWe9vXFanzGgv83DE6jSlqpLoyaSCQxxamwOnX2jSfc0vX7aJR4yXlCa8GmZCoWGj6RMvxq)Q0vCUdhptR)uX7aJR4Kd275m1wCaGD(xXF)FEEKbqKts1fiQ4pGMmqJkUdmcsr(eYGH2iWe96cSSTsKy7h2kduMKfc7rgYNqgm0gbMOxxXJxQxxXjhS3ZzQT4aa78VMvxMCv6ko3HJNP1FQ4Xl1RR4eTrG9drFq1ipaz4eurECidegCpn)xXFanzGgv83DE6jSlqpLoyaSCQxxamwOnX2jeyleORI3bgxXjAJa7hI(GQrEaYWjOI84qgim4EA(VMvx(TQ0vCUdhptR)uXFanzGgvCxT9dBZWZDwMHBrgOT4a6P0c3HJNP2krITu2bgbPmd3ImqBXb0tPfyzBDZ2P26QToWiifONsroawbw2wjsS9DNNEc7c0tPdgalN61faJfAtSDcBHaD26wfpEPEDf)fE)iEPE9WRKSI7vso6aJR4umXrc02Doj1S6ckTkDfN7WXZ06pv8hqtgOrf3bgbPa9ukYbWkWY2krIToWiif5tidgAJat0RlWY2krITV780tyxGEkDWay5uVUaySqBITtyleORIhVuVUIdt4HMmgPM1SI)OKQ0vxGOkDfN7WXZ06pv8hqtgOrfxgOmjle2JmKpHmyOncmrV22P26QToWiifONsroawbw2wjsS9dBjhS3rBAreCq5H2qvXdePEDH7WXZuBNA7h2soyVJ20Y7WCICGXunJuVUWD44zQTtT9DNNEc7c0tPdgalN61faJfAtSDcb2cb6SvIeBruX5CaySqBITtY23DE6jSlqpLoyaSCQxxamwOnXwjsSLCWEhTPfrWbLhAdvfpqK61fUdhptTDQTUARdmcsbWufWVKPJOvSOqY45UTtiWwi(YwjsS9DNNEc7csWdr4aq1OjfaJfAtSDcBHaD26MTUvXJxQxxXLpHmyOncmrVUMvx(QkDfN7WXZ06pv84L61vCI2iW(HOpOAKhGmCcQipoKbcdUNM)R4pGMmqJkUdmcsb6PuKdGvGLTvIeBtfJTDcBHaD2o1wxT9dBFhuUJolTkoNdKGT1TkEhyCfNOncSFi6dQg5bidNGkYJdzGWG7P5)AwD5ZQsxX5oC8mT(tf)b0KbAuX)WwhyeKc0tPihaRalB7uBD12pS9DNNEc7c0tPJ8aaUZcSSTsKy7h2MHN7Sa9u6ipaG7SWD44zQTUzRej26aJGuGEkf5ayfyzBNARR2soyVJ20Ii4GYdTHQIhis96c3HJNP2krITKd27OnTGOSNooKHJ)iKdJu4oC8m1w3Q4Xl1RR4ibpeHdavJMuZQlOFv6ko3HJNP1FQ4Xl1RR4yAtfdmMuXFanzGgvCTjrR5FBNKTsfOZ2P26QTUAl0aOHJNlH3pOxsgWY2o1wxT9dBF35PNWUa9u6GbWYPEDbw2wjsS9dBZWZDwMHBrgOT4a6P0c3HJNP26MTUzRej26aJGuGEkf5ayfyzBDZ2P26QTFyBgEUZYmClYaTfhqpLw4oC8m1wjsSLYoWiiLz4wKbAloGEkTalBRej2(HToWiifONsroawbw2w3SDQTUA7h2MHN7Sq4aOT4OvX5elaCH7WXZuBLiXwIm79JmaICskyAtheoa2ojBNSTUvXF)FEEKbqKts1fiQz1LjxLUIZD44zA9Nk(dOjd0OI7QTUA7h2ccLoyOCNLGsjfyzBNAliu6GHYDwckLu022jS9l0zRB2krITGqPdgk3zjOusbWyH2eBNqGTqmzBLiXwqO0bdL7SeukPqHbrQxB7KSfIjBRB2o1wxT1bgbPiFczWqBeyIEDbw2wjsS9DNNEc7I8jKbdTrGj61faJfAtSDcb2cb6SvIeB)WwzGYKSqypYq(eYGH2iWe9ABDZ2P26QTFyBgEUZYmClYaTfhqpLw4oC8m1wjsSLYoWiiLz4wKbAloGEkTalBRej2(HToWiifONsroawbw2w3Q4Xl1RR4W985)p6dAuZQl)wv6ko3HJNP1FQ4pGMmqJk(h26aJGuGEkf5ayfyzBNA7h2(UZtpHDb6P0bdGLt96cSSTtTLiZE)idGiNKcM20bHdGTtyle2o12pSndp3zHWbqBXrRIZjwa4c3HJNP2krITUARdmcsb6PuKdGvGLTDQTez27hzae5KuW0MoiCaSDs2(LTtT9dBZWZDwiCa0wC0Q4CIfaUWD44zQTtT1vBLbm0H4JwGOa9u6W58PTtT9dBzucSklZ0cJj)hWHFCaAh9JTvIeBzucSklZ0cJj)hWHFCaAh9JTDQTV780tyxym5)ao8Jdq7OFCbWyH2eBNKaBH43(Y2P2szhyeKYmClYaTfhqpLwGLT1nBDZwjsS1vBDGrqkqpLICaScSSTtTndp3zHWbqBXrRIZjwa4c3HJNP26wfpEPEDf35UECiJCMhb5XnLP1S6ckTkDfN7WXZ06pv84L61v8x49J4L61dVsYkUxj5OdmUINaTDNtsnRzf35UUkD1fiQsxX5oC8mT(tf)b0KbAuXjYS3pYaiYjPGPnDq4ay7Key7NvXJxQxxXdYJBktho(GK1S6YxvPR4ChoEMw)PI)aAYanQ4zae5SiuZzT)CBNAlrM9(rgarojLG84MY0rFqdBNWwiSDQTez27hzae5KuW0MoiCaSDcBHW2VTndp3zHWbqBXrRIZjwa4c3HJNPv84L61v8G84MY0rFqJAwZkoLrcyFwLU6cevPR4Xl1RR4e1Z9JR4ChoEMw)PMvx(QkDfN7WXZ06pv8hqtgOrf3bgbPa9ukYbWkWY2krIToWiif5tidgAJat0RlWYv84L61vC5l1RRz1LpRkDfN7WXZ06pv8tUIt4SIhVuVUIdnaA445ko0WdZvC6LfYCqpHdHhGoKdTlP(CxBrBNAl9Yc0atwb6BKh8BUK6ZDTfR4qdWOdmUItVKmGLRz1f0VkDfN7WXZ06pv8tUIt4SIhVuVUIdnaA445ko0WdZvC6LfYCqpHdHhGoKdTlP(CxBrBNAl9Yc0atwb6BKh8BUK6ZDTfTDQT0llug6bd0wCi7dryUK6ZDTfR4qdWOdmUIhE)GEjzalxZQltUkDfN7WXZ06pv8tUIt4SIhVuVUIdnaA445ko0WdZvCIm79JmaICskyAtheoa2oHTFz7326aJGuGEkf5ayfy5ko0am6aJR4eoaAloAvCoXcapEW5HGuZQl)wv6ko3HJNP1FQ4NCfNWzfpEPEDfhAa0WXZvCOHhMR4V780tyxGEkDWay5uVUalB7uBD12pSfekDWq5olbLskWY2krITGqPdgk3zjOusHcdIuV22jjWwiqNTsKyliu6GHYDwckLuamwOnX2jeyleOZ2VTDY2(7ARR2MHN7Smd3ImqBXb0tPfUdhptTvIeBFhuUJolU)hOrBRB26MTtT1vBD1wqO0bdL7SeukPOTTty7xOZwjsSLiZE)idGiNKc0tPdgalN612oHaBNSTUzRej2MHN7Smd3ImqBXb0tPfUdhptTvIeBFhuUJolU)hOrBRBvCOby0bgxXLVZpqoW4rj1S6ckTkDfN7WXZ06pv8hqtgOrf3bgbPa9ukYbWkWYv84L61vCefWo(7O1S6YNxLUIZD44zA9Nk(dOjd0OI7aJGuGEkf5ayfy5kE8s96kUddimWDTfRz1fPIQ0vCUdhptR)uXFanzGgvCIm79JmaICskEvCojJFDyQig3PTtiW2VSvIeBD12pSfekDWq5olbLsk8VxjjXwjsSfekDWq5olbLskAB7e2IsNSTUvXJxQxxX9Q4Csg)6WurmUZAwDbc0vLUIZD44zA9Nk(dOjd0OI7aJGuGEkf5ayfy5kE8s96kE0pMKGWpEH3xZQlqarv6ko3HJNP1FQ4Xl1RR4VW7hXl1RhELKvCVsYrhyCf)j8vZQlq8vv6ko3HJNP1FQ4Xl1RR4a4EeVuVE4vswX9kjhDGXvCSq7AwZAwXHYaIED1LVq3xOdIV(6ZR4cdqRTiPIJYqBsLD5t6YN4VyRTspZ2QyYhiTf5a2(PyH2FQTagLaRaMAl5WyBd48WIKP2(MJwKjfds0ETzBH4Z(fBL6da4xYuBzucC418VTVz(5UTiGdZ2pvGGp128S9tf8P26ke)E3kgKgKOm0Muzx(KU8j(l2AR0ZSTkM8bsBroGTF6Js(uBbmkbwbm1wYHX2gW5HfjtT9nhTitkgKO9AZ2(B)ITs91qzqYuB)0eOT7CwKkP8UZtpH9NABE2(PV780tyxKk5tT1vi(9UvmiLEMTf58(tO2I2gWGGyRqgW2ctyQTABBoZ2gVuV2wVssBDGtBfYa22(sBro4MAR22MZSTbLETT0idNGW)IbPT)o2cyQc4xY0r0kwyqAq(jXKpqYuB)CBJxQxBRxjjPyqwXLbhI65kUuSfFoONqBrtGYK0Guk2cz0Wb4VTqGsr12Vq3xqyqAqkfBLwihUBlADk1wPpaG70wHZCBBgaroT9DWDsSnaSTih4X0IbPbPuS9x975hCYuBDyKdW2(omNiT1Hf1MuSfT9ESCsSTV(3zoayiWEBJxQxtS9A))Ibz8s9AsrgWVdZjYVfGc5tidgcpaDGCGutykJQIiaWyH2Kj9zOdDgKXl1Rjfza)omNi)wakiZb9eICamuvebF4aJGuiZb9eICaScSSbz8s9AsrgWVdZjYVfGIa8IMh5baCNOQic0MeTM)lugrFAobet2GmEPEnPid43H5e53cqb0aOHJNrTdmwaM20bHdW4bNhccQNSacNOcn8WSGVmiJxQxtkYa(Dyor(TauanWKvG(g5b)MniniLITO5L61edY4L61ebe1Z9JniJxQxteiFPEnQkIahyeKc0tPihaRallrIdmcsr(eYGH2iWe96cSSbz8s9AY3cqb0aOHJNrTdmwa9sYawg1twaHtuHgEywa9YczoONWHWdqhYH2LuFURT4u6LfObMSc03ip43Cj1N7AlAqgVuVM8TauanaA44zu7aJfeE)GEjzalJ6jlGWjQqdpmlGEzHmh0t4q4bOd5q7sQp31wCk9Yc0atwb6BKh8BUK6ZDTfNsVSqzOhmqBXHSpeH5sQp31w0Guk2INbiTfMOTOT4Ca0w0wxuX5elaSTrA7N9TTzae5Ky7bSf9)2wfX2)hSTbGTvBBrRtPihaZGmEPEn5BbOaAa0WXZO2bglGWbqBXrRIZjwa4XdopeeupzbeorfA4Hzbez27hzae5KuW0MoiCaM4RVDGrqkqpLICaScSSbPuSvQVZtpHTTO5DEBrRaOHJNr1w0JWuBZZw57826WihGTnEPcnsTfTf6PuKdGvSvQHbaUt)FBHjm128S9DDcoVTcN5228SnEPcns2wONsroaMTc1C2wTFhM2I2gukPyqgVuVM8TauanaA44zu7aJfiFNFGCGXJsq9Kfq4evOHhMf8UZtpHDb6P0bdGLt96cS8ux)aekDWq5olbLskWYsKacLoyOCNLGsjfkmis96jjac0jrciu6GHYDwckLuamwOnzcbqGUVN8VRRz45olZWTid0wCa9uAH7WXZujsEhuUJolU)hOr7MBtD1vqO0bdL7SeukPO9eFHojsiYS3pYaiYjPa9u6GbWYPE9ecMSBsKKHN7Smd3ImqBXb0tPfUdhptLi5Dq5o6S4(FGgTBgKXl1RjFlafikGD83rrvre4aJGuGEkf5ayfyzdY4L61KVfGchgqyG7AlIQIiWbgbPa9ukYbWkWYgKsXw0JW2I2RIZ5NsSfsyQig3PTkIT5mdyBdaB7x2EaBXoaBBgarojOA7bSnOuITbG7pnTLihcBTfTf5a2IDa22CoABrPtMumiJxQxt(wak8Q4Csg)6WurmUtuvebez27hzae5Ku8Q4Csg)6WurmUZje8LejU(biu6GHYDwckLu4FVssIejGqPdgk3zjOusr7jqPt2ndY4L61KVfGIOFmjbHF8cVhvfrGdmcsb6PuKdGvGLniJxQxt(wakEH3pIxQxp8kjrTdmwWt4ZGmEPEn5BbOaa3J4L61dVssu7aJfGfABqAqkfBrBOjAVT5zlmHTv4m32(ZDTThIT5mBlAJ84MYuBvITXlvOSbz8s9AsX5UwqqECtz6WXhKevfrarM9(rgarojfmTPdchGjj4ZmiJxQxtko31Flafb5XnLPJ(GgOQicYaiYzrOMZA)5tjYS3pYaiYjPeKh3uMo6dAmbetjYS3pYaiYjPGPnDq4ambeFNHN7Sq4aOT4OvX5elaCH7WXZudsdsPyRuJgedsPyl6ryBrZtidS9t2iWe9ABfQ5STO1PuKdGvS9t48uBroGTO1PuKdGz77WyIThcITV780tyBR22MZSTn)7tBHaD2s431uITxoZaHkHTfMW2ETTpQTWTNjeBZz2w0K9H4rSvAqOPTs9H5ePTOCMQzK612QeBZWZDYuuT9a2Qi2MZmGTvO6922xARdBB0xoZaBrRtP2(RaWYPETT5SsSfrfNZIbz8s9As5rjcKpHmyOncmrVgvfrGmqzswiShziFczWqBeyIE9uxDGrqkqpLICaScSSejFqoyVJ20Ii4GYdTHQIhis96c3HJNPt)GCWEhTPL3H5e5aJPAgPEDH7WXZ0PV780tyxGEkDWay5uVUaySqBYecGaDsKGOIZ5aWyH2Kj9UZtpHDb6P0bdGLt96cGXcTjsKqoyVJ20Ii4GYdTHQIhis96c3HJNPtD1bgbPayQc4xY0r0kwuiz8CFcbq8LejV780tyxqcEichaQgnPaySqBYeqGo3CZGuk2IEe2wC1Z9JT9ABLA0W28SvgCpBXz5z4FTFkXw0eCpFGfPEDXGuk2gVuVMuEuY3cqbr9C)yuZaiY5qreaGBg5aICHWYZW)AjdzW98bwK61fgLaRYYmDQRzae5SOKrqPsKKbqKZcLDGrqkVGKAlwaC8s3miLITOhHT9NGkY2QnrPSThITOLu1wKdyBoZ2IOasAlmHT9a2ETTsnAyBGKmW2CMTfrbK0wycxSfLP5STUOIZPTs1GTD(8uBroGTOLuTyqgVuVMuEuY3cqbmHhAYyO2bglGOncSFi6dQg5bidNGkYJdzGWG7P5FuveboWiifONsroawbwwIKuX4jGaDtD9J3bL7OZsRIZ5ajy3miLITOhHTvQgSTFIWbGQrtS9ABLA0W2dojkLT9qSfToLICaSITOhHTvQgSTFIWbGQrtj2QTTO1PuKdGzRIy7)d225akBlR5mdS9teCqzB)Knuv8arQxB7bSvQQSNA7Hy7p(JqomsXGmEPEnP8OKVfGcKGhIWbGQrtqvre8Hdmcsb6PuKdGvGLN66hV780tyxGEkDKhaWDwGLLi5Jm8CNfONsh5baCNfUdhptDtIehyeKc0tPihaRalp1vYb7D0MwebhuEOnuv8arQxx4oC8mvIeYb7D0Mwqu2thhYWXFeYHrkChoEM6MbPuSf9iSTOCTPIbgtSv4m32gEVTFMTOXjnX2aW2clJQThW2)hSTbGTvBBrRtPihaRy7VQjWa22pb4wKbAlAlADk1wLyB8sfkB712MZSTzae50wfX2m8CNmTylEEY2ct0w02iTDYFBBgaroj2kuZzBX5aOTOTUOIZjwa4Ibz8s9As5rjFlafyAtfdmMG67)ZZJmaICseabQkIaTjrR5)jjvGUPU6k0aOHJNlH3pOxsgWYtD9J3DE6jSlqpLoyaSCQxxGLLi5Jm8CNLz4wKbAloGEkTWD44zQBUjrIdmcsb6PuKdGvGLDBQRFKHN7Smd3ImqBXb0tPfUdhptLiHYoWiiLz4wKbAloGEkTallrYhoWiifONsroawbw2TPU(rgEUZcHdG2IJwfNtSaWfUdhptLiHiZE)idGiNKcM20bHdWKMSBgKsXw0JW2IE985)BRlh0W2RTvQrduTD(8uTfT1bOmI)VT5zRWqtBroGTYNqgyR2iWe9ABpGTbLAlroe2KIbz8s9As5rjFlafW985)p6dAGQIiWvx)aekDWq5olbLskWYtbHshmuUZsqPKI2t8f6CtIeqO0bdL7SeukPaySqBYecGyYsKacLoyOCNLGsjfkmis96jbXKDBQRoWiif5tidgAJat0RlWYsK8UZtpHDr(eYGH2iWe96cGXcTjtiac0jrYhYaLjzHWEKH8jKbdTrGj61Un11pYWZDwMHBrgOT4a6P0c3HJNPsKqzhyeKYmClYaTfhqpLwGLLi5dhyeKc0tPihaRal7MbPuSf9iSTxBRuJg26aN2kd0dOPsyBHjAlAlADk12Ffawo1RTfrbKevBveBHjm1wTjkLT9qSfTKQ2ETT4sBlmHTnqsgyByl0tPoNpTf5a2(UZtpHTTmcI(uUF)TnAQTihW2z4wKbAlAl0tP2clNkgBRIyBgEUtMwmiJxQxtkpk5BbOW5UECiJCMhb5XnLPOQic(WbgbPa9ukYbWkWYt)4DNNEc7c0tPdgalN61fy5Pez27hzae5KuW0MoiCaMaIPFKHN7Sq4aOT4OvX5elaCH7WXZujsC1bgbPa9ukYbWkWYtjYS3pYaiYjPGPnDq4amPVM(rgEUZcHdG2IJwfNtSaWfUdhptN6QmGHoeF0cefONshoNpN(bJsGvzzMwym5)ao8Jdq7OFSejmkbwLLzAHXK)d4WpoaTJ(XttG2UZzHXK)d4WpoaTJ(XL3DE6jSlagl0Mmjbq8BFnLYoWiiLz4wKbAloGEkTal7MBsK4Qdmcsb6PuKdGvGLNMHN7Sq4aOT4OvX5elaCH7WXZu3miJxQxtkpk5BbO4fE)iEPE9WRKe1oWybjqB35KyqAqkfBL6GK2IYMvpBRuhKuBrBJxQxtk2IZPTrA7SkoZaBLb6b08VT5zlz(aPTpf8G10wTtgaGLtBFxt1uVMy712IY1MAlohauiv9XFdsPyl6ryBX5aOTOTUOIZjwayBveB)FW2ku9EBN10wUpyXzBZaiYjX2OP2IMNqgy7NSrGj612gn1w06ukYbWSnaST9L2c4G(hvBpGT5zlGramz2wCu2VGM2ETTPWZ2dyl2byBZaiYjPyqgVuVMuEcFciCa0wC0Q4CIfagvycpeoREE8csQTOaiq99)55rgarojcGavfrGRqdGgoEUq4aOT4OvX5ela84bNhcY0pGganC8Cr(o)a5aJhL4MejUsVSqMd6jCi8a0HCODbWiaMmhoEEkrM9(rgarojfmTPdchGjGWndsPyl(8bsBLAf8G10wCoaAlARlQ4CIfa2231un1RTnpBDNzzBXrz)cAAlSSTABlA7(vgKXl1RjLNW33cqbHdG2IJwfNtSaWOct4HWz1ZJxqsTffabQV)pppYaiYjraeOQicYWZDwiCa0wC0Q4CIfaUWD44z6u6LfYCqpHdHhGoKdTlagbWK5WXZtjYS3pYaiYjPGPnDq4amXxgKsX2R9)hpHpBXc3zIT5mBB8s9ABV2)3wys44zBPWaTfT9nhDZETfTnAQT9L2geBdBbSiSpa2gVuVUyqgVuVMuEcFFlafyAtho(GKOET))4j8jacdsdY4L61KcftCKaTDNtIaycp0KXqTdmwanaUJDxpO8Z9Xqgobm5X9JniJxQxtkumXrc02DojFlafWeEOjJHAhySacC74VJocmoN)tsdY4L61KcftCKaTDNtY3cqbmHhAYyO2bglq0)xEECiJGqum1hPETbz8s9AsHIjosG2UZj5BbOaMWdnzmu7aJfqbCqruapGYec7niniLITO8qBBrBOjApQ2sMpyp123bLb2gEVTGOfzIThITzae5KyB0uBjpUdGEedY4L61KcwO93cqXl8(r8s96HxjjQDGXcCURrLKa9LcGavfrGdmcsX5UECiJCMhb5XnLPfyzdY4L61KcwO93cqbvjYSFGfI6ZGuk2IEe2w06uQT)kaSCQxB712(UZtpHTTY351w02iT1ZbjTf9rNTAtIwZ)26aN22xARIy7)d2wHQ3B7bLbVq2wTjrR5FB12w0sQwSfLhUZ2sGbSTK5GEcruUPOatBQd3ugyB0uBr5AtT9hFqsBvITxB77op9e226WihGTfT(vfdY4L61KcwOTaONshmawo1RrvreanaA445I8D(bYbgpkzQ2KO18)ecqF0n1vTjrR5)jj4ZNSejz45oleoaAloAvCoXcax4oC8mDk0aOHJNleoaAloAvCoXcapEW5HG420pE35PNWUGOCtlWYtD9J3DE6jSlyAtho(GKfyzjsiYS3pYaiYjPGPnDq4amXxUzqkfBr5H7STeyaB7)d2wz40wyzBXrz)cAAlAdhTHM2ETT5mBBgaroTvrSfLbICgb2BRunyGY2QK(ttBJxQq5Ibz8s9Asbl0(BbOGmh0t4q4bOd5qBuveboWiifKGhIWbGQrtkWYt)GYoWiifHGiNrG9dKGbkxGLniJxQxtkyH2FlafVW7hXl1RhELKO2bgl4rjgKsX2pbvC2w0eOhqZ)2IY1MAlohaBJxQxBBE2cyeatMTfnoPj2kuZzBjCa0wC0Q4CIfa2GmEPEnPGfA)TauGPnDq4aG67)ZZJmaICseabQkIGm8CNfchaTfhTkoNybGlChoEMoLiZE)idGiNKcM20bHdWeqdGgoEUGPnDq4amEW5HGm9d6LfYCqpHdHhGoKdTlP(CxBXPF8UZtpHDbr5MwGLniLITOjGryGT5zlmHTfncSos9ABrB4On00wfX2O)BlACsBRsSTV0wy5Ibz8s9Asbl0(BbOGgyDK61O(()88idGiNebqGQIi4dObqdhpxcVFqVKmGLniLITOhHTfToLA7pNpTnsBNvXzgyRmqpGM)TvOMZ2(ja3ImqBrBrRtP2clBBE2I(2MbqKtcQ2EaBVCMb2MHN7Ky712IlDXGmEPEnPGfA)Taua9u6W58jQkIaTjrR5)jj4ZN80m8CNLz4wKbAloGEkTWD44z60m8CNfchaTfhTkoNybGlChoEMoLiZE)idGiNKcM20bHdWKe8BsK4QRz45olZWTid0wCa9uAH7WXZ0PFKHN7Sq4aOT4OvX5elaCH7WXZu3KiHiZE)idGiNKcM20bHdGaiCZGuk2Igx)PPTWe2w0GHEWaTfTfn9HimBRIy7)d22x02kYPTANNTO1PuKdGzR2KKdkQ2EaBveBX5aOTOTUOIZjwayBvITz45ozQTrtTvO692oRPTCFWIZ2MbqKtsXGmEPEnPGfA)TauqzOhmqBXHSpeHzuvebUcyeatMdhplrI2KO18)eO0j72ux)aAa0WXZf578dKdmEuIejAtIwZ)ti4ZNSBtD9Jm8CNfchaTfhTkoNybGlChoEMkrIRz45oleoaAloAvCoXcax4oC8mD6hqdGgoEUq4aOT4OvX5ela84bNhcIBUzqkfBrpcBlA9JTxBRuJg2Qi2()GTLE9NM22mtTnpBFbjTfnyOhmqBrBrtFicZOAB0uBZzgW2ga2wpti2MZrBl6BBgaroj2EWPTUozBfQ5STVRPWA6wXGmEPEnPGfA)Taua9u6W58jQkIaIm79JmaICskyAtheoatYv0)731uynluLqUo6CWV5JjfUdhptDBQ2KO18)Ke85tEAgEUZcHdG2IJwfNtSaWfUdhptLi5Jm8CNfchaTfhTkoNybGlChoEMAqkfBrpcBl(CqpH2IYoa9xSfn4iNTvrSnNzBZaiYPTkX2W5GtBZZwQY2EaB)FW2ohqzBXNd6jeXhySTOjqjy2YOeyvwMP2kuZzBr5AtD4MYaBpGT4Zb9eIOCtTnEPcLlgKXl1RjfSq7VfGcYCqpHdHhGoOCKZO(()88idGiNebqGQIiW1maICwM5WNZf5xoPVq3uIm79JmaICskyAtheoatc9DtIexL5SGOCtlXlvO8uaCZihqKlK5GEcr8bgpKbkbRWOeyvwMPUzqkfBrpcBlomaWnLb2MNTO8G2mHy712g2MbqKtBZ5iTvj2kEAlABE2sv22iTnNzBbQ4CABQyCXGmEPEnPGfA)TauqGbaUPmyK3alOntiO(()88idGiNebqGQIiidGiNLuX4rEdQYt6Rjp1bgbPa9ukYbWk0tyBqkfBrpcBlADk1wPpaG702R9)TvrSfhL9lOPTrtTfTK22aW2gVuHY2gn12CMTndGiN2k86pnTLQSTuyG2I2MZSTV5OB2xmiJxQxtkyH2FlafqpLoYda4or99)55rgarojcGavfra0aOHJNl0ljdy5Pzae5SKkgpYBqvEIpBQRoWiifONsroawHEcBjsCGrqkqpLICaScGXcTjt6DNNEc7c0tPdNZNfaJfAtCBA8sfkpOxwGgyYkqFJ8GFZceqKzVFKbqKtsbAGjRa9nYd(npLiZE)idGiNKcM20bHdWKCDYF76V97MHN7SKcvsooKbsKCH7WXZu3CZGmEPEnPGfA)TauGPn1HBkdqvreqVSanWKvG(g5b)MlP(CxBXPUMHN7Sq4aOT4OvX5elaCH7WXZ0Pez27hzae5KuW0MoiCaMaAa0WXZfmTPdchGXdopeejsOxwiZb9eoeEa6qo0UK6ZDTfDZGuk2IEe2wCu2VGg2kuZzBrZqBhahUZaBrts4XSfU9mHyBoZ2MbqKtBfQEVToSToS)eA7xO7xdBDyKdW2MZSTV780tyB77WyIToXZDdY4L61KcwO93cqbzoONWHWdqhuoYzuveba4MroGixKdTDaC4odgYKWJvyucSklZ0PqdGgoEUqVKmGLNMbqKZsQy8iVH8lhFHUjC9DNNEc7czoONWHWdqhuoY5cfgePE93IpQBgKsXw0JW2Iph0tOTsniiZ2ETTsnAylC7zcX2CMbSTbGTnOuITA)omTflgKXl1RjfSq7VfGcYCqpHJhiiZOQicaHshmuUZsqPKI2tab6miLITOhHTfLRn1wCoa2MNTVRjWySTOraC3wPNpyX5KyRm4EeBV2w0gA3VQyR0ODObANTs91ikaZwLyBoReBvITHTZQ4mdSvgOhqZ)2MZrBlGPxMAlA712I2q7(v2c3EMqSLga3TnNpyX5KyRsSnCo4028Snvm22doniJxQxtkyH2FlafyAtheoaO(()88idGiNebqGQIiGiZE)idGiNKcM20bHdWeqdGgoEUGPnDq4amEW5HGm1bgbPqdG7JC(GfNZcSmQV5qBbqGQ2jdaWY5qXWyQgjlacu1ozaawohkIGuFUtMqWxgKsXw0JW2IY1MARu1h)TnpBFxtGXyBrJa4UTspFWIZjXwzW9i2ETT4sxSvA0o0aTZwP(AefGzRIyBoReBvITHTZQ4mdSvgOhqZ)2MZrBlGPxMAlAlC7zcXwAaC32C(GfNtITkX2W5GtBZZ2uXyBp40GmEPEnPGfA)TauGPnDG4J)OQicCGrqk0a4(iNpyX5SalpfAa0WXZf6LKbSmQV5qBbqGQ2jdaWY5qXWyQgjlacu1ozaawohkIGuFUtMqWxtF35PNWUa9u6W58zbw2Guk2IEe2wuU2uB)XhK0wfX2)hST0R)002MzQT5zlGramz2w04KMuSfppzBFbj1w02iTf9T9a2IDa22maICsSvOMZ2IZbqBrBDrfNtSaW2MHN7KPfdY4L61KcwO93cqbM20HJpijQkIaObqdhpxOxsgWYtbHshmuUZc2bLX4olApXli5ivm(B0vM8uxjYS3pYaiYjPGPnDq4amj0F6hz45olykHb)lChoEMkrcrM9(rgarojfmTPdchGj9BtZWZDwWucd(x4oC8m1ndY4L61KcwO93cqb0atwb6BKh8Bg13)NNhzae5KiacuvebagbWK5WXZtZaiYzjvmEK3GQ8e)MejUMHN7SGPeg8VWD44z6u6LfYCqpHdHhGoKdTlagbWK5WXZUjrIdmcsbUrGbETfh0a4EZesbw2Guk2IlZpn82(UMQPETT5zljpzBFbj1w0wCu2VGM2ETThcYVtgaroj2kCMBBruX5uBrB)mBpGTyhGTLKXZDMAl25qSnAQTWeTfTfnj)FZ6Zw0ETD32OP26cAN02IYvcd(xmiJxQxtkyH2FlafK5GEchcpaDihAJQIiaWiaMmhoEEAgarolPIXJ8guLNa9N(rgEUZcMsyW)c3HJNPtZWZDwKj)FZ6B4129c3HJNPtjYS3pYaiYjPGPnDq4amXxgKsX2Fnzw2wCu2VGM2clB712geBXI(VTzae5KyBqSv(ie1XZOAl)7FSCARWzUTfrfNtTfT9ZS9a2IDa2wsgp3zQTyNdXwHAoBlAs()M1NTO9A7EXGmEPEnPGfA)TauqMd6jCi8a0HCOnQV)pppYaiYjraeOQicamcGjZHJNNMbqKZsQy8iVbv5jq)PFKHN7SGPeg8VWD44z60pCndp3zHWbqBXrRIZjwa4c3HJNPtjYS3pYaiYjPGPnDq4amb0aOHJNlyAtheoaJhCEiiUn11pYWZDwKj)FZ6B4129c3HJNPsK4AgEUZIm5)BwFdV2Ux4oC8mDkrM9(rgarojfmTPdchGjj4l3CZGmEPEnPGfA)TauGPnDq4aG67)ZZJmaICseabQkIaIm79JmaICskyAtheoatanaA445cM20bHdW4bNhccQV5qBbqGQ2jdaWY5qXWyQgjlacu1ozaawohkIGuFUtMqWxgKXl1RjfSq7VfGcmTPdeF8h13COTaiqv7Kbay5COyymvJKfabQANmaalNdfrqQp3jti4RPV780tyxGEkD4C(SalBqkfBrpcBlok7xqdBdIT(GK2cyYbsBveBV22CMTf7GYgKXl1RjfSq7VfGcYCqpHdHhGoOCKZgKsXw0JW2IJY(f002GyRpiPTaMCG0wfX2RTnNzBXoOSTrtTfhL9lOHTkX2RTvQrddY4L61KcwO93cqbzoONWHWdqhYH2gKgKsXw0JW2ETTsnAylAdhTHM2MNTICAlACsBBQp31w02OP2Y)EzfW2MNTETzBHLT1HZKb2kuZzBrRtPihaZGmEPEnPKaTDNtIaycp0KXqTdmwaJj)hWHFCaAh9Jrvre8UZtpHDb6P0bdGLt96cGXcTjtsaeFjrY7op9e2fONshmawo1Rlagl0MmXxOudsPyl()(z7NuQu0WwHAoBlADkf5aygKXl1RjLeOT7Cs(wakGj8qtgd1oWybAtEa4mC88aLahDcJnOmu9XOQicE35PNWUa9u6GbWYPEDbWyH2KjGaDgKsXw8)9Zw8zMtBr5We9zRqnNTfToLICamdY4L61Ksc02DojFlafWeEOjJHAhySaS4foaEqMzohyWe9HQIi4DNNEc7c0tPdgalN61faJfAtMac0zqkfBX)3pBLkd783wHAoBlAEczGTFYgbMOxBlmjezuTflCNTLadyBZZwsRYST5mBR)eYK02pb002maICAqgVuVMusG2UZj5BbOaMWdnzmu7aJfqoyVNZuBXba25pQkIahyeKI8jKbdTrGj61fyzjs(qgOmjle2JmKpHmyOncmrVg13)NNhzae5KiacdsPyl6ryB)jOISTAtukB7HylAjvTf5a2MZSTikGK2ctyBpGTxBRuJg2gijdSnNzBruajTfMWfBXNpqA7tbpynTvrSf6PuBzaSCQxB77op9e22QeBHaDeBpGTyhGTneg)lgKXl1RjLeOT7Cs(wakGj8qtgd1oWybeTrG9drFq1ipaz4eurECidegCpn)JQIi4DNNEc7c0tPdgalN61faJfAtMqaeOZGuk2IEe2wVssBpeBV(3bMW2sdSqKTnbA7oNeBV2)3wfX2pb4wKbAlAlADk1w0GDGrqSvj2gVuHYOA7bS9)bBBayB7lTndp3jtTv78SvZIbz8s9AsjbA7oNKVfGIx49J4L61dVssu7aJfqXehjqB35KGQIiW1pYWZDwMHBrgOT4a6P0c3HJNPsKqzhyeKYmClYaTfhqpLwGLDBQRoWiifONsroawbwwIK3DE6jSlqpLoyaSCQxxamwOnzciqNBgKsXw0GrcyFAls49oXZDBroGTWKWXZ2QjJr(fBrpcB712(UZtpHTTAB7bOmWwN)2MaTDNtBj(llgKXl1RjLeOT7Cs(wakGj8qtgJGQIiWbgbPa9ukYbWkWYsK4aJGuKpHmyOncmrVUallrY7op9e2fONshmawo1Rlagl0MmbeORItK5x1LVM8NxZAwRa]] )

end
