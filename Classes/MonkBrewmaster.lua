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
            duration = 7,
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

        ironskin_brew_icd = {
            duration = 1,
            generate = function ()
                local icd = buff.ironskin_brew_icd

                local applied = class.abilities.ironskin_brew.lastCast

                if query_time - applied < 1 then
                    icd.count = 1
                    icd.applied = applied
                    icd.expires = applied + 1
                    icd.caster = "player"
                    return
                end

                icd.count = 0
                icd.applied = 0
                icd.expires = 0
                icd.caster = "nobody"
            end
        }
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

    local stagger_ticks = {}

    local function trackBrewmasterDamage( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, arg1, arg2, arg3, arg4, arg5, arg6, _, arg8, _, _, arg11 )
        if destGUID == state.GUID then
            if subtype == "SPELL_ABSORBED" then
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
            elseif subtype == "SPELL_PERIODIC_DAMAGE" and sourceGUID == state.GUID and arg1 == 124255 then
                table.insert( stagger_ticks, 1, arg4 )
                stagger_ticks[ 31 ] = nil

            end
        end
    end

    -- Use register event so we can access local data.
    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function ()
        trackBrewmasterDamage( "COMBAT_LOG_EVENT_UNFILTERED", CombatLogGetCurrentEventInfo() )
    end )

    local function resetStaggerTicks()
        table.wipe( stagger_ticks )
    end

    spec:RegisterEvent( "PLAYER_REGEN_ENABLED", resetStaggerTicks )


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

            -- SimC expressions.
            if k == "light" then
                return t.percent < 3.5
            
            elseif k == "moderate" then
                return t.percent >= 3.5 and t.percent <= 6.5
                
            elseif k == "heavy" then
                return t.percent > 6.5
                
            elseif k == "none" then
                return stagger.down
                
            elseif k == 'percent' or k == 'pct' then
                -- stagger tick dmg / current hp
                return ceil( 100 * t.tick / health.current )

            elseif k == 'tick' or k == 'amount' then
                if bt then
                    return t.amount_remains / 20
                end
                return t.amount_remains / t.ticks_remain

            elseif k == 'ticks_remain' then
                return floor( stagger.remains / 0.5 )

            elseif k == 'amount_remains' then
                if bt then
                    t.amount_remains = bt.GetNormalStagger()
                else
                    t.amount_remains = UnitStagger( 'player' )
                end
                return t.amount_remains

            elseif k:sub( 1, 17 ) == "last_tick_damage_" then
                local ticks = k:match( "(%d+)$" )
                ticks = tonumber( ticks )

                if not ticks or ticks == 0 then return 0 end

                -- This isn't actually looking backwards, but we'll worry about it later.
                local total = 0

                for i = 1, ticks do
                    total = total + ( stagger_ticks[ i ] or 0 )
                end

                return total

            
                -- Hekili-specific expressions.
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
            
            toggle = "defensives",
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
            
            toggle = "defensives",
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

            toggle = "defensives",
            defensive = true,
            
            spend = 20,
            spendType = "energy",
            
            startsCombat = false,
            texture = 460692,
            
            usable = function () return debuff.dispellable_poison.up or debuff.dispellable_disease.up end,
            handler = function ()
                removeDebuff( "player", "dispellable_poison" )
                removeDebuff( "player", "dispellable_disease" )
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
                gain( healing_sphere.count * stat.attack_power * 2, "health" )
                healing_sphere.count = 0
            end,
        },
        

        fortifying_brew = {
            id = 115203,
            cast = 0,
            cooldown = 420,
            gcd = "spell",
            
            toggle = "defensives",
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
            
            toggle = "defensives",
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

            toggle = "defensives",
            defensive = true,
            
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

            toggle = "defensives",
            defensive = true,
            
            startsCombat = false,
            texture = 1360979,

            nobuff = "ironskin_brew_icd", -- implements 1s self-cooldown
            readyTime = function () return max( ( 2 - charges_fractional ) * recharge, buff.ironskin_brew.remains - gcd.max ) end, -- should reserve 1 charge for purifying.
            usable = function () return ( tanking or incoming_damage_3s > 0 ) end,

            handler = function ()
                applyBuff( "ironskin_brew_icd" )
                applyBuff( "ironskin_brew", min( 21, buff.ironskin_brew.remains + 7 ) )
                spendCharges( "purifying_brew", 1 )

                if set_bonus.tier20_2pc == 1 then healing_sphere.count = healing_sphere.count + 1 end

                removeBuff( "blackout_combo" )
            end,

            copy = "brews"
        },
        

        keg_smash = {
            id = 121253,
            cast = 0,
            charges = function () return ( level < 116 and equipped.stormstouts_last_gasp ) and 2 or nil end,
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

            toggle = "defensives",
            defensive = true,
            
            startsCombat = false,
            texture = 133701,

            -- usable = function () return stagger.pct > 0 end,
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
            
            usable = function () return target.casting end,
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
            
            toggle = "defensives",
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
    
        potion = "battle_potion_of_agility",
        
        package = "Brewmaster"
    } )


    spec:RegisterPack( "Brewmaster", 20180930.1640, [[dS0)Eaqibe9ieL2ee1NeuLrbjDkiXQqj5vkWSeOULGIDjv)IOAykKJbPAzOepdcnnusDniL2MaPVjOQghIcNtGyDqkAEqe3JOSpishuqfwOG8qifYfHuWhfqOrkGuNuajReL6LciyMcQOBIOi7ec(jIIYqfuPLkGQNQutvbDvefvFfsHYEb9xPmyOomvlwOhtyYk6YK2mk(mcJgvDAvTAbLEnImBkDBuz3a)wLHRehhsHQLJ0ZPy6IUor2UcLVRKgpIQZlaRxaL5Rq1(LmeD4q4E6PcrGLrOtgJccIJ6OhuedcAH7mGffUxCbjNqHBGZPWDiQUY5MuPW9IhG98jCiCBojQqHB(mxmOPC5eFYlf7IJtU55KSE(hqqDMuU55eYJ2lkpY4HzQJjFHEmVvnYh(kLf0LpKf0BKPdqQfIQRCUjvA38Cc4ok92mqbGr4E6PcrGLrOtgJccIJ6OhuedcRHBxk5pkCVFo0i4M)NtfaJW9unc4MSfoevx5CtQ0ctMoaPInzlmFMlg0uUCIp5LIDXXj38Cswp)diOotk38Cc5r7fLhz8Wm1XKVqpM3Qg5HlvdC)Ng5HBG3ithGulevx5CtQ0U55efBYw4TUKkxuPfgXrbxywgHozu4WuywJMioQyxSjBHrJ4DaHAqZInzlCykCGRwN8cJgiFrTfoq7uUc7fo(zhUTVjnWHW9uzCjBchcraD4q42f5Fa42LYR5z6csWTc8OvNWqWeIalWHWTlY)aWTzrDAJ3bZMjPpjfUvGhT6egcMqeqeoeUvGhT6egcUf0pv67WnV62KVWiPW8QBt(oNtEHzvHh1dkAHBxK)bGBINjBhtl512romHiWA4q4wbE0Qtyi4wq)uPVd38QBt((IilmskC4J2cJCHFG44EarB6CoH2q0uyKwyE1TjFNZjVWSQWOwyc6jTuyKl8OoRl84Jx4rDwkmkfg5chLyy6mhnFMaEarls11(8wbWTlY)aW905wuqJ3PCWeIaAHdHBf4rRoHHGBb9tL(oCZRUn57lISWiPWODuHrUWpqCCpGOnDoNqBiAkmslmV62KVZ5Kxywvyulmb9KwkmYfEuN1fE8Xl8OolfgLcJCHrTWrjgM(05wuqJ3PC95Tck84Jx4OedtF(mmsgTX5eVOpVvqHrbUDr(haUzoA(mb8aIwKQRWeIqqHdHBf4rRoHHGBGZPWTvYK0tY0io7ubTfReNtOWTlY)aWTvYK0tY0io7ubTfReNtOWeIq4dhc3Ui)da3sgT9PYzGBf4rRoHHGjebYaoeUDr(haUxU8paCRapA1jmemHiee4q42f5Fa4oAVB2yKOba3kWJwDcdbticOpcoeUDr(haUJk1OuspGaUvGhT6egcMqeqhD4q42f5Fa42(e8PPfwPjbNcs4wbE0QtyiycraDwGdHBxK)bGBMNQr7Dt4wbE0QtyiycraDeHdHBxK)bGBhiutsDBt4wlCRapA1jmemHiGoRHdHBf4rRoHHGBb9tL(oCNoLqZE(CAlV281cJ0cZcAHBxK)bG7hm2rsBGxkW8dMqeqhTWHWTc8OvNWqWTG(PsFhUnPtqO0(IilmslmQfoOfMvfg1cJyHdtHrTWI7SZBf0JuD10f8oLqnngQlY)aUTWOuyukmkfg5cJAHnPtqO0U1nzlFbP205CcTHEHrAHrTWOw4r9rSu4bfEuF0i0lmRkmQfgXchMclUZoVvqps1vtxW7uc10yOUi)d42cJsHrPWSQWM0jiuA36MSLVGuB6CoH2qCuHrPWOa3Ui)da3ls0NjGhq0IuDfMqeqpOWHWTc8OvNWqWTG(PsFhUJsmm9O1fKoPSjoU41N3kOWix4hioUhq0MoNtOn0dsqccNPWiTWOwyE1TjFNZjVWSQWJ6Ox4bf2KobHs7w3KT8fKAtNZj0gRlmkfg5chLyy6QvY8JPTi1xTkTBsxqQWiPWSuyKlCGSWrjgM(tpGH0dArQU2LwGBxK)bG7NEadPh0IuDfMqeqp8HdHBf4rRoHHGBb9tL(oClUZoVvqps1vtxW7uc10yOUi)d42cJ0cJEHrUWOw40Tki7rRli1oYBrQU2vGhT6SWixyXD25Tc6rRli1oYBrQU2PkN)atHrsHrSWOa3Ui)da3p9agspOfP6kmHiGozahc3Ui)da3p9agspOfP6kCRapA1jmemHiGEqGdHBf4rRoHHGBb9tL(oCBsNGqPDUBQupv42f5Fa4MqYPtycrGLrWHWTc8OvNWqWTG(PsFhU5v3M89frwyKuyerSWJpEHrTW8QBFarZSWRuTlojqwyKkRWiwyKlmV62KVViYcJKcJ2rfgf42f5Fa4wjFrTnENYbticSGoCiCRapA1jmeClOFQ03HBE1TjFFrKfgjfgreHBxK)bGBE1TpGOP2N8NcticSWcCiCRapA1jmeClOFQ03HBXD25Tc6rQUA6cENsOMgd1f5Fa3wyKu4rD0c3Ui)da3rRli1oYBrQUcticSGiCiCRapA1jmeClOFQ03HBulScukrafEqHrTWkqPeb0PkHckmRkS4o78wbDskrZW5g(ov58hykmkfgLcJKcZ6rfg5chLyy6rRliDsztCCXRpVvqHrUWI7SZBf0jPendNB47slWTlY)aWD06csTJ8wKQRWeIalSgoeUvGhT6egcUf0pv67WTzrT2w6ucnnfgPYkmlWTlY)aWnjLOz4CdpmHiWcAHdHBf4rRoHHGBb9tL(oCNUvbzNkz4FarlS(uBRpy2vGhT6SWix4OedtpADbPtkBIJlEDPLcJCHJsmmDQKH)beTW6tTT(GzxAbUDr(haUZNqPTf3YbticSeu4q4wbE0Qtyi4wq)uPVd3Ow40Tki7pySJK2aVuG5xl51w06csTJ8Uc8OvNfE8XlC6wfKDZIkE32MQ9htPb0vGhT6SWOuyKlCuIHPhTUG0jLnXXfVU0cC7I8paCNpHsBlULdMqeyj8HdHBxK)bG7O1fKoPSzs6tsHBf4rRoHHGjebwid4q42f5Fa4MKs0mCUHhUvGhT6egcMqeyjiWHWTc8OvNWqWTG(PsFhUJsmmDQKH)beTW6tTT(GzFERa42f5Fa4Mkz4FarlS(uBRpycticiocoeUvGhT6egcUf0pv67WDuIHPhTUG0jLnXXfV(8wbfg5cJAHJsmm9O9UPvYK95Tck84JxyulCuIHPhT3nTsMSlTuyKl88YEKQEY3oMgZt128YovzOQH3JwTWOuyuGBxK)bG7iv9KVDmnMNQWeIaIOdhc3Ui)da3c(VfLOMeUvGhT6egcMqeqKf4q42f5Fa4wW)TvFmfUvGhT6egcMqeqer4q4wbE0Qtyi4wq)uPVd3bYcNUvbzpADbPtkBIJlEDf4rRolmYfwCNDERGojLOz4CdFNQC(dmfgPfMqmlmYfg1cRaLseqHhuyulScukraDQsOGcZQcJAHf3zN3kOtsjAgo3W3PkN)atHhuycXSWOuyukmkfgPYkCqrlC7I8paCNpHsBlULdMqeqK1WHWTc8OvNWqWTG(PsFhUvGsjcOWiPWiIoC7I8paC7uHd0wEuQcsycrar0chc3Ui)da3ujd)diAH1NAB9bt4wbE0Qtyiyct4EHQIJl6jCieb0HdHBf4rRoHHGjebwGdHBf4rRoHHGjebeHdHBf4rRoHHGjebwdhc3kWJwDcdbticOfoeUDr(haUxU8paCRapA1jmemHieu4q42f5Fa4wW)TOe1KWTc8OvNWqWeIq4dhc3Ui)da3c(VT6JPWTc8OvNWqWeMWeUhtPM)aqeyze6KXOGGoz0rNfwhu4E1PGhqyGB0yHJahHafcbIOzHl8qETWp3YrZcZC0chEtLXLSz4vyQIgx6P6SWMJtlSlLhNN6SWcEhqOMEXoC(aTWOJMfMmhyKwwoAQZc7I8pqHdpxkVMNPlifE9ID48bAHrenlmzoWiTSC0uNf2f5FGchEept2oMwYRTJ8WRxSl2bkULJM6SWSuyxK)bkS9nPPxSHBZIkGiWsqjd4EHEmVvHBYw4quDLZnPslmz6aKk2KTW8zUyqt5Yj(Kxk2fhNCZZjz98pGG6mPCZZjKhTxuEKXdZuht(c9yERAKhUunW9FAKhUbEJmDasTquDLZnPs7MNtuSjBH36sQCrLwyehfCHzze6KrHdtHznAI4OIDXMSfgnI3beQbnl2KTWHPWbUADYlmAG8f1w4aTt5kSx44N9IDXMSfgnqUkKsDw4OYCuTWIJl6zHJkXdm9choecDjnfgCGWW7uogjBHDr(hWu4dydOxSDr(hW0xOQ44IEkJX6gsfBxK)bm9fQkoUONdKjN5UzX2f5FatFHQIJl65azYDjcofKE(hOyt2cVb(IH)Yct9Fw4OedJolSj90u4OYCuTWIJl6zHJkXdmf2bZcVq1WSCz(aIc)McppG2l2Ui)dy6luvCCrphitUb4lg(lBM0ttX2f5FatFHQIJl65azYxU8pqX2f5FatFHQIJl65azYf8FlkrnzX2f5FatFHQIJl65azYf8FB1htl2fBYwy0a5Qqk1zH1XuAafoFoTWjVwyxKhTWVPW(y(B9Ov7fBxK)bmYCP8AEMUGuX2f5FaZazYnlQtB8oy2mj9jPfBxK)bmdKjN4zY2X0sETDKh8ZiJxDBYJeE1TjFNZjNvJ6bfTfBxK)bmdKjF6ClkOX7uUGFgz8QBt((Iirs4JwKFG44EarB6CoH2q0GuE1TjFNZjNvOsqpPfKh1z94JpQZckihLyy6mhnFMaEarls11(8wbfBxK)bmdKjN5O5ZeWdiArQUg8ZiJxDBY3xejsq7iKFG44EarB6CoH2q0GuE1TjFNZjNvOsqpPfKh1z94JpQZckiJAuIHPpDUff04DkxFERGXhpkXW0NpdJKrBCoXl6ZBfGsX2f5FaZazYLmA7tLlyGZPYSsMKEsMgXzNkOTyL4CcTy7I8pGzGm5sgT9PYzk2Ui)dygit(YL)bk2Ui)dygitE0E3SXirdOy7I8pGzGm5rLAukPhquSDr(hWmqMC7tWNMwyLMeCkil2Ui)dygitoZt1O9UzX2f5FaZazYDGqnj1TnHBTfBxK)bmdKj)bJDK0g4Lcm)AjV2IwxqQDKh8ZilDkHM9850wET5RiLf0wSl2KTWHRe9zc4befoQ8(y)jrl8BkC0n6SWhOWGJY52pW88pqHr9rdfo51cB9ulSs(cvnM)afoPpbHsnf(zkSjDccLwyZhyAHFGGQUrNf(gtPfo51cBDtwyehv48fKmf(OfgD0wyJkoW0GsVy7I8pGzGm5ls0NjGhq0IuDn4NrMjDccL2xejsrnOScveddQI7SZBf0JuD10f8oLqnngQlY)aUffuqbzunPtqO0U1nzlFbP205CcTHosrf1r9rSmyuF0i0zfQiggXD25Tc6rQUA6cENsOMgd1f5Fa3IckSYKobHs7w3KT8fKAtNZj0gIJqbLIDXMSfoqrpGH0dkCiQUw4f6F0pdOWR8kqhtPf(ZcN3rQWMNa8mVWbzHNoNtOf2bZc)0dyi9GchP6AHJsmmf(nfM7nMhquyu9zyLmzHtETW8QBt(oNtEHfNYW8IxbzHDH4OZhqu48k8dsfy(mGcFmfE6CoHw40jPaucUWoyw48k8uIBPWk5c1ykSG3PeQPWrL5OAHdDH6fBxK)bmdKj)PhWq6bTivxd(zKfLyy6rRliDsztCCXRpVvaYpqCCpGOnDoNqBOhKGeeodsrLxDBY35CYz1Oo6dmPtqO0U1nzlFbP205CcTXAuqokXW0vRK5htBrQVAvA3KUGesyb5azuIHP)0dyi9GwKQRDPLITlY)aMbYK)0dyi9GwKQRb)mYe3zN3kOhP6QPl4DkHAAmuxK)bClsrhzut3QGShTUGu7iVfP6AxbE0QtKf3zN3kOhTUGu7iVfP6ANQC(dmibruk2Ui)dygit(tpGH0dArQUwSl2KTWbIsoDwy5foqRU9befgnyFYFAX2f5FaZazYjKC6m4NrMjDccL25UPs9ul2Ui)dygitUs(IAB8oLl4NrgV62KVVisKGiIJpoQ8QBFarZSWRuTlojqIuziImV62KVVisKG2rOuSDr(hWmqMCE1TpGOP2N8Ng8ZiJxDBY3xejsqeXIDXMSfoK1fKkmzg5foevxl8BkSqIsvqAdOWsgDw48kS(jVslmvxSk4n8fos1vtHJUrNf(af2QgtHtEhuyE3YuyVWrQUwybVtj0c7J5V1Jwn4cF0cBV1cRaLseqHZRWkWJwTWbckrH3CUHVy7I8pGzGm5rRli1oYBrQUg8ZitCNDERGEKQRMUG3PeQPXqDr(hWTizuhTfBxK)bmdKjpADbP2rEls11GFgzOQaLseWauvGsjcOtvcfWkXD25Tc6KuIMHZn8DQY5pWGckiH1JqokXW0Jwxq6KYM44IxFERaKf3zN3kOtsjAgo3W3Lwk2fBYwyYmggfy(XuBabx4KxlC4iCdNfEH(h9ZpWutHde2f(afwyvFmn4ch62fwTgn4cV(jFHvGsjcOWMffmvQPWoywyX0uyZrtDw4OAV1ITlY)aMbYKtsjAgo3Wh8ZiZSOwBlDkHMgKkJLITlY)aMbYKNpHsBlULl4Nrw6wfKDQKH)beTW6tTT(GzxbE0QtKJsmm9O1fKoPSjoU41LwqokXW0Psg(hq0cRp126dMDPLITlY)aMbYKNpHsBlULl4NrgQPBvq2FWyhjTbEPaZVwYRTO1fKAh5Df4rRohF80Tki7Mfv8UTnv7pMsdORapA1jkihLyy6rRliDsztCCXRlTuSDr(hWmqM8O1fKoPSzs6tsl2Ui)dygitojLOz4CdFX2f5FaZazYPsg(hq0cRp126dMb)mYIsmmDQKH)beTW6tTT(GzFERGITlY)aMbYKhPQN8TJPX8un4NrwuIHPhTUG0jLnXXfV(8wbiJAuIHPhT3nTsMSpVvW4JJAuIHPhT3nTsMSlTG88YEKQEY3oMgZt128YovzOQH3Jwffuk2Ui)dygitUG)BrjQjl2Ui)dygitUG)BR(yAX2f5FaZazYZNqPTf3Yf8ZilqMUvbzpADbPtkBIJlEDf4rRorwCNDERGojLOz4CdFNQC(dmiLqmrgvfOuIagGQcukraDQsOawHQ4o78wbDskrZW5g(ov58hygqiMOGckivwqrBX2f5FaZazYDQWbAlpkvbzWpJmfOuIaqcIOxSDr(hWmqMCQKH)beTW6tTT(GjmHjeca]] )


end