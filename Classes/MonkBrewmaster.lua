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
            readyTime = function () return max( ( 2 - charges_fractional ) * recharge, buff.ironskin_brew.remains - 3 ) end, -- should reserve 1 charge for purifying.
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
    
        package = "Brewmaster"
    } )


    spec:RegisterPack( "Brewmaster", 20180826.1821, [[dS04CaqiuO4rKKYMGqFIkvzuqWPGiRcf0RKqZsr4wKuLDjPFjrnmiPJbrTmG4zuPmnssUgqQTrsLVrLQACajohkeRdfQmpiH7HI2hKOdcKeluI8qGKKlIcv9rsQkgjkKQtIcLwjvYlrHKMjjvv3eiPyNks)eiPAOOqILssvPNcyQsWvrHu(kqsP9QQ)kyWqDyklwOhJQjRWLj2mI(mcJMeNwLvtLkVgsnBQ62uXUb9BLgoqDCGKulhPNtQPl66O02ve9Df14jjopjL1tsQMpkW(L6h5VWdmSu(PGGkYGcQGciQRImOacYi)aPAGLhaSXrBeYdanh5bkrLzhtNc9baBQ5xB8fEa9Ys5YdOKjynJRCzIlvyJv(6uwFoSElVfYPgzwwFo8Yr)glhjn1BitwgmDjpVOlx4ekiixUaiiha1Sq0Hsuz2X0PqR6ZH)ar2ZNmw4hFGHLYpfeurguqfuarDvKbfKvLQa5bm2uzPpaW5aQ6bgIM)afuoDJpDJTgd24OncPXlzJnEElSX(tN6gtU0gZOlOp)vFa)Pt9x4bgcPX6ZVWpf5VWdy88w4dyS5gSmno6hqGw0lJV0N)uq(cpGXZBHpGgSy0GIbhbDsp0Ydiql6LXx6ZFQBFHhqGw0lJV0dWPxk0ZEafX8PsJrrJveZNkvhtLgZWgJAvDG(bmEEl8bioYmSKHurcRkF(tv1x4beOf9Y4l9aC6Lc9ShqrmFQubZZgJIg7(GUXi24dYxNdsegMJrib30ngLnwrmFQuDmvAmdBmcnMGUSGBmIng1QQAmdyqJrTcsJrQXi24iljzLCP5rQ2bjcrQmxh7m8bmEEl8bgMdybgumQZN)uq)fEabArVm(spaNEPqp7bueZNkvW8SXOOXGg1gJyJpiFDoiryyogHeCt3yu2yfX8Ps1XuPXmSXi0yc6YcUXi2yuRQQXmGbng1kingPgJyJrOXrwsY6WCalWGIrDQJDg2ygWGghzjjRJJKKvlbhJ441XodBmspGXZBHpa5sZJuTdseIuz(ZFQ6(cpGaTOxgFPhaAoYd4z1jDz1bI1peyaSN1XiKhW45TWhGvlHlfNp)PU)x4bmEEl8baV5TWhqGw0lJV0N)uq5l8agpVf(ar)UJajlvThqGw0lJV0N)ug5l8agpVf(arHQfk6ds8ac0IEz8L(8NImQFHhW45TWhWFekPo4o2bHJaZhqGw0lJV0N)uKr(l8agpVf(aKhvI(DhpGaTOxgFPp)PidYx4bmEEl8bmix0j18bU59pGaTOxgFPp)Pi72x4beOf9Y4l9aC6Lc9ShinkHK18CKqUHXjngLngeq)agpVf(ahCYfTeGhRQB7N)uKv1x4beOf9Y4l9aC6Lc9ShqNgbHqRG5zJrzJrOXQRXmSXi0y3AS61yeAmFx)yNH1ivM1vUIrjeDGKA88wO5BmsngPgJuJrSXi0yDAeecT6nDgYJJommhJqci3yu2yeAmcng1kQG04Ing1kQOICJzyJrOXU1y1RX8D9JDgwJuzwx5kgLq0bsQXZBHMVXi1yKAmdBSonccHw9Mod5XrhgMJrib3qTXi1yKEaJN3cFaWS0JuTdseIuz(ZFkYG(l8ac0IEz8LEao9sHE2dezjjRrVXrVSzGVoXTo2zyJrSXhKVohKimmhJqciZimcJ4OBmkBmcnwrmFQuDmvAmdBmQvKBCXgRtJGqOvVPZqEC0HH5yesqvngPgJyJJSKKvXZQVjLqKAZEHw1PXr3yu0yqAmInMX04iljz9OluJ(GHivMRSGFaJN3cFGJUqn6dgIuz(ZFkYQ7l8ac0IEz8LEao9sHE2dW31p2zynsLzDLRyucrhiPgpVfA(gJYgJCJrSXi0408cmRrVXrhwvcrQmxfOf9YOXi2y(U(XodRrVXrhwvcrQmxPIJDqDJrrJDRXi9agpVf(ahDHA0hmePY8N)uKD)VWdy88w4dC0fQrFWqKkZpGaTOxgFPp)PidkFHhqGw0lJV0dWPxk0ZEaDAeecT6SdHAP8agpVf(aeSgD85pfzg5l8ac0IEz8LEao9sHE2dOiMpvQG5zJrrJbb0pGXZBHpGOcyXhumQZN)uqq9l8ac0IEz8LEao9sHE2dOiMpvQG5zJrrJbb0pGXZBHpGIy(dsee)PYr)8NccYFHhqGw0lJV0dWPxk0ZEa(U(XodRrQmRRCfJsi6aj145TqZ3yu0yuRG(bmEEl8bIEJJoSQeIuz(ZFkiG8fEabArVm(spaNEPqp7bqOXcuOeQ14IngHglqHsOwLkecSXmSX8D9JDgwrlebTJPvQuXXoOUXi1yKAmkASQqTXi24iljzn6no6Lnd81jU1XodBmInMVRFSZWkAHiODmTsLf8dy88w4de9ghDyvjePY8N)uqC7l8ac0IEz8LEao9sHE2dOblEFinkHK6gJsMngKhW45TWhaTqe0oMw5ZFkiQ6l8ac0IEz8LEao9sHE2dKMxGzLYQvoirWD2qcZhCufOf9YOXi24iljzn6no6Lnd81jUvwWngXghzjjRuwTYbjcUZgsy(GJkl4hW45TWhipcHgaBENp)PGa6VWdiql6LXx6b40lf6zpacnonVaZ6bNCrlb4XQ62gsfje9ghDyvPkql6LrJzadACAEbMvnyHFMpme)nPqvRkql6LrJrQXi24iljzn6no6Lnd81jUvwWpGXZBHpqEecna28oF(tbrDFHhW45TWhi6no6Lnd6KEOLhqGw0lJV0N)uqC)VWdy88w4dGwicAhtR8ac0IEz8L(8NccO8fEabArVm(spaNEPqp7bISKKvkRw5Geb3zdjmFWrDSZWhW45TWhGYQvoirWD2qcZhC85pfeg5l8ac0IEz8LEao9sHE2dezjjRrVXrVSzGVoXTo2zyJrSXi04iljzn63D4z1zDSZWgZag0yeACKLKSg97o8S6SYcUXi24XM1ivSujSKbYJkHXMvQqsfTIf9sJrQXi9agpVf(arQyPsyjdKhv(8N6gQFHhW45TWhGRCHilvNpGaTOxgFPp)PUH8x4bmEEl8b4kxy2MuEabArVm(sF(tDdKVWdiql6LXx6b40lf6zpaJPXP5fywJEJJEzZaFDIBvGw0lJgJyJ576h7mSIwicAhtRuPIJDqDJrzJj4JgJyJrOXcuOeQ14IngHglqHsOwLkecSXmSXi0y(U(XodROfIG2X0kvQ4yhu34InMGpAmsngPgJuJrjZgRoq)agpVf(a5ri0ayZ785p1n3(cpGaTOxgFPhGtVuON9acuOeQ1yu0y3q(bmEEl8bmk3GsixkvG5N)u3u1x4bmEEl8bOSALdseCNnKW8bhpGaTOxgFPp)8batf(6eT8l8tr(l8ac0IEz8L(8NcYx4beOf9Y4l95p1TVWdiql6LXx6ZFQQ(cpGaTOxgFPp)PG(l8agpVf(aG38w4diql6LXx6ZFQ6(cpGXZBHpax5crwQoFabArVm(sF(tD)VWdy88w4dWvUWSnP8ac0IEz8L(8ZpFGjfQ(w4pfeurguqfuarDvKbrvQ7bMnk8Ge6haulOI67ug7u1hgxJBCbfPXNd4LMnMCPn29gcPX6t3RXubun7rLrJ1RJ0yJnxhlLrJ5kgKq012L6)GsJrMX1ygnOMfm4LMYOXgpVf2y3ZyZnyzAC0UxTDP(pO0y3yCnMrdQzbdEPPmASXZBHn29ioYmSKHurcRkUxTD1UySoGxAkJgdsJnEElSX(tN6A76b0Gf(pfe1bkpay6sEE5buTgZ4vr4SPmACuixQ0y(6eTSXrH4G6AJbv4CbCQBmCHQNIrDiz9n245TqDJxOxTA7Y45TqDfmv4Rt0sMKEtJUDz88wOUcMk81jAzrMLj3D0UmEEluxbtf(6eTSiZYglHJatlVf2UuTgdanWALnBm1UrJJSKKYOX60sDJJc5sLgZxNOLnokehu3ydoAmyQOEG3mpirJpDJhluQTlJN3c1vWuHVorllYSSgAG1kBg0PL62LXZBH6kyQWxNOLfzwg8M3cBxgpVfQRGPcFDIwwKzzUYfISuD2UmEEluxbtf(6eTSiZYCLlmBtkTR2LQ1ygVkcNnLrJLjfQAnophPXPI0yJNlTXNUX2K25TOxQTlJN3c1mn2CdwMghD7Y45TqDrML1GfJgum4iOt6HwAxgpVfQlYSmXrMHLmKksyvzIJKPIy(ubfkI5tLQJPcdrTQoq3UmEEluxKz5H5awGbfJ6mXrYurmFQubZtu4(GgXdYxNdsegMJrib30OurmFQuDmvyice0LfmIOwvfdyaQvqqcXiljzLCP5rQ2bjcrQmxh7mSDz88wOUiZYKlnps1oirisL5josMkI5tLkyEIcqJkIhKVohKimmhJqcUPrPIy(uP6yQWqeiOllyerTQkgWauRGGeIiezjjRdZbSadkg1Po2zidyqKLKSoosswTeCmIJxh7meP2LXZBH6ImlZQLWLIZeqZry6z1jDz1bI1peyaSN1XiK2LXZBH6ImldEZBHTlJN3c1fzwo63DeizPQ1UmEEluxKz5Oq1cf9bjAxgpVfQlYSS)iusDWDSdchbMTlJN3c1fzwM8Os0V7ODz88wOUiZYgKl6KA(a38(2LXZBH6ImlFWjx0saESQUTHurcrVXrhwvM4izMgLqYAEosi3W4euccOBxTlvRXmkS0JuTds04OOytEllTXNUXrtlJgVWgdxQJ5pv3YBHngHJX34urAS3sPXIkGPIwFlSXj9iieQUXhzJ1Prqi0gRpvxA8b5uX0YOX7KcTXPI0yVPZg7gQnopoADJxAJrg0nwl8fo0ivBxgpVfQlYSmyw6rQ2bjcrQmpXrYuNgbHqRG5jkrqDmeb3upe476h7mSgPYSUYvmkHOdKuJN3cnpsiHeIiOtJGqOvVPZqEC0HH5yesazuIacOwrfKIOwrfvKzicUPE8D9JDgwJuzwx5kgLq0bsQXZBHMhjKyOonccHw9Mod5XrhgMJrib3qfjKAxTlvRXmw6c1OpyJlrL5gdMEl9s1A8SIaLjfAJVSX5UOBS(iGh5Xny24H5yesJn4OXhDHA0hSXrQm34iljzJpDJDoT(GengbB4owD24urASIy(uP6yQ0y(kKKh)ey2yJZx64Geno3gFWuG6lvRXlzJhMJrinon0cePjASbhno3gpyDa3yrfUO1nMRyucr34OqUuPXL2s12LXZBH6ImlF0fQrFWqKkZtCKmJSKK1O34Ox2mWxN4wh7meXdYxNdsegMJribKzegHrC0OebfX8Ps1XuHHOwrUOonccHw9Mod5XrhgMJribvHeIrwsYQ4z13KsisTzVqR604OrbiiYyISKK1JUqn6dgIuzUYcUDz88wOUiZYhDHA0hmePY8ehjt(U(XodRrQmRRCfJsi6aj145TqZJsKreH08cmRrVXrhwvcrQmxfOf9Yar(U(XodRrVXrhwvcrQmxPIJDqnkCdP2LXZBH6ImlF0fQrFWqKkZTR2LQ1y1hwJoAC5gZOlM)GenMX7pvoA7Y45TqDrMLjyn6yIJKPonccHwD2HqTuAxgpVfQlYSSOcyXhumQZehjtfX8PsfmprbiGUDz88wOUiZYkI5pirq8NkhDIJKPIy(uPcMNOaeq3UAxQwJl5no6gdQRsJlrL5gF6gZzPubME1AmRwgno3glxQi0gtfWEbEALghPYSUXrtlJgVWg7fTUXPIbBSI5jBS14ivMBmxXOesJTjTZBrVmrJxAJ97CJfOqjuRX52ybArV0ygvHOXaoMwPDz88wOUiZYrVXrhwvcrQmpXrYKVRFSZWAKkZ6kxXOeIoqsnEEl08Oa1kOBxgpVfQlYSC0BC0HvLqKkZtCKmrqGcLqTIiiqHsOwLkecKH8D9JDgwrlebTJPvQuXXoOgjKqHQqfXiljzn6no6Lnd81jU1XodrKVRFSZWkAHiODmTsLfC7QDPAnguNKuG6BsXR2enovKgdQWOO(Bmy6T0lpvx0nMrfOXlSXCVytkt04slqJfVwMOXZxQ0ybkuc1ASgSahcv3ydoAmFOBSEPPmACu87C7Y45TqDrMLrlebTJPvM4izQblEFinkHKAuYeK2LXZBH6ImlNhHqdGnVZehjZ08cmRuwTYbjcUZgsy(GJQaTOxgigzjjRrVXrVSzGVoXTYcgXiljzLYQvoirWD2qcZhCuzb3UmEEluxKz58ieAaS5DM4izIqAEbM1do5IwcWJv1TnKksi6no6WQsvGw0ldgWG08cmRAWc)mFyi(BsHQwvGw0ldKqmYsswJEJJEzZaFDIBLfC7Y45TqDrMLJEJJEzZGoPhAPDz88wOUiZYOfIG2X0kTlJN3c1fzwMYQvoirWD2qcZhCmXrYmYsswPSALdseCNnKW8bh1XodBxgpVfQlYSCKkwQewYa5rLjosMrwsYA0BC0lBg4RtCRJDgIicrwsYA0V7WZQZ6yNHmGbiezjjRr)UdpRoRSGrCSznsflvclzG8OsySzLkKurRyrVGesTlJN3c1fzwMRCHilvNTlJN3c1fzwMRCHzBsPDz88wOUiZY5ri0ayZ7mXrYKXKMxGzn6no6Lnd81jUvbArVmqKVRFSZWkAHiODmTsLko2b1OKGpqebbkuc1kIGafkHAvQqiqgIaFx)yNHv0crq7yALkvCSdQlsWhiHesOKP6aD7Y45TqDrMLnk3GsixkvG5ehjtbkuc1qHBi3UmEEluxKzzkRw5Geb3zdjmFWXNF(pa]] )


end