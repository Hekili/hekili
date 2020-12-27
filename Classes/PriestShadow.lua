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


    spec:RegisterPack( "Shadow", 20201227, [[da1lFbqivcpIqQlbfb0MKQ6tqrOrrPQtjvXQGIQ4vQenlOWTiKqTlP8lvknmcHJbswMkjpJsrMgLcUMuLABqrLVPsHghueDokfkRJqIMNuLCpO0(Ou5GesYcvj1dPuutuLIUOkf0gPuiFKqczKeskNKqcwji1lHIa1mPuO6MeIYojs9tOOQgkuKokueilfkcWtH0ujsUkHiBfkkFLquTxk(RKgSshwyXuYJvXKr6YO2meFMGrlvonPvdfb9AkLMTe3gQ2TIFRQHtuhxLcSCGNJy6uDDqTDq8Dc14jKuDEvQwpuuLMprSFrBGYiLbLgoBK(krCLiG6QRUXguIakOSjmNb1VlZgu54yBiWg0jWzdkAxqFXgu54E5dQrkdk5Hbh2G25UmruE7TcQ3bB1op(TefhUeU(Zbei(Tef)CRb1cwlUOWySmO0WzJ0xjIRebuxD1n2GseqbLn1BdAa7DpWGIQ42SbTtPuEmwguktogurNlAxqFX5IPaLjEcTOZ9M8HXTyqUxDJyK7vI4krKqNql6CLsmh2MlM9knxPEaGhpxXD8KRhab2Z98WJtYnaCUip4W0MbTOeNyKYGkd4ZJBfUrkJ0qzKYGYtyvyQ5Ad6bOod0WGcy8qhsU9kxBseIWGghx)XGk)Izqv8dOvKh4QdtzJBK(kJuguEcRctnxBqpa1zGgg0lY1cgbPr6c6lg5b4nyzdACC9hdkPlOVyKhGBCJ02KrkdkpHvHPMRnOhG6mqddQoKyu)EJYi6r9CTlxO6TbnoU(JbnaNy4Q)aapUXnsBdgPmO8ewfMAU2G(Yguc7g0446pguibqdRcBqHefy2GELbfsaQtGZguCDOvchG6b2FeeJBKU3gPmOXX1FmOqcCzfONQ)WNodkpHvHPMRnUXnOuCHQd0Xw2jgPmsdLrkdkpHvHPMRnOtGZguAaSf))Ps5JT1QmSdyYHNdBqJJR)yqPbWw8)NkLp2wRYWoGjhEoSXnsFLrkdkpHvHPMRnOtGZguc8yv(NwdC27UtCdACC9hdkbESk)tRbo7D3jUXnsBtgPmO8ewfMAU2GoboBqfk3L7QpsniefxlHR)yqJJR)yqfk3L7QpsniefxlHR)yCJ02GrkdkpHvHPMRnOtGZgukGdkIc4keMq4IbnoU(JbLc4GIOaUcHjeUyCJBqPmsaxCJugPHYiLbnoU(JbLOfEoSbLNWQWuZ1g3i9vgPmO8ewfMAU2GEaQZanmOwWiiniVsrEaEdwoxjsY1cgbPj)IzqvheyI(tdw2Gghx)XGk)U(JXnsBtgPmO8ewfMAU2G(Yguc7g0446pguibqdRcBqHefy2GsFVr6c6lUk(b0QCOtZ1JT6iKB)CPV3Ge4Ykqpv)HpDnxp2QJGbfsaQtGZgu67KkSSXnsBdgPmO8ewfMAU2G(Yguc7g0446pguibqdRcBqHefy2GsFVr6c6lUk(b0QCOtZ1JT6iKB)CPV3Ge4Ykqpv)HpDnxp2QJqU9ZL(EJYqEyGocv5siaZnxp2QJGbfsaQtGZg0OuQ03jvyzJBKU3gPmO8ewfMAU2G(Yguc7g0446pguibqdRcBqHefy2GsK5sP6bqGDsdxhALWbix7Y9QCVmxlyeKgKxPipaVblBqHeG6e4SbLWbqhH6OcDoEa46b2FeeJBKgZzKYGYtyvyQ5Ad6lBqjSBqJJR)yqHeanSkSbfsuGzd65)c9fpniVsRmaw21FAWY52px7Z9ICbHsRmeE8wqPKgSCUsKKliuALHWJ3ckL0OWGW1FYTxyZfkrKRej5ccLwzi84TGsjnaJh6qY1oS5cLiY9YC7DUyEY1(C9OWJ36GhbgOJqfYR0gpHvHP5krsUNhcpX4nBVd0yYTNC7j3(5AFU2NliuALHWJ3ckL00jx7Y9krKRej5sK5sP6bqGDsdYR0kdGLD9NCTdBU9o3EYvIKC9OWJ36GhbgOJqfYR0gpHvHP5krsUNhcpX4nBVd0yYThdkKauNaNnOY)xQipOEOeJBK(gnszq5jSkm1CTb9auNbAyqTGrqAqELI8a8gSSbnoU(JbfrbSv5FQXnsJjnszq5jSkm1CTb9auNbAyqTGrqAqELI8a8gSSbnoU(Jb1IbegyRocg3iTnMrkdkpHvHPMRnOhG6mqddkrMlLQhab2jTIk05KkMqyQaopEU2Hn3RYvIKCTp3lYfekTYq4XBbLsASOUsCsUsKKliuALHWJ3ckL00jx7Y9g7DU9yqJJR)yqlQqNtQycHPc484g3inuIWiLbLNWQWuZ1g0dqDgOHb1cgbPb5vkYdWBWYg0446pg0yomXbrPEIsX4gPHckJuguEcRctnxBqJJR)yqprPuJJR)ulkXnOfL41jWzd6r8X4gPH6kJuguEcRctnxBqJJR)yqbWtnoU(tTOe3GwuIxNaNnO4Hog34g0J4JrkJ0qzKYGYtyvyQ5AdkmHRI70cxpbX1rWinug0446pguchaDeQJk054bGnON7Ncx9aiWoXinug0dqDgOHb1(CHeanSkCJWbqhH6OcDoEa46b2FeKC7N7f5cjaAyv4M8)LkYdQhkj3EYvIKCTpx67nsxqFXvXpGwLdDAagbWKUWQW52pxImxkvpacStA46qReoa5AxUqLBpg3i9vgPmO8ewfMAU2Gct4Q4oTW1tqCDemsdLbnoU(JbLWbqhH6OcDoEayd65(PWvpacStmsdLb9auNbAyq9OWJ3iCa0rOoQqNJhaUXtyvyAU9ZL(EJ0f0xCv8dOv5qNgGramPlSkCU9ZLiZLs1dGa7KgUo0kHdqU2L7vg3iTnzKYGYtyvyQ5Ad6pL71J4JbfkdACC9hdkUo0QvjiUXnUb1b6yl7eJugPHYiLbLNWQWuZ1g0446pgugx(oGJs9b0jMdBqpa1zGgg0Z)f6lEAqELwzaSSR)0amEOdj3EHnxOUkxjsY98FH(INgKxPvgal76pnaJh6qY1UCV6gnOtGZgugx(oGJs9b0jMdBCJ0xzKYGYtyvyQ5AdACC9hdQoKda2dRcxVbWX4W4vkdrpSb9auNbAyqp)xOV4Pb5vALbWYU(tdW4HoKCTlxOeHbDcC2GQd5aG9WQW1BaCmomELYq0dBCJ02KrkdkpHvHPMRnOXX1FmO4XjSaCL0XSxXHj6XGEaQZanmON)l0x80G8kTYayzx)Pby8qhsU2LluIWGoboBqXJtyb4kPJzVIdt0JXnsBdgPmO8ewfMAU2GoboBqjpCPWURJqfaBD3GEUFkC1dGa7eJ0qzqpa1zGggulyeKM8lMbvDqGj6pny5CLij3lYvgOmXBeUGuLFXmOQdcmr)XGghx)XGsE4sHDxhHka26UXns3BJuguEcRctnxBqJJR)yqj6GaxQcLGQH)as1kOcC9rQim4pQF3GEaQZanmON)l0x80G8kTYayzx)Pby8qhsU2HnxOeHbDcC2Gs0bbUufkbvd)bKQvqf46JuryWFu)UXnsJ5mszq5jSkm1CTb9auNbAyqTp3lY1JcpERdEeyGocviVsB8ewfMMRej5szlyeKwh8iWaDeQqEL2GLZTNC7NR95AbJG0G8kf5b4ny5CLij3Z)f6lEAqELwzaSSR)0amEOdjx7YfkrKBpg0446pg0tuk1446p1IsCdArjEDcC2GsXfQoqhBzNyCJ03OrkdkpHvHPMRnOhG6mqddQfmcsdYRuKhG3GLZvIKCTGrqAYVygu1bbMO)0GLZvIKCp)xOV4Pb5vALbWYU(tdW4HoKCTlxOeHbnoU(JbfMWv1zCIXnUb9qjgPmsdLrkdkpHvHPMRnOhG6mqddQfmcsdYRuKhG3GLZvIKCVixYdxS0H2opUv4vCMQE46pnEcRctZTFUN)l0x80G8kTYayzx)Pby8qhsU2HnxOerUsKKlIk05vaJh6qYTx5E(VqFXtdYR0kdGLD9NgGXdDig0446pgu5xmdQ6Gat0FmUr6Rmszq5jSkm1CTb9auNbAyqbWdJ8abUry5oymVKQm4pLapC9NgFdGvzzMMB)CTpxpacS3usnO0CLijxpacS3OSfmcs7eexhHgGJJNBpg0446pguIw45Wg3iTnzKYGYtyvyQ5AdACC9hdkrhe4svOeun8hqQwbvGRpsfHb)r97g0dqDgOHb1cgbPb5vkYdWBWY5krsUUIZ5AxUqjIC7NR95ErUNhcpX4Trf68ksW52JbDcC2Gs0bbUufkbvd)bKQvqf46JuryWFu)UXnsBdgPmO8ewfMAU2GEaQZanmOxKRfmcsdYRuKhG3GLZTFU2N7f5E(VqFXtdYR0Q)aapEdwoxjsY9IC9OWJ3G8kT6paWJ34jSkmn3EYvIKCTGrqAqELI8a8gSCU9Z1(CjpCXshAta8q4QoquHheU(tJNWQW0CLijxYdxS0H2quUqRps1Q8eYJtA8ewfMMBpg0446pguKGRcWbGQXqmUr6EBKYGYtyvyQ5AdACC9hdkUouHaNjg0dqDgOHbvhsmQFp3ELRnMiYTFU2NR95cjaAyv4wukv67KkSCU9Z1(CVi3Z)f6lEAqELwzaSSR)0GLZvIKCVixpk84To4rGb6iuH8kTXtyvyAU9KBp5krsUwWiiniVsrEaEdwo3EYTFU2N7f56rHhV1bpcmqhHkKxPnEcRctZvIKCPSfmcsRdEeyGocviVsBWY5krsUxKRfmcsdYRuKhG3GLZTNC7NR95ErUEu4XBeoa6iuhvOZXda34jSkmnxjsYLiZLs1dGa7KgUo0kHdqU9k3ENBpg0Z9tHREaeyNyKgkJBKgZzKYGYtyvyQ5Ad6bOod0WGAFU2N7f5ccLwzi84TGsjny5C7NliuALHWJ3ckL00jx7Y9krKBp5krsUGqPvgcpElOusdW4HoKCTdBUq17CLijxqO0kdHhVfukPrHbHR)KBVYfQENBp52px7Z1cgbPj)IzqvheyI(tdwoxjsY98FH(INM8lMbvDqGj6pnaJh6qY1oS5cLiYvIKCVixzGYeVr4csv(fZGQoiWe9NC7j3(5AFUxKRhfE8wh8iWaDeQqEL24jSkmnxjsYLYwWiiTo4rGb6iuH8kTblNRej5ErUwWiiniVsrEaEdwo3EmOXX1FmOWt3xUxNhsyCJ03OrkdkpHvHPMRnOhG6mqdd6f5AbJG0G8kf5b4ny5C7N7f5E(VqFXtdYR0kdGLD9NgSCU9ZLiZLs1dGa7KgUo0kHdqU2Llu52p3lY1JcpEJWbqhH6OcDoEa4gpHvHP5krsU2NRfmcsdYRuKhG3GLZTFUezUuQEaeyN0W1HwjCaYTx5EvU9Z9IC9OWJ3iCa0rOoQqNJhaUXtyvyAU9ZvgWqQchAdQgKxPvRV452tUsKKR95AbJG0G8kf5b4ny5C7NRhfE8gHdGoc1rf6C8aWnEcRctZThdACC9hdQ1)t9rQEhxdYHhktnUrAmPrkdkpHvHPMRnOXX1FmONOuQXX1FQfL4g0Is86e4Sb1b6yl7eJBCdQ1)JrkJ0qzKYGYtyvyQ5Ad6bOod0WGsK5sP6bqGDsdxhALWbi3EHnxBYGghx)XGgKdpuMwTkbXnUr6Rmszq5jSkm1CTb9auNbAyq9aiWEtS6D6GjZTFUezUuQEaeyN0cYHhktRZdjY1UCHk3(5sK5sP6bqGDsdxhALWbix7YfQCVmxpk84nchaDeQJk054bGB8ewfMAqJJR)yqdYHhktRZdjmUXnO4HogPmsdLrkdkpHvHPMRnOhG6mqddQfmcsZ6)P(ivVJRb5WdLPnyzdkXb6XnsdLbnoU(Jb9eLsnoU(tTOe3GwuIxNaNnOw)pg3i9vgPmOXX1FmOuLiZLkEiOhdkpHvHPMRnUrABYiLbLNWQWuZ1g0dqDgOHbfsa0WQWn5)lvKhupusU9ZvhsmQFpx7WMRniIC7NR95Qdjg1VNBVWMlMS35krsUEu4XBeoa6iuhvOZXda34jSkmn3(5cjaAyv4gHdGoc1rf6C8aW1dS)ii52tU9Z9ICp)xOV4PHO8qBWYg0446pguiVsRmaw21FmUrABWiLbLNWQWuZ1g0dqDgOHb1cgbPHeCvaoaungsdwo3(5ErUu2cgbPjgeEhcCPIemq5gSSbnoU(JbL0f0xCv8dOv5qhJBKU3gPmO8ewfMAU2Gghx)XGEIsPghx)PwuIBqlkXRtGZg0dLyCJ0yoJuguEcRctnxBqJJR)yqX1HwjCamOhG6mqddQhfE8gHdGoc1rf6C8aWnEcRctZTFUezUuQEaeyN0W1HwjCaY1UCHeanSkCdxhALWbOEG9hbj3(5ErU03BKUG(IRIFaTkh60C9yRoc52p3lY98FH(INgIYdTblBqp3pfU6bqGDIrAOmUr6B0iLbLNWQWuZ1g0446pguAGpHR)yqpa1zGgg0lYfsa0WQWTOuQ03jvyzd65(PWvpacStmsdLXnsJjnszq5jSkm1CTb9auNbAyq1HeJ63ZTxyZft27C7NRhfE8wh8iWaDeQqEL24jSkmn3(56rHhVr4aOJqDuHohpaCJNWQW0C7NlrMlLQhab2jnCDOvchGC7f2CXC5krsU2NR956rHhV1bpcmqhHkKxPnEcRctZTFUxKRhfE8gHdGoc1rf6C8aWnEcRctZTNCLijxImxkvpacStA46qReoa5InxOYThdACC9hdkKxPvRV4g3iTnMrkdkpHvHPMRnOXX1FmOugYdd0rOkxcby2GEaQZanmO2NlGramPlSkCUsKKRoKyu)EU2L7n27C7j3(5AFUxKlKaOHvHBY)xQipOEOKCLijxDiXO(9CTdBUyYENBp52px7Z9IC9OWJ3iCa0rOoQqNJhaUXtyvyAUsKKR956rHhVr4aOJqDuHohpaCJNWQW0C7N7f5cjaAyv4gHdGoc1rf6C8aW1dS)ii52tU9yqp3pfU6bqGDIrAOmUrAOeHrkdkpHvHPMRnOhG6mqddkrMlLQhab2jnCDOvchGC7vU2NRnK7L5E(HcREJQeYpX4v(09mPXtyvyAU9KB)C1HeJ63ZTxyZft27C7NRhfE8gHdGoc1rf6C8aWnEcRctZvIKCVixpk84nchaDeQJk054bGB8ewfMAqJJR)yqH8kTA9f34gPHckJuguEcRctnxBqJJR)yqjDb9fxf)aALYH3zqpa1zGggu7Z1dGa7TookExt(452RCVse52pxImxkvpacStA46qReoa52RCTHC7jxjsY1(CLzVHO8qBXXviCU9ZfapmYde4gPlOVyKsGZvzGsWB8nawLLzAU9yqp3pfU6bqGDIrAOmUrAOUYiLbLNWQWuZ1g0446pgucmaWdLbv)R4bDycXGEaQZanmOEaeyV5kox9Vsvo3EL7v9o3(5AbJG0G8kf5b4n6lEmON7Ncx9aiWoXinug3inu2KrkdkpHvHPMRnOXX1FmOqELw9ha4XnOhG6mqddkKaOHvHB03jvy5C7NRhab2BUIZv)RuLZ1UCTPC7NRfmcsdYRuKhG3OV4j3(5ghxHWv67nibUSc0t1F4txU2HnxImxkvpacStAqcCzfONQ)WNUC7NlrMlLQhab2jnCDOvchGC7vU2NBVZ9YCTpxmxUyEY1JcpEZfReV(ivKW5gpHvHP52tU9yqp3pfU6bqGDIrAOmUrAOSbJuguEcRctnxBqpa1zGggu67nibUSc0t1F4txZ1JT6iKB)CTpxpk84nchaDeQJk054bGB8ewfMMB)CjYCPu9aiWoPHRdTs4aKRD5cjaAyv4gUo0kHdq9a7pcsUsKKl99gPlOV4Q4hqRYHonxp2QJqU9yqJJR)yqX1HAXdLbg3inu92iLbLNWQWuZ1g0dqDgOHbfapmYde4MCOJfGdBzqvMef8gFdGvzzMMB)CHeanSkCJ(oPclNB)C9aiWEZvCU6Fv(41RerU2LR95E(VqFXtJ0f0xCv8dOvkhExJcdcx)j3lZv4qZThdACC9hdkPlOV4Q4hqRuo8oJBKgkmNrkdkpHvHPMRnOhG6mqddkiuALHWJ3ckL00jx7YfkryqJJR)yqjDb9fxpGG0zCJ0qDJgPmO8ewfMAU2Gghx)XGIRdTs4ayqp3pfU6bqGDIrAOmO64maal7vfXG66XwIDyVYGQJZaaSSxvCCMQHZguOmOhG6mqddkrMlLQhab2jnCDOvchGCTlxibqdRc3W1HwjCaQhy)rqYTFUwWiinAaST6DpSqN3GLnONUqhdkug3inuysJuguEcRctnxBqJJR)yqX1HwrkXDdQoodaWYEvrmOUESLyh2R6F(VqFXtdYR0Q1x8gSSbvhNbayzVQ44mvdNnOqzqpa1zGggulyeKgna2w9UhwOZBWY52pxibqdRc3OVtQWYg0txOJbfkJBKgkBmJuguEcRctnxBqpa1zGgguibqdRc3OVtQWY52pxqO0kdHhVH)qyCE8Mo5AxUNG4vxX5CVmxr06DU9Z1(CjYCPu9aiWoPHRdTs4aKBVY1gYTFUxKRhfE8gUsyW9gpHvHP5krsUezUuQEaeyN0W1HwjCaYTx5I5YTFUEu4XB4kHb3B8ewfMMBpg0446pguCDOvRsqCJBK(kryKYGYtyvyQ5AdACC9hdkKaxwb6P6p8PZGEaQZanmOagbWKUWQW52pxpacS3CfNR(xPkNRD5I5YvIKCTpxpk84nCLWG7nEcRctZTFU03BKUG(IRIFaTkh60amcGjDHvHZTNCLijxlyeKg8Gadk6iuPbW2HjKgSSb9C)u4Qhab2jgPHY4gPVckJuguEcRctnxBqpa1zGgguaJaysxyv4C7NRhab2BUIZv)RuLZ1UCTHC7N7f56rHhVHRegCVXtyvyAU9Z1JcpEtMC)0PNArhBB8ewfMMB)CjYCPu9aiWoPHRdTs4aKRD5ELbnoU(JbL0f0xCv8dOv5qhJBK(QRmszq5jSkm1CTbnoU(JbL0f0xCv8dOv5qhd6bOod0WGcyeat6cRcNB)C9aiWEZvCU6FLQCU2LRnKB)CVixpk84nCLWG7nEcRctZTFUxKR956rHhVr4aOJqDuHohpaCJNWQW0C7NlrMlLQhab2jnCDOvchGCTlxibqdRc3W1HwjCaQhy)rqYTNC7NR95ErUEu4XBYK7No9ul6yBJNWQW0CLijx7Z1JcpEtMC)0PNArhBB8ewfMMB)CjYCPu9aiWoPHRdTs4aKBVWM7v52tU9yqp3pfU6bqGDIrAOmUr6RSjJuguEcRctnxBqJJR)yqX1HwjCamON7Ncx9aiWoXinuguDCgaGL9QIyqD9ylXoSxzq1Xzaaw2Rkoot1Wzdkug0dqDgOHbLiZLs1dGa7KgUo0kHdqU2LlKaOHvHB46qReoa1dS)iig0txOJbfkJBK(kBWiLbLNWQWuZ1g0446pguCDOvKsC3GQJZaaSSxvedQRhBj2H9Q(N)l0x80G8kTA9fVblBq1Xzaaw2Rkoot1Wzdkug0txOJbfkJBK(QEBKYGghx)XGs6c6lUk(b0kLdVZGYtyvyQ5AJBK(kmNrkdACC9hdkPlOV4Q4hqRYHoguEcRctnxBCJBCdkegq0FmsFLiUseqDfu3ObvCagDeigurbC5h4mnxmzUXX1FYTOeN0sOnOYGhrlSbv05I2f0xCUykqzINql6CVjFyClgK7v3ig5ELiUsej0j0IoxPeZHT5IzVsZvQha4XZvChp56bqG9Cpp84KCdaNlYdomTLqNql6CVHI68b2zAUwmYd4CppUv45AXc6qA5kQohw2j5o)ikUla4iWLCJJR)qY9NY9wcDCC9hstgWNh3k8lXER8lMbvXpGwrEGRomLXqrWcy8qhsVSjriIe6446pKMmGppUv4xI9wsxqFXipahdfb7fwWiinsxqFXipaVblNqhhx)H0Kb85XTc)sS3gGtmC1FaGhhdfbRoKyu)EJYi6rD7GQ3j0XX1FinzaFECRWVe7TqcGgwfgJjWzS46qReoa1dS)iiy8YyjSJbKOaZyVkHooU(dPjd4ZJBf(LyVfsGlRa9u9h(0LqNql6CX031Fij0XX1FiyjAHNdNqhhx)HGv(D9hmueSwWiiniVsrEaEdwwIelyeKM8lMbvDqGj6pny5e6446pKlXElKaOHvHXycCgl9DsfwgJxglHDmGefygl99gPlOV4Q4hqRYHonxp2QJqF67nibUSc0t1F4txZ1JT6iKqhhx)HCj2BHeanSkmgtGZyJsPsFNuHLX4LXsyhdirbMXsFVr6c6lUk(b0QCOtZ1JT6i0N(EdsGlRa9u9h(01C9yRoc9PV3OmKhgOJqvUecWCZ1JT6iKql6Cr9a45ct0rixuoa6iKR0QqNJhao3WZ1MUmxpacStY9b5AdxMRIK79ho3aW5QtUy2RuKhGNqhhx)HCj2BHeanSkmgtGZyjCa0rOoQqNJhaUEG9hbbJxglHDmGefyglrMlLQhab2jnCDOvcha7U6slyeKgKxPipaVblNql6CT5)l0x8KlM(FjxmlaAyvymYvKimnx)Zv()sUwmYd4CJJRqcxhHCH8kf5b4TCTzyaGhVCpxyctZ1)Cp)4GVKR4oEY1)CJJRqcNZfYRuKhGNRy17YvNZJRJqUbLsAj0XX1FixI9wibqdRcJXe4mw5)lvKhupucgVmwc7yajkWm2Z)f6lEAqELwzaSSR)0GL7B)fGqPvgcpElOusdwwIeqO0kdHhVfukPrHbHR)0lSqjcjsaHsRmeE8wqPKgGXdDi2HfkrCzVX8yVhfE8wh8iWaDeQqEL24jSkmvIKZdHNy8MT3bAm90tF7ThekTYq4XBbLsA6y3vIqIeImxkvpacStAqELwzaSSR)yh2E3JejEu4XBDWJad0rOc5vAJNWQWujsopeEIXB2EhOX0tcDCC9hYLyVfrbSv5FkgkcwlyeKgKxPipaVblNqhhx)HCj2BTyaHb2QJagkcwlyeKgKxPipaVblNql6CfjcNRnUk05yIKCHgMkGZJNRIKR3Xao3aW5EvUpix8hW56bqGDcg5(GCdkLKBa4bt0ZLihIhDeYf5b5I)aoxVlMCVXEtAj0XX1FixI92Ik05KkMqyQaopogkcwImxkvpacStAfvOZjvmHWubCEC7WELej2FbiuALHWJ3ckL0yrDL4ejsaHsRmeE8wqPKMo2DJ9UNe6446pKlXEBmhM4GOuprPGHIG1cgbPb5vkYdWBWYj0XX1FixI92tuk1446p1IsCmMaNXEeFsOJJR)qUe7Ta4Pghx)PwuIJXe4mw8qNe6eArNROctTXZ1)CHjCUI74j3R)FY9rY174CfvKdpuMMRsYnoUcHtOJJR)qAw)pydYHhktRwLG4yOiyjYCPu9aiWoPHRdTs4a0lS2ucDCC9hsZ6)5sS3gKdpuMwNhsGHIG1dGa7nXQ3PdMSprMlLQhab2jTGC4HY068qc7GQprMlLQhab2jnCDOvcha7G6spk84nchaDeQJk054bGB8ewfMMqNql6CT5BssOfDUIeHZftFXmixrHbbMO)KRy17YfZELI8a8wUIAFHMlYdYfZELI8a8CppotY9rqY98FH(INC1jxVJZDyrDpxOerUe(8dLK77DmqSs4CHjCU)K7HMl8uycjxVJZft5si8KCLceQNRn)4wHNRiJPQhU(tUkjxpk84mfJCFqUksUEhd4CfRLsUZ75AX5gZ7Dmixm7vAU3qaSSR)KR3PKCruHoVLqhhx)H0oucw5xmdQ6Gat0FWqrWAbJG0G8kf5b4nyzjsUG8WflDOTZJBfEfNPQhU(tJNWQW0(N)l0x80G8kTYayzx)Pby8qhIDyHsesKGOcDEfW4HoKED(VqFXtdYR0kdGLD9NgGXdDij0IoxrIW5IQfEoCU)KRnFZC9pxzWFYfLL7GX8IjsYftb)Pe4HR)0sOJJR)qAhk5sS3s0cphgdpacSxveSa4HrEGa3iSChmMxsvg8NsGhU(tJVbWQSmt7BVhab2BkPguQejEaeyVrzlyeK2jiUocnahhVNeArNRir4CVoOcCU6qukN7JKlMzJYf5b56DCUikG45ct4CFqU)KRnFZCdeNb56DCUikG45ct4wUIC17YvAvOZZ1gfCUDFHMlYdYfZSrTe6446pK2HsUe7TWeUQoJJXe4mwIoiWLQqjOA4pGuTcQaxFKkcd(J63XqrWAbJG0G8kf5b4nyzjsCfNTdkr03(lopeEIXBJk05vKG7jHw05kseoxBuW5kkcoaungsU)KRnFZCFyNOuo3hjxm7vkYdWB5kseoxBuW5kkcoaungkjxDYfZELI8a8CvKCV)W52fq4Cz17yqUIIapeoxrHbIk8GW1FY9b5AJuUqZ9rY96YtipoPLqhhx)H0ouYLyVfj4QaCaOAmemueSxybJG0G8kf5b4ny5(2FX5)c9fpniVsR(da84nyzjsUWJcpEdYR0Q)aapEJNWQW0EKiXcgbPb5vkYdWBWY9TN8WflDOnbWdHR6arfEq46pnEcRctLiH8WflDOneLl06JuTkpH84KgpHvHP9Kql6CfjcNRithQqGZKCf3XtUrPKRnL7nFPi5gaoxyzmY9b5E)HZnaCU6KlM9kf5b4TCVHdbgW5kQbpcmqhHCXSxP5QKCJJRq4C)jxVJZ1dGa75Qi56rHhNPTCr9xoxyIoc5gEU9(YC9aiWojxXQ3LlkhaDeYvAvOZXda3sOJJR)qAhk5sS3IRdviWzcgN7Ncx9aiWobluyOiy1HeJ637LnMi6BV9qcGgwfUfLsL(oPcl33(lo)xOV4Pb5vALbWYU(tdwwIKl8OWJ36GhbgOJqfYR0gpHvHP90JejwWiiniVsrEaEdwUN(2FHhfE8wh8iWaDeQqEL24jSkmvIekBbJG06GhbgOJqfYR0gSSejxybJG0G8kf5b4ny5E6B)fEu4XBeoa6iuhvOZXda34jSkmvIeImxkvpacStA46qReoa9Q39Kql6CfjcNRinDF5EUs)qIC)jxB(MyKB3xO6iKRfqzKY9C9pxXH65I8GCLFXmixDqGj6p5(GCdknxICiEiTe6446pK2HsUe7TWt3xUxNhsGHIG1E7VaekTYq4XBbLsAWY9bHsRmeE8wqPKMo2DLi6rIeqO0kdHhVfukPby8qhIDyHQ3sKacLwzi84TGsjnkmiC9NEbvV7PV9wWiin5xmdQ6Gat0FAWYsKC(VqFXtt(fZGQoiWe9NgGXdDi2HfkrirYfYaLjEJWfKQ8lMbvDqGj6p903(l8OWJ36GhbgOJqfYR0gpHvHPsKqzlyeKwh8iWaDeQqEL2GLLi5clyeKgKxPipaVbl3tcTOZvKiCU)KRnFZCTG9CLb6duxjCUWeDeYfZELM7neal76p5IOaIJrUksUWeMMRoeLY5(i5Iz2OC)jxuPYfMW5giodYnYfYRuRV45I8GCp)xOV4jxgbrpkpN75gdnxKhKBh8iWaDeYfYR0CHLDfNZvrY1JcpotBj0XX1FiTdLCj2BT(FQps174Aqo8qzkgkc2lSGrqAqELI8a8gSC)lo)xOV4Pb5vALbWYU(tdwUprMlLQhab2jnCDOvcha7GQ)fEu4XBeoa6iuhvOZXda34jSkmvIe7TGrqAqELI8a8gSCFImxkvpacStA46qReoa96Q(x4rHhVr4aOJqDuHohpaCJNWQW0(Yagsv4qBq1G8kTA9fVhjsS3cgbPb5vkYdWBWY99OWJ3iCa0rOoQqNJhaUXtyvyApj0XX1FiTdLCj2BprPuJJR)ulkXXycCgRd0Xw2jj0j0IoxBoiEUI8oTW5AZbX1ri3446pKwUOSNB452PcDmixzG(a1VNR)5s6EGN7rbhy1ZvhNbayzp3Zpu11Fi5(tUImDO5IYb4wBujUNql6CfjcNlkhaDeYvAvOZXdaNRIK79hoxXAPKBN65YZdl0LRhab2j5gdnxm9fZGCffgeyI(tUXqZfZELI8a8CdaN78EUaoO3Xi3hKR)5cyeat6YfvKlkX0C)jxx8N7dYf)bCUEaeyN0sOJJR)qAhXhSeoa6iuhvOZXdaJbmHRI70cxpbX1raluyCUFkC1dGa7eSqHHIG1EibqdRc3iCa0rOoQqNJhaUEG9hbP)fqcGgwfUj)FPI8G6Hs6rIe7PV3iDb9fxf)aAvo0Pbyeat6cRc3NiZLs1dGa7KgUo0kHdGDq1tcTOZfT7bEU2ScoWQNlkhaDeYvAvOZXdaN75hQ66p56FU2YSCUOICrjMMlSCU6KRO6VHj0XX1FiTJ4ZLyVLWbqhH6OcDoEaymGjCvCNw46jiUocyHcJZ9tHREaeyNGfkmueSEu4XBeoa6iuhvOZXda34jSkmTp99gPlOV4Q4hqRYHonaJaysxyv4(ezUuQEaeyN0W1HwjCaS7QeArN7pL71J4tU4HTmjxVJZnoU(tU)uUNlmjSkCUuyGoc5E6Iz4Ioc5gdn359CdsUrUawaUeGCJJR)0sOJJR)qAhXNlXElUo0Qvjiog)uUxpIpyHkHoHooU(dPrXfQoqhBzNGfMWv1zCmMaNXsdGT4)pvkFSTwLHDato8C4e6446pKgfxO6aDSLDYLyVfMWv1zCmMaNXsGhRY)0AGZE3DINqhhx)H0O4cvhOJTStUe7TWeUQoJJXe4mwHYD5U6JudcrX1s46pj0XX1FinkUq1b6yl7KlXElmHRQZ4ymboJLc4GIOaUcHjeUKqNql6CfzHo5kQWuBCmYL09WfAUNhcdYnkLCbXiWKCFKC9aiWoj3yO5so8ea9jj0XX1Fin8qNlXE7jkLACC9NArjogtGZyT(FWG4a94yHcdfbRfmcsZ6)P(ivVJRb5WdLPny5e6446pKgEOZLyVLQezUuXdb9Kql6CfjcNlM9kn3Biaw21FY9NCp)xOV4jx5)l6iKB45w4G45AdIixDiXO(9CTG9CN3ZvrY9(dNRyTuY9HWGtiNRoKyu)EU6KlMzJA5kYcB5CjWaoxsxqFXikp0BX1HAXdLb5QKC)j3Z)f6lEY1IrEaNlMDdBj0XX1Fin8qhSqELwzaSSR)GHIGfsa0WQWn5)lvKhupusFDiXO(D7WAdIOV96qIr979clMS3sK4rHhVr4aOJqDuHohpaCJNWQW0(qcGgwfUr4aOJqDuHohpaC9a7pcsp9V48FH(INgIYdTblNql6CfzHTCUeyaN79hoxzypxy5Crf5IsmnxrfQOctZ9NC9ooxpacSNRIKRiheEhcCjxBuWaLZvjdMONBCCfc3sOJJR)qA4HoxI9wsxqFXvXpGwLdDWqrWAbJG0qcUkahaQgdPbl3)ckBbJG0edcVdbUurcgOCdwoHooU(dPHh6Cj2BprPuJJR)ulkXXycCg7HssOfDUIAQqxUykqFG63ZvKPdnxuoa5ghx)jx)ZfWiaM0L7nFPi5kw9UCjCa0rOoQqNJhaoHooU(dPHh6Cj2BX1HwjCaW4C)u4Qhab2jyHcdfbRhfE8gHdGoc1rf6C8aWnEcRct7tK5sP6bqGDsdxhALWbWoibqdRc3W1HwjCaQhy)rq6Fb99gPlOV4Q4hqRYHonxp2QJq)lo)xOV4PHO8qBWYj0IoxmfWimix)ZfMW5EZaFcx)jxrfQOctZvrYnM75EZxQCvsUZ75cl3sOJJR)qA4HoxI9wAGpHR)GX5(PWvpacStWcfgkc2lGeanSkClkLk9DsfwoHw05kseoxm7vAUx)fp3WZTtf6yqUYa9bQFpxXQ3LROg8iWaDeYfZELMlSCU(NRnKRhab2jyK7dY99ogKRhfECsU)KlQuTe6446pKgEOZLyVfYR0Q1xCmueS6qIr979clMS399OWJ36GhbgOJqfYR0gpHvHP99OWJ3iCa0rOoQqNJhaUXtyvyAFImxkvpacStA46qReoa9clMtIe7T3JcpERdEeyGocviVsB8ewfM2)cpk84nchaDeQJk054bGB8ewfM2JejezUuQEaeyN0W1HwjCaWcvpj0Io3B(dMONlmHZ9MmKhgOJqUyAjeG5CvKCV)W5EIjxb2Zvh)ZfZELI8a8C1H4CqXi3hKRIKlkhaDeYvAvOZXdaNRsY1JcpotZngAUI1sj3o1ZLNhwOlxpacStAj0XX1Fin8qNlXElLH8WaDeQYLqaMX4C)u4Qhab2jyHcdfbR9agbWKUWQWsKOdjg1VB3n27E6B)fqcGgwfUj)FPI8G6HsKirhsmQF3oSyYE3tF7VWJcpEJWbqhH6OcDoEa4gpHvHPsKyVhfE8gHdGoc1rf6C8aWnEcRct7FbKaOHvHBeoa6iuhvOZXdaxpW(JG0tpj0IoxrIW5IzxN7p5AZ3mxfj37pCU0FWe9ChMP56FUNG45EtgYdd0rixmTecWmg5gdnxVJbCUbGZTWesUExm5Ad56bqGDsUpSNR99oxXQ3L75hkS690sOJJR)qA4HoxI9wiVsRwFXXqrWsK5sP6bqGDsdxhALWbOx2BdxE(HcREJQeYpX4v(09mPXtyvyAp91HeJ637fwmzV77rHhVr4aOJqDuHohpaCJNWQWujsUWJcpEJWbqhH6OcDoEa4gpHvHPj0IoxrIW5I2f0xCUI8hqfL5Eto8UCvKC9ooxpacSNRsYnSEypx)ZLQCUpi37pCUDbeox0UG(IrkboNlMcucEU8nawLLzAUIvVlxrMoulEOmi3hKlAxqFXikp0CJJRq4wcDCC9hsdp05sS3s6c6lUk(b0kLdVdJZ9tHREaeyNGfkmueS27bqG9whhfVRjF8EDLi6tK5sP6bqGDsdxhALWbOx2qpsKyVm7neLhAloUcH7dGhg5bcCJ0f0xmsjW5Qmqj4n(gaRYYmTNeArNRir4CrHbaEOmix)ZvKf0HjKC)j3ixpacSNR3fEUkjxHxhHC9pxQY5gEUEhNlqf68CDfNBj0XX1Fin8qNlXElbga4HYGQ)v8GomHGX5(PWvpacStWcfgkcwpacS3CfNR(xPk3RR6DFlyeKgKxPipaVrFXtcTOZvKiCUy2R0CL6baE8C)PCpxfjxurUOetZngAUyMu5gao344keo3yO56DCUEaeypxX)Gj65svoxkmqhHC9oo3txmdxAj0XX1Fin8qNlXElKxPv)baECmo3pfU6bqGDcwOWqrWcjaAyv4g9DsfwUVhab2BUIZv)RuLTZM6BbJG0G8kf5b4n6lE6hhxHWv67nibUSc0t1F4tNDyjYCPu9aiWoPbjWLvGEQ(dF66tK5sP6bqGDsdxhALWbOx237lThZH5XJcpEZfReV(ivKW5gpHvHP90tcDCC9hsdp05sS3IRd1IhkdWqrWsFVbjWLvGEQ(dF6AUESvhH(27rHhVr4aOJqDuHohpaCJNWQW0(ezUuQEaeyN0W1HwjCaSdsa0WQWnCDOvchG6b2FeejsOV3iDb9fxf)aAvo0P56XwDe6jHw05kseoxurUO8M5kw9UCX0qhlah2YGCXusuWZfEkmHKR3X56bqG9CfRLsUwCUwC5fN7vIatG5AXipGZ174Cp)xOV4j3ZJZKCTIJTj0XX1Fin8qNlXElPlOV4Q4hqRuo8omueSa4HrEGa3KdDSaCyldQYKOG34BaSklZ0(qcGgwfUrFNuHL77bqG9MR4C1)Q8XRxjc7S)8FH(INgPlOV4Q4hqRuo8UgfgeU(ZLchApj0IoxrIW5I2f0xCU2miiD5(tU28nZfEkmHKR3Xao3aW5gukjxDopUocTe6446pKgEOZLyVL0f0xC9acshgkcwqO0kdHhVfukPPJDqjIeArNRir4Cfz6qZfLdqU(N75hcmoN7ndGT5kv3dl05KCLb)HK7p5kQW8VHTCLcZ)My(5AZ)GOa8CvsUENsYvj5g52PcDmixzG(a1VNR3ftUaM(URJqU)KROcZ)gMl8uycjxAaSnxV7Hf6CsUkj3W6H9C9pxxX5CFypHooU(dPHh6Cj2BX1HwjCaW4C)u4Qhab2jyHcdfblrMlLQhab2jnCDOvcha7GeanSkCdxhALWbOEG9hbPVfmcsJgaBRE3dl05nyzmoDHoyHcdDCgaGL9QIJZunCgluyOJZaaSSxveSUESLyh2RsOfDUIeHZvKPdnxBujUNR)5E(HaJZ5EZayBUs19WcDojxzWFi5(tUOs1Yvkm)BI5NRn)dIcWZvrY17usUkj3i3ovOJb5kd0hO(9C9UyYfW03DDeYfEkmHKlna2MR39WcDojxLKBy9WEU(NRR4CUpSNqhhx)H0WdDUe7T46qRiL4ogkcwlyeKgna2w9UhwOZBWY9HeanSkCJ(oPclJXPl0bluyOJZaaSSxvCCMQHZyHcdDCgaGL9QIG11JTe7WEv)Z)f6lEAqELwT(I3GLtOfDUIeHZvKPdn3RlbXZvrY9(dNl9hmrp3HzAU(NlGramPl3B(srA5I6VCUNG46iKB45Ad5(GCXFaNRhab2j5kw9UCr5aOJqUsRcDoEa4C9OWJZ0wcDCC9hsdp05sS3IRdTAvcIJHIGfsa0WQWn67KkSCFqO0kdHhVH)qyCE8Mo2DcIxDfNVueTE33EImxkvpacStA46qReoa9Yg6FHhfE8gUsyW9gpHvHPsKqK5sP6bqGDsdxhALWbOxyU(Eu4XB4kHb3B8ewfM2tcDCC9hsdp05sS3cjWLvGEQ(dF6W4C)u4Qhab2jyHcdfblGramPlSkCFpacS3CfNR(xPkBhMtIe79OWJ3WvcdU34jSkmTp99gPlOV4Q4hqRYHonaJaysxyv4EKiXcgbPbpiWGIocvAaSDycPblNql6CrL5JgLCp)qvx)jx)ZL4VCUNG46iKlQixuIP5(tUpcIOypacStYvChp5IOcDUoc5At5(GCXFaNlXJJTmnx83IKBm0CHj6iKlMsUF60tU246yBUXqZvAmFPYvKPegCVLqhhx)H0WdDUe7TKUG(IRIFaTkh6GHIGfWiaM0fwfUVhab2BUIZv)RuLTZg6FHhfE8gUsyW9gpHvHP99OWJ3Kj3pD6Pw0X2gpHvHP9jYCPu9aiWoPHRdTs4ay3vj0IoxmbZSCUOICrjMMlSCU)KBqYfpM756bqGDsUbjx5NquRcJrUSO(HL9Cf3XtUiQqNRJqU2uUpix8hW5s84yltZf)Ti5kw9UCXuY9tNEY1gxhBBj0XX1Fin8qNlXElPlOV4Q4hqRYHoyCUFkC1dGa7eSqHHIGfWiaM0fwfUVhab2BUIZv)RuLTZg6FHhfE8gUsyW9gpHvHP9VWEpk84nchaDeQJk054bGB8ewfM2NiZLs1dGa7KgUo0kHdGDqcGgwfUHRdTs4aupW(JG0tF7VWJcpEtMC)0PNArhBB8ewfMkrI9Eu4XBYK7No9ul6yBJNWQW0(ezUuQEaeyN0W1HwjCa6f2R6PNe6446pKgEOZLyVfxhALWbaJZ9tHREaeyNGfkmueSezUuQEaeyN0W1HwjCaSdsa0WQWnCDOvchG6b2FeemoDHoyHcdDCgaGL9QIJZunCgluyOJZaaSSxveSUESLyh2RsOJJR)qA4HoxI9wCDOvKsChJtxOdwOWqhNbayzVQ44mvdNXcfg64maal7vfbRRhBj2H9Q(N)l0x80G8kTA9fVblNql6CfjcNlQixuEZCdsULG45cyYd8CvKC)jxVJZf)HWj0XX1Fin8qNlXElPlOV4Q4hqRuo8UeArNRir4Crf5Ismn3GKBjiEUaM8apxfj3FY174CXFiCUXqZfvKlkVzUkj3FY1MVzcDCC9hsdp05sS3s6c6lUk(b0QCOtcDcTOZvKiCU)KRnFZCfvOIkmnx)ZvG9CV5lvUUESvhHCJHMllQlRaox)ZTOdNlSCUwS7mixXQ3LlM9kf5b4j0XX1FinhOJTStWct4Q6mogtGZyzC57aok1hqNyomgkc2Z)f6lEAqELwzaSSR)0amEOdPxyH6kjso)xOV4Pb5vALbWYU(tdW4Hoe7U6gtOfDUO3NtUIcyc6M5kw9UCXSxPipapHooU(dP5aDSLDYLyVfMWv1zCmMaNXQd5aG9WQW1BaCmomELYq0dJHIG98FH(INgKxPvgal76pnaJh6qSdkrKql6CrVpNCr7y2ZvKbt0tUIvVlxm7vkYdWtOJJR)qAoqhBzNCj2BHjCvDghJjWzS4XjSaCL0XSxXHj6bdfb75)c9fpniVsRmaw21FAagp0HyhuIiHw05IEFo5IjayR75kw9UCX0xmdYvuyqGj6p5ctcbgJCXdB5CjWaox)ZLmQmNR3X5wEXmXZvudtZ1dGa7j0XX1FinhOJTStUe7TWeUQoJJXe4mwYdxkS76iubWw3XqrWAbJG0KFXmOQdcmr)PbllrYfYaLjEJWfKQ8lMbvDqGj6pyCUFkC1dGa7eSqLql6CfjcN71bvGZvhIs5CFKCXmBuUipixVJZfrbepxycN7dY9NCT5BMBG4mixVJZfrbepxyc3YfT7bEUhfCGvpxfjxiVsZLbWYU(tUN)l0x8KRsYfkrqY9b5I)ao3qCCVLqhhx)H0CGo2Yo5sS3ct4Q6mogtGZyj6GaxQcLGQH)as1kOcC9rQim4pQFhdfb75)c9fpniVsRmaw21FAagp0HyhwOercTOZvKiCUfL45(i5(JOyycNlnWdboxhOJTStY9NY9CvKCf1GhbgOJqUy2R0CVjBbJGKRsYnoUcHXi3hK79ho3aW5oVNRhfECMMRo(NR6Te6446pKMd0Xw2jxI92tuk1446p1IsCmMaNXsXfQoqhBzNGHIG1(l8OWJ36GhbgOJqfYR0gpHvHPsKqzlyeKwh8iWaDeQqEL2GL7PV9wWiiniVsrEaEdwwIKZ)f6lEAqELwzaSSR)0amEOdXoOerpj0Io3BYibCXZfjkfR4yBUipixysyv4CvNXjIYCfjcN7p5E(VqFXtU6K7dOmixR756aDSL9CjL3Bj0XX1FinhOJTStUe7TWeUQoJtWqrWAbJG0G8kf5b4nyzjsSGrqAYVygu1bbMO)0GLLi58FH(INgKxPvgal76pnaJh6qSdkryqjY8Xi9v9gtACJBma]] )

end
