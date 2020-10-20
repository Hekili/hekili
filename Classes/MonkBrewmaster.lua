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


    spec:RegisterPack( "Brewmaster", 20201013, [[dGeVPaqiPqvpIIkxIIQsTjbAueLoffLvHI0RKIMLa6wsHkTlP6xGudtqDmPGLHaptaMgrrxtkX2OOkFdfHghkICoIcTokQQ08qqUhi2hkQdsrvvluk1dLcLAIuuvYfrruJukuXjLcLSsIQxkfkAMuuvXnLcf2jk4NOiWqrrqpvftfKCvkQk2lK)sPbd1HPAXG6XeMSkDzsBwP(SqJgLoTKvlfYRfKzRKBtHDd8BKgorwUQEoQMUORJOTlL03rOXJcDEkY6jky(iO2VIrnGGcDUEQigiimbHBiCdb0dhwMHjOb0jnjPOJKlc5rfDaUHIoTFLOHZt9rhj30I6xeuOdNs(cfDyZuIB(fAOJvYsc3fudO5Lb5YZIceVVtO5LHaA0bMSwzJfabJoxpvedeeMGWneUHa6HdlZWeGoozYsF05ugn2OdBDVkabJoxLlqhZn42Vs0W5P(dUXGccnYn3Gzcejfw)b3qaboycctqy0zv8KJGcDU62jxjckednGGcDCrwua6WLu)TSo4A55xHu0rbo8sVO2OeXabiOqhf4Wl9IAJoIVs9lhDyvFLSDjroycnyMyldo4GlGGAuGO96gEuTbWhmZdMv9vY2nCghmthSSdoCNGb3CWYo4WDcgmthC8PKsd2SbB2GdoyyY9UVPFwBtfiAHFLy)sjcqhxKffGox3qsbww)nqjIHaqqHokWHx6f1gDeFL6xo6WQ(kz7sICWeAWTeEWbhCbeuJceTx3WJQna(GzEWSQVs2UHZ4Gz6GLDWH7em4Mdw2bhUtWGz6GJpLuAWMnyZgCWbl7GHj37(1nKuGL1FJ(LsemyZqhxKffGoB6N12ubIw4xjIsedYebf6OahEPxuB0XfzrbOJZzB1bk3(UmqFRG((cDeFL6xo6CvyY9U)UmqFRG((YEvyY9UFPebdMWeEWxfMCV7ck4skYQv1wGq2RctU3DsPbhCWP)rn7SQVs2UKihmHgCanmyct4bNLHAtQ9w6Gj0Gjim6aCdfDCoBRoq523Lb6Bf03xOeXqliOqhxKffGoKC1wPAWrhf4Wl9IAJsedMhck0XfzrbOJenlkaDuGdV0lQnkrmWerqHoUilkaDGxu61UjFtOJcC4LErTrjIbMeck0XfzrbOdS(C9dvGi6OahEPxuBuIyqgrqHoUilkaDwvKn52grEJgkirhf4Wl9IAJsednegbf64ISOa0zxVcVO0l6OahEPxuBuIyOHgqqHoUilkaDCGq557lRWxl0rbo8sVO2OeXqdeGGcDuGdV0lQn6i(k1VC0jld1Mu7T0bZ8GjOf0XfzrbOtbALgsTGIugCkkrm0qaiOqhf4Wl9IAJoIVs9lhDeS(hv(GHmybR)rLBnCghCWbZtpg1VZQERMgCWbl7GHj37Ue5x7sVwbB1VuIGbtycpyyY9Ulr(1U0RvWw9xn8cWhmHgCd9wgmthCuChSzdo4Gfu66sjc6cDP8S8Lf(vI9xn8cWhmHgClOJlYIcqhjYV2Mkq0c)kruIyObzIGcDuGdV0lQn6i(k1VC0HRzwGiVlr(12KLNEmQVvq(pR0GzEWHhCWbhFkP0GdoyE6XO(DjroyMHmyUMzbI8Ue5xBtwE6XO(wb5)SsOJlYIcqhjYV2Mkq0c)kruIyOHwqqHokWHx6f1gDeFL6xo6W1mlqK3Li)ABYYtpg13ki)NvAWmp4Wdo4G50fDWbhmp9yu)UKihmZqgmxZSarExI8RTjlp9yuFRG8FwPbZ0bhU3c64ISOa0rI8RTPceTWVseLigAW8qqHokWHx6f1gDeFL6xo6W1mlqK3Li)ABYYtpg13A4mYknyMhC4bhCWXNskn4GdMNEmQFxsKdMzidMRzwGiVlr(12KLNEmQV1WzKvcDCrwua6ir(12ubIw4xjIsednWerqHokWHx6f1gDeFL6xo6W1mlqK3Li)ABYYtpg13A4mYknyMhC4bhCWC6Io4GdMNEmQFxsKdMzidMRzwGiVlr(12KLNEmQV1WzKvAWmDWH7TGoUilkaDKi)ABQarl8RerjIHgysiOqhf4Wl9IAJoIVs9lhD4AMfiY7sKFTnz5PhJ6BfK)Zknyido8GdoyUMzbI8Ue5xBtwE6XO(wdNrwPbdzWHhCWbhFkP0GdoyE6XO(DjroyMhmbHrhxKffGosKFTnvGOf(vIOeXqdYick0rbo8sVO2OJ4Ru)YrhUMzbI8Ue5xBtwE6XO(wb5)SsdgYGdp4GdMRzwGiVlr(12KLNEmQV1WzKvAWqgC4bhCWC6Io4GdMNEmQFxsKdM5b3qy0XfzrbOJe5xBtfiAHFLikrmqqyeuOJcC4LErTrhXxP(LJoSQVs2UKihmHgCldMPdMv9vbIwUeR(Axqjb5GjmHhSSdMv9vbIwUeR(Axqjb5GzgYGdyWbhmR6RKTljYbtOb3s4bBg64ISOa0rzusxww)nqjIbcAabf6OahEPxuB0r8vQF5OdR6RKTljYbtObhqaOJlYIcqhw1xfiA1vXy9OeXabeGGcDuGdV0lQn6i(k1VC0rqPRlLiOlr(12ubIw4xj2fS(hvUD)UilkWxdMqdoCVf0XfzrbOd8YfHSugTWVseLigiiaeuOJcC4LErTrhXxP(LJoYoyfOF00GBoyzhSc0pAQ)AubdMPdwqPRlLiOhsJwUHZz7VA4fGpyZgSzdMqdwMHhCWbdtU3D4LlcrjtRGAat7xkrWGdoybLUUuIGEinA5goNTtkHoUilkaDGxUiKLYOf(vIOeXabYebf6OahEPxuB0r8vQF5Odm5E3HxUieLmTcQbmTFPebdo4GlGGAuGO96gEuTeiJYOmAWhmZdw2bZQ(kz7goJdMPdoCpCldU5G5PhJ63xopTzjczVUHhvRmhSzdo4GHj37UUi5vRQf(DIl9780fHgmHgmbOJlYIcqhHUuEw(Yc)kruIyGGwqqHokWHx6f1gDeFL6xo6atU3DjYV2LETc2Qtkn4Gdw2bdtU3DjYV2LETc2Q)QHxa(Gj0GBO3YGz6GJI7GjmHhSGsxxkrqxI8RTPceTWVsS)QHxa(GzEWWK7DxI8RDPxRGT6VA4fGpyZqhxKffGocDP8S8Lf(vIOeXabMhck0rbo8sVO2OJ4Ru)YrhUKUw20)OM8bZmKbta64ISOa0jKgTCdNZIsedeWerqHoUilkaDUAszeDuGdV0lQnkrmqatcbf6OahEPxuB0r8vQF5OdxsxlB6Fut(GzgYGjyWbhmm5E3FsoBbI2g5x1sSa3(LseGoUilkaDEsoBbI2g5x1sSaxuIyGazebf64ISOa0bMc0ljpTWVseDuGdV0lQnkrmeqyeuOJlYIcqNTVwkWs)R(OJcC4LErTrjIHaAabf64ISOa0z76QaQLNudj0rbo8sVO2OeXqaeGGcDCrwua6quDjkGBPBl9V6JokWHx6f1gLigciaeuOJcC4LErTrhXxP(LJoPVuq2FsoBbI2g5x1sSa3UcC4LEhCWbdtU3D4LlcrjtRGAat7Ksdo4GHj37(tYzlq02i)QwIf42jLqhxKffGozf13k5lduIyiazIGcDuGdV0lQn6i(k1VC0r2bN(sbzVaTsdPwqrkdo1MSQfE5IqwkJDf4Wl9oyct4bN(sbzNlPIYx2RUQw13uxbo8sVd2SbhCWWK7DhE5IquY0kOgW0oPe64ISOa0jRO(wjFzGsedb0cck0rbo8sVO2OJ4Ru)YrhyY9UhRDAPBBYQwkJDE6IqdM5blt0XfzrbOJYOKUSS(BGsedbyEiOqhxKffGoWlxeIsM2qLie6OahEPxuBuIyiaMick0XfzrbOtinA5goNfDuGdV0lQnkrmeatcbf6OahEPxuB0r8vQF5OZLMDbfiuq(EQx7E5gA)vdVa8bdzWHrhxKffGockqOG89uV29YnuuIyiazebf6OahEPxuB0r8vQF5OtJFWkNRaH2tw1kEsrbVulDB3l3q7gEJOp64ISOa0Hv9pTkNRaHIsedYmmck0rbo8sVO2OJ4Ru)YrhyY9UhRDAPBBYQwkJDE6IqdMzidoa0XfzrbOJYOKUSS(BGsedYSbeuOJcC4LErTrhXxP(LJoWK7D)j5SfiABKFvlXcC7xkra64ISOa05j5SfiABKFvlXcCrjIbzsack0rbo8sVO2OJ4Ru)YrhyY9UdVCrikzAfudyA)sjcgCWbl7GHj37o8IsVlsE2VuIGbtycpyzhmm5E3Hxu6DrYZoP0Gdo4ln7WV6jRLUT76v7LM9x3VYzD4LoyZgSzOJlYIcqh4x9K1s32D9kkrmiZaqqHoUilkaDeSLfM85j6OahEPxuBuIyqMYebf64ISOa0rWwwIERk6OahEPxuBuIyqMTGGcDuGdV0lQn6i(k1VC0bMCV7XANw62MSQLYyNNUi0GzgYGjaDCrwua6OmkPllR)gOeXGmnpeuOJcC4LErTrhXxP(LJoUiRwvRcuJs5dMzidoGbhCWckDDPeb9qA0YnCoB)vdVa8bZ8GJI7GdoyzhSc0pAAWnhSSdwb6hn1FnQGbZ0bl7Gfu66sjc6H0OLB4C2(RgEb4dU5GJI7GnBWMnyZgmZqgS51c64ISOa0HlvaqbIwX7a1gQeHqjIbzYerqHokWHx6f1gDeFL6xo604hC6lfKD4LlcrjtRGAat7kWHx6DWbhSGsxxkrqpKgTCdNZ2F1WlaFWmp4O4o4Gdw2bRa9JMgCZbl7GvG(rt9xJkyWmDWYoybLUUuIGEinA5goNT)QHxa(GBo4O4oyZgSzd2SbZmKbBETGoUilkaDYkQVvYxgOeXGmzsiOqhf4Wl9IAJoIVs9lhDuG(rtdMqdoGgqhxKffGo(lCGAt6)kirjIbzkJiOqhxKffGopjNTarBJ8RAjwGl6OahEPxuBuIs0r6vb1a2teuigAabf64ISOa0zVuoR49DIokWHx6f1gLigiabf64ISOa0rWwwyYNNOJcC4LErTrjIHaqqHoUilkaDeSLLO3QIokWHx6f1gLOeLOtR6ZlkaXabHjiCdHBiCVb0HO)Gce5OtJLHe9t9oycgSlYIcg8Q4jVpYrhPNURLIoMBWTFLOHZt9hCJbfeAKBUbZeiskS(dUHacCWeeMGWJ8rU5gmtMrvqM6DWW6M(6GfudyphmSglaVpyZFHqLs(GbuqJlR)gBY1GDrwuaFWuWYuFKBUb7ISOaEx6vb1a2ti7LZdnYn3GDrwuaVl9QGAa7ztiqVP07i3Cd2fzrb8U0RcQbSNnHaTtgnuq6zrbJCZn4dWL4S0CWVx3bdtU36DW80t(GH1n91blOgWEoyynwa(GDWDWsV24krZSaXbx8bFPaTpYn3GDrwuaVl9QGAa7ztiqZbUeNLMwE6jFK7ISOaEx6vb1a2ZMqGEVuoR49DoYDrwuaVl9QGAa7ztiqlyllm5ZZrUlYIc4DPxfudypBcbAbBzj6TQJ8rU5gmtMrvqM6DWAR6BAWzzOdoz1b7IK(dU4d2B1RLdV0(i3fzrbCiCj1FlRdUwE(viDK7ISOaEtiqFDdjfyz93iWAdHv9vY2LejHyITeSacQrbI2RB4r1gaNzw1xjB3WzKPYgUtqtzd3jGPXNskzMzbHj37(M(zTnvGOf(vI9lLiyK7ISOaEtiqVPFwBtfiAHFLyG1gcR6RKTljsc1s4Gfqqnkq0EDdpQ2a4mZQ(kz7goJmv2WDcAkB4obmn(usjZmlOSWK7D)6gskWY6Vr)sjcmBK7ISOaEtiqtYvBLQrGa3qH4C2wDGYTVld03kOVVcS2qUkm5E3FxgOVvqFFzVkm5E3VuIact4RctU3DbfCjfz1QAlqi7vHj37oPuW0)OMDw1xjBxsKekGgimHZYqTj1ElLqeeEK7ISOaEtiqtYvBLQbFK7ISOaEtiqlrZIcg5UilkG3ec0Wlk9A3KVPrUlYIc4nHanS(C9dvG4i3fzrb8MqGEvr2KBBe5nAOGCK7ISOaEtiqVRxHxu6DK7ISOaEtiq7aHYZ3xwHVwJCxKffWBcb6c0knKAbfPm4uBYQw4LlczPmgyTHKLHAtQ9wkZe0YiFKBUbZes(12ubIdgwz9wlk5p4IpyyNR3btbdgqFdFvYGNffmyzlM8GtwDWlp1bRmk9kNxuWGZVIr95dU2dMNEmQ)G5LmOdUaIxDUEhmTv9hCYQdE58CWbeEWzjcXhm9hCdTmyUkOGl3S(i3fzrb8MqGwI8RTPceTWVsmWAdrW6Fu5qeS(hvU1Wzmip9yu)oR6TAkOSWK7DxI8RDPxRGT6xkraHjmm5E3Li)Ax61kyR(RgEb4eQHElmnkUMfuqPRlLiOl0LYZYxw4xj2F1WlaNqTmYh5MBWMpCDWckyxrYxVdwI8RTjlp9yuFRG8FwPbVFQXGB)krdNN6pyQuwuaVpYDrwuaVjeOLi)ABQarl8RedS2q4AMfiY7sKFTnz5PhJ6BfK)ZkXC4GXNskfKNEmQFxsKmdHRzwGiVlr(12KLNEmQVvq(pR0i3fzrb8MqGwI8RTPceTWVsmWAdHRzwGiVlr(12KLNEmQVvq(pReZHdYPlAqE6XO(DjrYmeUMzbI8Ue5xBtwE6XO(wb5)SsmnCVLr(i3Cd28HRdwqb7ks(6DWsKFTnz5PhJ6BnCgzLg8(PgdU9RenCEQ)GPszrb8(i3fzrb8MqGwI8RTPceTWVsmWAdHRzwGiVlr(12KLNEmQV1WzKvI5WbJpLukip9yu)UKizgcxZSarExI8RTjlp9yuFRHZiR0i3fzrb8MqGwI8RTPceTWVsmWAdHRzwGiVlr(12KLNEmQV1WzKvI5Wb50fnip9yu)UKizgcxZSarExI8RTjlp9yuFRHZiRetd3BzKpYn3GpPhJ6pyZ3dMUhmbHhmXATgCOATgSjk5GlWGjO3YG5QGcU8btSswkzoyw1xfioy6pyjYV2MkqSp4bB(W17GjYQGblr(12KLNEmQVvq(pR0GDWDWgoJSsd2FDW3I7Wl92h5UilkG3ec0sKFTnvGOf(vIbwBiCnZce5DjYV2MS80Jr9TcY)zLGeoixZSarExI8RTjlp9yuFRHZiReKWbJpLukip9yu)UKizMGWJCxKffWBcbAjYV2Mkq0c)kXaRneUMzbI8Ue5xBtwE6XO(wb5)SsqchKRzwGiVlr(12KLNEmQV1WzKvcs4GC6IgKNEmQFxsKm3q4r(i3CdUXr9vbIdMjVkgRFK7ISOaEtiqRmkPllR)gbwBiSQVs2UKijulmLv9vbIwUeR(AxqjbjHjSSSQVkq0YLy1x7ckjizgsabzvFLSDjrsOwcB2i3fzrb8MqGMv9vbIwDvmwFG1gcR6RKTljscfqaJ8rU5gC7LlcnyMaghC7xjo4Ipyb5)kixMgmjxVdoPdwRKv)b)Q0sbfNDWWVsKpyyNR3btbdEPC(GtwhmywFThSpy4xjoybR)rDWERETC4Lg4GP)GxuIdwb6hnn4Koyf4WlDWnMACWhdNZoYDrwuaVjeOHxUiKLYOf(vIbwBickDDPebDjYV2Mkq0c)kXUG1)OYT73fzrb(IqH7TmYDrwuaVjeOHxUiKLYOf(vIbwBiYQa9JMAkRc0pAQ)AubmvqPRlLiOhsJwUHZz7VA4fGBMzesMHdctU3D4LlcrjtRGAat7xkrqqbLUUuIGEinA5goNTtknYh5MBWn26s5z5Rb3(vIdw6l6xPPbtKvbAR6p4khCsPHgmVIGAxchKd(6gEuhSdUdUEkGhQadg(vIdgMCVhCXhSrX5fioyz9BJi55GtwDWSQVs2UHZ4GfuDVlrPGCWUqq)BbIdoPdUaPc4vAAW09GVUHh1bNEifywGd2b3bN0bFjnKgSYOq58bly9pQ8bdRB6RdUnTDFK7ISOaEtiql0LYZYxw4xjgyTHatU3D4LlcrjtRGAat7xkrqWciOgfiAVUHhvlbYOmkJgCMLLv9vY2nCgzA4E4wAYtpg1VVCEAZseYEDdpQwzAwqyY9URlsE1QAHFN4s)opDricrWi3fzrb8MqGwOlLNLVSWVsmWAdbMCV7sKFTl9AfSvNukOSWK7DxI8RDPxRGT6VA4fGtOg6TW0O4syclO01Lse0Li)ABQarl8Re7VA4fGZmm5E3Li)Ax61kyR(RgEb4MnYh5MBWmb7Tc4vR6YuGdoz1bB(ZeA(zWsFr)klzq5dUX8mykyWIL6TQbo420ZG1fxdCWeRKDWkq)OPbZLuWvF(GDWDWIlFWC6N6DWW6IsCK7ISOaEtiqhsJwUHZzdS2q4s6Azt)JAYzgcbJ8rUlYIc4nHa9vtkJJCxKffWBcb6NKZwGOTr(vTelWnWAdHlPRLn9pQjNzieeeMCV7pjNTarBJ8RAjwGB)sjcg5JCxKffWBcbAykqVK80c)kXrUlYIc4nHa92xlfyP)v)rUlYIc4nHa921vbulpPgsJCxKffWBcbAIQlrbClDBP)v)rUlYIc4nHaDwr9Ts(YiWAdj9LcY(tYzlq02i)QwIf42vGdV0BqyY9UdVCrikzAfudyANukim5E3FsoBbI2g5x1sSa3oP0i3fzrb8MqGoRO(wjFzeyTHiB6lfK9c0knKAbfPm4uBYQw4LlczPm2vGdV0lHjC6lfKDUKkkFzV6QAvFtDf4Wl9AwqyY9UdVCrikzAfudyANuAK7ISOaEtiqRmkPllR)gbwBiWK7Dpw70s32KvTug780fHywMJCxKffWBcbA4LlcrjtBOseAK7ISOaEtiqhsJwUHZzh5UilkG3ec0ckqOG89uV29Yn0aRnKln7ckqOG89uV29Yn0(RgEb4qcpYDrwuaVjeOzv)tRY5kqObwBinELZvGq7jRAfpPOGxQLUT7LBODdVr0FK7ISOaEtiqRmkPllR)gbwBiWK7Dpw70s32KvTug780fHygsaJCxKffWBcb6NKZwGOTr(vTelWnWAdbMCV7pjNTarBJ8RAjwGB)sjcg5UilkG3ec0WV6jRLUT761aRneyY9UdVCrikzAfudyA)sjccklm5E3Hxu6DrYZ(Lseqycllm5E3Hxu6DrYZoPuWln7WV6jRLUT76v7LM9x3VYzD4LAMzJCxKffWBcbAbBzHjFEoYDrwuaVjeOfSLLO3QoYn3GzYmkPRb344VXGzD(GzRiR(d28ftitgQbNSoyWqXeoyISkyWMOKdM1BvhSNdEPophmbdM(W8(i3fzrb8MqGwzusxww)ncS2qGj37ES2PLUTjRAPm25PlcXmecg5UilkG3ec0CPcakq0kEhO2qLiuG1gIlYQv1Qa1OuoZqciOGsxxkrqpKgTCdNZ2F1WlaN5O4guwfOF0utzvG(rt9xJkGPYkO01Lse0dPrl3W5S9xn8cWBgfxZmZmMHyETmYDrwuaVjeOZkQVvYxgbwBin(0xki7WlxeIsMwb1aM2vGdV0BqbLUUuIGEinA5goNT)QHxaoZrXnOSkq)OPMYQa9JM6VgvatLvqPRlLiOhsJwUHZz7VA4fG3mkUMzMzmdX8AzK7ISOaEtiq7VWbQnP)RGmWAdrb6hnrOaAyK7ISOaEtiq)KC2ceTnYVQLybUOdxsfigiW8ysOeLiea]] )


end