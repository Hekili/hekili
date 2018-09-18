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
    
        potion = "battle_potion_of_agility",
        
        package = "Brewmaster"
    } )


    spec:RegisterPack( "Brewmaster", 20180918.1246, [[dSeuDaqissYJijLnbbFsrkgfe5uqOvHc5vsOzPi5wujXUu4xsWWqbhdIAzGQEgvktdfQRbQ02OsQVrLQACqcoNIuTossL5bj5EOO9bj6GksPfkrEiKqLlsss9rssuJesO4KqczLKuVKKezMuPkUjjjWove)KKeAOuPkTuiHspfKPkrDvssvFLKe0Ev5VImyOomLflQhJQjlPltSze9zegnvCAvTAQu51qQztv3Me7g43knCq54qcvTCKEoPMUW1rPTdQ47kQXtsCEQeRNkjnFiP2VuFiFLpOQfYnbEgqgfyy6iJcdKHNXUMXm(GcxGjhemJJ2iKdcykYbvIkZkMoe6bbZCXVw9kFq6LLYLdYjcyAvxHceF4WMh8vPG(vy9w8lGtnYOG(v4fY(nxitAUsvGtby0L89IUq5xOWJCHYWJCsvWcqNkrLzfthcDOFf(bLzFFGIax(GQwi3e4zazuGHPJmkmqgEg7Agd)bzSHZspiOxbf3bvfn)GM2AvQnw1RLgJIcrr34yB80YJFbn29AC0n(bn2aXZFyw8lOXlzJn2yvSqQnoOpaTenwZcd2sJXb5FDOVYhuvinwFCLVjiFLpiJh)coiJn2KfHXrFqcWYEPELU4Ma)v(GmE8l4G0WeJMCmqnPd6JwoibyzVuVsxCtC7kFqcWYEPELoio9dH(2b5iMpCAmQASJy(WzOyQ0yg1yggUgUhKXJFbheXtgPLmfosAv5IBcJVYhKaSSxQxPdIt)qOVDqoI5dNbmE0yu1y3hUngHg)a(Q8aIu1umcj5MUXOSXoI5dNHIPsJzuJrQXe0LfwJrOXmmyCJrnQBmdd4BmIngHgNzjjhKlnEsxEarktL5rDNbhKXJFbhu1uGjGKJrvU4Ma3R8bjal7L6v6G40pe6BhKJy(WzaJhngvngUm0yeA8d4RYdisvtXiKKB6gJYg7iMpCgkMknMrngPgtqxwyngHgZWGXng1OUXmmGVXi2yeAmsnoZssoQMcmbKCmQYOUZGgJAu34mlj5O(KKSAjPyepFu3zqJr8GmE8l4GixA8KU8aIuMkZxCtC9v(GeGL9s9kDqatroipRoOlRorS(QasW8SkgHCqgp(fCqEwDqxwDIy9vbKG5zvmc5IBI7FLpiJh)coiwTK(qu0hKaSSxQxPlUjOWv(GmE8l4GGTXVGdsaw2l1R0f3KPFLpiJh)coOSF3AIKL6Ybjal7L6v6IBcYmCLpiJh)coOSq1cf9dioibyzVuVsxCtqg5R8bz84xWb5FcNqNChBLqraXbjal7L6v6IBcYWFLpiJh)coiYNkz)U1dsaw2l1R0f3eKD7kFqgp(fCqgGl6GA(e38(dsaw2l1R0f3eKz8v(GeGL9s9kDqC6hc9TdkmkHeJ4vKuSP6lngLngE4Eqgp(fCqpaolAjbEwx12lUjid3R8bjal7L6v6G40pe6BhKomccHoGXJgJYgJuJDDJzuJrQXU1yxPXi1y(U(6odgzQmRhChJsi6ej14XVaZ3yeBmIngXgJqJrQX6Wiie6WB6ifphDQAkgHKqUXOSXi1yKAmddgGVXfBmddgya5gZOgJuJDRXUsJ576R7myKPYSEWDmkHOtKuJh)cmFJrSXi2yg1yDyeecD4nDKINJovnfJqsUXqJrSXiEqgp(fCqWyPpPlpGiLPY8f3eKD9v(GeGL9s9kDqC6hc9TdkZssoYEJJEzJeFvY7OUZGgJqJFaFvEarQAkgHKqE6tF6k6gJYgJuJDeZhodftLgZOgZWa5gxSX6Wiie6WB6ifphDQAkgHKyCJrSXi04mlj5q8S6hosktTzVqh6W4OBmQAm8ngHgRQACMLKC80fOr)GuMkZdwyhKXJFbh0txGg9dszQmFXnbz3)kFqcWYEPELoio9dH(2bX31x3zWitLz9G7yucrNiPgp(fy(gJYgJCJrOXi14W8cigzVXrNwvszQmpeGL9sTXi0y(U(6odgzVXrNwvszQmpOII9aDJrvJDRXiEqgp(fCqpDbA0piLPY8f3eKrHR8bz84xWb90fOr)GuMkZhKaSSxQxPlUjip9R8bjal7L6v6G40pe6BhKomccHou2QqTqoiJh)coicwJwV4Mapdx5dsaw2l1R0bXPFi03oihX8HZagpAmQAm8W9GmE8l4GevGj(KJrvU4MapYx5dsaw2l1R0bXPFi03oihX8HZagpAmQAm8W9GmE8l4GCeZ)aIK4FvE6f3e4H)kFqcWYEPELoio9dH(2bX31x3zWitLz9G7yucrNiPgp(fy(gJQgZWaUhKXJFbhu2BC0PvLuMkZxCtG3TR8bjal7L6v6G40pe6BhesnwacLWLgxSXi1ybiucxguHqanMrnMVRVUZGbAHiPvmTZGkk2d0ngXgJyJrvJzmdngHgNzjjhzVXrVSrIVk5Du3zqJrOX8D91DgmqlejTIPDgSWoiJh)coOS34OtRkPmvMV4MapJVYhKaSSxQxPdIt)qOVDqAyI3NcJsiHUXOKzJH)GmE8l4GqlejTIPDU4MapCVYhKaSSxQxPdIt)qOVDqH5fqmOSANhqKCNvL08dQdbyzVuBmcnoZssoYEJJEzJeFvY7GfwJrOXzwsYbLv78aIK7SQKMFqDWc7GmE8l4GINqOjyMx5IBc8U(kFqcWYEPELoio9dH(2bHuJdZlGy8a4SOLe4zDvBtHJKYEJJoTQmeGL9sTXOg1nomVaIHgMWFZNQI)HJqDzial7LAJrSXi04mlj5i7no6Lns8vjVdwyhKXJFbhu8ecnbZ8kxCtG39VYhKXJFbhu2BC0lBK0b9rlhKaSSxQxPlUjWJcx5dY4XVGdcTqK0kM25GeGL9s9kDXnb(PFLpibyzVuVsheN(HqF7GYSKKdkR25bej3zvjn)G6OUZGdY4XVGdIYQDEarYDwvsZpOEXnXngUYhKaSSxQxPdIt)qOVDqzwsYr2BC0lBK4RsEh1Dg0yeAmsnoZssoY(DREwDmQ7mOXOg1ngPgNzjjhz)UvpRogSWAmcnUUXitflCslzI8PsQUXGkKur7yzV0yeBmIhKXJFbhuMkw4KwYe5tLlUjUH8v(GmE8l4G4oFkZs1Xbjal7L6v6IBIBWFLpiJh)coiUZNMn4ihKaSSxQxPlUjU52v(GeGL9s9kDqC6hc9Tdsv14W8cigzVXrVSrIVk5Dial7LAJrOX8D91DgmqlejTIPDgurXEGUXOSXe8AJrOXi1ybiucxACXgJuJfGqjCzqfcb0yg1yKAmFxFDNbd0crsRyANbvuShOBCXgtWRngXgJyJrSXOKzJDnCpiJh)coO4jeAcM5vU4M4gJVYhKaSSxQxPdIt)qOVDqcqOeU0yu1y3q(GmE8l4Gmk3askwkvaXf3e3G7v(GmE8l4GOSANhqKCNvL08dQhKaSSxQxPlU4GGrf(QKT4kFtq(kFqcWYEPELU4Ma)v(GeGL9s9kDXnXTR8bjal7L6v6IBcJVYhKaSSxQxPlUjW9kFqgp(fCqW24xWbjal7L6v6IBIRVYhKXJFbhe35tzwQooibyzVuVsxCtC)R8bz84xWbXD(0Sbh5GeGL9s9kDXfxCqWrO6Fb3e4zazuGbuaExpqgfGh5dA2OGhqOpivHtlk2jOOjQYQUg34YosJFfylnAm5sB80ufsJ1httJPckE2Nk1gRxfPXgBSkwi1gZDmaHOhTA3ZdKgJSQRXQEGMfgSLgsTXgp(f04PXyJnzryC0tZOv7EEG0y3uDnw1d0SWGT0qQn24XVGgpnepzKwYu4iPvLPz0QB1OifylnKAJHVXgp(f0y)Rd9OvFqWOl57Lds1ASQwfHZgsTXzHCPsJ5Rs2IgNfIhOhnEA5CbwOBmybUIJrviz9n24XVaDJxG3LrR24XVa9agv4Rs2cMKEtJUvB84xGEaJk8vjBrrMfi3T2QnE8lqpGrf(QKTOiZcglHIacl(f0QvTgdbmyANnAm1(AJZSKKsTX6WcDJZc5sLgZxLSfnolepq3yduBmmQ4kW2iEarJFDJRlqgTAJh)c0dyuHVkzlkYSGgyW0oBK0Hf6wTXJFb6bmQWxLSffzwa2g)cA1gp(fOhWOcFvYwuKzbUZNYSuD0QnE8lqpGrf(QKTOiZcCNpnBWrA1TAvRXQAveoBi1glWrOU044vKghosJnES0g)6gBWXEVL9YOvB84xGMPXgBYIW4OB1gp(fOlYSGgMy0KJbQjDqF0sR24XVaDrMfiEYiTKPWrsRkt9KmDeZhoOYrmF4mumvyeddxd3wTXJFb6Imlunfyci5yuLPEsMoI5dNbmEGk3hUi8a(Q8aIu1umcj5MgLoI5dNHIPcJqIGUSWqGHbJrnQzyapIiKzjjhKlnEsxEarktL5rDNbTAJh)c0fzwGCPXt6YdiszQmp1tY0rmF4mGXdubxgq4b8v5bePQPyesYnnkDeZhodftfgHebDzHHaddgJAuZWaEeraPmlj5OAkWeqYXOkJ6odqnQZSKKJ6tsYQLKIr88rDNbi2QnE8lqxKzbwTK(quMcykctpRoOlRorS(QasW8SkgH0QnE8lqxKzbwTK(qu0TAJh)c0fzwa2g)cA1gp(fOlYSq2VBnrYsDPvB84xGUiZczHQfk6hq0QnE8lqxKzb)t4e6K7yRekciA1gp(fOlYSa5tLSF3AR24XVaDrMfmax0b18jU59TAJh)c0fzw4bWzrljWZ6Q2MchjL9ghDAvzQNKzyucjgXRiPyt1xqj8WTv3QvTg7EzPpPlpGOXzXXGZVS0g)6gNnTuB8cAmyPkM)Dvl(f0yKEvDJdhPXElKglQaJkA9VGgh0NGqO6g)KnwhgbHqBS(DvPXpGtftl1gVWrOnoCKg7nD0y3yOXXZrRB8sBmYWTXAHVGQgXrR24XVaDrMfGXsFsxEarktL5PEsM6Wiie6agpqjsUMri5MRGeFxFDNbJmvM1dUJrjeDIKA84xG5rererajDyeecD4nDKINJovnfJqsiJsKqIHbdWxKHbdmGmJqYnxHVRVUZGrMkZ6b3XOeIorsnE8lW8iIiJ0Hrqi0H30rkEo6u1umcj5gdiIyRUvRAngfrxGg9dACjQm3yy0FPF4sJNDeGahH24pACSl6gRFcWt(CdenUAkgH0yduB8txGg9dACMkZnoZss24x3yLxRFarJrYQUJvhnoCKg7iMpCgkMknMVcj5ZFben248LwFarJJTXpieG(dxA8s24QPyesJddTaqCQgBGAJJTXvwfynwuHlADJ5ogLq0nolKlvACPT0OvB84xGUiZcpDbA0piLPY8upjZmlj5i7no6Lns8vjVJ6odq4b8v5bePQPyesc5Pp9PROrjsoI5dNHIPcJyyGCrDyeecD4nDKINJovnfJqsmgreYSKKdXZQF4iPm1M9cDOdJJgvWJGQkZssoE6c0OFqktL5blSwTXJFb6Iml80fOr)GuMkZt9Km576R7myKPYSEWDmkHOtKuJh)cmpkrgbKcZlGyK9ghDAvjLPY8qaw2lve476R7myK9ghDAvjLPY8Gkk2d0OYneB1gp(fOlYSWtxGg9dszQm3QB1QwJvLznATXfAmkgX8pGOXQA)RYtB1gp(fOlYSabRrRt9Km1Hrqi0HYwfQfsR24XVaDrMfevGj(KJrvM6jz6iMpCgW4bQGhUTAJh)c0fzwWrm)disI)v5Pt9KmDeZhody8avWd3wDRw1ACjVXr3yvrvACjQm34x3yolLkGW7sJz1sTXX2y5dhH2yQaZlGx704mvM1noBAP24f0yVO1noCmqJDmpzJTgNPYCJ5ogLqASbh79w2lt14L2y)o3ybiucxACSnwaw2lnwvsiAmKIPDA1gp(fOlYSq2BC0PvLuMkZt9Km576R7myKPYSEWDmkHOtKuJh)cmpQyya3wTXJFb6ImlK9ghDAvjLPY8upjtKeGqjCPiscqOeUmOcHayeFxFDNbd0crsRyANbvuShOreruXygqiZssoYEJJEzJeFvY7OUZae476R7myGwisAft7myH1QB1QwJvfjjfG(HJ4DzQghosJNw3R7PXWO)s)4Dvr3yvjOgVGgZ9IbhzQgxAHAS41YunE(dNglaHs4sJ1WeqvO6gBGAJ5vDJ1lnKAJZIFNB1gp(fOlYSaAHiPvmTZupjtnmX7tHrjKqJsMW3QnE8lqxKzH4jeAcM5vM6jzgMxaXGYQDEarYDwvsZpOoeGL9sfHmlj5i7no6Lns8vjVdwyiKzjjhuwTZdisUZQsA(b1blSwTXJFb6ImlepHqtWmVYupjtKcZlGy8a4SOLe4zDvBtHJKYEJJoTQmeGL9sf1OomVaIHgMWFZNQI)HJqDzial7LkIiKzjjhzVXrVSrIVk5DWcRvB84xGUiZczVXrVSrsh0hT0QnE8lqxKzb0crsRyANwTXJFb6Imlqz1opGi5oRkP5huN6jzMzjjhuwTZdisUZQsA(b1rDNbTAJh)c0fzwitflCslzI8PYupjZmlj5i7no6Lns8vjVJ6odqaPmlj5i73T6z1XOUZauJAKYSKKJSF3QNvhdwyiu3yKPIfoPLmr(ujv3yqfsQODSSxqeXwTXJFb6ImlWD(uMLQJwTXJFb6ImlWD(0SbhPvB84xGUiZcXti0emZRm1tYuvfMxaXi7no6Lns8vjVdbyzVurGVRVUZGbAHiPvmTZGkk2d0OKGxrajbiucxkIKaekHldQqiagHeFxFDNbd0crsRyANbvuShOlsWRiIiIOKPRHBR24XVaDrMfmk3askwkvaXupjtbiucxqLBi3QnE8lqxKzbkR25bej3zvjn)G6bPHj8Bc8UgfU4I7aa]] )


end