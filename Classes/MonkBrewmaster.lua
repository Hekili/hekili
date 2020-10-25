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


    spec:RegisterPack( "Brewmaster", 20201025, [[dGesPaqivcYJuj0LqrqTjbAuKQCksLwfksVsQ0SeGBjGKAxk6xqLgMuXXeuTmPQEMGY0iv01iv12eq8nueACOiQZrQqRtaP08GQQ7PsTpuuhuaPAHsvEOkbQjkGKCruezKOiiNuLazLuQEPkb0mfqkUPkbyNqv(Pkb1qrrGNQIPQs6QciXEb(lfdgXHPAXq6XKmziUmXMv4ZcnAu60swTaQxliZwk3Ms2nOFJ0WjLLRQNJQPl66qz7Qe9Duy8qfNNsz9Kky(qvz)kniCWvWbXtbGx)o97eEN(6pdVt)WcpmWjTPjGJMRc5rbCGULao9EHHLZt5bhn3wJ6iGRGdNI9kbCyZuJhOfxCJvYIHovulC5LfwZZIcvVpsC5LLcxWbfRA5feeGcoiEka863PFNW70x)z4D6hw49bhhlzPp4CkRlyWHTqqeiafCqeUcCU4s69cdlNNYVKlakm0A)Il5cRskQ8lPV(bSK(D63bCAfp5GRGdImCSwcUcWlCWvWXvzrHGdxt83W6qedp)kKaoc0rBccOhib41hCfCeOJ2eeqpWr9vkF5GdR4TKDQPYLG)LWe1FjbxsbvuRcgniULhfty8LW8syfVLStlhNLW0LO3s6m7VKUlrVL0z2FjmDjXNIPTeDxIUlj4sqXgJ5G(znSvWOb9fgtekdi44QSOqWbXT0eOH1FlqcWlmWvWrGoAtqa9ah1xP8LdoSI3s2PMkxc(xI(DwsWLuqf1QGrdIB5rXegFjmVewXBj70YXzjmDj6TKoZ(lP7s0BjDM9xctxs8PyAlr3LO7scUe9wck2ymrClnbAy93AIqzaxIUGJRYIcbNb9ZAyRGrd6lmajapDcUcoc0rBccOh44QSOqWX5Sx6qHBExhOVrrFVboQVs5lhCqeuSXy(UoqFJI(EZGiOyJXeHYaUe8HVLGiOyJXurHiyQSUumfmKbrqXgJjM2scUK0)OKtwXBj7utLlb)ljSWxc(W3sYYsmj1GuYsW)s63bCGULaooN9shkCZ76a9nk67nqcWtFWvWXvzrHGdgxmvkwCWrGoAtqa9ajaVabCfCCvwui4OrZIcbhb6Onbb0dKa8yIGRGJRYIcbh0gLIygyVnWrGoAtqa9ajapMm4k44QSOqWbvEU8HkyeCeOJ2eeqpqcWthbxbhxLffcoTkYMCtGXqIwcmbhb6Onbb0dKa8cVd4k44QSOqWzuVG2OueWrGoAtqa9ajaVWdhCfCCvwui44qLWZ3BgL3AGJaD0MGa6bsaEH3hCfCeOJ2eeqpWr9vkF5GtwwIjPgKswcZlPV(GJRYIcbNcEjnKyGfMo4uqcWl8Waxbhb6Onbb0dCuFLYxo4Oy9pk8LCVefR)rHBSCCwsWLWtpgLFYk(L2wsWLO3sqXgJPg2xJsqmk2AIqzaxc(W3sqXgJPg2xJsqmk2A(ILxq(sW)scFQ)sy6sIkKLO7scUefL2qOmGtL0eEwEZG(cJ5lwEb5lb)lrFWXvzrHGJg2xdBfmAqFHbib4fUobxbhb6Onbb0dCuFLYxo4WLmlyKp1W(AyZWtpgL3OW(NvBjmVKolj4sIpftBjbxcp9yu(PMkxcZ3lHlzwWiFQH91WMHNEmkVrH9pRg44QSOqWrd7RHTcgnOVWaKa8cxFWvWrGoAtqa9ah1xP8LdoCjZcg5tnSVg2m80Jr5nkS)z1wcZlPZscUeoTrxsWLWtpgLFQPYLW89s4sMfmYNAyFnSz4PhJYBuy)ZQTeMUKot9bhxLffcoAyFnSvWOb9fgGeGx4bc4k4iqhTjiGEGJ6Ru(YbhUKzbJ8Pg2xdBgE6XO8glhhwTLW8s6SKGlj(umTLeCj80Jr5NAQCjmFVeUKzbJ8Pg2xdBgE6XO8glhhwnWXvzrHGJg2xdBfmAqFHbib4foteCfCeOJ2eeqpWr9vkF5GdxYSGr(ud7RHndp9yuEJLJdR2syEjDwsWLWPn6scUeE6XO8tnvUeMVxcxYSGr(ud7RHndp9yuEJLJdR2sy6s6m1hCCvwui4OH91WwbJg0xyasaEHZKbxbhb6Onbb0dCuFLYxo4WLmlyKp1W(AyZWtpgL3OW(NvBj3lPZscUeUKzbJ8Pg2xdBgE6XO8glhhwTLCVKolj4sIpftBjbxcp9yu(PMkxcZlPFhWXvzrHGJg2xdBfmAqFHbib4fUocUcoc0rBccOh4O(kLVCWHlzwWiFQH91WMHNEmkVrH9pR2sUxsNLeCjCjZcg5tnSVg2m80Jr5nwooSAl5EjDwsWLWPn6scUeE6XO8tnvUeMxs4DahxLffcoAyFnSvWOb9fgGeGx)oGRGJaD0MGa6boQVs5lhCyfVLStnvUe8Ve9xctxcR4TcgnCnw5LPIIbZLGp8Te9wcR4TcgnCnw5LPIIbZLW89scBjbxcR4TKDQPYLG)LOFNLOl44QSOqWrWrtAgw)TajaV(HdUcoc0rBccOh4O(kLVCWHv8wYo1u5sW)sclmWXvzrHGdR4TcgnsRWPEqcWRFFWvWrGoAtqa9ah1xP8LdokkTHqzaNAyFnSvWOb9fgtfR)rHBgVRYIc92sW)s6m1hCCvwui4G2Cvidfhd6lmajaV(HbUcoc0rBccOh4O(kLVCWrVLiq5J2ws3LO3seO8rBZxIcCjmDjkkTHqzaNHKOHB5C25lwEb5lr3LO7sW)s0zNLeCjOyJXeT5QquS0OOwO0jcLbCjbxIIsBiugWzijA4woNDIPboUklkeCqBUkKHIJb9fgGeGxFDcUcoc0rBccOh4O(kLVCWbfBmMOnxfIILgf1cLorOmGlj4skOIAvWObXT8Oy6RJ6OoAXxcZlrVLWkElzNwoolHPlPZSJ(lP7s4PhJYpBopnzPczqClpkgDUeDxsWLGIngtPHXRlfd67mAYp5PRcTe8VK(GJRYIcbhL0eEwEZG(cdqcWRV(GRGJaD0MGa6boQVs5lhCqXgJPg2xJsqmk2AIPTKGlrVLGIngtnSVgLGyuS18flVG8LG)Le(u)LW0LevilbF4BjkkTHqzaNAyFnSvWOb9fgZxS8cYxcZlbfBmMAyFnkbXOyR5lwEb5lrxWXvzrHGJsAcplVzqFHbib41pqaxbhb6Onbb0dCuFLYxo4W1KwZK(hLKVeMVxsFWXvzrHGtijA4woNfKa86ZebxbhxLffcoissXbCeOJ2eeqpqcWRptgCfCeOJ2eeqpWr9vkF5GdxtAnt6Fus(sy(Ej9xsWLGIngZhJZwWOjWoIyyuqKjcLbeCCvwui48yC2cgnb2redJcIasaE91rWvWXvzrHGdkfkiy80G(cdWrGoAtqa9ajaVW6aUcoUklkeCgERjqd9rKhCeOJ2eeqpqcWlSWbxbhxLffcodxAfum8KAPboc0rBccOhib4fwFWvWXvzrHGddX1OqUHom0hrEWrGoAtqa9ajaVWcdCfCeOJ2eeqpWr9vkF5Gt6nbMZhJZwWOjWoIyyuqKPaD0MGSKGlbfBmMOnxfIILgf1cLoX0wsWLGIngZhJZwWOjWoIyyuqKjMg44QSOqWjRO8gnVzbsaEHPtWvWrGoAtqa9ah1xP8Ldo6TK0BcmNf8sAiXalmDWPMKvmOnxfYqXzkqhTjilbF4BjP3eyo5AIQ8MbrA1LYBBkqhTjilr3LeCjOyJXeT5QquS0OOwO0jMg44QSOqWjRO8gnVzbsaEHPp4k4iqhTjiGEGJ6Ru(YbhuSXygRrAOdtYkgkotE6QqlH5LOtWXvzrHGJGJM0mS(BbsaEHfiGRGJRYIcbh0MRcrXstOsfcCeOJ2eeqpqcWlmMi4k44QSOqWjKenClNZcoc0rBccOhib4fgtgCfCeOJ2eeqpWr9vkF5GdcnNkkujW89uqmJMBjZxS8cYxY9s6aoUklkeCuuOsG57PGygn3sajaVW0rWvWrGoAtqa9ah1xP8LdoxOLiCUavYmzfJ6XufAtm0Hz0ClzA5bM(GJRYIcbhwX)0iCUavcib4PZoGRGJaD0MGa6boQVs5lhCqXgJzSgPHomjRyO4m5PRcTeMVxsyGJRYIcbhbhnPzy93cKa80z4GRGJRYIcbNKIPyn0Hbr8KfCeOJ2eeqpqcWtN9bxbhb6Onbb0dCuFLYxo4GIngZhJZwWOjWoIyyuqKjcLbeCCvwui48yC2cgnb2redJcIasaE6mmWvWrGoAtqa9ah1xP8LdoOyJXeT5QquS0OOwO0jcLbCjbxIElbfBmMOnkfPHXZjcLbCj4dFlrVLGIngt0gLI0W45etBjbxccnNOV4jRHomJ6fdcnNVmEHZ6Onzj6UeDbhxLffcoOV4jRHomJ6fqcWtN6eCfCCvwui4Oyldk2ZtWrGoAtqa9ajapDQp4k44QSOqWrXwgg(Lc4iqhTjiGEGeGNodeWvWrGoAtqa9ah1xP8LdoOyJXmwJ0qhMKvmuCM80vHwcZ3lPp44QSOqWrWrtAgw)TajapDYebxbhb6Onbb0dCuFLYxo44QSUumcuSkHVeMVxsylj4suuAdHYaodjrd3Y5SZxS8cYxcZlrWruyPyYYswsWLO3seO8rBlP7s0Bjcu(OT5lrbUeMUe9wIIsBiugWzijA4woND(ILxq(s6UebhrHLIjllzj6UeDxIUlH57Lei6doUklkeC4AfewWOr9oumHkviqcWtNmzWvWrGoAtqa9ah1xP8LdoxOLKEtG5eT5QquS0OOwO0PaD0MGSKGlrrPnekd4mKenClNZoFXYliFjmVKOczjbxIElrGYhTTKUlrVLiq5J2MVef4sy6s0BjkkTHqzaNHKOHB5C25lwEb5lP7sIkKLO7s0Dj6UeMVxsGOp44QSOqWjRO8gnVzbsaE6uhbxbhb6Onbb0dCuFLYxo4iq5J2wc(xsyHdoUklkeC8x5qXK0)fycsaE63bCfCCvwui48yC2cgnb2redJcIaoc0rBccOhibj4O9IIAH6j4kaVWbxbhxLffcoJMWzvVpsWrGoAtqa9ajaV(GRGJRYIcbhfBzqXEEcoc0rBccOhib4fg4k44QSOqWrXwgg(Lc4iqhTjiGEGeKGeCUuEErHa863PFNW70xFWHH)Wcg5GZfKLg9tbzj9xIRYIcxsR4jFU2bhTNoQMaoxCj9EHHLZt5xYfafgATFXLCHvjfv(L0x)aws)o97S2x7xCjmjCefwkilbvg0xwIIAH65sqLyb5ZLeORuIwYxcKcduZ6V1aRTexLffYxcf2Snx7UklkKp1ErrTq9S7nUJMWzvVpY1URYIc5tTxuulup7EJRITmOyppx7UklkKp1ErrTq9S7nUk2YWWVuw7R9lUeMeoIclfKLixkVTLKLLSKKvwIRs6VKIVe)sVAoAtMRDxLffYV5AI)gwhIy45xHK1URYIc5DVXfXT0eOH1FRaQXnR4TKDQPs8Ze1pybvuRcgniULhftyCMzfVLStlhhMQxNz)U61z2NPXNIPPRUbrXgJ5G(znSvWOb9fgtekd4A3vzrH8U34oOFwdBfmAqFHra14Mv8wYo1uj(1VtWcQOwfmAqClpkMW4mZkElzNwoomvVoZ(D1RZSptJpfttxDdQhk2ymrClnbAy93AIqza1DT7QSOqE3BCX4IPsXkaOBj3oN9shkCZ76a9nk67TaQXnIGIngZ31b6Bu03BgebfBmMiugq8HpebfBmMkkebtL1LIPGHmick2ymX0cM(hLCYkElzNAQe)Hfo(WxwwIjPgKsWF)oRDxLffY7EJlgxmvkw81URYIc5DVXvJMffU2DvwuiV7nUOnkfXmWEBRDxLffY7EJlQ8C5dvW4A3vzrH8U342QiBYnbgdjAjWCT7QSOqE3BCh1lOnkfzT7QSOqE3BCDOs457nJYBT1URYIc5DVXTGxsdjgyHPdo1KSIbT5QqgkobuJ7SSetsniLWCF9x7R9lUeMaSVg2kyCjOcRFzrX(Lu8LG6Cbzju4sG03YBLo4zrHlrVIjTKKvwsZtzjcoAVW5ffUK8RyuE(sQXs4PhJYVeEPdYskO6fNlilHEP8ljzLL0CEUKW6SKSuH4lH(ljC9xcxuuicx35A3vzrH8U34QH91WwbJg0xyeqnUvS(hf(TI1)OWnwoob5PhJYpzf)sBb1dfBmMAyFnkbXOyRjcLbeF4dfBmMAyFnkbXOyR5lwEb54p8P(mnQq0nOIsBiugWPsAcplVzqFHX8flVGC8R)AFTFXLeOWLLOOWrfXEbzjAyFnSz4PhJYBuy)ZQTKXtTwsVxyy58u(Lq1YIc5Z1URYIc5DVXvd7RHTcgnOVWiGACZLmlyKp1W(AyZWtpgL3OW(NvJ5obJpftlip9yu(PMkz(MlzwWiFQH91WMHNEmkVrH9pR2A3vzrH8U34QH91WwbJg0xyeqnU5sMfmYNAyFnSz4PhJYBuy)ZQXCNGCAJgKNEmk)utLmFZLmlyKp1W(AyZWtpgL3OW(NvJPDM6V2x7xCjbkCzjkkCurSxqwIg2xdBgE6XO8glhhwTLmEQ1s69cdlNNYVeQwwuiFU2DvwuiV7nUAyFnSvWOb9fgbuJBUKzbJ8Pg2xdBgE6XO8glhhwnM7em(umTG80Jr5NAQK5BUKzbJ8Pg2xdBgE6XO8glhhwT1URYIc5DVXvd7RHTcgnOVWiGACZLmlyKp1W(AyZWtpgL3y54WQXCNGCAJgKNEmk)utLmFZLmlyKp1W(AyZWtpgL3y54WQX0ot9x7R9lUKt6XO8lHj8sOJL0VZsyuT2scvT2sSrXwsbxs)P(lHlkkeHVegvYsXYLWkERGXLq)LOH91WwbJZLSKafUGSegScCjAyFnSz4PhJYBuy)ZQTehISelhhwTL4VSeKI7OnbzU2DvwuiV7nUAyFnSvWOb9fgbuJBUKzbJ8Pg2xdBgE6XO8gf2)SA3DcYLmlyKp1W(AyZWtpgL3y54WQD3jy8PyAb5PhJYp1ujZ97S2DvwuiV7nUAyFnSvWOb9fgbuJBUKzbJ8Pg2xdBgE6XO8gf2)SA3DcYLmlyKp1W(AyZWtpgL3y54WQD3jiN2Ob5PhJYp1ujZH3zTV2V4sycjERGXLWKAfo1V2DvwuiV7nUcoAsZW6Vva14Mv8wYo1uj(1NPSI3ky0W1yLxMkkgmXh(0Jv8wbJgUgR8YurXGjZ3HfKv8wYo1uj(1VJURDxLffY7EJlR4TcgnsRWP(aQXnR4TKDQPs8hwyR91(fxsVMRcTKlmolP3lmwsXxIc7FbMnBlbJliljPlrQKv(L8IwtGfNDjOVWGVeuNlilHcxst48LKSoCjSEBSeFjOVWyjkw)JYs8l9Q5OnjGLq)L0OmwIaLpABjjDjc0rBYsUaL4sowoNDT7QSOqE3BCrBUkKHIJb9fgbuJBfL2qOmGtnSVg2ky0G(cJPI1)OWnJ3vzrHEd)DM6V2DvwuiV7nUOnxfYqXXG(cJaQXTEcu(OTU6jq5J2MVefitvuAdHYaodjrd3Y5SZxS8cY1vx8RZobrXgJjAZvHOyPrrTqPtekdyqfL2qOmGZqs0WTCo7etBTV2V4sUGLMWZYBlP3lmwI2x0VsBlHbRaLlLFjvUKKsdTeEfH1OuomxcIB5rzjoezj1tH8qfCjOVWyjOyJXsk(sSkoVGXLONJeymEUKKvwcR4TKDA54SefvgJsvcmxIRu0hPGXLK0LuWuG8kTTe6yjiULhLLKEibQBalXHiljPlbbZsBjcokHZxII1)OWxcQmOVSKE0EZ1URYIc5DVXvjnHNL3mOVWiGACJIngt0MRcrXsJIAHsNiugWGfurTky0G4wEum91rDuhT4mRhR4TKDA54W0oZo63LNEmk)S580KLkKbXT8Oy0PUbrXgJP0W41LIb9Dgn5N80vHWF)1URYIc5DVXvjnHNL3mOVWiGACJIngtnSVgLGyuS1etlOEOyJXud7RrjigfBnFXYlih)Hp1NPrfc(WNIsBiugWPg2xdBfmAqFHX8flVGCMrXgJPg2xJsqmk2A(ILxqUUR91(fxYfEmeiVUuA2cyjjRSKaDMGanlr7l6xzPdcFjxGNLqHlr1e)sjGL0JEwI04salHrLSlrGYhTTeUMarKNVehISefcFjC6NcYsqLgLXA3vzrH8U34gsIgULZzdOg3CnP1mP)rj5mF3FTV2DvwuiV7nUissXzT7QSOqE3BCFmoBbJMa7iIHrbrcOg3CnP1mP)rj5mF3pik2ymFmoBbJMa7iIHrbrMiugW1(A3vzrH8U34IsHccgpnOVWyT7QSOqE3BChERjqd9rKFT7QSOqE3BChU0kOy4j1sBT7QSOqE3BCziUgfYn0HH(iYV2DvwuiV7nUzfL3O5nRaQXD6nbMZhJZwWOjWoIyyuqKPaD0MGeefBmMOnxfIILgf1cLoX0cIIngZhJZwWOjWoIyyuqKjM2A3vzrH8U34MvuEJM3ScOg36LEtG5SGxsdjgyHPdo1KSIbT5Qqgkotb6OnbbF4l9MaZjxtuL3misRUuEBtb6Onbr3GOyJXeT5QquS0OOwO0jM2A3vzrH8U34k4OjndR)wbuJBuSXygRrAOdtYkgkotE6QqmRZ1URYIc5DVXfT5QquS0eQuHw7UklkK39g3qs0WTCo7A3vzrH8U34QOqLaZ3tbXmAULeqnUrO5urHkbMVNcIz0Clz(ILxq(DN1URYIc5DVXLv8pncNlqLeqnUVqcNlqLmtwXOEmvH2edDygn3sMwEGP)A3vzrH8U34k4OjndR)wbuJBuSXygRrAOdtYkgkotE6QqmFh2A3vzrH8U34MumfRHomiINSRDxLffY7EJ7JXzly0eyhrmmkisa14gfBmMpgNTGrtGDeXWOGitekd4A3vzrH8U34I(INSg6WmQxcOg3OyJXeT5QquS0OOwO0jcLbmOEOyJXeTrPinmEorOmG4dF6HIngt0gLI0W45etlicnNOV4jRHomJ6fdcnNVmEHZ6OnrxDx7UklkK39gxfBzqXEEU2DvwuiV7nUk2YWWVuw7xCjmjC0K2syc5V1syD(syRiR8ljqftat66sswhUKRmblHbRaxInk2sy9lLL45sAIZZL0Fj0hLpx7UklkK39gxbhnPzy93kGACJIngZynsdDyswXqXzYtxfI57(RDxLffY7EJlxRGWcgnQ3HIjuPcfqnUDvwxkgbkwLWz(oSGkkTHqzaNHKOHB5C25lwEb5ml4ikSumzzjb1tGYhT1vpbkF028LOazQEkkTHqzaNHKOHB5C25lwEb5DfCefwkMSSeD1vxMVde9x7UklkK39g3SIYB08Mva14(cLEtG5eT5QquS0OOwO0PaD0MGeurPnekd4mKenClNZoFXYliN5OcjOEcu(OTU6jq5J2MVefit1trPnekd4mKenClNZoFXYliVBuHORU6Y8DGO)A3vzrH8U346VYHIjP)lWmGAClq5J2WFyHV2DvwuiV7nUpgNTGrtGDeXWOGiGdxtua86himzqcsaaa]] )


end