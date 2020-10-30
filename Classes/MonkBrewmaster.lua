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
            
            elseif k == "amount_to_total_percent" or k == "amounttototalpct" then
                return ceil( 100 * t.tick / t.amount_remains )

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

                if legendary.invokers_delight.enabled then
                    if buff.invokers_delight.down then stat.haste = stat.haste + 0.33 end
                    applyBuff( "invokers_delight" )
                end
            end,

            copy = "invoke_niuzao_the_black_ox",

            auras = {
                invokers_delight = {
                    id = 338321,
                    duration = 20,
                    max_stack = 1
                }
            }
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
    

    spec:RegisterSetting( "purify_for_celestial", true, {
        name = "Maximize |T1360979:0|t Celestial Brew Shield",
        desc = "If checked, the addon will focus on using |T133701:0|t Purifying Brew as often as possible, to build stacks of Purified Chi for your Celestial Brew shield.\n\n" ..
            "This is likely to work best with the Light Brewing talent, but risks leaving you without a charge of Purifying Brew following a large spike in your Stagger.\n\n" ..
            "Custom priorities may ignore this setting.",
        type = "toggle",
        width = "full",
    } )


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
    
    
    spec:RegisterSetting( "bof_percent", 50, {
        name = "|T615339:0|t Breath of Fire: Require |T594274:0|t Keg Smash %",
        desc = "If set above zero, |T615339:0|t Breath of Fire will only be recommended if this percentage of your targets are afflicted with |T594274:0|t Keg Smash.\n\n" ..
            "Example:  If set to |cFFFFD10050|r, with 2 targets, Breath of Fire will be saved until at least 1 target has Keg Smash applied.",
        type = "range",
        min = 0,
        max = 100,
        step = 0.1,
        width = "full"
    } )


    spec:RegisterSetting( "eh_percent", 65, {
        name = "|T627486:0|t Expel Harm: Health %",
        desc = "If set above zero, the addon will not recommend |T627486:0|t Expel Harm until your health falls below this percentage.",
        type = "range",
        min = 0,
        max = 100,
        step = 1,
        width = "full"
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



    spec:RegisterPack( "Brewmaster", 20201030, [[dGKaTaqiei1JOk0LqGsTjc1OOQ4uuvAviuELcmlkLULQaKDjv)svQHrv6yuv1YqqpJQktJsrxJQOTrPqFJQGgNQaDokfSoeiO5Pk09uO9bkDqeiYcvL8qeOKjQka1frGQrIajDseiXkPu9seiQzIabUjceANiKFIafdvva9uqMkO4QQcG9c5VumyKoSOfdvpMOjdLltAZs5Zuz0eCAjRwvqVwbnBfDBkz3a)gLHJOLR0Zr10fUUQA7iu9Dq14vfDEcz9ufy(iG9RYi)rWGGWYqrerOxc96Vx)8293d9AtVEIGcrKkcImLdtNIGaPLIGETkCRKh6IGitrtwIHGbbXz)vQiiHii5ee((TRcHpExYSEZlR)mJIbKB2I38Ys(gbH)RzqqbGWrqyzOiIi0lHE93RFE7(BJE(G20gqq5peylccQSiyHGekmmfGWrqykxIG84rFTkCRKh6EucImWWZUhpkbJmy46Euc9qBpkHEj0lcAw8GJGbbHPT8pdemiI8hbdckLrXaiioPMRribygES1qfbPGeFQyOxOareHiyqqkiXNkg6fcsUvOBLiiUgrbC8o5FRMitJTgPovEu58OIpQphnkl1emJv(0ifY1P8J(4rDsSUv(8OeGahf)3ADY)wTsXmsHQ)jpQ4JI)BTo5FRwPygPq1x1kla)OpEu)7EEuIDuNeRBLppQVhLae4OsgBIXGd6sDQ8OYPbFv49vTYcWp6JhLWJsSJ6KyDR85rfFuPqUoLBABkJIbY5rH9O(39ebLYOyaee5FRMOc4m4RchfiI8dbdcsbj(uXqVqqYTcDRebH)BTo5FRwPygPq1)KiOugfdGGK6u5rLtd(QWrbIiBIGbbPGeFQyOxii5wHUvIGe0CgcDszC0hpQh65rfF0cizwfWzWsR0Pg)4hf2JkO5me6w5ZJsSJ6Zr92j8OdoQph1BNWJsSJ6w2N8O(EuFpQ4JI)BTEJTr1evaNbFv4DmgCackLrXaiiS0IubgHCTqbIiprWGGuqIpvm0leKCRq3krqcAodHoPmo6Jh1tVhv8rlGKzvaNblTsNA8JFuypQGMZqOBLppkXoQph1BNWJo4O(CuVDcpkXoQBzFYJ67r99OIpQphf)3ADS0IubgHCT6ym4GJ6lckLrXaiOgBJQjQaod(QWrbIiBebdcsbj(uXqVqqPmkgabLCbINaLB20dyRrY2CIGKBf6wjcctX)TwFtpGTgjBZPbtX)TwhJbhCucqGJIP4)wRlzaSVmkIRMcm0GP4)wR)jpQ4Jg560OlO5me6KY4OpEu)8)OeGahnkl1emdwPh9XJsOxeeiTueuYfiEcuUztpGTgjBZjkqe5HiyqqPmkgab95QPc1IJGuqIpvm0luGi6brWGGszumacIKffdGGuqIpvm0luGiYgqWGGszumaccFYyyM2FfHGuqIpvm0luGiYFViyqqPmkgabHRlx3HfWHGuqIpvm0luGiYF)rWGGszumacAwoHGBE4hZzPGabPGeFQyOxOarK)eIGbbLYOyaeuRwfFYyyiifK4tfd9cfiI83pemiOugfdGGsGu5XMtJmNteKcs8PIHEHcer(BtemiifK4tfd9cbj3k0TseuuwQjygSspkShLqprqPmkgabvaIZgQgq99GKHcer(7jcgeKcs8PIHEHGKBf6wjcIRruahVt(3QjYWJ0501i)7kqEuypQ3Jk(OUL9jpQ4JYJ050TtkJJc74r5AefWX7K)TAIm8iDoDnY)UcKiOugfdGGi)B1evaNbFv4OarK)2icgeKcs8PIHEHGKBf6wjcIRruahVt(3QjYWJ0501i)7kqEuypQ3Jk(OC2KDuXhLhPZPBNughf2XJY1ikGJ3j)B1ez4r6C6AK)DfipkXoQ3UNiOugfdGGi)B1evaNbFv4OarK)EicgeKcs8PIHEHGKBf6wjcIRruahVt(3QjYWJ0501yLpfipkSh17rfFu3Y(Khv8r5r6C62jLXrHD8OCnIc44DY)wnrgEKoNUgR8PajckLrXaiiY)wnrfWzWxfokqe5)dIGbbPGeFQyOxii5wHUvIG4AefWX7K)TAIm8iDoDnw5tbYJc7r9EuXhLZMSJk(O8iDoD7KY4OWoEuUgrbC8o5FRMidpsNtxJv(uG8Oe7OE7EIGszumacI8VvtubCg8vHJcer(BdiyqqkiXNkg6fcsUvOBLiiUgrbC8o5FRMidpsNtxJ8VRa5rhpQ3Jk(OCnIc44DY)wnrgEKoNUgR8Pa5rhpQ3Jk(OUL9jpQ4JYJ050TtkJJc7rj0lckLrXaiiY)wnrfWzWxfokqerOxemiifK4tfd9cbj3k0TseexJOaoEN8VvtKHhPZPRr(3vG8OJh17rfFuUgrbC8o5FRMidpsNtxJv(uG8OJh17rfFuoBYoQ4JYJ050TtkJJc7r93lckLrXaiiY)wnrfWzWxfokqerO)iyqqkiXNkg6fcsUvOBLiibnNHqNugh9XJ65rj2rf0CwaNHtkOR2LSpiokbiWr95OcAolGZWjf0v7s2hehf2XJ63rfFubnNHqNugh9XJ6P3J6lckLrXaii9jPonc5AHceresicgeKcs8PIHEHGKBf6wjcsqZzi0jLXrF8O(5hckLrXaiibnNfWz0z9SwuGiIq)qWGGuqIpvm0leKCRq3krqsgBIXGd6K)TAIkGZGVk8UuixNYnTnLrXa58OpEuVDprqPmkgabHpt5qd7PbFv4OareH2ebdcsbj(uXqVqqYTcDReb5ZrvGUorhDWr95OkqxNO(QofCuIDujJnXyWb9HQZWTsUqFvRSa8J67r99OpEuB69OIpk(V164ZuoK9dJKzHZ6ym4GJk(OsgBIXGd6dvNHBLCH(NebLYOyaee(mLdnSNg8vHJcere6jcgeKcs8PIHEHGKBf6wjcksWWc4oQ4JI)BTo(mLdz)Wizw4Sogdo4OIpAbKmRc4myPv6udH2Gnydw8Jc7r95OcAodHUv(8Oe7OE7E98OdokpsNt3(m5Hjk5qdwALo1yZJ67rfFu8FR115Nxexn4BcFQBNhPC4rF8OeIGszumacsQtLhvon4RchfiIi0grWGGuqIpvm0leKCRq3krqrcgwa3rfFu8FR1j)B1kfZifQ(N8OIpQphf)3ADY)wTsXmsHQVQvwa(rF8O(398Oe7Ooj2rjaboQKXMym4Go5FRMOc4m4RcVVQvwa(rH9O4)wRt(3QvkMrku9vTYcWpQViOugfdGGK6u5rLtd(QWrbIic9qemiifK4tfd9cbj3k0TseeNuNttKRtd(rHD8OeIGszumacAO6mCRKlGcere(GiyqqPmkgabHPb7jcsbj(uXqVqbIicTbemiifK4tfd9cbj3k0TseeNuNttKRtd(rHD8OeEuXhf)3A99ZfkGZ8WetnWlawhJbhGGszumacA)CHc4mpmXud8cGHcer(5fbdckLrXaiiCgqX(8WGVkCeKcs8PIHEHcer(5pcgeukJIbqqTCovGHTy6IGuqIpvm0luGiYpcrWGGszumacQL6SaQHhmlseKcs8PIHEHcer(5hcgeukJIbqqW1KKb4gwZWwmDrqkiXNkg6fkqe5NnrWGGuqIpvm0leKCRq3krqrovq03pxOaoZdtm1aVayDfK4tf7OIpk(V164ZuoK9dJKzHZ6FYJk(O4)wRVFUqbCMhMyQbEbW6FseukJIbqqr501qMtluGiYpprWGGuqIpvm0leKCRq3krq4)wRJpt5q2pmsMfoR)jrqPmkgabfLtxdzoTqbIi)SremiifK4tfd9cbj3k0Tsee(V16UQfgwZecQH9SZJuo8OWEuBIGszumacsFsQtJqUwOarKFEicgeukJIbqq4ZuoK9dZWsoebPGeFQyOxOarKFpicgeukJIbqqdvNHBLCbeKcs8PIHEHcer(zdiyqqkiXNkg6fcsUvOBLiimw0LmGubXMHIzAZ0s7RALfGF0XJ6fbLYOyaeKKbKki2mumtBMwkkqeztViyqqkiXNkg6fcsUvOBLiic6JQCUcKApeuJC)YcFQgwZ0MPL2TYhYweukJIbqqcAUHr5CfivuGiYM(JGbbPGeFQyOxii5wHUvIGW)Tw3vTWWAMqqnSNDEKYHhf2XJ6hckLrXaii9jPonc5AHcer2KqemiOugfdGGc2xkyyndMMHacsbj(uXqVqbIiB6hcgeKcs8PIHEHGKBf6wjcc)3A99ZfkGZ8WetnWlawhJbhGGszumacA)CHc4mpmXud8cGHcer20MiyqqkiXNkg6fcsUvOBLii8FR1XNPCi7hgjZcN1XyWbhv8r95O4)wRJpzmS5NhDmgCWrjaboQphf)3AD8jJHn)8O)jpQ4JIXIo(QziyyntRw1GXI(QTv5cj(upQVh1xeukJIbqq4RMHGH1mTAvuGiYMEIGbbLYOyaeKuOm4)LhiifK4tfd9cfiISPnIGbbLYOyaeKuOmWtIRiifK4tfd9cfiISPhIGbbPGeFQyOxii5wHUvIGW)Tw3vTWWAMqqnSNDEKYHhf2XJsickLrXaii9jPonc5AHcer28brWGGuqIpvm0leKCRq3krqPmkIRgfOwLYpkSJh1VJk(OsgBIXGd6dvNHBLCH(Qwzb4hf2JQpv5putuw6rfFuFoQc01j6OdoQphvb66e1x1PGJsSJ6ZrLm2eJbh0hQod3k5c9vTYcWp6GJQpv5putuw6r99O(EuFpkSJh1g9ebLYOyaeeNSaGc4mYnbQzyjhIcer20gqWGGuqIpvm0leKCRq3krqe0hnYPcIo(mLdz)Wizw4SUcs8PIDuXhvYytmgCqFO6mCRKl0x1kla)OWEuNe7OIpQphvb66eD0bh1NJQaDDI6R6uWrj2r95OsgBIXGd6dvNHBLCH(Qwzb4hDWrDsSJ67r99O(EuyhpQn6jckLrXaiOOC6AiZPfkqe5PxemiifK4tfd9cbj3k0TseKc01j6OpEu)8hbLYOyaeuUYeOMGTRccuGiYt)rWGGszumacA)CHc4mpmXud8cGHGuqIpvm0luGcee5QsMfEgiyqe5pcgeukJIbqqTPYfKB2ceKcs8PIHEHcereIGbbLYOyaeKuOm4)LhiifK4tfd9cfiI8dbdckLrXaiiPqzGNexrqkiXNkg6fkqbkqqexxEXaiIi0lHE93lHEiccEUGc44iickwKSnuSJs4rtzumWrNfp49ZocItQsereAJpicICzTAQiipE0xRc3k5HUhLGidm8S7XJsWidgUUh1pV2Euc9sO3Z(z3JhLG)uL)qXokU2yREujZcpJJIRUcW7hLGKuQKb)Oag4bKqUwT)8OPmkgGFugykQF2tzumaVtUQKzHNXGX3TPYfKB2IZEkJIb4DYvLml8mgm(wkug8)YJZEkJIb4DYvLml8mgm(wkug4jX1Z(z3JhLG)uL)qXoQsCDfD0OS0Jgc6rtzW2Jw8JMepRzIp1(zpLrXa8roPMRribygES1q9SF2tzumaFW4BY)wnrfWzWxfUTvBKRruahVt(3QjY0yRrQtLhvof7tuwQjygR8PrkKRt5p6KyDR8jbia(V16K)TALIzKcv)tkg)3ADY)wTsXmsHQVQvwa(J(39Kyojw3kF6lbiGKXMym4GUuNkpQCAWxfEFvRSa8hjKyojw3kFkwkKRt5M2MYOyGCcR)Dpp7PmkgGpy8TuNkpQCAWxfUTvBe)3ADY)wTsXmsHQ)jp7PmkgGpy8nwArQaJqUw2wTrbnNHqNugp6HEkUasMvbCgS0kDQXpoScAodHUv(Ky(4Tt4aF82jKyUL9j91xX4)wR3yBunrfWzWxfEhJbhC2tzumaFW47gBJQjQaod(QWTTAJcAodHoPmE0tVIlGKzvaNblTsNA8JdRGMZqOBLpjMpE7eoWhVDcjMBzFsF9vSp4)wRJLwKkWiKRvhJbh47z)SNYOya(GX3FUAQqTSfKw6yYfiEcuUztpGTgjBZPTvBetX)TwFtpGTgjBZPbtX)TwhJbhqacGP4)wRlzaSVmkIRMcm0GP4)wR)jfh560OlO5me6KY4r)8Naeikl1emdwPpsO3ZEkJIb4dgF)5QPc1IF2tzumaFW4BswumWzpLrXa8bJVXNmgMP9xrN9ugfdWhm(gxxUUdlG7SNYOya(GX3ZYjeCZd)yolfeN9ugfdWhm(UvRIpzmSZEkJIb4dgFNaPYJnNgzoNN9ugfdWhm(UaeNnunG67bjZecQbFMYHg2tBR2yuwQjygSsHLqpp7NDpE0h4FRMOc4okUkKeVy)9Of)O4jxXokdCuaBTYz5bzumWr9Pi4hne0JoZqpQ(KCvoVyGJgB5C6YpA1okpsNt3JYlpqpAbKRMCf7OmIR7rdb9OZKhh1pVhnk5q(rz7r93ZJYvjdGX9TF294rtzumaFW4BY)wnrfWzWxfUTvBKRruahVt(3QjYWJ0501i)7kqo6vmxJOaoEN8VvtKHhPZPRXkFkqo6vSuixNYhLc56uUXkFkMhPZPBxqtIlsSp4)wRt(3QvkMrkuDmgCabia(V16K)TALIzKcvFvRSa8h9V7jXCsmFflzSjgdoOl1PYJkNg8vH3x1kla)rpp7NDpE0h4FRMOc4okUkKeVy)9Of)O4jxXokdCuaBTYz5bzumq)S7XJMYOya(GX3K)TAIkGZGVkCBR2ixJOaoEN8VvtKHhPZPRr(3vGC0RyUgrbC8o5FRMidpsNtxJv(uGC0RyEKoNUDszaR)p4z3JhnLrXa8bJVj)B1evaNbFv42wTrUgrbC8o5FRMidpsNtxJ8VRa5OxXCnIc44DY)wnrgEKoNUgR8Pa5OxX8iDoD7KYawBqmpsNt3EAX(GWemtWICAiLbSE63z3JhnLrXa8bJVj)B1evaNbFv42wTrUgrbC8o5FRMidpsNtxJ8VRa5OxXCnIc44DY)wnrgEKoNUgR8Pa5OxX8iDoD7KYawB29umpsNt3EAX(GWemtWICAiLbSEO)NDpE0ugfdWhm(M8VvtubCg8vHBB1g5AefWX7K)TAIm8iDoDnY)UcKJEfZ1ikGJ3j)B1ez4r6C6ASYNcKJEfZJ050Ttkdy9tmpsNt3EAX(GWemtWICAiLbSpO3Z(z3Jh9bGRhvYaTY9xf7OK)TAIm8iDoDnY)UcKhTTmRJ(Av4wjp09OmYOyaE)SNYOya(GX3K)TAIkGZGVkCBR2ixJOaoEN8VvtKHhPZPRr(3vGewVIDl7tkMhPZPBNugWoY1ikGJ3j)B1ez4r6C6AK)Dfip7PmkgGpy8n5FRMOc4m4Rc32QnY1ikGJ3j)B1ez4r6C6AK)DfiH1RyoBYeZJ050Ttkdyh5AefWX7K)TAIm8iDoDnY)UcKeZB3ZZ(z3Jh9bGRhvYaTY9xf7OK)TAIm8iDoDnw5tbYJ2wM1rFTkCRKh6EugzumaVF2tzumaFW4BY)wnrfWzWxfUTvBKRruahVt(3QjYWJ0501yLpfiH1Ry3Y(KI5r6C62jLbSJCnIc44DY)wnrgEKoNUgR8Pa5zpLrXa8bJVj)B1evaNbFv42wTrUgrbC8o5FRMidpsNtxJv(uGewVI5SjtmpsNt3oPmGDKRruahVt(3QjYWJ0501yLpfijM3UNN9ZUhpkuKoNUhLG9rzTJsO3JcVMZJoSMZJkI9pAbokHDppkxLmag)OWRqG9JJkO5SaUJY2Js(3QjQaU(rp6daxXokCbfCuY)wnrgEKoNUg5FxbYJMaSJALpfipAU6rXkEIpvS(zpLrXa8bJVj)B1evaNbFv42wTrUgrbC8o5FRMidpsNtxJ8VRa5OxXCnIc44DY)wnrgEKoNUgR8Pa5OxXUL9jfZJ050Ttkdyj07zpLrXa8bJVj)B1evaNbFv42wTrUgrbC8o5FRMidpsNtxJ8VRa5OxXCnIc44DY)wnrgEKoNUgR8Pa5OxXC2KjMhPZPBNugW6V3Z(z3JhLGQMZc4okbFwpR9SNYOya(GX36tsDAeY1Y2QnkO5me6KY4rpjMGMZc4mCsbD1UK9bbbiGpcAolGZWjf0v7s2heWo6NybnNHqNugp6PxFp7PmkgGpy8TGMZc4m6SEwRTvBuqZzi0jLXJ(53z)S7XJ(AMYHhLG55rFTk8Jw8Jk)7QGyk6OFUID0GDuTcbDp6QKtfuCHJIVkC(rXtUIDug4OtLZpAiKGJkKZ2rZJIVk8JkfY1PhnjEwZeFQ2Eu2E0jd(rvGUorhnyhvbj(upkbz1DuiRKlC2tzumaFW4B8zkhAypn4Rc32QnkzSjgdoOt(3QjQaod(QW7sHCDk302ugfdKZh9298SNYOya(GX34Zuo0WEAWxfUTvB0hfORt0aFuGUor9vDkGysgBIXGd6dvNHBLCH(Qwzb4(67J20Ry8FR1XNPCi7hgjZcN1XyWbILm2eJbh0hQod3k5c9p5z)S7XJsWsNkpQCE0xRc)OKBX2keDu4ckqjUUhTIJgm2WJYlhOALmbXrXsR0PhnbyhTwgGpSahfFv4hf)3AhT4h1Q48c4oQpj2d)84OHGEubnNHq3kFEujtBTswkioAkLSfRaUJgSJwGqb8keDuw7OyPv60Jg5qf4RThnbyhnyhf7BrEu9Pu58JkfY1P8JIRn2Qh9f7v)SNYOya(GX3sDQ8OYPbFv42wTXibdlGtm(V164ZuoK9dJKzHZ6ym4aXfqYSkGZGLwPtneAd2GnyXH1hbnNHq3kFsmVDVEoGhPZPBFM8WeLCOblTsNASPVIX)TwxNFErC1GVj8PUDEKYHps4zpLrXa8bJVL6u5rLtd(QWTTAJrcgwaNy8FR1j)B1kfZifQ(NuSp4)wRt(3QvkMrku9vTYcWF0)UNeZjXiabKm2eJbh0j)B1evaNbFv49vTYcWHf)3ADY)wTsXmsHQVQvwaUVN9ZUhpkbtRPaErCDkY2Jgc6rji9aji4OKBX2kkpq5hLGm0rzGJkNAsC12J(IbDuDYvBpk8keoQc01j6OCsfGPl)Oja7Osm(r5SnuSJIRtg8ZEkJIb4dgFpuDgUvYfSTAJCsDonrUon4Wos4z)SNYOya(GX3yAWEE2tzumaFW479ZfkGZ8WetnWlaMTvBKtQZPjY1Pbh2rcfJ)BT((5cfWzEyIPg4faRJXGdo7N9ugfdWhm(gNbuSppm4Rc)SNYOya(GX3TCovGHTy6E2tzumaFW47wQZcOgEWSip7PmkgGpy8nCnjzaUH1mSft3ZEkJIb4dgFhLtxdzoTSTAJrovq03pxOaoZdtm1aVayDfK4tftm(V164ZuoK9dJKzHZ6FsX4)wRVFUqbCMhMyQbEbW6FYZEkJIb4dgFhLtxdzoTSTAJ4)wRJpt5q2pmsMfoR)jp7PmkgGpy8T(KuNgHCTSTAJ4)wR7QwyyntiOg2Zops5qyT5zpLrXa8bJVXNPCi7hMHLC4zpLrXa8bJVhQod3k5cN9ugfdWhm(wYasfeBgkMPntl12QnIXIUKbKki2mumtBMwAFvRSa8rVN9ugfdWhm(wqZnmkNRaPAB1gjOvoxbsThcQrUFzHpvdRzAZ0s7w5dz7zpLrXa8bJV1NK60iKRLTvBe)3ADx1cdRzcb1WE25rkhc7OFN9ugfdWhm(oyFPGH1myAgcN9ugfdWhm(E)CHc4mpmXud8cGzB1gX)TwF)CHc4mpmXud8cG1XyWbN9ugfdWhm(gF1memSMPvRAB1gX)TwhFMYHSFyKmlCwhJbhi2h8FR1XNmg28ZJogdoGaeWh8FR1XNmg28ZJ(Numgl64RMHGH1mTAvdgl6R2wLlK4t1xFp7PmkgGpy8TuOm4)LhN9ugfdWhm(wkug4jX1ZUhpkb)jPopkb1CToQqYpQq5e09OpGFGeCyoAiKGJcZd8OWfuWrfX(hvijUE0mo6utECucpkBX59ZEkJIb4dgFRpj1PrixlBR2i(V16UQfgwZecQH9SZJuoe2rcp7PmkgGpy8nNSaGc4mYnbQzyjhAB1gtzuexnkqTkLd7OFILm2eJbh0hQod3k5c9vTYcWHvFQYFOMOSuX(OaDDIg4Jc01jQVQtbeZhjJnXyWb9HQZWTsUqFvRSa8b6tv(d1eLL6RV(c7On65zpLrXa8bJVJYPRHmNw2wTrc6iNki64ZuoK9dJKzHZ6kiXNkMyjJnXyWb9HQZWTsUqFvRSaCyDsmX(OaDDIg4Jc01jQVQtbeZhjJnXyWb9HQZWTsUqFvRSa8bojMV(6lSJ2ONN9ugfdWhm(oxzcutW2vbHTvBub66e9OF(F2tzumaFW479ZfkGZ8WetnWlagkqbcb]] )


end