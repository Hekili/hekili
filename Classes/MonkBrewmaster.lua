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



    spec:RegisterPack( "Brewmaster", 20201123, [[dK0aQaqibQ6rikCjGivBsaJsqCkbPvHi8kfywukDlIIs2Lu9lOWWuihtGSmOONrPyAcuUgrPTruKVjqLXruGZruO1ruuX8ac3dO2hIQdcejwOc6HeffxerrAKefv5KarsRKO6LikIzsuuQBcePStfQFIOOAOefv1tv0ubsxfrr5RefvAVQ8xkgmQomvlgHhtyYqCzsBwkFwOrtKtlA1ar9Ab1SbCBkz3Q63inCO64ef0Yv65OmDjxhsBhrPVdLgpI05PuTEGiMpIO9d6lOd0BI4LEJXCeMJckimTPhKS2eCYkt3SSJR3e3fH9OEZ3T0BoCvSwoR09M4UDaQJCGEtgfDf6nLQcNjZbdmIzjHs0fulmyPfkGxj9fR3kmyPLaJBsGMafi1)iUjIx6ngZryokOGW0MEqYAtWjlM30rlj6EZzAjZCtPebr)J4MiktCtYaYhUkwlNv6c5G0OFyOCYaYhtjRArOlKJPn2c5yocZr3eizf7a9MiAZrbQd0BCqhO30fvs)BYWvFns(Jyy1MH1BQVtaOi3WRUXyEGEt9Dcaf5gEtXMLUPFtMwv(rwhhDZMDtJUgHcOSkDaipaKhcKxPLAkQXYj1iK8nQmiheqEuG0TCsHCsssiNaT164OB2sfXiKYokoKhaYjqBToo6MTurmcPSVQLNpdYbbKhuxwiNeqEuG0TCsH8qHCsssixqPaiuSFxOakRshWqSk2(QwE(miheqoMqojG8OaPB5Kc5bGCHKVrLzARlQK(oaKtoKhux2B6IkP)nXr3Szp)OHyvSxDJT5a9M67eakYn8MInlDt)MeOTwhhDZwQigHu2rXVPlQK(3uOakRshWqSk2RUXb7a9M67eakYn8MInlDt)MsQdusDCrb5GaYdozH8aqE(cQv(rdIB5r1yddYjhYLuhOK6woPqojG8qG8rDmH8bqEiq(OoMqojG84srXH8qH8qH8aqobAR1B0TYM98JgIvX2rOy)B6IkP)nrClC9ns(AD1nw2d0BQVtaOi3WBk2S0n9BkPoqj1XffKdcix2rqEaipFb1k)ObXT8OASHb5Kd5sQdusDlNuiNeqEiq(OoMq(aipeiFuhtiNeqECPO4qEOqEOqEaipeiNaT16iUfU(gjFT6iuSpKh6nDrL0)Mn6wzZE(rdXQyV6glthO3uFNaqrUH30fvs)B6mjY6VYmRdsORrqxh4MInlDt)MikbAR1xhKqxJGUoGbrjqBTocf7d5KKKqoIsG2ADb9rqfvsw1KFydIsG2ADuCipaKx(g1QlPoqj1XffKdci3MGGCsssiVsl1uudsQqoiGCmhDZ3T0B6mjY6VYmRdsORrqxh4QBCWDGEtxuj9VjktnzPwSBQVtaOi3WRUXYGd0B6IkP)nXPvs)BQVtaOi3WRUXY4b6nDrL0)MeaukIPHU2VP(obGICdV6gh0Od0B6IkP)nj0LPB48J3uFNaqrUHxDJdkOd0B6IkP)nbYOuXmGmks0s)6M67eakYn8QBCqyEGEtxuj9VzlxLaGsrUP(obGICdV6ghKnhO30fvs)B6Vqz16agHdaCt9Dcaf5gE1noOGDGEtxuj9VjHhn0MP2ueMDt9Dcaf5gE1noizpqVPlQK(3mFYsdRMprbjo9M67eakYn8QBCqY0b6nDrL0)MffvizOndI6L0n13jauKB4v34GcUd0B6IkP)nXQoo9zgAZqxeDVP(obGICdV6ghKm4a9MUOs6FZMdaOVHUi6Et9Dcaf5gE1noiz8a9MUOs6Ftc6RiOSYqSk2BQVtaOi3WRUXyo6a9M67eakYn8MInlDt)MmTQ8JSoo6Mn7gw5XOUgb6Us4qo5q(iipaKhxkkoKhaYzLhJ62XffKtoyiNPvLFK1Xr3Sz3Wkpg11iq3vc)MUOs6FtC0nB2ZpAiwf7v3ymd6a9M67eakYn8MInlDt)MmTQ8JSoo6Mn7gw5XOUgb6Us4qo5q(iipaKZOauipaKZkpg1TJlkiNCWqotRk)iRJJUzZUHvEmQRrGUReoKtciFux2B6IkP)nXr3Szp)OHyvSxDJXeZd0BQVtaOi3WBk2S0n9BY0QYpY64OB2SByLhJ6ASCsLWHCYH8rqEaipUuuCipaKZkpg1TJlkiNCWqotRk)iRJJUzZUHvEmQRXYjvc)MUOs6FtC0nB2ZpAiwf7v3ymT5a9M67eakYn8MInlDt)MmTQ8JSoo6Mn7gw5XOUglNujCiNCiFeKhaYzuakKhaYzLhJ62XffKtoyiNPvLFK1Xr3Sz3Wkpg11y5KkHd5KaYh1L9MUOs6FtC0nB2ZpAiwf7v3ymd2b6n13jauKB4nfBw6M(nzAv5hzDC0nB2nSYJrDnc0DLWHCWq(iipaKZ0QYpY64OB2SByLhJ6ASCsLWHCWq(iipaKhxkkoKhaYzLhJ62XffKtoKJ5OB6IkP)nXr3Szp)OHyvSxDJXu2d0BQVtaOi3WBk2S0n9BY0QYpY64OB2SByLhJ6AeO7kHd5GH8rqEaiNPvLFK1Xr3Sz3Wkpg11y5KkHd5GH8rqEaiNrbOqEaiNvEmQBhxuqo5qEqJUPlQK(3ehDZM98JgIvXE1ngtz6a9M67eakYn8MInlDt)MckfaHI974OB2SNF0qSk2UqY3OYmT1fvsFhaYbbKpQl7nDrL0)MeaUiSHsQHyvSxDJXm4oqVP(obGICdVPyZs30VziqU(6gTd5dG8qGC91nAVVAuFiNeqUGsbqOy)EynAywotQVQLNpdYdfYdfYbbKhSrqEaiNaT16eaUimfTmcQfbTJqX(qEaixqPaiuSFpSgnmlNj1rXVPlQK(3KaWfHnusneRI9QBmMYGd0BQVtaOi3WBk2S0n9BkPoqj1XffKdcixwiNeqUK6a5hnmCjD1UGI(fKtssc5Ha5sQdKF0WWL0v7ck6xqo5GHCBG8aqUK6aLuhxuqoiGCzhb5HEtxuj9VPskUcyK816QBmMY4b6n13jauKB4nfBw6M(nLuhOK64IcYbbKBJn30fvs)BkPoq(rJcKKM7v3yBgDGEt9Dcaf5gEtXMLUPFtgUcaykFJAXGCYbd5yEtxuj9VzynAywot6QBSnbDGEt9Dcaf5gEtXMLUPFtgUcaykFJAXGCYbd5yEtxuj9VzZvG8vdROw4xDJTbZd0BQVtaOi3WBk2S0n9BsG2ADSQJtFMH2m0fr3ok(nDrL0)MH1OHz5mPRUX2yZb6n13jauKB4nfBw6M(nl)dNFeYda5eOTwNaWfHPOLrqTiODek2hYda55lOw5hniULhvdMYOmkJwmiNCipeixsDGsQB5Kc5KaYh1hjlKpaYzLhJ62bCwzQue2G4wEunbdYdfYda5eOTwxbqzjzvdX6yb0TZkxegYbbKJ5nDrL0)Mcfqzv6agIvXE1n2MGDGEt9Dcaf5gEtXMLUPFZY)W5hH8aqobAR1Xr3SLkIriLDuCipaKhcKtG2ADC0nBPIyeszFvlpFgKdcipOUSqojG8OabYjjjHCbLcGqX(DC0nB2ZpAiwfBFvlpFgKtoKtG2ADC0nBPIyeszFvlpFgKh6nDrL0)Mcfqzv6agIvXE1n2gzpqVPlQK(3erlkP3uFNaqrUHxDJTrMoqVP(obGICdVPyZs30Vz5a6x9fLjLF0aYoIAWMpsxFNaqrG8aqobAR1jaCrykAzeulcAhfhYda5eOTwFrzs5hnGSJOgS5J0rXVPlQK(3SYOUgChW6QBSnb3b6n13jauKB4nfBw6M(njqBTUqY3vrm4oJL0N1rOyFipaKVOV2OBu7cjFxfXG7mwsFwxLHOjoUICtxuj9VjXQEjzOntlx9QBSnYGd0B6IkP)nRmQRb3bSUP(obGICdV6gBJmEGEtxuj9VjbGlctrlt4ue(M67eakYn8QBCWgDGEtxuj9VzynAywot6M67eakYn8QBCWc6a9M67eakYn8MInlDt)Mi0QlOVq)A9srmna3s7RA55ZGCWq(OB6IkP)nf0xOFTEPiMgGBPxDJdgMhO30fvs)B2CfiF1WkQf(n13jauKB4v34GzZb6n13jauKB4nfBw6M(ndEixzm9fAVKuJyrfjbGAOntdWT0ULdY09MUOs6Ftj13YOmM(c9QBCWc2b6n13jauKB4nfBw6M(njqBTEmBLH2mLKAOK2zLlcd5KdgYT5MUOs6FtLuCfWi5R1v34Gj7b6n13jauKB4nfBw6M(nlFJA1LuhOK64IcYbbyipizVPlQK(3SOOcjdTzquVKU6ghmz6a9M67eakYn8MInlDt)MeOTwFrzs5hnGSJOgS5J0rOy)B6IkP)nxuMu(rdi7iQbB(ixDJdwWDGEt9Dcaf5gEtXMLUPFtc0wRlK8DvedUZyj9zDu8B6IkP)nz45)5hnI1F1eofHV6ghmzWb6n13jauKB4nfBw6M(njqBTUqY3vrm4oJL0N1rOyFipaKVOV2OBu7cjFxfXG7mwsFwxLHOjoUICtxuj9VjXQEjzOntlx9QBCWKXd0B6IkP)nfsPHaDz1n13jauKB4v3yzhDGEtxuj9VPqknyDYQ3uFNaqrUHxDJLnOd0BQVtaOi3WBk2S0n9B6IkjRA0xTsLb5KdgYTbYda5ckfaHI97H1OHz5mP(QwE(miNCipkqG8aqEiqU(6gTd5dG8qGC91nAVVAuFiNeqEiqUGsbqOy)EynAywotQVQLNpdYha5kPQaTutLwkKhkKhkKhkKtoyixMKfYda5Ha5bpKxoG(vNHNvlxTRVtaOiqojjjKh8q(I(AJUrTlK8DvedUZyj9zDvgIM44kcKh6nDrL0)Mm88)8JgX6VAcNIWxDJLfZd0BQVtaOi3WBk2S0n9Bg8qE5a6xDcaxeMIwgb1IG213jaueipaKlOuaek2VhwJgMLZK6RA55ZGCYH8OabYda5Ha56RB0oKpaYdbY1x3O9(Qr9HCsa5Ha5ckfaHI97H1OHz5mP(QwE(miFaKhfiqEOqEOqEOqo5GHCzs2B6IkP)nRmQRb3bSU6glRnhO3uFNaqrUH3uSzPB63uFDJ2HCqa52e0nDrL0)M(k8xnfDx9RRUXYgSd0B6IkP)nxuMu(rdi7iQbB(i3uFNaqrUHxD1nXxvqTi86a9gh0b6nDrL0)MnaLjjwVv3uFNaqrUHxDJX8a9MUOs6FtHuAiqxwDt9Dcaf5gE1n2Md0B6IkP)nfsPbRtw9M67eakYn8QRU6MKvxws)BmMJWCuqJSz0nX67NFKDtqQw40Tueihti3fvsFihizfRdLFt8L2sa9MKbKpCvSwoR0fYbPr)Wq5KbKpMsw1IqxihtBSfYXCeMJGYHYjdiNmLuvGwkcKtOn6QqUGAr4fKtOX8zDihKIqO4fdYF6lZsYxRgkaK7IkPpdYPpG9ouUlQK(So(QcQfHxdaJrdqzsI1BfuUlQK(So(QcQfHxdaJHqkneOlRGYDrL0N1XxvqTi8AaymesPbRtwfkhkNmGCYusvbAPiqUswDTd5vAPqEjPqUlk6c5jdYDY6jGtaODOCxuj9zGz4QVgj)rmSAZWkuouUlQK(SbGXahDZM98JgIvXAB2aZ0QYpY64OB2SBA01iuaLvPdeiKkTutrnwoPgHKVrLbIOaPB5KssssG2ADC0nBPIyeszhfpabAR1Xr3SLkIriL9vT88zGiOUSKikq6woPHssskOuaek2VluaLvPdyiwfBFvlpFgiWKerbs3YjnGqY3OYmT1fvsFhG8G6YcL7IkPpBaymekGYQ0bmeRI12SbMaT164OB2sfXiKYokouUlQK(SbGXaXTW13i5RLTzdSK6aLuhxuGi4Knq(cQv(rdIB5r1ydJCj1bkPULtkjczuhZbHmQJjjIlffp0qdqG2A9gDRSzp)OHyvSDek2hk3fvsF2aWy0OBLn75hneRI12SbwsDGsQJlkqi7Oa5lOw5hniULhvJnmYLuhOK6woPKiKrDmheYOoMKiUuu8qdnqieOTwhXTW13i5RvhHI9dfkhk3fvsF2aWyGYutwQLTVBPGDMez9xzM1bj01iORdyB2aJOeOTwFDqcDnc66ageLaT16iuSpjjjIsG2ADb9rqfvsw1KFydIsG2ADu8aLVrT6sQdusDCrbcBcIKKSsl1uudsQGaZrq5UOs6ZgagduMAYsTyq5UOs6ZgagdCAL0hk3fvsF2aWyqaqPiMg6Ahk3fvsF2aWyqOlt3W5hHYDrL0NnamgazuQygqgfjAPFbL7IkPpBaymA5QeaukcuUlQK(SbGXWFHYQ1bmchaak3fvsF2aWyq4rdTzQnfHzq5UOs6ZgagJ8jlnSA(efK4utjPgcaxe2qjfk3fvsF2aWyuuuHKH2miQxsq5UOs6ZgagdSQJtFMH2m0frxOCxuj9zdaJrZba03qxeDHYDrL0Nnamge0xrqzLHyvSq5q5KbKtMXuixq)wgrxfbYXr3Sz3Wkpg11iq3vchYBl1cYhUkwlNv6c5u8kPpRdL7IkPpBaymWr3Szp)OHyvS2MnWmTQ8JSoo6Mn7gw5XOUgb6Us4KpkqCPO4byLhJ62Xff5GzAv5hzDC0nB2nSYJrDnc0DLWHYDrL0Nnamg4OB2SNF0qSkwBZgyMwv(rwhhDZMDdR8yuxJaDxjCYhfGrbObyLhJ62Xff5GzAv5hzDC0nB2nSYJrDnc0DLWjXOUSq5q5KbKtMXuixq)wgrxfbYXr3Sz3Wkpg11y5KkHd5TLAb5dxfRLZkDHCkEL0N1HYDrL0Nnamg4OB2SNF0qSkwBZgyMwv(rwhhDZMDdR8yuxJLtQeo5JcexkkEaw5XOUDCrroyMwv(rwhhDZMDdR8yuxJLtQeouUlQK(SbGXahDZM98JgIvXAB2aZ0QYpY64OB2SByLhJ6ASCsLWjFuagfGgGvEmQBhxuKdMPvLFK1Xr3Sz3Wkpg11y5KkHtIrDzHYHYjdiFwEmQlKdshYPnihZrqo2eaaYdNaaqUDkkKNpKJzxwiNPc6JWGCSzjrrlixsDG8JqoDHCC0nB2Zp2HCiNmJPiqowj9HCC0nB2nSYJrDnc0DLWHC)rGClNujCi3xfYrsMtaOiDOCxuj9zdaJbo6Mn75hneRI12SbMPvLFK1Xr3Sz3Wkpg11iq3vch8OamTQ8JSoo6Mn7gw5XOUglNujCWJcexkkEaw5XOUDCrroMJGYDrL0Nnamg4OB2SNF0qSkwBZgyMwv(rwhhDZMDdR8yuxJaDxjCWJcW0QYpY64OB2SByLhJ6ASCsLWbpkaJcqdWkpg1TJlkYdAeuouoza5dbCryiNmNuiF4QyH8Kb5c0D1VaSd5OmfbYlkKRzjPlKVkoG(jtcYjwfldYjCMIa50hYbugdYlj)HCjhOb5oKtSkwixi5BuHCNSEc4eaQTqoDHCakwixFDJ2H8Ic567eakKtMOriFA5mjOCxuj9zdaJbbGlcBOKAiwfRTzdSGsbqOy)oo6Mn75hneRITlK8nQmtBDrL03baXOUSq5UOs6Zgagdcaxe2qj1qSkwBZg4q0x3O9bHOVUr79vJ6tcbLcGqX(9WA0WSCMuFvlpFwOHcIGnkabAR1jaCrykAzeulcAhHI9diOuaek2VhwJgMLZK6O4q5q5KbKlZtDG8JqozkqsAUq5UOs6ZgagdLuCfWi5RLTzdSK6aLuhxuGqwsiPoq(rddxsxTlOOFrssgIK6a5hnmCjD1UGI(f5GTjGK6aLuhxuGq2rHcL7IkPpBaymKuhi)OrbssZ12SbwsDGsQJlkqyJnq5q5KbKtM3A6ZsYQa2TfYljfYbPiZxMnKJVjDZkbjkdYjtMqo9HCbG6KvTfYhsNqUcWuBHCSzjb56RB0oKZW1hrxgK7pcKlqyqoJULIa5ekafluUlQK(SbGXiSgnmlNjzB2aZWvaat5Bulg5GXek3fvsF2aWy0CfiF1WkQfUTzdmdxbamLVrTyKdgtOCYaYLzCwb5Kjti3liVO4qo(MuihbDZpc5YCPK5qobAR1HYDrL0NnamgH1OHz5mjBZgyc0wRJvDC6Zm0MHUi62rXHYHYjdixMrbuwLoaKpCvSqo(M0nl7qowj9vYQlKNfKxuAyiNLXpBPW)cYrClpQqU)iqEU0NfoFiNyvSqobARb5jdYTsgl)iKhIJaYOScYljfYLuhOK6woPqUGQTwks9li3fc6IKFeYlkKNFPpll7qoTb5iULhviV8W6hQTqU)iqErHCeulCixjvOmgKlK8nQmiNqB0vH8H0HDOCxuj9zdaJHqbuwLoGHyvS2MnWL)HZpgGaT16eaUimfTmcQfbTJqX(bYxqTYpAqClpQgmLrzugTyKhIK6aLu3YjLeJ6JKDaR8yu3oGZktLIWge3YJQjyHgGaT16kakljRAiwhlGUDw5IWGatOCxuj9zdaJHqbuwLoGHyvS2MnWL)HZpgGaT164OB2sfXiKYokEGqiqBToo6MTurmcPSVQLNpdeb1LLerbcjjPGsbqOy)oo6Mn75hneRITVQLNpJCc0wRJJUzlveJqk7RA55Zcfkhk3fvsF2aWyGOfLuOCOCxuj9zdaJrLrDn4oGLTzdC5a6x9fLjLF0aYoIAWMpsxFNaqrcqG2ADcaxeMIwgb1IG2rXdqG2A9fLjLF0aYoIAWMpshfhk3fvsF2aWyqSQxsgAZ0YvTnBGjqBTUqY3vrm4oJL0N1rOy)al6Rn6g1UqY3vrm4oJL0N1vziAIJRiq5UOs6ZgagJkJ6AWDalOCxuj9zdaJbbGlctrlt4uegk3fvsF2aWyewJgMLZKGYDrL0Nnamgc6l0VwVuetdWTuBZgyeA1f0xOFTEPiMgGBP9vT88zGhbL7IkPpBaymAUcKVAyf1chk3fvsF2aWyiP(wgLX0xO2MnWbVYy6l0EjPgXIksca1qBMgGBPDlhKPluUlQK(SbGXqjfxbms(AzB2atG2A9y2kdTzkj1qjTZkxeMCW2aL7IkPpBaymkkQqYqBge1ljBZg4Y3OwDj1bkPoUOab4GKfk3fvsF2aWySOmP8Jgq2rud28rSnBGjqBT(IYKYpAazhrnyZhPJqX(q5UOs6ZgagdgE(F(rJy9xnHtryBZgyc0wRlK8DvedUZyj9zDuCOCxuj9zdaJbXQEjzOntlx12SbMaT16cjFxfXG7mwsFwhHI9dSOV2OBu7cjFxfXG7mwsFwxLHOjoUIaL7IkPpBaymesPHaDzfuUlQK(SbGXqiLgSozvOCxuj9zdaJbdp)p)OrS(RMWPiSTzdSlQKSQrF1kvg5GTjGGsbqOy)EynAywotQVQLNpJ8Oajqi6RB0(Gq0x3O9(Qr9jrickfaHI97H1OHz5mP(QwE(SbkPQaTutLwAOHgk5GLjzdesWxoG(vNHNvlxTRVtaOiKKKb)I(AJUrTlK8DvedUZyj9zDvgIM44ksOq5UOs6ZgagJkJ6AWDalBZg4GVCa9RobGlctrlJGArq767eaksabLcGqX(9WA0WSCMuFvlpFg5rbsGq0x3O9bHOVUr79vJ6tIqeukacf73dRrdZYzs9vT88zdIcKqdnuYbltYcL7IkPpBaym8v4VAk6U6x2MnW6RB0oiSjiOCxuj9zdaJXIYKYpAazhrnyZh5MmCvCJXuMKbxD1Da]] )


end