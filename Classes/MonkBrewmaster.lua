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


    spec:RegisterPack( "Brewmaster", 20201027, [[dGeGUaqivLu9ivLQlriHAteQrrvXPOQ0QiK6vsvnlQsUfvPKSlv8le0WOIogvvTmeYZOQY0OcCnQqBJQu13iK04OkvoNQszDQkj08ieUNuzFQQ6GQkjzHQkEiHeYePkLuxKqIgPQskDsvLuSsQIxQQKuZuvjb3uvjr7eH6NesWqPkL6PQYurGRsvkXEH8xkgmuhw0Ir0JjAYi5YK2Su(mLgnbNwYQvvIxlvz2GCBQ0Ub(nQgoOwUsphLPlCDvA7eI(osz8QQCEKQ1tvkMpvq7xXi)reGEuzOiIjYjro93jrI6X5383F0lOdROhCk7Lwf9aPRIEFwLMBYcDrp4KoepPqeGEm(DLk6jebm7RiHeARq4sEKCxczL7fkJIdKB2cczLRKq0J8wqXxdarIEuzOiIjYjro93jrI6X5383Pd(g6L3qGVO3RCffHEcffLcqKOhLYKO33h8NvP5MSq3b)vYb9gpFFWIcYGtQ7Gjsu9AWe5KiNOhuXcgIa0JsB5fkqeGi2FebOxkJIdqpgSMRribugwSvpf9uqscPuOpOarmricqpfKKqkf6d6j3k0Ts0tqtOq4alJblIblQooyXdUasUBbSgQ0nTQXp2G)pybnHcHJB(BWIEW(myNhIgC)b7ZGDEiAWIEW2LFHhSVd23blEWK3w704Bun6fWAixL2HItdGEPmkoa9OsxyfyeY1ffiI9dra6PGKesPqFqp5wHUvIEcAcfchyzmyrmyhDoyXdUasUBbSgQ0nTQXp2G)pybnHcHJB(BWIEW(myNhIgC)b7ZGDEiAWIEW2LFHhSVd23blEW(myYBRDOsxyfyeY19qXPbgSVOxkJIdqVgFJQrVawd5Q0qbIyhGia9uqscPuOpOxkJIdqVKjiYeOmZMEdFns(MqONCRq3krpkL82ANn9g(AK8nHmuk5T1ouCAGb7qhoykL82AhjhqDLrjs1uGEgkL82ANl8Gfp4ixRghbnHcHdSmgSigSF(pyh6WbhLRAcUHQ0blIbtKt0dKUk6LmbrMaLz20B4RrY3ecfiIDera6LYO4a07YutfQld9uqscPuOpOarS3Jia9szuCa6bZJIdqpfKKqkf6dkqelQicqVugfhGEKqCoLPDx6ONcssiLc9bfiI9oebOxkJIdqpsDz62Raw0tbjjKsH(GceXFdra6LYO4a0dQScbZ8LlL1vbb6PGKesPqFqbIy)DIia9szuCa61QvjH4Ck0tbjjKsH(GceX(7pIa0lLrXbOxcKkl2eYitii0tbjjKsH(GceX(teIa0tbjjKsH(GEYTcDRe9IYvnb3qv6G)pyICe9szuCa6varY7PgqD9MKJceX(7hIa0tbjjKsH(GEYTcDRe9yAefWYoW3TA0nSiTwDnY7UcWdUBWohS4bZ0ikGLDGVB1OByrAT6ACZFcWdUBWohS4blfY1QSb3nyPqUwLzCZFdw8GzrAT6Ee0uK0hS4b7ZGjVT2b(UvRukJuOouCAGb7qhoyYBRDGVB1kLYifQZQUzbydwed2)JJdw0d2kPgSVdw8GLCoefNg4iviLfvczixL2zv3SaSblIb7i6LYO4a0d(UvJEbSgYvPHceX(7aebONcssiLc9b9KBf6wj6X0ikGLDGVB1OByrAT6AK3DfGhC3GDoyXdMPrual7aF3Qr3WI0A114M)eGhC3GDoyXdMfP1Q7bwgd()G937qVugfhGEW3TA0lG1qUknuGi2FhreGEkijHuk0h0tUvOBLOhtJOaw2b(UvJUHfP1QRrE3vaEWDd25GfpyMgrbSSd8DRgDdlsRvxJB(taEWDd25GfpywKwRUhyzm4)d(Bdw8GzrAT6Esx(feMGBcEKqgyzm4)d2r)qVugfhGEW3TA0lG1qUknuGi2FVhra6PGKesPqFqp5wHUvIEmnIcyzh47wn6gwKwRUg5Dxb4b3nyNdw8GzAefWYoW3TA0nSiTwDnU5pb4b3nyNdw8GzrAT6EGLXG)pyhCCCWIhmlsRv3t6YVGWeCtWJeYalJb)FWIQ)OxkJIdqp47wn6fWAixLgkqe7VOIia9uqscPuOpONCRq3krpMgrbSSd8DRgDdlsRvxJ8URa8G7gSZblEWmnIcyzh47wn6gwKwRUg38Na8G7gSZblEWSiTwDpWYyW)hSFdw8GzrAT6Esx(feMGBcEKqgyzm4)d27CIEPmkoa9GVB1OxaRHCvAOarS)EhIa0tbjjKsH(GEYTcDRe9yAefWYoW3TA0nSiTwDnY7UcWd()GDoyXd2U8l8GfpywKwRUhyzm4)DdMPrual7aF3Qr3WI0A11iV7kaJEPmkoa9GVB1OxaRHCvAOarS)Fdra6PGKesPqFqp5wHUvIEmnIcyzh47wn6gwKwRUg5Dxb4b)FWohS4bZ4q8blEWSiTwDpWYyW)7gmtJOaw2b(UvJUHfP1QRrE3vaEWIEWopoIEPmkoa9GVB1OxaRHCvAOarmroreGEkijHuk0h0tUvOBLOhtJOaw2b(UvJUHfP1QRXn)jap4)d25Gfpy7YVWdw8GzrAT6EGLXG)3nyMgrbSSd8DRgDdlsRvxJB(tag9szuCa6bF3QrVawd5Q0qbIyI8hra6PGKesPqFqp5wHUvIEmnIcyzh47wn6gwKwRUg38Na8G)pyNdw8GzCi(GfpywKwRUhyzm4)DdMPrual7aF3Qr3WI0A114M)eGhSOhSZJJOxkJIdqp47wn6fWAixLgkqetericqpfKKqkf6d6j3k0Ts0JPrual7aF3Qr3WI0A11iV7kap4Ub7CWIhmtJOaw2b(UvJUHfP1QRXn)jap4Ub7CWIhSD5x4blEWSiTwDpWYyW)hmrorVugfhGEW3TA0lG1qUknuGiMi)qeGEkijHuk0h0tUvOBLOhtJOaw2b(UvJUHfP1QRrE3vaEWDd25GfpyMgrbSSd8DRgDdlsRvxJB(taEWDd25GfpyghIpyXdMfP1Q7bwgd()G93j6LYO4a0d(UvJEbSgYvPHceXe5aebONcssiLc9b9KBf6wj6jOjuiCGLXGfXGDCWIEWcAcvaRHblOREK8ligSdD4G9zWcAcvaRHblOREK8lig8)Ub73GfpybnHcHdSmgSigSJohSVOxkJIdqp9hSczeY1ffiIjYrebONcssiLc9b9KBf6wj6jOjuiCGLXGfXG9Zp0lLrXbONGMqfWAuO6xTOarmrEpIa0tbjjKsH(GEYTcDRe9KCoefNg4aF3QrVawd5Q0osHCTkZ02ugfhKqdwed25Xr0lLrXbOhjuk7z4)mKRsdfiIjsureGEkijHuk0h0tUvOBLONpdwb6APp4(d2NbRaDT0pRAvWGf9GLCoefNg40tTgMBYeoR6MfGnyFhSVdwed2bohS4btEBTdjuk7XVHrYDj5hkonWGfpyjNdrXPbo9uRH5MmHZfg9szuCa6rcLYEg(pd5Q0qbIyI8oebONcssiLc9b9KBf6wj6fjOxbSdw8GjVT2HekL943Wi5UK8dfNgyWIhCbKC3cynuPBAvdrF7BFZLn4)d2NblOjuiCCZFdw0d25XPJdU)GzrAT6EGswyIs2ZqLUPvnoyW(oyXdM82Ahf6YkrQgYnPbP7HfPS3GfXGjc9szuCa6jviLfvczixLgkqet03qeGEkijHuk0h0tUvOBLOxKGEfWoyXdM82Ah47wTsPmsH6CHhS4b7ZGjVT2b(UvRukJuOoR6MfGnyrmy)pooyrpyRKAWo0HdwY5quCAGd8DRg9cynKRs7SQBwa2G)pyYBRDGVB1kLYifQZQUzbyd2x0lLrXbONuHuwujKHCvAOarSForeGEkijHuk0h0tUvOBLOhdwHGmrUwnyd(F3Gjc9szuCa61tTgMBYeqbIy)8hra6LYO4a0Jsd(p0tbjjKsH(GceX(reIa0tbjjKsH(GEYTcDRe9yWkeKjY1QbBW)7gmrdw8GjVT2zVmHcynFjPudTcqDO40aOxkJIdqV9YekG18LKsn0kafkqe7NFicqVugfhGEKCGsDzHHCvAONcssiLc9bfiI9ZbicqVugfhGETecsbg(sPl6PGKesPqFqbIy)Cera6LYO4a0RLkubudl4UWONcssiLc9bfiI9Z7reGEPmkoa9OPjmhWm8MHVu6IEkijHuk0huGi2prfra6PGKesPqFqp5wHUvIErcPG4SxMqbSMVKuQHwbOokijHuQblEWK3w7qcLYE8ByKCxs(5cpyXdM82AN9YekG18LKsn0ka15cJEPmkoa9IYQRboHCrbIy)8oebONcssiLc9b9KBf6wj6rEBTdjuk7XVHrYDj5Nlm6LYO4a0lkRUg4eYffiI97BicqpfKKqkf6d6j3k0Ts0J82AhB1cdVzcb1W)Dyrk7n4)d2bOxkJIdqp9hSczeY1ffiIDGtebOxkJIdqpsOu2JFdtVs2d9uqscPuOpOarSd8hra6LYO4a0RNAnm3KjGEkijHuk0huGi2beHia9uqscPuOpONCRq3krpkECKCGubXMHszAqPREw1nlaBWDd2j6LYO4a0tYbsfeBgkLPbLUkkqe7a)qeGEkijHuk0h0tUvOBLO3xFWkJPaPEcb1i3RSiHudVzAqPRECZVWx0lLrXbONGMByugtbsffiIDGdqeGEkijHuk0h0tUvOBLOh5T1o2QfgEZecQH)7WIu2BW)7gSFOxkJIdqp9hSczeY1ffiIDGJicqVugfhGEb)kfm8MHsZqa9uqscPuOpOarSd8EebONcssiLc9b9KBf6wj6rEBTZEzcfWA(ssPgAfG6qXPbqVugfhGE7LjuaR5ljLAOvakuGi2bIkIa0tbjjKsH(GEYTcDRe9iVT2HekL943Wi5UK8dfNgyWIhSpdM82AhsioNc6YIdfNgyWo0Hd2NbtEBTdjeNtbDzX5cpyXdMIhhYvZqWWBMwTQHIhNvBRYessiDW(oyFrVugfhGEKRMHGH3mTAvuGi2bEhIa0lLrXbONuOmK3LfONcssiLc9bfiIDW3qeGEPmkoa9KcLHwksf9uqscPuOpOarSJoreGEkijHuk0h0tUvOBLOh5T1o2QfgEZecQH)7WIu2BW)7gmrOxkJIdqp9hSczeY1ffiID0FebONcssiLc9b9KBf6wj6LYOePAuG6wkBW)7gSFdw8GLCoefNg40tTgMBYeoR6MfGn4)dw)PYBOMOC1blEW(myfORL(G7pyFgSc01s)SQvbdw0d2Nbl5CikonWPNAnm3KjCw1nlaBW9hS(tL3qnr5Qd23b77G9DW)7gS37i6LYO4a0JbxaqbSg5Ma10RK9qbIyhjcra6PGKesPqFqp5wHUvIEF9bhjKcIdjuk7XVHrYDj5hfKKqk1GfpyjNdrXPbo9uRH5MmHZQUzbyd()GTsQblEW(myfORL(G7pyFgSc01s)SQvbdw0d2Nbl5CikonWPNAnm3KjCw1nlaBW9hSvsnyFhSVd23b)VBWEVJOxkJIdqVOS6AGtixuGi2r)qeGEkijHuk0h0tUvOBLONc01sFWIyW(5p6LYO4a0lxzcutW3vbbkqe7OdqeGEPmkoa92ltOawZxsk1qRauONcssiLc9bfOa9GxvYDjZaraIy)reGEPmkoa9AqktqUzlqpfKKqkf6dkqeteIa0lLrXbONuOmK3LfONcssiLc9bfiI9dra6LYO4a0tkugAPiv0tbjjKsH(GcuGc0tK6YkoarmrojYP)ojYr0JwUGcyzO3xJlmFdLAWen4ugfhmyOIfSZ4b9yWQermrEV3HEWlVvqk699b)zvAUjl0DWFLCqVXZ3hSOGm4K6oyIevVgmrojY54z889blk)PYBOudMuB8vhSK7sMXGjvBbyNb)vjLkCWgmGd8wjKRB7cn4ugfhWgmhar)mEszuCa7aVQK7sMr)ocBqktqUzlgpPmkoGDGxvYDjZOFhHsHYqExwmEszuCa7aVQK7sMr)ocLcLHwksD8mE((GfL)u5nuQbRIux6dokxDWHGo4ug8DWfBWPiZckjH0Z4jLrXbSogSMRribugwSvpD8KYO4aw)ocPsxyfyeY11RQ1jOjuiCGLHievhfxaj3Tawdv6Mw14h7VGMqHWXn)jAFCEiQVpopejA7YVW(6RyYBRDA8nQg9cynKRs7qXPbgpPmkoG1VJWgFJQrVawd5Q08QADcAcfchyzichDkUasUBbSgQ0nTQXp2FbnHcHJB(t0(48quFFCEis02LFH91xX(qEBTdv6cRaJqUUhkonGVJNugfhW63r4LPMkuxVaPR2LmbrMaLz20B4RrY3eYRQ1rPK3w7SP3WxJKVjKHsjVT2HItd4qhsPK3w7i5aQRmkrQMc0ZqPK3w7CHfh5A14iOjuiCGLHi8ZFh6WOCvtWnuLkcICoEszuCaRFhHxMAQqDzJNugfhW63rimpkoy8KYO4aw)ocjH4Ckt7U0hpPmkoG1VJqsDz62Ra2XtkJIdy97ieQScbZ8LlL1vbX4jLrXbS(De2QvjH4CQXtkJIdy97imbsLfBczKje04jLrXbS(DewarY7PgqD9MKBcb1qcLYEg(pVQwxuUQj4gQs)tKJJNXZ3hS3(UvJEbSdMufsrw87o4InyYKPudMdgmGVUju5nzuCWG9PeLdoe0bdLHoy9h8QmwXbdo2YA1Ln4QnywKwRUdMvEJo4cixnzk1G5Iu3bhc6GHswmy)Co4OK9ydMVd2FhhmtLCafZ3Z4jLrXbS(DecF3QrVawd5Q08QADmnIcyzh47wn6gwKwRUg5Dxb4oNIzAefWYoW3TA0nSiTwDnU5pb4oNILc5AvwNuixRYmU5pXSiTwDpcAks6I9H82Ah47wTsPmsH6qXPbCOdjVT2b(UvRukJuOoR6MfGjc)pokARKYxXsohIItdCKkKYIkHmKRs7SQBwaMiCC8mE((G923TA0lGDWKQqkYIF3bxSbtMmLAWCWGb81nHkVjJIdoJNugfhW63ri8DRg9cynKRsZRQ1X0ikGLDGVB1OByrAT6AK3DfG7CkMPrual7aF3Qr3WI0A114M)eG7CkMfP1Q7bwg)937gpPmkoG1VJq47wn6fWAixLMxvRJPrual7aF3Qr3WI0A11iV7ka35umtJOaw2b(UvJUHfP1QRXn)ja35umlsRv3dSm()nXSiTwDpPl)cctWnbpsidSm(7OFJNugfhW63ri8DRg9cynKRsZRQ1X0ikGLDGVB1OByrAT6AK3DfG7CkMPrual7aF3Qr3WI0A114M)eG7CkMfP1Q7bwg)DWXrXSiTwDpPl)cctWnbpsidSm(lQ(pEszuCaRFhHW3TA0lG1qUknVQwhtJOaw2b(UvJUHfP1QRrE3vaUZPyMgrbSSd8DRgDdlsRvxJB(taUZPywKwRUhyz83pXSiTwDpPl)cctWnbpsidSm(7DohpJNVpyVfMoyjh0k7DvQbdF3Qr3WI0A11iV7kap42YDh8NvP5MSq3bZHJIdyNXtkJIdy97ie(UvJEbSgYvP5v16yAefWYoW3TA0nSiTwDnY7UcW)Dk2U8lSywKwRUhyz8VJPrual7aF3Qr3WI0A11iV7kapEszuCaRFhHW3TA0lG1qUknVQwhtJOaw2b(UvJUHfP1QRrE3va(VtXmoexmlsRv3dSm(3X0ikGLDGVB1OByrAT6AK3DfGfTZJJJNXZ3hS3cthSKdAL9Uk1GHVB1OByrAT6ACZFcWdUTC3b)zvAUjl0DWC4O4a2z8KYO4aw)ocHVB1OxaRHCvAEvToMgrbSSd8DRgDdlsRvxJB(ta(VtX2LFHfZI0A19alJ)DmnIcyzh47wn6gwKwRUg38Na84jLrXbS(DecF3QrVawd5Q08QADmnIcyzh47wn6gwKwRUg38Na8FNIzCiUywKwRUhyz8VJPrual7aF3Qr3WI0A114M)eGfTZJJJNXZ3h8lsRv3blkEW82GjY5GPvqqdUxbbny687GlWGj644GzQKdOydMwfc8BmybnHkGDW8DWW3TA0lG9m4b7TWuQbttqbdg(UvJUHfP1QRrE3vaEWjGAWU5pb4bNRoyQILKqk1z8KYO4aw)ocHVB1OxaRHCvAEvToMgrbSSd8DRgDdlsRvxJ8URaCNtXmnIcyzh47wn6gwKwRUg38NaCNtX2LFHfZI0A19alJ)e5C8KYO4aw)ocHVB1OxaRHCvAEvToMgrbSSd8DRgDdlsRvxJ8URaCNtXmnIcyzh47wn6gwKwRUg38NaCNtXmoexmlsRv3dSm(7VZXZ457d(RvtOcyhSOeQ(v74jLrXbS(DeQ)GviJqUUEvTobnHcHdSmeHJIwqtOcynmybD1JKFbHdDOpcAcvaRHblOREK8li(35NybnHcHdSmeHJo9D8KYO4aw)ocf0eQawJcv)Q1RQ1jOjuiCGLHi8ZVXZ457d(duk7nyrHFd(ZQ0gCXgS8URcci6d(YuQbh8bRviO7GxfgsbftyWKRsJnyYKPudMdgmKYydoesWGfsO2GZbtUkTblfY1QdofzwqjjK61G57GH40gSc01sFWbFWkijH0b)vR2b)CtMW4jLrXbS(DescLYEg(pd5Q08QADsohIItdCGVB1OxaRHCvAhPqUwLzABkJIdsir48444jLrXbS(DescLYEg(pd5Q08QAD(OaDT077Jc01s)SQvbIwY5quCAGtp1AyUjt4SQBwaMV(kch4um5T1oKqPSh)ggj3LKFO40aILCoefNg40tTgMBYeox4XZ457dwuKcPSOsOb)zvAdgEl(wb9bttqbQi1DWvm4GZ7nywzbvRKjigmv6MwDWjGAW1YbSEfyWKRsBWK3wBWfBWUfJva7G9jP(YLfdoe0blOjuiCCZFdwY1wRKLcIbNsjFPkGDWbFWfiuaRc6dM3gmv6MwDWr2tb(61Gta1Gd(GPUUWdw)jvgBWsHCTkBWKAJV6G)W)CgpPmkoG1VJqPcPSOsid5Q08QADrc6vaRyYBRDiHszp(nmsUlj)qXPbexaj3Tawdv6Mw1q03(23Cz)9rqtOq44M)eTZJth7ZI0A19aLSWeLSNHkDtRACGVIjVT2rHUSsKQHCtAq6Eyrk7jcIgpPmkoG1VJqPcPSOsid5Q08QADrc6vaRyYBRDGVB1kLYifQZfwSpK3w7aF3QvkLrkuNvDZcWeH)hhfTvs5qhk5CikonWb(UvJEbSgYvPDw1nla7p5T1oW3TALszKc1zv3SamFhpJNVpyrHwtbSsKkeDVgCiOd(RYB)vyWWBX3kkVrzd(R(nyoyWsinfP61G)WFdwHyQxdMwfcdwb6APpygScO0Ln4eqnyjfBWm(gk1GjvioTXtkJIdy97iSNAnm3Kj4v16yWkeKjY1Qb7FhrJNXtkJIdy97iKsd(VXtkJIdy97iCVmHcynFjPudTcq5v16yWkeKjY1Qb7FhrIjVT2zVmHcynFjPudTcqDO40aJNXtkJIdy97iKKduQllmKRsB8KYO4aw)ocBjeKcm8Ls3XtkJIdy97iSLkubudl4UWJNugfhW63rinnH5aMH3m8Ls3XtkJIdy97imkRUg4eY1RQ1fjKcIZEzcfWA(ssPgAfG6OGKesPetEBTdjuk7XVHrYDj5NlSyYBRD2ltOawZxsk1qRauNl84jLrXbS(DegLvxdCc56v16iVT2HekL943Wi5UK8ZfE8KYO4aw)oc1FWkKrixxVQwh5T1o2QfgEZecQH)7WIu27VdgpPmkoG1VJqsOu2JFdtVs2B8KYO4aw)oc7PwdZnzcJNugfhW63rOKdKki2muktdkDvVQwhfposoqQGyZqPmnO0vpR6MfG15C8KYO4aw)ocf0CdJYykqQEvTUVUYykqQNqqnY9klsi1WBMgu6Qh38l8D8KYO4aw)oc1FWkKrixxVQwh5T1o2QfgEZecQH)7WIu27FNFJNugfhW63ryWVsbdVzO0megpPmkoG1VJW9YekG18LKsn0kaLxvRJ82AN9YekG18LKsn0ka1HItdmEszuCaRFhHKRMHGH3mTAvVQwh5T1oKqPSh)ggj3LKFO40aI9H82AhsioNc6YIdfNgWHo0hYBRDiH4CkOlloxyXu84qUAgcgEZ0Qvnu84SABvMqscP(674jLrXbS(Dekfkd5DzX4jLrXbS(DekfkdTuK6457dwu(dwHg8xBUUdwizdwOSc6oyV1EBrjbdoesWGjWBpyAckyW053blKIuhCgdgstwmyIgmFjzNXtkJIdy97iu)bRqgHCD9QADK3w7yRwy4ntiOg(VdlszV)DenEszuCaRFhHm4cakG1i3eOMELSNxvRlLrjs1Oa1Tu2)o)el5CikonWPNAnm3KjCw1nla7V(tL3qnr5QI9rb6AP33hfORL(zvRceTpsohIItdC6PwdZnzcNvDZcW6R)u5nutuUQV(67)oV3XXtkJIdy97imkRUg4eY1RQ191JesbXHekL943Wi5UK8JcssiLsSKZHO40aNEQ1WCtMWzv3SaS)wjLyFuGUw699rb6APFw1Qar7JKZHO40aNEQ1WCtMWzv3SaS(wjLV(67)oV3XXtkJIdy97imxzcutW3vbHxvRtb6APlc)8F8KYO4aw)oc3ltOawZxsk1qRauOafie]] )


end