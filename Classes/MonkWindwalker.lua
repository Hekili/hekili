-- MonkWindwalker.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [-] calculated_strikes
-- [-] coordinated_offensive (aura)
-- [-] inner_fury
-- [x] xuens_bond


if UnitClassBase( 'player' ) == 'MONK' then
    local spec = Hekili:NewSpecialization( 269 )

    spec:RegisterResource( Enum.PowerType.Energy, {
        crackling_jade_lightning = {
            aura = 'crackling_jade_lightning',
            debuff = true,

            last = function ()
                local app = state.debuff.crackling_jade_lightning.applied
                local t = state.query_time

                return app + floor( ( t - app ) / state.haste ) * state.haste
            end,

            stop = function( x )
                return x < class.abilities.crackling_jade_lightning.spendPerSec
            end,

            interval = function () return state.haste end,
            value = function () return class.abilities.crackling_jade_lightning.spendPerSec end,
        },

        energizing_elixir = {
            aura = "energizing_elixir",

            last = function ()
                local app = state.buff.energizing_elixir.applied
                local t = state.query_time

                return app + floor( ( t - app ) / 1.5 ) * 1.5
            end,

            interval = 1.5,
            value = 15
        }
    } )

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

        ascension = 22098, -- 115396
        fist_of_the_white_tiger = 19771, -- 261947
        energizing_elixir = 22096, -- 115288

        tiger_tail_sweep = 19993, -- 264348
        good_karma = 23364, -- 280195
        ring_of_peace = 19995, -- 116844

        inner_strength = 23258, -- 261767
        diffuse_magic = 20173, -- 122783
        dampen_harm = 20175, -- 122278

        hit_combo = 22093, -- 196740
        rushing_jade_wind = 23122, -- 116847
        dance_of_chiji = 22102, -- 325201

        spiritual_focus = 22107, -- 280197
        whirling_dragon_punch = 22105, -- 152175
        serenity = 21191, -- 152173
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( {
        alpha_tiger = 3734, -- 287503
        disabling_reach = 3050, -- 201769
        grapple_weapon = 3052, -- 233759
        perpetual_paralysis = 5448, -- 357495
        pressure_points = 3744, -- 345829
        reverse_harm = 852, -- 342928
        ride_the_wind = 77, -- 201372
        tigereye_brew = 675, -- 247483
        turbo_fists = 3745, -- 287681
        wind_waker = 3737, -- 357633
    } )

    -- Auras
    spec:RegisterAuras( {
        bok_proc = {
            id = 116768,
            type = "Magic",
            max_stack = 1,
        },
        chi_torpedo = {
            id = 119085,
            duration = 10,
            max_stack = 2,
        },
        crackling_jade_lightning = {
            id = 117952,
            duration = 4,
            max_stack = 1,
        },
        dance_of_chiji = {
            id = 325202,
            duration = 15,
            max_stack = 1,
        },
        dampen_harm = {
            id = 122278,
            duration = 10,
            max_stack = 1,
        },
        diffuse_magic = {
            id = 122783,
            duration = 6,
            max_stack = 1,
        },
        disable = {
            id = 116095,
            duration = 15,
            max_stack = 1,
        },
        disable_root = {
            id = 116706,
            duration = 8,
            max_stack = 1,
        },
        energizing_elixir = {
            id = 115288,
            duration = 5,
            max_stack = 1,
        },
        exit_strategy = {
            id = 289324,
            duration = 2,
            max_stack = 1
        },
        eye_of_the_tiger = {
            id = 196608,
            duration = 8
        },
        fists_of_fury = {
            id = 113656,
            duration = function () return 4 * haste end,
            max_stack = 1,
        },
        flying_serpent_kick = {
            name = "Flying Serpent Kick",
            duration = 2,
            generate = function ()
                local cast = rawget( class.abilities.flying_serpent_kick, "lastCast" ) or 0
                local up = cast + 2 > query_time

                local fsk = buff.flying_serpent_kick
                fsk.name = "Flying Serpent Kick"

                if up then
                    fsk.count = 1
                    fsk.expires = cast + 2
                    fsk.applied = cast
                    fsk.caster = "player"
                    return
                end
                fsk.count = 0
                fsk.expires = 0
                fsk.applied = 0
                fsk.caster = "nobody"
            end,
        },
        hit_combo = {
            id = 196741,
            duration = 10,
            max_stack = 6,
        },
        inner_strength = {
            id = 261769,
            duration = 5,
            max_stack = 5,
        },
        leg_sweep = {
            id = 119381,
            duration = 3,
            max_stack = 1,
        },
        mark_of_the_crane = {
            id = 228287,
            duration = 15,
            max_stack = 1,
        },
        mortal_wounds = {
            id = 115804,
            duration = 10,
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
            id = 115546,
            duration = 8,
        },
        ring_of_peace = {
            id = 116844,
            duration = 5
        },
        rising_sun_kick = {
            id = 107428,
            duration = 10,
        },
        rushing_jade_wind = {
            id = 116847,
            duration = function () return 6 * haste end,
            max_stack = 1,
            dot = "buff",
        },
        serenity = {
            id = 152173,
            duration = 12,
            max_stack = 1,
        },
        spinning_crane_kick = {
            id = 101546,
            duration = function () return 1.5 * haste end,
            max_stack = 1,
        },
        storm_earth_and_fire = {
            id = 137639,
            duration = 15,
            max_stack = 1,
        },
        tigers_lust = {
            id = 116841,
            duration = 6,
            max_stack = 1,
        },
        touch_of_death = {
            id = 115080,
            duration = 8
        },
        touch_of_karma = {
            id = 125174,
            duration = 10,
        },
        touch_of_karma_debuff = {
            id = 122470,
            duration = 10,
        },
        transcendence = {
            id = 101643,
            duration = 900,
        },
        transcendence_transfer = {
            id = 119996,
        },
        whirling_dragon_punch = {
            id = 196742,
            duration = function () return action.rising_sun_kick.cooldown end,
            max_stack = 1,
        },
        windwalking = {
            id = 166646,
            duration = 3600,
            max_stack = 1,
        },
        zen_flight = {
            id = 125883,
            duration = 3600,
            max_stack = 1,
        },
        zen_pilgrimage = {
            id = 126892,
        },

        -- PvP Talents
        alpha_tiger = {
            id = 287504,
            duration = 8,
            max_stack = 1,
        },

        fortifying_brew = {
            id = 201318,
            duration = 15,
            max_stack = 1,
        },

        grapple_weapon = {
            id = 233759,
            duration = 6,
            max_stack = 1,
        },

        heavyhanded_strikes = {
            id = 201787,
            duration = 2,
            max_stack = 1,
        },

        ride_the_wind = {
            id = 201447,
            duration = 3600,
            max_stack = 1,
        },

        tigereye_brew_stack = {
            id = 248646,
            duration = 120,
            max_stack = 20,
        },

        tigereye_brew = {
            id = 247483,
            duration = 20,
            max_stack = 1
        },

        wind_waker = {
            id = 290500,
            duration = 4,
            max_stack = 1,
        },


        -- Azerite Powers
        dance_of_chiji_azerite = {
            id = 286587,
            duration = 15,
            max_stack = 1
        },

        fury_of_xuen = {
            id = 287062,
            duration = 20,
            max_stack = 67,
        },

        fury_of_xuen_haste = {
            id = 287063,
            duration = 8,
            max_stack = 1,
        },

        recently_challenged = {
            id = 290512,
            duration = 30,
            max_stack = 1
        },

        sunrise_technique = {
            id = 273298,
            duration = 15,
            max_stack = 1
        },


        -- Legendaries
        invokers_delight = {
            id = 338321,
            duration = 15,
            max_stack = 1
        },

        pressure_point = {
            id = 337482,
            duration = 5,
            max_stack = 1,
            generate = function( t, auraType )
                local lastCast, castTime = action.fists_of_fury.lastCast, action.fists_of_fury.cast

                if query_time - lastCast < castTime + 5 then
                    t.count = 1
                    t.expires = lastCast + castTime + 5
                    t.applied = lastCast + castTime
                    t.caster = "player"

                    return
                end

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end,
        },

        -- Jade Ignition
        chi_energy = {
            id = 337571,
            duration = 45,
            max_stack = 30
        },

        the_emperors_capacitor = {
            id = 337291,
            duration = 3600,
            max_stack = 20,
        },
    } )


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364418, "tier28_4pc", 363734 )
    -- 2-Set - Fists of Primordium - Increases Fists of Fury damage by 40%.
    -- 4-Set - Primordial Potential - After 10 offensive abilities, your next 3 offensive abilities deal an additional 22% damage.
    spec:RegisterAuras( {
        primordial_potential = {
            id = 363911,
            duration = 10,
            max_stack = 10
        },
        primordial_power = {
            id = 363924,
            duration = 10,
            max_stack = 3
        }
    } )

    spec:RegisterGear( 'tier19', 138325, 138328, 138331, 138334, 138337, 138367 )
    spec:RegisterGear( 'tier20', 147154, 147156, 147152, 147151, 147153, 147155 )
    spec:RegisterGear( 'tier21', 152145, 152147, 152143, 152142, 152144, 152146 )
    spec:RegisterGear( 'class', 139731, 139732, 139733, 139734, 139735, 139736, 139737, 139738 )

    spec:RegisterGear( 'cenedril_reflector_of_hatred', 137019 )
    spec:RegisterGear( 'cinidaria_the_symbiote', 133976 )
    spec:RegisterGear( 'drinking_horn_cover', 137097 )
    spec:RegisterGear( 'firestone_walkers', 137027 )
    spec:RegisterGear( 'fundamental_observation', 137063 )
    spec:RegisterGear( 'gai_plins_soothing_sash', 137079 )
    spec:RegisterGear( 'hidden_masters_forbidden_touch', 137057 )
    spec:RegisterGear( 'jewel_of_the_lost_abbey', 137044 )
    spec:RegisterGear( 'katsuos_eclipse', 137029 )
    spec:RegisterGear( 'march_of_the_legion', 137220 )
    spec:RegisterGear( 'prydaz_xavarics_magnum_opus', 132444 )
    spec:RegisterGear( 'salsalabims_lost_tunic', 137016 )
    spec:RegisterGear( 'sephuzs_secret', 132452 )
    spec:RegisterGear( 'the_emperors_capacitor', 144239 )

    spec:RegisterGear( 'soul_of_the_grandmaster', 151643 )
    spec:RegisterGear( 'stormstouts_last_gasp', 151788 )
    spec:RegisterGear( 'the_wind_blows', 151811 )


    spec:RegisterStateTable( "combos", {
        blackout_kick = true,
        chi_burst = true,
        chi_wave = true,
        crackling_jade_lightning = true,
        expel_harm = true,
        faeline_stomp = true,
        fist_of_the_white_tiger = true,
        fists_of_fury = true,
        flying_serpent_kick = true,
        rising_sun_kick = true,
        spinning_crane_kick = true,
        tiger_palm = true,
        touch_of_death = true,
        whirling_dragon_punch = true
    } )

    local prev_combo, actual_combo, virtual_combo

    spec:RegisterStateExpr( "last_combo", function () return virtual_combo or actual_combo end )

    spec:RegisterStateExpr( "combo_break", function ()
        return this_action == virtual_combo and combos[ virtual_combo ]
    end )

    spec:RegisterStateExpr( "combo_strike", function ()
        return not combos[ this_action ] or this_action ~= virtual_combo
    end )


    local tp_chi_pending = false

    -- If a Tiger Palm missed, pretend we never cast it.
    -- Use RegisterEvent since we're looking outside the state table.
    spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )

        if sourceGUID == state.GUID then
            local ability = class.abilities[ spellID ] and class.abilities[ spellID ].key
            if not ability then return end

            if ability == "tiger_palm" and subtype == "SPELL_MISSED" and not state.talent.hit_combo.enabled then
                if ns.castsAll[1] == "tiger_palm" then ns.castsAll[1] = "none" end
                if ns.castsAll[2] == "tiger_palm" then ns.castsAll[2] = "none" end
                if ns.castsOn[1] == "tiger_palm" then ns.castsOn[1] = "none" end
                actual_combo = "none"

                Hekili:ForceUpdate( "WW_MISSED" )

            elseif subtype == "SPELL_CAST_SUCCESS" and state.combos[ ability ] then
                prev_combo = actual_combo
                actual_combo = ability

                --[[ if ability == "tiger_palm" then
                    tp_chi_pending = true
                end ]]

            elseif subtype == "SPELL_DAMAGE" and spellID == 148187 then
                -- track the last tick.
                state.buff.rushing_jade_wind.last_tick = GetTime()

            end
        end
    end )


    local tier28_offensive_abilities = {
        blackout_kick = 1,
        breath_of_fire = 1,
        chi_burst = 1,
        chi_wave = 1,
        crackling_jade_lightning = 1,
        faeline_stomp = 1,
        fist_of_the_white_tiger = 1,
        fists_of_fury = 1,
        flying_serpent_kick = 1,
        keg_smash = 1,
        rising_sun_kick = 1,
        rushing_jade_wind = 1,
        spinning_crane_kick = 1,
        tiger_palm = 1,
        whirling_dragon_punch = 1,
    }

    spec:RegisterHook( "runHandler", function( key, noStart )
        if combos[ key ] then
            if last_combo == key then removeBuff( "hit_combo" )
            else
                if talent.hit_combo.enabled then addStack( "hit_combo", 10, 1 ) end
                if azerite.fury_of_xuen.enabled then addStack( "fury_of_xuen", nil, 1 ) end
                if conduit.xuens_bond.enabled and cooldown.invoke_xuen.remains > 0 then reduceCooldown( "invoke_xuen", 0.1 ) end
            end
            virtual_combo = key
        end

        if set_bonus.tier28_4pc > 0 and tier28_offensive_abilities[ key ] then
            if buff.primordial_power.up then
                removeStack( "primordial_power" )
            else
                addStack( "primordial_potential", nil, 1 )
                if buff.primordial_potential.stack > 9 then
                    removeBuff( "primordial_potential" )
                    applyBuff( "primordial_power", nil, 3 )
                end
            end
        end
    end )


    local chiSpent = 0

    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "chi" and amt > 0 then
            if talent.spiritual_focus.enabled then
                chiSpent = chiSpent + amt
                cooldown.storm_earth_and_fire.expires = max( 0, cooldown.storm_earth_and_fire.expires - floor( chiSpent / 2 ) )
                chiSpent = chiSpent % 2
            end

            if legendary.last_emperors_capacitor.enabled then
                addStack( "the_emperors_capacitor", nil, 1 )
            end
        end
    end )


    local noop = function () end

    local reverse_harm_target

    spec:RegisterHook( "reset_precast", function ()
        chiSpent = 0

        if actual_combo == "tiger_palm" and chi.current < 2 and now - action.tiger_palm.lastCast > 0.2 then
            actual_combo = "none"
        end

        if buff.rushing_jade_wind.up then setCooldown( "rushing_jade_wind", 0 ) end

        if buff.casting.up and buff.casting.v1 == action.spinning_crane_kick.id then
            removeBuff( "casting" )
            -- Spinning Crane Kick buff should be up.
        end

        spinning_crane_kick.count = nil

        virtual_combo = actual_combo or "no_action"
        reverse_harm_target = nil

        if not IsUsableSpell( 322109 ) then setCooldown( "touch_of_death", action.touch_of_death.cooldown ) end

        if buff.weapons_of_order_ww.up then
            state:QueueAuraExpiration( "weapons_of_order_ww", noop, buff.weapons_of_order_ww.expires )
        end
    end )


    spec:RegisterHook( "IsUsable", function( spell )
        -- Allow repeats to happen if your chi has decayed to 0.
        if talent.hit_combo.enabled and buff.hit_combo.up and ( spell ~= "tiger_palm" or chi.current > 0 ) and last_combo == spell then
            return false, "would break hit_combo"
        end
    end )


    spec:RegisterStateTable( "spinning_crane_kick", setmetatable( { onReset = function( self ) self.count = nil end },
        { __index = function( t, k )
                if k == 'count' then
                    t[ k ] = max( GetSpellCount( action.spinning_crane_kick.id ), active_dot.mark_of_the_crane )
                    return t[ k ]
                end
        end } ) )

    spec:RegisterStateExpr( "alpha_tiger_ready", function ()
        if not pvptalent.alpha_tiger.enabled then
            return false
        elseif debuff.recently_challenged.down then
            return true
        elseif cycle then return
            active_dot.recently_challenged < active_enemies
        end
        return false
    end )

    spec:RegisterStateExpr( "alpha_tiger_ready_in", function ()
        if not pvptalent.alpha_tiger.enabled then return 3600 end
        if active_dot.recently_challenged < active_enemies then return 0 end
        return debuff.recently_challenged.remains
    end )

    spec:RegisterStateFunction( "weapons_of_order", function( c )
        if c and c > 0 then
            return buff.weapons_of_order_ww.up and ( c - 1 ) or c
        end
        return c
    end )


    spec:RegisterPet( "xuen_the_white_tiger", 63508, "invoke_xuen", 24 )


    -- Abilities
    spec:RegisterAbilities( {
        blackout_kick = {
            id = 100784,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.serenity.up or buff.bok_proc.up then return 0 end
                return weapons_of_order( 1 )
            end,
            spendType = "chi",

            startsCombat = true,
            texture = 574575,

            cycle = 'mark_of_the_crane',

            handler = function ()
                if buff.bok_proc.up and buff.serenity.down then
                    removeBuff( "bok_proc" )
                    if set_bonus.tier21_4pc > 0 then gain( 1, "chi" ) end
                end

                cooldown.rising_sun_kick.expires = max( 0, cooldown.rising_sun_kick.expires - ( buff.weapons_of_order.up and 2 or 1 ) )
                cooldown.fists_of_fury.expires = max( 0, cooldown.fists_of_fury.expires - ( buff.weapons_of_order.up and 2 or 1 ) )

                if talent.eye_of_the_tiger.enabled then applyDebuff( "target", "eye_of_the_tiger" ) end
                applyDebuff( "target", "mark_of_the_crane", 15 )
            end,
        },


        chi_burst = {
            id = 123986,
            cast = function () return 1 * haste end,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 135734,

            talent = "chi_burst",

            handler = function ()
                gain( min( 2, active_enemies ), "chi" )
            end,
        },


        chi_torpedo = {
            id = 115008,
            cast = 0,
            charges = function () return legendary.roll_out.enabled and 3 or 2 end,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            startsCombat = false,
            texture = 607849,

            talent = "chi_torpedo",

            handler = function ()
                applyBuff( "chi_torpedo" )
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


        crackling_jade_lightning = {
            id = 117952,
            cast = 4,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 20 * ( 1 - ( buff.the_emperors_capacitor.stack * 0.05 ) ) end,
            spendPerSec = function () return 20 * ( 1 - ( buff.the_emperors_capacitor.stack * 0.05 ) ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 606542,

            start = function ()
                applyDebuff( "target", "crackling_jade_lightning" )
            end,

            finish = function ()
                removeBuff( "the_emperors_capacitor" )
            end
        },


        dampen_harm = {
            id = 122278,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

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

            spend = 20,
            spendType = "energy",

            startsCombat = false,
            texture = 460692,

            usable = function () return debuff.dispellable_poison.up or debuff.dispellable_disease.up end,
            handler = function ()
                removeDebuff( "player", "dispellable_poison" )
                removeDebuff( "player", "dispellable_disease" )
            end,nm
        },


        diffuse_magic = {
            id = 122783,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = true,
            texture = 775460,

            handler = function ()
                removeBuff( "dispellable_magic" )
            end,
        },


        disable = {
            id = 116095,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0,
            spendType = "energy",

            startsCombat = true,
            texture = 132316,

            handler = function ()
                if not debuff.disable.up then applyDebuff( "target", "disable" )
                else applyDebuff( "target", "disable_root" ) end
            end,
        },


        energizing_elixir = {
            id = 115288,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 608938,

            talent = "energizing_elixir",

            handler = function ()
                gain( 2, "chi" )
                applyBuff( "energizing_elixir" )
            end,
        },


        expel_harm = {
            id = 322101,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = 15,
            spendType = "energy",

            startsCombat = true,
            texture = 627486,

            handler = function ()
                gain( ( healing_sphere.count * stat.attack_power ) + stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )
                removeBuff( "gift_of_the_ox" )
                healing_sphere.count = 0

                gain( pvptalent.reverse_harm.enabled and 2 or 1, "chi" )
            end,
        },


        fist_of_the_white_tiger = {
            id = 261947,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 2065583,

            talent = "fist_of_the_white_tiger",

            handler = function ()
                gain( 3, "chi" )
            end,
        },


        fists_of_fury = {
            id = 113656,
            cast = 4,
            channeled = true,
            cooldown = function ()
                local x = 24 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            gcd = "spell",

            spend = function ()
                if buff.serenity.up then return 0 end
                return weapons_of_order( 3 )
            end,
            spendType = "chi",

            startsCombat = true,
            texture = 627606,

            cycle = "mark_of_the_crane",
            aura = "mark_of_the_crane",

            tick_time = function () return haste end,

            start = function ()
                if buff.fury_of_xuen.stack >= 50 then
                    applyBuff( "fury_of_xuen_haste" )
                    summonPet( "xuen", 8 )
                    removeBuff( "fury_of_xuen" )
                end

                if talent.whirling_dragon_punch.enabled and cooldown.rising_sun_kick.remains > 0 then
                    applyBuff( "whirling_dragon_punch", min( cooldown.fists_of_fury.remains, cooldown.rising_sun_kick.remains ) )
                end

                if pvptalent.turbo_fists.enabled then
                    applyDebuff( "target", "heavyhanded_strikes", action.fists_of_fury.cast_time + 2 )
                end

                if legendary.pressure_release.enabled then
                    -- TODO: How much to generate?  Do we need to queue it?  Special buff generator?
                end
            end,

            tick = function ()
                if legendary.jade_ignition.enabled then
                    addStack( "jade_ignition", nil, active_enemies )
                end
            end,

            finish = function ()
                if legendary.xuens_battlegear.enabled then applyBuff( "pressure_point" ) end
            end,
        },


        fortifying_brew = {
            id = 243435,
            cast = 0,
            cooldown = 180,
            gcd = "off",

            toggle = "defensives",

            startsCombat = false,
            texture = 1616072,

            handler = function ()
                applyBuff( "fortifying_brew" )
                if conduit.fortifying_ingredients.enabled then applyBuff( "fortifying_ingredients" ) end
            end,
        },


        flying_serpent_kick = {
            id = 101545,
            cast = 0,
            cooldown = function () return level > 53 and 20 or 25 end,
            gcd = "spell",

            startsCombat = true,
            texture = 606545,

            handler = function ()
                if buff.flying_serpent_kick.up then
                    removeBuff( "flying_serpent_kick" )
                else
                    applyBuff( "flying_serpent_kick" )
                    setCooldown( "global_cooldown", 2 )
                end
            end,
        },


        grapple_weapon = {
            id = 233759,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "grapple_weapon",

            startsCombat = true,
            texture = 132343,

            handler = function ()
                applyDebuff( "target", "grapple_weapon" )
            end,
        },


        invoke_xuen = {
            id = 123904,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 620832,

            handler = function ()
                summonPet( "xuen_the_white_tiger", 24 )

                if legendary.invokers_delight.enabled then
                    if buff.invokers_delight.down then stat.haste = stat.haste + 0.33 end
                    applyBuff( "invokers_delight" )
                end
            end,

            copy = "invoke_xuen_the_white_tiger"
        },


        leg_sweep = {
            id = 119381,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 642414,

            handler = function ()
                applyDebuff( "target", "leg_sweep" )
                active_dot.leg_sweep = active_enemies
                if conduit.dizzying_tumble.enabled then applyDebuff( "target", "dizzying_tumble" ) end
            end,
        },


        paralysis = {
            id = 115078,
            cast = 0,
            cooldown = function () return level > 55 and 30 or 45 end,
            gcd = "spell",

            spend = 0,
            spendType = "energy",

            startsCombat = false,
            texture = 629534,

            handler = function ()
                applyDebuff( "target", "paralysis", 60 )
            end,
        },


        provoke = {
            id = 115546,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            startsCombat = true,
            texture = 620830,

            handler = function ()
                applyDebuff( "target", "provoke", 8 )
            end,
        },


        resuscitate = {
            id = 115178,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 132132,

            handler = function ()
            end,
        },


        reverse_harm = {
            id = 287771,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            pvptalent = function ()
                if essence.conflict_and_strife.major then return end
                return "reverse_harm"
            end,

            startsCombat = true,
            texture = 627486,

            indicator = function ()
                local caption = class.abilities.reverse_harm.caption
                if caption and caption ~= UnitName( "player" ) then return "cycle" end
            end,

            caption = function ()
                if not group or not settings.optimize_reverse_harm then return end
                if reverse_harm_target then return reverse_harm_target end

                local targetName, dmg = UnitName( "player "), -1

                if raid then
                    for i = 1, 5 do
                        local unit = "raid" .. i

                        if UnitExists( unit ) and UnitIsFriend( "player", unit ) then
                            local h, m = UnitHealth( unit ), UnitHealthMax( unit )
                            local deficit = min( m - h, m * 0.08 )

                            if deficit > dmg then
                                targetName = i < 5 and UnitName( "target" ) or nil
                                dmg = deficit
                            end
                        end
                    end

                elseif group then
                    for i = 1, 5 do
                        local unit = i < 5 and ( "party" .. i ) or "player"

                        if UnitExists( unit ) and UnitIsFriend( "player", unit ) then
                            local h, m = UnitHealth( unit ), UnitHealthMax( unit )
                            local deficit = min( m - h, m * 0.08 )

                            if deficit > dmg then
                                targetName = not UnitIsUnit( "player", unit ) and UnitName( unit ) or nil
                                dmg = deficit
                            end
                        end
                    end

                end

                -- Consider using LibGetFrame to highlight a raid frame.
                reverse_harm_target = targetName
                return reverse_harm_target
            end,

            usable = function ()
                if not group and health.deficit / health.max < 0.02 then return false, "solo and health deficit is too low" end
                return true
            end,

            handler = function ()
                health.actual = min( health.max, health.current + 0.08 * health.max )
                gain( 1, "chi" )
            end,
        },


        ring_of_peace = {
            id = 116844,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 839107,

            talent = "ring_of_peace",

            handler = function ()
            end,
        },


        rising_sun_kick = {
            id = 107428,
            cast = 0,
            cooldown = function ()
                local x = 10 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            gcd = "spell",

            spend = function ()
                if buff.serenity.up then return 0 end
                return weapons_of_order( 2 )
            end,
            spendType = "chi",

            startsCombat = true,
            texture = 642415,

            cycle = "mark_of_the_crane",

            handler = function ()
                applyDebuff( 'target', 'mark_of_the_crane' )

                if talent.whirling_dragon_punch.enabled and cooldown.fists_of_fury.remains > 0 then
                    applyBuff( "whirling_dragon_punch", min( cooldown.fists_of_fury.remains, cooldown.rising_sun_kick.remains ) )
                end

                if azerite.sunrise_technique.enabled then applyDebuff( "target", "sunrise_technique" ) end

                if buff.weapons_of_order.up then
                    applyBuff( "weapons_of_order_ww" )
                    state:QueueAuraExpiration( "weapons_of_order_ww", noop, buff.weapons_of_order_ww.expires )
                end
            end,
        },


        roll = {
            id = 109132,
            cast = 0,
            charges = function ()
                local n = 1 + ( talent.celerity.enabled and 1 or 0 ) + ( legendary.roll_out.enabled and 1 or 0 )
                if n > 1 then return n end
                return nil
            end,
            cooldown = function () return talent.celerity.enabled and 15 or 20 end,
            recharge = function () return talent.celerity.enabled and 15 or 20 end,
            gcd = "spell",

            startsCombat = true,
            texture = 574574,

            notalent = "chi_torpedo",

            handler = function ()
                if azerite.exit_strategy.enabled then applyBuff( "exit_strategy" ) end
            end,
        },


        rushing_jade_wind = {
            id = 116847,
            cast = 0,
            cooldown = function ()
                local x = 6 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            hasteCD = true,
            gcd = "spell",

            spend = function() return weapons_of_order( 1 ) end,
            spendType = "chi",

            talent = "rushing_jade_wind",

            startsCombat = false,
            texture = 606549,

            handler = function ()
                applyBuff( "rushing_jade_wind" )
            end,
        },


        serenity = {
            id = 152173,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 90 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 988197,

            talent = "serenity",

            handler = function ()
                applyBuff( "serenity" )
                setCooldown( "fist_of_the_white_tiger", cooldown.fist_of_the_white_tiger.remains - ( cooldown.fist_of_the_white_tiger.remains / 2 ) )
                setCooldown( "fists_of_fury", cooldown.fists_of_fury.remains - ( cooldown.fists_of_fury.remains / 2 ) )
                setCooldown( "rising_sun_kick", cooldown.rising_sun_kick.remains - ( cooldown.rising_sun_kick.remains / 2 ) )
                setCooldown( "rushing_jade_wind", cooldown.rushing_jade_wind.remains - ( cooldown.rushing_jade_wind.remains / 2 ) )
                if conduit.coordinated_offensive.enabled then applyBuff( "coordinated_offensive" ) end
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
            id = 101546,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.dance_of_chiji_azerite.up or buff.dance_of_chiji.up ) and 0 or weapons_of_order( 2 ) end,
            spendType = "chi",

            startsCombat = true,
            texture = 606543,

            handler = function ()
                removeBuff( "dance_of_chiji" )
                removeBuff( "dance_of_chiji_azerite" )
                removeBuff( "chi_energy" )

                applyBuff( "spinning_crane_kick" )

                if debuff.bonedust_brew.up or active_dot.bonedust_brew > 0 and active_enemies > 1 then
                    gain( 1, "chi" )
                end
            end,
        },


        storm_earth_and_fire = {
            id = 137639,
            cast = 0,
            charges = 2,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
            icd = 1, -- guessing.
            gcd = "off",

            toggle = function ()
                if settings.sef_one_charge then
                    if cooldown.storm_earth_and_fire.true_time_to_max_charges > gcd.max then return "cooldowns" end
                    return
                end
                return "cooldowns"
            end,

            startsCombat = false,
            texture = 136038,

            notalent = "serenity",
            nobuff = "storm_earth_and_fire",

            handler = function ()
                applyBuff( "storm_earth_and_fire" )
            end,

            bind = "storm_earth_and_fire_fixate",

            auras = {
                -- Conduit
                coordinated_offensive = {
                    id = 336602,
                    duration = 15,
                    max_stack = 1
                }
            }
        },


        storm_earth_and_fire_fixate = {
            id = 221771,
            known = 137639,
            cast = 0,
            cooldown = 0,
            icd = 1,
            gcd = "spell",

            startsCombat = true,
            texture = 236188,

            notalent = "serenity",
            buff = "storm_earth_and_fire",

            usable = function ()
                if action.storm_earth_and_fire_fixate.lastCast >= action.storm_earth_and_fire.lastCast then return false, "spirits are already fixated" end
                return true
            end,

            bind = "storm_earth_and_fire",
        },


        tiger_palm = {
            id = 100780,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 50,
            spendType = "energy",

            startsCombat = true,
            texture = 606551,

            cycle = function ()
                if legendary.keefers_skyreach.enabled and debuff.skyreach_exhaustion.up and active_dot.skyreach_exhaustion < cycle_enemies then return "skyreach_exhaustion" end
                return "mark_of_the_crane"
            end,

            buff = function () return prev_gcd[1].tiger_palm and buff.hit_combo.up and "hit_combo" or nil end,

            handler = function ()
                if talent.eye_of_the_tiger.enabled then
                    applyDebuff( "target", "eye_of_the_tiger" )
                    applyBuff( "eye_of_the_tiger" )
                end

                if pvptalent.alpha_tiger.enabled and debuff.recently_challenged.down then
                    if buff.alpha_tiger.down then
                        stat.haste = stat.haste + 0.10
                        applyBuff( "alpha_tiger" )
                        applyDebuff( "target", "recently_challenged" )
                    end
                end

                if legendary.keefers_skyreach.enabled and debuff.skyreach_exhaustion.down then
                    setDistance( 5 )
                    applyDebuff( "target", "keefers_skyreach" )
                    applyDebuff( "target", "skyreach_exhaustion" )
                end

                gain( 2, "chi" )

                applyDebuff( "target", "mark_of_the_crane" )
            end,

            auras = {
                -- Legendary
                keefers_skyreach = {
                    id = 344021,
                    duration = 6,
                    max_stack = 1,
                },
                skyreach_exhaustion = {
                    id = 337341,
                    duration = 30,
                    max_stack = 1,
                    copy = "recently_rushing_tiger_palm"
                },
            }
        },


        tigereye_brew = {
            id = 247483,
            cast = 0,
            cooldown = 1,
            gcd = "spell",

            startsCombat = false,
            texture = 613399,

            buff = "tigereye_brew_stack",
            pvptalent = "tigereye_brew",

            handler = function ()
                applyBuff( "tigereye_brew", 2 * min( 10, buff.tigereye_brew_stack.stack ) )
                removeStack( "tigereye_brew_stack", min( 10, buff.tigereye_brew_stack.stack ) )
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


        touch_of_death = {
            id = 322109,
            cast = 0,
            cooldown = function () return legendary.fatal_touch.enabled and 60 or 180 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 606552,

            cycle = "touch_of_death",

            usable = function () return target.health.pct < 15, "requires low health target" end,

            handler = function ()
                applyDebuff( "target", "touch_of_death" )
                if level > 51 then applyBuff( "touch_of_death_buff" ) end
            end,

            auras = {
                touch_of_death_buff = {
                    id = 344361,
                    duration = 8,
                    max_stack = 1
                }
            }
        },


        touch_of_karma = {
            id = 122470,
            cast = 0,
            cooldown = 90,
            gcd = "off",

            startsCombat = true,
            texture = 651728,

            usable = function ()
                return incoming_damage_3s >= health.max * ( settings.tok_damage or 20 ) / 100, "incoming damage not sufficient (" .. ( settings.tok_damage or 20 ) .. "% / 3 sec) to use"
            end,

            handler = function ()
                applyBuff( "touch_of_karma" )
                applyDebuff( "target", "touch_of_karma_debuff" )
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
            end,
        },


        transcendence_transfer = {
            id = 119996,
            cast = 0,
            cooldown = function () return buff.escape_from_reality.up and 0 or 45 end,
            gcd = "spell",

            startsCombat = false,
            texture = 237585,

            handler = function ()
                if buff.escape_from_reality.up then removeBuff( "escape_from_reality" )
                elseif legendary.escape_from_reality.enabled then
                    applyBuff( "escape_from_reality" )
                end
            end,

            auras = {
                escape_from_reality = {
                    id = 343249,
                    duration = 10,
                    max_stack = 1
                }
            }
        },


        vivify = {
            id = 116670,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = false,
            texture = 1360980,

            handler = function ()
            end,
        },


        whirling_dragon_punch = {
            id = 152175,
            cast = 0,
            cooldown = 24,
            gcd = "spell",

            startsCombat = true,
            texture = 988194,

            talent = "whirling_dragon_punch",
            buff = "whirling_dragon_punch",

            usable = function ()
                if settings.check_wdp_range and target.outside8 then return false, "target is outside of melee range" end
                return true
            end,

            handler = function ()
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
        cycle = true,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_spectral_agility",

        package = "Windwalker",

        strict = false
    } )

    spec:RegisterSetting( "allow_fsk", false, {
        name = "Use |T606545:0|t Flying Serpent Kick",
        desc = "If unchecked, |T606545:0|t Flying Serpent Kick will not be recommended (this is the same as disabling the ability via Windwalker > Abilities > Flying Serpent Kick > Disable).",
        type = "toggle",
        width = "full",
        get = function () return not Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled = not val
        end,
    } )

    spec:RegisterSetting( "optimize_reverse_harm", false, {
        name = "Optimize |T627486:0|t Reverse Harm",
        desc = "If checked, |T627486:0|t Reverse Harm's caption will show the recommended target's name.",
        type = "toggle",
        width = "full",
    } )

    spec:RegisterSetting( "sef_one_charge", false, {
        name = "Reserve One |T136038:0|t Storm, Earth, and Fire Charge as CD",
        desc = "If checked, |T136038:0|t when Storm, Earth, and Fire's toggle is set to Default, only one charge will be reserved for use with the Cooldowns toggle.",
        type = "toggle",
        width = "full",
    } )

    spec:RegisterSetting( "tok_damage", 1, {
        name = "Required Damage for |T651728:0|t Touch of Karma",
        desc = "If set above zero, |T651728:0|t Touch of Karma will only be recommended while you have taken this percentage of your maximum health in damage in the past 3 seconds.",
        type = "range",
        min = 0,
        max = 99,
        step = 0.1,
        width = "full",
    } )

    spec:RegisterSetting( "check_wdp_range", false, {
        name = "Check |T988194:0|t Whirling Dragon Punch Range",
        desc = "If checked, when your target is outside of |T988194:0|t Whirling Dragon Punch's range, it will not be recommended.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Windwalker", 20220523, [[dSKY5cqirQ8ivQiBIu6tiLAuIeNsK0QePk9kPKMfsv3se0UOQFjLQHjcDmr0YqQ8mvQAAIaUMucBtKQ6BsjQgNkvQZPsfwNkvY8qkUhISpvkhuKQWcLs5HiLOjksvuUOuIInksvKpIusXjLsuALKcVuKQOAMiLWnvPIIDsk6NQur1srkP0tjyQIu(ksjvJveO9sL)cmyuoSIftupMKjlvxgAZQ4ZIQrtKttz1iLKxtQmBeUnH2TKFRQHJOoUuISCLEoQMUW1rY2jv9DvY4LIoVuy9QurP5lk7h0UKU0Cc9jqNM0LiD0LylO7EFYKjM(0rNtiAqgDcKhLUjhDc1iIobADR6xdHoCDcKNge)0DP5e4p1QqNGtqMYiIw2Yj7e6tGonPlr6OlXwq39(Kjtm9tEhobozu50KU0)oCcswVJLt2j0rUYjqRBv)Ai0HlKDN5lDqnUZmnGm6UNEiJUePJoOgqnOLsZMJ87cQrcHS0UWrhKLEY4bhY(dKLEIABazwf4UuKdiJ4ZnLhQrcHS0UWrhKjq2QYQCiJwUtHqw65MshKr85MYd1iHqw6rVdzYpNFSCPaYusOshhYIhYeNQbKrltpdYWkwd5EOgjeYsp6DiZQeQEr5jGS0teixsTZj8obcJhCxAoHNmw46sZPzsxAobSgzcS7AZjmQW(YjCmEa(diKqWLKfiiSCCDcQ1cCTXjOKmV40eYsiKPKmi7gji7ENGQHIabXS5yWDAM0fonPZLMtaRrMa7U2CcQ1cCTXjedbwHxjzazQLhESgzcSdzAHmLK5fNMqwcHmLKbz3ibz37egvyF5eWMKrcG0SIUWP59U0CcynYey31MtyuH9LtiSCCbKhcrNGATaxBCcQxu(b8ynDiKPfYusMxCAczjeYusgKDJeKrNtq1qrGGy2Cm4ont6cNMjGlnNawJmb2DT5euRf4AJtqjzEXPjKLqitjzqgjiJoNWOc7lNGsYaxJE0fonBHlnNWOc7lNa2KmsaKMv0jG1itGDxBUWPz67sZjG1itGDxBoHrf2xoHWYXfqEieDcQ1cCTXjOKmV40eYsiKPKmi7gjiJoNGQHIabXS5yWDAM0fUWjCHd5V4G)a(TJRlnNMjDP5eWAKjWURnNGATaxBCcPdYIHaRWZXfllA4XAKjWUtGhRPcNMjDcJkSVCcQHGamQW(cqy8Wjqy8auJi6euDahpUWPjDU0CcynYey31MtqTwGRnoHyiWk8CCXYIgESgzcS7e4XAQWPzsNWOc7lNGAiiaJkSVaegpCcegpa1iIobvhWXfllA4cNM37sZjG1itGDxBoHrf2xoH14wLd4ufqNP05eunueiiMnhdUtZKUWPzc4sZjG1itGDxBoHrf2xobzIrP7PcGotPZjOwlW1gNG6fLFapwthczAHm1)e9)Q8hJhCWFahQTHFrXXkoKPfYu)t0)RYVg3QCaNQa6mLo)IIJvCitlKjtDo(lCi)fh8hWVDCbxxEkYobvdfbcIzZXG70mPlCA2cxAobSgzcS7AZjOwlW1gNG6fLFapwthczAHmzQZX3NsHG)ausgTY8uKDcJkSVCcCYwvwLdu7uiqNP05cNMPVlnNawJmb2DT5euRf4AJtqM6C8x4q(lo4pGF74cUU8uKHmTqMm1545XVIaC2qcmvhCSf9uKHmTqw6Gmoga5VO4(WWLU7gqhzfKPfYgvy6rawOOHCiJgiJoNGvbUlf5WjK0jyvG7sroaMOi2TjqNqsNWOc7lNWX4bh8hWHAB4cNMTCxAobSgzcS7AZjOwlW1gNGm154VWH8xCWFa)2XfCD5PidzAHmzQZXZJFfb4SHeyQo4yl6PidzAHmoga5VO4(WWLU7gqhzfKLLbzJkm9ialu0qoKDJeKrhKPfYKPoh)foK)Id(d43oUGRl)IIJvCiJgilPtyuH9Lt4y8Gd(d4qTnCHtZ72LMtyuH9Lt4sYwcRYb9DY)cqMQusobSgzcS7AZfonVdxAobSgzcS7AZjOwlW1gNG6fLFapwthczAHSrfMEeGfkAihYUrcYUhY0czYuNJ)chYFXb)b8BhxW1LNIStyuH9LtGt2QYQCGANcb6mLox40mzIU0CcynYey31MtyuH9Lt4y8a8hqiHGljlqqy546euRf4AJtqjzqgjilritlKjtDo(lCi)fh8hWVDCbxx(ffhR4qgnqwcazzzqMsYGmAGS7DcQgkceeZMJb3Pzsx40mzsxAobSgzcS7AZjOwlW1gNGsY8IttilHqMsYGSBKGSKoHrf2xobSjzKainROlCAMKoxAobSgzcS7AZjOwlW1gNGsY8IttilHqMsYGSBKGSuGSKqwRq2OctpcWcfnKdz3GSKqwQoHrf2xobLKbKPwE4cNMjV3LMtaRrMa7U2CcJkSVCcHLJlG8qi6euRf4AJtqjzqgjilritlKjtDo(lCi)fh8hWVDCbxx(ffhR4qgnqwcazzzqwkqw6GSyiWk8swauVO87XAKjWoKLLbzQxu(b8ynDiKLkKPfYusMxCAczjeYusgKDJeKrNtq1qrGGy2Cm4ont6cNMjtaxAobSgzcS7AZjOwlW1gNGm154vsgalCZB45XO0bz3GS7teYsiK1cil9czJkm9ialu0qUtyuH9LtGt2QYQCGANcb6mLox40mzlCP5eWAKjWURnNWOc7lNGmXO09ubqNP05euRf4AJtq9IYpGhRPdHmTq2OctpcWcfnKdz0qcYUhY0czkjdYUrcYUhYYYGmzQZXFHd5V4G)a(TJl46Ytr2jOAOiqqmBogCNMjDHtZKPVlnNWOc7lNGsYaxJE0jG1itGDxBUWPzYwUlnNGvbUlf5WjK0jmQW(YjCiAyvoGJlzScGotPZjG1itGDxBUWfoboUyzrdxAont6sZjG1itGDxBob1AbU24eKPohphxSSOHFrXXkoKrdKL0jmQW(YjCmEWb)bCO2gUWPjDU0CcynYey31MtqTwGRnob1lk)aESMoeY0czPazJkm9ialu0qoKDJeKDpKLLbzJkm9ialu0qoKDdYsczAHS0bzQ)j6)v5xJBvoGtvaDMsNNImKLQtyuH9LtGt2QYQCGANcb6mLox408ExAobSgzcS7AZjmQW(YjSg3QCaNQa6mLoNGATaxBCcQxu(b8ynDOtq1qrGGy2Cm4ont6cNMjGlnNawJmb2DT5euRf4AJtyuHPhbyHIgYHSBKGS7DcJkSVCchJhCWFahQTHlCA2cxAobSgzcS7AZjOwlW1gNG6fLFapwthczAHmzQZX3NsHG)ausgTY8uKDcJkSVCcCYwvwLdu7uiqNP05cNMPVlnNawJmb2DT5egvyF5eKjgLUNka6mLoNGATaxBCcQxu(b8ynDiKPfYKPoh)foK)Id(d43oUEkYqMwit9pr)Vk)ACRYbCQcOZu68lkowXHSBqgDobvdfbcIzZXG70mPlCA2YDP5eSkWDPiha74esN6FI(Fv(14wLd4ufqNP05Pi7egvyF5eogp4G)aouBdNawJmb2DT5cNM3TlnNawJmb2DT5euRf4AJtq9IYpGhRPdHmTqwhLPohV8xyNIha5fVaDuM6C8uKDcJkSVCcCYwvwLdu7uiqNP05cNM3HlnNawJmb2DT5egvyF5eogpa)besi4sYceewoUob1AbU24eusgKrdKDVtq1qrGGy2Cm4ont6cNMjt0LMtaRrMa7U2CcJkSVCcYeJs3tfaDMsNtqTwGRnob1lk)aESMoeYYYGS0bzXqGv4LSaOEr53J1itGDNGQHIabXS5yWDAM0fontM0LMtyuH9LtGt2QYQCGANcb6mLoNawJmb2DT5cx4euDahxSSOHlnNMjDP5eWAKjWURnNWt2jWXWooHrf2xob9ZAJmb6e0plOgr0jWXfllAaKPwE4euRf4AJtigcScVv6FDiOjfwESgzcS7e0peuiaj4Otq9pr)VkphxSSOHFrXXkoKrdKLeYYYGm1)e9)Q8CCXYIg(ffhR4q2ni7(eHSSmit(5CitlKDSCPaSO4yfhYObYOlrNG(HGcDcQ)j6)v554ILfn8lkowXHmAGSKqwwgKrgdFtkSaHecUKSabHLJRFuHPhHmTqM6FI(FvEoUyzrd)IIJvCi7gKDFIqwwgKj)CoKPfYowUuawuCSIdz0az0LOlCAsNlnNawJmb2DT5euRf4AJtiDqM(zTrMa9sprh0KclilldYKFohY0czhlxkalkowXHmAGm6AHtyuH9LtWk9Voe0Kclx408ExAobSgzcS7AZjOwlW1gNG(zTrMa9CCXYIgazQLhoHrf2xoHPuip2HaOgccx40mbCP5eWAKjWURnNGATaxBCc6N1gzc0ZXfllAaKPwE4egvyF5eKj(VdouBdx40SfU0CcynYey31MtqTwGRnob9ZAJmb654ILfnaYulpCcJkSVCchBrzI)7UWPz67sZjG1itGDxBob1AbU24e0pRnYeONJlww0aitT8WjmQW(YjiJlhxDwL7cNMTCxAobSgzcS7AZjOwlW1gNG(zTrMa9CCXYIgazQLhoHrf2xob5jh8hqSMsh3fonVBxAoHrf2xoHzvtHG43fRWjG1itGDxBUWP5D4sZjG1itGDxBob1AbU24eIHaRWBL(xhcAsHLhRrMa7qMwilfi7y5sbyrXXkoKDdYsbYsE3jczjeYwQcp)MJ(ZedbiEkLKhRrMa7qw6fYssxIqwQqwwgKrgdFtkSaHecUKSabHLJRFuHPhHmTqwkqw6Gm1RhRPcFHQ9j(TdzzzqMm154L)c7u8aiV4LNImKLkKLLbzPazQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR4q2ni7y5sbyrXXkoKLkKPfYKPohV8xyNIha5fV8uKHSSmit(5CitlKDSCPaSO4yfhYObYsMiKLQtyuH9LtiEkLe4pGooHKlCAMmrxAobSgzcS7AZjOwlW1gNqmeyfER0)6qqtkS8ynYeyhY0czPazhlxkalkowXHSBq2DKiKLLbzKXW3KclqiHGljlqqy546hvy6rilldYKFohY0czhlxkalkowXHmAGSKjczP6egvyF5eINsjb(dq3SIJlCAMmPlnNawJmb2DT5euRf4AJtiDqwmeyfER0)6qqtkS8ynYeyhY0czPazhlxkalkowXHSBqwkqwY7orilHq2sv453C0FMyiaXtPK8ynYeyhYsVqws6seYsfYYYGmzQZXl)f2P4bqEXlpfzilldYKFohY0czhlxkalkowXHmAGSKjczP6egvyF5eINsjb(dOJti5cNMjPZLMtaRrMa7U2CcQ1cCTXjKoilgcScVv6FDiOjfwESgzcSdzAHSuGSJLlfGffhR4q2ni7oseYYYGm5NZHmTq2XYLcWIIJvCiJgilz6dzP6egvyF5eINsjb(dq3SIJlCAM8ExAobSgzcS7AZjOwlW1gNG6FI(Fv(14wLd4ufqNP05xuCSIdz0azyturfiimr0jmQW(YjCHd5V4G)a(TJRlCAMmbCP5eWAKjWURnNWOc7lNaT6dQkhTDbDKhw1GdudbHtqTwGRnob9ZAJmb654ILfnaYulpGSSmit(5CitlKDSCPaSO4yfhYObYOlrNqnIOtGw9bvLJ2UGoYdRAWbQHGWfont2cxAobSgzcS7AZjmQW(YjyfxTuXitGGwIAQGse0r9McDcQ1cCTXjOFwBKjqphxSSObqMA5bKLLbzYpNdzAHSJLlfGffhR4qgnqgDj6eQreDcwXvlvmYeiOLOMkOebDuVPqx40mz67sZjG1itGDxBoHrf2xoHRDcjE8f6euRf4AJtq)S2itGEoUyzrdGm1YdilldYKFohY0czhlxkalkowXHmAGm6s0juJi6eU2jK4XxOlCAMSL7sZjG1itGDxBoHrf2xoHxpUkPzZXoyktCaYte42WjOwlW1gNG(zTrMa9CCXYIgazQLhqwwgKj)CoKPfYowUuawuCSIdz0az0LOtOgr0j86XvjnBo2btzIdqEIa3gUWPzY72LMtaRrMa7U2CcJkSVCcCPP)x57WjdIpqrNGATaxBCcKXW3KclqiHGljlqqy546hvy6rilldYKFohY0czhlxkalkowXHmAGm6seYYYGS0bzlvHNFZrVv6FD4YbDKWYLcpwJmb2Dc1iIobU00)R8D4KbXhOOlCAM8oCP5eWAKjWURnNGATaxBCc6N1gzc0ZXfllAaKPwE4egvyF5eYjMUnXVCG80Zrx40KUeDP5eWAKjWURnNWOc7lNqiHGJT8aWTCJWjOwlW1gNG(zTrMa9CCXYIgazQLhqwwgKj)CoKPfYowUuawuCSIdz0az0LOtOgr0jesi4ylpaCl3iCHtt6s6sZjG1itGDxBob1AbU24eshKPFwBKjqFtkSaFbO4iiwR0HbKLLbzQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR4q2niJUeHSSmit)S2itGEPNOdAsHLtyuH9LtGIJalqrUlCAshDU0CcJkSVCcNbjScb84fj7eWAKjWURnx40KU7DP5egvyF5eodbbwGF746eWAKjWURnx40KUeWLMtaRrMa7U2CcQ1cCTXji)CoKPfYowUuawuCSIdz0azjBbKLLbzPazkjdYUrcYOdY0czPazhlxkalkowXHSBqw6NiKPfYsbYsbYu)t0)RYZXfllA4xuCSIdz3GSKjczzzqMm15454ILfn8uKHSSmit9pr)VkphxSSOHNImKLkKPfYsbYiJHVjfwGqcbxswGGWYX1pQW0JqwwgKP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz3GSKjczzzqM(zTrMa9sprh0KclilvilvilvilldYsbYowUuawuCSIdz0qcYs)eHmTqwkqgzm8nPWcesiGwxYceewoU(rfMEeYYYGm1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gKDSCPaSO4yfhYsfYsfYs1jmQW(Yji)f2P4bqEXlx40KUw4sZjG1itGDxBob1AbU24eu)t0)RYVg3QCaNQa6mLo)IIJvCiJgiJoilldYKFohY0czhlxkalkowXHmAGSKTWjmQW(YjWXfllA4cNM0L(U0CcJkSVCcYto4pGynLoUtaRrMa7U2CHtt6A5U0CcynYey31MtqTwGRnob(triBv3tMIhueiaxkYH9LhRrMa7qMwilDqgzm8nPWcesi4sYceewoU(rfMEeY0czYuNJNJlww0W3)RcY0czYuNJx(lStXdG8Ix((FvobRcCxkYbWoob(triBv3R)jMWiqa)j0Jv4eSkWDPihatue72eOtiPtyuH9Lt4qGCj1oNWjyvG7sroa5eV8q4es6cx4e4HlnNMjDP5eWAKjWURnNGATaxBCcPazYuNJN8AI)2THaq(dScBi88yu6GmAGS7aYYYGmzQZXl)f2P4bqEXl)IIJvCiJgit9pr)Vk)ACRYbCQcOZu68lkowXHmTqMm154L)c7u8aiV4LNImKPfYiJHVjfwGqcbxswGGWYX1pQW0JqwQqMwilfiBhRdq9yf(P35ERGSBqM6FI(Fv(ljBjSkh03j)lazQsj57u7e2xqw6fYs0F3qwwgKXjJeeGy2Cm4q2niljKLQtyuH9Lt4sYwcRYb9DY)cqMQusUWPjDU0CcynYey31MtqTwGRnob1lk)aESMoeY0czYuNJVpLcb)bOKmAL5PidzAHSuGSDSoa1Jv4NEN7TcYUbzYuNJVpLcb)bOKmAL5xuCSIdzjeYOdYYYGSDSoa1Jv4NEN7PidzP6egvyF5e4KTQSkhO2PqGotPZfonV3LMtaRrMa7U2CcQ1cCTXjWFkczR6E9pXegbc4pHEScpwJmb2HmTqMm1545XVIaC2qcmvhCSf99)QGmTqwhLPohV8xyNIha5fVaDuM6C89)QCcwf4UuKdGDCcYuNJx)tmHrGa(tOhRairjo1BDpf5SmSWnVHpmreepqCAsZ9zzQ)j6)v5xJBvoGtvaDMsNFrXXkon0LLP(NO)xL)y8Gd(d4qTn8lkowXPHoNGvbUlf5ayIIy3MaDcjDcJkSVCchcKlP25eUWPzc4sZjG1itGDxBoHrf2xoH14wLd4ufqNP05euRf4AJtq9pr)VkphxSSOHFrXXkoKDdYsczzzqw6GSyiWk8CCXYIgESgzcSdzAHSuGm1)e9)Q8x4q(lo4pGF746xuCSIdz3GSeaYYYGS0bzQxpwtfEDnwBkilvNGQHIabXS5yWDAM0fonBHlnNawJmb2DT5euRf4AJtifiBhRdq9yf(P35ERGSBqM6FI(Fv(JXdo4pGd12W3P2jSVGS0lKLO)UHSSmiBhRdq9yf(P35EkYqwQqMwilfidlCZB4dtebXdeNMq2nidBIkQabHjIqwcHSKqwwgKPKmV40eYsiKPKmiJgsqwsilldYKPohpp(veGZgsGP6GJTOFrXXkoKrdKHnrfvGGWeriRviljKLkKLLbzhlxkalkowXHmAGmSjQOceeMiczTczjHSSmiRJYuNJx(lStXdG8IxGoktDoEkYqwwgKjtDoEYRj(B3gca5)cxpfzNWOc7lNWX4bh8hWHAB4cNMPVlnNawJmb2DT5euRf4AJtqM6C8HecqrY4(lhOgYJYIF98yu6GSBqwY7aY0czyHBEdFyIiiEG40eYUbzyturfiimreYsiKLeY0czQ)j6)v5xJBvoGtvaDMsNFrXXkoKDdYWMOIkqqyIiKLLbzYuNJpKqaksg3F5a1qEuw8RNhJshKDdYsMaqMwilfit9pr)VkphxSSOHFrXXkoKrdK1citlKfdbwHNJlww0WJ1itGDilldYu)t0)RYFHd5V4G)a(TJRFrXXkoKrdK1citlKPE9ynv411yTPGSSmi7y5sbyrXXkoKrdK1cilvNWOc7lNGAhLocRYb0QPJaclxkkRYDHtZwUlnNawJmb2DT5euRf4AJtqM6C8lfxYQCaTA6i4YQUV)xfKPfYgvy6rawOOHCi7gKL0jmQW(YjSuCjRYb0QPJGlR6UWP5D7sZjG1itGDxBoHrf2xoHJXdWFaHecUKSabHLJRtqTwGRnobLKbz0az37eunueiiMnhdUtZKUWP5D4sZjG1itGDxBob1AbU24eusMxCAczjeYusgKDJeKL0jmQW(YjGnjJeaPzfDHtZKj6sZjG1itGDxBob1AbU24eusMxCAczjeYusgKDJeKLeY0czJkm9ialu0qoKrcYsczAHSDSoa1Jv4NEN7TcYUbz0LiKLLbzkjZlonHSeczkjdYUrcYOdY0czJkm9ialu0qoKDJeKrNtyuH9LtqjzazQLhUWPzYKU0CcynYey31MtqTwGRnoH0bzYuNJN8AI)2THaq(VW1tr2jmQW(YjOKmW1OhDHtZK05sZjG1itGDxBoHrf2xoHWYXfqEieDcQ1cCTXjOEr5hWJ10HqMwitjzEXPjKLqitjzq2nsqgDqMwitM6C884xraoBibMQdo2I((FvobvdfbcIzZXG70mPlCAM8ExAobSgzcS7AZjOwlW1gNGm154vsgalCZB45XO0bz3GS7teYsiK1cil9czJkm9ialu0qoKPfYKPohpp(veGZgsGP6GJTOV)xfKPfYsbYu)t0)RYVg3QCaNQa6mLo)IIJvCi7gKrhKPfYu)t0)RYFmEWb)bCO2g(ffhR4q2niJoilldYu)t0)RYVg3QCaNQa6mLo)IIJvCiJgi7EitlKP(NO)xL)y8Gd(d4qTn8lkowXHSBq29qMwitjzq2ni7EilldYu)t0)RYVg3QCaNQa6mLo)IIJvCi7gKDpKPfYu)t0)RYFmEWb)bCO2g(ffhR4qgnq29qMwitjzq2nilbGSSmitjzEXPjKLqitjzqgnKGSKqMwidlCZB4dtebXdeNMqgnqgDqwQqwwgKjtDoELKbWc38gEEmkDq2nilzIqMwi7y5sbyrXXkoKrdK1YDcJkSVCcCYwvwLdu7uiqNP05cNMjtaxAobSgzcS7AZjmQW(YjitmkDpva0zkDob1AbU24euVO8d4XA6qitlKLcKfdbwHNJlww0WJ1itGDitlKP(NO)xLNJlww0WVO4yfhYObYUhYYYGm1)e9)Q8RXTkhWPkGotPZVO4yfhYUbzjHmTqM6FI(Fv(JXdo4pGd12WVO4yfhYUbzjHSSmit9pr)Vk)ACRYbCQcOZu68lkowXHmAGS7HmTqM6FI(Fv(JXdo4pGd12WVO4yfhYUbz3dzAHmLKbz3Gm6GSSmit9pr)Vk)ACRYbCQcOZu68lkowXHSBq29qMwit9pr)Vk)X4bh8hWHAB4xuCSIdz0az3dzAHmLKbz3GS7HSSmitjzq2niRfqwwgKjtDoE5xhG8(kpfzilvNGQHIabXS5yWDAM0font2cxAobSgzcS7AZjmQW(YjewoUaYdHOtqTwGRnob1lk)aESMoeY0czkjZlonHSeczkjdYUrcYOZjOAOiqqmBogCNMjDHtZKPVlnNawJmb2DT5euRf4AJtqjzEXPjKLqitjzq2nsqwsNWOc7lNWSQPqq87Iv4cNMjB5U0CcynYey31MtqTwGRnoH0bzQxpwtf(cv7t8BhYYYGmzQZXtEnXF72qai)bwHneEkYoHrf2xoHdrdRYbCCjJva0zkDobRcCxkYHtiPlCAM8UDP5eWAKjWURnNWOc7lNGmXO09ubqNP05euRf4AJtq9IYpGhRPdHmTqM6FI(Fv(JXdo4pGd12WVO4yfhYObYUhY0czkjdYibz0bzAHmYlQhKR6(K(WYXfqEieHmTqgw4M3WhMicIh0IeHmAGSKobvdfbcIzZXG70mPlCAM8oCP5eWAKjWURnNWOc7lNGmXO09ubqNP05euRf4AJtq9IYpGhRPdHmTqgw4M3WhMicIhionHmAGm6GmTqwkqMsY8IttilHqMsYGmAibzjHSSmiJ8I6b5QUpPpSCCbKhcrilvNGQHIabXS5yWDAM0fUWjO6aoECP50mPlnNawJmb2DT5euRf4AJtiDqM(zTrMa9sprh0KclitlKLcKP(NO)xLFnUv5aovb0zkD(ffhR4qgnqgDqwwgKLoit96XAQWRRXAtbzPczAHSuGS0bzQxpwtf(cv7t8BhYYYGm1)e9)Q8YFHDkEaKx8YVO4yfhYObYOdYsfYYYGSJLlfGffhR4qgnqgDTWjmQW(YjyL(xhcAsHLlCAsNlnNawJmb2DT5euRf4AJtigcScVv6FDiOjfwESgzcSdzAHSuGSJLlfGffhR4q2nilfil5DNiKLqiBPk88Bo6ptmeG4PusESgzcSdzPxiljDjczPczzzqMm1545XVIaC2qcmvhCSf99)QGmTqgzm8nPWcesi4sYceewoU(rfMEeY0czPazPdYuVESMk8fQ2N43oKLLbzYuNJx(lStXdG8IxEkYqwQqwwgKLcKP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz3GSJLlfGffhR4qwQqMwitM6C8YFHDkEaKx8YtrgYYYGm5NZHmTq2XYLcWIIJvCiJgilzIqwQoHrf2xoH4PusG)a64esUWP59U0CcynYey31MtqTwGRnoH0bzXqGv4Ts)RdbnPWYJ1itGDitlKLcKDSCPaSO4yfhYUbzPazjV7eHSeczlvHNFZr)zIHaepLsYJ1itGDil9czjPlrilvilldYKPohpp(veGZgsGP6GJTOV)xfKPfYsbYshKPE9ynv4luTpXVDilldYKPohV8xyNIha5fV8uKHSuHSSmit(5CitlKDSCPaSO4yfhYObYsMiKLQtyuH9LtiEkLe4pGooHKlCAMaU0CcynYey31MtqTwGRnoHuGSDSoa1Jv4NEN7TcYUbzjqlGSSmiBhRdq9yf(P35EkYqwQqMwit9pr)Vk)ACRYbCQcOZu68lkowXHmAGmSjQOceeMiczAHm1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gKLcKrxIqwRqgDjczPxiBPk88Bo6Ts)RdxoOJewUu4XAKjWoKLkKLLbzYpNdzAHSJLlfGffhR4qgnq29TWjmQW(YjCHd5V4G)a(TJRlCA2cxAobSgzcS7AZjOwlW1gNG6fLFapwthczAHSuGSDSoa1Jv4NEN7TcYUbzjteYYYGSDSoa1Jv4NEN7PidzP6egvyF5eodsyfc4Xls2fontFxAobSgzcS7AZjOwlW1gNWowhG6Xk8tVZ9wbz3GS7teYYYGSDSoa1Jv4NEN7Pi7egvyF5eodbbwGF746cNMTCxAobSgzcS7AZjOwlW1gNq6GmzQZXl)f2P4bqEXlpfzitlKLcKPKmi7gjiJoitlKDSCPaSO4yfhYUbzPFIqMwilfit9pr)Vkpp(veGZgsGP6GJTOxjnBoYHSBqwIqwwgKP(NO)xLNh)kcWzdjWuDWXw0VO4yfhYUbzjteYsfY0czPazKXW3KclqiHGljlqqy546hvy6rilldYu)t0)RYBL(xhcAsHfiKqWLKfiiSCC9lkowXHSBqwYeHSSmit)S2itGEPNOdAsHfKLkKLLbzPazkjdYUrcYOdY0czhlxkalkowXHmAibzPFIqMwilfiJmg(MuybcjeqRlzbcclhx)OctpczzzqM6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXkoKDdYowUuawuCSIdzPczAHSuGm1)e9)Q884xraoBibMQdo2IEL0S5ihYUbzjczzzqM6FI(FvEE8RiaNnKat1bhBr)IIJvCi7gKDSCPaSO4yfhYYYGmzQZXZJFfb4SHeyQo4yl6PidzPczPczzzqM8Z5qMwi7y5sbyrXXkoKrdKLSfqwQqwwgKj)CoKPfYowUuawuCSIdz0azjteY0cz8NIq2QUNaNoqUbaBoIKjqpwJmb2DcJkSVCcYFHDkEaKx8YfonVBxAobSgzcS7AZjOwlW1gNG6RoLfE1)B3QjWo4phS4ME0J1itGDNWOc7lNap(veGZgsGP6GJTi4ynNaDHtZ7WLMtaRrMa7U2CcQ1cCTXjO(NO)xLNh)kcWzdjWuDWXw0RKMnh5qgjiJoilldYowUuawuCSIdz0az0LiKLLbzPaz7yDaQhRWp9o3VO4yfhYUbzjBbKLLbzPazPdYuVESMk86AS2uqMwilDqM61J1uHVq1(e)2HSuHmTqwkqwkq2owhG6Xk8tVZ9wbz3Gm1)e9)Q884xraoBibMQdo2I(dfbbyrL0S5iimreYYYGS0bz7yDaQhRWp9o3JnnEWHSuHmTqwkqM6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXkoKDdYu)t0)RYZJFfb4SHeyQo4yl6pueeGfvsZMJGWerilldY0pRnYeOx6j6GMuybzPczPczAHm1)e9)Q8hJhCWFahQTHFrXXkoKrdji7oGmTqMsYGSBKGm6GmTqM6FI(Fv(ljBjSkh03j)lazQsj5xuCSIdz0qcYsshKLQtyuH9LtGh)kcWzdjWuDWXw0fontMOlnNawJmb2DT5euRf4AJtq96XAQWRRXAtbzAHSuGmzQZXFHd5V4G)a(TJRNImKLLbzPazhlxkalkowXHmAGm1)e9)Q8x4q(lo4pGF746xuCSIdzzzqM6FI(Fv(lCi)fh8hWVDC9lkowXHSBqM6FI(FvEE8RiaNnKat1bhBr)HIGaSOsA2CeeMiczPczAHm1)e9)Q8hJhCWFahQTHFrXXkoKrdji7oGmTqMsYGSBKGm6GmTqM6FI(Fv(ljBjSkh03j)lazQsj5xuCSIdz0qcYsshKLQtyuH9LtGh)kcWzdjWuDWXw0fontM0LMtaRrMa7U2CcQ1cCTXjOE9ynv4luTpXVDitlKLcK1rzQZXl)f2P4bqEXlqhLPohpfzitlKLoit)S2itGEPNOd44bYsfY0czDuM6C8YFHDkEaKx8c0rzQZXtrgY0czPazKXW3KclqiHGljlqqy546hvy6rilldY0pRnYeOx6j6GMuybzzzqM6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXkoKDdYu)t0)RYZJFfb4SHeyQo4yl6pueeGfvsZMJGWerilldYu)t0)RYBL(xhcAsHfiKqWLKfiiSCC9lkowXHSBq29jczP6egvyF5e4XVIaC2qcmvhCSfDHtZK05sZjG1itGDxBoHrf2xobA1huvoA7c6ipSQbhOgccNGATaxBCcKXW3KclqiHGljlqqy546hvy6rilldYu)t0)RYBL(xhcAsHfiKqWLKfiiSCC9lkowXHSBqw6NiKPfYowUuawuCSIdz3GSK3DIqwwgKj)CoKPfYowUuawuCSIdz0az0LOtOgr0jqR(GQYrBxqh5Hvn4a1qq4cNMjV3LMtaRrMa7U2CcJkSVCcwXvlvmYeiOLOMkOebDuVPqNGATaxBCcKXW3KclqiHGljlqqy546hvy6rilldYKFohY0czhlxkalkowXHmAGm6s0juJi6eSIRwQyKjqqlrnvqjc6OEtHUWPzYeWLMtaRrMa7U2CcJkSVCcx7es84l0jOwlW1gNazm8nPWcesi4sYceewoU(rfMEeYYYGm5NZHmTq2XYLcWIIJvCiJgiJUeDc1iIoHRDcjE8f6cNMjBHlnNawJmb2DT5egvyF5e4st)VY3HtgeFGIob1AbU24eiJHVjfwGqcbxswGGWYX1pQW0JqwwgKj)CoKPfYowUuawuCSIdz0az0LiKLLbzPdYwQcp)MJER0)6WLd6iHLlfESgzcS7eQreDcCPP)x57WjdIpqrx40mz67sZjG1itGDxBoHrf2xoHxpUkPzZXoyktCaYte42WjOwlW1gNazm8nPWcesi4sYceewoU(rfMEeYYYGm1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gKDhjczzzqM8Z5qMwi7y5sbyrXXkoKrdKrxIoHAerNWRhxL0S5yhmLjoa5jcCB4cNMjB5U0CcynYey31MtqTwGRnobYy4BsHfiKqWLKfiiSCC9Jkm9iKLLbzYpNdzAHSJLlfGffhR4qgnqwYw4egvyF5eYjMUnXVCG80Zrx40m5D7sZjG1itGDxBoHrf2xoHqcbhB5bGB5gHtqTwGRnobYy4BsHfiKqWLKfiiSCC9lkowXHSBqwYwazzzqM6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXkoKDdYs)eHmTq2XYLcWIIJvCi7gKDFIjczzzqM8Z5qMwi7y5sbyrXXkoKrdKrxIoHAerNqiHGJT8aWTCJWfontEhU0CcynYey31MtyuH9Ltqnkje8hWOAjkBXoiwC4ulYDcQ1cCTXjmQW0JaSqrd5qgnqgDqMwitM6C8JQLOSf7GRP6EkYqwwgKnQW0JaSqrd5q2niljKPfYKPoh)OAjkBXoyAIEkYqwwgKj)CoKPfYowUuawuCSIdz0az0LOtOgr0jOgLec(dyuTeLTyheloCQf5UWPjDj6sZjG1itGDxBoHrf2xobUAwo4pGZobU1qa4XAh0jOwlW1gNq6GmzQZXZvZYb)bC2jWTgcapw7GGeWtrgYYYGm5NZHmTq2XYLcWIIJvCiJgi7(w4eQreDcC1SCWFaNDcCRHaWJ1oOlCAsxsxAobSgzcS7AZjOwlW1gNq6Gm9ZAJmb6BsHf4lafhbXALomGSSmit9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yfhYUbz0LiKPfYiJHVjfwGqcbxswGGWYX1VO4yfhYObYOlrilldY0pRnYeOx6j6GMuy5egvyF5eO4iWcuK7cNM0rNlnNawJmb2DT5euRf4AJtigcScVv6FDiOjfwESgzcSdzAHSuGSJLlfGffhR4q2ni7oseYYYGmYy4BsHfiKqWLKfiiSCC9Jkm9iKLLbz6N1gzc0l9eDqtkSGSSmit(5CitlKDSCPaSO4yfhYObYsM(qwQoHrf2xoH4PusG)a0nR44cNM0DVlnNawJmb2DT5euRf4AJtiDqwmeyfER0)6qqtkS8ynYeyhY0czPazhlxkalkowXHSBqwYwChqwwgKPFwBKjqV0t0bnPWcYs1jmQW(YjepLsc8hGUzfhx40KUeWLMtaRrMa7U2CcQ1cCTXjO(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz3GS7teYYYGm9ZAJmb6LEIoOjfwqwwgKj)CoKPfYowUuawuCSIdz0az0LOtyuH9LtykfYJDiaQHGWfonPRfU0CcynYey31MtqTwGRnob1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gKDFIqwwgKPFwBKjqV0t0bnPWcYYYGm5NZHmTq2XYLcWIIJvCiJgiJUeDcJkSVCcYe)3bhQTHlCAsx67sZjG1itGDxBob1AbU24eu)t0)RYBL(xhcAsHfiKqWLKfiiSCC9lkowXHSBq29jczzzqM(zTrMa9sprh0KclilldYKFohY0czhlxkalkowXHmAGSKj6egvyF5eo2IYe)3DHtt6A5U0CcynYey31MtqTwGRnob1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gKDFIqwwgKPFwBKjqV0t0bnPWcYYYGm5NZHmTq2XYLcWIIJvCiJgilzlCcJkSVCcY4YXvNv5UWPjD3TlnNawJmb2DT5euRf4AJtqM6C884xraoBibMQdo2I((FvoHrf2xob5jh8hqSMsh3fonP7oCP5egvyF5eiSCPGdOvu9CrScNawJmb2DT5cNM3NOlnNawJmb2DT5euRf4AJtG)ueYw19KP4bfbcWLICyF5XAKjWoKPfYshKrgdFtkSaHecUKSabHLJRFuHPhHmTqMm1545XVIaC2qcmvhCSf99)QGmTqMm154L)c7u8aiV4LV)xLtWQa3LICaSJtG)ueYw196FIjmceWFc9yfobRcCxkYbWefXUnb6es6egvyF5eoeixsTZjCcwf4UuKdqoXlpeoHKUWfoHoEgkIWLMtZKU0CcJkSVCcCY4SaPP6aESMo0jG1itGDxBUWPjDU0CcynYey31Mt4j7e4y4egvyF5e0pRnYeOtq)qqHob1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gKDSCPaSO4yfhYYYGSJLlfGffhR4qwcHm1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCiJgiljDjczAHSuGSuGSyiWk8CCXYIgESgzcSdzAHSJLlfGffhR4q2nit9pr)VkphxSSOHFrXXkoKPfYu)t0)RYZXfllA4xuCSIdz3GSKjczPczzzqwkqM6FI(FvEE8RiaNnKat1bhBr)HIGaSOsA2CeeMicz0azhlxkalkowXHmTqM6FI(FvEE8RiaNnKat1bhBr)HIGaSOsA2CeeMicz3GSKTaYsfYYYGSuGm1)e9)Q884xraoBibMQdo2IEL0S5ihYibzjczAHm1)e9)Q884xraoBibMQdo2I(ffhR4qgnq2XYLcWIIJvCilvilvNG(zb1iIobPNOdAsHLlCAEVlnNawJmb2DT5eEYobogoHrf2xob9ZAJmb6e0peuOtq9pr)VkV8xyNIha5fV8uKHmTqM6FI(FvEE8RiaNnKat1bhBrVsA2CKdz0az0bzAHmLKbz0az3dzzzqMm154L)c7u8aiV4LFrXXkoKrdKD3ob9ZcQreDcsprhWXJlCAMaU0CcynYey31MtqTwGRnoHyiWk8wP)1HGMuy5XAKjWoKPfYsbYsbYKPohphxSSOHNImKLLbzYuNJNh)kcWzdjWuDWXw0trgYsfY0czKXW3KclqiHGljlqqy546hvy6rilldYKFohY0czhlxkalkowXHmAibzPFIqwQoHrf2xobYFyF5cNMTWLMtaRrMa7U2CcQ1cCTXjKoilgcScVv6FDiOjfwESgzcSdzAHSuGSuGmzQZXZXfllA4PidzzzqMm1545XVIaC2qcmvhCSf9uKHSuHmTq2XYLcWIIJvCiJgsqw6NiKLQtyuH9LtG8h2xUWPz67sZjG1itGDxBob1AbU24eKPohphxSSOHNIStGhRPcNMjDcJkSVCcQHGamQW(cqy8Wjqy8auJi6e44ILfnCHtZwUlnNawJmb2DT5euRf4AJtqM6C8x4q(lo4pGF746Pi7e4XAQWPzsNWOc7lNGAiiaJkSVaegpCcegpa1iIoHlCi)fh8hWVDCDHtZ72LMtaRrMa7U2CcQ1cCTXjeMicz0azjaKPfYusgKrdK1citlKLoiJmg(MuybcjeCjzbcclhx)Octp6e4XAQWPzsNWOc7lNGAiiaJkSVaegpCcegpa1iIoHNmw46cNM3HlnNawJmb2DT5egvyF5eogpa)besi4sYceewoUob1AbU24eusMxCAczjeYusgKDJeKDpKPfYsbYWc38g(Werq8aXPjKrdKLeYYYGmSWnVHpmreepqCAcz0azjaKPfYu)t0)RYFmEWb)bCO2g(ffhR4qgnqwsFlGSSmit9pr)Vk)foK)Id(d43oU(ffhR4qgnqgDqwQqMwilDqwhLPohV8xyNIha5fVaDuM6C8uKDcQgkceeZMJb3Pzsx40mzIU0CcynYey31MtqTwGRnobLK5fNMqwcHmLKbz3ibzjHmTqwkqgw4M3WhMicIhionHmAGSKqwwgKP(NO)xLNJlww0WVO4yfhYObYOdYYYGmSWnVHpmreepqCAcz0azjaKPfYu)t0)RYFmEWb)bCO2g(ffhR4qgnqwsFlGSSmit9pr)Vk)foK)Id(d43oU(ffhR4qgnqgDqwQqMwilDqMm154L)c7u8aiV4LNIStyuH9LtaBsgjasZk6cNMjt6sZjG1itGDxBoHrf2xoHWYXfqEieDcQ1cCTXjOEr5hWJ10HqMwitjzEXPjKLqitjzq2nsqgDqMwilfidlCZB4dtebXdeNMqgnqwsilldYu)t0)RYZXfllA4xuCSIdz0az0bzzzqgw4M3WhMicIhionHmAGSeaY0czQ)j6)v5pgp4G)aouBd)IIJvCiJgilPVfqwwgKP(NO)xL)chYFXb)b8Bhx)IIJvCiJgiJoilvitlKLoiRJYuNJx(lStXdG8IxGoktDoEkYobvdfbcIzZXG70mPlCAMKoxAobSgzcS7AZjOwlW1gNG61J1uHVSCPaCgeY0czQ)j6)v5pdsyfc4Xls2VO4yfhYUbz01citlKLcKPKmV40eYsiKPKmi7gjiljKPfYgvy6rawOOHCiJeKLeY0cz7yDaQhRWp9o3BfKDdYOlrilldYusMxCAczjeYusgKDJeKrhKPfYgvy6rawOOHCi7gjiJoilvNWOc7lNGsYaYulpCHtZK37sZjG1itGDxBob1AbU24eiVOEqUQ7t6dlhxa5HqeY0czkjdYObYsaNWOc7lNaw4MB3zTkhGewtBDHtZKjGlnNawJmb2DT5euRf4AJtiDqwmeyfEoUyzrdpwJmb2Dc8ynv40mPtyuH9LtqneeGrf2xacJhobcJhGAerNGQd44Xfont2cxAobSgzcS7AZjOwlW1gNqmeyfEoUyzrdpwJmb2Dc8ynv40mPtyuH9LtqneeGrf2xacJhobcJhGAerNGQd44ILfnCHtZKPVlnNawJmb2DT5euRf4AJtyuHPhbyHIgYHmAGS7Dc8ynv40mPtyuH9LtqneeGrf2xacJhobcJhGAerNapCHtZKTCxAobSgzcS7AZjOwlW1gNWOctpcWcfnKdz3ibz37e4XAQWPzsNWOc7lNGAiiaJkSVaegpCcegpa1iIoH5rx4cNa5fvVO8eU0CAM0LMtyuH9Ltq(JGa7GdX0a7xwLdIVPvobSgzcS7AZfonPZLMtaRrMa7U2CcpzNahdNWOc7lNG(zTrMaDc6hck0jGTeLrMm29wXvlvmYeiOLOMkOebDuVPqilldYWwIYitg7(CIPBt8lhip9CeYYYGmSLOmYKXU)ANqIhFHqwwgKHTeLrMm29VECvsZMJDWuM4aKNiWTbKLLbzylrzKjJDpxA6)v(oCYG4dueYYYGmSLOmYKXUpKqWXwEa4wUrazzzqg2sugzYy3RgLec(dyuTeLTyheloCQf5ob9ZcQreDcnPWc8fGIJGyTshgUWP59U0CcJkSVCchcKlP25eobSgzcS7AZfontaxAobSgzcS7AZjOwlW1gNq6Gm1RhRPcFz5sb4mOtyuH9LtqjzazQLhUWPzlCP5eWAKjWURnNGATaxBCcPdYIHaRWJfU52DwRYbiH1expwJmb2DcJkSVCckjdCn6rx4cNW8OlnNMjDP5egvyF5eUKSLWQCqFN8VaKPkLKtaRrMa7U2CHtt6CP5eWAKjWURnNGATaxBCcQxu(b8ynDiKPfYsbYKPohFFkfc(dqjz0kZtrgYYYGSoktDoE5VWofpaYlEb6Om154PidzP6egvyF5e4KTQSkhO2PqGotPZfonV3LMtaRrMa7U2CcQ1cCTXjGfU5n8HjIG4bItti7gKHnrfvGGWerilldYusMxCAczjeYusgKrdjilPtyuH9Lt4y8Gd(d4qTnCHtZeWLMtaRrMa7U2CcJkSVCcRXTkhWPkGotPZjOwlW1gNqkqwmeyf(ljBjSkh03j)lazQsj5XAKjWoKPfYu)t0)RYVg3QCaNQa6mLoFNANW(cYUbzQ)j6)v5VKSLWQCqFN8VaKPkLKFrXXkoK1kKLaqwQqMwilfit9pr)Vk)X4bh8hWHAB4xuCSIdz3GS7HSSmitjzq2nsqwlGSuDcQgkceeZMJb3Pzsx40SfU0CcynYey31MtqTwGRnobzQZXVuCjRYb0QPJGlR6((FvoHrf2xoHLIlzvoGwnDeCzv3fontFxAobSgzcS7AZjOwlW1gNGsY8IttilHqMsYGSBKGSKoHrf2xobSjzKainROlCA2YDP5eWAKjWURnNWOc7lNWX4b4pGqcbxswGGWYX1jOwlW1gNGsY8IttilHqMsYGSBKGS7DcQgkceeZMJb3Pzsx408UDP5eWAKjWURnNGATaxBCckjZlonHSeczkjdYUrcYOZjmQW(YjOKmGm1Ydx408oCP5eWAKjWURnNGATaxBCcYuNJpKqaksg3F5a1qEuw8RNhJshKDdYsEhqMwidlCZB4dtebXdeNMq2nidBIkQabHjIqwcHSKqMwit9pr)Vk)X4bh8hWHAB4xuCSIdz3GmSjQOceeMi6egvyF5eu7O0ryvoGwnDeqy5srzvUlCAMmrxAobSgzcS7AZjmQW(YjewoUaYdHOtqTwGRnobLK5fNMqwcHmLKbz3ibz0bzAHSuGS0bzXqGv4LSaOEr53J1itGDilldYuVO8d4XA6qilvNGQHIabXS5yWDAM0fontM0LMtaRrMa7U2CcQ1cCTXjOKmV40eYsiKPKmi7gjilPtyuH9Ltyw1uii(DXkCHtZK05sZjG1itGDxBob1AbU24euVO8d4XA6qitlKLcKP(NO)xLx(lStXdG8Ix(ffhR4q2niJoilldYshKPE9ynv4luTpXVDilvitlKLcKPKmi7gjiRfqwwgKP(NO)xL)y8Gd(d4qTn8lkowXHSBqw6dzzzqM6FI(Fv(JXdo4pGd12WVO4yfhYUbz3dzAHmLKbz3ibz3dzAHmSWnVHpmreepOfjcz0azjHSSmidlCZB4dtebXdeNMqgnKGSuGS7HSwHS7HS0lKP(NO)xL)y8Gd(d4qTn8lkowXHmAGSwazPczzzqMm1545XVIaC2qcmvhCSf9uKHSuDcJkSVCcCYwvwLdu7uiqNP05cNMjV3LMtaRrMa7U2CcQ1cCTXjOEr5hWJ10HoHrf2xobLKbUg9OlCAMmbCP5eWAKjWURnNWOc7lNWHOHv5aoUKXka6mLoNGATaxBCcYuNJx(1biVVY3)RYjyvG7sroCcjDHtZKTWLMtaRrMa7U2CcJkSVCcYeJs3tfaDMsNtqTwGRnob1lk)aESMoeY0czPazYuNJx(1biVVYtrgYYYGSyiWk8swauVO87XAKjWoKPfYiVOEqUQ7t6dlhxa5HqeY0czkjdYibz0bzAHm1)e9)Q8hJhCWFahQTHFrXXkoKrdKDpKLLbzkjZlonHSeczkjdYOHeKLeY0czKxupix19j9CYwvwLdu7uiqNP0bzAHmSWnVHpmreepqCAcz0az3dzP6eunueiiMnhdUtZKUWfUWjOhxU9Ltt6sKo6sSfjtaNW1SLv5CNaTE6bTwnBz1KwZDbzqwAsiKzIK)nGSZVqgTVWH8xCWFa)2XL2q2ITeLTyhY4Viczdv8ItGDitjnvoY9qnOfwHqwY7cYOLFPh3a7qgTJHaRWNG0gYIhYODmeyf(e0J1itGDAdztazTm350cilLKnt1d1Gwyfcz0DxqgT8l94gyhYODmeyf(eK2qw8qgTJHaRWNGESgzcStBiBciRL5oNwazPKSzQEOg0cRqil593fKrl)spUb2HmAhdbwHpbPnKfpKr7yiWk8jOhRrMa70gYsjzZu9qnGAqRNEqRvZwwnP1CxqgKLMeczMi5Fdi78lKrBoUyzrdAdzl2su2IDiJ)IiKnuXlob2HmL0u5i3d1Gwyfczjt8UGmA5x6XnWoKr7yiWk8jiTHS4HmAhdbwHpb9ynYeyN2q2eqwlZDoTaYsjzZu9qnGAqRNEqRvZwwnP1CxqgKLMeczMi5Fdi78lKrBvhWXfllAqBiBXwIYwSdz8xeHSHkEXjWoKPKMkh5EOg0cRqi7oUliJw(LECdSdz0EPk88Bo6tqAdzXdz0EPk88Bo6tqpwJmb2PnKLsYMP6HAqlScHSKjVliJw(LECdSdz0EPk88Bo6tqAdzXdz0EPk88Bo6tqpwJmb2PnKLsYMP6HAqlScHSK39Dbz0YV0JBGDiJ2lvHNFZrFcsBilEiJ2lvHNFZrFc6XAKjWoTHSjGSwM7CAbKLsYMP6HAqlScHm6A53fKrl)spUb2HmAZFkczR6(eK2qw8qgT5pfHSvDFc6XAKjWoTHSus2mvpudOg06Ph0A1SLvtAn3fKbzPjHqMjs(3aYo)cz0Mh0gYwSLOSf7qg)friBOIxCcSdzkPPYrUhQbTWkeYU)UGmA5x6XnWoKrB(triBv3NG0gYIhYOn)PiKTQ7tqpwJmb2PnKLsYMP6HAqlScHSe4UGmA5x6XnWoKr7yiWk8jiTHS4HmAhdbwHpb9ynYeyN2qwkjBMQhQbTWkeYs)7cYOLFPh3a7qgTJHaRWNG0gYIhYODmeyf(e0J1itGDAdzPKSzQEOg0cRqilzcCxqgT8l94gyhYODmeyf(eK2qw8qgTJHaRWNGESgzcStBilLKnt1d1aQbTE6bTwnBz1KwZDbzqwAsiKzIK)nGSZVqgTvDahp0gYwSLOSf7qg)friBOIxCcSdzkPPYrUhQbTWkeYO7UGmA5x6XnWoKr7LQWZV5OpbPnKfpKr7LQWZV5Opb9ynYeyN2qwkjBMQhQbTWkeYU)UGmA5x6XnWoKr7LQWZV5OpbPnKfpKr7LQWZV5Opb9ynYeyN2qwkjBMQhQbTWkeYsG7cYOLFPh3a7qgTxQcp)MJ(eK2qw8qgTxQcp)MJ(e0J1itGDAdzPKSzQEOg0cRqiRLFxqgT8l94gyhYOn)PiKTQ7tqAdzXdz0M)ueYw19jOhRrMa70gYMaYAzUZPfqwkjBMQhQbTWkeYs2I7cYOLFPh3a7qgTxQcp)MJ(eK2qw8qgTxQcp)MJ(e0J1itGDAdztazTm350cilLKnt1d1Gwyfcz3N4Dbz0YV0JBGDiJ28NIq2QUpbPnKfpKrB(triBv3NGESgzcStBilLKnt1d1aQbTE6bTwnBz1KwZDbzqwAsiKzIK)nGSZVqgT74zOicAdzl2su2IDiJ)IiKnuXlob2HmL0u5i3d1Gwyfcz0DxqgT8l94gyhYODmeyf(eK2qw8qgTJHaRWNGESgzcStBilLKnt1d1GwyfczjtG7cYOLFPh3a7qgTJHaRWNG0gYIhYODmeyf(e0J1itGDAdztazTm350cilLKnt1d1GwyfczjBXDbz0YV0JBGDiJ2XqGv4tqAdzXdz0ogcScFc6XAKjWoTHSjGSwM7CAbKLsYMP6HAa1Gwp9GwRMTSAsR5UGmilnjeYmrY)gq25xiJ2ZJ0gYwSLOSf7qg)friBOIxCcSdzkPPYrUhQbTWkeYsG7cYOLFPh3a7qgTJHaRWNG0gYIhYODmeyf(e0J1itGDAdzPKSzQEOg0cRqilzI3fKrl)spUb2HmAhdbwHpbPnKfpKr7yiWk8jOhRrMa70gYsjzZu9qnOfwHqwYwCxqgT8l94gyhYODmeyf(eK2qw8qgTJHaRWNGESgzcStBilLKnt1d1aQrlRi5FdSdz3bKnQW(cYimEW9qnCcK3)yeOt4oDNGmADR6xdHoCHS7mFPdQXD6obz3zMgqgD3tpKrxI0rhudOg3P7eKrlLMnh53fuJ70DcYsiKL2fo6GS0tgp4q2FGS0tuBdiZQa3LICazeFUP8qnUt3jilHqwAx4OdYeiBvzvoKrl3Pqil9CtPdYi(Ct5HACNUtqwcHS0JEhYKFo)y5sbKPKqLooKfpKjovdiJwMEgKHvSgY9qnUt3jilHqw6rVdzwLq1lkpbKLEIa5sQDoHhQbuJ70DcYAzAIkQa7qMmE(fHm1lkpbKjJ5wX9qw6HsHKdoKvFLqPzfpueq2Oc7loK9frdpuJrf2xCp5fvVO8eTsQD5pccSdoetdSFzvoi(Mwb1yuH9f3tEr1lkprRKAx)S2itG0xJisQjfwGVauCeeRv6WG(Nmjog0RFiOqsylrzKjJDVvC1sfJmbcAjQPckrqh1BkmldBjkJmzS7ZjMUnXVCG80ZXSmSLOmYKXU)ANqIhFHzzylrzKjJD)RhxL0S5yhmLjoa5jcCBKLHTeLrMm29CPP)x57WjdIpqXSmSLOmYKXUpKqWXwEa4wUrKLHTeLrMm29QrjHG)agvlrzl2bXIdNArouJrf2xCp5fvVO8eTsQ9dbYLu7CcOgJkSV4EYlQEr5jALu7kjditT8GE7qkDQxpwtf(YYLcWzqOgJkSV4EYlQEr5jALu7kjdCn6r6TdP0fdbwHhlCZT7SwLdqcRjUESgzcSd1aQXD6obzTmnrfvGDid1JBdilmreYcjeYgv8lKzCiB0pgXitGEOgJkSV4K4KXzbst1b8ynDiuJrf2x8wj1U(zTrMaPVgrKK0t0bnPWI(Nmjog0RFiOqsQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR43owUuawuCSINLDSCPaSO4yfpHQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR40KKUe1MskXqGv454ILfn0ESCPaSO4yf)M6FI(FvEoUyzrd)IIJvCTQ)j6)v554ILfn8lkowXVLmXuZYsr9pr)Vkpp(veGZgsGP6GJTO)qrqawujnBoccteP5y5sbyrXXkUw1)e9)Q884xraoBibMQdo2I(dfbbyrL0S5iimr8wYwKAwwkQ)j6)v55XVIaC2qcmvhCSf9kPzZroPe1Q(NO)xLNh)kcWzdjWuDWXw0VO4yfNMJLlfGffhR4PMkuJrf2x8wj1U(zTrMaPVgrKK0t0bC8q)tMehd61peuij1)e9)Q8YFHDkEaKx8YtrwR6FI(FvEE8RiaNnKat1bhBrVsA2CKtdDAvsgn3NLjtDoE5VWofpaYlE5xuCSItZDd1yuH9fVvsTt(d7l6TdPyiWk8wP)1HGMuy5XAKjWU2usrM6C8CCXYIgEkYzzYuNJNh)kcWzdjWuDWXw0trovTKXW3KclqiHGljlqqy546hvy6XSm5NZ1ESCPaSO4yfNgsPFIPc1yuH9fVvsTt(d7l6TdP0fdbwH3k9Voe0KclpwJmb21MskYuNJNJlww0WtroltM6C884xraoBibMQdo2IEkYPQ9y5sbyrXXkonKs)etfQXOc7lERKAxneeGrf2xacJh0xJisIJlww0GEESMkiLKE7qsM6C8CCXYIgEkYqngvyFXBLu7QHGamQW(cqy8G(Aersx4q(lo4pGF74sppwtfKssVDijtDo(lCi)fh8hWVDC9uKHAmQW(I3kP2vdbbyuH9fGW4b91iIKEYyHl98ynvqkj92HuyIinjGwLKrtl0MoYy4BsHfiKqWLKfiiSCC9Jkm9iuJrf2x8wj1(X4b4pGqcbxswGGWYXLEvdfbcIzZXGtkj92HKsY8ItZeQKSBKUxBkyHBEdFyIiiEG40KMKzzyHBEdFyIiiEG40KMeqR6FI(Fv(JXdo4pGd12WVO4yfNMK(wKLP(NO)xL)chYFXb)b8Bhx)IIJvCAOlvTPRJYuNJx(lStXdG8IxGoktDoEkYqngvyFXBLu7ytYibqAwr6TdjLK5fNMjujz3iLuBkyHBEdFyIiiEG40KMKzzQ)j6)v554ILfn8lkowXPHUSmSWnVHpmreepqCAstcOv9pr)Vk)X4bh8hWHAB4xuCSIttsFlYYu)t0)RYFHd5V4G)a(TJRFrXXkon0LQ20jtDoE5VWofpaYlE5Pid1yuH9fVvsThwoUaYdHi9QgkceeZMJbNus6Tdj1lk)aESMouRsY8ItZeQKSBKOtBkyHBEdFyIiiEG40KMKzzQ)j6)v554ILfn8lkowXPHUSmSWnVHpmreepqCAstcOv9pr)Vk)X4bh8hWHAB4xuCSIttsFlYYu)t0)RYFHd5V4G)a(TJRFrXXkon0LQ201rzQZXl)f2P4bqEXlqhLPohpfzOgJkSV4TsQDLKbKPwEqVDiPE9ynv4llxkaNb1Q(NO)xL)miHviGhViz)IIJv8B01cTPOKmV40mHkj7gPKAhvy6rawOOHCsj1UJ1bOESc)07CVv3OlXSmLK5fNMjujz3irN2rfMEeGfkAi)gj6sfQXOc7lERKAhlCZT7SwLdqcRPT0BhsKxupix19j9HLJlG8qiQvjz0KaqngvyFXBLu7QHGamQW(cqy8G(AersQoGJh65XAQGus6TdP0fdbwHNJlww0aQXOc7lERKAxneeGrf2xacJh0xJiss1bCCXYIg0ZJ1ubPK0BhsXqGv454ILfnGAmQW(I3kP2vdbbyuH9fGW4b91iIK4b98ynvqkj92H0OctpcWcfnKtZ9qngvyFXBLu7QHGamQW(cqy8G(AersZJ0ZJ1ubPK0BhsJkm9ialu0q(ns3d1aQXOc7lUFEK0LKTewLd67K)fGmvPKGAmQW(I7NhBLu7CYwvwLdu7uiqNP0rVDiPEr5hWJ10HAtrM6C89Pui4paLKrRmpf5SSoktDoE5VWofpaYlEb6Om154PiNkuJrf2xC)8yRKA)y8Gd(d4qTnO3oKWc38g(Werq8aXP5nSjQOceeMiMLPKmV40mHkjJgsjHAmQW(I7NhBLu7RXTkhWPkGotPJEvdfbcIzZXGtkj92HukXqGv4VKSLWQCqFN8VaKPkLKw1)e9)Q8RXTkhWPkGotPZ3P2jSVUP(NO)xL)sYwcRYb9DY)cqMQus(ffhR4TMaPQnf1)e9)Q8hJhCWFahQTHFrXXk(T7ZYus2nsTivOgJkSV4(5Xwj1(sXLSkhqRMocUSQtVDijtDo(LIlzvoGwnDeCzv33)RcQXOc7lUFESvsTJnjJeaPzfP3oKusMxCAMqLKDJusOgJkSV4(5Xwj1(X4b4pGqcbxswGGWYXLEvdfbcIzZXGtkj92HKsY8ItZeQKSBKUhQXOc7lUFESvsTRKmGm1Yd6TdjLK5fNMjujz3irhuJrf2xC)8yRKAxTJshHv5aA10raHLlfLv50BhsYuNJpKqaksg3F5a1qEuw8RNhJs3TK3HwSWnVHpmreepqCAEdBIkQabHjIjmPw1)e9)Q8hJhCWFahQTHFrXXk(nSjQOceeMic1yuH9f3pp2kP2dlhxa5HqKEvdfbcIzZXGtkj92HKsY8ItZeQKSBKOtBkPlgcScVKfa1lk)zzQxu(b8ynDyQqngvyFX9ZJTsQ9zvtHG43fRGE7qsjzEXPzcvs2nsjHAmQW(I7NhBLu7CYwvwLdu7uiqNP0rVDiPEr5hWJ10HAtr9pr)VkV8xyNIha5fV8lkowXVrxww6uVESMk8fQ2N43EQAtrjz3i1ISm1)e9)Q8hJhCWFahQTHFrXXk(T0plt9pr)Vk)X4bh8hWHAB4xuCSIF7ETkj7gP71IfU5n8HjIG4bTirAsMLHfU5n8HjIG4bIttAiLY9TEF6v9pr)Vk)X4bh8hWHAB4xuCSIttlsnltM6C884xraoBibMQdo2IEkYPc1yuH9f3pp2kP2vsg4A0J0BhsQxu(b8ynDiuJrf2xC)8yRKA)q0WQCahxYyfaDMsh92HKm154LFDaY7R89)QO3Qa3LICqkjuJrf2xC)8yRKAxMyu6EQaOZu6Ox1qrGGy2Cm4KssVDiPEr5hWJ10HAtrM6C8YVoa59vEkYzzXqGv4LSaOEr5xl5f1dYvDFsFy54cipeIAvsgj60Q(NO)xL)y8Gd(d4qTn8lkowXP5(SmLK5fNMjujz0qkPwYlQhKR6(KEozRkRYbQDkeOZu60IfU5n8HjIG4bIttAUpvOgqngvyFX9QoGJhswP)1HGMuybcjeCjzbcclhx6TdP0PFwBKjqV0t0bnPWsBkQ)j6)v5xJBvoGtvaDMsNFrXXkon0LLLo1RhRPcVUgRnvQAtjDQxpwtf(cv7t8Bplt9pr)VkV8xyNIha5fV8lkowXPHUuZYowUuawuCSItdDTaQXOc7lUx1bC80kP2JNsjb(dOJtirVDifdbwH3k9Voe0KclpwJmb21MYXYLcWIIJv8BPK8UtmHlvHNFZr)zIHaepLsk9MKUetnltM6C884xraoBibMQdo2I((FvAjJHVjfwGqcbxswGGWYX1pQW0JAtjDQxpwtf(cv7t8BpltM6C8YFHDkEaKx8Ytro1SSuu)t0)RYBL(xhcAsHfiKqWLKfiiSCC9lkowXVDSCPaSO4yfpvTYuNJx(lStXdG8IxEkYzzYpNR9y5sbyrXXkonjtmvOgJkSV4EvhWXtRKApEkLe4pGooHe92Hu6IHaRWBL(xhcAsHLhRrMa7At5y5sbyrXXk(TusE3jMWLQWZV5O)mXqaINsjLEtsxIPMLjtDoEE8RiaNnKat1bhBrF)VkTPKo1RhRPcFHQ9j(TNLjtDoE5VWofpaYlE5PiNAwM8Z5ApwUuawuCSIttYetfQXOc7lUx1bC80kP2VWH8xCWFa)2XLE7qkLDSoa1Jv4NEN7T6wc0ISSDSoa1Jv4NEN7PiNQw1)e9)Q8RXTkhWPkGotPZVO4yfNgSjQOceeMiQv9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yf)wk0LyR0Ly6DPk88Bo6Ts)RdxoOJewUuKAwM8Z5ApwUuawuCSItZ9TaQXOc7lUx1bC80kP2pdsyfc4XlsME7qs9IYpGhRPd1MYowhG6Xk8tVZ9wDlzIzz7yDaQhRWp9o3trovOgJkSV4EvhWXtRKA)meeyb(TJl92H0owhG6Xk8tVZ9wD7(eZY2X6aupwHF6DUNImuJrf2xCVQd44PvsTl)f2P4bqEXl6TdP0jtDoE5VWofpaYlE5PiRnfLKDJeDApwUuawuCSIFl9tuBkQ)j6)v55XVIaC2qcmvhCSf9kPzZr(TeZYu)t0)RYZJFfb4SHeyQo4yl6xuCSIFlzIPQnfYy4BsHfiKqWLKfiiSCC9Jkm9ywM6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXk(TKjMLPFwBKjqV0t0bnPWk1SSuus2ns0P9y5sbyrXXkonKs)e1Mczm8nPWcesiGwxYceewoU(rfMEmlt9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yf)2XYLcWIIJv8u1MI6FI(FvEE8RiaNnKat1bhBrVsA2CKFlXSm1)e9)Q884xraoBibMQdo2I(ffhR43owUuawuCSINLjtDoEE8RiaNnKat1bhBrpf5utnlt(5CThlxkalkowXPjzlsnlt(5CThlxkalkowXPjzIA5pfHSvDpboDGCda2CejtGqngvyFX9QoGJNwj1op(veGZgsGP6GJTi4ynNaP3oKuF1PSWR(F7wnb2b)5Gf30JESgzcSd1yuH9f3R6aoEALu784xraoBibMQdo2I0BhsQ)j6)v55XVIaC2qcmvhCSf9kPzZroj6YYowUuawuCSItdDjMLLYowhG6Xk8tVZ9lkowXVLSfzzPKo1RhRPcVUgRnL20PE9ynv4luTpXV9u1Msk7yDaQhRWp9o3B1n1)e9)Q884xraoBibMQdo2I(dfbbyrL0S5iimrmllD7yDaQhRWp9o3JnnEWtvBkQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR43u)t0)RYZJFfb4SHeyQo4yl6pueeGfvsZMJGWeXSm9ZAJmb6LEIoOjfwPMQw1)e9)Q8hJhCWFahQTHFrXXkonKUdTkj7gj60Q(NO)xL)sYwcRYb9DY)cqMQus(ffhR40qkjDPc1yuH9f3R6aoEALu784xraoBibMQdo2I0BhsQxpwtfEDnwBkTPitDo(lCi)fh8hWVDC9uKZYs5y5sbyrXXkonQ)j6)v5VWH8xCWFa)2X1VO4yfplt9pr)Vk)foK)Id(d43oU(ffhR43u)t0)RYZJFfb4SHeyQo4yl6pueeGfvsZMJGWeXu1Q(NO)xL)y8Gd(d4qTn8lkowXPH0DOvjz3irNw1)e9)Q8xs2syvoOVt(xaYuLsYVO4yfNgsjPlvOgJkSV4EvhWXtRKANh)kcWzdjWuDWXwKE7qs96XAQWxOAFIF7AtPJYuNJx(lStXdG8IxGoktDoEkYAtN(zTrMa9sprhWXtQA7Om154L)c7u8aiV4fOJYuNJNIS2uiJHVjfwGqcbxswGGWYX1pQW0Jzz6N1gzc0l9eDqtkSYYu)t0)RYBL(xhcAsHfiKqWLKfiiSCC9lkowXVP(NO)xLNh)kcWzdjWuDWXw0FOiialQKMnhbHjIzzQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR43UpXuHAmQW(I7vDahpTsQDkocSafPVgrKeT6dQkhTDbDKhw1Gdudbb92Hezm8nPWcesi4sYceewoU(rfMEmlt9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yf)w6NO2JLlfGffhR43sE3jMLj)CU2JLlfGffhR40qxIqngvyFX9QoGJNwj1ofhbwGI0xJisYkUAPIrMabTe1ubLiOJ6nfsVDirgdFtkSaHecUKSabHLJRFuHPhZYKFox7XYLcWIIJvCAOlrOgJkSV4EvhWXtRKANIJalqr6RrejDTtiXJVq6TdjYy4BsHfiKqWLKfiiSCC9Jkm9ywM8Z5ApwUuawuCSItdDjc1yuH9f3R6aoEALu7uCeybksFnIijU00)R8D4KbXhOi92Hezm8nPWcesi4sYceewoU(rfMEmlt(5CThlxkalkowXPHUeZYs3sv453C0BL(xhUCqhjSCPaQXOc7lUx1bC80kP2P4iWcuK(AersVECvsZMJDWuM4aKNiWTb92Hezm8nPWcesi4sYceewoU(rfMEmlt9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yf)2DKywM8Z5ApwUuawuCSItdDjc1yuH9f3R6aoEALu75et3M4xoqE65i92Hezm8nPWcesi4sYceewoU(rfMEmlt(5CThlxkalkowXPjzlGAmQW(I7vDahpTsQDkocSafPVgrKuiHGJT8aWTCJGE7qImg(MuybcjeCjzbcclhx)IIJv8BjBrwM6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXk(T0prThlxkalkowXVDFIjMLj)CU2JLlfGffhR40qxIqngvyFX9QoGJNwj1ofhbwGI0xJissnkje8hWOAjkBXoiwC4ulYP3oKgvy6rawOOHCAOtRm154hvlrzl2bxt19uKZYgvy6rawOOH8Bj1ktDo(r1su2IDW0e9uKZYKFox7XYLcWIIJvCAOlrOgJkSV4EvhWXtRKANIJalqr6RrejXvZYb)bC2jWTgcapw7G0BhsPtM6C8C1SCWFaNDcCRHaWJ1oiib8uKZYKFox7XYLcWIIJvCAUVfqngvyFX9QoGJNwj1ofhbwGIC6TdP0PFwBKjqFtkSaFbO4iiwR0HrwM6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXk(n6sulzm8nPWcesi4sYceewoU(ffhR40qxIzz6N1gzc0l9eDqtkSGAmQW(I7vDahpTsQ94PusG)a0nR4qVDifdbwH3k9Voe0KclpwJmb21MYXYLcWIIJv8B3rIzzKXW3KclqiHGljlqqy546hvy6XSm9ZAJmb6LEIoOjfwzzYpNR9y5sbyrXXkonjt)uHAmQW(I7vDahpTsQ94PusG)a0nR4qVDiLUyiWk8wP)1HGMuy5XAKjWU2uowUuawuCSIFlzlUJSm9ZAJmb6LEIoOjfwPc1yuH9f3R6aoEALu7tPqESdbqnee0BhsQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR43UpXSm9ZAJmb6LEIoOjfwzzYpNR9y5sbyrXXkon0LiuJrf2xCVQd44PvsTlt8FhCO2g0BhsQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR43UpXSm9ZAJmb6LEIoOjfwzzYpNR9y5sbyrXXkon0LiuJrf2xCVQd44PvsTFSfLj(VtVDiP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIF7(eZY0pRnYeOx6j6GMuyLLj)CU2JLlfGffhR40KmrOgJkSV4EvhWXtRKAxgxoU6SkNE7qs9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yf)29jMLPFwBKjqV0t0bnPWklt(5CThlxkalkowXPjzlGAmQW(I7vDahpTsQD5jh8hqSMshNE7qsM6C884xraoBibMQdo2I((FvqngvyFX9QoGJNwj1oHLlfCaTIQNlIva1yuH9f3R6aoEALu7hcKlP25e0Bhs8NIq2QUNmfpOiqaUuKd7lTPJmg(MuybcjeCjzbcclhx)OctpQvM6C884xraoBibMQdo2I((FvALPohV8xyNIha5fV89)QO3Qa3LICamrrSBtGKssVvbUlf5aKt8YdbPK0BvG7sroa2He)PiKTQ71)etyeiG)e6XkGAa1yuH9f3R6aoUyzrds6N1gzcK(AersCCXYIgazQLh0)KjXXWo0R(QBH9fPyiWk8wP)1HGMuy5XAKjWo96hckKK6FI(FvEoUyzrd)IIJvCAsMLrgdFtkSaHecUKSabHLJRFuHPh1Q(NO)xLNJlww0WVO4yf)29jMLj)CU2JLlfGffhR40qxI0RFiOqasWrsQ)j6)v554ILfn8lkowXPjzwM6FI(FvEoUyzrd)IIJv8B3NywM8Z5ApwUuawuCSItdDjc1yuH9f3R6aoUyzrJwj1Uv6FDiOjfwGqcbxswGGWYXLE7qkD6N1gzc0l9eDqtkSYYKFox7XYLcWIIJvCAORfqngvyFX9QoGJlww0OvsTpLc5Xoea1qqqVDiPFwBKjqphxSSObqMA5buJrf2xCVQd44ILfnALu7Ye)3bhQTb92HK(zTrMa9CCXYIgazQLhqngvyFX9QoGJlww0OvsTFSfLj(VtVDiPFwBKjqphxSSObqMA5buJrf2xCVQd44ILfnALu7Y4YXvNv50Bhs6N1gzc0ZXfllAaKPwEa1yuH9f3R6aoUyzrJwj1U8Kd(diwtPJtVDiPFwBKjqphxSSObqMA5buJrf2xCVQd44ILfnALu7ZQMcbXVlwbuJrf2xCVQd44ILfnALu7XtPKa)b0XjKO3oKIHaRWBL(xhcAsHLhRrMa7At5y5sbyrXXk(TusE3jMWLQWZV5O)mXqaINsjLEtsxIPMLrgdFtkSaHecUKSabHLJRFuHPh1Ms6uVESMk8fQ2N43EwMm154L)c7u8aiV4LNICQzzPO(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIF7y5sbyrXXkEQALPohV8xyNIha5fV8uKZYKFox7XYLcWIIJvCAsMyQqngvyFX9QoGJlww0OvsThpLsc8hGUzfh6TdPyiWk8wP)1HGMuy5XAKjWU2uowUuawuCSIF7osmlJmg(MuybcjeCjzbcclhx)OctpMLj)CU2JLlfGffhR40KmXuHAmQW(I7vDahxSSOrRKApEkLe4pGooHe92Hu6IHaRWBL(xhcAsHLhRrMa7At5y5sbyrXXk(TusE3jMWLQWZV5O)mXqaINsjLEtsxIPMLjtDoE5VWofpaYlE5PiNLj)CU2JLlfGffhR40KmXuHAmQW(I7vDahxSSOrRKApEkLe4paDZko0BhsPlgcScVv6FDiOjfwESgzcSRnLJLlfGffhR43UJeZYKFox7XYLcWIIJvCAsM(Pc1yuH9f3R6aoUyzrJwj1(foK)Id(d43oU0BhsQ)j6)v5xJBvoGtvaDMsNFrXXkonyturfiimreQXOc7lUx1bCCXYIgTsQDkocSafPVgrKeT6dQkhTDbDKhw1Gdudbb92HK(zTrMa9CCXYIgazQLhzzYpNR9y5sbyrXXkon0LiuJrf2xCVQd44ILfnALu7uCeybksFnIijR4QLkgzce0sutfuIGoQ3ui92HK(zTrMa9CCXYIgazQLhzzYpNR9y5sbyrXXkon0LiuJrf2xCVQd44ILfnALu7uCeybksFnIiPRDcjE8fsVDiPFwBKjqphxSSObqMA5rwM8Z5ApwUuawuCSItdDjc1yuH9f3R6aoUyzrJwj1ofhbwGI0xJis61JRsA2CSdMYehG8ebUnO3oK0pRnYeONJlww0aitT8ilt(5CThlxkalkowXPHUeHAmQW(I7vDahxSSOrRKANIJalqr6RrejXLM(FLVdNmi(afP3oKiJHVjfwGqcbxswGGWYX1pQW0JzzYpNR9y5sbyrXXkon0Lyww6wQcp)MJER0)6WLd6iHLlfqngvyFX9QoGJlww0OvsTNtmDBIF5a5PNJ0Bhs6N1gzc0ZXfllAaKPwEa1yuH9f3R6aoUyzrJwj1ofhbwGI0xJiskKqWXwEa4wUrqVDiPFwBKjqphxSSObqMA5rwM8Z5ApwUuawuCSItdDjc1yuH9f3R6aoUyzrJwj1ofhbwGIC6TdP0PFwBKjqFtkSaFbO4iiwR0HrwM6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXk(n6smlt)S2itGEPNOdAsHfuJrf2xCVQd44ILfnALu7NbjScb84fjd1yuH9f3R6aoUyzrJwj1(ziiWc8BhxOgJkSV4EvhWXfllA0kP2L)c7u8aiV4f92HK8Z5ApwUuawuCSIttYwKLLIsYUrIoTPCSCPaSO4yf)w6NO2usr9pr)VkphxSSOHFrXXk(TKjMLjtDoEoUyzrdpf5Sm1)e9)Q8CCXYIgEkYPQnfYy4BsHfiKqWLKfiiSCC9Jkm9ywM6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXk(TKjMLPFwBKjqV0t0bnPWk1utnllLJLlfGffhR40qk9tuBkKXW3KclqiHaADjlqqy546hvy6XSm1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJv8BhlxkalkowXtn1uHAmQW(I7vDahxSSOrRKANJlww0GE7qs9pr)Vk)ACRYbCQcOZu68lkowXPHUSm5NZ1ESCPaSO4yfNMKTaQXOc7lUx1bCCXYIgTsQD5jh8hqSMshhQXOc7lUx1bCCXYIgTsQ9dbYLu7Cc6Tdj(triBv3tMIhueiaxkYH9L20rgdFtkSaHecUKSabHLJRFuHPh1ktDoEoUyzrdF)VkTYuNJx(lStXdG8Ix((Fv0BvG7sroaMOi2TjqsjP3Qa3LICaYjE5HGus6TkWDPiha7qI)ueYw196FIjmceWFc9yfqnGAmQW(I7FYyHlPJXdWFaHecUKSabHLJl9QgkceeZMJbNus6TdjLK5fNMjujz3iDpuJrf2xC)tglCBLu7ytYibqAwr6TdPyiWk8kjditT8WJ1itGDTkjZlontOsYUr6EOgJkSV4(Nmw42kP2dlhxa5HqKEvdfbcIzZXGtkj92HK6fLFapwthQvjzEXPzcvs2ns0b1yuH9f3)KXc3wj1UsYaxJEKE7qsjzEXPzcvsgj6GAmQW(I7FYyHBRKAhBsgjasZkc1yuH9f3)KXc3wj1Ey54cipeI0RAOiqqmBogCsjP3oKusMxCAMqLKDJeDqnGAmQW(I754ILfniDmEWb)bCO2g0BhsYuNJNJlww0WVO4yfNMKqngvyFX9CCXYIgTsQDozRkRYbQDkeOZu6O3oKuVO8d4XA6qTPmQW0JaSqrd53iDFw2OctpcWcfnKFlP20P(NO)xLFnUv5aovb0zkDEkYPc1yuH9f3ZXfllA0kP2xJBvoGtvaDMsh9QgkceeZMJbNus6Tdj1lk)aESMoeQXOc7lUNJlww0OvsTFmEWb)bCO2g0BhsJkm9ialu0q(ns3d1yuH9f3ZXfllA0kP25KTQSkhO2PqGotPJE7qs9IYpGhRPd1ktDo((uke8hGsYOvMNImuJrf2xCphxSSOrRKAxMyu6EQaOZu6Ox1qrGGy2Cm4KssVDiPEr5hWJ10HALPoh)foK)Id(d43oUEkYAv)t0)RYVg3QCaNQa6mLo)IIJv8B0b1yuH9f3ZXfllA0kP2pgp4G)aouBd6TkWDPiha7qkDQ)j6)v5xJBvoGtvaDMsNNImuJrf2xCphxSSOrRKANt2QYQCGANcb6mLo6Tdj1lk)aESMouBhLPohV8xyNIha5fVaDuM6C8uKHAmQW(I754ILfnALu7hJhG)acjeCjzbcclhx6vnueiiMnhdoPK0BhskjJM7HAmQW(I754ILfnALu7YeJs3tfaDMsh9QgkceeZMJbNus6Tdj1lk)aESMomllDXqGv4LSaOEr5hQXOc7lUNJlww0OvsTZjBvzvoqTtHaDMshudOgJkSV4EEq6sYwcRYb9DY)cqMQus0BhsPitDoEYRj(B3gca5pWkSHWZJrPJM7iltM6C8YFHDkEaKx8YVO4yfNg1)e9)Q8RXTkhWPkGotPZVO4yfxRm154L)c7u8aiV4LNISwYy4BsHfiKqWLKfiiSCC9Jkm9yQAtzhRdq9yf(P35ERUP(NO)xL)sYwcRYb9DY)cqMQus(o1oH9v6nr)DNLXjJeeGy2Cm43sMkuJrf2xCppALu7CYwvwLdu7uiqNP0rVDiPEr5hWJ10HALPohFFkfc(dqjz0kZtrwBk7yDaQhRWp9o3B1nzQZX3NsHG)ausgTY8lkowXtiDzz7yDaQhRWp9o3trovOgJkSV4EE0kP2peixsTZjO3Qa3LICamrrSBtGKssVvbUlf5ayhsYuNJx)tmHrGa(tOhRairjo1BDpf5SmSWnVHpmreepqCAsZ9zzQ)j6)v5xJBvoGtvaDMsNFrXXkon0LLP(NO)xL)y8Gd(d4qTn8lkowXPHo6Tdj(triBv3R)jMWiqa)j0JvOvM6C884xraoBibMQdo2I((FvA7Om154L)c7u8aiV4fOJYuNJV)xfuJrf2xCppALu7RXTkhWPkGotPJEvdfbcIzZXGtkj92HK6FI(FvEoUyzrd)IIJv8BjZYsxmeyfEoUyzrdTPO(NO)xL)chYFXb)b8Bhx)IIJv8Bjqww6uVESMk86AS2uPc1yuH9f3ZJwj1(X4bh8hWHABqVDiLYowhG6Xk8tVZ9wDt9pr)Vk)X4bh8hWHAB47u7e2xP3e93Dw2owhG6Xk8tVZ9uKtvBkyHBEdFyIiiEG408g2evubcctetyYSmLK5fNMjujz0qkzwMm1545XVIaC2qcmvhCSf9lkowXPbBIkQabHjITMm1SSJLlfGffhR40GnrfvGGWeXwtML1rzQZXl)f2P4bqEXlqhLPohpf5SmzQZXtEnXF72qai)x46Pid1yuH9f3ZJwj1UAhLocRYb0QPJaclxkkRYP3oKKPohFiHauKmU)YbQH8OS4xppgLUBjVdTyHBEdFyIiiEG408g2evubcctetysTQ)j6)v5xJBvoGtvaDMsNFrXXk(nSjQOceeMiMLjtDo(qcbOizC)Ldud5rzXVEEmkD3sMaAtr9pr)VkphxSSOHFrXXkonTqBmeyfEoUyzrJSm1)e9)Q8x4q(lo4pGF746xuCSIttl0QE9ynv411yTPYYowUuawuCSIttlsfQXOc7lUNhTsQ9LIlzvoGwnDeCzvNE7qsM6C8lfxYQCaTA6i4YQUV)xL2rfMEeGfkAi)wsOgJkSV4EE0kP2pgpa)besi4sYceewoU0RAOiqqmBogCsjP3oKusgn3d1yuH9f3ZJwj1o2KmsaKMvKE7qsjzEXPzcvs2nsjHAmQW(I75rRKAxjzazQLh0BhskjZlontOsYUrkP2rfMEeGfkAiNusT7yDaQhRWp9o3B1n6smltjzEXPzcvs2ns0PDuHPhbyHIgYVrIoOgJkSV4EE0kP2vsg4A0J0BhsPtM6C8Kxt83UneaY)fUEkYqngvyFX98OvsThwoUaYdHi9QgkceeZMJbNus6Tdj1lk)aESMouRsY8ItZeQKSBKOtRm1545XVIaC2qcmvhCSf99)QGAmQW(I75rRKANt2QYQCGANcb6mLo6TdjzQZXRKmaw4M3WZJrP729jMWwKEhvy6rawOOHCTYuNJNh)kcWzdjWuDWXw03)RsBkQ)j6)v5xJBvoGtvaDMsNFrXXk(n60Q(NO)xL)y8Gd(d4qTn8lkowXVrxwM6FI(Fv(14wLd4ufqNP05xuCSItZ9Av)t0)RYFmEWb)bCO2g(ffhR43UxRsYUDFwM6FI(Fv(14wLd4ufqNP05xuCSIF7ETQ)j6)v5pgp4G)aouBd)IIJvCAUxRsYULazzkjZlontOsYOHusTyHBEdFyIiiEG40Kg6snltM6C8kjdGfU5n88yu6ULmrThlxkalkowXPPLd1yuH9f3ZJwj1UmXO09ubqNP0rVQHIabXS5yWjLKE7qs9IYpGhRPd1MsmeyfEoUyzrdTQ)j6)v554ILfn8lkowXP5(Sm1)e9)Q8RXTkhWPkGotPZVO4yf)wsTQ)j6)v5pgp4G)aouBd)IIJv8BjZYu)t0)RYVg3QCaNQa6mLo)IIJvCAUxR6FI(Fv(JXdo4pGd12WVO4yf)29Avs2n6YYu)t0)RYVg3QCaNQa6mLo)IIJv8B3Rv9pr)Vk)X4bh8hWHAB4xuCSItZ9Avs2T7ZYus2TwKLjtDoE5xhG8(kpf5uHAmQW(I75rRKApSCCbKhcr6vnueiiMnhdoPK0BhsQxu(b8ynDOwLK5fNMjujz3irhuJrf2xCppALu7ZQMcbXVlwb92HKsY8ItZeQKSBKsc1yuH9f3ZJwj1(HOHv5aoUKXka6mLo6TkWDPihKssVDiLo1RhRPcFHQ9j(TNLjtDoEYRj(B3gca5pWkSHWtrgQXOc7lUNhTsQDzIrP7PcGotPJEvdfbcIzZXGtkj92HK6fLFapwthQv9pr)Vk)X4bh8hWHAB4xuCSItZ9Avsgj60sEr9GCv3N0hwoUaYdHOwSWnVHpmreepOfjstsOgJkSV4EE0kP2LjgLUNka6mLo6vnueiiMnhdoPK0BhsQxu(b8ynDOwSWnVHpmreepqCAsdDAtrjzEXPzcvsgnKsMLrEr9GCv3N0hwoUaYdHyQqnGAmQW(I7VWH8xCWFa)2XLKAiiaJkSVaegpOVgrKKQd44HEESMkiLKE7qkDXqGv454ILfnGAmQW(I7VWH8xCWFa)2XTvsTRgccWOc7laHXd6RrejP6aoUyzrd65XAQGus6TdPyiWk8CCXYIgqngvyFX9x4q(lo4pGF742kP2xJBvoGtvaDMsh9QgkceeZMJbNusOgJkSV4(lCi)fh8hWVDCBLu7YeJs3tfaDMsh9QgkceeZMJbNus6Tdj1lk)aESMouR6FI(Fv(JXdo4pGd12WVO4yfxR6FI(Fv(14wLd4ufqNP05xuCSIRvM6C8x4q(lo4pGF74cUU8uKHAmQW(I7VWH8xCWFa)2XTvsTZjBvzvoqTtHaDMsh92HK6fLFapwthQvM6C89Pui4paLKrRmpfzOgJkSV4(lCi)fh8hWVDCBLu7hJhCWFahQTb9wf4UuKdsjP3Qa3LICamrrSBtGKssVDijtDo(lCi)fh8hWVDCbxxEkYALPohpp(veGZgsGP6GJTONIS20XXai)ff3hgU0D3a6iR0oQW0JaSqrd50qhuJrf2xC)foK)Id(d43oUTsQ9JXdo4pGd12GE7qsM6C8x4q(lo4pGF74cUU8uK1ktDoEE8RiaNnKat1bhBrpfzTCmaYFrX9HHlD3nGoYQSSrfMEeGfkAi)gj60ktDo(lCi)fh8hWVDCbxx(ffhR40KeQXOc7lU)chYFXb)b8Bh3wj1(LKTewLd67K)fGmvPKGAmQW(I7VWH8xCWFa)2XTvsTZjBvzvoqTtHaDMsh92HK6fLFapwthQDuHPhbyHIgYVr6ETYuNJ)chYFXb)b8BhxW1LNImuJrf2xC)foK)Id(d43oUTsQ9JXdWFaHecUKSabHLJl9QgkceeZMJbNus6TdjLKrkrTYuNJ)chYFXb)b8BhxW1LFrXXkonjqwMsYO5EOgJkSV4(lCi)fh8hWVDCBLu7ytYibqAwr6TdjLK5fNMjujz3iLeQXOc7lU)chYFXb)b8Bh3wj1UsYaYulpO3oKusMxCAMqLKDJukjBDuHPhbyHIgYVLmvOgJkSV4(lCi)fh8hWVDCBLu7HLJlG8qisVQHIabXS5yWjLKE7qsjzKsuRm154VWH8xCWFa)2XfCD5xuCSIttcKLLs6IHaRWlzbq9IYFwM6fLFapwthMQwLK5fNMjujz3irhuJrf2xC)foK)Id(d43oUTsQDozRkRYbQDkeOZu6O3oKKPohVsYayHBEdppgLUB3NycBr6DuHPhbyHIgYHAmQW(I7VWH8xCWFa)2XTvsTltmkDpva0zkD0RAOiqqmBogCsjP3oKuVO8d4XA6qTJkm9ialu0qonKUxRsYUr6(SmzQZXFHd5V4G)a(TJl46YtrgQXOc7lU)chYFXb)b8Bh3wj1UsYaxJEeQXOc7lU)chYFXb)b8Bh3wj1(HOHv5aoUKXka6mLo6TkWDPihKs6egQq6xNGGjslDHlCoa]] )


end