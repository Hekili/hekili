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
                return stagger == debuff.light_stagger and stagger.up
            
            elseif k == "moderate" then
                return stagger == debuff.moderate_stagger and stagger.up
                
            elseif k == "heavy" then
                return stagger == debuff.heavy_stagger and stagger.up
                
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
                    total = total + ( stagger_ticks[i] or 0 )
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
            
            --readyTime = function () return buff.ironskin_brew.remains - 3 end,
            handler = function ()
                applyBuff( "ironskin_brew_icd" )
                applyBuff( "ironskin_brew", buff.ironskin_brew.remains + 7 )
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

            toggle = "defensives",
            defensive = true,
            
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


    spec:RegisterPack( "Brewmaster", 20180824.1034, [[dSu9Aaqiui6rOOYMasFIkfnkOWPaQwfkOxjfnlPuDlQOyxs1VuuggqCmOsldQ4zuPAAOqDnOO2gvk9nGIghqHZHcyDOqQ5HIY9Oc7dkYbPsHwOuYdrbsUivuQpIcKAKurjDsuizLujVefcntQuWnrbk2PIQFIcunuuiyPOarpfWuLcxLkkXxrbkTxq)vWGHCyklwOhJQjRWLjTze(mIgnrDAvwnvu9AOQztv3Mi7wv)wPHdLookqy5i9Cctx01rPTlLY3vKXtf58OiRhfvnFGs7xYqCHnGadlv4CCabxWaeWahg3Xfe3zmJzaiqYewfcG144nsfc8MKcbAr1jjtKkfcG1yYV2a2aciwwkxHaYzIvWONnJ8sz2yNVsZeNeR3YBFo1iYzItIpl634SiH5mdTTzyPlX5vXSgNsXb3znWb3adM9XhAr1jjtKkTlojoeiYE(Kr9WieyyPcNJdi4cgGag4W4oUGGlyIzWacySP8sHaaNedkiWqfCiqd5tuOtuiRqynoEJul0suiJN3(fYFIuuiILwiNvf)5VoeWFIuaBabgkHX6tyd4CCHnGagpV9HacSQrdY2pcIKE4viG(w0RdylycNJdSbeqFl61bSfeGtVuPNbbKvZNYfIzfswnFk3LmNkedleiD3IziGXZBFia5rKHLiKYAyDcMW5UdBab03IEDaBbb40lv6zqaz18PChlpleZkeyI5cbAHUNVs3tggMKrQb3ffctfswnFk3LmNkedlegfIKUSyleOfcKoJleybBHaPJtHaVqGwOilbrNyP5rW09KHivN6JD6HagpV9HadtcR(bzJkbt4CgdBab03IEDaBbb40lv6zqaz18PChlpleZkeyI5cbAHUNVs3tggMKrQb3ffctfswnFk3LmNkedlegfIKUSyleOfcKoJleybBHaPJtHaVqGwimkuKLGOpmjS6hKnQuFStFHalyluKLGOpoccwHgKmYJ3h70xiWHagpV9HaelnpcMUNmeP6emHZXmSbeqFl61bSfe4njfc4zfjDzfbY1p0pG1ZkzKkeW45TpeGvOHlvjycN7wydiGXZBFiWqZ1jiG(w0RdylycNdMWgqaJN3(qaSBE7db03IEDaBbt4CWa2acy882hce97oceSuMGa6BrVoGTGjCodaBabmEE7dbIkvOu83tcb03IEDaBbt4CCbb2acy882hc4ps5ueCo7Gus)ecOVf96a2cMW54IlSbeW45TpeG4OA0V7acOVf96a2cMW54IdSbeW45TpeWEUksQ5dCZ7Ha6BrVoGTGjCoUUdBab03IEDaBbb40lv6zqG0OKA2Ztsd5ggNwimviCWmeW45Tpe4(2w8A4pwM3wycNJlJHnGa6BrVoGTGaC6Lk9miqKLGOh9gh)YMb(kf3(yN(cbAHUNVs3tggMKrQbCzagGbKefctfcJcjRMpL7sMtfIHfcKoUfQzHePrsQ0U3ezipo(WWKmsnW4cbEHaTqrwcIU6zfxBAisTjVs7I044leZkeofc0cXiluKLGOF09f4VpeP6uNfleW45Tpe4O7lWFFis1jycNJlMHnGa6BrVoGTGaC6Lk9miaFx)yN(EKQtIox2OKQiqqnEE7B(cHPcHBHaTq8D9JD67rVXXhwNcrQo1PQKDVOqmRqUdbmEE7dbo6(c83hIuDcMW546wydiG(w0RdyliaNEPspdcisJKuPDS8SqyQqyui3wigwimkK7fYzkegfIVRFStFps1jrNlBusveiOgpV9nFHaVqGxiWleOfcJcjsJKuPDVjYqEC8HHjzKAa3cHPcHrHWOqG0bbNc1SqG0bbeCledlegfY9c5mfIVRFStFps1jrNlBusveiOgpV9nFHaVqGxigwirAKKkT7nrgYJJpmmjJudUdsHaVqGdbmEE7dbWYspcMUNmeP6emHZXfmHnGa6BrVoGTGaC6Lk9miaFx)yN(EKQtIox2OKQiqqnEE7B(cXScbshZqaJN3(qGO344dRtHivNGjCoUGbSbeqFl61bSfeGtVuPNbbWOq6RusMkuZcHrH0xPKm1PkP(fIHfIVRFStFhVsgesMqUtvj7ErHaVqGxiMvigdsHaTqrwcIE0BC8lBg4RuC7JD6leOfIVRFStFhVsgesMqUZIfcy882hce9ghFyDkeP6emHZXLbGnGa6BrVoGTGaC6Lk9miGaR69H0OKAkkeMCuiCGagpV9Ha4vYGqYeYWeohhqGnGa6BrVoGTGaC6Lk9miqAE9ZoLviFpzW52qdt3p66BrVokeOfkYsq0JEJJFzZaFLIBNfBHaTqrwcIoLviFpzW52qdt3p6SyHagpV9Ha5rQ0awZlbt4CCWf2acOVf96a2ccWPxQ0ZGayuO086N97BBXRH)yzEBdPSgIEJJpSo113IEDuiWc2cLMx)SlWQ8Z8HH6V2uktD9TOxhfc8cbAHISee9O344x2mWxP42zXcbmEE7dbYJuPbSMxcMW54GdSbeW45Tpei6no(LndIKE4viG(w0RdylycNJJ7WgqaJN3(qa8kzqizcziG(w0RdylycNJdJHnGa6BrVoGTGaC6Lk9miqKLGOtzfY3tgCUn0W09J(yNEiGXZBFiaLviFpzW52qdt3pGjCooyg2acOVf96a2ccWPxQ0ZGarwcIE0BC8lBg4RuC7JD6leOfcJcfzji6r)UdpRi7JD6leybBHWOqrwcIE0V7WZkYol2cbAHgB2Ju1s5WseioQggB2PkbvfYw0Rfc8cboeW45TpeisvlLdlrG4OkmHZXXTWgqaJN3(qaU8fISurcb03IEDaBbt4CCatydiGXZBFiax(ctwBkeqFl61bSfmHZXbmGnGa6BrVoGTGaC6Lk9miaJSqP51p7rVXXVSzGVsXTRVf96OqGwi(U(Xo9D8kzqizc5ovLS7ffctfIKpkeOfcJcPVsjzQqnlegfsFLsYuNQK6xigwimkeFx)yN(oELmiKmHCNQs29Ic1SqK8rHaVqGxiWleMCui3IziGXZBFiqEKknG18sWeohhga2acOVf96a2ccWPxQ0ZGa6RusMkeZkK74cbmEE7dbmk3EnKlLQFct4C3bb2acy882hcqzfY3tgCUn0W09diG(w0RdylyctiawQYxPOLWgW54cBab03IEDaBbt4CCGnGa6BrVoGTGjCU7Wgqa9TOxhWwWeoNXWgqa9TOxhWwWeohZWgqaJN3(qaSBE7db03IEDaBbt4C3cBabmEE7db4YxiYsfjeqFl61bSfmHZbtydiGXZBFiax(ctwBkeqFl61bSfmHjmHaTPuXTpCooGGlyacy6oiDCWbZ4abMm6FpPacWG1nYGCoJAodAgDHkudzTqNe2LMfIyPfYnhkHX6t3SquLbb7r1rHeRKwiJnxjl1rH4Y2tQIE5YnCVwiCz0fYz5fSyXU0uhfY45TFHCtJn3GLPXX7M9YLB4ETqUZOlKZYlyXIDPPokKXZB)c5MKhrgwIqkRH1j3SxUkxmkjSln1rHWPqgpV9lK)ePOxUGacSkhohh3cgqaS0L48keG5kKZ2jLZM6OqrLyPAH4Ru0YcfvY7f9c5g5CfBkk0VVZiBujcwFHmEE7lk0(EM6LlJN3(IowQYxPOLoi8MaF5Y45TVOJLQ8vkAzthZi2DuUmEE7l6yPkFLIw20XmJLus)0YB)YfZviG3WkK3Squ7gfkYsqOJcjslffkQelvleFLIwwOOsEVOq2pkewQ6my3mVNSqNOqJ91E5Y45TVOJLQ8vkAzthZeVHviVzqKwkkxgpV9fDSuLVsrlB6yg2nV9lxgpV9fDSuLVsrlB6ygx(crwQilxgpV9fDSuLVsrlB6ygx(ctwBA5QCXCfYz7KYztDuiTnLYuHYtslukRfY45sl0jkK1MDEl61E5Y45TVWHXMBWY044lxgpV9fnDmtGvnAq2(rqK0dVwUmEE7lA6yg5rKHLiKYAyDQ9JWHSA(uMzYQ5t5UK5edbP7wmxUmEE7lA6y2WKWQFq2OsTFeoKvZNYDS8KzGjMb9E(kDpzyysgPgCxGjz18PCxYCIHyqsxwSGcsNXGfSG0XbCqJSeeDILMhbt3tgIuDQp2PVCz882x00XmILMhbt3tgIuDQ9JWHSA(uUJLNmdmXmO3ZxP7jddtYi1G7cmjRMpL7sMtmeds6YIfuq6mgSGfKooGdkgrwcI(WKWQFq2Os9Xo9GfSrwcI(4iiyfAqYipEFStp4LlJN3(IMoMXk0WLQu7VjPo8SIKUSIa56h6hW6zLmsTCz882x00XmSBE7xUmEE7lA6yw0V7iqWszQCz882x00XSOsfkf)9KLlJN3(IMoM5ps5ueCo7Gus)SCz882x00XmIJQr)UJYLXZBFrthZSNRIKA(a38(YLXZBFrthZUVTfVg(JL5TnKYAi6no(W6u7hHJ0OKA2Ztsd5ggNIjCWC5QCXCfIrr3xG)(c1IQtfcl9w6LmvOjz912uAHUSq5U4lK4i)J442NfAysgPwi7hf6O7lWFFHIuDQqrwcIcDIcjDcX9KfcdB4CwrwOuwlKSA(uUlzovi(Qeeh)0plKX5lDCpzHYTq3N6lUKPcTefAysgPwO0WRp4Txi7hfk3cnyLWwi1jUkefIlBusvuOOsSuTqT2w9YLXZBFrthZo6(c83hIuDQ9JWrKLGOh9gh)YMb(kf3(yNEqVNVs3tggMKrQbCzagGbKeycdz18PCxYCIHG0XTPinssL29Mid5XXhgMKrQbgdoOrwcIU6zfxBAisTjVs7I044zgoGYiJSee9JUVa)9HivN6SylxgpV9fnDm7O7lWFFis1P2pch8D9JD67rQoj6CzJsQIab145TV5XeUGY31p2PVh9ghFyDkeP6uNQs29cM5E5QCXCfIrGLEemDpzHIQS12TS0cDIcfnHok0(f6xQK5pM3YB)cHX5SlukRfYBPwi1jSuviU9luspssLkk0ruirAKKkTqIJ51cDpNQMqhfABtPfkL1c5nrwi3bPq5XXlk0sleUyUqcLV)qaEVCz882x00XmSS0JGP7jdrQo1(r4qKgjPs7y5jMWWTmed3Dgm476h703JuDs05YgLufbcQXZBFZdo4GdkgI0ijvA3BImKhhFyysgPgWftyGbiDqWPjiDqabxgIH7odFx)yN(EKQtIox2OKQiqqnEE7BEWbNHI0ijvA3BImKhhFyysgPgCheWbVCvUyUc1YBC8fIb3Pc1IQtf6efIZsP6NEMkeRqhfk3cPxkR0crvSE9pHCHIuDsuOOj0rH2VqEvikukBFHKnprHScfP6uH4YgLulK1MDEl612l0slKFNkK(kLKPcLBH03IETqmIkzHaKmHC5Y45TVOPJzrVXXhwNcrQo1(r4GVRFStFps1jrNlBusveiOgpV9npZaPJ5YLXZBFrthZIEJJpSofIuDQ9JWbg6RusMAIH(kLKPovj1NH8D9JD674vYGqYeYDQkz3lahCMXyqanYsq0JEJJFzZaFLIBFStpO8D9JD674vYGqYeYDwSLRYfZvigCcc9fxBQNP2lukRfYnYi4gkew6T0lpMxffIreOq7xiUxT202luRfOqQxOTxOPlLlK(kLKPcjWQ)qPIcz)Oq8HOqILM6Oqr1VtLlJN3(IMoMHxjdcjti3(r4qGv9(qAusnfyYboLlJN3(IMoMLhPsdynVu7hHJ086NDkRq(EYGZTHgMUF013IEDaAKLGOh9gh)YMb(kf3olwqJSeeDkRq(EYGZTHgMUF0zXwUmEE7lA6ywEKknG18sTFeoWinV(z)(2w8A4pwM32qkRHO344dRtD9TOxhGfSP51p7cSk)mFyO(RnLYuxFl61b4Ggzji6rVXXVSzGVsXTZITCz882x00XSO344x2mis6HxlxgpV9fnDmdVsgesMqUCz882x00XmkRq(EYGZTHgMUF0(r4iYsq0PSc57jdo3gAy6(rFStF5Y45TVOPJzrQAPCyjcehvB)iCezji6rVXXVSzGVsXTp2PhumISee9OF3HNvK9Xo9GfSyezji6r)UdpRi7Sybf0XM9ivTuoSebIJQHXMDQsqvHSf9k4GxUmEE7lA6ygx(crwQilxgpV9fnDmJlFHjRnTCz882x00XS8ivAaR5LA)iCWitZRF2JEJJFzZaFLIBxFl61bO8D9JD674vYGqYeYDQkz3lWejFakg6RusMAIH(kLKPovj1NHyW31p2PVJxjdcjti3PQKDVOjjFao4GJjhUfZLlJN3(IMoMzuU9Aixkv)S9JWH(kLKjM5oULlJN3(IMoMrzfY3tgCUn0W09dyctiea]] )


end