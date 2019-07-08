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
            duration = 21,
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
                return ceil( 100 * t.tick / health.current )

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

            usable = function ()
                if active_dot.keg_smash / true_active_enemies < settings.bof_percent / 100 then
                    return false, "keg_smash applied to fewer than " .. settings.bof_percent .. " targets"
                end
                return true
            end,

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

            usable = function ()
                if healing_sphere.count == 0 then return false, "no healing spheres"
                elseif ( settings.eh_percent > 0 and health.pct > settings.eh_percent ) then return false, "health is above " .. settings.eh_percent .. "%" end
                return true
            end,
            handler = function ()
                if level < 116 and set_bonus.tier20_4pc == 1 then stagger.amount = stagger.amount * ( 1 - ( 0.05 * healing_sphere.count ) ) end
                gain( healing_sphere.count * stat.attack_power * 2, "health" )
                healing_sphere.count = 0
            end,
        },


        fortifying_brew = {
            id = 115203,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 420 end,
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
            readyTime = function ()
                if full_recharge_time < 3 then return 0 end
                return max( ( 2 - charges_fractional ) * recharge, 0.01 + buff.ironskin_brew.remains - settings.isb_overlap ) end, -- should reserve 1 charge for purifying.
            usable = function ()
                if not tanking and incoming_damage_3s == 0 then return false, "player is not tanking or has not taken damage in 3s" end
                return true
            end,

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
                active_dot.keg_smash = active_enemies

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

            readyTime = function ()
                return ( 1 + settings.brew_charges - charges_fractional ) * recharge
            end,

            usable = function ()
                if stagger.pct == 0 then return false, "no damage is staggered" end
                if settings.purify_stagger > 0 then
                    if stagger.pct < settings.purify_stagger * ( group and 1 or 0.5 ) then return false, "stagger pct " .. stagger.pct .. " less than purify_stagger setting " .. ( settings.purify_stagger * ( group and 1 or 0.5 ) ) end
                end
                return true
            end,

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


    spec:RegisterSetting( "bof_percent", 50, {
        name = "|T615339:0|t Breath of Fire: Require |T594274:0|t Keg Smash %",
        desc = "If set above zero, |T615339:0|t Breath of Fire will only be recommended if this percentage of your targets are afflicted with |T594274:0|t Keg Smash.\n\n" ..
            "Example:  If set to |cFFFFD10050|r, with 2 targets, Breath of Fire will be saved until at least 1 target has Keg Smash applied.",
        type = "range",
        min = 0,
        max = 100,
        step = 0.1,
        width = 1.5
    } )


    spec:RegisterSetting( "eh_percent", 65, {
        name = "|T627486:0|t Expel Harm: Health %",
        desc = "If set above zero, the addon will not recommend |T627486:0|t Expel Harm until your health falls below this percentage.",
        type = "range",
        min = 0,
        max = 100,
        step = 1,
        width = 1.5
    } )

    spec:RegisterSetting( "isb_overlap", 1, {
        name = "|T1360979:0|t Ironskin Brew: Overlap Duration",
        desc = "If set above zero, the addon will not recommend |T1360979:0|t Ironskin Brew until the buff has less than this number of seconds remaining, unless you are about to cap Ironskin Brew charges.",
        type = "range",
        min = 0,
        max = 7,
        step = 0.1,
        width = 1.5
    } )

    spec:RegisterSetting( "brew_charges", 2, {
        name = "|T1360979:0|t Ironskin Brew: Reserve Charges",
        desc = "If set above zero, the addon will not recommend |T133701:0|t Purifying Brew if it would leave you without these charges for |T1360979:0|t Ironskin Brew.",
        type = "range",
        min = 0,
        max = 4,
        step = 0.1,
        width = 1.5
    } )

    spec:RegisterSetting( "purify_stagger", 33, {
        name = "|T133701:0|t Purifying Brew: Minimum Stagger %",
        desc = "If set above zero, the addon will not recommend |T133701:0|t Purifying Brew if your current stagger is ticking for less than this percentage of your |cFFFF0000current|r health.\n\n" ..
            "This value is halved when playing solo.",
        type = "range",
        min = 0,
        max = 100,
        step = 0.1,
        width = 1.5
    } )


    spec:RegisterPack( "Brewmaster", 20190707.2339, [[dS0aEaqiIkQhPi1MGs9jfjzuqLofkXQar9kr0SiQ6wqj1UuPFjcdJO4yeLwMi1ZqPmnOKCnqKTHsL(MirJJOsDorcRdLkMhi4EOk7dkXbbHklur8qfj0fvKuFurcmsfjQtccLvcv9sIkKzsubUjrfQDcf(jrf0qjQilvrI8uvmvOORccv5Rksq7fYFf1GbomvlwHhtyYG6YK2mcFgfJgrNwQvJsvVgv1SP0TjYUv63QA4kQJdcv1Yr65umDjxhv2UiPVdsJhL05HkwprLmFqi7xyKSimrhyVuegPLr2uitkLjL30SHvSB60OtHZSIoZUGVZOOZ6sk6mHQqLCtPu0z2XX(omct0X8CuHIoKvnByNejy6IKBCfVuctlXz9Q)vqDIkHPLejqNbxBli2IgOdSxkcJ0YiBkKjLYKYBA2Wk2yln64Cf5trNtlnfrhYggwx0aDGvJaDMoatOkuj3uknaYX)YpWpDaiRA2WojsW0fj34kEPeMwIZ6v)RG6evctljse4Noa45S4eGukFaslJSPiayDasZg7WMCh4d8thGPiPVmQHDc8thaSoatj16SgGPM1z1gGPStLcGhGrx3a)0baRdGCIJ2e4eGFT4eGMiaDfaO)ovvaMPAQ6wbaNNlae0xkacsV3Ezcae7m5Io22ugeMOdSs4C2cHjcdzryIoUO6FrhZS60mPVWztrB(k6ORpSkmAcQqyKgHj6ORpSkmAc6iODP02rhs1TfzaGqaiv3wKxjN1aa5aiZLDHe64IQ)fDyAIk)e5IuZpROcHbBimrhD9HvHrtqhbTlL2o6qQUTiVZIkaqiaPesba7a0R4L6Ljd7soJMzZeaSeas1Tf5vYznaqoa4gazUPdqYaGBaK5Moaqoam0NBoaSeawca2byWrqCjEA1e40ltEqvOx4h6IoUO6FrhyxAw3mPtLqfcdScHj6ORpSkmAc6iODP02rhs1Tf5DwubacbasYeaSdqVIxQxMmSl5mAMntaWsaiv3wKxjN1aa5aGBaK5MoajdaUbqMB6aa5aWqFU5aWsayjayhaCdWGJG4c7sZ6MjDQ0f(HUbGf0Xfv)l6q80QjWPxM8GQqrfcdiHWeD01hwfgnbDwxsrNEt9fE1)MFImoC2Frhxu9VOtVP(cV6FZprgho7VOcHb7IWeDCr1)IoCgn3LkzqhD9HvHrtqfcJuIWeDCr1)IoZF1)Io66dRcJMGkegYnct0Xfv)l6mS)dNj4O4Go66dRcJMGkegPaHj64IQ)fDgk1Ou(9YGo66dRcJMGkegYkdct0Xfv)l6yBgYYKzphmJKUf6ORpSkmAcQqyiRSimrhxu9VOdrt1H9Fy0rxFyvy0euHWq20imrhxu9VOJVc1uu3MfU1Io66dRcJMGkegYYgct0rxFyvy0e0rq7sPTJovlP56ZWTgaSeG0qcDCr1)Io9M6ZxZBZjx(JkegYIvimrhD9HvHrtqhbTlL2o6m4iiUdRl4)Cvw8sJ)c)q3aGDa6v8s9YKHDjNrZYMIuKcjtaWsaWnaKQBlYRKZAaGCaK5kBasgat5mmk9ADtLRwWpd7soJMXQaWsaWoadocIRA5mDQAEqDOwLEnLl4haieG0ba7aiNdWGJG420Fn87npOk0l3m64IQ)fDA6Vg(9MhufkQqyilKqyIo66dRcJMGocAxkTD0r8Vf(HU3bvHAUcsNYOMmb1fv)RBdawcGSba7ai(3c)q37W6c(5N18GQqVuvY71eaiea2qhxu9VOtt)1WV38GQqrfcdzzxeMOJU(WQWOjOJG2LsBhDmLZWO07SOcawcaUbinKcaKdaUbq2aKmam0NBoaSeawca2byWrqCB6Vg(9Mhuf6LBoayhaCdq6aG1bqq6ug1KjOUO6FDBayjaqoauvq6ugnaqiadocIBt)1WV38GQqVuvY71GoUO6FrNzoAtGtVm5bvHIkegYMseMOJU(WQWOjOJG2LsBhDmLZWO0R0dRuVu0Xfv)l6WW5uyuHWqw5gHj6ORpSkmAc6iODP02rhs1Tf5DwubacbasbaYbGuDBVmzZmPs1R452kaqeefaCdaP62EzYMzsLQxXZTvaWcVaWwaWoaKQBlY7SOcaecaKKjaSGoUO6FrhL1z1MjDQeQqyiBkqyIo66dRcJMGocAxkTD0HuDBrENfvaGqayJn0Xfv)l6qQUTxMSABwBkQqyKwgeMOJU(WQWOjOJG2LsBhDe)BHFO7DqvOMRG0PmQjtqDr1)62aaHaiZfsOJlQ(x0zyDb)8ZAEqvOOcHrAzryIo66dRcJMGocAxkTD0b3aORszWjajdaUbqxLYGZLQm6gaihaX)w4h6E5RmzJKBiVuvY71eawcalbacbaRKjayhGbhbXDyDb)NRYIxA8x4h6gaSdG4Fl8dDV8vMSrYnKxUz0Xfv)l6mSUGF(znpOkuuHWiDAeMOJU(WQWOjOJG2LsBhDmZQ1MlNYOLjayHxasJoUO6Frh(kt2i5gsuHWinBimrhxu9VOdSwpROJU(WQWOjOcHrAScHj6ORpSkmAc6iODP02rhZSAT5YPmAzcaw4fG0ba7am4iiUuodzVmz27WAgAVWx4h6IoUO6FrhkNHSxMm7DyndTxyuHWinKqyIo66dRcJMGocAxkTD0PCRU1LYzi7LjZEhwZq7f(QRpSkCaWoadocI7W6c(pxLfV04VCZba7am4iiUuodzVmz27WAgAVWxUz0Xfv)l6unJsZZUvcvimsZUimrhD9HvHrtqhbTlL2o6GBak3QBD7n1NVM3MtU8pxKAEyDb)8Z6vxFyv4aarquak3QBDnZQODBgwTDQkfNRU(WQWbGLaGDagCee3H1f8FUklEPXF5Mrhxu9VOt1mknp7wjuHWiDkryIoUO6FrNH1f8FUkBkAZxrhD9HvHrtqfcJ0Ynct0Xfv)l6WxzYgj3qIo66dRcJMGkegPtbct0rxFyvy0e0rq7sPTJodocIlLZq2ltM9oSMH2l8f(HUOJlQ(x0HYzi7LjZEhwZq7fgvimytgeMOJU(WQWOjOJG2LsBhDgCee3H1f8FUklEPXFHFOBaWoa4gGbhbXDy)h2YzQl8dDdaebrba3am4iiUd7)WwotD5Mda2ba(R7GQErMFImrt1m8xxQsqvdPpSAayjaSGoUO6FrNbv9Im)ezIMQOcHbBYIWeDCr1)IocYop4OMcD01hwfgnbvimylnct0Xfv)l6ii7mupvfD01hwfgnbvimyJneMOJU(WQWOjOJG2LsBhDKZbOCRU1DyDb)NRYIxA8xD9HvHda2bq8Vf(HUx(kt2i5gYlvL8EnbalbGrahaSdaUbqxLYGtasgaCdGUkLbNlvz0naqoa4gaX)w4h6E5RmzJKBiVuvY71eGKbGrahawcalbGLaGfEbGDHe64IQ)fDQMrP5z3kHkegSHvimrhD9HvHrtqhbTlL2o6ORszWjaqiaSjl64IQ)fDCQWxnxpLQBHkegSbjeMOJlQ(x0HYzi7LjZEhwZq7fgD01hwfgnbvOcDMPQ4LgEHWeHHSimrhxu9VOZ8x9VOJU(WQWOjOcHrAeMOJlQ(x0rq25bh1uOJU(WQWOjOcHbBimrhxu9VOJGSZq9uv0rxFyvy0euHkuHoPQut)lcJ0YiBkKjLYKYBA2ytUrhOoD7LXGotHqCtjmGyymfWobiaysQbOLMFAfaINgGPcwjCoBnvbGQq85AQchaZlPbW5QxYlfoacsFzuZnWlh0RgG0StaG4TgU55NwkCaCr1)gGPIPjQ8tKlsn)Sov3aFGhIjn)0sHdq6a4IQ)na22uMBGhDmZQaHrA2vUrNz6t0wfDMoatOkuj3uknaYX)YpWpDaiRA2WojsW0fj34kEPeMwIZ6v)RG6evctljse4Noa45S4eGukFaslJSPiayDasZg7WMCh4d8thGPiPVmQHDc8thaSoatj16SgGPM1z1gGPStLcGhGrx3a)0baRdGCIJ2e4eGFT4eGMiaDfaO)ovvaMPAQ6wbaNNlae0xkacsV3Ezcae7m5g4d8thGPMvvWvkCagkXt1aiEPHxbyOm9AUbaIti05YeG9xSM0PseC2a4IQ)1eGFT4Cd8thaxu9VM7mvfV0WlEew3WpWpDaCr1)AUZuv8sdVsYlbX)Wb(PdGlQ(xZDMQIxA4vsEjCogjDlV6Fd8thGZ6ZgYVca1B4am4iiu4aykVmbyOepvdG4LgEfGHY0Rja(chGzQI1ZFv9YeG2ea4F1BGF6a4IQ)1CNPQ4LgELKxcZ6ZgYVYMYltG3fv)R5otvXln8kjVeZF1)g4Dr1)AUZuv8sdVsYlHGSZdoQPc8UO6Fn3zQkEPHxj5Lqq2zOEQAGpWpDaMAwvbxPWbqtvP4eGQL0auKAaCr90a0Ma4P6T1hw9g4Dr1)A4zMvNMj9foBkAZxd8UO6Fnj5LGPjQ8tKlsn)SkFtWJuDBrcbs1Tf5vYzfYYCzxif4Dr1)AsYlbSlnRBM0PsY3e8iv3wK3zrbHucjS7v8s9YKHDjNrZSzWcP62I8k5SczCL5MojUYCtdzg6ZnZclyp4iiUepTAcC6LjpOk0l8dDd8UO6Fnj5LG4PvtGtVm5bvHkFtWJuDBrENffeGKmy3R4L6Ljd7soJMzZGfs1Tf5vYzfY4kZnDsCL5MgYm0NBMfwWg3bhbXf2LM1nt6uPl8dDzjW7IQ)1KKxcoJM7sLKFDjLxVP(cV6FZprgho7VbExu9VMK8sWz0CxQKjW7IQ)1KKxI5V6Fd8UO6Fnj5Lyy)hotWrXjW7IQ)1KKxIHsnkLFVmbExu9VMK8syBgYYKzphmJKUvG3fv)RjjVeenvh2)Hd8UO6Fnj5LWxHAkQBZc3Ad8UO6Fnj5LO3uF(AEBo5Y)CrQ5H1f8ZpRY3e8QwsZ1NHBflPHuGpWpDaGy0Fn87natOk0amt7N2fobakPUAQknaDfG6F(bW0mBt0cFRaa7soJgaFHdqt)1WV3amOk0am4iicqBcGuBm9YeaCDy2ZzQauKAaiv3wKxjN1aiELGOfTUvaCH4PW9YeG6dqVLUMUWjapraGDjNrdq581Lf5dGVWbO(aaZjnhaLvHAmbqq6ug1eGHs8unat(j3aVlQ(xtsEjA6Vg(9MhufQ8nbVbhbXDyDb)NRYIxA8x4h6IDVIxQxMmSl5mAw2uKIuizWcUKQBlYRKZkKL5kBst5mmk9ADtLRwWpd7soJMXkwWEWrqCvlNPtvZdQd1Q0RPCbFiKgB58GJG420Fn87npOk0l3CG3fv)RjjVen9xd)EZdQcv(MGN4Fl8dDVdQc1CfKoLrnzcQlQ(x3IfzXw8Vf(HU3H1f8ZpR5bvHEPQK3RbcSf4d8tha5ehTjWPxMamusp1(5ObOnby4gfoa)gG9PsUTLlV6FdaU9uhGIudG1lnakRZu1y6FdqrBggLAcqteat5mmknaMwU0a0RGQUrHdWNQsdqrQbW6MkaSjtaQwW3eGNgazHuamQ4xydl3aVlQ(xtsEjM5Onbo9YKhufQ8nbpt5mmk9olkSGBAibzCLnjd95MzHfShCee3M(RHFV5bvHE5MXg30yTG0PmQjtqDr1)6wwGmvfKoLrHWGJG420Fn87npOk0lvL8Enb(a)0bykGZPWbiraMYQB7LjatTTzTPbExu9VMK8sWW5uy5BcEMYzyu6v6HvQxAG3fv)RjjVekRZQnt6uj5BcEKQBlY7SOGaKGmP62EzYMzsLQxXZTfebr4sQUTxMSzMuP6v8CBHfESHnP62I8olkiajzyjW7IQ)1KKxcs1T9YKvBZAtLVj4rQUTiVZIccSXwGpWpDaMyDb)aihYAaMqvObOnbqWrP6wwCcaNrHdq9bq7IuPbGQZwDBdzagufQjad3OWb43ayvJjafPVbG0TebWdWGQqdGG0PmAa8u926dRkFaEAaSp0aORszWja1haD9HvdGCKYeGJKBid8UO6Fnj5LyyDb)8ZAEqvOY3e8e)BHFO7DqvOMRG0PmQjtqDr1)6wiiZfsbExu9VMK8smSUGF(znpOku5BcE4QRszWjjU6QugCUuLrxil(3c)q3lFLjBKCd5LQsEVgwybcyLmyp4iiUdRl4)Cvw8sJ)c)qxSf)BHFO7LVYKnsUH8Ynh4d8tha5qccDnDQQfh5dqrQbaItojheGzA)0UA5snbqo6eGFdGWQEQQ8byYFcGAnQ8baAxKbqxLYGtamZ6cRuta8foacytampTu4amu7dnW7IQ)1KKxc(kt2i5gs5BcEMz1AZLtz0YGfEPd8bExu9VMK8saR1ZAG3fv)RjjVeuodzVmz27WAgAVWY3e8mZQ1MlNYOLbl8sJ9GJG4s5mK9YKzVdRzO9cFHFOBGpW7IQ)1KKxIQzuAE2TsY3e8k3QBDPCgYEzYS3H1m0EHV66dRcJ9GJG4oSUG)ZvzXln(l3m2docIlLZq2ltM9oSMH2l8LBoW7IQ)1KKxIQzuAE2TsY3e8WTCRU1T3uF(AEBo5Y)CrQ5H1f8ZpRxD9HvHHiiQCRU11mRI2Tzy12PQuCU66dRcZc2docI7W6c(pxLfV04VCZbExu9VMK8smSUG)ZvztrB(AG3fv)RjjVe8vMSrYnKbExu9VMK8sq5mK9YKzVdRzO9clFtWBWrqCPCgYEzYS3H1m0EHVWp0nW7IQ)1KKxIbv9Im)ezIMQY3e8gCee3H1f8FUklEPXFHFOl24o4iiUd7)WwotDHFOlebr4o4iiUd7)WwotD5MXg(R7GQErMFImrt1m8xxQsqvdPpSklSe4Dr1)AsYlHGSZdoQPc8UO6Fnj5Lqq2zOEQAG3fv)RjjVevZO08SBLKVj4jNl3QBDhwxW)5QS4Lg)vxFyvySf)BHFO7LVYKnsUH8svjVxdwyeWyJRUkLbNK4QRszW5svgDHmUI)TWp09YxzYgj3qEPQK3RjjJaMfwybl8yxif4Dr1)AsYlHtf(Q56PuDl5BcE6QugCGaBYg4Dr1)AsYlbLZq2ltM9oSMH2lmQqfcba]] )


end