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
            readyTime = function () return max( ( 2 - charges_fractional ) * recharge, buff.ironskin_brew.remains - gcd.max ) end, -- should reserve 1 charge for purifying.
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


    spec:RegisterPack( "Brewmaster", 20190421.1006, [[dSe8DaqiOsvEeuuBck5tkvKrbv1PqkwfujVsKAwIi3cGYUa6xevddQ4yiLwgu4zIqtdGQRjc2grH(MsfACeLQZruW6ikX8ai3dvSpOiheQuAHIKhcvkCrLkXhjkjgPsf0jvQKwjs1lHkv1mjkjDtLkWobWpjkPmuLkQLcvQ8uvAQkvDvOsr9vIsQ2lO)QKbd5WuTyr9yctwfxM0MrYNrPrJItRy1ef9AuPztPBtKDl1Vv1WvkhhQuKLJ45umDjxhvTDruFhqJhQY5HsTEIsz(kvQ9lmKw4E494LcbadCOvgWbWXGwqAXbNeaCzaElS3u4DZfCDwfEBxsH3uefOKBkLaVBo223pW9WR55jcfEzQAZilYLZofdFgu8sYnJeV1R5BbXPk5MrsihEZ8JT21gMH3JxkeamWHwzahahdAbPfhCsirzhED(I5jW7DKWnGxM5C0gMH3JAeWlMdukIcuYnLsc0o4BUbDmhiMQ2mYIC5StXWNbfVKCZiXB9A(wqCQsUzKeYZ2plpt5a2rtw(g5PgRAKVZef35ZXiFNXDRDW3CxPikqj3ukb0msIGoMdeUDJm2aHbTjfimWHwziqawGKDzbNec6bDmhiCdgVzvJSe0XCGaSaH7uRJxG2f82uBG2HorkqEGYtbg0XCGaSaTZ8KHc7a9Tf7anubAQab87DQc0grtw7kqy)8bII8sbsW4tpnBG21Bkq41oMYa3dVhLY5TfCpeaAH7HxxuZ3WRztDYIX7ZYuKHRcVA7zREGPGfeamG7HxT9SvpWuWRGmLsghEzu3wmbcqbIrDBXak54fiCfiCaLXeGxxuZ3Wl7qvRNAvm66XdwqaseUhE12Zw9atbVcYukzC4LrDBXaUjQabOaTJjeiSc00IxAA21XLCwDLOjqykqmQBlgqjhVaHRaHFGWbeJaLoq4hiCaXiq4kqSKNFlq0eiAcewbkZtrbs9KAOWEA2vMOabppWgEDrnFdVhxAt7fJtKGfeaahUhE12Zw9atbVcYukzC4LrDBXaUjQabOaLaobcRanT4LMMDDCjNvxjAceMceJ62IbuYXlq4kq4hiCaXiqPde(bchqmceUcel553cenbIMaHvGWpqzEkkWJlTP9IXjsGNhyhiAGxxuZ3Wl1tQHc7PzxzIcewqasaUhE12Zw9atbVTlPW70j)cVMVxp1cBE73WRlQ5B4D6KFHxZ3RNAHnV9BybbqgH7HxxuZ3W72xZ3WR2E2QhykybbyhH7HxxuZ3WB2()zrXtWgE12Zw9atbliaYoCp86IA(gEZkXOeUtZcVA7zREGPGfeazaUhEDrnFdV2HLPmlzYFyL0UGxT9SvpWuWccaT4a3dVUOMVHxQHOz7)h4vBpB1dmfSGaqlTW9WRlQ5B41BHAkIBxc3AHxT9SvpWuWccaTya3dVA7zREGPGxbzkLmo8wJKUQFDgnqykqyKa86IA(gENo5NRU6Hx28hwqaOnr4E4vBpB1dmf8kitPKXH3mpffy26cUpFTeVu(bppWoqyfOmpff4q(2WD6vMOabjQKpTjqakqSIdOKJxGWkqtlEPPzxhxYz1vIMaHPaHd86IA(gEhY3gUtVYefiSGaqlGd3dVA7zREGPGxbzkLmo8k(3EEGnyMOanGcgNWQMffXf18TBdeMceTbcRaHFGk3QDbMTUG76XBLjkqqT9SvpbcRaj(3EEGny26cURhVvMOabjQKpTjqakqjgiAGxxuZ3W7q(2WD6vMOaHfeaAtaUhE12Zw9atbVcYukzC41uolRsa3evGWuGWpqyKqGWvGWpq0gO0bIL88BbIMartGWkqzEkkWH8TH70RmrbcYVfiSce(bcJabybsW4ew1SOiUOMVDBGOjq4kqevW4ewnqakqzEkkWH8TH70RmrbcsujFAd86IA(gE34jdf2tZUYefiSGaqRmc3dVA7zREGPGxbzkLmo8AkNLvjGs)rjEPWRlQ5B4LL3jhybbG2DeUhE12Zw9atbVcYukzC4LrDBXaUjQabOaLqGWvGyu3wmlZgJsuqXZ3vG29Ude(bIrD70SlZgJsuqXZ3vGWeNaLyGWkqmQBlgWnrfiafOeWjq0aVUOMVHxfVn1UyCIeSGaqRSd3dVA7zREGPGxbzkLmo8YOUTya3evGauGsmr41f18n8YOUDA2LAh8gcSGaqRma3dVA7zREGPGxbzkLmo8k(3EEGnyMOanGcgNWQMffXf18TBdeGceoGjaVUOMVH3S1fCxpERmrbcliayGdCp8QTNT6bMcEfKPuY4Wl(bsBLWIDGshi8dK2kHfBqIYQDGWvGe)BppWgKRYUmsUHbKOs(0MartGOjqakqaoobcRaL5POaZwxW95RL4LYp45b2bcRaj(3EEGnixLDzKCddi)g86IA(gEZwxWD94TYefiSGaGbTW9WR2E2Qhyk4vqMsjJdVMn1AxLty1YeimXjqyaVUOMVHxUk7Yi5ggybbadmG7HxxuZ3W7rRhp4vBpB1dmfSGaGrIW9WR2E2Qhyk4vqMsjJdVMn1AxLty1YeimXjqyeiScuMNIcKWByMMDjt)OlGtFappWgEDrnFdVeEdZ0Slz6hDbC6dSGaGbGd3dVA7zREGPGxbzkLmo8wUv7cKWByMMDjt)OlGtFa12Zw9eiScuMNIcmBDb3NVwIxk)G8BbcRaL5POaj8gMPzxY0p6c40hq(n41f18n8wdRswBUvcwqaWib4E4vBpB1dmf8kitPKXHx8du5wTlWPt(5QRE4Ln)xfJUYwxWD94bQTNT6jq7E3bQCR2fOztfJBxh1ojReSb12Zw9eiAcewbkZtrbMTUG7ZxlXlLFq(n41f18n8wdRswBUvcwqaWqgH7HxxuZ3WB26cUpFTmfz4QWR2E2QhykybbaJDeUhEDrnFdVCv2LrYnmWR2E2QhykybbadzhUhE12Zw9atbVcYukzC4nZtrbs4nmtZUKPF0fWPpGNhydVUOMVHxcVHzA2Lm9JUao9bwqaWqgG7HxT9SvpWuWRGmLsghEZ8uuGzRl4(81s8s5h88a7aHvGWpqzEkkWS9)JL3uGNhyhODV7aHFGY8uuGz7)hlVPa53cewb68fyMOEXSEQf1q015lqIsrudJNTAGOjq0aVUOMVH3mr9Iz9ulQHOWccqI4a3dVUOMVHxbZSY8etbVA7zREGPGfeGePfUhEDrnFdVcMzb0twHxT9SvpWuWccqIya3dVA7zREGPGxbzkLmo8I7fOYTAxGzRl4(81s8s5huBpB1tGWkqI)TNhydYvzxgj3WasujFAtGWuGyfNaHvGWpqARewSdu6aHFG0wjSydsuwTdeUce(bs8V98aBqUk7Yi5ggqIk5tBcu6aXkobIMartGOjqyItGKXeGxxuZ3WBnSkzT5wjybbiXeH7HxT9SvpWuWRGmLsghE1wjSyhiafOePfEDrnFdVor4TUQNq0UGfeGebC4E41f18n8s4nmtZUKPF0fWPpWR2E2Qhykybl4DJOIxk7fCpeaAH7HxT9SvpWuWccagW9WR2E2Qhykybbir4E4vBpB1dmfSGaa4W9WR2E2Qhykybbib4E41f18n8U918n8QTNT6bMcwqaKr4E41f18n8kyMvMNyk4vBpB1dmfSGaSJW9WRlQ5B4vWmlGEYk8QTNT6bMcwWcwWBYkXmFdbadCOvgWbWXGwqAXbNeGxGoPNM1aVY64wCha7kaYkYsGc0EgnqJ02tQar9KaTthLY5T1ofiIIBIFi6jqMxsdKZxVKx6jqcgVzvdyqxwDAnqyilbc3CB432EsPNa5IA(oq7e7qvRNAvm66XBNad6b9DvA7jLEcegbYf18DGSJPmGbD41SPciayiJYo8UrEQXQWlMdukIcuYnLsc0o4BUbDmhiMQ2mYIC5StXWNbfVKCZiXB9A(wqCQsUzKeYd6yoq42nYydeg0MuGWahALHabybs2LfCsiOh0XCGWny8MvnYsqhZbcWceUtToEbAxWBtTbAh6ePa5bkpfyqhZbcWc0oZtgkSd03wSd0qfOPceWV3PkqBenzTRaH9ZhikYlfibJp90SbAxVPad6bDmhODbpvWx6jqzL6jAGeVu2RaLv2PnGbc3ke6wzcu)nGX4ejkEBGCrnFBc03wSbd6UOMVnGBev8szV4qzDd3GUlQ5Bd4grfVu2R0CKt9)jO7IA(2aUruXlL9knh5opRK2LxZ3bDmhOB7BgMVceXNtGY8uu6jqMYltGYk1t0ajEPSxbkRStBcK3NaTruaB7RAA2anMaD(wbd6UOMVnGBev8szVsZrUP9ndZxlt5LjO7IA(2aUruXlL9knh5BFnFh0DrnFBa3iQ4LYELMJCbZSY8etf0DrnFBa3iQ4LYELMJCbZSa6jRb9GoMd0UGNk4l9einzLGDGQrsduXObYf1tc0ycKNSpwpBvWGUlQ5BdhZM6KfJ3NLPidxnO7IA(2KMJC2HQwp1Qy01Jxsdfhg1TfdGyu3wmGsoE4chqzmHGUlQ5BtAoYpU0M2lgNiL0qXHrDBXaUjkaTJjG10IxAA21XLCwDLObtmQBlgqjhpCHpoGyKgFCaXaxSKNFJgAWkZtrbs9KAOWEA2vMOabppWoO7IA(2KMJCQNudf2tZUYefysdfhg1Tfd4MOauc4G10IxAA21XLCwDLObtmQBlgqjhpCHpoGyKgFCaXaxSKNFJgAWc)mpff4XL20EX4ejWZdSPjO7IA(2KMJCEJUMsLsQDjLZ0j)cVMVxp1cBE73bDxuZ3M0CKV918Dq3f18Tjnh5z7)Nffpb7GUlQ5BtAoYZkXOeUtZg0DrnFBsZrUDyzkZsM8hwjTRGUlQ5BtAoYPgIMT)Fc6UOMVnP5i3BHAkIBxc3Ad6UOMVnP5iF6KFU6QhEzZ)vXORS1fCxpEjnuCQrsx1VoJIjmsiOh0XCG2vY3gUthOuefyG2iZtMc7abKrBnzLeOPcu9p3azg2EOgH3vGoUKZQbY7tGgY3gUthOmrbgOmpfvGgtGKgJzA2aHVFKjVPcuXObIrDBXak54fiXRuuJy0UcKlep5mnBGQpqtxABMc7a9ub64soRgOY5QnnjfiVpbQ(aD4L2cKINqnMajyCcRAcuwPEIgOuFkWGUlQ5BtAoYhY3gUtVYefysdfNmpffy26cUpFTeVu(bppWgRmpff4q(2WD6vMOabjQKpTbqSIdOKJhwtlEPPzxhxYz1vIgmHtq3f18Tjnh5d5Bd3PxzIcmPHIJ4F75b2GzIc0akyCcRAwuexuZ3Uft0If(LB1UaZwxWD94TYefiO2E2QhSe)BppWgmBDb31J3ktuGGevYN2aOePjOh0XCG2zEYqH90SbkRmEYZZtc0ycu2n6jqFhO(jsUDKnVMVde(ZUeOIrdK1lnqkEBe1yMVdurgwwLyc0qfit5SSkjqMr20anTGOUrpb6twjbQy0azDtfOeXjq1i4Ac0tceTjeiJk((yObmO7IA(2KMJ8nEYqH90SRmrbM0qXXuolRsa3efMWhJeWf(0MML88B0qdwzEkkWH8TH70RmrbcYVHf(yaycgNWQMffXf18TBPbxevW4ewfqzEkkWH8TH70RmrbcsujFAtqpOJ5ajRW7KtGKhODO62Pzd0Uyh8gsq3f18Tjnh5S8o5K0qXXuolRsaL(Js8sd6UOMVnP5ixXBtTlgNiL0qXHrDBXaUjkaLaUyu3wmlZgJsuqXZ31U3n(mQBNMDz2yuIckE(UWeNeXIrDBXaUjkaLao0e0DrnFBsZroJ62PzxQDWBijnuCyu3wmGBIcqjMyqpOJ5aLY6cUbswdVaLIOad0ycKGNq0USyhiEJEcu9bsNIrjbIOBwThdtGYefOjqz3ONa9DGSQXeOIX7aX4wQa5bktuGbsW4ewnqEY(y9Svtkqpjq2hyG0wjSyhO6dK2E2Qbc3xzd0vYnmbDxuZ3M0CKNTUG76XBLjkWKgkoI)TNhydMjkqdOGXjSQzrrCrnF7waHdycbDxuZ3M0CKNTUG76XBLjkWKgko4RTsyXon(ARewSbjkR24s8V98aBqUk7Yi5ggqIk5tBOHgab44GvMNIcmBDb3NVwIxk)GNhyJL4F75b2GCv2LrYnmG8Bb9GoMdKSgfL2Mjz1IDsbQy0aHB3zz1aTrMNm1iBQjq4(3a9DGew1twtkqP(BGuRrtkqaNIjqARewSdKzt7JsmbY7tGehtGmpP0tGYQ9bg0DrnFBsZroxLDzKCdtsdfhZMATRYjSAzWehmc6bDxuZ3M0CKF06XlOh0DrnFBsZroH3Wmn7sM(rxaN(K0qXXSPw7QCcRwgmXbdSY8uuGeEdZ0Slz6hDbC6d45b2bDxuZ3M0CKxdRswBUvkPHIt5wTlqcVHzA2Lm9JUao9buBpB1dwzEkkWS1fCF(AjEP8dYVHvMNIcKWByMMDjt)OlGtFa53c6UOMVnP5iVgwLS2CRusdfh8l3QDboDYpxD1dVS5)Qy0v26cURhpqT9Svp7E3LB1UanBQyC76O2jzLGnO2E2QhAWkZtrbMTUG7ZxlXlLFq(TGUlQ5BtAoYZwxW95RLPidxnO7IA(2KMJCUk7Yi5gMGUlQ5BtAoYj8gMPzxY0p6c40NKgkozEkkqcVHzA2Lm9JUao9b88a7GUlQ5BtAoYZe1lM1tTOgIM0qXjZtrbMTUG7ZxlXlLFWZdSXc)mpffy2()XYBkWZdS39UXpZtrbMT)FS8McKFdRZxGzI6fZ6PwudrxNVajkfrnmE2Q0qtq3f18Tjnh5cMzL5jMkO7IA(2KMJCbZSa6jRbDxuZ3M0CKxdRswBUvkPHIdUx5wTlWS1fCF(AjEP8dQTNT6blX)2ZdSb5QSlJKByajQKpTbtSIdw4RTsyXon(ARewSbjkR24cFX)2ZdSb5QSlJKByajQKpTjnR4qdn0GjoYycbDxuZ3M0CK7eH36QEcr7kPHIJ2kHfBaLiTbDxuZ3M0CKt4nmtZUKPF0fWPpWcwqia]] )


end