-- MageFrost.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 64 )

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
        winters_reach = {
            id = 273347,
            duration = 15,
            max_stack = 1,
        },
    } )


    -- azerite power.
    spec:RegisterStateExpr( "winters_reach_active", function ()
        return false
    end )

    spec:RegisterStateFunction( "winters_reach", function( active )
        winters_reach_active = active
    end )


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
        } )
    } )


    spec:RegisterStateTable( "incanters_flow", {
        changed = 0,
        count = 0,
        direction = "+",
    } )


    local FindUnitBuffByID = ns.FindUnitBuffByID


    spec:RegisterEvent( "UNIT_AURA", function( event, unit )
        if UnitIsUnit( unit, "player" ) and state.talent.incanters_flow.enabled then
            -- Check to see if IF changed.
            local name, _, count = FindUnitBuffByID( "player", 116267, "PLAYER" )

            if name and count ~= state.incanters_flow.count and state.combat > 0 then
                if count == 1 then
                    state.incanters_flow.direction = "+"
                elseif count == 5 then
                    state.incanters_flow.direction = "-"
                elseif count > state.incanters_flow.count then
                    state.incanters_flow.direction = "+"
                elseif count < state.incanters_flow.count then
                    state.incanters_flow.direction = "-"
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

        had_brain_freeze = false,
    } )

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 116 then
                frost_info.last_target_actual = destGUID
            end

            if spellID == 44614 and FindUnitBuffByID( "player", 205766 ) then
                frost_info.had_brain_freeze = true
            end
        end
    end )

    spec:RegisterStateExpr( "brain_freeze_active", function ()
        return debuff.winters_chill.up or ( prev_gcd[1].flurry and frost_info.had_brain_freeze )
    end )

    spec:RegisterHook( "reset_precast", function ()
        frost_info.last_target_virtual = frost_info.last_target_actual
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
            id = 1953,
            cast = 0,
            charges = 1,
            cooldown = 15,
            recharge = 15,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135736,

            notalent = "shimmer",
            
            handler = function ()
                -- applies blink (1953)
            end,
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
                applyDebuff( "target", "chilled" )
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

            usable = function () return target.casting end,
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
                end

                applyDebuff( "target", "flurry" )
                addStack( "icicles", nil, 1 )

                if talent.bone_chilling.enabled then addStack( "bone_chilling", nil, 1 ) end
                removeBuff( "ice_floes" )

                removeBuff( "winters_reach" )
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
        

        shimmer = {
            id = 212653,
            cast = 0,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            gcd = "off",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135739,

            talent = "shimmer",
            
            handler = function ()
                -- applies shimmer (212653)
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


    spec:RegisterPack( "Frost Mage", 20180930.1705, [[dOut2aqisf6rIqTjsL(KOKAuqOCkiu9krKzrkClrjAxk1VufggeLJPkAzIO8mietdcPRbrvBtuc9nrigNkI6CquP1PIiMNksUNOyFQi1bvrGfQk1dHOIMiPIQUOiK2Oi4JQi0ijvuPtsQGvQeMjev4MIsWojf9tsfLHsQilvevpfHPQk5QKkQ4RIsYEr1FH0GPCyHfRspMKjJOld2SQ6ZI0OvsNwYQvrqVwuQzJ0Tfv7wXVLA4KslhQNJY0P66QW2vI(oPQXRIiDEiy9QOMpez)eZFYFXjidh4AMmK98KrgYfrq2(zIGSebrtgNWrqlWj0gQSJuGtmroWjsa3mxSSqKcCcTbc0oi5V4eS(aRaoXQ7AzNKhpslF94UvD(dwLFqdV6rHJV)Gv5QhxAFFC)rwsclFOf3)IcSh6egsEuKSh6uYrZcrkGMaUz(Mv5koX9OOUom8lNGmCGRzYq2Ztgzixebz7NjcYseeLteh(AJ5eevoYjNyTijHHF5eKatXjsSyjGBMlwwisbzrIfB1DTStYJhPLVEC3Qo)bRYpOHx9OWX3FWQC1JlTVpU)iljHLp0I7Frb2dDcdjpks2dDk5OzHifqta3mFZQCLSiXIraADi)cyXqeKPHyjdzppzXYsXEMiNeKH8CcAXCg)fNGvtkf4V4A(K)ItatCPaj)nNqHlhWvWjuDtjB9ZUua60lJngcseetxXiH7X)V1xJdygQATO09HworO8QhorPa0PxgCNRzY4V4eWexkqYFZju4YbCfCcDumpOW47uAOQGIY0wzdByIlfiftxXqmX0IHLOPkY9ZnC752uxmKqsS7X)VV4Og0pgGZWgdHYftxX0IHLOPkY9Z9h3m)2uxmeNtekV6Ht8PhymcCNRjIWFXjGjUuGK)MtOWLd4k4eEqHX3P0qvbfLPTYg2WexkqkMUIDp()9fh1G(XaCg2yiuUy6kgIjMwmSenvrUFU)4M53M6IPRy3J)FxQsrb2M5HkBXoLyiQyiHKyAXWs0uf5(5oLgQkOOmTv2GyiHKyAXWs0uf5(5gU9CBQlgIZjcLx9Wj(0dmgbUZ1er5V4eHYRE4eFCFgg0gF5eWexkqYFZDUMip)fNaM4sbs(BoHcxoGRGtekVwcOWa5fWe70ILmXqcjXcLxlbuyG8cyIDAXEkMUIPcMJ6voiwgXqMy6k294)3)AsbmdT)OFCZ8ngcLl2PelzCIq5vpCIlToFoWKCNRzwK)ItatCPaj)nNqHlhWvWjUh))(xtkGzO9h9JBMVXqOCorO8QhorPauAmkG7Cnte(lorO8QhoHQZbhL5noNtatCPaj)n35AEY8xCcyIlfi5V5ekC5aUcoHokMhuy8DknuvqrzARSHnmXLcKIHesIDp()DPkffyBMhQSflJyiVy6kMok294)3xCud6hdWzyJHq5CIq5vpCc42ZTPo35AIC5V4eWexkqYFZju4YbCfCcDuSq5vp7pUpddAJV7Aq)0kD1ftxXsX9XqIgnS)4(mmOn(UXqEudtSmIHmorO8QhoboqaT)OFCZCUZ18jY4V4eWexkqYFZju4YbCfCcvWCuVYbXYigYedjKeluETeqHbYlGj2Pf7jNiuE1dN4sRZNdmj35A(8j)fNaM4sbs(BoHcxoGRGtCp()9fh1G(XaCg2yiuUyiHKyAXWs0uf5(5gU9CBQlgsijwO8AjGcdKxatStl2tX0vmpOW4BMwA5EnPOLc2WexkqYjcLx9WjsPHQckktBLnWDUMptg)fNiuE1dNOua60ldobmXLcK83CNR5teH)ItatCPaj)nNqHlhWvWjIZaUCyRVghWmumeQ1nmXLcKIPRy6Oy3J)FFXrnOFmaNHngcLlMUIDp()T(ACaZqXqOw3yiuoNiuE1dN4tpWye4oxZNik)fNiuE1dN4JBMFBQZjGjUuGK)M7CnFI88xCcyIlfi5V5eHYRE4eQGsrdLx9GslMZjOfZrNih4e59sihgN7CnFMf5V4eHYRE4eLcqPXOaobmXLcK83CN7Ccs4hhuN)IR5t(lorO8QhoHQpghWmTaLYjGjUuGK)M7Cntg)fNaM4sbs(BoHcxoGRGtOfdlrtvK7N7p9aJrqmDf7IJAq)yaodOHYRLGy6kMok294)3)AsbmdT)OFCZ8ngcLZjcLx9WjkfGsJrbCNRjIWFXjGjUuGK)MtekV6HtOckfnuE1dkTyoNGwmhDICGtO6Ms26hg35AIO8xCcyIlfi5V5ekC5aUcorO8AjGcdKxatStlgIiMUI5bfgF)XaCUMuuCuZgM4sbsXqcjXcLxlbuyG8cyIDAXquorO8QhoHkOu0q5vpO0I5CcAXC0jYbor0a35AI88xCcyIlfi5V5eHYRE4eQGsrdLx9GslMZjOfZrNih4eSAsPa35oNqlguD(nC(lUMp5V4eWexkqYFZDUMjJ)ItatCPaj)n35AIi8xCcyIlfi5V5oxteL)ItekV6HteyvmaAnoqPGY5eWexkqYFZDUMip)fNiuE1dNqF4agfOqomEq5eWexkqYFZDUMzr(lobmXLcK83CNRzIWFXjcLx9WjYlmUXOvEKcCcyIlfi5V5oxZtM)ItekV6HtOT9QhobmXLcK83CNRjYL)ItekV6Ht8XnZVn15eWexkqYFZDUZjuDtjB9dJ)IR5t(lorO8QhorPqaDjudJtatCPaj)n35AMm(lorO8QhorEHXngTYJuGtatCPaj)n35AIi8xCcyIlfi5V5ekC5aUcoHwmSenvrUFU)4(mmOn(kgsijMx5aQ3OKfi2Pf7jYeljXubZr9khetxX8khq9gLSaXoLyjdzCIq5vpCc8XaO9hvBRhWCNRjIYFXjGjUuGK)MtOWLd4k4eEqHX34Jbq7pQ2wpG3WexkqkMUIfkVwcOWa5fWelJypftxXuDtjB9ZgFmaA)r126b8(FqPOyqTg4ua1RCqStjMQBkzRF2FCFgg0gF3yipQHXjcLx9WjubLIgkV6bLwmNtqlMJoroWj8GcJJIBTCNRjYZFXjGjUuGK)MtOWLd4k4eAXWs0uf5(5UuiGUeQHjgsijMh4uW3ELdOEJswGyNsSebzCIq5vpCcTTx9WDUMzr(lorO8QhoXbdqlhYzCcyIlfi5V5oxZeH)ItekV6HtCPDtI(pWiWjGjUuGK)M7Cnpz(lorO8QhoXfWmaNDnPCcyIlfi5V5oxtKl)fNiuE1dNGwPRod9eEqMMdJZjGjUuGK)M7CnFIm(lorO8QhoXVWWL2njNaM4sbs(BUZ185t(lorO8QhormkG54GIQckLtatCPaj)n35oNiAG)IR5t(lorO8QhoXh3NHbTXxobmXLcK83CNRzY4V4eHYRE4exAD(CGj5eWexkqYFZDUMic)fNiuE1dNq15GJY8gNZjGjUuGK)M7Cnru(lorO8QhorPa0PxgCcyIlfi5V5oxtKN)ItatCPaj)nNqHlhWvWj0IHLOPkY9ZnC752uxmKqsS7X)VV4Og0pgGZWgdHYftxXqmX0IHLOPkY9Z9h3m)2uxmDfdXe7E8)7svkkW2mpuzl2PedrfdjKethfZdkm(oLgQkOOmTv2WgM4sbsXqCXqcjX0IHLOPkY9ZDknuvqrzARSbXqCorO8QhoXNEGXiWDUMzr(lobmXLcK83CcfUCaxbN4E8)7FnPaMH2F0pUz(gdHY5eHYRE4eLcqPXOaUZ1mr4V4eHYRE4e4ab0(J(XnZ5eWexkqYFZDUMNm)fNiuE1dNaU9CBQZjGjUuGK)M7CnrU8xCIq5vpCIuAOQGIY0wzdCcyIlfi5V5oxZNiJ)ItekV6HtO6bq7pQQPKCcyIlfi5V5oxZNp5V4eHYRE4eFCZ8BtDobmXLcK83CNR5ZKXFXjGjUuGK)MtekV6HtOckfnuE1dkTyoNGwmhDICGtK3lHCyCUZ18jIWFXjcLx9WjkfGsJrbCcyIlfi5V5o35eEqHXrXTw(lUMp5V4eWexkqYFZju4YbCfCcpOW47uAOQGIY0wzdByIlfiftxXUh))UuLIcSnZdv2ILrmKxmDfdXe7E8)7loQb9Jb4mSXqOCXqcjX8GcJVHBp3M6ByIlfiftxXuDtjB9ZgU9CBQVXqEudtStjMkyoQx5GyioNiuE1dNaFmaA)r126bm35AMm(lobmXLcK83CcfUCaxbNqhfZdkm(oLgQkOOmTv2WgM4sbsX0vmetmpOW4B42ZTP(gM4sbsX0vmv3uYw)SHBp3M6BmKh1We7uIPcMJ6voigsijMhuy8TQZbhL5noFdtCPaPy6kMQBkzRF2QohCuM348ngYJAyIDkXubZr9khedjKeZdkm(ghiG2F0pUz(gM4sbsX0vmv3uYw)SXbcO9h9JBMVXqEudtStjMkyoQx5GyiHKyQ1aNcm0pouE1tqf70I9CJCfdX5eHYRE4e4Jbq7pQ2wpG5o35e59sihgN)IR5t(lobmXLcK83CcfUCaxbNiVxc5W4BYI5XOaXoTyprgNiuE1dN4sRjBUZ1mz8xCcyIlfi5V5ekC5aUcoX94)3Lcq)0gyBYw)WjcLx9WjkfG(PnW4o35oNyjGzvpCntgYEEYi7KFMSDYsgIIOCc9bEQjLXj0HCTn2bsXseXcLx9igTyoBll4emTGIRzwer5eAX9VOaNiXILaUzUyzHifKfjwSv31YojpEKw(6XDR68hSk)GgE1JchF)bRYvpU0((4(JSKew(qlU)ffyp0jmK8Oizp0PKJMfIuanbCZ8nRYvYIelgbO1H8lGfdrqMgILmK98Kfllf7zICsqgYllKfjwSe9KcQdhif7c)gdIP68B4IDH0AyBXobkfO1zIn9KLRbo)FqfluE1dtSEOiSLfHYREyBTyq153WZ8PblBzrO8Qh2wlguD(n8KY843nPSiuE1dBRfdQo)gEszEehP5W4Hx9ilcLx9W2AXGQZVHNuMhbwfdGwJdukOCzrO8Qh2wlguD(n8KY8qF4agfOqomEqLfHYREyBTyq153WtkZd2eAzRTJY8WzYIq5vpSTwmO68B4jL5rEHXngTYJuqwekV6HT1IbvNFdpPmp02E1JSiuE1dBRfdQo)gEszE8XnZVn1LfYIelwIEsb1HdKIblbmcI5voiMVcIfkVXIvmXILrrJlf2YIq5vpSmQ(yCaZ0cuQSiXIPdFX8vqS8ifeBnyILqNGyX3bSyQG51KkwnmpgxSeOhymcAiMEqmvmIrc0abX8vqmDqbIHCeJcelgsXoyGyTVcyXwR0vX0IRgxocIfkV6rdXQVyXYOOXLcBzrO8QhwszEukaLgJc0O(z0IHLOPkY9Z9NEGXiO7fh1G(XaCgqdLxlbD1X7X)V)1KcygA)r)4M5BmekxwekV6HLuMhQGsrdLx9GslMRXe5qgv3uYw)WKfjwSxRGyEGtbxmFfdS1MskwXMS2fdoPHY3I9gC9amIHizjYlMh4uWzAiMVcIrw)pGHrbmXUGRhGrmFfeJ4LyXqk2jOtuXcLx9igTyotSadIHdFfWIXYdkDlMo3wpSeWAiwcyaoxtQyjpQrmTy4dyMyhSAsf7e0jQyHYREeJwmxmw3dGflyIvUyxyGF5mXsXq4uee7J7CX8vqS1kDvmT4QXLJGyVP15ZbMuSq5vpBzrO8QhwszEOckfnuE1dkTyUgtKdzIg0O(zcLxlbuyG8cyNgr01dkm((Jb4CnPO4OMnmXLcKiHuO8AjGcdKxa70iQSiuE1dlPmpubLIgkV6bLwmxJjYHmSAsPGSqwKyXYQYxflbmaNRjvSKh1OHyLN1mXUG7awmVftlUAC51zqSdwnPILaUpdJy6m8vm9RWi2T9vXsqNjwmKI9MwNphysXcmiw))IP6Ms26NTyzv5R9HlwcyaoxtQyjpQrdX8vqmvplbmdeRyI54dqSG6R9r6Qy(kigz9)aggfiwXelVMIPoOGyhJxuXwcyeeBTsxfZdCk4IP6JXzBzrO8Qh2oAiZh3NHbTXxzrO8Qh2oAiPmpU0685atklcLx9W2rdjL5HQZbhL5noxwekV6HTJgskZJsbOtVmKfjwmIkxlT(fqkwc0dmgbXu9qwE1dtSpUZfZxbXiEjwO8QhXOfZ3IruJceZxbXYJuqSIjwkmao8Asf7hyXOaJj2BCuJyjGb4miMAnWPatdX8vqm4KgkxmvpKLx9i2kGbXk2K1UybLkMVgUyvU2g7X4BzrO8Qh2oAiPmp(0dmgbnQFgTyyjAQIC)Cd3EUn1rcP7X)VV4Og0pgGZWgdHY1fX0IHLOPkY9Z9h3m)2uxxe7E8)7svkkW2mpuzFkefjK0rpOW47uAOQGIY0wzdByIlfirCKqslgwIMQi3p3P0qvbfLPTYgqCzrO8Qh2oAiPmpkfGsJrbAu)m3J)F)RjfWm0(J(XnZ3yiuUSiXI9AfelpsbX0xuQyPWa4GsrqSliwkmao8AsfleJ2Uy9xSe6eetTg4uGjM(vye7GvtQy(ki2jOtuXcLx9igTy(wSxyeQjvmVfJeObcIL8abX6VyjGBMl2X4fvmFfWGybgeBAXsOtqm1AGtbMyXqk20IfkVwcILaUpdJy6m8LjM((GskgfcsX8wSYfBAxSlutQyhmGuSWflO0TSiuE1dBhnKuMh4ab0(J(XnZLfHYREy7OHKY8aU9CBQllcLx9W2rdjL5rknuvqrzARSbzrIftNdRMuXqo7beR)IHC2usXkMy5nZPiiMoVori2ahooOIPV8vX8vqStqNOI5bofCX8vmWwBkjBlMo4I1dfbXUGQZbMyKGcgxS0OgX0x(Qy4(iDLIGyjIynwS8gdI5bofC2wwekV6HTJgskZdvpaA)rvnLuwekV6HTJgskZJpUz(TPUSiuE1dBhnKuMhQGsrdLx9GslMRXe5qM8EjKdJllcLx9W2rdjL5rPauAmkqwilcLx9W2QUPKT(HLPuiGUeQHjlcLx9W2QUPKT(HLuMh5fg3y0kpsbzrIfl5hdiw)ftNA9awSIjwq1hiWe7GbKIPV8vXsa3NHrmDg(Uf7emiigf(EVeWIPwdCkWelCX8vqmyifR)I5RGy)kD1fJT2husXUGyhmGudXksiOueeR(I5RGy3MXeJSb2K1UyKfiwnI5RGy5fjjfeR)I5RGyj)yaXUh))wwekV6HTvDtjB9dlPmpWhdG2FuTTEaRr9ZOfdlrtvK7N7pUpddAJViHKx5aQ3OKfC6NiljvWCuVYbD9khq9gLSGtLmKjlsSy6SrmwnPuqmpWPGl2VsxDMgI5RGyQUPKT(rS(lwYpgqS(lMo16bSyftmARhWI5RXiMVcIP6Ms26hX6VyjG7ZWiModF1qmFTyILwlbMyWj1XHyj)yaX6Vy6uRhWIPwdCkWeZxdxm2AFqjf7cIDWasX0x(QyHYRLGyEqHXzAiw9ftBZy1LcBzrO8Qh2w1nLS1pSKY8qfukAO8QhuAXCnMihY4bfghf3A1O(z8GcJVXhdG2FuTTEaVHjUuGu3q51safgiVawMN6Q6Ms26Nn(ya0(JQT1d49)GsrXGAnWPaQx5WPuDtjB9Z(J7ZWG247gd5rnmzrO8Qh2w1nLS1pSKY8qB7vpAu)mAXWs0uf5(5UuiGUeQHHesEGtbF7voG6nkzbNkrqMSiuE1dBR6Ms26hwszECWa0YHCMSiuE1dBR6Ms26hwszECPDtI(pWiilcLx9W2QUPKT(HLuMhxaZaC21KklcLx9W2QUPKT(HLuMh0kD1zONWdY0CyCzrO8Qh2w1nLS1pSKY84xy4s7MuwekV6HTvDtjB9dlPmpIrbmhhuuvqPYczrO8Qh2oVxc5W4zU0AYwJ6NjVxc5W4BYI5XOGt)ezYIq5vpSDEVeYHXtkZJsbOFAdmnQFM7X)VlfG(PnW2KT(rwilsSy6WigRZbXyLFeE1dtdXqOpetfJyS1WDalMoOaX0SxgIblHrS47awSGIHGebXubZRjvSeOhymcIfdPy6Gced5igfSftN5RawFXaX81IjwO8QhXkMyhmGum9RWiMVcILhPGyRbtSe6eel(oGftfmVMuXsGEGXiOHymaelU9syllcLx9W2SAsPqMsbOtVm0O(zuDtjB9ZUua60lJngcse0LeUh))wFnoGzOQ1Is3hALfjwSSQ81(Wf7ej0qmFfelpsbXoHhmxmhxatmVfJTgUdyXcMy5XGGyjGBMFBQZelgsXs0Bp3M6mXcMyABgRUuylwcnwvtQyS1WDalwpILaUz(TPUyftmMxuQyHyS8GsflnQrdXyTyftSPDXubUMuXIBF4ILqNWwmDqbIHCeJceRyI5DlMEiYwmVftFGXX4Irc0aHAsf7noQrSeWaCgelb6bgJWwwekV6HTz1KsHKY84tpWye0O(z0rpOW47uAOQGIY0wzdByIlfi1fX0IHLOPkY9ZnC752uhjKUh))(IJAq)yaodBmekxxTyyjAQIC)C)XnZVn1rCzrIflRkFvStKqdX8vqS8ifeRhkcIXwd3bmtSeWnZVn1fZxdxm99bLumThUy(kKlw4I9mlreX0bvPOGympuzZ0qSe92ZTPUy1xSYftFFqjftFWCqS34OgXsadWzqm1AGtbXqSAdBX0VcJy(kiwEKcIX8a7mXubZRjvSe92ZTPUy6lFvS34OgXsadWzqSq51saXflgsX6VyQ(aZaXorAOQGkgH2kBylMoF9)aggfi2fC9amIXwd3bCnPILaUz(TPUy6lFvSNzjIiMoOkffyIfdPypZsevmDqvkkWeRyIXYdkvdXUhUypZsermhgsMyEl2fe7cUdyXQrS8gdIXk)i8QhMyiMVcITwPRawStKqmYipsbXkMgI5RGy5ngeRCXOqmmX8wFGjzI9mlreeFllcLx9W2SAsPqszE8PhymcAu)mEqHX3P0qvbfLPTYg2WexkqQ794)3xCud6hdWzyJHq56IyAXWs0uf5(5(JBMFBQR794)3LQuuGTzEOY(uiksiPfdlrtvK7N7uAOQGIY0wzdiHKwmSenvrUFUHBp3M6iUSiuE1dBZQjLcjL5Xh3NHbTXxzrIflRkFvSeWaCUMuXsEuJyXqkw4IrHG5ILmX8aNcotdXEtRZNdmPydaKmX8wSli2bdiftF5RITwPRawmT4QXLJGyElwEKnig7adIHqFiMkgX(Ll2T9vXQH5X4I9MwNphysMy14TyHySAsPGyjGb4CnPIL8OMTyeEG9AsftF5RI5RyaeZdCk4mne7nToFoWKIrHyjWeZxbXOTEX0IRgxocI9lkfWIHBkiwmKIvmXoyaPy9iMQBkzRFedXIHuSt4bZflpYUMuXyhyqSPDX8wm9bZbXEJJAelbmaNbXuRbofyiUy6lFvSglM(Yx7dxSeWaCUMuXsEuZwwekV6HTz1KsHKY84sRZNdmPg1ptO8AjGcdKxa70jdjKcLxlbuyG8cyN(PUQG5OELdzqMU3J)F)RjfWm0(J(XnZ3yiu(PsMSiXI9cJqnPI5TyA7MkMAnWPatS(lwcDcI9BSyXGGVwtQyfBYAxm9n2xfR8Ty6CyGy(kKlwWeZxbeet15WwwekV6HTz1KsHKY8OuakngfOr9ZCp()9VMuaZq7p6h3mFJHq5YIq5vpSnRMukKuMhQohCuM34CzrIflRkFTpCXorcnelrV9CBQlwXe7GbKI1JyQUPKT(zlwwv(QyNiHgILO3EUn1fRyI1dfbXoyaPyEl2VOuXQrmFfe7sJjBXyABNjM(vye7xS1Asf73yXcXEJJAelbmaNbX0IBLgIvBylMVcILhPGyyiuRatmKxmDqvkkWe7E4IX8IsfJSb2K1UyRXsqSqS34OgXsadWzqmT4wTf71AXeRyIPZRteInWHJdQy6lFvmARxS8G5agbXIHumgTsxDXsJAeR9vaRVyWwwekV6HTz1KsHKY8aU9CBQRr9ZOJEqHX3P0qvbfLPTYg2WexkqIes3J)FxQsrb2M5Hk7miVU6494)3xCud6hdWzyJHq5YIelwYdeeR)ILaUzUyftSdgqkw8DalwqPILqnPaMjw)flbCZCXuRbofyITglbXUamIDWasXIHumFfWGyfBYAxSq51sqSeW9zyetNHVI5RHlMQpOKILcdGdhelVXWwSxRftSIjwpueeleJLhuQyPrnIfPrnmxS8dQxAPGyEGtbNPHybtSKhiiw)flbCZCXk2K1UyE3Iv5AdL)pOBzrO8Qh2MvtkfskZdCGaA)r)4M5Au)m6yO8QN9h3NHbTX3DnOFALU66MI7JHenAy)X9zyqB8DJH8OgwgKjlsSyVP15ZbMuSIj2bdiflyIrB9IPfxnUCee7xukGflsJAyUyjtmpWPGZ2ILvRWi2bRMuXsadW5Asfl5rnAiw5zntSqSCGSoYflnQrmVf7GbI5RGy1W8yCXEtRZNdmPyWsyelsJAyUyHySAsPGyEGtbxdXaMwqvbLIGy6lFvmARxS8G5agHTSiuE1dBZQjLcjL5XLwNphysnQFgvWCuVYHmidjKcLxlbuyG8cyN(PSiXIDI0qvbvmcTv2GyftSdgqkM(vyeZxbmK1mXcXEJJAelbmaNbX0IBLyHYRLGyiwTHTy9qrqm9RWiw5IPIrSligBnChWajIVf71AXeRyIfIXYdkvmVflhiRJCXsJAeRgXYBMlgR8JWREyBXqoA9ILhmhWiigfIHjM36dmjtSdwnPIvUy6xHrSyzu04sHTyz1kmIDWQjvmcT0Y9AsfthuGyXqk2ASSMuXIP9valMh4uWfBGaFrqdXkpRzIXOv6QtrqSl4oGfZBXoyGyNiHy6xHrSyzu04sbnelyI5RGymq1dPyEGtbxmYgytw7IDHb(Ll2h35IXwd3bCnPI5RGy5rnI5bof8TSiuE1dBZQjLcjL5rknuvqrzARSbnQFM7X)VV4Og0pgGZWgdHYrcjTyyjAQIC)Cd3EUn1rcPq51safgiVa2PFQRhuy8ntlTCVMu0sbByIlfiLfHYREyBwnPuiPmpkfGo9YqwekV6HTz1KsHKY84tpWye0O(zIZaUCyRVghWmumeQ1nmXLcK6QJ3J)FFXrnOFmaNHngcLR794)36RXbmdfdHADJHq5YIq5vpSnRMukKuMhFCZ8BtDzrO8Qh2MvtkfskZdvqPOHYREqPfZ1yICitEVeYHXLfHYREyBwnPuiPmpkfGsJrbYczrIflRkFvStKgQkOIrOTYg0qSKFmGy9xmDQ1dyXyR9bLuSli2bdifdxPRUyx43yqmFfe7ePHQcQyeARSbXuD(TfdXQnSftF5RIH8IPdQsrbMyXqkwi2BCuJyjGb4mG4BXYQvyelrV9CBQlwXeR)FXuDtjB9JgIL8JbeR)IPtTEalMkgXckRf7cIDWasXoHhmxm9LVkgYlMoOkffyBzrO8Qh22dkmokU1MbFmaA)r126bSg1pJhuy8DknuvqrzARSHnmXLcK6Ep()DPkffyBMhQSZG86Iy3J)FFXrnOFmaNHngcLJesEqHX3WTNBt9nmXLcK6Q6Ms26NnC752uFJH8Og2PubZr9khqCzrIflRkFTpCXorAOQGkgH2kBqdXs(XaI1FX0PwpGfJT2husXUGyhmGuSl8Bmiwmii2TstbSyQUPKT(rmelrV9CBQRHyiNDo4Ir4noxdXsEGGy9xSeWnZrCXASy6xHrSKFmGy9xmDQ1dyXkMyXTpCX8wmmeQvXsMyQ1aNcSTSiuE1dB7bfghf3AtkZd8XaO9hvBRhWAu)m6Ohuy8DknuvqrzARSHnmXLcK6IyEqHX3WTNBt9nmXLcK6Q6Ms26NnC752uFJH8Og2PubZr9khqcjpOW4BvNdokZBC(gM4sbsDvDtjB9Zw15GJY8gNVXqEud7uQG5OELdiHKhuy8noqaT)OFCZ8nmXLcK6Q6Ms26NnoqaT)OFCZ8ngYJAyNsfmh1RCajKuRbofyOFCO8QNGE6NBKlIZDUZ5a]] )


end
