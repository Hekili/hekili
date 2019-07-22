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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
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

        potion = "potion_of_unbridled_fury",

        package = "Fire",
    } )


    spec:RegisterPack( "Fire", 20190722, [[duepncqiufpcvPYMayuQuDkazvkej9kfsZsbCluLQSlq)si1WasogqSmvk8mfctdvj6AOkPTHQu6BOkbJdvPOZPqeRtHi18uP09qvTpavhevPQOfQq1drvc5IOkvL2iQsHojQsvLvkeDtfIe7uHYqrvc1srvk4PezQkqxfvPQQ9k4VegmvomLflQhdzYOYLr2SiFwLmAI60sTAfI61akZMQUTk2Ts)wYWfQJJQuvy5Q65qnDsxxrBxi57kOXdK68cH1RsrZhO2pkhajmyqIZukm2nafiJeqXlCJBabfO4vE7i4fcsAeXuqk2qaZUOG0AhkiXBSFkifBr4lJlmyqcxZhrbjzvJXJ0rh9vRYZmevNOX9z6nTRf9wsJg3hu0bP8S9kVFBihK4mLcJDdqbYibu8c34gqqbkEL3ocEzqYMQC9bjP(m9M21Yl6TKgKKBooAd5GehHrbjEhZXBSFI5gPyxelsEhZjRAmEKo6OVAvEMHO6enUptVPDTO3sA04(GIo7RC05KX7XrrfD8xP2t4O5f)eVbR5WrZlM3GyKIDrcEJ9tqCFqSi5DmxKtFem3nazaM7gGcKrcZX7XC3auJ086iHfjlsEhZXls22lcpsZIK3XC8EmhV)yI50(qcTeCnXCVPY0ZCQSTmNA)fPqTpKqlbxtmxQEMZByL3dtOA5yol3(wJG5My7IWWGKVXkomyq6RyrSSHPWGHXajmyqYqAxBq6NljQKiUgsFqIwl7jUW4bnm2ncdgKO1YEIlmEqc9TsFBbP7m3DMtnpTkm5TdjInfjdP1YEIJ5aWCgs7OibT0PjmZbCMdeMdiMdmyMZqAhfjOLonHzoGZC8sMdiMdaZLNPeuUubwFYag8jdPbjdPDTbPK3oew)gyuqdJnIWGbjATSN4cJhKqFR03wqkptjOCPcS(Kbm4tgsdsgs7AdsXr8v2BynOHX4LHbds0AzpXfgpinXKyOC7jbYWAVxbjqcsOVv6BliDN5qv55QHlevN8eRDTWNowVyMd4mhOyoWGzUu)ewTxPhAiTJIyoamxEMsWFUKOsI4Ai9WzmZbeZbG5UZC8WC5zkbLjt79smJHpziL5aWC8WC5zkbLlvG1NmGbFYqkZbG54H5IFkkrLsIlehm1pjYEdRmhaM7oZziTRfM6NezVHvis2(lcZCaNpZDdMdmyM7oZziTRfglx02GwK82HWqKS9xeM5aoFMdeMdaZPMNwfglx02GwK82HWqATSN4yoGyoWGzU7mNAEAvO5jqJ13W30WI08JasRL9ehZbG5qv55QHlK7TRAXI8tMkdFY4IG5aI5adM5UZCQ5PvHyY(EVeAnrYqATSN4yoamNA)fPqzY8QmmgPm3T8zUrakMdiMdmyM7oZPMNwfM6NWQ9k9qATSN4yoamxQFcR2R0dnK2rrmhqmhqmhqbPjMevkjUqCbjqcsgs7AdsP(jr2BynOHX41WGbjATSN4cJhKmK21gKqM3lmK21k8nwds(gRI1ouqYqAhfjuZtRIdAymEByWGeTw2tCHXdsOVv6BliLNPemoIVqEdFGpziL5aWCidRcTpeZDlZLNPemoIVqEdFGpDSEXmhaMlptj4pxsujrCnKE4thRxmZbCMdzyvO9Hcsgs7AdsXr8v2BynOHX4fcdgKO1YEIlmEqAIjXq52tcKH1EVcsGeKqFR03wq6oZHQYZvdxiQo5jw7AHpDSEXmhWzoqXCGbZCP(jSAVsp0qAhfXCayU8mLG)CjrLeX1q6HZyMdiMdaZDN5YZucktM27LygdFYqkZbG5UZCQ9xKcLjZRYWyKYCaNpZncqXCGbZC8WCQ5PvHyY(EVeAnrYqATSN4yoGyoGcstmjQusCH4csGeKmK21gKs9tIS3WAqdJXBggmirRL9exy8G0etIHYTNeidR9EfKajiH(wPVTG0DMdvLNRgUquDYtS21cF6y9IzoGZCGI5adM5s9ty1ELEOH0okI5aWC5zkb)5sIkjIRH0dNXmhqmhaMtnpTket237LqRjsgsRL9ehZbG5u7VifktMxLHXiL5ULpZncqXCayU7mxEMsqzY0EVeZy4tgszoamhpmNH0UwigvpsgsGMqtT3lMdmyMJhMlptjOmzAVxIzm8jdPmhaMJhMlptjOCPcS(Kbm4tgszoGcstmjQusCH4csGeKmK21gKs9tIS3WAqdJnscdgKO1YEIlmEqc9TsFBbP4NIsCH4GGaXO6rYmhaMlptjOmzAVxIzmCgZCayo180QqmzFVxcTMiziTw2tCmhaMtT)IuOmzEvggJuM7w(m3iafZbG5UZC8WCQ5PvHjVDirSPiziTw2tCmhyWmNH0oksqlDAcZC8zoqyoGcsgs7AdsXr8v2BynOHXabuHbds0AzpXfgpiH(wPVTGepmx8trjUqCqqGXYfTnOfjVDimZbG5YZucktM27LygdFYqAqYqAxBqkwUOTbTi5TdHdAymqajmyqIwl7jUW4bj03k9TfKu7VifktMxLHXiL5ULpZncqXCayo180QqmzFVxcTMiziTw2tCbjdPDTbjmQEKCqdJbYncdgKO1YEIlmEqc9TsFBbjdPDuKGw60eM5aoZDJGKH0U2Ge3Bx1If5NmvoOHXazeHbds0AzpXfgpiH(wPVTG0DMtnpTkm5TdjInfjdP1YEIJ5aWCgs7OibT0PjmZbCM7gmhqmhyWmNH0oksqlDAcZCaN541GKH0U2GuYBhcRFdmkOHXaHxggmiziTRniL6NYM3hKO1YEIlmEqdAqkFeO6KNyTRvelBykmyymqcdgKO1YEIlmEqc9TsFBbP8mLGO6KNyTRfYvd3GKH0U2GKVVKvSyKNCxhA1Ggg7gHbdsgs7AdsXL21gKO1YEIlmEqdJnIWGbjdPDTbPSVkorA(reKO1YEIlmEqdJXlddgKmK21gKY0JPhy9EfKO1YEIlmEqdJXRHbdsgs7AdsP(PSVkUGeTw2tCHXdAymEByWGKH0U2GKTicRV5fiZ7ds0AzpXfgpOHX4fcdgKO1YEIlmEqYqAxBqczEVWqAxRW3yni5BSkw7qbj97fyKIdAymEZWGbjATSN4cJhKqFR03wqk(POexioiiqmQEKmZbG5YZucktM27LygdNXbjdPDTbP4i(k7nSg0WyJKWGbjATSN4cJhKqFR03wqkptjOCPcS(Kbm4moiziTRnifhXxzVH1GggdeqfgmirRL9exy8Ge6BL(2cs5zkbJJ4lK3Wh4tgszoamhYWQq7dXC3YC5zkbr1jpXAxl8PJ1loiziTRnifhXxzVH1GggdeqcdgKmK21gKILlABqlsE7q4GeTw2tCHXdAymqUryWGeTw2tCHXdsOVv6BliLNPem7nSsV4yyLEiwneWyo(mhimhaMlptjOCPcS(KbmixnCzoamhpmxEMsW4i(c5n8b(KHuMdaZf)uuIleheeyCeFL9gwzoam3DMlptjy2ByLEXXWk9WNowVyM7wMduqq4vMdmyM7cXbF6y9IzUBzoqbbHxzoGcsgs7AdsP(jr2ByninXKOsjXfIlibsqdJbYicdgKO1YEIlmEqAIjXq52tcKH1EVcsGeKmK21gKs9tIS3WAqc9TsFBbP8mLGzVHv6fhdR0dXQHagZXN5aH5aWC3zodPDTqmQEKmKanHMAVxmhaMZqAxleJQhjdjqtOPsINowVyM7wMduqq4vMdmyMlptjy2ByLEXXWk9WNowVyM7wMduqq4vMdOGggdeEzyWGeTw2tCHXdsOVv6BliLNPeuUubwFYagKRgUmhaM7oZHQYZvdxyQFsK9gwHpDSEXm3TmhYWQq7dXCGbZCgs7AHP(jr2ByfIKT)IWmhWzoqXCafKmK21gKWO6rYbnmgi8AyWGeTw2tCHXdstmjgk3EsGmS27vqcKGe6BL(2cs5zkbZEdR0logwPhIvdbmMd4mhimhaM7oZf)uuIleheeigvpsM5aWC8WC5zkbLlvG1NmGbNXmhaMJhMZqAxleJQhjdjqtOP27fZbgmZLNPem7nSsV4yyLE4thRxmZDlZbkii8kZbuqAIjrLsIlexqcKGKH0U2GuQFsK9gwdAymq4THbds0AzpXfgpiH(wPVTGuEMsquDYtS21cF6y9IzUBzUleh8yGM5aWCgs7OibT0PjmZbCMdKGKH0U2GKVJQ3lrUo5GggdeEHWGbjATSN4cJhKqFR03wqkptjiQo5jw7AHpDSEXm3Tm3fIdEmqhKmK21gK4E7QwSi)KPYbnmgi8MHbdsgs7Adsyu9i5GeTw2tCHXdAqdsCuYMEnmyymqcdgKmK21gKq1Cv6XXK3hKO1YEIlmEqdJDJWGbjATSN4cJhKqFR03wqkptjiQo5jw7AHC1WniziTRniD6)Rx0h7IcAySregmiziTRniHQfrR(MsCIK3ouqIwl7jUW4bnmgVmmyqYqAxBqkvOjM4e2nPVvsKj7eKO1YEIlmEqdJXRHbdsgs7AdsXZVtr07Li7nSgKO1YEIlmEqdJXBddgKmK21gK(oo2tIEf4ydrbjATSN4cJh0Wy8cHbdsgs7AdsQmjMBUMlNivpIcs0AzpXfgpOHX4nddgKmK21gKgwVNlkQxXt4ATfrbjATSN4cJh0WyJKWGbjATSN4cJhKqFR03wqsnpTkm1pHv7v6H0AzpXXCayUu)ewTxPh(0X6fZCaN5stVx8es2(lsO9HyoWGzouvEUA4cr1jpXAxl8PJ1lM5aoZfL9TL9eevN8eRDTIVIfOPwPeZbG5YZucIQtEI1UwixnCzoWGzoTpKqlbxtm3TmhQkpxnCHO6KNyTRf(0X6fZCayU8mLGO6KNyTRfYvd3GKH0U2G0pxsujrCnK(GggdeqfgmirRL9exy8GKH0U2G0X8P6peNqMEZZHfE6A4BX4Ge6BL(2csOQ8C1WfIQtEI1Uw4thRxmZbCMJx51G0AhkiDmFQ(dXjKP38CyHNUg(wmoOHXabKWGbjATSN4cJhKqFR03wq6oZPMNwf(ZLevsexdPhsRL9ehZbG5qv55QHlevN8eRDTWNowVyM7w(mNH0Uw4pxsujrCnKEiYWQq7dXCGbZCOQ8C1WfIQtEI1Uw4tgxemhqmhaMJhMl1pHv7v6Hgs7OiMdmyMlptjiQo5jw7AHZ4GKH0U2GeY8EHH0UwHVXAqY3yvS2HcsO6KNyTRvelBykOHXa5gHbds0AzpXfgpinXKyOC7jbYWAVxbjqcsOVv6BliDN5imMwebp0P(ievs4NOMtW9KDWWJnY1ZCGbZCegtlIGh6uFeIkj8tuZj4EYoy4P36zoamNDt6BLGzVHv6fhdR0dP1YEIJ5aI5aWCiz7VimZXN5ogOfiz7VimZbG54H5YZuckxQaRpzad(KHuMdaZXdZDN5YZucktM27LygdFYqkZbG5UZC5zkbr1jpXAxlCgZCayU7mNH0UwyQFkBEpSxrY3xYkZbgmZziTRfghXxzVHvyVIKVVKvMdmyMZqAxleJQhjdjqtOP27fZbeZbgmZP2FrkuMmVkdJrkZDlFMBeGI5aWCgs7AHyu9izibAcn1EVyoGyoGyoamhpm3DMJhMlptjOmzAVxIzm8jdPmhaMJhMlptjOCPcS(Kbm4tgszoamxEMsquDYtS21c5QHlZbG5UZCgs7AHP(PS59WEfjFFjRmhyWmNH0UwyCeFL9gwH9ks((swzoGyoGcstmjQusCH4csGeKmK21gKs9tIS3WAqdJbYicdgKO1YEIlmEqAIjXq52tcKH1EVcsGeKqFR03wq6oZrymTicEOt9riQKWprnNG7j7GHhBKRN5adM5imMwebp0P(ievs4NOMtW9KDWWtV1ZCayo7M03kbZEdR0logwPhsRL9ehZbeZbG5qY2FryMJpZDmqlqY2FryMdaZXdZLNPeuUubwFYag8jdPmhaMJhM7oZLNPeuMmT3lXmg(KHuMdaZDN5YZucIQtEI1Uw4mM5aWC3zodPDTWu)u28EyVIKVVKvMdmyMZqAxlmoIVYEdRWEfjFFjRmhyWmNH0UwigvpsgsGMqtT3lMdiMdmyMtT)IuOmzEvggJuM7w(m3iafZbG5mK21cXO6rYqc0eAQ9EXCaXCaXCayoEyU7mhpmxEMsqzY0EVeZy4tgszoamhpmxEMsq5sfy9jdyWNmKYCayU8mLGO6KNyTRfYvdxMdaZDN5mK21ct9tzZ7H9ks((swzoWGzodPDTW4i(k7nSc7vK89LSYCaXCafKMysuPK4cXfKajiziTRniL6NezVH1GggdeEzyWGeTw2tCHXdsOVv6BliLNPe8NljQKiUgspCgZCayU8mLGO6KNyTRfYvd3GKH0U2GeY8EHH0UwHVXAqY3yvS2HcsFflILnmf0WyGWRHbds0AzpXfgpivXbjmPbjdPDTbPOSVTSNcsrz(jfKuZtRc)5sIkjIRH0dP1YEIJ5aWCOQ8C1Wf(ZLevsexdPh(0X6fZC3YCOQ8C1WfM6NezVHvyA69INqY2FrcTpeZbG5UZCOQ8C1WfIQtEI1Uw4thRxmZbCMlk7Bl7jiQo5jw7AfFflqtTsjMdmyMl1pHv7v6Hgs7OiMdiMdaZDN5qv55QHl8NljQKiUgsp8PJ1lM5UL50(qcTeCnXCGbZCgs7AH)CjrLeX1q6Hiz7VimZbCMdumhqmhyWmhQkpxnCHO6KNyTRf(0X6fZC3YCgs7AHP(jr2ByfMMEV4jKS9xKq7dXCJYCOQ8C1WfM6NezVHvi38nTRL5gPYC2nPVvcM9gwPxCmSspKwl7joMdaZXdZL6NWQ9k9qdPDueZbG5qv55QHlevN8eRDTWNowVyM7wMt7dj0sW1eZbgmZPMNwfM6NWQ9k9qATSN4yoamxQFcR2R0dnK2rrmhaMl1pHv7v6HpDSEXm3TmhQkpxnCHP(jr2ByfMMEV4jKS9xKq7dXCJYCOQ8C1WfM6NezVHvi38nTRL5gPYC2nPVvcM9gwPxCmSspKwl7jUGuu2lw7qbPu)Ki7nSkIRY37vqdJbcVnmyqIwl7jUW4bPkoiHjniziTRnifL9TL9uqkkZpPGKAEAv4pxsujrCnKEiTw2tCmhaMdvLNRgUWFUKOsI4Ai9WNowVyM7wMdvLNRgUWy5I2g0IK3oegMMEV4jKS9xKq7dXCayouvEUA4cr1jpXAxl8PJ1lM5aoZfL9TL9eevN8eRDTIVIfOPwPeZbG5UZCOQ8C1Wf(ZLevsexdPh(0X6fZC3YCAFiHwcUMyoWGzodPDTWFUKOsI4Ai9qKS9xeM5aoZbkMdiMdmyMdvLNRgUquDYtS21cF6y9IzUBzodPDTWy5I2g0IK3oegMMEV4jKS9xKq7dXCayouvEUA4cr1jpXAxl8PJ1lM5UL50(qcTeCnfKIYEXAhkiflx02GwexLV3RGggdeEHWGbjATSN4cJhKmK21gKqM3lmK21k8nwds(gRI1ouqcR2YzpN4l10U2Gg0Gu8tO6KnnmyymqcdgKmK21gKShzlj6vjVNqAqIwl7jUW4bnm2ncdgKO1YEIlmEqQIdsysdsgs7AdsrzFBzpfKIY8tkiXBbvqkk7fRDOGeQo5jw7AfFflqtTsPGggBeHbdsgs7AdsN()6f9XUOGeTw2tCHXdAymEzyWGKH0U2GuCPDTbjATSN4cJh0Wy8AyWGKH0U2GuCeFL9gwds0AzpXfgpObniHQtEI1UwrSSHPWGHXajmyqIwl7jUW4bP1ouqYUjw2Edls1QIkjIRH0hKmK21gKSBILT3WIuTQOsI4Ai9bnm2ncdgKO1YEIlmEqYqAxBqAIjrR0jiH(wPVTGuEMsquDYtS21cNXmhaMZqAxlm1pjYEdRqKS9xewKEdPDTMN5UL5abEJG0Ahkijhrm9Q8tgNy43yD4BX4GggBeHbdsgs7AdszFvCIkjuzsqlDIiirRL9exy8GggJxggmiziTRniDnTNRTvujHDt6lvoirRL9exy8GggJxddgKO1YEIlmEqc9TsFBbj7M03kbZEdR0logwPhsRL9ehZbG5uZtRctE7qIAH0AzpXXCayoEyocJPfrWdDQpcrLe(jQ5eCpzhm8yJC9bjdPDTbjK59cdPDTcFJ1GKVXQyTdfKYhbQo5jw7AfXYgMcAymEByWGKH0U2G0Ho1hHOsc)e1CcUNSdoirRL9exy8GggJximyqYqAxBq6AApxBROsc7M0xQCqIwl7jUW4bnmgVzyWGeTw2tCHXdstmjgk3EsGmS27vqcKGe6BL(2csegtlIGh6uFeIkj8tuZj4EYoy4Xg56zoamhs2(lcZC8zUJbAbs2(lcZCayoEyU8mLGYLkW6tgWGpziL5aWC8WC3zU8mLGYKP9EjMXWNmKYCayU7mxEMsquDYtS21cNXmhaM7oZziTRfM6NYM3d7vK89LSYCGbZCgs7AHXr8v2Byf2Ri57lzL5adM5mK21cXO6rYqc0eAQ9EXCaXCGbZCQ9xKcLjZRYWyKYC3YN5gbOyoamNH0UwigvpsgsGMqtT3lMdiMdiMdaZXdZDN54H5YZucktM27LygdFYqkZbG54H5YZuckxQaRpzad(KHuMdaZLNPeevN8eRDTqUA4YCayU7mNH0UwyQFkBEpSxrY3xYkZbgmZziTRfghXxzVHvyVIKVVKvMdiMdOG0etIkLexiUGeibjdPDTbPu)Ki7nSg0WyJKWGbjATSN4cJhKqFR03wqkptjiQo5jw7AHC1WniziTRni9ZLevsexdPpOHXabuHbds0AzpXfgpiH(wPVTG0DMZUj9TsWS3Wk9IJHv6H0AzpXXCayU8mLGzVHv6fhdR0dXQHagZbC(m3iyoGyoWGzoEyo7M03kbZEdR0logwPhsRL9exqYqAxBqczEVWqAxRW3yni5BSkw7qbjdPDuKqnpTkoOHXabKWGbjATSN4cJhKMysmuU9KazyT3RGeibj03k9TfK4H5imMwebp0P(ievs4NOMtW9KDWWJnY1ZCayU7mhpmNDt6BLGzVHv6fhdR0dP1YEIJ5adM54H5uZtRctE7qIAH0AzpXXCaXCayU7m3DMZqAxl8qkvpSxrY3xYkZbG5mK21cpKs1d7vK89LSkE6y9IzUB5ZCGcYRmhqmhyWmhpmNAEAv4HuQEiTw2tCmhqmhaM7oZLNPe8NljQKiUgspCgZCGbZC8WCQ5PvH)CjrLeX1q6H0AzpXXCafKMysuPK4cXfKajiziTRniHQtEI1U2GggdKBegmirRL9exy8G0etIHYTNeidR9EfKajiH(wPVTGeHX0Ii4Ho1hHOsc)e1CcUNSdgESrUEMdaZDN5YZuc(ZLevsexdPhoJzoWGzoEyo180QWFUKOsI4Ai9qATSN4yoGcstmjQusCH4csGeKmK21gKq1jpXAxBqdJbYicdgKO1YEIlmEqAIjXq52tcKH1EVcsGeKqFR03wqIWyAre8qN6JqujHFIAob3t2bdp2ixpZbG5UZCiz7ViSi9gs7AnpZbCMde4iyoWGzU8mLGzVHv6fhdR0dF6y9IzUBzoqb5vMdmyMlptjiQo5jw7AHpDSEXm3TmxEMsWS3Wk9IJHv6HCZ30UwMdmyMJhMZUj9TsWS3Wk9IJHv6H0AzpXXCaXCayU7m3DMlptjiQo5jw7AHZyMdaZDN5YZucktM27LygdFYqkZbG54H5mK21cJJ4RS3WkSxrY3xYkZbG54H5mK21cXO6rYqc0eAQ9EXCaXCGbZC3zodPDTqmQEKmKanHMkjE6y9IzoamxEMsqzY0EVeZyixnCzoamxEMsq5sfy9jdyqUA4YCayoEyodPDTW4i(k7nSc7vK89LSYCaXCaXCafKMysuPK4cXfKajiziTRniL6NezVH1GggdeEzyWGeTw2tCHXdstmjgk3EsGmS27vqcKGe6BL(2cs8WCegtlIGh6uFeIkj8tuZj4EYoy4Xg56zoam3DMJhMZUj9TsWS3Wk9IJHv6H0AzpXXCGbZC8WCQ5PvHjVDirTqATSN4yoGyoam3DM7oZLNPeevN8eRDTWzmZbG5UZC5zkbLjt79smJHpziL5aWC8WCgs7AHXr8v2Byf2Ri57lzL5aWC8WCgs7AHyu9izibAcn1EVyoGyoWGzU7mNH0UwigvpsgsGMqtLepDSEXmhaMlptjOmzAVxIzmKRgUmhaMlptjOCPcS(KbmixnCzoamhpmNH0UwyCeFL9gwH9ks((swzoGyoGyoGcstmjQusCH4csGeKmK21gKs9tIS3WAqdJbcVggmirRL9exy8Ge6BL(2cs5zkbr1jpXAxlKRgUbjdPDTbjFFjRyXip5Uo0Qbnmgi82WGbjATSN4cJhKqFR03wqYUj9TsWS3Wk9IJHv6H0AzpXXCayo180QWK3oKOwiTw2tCmhaMJhMJWyAre8qN6JqujHFIAob3t2bdp2ixFqYqAxBqczEVWqAxRW3yni5BSkw7qbP8rGQtEI1UwrSSHPGggdeEHWGbjdPDTbPSVkorLeQmjOLoreKO1YEIlmEqdJbcVzyWGKH0U2G0Ho1hHOsc)e1CcUNSdoirRL9exy8GggdKrsyWGKH0U2G010EU2wrLe2nPVu5GeTw2tCHXdAySBaQWGbjATSN4cJhKqFR03wqkptjiQo5jw7AHC1WniziTRni9ZLevsexdPpOHXUbiHbds0AzpXfgpiH(wPVTG0DMZUj9TsWS3Wk9IJHv6H0AzpXXCayU8mLGzVHv6fhdR0dXQHagZbC(m3iyoGyoWGzoEyo7M03kbZEdR0logwPhsRL9exqYqAxBqczEVWqAxRW3yni5BSkw7qbjdPDuKqnpTkoOHXUXncdgKO1YEIlmEqAIjXq52tcKH1EVcsGeKqFR03wqIhMJWyAre8qN6JqujHFIAob3t2bdp2ixpZbG5UZC8WC2nPVvcM9gwPxCmSspKwl7joMdmyMJhMtnpTkm5TdjQfsRL9ehZbeZbG5UZC3zodPDTWdPu9WEfjFFjRmhaMZqAxl8qkvpSxrY3xYQ4PJ1lM5ULpZbkiVYCaXCGbZC8WCQ5PvHhsP6H0AzpXXCaXCayU7mxEMsWFUKOsI4Ai9WzmZbgmZXdZPMNwf(ZLevsexdPhsRL9ehZbuqAIjrLsIlexqcKGKH0U2GeQo5jw7AdAySBmIWGbjATSN4cJhKMysmuU9KazyT3RGeibj03k9TfKimMwebp0P(ievs4NOMtW9KDWWJnY1ZCayU7mxEMsWFUKOsI4Ai9WzmZbgmZXdZPMNwf(ZLevsexdPhsRL9ehZbuqAIjrLsIlexqcKGKH0U2GeQo5jw7AdAySBWlddgKmK21gKIlTRnirRL9exy8Ggg7g8AyWGKH0U2Gu2xfNin)ics0AzpXfgpOHXUbVnmyqYqAxBqktpMEG17vqIwl7jUW4bnm2n4fcdgKmK21gKs9tzFvCbjATSN4cJh0Wy3G3mmyqYqAxBqYweH138cK59bjATSN4cJh0Wy3yKegmirRL9exy8GKH0U2GeY8EHH0UwHVXAqY3yvS2Hcs63lWifh0WyJauHbds0AzpXfgpiH(wPVTG0DM7oZPMNwfM82HeXMIKH0AzpXXCayodPDuKGw60eM5aoZDdMdiMdmyMZqAhfjOLonHzoGZC8wMdiMdaZLNPeuUubwFYag8jdPmhaMJhMZUj9TsWS3Wk9IJHv6H0AzpXfKmK21gKsE7qy9BGrbnm2iajmyqIwl7jUW4bj03k9TfKYZucghXxiVHpWNmKYCayU8mLGO6KNyTRf(0X6fZCaN5qgwfAFOGKH0U2GuCeFL9gwdAySrCJWGbjATSN4cJhKqFR03wqkptjOCPcS(Kbm4tgsdsgs7AdsXr8v2BynOHXgXicdgKO1YEIlmEqAIjXq52tcKH1EVcsGeKqFR03wqIWyAre8qN6JqujHFIAob3t2bdp2ixpZbG5UZCiz7ViSi9gs7AnpZbCMde4iyoWGzU8mLGzVHv6fhdR0dF6y9IzUBzoqb5vMdmyMlptjiQo5jw7AHpDSEXm3TmxEMsWS3Wk9IJHv6HCZ30UwMdmyMJhMZUj9TsWS3Wk9IJHv6H0AzpXXCaXCayU7m3DMlptjiQo5jw7AHZyMdaZDN5YZucktM27LygdFYqkZbG54H5mK21cJJ4RS3WkSxrY3xYkZbG54H5mK21cXO6rYqc0eAQ9EXCaXCGbZC3zodPDTqmQEKmKanHMkjE6y9IzoamxEMsqzY0EVeZyixnCzoamxEMsq5sfy9jdyqUA4YCayoEyodPDTW4i(k7nSc7vK89LSYCaXCaXCafKMysuPK4cXfKajiziTRniL6NezVH1GggBe8YWGbjATSN4cJhKMysmuU9KazyT3RGeibj03k9TfK4H5imMwebp0P(ievs4NOMtW9KDWWJnY1ZCayU7mhpmNDt6BLGzVHv6fhdR0dP1YEIJ5adM54H5uZtRctE7qIAH0AzpXXCaXCayU7m3DMlptjiQo5jw7AHZyMdaZDN5YZucktM27LygdFYqkZbG54H5mK21cJJ4RS3WkSxrY3xYkZbG54H5mK21cXO6rYqc0eAQ9EXCaXCGbZC3zodPDTqmQEKmKanHMkjE6y9IzoamxEMsqzY0EVeZyixnCzoamxEMsq5sfy9jdyqUA4YCayoEyodPDTW4i(k7nSc7vK89LSYCaXCaXCafKMysuPK4cXfKajiziTRniL6NezVH1GggBe8AyWGeTw2tCHXdsOVv6Blif)uuIleheeigvpsM5aWC5zkbLjt79smJHZ4GKH0U2GuCeFL9gwdAySrWBddgKmK21gKILlABqlsE7q4GeTw2tCHXdAySrWlegmirRL9exy8Ge6BL(2cs5zkbr1jpXAxl8PJ1lM5aoZHmSk0(qmhaMlptjiQo5jw7AHZyMdmyMlptjiQo5jw7AHC1WniziTRniHr1JKdAySrWBggmirRL9exy8Ge6BL(2cs5zkbr1jpXAxl8PJ1lM5UL5UqCWJbAMdaZziTJIe0sNMWmhWzoqcsgs7Ads(oQEVe56KdAySrmscdgKO1YEIlmEqc9TsFBbP8mLGO6KNyTRf(0X6fZC3YCxio4XanZbG5YZucIQtEI1Uw4moiziTRniX92vTyr(jtLdAymEjOcdgKO1YEIlmEqc9TsFBbj1(lsHYK5vzymszUB5ZCJaumhaMtnpTket237LqRjsgsRL9exqYqAxBqcJQhjh0GgK0VxGrkomyymqcdgKmK21gKMys0kDWbjATSN4cJh0Wy3imyqIwl7jUW4bjdPDTbP4cbmsX9njobQoXt10UwbhfvJOGe6BL(2cs8WCOQ8C1WfIIa5l9RTrIS3WkKB(M21gKw7qbP4cbmsX9njobQoXt10UwbhfvJOGg0GewTLZEoXxQPDTHbdJbsyWGeTw2tCHXdsOVv6BliDN5UZCQ5PvHjVDirSPiziTw2tCmhaMZqAhfjOLonHzoGZCGWCayoEyUu)ewTxPhAiTJIyoGyoWGzodPDuKGw60eM5aoZXlzoGyoamxEMsq5sfy9jdyWNmKgKmK21gKsE7qy9BGrbnm2ncdgKO1YEIlmEqc9TsFBbP8mLGYLkW6tgWGpziL5aWC5zkbLlvG1NmGbF6y9IzUBzodPDTWu)u28EibAcnvsO9Hcsgs7AdsXr8v2BynOHXgryWGeTw2tCHXdsOVv6BliLNPeuUubwFYag8jdPmhaM7oZf)uuIleheeyQFkBEpZbgmZL6NWQ9k9qdPDueZbgmZziTRfghXxzVHvyVIKVVKvMdOGKH0U2GuCeFL9gwdAymEzyWGeTw2tCHXdsOVv6BliLNPeuUubwFYag8jdPmhaMtT)IuOmzEvggJuM7w(m3iafZbG5uZtRcXK99Ej0AIKH0AzpXfKmK21gKIJ4RS3WAqdJXRHbds0AzpXfgpiH(wPVTGuEMsW4i(c5n8b(KHuMdaZHmSk0(qm3TmxEMsW4i(c5n8b(0X6fhKmK21gKIJ4RS3WAqdJXBddgKO1YEIlmEqAIjXq52tcKH1EVcsGeKqFR03wq6oZHQYZvdxiQo5jw7AHpDSEXmhWzoqXCayU8mLG)CjrLeX1q6HC1WL5adM5s9ty1ELEOH0okI5aI5aWC8WCQ5PvHaRxoFVxqATSN4yoamhpmxu23w2tWu)Ki7nSkIRY37fZbG5UZC3zU7mNH0UwyQFkBEpKanHMAVxmhyWmNH0UwyCeFL9gwHeOj0u79I5aI5aWC3zU8mLGYKP9EjMXWNmKYCGbZCP(jSAVsp0qAhfXCayoEyU8mLGYLkW6tgWGpziL5aWC8WC5zkbLjt79smJHpziL5aI5aI5adM5UZCQ5PvHyY(EVeAnrYqATSN4yoamNA)fPqzY8QmmgPm3T8zUrakMdaZDN5YZucktM27LygdFYqkZbG54H5mK21cXO6rYqc0eAQ9EXCGbZC8WC5zkbLlvG1NmGbFYqkZbG54H5YZucktM27LygdFYqkZbG5mK21cXO6rYqc0eAQ9EXCayoEyodPDTW4i(k7nSc7vK89LSYCayoEyodPDTWu)u28EyVIKVVKvMdiMdiMdmyM7oZL6NWQ9k9qdPDueZbG5UZCgs7AHXr8v2Byf2Ri57lzL5adM5mK21ct9tzZ7H9ks((swzoGyoamhpmxEMsqzY0EVeZy4tgszoamhpmxEMsq5sfy9jdyWNmKYCaXCafKMysuPK4cXfKajiziTRniL6NezVH1GggJximyqIwl7jUW4bj03k9TfKuZtRcbwVC(EVG0AzpXXCayU8mLGYKP9EjMXWNmKYCayU7mhQkpxnCHO6KNyTRf(0X6fZCaN5stVx8es2(lsO9HyUrzUBWCJYCQ5PvHaRxoFVxqATSN4yoWGzUu)ewTxPh(0X6fZCaN5stVx8es2(lsO9HyoWGzU7mhpmNAEAv4pxsujrCnKEiTw2tCmhyWmhQkpxnCH)CjrLeX1q6HpDSEXmhWzoTpKqlbxtmhaMZqAxl8NljQKiUgspejB)fHzUBzoqyoGyoamhQkpxnCHO6KNyTRf(0X6fZCaN50(qcTeCnXCafKmK21gKs9tIS3WAqdJXBggmirRL9exy8Ge6BL(2csXpfL4cXbbbIr1JKzoamxEMsqzY0EVeZy4mM5aWCQ5PvHyY(EVeAnrYqATSN4yoamNA)fPqzY8QmmgPm3T8zUrakMdaZDN5UZCQ5PvHjVDirSPiziTw2tCmhaMZqAhfjOLonHzo(mhimhaMJhMl1pHv7v6Hgs7OiMdiMdmyM7oZziTJIe0sNMWm3TmhVK5aWC8WCQ5PvHjVDirSPiziTw2tCmhqmhqbjdPDTbP4i(k7nSg0WyJKWGbjATSN4cJhKqFR03wq6oZLNPeuMmT3lXmg(KHuMdmyM7oZXdZLNPeuUubwFYag8jdPmhaM7oZziTRfM6NezVHvis2(lcZCaN5afZbgmZPMNwfIj779sO1ejdP1YEIJ5aWCQ9xKcLjZRYWyKYC3YN5gbOyoGyoGyoGyoamhpmxu23w2tWy5I2g0I4Q89EfKmK21gKILlABqlsE7q4GggdeqfgmirRL9exy8GKH0U2GeY8EHH0UwHVXAqY3yvS2Hcsgs7OiHAEAvCqdJbciHbds0AzpXfgpiH(wPVTGKH0oksqlDAcZCaN5ajiziTRniX92vTyr(jtLdAymqUryWGeTw2tCHXdsgs7AdsAZryT(JavCeOdsOVv6BliHQYZvdxiQo5jw7AHpDSEXmhWzUBakMdmyMtnpTkm1pHv7v6H0AzpXXCayUu)ewTxPh(0X6fZCaN5UbOcsRDOGK2CewR)iqfhb6GggdKregmirRL9exy8GKH0U2GuCHagP4(MeNavN4PAAxRGJIQruqc9TsFBbjuvEUA4cr1jpXAxl8PJ1lM5aoZDdqXCGbZCQ5PvHP(jSAVspKwl7joMdaZL6NWQ9k9WNowVyMd4m3navqIsjcPI1ouqcfbYx6xBJezVH1GggdeEzyWGeTw2tCHXdsOVv6BliP2FrkuMmVkdJrkZDlFMBeGI5aWCQ5PvHyY(EVeAnrYqATSN4csgs7Adsyu9i5GggdeEnmyqYqAxBqk1pLnVpirRL9exy8GggdeEByWGKH0U2GegvpsoirRL9exy8Gg0GKH0oksOMNwfhgmmgiHbds0AzpXfgpiH(wPVTGKH0oksqlDAcZCaN5aH5aWC5zkbr1jpXAxlKRgUmhaM7oZHQYZvdxiQo5jw7AHpDSEXmhWzouvEUA4c9Du9EjY1jd5MVPDTmhyWmhQkpxnCHO6KNyTRf(KXfbZbuqYqAxBqY3r17LixNCqdJDJWGbjATSN4cJhKqFR03wqkptj4pxsujrCnKE4mM5aWC3zUu)ewTxPh(0X6fZCaN5qv55QHl8qkvpKB(M21YCGbZC8WCP(jSAVsp0qAhfXCaXCGbZCOQ8C1Wf(ZLevsexdPh(0X6fZCaN50(qcTeCnXCayodPDTWFUKOsI4Ai9qKS9xeM5UL5aH5adM5UZCOQ8C1WfEiLQhYnFt7AzUBzouvEUA4cr1jpXAxl8PJ1lM5adM5qv55QHlevN8eRDTWNmUiyoGyoamhpmNAEAv4pxsujrCnKEiTw2tCmhaM7oZHQYZvdx4HuQEi38nTRL5UL5s9ty1ELE4thRxmZbgmZXdZPMNwfM6NWQ9k9qATSN4yoWGzoEyUu)ewTxPhAiTJIyoGcsgs7AdshsP6dAqdAqkk6XDTHXUbOazKakEbqafeuJKG0q73EVWbjE)oX1RehZXBYCgs7AzoFJvmKfzqk(Ru7PGeVJ54n2pXCJuSlIfjVJ5KvngpshD0xTkpZquDIg3NP30Uw0BjnACFqrN9vo6CY494OOIo(Ru7jC08IFI3G1C4O5fZBqmsXUibVX(jiUpiwK8oMlYPpcM7gGmaZDdqbYiH549yUBaQrAEDKWIKfjVJ54fjB7fHhPzrY7yoEpMJ3FmXCAFiHwcUMyU3uz6zov2wMtT)IuO2hsOLGRjMlvpZ5nSY7HjuTCmNLBFRrWCtSDryilswK8oMJ3xqtOPsCmxMs1tmhQoztzUmD1lgYC8(eHOyfZCBT8EY2FstpZziTRfZC16JaYIK3XCgs7AXW4Nq1jBk)K3WaJfjVJ5mK21IHXpHQt20r5hDQkowK8oMZqAxlgg)eQozthLF0286qRAAxllsdPDTyy8tO6KnDu(rBpYws0RsEpHuwK8oMBq5gZCrzFBzpXCysXmNktmN2hI5mL5gk3izMJ3WCjMRsmhV4Ai9mhwUMEoMdR2RmxM69I5WwuehZLQN5uzI5wc0kZXlQo5jw7AzUyzdtSinK21IHXpHQt20r5hDu23w2tdS2H4JQtEI1UwXxXc0uRuAGkMpM0bIY8tIpVfuSi5DmNH0Uwmm(juDYMok)OXRfJLlvGvtXSinK21IHXpHQt20r5h9P)VErFSlIfPH0Uwmm(juDYMok)OJlTRLfPH0Uwmm(juDYMok)OJJ4RS3WklswK8oMJ3xqtOPsCmhff9rWCAFiMtLjMZqA9mxJzolkR9w2tqwKgs7AX8r1Cv6XXK3ZI0qAxlEu(rF6)Rx0h7IgOt8ZZucIQtEI1UwixnCzrAiTRfpk)Or1IOvFtjorYBhIfPH0Uw8O8JovOjM4e2nPVvsKj7WI0qAxlEu(rhp)ofrVxIS3WklsdPDT4r5h93XXEs0RahBiIfPH0Uw8O8JwLjXCZ1C5eP6relsdPDT4r5h9W69Crr9kEcxRTiIfPH0Uw8O8J(NljQKiUgs)aDIVAEAvyQFcR2R0dP1YEIdqQFcR2R0dF6y9IbEA69INqY2FrcTpeyWOQ8C1WfIQtEI1Uw4thRxmWJY(2YEcIQtEI1UwXxXc0uRucqEMsquDYtS21c5QHlyWAFiHwcUMUfvLNRgUquDYtS21cF6y9IbKNPeevN8eRDTqUA4YI0qAxlEu(rpXKOv6mWAhI)X8P6peNqMEZZHfE6A4BX4b6eFuvEUA4cr1jpXAxl8PJ1lg48kVYI0qAxlEu(rJmVxyiTRv4BSoWAhIpQo5jw7AfXYgMgOt8VRMNwf(ZLevsexdPhsRL9ehauvEUA4cr1jpXAxl8PJ1l(w(gs7AH)CjrLeX1q6HidRcTpeyWOQ8C1WfIQtEI1Uw4tgxeabGNu)ewTxPhAiTJIadoptjiQo5jw7AHZywKgs7AXJYp6u)Ki7nSoWetIHYTNeidR9EXhKbMysuPK4cXXhKb6e)7egtlIGh6uFeIkj8tuZj4EYoy4Xg56bdMWyAre8qN6JqujHFIAob3t2bdp9wpa7M03kbZEdR0logwPhsRL9ehqaqY2Fry(hd0cKS9xegap5zkbLlvG1NmGbFYqkaEUNNPeuMmT3lXmg(KHua3ZZucIQtEI1Uw4mgWDdPDTWu)u28EyVIKVVKvWGnK21cJJ4RS3WkSxrY3xYkyWgs7AHyu9izibAcn1EVacmy1(lsHYK5vzymsVL)iafadPDTqmQEKmKanHMAVxabeaEUZtEMsqzY0EVeZy4tgsbWtEMsq5sfy9jdyWNmKciptjiQo5jw7AHC1WfWDdPDTWu)u28EyVIKVVKvWGnK21cJJ4RS3WkSxrY3xYkqaXI0qAxlEu(rN6NezVH1bMysmuU9KazyT3l(GmWetIkLexio(GmqN4FNWyAre8qN6JqujHFIAob3t2bdp2ixpyWegtlIGh6uFeIkj8tuZj4EYoy4P36by3K(wjy2ByLEXXWk9qATSN4acas2(lcZ)yGwGKT)IWa4jptjOCPcS(Kbm4tgsbWZ98mLGYKP9EjMXWNmKc4EEMsquDYtS21cNXaUBiTRfM6NYM3d7vK89LScgSH0UwyCeFL9gwH9ks((swbd2qAxleJQhjdjqtOP27fqGbR2FrkuMmVkdJr6T8hbOayiTRfIr1JKHeOj0u79ciGaWZDEYZucktM27LygdFYqkaEYZuckxQaRpzad(KHua5zkbr1jpXAxlKRgUaUBiTRfM6NYM3d7vK89LScgSH0UwyCeFL9gwH9ks((swbciwKgs7AXJYpAK59cdPDTcFJ1bw7q8)kwelByAGoXpptj4pxsujrCnKE4mgqEMsquDYtS21c5QHllsdPDT4r5hDu23w2tdS2H4N6NezVHvrCv(EVgikZpj(Q5PvH)CjrLeX1q6H0AzpXbavLNRgUWFUKOsI4Ai9WNowV4Brv55QHlm1pjYEdRW007fpHKT)IeAFia3rv55QHlevN8eRDTWNowVyGhL9TL9eevN8eRDTIVIfOPwPeyWP(jSAVsp0qAhfbeG7OQ8C1Wf(ZLevsexdPh(0X6fFR2hsOLGRjWGnK21c)5sIkjIRH0drY2FryGdkGadgvLNRgUquDYtS21cF6y9IV1qAxlm1pjYEdRW007fpHKT)IeAFOrrv55QHlm1pjYEdRqU5BAx7iv7M03kbZEdR0logwPhsRL9ehaEs9ty1ELEOH0okcaQkpxnCHO6KNyTRf(0X6fFR2hsOLGRjWGvZtRct9ty1ELEiTw2tCas9ty1ELEOH0okcqQFcR2R0dF6y9IVfvLNRgUWu)Ki7nScttVx8es2(lsO9HgfvLNRgUWu)Ki7nSc5MVPDTJuTBsFRem7nSsV4yyLEiTw2tCSinK21IhLF0rzFBzpnWAhIFSCrBdArCv(EVgikZpj(Q5PvH)CjrLeX1q6H0AzpXbavLNRgUWFUKOsI4Ai9WNowV4Brv55QHlmwUOTbTi5TdHHPP3lEcjB)fj0(qaqv55QHlevN8eRDTWNowVyGhL9TL9eevN8eRDTIVIfOPwPeG7OQ8C1Wf(ZLevsexdPh(0X6fFR2hsOLGRjWGnK21c)5sIkjIRH0drY2FryGdkGadgvLNRgUquDYtS21cF6y9IV1qAxlmwUOTbTi5TdHHPP3lEcjB)fj0(qaqv55QHlevN8eRDTWNowV4B1(qcTeCnXI0qAxlEu(rJmVxyiTRv4BSoWAhIpwTLZEoXxQPDTSizrAiTRfdnK2rrc180Qy((oQEVe56KhOt8nK2rrcAPttyGdcG8mLGO6KNyTRfYvdxa3rv55QHlevN8eRDTWNowVyGJQYZvdxOVJQ3lrUozi38nTRfmyuvEUA4cr1jpXAxl8jJlcGyrAiTRfdnK2rrc180Q4r5h9HuQ(b6e)8mLG)CjrLeX1q6HZya3t9ty1ELE4thRxmWrv55QHl8qkvpKB(M21cgmpP(jSAVsp0qAhfbeyWOQ8C1Wf(ZLevsexdPh(0X6fdCTpKqlbxtamK21c)5sIkjIRH0drY2Fr4Bbbm47OQ8C1WfEiLQhYnFt7AVfvLNRgUquDYtS21cF6y9IbdgvLNRgUquDYtS21cFY4Iaia8OMNwf(ZLevsexdPhsRL9ehG7OQ8C1WfEiLQhYnFt7AVn1pHv7v6HpDSEXGbZJAEAvyQFcR2R0dP1YEIdmyEs9ty1ELEOH0okciwKSinK21IH5JavN8eRDTIyzdt899LSIfJ8K76qRoqN4NNPeevN8eRDTqUA4YI0qAxlgIQtEI1UwrSSHPr5h9etIwPZaRDi(2nXY2ByrQwvujrCnKEwKgs7AXquDYtS21kILnmnk)ONys0kDgyTdXxoIy6v5NmoXWVX6W3IXd0j(5zkbr1jpXAxlCgdWqAxlm1pjYEdRqKS9xewKEdPDTM)wqG3GfPH0UwmevN8eRDTIyzdtJYp6SVkorLeQmjOLorWI0qAxlgIQtEI1UwrSSHPr5h910EU2wrLe2nPVuzwKgs7AXquDYtS21kILnmnk)OrM3lmK21k8nwhyTdXpFeO6KNyTRvelByAGoX3Uj9TsWS3Wk9IJHv6H0AzpXbqnpTkm5TdjQfsRL9ehaEimMwebp0P(ievs4NOMtW9KDWWJnY1ZI0qAxlgIQtEI1UwrSSHPr5h9Ho1hHOsc)e1CcUNSdMfPH0UwmevN8eRDTIyzdtJYp6RP9CTTIkjSBsFPYSinK21IHO6KNyTRvelByAu(rN6NezVH1bMysmuU9KazyT3l(GmWetIkLexio(GmqN4tymTicEOt9riQKWprnNG7j7GHhBKRhas2(lcZ)yGwGKT)IWa4jptjOCPcS(Kbm4tgsbWZ98mLGYKP9EjMXWNmKc4EEMsquDYtS21cNXaUBiTRfM6NYM3d7vK89LScgSH0UwyCeFL9gwH9ks((swbd2qAxleJQhjdjqtOP27fqGbR2FrkuMmVkdJr6T8hbOayiTRfIr1JKHeOj0u79ciGaWZDEYZucktM27LygdFYqkaEYZuckxQaRpzad(KHua5zkbr1jpXAxlKRgUaUBiTRfM6NYM3d7vK89LScgSH0UwyCeFL9gwH9ks((swbciwKgs7AXquDYtS21kILnmnk)O)5sIkjIRH0pqN4NNPeevN8eRDTqUA4YI0qAxlgIQtEI1UwrSSHPr5hnY8EHH0UwHVX6aRDi(gs7OiHAEAv8aDI)D7M03kbZEdR0logwPhsRL9ehG8mLGzVHv6fhdR0dXQHagW5pcGadMh7M03kbZEdR0logwPhsRL9ehlsdPDTyiQo5jw7AfXYgMgLF0O6KNyTRDGjMevkjUqC8bzGjMedLBpjqgw79Ipid0j(8qymTicEOt9riQKWprnNG7j7GHhBKRhWDESBsFRem7nSsV4yyLEiTw2tCGbZJAEAvyYBhsulKwl7joGaC)UH0Uw4HuQEyVIKVVKvags7AHhsP6H9ks((swfpDSEX3YhuqEfiWG5rnpTk8qkvpKwl7joGaCpptj4pxsujrCnKE4mgmyEuZtRc)5sIkjIRH0dP1YEIdiwKgs7AXquDYtS21kILnmnk)Or1jpXAx7atmjQusCH44dYatmjgk3EsGmS27fFqgOt8jmMwebp0P(ievs4NOMtW9KDWWJnY1d4EEMsWFUKOsI4Ai9WzmyW8OMNwf(ZLevsexdPhsRL9ehqSinK21IH5JavN8eRDTIyzdtJYp64s7AzrAiTRfdZhbQo5jw7AfXYgMgLF0zFvCI08JGfPH0UwmmFeO6KNyTRvelByAu(rNPhtpW69IfPH0UwmmFeO6KNyTRvelByAu(rN6NY(Q4yrAiTRfdZhbQo5jw7AfXYgMgLF02IiS(MxGmVNfPH0UwmmFeO6KNyTRvelByAu(rJmVxyiTRv4BSoWAhIV(9cmsXSinK21IH5JavN8eRDTIyzdtJYp64i(k7nSoqN4h)uuIleheeigvpsgqEMsqzY0EVeZy4mMfPH0UwmmFeO6KNyTRvelByAu(rhhXxzVH1b6e)8mLGYLkW6tgWGZywKgs7AXquDYtS21kILnmnk)Ot9tIS3W6atmjQusCH44dYatmjgk3EsGmS27fFqgOt8jmMwebp0P(ievs4NOMtW9KDWWJnY1d4os2(lclsVH0UwZdCqGJam48mLGzVHv6fhdR0dF6y9IVfuqEfm48mLGO6KNyTRf(0X6fFBEMsWS3Wk9IJHv6HCZ30UwWG5XUj9TsWS3Wk9IJHv6H0AzpXbeG73ZZucIQtEI1Uw4mgW98mLGYKP9EjMXWNmKcGhdPDTW4i(k7nSc7vK89LScGhdPDTqmQEKmKanHMAVxabg8DdPDTqmQEKmKanHMkjE6y9IbKNPeuMmT3lXmgYvdxa5zkbLlvG1NmGb5QHlaEmK21cJJ4RS3WkSxrY3xYkqabelsdPDTyiQo5jw7AfXYgMgLF0P(jr2ByDGjMevkjUqC8bzGjMedLBpjqgw79Ipid0j(8qymTicEOt9riQKWprnNG7j7GHhBKRhWDESBsFRem7nSsV4yyLEiTw2tCGbZJAEAvyYBhsulKwl7joGaC)EEMsquDYtS21cNXaUNNPeuMmT3lXmg(KHua8yiTRfghXxzVHvyVIKVVKva8yiTRfIr1JKHeOj0u79ciWGVBiTRfIr1JKHeOj0ujXthRxmG8mLGYKP9EjMXqUA4ciptjOCPcS(KbmixnCbWJH0UwyCeFL9gwH9ks((swbciGyrAiTRfdZhbQo5jw7AfXYgMgLF0Xr8v2ByDGoXpptjyCeFH8g(aFYqkaKHvH2h628mLGO6KNyTRf(0X6fZI0qAxlgMpcuDYtS21kILnmnk)OJLlABqlsE7qywKgs7AXW8rGQtEI1UwrSSHPr5hDQFsK9gwhyIjrLsIlehFqgOt8ZZucM9gwPxCmSspeRgcy8bbqEMsq5sfy9jdyqUA4cGN8mLGXr8fYB4d8jdPaIFkkXfIdccmoIVYEdRaUNNPem7nSsV4yyLE4thRx8TGcccVcg8fId(0X6fFlOGGWRaXI0qAxlgMpcuDYtS21kILnmnk)Ot9tIS3W6atmjgk3EsGmS27fFqgOt8ZZucM9gwPxCmSspeRgcy8bbWDdPDTqmQEKmKanHMAVxamK21cXO6rYqc0eAQK4PJ1l(wqbbHxbdoptjy2ByLEXXWk9WNowV4BbfeeEfiwKgs7AXW8rGQtEI1UwrSSHPr5hngvpsEGoXpptjOCPcS(KbmixnCbChvLNRgUWu)Ki7nScF6y9IVfzyvO9Had2qAxlm1pjYEdRqKS9xeg4GciwKgs7AXW8rGQtEI1UwrSSHPr5hDQFsK9gwhyIjXq52tcKH1EV4dYatmjQusCH44dYaDIFEMsWS3Wk9IJHv6Hy1qad4Ga4E8trjUqCqqGyu9iza8KNPeuUubwFYagCgdGhdPDTqmQEKmKanHMAVxGbNNPem7nSsV4yyLE4thRx8TGcccVcelsdPDTyy(iq1jpXAxRiw2W0O8J23r17LixN8aDIFEMsquDYtS21cF6y9IV9cXbpgObyiTJIe0sNMWahewKgs7AXW8rGQtEI1UwrSSHPr5hn3Bx1If5NmvEGoXpptjiQo5jw7AHpDSEX3EH4Ghd0SinK21IH5JavN8eRDTIyzdtJYpAmQEKmlswK8oMJxuDYtS21YCXYgMyU4NITNWmNLBFRnHzUHTkZCgZXrElIbyovMwMZBZfjtyMRxTyovMyoEr1jpXAxlZHjEFmPfrSinK21IHO6KNyTRvelByIVVVKvSyKNCxhA1b6e)8mLGO6KNyTRfYvdxwKgs7AXquDYtS21kILnmnk)OrM3lmK21k8nwhyTdXpFeO6KNyTRvelByAGoX3Uj9TsWS3Wk9IJHv6H0AzpXbqnpTkm5TdjQfsRL9ehaEimMwebp0P(ievs4NOMtW9KDWWJnY1ZI0qAxlgIQtEI1UwrSSHPr5hD2xfNOscvMe0sNiyrAiTRfdr1jpXAxRiw2W0O8J(qN6JqujHFIAob3t2bZI0qAxlgIQtEI1UwrSSHPr5h910EU2wrLe2nPVuzwKgs7AXquDYtS21kILnmnk)O)5sIkjIRH0pqN4NNPeevN8eRDTqUA4YI0qAxlgIQtEI1UwrSSHPr5hnY8EHH0UwHVX6aRDi(gs7OiHAEAv8aDI)D7M03kbZEdR0logwPhsRL9ehG8mLGzVHv6fhdR0dXQHagW5pcGadMh7M03kbZEdR0logwPhsRL9ehlsdPDTyiQo5jw7AfXYgMgLF0O6KNyTRDGjMevkjUqC8bzGjMedLBpjqgw79Ipid0j(8qymTicEOt9riQKWprnNG7j7GHhBKRhWDESBsFRem7nSsV4yyLEiTw2tCGbZJAEAvyYBhsulKwl7joGaC)UH0Uw4HuQEyVIKVVKvags7AHhsP6H9ks((swfpDSEX3YhuqEfiWG5rnpTk8qkvpKwl7joGaCpptj4pxsujrCnKE4mgmyEuZtRc)5sIkjIRH0dP1YEIdiwKgs7AXquDYtS21kILnmnk)Or1jpXAx7atmjQusCH44dYatmjgk3EsGmS27fFqgOt8jmMwebp0P(ievs4NOMtW9KDWWJnY1d4EEMsWFUKOsI4Ai9WzmyW8OMNwf(ZLevsexdPhsRL9ehqSinK21IHO6KNyTRvelByAu(rhxAxllsdPDTyiQo5jw7AfXYgMgLF0zFvCI08JGfPH0UwmevN8eRDTIyzdtJYp6m9y6bwVxSinK21IHO6KNyTRvelByAu(rN6NY(Q4yrAiTRfdr1jpXAxRiw2W0O8J2weH138cK59SinK21IHO6KNyTRvelByAu(rJmVxyiTRv4BSoWAhIV(9cmsXSinK21IHO6KNyTRvelByAu(rN82HW63aJgOt8VFxnpTkm5TdjInfjdP1YEIdGH0oksqlDAcd8BaeyWgs7OibT0PjmW5TabiptjOCPcS(Kbm4tgsbWJDt6BLGzVHv6fhdR0dP1YEIJfPH0UwmevN8eRDTIyzdtJYp64i(k7nSoqN4NNPemoIVqEdFGpzifqEMsquDYtS21cF6y9IboYWQq7dXI0qAxlgIQtEI1UwrSSHPr5hDCeFL9gwhOt8ZZuckxQaRpzad(KHuwKgs7AXquDYtS21kILnmnk)Ot9tIS3W6atmjQusCH44dYatmjgk3EsGmS27fFqgOt8jmMwebp0P(ievs4NOMtW9KDWWJnY1d4os2(lclsVH0UwZdCqGJam48mLGzVHv6fhdR0dF6y9IVfuqEfm48mLGO6KNyTRf(0X6fFBEMsWS3Wk9IJHv6HCZ30UwWG5XUj9TsWS3Wk9IJHv6H0AzpXbeG73ZZucIQtEI1Uw4mgW98mLGYKP9EjMXWNmKcGhdPDTW4i(k7nSc7vK89LScGhdPDTqmQEKmKanHMAVxabg8DdPDTqmQEKmKanHMkjE6y9IbKNPeuMmT3lXmgYvdxa5zkbLlvG1NmGb5QHlaEmK21cJJ4RS3WkSxrY3xYkqabelsdPDTyiQo5jw7AfXYgMgLF0P(jr2ByDGjMevkjUqC8bzGjMedLBpjqgw79Ipid0j(8qymTicEOt9riQKWprnNG7j7GHhBKRhWDESBsFRem7nSsV4yyLEiTw2tCGbZJAEAvyYBhsulKwl7joGaC)EEMsquDYtS21cNXaUNNPeuMmT3lXmg(KHua8yiTRfghXxzVHvyVIKVVKva8yiTRfIr1JKHeOj0u79ciWGVBiTRfIr1JKHeOj0ujXthRxmG8mLGYKP9EjMXqUA4ciptjOCPcS(KbmixnCbWJH0UwyCeFL9gwH9ks((swbciGyrAiTRfdr1jpXAxRiw2W0O8JooIVYEdRd0j(XpfL4cXbbbIr1JKbKNPeuMmT3lXmgoJzrAiTRfdr1jpXAxRiw2W0O8JowUOTbTi5TdHzrAiTRfdr1jpXAxRiw2W0O8JgJQhjpqN4NNPeevN8eRDTWNowVyGJmSk0(qaYZucIQtEI1Uw4mgm48mLGO6KNyTRfYvdxwKgs7AXquDYtS21kILnmnk)O9Du9EjY1jpqN4NNPeevN8eRDTWNowV4BVqCWJbAags7OibT0PjmWbHfPH0UwmevN8eRDTIyzdtJYpAU3UQflYpzQ8aDIFEMsquDYtS21cF6y9IV9cXbpgObKNPeevN8eRDTWzmlsdPDTyiQo5jw7AfXYgMgLF0yu9i5b6eF1(lsHYK5vzymsVL)iafa180QqmzFVxcTMiziTw2tCSizrAiTRfd)kwelByI)pxsujrCnKEwKgs7AXWVIfXYgMgLF0jVDiS(nWOb6e)73vZtRctE7qIytrYqATSN4ayiTJIe0sNMWaheGad2qAhfjOLonHboVeia5zkbLlvG1NmGbFYqklsdPDTy4xXIyzdtJYp64i(k7nSoqN4NNPeuUubwFYag8jdPSinK21IHFflILnmnk)Ot9tIS3W6atmjQusCH44dYatmjgk3EsGmS27fFqgOt8VJQYZvdxiQo5jw7AHpDSEXahuGbN6NWQ9k9qdPDueG8mLG)CjrLeX1q6HZyGaCNN8mLGYKP9EjMXWNmKcGN8mLGYLkW6tgWGpzifapXpfLOsjXfIdM6NezVHva3nK21ct9tIS3WkejB)fHbo)Bag8DdPDTWy5I2g0IK3oegIKT)IWaNpiauZtRcJLlABqlsE7qyiTw2tCabg8D180QqZtGgRVHVPHfP5hbKwl7joaOQ8C1WfY92vTyr(jtLHpzCraeyW3vZtRcXK99Ej0AIKH0AzpXbqT)IuOmzEvggJ0B5pcqbeyW3vZtRct9ty1ELEiTw2tCas9ty1ELEOH0okciGaIfPH0Uwm8RyrSSHPr5hnY8EHH0UwHVX6aRDi(gs7OiHAEAvmlsdPDTy4xXIyzdtJYp64i(k7nSoqN4NNPemoIVqEdFGpzifaYWQq7dDBEMsW4i(c5n8b(0X6fdiptj4pxsujrCnKE4thRxmWrgwfAFiwKgs7AXWVIfXYgMgLF0P(jr2ByDGjMevkjUqC8bzGjMedLBpjqgw79Ipid0j(3rv55QHlevN8eRDTWNowVyGdkWGt9ty1ELEOH0okcqEMsWFUKOsI4Ai9WzmqaUNNPeuMmT3lXmg(KHua3v7VifktMxLHXif48hbOadMh180QqmzFVxcTMiziTw2tCabelsdPDTy4xXIyzdtJYp6u)Ki7nSoWetIkLexio(GmWetIHYTNeidR9EXhKb6e)7OQ8C1WfIQtEI1Uw4thRxmWbfyWP(jSAVsp0qAhfbiptj4pxsujrCnKE4mgiaQ5PvHyY(EVeAnrYqATSN4aO2FrkuMmVkdJr6T8hbOaCpptjOmzAVxIzm8jdPa4XqAxleJQhjdjqtOP27fyW8KNPeuMmT3lXmg(KHua8KNPeuUubwFYag8jdPaXI0qAxlg(vSiw2W0O8JooIVYEdRd0j(XpfL4cXbbbIr1JKbKNPeuMmT3lXmgoJbOMNwfIj779sO1ejdP1YEIdGA)fPqzY8QmmgP3YFeGcWDEuZtRctE7qIytrYqATSN4ad2qAhfjOLonH5dcqSinK21IHFflILnmnk)OJLlABqlsE7q4b6eFEIFkkXfIdccmwUOTbTi5TdHbKNPeuMmT3lXmg(KHuwKgs7AXWVIfXYgMgLF0yu9i5b6eF1(lsHYK5vzymsVL)iafa180QqmzFVxcTMiziTw2tCSinK21IHFflILnmnk)O5E7QwSi)KPYd0j(gs7OibT0PjmWVblsdPDTy4xXIyzdtJYp6K3oew)gy0aDI)D180QWK3oKi2uKmKwl7joags7OibT0PjmWVbqGbBiTJIe0sNMWaNxzrAiTRfd)kwelByAu(rN6NYM3ZIKfPH0UwmeR2YzpN4l10Uw(jVDiS(nWOb6e)73vZtRctE7qIytrYqATSN4ayiTJIe0sNMWahea8K6NWQ9k9qdPDueqGbBiTJIe0sNMWaNxceG8mLGYLkW6tgWGpziLfPH0UwmeR2YzpN4l10U2r5hDCeFL9gwhOt8ZZuckxQaRpzad(KHua5zkbLlvG1NmGbF6y9IV1qAxlm1pLnVhsGMqtLeAFiwKgs7AXqSAlN9CIVut7AhLF0Xr8v2ByDGoXpptjOCPcS(Kbm4tgsbCp(POexioiiWu)u28EWGt9ty1ELEOH0okcmydPDTW4i(k7nSc7vK89LScelsdPDTyiwTLZEoXxQPDTJYp64i(k7nSoqN4NNPeuUubwFYag8jdPau7VifktMxLHXi9w(JauauZtRcXK99Ej0AIKH0AzpXXI0qAxlgIvB5SNt8LAAx7O8JooIVYEdRd0j(5zkbJJ4lK3Wh4tgsbGmSk0(q3MNPemoIVqEdFGpDSEXSinK21IHy1wo75eFPM21ok)Ot9tIS3W6atmjQusCH44dYatmjgk3EsGmS27fFqgOt8VJQYZvdxiQo5jw7AHpDSEXahuaYZuc(ZLevsexdPhYvdxWGt9ty1ELEOH0okcia8OMNwfcSE589EbP1YEIdaprzFBzpbt9tIS3WQiUkFVxaUF)UH0UwyQFkBEpKanHMAVxGbBiTRfghXxzVHvibAcn1EVacW98mLGYKP9EjMXWNmKcgCQFcR2R0dnK2rra4jptjOCPcS(Kbm4tgsbWtEMsqzY0EVeZy4tgsbciWGVRMNwfIj779sO1ejdP1YEIdGA)fPqzY8QmmgP3YFeGcW98mLGYKP9EjMXWNmKcGhdPDTqmQEKmKanHMAVxGbZtEMsq5sfy9jdyWNmKcGN8mLGYKP9EjMXWNmKcWqAxleJQhjdjqtOP27faEmK21cJJ4RS3WkSxrY3xYkaEmK21ct9tzZ7H9ks((swbciWGVN6NWQ9k9qdPDueG7gs7AHXr8v2Byf2Ri57lzfmydPDTWu)u28EyVIKVVKvGaWtEMsqzY0EVeZy4tgsbWtEMsq5sfy9jdyWNmKceqSinK21IHy1wo75eFPM21ok)Ot9tIS3W6aDIVAEAviW6LZ37fKwl7joa5zkbLjt79smJHpzifWDuvEUA4cr1jpXAxl8PJ1lg4PP3lEcjB)fj0(qJEJrvZtRcbwVC(EVG0AzpXbgCQFcR2R0dF6y9IbEA69INqY2FrcTpeyW35rnpTk8NljQKiUgspKwl7joWGrv55QHl8NljQKiUgsp8PJ1lg4AFiHwcUMayiTRf(ZLevsexdPhIKT)IW3ccqaqv55QHlevN8eRDTWNowVyGR9HeAj4AciwKgs7AXqSAlN9CIVut7AhLF0Xr8v2ByDGoXp(POexioiiqmQEKmG8mLGYKP9EjMXWzma180QqmzFVxcTMiziTw2tCau7VifktMxLHXi9w(JauaUFxnpTkm5TdjInfjdP1YEIdGH0oksqlDAcZhea8K6NWQ9k9qdPDueqGbF3qAhfjOLonHVLxcGh180QWK3oKi2uKmKwl7joGaIfPH0UwmeR2YzpN4l10U2r5hDSCrBdArYBhcpqN4FpptjOmzAVxIzm8jdPGbFNN8mLGYLkW6tgWGpzifWDdPDTWu)Ki7nScrY2FryGdkWGvZtRcXK99Ej0AIKH0AzpXbqT)IuOmzEvggJ0B5pcqbeqabGNOSVTSNGXYfTnOfXv579IfPH0UwmeR2YzpN4l10U2r5hnY8EHH0UwHVX6aRDi(gs7OiHAEAvmlsdPDTyiwTLZEoXxQPDTJYpAU3UQflYpzQ8aDIVH0oksqlDAcdCqyrAiTRfdXQTC2Zj(snTRDu(rpXKOv6mWAhIV2CewR)iqfhb6b6eFuvEUA4cr1jpXAxl8PJ1lg43auGbRMNwfM6NWQ9k9qATSN4aK6NWQ9k9WNowVyGFdqXI0qAxlgIvB5SNt8LAAx7O8JEIjrR0zakLiKkw7q8rrG8L(12ir2ByDGoXhvLNRgUquDYtS21cF6y9Ib(nafyWQ5PvHP(jSAVspKwl7joaP(jSAVsp8PJ1lg43auSinK21IHy1wo75eFPM21ok)OXO6rYd0j(Q9xKcLjZRYWyKEl)rakaQ5PvHyY(EVeAnrYqATSN4yrAiTRfdXQTC2Zj(snTRDu(rN6NYM3ZI0qAxlgIvB5SNt8LAAx7O8JgJQhjZIKfPH0Uwmu)EbgPy(tmjALoywKgs7AXq97fyKIhLF0tmjALodS2H4hxiGrkUVjXjq1jEQM21k4OOAenqN4ZdQkpxnCHOiq(s)ABKi7nSc5MVPDTbjCmHcJXBhrqdAiaa]] )


end
