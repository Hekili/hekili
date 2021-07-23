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
    

    spec:RegisterSetting( "ox_walker", true, {
        name = "Use |T606543:0|t Spinning Crane Kick in Single-Target with Walk with the Ox",
        desc = "If checked, the default priority will recommend |T606543:0|t Spinning Crane Kick when Walk with the Ox is active.  This tends to " ..
            "reduce mitigation slightly but increase damage based on using Invoke Niuzao more frequently.  This is consistent with 9.1 SimulationCraft " ..
            "behavior.",
        type = "toggle",
        width = "full",
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



    spec:RegisterPack( "Brewmaster", 20210723, [[d4eQcbqiss0JOc5skeKnbf(ejjmkqLofOIvPq0RqsMfvs3IePSlv8lsudJK4ykKwgsQNbLY0uO01uOABKi5BKKQXbLuoNcfwNcHmpOuDpsyFubhekjAHGQEijjnrfkQlQqGpQqrAKqjHtsIiwjvQxcLuntfkIBsIiTtKOFsIunusszPkeu9uOAQiHRcLK(kjIASkeu2lQ(lvnyjhw0IrQhtQjRsxMyZk1NvYOr40cRMeHxtfnBfDBfSBv9BidhrhxHqTCGNJY0L66GSDQeFhugpu05jPwpvOMpuI9tz(OCk443SfoLuRc1JQIQtn2oJQ6Js9yhlhVvtkCCYu7mxch)ZbHJdpqGnKSwaCCYu9eLxofCCgccOfoor3KSrKYkVIMaI(OrdkZIbOz2b61GC3kZIbTYCCAOy2kjpNMJFZw4usTkupQkQo1y7mQQpk1JfBC8eQjqaooEmOQCCI4ELNtZXVctZXHhiWgswlaRusrVtZTBOPAROgBUAf1Qq9OMBZTQsK)syJiZTsZQX4mQvXRNqxHzLQbbIT64xwbpqGzL8nieMvazMTCTQrwPK8UGCkwrza54ezvtKTvxKvpQTcIf)YkgPOTIjDh)IDSYkvdGCjUIvBrU0P2PvO3QX0OXkGOpMBLMvJ5GbKvcUw9cmR6eSK(OrO5fb7pKjet8PUd0FaYqgpZkn6VrhONzvtKTvx0RkARisxeRY3Q4vARCqSsgXqHl5u((yUvAwPKMofRys3XVyheMEy50PaSIbrsIaTvqS4xwHRQyDRqVvBbMaSQjY3kSzL8YqimRGfnHvA0FHI(alNo9WIMW3eIhH5HJpdwZ4uWXVYoHMnNcoLJYPGJN6oqphNrkjWtK)1ZAq4u44YN0t5YHN3CkPMtbhx(KEkxo8CCniAbejhNjDh)IDiHaXwTFJaETmfwh50kmScUw1XG4BKFiX0RjsWsywHDRw67ziX0kSGfROH27djei2HC9AI4arAfgwrdT3hsiqSd561eXbidz8mRWUvJEg3QrA1sFpdjMwbhRWcwSsJqZlc2F0YuyDKtpnqGDaYqgpZkSBf1wnsRw67ziX0kmSstKGLW8BqQ7a950khSA0Z4C8u3b654KqGyRo(LNgiW4nNsSXPGJlFspLlhEoUgeTaIKJtdT3hsiqSd561eXbIKJN6oqphxltH1ro90abgV5uowofCC5t6PC5WZX1GOfqKCCcjNnXHu3wHDRu9XTcdRIxJgIF5V5qUep2yw5GvesoBIZqIPvJ0k4ALkhQTIkRGRvQCO2QrA1cGGiTcowbhRWWkAO9(SrGo2QJF5PbcSZfb754PUd0ZXV5aP8EIemWBoLJZPGJlFspLlhEoUgeTaIKJti5SjoK62kSB14QyfgwfVgne)YFZHCjESXSYbRiKC2eNHetRgPvW1kvouBfvwbxRu5qTvJ0QfabrAfCScowHHvW1kAO9(CZbs59ejy4CrWERGdhp1DGEo(gb6yRo(LNgiW4nNsLItbhx(KEkxo8CCniAbejhVtWs6ZvOH27JozD8RdqsDZXtDhONJZiLe4jY)6zniCk8MtPQZPGJlFspLlhEoEQ7a9C8Kr4s(cZdshJaEncKtoUgeTaIKJFfAO9(ashJaEncKt)vOH27Zfb7TclyXQRqdT3hn6Vq6oCr8X70FfAO9(arAfgw1jyj9HqYztCi1Tvy3kSnQvyblw1XG4BK)gIvy3kQvHJ)5GWXtgHl5lmpiDmc41iqo5nNsSgNcoU8j9uUC454FoiC8lqY7oaI3fHXKjhp1DGEo(fi5DhaX7IWyYK3CkhdofC8u3b654qmXhTmW44YN0t5YHN3CkhvfofC8u3b654KOoqphx(KEkxo88Mt5OJYPGJN6oqphNEIqx)gcOMJlFspLlhEEZPCuQ5uWXtDhONJtlaMaCg)IJlFspLlhEEZPCuSXPGJN6oqphFglIM5vcO7Aq(MJlFspLlhEEZPC0XYPGJN6oqphFhaHEIqxoU8j9uUC45nNYrhNtbhp1DGEoE(AH1GC615CYXLpPNYLdpV5uoQsXPGJN6oqphNoxE023Gq7KXXLpPNYLdpV5uoQQZPGJlFspLlhEoUgeTaIKJ3jyj9PJbX3i)neRCWkLYkmSsJqZlc2FiHaXwD8lpnqGD0ejyjm)gK6oqFoTc7wrnhp1DGEoE8UGCk(pGCCI4nNYrXACk44YN0t5YHNJRbrlGi54DcwsFiKC2ehsDBf2vy1OJBfwWIvDcwsFiKC2ehneaiFBf2TIqYztCgsm54PUd0ZXBeKMWJ2(RKnbV5uo6yWPGJN6oqphhMKKON5rBpcCfahx(KEkxo88Mtj1QWPGJN6oqphFNZP8Ee4kaoU8j9uUC45nNsQhLtbhp1DGEoon6LleR90abghx(KEkxo88Mtj1uZPGJlFspLlhEoEQ7a9CCsiqSvh)YtdeyC8RW0GGSd0ZXXQmXkn63XccixRiHaXwTN15AjaVgcaiiTAdqdwbpqGnKSwawHi7a9SdhxdIwarYXzs3XVyhsiqSv7zDUwcWRHaacsRCWkvScdRwaeePvyyfRZ1sahsDBLdkSIjDh)IDiHaXwTN15AjaVgcaii5nNsQXgNcoU8j9uUC454PUd0ZXjHaXwD8lpnqGXXVctdcYoqphhRYeR0OFhliGCTIeceB1EwNRLa8AiaGG0Qnanyf8ab2qYAbyfISd0ZoCCniAbejhNjDh)IDiHaXwTN15AjaVgcaiiTYbRuXkmSIHMiRWWkwNRLaoK62khuyft6o(f7qcbITApRZ1saEneaqqA1iTsLZ48Mtj1JLtbhx(KEkxo8C8u3b654KqGyRo(LNgiW44xHPbbzhONJJvzIvA0VJfeqUwrcbITApRZ1sa(HetcsR2a0GvWdeydjRfGviYoqp7WX1GOfqKCCM0D8l2HeceB1EwNRLa8djMeKw5GvQyfgwTaiisRWWkwNRLaoK62khuyft6o(f7qcbITApRZ1sa(HetcsEZPK6X5uWXLpPNYLdphp1DGEoojei2QJF5Pbcmo(vyAqq2b654yvMyLg97ybbKRvKqGyR2Z6CTeGFiXKG0Qnanyf8ab2qYAbyfISd0ZoCCniAbejhNjDh)IDiHaXwTN15Aja)qIjbPvoyLkwHHvm0ezfgwX6CTeWHu3w5GcRys3XVyhsiqSv7zDUwcWpKysqA1iTsLZ48Mtj1kfNcoU8j9uUC454PUd0ZXjHaXwD8lpnqGXXVctdcYoqphxvtwBLQbVvxiq8lRAcXkkdihNiRGf)fbZvROHARq)uTvX2kGOLVNQTIi6dhxdIwarYXzDUwc4KdiOVBuJ6CsQBRCqHvQCuDRWWk4ALgHMxeS)eVliNI)dihNiFtiE6zQD6ryEaYqgpZkSB14wHfSyfn0EFI3fKtX)bKJtKVjep9m1o9impqKwbhEZPKAvNtbhx(KEkxo8C8u3b654KqGyRo(LNgiW44xHPbbzhONJJ35AjaRgHScTTIAvScwmNw5mMtRuJGSkERO(mUvmrJ(lZkyrtGGARiKCg)YkeWksiqSvh)6yLvyvMCTcgH8wrcbITApRZ1saEneaqqAv(xRgsmjiTkbIv3GL0t5E44Aq0cisoot6o(f7qcbITApRZ1saEneaqqALcRuXkmSIjDh)IDiHaXwTN15Aja)qIjbPvkSsfRWWQfabrAfgwX6CTeWHu3w5GvuRcV5usnwJtbhx(KEkxo8C8u3b654KqGyRo(LNgiW44xHPbbzhONJJ35AjaRgHScTTAuvScwmNw5mMtRuJGSkERg3kMOr)LzfSOjqqTvesoJFzfcyfjei2QJFDSYkSktUwbJqERiHaXwTN15AjaVgcaiiTk)RvdjMeKwLaXQBWs6PCpCCniAbejhNjDh)IDiHaXwTN15AjaVgcaiiTsHvQyfgwXKUJFXoKqGyR2Z6CTeGFiXKG0kfwPIvyyfdnrwHHvSoxlbCi1Tvoy1OQWBoLupgCk44YN0t5YHNJN6oqphNeceB1XV80abgh)kmnii7a9C8Xm0aPvQg8wPjsWsyw1iyj4YSQjeRK)AfABfLbKJt0iYQ8v3eXVSkywrlDlaRAI8T6rnr8RdhxdIwarYXPH27t8UGCk(pGCCI8nH4PNP2PhH5bI0kmSIgAVpX7cYP4)aYXjY3eINEMANEeMhGmKXZSc7wH14nNsSPcNcoU8j9uUC454PUd0ZXjHaXwD8lpnqGXXVctdcYoqphhR0fuCTsNKKXVSstKGLWC1kAO2kseAALMiblHzfJab6PAROLnciwrza54ezLgnimRGiTk)Rv5CIGz1fAGm(LvnYQ0fuCTsNKKXVS6cbIFzfLbKJt0HJRbrlGi54AeAErW(djei2QJF5PbcSJMiblH53Gu3b6ZPvoOWQrpynRWWk4ALgHMxeS)eVliNI)dihNiFtiE6zQD6ryEaYqgpZkhSAuvSclyXkAO9(eVliNI)dihNiFtiE6zQD6ryEGiTco8Mtj2gLtbhx(KEkxo8C8u3b6540Zu70JW0tdeyC8RW0GGSd0ZXHFMANwP0X0k4bcmRcMvAiaq(EQ2kiMCTQrwjrtiaRac5u(GryfnqGXSIozY1k0B1uymRAI8TIiNBRsRObcmR0ejyjwLUKXmPNIRwHawnrWSsEbSuBvJSs(KEkwH1LLv4djJGJRbrlGi54AeAErW(djei2QJF5PbcSJMiblH53Gu3b6ZPvy3kvoJZBoLyJAofCC5t6PC5WZX1GOfqKCC4AL8cyP2kQScUwjVawQpazjVvJ0kncnViy)XPS8SHKrCaYqgpZk4yfCSc7wnwvScdROH27d9m1orqTxJgOrNlc2BfgwPrO5fb7poLLNnKmIdejhp1DGEoo9m1o9im90abgV5uInSXPGJlFspLlhEoEQ7a9CCbtsz6jsWah)kmnii7a9CCScjNXVSAemdmdahxdIwarYXjKC2ehsDBf2TACRgPvesoJF5zKecqoAe03wHfSyfCTIqYz8lpJKqaYrJG(2khuyf2ScdRiKC2ehsDBf2TACvSco8Mtj2glNcoU8j9uUC454Aq0cisooHKZM4qQBRWUvydBC8u3b654esoJF5LzGza4nNsSnoNcoU8j9uUC454Aq0cisoUgHMxeS)qJE5cXApnqGDaYqgpZkSB1yTcdRyiOjD83ZuYRNwTxWmhiNYr(KEkxoEQ7a9C89uyeAqUBEZPeBkfNcoU8j9uUC454PUd0ZXDklpBizeC8RW0GGSd0ZXv67T8SWfzQ2vRAcXkSsvBmXksqGarhowywH1XTc9wPNs6I4QvWJWTsMmXvRGfnHvYlGLARyKYFfaZQ8VwPVmRyiqlxROLjcghxdIwarYXzKYC67eSKMzLdkSIAEZPeBQoNcoU8j9uUC454Aq0cisooJuMtFNGL0mRCqHvuZXtDhONJVtzgV4znAGK3CkXgwJtbhx(KEkxo8C8u3b654oLLNnKmco(vyAqq2b654QAYARW64wLTvnI0ksqGS6cbIFzLsgP0TIgAVpCCniAbejhNgAVpWKKe9mpA7rGRaoqK8Mtj2gdofCC5t6PC5WZXtDhONJRLPW6iNEAGaJJFfMgeKDGEoUQktH1roTcEGaZksqGarR2kyeYlUiaRI2QgHCAflwFSdD(Tv3CixIv5FTkaON5mERObcmROH2BRcMvdbJf)Yk4MxLaI1w1eIvesoBIZqIPvAKS3HoKVTk1Ae4g)YQgzv8T8SOvBfAB1nhYLyvNoLhoUAv(xRAKvxObsRem1cJzLMiblHzfTSraXk4rWF44Aq0cisoENVZ4xwHHv0q79HEMANiO2Rrd0OZfb7TcdRIxJgIF5V5qUep1JXymgdmRCWk4AfHKZM4mKyA1iTsLJkJBfvwX6CTeWzMS23H2P)Md5s8J1k4yfgwrdT3hzcXcxepniHnfWH1P2Pvy3kQ5nNYXQcNcoU8j9uUC454Aq0cisoENVZ4xwHHv0q79Hece7qUEnrCGiTcdRGRv0q79Hece7qUEnrCaYqgpZkSB1ONXTAKwT0xRWcwSsJqZlc2FiHaXwD8lpnqGDaYqgpZkhSIgAVpKqGyhY1RjIdqgY4zwbhoEQ7a9CCTmfwh50tdey8Mt5yhLtbhp1DGEo(vAeMCC5t6PC5WZBoLJLAofCC5t6PC5WZX1GOfqKCCgPmN(oblPzw5GcRO2kmSIgAVpaigr8lVsKxXdl(75IG9C8u3b654aigr8lVsKxXdl(lV5uowSXPGJlFspLlhEoUgeTaIKJ35u((aGyeXV8krEfpS4Vh5t6PCTcdROH27d9m1orqTxJgOrhisRWWkAO9(aGyeXV8krEfpS4VhisoEQ7a9C8owcWtMZbEZPCSJLtbhx(KEkxo8CCniAbejhNgAVpAIeaKRNmzSa9SZfb7TcdRaqVSrGLC0ejaixpzYyb6zhzedfKKYLJN6oqphNgizt4rB)oacV5uo2X5uWXtDhONJtptTteu7DgANCC5t6PC5WZBoLJvP4uWXtDhONJ7uwE2qYi44YN0t5YHN3CkhRQZPGJlFspLlhEoUgeTaIKJRrO5fb7p7uMXlEwJgipaziJNzLdwrTvyyfJuMtFNGL0mRCqHvuZXtDhONJRjcpneG18Mt5yXACk44PUd0ZX3PmJx8SgnqYXLpPNYLdpV5uo2XGtbhx(KEkxo8CCniAbejhNgAVpRy3E023eIhH5H1P2PvoOWkSXXtDhONJlysktprcg4nNYXvHtbhp1DGEoEJG0eE02FLSj44YN0t5YHN3CkhFuofCC5t6PC5WZX1GOfqKCCAO9(aGyeXV8krEfpS4VNlc2ZXtDhONJdGyeXV8krEfpS4V8Mt54uZPGJlFspLlhEoUgeTaIKJtdT3hnrcaY1tMmwGE2bIKJN6oqphNrg)h)YRb5lENH2jV5uoo24uWXLpPNYLdphxdIwarYXVO(OrVw(gKTC97zoihGmKXZSsHvQWXtDhONJRrVw(gKTC97zoi8Mt54JLtbhx(KEkxo8CCniAbejhNgAVp0Zu7eb1EnAGgDUiyVvyyfCTIgAVp0te6oHy95IG9wHfSyfCTIgAVp0te6oHy9bI0kmS6I6dnqYMWJ2(Dae)f1hGSbcJiPNIvWXk4WXtDhONJtdKSj8OTFhaH3CkhFCofCC5t6PC5WZX1GOfqKCCvPvcJjVwonH41aiDqpfpA73ZCqodPsGaC8u3b654escAVWyYRfEZPCCLItbhp1DGEoUMi80qawZXLpPNYLdpV5uoUQZPGJN6oqphxteEyPlchx(KEkxo88Mt54ynofC8u3b654cMKt0n(L3PS44YN0t5YHN3CkhFm4uWXLpPNYLdphp1DGEoUGjPm9ejyGJFfMgeKDGEo(iatszAfwrcgSIizwrelcby1yw1gbuyvtKVvuOAwbJqERuJGSIiDrSkBRMsYARO2keGMD44Aq0cisoon0EFwXU9OTVjepcZdRtTtRCqHvuZBoLkLkCk44YN0t5YHNJN6oqphNrg)h)YRb5lENH2jh)kmnii7a9CCvnzTv4Qkw3QyBL8iOfHvYldHWSkbIvjab9xxTcbSk2wPKvYkzku6wfmRKpPNY9yffebZQGzvAfBglI2QRSLNfUiwnrmMvixeGvqS4xwrHQzfnuB1sEbKZPARaYfslmRyXGvUKGiFTy1aciw1e5Bv(QBI4xwjtMC44Aq0cisooCTk1D4I4LxgcHzLdkScBwHfSyft6o(f7GW0dlNofGvyyLg9xOOpWYPtpSOj8nH4ryEKpPNY1k4yfgwPrO5fb7poLLNnKmIdqgY4zw5Gvl91kmScUwjVawQTIkRGRvYlGL6dqwYB1iTcUwPrO5fb7poLLNnKmIdqgY4zwrLvcMIgQfFhdIvWXk4yfCSYbfwPuJBfgwbxRuLw15u((WiJEha5iFspLRvyblwPkTca9YgbwYrtKaGC9KjJfONDKrmuqskxRGdV5uQuJYPGJlFspLlhEoUgeTaIKJRkTQZP89HEMANiO2Rrd0OJ8j9uUwHHvAeAErW(Jtz5zdjJ4aKHmEMvoy1sFTcdRGRvYlGLAROYk4AL8cyP(aKL8wnsRGRvAeAErW(Jtz5zdjJ4aKHmEMvuz1sFTcowbhRGJvoOWkLACoEQ7a9C8owcWtMZbEZPuPOMtbhx(KEkxo8CCniAbejhxEbSuBf2TcBJYXtDhONJNaD(IVraG8nV5uQuyJtbhp1DGEooaIre)YRe5v8WI)YXLpPNYLdpV5nhNeiA0aD2Ck4uokNcoEQ7a9C89uyeAqUBoU8j9uUC45nNsQ5uWXtDhONJtJ6Ekx)EMQLlS4x(gHz8CC5t6PC5WZBoLyJtbhp1DGEo(Ekmcni3nhx(KEkxo88Mt5y5uWXtDhONJRjcpneG1CC5t6PC5WZBoLJZPGJN6oqphxteEyPlchx(KEkxo88M38MJ7Iayb65usTkupQkQ(OQohhwc(4xmoUsgRCeoLkjuoMoISYkkieRIbseOTAJawPkUYoHMTQWkGmIHcGCTIHgeRsOgnKTCTstK)syhZ9ys8Ivk1OJiRuv07IaA5ALQOZP89zeMQWQgzLQOZP89ze2r(KEkxvHvWDumHZXCBUvsgirGwUwrTvPUd0B1myn7yU54msrZPKALcRXXjbODmfoUJCKvWdeydjRfGvkPO3P52roYk3qt1wrn2C1kQvH6rn3MBh5iRuvI8xcBezUDKJSsPz1yCg1Q41tORWSs1GaXwD8lRGhiWSs(gecZkGmZwUw1iRusExqofROmGCCISQjY2QlYQh1wbXIFzfJu0wXKUJFXowzLQbqUexXQTix6u70k0B1yA0yfq0hZTJCKvknRgZbdiReCT6fyw1jyj9rJqZlc2FitiM4tDhO)aKHmEMvA0FJoqpZQMiBRUOxv0wrKUiwLVvXR0w5GyLmIHcxYP89XC7ihzLsZkL00Pyft6o(f7GW0dlNofGvmisseOTcIf)YkCvfRBf6TAlWeGvnr(wHnRKxgcHzfSOjSsJ(lu0hy50Phw0e(Mq8impMBZTJCKvJamfnulxROLnciwPrd0zBfTSINDScRuRfYMz1JELgrcg2qtRsDhONzf6NQpM7u3b6zhsGOrd0ztLcL3tHrOb5Un3PUd0ZoKarJgOZMkfktJ6Ekx)EMQLlS4x(gHz8M7u3b6zhsGOrd0ztLcL3tHrOb5Un3PUd0ZoKarJgOZMkfkRjcpneG1M7u3b6zhsGOrd0ztLcL1eHhw6IyUn3oYrwncWu0qTCTsCraQTQJbXQMqSk1ncyvWSkDjJzspLJ5o1DGEMcgPKapr(xpRbHtXCBUtDhONrLcLjHaXwD8lpnqG5ASvWKUJFXoKqGyR2VraVwMcRJCIbC7yq8nYpKy61ejyjmSV03ZqIjwWcn0EFiHaXoKRxtehismOH27djei2HC9AI4aKHmEg2h9m(ix67ziXeoyblAeAErW(JwMcRJC6PbcSdqgY4zyN6rU03ZqIjgAIeSeMFdsDhOpNom6zCZDQ7a9mQuOSwMcRJC6PbcmxJTcAO9(qcbIDixVMioqKM7u3b6zuPq5BoqkVNibdUgBfesoBIdPUXUQpogXRrdXV83CixIhBmhiKC2eNHeZrcxvoutfCv5q9ixaeejCGdg0q79zJaDSvh)YtdeyNlc2BUtDhONrLcL3iqhB1XV80abMRXwbHKZM4qQBSpUkyeVgne)YFZHCjESXCGqYztCgsmhjCv5qnvWvLd1JCbqqKWboyaxAO9(CZbs59ejy4CrWE4yUn3PUd0ZOsHYmsjbEI8VEwdcNIRXwrNGL0NRqdT3hDY64xhGK62CN6oqpJkfkdXeF0YGRFoiksgHl5lmpiDmc41iqoDn2kUcn0EFaPJraVgbYP)k0q795IG9yblxHgAVpA0FH0D4I4J3P)k0q79bIeJoblPpesoBIdPUXo2gflyPJbX3i)neStTkM7u3b6zuPqziM4JwgC9ZbrXfi5DhaX7IWyY0CN6oqpJkfkdXeF0YaZCN6oqpJkfktI6a9M7u3b6zuPqz6jcD9BiGAZDQ7a9mQuOmTaycWz8lZDQ7a9mQuO8mwenZReq31G8T5o1DGEgvkuEhaHEIqxZDQ7a9mQuOC(AH1GC615CAUtDhONrLcLPZLhT9ni0ozM7u3b6zuPq54Db5u8Fa54e5BcXtptTtpctxJTIoblPpDmi(g5VH4GsHHgHMxeS)qcbIT64xEAGa7OjsWsy(ni1DG(CIDQn3PUd0ZOsHYncst4rB)vYMW1yROtWs6dHKZM4qQBSRy0XXcw6eSK(qi5SjoAiaq(g7esoBIZqIP5o1DGEgvkugMKKON5rBpcCfG5o1DGEgvkuENZP8Ee4kaZDQ7a9mQuOmn6LleR90abM52C7iRWQmXkn63XccixRiHaXwTN15AjaVgcaiiTAdqdwbpqGnKSwawHi7a9SJ5o1DGEgvkuMeceB1XV80abMRXwbt6o(f7qcbITApRZ1saEneaqq6GkySaiismyDUwc4qQBhuWKUJFXoKqGyR2Z6CTeGxdbaeKMBhzfwLjwPr)owqa5Afjei2Q9Soxlb41qaabPvBaAWk4bcSHK1cWkezhONDm3PUd0ZOsHYKqGyRo(LNgiWCn2kys3XVyhsiqSv7zDUwcWRHaacshubdgAIWG15AjGdPUDqbt6o(f7qcbITApRZ1saEneaqqosvoJBUn3oYkSktSsJ(DSGaY1ksiqSv7zDUwcWpKysqA1gGgScEGaBizTaScr2b6zhZDQ7a9mQuOmjei2QJF5PbcmxJTcM0D8l2HeceB1EwNRLa8djMeKoOcglacIedwNRLaoK62bfmP74xSdjei2Q9Soxlb4hsmjin3oYkSktSsJ(DSGaY1ksiqSv7zDUwcWpKysqA1gGgScEGaBizTaScr2b6zhZDQ7a9mQuOmjei2QJF5PbcmxJTcM0D8l2HeceB1EwNRLa8djMeKoOcgm0eHbRZ1sahsD7GcM0D8l2HeceB1EwNRLa8djMeKJuLZ4MBZTJSsvtwBLQbVvxiq8lRAcXkkdihNiRGf)fbZvROHARq)uTvX2kGOLVNQTIi6J5o1DGEgvkuMeceB1XV80abMRXwbRZ1saNCab9DJAuNtsD7GcvoQogWvJqZlc2FI3fKtX)bKJtKVjep9m1o9impaziJNH9XXcwOH27t8UGCk(pGCCI8nH4PNP2PhH5bIeoMBZTJScVZ1sawnczfABf1QyfSyoTYzmNwPgbzv8wr9zCRyIg9xMvWIMab1wri5m(LviGvKqGyRo(1XkRWQm5Afmc5TIeceB1EwNRLa8AiaGG0Q8VwnKysqAvceRUblPNY9yUtDhONrLcLjHaXwD8lpnqG5ASvWKUJFXoKqGyR2Z6CTeGxdbaeKkubdM0D8l2HeceB1EwNRLa8djMeKkubJfabrIbRZ1sahsD7a1QyUDKv4DUwcWQriRqBRgvfRGfZPvoJ50k1iiRI3QXTIjA0FzwblAceuBfHKZ4xwHawrcbIT64xhRScRYKRvWiK3ksiqSv7zDUwcWRHaacsRY)A1qIjbPvjqS6gSKEk3J5o1DGEgvkuMeceB1XV80abMRXwbt6o(f7qcbITApRZ1saEneaqqQqfmys3XVyhsiqSv7zDUwcWpKysqQqfmyOjcdwNRLaoK62HrvXCBUDKvJzObsRun4TstKGLWSQrWsWLzvtiwj)1k02kkdihNOrKv5RUjIFzvWSIw6waw1e5B1JAI4xhZDQ7a9mQuOmjei2QJF5PbcmxJTcAO9(eVliNI)dihNiFtiE6zQD6ryEGiXGgAVpX7cYP4)aYXjY3eINEMANEeMhGmKXZWowZCBUDKvyLUGIRv6KKm(LvAIeSeMRwrd1wrIqtR0ejyjmRyeiqpvBfTSraXkkdihNiR0ObHzfePv5FTkNtemRUqdKXVSQrwLUGIRv6KKm(Lvxiq8lROmGCCIoM7u3b6zuPqzsiqSvh)YtdeyUgBfAeAErW(djei2QJF5PbcSJMiblH53Gu3b6ZPdkg9G1WaUAeAErW(t8UGCk(pGCCI8nH4PNP2PhH5bidz8mhgvfSGfAO9(eVliNI)dihNiFtiE6zQD6ryEGiHJ52C7iRGFMANwP0X0k4bcmRcMvAiaq(EQ2kiMCTQrwjrtiaRac5u(GryfnqGXSIozY1k0B1uymRAI8TIiNBRsRObcmR0ejyjwLUKXmPNIRwHawnrWSsEbSuBvJSs(KEkwH1LLv4djJWCN6oqpJkfktptTtpctpnqG5ASvOrO5fb7pKqGyRo(LNgiWoAIeSeMFdsDhOpNyxLZ4M7u3b6zuPqz6zQD6ry6PbcmxJTc4kVawQPcUYlGL6dqwYpsncnViy)XPS8SHKrCaYqgpdoWb7JvfmOH27d9m1orqTxJgOrNlc2JHgHMxeS)4uwE2qYioqKMBZTJScRqYz8lRgbZaZayUtDhONrLcLfmjLPNibdUgBfesoBIdPUX(4JKqYz8lpJKqaYrJG(glybUesoJF5zKecqoAe03oOaByqi5SjoK6g7JRcCm3PUd0ZOsHYesoJF5LzGzaCn2kiKC2ehsDJDSHnZT5o1DGEgvkuEpfgHgK721yRqJqZlc2FOrVCHyTNgiWoaziJNH9XIbdbnPJ)EMsE90Q9cM5a5uoYN0t5AUn3oYkL(ElplCrMQD1QMqScRu1gtSIeeiq0HJfMvyDCRqVv6PKUiUAf8iCRKjtC1kyrtyL8cyP2kgP8xbWSk)Rv6lZkgc0Y1kAzIGzUtDhONrLcLDklpBizeUgBfmszo9DcwsZCqb1M7u3b6zuPq5DkZ4fpRrdKUgBfmszo9DcwsZCqb1MBZTJSsvtwBfwh3QSTQrKwrccKvxiq8lRuYiLUv0q79XCN6oqpJkfk7uwE2qYiCn2kOH27dmjjrpZJ2Ee4kGdeP52C7iRuvzkSoYPvWdeywrcceiA1wbJqEXfbyv0w1iKtRyX6JDOZVT6Md5sSk)Rvba9mNXBfnqGzfn0EBvWSAiyS4xwb38QeqS2QMqSIqYztCgsmTsJK9o0H8TvPwJa34xw1iRIVLNfTARqBRU5qUeR60P8WXvRY)AvJS6cnqALGPwymR0ejyjmROLnciwbpc(J5o1DGEgvkuwltH1ro90abMRXwrNVZ4xyqdT3h6zQDIGAVgnqJoxeShJ41OH4x(BoKlXt9ymgJXaZb4si5SjodjMJuLJkJtfRZ1saNzYAFhAN(BoKlXpw4Gbn0EFKjelCr80Ge2uahwNANyNAZDQ7a9mQuOSwMcRJC6PbcmxJTIoFNXVWGgAVpKqGyhY1RjIdejgWLgAVpKqGyhY1RjIdqgY4zyF0Z4JCPVyblAeAErW(djei2QJF5PbcSdqgY4zoqdT3hsiqSd561eXbidz8m4yUn3PUd0ZOsHYxPryAUn3PUd0ZOsHYaigr8lVsKxXdl(RRXwbJuMtFNGL0mhuqng0q79baXiIF5vI8kEyXFpxeS3CN6oqpJkfk3XsaEYCo4ASv05u((aGyeXV8krEfpS4Vh5t6PCXGgAVp0Zu7eb1EnAGgDGiXGgAVpaigr8lVsKxXdl(7bI0CN6oqpJkfktdKSj8OTFhaX1yRGgAVpAIeaKRNmzSa9SZfb7Xaa9YgbwYrtKaGC9KjJfONDKrmuqskxZDQ7a9mQuOm9m1orqT3zODAUtDhONrLcLDklpBizeM7u3b6zuPqznr4PHaS21yRqJqZlc2F2PmJx8SgnqEaYqgpZbQXGrkZPVtWsAMdkO2CN6oqpJkfkVtzgV4znAG0CN6oqpJkfklysktprcgCn2kOH27Zk2ThT9nH4ryEyDQD6GcSzUtDhONrLcLBeKMWJ2(RKnH5o1DGEgvkugaXiIF5vI8kEyXFDn2kOH27daIre)YRe5v8WI)EUiyV5o1DGEgvkuMrg)h)YRb5lENH2PRXwbn0EF0ejaixpzYyb6zhisZDQ7a9mQuOSg9A5Bq2Y1VN5G4ASvCr9rJET8niB563ZCqoaziJNPqfZDQ7a9mQuOmnqYMWJ2(DaexJTcAO9(qptTteu71ObA05IG9yaxAO9(qprO7eI1Nlc2JfSaxAO9(qprO7eI1hismUO(qdKSj8OTFhaXFr9biBGWis6Pah4yUtDhONrLcLjKe0EHXKxlUgBfQsHXKxlNMq8AaKoONIhT97zoiNHujqaZDQ7a9mQuOSMi80qawBUtDhONrLcL1eHhw6IyUtDhONrLcLfmjNOB8lVtzzUDKvJamjLPvyfjyWkIKzfrSieGvJzvBeqHvnr(wrHQzfmc5TsncYkI0fXQSTAkjRTIARqaA2XCN6oqpJkfklysktprcgCn2kOH27Zk2ThT9nH4ryEyDQD6GcQn3oYkvnzTv4Qkw3QyBL8iOfHvYldHWSkbIvjab9xxTcbSk2wPKvYkzku6wfmRKpPNY9yffebZQGzvAfBglI2QRSLNfUiwnrmMvixeGvqS4xwrHQzfnuB1sEbKZPARaYfslmRyXGvUKGiFTy1aciw1e5Bv(QBI4xwjtMCm3PUd0ZOsHYmY4)4xEniFX7m0oDn2kGBQ7WfXlVmecZbfydlyHjDh)IDqy6HLtNcadn6VqrFGLtNEyrt4BcXJW8iFspLlCWqJqZlc2FCklpBizehGmKXZCyPVyax5fWsnvWvEbSuFaYs(rcxncnViy)XPS8SHKrCaYqgpJkbtrd1IVJbboWbooOqPghd4Qk7CkFFyKrVdGCKpPNYflyrvcGEzJal5OjsaqUEYKXc0ZoYigkijLlCm3PUd0ZOsHYDSeGNmNdUgBfQYoNY3h6zQDIGAVgnqJWqJqZlc2FCklpBizehGmKXZCyPVyax5fWsnvWvEbSuFaYs(rcxncnViy)XPS8SHKrCaYqgpJQL(ch4ahhuOuJBUtDhONrLcLtGoFX3iaq(21yRqEbSuJDSnQ5o1DGEgvkugaXiIF5vI8kEyXF5nV5Ca]] )


end