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

                if level < 116 and equipped.firestone_walkers then setCooldown( "fortifying_brew", max( 0, cooldown.fortifying_brew.remains - ( min( 6, active_enemies * 2 ) ) ) ) end

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

                applyBuff( "shuffle" )

                setCooldown( "celestial_brew", max( 0, cooldown.celestial_brew.remains - ( 4 + ( buff.blackout_combo.up and 2 or 0 ) ) ) )
                gainChargeTime( 'purifying_brew', 4 + ( buff.blackout_combo.up and 2 or 0 ) )
                cooldown.fortifying_brew.expires = max( 0, cooldown.fortifying_brew.expires - 4 + ( buff.blackout_combo.up and 2 or 0 ) )

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
                if set_bonus.tier20_2pc == 1 then healing_sphere.count = healing_sphere.count + 1 end

                if buff.blackout_combo.up then
                    addStack( 'elusive_brawler', 10, 1 )
                    removeBuff( 'blackout_combo' )
                end

                local reduction = 0.5
                stagger.amount = stagger.amount * ( 1 - reduction )
                stagger.tick = stagger.tick * ( 1 - reduction )
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
                gainChargeTime( 'celestial_brew', 1 )
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

            start = function ()
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


    spec:RegisterPack( "Brewmaster", 20200817.1, [[dSe8FaqiQurpIKQ2esPprsLYOqjofkPvHuXReIzrL4wqvs7cWVuknmOQogjLLjuEgvstdPqxdk02OsL(gufnoOk15qkyDuPknpOG7bv2NqQdssfwOsXdjPsAIKurCrQuvFKKkkJKkvOtcvjSssYlPsfmtsQO6MKuPANqr)KKkXqPsvSusQi9uPmvHQVcvjQ9QQ)svdgYHPSyP6XOAYk5YeBgOptIrJKtRy1iv61OuZwWTPIDRYVbnCLQJdvjYYr8CsnDrxhfBxi57qPXJu15Psz9qvy(ifTFj)Q9X)2Ys5Xmg(XWhF8wn8eqn8gF3fJU(T0TD5B7gNTPiF7mh5BBicwhtNc5B7MBbOT(4FtdziC5BuzURDVB3QmjfthGdD2QhhMGLd84edm3Qhh(2V1zMqIxCF)BllLhZy4hdF8XB1Wta1WB8Xig)MXKuqY3AJJ663OM1sUV)TLO5Ft9fAdrW6y6uifsDhESlvQVqQdgfgDwi1Wtxkum8JH)3cJo1F8VTeqJjKF8ht1(4FZ45aVVP3fJ4PSB51jzylFtoRhK1V5ZhZyF8VjN1dY638nozsHm23OelKua78SqyOq4jgleTfAoo0zof)YCmfX7QUqrxikXcjfGJrFHOtHyPq4deRqrkelfcFGyfIofsHaz2leRfI1crBH6mGGaGqsoGUnNIVteSali27Bgph49TL5SlNNYioF(y66h)BYz9GS(nFJtMuiJ9nkXcjfWoplegkegXVq0wO54qN5u8lZXueVR6cfDHOelKuaog9fIofILcHpqScfPqSui8bIvi6uifcKzVqSwiwleTfILc1zabbwMZUCEkJ4aSGyVcX63mEoW7BGqsoGUnNIVteSF(ysJF8VjN1dY638nJNd8(MPPIYor7jgEajEoKyHVXjtkKX(2s6mGGaedpGephsSGFjDgqqGfe7viAsZcTKodiiahElgEorj(5y7xsNbeeGzVq0wO0ikscqjwiPa25zHWqHCvTcrtAwOCCeFc9Rrkegkum8)2zoY3mnvu2jApXWdiXZHel85Jjg)4FZ45aVVXOf)KIJ(BYz9GS(nF(y6UF8Vz8CG332H5aVVjN1dY6385JjE(X)MXZbEFRhGWLhKH423KZ6bz9B(8XeV)4FZ45aVV1fIwiSNt5BYz9GS(nF(ysdF8Vz8CG33cJcvQ90LzP4ix(n5SEqw)MpFmvd)p(3mEoW7BGdr6biC9n5SEqw)MpFmvtTp(3mEoW7B2XfDsSGNBHW3KZ6bz9B(8XuTyF8VjN1dY638nozsHm23YXr8j0VgPqrxOyy8Bgph49T5IcYw83WGhg8Zht1C9J)n5SEqw)MVXjtkKX(wNbeeOhmoBit65qNoeybXEfI2cnhh6mNIFzoMI4vJgObAWrxOOlelfIsSqsb4y0xi6ui8buRqrkKonffHaemD6ZHZ2Vmhtr80yHyTq0wOodiiGey0tuIVtmSbHaOtJZUqyOqX(MXZbEFJlbrNJf8DIG9Zht1OXp(3KZ6bz9B(gNmPqg7B60uuecWoplu0fILcfdJfIofILcPwHIuifcKzVqSwiwleTfQZaccme4PzpNVteSam7fI2cXsHIvi8AH4ugrr0EqIXZbEwOqSwi6uiIWPmIIuimuOodiiWqGNM9C(orWcqehBo93mEoW7B7mKb0T5u8DIG9Zht1W4h)BYz9GS(nFJtMuiJ9nDAkkcbWbUeILY3mEoW7BCji6CSGVteSF(yQM7(X)MCwpiRFZ34KjfYyFJsSqsbSZZcHHcHXcrNcrjwyofVENsicahYCzHOjnlelfIsSWCkE9oLqeaoK5YcfnUc5AHOTquIfskGDEwimuimIFHy9Bgph49nH(Dj4PmIZNpMQHNF8VjN1dY638nozsHm23OelKua78SqyOqU663mEoW7BuIfMtXlHH(H85JPA49h)BYz9GS(nFJtMuiJ9noegwqShqNiy1aCkJOiApiX45apluimui8bW43mEoW7B9GXz7H077eb7NpMQrdF8VjN1dY638nozsHm23yPqYjef3kuKcXsHKtikUbqef5keDkehcdli2dGTO41oMMcGio2C6cXAHyTqyOq0i(fI2c1zabb6bJZgYKEo0PdbwqSxHOTqCimSGypa2IIx7yAkaM9Vz8CG336bJZ2dP33jc2pFmJH)h)BYz9GS(nFJtMuiJ9n9Uec(0iksQlu04kuSVz8CG33ylkETJPP(8XmMAF8Vz8CG33wscP)BYz9GS(nF(ygl2h)BYz9GS(nFJtMuiJ9n9Uec(0iksQlu04kuScrBH6mGGaegn1CkE6AlXJDUfWcI9(MXZbEFJWOPMtXtxBjESZT(8XmMRF8VjN1dY638nozsHm23slixcqy0uZP4PRTep25waYz9GSkeTfQZacc0dgNnKj9COthcWSxiAluNbeeGWOPMtXtxBjESZTay2)MXZbEFlhfH43TGZNpMXOXp(3KZ6bz9B(gNmPqg7BSuO0cYLaZffKT4VHbpmOpPeFpyC2Ei9aYz9GSkenPzHslixcO3f(yb)sctucXna5SEqwfI1crBH6mGGa9GXzdzsph60Ham7FZ45aVVLJIq87wW5ZhZyy8J)n5SEqw)MVXjtkKX(wNbeeqzatpe0NuIhspGono7cfDHOXVz8CG33e63LGNYioF(ygZD)4FZ45aVV1dgNnKj9Sho7VjN1dY6385Jzm88J)nJNd8(gBrXRDmn13KZ6bz9B(8XmgE)X)MCwpiRFZ34KjfYyFBbtao84YLelLLhmyocarCS50fcxHW)Bgph49no84YLelLLhmyoYNpMXOHp(3KZ6bz9B(gNmPqg7BUZcjATCCbiPepNWWNEq8qqpyWCeahJUqY3mEoW7BuIrsVO1YXLpFmDf)p(3KZ6bz9B(gNmPqg7BDgqqaLbm9qqFsjEi9a604Slu04kKRFZ45aVVj0VlbpLrC(8X0v1(4FtoRhK1V5BCYKczSV1zabbimAQ5u801wIh7ClGfe79nJNd8(gHrtnNINU2s8yNB95JPRX(4FtoRhK1V5BCYKczSV1zabb6bJZgYKEo0PdbwqSxHOTqSuOodiiqpaHRaJobwqSxHOjnlelfQZacc0dq4kWOtaM9crBHwWeOtelP8qqp4qe)cMaebKiAkRhKcXAHy9Bgph49TorSKYdb9Gdr(8X0vx)4FZ45aVVXPgFNHOZVjN1dY6385JPR04h)Bgph49no14XArjFtoRhK1V5ZhtxX4h)BYz9GS(nFJtMuiJ9nJNtuIxoXzeDHIUqQ9nJNd8(MEFUBofpNyN4zpC2F(y6Q7(X)MCwpiRFZ34KjfYyFRZaccOmGPhc6tkXdPhqNgNDHIgxHI9nJNd8(Mq)Ue8ugX5ZhtxXZp(3KZ6bz9B(gNmPqg7BUZcLwqUeOhmoBit65qNoeqoRhKvHOTqCimSGypa2IIx7yAkaI4yZPlu0fsHVkeTfILcjNquCRqrkelfsoHO4garuKRq0PqSuioegwqShaBrXRDmnfarCS50fksHu4RcXAHyTqSwOOXvi3fJFZ45aVVLJIq87wW5ZhtxX7p(3KZ6bz9B(gNmPqg7BYjef3kegkKRQ9nJNd8(Mr42j(esiYLF(y6kn8X)MXZbEFJWOPMtXtxBjESZT(MCwpiRFZNF(TDIWHoDl)4pMQ9X)MXZbEFBhMd8(MCwpiRFZNpMX(4FZ45aVVXPgFNHOZVjN1dY6385JPRF8Vz8CG334uJhRfL8n5SEqw)Mp)8ZVfLq0d8EmJHFm8XhVvdp)gwJCZPO)gEz1H6umXlWuDM7TqfkoLuOXzhsYcbcjfsDBjGgtiv3kerWlXmezvin0rkKXKqhlLvH4u2PiAGsvCkPqGWqaIDoLczmetxiScrkeJwwfAUcLusHmEoWRqHrNfQZKfcRqKcDWSqGqMBvO5kusjfYwl4vOLLw30I7Tuvi8AHgc80SNZ3jc2svPcVWzhsszvOyfY45aVcfgDQbkvFtVl8hZyUlE)TDceCcY3uFH2qeSoMofsHu3Hh7sL6lK6GrHrNfsn80Lcfd)y4xQkvQVqUp9cNjLvH6ciKifIdD6wwOUOmNgOqQdox2tDHo4HxPmIditOqgph4Ple8cUbuQuFHmEoWtdSteo0PBjoWGPzxQuFHmEoWtdSteo0PBzeCBbHWvPs9fY45apnWor4qNULrWT1yuCKlTCGxPs9fQD2UMcMfIyZQqDgqqzviDAPUqDbesKcXHoDlluxuMtxi7wfANi41DyMZPuOrxOf8eGsL6lKXZbEAGDIWHoDlJGBR(SDnfm960sDPY45apnWor4qNULrWTDhMd8kvgph4Pb2jch60TmcUTCQX3zi6Suz8CGNgyNiCOt3Yi42YPgpwlkPuvQuFHCF6fotkRcjrje3kuoosHskPqgpHKcn6czrztW6bbOuz8CGNgNExmINYULxNKHTuQmEoWthb32L5SlNNYioUmG4OelKua78ed4jgPDoo0zof)YCmfX7QoAkXcjfGJrpDybFGyrybFGy0rHaz2zLvA7mGGaGqsoGUnNIVteSali2Ruz8CGNocUTGqsoGUnNIVteSUmG4OelKua78edyeFANJdDMtXVmhtr8UQJMsSqsb4y0thwWhiwewWhigDuiqMDwzLww6mGGalZzxopLrCawqShRLkJNd80rWTLrl(jfhxoZrWzAQOSt0EIHhqINdjwWLbe3s6mGGaedpGephsSGFjDgqqGfe7rtAUKodiiahElgEorj(5y7xsNbeeGzN20ikscqjwiPa25jgCvnAsZCCeFc9RrWqm8lvgph4PJGBlJw8tko6sLXZbE6i42UdZbELkJNd80rWTThGWLhKH4wPY45apDeCB7crle2ZPuQmEoWthb32WOqLApDzwkoYLLkJNd80rWTfCispaHRsLXZbE6i42Ahx0jXcEUfcLkJNd80rWTDUOGSf)nm4Hb9jL47bJZ2dP3LbexooIpH(1irhdJLQsL6lK6QeeDowOqBic2cTtgizs3kewk5KOesHMSqjeYUq6r5gWHBxwOL5yksHSBvOHapn75kuNiyluNbeSqJUqoJwpNsHyXw0LrNfkPKcrjwiPaCm6lehkGGdFKllKX5qYAoLcLWcnxkNEs3keeSqlZXuKcLgB5y1Lcz3QqjSqlgN9cj0ZfTUqCkJOi6c1fqirk0g4gGsLXZbE6i42YLGOZXc(orW6YaIRZacc0dgNnKj9COthcSGypANJdDMtXVmhtr8Qrd0an4OJMfkXcjfGJrpDWhqTi60uuecqW0PphoB)YCmfXtJSsBNbeeqcm6jkX3jg2Gqa0PXzJHyLQsL6lK7HHmGUnNsH6cLf1azifA0fQBAzvi4vOdsCSWGhwoWRqSmUFHskPqblLcj0VteTEGxHsYOOieDHgWcPttrrifsp4HuO54eX0YQqWOesHskPqbtNfYv8luoC26cbjfsnmwiTWH3sZkqPY45apDeCB3zidOBZP47ebRldioDAkkcbyNNrZsmmshwulIcbYSZkR02zabbgc80SNZ3jcwaMDAzjgELtzefr7bjgph4zbwPdr4ugrrWqNbeeyiWtZEoFNiybiIJnNUuvQuFHChflmNsHC)Wq)qkvgph4PJGBlxcIohl47ebRldioDAkkcbWbUeILsPY45apDeCBf63LGNYioUmG4OelKua78edyKouIfMtXR3PeIaWHmxstAYcLyH5u86DkHiaCiZLrJZvAPelKua78edyeFwlvgph4PJGBlLyH5u8syOFiUmG4OelKua78edU6APQuP(cTjyC2fsDH(cTHiyl0OleNHqKldUvigTSkuclKmjLqker2dYnAQc1jcwDH6MwwfcEfkiADHsk7keLfalKvOorWwioLruKczrztW6bXLcbjfkaXwi5eIIBfkHfsoRhKc5oikfQ5yAQsLXZbE6i422dgNThsVVteSUmG44qyybXEaDIGvdWPmIIO9GeJNd8SagWhaJLkJNd80rWTThmoBpKEFNiyDzaXXICcrXTiSiNquCdGikYrhoegwqShaBrXRDmnfarCS50SYkgOr8PTZacc0dgNnKj9COthcSGypA5qyybXEaSffV2X0uam7LQsL6lK6ciOC6jkj4MlfkPKcPoCpQZl0ozGKjh8q0fYDOvi4viEqSOexk0gyRqsqlUuiStsvi5eIIBfsVl3si6cz3Qq8LUqAijLvH6saITuz8CGNocUTSffV2X0uUmG407si4tJOiPoACXkvLkJNd80rWTDjjK(sLXZbE6i42sy0uZP4PRTep25wUmG407si4tJOiPoACXOTZaccqy0uZP4PRTep25wali2RuvQmEoWthb32CueIF3coUmG4slixcqy0uZP4PRTep25waYz9GSOTZacc0dgNnKj9COthcWStBNbeeGWOPMtXtxBjESZTay2lvgph4PJGBBokcXVBbhxgqCSKwqUeyUOGSf)nm4Hb9jL47bJZ2dPhqoRhKfnPzAb5sa9UWhl4xsyIsiUbiN1dYIvA7mGGa9GXzdzsph60Ham7LkJNd80rWTvOFxcEkJ44YaIRZaccOmGPhc6tkXdPhqNgND00yPY45apDeCB7bJZgYKE2dNDPY45apDeCBzlkETJPPkvgph4PJGBlhEC5sILYYdgmhXLbe3cMaC4XLljwklpyWCeaI4yZPXHFPY45apDeCBPeJKErRLJlUmG4CNIwlhxaskXZjm8Phepe0dgmhbWXOlKuQmEoWthb3wH(Dj4PmIJldiUodiiGYaMEiOpPepKEaDAC2rJZ1sLXZbE6i42sy0uZP4PRTep25wUmG46mGGaegn1CkE6AlXJDUfWcI9kvgph4PJGBBNiws5HGEWHiUmG46mGGa9GXzdzsph60Hali2Jww6mGGa9aeUcm6eybXE0KMS0zabb6biCfy0jaZoTlyc0jILuEiOhCiIFbtaIasenL1dcRSwQmEoWthb3wo147meDwQmEoWthb3wo14XArjLkJNd80rWTvVp3nNINtSt8ShoBxgqCgpNOeVCIZi6OvRuP(c5(0VlHc5oAeNcrz6crnkucPqQtCpUF8cLu2vO4UNcHLsUc5gKPquwusHSSqbX0zHIviiPRbkvgph4PJGBRq)Ue8ugXXLbexNbeeqzatpe0NuIhspGono7OXfRuz8CGNocUT5Oie)UfCCzaX5otlixc0dgNnKj9COthciN1dYIwoegwqShaBrXRDmnfarCS50rRWx0YICcrXTiSiNquCdGikYrhw4qyybXEaSffV2X0uaeXXMthrHVyLvwJgN7IXsLXZbE6i42AeUDIpHeICPldio5eIIByWv1kvgph4PJGBlHrtnNINU2s8yNB95N)d]] )


end