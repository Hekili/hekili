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
        },


        -- Legendaries
        charred_passions = {
            id = 338140,
            duration = 8,
            max_stack = 1
        },
        mighty_pour = {
            id = 337994,
            duration = 8,
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


    spec:RegisterTotem( "black_ox_statue", 627607 )
    spec:RegisterPet( "niuzao_the_black_ox", 73967, "invoke_niuzao", 24 )


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

                if buff.charred_passions.up and debuff.breath_of_fire_dot.up then
                    applyDebuff( "target", "breath_of_fire_dot" )
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

                if legendary.charred_passions.enabled then
                    applyBuff( "charred_passions" )
                end

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

                if legendary.mighty_pour.enabled then
                    applyBuff( "mighty_pour" )
                end
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

            startsCombat = false,
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

            startsCombat = false,
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
                summonPet( "niuzao_the_black_ox", 24 )

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
            charges = function () return legendary.stormstouts_last_keg.enabled and 2 or nil end,
            recharge = function () return legendary.stormstouts_last_keg.enabled and 8 or nil end,
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
            charges = function () return level > 46 and 2 or 1 end,
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

                if buff.charred_passions.up and debuff.breath_of_fire_dot.up then
                    applyDebuff( "target", "breath_of_fire_dot" )
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
                elseif state.spec.brewmaster then
                    setCooldown( "keg_smash", 0 )
                end
            end,

            auras = {
                weapons_of_order = {
                    id = 310454,
                    duration = function () return conduit.strike_with_clarity.enabled and 35 or 30 end,
                    max_stack = 1,
                },
                weapons_of_order_debuff = {
                    id = 312106,
                    duration = 8,
                    max_stack = 5
                },
                weapons_of_order_ww = {
                    id = 311054,
                    duration = 5,
                    max_stack = 1,
                    copy = "weapons_of_order_buff"
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

        potion = "phantom_fire",

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



    spec:RegisterPack( "Brewmaster", 20210403, [[d4KN0aqiusIhrH0LqjrTja6tscLrbGofaSkscVcImlku3ssOAxQQFHszyOehts0YqkEgGY0OqCnjjBJKO(gjrmojb15KKsRdLk18auDpKQ9rs6GOuHfkP6HOurteLeXfrjHpssK0irjjDssIuRKcEjkj1mLeGBIsI0ork9tjbzOOujlvsG8uGMke1vLeYxLeOgljrI9c1FP0Gv6WclMepMutwvUmXMv4ZsmAuCArRwsQETKYSv0TPODd63igosoUKaA5Q8CunDPUoK2okv9DimEa58KuRxskMpkP2pvJReJmg8fTGPLgwOPswmcla7xzLgHgGvjgSvtjyqQqxlkcgegMcgS(jimdElhgKkupjXdJmgKtqpTGbz6MIZUzJTs2mOkFnXKnEAIoJojq9fJMnEAQzddQGMZwLgIvWGVOfmT0WcnvYIryby)kR0i0ammyG2mKddcMMStmit(EceRGbFcxJbRFccZG3Y5lRucSMBGDqD50xAm2xAyHMkDdUb2jtalcND7gQ4(YoEpFzfarnjVew8LvlLVBOI7lYKhHD7RVvqc7tbHVSl0lhQtyX3h6LWIV0MOvtq(yWzYBogzm4tgb6SXiJPTsmYyWq3jbIb5usCwMa(S8(YAcguGHYuE464gtlnyKXGcmuMYdxhdQVSLldmix6oHf(Nc9YHA7GCwTmfENX0xa9fG(2PPyBI1maYQzIRiCFbUVf97Bga5lRzTVkOJXNc9YrkpRMj)Ou(cOVkOJXNc9YrkpRMj)NygjK7lW9TYFv(QcFl633maYxa4lRzTVAcz(iiGFTmfENX0QCcI)jMrc5(cCFPXxv4Br)(Mbq(cOVAM4kc3oUq3jbgtFv13k)vHbdDNeigKc9YH6ewSkNGa3yAbggzmOadLP8W1XG6lB5YadQGogFk0lhP8SAM8JsHbdDNeigultH3zmTkNGa3yAncgzmOadLP8W1XG6lB5YadYiXSz(u62xG7RkPkFb03eQjMjSyFHzuelW4(QQVmsmBMVzaKVQWxa6llFA8fjFbOVS8PXxv4B5iOu(caFbGVa6Rc6y8hKRZH6ewSkNG4)iiGyWq3jbIbFHjLaTmXzIBmTvHrgdkWqzkpCDmO(YwUmWGmsmBMpLU9f4(wfl(cOVjutmtyX(cZOiwGX9vvFzKy2mFZaiFvHVa0xw(04ls(cqFz5tJVQW3YrqP8fa(caFb0xa6Rc6y8FHjLaTmXz(FeeqFbagm0DsGyWb56COoHfRYjiWnMwvgJmguGHYuE46yWq3jbIbdod7dOWTxunKZQjxmXG6lB5Yad(ef0X4Fr1qoRMCX0(ef0X4)iiG(YAw77tuqhJVMaFO6ozVytyn7tuqhJpkLVa6Bhxr6pJeZM5tPBFbUVaRsFznR9TttX2e7lfFbUV0WcgegMcgm4mSpGc3Er1qoRMCXe3yAvjyKXGHUtcedIYfB2IjhdkWqzkpCDCJPTcJrgdg6ojqmifPtcedkWqzkpCDCJPTAXiJbdDNeiguzsip7a9uJbfyOmLhUoUX0wjlyKXGHUtcedQihxUAjSGbfyOmLhUoUX0wzLyKXGHUtcedoZctZTvh9vmfyJbfyOmLhUoUX0wjnyKXGHUtcedoYtuMeYddkWqzkpCDCJPTsGHrgdg6ojqmya1cVVyA1XCIbfyOmLhUoUX0wPrWiJbdDNeigujkwYW2xQRXXGcmuMYdxh3yARSkmYyqbgkt5HRJb1x2YLbgSJRi9VttX2e7lfFv1xv2xa9vtiZhbb8tHE5qDclwLtq81mXveUDCHUtcmM(cCFPbdg6ojqmyczpPMyHjA1eeCJPTsvgJmguGHYuE46yq9LTCzGb74ks)zKy2mFkD7lWP7BLv5lRzTVDCfP)msmBMVg9ob2(cCFzKy2mFZaimyO7KaXGnbvZyjd7tIMb3yARuLGrgdg6ojqmicjOiqULmSK7jhguGHYuE464gtBLvymYyWq3jbIbhXCkql5EYHbfyOmLhUoUX0wz1Irgdg6ojqmOcbkpuEBvobbguGHYuE464gtlnSGrgdkWqzkpCDmyO7KaXGuOxouNWIv5eeyWNW1xs1jbIbRiU4RMahzb9KNVuOxouB5DukYz1O3Xq574iM(w)eeMbVLZxcvNei)Jb1x2YLbgKlDNWc)tHE5qTL3rPiNvJEhdLVQ6ll(cOVLJGs5lG(Y7OuK7tPBFvLUVCP7ew4Fk0lhQT8okf5SA07yOWnMwAQeJmguGHYuE46yWq3jbIbPqVCOoHfRYjiWGpHRVKQtcedwrCXxnboYc6jpFPqVCO2Y7OuKZQrVJHY3Xrm9T(jimdElNVeQojq(hdQVSLldmix6oHf(Nc9YHAlVJsroRg9ogkFv1xw8fqF5KjXxa9L3rPi3Ns3(QkDF5s3jSW)uOxouB5DukYz1O3Xq5Rk8LLFv4gtln0GrgdkWqzkpCDmyO7KaXGuOxouNWIv5eeyWNW1xs1jbIbRiU4RMahzb9KNVuOxouB5DukYzndGyO8DCetFRFccZG3Y5lHQtcK)XG6lB5YadYLUtyH)PqVCO2Y7OuKZAgaXq5RQ(YIVa6B5iOu(cOV8okf5(u62xvP7lx6oHf(Nc9YHAlVJsroRzaedfUX0sdWWiJbfyOmLhUogm0DsGyqk0lhQtyXQCccm4t46lP6KaXGvex8vtGJSGEYZxk0lhQT8okf5SMbqmu(ooIPV1pbHzWB58Lq1jbY)yq9LTCzGb5s3jSW)uOxouB5DukYzndGyO8vvFzXxa9LtMeFb0xEhLICFkD7RQ09LlDNWc)tHE5qTL3rPiN1maIHYxv4ll)QWnMwAmcgzmOadLP8W1XGHUtcedsHE5qDclwLtqGbFcxFjvNeigeSJsroFzL9Lm8Lgw8froN(wlNtFvtq9nH(sZVkF5IMaFCFrKndbT9LrIzcl(soFPqVCOoHLVV(wrC55lcgb6lf6Ld1wEhLICwn6Dmu(gWNVMbqmu(gN47l5HYuEFmO(YwUmWGCP7ew4Fk0lhQT8okf5SA07yO8LUVS4lG(YLUtyH)PqVCO2Y7OuKZAgaXq5lDFzXxa9TCeukFb0xEhLICFkD7RQ(sdl4gtlnvHrgdkWqzkpCDmyO7KaXGuOxouNWIv5eeyWNW1xs1jbIbb7OuKZxwzFjdFRKfFrKZPV1Y50x1euFtOVv5lx0e4J7lISziOTVmsmtyXxY5lf6Ld1jS8913kIlpFrWiqFPqVCO2Y7OuKZQrVJHY3a(81maIHY34eFFjpuMY7Jb1x2YLbgKlDNWc)tHE5qTL3rPiNvJEhdLV09LfFb0xU0Dcl8pf6Ld1wEhLICwZaigkFP7ll(cOVCYK4lG(Y7OuK7tPBFv13kzb3yAPrLXiJbfyOmLhUogm0DsGyqLzORzjazvobbg8jC9LuDsGyW6ZqxZ3keq(w)ee(MCF1O3jWEQ2xuU88Tj(kzZiNVNqnfyYz8v5eeCFvcU88La9DkCUVnta9LjMdFdFvobHVAM4kIVb7JCgktXyFjNVtccFfOCf1(2eFfyOmfFz1sXxqZGZGb1x2YLbgutiZhbb8tHE5qDclwLtq81mXveUDCHUtcmM(cCFz5xfUX0sJkbJmguGHYuE46yq9LTCzGbbOVcuUIAFrYxa6RaLRO(FsrG(QcF1eY8rqa)1KILBgCM)jMrc5(caFbGVa3xJWIVa6Rc6y8vMHUgbTTAIPc5)iiG(cOVAcz(iiG)AsXYndoZhLcdg6ojqmOYm01SeGSkNGa3yAPPcJrgdkWqzkpCDmyO7KaXGcquY0YeNjg8jC9LuDsGyqwvjMjS4lRyMaLhguFzlxgyqgjMnZNs3(cCFRYxv4lJeZewSCkg5KVMGcBFznR9fG(YiXmHflNIro5RjOW2xvP7lW8fqFzKy2mFkD7lW9Tkw8fa4gtlnvlgzmOadLP8W1XG6lB5YadYiXSz(u62xG7lWaggm0DsGyqgjMjSyLzcuE4gtlWybJmguGHYuE46yWq3jbIbRjfl3m4myWNW1xs1jbIbRqJHa5j7LPAJ9TzeFzhSRkaFPUKCzNvJW9Lvd6lb6REkb7fJ9Tob0xzYfJ9fr2m(kq5kQ9LtjWNCCFd4Zx9J7lNCT88vrMeeyq9LTCzGb5uYCA74ksZ9vv6(sdUX0cSkXiJbfyOmLhUoguFzlxgyqoLmN2oUI0CFvLUV0GbdDNeigCeYmHIL3etkCJPfy0GrgdkWqzkpCDmyO7KaXG1KILBgCgm4t46lP6KaXGSZG3(YQb9nAFBcLVuxs89HEjS4BfmPc5Rc6y8XG6lB5YadQGogFesqrGClzyj3tUpkfUX0cmGHrgdkWqzkpCDmyO7KaXGAzk8oJPv5eeyWNW1xs1jbIbzNYu4DgtFRFccFPUKCzR2xemcuyVC(MTVnHuZxEwG5i1bS99fMrr8nGpFZJa51sOVkNGWxf0XW3K7RzY5jS4laJx1r5TVnJ4lJeZM5Bga5RMiJrQtb2(gAn5EjS4Bt8nHTa5zR2xYW3xygfX3oQjqaySVb85Bt89HAs5RaKw4CF1mXveUVkYGCIV1j1)yq9LTCzGb7awlHfFb0xf0X4RmdDncAB1etfY)rqa9fqFtOMyMWI9fMrrS0uTvB1AY9vvFbOVmsmBMVzaKVQWxw(SuLVi5lVJsrU)m4TTtDn7lmJIynIVaWxa9vbDm(YeLNSxSkxGyk3N3HUMVa3xAWnMwGzemYyqbgkt5HRJb1x2YLbgSdyTew8fqFvqhJpf6LJuEwnt(rP8fqFbOVkOJXNc9YrkpRMj)NygjK7lW9TYFv(QcFl6NVSM1(QjK5JGa(PqVCOoHfRYji(NygjK7RQ(QGogFk0lhP8SAM8FIzKqUVaadg6ojqmOwMcVZyAvobbUX0cSQWiJbdDNeig8jnbimOadLP8W1XnMwGPYyKXGcmuMYdxhdQVSLldmiNsMtBhxrAUVQs3xA8fqFvqhJ)HYzsyXw94jwej89FeeqmyO7KaXGhkNjHfB1JNyrKWhUX0cmvcgzmOadLP8W1XG6lB5Yad2XuG9)q5mjSyRE8elIe((cmuMYZxa9vbDm(kZqxJG2wnXuH8rP8fqFvqhJ)HYzsyXw94jwej89rPWGHUtced2zrolvmnXnMwGvHXiJbfyOmLhUoguFzlxgyqf0X4RzI7KNLk48Ka5)hbb0xa99qHYGCf5RzI7KNLk48Ka5FPcenPOKhgm0DsGyqLtIMXsg2rEcUX0cSQfJmgm0DsGyqLzORrqBBTuxddkWqzkpCDCJP1iSGrgdg6ojqmynPy5MbNbdkWqzkpCDCJP1ivIrgdg6ojqm4iKzcflVjMuyqbgkt5HRJBmTgHgmYyqbgkt5HRJb1x2YLbgubDm(LC0wYW2mILa0N3HUMVQs3xGHbdDNeiguaIsMwM4mXnMwJammYyWq3jbIbBcQMXsg2NendguGHYuE464gtRrmcgzmOadLP8W1XG6lB5YadQGog)dLZKWIT6XtSis47)iiGyWq3jbIbpuotcl2QhpXIiHpCJP1ivHrgdkWqzkpCDmO(YwUmWGkOJXxZe3jplvW5jbY)OuyWq3jbIb5ujeMWIvFbuS1sDnCJP1iQmgzmOadLP8W1XG6lB5Yad(i9xtGAb2x0YZoMHP8pXmsi3x6(Ycgm0DsGyqnbQfyFrlp7ygMcUX0AevcgzmOadLP8W1XG6lB5YadQGogFLzORrqBRMyQq(pccOVa6la9vbDm(ktc5nr59)rqa9L1S2xa6Rc6y8vMeYBIY7pkLVa67J0FLtIMXsg2rEI9r6)jJt4mHYu8fa(camyO7KaXGkNenJLmSJ8eCJP1ivymYyqbgkt5HRJb1x2YLbgKvXxHZfOw(nJy1hQovMILmSJzykFZO6Kddg6ojqmiJexBfoxGAb3yAns1Irgdg6ojqmOMjTkOhVXGcmuMYdxh3yARIfmYyWq3jbIb1mPfrWEbdkWqzkpCDCJPTQkXiJbdDNeiguaIAsEjSyRjfmOadLP8W1XnM2QObJmguGHYuE46yWq3jbIbfGOKPLjotm4t46lP6KaXGScGOKPVSQXz6ltW9LjlmY5lRe2fRazFBMa6lYSlFrWiqFvtq9LjyV4B0(oLG3(sJVKtH)XG6lB5YadQGog)soAlzyBgXsa6Z7qxZxvP7ln4gtBvadJmguGHYuE46yq9LTCzGbdDNSxScumtH7RQ09fy(cOVAcz(iiG)AsXYndoZ)eZiHCFv1xbirJ2ITttXxa9fG(kq5kQ9fjFbOVcuUI6)jfb6Rk8fG(QjK5JGa(Rjfl3m4m)tmJeY9fjFfGenAl2onfFbGVaWxa4RQ09vLRcdg6ojqmiNkHWewS6lGITwQRHBmTvzemYyqbgkt5HRJb1x2YLbgKvX3oMcS)kZqxJG2wnXuH8fyOmLNVa6RMqMpcc4VMuSCZGZ8pXmsi3xv9TOF(cOVa0xbkxrTVi5la9vGYvu)pPiqFvHVa0xnHmFeeWFnPy5MbN5FIzKqUVi5Br)8fa(caFbGVQs3xvUkmyO7KaXGDwKZsfttCJPTQQWiJbfyOmLhUoguFzlxgyqbkxrTVa3xGvjgm0DsGyW40buSn5ob24gtBvQmgzmyO7KaXGhkNjHfB1JNyrKWhguGHYuE464g3yqQt0etLOXiJPTsmYyWq3jbIbhtHZOVy0yqbgkt5HRJBmT0Grgdg6ojqmOcP7P8SJzOwEisyX2eGsiguGHYuE464gtlWWiJbdDNeiguZKwf0J3yqbgkt5HRJBmTgbJmgm0DsGyqntAreSxWGcmuMYdxh34g3yq2lhpjqmT0WcnvYcWQKgmiI4GjSWXGvWSJkiAvPPvLk72xFrMr8nnPix77GC(wXEYiqNDfZ3tQarZtE(YjMIVbAtmJwE(Qzcyr4F3qfqcfFRYiSBFzNei7LRLNVvSoMcS)QuQy(2eFRyDmfy)vP8fyOmLxfZxawjqa47gCdQ0MuKRLNV04BO7Ka9DM8M)DdyqoLOX0sJkxHXGuhzKtbdAuJ6B9tqyg8woFzLsG1Cdg1O(YoOUC6lng7lnSqtLUb3GrnQVStMaweo72nyuJ6Bf3x2X75lRaiQj5LWIVSAP8Ddg1O(wX9fzYJWU913kiH9PGWx2f6Ld1jS47d9syXxAt0QjiF3GBWOg1xwbqIgTLNVkYGCIVAIPs0(QiLeY)(Yo0AHQ5(cjWkotCMd0PVHUtcK7lbov)DdHUtcK)PortmvIgj6SnMcNrFXODdHUtcK)PortmvIgj6SPq6Ekp7ygQLhIewSnbOe6gcDNei)tDIMyQens0ztZKwf0J3UHq3jbY)uNOjMkrJeD20mPfrWEXn4gmQr9LvaKOrB55RWE5u7BNMIVnJ4BOBY5BY9nyFKZqzkF3qO7Ka505usCwMa(S8(YAIBWne6ojqos0zJc9YH6ewSkNGW4CqNlDNWc)tHE5qTDqoRwMcVZycia70uSnXAgaz1mXveoWl633maI1SwbDm(uOxos5z1m5hLcqf0X4tHE5iLNvZK)tmJeYbEL)Qurr)(MbqaG1SwtiZhbb8RLPW7mMwLtq8pXmsih40OII(9ndGauZexr42Xf6ojWyQAL)QCdHUtcKJeD20Yu4DgtRYjimoh0vqhJpf6LJuEwnt(rPCdHUtcKJeD2EHjLaTmXzACoOZiXSz(u6g4QKQamHAIzcl2xygfXcmUQmsmBMVzaKkailFAqcGS8PrfLJGsbaaaOc6y8hKRZH6ewSkNG4)iiGUHq3jbYrIoBdY15qDclwLtqyCoOZiXSz(u6g4vXcGjutmtyX(cZOiwGXvLrIzZ8ndGubaz5tdsaKLpnQOCeukaaaabOc6y8FHjLaTmXz(Feeqa4gCdHUtcKJeD2q5InBX0yyyk0dod7dOWTxunKZQjxmnoh0FIc6y8VOAiNvtUyAFIc6y8FeeqwZ6NOGogFnb(q1DYEXMWA2NOGogFuka74ks)zKy2mFkDdCGvjRzDNMITj2xkaNgwCdHUtcKJeD2q5InBXK7gcDNeihj6Srr6KaDdHUtcKJeD2uMeYZoqp1UHq3jbYrIoBkYXLRwclUHq3jbYrIoBZSW0CB1rFftb2UHq3jbYrIoBJ8eLjH8CdHUtcKJeD2cOw49ftRoMt3qO7Ka5irNnLOyjdBFPUg3ne6ojqos0zlHSNutSWeTAcITzeRYm01SeGmoh074ks)70uSnX(srvvgqnHmFeeWpf6Ld1jSyvobXxZexr42Xf6ojWycCACdHUtcKJeD2AcQMXsg2NenJX5GEhxr6pJeZM5tPBGtVYQynR74ks)zKy2mFn6DcSboJeZM5Bga5gcDNeihj6SHqckcKBjdl5EY5gcDNeihj6SnI5uGwY9KZne6ojqos0ztHaLhkVTkNGWn4gmQVvex8vtGJSGEYZxk0lhQT8okf5SA07yO8DCetFRFccZG3Y5lHQtcK)DdHUtcKJeD2OqVCOoHfRYjimoh05s3jSW)uOxouB5DukYz1O3XqPklawockfG8okf5(u6wv6CP7ew4Fk0lhQT8okf5SA07yOCdg13kIl(QjWrwqp55lf6Ld1wEhLICwn6Dmu(ooIPV1pbHzWB58Lq1jbY)UHq3jbYrIoBuOxouNWIv5eegNd6CP7ew4Fk0lhQT8okf5SA07yOuLfa5KjbqEhLICFkDRkDU0Dcl8pf6Ld1wEhLICwn6DmuQGLFvUb3Gr9TI4IVAcCKf0tE(sHE5qTL3rPiN1maIHY3Xrm9T(jimdElNVeQojq(3ne6ojqos0zJc9YH6ewSkNGW4CqNlDNWc)tHE5qTL3rPiN1maIHsvwaSCeuka5DukY9P0TQ05s3jSW)uOxouB5DukYzndGyOCdg13kIl(QjWrwqp55lf6Ld1wEhLICwZaigkFhhX036NGWm4TC(sO6Ka5F3qO7Ka5irNnk0lhQtyXQCccJZbDU0Dcl8pf6Ld1wEhLICwZaigkvzbqozsaK3rPi3Ns3QsNlDNWc)tHE5qTL3rPiN1maIHsfS8RYn4gmQVGDukY5lRSVKHV0WIViY503A5C6RAcQVj0xA(v5lx0e4J7lISziOTVmsmtyXxY5lf6Ld1jS8913kIlpFrWiqFPqVCO2Y7OuKZQrVJHY3a(81maIHY34eFFjpuMY77gcDNeihj6SrHE5qDclwLtqyCoOZLUtyH)PqVCO2Y7OuKZQrVJHIolaYLUtyH)PqVCO2Y7OuKZAgaXqrNfalhbLcqEhLICFkDRknS4gmQVGDukY5lRSVKHVvYIViY503A5C6RAcQVj03Q8LlAc8X9fr2me02xgjMjS4l58Lc9YH6ew((6BfXLNViyeOVuOxouB5DukYz1O3Xq5BaF(AgaXq5BCIVVKhkt59DdHUtcKJeD2OqVCOoHfRYjimoh05s3jSW)uOxouB5DukYz1O3XqrNfa5s3jSW)uOxouB5DukYzndGyOOZcGCYKaiVJsrUpLUvTswCdUbJ6B9zOR5BfciFRFccFtUVA07eypv7lkxE(2eFLSzKZ3tOMcm5m(QCccUVkbxE(sG(ofo33MjG(YeZHVHVkNGWxntCfX3G9rodLPySVKZ3jbHVcuUIAFBIVcmuMIVSAP4lOzWzCdHUtcKJeD2uMHUMLaKv5eegNd6Acz(iiGFk0lhQtyXQCcIVMjUIWTJl0DsGXe4S8RYne6ojqos0ztzg6AwcqwLtqyCoOdqbkxrnsauGYvu)pPiqvOjK5JGa(Rjfl3m4m)tmJeYbaaaUrybqf0X4RmdDncAB1etfY)rqabutiZhbb8xtkwUzWz(OuUb3Gr9LvvIzcl(YkMjq55gcDNeihj6SjarjtltCMgNd6msmBMpLUbEvQGrIzclwofJCYxtqHnRznazKyMWILtXiN81euyRkDGbiJeZM5tPBGxflaWne6ojqos0zJrIzclwzMaLNX5GoJeZM5tPBGdmG5gCdg13k0yiqEYEzQ2yFBgXx2b7QcWxQljx2z1iCFz1G(sG(QNsWEXyFRta9vMCXyFrKnJVcuUIAF5uc8jh33a(8v)4(YjxlpFvKjbHBi0DsGCKOZwnPy5MbNX4CqNtjZPTJRinxv604gcDNeihj6SnczMqXYBIjLX5GoNsMtBhxrAUQ0PXn4gmQVSZG3(YQb9nAFBcLVuxs89HEjS4BfmPc5Rc6y8DdHUtcKJeD2Qjfl3m4mgNd6kOJXhHeuei3sgwY9K7Js5gCdg1x2PmfENX036NGWxQljx2Q9fbJaf2lNVz7Bti18LNfyosDaBFFHzueFd4Z38iqETe6RYji8vbDm8n5(AMCEcl(cW4vDuE7BZi(YiXSz(Mbq(QjYyK6uGTVHwtUxcl(2eFtylqE2Q9Lm89fMrr8TJAceag7BaF(2eFFOMu(kaPfo3xntCfH7RImiN4BDs9VBi0DsGCKOZMwMcVZyAvobHX5GEhWAjSaOc6y8vMHUgbTTAIPc5)iiGaMqnXmHf7lmJIyPPAR2Q1KRkazKy2mFZaivWYNLQqI3rPi3Fg822PUM9fMrrSgbaaQGogFzIYt2lwLlqmL7Z7qxd404gcDNeihj6SPLPW7mMwLtqyCoO3bSwclaQGogFk0lhP8SAM8JsbiavqhJpf6LJuEwnt(pXmsih4v(Rsff9J1SwtiZhbb8tHE5qDclwLtq8pXmsixvf0X4tHE5iLNvZK)tmJeYbGBWne6ojqos0z7jnbi3GBi0DsGCKOZ2HYzsyXw94jwej8zCoOZPK502XvKMRkDAaubDm(hkNjHfB1JNyrKW3)rqaDdHUtcKJeD26SiNLkMMgNd6Dmfy)puotcl2QhpXIiHVVadLP8aubDm(kZqxJG2wnXuH8rPaubDm(hkNjHfB1JNyrKW3hLYne6ojqos0zt5KOzSKHDKNyCoORGogFntCN8SubNNei))iiGaEOqzqUI81mXDYZsfCEsG8VubIMuuYZne6ojqos0ztzg6Ae02wl11CdHUtcKJeD2Qjfl3m4mUHq3jbYrIoBJqMjuS8Mys5gcDNeihj6SjarjtltCMgNd6kOJXVKJ2sg2MrSeG(8o01uLoWCdHUtcKJeD2AcQMXsg2NenJBi0DsGCKOZ2HYzsyXw94jwej8zCoORGog)dLZKWIT6XtSis47)iiGUHq3jbYrIoBCQectyXQVak2APUMX5GUc6y81mXDYZsfCEsG8pkLBi0DsGCKOZMMa1cSVOLNDmdtX4Cq)r6VMa1cSVOLNDmdt5FIzKqoDwCdHUtcKJeD2uojAglzyh5jgNd6kOJXxzg6Ae02QjMkK)JGaciavqhJVYKqEtuE)FeeqwZAaQGogFLjH8MO8(Jsb4J0FLtIMXsg2rEI9r6)jJt4mHYuaaaCdHUtcKJeD2yK4ARW5culgNd6SkcNlqT8BgXQpuDQmflzyhZWu(Mr1jNBi0DsGCKOZMMjTkOhVDdHUtcKJeD20mPfrWEXne6ojqos0ztaIAsEjSyRjf3Gr9LvaeLm9LvnotFzcUVmzHroFzLWUyfi7BZeqFrMD5lcgb6RAcQVmb7fFJ23Pe82xA8LCk8VBi0DsGCKOZMaeLmTmXzACoORGog)soAlzyBgXsa6Z7qxtv604gcDNeihj6SXPsimHfR(cOyRL6AgNd6HUt2lwbkMPWvLoWautiZhbb8xtkwUzWz(NygjKRQaKOrBX2PPaiafOCf1ibqbkxr9)KIavba1eY8rqa)1KILBgCM)jMrc5ijajA0wSDAkaaaaqv6QCvUHq3jbYrIoBDwKZsfttJZbDwLoMcS)kZqxJG2wnXuHaOMqMpcc4VMuSCZGZ8pXmsix1I(biafOCf1ibqbkxr9)KIavba1eY8rqa)1KILBgCM)jMrc5iv0paaaaOkDvUk3qO7Ka5irNT40buSn5ob2gNd6cuUIAGdSkDdHUtcKJeD2ouotcl2QhpXIiHpCJBmg]] )


end