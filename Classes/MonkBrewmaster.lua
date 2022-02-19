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


    -- Tier 28
    spec:RegisterGear( "tier28", 188916, 188914, 188912, 188911, 188910 )
    spec:RegisterSetBonuses( "tier28_2pc", 364415, "tier28_4pc", 366792 )
    -- 2-Set - Breath of the Cosmos - Targets ignited by Breath of Fire deal an additional 4% less damage to you.
    -- 4-Set - Keg of the Heavens - Keg Smash deals an additional 50% damage, heals you for 66% of damage dealt, and grants 66% of damage dealt as maximum health for 10 sec.
    spec:RegisterAuras( {
        keg_of_the_heavens = {
            id = 366794,
            duration = 10,
            max_stack = 1,
        },
    } )

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

                if set_bonus.tier28_4pc > 0 then
                    applyBuff( "keg_of_the_heavens" )
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
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
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



    spec:RegisterPack( "Brewmaster", 20210801, [[d4uHdbqiKuXJOs4skeInbf(evGAuaLofqXQui6virZIkPBHKQAxQ4xKidJe1XuiTmsINHKY0uO01uOABij5BqjLXrfKZPqH1PqOMhsI7rc7Jk0bHscleO6Hub1evOOUiva9rfkIrcLeDsKujRKk1lHsQMPcfPBIKk1orc)KkqgQcblvHqQNcvtfk1vHssFLkaJvHqYEr1FPQbl5WIwms9ysnzv6YeBwP(SsgncNwy1ij1RPIMTIUTc2TQ(nKHJOJJKQSCqphLPl11bSDssFhiJhk68KuRNkrZhkX(PmFuo2C8B2cNcvuwLrv2HuE0ZOu1Oo0OoehVvtkCCYu7mxch)ZbHJdouanKSwGCCYu9eLxo2CCgcaQfoor3KSrSskTIMaG(OrdkXIbGz2b61WC3kXIbTsCCAGy2uxpNMJFZw4uOIYQmQYoKYJEgLQg1HgDSC8eOjqqooEm4WCCI4ELNtZXVctZXbhkGgswlqROUrVtZTBGPARO2OUALkkRYOMBZTdtK)syJyZn13QX4mQvXRNaxHz1iaaJT64xwbouazL8nmeMvqzMTCTQrwrD9QICkwrra4YezvtKTvxKvpQTcGf)YkgPOTIjDh)IDSYQraIunUIvBrU0P2PvO3QXKOXkbOpMBQVvJ5GbLvcVw9ciR6eUK(OrO5fb6pKjat8PUd0FGYqgpZkn6VrhONzvtKTvx07GBRisvfRY3Q4P(RCqSsOEaHQ5u((yUP(wrDNofRys3XVyheMEq50PaTIbqsIGTvaS4xwH7WyDRqVvBbKaTQjY3kQzL8YqimRafnHvA0FbI(akNo9GIMW3eIhH5HJpdwZ4yZXVYobMnhBofJYXMJN6oqphNrkj0tK)1ZAy4u44YN0t5YbN3CkuHJnhx(KEkxo4CCnmAbgjhNjDh)IDibGXwTFJGETmfwh50kmScSw1XG4BKFiX0Rjs4sywrfRw67ziX0kSGfROb27djam2HC9AI4aqAfgwrdS3hsaySd561eXbkdz8mROIvJEg3QrA1sFpdjMwbgRWcwSsJqZlc0F0YuyDKtpnuaDGYqgpZkQyLkwnsRw67ziX0kmSstKWLW8ByQ7a950khTA0Z4C8u3b654KaWyRo(LNgkG4nNcQXXMJlFspLlhCoUggTaJKJtdS3hsaySd561eXbGKJN6oqphxltH1ro90qbeV5umwo2CC5t6PC5GZX1WOfyKCCcjNnXHu3wrfRWAJBfgwfVgne)YFZHCjEQXSYrRiKC2eNHetRgPvG1kLpQyfLwbwRu(OIvJ0QfebqAfyScmwHHv0a79zJGDSvh)YtdfqNlc0ZXtDhONJFZbs59ejCG3CkgNJnhx(KEkxo4CCnmAbgjhNqYztCi1TvuXQXv2kmSkEnAi(L)Md5s8uJzLJwri5SjodjMwnsRaRvkFuXkkTcSwP8rfRgPvlicG0kWyfyScdRaRv0a795MdKY7js4W5Ia9wbgoEQ7a9C8nc2XwD8lpnuaXBofufhBoU8j9uUCW54Ay0cmsoENWL0NRqdS3hDY64xhOK6MJN6oqphNrkj0tK)1ZAy4u4nNcSghBoU8j9uUCW54PUd0ZXtgHQ5lmpmDjc61iyo54Ay0cmso(vOb27dmDjc61iyo9xHgyVpxeO3kSGfRUcnWEF0O)cO7qvXhVt)vOb27daPvyyvNWL0hcjNnXHu3wrfRO2OwHfSyvhdIVr(BiwrfRurzo(NdchpzeQMVW8W0LiOxJG5K3CkCio2CC5t6PC5GZX)Cq44xOK3DafVQcJjtoEQ7a9C8luY7oGIxvHXKjV5umgCS54PUd0ZXbyIpAzGXXLpPNYLdoV5umQYCS54PUd0ZXjrDGEoU8j9uUCW5nNIrhLJnhp1DGEoo9eHU(naunhx(KEkxo48MtXOQWXMJN6oqphNwGmb6m(fhx(KEkxo48MtXOuJJnhp1DGEo(mwenZt1a31G8nhx(KEkxo48MtXOJLJnhp1DGEo(oGc9eHUCC5t6PC5GZBofJoohBoEQ7a9C881cRH50RZ5KJlFspLlhCEZPyuQIJnhp1DGEooDU8OTVHH2jJJlFspLlhCEZPyuSghBoU8j9uUCW54Ay0cmsoENWL0NogeFJ83qSYrROkRWWkncnViq)HeagB1XV80qb0rtKWLW8ByQ7a950kQyLkC8u3b654XRkYP4)aWLjI3Ckg1H4yZXLpPNYLdohxdJwGrYX7eUK(qi5SjoK62kQOWQrh3kSGfR6eUK(qi5SjoAaiu(2kQyfHKZM4mKyYXtDhONJ3ianHhT9xjBcEZPy0XGJnhp1DGEooijjrpZJ2Ee8kqoU8j9uUCW5nNcvuMJnhp1DGEo(oNt59i4vGCC5t6PC5GZBofQmkhBoEQ7a9CCA0lxaw7PHcioU8j9uUCW5nNcvuHJnhx(KEkxo4C8u3b654KaWyRo(LNgkG44xHPHbzhONJJvzIvA0VJfauUwrcaJTApRZ1sGEnaesqA1gIgScCOaAizTaTcr2b6zhoUggTaJKJZKUJFXoKaWyR2Z6CTeOxdaHeKw5OvkBfgwTGiasRWWkwNRLapK62khvyft6o(f7qcaJTApRZ1sGEnaesqYBofQqno2CC5t6PC5GZXtDhONJtcaJT64xEAOaIJFfMggKDGEoowLjwPr)owaq5Afjam2Q9Soxlb61aqibPvBiAWkWHcOHK1c0kezhOND44Ay0cmsoot6o(f7qcaJTApRZ1sGEnaesqALJwPSvyyfdnrwHHvSoxlbEi1TvoQWkM0D8l2HeagB1EwNRLa9AaiKG0QrALYNX5nNcvglhBoU8j9uUCW54PUd0ZXjbGXwD8lpnuaXXVctddYoqphhRYeR0OFhlaOCTIeagB1EwNRLa9djMeKwTHObRahkGgswlqRqKDGE2HJRHrlWi54mP74xSdjam2Q9Soxlb6hsmjiTYrRu2kmSAbraKwHHvSoxlbEi1TvoQWkM0D8l2HeagB1EwNRLa9djMeK8MtHkJZXMJlFspLlhCoEQ7a9CCsaySvh)YtdfqC8RW0WGSd0ZXXQmXkn63XcakxRibGXwTN15Ajq)qIjbPvBiAWkWHcOHK1c0kezhOND44Ay0cmsoot6o(f7qcaJTApRZ1sG(HetcsRC0kLTcdRyOjYkmSI15AjWdPUTYrfwXKUJFXoKaWyR2Z6CTeOFiXKG0QrALYNX5nNcvOko2CC5t6PC5GZXtDhONJtcaJT64xEAOaIJFfMggKDGEoUdNS2QraCRUaW4xw1eIvueaUmrwbk(lcKRwrd0wH(PARITvqrlFpvBfr0hoUggTaJKJZ6CTe4jhqaF3Og15Ku3w5OcRu(G1ScdRaRvAeAErG(t8QICk(paCzI8nH4PNP2PhH5bkdz8mROIvJBfwWIv0a79jEvrof)haUmr(Mq80Zu70JW8aqAfy4nNcvWACS54YN0t5YbNJN6oqphNeagB1XV80qbeh)kmnmi7a9CC8oxlbA1iIvOTvQOSvGI50kNXCALAeGvXBLkNXTIjA0FzwbkAceqBfHKZ4xwHGwrcaJT64xhRScRYKRvGiK3ksaySv7zDUwc0RbGqcsRY)A1qIjbPvjuS6gSKEk3dhxdJwGrYXzs3XVyhsaySv7zDUwc0RbGqcsRuyLYwHHvmP74xSdjam2Q9Soxlb6hsmjiTsHvkBfgwTGiasRWWkwNRLapK62khTsfL5nNcvCio2CC5t6PC5GZXtDhONJtcaJT64xEAOaIJFfMggKDGEooENRLaTAeXk02Qrv2kqXCALZyoTsncWQ4TACRyIg9xMvGIMab0wri5m(LviOvKaWyRo(1XkRWQm5Afic5TIeagB1EwNRLa9AaiKG0Q8VwnKysqAvcfRUblPNY9WX1WOfyKCCM0D8l2HeagB1EwNRLa9AaiKG0kfwPSvyyft6o(f7qcaJTApRZ1sG(HetcsRuyLYwHHvm0ezfgwX6CTe4Hu3w5OvJQmV5uOYyWXMJlFspLlhCoEQ7a9CCsaySvh)YtdfqC8RW0WGSd0ZXhZadKwncGBLMiHlHzvJaLWlZQMqSs(RvOTvueaUmrJyRYxDte)YQGzfT0TaTQjY3Qh1eXVoCCnmAbgjhNgyVpXRkYP4)aWLjY3eINEMANEeMhasRWWkAG9(eVQiNI)daxMiFtiE6zQD6ryEGYqgpZkQyLdXBofutzo2CC5t6PC5GZXtDhONJtcaJT64xEAOaIJFfMggKDGEoowHQO4ALojjJFzLMiHlH5Qv0aTvKi00knrcxcZkgbc2t1wrlBeuSIIaWLjYknAqywbqAv(xRY5ebYQlWaz8lRAKvPQO4ALojjJFz1fag)YkkcaxMOdhxdJwGrYX1i08Ia9hsaySvh)YtdfqhnrcxcZVHPUd0NtRCuHvJECiRWWkWALgHMxeO)eVQiNI)daxMiFtiE6zQD6ryEGYqgpZkhTAuLTclyXkAG9(eVQiNI)daxMiFtiE6zQD6ryEaiTcm8Mtb1gLJnhx(KEkxo4C8u3b6540Zu70JW0tdfqC8RW0WGSd0ZXbFMANw5GW0kWHciRcMvAaiu(EQ2kaMCTQrwjrtiqRGc5u(GryfnuaXSIozY1k0B1uymRAI8TIiNBRsROHciR0ejCjwLQMXmPNIRwHGwnrGSsEbUuBvJSs(KEkwH1LLv4djJGJRHrlWi54AeAErG(djam2QJF5PHcOJMiHlH53Wu3b6ZPvuXkLpJZBofutfo2CC5t6PC5GZX1WOfyKCCWAL8cCP2kkTcSwjVaxQpqzjVvJ0kncnViq)XPS8SHKrCGYqgpZkWyfySIkwnwLTcdROb27d9m1oraTxJgOrNlc0BfgwPrO5fb6poLLNnKmIdajhp1DGEoo9m1o9im90qbeV5uqnQXXMJlFspLlhCoEQ7a9CCbtsz6js4ah)kmnmi7a9CCSsjNXVSYbodmdihxdJwGrYXjKC2ehsDBfvSACRgPvesoJF5zKecuoAeW3wHfSyfyTIqYz8lpJKqGYrJa(2khvyf1ScdRiKC2ehsDBfvSACLTcm8Mtb1glhBoU8j9uUCW54Ay0cmsooHKZM4qQBROIvuJAC8u3b654esoJF5LzGza5nNcQnohBoU8j9uUCW54Ay0cmsoUgHMxeO)qJE5cWApnuaDGYqgpZkQy1yTcdRyiGjD83djaRbMIxGaKDG(J8j9uUC8u3b6547PWi0WC38Mtb1Oko2CC5t6PC5GZXtDhONJ7uwE2qYi44xHPHbzhONJ7G2B5zHQYuTRw1eIvyfJWyQvKWabJoCPWScRJBf6TspLuvXvRahHBLmzIRwbkAcRKxGl1wXiL)kqMv5FTsFzwXqWwUwrlteioUggTaJKJZiL503jCjnZkhvyLk8Mtb1WACS54YN0t5YbNJRHrlWi54mszo9DcxsZSYrfwPchp1DGEo(oLz8IN1ObsEZPGAoehBoU8j9uUCW54PUd0ZXDklpBizeC8RW0WGSd0ZXD4K1wH1XTkBRAePvKWaz1fag)YkhaYbzfnWEF44Ay0cmsoonWEFajjj6zE02JGxbEai5nNcQngCS54YN0t5YbNJN6oqphxltH1ro90qbeh)kmnmi7a9CChwMcRJCAf4qbKvKWabJwTvGiKxuvGwfTvnc50kwS(yh68BRU5qUeRY)AvarpZz8wrdfqwrdS3wfmRgcgl(LvGnVunaRTQjeRiKC2eNHetR0izVdDiFBvQ1i4n(LvnYQ4B5zrR2k02QBoKlXQoDkpyC1Q8Vw1iRUadKwjyQfgZknrcxcZkAzJGIvGJa)WX1WOfyKC8oFNXVScdROb27d9m1oraTxJgOrNlc0BfgwfVgne)YFZHCjEvgJXymgyw5OvG1kcjNnXziX0QrALYhLh3kkTI15AjWZmzTVdTt)nhYL4hRvGXkmSIgyVpYeGfQkEAycAkWdRtTtROIvQWBofJvzo2CC5t6PC5GZX1WOfyKC8oFNXVScdROb27djam2HC9AI4aqAfgwbwROb27djam2HC9AI4aLHmEMvuXQrpJB1iTAPVwHfSyLgHMxeO)qcaJT64xEAOa6aLHmEMvoAfnWEFibGXoKRxtehOmKXZScmC8u3b654AzkSoYPNgkG4nNIXokhBoEQ7a9C8R0im54YN0t5YbN3CkgRkCS54YN0t5YbNJRHrlWi54mszo9DcxsZSYrfwPIvyyfnWEFGamI4xEQoVIhu83Zfb654PUd0ZXHamI4xEQoVIhu8xEZPySuJJnhx(KEkxo4CCnmAbgjhVZP89bcWiIF5P68kEqXFpYN0t5AfgwrdS3h6zQDIaAVgnqJoaKwHHv0a79bcWiIF5P68kEqXFpaKC8u3b654DSeONmNd8MtXyhlhBoU8j9uUCW54Ay0cmsoonWEF0ejekxpzYyb6zNlc0BfgwbbEzJGl5OjsiuUEYKXc0Zoc1diijLlhp1DGEoonuYMWJ2(DafEZPySJZXMJN6oqphNEMANiG27m0o54YN0t5YbN3CkglvXXMJN6oqph3PS8SHKrWXLpPNYLdoV5umwSghBoU8j9uUCW54Ay0cmsoUgHMxeO)StzgV4znAG8aLHmEMvoALkwHHvmszo9DcxsZSYrfwPchp1DGEoUMi80aqwZBofJ1H4yZXtDhONJVtzgV4znAGKJlFspLlhCEZPySJbhBoU8j9uUCW54Ay0cmsoonWEFwXU9OTVjepcZdRtTtRCuHvuJJN6oqphxWKuMEIeoWBofJRmhBoEQ7a9C8gbOj8OT)kztWXLpPNYLdoV5um(OCS54YN0t5YbNJRHrlWi540a79bcWiIF5P68kEqXFpxeONJN6oqphhcWiIF5P68kEqXF5nNIXvHJnhx(KEkxo4CCnmAbgjhNgyVpAIecLRNmzSa9Sdajhp1DGEooJm(p(LxdZx8odTtEZPyCQXXMJlFspLlhCoUggTaJKJFr9rJET8nmB563ZCqoqziJNzLcRuMJN6oqphxJET8nmB563ZCq4nNIXhlhBoU8j9uUCW54Ay0cmsoonWEFONP2jcO9A0an6CrGERWWkWAfnWEFONi0DcW6Zfb6TclyXkWAfnWEFONi0DcW6daPvyy1f1hAOKnHhT97ak(lQpqzdfgrspfRaJvGHJN6oqphNgkzt4rB)oGcV5um(4CS54YN0t5YbNJRHrlWi54uhRegtETCAcXRHa6GEkE02VN5GCgsQgb54PUd0ZXjKe2EHXKxl8MtX4ufhBoEQ7a9CCnr4PbGSMJlFspLlhCEZPyCSghBoEQ7a9CCnr4bLQkCC5t6PC5GZBofJ7qCS54PUd0ZXfmjNOB8lVtzXXLpPNYLdoV5um(yWXMJlFspLlhCoEQ7a9CCbtsz6js4ah)kmnmi7a9CChiMKY0kSYeoyfrYSIiwec0QX8i4aX2QMiFRWEeSceH8wPgbyfrQQyv2wnLK1wPIviin7WX1WOfyKCCAG9(SID7rBFtiEeMhwNANw5OcRuH3CkOkL5yZXLpPNYLdohp1DGEooJm(p(LxdZx8odTto(vyAyq2b654oCYARWDySUvX2k5ralcRKxgcHzvcfRsic4VUAfcAvSTYb4aCay7GSkywjFspL7XkSjcMvbZQ0k2mweTvxzlpluvSAIymRqQkqRayXVSc7rWkAG2QL8cmNt1wbLlGwywXIbRunHr(AXQbeuSQjY3Q8v3eXVSsMm5WX1WOfyKCCQJvqGx2i4somIerKiMFiwe9rOEabjPCTcdRaRvPUdvfV8YqimRCuHvuZkSGfRys3XVyheMEq50PaTcdR0O)ce9buoD6bfnHVjepcZJ8j9uUwbgRWWkncnViq)XPS8SHKrCGYqgpZkhTAPVwHHvG1k5f4sTvuAfyTsEbUuFGYsERgPvG1kncnViq)XPS8SHKrCGYqgpZkkTsWu0aT47yqScmwbgRaJvoQWkQACRWWkWAf1XQoNY3hgz07akh5t6PCTclyXkQJvqGx2i4soAIecLRNmzSa9SJq9acss5Afy4nNcQAuo2CC5t6PC5GZX1WOfyKCCQJvDoLVp0Zu7eb0EnAGgDKpPNY1kmSsJqZlc0FCklpBizehOmKXZSYrRw6RvyyfyTsEbUuBfLwbwRKxGl1hOSK3QrAfyTsJqZlc0FCklpBizehOmKXZSIsRw6RvGXkWyfySYrfwrvJZXtDhONJ3XsGEYCoWBofuLkCS54YN0t5YbNJRHrlWi54YlWLAROIvuBuoEQ7a9C8eQZx8nccLV5nNcQIACS54YN0t5YbNJRHrlWi54meWKo(7rv0m7ykEgAQQ89r(KEkxoEQ7a9C89uyeAyUBEZPGQglhBoEQ7a9CCiaJi(LNQZR4bf)LJlFspLlhCEZBooju0Ob6S5yZPyuo2C8u3b6547PWi0WC3CC5t6PC5GZBofQWXMJN6oqphNg19uU(9mvlxqXV8ncZ454YN0t5YbN3CkOghBoEQ7a9C89uyeAyUBoU8j9uUCW5nNIXYXMJN6oqphxteEAaiR54YN0t5YbN3CkgNJnhp1DGEoUMi8GsvfoU8j9uUCW5nV5nhxvbYc0ZPqfLvzuLXAQqnooOe(XVyCChawXiAkOUOymzeBLvytiwfdKiyB1gbTYbFLDcmBhSvqH6beq5AfdniwLanAiB5ALMi)LWoM7X04fROQrhXw5WOxvb2Y1khCNt57ZikhSvnYkhCNt57ZiQJ8j9uUoyRa7OycMJ52CtDnqIGTCTsfRsDhO3QzWA2XCZXjHODmfoUlCHvGdfqdjRfOvu3O3P52fUWk3at1wrTrD1kvuwLrn3MBx4cRCyI8xcBeBUDHlSI6B1yCg1Q41tGRWSAeaGXwD8lRahkGSs(ggcZkOmZwUw1iROUEvrofROiaCzISQjY2QlYQh1wbWIFzfJu0wXKUJFXowz1iarQgxXQTix6u70k0B1ys0yLa0hZTlCHvuFRgZbdkReET6fqw1jCj9rJqZlc0FitaM4tDhO)aLHmEMvA0FJoqpZQMiBRUO3b3wrKQkwLVvXt9x5GyLq9acvZP89XC7cxyf13kQ70Pyft6o(f7GW0dkNofOvmasseSTcGf)YkChgRBf6TAlGeOvnr(wrnRKxgcHzfOOjSsJ(lq0hq50Phu0e(Mq8impMBZTlCHvoqmfnqlxROLnckwPrd0zBfTSINDScRqRfYMz1JEQprch2atRsDhONzf6NQpM7u3b6zhsOOrd0ztPcL2tHrOH5Un3PUd0ZoKqrJgOZMsfkrJ6Ekx)EMQLlO4x(gHz8M7u3b6zhsOOrd0ztPcL2tHrOH5Un3PUd0ZoKqrJgOZMsfkPjcpnaK1M7u3b6zhsOOrd0ztPcL0eHhuQQyUn3UWfw5aXu0aTCTsuvGQTQJbXQMqSk1ncAvWSkvnJzspLJ5o1DGEMcgPKqpr(xpRHHtXCBUtDhONrPcLibGXwD8lpnua5ASvWKUJFXoKaWyR2VrqVwMcRJCIby7yq8nYpKy61ejCjmQS03ZqIjwWcnWEFibGXoKRxtehasmOb27djam2HC9AI4aLHmEgvg9m(ix67ziXemyblAeAErG(JwMcRJC6PHcOdugY4zurLrU03ZqIjgAIeUeMFdtDhOpNoo6zCZDQ7a9mkvOKwMcRJC6PHcixJTcAG9(qcaJDixVMioaKM7u3b6zuQqPBoqkVNiHdUgBfesoBIdPUPcwBCmIxJgIF5V5qUep1yosi5SjodjMJeSkFuHsWQ8rLrUGiasWagmOb27Zgb7yRo(LNgkGoxeO3CN6oqpJsfkTrWo2QJF5PHcixJTccjNnXHu3uzCLXiEnAi(L)Md5s8uJ5iHKZM4mKyosWQ8rfkbRYhvg5cIaibdyWaS0a795MdKY7js4W5Ia9GXCBUtDhONrPcLyKsc9e5F9SggofxJTIoHlPpxHgyVp6K1XVoqj1T5o1DGEgLkucGj(OLbx)CquKmcvZxyEy6se0RrWC6ASvCfAG9(atxIGEncMt)vOb27Zfb6XcwUcnWEF0O)cO7qvXhVt)vOb27dajgDcxsFiKC2ehsDtfQnkwWshdIVr(BiurfLn3PUd0ZOuHsamXhTm46NdIIluY7oGIxvHXKP5o1DGEgLkucGj(OLbM5o1DGEgLkuIe1b6n3PUd0ZOuHs0te663aq1M7u3b6zuQqjAbYeOZ4xM7u3b6zuQqPzSiAMNQbURb5BZDQ7a9mkvO0oGc9eHUM7u3b6zuQqP81cRH50RZ50CN6oqpJsfkrNlpA7ByODYm3PUd0ZOuHsXRkYP4)aWLjY3eINEMANEeMUgBfDcxsF6yq8nYFdXrQcdncnViq)HeagB1XV80qb0rtKWLW8ByQ7a95KkQyUtDhONrPcLAeGMWJ2(RKnHRXwrNWL0hcjNnXHu3urXOJJfS0jCj9HqYztC0aqO8nviKC2eNHetZDQ7a9mkvOeijjrpZJ2Ee8kqZDQ7a9mkvO0oNt59i4vGM7u3b6zuQqjA0lxaw7PHciZT52fwHvzIvA0VJfauUwrcaJTApRZ1sGEnaesqA1gIgScCOaAizTaTcr2b6zhZDQ7a9mkvOejam2QJF5PHcixJTcM0D8l2HeagB1EwNRLa9AaiKG0rLXybraKyW6CTe4Hu3oQGjDh)IDibGXwTN15AjqVgacjin3UWkSktSsJ(DSaGY1ksaySv7zDUwc0RbGqcsR2q0GvGdfqdjRfOviYoqp7yUtDhONrPcLibGXwD8lpnua5ASvWKUJFXoKaWyR2Z6CTeOxdaHeKoQmgm0eHbRZ1sGhsD7OcM0D8l2HeagB1EwNRLa9AaiKGCKkFg3CBUDHvyvMyLg97ybaLRvKaWyR2Z6CTeOFiXKG0Qnenyf4qb0qYAbAfISd0ZoM7u3b6zuQqjsaySvh)YtdfqUgBfmP74xSdjam2Q9Soxlb6hsmjiDuzmwqeajgSoxlbEi1TJkys3XVyhsaySv7zDUwc0pKysqAUDHvyvMyLg97ybaLRvKaWyR2Z6CTeOFiXKG0Qnenyf4qb0qYAbAfISd0ZoM7u3b6zuQqjsaySvh)YtdfqUgBfmP74xSdjam2Q9Soxlb6hsmjiDuzmyOjcdwNRLapK62rfmP74xSdjam2Q9Soxlb6hsmjihPYNXn3MBxyLdNS2QraCRUaW4xw1eIvueaUmrwbk(lcKRwrd0wH(PARITvqrlFpvBfr0hZDQ7a9mkvOejam2QJF5PHcixJTcwNRLap5ac47g1OoNK62rfkFWAyawncnViq)jEvrof)haUmr(Mq80Zu70JW8aLHmEgvghlyHgyVpXRkYP4)aWLjY3eINEMANEeMhasWyUn3UWk8oxlbA1iIvOTvQOSvGI50kNXCALAeGvXBLkNXTIjA0FzwbkAceqBfHKZ4xwHGwrcaJT64xhRScRYKRvGiK3ksaySv7zDUwc0RbGqcsRY)A1qIjbPvjuS6gSKEk3J5o1DGEgLkuIeagB1XV80qbKRXwbt6o(f7qcaJTApRZ1sGEnaesqQqzmys3XVyhsaySv7zDUwc0pKysqQqzmwqeajgSoxlbEi1TJQOS52fwH35AjqRgrScTTAuLTcumNw5mMtRuJaSkERg3kMOr)LzfOOjqaTvesoJFzfcAfjam2QJFDSYkSktUwbIqERibGXwTN15AjqVgacjiTk)RvdjMeKwLqXQBWs6PCpM7u3b6zuQqjsaySvh)YtdfqUgBfmP74xSdjam2Q9Soxlb61aqibPcLXGjDh)IDibGXwTN15Ajq)qIjbPcLXGHMimyDUwc8qQBhhvzZT52fwnMbgiTAea3knrcxcZQgbkHxMvnHyL8xRqBROiaCzIgXwLV6Mi(LvbZkAPBbAvtKVvpQjIFDm3PUd0ZOuHsKaWyRo(LNgkGCn2kOb27t8QICk(paCzI8nH4PNP2PhH5bGedAG9(eVQiNI)daxMiFtiE6zQD6ryEGYqgpJkoK52C7cRWkuffxR0jjz8lR0ejCjmxTIgOTIeHMwPjs4sywXiqWEQ2kAzJGIvueaUmrwPrdcZkasRY)AvoNiqwDbgiJFzvJSkvffxR0jjz8lRUaW4xwrra4YeDm3PUd0ZOuHsKaWyRo(LNgkGCn2k0i08Ia9hsaySvh)YtdfqhnrcxcZVHPUd0Nthvm6XHWaSAeAErG(t8QICk(paCzI8nH4PNP2PhH5bkdz8mhhvzSGfAG9(eVQiNI)daxMiFtiE6zQD6ryEaibJ52C7cRaFMANw5GW0kWHciRcMvAaiu(EQ2kaMCTQrwjrtiqRGc5u(GryfnuaXSIozY1k0B1uymRAI8TIiNBRsROHciR0ejCjwLQMXmPNIRwHGwnrGSsEbUuBvJSs(KEkwH1LLv4djJWCN6oqpJsfkrptTtpctpnua5ASvOrO5fb6pKaWyRo(LNgkGoAIeUeMFdtDhOpNur5Z4M7u3b6zuQqj6zQD6ry6PHcixJTcWkVaxQPeSYlWL6duwYpsncnViq)XPS8SHKrCGYqgpdmGHkJvzmOb27d9m1oraTxJgOrNlc0JHgHMxeO)4uwE2qYioaKMBZTlScRuYz8lRCGZaZaAUtDhONrPcLemjLPNiHdUgBfesoBIdPUPY4JKqYz8lpJKqGYrJa(glybSesoJF5zKecuoAeW3oQGAyqi5SjoK6MkJRmym3PUd0ZOuHsesoJF5LzGzaDn2kiKC2ehsDtfQrnZT5o1DGEgLkuApfgHgM721yRqJqZlc0FOrVCbyTNgkGoqziJNrLXIbdbmPJ)EibynWu8ceGSd0FKpPNY1CBUDHvoO9wEwOQmv7QvnHyfwXimMAfjmqWOdxkmRW64wHER0tjvvC1kWr4wjtM4QvGIMWk5f4sTvms5VcKzv(xR0xMvmeSLRv0YebYCN6oqpJsfk5uwE2qYiCn2kyKYC67eUKM5Ocvm3PUd0ZOuHs7uMXlEwJgiDn2kyKYC67eUKM5Ocvm3MBxyLdNS2kSoUvzBvJiTIegiRUaW4xw5aqoiROb27J5o1DGEgLkuYPS8SHKr4ASvqdS3hqssIEMhT9i4vGhasZT52fw5WYuyDKtRahkGSIegiy0QTceH8IQc0QOTQriNwXI1h7qNFB1nhYLyv(xRci6zoJ3kAOaYkAG92QGz1qWyXVScS5LQbyTvnHyfHKZM4mKyALgj7DOd5BRsTgbVXVSQrwfFlplA1wH2wDZHCjw1Pt5bJRwL)1Qgz1fyG0kbtTWywPjs4sywrlBeuScCe4hZDQ7a9mkvOKwMcRJC6PHcixJTIoFNXVWGgyVp0Zu7eb0EnAGgDUiqpgXRrdXV83CixIxLXymgJbMJGLqYztCgsmhPYhLhNswNRLapZK1(o0o93CixIFSGbdAG9(itawOQ4PHjOPapSo1oPIkM7u3b6zuQqjTmfwh50tdfqUgBfD(oJFHbnWEFibGXoKRxtehasmalnWEFibGXoKRxtehOmKXZOYONXh5sFXcw0i08Ia9hsaySvh)YtdfqhOmKXZCKgyVpKaWyhY1RjIdugY4zGXCBUtDhONrPcLUsJW0CBUtDhONrPcLGamI4xEQoVIhu8xxJTcgPmN(oHlPzoQqfmOb27deGre)Yt15v8GI)EUiqV5o1DGEgLkuQJLa9K5CW1yROZP89bcWiIF5P68kEqXFpYN0t5IbnWEFONP2jcO9A0an6aqIbnWEFGamI4xEQoVIhu83daP5o1DGEgLkuIgkzt4rB)oGIRXwbnWEF0ejekxpzYyb6zNlc0Jbe4LncUKJMiHq56jtglqp7iupGGKuUM7u3b6zuQqj6zQDIaAVZq70CN6oqpJsfk5uwE2qYim3PUd0ZOuHsAIWtdazTRXwHgHMxeO)StzgV4znAG8aLHmEMJQGbJuMtFNWL0mhvOI5o1DGEgLkuANYmEXZA0aP5o1DGEgLkusWKuMEIeo4ASvqdS3NvSBpA7BcXJW8W6u70rfuZCN6oqpJsfk1ianHhT9xjBcZDQ7a9mkvOeeGre)Yt15v8GI)6ASvqdS3hiaJi(LNQZR4bf)9CrGEZDQ7a9mkvOeJm(p(LxdZx8odTtxJTcAG9(OjsiuUEYKXc0ZoaKM7u3b6zuQqjn61Y3WSLRFpZbX1yR4I6Jg9A5By2Y1VN5GCGYqgptHYM7u3b6zuQqjAOKnHhT97akUgBf0a79HEMANiG2Rrd0OZfb6XaS0a79HEIq3jaRpxeOhlybS0a79HEIq3jaRpaKyCr9Hgkzt4rB)oGI)I6du2qHrK0tbmGXCN6oqpJsfkrijS9cJjVwCn2kOocJjVwonH41qaDqpfpA73ZCqodjvJGM7u3b6zuQqjnr4PbGS2CN6oqpJsfkPjcpOuvXCN6oqpJsfkjysor34xENYYC7cRCGysktRWkt4GvejZkIyriqRgZJGdeBRAI8Tc7rWkqeYBLAeGvePQIvzB1uswBLkwHG0SJ5o1DGEgLkusWKuMEIeo4ASvqdS3NvSBpA7BcXJW8W6u70rfQyUDHvoCYARWDySUvX2k5ralcRKxgcHzvcfRsic4VUAfcAvSTYb4aCay7GSkywjFspL7XkSjcMvbZQ0k2mweTvxzlpluvSAIymRqQkqRayXVSc7rWkAG2QL8cmNt1wbLlGwywXIbRunHr(AXQbeuSQjY3Q8v3eXVSsMm5yUtDhONrPcLyKX)XV8Ay(I3zOD6ASvqDGaVSrWLCyejIirm)qSi6Jq9acss5IbytDhQkE5LHqyoQGAyblmP74xSdctpOC6uGyOr)fi6dOC60dkAcFtiEeMh5t6PCbdgAeAErG(Jtz5zdjJ4aLHmEMJl9fdWkVaxQPeSYlWL6duwYpsWQrO5fb6poLLNnKmIdugY4zukykAGw8DmiGbmGXrfu14yawQtNt57dJm6DaLJ8j9uUybluhiWlBeCjhnrcHY1tMmwGE2rOEabjPCbJ5o1DGEgLkuQJLa9K5CW1yRG605u((qptTteq71ObAegAeAErG(Jtz5zdjJ4aLHmEMJl9fdWkVaxQPeSYlWL6duwYpsWQrO5fb6poLLNnKmIdugY4zuU0xWagW4OcQACZDQ7a9mkvOuc15l(gbHY3UgBfYlWLAQqTrn3PUd0ZOuHs7PWi0WC3UgBfmeWKo(7rv0m7ykEgAQQ89r(KEkxZDQ7a9mkvOeeGre)Yt15v8GI)YXzKIMtHkuLdXBEZ5]] )


end