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


    spec:RegisterPack( "Shadow", 20201217, [[davWEbqivfEeHuxsvfcTjPQ(KQkuJIsvNsQIvriu8kvfnlOOBriHAxs5xQQ0WGcDmqYYuvQNjvPAAuk4AukABec5BqbmoOaDocjL1rirZtQsUhuAFuQCqcjzHQk5HsvktuvfDrvvqBKsH8rcjKrsPq5KesWkbPEPQke1mPuO6MeIYojI(jHq1qHc6OQQqKLQQcbpfstLiCvcr2kHGVsiQ2lf)vsdwPdlSyk5XQYKr6YO2meFMGrlvonPvRQcPxtP0SL42q1Uv8BvgorDCvvGLd8CetNQRdQTdIVtOgpHKQZRQQ1tiuA(eP9lAdugjmO0WzJKFJXVXiuFdfgO9ngXigTPb1)lZgu54zBiWg0jWzdkAxqpXgu54F5cQrcdk5Gbp2G25Umru(7VcQ3bB1Eh(VefhUeUEZdei(Vef)9Rb1cwlUOWySmO0WzJKFJXVXiuFdfgObLOwV)Tnfrg0a27oGbfvX7ndANsP8ySmOuM8mOIox0UGEIZfdbkt8eArN7p5hJBXGCHcdGzUFJXVXycDcTOZvcXCyBUIWP0CL4aaE8Cf3XtUEaeyp33bpoj3aW5ICGhtBg0IsCIrcdkEOJrcJKqzKWGYtyvyQ5ld6dOod0WGAbJG0SUBQhs174AqE8qzAdw2GsCG(CJKqzqJNR3yqFrPuJNR3ulkXnOfL41jWzdQ1DJXns(TrcdA8C9gdkvjYCPIhc6ZGYtyvyQ5lJBKS3nsyq5jSkm18Lb9buNbAyqHeanSkCt(Usf5a1hLKB)C1HeJ6)Z1oS5Adym3(5AFU6qIr9)52lS5IbTzUsLMRhfE8gHdGoc1rf6C8aWnEcRctZTFUqcGgwfUr4aOJqDuHohpaC9b7hcsU9KB)C)i33Df6jEAikp0gSSbnEUEJbfYP0kdGLD9gJBK0gmsyq5jSkm18Lb9buNbAyqTGrqAibxfGdavJH0GLZTFUFKlLTGrqAIbH3HaxQibduUblBqJNR3yqjDb9exfFaAvo0X4gjTPrcdkpHvHPMVmOXZ1BmOVOuQXZ1BQfL4g0Is86e4Sb9rjg3iPiYiHbLNWQWuZxg0hqDgOHb1JcpEJWbqhH6OcDoEa4gpHvHP52pxImxkvpacStA46qReoa5AxUqcGgwfUHRdTs4auFW(HGKB)C)ix65nsxqpXvXhGwLdDAU(SvhHC7N7h5(URqpXtdr5H2GLnOXZ1BmO46qReoag03)xHREaeyNyKekJBKedyKWGYtyvyQ5ld6dOod0WG(rUqcGgwfUfLsLEoPclBqJNR3yqPb(eUEJb99)v4Qhab2jgjHY4gjXGgjmO8ewfMA(YG(aQZanmO6qIr9)52lS5IbTzU9Z1JcpERdEeyGocviNsB8ewfMMB)C9OWJ3iCa0rOoQqNJhaUXtyvyAU9ZLiZLs1dGa7KgUo0kHdqU9cBUIOCLknx7Z1(C9OWJ36GhbgOJqfYP0gpHvHP52p3pY1JcpEJWbqhH6OcDoEa4gpHvHP52tUsLMlrMlLQhab2jnCDOvchGCXMlu52JbnEUEJbfYP0Q1vCJBKuuZiHbLNWQWuZxg0hqDgOHb1(CbmcGjDHvHZvQ0C1HeJ6)Z1UCXa2m3EYTFU2N7h5cjaAyv4M8DLkYbQpkjxPsZvhsmQ)px7WMlg0M52tU9Z1(C)ixpk84nchaDeQJk054bGB8ewfMMRuP5AFUEu4XBeoa6iuhvOZXda34jSkmn3(5(rUqcGgwfUr4aOJqDuHohpaC9b7hcsU9KBpg0456ngukd5Gb6iuLlHamBqF)FfU6bqGDIrsOmUrsOWOrcdkpHvHPMVmOpG6mqddkrMlLQhab2jnCDOvchGC7vU2NRnK7N5(UHcREJQeYnX4v(1DmPXtyvyAU9KB)C1HeJ6)ZTxyZfdAZC7NRhfE8gHdGoc1rf6C8aWnEcRctZvQ0C)ixpk84nchaDeQJk054bGB8ewfMAqJNR3yqHCkTADf34gjHckJeguEcRctnFzqFa1zGggu7Z1dGa7TookExt(552RC)gJ52pxImxkvpacStA46qReoa52RCTHC7jxPsZ1(CLzVHO8qBXZviCU9ZfapmYbe4gPlONyKsGZvzGsWB8pawLLzAU9yqJNR3yqjDb9exfFaALYH3zqF)FfU6bqGDIrsOmUrsO(2iHbLNWQWuZxg0hqDgOHb1dGa7nxX5QFvQY52RC)2M52pxlyeKgKtPihaVrpXJbnEUEJbLada8qzq1VkEqhMqmOV)Vcx9aiWoXijug3iju9UrcdkpHvHPMVmOpG6mqddkKaOHvHB0Zjvy5C7NRhab2BUIZv)QuLZ1UC79C7NRfmcsdYPuKdG3ON4j3(5gpxHWv65nibUSc0x1p4xxU2HnxImxkvpacStAqcCzfOVQFWVUC7NlrMlLQhab2jnCDOvchGC7vU2NRnZ9ZCTpxruUIyY1JcpEZfReVEivKW5gpHvHP52tU9yqJNR3yqHCkT6haWJBqF)FfU6bqGDIrsOmUrsOSbJeguEcRctnFzqFa1zGggu65nibUSc0x1p4xxZ1NT6iKB)CTpxpk84nchaDeQJk054bGB8ewfMMB)CjYCPu9aiWoPHRdTs4aKRD5cjaAyv4gUo0kHdq9b7hcsUsLMl98gPlON4Q4dqRYHonxF2QJqU9yqJNR3yqX1HAXdLbg3iju20iHbLNWQWuZxg0hqDgOHbfapmYbe4MCOJfGdBzqvMef8g)dGvzzMMB)CHeanSkCJEoPclNB)C9aiWEZvCU6xv(51VXyU2LR95(URqpXtJ0f0tCv8bOvkhExJcdcxVj3pZv4rZThdA8C9gdkPlON4Q4dqRuo8oJBKekrKrcdkpHvHPMVmOpG6mqddkiuALHWJ3ckL00jx7YfkmAqJNR3yqjDb9exFGG0zCJKqHbmsyq5jSkm18LbnEUEJbfxhALWbWG(()kC1dGa7eJKqzq1Xzaaw2RkIb11NTe7W(TbvhNbayzVQ44mvdNnOqzqFDHoguOmOpG6mqddkrMlLQhab2jnCDOvchGCTlxibqdRc3W1HwjCaQpy)qqYTFUwWiinAaST6DhSqN3GLnUrsOWGgjmO8ewfMA(YGgpxVXGIRdTIuI)guDCgaGL9QIyqD9zlXoSF3)DxHEINgKtPvRR4nyzdQoodaWYEvXXzQgoBqHYG(6cDmOqzqFa1zGggulyeKgna2w9UdwOZBWY52pxibqdRc3ONtQWYg3ijuIAgjmO8ewfMA(YG(aQZanmOqcGgwfUrpNuHLZTFUGqPvgcpEd)GW484nDY1UCFbXRUIZ5(zUySzZC7NR95sK5sP6bqGDsdxhALWbi3ELRnKB)C)ixpk84nCLWG)nEcRctZvQ0CjYCPu9aiWoPHRdTs4aKBVYveLB)C9OWJ3Wvcd(34jSkmn3EmOXZ1BmO46qRwLG4g3i53y0iHbLNWQWuZxg0hqDgOHbfWiaM0fwfo3(56bqG9MR4C1Vkv5CTlxruUsLMR956rHhVHReg8VXtyvyAU9ZLEEJ0f0tCv8bOv5qNgGramPlSkCU9KRuP5AbJG0GheyqrhHkna2omH0GLnOXZ1BmOqcCzfOVQFWVod67)RWvpacStmscLXns(nugjmO8ewfMA(YG(aQZanmOagbWKUWQW52pxpacS3CfNR(vPkNRD5Ad52p3pY1JcpEdxjm4FJNWQW0C7NRhfE8Mm5)RtF1Io224jSkmn3(5sK5sP6bqGDsdxhALWbix7Y9BdA8C9gdkPlON4Q4dqRYHog3i53FBKWGYtyvyQ5ld6dOod0WGcyeat6cRcNB)C9aiWEZvCU6xLQCU2LRnKB)C)ixpk84nCLWG)nEcRctZTFUFKR956rHhVr4aOJqDuHohpaCJNWQW0C7NlrMlLQhab2jnCDOvchGCTlxibqdRc3W1HwjCaQpy)qqYTNC7NR95(rUEu4XBYK)Vo9vl6yBJNWQW0CLknx7Z1JcpEtM8)1PVArhBB8ewfMMB)CjYCPu9aiWoPHRdTs4aKBVWM7352tU9yqJNR3yqjDb9exfFaAvo0XG(()kC1dGa7eJKqzCJKF37gjmO8ewfMA(YGgpxVXGIRdTs4ayqF)FfU6bqGDIrsOmO64maal7vfXG66ZwIDy)2GQJZaaSSxvCCMQHZguOmOVUqhdkug0hqDgOHbLiZLs1dGa7KgUo0kHdqU2LlKaOHvHB46qReoa1hSFiig3i532GrcdkpHvHPMVmOXZ1BmO46qRiL4VbvhNbayzVQiguxF2sSd739F3vON4Pb5uA16kEdw2GQJZaaSSxvCCMQHZguOmOVUqhdkug3i5320iHbnEUEJbL0f0tCv8bOvkhENbLNWQWuZxg3i53IiJeg0456ngusxqpXvXhGwLdDmO8ewfMA(Y4g3GsXfQoqhBzNyKWijugjmO8ewfMA(YGoboBqPbWw87MkLF2wRYWoGjpEESbnEUEJbLgaBXVBQu(zBTkd7aM845Xg3i53gjmO8ewfMA(YGoboBqjWJv5oAnWzV7pXnOXZ1BmOe4XQChTg4S39N4g3izVBKWGYtyvyQ5ld6e4SbvO8xUREi1GquCTeUEJbnEUEJbvO8xUREi1GquCTeUEJXnsAdgjmO8ewfMA(YGoboBqPaoOikGRqycHlg0456ngukGdkIc4keMq4IXnUbLYibCXnsyKekJeg0456nguIw45XguEcRctnFzCJKFBKWGYtyvyQ5ld6dOod0WGAbJG0GCkf5a4ny5CLknxlyeKM8jMbvDqGj6nnyzdA8C9gdQ856ng3izVBKWGYtyvyQ5ld6jBqjSBqJNR3yqHeanSkSbfsuGzdk98gPlON4Q4dqRYHonxF2QJqU9ZLEEdsGlRa9v9d(11C9zRocguibOoboBqPNtQWYg3iPnyKWGYtyvyQ5ld6jBqjSBqJNR3yqHeanSkSbfsuGzdk98gPlON4Q4dqRYHonxF2QJqU9ZLEEdsGlRa9v9d(11C9zRoc52px65nkd5Gb6iuLlHam3C9zRocguibOoboBqJsPspNuHLnUrsBAKWGYtyvyQ5ld6jBqjSBqJNR3yqHeanSkSbfsuGzdkrMlLQhab2jnCDOvchGCTl3VZ9ZCTGrqAqoLICa8gSSbfsaQtGZguchaDeQJk054bGRpy)qqmUrsrKrcdkpHvHPMVmONSbLWUbnEUEJbfsa0WQWguirbMnOV7k0t80GCkTYayzxVPblNB)CTp3pYfekTYq4XBbLsAWY5kvAUGqPvgcpElOusJcdcxVj3EHnxOWyUsLMliuALHWJ3ckL0amEOdjx7WMluym3pZ1M5kIjx7Z1JcpERdEeyGocviNsB8ewfMMRuP5(oi8eJ3S9pqJj3EYTNC7NR95AFUGqPvgcpElOustNCTl3VXyUsLMlrMlLQhab2jniNsRmaw21BY1oS5AZC7jxPsZ1JcpERdEeyGocviNsB8ewfMMRuP5(oi8eJ3S9pqJj3EmOqcqDcC2GkFxPICG6JsmUrsmGrcdkpHvHPMVmOpG6mqddQfmcsdYPuKdG3GLnOXZ1BmOikGTk3rnUrsmOrcdkpHvHPMVmOpG6mqddQfmcsdYPuKdG3GLnOXZ1BmOwmGWaB1rW4gjf1msyq5jSkm18Lb9buNbAyqjYCPu9aiWoPvuHoNu)rHPc4845Ah2C)oxPsZ1(C)ixqO0kdHhVfukPXI6kXj5kvAUGqPvgcpElOustNCTlxmGnZThdA8C9gdArf6Cs9hfMkGZJBCJKqHrJeguEcRctnFzqFa1zGggulyeKgKtPihaVblBqJNR3yqJ5XeheL6lkfJBKekOmsyq5jSkm18LbnEUEJb9fLsnEUEtTOe3GwuIxNaNnOpXpJBKeQVnsyq5jSkm18LbnEUEJbfap1456n1IsCdArjEDcC2GIh6yCJBqLb87WTc3iHrsOmsyq5jSkm18Lb9buNbAyqbmEOdj3ELBVJrmAqJNR3yqLpXmOk(a0kYbC1HPSXns(TrcdkpHvHPMVmOpG6mqdd6h5AbJG0iDb9eJCa8gSSbnEUEJbL0f0tmYbWnUrYE3iHbLNWQWuZxg0hqDgOHbvhsmQ)Vrze9PEU2Llu20GgpxVXGgGxmC1paGh34gjTbJeguEcRctnFzqpzdkHDdA8C9gdkKaOHvHnOqIcmBq)2Gcja1jWzdkUo0kHdq9b7hcIXnsAtJeg0456nguibUSc0x1p4xNbLNWQWuZxg34g0hLyKWijugjmO8ewfMA(YG(aQZanmOwWiiniNsroaEdwoxPsZ9JCjhCXshA7D4wHxXzQ6HR304jSkmn3(5(URqpXtdYP0kdGLD9MgGXdDi5Ah2CHcJ5kvAUiQqNxbmEOdj3EL77Uc9epniNsRmaw21BAagp0HyqJNR3yqLpXmOQdcmrVX4gj)2iHbLNWQWuZxg0hqDgOHbfapmYbe4gHL7GfXsQYG7vc8W1BA8pawLLzQbnEUEJbLOfEESXns27gjmO8ewfMA(YGgpxVXGs0bbUufkbvd)aKQvqf46HuryW9u)Vb9buNbAyqTGrqAqoLICa8gSCUsLMRR4CU2Lluym3(5AFUFK77GWtmEBuHoVIeCU9yqNaNnOeDqGlvHsq1WpaPAfubUEivegCp1)BCJK2GrcdkpHvHPMVmOpG6mqdd6h5AbJG0GCkf5a4ny5C7NR95(rUV7k0t80GCkT6haWJ3GLZvQ0C)ixpk84niNsR(ba84nEcRctZTNCLknxlyeKgKtPihaVblNB)CTpxYbxS0H2eaheUQdev4aHR304jSkmnxPsZLCWflDOneLl06HuTkhHC4KgpHvHP52JbnEUEJbfj4QaCaOAmeJBK0MgjmO8ewfMA(YG(aQZanmO6qIr9)52RCf1WyU9Z1(CTpxibqdRc3IsPspNuHLZTFU2N7h5(URqpXtdYP0kdGLD9MgSCUsLM7h56rHhV1bpcmqhHkKtPnEcRctZTNC7jxPsZ1cgbPb5ukYbWBWY52tU9Z1(C)ixpk84To4rGb6iuHCkTXtyvyAUsLMlLTGrqADWJad0rOc5uAdwoxPsZ9JCTGrqAqoLICa8gSCU9KB)CTp3pY1JcpEJWbqhH6OcDoEa4gpHvHP5kvAUezUuQEaeyN0W1HwjCaYTx5AZC7XGgpxVXGIRdviWzIb99)v4Qhab2jgjHY4gjfrgjmO8ewfMA(YG(aQZanmO2NR95(rUGqPvgcpElOusdwo3(5ccLwzi84TGsjnDY1UC)gJ52tUsLMliuALHWJ3ckL0amEOdjx7WMlu2mxPsZfekTYq4XBbLsAuyq46n52RCHYM52tU9Z1(CTGrqAYNygu1bbMO30GLZvQ0CF3vON4PjFIzqvheyIEtdW4HoKCTdBUqHXCLkn3pYvgOmXBeUGuLpXmOQdcmrVj3EYTFU2N7h56rHhV1bpcmqhHkKtPnEcRctZvQ0CPSfmcsRdEeyGocviNsBWY5kvAUFKRfmcsdYPuKdG3GLZThdA8C9gdk80DL)15Geg3ijgWiHbLNWQWuZxg0hqDgOHb9JCTGrqAqoLICa8gSCU9Z9JCF3vON4Pb5uALbWYUEtdwo3(5sK5sP6bqGDsdxhALWbix7YfQC7N7h56rHhVr4aOJqDuHohpaCJNWQW0CLknx7Z1cgbPb5ukYbWBWY52pxImxkvpacStA46qReoa52RC)o3(5(rUEu4XBeoa6iuhvOZXda34jSkmn3(5kdyivHhTbvdYP0Q1v8C7jxPsZ1(CTGrqAqoLICa8gSCU9Z1JcpEJWbqhH6OcDoEa4gpHvHP52JbnEUEJb16UPEivVJRb5XdLPg3ijg0iHbLNWQWuZxg0456ng0xuk1456n1IsCdArjEDcC2G6aDSLDIXnUb1b6yl7eJegjHYiHbLNWQWuZxg0456ngugx(pGJs9a0jMhBqFa1zGgg03Df6jEAqoLwzaSSR30amEOdj3EHnxO(oxPsZ9DxHEINgKtPvgal76nnaJh6qY1UC)gdyqNaNnOmU8FahL6bOtmp24gj)2iHbLNWQWuZxg0456nguDipaShwfU(dGJXHXRugI(yd6dOod0WG(URqpXtdYP0kdGLD9MgGXdDi5AxUqHrd6e4SbvhYda7HvHR)a4yCy8kLHOp24gj7DJeguEcRctnFzqJNR3yqXJxyb4kPJzVIdt0Nb9buNbAyqF3vON4Pb5uALbWYUEtdW4HoKCTlxOWObDcC2GIhVWcWvshZEfhMOpJBK0gmsyq5jSkm18LbDcC2Gso4sHDxhHka26Vb99)v4Qhab2jgjHYGgpxVXGso4sHDxhHka26Vb9buNbAyqTGrqAYNygu1bbMO30GLZvQ0C)ixzGYeVr4csv(eZGQoiWe9gJBK0MgjmO8ewfMA(YGgpxVXGs0bbUufkbvd)aKQvqf46HuryW9u)Vb9buNbAyqF3vON4Pb5uALbWYUEtdW4HoKCTdBUqHrd6e4SbLOdcCPkucQg(bivRGkW1dPIWG7P(FJBKuezKWGYtyvyQ5ldA8C9gd6lkLA8C9MArjUb9buNbAyqTp3pY1JcpERdEeyGocviNsB8ewfMMRuP5szlyeKwh8iWaDeQqoL2GLZTNC7NR95AbJG0GCkf5a4ny5CLkn33Df6jEAqoLwzaSSR30amEOdjx7YfkmMBpg0Is86e4SbLIluDGo2YoX4gjXagjmO8ewfMA(YG(aQZanmOwWiiniNsroaEdwoxPsZ1cgbPjFIzqvheyIEtdwoxPsZ9DxHEINgKtPvgal76nnaJh6qY1UCHcJg0456nguycxvNXjg34guR7gJegjHYiHbLNWQWuZxg0hqDgOHbLiZLs1dGa7KgUo0kHdqU9cBU9UbnEUEJbnipEOmTAvcIBCJKFBKWGYtyvyQ5ld6dOod0WG6bqG9My170bdMB)CjYCPu9aiWoPfKhpuMwNdsKRD5cvU9ZLiZLs1dGa7KgUo0kHdqU2Llu5(zUEu4XBeoa6iuhvOZXda34jSkm1GgpxVXGgKhpuMwNdsyCJBqFIFgjmscLrcdkpHvHPMVmOWeUkUtlC9fexhbJKqzqJNR3yqjCa0rOoQqNJha2G(()kC1dGa7eJKqzqFa1zGggu7Zfsa0WQWnchaDeQJk054bGRpy)qqYTFUFKlKaOHvHBY3vQihO(OKC7jxPsZ1(CPN3iDb9exfFaAvo0Pbyeat6cRcNB)CjYCPu9aiWoPHRdTs4aKRD5cvU9yCJKFBKWGYtyvyQ5ldkmHRI70cxFbX1rWijug0456nguchaDeQJk054bGnOV)Vcx9aiWoXijug0hqDgOHb1JcpEJWbqhH6OcDoEa4gpHvHP52px65nsxqpXvXhGwLdDAagbWKUWQW52pxImxkvpacStA46qReoa5AxUFBCJK9UrcdkpHvHPMVmO3u(xFIFguOmOXZ1BmO46qRwLG4g34g3GcHbe9gJKFJXVXiuFdfgnOIdWOJaXGkkGlFaNP5IbZnEUEtUfL4KwcTbLiZpJKFBtmObvgCiAHnOIox0UGEIZfdbkt8eArN7p5hJBXGCHcdGzUFJXVXycDcTOZvcXCyBUIWP0CL4aaE8Cf3XtUEaeyp33bpoj3aW5ICGhtBj0j0Io3FOOo)GDMMRfJCao33HBfEUwSGoKwUIQ3JLDsUZnII7caocCj3456nKCVP8VLqhpxVH0Kb87WTc)tS)kFIzqv8bOvKd4QdtzmveSagp0H0REhJymHoEUEdPjd43HBf(Ny)L0f0tmYbWXurW(HfmcsJ0f0tmYbWBWYj0XZ1Binza)oCRW)e7Vb4fdx9da4XXurWQdjg1)3OmI(u3oOSzcD8C9gstgWVd3k8pX(lKaOHvHXCcCglUo0kHdq9b7hccMNmwc7ycjkWm2VtOJNR3qAYa(D4wH)j2FHe4YkqFv)GFDj0j0Ioxm8C9gscD8C9gcwIw45Xj0XZ1BiyLpxVbtfbRfmcsdYPuKdG3GLLk1cgbPjFIzqvheyIEtdwoHoEUEd5tS)cjaAyvymNaNXspNuHLX8KXsyhtirbMXspVr6c6jUk(a0QCOtZ1NT6i0NEEdsGlRa9v9d(11C9zRocj0XZ1BiFI9xibqdRcJ5e4m2OuQ0ZjvyzmpzSe2XesuGzS0ZBKUGEIRIpaTkh60C9zRoc9PN3Ge4YkqFv)GFDnxF2QJqF65nkd5Gb6iuLlHam3C9zRocj0IoxupaEUWeDeYfLdGoc5kPk054bGZn8C79pZ1dGa7KCpqU2WN5Qi5()GZnaCU6KRiCkf5a4j0XZ1BiFI9xibqdRcJ5e4mwchaDeQJk054bGRpy)qqW8KXsyhtirbMXsK5sP6bqGDsdxhALWbWUV)0cgbPb5ukYbWBWYj0Io3E7Uc9ep5IH3vYvecGgwfgZCfjctZ1VCLVRKRfJCao345kKW1rixiNsroaEl3Edga4Xl)ZfMW0C9l33no4k5kUJNC9l345kKW5CHCkf5a45kw9UC15D46iKBqPKwcD8C9gYNy)fsa0WQWyoboJv(Usf5a1hLG5jJLWoMqIcmJ9DxHEINgKtPvgal76nny5(2)biuALHWJ3ckL0GLLkfekTYq4XBbLsAuyq46n9cluyuQuqO0kdHhVfukPby8qhIDyHcJFAtrm27rHhV1bpcmqhHkKtPnEcRctLk9Dq4jgVz7FGgtp903E7bHsRmeE8wqPKMo29ngLkLiZLs1dGa7KgKtPvgal76n2H1M9ivQhfE8wh8iWaDeQqoL24jSkmvQ03bHNy8MT)bAm9KqhpxVH8j2FruaBvUJIPIG1cgbPb5ukYbWBWYj0XZ1BiFI9xlgqyGT6iGPIG1cgbPb5ukYbWBWYj0IoxrIW5AJRcD(pMKl0WubCE8CvKC9ogW5gao3VZ9a5IFaoxpacStWm3dKBqPKCdap)ypxICiE0rixKdKl(b4C9UyYfdytslHoEUEd5tS)wuHoNu)rHPc484yQiyjYCPu9aiWoPvuHoNu)rHPc4842H9BPsT)dqO0kdHhVfukPXI6kXjsLccLwzi84TGsjnDSddyZEsOJNR3q(e7VX8yIdIs9fLcMkcwlyeKgKtPihaVblNqhpxVH8j2FFrPuJNR3ulkXXCcCg7t8lHoEUEd5tS)cGNA8C9MArjoMtGZyXdDsOtOfDUIkm0gpx)YfMW5kUJNC)6Uj3djxVJZvurE8qzAUkj345keoHoEUEdPzD3GnipEOmTAvcIJPIGLiZLs1dGa7KgUo0kHdqVW27j0XZ1BinR7MpX(BqE8qzADoibMkcwpacS3eRENoyW(ezUuQEaeyN0cYJhktRZbjSdQ(ezUuQEaeyN0W1HwjCaSdQp9OWJ3iCa0rOoQqNJhaUXtyvyAcDcTOZT3(jjHw05kseoxm8eZGCffgeyIEtUIvVlxr4ukYbWB5AJDfAUihixr4ukYbWZ9D4mj3dbj33Df6jEYvNC9oo3Hf19CHcJ5s43nusUN3XaXkHZfMW5EtUpAUWtHjKC9ooxmKlHWrYvcqOEU92HBfEUImMQE46n5QKC9OWJZumZ9a5Qi56DmGZvSwk5oNNRfNBmN3XGCfHtP5(dbWYUEtUENsYfrf68wcD8C9gs7rjyLpXmOQdcmrVbtfbRfmcsdYPuKdG3GLLk9dYbxS0H2EhUv4vCMQE46nnEcRct7)URqpXtdYP0kdGLD9MgGXdDi2HfkmkvkIk05vaJh6q617Uc9epniNsRmaw21BAagp0HKql6CfjcNlQw45X5EtU92pZ1VCLb3lxuwUdwe7pMKlgcUxjWdxVPLqhpxVH0EuYNy)LOfEEmMkcwa8WihqGBewUdwelPkdUxjWdxVPX)ayvwMPj0IoxrIW5(vqf4C1HOuo3djxrWgLlYbY174CruaXZfMW5EGCVj3E7N5giodY174CruaXZfMWTCf5Q3LRKQqNNRnk4C7UcnxKdKRiyJAj0XZ1BiThL8j2FHjCvDghZjWzSeDqGlvHsq1WpaPAfubUEivegCp1)JPIG1cgbPb5ukYbWBWYsL6koBhuySV9F8oi8eJ3gvOZRib3tcTOZvKiCU2OGZvueCaOAmKCVj3E7N5EWorPCUhsUIWPuKdG3YvKiCU2OGZvueCaOAmusU6KRiCkf5a45Qi5()GZTlGW5YQ3XGCffboiCUIcdev4aHR3K7bY1gPCHM7HK7xLJqoCslHoEUEdP9OKpX(lsWvb4aq1yiyQiy)WcgbPb5ukYbWBWY9T)J3Df6jEAqoLw9da4XBWYsL(HhfE8gKtPv)aaE8gpHvHP9ivQfmcsdYPuKdG3GL7Bp5Glw6qBcGdcx1bIkCGW1BA8ewfMkvk5Glw6qBikxO1dPAvoc5WjnEcRct7jHw05kseoxrMouHaNj5kUJNCJsj3Ep3FEsqYnaCUWYyM7bY9)bNBa4C1jxr4ukYbWB5(dhcmGZ1gdEeyGoc5kcNsZvj5gpxHW5EtUEhNRhab2ZvrY1JcpotB5I6NCUWeDeYn8CT5N56bqGDsUIvVlxuoa6iKRKQqNJhaULqhpxVH0EuYNy)fxhQqGZemF)FfU6bqGDcwOWurWQdjg1)3lrnm23E7HeanSkClkLk9CsfwUV9F8URqpXtdYP0kdGLD9MgSSuPF4rHhV1bpcmqhHkKtPnEcRct7PhPsTGrqAqoLICa8gSCp9T)dpk84To4rGb6iuHCkTXtyvyQuPu2cgbP1bpcmqhHkKtPnyzPs)WcgbPb5ukYbWBWY903(p8OWJ3iCa0rOoQqNJhaUXtyvyQuPezUuQEaeyN0W1HwjCa6Ln7jHw05kseoxrA6UY)CL8Ge5EtU92pXm3URq1rixlGYiL)56xUId1Zf5a5kFIzqU6Gat0BY9a5guAUe5q8qAj0XZ1BiThL8j2FHNUR8VohKatfbR92)biuALHWJ3ckL0GL7dcLwzi84TGsjnDS7Bm2JuPGqPvgcpElOusdW4Hoe7WcLnLkfekTYq4XBbLsAuyq46n9ckB2tF7TGrqAYNygu1bbMO30GLLk9DxHEINM8jMbvDqGj6nnaJh6qSdluyuQ0pKbkt8gHliv5tmdQ6Gat0B6PV9F4rHhV1bpcmqhHkKtPnEcRctLkLYwWiiTo4rGb6iuHCkTbllv6hwWiiniNsroaEdwUNeArNRir4CVj3E7N5Ab75kd0dOUs4CHj6iKRiCkn3Fiaw21BYfrbehZCvKCHjmnxDikLZ9qYveSr5EtUOsKlmHZnqCgKBKlKtPwxXZf5a5(URqpXtUmcI(uEE)ZngAUihi3o4rGb6iKlKtP5cl7koNRIKRhfECM2sOJNR3qApk5tS)AD3upKQ3X1G84HYumveSFybJG0GCkf5a4ny5(F8URqpXtdYP0kdGLD9MgSCFImxkvpacStA46qReoa2bv)p8OWJ3iCa0rOoQqNJhaUXtyvyQuP2BbJG0GCkf5a4ny5(ezUuQEaeyN0W1HwjCa6139)WJcpEJWbqhH6OcDoEa4gpHvHP9LbmKQWJ2GQb5uA16kEpsLAVfmcsdYPuKdG3GL77rHhVr4aOJqDuHohpaCJNWQW0EsOJNR3qApk5tS)(IsPgpxVPwuIJ5e4mwhOJTStsOtOfDU9wq8Cf5DAHZT3cIRJqUXZ1BiTCrzp3WZTtf6yqUYa9aQ)px)YL0Dap3NcEWQNRoodaWYEUVBOQR3qY9MCfz6qZfLdWV2Os8pHw05kseoxuoa6iKRKQqNJhaoxfj3)hCUI1sj3o1ZLNdwOlxpacStYngAUy4jMb5kkmiWe9MCJHMRiCkf5a45gao358CbCq)JzUhix)YfWiaM0LlQixuIH5EtUU4l3dKl(b4C9aiWoPLqhpxVH0EIFyjCa0rOoQqNJhagtycxf3PfU(cIRJawOW89)v4Qhab2jyHctfbR9qcGgwfUr4aOJqDuHohpaC9b7hcs)pGeanSkCt(Usf5a1hL0JuP2tpVr6c6jUk(a0QCOtdWiaM0fwfUprMlLQhab2jnCDOvcha7GQNeArNlA3b8C7nf8Gvpxuoa6iKRKQqNJhao33nu11BY1VCTLz5Crf5Ismmxy5C1jxr19dtOJNR3qApXVpX(lHdGoc1rf6C8aWyct4Q4oTW1xqCDeWcfMV)Vcx9aiWobluyQiy9OWJ3iCa0rOoQqNJhaUXtyvyAF65nsxqpXvXhGwLdDAagbWKUWQW9jYCPu9aiWoPHRdTs4ay33j0Io3Bk)RpXVCXdBzsUEhNB8C9MCVP8pxysyv4CPWaDeY91fZWfDeYngAUZ55gKCJCbSaCja5gpxVPLqhpxVH0EIFFI9xCDOvRsqCmVP8V(e)WcvcDcD8C9gsJIluDGo2YoblmHRQZ4yoboJLgaBXVBQu(zBTkd7aM845Xj0XZ1BinkUq1b6yl7KpX(lmHRQZ4yoboJLapwL7O1aN9U)epHoEUEdPrXfQoqhBzN8j2FHjCvDghZjWzScL)YD1dPgeIIRLW1BsOJNR3qAuCHQd0Xw2jFI9xycxvNXXCcCglfWbfrbCfctiCjHoHw05kYcDYvuHH24yMlP7Gl0CFhegKBuk5cIrGj5Ei56bqGDsUXqZL84ja6rsOJNR3qA4HoFI93xuk1456n1IsCmNaNXAD3GjXb6ZXcfMkcwlyeKM1Dt9qQEhxdYJhktBWYj0XZ1Bin8qNpX(lvjYCPIhc6lHw05kseoxr4uAU)qaSSR3K7n5(URqpXtUY3v0ri3WZTWbXZ1gWyU6qIr9)5Ab75oNNRIK7)doxXAPK7bHbVqoxDiXO()C1jxrWg1YvKf2Y5sGbCUKUGEIruEO)IRd1IhkdYvj5EtUV7k0t8KRfJCaoxr4h2sOJNR3qA4HoyHCkTYayzxVbtfblKaOHvHBY3vQihO(OK(6qIr9)2H1gWyF71HeJ6)7fwmOnLk1JcpEJWbqhH6OcDoEa4gpHvHP9HeanSkCJWbqhH6OcDoEa46d2peKE6)X7Uc9epneLhAdwoHw05kYcB5CjWao3)hCUYWEUWY5IkYfLyyUIkurfgM7n56DCUEaeypxfjxroi8oe4sU2OGbkNRsMFSNB8Cfc3sOJNR3qA4HoFI9xsxqpXvXhGwLdDWurWAbJG0qcUkahaQgdPbl3)dkBbJG0edcVdbUurcgOCdwoHoEUEdPHh68j2FFrPuJNR3ulkXXCcCg7JssOfDU2yQqxUyiqpG6)ZvKPdnxuoa5gpxVjx)YfWiaM0L7ppji5kw9UCjCa0rOoQqNJhaoHoEUEdPHh68j2FX1HwjCaW89)v4Qhab2jyHctfbRhfE8gHdGoc1rf6C8aWnEcRct7tK5sP6bqGDsdxhALWbWoibqdRc3W1HwjCaQpy)qq6)b98gPlON4Q4dqRYHonxF2QJq)pE3vON4PHO8qBWYj0IoxmeWimix)YfMW5(ZaFcxVjxrfQOcdZvrYnM)5(ZtICvsUZ55cl3sOJNR3qA4HoFI9xAGpHR3G57)RWvpacStWcfMkc2pGeanSkClkLk9CsfwoHw05kseoxr4uAUFDfp3WZTtf6yqUYa9aQ)pxXQ3LRng8iWaDeYveoLMlSCU(LRnKRhab2jyM7bY98ogKRhfECsU3KlQeTe6456nKgEOZNy)fYP0Q1vCmveS6qIr9)9clg0M99OWJ36GhbgOJqfYP0gpHvHP99OWJ3iCa0rOoQqNJhaUXtyvyAFImxkvpacStA46qReoa9cRisQu7T3JcpERdEeyGocviNsB8ewfM2)dpk84nchaDeQJk054bGB8ewfM2JuPezUuQEaeyN0W1HwjCaWcvpj0Io3FEZp2ZfMW5(tgYbd0rixmSecWCUksU)p4CFXKRa75QJF5kcNsroaEU6qCoOyM7bYvrYfLdGoc5kPk054bGZvj56rHhNP5gdnxXAPKBN65YZbl0LRhab2jTe6456nKgEOZNy)LYqoyGocv5siaZy(()kC1dGa7eSqHPIG1EaJaysxyvyPs1HeJ6)TddyZE6B)hqcGgwfUjFxPICG6JsKkvhsmQ)3oSyqB2tF7)WJcpEJWbqhH6OcDoEa4gpHvHPsLAVhfE8gHdGoc1rf6C8aWnEcRct7)bKaOHvHBeoa6iuhvOZXdaxFW(HG0tpj0IoxrIW5kcFL7n52B)mxfj3)hCU0B(XEUdZ0C9l3xq8C)jd5Gb6iKlgwcbygZCJHMR3Xao3aW5wycjxVlMCTHC9aiWoj3d2Z1EBMRy17Y9Ddfw9EAj0XZ1Bin8qNpX(lKtPvRR4yQiyjYCPu9aiWoPHRdTs4a0l7THpF3qHvVrvc5My8k)6oM04jSkmTN(6qIr9)9clg0M99OWJ3iCa0rOoQqNJhaUXtyvyQuPF4rHhVr4aOJqDuHohpaCJNWQW0eArNRir4Cr7c6joxr(bOIYC)jhExUksUEhNRhab2Zvj5gwhSNRF5svo3dK7)do3UacNlAxqpXiLaNZfdbkbpx(haRYYmnxXQ3LRithQfpugK7bYfTlONyeLhAUXZviClHoEUEdPHh68j2FjDb9exfFaALYH3H57)RWvpacStWcfMkcw79aiWERJJI31KFEV(gJ9jYCPu9aiWoPHRdTs4a0lBOhPsTxM9gIYdTfpxHW9bWdJCabUr6c6jgPe4CvgOe8g)dGvzzM2tcTOZvKiCUOWaapugKRF5kYc6WesU3KBKRhab2Z17cpxLKRWPJqU(Llv5CdpxVJZfOcDEUUIZTe6456nKgEOZNy)Lada8qzq1VkEqhMqW89)v4Qhab2jyHctfbRhab2BUIZv)QuL7132SVfmcsdYPuKdG3ON4jHw05kseoxr4uAUsCaapEU3u(NRIKlQixuIH5gdnxrqICdaNB8CfcNBm0C9ooxpacSNR4B(XEUuLZLcd0rixVJZ91fZWLwcD8C9gsdp05tS)c5uA1paGhhZ3)xHREaeyNGfkmveSqcGgwfUrpNuHL77bqG9MR4C1Vkvz769(wWiiniNsroaEJEIN(XZviCLEEdsGlRa9v9d(1zhwImxkvpacStAqcCzfOVQFWVU(ezUuQEaeyN0W1HwjCa6L928t7frIy8OWJ3CXkXRhsfjCUXtyvyAp9KqhpxVH0WdD(e7V46qT4HYamveS0ZBqcCzfOVQFWVUMRpB1rOV9Eu4XBeoa6iuhvOZXda34jSkmTprMlLQhab2jnCDOvcha7GeanSkCdxhALWbO(G9dbrQu65nsxqpXvXhGwLdDAU(SvhHEsOfDUIeHZfvKlk)zUIvVlxmm0XcWHTmixmKef8CHNcti56DCUEaeypxXAPKRfNRfxoX5(ng)rmxlg5aCUEhN77Uc9ep5(oCMKRv8SnHoEUEdPHh68j2FjDb9exfFaALYH3HPIGfapmYbe4MCOJfGdBzqvMef8g)dGvzzM2hsa0WQWn65KkSCFpacS3CfNR(vLFE9BmAN9V7k0t80iDb9exfFaALYH31OWGW1B(u4r7jHw05kseox0UGEIZT3abPl3BYT3(zUWtHjKC9ogW5gao3Gsj5QZ7W1rOLqhpxVH0WdD(e7VKUGEIRpqq6WurWccLwzi84TGsjnDSdkmMql6CfjcNRithAUOCaY1VCF3qGX5C)zaSnxj6oyHoNKRm4EKCVjxrLi(pSLReI4)uep3E7gefGNRsY17usUkj3i3ovOJb5kd0dO()C9UyYfW0ZDDeY9MCfvI4)WCHNcti5sdGT56DhSqNtYvj5gwhSNRF56koN7b7j0XZ1Bin8qNpX(lUo0kHdaMV)Vcx9aiWobluyQiyjYCPu9aiWoPHRdTs4ayhKaOHvHB46qReoa1hSFii9TGrqA0ayB17oyHoVblJ5Rl0bluyQJZaaSSxvCCMQHZyHctDCgaGL9QIG11NTe7W(DcTOZvKiCUImDO5AJkX)C9l33neyCo3FgaBZvIUdwOZj5kdUhj3BYfvIwUsiI)tr8C7TBquaEUksUENsYvj5g52PcDmixzGEa1)NR3ftUaMEURJqUWtHjKCPbW2C9UdwOZj5QKCdRd2Z1VCDfNZ9G9e6456nKgEOZNy)fxhAfPe)XurWAbJG0ObW2Q3DWcDEdwUpKaOHvHB0ZjvyzmFDHoyHctDCgaGL9QIJZunCgluyQJZaaSSxveSU(SLyh2V7)URqpXtdYP0Q1v8gSCcTOZvKiCUImDO5(vjiEUksU)p4CP38J9ChMP56xUagbWKUC)5jbPLlQFY5(cIRJqUHNRnK7bYf)aCUEaeyNKRy17YfLdGoc5kPk054bGZ1JcpotBj0XZ1Bin8qNpX(lUo0QvjioMkcwibqdRc3ONtQWY9bHsRmeE8g(bHX5XB6y3liE1vC(tm2SzF7jYCPu9aiWoPHRdTs4a0lBO)hEu4XB4kHb)B8ewfMkvkrMlLQhab2jnCDOvchGEjI67rHhVHReg8VXtyvyApj0XZ1Bin8qNpX(lKaxwb6R6h8RdZ3)xHREaeyNGfkmveSagbWKUWQW99aiWEZvCU6xLQSDIiPsT3JcpEdxjm4FJNWQW0(0ZBKUGEIRIpaTkh60amcGjDHvH7rQulyeKg8Gadk6iuPbW2HjKgSCcTOZfvMFAuY9DdvD9MC9lxIFY5(cIRJqUOICrjgM7n5EiiII9aiWojxXD8KlIk056iKBVN7bYf)aCUepE2Y0CXplsUXqZfMOJqUyi5)RtF5AJRJT5gdnxjfXLixrMsyW)wcD8C9gsdp05tS)s6c6jUk(a0QCOdMkcwaJaysxyv4(EaeyV5kox9Rsv2oBO)hEu4XB4kHb)B8ewfM23JcpEtM8)1PVArhBB8ewfM2NiZLs1dGa7KgUo0kHdGDFNql6C)rMz5Crf5Ismmxy5CVj3GKlEm)Z1dGa7KCdsUYhHOwfgZCzr9hl75kUJNCruHoxhHC79CpqU4hGZL4XZwMMl(zrYvS6D5IHK)Vo9LRnUo22sOJNR3qA4HoFI9xsxqpXvXhGwLdDW89)v4Qhab2jyHctfblGramPlSkCFpacS3CfNR(vPkBNn0)dpk84nCLWG)nEcRct7)H9Eu4XBeoa6iuhvOZXda34jSkmTprMlLQhab2jnCDOvcha7GeanSkCdxhALWbO(G9dbPN(2)HhfE8Mm5)RtF1Io224jSkmvQu79OWJ3Kj)FD6Rw0X2gpHvHP9jYCPu9aiWoPHRdTs4a0lSF3tpj0XZ1Bin8qNpX(lUo0kHdaMV)Vcx9aiWobluyQiyjYCPu9aiWoPHRdTs4ayhKaOHvHB46qReoa1hSFiiy(6cDWcfM64maal7vfhNPA4mwOWuhNbayzVQiyD9zlXoSFNqhpxVH0WdD(e7V46qRiL4pMVUqhSqHPoodaWYEvXXzQgoJfkm1Xzaaw2RkcwxF2sSd739F3vON4Pb5uA16kEdwoHw05kseoxurUO8N5gKClbXZfWKd45Qi5EtUEhNl(bHtOJNR3qA4HoFI9xsxqpXvXhGwPC4Dj0IoxrIW5IkYfLyyUbj3sq8Cbm5aEUksU3KR3X5IFq4CJHMlQixu(ZCvsU3KBV9Ze6456nKgEOZNy)L0f0tCv8bOv5qNe6eArNRir4CVj3E7N5kQqfvyyU(LRa75(ZtICD9zRoc5gdnxwuxwbCU(LBrhoxy5CTy3zqUIvVlxr4ukYbWtOJNR3qAoqhBzNGfMWv1zCmNaNXY4Y)bCuQhGoX8ymveSV7k0t80GCkTYayzxVPby8qhsVWc13sL(URqpXtdYP0kdGLD9MgGXdDi29ngiHw05I(FE5kk8J0pZvS6D5kcNsroaEcD8C9gsZb6yl7KpX(lmHRQZ4yoboJvhYda7HvHR)a4yCy8kLHOpgtfb77Uc9epniNsRmaw21BAagp0HyhuymHw05I(FE5I2XSNRidMOVCfRExUIWPuKdGNqhpxVH0CGo2Yo5tS)ct4Q6moMtGZyXJxyb4kPJzVIdt0hMkc23Df6jEAqoLwzaSSR30amEOdXoOWycTOZf9)8Y9hbyR)5kw9UCXWtmdYvuyqGj6n5ctcbgZCXdB5CjWaox)YLmQmNR3X5woXmXZ1gddZ1dGa7j0XZ1BinhOJTSt(e7VWeUQoJJ5e4mwYbxkS76iubWw)XurWAbJG0KpXmOQdcmrVPbllv6hYaLjEJWfKQ8jMbvDqGj6ny(()kC1dGa7eSqLql6CfjcN7xbvGZvhIs5CpKCfbBuUihixVJZfrbepxycN7bY9MC7TFMBG4mixVJZfrbepxyc3YfT7aEUpf8GvpxfjxiNsZLbWYUEtUV7k0t8KRsYfkmsY9a5IFao3qC8VLqhpxVH0CGo2Yo5tS)ct4Q6moMtGZyj6GaxQcLGQHFas1kOcC9qQim4EQ)htfb77Uc9epniNsRmaw21BAagp0HyhwOWycTOZvKiCUfL45Ei5EJOyycNlnWdboxhOJTStY9MY)CvKCTXGhbgOJqUIWP0C)jBbJGKRsYnEUcHXm3dK7)do3aW5oNNRhfECMMRo(LR6Te6456nKMd0Xw2jFI93xuk1456n1IsCmNaNXsXfQoqhBzNGPIG1(p8OWJ36GhbgOJqfYP0gpHvHPsLszlyeKwh8iWaDeQqoL2GL7PV9wWiiniNsroaEdwwQ03Df6jEAqoLwzaSSR30amEOdXoOWypj0Io3FYibCXZfjkfR4zBUihixysyv4CvNXjIYCfjcN7n5(URqpXtU6K7bOmixR)56aDSL9CjLZBj0XZ1BinhOJTSt(e7VWeUQoJtWurWAbJG0GCkf5a4nyzPsTGrqAYNygu1bbMO30GLLk9DxHEINgKtPvgal76nnaJh6qSdkmACJBma]] )

end
