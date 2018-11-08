-- MageFire.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 63 )

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
        preheat = {
            id = 273333,
            duration = 30,
            max_stack = 1,
        },

        blaster_master = {
            id = 274598,
            duration = 3,
            max_stack = 1,
        }
    } )


    spec:RegisterStateTable( "firestarter", setmetatable( {}, {
        __index = setfenv( function( t, k )
            if k == "active" then return talent.firestarter.enabled and target.health.pct > 90 end
        end, state )
    } ) )
    

    --[[ spec:RegisterHook( "reset_precast", function ()
        auto_advance = false
    end ) ]]


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
                if talent.blazing_soul.enabled then applyBuff( "blazing_barrier" ) end
            end,
        },
        

        combustion = {
            id = 190319,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135824,
            
            handler = function ()
                applyBuff( "combustion" )
                stat.crit = stat.crit + 100
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

            usable = function () return target.casting end,
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
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135807,

            nobuff = "fire_blasting", -- horrible.
            
            handler = function ()
                if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                else applyBuff( "heating_up" ) end

                if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                if azerite.blaster_master.enabled then applyBuff( "blaster_master" ) end
                
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
            end,
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

            velocity = 25,
            
            handler = function ()
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
            
            handler = function ()
                if buff.combustion.up or ( talent.firestarter.enabled and target.health.pct > 90 ) then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end

                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                end

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
            
            handler = function ()
                if buff.combustion.up or ( talent.firestarter.enabled and target.health.pct > 90 ) then
                    if buff.heating_up.up then removeBuff( "heating_up" ); applyBuff( "hot_streak" )
                    else applyBuff( "heating_up" ) end

                    if talent.kindling.enabled then setCooldown( "combustion", max( 0, cooldown.combustion.remains - 1 ) ) end
                end

                applyDebuff( "target", "ignite" )
                removeBuff( "hot_streak" )
                removeBuff( "pyroclasm" )
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
            
            toggle = "cooldowns",

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
                applyDebuff( "target", "ignite" )

                if azerite.preheat.enabled then applyDebuff( "target", "preheat" ) end
            end,
        },
        

        shimmer = {
            id = 212653,
            cast = 0,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",
            
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
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "battle_potion_of_intellect",
        
        package = "Fire",
    } )


    spec:RegisterPack( "Fire", 20180930.1704, [[dqud2aqiuOEeeqBsigfvuNIkYQes4vqKzPiClHeTlk9lfLHjK6yQKwge0ZuuzAkQ6AqG2Mqs(gkKghQsCoiawheGMNIu3dfTpufhuiPOfIcEOqsPUikePnIQK6KcjfwPkXmfsk5Mcjv7eIAOOqyPOkjpvftvLQ9c8xrgSGdtAXk8yqtgvUmYMf1NrvnAH60swnkeXRvenBQ62qA3k9BPgovA5Q65qnDIRJsBhc9DvkJhvPoVIK1JcrnFQW(PyWvWDWHtfcGmcJ(kVencWCrBVYOrp)C8c4it5sGJRcNu5tGZQOe4WRRNahxDkFRCG7GdUzFiboXI4IraNnJFjXSdlSrNHluwVkvVWxZYmCHcNn89y2iRrjhH4m3VZLNWZyepXR0IdpJrWRsrDLpL411twCHcbNbB5LOglyaoCQqaKry0x5LOraMlA7vgn6RZph4OSsC)GZPqz9Qu9g1(1SaoXfhhTGb4Wryi4GanbED9Kje1v(K5cc0eIfXfJaoBg)sIzhwyJodxOSEvQEHVMLz4cfoB47XSrwJsocXzUFNlpHNXiEIxPfhEgJGxLI6kFkXRRNS4cfAUGanHd5ke6GEtyUONWeqy0x5ftiknHRmkcy0rdo(clyWDWHJYkRxa3biFfChCuOu9coWMDf6XUK3do0QdpXbyaiaKri4o4qRo8ehGbWb(LqFPGZGnNTWgDWILQxlxFBbhfkvVGdA9F)Pcv5tabG8CG7GdT6WtCagah4xc9Lco56jSOVqVvHsHizcrmbfkvV2NDPuNtU9n6TWy95tytGPjGqtWHdta2TNRVTwyJoyXs1R9juTwSjWJjmF0MqetyWMZwyJoyXs1RLRVTMqetGXMGOEAf7K1Y5RLVLwD4jotWHdtq0NpjwPqPK0jUImHPnHRxnbhombr90k2jRLZxlFlT6WtCMqetWztagRpFcNYVcLQx1Bc8ycxT8Ij4WHjifkzctBcZhTj4KjeXeGD756BRf2OdwSu9AFcvRfBc8ycZhn4OqP6fCE2LsDo523OhiaKNhChCOvhEIdWa4a)sOVuWzWMZw3P(g6vmQ9jfkMqetWzta2TNRVTwyJoyXs1R9juTwSjWJjmF0MGdhMGcLQx7ZUuQZj3(g9wyS(8jSjWJjC1eCcCuOu9cop7sPoNC7B0deaYii4o4qRo8ehGbWb(LqFPGdSBpxFBTWgDWILQx7tOATytyAMMGcLQx7ZUuQZj3(g9wOILKuOKjGKj4SjWytqupTIDYA581Y3sRo8eNjefMaFiNj4KjeXeC2eySjiQNwXMRNWI(c9wA1HN4mbhombgBc56jSOVqVvHsHizcoCyckukePeTeArytGhMMW8MGdhMGcLcrkrlHwe2e4HPjGqtiIjiQNwXM9kkLCvbgBPvhEIZeCYeC4WegS5Sf2OdwSu9AzDbhfkvVGdu9(KcLQ3KVWc44lSKwfLahyJoyXs1BYnwXeqaihvG7GdT6WtCagah4xc9Lcod2C2(SlL6CYTVrVL11eIycd2C2cB0blwQETC9TfCuOu9coq17tkuQEt(clGJVWsAvucC(2n5gRyciaKzuWDWHwD4joadGJcLQxWbQEFsHs1BYxybC8fwsRIsGdw0LtFU03IkvVabiGJ7tWgDOc4oa5RG7GdT6WtCagacazecUdo0QdpXbyaiaKNdChCOvhEIdWaqaipp4o4OqP6fC0hQlLQviVNGc4qRo8ehGbGaqgbb3bhA1HN4amaeaYrf4o4OqP6fCqR)7pvOkFcCOvhEIdWaqaiZOG7GJcLQxWXTLQxWHwD4joadabGmVaUdokuQEbh3P(E4vSao0QdpXbyaiabCGn6GflvVj3yftG7aKVcUdo0QdpXbyaCGFj0xk4myZzlSrhSyP61Y13wWrHs1l44l(XcoXiHLJpkTcqaiJqWDWHwD4joadGd8lH(sbNbBoBHn6GflvVwU(2cokuQEbNNDPuNtU9n6bca55a3bhA1HN4amaokuQEbhO69jfkvVjFHfWXxyjTkkbokukePKOEAfmqaipp4o4OqP6fCGn6GflvVGdT6WtCagacazeeChCuOu9coUTu9co0QdpXbyaiaKJkWDWrHs1l4m8DZLYS)uGdT6WtCagacazgfChCuOu9cod6X0pzT8bhA1HN4amaeaY8c4o4OqP6fCY1tdF3CGdT6WtCagacazeaWDWrHs1l4OlKWYR(eu9EWHwD4joadabG81Ob3bhfkvVGdlMsLqOyWHwD4joadabG81RG7GdT6WtCagah4xc9LcooBcoBcI6PvSzVIsjxvGXwA1HN4mHiMGcLcrkrlHwe2e4XeqOj4Kj4WHjOqPqKs0sOfHnbEmHOYeCYeIycd2C2g3sclpPtAFsHc4OqP6fCYEfLWYxtsabG8vecUdo0QdpXbyaCGFj0xk4myZzR7uFd9kg1(KcftiIjmyZzlSrhSyP61(eQwl2e4XeiEtqwHssHsGJcLQxWXDQVhEflabG815a3bhA1HN4amaoWVe6lfCgS5SnULewEsN0(KcfWrHs1l44o13dVIfGaq(68G7GdT6WtCagah4xc9Lcod2C2gtQul)eRR9jfkGJcLQxWjxpLgEflabG8veeChCuOu9coUXnTfVtzVIsyWHwD4joadabG81OcChCOvhEIdWa4a)sOVuWzWMZwyJoyXs1R9juTwSjWJjavSKKcLahfkvVGdg2pmgiaKVYOG7GdT6WtCagah4xc9Lcom2egS5SnULewEsN0(KcftiIjOqP61MRNsdVIflmwF(e2eM2eUcokuQEbhUx53lonEsLyGaq(kVaUdo0QdpXbyaCGFj0xk4i6ZNeBmPEj26cftyAMMWCrBcrmbr90kwmPFT8tsZcJT0QdpXbokuQEbhmSFymqac4OqPqKsI6PvWG7aKVcUdo0QdpXbyaCGFj0xk44SjmyZzlSrhSyP61Y13wtWjtWHdtWztyWMZwyJoyXs1RL11eIyckuQET56P0WRyXcJ1NpHnHPnHRMGtGJcLQxWz4vSKUPisabGmcb3bhA1HN4amaoWVe6lfCGD756BRf2OdwSu9AFcvRfBc8ycZhTj4WHj4Sja72Z13wlSrhSyP61(eQwl2e4Xee95tIvkukjDIRitWjtWHdtyWMZ2NDPuNtU9n6TSUMGdhMqUEcl6l0BvOuisGJcLQxWbLeQFGaqEoWDWHwD4joadGd8lH(sbhr90kw1t8glVIzKvCkZ(tzPvhEIZeIycm2egS5SnULewEsN0(KcfWrHs1l4W9k)EXPXtQedeaYZdUdo0QdpXbyaCGFj0xk4OqPqKs0sOfHnbEmHRMqetyWMZwyJoyXs1RLRVTGJcLQxWXxiwl)0OrhabiGdw0LtFU03IkvVG7aKVcUdo0QdpXbyaCGFj0xk44Sj4SjiQNwXM9kkLCvbgBPvhEIZeIyckukePeTeArytGht4Qj4Kj4WHjOqPqKs0sOfHnbEmH5nbNmHiMWGnNTXTKWYt6K2NuOaokuQEbNSxrjS81KeqaiJqWDWHwD4joadGd8lH(sbNbBoBJBjHLN0jTpPqXeIycd2C2g3sclpPtAFcvRfBctBckuQET56PH69wI3eKvOKuOe4OqP6fCCN67HxXcqaiph4o4qRo8ehGbWb(LqFPGZGnNTXTKWYt6K2NuOycrmHC9ew0xO3QqPqKmHiMaJnbr90k2NDPuNtU9n6T0QdpXbokuQEbh3P(E4vSaeaYZdUdo0QdpXbyaCGFj0xk4aJ1NpHt5xHs1R6nbEmbeAzutiIjOqPqKs0sOfHnbEmbecokuQEbh34M2I3PSxrjmqaiJGG7GdT6WtCagah4xc9Lcod2C2g3sclpPtAFsHIjeXeC2eySj4(eIj(qo7vR7uFp8kwmbhombfkvVw3P(E4vSyRnL9f)yXeCcCuOu9coUt99WRybiaKJkWDWHwD4joadGd8lH(sbNbBoBJBjHLN0jTpPqXeIycI(8jXgtQxITUqXeMMPjmx0MqetqupTIft6xl)K0SWylT6WtCGJcLQxWXDQVhEflabGmJcUdo0QdpXbyaCGFj0xk4myZzR7uFd9kg1(KcftiIjq8MGScLKcLmHPnHbBoBDN6BOxXO2Nq1AXGJcLQxWXDQVhEflabGmVaUdo0QdpXbyaCuOu9coq17tkuQEt(clGJVWsAvucCuOuisjr90kyGaqgbaChCOvhEIdWa4a)sOVuWHXMGOEAf7K1Y5RLVLwD4jotiIjmyZzBmPsT8tSU2NuOycrmbNnbgBcI6PvSp7sPoNC7B0BPvhEIZeC4WeGX6ZNWP8RqP6v9MapMWv78MGdhMaSBpxFBTWgDWILQx7tOATytyAty(OnbNmHiMGZMWCMquAcWy95t4u(vOu9QEtWjtikmbNnHRi0eIcta7sEFkwXczcozctBcWU9C9T1cB0blwQETpHQ1InbKmH5mbhombrF(KyLcLssN4kYeM2eMhCuOu9co56P0WRybiaKVgn4o4qRo8ehGbWb(LqFPGJOEAf7K1Y5RLVLwD4jotiIjmyZzBmPsT8tSU2NuOycrmbNnbgBcI6PvSp7sPoNC7B0BPvhEIZeC4WeGX6ZNWP8RqP6v9MapMWvlcAcoCycWU9C9T1cB0blwQETpHQ1InHPnH5J2eCYeIycoBcZzcrPjaJ1NpHt5xHs1R6nbNmHOWeC2eUYlMquycyxY7tXkwitWjtyAta2TNRVTwyJoyXs1R9juTwSjGKjmNj4WHji6ZNeRuOus6exrMW0MW8GJcLQxWjxpLgEflabG81RG7GdT6WtCagah4xc9LcooBcd2C2cB0blwQETSUMGdhMWGnNTp7sPoNC7B0BzDnbhomHbBoBRfQRqpoL99nlwu4KMapMWCMGdhMGOEAflA9F)Pcv5twA1HN4mbNmHiMGZMW8MquAcWy95t4u(vOu9QEtWjtikmHRZzctBcWU9C9T1cB0blwQETpHQ1InbKmbe0eC4Wee95tIvkukjDIRityAt4A0GJcLQxWXnUPT4Dk7vucdeaYxri4o4qRo8ehGbWb(LqFPGJZMWGnNTWgDWILQxlRRj4WHjmyZz7ZUuQZj3(g9wwxtWjtiIj4SjmVjeLMamwF(eoLFfkvVQ3eCYeIctyUOnHPnby3EU(2AHn6GflvV2Nq1AXMasMaccokuQEbh34M2I3PSxrjmqaiFDoWDWHwD4joadGd8lH(sbhyS(8jCk)kuQEvVjWJjGqlcAcrmby3EU(2AHn6GflvV2Nq1AXMapMacNdCuOu9coUXnTfVtzVIsyGaq(68G7GdT6WtCagah4xc9LcooBcI(8jXgtQxITUqXeMMPjmx0MqetqupTIft6xl)K0SWylT6WtCMGtMGdhMGZMGYitFjK19PysflT6WtCMqetGJgS5S19PysflxFBnbNahfkvVGdg2pmgiaKVIGG7GJcLQxWjxpnuVhCOvhEIdWaqaiFnQa3bhfkvVGdg2pmgCOvhEIdWaqac48TBYnwXe4oa5RG7GJcLQxW5zxk15KBFJEWHwD4joadabGmcb3bhA1HN4amaoWVe6lfCC2eC2ee1tRyZEfLsUQaJT0QdpXzcrmbfkfIuIwcTiSjWJjC1eCYeC4WeuOuisjAj0IWMapMW8MGtMqetyWMZ24wsy5jDs7tkuahfkvVGt2ROew(AsciaKNdChCOvhEIdWa4a)sOVuWzWMZ24wsy5jDs7tkuahfkvVGJ7uFp8kwaca55b3bhA1HN4amaokuQEbhO69jfkvVjFHfWXxyjTkkbokukePKOEAfmqaiJGG7GdT6WtCagah4xc9Lcod2C26o13qVIrTpPqXeIyceVjiRqjPqjtyAtyWMZw3P(g6vmQ9juTwSjeXegS5S9zxk15KBFJE7tOATytGhtaQyjjfkbokuQEbh3P(E4vSaeaYrf4o4qRo8ehGbWb(LqFPGdJnb3Nqm15CIpKZMRNsdVIftiIjmyZzBmPsT8tSU2NuOycrmHC9ew0xO3QqPqKmHiMamwF(eoLFfkvVQ3e4XeUAzuWrHs1l4KRNsdVIfGaqMrb3bhA1HN4amaoWVe6lfCySj4(eIj(qo7vRBCtBX7u2ROe2eIycWy95t4u(vOu9QEtGhtaHwg1eIyc56jSOVqVvHsHibokuQEbh34M2I3PSxrjmqaiZlG7GdT6WtCagah4xc9Lcom2eCFcXuNZj(qoBUEkn8kwmHiMaJnHC9ew0xO3QqPqKahfkvVGtUEkn8kwacazeaWDWHwD4joadGd8lH(sbhgBcUpHyIpKZE16g30w8oL9kkHbhfkvVGJBCtBX7u2ROegiaKVgn4o4qRo8ehGbWb(LqFPGJOpFsSXK6LyRlumHPzAcZfTjeXee1tRyXK(1Ypjnlm2sRo8eh4OqP6fCWW(HXabG81RG7GdT6WtCagah4xc9LcokukePeTeArytGhtaHGJcLQxWH7v(9ItJNujgiaKVIqWDWHwD4joadGd8lH(sbhNnbr90k2SxrPKRkWylT6WtCMqetqHsHiLOLqlcBc8yci0eCYeC4WeuOuisjAj0IWMapMaccokuQEbNSxrjS81KeqaiFDoWDWrHs1l4KRNgQ3do0QdpXbyaiabiGdI0JREbiJWOVYlrZlxNZgD0ZJGGZn93A5JbNOgOU9leNjevMGcLQxtWxybBnxahSlbbihvZboUFNlpboiqtGxxpzcrDLpzUGanHyrCXiGZMXVKy2Hf2OZWfkRxLQx4RzzgUqHZg(EmBK1OKJqCM735Yt4zmIN4vAXHNXi4vPOUYNs866jlUqHMliqt4qUcHoO3eMl6jmbeg9vEXeIst4kJIagD0MlMliqtGrkVjiRqCMWGY9tMaSrhQycdIFTyRje1ecjxbBcBVrzS(OzwVjOqP6fBc96NYAUOqP6fBDFc2OdvyM9kEsZffkvVyR7tWgDOcsmNL7MZCrHs1l26(eSrhQGeZzklFuAfvQEnxuOu9ITUpbB0HkiXCM(qDPuTc59eumxuOu9ITUpbB0HkiXCgEvxCCljSOc2CrHs1l26(eSrhQGeZzO1)9NkuLpzUOqP6fBDFc2OdvqI5m3wQEnxuOu9ITUpbB0HkiXCM7uFp8kwmxmxqGMaJuEtqwH4mbcr6NYeKcLmbjMmbfk9Bcf2eue1YRdpznxuOu9IzcB2vOh7sEV5IcLQxmsmNHw)3FQqv(0evM5GnNTWgDWILQxlxFBnxqGMWr0LtFot4U6PvmbEvZimHOwn)cAnxuOu9IrI5SNDPuNtU9n6NOYmZ1tyrFHERcLcrkIcLQx7ZUuQZj3(g9wyS(8jmte6WbSBpxFBTWgDWILQx7tOATyEMp6id2C2cB0blwQETC9TncJf1tRyNSwoFT8T0QdpX5WHOpFsSsHsjPtCfn91RoCiQNwXozTC(A5BPvhEIlIZWy95t4u(vOu9QEEUA5fhoKcLME(ODkcSBpxFBTWgDWILQx7tOATyEMpAZfeOjWRAgHjWIjt4wC5jtGfxlFtGrm13qVIrTMlkuQEXiXC2ZUuQZj3(g9tuzMd2C26o13qVIrTpPqjIZWU9C9T1cB0blwQETpHQ1I5z(OD4qHs1R9zxk15KBFJElmwF(eMNRozUOqP6fJeZzq17tkuQEt(cltSkkXe2OdwSu9MCJvmnrLzc72Z13wlSrhSyP61(eQwlEAMkuQETp7sPoNC7B0BHkwssHsi5mJf1tRyNSwoFT8T0QdpXff8HCofXzglQNwXMRNWI(c9wA1HN4C4GX56jSOVqVvHsHi5WHcLcrkrlHweMhMZ7WHcLcrkrlHweMhMimIOEAfB2ROuYvfySLwD4joNC4yWMZwyJoyXs1RL11CrHs1lgjMZGQ3NuOu9M8fwMyvuI53Uj3yfttuzMd2C2(SlL6CYTVrVL1nYGnNTWgDWILQxlxFBnxuOu9IrI5mO69jfkvVjFHLjwfLyIfD50Nl9TOs1R5I5IcLQxSvHsHiLe1tRGzo8kws3uePjQmtNhS5Sf2OdwSu9A56BRtoC48GnNTWgDWILQxlRBefkvV2C9uA4vSyHX6ZNWtF1jZffkvVyRcLcrkjQNwbJeZzOKq9prLzc72Z13wlSrhSyP61(eQwlMN5J2HdNHD756BRf2OdwSu9AFcvRfZJOpFsSsHsjPtCf5Kdhd2C2(SlL6CYTVrVL11HJC9ew0xO3QqPqKmxuOu9ITkukePKOEAfmsmNX9k)EXPXtQeprLzkQNwXQEI3y5vmJSItz2FklT6WtCry8GnNTXTKWYt6K2NuOyUOqP6fBvOuisjr90kyKyoZxiwl)0OrhtuzMkukePeTeAryEUgzWMZwyJoyXs1RLRVTMlMlkuQEXwyJoyXs1BYnwXetFXpwWjgjSC8rPvMOYmhS5Sf2OdwSu9A56BR5IcLQxSf2OdwSu9MCJvmHeZzp7sPoNC7B0prLzoyZzlSrhSyP61Y13wZffkvVylSrhSyP6n5gRycjMZGQ3NuOu9M8fwMyvuIPcLcrkjQNwbBUOqP6fBHn6GflvVj3yftiXCgSrhSyP61CrHs1l2cB0blwQEtUXkMqI5m3wQEnxuOu9ITWgDWILQ3KBSIjKyoB47MlLz)PmxuOu9ITWgDWILQ3KBSIjKyoBqpM(jRLV5IcLQxSf2OdwSu9MCJvmHeZz56PHVBoZffkvVylSrhSyP6n5gRycjMZ0fsy5vFcQEV5IcLQxSf2OdwSu9MCJvmHeZzSykvcHInxuOu9ITWgDWILQ3KBSIjKyol7vuclFnjnrLz6SZI6PvSzVIsjxvGXwA1HN4IOqPqKs0sOfH5bHo5WHcLcrkrlHweMNOYPid2C2g3sclpPtAFsHI5IcLQxSf2OdwSu9MCJvmHeZzUt99WRyzIkZCWMZw3P(g6vmQ9jfkrgS5Sf2OdwSu9AFcvRfZdXBcYkuskuYCrHs1l2cB0blwQEtUXkMqI5m3P(E4vSmrLzoyZzBCljS8KoP9jfkMlkuQEXwyJoyXs1BYnwXesmNLRNsdVILjQmZbBoBJjvQLFI11(KcfZffkvVylSrhSyP6n5gRycjMZCJBAlENYEfLWMlkuQEXwyJoyXs1BYnwXesmNHH9dJNOYmhS5Sf2OdwSu9AFcvRfZduXsskuYCrHs1l2cB0blwQEtUXkMqI5mUx53lonEsL4jQmtgpyZzBCljS8KoP9jfkruOu9AZ1tPHxXIfgRpFcp9vZffkvVylSrhSyP6n5gRycjMZWW(HXtuzMI(8jXgtQxITUqzAMZfDer90kwmPFT8tsZcJT0QdpXzUyUOqP6fB)2n5gRyI5ZUuQZj3(g9MlkuQEX2VDtUXkMqI5SSxrjS81K0evMPZolQNwXM9kkLCvbgBPvhEIlIcLcrkrlHweMNRo5WHcLcrkrlHweMN5DkYGnNTXTKWYt6K2NuOyUOqP6fB)2n5gRycjMZCN67HxXYevM5GnNTXTKWYt6K2NuOyUOqP6fB)2n5gRycjMZGQ3NuOu9M8fwMyvuIPcLcrkjQNwbBUOqP6fB)2n5gRycjMZCN67HxXYevM5GnNTUt9n0Ryu7tkuIq8MGScLKcLMEWMZw3P(g6vmQ9juTwCKbBoBF2LsDo523O3(eQwlMhOILKuOK5IcLQxS9B3KBSIjKyolxpLgEfltuzMm29jetDoN4d5S56P0WRyjYGnNTXKk1YpX6AFsHsKC9ew0xO3QqPqKIaJ1NpHt5xHs1R655QLrnxuOu9ITF7MCJvmHeZzUXnTfVtzVIs4jQmtg7(eIj(qo7vRBCtBX7u2ROeocmwF(eoLFfkvVQNheAz0i56jSOVqVvHsHizUOqP6fB)2n5gRycjMZY1tPHxXYevMjJDFcXuNZj(qoBUEkn8kwIW4C9ew0xO3QqPqKmxuOu9ITF7MCJvmHeZzUXnTfVtzVIs4jQmtg7(eIj(qo7vRBCtBX7u2ROe2CrHs1l2(TBYnwXesmNHH9dJNOYmf95tInMuVeBDHY0mNl6iI6PvSys)A5NKMfgBPvhEIZCrHs1l2(TBYnwXesmNX9k)EXPXtQeprLzQqPqKs0sOfH5bHMlkuQEX2VDtUXkMqI5SSxrjS81K0evMPZI6PvSzVIsjxvGXwA1HN4IOqPqKs0sOfH5bHo5WHcLcrkrlHweMhe0CrHs1l2(TBYnwXesmNLRNgQ3BUyUOqP6fBXIUC6ZL(wuP6Lz2ROew(AsAIkZ0zNf1tRyZEfLsUQaJT0QdpXfrHsHiLOLqlcZZvNC4qHsHiLOLqlcZZ8ofzWMZ24wsy5jDs7tkumxuOu9ITyrxo95sFlQu9IeZzUt99WRyzIkZCWMZ24wsy5jDs7tkuImyZzBCljS8KoP9juTw80kuQET56PH69wI3eKvOKuOK5IcLQxSfl6YPpx6BrLQxKyoZDQVhEfltuzMd2C2g3sclpPtAFsHsKC9ew0xO3QqPqKIWyr90k2NDPuNtU9n6T0QdpXzUOqP6fBXIUC6ZL(wuP6fjMZCJBAlENYEfLWtuzMWy95t4u(vOu9QEEqOLrJOqPqKs0sOfH5bHMlkuQEXwSOlN(CPVfvQErI5m3P(E4vSmrLzoyZzBCljS8KoP9jfkrCMXUpHyIpKZE16o13dVIfhouOu9ADN67HxXIT2u2x8JfNmxuOu9ITyrxo95sFlQu9IeZzUt99WRyzIkZCWMZ24wsy5jDs7tkuIi6ZNeBmPEj26cLPzox0re1tRyXK(1Ypjnlm2sRo8eN5IcLQxSfl6YPpx6BrLQxKyoZDQVhEfltuzMd2C26o13qVIrTpPqjcXBcYkuskuA6bBoBDN6BOxXO2Nq1AXMlkuQEXwSOlN(CPVfvQErI5mO69jfkvVjFHLjwfLyQqPqKsI6PvWMlkuQEXwSOlN(CPVfvQErI5SC9uA4vSmrLzYyr90k2jRLZxlFlT6WtCrgS5SnMuPw(jwx7tkuI4mJf1tRyF2LsDo523O3sRo8eNdhWy95t4u(vOu9QEEUAN3Hdy3EU(2AHn6GflvV2Nq1AXtpF0ofX55IsyS(8jCk)kuQEvVtrHZxryuGDjVpfRyHCAAy3EU(2AHn6GflvV2Nq1AXinNdhI(8jXkfkLKoXv00ZBUOqP6fBXIUC6ZL(wuP6fjMZY1tPHxXYevMPOEAf7K1Y5RLVLwD4jUid2C2gtQul)eRR9jfkrCMXI6PvSp7sPoNC7B0BPvhEIZHdyS(8jCk)kuQEvppxTiOdhWU9C9T1cB0blwQETpHQ1INE(ODkIZZfLWy95t4u(vOu9QENIcNVYlrb2L8(uSIfYPPHD756BRf2OdwSu9AFcvRfJ0CoCi6ZNeRuOus6exrtpV5IcLQxSfl6YPpx6BrLQxKyoZnUPT4Dk7vucprLz68GnNTWgDWILQxlRRdhd2C2(SlL6CYTVrVL11HJbBoBRfQRqpoL99nlwu4K8mNdhI6PvSO1)9NkuLpzPvhEIZPiopFucJ1NpHt5xHs1R6DkkUo30WU9C9T1cB0blwQETpHQ1IrcbD4q0NpjwPqPK0jUIM(A0MlkuQEXwSOlN(CPVfvQErI5m34M2I3PSxrj8evMPZd2C2cB0blwQETSUoCmyZz7ZUuQZj3(g9wwxNI488rjmwF(eoLFfkvVQ3POyUONg2TNRVTwyJoyXs1R9juTwmsiO5IcLQxSfl6YPpx6BrLQxKyoZnUPT4Dk7vucprLzcJ1NpHt5xHs1R65bHwemcSBpxFBTWgDWILQx7tOATyEq4CMlkuQEXwSOlN(CPVfvQErI5mmSFy8evMPZI(8jXgtQxITUqzAMZfDer90kwmPFT8tsZcJT0QdpX5KdhoRmY0xczDFkMuXsRo8exeoAWMZw3NIjvSC9T1jZffkvVylw0LtFU03IkvViXCwUEAOEV5IcLQxSfl6YPpx6BrLQxKyodd7hgdeGaaa]] )


end
