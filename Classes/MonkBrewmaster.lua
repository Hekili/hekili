-- MonkBrewmaster.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

local format = string.format


-- Conduits
-- [-] scalding_brew
-- [x] walk_with_the_ox

-- Covenant
-- [x] strike_with_clarity
-- [-] imbued_reflections
-- [-] bone_marrow_hops
-- [-] way_of_the_fae

-- Endurance
-- [x] fortifying_ingredients
-- [-] grounding_breath
-- [-] harm_denial

-- Brewmaster Endurance
-- [x] celestial_effervescence
-- [x] evasive_stride

-- Finesse
-- [x] dizzying_tumble
-- [-] lingering_numbness
-- [x] swift_transference
-- [-] tumbling_technique


if UnitClassBase( "player" ) == "MONK" then
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
        },


        -- Conduits
        lingering_numbness = {
            id = 336884,
            duration = 5,
            max_stack = 1
        }
    } )


    spec:RegisterHook( "reset_postcast", function( x )
        for k, v in pairs( stagger ) do
            stagger[ k ] = nil
        end
        return x
    end )


    spec:RegisterGear( "tier19", 138325, 138328, 138331, 138334, 138337, 138367 )
    spec:RegisterGear( "tier20", 147154, 147156, 147152, 147151, 147153, 147155 )
    spec:RegisterGear( "tier21", 152145, 152147, 152143, 152142, 152144, 152146 )
    spec:RegisterGear( "class", 139731, 139732, 139733, 139734, 139735, 139736, 139737, 139738 )

    spec:RegisterGear( "cenedril_reflector_of_hatred", 137019 )
    spec:RegisterGear( "cinidaria_the_symbiote", 133976 )
    spec:RegisterGear( "drinking_horn_cover", 137097 )
    spec:RegisterGear( "firestone_walkers", 137027 )
    spec:RegisterGear( "fundamental_observation", 137063 )
    spec:RegisterGear( "gai_plins_soothing_sash", 137079 )
    spec:RegisterGear( "hidden_masters_forbidden_touch", 137057 )
    spec:RegisterGear( "jewel_of_the_lost_abbey", 137044 )
    spec:RegisterGear( "katsuos_eclipse", 137029 )
    spec:RegisterGear( "march_of_the_legion", 137220 )
    spec:RegisterGear( "salsalabims_lost_tunic", 137016 )
    spec:RegisterGear( "soul_of_the_grandmaster", 151643 )
    spec:RegisterGear( "stormstouts_last_gasp", 151788 )
    spec:RegisterGear( "the_emperors_capacitor", 144239 )
    spec:RegisterGear( "the_wind_blows", 151811 )


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
    local staggered_damage_pool = {}
    local total_staggered = 0

    local stagger_ticks = {}

    local function trackBrewmasterDamage( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, arg1, arg2, arg3, arg4, arg5, arg6, _, arg8, _, _, arg11 )
        if destGUID == state.GUID then
            if subtype == "SPELL_ABSORBED" then
                local now = GetTime()

                if arg1 == destGUID and arg5 == 115069 then
                    local dmg = table.remove( staggered_damage_pool, 1 ) or {}

                    dmg.t = now
                    dmg.d = arg8
                    dmg.s = 6603

                    total_staggered = total_staggered + arg8

                    table.insert( staggered_damage, 1, dmg )

                elseif arg8 == 115069 then
                    local dmg = table.remove( staggered_damage_pool, 1 ) or {}

                    dmg.t = now
                    dmg.d = arg11
                    dmg.s = arg1

                    total_staggered = total_staggered + arg11

                    table.insert( staggered_damage, 1, dmg )
                    
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

    spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
        table.wipe( stagger_ticks )
    end )


    function stagger_in_last( t )
        local now = GetTime()

        for i = #staggered_damage, 1, -1 do
            if staggered_damage[ i ].t + 10 < now then
                total_staggered = max( 0, total_staggered - staggered_damage[ i ].d )
                staggered_damage_pool[ #staggered_damage_pool + 1 ] = table.remove( staggered_damage, i )
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
                if k == "up" then return false
                elseif k == "down" then return true
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

            elseif k == "percent" or k == "pct" then
                -- stagger tick dmg / current effective hp
                if health.current == 0 then return 100 end
                local current = health.current + UnitGetTotalAbsorbs( "player" )
                return ceil( 100 * t.tick / health.current )
            
            elseif k == "percent_max" or k == "pct_max" then
                if health.max == 0 then return 100 end
                return ceil( 100 * t.tick / health.max )

            elseif k == "tick" or k == "amount" then
                if t.ticks_remain == 0 then return 0 end
                return t.amount_remains / t.ticks_remain
            
            elseif k == "ticks_remain" then
                return floor( stagger.remains / 0.5 )

            elseif k == "amount_remains" then
                t.amount_remains = UnitStagger( "player" )
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
            elseif k == "incoming_per_second" then
                return avg_stagger_ps_in_last( 10 )

            elseif k == "time_to_death" then
                return ceil( health.current / ( stagger.tick * 2 ) )

            elseif k == "percent_max_hp" then
                return ( 100 * stagger.amount / health.max )

            elseif k == "percent_remains" then
                return total_staggered > 0 and ( 100 * stagger.amount / stagger_in_last( 10 ) ) or 0

            elseif k == "total" then
                return total_staggered

            elseif k == "dump" then
                if DevTools_Dump then DevTools_Dump( staggered_damage ) end

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
                if conduit.walk_with_the_ox.enabled and cooldown.invoke_niuzao.remains > 0 then
                    reduceCooldown( "invoke_niuzao", 0.5 )
                end

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
            cooldown = function () return level > 42 and 5 or 15 end,
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
                if conduit.fortifying_ingredients.enabled then applyBuff( "fortifying_ingredients" ) end
            end,

            auras = {
                -- Conduit
                fortifying_ingredients = {
                    id = 336874,
                    duration = 15,
                    max_stack = 1
                }
            }
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
                if conduit.dizzying_tumble.enabled then applyDebuff( "target", "dizzying_tumble" ) end
            end,

            auras = {
                -- Conduit
                dizzying_tumble = {
                    id = 336891,
                    duration = 5,
                    max_stack = 1
                }
            }
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
                if stagger.amount == 0 then return false, "no damage is staggered" end
                if health.current == 0 then return false, "you are dead" end
                return true
            end,

            handler = function ()
                if buff.blackout_combo.up then
                    addStack( "elusive_brawler", 10, 1 )
                    removeBuff( "blackout_combo" )
                end

                local stacks = stagger.heavy and 3 or stagger.moderate and 2 or 1
                addStack( "purified_brew", nil, stacks )

                local reduction = 0.5
                stagger.amount_remains = stagger.amount_remains * ( 1 - reduction )
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
                gainChargeTime( "celestial_brew", debuff.bonedust_brew.up and 2 or 1 )
                gainChargeTime( "purifying_brew", debuff.bonedust_brew.up and 2 or 1 )

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
                if conduit.swift_transference.enabled then applyBuff( "swift_transference" ) end
            end,

            auras = {
                -- Conduit
                swift_transference = {
                    id = 337079,
                    duration = 5,
                    max_stack = 1
                }
            }
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
                    duration = function () return conduit.strike_with_clarity.enabled and 35 or 30 end,
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

    spec:RegisterSetting( "purify_stagger_currhp", 12, {
        name = "|T133701:0|t Purifying Brew: Stagger Tick % Current Health",
        desc = "If set above zero, the addon will recommend |T133701:0|t Purifying Brew when your current stagger ticks for this percentage of your |cFFFF0000current|r effective health (or more).  " ..
            "Custom priorities may ignore this setting.\n\n" ..
            "This value is halved when playing solo.",
        type = "range",
        min = 0,
        max = 100,
        step = 0.1,
        width = "full"
    } )

    spec:RegisterSetting( "purify_stagger_maxhp", 6, {
        name = "|T133701:0|t Purifying Brew: Stagger Tick % Maximum Health",
        desc = "If set above zero, the addon will recommend |T133701:0|t Purifying Brew when your current stagger ticks for this percentage of your |cFFFF0000maximum|r health (or more).  " ..
            "Custom priorities may ignore this setting.\n\n" ..
            "This value is halved when playing solo.",
        type = "range",
        min = 0,
        max = 100,
        step = 0.1,
        width = "full"
    } )


    spec:RegisterPack( "Brewmaster", 20201010.1, [[dGufPaqifO0JOuXLuGqTjj0OKGoLcyvecVsbnlkvDlfOODPOFPszysuhJqAzqvEMeyAeIUMcLTbvcFdQenoOsY5qrQ1ParAEOiUNkzFOOoOce1cvipubs1evGqUiuj1ivGcNubszLeQxQajntfiIBQaj2juXpvGkdvbQ6PQyQQuDvfiyVa)LIbJ4WuTyqEmrtguxM0MLYNL0Oj40IwnLk9AjYSLQBtj7gYVrA4O0Yv1Zr10fUou2UcvFhfgpuvNNsz9Oiz(qLA)knquWDWb2dfGdELXRSOLfT8u0cgJPlaxboHnwfCyDzjVQGdYTuWz0RmSCEOp4W626uhgChC4uSxQGJqeS8bP3UvZqadAkPw34Pfw3JKIKV3IB80sEdCGWYEmOHaqGdShkah8kJxzrllA5POfuwurfj44yHa9bNtAnOdocjmSIaqGdSYLGJDwYOxzy58q)LmOqrLwX2zjdozqH0FjIw2(LGxz8kdo9KhCWDWbwBowpa3b4ik4o44YiPiWHZQ(BeCeSHhFwsbhf5qDfgmceaCWdChCuKd1vyWiWr(zOF6GJG69qyYkJLWKLGlhBjfxsIKuRevnWULxvtb8LW8seuVhctlh)LiILu4skpXBjdxsHlP8eVLiILuFkg7sgyjdSKIlbcR1Mn6hzZwIQgOxzmHPmqGJlJKIahy3Ivrgb)TabaNca3bhf5qDfgmcCKFg6No4iOEpeMSYyjmzjJvEjfxsIKuRevnWULxvtb8LW8seuVhctlh)LiILu4skpXBjdxsHlP8eVLiILuFkg7sgyjdSKIlPWLaH1Aty3Ivrgb)TMWugOLma44YiPiWPr)iB2su1a9kdqaWrKG7GJICOUcdgboi3sbhNlmUJuU5DMI(gj99o44YiPiWX5cJ7iLBENPOVrsFVdoYpd9thCGviSwB(otrFJK(E3aRqyT2eMYaTeCJ7LaRqyT2usrWyYihxnjQKbwHWATjg7skUKW)Qgtb17HWKvglHjlParxcUX9sI0snb1aN6syYsWRmia4mg4o44YiPiWbJRMmulo4OihQRWGrGaGdUaChCCzKue4WsJKIahf5qDfgmceaCWLG7GJlJKIahOoLcBAyVnWrrouxHbJabahCf4o44YiPiWbsFU(LsufCuKd1vyWiqaWHPb3bhxgjfbo9SkeCJDXGRwkkahf5qDfgmceaCeTm4o44YiPiWPLVc1PuyWrrouxHbJabahrffChCCzKue44iPYJ37gP37GJICOUcdgbcaoIIh4o4OihQRWGrGJ8Zq)0bNiTutqnWPUeMxcEJboUmskcCs040sQbLymLtbbahrlaChCuKd1vyWiWr(zOF6GJuW)QYxY1sKc(xvUXYXFjfxcp8Av)PG6JBBjfxsHlbcR1MSyF2sf2ifYjmLbAj4g3lbcR1MSyF2sf2ifY5RwEI4lHjlr05ylrelPkHxYalP4sKuAhMYanLAx5r6Dd0RmMVA5jIVeMSKXahxgjfboSyF2SLOQb6vgGaGJOIeChCuKd1vyWiWr(zOF6GdxJirv(Kf7ZMndp8AvFJe7Fb2LW8skVKIlP(um2LuCj8WRv9NSYyjmFTeUgrIQ8jl2NnBgE41Q(gj2)cSGJlJKIahwSpB2su1a9kdqaWr0Xa3bhf5qDfgmcCKFg6No4W1isuLpzX(SzZWdVw13iX(xGDjmVKYlP4s40oDjfxcp8Av)jRmwcZxlHRrKOkFYI9zZMHhETQVrI9Va7seXskphdCCzKue4WI9zZwIQgOxzacaoIIla3bhf5qDfgmcCKFg6No4W1isuLpzX(SzZWdVw13y54lWUeMxs5LuCj1NIXUKIlHhETQ)KvglH5RLW1isuLpzX(SzZWdVw13y54lWcoUmskcCyX(Szlrvd0RmabahrXLG7GJICOUcdgboYpd9thC4AejQYNSyF2Sz4HxR6BSC8fyxcZlP8skUeoTtxsXLWdVw1FYkJLW81s4AejQYNSyF2Sz4HxR6BSC8fyxIiws55yGJlJKIahwSpB2su1a9kdqaWruCf4o4OihQRWGrGJ8Zq)0bhUgrIQ8jl2NnBgE41Q(gj2)cSl5AjLxsXLW1isuLpzX(SzZWdVw13y54lWUKRLuEjfxs9PySlP4s4HxR6pzLXsyEj4vgCCzKue4WI9zZwIQgOxzacaoIY0G7GJICOUcdgboYpd9thC4AejQYNSyF2Sz4HxR6BKy)lWUKRLuEjfxcxJirv(Kf7ZMndp8AvFJLJVa7sUws5LuCjCANUKIlHhETQ)KvglH5LiAzWXLrsrGdl2NnBjQAGELbia4GxzWDWrrouxHbJah5NH(PdocQ3dHjRmwctwYylrelrq9EIQgoRG(6usXqXsWnUxsHlrq9EIQgoRG(6usXqXsy(AjfSKIlrq9EimzLXsyYsgR8sgaCCzKue4O4ZQDJG)wGaGdEIcUdokYH6kmye4i)m0pDWrq9EimzLXsyYskOaWXLrsrGJG69evnApXpFqaWbp8a3bhf5qDfgmcCKFg6No4iP0omLbAYI9zZwIQgOxzmLc(xvUP9UmskY7lHjlP8CmWXLrsrGdu3LLmu8nqVYaeaCWRaWDWrrouxHbJah5NH(PdofUefPF12sgUKcxII0VAB(AvrlrelrsPDykd0SKwnClNlmF1YteFjdSKbwctwIilVKIlbcR1MqDxwIIfgj1cIoHPmqlP4sKuAhMYanlPvd3Y5ctmwWXLrsrGdu3LLmu8nqVYaeaCWtKG7GJICOUcdgboYpd9thCGWATju3LLOyHrsTGOtykd0skUKejPwjQAGDlVQg8yAMMPT4lH5Lu4seuVhctlh)LiILuEk6sgUeE41Q(ZUZdtKYsgy3YRQrKlzGLuCjqyT2u7y8CC1a9oJU(tE4YslHjlbpWXLrsrGJu7kpsVBGELbia4G3yG7GJICOUcdgboYpd9thCGWATjl2NTuHnsHCIXUKIlPWLaH1AtwSpBPcBKc58vlpr8LWKLi6CSLiILuLWlb34EjskTdtzGMSyF2SLOQb6vgZxT8eXxcZlbcR1MSyF2sf2ifY5RwEI4lzaWXLrsrGJu7kpsVBGELbia4GhUaChCuKd1vyWiWr(zOF6GdNv7Dt4Fvd(sy(Aj4boUmskcCkPvd3Y5cGaGdE4sWDWXLrsrGdSgu8bhf5qDfgmceaCWdxbUdokYH6kmye4i)m0pDWHZQ9Uj8VQbFjmFTe8wsXLaH1AZhJlKOQXUoSAyKi4jmLbcCCzKue48yCHevn21HvdJebdcao4X0G7GJlJKIahiksHX4Hb6vgGJICOUcdgbcaofugChCCzKue408Exrg6dRp4OihQRWGrGaGtbIcUdoUmskcCAU2tKA4b1IfCuKd1vyWiqaWPa8a3bhxgjfbomuNLI4gAZqFy9bhf5qDfgmceaCkOaWDWrrouxHbJah5NH(PdoH3vumFmUqIQg76WQHrIGNkYH6k8skUeiSwBc1DzjkwyKuli6eJDjfxcewRnFmUqIQg76WQHrIGNySGJlJKIaNiR6By9Ufia4uGib3bhf5qDfgmcCKFg6No4u4scVROyMOXPLudkXykNAcb1a1Dzjdf)PICOUcVeCJ7LeExrXKZQY07gyTNJRVTPICOUcVKbwsXLaH1AtOUllrXcJKAbrNySGJlJKIaNiR6By9Ufia4uWyG7GJICOUcdgboYpd9thCGWATznBHH2mHGAO4p5HllTeMxIibhxgjfbok(SA3i4Vfia4uaUaChCCzKue4a1DzjkwykLYsGJICOUcdgbcaofGlb3bhxgjfboL0QHB5CbWrrouxHbJabaNcWvG7GJICOUcdgboYpd9thCGPXusrsffVhkSP1DlD(QLNi(sUwszWXLrsrGJKIKkkEpuytR7wkia4uatdUdokYH6kmye4i)m0pDWzWUeLZvKuNHGAKpMmH6QH2mTUBPtl3U0hCCzKue4iO(hgLZvKubbahrwgChCuKd1vyWiWr(zOF6GdewRnRzlm0Mjeudf)jpCzPLW81skaCCzKue4O4ZQDJG)wGaGJiffChCuKd1vyWiWr(zOF6GdewRnFmUqIQg76WQHrIGNWugiWXLrsrGZJXfsu1yxhwnmsemia4is8a3bhf5qDfgmcCKFg6No4aH1AtOUllrXcJKAbrNWugOLuCjfUeiSwBc1Pu4ogpMWugOLGBCVKcxcewRnH6ukChJhtm2LuCjW0yc9QhcgAZ0YxnW0y(A7vUGd11LmWsgaCCzKue4a9QhcgAZ0Yxbbahrwa4o44YiPiWrkKgiSNhGJICOUcdgbcaoIuKG7GJlJKIahPqAy4JRGJICOUcdgbcaoICmWDWrrouxHbJah5NH(PdoUmYXvJIuRu5lH5Lik44YiPiWHZMiuIQg57i1ukLLabahrIla3bhf5qDfgmcCKFg6No4aH1AZA2cdTzcb1qXFYdxwAjmFTe8ahxgjfbok(SA3i4Vfia4isCj4o4OihQRWGrGJ8Zq)0bNb7scVROyc1DzjkwyKuli6urouxHxsXLiP0omLbAwsRgULZfMVA5jIVeMxsvcVKIlPWLOi9R2wYWLu4suK(vBZxRkAjIyjfUejL2HPmqZsA1WTCUW8vlpr8LmCjvj8sgyjdSKbwcZxlbxmg44YiPiWjYQ(gwVBbcaoIexbUdokYH6kmye4i)m0pDWrr6xTTeMSKcefCCzKue44V0rQjO)ROaeaCejtdUdoUmskcCEmUqIQg76WQHrIGbhf5qDfgmceGaCyFvsTG8aChGJOG7GJlJKIaNwx5cY3Bb4OihQRWGrGaGdEG7GJlJKIahwAKue4OihQRWGrGaGtbG7GJlJKIahPqAGWEEaokYH6kmyeia4isWDWXLrsrGJuinm8XvWrrouxHbJabiab4mU(8KIa4Gxz8klAzrldom8hLOkhCg0SyPFOWlbVL4YiPOL0tEWNRyWH9PTSRGJDwYOxzy58q)LmOqrLwX2zjdozqH0FjIw2(LGxz8kVIxX2zj4A8vjwOWlbsB0xxIKAb5XsG0AI4ZLmilLkBWxcIIgmf83QH1xIlJKI4lHI62MRy7SexgjfXNSVkPwqEC16oV0k2olXLrsr8j7RsQfKhdVU1Ou4vSDwIlJKI4t2xLulipgEDZXQwkk8iPOvSDwYb5SCbASK3t4LaH1Ak8s4Hh8LaPn6RlrsTG8yjqAnr8L4i4LW(6GjlnIevxsYxcmfPZvSDwIlJKI4t2xLulipgEDJJCwUanm8Wd(k2Lrsr8j7RsQfKhdVU16kxq(ElwXUmskIpzFvsTG8y41nwAKu0k2Lrsr8j7RsQfKhdVUjfsde2ZJvSlJKI4t2xLulipgEDtkKgg(46kEfBNLGRXxLyHcVeDC9TTKiT0Lec6sCzq)LK8L4J7z3H66Cf7YiPi(fNv93i4iydp(SKUIDzKueF41ny3Ivrgb)TSpBxcQ3dHjRmycUCSIjssTsu1a7wEvnfWzwq9EimTC8frHLN4nSWYt8er9PySdmqriSwB2OFKnBjQAGELXeMYaTIDzKueF41Tg9JSzlrvd0RmSpBxcQ3dHjRmyYyLlMij1krvdSB5v1uaNzb17HW0YXxefwEI3WclpXte1NIXoWaflecR1MWUfRImc(BnHPmqdSIDzKueF41nmUAYqTSh5w6LZfg3rk38otrFJK(E3(SDbRqyT28DMI(gj99UbwHWATjmLbc34gwHWATPKIGXKroUAsujdScH1Atm2IH)vnMcQ3dHjRmysbIIBChPLAcQbovMGx5vSlJKI4dVUHXvtgQfFf7YiPi(WRBS0iPOvSlJKI4dVUb1Puytd7TTIDzKueF41ni956xkr1vSlJKI4dVU1ZQqWn2fdUAPOyf7YiPi(WRBT8vOoLcVIDzKueF41nhjvE8E3i9EFf7YiPi(WRBjACAj1GsmMYPMqqnqDxwYqX3(SDfPLAcQbovMXBSv8k2olzWJ9zZwIQlbsf8Xtk2VKKVeiNRWlHIwcI(wEpzkpskAjfM46Lec6s6EOlrXN9vopPOLeFwR6Zxs2wcp8Av)LWtMsxsIKV6CfEj0X1FjHGUKUZJLuq5LePSeFj0FjIo2s4QKIG5dmxXUmskIp86gl2NnBjQAGELH9z7sk4Fv5xsb)Rk3y54xKhETQ)uq9XTvSqiSwBYI9zlvyJuiNWugiCJBiSwBYI9zlvyJuiNVA5jIZerNJjIQeEGIskTdtzGMsTR8i9Ub6vgZxT8eXzYyR4vSDwYGaxxIKIAzf7v4LWI9zZMHhETQVrI9Va7sAp1AjJELHLZd9xcLnskIpxXUmskIp86gl2NnBjQAGELH9z7IRrKOkFYI9zZMHhETQVrI9ValZLlwFkgBrE41Q(twzW8fxJirv(Kf7ZMndp8AvFJe7Fb2vSlJKI4dVUXI9zZwIQgOxzyF2U4AejQYNSyF2Sz4HxR6BKy)lWYC5ICANwKhETQ)KvgmFX1isuLpzX(SzZWdVw13iX(xGveLNJTIxX2zjdcCDjskQLvSxHxcl2NnBgE41Q(glhFb2L0EQ1sg9kdlNh6VekBKueFUIDzKueF41nwSpB2su1a9kd7Z2fxJirv(Kf7ZMndp8AvFJLJValZLlwFkgBrE41Q(twzW8fxJirv(Kf7ZMndp8AvFJLJVa7k2Lrsr8Hx3yX(Szlrvd0RmSpBxCnIev5twSpB2m8WRv9nwo(cSmxUiN2Pf5HxR6pzLbZxCnIev5twSpB2m8WRv9nwo(cSIO8CSv8k2ol5eETQ)sgeVeABj4vEjmYEFjLYEFj2OyljrlbV5ylHRskcMVegziqXILiOEpr1Lq)LWI9zZwIQZLSKbbUcVegckAjSyF2Sz4HxR6BKy)lWUehbVelhFb2L4VUe4K7qDfEUIDzKueF41nwSpB2su1a9kd7Z2fxJirv(Kf7ZMndp8AvFJe7Fb2RYf5AejQYNSyF2Sz4HxR6BSC8fyVkxS(um2I8WRv9NSYGz8kVIDzKueF41nwSpB2su1a9kd7Z2fxJirv(Kf7ZMndp8AvFJe7Fb2RYf5AejQYNSyF2Sz4HxR6BSC8fyVkxKt70I8WRv9NSYGzrlVIxX2zjdgQ3tuDj46EIF(RyxgjfXhEDtXNv7gb)TSpBxcQ3dHjRmyYyIqq9EIQgoRG(6usXqbUXDHcQ3tu1Wzf0xNskgky(QGIcQ3dHjRmyYyLhyf7YiPi(WRBcQ3tu1O9e)8TpBxcQ3dHjRmysbfSIxX2zjJ6US0sgC4VKrVYyjjFjsS)vu0TTemUcVKGUendb9xYRSDfLCHLa9kd(sGCUcVekAjDLZxsi4OLi492s8La9kJLif8VQlXh3ZUd1v7xc9xsNYyjks)QTLe0LOihQRlzqvRl5y5CHvSlJKI4dVUb1DzjdfFd0RmSpBxskTdtzGMSyF2SLOQb6vgtPG)vLBAVlJKI8otkphBf7YiPi(WRBqDxwYqX3a9kd7Z2vHks)QTHfQi9R2MVwvKiKuAhMYanlPvd3Y5cZxT8eXhyaMiYYfHWATju3LLOyHrsTGOtykdurjL2HPmqZsA1WTCUWeJDfVITZsg01UYJ07lz0Rmwc7N0pdBlHHGI0X1FjzSKGslTeEwrzlLokwcSB5vDjocEj5tr8sjAjqVYyjqyT2ss(sSsopr1LuOdBxmESKqqxIG69qyA54VejvBTuMkkwIlL0hor1Le0LKOqr8mSTeABjWULx1LeEjfnG9lXrWljOlbgZIDjk(sLZxIuW)QYxcK2OVUKr0rZvSlJKI4dVUj1UYJ07gOxzyF2UGWATju3LLOyHrsTGOtykduXejPwjQAGDlVQg8yAMMPT4mxOG69qyA54lIYtrhYdVw1F2DEyIuwYa7wEvnICGIqyT2u7y8CC1a9oJU(tE4YsmbVvSlJKI4dVUj1UYJ07gOxzyF2UGWATjl2NTuHnsHCIXwSqiSwBYI9zlvyJuiNVA5jIZerNJjIQeg34wsPDykd0Kf7ZMTevnqVYy(QLNioZqyT2Kf7ZwQWgPqoF1YteFGv8k2olzW1AkINJRDB2VKqqxYG8GFqYsy)K(zKmLYxYG6zju0sKD1hxTFjJONLODUA)syKHWsuK(vBlHZQiy95lXrWlrcZxcN(HcVeiTtzSIDzKueF41TsA1WTCUG9z7IZQ9Uj8VQbN5l8wXRyxgjfXhEDdwdk(RyxgjfXhED7X4cjQASRdRggjc2(SDXz1E3e(x1GZ8fEfHWAT5JXfsu1yxhwnmse8eMYaTIxXUmskIp86gefPWy8Wa9kJvSlJKI4dVU18Exrg6dR)k2Lrsr8Hx3AU2tKA4b1IDf7YiPi(WRBmuNLI4gAZqFy9xXUmskIp86wKv9nSE3Y(SDfExrX8X4cjQASRdRggjcEQihQRWfHWATju3LLOyHrsTGOtm2IqyT28X4cjQASRdRggjcEIXUIDzKueF41TiR6By9UL9z7QWW7kkMjACAj1GsmMYPMqqnqDxwYqXFQihQRW4g3H3vum5SQm9Ubw7546BBQihQRWduecR1MqDxwIIfgj1cIoXyxXUmskIp86MIpR2nc(BzF2UGWATznBHH2mHGAO4p5HllXSixXUmskIp86gu3LLOyHPuklTIDzKueF41TsA1WTCUWk2Lrsr8Hx3KuKurX7HcBAD3sTpBxW0ykPiPII3df206ULoF1Yte)Q8k2Lrsr8Hx3eu)dJY5ksQ2NTRbRY5ksQZqqnYhtMqD1qBMw3T0PLBx6VIDzKueF41nfFwTBe83Y(SDbH1AZA2cdTzcb1qXFYdxwI5RcwXUmskIp862JXfsu1yxhwnmseS9z7ccR1MpgxirvJDDy1WirWtykd0k2Lrsr8Hx3GE1dbdTzA5R2NTliSwBc1DzjkwyKuli6eMYavSqiSwBc1Pu4ogpMWugiCJ7cHWATjuNsH7y8yIXweMgtOx9qWqBMw(QbMgZxBVYfCOUoWaRyxgjfXhEDtkKgiSNhRyxgjfXhEDtkKgg(46k2Lrsr8Hx34SjcLOQr(osnLszj7Z2LlJCC1Oi1kvoZIUITZsW14ZQ9Lmy4V1seC(seYQG(lzq0GhxFFjHGJwY9b)syiOOLyJITebFCDjESKU68yj4Te6dXNRyxgjfXhEDtXNv7gb)TSpBxqyT2SMTWqBMqqnu8N8WLLy(cVvSlJKI4dVUfzvFdR3TSpBxd2W7kkMqDxwIIfgj1cIovKd1v4IskTdtzGML0QHB5CH5RwEI4mxLWflur6xTnSqfPF1281QIerHskTdtzGML0QHB5CH5RwEI4dRs4bgyaMVWfJTIDzKueF41n)Losnb9Fff2NTlfPF1gtkq0vSlJKI4dVU9yCHevn21HvdJebdoCwvcWbpCbUceGaaaa]] )


end