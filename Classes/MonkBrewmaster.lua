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

        light_brewing = 22099, -- 325093
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
        exploding_keg = 22103, -- 325153

        high_tolerance = 22106, -- 196737
        celestial_flames = 22104, -- 325177
        blackout_combo = 22108, -- 196736
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        admonishment = 843, -- 207025
        avert_harm = 669, -- 202162
        craft_nimble_brew = 670, -- 213658
        double_barrel = 672, -- 202335
        eerie_fermentation = 765, -- 205147
        guided_meditation = 668, -- 202200
        hot_trub = 667, -- 202126
        incendiary_breath = 671, -- 202272
        microbrew = 666, -- 202107
        mighty_ox_kick = 673, -- 202370
        niuzaos_essence = 1958, -- 232876
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
        celestial_brew = {
            id = 322507,
            duration = 8,
            max_stack = 1,
        },
        celestial_flames = {
            id = 325190,
            duration = 6,
            max_stack = 1,
        },
        celestial_fortune = {
            id = 216519,
        },
        chi_torpedo = {
            id = 119085,
            duration = 10,
            max_stack = 2,
        },
        clash = {
            id = 128846,
            duration = 4,
            max_stack = 1,
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
        exploding_keg = {
            id = 325153,
            duration = 3,
            max_stack = 1,
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
            duration = 3600,
            max_stack = 10,
        },
        guard = {
            id = 115295,
            duration = 8,
            max_stack = 1,
        },
        invoke_niuzao_the_black_ox = {
            id = 132578,
            duration = 25,
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
            id = 113746,
            duration = 3600,
            max_stack = 1,
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
        purified_chi = {
            id = 325092,
            duration = 15,
            max_stack = 10,
        },
        rushing_jade_wind = {
            id = 116847,
            duration = function () return 9 * haste end,
            max_stack = 1,
        },
        shuffle = {
            id = 215479,
            duration = 7.11,
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
        touch_of_death = {
            id = 325095,
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
            duration = function () return talent.bob_and_weave.enabled and 13 or 10 end,
            unit = "player",
        },
        moderate_stagger = {
            id = 124274,
            duration = function () return talent.bob_and_weave.enabled and 13 or 10 end,
            unit = "player",
        },
        heavy_stagger = {
            id = 124273,
            duration = function () return talent.bob_and_weave.enabled and 13 or 10 end,
            unit = "player",
        },

        --[[ ironskin_brew_icd = {
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
        }, ]]


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
        if healing_sphere.count > 0 then
            applyBuff( "gift_of_the_ox", nil, healing_sphere.count )
        end
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
                if health.current == 0 then return 100 end
                return ceil( 100 * t.tick / health.current )

            elseif k == 'tick' then
                if t.ticks_remain == 0 then return 0 end
                return t.amount / t.ticks_remain

            elseif k == 'ticks_remain' then
                return floor( stagger.remains / 0.5 )

            elseif k == 'amount' or k == 'amount_remains' then
                t.amount = UnitStagger( 'player' )
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
                setCooldown( "celestial_brew", 0 )
                gainCharges( "purifying_brew", class.abilities.purifying_brew.charges )                
            end,
        },


        blackout_kick = {
            id = 205523,
            cast = 0,
            charges = 1,
            cooldown = 4,
            recharge = 4,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 574575,

            handler = function ()
                applyBuff( "shuffle" )

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

                if debuff.keg_smash.up then applyDebuff( "target", "breath_of_fire_dot" ) end
                addStack( "elusive_brawler", 10, active_enemies * ( 1 + set_bonus.tier21_2pc ) )                
            end,
        },


        celestial_brew = {
            id = 322507,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1360979,

            toggle = "defensives",
            
            handler = function ()
                removeBuff( "purified_chi" )
                applyBuff( "celestial_brew" )
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


        clash = {
            id = 324312,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 628134,
            
            handler = function ()
                setDistance( 5 )
                applyDebuff( "target", "clash" )
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

            start = function ()
                removeBuff( "the_emperors_capacitor" )
                applyDebuff( "target", "crackling_jade_lightning" )
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
            id = 322101,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 15,
            spendType = "energy",

            startsCombat = true,
            texture = 627486,

            usable = function ()
                if ( settings.eh_percent > 0 and health.pct > settings.eh_percent ) then return false, "health is above " .. settings.eh_percent .. "%" end
                return true
            end,
            handler = function ()
                gain( ( healing_sphere.count * stat.attack_power ) + stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )
                removeBuff( "gift_of_the_ox" )
                healing_sphere.count = 0
            end,
        },


        exploding_keg = {
            id = 325153,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",
            talent = "exploding_keg",

            startsCombat = true,
            texture = 644378,
            
            handler = function ()
                applyDebuff( "target", "exploding_keg" )
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


        --[[ guard = {
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
        }, ]]


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


        --[[ ironskin_brew = {
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
        }, ]]


        keg_smash = {
            id = 121253,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 594274,

            handler = function ()
                applyDebuff( "target", "keg_smash" )
                active_dot.keg_smash = active_enemies

                applyBuff( "shuffle" )

                setCooldown( "celestial_brew", max( 0, cooldown.celestial_brew.remains - ( 4 + ( buff.blackout_combo.up and 2 or 0 ) + ( buff.bonedust_brew.up and 1 or 0 ) ) ) )
                setCooldown( "fortifying_brew", max( 0, cooldown.fortifying_brew.remains - ( 4 + ( buff.blackout_combo.up and 2 or 0 ) + ( buff.bonedust_brew.up and 1 or 0 ) ) ) )
                gainChargeTime( "purifying_brew", 4 + ( buff.blackout_combo.up and 2 or 0 ) +  ( buff.bonedust_brew.up and 1 or 0 ) )

                if buff.weapons_of_order.up then
                    applyDebuff( "target", "weapons_of_order_debuff", nil, min( 5, debuff.weapons_of_order_debuff.stack + 1 ) )
                end

                removeBuff( "blackout_combo" )
                addStack( "elusive_brawler", nil, 1 )
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
            charges = 2,
            cooldown = function () return ( 15 - ( talent.light_brewing.enabled and 3 or 0 ) ) * haste end,
            recharge = function () return ( 15 - ( talent.light_brewing.enabled and 3 or 0 ) ) * haste end,
            gcd = "off",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 133701,

            usable = function ()
                if stagger.pct == 0 then return false, "no damage is staggered" end
                if settings.purify_stagger > 0 then
                    if stagger.pct < settings.purify_stagger * ( group and 1 or 0.5 ) then return false, "stagger pct " .. stagger.pct .. " less than purify_stagger setting " .. ( settings.purify_stagger * ( group and 1 or 0.5 ) ) end
                end
                return true
            end,

            handler = function ()
                if buff.blackout_combo.up then
                    addStack( 'elusive_brawler', 10, 1 )
                    removeBuff( 'blackout_combo' )
                end

                local reduction = 0.5
                stagger.amount = stagger.amount * ( 1 - reduction )
                stagger.tick = stagger.tick * ( 1 - reduction )

                applyBuff( "purified_chi" )
            end,

            copy = "brews"
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


        spinning_crane_kick = {
            id = 322729,
            cast = 1.5,
            channeled = true,
            cooldown = 0,
            gcd = "spell",
            
            spend = 25,
            spendType = "energy",
            
            startsCombat = true,
            texture = 606543,
            
            start = function ()
                applyBuff( "shuffle" )
                
                if talent.celestial_flames.enabled then
                    applyDebuff( "target", "breath_of_fire_dot" )
                    active_dot.breath_of_fire_dot = active_enemies
                end
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
                gainChargeTime( 'celestial_brew', debuff.bonedust_brew.up and 2 or 1 )
                gainChargeTime( 'purifying_brew', debuff.bonedust_brew.up and 2 or 1 )

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

            start = function ()
                applyBuff( "zen_meditation" )
            end,
        },


        -- Monk - Kyrian    - 310454 - weapons_of_order     (Weapons of Order)
        -- TODO:  Effects of WoO for each spec.
        weapons_of_order = {
            id = 310454,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "essences",
            
            startsCombat = false,
            texture = 3565447,

            handler = function ()
                applyBuff( "weapons_of_order" )

                if state.spec.mistweaver then
                    setCooldown( "essence_font", 0 )
                end
            end,

            auras = {
                weapons_of_order = {
                    id = 310454,
                    duration = 30,
                    max_stack = 1
                },
                weapons_of_order_debuff = {
                    id = 312106,
                    duration = 8,
                    max_stack = 5
                },
                weapons_of_order_buff = {
                    id = 311054,
                    duration = 5,
                    max_stack = 1
                }
            }
        },

        -- Monk - Necrolord - 325216 - bonedust_brew        (Bonedust Brew)
        bonedust_brew = {
            id = 325216,
            cast  = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "essences",

            startsCombat = true,
            texture = 3578227,

            handler = function ()
                applyDebuff( "target", "bonedust_brew" )
            end,

            auras = {
                bonedust_brew = {
                    id = 325216,
                    duration = 10,
                    max_stack = 1
                }
            }
        },

        -- Monk - Night Fae - 327104 - faeline_stomp        (Faeline Stomp)
        faeline_stomp = {
            id = 327104,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 3636842,

            toggle = "essences",
            
            handler = function ()
                applyBuff( "faeline_stomp" )

                if spec.brewmaster then
                    applyDebuff( "target", "breath_of_fire" )
                    active_dot.breath_of_fire = active_enemies
                end
            end,

            auras = {
                faeline_stomp = {
                    id = 327104,
                    duration = 30,
                    max_stack = 1,
                },        
            }
        },

        -- Monk - Venthyr   - 326860 - fallen_order         (Fallen Order)
        fallen_order = {
            id = 326860,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            startsCombat = false,
            texture = 3565721,

            toggle = "essences",

            handler = function ()
                applyBuff( "fallen_order" )
            end,

            auras = {
                fallen_order = {
                    id = 326860,
                    duration = 24,
                    max_stack = 1
                }
            }
        }

        
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

    --[[ spec:RegisterSetting( "isb_overlap", 1, {
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
    } ) ]]

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


    spec:RegisterPack( "Brewmaster", 20200926, [[dyuFDaqisO0JivYMavnksWPiuTksiVsiMfPIBrcfTlv5xIsddrCmeLLjKEgHY0ar5AGkTnqeFJeQghisohPsToePKMhOI7bs7JuLdIivAHIkpeePQjIiL4IisXijHcNerQQvsiVerQYmbrQCtePIDkQ6NisPgkis5PImvrXEL6VumyIomvlwHhd1Kv0LrTzv1NjPrJWPvz1isEnjA2cUnPSBL(nWWfQLJ0ZP00LCDc2oi47GY4ruDEsvTEqunFqO9d5MSotNMEXD(OKeLes0Dui5rgzIP7O6UtL(XCNIDSsxL706ACNYrzyAUTyANID9daF2z6KfiqXCNiQk2sAnBw1RiegpmqlR90ecEDGft9FL1EA4SDAiCHI0F7rNMEXD(OKeLes0Dui5rgzIP7OqsNCHIaq7u60G03jIBo5ThDAYwCN0fsMJYW0CBXuKK0bSkrI0fsM44I1gmfjJcj6GKrjjkjDkC2Y2z60K)UqO6mDEY6mDYX1b2ozJzNAi8DASf9uYDIxFe4zNRRoF0otN41hbE256eMEftpVteShkIxmUqs4GKkoCrs4rYBXaTBvntxZvzJywKupKKG9qr80CYrsfHKkGKK8IIKrqsfqssErrsfHKQuGqmskoskoscpsoe()3hqR7R)TQMbLH9MayBNCCDGTttxlMxdHt16QZlwNPt86Jap7CDctVIPN3jc2dfXlgxijCqs4scscpsElgODRQz6AUkBeZIK6HKeShkINMtosQiKubKKKxuKmcsQassYlksQiKuLceIrsXrsXrs4rsfqYHW))MUwmVgcNQ9MaylskENCCDGTtFaTUV(3QAgugwxDEiRZ0jE9rGNDUo546aBNClbe8LTgQd5aQbdOEOty6vm98on5HW))OoKdOgmG6bZKhc))BcGTijeHiso5HW))WGDkGRdcS5wLMjpe()NqmscpswovLRhb7HI4fJlKeoiPyKHKqeIizDASPaM5XijCqYOK0P114o5wci4lBnuhYbudgq9qxDE42z6KJRdSDsWYMRynBN41hbE256QZdjDMo546aBNIb1b2oXRpc8SZ1vNxX7mDYX1b2oncaW08fO63jE9rGNDUU68qQotNCCDGTtdMAzQYBv7eV(iWZoxxDED3z6KJRdSDkCQeL1qkHPQgVvN41hbE256QZtgjDMo546aBN(hLhbay2jE9rGNDUU68KrwNPtoUoW2jFXSTOEWG9qOt86Jap7CD15jlANPt86Jap7CDctVIPN3P60ytbmZJrs9qYOWTtoUoW2PBHaqjB2taYDqxDEYeRZ0jE9rGNDUoHPxX0Z70q4)FXc07F80GjUNqmscpsoe()3i4yLaHYGbAdWBcGTij8i5TyG2TQMPR5QSHmDRBDRzrs9qss6KJRdSDcZb2wNhmdkdRRopzqwNPt86Jap7CDctVIPN3jB5QQm9fJlKupKubKmkCrsfHKkGKKHKrqsvkqigjfhjfhjHiersmHtvzlsQhssgscpsoe()hMdSTopygug2BcGTij8i5q4)FXc07F80GjU3eaB7KJRdSDkwGEF9Vv1mOmSU68Kb3otN41hbE256eMEftpVteShkIxmUqs4GKWfjvessWE4wvJnMGP8dde2cjHiersfqsc2d3QASXemLFyGWwiPEqrsXqs4rsc2dfXlgxijCqs4scskENCCDGTtm5XCWq4uTU68KbjDMoXRpc8SZ1jm9kMEENiypueVyCHKWbjftSo546aBNiypCRQHdh5hTRopzkENPt86Jap7CDctVIPN3jmaeMay7Bqzy2hMWPQS18PoUoW6bKeoijjp42jhxhy70i4yLga5MbLH1vNNmivNPt86Jap7CDctVIPN3jfqsEzQQ(izeKubKKxMQQ)JYQ8IKkcjXaqycGTpLSQXQ5wIhL18BTiP4iP4ijCqsiJeKeEKCi8)VrWXkbcLbd0gG3eaBrs4rsmaeMay7tjRASAUL4je3jhxhy70i4yLga5MbLH1vNNmD3z6eV(iWZoxNW0Ry65DYgZHGPCQkxwKupOiz0o546aBNuYQgRMBj6QZhLKotNCCDGTttUaK3jE9rGNDUU68rjRZ0jE9rGNDUoHPxX0Z7KnMdbt5uvUSiPEqrYOij8i5q4)FublXTQgs5t2a725BcGTDYX1b2orfSe3QAiLpzdSBND15JgTZ0jhxhy70aS8uWwMbLH1jE9rGNDUU68rfRZ0jhxhy703dbEna6KPDIxFe4zNRRoFuiRZ0jhxhy7035WTSXwaT4oXRpc8SZ1vNpkC7mDYX1b2obJ9yWAnGVbqNmTt86Jap7CD15JcjDMoXRpc8SZ1jm9kMEENkpWB9OcwIBvnKYNSb2TZhV(iWtKeEKCi8)VrWXkbcLbd0gGNqmscpsoe()hvWsCRQHu(KnWUD(eI7KJRdSDQovMAI9GwxD(OkENPt86Jap7CDctVIPN3jfqYYd8wVBHaqjB2taYDGPiyZi4yLga5pE9rGNijeHiswEG36zJz85bZKdheyQ(pE9rGNiP4ij8i5q4)FJGJvcekdgOnapH4o546aBNQtLPMypO1vNpkKQZ0jE9rGNDUoHPxX0Z70q4)FQ3VmGVPiydG8NTCSsKupKeY6KJRdSDIjpMdgcNQ1vNpQU7mDYX1b2oncowjqOmkpSYoXRpc8SZ1vNxms6mDYX1b2oPKvnwn3s0jE9rGNDUU68IrwNPt86Jap7CDctVIPN3PjOEyWI5TOEXtZp4A8JYA(TwKeksssNCCDGTtyWI5TOEXtZp4ACxDEXI2z6eV(iWZoxNW0Ry65DsXIKS1YlMFfbBWub8ncSb8n)GRXpnNuaANCCDGTteStldBT8I5U68IjwNPt86Jap7CDctVIPN3PHW))uVFzaFtrWga5pB5yLiPEqrsX6KJRdSDIjpMdgcNQ1vNxmiRZ0jE9rGNDUoHPxX0Z70q4)FublXTQgs5t2a725BcGTDYX1b2orfSe3QAiLpzdSBND15fdUDMoXRpc8SZ1jm9kMEENgc))BeCSsGqzWaTb4nbWwKeEKubKCi8)VraaMbbB9MaylscriIKkGKdH))ncaWmiyRNqmscpsob1BqzVimGV5Fu2mb1JYFkBj8rGrsXrsX7KJRdSDAqzVimGV5FuURoVyqsNPtoUoW2jmXzgcuB1jE9rGNDUU68IP4DMo546aBNWeNbMdbUt86Jap7CD15fds1z6eV(iWZoxNW0Ry65DYX1bb2WlRDSfj1djjRtoUoW2jB8T7TQgm1x2O8Wk7QZlMU7mDIxFe4zNRty6vm98one()N69ld4Bkc2ai)zlhRej1dksgTtoUoW2jM8yoyiCQwxDEiJKotN41hbE256eMEftpVtkwKS8aV1BeCSsGqzWaTb4XRpc8ejHhjXaqycGTpLSQXQ5wIhL18BTiPEiPkEIKWJKkGK8Yuv9rYiiPcijVmvv)hLv5fjvesQasIbGWeaBFkzvJvZTepkR53ArYiiPkEIKIJKIJKIJK6bfjHe42jhxhy7uDQm1e7bTU68qgzDMoXRpc8SZ1jm9kMEEN4LPQ6JKWbjfJSo546aBNCk2x2uakL3QRopKfTZ0jhxhy7evWsCRQHu(KnWUD2jE9rGNDUU6QtXugd0gE1z68K1z6KJRdSDkguhy7eV(iWZoxxD(ODMo546aBNWeNziqTvN41hbE256QZlwNPtoUoW2jmXzG5qG7eV(iWZoxxD1vNGatThy78rjjkjKaPitXFr7emNU3QA7ePVwmGw8ejJIKoUoWIKHZw2hsuNSXmUZhfsGuDkMc(xG7KUqYCugMMBlMIKKoGvjsKUqYehxS2GPizuirhKmkjrjbjcjsxijPHCglu8ejh8hqzKed0gEHKdw9w7djjDXyoUSi5cwftcNQ9fciPJRdSwKeSb9Fir6cjDCDG1(IPmgOn8c6p4wLir6cjDCDG1(IPmgOn8kc0SFayIePlK0X1bw7lMYyG2WRiqZ6cQA8wEDGfjsxizA9ylbOqsQFtKCi8)8ejTLxwKCWFaLrsmqB4fsoy1BTiPVtKmMYkMXGQUvfjplsobl)qI0fs646aR9ftzmqB4veOzTRhBjaLXwEzrICCDG1(IPmgOn8kc0SXG6alsKJRdS2xmLXaTHxrGMftCMHa1wiroUoWAFXugd0gEfbAwmXzG5qGrIqI0fssAiNXcfprsgcmvFKSongjlcgjDCbOi5zrshc(f8rGFiroUoWAHAJzNAi8DASf9uYiroUoWAJan701I51q4unDUpuc2dfXlgxWrXHl83IbA3QAMUMRYgXS6rWEOiEAo5ksbsErJOajVOksLceIfxC4hc))7dO191)wvZGYWEtaSfjYX1bwBeOz)aADF9Vv1mOmmDUpuc2dfXlgxWbUKa)TyG2TQMPR5QSrmREeShkINMtUIuGKx0ikqYlQIuPaHyXfhEfgc))B6AX8AiCQ2BcGTIJe546aRnc0Scw2CfRPZ6Amu3sabFzRH6qoGAWaQh05(qN8q4)FuhYbudgq9GzYdH))nbWwicXjpe()hgStbCDqGn3Q0m5HW))eIHVCQkxpc2dfXlgxWrmYGieRtJnfWmpgorjbjYX1bwBeOzfSS5kwZIe546aRnc0SXG6alsKJRdS2iqZocaW08fO6Je546aRnc0SdMAzQYBvrICCDG1gbA2WPsuwdPeMQA8wiroUoWAJan7)O8iaatKihxhyTrGM1xmBlQhmypeqICCDG1gbA2BHaqjB2taYDGPiyZi4yLga56CFO1PXMcyMhRxu4IeHe546aRnc0SyoW268Gzqzy6CFOdH))flqV)XtdM4EcXWpe()3i4yLaHYGbAdWBcGTWFlgODRQz6AUkBit36w3Aw9ibjYX1bwBeOzJfO3x)BvndkdtN7d1wUQktFX4spfIcxfPazruPaHyXfhIqet4uv2QhzWpe()hMdSTopygug2BcGTWpe()xSa9(hpnyI7nbWwKiKiDHKkgShUvfjjnHJ8JIe546aRnc0Sm5XCWq4unDUpuc2dfXlgxWbUkIG9WTQgBmbt5hgiSfeHOceShUv1yJjyk)WaHT0dQyWtWEOiEX4coWLeXrICCDG1gbAwc2d3QA4Wr(r15(qjypueVyCbhXedjcjsxizUGJvIKK2KJK5OmmK8SijwGs5Tc6JKcwEIKfaj5Riykss54aVNLajhugMfjhULNijyrYaBTizr4lss4Hps6i5GYWqsmHtvzK0HGFbFeyDqsafjdayijVmvvFKSaijV(iWijPhRIKjn3sGe546aRnc0SJGJvAaKBgugMo3hkgactaS9nOmm7dt4uv2A(uhxhy9aCi5bxKihxhyTrGMDeCSsdGCZGYW05(qvGxMQQFef4LPQ6)OSkVkcdaHja2(uYQgRMBjEuwZV1kU4WbYib(HW))gbhReiugmqBaEtaSfEmaeMay7tjRASAUL4jeJeHePlKK0()51EqGd6Rdswemss6cPbPdjJPhGE1b5Sfjj9sijyrsCGDiW6GK5ajKKdwwhKe2veijVmvvFK0gZ7KPwK03jsINwK0cOfprYbhaWqICCDG1gbAwLSQXQ5wcDUpuBmhcMYPQCz1dAuKiKihxhyTrGMDYfGCKihxhyTrGMLkyjUv1qkFYgy3o15(qTXCiykNQYLvpOrHFi8)pQGL4wvdP8jBGD78nbWwKiKihxhyTrGMDawEkylZGYWqICCDG1gbA2Vhc8Aa0jtrICCDG1gbA2VZHBzJTaAXiroUoWAJanlm2JbR1a(gaDYuKihxhyTrGMTovMAI9GMo3hA5bERhvWsCRQHu(KnWUD(41hbEc)q4)FJGJvcekdgOnapHy4hc))JkyjUv1qkFYgy3oFcXiroUoWAJanBDQm1e7bnDUpufkpWB9UfcaLSzpbi3bMIGnJGJvAaK)41hbEcriwEG36zJz85bZKdheyQ(pE9rGNId)q4)FJGJvcekdgOnapHyKihxhyTrGMLjpMdgcNQPZ9Hoe()N69ld4Bkc2ai)zlhRupidjYX1bwBeOzhbhReiugLhwjsKJRdS2iqZQKvnwn3sGe546aRnc0SyWI5TOEXtZp4ASo3h6eupmyX8wuV4P5hCn(rzn)wlusqICCDG1gbAwc2PLHTwEXSo3hQILTwEX8RiydMkGVrGnGV5hCn(P5KcqrICCDG1gbAwM8yoyiCQMo3h6q4)FQ3VmGVPiydG8NTCSs9GkgsKJRdS2iqZsfSe3QAiLpzdSBN6CFOdH))rfSe3QAiLpzdSBNVja2Ie546aRnc0Sdk7fHb8n)JY6CFOdH))ncowjqOmyG2a8Mayl8kme()3iaaZGGTEtaSfIquHHW))gbaygeS1tig(jOEdk7fHb8n)JYMjOEu(tzlHpcS4IJe546aRnc0SyIZmeO2cjYX1bwBeOzXeNbMdbgjYX1bwBeOzTX3U3QAWuFzJYdRuN7d1X1bb2WlRDSvpYqI0fssAipMdiPIHt1qsc3IKeNkbtrsslqAKMmizr4lsMbsdjHrWlsQpqajjCiWiPxizGDBHKrrsaDyFiroUoWAJanltEmhmeovtN7dDi8)p17xgW3ueSbq(ZwowPEqJIe546aRnc0S1PYutSh005(qvSLh4TEJGJvcekdgOnapE9rGNWJbGWeaBFkzvJvZTepkR53A1tfpHxbEzQQ(ruGxMQQ)JYQ8QifWaqycGTpLSQXQ5wIhL18BTruXtXfxC9GcjWfjYX1bwBeOzDk2x2uakL3sN7dLxMQQpCeJmKihxhyTrGMLkyjUv1qkFYgy3o7QRUb]] )


end