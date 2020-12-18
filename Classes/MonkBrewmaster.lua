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
            duration = 7,
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



    spec:RegisterPack( "Brewmaster", 20201217, [[d40PSaqiiPKhbjvxIsjkBse9jkLWOOu1PejwfcXRuGzrPYTOuIQDjv)cs1WuQCmIslds8mrstJsPUgLITPGW3OusJJOqDoesToesY8uqDpLY(qOoirHyHkKhcjLAIefKlQGiFubrXiHKcDsesQvsu9sIcQzcjfCtfev7uPQFsuadLOqAPkik9uLmvfQRsuG(kKuKXcjf1Eb(lfdgLdt1IHQhtyYqCzsBwuFwkJgrNwYQvq61IuZwr3Ms2nOFJ0WjYXPuISCv9CunDHRdLTtu03rW4HuoViSEesmFij7xLbYcgdwiEOG9OSdLDYIIS2AxwIo1DYIcyfjKuWsYfP9Mcwq3sbRrVsWY5H(GLKNysDeWyWItXEHcwKriXjQqh9wfKy4Db1cDEzHn9OOqX75aDEzjqhSWXQzqudb4GfIhkypk7qzNSOiRT2LLOtfSCSGK(G1QSqTblYcbrHaCWcr5cWc1p2Oxjy58q)JnKtHPp5O(XKHuHAHR)XK1wT7yOSdLDG1S4bhmgSq0SJndWyWEzbJblxeffcwCj1FdPdrm84R0kyPqhFQiGrGaShfWyWsHo(uraJalXxH(LdwCnIc24DjSVYjmz6Be6u5r5ZJL8y2FSOSutqnwoAgbP)nLFSHpwtG0TC0ogQq1XWXY5Ue2x5srmcYQJjDSKhdhlN7syFLlfXiiR(RwEb5hB4JjB3MJrKJ1eiDlhTJLYXqfQoMGsNiucWUqNkpkFAWFLq)vlVG8Jn8Xq5ye5ynbs3Yr7yjpMG0)MYn53frrH(8yeFmz72awUikkeSKW(kNOGnd(ReabyFQGXGLcD8PIagbwIVc9lhSWXY5Ue2x5srmcYQJjbwUikkeSe6u5r5td(ReabyVTbJblf64tfbmcSeFf6xoyrQ(mi7sI4ydFmB1MJL8yfuqTkyZG4wEtnPYpgXhJu9zq2TC0ogroM9hBxhLJn4y2FSDDuogrow7PyshlLJLYXsEmCSCUNPFu5efSzWFLqhHsacwUikkeSqCljfAi93ceG92agdwk0XNkcyeyj(k0VCWIu9zq2LeXXg(y2S7yjpwbfuRc2miUL3utQ8Jr8XivFgKDlhTJrKJz)X21r5ydoM9hBxhLJrKJ1EkM0Xs5yPCSKhZ(JHJLZDe3ssHgs)T6iucWJLcy5IOOqWkt)OYjkyZG)kbqa2peGXGLcD8PIagbwUikkeSCoPmDOYnVtuOVrqFFcwIVc9lhSquCSCU)orH(gb99PbrXXY5ocLa8yOcvhdrXXY5UGcrWerjt1uW0gefhlN7yshl5Xc)BA0jvFgKDjrCSHpwQYEmuHQJfLLAcQbP0Jn8XqzhybDlfSCoPmDOYnVtuOVrqFFccWEBfmgSCruuiyHXvtfQfhSuOJpveWiqa2lJbJblxeffcws0OOqWsHo(uraJabyprdgdwUikkeSWNukIjJ9jalf64tfbmceG9YUdmgSCruuiyHRpx)0fSbwk0XNkcyeia7LvwWyWYfrrHG1SAKb3mumKMLcdWsHo(uraJabyVSOagdwUikkeSY1R4tkfbSuOJpveWiqa2lBQGXGLlIIcblhkuE8(0i85eSuOJpveWiqa2lRTbJblxeffcw4EZqZM4lrAoyPqhFQiGrGaSxwBaJblf64tfbmcSeFf6xoyLRgzyE1Yli)yeFmuSbSCruuiyvqzstRgyHruCkia7LDiaJblf64tfbmcSeFf6xoyf(30OtQ(mi7sI4ydVDmzT5yOcvhl8VPrNu9zq2fy)RW4ydFms1Nbz3YrdSCruuiyfumbPHMniQhKGaSxwBfmgSCruuiyrqDjkKBOzd9r0hSuOJpveWiqa2lRmgmgSCruuiyL95uHg6JOpyPqhFQiGrGaSxwIgmgSCruuiyHtHkcgpm4VsaSuOJpveWiqa2JYoWyWsHo(uraJalXxH(LdwCnIc24DjSVYjm8WBn9ncS)jLogXhB3XsES2tXKowYJXdV10VljIJr82X4AefSX7syFLty4H3A6Bey)tkbwUikkeSKW(kNOGnd(ReabypkYcgdwk0XNkcyeyj(k0VCWIRruWgVlH9voHHhERPVrG9pP0Xi(y7owYJXPt6XsEmE4TM(DjrCmI3ogxJOGnExc7RCcdp8wtFJa7FsPJrKJTRBdy5IOOqWsc7RCIc2m4VsaeG9OGcymyPqhFQiGrGL4Rq)YblUgrbB8Ue2x5egE4TM(glhnsPJr8X2DSKhR9umPJL8y8WBn97sI4yeVDmUgrbB8Ue2x5egE4TM(glhnsjWYfrrHGLe2x5efSzWFLaia7rjvWyWsHo(uraJalXxH(LdwCnIc24DjSVYjm8WBn9nwoAKshJ4JT7yjpgNoPhl5X4H3A63LeXXiE7yCnIc24DjSVYjm8WBn9nwoAKshJihBx3gWYfrrHGLe2x5efSzWFLaia7rX2GXGLcD8PIagbwIVc9lhS4AefSX7syFLty4H3A6Bey)tkDSTJT7yjpgxJOGnExc7RCcdp8wtFJLJgP0X2o2UJL8yTNIjDSKhJhERPFxsehJ4JHYoWYfrrHGLe2x5efSzWFLaia7rXgWyWsHo(uraJalXxH(LdwCnIc24DjSVYjm8WBn9ncS)jLo22X2DSKhJRruWgVlH9voHHhERPVXYrJu6yBhB3XsEmoDspwYJXdV10VljIJr8XKDhy5IOOqWsc7RCIc2m4VsaeG9OmeGXGLcD8PIagbwIVc9lhSeu6eHsa2LW(kNOGnd(Re6cs)Bk3KFxeff6ZJn8X21TbSCruuiyHpDrAdfnd(Reabypk2kymyPqhFQiGrGL4Rq)Ybl7pMc1VL4ydoM9htH63s0FTPWJrKJjO0jcLaSNwBgULZj7VA5fKFSuowkhB4Jz7Dhl5XWXY5o(0fPPyHrqTWPDekb4XsEmbLorOeG90AZWTCozhtcSCruuiyHpDrAdfnd(ReabypkYyWyWsHo(uraJalXxH(LdwKQpdYUKio2WhZMJrKJrQ(SGndxIuFTlOyW4yOcvhZ(JrQ(SGndxIuFTlOyW4yeVDSupwYJrQ(mi7sI4ydFmB2DSualxeffcwkAs60q6Vfia7rHObJblf64tfbmcSeFf6xoyrQ(mi7sI4ydFSutfSCruuiyrQ(SGnJol0QheG9PUdmgSuOJpveWiWs8vOF5GfxsNtt4Ftd(XiE7yOawUikkeSsRnd3Y5KGaSpvzbJblf64tfbmcSeFf6xoyXL050e(30GFmI3ogkGLlIIcbRSRZcQgEqTKabyFQOagdwk0XNkcyeyj(k0VCWchlN7euxIc5gA2qFe97ysGLlIIcbR0AZWTCojia7tnvWyWsHo(uraJalXxH(LdwHdtxW2XsEmCSCUJpDrAkwyeulCAhHsaESKhRGcQvbBge3YBQbfIMOjAl(Xi(y2Fms1Nbz3Yr7ye5y767S5ydogp8wt)(05HjkrAdIB5n1y7JLYXsEmCSCURtmEjt1G)oHP(DE4I0hB4JHcy5IOOqWsOtLhLpn4VsaeG9PABWyWsHo(uraJalXxH(LdwHdtxW2XsEmCSCUlH9vUueJGS6yshl5XS)y4y5Cxc7RCPigbz1F1Yli)ydFmz72CmICSMa5yOcvhtqPtekbyxc7RCIc2m4VsO)QLxq(Xi(y4y5Cxc7RCPigbz1F1Yli)yPawUikkeSe6u5r5td(ReabyFQ2agdwUikkeSq0GIgyPqhFQiGrGaSp1HamgSuOJpveWiWs8vOF5GfxsNtt4Ftd(XiE7yOCSKhdhlN7pgNSGnZqDe1qOGiDekbiy5IOOqW6X4KfSzgQJOgcfebeG9PARGXGLcD8PIagbwIVc9lhScFQWO)yCYc2md1rudHcI0vOJpvKJL8y4y5ChF6I0uSWiOw40oM0XsEmCSCU)yCYc2md1rudHcI0XKalxeffcwr103i5tlqa2NQmgmgSuOJpveWiWs8vOF5Gfowo3fK()kIrY58Ic5Dekb4XsEShdQz630UG0)xrmsoNxuiVR2syLKKIawUikkeSWF1dsdnBY1RGaSpvIgmgSCruuiyHpDrAkwysxI0GLcD8PIagbcWEBVdmgSCruuiyLwBgULZjblf64tfbmceG92wwWyWYfrrHGv21zbvdpOwsGLcD8PIagbcWEBJcymyPqhFQiGrGL4Rq)YblCSCU3QCyOztqQgkADE4I0hJ4TJLky5IOOqWsrtsNgs)TabyVTtfmgSCruuiyfumbPHMniQhKGLcD8PIagbcWEBBBWyWsHo(uraJalXxH(Ldw4y5C)X4KfSzgQJOgcfePJqjablxeffcwpgNSGnZqDe1qOGiGaS322agdwk0XNkcyeyj(k0VCWchlN7cs)FfXi5CErH8oMey5IOOqWIlvqybBgX7q1KUePbbyVThcWyWsHo(uraJalXxH(Ldwi0OlOqHcJ3dfXKNUL2F1Yli)yBhBhy5IOOqWsqHcfgVhkIjpDlfeG922wbJblf64tfbmcSeFf6xoyHJLZD8PlstXcJGAHt7iucWJL8y2FmCSCUJpPuKjgp6iucWJHkuDm7pgowo3XNukYeJhDmPJL8yi0OJ)QhKgA2KRxni0O)A(voPJp1JLYXsbSCruuiyH)QhKgA2KRxbbyVTLXGXGLcD8PIagbwIVc9lhSqToMY5kuO9GunIhtu4t1qZM80T0ULpu6dwUikkeSiv)dJY5kuOGaS32enymy5IOOqWsqwgCSNhGLcD8PIagbcWEB2bgdwUikkeSeKLHGltfSuOJpveWiqa2BJSGXGLcD8PIagbwIVc9lhSWXY5ERYHHMnbPAOO15HlsFmI3ogkGLlIIcblfnjDAi93ceG92GcymyPqhFQiGrGL4Rq)YblxeLmvJcvRs5hJ4TJL6XsEmbLorOeG90AZWTCoz)vlVG8Jr8Xu0ubwOMOS0JL8y2FmfQFlXXgCm7pMc1VLO)AtHhJihZ(JjO0jcLaSNwBgULZj7VA5fKFSbhtrtfyHAIYspwkhlLJLYXiE7ydHnGLlIIcblUubHfSzeVdvt6sKgeG92KkymyPqhFQiGrGL4Rq)YbluRJf(uHrhF6I0uSWiOw40UcD8PICSKhtqPtekbypT2mClNt2F1Yli)yeFSMa5yjpM9htH63sCSbhZ(JPq9Bj6V2u4XiYXS)yckDIqja7P1MHB5CY(RwEb5hBWXAcKJLYXs5yPCmI3o2qydy5IOOqWkQM(gjFAbcWEBSnymyPqhFQiGrGL4Rq)YblfQFlXXg(yPkly5IOOqWYFHdvtq)xHbia7TXgWyWYfrrHG1JXjlyZmuhrnekicyPqhFQiGrGaeGL0RcQfUhGXG9YcgdwUikkeSYtLtkEphGLcD8PIagbcWEuaJblxeffcw40iMkIjp9ekcHc2mbfTccwk0XNkcyeia7tfmgSCruuiyjildo2ZdWsHo(uraJabyVTbJblxeffcwcYYqWLPcwk0XNkcyeiabialzQpVOqWEu2HYozrr2ublc(dlyJdwOMKrgYUNOE)qgIQJDSXK6Xklj6hhlt)Jzlq0SJndBXXE1wcREf5yCQLEmhlOwEOihtq6WMY7NCudfupMnPsuDmuBkuM6hkYXSfHpvy0rnBlowqpMTi8PcJoQ5UcD8PIyloM9YIwk9t(jNO2sI(HICmuoMlIIcp2S4bVFYblUKka7rziKXGL0tZ1ublu)yJELGLZd9p2qofM(KJ6htgsfQfU(htwB1UJHYou2DYp5O(XgsOPcSqrogUMPVEmb1c3JJHRTcY7htgriuPGFmifAlN0FRm28yUikkKFmkCMOFYDruuiVl9QGAH7XGn0ZtLtkEphNCxeffY7sVkOw4EmydDCAetfXKNEcfHqbBMGIwbp5UikkK3LEvqTW9yWg6cYYGJ984K7IOOqEx6vb1c3JbBOlildbxM6j)KJ6hBiHMkWcf5yQm1pXXIYspwqQhZfb9pwXpMltVMo(u7NCxeffY34sQ)gshIy4XxP1t(j3frrH8bBOlH9vorbBg8xjyxL34AefSX7syFLtyY03i0PYJYNjTpkl1euJLJMrq6Ft5d3eiDlhnuHkCSCUlH9vUueJGS6ysjXXY5Ue2x5srmcYQ)QLxq(WY2THinbs3YrlfuHkbLorOeGDHovEu(0G)kH(RwEb5dJcrAcKULJwsbP)nLBYVlIIc9jXY2T5K7IOOq(Gn0f6u5r5td(ReSRYB4y5Cxc7RCPigbz1XKo5UikkKpydDe3ssHgs)TSRYBKQpdYUKig2wTjzbfuRc2miUL3utQCIjvFgKDlhnIy)UokdSFxhfI0EkMukPKehlN7z6hvorbBg8xj0rOeGNCxeffYhSHEM(rLtuWMb)vc2v5ns1NbzxsedBZUKfuqTkyZG4wEtnPYjMu9zq2TC0iI976OmW(DDuis7PysPKss7XXY5oIBjPqdP)wDekbykN8tUlIIc5d2qhJRMkul7GULU5Csz6qLBENOqFJG((0UkVHO4y5C)DIc9nc67tdIIJLZDekbiQqfIIJLZDbfIGjIsMQPGPnikowo3XKsg(30OtQ(mi7sIy4uLfvOkkl1eudsPdJYUtUlIIc5d2qhJRMkul(j3frrH8bBOlrJIcp5UikkKpydD8jLIyYyFItUlIIc5d2qhxFU(Ply7K7IOOq(Gn0NvJm4MHIH0SuyCYDruuiFWg656v8jLICYDruuiFWg6ouO849Pr4Z5j3frrH8bBOJ7ndnBIVeP5NCxeffYhSHEbLjnTAGfgrXPMGun4txK2qrZUkVLRgzyE1YliNyuS5K7IOOq(Gn0dkMG0qZge1ds7Q8w4FtJoP6ZGSljIH3K1guHQW)MgDs1NbzxG9VcJHjvFgKDlhTtUlIIc5d2qNG6sui3qZg6JO)j3frrH8bBON95uHg6JO)j3frrH8bBOJtHkcgpm4Vs4KFYr9JjdY1JjOWC1WEf5ysyFLty4H3A6Bey)tkDS8tTo2Oxjy58q)JrLIIc59tUlIIc5d2qxc7RCIc2m4VsWUkVX1ikyJ3LW(kNWWdV103iW(NuI4DjBpftkjp8wt)UKiiEJRruWgVlH9voHHhERPVrG9pP0j3frrH8bBOlH9vorbBg8xjyxL34AefSX7syFLty4H3A6Bey)tkr8UKC6KMKhERPFxseeVX1ikyJ3LW(kNWWdV103iW(NuIi762CYp5O(XKb56XeuyUAyVICmjSVYjm8WBn9nwoAKshl)uRJn6vcwop0)yuPOOqE)K7IOOq(Gn0LW(kNOGnd(ReSRYBCnIc24DjSVYjm8WBn9nwoAKseVlz7Pysj5H3A63LebXBCnIc24DjSVYjm8WBn9nwoAKsNCxeffYhSHUe2x5efSzWFLGDvEJRruWgVlH9voHHhERPVXYrJuI4Dj50jnjp8wt)UKiiEJRruWgVlH9voHHhERPVXYrJuIi762CYp5O(XwH3A6FmBzhJMpgk7ogHAopw6Aopwck2Xk4XqPBZX4QGcr4hJqfKuS4yKQply7y0)ysyFLtuWw)yhtgKRihJaPcpMe2x5egE4TM(gb2)KshZHihZYrJu6y(RhdP4o(ur6NCxeffYhSHUe2x5efSzWFLGDvEJRruWgVlH9voHHhERPVrG9pP02UKCnIc24DjSVYjm8WBn9nwoAKsB7s2EkMusE4TM(Djrqmk7o5UikkKpydDjSVYjkyZG)kb7Q8gxJOGnExc7RCcdp8wtFJa7FsPTDj5AefSX7syFLty4H3A6BSC0iL22LKtN0K8WBn97sIGyz3DYp5O(XgnDr6JjdG2Xg9kHJv8JjW(xHXmXXW4kYXc6X0ki1)yVknvyXjpg(Re4hd35kYXOWJnvo)ybPdpgPpZhZpg(ReoMG0)MEmxMEnD8PA3XO)XMuchtH63sCSGEmf64t9yYWA7yllNtEYDruuiFWg64txK2qrZG)kb7Q8MGsNiucWUe2x5efSzWFLqxq6Ft5M87IOOqFo8UUnNCxeffYhSHo(0fPnu0m4VsWUkVzVc1VLyG9ku)wI(RnfsebLorOeG90AZWTCoz)vlVG8uszyBVljowo3XNUinflmcQfoTJqjatkO0jcLaSNwBgULZj7ysN8toQFmuJQply7ydPzHw9NCxeffYhSHUIMKonK(BzxL3ivFgKDjrmSneHu9zbBgUeP(AxqXGbQqL9KQplyZWLi1x7ckgmiEl1KKQpdYUKig2MDPCYDruuiFWg6KQplyZOZcT6TRYBKQpdYUKigo1up5NCu)yYa5Sc5Lm1zc7owqQhtgrgf1WXK(I(vuefLFmz41XOWJjMQlt1UJnIUoMo5QDhJqfKhtH63sCmUKcr0NFmhICmbc)yC6hkYXW1jLWj3frrH8bBONwBgULZjTRYBCjDonH)nn4eVHYj3frrH8bBONDDwq1WdQLKDvEJlPZPj8VPbN4nuo5NCu)yO2opoMm86yECSGkDmPVOhdb7ly7yOMOYahdhlN7NCxeffYhSHEATz4woN0UkVHJLZDcQlrHCdnBOpI(DmPt(jh1pgQTovEu(8yJELWXK(I(vK4yeivOkt9pwfhlO00hJxnyLlHdJJH4wEtpMdrow9uipDbpg(ReogowoFSIFmRIZly7y27idfJhhli1JrQ(mi7woAhtq1CUeLcJJ5cb9rky7yb9yfmuiVIehJMpgIB5n9yHNwHPy3XCiYXc6XqWSKoMIMq58Jji9VP8JHRz6RhBeDu)K7IOOq(Gn0f6u5r5td(ReSRYBHdtxWwsCSCUJpDrAkwyeulCAhHsaMSGcQvbBge3YBQbfIMOjAloX2tQ(mi7woAezxFNnd4H3A63NopmrjsBqClVPgBNssCSCURtmEjt1G)oHP(DE4I0dJYj3frrH8bBOl0PYJYNg8xjyxL3chMUGTK4y5Cxc7RCPigbz1XKsApowo3LW(kxkIrqw9xT8cYhw2UnePjqqfQeu6eHsa2LW(kNOGnd(Re6VA5fKtmowo3LW(kxkIrqw9xT8cYt5KFYDruuiFWg6iAqr7KFYDruuiFWg6pgNSGnZqDe1qOGi2v5nUKoNMW)MgCI3qjjowo3FmozbBMH6iQHqbr6iucWtUlIIc5d2qpQM(gjFAzxL3cFQWO)yCYc2md1rudHcI0vOJpvKK4y5ChF6I0uSWiOw40oMusCSCU)yCYc2md1rudHcI0XKo5UikkKpydD8x9G0qZMC9QDvEdhlN7cs)FfXi5CErH8ocLam5Jb1m9BAxq6)RigjNZlkK3vBjSsssro5UikkKpydD8PlstXct6sK(K7IOOq(Gn0tRnd3Y5KNCxeffYhSHE21zbvdpOwsNCxeffYhSHUIMKonK(BzxL3WXY5ERYHHMnbPAOO15Hlst8wQNCxeffYhSHEqXeKgA2GOEqEYDruuiFWg6pgNSGnZqDe1qOGi2v5nCSCU)yCYc2md1rudHcI0rOeGNCxeffYhSHoxQGWc2mI3HQjDjsBxL3WXY5UG0)xrmsoNxuiVJjDYDruuiFWg6ckuOW49qrm5PBP2v5neA0fuOqHX7HIyYt3s7VA5fKVT7K7IOOq(Gn0XF1dsdnBY1R2v5nCSCUJpDrAkwyeulCAhHsaM0ECSCUJpPuKjgp6iucquHk7XXY5o(KsrMy8OJjLeHgD8x9G0qZMC9QbHg9xZVYjD8PMskNCxeffYhSHoP6FyuoxHc1UkVHAPCUcfApivJ4Xef(un0SjpDlTB5dL(NCxeffYhSHUGSm4yppo5UikkKpydDbzzi4Yup5O(XgsOjPZJHA0FRJr68Jrwns9pMmKm6qA8XcshESXYOhJaPcpwck2XiDzQhZJJnvNhhdLJrFCE)K7IOOq(Gn0v0K0PH0Fl7Q8gowo3Bvom0SjivdfTopCrAI3q5K7IOOq(Gn05sfewWMr8ounPlrA7Q8MlIsMQrHQvPCI3snPGsNiucWEATz4woNS)QLxqoXkAQalutuwAs7vO(TedSxH63s0FTPqIyVGsNiucWEATz4woNS)QLxq(afnvGfQjklnLusH4THWMtUlIIc5d2qpQM(gjFAzxL3qTcFQWOJpDrAkwyeulCAsbLorOeG90AZWTCoz)vlVGCIBcKK2Rq9BjgyVc1VLO)AtHeXEbLorOeG90AZWTCoz)vlVG8bnbskPKcXBdHnNCxeffYhSHU)chQMG(Vcd7Q8Mc1VLy4uL9K7IOOq(Gn0FmozbBMH6iQHqbrabiaa]] )


end