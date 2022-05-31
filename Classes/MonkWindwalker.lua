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


    spec:RegisterPack( "Windwalker", 20220530, [[dSKi8cqirk9iPevBIu6tiLAuIeNsK0QKsqVskPzHu1TeHAxu1VKs1WebhteTmKkptLQMMiextKITjLqFtLkX4uPcNtLkADQuPMhsX9qK9Ps5GsjGfkLYdrkrtukbkxukrXgLsG8rKskoPuIsRKu4Lsjq1mrkHBQsLe7Ku0pvPsQLIusPNsWufP6RiLunwriTxQ8xGbJYHvSyI6XKmzP6YqBwfFwunAICAkRgPK8AsLzJWTj0UL8BvnCe1XLsKLR0Zr10fUos2oPQVRsgVu05LcRxLkjnFrz)G2L0LUtOpb60KUeOJUesZ9j4tMiPjH7VdNq0Gm6eipkDto6eQreDc06w1VgcD46eipni(P7s3jWFQvHobNGmLreTSLt2j0NaDAsxc0rxcP5(e8jtK0KW9obozu50KUw8oDcswVJLt2j0rUYjqRBv)Ai0HlKDx5lDqnURmnGS7tGEiJUeOJoOgqnOLsZMJ87gQrIHS0VWrhK1cY4bhY(dK1cIABazwf4UuKdiJ4ZnLhQrIHS0VWrhKjq2QYQCiJwUtHqwl4MshKr85MYd1iXqwlqVdzYpNFSCPaYusOshhYIhYeNQbKrlBbdYWkwd5EOgjgYAb6DiZQeREr5jGSwqeixsTZj8obcJhCx6oHNmw46s3Pzsx6obSgzcS7AZjmQW(YjCmEa(diKqWLKfiiSCCDcQ1cCTXjOKmV40eYsmKPKmi7gji7ENGQHIabXS5yWDAM0fonPZLUtaRrMa7U2CcQ1cCTXjedbwHxjzazQLhESgzcSdzAHmLK5fNMqwIHmLKbz3ibz37egvyF5eWMKrcG0SIUWP59U0DcynYey31MtyuH9LtiSCCbKhcrNGATaxBCcQxu(b8ynDiKPfYusMxCAczjgYusgKDJeKrNtq1qrGGy2Cm4ont6cNMjIlDNawJmb2DT5euRf4AJtqjzEXPjKLyitjzqgjiJoNWOc7lNGsYaxJE0fontJlDNWOc7lNa2KmsaKMv0jG1itGDxBUWPzl6s3jG1itGDxBoHrf2xoHWYXfqEieDcQ1cCTXjOKmV40eYsmKPKmi7gjiJoNGQHIabXS5yWDAM0fUWjCHd5V4G)a(TJRlDNMjDP7eWAKjWURnNGATaxBCcPfYIHaRWZXfllA4XAKjWUtGhRPcNMjDcJkSVCcQHGamQW(cqy8Wjqy8auJi6euDahpUWPjDU0DcynYey31MtqTwGRnoHyiWk8CCXYIgESgzcS7e4XAQWPzsNWOc7lNGAiiaJkSVaegpCcegpa1iIobvhWXfllA4cNM37s3jG1itGDxBoHrf2xoH14wLd4ufqNP05eunueiiMnhdUtZKUWPzI4s3jG1itGDxBoHrf2xobzIrP7PcGotPZjOwlW1gNG6fLFapwthczAHm1)e9)Q8hJhCWFahQTHFrXXkoKPfYu)t0)RYVg3QCaNQa6mLo)IIJvCitlKjtDo(lCi)fh8hWVDCbxxEkYobvdfbcIzZXG70mPlCAMgx6obSgzcS7AZjOwlW1gNG6fLFapwthczAHmzQZX3NsHG)ausgTY8uKDcJkSVCcCYwvwLdu7uiqNP05cNMTOlDNawJmb2DT5euRf4AJtqM6C8x4q(lo4pGF74cUU8uKHmTqMm1545XVIaC2qcmvhCSf9uKHmTqwAHmoga5VO4(WWLU7aqhzfKPfYgvy6rawOOHCiJgiJoNGvbUlf5WjK0jyvG7sroaMOi2TjqNqsNWOc7lNWX4bh8hWHAB4cNM3fx6obSgzcS7AZjOwlW1gNGm154VWH8xCWFa)2XfCD5PidzAHmzQZXZJFfb4SHeyQo4yl6PidzAHmoga5VO4(WWLU7aqhzfKLLbzJkm9ialu0qoKDJeKrhKPfYKPoh)foK)Id(d43oUGRl)IIJvCiJgilPtyuH9Lt4y8Gd(d4qTnCHtZ7WLUtyuH9Lt4sYwcRYb9DY)cqMQusobSgzcS7AZfonVtx6obSgzcS7AZjOwlW1gNG6fLFapwthczAHSrfMEeGfkAihYUrcYUhY0czYuNJ)chYFXb)b8BhxW1LNIStyuH9LtGt2QYQCGANcb6mLox40mzcU0DcynYey31MtyuH9Lt4y8a8hqiHGljlqqy546euRf4AJtqjzqgjilbitlKjtDo(lCi)fh8hWVDCbxx(ffhR4qgnqwIazzzqMsYGmAGS7DcQgkceeZMJb3Pzsx40mzsx6obSgzcS7AZjOwlW1gNGsY8IttilXqMsYGSBKGSKoHrf2xobSjzKainROlCAMKox6obSgzcS7AZjOwlW1gNGsY8IttilXqMsYGSBKGSuGSKqwRq2OctpcWcfnKdz3GSKqwQoHrf2xobLKbKPwE4cNMjV3LUtaRrMa7U2CcJkSVCcHLJlG8qi6euRf4AJtqjzqgjilbitlKjtDo(lCi)fh8hWVDCbxx(ffhR4qgnqwIazzzqwkqwAHSyiWk8swauVO87XAKjWoKLLbzQxu(b8ynDiKLkKPfYusMxCAczjgYusgKDJeKrNtq1qrGGy2Cm4ont6cNMjtex6obSgzcS7AZjOwlW1gNGm154vsgalCZB45XO0bz3GS7taYsmKLgiRfczJkm9ialu0qUtyuH9LtGt2QYQCGANcb6mLox40mzACP7eWAKjWURnNWOc7lNGmXO09ubqNP05euRf4AJtq9IYpGhRPdHmTq2OctpcWcfnKdz0qcYUhY0czkjdYUrcYUhYYYGmzQZXFHd5V4G)a(TJl46Ytr2jOAOiqqmBogCNMjDHtZKTOlDNWOc7lNGsYaxJE0jG1itGDxBUWPzY7IlDNGvbUlf5WjK0jmQW(YjCiAyvoGJlzScGotPZjG1itGDxBUWfoboUyzrdx6ont6s3jG1itGDxBob1AbU24eKPohphxSSOHFrXXkoKrdKL0jmQW(YjCmEWb)bCO2gUWPjDU0DcynYey31MtqTwGRnob1lk)aESMoeY0czPazJkm9ialu0qoKDJeKDpKLLbzJkm9ialu0qoKDdYsczAHS0czQ)j6)v5xJBvoGtvaDMsNNImKLQtyuH9LtGt2QYQCGANcb6mLox408Ex6obSgzcS7AZjmQW(YjSg3QCaNQa6mLoNGATaxBCcQxu(b8ynDOtq1qrGGy2Cm4ont6cNMjIlDNawJmb2DT5euRf4AJtyuHPhbyHIgYHSBKGS7DcJkSVCchJhCWFahQTHlCAMgx6obSgzcS7AZjOwlW1gNG6fLFapwthczAHmzQZX3NsHG)ausgTY8uKDcJkSVCcCYwvwLdu7uiqNP05cNMTOlDNawJmb2DT5egvyF5eKjgLUNka6mLoNGATaxBCcQxu(b8ynDiKPfYKPoh)foK)Id(d43oUEkYqMwit9pr)Vk)ACRYbCQcOZu68lkowXHSBqgDobvdfbcIzZXG70mPlCAExCP7eSkWDPiha74esR6FI(Fv(14wLd4ufqNP05Pi7egvyF5eogp4G)aouBdNawJmb2DT5cNM3HlDNawJmb2DT5euRf4AJtq9IYpGhRPdHmTqwhLPohV8xyNIha5fVaDuM6C8uKDcJkSVCcCYwvwLdu7uiqNP05cNM3PlDNawJmb2DT5egvyF5eogpa)besi4sYceewoUob1AbU24eusgKrdKDVtq1qrGGy2Cm4ont6cNMjtWLUtaRrMa7U2CcJkSVCcYeJs3tfaDMsNtqTwGRnob1lk)aESMoeYYYGS0czXqGv4LSaOEr53J1itGDNGQHIabXS5yWDAM0fontM0LUtyuH9LtGt2QYQCGANcb6mLoNawJmb2DT5cx4euDahxSSOHlDNMjDP7eWAKjWURnNWt2jWXWooHrf2xob9ZAJmb6e0plOgr0jWXfllAaKPwE4euRf4AJtigcScVv6FDiOjfwESgzcS7e0peuiaj4Otq9pr)VkphxSSOHFrXXkoKrdKLeYYYGm1)e9)Q8CCXYIg(ffhR4q2ni7(eGSSmit(5CitlKDSCPaSO4yfhYObYOlbNG(HGcDcQ)j6)v554ILfn8lkowXHmAGSKqwwgKrgdFtkSaHecUKSabHLJRFuHPhHmTqM6FI(FvEoUyzrd)IIJvCi7gKDFcqwwgKj)CoKPfYowUuawuCSIdz0az0LGlCAsNlDNawJmb2DT5euRf4AJtiTqM(zTrMa9sprh0KclilldYKFohY0czhlxkalkowXHmAGm6sJtyuH9LtWk9Voe0Kclx408Ex6obSgzcS7AZjOwlW1gNG(zTrMa9CCXYIgazQLhoHrf2xoHPuip2HaOgccx40mrCP7eWAKjWURnNGATaxBCc6N1gzc0ZXfllAaKPwE4egvyF5eKj(VdouBdx40mnU0DcynYey31MtqTwGRnob9ZAJmb654ILfnaYulpCcJkSVCchBrzI)7UWPzl6s3jG1itGDxBob1AbU24e0pRnYeONJlww0aitT8WjmQW(YjiJlhxDwL7cNM3fx6obSgzcS7AZjOwlW1gNG(zTrMa9CCXYIgazQLhoHrf2xob5jh8hqSMsh3fonVdx6oHrf2xoHzvtHG43fRWjG1itGDxBUWP5D6s3jG1itGDxBob1AbU24eIHaRWBL(xhcAsHLhRrMa7qMwilfi7y5sbyrXXkoKDdYsbYsEhjazjgYwQcp)MJ(ZedbiEkLKhRrMa7qwleYssxcqwQqwwgKrgdFtkSaHecUKSabHLJRFuHPhHmTqwkqwAHm1RhRPcFHQ9j(TdzzzqMm154L)c7u8aiV4LNImKLkKLLbzPazQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR4q2ni7y5sbyrXXkoKLkKPfYKPohV8xyNIha5fV8uKHSSmit(5CitlKDSCPaSO4yfhYObYsMaKLQtyuH9LtiEkLe4pGooHKlCAMmbx6obSgzcS7AZjOwlW1gNqmeyfER0)6qqtkS8ynYeyhY0czPazhlxkalkowXHSBq2DMaKLLbzKXW3KclqiHGljlqqy546hvy6rilldYKFohY0czhlxkalkowXHmAGSKjazP6egvyF5eINsjb(dq3SIJlCAMmPlDNawJmb2DT5euRf4AJtiTqwmeyfER0)6qqtkS8ynYeyhY0czPazhlxkalkowXHSBqwkqwY7ibilXq2sv453C0FMyiaXtPK8ynYeyhYAHqws6saYsfYYYGmzQZXl)f2P4bqEXlpfzilldYKFohY0czhlxkalkowXHmAGSKjazP6egvyF5eINsjb(dOJti5cNMjPZLUtaRrMa7U2CcQ1cCTXjKwilgcScVv6FDiOjfwESgzcSdzAHSuGSJLlfGffhR4q2ni7otaYYYGm5NZHmTq2XYLcWIIJvCiJgilzlczP6egvyF5eINsjb(dq3SIJlCAM8Ex6obSgzcS7AZjOwlW1gNG6FI(Fv(14wLd4ufqNP05xuCSIdz0azyturfiimr0jmQW(YjCHd5V4G)a(TJRlCAMmrCP7eWAKjWURnNWOc7lNaT6dQkhTDbDKhw1GdudbHtqTwGRnob9ZAJmb654ILfnaYulpGSSmit(5CitlKDSCPaSO4yfhYObYOlbNqnIOtGw9bvLJ2UGoYdRAWbQHGWfontMgx6obSgzcS7AZjmQW(YjyfxTuXitGGwIAQGse0r9McDcQ1cCTXjOFwBKjqphxSSObqMA5bKLLbzYpNdzAHSJLlfGffhR4qgnqgDj4eQreDcwXvlvmYeiOLOMkOebDuVPqx40mzl6s3jG1itGDxBoHrf2xoHRDcjE8f6euRf4AJtq)S2itGEoUyzrdGm1YdilldYKFohY0czhlxkalkowXHmAGm6sWjuJi6eU2jK4XxOlCAM8U4s3jG1itGDxBoHrf2xoHxpUkPzZXoyktCaYte42WjOwlW1gNG(zTrMa9CCXYIgazQLhqwwgKj)CoKPfYowUuawuCSIdz0az0LGtOgr0j86XvjnBo2btzIdqEIa3gUWPzY7WLUtaRrMa7U2CcJkSVCcCPP)x57WjdIpqrNGATaxBCcKXW3KclqiHGljlqqy546hvy6rilldYKFohY0czhlxkalkowXHmAGm6saYYYGS0czlvHNFZrVv6FD4YbDKWYLcpwJmb2Dc1iIobU00)R8D4KbXhOOlCAM8oDP7eWAKjWURnNGATaxBCc6N1gzc0ZXfllAaKPwE4egvyF5eYjMUnXVCG80Zrx40KUeCP7eWAKjWURnNWOc7lNqiHGJT8aWTCJWjOwlW1gNG(zTrMa9CCXYIgazQLhqwwgKj)CoKPfYowUuawuCSIdz0az0LGtOgr0jesi4ylpaCl3iCHtt6s6s3jG1itGDxBoHrf2xobC2qsEXrhUCGjsEuHtqTwGRnob9ZAJmb654ILfnaYulpGSSmit(5CitlKDSCPaSO4yfhYObYOlbNqnIOtaNnKKxC0HlhyIKhv4cNM0rNlDNawJmb2DT5euRf4AJtiTqM(zTrMa9nPWc8fGIJGyTshgqwwgKP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz3Gm6saYYYGm9ZAJmb6LEIoOjfwoHrf2xobkocSaf5UWPjD37s3jmQW(YjCgKWkeWJxKStaRrMa7U2CHtt6sex6oHrf2xoHZqqGf43oUobSgzcS7AZfonPlnU0DcynYey31MtqTwGRnob5NZHmTq2XYLcWIIJvCiJgilzAGSSmilfitjzq2nsqgDqMwilfi7y5sbyrXXkoKDdYAXeGmTqwkqwkqM6FI(FvEoUyzrd)IIJvCi7gKLmbilldYKPohphxSSOHNImKLLbzQ)j6)v554ILfn8uKHSuHmTqwkqgzm8nPWcesi4sYceewoU(rfMEeYYYGm1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gKLmbilldY0pRnYeOx6j6GMuybzPczPczPczzzqwkq2XYLcWIIJvCiJgsqwlMaKPfYsbYiJHVjfwGqcb06swGGWYX1pQW0JqwwgKP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz3GSJLlfGffhR4qwQqwQqwQoHrf2xob5VWofpaYlE5cNM01IU0DcynYey31MtqTwGRnob1)e9)Q8RXTkhWPkGotPZVO4yfhYObYOdYYYGm5NZHmTq2XYLcWIIJvCiJgilzACcJkSVCcCCXYIgUWPjD3fx6oHrf2xob5jh8hqSMsh3jG1itGDxBUWPjD3HlDNawJmb2DT5euRf4AJtG)ueYw19KP4bfbcWLICyF5XAKjWoKPfYslKrgdFtkSaHecUKSabHLJRFuHPhHmTqMm15454ILfn89)QGmTqMm154L)c7u8aiV4LV)xLtWQa3LICaSJtG)ueYw196FIjmceWFc9yfobRcCxkYbWefXUnb6es6egvyF5eoeixsTZjCcwf4UuKdqoXlpeoHKUWfobE4s3Pzsx6obSgzcS7AZjOwlW1gNqkqMm154jVM4VDBiaK)aRWgcppgLoiJgi7oHSSmitM6C8YFHDkEaKx8YVO4yfhYObYu)t0)RYVg3QCaNQa6mLo)IIJvCitlKjtDoE5VWofpaYlE5PidzAHmYy4BsHfiKqWLKfiiSCC9Jkm9iKLkKPfYsbY2X6aupwHF6DU3ki7gKP(NO)xL)sYwcRYb9DY)cqMQus(o1oH9fK1cHSe83bKLLbzCYibbiMnhdoKDdYsczP6egvyF5eUKSLWQCqFN8VaKPkLKlCAsNlDNawJmb2DT5euRf4AJtq9IYpGhRPdHmTqMm1547tPqWFakjJwzEkYqMwilfiBhRdq9yf(P35ERGSBqMm1547tPqWFakjJwz(ffhR4qwIHm6GSSmiBhRdq9yf(P35EkYqwQoHrf2xobozRkRYbQDkeOZu6CHtZ7DP7eWAKjWURnNGATaxBCc8NIq2QUx)tmHrGa(tOhRWJ1itGDitlKjtDoEE8RiaNnKat1bhBrF)VkitlK1rzQZXl)f2P4bqEXlqhLPohF)VkNGvbUlf5ayhNGm1541)etyeiG)e6XkasuIt9w3troldlCZB4dtebXdeNM0CFwM6FI(Fv(14wLd4ufqNP05xuCSItdDzzQ)j6)v5pgp4G)aouBd)IIJvCAOZjyvG7sroaMOi2TjqNqsNWOc7lNWHa5sQDoHlCAMiU0DcynYey31MtyuH9LtynUv5aovb0zkDob1AbU24eu)t0)RYZXfllA4xuCSIdz3GSKqwwgKLwilgcScphxSSOHhRrMa7qMwilfit9pr)Vk)foK)Id(d43oU(ffhR4q2nilrGSSmilTqM61J1uHxxJ1McYs1jOAOiqqmBogCNMjDHtZ04s3jG1itGDxBob1AbU24esbY2X6aupwHF6DU3ki7gKP(NO)xL)y8Gd(d4qTn8DQDc7liRfczj4VdilldY2X6aupwHF6DUNImKLkKPfYsbYWc38g(Werq8aXPjKDdYWMOIkqqyIiKLyiljKLLbzkjZlonHSedzkjdYOHeKLeYYYGmzQZXZJFfb4SHeyQo4yl6xuCSIdz0azyturfiimreYAfYsczPczzzq2XYLcWIIJvCiJgidBIkQabHjIqwRqwsilldY6Om154L)c7u8aiV4fOJYuNJNImKLLbzYuNJN8AI)2THaq(VW1tr2jmQW(YjCmEWb)bCO2gUWPzl6s3jG1itGDxBob1AbU24eKPohFiHauKmU)YbQH8OS4xppgLoi7gKL8oHmTqgw4M3WhMicIhionHSBqg2evubccteHSedzjHmTqM6FI(Fv(14wLd4ufqNP05xuCSIdz3GmSjQOceeMiczzzqMm154djeGIKX9xoqnKhLf)65XO0bz3GSKjcKPfYsbYu)t0)RYZXfllA4xuCSIdz0azPbY0czXqGv454ILfn8ynYeyhYYYGm1)e9)Q8x4q(lo4pGF746xuCSIdz0azPbY0czQxpwtfEDnwBkilldYowUuawuCSIdz0azPbYs1jmQW(YjO2rPJWQCaTA6iGWYLIYQCx408U4s3jG1itGDxBob1AbU24eKPoh)sXLSkhqRMocUSQ77)vbzAHSrfMEeGfkAihYUbzjDcJkSVCclfxYQCaTA6i4YQUlCAEhU0DcynYey31MtyuH9Lt4y8a8hqiHGljlqqy546euRf4AJtqjzqgnq29obvdfbcIzZXG70mPlCAENU0DcynYey31MtqTwGRnobLK5fNMqwIHmLKbz3ibzjDcJkSVCcytYibqAwrx40mzcU0DcynYey31MtqTwGRnobLK5fNMqwIHmLKbz3ibzjHmTq2OctpcWcfnKdzKGSKqMwiBhRdq9yf(P35ERGSBqgDjazzzqMsY8IttilXqMsYGSBKGm6GmTq2OctpcWcfnKdz3ibz05egvyF5eusgqMA5HlCAMmPlDNawJmb2DT5euRf4AJtiTqMm154jVM4VDBiaK)lC9uKDcJkSVCckjdCn6rx40mjDU0DcynYey31MtyuH9LtiSCCbKhcrNGATaxBCcQxu(b8ynDiKPfYusMxCAczjgYusgKDJeKrhKPfYKPohpp(veGZgsGP6GJTOV)xLtq1qrGGy2Cm4ont6cNMjV3LUtaRrMa7U2CcQ1cCTXjitDoELKbWc38gEEmkDq2ni7(eGSedzPbYAHq2OctpcWcfnKdzAHmzQZXZJFfb4SHeyQo4yl67)vbzAHSuGm1)e9)Q8RXTkhWPkGotPZVO4yfhYUbz0bzAHm1)e9)Q8hJhCWFahQTHFrXXkoKDdYOdYYYGm1)e9)Q8RXTkhWPkGotPZVO4yfhYObYUhY0czQ)j6)v5pgp4G)aouBd)IIJvCi7gKDpKPfYusgKDdYUhYYYGm1)e9)Q8RXTkhWPkGotPZVO4yfhYUbz3dzAHm1)e9)Q8hJhCWFahQTHFrXXkoKrdKDpKPfYusgKDdYseilldYusMxCAczjgYusgKrdjiljKPfYWc38g(Werq8aXPjKrdKrhKLkKLLbzYuNJxjzaSWnVHNhJshKDdYsMaKPfYowUuawuCSIdz0az3fNWOc7lNaNSvLv5a1ofc0zkDUWPzYeXLUtaRrMa7U2CcJkSVCcYeJs3tfaDMsNtqTwGRnob1lk)aESMoeY0czPazXqGv454ILfn8ynYeyhY0czQ)j6)v554ILfn8lkowXHmAGS7HSSmit9pr)Vk)ACRYbCQcOZu68lkowXHSBqwsitlKP(NO)xL)y8Gd(d4qTn8lkowXHSBqwsilldYu)t0)RYVg3QCaNQa6mLo)IIJvCiJgi7EitlKP(NO)xL)y8Gd(d4qTn8lkowXHSBq29qMwitjzq2niJoilldYu)t0)RYVg3QCaNQa6mLo)IIJvCi7gKDpKPfYu)t0)RYFmEWb)bCO2g(ffhR4qgnq29qMwitjzq2ni7EilldYusgKDdYsdKLLbzYuNJx(1biVVYtrgYs1jOAOiqqmBogCNMjDHtZKPXLUtaRrMa7U2CcJkSVCcHLJlG8qi6euRf4AJtq9IYpGhRPdHmTqMsY8IttilXqMsYGSBKGm6CcQgkceeZMJb3Pzsx40mzl6s3jG1itGDxBob1AbU24eusMxCAczjgYusgKDJeKL0jmQW(YjmRAkee)UyfUWPzY7IlDNawJmb2DT5euRf4AJtiTqM61J1uHVq1(e)2HSSmitM6C8Kxt83UneaYFGvydHNIStyuH9Lt4q0WQCahxYyfaDMsNtWQa3LIC4es6cNMjVdx6obSgzcS7AZjmQW(YjitmkDpva0zkDob1AbU24euVO8d4XA6qitlKP(NO)xL)y8Gd(d4qTn8lkowXHmAGS7HmTqMsYGmsqgDqMwiJ8I6b5QUpPpSCCbKhcritlKHfU5n8HjIG4bPjbiJgilPtq1qrGGy2Cm4ont6cNMjVtx6obSgzcS7AZjmQW(YjitmkDpva0zkDob1AbU24euVO8d4XA6qitlKHfU5n8HjIG4bIttiJgiJoitlKLcKPKmV40eYsmKPKmiJgsqwsilldYiVOEqUQ7t6dlhxa5HqeYs1jOAOiqqmBogCNMjDHlCcQoGJhx6ont6s3jG1itGDxBob1AbU24eslKPFwBKjqV0t0bnPWcY0czPazQ)j6)v5xJBvoGtvaDMsNFrXXkoKrdKrhKLLbzPfYuVESMk86AS2uqwQqMwilfilTqM61J1uHVq1(e)2HSSmit9pr)VkV8xyNIha5fV8lkowXHmAGm6GSuHSSmi7y5sbyrXXkoKrdKrxACcJkSVCcwP)1HGMuy5cNM05s3jG1itGDxBob1AbU24eIHaRWBL(xhcAsHLhRrMa7qMwilfi7y5sbyrXXkoKDdYsbYsEhjazjgYwQcp)MJ(ZedbiEkLKhRrMa7qwleYssxcqwQqwwgKjtDoEE8RiaNnKat1bhBrF)VkitlKrgdFtkSaHecUKSabHLJRFuHPhHmTqwkqwAHm1RhRPcFHQ9j(TdzzzqMm154L)c7u8aiV4LNImKLkKLLbzPazQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR4q2ni7y5sbyrXXkoKLkKPfYKPohV8xyNIha5fV8uKHSSmit(5CitlKDSCPaSO4yfhYObYsMaKLQtyuH9LtiEkLe4pGooHKlCAEVlDNawJmb2DT5euRf4AJtiTqwmeyfER0)6qqtkS8ynYeyhY0czPazhlxkalkowXHSBqwkqwY7ibilXq2sv453C0FMyiaXtPK8ynYeyhYAHqws6saYsfYYYGmzQZXZJFfb4SHeyQo4yl67)vbzAHSuGS0czQxpwtf(cv7t8BhYYYGmzQZXl)f2P4bqEXlpfzilvilldYKFohY0czhlxkalkowXHmAGSKjazP6egvyF5eINsjb(dOJti5cNMjIlDNawJmb2DT5euRf4AJtifiBhRdq9yf(P35ERGSBqwIKgilldY2X6aupwHF6DUNImKLkKPfYu)t0)RYVg3QCaNQa6mLo)IIJvCiJgidBIkQabHjIqMwit9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yfhYUbzPaz0LaK1kKrxcqwleYwQcp)MJER0)6WLd6iHLlfESgzcSdzPczzzqM8Z5qMwi7y5sbyrXXkoKrdKDFACcJkSVCcx4q(lo4pGF746cNMPXLUtaRrMa7U2CcQ1cCTXjOEr5hWJ10HqMwilfiBhRdq9yf(P35ERGSBqwYeGSSmiBhRdq9yf(P35EkYqwQoHrf2xoHZGewHaE8IKDHtZw0LUtaRrMa7U2CcQ1cCTXjSJ1bOESc)07CVvq2ni7(eGSSmiBhRdq9yf(P35EkYoHrf2xoHZqqGf43oUUWP5DXLUtaRrMa7U2CcQ1cCTXjKwitM6C8YFHDkEaKx8YtrgY0czPazkjdYUrcYOdY0czhlxkalkowXHSBqwlMaKPfYsbYu)t0)RYZJFfb4SHeyQo4yl6vsZMJCi7gKLaKLLbzQ)j6)v55XVIaC2qcmvhCSf9lkowXHSBqwYeGSuHmTqwkqgzm8nPWcesi4sYceewoU(rfMEeYYYGm1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gKLmbilldY0pRnYeOx6j6GMuybzPczzzqwkqMsYGSBKGm6GmTq2XYLcWIIJvCiJgsqwlMaKPfYsbYiJHVjfwGqcb06swGGWYX1pQW0JqwwgKP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz3GSJLlfGffhR4qwQqMwilfit9pr)Vkpp(veGZgsGP6GJTOxjnBoYHSBqwcqwwgKP(NO)xLNh)kcWzdjWuDWXw0VO4yfhYUbzhlxkalkowXHSSmitM6C884xraoBibMQdo2IEkYqwQqwQqwwgKj)CoKPfYowUuawuCSIdz0azjtdKLkKLLbzYpNdzAHSJLlfGffhR4qgnqwYeGmTqg)PiKTQ7jWPdKBaWMJizc0J1itGDNWOc7lNG8xyNIha5fVCHtZ7WLUtaRrMa7U2CcQ1cCTXjO(QtzHx9)2TAcSd(ZblUPh9ynYey3jmQW(YjWJFfb4SHeyQo4ylcowZjqx408oDP7eWAKjWURnNGATaxBCcQ)j6)v55XVIaC2qcmvhCSf9kPzZroKrcYOdYYYGSJLlfGffhR4qgnqgDjazzzqwkq2owhG6Xk8tVZ9lkowXHSBqwY0azzzqwkqwAHm1RhRPcVUgRnfKPfYslKPE9ynv4luTpXVDilvitlKLcKLcKTJ1bOESc)07CVvq2nit9pr)Vkpp(veGZgsGP6GJTO)qrqawujnBoccteHSSmilTq2owhG6Xk8tVZ9ytJhCilvitlKLcKP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz3Gm1)e9)Q884xraoBibMQdo2I(dfbbyrL0S5iimreYYYGm9ZAJmb6LEIoOjfwqwQqwQqMwit9pr)Vk)X4bh8hWHAB4xuCSIdz0qcYUtitlKPKmi7gjiJoitlKP(NO)xL)sYwcRYb9DY)cqMQus(ffhR4qgnKGSK0bzP6egvyF5e4XVIaC2qcmvhCSfDHtZKj4s3jG1itGDxBob1AbU24euVESMk86AS2uqMwilfitM6C8x4q(lo4pGF746Pidzzzqwkq2XYLcWIIJvCiJgit9pr)Vk)foK)Id(d43oU(ffhR4qwwgKP(NO)xL)chYFXb)b8Bhx)IIJvCi7gKP(NO)xLNh)kcWzdjWuDWXw0FOiialQKMnhbHjIqwQqMwit9pr)Vk)X4bh8hWHAB4xuCSIdz0qcYUtitlKPKmi7gjiJoitlKP(NO)xL)sYwcRYb9DY)cqMQus(ffhR4qgnKGSK0bzP6egvyF5e4XVIaC2qcmvhCSfDHtZKjDP7eWAKjWURnNGATaxBCcQxpwtf(cv7t8BhY0czPazDuM6C8YFHDkEaKx8c0rzQZXtrgY0czPfY0pRnYeOx6j6aoEGSuHmTqwhLPohV8xyNIha5fVaDuM6C8uKHmTqwkqgzm8nPWcesi4sYceewoU(rfMEeYYYGm9ZAJmb6LEIoOjfwqwwgKP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz3Gm1)e9)Q884xraoBibMQdo2I(dfbbyrL0S5iimreYYYGm1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gKDFcqwQoHrf2xobE8RiaNnKat1bhBrx40mjDU0DcynYey31MtyuH9LtGw9bvLJ2UGoYdRAWbQHGWjOwlW1gNazm8nPWcesi4sYceewoU(rfMEeYYYGm1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gK1IjazAHSJLlfGffhR4q2nil5DKaKLLbzYpNdzAHSJLlfGffhR4qgnqgDj4eQreDc0QpOQC02f0rEyvdoqneeUWPzY7DP7eWAKjWURnNWOc7lNGvC1sfJmbcAjQPckrqh1Bk0jOwlW1gNazm8nPWcesi4sYceewoU(rfMEeYYYGm5NZHmTq2XYLcWIIJvCiJgiJUeCc1iIobR4QLkgzce0sutfuIGoQ3uOlCAMmrCP7eWAKjWURnNWOc7lNW1oHep(cDcQ1cCTXjqgdFtkSaHecUKSabHLJRFuHPhHSSmit(5CitlKDSCPaSO4yfhYObYOlbNqnIOt4ANqIhFHUWPzY04s3jG1itGDxBoHrf2xobU00)R8D4KbXhOOtqTwGRnobYy4BsHfiKqWLKfiiSCC9Jkm9iKLLbzYpNdzAHSJLlfGffhR4qgnqgDjazzzqwAHSLQWZV5O3k9VoC5Gosy5sHhRrMa7oHAerNaxA6)v(oCYG4du0font2IU0DcynYey31MtyuH9Lt41JRsA2CSdMYehG8ebUnCcQ1cCTXjqgdFtkSaHecUKSabHLJRFuHPhHSSmit9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yfhYUbz3zcqwwgKj)CoKPfYowUuawuCSIdz0az0LGtOgr0j86XvjnBo2btzIdqEIa3gUWPzY7IlDNawJmb2DT5euRf4AJtGmg(MuybcjeCjzbcclhx)OctpczzzqM8Z5qMwi7y5sbyrXXkoKrdKLmnoHrf2xoHCIPBt8lhip9C0fontEhU0DcynYey31MtyuH9LtiKqWXwEa4wUr4euRf4AJtGmg(MuybcjeCjzbcclhx)IIJvCi7gKLmnqwwgKP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz3GSwmbitlKDSCPaSO4yfhYUbz3NqcqwwgKj)CoKPfYowUuawuCSIdz0az0LGtOgr0jesi4ylpaCl3iCHtZK3PlDNawJmb2DT5egvyF5euJscb)bmQwIYwSdIfho1ICNGATaxBCcJkm9ialu0qoKrdKrhKPfYKPoh)OAjkBXo4AQUNImKLLbzJkm9ialu0qoKDdYsczAHmzQZXpQwIYwSdMMONImKLLbzYpNdzAHSJLlfGffhR4qgnqgDj4eQreDcQrjHG)agvlrzl2bXIdNArUlCAsxcU0DcynYey31MtyuH9LtGRMLd(d4StGBneaES2bDcQ1cCTXjKwitM6C8C1SCWFaNDcCRHaWJ1oiir8uKHSSmit(5CitlKDSCPaSO4yfhYObYUpnoHAerNaxnlh8hWzNa3Aia8yTd6cNM0L0LUtaRrMa7U2CcJkSVCc4SHK8IJoC5atK8OcNGATaxBCcQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR4q2nilnPbYYYGm9ZAJmb6LEIoOjfwqwwgKj)CoKPfYowUuawuCSIdz0azjtJtOgr0jGZgsYlo6WLdmrYJkCHtt6OZLUtaRrMa7U2CcQ1cCTXjKwit)S2itG(Muyb(cqXrqSwPddilldYu)t0)RYBL(xhcAsHfiKqWLKfiiSCC9lkowXHSBqgDjazAHmYy4BsHfiKqWLKfiiSCC9lkowXHmAGm6saYYYGm9ZAJmb6LEIoOjfwoHrf2xobkocSaf5UWPjD37s3jG1itGDxBob1AbU24eIHaRWBL(xhcAsHLhRrMa7qMwilfi7y5sbyrXXkoKDdYUZeGSSmiJmg(MuybcjeCjzbcclhx)OctpczzzqM(zTrMa9sprh0KclilldYKFohY0czhlxkalkowXHmAGSKTiKLQtyuH9LtiEkLe4paDZkoUWPjDjIlDNawJmb2DT5euRf4AJtiTqwmeyfER0)6qqtkS8ynYeyhY0czPazhlxkalkowXHSBqwY0CNqwwgKPFwBKjqV0t0bnPWcYs1jmQW(YjepLsc8hGUzfhx40KU04s3jG1itGDxBob1AbU24eu)t0)RYBL(xhcAsHfiKqWLKfiiSCC9lkowXHSBq29jazzzqM(zTrMa9sprh0KclilldYKFohY0czhlxkalkowXHmAGm6sWjmQW(YjmLc5Xoea1qq4cNM01IU0DcynYey31MtqTwGRnob1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gKDFcqwwgKPFwBKjqV0t0bnPWcYYYGm5NZHmTq2XYLcWIIJvCiJgiJUeCcJkSVCcYe)3bhQTHlCAs3DXLUtaRrMa7U2CcQ1cCTXjO(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz3GS7taYYYGm9ZAJmb6LEIoOjfwqwwgKj)CoKPfYowUuawuCSIdz0azjtWjmQW(YjCSfLj(V7cNM0DhU0DcynYey31MtqTwGRnob1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJvCi7gKDFcqwwgKPFwBKjqV0t0bnPWcYYYGm5NZHmTq2XYLcWIIJvCiJgilzACcJkSVCcY4YXvNv5UWPjD3PlDNawJmb2DT5euRf4AJtqM6C884xraoBibMQdo2I((FvoHrf2xob5jh8hqSMsh3fonVpbx6oHrf2xobclxk4aAfvpxeRWjG1itGDxBUWP59jDP7eWAKjWURnNGATaxBCc8NIq2QUNmfpOiqaUuKd7lpwJmb2HmTqwAHmYy4BsHfiKqWLKfiiSCC9Jkm9iKPfYKPohpp(veGZgsGP6GJTOV)xfKPfYKPohV8xyNIha5fV89)QCcwf4UuKdGDCc8NIq2QUx)tmHrGa(tOhRWjyvG7sroaMOi2TjqNqsNWOc7lNWHa5sQDoHtWQa3LICaYjE5HWjK0fUWj0XZqreU0DAM0LUtyuH9LtGtgNfinvhWJ10HobSgzcS7AZfonPZLUtaRrMa7U2CcpzNahdNWOc7lNG(zTrMaDc6hck0jO(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz3GSJLlfGffhR4qwwgKDSCPaSO4yfhYsmKP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIdz0azjPlbitlKLcKLcKfdbwHNJlww0WJ1itGDitlKDSCPaSO4yfhYUbzQ)j6)v554ILfn8lkowXHmTqM6FI(FvEoUyzrd)IIJvCi7gKLmbilvilldYsbYu)t0)RYZJFfb4SHeyQo4yl6pueeGfvsZMJGWeriJgi7y5sbyrXXkoKPfYu)t0)RYZJFfb4SHeyQo4yl6pueeGfvsZMJGWeri7gKLmnqwQqwwgKLcKP(NO)xLNh)kcWzdjWuDWXw0RKMnh5qgjilbitlKP(NO)xLNh)kcWzdjWuDWXw0VO4yfhYObYowUuawuCSIdzPczP6e0plOgr0ji9eDqtkSCHtZ7DP7eWAKjWURnNWt2jWXWjmQW(YjOFwBKjqNG(HGcDcQ)j6)v5L)c7u8aiV4LNImKPfYu)t0)RYZJFfb4SHeyQo4yl6vsZMJCiJgiJoitlKPKmiJgi7EilldYKPohV8xyNIha5fV8lkowXHmAGS7WjOFwqnIOtq6j6aoECHtZeXLUtaRrMa7U2CcQ1cCTXjedbwH3k9Voe0KclpwJmb2HmTqwkqwkqMm15454ILfn8uKHSSmitM6C884xraoBibMQdo2IEkYqwQqMwiJmg(MuybcjeCjzbcclhx)OctpczzzqM8Z5qMwi7y5sbyrXXkoKrdjiRftaYs1jmQW(Yjq(d7lx40mnU0DcynYey31MtqTwGRnoH0czXqGv4Ts)RdbnPWYJ1itGDitlKLcKLcKjtDoEoUyzrdpfzilldYKPohpp(veGZgsGP6GJTONImKLkKPfYowUuawuCSIdz0qcYAXeGSuDcJkSVCcK)W(YfonBrx6obSgzcS7AZjOwlW1gNGm15454ILfn8uKDc8ynv40mPtyuH9LtqneeGrf2xacJhobcJhGAerNahxSSOHlCAExCP7eWAKjWURnNGATaxBCcYuNJ)chYFXb)b8BhxpfzNapwtfont6egvyF5eudbbyuH9fGW4HtGW4bOgr0jCHd5V4G)a(TJRlCAEhU0DcynYey31MtqTwGRnoHWeriJgilrGmTqMsYGmAGS0azAHS0czKXW3KclqiHGljlqqy546hvy6rNapwtfont6egvyF5eudbbyuH9fGW4HtGW4bOgr0j8KXcxx408oDP7eWAKjWURnNWOc7lNWX4b4pGqcbxswGGWYX1jOwlW1gNGsY8IttilXqMsYGSBKGS7HmTqwkqgw4M3WhMicIhionHmAGSKqwwgKHfU5n8HjIG4bIttiJgilrGmTqM6FI(Fv(JXdo4pGd12WVO4yfhYObYs6tdKLLbzQ)j6)v5VWH8xCWFa)2X1VO4yfhYObYOdYsfY0czPfY6Om154L)c7u8aiV4fOJYuNJNIStq1qrGGy2Cm4ont6cNMjtWLUtaRrMa7U2CcQ1cCTXjOKmV40eYsmKPKmi7gjiljKPfYsbYWc38g(Werq8aXPjKrdKLeYYYGm1)e9)Q8CCXYIg(ffhR4qgnqgDqwwgKHfU5n8HjIG4bIttiJgilrGmTqM6FI(Fv(JXdo4pGd12WVO4yfhYObYs6tdKLLbzQ)j6)v5VWH8xCWFa)2X1VO4yfhYObYOdYsfY0czPfYKPohV8xyNIha5fV8uKDcJkSVCcytYibqAwrx40mzsx6obSgzcS7AZjmQW(YjewoUaYdHOtqTwGRnob1lk)aESMoeY0czkjZlonHSedzkjdYUrcYOdY0czPazyHBEdFyIiiEG40eYObYsczzzqM6FI(FvEoUyzrd)IIJvCiJgiJoilldYWc38g(Werq8aXPjKrdKLiqMwit9pr)Vk)X4bh8hWHAB4xuCSIdz0azj9PbYYYGm1)e9)Q8x4q(lo4pGF746xuCSIdz0az0bzPczAHS0czDuM6C8YFHDkEaKx8c0rzQZXtr2jOAOiqqmBogCNMjDHtZK05s3jG1itGDxBob1AbU24euVESMk8LLlfGZGqMwit9pr)Vk)zqcRqapErY(ffhR4q2niJU0azAHSuGmLK5fNMqwIHmLKbz3ibzjHmTq2OctpcWcfnKdzKGSKqMwiBhRdq9yf(P35ERGSBqgDjazzzqMsY8IttilXqMsYGSBKGm6GmTq2OctpcWcfnKdz3ibz0bzP6egvyF5eusgqMA5HlCAM8Ex6obSgzcS7AZjOwlW1gNa5f1dYvDFsFy54cipeIqMwitjzqgnqwI4egvyF5eWc3C7UQv5aKWAARlCAMmrCP7eWAKjWURnNGATaxBCcPfYIHaRWZXfllA4XAKjWUtGhRPcNMjDcJkSVCcQHGamQW(cqy8Wjqy8auJi6euDahpUWPzY04s3jG1itGDxBob1AbU24eIHaRWZXfllA4XAKjWUtGhRPcNMjDcJkSVCcQHGamQW(cqy8Wjqy8auJi6euDahxSSOHlCAMSfDP7eWAKjWURnNGATaxBCcJkm9ialu0qoKrdKDVtGhRPcNMjDcJkSVCcQHGamQW(cqy8Wjqy8auJi6e4HlCAM8U4s3jG1itGDxBob1AbU24egvy6rawOOHCi7gji7ENapwtfont6egvyF5eudbbyuH9fGW4HtGW4bOgr0jmp6cx4eiVO6fLNWLUtZKU0DcJkSVCcYFeeyhCiMgy)YQCq8nTYjG1itGDxBUWPjDU0DcynYey31Mt4j7e4y4egvyF5e0pRnYeOtq)qqHobSLOmYKXU3kUAPIrMabTe1ubLiOJ6nfczzzqg2sugzYy3NtmDBIF5a5PNJqwwgKHTeLrMm29x7es84leYYYGmSLOmYKXU)1JRsA2CSdMYehG8ebUnGSSmidBjkJmzS75st)VY3HtgeFGIqwwgKHTeLrMm29Heco2Yda3YncilldYWwIYitg7E1OKqWFaJQLOSf7GyXHtTi3jOFwqnIOtOjfwGVauCeeRv6WWfonV3LUtyuH9Lt4qGCj1oNWjG1itGDxBUWPzI4s3jG1itGDxBob1AbU24eslKPE9ynv4llxkaNbDcJkSVCckjditT8WfontJlDNawJmb2DT5euRf4AJtiTqwmeyfESWn3URAvoajSM46XAKjWUtyuH9LtqjzGRrp6cx4eMhDP70mPlDNWOc7lNWLKTewLd67K)fGmvPKCcynYey31MlCAsNlDNawJmb2DT5euRf4AJtq9IYpGhRPdHmTqwkqMm1547tPqWFakjJwzEkYqwwgK1rzQZXl)f2P4bqEXlqhLPohpfzilvNWOc7lNaNSvLv5a1ofc0zkDUWP59U0DcynYey31MtqTwGRnobSWnVHpmreepqCAcz3GmSjQOceeMiczzzqMsY8IttilXqMsYGmAibzjDcJkSVCchJhCWFahQTHlCAMiU0DcynYey31MtyuH9LtynUv5aovb0zkDob1AbU24esbYIHaRWFjzlHv5G(o5FbitvkjpwJmb2HmTqM6FI(Fv(14wLd4ufqNP057u7e2xq2nit9pr)Vk)LKTewLd67K)fGmvPK8lkowXHSwHSebYsfY0czPazQ)j6)v5pgp4G)aouBd)IIJvCi7gKDpKLLbzkjdYUrcYsdKLQtq1qrGGy2Cm4ont6cNMPXLUtaRrMa7U2CcQ1cCTXjitDo(LIlzvoGwnDeCzv33)RYjmQW(YjSuCjRYb0QPJGlR6UWPzl6s3jG1itGDxBob1AbU24eusMxCAczjgYusgKDJeKL0jmQW(YjGnjJeaPzfDHtZ7IlDNawJmb2DT5egvyF5eogpa)besi4sYceewoUob1AbU24eusMxCAczjgYusgKDJeKDVtq1qrGGy2Cm4ont6cNM3HlDNawJmb2DT5euRf4AJtqjzEXPjKLyitjzq2nsqgDoHrf2xobLKbKPwE4cNM3PlDNawJmb2DT5euRf4AJtqM6C8HecqrY4(lhOgYJYIF98yu6GSBqwY7eY0czyHBEdFyIiiEG40eYUbzyturfiimreYsmKLeY0czQ)j6)v5pgp4G)aouBd)IIJvCi7gKHnrfvGGWerNWOc7lNGAhLocRYb0QPJaclxkkRYDHtZKj4s3jG1itGDxBoHrf2xoHWYXfqEieDcQ1cCTXjOKmV40eYsmKPKmi7gjiJoitlKLcKLwilgcScVKfa1lk)ESgzcSdzzzqM6fLFapwthczP6eunueiiMnhdUtZKUWPzYKU0DcynYey31MtqTwGRnobLK5fNMqwIHmLKbz3ibzjDcJkSVCcZQMcbXVlwHlCAMKox6obSgzcS7AZjOwlW1gNG6fLFapwthczAHSuGm1)e9)Q8YFHDkEaKx8YVO4yfhYUbz0bzzzqwAHm1RhRPcFHQ9j(TdzPczAHSuGmLKbz3ibzPbYYYGm1)e9)Q8hJhCWFahQTHFrXXkoKDdYArilldYu)t0)RYFmEWb)bCO2g(ffhR4q2ni7EitlKPKmi7gji7EitlKHfU5n8HjIG4bPjbiJgiljKLLbzyHBEdFyIiiEG40eYOHeKLcKDpK1kKDpK1cHm1)e9)Q8hJhCWFahQTHFrXXkoKrdKLgilvilldYKPohpp(veGZgsGP6GJTONImKLQtyuH9LtGt2QYQCGANcb6mLox40m59U0DcynYey31MtqTwGRnob1lk)aESMo0jmQW(YjOKmW1OhDHtZKjIlDNawJmb2DT5egvyF5eoenSkhWXLmwbqNP05euRf4AJtqM6C8YVoa59v((FvobRcCxkYHtiPlCAMmnU0DcynYey31MtyuH9LtqMyu6EQaOZu6CcQ1cCTXjOEr5hWJ10HqMwilfitM6C8YVoa59vEkYqwwgKfdbwHxYcG6fLFpwJmb2HmTqg5f1dYvDFsFy54cipeIqMwitjzqgjiJoitlKP(NO)xL)y8Gd(d4qTn8lkowXHmAGS7HSSmitjzEXPjKLyitjzqgnKGSKqMwiJ8I6b5QUpPNt2QYQCGANcb6mLoitlKHfU5n8HjIG4bIttiJgi7EilvNGQHIabXS5yWDAM0fUWfob94YTVCAsxc0rxcPHU7DcxZwwLZDc06Ta0A1SLvtAn3nKbzPlHqMjs(3aYo)cz0(chYFXb)b8BhxAdzl2su2IDiJ)IiKnuXlob2HmL0u5i3d1GwyfczjVBiJw(LECdSdz0ogcScFIsBilEiJ2XqGv4tupwJmb2PnKnbK1YCxtlGSus2mvpudAHviKr3Ddz0YV0JBGDiJ2XqGv4tuAdzXdz0ogcScFI6XAKjWoTHSjGSwM7AAbKLsYMP6HAqlScHSK3F3qgT8l94gyhYODmeyf(eL2qw8qgTJHaRWNOESgzcStBilLKnt1d1aQbTElaTwnBz1KwZDdzqw6siKzIK)nGSZVqgT54ILfnOnKTylrzl2Hm(lIq2qfV4eyhYustLJCpudAHviKLmH7gYOLFPh3a7qgTJHaRWNO0gYIhYODmeyf(e1J1itGDAdztazTm310cilLKnt1d1aQbTElaTwnBz1KwZDdzqw6siKzIK)nGSZVqgTvDahxSSObTHSfBjkBXoKXFreYgQ4fNa7qMsAQCK7HAqlScHS78UHmA5x6XnWoKr7LQWZV5OprPnKfpKr7LQWZV5Opr9ynYeyN2qwkjBMQhQbTWkeYsM8UHmA5x6XnWoKr7LQWZV5OprPnKfpKr7LQWZV5Opr9ynYeyN2qwkjBMQhQbTWkeYsEh3nKrl)spUb2HmAVufE(nh9jkTHS4HmAVufE(nh9jQhRrMa70gYMaYAzURPfqwkjBMQhQbTWkeYO7oUBiJw(LECdSdz0M)ueYw19jkTHS4HmAZFkczR6(e1J1itGDAdzPKSzQEOgqnO1BbO1QzlRM0AUBidYsxcHmtK8VbKD(fYOnpOnKTylrzl2Hm(lIq2qfV4eyhYustLJCpudAHviKD)Ddz0YV0JBGDiJ28NIq2QUprPnKfpKrB(triBv3NOESgzcStBilLKnt1d1GwyfczjYDdz0YV0JBGDiJ2XqGv4tuAdzXdz0ogcScFI6XAKjWoTHSus2mvpudAHviK1I3nKrl)spUb2HmAhdbwHprPnKfpKr7yiWk8jQhRrMa70gYsjzZu9qnOfwHqwYe5UHmA5x6XnWoKr7yiWk8jkTHS4HmAhdbwHpr9ynYeyN2qwkjBMQhQbudA9waATA2YQjTM7gYGS0LqiZej)BazNFHmAR6aoEOnKTylrzl2Hm(lIq2qfV4eyhYustLJCpudAHviKr3Ddz0YV0JBGDiJ2lvHNFZrFIsBilEiJ2lvHNFZrFI6XAKjWoTHSus2mvpudAHviKD)Ddz0YV0JBGDiJ2lvHNFZrFIsBilEiJ2lvHNFZrFI6XAKjWoTHSus2mvpudAHviKLi3nKrl)spUb2HmAVufE(nh9jkTHS4HmAVufE(nh9jQhRrMa70gYsjzZu9qnOfwHq2D5UHmA5x6XnWoKrB(triBv3NO0gYIhYOn)PiKTQ7tupwJmb2PnKnbK1YCxtlGSus2mvpudAHviKLmn3nKrl)spUb2HmAVufE(nh9jkTHS4HmAVufE(nh9jQhRrMa70gYMaYAzURPfqwkjBMQhQbTWkeYUp5Ddz0YV0JBGDiJ28NIq2QUprPnKfpKrB(triBv3NOESgzcStBilLKnt1d1aQbTElaTwnBz1KwZDdzqw6siKzIK)nGSZVqgT74zOicAdzl2su2IDiJ)IiKnuXlob2HmL0u5i3d1Gwyfcz0D3qgT8l94gyhYODmeyf(eL2qw8qgTJHaRWNOESgzcStBilLKnt1d1GwyfczjtK7gYOLFPh3a7qgTJHaRWNO0gYIhYODmeyf(e1J1itGDAdztazTm310cilLKnt1d1GwyfczjtZDdz0YV0JBGDiJ2XqGv4tuAdzXdz0ogcScFI6XAKjWoTHSjGSwM7AAbKLsYMP6HAa1GwVfGwRMTSAsR5UHmilDjeYmrY)gq25xiJ2ZJ0gYwSLOSf7qg)friBOIxCcSdzkPPYrUhQbTWkeYsK7gYOLFPh3a7qgTJHaRWNO0gYIhYODmeyf(e1J1itGDAdzPKSzQEOg0cRqilzc3nKrl)spUb2HmAhdbwHprPnKfpKr7yiWk8jQhRrMa70gYsjzZu9qnOfwHqwY0C3qgT8l94gyhYODmeyf(eL2qw8qgTJHaRWNOESgzcStBilLKnt1d1aQrlRi5FdSdz3jKnQW(cYimEW9qnCcK3)yeOtOL3YHmADR6xdHoCHS7kFPdQrlVLdz3vMgq29jqpKrxc0rhudOgT8woKrlLMnh53nuJwElhYsmKL(fo6GSwqgp4q2FGSwquBdiZQa3LICazeFUP8qnA5TCilXqw6x4OdYeiBvzvoKrl3PqiRfCtPdYi(Ct5HA0YB5qwIHSwGEhYKFo)y5sbKPKqLooKfpKjovdiJw2cgKHvSgY9qnA5TCilXqwlqVdzwLy1lkpbK1cIa5sQDoHhQbuJwElhYAzAIkQa7qMmE(fHm1lkpbKjJ5wX9qwlGsHKdoKvFLyPzfpueq2Oc7loK9frdpuJrf2xCp5fvVO8eTsQD5pccSdoetdSFzvoi(Mwb1yuH9f3tEr1lkprRKAx)S2itG0xJisQjfwGVauCeeRv6WG(Nmjog0RFiOqsylrzKjJDVvC1sfJmbcAjQPckrqh1BkmldBjkJmzS7ZjMUnXVCG80ZXSmSLOmYKXU)ANqIhFHzzylrzKjJD)RhxL0S5yhmLjoa5jcCBKLHTeLrMm29CPP)x57WjdIpqXSmSLOmYKXUpKqWXwEa4wUrKLHTeLrMm29QrjHG)agvlrzl2bXIdNArouJrf2xCp5fvVO8eTsQ9dbYLu7CcOgJkSV4EYlQEr5jALu7kjditT8GE7qkTQxpwtf(YYLcWzqOgJkSV4EYlQEr5jALu7kjdCn6r6TdP0gdbwHhlCZT7QwLdqcRjUESgzcSd1aQrlVLdzTmnrfvGDid1JBdilmreYcjeYgv8lKzCiB0pgXitGEOgJkSV4K4KXzbst1b8ynDiuJrf2x8wj1U(zTrMaPVgrKK0t0bnPWI(Nmjog0RFiOqsQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR43owUuawuCSINLDSCPaSO4yfpXQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR40KKUe0MskXqGv454ILfn0ESCPaSO4yf)M6FI(FvEoUyzrd)IIJvCTQ)j6)v554ILfn8lkowXVLmHuZYsr9pr)Vkpp(veGZgsGP6GJTO)qrqawujnBoccteP5y5sbyrXXkUw1)e9)Q884xraoBibMQdo2I(dfbbyrL0S5iimr8wY0KAwwkQ)j6)v55XVIaC2qcmvhCSf9kPzZroPe0Q(NO)xLNh)kcWzdjWuDWXw0VO4yfNMJLlfGffhR4PMkuJrf2x8wj1U(zTrMaPVgrKK0t0bC8q)tMehd61peuij1)e9)Q8YFHDkEaKx8YtrwR6FI(FvEE8RiaNnKat1bhBrVsA2CKtdDAvsgn3NLjtDoE5VWofpaYlE5xuCSItZDa1yuH9fVvsTt(d7l6TdPyiWk8wP)1HGMuy5XAKjWU2usrM6C8CCXYIgEkYzzYuNJNh)kcWzdjWuDWXw0trovTKXW3KclqiHGljlqqy546hvy6XSm5NZ1ESCPaSO4yfNgsTycPc1yuH9fVvsTt(d7l6TdP0gdbwH3k9Voe0KclpwJmb21MskYuNJNJlww0WtroltM6C884xraoBibMQdo2IEkYPQ9y5sbyrXXkonKAXesfQXOc7lERKAxneeGrf2xacJh0xJisIJlww0GEESMkiLKE7qsM6C8CCXYIgEkYqngvyFXBLu7QHGamQW(cqy8G(Aersx4q(lo4pGF74sppwtfKssVDijtDo(lCi)fh8hWVDC9uKHAmQW(I3kP2vdbbyuH9fGW4b91iIKEYyHl98ynvqkj92HuyIinjIwLKrtA0MwYy4BsHfiKqWLKfiiSCC9Jkm9iuJrf2x8wj1(X4b4pGqcbxswGGWYXLEvdfbcIzZXGtkj92HKsY8ItZeRKSBKUxBkyHBEdFyIiiEG40KMKzzyHBEdFyIiiEG40KMerR6FI(Fv(JXdo4pGd12WVO4yfNMK(0KLP(NO)xL)chYFXb)b8Bhx)IIJvCAOlvTPTJYuNJx(lStXdG8IxGoktDoEkYqngvyFXBLu7ytYibqAwr6TdjLK5fNMjwjz3iLuBkyHBEdFyIiiEG40KMKzzQ)j6)v554ILfn8lkowXPHUSmSWnVHpmreepqCAstIOv9pr)Vk)X4bh8hWHAB4xuCSIttsFAYYu)t0)RYFHd5V4G)a(TJRFrXXkon0LQ20ktDoE5VWofpaYlE5Pid1yuH9fVvsThwoUaYdHi9QgkceeZMJbNus6Tdj1lk)aESMouRsY8ItZeRKSBKOtBkyHBEdFyIiiEG40KMKzzQ)j6)v554ILfn8lkowXPHUSmSWnVHpmreepqCAstIOv9pr)Vk)X4bh8hWHAB4xuCSIttsFAYYu)t0)RYFHd5V4G)a(TJRFrXXkon0LQ202rzQZXl)f2P4bqEXlqhLPohpfzOgJkSV4TsQDLKbKPwEqVDiPE9ynv4llxkaNb1Q(NO)xL)miHviGhViz)IIJv8B0LgTPOKmV40mXkj7gPKAhvy6rawOOHCsj1UJ1bOESc)07CVv3OlHSmLK5fNMjwjz3irN2rfMEeGfkAi)gj6sfQXOc7lERKAhlCZT7QwLdqcRPT0BhsKxupix19j9HLJlG8qiQvjz0KiqngvyFXBLu7QHGamQW(cqy8G(AersQoGJh65XAQGus6TdP0gdbwHNJlww0aQXOc7lERKAxneeGrf2xacJh0xJiss1bCCXYIg0ZJ1ubPK0BhsXqGv454ILfnGAmQW(I3kP2vdbbyuH9fGW4b91iIK4b98ynvqkj92H0OctpcWcfnKtZ9qngvyFXBLu7QHGamQW(cqy8G(AersZJ0ZJ1ubPK0BhsJkm9ialu0q(ns3d1aQXOc7lUFEK0LKTewLd67K)fGmvPKGAmQW(I7NhBLu7CYwvwLdu7uiqNP0rVDiPEr5hWJ10HAtrM6C89Pui4paLKrRmpf5SSoktDoE5VWofpaYlEb6Om154PiNkuJrf2xC)8yRKA)y8Gd(d4qTnO3oKWc38g(Werq8aXP5nSjQOceeMiMLPKmV40mXkjJgsjHAmQW(I7NhBLu7RXTkhWPkGotPJEvdfbcIzZXGtkj92HukXqGv4VKSLWQCqFN8VaKPkLKw1)e9)Q8RXTkhWPkGotPZ3P2jSVUP(NO)xL)sYwcRYb9DY)cqMQus(ffhR4TMiPQnf1)e9)Q8hJhCWFahQTHFrXXk(T7ZYus2nsPjvOgJkSV4(5Xwj1(sXLSkhqRMocUSQtVDijtDo(LIlzvoGwnDeCzv33)RcQXOc7lUFESvsTJnjJeaPzfP3oKusMxCAMyLKDJusOgJkSV4(5Xwj1(X4b4pGqcbxswGGWYXLEvdfbcIzZXGtkj92HKsY8ItZeRKSBKUhQXOc7lUFESvsTRKmGm1Yd6TdjLK5fNMjwjz3irhuJrf2xC)8yRKAxTJshHv5aA10raHLlfLv50BhsYuNJpKqaksg3F5a1qEuw8RNhJs3TK3PwSWnVHpmreepqCAEdBIkQabHjIjoPw1)e9)Q8hJhCWFahQTHFrXXk(nSjQOceeMic1yuH9f3pp2kP2dlhxa5HqKEvdfbcIzZXGtkj92HKsY8ItZeRKSBKOtBkPngcScVKfa1lk)zzQxu(b8ynDyQqngvyFX9ZJTsQ9zvtHG43fRGE7qsjzEXPzIvs2nsjHAmQW(I7NhBLu7CYwvwLdu7uiqNP0rVDiPEr5hWJ10HAtr9pr)VkV8xyNIha5fV8lkowXVrxwwAvVESMk8fQ2N43EQAtrjz3iLMSm1)e9)Q8hJhCWFahQTHFrXXk(Twmlt9pr)Vk)X4bh8hWHAB4xuCSIF7ETkj7gP71IfU5n8HjIG4bPjbAsMLHfU5n8HjIG4bIttAiLY9TEFlu9pr)Vk)X4bh8hWHAB4xuCSIttAsnltM6C884xraoBibMQdo2IEkYPc1yuH9f3pp2kP2vsg4A0J0BhsQxu(b8ynDiuJrf2xC)8yRKA)q0WQCahxYyfaDMsh92HKm154LFDaY7R89)QO3Qa3LICqkjuJrf2xC)8yRKAxMyu6EQaOZu6Ox1qrGGy2Cm4KssVDiPEr5hWJ10HAtrM6C8YVoa59vEkYzzXqGv4LSaOEr5xl5f1dYvDFsFy54cipeIAvsgj60Q(NO)xL)y8Gd(d4qTn8lkowXP5(SmLK5fNMjwjz0qkPwYlQhKR6(KEozRkRYbQDkeOZu60IfU5n8HjIG4bIttAUpvOgqngvyFX9QoGJhswP)1HGMuybcjeCjzbcclhx6TdP0QFwBKjqV0t0bnPWsBkQ)j6)v5xJBvoGtvaDMsNFrXXkon0LLLw1RhRPcVUgRnvQAtjTQxpwtf(cv7t8Bplt9pr)VkV8xyNIha5fV8lkowXPHUuZYowUuawuCSItdDPbQXOc7lUx1bC80kP2JNsjb(dOJtirVDifdbwH3k9Voe0KclpwJmb21MYXYLcWIIJv8BPK8osiXlvHNFZr)zIHaepLsQfMKUesnltM6C884xraoBibMQdo2I((FvAjJHVjfwGqcbxswGGWYX1pQW0JAtjTQxpwtf(cv7t8BpltM6C8YFHDkEaKx8Ytro1SSuu)t0)RYBL(xhcAsHfiKqWLKfiiSCC9lkowXVDSCPaSO4yfpvTYuNJx(lStXdG8IxEkYzzYpNR9y5sbyrXXkonjtivOgJkSV4EvhWXtRKApEkLe4pGooHe92HuAJHaRWBL(xhcAsHLhRrMa7At5y5sbyrXXk(TusEhjK4LQWZV5O)mXqaINsj1ctsxcPMLjtDoEE8RiaNnKat1bhBrF)VkTPKw1RhRPcFHQ9j(TNLjtDoE5VWofpaYlE5PiNAwM8Z5ApwUuawuCSIttYesfQXOc7lUx1bC80kP2VWH8xCWFa)2XLE7qkLDSoa1Jv4NEN7T6wIKMSSDSoa1Jv4NEN7PiNQw1)e9)Q8RXTkhWPkGotPZVO4yfNgSjQOceeMiQv9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yf)wk0LqR0LqlCPk88Bo6Ts)RdxoOJewUuKAwM8Z5ApwUuawuCSItZ9PbQXOc7lUx1bC80kP2pdsyfc4XlsME7qs9IYpGhRPd1MYowhG6Xk8tVZ9wDlzczz7yDaQhRWp9o3trovOgJkSV4EvhWXtRKA)meeyb(TJl92H0owhG6Xk8tVZ9wD7(eYY2X6aupwHF6DUNImuJrf2xCVQd44PvsTl)f2P4bqEXl6TdP0ktDoE5VWofpaYlE5PiRnfLKDJeDApwUuawuCSIFRftqBkQ)j6)v55XVIaC2qcmvhCSf9kPzZr(TeYYu)t0)RYZJFfb4SHeyQo4yl6xuCSIFlzcPQnfYy4BsHfiKqWLKfiiSCC9Jkm9ywM6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXk(TKjKLPFwBKjqV0t0bnPWk1SSuus2ns0P9y5sbyrXXkonKAXe0Mczm8nPWcesiGwxYceewoU(rfMEmlt9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yf)2XYLcWIIJv8u1MI6FI(FvEE8RiaNnKat1bhBrVsA2CKFlHSm1)e9)Q884xraoBibMQdo2I(ffhR43owUuawuCSINLjtDoEE8RiaNnKat1bhBrpf5utnlt(5CThlxkalkowXPjzAsnlt(5CThlxkalkowXPjzcA5pfHSvDpboDGCda2CejtGqngvyFX9QoGJNwj1op(veGZgsGP6GJTi4ynNaP3oKuF1PSWR(F7wnb2b)5Gf30JESgzcSd1yuH9f3R6aoEALu784xraoBibMQdo2I0BhsQ)j6)v55XVIaC2qcmvhCSf9kPzZroj6YYowUuawuCSItdDjKLLYowhG6Xk8tVZ9lkowXVLmnzzPKw1RhRPcVUgRnL20QE9ynv4luTpXV9u1Msk7yDaQhRWp9o3B1n1)e9)Q884xraoBibMQdo2I(dfbbyrL0S5iimrmllT7yDaQhRWp9o3JnnEWtvBkQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR43u)t0)RYZJFfb4SHeyQo4yl6pueeGfvsZMJGWeXSm9ZAJmb6LEIoOjfwPMQw1)e9)Q8hJhCWFahQTHFrXXkonKUtTkj7gj60Q(NO)xL)sYwcRYb9DY)cqMQus(ffhR40qkjDPc1yuH9f3R6aoEALu784xraoBibMQdo2I0BhsQxpwtfEDnwBkTPitDo(lCi)fh8hWVDC9uKZYs5y5sbyrXXkonQ)j6)v5VWH8xCWFa)2X1VO4yfplt9pr)Vk)foK)Id(d43oU(ffhR43u)t0)RYZJFfb4SHeyQo4yl6pueeGfvsZMJGWeXu1Q(NO)xL)y8Gd(d4qTn8lkowXPH0DQvjz3irNw1)e9)Q8xs2syvoOVt(xaYuLsYVO4yfNgsjPlvOgJkSV4EvhWXtRKANh)kcWzdjWuDWXwKE7qs96XAQWxOAFIF7AtPJYuNJx(lStXdG8IxGoktDoEkYAtR(zTrMa9sprhWXtQA7Om154L)c7u8aiV4fOJYuNJNIS2uiJHVjfwGqcbxswGGWYX1pQW0Jzz6N1gzc0l9eDqtkSYYu)t0)RYBL(xhcAsHfiKqWLKfiiSCC9lkowXVP(NO)xLNh)kcWzdjWuDWXw0FOiialQKMnhbHjIzzQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR43UpHuHAmQW(I7vDahpTsQDkocSafPVgrKeT6dQkhTDbDKhw1Gdudbb92Hezm8nPWcesi4sYceewoU(rfMEmlt9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yf)wlMG2JLlfGffhR43sEhjKLj)CU2JLlfGffhR40qxcqngvyFX9QoGJNwj1ofhbwGI0xJisYkUAPIrMabTe1ubLiOJ6nfsVDirgdFtkSaHecUKSabHLJRFuHPhZYKFox7XYLcWIIJvCAOlbOgJkSV4EvhWXtRKANIJalqr6RrejDTtiXJVq6TdjYy4BsHfiKqWLKfiiSCC9Jkm9ywM8Z5ApwUuawuCSItdDja1yuH9f3R6aoEALu7uCeybksFnIijU00)R8D4KbXhOi92Hezm8nPWcesi4sYceewoU(rfMEmlt(5CThlxkalkowXPHUeYYs7sv453C0BL(xhUCqhjSCPaQXOc7lUx1bC80kP2P4iWcuK(AersVECvsZMJDWuM4aKNiWTb92Hezm8nPWcesi4sYceewoU(rfMEmlt9pr)VkVv6FDiOjfwGqcbxswGGWYX1VO4yf)2DMqwM8Z5ApwUuawuCSItdDja1yuH9f3R6aoEALu75et3M4xoqE65i92Hezm8nPWcesi4sYceewoU(rfMEmlt(5CThlxkalkowXPjzAGAmQW(I7vDahpTsQDkocSafPVgrKuiHGJT8aWTCJGE7qImg(MuybcjeCjzbcclhx)IIJv8BjttwM6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXk(TwmbThlxkalkowXVDFcjKLj)CU2JLlfGffhR40qxcqngvyFX9QoGJNwj1ofhbwGI0xJissnkje8hWOAjkBXoiwC4ulYP3oKgvy6rawOOHCAOtRm154hvlrzl2bxt19uKZYgvy6rawOOH8Bj1ktDo(r1su2IDW0e9uKZYKFox7XYLcWIIJvCAOlbOgJkSV4EvhWXtRKANIJalqr6RrejXvZYb)bC2jWTgcapw7G0BhsPvM6C8C1SCWFaNDcCRHaWJ1oiir8uKZYKFox7XYLcWIIJvCAUpnqngvyFX9QoGJNwj1ofhbwGI0xJiscNnKKxC0HlhyIKhvqVDiP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIFlnPjlt)S2itGEPNOdAsHvwM8Z5ApwUuawuCSIttY0a1yuH9f3R6aoEALu7uCeybkYP3oKsR(zTrMa9nPWc8fGIJGyTshgzzQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR43OlbTKXW3KclqiHGljlqqy546xuCSItdDjKLPFwBKjqV0t0bnPWcQXOc7lUx1bC80kP2JNsjb(dq3SId92HumeyfER0)6qqtkS8ynYeyxBkhlxkalkowXVDNjKLrgdFtkSaHecUKSabHLJRFuHPhZY0pRnYeOx6j6GMuyLLj)CU2JLlfGffhR40KSftfQXOc7lUx1bC80kP2JNsjb(dq3SId92HuAJHaRWBL(xhcAsHLhRrMa7At5y5sbyrXXk(TKP5oZY0pRnYeOx6j6GMuyLkuJrf2xCVQd44PvsTpLc5Xoea1qqqVDiP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIF7(eYY0pRnYeOx6j6GMuyLLj)CU2JLlfGffhR40qxcqngvyFX9QoGJNwj1UmX)DWHABqVDiP(NO)xL3k9Voe0KclqiHGljlqqy546xuCSIF7(eYY0pRnYeOx6j6GMuyLLj)CU2JLlfGffhR40qxcqngvyFX9QoGJNwj1(XwuM4)o92HK6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXk(T7tilt)S2itGEPNOdAsHvwM8Z5ApwUuawuCSIttYeGAmQW(I7vDahpTsQDzC54QZQC6Tdj1)e9)Q8wP)1HGMuybcjeCjzbcclhx)IIJv8B3NqwM(zTrMa9sprh0KcRSm5NZ1ESCPaSO4yfNMKPbQXOc7lUx1bC80kP2LNCWFaXAkDC6TdjzQZXZJFfb4SHeyQo4yl67)vb1yuH9f3R6aoEALu7ewUuWb0kQEUiwbuJrf2xCVQd44PvsTFiqUKANtqVDiXFkczR6EYu8GIab4sroSV0MwYy4BsHfiKqWLKfiiSCC9Jkm9OwzQZXZJFfb4SHeyQo4yl67)vPvM6C8YFHDkEaKx8Y3)RIERcCxkYbWefXUnbskj9wf4UuKdqoXlpeKssVvbUlf5ayhs8NIq2QUx)tmHrGa(tOhRaQbuJrf2xCVQd44ILfniPFwBKjq6RrejXXfllAaKPwEq)tMehd7qV6RUf2xKIHaRWBL(xhcAsHLhRrMa70RFiOqsQ)j6)v554ILfn8lkowXPjzwgzm8nPWcesi4sYceewoU(rfMEuR6FI(FvEoUyzrd)IIJv8B3NqwM8Z5ApwUuawuCSItdDjqV(HGcbibhjP(NO)xLNJlww0WVO4yfNMKzzQ)j6)v554ILfn8lkowXVDFczzYpNR9y5sbyrXXkon0LauJrf2xCVQd44ILfnALu7wP)1HGMuybcjeCjzbcclhx6TdP0QFwBKjqV0t0bnPWklt(5CThlxkalkowXPHU0a1yuH9f3R6aoUyzrJwj1(ukKh7qaudbb92HK(zTrMa9CCXYIgazQLhqngvyFX9QoGJlww0OvsTlt8FhCO2g0Bhs6N1gzc0ZXfllAaKPwEa1yuH9f3R6aoUyzrJwj1(XwuM4)o92HK(zTrMa9CCXYIgazQLhqngvyFX9QoGJlww0OvsTlJlhxDwLtVDiPFwBKjqphxSSObqMA5buJrf2xCVQd44ILfnALu7Yto4pGynLoo92HK(zTrMa9CCXYIgazQLhqngvyFX9QoGJlww0OvsTpRAkee)UyfqngvyFX9QoGJlww0OvsThpLsc8hqhNqIE7qkgcScVv6FDiOjfwESgzcSRnLJLlfGffhR43sj5DKqIxQcp)MJ(ZedbiEkLulmjDjKAwgzm8nPWcesi4sYceewoU(rfMEuBkPv96XAQWxOAFIF7zzYuNJx(lStXdG8IxEkYPMLLI6FI(FvER0)6qqtkSaHecUKSabHLJRFrXXk(TJLlfGffhR4PQvM6C8YFHDkEaKx8Ytrolt(5CThlxkalkowXPjzcPc1yuH9f3R6aoUyzrJwj1E8ukjWFa6MvCO3oKIHaRWBL(xhcAsHLhRrMa7At5y5sbyrXXk(T7mHSmYy4BsHfiKqWLKfiiSCC9Jkm9ywM8Z5ApwUuawuCSIttYesfQXOc7lUx1bCCXYIgTsQ94PusG)a64es0BhsPngcScVv6FDiOjfwESgzcSRnLJLlfGffhR43sj5DKqIxQcp)MJ(ZedbiEkLulmjDjKAwMm154L)c7u8aiV4LNICwM8Z5ApwUuawuCSIttYesfQXOc7lUx1bCCXYIgTsQ94PusG)a0nR4qVDiL2yiWk8wP)1HGMuy5XAKjWU2uowUuawuCSIF7otilt(5CThlxkalkowXPjzlMkuJrf2xCVQd44ILfnALu7x4q(lo4pGF74sVDiP(NO)xLFnUv5aovb0zkD(ffhR40GnrfvGGWerOgJkSV4EvhWXfllA0kP2P4iWcuK(Aers0QpOQC02f0rEyvdoqnee0Bhs6N1gzc0ZXfllAaKPwEKLj)CU2JLlfGffhR40qxcqngvyFX9QoGJlww0OvsTtXrGfOi91iIKSIRwQyKjqqlrnvqjc6OEtH0Bhs6N1gzc0ZXfllAaKPwEKLj)CU2JLlfGffhR40qxcqngvyFX9QoGJlww0OvsTtXrGfOi91iIKU2jK4Xxi92HK(zTrMa9CCXYIgazQLhzzYpNR9y5sbyrXXkon0LauJrf2xCVQd44ILfnALu7uCeybksFnIiPxpUkPzZXoyktCaYte42GE7qs)S2itGEoUyzrdGm1YJSm5NZ1ESCPaSO4yfNg6saQXOc7lUx1bCCXYIgTsQDkocSafPVgrKexA6)v(oCYG4duKE7qImg(MuybcjeCjzbcclhx)OctpMLj)CU2JLlfGffhR40qxczzPDPk88Bo6Ts)RdxoOJewUua1yuH9f3R6aoUyzrJwj1EoX0Tj(LdKNEosVDiPFwBKjqphxSSObqMA5buJrf2xCVQd44ILfnALu7uCeybksFnIiPqcbhB5bGB5gb92HK(zTrMa9CCXYIgazQLhzzYpNR9y5sbyrXXkon0LauJrf2xCVQd44ILfnALu7uCeybksFnIijC2qsEXrhUCGjsEub92HK(zTrMa9CCXYIgazQLhzzYpNR9y5sbyrXXkon0LauJrf2xCVQd44ILfnALu7uCeybkYP3oKsR(zTrMa9nPWc8fGIJGyTshgzzQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR43OlHSm9ZAJmb6LEIoOjfwqngvyFX9QoGJlww0OvsTFgKWkeWJxKmuJrf2xCVQd44ILfnALu7NHGalWVDCHAmQW(I7vDahxSSOrRKAx(lStXdG8Ix0BhsYpNR9y5sbyrXXkonjttwwkkj7gj60MYXYLcWIIJv8BTycAtjf1)e9)Q8CCXYIg(ffhR43sMqwMm15454ILfn8uKZYu)t0)RYZXfllA4PiNQ2uiJHVjfwGqcbxswGGWYX1pQW0JzzQ)j6)v5Ts)RdbnPWcesi4sYceewoU(ffhR43sMqwM(zTrMa9sprh0KcRutn1SSuowUuawuCSItdPwmbTPqgdFtkSaHecO1LSabHLJRFuHPhZYu)t0)RYBL(xhcAsHfiKqWLKfiiSCC9lkowXVDSCPaSO4yfp1utfQXOc7lUx1bCCXYIgTsQDoUyzrd6Tdj1)e9)Q8RXTkhWPkGotPZVO4yfNg6YYKFox7XYLcWIIJvCAsMgOgJkSV4EvhWXfllA0kP2LNCWFaXAkDCOgJkSV4EvhWXfllA0kP2peixsTZjO3oK4pfHSvDpzkEqrGaCPih2xAtlzm8nPWcesi4sYceewoU(rfMEuRm15454ILfn89)Q0ktDoE5VWofpaYlE57)vrVvbUlf5ayIIy3MajLKERcCxkYbiN4LhcsjP3Qa3LICaSdj(triBv3R)jMWiqa)j0Jva1aQXOc7lU)jJfUKogpa)besi4sYceewoU0RAOiqqmBogCsjP3oKusMxCAMyLKDJ09qngvyFX9pzSWTvsTJnjJeaPzfP3oKIHaRWRKmGm1YdpwJmb21QKmV40mXkj7gP7HAmQW(I7FYyHBRKApSCCbKhcr6vnueiiMnhdoPK0BhsQxu(b8ynDOwLK5fNMjwjz3irhuJrf2xC)tglCBLu7kjdCn6r6TdjLK5fNMjwjzKOdQXOc7lU)jJfUTsQDSjzKainRiuJrf2xC)tglCBLu7HLJlG8qisVQHIabXS5yWjLKE7qsjzEXPzIvs2ns0b1aQXOc7lUNJlww0G0X4bh8hWHABqVDijtDoEoUyzrd)IIJvCAsc1yuH9f3ZXfllA0kP25KTQSkhO2PqGotPJE7qs9IYpGhRPd1MYOctpcWcfnKFJ09zzJkm9ialu0q(TKAtR6FI(Fv(14wLd4ufqNP05PiNkuJrf2xCphxSSOrRKAFnUv5aovb0zkD0RAOiqqmBogCsjP3oKuVO8d4XA6qOgJkSV4EoUyzrJwj1(X4bh8hWHABqVDinQW0JaSqrd53iDpuJrf2xCphxSSOrRKANt2QYQCGANcb6mLo6Tdj1lk)aESMouRm1547tPqWFakjJwzEkYqngvyFX9CCXYIgTsQDzIrP7PcGotPJEvdfbcIzZXGtkj92HK6fLFapwthQvM6C8x4q(lo4pGF746PiRv9pr)Vk)ACRYbCQcOZu68lkowXVrhuJrf2xCphxSSOrRKA)y8Gd(d4qTnO3Qa3LICaSdP0Q(NO)xLFnUv5aovb0zkDEkYqngvyFX9CCXYIgTsQDozRkRYbQDkeOZu6O3oKuVO8d4XA6qTDuM6C8YFHDkEaKx8c0rzQZXtrgQXOc7lUNJlww0OvsTFmEa(diKqWLKfiiSCCPx1qrGGy2Cm4KssVDiPKmAUhQXOc7lUNJlww0OvsTltmkDpva0zkD0RAOiqqmBogCsjP3oKuVO8d4XA6WSS0gdbwHxYcG6fLFOgJkSV4EoUyzrJwj1oNSvLv5a1ofc0zkDqnGAmQW(I75bPljBjSkh03j)lazQsjrVDiLIm154jVM4VDBiaK)aRWgcppgLoAUZSmzQZXl)f2P4bqEXl)IIJvCAu)t0)RYVg3QCaNQa6mLo)IIJvCTYuNJx(lStXdG8IxEkYAjJHVjfwGqcbxswGGWYX1pQW0JPQnLDSoa1Jv4NEN7T6M6FI(Fv(ljBjSkh03j)lazQsj57u7e2xTWe83rwgNmsqaIzZXGFlzQqngvyFX98OvsTZjBvzvoqTtHaDMsh92HK6fLFapwthQvM6C89Pui4paLKrRmpfzTPSJ1bOESc)07CVv3KPohFFkfc(dqjz0kZVO4yfpX0LLTJ1bOESc)07Cpf5uHAmQW(I75rRKA)qGCj1oNGERcCxkYbWefXUnbskj9wf4UuKdGDijtDoE9pXegbc4pHEScGeL4uV19uKZYWc38g(Werq8aXPjn3NLP(NO)xLFnUv5aovb0zkD(ffhR40qxwM6FI(Fv(JXdo4pGd12WVO4yfNg6O3oK4pfHSvDV(NycJab8NqpwHwzQZXZJFfb4SHeyQo4yl67)vPTJYuNJx(lStXdG8IxGoktDo((FvqngvyFX98OvsTVg3QCaNQa6mLo6vnueiiMnhdoPK0BhsQ)j6)v554ILfn8lkowXVLmllTXqGv454ILfn0MI6FI(Fv(lCi)fh8hWVDC9lkowXVLizzPv96XAQWRRXAtLkuJrf2xCppALu7hJhCWFahQTb92Huk7yDaQhRWp9o3B1n1)e9)Q8hJhCWFahQTHVtTtyF1ctWFhzz7yDaQhRWp9o3trovTPGfU5n8HjIG4bItZByturfiimrmXjZYusMxCAMyLKrdPKzzYuNJNh)kcWzdjWuDWXw0VO4yfNgSjQOceeMi2AYuZYowUuawuCSItd2evubccteBnzwwhLPohV8xyNIha5fVaDuM6C8uKZYKPohp51e)TBdbG8FHRNImuJrf2xCppALu7QDu6iSkhqRMociSCPOSkNE7qsM6C8HecqrY4(lhOgYJYIF98yu6UL8o1IfU5n8HjIG4bItZByturfiimrmXj1Q(NO)xLFnUv5aovb0zkD(ffhR43WMOIkqqyIywMm154djeGIKX9xoqnKhLf)65XO0DlzIOnf1)e9)Q8CCXYIg(ffhR40KgTXqGv454ILfnYYu)t0)RYFHd5V4G)a(TJRFrXXkonPrR61J1uHxxJ1Mkl7y5sbyrXXkonPjvOgJkSV4EE0kP2xkUKv5aA10rWLvD6TdjzQZXVuCjRYb0QPJGlR6((FvAhvy6rawOOH8BjHAmQW(I75rRKA)y8a8hqiHGljlqqy54sVQHIabXS5yWjLKE7qsjz0CpuJrf2xCppALu7ytYibqAwr6TdjLK5fNMjwjz3iLeQXOc7lUNhTsQDLKbKPwEqVDiPKmV40mXkj7gPKAhvy6rawOOHCsj1UJ1bOESc)07CVv3OlHSmLK5fNMjwjz3irN2rfMEeGfkAi)gj6GAmQW(I75rRKAxjzGRrpsVDiLwzQZXtEnXF72qai)x46Pid1yuH9f3ZJwj1Ey54cipeI0RAOiqqmBogCsjP3oKuVO8d4XA6qTkjZlontSsYUrIoTYuNJNh)kcWzdjWuDWXw03)RcQXOc7lUNhTsQDozRkRYbQDkeOZu6O3oKKPohVsYayHBEdppgLUB3NqIttlCuHPhbyHIgY1ktDoEE8RiaNnKat1bhBrF)VkTPO(NO)xLFnUv5aovb0zkD(ffhR43OtR6FI(Fv(JXdo4pGd12WVO4yf)gDzzQ)j6)v5xJBvoGtvaDMsNFrXXkon3Rv9pr)Vk)X4bh8hWHAB4xuCSIF7ETkj729zzQ)j6)v5xJBvoGtvaDMsNFrXXk(T71Q(NO)xL)y8Gd(d4qTn8lkowXP5ETkj7wIKLPKmV40mXkjJgsj1IfU5n8HjIG4bIttAOl1SmzQZXRKmaw4M3WZJrP7wYe0ESCPaSO4yfNM7cuJrf2xCppALu7YeJs3tfaDMsh9QgkceeZMJbNus6Tdj1lk)aESMouBkXqGv454ILfn0Q(NO)xLNJlww0WVO4yfNM7ZYu)t0)RYVg3QCaNQa6mLo)IIJv8Bj1Q(NO)xL)y8Gd(d4qTn8lkowXVLmlt9pr)Vk)ACRYbCQcOZu68lkowXP5ETQ)j6)v5pgp4G)aouBd)IIJv8B3Rvjz3Ollt9pr)Vk)ACRYbCQcOZu68lkowXVDVw1)e9)Q8hJhCWFahQTHFrXXkon3Rvjz3Upltjz3stwMm154LFDaY7R8uKtfQXOc7lUNhTsQ9WYXfqEiePx1qrGGy2Cm4KssVDiPEr5hWJ10HAvsMxCAMyLKDJeDqngvyFX98OvsTpRAkee)Uyf0BhskjZlontSsYUrkjuJrf2xCppALu7hIgwLd44sgRaOZu6O3Qa3LICqkj92HuAvVESMk8fQ2N43EwMm154jVM4VDBiaK)aRWgcpfzOgJkSV4EE0kP2LjgLUNka6mLo6vnueiiMnhdoPK0BhsQxu(b8ynDOw1)e9)Q8hJhCWFahQTHFrXXkon3RvjzKOtl5f1dYvDFsFy54cipeIAXc38g(Werq8G0KanjHAmQW(I75rRKAxMyu6EQaOZu6Ox1qrGGy2Cm4KssVDiPEr5hWJ10HAXc38g(Werq8aXPjn0PnfLK5fNMjwjz0qkzwg5f1dYvDFsFy54cipeIPc1aQXOc7lU)chYFXb)b8BhxsQHGamQW(cqy8G(AersQoGJh65XAQGus6TdP0gdbwHNJlww0aQXOc7lU)chYFXb)b8Bh3wj1UAiiaJkSVaegpOVgrKKQd44ILfnONhRPcsjP3oKIHaRWZXfllAa1yuH9f3FHd5V4G)a(TJBRKAFnUv5aovb0zkD0RAOiqqmBogCsjHAmQW(I7VWH8xCWFa)2XTvsTltmkDpva0zkD0RAOiqqmBogCsjP3oKuVO8d4XA6qTQ)j6)v5pgp4G)aouBd)IIJvCTQ)j6)v5xJBvoGtvaDMsNFrXXkUwzQZXFHd5V4G)a(TJl46YtrgQXOc7lU)chYFXb)b8Bh3wj1oNSvLv5a1ofc0zkD0BhsQxu(b8ynDOwzQZX3NsHG)ausgTY8uKHAmQW(I7VWH8xCWFa)2XTvsTFmEWb)bCO2g0BvG7sroiLKERcCxkYbWefXUnbskj92HKm154VWH8xCWFa)2XfCD5PiRvM6C884xraoBibMQdo2IEkYAtlhdG8xuCFy4s3DaOJSs7OctpcWcfnKtdDqngvyFX9x4q(lo4pGF742kP2pgp4G)aouBd6TdjzQZXFHd5V4G)a(TJl46YtrwRm1545XVIaC2qcmvhCSf9uK1YXai)ff3hgU0Dha6iRYYgvy6rawOOH8BKOtRm154VWH8xCWFa)2XfCD5xuCSIttsOgJkSV4(lCi)fh8hWVDCBLu7xs2syvoOVt(xaYuLscQXOc7lU)chYFXb)b8Bh3wj1oNSvLv5a1ofc0zkD0BhsQxu(b8ynDO2rfMEeGfkAi)gP71ktDo(lCi)fh8hWVDCbxxEkYqngvyFX9x4q(lo4pGF742kP2pgpa)besi4sYceewoU0RAOiqqmBogCsjP3oKusgPe0ktDo(lCi)fh8hWVDCbxx(ffhR40KizzkjJM7HAmQW(I7VWH8xCWFa)2XTvsTJnjJeaPzfP3oKusMxCAMyLKDJusOgJkSV4(lCi)fh8hWVDCBLu7kjditT8GE7qsjzEXPzIvs2nsPKS1rfMEeGfkAi)wYuHAmQW(I7VWH8xCWFa)2XTvsThwoUaYdHi9QgkceeZMJbNus6TdjLKrkbTYuNJ)chYFXb)b8BhxW1LFrXXkonjswwkPngcScVKfa1lk)zzQxu(b8ynDyQAvsMxCAMyLKDJeDqngvyFX9x4q(lo4pGF742kP25KTQSkhO2PqGotPJE7qsM6C8kjdGfU5n88yu6UDFcjonTWrfMEeGfkAihQXOc7lU)chYFXb)b8Bh3wj1UmXO09ubqNP0rVQHIabXS5yWjLKE7qs9IYpGhRPd1oQW0JaSqrd50q6ETkj7gP7ZYKPoh)foK)Id(d43oUGRlpfzOgJkSV4(lCi)fh8hWVDCBLu7kjdCn6rOgJkSV4(lCi)fh8hWVDCBLu7hIgwLd44sgRaOZu6O3Qa3LICqkPtyOcPFDccMiT0fUW5a]] )


end