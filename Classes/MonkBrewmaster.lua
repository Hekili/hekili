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



    spec:RegisterPack( "Brewmaster", 20210627, [[d4K)9aqiscQhjfvxIKGSjqPpbkIgfOItbQ0QOe1RqbZIs4wGcHDPs)Ie1WiHoMuKLrI8muOMgOGRjL02GuLVrsOXbkkNtkkwNuuY8Gu5EOO9rs6GGcPfkL6HKeyIuIixKse(iOOIrckuojOOQvkfEjOimtqHOBsjIYoHu(jOq1qPePLsjIQNcXujbxfuK(QuuQglOOs7fP)sXGvCyrlgrpMutwfxMyZk5Zs1OrPtlSAiv1RPKMTsDBk1Uv1VHA4iCCPOuwoWZr10LCDq2UuIVdjJhu15jPwpjrZhfY(PAAtufOiNSekAkPOsnPi6PKkEBsfBsXMGbksPMqOieP2A2fkYN2cfPnqqzN8saueIu9gNhQcueogcOfkcBve8MLYk3JIfI8QX2kZdBODwb(1GCvkZdBTYuesOyxW8pLKICYsOOPKIk1KIONsQ4TjvSjfBQjkscvSyafbjSvbue24CKNssrocxtrAdeu2jVeGpwYWVvVrdOx8rjv0cFusrLAYB4nubS53fEZYBaJWNM52KpXR3qhH7JLcbIL647(0giO8r(cec3hGSZso(uyFG5)wWwfFqlGuzI9PyZYNd2Nhx(aXJV7dNq0(WLQIVZV(4JLcWTehXNLihYuB1h87dmNOGXGiVuKDWlovbkYrwj0UOkqrRjQcuKuxb(PiCcjbg28pgEbcRcfr(KClhABArrtjQcue5tYTCOTPiAquciskcxQk(o)sabILAZcdmAzl8kYTpW6dC8PcBXuyJDcVrZMGUW9bD(01NRDcVpmIr(qcTwxciqSc5y0SXfIWhy9HeATUeqGyfYXOzJlqSZ45(GoFA62Qpw2NU(CTt49bU(Wig5JgJ3hmQ)QLTWRi3gsGG6ce7mEUpOZhL8XY(01NRDcVpW6JMnbDHBwGuxb(ZTpQ6tt3wPiPUc8triGaXsD8DdjqqrlkAmMQafr(KClhABkIgeLaIKIqcTwxciqSc5y0SXfIGIK6kWpfrlBHxrUnKabfTOObdufOiYNKB5qBtr0GOeqKuewj3f7Lqx(GoFuXw9bwFIxJTJVBoPD2fdJ5(OQpSsUl2RDcVpw2h44JIxL8HbFGJpkEvYhl7thGHi8bU(axFG1hsO16UWGkwQJVBibcQ7bJ6PiPUc8troPnH8g2eytlkATsvGIiFsULdTnfrdIsarsryLCxSxcD5d68Pvf9bwFIxJTJVBoPD2fdJ5(OQpSsUl2RDcVpw2h44JIxL8HbFGJpkEvYhl7thGHi8bU(axFG1h44dj0ADpPnH8g2eyFpyuVpWLIK6kWpfzHbvSuhF3qceu0IIg6rvGIiFsULdTnfrdIsarsrQe0L6EesO16QtEfF)cKuxuKuxb(PiCcjbg28pgEbcRcTOOPIufOiYNKB5qBtrsDf4NIKC2wYx4gqQsmWOXGCtr0GOeqKuKJqcTwxqQsmWOXGCBocj0ADpyuVpmIr(CesO16QX)bsxrlIjERMJqcTwxicFG1NkbDPUSsUl2lHU8bD(W4M8HrmYNkSftHnNq8bD(OKIuKpTfksYzBjFHBaPkXaJgdYnTOObZOkqrKpj3YH2MI8PTqroajpRaiMweox2uKuxb(PihGKNvaetlcNlBArrRzOkqrsDf4NIaXftuInNIiFsULdTnTOO1KIufOiPUc8triWvGFkI8j5wo020IIwtnrvGIK6kWpfHCJXhZccOMIiFsULdTnTOO1KsufOiPUc8trifaxawJVtrKpj3YH2Mwu0AIXufOiPUc8tr2rNT4g0h60TLVOiYNKB5qBtlkAnbdufOiPUc8trwbqi3y8HIiFsULdTnTOO1uRufOiPUc8trYxl8cKBJo3BkI8j5wo020IIwtOhvbksQRa)ueYSBWltbcTvofr(KClhABArrRjvKQafr(KClhABkIgeLaIKIujOl1TcBXuyZjeFu1h0Zhy9rJX7dg1FjGaXsD8DdjqqD1SjOlCZcK6kWFU9bD(Oefj1vGFks8TGTkMpGuzIPffTMGzufOiYNKB5qBtr0GOeqKuKkbDPUSsUl2lHU8bDm9PPw9HrmYNkbDPUSsUl2RgcaKV8bD(Wk5UyV2j8uKuxb(PifgsZAWlZrYILwu0AQzOkqrsDf4NIGssc8Zn4LbdocGIiFsULdTnTOOPKIufOiPUc8trw5ElVbdocGIiFsULdTnTOOPutufOiPUc8triXVCG4LHeiOOiYNKB5qBtlkAkPevbkI8j5wo02uKuxb(PieqGyPo(UHeiOOihHRbbrf4NIat5IpA8VIoeqo(qabILAdVYExagneaWs4ZcGT9PnqqzN8sa(GjQa)8lfrdIsarsr4svX35xciqSuB4v27cWOHaawcFu1hf9bwF6ameHpW6dVYExaxcD5JQm9HlvfFNFjGaXsTHxzVlaJgcayjOffnLymvbkI8j5wo02uKuxb(PieqGyPo(UHeiOOihHRbbrf4NIat5IpA8VIoeqo(qabILAdVYExagneaWs4ZcGT9PnqqzN8sa(GjQa)8lfrdIsarsr4svX35xciqSuB4v27cWOHaawcFu1hf9bwF44n2hy9HxzVlGlHU8rvM(WLQIVZVeqGyP2WRS3fGrdbaSe(yzFu82kTOOPemqvGIiFsULdTnfj1vGFkcbeiwQJVBibckkYr4Aqqub(PiWuU4Jg)ROdbKJpeqGyP2WRS3fGXoHNLWNfaB7tBGGYo5La8btub(5xkIgeLaIKIWLQIVZVeqGyP2WRS3fGXoHNLWhv9rrFG1Noadr4dS(WRS3fWLqx(OktF4svX35xciqSuB4v27cWyNWZsqlkAk1kvbkI8j5wo02uKuxb(PieqGyPo(UHeiOOihHRbbrf4NIat5IpA8VIoeqo(qabILAdVYExag7eEwcFwaSTpTbck7KxcWhmrf4NFPiAquciskcxQk(o)sabILAdVYExag7eEwcFu1hf9bwF44n2hy9HxzVlGlHU8rvM(WLQIVZVeqGyP2WRS3fGXoHNLWhl7JI3wPffnLqpQcue5tYTCOTPiPUc8triGaXsD8DdjqqrrocxdcIkWpfrfK8YhlTTphiq8DFkwXh0civMyFqf)bJYcFiHkFW)wTpXYhGOLV2Q9HnQlfrdIsarsr4v27c4M2yOVkCHRCtOlFuLPpkEvrFG1h44JgJ3hmQ)gFlyRI5divMytXkgYDQTAWWFbIDgp3h05tR(Wig5dj0ADJVfSvX8bKktSPyfd5o1wny4Vqe(axArrtjvKQafr(KClhABksQRa)ueciqSuhF3qceuuKJW1GGOc8trqQS3fGpQq(Gx(OKI(Gk2BFSg7TpQXq(eVpkDB1hUOX)H7dQOyXqLpSsUJV7dg4dbeiwQJVF9Xhykxo(GIvEFiGaXsTHxzVlaJgcayj8j)Jp2j8Se(KaXNtWtYTCUuenikbejfHlvfFNFjGaXsTHxzVlaJgcayj8HPpk6dS(WLQIVZVeqGyP2WRS3fGXoHNLWhM(OOpW6thGHi8bwF4v27c4sOlFu1hLuKwu0ucMrvGIiFsULdTnfj1vGFkcbeiwQJVBibckkYr4Aqqub(Piiv27cWhviFWlFAsrFqf7TpwJ92h1yiFI3Nw9HlA8F4(Gkkwmu5dRK747(Gb(qabIL647xF8bMYLJpOyL3hciqSuB4v27cWOHaawcFY)4JDcplHpjq85e8KClNlfrdIsarsr4svX35xciqSuB4v27cWOHaawcFy6JI(aRpCPQ478lbeiwQn8k7DbySt4zj8HPpk6dS(WXBSpW6dVYExaxcD5JQ(0KI0IIMsndvbkI8j5wo02uKuxb(PieqGyPo(UHeiOOihHRbbrf4NIyjbzt4JL22hnBc6c3NcJkbhUpfR4J8hFWlFqlGuzIBw(KV6In(Upb3hsPkb4tXMVppUyJVFPiAquciskcj0ADJVfSvX8bKktSPyfd5o1wny4Vqe(aRpKqR1n(wWwfZhqQmXMIvmK7uB1GH)ce7mEUpOZhygTOOXyfPkqrKpj3YH2MIK6kWpfHacel1X3nKabff5iCniiQa)uey0wWXXhDsqeF3hnBc6c3cFiHkFiW4TpA2e0fUpCwmO2Q9HuwyG4dAbKktSpASTW9bIWN8p(K7ngLphiBI47(uyFYwWXXhDsqeF3Ndei(UpOfqQmXxkIgeLaIKIOX49bJ6VeqGyPo(UHeiOUA2e0fUzbsDf4p3(OktFA6cZ8bwFGJpAmEFWO(B8TGTkMpGuzInfRyi3P2Qbd)fi2z8CFu1NMu0hgXiFiHwRB8TGTkMpGuzInfRyi3P2Qbd)fIWh4slkAmUjQcue5tYTCOTPiPUc8tri3P2QbdVHeiOOihHRbbrf4NI0ENAR(aJdVpTbckFcUpAiaq(AR2hiUC8PW(irXkaFacXw(GZ6djqqX9Hm5YXh87Zw4CFk289Hn3lFsFibckF0SjOl(KTKXoj3If(Gb(SXO8rEb0v7tH9r(KCl(atiDFqStolfrdIsarsr0y8(Gr9xciqSuhF3qceuxnBc6c3SaPUc8NBFqNpkEBLwu0ySsufOiYNKB5qBtr0GOeqKue44J8cOR2hg8bo(iVa6QVaPlVpw2hngVpyu)1Q0nC7KZEbIDgp3h46dC9bD(adk6dS(qcTwxYDQTIHkJgBtIVhmQ3hy9rJX7dg1FTkDd3o5SxicksQRa)ueYDQTAWWBibckArrJXmMQafr(KClhABksQRa)uebEczBytGnf5iCniiQa)ueymj3X39XsSd4dafrdIsarsryLCxSxcD5d68PvFSSpSsUJVB4eScqUAm0x(Wig5dC8HvYD8DdNGvaYvJH(Yhvz6dJ9bwFyLCxSxcD5d68Pvf9bU0IIgJHbQcue5tYTCOTPiAquciskcRK7I9sOlFqNpmMXuKuxb(PiSsUJVBKDaFaOffng3kvbkI8j5wo02uenikbejfrJX7dg1FjXVCG4LHeiOUaXoJN7d68bg8bwF4yOnz8N7wYJHuTrGpTj2Yv(KClhksQRa)uK1w4SAqUkArrJXOhvbkI8j5wo02uKuxb(PiwLUHBNCwkYr4Aqqub(PiW4RL88OfzR2cFkwXhyulfgPpeGadIkuPW9bMaXh87JElzlIf(0gJ4JS5If(GkkwFKxaD1(WjK)iaUp5F8rF4(WXGso(qkBmkkIgeLaIKIWjK92ujOlf3hvz6Js0IIgJvrQcue5tYTCOTPiAquciskcNq2BtLGUuCFuLPpkrrsDf4NISszhVy4f2MGwu0ymmJQafr(KClhABksQRa)ueRs3WTtolf5iCniiQa)uevqYlFGjq8jlFkmHpeGa7ZbceF3NMDmmUpKqR1LIObrjGiPiKqR1fLKe4NBWldgCeWfIGwu0yCZqvGIiFsULdTnfj1vGFkIw2cVICBibckkYr4Aqqub(PiQazl8kYTpTbckFiabgeLAFqXkV0Ia8jkFkm2Qp8O)Xk05x(Cs7Sl(K)XNaGFU149HeiO8HeAT8j4(yhCE8DFGtEqFiE5tXk(Wk5UyV2j8(OXYAf6q(YNuRXGt8DFkSpXxYZJsTp4LpN0o7IpvAvE4AHp5F8PW(CGSj8rGxlCUpA2e0fUpKYcdeFAJBFPiAqucisksLV147(aRpKqR1LCNARyOYOX2K47bJ69bwFIxJTJVBoPD2fJsntZ0m2CFu1h44dRK7I9ANW7JL9rXRIT6dd(WRS3fWDN8YuH2Q5K2zxmWGpW1hy9HeATUYgIhTigsqIAlGlVsTvFqNpkrlkAWGIufOiYNKB5qBtr0GOeqKuKkFRX39bwFiHwRlbeiwHCmA24cr4dS(ahFiHwRlbeiwHCmA24ce7mEUpOZNMUT6JL9PRp(Wig5JgJ3hmQ)sabIL647gsGG6ce7mEUpQ6dj0ADjGaXkKJrZgxGyNXZ9bUuKuxb(PiAzl8kYTHeiOOffnyOjQcuKuxb(PihPWWtrKpj3YH2Mwu0GbLOkqrKpj3YH2MIObrjGiPiCczVnvc6sX9rvM(OKpW6dj0ADbqC247g0ppIbv8N7bJ6PiPUc8traqC247g0ppIbv8hArrdgymvbkI8j5wo02uenikbejfPYT81faXzJVBq)8iguXFUYNKB54dS(qcTwxYDQTIHkJgBtIVqe(aRpKqR1faXzJVBq)8iguXFUqeuKuxb(Piv0fGHi320IIgmadufOiYNKB5qBtr0GOeqKuesO16QztaqogIKZd8ZVhmQ3hy9ba9Ycd6YvZMaGCmejNh4NFLMnOGGqouKuxb(PiKajlwdEzwbqOffnyOvQcuKuxb(PiK7uBfdvgRH2kfr(KClhABArrdgqpQcuKuxb(PiwLUHBNCwkI8j5wo020IIgmOIufOiYNKB5qBtr0GOeqKuengVpyu)DLYoEXWlSnXfi2z8CFu1hL8bwF4eYEBQe0LI7JQm9rjksQRa)uenByiHa8Iwu0GbygvbksQRa)uKvk74fdVW2eue5tYTCOTPffnyOzOkqrKpj3YH2MIObrjGiPiKqR1ThRYGxMIvmy4V8k1w9rvM(WyksQRa)uebEczBytGnTOO1QIufOiPUc8trkmKM1GxMJKflfr(KClhABArrR1MOkqrKpj3YH2MIObrjGiPiKqR1faXzJVBq)8iguXFUhmQNIK6kWpfbaXzJVBq)8iguXFOffTwvIQafr(KClhABkIgeLaIKIqcTwxnBcaYXqKCEGF(fIGIK6kWpfHte)hF3Ob5lgRH2kTOO1kJPkqrKpj3YH2MIObrjGiPihCD14xlFbYsoM1oTLlqSZ45(W0hfPiPUc8tr04xlFbYsoM1oTfArrRvyGQafr(KClhABkIgeLaIKIqcTwxYDQTIHkJgBtIVhmQ3hy9bo(qcTwxYngF2q86EWOEFyeJ8bo(qcTwxYngF2q86cr4dS(CW1LeizXAWlZkaI5GRlqwaHZMKBXh46dCPiPUc8tribswSg8YScGqlkAT2kvbkI8j5wo02uenikbejfrf2hHZLxl3IvmAaKoi3IbVmRDAlx7e9XaksQRa)uewjbLr4C51cTOO1k6rvGIK6kWpfrZggsiaVOiYNKB5qBtlkATQIufOiPUc8tr0SHbv2IqrKpj3YH2Mwu0AfMrvGIK6kWpfrGNyJpX3nwLofr(KClhABArrR1MHQafr(KClhABksQRa)uebEczBytGnf5iCniiQa)uelb8eY2hySey7dBY9Hn6ScWhljl1sOGpfB((OGL6dkw59rngYh2SfXNS8zljV8rjFWas(LIObrjGiPiKqR1ThRYGxMIvmy4V8k1w9rvM(OeTOOHEksvGIiFsULdTnfrdIsarsrsDfTig5f7q4(OktFySpW6JgJ3hmQ)Av6gUDYzVaXoJN7JQ(iWlAOsmvyl(aRpWXh5fqxTpm4dC8rEb0vFbsxEFSSpWXhngVpyu)1Q0nC7KZEbIDgp3hg8rGx0qLyQWw8bU(axFGRpQY0h0RvksQRa)ueor8F8DJgKVySgAR0IIg61evbkI8j5wo02uenikbejfrf2Nk3YxxYDQTIHkJgBtIVYNKB54dS(OX49bJ6VwLUHBNC2lqSZ45(OQpD9Xhy9bo(iVa6Q9HbFGJpYlGU6lq6Y7JL9bo(OX49bJ6VwLUHBNC2lqSZ45(WGpD9Xh46dC9bU(OktFqVwPiPUc8trQOladrUTPffn0tjQcue5tYTCOTPiAquciskI8cOR2h05dJBIIK6kWpfjb68ftHba5lArrd9ymvbksQRa)ueaeNn(Ub9ZJyqf)HIiFsULdTnTOffHaiASnzwufOO1evbksQRa)uK1w4SAqUkkI8j5wo020IIMsufOiPUc8triXvTLJzTt1Ybv8DtHHpEkI8j5wo020IIgJPkqrsDf4NIOzddjeGxue5tYTCOTPffnyGQafj1vGFkIMnmOYwekI8j5wo020Iw0II0Ia4b(POPKIk1KIWGImMIGkbF8DofPzhg1soAW8ObZPz5JpkWk(e2eyq5Zcd8bM8iReAxWK(aKMnOaihF4yBXNeQW2zjhF0S53f(1BaJmEXh0RPMLpQa83Iak54dmzLB5RlmxysFkSpWKvULVUWCVYNKB5at6dCAcE4E9gEdyEBcmOKJpk5tQRa)(SdEXVEdkcbaVITqrAEZ9PnqqzN8sa(yjd)w9gnV5(0a6fFusfTWhLuuPM8gEJM3CFubS53fEZYB08M7dmcFAMBt(eVEdDeUpwkeiwQJV7tBGGYh5lqiCFaYol54tH9bM)BbBv8bTasLj2NInlFoyFEC5dep(UpCcr7dxQk(o)6Jpwka3sCeFwICitTvFWVpWCIcgdI86n8gnV5(yjGx0qLC8HuwyG4JgBtMLpKspE(1hyuTwikUpp(HrWMa7f02Nuxb(5(G)T6R3i1vGF(LaiASnzwmWu51w4SAqUkVrQRa)8lbq0yBYSyGPYK4Q2YXS2PA5Gk(UPWWhV3i1vGF(LaiASnzwmWuznByiHa8YBK6kWp)saen2MmlgyQSMnmOYweVH3O5n3hlb8IgQKJpslcqTpvyl(uSIpPUWaFcUpzlzStYTC9gPUc8ZzYjKeyyZ)y4fiSkEdVrQRa)CgyQmbeiwQJVBibcklIftUuv8D(Lacel1Mfgy0Yw4vKByHtf2IPWg7eEJMnbDHJUU(CTt4zeJiHwRlbeiwHCmA24cralj0ADjGaXkKJrZgxGyNXZrxt3wTCxFU2j8WLrmsJX7dg1F1Yw4vKBdjqqDbIDgphDkz5U(CTt4HvZMGUWnlqQRa)5w1MUT6nsDf4NZatL1Yw4vKBdjqqzrSyscTwxciqSc5y0SXfIWBK6kWpNbMkFsBc5nSjW2IyXKvYDXEj0f6uXwHnEn2o(U5K2zxmmMRkRK7I9ANWBz4O4vjgGJIxLSChGHiGlCHLeATUlmOIL647gsGG6EWOEVrQRa)CgyQ8cdQyPo(UHeiOSiwmzLCxSxcDHUwve241y747MtANDXWyUQSsUl2RDcVLHJIxLyaokEvYYDagIaUWfw4qcTw3tAtiVHnb23dg1dxVH3i1vGFodmvMtijWWM)XWlqyvSiwmRe0L6EesO16QtEfF)cKuxEJuxb(5mWuziUyIsST4tBHzYzBjFHBaPkXaJgdYTfXI5riHwRlivjgy0yqUnhHeATUhmQNrm6iKqR1vJ)dKUIwet8wnhHeATUqeWwjOl1LvYDXEj0f6yCtmIrvylMcBoHGoLu0BK6kWpNbMkdXftuITfFAlmpajpRaiMweox2EJuxb(5mWuziUyIsS5EJuxb(5mWuzcCf43BK6kWpNbMktUX4Jzbbu7nsDf4NZatLjfaxawJV7nsDf4NZatL3rNT4g0h60TLV8gPUc8ZzGPYRaiKBm(4nsDf4NZatLZxl8cKBJo3BVrQRa)CgyQmz2n4LPaH2k3BK6kWpNbMkhFlyRI5divMytXkgYDQTAWWBrSywjOl1TcBXuyZjevrpy1y8(Gr9xciqSuhF3qceuxnBc6c3SaPUc8NB0PK3i1vGFodmvUWqAwdEzoswSwelMvc6sDzLCxSxcDHoMn1kJyuLGUuxwj3f7vdbaYxOJvYDXETt49gPUc8ZzGPYOKKa)CdEzWGJa8gPUc8ZzGPYRCVL3Gbhb4nsDf4NZatLjXVCG4LHeiO8gEJM7dmLl(OX)k6qa54dbeiwQn8k7Dby0qaalHpla22N2abLDYlb4dMOc8ZVEJuxb(5mWuzciqSuhF3qceuwelMCPQ478lbeiwQn8k7Dby0qaalHQkcBhGHiGLxzVlGlHUuLjxQk(o)sabILAdVYExagneaWs4nAUpWuU4Jg)ROdbKJpeqGyP2WRS3fGrdbaSe(SayBFAdeu2jVeGpyIkWp)6nsDf4NZatLjGaXsD8DdjqqzrSyYLQIVZVeqGyP2WRS3fGrdbaSeQQiSC8gdlVYExaxcDPktUuv8D(Lacel1gEL9UamAiaGLWYkEB1B4nAUpWuU4Jg)ROdbKJpeqGyP2WRS3fGXoHNLWNfaB7tBGGYo5La8btub(5xVrQRa)CgyQmbeiwQJVBibcklIftUuv8D(Lacel1gEL9Uam2j8SeQQiSDagIawEL9UaUe6svMCPQ478lbeiwQn8k7DbySt4zj8gn3hykx8rJ)v0HaYXhciqSuB4v27cWyNWZs4ZcGT9PnqqzN8sa(GjQa)8R3i1vGFodmvMacel1X3nKabLfXIjxQk(o)sabILAdVYExag7eEwcvvewoEJHLxzVlGlHUuLjxQk(o)sabILAdVYExag7eEwclR4TvVH3O5(OcsE5JL22Ndei(UpfR4dAbKktSpOI)GrzHpKqLp4FR2Ny5dq0YxB1(Wg11BK6kWpNbMktabIL647gsGGYIyXKxzVlGBAJH(QWfUYnHUuLPIxvew4OX49bJ6VX3c2Qy(asLj2uSIHCNARgm8xGyNXZrxRmIrKqR1n(wWwfZhqQmXMIvmK7uB1GH)craxVH3O5(GuzVlaFuH8bV8rjf9bvS3(yn2BFuJH8jEFu62QpCrJ)d3hurXIHkFyLChF3hmWhciqSuhF)6JpWuUC8bfR8(qabILAdVYExagneaWs4t(hFSt4zj8jbIpNGNKB5C9gPUc8ZzGPYeqGyPo(UHeiOSiwm5svX35xciqSuB4v27cWOHaawcMkclxQk(o)sabILAdVYExag7eEwcMkcBhGHiGLxzVlGlHUuvjf9gn3hKk7Db4JkKp4LpnPOpOI92hRXE7JAmKpX7tR(Wfn(pCFqfflgQ8HvYD8DFWaFiGaXsD89Rp(at5YXhuSY7dbeiwQn8k7Dby0qaalHp5F8XoHNLWNei(CcEsULZ1BK6kWpNbMktabIL647gsGGYIyXKlvfFNFjGaXsTHxzVlaJgcayjyQiSCPQ478lbeiwQn8k7DbySt4zjyQiSC8gdlVYExaxcDPAtk6n8gn3hljiBcFS02(Oztqx4(uyuj4W9PyfFK)4dE5dAbKktCZYN8vxSX39j4(qkvjaFk2895XfB89R3i1vGFodmvMacel1X3nKabLfXIjj0ADJVfSvX8bKktSPyfd5o1wny4VqeWscTw34BbBvmFaPYeBkwXqUtTvdg(lqSZ45OdM5n8gn3hy0wWXXhDsqeF3hnBc6c3cFiHkFiW4TpA2e0fUpCwmO2Q9HuwyG4dAbKktSpASTW9bIWN8p(K7ngLphiBI47(uyFYwWXXhDsqeF3Ndei(UpOfqQmXxVrQRa)CgyQmbeiwQJVBibcklIftngVpyu)Lacel1X3nKab1vZMGUWnlqQRa)5wvMnDHzWchngVpyu)n(wWwfZhqQmXMIvmK7uB1GH)ce7mEUQnPiJyej0ADJVfSvX8bKktSPyfd5o1wny4VqeW1B4nAUpT3P2QpW4W7tBGGYNG7JgcaKV2Q9bIlhFkSpsuScWhGqSLp4S(qceuCFitUC8b)(Sfo3NInFFyZ9YN0hsGGYhnBc6IpzlzStYTyHpyGpBmkFKxaD1(uyFKpj3IpWes3he7KZ6nsDf4NZatLj3P2QbdVHeiOSiwm1y8(Gr9xciqSuhF3qceuxnBc6c3SaPUc8NB0P4TvVrQRa)CgyQm5o1wny4nKabLfXIjCKxaD1mah5fqx9fiD5TSgJ3hmQ)Av6gUDYzVaXoJNdx4IoyqryjHwRl5o1wXqLrJTjX3dg1dRgJ3hmQ)Av6gUDYzVqeEdVrZ9bgtYD8DFSe7a(a4nsDf4NZatLf4jKTHnb2welMSsUl2lHUqxRwMvYD8DdNGvaYvJH(IrmcoSsUJVB4eScqUAm0xQYKXWYk5UyVe6cDTQiC9gPUc8ZzGPYSsUJVBKDaFaSiwmzLCxSxcDHogZyVH3i1vGFodmvETfoRgKRYIyXuJX7dg1FjXVCG4LHeiOUaXoJNJoyawogAtg)5UL8yivBe4tBITCLpj3YXB4nAUpW4RL88OfzR2cFkwXhyulfgPpeGadIkuPW9bMaXh87JElzlIf(0gJ4JS5If(GkkwFKxaD1(WjK)iaUp5F8rF4(WXGso(qkBmkVrQRa)CgyQSvPB42jN1IyXKti7TPsqxkUQmvYBK6kWpNbMkVszhVy4f2MWIyXKti7TPsqxkUQmvYB4nAUpQGKx(atG4tw(uycFiab2Ndei(Upn7yyCFiHwRR3i1vGFodmv2Q0nC7KZArSyscTwxussGFUbVmyWraxicVH3O5(OcKTWRi3(0giO8HaeyquQ9bfR8slcWNO8PWyR(WJ(hRqNF5ZjTZU4t(hFca(5wJ3hsGGYhsO1YNG7JDW5X39bo5b9H4LpfR4dRK7I9ANW7JglRvOd5lFsTgdoX39PW(eFjppk1(Gx(Cs7Sl(uPv5HRf(K)XNc7ZbYMWhbETW5(Oztqx4(qklmq8PnU91BK6kWpNbMkRLTWRi3gsGGYIyXSY3A8DyjHwRl5o1wXqLrJTjX3dg1dB8ASD8DZjTZUyuQzAMMXMRkCyLCxSx7eElR4vXwzGxzVlG7o5LPcTvZjTZUyGb4clj0ADLnepArmKGe1waxELAROtjVrQRa)CgyQSw2cVICBibcklIfZkFRX3HLeATUeqGyfYXOzJlebSWHeATUeqGyfYXOzJlqSZ45ORPBRwURpmIrAmEFWO(lbeiwQJVBibcQlqSZ45QscTwxciqSc5y0SXfi2z8C46n8gPUc8ZzGPYhPWW7n8gPUc8ZzGPYaioB8Dd6NhXGk(JfXIjNq2BtLGUuCvzQeSKqR1faXzJVBq)8iguXFUhmQ3BK6kWpNbMkxrxagICBBrSyw5w(6cG4SX3nOFEedQ4px5tYTCGLeATUK7uBfdvgn2MeFHiGLeATUaioB8Dd6NhXGk(ZfIWBK6kWpNbMktcKSyn4LzfaXIyXKeATUA2eaKJHi58a)87bJ6Hfa9Ycd6YvZMaGCmejNh4NFLMnOGGqoEJuxb(5mWuzYDQTIHkJ1qB1BK6kWpNbMkBv6gUDYz9gPUc8ZzGPYA2Wqcb4LfXIPgJ3hmQ)UszhVy4f2M4ce7mEUQkblNq2BtLGUuCvzQK3i1vGFodmvELYoEXWlSnH3i1vGFodmvwGNq2g2eyBrSyscTw3ESkdEzkwXGH)YRuBvvMm2BK6kWpNbMkxyinRbVmhjlwVrQRa)CgyQmaIZgF3G(5rmOI)yrSyscTwxaeNn(Ub9ZJyqf)5EWOEVrQRa)CgyQmNi(p(UrdYxmwdTvlIftsO16QztaqogIKZd8ZVqeEJuxb(5mWuzn(1YxGSKJzTtBXIyX8GRRg)A5lqwYXS2PTCbIDgpNPIEJuxb(5mWuzsGKfRbVmRaiwelMKqR1LCNARyOYOX2K47bJ6HfoKqR1LCJXNneVUhmQNrmcoKqR1LCJXNneVUqeWEW1LeizXAWlZkaI5GRlqwaHZMKBbUW1BK6kWpNbMkZkjOmcNlVwSiwmvHfoxETClwXObq6GClg8YS2PTCTt0hd8gPUc8ZzGPYA2Wqcb4L3i1vGFodmvwZgguzlI3i1vGFodmvwGNyJpX3nwLU3O5(yjGNq2(aJLaBFytUpSrNva(yjzPwcf8PyZ3hfSuFqXkVpQXq(WMTi(KLpBj5Lpk5dgqYVEJuxb(5mWuzbEczBytGTfXIjj0AD7XQm4LPyfdg(lVsTvvzQK3i1vGFodmvMte)hF3Ob5lgRH2QfXIzQROfXiVyhcxvMmgwngVpyu)1Q0nC7KZEbIDgpxvbErdvIPcBbw4iVa6QzaoYlGU6lq6YBz4OX49bJ6VwLUHBNC2lqSZ45miWlAOsmvylWfUWvvMOxREJuxb(5mWu5k6cWqKBBlIftv4k3YxxYDQTIHkJgBtIHvJX7dg1FTkDd3o5SxGyNXZvTRpWch5fqxndWrEb0vFbsxEldhngVpyu)1Q0nC7KZEbIDgpNHU(ax4cxvzIET6nsDf4NZatLtGoFXuyaq(YIyXuEb0vJog3K3i1vGFodmvgaXzJVBq)8iguXFOiCcrtrtj0dMrlArP]] )


end