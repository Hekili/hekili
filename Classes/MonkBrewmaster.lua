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
            readyTime = function () return buff.ironskin_brew.remains - 3 end,
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


    spec:RegisterPack( "Brewmaster", 20180826.1246, [[dSewDaqiuK4rOO0Muu9jQuvJck5uqrRckvVsIAwksUfjvzxs6xsKHPioguPLbv8mQuMgjvUgkITHIQVHIIXbfY5qbzDOiL5bLY9ij7trQdsLQ0cLqpekuXfrrQ(ivQcJefu1jrrsRKk5LOGsZekuCtOqP2PIYpHcvnuuqXsHcv6PaMQeCvuqLVcfkzVG(RGbd5WuwSqpgvtwHltSze9zegnkDAvwnvQ8AOQztv3Mk2TQ(TsdhOoovQIwospNutx01jX2Hc(oqgpk05jPSEsQQ5JcSFPgIlSaeyyPaNHZeCXOjyeomVIloQJ54abs1alqaWghVriqG3CeiqrQaYX0PqHaGn18RnGfGa6vHYfiaBMG1mTsLiUKvjw5Rtj95O4T82NtnYSK(C4LI(nwksAQ3qWqjW0L88IUuHtO4GBPc4GBaJ9(4dfPcihtNcTQphoeiQC(KP(WieyyPaNHZeCXOjyeomVIlotWiiGPKSlfcaCoyCGadrZHafypDJoDJSgb244ncPrlzJmEE73i)PtDJixAJy4f8N)Qqa)PtnSaeyiKMIpHfGZWfwacy882hcyk5gSmnoEiG8w0ldyrycNHdSaeW45TpeqdwmAG1(rqN0dVabK3IEzalct4m3GfGaYBrVmGfHaC6Lc9miaRy(KTryRrSI5t2QJXyJWEJMuzotGagpV9HaehzgwYqYkHLrycNPoybiG8w0ldyriaNEPqpdcWkMpzRG5zJWwJygM0O5n6E(6CpryyogHeCt3OPBeRy(KT6ym2iS3iSAebDva3O5nAsvDnIbmOrtQ40imB08gfvijRKlnps1UNiePcO6yb9qaJN3(qGH5aw(aRrDGjCgtGfGaYBrVmGfHaC6Lc9miaRy(KTcMNncBnIjtA08gDpFDUNimmhJqcUPB00nIvmFYwDmgBe2BewnIGUkGB08gnPQUgXag0OjvCAeMnAEJWQrrfsY6WCalFG1Oo1Xc6BedyqJIkKK1XrsQOLGJrC86yb9nctiGXZBFia5sZJuT7jcrQacMWzmhwaciVf9Yawec8MJab8k6KUk6aX6hYha7vCmcbcy882hcOOLWLIdmHZygybiGXZBFia4nV9HaYBrVmGfHjCggblabmEE7dbI(DhbsfQAqa5TOxgWIWeoJHGfGagpV9HarHQfk(7jGaYBrVmGfHjCgUtGfGagpV9Ha(JGn1b3PmiCKpHaYBrVmGfHjCgU4clabmEE7dbipQe97oGaYBrVmGfHjCgU4alabmEE7dbSNl6KA(a38EiG8w0ldyrycNHRBWcqa5TOxgWIqao9sHEgeinkHK18CKqUHXjnA6gHdtGagpV9Ha3JHfVe(tr9TfMWz4QoybiG8w0ldyriaNEPqpdcOtJGqOvW8Srt3iSAeZBe2BewnYTgPEncRgX31pwqFnsfq6kN1OeIoqsnEE7B(gHzJWSry2O5ncRgPtJGqOvVPZqEC8HH5yesa3gnDJWQry1Oj1j40OYnAsDYeCBe2BewnYTgPEnIVRFSG(AKkG0voRrjeDGKA88238ncZgHzJWEJ0Prqi0Q30zipo(WWCmcj42KgHzJWecy882hcawHEKQDprisfqWeodxMalabK3IEzalcb40lf6zqGOcjzn6no(vjd81jU1Xc6B08gDpFDUNimmhJqc4Yqmed5OB00ncRgXkMpzRogJnc7nAsf3gvUr60iieA1B6mKhhFyyogHeuxJWSrZBuuHKSkEf9HbjePgiVqR6044Be2AeonAEJyknkQqswp6(A83hIubuvbmeW45Tpe4O7RXFFisfqWeodxMdlabK3IEzalcb40lf6zqa(U(Xc6RrQasx5SgLq0bsQXZBFZ3OPBeUnAEJWQrP5LpRrVXXhwgdrQaQkVf9YOrZBeFx)yb91O344dlJHivavPIJDVUryRrU1imHagpV9HahDFn(7drQacMWz4YmWcqaJN3(qGJUVg)9HivabbK3IEzalct4mCXiybiG8w0ldyriaNEPqpdcOtJGqOvNDiulLgnVr3ZxN7jcdZXiKGB6gnDJMabmEE7dbium6aMWz4YqWcqa5TOxgWIqao9sHEgeGvmFYwbZZgHTgXmtGagpV9HaSI5VNii(JXJct4mCMalabK3IEzalcb40lf6zqa(U(Xc6RrQasx5SgLq0bsQXZBFZ3iS1OjvMabmEE7dbIEJJpSmgIubemHZWbxybiG8w0ldyriaNEPqpdcGvJKxOeQ1OYncRgjVqjuRsfc5Be2BeFx)yb9v8crq7yA2kvCS71ncZgHzJWwJu3KgnVrrfsYA0BC8Rsg4RtCRJf03O5nIVRFSG(kEHiODmnBvbmeW45Tpei6no(WYyisfqWeodhCGfGaYBrVmGfHaC6Lc9miGgS49H0OesQB00QAeoqaJN3(qa8crq7yAwycNHJBWcqa5TOxgWIqao9sHEgeinV8zLQOzVNi4oBibq3pQYBrVmA08gfvijRrVXXVkzGVoXTQaUrZBuuHKSsv0S3teCNnKaO7hvfWqaJN3(qG8ieAaS5DGjCgoQdwaciVf9YawecWPxk0ZGay1O08YN17XWIxc)PO(2gswje9ghFyzSkVf9YOrmGbnknV8zvdw4N5ddXFyqOQvL3IEz0imB08gfvijRrVXXVkzGVoXTQagcy882hcKhHqdGnVdmHZWHjWcqaJN3(qGO344xLmOt6HxGaYBrVmGfHjCgomhwacy882hcGxicAhtZcbK3IEzalct4mCygybiG8w0ldyriaNEPqpdcevijRufn79eb3zdja6(rDSGEiGXZBFiavrZEprWD2qcGUFat4mCWiybiG8w0ldyriaNEPqpdcevijRrVXXVkzGVoXTowqFJM3iSAuuHKSg97o8k6SowqFJyadAewnkQqswJ(DhEfDwva3O5nASznsflzdlzG8OsySzLkKurZArV0imBeMqaJN3(qGivSKnSKbYJkWeodhgcwacy882hcWzVquHQtiG8w0ldyrycN52eybiGXZBFiaN9cGmmiqa5TOxgWIWeoZnCHfGaYBrVmGfHaC6Lc9miaRy(KTYvOu5ZgHTgXkMpzRogJnc7nAsL5nAEJyfZFprqdMvOsLVkF2OPB0eiGXZBFiGWiyXhynQdmHZCdhybiG8w0ldyriaNEPqpdcWuAuAE5ZA0BC8Rsg4RtCRYBrVmA08gX31pwqFfVqe0oMMTsfh7EDJMUre8rJM3iSAK8cLqTgvUry1i5fkHAvQqiFJWEJWQr8D9Jf0xXlebTJPzRuXXUx3OYnIGpAeMncZgHzJMwvJyotGagpV9Ha5ri0ayZ7at4m3CdwaciVf9YawecWPxk0ZGaYluc1Ae2AKB4cbmEE7dbmk3EjKlLkFct4m3uhSaeW45TpeGQOzVNi4oBibq3pGaYBrVmGfHjmHaGPcFDIwclaNHlSaeqEl6LbSimHZWbwaciVf9YaweMWzUblabK3IEzalct4m1blabK3IEzalct4mMalabmEE7dbaV5TpeqEl6LbSimHZyoSaeW45TpeGZEHOcvNqa5TOxgWIWeoJzGfGagpV9HaC2laYWGabK3IEzalctyctiageQ(2hodNj4IrtWiCuxf3jUPoiaiJ(3tOHaySCVyCNXuN5EW0AuJkWkn6CaV0SrKlTrU)qinfF6(nIkUNkhvgnsVosJmLCDSugnIZApHORTlmM7LgHltRrmCVwbm4LMYOrgpV9BK7Bk5gSmnoE3V2UWyUxAKBmTgXW9AfWGxAkJgz882VrUpXrMHLmKSsyz09RTR2ft1b8stz0iCAKXZB)g5pDQRTliGgSWHZWH5yeeamDjpVaby2gX0zu4kPmAuuixQ0i(6eTSrrH4EDTrUxoxaN6g97RESg1HuX3iJN3(6gTVxTA7Y45TVUcMk81jAPksVPX3UmEE7RRGPcFDIwwwvjYDhTlJN3(6kyQWxNOLLvvYuiCKpT82VDXSnc4nWA2nBe1UrJIkKKYOr60sDJIc5sLgXxNOLnkke3RBK9JgbMkQh4nZ7jA0PB0yFP2UmEE7RRGPcFDIwwwvj9BG1SBg0PL62LXZBFDfmv4Rt0YYQkbEZB)2LXZBFDfmv4Rt0YYQkXzVquHQZ2LXZBFDfmv4Rt0YYQkXzVaidds7QDXSnIPZOWvsz0ibdcvTgLNJ0OKvAKXZL2Ot3idd25TOxQTlJN3(AvMsUbltJJVDz882xxwvjnyXObw7hbDsp8s7Y45TVUSQsehzgwYqYkHLXPosvSI5twSXkMpzRogJyFsL5mPDz882xxwvPH5aw(aRrDM6ivXkMpzRG5j2ygMm)E(6CpryyogHeCtpnRy(KT6ymIDSiORc45tQQJbmysfhmNhvijRKlnps1UNiePcO6yb9TlJN3(6YQkrU08iv7EIqKkGM6ivXkMpzRG5j2yYK53ZxN7jcdZXiKGB6PzfZNSvhJrSJfbDvapFsvDmGbtQ4G5CSIkKK1H5aw(aRrDQJf0ZagevijRJJKurlbhJ441Xc6XSDz882xxwvjfTeUuCM6nhrLxrN0vrhiw)q(ayVIJriTlJN3(6YQkbEZB)2LXZBFDzvLI(DhbsfQATlJN3(6YQkffQwO4VNODz882xxwvj)rWM6G7ugeoYNTlJN3(6YQkrEuj63D0UmEE7RlRQK9CrNuZh4M33UmEE7RlRQ09yyXlH)uuFBdjReIEJJpSmo1rQknkHK18CKqUHXjtJdtAxTlMTrmmk0JuT7jAuuynmCRcTrNUrrtlJgTFJ(L6y(t9T82VryDm9gLSsJ8wknsyemv06B)gL0JGqO6gDKnsNgbHqBK(uFPr3ZPIPLrJwmi0gLSsJ8MoBKBtAuEC86gT0gHltAKw47p0ywBxgpV91LvvcSc9iv7EIqKkGM6ivPtJGqOvW8CASyo2XYn1dl(U(Xc6RrQasx5SgLq0bsQXZBFZJjMyohlDAeecT6nDgYJJpmmhJqc4onwynPobNYtQtMGl2XYn1JVRFSG(AKkG0voRrjeDGKA88238yIj21Prqi0Q30zipo(WWCmcj42emXSD1Uy2gXuP7RXFFJksfqncm9w6LQ1iqSYlyqOn6YgL7IVr6J4pYJBF2OH5yesJSF0OJUVg)9nksfqnkQqs2Ot3iNtRVNOryzd3POZgLSsJyfZNSvhJXgXxHK84N8zJmoFPJ7jAuUn6(uE9LQ1OLSrdZXiKgLgE5XCQgz)Or52OHId4gjmYfTUrCwJsi6gffYLknQ4wS2UmEE7RlRQ0r3xJ)(qKkGM6ivfvijRrVXXVkzGVoXTowq)875RZ9eHH5yesaxgIHyih90yXkMpzRogJyFsf3Y60iieA1B6mKhhFyyogHeuhMZJkKKvXROpmiHi1a5fAvNghp2WzotjQqswp6(A83hIubuvbC7Y45TVUSQshDFn(7drQaAQJufFx)yb91ivaPRCwJsi6aj145TV5Ng35yLMx(Sg9ghFyzmePcOQ8w0lJ58D9Jf0xJEJJpSmgIubuLko29AS5gMTlJN3(6YQkD0914VpePcO2v7IzBK7HIrhnQuJy4fZFprJy6(JXJ2UmEE7RlRQeHIrhtDKQ0Prqi0QZoeQLs7Y45TVUSQsSI5VNii(JXJo1rQIvmFYwbZtSXmtAxTlMTrf9ghFJW4zSrfPcOgD6gXvOu5tVAnsrlJgLBJKlzfAJOcyV8NMTrrQas3OOPLrJ2VrErRBuYAFJynpzJSgfPcOgXznkH0idd25TOxMQrlTr(fuJKxOeQ1OCBK8w0lnIHviAeGJPzBxgpV91Lvvk6no(WYyisfqtDKQ476hlOVgPciDLZAucrhiPgpV9np2Muzs7Y45TVUSQsrVXXhwgdrQaAQJufwYluc1kJL8cLqTkviKh78D9Jf0xXlebTJPzRuXXUxJjMytDtMhvijRrVXXVkzGVoXTowq)C(U(Xc6R4fIG2X0SvfWTR2fZ2imEss51hgeVAt1OKvAK7LHbJPrGP3sV8uFr3igwGgTFJ4EXWGmvJkUans8AzQgb6s2gjVqjuRrAWYpeQUr2pAeFOBKEPPmAuu8lO2LXZBFDzvLWlebTJPzN6ivPblEFinkHK6PvHt7Y45TVUSQs5ri0ayZ7m1rQknV8zLQOzVNi4oBibq3pQYBrVmMhvijRrVXXVkzGVoXTQaEEuHKSsv0S3teCNnKaO7hvfWTlJN3(6YQkLhHqdGnVZuhPkSsZlFwVhdlEj8NI6BBizLq0BC8HLXQ8w0ldgWG08YNvnyHFMpme)HbHQwvEl6LbMZJkKK1O344xLmWxN4wva3UmEE7RlRQu0BC8Rsg0j9WlTlJN3(6YQkHxicAhtZ2UmEE7RlRQevrZEprWD2qcGUFm1rQkQqswPkA27jcUZgsa09J6yb9TlJN3(6YQkfPILSHLmqEuzQJuvuHKSg9gh)QKb(6e36yb9ZXkQqswJ(DhEfDwhlONbmaROcjzn63D4v0zvb88XM1ivSKnSKbYJkHXMvQqsfnRf9cMy2UmEE7RlRQeN9crfQoBxgpV91LvvIZEbqggK2LXZBFDzvLegbl(aRrDM6ivXkMpzRCfkv(eBSI5t2QJXi2Nuz(CwX83te0GzfQu5RYNtpPDz882xxwvP8ieAaS5DM6ivXusZlFwJEJJFvYaFDIBvEl6LXC(U(Xc6R4fIG2X0SvQ4y3RNMGpMJL8cLqTYyjVqjuRsfc5Xow8D9Jf0xXlebTJPzRuXXUxxMGpWetmNwfZzs7Y45TVUSQsgLBVeYLsLpN6ivjVqjudBUHB7Y45TVUSQsufn79eb3zdja6(bmHjec]] )


end