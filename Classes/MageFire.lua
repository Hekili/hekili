-- MageFire.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 63, true )

    -- spec:RegisterResource( Enum.PowerType.ArcaneCharges )
    spec:RegisterResource( Enum.PowerType.Mana )
    
    -- Talents
    spec:RegisterTalents( {
        firestarter = 22456, -- 205026
        pyromaniac = 22459, -- 205020
        searing_touch = 22462, -- 269644

        blazing_soul = 23071, -- 235365
        shimmer = 22443, -- 212653
        blast_wave = 23074, -- 157981

        incanters_flow = 22444, -- 1463
        mirror_image = 22445, -- 55342
        rune_of_power = 22447, -- 116011

        flame_on = 22450, -- 205029
        alexstraszas_fury = 22465, -- 235870
        phoenix_flames = 22468, -- 257541

        frenetic_speed = 22904, -- 236058
        ice_ward = 22448, -- 205036
        ring_of_frost = 22471, -- 113724

        flame_patch = 22451, -- 205037
        conflagration = 23362, -- 205023
        living_bomb = 22472, -- 44457

        kindling = 21631, -- 155148
        pyroclasm = 22220, -- 269650
        meteor = 21633, -- 153561
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3583, -- 208683
        relentless = 3582, -- 196029
        adaptation = 3581, -- 214027

        prismatic_cloak = 828, -- 198064
        dampened_magic = 3524, -- 236788
        greater_pyroblast = 648, -- 203286
        flamecannon = 647, -- 203284
        kleptomania = 3530, -- 198100
        temporal_shield = 56, -- 198111
        netherwind_armor = 53, -- 198062
        tinder = 643, -- 203275
        world_in_flames = 644, -- 203280
        firestarter = 646, -- 203283
        controlled_burn = 645, -- 280450
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
        blast_wave = {
            id = 157981,
            duration = 4,
            max_stack = 1,
        },
        blazing_barrier = {
            id = 235313,
            duration = 60,
            type = "Magic",
            max_stack = 1,
        },
        blink = {
            id = 1953,
        },
        cauterize = {
            id = 86949,
        },
        combustion = {
            id = 190319,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        conflagration = {
            id = 226757,
            duration = 8.413,
            type = "Magic",
            max_stack = 1,
        },
        critical_mass = {
            id = 117216,
        },
        dragons_breath = {
            id = 31661,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        enhanced_pyrotechnics = {
            id = 157642,
            duration = 15,
            type = "Magic",
            max_stack = 10,
        },
        fire_blasting = {
            duration = 0.5,
            max_stack = 1,
            generate = function ()
                local last = action.fire_blast.lastCast
                local fb = buff.fire_blasting

                if query_time - last < 0.5 then
                    fb.count = 1
                    fb.applied = last
                    fb.expires = last + 0.5
                    fb.caster = "player"
                    return
                end

                fb.count = 0
                fb.applied = 0
                fb.expires = 0
                fb.caster = "nobody"
            end,
        },
        flamestrike = {
            id = 2120,
            duration = 8,
            max_stack = 1,
        },
        frenetic_speed = {
            id = 236060,
            duration = 3,
            max_stack = 1,
        },
        frost_nova = {
            id = 122,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        heating_up = {
            id = 48107,
            duration = 10,
            max_stack = 1,
        },
        hot_streak = {
            id = 48108,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        hypothermia = {
            id = 41425,
            duration = 30,
            max_stack = 1,
        },
        ice_block = {
            id = 45438,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        ignite = {
            id = 12654,
            duration = 9,
            type = "Magic",
            max_stack = 1,
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
        living_bomb = {
            id = 217694,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        living_bomb_spread = {
            id = 244813,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        meteor_burn = {
            id = 155158,
            duration = 3600,
            max_stack = 1,
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
        pyroclasm = {
            id = 269651,
            duration = 15,
            max_stack = 2,
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

        -- Azerite Powers
        blaster_master = {
            id = 274598,
            duration = 3,
            max_stack = 3,
        },

        wildfire = {
            id = 288800,
            duration = 10,
            max_stack = 1,
        },
    } )


    spec:RegisterStateTable( "firestarter", setmetatable( {}, {
        __index = setfenv( function( t, k )
            if k == "active" then return talent.firestarter.enabled and target.health.pct > 90
            elseif k == "remains" then
                if not talent.firestarter.enabled or target.health.pct <= 90 then return 0 end
                return max( 0, floor( target.time_to_die * 90 / target.health.pct ) )
            end
        end, state )
    } ) )


    spec:RegisterTotem( "rune_of_power", 609815 )

    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end
    end )
    

    spec:RegisterStateExpr( "auto_advance", function () return false end )


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
        

        blast_wave = {
            id = 157981,
            cast = 0,
            cooldown = 25,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135903,

            talent = "blast_wave",
            
            usable = function () return target.distance < 8 end,
            handler = function ()
                applyDebuff( "target", "blast_wave" )
            end,
        },
        

        blazing_barrier = {
            id = 235313,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            defensive = true,
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = false,
            texture = 132221,
            
            handler = function ()
                applyBuff( "blazing_barrier" )
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
                if talent.blazing_soul.enabled then applyBuff( "blazing_barrier" ) end
            end,

            copy = { 212653, 1953, "shimmer" }
        },


        combustion = {
            id = 190319,
            cast = 0,
            cooldown = 120,
            gcd = "off",
            castableWhileCasting = true,
            
            spend = 0.1,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135824,
            
            handler = function ()
                applyBuff( "combustion" )
                stat.crit = stat.crit + 100

                if azerite.wildfire.enabled then applyBuff( 'wildfire' ) end
            end,
        },
        

        --[[ conjure_refreshment = {
            id = 190336,
            cast = 3,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
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
        

        dragons_breath = {
            id = 31661,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = true,
            texture = 134153,
            
            usable = function () return target.within12 end,
            handler = function ()
                if talent.alexstraszas_fury.enabled then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end
                end

                applyDebuff( "target", "dragons_breath" )
            end,
        },
        

        fire_blast = {
            id = 108853,
            cast = 0,
            charges = function () return talent.flame_on.enabled and 3 or 2 end,
            cooldown = function () return talent.flame_on.enabled and 10 or 12 end,
            recharge = function () return talent.flame_on.enabled and 10 or 12 end,
            gcd = "off",
            castableWhileCasting = true,
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135807,

            nobuff = "fire_blasting", -- horrible.
            
            handler = function ()
                if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                else applyBuff( "heating_up" ) end

                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                if azerite.blaster_master.enabled then addStack( "blaster_master", nil, 1 ) end
                
                removeDebuff( "target", "preheat" )

                applyBuff( "fire_blasting" )
            end,
        },
        

        fireball = {
            id = 133,
            cast = 2.25,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135812,

            velocity = 45,

            -- Used by the real event handler, must use *real* data.
            -- Only purpose is to add any needed flags to the data table for onImpact.
            onRealCastFinish = function( data )
                if PlayerBuffUp( "combustion" ) then
                    data.willCrit = true
                end
            end,

            onCastFinish = function( data )
                if buff.combustion.up then
                    data.willCrit = true
                end
            end,

            onImpact = function( data )
                if data.willCrit or ( talent.firestarter.enabled and target.health.pct > 90 ) or ( stat.crit + ( buff.enhanced_pyrotechnics.stack * 10 ) >= 100 ) then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end

                    removeBuff( "enhanced_pyrotechnics" )

                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                else
                    removeBuff( "heating_up" )
                    addStack( "enhanced_pyrotechnics", nil, buff.enhanced_pyrotechnics.stack + 1 )
                end

                applyDebuff( "target", "ignite" )
                if talent.conflagration.enabled then applyDebuff( "target", "conflagration" ) end
            end,

            --[[ Old handler.
            handler = function ()
                if buff.combustion.up or ( talent.firestarter.enabled and target.health.pct > 90 ) or ( stat.crit + ( buff.enhanced_pyrotechnics.stack * 10 ) >= 100 ) then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end
                    
                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                else
                    addStack( "enhanced_pyrotechnics", nil, 1 )
                    removeBuff( "heating_up" )
                end

                applyDebuff( "target", "ignite" )
                if talent.conflagration.enabled then applyDebuff( "target", "conflagration" ) end
            end, ]]
        },
        

        flamestrike = {
            id = 2120,
            cast = function () return buff.hot_streak.up and 0 or 4 * haste end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135826,
            
            handler = function ()
                removeBuff( "hot_streak" )
                if buff.combustion.up then applyBuff( "heating_up" ) end

                applyDebuff( "target", "ignite" )
                applyDebuff( "target", "flamestrike" )
            end,
        },
        

        frost_nova = {
            id = 122,
            cast = 0,
            charges = function () return talent.ice_ward.enabled and 2 or nil end,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",
            
            defensive = true,

            spend = 0.02,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135848,
            
            handler = function ()
                applyDebuff( "target", "frost_nova" )
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
        

        living_bomb = {
            id = 44457,
            cast = 0,
            cooldown = 12,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 236220,
            
            handler = function ()
                applyDebuff( "target", "living_bomb" )
            end,
        },
        

        meteor = {
            id = 153561,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 1033911,

            velocity = function ()
                return target.maxR / 1.5
            end,
            
            onImpact = function ()
                applyDebuff( "target", "meteor_burn" )
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
        

        phoenix_flames = {
            id = 257541,
            cast = 0,
            charges = 3,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1392549,

            talent = "phoenix_flames",

            velocity = 50,
            
            onImpact = function ()
                if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                else applyBuff( "heating_up" ) end

                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
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
        

        pyroblast = {
            id = 11366,
            cast = function () return buff.hot_streak.up and 0 or 4.5 * haste end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135808,

            velocity = 35,

            -- Used by the real event handler, must use *real* data.
            -- Only purpose is to add any needed flags to the data table for onImpact.
            onRealCastFinish = function( data )
                if PlayerBuffUp( "combustion" ) or ( talent.firestarter.enabled and target.health.pct > 90 ) then
                    data.willCrit = true
                end
            end,

            onCastFinish = function( data )
                if buff.combustion.up or ( talent.firestarter.enabled and target.health.pct > 90 ) then
                    data.willCrit = true
                end

                removeBuff( "hot_streak" )
                removeStack( "pyroclasm" )
            end,

            onImpact = function( data )
                if Hekili.ActiveDebug then Hekili:Debug( "willCrit: %d, heating_up: %d, hot_streak: %d, ignite: %d", willCrit and 1 or 0, buff.heating_up.up and 1 or 0, buff.hot_streak.up and 1 or 0, debuff.ignite.up and 1 or 0 ) end

                if data.willCrit then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end

                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                else
                    removeBuff( "heating_up" )
                end

                applyDebuff( "target", "ignite" )
                if Hekili.ActiveDebug then Hekili:Debug( "willCrit: %d, heating_up: %d, hot_streak: %d, ignite: %d", willCrit and 1 or 0, buff.heating_up.up and 1 or 0, buff.hot_streak.up and 1 or 0, debuff.ignite.up and 1 or 0 ) end
            end,
            
            usable = function () 
                if action.pyroblast.cast > 0 and not boss then return false, "hardcasts only allowed on bosses" end
                return true
            end,

            --[[ handler = function ()
                if buff.combustion.up or ( talent.firestarter.enabled and target.health.pct > 90 ) then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end

                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                end

                if buff.hot_streak.up then
                    removeBuff( "hot_streak" )
                    removeStack( "pyroclasm" )
                end
                
                applyDebuff( "target", "ignite" )
            end, ]]
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
            
            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 609815,

            nobuff = "rune_of_power",
            talent = "rune_of_power",
            
            handler = function ()
                applyBuff( "rune_of_power" )
            end,
        },
        

        scorch = {
            id = 2948,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135827,
            
            handler = function ()
                if talent.frenetic_speed.enabled then applyBuff( "frenetic_speed" ) end

                if buff.combustion.up or stat.crit >= 100 then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end
                end

                applyDebuff( "target", "ignite" )

                if azerite.preheat.enabled then applyDebuff( "target", "preheat" ) end
            end,
        },
        

        slow_fall = {
            id = 130,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
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
        gcdSync = false,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "battle_potion_of_intellect",
        
        package = "Fire",
    } )


    spec:RegisterPack( "Fire", 20181211.0847, [[duK(NbqirrpIejTjiAuKGtbjTkiqvVsuXSeL6wqGyxa)Ie1WGeoMQOLjQINbbmnrvQRrIuBJeH(geinosK4CIQeRJerAEQcDpsY(ev1bHafSqrLEOOkjxecuQnsIaNecu0kjHUPOkP2POKHsIiwkjc6PO0uffUkeOK9sQ)svdMkhMYIf5XGMmkUmYMv4ZQsJwOoTuRgcu51qqZwWTvv7wPFlz4c54qGcTCvEoutN46kA7qOVtsnEirNxvW6jruZhsTFuT(PodnlJjKoR8GIN5fuKhu8eKheiVvk5jVOzLhIinBKbrO9sA21(KMvjOpsZgzpekJrNHMfxZdsA2yrIWkPkR8BlXZeawFLX9FgmPRfE2qug3FOYPqLuonmeegcrLJUA0bcRSsYrkHwZGvwjrj0NxBVKxjOpcG7puZMMDqqWC1jnlJjKoR8GIN5fuKhu8eKheiVvk5rPOzTPexNMLT)ZGjDT5vNnenBCZWqRoPzzimuZQu5oLG(iUlV2EjUIkvUlwKiSsQYk)2s8mbG1xzC)Nbt6AHNneLX9hQCkujLtddbHHqu5ORgDGWkRKCKsO1myLvsuc9512l5vc6Ja4(d5kQu5oLakDt7EG7EMn3Lhu8mVWDiiCxEqaL08wP5kYvuPYD5vX2(syLuUIkvUdbH7qWctCN0FYlLNPjU7mjMoUtITL7e7Ejbi9N8s5zAI7g1XDbdliiycwld3zPo0YdC3eBVegOzdnwW6m0SrhbRFYeDg6SEQZqZsRLceJoxTOZkp6m0S0APaXOZvl6SqaDgAwATuGy05QfDw5TodnRbLUwnRDqBjFVcfceu0S0APaXOZvl6SuADgAwATuGy05QzRinlMenRbLUwnlI21wkqAweTWK0SkruOzr0o)AFsZcRFAILUw)vrE4uQXql6SuI6m0S0APaXOZvl6Sqq1zOznO01Qz)9D157V9sAwATuGy05QfDwkfDgAwdkDTA2Os6A1S0APaXOZvl6SYl6m0Sgu6A1SrpCvkyyrZsRLceJoxTOfnB67H1pnXsxRpk2WKodDwp1zOzP1sbIrNRMfETqxBA20CmaW6NMyPRfWuQxnRbLUwnBOFJfShb3K59tROfDw5rNHMLwlfigDUAw41cDTPztZXaaRFAILUwatPE5oKCNbLgrYtl9BcZD5ZDp1Sgu6A1SHgXEF9P6N0IoleqNHMLwlfigDUAw41cDTPztZXaaRFAILUwatPE1Sgu6A1S3CjFn8rLA60IoR8wNHMLwlfigDUA2jM8QJ7a5Hgw69vZ(uZAqPRvZo6J8PGHfnl8AHU20SP5yasbdl05)gwOdWuQxUdj3Pa3jwGwbCZL81WhvQPdqRLced3HK7mO01cU5s(A4Jk10biusWP07l3HK7mO01cU5s(A4Jk10biusWPq(J(wVyU7rUdfaLi3Hgn3Pa3bRkWuQxaS(Pjw6AbhzmpWDOrZDP5yaG1pnXsxlygXDOYDi5Um5oXc0kGBUKVg(OsnDaATuGy4oKCxMCNbLUwq0dxLcgwa96hH(nw4oKCxMCNbLUwWOpkzHaOx)i0VXc3HQw0zP06m0S0APaXOZvZAqPRvZcTqWBqPR1hASOzdnw8R9jnRbLgrYlwGwbRfDwkrDgAwATuGy05QzNyYRoUdKhAyP3xn7tnl8AHU20SMsMUwiqkyyHo)3WcDaATuGy4oKCNcCNcCNbLUwWNeQoqV(rOFJfUdnAUl6ie9VqgWtWNeQoUdnAUdwvGPuVGpjuDGJ(wVyUlFUtP5ou5o0O5Um5oXc0kGpjuDaATuGy4ou5oKCNcCxAogGBUKVg(OsnDGze3Hgn3Lj3jwGwbCZL81WhvQPdqRLced3HQMDIjFng(xiJM9PM1GsxRMfw)0elDTArNfcQodnRbLUwnBujDTAwATuGy05QfDwkfDgAwdkDTA2uOkg)yEpOzP1sbIrNRw0zLx0zOznO01Qzt0HPdH9(QzP1sbIrNRw0z9ef6m0Sgu6A1SJ(OuOkgnlTwkqm6C1IoRNp1zOznO01QzTfsy5SGhAHGMLwlfigDUArN1Z8OZqZsRLceJoxnRbLUwnl0cbVbLUwFOXIMn0yXV2N0SY1lcjbRfDwpraDgAwATuGy05QzHxl01MMn6ie9VqgWtagwhmM7qYDP5yaIjt691pJaZinRbLUwnB0dxLcgw0IoRN5TodnlTwkqm6C1SWRf6AtZMMJbiUepwoYqiygPznO01QzJE4QuWWIw0z9uP1zOzP1sbIrNRMfETqxBA20CmarpCfmy4p4idkChsUdAyXl9N4Uh5U0CmaW6NMyPRfC036fRznO01QzJE4QuWWIw0z9ujQZqZAqPRvZgfx02O0pc2NWAwATuGy05QfDwprq1zOzP1sbIrNRMfETqxBA20CmaPGHf68Fdl0bWIbri3PI7EYDi5U0CmaXL4XYrgcbmL6L7qYDzYDP5yaIE4kyWWFWrgu4oKCx0ri6FHmGNGOhUkfmSWDi5of4U0CmaPGHf68Fdl0bo6B9I5Uh5ouaEQ0ChA0C3lKbC036fZDpYDOa8uP5ou1Sgu6A1SJ(iFkyyrZoXKVgd)lKrZ(ul6SEQu0zOzP1sbIrNRMDIjV64oqEOHLEF1Sp1Sgu6A1SJ(iFkyyrZcVwORnnBAogGuWWcD(VHf6ayXGiK7uXDp5oKCNcCNbLUwagwhmgqOKGtP3xUdj3zqPRfGH1bJbekj4ui)rFRxm39i3HcWtLM7qJM7sZXaKcgwOZ)nSqh4OV1lM7EK7qb4PsZDOQfDwpZl6m0S0APaXOZvZcVwORnnBAogG4s8y5idHaMs9YDi5of4oyvbMs9cg9r(uWWc4OV1lM7EK7Ggw8s)jUdnAUZGsxly0h5tbdlaySDVeM7YN7qb3HQM1GsxRMfdRdgRfDw5bf6m0S0APaXOZvZoXKxDChip0WsVVA2NAw41cDTPztZXaKcgwOZ)nSqhalgeHCx(C3tUdj3Pa3fDeI(xid4jadRdgZDi5Um5U0CmaXL4XYrgcbZiUdj3Lj3zqPRfGH1bJbekj4u69L7qJM7sZXaKcgwOZ)nSqh4OV1lM7EK7qb4PsZDOQzNyYxJH)fYOzFQznO01Qzh9r(uWWIw0zLNN6m0S0APaXOZvZcVwORnnBAogay9ttS01co6B9I5Uh5Uxid4BOK7qYDguAejpT0Vjm3Lp39uZAqPRvZgAe791NQFsl6SYtE0zOzP1sbIrNRMfETqxBA20CmaW6NMyPRfC036fZDpYDVqgW3qPM1GsxRML5S3AX(0rMeRfDw5bb0zOznO01QzXW6GXAwATuGy05QfTOzzOHndIodDwp1zOznO01QzH1Cf6WruiOzP1sbIrNRw0zLhDgAwATuGy05QzHxl01MMnnhdaS(Pjw6AbmL6vZAqPRvZ(77QZ3F7L0IoleqNHMLwlfigDUAw41cDTPzflqRag9ryXoHoaTwkqmChsUB0hHf7e6ah9TEXCx(C3ygc(JGX29sEP)e3Hgn3bRkWuQxaS(Pjw6Abh9TEXCx(ChI21wkqay9ttS016VkYdNsngChsUlnhdaS(Pjw6AbmL6L7qJM7K(tEP8mnXDpYDWQcmL6faRFAILUwWrFRxm3HK7sZXaaRFAILUwatPE1Sgu6A1S3CjFn8rLA60IoR8wNHMLwlfigDUAw41cDTPzvG7elqRaU5s(A4Jk10bO1sbIH7qYDWQcmL6faRFAILUwWrFRxm39OkUZGsxl4Ml5RHpQuthaAyXl9N4o0O5oyvbMs9cG1pnXsxl4iJ5bUdvUdj3Lj3n6JWIDcDadknIe3Hgn3LMJbaw)0elDTGzKM1GsxRMfAHG3GsxRp0yrZgAS4x7tAwy9ttS016JInmPfDwkTodnlTwkqm6C1SWRf6AtZMMJb4Ml5RHpQuthygXDi5U0CmaW6NMyPRfWuQxnRbLUwnl0cbVbLUwFOXIMn0yXV2N0Sxf5JInmPfDwkrDgAwATuGy05Qzr0ctsZkwGwbCZL81WhvQPdqRLced3HK7Gvfyk1l4Ml5RHpQuth4OV1lM7EK7Gvfyk1ly0h5tbdlGXme8hbJT7L8s)jUdj3Pa3bRkWuQxaS(Pjw6Abh9TEXCx(ChI21wkqay9ttS016VkYdNsngChA0C3Opcl2j0bmO0isChQChsUtbUdwvGPuVGBUKVg(OsnDGJ(wVyU7rUt6p5LYZ0e3Hgn3zqPRfCZL81WhvQPdaJT7LWCx(Chk4ou5o0O5oyvbMs9cG1pnXsxl4OV1lM7EK7mO01cg9r(uWWcymdb)rWy7EjV0FI7YH7Gvfyk1ly0h5tbdlaM5zsxl3HGN7mLmDTqGuWWcD(VHf6a0APaXWDi5Um5UrFewStOdyqPrK4oKChSQatPEbW6NMyPRfC036fZDpYDs)jVuEMM4o0O5oXc0kGrFewStOdqRLced3HK7g9ryXoHoGbLgrI7qYDJ(iSyNqh4OV1lM7EK7Gvfyk1ly0h5tbdlGXme8hbJT7L8s)jUlhUdwvGPuVGrFKpfmSayMNjDTChcEUZuY01cbsbdl05)gwOdqRLceJM1GsxRMfr7AlfinlI25x7tA2rFKpfmS4JQk07Rw0zHGQZqZsRLceJoxnlIwysAwXc0kGBUKVg(OsnDaATuGy4oKChSQatPEb3CjFn8rLA6ah9TEXC3JChSQatPEbrXfTnk9JG9jmymdb)rWy7EjV0FI7qYDWQcmL6faRFAILUwWrFRxm3Lp3HODTLceaw)0elDT(RI8WPuJb3HK7uG7Gvfyk1l4Ml5RHpQuth4OV1lM7EK7K(tEP8mnXDOrZDgu6Ab3CjFn8rLA6aWy7Ejm3Lp3HcUdvUdnAUdwvGPuVay9ttS01co6B9I5Uh5odkDTGO4I2gL(rW(egmMHG)iySDVKx6pXDi5oyvbMs9cG1pnXsxl4OV1lM7EK7K(tEP8mnPznO01Qzr0U2sbsZIOD(1(KMnkUOTrPpQQqVVArNLsrNHMLwlfigDUAwdkDTAwOfcEdkDT(qJfnBOXIFTpPzXITm2X4VsmPRvlArZEvKpk2WKodDwp1zOznO01QzV5s(A4Jk10PzP1sbIrNRw0zLhDgAwATuGy05QzHxl01MMvbUtbUtSaTcyeSp5JmbgdO1sbIH7qYDguAejpT0Vjm3Lp39K7qL7qJM7mO0isEAPFtyUlFUlV5ou5oKCxAogG4s8y5idHGJmOOznO01Qzhb7ty5AesArNfcOZqZsRLceJoxnl8AHU20SP5yaIlXJLJmecoYGIM1GsxRMn6HRsbdlArNvERZqZsRLceJoxn7etE1XDG8qdl9(QzFQzHxl01MMvbUdwvGPuVay9ttS01co6B9I5U85ouWDOrZDJ(iSyNqhWGsJiXDi5U0Cma3CjFn8rLA6aZiUdvUdj3Pa3Lj3LMJbiMmP3x)mcCKbfUdj3Lj3LMJbiUepwoYqi4idkChsUltUl6ie91y4FHmGrFKpfmSWDi5of4odkDTGrFKpfmSaGX29syUlFvCxE4o0O5of4odkDTGO4I2gL(rW(egaJT7LWCx(Q4UNChsUtSaTcikUOTrPFeSpHb0APaXWDOYDOrZDkWDIfOvawGqjwodRKnSFmVha0APaXWDi5oyvbMs9cyo7TwSpDKjXGJmMh4ou5o0O5of4oXc0kamzxVVEPMWyaTwkqmChsUtS7LeqmzbjgebfU7rvChcGcUdvUdnAUtbUtSaTcy0hHf7e6a0APaXWDi5UrFewStOdyqPrK4ou5ou5ou1Stm5RXW)cz0Sp1Sgu6A1SJ(iFkyyrl6SuADgAwATuGy05QznO01QzHwi4nO016dnw0SHgl(1(KM1GsJi5flqRG1IolLOodnlTwkqm6C1SWRf6AtZMMJbi6HRGbd)bhzqH7qYDqdlEP)e39i3LMJbi6HRGbd)bh9TEXChsUlnhdWnxYxdFuPMoWrFRxm3Lp3bnS4L(tAwdkDTA2OhUkfmSOfDwiO6m0S0APaXOZvZoXKxDChip0WsVVA2NAw41cDTPzvG7Gvfyk1law)0elDTGJ(wVyUlFUdfChA0C3Opcl2j0bmO0isChsUlnhdWnxYxdFuPMoWmI7qL7qYDkWDP5yaIjt691pJahzqH7qYDkWDIDVKaIjliXGiOWD5RI7qauWDOrZDzYDIfOvayYUEF9snHXaATuGy4ou5ou1Stm5RXW)cz0Sp1Sgu6A1SJ(iFkyyrl6Suk6m0S0APaXOZvZoXKxDChip0WsVVA2NAw41cDTPzvG7Gvfyk1law)0elDTGJ(wVyUlFUdfChA0C3Opcl2j0bmO0isChsUlnhdWnxYxdFuPMoWmI7qL7qYDIfOvayYUEF9snHXaATuGy4oKCNy3ljGyYcsmickC3JQ4oeafChsUtbUlnhdqmzsVV(ze4idkChsUltUZGsxladRdgdiusWP07l3Hgn3Lj3LMJbiMmP3x)mcCKbfUdj3Lj3LMJbiUepwoYqi4idkChQA2jM81y4FHmA2NAwdkDTA2rFKpfmSOfDw5fDgAwATuGy05QzHxl01MMn6ie9VqgWtagwhmM7qYDP5yaIjt691pJaZiUdj3jwGwbGj7691l1egdO1sbIH7qYDIDVKaIjliXGiOWDpQI7qauWDi5of4Um5oXc0kGrW(KpYeymGwlfigUdnAUZGsJi5PL(nH5ovC3tUdvnRbLUwnB0dxLcgw0IoRNOqNHMLwlfigDUAw41cDTPzZK7Iocr)lKb8eefx02O0pc2NWChsUlnhdqmzsVV(ze4idkAwdkDTA2O4I2gL(rW(ewl6SE(uNHMLwlfigDUAw41cDTPzf7EjbetwqIbrqH7Euf3HaOG7qYDIfOvayYUEF9snHXaATuGy0Sgu6A1SyyDWyTOZ6zE0zOzP1sbIrNRMfETqxBAwdknIKNw63eM7YN7YJM1GsxRML5S3AX(0rMeRfDwpraDgAwATuGy05QzHxl01MMvbUtSaTcyeSp5JmbgdO1sbIH7qYDguAejpT0Vjm3Lp3LhUdvUdnAUZGsJi5PL(nH5U85oLwZAqPRvZoc2NWY1iK0IoRN5TodnRbLUwn7OpkzHGMLwlfigDUArlAwy9ttS016JInmPZqN1tDgAwATuGy05QzHxl01MMnnhdaS(Pjw6AbmL6vZAqPRvZg63yb7rWnzE)0kArNvE0zOzP1sbIrNRMfETqxBAwtjtxleifmSqN)ByHoaTwkqmChsUtSaTcyeSp5RfqRLceJM1GsxRMfAHG3GsxRp0yrZgAS4x7tA203dRFAILUwFuSHjTOZcb0zOzP1sbIrNRMfETqxBA20CmaW6NMyPRfWuQxnRbLUwn7nxYxdFuPMoTOZkV1zOzP1sbIrNRM1GsxRMfAHG3GsxRp0yrZgAS4x7tAwdknIKxSaTcwl6SuADgAwATuGy05QzNyYRoUdKhAyP3xn7tnl8AHU20SkWDzYDMsMUwiqkyyHo)3WcDaATuGy4o0O5Um5oXc0kGrW(KVwaTwkqmChQChsUtbUtbUZGsxl4tcvhOx)i0VXc3Hgn3fDeI(xid4j4tcvh3Hgn3bRkWuQxWNeQoWrFRxm3Lp3P0ChQChA0CxMCNybAfWNeQoaTwkqmChQChsUtbUlnhdWnxYxdFuPMoWmI7qJM7YK7elqRaU5s(A4Jk10bO1sbIH7qvZoXKVgd)lKrZ(uZAqPRvZcRFAILUwTOZsjQZqZAqPRvZgvsxRMLwlfigDUArNfcQodnRbLUwnBkufJFmVh0S0APaXOZvl6Suk6m0Sgu6A1Sj6W0HWEF1S0APaXOZvl6SYl6m0Sgu6A1SJ(OuOkgnlTwkqm6C1IoRNOqNHM1GsxRM1wiHLZcEOfcAwATuGy05QfDwpFQZqZsRLceJoxnRbLUwnl0cbVbLUwFOXIMn0yXV2N0SY1lcjbRfDwpZJodnlTwkqm6C1SWRf6AtZQa3Pa3jwGwbmc2N8rMaJb0APaXWDi5odknIKNw63eM7YN7Yd3Hk3Hgn3zqPrK80s)MWCx(CNsK7qL7qYDP5yaIlXJLJmecoYGIM1GsxRMDeSpHLRriPfDwpraDgAwATuGy05QzHxl01MMnnhdq0dxbdg(doYGc3HK7sZXaaRFAILUwWrFRxm3Lp3bnS4L(tAwdkDTA2OhUkfmSOfDwpZBDgAwATuGy05QzHxl01MMnnhdqCjESCKHqWrgu0Sgu6A1SrpCvkyyrl6SEQ06m0S0APaXOZvZoXKxDChip0WsVVA2NAw41cDTPzvG7YK7mLmDTqGuWWcD(VHf6a0APaXWDOrZDzYDIfOvaJG9jFTaATuGy4ou5oKCNcCNcCxAogay9ttS01cMrChsUtbUlnhdqmzsVV(ze4idkChsUltUZGsxli6HRsbdlGE9Jq)glChsUltUZGsxladRdgdiusWP07l3Hk3Hgn3Pa3zqPRfGH1bJbekj4ui)rFRxm3HK7sZXaetM07RFgbyk1l3HK7sZXaexIhlhzieWuQxUdj3Lj3zqPRfe9WvPGHfqV(rOFJfUdvUdvUdvn7et(Am8Vqgn7tnRbLUwn7OpYNcgw0IoRNkrDgAwATuGy05QzHxl01MMn6ie9VqgWtagwhmM7qYDP5yaIjt691pJaZinRbLUwnB0dxLcgw0IoRNiO6m0Sgu6A1SrXfTnk9JG9jSMLwlfigDUArN1tLIodnlTwkqm6C1SWRf6AtZMMJbaw)0elDTGJ(wVyUlFUdAyXl9N4oKCxAogay9ttS01cMrChA0CxAogay9ttS01cyk1RM1GsxRMfdRdgRfDwpZl6m0S0APaXOZvZcVwORnnBAogay9ttS01co6B9I5Uh5Uxid4BOK7qYDguAejpT0Vjm3Lp39uZAqPRvZgAe791NQFsl6SYdk0zOzP1sbIrNRMfETqxBA20CmaW6NMyPRfC036fZDpYDVqgW3qj3HK7sZXaaRFAILUwWmsZAqPRvZYC2BTyF6itI1IoR88uNHMLwlfigDUAw41cDTPzf7EjbetwqIbrqH7Euf3HaOG7qYDIfOvayYUEF9snHXaATuGy0Sgu6A1SyyDWyTOfnRbLgrYlwGwbRZqN1tDgAwATuGy05QzHxl01MM1GsJi5PL(nH5U85UNChsUlnhdaS(Pjw6AbmL6L7qYDkWDWQcmL6faRFAILUwWrFRxm3Lp3bRkWuQxqOrS3xFQ(jaZ8mPRL7qJM7Gvfyk1law)0elDTGJmMh4ou1Sgu6A1SHgXEF9P6N0IoR8OZqZsRLceJoxnl8AHU20SP5yaU5s(A4Jk10bMrChsUtbUB0hHf7e6ah9TEXCx(ChSQatPEbFsO6amZZKUwUdnAUltUB0hHf7e6aguAejUdvUdnAUdwvGPuVGBUKVg(OsnDGJ(wVyUlFUt6p5LYZ0e3HK7mO01cU5s(A4Jk10bGX29syU7rU7j3Hgn3Pa3bRkWuQxWNeQoaZ8mPRL7EK7Gvfyk1law)0elDTGJ(wVyUdnAUdwvGPuVay9ttS01coYyEG7qL7qYDzYDIfOva3CjFn8rLA6a0APaXWDi5of4oyvbMs9c(Kq1byMNjDTC3JC3Opcl2j0bo6B9I5o0O5Um5oXc0kGrFewStOdqRLced3Hgn3Lj3n6JWIDcDadknIe3HQM1GsxRM9tcvNw0IMfl2YyhJ)kXKUwDg6SEQZqZsRLceJoxnl8AHU20SkWDkWDIfOvaJG9jFKjWyaTwkqmChsUZGsJi5PL(nH5U85UNChsUltUB0hHf7e6aguAejUdvUdnAUZGsJi5PL(nH5U85U8M7qL7qYDP5yaIlXJLJmecoYGIM1GsxRMDeSpHLRriPfDw5rNHMLwlfigDUAw41cDTPztZXaexIhlhzieCKbfUdj3LMJbiUepwoYqi4OV1lM7EK7mO01cg9rjleaekj4uiV0FsZAqPRvZg9WvPGHfTOZcb0zOzP1sbIrNRMfETqxBA20CmaXL4XYrgcbhzqH7qYDkWDrhHO)fYaEcg9rjle4o0O5UrFewStOdyqPrK4o0O5odkDTGOhUkfmSa61pc9BSWDOQznO01QzJE4QuWWIw0zL36m0S0APaXOZvZcVwORnnBAogG4s8y5idHGJmOWDi5oXUxsaXKfKyqeu4UhvXDiak4oKCNybAfaMSR3xVutymGwlfignRbLUwnB0dxLcgw0IolLwNHMLwlfigDUAw41cDTPztZXae9WvWGH)GJmOWDi5oOHfV0FI7EK7sZXae9WvWGH)GJ(wVynRbLUwnB0dxLcgw0IolLOodnlTwkqm6C1Stm5vh3bYdnS07RM9PMfETqxBAwf4oyvbMs9cG1pnXsxl4OV1lM7YN7qb3HK7sZXaCZL81WhvQPdWuQxUdnAUB0hHf7e6aguAejUdvUdj3Lj3jwGwbGWEzc9(cO1sbIH7qYDzYDiAxBPabg9r(uWWIpQQqVVChsUtbUtbUtbUZGsxly0hLSqaqOKGtP3xUdnAUZGsxli6HRsbdlacLeCk9(YDOYDi5of4U0CmaXKj9(6NrGJmOWDOrZDJ(iSyNqhWGsJiXDi5Um5U0CmaXL4XYrgcbhzqH7qYDzYDP5yaIjt691pJahzqH7qL7qL7qJM7uG7elqRaWKD9(6LAcJb0APaXWDi5oXUxsaXKfKyqeu4UhvXDiak4oKCNcCxAogGyYKEF9ZiWrgu4oKCxMCNbLUwagwhmgqOKGtP3xUdnAUltUlnhdqCjESCKHqWrgu4oKCxMCxAogGyYKEF9ZiWrgu4oKCNbLUwagwhmgqOKGtP3xUdj3Lj3zqPRfe9WvPGHfqV(rOFJfUdj3Lj3zqPRfm6Jswia61pc9BSWDOYDOYDOrZDkWDJ(iSyNqhWGsJiXDi5of4odkDTGOhUkfmSa61pc9BSWDOrZDgu6AbJ(OKfcGE9Jq)glChQChsUltUlnhdqmzsVV(ze4idkChsUltUlnhdqCjESCKHqWrgu4ou5ou1Stm5RXW)cz0Sp1Sgu6A1SJ(iFkyyrl6Sqq1zOzP1sbIrNRMfETqxBAwXc0kae2ltO3xaTwkqmChsUlnhdqmzsVV(ze4idkChsUtbUdwvGPuVay9ttS01co6B9I5U85UXme8hbJT7L8s)jUlhUlpCxoCNybAfac7Lj07lGwlfigUdnAUB0hHf7e6ah9TEXCx(C3ygc(JGX29sEP)e3Hgn3Pa3Lj3jwGwbCZL81WhvQPdqRLced3Hgn3bRkWuQxWnxYxdFuPMoWrFRxm3Lp3j9N8s5zAI7qYDgu6Ab3CjFn8rLA6aWy7Ejm39i39K7qL7qYDWQcmL6faRFAILUwWrFRxm3Lp3j9N8s5zAI7qvZAqPRvZo6J8PGHfTOZsPOZqZsRLceJoxnl8AHU20SrhHO)fYaEcWW6GXChsUlnhdqmzsVV(zeygXDi5oXc0kamzxVVEPMWyaTwkqmChsUtS7LeqmzbjgebfU7rvChcGcUdj3Pa3Pa3jwGwbmc2N8rMaJb0APaXWDi5odknIKNw63eM7uXDp5oKCxMC3Opcl2j0bmO0isChQChA0CNcCNbLgrYtl9BcZDpYD5n3HK7YK7elqRagb7t(itGXaATuGy4ou5ou1Sgu6A1SrpCvkyyrl6SYl6m0S0APaXOZvZcVwORnnRcCxAogGyYKEF9ZiWrgu4o0O5of4Um5U0CmaXL4XYrgcbhzqH7qYDkWDgu6AbJ(iFkyybaJT7LWCx(Chk4o0O5oXc0kamzxVVEPMWyaTwkqmChsUtS7LeqmzbjgebfU7rvChcGcUdvUdvUdvUdj3Lj3HODTLceikUOTrPpQQqVVAwdkDTA2O4I2gL(rW(ewl6SEIcDgAwATuGy05QznO01QzHwi4nO016dnw0SHgl(1(KM1GsJi5flqRG1IoRNp1zOzP1sbIrNRMfETqxBAwdknIKNw63eM7YN7EQznO01Qzzo7TwSpDKjXArN1Z8OZqZsRLceJoxnRbLUwnR0mewQ77HfdHsnl8AHU20SWQcmL6faRFAILUwWrFRxm3Lp3LhuWDOrZDIfOvaJ(iSyNqhGwlfigUdj3n6JWIDcDGJ(wVyUlFUlpOqZU2N0SsZqyPUVhwmek1IoRNiGodnlTwkqm6C1SWRf6AtZk29sciMSGedIGc39OkUdbqb3HK7elqRaWKD9(6LAcJb0APaXOznO01QzXW6GXArN1Z8wNHM1GsxRMD0hLSqqZsRLceJoxTOZ6PsRZqZAqPRvZIH1bJ1S0APaXOZvlArZkxViKeSodDwp1zOznO01QzNyY3c9XAwATuGy05QfTOfnlI0H7A1zLhu8uP8mppFcqHsjVrq1SQTB79fRzrW8hvNqmCNsH7mO01YDHglyaxrnB0vJoqAwLk3Pe0hXD512lXvuPYDXIeHvsvw53wINjaS(kJ7)mysxl8SHOmU)qLtHkPCAyiimeIkhD1OdewzLKJucTMbRSsIsOpV2EjVsqFea3FixrLk3PeqPBA3dC3ZS5U8GIN5fUdbH7YdcOKM3knxrUIkvUlVk22xcRKYvuPYDiiChcwyI7K(tEP8mnXDNjX0XDsSTCNy3ljaP)KxkpttC3OoUlyybbbtWAz4ol1HwEG7My7LWaUICfvQChc2OKGtHy4UenQJ4oy9tMWDj6TxmG7qWaesrcM72ArqIT7pMbUZGsxlM7Qn8aGRObLUwmi6iy9tMOAemmc5kAqPRfdIocw)Kj5Os5rvmCfnO01IbrhbRFYKCuPSnF)0kM01Yv0GsxlgeDeS(jtYrLY2bTL89kuiqqHROsL7YiUXChI21wkqChMem3jXe3j9N4ot4o1XnmM7ucNlXD1G7usk10XD44Agy4oSyNWDjQ3xUdBismC3OoUtIjUBjukCxEv9ttS01YDrXgM4kAqPRfdIocw)Kj5OszeTRTuGYETpPcw)0elDT(RI8WPuJr2vKkmjzJOfMKkLik4kAqPRfdIocw)Kj5Osz8Ar44s8yXemxrdkDTyq0rW6Nmjhvk)77QZ3F7L4kAqPRfdIocw)Kj5Os5Os6A5kAqPRfdIocw)Kj5Os5OhUkfmSWvKROsL7qWgLeCked3ris3dCN0FI7KyI7mOuh31yUZq06GLceGRObLUwSkynxHoCefcCfnO01IZrLY)(U6893EPS7HQ0CmaW6NMyPRfWuQxUIgu6AX5Os5BUKVg(OsnDz3dvIfOvaJ(iSyNqhGwlfigKJ(iSyNqh4OV1lo)Xme8hbJT7L8s)j0OHvfyk1law)0elDTGJ(wV48r0U2sbcaRFAILUw)vrE4uQXazAogay9ttS01cyk1lA0s)jVuEMMEewvGPuVay9ttS01co6B9IrMMJbaw)0elDTaMs9Yv0GsxlohvkdTqWBqPR1hASK9AFsfS(Pjw6A9rXgMYUhQuqSaTc4Ml5RHpQuthGwlfigKWQcmL6faRFAILUwWrFRx8JQmO01cU5s(A4Jk10bGgw8s)j0OHvfyk1law)0elDTGJmMhqfzMJ(iSyNqhWGsJiHgDAogay9ttS01cMrCfnO01IZrLYqle8gu6A9HglzV2NuDvKpk2Wu29qvAogGBUKVg(OsnDGzeY0CmaW6NMyPRfWuQxUIgu6AX5OszeTRTuGYETpPA0h5tbdl(OQc9(MnIwysQelqRaU5s(A4Jk10bO1sbIbjSQatPEb3CjFn8rLA6ah9TEXpcRkWuQxWOpYNcgwaJzi4pcgB3l5L(tivawvGPuVay9ttS01co6B9IZhr7AlfiaS(Pjw6A9xf5HtPgd0Oh9ryXoHoGbLgrcvKkaRkWuQxWnxYxdFuPMoWrFRx8Js)jVuEMMqJ2Gsxl4Ml5RHpQuthagB3lHZhfOIgnSQatPEbW6NMyPRfC036f)ObLUwWOpYNcgwaJzi4pcgB3l5L(t5aRkWuQxWOpYNcgwamZZKUwe8MsMUwiqkyyHo)3WcDaATuGyqM5Opcl2j0bmO0isiHvfyk1law)0elDTGJ(wV4hL(tEP8mnHgTybAfWOpcl2j0bO1sbIb5Opcl2j0bmO0isih9ryXoHoWrFRx8JWQcmL6fm6J8PGHfWygc(JGX29sEP)uoWQcmL6fm6J8PGHfaZ8mPRfbVPKPRfcKcgwOZ)nSqhGwlfigUIgu6AX5OszeTRTuGYETpPkkUOTrPpQQqVVzJOfMKkXc0kGBUKVg(OsnDaATuGyqcRkWuQxWnxYxdFuPMoWrFRx8JWQcmL6fefx02O0pc2NWGXme8hbJT7L8s)jKWQcmL6faRFAILUwWrFRxC(iAxBPabG1pnXsxR)QipCk1yGubyvbMs9cU5s(A4Jk10bo6B9IFu6p5LYZ0eA0gu6Ab3CjFn8rLA6aWy7EjC(Oav0OHvfyk1law)0elDTGJ(wV4hnO01cIIlABu6hb7tyWygc(JGX29sEP)esyvbMs9cG1pnXsxl4OV1l(rP)KxkpttCfnO01IZrLYqle8gu6A9HglzV2NuHfBzSJXFLysxlxrUIgu6AXadknIKxSaTcwvOrS3xFQ(PS7HkdknIKNw63eo)NitZXaaRFAILUwatPErQaSQatPEbW6NMyPRfC036fNpSQatPEbHgXEF9P6NamZZKUw0OHvfyk1law)0elDTGJmMhqLRObLUwmWGsJi5flqRGZrLYFsO6YUhQsZXaCZL81WhvQPdmJqQWOpcl2j0bo6B9IZhwvGPuVGpjuDaM5zsxlA0zo6JWIDcDadknIeQOrdRkWuQxWnxYxdFuPMoWrFRxC(s)jVuEMMqAqPRfCZL81WhvQPdaJT7LWp(enAfGvfyk1l4tcvhGzEM01(iSQatPEbW6NMyPRfC036fJgnSQatPEbW6NMyPRfCKX8aQiZuSaTc4Ml5RHpQuthGwlfigKkaRkWuQxWNeQoaZ8mPR9XrFewStOdC036fJgDMIfOvaJ(iSyNqhGwlfig0OZC0hHf7e6aguAeju5kYv0GsxlgK(Ey9ttS016JInmPk0VXc2JGBY8(PvYUhQsZXaaRFAILUwatPE5kAqPRfdsFpS(Pjw6A9rXgMYrLYHgXEF9P6NYUhQsZXaaRFAILUwatPErAqPrK80s)MW5)KRObLUwmi99W6NMyPR1hfBykhvkFZL81WhvQPl7EOknhdaS(Pjw6AbmL6LRObLUwmi99W6NMyPR1hfBykhvkp6J8PGHLSNyYRoUdKhAyP3xvpZUhQsZXaKcgwOZ)nSqhGPuVivqSaTc4Ml5RHpQuthGwlfigKgu6Ab3CjFn8rLA6aekj4u69fPbLUwWnxYxdFuPMoaHscofYF036f)ikakr0OvawvGPuVay9ttS01coYyEan60CmaW6NMyPRfmJqfzMIfOva3CjFn8rLA6a0APaXGmtdkDTGOhUkfmSa61pc9BSGmtdkDTGrFuYcbqV(rOFJfu5kAqPRfdsFpS(Pjw6A9rXgMYrLYqle8gu6A9HglzV2NuzqPrK8IfOvWCfnO01IbPVhw)0elDT(Oydt5Oszy9ttS01M9et(Am8VqgvpZEIjV64oqEOHLEFv9m7EOYuY01cbsbdl05)gwOdqRLcedsfuWGsxl4tcvhOx)i0VXcA0rhHO)fYaEc(Kq1HgnSQatPEbFsO6ah9TEX5R0OIgDMIfOvaFsO6a0APaXGksfsZXaCZL81WhvQPdmJqJotXc0kGBUKVg(OsnDaATuGyqLRObLUwmi99W6NMyPR1hfBykhvkhvsxlxrdkDTyq67H1pnXsxRpk2WuoQuofQIXpM3dCfnO01IbPVhw)0elDT(Oydt5Os5eDy6qyVVCfnO01IbPVhw)0elDT(Oydt5Os5rFukufdxrdkDTyq67H1pnXsxRpk2WuoQu2wiHLZcEOfcCfnO01IbPVhw)0elDT(Oydt5OszOfcEdkDT(qJLSx7tQKRxescMRObLUwmi99W6NMyPR1hfBykhvkh9WvPGHLS7HQOJq0)czapbyyDWyKP5yaIjt691pJaZiUIgu6AXG03dRFAILUwFuSHPCuPC0dxLcgwYUhQsZXaexIhlhziemJ4kAqPRfdsFpS(Pjw6A9rXgMYrLYrpCvkyyj7EOknhdq0dxbdg(doYGcsOHfV0F6X0CmaW6NMyPRfC036fZv0GsxlgK(Ey9ttS016JInmLJkLJIlABu6hb7tyUIgu6AXG03dRFAILUwFuSHPCuP8OpYNcgwYEIjFng(xiJQNz3dvP5yasbdl05)gwOdGfdIqvprMMJbiUepwoYqiGPuViZmnhdq0dxbdg(doYGcYOJq0)czapbrpCvkyybPcP5yasbdl05)gwOdC036f)ikapvA0OFHmGJ(wV4hrb4PsJkxrdkDTyq67H1pnXsxRpk2WuoQuE0h5tbdlzpXKxDChip0WsVVQEMDpuLMJbifmSqN)ByHoawmicv9ePcgu6AbyyDWyaHscoLEFrAqPRfGH1bJbekj4ui)rFRx8JOa8uPrJonhdqkyyHo)3WcDGJ(wV4hrb4PsJkxrdkDTyq67H1pnXsxRpk2WuoQugdRdgNDpuLMJbiUepwoYqiGPuVivawvGPuVGrFKpfmSao6B9IFeAyXl9NqJ2Gsxly0h5tbdlaySDVeoFuGkxrdkDTyq67H1pnXsxRpk2WuoQuE0h5tbdlzpXKxDChip0WsVVQEM9et(Am8VqgvpZUhQsZXaKcgwOZ)nSqhalgeH5)ePcrhHO)fYaEcWW6GXiZmnhdqCjESCKHqWmczMgu6AbyyDWyaHscoLEFrJonhdqkyyHo)3WcDGJ(wV4hrb4PsJkxrdkDTyq67H1pnXsxRpk2WuoQuo0i27Rpv)u29qvAogay9ttS01co6B9IF8fYa(gkrAqPrK80s)MW5)KRObLUwmi99W6NMyPR1hfBykhvkZC2BTyF6itIZUhQsZXaaRFAILUwWrFRx8JVqgW3qjxrdkDTyq67H1pnXsxRpk2WuoQugdRdgZvKROsL7YRQFAILUwUlk2We3fDuKDeM7SuhAPjm3PULyUZ4ogkypKn3jX0YDbBUWycZD9kf3jXe3Lxv)0elDTChMqW4KwiXv0GsxlgaRFAILUwFuSHjvH(nwWEeCtM3pTs29qvAogay9ttS01cyk1lxrdkDTyaS(Pjw6A9rXgMYrLYqle8gu6A9HglzV2NuL(Ey9ttS016JInmLDpuzkz6AHaPGHf68Fdl0bO1sbIbPybAfWiyFYxlGwlfigUIgu6AXay9ttS016JInmLJkLV5s(A4Jk10LDpuLMJbaw)0elDTaMs9Yv0GsxlgaRFAILUwFuSHPCuPm0cbVbLUwFOXs2R9jvguAejVybAfmxrdkDTyaS(Pjw6A9rXgMYrLYW6NMyPRn7jM81y4FHmQEM9etE1XDG8qdl9(Q6z29qLczAkz6AHaPGHf68Fdl0bO1sbIbn6mflqRagb7t(Ab0APaXGksfuWGsxl4tcvhOx)i0VXcA0rhHO)fYaEc(Kq1HgnSQatPEbFsO6ah9TEX5R0OIgDMIfOvaFsO6a0APaXGksfsZXaCZL81WhvQPdmJqJotXc0kGBUKVg(OsnDaATuGyqLRObLUwmaw)0elDT(Oydt5Os5Os6A5kAqPRfdG1pnXsxRpk2WuoQuofQIXpM3dCfnO01IbW6NMyPR1hfBykhvkNOdthc79LRObLUwmaw)0elDT(Oydt5Os5rFukufdxrdkDTyaS(Pjw6A9rXgMYrLY2cjSCwWdTqGRObLUwmaw)0elDT(Oydt5OszOfcEdkDT(qJLSx7tQKRxescMRObLUwmaw)0elDT(Oydt5Os5rW(ewUgHu29qLckiwGwbmc2N8rMaJb0APaXG0GsJi5PL(nHZppOIgTbLgrYtl9BcNVsevKP5yaIlXJLJmecoYGcxrdkDTyaS(Pjw6A9rXgMYrLYrpCvkyyj7EOknhdq0dxbdg(doYGcY0CmaW6NMyPRfC036fNp0WIx6pXv0GsxlgaRFAILUwFuSHPCuPC0dxLcgwYUhQsZXaexIhlhzieCKbfUIgu6AXay9ttS016JInmLJkLh9r(uWWs2tm5RXW)czu9m7jM8QJ7a5Hgw69v1ZS7HkfY0uY01cbsbdl05)gwOdqRLcedA0zkwGwbmc2N81cO1sbIbvKkOqAogay9ttS01cMrivinhdqmzsVV(ze4idkiZ0Gsxli6HRsbdlGE9Jq)gliZ0GsxladRdgdiusWP07lQOrRGbLUwagwhmgqOKGtH8h9TEXitZXaetM07RFgbyk1lY0CmaXL4XYrgcbmL6fzMgu6AbrpCvkyyb0RFe63ybvurLRObLUwmaw)0elDT(Oydt5Os5OhUkfmSKDpufDeI(xid4jadRdgJmnhdqmzsVV(zeygXv0GsxlgaRFAILUwFuSHPCuPCuCrBJs)iyFcZv0GsxlgaRFAILUwFuSHPCuPmgwhmo7EOknhdaS(Pjw6Abh9TEX5dnS4L(titZXaaRFAILUwWmcn60CmaW6NMyPRfWuQxUIgu6AXay9ttS016JInmLJkLdnI9(6t1pLDpuLMJbaw)0elDTGJ(wV4hFHmGVHsKguAejpT0VjC(p5kAqPRfdG1pnXsxRpk2WuoQuM5S3AX(0rMeNDpuLMJbaw)0elDTGJ(wV4hFHmGVHsKP5yaG1pnXsxlygXv0GsxlgaRFAILUwFuSHPCuPmgwhmo7EOsS7LeqmzbjgebLhvHaOaPybAfaMSR3xVutymGwlfigUICfnO01Ibxf5JInmP6Ml5RHpQuthxrdkDTyWvr(Oydt5Os5rW(ewUgHu29qLckiwGwbmc2N8rMaJb0APaXG0GsJi5PL(nHZ)jQOrBqPrK80s)MW5N3OImnhdqCjESCKHqWrgu4kAqPRfdUkYhfBykhvkh9WvPGHLS7HQ0CmaXL4XYrgcbhzqHRObLUwm4QiFuSHPCuP8OpYNcgwYEIjFng(xiJQNzpXKxDChip0WsVVQEMDpuPaSQatPEbW6NMyPRfC036fNpkqJE0hHf7e6aguAejKP5yaU5s(A4Jk10bMrOIuHmtZXaetM07RFgboYGcYmtZXaexIhlhzieCKbfKzgDeI(Am8VqgWOpYNcgwqQGbLUwWOpYNcgwaWy7EjC(QYdA0kyqPRfefx02O0pc2NWaySDVeoFvprkwGwbefx02O0pc2NWaATuGyqfnAfelqRaSaHsSCgwjBy)yEpaO1sbIbjSQatPEbmN9wl2NoYKyWrgZdOIgTcIfOvayYUEF9snHXaATuGyqk29sciMSGedIGYJQqauGkA0kiwGwbm6JWIDcDaATuGyqo6JWIDcDadknIeQOIkxrdkDTyWvr(Oydt5OszOfcEdkDT(qJLSx7tQmO0isEXc0kyUIgu6AXGRI8rXgMYrLYrpCvkyyj7EOknhdq0dxbdg(doYGcsOHfV0F6X0CmarpCfmy4p4OV1lgzAogGBUKVg(OsnDGJ(wV48Hgw8s)jUIgu6AXGRI8rXgMYrLYJ(iFkyyj7jM81y4FHmQEM9etE1XDG8qdl9(Q6z29qLcWQcmL6faRFAILUwWrFRxC(Oan6rFewStOdyqPrKqMMJb4Ml5RHpQuthygHksfsZXaetM07RFgboYGcsfe7EjbetwqIbrqjFviakqJotXc0kamzxVVEPMWyaTwkqmOIkxrdkDTyWvr(Oydt5Os5rFKpfmSK9et(Am8VqgvpZEIjV64oqEOHLEFv9m7EOsbyvbMs9cG1pnXsxl4OV1loFuGg9Opcl2j0bmO0isitZXaCZL81WhvQPdmJqfPybAfaMSR3xVutymGwlfigKIDVKaIjliXGiO8OkeafivinhdqmzsVV(ze4idkiZ0GsxladRdgdiusWP07lA0zMMJbiMmP3x)mcCKbfKzMMJbiUepwoYqi4idkOYv0GsxlgCvKpk2WuoQuo6HRsbdlz3dvrhHO)fYaEcWW6GXitZXaetM07RFgbMriflqRaWKD9(6LAcJb0APaXGuS7LeqmzbjgebLhvHaOaPczkwGwbmc2N8rMaJb0APaXGgTbLgrYtl9BcR6jQCfnO01Ibxf5JInmLJkLJIlABu6hb7t4S7HQmJocr)lKb8eefx02O0pc2NWitZXaetM07RFgboYGcxrdkDTyWvr(Oydt5OszmSoyC29qLy3ljGyYcsmickpQcbqbsXc0kamzxVVEPMWyaTwkqmCfnO01Ibxf5JInmLJkLzo7TwSpDKjXz3dvguAejpT0VjC(5HRObLUwm4QiFuSHPCuP8iyFclxJqk7EOsbXc0kGrW(KpYeymGwlfigKguAejpT0VjC(5bv0OnO0isEAPFt48vAUIgu6AXGRI8rXgMYrLYJ(OKfcCf5kAqPRfdWITm2X4VsmPRv1iyFclxJqk7EOsbfelqRagb7t(itGXaATuGyqAqPrK80s)MW5)ezMJ(iSyNqhWGsJiHkA0guAejpT0VjC(5nQitZXaexIhlhzieCKbfUIgu6AXaSylJDm(Ret6AZrLYrpCvkyyj7EOknhdqCjESCKHqWrguqMMJbiUepwoYqi4OV1l(rdkDTGrFuYcbaHscofYl9N4kAqPRfdWITm2X4VsmPRnhvkh9WvPGHLS7HQ0CmaXL4XYrgcbhzqbPcrhHO)fYaEcg9rjleqJE0hHf7e6aguAej0OnO01cIE4QuWWcOx)i0VXcQCfnO01IbyXwg7y8xjM01MJkLJE4QuWWs29qvAogG4s8y5idHGJmOGuS7LeqmzbjgebLhvHaOaPybAfaMSR3xVutymGwlfigUIgu6AXaSylJDm(Ret6AZrLYrpCvkyyj7EOknhdq0dxbdg(doYGcsOHfV0F6X0CmarpCfmy4p4OV1lMRObLUwmal2YyhJ)kXKU2CuP8OpYNcgwYEIjFng(xiJQNzpXKxDChip0WsVVQEMDpuPaSQatPEbW6NMyPRfC036fNpkqMMJb4Ml5RHpQuthGPuVOrp6JWIDcDadknIeQiZuSaTcaH9Ye69fqRLcedYmr0U2sbcm6J8PGHfFuvHEFrQGckyqPRfm6JswiaiusWP07lA0gu6AbrpCvkyybqOKGtP3xurQqAogGyYKEF9ZiWrguqJE0hHf7e6aguAejKzMMJbiUepwoYqi4idkiZmnhdqmzsVV(ze4idkOIkA0kiwGwbGj7691l1egdO1sbIbPy3ljGyYcsmickpQcbqbsfsZXaetM07RFgboYGcYmnO01cWW6GXacLeCk9(IgDMP5yaIlXJLJmecoYGcYmtZXaetM07RFgboYGcsdkDTamSoymGqjbNsVViZ0Gsxli6HRsbdlGE9Jq)gliZ0Gsxly0hLSqa0RFe63ybvurJwHrFewStOdyqPrKqQGbLUwq0dxLcgwa96hH(nwqJ2Gsxly0hLSqa0RFe63ybvKzMMJbiMmP3x)mcCKbfKzMMJbiUepwoYqi4idkOIkxrdkDTyawSLXog)vIjDT5Os5rFKpfmSKDpujwGwbGWEzc9(cO1sbIbzAogGyYKEF9ZiWrguqQaSQatPEbW6NMyPRfC036fN)ygc(JGX29sEP)uo5jhXc0kae2ltO3xaTwkqmOrp6JWIDcDGJ(wV48hZqWFem2UxYl9NqJwHmflqRaU5s(A4Jk10bO1sbIbnAyvbMs9cU5s(A4Jk10bo6B9IZx6p5LYZ0esdkDTGBUKVg(OsnDaySDVe(XNOIewvGPuVay9ttS01co6B9IZx6p5LYZ0eQCfnO01IbyXwg7y8xjM01MJkLJE4QuWWs29qv0ri6FHmGNamSoymY0CmaXKj9(6NrGzesXc0kamzxVVEPMWyaTwkqmif7EjbetwqIbrq5rviakqQGcIfOvaJG9jFKjWyaTwkqminO0isEAPFtyvprM5Opcl2j0bmO0isOIgTcguAejpT0Vj8J5nYmflqRagb7t(itGXaATuGyqfvUIgu6AXaSylJDm(Ret6AZrLYrXfTnk9JG9jC29qLcP5yaIjt691pJahzqbnAfYmnhdqCjESCKHqWrguqQGbLUwWOpYNcgwaWy7EjC(OanAXc0kamzxVVEPMWyaTwkqmif7EjbetwqIbrq5rviakqfvurMjI21wkqGO4I2gL(OQc9(Yv0GsxlgGfBzSJXFLysxBoQugAHG3GsxRp0yj71(KkdknIKxSaTcMRObLUwmal2YyhJ)kXKU2CuPmZzV1I9PJmjo7EOYGsJi5PL(nHZ)jxrdkDTyawSLXog)vIjDT5Os5jM8Tq)Sx7tQKMHWsDFpSyiuMDpubRkWuQxaS(Pjw6Abh9TEX5NhuGgTybAfWOpcl2j0bO1sbIb5Opcl2j0bo6B9IZppOGRObLUwmal2YyhJ)kXKU2CuPmgwhmo7EOsS7LeqmzbjgebLhvHaOaPybAfaMSR3xVutymGwlfigUIgu6AXaSylJDm(Ret6AZrLYJ(OKfcCfnO01IbyXwg7y8xjM01MJkLXW6GXCf5kAqPRfdKRxescw1et(wOpwZIJiOolLicOfTO1]] )


end
