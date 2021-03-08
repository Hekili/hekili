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


    spec:RegisterPack( "Shadow", 20210307, [[da135bqivv5rku1LOikQnPQYNuvvzukuoLcPvrru6vGcZcL0TOOISlv8lkcdJIshdLyzGIEMiuMgfrUMQQY2OOcFJIOACGsvNtHkvRtKunpvf6EIO9PQOdQqfleuYdbLYePOQlQQQQnQQG(OcvkJuvbCsrsPvsr6LuefAMkuj3KIkTtfIFkskgkffhLIOilLIkQEkunvrIRksYwfH8vrOAVk6VQYGjDyjlwbpwLMmQUmXMHYNrXOPuNMQvtrfLxlcMTOUnf2Tu)wPHtjhhuQSCGNdz6cxhKTdQ(ok14vvGoVQsRNIOG5lsTFKNSmtzIZRqMJatZctwmBIzwt(bMWmXm5We2pXJVwYe3QUjumYeVldzIJBx8L9e3Q(M3IptzIJwiWvM42ryHsDtycgpSHgo31Wei3akxHV9fuyHjqUX1et8biphP2EomX5viZrGPzHjlMnXmRj)atyMyMdtc2pXlOWEbtCC3a2M42oNl9CyIZf0DIJBx8LnPMb4ckitn3cCTjLfwjfMMfMSqMsMMcBPsG0eToN0uwaq6Gu22stAuagji9UqDGiTacPyl4k8Zep7OantzIFzFNPmhHLzktCPRHSWNWAIdHKhBBplVBHcVzMJWYeVUHV9ehjfWBMx7m2HrbKj(97nlVOamsGMJWYe)c8qaEnXhJu4fWRHSCqsb8M51oJDyua5DHIfdJ0FK(hPWlGxdz5yTB(HTG3LJiDustNM0XiLVXbzx8L9J9c4pRY7dqWacYUgYcP)ifzj58lkaJeOJH38hskaPFsklKo6eNlOlWTcF7jEQqcP4sb8MH0rCg7WOacPogPFxisz75mP2EqQ0leJnPrbyKarA1CsnZYwaKMABmiKVnPvZjnrRZXwGbPfqiT3GuGu8VSs6cinwsbcgqq2KIN4PUziDBsd2lPlGuJfiKgfGrc0zgZrG5mLjU01qw4tynXHqYJTTNL3TqH3mZryzIx3W3EIJKc4nZRDg7WOaYe)(9MLxuagjqZryzIFbEiaVM4rLLooiPaEZ8ANXomkGCKUgYcN0FKY34GSl(Y(XEb8Nv59biyabzxdzH0FKISKC(ffGrc0XWB(djfG0pjfMtCUGUa3k8TN442liif2CWfYdsXLc4ndPJ4m2HrbesVBZ9W3M0yjnbrSifpXtDZqkKfPEt64S))mMJKyZuM4sxdzHpH1eF7833L9DIZYeVUHV9e3WB(BixOyIZf0f4wHV9eF7833L9LuJkbbrAylKw3W3M0TZFjfcvdzHuoeWBgsV2v3s2BgsRMtAVbPfI0IuGWaLlaP1n8TpZygtCUbZlaENGeOzkZryzMYex6Ail8jSM4DzitCEbsWy3(XLBcVNfuae0v6RmXRB4BpX5fibJD7hxUj8EwqbqqxPVYmMJaZzktCPRHSWNWAI3LHmXrq9qEx(RmKW(lkM41n8TN4iOEiVl)vgsy)ffZyosIntzIlDnKf(ewt8UmKjot(RL9BXEfc5gEUcF7jEDdF7jot(RL9BXEfc5gEUcF7zmhXKMPmXLUgYcFcRjExgYeNdKIJ5a5bxqijpXRB4BpX5aP4yoqEWfesYZygtCUGvq5yMYCewMPmXLUgYcFcRjoxqxGBf(2tCZSHVnAIx3W3EIJ8S0xzgZrG5mLjU01qw4tynXVapeGxt8bimSd815ylW4azrA60KoaHHDSw2c45ngeY3(aznXRB4BpXT2W3EgZrsSzktCPRHSWNWAIVwtCKet86g(2tC4fWRHSmXHxzizIZ34GSl(Y(XEb8Nv59j8BcEZq6ps5BCGxgwoWVVyHU2NWVj4nZehEbEDzitC(gOhK1mMJysZuM4sxdzHpH1eFTM4ijM41n8TN4WlGxdzzIdVYqYeNVXbzx8L9J9c4pRY7t43e8MH0FKY34aVmSCGFFXcDTpHFtWBgs)rkFJdxGVqaVzEw5IbsoHFtWBMjo8c86YqM4vo)4BGEqwZyoY)MPmXLUgYcFcRj(AnXrsmXRB4BpXHxaVgYYehELHKjoYsY5xuagjqhdV5pKuas)KuyskmiDacd7aFDo2cmoqwtCUGUa3k8TN44rbcsHqEZqkUuaVziDeNXomkGqAfKMyWG0OamsGiDbKAsWGuhJ0VlePfqi1Bst06CSfymXHxGxxgYehjfWBMx7m2HrbK3fkwmSzmhXCmtzIlDnKf(ewt81AIJKyIx3W3EIdVaEnKLjo8kdjt87Uz(YUpWxN)eaKv4BFGSi9hPJr6FKckN)e4shNIZrhilstNMuq58Nax64uCo6WHav4Bt6htsklML00Pjfuo)jWLoofNJoaXO8gr6NjjLfZskmi9FKAYs6yKgvw64yd1mcWBMh815hPRHSWjnDAsVlCPRooj8f4vt6OKokP)iDmshJuq58Nax64uCo64nPFskmnlPPttkYsY5xuagjqh4RZFcaYk8Tj9ZKK(pshL00PjnQS0XXgQzeG3mp4RZpsxdzHtA60KEx4sxDCs4lWRM0rN4CbDbUv4BpXHTDZ8LDtQz2ntAIkGxdzHvstfs4KglPw7MjDqWwGqADdhEfEZqk815ylW4qkSbbash5VKcHeoPXs6D7aSzszBlnPXsADdhEfcPWxNJTadsz7HnPEFxdVziT4C0zIdVaVUmKjU1U5h2cExoAgZrm5ZuM4sxdzHpH1e)c8qaEnXhGWWoWxNJTaJdK1eVUHV9ehZbYqEx(mMJa7NPmXLUgYcFcRj(f4Ha8AIpaHHDGVohBbghiRjEDdF7j(GaqcibVzMXCKX9zktCPRHSWNWAIx3W3EINDg7a9mNbXzmKoM4CbDbUv4BpXtfsiDC5m2X)Hi1uioJH0bPogPHTaeslGqkmjDbKASaH0OamsGyL0fqAX5islG0)xqkYQy3EZqk2ci1ybcPHD1KAY)h6mXVapeGxtCKLKZVOamsGozNXoqpZzqCgdPds)mjPWK00PjDms)Juq58Nax64uCo6iFqhfistNMuq58Nax64uCo64nPFsQj)FKo6mMJWIzNPmXLUgYcFcRj(f4Ha8AIpaHHDGVohBbghiRjEDdF7jE1xbfGk)UvopJ5iSWYmLjU01qw4tynXRB4BpXVvo)QB4B)YokM4zhfVUmKj(L9DgZrybMZuM4sxdzHpH1eVUHV9eha1V6g(2VSJIjE2rXRldzIBuEpJzmXTaYDngQyMYCewMPmXLUgYcFcRjEDdF7jU1Ywap2lG)Wwq4bexM4CbDbUv4BpX))pOCHcHt6GGTaH07AmubPdcJ3OdPJZ9kwbI0EBZj7cyGbLjTUHVnI0TZFpt8lWdb41ehigL3is)iPjMzn7mMJaZzktCPRHSWNWAIFbEiaVM4)r6aeg2bzx8Ln2cmoqwt86g(2tCKDXx2ylWygZrsSzktCPRHSWNWAIFbEiaVM4EJQ2JVhUG5xpi9tsz5Ft86g(2t8cCRwEXcashZyoIjntzIlDnKf(ewt81AIJKyIx3W3EIdVaEnKLjo8kdjtCyoXHxGxxgYe3WB(djf4DHIfdBgZr(3mLjEDdF7jo8YWYb(9fl01EIlDnKf(ewZygt8a4DcsGMPmhHLzktCPRHSWNWAIZf0f4wHV9epviH0Tjf2mpPJd(4ygsJLugji18BkKg(nbVziTAoPYh0YbcPXsA2BHuilshKieaPS9WM0eTohBbgt8UmKjUyy9fiv(TaEx9vM4xGhcWRj(D3mFz3h4RZFcaYk8TpaXO8gr6htsklWK00Pj9UBMVS7d815pbazf(2hGyuEJi9tsHPjFIx3W3EIlgwFbsLFlG3vFLzmhbMZuM4sxdzHpH1eNlOlWTcF7jo(3(sAQ1KjZtkBpSjnrRZXwGXeVldzI7n6cGIAilpyhu1bKXJlW9RmXVapeGxt87Uz(YUpWxN)eaKv4BFaIr5nI0pjLfZoXRB4BpX9gDbqrnKLhSdQ6aY4Xf4(vMXCKeBMYex6Ail8jSM4CbDbUv4BpXX)2xsXTfji1CHq(Lu2EytAIwNJTaJjExgYe3OU1aqEiBrINbeYVt8lWdb41e)UBMVS7d815pbazf(2hGyuEJi9tszXSt86g(2tCJ6wda5HSfjEgqi)oJ5iM0mLjU01qw4tynX7YqM4OfkNLi8M5bGg(oXVFVz5ffGrc0CewM4xGhcWRj(aeg2XAzlGN3yqiF7dKfPPtt6FKAbCbfhKKXEwlBb88gdc5BpXRB4BpXrluolr4nZdan8DIZf0f4wHV9eh)BFj1Co0Wxsz7HnPMzzlastTngeY3MuiuXiSsQrLGqkcciKglPO2TesdBH08YwqbPFaZqAuagjMXCK)ntzIlDnKf(ewtCUGUa3k8TN4PcjKcRIZiK6nY5cPlgPj6djfBbKg2cPyoafKcHesxaPBtkSzEslSqaKg2cPyoafKcHKdP42lii96GlKhK6yKcFDoPcaYk8Tj9UBMVSBsDePSywePlGuJfiKwSRVNjExgYeh5ngu(XKlUxXcqVHIZiVf7HjG96X3j(f4Ha8AIF3nZx29b(68NaGScF7dqmkVrK(zsszXSt86g(2tCK3yq5htU4Efla9gkoJ8wShMa2RhFNXCeZXmLjU01qw4tynX5c6cCRW3EINkKqA2rbPlgPBBobHes5LrXiKgaVtqcePBN)sQJr6haQzeG3mKMO15KAEzacdJuhrADdhUWkPlG0VlePfqiT3G0OYshcNuVJLupot86g(2t8BLZV6g(2VSJIj(f4Ha8AIpgP)rAuzPJJnuZiaVzEWxNFKUgYcN00PjLldqyyhBOMraEZ8GVo)azr6OK(J0XiDacd7aFDo2cmoqwKMonP3DZ8LDFGVo)jaiRW3(aeJYBePFsklML0rN4zhfVUmKjo3G5faVtqc0mMJyYNPmXLUgYcFcRjEDdF7joesEEigOjoxqxGBf(2tCZlyfuoifRY5H6MaPylGuiunKfs9qmqPoPPcjKUnP3DZ8LDtQ3KUaUaiD4lPbW7eKGuuEJZe)c8qaEnXhGWWoWxNJTaJdKfPPtt6aeg2XAzlGN3yqiF7dKfPPtt6D3mFz3h4RZFcaYk8TpaXO8gr6NKYIzNXmM4xoAMYCewMPmXLUgYcFcRjEDdF7jU1YwapVXGq(2tCUGUa3k8TN4PcjKAMLTain12yqiFBsz7HnPjADo2cmoK(b2mNuSfqAIwNJTadsVRHGiDXWi9UBMVSBs9M0WwiTLpyqklMLuKC3MJiDdBbW2rcPqiH0Tj9YjfQZccrAylKAgjxmlI0uaLhKcBRXqfKAUc3Jk8Tj1rKgvw6q4Ss6ci1XinSfGqkBpNjT3G0bH0Q3WwaKMO15K()aiRW3M0W2rKI5m2XzIFbEiaVM4waxqXbjzSN1YwapVXGq(2K(J0XiDacd7aFDo2cmoqwKMonP)rkAHYdEZpmGfU88gUZSGk8TpsxdzHt6ps)Ju0cLh8MFURXqfpdH7rf(2hPRHSWj9hP3DZ8LDFGVo)jaiRW3(aeJYBePFMKuwmlPPttkMZyhpGyuEJi9JKE3nZx29b(68NaGScF7dqmkVrKMonPOfkp4n)Waw4YZB4oZcQW3(iDnKfoP)iDmshGWWoaH7a5gc)vTBuhuu3ei9ZKKYcmjnDAsV7M5l7(GvYJbQaCVA0bigL3is)KuwmlPJs6OZyocmNPmXLUgYcFcRjoxqxGBf(2t8uHesHvXzes9g5CH0fJ0e9HKITasdBHumhGcsHqcPlG0Tjf2mpPfwiasdBHumhGcsHqYH0e3dBshXzSds)Wsi1EZCsXwaPj6dpt8UmKjoYBmO8JjxCVIfGEdfNrEl2dta71JVt8lWdb41eFacd7aFDo2cmoqwKMonPHBiK(jPSyws)r6yK(hP3fU0vhN2zSJhwjKo6eVUHV9eh5ngu(XKlUxXcqVHIZiVf7HjG96X3zmhjXMPmXLUgYcFcRjEDdF7jowjpgOcW9QrtCUGUa3k8TN4PcjK(HLq64gub4E1is3MuyZ8KUqbY5cPlgPjADo2cmoKMkKq6hwcPJBqfG7vZrK6nPjADo2cmi1Xi97crQDbxiv8WwaKoUbw4cPP2gUZSGk8TjDbK(HUK5KUyKcR8IqRb6mXVapeGxt8)iDacd7aFDo2cmoqwK(J0Xi9psV7M5l7(aFD(lwaq64azrA60K(hPrLLooWxN)IfaKoosxdzHt6OKMonPdqyyh4RZXwGXbYI0FKogPOfkp4n)Waw4YZB4oZcQW3(iDnKfoPPttkAHYdEZpyUK5Vf7nKxeAnqhPRHSWjD0zmhXKMPmXLUgYcFcRjEDdF7jUH3CMYqqt873BwErbyKanhHLj(f4Ha8AI7nQAp(s6hjDC3SK(J0XiDmsHxaVgYYPY5hFd0dYI0FKogP)r6D3mFz3h4RZFcaYk8TpqwKMonP)rAuzPJJnuZiaVzEWxNFKUgYcN0rjDustNM0bimSd815ylW4azr6OK(J0Xi9psJklDCSHAgb4nZd(68J01qw4KMonPCzacd7yd1mcWBMh815hilstNM0)iDacd7aFDo2cmoqwKokP)iDms)J0OYshhKuaVzETZyhgfqosxdzHtA60KISKC(ffGrc0XWB(djfG0ps6)iD0joxqxGBf(2t8uHesnxV5mLHGiLTT0Kw5mPjgPMFtbrAbesHSyL0fq63fI0ciK6nPjADo2cmoK()ncciK(bGAgb4ndPjADoPoI06goCH0TjnSfsJcWibPogPrLLoe(Hu8yTifc5ndPvq6)GbPrbyKarkBpSjfxkG3mKoIZyhgfqoZyoY)MPmXLUgYcFcRjEDdF7jouBV5VVEHxtCUGUa3k8TN4PcjKMQ2EZFjDKfEr62KcBMNvsT3m3BgshaUGL)sASKYU8GuSfqQ1YwaK6ngeY3M0fqAX5KISk2n6mXVapeGxt8XiDms)Juq58Nax64uCo6azr6psbLZFcCPJtX5OJ3K(jPW0SKokPPttkOC(tGlDCkohDaIr5nI0ptskl)J00Pjfuo)jWLoofNJoCiqf(2K(rsz5FKokP)iDmshGWWowlBb88gdc5BFGSinDAsV7M5l7(yTSfWZBmiKV9bigL3is)mjPSywstNM0)i1c4ckoijJ9Sw2c45ngeY3M0rj9hPJr6FKgvw64yd1mcWBMh815hPRHSWjnDAs5Yaeg2XgQzeG3mp4RZpqwKMonP)r6aeg2b(6CSfyCGSiD0zmhXCmtzIlDnKf(ewt86g(2t8HD73I9cB5vOR0CHpX5c6cCRW3EINkKq62KcBMN0bOGulGVapCKqkeYBgst06Cs)FaKv4BtkMdqbRK6yKcHeoPEJCUq6IrAI(qs3Mu8uifcjKwyHaiTif(68HnhKITasV7M5l7MubdZVU03VKwnNuSfqQnuZiaVzif(6CsHSc3qi1XinQS0HWpt8lWdb41e)pshGWWoWxNJTaJdKfP)i9psV7M5l7(aFD(taqwHV9bYI0FKISKC(ffGrc0XWB(djfG0pjLfs)r6FKgvw64GKc4nZRDg7WOaYr6AilCstNM0XiDacd7aFDo2cmoqwK(JuKLKZVOamsGogEZFiPaK(rsHjP)i9psJklDCqsb8M51oJDyua5iDnKfoP)iDmsTac8hZLFy5aFD(ByZbP)iDms)Jub2b5wwc)igwFbsLFlG3vFfstNM0)inQS0XXgQzeG3mp4RZpsxdzHt6OKMonPcSdYTSe(rmS(cKk)waVR(kK(J07Uz(YUpIH1xGu53c4D1x5aeJYBePFmjPSyoGjP)iLldqyyhBOMraEZ8GVo)azr6OKokPPtt6yKoaHHDGVohBbghils)rAuzPJdskG3mV2zSdJcihPRHSWjD0zmhXKptzIlDnKf(ewt86g(2t8BLZV6g(2VSJIjE2rXRldzIhaVtqc0mMXeFy3EMYCewMPmXLUgYcFcRjEDdF7jEHUsZf(BixOyIZf0f4wHV9eFCmZ4I0yjfcjKY2wAsH1UnPlgPHTq64GUsZfoPoI06goCzIFbEiaVM4iljNFrbyKaDm8M)qsbi9JjjnXMXCeyotzIlDnKf(ewt8lWdb41epkaJeh2Ey7nSN0FKISKC(ffGrc0PqxP5c)1l8I0pjLfs)rkYsY5xuagjqhdV5pKuas)KuwifgKgvw64GKc4nZRDg7WOaYr6Ail8jEDdF7jEHUsZf(Rx41mMXe3O8EMYCewMPmXLUgYcFcRjoxqxGBf(2tCZT8M0XXmJlwjfzVqzoP3fUaiTYzsbvZiisxmsJcWibI0Q5KIUsxaFrt86g(2t8BLZV6g(2VSJIjoka(nMJWYe)c8qaEnXhGWWod72Vf7f2YRqxP5c)aznXZokEDzit8HD7zmhbMZuM41n8TN4Chzj5NrX43jU01qw4tynJ5ij2mLjU01qw4tynXRB4BpXHVo)jaiRW3EIZf0f4wHV9epviH0eToN0)hazf(2KUnP3DZ8LDtQ1UzVziTcsZsHcsnjZsQ3OQ94lPdqbP9gK6yK(DHiLTNZKUWfWTSi1Bu1E8LuVjnrF4HuZTsqifbbesr2fFzJ5sZnHH38bP5cG0Q5KAUEZjfw5cfK6is3M07Uz(YUjDqWwGqAI()Ze)c8qaEnXHxaVgYYXA38dBbVlhr6ps9gvThFj9ZKKAsML0FKogPEJQ2JVK(XKKc7)hPPttAuzPJdskG3mV2zSdJcihPRHSWj9hPWlGxdz5GKc4nZRDg7WOaY7cflggPJs6ps)J07Uz(YUpyU08dKfP)iDms)J07Uz(YUpgEZFd5cfhilstNMuKLKZVOamsGogEZFiPaK(jPWK0rNXCetAMYex6Ail8jSM41n8TN4i7IVSFSxa)zvEpX5c6cCRW3EIBUvccPiiGq63fIulOGuilsXt8u3mKoo4JJziDBsdBH0OamsqQJrAIdQWgdkt6hwcWfsDu)FbP1nC4cPSTLMumNXo8MHuwmNsmsJcWib6mXVapeGxt8bimSdwjpgOcW9Qrhils)r6FKYLbimSdBqf2yq5hwjaxoqwK(JuKLKZVOamsGogEZFiPaK(rsnPzmh5FZuM4sxdzHpH1eVUHV9e)w58RUHV9l7OyINDu86YqM4xoAgZrmhZuM4sxdzHpH1eVUHV9e3WB(djfyIF)EZYlkaJeO5iSmXVapeGxt8OYshhKuaVzETZyhgfqosxdzHt6psrwso)IcWib6y4n)HKcq6NKcVaEnKLJH38hskW7cflggP)i9ps5BCq2fFz)yVa(ZQ8(e(nbVzi9hP)r6D3mFz3hmxA(bYAIZf0f4wHV9e)d4m2KAgGVap(sQ56nNuCPaKw3W3M0yjfiyabztQ53uqKY2dBsrsb8M51oJDyuazgZrm5ZuM4sxdzHpH1eVUHV9eNxgDf(2t873BwErbyKanhHLj(f4Ha8AI)hPWlGxdz5u58JVb6bznX5c6cCRW3EIBgGGjasJLuiKqQ5lJUcFBshh8XXmK6yKw9xsn)McPoI0EdsHSoZyocSFMYex6Ail8jSM41n8TN4WxN)g2CmX5c6cCRW3EINkKqAIwNtkS2CqAfKA7m2cGulGVap(skBpSj9da1mcWBgst06CsHSinwsnjsJcWibIvsxaPBylasJklDGiDBsXt5mXVapeGxtCVrv7Xxs)yssH9)J0FKgvw64yd1mcWBMh815hPRHSWj9hPrLLooiPaEZ8ANXomkGCKUgYcN0FKISKC(ffGrc0XWB(djfG0pMKuZbPPtt6yKogPrLLoo2qnJa8M5bFD(r6AilCs)r6FKgvw64GKc4nZRDg7WOaYr6AilCshL00Pjfzj58lkaJeOJH38hskaPjjLfshDgZrg3NPmXLUgYcFcRjEDdF7joxGVqaVzEw5IbsM4CbDbUv4BpXn)2)xqkesi18c8fc4ndPMjxmqcPogPFxisVvtkJeK6DSKMO15ylWGuVrHuCwjDbK6yKIlfWBgshXzSdJciK6isJklDiCsRMtkBpNj12dsLEHySjnkaJeOZe)c8qaEnXhJuGGbeKDnKfstNMuVrv7Xxs)Kut()iDus)r6yK(hPWlGxdz5yTB(HTG3LJinDAs9gvThFj9ZKKc7)hPJs6pshJ0)inQS0XbjfWBMx7m2HrbKJ01qw4KMonPJrAuzPJdskG3mV2zSdJcihPRHSWj9hP)rk8c41qwoiPaEZ8ANXomkG8UqXIHr6OKo6mMJWIzNPmXLUgYcFcRjEDdF7jo815VHnhtCUGUa3k8TN4PcjKMiyr62KcBMNuhJ0VleP8T)VG0weoPXs6TqbPMxGVqaVzi1m5IbsyL0Q5Kg2cqiTacPzbHinSRMutI0OamsGiDHcsh7FKY2dBsVBZH8y0Ze)c8qaEnXrwso)IcWib6y4n)HKcq6hjDmsnjsHbP3T5qEC4ocTD1XtU2RGosxdzHt6OK(JuVrv7Xxs)yssH9)J0FKgvw64GKc4nZRDg7WOaYr6AilCstNM0)inQS0XbjfWBMx7m2HrbKJ01qw4ZyoclSmtzIlDnKf(ewt86g(2tCKDXx2p2lG)4sf2t873BwErbyKanhHLj(f4Ha8AIpgPrbyK4ylvoSpw3G0pskmnlP)ifzj58lkaJeOJH38hskaPFKutI0rjnDAshJuljoyU08tDdhUq6psbqTGTag5GSl(YglxgYZc4iJJa7GCllHt6OtCUGUa3k8TN4PcjKIBx8LnPj(c4PoPMxQWMuhJ0WwinkaJeK6isRHfkinws5Uq6ci97crQDbxif3U4lBSCziKAgGJmivGDqULLWjLTh2KAUEZhKMlasxaP42fFzJ5sZjTUHdxoZyoclWCMYex6Ail8jSM41n8TN4iiaqAUaEX(mkEli0e)(9MLxuagjqZryzIFbEiaVM4rbyK4eUH8I9XDH0pskm)hP)iDacd7aFDo2cmo8LDpX5c6cCRW3EINkKqkoeainxaKglPMBXBbHiDBslsJcWibPHDfK6iszwVzinws5UqAfKg2cPaNXoinCd5mJ5iSKyZuM4sxdzHpH1eVUHV9eh(68xSaG0Xe)(9MLxuagjqZryzIFbEiaVM4WlGxdz5W3a9GSi9hPrbyK4eUH8I9XDH0pjnXi9hPJr6aeg2b(6CSfyC4l7M00PjDacd7aFDo2cmoaXO8gr6hj9UBMVS7d815VHnhhGyuEJiDus)rADdhU84BCGxgwoWVVyHU2KMKuKLKZVOamsGoWldlh43xSqxBs)rkYsY5xuagjqhdV5pKuas)iPJr6)ifgKogPMdsnzjnQS0Xjy7O4TypSkKJ01qw4KokPJoX5c6cCRW3EINkKqAIwNtAklaiDq625VK6yKIN4PUziTAoPjkfslGqADdhUqA1CsdBH0Oamsqk7T)VGuUlKYHaEZqAylKETRUL8zgZryXKMPmXLUgYcFcRj(f4Ha8AIZ34aVmSCGFFXcDTpHFtWBgs)r6yKgvw64GKc4nZRDg7WOaYr6AilCs)rkYsY5xuagjqhdV5pKuas)Ku4fWRHSCm8M)qsbExOyXWinDAs5BCq2fFz)yVa(ZQ8(e(nbVziDus)r6yK(hPaOwWwaJCq2fFzJLld5zbCKXrGDqULLWjnDAsRB4WLhFJd8YWYb(9fl01M0KKISKC(ffGrc0bEzy5a)(If6At6Ot86g(2tCdV5dsZfWmMJWY)MPmXLUgYcFcRjEDdF7joYU4l7h7fWFCPc7joxqxGBf(2t8uHesXt8u38KY2dBsnt59aqQeeaPMbvzdsH6SGqKg2cPrbyKGu2Eot6Gq6GKx2KctZAYmPdc2cesdBH07Uz(YUj9UgcI0H6MWe)c8qaEnXbqTGTag5yvEpaKkbb8Sqv24iWoi3Ys4K(Ju4fWRHSC4BGEqwK(J0OamsCc3qEX(SUXdMML0pjDmsV7M5l7(GSl(Y(XEb8hxQW(WHav4BtkmiL5YjD0zmhHfZXmLjU01qw4tynXRB4BpXr2fFz)UGczpX5c6cCRW3EINkKqkUDXx2KcBGczt62KcBMNuOoliePHTaeslGqAX5is9(UgEZCM4xGhcWRjoOC(tGlDCkohD8M0pjLfZoJ5iSyYNPmXLUgYcFcRj(f4Ha8AIJSKC(ffGrc0XWB(djfG0pjfEb8AilhdV5pKuG3fkwmms)r6aeg2HxGeEH9cXyhhiRjoxqxGBf(2t8uHesnxV5KIlfG0yj9UncYqi18fibstXEHySdePwG9IiDBshNuZ)FinLuJ5tnKcBBJ5adsDePHTJi1rKwKA7m2cGulGVap(sAyxnPaHVr4ndPBt64KA(FsH6SGqKYlqcKg2leJDGi1rKwdluqASKgUHq6cft873BwErbyKanhHLjU3HaaqwXZXM4HFta9zsyoX9oeaaYkEUHHW9kKjolt8RD59eNLjEDdF7jUH38hskWmMJWcSFMYex6Ail8jSM4CbDbUv4BpXtfsi1C9Mt6hMRVKglP3TrqgcPMVajqAk2leJDGi1cSxePBtkEkhstj1y(udPW22yoWGuhJ0W2rK6islsTDgBbqQfWxGhFjnSRMuGW3i8MHuOolieP8cKaPH9cXyhisDeP1WcfKglPHBiKUqXe)c8qaEnXhGWWo8cKWlSxig74azr6psHxaVgYYHVb6bznX9oeaaYkEo2ep8BcOptcZF3DZ8LDFGVo)nS54aznX9oeaaYkEUHHW9kKjolt8RD59eNLjEDdF7jUH38hwU(oJ5iSmUptzIlDnKf(ewt86g(2tCdV5VHCHIjoxqxGBf(2t8uHesnxV5KcRCHcsDms)UqKY3()csBr4KglPabdiiBsn)Mc6qkESwKElu4ndPvqQjr6ci1ybcPrbyKarkBpSjfxkG3mKoIZyhgfqinQS0HWjTAoPFxislGqAVbPqiVzif3U4lBSCziKAgGJmiDbKAg03RTFjDC5DcNj(f4Ha8AIdVaEnKLdFd0dYI0FKckN)e4shhJfUyiDC8M0pj9wO4fUHqkmi1SN)r6psrwso)IcWib6y4n)HKcq6hjDmsnjsHbPWKutwsJklDCmCKa(EKUgYcNuyqADdhU84BCGxgwoWVVyHU2KAYsAuzPJJf6712VVS3jCKUgYcN0rNXCeyA2zktCPRHSWNWAIx3W3EIdVmSCGFFXcDTN4xGhcWRjoqWacYUgYcP)inkaJeNWnKxSpUlK(jPMdstNM0XinQS0XXWrc47r6AilCs)rkFJdYU4l7h7fWFwL3hGGbeKDnKfshL00PjDacd7a1yqGS3mpEbsOfe6aznXVFVz5ffGrc0CewMXCeyYYmLjU01qw4tynXRB4BpXr2fFz)yVa(ZQ8EIZf0f4wHV9eh3sUELj9Un3dFBsJLuuSwKElu4ndP4jEQBgs3M0fdZCkkaJeiszBlnPyoJD4ndPjgPlGuJfiKII6MGWj1yhqKwnNuiK3mKAg03RTFjDC5DcKwnN0rsnPqQ56ib89mXVapeGxtCGGbeKDnKfs)rAuagjoHBiVyFCxi9tsnjs)r6FKgvw64y4ib89iDnKfoP)inQS0XXc99A73x27eosxdzHt6psrwso)IcWib6y4n)HKcq6NKcZzmhbMWCMYex6Ail8jSM41n8TN4i7IVSFSxa)zvEpXVFVz5ffGrc0CewM4xGhcWRjoqWacYUgYcP)inkaJeNWnKxSpUlK(jPMeP)i9psJklDCmCKa(EKUgYcN0FK(hPJrAuzPJdskG3mV2zSdJcihPRHSWj9hPiljNFrbyKaDm8M)qsbi9tsHxaVgYYXWB(djf4DHIfdJ0rj9hPJr6FKgvw64yH(ET97l7DchPRHSWjnDAshJ0OYshhl03RTFFzVt4iDnKfoP)ifzj58lkaJeOJH38hskaPFmjPWK0rjD0joxqxGBf(2tCtgfXIu8ep1ndPqwKUnPfIuJQ)sAuagjqKwisTweYhYcRKkFWRyfKY2wAsXCg7WBgstmsxaPglqiff1nbHtQXoGiLTh2KAg03RTFjDC5DcNzmhbMj2mLjU01qw4tynXRB4BpXn8M)qsbM43V3S8IcWibAocltCVdbaGSINJnXd)Ma6ZKWCI7DiaaKv8CddH7vitCwM4xGhcWRjoYsY5xuagjqhdV5pKuas)Ku4fWRHSCm8M)qsbExOyXWM4x7Y7jolZyocmnPzktCPRHSWNWAIx3W3EIB4n)HLRVtCVdbaGSINJnXd)Ma6ZKW83D3mFz3h4RZFdBooqwtCVdbaGSINByiCVczIZYe)AxEpXzzgZrG5)MPmXLUgYcFcRjoxqxGBf(2t8uHesXt8u38KwisZfkifiOfeK6yKUnPHTqQXcxM41n8TN4i7IVSFSxa)XLkSNXCeyAoMPmXLUgYcFcRjoxqxGBf(2t8uHesXt8u3mKwisZfkifiOfeK6yKUnPHTqQXcxiTAoP4jEQBEsDePBtkSz(jEDdF7joYU4l7h7fWFwL3ZygZyIdxaiF75iW0SWKfZYcmzzIZUaT3mOjEIpoMZhj1oY4wQtkPPylK6gwliifBbK(Fxo6)ifiWoihiCsrRHqAbfRrfcN0RD1mc6qMoU8wi1CK6KcBBdxaHWj9)cG3jiXPgUN7Uz(YU)psJL0)7UBMVS7tnC)pshJLp4OhYuY0uRH1ccHtkSN06g(2KMDuGoKPtClWI5zzIpEsXTl(YMuZaCbfKPJNuZTaxBszHvsHPzHjlKPKPJN0uylvcKMO15KMYcashKY2wAsJcWibP3fQdePfqifBbxHFitjthpP))huUqHWjDqWwGq6DngQG0bHXB0H0X5EfRarAVT5KDbmWGYKw3W3gr625VhY06g(2OJfqURXqfWiPjSw2c4XEb8h2ccpG4cRowsGyuEJ(yIzwZsMw3W3gDSaYDngQagjnbYU4lBSfyWQJL8VbimSdYU4lBSfyCGSitRB4BJowa5UgdvaJKMOa3QLxSaG0bRowsVrv7X3dxW8RhFYY)itRB4BJowa5UgdvaJKMaEb8AilS2LHK0WB(djf4DHIfdJ11kjscwHxzijjmjtRB4BJowa5UgdvaJKMaEzy5a)(If6AtMsMoEsnZg(2iY06g(2OKipl9vitRB4BJsATHVnRowYbimSd815ylW4azLo9aeg2XAzlGN3yqiF7dKfzADdFBemsAc4fWRHSWAxgss(gOhKfRRvsKeScVYqss(ghKDXx2p2lG)SkVpHFtWBMF8noWldlh43xSqx7t43e8MHmTUHVncgjnb8c41qwyTldjzLZp(gOhKfRRvsKeScVYqss(ghKDXx2p2lG)SkVpHFtWBMF8noWldlh43xSqx7t43e8M5hFJdxGVqaVzEw5IbsoHFtWBgY0XtkEuGGuiK3mKIlfWBgshXzSdJciKwbPjgminkaJeisxaPMemi1Xi97crAbes9M0eTohBbgKP1n8TrWiPjGxaVgYcRDzijrsb8M51oJDyua5DHIfdJ11kjscwHxzijjYsY5xuagjqhdV5pKuGpHjmgGWWoWxNJTaJdKfz64jf22nZx2nPMz3mPjQaEnKfwjnviHtASKATBM0bbBbcP1nC4v4ndPWxNJTaJdPWgeaiDK)skes4KglP3TdWMjLTT0KglP1nC4viKcFDo2cmiLTh2K69Dn8MH0IZrhY06g(2iyK0eWlGxdzH1UmKKw7MFyl4D5iwxRKijyfELHKK3DZ8LDFGVo)jaiRW3(az9BS)aLZFcCPJtX5OdKv60GY5pbU0XP4C0HdbQW3(JjzXSPtdkN)e4shNIZrhGyuEJ(mjlMfg)ZKDSOYshhBOMraEZ8GVo)iDnKfE603fU0vhNe(c8QhD0FJngOC(tGlDCkohD8(tyA20Prwso)IcWib6aFD(taqwHV9Nj)3OPthvw64yd1mcWBMh815hPRHSWtN(UWLU64KWxGx9OKP1n8TrWiPjWCGmK3LZQJLCacd7aFDo2cmoqwKP1n8TrWiPjgeasaj4ndRowYbimSd815ylW4azrMoEstfsiDC5m2X)Hi1uioJH0bPogPHTaeslGqkmjDbKASaH0OamsGyL0fqAX5islG0)xqkYQy3EZqk2ci1ybcPHD1KAY)h6qMw3W3gbJKMi7m2b6zodIZyiDWQJLezj58lkaJeOt2zSd0ZCgeNXq64ZKWmD6X(duo)jWLoofNJoYh0rbkDAq58Nax64uCo649NM8)nkzADdFBemsAIQVckav(DRCMvhl5aeg2b(6CSfyCGSitRB4BJGrstCRC(v3W3(LDuWAxgsYl7lzADdFBemsAcau)QB4B)YokyTldjPr5nzkz64jDCmZ4I0yjfcjKY2wAsH1UnPlgPHTq64GUsZfoPoI06goCHmTUHVn6mSBNSqxP5c)nKluWQJLezj58lkaJeOJH38hskWhtMyKP1n8TrNHDByK0ef6knx4VEHxS6yjJcWiXHTh2Ed7)HSKC(ffGrc0PqxP5c)1l86tw(HSKC(ffGrc0XWB(djf4twGruzPJdskG3mV2zSdJcihPRHSWjtjthpPWM5rKPJN0uHesnZYwaKMABmiKVnPS9WM0eTohBbghs)aBMtk2cinrRZXwGbP31qqKUyyKE3nZx2nPEtAylK2YhmiLfZsksUBZrKUHTay7iHuiKq62KE5Kc1zbHinSfsnJKlMfrAkGYdsHT1yOcsnxH7rf(2K6isJklDiCwjDbK6yKg2cqiLTNZK2Bq6GqA1Bylast06Cs)FaKv4BtAy7isXCg74qMw3W3gDUCusRLTaEEJbH8Tz1XsAbCbfhKKXEwlBb88gdc5B)BSbimSd815ylW4azLo9FOfkp4n)Waw4YZB4oZcQW3(iDnKf(V)qluEWB(5Ugdv8meUhv4BFKUgYc)3D3mFz3h4RZFcaYk8TpaXO8g9zswmB60yoJD8aIr5n6J3DZ8LDFGVo)jaiRW3(aeJYBu60Ofkp4n)Waw4YZB4oZcQW3(iDnKf(VXgGWWoaH7a5gc)vTBuhuu3e(mjlWmD67Uz(YUpyL8yGka3RgDaIr5n6twm7OJsMoEstfsif3ZsFfs3MuyZ8KglPwG9skUyzdzYW)Hi1mG9MlJk8TpKPJN06g(2OZLJGrstG8S0xH1Oams8CSKaOwWwaJCqILnKjdONfyV5YOcF7Ja7GCllH)BSOamsCC0R480PJcWiXHldqyyNBHcVzoaPUXOKPJN0uHesHvXzes9g5CH0fJ0e9HKITasdBHumhGcsHqcPlG0Tjf2mpPfwiasdBHumhGcsHqYH0e3dBshXzSds)Wsi1EZCsXwaPj6dpKP1n8TrNlhbJKMacjppedw7YqsI8gdk)yYf3RybO3qXzK3I9WeWE94lRowYbimSd815ylW4azLoD4gYNSy2FJ93DHlD1XPDg74HvYOKPJN0uHes)WsiDCdQaCVAePBtkSzEsxOa5CH0fJ0eTohBbghstfsi9dlH0XnOcW9Q5is9M0eTohBbgK6yK(DHi1UGlKkEylash3alCH0uBd3zwqf(2KUas)qxYCsxmsHvErO1aDitRB4BJoxocgjnbwjpgOcW9QrS6yj)Bacd7aFDo2cmoqw)g7V7Uz(YUpWxN)IfaKooqwPt)xuzPJd815VybaPJJ01qw4JMo9aeg2b(6CSfyCGS(ngAHYdEZpmGfU88gUZSGk8TpsxdzHNonAHYdEZpyUK5Vf7nKxeAnqhPRHSWhLmD8KMkKqQ56nNPmeePSTLM0kNjnXi18BkislGqkKfRKUas)UqKwaHuVjnrRZXwGXH0)VrqaH0pauZiaVzinrRZj1rKw3WHlKUnPHTqAuagji1XinQS0HWpKIhRfPqiVziTcs)hminkaJeisz7HnP4sb8MH0rCg7WOaYHmTUHVn6C5iyK0egEZzkdbX697nlVOamsGsYcRowsVrv7X3poUB2FJng8c41qwovo)4BGEqw)g7V7Uz(YUpWxN)eaKv4BFGSsN(VOYshhBOMraEZ8GVo)iDnKf(OJMo9aeg2b(6CSfyCGSg93y)fvw64yd1mcWBMh815hPRHSWtNMldqyyhBOMraEZ8GVo)azLo9Fdqyyh4RZXwGXbYA0FJ9xuzPJdskG3mV2zSdJcihPRHSWtNgzj58lkaJeOJH38hskWh)3OKPJN0uHestvBV5VKoYcViDBsHnZZkP2BM7ndPdaxWYFjnwszxEqk2ci1Azlas9gdc5Bt6ciT4Csrwf7gDitRB4BJoxocgjnbuBV5VVEHxS6yjhBS)aLZFcCPJtX5OdK1pq58Nax64uCo649NW0SJMonOC(tGlDCkohDaIr5n6ZKS8V0PbLZFcCPJtX5OdhcuHV9hz5FJ(BSbimSJ1YwapVXGq(2hiR0PV7M5l7(yTSfWZBmiKV9bigL3OptYIztN(plGlO4GKm2ZAzlGN3yqiF7r)n2FrLLoo2qnJa8M5bFD(r6Ail80P5Yaeg2XgQzeG3mp4RZpqwPt)3aeg2b(6CSfyCGSgLmD8KMkKq62KcBMN0bOGulGVapCKqkeYBgst06Cs)FaKv4BtkMdqbRK6yKcHeoPEJCUq6IrAI(qs3Mu8uifcjKwyHaiTif(68HnhKITasV7M5l7MubdZVU03VKwnNuSfqQnuZiaVzif(6CsHSc3qi1XinQS0HWpKP1n8TrNlhbJKMyy3(TyVWwEf6knx4S6yj)Bacd7aFDo2cmoqw)(7UBMVS7d815pbazf(2hiRFiljNFrbyKaDm8M)qsb(KLF)fvw64GKc4nZRDg7WOaYr6Ail80PhBacd7aFDo2cmoqw)qwso)IcWib6y4n)HKc8ry(7VOYshhKuaVzETZyhgfqosxdzH)BmlGa)XC5hwoWxN)g2C8BS)eyhKBzj8Jyy9fiv(TaEx9vsN(VOYshhBOMraEZ8GVo)iDnKf(OPtlWoi3Ys4hXW6lqQ8Bb8U6R8laENGehXW6lqQ8Bb8U6RCU7M5l7(aeJYB0htYI5aM)4Yaeg2XgQzeG3mp4RZpqwJoA60JnaHHDGVohBbghiRFrLLooiPaEZ8ANXomkGCKUgYcFuY06g(2OZLJGrstCRC(v3W3(LDuWAxgsYa4DcsGitjthpPWwHcstCBplKcBfk8MH06g(2OdP4sqAfKA7m2cGulGVap(sASKISxqq61bxipi17qaaiRG072Cp8TrKUnPMR3CsXLcyIpmxFjthpPPcjKIlfWBgshXzSdJciK6yK(DHiLTNZKA7bPsVqm2KgfGrcePvZj1mlBbqAQTXGq(2KwnN0eTohBbgKwaH0EdsbsX)YkPlG0yjfiyabztkEIN6MH0TjnyVKUasnwGqAuagjqhY06g(2OZL9njskG3mV2zSdJciScHKhBBplVBHcVzsYcR3V3S8IcWibkjlS6yjhdEb8AilhKuaVzETZyhgfqExOyXW(9h8c41qwow7MFyl4D5OrtNEm(ghKDXx2p2lG)SkVpabdii7Ail)qwso)IcWib6y4n)HKc8jlJsMoEsXTxqqkS5GlKhKIlfWBgshXzSdJciKE3M7HVnPXsAcIyrkEIN6MHuils9M0Xz)FY06g(2OZL9fgjnbskG3mV2zSdJciScHKhBBplVBHcVzsYcR3V3S8IcWibkjlS6yjJklDCqsb8M51oJDyua5iDnKf(p(ghKDXx2p2lG)SkVpabdii7Ail)qwso)IcWib6y4n)HKc8jmjthpPBN)(USVKAujiisdBH06g(2KUD(lPqOAilKYHaEZq61U6wYEZqA1Cs7niTqKwKcegOCbiTUHV9HmTUHVn6CzFHrsty4n)nKluW625VVl7BswitjtRB4BJoCdMxa8objqjHqYZdXG1UmKK8cKGXU9Jl3eEplOaiOR0xHmTUHVn6WnyEbW7eKabJKMacjppedw7YqsIG6H8U8xziH9xuqMw3W3gD4gmVa4DcsGGrstaHKNhIbRDzijzYFTSFl2Rqi3WZv4BtMw3W3gD4gmVa4DcsGGrstaHKNhIbRDzij5aP4yoqEWfesYKPKPJNuZT8M0XXmJlwjfzVqzoP3fUaiTYzsbvZiisxmsJcWibI0Q5KIUsxaFrKP1n8TrhJYByK0e3kNF1n8TFzhfS2LHKCy3Mvua8BKKfwDSKdqyyNHD73I9cB5vOR0CHFGSitRB4BJogL3WiPj4oYsYpJIXVKPJN0uHest06Cs)FaKv4Bt62KE3nZx2nPw7M9MH0kinlfki1KmlPEJQ2JVKoafK2BqQJr63fIu2Eot6cxa3YIuVrv7Xxs9M0e9Hhsn3kbHueeqifzx8LnMln3egEZhKMlasRMtQ56nNuyLluqQJiDBsV7M5l7M0bbBbcPj6)pKP1n8TrhJY7KWxN)eaKv4BZQJLeEb8AilhRDZpSf8UC0pVrv7X3ptAsM93yEJQ2JVFmjS)FPthvw64GKc4nZRDg7WOaYr6Ail8FWlGxdz5GKc4nZRDg7WOaY7cflg2O)(7UBMVS7dMln)az9BS)U7M5l7(y4n)nKluCGSsNgzj58lkaJeOJH38hskWNWCuY0XtQ5wjiKIGacPFxisTGcsHSifpXtDZq64GpoMH0TjnSfsJcWibPogPjoOcBmOmPFyjaxi1r9)fKw3WHlKY2wAsXCg7WBgszXCkXinkaJeOdzADdFB0XO8ggjnbYU4l7h7fWFwL3S6yjhGWWoyL8yGka3RgDGS(9hxgGWWoSbvyJbLFyLaC5az9dzj58lkaJeOJH38hskWhnjY06g(2OJr5nmsAIBLZV6g(2VSJcw7YqsE5iY0Xt6hWzSj1maFbE8LuZ1BoP4sbiTUHVnPXskqWacYMuZVPGiLTh2KIKc4nZRDg7WOaczADdFB0XO8ggjnHH38hskaR3V3S8IcWibkjlS6yjJklDCqsb8M51oJDyua5iDnKf(pKLKZVOamsGogEZFiPaFcVaEnKLJH38hskW7cflg2V)4BCq2fFz)yVa(ZQ8(e(nbVz(93D3mFz3hmxA(bYImD8KAgGGjasJLuiKqQ5lJUcFBshh8XXmK6yKw9xsn)McPoI0EdsHSoKP1n8TrhJYByK0e8YORW3M173BwErbyKaLKfwDSK)bVaEnKLtLZp(gOhKfz64jnviH0eToNuyT5G0ki12zSfaPwaFbE8Lu2Eyt6haQzeG3mKMO15KczrASKAsKgfGrceRKUas3WwaKgvw6ar62KINYHmTUHVn6yuEdJKMa(683WMdwDSKEJQ2JVFmjS)F)IklDCSHAgb4nZd(68J01qw4)IklDCqsb8M51oJDyua5iDnKf(pKLKZVOamsGogEZFiPaFmP5iD6XglQS0XXgQzeG3mp4RZpsxdzH)7VOYshhKuaVzETZyhgfqosxdzHpA60iljNFrbyKaDm8M)qsbsYYOKPJNuZV9)fKcHesnVaFHaEZqQzYfdKqQJr63fI0B1KYibPEhlPjADo2cmi1BuifNvsxaPogP4sb8MH0rCg7WOacPoI0OYshcN0Q5KY2ZzsT9GuPxigBsJcWib6qMw3W3gDmkVHrstWf4leWBMNvUyGewDSKJbemGGSRHSKoT3OQ947NM8)n6VX(dEb8AilhRDZpSf8UCu60EJQ2JVFMe2)Vr)n2FrLLooiPaEZ8ANXomkGCKUgYcpD6XIklDCqsb8M51oJDyua5iDnKf(V)GxaVgYYbjfWBMx7m2HrbK3fkwmSrhLmD8KMkKqAIGfPBtkSzEsDms)UqKY3()csBr4KglP3cfKAEb(cb8MHuZKlgiHvsRMtAylaH0ciKMfeI0WUAsnjsJcWibI0fkiDS)rkBpSj9UnhYJrpKP1n8TrhJYByK0eWxN)g2CWQJLezj58lkaJeOJH38hskWhhZKGXDBoKhhUJqBxD8KR9kOJ01qw4J(ZBu1E89JjH9)7xuzPJdskG3mV2zSdJcihPRHSWtN(VOYshhKuaVzETZyhgfqosxdzHtMoEstfsif3U4lBst8fWtDsnVuHnPogPHTqAuagji1rKwdluqASKYDH0fq63fIu7cUqkUDXx2y5Yqi1mahzqQa7GCllHtkBpSj1C9MpinxaKUasXTl(YgZLMtADdhUCitRB4BJogL3WiPjq2fFz)yVa(JlvyZ697nlVOamsGsYcRowYXIcWiXXwQCyFSUXhHPz)HSKC(ffGrc0XWB(djf4JM0OPtpMLehmxA(PUHdx(bGAbBbmYbzx8LnwUmKNfWrghb2b5wwcFuY0XtAQqcP4qaG0CbqASKAUfVfeI0TjTinkaJeKg2vqQJiLz9MH0yjL7cPvqAylKcCg7G0WnKdzADdFB0XO8ggjnbccaKMlGxSpJI3ccX697nlVOamsGsYcRowYOamsCc3qEX(4U8ry(VFdqyyh4RZXwGXHVSBY0XtAQqcPjADoPPSaG0bPBN)sQJrkEIN6MH0Q5KMOuiTacP1nC4cPvZjnSfsJcWibPS3()cs5Uqkhc4ndPHTq61U6wYhY06g(2OJr5nmsAc4RZFXcashSE)EZYlkaJeOKSWQJLeEb8Ailh(gOhK1VOamsCc3qEX(4U8zI9BSbimSd815ylW4Wx2D60dqyyh4RZXwGXbigL3OpE3nZx29b(683WMJdqmkVrJ(RUHdxE8noWldlh43xSqx7KiljNFrbyKaDGxgwoWVVyHU2)qwso)IcWib6y4n)HKc8XX(hmgZCyYgvw64eSDu8wShwfYr6Ail8rhLmTUHVn6yuEdJKMWWB(G0CbWQJLKVXbEzy5a)(If6AFc)MG3m)glQS0XbjfWBMx7m2HrbKJ01qw4)qwso)IcWib6y4n)HKc8j8c41qwogEZFiPaVluSyyPtZ34GSl(Y(XEb8Nv59j8BcEZm6VX(da1c2cyKdYU4lBSCziplGJmocSdYTSeE601nC4YJVXbEzy5a)(If6ANezj58lkaJeOd8YWYb(9fl01EuY0XtAQqcP4jEQBEsz7HnPMP8EaivccGuZGQSbPqDwqisdBH0OamsqkBpNjDqiDqYlBsHPznzM0bbBbcPHTq6D3mFz3KExdbr6qDtGmTUHVn6yuEdJKMazx8L9J9c4pUuHnRowsaulylGrowL3daPsqapluLnocSdYTSe(p4fWRHSC4BGEqw)IcWiXjCd5f7Z6gpyA2ph7UBMVS7dYU4l7h7fWFCPc7dhcuHVnmyU8rjthpPPcjKIBx8LnPWgOq2KUnPWM5jfQZccrAylaH0ciKwCoIuVVRH3mhY06g(2OJr5nmsAcKDXx2VlOq2S6yjbLZFcCPJtX5OJ3FYIzjthpPPcjKAUEZjfxkaPXs6DBeKHqQ5lqcKMI9cXyhisTa7fr62KooPM))qAkPgZNAif22gZbgK6isdBhrQJiTi12zSfaPwaFbE8L0WUAsbcFJWBgs3M0Xj18)Kc1zbHiLxGeinSxig7arQJiTgwOG0yjnCdH0fkitRB4BJogL3WiPjm8M)qsby9(9MLxuagjqjzHvhljYsY5xuagjqhdV5pKuGpHxaVgYYXWB(djf4DHIfd73aeg2HxGeEH9cXyhhilwV2L3jzHvVdbaGSINByiCVcjjlS6DiaaKv8CSKHFta9zsysMoEstfsi1C9Mt6hMRVKglP3TrqgcPMVajqAk2leJDGi1cSxePBtkEkhstj1y(udPW22yoWGuhJ0W2rK6islsTDgBbqQfWxGhFjnSRMuGW3i8MHuOolieP8cKaPH9cXyhisDeP1WcfKglPHBiKUqbzADdFB0XO8ggjnHH38hwU(YQJLCacd7WlqcVWEHySJdK1p4fWRHSC4BGEqwSETlVtYcREhcaazfp3Wq4Efsswy17qaaiR45yjd)Ma6ZKW83D3mFz3h4RZFdBooqwKPJN0uHesnxV5KcRCHcsDms)UqKY3()csBr4KglPabdiiBsn)Mc6qkESwKElu4ndPvqQjr6ci1ybcPrbyKarkBpSjfxkG3mKoIZyhgfqinQS0HWjTAoPFxislGqAVbPqiVzif3U4lBSCziKAgGJmiDbKAg03RTFjDC5DchY06g(2OJr5nmsAcdV5VHCHcwDSKWlGxdz5W3a9GS(bkN)e4shhJfUyiDC8(ZBHIx4gcmm75F)qwso)IcWib6y4n)HKc8XXmjyatt2OYshhdhjGVhPRHSWHrDdhU84BCGxgwoWVVyHU2MSrLLoowOVxB)(YENWr6Ail8rjtRB4BJogL3WiPjGxgwoWVVyHU2SE)EZYlkaJeOKSWQJLeiyabzxdz5xuagjoHBiVyFCx(0CKo9yrLLoogosaFpsxdzH)JVXbzx8L9J9c4pRY7dqWacYUgYYOPtpaHHDGAmiq2BMhVaj0ccDGSithpP4wY1RmP3T5E4BtASKII1I0BHcVzifpXtDZq62KUyyMtrbyKarkBBPjfZzSdVzinXiDbKASaHuuu3eeoPg7aI0Q5KcH8MHuZG(ET9lPJlVtG0Q5KosQjfsnxhjGVhY06g(2OJr5nmsAcKDXx2p2lG)SkVz1XscemGGSRHS8lkaJeNWnKxSpUlFAs)(lQS0XXWrc47r6Ail8FrLLoowOVxB)(YENWr6Ail8FiljNFrbyKaDm8M)qsb(eMKPJNutgfXIu8ep1ndPqwKUnPfIuJQ)sAuagjqKwisTweYhYcRKkFWRyfKY2wAsXCg7WBgstmsxaPglqiff1nbHtQXoGiLTh2KAg03RTFjDC5DchY06g(2OJr5nmsAcKDXx2p2lG)SkVz9(9MLxuagjqjzHvhljqWacYUgYYVOamsCc3qEX(4U8Pj97VOYshhdhjGVhPRHSW)93yrLLooiPaEZ8ANXomkGCKUgYc)hYsY5xuagjqhdV5pKuGpHxaVgYYXWB(djf4DHIfdB0FJ9xuzPJJf6712VVS3jCKUgYcpD6XIklDCSqFV2(9L9oHJ01qw4)qwso)IcWib6y4n)HKc8XKWC0rjtRB4BJogL3WiPjm8M)qsby9(9MLxuagjqjzHvhljYsY5xuagjqhdV5pKuGpHxaVgYYXWB(djf4DHIfdJ1RD5Dswy17qaaiR45ggc3RqsYcREhcaazfphlz43eqFMeMKP1n8TrhJYByK0egEZFy56lRx7Y7KSWQ3HaaqwXZnmeUxHKKfw9oeaaYkEowYWVjG(mjm)D3nZx29b(683WMJdKfz64jnviHu8ep1npPfI0CHcsbcAbbPogPBtAylKASWfY06g(2OJr5nmsAcKDXx2p2lG)4sf2KPJN0uHesXt8u3mKwisZfkifiOfeK6yKUnPHTqQXcxiTAoP4jEQBEsDePBtkSzEY06g(2OJr5nmsAcKDXx2p2lG)SkVjtjthpPPcjKUnPWM5jDCWhhZqASKYibPMFtH0WVj4ndPvZjv(GwoqinwsZElKczr6GeHaiLTh2KMO15ylWGmTUHVn6eaVtqcusiK88qmyTldjPyy9fiv(TaEx9vy1XsE3nZx29b(68NaGScF7dqmkVrFmjlWmD67Uz(YUpWxN)eaKv4BFaIr5n6tyAYjthpP4F7lPPwtMmpPS9WM0eTohBbgKP1n8TrNa4DcsGGrstaHKNhIbRDzij9gDbqrnKLhSdQ6aY4Xf4(vy1XsE3nZx29b(68NaGScF7dqmkVrFYIzjthpP4F7lP42IeKAUqi)skBpSjnrRZXwGbzADdFB0jaENGeiyK0eqi55HyWAxgssJ6wda5HSfjEgqi)YQJL8UBMVS7d815pbazf(2hGyuEJ(KfZsMoEsX)2xsnNdn8Lu2EytQzw2cG0uBJbH8TjfcvmcRKAujiKIGacPXskQDlH0WwinVSfuq6hWmKgfGrcY06g(2Ota8objqWiPjGqYZdXG1UmKKOfkNLi8M5bGg(YQJLCacd7yTSfWZBmiKV9bYkD6)SaUGIdsYypRLTaEEJbH8Tz9(9MLxuagjqjzHmD8KMkKqkSkoJqQ3iNlKUyKMOpKuSfqAylKI5auqkesiDbKUnPWM5jTWcbqAylKI5auqkesoKIBVGG0RdUqEqQJrk815KkaiRW3M07Uz(YUj1rKYIzrKUasnwGqAXU(EitRB4BJobW7eKabJKMacjppedw7YqsI8gdk)yYf3RybO3qXzK3I9WeWE94lRowY7Uz(YUpWxN)eaKv4BFaIr5n6ZKSywY0XtAQqcPzhfKUyKUT5eesiLxgfJqAa8objqKUD(lPogPFaOMraEZqAIwNtQ5LbimmsDeP1nC4cRKUas)UqKwaH0EdsJklDiCs9ows94qMw3W3gDcG3jibcgjnXTY5xDdF7x2rbRDzij5gmVa4DcsGy1Xso2FrLLoo2qnJa8M5bFD(r6Ail80P5Yaeg2XgQzeG3mp4RZpqwJ(BSbimSd815ylW4azLo9D3mFz3h4RZFcaYk8TpaXO8g9jlMDuY0XtQ5fSckhKIv58qDtGuSfqkeQgYcPEigOuN0uHes3M07Uz(YUj1BsxaxaKo8L0a4DcsqkkVXHmTUHVn6eaVtqcemsAciK88qmqS6yjhGWWoWxNJTaJdKv60dqyyhRLTaEEJbH8TpqwPtF3nZx29b(68NaGScF7dqmkVrFYIzN4il5ohbM)d2pJzmNa]] )

end
