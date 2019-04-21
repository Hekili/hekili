-- MonkBrewmaster.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


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
            duration = function () return 6 * haste end,
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
        },


        -- Azerite Powers
        straight_no_chaser = {
            id = 285959,
            duration = 7,
            max_stack = 1,
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
                return ceil( 100 * t.amount / health.current )

            elseif k == 'tick' then
                if bt then
                    return t.amount / 20
                end
                return t.amount / t.ticks_remain

            elseif k == 'ticks_remain' then
                return floor( stagger.remains / 0.5 )

            elseif k == 'amount' or k == 'amount_remains' then
                if bt then
                    t.amount = bt.GetNormalStagger()
                else
                    t.amount = UnitStagger( 'player' )
                end
                return t.amount

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
            charges = function () return talent.light_brewing.enabled and 4 or 3 end,
            cooldown = function () return ( 15 - ( talent.light_brewing.enabled and 3 or 0 ) ) * haste end,
            recharge = function () return ( 15 - ( talent.light_brewing.enabled and 3 or 0 ) ) * haste end,
            gcd = "off",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 1360979,

            nobuff = "ironskin_brew_icd", -- implements 1s self-cooldown
            readyTime = function () return max( ( 2 - charges_fractional ) * recharge, 0.01 + buff.ironskin_brew.remains - gcd.max ) end, -- should reserve 1 charge for purifying.
            usable = function () return ( tanking or incoming_damage_3s > 0 ) end,

            handler = function ()
                applyBuff( "ironskin_brew_icd" )
                applyBuff( "ironskin_brew", min( 21, buff.ironskin_brew.remains + 7 ) )
                spendCharges( "purifying_brew", 1 )

                -- NOTE:  CHECK FOR DURATION EXTENSION LIKE ISB...
                if azerite.straight_no_chaser.enabled then applyBuff( "straight_no_chaser" ) end
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
            charges = function () return talent.light_brewing.enabled and 4 or 3 end,
            cooldown = function () return ( 15 - ( talent.light_brewing.enabled and 3 or 0 ) ) * haste end,
            recharge = function () return ( 15 - ( talent.light_brewing.enabled and 3 or 0 ) ) * haste end,
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

                local reduction = 0.5
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

            debuff = "casting",
            readyTime = state.timeToInterrupt,

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


    spec:RegisterPack( "Brewmaster", 20190421.1222, [[dSe8DaqiIcQhbLYMGs(KcfnkeXPGQAvqP6vIuZseClOqTlG(fr1WqKoguPLPqEMi00Gc5AIeBdkQ(McvmofkCoIsSoIcnpOG7Hk2huKdcfLwOi6HeLQUOcL6JeLugjuu4KkuYkruVKOK0mjkjUjrPYobWpjkidvHkTuIc8uvAQa0vHII8vOOO2lO)QObd5WuTyr9yctwfxM0Mr4ZO0OrXPvA1ef9AuPztPBtKDl1Vv1WvWXjkPA5i9CkMUKRJQ2UiPVdOXdv58qfRNOuMVcvTFHH4cbeEpEPqagrkUYcPy0iCbXD0OrKIrWBHZGcVdUGRZQWB7sk8MKQaLCtPu4DWXX((bci8AEEQqHxMQgmYOC5SBXWNbfVKCZkXB9A)wqDIsUzLeYH3m)ARXQHz494LcbyeP4klKIrJWfexCXnfCteED(I5PW7DLK9WlZEoAdZW7rnc4fBbkjvbk5MsPbs29n3Gm2cetvdgzuUC2Ty4ZGIxsUzL4TETFlOorj3Ssc5z7NLNjCm(OPkFG(eRvnYhxQkd89yKpUYGPS7BUZKufOKBkLcAwjrqgBbcZoqxBGgHBcbAeP4klbcJd0yiJKMsqoiJTaj7z8MvnYyqgBbcJdKmqToEbASXBqTbcZWPsbYduElWGm2ceghOXLNUe4eOVT4eOLiqBfiGFpMvGgOAQAxbcNNpqe0xkqcgF7Tzd0yDtccV21ugiGW7rjCEBbbecaUqaHxxu73WRzqD6KX7Z0u0LRcVA7zREGjHfeGrqaHxT9SvpWKWRGULsxhEzu3wmbcdbIrDBXak54fiShisbX8uGxxu73Wl7suZNywm68Xdwqaseci8QTNT6bMeEf0Tu66WlJ62IbCqubcdbACsjqyfOTfV02SZJl5S6mrtGWuGyu3wmGsoEbc7bIKark4OaLoqKeisbhfiShiw6Zpei8de(bcRaL5jiajEATe4Sn7mtvGGNhydVUO2VH3JlnO9KXPsWccagbbeE12Zw9atcVc6wkDD4LrDBXaoiQaHHaLcPbcRaTT4L2MDECjNvNjAceMceJ62IbuYXlqypqKeisbhfO0bIKark4OaH9aXsF(HaHFGWpqyfiscuMNGa84sdApzCQe45b2bcF41f1(n8s80AjWzB2zMQaHfeGuGacVA7zREGjH32Lu4D7uFHx73ZNyIdV9B41f1(n8UDQVWR975tmXH3(nSGaG5qaHxxu73W7Wx73WR2E2QhysybbyCGacVUO2VH3S9)ZKGNId8QTNT6bMewqagdiGWRlQ9B4nRuJs5Unl8QTNT6bMewqaKfiGWRlQ9B41USmLzkt(dRK2f8QTNT6bMewqaWLuiGWRlQ9B4LyPA2()bE12Zw9atclia4Ileq41f1(n86Tqnf1TtHBTWR2E2Qhysybba3rqaHxT9SvpWKWRGULsxhERvsN1ppRgimfOrPaVUO2VH3Tt95QZE5Ln)HfeaCteci8QTNT6bMeEf0Tu66WBMNGamBDb3NVMIxk)GNhyhiScuMNGaCPFB4U9mtvGGuvY32eimeiwXbuYXlqyfOTfV02SZJl5S6mrtGWuGifEDrTFdVl9Bd3TNzQcewqaWfJGacVA7zREGjHxbDlLUo8k(3EEGnyMQanGcgNYQMjb1f1(TBdeMceUbcRarsGk3QDbMTUG78XBMPkqqT9SvpbcRaj(3EEGny26cUZhVzMQabPQKVTjqyiqjgi8Hxxu73W7s)2WD7zMQaHfeaCtbci8QTNT6bMeEf0Tu66WRPCwwLcoiQaHParsGgLsGWEGijq4gO0bIL(8dbc)aHFGWkqzEccWL(TH72ZmvbcYpeiScejbAuGW4ajyCkRAMeuxu73Unq4hiShiQkyCkRgimeOmpbb4s)2WD7zMQabPQKVTbEDrTFdVd80LaNTzNzQcewqaWfZHacVA7zREGjHxbDlLUo8AkNLvPGs)rPEPWRlQ9B4LL3Phybba3Xbci8QTNT6bMeEf0Tu66WlJ62IbCqubcdbkLaH9aXOUTyMMbgLQGINVRan(XhisceJ62TzNMbgLQGINVRaHjobkXaHvGyu3wmGdIkqyiqPqAGWhEDrTFdVkEdQDY4ujybba3Xaci8QTNT6bMeEf0Tu66WlJ62IbCqubcdbkXeHxxu73WlJ62TzNQDXBPWccaUYceq4vBpB1dmj8kOBP01HxX)2ZdSbZufObuW4uw1mjOUO2VDBGWqGifmf41f1(n8MTUG78XBMPkqybbyePqaHxT9SvpWKWRGULsxhEjjqARuwCcu6arsG0wPS4asvwTde2dK4F75b2GCv2PrYnmGuvY32ei8de(bcdbcJinqyfOmpbby26cUpFnfVu(bppWoqyfiX)2ZdSb5QStJKBya5hGxxu73WB26cUZhVzMQaHfeGr4cbeE12Zw9atcVc6wkDD41mOw7SCkRwMaHjobAe86IA)gE5QStJKByGfeGrJGacVUO2VH3JwpEWR2E2QhysybbyuIqaHxT9SvpWKWRGULsxhEndQ1olNYQLjqyItGgfiScuMNGaKYBy2MDkt)OtGBFappWgEDrTFdVuEdZ2Stz6hDcC7dSGamcJGacVA7zREGjHxbDlLUo8wUv7cKYBy2MDkt)OtGBFa12Zw9eiScuMNGamBDb3NVMIxk)G8dbcRaL5jiaP8gMTzNY0p6e42hq(b41f1(n8wlRsNdUvcwqagLceq4vBpB1dmj8kOBP01Hxscu5wTlWTt95QZE5Ln)NfJoZwxWD(4bQTNT6jqJF8bQCR2fOzqfRBNh1UPQuCa12Zw9ei8dewbkZtqaMTUG7ZxtXlLFq(b41f1(n8wlRsNdUvcwqagH5qaHxxu73WB26cUpFnnfD5QWR2E2Qhysybby04abeEDrTFdVCv2PrYnmWR2E2Qhysybby0yabeE12Zw9atcVc6wkDD4nZtqas5nmBZoLPF0jWTpGNhydVUO2VHxkVHzB2Pm9JobU9bwqagjlqaHxT9SvpWKWRGULsxhEZ8eeGzRl4(81u8s5h88a7aHvGijqzEccWS9)JL3uGNhyhOXp(arsGY8eeGz7)hlVPa5hcewb68fyMQEXmFIjXs155lqQsqvdJNTAGWpq4dVUO2VH3mv9Iz(etILQWccqIKcbeEDrTFdVcMDM5PMcE12Zw9atcliajIleq41f1(n8ky2jqpvfE12Zw9atcliajocci8QTNT6bMeEf0Tu66WRmCGk3QDbMTUG7ZxtXlLFqT9SvpbcRaj(3EEGnixLDAKCddivL8TnbctbIvCcewbIKaPTszXjqPdejbsBLYIdivz1oqypqKeiX)2ZdSb5QStJKByaPQKVTjqPdeR4ei8de(bc)aHjobcZtbEDrTFdV1YQ05GBLGfeGeteci8QTNT6bMeEf0Tu66WR2kLfNaHHaLiUWRlQ9B41PcV1z9uQ2fSGaKigbbeEDrTFdVuEdZ2Stz6hDcC7d8QTNT6bMewWcEhOQ4LYEbbecaUqaHxT9SvpWKWccWiiGWR2E2QhysybbiriGWR2E2QhysybbaJGacVA7zREGjHfeGuGacVUO2VH3HV2VHxT9SvpWKWccaMdbeEDrTFdVcMDM5PMcE12Zw9atcliaJdeq41f1(n8ky2jqpvfE12Zw9atclybl4nvLA2VHamIuCLfsXOr4cIlPKI5WlqN2BZAGxmZywzaaJfaYAYyGceGmAGwPHNwbI4PbAmpkHZBRXmquvwNFP6jqMxsdKZxVKx6jqcgVzvdyqwwzBnqJKXaHzQn8ddpT0tGCrTFhOXKDjQ5tmlgD(4nMGb5G8yjn80spbAuGCrTFhi7AkdyqgEndQacWimFmG3b6tSwfEXwGssvGsUPuAGKDFZniJTaXu1GrgLlNDlg(mO4LKBwjERx73cQtuYnRKqEqgBbcZoqxBGgHBcbAeP4klbcJd0yiJKMsqoiJTaj7z8MvnYyqgBbcJdKmqToEbASXBqTbcZWPsbYduElWGm2ceghOXLNUe4eOVT4eOLiqBfiGFpMvGgOAQAxbcNNpqe0xkqcgF7Tzd0yDtcgKdYylqJnEQGV0tGYkXt1ajEPSxbkRSBBadeMvi0HYeO(BmMXPse82a5IA)2eOVT4agKDrTFBahOQ4LYEXHW6gUbzxu73gWbQkEPSxP5iN4)tq2f1(TbCGQIxk7vAoYDEwjTlV2VdYylq32hmmFfiQVNaL5ji0tGmLxMaLvINQbs8szVcuwz32eiVpbAGQy8Wx12SbAnb68TcgKDrTFBahOQ4LYELMJCt7dgMVMMYltq2f1(TbCGQIxk7vAoYh(A)oi7IA)2aoqvXlL9knh5cMDM5PMki7IA)2aoqvXlL9knh5cMDc0tvdYbzSfOXgpvWx6jqAQkfNavRKgOIrdKlQNgO1eipvFTE2QGbzxu73goMb1PtgVpttrxUAq2f1(Tjnh5SlrnFIzXOZhVewcomQBlgmWOUTyaLC8WoPGyEkbzxu73M0CKFCPbTNmovkHLGdJ62IbCquyyCsbRTfV02SZJl5S6mrdMyu3wmGsoEyNesbhLMesbhHDw6ZpGp(yL5jiajEATe4Sn7mtvGGNhyhKDrTFBsZroXtRLaNTzNzQcmHLGdJ62IbCquyifsXABXlTn784soRot0Gjg1TfdOKJh2jHuWrPjHuWryNL(8d4JpwKK5jiapU0G2tgNkbEEGn(bzxu73M0CKZB05wQucTlPC2o1x41(98jM4WB)oi7IA)2KMJ8HV2VdYUO2VnP5ipB))mj4P4eKDrTFBsZrEwPgLYDB2GSlQ9BtAoYTlltzMYK)WkPDfKDrTFBsZroXs1S9)tq2f1(Tjnh5ElutrD7u4wBq2f1(Tjnh5BN6ZvN9YlB(plgDMTUG78XlHLGtTs6S(5zvmnkLGCqgBbASOFB4UDGssvGbAGUpDlCceqgT1uvAG2kq1)CdKzz7LyfExb64soRgiVpbAPFB4UDGYufyGY8eebAnbsAnMTzdej(rM8MkqfJgig1TfdOKJxGeVsqSIv7kqUq80Z2SbQ(aTDPTzlCc0teOJl5SAGkNR24NqG8(eO6d0HxAiqkEc1ycKGXPSQjqzL4PAGs(jbdYUO2VnP5iFPFB4U9mtvGjSeCY8eeGzRl4(81u8s5h88aBSY8eeGl9Bd3TNzQceKQs(2gmWkoGsoEyTT4L2MDECjNvNjAWePbzxu73M0CKV0VnC3EMPkWewcoI)TNhydMPkqdOGXPSQzsqDrTF7wmHlwKuUv7cmBDb35J3mtvGGA7zREWs8V98aBWS1fCNpEZmvbcsvjFBdgse)GCqgBbAC5PlboBZgOSY4PUppnqRjqz3ONa9DG6Nk52v28A)oqKSJDGkgnqwV0aP4nqvJz)oqfDzzvQjqlrGmLZYQ0azwztd02cQ6g9eOpvLgOIrdK1nvGsK0avRGRjqpnq4MsGmQ47JbFWGSlQ9BtAoYh4PlboBZoZufyclbht5SSkfCquyIKrPGDsWnnl95hWhFSY8eeGl9Bd3TNzQceKFalsgHXcgNYQMjb1f1(TBXh7uvW4uwfdzEccWL(TH72ZmvbcsvjFBtqoiJTajRX70tGKhimd1TBZgOX2U4T0GSlQ9BtAoYz5D6jHLGJPCwwLck9hL6LgKDrTFBsZrUI3GANmovkHLGdJ62IbCquyifSZOUTyMMbgLQGINVRXpEsyu3Un70mWOufu88DHjojIfJ62IbCquyifsXpi7IA)2KMJCg1TBZov7I3styj4WOUTyahefgsmXGCqgBbkP1fCdKmeEbkjvbgO1eibpLQDzXjq8g9eO6dKUfJsdevhSAVgMaLPkqtGYUrpb67azvJjqfJ3bIXTebYduMQadKGXPSAG8u916zRMqGEAGSpWaPTszXjq1hiT9SvdKSQYgORKBycYUO2VnP5ipBDb35J3mtvGjSeCe)BppWgmtvGgqbJtzvZKG6IA)2TyGuWucYUO2VnP5ipBDb35J3mtvGjSeCirBLYItAs0wPS4asvwTXU4F75b2GCv2PrYnmGuvY32Gp(yaJifRmpbby26cUpFnfVu(bppWglX)2ZdSb5QStJKBya5hcYbzSfiziccTnBQQfNecuXObcZoUYkbAGUpDRv2utGKvVb67ajSQNQMqGs(3aPwJMqGaUftG0wPS4eiZG2hLAcK3NajoMazEAPNaLv7dmi7IA)2KMJCUk70i5gMewcoMb1ANLtz1YGjoJcYbzxu73M0CKF06XlihKDrTFBsZroL3WSn7uM(rNa3(KWsWXmOw7SCkRwgmXzewzEccqkVHzB2Pm9JobU9b88a7GSlQ9BtAoYRLvPZb3kLWsWPCR2fiL3WSn7uM(rNa3(aQTNT6bRmpbby26cUpFnfVu(b5hWkZtqas5nmBZoLPF0jWTpG8dbzxu73M0CKxlRsNdUvkHLGdjLB1Ua3o1NRo7Lx28Fwm6mBDb35JhO2E2QNXp(YTAxGMbvSUDEu7MQsXbuBpB1d(yL5jiaZwxW95RP4LYpi)qq2f1(Tjnh5zRl4(810u0LRgKDrTFBsZroxLDAKCdtq2f1(Tjnh5uEdZ2Stz6hDcC7tclbNmpbbiL3WSn7uM(rNa3(aEEGDq2f1(Tjnh5zQ6fZ8jMelvtyj4K5jiaZwxW95RP4LYp45b2yrsMNGamB))y5nf45b2JF8KK5jiaZ2)pwEtbYpG15lWmv9Iz(etILQZZxGuLGQggpBv8Xpi7IA)2KMJCbZoZ8utfKDrTFBsZrUGzNa9u1GSlQ9BtAoYRLvPZb3kLWsWrgUCR2fy26cUpFnfVu(b12Zw9GL4F75b2GCv2PrYnmGuvY32GjwXbls0wPS4KMeTvkloGuLvBStI4F75b2GCv2PrYnmGuvY32KMvCWhF8XehmpLGSlQ9BtAoYDQWBDwpLQDLWsWrBLYIdgse3GSlQ9BtAoYP8gMTzNY0p6e42hybliea]] )


end