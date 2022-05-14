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

    local function trackBrewmasterDamage( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, arg1, arg2, arg3, arg4, arg5, arg6, _, arg8, _, _, arg11 )
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
    spec:RegisterCombatLogEvent( function( ... )
        trackBrewmasterDamage( ... )
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
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = true,
            texture = 606543,

            handler = function ()
                applyBuff( "shuffle" )

                if talent.celestial_flames.enabled then
                    applyDebuff( "target", "breath_of_fire_dot" )
                    active_dot.breath_of_fire_dot = active_enemies
                end

                applyBuff( "spinning_crane_kick" )

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



    spec:RegisterPack( "Brewmaster", 20220302, [[d4u1dbqiOO0JOI4skeInbf(ejf1OakDkGIvPq0RqknlQOUfjfSlv8lsIHrI6ykuTmsKNHuPPPqX1uiTnKQY3qQIghuu5CkeSofc18qQ4EKW(iP6GkuQwiq1djPKjQqPCrsk0hvOensOOkNekQQvsL6LivHzQqjCtfkPDIu8tskYqjPulvHqQNcvtfk1vHIIVIuv1yviKSxu9xQAWsoSOfJKhtQjRsxMyZk1NvYOr40cRgPk9AQKzROBRGDRQFdz4i64ivvwoONJY0L66a2ojPVdKXdLCEQW6PI08HISFkZhNJnh)MTWPrjLvsjLPRYkDgFegDmJpkhVDqkCCYu7kxch)ZbHJdouanKSwGCCY0XeLxo2CCgcaQfoor3KSrSkQSIMaG6OrdQWIbGz2b61WC3QWIbTkCCkGy2y(pNIJFZw40OKYkPKY0vzLoJpcJoMXPlhpbAceKJJhdQfhNiUx55uC8RW0CCWHcOHK1c0QXk6DzUhRjutyLsoBLskRKsMBZTArK)syJyZTAWQr4mUvXRNaxHzLAdaJTJ4xwbouazL8nmeMvqzMTCTQrwH5)QICjwrta40ezvtKTvxKvpQTcGf)YkgPOTIjDh)IDSYk1gIunUIvBrUuP2LvO3QXYOX8aOoMB1GvJTGbLvcVw9ciR6eUK(OrO5fb6pKjat8PUd0FGYqgpZkn6VrhONzvtKTvx0RMBRisvfRY3Q4vdRCqSsOFaHQ5u((yUvdwnwtxIvmP74xSdclpOC6sGwXaijrW2kaw8lRWvl6HvO3QTasGw1e5BfDTsEzieMvGIMWkn6VarFaLtxEqrt4BcXJW6WXNbRzCS54xzNaZMJnNMX5yZXtDhONJZiLe6jY)6znmCjCC5tQPC5GZBonkXXMJlFsnLlhCoUggTaJKJZKUJFXoKaWy7WVrqVwMcRJCAfgwbwR6yq8nYpKy51ejCjmROJvl99mKyzfMWKvua79Heag7qUEnrCaiTcdROa27djam2HC9AI4aLHmEMv0XQXpJA1iTAPVNHelRaJvyctwPrO5fb6pAzkSoYPNckGoqziJNzfDSsjRgPvl99mKyzfgwPjs4sy(nm1DG(CAL6wn(zuoEQ7a9CCsaySDe)Ytbfq8MtdD5yZXLpPMYLdohxdJwGrYXPa27djam2HC9AI4aqYXtDhONJRLPW6iNEkOaI3CAgdhBoU8j1uUCW54Ay0cmsooHKZM4qQBROJv0ZrTcdRIxJgIF5V5qUepDzwPUvesoBIZqILvJ0kWALYhLSIwRaRvkFuYQrA1cIaiTcmwbgRWWkkG9(SrWo2oIF5PGcOZfb654PUd0ZXV5aP8EIeoWBonJYXMJlFsnLlhCoUggTaJKJti5SjoK62k6y1OkBfgwfVgne)YFZHCjE6YSsDRiKC2eNHelRgPvG1kLpkzfTwbwRu(OKvJ0QfebqAfyScmwHHvG1kkG9(CZbs59ejC4CrGERadhp1DGEo(gb7y7i(LNckG4nNg6JJnhx(KAkxo4CCnmAbgjhVt4s6ZvOa27JozD8RdusDZXtDhONJZiLe6jY)6znmCj8Mtd9KJnhx(KAkxo4C8u3b654jJq18fMhMofb9AemNCCnmAbgjh)kua79bMofb9AemN(RqbS3Nlc0BfMWKvxHcyVpA0Fb0DOQ4J3L)kua79bG0kmSQt4s6dHKZM4qQBROJv0DCRWeMSQJbX3i)neROJvkPmh)ZbHJNmcvZxyEy6ue0RrWCYBonyoo2CC5tQPC5GZX)Cq44xOK3DafVQcJjtoEQ7a9C8luY7oGIxvHXKjV50mcCS54PUd0ZXbyIpAzGXXLpPMYLdoV50mUYCS54PUd0ZXjrDGEoU8j1uUCW5nNMXhNJnhp1DGEoo1eHU(na0bhx(KAkxo48MtZ4kXXMJN6oqphNsGmb6k(fhx(KAkxo48MtZ40LJnhp1DGEo(mwenZtVa31G8nhx(KAkxo48MtZ4JHJnhp1DGEo(oGc1eHUCC5tQPC5GZBonJpkhBoEQ7a9C881cRH50RZ5KJlFsnLlhCEZPzC6JJnhp1DGEoovU8OTVHH2fJJlFsnLlhCEZPzC6jhBoU8j1uUCW54Ay0cmsoENWL0NogeFJ83qSsDROpRWWkncnViq)HeagBhXV8uqb0rtKWLW8ByQ7a950k6yLsC8u3b654XRkYL4)aWPjI3CAghZXXMJlFsnLlhCoUggTaJKJ3jCj9HqYztCi1Tv0rHvJpQvyctw1jCj9HqYztC0aqO8Tv0XkcjNnXziXIJN6oqphVraAcpA7Vs2e8MtZ4JahBoEQ7a9CCqssIEMhT9i4vGCC5tQPC5GZBonkPmhBoEQ7a9C8DoNY7rWRa54YNut5YbN3CAuACo2CC5tQPC5GZX1WOfyKCCmRvxHcyVpuOxUaS2tbfq(RqbS3hasoEQ7a9CCk0lxaw7PGciEZPrjL4yZXLpPMYLdohp1DGEoojam2oIF5PGcio(vyAyq2b654ygMyLg97ybaLRvKaWy7WZ6CTeOxdaHeKwTHObRahkGgswlqRqKDGE2HJRHrlWi54mP74xSdjam2o8Soxlb61aqibPvQBLYwHHvlicG0kmSI15AjWdPUTsDfwXKUJFXoKaWy7WZ6CTeOxdaHeK8MtJs0LJnhx(KAkxo4C8u3b654KaWy7i(LNckG44xHPHbzhONJJzyIvA0VJfauUwrcaJTdpRZ1sGEnaesqA1gIgScCOaAizTaTcr2b6zhoUggTaJKJZKUJFXoKaWy7WZ6CTeOxdaHeKwPUvkBfgwXqtKvyyfRZ1sGhsDBL6kSIjDh)IDibGX2HN15AjqVgacjiTAKwP8zuEZPrPXWXMJlFsnLlhCoEQ7a9CCsaySDe)YtbfqC8RW0WGSd0ZXXmmXkn63XcakxRibGX2HN15Ajq)qIfbPvBiAWkWHcOHK1c0kezhOND44Ay0cmsoot6o(f7qcaJTdpRZ1sG(HelcsRu3kLTcdRwqeaPvyyfRZ1sGhsDBL6kSIjDh)IDibGX2HN15Ajq)qIfbjV50O0OCS54YNut5YbNJN6oqphNeagBhXV8uqbeh)kmnmi7a9CCmdtSsJ(DSaGY1ksaySD4zDUwc0pKyrqA1gIgScCOaAizTaTcr2b6zhoUggTaJKJZKUJFXoKaWy7WZ6CTeOFiXIG0k1TszRWWkgAIScdRyDUwc8qQBRuxHvmP74xSdjam2o8Soxlb6hsSiiTAKwP8zuEZPrj6JJnhx(KAkxo4C8u3b654KaWy7i(LNckG44xHPHbzhONJRwjRTsTb3Qlam(LvnHyfnbGttKvGI)Ia5SvuaTvOF6WQyBfu0Y3thwre9HJRHrlWi54SoxlbEYbeW3nQrDoj1TvQRWkLp0tRWWkWALgHMxeO)eVQixI)daNMiFtiEQzQD5ryDGYqgpZk6y1OwHjmzffWEFIxvKlX)bGttKVjep1m1U8iSoaKwbgEZPrj6jhBoU8j1uUCW54PUd0ZXjbGX2r8lpfuaXXVctddYoqphhVZ1sGwnIyfABLskBfOyoTYvmNw5abyv8wP0zuRyIg9xMvGIMab0wri5m(LviOvKaWy7i(1XkRWmm5Afic5TIeagBhEwNRLa9AaiKG0Q8VwnKyrqAvcfRUblPMY9WX1WOfyKCCM0D8l2HeagBhEwNRLa9AaiKG0kfwPSvyyft6o(f7qcaJTdpRZ1sG(HelcsRuyLYwHHvlicG0kmSI15AjWdPUTsDRuszEZPrjmhhBoU8j1uUCW54PUd0ZXjbGX2r8lpfuaXXVctddYoqphhVZ1sGwnIyfAB14kBfOyoTYvmNw5abyv8wnQvmrJ(lZkqrtGaARiKCg)Yke0ksaySDe)6yLvygMCTceH8wrcaJTdpRZ1sGEnaesqAv(xRgsSiiTkHIv3GLut5E44Ay0cmsoot6o(f7qcaJTdpRZ1sGEnaesqALcRu2kmSIjDh)IDibGX2HN15Ajq)qIfbPvkSszRWWkgAIScdRyDUwc8qQBRu3QXvM3CAuAe4yZXLpPMYLdohp1DGEoojam2oIF5PGcio(vyAyq2b654JnGbsRuBWTstKWLWSQrGs4Lzvtiwj)1k02kAcaNMOrSv57OjIFzvWSIs6wGw1e5B1JAI4xhoUggTaJKJtbS3N4vf5s8Fa40e5BcXtntTlpcRdaPvyyffWEFIxvKlX)bGttKVjep1m1U8iSoqziJNzfDScZXBon0vzo2CC5tQPC5GZXtDhONJtcaJTJ4xEkOaIJFfMggKDGEo(yxvuCTsNKKXVSstKWLWC2kkG2kseAALMiHlHzfJab7PdROKnckwrta40ezLgnimRaiTk)Rv5CIaz1fyGm(LvnYQuvuCTsNKKXVS6caJFzfnbGtt0HJRHrlWi54AeAErG(djam2oIF5PGcOJMiHlH53Wu3b6ZPvQRWQXpyoRWWkWALgHMxeO)eVQixI)daNMiFtiEQzQD5ryDGYqgpZk1TACLTctyYkkG9(eVQixI)daNMiFtiEQzQD5ryDaiTcm8MtdDhNJnhx(KAkxo4C8u3b654uZu7YJWYtbfqC8RW0WGSd0ZXbFMAxwPMWYkWHciRcMvAaiu(E6WkaMCTQrwjrtiqRGc5u(GryffuaXSIkzY1k0B1uymRAI8TIiNBRsROGciR0ejCjwLQMXmPMIZwHGwnrGSsEbUCyvJSs(KAkwrpKLv4djJGJRHrlWi54AeAErG(djam2oIF5PGcOJMiHlH53Wu3b6ZPv0XkLpJYBon0vjo2CC5tQPC5GZX1WOfyKCCWAL8cC5WkATcSwjVaxooqzjVvJ0kncnViq)XLS8SHKrCGYqgpZkWyfySIowngLTcdROa27d1m1UqaTxJgOqNlc0BfgwPrO5fb6pUKLNnKmIdajhp1DGEoo1m1U8iS8uqbeV50qx6YXMJlFsnLlhCoEQ7a9CCblsz6js4ah)kmnmi7a9CCmpjNXVSsnodScihxdJwGrYXjKC2ehsDBfDSAuRgPvesoJF5zKecuoAeW3wHjmzfyTIqYz8lpJKqGYrJa(2k1vyfDTcdRiKC2ehsDBfDSAuLTcm8MtdDhdhBoU8j1uUCW54Ay0cmsooHKZM4qQBROJv0LUC8u3b654esoJF5LzGva5nNg6okhBoU8j1uUCW54Ay0cmsoUgHMxeO)qHE5cWApfuaDGYqgpZk6y1yScdRyiGjv83djaRbMIxGaKDG(J8j1uUC8u3b6547PWi0WC38MtdDPpo2CC5tQPC5GZXtDhONJ7swE2qYi44xHPHbzhONJRM2B5zHQY0HZw1eIvJD1ESWksyGGrhovywrpWTc9wPNsQQ4SvGJWTsMmXzRafnHvYlWLdRyKYFfiZQ8VwPVmRyiylxROKjcehxdJwGrYXzKYC67eUKMzL6kSsjEZPHU0to2CC5tQPC5GZX1WOfyKCCgPmN(oHlPzwPUcRuIJN6oqphFNYmEXZA0ajV50qxmhhBoU8j1uUCW54PUd0ZXDjlpBizeC8RW0WGSd0ZXvRK1wrpWTkBRAePvKWaz1fag)Yk6psnzffWEF44Ay0cmsoofWEFajjj6zE02JGxbEai5nNg6ocCS54YNut5YbNJN6oqphxltH1ro9uqbeh)kmnmi7a9CC1sMcRJCAf4qbKvKWabJ2HvGiKxuvGwfTvnc5YkwS(yh68BRU5qUeRY)AvarpZv8wrbfqwrbS3wfmRgcgl(LvGnV0laRTQjeRiKC2eNHelR0izVdDiFBvQ1i4n(LvnYQ4B5zr7Wk02QBoKlXQoDjpyC2Q8Vw1iRUadKwjyPfgZknrcxcZkkzJGIvGJa)WX1WOfyKC8oFxXVScdROa27d1m1UqaTxJgOqNlc0BfgwfVgne)YFZHCjELgHryegywPUvG1kcjNnXziXYQrALYhLh1kATI15AjWZmzTVdTl)nhYL4hJvGXkmSIcyVpYeGfQkEkycAkWdRtTlROJvkXBonJrzo2CC5tQPC5GZX1WOfyKC8oFxXVScdROa27djam2HC9AI4aqAfgwbwROa27djam2HC9AI4aLHmEMv0XQXpJA1iTAPVwHjmzLgHMxeO)qcaJTJ4xEkOa6aLHmEMvQBffWEFibGXoKRxtehOmKXZScmC8u3b654AzkSoYPNckG4nNMXmohBoEQ7a9C8R0iS44YNut5YbN3CAgJsCS54YNut5YbNJRHrlWi54mszo9DcxsZSsDfwPKvyyffWEFGamI4xE6nVIhu83Zfb654PUd0ZXHamI4xE6nVIhu8xEZPzm0LJnhx(KAkxo4CCnmAbgjhVZP89bcWiIF5P38kEqXFpYNut5AfgwrbS3hQzQDHaAVgnqHoaKwHHvua79bcWiIF5P38kEqXFpaKC8u3b654DSeONmNd8MtZygdhBoU8j1uUCW54Ay0cmsoofWEF0ejekxpzYyb6zNlc0BfgwbbEzJGl5OjsiuUEYKXc0Zoc9diijLlhp1DGEoofuYMWJ2(DafEZPzmJYXMJN6oqphNAMAxiG27k0U44YNut5YbN3CAgd9XXMJN6oqph3LS8SHKrWXLpPMYLdoV50mg6jhBoU8j1uUCW54Ay0cmsoUgHMxeO)StzgV4znAG8aLHmEMvQBLswHHvmszo9DcxsZSsDfwPehp1DGEoUMi8uaqwZBonJbZXXMJN6oqphFNYmEXZA0ajhx(KAkxo48MtZygbo2CC5tQPC5GZX1WOfyKCCkG9(SID7rBFtiEewhwNAxwPUcROlhp1DGEoUGfPm9ejCG3CAgvzo2C8u3b654ncqt4rB)vYMGJlFsnLlhCEZPz0X5yZXLpPMYLdohxdJwGrYXPa27deGre)YtV5v8GI)EUiqphp1DGEooeGre)YtV5v8GI)YBonJQehBoU8j1uUCW54Ay0cmsoofWEF0ejekxpzYyb6zhasoEQ7a9CCgz8F8lVgMV4DfAx8MtZO0LJnhx(KAkxo4CCnmAbgjh)I6Jg9A5By2Y1VN5GCGYqgpZkfwPmhp1DGEoUg9A5By2Y1VN5GWBonJogo2CC5tQPC5GZX1WOfyKCCkG9(qntTleq71Obk05Ia9wHHvG1kkG9(qnrO7eG1Nlc0BfMWKvG1kkG9(qnrO7eG1hasRWWQlQpuqjBcpA73bu8xuFGYgkmIKAkwbgRadhp1DGEoofuYMWJ2(DafEZPz0r5yZXLpPMYLdohxdJwGrYXXSwjmM8A50eIxdb0b1u8OTFpZb5mK0lcYXtDhONJtijS9cJjVw4nNMrPpo2C8u3b654AIWtbaznhx(KAkxo48MtZO0to2C8u3b654AIWdkvv44YNut5YbN3CAgfZXXMJN6oqphxWICIUXV8UKfhx(KAkxo48MtZOJahBoU8j1uUCW54PUd0ZXfSiLPNiHdC8RW0WGSd0ZXvJyrktRW8s4GvejZkIyriqRgBQTAeBRAI8TcB12kqeYBLdeGvePQIvzB1uswBLswHGuSdhxdJwGrYXPa27Zk2ThT9nH4ryDyDQDzL6kSsjEZPH(uMJnhx(KAkxo4C8u3b654mY4)4xEnmFX7k0U44xHPHbzhONJRwjRTcxTOhwfBRKhbSiSsEzieMvjuSkHiG)6SviOvX2k6p9N(JTAYQGzL8j1uUhRWMiywfmRsRyZyr0wDLT8SqvXQjIXScPQaTcGf)YkSvBROaARwYlWCoDyfuUaAHzflgSs1eg5RfRgqqXQMiFRY3rte)YkzYKdhxdJwGrYXXSwbbEzJGl5WiserIy(Hyr0hH(beKKY1kmScSwL6ouv8YldHWSsDfwrxRWeMSIjDh)IDqy5bLtxc0kmSsJ(lq0hq50Lhu0e(Mq8iSoYNut5AfyScdR0i08Ia9hxYYZgsgXbkdz8mRu3QL(AfgwbwRKxGlhwrRvG1k5f4YXbkl5TAKwbwR0i08Ia9hxYYZgsgXbkdz8mRO1kblrd0IVJbXkWyfyScmwPUcROVrTcdRaRvywR6CkFFyKrVdOCKpPMY1kmHjRWSwbbEzJGl5OjsiuUEYKXc0Zoc9diijLRvGH3CAOVX5yZXLpPMYLdohxdJwGrYXXSw15u((qntTleq71Obk0r(KAkxRWWkncnViq)XLS8SHKrCGYqgpZk1TAPVwHHvG1k5f4YHv0AfyTsEbUCCGYsERgPvG1kncnViq)XLS8SHKrCGYqgpZkATAPVwbgRaJvGXk1vyf9nkhp1DGEoEhlb6jZ5aV50qFkXXMJlFsnLlhCoUggTaJKJlVaxoSIowr3X54PUd0ZXtOoFX3iiu(M3CAOp6YXMJlFsnLlhCoUggTaJKJZqatQ4VhvrZSJP4zOPQY3h5tQPC54PUd0ZX3tHrOH5U5nNg6BmCS54PUd0ZXHamI4xE6nVIhu8xoU8j1uUCW5nV54KqrJgOYMJnNMX5yZXtDhONJVNcJqdZDZXLpPMYLdoV50OehBoEQ7a9CCku3t563Z0HCbf)Y3iSINJlFsnLlhCEZPHUCS54PUd0ZX3tHrOH5U54YNut5YbN3CAgdhBoEQ7a9CCnr4PaGSMJlFsnLlhCEZPzuo2C8u3b654AIWdkvv44YNut5YbN38M3CCvfilqpNgLuwPXvgZP84CCqj8JFX440)X(iAAW8PzSCeBLvytiwfdKiyB1gbTsnFLDcmB1SvqH(beq5AfdniwLanAiB5ALMi)LWoM7XI4fROVXhXwPwOxvb2Y1k1CNt57Zik1SvnYk1CNt57ZiQJ8j1uUQzRa74ybMJ52CJ5pqIGTCTsjRsDhO3QzWA2XCZXjHODmfoUtCIvGdfqdjRfOvJv07YC7eNy1ynHAcRuYzRuszLuYCBUDItSsTiYFjSrS52joXk1GvJWzCRIxpbUcZk1gagBhXVScCOaYk5ByimRGYmB5AvJScZ)vf5sSIMaWPjYQMiBRUiREuBfal(LvmsrBft6o(f7yLvQnePACfR2ICPsTlRqVvJLrJ5bqDm3oXjwPgSASfmOSs41QxazvNWL0hncnViq)HmbyIp1DG(dugY4zwPr)n6a9mRAIST6IE1CBfrQQyv(wfVAyLdIvc9diunNY3hZTtCIvQbRgRPlXkM0D8l2bHLhuoDjqRyaKKiyBfal(Lv4Qf9Wk0B1wajqRAI8TIUwjVmecZkqrtyLg9xGOpGYPlpOOj8nH4ryDm3MBN4eRuJyjAGwUwrjBeuSsJgOY2kkzfp7y1yxRfYMz1JE1arch2atRsDhONzf6NooM7u3b6zhsOOrduztRcv2tHrOH5Un3PUd0ZoKqrJgOYMwfQqH6Ekx)EMoKlO4x(gHv8M7u3b6zhsOOrduztRcv2tHrOH5Un3PUd0ZoKqrJgOYMwfQOjcpfaK1M7u3b6zhsOOrduztRcv0eHhuQQyUn3oXjwPgXs0aTCTsuvGoSQJbXQMqSk1ncAvWSkvnJzsnLJ5o1DGEMcgPKqpr(xpRHHlXCBUtDhONrRcvibGX2r8lpfua5CSvWKUJFXoKaWy7WVrqVwMcRJCIby7yq8nYpKy51ejCjm6S03ZqIfMWefWEFibGXoKRxtehasmOa27djam2HC9AI4aLHmEgDg)m6ix67ziXcmyctAeAErG(JwMcRJC6PGcOdugY4z0rPrU03ZqIfgAIeUeMFdtDhOpNQp(zuZDQ7a9mAvOIwMcRJC6PGciNJTckG9(qcaJDixVMioaKM7u3b6z0QqLBoqkVNiHdohBfesoBIdPUPd9CumIxJgIF5V5qUepDzQti5SjodjwJeSkFuIwWQ8rPrUGiasWagmOa27Zgb7y7i(LNckGoxeO3CN6oqpJwfQSrWo2oIF5PGciNJTccjNnXHu30zuLXiEnAi(L)Md5s80LPoHKZM4mKynsWQ8rjAbRYhLg5cIaibdyWaSua795MdKY7js4W5Ia9GXCBUtDhONrRcvyKsc9e5F9SggUeNJTIoHlPpxHcyVp6K1XVoqj1T5o1DGEgTkubGj(OLbN)CquKmcvZxyEy6ue0RrWC6CSvCfkG9(atNIGEncMt)vOa27Zfb6XeMUcfWEF0O)cO7qvXhVl)vOa27dajgDcxsFiKC2ehsDth6ooMWuhdIVr(Bi0rjLn3PUd0ZOvHkamXhTm48NdIIluY7oGIxvHXKP5o1DGEgTkubGj(OLbM5o1DGEgTkuHe1b6n3PUd0ZOvHkute663aqhM7u3b6z0QqfkbYeOR4xM7u3b6z0QqLzSiAMNEbURb5BZDQ7a9mAvOYoGc1eHUM7u3b6z0QqL81cRH50RZ50CN6oqpJwfQqLlpA7ByODXm3PUd0ZOvHkXRkYL4)aWPjY3eINAMAxEewohBfDcxsF6yq8nYFdrD6ddncnViq)HeagBhXV8uqb0rtKWLW8ByQ7a95KokzUtDhONrRcvAeGMWJ2(RKnHZXwrNWL0hcjNnXHu30rX4JIjm1jCj9HqYztC0aqO8nDiKC2eNHelZDQ7a9mAvOcijjrpZJ2Ee8kqZDQ7a9mAvOYoNt59i4vGM7u3b6z0Qqfk0lxaw7PGciNJTcm7vOa27df6LlaR9uqbK)kua79bG0CBUDIvygMyLg97ybaLRvKaWy7WZ6CTeOxdaHeKwTHObRahkGgswlqRqKDGE2XCN6oqpJwfQqcaJTJ4xEkOaY5yRGjDh)IDibGX2HN15AjqVgacjivxzmwqeajgSoxlbEi1T6kys3XVyhsaySD4zDUwc0RbGqcsZTtScZWeR0OFhlaOCTIeagBhEwNRLa9AaiKG0Qnenyf4qb0qYAbAfISd0ZoM7u3b6z0QqfsaySDe)YtbfqohBfmP74xSdjam2o8Soxlb61aqibP6kJbdnryW6CTe4Hu3QRGjDh)IDibGX2HN15AjqVgacjihPYNrn3MBNyfMHjwPr)owaq5Afjam2o8Soxlb6hsSiiTAdrdwbouanKSwGwHi7a9SJ5o1DGEgTkuHeagBhXV8uqbKZXwbt6o(f7qcaJTdpRZ1sG(Helcs1vgJfebqIbRZ1sGhsDRUcM0D8l2HeagBhEwNRLa9djweKMBNyfMHjwPr)owaq5Afjam2o8Soxlb6hsSiiTAdrdwbouanKSwGwHi7a9SJ5o1DGEgTkuHeagBhXV8uqbKZXwbt6o(f7qcaJTdpRZ1sG(Helcs1vgdgAIWG15AjWdPUvxbt6o(f7qcaJTdpRZ1sG(HelcYrQ8zuZT52jwPwjRTsTb3Qlam(LvnHyfnbGttKvGI)Ia5SvuaTvOF6WQyBfu0Y3thwre9XCN6oqpJwfQqcaJTJ4xEkOaY5yRG15AjWtoGa(UrnQZjPUvxHYh6jgGvJqZlc0FIxvKlX)bGttKVjep1m1U8iSoqziJNrNrXeMOa27t8QICj(paCAI8nH4PMP2LhH1bGemMBZTtScVZ1sGwnIyfABLskBfOyoTYvmNw5abyv8wP0zuRyIg9xMvGIMab0wri5m(LviOvKaWy7i(1XkRWmm5Afic5TIeagBhEwNRLa9AaiKG0Q8VwnKyrqAvcfRUblPMY9yUtDhONrRcvibGX2r8lpfua5CSvWKUJFXoKaWy7WZ6CTeOxdaHeKkugdM0D8l2HeagBhEwNRLa9djweKkugJfebqIbRZ1sGhsDRUskBUDIv4DUwc0QreRqBRgxzRafZPvUI50khiaRI3QrTIjA0FzwbkAceqBfHKZ4xwHGwrcaJTJ4xhRScZWKRvGiK3ksaySD4zDUwc0RbGqcsRY)A1qIfbPvjuS6gSKAk3J5o1DGEgTkuHeagBhXV8uqbKZXwbt6o(f7qcaJTdpRZ1sGEnaesqQqzmys3XVyhsaySD4zDUwc0pKyrqQqzmyOjcdwNRLapK6w9Xv2CBUDIvJnGbsRuBWTstKWLWSQrGs4Lzvtiwj)1k02kAcaNMOrSv57OjIFzvWSIs6wGw1e5B1JAI4xhZDQ7a9mAvOcjam2oIF5PGciNJTckG9(eVQixI)daNMiFtiEQzQD5ryDaiXGcyVpXRkYL4)aWPjY3eINAMAxEewhOmKXZOdMZCBUDIvJDvrX1kDssg)YknrcxcZzROaARirOPvAIeUeMvmceSNoSIs2iOyfnbGttKvA0GWScG0Q8VwLZjcKvxGbY4xw1iRsvrX1kDssg)YQlam(Lv0eaonrhZDQ7a9mAvOcjam2oIF5PGciNJTcncnViq)HeagBhXV8uqb0rtKWLW8ByQ7a95uDfJFWCyawncnViq)jEvrUe)haonr(Mq8uZu7YJW6aLHmEM6JRmMWefWEFIxvKlX)bGttKVjep1m1U8iSoaKGXCBUDIvGptTlRutyzf4qbKvbZknaekFpDyfatUw1iRKOjeOvqHCkFWiSIckGywrLm5Af6TAkmMvnr(wrKZTvPvuqbKvAIeUeRsvZyMutXzRqqRMiqwjVaxoSQrwjFsnfROhYYk8HKryUtDhONrRcvOMP2LhHLNckGCo2k0i08Ia9hsaySDe)YtbfqhnrcxcZVHPUd0Nt6O8zuZDQ7a9mAvOc1m1U8iS8uqbKZXwbyLxGlh0cw5f4YXbkl5hPgHMxeO)4swE2qYioqziJNbgWqNXOmgua79HAMAxiG2RrduOZfb6XqJqZlc0FCjlpBizehasZT52jwH5j5m(LvQXzGvan3PUd0ZOvHkcwKY0tKWbNJTccjNnXHu30z0rsi5m(LNrsiq5OraFJjmbwcjNXV8mscbkhnc4B1vqxmiKC2ehsDtNrvgmM7u3b6z0QqfcjNXV8YmWkGohBfesoBIdPUPdDPR52CN6oqpJwfQSNcJqdZD7CSvOrO5fb6puOxUaS2tbfqhOmKXZOZyWGHaMuXFpKaSgykEbcq2b6pYNut5AUn3oXk10ElpluvMoC2QMqSASR2Jfwrcdem6WPcZk6bUvO3k9usvfNTcCeUvYKjoBfOOjSsEbUCyfJu(RazwL)1k9LzfdbB5AfLmrGm3PUd0ZOvHkUKLNnKmcNJTcgPmN(oHlPzQRqjZDQ7a9mAvOYoLz8IN1ObsNJTcgPmN(oHlPzQRqjZT52jwPwjRTIEGBv2w1isRiHbYQlam(Lv0FKAYkkG9(yUtDhONrRcvCjlpBizeohBfua79bKKKON5rBpcEf4bG0CBUDIvQLmfwh50kWHciRiHbcgTdRariVOQaTkARAeYLvSy9Xo053wDZHCjwL)1QaIEMR4TIckGSIcyVTkywnemw8lRaBEPxawBvtiwri5SjodjwwPrYEh6q(2QuRrWB8lRAKvX3YZI2HvOTv3CixIvD6sEW4Sv5FTQrwDbgiTsWslmMvAIeUeMvuYgbfRahb(XCN6oqpJwfQOLPW6iNEkOaY5yROZ3v8lmOa27d1m1UqaTxJgOqNlc0Jr8A0q8l)nhYL4vAegHryGPoyjKC2eNHeRrQ8r5rPL15AjWZmzTVdTl)nhYL4hdyWGcyVpYeGfQkEkycAkWdRtTl6OK5o1DGEgTkurltH1ro9uqbKZXwrNVR4xyqbS3hsaySd561eXbGedWsbS3hsaySd561eXbkdz8m6m(z0rU0xmHjncnViq)HeagBhXV8uqb0bkdz8m1Pa27djam2HC9AI4aLHmEgym3M7u3b6z0QqLR0iSm3M7u3b6z0QqfiaJi(LNEZR4bf)15yRGrkZPVt4sAM6kucdkG9(abyeXV80BEfpO4VNlc0BUtDhONrRcv6yjqpzohCo2k6CkFFGamI4xE6nVIhu83J8j1uUyqbS3hQzQDHaAVgnqHoaKyqbS3hiaJi(LNEZR4bf)9aqAUtDhONrRcvOGs2eE02VdO4CSvqbS3hnrcHY1tMmwGE25Ia9yabEzJGl5OjsiuUEYKXc0Zoc9diijLR5o1DGEgTkuHAMAxiG27k0Um3PUd0ZOvHkUKLNnKmcZDQ7a9mAvOIMi8uaqw7CSvOrO5fb6p7uMXlEwJgipqziJNPUsyWiL503jCjntDfkzUtDhONrRcv2PmJx8SgnqAUtDhONrRcveSiLPNiHdohBfua79zf72J2(Mq8iSoSo1UuxbDn3PUd0ZOvHkncqt4rB)vYMWCN6oqpJwfQabyeXV80BEfpO4VohBfua79bcWiIF5P38kEqXFpxeO3CN6oqpJwfQWiJ)JF51W8fVRq7Y5yRGcyVpAIecLRNmzSa9SdaP5o1DGEgTkurJET8nmB563ZCqCo2kUO(OrVw(gMTC97zoihOmKXZuOS5o1DGEgTkuHckzt4rB)oGIZXwbfWEFOMP2fcO9A0af6CrGEmalfWEFOMi0DcW6Zfb6XeMalfWEFOMi0DcW6dajgxuFOGs2eE02VdO4VO(aLnuyej1uadym3PUd0ZOvHkescBVWyYRfNJTcmRWyYRLttiEneqhutXJ2(9mhKZqsViO5o1DGEgTkurteEkaiRn3PUd0ZOvHkAIWdkvvm3PUd0ZOvHkcwKt0n(L3LSm3oXk1iwKY0kmVeoyfrYSIiwec0QXMARgX2QMiFRWwTTceH8w5abyfrQQyv2wnLK1wPKviif7yUtDhONrRcveSiLPNiHdohBfua79zf72J2(Mq8iSoSo1UuxHsMBNyLALS2kC1IEyvSTsEeWIWk5LHqywLqXQeIa(RZwHGwfBRO)0F6p2QjRcMvYNut5EScBIGzvWSkTInJfrB1v2YZcvfRMigZkKQc0kaw8lRWwTTIcOTAjVaZ50Hvq5cOfMvSyWkvtyKVwSAabfRAI8TkFhnr8lRKjtoM7u3b6z0Qqfgz8F8lVgMV4DfAxohBfywiWlBeCjhgrIiseZpelI(i0pGGKuUya2u3HQIxEzieM6kOlMWet6o(f7GWYdkNUeigA0FbI(akNU8GIMW3eIhH1r(KAkxWGHgHMxeO)4swE2qYioqziJNP(sFXaSYlWLdAbR8cC54aLL8JeSAeAErG(Jlz5zdjJ4aLHmEgTcwIgOfFhdcyadyuxb9nkgGfZ25u((WiJEhq5iFsnLlMWeMfc8YgbxYrtKqOC9KjJfONDe6hqqskxWyUtDhONrRcv6yjqpzohCo2kWSDoLVpuZu7cb0EnAGcHHgHMxeO)4swE2qYioqziJNP(sFXaSYlWLdAbR8cC54aLL8JeSAeAErG(Jlz5zdjJ4aLHmEgTl9fmGbmQRG(g1CN6oqpJwfQKqD(IVrqO8TZXwH8cC5Go0DCZDQ7a9mAvOYEkmcnm3TZXwbdbmPI)EufnZoMINHMQkFFKpPMY1CN6oqpJwfQabyeXV80BEfpO4VCCgPO50Oe9H54nV5Ca]] )


end