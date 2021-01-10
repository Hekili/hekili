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


    spec:RegisterPack( "Shadow", 20201228, [[da1OEbqivcpIqYLOuOuBsQQpbfHgfLQoLufRIqe8kvIMfu4wukuSlP8lvknmcHJbswMkjptQsAAuk4AukABqr03iKkJtLcohHi16iKI5jvPUhuAFuQCqcP0cvj1dLQetuLIUOkfYgPuiFKqeAKesvojHizLGuVekcOzsPq1njeLDsK6NeIOHcfPJcfbyPukuYtH0ujsUkuuTvOO8vcr1EP4VsAWkDyHftjpwftgPlJAZq8zcgTu50Kwnue0RPuA2sCBOA3k(TQgorDCvkulh45iMovxhuBheFNqnEcPQoVkvRhkc08jI9lAdugPmO0WzJ0xjIRebuxD1n0GckBks3RysdQFxMnOYXX2qGnOtGZgu0UG(InOYX9YhuJuguYddoSbTZDzIO52BfuVd2QDE8BjkoCjC9Ndiq8Bjk(5wdQfSwCrQXyzqPHZgPVsexjcOU6QBObfu2uKUxTPbnG9Uhyqrv8EXG2PukpgldkLjhdQOYfTlOV4CXuGYepHwu5Et(W4wmi3RUbmY9krCLisOtOfvUsjMdBZfZELMRupaWJNR4oEY1dGa75EE4Xj5gaoxKhCyAZGwuItmszqXdDmszKgkJuguEcRctnxBqpa1zGggulyeKM1)t9rQEhxdYHhktBWYguId0JBKgkdACC9hd6jkLACC9NArjUbTOeVoboBqT(FmUr6RmszqJJR)yqPkrMlv8qqpguEcRctnxBCJ09QrkdkpHvHPMRnOhG6mqddkKaOHvHBY)xQipOEOKC7NRoKyu)EU2HnxBqe52px7ZvhsmQFp3EJn3BWM5krsUEu4XBeoa6iuhvOZXda34jSkmn3(5cjaAyv4gHdGoc1rf6C8aW1dS)ii52tU9Z9ICp)xOV4PHO8qBWYg0446pguiVsRmaw21FmUrABWiLbLNWQWuZ1g0dqDgOHb1cgbPHeCvaoaungsdwo3(5ErUu2cgbPjgeEhcCPIemq5gSSbnoU(JbL0f0xCv8dOv5qhJBK2MgPmO8ewfMAU2Gghx)XGEIsPghx)PwuIBqlkXRtGZg0dLyCJ0ysJuguEcRctnxBqJJR)yqX1HwjCamOhG6mqddQhfE8gHdGoc1rf6C8aWnEcRctZTFUezUuQEaeyN0W1HwjCaY1UCHeanSkCdxhALWbOEG9hbj3(5ErU03BKUG(IRIFaTkh60C9yRoc52p3lY98FH(INgIYdTblBqp3pfU6bqGDIrAOmUrArNrkdkpHvHPMRnOXX1FmO0aFcx)XGEaQZanmOxKlKaOHvHBrPuPVtQWYg0Z9tHREaeyNyKgkJBK(gmszq5jSkm1CTb9auNbAyq1HeJ63ZT3yZ9gSzU9Z1JcpERdEeyGocviVsB8ewfMMB)C9OWJ3iCa0rOoQqNJhaUXtyvyAU9ZLiZLs1dGa7KgUo0kHdqU9gBUyYCLijx7Z1(C9OWJ36GhbgOJqfYR0gpHvHP52p3lY1JcpEJWbqhH6OcDoEa4gpHvHP52tUsKKlrMlLQhab2jnCDOvchGCXMlu52JbnoU(JbfYR0Q1xCJBKwK2iLbLNWQWuZ1g0446pgukd5Hb6iuLlHamBqpa1zGggu7ZfWiaM0fwfoxjsYvhsmQFpx7Yv0zZC7j3(5AFUxKlKaOHvHBY)xQipOEOKCLijxDiXO(9CTdBU3GnZTNC7NR95ErUEu4XBeoa6iuhvOZXda34jSkmnxjsY1(C9OWJ3iCa0rOoQqNJhaUXtyvyAU9Z9ICHeanSkCJWbqhH6OcDoEa46b2FeKC7j3EmON7Ncx9aiWoXinug3inuIWiLbLNWQWuZ1g0dqDgOHbLiZLs1dGa7KgUo0kHdqU9ox7Z1gY9YCp)qHvVrvc5Ny8kF6EM04jSkmn3EYTFU6qIr9752BS5Ed2m3(56rHhVr4aOJqDuHohpaCJNWQW0CLij3lY1JcpEJWbqhH6OcDoEa4gpHvHPg0446pguiVsRwFXnUrAOGYiLbLNWQWuZ1g0446pgusxqFXvXpGwPC4Dg0dqDgOHb1(C9aiWERJJI31KpEU9o3RerU9ZLiZLs1dGa7KgUo0kHdqU9oxBi3EYvIKCTpxz2Bikp0wCCfcNB)CbWdJ8abUr6c6lgPe4CvgOe8gFJHvzzMMBpg0Z9tHREaeyNyKgkJBKgQRmszq5jSkm1CTbnoU(JbLada8qzq1)kEqhMqmOhG6mqddQhab2BUIZv)RuLZT35ELnZTFUwWiiniVsrEaEJ(Ihd65(PWvpacStmsdLXnsdvVAKYGYtyvyQ5AdACC9hdkKxPv)baECd6bOod0WGcjaAyv4g9Dsfwo3(56bqG9MR4C1)kv5CTl3En3(5AbJG0G8kf5b4n6lEYTFUXXviCL(EdsGlRa9u9h(0LRDyZLiZLs1dGa7KgKaxwb6P6p8Pl3(5sK5sP6bqGDsdxhALWbi3ENR95AZCVmx7ZftMRiHC9OWJ3CXkXRpsfjCUXtyvyAU9KBpg0Z9tHREaeyNyKgkJBKgkBWiLbLNWQWuZ1g0dqDgOHbL(EdsGlRa9u9h(01C9yRoc52px7Z1JcpEJWbqhH6OcDoEa4gpHvHP52pxImxkvpacStA46qReoa5AxUqcGgwfUHRdTs4aupW(JGKRej5sFVr6c6lUk(b0QCOtZ1JT6iKBpg0446pguCDOw8qzGXnsdLnnszq5jSkm1CTb9auNbAyqbWdJ8abUjh6yb4WwguLjrbVX3yyvwMP52pxibqdRc3OVtQWY52pxpacS3CfNR(xLpE9krKRD5AFUN)l0x80iDb9fxf)aALYH31OWGW1FY9YCfo0C7XGghx)XGs6c6lUk(b0kLdVZ4gPHctAKYGYtyvyQ5Ad6bOod0WGccLwzi84TGsjnDY1UCHseg0446pgusxqFX1diiDg3inuIoJuguEcRctnxBqJJR)yqX1HwjCamON7Ncx9aiWoXinuguDCgaGL9QIyqD9ylXoSxzq1Xzaaw2Rkoot1Wzdkug0dqDgOHbLiZLs1dGa7KgUo0kHdqU2LlKaOHvHB46qReoa1dS)ii52pxlyeKgna2w9UhwOZBWYg0txOJbfkJBKgQBWiLbLNWQWuZ1g0446pguCDOvKsC3GQJZaaSSxvedQRhBj2H9Q(N)l0x80G8kTA9fVblBq1Xzaaw2Rkoot1Wzdkug0dqDgOHb1cgbPrdGTvV7Hf68gSCU9Zfsa0WQWn67KkSSb90f6yqHY4gPHsK2iLbLNWQWuZ1g0dqDgOHbfsa0WQWn67KkSCU9ZfekTYq4XB4pegNhVPtU2L7jiE1vCo3lZvenBMB)CTpxImxkvpacStA46qReoa527CTHC7N7f56rHhVHRegCVXtyvyAUsKKlrMlLQhab2jnCDOvchGC7DUyYC7NRhfE8gUsyW9gpHvHP52JbnoU(JbfxhA1Qee34gPVsegPmO8ewfMAU2Gghx)XGcjWLvGEQ(dF6mOhG6mqddkGramPlSkCU9Z1dGa7nxX5Q)vQY5AxUyYCLijx7Z1JcpEdxjm4EJNWQW0C7Nl99gPlOV4Q4hqRYHonaJaysxyv4C7jxjsY1cgbPbpiWGIocvAaSDycPblBqp3pfU6bqGDIrAOmUr6RGYiLbLNWQWuZ1g0dqDgOHbfWiaM0fwfo3(56bqG9MR4C1)kv5CTlxBi3(5ErUEu4XB4kHb3B8ewfMMB)C9OWJ3Kj3pD6Pw0X2gpHvHP52pxImxkvpacStA46qReoa5AxUxzqJJR)yqjDb9fxf)aAvo0X4gPV6kJuguEcRctnxBqJJR)yqjDb9fxf)aAvo0XGEaQZanmOagbWKUWQW52pxpacS3CfNR(xPkNRD5Ad52p3lY1JcpEdxjm4EJNWQW0C7N7f5AFUEu4XBeoa6iuhvOZXda34jSkmn3(5sK5sP6bqGDsdxhALWbix7Yfsa0WQWnCDOvchG6b2FeKC7j3(5AFUxKRhfE8Mm5(Ptp1Io224jSkmnxjsY1(C9OWJ3Kj3pD6Pw0X2gpHvHP52pxImxkvpacStA46qReoa52BS5EvU9KBpg0Z9tHREaeyNyKgkJBK(QE1iLbLNWQWuZ1g0446pguCDOvchad65(PWvpacStmsdLbvhNbayzVQiguxp2sSd7vguDCgaGL9QIJZunC2GcLb9auNbAyqjYCPu9aiWoPHRdTs4aKRD5cjaAyv4gUo0kHdq9a7pcIb90f6yqHY4gPVYgmszq5jSkm1CTbnoU(JbfxhAfPe3nO64maal7vfXG66XwIDyVQ)5)c9fpniVsRwFXBWYguDCgaGL9QIJZunC2GcLb90f6yqHY4gPVYMgPmOXX1FmOKUG(IRIFaTs5W7mO8ewfMAU24gPVctAKYGghx)XGs6c6lUk(b0QCOJbLNWQWuZ1g34gukUq1b6yl7eJugPHYiLbLNWQWuZ1g0jWzdkna2I))uP8X2Avg2bm5WZHnOXX1FmO0ayl()tLYhBRvzyhWKdph24gPVYiLbLNWQWuZ1g0jWzdkbESk)tRbo7D3jUbnoU(JbLapwL)P1aN9U7e34gP7vJuguEcRctnxBqNaNnOcL7YD1hPgeIIRLW1FmOXX1FmOcL7YD1hPgeIIRLW1FmUrABWiLbLNWQWuZ1g0jWzdkfWbfrbCfctiCXGghx)XGsbCqruaxHWecxmUXnOugjGlUrkJ0qzKYGghx)XGs0cph2GYtyvyQ5AJBK(kJuguEcRctnxBqpa1zGggulyeKgKxPipaVblNRej5AbJG0KFXmOQdcmr)PblBqJJR)yqLFx)X4gP7vJuguEcRctnxBqFzdkHDdACC9hdkKaOHvHnOqIcmBqPV3iDb9fxf)aAvo0P56XwDeYTFU03BqcCzfONQ)WNUMRhB1rWGcja1jWzdk9Dsfw24gPTbJuguEcRctnxBqFzdkHDdACC9hdkKaOHvHnOqIcmBqPV3iDb9fxf)aAvo0P56XwDeYTFU03BqcCzfONQ)WNUMRhB1ri3(5sFVrzipmqhHQCjeG5MRhB1rWGcja1jWzdAukv67KkSSXnsBtJuguEcRctnxBqFzdkHDdACC9hdkKaOHvHnOqIcmBqjYCPu9aiWoPHRdTs4aKRD5EvUxMRfmcsdYRuKhG3GLnOqcqDcC2Gs4aOJqDuHohpaC9a7pcIXnsJjnszq5jSkm1CTb9LnOe2nOXX1FmOqcGgwf2GcjkWSb98FH(INgKxPvgal76pny5C7NR95ErUGqPvgcpElOusdwoxjsYfekTYq4XBbLsAuyq46p52BS5cLiYvIKCbHsRmeE8wqPKgGXdDi5Ah2CHse5EzU2mxrc5AFUEu4XBDWJad0rOc5vAJNWQW0CLij3ZdHNy8MT3bAm52tU9KB)CTpx7ZfekTYq4XBbLsA6KRD5ELiYvIKCjYCPu9aiWoPb5vALbWYU(tU2HnxBMBp5krsUEu4XBDWJad0rOc5vAJNWQW0CLij3ZdHNy8MT3bAm52JbfsaQtGZgu5)lvKhupuIXnsl6mszq5jSkm1CTb9auNbAyqTGrqAqELI8a8gSSbnoU(JbfrbSv5FQXnsFdgPmO8ewfMAU2GEaQZanmOwWiiniVsrEaEdw2Gghx)XGAXacdSvhbJBKwK2iLbLNWQWuZ1g0dqDgOHbLiZLs1dGa7Kwrf6CsftimvaNhpx7WM7v5krsU2N7f5ccLwzi84TGsjnw0xjojxjsYfekTYq4XBbLsA6KRD5k6SzU9yqJJR)yqlQqNtQycHPc484g3inuIWiLbLNWQWuZ1g0dqDgOHb1cgbPb5vkYdWBWYg0446pg0yomXbrPEIsX4gPHckJuguEcRctnxBqJJR)yqprPuJJR)ulkXnOfL41jWzd6r8X4gPH6kJuguEcRctnxBqJJR)yqbWtnoU(tTOe3GwuIxNaNnO4Hog34guzaFECRWnszKgkJuguEcRctnxBqpa1zGgguaJh6qYT352RIqeg0446pgu5xmdQIFaTI8axDykBCJ0xzKYGYtyvyQ5Ad6bOod0WGErUwWiinsxqFXipaVblBqJJR)yqjDb9fJ8aCJBKUxnszq5jSkm1CTb9auNbAyq1HeJ63BugrpQNRD5cLnnOXX1FmOb4edx9ha4XnUrABWiLbLNWQWuZ1g0x2Gsy3Gghx)XGcjaAyvydkKOaZg0RmOqcqDcC2GIRdTs4aupW(JGyCJ020iLbnoU(JbfsGlRa9u9h(0zq5jSkm1CTXnUb9qjgPmsdLrkdkpHvHPMRnOhG6mqddQfmcsdYRuKhG3GLZvIKCVixYdxS0H2opUv4vCMQE46pnEcRctZTFUN)l0x80G8kTYayzx)Pby8qhsU2HnxOerUsKKlIk05vaJh6qYT35E(VqFXtdYR0kdGLD9NgGXdDig0446pgu5xmdQ6Gat0FmUr6Rmszq5jSkm1CTbnoU(JbLOdcCPkucQg(divRGkW1hPIWG)O(Dd6bOod0WGAbJG0G8kf5b4ny5CLijxxX5CTlxOerU9Z1(CVi3ZdHNy82OcDEfj4C7XGoboBqj6GaxQcLGQH)as1kOcC9rQim4pQF34gP7vJuguEcRctnxBqpa1zGgg0lY1cgbPb5vkYdWBWY52px7Z9ICp)xOV4Pb5vA1FaGhVblNRej5ErUEu4XBqELw9ha4XB8ewfMMBp5krsUwWiiniVsrEaEdwo3(5AFUKhUyPdTjaEiCvhiQWdcx)PXtyvyAUsKKl5Hlw6qBikxO1hPAvEc5XjnEcRctZThdACC9hdksWvb4aq1yig3iTnyKYGYtyvyQ5AdACC9hdkUouHaNjg0dqDgOHbvhsmQFp3ENRiTiYTFU2NR95cjaAyv4wukv67KkSCU9Z1(CVi3Z)f6lEAqELwzaSSR)0GLZvIKCVixpk84To4rGb6iuH8kTXtyvyAU9KBp5krsUwWiiniVsrEaEdwo3EYTFU2N7f56rHhV1bpcmqhHkKxPnEcRctZvIKCPSfmcsRdEeyGocviVsBWY5krsUxKRfmcsdYRuKhG3GLZTNC7NR95ErUEu4XBeoa6iuhvOZXda34jSkmnxjsYLiZLs1dGa7KgUo0kHdqU9oxBMBpg0Z9tHREaeyNyKgkJBK2MgPmO8ewfMAU2GEaQZanmO2NR95ErUGqPvgcpElOusdwo3(5ccLwzi84TGsjnDY1UCVse52tUsKKliuALHWJ3ckL0amEOdjx7WMlu2mxjsYfekTYq4XBbLsAuyq46p527CHYM52tU9Z1(CTGrqAYVygu1bbMO)0GLZvIKCp)xOV4Pj)IzqvheyI(tdW4HoKCTdBUqjICLij3lYvgOmXBeUGuLFXmOQdcmr)j3EYTFU2N7f56rHhV1bpcmqhHkKxPnEcRctZvIKCPSfmcsRdEeyGocviVsBWY5krsUxKRfmcsdYRuKhG3GLZThdACC9hdk809L715Heg3inM0iLbLNWQWuZ1g0dqDgOHb9ICTGrqAqELI8a8gSCU9Z9ICp)xOV4Pb5vALbWYU(tdwo3(5sK5sP6bqGDsdxhALWbix7YfQC7N7f56rHhVr4aOJqDuHohpaCJNWQW0CLijx7Z1cgbPb5vkYdWBWY52pxImxkvpacStA46qReoa527CVk3(5ErUEu4XBeoa6iuhvOZXda34jSkmn3(5kdyivHdTbvdYR0Q1x8C7jxjsY1(CTGrqAqELI8a8gSCU9Z1JcpEJWbqhH6OcDoEa4gpHvHP52JbnoU(Jb16)P(ivVJRb5WdLPg3iTOZiLbLNWQWuZ1g0446pg0tuk1446p1IsCdArjEDcC2G6aDSLDIXnUb1b6yl7eJugPHYiLbLNWQWuZ1g0446pgugx(oGJs9b0jMdBqpa1zGgg0Z)f6lEAqELwzaSSR)0amEOdj3EJnxOUkxjsY98FH(INgKxPvgal76pnaJh6qY1UCVs0zqNaNnOmU8DahL6dOtmh24gPVYiLbLNWQWuZ1g0446pguDihaShwfUEJHJXHXRugIEyd6bOod0WGE(VqFXtdYR0kdGLD9NgGXdDi5AxUqjcd6e4SbvhYba7HvHR3y4yCy8kLHOh24gP7vJuguEcRctnxBqJJR)yqXJtyb4kPJzVIdt0Jb9auNbAyqp)xOV4Pb5vALbWYU(tdW4HoKCTlxOeHbDcC2GIhNWcWvshZEfhMOhJBK2gmszq5jSkm1CTbDcC2GsE4sHDxhHka26Ub9C)u4Qhab2jgPHYGEaQZanmOwWiin5xmdQ6Gat0FAWY5krsUxKRmqzI3iCbPk)IzqvheyI(JbnoU(JbL8WLc7UocvaS1DJBK2MgPmO8ewfMAU2Gghx)XGs0bbUufkbvd)bKQvqf46JuryWFu)Ub9auNbAyqp)xOV4Pb5vALbWYU(tdW4HoKCTdBUqjcd6e4SbLOdcCPkucQg(divRGkW1hPIWG)O(DJBKgtAKYGYtyvyQ5Ad6bOod0WGAFUxKRhfE8wh8iWaDeQqEL24jSkmnxjsYLYwWiiTo4rGb6iuH8kTblNBp52px7Z1cgbPb5vkYdWBWY5krsUN)l0x80G8kTYayzx)Pby8qhsU2LluIi3EmOXX1FmONOuQXX1FQfL4g0Is86e4SbLIluDGo2YoX4gPfDgPmO8ewfMAU2GEaQZanmOwWiiniVsrEaEdwoxjsY1cgbPj)IzqvheyI(tdwoxjsY98FH(INgKxPvgal76pnaJh6qY1UCHseg0446pguycxvNXjg34guR)hJugPHYiLbLNWQWuZ1g0dqDgOHbLiZLs1dGa7KgUo0kHdqU9gBU9QbnoU(JbnihEOmTAvcIBCJ0xzKYGYtyvyQ5Ad6bOod0WG6bqG9My1705gYTFUezUuQEaeyN0cYHhktRZdjY1UCHk3(5sK5sP6bqGDsdxhALWbix7YfQCVmxpk84nchaDeQJk054bGB8ewfMAqJJR)yqdYHhktRZdjmUXnOhXhJugPHYiLbLNWQWuZ1guycxf3PfUEcIRJGrAOmOXX1FmOeoa6iuhvOZXdaBqp3pfU6bqGDIrAOmOhG6mqddQ95cjaAyv4gHdGoc1rf6C8aW1dS)ii52p3lYfsa0WQWn5)lvKhupusU9KRej5AFU03BKUG(IRIFaTkh60amcGjDHvHZTFUezUuQEaeyN0W1HwjCaY1UCHk3EmUr6Rmszq5jSkm1CTbfMWvXDAHRNG46iyKgkdACC9hdkHdGoc1rf6C8aWg0Z9tHREaeyNyKgkd6bOod0WG6rHhVr4aOJqDuHohpaCJNWQW0C7Nl99gPlOV4Q4hqRYHonaJaysxyv4C7NlrMlLQhab2jnCDOvchGCTl3RmUr6E1iLbLNWQWuZ1g0Fk3RhXhdkug0446pguCDOvRsqCJBCJBqHWaI(Jr6ReXvIaQRUs0zqfhGrhbIbvKcx(botZ9gYnoU(tUfL4KwcTbLiZhJ0xzZBWGkdEeTWgurLlAxqFX5IPaLjEcTOY9M8HXTyqUxDdyK7vI4krKqNqlQCLsmh2MlM9knxPEaGhpxXD8KRhab2Z98WJtYnaCUip4W0wcDcTOY9gj6ZhyNP5AXipGZ984wHNRflOdPLRO9CyzNK78JnMUaGJaxYnoU(dj3Fk3Bj0XX1FinzaFECRWVe7TYVyguf)aAf5bU6WugdfblGXdDi9UxfHisOJJR)qAYa(84wHFj2BjDb9fJ8aCmueSxybJG0iDb9fJ8a8gSCcDCC9hstgWNh3k8lXEBaoXWv)baECmueS6qIr97nkJOh1TdkBMqhhx)H0Kb85XTc)sS3cjaAyvymMaNXIRdTs4aupW(JGGXlJLWogqIcmJ9Qe6446pKMmGppUv4xI9wibUSc0t1F4txcDcTOYftFx)HKqhhx)HGLOfEoCcDCC9hcw531FWqrWAbJG0G8kf5b4nyzjsSGrqAYVygu1bbMO)0GLtOJJR)qUe7TqcGgwfgJjWzS03jvyzmEzSe2XasuGzS03BKUG(IRIFaTkh60C9yRoc9PV3Ge4Ykqpv)HpDnxp2QJqcDCC9hYLyVfsa0WQWymboJnkLk9DsfwgJxglHDmGefygl99gPlOV4Q4hqRYHonxp2QJqF67nibUSc0t1F4txZ1JT6i0N(EJYqEyGocv5siaZnxp2QJqcTOYf1dGNlmrhHCr5aOJqUsRcDoEa4Cdp3E9YC9aiWoj3hKRnCzUksU3F4CdaNRo5IzVsrEaEcDCC9hYLyVfsa0WQWymboJLWbqhH6OcDoEa46b2FeemEzSe2XasuGzSezUuQEaeyN0W1HwjCaS7QlTGrqAqELI8a8gSCcTOYTx(VqFXtUy6)LCXSaOHvHXixmNW0C9px5)l5AXipGZnoUcjCDeYfYRuKhG3YTxGbaE8Y9CHjmnx)Z98Jd(sUI74jx)ZnoUcjCoxiVsrEaEUIvVlxDopUoc5gukPLqhhx)HCj2BHeanSkmgtGZyL)VurEq9qjy8YyjSJbKOaZyp)xOV4Pb5vALbWYU(tdwUV9xacLwzi84TGsjnyzjsaHsRmeE8wqPKgfgeU(tVXcLiKibekTYq4XBbLsAagp0HyhwOeXL2uKG9Eu4XBDWJad0rOc5vAJNWQWujsopeEIXB2EhOX0tp9T3EqO0kdHhVfukPPJDxjcjsiYCPu9aiWoPb5vALbWYU(JDyTzpsK4rHhV1bpcmqhHkKxPnEcRctLi58q4jgVz7DGgtpj0XX1FixI9wefWwL)PyOiyTGrqAqELI8a8gSCcDCC9hYLyV1IbegyRocyOiyTGrqAqELI8a8gSCcTOYfZjCU24QqNJjsYfAyQaopEUksUEhd4CdaN7v5(GCXFaNRhab2jyK7dYnOusUbGhmrpxICiE0rixKhKl(d4C9UyYv0ztslHooU(d5sS3wuHoNuXectfW5XXqrWsK5sP6bqGDsROcDoPIjeMkGZJBh2RKiX(laHsRmeE8wqPKgl6ReNirciuALHWJ3ckL00XorNn7jHooU(d5sS3gZHjoik1tukyOiyTGrqAqELI8a8gSCcDCC9hYLyV9eLsnoU(tTOehJjWzShXNe6446pKlXElaEQXX1FQfL4ymboJfp0jHoHwu5kAXuB8C9pxycNR4oEY96)NCFKC9ooxrl5WdLP5QKCJJRq4e6446pKM1)d2GC4HY0QvjiogkcwImxkvpacStA46qReoa9gBVMqhhx)H0S(FUe7Tb5WdLP15HeyOiy9aiWEtS6D6Cd9jYCPu9aiWoPfKdpuMwNhsyhu9jYCPu9aiWoPHRdTs4ayhux6rHhVr4aOJqDuHohpaCJNWQW0e6eArLBVCtscTOYfZjCUy6lMb5ksniWe9NCfRExUy2RuKhG3Yv07l0CrEqUy2RuKhGN75XzsUpcsUN)l0x8KRo56DCUdl675cLiYLWNFOKCFVJbIvcNlmHZ9NCp0CHNcti56DCUykxcHNKRuGq9C7Lh3k8Cfzmv9W1FYvj56rHhNPyK7dYvrY17yaNRyTuYDEpxlo3yEVJb5IzVsZ9gbGLD9NC9oLKlIk05Te6446pK2HsWk)IzqvheyI(dgkcwlyeKgKxPipaVbllrYfKhUyPdTDECRWR4mv9W1FA8ewfM2)8FH(INgKxPvgal76pnaJh6qSdluIqIeevOZRagp0H07Z)f6lEAqELwzaSSR)0amEOdjHwu5I5eoxuTWZHZ9NC7LBMR)5kd(tUOSChmMGyIKCXuWFkbE46pTeArLBCC9hs7qjxI9wIw45Wy4bqG9QIGfapmYde4gHL7GXeKuLb)Pe4HR)04BmSklZ0(27bqG9MsQbLkrIhab2Bu2cgbPDcIRJqdWXX7jHwu5I5eo3RdQaNRoeLY5(i5Iz2OCrEqUEhNlIciEUWeo3hK7p52l3m3aXzqUEhNlIciEUWeULRix9UCLwf68CTrbNB3xO5I8GCXmBulHooU(dPDOKlXElmHRQZ4ymboJLOdcCPkucQg(divRGkW1hPIWG)O(DmueSwWiiniVsrEaEdwwIexXz7Gse9T)IZdHNy82OcDEfj4EsOfvUyoHZ1gfCUIeHdavJHK7p52l3m3h2jkLZ9rYfZELI8a8wUyoHZ1gfCUIeHdavJHsYvNCXSxPipapxfj37pCUDbeoxw9ogKRirWdHZvKAGOcpiC9NCFqU2iLl0CFKCVU8eYJtAj0XX1FiTdLCj2BrcUkahaQgdbdfb7fwWiiniVsrEaEdwUV9xC(VqFXtdYR0Q)aapEdwwIKl8OWJ3G8kT6paWJ34jSkmThjsSGrqAqELI8a8gSCF7jpCXshAta8q4QoquHheU(tJNWQWujsipCXshAdr5cT(ivRYtipoPXtyvyApj0IkxmNW5kY0Hke4mjxXD8KBuk52R5EZxksUbGZfwgJCFqU3F4CdaNRo5IzVsrEaEl3B0qGbCUIEWJad0rixm7vAUkj344keo3FY174C9aiWEUksUEu4XzAlxu)LZfMOJqUHNRnVmxpacStYvS6D5IYbqhHCLwf6C8aWTe6446pK2HsUe7T46qfcCMGX5(PWvpacStWcfgkcwDiXO(9ElslI(2BpKaOHvHBrPuPVtQWY9T)IZ)f6lEAqELwzaSSR)0GLLi5cpk84To4rGb6iuH8kTXtyvyAp9irIfmcsdYRuKhG3GL7PV9x4rHhV1bpcmqhHkKxPnEcRctLiHYwWiiTo4rGb6iuH8kTbllrYfwWiiniVsrEaEdwUN(2FHhfE8gHdGoc1rf6C8aWnEcRctLiHiZLs1dGa7KgUo0kHdqVTzpj0IkxmNW5I5t3xUNR0pKi3FYTxUjg529fQoc5AbugPCpx)ZvCOEUipix5xmdYvheyI(tUpi3GsZLihIhslHooU(dPDOKlXEl809L715HeyOiyT3(laHsRmeE8wqPKgSCFqO0kdHhVfukPPJDxjIEKibekTYq4XBbLsAagp0HyhwOSPejGqPvgcpElOusJcdcx)P3qzZE6BVfmcst(fZGQoiWe9NgSSejN)l0x80KFXmOQdcmr)Pby8qhIDyHsesKCHmqzI3iCbPk)IzqvheyI(tp9T)cpk84To4rGb6iuH8kTXtyvyQeju2cgbP1bpcmqhHkKxPnyzjsUWcgbPb5vkYdWBWY9KqlQCXCcN7p52l3mxlypxzG(a1vcNlmrhHCXSxP5EJaWYU(tUikG4yKRIKlmHP5QdrPCUpsUyMnk3FYfvQCHjCUbIZGCJCH8k16lEUipi3Z)f6lEYLrq0JYZ5EUXqZf5b52bpcmqhHCH8knxyzxX5CvKC9OWJZ0wcDCC9hs7qjxI9wR)N6Ju9oUgKdpuMIHIG9clyeKgKxPipaVbl3)IZ)f6lEAqELwzaSSR)0GL7tK5sP6bqGDsdxhALWbWoO6FHhfE8gHdGoc1rf6C8aWnEcRctLiXElyeKgKxPipaVbl3NiZLs1dGa7KgUo0kHdqVVQ)fEu4XBeoa6iuhvOZXda34jSkmTVmGHufo0guniVsRwFX7rIe7TGrqAqELI8a8gSCFpk84nchaDeQJk054bGB8ewfM2tcDCC9hs7qjxI92tuk1446p1IsCmMaNX6aDSLDscDcTOYTxcINRiVtlCU9sqCDeYnoU(dPLlk75gEUDQqhdYvgOpq9756FUKUh45EuWbw9C1Xzaaw2Z98dvD9hsU)KRithAUOCaU1gvI7j0IkxmNW5IYbqhHCLwf6C8aW5Qi5E)HZvSwk52PEU88WcD56bqGDsUXqZftFXmixrQbbMO)KBm0CXSxPipap3aW5oVNlGd6DmY9b56FUagbWKUCrf5Igmn3FY1f)5(GCXFaNRhab2jTe6446pK2r8blHdGoc1rf6C8aWyat4Q4oTW1tqCDeWcfgN7Ncx9aiWobluyOiyThsa0WQWnchaDeQJk054bGRhy)rq6FbKaOHvHBY)xQipOEOKEKiXE67nsxqFXvXpGwLdDAagbWKUWQW9jYCPu9aiWoPHRdTs4ayhu9KqlQCr7EGNBVOGdS65IYbqhHCLwf6C8aW5E(HQU(tU(NRTmlNlQix0GP5clNRo5kA)BucDCC9hs7i(Cj2BjCa0rOoQqNJhagdycxf3PfUEcIRJawOW4C)u4Qhab2jyHcdfbRhfE8gHdGoc1rf6C8aWnEcRct7tFVr6c6lUk(b0QCOtdWiaM0fwfUprMlLQhab2jnCDOvcha7UkHwu5(t5E9i(KlEyltY174CJJR)K7pL75ctcRcNlfgOJqUNUygUOJqUXqZDEp3GKBKlGfGlbi3446pTe6446pK2r85sS3IRdTAvcIJXpL71J4dwOsOtOJJR)qAuCHQd0Xw2jyHjCvDghJjWzS0ayl()tLYhBRvzyhWKdphoHooU(dPrXfQoqhBzNCj2BHjCvDghJjWzSe4XQ8pTg4S3DN4j0XX1FinkUq1b6yl7KlXElmHRQZ4ymboJvOCxUR(i1GquCTeU(tcDCC9hsJIluDGo2Yo5sS3ct4Q6mogtGZyPaoOikGRqycHlj0j0IkxrwOtUIwm1ghJCjDpCHM75HWGCJsjxqmcmj3hjxpacStYngAUKdpbqFscDCC9hsdp05sS3EIsPghx)PwuIJXe4mwR)hmioqpowOWqrWAbJG0S(FQps174Aqo8qzAdwoHooU(dPHh6Cj2BPkrMlv8qqpj0IkxmNW5IzVsZ9gbGLD9NC)j3Z)f6lEYv()Ioc5gEUfoiEU2GiYvhsmQFpxlyp359CvKCV)W5kwlLCFim4eY5Qdjg1VNRo5Iz2OwUISWwoxcmGZL0f0xmIYd9wCDOw8qzqUkj3FY98FH(INCTyKhW5Iz3OwcDCC9hsdp0blKxPvgal76pyOiyHeanSkCt()sf5b1dL0xhsmQF3oS2Gi6BVoKyu)EVXEd2uIepk84nchaDeQJk054bGB8ewfM2hsa0WQWnchaDeQJk054bGRhy)rq6P)fN)l0x80quEOny5eArLRilSLZLad4CV)W5kd75clNlQix0GP5kArfTyAU)KR3X56bqG9CvKCf5GW7qGl5AJcgOCUkzWe9CJJRq4wcDCC9hsdp05sS3s6c6lUk(b0QCOdgkcwlyeKgsWvb4aq1yiny5(xqzlyeKMyq4DiWLksWaLBWYj0XX1Fin8qNlXE7jkLACC9NArjogtGZypuscTOYv0tf6Yftb6du)EUImDO5IYbi3446p56FUagbWKUCV5lfjxXQ3LlHdGoc1rf6C8aWj0XX1Fin8qNlXElUo0kHdagN7Ncx9aiWobluyOiy9OWJ3iCa0rOoQqNJhaUXtyvyAFImxkvpacStA46qReoa2bjaAyv4gUo0kHdq9a7pcs)lOV3iDb9fxf)aAvo0P56XwDe6FX5)c9fpneLhAdwoHwu5IPagHb56FUWeo3Bg4t46p5kArfTyAUksUXCp3B(sLRsYDEpxy5wcDCC9hsdp05sS3sd8jC9hmo3pfU6bqGDcwOWqrWEbKaOHvHBrPuPVtQWYj0IkxmNW5IzVsZ96V45gEUDQqhdYvgOpq975kw9UCf9GhbgOJqUy2R0CHLZ1)CTHC9aiWobJCFqUV3XGC9OWJtY9NCrLQLqhhx)H0WdDUe7TqELwT(IJHIGvhsmQFV3yVbB23JcpERdEeyGocviVsB8ewfM23JcpEJWbqhH6OcDoEa4gpHvHP9jYCPu9aiWoPHRdTs4a0BSysjsS3Epk84To4rGb6iuH8kTXtyvyA)l8OWJ3iCa0rOoQqNJhaUXtyvyApsKqK5sP6bqGDsdxhALWbalu9KqlQCV5pyIEUWeo3BYqEyGoc5IPLqaMZvrY9(dN7jMCfypxD8pxm7vkYdWZvhIZbfJCFqUksUOCa0rixPvHohpaCUkjxpk84mn3yO5kwlLC7upxEEyHUC9aiWoPLqhhx)H0WdDUe7TugYdd0rOkxcbygJZ9tHREaeyNGfkmueS2dyeat6cRclrIoKyu)UDIoB2tF7Vasa0WQWn5)lvKhupuIej6qIr972H9gSzp9T)cpk84nchaDeQJk054bGB8ewfMkrI9Eu4XBeoa6iuhvOZXda34jSkmT)fqcGgwfUr4aOJqDuHohpaC9a7pcsp9KqlQCXCcNlMDDU)KBVCZCvKCV)W5s)bt0ZDyMMR)5EcIN7nzipmqhHCX0siaZyKBm0C9ogW5gao3cti56DXKRnKRhab2j5(WEU2BZCfRExUNFOWQ3tlHooU(dPHh6Cj2BH8kTA9fhdfblrMlLQhab2jnCDOvchGEBVnC55hkS6nQsi)eJx5t3ZKgpHvHP90xhsmQFV3yVbB23JcpEJWbqhH6OcDoEa4gpHvHPsKCHhfE8gHdGoc1rf6C8aWnEcRcttOfvUyoHZfTlOV4Cf5pGkAY9MC4D5Qi56DCUEaeypxLKBy9WEU(Nlv5CFqU3F4C7ciCUODb9fJucCoxmfOe8C5BmSklZ0CfRExUImDOw8qzqUpix0UG(IruEO5ghxHWTe6446pKgEOZLyVL0f0xCv8dOvkhEhgN7Ncx9aiWobluyOiyT3dGa7TookExt(49(kr0NiZLs1dGa7KgUo0kHdqVTHEKiXEz2Bikp0wCCfc3hapmYde4gPlOVyKsGZvzGsWB8ngwLLzApj0IkxmNW5Icda8qzqU(NRilOdti5(tUrUEaeypxVl8CvsUcVoc56FUuLZn8C9ooxGk0556ko3sOJJR)qA4HoxI9wcmaWdLbv)R4bDycbJZ9tHREaeyNGfkmueSEaeyV5kox9VsvU3xzZ(wWiiniVsrEaEJ(INeArLlMt4CXSxP5k1da845(t5EUksUOICrdMMBm0CXmPYnaCUXXviCUXqZ174C9aiWEUI)bt0ZLQCUuyGoc56DCUNUygU0sOJJR)qA4HoxI9wiVsR(da84yCUFkC1dGa7eSqHHIGfsa0WQWn67KkSCFpacS3CfNR(xPkBxV23cgbPb5vkYdWB0x80poUcHR03BqcCzfONQ)WNo7WsK5sP6bqGDsdsGlRa9u9h(01NiZLs1dGa7KgUo0kHdqVT3MxApMuKGhfE8MlwjE9rQiHZnEcRct7PNe6446pKgEOZLyVfxhQfpugGHIGL(EdsGlRa9u9h(01C9yRoc9T3JcpEJWbqhH6OcDoEa4gpHvHP9jYCPu9aiWoPHRdTs4ayhKaOHvHB46qReoa1dS)iisKqFVr6c6lUk(b0QCOtZ1JT6i0tcTOYfZjCUOICrZnZvS6D5IPHowaoSLb5IPKOGNl8uycjxVJZ1dGa75kwlLCT4CT4Ylo3ReHn25AXipGZ174Cp)xOV4j3ZJZKCTIJTj0XX1Fin8qNlXElPlOV4Q4hqRuo8omueSa4HrEGa3KdDSaCyldQYKOG34BmSklZ0(qcGgwfUrFNuHL77bqG9MR4C1)Q8XRxjc7S)8FH(INgPlOV4Q4hqRuo8UgfgeU(ZLchApj0IkxmNW5I2f0xCU9ciiD5(tU9YnZfEkmHKR3Xao3aW5gukjxDopUocTe6446pKgEOZLyVL0f0xC9acshgkcwqO0kdHhVfukPPJDqjIeArLlMt4Cfz6qZfLdqU(N75hcmoN7ndGT5kv3dl05KCLb)HK7p5kAfjVrTCLsK8MIK52l)GOa8CvsUENsYvj5g52PcDmixzG(a1VNR3ftUaM(URJqU)KROvK8gLl8uycjxAaSnxV7Hf6CsUkj3W6H9C9pxxX5CFypHooU(dPHh6Cj2BX1HwjCaW4C)u4Qhab2jyHcdfblrMlLQhab2jnCDOvcha7GeanSkCdxhALWbOEG9hbPVfmcsJgaBRE3dl05nyzmoDHoyHcdDCgaGL9QIJZunCgluyOJZaaSSxveSUESLyh2RsOfvUyoHZvKPdnxBujUNR)5E(HaJZ5EZayBUs19WcDojxzWFi5(tUOs1YvkrYBksMBV8dIcWZvrY17usUkj3i3ovOJb5kd0hO(9C9UyYfW03DDeYfEkmHKlna2MR39WcDojxLKBy9WEU(NRR4CUpSNqhhx)H0WdDUe7T46qRiL4ogkcwlyeKgna2w9UhwOZBWY9HeanSkCJ(oPclJXPl0bluyOJZaaSSxvCCMQHZyHcdDCgaGL9QIG11JTe7WEv)Z)f6lEAqELwT(I3GLtOfvUyoHZvKPdn3RlbXZvrY9(dNl9hmrp3HzAU(NlGramPl3B(srA5I6VCUNG46iKB45Ad5(GCXFaNRhab2j5kw9UCr5aOJqUsRcDoEa4C9OWJZ0wcDCC9hsdp05sS3IRdTAvcIJHIGfsa0WQWn67KkSCFqO0kdHhVH)qyCE8Mo2DcIxDfNVuenB23EImxkvpacStA46qReoa92g6FHhfE8gUsyW9gpHvHPsKqK5sP6bqGDsdxhALWbO3yY(Eu4XB4kHb3B8ewfM2tcDCC9hsdp05sS3cjWLvGEQ(dF6W4C)u4Qhab2jyHcdfblGramPlSkCFpacS3CfNR(xPkBhMuIe79OWJ3WvcdU34jSkmTp99gPlOV4Q4hqRYHonaJaysxyv4EKiXcgbPbpiWGIocvAaSDycPblNqlQCrL5JgLCp)qvx)jx)ZL4VCUNG46iKlQix0GP5(tUpcIngpacStYvChp5IOcDUoc52R5(GCXFaNlXJJTmnx83IKBm0CHj6iKlMsUF60tU246yBUXqZvArsPYvKPegCVLqhhx)H0WdDUe7TKUG(IRIFaTkh6GHIGfWiaM0fwfUVhab2BUIZv)RuLTZg6FHhfE8gUsyW9gpHvHP99OWJ3Kj3pD6Pw0X2gpHvHP9jYCPu9aiWoPHRdTs4ay3vj0IkxmbYSCUOICrdMMlSCU)KBqYfpM756bqGDsUbjx5NquRcJrUSO)HL9Cf3XtUiQqNRJqU9AUpix8hW5s84yltZf)Ti5kw9UCXuY9tNEY1gxhBBj0XX1Fin8qNlXElPlOV4Q4hqRYHoyCUFkC1dGa7eSqHHIGfWiaM0fwfUVhab2BUIZv)RuLTZg6FHhfE8gUsyW9gpHvHP9VWEpk84nchaDeQJk054bGB8ewfM2NiZLs1dGa7KgUo0kHdGDqcGgwfUHRdTs4aupW(JG0tF7VWJcpEtMC)0PNArhBB8ewfMkrI9Eu4XBYK7No9ul6yBJNWQW0(ezUuQEaeyN0W1HwjCa6n2R6PNe6446pKgEOZLyVfxhALWbaJZ9tHREaeyNGfkmueSezUuQEaeyN0W1HwjCaSdsa0WQWnCDOvchG6b2FeemoDHoyHcdDCgaGL9QIJZunCgluyOJZaaSSxveSUESLyh2RsOJJR)qA4HoxI9wCDOvKsChJtxOdwOWqhNbayzVQ44mvdNXcfg64maal7vfbRRhBj2H9Q(N)l0x80G8kTA9fVblNqlQCXCcNlQix0CZCdsULG45cyYd8CvKC)jxVJZf)HWj0XX1Fin8qNlXElPlOV4Q4hqRuo8UeArLlMt4Crf5Igmn3GKBjiEUaM8apxfj3FY174CXFiCUXqZfvKlAUzUkj3FYTxUzcDCC9hsdp05sS3s6c6lUk(b0QCOtcDcTOYfZjCU)KBVCZCfTOIwmnx)ZvG9CV5lvUUESvhHCJHMll6lRaox)ZTOdNlSCUwS7mixXQ3LlM9kf5b4j0XX1FinhOJTStWct4Q6mogtGZyzC57aok1hqNyomgkc2Z)f6lEAqELwzaSSR)0amEOdP3yH6kjso)xOV4Pb5vALbWYU(tdW4Hoe7Us0LqlQCrVpNCfPWeWnZvS6D5IzVsrEaEcDCC9hsZb6yl7KlXElmHRQZ4ymboJvhYba7HvHR3y4yCy8kLHOhgdfb75)c9fpniVsRmaw21FAagp0HyhuIiHwu5IEFo5I2XSNRidMONCfRExUy2RuKhGNqhhx)H0CGo2Yo5sS3ct4Q6mogtGZyXJtyb4kPJzVIdt0dgkc2Z)f6lEAqELwzaSSR)0amEOdXoOercTOYf9(CY1glyR75kw9UCX0xmdYvKAqGj6p5ctcbgJCXdB5CjWaox)ZLmQmNR3X5wEXmXZv0dtZ1dGa7j0XX1FinhOJTStUe7TWeUQoJJXe4mwYdxkS76iubWw3XqrWAbJG0KFXmOQdcmr)PbllrYfYaLjEJWfKQ8lMbvDqGj6pyCUFkC1dGa7eSqLqlQCXCcN71bvGZvhIs5CFKCXmBuUipixVJZfrbepxycN7dY9NC7LBMBG4mixVJZfrbepxyc3YfT7bEUhfCGvpxfjxiVsZLbWYU(tUN)l0x8KRsYfkrqY9b5I)ao3qCCVLqhhx)H0CGo2Yo5sS3ct4Q6mogtGZyj6GaxQcLGQH)as1kOcC9rQim4pQFhdfb75)c9fpniVsRmaw21FAagp0HyhwOercTOYfZjCUfL45(i5(JngycNlnWdboxhOJTStY9NY9CvKCf9GhbgOJqUy2R0CVjBbJGKRsYnoUcHXi3hK79ho3aW5oVNRhfECMMRo(NR6Te6446pKMd0Xw2jxI92tuk1446p1IsCmMaNXsXfQoqhBzNGHIG1(l8OWJ36GhbgOJqfYR0gpHvHPsKqzlyeKwh8iWaDeQqEL2GL7PV9wWiiniVsrEaEdwwIKZ)f6lEAqELwzaSSR)0amEOdXoOerpj0Ik3BYibCXZfjkfR4yBUipixysyv4CvNXjIMCXCcN7p5E(VqFXtU6K7dOmixR756aDSL9CjL3Bj0XX1FinhOJTStUe7TWeUQoJtWqrWAbJG0G8kf5b4nyzjsSGrqAYVygu1bbMO)0GLLi58FH(INgKxPvgal76pnaJh6qSdkryCJBma]] )

end
