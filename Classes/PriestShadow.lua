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


    spec:RegisterPack( "Shadow", 20210121, [[defcKbqivfEevixsvvPWMuK(KQs0OisofrQvPQQIELQsnle0TuvvHDjXVqaddHYXuvzzQk6zQkHPHqvxtruBtvj13qOsJdHOoNQscRtvvX8ue5EeyFkcheHiluvvEivOAIieUOQQs2ivO0hvvs0iPcfDsvLKwji6LuHcAMiur3ebs7KkYprOcdfbQJQQQu0sPcf6PiAQubxfHuBfHKVIaXyPcfyVs6VkmyLoSWIPspwvMmsxg1MH4ZeA0kQttA1QQkvVMkQztv3gs7wQFRYWjQJRQQQLd8COMUORdQTdsFNGgVQQkDEqy9QQkLMprSFkx)vDOssJKRo9jX(8hX(95VYNe73xt8vYeczUskhpNdrUs2bkxjjNd6jSskhq4VGwDOsIpyWJRKZzkJ)hcqarnNHDlVdLayff2hPE9deijbWk6Javsxy1NF1U6wjPrYvN(KyF(Jy)(8x5tI97R)9zLmGZ5dujjvuhVsoRuk3v3kjLXVkPJSLCoONqBjyGY40G0r2cz0WbacB)8hH2(jX(8NbPbPJS1bHC4STe1PuBD4aaUtBfoZTTzae5023b3j22aW2ICGhtlvsVItC1HkPmGFhQBKvhQo9R6qLK7W1Z06FvYhqtgOrLeWOH2yBNKTFbXiwLmEPEDLu(eYGHWdqhihi1eMY1S60NvhQKChUEMw)Rs(aAYanQKFyRlmcsbph0tiYbqlWYvY4L61vs8CqpHihaTMvN(IQdvsUdxptR)vjFanzGgvsTXrRjefkJOpnTDcB)n5kz8s96kzaErZJ8aaUZAwDI4Rouj5oC9mT(xL8KRKyoRKXl1RRKqdGgUEUscn8WCL8Zkj0am6aLRKOAthyoaJhCEii1S60KRoujJxQxxjHgOYkqFJ8GFZvsUdxptR)vZAwjPOIJeOTZCIRouD6x1Hkj3HRNP1)QKDGYvsAaCg9UEq5NZJHmCcy8J7hxjJxQxxjPbWz076bLFopgYWjGXpUFCnRo9z1Hkj3HRNP1)QKDGYvsmC76VJocuoNHaNvY4L61vsmC76VJocuoNHaN1S60xuDOsYD46zA9VkzhOCLu0dH884qgbgROQps96kz8s96kPOhc55XHmcmwrvFK611S6eXxDOsYD46zA9VkzhOCLKc4GIOaEaLXy2xjJxQxxjPaoOikGhqzmM91SMvs0q7QdvN(vDOsYD46zA9Vk5dOjd0Os6cJGuCVRhhYiN5rGFCtzAbwUsItG(YQt)QKXl1RRKVW7hXl1RhEfNvsVIZrhOCL09UUMvN(S6qLmEPEDLKQyz2pqdr9vj5oC9mT(xnRo9fvhQKChUEMw)Rs(aAYanQKqdGgUEUiFNFGCGXJITDQTAJJwtiSDcb2s8eZ2P2kLTAJJwtiSDscSLipzBLiX2m8CNfmhaTfhTkoNObGlChUEMA7uBHganC9CbZbqBXrRIZjAa4XdopeeBL22P2(HTV780tyxquUPfyzBNARu2(HTV780tyxq1MoC9bolWY2krITyz27hzae5exq1MoWCaSDcB)0wPRKXl1RRKqpLoyaSCQxxZQteF1Hkj3HRNP1)QKpGMmqJkPlmcsbj4HiCaOA04cSSTtT9dBPSlmcsriiYzey)ajyGYfy5kz8s96kjEoONWHWdqhYH21S60KRouj5oC9mT(xLmEPEDL8fE)iEPE9WR4Ss6vCo6aLRKpkUMvN(6QdvsUdxptR)vjJxQxxjr1MoWCaQKpGMmqJkzgEUZcMdG2IJwfNt0aWfUdxptTDQTyz27hzae5exq1MoWCaSDcBHganC9CbvB6aZby8GZdbX2P2(HT0ll45GEchcpaDihAxs95S2I2o12pS9DNNEc7cIYnTalxjFq888idGiN4Qt)Qz1jIB1Hkj3HRNP1)QKXl1RRK0aTJuVUs(aAYanQKFyl0aOHRNlH3pOxIhWYvYhepppYaiYjU60VAwDIixDOsYD46zA9Vk5dOjd0OsQnoAnHW2jjWwI8KTDQTz45olZWTid0wCa9uAH7W1ZuBNABgEUZcMdG2IJwfNt0aWfUdxptTDQTyz27hzae5exq1MoWCaSDscS9RTvIeBLYwPSndp3zzgUfzG2IdONslChUEMA7uB)W2m8CNfmhaTfhTkoNObGlChUEMAR02krITyz27hzae5exq1MoWCaSvGT)Sv6kz8s96kj0tPd3ZN1S60xr1Hkj3HRNP1)QKpGMmqJkPu2cyeaJNdxpBRej2QnoAnHW2jSL4ozBL22P2kLTFyl0aOHRNlY35hihy8OyBLiXwTXrRje2oHaBjYt2wPTDQTsz7h2MHN7SG5aOT4OvX5enaCH7W1ZuBLiXwPSndp3zbZbqBXrRIZjAa4c3HRNP2o12pSfAa0W1ZfmhaTfhTkoNObGhp48qqSvABLUsgVuVUsszOhmqBXHSpeH5AwD6hXQouj5oC9mT(xL8b0KbAujXYS3pYaiYjUGQnDG5ay7KSvkBjEB)2231uynlufJVo6CWV5JXfUdxptTvABNAR24O1ecBNKaBjYt22P2MHN7SG5aOT4OvX5enaCH7W1ZuBLiX2pSndp3zbZbqBXrRIZjAa4c3HRNPvY4L61vsONshUNpRz1PF)Qouj5oC9mT(xLmEPEDLeph0t4q4bOdkh5CL8b0KbAujLY2maICwM5WNZf5xA7KS9tIz7uBXYS3pYaiYjUGQnDG5ay7KSL4TvABLiXwPSvMZcIYnTeVuHY2o1waCZihqKl45GEcr8bkpKbkgTW)pSklZuBLUs(G455rgaroXvN(vZQt)(S6qLK7W1Z06FvY4L61vsmmaWnLbJ8gObTzmUs(aAYanQKzae5SKkkpYBqv22jz7Nt22P26cJGuGEkf5aOf6jSRKpiEEEKbqKtC1PF1S60VVO6qLK7W1Z06FvY4L61vsONsh5baCNvYhqtgOrLeAa0W1Zf6L4bSSTtTndGiNLur5rEdQY2oHTFHTtTvkBDHrqkqpLICa0c9e22krITUWiifONsroaAbWOH2yBNKTV780tyxGEkD4E(Say0qBSTsB7uBJxQq5b9Yc0avwb6BKh8B2wb2ILzVFKbqKtCbAGkRa9nYd(nB7uBXYS3pYaiYjUGQnDG5ay7KSvkBNSTFBRu2(12(FABgEUZskuX54qgirYfUdxptTvABLUs(G455rgaroXvN(vZQt)i(QdvsUdxptR)vjFanzGgvs6LfObQSc03ip43Cj1NZAlA7uBLY2m8CNfmhaTfhTkoNObGlChUEMA7uBXYS3pYaiYjUGQnDG5ay7e2cnaA465cQ20bMdW4bNhcITsKyl9YcEoONWHWdqhYH2LuFoRTOTsxjJxQxxjr1M6YnLb1S60VjxDOsYD46zA9Vk5dOjd0OscGBg5aICro02fWHZmyiJdpAH)FyvwMP2o1wObqdxpxOxIhWY2o12maICwsfLh5nKF54tIz7e2kLTV780tyxWZb9eoeEa6GYroxOWGi1RT9BBfFuBLUsgVuVUsINd6jCi8a0bLJCUMvN(91vhQKChUEMw)Rs(aAYanQKGqPdgk3zjOuCrBBNW2FeRsgVuVUsINd6jC8abEUMvN(rCRouj5oC9mT(xLmEPEDLevB6aZbOs(G455rgaroXvN(vj1ozaawohksLm1NZ4je8zLu7Kbay5COOOmvJKRK)QKpGMmqJkjwM9(rgaroXfuTPdmhaBNWwObqdxpxq1MoWCagp48qqSDQTUWiifAaCEKZhS4CwGLRKV5q7k5VAwD6hrU6qLK7W1Z06FvY4L61vsuTPdeFarLu7Kbay5COivYuFoJNqWNtF35PNWUa9u6W98zbwUsQDYaaSCouuuMQrYvYFvYhqtgOrL0fgbPqdGZJC(GfNZcSSTtTfAa0W1Zf6L4bSCL8nhAxj)vZQt)(kQouj5oC9mT(xL8b0KbAujHganC9CHEjEalB7uBbHshmuUZc6bLr5olAB7e2(cCosfLT9BBjwzY2o1wPSflZE)idGiN4cQ20bMdGTtYwI32P2(HTz45olOkMbqu4oC9m1wjsSflZE)idGiN4cQ20bMdGTtY2V22P2MHN7SGQygarH7W1ZuBLUsgVuVUsIQnD46dCwZQtFsSQdvsUdxptR)vjJxQxxjHgOYkqFJ8GFZvYhqtgOrLeWiagphUE22P2MbqKZsQO8iVbvzBNW2V2wjsSvkBZWZDwqvmdGOWD46zQTtTLEzbph0t4q4bOd5q7cGramEoC9STsBRej26cJGuGBeyGxBXbnao3mgxGLRKpiEEEKbqKtC1PF1S60N)Qouj5oC9mT(xL8b0KbAujbmcGXZHRNTDQTzae5SKkkpYBqv22jSL4TDQTFyBgEUZcQIzaefUdxptTDQTz45olYyiEZ6B4125c3HRNP2o1wSm79JmaICIlOAthyoa2oHTFwjJxQxxjXZb9eoeEa6qo0UMvN(8ZQdvsUdxptR)vjJxQxxjXZb9eoeEa6qo0Us(aAYanQKagbW45W1Z2o12maICwsfLh5nOkB7e2s82o12pSndp3zbvXmaIc3HRNP2o12pSvkBZWZDwWCa0wC0Q4CIgaUWD46zQTtTflZE)idGiN4cQ20bMdGTtyl0aOHRNlOAthyoaJhCEii2kTTtTvkB)W2m8CNfzmeVz9n8A7CH7W1ZuBLiXwPSndp3zrgdXBwFdV2ox4oC9m12P2ILzVFKbqKtCbvB6aZbW2jjW2pTvABLUs(G455rgaroXvN(vZQtF(fvhQKChUEMw)RsgVuVUsIQnDG5aujFq888idGiN4Qt)QKANmaalNdfPsM6Zz8ec(SsQDYaaSCouuuMQrYvYFvYhqtgOrLelZE)idGiN4cQ20bMdGTtyl0aOHRNlOAthyoaJhCEiivY3CODL8xnRo9jXxDOsYD46zA9Vkz8s96kjQ20bIpGOsQDYaaSCouKkzQpNXti4ZPV780tyxGEkD4E(Salxj1ozaawohkkkt1i5k5Vk5Bo0Us(RMvN(CYvhQKXl1RRK45GEchcpaDq5iNRKChUEMw)RMvN(8RRoujJxQxxjXZb9eoeEa6qo0UsYD46zA9VAwZk5t4R6q1PFvhQKChUEMw)RscJ5HWz1ZJxGtTfRo9RsgVuVUsI5aOT4OvX5enaCL8bXZZJmaICIRo9Rs(aAYanQKszl0aOHRNlyoaAloAvCordapEW5HGy7uB)WwObqdxpxKVZpqoW4rX2kTTsKyRu2sVSGNd6jCi8a0HCODbWiagphUE22P2ILzVFKbqKtCbvB6aZbW2jS9NTsxZQtFwDOsYD46zA9VkjmMhcNvppEbo1wS60Vkz8s96kjMdG2IJwfNt0aWvYhepppYaiYjU60Vk5dOjd0OsMHN7SG5aOT4OvX5enaCH7W1ZuBNAl9YcEoONWHWdqhYH2faJay8C46zBNAlwM9(rgaroXfuTPdmhaBNW2pRz1PVO6qLK7W1Z06FvYR9qmEcFvYFvY4L61vsuTPdxFGZAwZkzc02zoXvhQo9R6qLK7W1Z06FvY4L61vsgvgcah(XbOD0pUs(aAYanQKV780tyxGEkDWay5uVUay0qBSTtsGT)(0wjsS9DNNEc7c0tPdgalN61faJgAJTDcB)K4wj7aLRKmQmeao8Jdq7OFCnRo9z1Hkj3HRNP1)QKXl1RRKAJFa4mC984)HJoHrhugQ(4k5dOjd0Os(UZtpHDb6P0bdGLt96cGrdTX2oHT)iwLSduUsQn(bGZW1ZJ)ho6egDqzO6JRz1PVO6qLK7W1Z06FvY4L61vs04fUaEGNzohOWy9vjFanzGgvY3DE6jSlqpLoyaSCQxxamAOn22jS9hXQKDGYvs04fUaEGNzohOWy9vZQteF1Hkj3HRNP1)QKDGYvs8b79CMAloaWUqujFq888idGiN4Qt)QKpGMmqJkPlmcsr(eYGH2iWy96cSSTsKy7h2kdugNfm7rgYNqgm0gbgRxxjJxQxxjXhS3ZzQT4aa7crnRon5QdvsUdxptR)vjJxQxxjXAJa7hI(GQrEa8WnOI84qgim4EAcrL8b0KbAujF35PNWUa9u6GbWYPEDbWOH2yBNqGT)iwLSduUsI1gb2pe9bvJ8a4HBqf5XHmqyW90eIAwD6RRouj5oC9mT(xL8b0KbAujLY2pSndp3zzgUfzG2IdONslChUEMARej2szxyeKYmClYaTfhqpLwGLTvABNARu26cJGuGEkf5aOfyzBLiX23DE6jSlqpLoyaSCQxxamAOn22jS9hXSv6kz8s96k5l8(r8s96HxXzL0R4C0bkxjPOIJeOTZCIRz1jIB1Hkj3HRNP1)QKpGMmqJkPlmcsb6PuKdGwGLTvIeBDHrqkYNqgm0gbgRxxGLTvIeBF35PNWUa9u6GbWYPEDbWOH2yBNW2FeRsgVuVUscJ5HMmkUM1Ss(O4QdvN(vDOsYD46zA9Vk5dOjd0OskdugNfm7rgYNqgm0gbgRxB7uBLYwxyeKc0tPihaTalBRej2(HT4d27QnTicoO8qBOQ4bIuVUWD46zQTtT9dBXhS3vBA5DOUroqzQMrQxx4oC9m12P2(UZtpHDb6P0bdGLt96cGrdTX2oHaB)rmBLiXwevCohagn0gB7KS9DNNEc7c0tPdgalN61faJgAJTvIeBXhS3vBAreCq5H2qvXdePEDH7W1ZuBNARu26cJGuamvb8lz6iAfnk4mEoB7ecS93N2krITV780tyxqcEichaQgnUay0qBSTty7pIzR02kDLmEPEDLu(eYGH2iWy96AwD6ZQdvsUdxptR)vjJxQxxjXAJa7hI(GQrEa8WnOI84qgim4EAcrL8b0KbAujDHrqkqpLICa0cSSTsKyBQOSTty7pIz7uBLY2pS9Dq5o6S0Q4Coqc2wPRKDGYvsS2iW(HOpOAKhapCdQipoKbcdUNMquZQtFr1Hkj3HRNP1)QKpGMmqJk5h26cJGuGEkf5aOfyzBNARu2(HTV780tyxGEkDKhaWDwGLTvIeB)W2m8CNfONsh5baCNfUdxptTvABLiXwxyeKc0tPihaTalB7uBLYw8b7D1MwebhuEOnuv8arQxx4oC9m1wjsSfFWExTPfeL90XHmC9hgFO4c3HRNP2kDLmEPEDLej4HiCaOA04AwDI4Rouj5oC9mT(xLmEPEDLevBQyGY4k5dOjd0OsQnoAnHW2jz7xbXSDQTszRu2cnaA465s49d6L4bSSTtTvkB)W23DE6jSlqpLoyaSCQxxGLTvIeB)W2m8CNLz4wKbAloGEkTWD46zQTsBR02krITUWiifONsroaAbw2wPTDQTsz7h2MHN7Smd3ImqBXb0tPfUdxptTvIeBPSlmcszgUfzG2IdONslWY2krITFyRlmcsb6PuKdGwGLTvABNARu2(HTz45olyoaAloAvCordax4oC9m1wjsSflZE)idGiN4cQ20bMdGTtY2jBR0vYhepppYaiYjU60VAwDAYvhQKChUEMw)Rs(aAYanQKszRu2(HTGqPdgk3zjOuCbw22P2ccLoyOCNLGsXfTTDcB)Ky2kTTsKyliu6GHYDwckfxamAOn22jey7VjBRej2ccLoyOCNLGsXfkmis9ABNKT)MSTsB7uBLYwxyeKI8jKbdTrGX61fyzBLiX23DE6jSlYNqgm0gbgRxxamAOn22jey7pIzRej2(HTYaLXzbZEKH8jKbdTrGX612kTTtTvkB)W2m8CNLz4wKbAloGEkTWD46zQTsKylLDHrqkZWTid0wCa9uAbw2wjsS9dBDHrqkqpLICa0cSSTsxjJxQxxjH75ZdXOpOrnRo91vhQKChUEMw)Rs(aAYanQKFyRlmcsb6PuKdGwGLTDQTFy77op9e2fONshmawo1RlWY2o1wSm79JmaICIlOAthyoa2oHT)SDQTFyBgEUZcMdG2IJwfNt0aWfUdxptTvIeBLYwxyeKc0tPihaTalB7uBXYS3pYaiYjUGQnDG5ay7KS9tBNA7h2MHN7SG5aOT4OvX5enaCH7W1ZuBNARu2kdyOdXhT8Ra9u6W98PTtTvkB)Ww()HvzzMwyuziaC4hhG2r)yBLiX2pSndp3zzgUfzG2IdONslChUEMAR02krIT8)dRYYmTWOYqa4WpoaTJ(X2o123DE6jSlmQmeao8Jdq7OFCbWOH2yBNKaB)91FA7uBPSlmcszgUfzG2IdONslWY2kTTsBRej2kLTUWiifONsroaAbw22P2MHN7SG5aOT4OvX5enaCH7W1ZuBLUsgVuVUs6ExpoKroZJa)4MY0AwDI4wDOsYD46zA9Vkz8s96k5l8(r8s96HxXzL0R4C0bkxjtG2oZjUM1Ss6ExxDO60VQdvsUdxptR)vjFanzGgvsSm79JmaICIlOAthyoa2ojb2(fvY4L61vYa)4MY0HRpWznRo9z1Hkj3HRNP1)QKpGMmqJkzgarolc1CwBISTtTflZE)idGiN4sGFCtz6OpOHTty7pBNAlwM9(rgaroXfuTPdmhaBNW2F2(TTz45olyoaAloAvCordax4oC9mTsgVuVUsg4h3uMo6dAuZAwjPmsa7ZQdvN(vDOsgVuVUsIvp3pUsYD46zA9VAwD6ZQdvsUdxptR)vjFanzGgvsxyeKc0tPihaTalBRej26cJGuKpHmyOncmwVUalxjJxQxxjLVuVUMvN(IQdvsUdxptR)vjp5kjMZkz8s96kj0aOHRNRKqdpmxjPxwWZb9eoeEa6qo0UK6ZzTfTDQT0llqduzfOVrEWV5sQpN1wSscnaJoq5kj9s8awUMvNi(QdvsUdxptR)vjp5kjMZkz8s96kj0aOHRNRKqdpmxjPxwWZb9eoeEa6qo0UK6ZzTfTDQT0llqduzfOVrEWV5sQpN1w02P2sVSqzOhmqBXHSpeH5sQpN1wSscnaJoq5kz49d6L4bSCnRon5QdvsUdxptR)vjp5kjMZkz8s96kj0aOHRNRKqdpmxjXYS3pYaiYjUGQnDG5ay7e2(PTFBRlmcsb6PuKdGwGLRKqdWOduUsI5aOT4OvX5ena84bNhcsnRo91vhQKChUEMw)RsEYvsmNvY4L61vsObqdxpxjHgEyUs(UZtpHDb6P0bdGLt96cSSTtTvkB)WwqO0bdL7SeukUalBRej2ccLoyOCNLGsXfkmis9ABNKaB)rmBLiXwqO0bdL7SeukUay0qBSTtiW2FeZ2VTDY2(FARu2MHN7Smd3ImqBXb0tPfUdxptTvIeBFhuUJolodbqJ2wPTvABNARu2kLTGqPdgk3zjOuCrBBNW2pjMTsKylwM9(rgaroXfONshmawo1RTDcb2ozBL2wjsSndp3zzgUfzG2IdONslChUEMARej2(oOChDwCgcGgTTsxjHgGrhOCLu(o)a5aJhfxZQte3QdvsUdxptR)vjFanzGgvsxyeKc0tPihaTalxjJxQxxjrua76VJwZQte5QdvsUdxptR)vjFanzGgvsxyeKc0tPihaTalxjJxQxxjDzaMboRTynRo9vuDOsYD46zA9Vk5dOjd0OsILzVFKbqKtCXRIZjE8Vdtfr5oTDcb2(PTsKyRu2(HTGqPdgk3zjOuCH)VkoX2krITGqPdgk3zjOuCrBBNWwI7KTv6kz8s96kPxfNt84FhMkIYDwZQt)iw1Hkj3HRNP1)QKpGMmqJkPlmcsb6PuKdGwGLRKXl1RRKr)yCcc)4fEFnRo97x1Hkj3HRNP1)QKXl1RRKVW7hXl1RhEfNvsVIZrhOCL8j8vZQt)(S6qLK7W1Z06FvY4L61vsaCpIxQxp8koRKEfNJoq5kjAODnRznRKqzawVU60Ne7ZFe73pIB5xLuyaATfXvsccrYXOtFvN(k)hBT1Hz2wfv(aPTihW2Ven0(lTfW)pScyQT4dLTnGZdnsMA7BoArgxmijo1MT93x8p264haWVKP2Y)pC41ecBFZ8ZzBrahQTFPabFPT5z7xk4lTvQF)xPlgKgKeeIKJrN(Qo9v(p2ARdZSTkQ8bsBroGTF5JI)sBb8)dRaMAl(qzBd48qJKP2(MJwKXfdsItTzB)6)Xwh)AOmizQTFzc02zologuE35PNW(lTnpB)Y3DE6jSlog8L2k1V)R0fdshMzBroV)eQTOTbmiW2kKbSTWyMAR22MZSTXl1RT1R40wx40wHmGTTV0wKdUP2QTT5mBBqPxBlnYWnW8)yqA7)HTaMQa(LmDeTIggKgKFvu5dKm1wISTXl1RT1R4exmiRKYGdr9CL0r2soh0tOTemqzCAq6iBHmA4aaHTF(JqB)KyF(ZG0G0r26GqoC2wI6uQToCaa3PTcN522maICA77G7eBBayBroWJPfdsdshz7)6)Yp4KP26YihGT9DOUrARllQnUylr69y5eBBF9)XCaqrG92gVuVgB71EikgKXl1RXfza)ou3i)wabKpHmyi8a0bYbsnHPmHkIaaJgAJN0xqmIzqgVuVgxKb87qDJ8Bbeaph0tiYbqjure8Hlmcsbph0tiYbqlWYgKXl1RXfza)ou3i)wabcWlAEKhaWDsOIiqBC0AcrHYi6tZj(nzdY4L614ImGFhQBKFlGaqdGgUEMWoqzbOAthyoaJhCEiieEYcWCsi0WdZc(0GmEPEnUid43H6g53cia0avwb6BKh8B2G0G0r2sWxQxJniJxQxJfGvp3p2GmEPEnwG8L61eQicCHrqkqpLICa0cSSejUWiif5tidgAJaJ1RlWYgKXl1RXFlGaqdGgUEMWoqzb0lXdyzcpzbyojeA4Hzb0ll45GEchcpaDihAxs95S2ItPxwGgOYkqFJ8GFZLuFoRTObz8s9A83cia0aOHRNjSduwq49d6L4bSmHNSamNecn8WSa6Lf8CqpHdHhGoKdTlP(CwBXP0llqduzfOVrEWV5sQpN1wCk9YcLHEWaTfhY(qeMlP(CwBrdshzlzgG0wyS2I2sYbqBrBDsfNt0aW2gPTFX32MbqKtSThWwI)BBveBH4GTnaSTABlrDkf5aOgKXl1RXFlGaqdGgUEMWoqzbyoaAloAvCordapEW5HGq4jlaZjHqdpmlalZE)idGiN4cQ20bMdWeF(Tlmcsb6PuKdGwGLniDKTo(DE6jSTLGVZBlrfanC9mH2s0yMABE2kFN3wxg5aSTXlvOrQTOTqpLICa0IToomaWD6HWwymtTnpBFxNGZBRWzUTnpBJxQqJKTf6PuKdGARqnNTv73HQTOTbLIlgKXl1RXFlGaqdGgUEMWoqzbY35hihy8OycpzbyojeA4HzbV780tyxGEkDWay5uVUalpvQpaHshmuUZsqP4cSSejGqPdgk3zjOuCHcdIuVEsc(rmjsaHshmuUZsqP4cGrdTXti4hX(EY)NsLHN7Smd3ImqBXb0tPfUdxptLi5Dq5o6S4meanAPLEQusbcLoyOCNLGsXfTN4tIjrcwM9(rgaroXfONshmawo1RNqWKLwIKm8CNLz4wKbAloGEkTWD46zQejVdk3rNfNHaOrlTbz8s9A83ciaIcyx)DucvebUWiifONsroaAbw2GmEPEn(BbeWLbyg4S2IeQicCHrqkqpLICa0cSSbPJSLOXSTeNQ4C(LyBHeMkIYDARIyBoZa22aW2(PThWw0dW2MbqKtmH2EaBdkfBBa4(ltBXYHWwBrBroGTOhGTnNJ2wI7KXfdY4L614VfqaVkoN4X)omveL7KqfrawM9(rgaroXfVkoN4X)omveL7CcbFkrIuFacLoyOCNLGsXf()Q4elrciu6GHYDwckfx0EcI7KL2GmEPEn(Bbei6hJtq4hVW7jure4cJGuGEkf5aOfyzdY4L614VfqGx49J4L61dVItc7aLf8e(miJxQxJ)wabaW9iEPE9WR4KWoqzbOH2gKgKoYwIebtCABE2cJzBfoZTT)DxB7HyBoZ2sKWpUPm1wfBB8sfkBqgVuVgxCVRfe4h3uMoC9bojureGLzVFKbqKtCbvB6aZbysc(cdY4L614I7D93ciqGFCtz6OpObHkIGmaICweQ5S2e5Pyz27hzae5exc8JBkth9bnM43uSm79JmaICIlOAthyoat877m8CNfmhaTfhTkoNObGlChUEMAqAq6iBDCIaBq6iBjAmBlbFczGTF1gbgRxBRqnNTLOoLICa0IToMNNAlYbSLOoLICauBFhkJT9qqS9DNNEcBB122CMTT5)BA7pIzlMFxtX2E5mdeQy2wymB712(O2c3EgJTnNzBjy2hIh2whaHM264hQBK2sqzQMrQxBRITndp3jtj02dyRIyBoZa2wHQ3BBFPTUSTrF5mdSLOoLA7)calN612MZk2wevColgKXl1RXLhflq(eYGH2iWy9AcvebYaLXzbZEKH8jKbdTrGX61tLYfgbPa9ukYbqlWYsK8b(G9UAtlIGdkp0gQkEGi1RlChUEMo9d8b7D1MwEhQBKduMQzK61fUdxptN(UZtpHDb6P0bdGLt96cGrdTXti4hXKibrfNZbGrdTXt6DNNEc7c0tPdgalN61faJgAJLibFWExTPfrWbLhAdvfpqK61fUdxptNkLlmcsbWufWVKPJOv0OGZ458ec(9PejV780tyxqcEichaQgnUay0qB8e)iM0sBq6iBjAmBlP65(X2ETTooryBE2kdUNTKS8m8)2VeBlbdUNpqJuVUyq6iBJxQxJlpk(BbeaREUFmHzae5COicaWnJCarUGz5z4)T4Hm4E(ans96c))WQSmtNkvgarolkEeuQejzae5SqzxyeKYlWP2IfahVuAdshzlrJzB)lOISTAJvkB7Hylr5yTf5a2MZSTikaN2cJzBpGTxBRJte2gijdSnNzBruaoTfgZfBjiAoBRtQ4CARJnyBNpp1wKdylr5ylgKXl1RXLhf)TacaJ5HMmkHDGYcWAJa7hI(GQrEa8WnOI84qgim4EAcbHkIaxyeKc0tPihaTallrsQO8e)i2uP(4Dq5o6S0Q4CoqcwAdshzlrJzBDSbB7xjCaOA0yBV2whNiS9GtSszBpeBjQtPihaTylrJzBDSbB7xjCaOA0uSTABlrDkf5aO2Qi2cXbB7CaLTL1CMb2(vcoOSTF1gQkEGi1RT9a26yv2tT9qS9p)HXhkUyqgVuVgxEu83ciasWdr4aq1OXeQic(WfgbPa9ukYbqlWYtL6J3DE6jSlqpLoYda4olWYsK8rgEUZc0tPJ8aaUZc3HRNPslrIlmcsb6PuKdGwGLNkf(G9UAtlIGdkp0gQkEGi1RlChUEMkrc(G9UAtlik7PJdz46pm(qXfUdxptL2G0r2s0y2wcQ2uXaLX2kCMBBdV32VWwI4CaBBayBHLj02dylehSTbGTvBBjQtPihaTy7)QXWa2wht4wKbAlAlrDk1wfBB8sfkB712MZSTzae50wfX2m8CNmTylzEY2cJ1w02iTDYFBBgaroX2kuZzBj5aOTOToPIZjAa4Ibz8s9AC5rXFlGaOAtfdugt4dINNhzae5el4hHkIaTXrRjet6RGytLskObqdxpxcVFqVepGLNk1hV780tyxGEkDWay5uVUallrYhz45olZWTid0wCa9uAH7W1ZuPLwIexyeKc0tPihaTall9uP(idp3zzgUfzG2IdONslChUEMkrcLDHrqkZWTid0wCa9uAbwwIKpCHrqkqpLICa0cSS0tL6Jm8CNfmhaTfhTkoNObGlChUEMkrcwM9(rgaroXfuTPdmhGjnzPniDKTenMTLO75ZdHToDqdBV2whNii025Zt1w0wxGYiEiSnpBfgAAlYbSv(eYaB1gbgRxB7bSnOuBXYHWgxmiJxQxJlpk(BbeaUNppeJ(GgeQicKsQpaHshmuUZsqP4cS8uqO0bdL7SeukUO9eFsmPLibekDWq5olbLIlagn0gpHGFtwIeqO0bdL7SeukUqHbrQxpPFtw6Ps5cJGuKpHmyOncmwVUallrY7op9e2f5tidgAJaJ1Rlagn0gpHGFetIKpKbkJZcM9id5tidgAJaJ1RLEQuFKHN7Smd3ImqBXb0tPfUdxptLiHYUWiiLz4wKbAloGEkTallrYhUWiifONsroaAbwwAdshzlrJzBV2whNiS1foTvgOhqtfZ2cJ1w0wI6uQT)laSCQxBlIcWjH2Qi2cJzQTAJvkB7Hylr5yT9ABjDWwymBBGKmW2WwONsDpFAlYbS9DNNEcBBzee9PC)GW2OP2ICaBNHBrgOTOTqpLAlSCQOSTkITz45ozAXGmEPEnU8O4Vfqa376XHmYzEe4h3uMsOIi4dxyeKc0tPihaTalp9J3DE6jSlqpLoyaSCQxxGLNILzVFKbqKtCbvB6aZbyIFt)idp3zbZbqBXrRIZjAa4c3HRNPsKiLlmcsb6PuKdGwGLNILzVFKbqKtCbvB6aZbysFo9Jm8CNfmhaTfhTkoNObGlChUEMovkzadDi(OLFfONshUNpNk1h8)dRYYmTWOYqa4WpoaTJ(XsK8rgEUZYmClYaTfhqpLw4oC9mvAjs4)hwLLzAHrLHaWHFCaAh9JNMaTDMZcJkdbGd)4a0o6hxE35PNWUay0qB8Ke87R)CkLDHrqkZWTid0wCa9uAbwwAPLirkxyeKc0tPihaTalpndp3zbZbqBXrRIZjAa4c3HRNPsBqgVuVgxEu83ciWl8(r8s96HxXjHDGYcsG2oZj2G0G0r264boTLGmRE2whpWP2I2gVuVgxSLKtBJ02zvCMb2kd0dOje2MNT45dK2(uWdwtB1ozaawoT9Dnvt9ASTxBlbvBQTKCaiGJ1hqyq6iBjAmBljhaTfT1jvCordaBRIylehSTcvV32znTL7dwC22maICITnAQTe8jKb2(vBeySETTrtTLOoLICauBdaBBFPTaoOqqOThW28SfWiagpBljb5FiyBV22u4z7bSf9aSTzae5exmiJxQxJlpHpbyoaAloAvCordatimMhcNvppEbo1wuWpcFq888idGiNyb)iureif0aOHRNlyoaAloAvCordapEW5HGm9dObqdxpxKVZpqoW4rXslrIu0ll45GEchcpaDihAxamcGXZHRNNILzVFKbqKtCbvB6aZbyIFsBq6iBjNpqARJRGhSM2sYbqBrBDsfNt0aW2(UMQPETT5zRZmlBljb5FiyBHLTvBBjs3)YGmEPEnU8e((wabWCa0wC0Q4CIgaMqympeoREE8cCQTOGFe(G455rgaroXc(rOIiidp3zbZbqBXrRIZjAa4c3HRNPtPxwWZb9eoeEa6qo0UayeaJNdxppflZE)idGiN4cQ20bMdWeFAq6iBV2dX4j8zlA4mJTnNzBJxQxB71EiSfghUE2wkmqBrBFZr3SxBrBJMABFPTb22Wwalc7dGTXl1RlgKXl1RXLNW33ciaQ20HRpWjHx7Hy8e(e8ZG0GmEPEnUqrfhjqBN5elagZdnzuc7aLfqdGZO31dk)CEmKHtaJFC)ydY4L614cfvCKaTDMt83ciamMhAYOe2bklad3U(7OJaLZziWPbz8s9ACHIkosG2oZj(BbeagZdnzuc7aLfi6HqEECiJaJvu1hPETbz8s9ACHIkosG2oZj(BbeagZdnzuc7aLfqbCqruapGYym7niniDKTe0qBBjsemXjH2INpyp123bLb2gEVTGOfzSThITzae5eBB0uBXpUdGEydY4L614cAO93ciWl8(r8s96HxXjHDGYcCVRjeNa9Lc(rOIiWfgbP4ExpoKroZJa)4MY0cSSbz8s9ACbn0(BbeGQyz2pqdr9zq6iBjAmBlrDk12)fawo1RT9ABF35PNW2w578AlABK265aN2s8eZwTXrRje26cN22xARIylehSTcvV32dkdEHSTAJJwtiSvBBjkhBXwcA4mBlggW2INd6jer5MsauTPUCtzGTrtTLGQn12)8boTvX2ETTV780tyBRlJCa2wI6FvmiJxQxJlOH2cGEkDWay5uVMqfra0aOHRNlY35hihy8O4PAJJwtiMqaXtSPsPnoAnHysciYtwIKm8CNfmhaTfhTkoNObGlChUEMofAa0W1ZfmhaTfhTkoNObGhp48qqKE6hV780tyxquUPfy5Ps9X7op9e2fuTPdxFGZcSSejyz27hzae5exq1MoWCaM4tPniDKTe0Wz2wmmGTfId2wz40wyzBjji)dbBlrIKirW2ETT5mBBgaroTvrSLGaICgb2BRJnyGY2Q4(ltBJxQq5Ibz8s9ACbn0(Bbeaph0t4q4bOd5qBcvebUWiifKGhIWbGQrJlWYt)GYUWiifHGiNrG9dKGbkxGLniJxQxJlOH2FlGaVW7hXl1RhEfNe2bkl4rXgKoYwhtvC2wcgOhqtiSLGQn1wsoa2gVuV228SfWiagpBlrCoGTvOMZ2I5aOT4OvX5enaSbz8s9ACbn0(BbeavB6aZbGWhepppYaiYjwWpcvebz45olyoaAloAvCordax4oC9mDkwM9(rgaroXfuTPdmhGjGganC9CbvB6aZby8GZdbz6h0ll45GEchcpaDihAxs95S2It)4DNNEc7cIYnTalBq6iBjyaJWaBZZwymBlreODK612sKijseSTkITrdHTeX5GTk22(sBHLlgKXl1RXf0q7VfqaAG2rQxt4dINNhzae5el4hHkIGpGganC9Cj8(b9s8aw2G0r2s0y2wI6uQT)D(02iTDwfNzGTYa9aAcHTc1C2wht4wKbAlAlrDk1wyzBZZwI32maICIj02dy7LZmW2m8CNyBV2wshkgKXl1RXf0q7VfqaONshUNpjureOnoAnHysciYtEAgEUZYmClYaTfhqpLw4oC9mDAgEUZcMdG2IJwfNt0aWfUdxptNILzVFKbqKtCbvB6aZbysc(AjsKsQm8CNLz4wKbAloGEkTWD46z60pYWZDwWCa0wC0Q4CIgaUWD46zQ0sKGLzVFKbqKtCbvB6aZbqWpPniDKTeX1FzAlmMTLiyOhmqBrBjyFicZ2Qi2cXbB7lABf50wTZZwI6ukYbqTvBCYbLqBpGTkITKCa0w0wNuX5enaSTk22m8CNm12OP2ku9EBN10wUpyXzBZaiYjUyqgVuVgxqdT)wabOm0dgOT4q2hIWmHkIaPamcGXZHRNLirBC0AcXee3jl9uP(aAa0W1Zf578dKdmEuSejAJJwtiMqarEYspvQpYWZDwWCa0wC0Q4CIgaUWD46zQejsLHN7SG5aOT4OvX5enaCH7W1Z0PFanaA465cMdG2IJwfNt0aWJhCEiislTbPJSLOXSTe1F2ETTooryRIylehST0R)Y02MzQT5z7lWPTebd9GbAlAlb7dryMqBJMABoZa22aW26zm22CoABjEBZaiYj22doTvQjBRqnNT9DnfwtPlgKXl1RXf0q7VfqaONshUNpjureGLzVFKbqKtCbvB6aZbyssr8F)UMcRzHQy81rNd(nFmUWD46zQ0t1ghTMqmjbe5jpndp3zbZbqBXrRIZjAa4c3HRNPsK8rgEUZcMdG2IJwfNt0aWfUdxptniDKTenMTLCoONqBjihG(p2seCKZ2Qi2MZSTzae50wfBB4EWPT5zlvzBpGTqCW2ohqzBjNd6jeXhOSTemqXO2Y)pSklZuBfQ5STeuTPUCtzGThWwY5GEcruUP2gVuHYfdY4L614cAO93ciaEoONWHWdqhuoYzcFq888idGiNyb)iureivgarolZC4Z5I8lN0NeBkwM9(rgaroXfuTPdmhGjr8slrIuYCwquUPL4LkuEkaUzKdiYf8CqpHi(aLhYafJw4)hwLLzQ0gKoYwIgZ2scdaCtzGT5zlbnOnJX2ETTHTzae502CosBvSTIN2I2MNTuLTnsBZz2wGkoN2MkkxmiJxQxJlOH2FlGayyaGBkdg5nqdAZymHpiEEEKbqKtSGFeQicYaiYzjvuEK3GQ8K(CYtDHrqkqpLICa0c9e2gKoYwIgZ2suNsT1Hda4oT9Ape2Qi2ssq(hc22OP2suoyBayBJxQqzBJMABoZ2MbqKtBfE9xM2sv2wkmqBrBZz223C0n7lgKXl1RXf0q7VfqaONsh5baCNe(G455rgaroXc(rOIiaAa0W1Zf6L4bS80maICwsfLh5nOkpXxmvkxyeKc0tPihaTqpHTejUWiifONsroaAbWOH24j9UZtpHDb6P0H75ZcGrdTXspnEPcLh0llqduzfOVrEWVzbcWYS3pYaiYjUanqLvG(g5b)MNILzVFKbqKtCbvB6aZbyssn5VL6R)pZWZDwsHkohhYajsUWD46zQ0sBqgVuVgxqdT)wabq1M6YnLbeQicOxwGgOYkqFJ8GFZLuFoRT4uPYWZDwWCa0wC0Q4CIgaUWD46z6uSm79JmaICIlOAthyoatanaA465cQ20bMdW4bNhcIej0ll45GEchcpaDihAxs95S2IsBq6iBjAmBljb5FicBfQ5STeCOTlGdNzGTemo8O2c3EgJTnNzBZaiYPTcvV3wx2wx2FcT9tI9VHTUmYbyBZz223DE6jST9DOm2w345Sbz8s9ACbn0(Bbeaph0t4q4bOdkh5mHkIaaCZihqKlYH2UaoCMbdzC4rl8)dRYYmDk0aOHRNl0lXdy5Pzae5SKkkpYBi)YXNeBcPE35PNWUGNd6jCi8a0bLJCUqHbrQx)T4JkTbPJSLOXSTKZb9eARJdc8STxBRJte2c3EgJTnNzaBBayBdkfBR2VdvBXIbz8s9ACbn0(Bbeaph0t44bc8mHkIaqO0bdL7SeukUO9e)iMbPJSLOXSTeuTP2sYbW28S9DnggLTLicGZ26W8bloNyBLb3dB712sKio(xfBDG4GiioS1XVgrbO2QyBZzfBRITnSDwfNzGTYa9aAcHT5C02cy6LP2I2ETTejIJ)LTWTNXyBPbWzBZ5dwCoX2QyBd3doTnpBtfLT9GtdY4L614cAO93ciaQ20bMdaHpiEEEKbqKtSGFeQicWYS3pYaiYjUGQnDG5amb0aOHRNlOAthyoaJhCEiitDHrqk0a48iNpyX5Salt4Bo0wWpc1ozaawohkkkt1izb)iu7Kbay5COics95mEcbFAq6iBjAmBlbvBQTowFaHT5z77AmmkBlreaNT1H5dwCoX2kdUh22RTL0HIToqCqeeh264xJOauBveBZzfBRITnSDwfNzGTYa9aAcHT5C02cy6LP2I2c3EgJTLgaNTnNpyX5eBRITnCp4028Snvu22doniJxQxJlOH2FlGaOAthi(accvebUWiifAaCEKZhS4CwGLNcnaA465c9s8awMW3COTGFeQDYaaSCouuuMQrYc(rO2jdaWY5qreK6Zz8ec(C67op9e2fONshUNplWYgKoYwIgZ2sq1MA7F(aN2Qi2cXbBl96VmTTzMABE2cyeaJNTLiohWfBjZt22xGtTfTnsBjEBpGTOhGTndGiNyBfQ5STKCa0w0wNuX5enaSTz45ozAXGmEPEnUGgA)TacGQnD46dCsOIiaAa0W1Zf6L4bS8uqO0bdL7SGEqzuUZI2t8cCosfL)MyLjpvkSm79JmaICIlOAthyoatI4N(rgEUZcQIzaefUdxptLiblZE)idGiN4cQ20bMdWK(6Pz45olOkMbqu4oC9mvAdY4L614cAO93cia0avwb6BKh8BMWhepppYaiYjwWpcvebagbW45W1ZtZaiYzjvuEK3GQ8eFTejsLHN7SGQygarH7W1Z0P0ll45GEchcpaDihAxamcGXZHRNLwIexyeKcCJad8AloObW5MX4cSSbPJSLuMFA4T9Dnvt9ABZZwCEY2(cCQTOTKeK)HGT9ABpeK)JmaICITv4m32IOIZP2I2(f2EaBrpaBloJNZm1w0ZfBB0uBHXAlAlbJH4nRpBjo12zBJMARtehoylbvXmaIIbz8s9ACbn0(Bbeaph0t4q4bOd5qBcvebagbW45W1ZtZaiYzjvuEK3GQ8ee)0pYWZDwqvmdGOWD46z60m8CNfzmeVz9n8A7CH7W1Z0Pyz27hzae5exq1MoWCaM4tdshzRJHmlBljb5FiyBHLT9ABdSTOrdHTzae5eBBGTv(Wy11ZeAl)FFSCARWzUTfrfNtTfT9lS9a2IEa2wCgpNzQTONl2wHAoBlbJH4nRpBjo125Ibz8s9ACbn0(Bbeaph0t4q4bOd5qBcFq888idGiNyb)iureayeaJNdxppndGiNLur5rEdQYtq8t)idp3zbvXmaIc3HRNPt)qQm8CNfmhaTfhTkoNObGlChUEMoflZE)idGiN4cQ20bMdWeqdGgUEUGQnDG5amEW5HGi9uP(idp3zrgdXBwFdV2ox4oC9mvIePYWZDwKXq8M13WRTZfUdxptNILzVFKbqKtCbvB6aZbysc(uAPniJxQxJlOH2FlGaOAthyoae(G455rgaroXc(rOIialZE)idGiN4cQ20bMdWeqdGgUEUGQnDG5amEW5HGq4Bo0wWpc1ozaawohkkkt1izb)iu7Kbay5COics95mEcbFAqgVuVgxqdT)wabq1Moq8bee(MdTf8JqTtgaGLZHIIYunswWpc1ozaawohkIGuFoJNqWNtF35PNWUa9u6W98zbw2G0r2s0y2wscY)qe2gyB9boTfW4dK2Qi2ETT5mBl6bLniJxQxJlOH2FlGa45GEchcpaDq5iNniDKTenMTLKG8peSTb2wFGtBbm(aPTkITxBBoZ2IEqzBJMAljb5FicBvSTxBRJtegKXl1RXf0q7Vfqa8CqpHdHhGoKdTniniDKTenMT9ABDCIWwIejrIGTnpBf50wI4CW2uFoRTOTrtTL)VYkGTnpB9AZ2clBRlNjdSvOMZ2suNsroaQbz8s9ACjbA7mNybWyEOjJsyhOSagvgcah(XbOD0pMqfrW7op9e2fONshmawo1Rlagn0gpjb)(uIK3DE6jSlqpLoyaSCQxxamAOnEIpjUgKoYwsi6NTF1)njcBfQ5STe1PuKdGAqgVuVgxsG2oZj(BbeagZdnzuc7aLfOn(bGZW1ZJ)ho6egDqzO6Jjure8UZtpHDb6P0bdGLt96cGrdTXt8JygKoYwsi6NTKZmN2sqHX6ZwHAoBlrDkf5aOgKXl1RXLeOTZCI)wabGX8qtgLWoqzbOXlCb8apZCoqHX6JqfrW7op9e2fONshmawo1Rlagn0gpXpIzq6iBjHOF26ye2fcBfQ5STe8jKb2(vBeySETTW4qKj0w0Wz2wmmGTnpBXTkZ2MZST(tiJtBDmjyBZaiYPbz8s9ACjbA7mN4Vfqaymp0KrjSduwa(G9EotTfhayxiiure4cJGuKpHmyOncmwVUallrYhYaLXzbZEKH8jKbdTrGX61e(G455rgaroXc(zq6iBjAmB7FbvKTvBSszBpeBjkhRTihW2CMTfrb40wymB7bS9ABDCIW2ajzGT5mBlIcWPTWyUyl58bsBFk4bRPTkITqpLAldGLt9ABF35PNW2wfB7pIHT9a2IEa22qyarXGmEPEnUKaTDMt83ciamMhAYOe2bklaRncSFi6dQg5bWd3GkYJdzGWG7PjeeQicE35PNWUa9u6GbWYPEDbWOH24je8JygKoYwIgZ26vCA7Hy71)hWy2wAGgISTjqBN5eB71EiSvrS1XeUfzG2I2suNsTLiyxyeeBvSTXlvOmH2EaBH4GTnaST9L2MHN7KP2QDE2QzXGmEPEnUKaTDMt83ciWl8(r8s96HxXjHDGYcOOIJeOTZCIjurei1hz45olZWTid0wCa9uAH7W1ZujsOSlmcszgUfzG2IdONslWYspvkxyeKc0tPihaTallrY7op9e2fONshmawo1Rlagn0gpXpIjTbPJSLiyKa2N2IeEVB8C2wKdylmoC9STAYO4)XwIgZ2ETTV780tyBR22EakdS1fcBtG2oZPTy)LfdY4L614sc02zoXFlGaWyEOjJIjure4cJGuGEkf5aOfyzjsCHrqkYNqgm0gbgRxxGLLi5DNNEc7c0tPdgalN61faJgAJN4hXQKyz(vD6ZjtKRznRva]] )

end
