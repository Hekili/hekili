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
            copy = "breath_of_fire"
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

                if debuff.keg_smash.up then applyDebuff( "target", "breath_of_fire_dot" ) end
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

        potion = "superior_battle_potion_of_agility",

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


    spec:RegisterPack( "Brewmaster", 20190920, [[dWudIaqiOi1JGIAtisFcksgfQkNcvvRcQQELOYSiv1TeLODPWVefddrCmsfltQYZivAAqvPRbvPTrQcFdkcJdQcohPkTorj18ev5EiQ9jQQdcvfzHsv9qOiQjcvfvxuus(OOeyKIsOtcvHwjk5LIsqZKufv3KufPDcL6NKQOmuOQWsHIipvrtfkCvOQO8vsve2lO)sPbd5WuTyP8ysMSQCzInRQ(mQmAeoTsRgLsVgvz2ICBsz3Q8BGHlvooPkIwospNIPl56Oy7Is9DOY4HsopkvRhQIMpkf7xyOoqmGZNxce7EKOJEjrV9izOdj90fol27e4SZv8CobopxtGZ(ubNMBkHcNDo7jG)GyaNgadvjWjrvDMSotgUTiyAdfqlJz1ysETGtr9FLXSAQmWzJztfE8Gn485LaXUhj6Oxs0Bpsg6qsVE4ftaNotraOW5C1WKHtI99Kd2GZNyuWjMduFQGtZnLqdKEk44fSWCGiQQZK1zYWTfbtBOaAzmRgtYRfCkQ)RmMvtLjyH5anLUs0Acnq9ir)a1JeD0BWkyH5aHjt4hNyY6GfMduwgimjj5yfOScRojfOSOt1cKhO2wJGfMduwgi8bdD)ShiWLypq7pqBfiCGdtvbQJkzlxfi2bmb6tbAbsr47ThxGWJZ(d4mTMYaXaoFY3zsfedi26aXaoDvTGdonDItTe(9SMIU8e4uoVLKhSpSGy3dIbCkN3sYd2hov0Te66WjH4PIiq5ficXtfXqZXkq4pqKm0d8cNUQwWbNC7VSGVTielalybXwxigWPCEljpyF4ur3sORdNeINkIrNQcuEbctG3arAG2tb02JZ(CnNtS6Acu(bIq8urm0CSce(deFbIKrVaLlq8fisg9ce(dehfW0fi(de)bI0a1y()XhqR9Z(EC2gvWnEaChC6QAbhC(CTo5SeovdwqSXxigWPCEljpyF4ur3sORdNeINkIrNQcuEbcVKeisd0EkG2EC2NR5CIvxtGYpqeINkIHMJvGWFG4lqKm6fOCbIVarYOxGWFG4OaMUaXFG4pqKgi(cuJ5)hpxRtolHt1gpaUlq8dNUQwWbNFaT2p77XzBubhSGyJxigWPCEljpyF40v1co40nez7NySuhpbuRcq9eCQOBj01HZN0y()b1Xta1QaupzFsJ5)hpaUlqSHnb6jnM)FOa3JrvB2IDpE2N0y()btxGinqLt5KAqiEQigDQkq5fiD1jqSHnbQwnXwa7BLaLxG6rcCEUMaNUHiB)eJL64jGAvaQNGfeB9aIbC6QAbhCYye7wIMboLZBj5b7dli2ycigWPRQfCWzhOwWbNY5TK8G9HfeB8aed40v1co4SLaGN9ZqzhoLZBj5b7dli26fIbC6QAbhC2eQrO82JdoLZBj5b7dli26qced40v1co4mTCeLXYwMhNMCfCkN3sYd2hwqS1rhigWPRQfCW5FPslbap4uoVLKhSpSGyRtpigWPRQfCWPFkXuupzvEkbNY5TK8G9HfeBD0fIbCkN3sYd2hov0Te66WzTAITa23kbk)a1dVWPRQfCW5Ezd4j2BzWthali26GVqmGt58wsEW(WPIULqxhoBm))OLCfpatzvaTgy8a4UarAG2tb02JZ(CnNtS6Ox9QxntGYpq8ficXtfXqZXkq4pqKm0jq5cKPCooHosUPS1Q4zFUMZjw8nq8hisduJ5)hsIXSzl2g1XLe6WuUIxGYlq9cePbcthOgZ)pwk4m82Z2OcUbthC6QAbhCUuWz4TNTrfCWcITo4fIbCkN3sYd2hov0Te66WPcaspaUB0OcoZqr4uoXy)uxvl48uGYpq6eisdKcaspaUB0sUINfGLTrfCdQO57zcuEbsx40v1co4CPGZWBpBJk4GfeBD0digWPCEljpyF4ur3sORdNMY54e6Otvbk)aXxG6H3aH)aXxG0jq5cehfW0fi(de)bI0a1y()XsbNH3E2gvWny6cePbIVa1lqzzGueoLtm2p1v1copfi(de(devueoLtcuEbQX8)JLcodV9SnQGBqfnFpdC6QAbhC2Xq3p77XzBubhSGyRdMaIbCkN3sYd2hov0Te66WPPCooHo0apH6LaNUQwWbNCmo9bli26GhGyaNY5TK8G9HtfDlHUoCsiEQigDQkq5fi8gi8hicXt7XznDecvgkaZvbInSjq8ficXt7XznDecvgkaZvbkFYbs3arAGiepveJovfO8ceEjjq8dNUQwWbNcwDsYs4unybXwh9cXaoLZBj5b7dNk6wcDD4Kq8urm6uvGYlq6QlC6QAbhCsiEApoRKwSwkSGy3JeigWPCEljpyF4ur3sORdNkai9a4UrJk4mdfHt5eJ9tDvTGZtbkVarYaVWPRQfCWzl5kEwaw2gvWbli290bIbCkN3sYd2hov0Te66WjFbsoHYXEGYfi(cKCcLJ9bv4Klq4pqkai9a4UbpHZA0CdXGkA(EMaXFG4pq5fi8LKarAGAm))OLCfpatzvaTgy8a4UarAGuaq6bWDdEcN1O5gIbthC6QAbhC2sUINfGLTrfCWcIDVEqmGt58wsEW(WPIULqxhonDskzlNYjLjq5toq9Gtxvl4GtEcN1O5gcybXUNUqmGtxvl4GZNuaSGt58wsEW(WcIDp8fIbCkN3sYd2hov0Te66WPPtsjB5uoPmbkFYbQxGinqnM)Fqzme7XzzR)elU9EJha3bNUQwWbNugdXECw26pXIBVhSGy3dVqmGt58wsEW(WPIULqxholpjxnOmgI94SS1FIf3EVHCEljVarAGAm))OLCfpatzvaTgyW0fisduJ5)hugdXECw26pXIBV3GPdoDvTGdoRLtO2opPbli290digWPCEljpyF4ur3sORdN8fOYtYvJ9YgWtS3YGNoWweITLCfplaRHCEljVaXg2eOYtYvdtNOwpzFsAZwOSpKZBj5fi(dePbQX8)JwYv8amLvb0AGbthC6QAbhCwlNqTDEsdwqS7HjGyaNY5TK8G9HtfDlHUoC2y()b3(ll4BlcXcWAykxXlq5hi8foDvTGdofS6KKLWPAWcIDp8aed40v1co4SLCfpatznfD5jWPCEljpyFybXUNEHyaNUQwWbN8eoRrZneWPCEljpyFybXwxsGyaNY5TK8G9HtfDlHUoC(a1qboLCf1l5z)jxtgurZ3ZeiYbIe40v1co4uboLCf1l5z)jxtGfeBD1bIbCkN3sYd2hov0Te66WjMoqIXiNsgfHyvug12sIf8T)KRjdnNTakC6QAbhCsioTSIXiNsGfeBD7bXaoLZBj5b7dNk6wcDD4SX8)dU9xwW3weIfG1WuUIxGYNCG0foDvTGdofS6KKLWPAWcITU6cXaoLZBj5b7dNk6wcDD4SX8)dkJHypolB9NyXT3B8a4o40v1co4KYyi2JZYw)jwC79GfeBDXxigWPCEljpyF4ur3sORdNnM)F0sUIhGPSkGwdmEaCxGinq8fOgZ)pAja4Lym14bWDbInSjq8fOgZ)pAja4Lym1GPlqKgOhOgnQ4fHf8T)Lk2hOgu5tfdH3ssG4pq8dNUQwWbNnQ4fHf8T)LkWcITU4fIbC6QAbhCQiwBJHAk4uoVLKhSpSGyRREaXaoDvTGdoveRfNNTaNY5TK8G9HfeBDXeqmGt58wsEW(WPIULqxhoBm))GB)Lf8TfHybynmLR4fO8jhOEWPRQfCWPGvNKSeovdwqS1fpaXaoLZBj5b7dNk6wcDD4ethOYtYvJwYv8amLvb0AGHCEljVarAGuaq6bWDdEcN1O5gIbv089mbk)aXPEbI0aXxGKtOCShOCbIVajNq5yFqfo5ce(deFbsbaPha3n4jCwJMBigurZ3ZeOCbIt9ce)bI)aXFGYNCG0d8cNUQwWbN1YjuBNN0GfeBD1led4uoVLKhSpCQOBj01Ht5ekh7bkVaPRoWPRQfCWPtv(j2cqPYvWcIn(sced40v1co4KYyi2JZYw)jwC79Gt58wsEW(WcwWzhvuaTMxqmGyRded40v1co4Sdul4Gt58wsEW(WcIDpigWPRQfCWPIyTngQPGt58wsEW(WcITUqmGtxvl4GtfXAX5zlWPCEljpyFyblybNzluZcoi29irh9scEqhsGtCo92JZaN6jWNWKWgpIDwqwhOaHbHeOvRdqRa9b0aHPEY3zsfMkqurpjZsLxGmanjqotb08sEbsr4hNygbl989Ka1lRde(SZW01bOL8cKRQfCbctXT)Yc(2IqSaSWuJGvWcpQ1bOL8cuVa5QAbxGsRPmJGfCA6efe7E6bEao7OG)Me4eZbQpvWP5MsObspfC8cwyoqev1zY6mz42IGPnuaTmMvJj51cof1)vgZQPYeSWCGMsxjAnHgOEKOFG6rIo6nyfSWCGWKj8JtmzDWcZbkldeMKKCScuwHvNKcuw0PAbYduBRrWcZbklde(GHUF2de4sShO9hOTceoWHPQa1rLSLRce7aMa9PaTaPi892Jlq4Xz)rWkyH5aLvyjkMsEbQjFavcKcO18kqnHBpZiq4tkL0vMaDGlljCQ2Njfixvl4mbcCj2hblmhixvl4mJoQOaAnVi)tUHxWcZbYv1coZOJkkGwZRCKZ8bGxWcZbYv1coZOJkkGwZRCKZ4mCAYvETGlyH5anpVZqaQar99fOgZ)lVazkVmbQjFavcKcO18kqnHBptG87fOoQKLDGQ2JlqRjqpWjJGfMdKRQfCMrhvuaTMx5iNXCENHauwt5Ljy5QAbNz0rffqR5voYz6a1cUGLRQfCMrhvuaTMx5iNrrS2gd1ublxvl4mJoQOaAnVYroJIyT48SLGvWcZbkRWsumL8cKKTqzpq1QjbQiKa5Qcqd0AcKNTVjVLKrWYv1codztN4ulHFpRPOlpjy5QAbNjh5mC7VSGVTielal93pzcXtfrEeINkIHMJf(jzOh4ny5QAbNjh5mpxRtolHt10F)KjepveJovLhMaVKUNcOThN95AoNy11KpH4PIyO5yHF(iz0lhFKm6HFokGPJF(jTX8)JpGw7N994SnQGB8a4UGLRQfCMCKZ8b0A)SVhNTrfC6VFYeINkIrNQYdVKq6EkG2EC2NR5CIvxt(eINkIHMJf(5JKrVC8rYOh(5OaMo(5Nu(Am))45ADYzjCQ24bWD8hSCvTGZKJCggJy3s00)CnHSBiY2pXyPoEcOwfG6j93p5N0y()b1Xta1QaupzFsJ5)hpaUJnS5jnM)FOa3JrvB2IDpE2N0y()bthPLt5KAqiEQigDQkpD1HnSPwnXwa7BL86rsWYv1cotoYzymIDlrZeSCvTGZKJCMoqTGly5QAbNjh5mTea8SFgk7blxvl4m5iNPjuJq5ThxWYv1cotoYzslhrzSSL5XPjxfSCvTGZKJCM)sLwcaEblxvl4m5iNXpLykQNSkpLcwUQwWzYroZEzd4j2BzWthylcX2sUINfGL(7NCTAITa23k53dVbRGfMdeEKcodV9cuFQGlqD0fq3I9aHJqojBHgOTcuba8cKz5U9Vk)Qa9CnNtcKFVaTuWz4TxGAubxGAm)FGwtG0wJzpUaXN)ylJPcuribIq8urm0CScKci))Qw5Qa5kfG(2Jlqfiq7vYz2I9ab(b65AoNeOY5jh)6hi)EbQab6XO1fiblLymbsr4uoXeOM8bujq9b9hblxvl4m5iNzPGZWBpBJk40F)KBm))OLCfpatzvaTgy8a4os3tb02JZ(CnNtS6Ox9Qxnt(8riEQigAow4NKHo5mLZXj0rYnLTwfp7Z1CoXIV8tAJ5)hsIXSzl2g1XLe6WuUIxE9ift3y()XsbNH3E2gvWny6cwUQwWzYroZsbNH3E2gvWP)(jRaG0dG7gnQGZmueoLtm2p1v1copLVoKQaG0dG7gTKR4zbyzBub3GkA(EM80nyfSWCGWhm09Z(ECbQjeE2lGHgO1eOMBKxGaxGoavZtlE61cUaX3MvbQiKaL8scKGvhvmMfCbQOlhNqnbA)bYuohNqdKzXtjq7POIBKxGazl0avesGsUPcKUKeOAv8mbcqdKo4nqgrbUNH)rWYv1cotoYz6yO7N994SnQGt)9t2uohNqhDQkF(6Hx8ZNo54OaMo(5N0gZ)pwk4m82Z2OcUbthP81llveoLtm2p1v1copXp(PIIWPCsEnM)FSuWz4TNTrfCdQO57zcwblmhOSagN(cuMaLffpThxGYQ0I1sdwUQwWzYrodhJtF6VFYMY54e6qd8eQxsWYv1cotoYzeS6KKLWPA6VFYeINkIrNQYdV4Nq80ECwthHqLHcWCfBydFeIN2JZA6ieQmuaMRYNSUKsiEQigDQkp8sc)blxvl4m5iNHq80ECwjTyTu93pzcXtfXOtv5PRUbRGfMdu)KR4fi9mScuFQGlqRjqkgkvUkXEGymYlqfiqYwecnquPlj3AicuJk4mbQ5g5fiWfOKymbQi8lqeE6hipqnQGlqkcNYjbYZ23K3sI(bcqducGlqYjuo2dubcKCEljbklu4c0uZneblxvl4m5iNPLCfplalBJk40F)Kvaq6bWDJgvWzgkcNYjg7N6QAbNNYJKbEdwUQwWzYrotl5kEwaw2gvWP)(jZNCcLJ9C8jNq5yFqfo5WVcaspaUBWt4Sgn3qmOIMVNHF(ZdFjH0gZ)pAjxXdWuwfqRbgpaUJufaKEaC3GNWznAUHyW0fScwyoq6z)VCMnBjXU(bQiKaHpHp0ZduhDb0Tw8umbklCgiWfivs8Sf9duFWmqsYi6hiCBrei5ekh7bY0j3tOMa53lqQNjqgaTKxGAscGly5QAbNjh5m8eoRrZne6VFYMojLSLt5KYKp5EbRGLRQfCMCKZ8KcGvWYv1cotoYzOmgI94SS1FIf3Ep93pztNKs2YPCszYNCpsBm))GYyi2JZYw)jwC79gpaUlyfSCvTGZKJCMA5eQTZtA6VFYLNKRgugdXECw26pXIBV3qoVLKhPnM)F0sUIhGPSkGwdmy6iTX8)dkJHypolB9NyXT3BW0fSCvTGZKJCMA5eQTZtA6VFY8vEsUASx2aEI9wg80b2IqSTKR4zbynKZBj5Xg2uEsUAy6e16j7tsB2cL9HCEljp(jTX8)JwYv8amLvb0AGbtxWYv1cotoYzeS6KKLWPA6VFYnM)FWT)Yc(2IqSaSgMYv8YhFdwUQwWzYrotl5kEaMYAk6YtcwUQwWzYrodpHZA0CdrWYv1cotoYzuGtjxr9sE2FY1e93p5hOgkWPKROEjp7p5AYGkA(EgYKeSCvTGZKJCgcXPLvmg5uI(7NmMwmg5uYOieRIYO2wsSGV9NCnzO5SfqdwUQwWzYroJGvNKSeovt)9tUX8)dU9xwW3weIfG1WuUIx(K1ny5QAbNjh5mugdXECw26pXIBVN(7NCJ5)hugdXECw26pXIBV34bWDblxvl4m5iNPrfViSGV9Vur)9tUX8)JwYv8amLvb0AGXdG7iLVgZ)pAja4Lym14bWDSHn81y()rlbaVeJPgmDK(a1OrfViSGV9VuX(a1GkFQyi8ws4N)GLRQfCMCKZOiwBJHAQGLRQfCMCKZOiwlopBjyH5aLvy1jPaLfDQwGiCtGiwocHgi854JScJave(fimWhbchHCbIDatGi8SLa5vGsIBQa1lqaAZmcwUQwWzYroJGvNKSeovt)9tUX8)dU9xwW3weIfG1WuUIx(K7fSCvTGZKJCMA5eQTZtA6VFYy6YtYvJwYv8amLvb0AGHCEljpsvaq6bWDdEcN1O5gIbv089m5ZPEKYNCcLJ9C8jNq5yFqfo5WpFkai9a4UbpHZA0CdXGkA(EMCCQh)8ZF(K1d8gSCvTGZKJCgNQ8tSfGsLR0F)KLtOCSNNU6eSCvTGZKJCgkJHypolB9NyXT3dwWccb]] )


end