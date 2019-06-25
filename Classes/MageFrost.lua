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


    spec:RegisterStateTable( "rotation", setmetatable( {},
    {
        __index = function( t, k )
            if k == "standard" and state.settings.rotation == "standard" then return true
            elseif k == "no_ice_lance" and state.settings.rotation == "no_ice_lance" then return true
            elseif k == "frozen_orb" and state.settings.rotation == "frozen_orb" then return true end
        
            return false
        end,
    } ) )




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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
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


    spec:RegisterSetting( "rotation", "standard", {
        name = "Preferred Priority",
        desc = "This sets the |cFFFFD100rotation.X|r value, selecting between one of two integrated SimC builds.",
        type = "select",
        width = 1.5,
        values = {
            standard = "Standard",
            no_ice_lance = "No Ice Lance",
            frozen_orb = "Frozen Orb"
        }
    } )

    
    -- 86e3ecc572a70c6f43be4aaf90be1a0d4103da31
    spec:RegisterPack( "Frost Mage", 20190625.0856, [[dO0OxbqifQ0Jui1MiQ6tkeAuevYPiQuVcL0SqrDlIK0UuYVqrgMcjhdfAzev8mIeMgkHUgiHTPqfFJijghkrCoucSoqIQ5Hsu3dLAFku1brjOwii6HGePjcseUikrAJGK(irIAKkeuDsIKALcyMOeKBQqqzNOGFQqGHcsuwQcr9uvzQkvDvqIOVsKi7f4Vcnyvomvlwv9yetguxgAZk6ZkLrteNMYQviiVwHYSjCBfSBj)wQHtuwosphvtN01f02vQ8DbA8ke58GuRheMprQ9lAaJG9GhSRiGb5mkgzbJACKduSgflbkgh5afGNcTme8K5KX8ne8kFabpOsBUM3imFdbpzo0I2Hb7bpEhsji4jrvzCOCMyAZujH)fPhyIBdHcxTUiuFQmXTbctG3p0eQuxGp4b7kcyqoJIrwWOgh5afRrXsGcOyuSaWZdvjnf8E2auk4jXGHXc8bpyKtaVrNhuPnxZBeMVHzGrNNevLXHYzIPntLe(xKEGjUnekC16Iq9PYe3gimLbgDEbclmp5momNNCgfJSG8KQ5nkwcuUumozGmWOZdkvIxBihkpdm68KQ5bLKJ5nIQnGrTJWgoI5zfxrhoVEM3iQoDd1LAdyu7iSHJyEZMMNW5AECK0fCEqPqjYlK7B4c8egx5G9G3SJCR2eiypGbgb7bpS8VaHbqcEeQPi1CWJ0TaUdwlJGXQ35lk6WqNN85bJ)W5Cf0kfP8irIjeRqzGNtuRlWZiyS6DoqbmihWEWZjQ1f4nPneyfB6h8WY)cegajqbmifG9Ghw(xGWaibpc1uKAo4jJI7IBe4fJl831VfAEYN3pCoxFQBvCsrecCrrNOGNtuRlWBkcPuObkGbweSh8WY)cegaj4rOMIuZbpNO2omIfoyipVXNNCYtAPZZjQTdJyHdgYZB85XyEYNhX5AuTbmp25nkWZjQ1f49fgeq4uyGcyaka7bpS8VaHbqcEeQPi1CW7hoNRPvBiLh7zCsBUUOOt08Kpps3c4oyTM0gcSIn9VO4GBfpVXNhuKN0sN3pCoxtR2qkp2Z4K2CDrrNO5Xop5aEorTUapJGrHxeeOagghWEWdl)lqyaKGhHAksnh8ioxJQnG5XoVrbEorTUaVVWGacNcduadsfWEWdl)lqyaKGhHAksnh8KrXDXnc8IXf(763cf8CIADbEtriLcnqbmWsa7bpS8VaHbqcEeQPi1CW7hoNRp1TkoPicbUOOt08Kpp5kpzuCxCJaVyCnPnx)TqZtAPZdg)HZ5sMtgdHJgbxuCWTIN34ZdhjKeQyuTbmpwZZjQ11Yiyu4fbxk13HIOAdyEYn45e16c8MIqkfAGcyGfa2dEorTUapspGAKRnDa8WY)cegajqbmW4Oa7bpNOwxGh(763cf8WY)cegajqbmWiJG9Ghw(xGWaibpNOwxGh1Ho2Z4K2Cf8SsrknuMgTj49dNZ10QnKYJ9moPnxxu0jkB5aEwPiLgktJ2WacBUIGhJGhHAksnh8GXF4CUK5KXq4OrWvOmGcyGr5a2dEorTUaVVWGacNcdEy5FbcdGeOagyuka7bpNOwxGNrWy17CWdl)lqyaKafWaJSiyp4HL)fimasWZjQ1f4PgmY1MoejnmosGhHAksnh8(HZ5Yiqh3HwXxWDWkp5Z7hoNlAyHXEgL1br6cUdwGx5di4PgmY1MoejnmosafWaJqbyp45e16c8M0MR)wOGhw(xGWaibkGbghhWEWdl)lqyaKGNtuRlWJ4cr0jQ1vuyCf8egxJLpGG3qVdhWsbkGbgLkG9GNtuRlWZiyu4fbbpS8VaHbqcuGcEiNJfb5G9agyeSh8CIADbEZMeYr4OdbsnfJF0hapS8VaHbqcuadYbSh8WY)cegaj4rOMIuZbVF4CUmIreiFXvNmwESCEYb8CIADbEd4qtHo2ZOiKyWryk6dCGcyqka7bpS8VaHbqcEeQPi1CW7hoNlJyebYxC1jJLh78GI8KpVF4CU(u3Q4KIie4IIorZtAPZZjQTdJyHdgYZB85XIGNtuRlW7l6go2ZOkbJyHdqduadSiyp45e16c8KfsTj0wTf)cNRGhw(xGWaibkGbOaSh8CIADbEutMmbgTkYL5ee8WY)cegajqbmmoG9GNtuRlWJ0fblL6kchNcFabpS8VaHbqcuadsfWEWdl)lqyaKGhHAksnh8(HZ5IIKXeiNhNnLGRqzGNtuRlWtLGXW63HfCC2uccuadSeWEWZjQ1f4fSPc4DOvrkY7YlccEy5FbcdGeOaf8QoAIi3Qnbc2dyGrWEWdl)lqyaKGhHAksnh8iDlG7G1YiyS6D(IIom05jFEW4pCoxbTsrkpsKycXkug45e16c8mcgRENduadYbSh8WY)cegaj4rOMIuZbp1fyPl831Vf6cl)lq48KppzuCxCJaVyCH)U(TqZt(8(HZ56tDRItkIqGlk6ef8CIADbEtriLcnqbmifG9Ghw(xGWaibpc1uKAo4jJI7IBe4fJRnHtmxe5YSXW8KpVF4CU(u3Q4KIie4IIorbpNOwxG3uesPqduadSiyp45e16c8M0gcSIn9dEy5FbcdGeOagGcWEWdl)lqyaKGhHAksnh8CIA7Wiw4GH88gFEYjpPLopNO2omIfoyipVXNhJ5jFEeNRr1gW8yN3OapNOwxG3xyqaHtHbkGHXbSh8WY)cegaj4rOMIuZbVF4CUMwTHuESNXjT56IIorZt(8uxGLU4YeMQwTfncUWY)ceop5ZZjQTdJyHdgYZB85Xi45e16c8mcgfErqGcyqQa2dEorTUapspGAKRnDa8WY)cegajqbmWsa7bpS8VaHbqcEeQPi1CW7hoNlJyebYxC1jJLh78GI8KpVXnVF4CU(u3Q4KIie4IIorbpNOwxGh(763cfOagybG9Ghw(xGWaibpc1uKAo49dNZ1N6wfNueHaxu0jAEslDEYO4U4gbEX4c)D9BHcEorTUaVnHtmxe5YSXqGcyGXrb2dEorTUapJGXQ35Ghw(xGWaibkGbgzeSh8WY)cegaj45e16c8udg5AthIKgghjWJqnfPMdE)W5CzeOJ7qR4l4oyLN859dNZfnSWypJY6GiDb3blWR8be8udg5AthIKgghjGcyGr5a2dEorTUaVjT56Vfk4HL)fimasGcyGrPaSh8WY)cegaj45e16c8iUqeDIADffgxbpHX1y5di4n07WbSuGcyGrweSh8CIADbEgbJcVii4HL)fimasGcuWB2rKZXIGCWEadmc2dEy5FbcdGe8iutrQ5Ghm(dNZLmNmgchncUG7Gf45e16c8MnjKJWrhcKAkg)OpauadYbSh8WY)cegaj4rOMIuZbpy8hoNlzozmeoAeCb3blWZjQ1f4nGdnf6ypJIqIbhHPOpWbkGbPaSh8WY)cegaj4rOMIuZbpzuCxCJaVyCrdlm2ZOSoisZt(8KrXDXnc8soRjTHaRyt)GNtuRlW7l6go2ZOkbJyHdqduadSiyp4HL)fimasWJqnfPMdEW4pCoxYCYyiC0i4cUdwGNtuRlWtwi1MqB1w8lCUcuadqbyp4HL)fimasWJqnfPMdEW4pCoxYCYyiC0i4cUdwGNtuRlWJAYKjWOvrUmNGafWW4a2dEy5FbcdGe8iutrQ5Ghm(dNZLmNmgchncUG7Gf45e16c8iDrWsPUIWXPWhqGcyqQa2dEy5FbcdGe8iutrQ5G3pCoxuKmMa584SPeCfkd8CIADbEQemgw)oSGJZMsqGcyGLa2dEy5FbcdGe8iutrQ5Ghm(dNZLmNmgchncUG7Gf45e16c8c2ub8o0Qif5D5fbbkqbp1fyPrAldShWaJG9Ghw(xGWaibpc1uKAo4PUalDTjCI5IixMngUWY)ceop5Z7hoNlJyebYxC1jJLh78GI8Kpp5kVF4CU(u3Q4KIie4IIorZtAPZtDbw6c)D9BHUWY)ceop5ZJ0TaUdwl831Vf6IIdUv88y58ioxJQnG5j3GNtuRlWJgwySNrzDqKcuadYbSh8WY)cegaj4rOMIuZbVXnp1fyPRnHtmxe5YSXWfw(xGW5jFEYvEQlWsx4VRFl0fw(xGW5jFEKUfWDWAH)U(TqxuCWTINhlNhX5AuTbmpPLop1fyPlspGAKRnDyHL)fiCEYNhPBbChSwKEa1ixB6WIIdUv88y58ioxJQnG5jT05PUalDrDOJ9moPnxxy5FbcNN85r6wa3bRf1Ho2Z4K2CDrXb3kEESCEeNRr1gW8Kw68isC6gYJtQtuRlxK34ZJXflip5g8CIADbE0WcJ9mkRdIuGcuWBO3HdyPG9agyeSh8WY)cegaj4rOMIuZbVF4CUmcgNIg5l4oybEorTUapJGXPOroqbk4jJIKE47kypGbgb7bpS8VaHbqcuadYbSh8WY)cegajqbmifG9Ghw(xGWaibkGbweSh8CIADbEoL4fgTsrHajk4HL)fimasGcyaka7bpNOwxGxqxrAef4awQlapS8VaHbqcuadJdyp4HL)fimasGcyqQa2dEorTUaVbJsBA0g8ne8WY)cegajqbmWsa7bpNOwxGNSwTUapS8VaHbqcuadSaWEWZjQ1f4nPnx)TqbpS8VaHbqcuGcEEJG9agyeSh8CIADbEtAdbwXM(bpS8VaHbqcuadYbSh8CIADbEFHbbeofg8WY)cegajqbmifG9Ghw(xGWaibpNOwxGhXfIOtuRROW4k4jmUglFabpKZXIGCGcyGfb7bpNOwxGhPhqnY1MoaEy5FbcdGeOagGcWEWZjQ1f4zemw9oh8WY)cegajqbmmoG9Ghw(xGWaibpc1uKAo4jJI7IBe4fJl831VfAEslDE)W5C9PUvXjfriWffDIMN85jx5jJI7IBe4fJRjT56VfAEYNNCL3pCoxgXicKV4QtglpwopwmpPLoVXnp1fyPRnHtmxe5YSXWfw(xGW5j35jT05jJI7IBe4fJRnHtmxe5YSXW8KBWZjQ1f4nfHuk0afWGubSh8WY)cegaj4rOMIuZbVF4CUMwTHuESNXjT56IIorbpNOwxGNrWOWlccuadSeWEWZjQ1f4rDOJ9moPnxbpS8VaHbqcuadSaWEWZjQ1f4H)U(TqbpS8VaHbqcuadmokWEWZjQ1f4TjCI5IixMngcEy5FbcdGeOagyKrWEWZjQ1f4r6cJ9msAbm4HL)fimasGcyGr5a2dEy5FbcdGe8CIADbEQbJCTPdrsdJJe4rOMIuZbVF4CUmc0XDOv8fChSYt(8(HZ5IgwySNrzDqKUG7Gf4v(acEQbJCTPdrsdJJeqbmWOua2dEorTUaVjT56Vfk4HL)fimasGcyGrweSh8WY)cegaj45e16c8iUqeDIADffgxbpHX1y5di4n07WbSuGcyGrOaSh8CIADbEgbJcVii4HL)fimasGcuWJ0TaUdwCWEadmc2dEorTUapJaDChAfh8WY)cegajqbmihWEWZjQ1f4nyuAtJ2GVHGhw(xGWaibkGbPaSh8WY)cegaj4rOMIuZbpzuCxCJaVyCnPneyfB6ppPLop1PBOUuBaJAhHnmVXNhJJkpwZJ4CnQ2aMN85PoDd1LAdyu7iSH5XY5jNrbEorTUapAyHXEgL1brkqbmWIG9Ghw(xGWaibpc1uKAo4PUalDrdlm2ZOSoisxy5FbcNN855e12HrSWbd55XopgZt(8iDlG7G1IgwySNrzDqKUMHcrKIejoDdJQnG5XY5r6wa3bR1K2qGvSP)ffhCR4GNtuRlWJ4cr0jQ1vuyCf8egxJLpGGN6cS0iTLbuadqbyp4HL)fimasWJqnfPMdEYO4U4gbEX4Yiqh3HwXZtAPZtD6gQl1gWO2rydZJLZtkgf45e16c8K1Q1fqbmmoG9GNtuRlWlKJrtXbo4HL)fimasGcyqQa2dEy5FbcdGe8iutrQ5G34MhTvxTUwtAdbwXM(ZtAPZJ0TaUdwRjTHaRyt)lko4wXZJLZdkapNOwxG3wOtHnVI9m6qG0wLauadSeWEWZjQ1f49fDdhNHuObpS8VaHbqcuadSaWEWZjQ1f49rkhPJz1g4HL)fimasGcyGXrb2dEorTUapHTjr5XrOq4TbSuWdl)lqyaKafWaJmc2dEorTUaVPrXVOByWdl)lqyaKafWaJYbSh8CIADbEErqUsDrK4cb4HL)fimasGcuWdgNEOqb7bmWiyp45e16c8iDyPiLldfcWdl)lqyaKafWGCa7bpS8VaHbqcEeQPi1CWtgf3f3iWlgxtriLcDEYN34M3pCoxtR2qkp2Z4K2CDrrNOGNtuRlWZiyu4fbbkGbPaSh8WY)cegaj45e16c8iUqeDIADffgxbpHX1y5di4r6wa3bloqbmWIG9Ghw(xGWaibpc1uKAo45e12HrSWbd55n(8KI8Kpp1fyPRjfriSAlsDRwy5FbcNN0sNNtuBhgXchmKN34ZJfbpNOwxGhXfIOtuRROW4k4jmUglFabpVrGcyaka7bpS8VaHbqcEeQPi1CWJ2QRwxRjTHaRyt)GNtuRlWJ4cr0jQ1vuyCf8egxJLpGG3SJCR2eiqbmmoG9Ghw(xGWaibpc1uKAo4rB1vRRv1rJGrHxee8CIADbEexiIorTUIcJRGNW4AS8be8QoAIi3QnbcuadsfWEWdl)lqyaKGhHAksnh8OT6Q11IREb7uyWZjQ1f4rCHi6e16kkmUcEcJRXYhqWJB1MabkqbpUvBceShWaJG9Ghw(xGWaibpc1uKAo4r6wa3bRLrWy178ffDyOZt(8GXF4CUcALIuEKiXeIvOmWZjQ1f4zemw9ohOagKdyp4HL)fimasWJqnfPMdEQlWsx4VRFl0fw(xGW5jFEYO4U4gbEX4c)D9BHMN85jx5nU5PUalDTjCI5IixMngUWY)ceopPLoVF4CUmIreiFXvNmwESCESyEslDE)W5C9PUvXjfriWffDIMNCdEorTUaVPiKsHgOagKcWEWdl)lqyaKGhHAksnh8uxGLU2eoXCrKlZgdxy5FbcNN85jJI7IBe4fJRnHtmxe5YSXW8KpVF4CU(u3Q4KIie4IIorbpNOwxG3uesPqduadSiyp4HL)fimasWJqnfPMdEYO4U4gbEX4AsBU(BHMN859dNZ1N6wfNueHaxu0jAEYNNCL34MN6cS01MWjMlICz2y4cl)lq48Kw68(HZ5YigrG8fxDYy5XY5XI5j3GNtuRlWBkcPuObkGbOaSh8WY)cegaj4rOMIuZbVXnpARUADTM0gcSIn9dEorTUapIlerNOwxrHXvWtyCnw(acEiNJfb5afWW4a2dEy5FbcdGe8iutrQ5GhTvxTUwtAdbwXM(bpNOwxGhXfIOtuRROW4k4jmUglFabVzhrohlcYbkGbPcyp45e16c8M0gcSIn9dEy5FbcdGeOagyjG9Ghw(xGWaibpc1uKAo45e12HrSWbd55n(8KtEslDEorTDyelCWqEEJppgZt(8ioxJQnG5XoVrLN859dNZ10QnKYJ9moPnxxu0jAESCEYb8CIADbEFHbbeofgOagybG9Ghw(xGWaibpc1uKAo49dNZ10QnKYJ9moPnxxu0jk45e16c8mcgfErqGcyGXrb2dEorTUapspGAKRnDa8WY)cegajqbmWiJG9GNtuRlWd)D9BHcEy5FbcdGeOagyuoG9Ghw(xGWaibpc1uKAo4nU55e16AnPneyfB6FzvCkSnjAEYN3gTdl4O34AsBiWk20)IIdUv88yN3OapNOwxGh1Ho2Z4K2CfOagyuka7bpS8VaHbqcEeQPi1CWJ4CnQ2aMh78gvEslDEorTDyelCWqEEJppgbpNOwxG3xyqaHtHbkGbgzrWEWdl)lqyaKGhHAksnh8(HZ56tDRItkIqGlk6enpPLopzuCxCJaVyCH)U(TqZtAPZZjQTdJyHdgYZB85XyEYNN6cS0fxMWu1QTOrWfw(xGWGNtuRlWBt4eZfrUmBmeOagyeka7bpNOwxGNrWy17CWdl)lqyaKafWaJJdyp4HL)fimasWZjQ1f4PgmY1MoejnmosGhHAksnh8(HZ5Yiqh3HwXxWDWkp5Z7hoNlAyHXEgL1br6cUdwGx5di4PgmY1MoejnmosafWaJsfWEWZjQ1f4nPnx)TqbpS8VaHbqcuadmYsa7bpS8VaHbqcEorTUapIlerNOwxrHXvWtyCnw(acEd9oCalfOagyKfa2dEorTUapJGrHxee8WY)cegajqbkqbVDiLBDbyqoJIrwWOKZOyCjhPakye8c60YQno4j1dYAQIW5XiJ55e16kpHXv(kdaECzibWW4WIGNmApnbcEJopOsBUM3imFdZaJopjQkJdLZetBMkj8Vi9atCBiu4Q1fH6tLjUnqykdm68cewyEYzCyop5mkgzb5jvZBuSeOCPyCYazGrNhuQeV2qouEgy05jvZdkjhZBevBaJAhHnCeZZkUIoCE9mVruD6gQl1gWO2rydhX8MnnpHZ184iPl48GsHsKxi33Wvgidm68yPJescveoVpoBkMhPh(UM3h3SIVYJfMqqzkpVQlPQeNomdf55e16INxxcOxzaNOwx8Lmks6HVRSNcNpwgWjQ1fFjJIKE47kRSzA2nCgWjQ1fFjJIKE47kRSzYd3gWsD16kd4e16IVKrrsp8DLv2m5uIxy0kffcKOzaNOwx8Lmks6HVRSYMjE4WqxXGUI0ikWbSuxKbCIADXxYOiPh(UYkBM4LlJlP1ixDLNbCIADXxYOiPh(UYkBMgmkTPrBW3WmGtuRl(sgfj9W3vwzZKSwTUYaorTU4lzuK0dFxzLnttAZ1Fl0mqgy05XshjKeQiCE4oKcDEQnG5PsW8CI208mEE(o3e(xGRmGtuRloBshwks5YqHidm68K6zEQemVbFdZtIZZdQnuZZNksZJ4C1QT8SIREP5bvriLcnZ5feZJ4vEWOWHopvcMNutW8yH8IG55fCEHCmVwLG08KyBsYtg1AQPqNNtuRlMZZM557Ct4FbUYaorTU4SYMjJGrHxeKzBYwgf3f3iWlgxtriLcT8J7pCoxtR2qkp2Z4K2CDrrNOzaNOwxCwzZeXfIOtuRROW4kZLpGSjDlG7Gfpdm682lbZtD6gQ5PsOixslGZZ41iQ5HJKt0vEqIAqeR8KcPkuKN60nu5mNNkbZd2MtKIfb559rniIvEQemV3(88copw4MLMNtuRR8egx555umpQRsqAE8bxiw5ncVdI7qkZ5bvkIqy1wEJSBvEYO4eP88c5wTLhlCZsZZjQ1vEcJR5X7UqAEopptZ7JfonLN3gfDvaDEtApKNkbZtITjjpzuRPMcDEqkmiGWPW55e16ALbCIADXzLntexiIorTUIcJRmx(aY2BKzBY2jQTdJyHdgYhVuiV6cS01KIiewTfPUvlS8VaHLwANO2omIfoyiF8SygWjQ1fNv2mrCHi6e16kkmUYC5di7zh5wTjqMTjBARUADTM0gcSIn9NbCIADXzLntexiIorTUIcJRmx(aYU6OjICR2eiZ2KnTvxTUwvhncgfErWmGtuRloRSzI4cr0jQ1vuyCL5Yhq2CR2eiZ2KnTvxTUwC1lyNcNbYaJopPKPsYdQueHWQT8gz3kMZZ0rKN3hvfP5PDEYOwtn1GaZlKB1wEqL2qGvEJa6pVGsWkVFRsYdQJG88copifgeq4u48CkMxpN5r6wa3bRvEsjtL0HAEqLIiewTL3i7wXCEQempsx7qkhZZ45P0qmpxOs6Wnj5PsW8GT5ePyrW8mEEdwzCsOaZlSutK3oKcDEsSnj5PoDd18iDyP8vgWjQ1fF5nYEsBiWk20FgWjQ1fF5nYkBM(cdciCkCgWjQ1fF5nYkBMiUqeDIADffgxzU8bKnY5yrqEgWjQ1fF5nYkBMi9aQrU20HmGtuRl(YBKv2mzemw9opdm68E2GmHnneopOkcPuOZJ0fSPwx88M0EipvcM3BFEorTUYtyCDL3ZkcMNkbZBW3W8mEEByHuxTAlVPtZtGCEEqsDRYdQueHaZJiXPBiN58ujyE4i5enpsxWMADLNeKI5z8Ae18CHipvIR5zdYAQ6LUYaorTU4lVrwzZ0uesPqZSnzlJI7IBe4fJl831VfQ0s)dNZ1N6wfNueHaxu0jQ8YLmkUlUrGxmUM0MR)wOYlx)W5CzeJiq(IRozmwMfLw6XvDbw6At4eZfrUmBmCHL)fiSClT0YO4U4gbEX4At4eZfrUmBmuUZaorTU4lVrwzZKrWOWlcYSnz)dNZ10QnKYJ9moPnxxu0jAgy05TxcM3GVH5f0eI82WcPUqaDEFmVnSqQRwTLNNNO186zEqTHAEejoDd55fucw5fYTAlpvcMhlCZsZZjQ1vEcJRR82tH2QT80opyu4qN3i7qNxpZdQ0MR5fwQjYtLGumpNI5vDEqTHAEejoDd555fCEvNNtuBhMhuPneyL3iG(55fSdfW5jqhopTZZ08QwZ7JwTLxihHZZ18CHyLbCIADXxEJSYMjQdDSNXjT5AgWjQ1fF5nYkBMWFx)wOzaNOwx8L3iRSzAt4eZfrUmBmmdm68GsYTAlpO0UW86zEqPTaopJN3qZvb05bLak7LxHHk1f5f0uj5PsW8yHBwAEQt3qnpvcf5sAbmFLNuR51La68(iPhqEEWiblnVn3Q8cAQK8OD4Meb05jvYRP5n0ump1PBOYxzaNOwx8L3iRSzI0fg7zK0c4mGtuRl(YBKv2mfYXOP4aZLpGSvdg5AthIKgghjMTj7F4CUmc0XDOv8fChSK)hoNlAyHXEgL1br6cUdwzaNOwx8L3iRSzAsBU(BHMbCIADXxEJSYMjIlerNOwxrHXvMlFazp07WbS0mGtuRl(YBKv2mzemk8IGzGmGtuRl(I0TaUdwC2gb64o0kEgWjQ1fFr6wa3bloRSzAWO0MgTbFdZaJoVroSW86zEqzDqKMNXZZfbDO55fYr48cAQK8GkTHaR8gb0)kpw4c68e4u7DinpIeNUH88CnpvcMhwW51Z8ujyEtBtIMhxshkGZ7J5fYryMZZGrxiGopBMNkbZ73CEEWnYRruZd2W8SkpvcM3GbdlW86zEQemVroSW8(HZ5kd4e16IViDlG7GfNv2mrdlm2ZOSoisz2MSLrXDXnc8IX1K2qGvSPFPLwD6gQl1gWO2rydhpJJIvIZ1OAdO8Qt3qDP2ag1ocBillNrLbgDEJGkpUvBcmp1PBOM302KOCMZtLG5r6wa3bR86zEJCyH51Z8GY6GinpJNNOdI08ujELNkbZJ0TaUdw51Z8GkTHaR8gb0pZ5PsmEEB2oKNhosk1ZBKdlmVEMhuwheP5rK40nKNNkX184s6qbCEFmVqocNxqtLKNtuBhMN6cSuoZ5zZ8K1CU9f4kd4e16IViDlG7GfNv2mrCHi6e16kkmUYC5diB1fyPrAlJzBYwDbw6IgwySNrzDqKUWY)cewENO2omIfoyiNnJYt6wa3bRfnSWypJY6GiDndfIifjsC6ggvBazzs3c4oyTM0gcSIn9VO4GBfpd4e16IViDlG7GfNv2mjRvRlMTjBzuCxCJaVyCzeOJ7qR4slT60nuxQnGrTJWgYYsXOYaorTU4ls3c4oyXzLntHCmAkoWZaorTU4ls3c4oyXzLntBHof28k2ZOdbsBvcZ2K94sB1vRR1K2qGvSPFPLM0TaUdwRjTHaRyt)lko4wXzzOidKbCIADXxKUfWDWIZkBM(IUHJZqk0zaNOwx8fPBbChS4SYMPps5iDmR2YaorTU4ls3c4oyXzLntcBtIYJJqHWBdyPzaNOwx8fPBbChS4SYMPPrXVOB4mGtuRl(I0TaUdwCwzZKxeKRuxejUqKbYaorTU4lKZXIGC2ZMeYr4OdbsnfJF0hYaorTU4lKZXIGCwzZ0ao0uOJ9mkcjgCeMI(aNzBY(hoNlJyebYxC1jJXYYjd4e16IVqohlcYzLntFr3WXEgvjyelCaAMTj7F4CUmIreiFXvNmgBOq(F4CU(u3Q4KIie4IIorLwANO2omIfoyiF8SygWjQ1fFHCoweKZkBMKfsTj0wTf)cNRzaNOwx8fY5yrqoRSzIAYKjWOvrUmNGzaNOwx8fY5yrqoRSzI0fblL6kchNcFaZaorTU4lKZXIGCwzZKkbJH1Vdl44SPeKzBY(hoNlksgtGCEC2ucUcLLbCIADXxiNJfb5SYMPGnvaVdTksrExErWmqgWjQ1fFn7iY5yrqo7ztc5iC0HaPMIXp6dmBt2W4pCoxYCYyiC0i4cUdwzaNOwx81SJiNJfb5SYMPbCOPqh7zuesm4imf9boZ2Knm(dNZLmNmgchncUG7GvgWjQ1fFn7iY5yrqoRSz6l6go2ZOkbJyHdqZSnzlJI7IBe4fJlAyHXEgL1brQ8YO4U4gbEjN1K2qGvSP)mGtuRl(A2rKZXIGCwzZKSqQnH2QT4x4CLzBYgg)HZ5sMtgdHJgbxWDWkd4e16IVMDe5CSiiNv2mrnzYey0QixMtqMTjBy8hoNlzozmeoAeCb3bRmGtuRl(A2rKZXIGCwzZePlcwk1veoof(aYSnzdJ)W5CjZjJHWrJGl4oyLbCIADXxZoICoweKZkBMujymS(DybhNnLGmBt2)W5CrrYycKZJZMsWvOSmGtuRl(A2rKZXIGCwzZuWMkG3HwfPiVlViiZ2Knm(dNZLmNmgchncUG7Gvgidm68CIADXxd9oCalL9xy1yrVGMzBYEO3HdyPlyJRErWXZ4OYaorTU4RHEhoGLYkBMmcgNIg5mBt2)W5CzemofnYxWDWkdKbgDEqL2qGvEJa6pVNvBcmdm68K6kpEpG5Xnn0vRloZ5bDhMhXR84sCvrAEsnbZJHENNhUdR88PI08CbfDyOZJ4C1QT8GQiKsHopVGZtQjyESqErWvEJavcsdACmpvIXZZjQ1vEgpVqocNxqjyLNkbZBW3W8K488GAd188PI08ioxTAlpOkcPuOzopoI55)EhUYaorTU4Rzh5wTjq2gbJvVZz2MSjDlG7G1YiyS6D(IIom0YdJ)W5Cf0kfP8irIjeRqzzaNOwx81SJCR2eiRSzAsBiWk20FgWjQ1fFn7i3QnbYkBMMIqkfAMTjBzuCxCJaVyCH)U(TqL)hoNRp1TkoPicbUOOt0mGtuRl(A2rUvBcKv2m9fgeq4uyMTjBNO2omIfoyiF8YrAPDIA7Wiw4GH8XZO8eNRr1gq2Jkd4e16IVMDKB1MazLntgbJcViiZ2K9pCoxtR2qkp2Z4K2CDrrNOYt6wa3bR1K2qGvSP)ffhCR4JhkKw6F4CUMwTHuESNXjT56IIorzlNmGtuRl(A2rUvBcKv2m9fgeq4uyMTjBIZ1OAdi7rLbCIADXxZoYTAtGSYMPPiKsHMzBYwgf3f3iWlgx4VRFl0mGtuRl(A2rUvBcKv2mnfHuk0mBt2)W5C9PUvXjfriWffDIkVCjJI7IBe4fJRjT56VfQ0sdJ)W5CjZjJHWrJGlko4wXhposijuXOAdiRorTUwgbJcVi4sP(ouevBaL7mGtuRl(A2rUvBcKv2mr6buJCTPdzaNOwx81SJCR2eiRSzc)D9BHMbCIADXxZoYTAtGSYMjQdDSNXjT5kZ2Knm(dNZLmNmgchncUcLXSvksPHY0Onz)dNZ10QnKYJ9moPnxxu0jkB5WSvksPHY0OnmGWMRiBgZaorTU4Rzh5wTjqwzZ0xyqaHtHZaorTU4Rzh5wTjqwzZKrWy178mGtuRl(A2rUvBcKv2mfYXOP4aZLpGSvdg5AthIKgghjMTj7F4CUmc0XDOv8fChSK)hoNlAyHXEgL1br6cUdwzaNOwx81SJCR2eiRSzAsBU(BHMbCIADXxZoYTAtGSYMjIlerNOwxrHXvMlFazp07WbS0mGtuRl(A2rUvBcKv2mzemk8IGzGmWOZJHopPMG5Xc5fbZ7z1MaZaJopPUYJ3dyECtdD16IZCEq3H5r8kpUexvKMNutW8yO355H7WkpFQinpxqrhg68ioxTAlpOkcPuOZZl48KAcMhlKxeCL3iqLG0GghZtLy88CIADLNXZlKJW5fucw5PsW8g8nmpjoppO2qnpFQinpIZvR2YdQIqkfAMZJJyE(V3HRmGtuRl(Q6OjICR2eiBJGXQ35mBt2KUfWDWAzemw9oFrrhgA5HXF4CUcALIuEKiXeIvOSmGtuRl(Q6OjICR2eiRSzAkcPuOz2MSvxGLUWFx)wOlS8VaHLxgf3f3iWlgx4VRFlu5)HZ56tDRItkIqGlk6end4e16IVQoAIi3QnbYkBMMIqkfAMTjBzuCxCJaVyCTjCI5IixMngk)pCoxFQBvCsrecCrrNOzaNOwx8v1rte5wTjqwzZ0K2qGvSP)mGtuRl(Q6OjICR2eiRSz6lmiGWPWmBt2orTDyelCWq(4LJ0s7e12HrSWbd5JNr5joxJQnGShvgWjQ1fFvD0erUvBcKv2mzemk8IGmBt2)W5CnTAdP8ypJtAZ1ffDIkV6cS0fxMWu1QTOrWfw(xGWY7e12HrSWbd5JNXmGtuRl(Q6OjICR2eiRSzI0dOg5AthYaorTU4RQJMiYTAtGSYMj831VfkZ2K9pCoxgXicKV4QtgJnui)4(dNZ1N6wfNueHaxu0jAgWjQ1fFvD0erUvBcKv2mTjCI5IixMngYSnz)dNZ1N6wfNueHaxu0jQ0slJI7IBe4fJl831VfAgWjQ1fFvD0erUvBcKv2mzemw9opd4e16IVQoAIi3QnbYkBMc5y0uCG5Yhq2QbJCTPdrsdJJeZ2K9pCoxgb64o0k(cUdwY)dNZfnSWypJY6GiDb3bRmGtuRl(Q6OjICR2eiRSzAsBU(BHMbCIADXxvhnrKB1MazLntexiIorTUIcJRmx(aYEO3HdyPzaNOwx8v1rte5wTjqwzZKrWOWlcMbYaJoVN6fStHZ7z1MaZaJopPUYJ3dyECtdD16IZCEq3H5r8kpUexvKMNutW8yO355H7WkpFQinpxqrhg68ioxTAlpOkcPuOZZl48KAcMhlKxeCL3iqLG0GghZtLy88CIADLNXZlKJW5fucw5PsW8g8nmpjoppO2qnpFQinpIZvR2YdQIqkfAMZJJyE(V3HRmGtuRl(IB1MazBemw9oNzBYM0TaUdwlJGXQ35lk6Wqlpm(dNZvqRuKYJejMqScLLbgDEsjtL0HAEs5hZ5Xs)D9BHMNXZZfbDO55XL4QIueELNuYuj5jLFmNhl931VfAEgppUexvKIW5zZ8mnVGDOaoVGoxX8GK6wLhuPicbMhrIt3W8KlBHR8ckbR8ujyEd(gMhxDQYZJ4C1QT8yP)U(TqZlOPsYdsQBvEqLIieyEorTDOCNxtZlOeSY7JIoyESyEsnXicKNNCzZ8yP)U(TqZZ45rCUMxqjyLNkbZBW3W8K488yrPkuKNutmIa5mNNPJipVpQksZt78c5yEQempiPUv5bvkIqG5nP9qEMMxx5jLfoXCrEpz2yOCVYaorTU4lUvBcKv2mnfHuk0mBt2QlWsx4VRFl0fw(xGWYlJI7IBe4fJl831VfQ8Y14QUalDTjCI5IixMngUWY)cewAP)HZ5YigrG8fxDYySmlkT0)W5C9PUvXjfriWffDIk3zGrNNuw4eZf59KzJH5z88CrqhAEECjUQifHxzaNOwx8f3QnbYkBMMIqkfAMTjB1fyPRnHtmxe5YSXWfw(xGWYlJI7IBe4fJRnHtmxe5YSXq5)HZ56tDRItkIqGlk6endm68KsMkPd18KYpMZtLG5n4ByEJqHCnpLAippTZJlXvfP5588g8c68GkT56VfkppNNNSMZTVax5jLmvsEs5hZ5PsW8g8nmVUeqNhxIRks55bvAZ1Fl08ujUMxWouaNNSqnpvcoKNR5XOuvkYtQjgrG5XvNmgFLhucBorkwemVpQbrSYJlXvfPwTLhuPnx)TqZlOPsYJrPQuKNutmIa555fCEmkvzX8KAIreippJNhFWfcMZ7hQ5XOuvkYtXcMNN259X8(OQinpRYBOPyECtdD16INNCPsW8KyBsqAEs5xEW(GVH5zCMZtLG5n0umptZtGEXZt7GofMNhJsvPqUx5b1MsSAlpUexvKMxx5bvAZ1Fl08mEEC1eI8884dUqK3MBfZ5X78mEEvR5rCQvB55)ouZdQnux5j1empwiViyEgppT78cI(y5PDEbDk1lnpyu4qB1wEqsDRYdQueHaZdQIqkf6vgWjQ1fFXTAtGSYMPPiKsHMzBYwgf3f3iWlgxtAZ1Flu5)HZ56tDRItkIqGlk6evE5ACvxGLU2eoXCrKlZgdxy5FbclT0)W5CzeJiq(IRozmwMfL7mqgy05Xs5CSiyEHCFdZBNtnKN3h68OT6Q11kd4e16IV4wTjqwzZeXfIOtuRROW4kZLpGSrohlcYz2MShxARUADTM0gcSIn9NbCIADXxCR2eiRSzI4cr0jQ1vuyCL5Yhq2ZoICoweKZSnztB1vRR1K2qGvSP)mqgWjQ1fFXTAtGSYMPjTHaRyt)zGrNNuYuj5bvkIqy1wEJSBvEEbNNR5jqNR5jN8uNUHkN58GuyqaHtHZRqeMNN259X8c5iCEbnvsEsSnjinpzuRPMcDEAN3GpgMhpKI5bDhMhXR8MMM3Vvj5zfx9sZdsHbbeofMNNvANNNh3QnbMhuPicHvB5nYUvR8EQtvR2YlOPsYtLqrmp1PBOYzopifgeq4u48eOVd55PsW8eDW8KrTMAk05nnHaP5rBbMNxW5z88c5iCEDLhPBbChSYtU8coVrOqUM3GpMvB5XdPyEvR5PDEbDUI5bj1TkpOsrecmpIeNUHC5oVGMkjVMMxqtL0HAEqLIiewTL3i7wTYaorTU4lUvBcKv2m9fgeq4uyMTjBNO2omIfoyiF8YrAPDIA7Wiw4GH8XZO8eNRr1gq2Js(F4CUMwTHuESNXjT56IIorzz5KbgDE7PqB1wEANNSUf5rK40nKNxpZdQnuZB2088cAvIvB5z8Ae18c2uvsEMUYdkjhZtLGd5588uji05r6bCLbCIADXxCR2eiRSzYiyu4fbz2MS)HZ5AA1gs5XEgN0MRlk6end4e16IV4wTjqwzZePhqnY1MoKbCIADXxCR2eiRSzc)D9BHMbgDEJSdDE9mpOsBUMNXZlKJW55tfP55crEq1QnKYZRN5bvAZ18isC6gYZtIVdZ7JyLxihHZZl48ujifZZ41iQ55e12H5bvAdbw5ncO)8ujUMhPdfW5THfsDfZBOP4kV9smEEgpVUeqNNNhFWfI82CRYZ3CR4AEdHc1KjW8uNUHkN58CEEJSdDE9mpOsBUMNXRruZt7opBqMt0zOyLbCIADXxCR2eiRSzI6qh7zCsBUYSnzpUorTUwtAdbwXM(xwfNcBtIk)gTdl4O34AsBiWk20)IIdUvC2Jkdm68GuyqaHtHZZ45fYr48CEEIoyEYOwtnf68MMqG088n3kUMNCYtD6gQ8vEsjjyLxi3QT8GkfriSAlVr2TI58mDe5555nGWw4qEBUv5PDEHCmpvcMNvC1lnpifgeq4u48WDyLNV5wX18884wTjW8uNUHkZ5HCziXCHa68cAQK8eDW8gCUIuOxzaNOwx8f3QnbYkBM(cdciCkmZ2KnX5AuTbK9OKwANO2omIfoyiF8mMbgDEszHtmxK3tMngMNXZlKJW5fucw5PsqkoI8888GK6wLhuPicbMNmAtYZjQTdZtUSfUYRlb05fucw5zAEeVY7J5XL4QIuewUx5TxIXZZ4555XhCHipTZBaHTWH82CRYZQ8gAUMh30qxTU4R8yH6G5n4CfPqNNa9INN2bDkmpVqUvB5zAEbLGvE(o3e(xGR8KssWkVqUvB59KjmvTAlpPMG55fCEs8DwTLNxTkbP5PoDd18k0PFOzopthrEECHTjrfqN3hvfP5PDEHCmpP8lVGsWkpFNBc)lqMZZ55PsW84iPl48uNUHAEWnYRruZ7JfonnVjThYJlXvfPwTLNkbZBWTkp1PBOUYaorTU4lUvBcKv2mTjCI5IixMngYSnz)dNZ1N6wfNueHaxu0jQ0slJI7IBe4fJl831VfQ0s7e12HrSWbd5JNr5vxGLU4YeMQwTfncUWY)ceod4e16IV4wTjqwzZKrWy178mGtuRl(IB1MazLntHCmAkoWC5diB1GrU20HiPHXrIzBY(hoNlJaDChAfFb3bl5)HZ5IgwySNrzDqKUG7GvgWjQ1fFXTAtGSYMPjT56VfAgWjQ1fFXTAtGSYMjIlerNOwxrHXvMlFazp07WbS0mGtuRl(IB1MazLntgbJcViygidm68KsMkjpPSWjMlY7jZgdzoVroSW86zEqzDqKMhxshkGZ7J5fYr48O2MenVpoBkMNkbZtklCI5I8EYSXW8i9WVZtUSfUYlOPsYdkYtQjgrG888copppiPUv5bvkIqGY9kpPKeSYJL(763cnpJNxpN5r6wa3blMZBKdlmVEMhuwheP5r8kpxW78(yEHCeoVrOqUMxqtLKhuKNutmIa5RmGtuRl(sDbwAK2Yytdlm2ZOSoisz2MSvxGLU2eoXCrKlZgdxy5Fbcl)pCoxgXicKV4QtgJnuiVC9dNZ1N6wfNueHaxu0jQ0sRUalDH)U(Tqxy5FbclpPBbChSw4VRFl0ffhCR4SmX5AuTbuUZaJopPKPs6qnpPSWjMlY7jZgdzoVroSW86zEqzDqKMhxshkGZ7J5fYr48(4SPyEEbDEFBBdP5r6wa3bR8Klw6VRFluMZdkThqnVN20bMZBKDOZRN5bvAZv5oVMMxqjyL3ihwyE9mpOSoisZZ455)ouZt78OOtKKNCYJiXPBiFLbCIADXxQlWsJ0wgRSzIgwySNrzDqKYSnzpUQlWsxBcNyUiYLzJHlS8VaHLxUuxGLUWFx)wOlS8VaHLN0TaUdwl831Vf6IIdUvCwM4CnQ2akT0QlWsxKEa1ixB6Wcl)lqy5jDlG7G1I0dOg5AthwuCWTIZYeNRr1gqPLwDbw6I6qh7zCsBUUWY)cewEs3c4oyTOo0XEgN0MRlko4wXzzIZ1OAdO0stK40nKhNuNOwxUy8mUybYnqbkaa]] )


end
