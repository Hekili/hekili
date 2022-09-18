-- MonkBrewmaster.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

if Hekili.IsDragonflight() then return end

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
        chi_torpedo = { -- Movement buff.
            id = 119085,
            duration = 10,
            max_stack = 2
        },
        --[[ chi_torpedo_115008 = { -- TODO: Actual duration of a Chi Torpedo roll?
            id = 115008,
            duration = 1.1,
            max_stack = 1
        }, ]]
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



    spec:RegisterPack( "Brewmaster", 20220821, [[Hekili:LVr)Znno2)w6SZfskSM8rtPW0KzawMDHDxG5k3W9tXrXwjXuhlFwY9JD6K)2V3ts2wY2kjLLLP7DdLsIT0tVV)spMny2NMDrirqN9(H9hoS)zdh4n4SXpF0Sle3MsNDrkj4sYk4djKnWVFvg96neUGMHV62ygjeHaNLNfaVETqKYFXtF6QiX68fEbSnpLhTjpMiIyjbzKLc87bpD2flYJIfVnz2Iwp(HNo7csUyndoMlI28AaYrHHu1YP8atez78FNLC5239Y8v5CX25dE2t2ohH223T9DVEnjzfL)ITV7h3o)5Ed2opkjiohGX25FmplA5TrjR2ohH2250erwe(MmkGX0WTZfSTZFBYvSlPBN)(O8)GaFxSMaNsi8Peg8HCUec8uAa8BQqaFL7TDoa)m2vrHWoxsPHla(425SKTZ)5iXVa8gjg9tr8m6ksgCujigiizROcGVXIdzxN4LsY5uFsaY(8YOBirja6fWscJWhXRWMKhb)ZAYvWXrsqQ8hxbcmGM(p5rxrIbstDI)obPLs8KDJ)1K4lrUippnLLvrrx86FvHWlPxJVhoj4lJq2eDJKnDniLvytEKWdHJp(iFXAQp7gVzxehXfCPggDjjpwaF89snoffb6nPusMpa4qFoW7VeuHOjKfX0WzVAMaukWfx9KlcYIajEeb2zbfKkLI(lzz(b0ykxerI3oVZ25DbuoAd1xW83qUXpynYBbS(8TZxfe6bpB787UB78f5lxQGsenewwKxEQeanFrPeaGXaVXBNFSbS6PaxPSReB8xaAxw7DO9oHZsJD(lZuSgKgMkpKkMvAH(QeGi7zKt2tBevfKSrnesN4esRPKyXAV0aHe1F2yj(cwrSniQes2aUh8hXL4REXsQ6yPiOVhqSpU6JiDNXqoCp5pf8zq(jmOopKfwHWWPKstafLSni2o(qX2X9)MJTD1iSbkjrw49v4BnQbX5tDIZAJ(qQeUbGtnyFG(caSDzPaW8z1GPYh9xyICWPxuwMFikMtUL7hqIJRaMZvaW8SAWSebcizCF2suffqCqdvIilPMKYrAMJZf7FsH1fABQ0XlWB3NaGwp3bAfqcqVnlbNKGNUmqzxaCoEEgL3WEOCjKBOs0qA(Z4CjcTmA1AHVLz64cuBxNcGCd67a7YqnayBbS4ysk6x1FzUOvKtq3KkKXj1Qt7b5g1Va52XHG4MLdxmCcCSB41C0oyO5QszQ)1EjJmxYIygleoNSBRVStSwgnJtZUeWP6lBS5YIrYJ7)L8WvBGqv1x7PMRDjW)LNE9v9mZvrscan7mqhsP6BV0ZSWrIK9bQAbx2GVuxVRHzBrmMWiL68Pk)5LrWTCA71MFEutRcBIKPB4NiZ2qgdSUYvduWYP3eWIASs7X(1b5zzaVvEEvE(QoyblpynYicPeXA5jBP6CnLKcPCGRGLfIjaAhQ2sdAjW0bVJTUq3rTa3hAVGlyj0qiDojxZx)qZqywlqc26HWCe2uM)ywuQ6L)lovMbdyFbgmqAy60j4cYQvuiLcGPTg8uSmJTrLMyrsNmje4E7kPK6qbupubK0bvGpPxIs4nDIrQzTcdjLwp83dzkLZIzFneQm2BFi9hKGRh78Bcbdk))5Pxnq(ZiyLGqsM1dN)WLmV)svnemeQUs0yNu7RjyjEF8vGJI8mzzkqXgv1MDDuc419jywicS4L4BHK)wIf0faU(WVTgQuXII1eazdlpriyWFiXLutFVNvK0xPhDlh0YADwedf3Hv8ygFESr1f7ylYClL8dxz4St(Xfk0F78)bqUlX6ErMqmev5s5VVLLJP)cValxHtXI10vUXqwegiqYgzzfAoyYNy5RGIfOnD9AAItFfq2OBNRLSKmqoegXL4)bPuvaLjLAv7w3zY(mYqYxwwKR0XUxSYbUyL)VdJ0Hzms7s(4GVg(4pLVjvzIwwYTGDnjlKRnwPiXICyLv7lqY)wXAj3lcw0ca7RA4qct(kVgjmVhJQo732Z0C9mjbxVFdheb)YRyraffqstL0GMSl8cLcoom4f81qTHONOfuOkrdFxqjQ47ZluhGmOyxJ(52Oal2lksTJQWjOcgw8O7tgOORUbEN9v5QBQYs5E5RBu9uaRQQqT02yZVkw2cTpCtr76qDfDsTi)mNx0XokyuIkqz0uij0i(Aa1GDGQwe5IWUAft58cDS1KyqDKOwwHSc52KOyehFIYSwkpOj0Sv3QpijfSD(VsX(Lbbwx)1kboVmU4i3TIPB1PR6rH6BGSyf6B5ydj3L0v(CeHQeuQoyah0j9RSoKmCWbgu84MfmDLNDAfqwzFBjNqS2voP0BsPXQg3ylo)LchMVjo6MOSD1ehjPPDW6Ztbzl1ladxRu7666LOA9ij50sBHukIU7ktTTaQSL0uXPrvyocN6PU1IwGvflw(Eor7mopEbK)cOUWf5XuFAwUKx5va3QQRaL31Y2PlpCxzsvk7QX6)WYL0eE0v04BFI2N8l)4VbEQYIyaEh9hOFOF9cLDsqmLCfAb8kg8eAmh)SQZVfkJ8uWLouOV2Xva6PNdE5qtTfuWQXkigOpe7RknLRKrdLuH7kTBDlgLAcYHekeKJTrMh9jUc)7IFOsQejySx6cwQIvu5E9ZSpOTxAefQEvXOzcIdUcDwR1R1qKQgyRCXPLi3QsFGEf6vlsIJmWvipAvs0YOacQSRATPweeLb40LyYkkpAiQQCyUjIRAVFxs4xK3xIu(B2k0agDja1izZcibbaDvgakkrGQoigHrWloub5sAsVNOpDbtf2c0qUjq6MTm6xrqVxXELNDNmsUuEi7ZXu9w5o85p)5BuHH62OJU996pw6RSi)Myqs7lIaFx6TFIvtOPX5OzbiAixhdlh2ggY5CTk6jUVoIg4V0NFTluO794ofQDzc1cHyg9DhGSNt9oKAS6NxivWUPwNAoXDOO2mjRi(SCoMZM)xiHuFSMSATZVX7LNM7U6luxGvtWQxTt1gZebBUBZiAIimb5usS8cgoXDCbvt6b9zSlWPeWAclIUu)mlpbvXxrBUg8Q4stn9JdIcIq2ZnSPMYd2QjMLuZLGkBDHJvpmnCTzVk3Evl1TSCGAPAPeP729lOW5VipJldfnUVDtan9mBJyJR7GSghEv0sHSRSQ7suBjkJO3AYfiiT6azT2zw703ZnN9vPap2T5s7knM6FCiH(eeKqyDGLjf4imDBueYWlkobBSbEFjH(lJjBOvYpSkpdXuJvkb)E0ZD5fUBP5gJfconfg3zrZ3PTcre2wJ3hFugDzgKoJkt6EwoTAAFm2DIwhbHB4CkqMEOstqwEqeSk5ULCMnKVGZtGrwCzcF9wKW2YIQsVUMQZZRVQRH8JQTOtTSda10yggd1hmtRVsxjk4mX53GVy78FbEdw5ch7P1kz9o)0hFZNkkP5tFSOLdY(wONmabw3JmBNHyjnl4ntOXTHNmg4PUkrUnf42sZsowbyp5OjS8vRngNazJpizqU7H6cUWL95p)5p9bvUl6t1dOU143X)cfTXL3EeE1b60AXk1WSoyY8L0JZaYqK1JVctBfkU(wSaXW8azr5raV8kcWfaDbijjzokkgzvVjWCF9QPXv5Uh0GzWpC)ni2u6SVWCbztqMfLeRU2e0GPTHXOZoMRIYGE9CvQMPpCzUeDmkx0zXJD3nSEmMohnixq9v3DBVIFqA50XfNYry6GY41GkHanCRWyKCp6GcsQlq70DEzr6ZPMxkZKc(oYCKWQgpXv(fN6ourbEG1CoOA)KSa0SsWK97qcd3HgklL8kgo6vGtqol(kKvvSChLsEQ1nT2mkNLVlWZyAgf55KMt2ZcMqeRc1Cln8AemqcMrj1C)zFPHv4I9QC1Ui3t6qZRi5DLRflRI(JP5XXE7DKje6rJzVrf2Fqbjdd8iH656XDBuFirQRjzOFt(Sl(8l)NV)TV)NFb204pHvLfTrnrwlrNHpspevpc9BPMcbSmB0sKKdzyPMyTa1aV5T9D)gK6fOdoca3RzjWblF)J02m)7hPQtR87fQgWZ7o4MEE40Z9w55JBBOYdMSXz4qDbVgL(SLGY1Sl(HFW(QLudKh(0whkp8fvdMh(ThEdNNgR(opGE6t974q6vipEJY1Eyvj6kdB87RaIcyAVmiGMIvaKWs(rmXKL5XfQfC1TTbGt)DVsxdpEYtD5mO9vx5gaqn51N4W6T9TxmIlpbnTN4YYU99wAE7(1OHnY0QZ2WMZCBXynj7PcabzsmCJojxHZtAmrxim1Veol7k(Fs0Yj7CKh70TLHD8C9igE3DT1tIoo7CW5d8gFSEV9U7U9msJNpSyTDA2A7PypnmilBqGKvRTlXyhgdAhU8Q(YE(Zg3P5K9nTQhqh3TV3WhJ)6y5vg2RNIKBBwdnpXAVV2PoU)9(u7kp26tmypBbEd9b8C3XSbAU37PoFJD4C07qC4i5zV7r6RdQ9nDG7tyhtqxPsqT5Zd0AH047yn6BNpCS7ZW9GWvEe1MYUwpIr9B7i4wgNYbKZ8jvZdN1tlh)nZNwBA3Su9kgUnZhAplBwW3C01mFH7BHZqRYy01MEANd)6QoFO5rz3OfdWByZmzW47UR1Xr7CJw2Aa06Tv3IhzmBzwmdZlyrQ4U7Hjt6dxhF5p1GrD)CBBd3P97i9s0X4k4NUN98WaTXHh4(G1h3hJeCq4(ENzPVouxc27hdxHjpaW5dNBl3HbZ(BYitThK3XqunDsFVN1P79yEcoFSoxLDogb90K2d1PF6RtuRG7eqwVlj7K20FbcVn(XdJry6VyUrdldGQvQh)fnjs7ME2V2BN9TKcBHZ00XdNbmA3K(HNbX0jd8o7E5yaKQ3hpd)TyyHSZF0yIAUFmZZ7BxIvdq1vHgpURzxnp2D7m7178t63X1fa1P1zdsZ3RnvpMOv1fAuVGQJBB8DU7UUT94Ptg1XQySEMNH9K5u7CgnYUGRQ(myXVBDoDo)Ko7D(C0SGV7txJjnvksKUwnV42PtgANeTXDZ2(InYE4GMngN4H8TTmOmfhX)xn1lMCPMndrphjUn(AF(xM21O)d4uV8y3t8IUjiToRl2v2Th0t6yYODsD3B)KmALunVAfE5DcIAnlroUk2pQXTv0MwDNDC9(wf1wEDnkYE3ZFsRIRIa9Tn3jwURTUK7s7LwhXKohYnNvpuqXaK0Q9PL8UO7Nw(dBD8qMoSZb7DXDqaNx4m4L3Dlg2Rq)aLXTCJ1U5(2YSMttbUZDprgt6Fas92m57QFJ5OwarhR9uqDB)dyrV6rlRMaczdtoGbOOvfM6pu1KClXE1eqiD6)TDkg(QuXgAeG7V5tLWbOwF0EhvHoDrGunKcGr4D318sO6SVbtOxBziw43aIc0P98r76Exp2CWd61R30jNoUt3JCmMb3D3rhGBYEUD3FuRZvW3EQc2LMymXf7B6hXhfapF0a3zVU3B8FNonLZZza(F0YZKxt9S)l]] )


end