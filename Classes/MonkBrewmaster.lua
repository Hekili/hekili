-- MonkBrewmaster.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'MONK' then
    local spec = Hekili:NewSpecialization( 268 )

    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.Chi )
    spec:RegisterResource( Enum.PowerType.Mana )
    
    -- Talents
    spec:RegisterTalents( {
        eye_of_the_tiger = 23106, -- 196607
        chi_wave = 19820, -- 115098
        chi_burst = 20185, -- 123986

        celerity = 19304, -- 115173
        chi_torpedo = 19818, -- 115008
        tigers_lust = 19302, -- 116841

        light_brewing = 22099, -- 196721
        spitfire = 22097, -- 242580
        black_ox_brew = 19992, -- 115399

        tiger_tail_sweep = 19993, -- 264348
        summon_black_ox_statue = 19994, -- 115315
        ring_of_peace = 19995, -- 116844

        bob_and_weave = 20174, -- 280515
        healing_elixir = 23363, -- 122281
        dampen_harm = 20175, -- 122278

        special_delivery = 19819, -- 196730
        rushing_jade_wind = 20184, -- 116847
        invoke_niuzao_the_black_ox = 22103, -- 132578

        high_tolerance = 22106, -- 196737
        guard = 22104, -- 115295
        blackout_combo = 22108, -- 196736
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3569, -- 214027
        relentless = 3570, -- 196029
        gladiators_medallion = 3571, -- 208683
        admonishment = 843, -- 207025
        fast_feet = 3526, -- 201201
        mighty_ox_kick = 673, -- 202370
        eerie_fermentation = 765, -- 205147
        niuzaos_essence = 1958, -- 232876
        double_barrel = 672, -- 202335
        incendiary_breath = 671, -- 202272
        craft_nimble_brew = 670, -- 213658
        avert_harm = 669, -- 202162
        hot_trub = 667, -- 202126
        guided_meditation = 668, -- 202200
        eminence = 3617, -- 216255
        microbrew = 666, -- 202107
    } )

    -- Auras
    spec:RegisterAuras( {
        blackout_combo = {
            id = 228563,
            duration = 15,
            max_stack = 1,
        },
        brewmasters_balance = {
            id = 245013,
        },
        breath_of_fire_dot = {
            id = 123725,
            duration = 12,
            max_stack = 1,
        },
        celestial_fortune = {
            id = 216519,
        },
        chi_torpedo = {
            id = 115008,
            duration = 10,
            max_stack = 2,
        },
        crackling_jade_lightning = {
            id = 117952,
            duration = function () return 4 * haste end ,
            max_stack = 1,
        },
        dampen_harm = {
            id = 122278,
            duration = 10,
            max_stack = 1,
        },
        elusive_brawler = {
            id = 195630,
            duration = 10,
            max_stack = 10,
        },
        eye_of_the_tiger = {
            id = 196608,
            duration = 8,
            max_stack = 1,
        },
        fortifying_brew = {
            id = 120954,
            duration = 15,
            max_stack = 1,
        },
        gift_of_the_ox = {
            id = 124502,
        },
        guard = {
            id = 115295,
            duration = 8,
            max_stack = 1,
        },
        ironskin_brew = {
            id = 215479,
            duration = 6,
            max_stack = 1,
        },
        keg_smash = {
            id = 121253,
            duration = 15,
            max_stack = 1,
        },
        leg_sweep = {
            id = 119381,
            duration = 3,
            max_stack = 1,
        },
        mana_divining_stone = {
            id = 227723,
            duration = 3600,
            max_stack = 1,
        },
        mystic_touch = {
            id = 8647,
        },
        paralysis = {
            id = 115078,
            duration = 60,
            max_stack = 1,
        },
        provoke = {
            id = 116189,
            duration = 3,
            max_stack = 1,
        },
        rushing_jade_wind = {
            id = 116847,
            duration = function () return 9 * haste end,
            max_stack = 1,
        },
        sign_of_the_warrior = {
            id = 225787,
            duration = 3600,
            max_stack = 1,
        },
        tiger_tail_sweep = {
            id = 264348,
        },
        tigers_lust = {
            id = 116841,
            duration = 6,
            max_stack = 1,
        },
        transcendence = {
            id = 101643,
            duration = 900,
            max_stack = 1,
        },
        transcendence_transfer = {
            id = 119996,
        },
        zen_flight = {
            id = 125883,
        },
        zen_meditation = {
            id = 115176,
            duration = 8,
            max_stack = 1,
        },

        light_stagger = {
            id = 124275,
            duration = 10,
            unit = "player",
        },
        moderate_stagger = {
            id = 124274,
            duration = 10,
            unit = "player",
        },
        heavy_stagger = {
            id = 124273,
            duration = 10,
            unit = "player",
        },
    } )


    spec:RegisterHook( 'reset_postcast', function( x )
        for k, v in pairs( stagger ) do
            stagger[ k ] = nil
        end
        return x
    end )


    spec:RegisterGear( 'tier19', 138325, 138328, 138331, 138334, 138337, 138367 )
    spec:RegisterGear( 'tier20', 147154, 147156, 147152, 147151, 147153, 147155 )
    spec:RegisterGear( 'tier21', 152145, 152147, 152143, 152142, 152144, 152146 )
    spec:RegisterGear( 'class', 139731, 139732, 139733, 139734, 139735, 139736, 139737, 139738 )
    
    spec:RegisterGear( 'cenedril_reflector_of_hatred', 137019 )
    spec:RegisterGear( 'cinidaria_the_symbiote', 133976 )
    spec:RegisterGear( 'drinking_horn_cover', 137097 )
    spec:RegisterGear( 'firestone_walkers', 137027 )
    spec:RegisterGear( 'fundamental_observation', 137063 )
    spec:RegisterGear( 'gai_plins_soothing_sash', 137079 )
    spec:RegisterGear( 'hidden_masters_forbidden_touch', 137057 )
    spec:RegisterGear( 'jewel_of_the_lost_abbey', 137044 )
    spec:RegisterGear( 'katsuos_eclipse', 137029 )
    spec:RegisterGear( 'march_of_the_legion', 137220 )
    spec:RegisterGear( 'salsalabims_lost_tunic', 137016 )
    spec:RegisterGear( 'soul_of_the_grandmaster', 151643 )
    spec:RegisterGear( 'stormstouts_last_gasp', 151788 )
    spec:RegisterGear( 'the_emperors_capacitor', 144239 )
    spec:RegisterGear( 'the_wind_blows', 151811 )


    spec:RegisterHook( "reset_precast", function ()
        rawset( healing_sphere, "count", nil )
        stagger.amount = nil
    end )

    spec:RegisterHook( "spend", function( amount, resource )
        if equipped.the_emperors_capacitor and resource == "chi" then
            addStack( "the_emperors_capacitor", nil, 1 )
        end
    end )

    spec:RegisterStateTable( "healing_sphere", setmetatable( {}, {
        __index = function( t,  k)
            if k == "count" then
                t[ k ] = GetSpellCount( action.expel_harm.id )
                return t[ k ]
            end
        end 
    } ) )


    local staggered_damage = {}
    local total_staggered = 0

    local function trackBrewmasterDamage( event, _, subtype, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, arg1, _, _, _, arg5, _, _, arg8, _, _, arg11 )
        if destGUID == state.GUID and subtype == "SPELL_ABSORBED" then
            local now = GetTime()

            if arg1 == destGUID and arg5 == 115069 then
                table.insert( staggered_damage, 1, {
                    t = now,
                    d = arg8,
                    s = 6603
                } )
                total_staggered = total_staggered + arg8

            elseif arg8 == 115069 then
                table.insert( staggered_damage, 1, {
                    t = now,
                    d = arg11,
                    s = arg1,
                } )
                total_staggered = total_staggered + arg11

            end
        end
    end

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", trackBrewmasterDamage )

    function stagger_in_last( t )
        local now = GetTime()

        for i = #staggered_damage, 1, -1 do
            if staggered_damage[ i ].t + 10 < now then
                total_staggered = max( 0, total_staggered - staggered_damage[ i ].d )
                table.remove( staggered_damage, i )
            end
        end

        t = min( 10, t )

        if t == 10 then return total_staggered end

        local sum = 0

        for i = 1, #staggered_damage do
            if staggered_damage[ i ].t > now + t then
                break
            end
            sum = sum + staggered_damage[ i ]
        end

        return sum
    end

    local function avg_stagger_ps_in_last( t )
        t = max( 1, min( 10, t ) )
        return stagger_in_last( t ) / t
    end


    local bt = BrewmasterTools
    state.UnitStagger = UnitStagger


    spec:RegisterStateTable( "stagger", setmetatable( {}, {
        __index = function( t, k, v )
            local stagger = debuff.heavy_stagger.up and debuff.heavy_stagger or nil
            stagger = stagger or ( debuff.moderate_stagger.up and debuff.moderate_stagger ) or nil
            stagger = stagger or ( debuff.light_stagger.up and debuff.light_stagger ) or nil

            if not stagger then
                if k == 'up' then return false
                elseif k == 'down' then return true
                else return 0 end
            end

            if k == "heavy" then
                return stagger == debuff.heavy_stagger and stagger.up
                
            elseif k == "moderate" then
                return stagger == debuff.moderate_stagger and stagger.up
                
            elseif k == "light" then
                return stagger == debuff.light_stagger and stagger.up
                
            elseif k == "none" then
                return stagger.down
                
            elseif k == 'tick' then
                if bt then
                    return t.amount / 20
                end
                return t.amount / t.ticks_remain

            elseif k == 'ticks_remain' then
                return floor( stagger.remains / 0.5 )

            elseif k == 'amount' then
                if bt then
                    t.amount = bt.GetNormalStagger()
                else
                    t.amount = UnitStagger( 'player' )
                end
                return t.amount

            elseif k == 'incoming_per_second' then
                return avg_stagger_ps_in_last( 10 )

            elseif k == 'time_to_death' then
                return ceil( health.current / ( stagger.tick * 2 ) )

            elseif k == 'percent_max_hp' then
                return ( 100 * stagger.amount / health.max )

            elseif k == 'percent_remains' then
                return total_staggered > 0 and ( 100 * stagger.amount / stagger_in_last( 10 ) ) or 0

            elseif k == 'total' then
                return total_staggered

            elseif k == 'dump' then
                DevTools_Dump( staggered_damage )

            end

            return nil

        end
    } ) )
    


    -- Abilities
    spec:RegisterAbilities( {
        black_ox_brew = {
            id = 115399,
            cast = 0,
            cooldown = 120,
            gcd = "off",
            
            defensive = true,

            startsCombat = false,
            texture = 629483,

            talent = "black_ox_brew",
            
            handler = function ()
                gain( energy.max, "energy" )
                gainCharges( "ironskin_brew", class.abilities.ironskin_brew.charges )
                gainCharges( "purifying_brew", class.abilities.purifying_brew.charges )                
            end,
        },
        

        blackout_strike = {
            id = 205523,
            cast = 0,
            cooldown = 3,
            hasteCD = true,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1500803,
            
            handler = function ()
                if talent.blackout_combo.enabled then
                    applyBuff( "blackout_combo" )
                end
                addStack( "elusive_brawler", 10, 1 )
            end,
        },
        

        breath_of_fire = {
            id = 115181,
            cast = 0,
            cooldown = function () return buff.blackout_combo.up and 12 or 15 end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 615339,
            
            handler = function ()
                removeBuff( "blackout_combo" )

                if level < 116 and equipped.firestone_walkers then setCooldown( "fortifying_brew", max( 0, cooldown.fortifying_brew.remains - ( min( 6, active_enemies * 2 ) ) ) ) end

                if debuff.keg_smash.up then applyDebuff( "target", "breath_of_fire" ) end
                addStack( "elusive_brawler", 10, active_enemies * ( 1 + set_bonus.tier21_2pc ) )                
            end,
        },
        

        chi_burst = {
            id = 123986,
            cast = 1,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135734,

            talent = "chi_burst",
                        
            handler = function ()                
            end,
        },
        

        chi_torpedo = {
            id = 115008,
            cast = 0,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",
            
            startsCombat = true,
            texture = 607849,

            talent = "chi_torpedo",
            
            handler = function ()
                addStack( "chi_torpedo", nil, 1 )
            end,
        },
        

        chi_wave = {
            id = 115098,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 606541,

            talent = "chi_wave",
            
            handler = function ()                
            end,
        },
        

        crackling_jade_lightning = {
            id = 117952,
            cast = 4,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",
            
            spend = 20,
            spendType = "energy",
            
            startsCombat = true,
            texture = 606542,
            
            handler = function ()
                removeBuff( "the_emperors_capacitor" )
                applyDebuff( "target", "crackling_jade_lightning" )
                -- applies crackling_jade_lightning (117952)
            end,
        },
        

        dampen_harm = {
            id = 122278,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            defensive = true,

            startsCombat = true,
            texture = 620827,

            talent = "dampen_harm",
            
            handler = function ()
                applyBuff( "dampen_harm" )
            end,
        },
        

        detox = {
            id = 218164,
            cast = 0,
            charges = 1,
            cooldown = 8,
            recharge = 8,
            gcd = "spell",
            
            spend = 20,
            spendType = "energy",
            
            startsCombat = false,
            texture = 460692,
            
            handler = function ()
            end,
        },
        

        expel_harm = {
            id = 115072,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 15,
            spendType = "energy",
            
            startsCombat = true,
            texture = 627486,
            
            usable = function () return healing_sphere.count > 0 end,
            handler = function ()
                if level < 116 and set_bonus.tier20_4pc == 1 then stagger.amount = stagger.amount * ( 1 - ( 0.05 * healing_sphere.count ) ) end
                healing_sphere.count = 0
            end,
        },
        

        fortifying_brew = {
            id = 115203,
            cast = 0,
            cooldown = 420,
            gcd = "spell",
            
            defensive = true,

            startsCombat = true,
            texture = 615341,
            
            handler = function ()
                applyBuff( "fortifying_brew" )
                health.max = health.max * 1.2
                health.actual = health.actual * 1.2
            end,
        },
        

        guard = {
            id = 115295,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            defensive = true,

            startsCombat = false,
            texture = 611417,

            talent = "guard",
            
            handler = function ()
                applyBuff( "guard" )
            end,
        },
        

        healing_elixir = {
            id = 122281,
            cast = 0,
            charges = 2,
            cooldown = 30,
            recharge = 30,
            gcd = "off",
            
            startsCombat = true,
            texture = 608939,

            talent = "healing_elixir",
            
            handler = function ()
                gain( 0.15 * health.max, "health" )
            end,
        },
        

        invoke_niuzao = {
            id = 132578,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 608951,
            
            handler = function ()
                summonPet( "niuzao", 45 )
            end,

            copy = "invoke_niuzao_the_black_ox"
        },
        

        ironskin_brew = {
            id = 115308,
            cast = 0,
            charges = 3,
            cooldown = 15,
            recharge = 15,
            hasteCD = true,
            gcd = "off",

            defensive = true,
            
            startsCombat = false,
            texture = 1360979,
            
            handler = function ()
                applyBuff( "ironskin_brew", buff.ironskin_brew.remains + 6 )
                spendCharges( "purifying_brew", 1 )

                if set_bonus.tier20_2pc == 1 then healing_sphere.count = healing_sphere.count + 1 end

                removeBuff( "blackout_combo" )
            end,

            copy = "brews"
        },
        

        keg_smash = {
            id = 121253,
            cast = 0,
            charges = function () return ( level < 116 and equipped.stormstouts_last_gasp ) and 2 or 1 end,
            cooldown = 8,
            recharge = 8,
            gcd = "spell",
            
            spend = 40,
            spendType = "energy",
            
            startsCombat = true,
            texture = 594274,
            
            handler = function ()
                applyDebuff( "target", "keg_smash" )
                
                gainChargeTime( 'ironskin_brew', 4 + ( buff.blackout_combo.up and 2 or 0 ) )
                gainChargeTime( 'purifying_brew', 4 + ( buff.blackout_combo.up and 2 or 0 ) )
                cooldown.fortifying_brew.expires = max( 0, cooldown.fortifying_brew.expires - 4 + ( buff.blackout_combo.up and 2 or 0 ) )
                
                removeBuff( "blackout_combo" )
                addStack( "elusive_brawler", nil, 1 )

                if level < 116 and equipped.salsalabims_lost_tunic then setCooldown( "breath_of_fire", 0 ) end
                end,
        },
        

        leg_sweep = {
            id = 119381,
            cast = 0,
            cooldown = function () return talent.tiger_tail_sweep.enabled and 50 or 60 end,
            gcd = "spell",
            
            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 642414,            
            
            handler = function ()
                applyDebuff( "target", "leg_sweep" )
                interrupt()
            end,
        },
        

        paralysis = {
            id = 115078,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 20,
            spendType = "energy",
            
            startsCombat = false,
            texture = 629534,
            
            handler = function ()
                applyDebuff( "target", "paralysis" )
            end,
        },
        

        provoke = {
            id = 115546,
            cast = 0,
            cooldown = 8,
            gcd = "off",
            
            startsCombat = true,
            texture = 620830,
            
            handler = function ()
                applyDebuff( "target", "provoke" )
            end,
        },
        

        purifying_brew = {
            id = 119582,
            cast = 0,
            charges = 3,
            cooldown = 15,
            recharge = 15,
            hasteCD = true,
            gcd = "off",
            
            startsCombat = false,
            texture = 133701,
            
            handler = function ()
                spendCharges( 'ironskin_brew', 1 )
                
                if set_bonus.tier20_2pc == 1 then healing_sphere.count = healing_sphere.count + 1 end
    
                if buff.blackout_combo.up then
                    addStack( 'elusive_brawler', 10, 1 )
                    removeBuff( 'blackout_combo' )
                end

                local reduction = 0.4
                stagger.amount = stagger.amount * ( 1 - reduction )
                stagger.tick = stagger.tick * ( 1 - reduction )

                if level < 116 and equipped.gai_plins_soothing_sash then gain( stagger.amount * 0.25, 'health' ) end
            end,
        },
        

        resuscitate = {
            id = 115178,
            cast = 10,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.01,
            spendType = "mana",
            
            startsCombat = false,
            texture = 132132,
            
            handler = function ()
            end,
        },
        

        ring_of_peace = {
            id = 116844,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = false,
            texture = 839107,

            talent = "ring_of_peace",
            
            handler = function ()                
            end,
        },
        

        roll = {
            id = 109132,
            cast = 0,
            charges = function () return talent.celerity.enabled and 3 or 2 end,
            cooldown = function () return talent.celerity.enabled and 15 or 20 end,
            recharge = function () return talent.celerity.enabled and 15 or 20 end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 574574,

            notalent = "chi_torpedo",
            
            handler = function ()
            end,
        },
        

        rushing_jade_wind = {
            id = 116847,
            cast = 0,
            cooldown = 6,
            hasteCD = true,
            gcd = "spell",
            
            spend = 0,
            spendType = "energy",
            
            startsCombat = false,
            texture = 606549,
            
            handler = function ()
                applyBuff( "rushing_jade_wind" )
            end,
        },
        

        spear_hand_strike = {
            id = 116705,
            cast = 0,
            cooldown = 15,
            gcd = "off",
            
            startsCombat = true,
            texture = 608940,

            toggle = "interrupts",
            
            handler = function ()
                interrupt()
            end,
        },
        

        summon_black_ox_statue = {
            id = 115315,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            startsCombat = false,
            texture = 627607,

            talent = "summon_black_ox_statue",
            
            handler = function ()
                summonPet( "black_ox_statue" )
            end,
        },
        

        tiger_palm = {
            id = 100780,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 25,
            spendType = "energy",
            
            startsCombat = true,
            texture = 606551,
            
            handler = function ()
                removeBuff( "blackout_combo" )
                if talent.eye_of_the_tiger.enabled then
                    applyDebuff( "target", "eye_of_the_tiger" )
                    applyBuff( "eye_of_the_tiger" )
                end
                gainChargeTime( 'ironskin_brew', 1 )
                gainChargeTime( 'purifying_brew', 1 )
                cooldown.fortifying_brew.expires = max( 0, cooldown.fortifying_brew.expires - 1 )
            end,
        },
        

        tigers_lust = {
            id = 116841,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 651727,

            talent = "tigers_lust",
            
            handler = function ()
                applyBuff( "tigers_lust" )
            end,
        },
        

        transcendence = {
            id = 101643,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            startsCombat = false,
            texture = 627608,
            
            handler = function ()
                applyBuff( "transcendence" )
            end,
        },
        

        transcendence_transfer = {
            id = 119996,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = false,
            texture = 237585,
            
            handler = function ()
            end,
        },
        

        vivify = {
            id = 116670,
            cast = 1.5,
            cooldown = 30,
            gcd = "spell",
            
            spend = 0,
            spendType = "energy",
            
            startsCombat = false,
            texture = 1360980,
            
            handler = function ()
            end,
        },
        

        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1518639,
            
            handler = function ()
            end,
        },
        

        zen_flight = {
            id = 125883,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 660248,
            
            handler = function ()
            end,
        }, ]]
        

        zen_meditation = {
            id = 115176,
            cast = 8,
            channeled = true,
            cooldown = 300,
            gcd = "spell",
            
            defensive = true,

            startsCombat = false,
            texture = 642417,
            
            handler = function ()
                applyBuff( "zen_meditation" )
            end,
        },
        

        --[[ zen_pilgrimage = {
            id = 126892,
            cast = 10,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 775462,
            
            handler = function ()
            end,
        },]]
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageDots = false,
        damageExpiration = 8,
    
        package = "Brewmaster"
    } )


    spec:RegisterPack( "Brewmaster", 20180730.2252, [[dG0ywaqijvLEeqH2eq8jIKAuukofLsRcO0RKKMfIKBrPQ2LGFjjgMq1XeILHiEgIQMgrIRbuTnev4BuQY4quPZbuqRdOOMhrQUhKAFuQCqev0cbspusvvxusvLpkPk0iLuL4KafzLcLzcuGBkPkyNsklvsvupfWufsxvsvXxLufzVQ6VsmyuomvlMIhJQjRWLjTzf9zKmAk50QSAIK8Aiz2qCBe2Tu)w0WjIJlPkPLd1ZjmDLUosTDeP(ornEjvopIY6LuLA(ePSFq)r(OpWWx9Rrs8iKBC7r(4bsibCsa3EpWsMe9bK4CuoL(aTtOpaOyvMWfRIFajoziPp(OpGiPXC9bS2vIamxPc1Tw0MapjQiocAeFVS5yFUvehbVIbjnvmt3(dL0vKGZ5HOIkrpftsKkrjjsPEiBufqXQmHlwfhehb)bm0hYcM638adF1VgjXJqUXTh5JhiHeWJifWFaNETs8daCe1)hyOc(de16eq2jGmhYK4CuoLcz5eYC(EzdziNyfq2mXqw9II6qUWdGCIv8rFGHoDAK9J(1I8rFaNVx2pGtVzX315OEaTDdIoEq)9RrYh9bC(Ez)au3Cl5SSwAjR7b02ni64b93Vg5)OpG2UbrhpOpahFRIp)bUMNextvgoHtPLiGhpoHaYSdYSuhzTceEDqgyHS4bPazGazg65mmt8EtYUMQyWQCyKY9d489Y(bgoHeTlwoM43VMu(OpG2UbrhpOpahFRIp)bUMNextvgoHtPLiGhpoHaYSdYSuhzTceEDqgyHS4bPazGaz2azg65mmCcjAxSCmryKYnKjnPbzg65mmU5KwOfcN64Hrk3qMTpGZ3l7hyM49MKDnvXGv5F)AG)rFaTDdIoEqFG2j0hWXCRJi7Hkkw(I1rbRMe3pGZ3l7hGwOLBvIF)AKJp6d489Y(bKK7L9dOTBq0Xd6VFn79rFaNVx2pGbjZrzsJj7b02ni64b93Vg5(rFaNVx2pGrXcfJ6AQhqB3GOJh0F)AGHF0hW57L9dGCuwROiv0dkcT3hqB3GOJh0F)ArI)rFaTDdIoEqFao(wfF(dSoMs3WEeAzZY4uiZoitkG)aoFVSFGRjDIsl9rxV983VwKiF0hqB3GOJh0hGJVvXN)aI1POuCWsDstgKjnPbz2azI1POuCGihk2xfYabY4zIms5oyWQSiWTCmLkktSZ3lBhbYSdnKXZezKYDWGvzrGWRRWTCmLkGm7dzXdGdzGazg65mC4SfOUUyWQCaRe(1ciZo0qMHEodhoBbQRlgSkhg0yFVSHmWczKeahYS9bC(Ez)asOX3KSRPkgSk)7xlcjF0hqB3GOJh0hGJVvXN)a2azg65mC4SfOUUyWQCyKYnKbcKXTCmLkktSZ3lBhbYSdYIeSh4qgiq218K4AQYWjCkTqEbKzhKzPoYAfi86GmWczXdrGmBHmqGmd9CgmiohvsVfEsyYWiLBideiJNjYiL7GbRYIa3YXuQOmXoFVSDeiZo0qgptKrk3bdwLfbcVUc3YXuQaYSpKfjehYSpKzdKfbYQczg65mC4SfOUUyWQCaRe(1cit6OHmd9CgoC2cuxxmyvomOX(EzdzGfYIhahYSfYabYm0Zz4WzlqDDXGv5awj8RfqM0rdzg65mC4SfOUUyWQCyqJ99YgYalKrYd489Y(boC2cuxxmyv(3VweY)rFaTDdIoEqFao(wfF(dCnpjUMQmCcNslrapECcbKbcKjwNIsXbl1jnzqgiqgptKrk3bdwLfbULJPurzID(Ez7iqM0rdzXd2d8hW57L9dyqCoQswxXGv5F)ArKYh9b02ni64b9b44Bv85paptKrk3bdwLfbULJPubKjDiJeideiZgitBftrgKvfYSbY0wXuKfWkL2qgyHmEMiJuUdOuQIGWfwbSs4xlGmBHmBHmPdzsjoKbcKzONZGbX5Os6TWtctggPCdzGaz8mrgPChqPufbHlSc0sEaNVx2pGbX5OkzDfdwL)9Rfb8p6dOTBq0Xd6dWX3Q4ZFaTvmfzqM0HmYh5bC(Ez)aoM7Tw2eJ1E)9RfHC8rFaTDdIoEqFao(wfF(diKOiiL1Xu6kGm7qdzK)bC(Ez)aOuQIGWfw)(1IyVp6dOTBq0Xd6dWX3Q4ZFad9CgmiohvsVfEsyYaTKhW57L9dShLIlsCeIF)Ari3p6d489Y(bqPufbHlSEaTDdIoEq)9Rfbm8J(aoFVSFadIZrL0BrS4dL(aA7geD8G(7xJK4F0hqB3GOJh0hGJVvXN)ag65myqCoQKEl8KWKHrk3qgiqMnqMHEodgKmhi0Inms5gYKM0GmBGmd9CgmizoqOfBGwcKbcKnYnyWQVwLCwMhwlJCdyDIvHLBquiZwiZ2hW57L9dyWQVwLCwMhw)9RrsKp6dOTBq0Xd6dWX3Q4ZFad9CgW0cRRPksLp0I81JWiL7hW57L9dGPfwxtvKkFOf5Rh)(1iHKp6d489Y(b4wxXqJf7dOTBq0Xd6VFnsi)h9bC(Ez)aCRRi7KwFaTDdIoEq)9RrIu(OpG2UbrhpOpahFRIp)bQVq26iAVbdIZrL0BHNeMmOTBq0bKbcKXZezKYDaLsveeUWkGvc)AbKzhKrXhqgiqMnqM2kMImiRkKzdKPTIPilGvkTHmWcz2az8mrgPChqPufbHlScyLWVwazvHmk(aYSfYSfYSfYSdnKbo4pGZ3l7hypkfxK4ie)(7dibR8KW47h9Rf5J(aA7geD8G(7xJKp6dOTBq0Xd6VFnY)rFaTDdIoEq)9RjLp6dOTBq0Xd6VFnW)OpGZ3l7hqsUx2pG2UbrhpO)(1ihF0hW57L9dWTUIHgl2hqB3GOJh0F)A27J(aoFVSFaU1vKDsRpG2UbrhpO)(7VpaPvS4Y(Rrs8iKBC7r(4bsijc4pGSJ7RPepq9e5SEUgyQw9iygYGSOwkKDess8czZedzs9qNonYk1qgwRxPpSoGmrsOqMtVjHV6aY4wEtPIamgyW1kKfbmdz1NwqlrsIxDazoFVSHmP2P3S476CusDagdm4AfYibmdz1NwqlrsIxDazoFVSHmPM6MBjNL1slzDsDagdgdmrijXRoGmsGmNVx2qgYjwrag7bKGZ5HOpayeYQF1PC6vhqMrNjwHmEsy8fYmk11IaKro5CvYkGSoB7B5yIjncK589YwazzJqwagZ57LTiibR8KW4l6jIlqbJ589YweKGvEsy8Tk6kZmhWyoFVSfbjyLNegFRIUIttrO967LnmgyeYaAxIWkxid73aYm0ZPoGmX6RaYm6mXkKXtcJVqMrPUwazEpGmjy1(sYDVMcYobKnYwdWyoFVSfbjyLNegFRIUIODjcRClI1xbmMZ3lBrqcw5jHX3QORij3lBymNVx2IGeSYtcJVvrxHBDfdnwSWyoFVSfbjyLNegFRIUc36kYoPvymymWiKv)Qt50RoGmL0kMmiBpcfYwlfYC(Myi7eqMtA)qCdIgGXC(Ezlq70Bw8DDokymNVx2IQORqDZTKZYAPLSoymNVx2IQORmCcjAxSCmbPUj6R5jX1uLHt4uAjc4XJtiSZsDK1kq41b24bPaIHEodZeV3KSRPkgSkhgPCdJ589YwufDLzI3Bs21ufdwLj1nrFnpjUMQmCcNslrapECcHDwQJSwbcVoWgpifqSXqpNHHtir7ILJjcJuULM0m0ZzyCZjTqleo1XdJuUTfgZ57LTOk6k0cTCRsqQ2ju0oMBDezpurXYxSoky1K4ggZ57LTOk6ksY9YggZ57LTOk6kgKmhLjnMmymNVx2IQORyuSqXOUMcgZ57LTOk6kihL1kksf9GIq7fgZ57LTOk6kxt6eLw6JUE7zzT0IbX5OkzDK6MOxhtPBypcTSzzCQDsbCymNVx2IQORiHgFtYUMQyWQmPUjAX6uukoyPoPjtAsZgX6uukoqKdf7RccptKrk3bdwLfbULJPurzID(Ez7i2HMNjYiL7GbRYIaHxxHB5ykvy)4bWbXqpNHdNTa11fdwLdyLWVwyhAd9CgoC2cuxxmyvomOX(EzdwscGBlmgyeYiNMKEHmULJPuiJWBNsj0EjfKzidYg60Prwit26quiB9g11uqMnoIStMaYwmTczzdzahr93witwHmKuwXq2TqMHmilcK59aYOLazBczrcGdz3eYKviZXkKTEJ6Akit(wlidrfciBT8gYSCKjKLtidmHZwG6AiZ4cfYg0yFVSHmAjbymNVx2IQORC4SfOUUyWQmPUjABm0Zz4WzlqDDXGv5WiLBq4woMsfLj257LTJyxKG9ahKR5jX1uLHt4uAH8c7SuhzTceEDGnEiITGyONZGbX5Os6TWtctggPCdcptKrk3bdwLfbULJPurzID(Ez7i2HMNjYiL7GbRYIaHxxHB5ykvy)iH423Mivn0Zz4WzlqDDXGv5awj8RfshTHEodhoBbQRlgSkhg0yFVSbB8a42cIHEodhoBbQRlgSkhWkHFTq6On0Zz4WzlqDDXGv5WGg77LnyjbgZ57LTOk6kgeNJQK1vmyvMu3e918K4AQYWjCkTeb84XjeGiwNIsXbl1jnzGWZezKYDWGvzrGB5ykvuMyNVx2oI0rhpypWHXC(EzlQIUIbX5OkzDfdwLj1nrZZezKYDWGvzrGB5ykviDsaXgTvmfzvTrBftrwaRuAdwEMiJuUdOuQIGWfwbSs4xlS1wPlL4GyONZGbX5Os6TWtctggPCdcptKrk3bukvrq4cRaTeymNVx2IQOR4yU3Aztmw7Lu3eT2kMImPt(iWyoFVSfvrxbLsveeUWIu3eTqIIGuwhtPRWo0KhgZ57LTOk6k7rP4IehHGu3eTHEodgeNJkP3cpjmzGwcmMZ3lBrv0vqPufbHlSGXC(EzlQIUIbX5Os6Tiw8HsHXC(EzlQIUIbR(AvYzzEyLu3eTHEodgeNJkP3cpjmzyKYni2yONZGbjZbcTydJuULM0SXqpNbdsMdeAXgOLaYi3GbR(AvYzzEyTmYnG1jwfwUbrT1wymNVx2IQORGPfwxtvKkFOf5RhK6MOn0ZzatlSUMQiv(qlYxpcJuUHXC(EzlQIUc36kgASyHXC(EzlQIUc36kYoPvymNVx2IQORShLIlsCecsDt0131r0EdgeNJkP3cpjmzqB3GOdq4zIms5oGsPkccxyfWkHFTWok(aeB0wXuKv1gTvmfzbSsPnyTHNjYiL7akLQiiCHvaRe(1IQu8HT2ARDObh8hqir5FnsihK7V)(pa]] )


end