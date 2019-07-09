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
        desc = "This sets the |cFFFFD100rotation.X|r value, selecting between one of three integrated SimC builds.",
        type = "select",
        width = 1.5,
        values = {
            standard = "Standard",
            no_ice_lance = "No Ice Lance",
            frozen_orb = "Frozen Orb"
        }
    } )

    
    spec:RegisterPack( "Frost Mage", 20190709.1545, [[dO0QJbqiLc8ibjBcPQpPuunkKeofsIEfHYSqsDlir1UuYVqQmmLICmivldsKNPuOPrqLRji12Ge03iOQgNsb15GeQ1rqvAEeQ4EeyFeuoiKO0crIEibvXeHeOUiHk1grs6JeQsJKqLuNKqvTsb1mHef3KqLyNeKFQuqgkKawQsr5PQQPcPCvcvs(kHQyVi(ljdwLdl1IH4Xqnzv5YGnl0NvQgnP40uwnKa51cIzt0Tfy3I(TKHJuwokphvtNQRtQ2oP03jKXdjKZJewVsP5djTFftqNGg5)AhicHsBcDu8Me(BcfVqp0HEtHw4iFNcAa5tRXH07a5NDaq(uLvCFoXLEhiFAnfYQFe0iFEPZWa5RXDACHx6OB3Cn6ilCfqh3c0LTBvIzD0PJBby6iFeDt6IFsqi)x7ariuAtOJI3KWFtO4f6Hw4qXBCJKFR7Akg5)TaHhYxJ9Eqsqi)hWXKFOMJQSI7ZjU07WeouZPXDACHx6OB3Cn6ilCfqh3c0LTBvIzD0PJBby6MWHAUW6skMdft9CO0MqhfphkFo0dTWRWf6j8eouZj8OPZDGl8oHd1CO85exXH52C3caLxQNbB(CwYDOFZvX52CVz7GVClauEPEgS5Zfl2CYM7ZXbCLV5eEqbpNoV3H1eouZHYNtCby7WCuLvCFoXLEhMdLffaLHVMWHAou(CBgeuAH5WvjFLOCHPallNvPHviYM7ZH1a4q4lYxACNtqJ8JLIB5UeiOrecDcAKpKnIeEekjFmZCGzn5JRs(kr5YWGklT9Ib9JI5OFUhGOhJlrw6aJRWAmPCPtJ8BSBvs(gguzPTjoriuIGg5dzJiHhHsYVXUvj5JBPu1y3QujnUt(sJ7QSdaYpwkGZHedCIteAJe0i)g7wLKFKvBHuvmeYhYgrcpcLeNiKWrqJ8HSrKWJqj5JzMdmRjFAmqRAh)wOVaKkrkPph9ZHOhJlewBPkYaylSyqJDYVXUvj5hL6mgfeNiuOjOr(q2is4rOK8XmZbM1KFJDtlOGecmGpNWMdLMdvuNRXUPfuqcbgWNtyZH(C0phU5UYTayobZTjYVXUvj5JiTTBB2J4eHqHe0iFiBej8ius(yM5aZAYhrpgxrl3bgxvrvKvCFXGg7Zr)C4QKVsuUISAlKQIHSyqqBjFoHnxONdvuNdrpgxrl3bgxvrvKvCFXGg7ZjyouI8BSBvs(gguYoXaXjcj8jOr(q2is4rOK8XmZbM1KpU5UYTayobZTjYVXUvj5JiTTBB2J4eH2We0iFiBej8ius(yM5aZAYNgd0Q2XVf6laPsKs6KFJDRsYpk1zmkioriumbnYhYgrcpcLKpMzoWSM8r0JXfcRTufzaSfwmOX(C0phvmhngOvTJFl0xrwXDKs6ZHkQZ9ae9yCrRXHapLHHfdcAl5ZjS5aueG1Dq5wamNyZ1y3QCzyqj7edlN1AbPYTayoQK8BSBvs(rPoJrbXjcH(MiOr(n2TkjFCfaUI7flG8HSrKWJqjXjcHo6e0i)g7wLKpGujsjDYhYgrcpcLeNie6OebnYhYgrcpcLKFJDRsYN1uOQOkYkUt(w6aJPtZvwK8r0JXv0YDGXvvufzf3xmOXUauI8T0bgtNMRSGa4zTdKp6KpMzoWSM8FaIEmUO14qGNYWWsNgXjcH(gjOr(n2TkjFePTDBZEKpKnIeEekjori0focAKFJDRsY3WGklTn5dzJiHhHsItec9qtqJ8HSrKWJqj53y3QK8D7bCVybkC9aue5JzMdmRjFe9yCzykuAbl5RxjkNJ(5q0JXftpbvfv0kraB9krj5NDaq(U9aUxSafUEakI4eHqhfsqJ8HSrKWJqj53y3QK8Pv4qaNBBHNcxb0092TkvpqRHbYhZmhywt(i6X4YWuO0cwYxVsuoh9ZHOhJlMEcQkQOvIa26vIsYp7aG8Pv4qaNBBHNcxb0092TkvpqRHbItecDHpbnYVXUvj5hzf3rkPt(q2is4rOK4eHqFdtqJ8HSrKWJqj53y3QK8XTuQASBvQKg3jFPXDv2ba5huAHaiDItecDumbnYVXUvj5Byqj7edKpKnIeEekjoXjFGZHedCcAeHqNGg5dzJiHhHsYhZmhywt(i6X4IPNGQIkALiGTELOCourDUg7MwqbjeyaFoHn3gj)g7wLKFSW6C4P6TaZCqHaDaXjcHse0iFiBej8ius(yM5aZAYVXUPfuqcbgWNtCMl0Zr)CuXCi6X4YWgwc8f3BCiZjocMd95qf152G58wcPV2Ln2APItZcbwq2is4nhvoh9ZHRs(kr5kYQTqQkgYIbbTL85e2COVP5OFUnyUg7wLRiR2cPQyillvrPTRXNJ(52zLE(uDbRiR2cPQyilge0wYNtWCBI8BSBvs(bqqXOqvrLuhBp1JbDaN4eH2ibnYhYgrcpcLKpMzoWSM8PI58wcPV2Ln2APItZcbwq2is4nh9ZHOhJldByjWxCVXHmNG5c9C0phvmhIEmUqyTLQidGTWIbn2NdvuNJgd0Q2XVf6laPsKs6ZrLZrLZHkQZrfZrfZ1y30ckiHad4ZjS524COI6CBWCElH0x7YgBTuXPzHaliBej8MJkNJ(5OI5OXaTQD8BH(kYQTqQkgYCOI6C7SspFQUGvKvBHuvmKfdcAl5ZjS5c9Cu5Cuj53y3QK8rKv9uvu5AafKqafeNiKWrqJ8HSrKWJqj5JzMdmRjFe9yCX0tqvrfTseWwVsuohQOoxJDtlOGecmGpNWMBJKFJDRsYNMoZIuy5Ucr2CN4eHcnbnYhYgrcpcLKpMzoWSM8r0JXftpbvfv0kraB9kr5COI6Cn2nTGcsiWa(CcBUns(n2TkjFMrJMeuwQ40AmqCIqOqcAKpKnIeEekj)g7wLKpUsmKoRD4PIYoaiFmZCGzn5JOhJlMEcQkQOvIa26vIsYxAjOWpYhfsCIqcFcAKpKnIeEekjFmZCGzn5JOhJlgGdrcCUkwmmS0Pr(n2TkjFxdO0tKspFQyXWaXjcTHjOr(q2is4rOK8XmZbM1KpIEmUy6jOQOIwjcyRxjkNdvuNRXUPfuqcbgWNtyZTrYVXUvj5lQyYNwWsfd4v2jgioXj)SuMuXTCxce0icHobnYhYgrcpcLKpMzoWSM8XvjFLOCzyqLL2EXG(rXC0p3dq0JXLilDGXvynMuU0Pr(n2TkjFddQS02eNiekrqJ8HSrKWJqj5JzMdmRjFVLq6laPsKs6liBej8MJ(5OXaTQD8BH(cqQePK(C0phIEmUqyTLQidGTWIbn2j)g7wLKFuQZyuqCIqBKGg5dzJiHhHsYhZmhywt(0yGw1o(TqFTlBS1sfNMfcmh9ZHOhJlewBPkYaylSyqJDYVXUvj5hL6mgfeNiKWrqJ8HSrKWJqj53y3QK8XTuQASBvQKg3jFPXDv2ba5dCoKyGtCIqHMGg53y3QK8JSAlKQIHq(q2is4rOK4eHqHe0iFiBej8ius(yM5aZAYVXUPfuqcbgWNtyZHsZHkQZ1y30ckiHad4ZjS5qFo6Nd3Cx5wamNG52e53y3QK8rK22Tn7rCIqcFcAKpKnIeEekjFmZCGzn5JOhJROL7aJRQOkYkUVyqJ95OFoVLq6lonP5UL7kddliBej8MJ(5ASBAbfKqGb85e2COt(n2TkjFddkzNyG4eH2We0i)g7wLKpUcaxX9Ifq(q2is4rOK4eHqXe0iFiBej8ius(yM5aZAYhrpgxg2WsGV4EJdzobZf65OFUnyoe9yCHWAlvrgaBHfdASt(n2TkjFaPsKs6eNie6BIGg5dzJiHhHsYhZmhywt(i6X4cH1wQIma2clg0yFourDoAmqRAh)wOVaKkrkPt(n2Tkj)DzJTwQ40SqaItecD0jOr(n2TkjFddQS02KpKnIeEekjori0rjcAKpKnIeEekj)g7wLKVBpG7flqHRhGIiFmZCGzn5JOhJldtHslyjF9kr5C0phIEmUy6jOQOIwjcyRxjkj)SdaY3ThW9IfOW1dqreNie6BKGg5dzJiHhHsYVXUvj5tRWHao32cpfUcOP7TBvQEGwddKpMzoWSM8r0JXLHPqPfSKVELOCo6Ndrpgxm9euvurRebS1ReLKF2ba5tRWHao32cpfUcOP7TBvQEGwddeNie6chbnYVXUvj5hzf3rkPt(q2is4rOK4eHqp0e0iFiBej8ius(n2TkjFClLQg7wLkPXDYxACxLDaq(bLwiasN4eHqhfsqJ8BSBvs(gguYoXa5dzJiHhHsItCYpwkGZHedCcAeHqNGg5dzJiHhHsYhZmhywt(i6X4IPNGQIkALiGTELOCo6N7bi6X4IwJdbEkddRxjkNdvuNRXUPfuqcbgWNtyZTrYVXUvj5hlSohEQElWmhuiqhqCIqOebnYhYgrcpcLKpMzoWSM8BSBAbfKqGb85eN5c9C0p3dq0JXfTghc8uggwVsuoh9ZHRs(kr5kYQTqQkgYIbbTL85e2CHEo6NBdMRXUv5kYQTqQkgYYsvuA7A85OFUDwPNpvxWkYQTqQkgYIbbTL85em3Mi)g7wLKFaeumkuvuj1X2t9yqhWjorOnsqJ8HSrKWJqj5JzMdmRjFAmqRAh)wOVISAlKQIHmhQOo3oR0ZNQlyfz1wivfdzXGG2s(CcBUqt(n2TkjFezvpvfvUgqbjeqbXjcjCe0iFiBej8ius(yM5aZAYhrpgxm9euvurRebS1ReLZr)Cparpgx0ACiWtzyy9kr5COI6Cn2nTGcsiWa(CcBUns(n2TkjFA6mlsHL7kezZDItek0e0iFiBej8ius(yM5aZAYhrpgxm9euvurRebS1ReLZr)Cparpgx0ACiWtzyy9kr5COI6Cn2nTGcsiWa(CcBUns(n2TkjFMrJMeuwQ40AmqCIqOqcAKpKnIeEekj)g7wLKpUsmKoRD4PIYoaiFmZCGzn5JOhJlMEcQkQOvIa26vIY5OFUhGOhJlAnoe4PmmSELOK8Lwck8J8rHeNiKWNGg5dzJiHhHsYhZmhywt(i6X4Ib4qKaNRIfddlDAKFJDRsY31ak9eP0ZNkwmmqCIqBycAKpKnIeEekjFmZCGzn5JOhJlMEcQkQOvIa26vIY5OFUhGOhJlAnoe4PmmSELOCourDUg7MwqbjeyaFoHn3gj)g7wLKVOIjFAblvmGxzNyG4eN89wcPRyfncAeHqNGg5dzJiHhHsYhZmhywt(ElH0x7YgBTuXPzHaliBej8MJ(5q0JXLHnSe4lU34qMtWCHEo6NJkMdrpgxiS2svKbWwyXGg7ZHkQZ5TesFbivIusFbzJiH3C0phUk5ReLlaPsKs6lge0wYNtCMd3Cx5wamhvs(n2TkjFMEcQkQOvIagXjcHse0iFiBej8ius(yM5aZAYFdMZBjK(Ax2yRLkonleybzJiH3C0phvmN3si9fGujsj9fKnIeEZr)C4QKVsuUaKkrkPVyqqBjFoXzoCZDLBbWCOI6CElH0x4kaCf3lwWcYgrcV5OFoCvYxjkx4kaCf3lwWIbbTL85eN5Wn3vUfaZHkQZ5TesFXAkuvufzf3xq2is4nh9ZHRs(kr5I1uOQOkYkUVyqqBjFoXzoCZDLBbWCOI6CynnBh4QiRXUvzlNtyZH(cfphvs(n2TkjFMEcQkQOvIagXjo5huAHaiDcAeHqNGg5dzJiHhHsYhZmhywt(i6X4YWGkklGVELOK8BSBvs(ggurzbCItCYNgdWvas7e0icHobnYVXUvj53mCNGYshKsa7KpKnIeEekjoriuIGg53y3QK8f1oWuGecG0Bj5dzJiHhHsIteAJe0i)g7wLKFGXyftzb9oq(q2is4rOK4eHeocAKFJDRsYNw5wLKpKnIeEekjorOqtqJ8BSBvs(rwXDKs6KpKnIeEekjoXj)UacAeHqNGg53y3QK8JSAlKQIHq(q2is4rOK4eHqjcAKFJDRsYhrAB32Sh5dzJiHhHsIteAJe0iFiBej8ius(n2TkjFClLQg7wLkPXDYxACxLDaq(aNdjg4eNiKWrqJ8BSBvs(4kaCf3lwa5dzJiHhHsItek0e0i)g7wLKVHbvwABYhYgrcpcLeNiekKGg5dzJiHhHsYhZmhywt(0yGw1o(TqFbivIusFourDoe9yCHWAlvrgaBHfdASph9ZrfZrJbAv743c9vKvChPK(C0phvmhIEmUmSHLaFX9ghYCIZCc3COI6CBWCElH0x7YgBTuXPzHaliBej8MJkNdvuNJgd0Q2XVf6RDzJTwQ40SqG5OsYVXUvj5hL6mgfeNiKWNGg5dzJiHhHsYhZmhywt(i6X4kA5oW4QkQISI7lg0yN8BSBvs(gguYoXaXjcTHjOr(n2TkjFwtHQIQiR4o5dzJiHhHsItecftqJ8BSBvs(asLiL0jFiBej8iusCIqOVjcAKFJDRsYFx2yRLkonleG8HSrKWJqjXjcHo6e0i)g7wLKpUsqvrfUKpYhYgrcpcLeNie6OebnYhYgrcpcLKFJDRsY3ThW9IfOW1dqrKpMzoWSM8r0JXLHPqPfSKVELOCo6Ndrpgxm9euvurRebS1ReLKF2ba572d4EXcu46bOiItec9nsqJ8HSrKWJqj53y3QK8Pv4qaNBBHNcxb0092TkvpqRHbYhZmhywt(i6X4YWuO0cwYxVsuoh9ZHOhJlMEcQkQOvIa26vIsYp7aG8Pv4qaNBBHNcxb0092TkvpqRHbItecDHJGg53y3QK8JSI7iL0jFiBej8iusCIqOhAcAKpKnIeEekj)g7wLKpULsvJDRsL04o5lnURYoai)GsleaPtCIqOJcjOr(n2TkjFddkzNyG8HSrKWJqjXjo5JRs(krjNGgri0jOr(n2Tkj)D9M9Sovvu1Bbw5AiFiBej8iusCIqOebnYVXUvj5BykuAbl5KpKnIeEekjorOnsqJ8BSBvs(bgJvmLf07a5dzJiHhHsItes4iOr(q2is4rOK8XmZbM1KpngOvTJFl0xrwTfsvXqMdvuNZTaq5L6zWCcBo030CInhU5UYTayo6NZTaq5L6zWCIZCO0Mi)g7wLKptpbvfv0kraJ4eHcnbnYhYgrcpcLKpMzoWSM89wcPVy6jOQOIwjcyliBej8MJ(5ASBAbfKqGb85emh6Zr)C4QKVsuUy6jOQOIwjcyROUuQyawtZ2bLBbWCIZC4QKVsuUISAlKQIHSyqqBjN8BSBvs(4wkvn2TkvsJ7KV04Uk7aG89wcPRyfnItecfsqJ8HSrKWJqj5JzMdmRjFAmqRAh)wOVmmfkTGL85qf15ClauEPEgmN4m3g3e53y3QK8PvUvjXjcj8jOr(n2TkjFDoOmhc4KpKnIeEekjorOnmbnYhYgrcpcLKF2ba5tRWHao32cpfUcOP7TBvQEGwddKFJDRsYNwHdbCUTfEkCfqt3B3Qu9aTggioriumbnYVXUvj5JiR6PI6mkiFiBej8iusCIqOVjcAKFJDRsYhbyCGfIL7KpKnIeEekjori0rNGg53y3QK8L2UgNRqbP)2dG0jFiBej8iusCIqOJse0i)g7wLKF0yaISQh5dzJiHhHsItec9nsqJ8BSBvs(DIbUZAPc3sj5dzJiHhHsItCY)bXwx6e0icHobnYVXUvj5Jl90bgNgiLKpKnIeEekjoriuIGg5dzJiHhHsYhZmhywt(0yGw1o(TqFfL6mgfZr)CBWCi6X4kA5oW4QkQISI7lg0yN8BSBvs(gguYoXaXjcTrcAKpKnIeEekj)g7wLKpULsvJDRsL04o5lnURYoaiFCvYxjk5eNiKWrqJ8HSrKWJqj5JzMdmRj)g7MwqbjeyaFoHn3gNJ(58wcPVIma2A5UI1wUGSrKWBourDUg7MwqbjeyaFoHnNWr(n2TkjFClLQg7wLkPXDYxACxLDaq(DbeNiuOjOr(q2is4rOK8XmZbM1KpR82TkxrwTfsvXqi)g7wLKpULsvJDRsL04o5lnURYoai)yP4wUlbItecfsqJ8HSrKWJqj5JzMdmRjFw5TBvUYszyqj7edKFJDRsYh3sPQXUvPsACN8Lg3vzhaKFwktQ4wUlbItes4tqJ8HSrKWJqj5JzMdmRjFw5TBvU4ENVM9i)g7wLKpULsvJDRsL04o5lnURYoaiFUL7sG4eN85wUlbcAeHqNGg5dzJiHhHsYhZmhywt(4QKVsuUmmOYsBVyq)Oyo6N7bi6X4sKLoW4kSgtkx60i)g7wLKVHbvwABItecLiOr(q2is4rOK8XmZbM1KV3si9fGujsj9fKnIeEZr)C0yGw1o(TqFbivIusFo6NJkMBdMZBjK(Ax2yRLkonleybzJiH3COI6Ci6X4YWgwc8f3BCiZjoZjCZHkQZHOhJlewBPkYaylSyqJ95OsYVXUvj5hL6mgfeNi0gjOr(q2is4rOK8XmZbM1KV3si91USXwlvCAwiWcYgrcV5OFoAmqRAh)wOV2Ln2APItZcbMJ(5q0JXfcRTufzaSfwmOXo53y3QK8JsDgJcItes4iOr(q2is4rOK8XmZbM1KpngOvTJFl0xrwXDKs6Zr)Ci6X4cH1wQIma2clg0yFo6NJkMBdMZBjK(Ax2yRLkonleybzJiH3COI6Ci6X4YWgwc8f3BCiZjoZjCZrLKFJDRsYpk1zmkiorOqtqJ8HSrKWJqj53y3QK8XTuQASBvQKg3jFPXDv2ba5dCoKyGtCIqOqcAKFJDRsYpYQTqQkgc5dzJiHhHsItes4tqJ8HSrKWJqj5JzMdmRj)g7MwqbjeyaFoHnhknhQOoxJDtlOGecmGpNWMd95OFoCZDLBbWCcMBtZr)Ci6X4kA5oW4QkQISI7lg0yFoXzouI8BSBvs(isB72M9iorOnmbnYhYgrcpcLKpMzoWSM8r0JXv0YDGXvvufzf3xmOXo53y3QK8nmOKDIbItecftqJ8BSBvs(4kaCf3lwa5dzJiHhHsItec9nrqJ8BSBvs(asLiL0jFiBej8iusCIqOJobnYhYgrcpcLKpMzoWSM83G5ASBvUISAlKQIHSSufL2UgFo6NBNv65t1fSISAlKQIHSyqqBjFobZTjYVXUvj5ZAkuvufzf3jori0rjcAKpKnIeEekjFmZCGzn5JBURClaMtWCBAourDUg7MwqbjeyaFoHnh6KFJDRsYhrAB32ShXjcH(gjOr(q2is4rOK8XmZbM1KpIEmUqyTLQidGTWIbn2NdvuNJgd0Q2XVf6laPsKs6ZHkQZ1y30ckiHad4ZjS5qFo6NZBjK(IttAUB5UYWWcYgrcpYVXUvj5VlBS1sfNMfcqCIqOlCe0i)g7wLKVHbvwABYhYgrcpcLeNie6HMGg5dzJiHhHsYVXUvj572d4EXcu46bOiYhZmhywt(i6X4YWuO0cwYxVsuoh9ZHOhJlMEcQkQOvIa26vIsYp7aG8D7bCVybkC9aueXjcHokKGg5dzJiHhHsYVXUvj5tRWHao32cpfUcOP7TBvQEGwddKpMzoWSM8r0JXLHPqPfSKVELOCo6Ndrpgxm9euvurRebS1ReLKF2ba5tRWHao32cpfUcOP7TBvQEGwddeNie6cFcAKFJDRsYpYkUJusN8HSrKWJqjXjcH(gMGg5dzJiHhHsYVXUvj5JBPu1y3QujnUt(sJ7QSdaYpO0cbq6eNie6OycAKFJDRsY3WGs2jgiFiBej8iusCItCYxlW4wLeHqPnHokEtOquk0RnTHdnkK8f1S0YDo5l(b0kMdV5qh95ASBvoN04oFnHjFonatecfkCKpnwfnjq(HAoQYkUpN4sVdt4qnNg3PXfEPJUDZ1OJSWvaDClqx2UvjM1rNoUfGPBchQ5cRlPyoum1ZHsBcDu8CO85qp0cVcxONWt4qnNWJMo3bUW7eouZHYNtCfhMBZDlauEPEgS5Zzj3H(nxfNBZ9MTd(YTaq5L6zWMpxSyZjBUphhWv(Mt4bf8C68Ehwt4qnhkFoXfGTdZrvwX95ex6Dyouwuaug(AchQ5q5ZTzqqPfMdxL8vIYfMcSSCwLgwHiBUphwdGdHVMWt4qnN4gfbyDhEZHaXIbZHRaK2Ndb2TKVMdLfJbAoFUSsuUMMfe1LZ1y3QKpxLskwt4qnxJDRs(IgdWvas7cIYMhYeouZ1y3QKVOXaCfG0UycOlw1BchQ5ASBvYx0yaUcqAxmb0167bq6TBvoHBSBvYx0yaUcqAxmb01mCNGYshKsa7t4g7wL8fngGRaK2ftaDC9GGkvIAhykqcbq6TCchQ5ASBvYx0yaUcqAxmb0XZMgxt5kU3oFc3y3QKVOXaCfG0UycOlWySIPSGEhMWn2Tk5lAmaxbiTlMa6OvUv5eUXUvjFrJb4kaPDXeqxKvChPK(eEchQ5e3OiaR7WBoqlWOyo3cG5CnWCn2l2CgFUwBBYgrcRjCJDRsUaCPNoW40aPCchQ5e)4CUgyUGEhMttZNJQfvNRJoWMd3C3Y95SK7D6ZrvPoJrb1ZjcMd35Cpq2umNRbMt8XWCOmDIH568nNohMRCnaBon2UM5OXSIzofZ1y3QK65S4CT22KnIewt4g7wLCXeqNHbLStmqTffqJbAv743c9vuQZyuq)gGOhJROL7aJRQOkYkUVyqJ9jCJDRsUycOd3sPQXUvPsACN6Sdab4QKVsuYNWHAo00aZ5nBh85CnmGRPKV5mEU5(CakQX(Aokbxea5CBeLh658MTdoN65CnWCplgbgKyGphc4IaiNZ1aZ9rBUoFZHYwI75ASBvoN04oFUMbZXAxdWMJh0s5AoX1LiqlWOEoQYayRL7ZTzTLZrJbrGXNtNB5(COSL4EUg7wLZjnUphVQeyZ185mFoeiHO5852zq7skMlYQG5CnWCASDnZrJzfZCkMJsPTDBZEZ1y3QCnHBSBvYftaD4wkvn2TkvsJ7uNDaiOlGAlkOXUPfuqcbgWf2gP3BjK(kYayRL7kwB5cYgrcpurTXUPfuqcbgWfMWnHBSBvYftaD4wkvn2TkvsJ7uNDaiiwkUL7sGAlkGvE7wLRiR2cPQyit4g7wLCXeqhULsvJDRsL04o1zhacYszsf3YDjqTffWkVDRYvwkddkzNyyc3y3QKlMa6WTuQASBvQKg3Po7aqa3YDjqTffWkVDRYf3781S3eEchQ5epMRzoQYayRL7ZTzTLupN5BoFoeWDGnNxZrJzfZCBlmNo3Y95OkR2c5CBigYCI0a5CiLRzoQUHMRZ3CukTTBB2BUMbZvX4C4QKVsuUMt8yUMs3NJQma2A5(CBwBj1Z5AG5WvQfyCyoJpNZ0H5APRP031mNRbM7zXiWGedZz85cS04yDjmNE6MCoTaJI50y7AMZB2o4ZHl905RjCJDRs(QlqqKvBHuvmKjCJDRs(Qlqmb0HiTTBB2Bc3y3QKV6cetaD4wkvn2TkvsJ7uNDaia4CiXaFc3y3QKV6cetaD4kaCf3lwWeUXUvjF1fiMa6mmOYsBpHd1CFlGM0Ig8MJQsDgJI5Wv(m3QKpxKvbZ5AG5(OnxJDRY5Kg3xZ9TedZ5AG5c6DyoJp3oKaRDl3Nl2S5KaNphLS2Y5OkdGTWCynnBh4upNRbMdqrn2Ndx5ZCRY50amyoJNBUpxlLZ5AAFolGwX8o91eUXUvjF1fiMa6IsDgJcQTOaAmqRAh)wOVaKkrkPJkQi6X4cH1wQIma2clg0yNEQGgd0Q2XVf6RiR4osjD6Pce9yCzydlb(I7noeXr4qf1nWBjK(Ax2yRLkonleybzJiHhvIkQ0yGw1o(TqFTlBS1sfNMfcqLt4g7wL8vxGycOZWGs2jgO2Icq0JXv0YDGXvvufzf3xmOX(eouZHMgyUGEhMtKjLZTdjWAPKI5qG52HeyTB5(C9CYYNRIZr1IQZH10SDGpNinqoNo3Y95CnWCOSL4EUg7wLZjnUVMdngfwUpNxZ9aztXCBwtXCvCoQYkUpNE6MCoxdWG5AgmxwZr1IQZH10SDGpxNV5YAUg7MwyoQYQTqo3gIHWNtuPlFZjH(nNxZz(Cz5ZHawUpNohEZ1(CTuUMWn2Tk5RUaXeqhRPqvrvKvCFc3y3QKV6cetaDasLiL0NWn2Tk5RUaXeq3USXwlvCAwiWeouZjUIB5(CcpvcZvX5eEk5BoJpxqXDjfZHcgf4pxc6oRLZjYCnZ5AG5qzlX9CEZ2bFoxdd4Ak5JVMt895QusXCiaUca(CpadPp3EB5CImxZCSsFxJKI5e(ZvS5ckgmN3SDW5RjCJDRs(Qlqmb0HReuvuHl5Bc3y3QKV6cetaD6CqzoeqD2bGa3Ea3lwGcxpafrTffGOhJldtHslyjF9krj9i6X4IPNGQIkALiGTELOCc3y3QKV6cetaD6CqzoeqD2bGaAfoeW52w4PWvanDVDRs1d0AyGAlkarpgxgMcLwWs(6vIs6r0JXftpbvfv0kraB9kr5eUXUvjF1fiMa6ISI7iL0NWn2Tk5RUaXeqhULsvJDRsL04o1zhacckTqaK(eUXUvjF1fiMa6mmOKDIHj8eUXUvjFHRs(krjxWUEZEwNQkQ6TaRCnt4g7wL8fUk5ReLCXeqNHPqPfSKpHBSBvYx4QKVsuYftaDbgJvmLf07WeouZTz6jmxfNdfOebS5m(CTuutbFoDo8MtK5AMJQSAlKZTHyiR5qztkMtcrV0cS5WAA2oWNR95CnWCq(MRIZ5AG5I2UgFoUMsx(MdbMtNdpQNZEqlLumNfNZ1aZHuC(CVc45M7Z9myolNZ1aZfyVNeMRIZ5AG52m9eMdrpgxt4g7wL8fUk5ReLCXeqhtpbvfv0kraJAlkGgd0Q2XVf6RiR2cPQyiOIQBbGYl1ZaHH(Med3Cx5waqVBbGYl1ZaXbL20eouZTHY54wUlH58MTd(CrBxJZPEoxdmhUk5ReLZvX52m9eMRIZHcuIa2CgFozjcyZ5A6CoxdmhUk5ReLZvX5OkR2c5CBigc1Z5Am(C7MwGphGICwp3MPNWCvCouGseWMdRPz7aFoxt7ZX1u6Y3CiWC6C4nNiZ1mxJDtlmN3siDo1ZzX5OvCUHiH1eUXUvjFHRs(krjxmb0HBPu1y3QujnUtD2bGaVLq6kwrJAlkWBjK(IPNGQIkALiGTGSrKWJ(g7Mwqbjeyaxa60JRs(kr5IPNGQIkALiGTI6sPIbynnBhuUfaIdUk5ReLRiR2cPQyilge0wYNWn2Tk5lCvYxjk5IjGoALBvsTffqJbAv743c9LHPqPfSKJkQUfakVupdeNnUPjCJDRs(cxL8vIsUycOtNdkZHa(eUXUvjFHRs(krjxmb0PZbL5qa1zhacOv4qaNBBHNcxb0092TkvpqRHHjCJDRs(cxL8vIsUycOdrw1tf1zumHBSBvYx4QKVsuYftaDiaJdSqSCFc3y3QKVWvjFLOKlMa6K2UgNRqbP)2dG0NWn2Tk5lCvYxjk5IjGUOXaezvVjCJDRs(cxL8vIsUycORtmWDwlv4wkNWt4g7wL8fW5qIbUGyH15Wt1BbM5Gcb6aQTOae9yCX0tqvrfTseWwVsuIkQn2nTGcsiWaUW24eUXUvjFbCoKyGlMa6cGGIrHQIkPo2EQhd6ao1wuqJDtlOGecmGloHMEQarpgxg2WsGV4EJdrCeGoQOUbElH0x7YgBTuXPzHaliBej8Os6XvjFLOCfz1wivfdzXGG2sUWqFt0Vbn2TkxrwTfsvXqwwQIsBxJt)oR0ZNQlyfz1wivfdzXGG2sUGnnHBSBvYxaNdjg4IjGoezvpvfvUgqbjeqb1wuav4TesFTlBS1sfNMfcSGSrKWJEe9yCzydlb(I7noebHMEQarpgxiS2svKbWwyXGg7OIkngOvTJFl0xasLiL0PsQevuPcQOXUPfuqcbgWf2grf1nWBjK(Ax2yRLkonleybzJiHhvspvqJbAv743c9vKvBHuvmeurDNv65t1fSISAlKQIHSyqqBjxyHMkPYjCJDRs(c4CiXaxmb0rtNzrkSCxHiBUtTffGOhJlMEcQkQOvIa26vIsurTXUPfuqcbgWf2gNWn2Tk5lGZHedCXeqhZOrtcklvCAngO2Icq0JXftpbvfv0kraB9krjQO2y30ckiHad4cBJt4g7wL8fW5qIbUycOdxjgsN1o8urzhaulTeu4Naui1wuaIEmUy6jOQOIwjcyRxjkNWn2Tk5lGZHedCXeqNRbu6jsPNpvSyyGAlkarpgxmahIe4CvSyyyPtBc3y3QKVaohsmWftaDIkM8PfSuXaELDIbQTOae9yCX0tqvrfTseWwVsuIkQn2nTGcsiWaUW24eEc3y3QKVILc4CiXaxqSW6C4P6TaZCqHaDa1wuaIEmUy6jOQOIwjcyRxjkP)bi6X4IwJdbEkddRxjkrf1g7MwqbjeyaxyBCc3y3QKVILc4CiXaxmb0fabfJcvfvsDS9upg0bCQTOGg7MwqbjeyaxCcn9parpgx0ACiWtzyy9krj94QKVsuUISAlKQIHSyqqBjxyHM(nOXUv5kYQTqQkgYYsvuA7AC63zLE(uDbRiR2cPQyilge0wYfSPjCJDRs(kwkGZHedCXeqhISQNQIkxdOGecOGAlkGgd0Q2XVf6RiR2cPQyiOI6oR0ZNQlyfz1wivfdzXGG2sUWc9eUXUvjFflfW5qIbUycOJMoZIuy5Ucr2CNAlkarpgxm9euvurRebS1ReL0)ae9yCrRXHapLHH1ReLOIAJDtlOGecmGlSnoHBSBvYxXsbCoKyGlMa6ygnAsqzPItRXa1wuaIEmUy6jOQOIwjcyRxjkP)bi6X4IwJdbEkddRxjkrf1g7MwqbjeyaxyBCc3y3QKVILc4CiXaxmb0HRedPZAhEQOSdaQLwck8takKAlkarpgxm9euvurRebS1ReL0)ae9yCrRXHapLHH1ReLt4g7wL8vSuaNdjg4IjGoxdO0tKspFQyXWa1wuaIEmUyaoejW5QyXWWsN2eUXUvjFflfW5qIbUycOtuXKpTGLkgWRStmqTffGOhJlMEcQkQOvIa26vIs6FaIEmUO14qGNYWW6vIsurTXUPfuqcbgWf2gNWt4qnxJDRs(kO0cbq6c4ASGaGrTffeuAHai91Z4ENyqyOVPjCOMRXUvjFfuAHaiDXeqhI0YqO2IcckTqaK(6zCVtmim030eUXUvjFfuAHaiDXeqNHbvuwaNAlkarpgxggurzb81ReLt4jCOMJQSAlKZTHyiZ9TCxct4qnN4NZXRayoU56TBvYPEokk95WDohxt7oWMt8XWCcvA75aTqoxhDGnxlzq)OyoCZDl3NJQsDgJI568nN4JH5qz6edR52qUgGjY4WCUgJpxJDRY5m(C6C4nNinqoNRbMlO3H50085OAr156OdS5Wn3TCFoQk1zmkOEooaZ1iLwynHBSBvYxXsXTCxccmmOYsBtTffGRs(kr5YWGklT9Ib9Jc6FaIEmUezPdmUcRXKYLoTjCJDRs(kwkUL7sqmb0HBPu1y3QujnUtD2bGGyPaohsmWNWn2Tk5RyP4wUlbXeqxKvBHuvmKjCJDRs(kwkUL7sqmb0fL6mgfuBrb0yGw1o(TqFbivIusNEe9yCHWAlvrgaBHfdASpHBSBvYxXsXTCxcIjGoePTDBZEuBrbn2nTGcsiWaUWqjurTXUPfuqcbgWfg60JBURClaeSPjCJDRs(kwkUL7sqmb0zyqj7eduBrbi6X4kA5oW4QkQISI7lg0yNECvYxjkxrwTfsvXqwmiOTKlSqJkQi6X4kA5oW4QkQISI7lg0yxaknHBSBvYxXsXTCxcIjGoePTDBZEuBrb4M7k3cabBAc3y3QKVILIB5UeetaDrPoJrb1wuangOvTJFl0xasLiL0NWn2Tk5RyP4wUlbXeqxuQZyuqTffGOhJlewBPkYaylSyqJD6PcAmqRAh)wOVISI7iL0rf1hGOhJlAnoe4PmmSyqqBjxyakcW6oOClaeRXUv5YWGs2jgwoR1csLBbavoHBSBvYxXsXTCxcIjGoCfaUI7flyc3y3QKVILIB5UeetaDasLiL0NWn2Tk5RyP4wUlbXeqhRPqvrvKvCNAlk4bi6X4IwJdbEkddlDAuBPdmMonxzrbi6X4kA5oW4QkQISI7lg0yxakrTLoWy60CLfeapRDqa6t4g7wL8vSuCl3LGycOdrAB32S3eUXUvjFflf3YDjiMa6mmOYsBpHBSBvYxXsXTCxcIjGoDoOmhcOo7aqGBpG7flqHRhGIO2Icq0JXLHPqPfSKVELOKEe9yCX0tqvrfTseWwVsuoHBSBvYxXsXTCxcIjGoDoOmhcOo7aqaTchc4CBl8u4kGMU3UvP6bAnmqTffGOhJldtHslyjF9krj9i6X4IPNGQIkALiGTELOCc3y3QKVILIB5UeetaDrwXDKs6t4g7wL8vSuCl3LGycOd3sPQXUvPsACN6SdabbLwiasFc3y3QKVILIB5UeetaDgguYoXWeEchQ5eQMt8XWCOmDIH5(wUlHjCOMt8Z54vamh3C92Tk5uphfL(C4oNJRPDhyZj(yyoHkT9CGwiNRJoWMRLmOFumhU5UL7ZrvPoJrXCD(Mt8XWCOmDIH1CBixdWezCyoxJXNRXUv5CgFoDo8MtKgiNZ1aZf07WCAA(CuTO6CD0b2C4M7wUphvL6mgfuphhG5AKslSMWn2Tk5RSuMuXTCxccmmOYsBtTffGRs(kr5YWGklT9Ib9Jc6FaIEmUezPdmUcRXKYLoTjCJDRs(klLjvCl3LGycOlk1zmkO2Ic8wcPVaKkrkPVGSrKWJEAmqRAh)wOVaKkrkPtpIEmUqyTLQidGTWIbn2NWn2Tk5RSuMuXTCxcIjGUOuNXOGAlkGgd0Q2XVf6RDzJTwQ40Sqa6r0JXfcRTufzaSfwmOX(eUXUvjFLLYKkUL7sqmb0HBPu1y3QujnUtD2bGaGZHed8jCJDRs(klLjvCl3LGycOlYQTqQkgYeUXUvjFLLYKkUL7sqmb0HiTTBB2JAlkOXUPfuqcbgWfgkHkQn2nTGcsiWaUWqNECZDLBbGGnnHBSBvYxzPmPIB5UeetaDgguYoXa1wuaIEmUIwUdmUQIQiR4(Ibn2P3BjK(IttAUB5UYWWcYgrcp6BSBAbfKqGbCHH(eUXUvjFLLYKkUL7sqmb0HRaWvCVybt4g7wL8vwktQ4wUlbXeqhGujsjDQTOae9yCzydlb(I7noebHM(narpgxiS2svKbWwyXGg7t4g7wL8vwktQ4wUlbXeq3USXwlvCAwia1wuaIEmUqyTLQidGTWIbn2rfvAmqRAh)wOVaKkrkPpHBSBvYxzPmPIB5UeetaDgguzPTNWn2Tk5RSuMuXTCxcIjGoDoOmhcOo7aqGBpG7flqHRhGIO2Icq0JXLHPqPfSKVELOKEe9yCX0tqvrfTseWwVsuoHBSBvYxzPmPIB5UeetaD6CqzoeqD2bGaAfoeW52w4PWvanDVDRs1d0AyGAlkarpgxgMcLwWs(6vIs6r0JXftpbvfv0kraB9kr5eUXUvjFLLYKkUL7sqmb0fzf3rkPpHBSBvYxzPmPIB5UeetaD4wkvn2TkvsJ7uNDaiiO0cbq6t4g7wL8vwktQ4wUlbXeqNHbLStmmHNWHAUV35RzV5(wUlHjCOMt8Z54vamh3C92Tk5uphfL(C4oNJRPDhyZj(yyoHkT9CGwiNRJoWMRLmOFumhU5UL7ZrvPoJrXCD(Mt8XWCOmDIH1CBixdWezCyoxJXNRXUv5CgFoDo8MtKgiNZ1aZf07WCAA(CuTO6CD0b2C4M7wUphvL6mgfuphhG5AKslSMWn2Tk5lUL7sqGHbvwABQTOaCvYxjkxgguzPTxmOFuq)dq0JXLilDGXvynMuU0PnHd1CIhZ1u6(CI3p1ZjUrQePK(CgFUwkQPGphxt7oWG3AoXJ5AMt8(PEoXnsLiL0NZ4ZX10Udm4nNfNZ85ev6Y3CIAUdZrjRTCoQYaylmhwtZ2H5OcBbR5ePbY5CnWCb9omh3BMZNd3C3Y95e3ivIusForMRzokzTLZrvgaBH5ASBAbQCUInNinqohcilrZjCZj(ydlb(CuHfNtCJujsj95m(C4M7ZjsdKZ5AG5c6DyonnFoHdLh65eFSHLaN65mFZ5ZHaUdS58AoDomNRbMJswB5CuLbWwyUiRcMZ85QCoXRSXwlN7tZcbOY1eUXUvjFXTCxcIjGUOuNXOGAlkWBjK(cqQePK(cYgrcp6PXaTQD8BH(cqQePKo9uXg4TesFTlBS1sfNMfcSGSrKWdvur0JXLHnSe4lU34qehHdvur0JXfcRTufzaSfwmOXovoHd1CIxzJTwo3NMfcmNXNRLIAk4ZX10Udm4TMWn2Tk5lUL7sqmb0fL6mgfuBrbElH0x7YgBTuXPzHaliBej8ONgd0Q2XVf6RDzJTwQ40Sqa6r0JXfcRTufzaSfwmOX(eouZjEmxtP7ZjE)upNRbMlO3H5qbPZ95CMb858AoUM2DGnxZNlOtkMJQSI7iL05Z185OvCUHiH1CIhZ1mN49t9CUgyUGEhMRsjfZX10Udm(CuLvChPK(CUM2NtuPlFZrt3NZ1abZ1(COJY34CIp2WsyoU34q4R5qbBXiWGedZHaUiaY54AA3bML7ZrvwXDKs6ZjYCnZHokFJZj(ydlb(CD(MdDuUWnN4JnSe4Zz854bTus9Ci6(COJY34CoKp(CEnhcmhc4oWMZY5ckgmh3C92Tk5ZrfUgyon2UgGnN49p3Rd6DyoJt9CUgyUGIbZz(CsOt(CEjQzp(COJY3ivUMJQfdB5(CCnT7aBUkNJQSI7iL0NZ4ZXDtkNRNJh0s5C7TLuphVMZ4ZLLphUzwUpxJu6(CuTO6AoXhdZHY0jgMZ4Z5vnNiOdzoVMtuZyD6Z9aztHL7ZrjRTCoQYaylmhvL6mgfRjCJDRs(IB5UeetaDrPoJrb1wuangOvTJFl0xrwXDKs60JOhJlewBPkYaylSyqJD6PInWBjK(Ax2yRLkonleybzJiHhQOIOhJldByjWxCVXHiochvoHBSBvYxCl3LGycOd3sPQXUvPsACN6SdabaNdjg4t4g7wL8f3YDjiMa6ISAlKQIHmHd1CIhZ1mhvzaS1Y952S2Y568nx7ZjHM7ZHsZ5nBhCo1ZrP02UTzV5saE858AoeyoDo8MtK5AMtJTRbyZrJzfZCkMZR5c6qG546myokk95WDox085qkxZCwY9o95OuAB32ShFol9AUEoUL7syoQYayRL7ZTzTLR5(EZCl3NtK5AMZ1WayoVz7GZPEokL22Tn7nNeATaFoxdmNSenhnMvmZPyUOjLaBowjH568nNXNtNdV5QCoCvYxjkNJk68nhkiDUpxqhIL7ZX1zWCz5Z51CIAUdZrjRTCoQYaylmhwtZ2bovoNiZ1mxXMtK5AkDFoQYayRL7ZTzTLRjCJDRs(IB5UeetaDisB72M9O2IcASBAbfKqGbCHHsOIAJDtlOGecmGlm0Ph3Cx5waiyt0JOhJROL7aJRQOkYkUVyqJDXbLMWHAo0yuy5(CEnhTQKZH10SDGpxfNJQfvNlwS56KcxJL7Zz8CZ95evmxZCMVMtCfhMZ1abZ185CnafZHRaynHBSBvYxCl3LGycOZWGs2jgO2Icq0JXv0YDGXvvufzf3xmOX(eUXUvjFXTCxcIjGoCfaUI7flyc3y3QKV4wUlbXeqhGujsj9jCOMBZAkMRIZrvwX95m(C6C4nxhDGnxlLZrvl3bgFUkohvzf3NdRPz7aFonTwyoeaY505WBUoFZ5AagmNXZn3NRXUPfMJQSAlKZTHyiZ5AAFoCPlFZTdjWAhMlOyWAo00y85m(CvkPyUEoEqlLZT3woxV3wY95c0LUrtcZ5nBhCo1Z1852SMI5Q4CuLvCFoJNBUpNx1CwaTg7rD5Ac3y3QKV4wUlbXeqhRPqvrvKvCNAlkydASBvUISAlKQIHSSufL2UgN(DwPNpvxWkYQTqQkgYIbbTLCbBAchQ5OuAB32S3CgFoDo8MR5ZjlrZrJzfZCkMlAsjWMR3Bl5(CO0CEZ2bNVMt8ObY505wUphvzaS1Y952S2sQNZ8nNpxpxa8m9G52BlNZR505WCUgyol5EN(CukTTBB2BoqlKZ17TLCFUEoUL7syoVz7Gt9CaNgGTwkPyorMRzozjAUGM7aJI1eUXUvjFXTCxcIjGoePTDBZEuBrb4M7k3cabBcvuBSBAbfKqGbCHH(eouZjELn2A5CFAwiWCgFoDo8MtKgiNZ1amyZ5Z1ZrjRTCoQYaylmhnwHNRXUPfMJkSfSMRsjfZjsdKZz(C4oNdbMJRPDhyWJkxZHMgJpNXNRNJh0s5CEnxa8m9G52BlNZY5ckUph3C92Tk5R5qzkrZf0ChyumNe6KpNxIA2JpNo3Y95mForAGCUwBBYgrcR5epAGCoDUL7Z9Pjn3TCFoXhdZ15BonTwl3NRZY1aS58MTd(Cj0mekOEoZ3C(CCPTRXLumhc4oWMZR505WCI3)CI0a5CT22KnIeOEUMpNRbMJd4kFZ5nBh85EfWZn3NdbsiA(Crwfmhxt7oWSCFoxdmxqB5CEZ2bFnHBSBvYxCl3LGycOBx2yRLkonleGAlkarpgxiS2svKbWwyXGg7OIkngOvTJFl0xasLiL0rf1g7MwqbjeyaxyOtV3si9fNM0C3YDLHHfKnIeEt4g7wL8f3YDjiMa6mmOYsBpHBSBvYxCl3LGycOtNdkZHaQZoae42d4EXcu46bOiQTOae9yCzykuAbl5RxjkPhrpgxm9euvurRebS1ReLt4g7wL8f3YDjiMa605GYCiG6Sdab0kCiGZTTWtHRaA6E7wLQhO1Wa1wuaIEmUmmfkTGL81ReL0JOhJlMEcQkQOvIa26vIYjCJDRs(IB5UeetaDrwXDKs6t4g7wL8f3YDjiMa6WTuQASBvQKg3Po7aqqqPfcG0NWn2Tk5lUL7sqmb0zyqj7edt4jCOMt8yUM5eVYgBTCUpnleG652m9eMRIZHcuIa2CCnLU8nhcmNohEZXSDn(CiqSyWCUgyoXRSXwlN7tZcbMdxbi1CuHTG1CImxZCHEoXhByjWNRZ3C9CuYAlNJQma2cu5AoXJgiNtCJujsj95m(CvmohUk5ReLup3MPNWCvCouGseWMd35CTKxZHaZPZH3COG05(CImxZCHEoXhByjWxt4g7wL8L3siDfROjGPNGQIkALiGrTff4TesFTlBS1sfNMfcSGSrKWJEe9yCzydlb(I7noebHMEQarpgxiS2svKbWwyXGg7OIQ3si9fGujsj9fKnIeE0JRs(kr5cqQePK(IbbTLCXb3Cx5waqLt4qnN4XCnLUpN4v2yRLZ9PzHaup3MPNWCvCouGseWMJRP0LV5qG505WBoeiwmyUoPyoeBFhyZHRs(kr5CuH4gPsKs6upNWtfa(CFVybup3M1umxfNJQSI7u5CfBorAGCUntpH5Q4COaLiGnNXNRrkDFoVMJbnwZCO0CynnBh4RjCJDRs(YBjKUIv0etaDm9euvurRebmQTOGnWBjK(Ax2yRLkonleybzJiHh9uH3si9fGujsj9fKnIeE0JRs(kr5cqQePK(IbbTLCXb3Cx5waGkQElH0x4kaCf3lwWcYgrcp6XvjFLOCHRaWvCVyblge0wYfhCZDLBbaQO6TesFXAkuvufzf3xq2is4rpUk5ReLlwtHQIQiR4(IbbTLCXb3Cx5waGkQynnBh4QiRXUvzlfg6lumvsCIti]] )


end
