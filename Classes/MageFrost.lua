-- MageFrost.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 64, true )

    -- spec:RegisterResource( Enum.PowerType.ArcaneCharges )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        bone_chilling = 22457, -- 205027
        lonely_winter = 22460, -- 205024
        ice_nova = 22463, -- 157997

        glacial_insulation = 22442, -- 235297
        shimmer = 22443, -- 212653
        ice_floes = 23073, -- 108839

        incanters_flow = 22444, -- 1463
        mirror_image = 22445, -- 55342
        rune_of_power = 22447, -- 116011

        frozen_touch = 22452, -- 205030
        chain_reaction = 22466, -- 278309
        ebonbolt = 22469, -- 257537

        frigid_winds = 22446, -- 235224
        ice_ward = 22448, -- 205036
        ring_of_frost = 22471, -- 113724

        freezing_rain = 22454, -- 270233
        splitting_ice = 23176, -- 56377
        comet_storm = 22473, -- 153595

        thermal_void = 21632, -- 155149
        ray_of_frost = 22309, -- 205021
        glacial_spike = 21634, -- 199786
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3584, -- 214027
        relentless = 3585, -- 196029
        gladiators_medallion = 3586, -- 208683

        deep_shatter = 68, -- 198123
        frostbite = 67, -- 198120
        chilled_to_the_bone = 66, -- 198126
        kleptomania = 58, -- 198100
        dampened_magic = 57, -- 236788
        prismatic_cloak = 3532, -- 198064
        temporal_shield = 3516, -- 198111
        ice_form = 634, -- 198144
        burst_of_cold = 633, -- 206431
        netherwind_armor = 3443, -- 198062
        concentrated_coolness = 632, -- 198148
    } )

    -- Auras
    spec:RegisterAuras( {
        active_blizzard = {
            duration = function () return 8 * haste end,
            max_stack = 1,
            generate = function( t )
                if query_time - action.blizzard.lastCast < 8 * haste then
                    t.count = 1
                    t.applied = action.blizzard.lastCast
                    t.expires = t.applied + ( 8 * haste )
                    t.caster = "player"
                    return
                end

                t.count = 0
                t.applied = 0
                t.expires = 0
                t.caster = "nobody"
            end,
        },
        arcane_intellect = {
            id = 1459,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
            shared = "player", -- use anyone's buff on the player, not just player's.
        },
        blink = {
            id = 1953,
        },
        blizzard = {
            id = 12486,
            duration = 3,
            max_stack = 1,
        },
        bone_chilling = {
            id = 205766,
            duration = 8,
            max_stack = 10,
        },
        brain_freeze = {
            id = 190446,
            duration = 15,
            max_stack = 1,
        },
        chain_reaction = {
            id = 278310,
            duration = 10,
            max_stack = 1,
        },
        chilled = {
            id = 205708,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        cone_of_cold = {
            id = 212792,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },
        fingers_of_frost = {
            id = 44544,
            duration = 15,
            max_stack = 2,
        },
        flurry = {
            id = 228354,
            duration = 1,
            type = "Magic",
            max_stack = 1,
        },
        freezing_rain = {
            id = 270232,
            duration = 12,
            max_stack = 1,
        },
        frost_nova = {
            id = 122,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        frostbolt = {
            id = 59638,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        frozen_orb = {
            duration = 10,
            max_stack = 1,
            generate = function ()
                local fo = buff.frozen_orb

                if query_time - action.frozen_orb.lastCast < 10 then
                    fo.count = 1
                    fo.applied = action.frozen_orb.lastCast
                    fo.expires = fo.applied + 10
                    fo.caster = "player"
                    return
                end

                fo.count = 0
                fo.applied = 0
                fo.expires = 0
                fo.caster = "nobody"
            end,
        },
        frozen_orb_snare = {
            id = 289308,
            duration = 3,
            max_stack = 1,
        },
        glacial_spike = {
            id = 228600,
            duration = 4,
            max_stack = 1,
        },
        hypothermia = {
            id = 41425,
            duration = 30,
            max_stack = 1,
        },
        ice_barrier = {
            id = 11426,
            duration = 60,
            type = "Magic",
            max_stack = 1,
        },
        ice_block = {
            id = 45438,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        ice_floes = {
            id = 108839,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        ice_nova = {
            id = 157997,
            duration = 2,
            type = "Magic",
            max_stack = 1,
        },
        icicles = {
            id = 205473,
            duration = 61,
            max_stack = 5,
        },
        icy_veins = {
            id = 12472,
            duration = function () return talent.thermal_void.enabled and 30 or 20 end,
            type = "Magic",
            max_stack = 1,
        },
        incanters_flow = {
            id = 116267,
            duration = 3600,
            max_stack = 5,
            meta = {
            }
        },
        preinvisibility = {
            id = 66,
            duration = 3,
            max_stack = 1,
        },
        invisibility = {
            id = 32612,
            duration = 20,
            max_stack = 1
        },
        mirror_image = {
            id = 55342,
            duration = 40,
            max_stack = 3,
            generate = function ()
                local mi = buff.mirror_image

                if action.mirror_image.lastCast > 0 and query_time < action.mirror_image.lastCast + 40 then
                    mi.count = 1
                    mi.applied = action.mirror_image.lastCast
                    mi.expires = mi.applied + 40
                    mi.caster = "player"
                    return
                end

                mi.count = 0
                mi.applied = 0
                mi.expires = 0
                mi.caster = "nobody"
            end,
        },
        polymorph = {
            id = 118,
            duration = 60,
            max_stack = 1
        },
        ray_of_frost = {
            id = 205021,
            duration = 5,
            max_stack = 1,
        },
        rune_of_power = {
            id = 116014,
            duration = 3600,
            max_stack = 1,
        },
        shatter = {
            id = 12982,
        },
        shimmer = {
            id = 212653,
        },
        slow_fall = {
            id = 130,
            duration = 30,
            max_stack = 1,
        },
        temporal_displacement = {
            id = 80354,
            duration = 600,
            max_stack = 1,
        },
        time_warp = {
            id = 80353,
            duration = 40,
            type = "Magic",
            max_stack = 1,
        },
        winters_chill = {
            id = 228358,
            duration = 1,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers (overrides)
        frigid_grasp = {
            id = 279684,
            duration = 20,
            max_stack = 1,
        },
        overwhelming_power = {
            id = 266180,
            duration = 25,
            max_stack = 25,
        },
        tunnel_of_ice = {
            id = 277904,
            duration = 300,
            max_stack = 3
        },
    } )


    spec:RegisterStateExpr( "fingers_of_frost_active", function ()
        return false
    end )

    spec:RegisterStateFunction( "fingers_of_frost", function( active )
        fingers_of_frost_active = active
    end )


    spec:RegisterStateTable( "ground_aoe", {
        frozen_orb = setmetatable( {}, {
            __index = setfenv( function( t, k )
                if k == "remains" then
                    return buff.frozen_orb.remains
                end
            end, state )
        } ),

        blizzard = setmetatable( {}, {
            __index = setfenv( function( t, k )
                if k == "remains" then return buff.active_blizzard.remains end
            end, state )
        } )
    } )


    spec:RegisterStateTable( "incanters_flow", {
        changed = 0,
        count = 0,
        direction = 0,
    } )


    local FindUnitBuffByID = ns.FindUnitBuffByID


    spec:RegisterEvent( "UNIT_AURA", function( event, unit )
        if UnitIsUnit( unit, "player" ) and state.talent.incanters_flow.enabled then
            -- Check to see if IF changed.
            local name, _, count = FindUnitBuffByID( "player", 116267, "PLAYER" )

            if name and count ~= state.incanters_flow.count and state.combat > 0 then
                if count == 1 then
                    if state.incanters_flow.direction == -1 then
                        state.incanters_flow.direction = 0
                    elseif state.incanters_flow.direction == 0 then
                        state.incanters_flow.direction = 1
                    end
                elseif count == 5 then
                    if state.incanters_flow.direction == 1 then
                        state.incanters_flow.direction = 0
                    elseif state.incanters_flow.direction == 0 then
                        state.incanters_flow.direction = -1
                    end
                end

                state.incanters_flow.count = count
                state.incanters_flow.changed = GetTime()
            end
        end
    end )


    spec:RegisterStateTable( "frost_info", {
        last_target_actual = "nobody",
        last_target_virtual = "nobody",
        watching = true,

        real_brain_freeze = false,
        virtual_brain_freeze = false
    } )

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 116 then
                frost_info.last_target_actual = destGUID
            end

            if spellID == 44614 then
                frost_info.real_brain_freeze = FindUnitBuffByID( "player", 190446 ) ~= nil
            end
        end
    end )

    spec:RegisterStateExpr( "brain_freeze_active", function ()
        return frost_info.virtual_brain_freeze
    end )


    spec:RegisterTotem( "rune_of_power", 609815 )

    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        frost_info.last_target_virtual = frost_info.last_target_actual
        frost_info.virtual_brain_freeze = frost_info.real_brain_freeze
    end )


    -- Abilities
    spec:RegisterAbilities( {
        arcane_intellect = {
            id = 1459,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            nobuff = "arcane_intellect",
            essential = true,

            startsCombat = false,
            texture = 135932,

            handler = function ()
                applyBuff( "arcane_intellect" )
            end,
        },


        blink = {
            id = function () return talent.shimmer.enabled and 212653 or 1953 end,
            cast = 0,
            charges = function () return talent.shimmer.enabled and 2 or 1 end,
            cooldown = function () return talent.shimmer.enabled and 20 or 15 end,
            recharge = function () return talent.shimmer.enabled and 20 or 15 end,
            gcd = "off",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = function () return talent.shimmer.enabled and 135739 or 135736 end,

            handler = function ()
                if talent.displacement.enabled then applyBuff( "displacement_beacon" ) end
            end,

            copy = { 212653, 1953, "shimmer" }
        },


        blizzard = {
            id = 190356,
            cast = function () return buff.freezing_rain.up and 0 or 2 * haste end,
            cooldown = 8,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135857,

            velocity = 20,

            handler = function ()
                applyDebuff( "target", "blizzard" )
                applyBuff( "active_blizzard" )
            end,
        },


        cold_snap = {
            id = 235219,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135865,

            handler = function ()
                setCooldown( "ice_barrier", 0 )
                setCooldown( "frost_nova", 0 )
                setCooldown( "cone_of_cold", 0 )
                setCooldown( "ice_block", 0 )
            end,
        },


        comet_storm = {
            id = 153595,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 2126034,

            talent = "comet_storm",

            handler = function ()
            end,
        },


        cone_of_cold = {
            id = 120,
            cast = 0,
            cooldown = 12,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 135852,

            usable = function ()
                return target.distance <= 12
            end,
            handler = function ()
                applyDebuff( "target", "cone_of_cold" )
                active_dot.cone_of_cold = max( active_enemies, active_dot.cone_of_cold )
            end,
        },


        --[[ conjure_refreshment = {
            id = 190336,
            cast = 3,
            cooldown = 15,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = false,
            texture = 134029,

            handler = function ()
            end,
        }, ]]


        counterspell = {
            id = 2139,
            cast = 0,
            cooldown = 24,
            gcd = "off",

            interrupt = true,
            toggle = "interrupts",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135856,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        ebonbolt = {
            id = 257537,
            cast = 2.5,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 1392551,

            handler = function ()
                applyBuff( "brain_freeze" )
            end,
        },


        flurry = {
            id = 44614,
            cast = function ()
                if buff.brain_freeze.up then return 0 end
                return 3 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 1506795,

            handler = function ()
                if buff.brain_freeze.up then
                    applyDebuff( "target", "winters_chill" )
                    removeBuff( "brain_freeze" )
                    frost_info.virtual_brain_freeze = true
                else
                    frost_info.virtual_brain_freeze = false
                end

                applyDebuff( "target", "flurry" )
                addStack( "icicles", nil, 1 )

                if talent.bone_chilling.enabled then addStack( "bone_chilling", nil, 1 ) end
                removeBuff( "ice_floes" )
            end,
        },


        frost_nova = {
            id = 122,
            cast = 0,
            charges = function () return talent.ice_ward.enabled and 2 or nil end,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135848,

            handler = function ()
                applyDebuff( "target", "frost_nova" )
            end,
        },


        frostbolt = {
            id = 116,
            cast = 2,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135846,

            handler = function ()
                addStack( "icicles", nil, 1 )

                applyDebuff( "target", "chilled" )
                if talent.bone_chilling.enabled then addStack( "bone_chilling", nil, 1 ) end

                removeBuff( "ice_floes" )

                if azerite.tunnel_of_ice.enabled then
                    if frost_info.last_target_virtual == target.unit then
                        addStack( "tunnel_of_ice", nil, 1 )
                    else
                        removeBuff( "tunnel_of_ice" )
                    end
                    frost_info.last_target_virtual = target.unit
                end
            end,
        },


        frozen_orb = {
            id = 84714,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 629077,

            handler = function ()
                addStack( "fingers_of_frost", nil, 1 )
                if talent.freezing_rain.enabled then applyBuff( "freezing_rain" ) end
                applyBuff( "frozen_orb" )
                applyDebuff( "target", "frozen_orb_snare" )
            end,
        },


        glacial_spike = {
            id = 199786,
            cast = 3,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 1698699,

            talent = "glacial_spike",

            usable = function () return buff.icicles.stack >= 5 end,
            handler = function ()
                removeBuff( "icicles" )
                applyDebuff( "target", "glacial_spike" )
            end,
        },


        ice_barrier = {
            id = 11426,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            defensive = true,

            spend = 0.03,
            spendType = "mana",

            startsCombat = false,
            texture = 135988,

            handler = function ()
                applyBuff( "ice_barrier" )
            end,
        },


        ice_block = {
            id = 45438,
            cast = 0,
            cooldown = 240,
            gcd = "spell",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 135841,

            handler = function ()
                applyBuff( "ice_block" )
                applyDebuff( "player", "hypothermia" )
            end,
        },


        ice_floes = {
            id = 108839,
            cast = 0,
            charges = 3,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            startsCombat = false,
            texture = 610877,

            talent = "ice_floes",

            handler = function ()
                applyBuff( "ice_floes" )
            end,
        },


        ice_lance = {
            id = 30455,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 135844,

            velocity = 47,

            handler = function ()
                if not talent.glacial_spike.enabled then removeStack( "icicles" ) end
                removeStack( "fingers_of_frost" )

                if talent.chain_reaction.enabled then
                    addStack( "chain_reaction", nil, 1 )
                end

                applyDebuff( "target", "chilled" )
                if talent.bone_chilling.enabled then addStack( "bone_chilling", nil, 1 ) end

                if azerite.whiteout.enabled then
                    cooldown.frozen_orb.expires = max( 0, cooldown.frozen_orb.expires - 0.5 )
                end 
            end,
        },


        ice_nova = {
            id = 157997,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 1033909,

            talent = "ice_nova",

            handler = function ()
                applyDebuff( "target", "ice_nova" )
            end,
        },


        icy_veins = {
            id = 12472,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135838,

            handler = function ()
                applyBuff( "icy_veins" )
                stat.haste = stat.haste + 0.30

                if azerite.frigid_grasp.enabled then
                    applyBuff( "frigid_grasp", 10 )
                    addStack( "fingers_of_frost", nil, 1 )
                end
            end,
        },


        invisibility = {
            id = 66,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 132220,

            handler = function ()
                applyBuff( "preinvisibility" )
                applyBuff( "invisibility", 23 )
            end,
        },


        mirror_image = {
            id = 55342,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135994,

            talent = "mirror_image",

            handler = function ()
                applyBuff( "mirror_image" )
            end,
        },


        polymorph = {
            id = 118,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = false,
            texture = 136071,

            handler = function ()
                applyDebuff( "target", "polymorph" )
            end,
        },


        ray_of_frost = {
            id = 205021,
            cast = 5,
            cooldown = 75,
            gcd = "spell",

            channeled = true,

            spend = 0.02,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1698700,

            talent = "ray_of_frost",

            handler = function ()
                applyDebuff( "target", "ray_of_frost" )
            end,
        },


        remove_curse = {
            id = 475,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136082,

            handler = function ()
            end,
        },


        ring_of_frost = {
            id = 113724,
            cast = 2,
            cooldown = 45,
            gcd = "spell",

            spend = 0.08,
            spendType = "mana",

            startsCombat = true,
            texture = 464484,

            talent = "ring_of_frost",

            handler = function ()                
            end,
        },


        rune_of_power = {
            id = 116011,
            cast = 1.5,
            charges = 2,
            cooldown = 40,
            recharge = 40,
            gcd = "spell",

            startsCombat = false,
            texture = 609815,

            nobuff = "rune_of_power",
            talent = "rune_of_power",

            handler = function ()
                applyBuff( "rune_of_power" )
            end,
        },


        slow_fall = {
            id = 130,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = false,
            texture = 135992,

            handler = function ()
                applyBuff( "slow_fall" )
            end,
        },


        spellsteal = {
            id = 30449,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.21,
            spendType = "mana",

            startsCombat = true,
            texture = 135729,

            handler = function ()
            end,
        },


        water_elemental = {
            id = 31687,
            cast = 1.5,
            cooldown = 30,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = false,
            texture = 135862,

            notalent = "lonely_winter",

            usable = function () return not pet.alive end,
            handler = function ()
                summonPet( "water_elemental" )
            end,

            copy = "summon_water_elemental"
        },


        time_warp = {
            id = 80353,
            cast = 0,
            cooldown = 300,
            gcd = "off",

            spend = 0.04,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 458224,

            handler = function ()
                applyBuff( "time_warp" )
                applyDebuff( "player", "temporal_displacement" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "potion_of_rising_death",

        package = "Frost Mage",
    } )


    spec:RegisterPack( "Frost Mage", 20190201.2351, [[dOuCXaqiHu6rKISjLO(KseJsiHtrkvEfPIzrkClvKAxQ0VusggPuoMsQLPQkptfrttivxJuQABKIsFtvP04eskNtfjwhPOyEKIQ7je7tvP6GcjQfQI6HcjvtuvvPCrveSrsjFufjnsvvLQtQQQALcQzQQQKBkKi7uvLFQQQyOcPyPkr6PQYuvbxvvPWxvrO9I4VGAWuoSOfdYJjzYaDzOnd4ZcmALYPLSAvLIETQsMnQUTqTBf)wQHtQA5i9CuMovxxPA7kHVliJxijNxfA9QkMpPs7NyYAYbYdmDK87pTT(u02FAB99VtQ9RJ(jjp)OEK80NQVYaK8MmgjpTOnZflkLbi5PppY7eKCG8y9ovHK3M76zAMvRckFBh6Q64vSkENNE1JIMa(kwfRwbXBOvqa5PbXfR0tBGIJSvrdfxAwGSvrZsHJszacRfTz(LvXkYdAV4()hce5bMos(9N2wFkA7pTT((3j1(1)DkKxU7BnL8EvCuN82kqqCiqKhiYuKNMetlAZCXIszakH1KyBURNPzwTkO8TDORQJxXQ4DE6vpkAc4RyvSAfeVHwbbKNgexSspTbkoYwfnuCPzbYwfnlfokLbiSw0M5xwfRKWAsmTqi6Espk2Ane7pTT(ue70I93j1mA)AjSewtIf13YjazAgjSMe70I9nyOylXRye2ByWcxIy1WCmbfRbeBjEsdq)6vmc7nmyHlrmGMkgpz(PzOQhqX03E1ZL84fZzKdKhRMaosoq(TMCG8WjH4ii5m5POLJ0kjpv3CWo0Clfcp9I8sXe8OyllgicTdaCdvJJugSAR487UEYlvE1d5vkeE6fjXj)(JCG8WjH4ii5m5POLJ0kjpp544xeQhOM7xCsiock2YIPNIlGduG31xeQhOM7ITSyrHyrRyEYXXVb8uvjhMPV(cV4KqCeumD1vmODaGBPkfhzxMNQVetZfl6IPRUIbTdaCHOznWaue)GxkMkxmTJ8sLx9qEa8Dk9iXj)oj5a5HtcXrqYzYtrlhPvsEEYXXVb8uvjhMPV(cV4KqCeuSLftpfxahOaVRVb8uvjhMPV(cfBzXG2baUq0SgyakIFWlftLtEPYREipa(oLEK4KFrNCG8WjH4ii5m5POLJ0kjp9uCbCGc8U(cqBMd1CxSLfdAha4crZAGbOi(bVumvUyllwuiw0kMNCC8BapvvYHz6RVWlojehbftxDfdAha4wQsXr2L5P6lX0CXIUyAh5LkV6H8a47u6rIt(P9KdKxQ8QhYdG2FWbUPqKhojehbjNjo5NMLCG8WjH4ii5m5POLJ0kjVu51ceghmUqMyFxS)etxDflvETaHXbJlKj23fBTyllMkzoSxXOyretBITSyq7aaxGAcqkdUbGbOnZVumvUyAUy)rEPYREipiE95tsbjo533soqE4KqCeKCM8u0YrALKh0oaWfOMaKYGBayaAZ8lftLtEPYREiVsHW8CuiXj)IAKdKxQ8QhYt1XOdZ8MgtE4KqCeKCM4KFNc5a5LkV6H8qOEGAUtE4KqCeKCM4KFR1g5a5HtcXrqYzYtrlhPvsErRyPYREUa0(doWnf6wdmaVc2CXwwSaAVpGWzJxaA)bh4McDPyCwdtSiIPnYlvE1d5rZJWnamaTzoXj)wVMCG8WjH4ii5m5POLJ0kjpvYCyVIrXIiM2etxDflvETaHXbJlKj23fBn5LkV6H8G41NpjfK4KFR)JCG8WjH4ii5m5POLJ0kjpODaGlenRbgGI4h8sXu5IPRUIPNIlGduG31xeQhOM7IPRUILkVwGW4GXfYe77ITwSLfZtoo(LPNxUxtaCPWlojehbjVu5vpKxapvvYHz6RVqIt(T(KKdKxQ8QhYRui80lsYdNeIJGKZeN8BD0jhipCsiocsotEPYREipVarM30yyvdIrf5POLJ0kjpODaGBPocVaRHDb7qJyllg0oaWLUpiCdaRVdH0lyhAiVjJrYZlqK5nngw1GyurCYV1Ap5a5LkV6H8aOnZHAUtE4KqCeKCM4KFR1SKdKhojehbjNjVu5vpKNk5C4u5vpW8I5KhVyo8KXi5f3lWyCCIt(T(BjhiVu5vpKxPqyEokK8WjH4ii5mXjo5bIa5o3jhi)wtoqEPYREipvVposz6roN8WjH4ii5mXj)(JCG8WjH4ii5m5POLJ0kjp9uCbCGc8U(cW3P0JITSyrRyq7aaxGAcqkdUbGbOnZVumvo5LkV6H8kfcZZrHeN87KKdKhojehbjNjVu5vpKNk5C4u5vpW8I5KhVyo8KXi5P6Md2HggXj)Io5a5HtcXrqYzYtrlhPvsEPYRfimoyCHmX(UyNuSLfZtoo(fGI4NAcGPznxCsiockMU6kwQ8AbcJdgxitSVlw0jVu5vpKNk5C4u5vpW8I5KhVyo8KXi5LnsCYpTNCG8WjH4ii5m5LkV6H8ujNdNkV6bMxmN84fZHNmgjpwnbCK4eN80trvhdLo5a53AYbYdNeIJGKZeN87pYbYdNeIJGKZeN87KKdKhojehbjNjo5x0jhiVu5vpKxsv5GW14iNJkN8WjH4ii5mXj)0EYbYlvE1d5fkDKcJCmghp5KhojehbjNjo5NMLCG8WjH4ii5mXj)(wYbYlvE1d5fxuAtHR4majpCsiocsotCYVOg5a5LkV6H803E1d5HtcXrqYzIt(DkKdKxQ8QhYdG2mhQ5o5HtcXrqYzItCYt1nhSdnmYbYV1KdKxQ8QhYRuhHxG1WipCsiocsotCYV)ihiVu5vpKxCrPnfUIZaK8WjH4ii5mXj)oj5a5HtcXrqYzYtrlhPvsE6P4c4af4D9fG2FWbUPqIPRUI5vmc7nmyHI9DXwRnX0rmvYCyVIrXwwmVIryVHblumnxS)0g5LkV6H8O7dc3aW67qiL4KFrNCG8WjH4ii5m5POLJ0kjpp544x6(GWnaS(oesV4KqCeuSLflvETaHXbJlKjweXwl2YIP6Md2HMlDFq4gawFhcPxGDohMIQTKgGWEfJIP5IP6Md2HMlaT)GdCtHUumoRHrEPYREipvY5WPYREG5fZjpEXC4jJrYZtooomT1tCYpTNCG8WjH4ii5m5POLJ0kjp9uCbCGc8U(wQJWlWAyIPRUI5vmc7nmyHIP5I9TAJ8sLx9qE6BV6H4KFAwYbYlvE1d5TZq4YXyg5HtcXrqYzIt(9TKdKxQ8QhYdI3nimWo9i5HtcXrqYzIt(f1ihiVu5vpKheszi9RAcipCsiocsotCYVtHCG8sLx9qE8kyZzWFZDWGyCCYdNeIJGKZeN8BT2ihiVu5vpKhqrriE3GKhojehbjNjo5361KdKxQ8QhYlhfYCAYHvjNtE4KqCeKCM4eN8Ygjhi)wtoqEPYREipaA)bh4McrE4KqCeKCM4KF)roqEPYREipiE95tsbjpCsiocsotCYVtsoqEPYREipvhJomZBAm5HtcXrqYzIt(fDYbYlvE1d5vkeE6fj5HtcXrqYzIt(P9KdKhojehbjNjpfTCKwj5PNIlGduG31xeQhOM7IPRUIbTdaCHOznWaue)GxkMkxSLflketpfxahOaVRVa0M5qn3fBzXIcXG2baULQuCKDzEQ(smnxSOlMU6kw0kMNCC8BapvvYHz6RVWlojehbft7etxDftpfxahOaVRVb8uvjhMPV(cft7iVu5vpKhaFNspsCYpnl5a5HtcXrqYzYtrlhPvsEq7aaxGAcqkdUbGbOnZVumvo5LkV6H8kfcZZrHeN87BjhiVu5vpKhnpc3aWa0M5KhojehbjNjo5xuJCG8sLx9qEiupqn3jpCsiocsotCYVtHCG8sLx9qEb8uvjhMPV(cjpCsiocsotCYV1AJCG8sLx9qEQEq4gaw1CqYdNeIJGKZeN8B9AYbYdNeIJGKZKxQ8QhYZlqK5nngw1GyurEkA5iTsYdAha4wQJWlWAyxWo0i2YIbTdaCP7dc3aW67qi9c2HgYBYyK88cezEtJHvnigveN8B9FKdKxQ8QhYdG2mhQ5o5HtcXrqYzIt(T(KKdKhojehbjNjVu5vpKNk5C4u5vpW8I5KhVyo8KXi5f3lWyCCIt(To6KdKxQ8QhYRuimphfsE4KqCeKCM4eN8I7fymoo5a53AYbYdNeIJGKZKNIwosRK8I7fymo(fSyEokuSVl2ATrEPYREipiEnFrCYV)ihipCsiocsotEkA5iTsYdAha4wkegG3i7c2HgYlvE1d5vkegG3iJ4eN4K3cKYQEi)(tBRJAR12F)D)tBA)FKxOKo1eWiV)hRVPockMMvSu5vpIXlMZUsyYJPhvKFA2OtE6PnqXrYttIPfTzUyrPmaLWAsSn31Z0mRwfu(2o0v1XRyv8op9Qhfnb8vSkwTcI3qRGaYtdIlwPN2afhzRIgkU0SazRIMLchLYaewlAZ8lRIvsynjMwieDpPhfBTgI9N2wFkIDAX(7KAgTFTewcRjXI6B5eGmnJewtIDAX(gmuSL4vmc7nmyHlrSAyoMGI1aITepPbOF9kgH9ggSWLigqtfJNm)0mu1dOy6BV65kHLWAsStiQq1UJGIbHanfft1XqPlgegud7kwuwPq9otSPNtVL0yGDUyPYREyI1d)4vcNkV6HD1trvhdLEeaEY(scNkV6HD1trvhdLUorwb0nOeovE1d7QNIQogkDDISk3dIXXtV6rcNkV6HD1trvhdLUorwLuvoiCnoY5OYLWPYREyx9uu1XqPRtKvS944EGdLosHrogJJNCjCQ8Qh2vpfvDmu66ezfBs9ST2HzE6mjCQ8Qh2vpfvDmu66ezvCrPnfUIZaucNkV6HD1trvhdLUorwPV9QhjCQ8Qh2vpfvDmu66ezfaTzouZDjSewtIDcrfQ2DeumCbspkMxXOy(gkwQ8MkwXelxKfpH44vcNkV6Hfr17JJuMEKZLWAsS)diMVHIfNbOyBjtmTATelbCKkMkzEnbIvdZZXftl(oLEudXcHIPYrmqKNhfZ3qX(Vcf7FLJcflhqX2zOyTVHuX2QGnX0tRMw(rXsLx9OHyfGy5IS4jehVs4u5vpmDISQuimphfQrberpfxahOaVRVa8Dk94Yrl0oaWfOMaKYGBayaAZ8lftLlHtLx9W0jYkvY5WPYREG5fZ1yYymIQBoyhAysynj2HnumpPbOlMVrr2wZbfRyZsCXWOkv(vSZOhcXrStEATxmpPbOZ0qmFdfdSaaqkokKjge6HqCeZ3qXEhelhqXIY9jiwQ8QhX4fZzILuumA6BivmwCY5xX(37q4cKQHyArr8tnbIT0SgX0traKYeBNvtGyr5(eelvE1Jy8I5IX6EqQyjtSYfdcheOCMybumD(rXaODSy(gk2wfSjMEA10Ypk2zE95tsbflvE1ZvcNkV6HPtKvQKZHtLx9aZlMRXKXyKSrnkGiPYRfimoyCHSVFYL9KJJFbOi(PMayAwZfNeIJG6QBQ8AbcJdgxi77rxcNkV6HPtKvQKZHtLx9aZlMRXKXyewnbCuclH1KyNy5BIPffXp1ei2sZA0qSYxctmi0DKkM3IPNwnT86dk2oRMaX0I2FWrS)HcjwOnCedQ9nX06FelhqXoZRpFskOyjffRbaet1nhSdnxXoXY36DxmTOi(PMaXwAwJgI5BOyQEwGugkwXeZP7Oyj3369GnX8numWcaaP4OqXkMyX1um1ohfBF8Il2cKEuSTkytmpPbOlMQ3hNDLWPYREy3SXia0(doWnfscNkV6HDZg1jYkiE95tsbLWPYREy3SrDISs1XOdZ8MglHtLx9WUzJ6ezvPq4PxKsynj2RI1ZlGcbftl(oLEumvpGLx9WedG2XI5BOyVdILkV6rmEX8RyVAuOy(gkwCgGIvmXcWbPPxtGyajvmoYyIDMM1iMwue)GIP2sAaY0qmFdfdJQu5IP6bS8QhX2qkkwXML4ILCUy(w6IvX6BQNJFLWPYREy3SrDIScGVtPh1OaIONIlGduG31xeQhOM76Ql0oaWfIM1adqr8dEPyQ8LJc9uCbCGc8U(cqBMd1CF5OaAha4wQsXr2L5P6lnp66QB06jhh)gWtvLCyM(6l8ItcXrqTtxD1tXfWbkW76BapvvYHz6RVqTtcNkV6HDZg1jYQsHW8CuOgfqeODaGlqnbiLb3aWa0M5xkMkxcRjXoSHIfNbOyHkoxSaCqAY5hfdcflahKMEnbILIXBxSgqmTATetTL0aKjwOnCeBNvtGy(gkwuUpbXsLx9igVy(vSd0J1eiM3IbI88OylnpkwdiMw0M5ITpEXfZ3qkkwsrXMwmTATetTL0aKjwoGInTyPYRfOyAr7p4i2)qHyIfQ35GIXXeumVfRCXM2fdcRjqSDgckw6ILC(vcNkV6HDZg1jYkAEeUbGbOnZLWPYREy3SrDIScH6bQ5UeovE1d7MnQtKvb8uvjhMPV(cLWAsSVbRMaXI69GI1aIf1BoOyftS4M58JI9VfnpXgC3PjxSqLVjMVHIfL7tqmpPbOlMVrr2wZbzxX(Vlwp8JIbHQogzIbIkCCXcYAelu5BIr79Gn(rX(wXAQyXnffZtAa6SReovE1d7MnQtKvQEq4gaw1CqjCQ8Qh2nBuNiR2ziC5ySgtgJr8cezEtJHvnigvAuarG2baUL6i8cSg2fSdnldTdaCP7dc3aW67qi9c2HgjCQ8Qh2nBuNiRaOnZHAUlHtLx9WUzJ6ezLk5C4u5vpW8I5AmzmgjUxGX44s4u5vpSB2OorwvkeMNJcLWs4u5vpSRQBoyhAyrk1r4fynmjCQ8Qh2v1nhSdnmDISkUO0McxXzakH1KylDFqXAaXIMoesfRyIL8q5rMy7meuSqLVjMw0(doI9puORyr55OyCeW7fivm1wsdqMyPlMVHIHdOynGy(gkgqfS5IX26DoOyqOy7meudXkqm58JIvaI5BOyqnJjgyJSzjUyGfkwnI5BOyXfiihfRbeZ3qXw6(GIbTdaCLWPYREyxv3CWo0W0jYk6(GWnaS(oes1OaIONIlGduG31xaA)bh4McPRUEfJWEddw43xRnDujZH9kgx2Rye2ByWc18)0MewtI9pJySAc4OyEsdqxmGkyZzAiMVHIP6Md2HgXAaXw6(GI1aIfnDiKkwXeJ3HqQy(woI5BOyQU5GDOrSgqmTO9hCe7FOqAiMVvmXcQfitmmQCAk2s3huSgqSOPdHuXuBjnazI5BPlgBR35GIbHITZqqXcv(MyPYRfOyEYXXzAiwbiM(MXkioELWPYREyxv3CWo0W0jYkvY5WPYREG5fZ1yYymINCCCyARxJciINCC8lDFq4gawFhcPxCsiocUCQ8AbcJdgxilY6LvDZb7qZLUpiCdaRVdH0lWoNdtr1wsdqyVIrnx1nhSdnxaA)bh4McDPyCwdtcNkV6HDvDZb7qdtNiR03E1Jgfqe9uCbCGc8U(wQJWlWAy6QRxXiS3WGfQ5FR2KWPYREyxv3CWo0W0jYQDgcxogZKWPYREyxv3CWo0W0jYkiE3GWa70Js4u5vpSRQBoyhAy6ezfeszi9RAcKWPYREyxv3CWo0W0jYkEfS5m4V5oyqmoUeovE1d7Q6Md2HgMorwbuueI3nOeovE1d7Q6Md2HgMorwLJczon5WQKZLWs4u5vpSBCVaJXXJaXR5lnkGiX9cmgh)cwmphf(91AtcNkV6HDJ7fymoUorwvkegG3itJcic0oaWTuimaVr2fSdnsyjSMe7)JySogfJv(E6vpmne7yVlMkhXyBP7ivS)RqX(1lsXWf4iwc4ivSKtXe8OyQK51eiMw8Dk9Oy5ak2)vOy)RCu4vS)X3qAOIHI5BftSu5vpIvmX2ziOyH2WrmFdflodqX2sMyA1Ajwc4ivmvY8Acetl(oLEudXyikwc1lWReovE1d7YQjGJrkfcp9IuJciIQBoyhAULcHNErEPycECzqeAha4gQghPmy1wX53D9synj2jw(wV7IDQpne7eG6bQ5UyftSKhkpYeJTLUJue8k2jw(MyN6tdXobOEGAUlwXeJTLUJueuScqSYfluVZbfluYCuSZ0SgX0II4hum1wsdqXII6IxXcTHJy(gkwCgGIX8K6mXujZRjqStaQhOM7IfQ8nXotZAetlkIFqXsLxlqTtSMkwOnCedc5DiXIUy)xvkoYelkkaXobOEGAUlwXetLmxSqB4iMVHIfNbOyBjtSOFATxS)RkfhzAiw5lHjge6osfZBX2zOy(gk2zAwJyArr8dkgaTJfRCX6rStLNQk5I90xFHA3vcNkV6HDz1eWrDIScGVtPh1OaI4jhh)Iq9a1C)ItcXrWL1tXfWbkW76lc1duZ9LJIO1too(nGNQk5Wm91x4fNeIJG6Ql0oaWTuLIJSlZt1xAE01vxODaGlenRbgGI4h8sXu5ANewtIDQ8uvjxSN(6luSIjwYdLhzIX2s3rkcELWPYREyxwnbCuNiRa47u6rnkGiEYXXVb8uvjhMPV(cV4KqCeCz9uCbCGc8U(gWtvLCyM(6lCzODaGlenRbgGI4h8sXu5synj2jw(wV7IDQpneZ3qXIZauSV5oZfZPfYeZBXyBP7ivSKjwCohftlAZCOM7mXsMy6BgRG44vStS8nXo1NgI5BOyXzakwp8JIX2s3rktmTOnZHAUlMVLUyH6DoOy63DX8nmwS0fB9PpPy)xvkokgZt1xSRy)BfaasXrHIbHEiehXyBP7iTMaX0I2mhQ5UyHkFtS1N(KI9FvP4itSCafB9PJUy)xvkoYeRyIXItoxdXG2DXwF6tkMJditmVfdcfdcDhPIvJyXnffJv(E6vpmXIcFdfBRc2qQyN6tmWmodqXkMgI5BOyXnffRCX4yomX8ousbzIT(0Nu7UIPvtv1eigBlDhPI1JyArBMd1CxSIjgZloxSumwCY5IfK1OHySwSIj20UyQKwtGyjuV7IPvR1vS)RqX(x5OqXkMyE3IfcZVeZBXcLuAoUyGippwtGyNPznIPffXpOyAX3P0JxjCQ8Qh2Lvtah1jYka(oLEuJciIEkUaoqbExFbOnZHAUVm0oaWfIM1adqr8dEPyQ8LJIO1too(nGNQk5Wm91x4fNeIJG6Ql0oaWTuLIJSlZt1xAE01ojCQ8Qh2Lvtah1jYkaA)bh4McjH1KyNy5BIPffXp1ei2sZAelhqXsxmoMmxS)eZtAa6mne7mV(8jPGInicYeZBXGqX2ziOyHkFtSTkydPIPNwnT8JI5TyX5xOySDkk2XExmvoIbuUyqTVjwnmphxSZ86ZNKcYeRgVflfJvtahftlkIFQjqSLM1Cf75j1RjqSqLVjMVrrumpPbOZ0qSZ86ZNKckghZfitmFdfJ3HetpTAA5hfdO4CKkgT5Oy5akwXeBNHGI1JyQU5GDOrSOihqX(M7mxS48RAceJTtrXM2fZBXcLmhf7mnRrmTOi(bftTL0aKPDIfQ8nXAQyHkFR3DX0II4NAceBPznxjCQ8Qh2Lvtah1jYkiE95tsb1OaIKkVwGW4GXfY((F6QBQ8AbcJdgxi77RxwLmh2RymI2wgAha4cutaszWnamaTz(LIPY18)KWAsSd0J1eiM3IPVBUyQTKgGmXAaX0Q1smGMkwoh9TAceRyZsCXc1uFtSYVI9nyOy(gglwYeZ3WJIP6y8kHtLx9WUSAc4OorwvkeMNJc1OaIaTdaCbQjaPm4gagG2m)sXu5s4u5vpSlRMaoQtKvQogDyM30yjCQ8Qh2Lvtah1jYkeQhOM7synj2sZJI1aIPfTzUyftSDgckwc4ivSKZftRAcqktSgqmTOnZftTL0aKj2wUafdcXrSDgckwoGI5BiffRyZsCXsLxlqX0I2FWrS)HcjMVLUyQENdkwaoinDuS4MIxXoSvmXkMy9Wpkwkglo5CXcYAeldYAyUyX7CV0ZrX8KgGotdXsMylnpkwdiMw0M5IvSzjUyE3IvX6tLdSZVs4u5vpSlRMaoQtKv08iCdadqBMRrbejAtLx9CbO9hCGBk0TgyaEfS5lhq79beoB8cq7p4a3uOlfJZAyr0MewtIDMxF(KuqXkMy7meuSKjgVdjMEA10YpkgqX5ivSmiRH5I9NyEsdqNDf7e3WrSDwnbIPffXp1ei2sZA0qSYxctSuSyeS2JfliRrmVfBNHI5BOy1W8CCXoZRpFskOy4cCeldYAyUyPySAc4OyEsdqxdXqMEuvjNFuSqLVjgVdjwCYCKE8kHtLx9WUSAc4OorwbXRpFskOgfqevYCyVIXiAtxDtLxlqyCW4czFFTewtIDQ8uvjxSN(6luSIj2odbfl0goI5BifxctSuSZ0SgX0II4hum90wjwQ8Abkwuux8kwp8JIfAdhXkxmvoIbHIX2s3rkcQDxXoSvmXkMyPyS4KZfZBXIrWApwSGSgXQrS4M5IXkFp9Qh2vS)vhsS4K5i9OyCmhMyEhkPGmX2z1eiw5IfAdhXYfzXtioEf7e3WrSDwnbI90Zl3RjqS)RqXYbuSTCrnbILt7BivmpPbOl2Gjf6OgIv(syIX4vWMZpkge6osfZBX2zOyN6tSqB4iwUilEcXrnelzI5BOymu1dOyEsdqxmWgzZsCXGWbbkxmaAhlgBlDhP1eiMVHIfN1iMN0a0Vs4u5vpSlRMaoQtKvb8uvjhMPV(c1OaIaTdaCHOznWaue)GxkMkxxD1tXfWbkW76lc1duZDD1nvETaHXbJlK991l7jhh)Y0Zl3RjaUu4fNeIJGs4u5vpSlRMaoQtKvLcHNErkHtLx9WUSAc4OorwTZq4YXynMmgJ4fiY8MgdRAqmQ0OaIaTdaCl1r4fynSlyhAwgAha4s3heUbG13Hq6fSdns4u5vpSlRMaoQtKva0M5qn3LWPYREyxwnbCuNiRujNdNkV6bMxmxJjJXiX9cmghxcNkV6HDz1eWrDISQuimphfsCIti]] )


end
