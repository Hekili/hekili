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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 420 end,
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


    spec:RegisterPack( "Brewmaster", 20190610.1033, [[dKKmEaqisbYJabxIuaTjOKprkeJcv0PqfwfPOEfLQzrP0TifzxG6xuIHHeogs0YGcpJuY0qH4AqPABOq6BukQXrkKohPqTokfAEqrUhQ0(GI6GKculKs6HukIlccLpskagjLI0jbHQvIKEjPG0mjfGUjPGANGu)KuqmuOuSukf8uv1ubj7fYFvLbdCyHflQhtYKvYLj2mu9zKA0O0PLSAuOEnkA2ICBs1UL63QmCLQLJ45umDfxhvTDsP(Usz8OGZdIwpuknFqi7NQruIGc9xXiiOXGck1ykyukPaMsk0IrOed0FGCxq)9qXmOf0VdDb9TsKn9Wmcb93ditxSqqH(MJNOe0NDMDJnAXcDnS8zy1PBXu68PyQRvKaFSykDLf0pZxPbI3Om6VIrqqJbfuQXuWOusbmLuOfJqj6h8d7rq)FPBtqF2ATKgLr)LyuOpeCGvISPhMrioqdFntNkeCa7m7gB0If6Ay5ZWQt3IP05tXuxRib(yXu6kl50LTKXdnTeTTSto8kjglydrSHOwglyJn80WxZ8zLiB6HzecSP0vovi4aQ8T4akPWwhGbfuQXoqtoGskSrT0YP6uHGdSjSrtlgB0PcbhOjhydskyWbqmg2LKdSPbr3bHdY1a7uHGd0KdWgEsHdPdUobPdkChuJd2UwJmoyNiAl94aipEhGtoDhOyJQRM2bq8VvyNkeCGMCa2WtkCiRM2bwjYMgX4aZe00cXbAGoOmoOVnheoWSlQksf2gtDTdU9PU2bvBgjwo4WDaBqwQBjlhmNdgwXb7K6i1ajStfcoqtoWge9tBz5a6cFEh(ByL3XGdKEiq6G5CqO9vlhOUgN3uxdJ(PYmgeuO)sWd(0GGcbnLiOq)qn11OVzxcYJn61ZmKIPG(sh5KSqwrdcAmqqH(sh5KSqwrFfPgHub6ZkrAyH3vJdWKdSzS7aSCq1QtVA63k0dA5PLXby2bSsKgwy9GbhOzhWPdOagdhy3bC6akGXWbA2b0KJF3bC4aoCawoiZJJdJFKPWHSA6xMiBWRBRr)qn11O)k03L(XgeD0GGwleuOV0rojlKv0xrQrivG(SsKgw4D14am5aStHdWYbvRo9QPFRqpOLNwghGzhWkrAyH1dgCGMDaNoGcymCGDhWPdOagdhOzhqto(DhWHd4Wby5aoDqMhhhEf67s)ydIo862AhWb6hQPUg9XpYu4qwn9ltKn0GGMrqqH(sh5KSqwr)o0f0VATpvm11Vd)bjF6A0putDn6xT2NkM663H)GKpDnAqqJDeuOFOM6A0F)M6A0x6iNKfYkAqqZOiOq)qn11OFoD36HZtGe9LoYjzHSIge02mck0putDn6NfIrimRMg9LoYjzHSIge0AueuOFOM6A0pv0SJ5Xy(fTU0d6lDKtYczfniO1yeuOFOM6A0hVisoD3c9LoYjzHSIge0usbck0putDn6hTsmdjspvKsOV0rojlKv0GGMskrqH(sh5KSqwrFfPgHub6pLU8M7TkXby2byGD0putDn6xT2ht51fp2ghAqqtjgiOqFPJCswiROVIuJqQa9Z844W5uOyE8ZtD65dEDBTdWYbzECC4ICTHz1Vmr2GjIEuTXbyYb0QfSEWGdWYbvRo9QPFRqpOLNwghGzhqb6hQPUg9lY1gMv)YezdniOPuleuOV0rojlKv0xrQrivG(Q7sRBRHZezZaRydcTyE4Kqn11rYby2bu6aSCaNoyIK0dCofkMVJHxMiBWsh5KSCawoqDxADBnCofkMVJHxMiBWerpQ24am5aTCahOFOM6A0VixByw9ltKn0GGMsgbbf6lDKtYczf9vKAesfOFMhhhUixByw9ltKny(DhGLd40by4an5afBqOfZdNeQPUosoGdhOzhqefBqOfhGjhK5XXHlY1gMv)YezdMi6r1g0putDn6VZtkCiRM(LjYgAqqtj2rqH(sh5KSqwrFfPgHub6BMGMwiW63siXiOFOM6A0NMpil0GGMsgfbf6lDKtYczf9vKAesfOpRePHfExnoatoa7oqZoGvIu10pZoRqey1X3JdGiiYbC6awjsvt)m7ScrGvhFpoaZCDGwoalhWkrAyH3vJdWKdWofoGd0putDn6lmSlPhBq0rdcAkTzeuOV0rojlKv0xrQrivG(SsKgw4D14am5aT0c9d1uxJ(SsKQM(jPIHIGge0uQrrqH(sh5KSqwrFfPgHub6RUlTUTgotKndSIni0I5Htc1uxhjhGjhqbm2r)qn11OFofkMVJHxMiBObbnLAmck0x6iNKfYk6Ri1iKkqFoDG0cHgshy3bC6aPfcnKWeHwAhOzhOUlTUTgMPq)m6HHfMi6r1ghWHd4WbyYbmcfoalhK5XXHZPqX84NN60Zh862AhGLdu3Lw3wdZuOFg9WWcZVJ(HAQRr)CkumFhdVmr2qdcAmOabf6lDKtYczf9vKAesfOVzxsP3eeAzmoaZCDagOFOM6A0NPq)m6HHfniOXGseuOFOM6A0FjZXa6lDKtYczfniOXadeuOV0rojlKv0xrQrivG(MDjLEtqOLX4amZ1by4aSCqMhhhMWByRM(X4yjVTQxWRBRr)qn11OpH3Wwn9JXXsEBvVqdcAm0cbf6lDKtYczf9vKAesfO)ejPhycVHTA6hJJL82QEblDKtYYby5GmpooCofkMh)8uNE(G53DawoiZJJdt4nSvt)yCSK3w1ly(D0putDn6pfTqE7rshniOXGrqqH(sh5KSqwrFfPgHub6ZPdMij9axT2ht51fp2g3ByLxofkMVJbyPJCswoaIGihmrs6b2SlQksVLKkTfcKWsh5KSCahoalhK5XXHZPqX84NN60Zhm)o6hQPUg9NIwiV9iPJge0yGDeuOFOM6A0pNcfZJFEMHumf0x6iNKfYkAqqJbJIGc9d1uxJ(mf6NrpmSOV0rojlKv0GGgdBgbf6lDKtYczf9vKAesfOFMhhhMWByRM(X4yjVTQxWRBRr)qn11OpH3Wwn9JXXsEBvVqdcAm0OiOqFPJCswiROVIuJqQa9Z844W5uOyE8ZtD65dEDBTdWYbC6GmpooCoD3kXBg41T1oaIGihWPdY844W50DReVzG53DawoyDdCMiXW(o8hErK36gyIGtedBKtId4WbCG(HAQRr)mrIH9D4p8IiObbngAmck0putDn6RyRxMNyg0x6iNKfYkAqqRffiOq)qn11OVITEBH2c6lDKtYczfniO1IseuOV0rojlKv0xrQrivG(AqoyIK0dCofkMh)8uNE(GLoYjz5aSCG6U062AyMc9ZOhgwyIOhvBCaMDaTA5aSCaNoqAHqdPdS7aoDG0cHgsyIqlTd0Sd40bQ7sRBRHzk0pJEyyHjIEuTXb2DaTA5aoCahoGdhGzUoGrXo6hQPUg9NIwiV9iPJge0AHbck0x6iNKfYk6Ri1iKkqFPfcnKoatoqlkr)qn11OFqurlV5iePh0GGwlTqqH(HAQRrFcVHTA6hJJL82QEH(sh5KSqwrdAq)DIOo9CmiOqqtjck0x6iNKfYkAqqJbck0x6iNKfYkAqqRfck0x6iNKfYkAqqZiiOqFPJCswiRObbn2rqH(HAQRr)9BQRrFPJCswiRObbnJIGc9d1uxJ(k26L5jMb9LoYjzHSIge02mck0putDn6RyR3wOTG(sh5KSqwrdAqd6RTqm11iOXGck1ykyemOeMsmWad0FliD10g0hIRVFKrwoadheQPU2bPYmgyNk6B2ffcAmyunk6Vto8kjOpeCGvISPhMrioqdFntNkeCa7m7gB0If6Ay5ZWQt3IP05tXuxRib(yXu6kl50LTKXdnTeTTSto8kjglydrSHOwglyJn80WxZ8zLiB6HzecSP0vovi4aQ8T4akPWwhGbfuQXoqtoGskSrT0YP6uHGdSjSrtlgB0PcbhOjhydskyWbqmg2LKdSPbr3bHdY1a7uHGd0KdWgEsHdPdUobPdkChuJd2UwJmoyNiAl94aipEhGtoDhOyJQRM2bq8VvyNkeCGMCa2WtkCiRM2bwjYMgX4aZe00cXbAGoOmoOVnheoWSlQksf2gtDTdU9PU2bvBgjwo4WDaBqwQBjlhmNdgwXb7K6i1ajStfcoqtoWge9tBz5a6cFEh(ByL3XGdKEiq6G5CqO9vlhOUgN3uxd7uDQqWbqmgef)ilhKf8JioqD65yCqwOR2a7anyLs2hJd6R1eBq0X5toiutDTXbxNGe2PgQPU2aVte1PNJHlEkmmDQHAQRnW7erD65ySZ1c(DlNAOM6Ad8oruNEog7CTe806spXux7uHGd(DSByVXbKOwoiZJJllhyMymoil4hrCG60ZX4GSqxTXbrVCWor00(nt10oOmoyDTa7ud1uxBG3jI60ZXyNRfth7g2BEMjgJtnutDTbENiQtphJDUw2VPU2PgQPU2aVte1PNJXoxlk26L5jMXPgQPU2aVte1PNJXoxlk26TfAlovNkeCaeJbrXpYYbI2cbshmLU4GHvCqOMJ4GY4Gq7OsrojWo1qn11gUMDjip2OxpZqkMItnutDTXoxlRqFx6hBq0TTW5YkrAyH3vdMSzSJv1QtVA63k0dA5PLbZSsKgwy9GbnZjfWyyNtkGXqZ0KJFNdoWkZJJdJFKPWHSA6xMiBWRBRDQHAQRn25Ab)itHdz10Vmr2STW5YkrAyH3vdMWofyvT60RM(Tc9GwEAzWmRePHfwpyqZCsbmg25Kcym0mn5435GdS4mZJJdVc9DPFSbrhEDBnho1qn11g7CTWBKxnIUTDOlCRw7tftD97WFqYNU2PgQPU2yNRL9BQRDQHAQRn25AjNUB9W5jq6ud1uxBSZ1swigHWSAANAOM6AJDUwsfn7yEmMFrRl94ud1uxBSZ1cErKC6ULtnutDTXoxlrReZqI0tfPKtnutDTXoxlvR9XuEDXJTX9gw5LtHI57yW2cN7u6YBU3QemJb2DQovi4aio5AdZQDGvIS5GDsDKAG0bBSslAlehuJdM7y6atr3fEPIECWk0dAXbrVCqrU2WSAhKjYMdY844oOmoqVmMQPDaNXIX8MXbdR4awjsdlSEWGduNGJxQs6XbHsDKv10oyohu9iTPgiDWH7GvOh0IdMGP0CyRdIE5G5CWIxF3bcdkXyCGIni0IXbzb)iIdSEwHDQHAQRn25APixByw9ltKnBlCUzECC4Ckump(5Po98bVUTgRmpooCrU2WS6xMiBWerpQ2GjA1cwpyaRQvNE10VvOh0YtldMPWPgQPU2yNRLICTHz1Vmr2STW5QUlTUTgotKndSIni0I5Htc1uxhjmtjwCors6boNcfZ3XWltKnyPJCswyPUlTUTgoNcfZ3XWltKnyIOhvBWKwC4uDQqWbydpPWHSAAhKf2q764joOmoihgz5GRDqFe9ivyBm11oGZcI5GHvCqkgXbcd7eXyQRDWqkAAHyCqH7aZe00cXbMcBfhuTIiHrwo40wioyyfhKcZ4aTOWbtPyACWrCaLy3bgrD9YWbStnutDTXoxl78KchYQPFzISzBHZnZJJdxKRnmR(LjYgm)owCIHMuSbHwmpCsOM66iXHMjIIni0cMY844Wf5AdZQFzISbte9OAJt1PcbhObGpilhyXb2ujsvt7aiwQyOio1qn11g7CTqZhKLTfoxZe00cbw)wcjgXPgQPU2yNRfHHDj9ydIUTfoxwjsdl8UAWe21mRePQPFMDwHiWQJVhicI4KvIu10pZoRqey1X3dM5QfwSsKgw4D1GjStbho1qn11g7CTWkrQA6NKkgkITfoxwjsdl8UAWKwA5uDQqWbwtHIPd0qyWbwjYMdkJdu8eI0tcshWBKLdMZbsnScXbezpjDzyDqMiBghKdJSCW1oijgJdg2ODaBKWDq4Gmr2CGIni0IdcTJkf5KyRdoIds3MdKwi0q6G5CG0rojoqdvODWxpmSo1qn11g7CTKtHI57y4LjYMTfox1DP1T1WzISzGvSbHwmpCsOM66iHjkGXUtnutDTXoxl5uOy(ogEzISzBHZLtPfcnK25uAHqdjmrOLwZQ7sRBRHzk0pJEyyHjIEuTHdoWeJqbwzECC4Ckump(5Po98bVUTgl1DP1T1Wmf6NrpmSW87ovNkeCGgcoU0MsBjbPToyyfhObJnAaDWoPosnf2kghOH(DW1oqLKqBXwhy9(oqsgXwhSvdRdKwi0q6aZU0lHyCq0lhOwghyoYilhKL0T5ud1uxBSZ1ctH(z0ddRTfoxZUKsVji0YyWmxmCQo1qn11g7CTSK5yWP6ud1uxBSZ1cH3Wwn9JXXsEBvVSTW5A2Lu6nbHwgdM5IbwzECCycVHTA6hJJL82QEbVUT2PgQPU2yNRLPOfYBps62w4CNij9at4nSvt)yCSK3w1lyPJCswyL5XXHZPqX84NN60Zhm)owzECCycVHTA6hJJL82QEbZV7ud1uxBSZ1Yu0c5ThjDBlCUCors6bUATpMYRlESnU3WkVCkumFhdWsh5KSGiiAIK0dSzxuvKEljvAleiHLoYjzXbwzECC4Ckump(5Po98bZV7ud1uxBSZ1sofkMh)8mdPyko1qn11g7CTWuOFg9WW6ud1uxBSZ1cH3Wwn9JXXsEBvVSTW5M5XXHj8g2QPFmowYBR6f862ANAOM6AJDUwYejg23H)WlIyBHZnZJJdNtHI5Xpp1PNp41T1yXzMhhhoNUBL4nd862AicI4mZJJdNt3Ts8MbMFhR1nWzIed77WF4frERBGjcormSrojCWHtnutDTXoxlk26L5jMXPgQPU2yNRffB92cTfNAOM6AJDUwMIwiV9iPBBHZvdAIK0dCofkMh)8uNE(GLoYjzHL6U062AyMc9ZOhgwyIOhvBWmTAHfNsleAiTZP0cHgsyIqlTM5uDxADBnmtH(z0ddlmr0JQn2Pvlo4GdmZLrXUtnutDTXoxlbrfT8MJqKESTW5kTqOHetArPtnutDTXoxleEdB10pghl5Tv9cnObHaa]] )


end