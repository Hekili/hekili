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



    spec:RegisterPack( "Brewmaster", 20201213, [[dOuiSaqievWJGsPljcP0MerJsK4uIKwfuQELsywukUfIku7sQ(fuyykvDmIsltj5zIGPru01OuABiQQVHOIghIk5CIqSorivMNsk3tPSpeLdcLc1cvIEiIQuterLYffHKrcLc5KqPaRKO6LiQcZuesXnHsbTtOOFIOkAOiQsEQctvPYvruP6RIqQAVQ8xkgmkhMQfdvpMWKH4YK2SO(SugncNwYQfH61IuZwr3Ms2nOFJ0WjYXruHSCv9CunDHRdPTtu47iY4HsopLQ1dLIMVsQ2pWNS3UBG4HEyUA)Q9YUs2e6YMGSRwrUUryxsVHKls7n9gq3sVXYxjz58q)Bi52Nuh52Ddof9f6niIqINOddmAvqGI3fulm4Lf60JIcfVNdm4LLaJBGJwZaBa8WVbIh6H5Q9R2l7kztOlBcYUAf5FdhniO)ngLf59nikeefE43ar5IBGTa2Yxjz58qFadBifMgihBbmYnvOw46dyYMGna2Q9R2FJzXd(T7giA2rNXT7Wu2B3nCruu4n4sQ)gchIy4XxP1BOqhFQi3YlomxD7UHcD8PIClVH4Rq)YVbxJOGnExc9RSDtM(gHovEu(eWscyPayrzPMGASCSmcc)BkhWwdWAcKULJfGT(6agoAo3Lq)kxkIrquDujaljGHJMZDj0VYLIyeev)vlVGCaBnat2UTag2bSMaPB5ybyPcyRVoGjO0jcLeSl0PYJYNg8xj1F1YlihWwdWwbyyhWAcKULJfGLeWee(3uUj)Uikk0NagzaMSDBVHlIIcVHe6xz7fSzWFL0fhMjC7UHcD8PIClVH4Rq)YVboAo3Lq)kxkIrquDuPB4IOOWBi0PYJYNg8xjDXHPmVD3qHo(urUL3q8vOF53Gq9zq0LebGTgGroTfWscyfuqTkyZG4wEtnjWbmYamc1Nbr3YXcWWoGLcGTVVcWwayPay77RamSdyTNIkbyPcyPcyjbmC0CUNPFuz7fSzWFLuhHscEdxeffEde3ssHgc)TU4W02B3nuOJpvKB5neFf6x(niuFgeDjrayRby2UhWscyfuqTkyZG4wEtnjWbmYamc1Nbr3YXcWWoGLcGTVVcWwayPay77RamSdyTNIkbyPcyPcyjbSuamC0CUJ4wsk0q4VvhHsccyPEdxeffEJm9JkBVGnd(RKU4WK8VD3qHo(urUL3WfrrH3W5eYWHk38o2K(gb995neFf6x(nquC0CU)o2K(gb99PbrXrZ5ocLeeWwFDadrXrZ5UGcrqfrjd1uW0gefhnN7Osawsal8VPrNq9zq0LebGTgGLGSa26RdyrzPMGAqkfWwdWwT)gq3sVHZjKHdvU5DSj9nc67ZlomjN3UB4IOOWBGYvtfQf)gk0XNkYT8IdtY1T7gUikk8gs0OOWBOqhFQi3YlomtKB3nCruu4nWNukIjJ(2VHcD8PIClV4Wu293UB4IOOWBGRpx)0fSDdf64tf5wEXHPSYE7UHlIIcVXSAeb3KyuKMLcJBOqhFQi3YlomLD1T7gUikk8g56v8jLICdf64tf5wEXHPSjC7UHlIIcVHdfkpEFAe(CEdf64tf5wEXHPSY82DdxeffEdCVzOzt8Lin)gk0XNkYT8IdtzT92Ddf64tf5wEdXxH(LFJC1icZRwEb5agza2kBVHlIIcVrbLbnTAGfk20PxCykl5F7UHcD8PIClVH4Rq)YVr4FtJoH6ZGOljcaBTnatwBbS1xhWc)BA0juFgeDb6)kmaS1amc1Nbr3YX6gUikk8gbfvqyOzdI6bXfhMYsoVD3WfrrH3GK6sui3qZg6JO)nuOJpvKB5fhMYsUUD3WfrrH3i7ZPcn0hr)BOqhFQi3YlomLnrUD3WfrrH3aNcveuEyWFL0nuOJpvKB5fhMR2F7UHcD8PIClVH4Rq)YVbxJOGnExc9RSDdp8wtFJa9FcjaJmaBpGLeWApfvcWscy8WBn97sIaWiBdW4AefSX7sOFLTB4H3A6BeO)tiDdxeffEdj0VY2lyZG)kPlomxj7T7gk0XNkYT8gIVc9l)gCnIc24Dj0VY2n8WBn9nc0)jKamYaS9awsaJtNualjGXdV10VljcaJSnaJRruWgVlH(v2UHhERPVrG(pHeGHDaBF32B4IOOWBiH(v2EbBg8xjDXH5Qv3UBOqhFQi3YBi(k0V8BW1ikyJ3Lq)kB3WdV103y5yribyKby7bSKaw7POsawsaJhERPFxseagzBagxJOGnExc9RSDdp8wtFJLJfH0nCruu4nKq)kBVGnd(RKU4WCvc3UBOqhFQi3YBi(k0V8BW1ikyJ3Lq)kB3WdV103y5yribyKby7bSKagNoPawsaJhERPFxseagzBagxJOGnExc9RSDdp8wtFJLJfHeGHDaBF32B4IOOWBiH(v2EbBg8xjDXH5kzE7UHcD8PIClVH4Rq)YVbxJOGnExc9RSDdp8wtFJa9FcjaBdW2dyjbmUgrbB8Ue6xz7gE4TM(glhlcjaBdW2dyjbS2trLaSKagp8wt)UKiamYaSv7VHlIIcVHe6xz7fSzWFL0fhMRS92Ddf64tf5wEdXxH(LFdUgrbB8Ue6xz7gE4TM(gb6)esa2gGThWscyCnIc24Dj0VY2n8WBn9nwowesa2gGThWscyC6KcyjbmE4TM(DjrayKbyYU)gUikk8gsOFLTxWMb)vsxCyUI8VD3qHo(urUL3q8vOF53qqPtekjyxc9RS9c2m4VsQli8VPCt(DruuOpbS1aS9DBVHlIIcVb(0fPnuSm4Vs6IdZvKZB3nuOJpvKB5neFf6x(nsbWuO(n7a2calfatH63S3FTPqad7aMGsNiusWEATz4woNO)QLxqoGLkGLkGTgGjZ9awsadhnN74txKMIggb1cN2rOKGawsatqPtekjypT2mClNt0rLUHlIIcVb(0fPnuSm4Vs6IdZvKRB3nuOJpvKB5neFf6x(niuFgeDjrayRby2cyyhWiuFwWMHlrOV2fuuyayRVoGLcGrO(SGndxIqFTlOOWaWiBdWsaWscyeQpdIUKiaS1amB3dyPEdxeffEdfljDAi836IdZvjYT7gk0XNkYT8gIVc9l)geQpdIUKiaS1aSes4gUikk8geQplyZOZcR6V4WmH93UBOqhFQi3YBi(k0V8BWL050e(30GdyKTbyRUHlIIcVrATz4woN4IdZeK92Ddf64tf5wEdXxH(LFdUKoNMW)MgCaJSnaB1nCruu4nYUolOA4b1s6IdZewD7UHcD8PIClVH4Rq)YVboAo3jPUefYn0SH(i63rLUHlIIcVrATz4woN4IdZes42Ddf64tf5wEdXxH(LFJWHPlydWscy4O5ChF6I0u0WiOw40ocLeeWscyfuqTkyZG4wEtnRsKejrS4agzawkagH6ZGOB5ybyyhW233BlGTaW4H3A63NopmrjsBqClVPgzcyPcyjbmC0CURtuEjd1G)oPP(DE4I0a2Aa2QB4IOOWBi0PYJYNg8xjDXHzcY82Ddf64tf5wEdXxH(LFJWHPlydWscy4O5Cxc9RCPigbr1rLaSKawkagoAo3Lq)kxkIrqu9xT8cYbS1amz72cyyhWAceaB91bmbLorOKGDj0VY2lyZG)kP(RwEb5agzagoAo3Lq)kxkIrqu9xT8cYbSuVHlIIcVHqNkpkFAWFL0fhMjy7T7gUikk8giAqX6gk0XNkYT8IdZei)B3nuOJpvKB5neFf6x(n4s6CAc)BAWbmY2aSvawsadhnN7pkNOGntIDe1qQGiDekj4nCruu4nEuorbBMe7iQHubrU4WmbY5T7gk0XNkYT8gIVc9l)gHpvy0FuorbBMe7iQHubr6k0XNkcGLeWWrZ5o(0fPPOHrqTWPDujaljGHJMZ9hLtuWMjXoIAivqKoQ0nCruu4nIQPVrYNwxCyMa562Ddf64tf5wEdXxH(LFdC0CUli8)veJKZ5ffY7iusqaljG9Oqnt)M2fe()kIrY58Ic5DLCeAjjPi3WfrrH3a)vpim0SjxVEXHzcjYT7gUikk8g4txKMIgM0Li9nuOJpvKB5fhMYC)T7gUikk8gP1MHB5CIBOqhFQi3YlomLPS3UB4IOOWBKDDwq1WdQL0nuOJpvKB5fhMYC1T7gk0XNkYT8gIVc9l)g4O5CVv5WqZMGqnuS68WfPbmY2aSeUHlIIcVHILKone(BDXHPmt42DdxeffEJGIkim0Sbr9G4gk0XNkYT8IdtzkZB3nuOJpvKB5neFf6x(nWrZ5(JYjkyZKyhrnKkishHscEdxeffEJhLtuWMjXoIAivqKlomLPT3UBOqhFQi3YBi(k0V8BGJMZDbH)VIyKCoVOqEhv6gUikk8gCPcclyZiEhQM0Li9fhMYK8VD3qHo(urUL3q8vOF53aHgDbfkuy8EOiM80T0(RwEb5a2gGT)gUikk8gckuOW49qrm5PBPxCyktY5T7gk0XNkYT8gIVc9l)g4O5ChF6I0u0WiOw40ocLeeWscyPay4O5ChFsPituE0rOKGa26RdyPay4O5ChFsPituE0rLaSKagcn64V6bHHMn56vdcn6VMFLt44tfWsfWs9gUikk8g4V6bHHMn561lomLj562Ddf64tf5wEdXxH(LFdYbat5Cfk0EqOgXJkk8PAOztE6wA3Ytm9VHlIIcVbH6FyuoxHc9IdtzMi3UB4IOOWBiikdo6ZJBOqhFQi3YlomTD)T7gUikk8gcIYqYLHEdf64tf5wEXHPTYE7UHcD8PIClVH4Rq)YVboAo3Bvom0SjiudfRopCrAaJSnaB1nCruu4nuSK0PHWFRlomTD1T7gk0XNkYT8gIVc9l)gUikzOgfQwLYbmY2aSeaSKaMGsNiusWEATz4woNO)QLxqoGrgGPyPc0qnrzPawsalfatH63SdylaSuamfQFZE)1McbmSdyPayckDIqjb7P1MHB5CI(RwEb5a2catXsfOHAIYsbSubSubSubmY2amY32B4IOOWBWLkiSGnJ4DOAsxI0xCyABc3UBOqhFQi3YBi(k0V8BqoayHpvy0XNUinfnmcQfoTRqhFQiawsatqPtekjypT2mClNt0F1YlihWidWAcealjGLcGPq9B2bSfawkaMc1VzV)AtHag2bSuambLorOKG90AZWTCor)vlVGCaBbG1eiawQawQawQagzBag5B7nCruu4nIQPVrYNwxCyARmVD3qHo(urUL3q8vOF53qH63SdyRbyji7nCruu4n8x4q1e0)vyCXHPT2E7UHlIIcVXJYjkyZKyhrnKkiYnuOJpvKB5fxCdPxfulCpUDhMYE7UHlIIcVrEQCcX754gk0XNkYT8IdZv3UB4IOOWBGtJyQiM80TRiKkyZeuSk4nuOJpvKB5fhMjC7UHlIIcVHGOm4OppUHcD8PIClV4WuM3UB4IOOWBiikdjxg6nuOJpvKB5fxCXnKH(8IcpmxTF1EzLDLmVbj)HfSXVb2alj6hkcGTcWCruuiGnlEW7a53q6P5AQ3aBbSLVsYY5H(ag2qkmnqo2cyKBQqTW1hWKnbBaSv7xThihihBbSefwQanueadxZ0xbmb1c3dadxBfK3bmSXcHkfCadsHKJj83kJobmxeffYbmkCAVdK7IOOqEx6vb1c3JfByKNkNq8EoaYDruuiVl9QGAH7XInmWPrmvetE62vesfSzckwfei3frrH8U0RcQfUhl2WqqugC0Nha5UikkK3LEvqTW9yXggcIYqYLHcKdKJTawIclvGgkcGPYqF7awuwkGfekG5IG(awXbmxgEnD8P2bYDruuiFJlP(BiCiIHhFLwbYbYDruuiFXggsOFLTxWMb)vs2u5nUgrbB8Ue6xz7Mm9ncDQ8O8zYuIYsnb1y5yzee(3u(Anbs3YXA91XrZ5Ue6x5srmcIQJkLehnN7sOFLlfXiiQ(RwEb5RjB3wS3eiDlhRuxFDbLorOKGDHovEu(0G)kP(RwEb5RTc7nbs3YXkPGW)MYn53frrH(Kmz72cK7IOOq(Inme6u5r5td(RKSPYB4O5Cxc9RCPigbr1rLaYDruuiFXggiULKcne(BztL3iuFgeDjrSg502KfuqTkyZG4wEtnjWjJq9zq0TCSWEk77RwKY((kS3EkQuQPMehnN7z6hv2EbBg8xj1rOKGa5UikkKVydJm9JkBVGnd(RKSPYBeQpdIUKiwZ29jlOGAvWMbXT8MAsGtgH6ZGOB5yH9u23xTiL99vyV9uuPutnzk4O5ChXTKuOHWFRocLemvGCGCxeffYxSHbkxnvOw2aDlDZ5eYWHk38o2K(gb99PnvEdrXrZ5(7yt6Be03NgefhnN7iusW1xhrXrZ5UGcrqfrjd1uW0gefhnN7Osjd)BA0juFgeDjrSwcYU(6rzPMGAqkDTv7bYDruuiFXggOC1uHAXbYDruuiFXggs0OOqGCxeffYxSHb(Ksrmz03oqUlIIc5l2WaxFU(Plydi3frrH8fBymRgrWnjgfPzPWai3frrH8fByKRxXNukcqUlIIc5l2WWHcLhVpncFobYDruuiFXgg4EZqZM4lrAoqUlIIc5l2WOGYGMwnWcfB6utqOg8PlsBOyztL3YvJimVA5fKt2kBbYDruuiFXggbfvqyOzdI6bHnvEl8VPrNq9zq0LeXABYA76Rh(30OtO(mi6c0)vySgH6ZGOB5ybK7IOOq(InmiPUefYn0SH(i6dK7IOOq(InmY(CQqd9r0hi3frrH8fByGtHkckpm4VscihihBbmYDUcyckmxn0xramj0VY2n8WBn9nc0)jKaS8tTaSLVsYY5H(agvkkkK3bYDruuiFXggsOFLTxWMb)vs2u5nUgrbB8Ue6xz7gE4TM(gb6)esKTpz7POsj5H3A63LebzBCnIc24Dj0VY2n8WBn9nc0)jKaYDruuiFXggsOFLTxWMb)vs2u5nUgrbB8Ue6xz7gE4TM(gb6)esKTpjNoPj5H3A63LebzBCnIc24Dj0VY2n8WBn9nc0)jKW((UTa5a5ylGrUZvatqH5QH(kcGjH(v2UHhERPVXYXIqcWYp1cWw(kjlNh6dyuPOOqEhi3frrH8fByiH(v2EbBg8xjztL34AefSX7sOFLTB4H3A6BSCSiKiBFY2trLsYdV10VljcY24AefSX7sOFLTB4H3A6BSCSiKaYDruuiFXggsOFLTxWMb)vs2u5nUgrbB8Ue6xz7gE4TM(glhlcjY2NKtN0K8WBn97sIGSnUgrbB8Ue6xz7gE4TM(glhlcjSVVBlqoqo2cyJWBn9bSeTagndyR2dyKQ5eWsxZjGzNIcyfeWw1TfW4QGcr4agPkiOObGrO(SGnaJ(aMe6xz7fS1bmaJCNRiagjcfcysOFLTB4H3A6BeO)tibyoebWSCSiKam)vadP4o(ur6a5UikkKVyddj0VY2lyZG)kjBQ8gxJOGnExc9RSDdp8wtFJa9FcPT9j5AefSX7sOFLTB4H3A6BSCSiK22NS9uuPK8WBn97sIGSv7bYDruuiFXggsOFLTxWMb)vs2u5nUgrbB8Ue6xz7gE4TM(gb6)esB7tY1ikyJ3Lq)kB3WdV103y5yriTTpjNoPj5H3A63LebzYUhihihBbSLtxKgWipXcWw(kjaR4aMa9Ffgt7agkxraSGcyAfe6dyVknvyXjam8xjXbmCNRiagfcytLZbSGWHagHpZaMdy4VscWee(3uaZLHxthFQ2ay0hWMusaMc1VzhWckGPqhFQag5H2aSHLZjaYDruuiFXgg4txK2qXYG)kjBQ8MGsNiusWUe6xz7fSzWFLuxq4Ft5M87IOOqFU2(UTa5UikkKVydd8PlsBOyzWFLKnvElffQFZ(IuuO(n79xBke7ckDIqjb7P1MHB5CI(RwEb5PM6AYCFsC0CUJpDrAkAyeulCAhHscMuqPtekjypT2mClNt0rLaYbYXwadBK6Zc2aSe1SWQEGCxeffYxSHHILKone(BztL3iuFgeDjrSMTyNq9zbBgUeH(AxqrHX6RNcH6Zc2mCjc91UGIcdY2sijH6ZGOljI1SDFQa5UikkKVyddc1NfSz0zHv92u5nc1NbrxseRLqca5a5ylGrEMZkKxYqN2TbWccfWWgtELObWK(I(vuytLdyKhdaJcbmXuDzO2aylPdatNC1gaJufeaMc1VzhW4skerFoG5qeatGWbmo9dfbWW1jLeqUlIIc5l2WiT2mClNtytL34s6CAc)BAWjBBfqUlIIc5l2Wi76SGQHhuljBQ8gxsNtt4FtdozBRaYbYXwaJ825bGrEmampaSGkbysFrbme0VGnalrpL8eWWrZ5oqUlIIc5l2WiT2mClNtytL3WrZ5oj1LOqUHMn0hr)oQeqoqo2cyK36u5r5taB5RKamPVOFf2bmsekuLH(awfawqPPbmE1GvUeomame3YBkG5qeaREkKNUGag(RKamC0CgWkoGzvCEbBawkosIr5bGfekGrO(mi6wowaMGQ5CjkfgaMle0hPGnalOawbdfYRWoGrZagIB5nfWcpTct1gaZHiawqbmeuljatXsOCoGji8VPCadxZ0xbSL0LDGCxeffYxSHHqNkpkFAWFLKnvElCy6c2sIJMZD8PlstrdJGAHt7iusWKfuqTkyZG4wEtnRsKejrS4KLcH6ZGOB5yH99992UGhERPFF68WeLiTbXT8MAKzQjXrZ5Uor5Lmud(7KM635HlsV2kGCxeffYxSHHqNkpkFAWFLKnvElCy6c2sIJMZDj0VYLIyeevhvkzk4O5Cxc9RCPigbr1F1YliFnz72I9Maz91fu6eHsc2Lq)kBVGnd(RK6VA5fKtgoAo3Lq)kxkIrqu9xT8cYtfihi3frrH8fByGObflGCGCxeffYxSHXJYjkyZKyhrnKkiInvEJlPZPj8VPbNSTvjXrZ5(JYjkyZKyhrnKkishHsccK7IOOq(InmIQPVrYNw2u5TWNkm6pkNOGntIDe1qQGiDf64tfjjoAo3XNUinfnmcQfoTJkLehnN7pkNOGntIDe1qQGiDujGCxeffYxSHb(REqyOztUE1MkVHJMZDbH)VIyKCoVOqEhHscM8rHAM(nTli8)veJKZ5ffY7k5i0sssraYDruuiFXgg4txKMIgM0LinqUlIIc5l2WiT2mClNtaK7IOOq(InmYUolOA4b1sci3frrH8fByOyjPtdH)w2u5nC0CU3QCyOztqOgkwDE4I0KTLaqUlIIc5l2WiOOccdnBqupiaYDruuiFXggpkNOGntIDe1qQGi2u5nC0CU)OCIc2mj2rudPcI0rOKGa5UikkKVyddUubHfSzeVdvt6sK2MkVHJMZDbH)VIyKCoVOqEhvci3frrH8fByiOqHcJ3dfXKNULAtL3qOrxqHcfgVhkIjpDlT)QLxq(2EGCxeffYxSHb(REqyOztUE1MkVHJMZD8PlstrdJGAHt7iusWKPGJMZD8jLImr5rhHscU(6PGJMZD8jLImr5rhvkjcn64V6bHHMn56vdcn6VMFLt44tn1ubYDruuiFXggeQ)Hr5CfkuBQ8g5GY5kuO9GqnIhvu4t1qZM80T0ULNy6dK7IOOq(InmeeLbh95bqUlIIc5l2WqqugsUmuGCSfWsuyjPtadBK)wagHZbmIQrOpGrUrELO2bybHdbSDKxagjcfcy2POagHldfW8aWMQZdaBfGrFCEhi3frrH8fByOyjPtdH)w2u5nC0CU3QCyOztqOgkwDE4I0KTTci3frrH8fByWLkiSGnJ4DOAsxI02u5nxeLmuJcvRs5KTLqsbLorOKG90AZWTCor)vlVGCYuSubAOMOS0KPOq9B2xKIc1VzV)AtHypfbLorOKG90AZWTCor)vlVG8fkwQanutuwAQPMkzBKVTa5UikkKVydJOA6BK8PLnvEJCi8PcJo(0fPPOHrqTWPDf64tfjPGsNiusWEATz4woNO)QLxqoznbsYuuO(n7lsrH63S3FTPqSNIGsNiusWEATz4woNO)QLxq(IMaj1utLSnY3wGCxeffYxSHH)chQMG(VcdBQ8Mc1VzFTeKfi3frrH8fBy8OCIc2mj2rudPcICdUKkomxr(KRlU4oa]] )


end