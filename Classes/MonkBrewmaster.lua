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
        double_barrel = 672, -- 202335
        eerie_fermentation = 765, -- 205147
        guided_meditation = 668, -- 202200
        hot_trub = 667, -- 202126
        incendiary_breath = 671, -- 202272
        microbrew = 666, -- 202107
        mighty_ox_kick = 673, -- 202370
        nimble_brew = 670, -- 354540
        niuzaos_essence = 1958, -- 232876
        rodeo = 5417, -- 355917
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
                    if legendary.call_to_arms.enabled then summonPet( "yulon", 12 ) end
                elseif state.spec.brewmaster then
                    setCooldown( "keg_smash", 0 )
                    if legendary.call_to_arms.enabled then summonPet( "niuzao", 12 ) end
                else
                    if legendary.call_to_arms.enabled then summonPet( "xuen", 12 ) end
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
                    max_stack = 1,
                    copy = "bonedust_brew_debuff"
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

                if legendary.fae_exposure.enabled then applyDebuff( "target", "fae_exposure" ) end
            end,

            auras = {
                faeline_stomp = {
                    id = 327104,
                    duration = 30,
                    max_stack = 1,
                },       
                fae_exposure = {
                    id = 356773,
                    duration = 10,
                    max_stack = 1,
                } 
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
        },      
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



    spec:RegisterPack( "Brewmaster", 20210717, [[d4evbbqiss4rur6sqrvTjOWNirvgfOOtbkSkfs9kKsZIkQBPqI2Lk9lsKHrcDmfILrs8msuMMcfxtHQTrcQVrsQghuu5CKK06uiH5rcCpKQ9rfCqOOKfck9qfsAIkuQUijj6JkusnsfkLtcfvzLujVKev1mHIs5MkusStKIFsIknusszPkus6Pq1uHsDvOO4RKOIXcfLQ9IYFPQbl5WIwmsEmPMSsDzInRIpROrJWPfwnjiVMk1SvYTvWUv1VHmCeDCfkXYbEoQMUuxhKTtf67GQXdLCEsQ1tfX8HISFkZgHHndFNTWOrffvzefv9ru17iJrXrgr1z4TAsHHtMA35uy4FoimCybc8HK3cGHtMQxOCZWMHZrqaTWWj6MKpkusPz0equxnAqjEmaTYoqVgKNwjEmOvIHtbfRgZ7zum8D2cJgvuuLruu1hrvVJmgfhzKXWWtOMaby44XWOYWjI9wEgfdFlCndhwGaFi5TaSASc6DBUCbTuB1iQUZwPIIQmI5YCnQe5pf(OWCnkTsvVJyv86f0w4wPAqG4Oo(PvWce4wjFdcHBfqwzlBRAKvyEVJi3Iv0eqojrw1ezB1gz1JARG4XpTItkAR4s3Xp5xRSs1aihJTy1rKnvQDBf6TASo6Xge11CnkTAShCGmtW2QxGBvNGP0xncT2i4)LmH4Ip1DG(lqgY45wPr)o6a9CRAISTAJELxBfr6Oyv(wf)OCMdIvYybkCmxY3xg(k4nNHndFlNeA1mSz0mcdBgEQ7a9mCoPKapr(BpVbHBHHlFsTKndwwZOrfg2mC5tQLSzWYW1GOfqKmCU0D8t(Leceh1(dc41Ys4DKlRWWkyAvhdIVr(HelVMibtHBLcSAQ33HelRWeMSIc6CUKqG4eY2RjIlePvyyff05CjHaXjKTxtexGmKXZTsbwnYDCRgTvt9(oKyzfmSctyYkncT2i4)vllH3rU8uab(fidz8CRuGvQy1OTAQ33HelRWWknrcMc3FaPUd0NlRCWQrUJZWtDhONHtcbIJ64NEkGaN1mAugdBgU8j1s2myz4Aq0cisgof05CjHaXjKTxtexisgEQ7a9mCTSeEh5Ytbe4SMrZyyyZWLpPwYMbldxdIwarYWjKC1exsDBLcSs1h3kmSkEnAi(PFNd5u8kJBLdwri5QjUdjwwnARGPvkEvXkATcMwP4vfRgTvtacI0kyyfmScdROGoN7bb64Oo(PNciWVBe8NHN6oqpdFNdKY7jsWaRz0modBgU8j1s2myz4Aq0cisgoHKRM4sQBRuGvJROvyyv8A0q8t)ohYP4vg3khSIqYvtChsSSA0wbtRu8QIv0AfmTsXRkwnARMaeePvWWkyyfgwbtROGoN7ohiL3tKGH7gb)Tcgm8u3b6z4heOJJ64NEkGaN1mAuyg2mC5tQLSzWYW1GOfqKm8obtPVBHc6CU6K3XpVaj1ndp1DGEgoNusGNi)TN3GWTWAgnQodBgU8j1s2myz4PUd0ZWtoHJ5lCpiDcc41iqUy4Aq0cisg(wOGoNliDcc41iqU8BHc6CUBe83kmHjR2cf05C1OFdP7WrXhVB)wOGoNlePvyyvNGP0xcjxnXLu3wPaRu2iwHjmzvhdIVr(DiwPaRurrg(Ndcdp5eoMVW9G0jiGxJa5I1mAWCmSz4YNulzZGLH)5GWW3aj3NaiEhfoxwm8u3b6z4BGK7taeVJcNllwZOrvzyZWtDhONHdXfF0YaNHlFsTKndwwZOzefzyZWtDhONHtI6a9mC5tQLSzWYAgnJmcdBgEQ7a9mCQfcT9hiGAgU8j1s2myznJMruHHndp1DGEgoLa4cWD8tgU8j1s2myznJMrugdBgEQ7a9m8vmjAUxHG2Zb5BgU8j1s2myznJMrgddBgEQ7a9m8taeQfcTz4YNulzZGL1mAgzCg2m8u3b6z45RfEdYLxNRfdx(KAjBgSSMrZikmdBgEQ7a9mCQC6rhFdcTBodx(KAjBgSSMrZiQodBgU8j1s2myz4Aq0cisgENGP03ogeFJ87qSYbRuyRWWkncT2i4)Leceh1Xp9uab(vtKGPW9hqQ7a95YkfyLkm8u3b6z4X7iYT4)aYjjI1mAgbZXWMHlFsTKndwgUgeTaIKH3jyk9LqYvtCj1TvkGUvJmUvyctw1jyk9LqYvtC1qaG8TvkWkcjxnXDiXIHN6oqpdVrqAcp643s2eSMrZiQkdBgEQ7a9mC4ssIEUhD8iWwamC5tQLSzWYAgnQOidBgEQ7a9m8tUwY7rGTay4YNulzZGL1mAuzeg2m8u3b6z4uOx2q82tbe4mC5tQLSzWYAgnQOcdBgU8j1s2myz4PUd0ZWjHaXrD8tpfqGZW3cxdcYoqpdhZWfR0O)etiGSTIeceh1EENZPa8AiaGG0QdanyfSab(qYBbyfISd0ZVmCniAbejdNlDh)KFjHaXrTN35CkaVgcaiiTYbRu0kmSAcqqKwHHv8oNtbCj1Tvoq3kU0D8t(Leceh1EENZPa8AiaGGK1mAurzmSz4YNulzZGLHN6oqpdNeceh1Xp9uabodFlCnii7a9mCmdxSsJ(tmHaY2ksiqCu75DoNcWRHaacsRoa0GvWce4djVfGviYoqp)YW1GOfqKmCU0D8t(Leceh1EENZPa8AiaGG0khSsrRWWkoAHScdR4DoNc4sQBRCGUvCP74N8ljeioQ98oNtb41qaabPvJ2kfVJZAgnQmgg2mC5tQLSzWYWtDhONHtcbIJ64NEkGaNHVfUgeKDGEgoMHlwPr)jMqazBfjeioQ98oNtb4hsSiiT6aqdwblqGpK8wawHi7a98ldxdIwarYW5s3Xp5xsiqCu75DoNcWpKyrqALdwPOvyy1eGGiTcdR4DoNc4sQBRCGUvCP74N8ljeioQ98oNtb4hsSiiznJgvgNHndx(KAjBgSm8u3b6z4KqG4Oo(PNciWz4BHRbbzhONHJz4IvA0FIjeq2wrcbIJApVZ5ua(HelcsRoa0GvWce4djVfGviYoqp)YW1GOfqKmCU0D8t(Leceh1EENZPa8djweKw5GvkAfgwXrlKvyyfVZ5uaxsDBLd0TIlDh)KFjHaXrTN35Cka)qIfbPvJ2kfVJZAgnQOWmSz4YNulzZGLHN6oqpdNeceh1Xp9uabodFlCnii7a9m8rn5TvQgSwTHaXpTQjeROjGCsIScE8BeCNTIcQTc9l1wfhRaIw(EP2kIOVmCniAbejdN35CkGBoGG(UrnQZfPUTYb6wP4v1TcdRGPvAeATrW)B8oICl(pGCsI8nH4PwP2ThH1fidz8CRuGvJBfMWKvuqNZnEhrUf)hqojr(Mq8uRu72JW6crAfmynJgvuDg2mC5tQLSzWYWtDhONHtcbIJ64NEkGaNHVfUgeKDGEgoENZPaScZ3k0Xkvu0k4XAzL7yTSsncYQ4TsL74wXfn63CRGhnbcQTIqYv8tRqaRiHaXrD8ZRvwHz4Y2k4eYBfjeioQ98oNtb41qaabPv5VTAiXIG0QeiwTdEsTK9LHRbrlGiz4CP74N8ljeioQ98oNtb41qaabPv0TsrRWWkU0D8t(Leceh1EENZPa8djweKwr3kfTcdRMaeePvyyfVZ5uaxsDBLdwPIISMrJkyog2mC5tQLSzWYWtDhONHtcbIJ64NEkGaNHVfUgeKDGEgoENZPaScZ3k0XQru0k4XAzL7yTSsncYQ4TACR4Ig9BUvWJMab1wri5k(PviGvKqG4Oo(51kRWmCzBfCc5TIeceh1EENZPa8AiaGG0Q83wnKyrqAvceR2bpPwY(YW1GOfqKmCU0D8t(Leceh1EENZPa8AiaGG0k6wPOvyyfx6o(j)scbIJApVZ5ua(HelcsROBLIwHHvC0czfgwX7CofWLu3w5GvJOiRz0OIQYWMHlFsTKndwgEQ7a9mCsiqCuh)0tbe4m8TW1GGSd0ZWh7qdKwPAWALMibtHBvJGNGn3QMqSs(TvOJv0eqojrJcRYxDte)0QGBfL0TaSQjY3Qh1eXpVmCniAbejdNc6CUX7iYT4)aYjjY3eINALA3EewxisRWWkkOZ5gVJi3I)diNKiFtiEQvQD7ryDbYqgp3kfyfMJ1mAuMImSz4YNulzZGLHN6oqpdNeceh1Xp9uabodFlCnii7a9mCmlhrX2kDssg)0knrcMc3zROGARirOLvAIemfUvCceOxQTIsoiGyfnbKtsKvA0GWTcI0Q83wLRfcUvBObY4Nw1iRshrX2kDssg)0Qnei(Pv0eqojrxgUgeTaIKHRrO1gb)VKqG4Oo(PNciWVAIemfU)asDhOpxw5aDRg5I5ScdRGPvAeATrW)B8oICl(pGCsI8nH4PwP2ThH1fidz8CRCWQru0kmHjROGoNB8oICl(pGCsI8nH4PwP2ThH1fI0kyWAgnkBeg2mC5tQLSzWYWtDhONHtTsTBpclpfqGZW3cxdcYoqpdh2vQDBLYflRGfiWTk4wPHaa57LARG4Y2QgzLenHaSciKl5doHvuabo3kQKlBRqVvlHZTQjY3kICDSkTIciWTstKGPyv6ygRKAjoBfcy1cb3k5fWuTvnYk5tQLyLYxMwHpKCcgUgeTaIKHRrO1gb)VKqG4Oo(PNciWVAIemfU)asDhOpxwPaRu8ooRz0OmvyyZWLpPwYMbldxdIwarYWHPvYlGPARO1kyAL8cyQ(cKP8wnAR0i0AJG)x3Y0ZhsoXfidz8CRGHvWWkfy1yu0kmSIc6CUuRu7gb1EnAGcD3i4VvyyLgHwBe8)6wME(qYjUqKm8u3b6z4uRu72JWYtbe4SMrJYugdBgU8j1s2myz4PUd0ZWfSiLLNibdm8TW1GGSd0ZWhBsUIFALQCfyfagUgeTaIKHti5QjUK62kfy14wnARiKCf)0ZjjeGC1iOVTctyYkyAfHKR4NEojHaKRgb9Tvoq3kLzfgwri5QjUK62kfy14kAfmynJgLngg2mC5tQLSzWYW1GOfqKmCcjxnXLu3wPaRuMYy4PUd0ZWjKCf)0lRaRaWAgnkBCg2mC5tQLSzWYW1GOfqKmCncT2i4)Lc9YgI3EkGa)cKHmEUvkWQXyfgwXrqlQ433LKBpLAVGvoqUKR8j1s2m8u3b6z4NLWj0G80SMrJYuyg2mC5tQLSzWYWtDhONH7wME(qYjy4BHRbbzhONHRCph55HJYsTZw1eIvywQgMnRibbceD4eHBLYh3k0BLEjPJIZwblc3kzXfNTcE0ewjVaMQTItk)waCRYFBLEZTIJaTSTIswi4mCniAbejdNtkRLVtWuAUvoq3kvynJgLP6mSz4YNulzZGLHRbrlGiz4CszT8DcMsZTYb6wPcdp1DGEg(jLv8IN3ObswZOrzyog2mC5tQLSzWYWtDhONH7wME(qYjy4BHRbbzhONHpQjVTs5JBv2w1isRibbYQnei(PvkhKY1kkOZ5YW1GOfqKmCkOZ5cxss0Z9OJhb2c4crYAgnktvzyZWLpPwYMbldp1DGEgUwwcVJC5PacCg(w4Aqq2b6z4JQSeEh5YkybcCRibbceTARGtiV4OaSkARAeYTv8y(Xj053wTZHCkwL)2QaGEU74TIciWTIc6CSk4wneCE8tRGzUviiEBvtiwri5QjUdjwwPrY5e6q(2QuRrGD8tRAKvX3YZJwTvOJv7CiNIvD6wEy4Sv5VTQrwTHgiTsWslCUvAIemfUvuYbbeRGfb7LHRbrlGiz4D(UJFAfgwrbDoxQvQDJGAVgnqHUBe83kmSkEnAi(PFNd5u8QOQQQQoWTYbRGPvesUAI7qILvJ2kfVkoUv0AfVZ5ua3vYBFhA3(DoKtXpgRGHvyyff05CLfepCu8uGe(saxENA3wPaRuH1mAgJImSz4YNulzZGLHRbrlGiz4D(UJFAfgwrbDoxsiqCcz71eXfI0kmScMwrbDoxsiqCcz71eXfidz8CRuGvJCh3QrB1uVTctyYkncT2i4)Leceh1Xp9uab(fidz8CRCWkkOZ5scbItiBVMiUaziJNBfmy4PUd0ZW1Ys4DKlpfqGZAgnJzeg2m8u3b6z4BPryXWLpPwYMblRz0mgvyyZWLpPwYMbldxdIwarYW5KYA57emLMBLd0TsfRWWkkOZ5cG4eXp9kuUfp8433nc(ZWtDhONHdG4eXp9kuUfp843SMrZyugdBgU8j1s2myz4Aq0cisgENl57laIte)0Rq5w8WJFFLpPwY2kmSIc6CUuRu7gb1EnAGcDHiTcdROGoNlaIte)0Rq5w8WJFFHiz4PUd0ZW7ykapzUgynJMXmgg2mC5tQLSzWYW1GOfqKmCkOZ5Qjsaq2EYKZd0ZVBe83kmSca9YbbMYvtKaGS9KjNhONFLXcuqskBgEQ7a9mCkGKnHhD8NaiSMrZygNHndp1DGEgo1k1UrqT3DODZWLpPwYMblRz0mgfMHndp1DGEgUBz65djNGHlFsTKndwwZOzmQodBgU8j1s2myz4Aq0cisgUgHwBe8)EszfV45nAG8cKHmEUvoyLkwHHvCszT8DcMsZTYb6wPcdp1DGEgUMi8uqaEZAgnJbZXWMHN6oqpd)KYkEXZB0ajdx(KAjBgSSMrZyuvg2mC5tQLSzWYW1GOfqKmCkOZ5oJt7rhFtiEewxENA3w5aDRugdp1DGEgUGfPS8ejyG1mAgxrg2m8u3b6z4ncst4rh)wYMGHlFsTKndwwZOz8ryyZWLpPwYMbldxdIwarYWPGoNlaIte)0Rq5w8WJFF3i4pdp1DGEgoaIte)0Rq5w8WJFZAgnJRcdBgU8j1s2myz4Aq0cisgof05C1ejaiBpzY5b65xisgEQ7a9mCoz8F8tVgKV4DhA3SMrZ4kJHndx(KAjBgSmCniAbejdFJ6Rg9A5Bq2Y2Fw5GCbYqgp3k6wPidp1DGEgUg9A5Bq2Y2Fw5GWAgnJpgg2mC5tQLSzWYW1GOfqKmCkOZ5sTsTBeu71Obk0DJG)wHHvW0kkOZ5sTqO9cI33nc(BfMWKvW0kkOZ5sTqO9cI3xisRWWQnQVuajBcp64pbq8BuFbYbiCIKAjwbdRGbdp1DGEgofqYMWJo(taewZOz8XzyZWLpPwYMbldxdIwarYWvfwjCU8A52eIxdG0b1s8OJ)SYb5oKkecWWtDhONHtijO9cNlVwynJMXvyg2m8u3b6z4AIWtbb4ndx(KAjBgSSMrZ4QodBgEQ7a9mCnr4HNokmC5tQLSzWYAgnJJ5yyZWtDhONHlyrUq74NE3YKHlFsTKndwwZOzCvLHndx(KAjBgSm8u3b6z4cwKYYtKGbg(w4Aqq2b6z4QsSiLLvJTemyfrYTIiMecWQXUQPkX2QMiFRWw1ScoH8wPgbzfr6Oyv2wTKK3wPIviaf)YW1GOfqKmCkOZ5oJt7rhFtiEewxENA3w5aDRuH1mAuyfzyZWLpPwYMbldp1DGEgoNm(p(PxdYx8UdTBg(w4Aqq2b6z4JAYBRWhvLVvXXk5rqtcRKxgcHBvceRsac63oBfcyvCSs5OCuoyRCTk4wjFsTK91kSjcUvb3Q0k(kMeTvB5ippCuSAH4CRqokaRG4XpTcBvZkkO2QP8cixl1wbKnKw4wXJbRCmbr(AXQbeqSQjY3Q8v3eXpTswC5YW1GOfqKmCyAvQ7WrXlVmec3khOBLYSctyYkn63qrFHNl3E4rt4BcXJW6kFsTKTvWWkmSsJqRnc(FDltpFi5exGmKXZTYbRM6TvyyfmTsEbmvBfTwbtRKxat1xGmL3QrBfmTsJqRnc(FDltpFi5exGmKXZTIwReSenul(ogeRGHvWWkyyLd0TsHh3kmScMwPkSQZL89Ltg9jaYv(KAjBRWeMSsvyfa6LdcmLRMibaz7jtopqp)kJfOGKu2wbdwZOrHhHHndx(KAjBgSmCniAbejdxvyvNl57l1k1UrqTxJgOqx5tQLSTcdR0i0AJG)x3Y0ZhsoXfidz8CRCWQPEBfgwbtRKxat1wrRvW0k5fWu9fit5TA0wbtR0i0AJG)x3Y0ZhsoXfidz8CRO1QPEBfmScgwbdRCGUvk84m8u3b6z4DmfGNmxdSMrJcRcdBgU8j1s2myz4Aq0cisgU8cyQ2kfyLYgHHN6oqpdpb68fFJaa5BwZOrHvgdBgEQ7a9mCaeNi(PxHYT4Hh)MHlFsTKndwwZAgojq0ObQSzyZOzeg2m8u3b6z4NLWj0G80mC5tQLSzWYAgnQWWMHN6oqpdNc19s2(ZkvlB4Xp9ncR4z4YNulzZGL1mAugdBgEQ7a9mCnr4PGa8MHlFsTKndwwZOzmmSz4PUd0ZW1eHhE6OWWLpPwYMblRznRz4okaEGEgnQOOkJOOcRIQZWHNGp(jNHRCWSgRsdMhnJ1JcRScBcXQyGebARoiGvkVTCsOvR8SciJfOaiBR4ObXQeQrdzlBR0e5pf(1CHzlEXkfEKrHvJk6DuaTSTs515s((Izx5zvJSs515s((Iz)kFsTKTYZkyocwW4AUmxyEdKiqlBRuXQu3b6TAf8MFnxmCoPOz0OIcJ5y4Ka0jwcd3Po1kybc8HK3cWQXkO3T5YPo1kxql1wnIQ7SvQOOkJyUmxo1PwnQe5pf(OWC5uNA1O0kv9oIvXRxqBHBLQbbIJ64NwblqGBL8nieUvazLTSTQrwH59oIClwrta5KezvtKTvBKvpQTcIh)0koPOTIlDh)KFTYkvdGCm2Ivhr2uP2TvO3QX6OhBquxZLtDQvJsRg7bhiZeST6f4w1jyk9vJqRnc(FjtiU4tDhO)cKHmEUvA0VJoqp3QMiBR2Ox51wrKokwLVvXpkN5GyLmwGchZL891CzUCQtTsvILOHAzBfLCqaXknAGkBROKz88RvywATq2CRE0pkjsWWbAzvQ7a9CRq)s91CL6oqp)scenAGkBAPR0zjCcnipT5k1DGE(LeiA0av20sxjku3lz7pRuTSHh)03iSI3CL6oqp)scenAGkBAPRKMi8uqaEBUsDhONFjbIgnqLnT0vsteE4PJI5YC5uNALQelrd1Y2kXrbO2QogeRAcXQu3iGvb3Q0Xmwj1sUMRu3b6505Ksc8e5V98geUfZL5k1DGEoT0vIeceh1Xp9uabUZXHox6o(j)scbIJA)bb8Azj8oYfgWSJbX3i)qILxtKGPWvWuVVdjwyctuqNZLeceNq2EnrCHiXGc6CUKqG4eY2RjIlqgY45kyK74JEQ33HelyGjmPrO1gb)VAzj8oYLNciWVaziJNRavg9uVVdjwyOjsWu4(di1DG(C5Wi3XnxPUd0ZPLUsAzj8oYLNciWDoo0PGoNljeioHS9AI4crAUsDhONtlDL25aP8EIem4CCOti5QjUK6wbQ(4yeVgne)0VZHCkELXDGqYvtChsSgnmv8QcTWuXRkJEcqqKWagyqbDo3dc0XrD8tpfqGF3i4V5k1DGEoT0v6GaDCuh)0tbe4ohh6esUAIlPUvW4kIr8A0q8t)ohYP4vg3bcjxnXDiXA0WuXRk0ctfVQm6jabrcdyGbmPGoN7ohiL3tKGH7gb)HH5YCL6oqpNw6kXjLe4jYF75niClohh6DcMsF3cf05C1jVJFEbsQBZvQ7a9CAPReex8rldo)5Gqp5eoMVW9G0jiGxJa5Y54qFluqNZfKobb8Aeix(TqbDo3nc(JjmTfkOZ5Qr)gs3HJIpE3(TqbDoxism6emL(si5QjUK6wbkBemHPogeFJ87quGkkAUsDhONtlDLG4IpAzW5phe6BGK7taeVJcNllZvQ7a9CAPReex8rldCZvQ7a9CAPRejQd0BUsDhONtlDLOwi02FGaQnxPUd0ZPLUsucGla3XpnxPUd0ZPLUsRys0CVcbTNdY3MRu3b650sxPtaeQfcTnxPUd0ZPLUs5RfEdYLxNRL5k1DGEoT0vIkNE0X3Gq7MBUsDhONtlDLI3rKBX)bKtsKVjep1k1U9iSCoo07emL(2XG4BKFhIdkmgAeATrW)ljeioQJF6Pac8RMibtH7pGu3b6ZLcuXCL6oqpNw6k1iinHhD8BjBcNJd9obtPVesUAIlPUva9rghtyQtWu6lHKRM4QHaa5Bfqi5QjUdjwMRu3b650sxj4ssIEUhD8iWwaMRu3b650sxPtUwY7rGTamxPUd0ZPLUsuOx2q82tbe4MlZLtTcZWfR0O)etiGSTIeceh1EENZPa8AiaGG0QdanyfSab(qYBbyfISd0ZVMRu3b650sxjsiqCuh)0tbe4ohh6CP74N8ljeioQ98oNtb41qaabPdkIXeGGiXG35CkGlPUDGox6o(j)scbIJApVZ5uaEneaqqAUCQvygUyLg9NycbKTvKqG4O2Z7CofGxdbaeKwDaObRGfiWhsElaRqKDGE(1CL6oqpNw6krcbIJ64NEkGa354qNlDh)KFjHaXrTN35CkaVgcaiiDqrm4OfcdENZPaUK62b6CP74N8ljeioQ98oNtb41qaab5Ov8oU5YC5uRWmCXkn6pXeciBRiHaXrTN35Cka)qIfbPvhaAWkybc8HK3cWkezhONFnxPUd0ZPLUsKqG4Oo(PNciWDoo05s3Xp5xsiqCu75DoNcWpKyrq6GIymbiism4DoNc4sQBhOZLUJFYVKqG4O2Z7CofGFiXIG0C5uRWmCXkn6pXeciBRiHaXrTN35Cka)qIfbPvhaAWkybc8HK3cWkezhONFnxPUd0ZPLUsKqG4Oo(PNciWDoo05s3Xp5xsiqCu75DoNcWpKyrq6GIyWrleg8oNtbCj1Td05s3Xp5xsiqCu75DoNcWpKyrqoAfVJBUmxo1Qrn5TvQgSwTHaXpTQjeROjGCsIScE8BeCNTIcQTc9l1wfhRaIw(EP2kIOVMRu3b650sxjsiqCuh)0tbe4ohh68oNtbCZbe03nQrDUi1Td0v8Q6yatncT2i4)nEhrUf)hqojr(Mq8uRu72JW6cKHmEUcghtyIc6CUX7iYT4)aYjjY3eINALA3EewxisyyUmxo1k8oNtbyfMVvOJvQOOvWJ1Yk3XAzLAeKvXBLk3XTIlA0V5wbpAceuBfHKR4NwHawrcbIJ64NxRScZWLTvWjK3ksiqCu75DoNcWRHaacsRYFB1qIfbPvjqSAh8KAj7R5k1DGEoT0vIeceh1Xp9uabUZXHox6o(j)scbIJApVZ5uaEneaqqsxrm4s3Xp5xsiqCu75DoNcWpKyrqsxrmMaeejg8oNtbCj1TdQOO5YPwH35CkaRW8TcDSAefTcESww5owlRuJGSkERg3kUOr)MBf8OjqqTvesUIFAfcyfjeioQJFETYkmdx2wbNqERiHaXrTN35CkaVgcaiiTk)TvdjweKwLaXQDWtQLSVMRu3b650sxjsiqCuh)0tbe4ohh6CP74N8ljeioQ98oNtb41qaabjDfXGlDh)KFjHaXrTN35Cka)qIfbjDfXGJwim4DoNc4sQBhgrrZL5YPwn2HgiTs1G1knrcMc3QgbpbBUvnHyL8BRqhROjGCsIgfwLV6Mi(Pvb3kkPBbyvtKVvpQjIFEnxPUd0ZPLUsKqG4Oo(PNciWDoo0PGoNB8oICl(pGCsI8nH4PwP2ThH1fIedkOZ5gVJi3I)diNKiFtiEQvQD7ryDbYqgpxbyoZL5YPwHz5ik2wPtsY4NwPjsWu4oBffuBfjcTSstKGPWTItGa9sTvuYbbeROjGCsISsJgeUvqKwL)2QCTqWTAdnqg)0Qgzv6ik2wPtsY4NwTHaXpTIMaYjj6AUsDhONtlDLiHaXrD8tpfqG7CCORrO1gb)VKqG4Oo(PNciWVAIemfU)asDhOpxoqFKlMddyQrO1gb)VX7iYT4)aYjjY3eINALA3EewxGmKXZDyefXeMOGoNB8oICl(pGCsI8nH4PwP2ThH1fIegMlZLtTc2vQDBLYflRGfiWTk4wPHaa57LARG4Y2QgzLenHaSciKl5doHvuabo3kQKlBRqVvlHZTQjY3kICDSkTIciWTstKGPyv6ygRKAjoBfcy1cb3k5fWuTvnYk5tQLyLYxMwHpKCcZvQ7a9CAPRe1k1U9iS8uabUZXHUgHwBe8)scbIJ64NEkGa)QjsWu4(di1DG(CPafVJBUsDhONtlDLOwP2ThHLNciWDoo0HP8cyQMwykVaMQVazk)O1i0AJG)x3Y0ZhsoXfidz8CyadfmgfXGc6CUuRu7gb1EnAGcD3i4pgAeATrW)RBz65djN4crAUmxo1QXMKR4NwPkxbwbWCL6oqpNw6kjyrklprcgCoo0jKC1exsDRGXhnHKR4NEojHaKRgb9nMWemjKCf)0ZjjeGC1iOVDGUYWGqYvtCj1TcgxryyUsDhONtlDLiKCf)0lRaRa4CCOti5QjUK6wbktzMlZvQ7a9CAPR0zjCcnipTZXHUgHwBe8)sHEzdXBpfqGFbYqgpxbJbdocArf)(UKC7Pu7fSYbYLCLpPwY2CzUCQvk3ZrEE4OSu7SvnHyfMLQHzZksqGarhor4wP8XTc9wPxs6O4SvWIWTswCXzRGhnHvYlGPAR4KYVfa3Q83wP3CR4iqlBROKfcU5k1DGEoT0vYTm98HKt4CCOZjL1Y3jykn3b6QyUsDhONtlDLoPSIx88gnq6CCOZjL1Y3jykn3b6QyUmxo1Qrn5TvkFCRY2QgrAfjiqwTHaXpTs5GuUwrbDoxZvQ7a9CAPRKBz65djNW54qNc6CUWLKe9Cp64rGTaUqKMlZLtTAuLLW7ixwblqGBfjiqGOvBfCc5fhfGvrBvJqUTIhZpoHo)2QDoKtXQ83wfa0ZDhVvuabUvuqNJvb3QHGZJFAfmZTcbXBRAcXkcjxnXDiXYknsoNqhY3wLAncSJFAvJSk(wEE0QTcDSANd5uSQt3YddNTk)TvnYQn0aPvcwAHZTstKGPWTIsoiGyfSiyVMRu3b650sxjTSeEh5Ytbe4ohh6D(UJFIbf05CPwP2ncQ9A0af6UrWFmIxJgIF635qofVkQQQQQdChGjHKRM4oKynAfVkooT8oNtbCxjV9DOD735qof)yGbguqNZvwq8WrXtbs4lbC5DQDRavmxPUd0ZPLUsAzj8oYLNciWDoo078Dh)edkOZ5scbItiBVMiUqKyatkOZ5scbItiBVMiUaziJNRGrUJp6PEJjmPrO1gb)VKqG4Oo(PNciWVaziJN7af05CjHaXjKTxtexGmKXZHH5YCL6oqpNw6kTLgHL5YCL6oqpNw6kbG4eXp9kuUfp843ohh6CszT8DcMsZDGUkyqbDoxaeNi(PxHYT4Hh)(UrWFZvQ7a9CAPRuhtb4jZ1GZXHENl57laIte)0Rq5w8WJFFLpPwYgdkOZ5sTsTBeu71Obk0fIedkOZ5cG4eXp9kuUfp843xisZvQ7a9CAPRefqYMWJo(taeNJdDkOZ5Qjsaq2EYKZd0ZVBe8hda0lheykxnrcaY2tMCEGE(vglqbjPSnxPUd0ZPLUsuRu7gb1E3H2T5k1DGEoT0vYTm98HKtyUsDhONtlDL0eHNccWBNJdDncT2i4)9KYkEXZB0a5fidz8ChubdoPSw(obtP5oqxfZvQ7a9CAPR0jLv8IN3ObsZvQ7a9CAPRKGfPS8ejyW54qNc6CUZ40E0X3eIhH1L3P2Td0vM5k1DGEoT0vQrqAcp643s2eMRu3b650sxjaeNi(PxHYT4Hh)254qNc6CUaior8tVcLBXdp(9DJG)MRu3b650sxjoz8F8tVgKV4DhA3ohh6uqNZvtKaGS9KjNhONFHinxPUd0ZPLUsA0RLVbzlB)zLdIZXH(g1xn61Y3GSLT)SYb5cKHmEoDfnxPUd0ZPLUsuajBcp64pbqCoo0PGoNl1k1UrqTxJgOq3nc(JbmPGoNl1cH2liEF3i4pMWemPGoNl1cH2liEFHiXyJ6lfqYMWJo(tae)g1xGCacNiPwcmGH5k1DGEoT0vIqsq7foxET4CCORkeoxETCBcXRbq6GAjE0XFw5GChsfcbmxPUd0ZPLUsAIWtbb4T5k1DGEoT0vsteE4PJI5k1DGEoT0vsWICH2Xp9ULP5YPwPkXIuwwn2sWGvej3kIysiaRg7QMQeBRAI8TcBvZk4eYBLAeKvePJIvzB1ssEBLkwHau8R5k1DGEoT0vsWIuwEIem4CCOtbDo3zCAp64BcXJW6Y7u72b6QyUCQvJAYBRWhvLVvXXk5rqtcRKxgcHBvceRsac63oBfcyvCSs5OCuoyRCTk4wjFsTK91kSjcUvb3Q0k(kMeTvB5ippCuSAH4CRqokaRG4XpTcBvZkkO2QP8cixl1wbKnKw4wXJbRCmbr(AXQbeqSQjY3Q8v3eXpTswC5AUsDhONtlDL4KX)Xp9Aq(I3DOD7CCOdZu3HJIxEzieUd0vgMWKg9BOOVWZLBp8Oj8nH4ryDLpPwYggyOrO1gb)VULPNpKCIlqgY45om1BmGP8cyQMwykVaMQVazk)OHPgHwBe8)6wME(qYjUaziJNtRGLOHAX3XGadyadhORWJJbmvfDUKVVCYOpbqUYNulzJjmPkaqVCqGPC1ejaiBpzY5b65xzSafKKYggMRu3b650sxPoMcWtMRbNJdDvrNl57l1k1UrqTxJgOqyOrO1gb)VULPNpKCIlqgY45om1BmGP8cyQMwykVaMQVazk)OHPgHwBe8)6wME(qYjUaziJNt7uVHbmGHd0v4XnxPUd0ZPLUsjqNV4BeaiF7CCOlVaMQvGYgXCL6oqpNw6kbG4eXp9kuUfp843SM1mg]] )


end