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


    spec:RegisterPack( "Windwalker", 20220501, [[dSeBVcqiveEKkIytuP(ekPgLOKtjk1Quru9kPeZcLQBrLWUOQFPI0WOs6yIWYqjEMkQMgvICnrsTnrs6BQisJtKeohkjADQOW8ikUhOSpPuheLKQfkL0drjHjQIOGlksISrusk9ruskoPijQvIs5LQik0mvrj3ufrr7KO0pvrPyPQOu6POYufj(QkkvJLkrTxs9xGbJ0HvSyQ4XKmzP6YqBwL(SOA0OQttz1OKKxtunBqUnr2TKFRQHdQoUkkA5k9Cctx46Oy7IOVRcJxK68II1RIO08LI9JyDcDkAU(eOwwwCLfwCn1UMWZscxkv4AQqZfzGJAo4Js(KJAUAKqn3z3Q(Xajhxnh8jd0pDDkAoXZSkuZP5CymOivU0oAU(eOwwwCLfwCn1UMWZscxkv46jvZjGJkTSSKQSsnhV17yPD0CDuO0CNDR6hdKCCj0tMFjNW2jZjdHMGDcLfxzHfcBe2yf8ZMJIZGWMli0uoWroHYQ1eHGq)lHYQLzZqOwf4UmWdcf6ZnLNWMli0uoWroHYb3QYQCcLvStHe6jJMsoHc95MYtyZfekREVtOoVqCTC(Gqv8OsUGqJNqLMkdHYkozGqXkwdfEcBUGqz17Dc1kxOEjNjiuwTqOGxTZn8AoitecDkAUhow4QtrlBcDkAoSghiSRBvZnQW(sZDnra(li4rWbVfiiSCC1CQ1cCTrZP4nV0KMqDbHQ4ncTnmc9CnNkJccbXS5yi0YMqhAzzrNIMdRXbc76w1CQ1cCTrZfdewHxXBahMveESghiStOUjufV5LM0eQliufVrOTHrONR5gvyFP5W0Wria)Ss6ql756u0Cynoqyx3QMBuH9LMlSCCbWhijnNATaxB0CQxY5bIyn5iH6Mqv8MxAstOUGqv8gH2ggHYIMtLrbHGy2CmeAztOdTSUKofnhwJde21TQ5uRf4AJMtXBEPjnH6ccvXBekmcLfn3Oc7lnNI3ahtsuhAztTofn3Oc7lnhMgocb4NvsZH14aHDDR6qlBQQtrZH14aHDDRAUrf2xAUWYXfaFGK0CQ1cCTrZP4nV0KMqDbHQ4ncTnmcLfnNkJccbXS5yi0YMqh6qZDGd8VeG)c(TJRofTSj0PO5WACGWUUvnNATaxB0CNGqJbcRWlWfllY4XACGWUMteRPcTSj0CJkSV0CQbccmQW(cazIqZbzIauJeQ5uDGaV6qlll6u0Cynoqyx3QMtTwGRnAUyGWk8cCXYImESghiSR5eXAQqlBcn3Oc7lnNAGGaJkSVaqMi0CqMia1iHAovhiWfllYOdTSNRtrZH14aHDDRAo1AbU2O5u8MxAstOUGqv8gH2ggHYcH6MqXc38m(WKqq8aPjnH2MqpxZnQW(sZHfU52jRv5aeYsBRo0Y6s6u0Cynoqyx3QMBuH9LMBnHv5abtbKBk5AovgfecIzZXqOLnHo0YMADkAoSghiSRBvZPwlW1gn3OcljcWcLmuqOTHrOSqOUjuhM71FGd8VeG)c(TJl44WVO0yLGqLHqtO5gvyFP5UMieG)cUmBgDOLnv1PO5WACGWUUvnNATaxB0CJkSKialuYqbH2ggHYIMBuH9LM7G3wiRYb9DY)caNPu86ql7jvNIMdRXbc76w1CQ1cCTrZPEjNhiI1KJeQBcnlcDuHLebyHsgki02Wi0Zju3eQdZ96pWb(xcWFb)2XfCC4zGtOnneQdZ967tPqWFbkEJvzEg4eA2AUrf2xAobCRkRYbQDkei3uY1Hw2uHofnhwJde21TQ5uRf4AJMtXBekmc1vc1nH6WCV(dCG)La8xWVDCbhh(fLgReeQmeQlP5gvyFP5W0Wria)Ss6qllRuNIMdRXbc76w1CJkSV0CxteG)ccEeCWBbcclhxnNATaxB0CkEJqHrOUsOUjuhM71FGd8VeG)c(TJl44WVO0yLGqLHqDjnNkJccbXS5yi0YMqhAzt4Qofn3Oc7ln3bVTqwLd67K)faotP41Cynoqyx3Qo0YMiHofnhwJde21TQ5gvyFP5CGgL8NjaYnLCnNATaxB0CQxY5bIyn5iH6Mqv)d1)JYFnria)fCz2m(fLgReeQBcv9pu)pk)AcRYbcMci3uY9lknwjiu3eQdZ96pWb(xcWFb)2XfCC4zGR5uzuqiiMnhdHw2e6qlBcw0PO5WACGWUUvn3Oc7lnxy54cGpqsAo1AbU2O5u8gHcJqDLqDtOom3R)ah4Fja)f8BhxWXHFrPXkbHkdH6sAovgfecIzZXqOLnHo0YM4CDkAoSghiSRBvZPwlW1gnNdZ96pWb(xcWFb)2XfCC4zGtOUjuhM71lIFLa4SbpyQo4Al6zGR5SkWDzGhAUeAoRcCxg4bWKKWUnbQ5sO5gvyFP5UMieG)cUmBgDOLnHlPtrZH14aHDDRAo1AbU2O5CyUxVI3ayHBEgVigLCcTnHEUReQli0utONCcDuHLebyHsgk0CJkSV0Cc4wvwLdu7uiqUPKRdTSjsTofnhwJde21TQ5gvyFP5UMia)fe8i4G3ceewoUAo1AbU2O5u8gHkdHEUMtLrbHGy2CmeAztOdTSjsvDkAoSghiSRBvZPwlW1gnNI38stAc1feQI3i02Wi0eAUrf2xAomnCecWpRKo0YM4KQtrZH14aHDDRAo1AbU2O5u8MxAstOUGqv8gH2ggHMfHMGqBHqhvyjrawOKHccTnHMGqZwZnQW(sZP4nGdZkcDOLnrQqNIMdRXbc76w1CJkSV0CHLJla(ajP5uRf4AJMllc9eeAmqyfEElaQxY59ynoqyNqBAiu1l58arSMCKqZMqDtOkEZlnPjuxqOkEJqBdJqzrZPYOGqqmBogcTSj0Hw2eSsDkAoSghiSRBvZnQW(sZ5ank5ptaKBk5Ao1AbU2O5uVKZdeXAYrc1nHoQWsIaSqjdfeQmWi0Zju3eQI3i02Wi0Zj0Mgc1H5E9h4a)lb4VGF74coo8mW1CQmkieeZMJHqlBcDOLLfx1PO5gvyFP5u8g4ysIAoSghiSRBvhAzzjHofnNvbUld8qZLqZnQW(sZDHYyvoqGlCScGCtjxZH14aHDDR6qhAobUyzrgDkAztOtrZH14aHDDRAo1AbU2O5CyUxVaxSSiJFrPXkbHkdHMqZnQW(sZDnria)fCz2m6qlll6u0Cynoqyx3QMtTwGRnAo1l58arSMCKqDtOzrOJkSKialuYqbH2ggHEoH20qOJkSKialuYqbH2MqtqOUj0tqOQ)H6)r5xtyvoqWua5MsUNboHMTMBuH9LMta3QYQCGANcbYnLCDOL9CDkAoSghiSRBvZnQW(sZTMWQCGGPaYnLCnNATaxB0CQxY5bIyn5OMtLrbHGy2CmeAztOdTSUKofnhwJde21TQ5uRf4AJMBuHLebyHsgki02Wi0Z1CJkSV0CxtecWFbxMnJo0YMADkAoSghiSRBvZPwlW1gnN6LCEGiwtosOUjuhM713NsHG)cu8gRY8mW1CJkSV0Cc4wvwLdu7uiqUPKRdTSPQofnhwJde21TQ5gvyFP5CGgL8NjaYnLCnNATaxB0CQxY5bIyn5iH6MqDyUx)boW)sa(l43oUEg4eQBcv9pu)pk)AcRYbcMci3uY9lknwji02eklAovgfecIzZXqOLnHo0YEs1PO5SkWDzGha7Q5oH6FO(Fu(1ewLdemfqUPK7zGR5gvyFP5UMieG)cUmBgnhwJde21TQdTSPcDkAoSghiSRBvZPwlW1gnN6LCEGiwtosOUj0o6WCVENVWoJiaolEa6OdZ96zGR5gvyFP5eWTQSkhO2PqGCtjxhAzzL6u0Cynoqyx3QMBuH9LM7AIa8xqWJGdElqqy54Q5uRf4AJMtXBeQme65AovgfecIzZXqOLnHo0YMWvDkAoSghiSRBvZnQW(sZ5ank5ptaKBk5Ao1AbU2O5uVKZdeXAYrcTPHqpbHgdewHN3cG6LCEpwJde21CQmkieeZMJHqlBcDOLnrcDkAUrf2xAobCRkRYbQDkei3uY1Cynoqyx3Qo0HMt1bcCXYIm6u0YMqNIMdRXbc76w1CpCnNadn3Oc7lnxYzTXbc1CjhiguZP(hQ)hLxGlwwKXVO0yLGqLHqtqOnnekCm8PzWce8i4G3ceewoU(rfwsKqDtOQ)H6)r5f4ILfz8lknwji02e65UsOnneQZleeQBc9A58byrPXkbHkdHYIRAUKZcQrc1CcCXYImahMve6qlll6u0Cynoqyx3QMtTwGRnAUtqOjN1ghi0Z)qDqAgSi0Mgc15fcc1nHETC(aSO0yLGqLHqzj1AUrf2xAoRs(YrqAgS0Hw2Z1PO5WACGWUUvnNATaxB0CjN1ghi0lWfllYaCywrO5gvyFP5CG(VdUmBgDOL1L0PO5WACGWUUvnNATaxB0CjN1ghi0lWfllYaCywrO5gvyFP5CWvGRCRY1Hw2uRtrZnQW(sZbz58HaWQy65syfAoSghiSRBvhAztvDkAoSghiSRBvZPwlW1gnxYzTXbc9cCXYImahMveAUrf2xAURTOd0)DDOL9KQtrZH14aHDDRAo1AbU2O5soRnoqOxGlwwKb4WSIqZnQW(sZnLcfXoqa1abPdTSPcDkAoSghiSRBvZPwlW1gnxYzTXbc9cCXYImahMveAUrf2xAoNjh8xqSMsUqhAzzL6u0Cynoqyx3QMtTwGRnAURLZhGfLgReeABcnlcnrQWvc1fe6Yu493C0FNyGaXZO49ynoqyNqp5eAcwCLqZMqBAiu4y4tZGfi4rWbVfiiSCC9JkSKiH6MqZIqpbHQ(Kynv4luTp0VDcTPHqDyUxVZxyNreaNfp8mWj0Sj0Mgcnlcv9pu)pkVvjF5iindwGGhbh8wGGWYX1VO0yLGqBtOxlNpalknwji0Sju3eQdZ96D(c7mIa4S4HNboH20qOoVqqOUj0RLZhGfLgReeQmeAcx1CJkSV0CXZO4b)f0Xj41Hw2eUQtrZH14aHDDRAo1AbU2O5UwoFawuASsqOTjuwPReAtdHchdFAgSabpco4TabHLJRFuHLej0Mgc15fcc1nHETC(aSO0yLGqLHqt4QMBuH9LMlEgfp4Va5Zkn6qlBIe6u0Cynoqyx3QMtTwGRnAo1)q9)O8RjSkhiykGCtj3VO0yLGqLHqX0OIjqqysOMBuH9LM7ah4Fja)f8BhxDOLnbl6u0Cynoqyx3QMtTwGRnAUKZAJde6f4ILfzaomRii0Mgc15fcc1nHETC(aSO0yLGqLHqzXvn3Oc7lnNvc1YeJdecotMPcgjqhtAkuhAztCUofnhwJde21TQ5gvyFP5cEeCTveaHLBqAo1AbU2O5soRnoqOxGlwwKb4WSIGqBAiuNxiiu3e61Y5dWIsJvccvgcLfx1C1iHAUGhbxBfbqy5gKo0YMWL0PO5WACGWUUvnNATaxB0CjN1ghi0lWfllYaCywrO5gvyFP5o2j4fXxOo0YMi16u0Cynoqyx3QMtTwGRnAUKZAJde6f4ILfzaomRi0CJkSV0C5qt3M4xbWz65Oo0YMiv1PO5WACGWUUvn3Oc7lnNGF6)r(oc4G4dusZPwlW1gnhCm8PzWce8i4G3ceewoU(rfwsKqBAiuNxiiu3e61Y5dWIsJvccvgcLfxj0Mgc9ee6Yu493C0BvYxoUcqhHSC(WJ14aHDnxnsOMtWp9)iFhbCq8bkPdTSjoP6u0Cynoqyx3QMBuH9LMdNn4DwCKJRaysWhvO5uRf4AJM7eeAYzTXbc9PzWc8fGrGGyTsogeAtdHQ(hQ)hL3QKVCeKMblqWJGdElqqy546xuASsqOTjuwCLqBAi0KZAJde65FOoindwAUAKqnhoBW7S4ihxbWKGpQqhAztKk0PO5WACGWUUvnNATaxB0CNGqtoRnoqOpndwGVamceeRvYXGqBAiu1)q9)O8wL8LJG0mybcEeCWBbcclhx)IsJvccTnHYIReAtdHMCwBCGqp)d1bPzWsZnQW(sZXiqGfOKqhAztWk1PO5gvyFP5UdczfceXlbxZH14aHDDR6qlllUQtrZnQW(sZDhiiSa)2XvZH14aHDDR6qlllj0PO5WACGWUUvnNATaxB0CoVqqOUj0RLZhGfLgReeQmeAIutOnneAweQI3i02Wiuwiu3eAwe61Y5dWIsJvccTnHMQUsOUj0Si0Siu1)q9)O8cCXYIm(fLgReeABcnHReAtdH6WCVEbUyzrgpdCcTPHqv)d1)JYlWfllY4zGtOztOUj0Siu4y4tZGfi4rWbVfiiSCC9JkSKiH20qOQ)H6)r5Tk5lhbPzWce8i4G3ceewoU(fLgReeABcnHReAtdHMCwBCGqp)d1bPzWIqZMqZMqZMqBAi0Si0RLZhGfLgReeQmWi0u1vc1nHMfHchdFAgSabpco78wGGWYX1pQWsIeAtdHQ(hQ)hL3QKVCeKMblqWJGdElqqy546xuASsqOTj0RLZhGfLgReeA2eA2eA2AUrf2xAoNVWoJiaolEOdTSSWIofnhwJde21TQ5uRf4AJMt9pu)pk)AcRYbcMci3uY9lknwjiuziuwi0Mgc15fcc1nHETC(aSO0yLGqLHqtKAn3Oc7lnNaxSSiJo0YYY56u0CJkSV0Coto4VGynLCHMdRXbc76w1HwwwCjDkAoSghiSRBvZPwlW1gnNdZ96f4ILfz89)Oiu3eQdZ96D(c7mIa4S4bOJom3RV)hfH6MqDyUxVZxyNreaNfp89)Oiu3eAweQ4zGCSQ7HZicgieGld8W(YJ14aHDcTPHqfpdKJvDFYhAcdcbIhkjwHhRXbc7eA2AoRcCxg4bWUAoXZa5yv3N8HMWGqG4HsIvO5SkWDzGhatsc72eOMlHMBuH9LM7cHcE1o3qZzvG7Yapa5qVZaP5sOdDO5eHofTSj0PO5WACGWUUvnNATaxB0CzrOom3Rh(As)2Tbca)dScBG8IyuYjuziuwjH20qOom3R35lSZicGZIh(fLgReeQmeQ6FO(Fu(1ewLdemfqUPK7xuASsqOUjuhM7178f2zebWzXdpdCc1nHchdFAgSabpco4TabHLJRFuHLej0Sju3eAwe6owhGjXk8tVl8wrOTju1)q9)O8h82czvoOVt(xa4mLI33z2jSVi0toH6QpvqOnneQaocbbIzZXqqOTj0eeA2AUrf2xAUdEBHSkh03j)laCMsXRdTSSOtrZH14aHDDRAo1AbU2O5u8MxAstOUGqv8gH2ggHYcH6MqXc38m(WKqq8aPjnH2MqpNqBAiufV5LM0eQliufVrOTHrOUeH6MqZIqXc38m(WKqq8aPjnH2MqzHqBAi0tqOWxmjix19j8HLJla(ajrOzR5gvyFP5Wc3C7K1QCaczPTvhAzpxNIMdRXbc76w1CQ1cCTrZPEjNhiI1KJeQBc1H5E99Pui4VafVXQmpdCc1nHMfHUJ1bysSc)07cVveABc1H5E99Pui4VafVXQm)IsJvcc1fekleAtdHUJ1bysSc)07cpdCcnBn3Oc7lnNaUvLv5a1ofcKBk56qlRlPtrZH14aHDDRAo1AbU2O5epdKJvDFYhAcdcbIhkjwHhRXbc7eQBc1H5E9I4xjaoBWdMQdU2I((FueQBcTJom3R35lSZicGZIhGo6WCV((FuAoRcCxg4bWUAohM71N8HMWGqG4HsIva4zKM6TUNbEtdw4MNXhMecIhinPL58Mg1)q9)O8RjSkhiykGCtj3VO0yLqgwAAu)d1)JYFnria)fCz2m(fLgReYWIMZQa3LbEamjjSBtGAUeAUrf2xAUlek4v7CdDOLn16u0Cynoqyx3QMBuH9LMBnHv5abtbKBk5Ao1AbU2O5u)d1)JYlWfllY4xuASsqOTj0eeAtdHEccngiScVaxSSiJhRXbc7eQBcnlcv9pu)pk)boW)sa(l43oU(fLgReeABc1Li0Mgc9eeQ6tI1uHxEM1MIqZwZPYOGqqmBogcTSj0Hw2uvNIMdRXbc76w1CQ1cCTrZLfHUJ1bysSc)07cVveABcv9pu)pk)1eHa8xWLzZ47m7e2xe6jNqD1Nki0MgcDhRdWKyf(P3fEg4eA2eQBcnlcflCZZ4dtcbXdKM0eABcftJkMabHjHeQli0eeAtdHQ4nV0KMqDbHQ4ncvgyeAccTPHqDyUxVi(vcGZg8GP6GRTOFrPXkbHkdHIPrftGGWKqcTfcnbHMnH20qOxlNpalknwjiuziumnQyceeMesOTqOji0MgcTJom3R35lSZicGZIhGo6WCVEg4eAtdH6WCVE4Rj9B3gia8)axpdCn3Oc7ln31eHa8xWLzZOdTSNuDkAoSghiSRBvZPwlW1gnNdZ96dEeGsWX9xbqnWhLf)6fXOKtOTj0eSsc1nHIfU5z8HjHG4bstAcTnHIPrftGGWKqc1feAcc1nHQ(hQ)hLFnHv5abtbKBk5(fLgReeABcftJkMabHjHeAtdH6WCV(GhbOeCC)vaud8rzXVErmk5eABcnHlrOUj0Siu1)q9)O8cCXYIm(fLgReeQmeAQju3eAmqyfEbUyzrgpwJde2j0Mgcv9pu)pk)boW)sa(l43oU(fLgReeQmeAQju3eQ6tI1uHxEM1MIqBAi0RLZhGfLgReeQmeAQj0S1CJkSV0CQDuYHSkhWQMocGSC(OSkxhAztf6u0Cynoqyx3QMtTwGRnAohM71VmcERYbSQPJGdR6((FueQBcDuHLebyHsgki02eAcn3Oc7ln3Yi4TkhWQMocoSQRdTSSsDkAoSghiSRBvZnQW(sZDnra(li4rWbVfiiSCC1CQ1cCTrZP4ncvgc9CnNkJccbXS5yi0YMqhAzt4QofnhwJde21TQ5uRf4AJMtXBEPjnH6ccvXBeAByeAcn3Oc7lnhMgocb4NvshAztKqNIMdRXbc76w1CQ1cCTrZP4nV0KMqDbHQ4ncTnmcnbH6MqhvyjrawOKHccfgHMGqDtO7yDaMeRWp9UWBfH2MqzXvcTPHqv8MxAstOUGqv8gH2ggHYcH6MqhvyjrawOKHccTnmcLfn3Oc7lnNI3aomRi0Hw2eSOtrZH14aHDDRAo1AbU2O5obH6WCVE4Rj9B3gia8)axpdCn3Oc7lnNI3ahtsuhAztCUofnhwJde21TQ5gvyFP5clhxa8bssZPwlW1gnN6LCEGiwtosOUjufV5LM0eQliufVrOTHrOSqOUjuhM71lIFLa4SbpyQo4Al67)rP5uzuqiiMnhdHw2e6qlBcxsNIMdRXbc76w1CQ1cCTrZ5WCVEfVbWc38mErmk5eABc9CxjuxqOPMqp5e6OcljcWcLmuqOUjuhM71lIFLa4SbpyQo4Al67)rrOUj0Siu1)q9)O8RjSkhiykGCtj3VO0yLGqBtOSqOUju1)q9)O8xtecWFbxMnJFrPXkbH2MqzHqBAiu1)q9)O8RjSkhiykGCtj3VO0yLGqLHqpNqDtOQ)H6)r5VMieG)cUmBg)IsJvccTnHEoH6Mqv8gH2MqpNqBAiu1)q9)O8RjSkhiykGCtj3VO0yLGqBtONtOUju1)q9)O8xtecWFbxMnJFrPXkbHkdHEoH6Mqv8gH2MqDjcTPHqv8MxAstOUGqv8gHkdmcnbH6MqXc38m(WKqq8aPjnHkdHYcHMnH20qOom3RxXBaSWnpJxeJsoH2Mqt4kH6MqVwoFawuASsqOYqONun3Oc7lnNaUvLv5a1ofcKBk56qlBIuRtrZH14aHDDRAUrf2xAohOrj)zcGCtjxZPwlW1gnN6LCEGiwtosOUj0Si0yGWk8cCXYImESghiStOUju1)q9)O8cCXYIm(fLgReeQme65eAtdHQ(hQ)hLFnHv5abtbKBk5(fLgReeABcnbH6Mqv)d1)JYFnria)fCz2m(fLgReeABcnbH20qOQ)H6)r5xtyvoqWua5MsUFrPXkbHkdHEoH6Mqv)d1)JYFnria)fCz2m(fLgReeABc9Cc1nHQ4ncTnHYcH20qOQ)H6)r5xtyvoqWua5MsUFrPXkbH2MqpNqDtOQ)H6)r5VMieG)cUmBg)IsJvccvgc9Cc1nHQ4ncTnHEoH20qOkEJqBtOPMqBAiuhM7178YbW3x5zGtOzR5uzuqiiMnhdHw2e6qlBIuvNIMdRXbc76w1CJkSV0CHLJla(ajP5uRf4AJMt9sopqeRjhju3eQI38stAc1feQI3i02Wiuw0CQmkieeZMJHqlBcDOLnXjvNIMdRXbc76w1CQ1cCTrZP4nV0KMqDbHQ4ncTnmcnHMBuH9LMBw1uii(DXk0Hw2ePcDkAoSghiSRBvZPwlW1gn3jiu1NeRPcFHQ9H(TtOnneQdZ96HVM0VDBGaW)aRWgipdCn3Oc7ln3fkJv5abUWXkaYnLCnNvbUld8qZLqhAztWk1PO5WACGWUUvn3Oc7lnNd0OK)mbqUPKR5uRf4AJMt9sopqeRjhju3eQ6FO(Fu(Rjcb4VGlZMXVO0yLGqLHqpNqDtOkEJqHrOSqOUju4lMeKR6(e(WYXfaFGKiu3ekw4MNXhMecIhKAxjuzi0eAovgfecIzZXqOLnHo0YYIR6u0Cynoqyx3QMBuH9LMZbAuYFMai3uY1CQ1cCTrZPEjNhiI1KJeQBcflCZZ4dtcbXdKM0eQmekleQBcnlcvXBEPjnH6ccvXBeQmWi0eeAtdHcFXKGCv3NWhwoUa4dKeHMTMtLrbHGy2CmeAztOdDO5uDGaV6u0YMqNIMdRXbc76w1CQ1cCTrZDccn5S24aHE(hQdsZGfH6MqZIqv)d1)JYVMWQCGGPaYnLC)IsJvccvgcLfcTPHqpbHQ(Kynv4LNzTPi0Sju3eAwe6jiu1NeRPcFHQ9H(TtOnneQ6FO(FuENVWoJiaolE4xuASsqOYqOSqOztOnne61Y5dWIsJvccvgcLLuR5gvyFP5Sk5lhbPzWshAzzrNIMdRXbc76w1CQ1cCTrZDTC(aSO0yLGqBtOzrOjsfUsOUGqxMcV)MJ(7edeiEgfVhRXbc7e6jNqtWIReA2eAtdH6WCVEr8ReaNn4bt1bxBrF)pkc1nHchdFAgSabpco4TabHLJRFuHLeju3eAwe6jiu1NeRPcFHQ9H(TtOnneQdZ96D(c7mIa4S4HNboHMnH20qOzrOQ)H6)r5Tk5lhbPzWce8i4G3ceewoU(fLgReeABc9A58byrPXkbHMnH6MqDyUxVZxyNreaNfp8mWj0Mgc15fcc1nHETC(aSO0yLGqLHqt4QMBuH9LMlEgfp4VGoobVo0YEUofnhwJde21TQ5uRf4AJMllcDhRdWKyf(P3fERi02eQlLAcTPHq3X6amjwHF6DHNboHMnH6Mqv)d1)JYVMWQCGGPaYnLC)IsJvccvgcftJkMabHjHeQBcv9pu)pkVvjF5iindwGGhbh8wGGWYX1VO0yLGqBtOzrOS4kH2cHYIRe6jNqxMcV)MJERs(YXva6iKLZhESghiStOztOnneQZleeQBc9A58byrPXkbHkdHEEQ1CJkSV0Ch4a)lb4VGF74QdTSUKofnhwJde21TQ5uRf4AJMt9sopqeRjhju3eAwe6owhGjXk8tVl8wrOTj0eUsOnne6owhGjXk8tVl8mWj0S1CJkSV0C3bHScbI4LGRdTSPwNIMdRXbc76w1CQ1cCTrZTJ1bysSc)07cVveABc9Cxj0MgcDhRdWKyf(P3fEg4AUrf2xAU7abHf43oU6qlBQQtrZH14aHDDRAo1AbU2O5obH6WCVENVWoJiaolE4zGtOUj0SiufVrOTHrOSqOUj0RLZhGfLgReeABcnvDLqDtOzrOQ)H6)r5fXVsaC2GhmvhCTf9k(zZrbH2MqDLqBAiu1)q9)O8I4xjaoBWdMQdU2I(fLgReeABcnHReA2eQBcnlcfog(0mybcEeCWBbcclhx)OcljsOnneQ6FO(FuERs(YrqAgSabpco4TabHLJRFrPXkbH2Mqt4kH20qOjN1ghi0Z)qDqAgSi0Sj0MgcnlcvXBeAByekleQBc9A58byrPXkbHkdmcnvDLqDtOzrOWXWNMblqWJGZoVfiiSCC9JkSKiH20qOQ)H6)r5Tk5lhbPzWce8i4G3ceewoU(fLgReeABc9A58byrPXkbHMnH6MqZIqv)d1)JYlIFLa4SbpyQo4Al6v8ZMJccTnH6kH20qOQ)H6)r5fXVsaC2GhmvhCTf9lknwji02e61Y5dWIsJvccTPHqDyUxVi(vcGZg8GP6GRTONboHMnHMnH20qOoVqqOUj0RLZhGfLgReeQmeAIutOztOnneQZleeQBc9A58byrPXkbHkdHMWvc1nHkEgihR6EiC6aNmam9ibhc9ynoqyxZnQW(sZ58f2zebWzXdDOL9KQtrZH14aHDDRAo1AbU2O5uF1zSWR(F7wnb2b)9ILWsIESghiSR5gvyFP5eXVsaC2GhmvhCTfbxl9eOo0YMk0PO5WACGWUUvnNATaxB0CQ)H6)r5fXVsaC2GhmvhCTf9k(zZrbHcJqzHqBAi0RLZhGfLgReeQmeklUsOnneAwe6owhGjXk8tVl8lknwji02eAIutOnneAwe6jiu1NeRPcV8mRnfH6MqpbHQ(Kynv4luTp0VDcnBc1nHMfHMfHUJ1bysSc)07cVveABcv9pu)pkVi(vcGZg8GP6GRTO)YabbwuXpBocctcj0Mgc9ee6owhGjXk8tVl8yAteccnBc1nHMfHQ(hQ)hL3QKVCeKMblqWJGdElqqy546xuASsqOTju1)q9)O8I4xjaoBWdMQdU2I(ldeeyrf)S5iimjKqBAi0KZAJde65FOoindweA2eA2eQBcv9pu)pk)1eHa8xWLzZ4xuASsqOYaJqzLeQBcvXBeAByekleQBcv9pu)pk)bVTqwLd67K)faotP49lknwjiuzGrOjyHqZwZnQW(sZjIFLa4SbpyQo4AlQdTSSsDkAoSghiSRBvZPwlW1gnN6tI1uHxEM1MIqDtOzrOom3R)ah4Fja)f8BhxpdCcTPHqZIqVwoFawuASsqOYqOQ)H6)r5pWb(xcWFb)2X1VO0yLGqBAiu1)q9)O8h4a)lb4VGF746xuASsqOTju1)q9)O8I4xjaoBWdMQdU2I(ldeeyrf)S5iimjKqZMqDtOQ)H6)r5VMieG)cUmBg)IsJvccvgyekRKqDtOkEJqBdJqzHqDtOQ)H6)r5p4TfYQCqFN8VaWzkfVFrPXkbHkdmcnbleA2AUrf2xAor8ReaNn4bt1bxBrDOLnHR6u0Cynoqyx3QMtTwGRnAo1NeRPcFHQ9H(TtOUj0o6WCVENVWoJiaolEa6OdZ96zGtOUj0Siu4y4tZGfi4rWbVfiiSCC9JkSKiH20qOjN1ghi0Z)qDqAgSi0Mgcv9pu)pkVvjF5iindwGGhbh8wGGWYX1VO0yLGqBtOQ)H6)r5fXVsaC2GhmvhCTf9xgiiWIk(zZrqysiH20qOQ)H6)r5Tk5lhbPzWce8i4G3ceewoU(fLgReeABc9Cxj0S1CJkSV0CI4xjaoBWdMQdU2I6qlBIe6u0Cynoqyx3QMBuH9LMZkHAzIXbcbNjZubJeOJjnfQ5uRf4AJMdog(0mybcEeCWBbcclhx)OcljsOnneQZleeQBc9A58byrPXkbHkdHYIRAUAKqnNvc1YeJdecotMPcgjqhtAkuhAztWIofnhwJde21TQ5gvyFP5cEeCTveaHLBqAo1AbU2O5GJHpndwGGhbh8wGGWYX1pQWsIeAtdHQ(hQ)hL3QKVCeKMblqWJGdElqqy546xuASsqOTj0u1vc1nHETC(aSO0yLGqBtON7QReAtdH68cbH6MqVwoFawuASsqOYqOS4QMRgjuZf8i4ARiacl3G0Hw2eNRtrZH14aHDDRAo1AbU2O5GJHpndwGGhbh8wGGWYX1pQWsIeAtdH68cbH6MqVwoFawuASsqOYqOS4QMBuH9LM7yNGxeFH6qlBcxsNIMdRXbc76w1CQ1cCTrZbhdFAgSabpco4TabHLJRFuHLej0Mgc15fcc1nHETC(aSO0yLGqLHqzXvn3Oc7lnxo00Tj(vaCMEoQdTSjsTofnhwJde21TQ5gvyFP56lo9RTiijkeiKMtTwGRnAUtqOjN1ghi0NMblWxagbcI1k5yqOnneQ6FO(FuERs(YrqAgSabpco4TabHLJRFrPXkbH2MqzXvc1nHchdFAgSabpco4TabHLJRFrPXkbHkdHYIReAtdHMCwBCGqp)d1bPzWsZvJeQ56lo9RTiijkeiKo0YMiv1PO5WACGWUUvn3Oc7lnNGF6)r(oc4G4dusZPwlW1gnhCm8PzWce8i4G3ceewoU(rfwsKqBAiuNxiiu3e61Y5dWIsJvccvgcLfxj0Mgc9ee6Yu493C0BvYxoUcqhHSC(WJ14aHDnxnsOMtWp9)iFhbCq8bkPdTSjoP6u0Cynoqyx3QMBuH9LMl4rW1wraewUbP5uRf4AJMdog(0mybcEeCWBbcclhx)IsJvccTnHMi1eAtdHQ(hQ)hL3QKVCeKMblqWJGdElqqy546xuASsqOTj0u1vc1nHETC(aSO0yLGqBtON7QReAtdH68cbH6MqVwoFawuASsqOYqOS4QMRgjuZf8i4ARiacl3G0Hw2ePcDkAoSghiSRBvZnQW(sZHZg8oloYXvamj4Jk0CQ1cCTrZDccn5S24aH(0myb(cWiqqSwjhdcTPHqv)d1)JYBvYxocsZGfi4rWbVfiiSCC9lknwji02eklUsOUju4y4tZGfi4rWbVfiiSCC9lknwjiuziuwCLqBAi0KZAJde65FOoindwAUAKqnhoBW7S4ihxbWKGpQqhAztWk1PO5WACGWUUvnNATaxB0CNGqtoRnoqOpndwGVamceeRvYXGqBAiu1)q9)O8wL8LJG0mybcEeCWBbcclhx)IsJvccTnHYIReAtdHMCwBCGqp)d1bPzWsZnQW(sZXiqGfOKqhAzzXvDkAoSghiSRBvZPwlW1gn31Y5dWIsJvccTnHYkDLqBAiu4y4tZGfi4rWbVfiiSCC9JkSKiH20qOjN1ghi0Z)qDqAgSi0Mgc15fcc1nHETC(aSO0yLGqLHqtKQAUrf2xAU4zu8G)cKpR0OdTSSKqNIMdRXbc76w1CQ1cCTrZP(hQ)hL3QKVCeKMblqWJGdElqqy546xuASsqOTj0ZDLqBAi0KZAJde65FOoindweAtdH68cbH6MqVwoFawuASsqOYqOS4QMBuH9LMZb6)o4YSz0HwwwyrNIMdRXbc76w1CQ1cCTrZP(hQ)hL3QKVCeKMblqWJGdElqqy546xuASsqOTj0ZDLqBAi0KZAJde65FOoindweAtdH68cbH6MqVwoFawuASsqOYqOjsTMBuH9LMZbxbUYTkxhAzz5CDkAUrf2xAoilNpeawftpxcRqZH14aHDDR6qlllUKofnhwJde21TQ5uRf4AJMt9pu)pkVvjF5iindwGGhbh8wGGWYX1VO0yLGqBtON7kH20qOjN1ghi0Z)qDqAgSi0Mgc15fcc1nHETC(aSO0yLGqLHqt4QMBuH9LM7Al6a9FxhAzzj16u0Cynoqyx3QMtTwGRnAo1)q9)O8wL8LJG0mybcEeCWBbcclhx)IsJvccTnHEUReAtdHMCwBCGqp)d1bPzWIqBAiuNxiiu3e61Y5dWIsJvccvgcLfx1CJkSV0CtPqrSdeqnqq6qlllPQofnhwJde21TQ5uRf4AJMZH5E9I4xjaoBWdMQdU2I((FuAUrf2xAoNjh8xqSMsUqhAzz5KQtrZH14aHDDRAo1AbU2O5CyUxVaxSSiJV)hfH6MqDyUxVZxyNreaNfpaD0H5E99)Oiu3eQdZ96D(c7mIa4S4HV)hfH6MqZIqfpdKJvDpCgrWaHaCzGh2xESghiStOnneQ4zGCSQ7t(qtyqiq8qjXk8ynoqyNqZwZzvG7Yapa2vZjEgihR6(Kp0egecepusScnNvbUld8ayssy3Ma1Cj0CJkSV0CxiuWR25gAoRcCxg4bih6DginxcDOdnxhVdduOtrlBcDkAUrf2xAobCCwa)uDGiwtoQ5WACGWUUvDOLLfDkAoSghiSRBvZ9W1Ccm0CJkSV0CjN1ghiuZLCGyqnN6FO(FuERs(YrqAgSabpco4TabHLJRFrPXkbH2MqVwoFawuASsqOnne61Y5dWIsJvcc1feQ6FO(FuERs(YrqAgSabpco4TabHLJRFrPXkbHkdHMGfxju3eAweAweAmqyfEbUyzrgpwJde2ju3e61Y5dWIsJvccTnHQ(hQ)hLxGlwwKXVO0yLGqDtOQ)H6)r5f4ILfz8lknwji02eAcxj0Sj0Mgcnlcv9pu)pkVi(vcGZg8GP6GRTO)YabbwuXpBocctcjuzi0RLZhGfLgReeQBcv9pu)pkVi(vcGZg8GP6GRTO)YabbwuXpBocctcj02eAIutOztOnneAweQ6FO(FuEr8ReaNn4bt1bxBrVIF2CuqOWiuxju3eQ6FO(FuEr8ReaNn4bt1bxBr)IsJvccvgc9A58byrPXkbHMnHMTMl5SGAKqnh)d1bPzWshAzpxNIMdRXbc76w1CQ1cCTrZLfH6WCVEbUyzrgpdCcTPHqDyUxVi(vcGZg8GP6GRTONboHMnH6MqHJHpndwGGhbh8wGGWYX1pQWsIeAtdH68cbH6MqVwoFawuASsqOYaJqtvx1CJkSV0CW)W(shAzDjDkAoSghiSRBvZPwlW1gnNdZ96f4ILfz8mW1CIynvOLnHMBuH9LMtnqqGrf2xaiteAoiteGAKqnNaxSSiJo0YMADkAoSghiSRBvZPwlW1gnNdZ96pWb(xcWFb)2X1ZaxZjI1uHw2eAUrf2xAo1abbgvyFbGmrO5GmraQrc1Ch4a)lb4VGF74QdTSPQofnhwJde21TQ5uRf4AJMlmjKqLHqDjc1nHQ4ncvgcn1eQBc9eekCm8PzWce8i4G3ceewoU(rfwsuZjI1uHw2eAUrf2xAo1abbgvyFbGmrO5GmraQrc1CpCSWvhAzpP6u0Cynoqyx3QMBuH9LM7AIa8xqWJGdElqqy54Q5uRf4AJMtXBEPjnH6ccvXBeABye65eQBcnlcflCZZ4dtcbXdKM0eQmeAccTPHqXc38m(WKqq8aPjnHkdH6seQBcv9pu)pk)1eHa8xWLzZ4xuASsqOYqOj8PMqBAiu1)q9)O8h4a)lb4VGF746xuASsqOYqOSqOztOUj0tqOD0H5E9oFHDgraCw8a0rhM71ZaxZPYOGqqmBogcTSj0Hw2uHofnhwJde21TQ5uRf4AJMtXBEPjnH6ccvXBeAByeAcc1nHMfHIfU5z8HjHG4bstAcvgcnbH20qOQ)H6)r5f4ILfz8lknwjiuziuwi0MgcflCZZ4dtcbXdKM0eQmeQlrOUju1)q9)O8xtecWFbxMnJFrPXkbHkdHMWNAcTPHqv)d1)JYFGd8VeG)c(TJRFrPXkbHkdHYcHMnH6MqpbH6WCVENVWoJiaolE4zGR5gvyFP5W0Wria)Ss6qllRuNIMdRXbc76w1CJkSV0CHLJla(ajP5uRf4AJMt9sopqeRjhju3eQI38stAc1feQI3i02Wiuwiu3eAwekw4MNXhMecIhinPjuzi0eeAtdHQ(hQ)hLxGlwwKXVO0yLGqLHqzHqBAiuSWnpJpmjeepqAstOYqOUeH6Mqv)d1)JYFnria)fCz2m(fLgReeQmeAcFQj0Mgcv9pu)pk)boW)sa(l43oU(fLgReeQmekleA2eQBc9eeAhDyUxVZxyNreaNfpaD0H5E9mW1CQmkieeZMJHqlBcDOLnHR6u0Cynoqyx3QMtTwGRnAo1NeRPcFz58b4oiH6Mqv)d1)JYFheYkeiIxcUFrPXkbH2Mqzj1eQBcnlcvXBEPjnH6ccvXBeAByeAcc1nHoQWsIaSqjdfekmcnbH6Mq3X6amjwHF6DH3kcTnHYIReAtdHQ4nV0KMqDbHQ4ncTnmcLfc1nHoQWsIaSqjdfeAByekleA2AUrf2xAofVbCywrOdTSjsOtrZH14aHDDRAo1AbU2O5obHgdewHxGlwwKXJ14aHDnNiwtfAztO5gvyFP5udeeyuH9faYeHMdYebOgjuZP6abE1Hw2eSOtrZH14aHDDRAo1AbU2O5IbcRWlWfllY4XACGWUMteRPcTSj0CJkSV0CQbccmQW(cazIqZbzIauJeQ5uDGaxSSiJo0YM4CDkAoSghiSRBvZPwlW1gn3OcljcWcLmuqOYqONR5eXAQqlBcn3Oc7lnNAGGaJkSVaqMi0CqMia1iHAorOdTSjCjDkAoSghiSRBvZPwlW1gn3OcljcWcLmuqOTHrONR5eXAQqlBcn3Oc7lnNAGGaJkSVaqMi0CqMia1iHAU5rDOdnh8fvVKZe6u0YMqNIMBuH9LMZ5Jac7Gl0Kb7hwLdIpTvAoSghiSRBvhAzzrNIMdRXbc76w1CpCnNadn3Oc7lnxYzTXbc1CjhiguZHNjJbho29wjultmoqi4mzMkyKaDmPPqcTPHqXZKXGdh7(COPBt8Ra4m9CKqBAiu8mzm4WXU)yNGxeFHeAtdHINjJbho29FsCv8ZMJDWuM0aCMiWndH20qO4zYyWHJDVGF6)r(oc4G4duIqBAiu8mzm4WXUp4rW1wraewUbrOnnekEMmgC4y3Rgfpc(lyuNjJTyhelocMffAUKZcQrc1CPzWc8fGrGGyTsog6ql756u0CJkSV0CxiuWR25gAoSghiSRBvhAzDjDkAoSghiSRBvZPwlW1gn3jiu1NeRPcFz58b4oOMBuH9LMtXBahMve6qlBQ1PO5WACGWUUvnNATaxB0CNGqJbcRWJfU52jRv5aeYsJRhRXbc7AUrf2xAofVboMKOo0HMBEuNIw2e6u0CJkSV0Ch82czvoOVt(xa4mLIxZH14aHDDR6qlll6u0Cynoqyx3QMtTwGRnAofV5LM0eQliufVrOTHrOSqOUjuSWnpJpmjeepqAstOTjuwi0MgcvXBEPjnH6ccvXBeAByeQlP5gvyFP5Wc3C7K1QCaczPTvhAzpxNIMdRXbc76w1CQ1cCTrZPEjNhiI1KJeQBcnlc1H5E99Pui4VafVXQmpdCcTPHq7OdZ96D(c7mIa4S4bOJom3RNboHMTMBuH9LMta3QYQCGANcbYnLCDOL1L0PO5WACGWUUvnNATaxB0CyHBEgFysiiEG0KMqBtOyAuXeiimjKqBAiufV5LM0eQliufVrOYaJqtO5gvyFP5UMieG)cUmBgDOLn16u0Cynoqyx3QMBuH9LMBnHv5abtbKBk5Ao1AbU2O5YIqJbcRWFWBlKv5G(o5FbGZukEpwJde2ju3eQ6FO(Fu(1ewLdemfqUPK77m7e2xeABcv9pu)pk)bVTqwLd67K)faotP49lknwji0wiuxIqZMqDtOzrOQ)H6)r5VMieG)cUmBg)IsJvccTnHEoH20qOkEJqBdJqtnHMTMtLrbHGy2CmeAztOdTSPQofnhwJde21TQ5uRf4AJMZH5E9lJG3QCaRA6i4WQUV)hLMBuH9LMBze8wLdyvthbhw11Hw2tQofnhwJde21TQ5uRf4AJMtXBEPjnH6ccvXBeAByeAcn3Oc7lnhMgocb4NvshAztf6u0Cynoqyx3QMBuH9LM7AIa8xqWJGdElqqy54Q5uRf4AJMtXBEPjnH6ccvXBeABye65AovgfecIzZXqOLnHo0YYk1PO5WACGWUUvnNATaxB0CkEZlnPjuxqOkEJqBdJqzrZnQW(sZP4nGdZkcDOLnHR6u0Cynoqyx3QMtTwGRnAohM71h8iaLGJ7VcGAGpkl(1lIrjNqBtOjyLeQBcflCZZ4dtcbXdKM0eABcftJkMabHjHeQli0eeQBcv9pu)pk)1eHa8xWLzZ4xuASsqOTjumnQyceeMeQ5gvyFP5u7OKdzvoGvnDeaz58rzvUo0YMiHofnhwJde21TQ5gvyFP5clhxa8bssZPwlW1gnNI38stAc1feQI3i02Wiuwiu3eAwe6ji0yGWk88wauVKZ7XACGWoH20qOQxY5bIyn5iHMTMtLrbHGy2CmeAztOdTSjyrNIMdRXbc76w1CQ1cCTrZP4nV0KMqDbHQ4ncTnmcnHMBuH9LMBw1uii(DXk0Hw2eNRtrZH14aHDDRAo1AbU2O5uVKZdeXAYrc1nHMfHQ(hQ)hL35lSZicGZIh(fLgReeABcLfcTPHqpbHQ(Kynv4luTp0VDcnBc1nHMfHQ4ncTnmcn1eAtdHQ(hQ)hL)AIqa(l4YSz8lknwji02eAQsOnneQ6FO(Fu(Rjcb4VGlZMXVO0yLGqBtONtOUjufVrOTHrONtOUjuSWnpJpmjeepi1UsOYqOji0MgcflCZZ4dtcbXdKM0eQmWi0Si0Zj0wi0Zj0toHQ(hQ)hL)AIqa(l4YSz8lknwjiuzi0utOztOnneQdZ96fXVsaC2GhmvhCTf9mWj0S1CJkSV0Cc4wvwLdu7uiqUPKRdTSjCjDkAoSghiSRBvZPwlW1gnN6LCEGiwtoQ5gvyFP5u8g4ysI6qlBIuRtrZH14aHDDRAUrf2xAUlugRYbcCHJvaKBk5Ao1AbU2O5CyUxVZlhaFFLV)hLMZQa3LbEO5sOdTSjsvDkAoSghiSRBvZnQW(sZ5ank5ptaKBk5Ao1AbU2O5uVKZdeXAYrc1nHMfH6WCVENxoa((kpdCcTPHqJbcRWZBbq9soVhRXbc7eQBcf(Ijb5QUpHpSCCbWhijc1nHQ4ncfgHYcH6Mqv)d1)JYFnria)fCz2m(fLgReeQme65eAtdHQ4nV0KMqDbHQ4ncvgyeAcc1nHcFXKGCv3NWlGBvzvoqTtHa5MsoH6MqXc38m(WKqq8aPjnHkdHEoHMTMtLrbHGy2CmeAztOdDOdnxsCf2xAzzXvwyX1ZtKAn3XSLv5cn3zNv)Sv2uzzz1CgekHMcpsOMe8Fdc9(lHY6dCG)La8xWVDCznHU4zYyl2juXlHe6WeV0eyNqv8tLJcpHTZYkKqtCgekR4RK4gyNqzDmqyfExM1eA8ekRJbcRW7YESghiSZAcDccnv6S5Si0SsKoBpHTZYkKqz5miuwXxjXnWoHY6yGWk8UmRj04juwhdewH3L9ynoqyN1e6eeAQ0zZzrOzLiD2EcBNLviHMivCgekR4RK4gyNqzDmqyfExM1eA8ekRJbcRW7YESghiSZAcnRePZ2tyJW2zNv)Sv2uzzz1CgekHMcpsOMe8Fdc9(lHYAbUyzrgwtOlEMm2IDcv8siHomXlnb2juf)u5OWty7SScj0eUEgekR4RK4gyNqzDmqyfExM1eA8ekRJbcRW7YESghiSZAcDccnv6S5Si0SsKoBpHncBNDw9ZwztLLLvZzqOeAk8iHAsW)ni07VekRvDGaxSSidRj0fptgBXoHkEjKqhM4LMa7eQIFQCu4jSDwwHekR8miuwXxjXnWoHY6LPW7V5O3LznHgpHY6LPW7V5O3L9ynoqyN1eAwjsNTNW2zzfsOjs1ZGqzfFLe3a7ekRxMcV)MJExM1eA8ekRxMcV)MJEx2J14aHDwtOtqOPsNnNfHMvI0z7jSDwwHeklU0zqOSIVsIBGDcL1INbYXQU3LznHgpHYAXZa5yv37YESghiSZAcnlwsNTNWgHTZoR(zRSPYYYQ5miucnfEKqnj4)ge69xcL1IG1e6INjJTyNqfVesOdt8stGDcvXpvok8e2olRqc1LodcLv8vsCdStOSw8mqow19UmRj04juwlEgihR6Ex2J14aHDwtOzLiD2EcBNLviHM6ZGqzfFLe3a7ekRJbcRW7YSMqJNqzDmqyfEx2J14aHDwtOzLiD2EcBNLviHEspdcLv8vsCdStOSogiScVlZAcnEcL1XaHv4DzpwJde2znHMvI0z7jSDwwHeAIuFgekR4RK4gyNqzDmqyfExM1eA8ekRJbcRW7YESghiSZAcnRePZ2tyJW2zNv)Sv2uzzz1CgekHMcpsOMe8Fdc9(lHYAvhiWlRj0fptgBXoHkEjKqhM4LMa7eQIFQCu4jSDwwHeklNbHYk(kjUb2juwVmfE)nh9UmRj04juwVmfE)nh9UShRXbc7SMqZkr6S9e2olRqc98ZGqzfFLe3a7ekRxMcV)MJExM1eA8ekRxMcV)MJEx2J14aHDwtOzLiD2EcBNLviHMQNbHYk(kjUb2juwlEgihR6ExM1eA8ekRfpdKJvDVl7XACGWoRj0ji0uPZMZIqZkr6S9e2olRqcnrQEgekR4RK4gyNqz9Yu493C07YSMqJNqz9Yu493C07YESghiSZAcDccnv6S5Si0SsKoBpHTZYkKqz5KEgekR4RK4gyNqzT4zGCSQ7DzwtOXtOSw8mqow19UShRXbc7SMqZIL0z7jSry7SZQF2kBQSSSAodcLqtHhjutc(VbHE)LqzDhVdduWAcDXZKXwStOIxcj0HjEPjWoHQ4NkhfEcBNLviHYYzqOSIVsIBGDcL1XaHv4DzwtOXtOSogiScVl7XACGWoRj0SsKoBpHTZYkKqtK4miuwXxjXnWoHY6yGWk8UmRj04juwhdewH3L9ynoqyN1e6eeAQ0zZzrOzLiD2EcBNLviHMGLZGqzfFLe3a7ekRJbcRW7YSMqJNqzDmqyfEx2J14aHDwtOtqOPsNnNfHMvI0z7jSry7SZQF2kBQSSSAodcLqtHhjutc(VbHE)Lqz98iRj0fptgBXoHkEjKqhM4LMa7eQIFQCu4jSDwwHeAQpdcLv8vsCdStOSogiScVlZAcnEcL1XaHv4DzpwJde2znHMvI0z7jSDwwHeAIeNbHYk(kjUb2juwhdewH3LznHgpHY6yGWk8UShRXbc7SMqZkr6S9e2olRqcnrQEgekR4RK4gyNqzDmqyfExM1eA8ekRJbcRW7YESghiSZAcnRePZ2tyJWwQSe8FdStOSscDuH9fHczIq4jSP5gMG)xnhNjXk0CW3)AqOM7KCsi0ZUv9JbsoUe6jZVKty7KCsi0tMtgcnb7eklUYcle2iSDsojekRGF2CuCge2ojNec1feAkh4iNqz1AIqqO)Lqz1YSziuRcCxg4bHc95MYty7KCsiuxqOPCGJCcLdUvLv5ekRyNcj0tgnLCcf6ZnLNW2j5KqOUGqz17Dc15fIRLZheQIhvYfeA8eQ0uziuwXjdekwXAOWty7KCsiuxqOS69oHALluVKZeekRwiuWR25gEcBe2ojNecnvknQycStOo49xKqvVKZeeQdMBLWtOS6kfcpeeA9Ll4Nv6YarOJkSVee6xqz8e2gvyFj8Wxu9sot0cStD(iGWo4cnzW(Hv5G4tBfHTrf2xcp8fvVKZeTa70KZAJdeYEnsiS0myb(cWiqqSwjhd2F4WeyWEYbIbHHNjJbho29wjultmoqi4mzMkyKaDmPPWMg8mzm4WXUphA62e)kaotphBAWZKXGdh7(JDcEr8f20GNjJbho29FsCv8ZMJDWuM0aCMiWnttdEMmgC4y3l4N(FKVJaoi(aLAAWZKXGdh7(GhbxBfbqy5gutdEMmgC4y3Rgfpc(lyuNjJTyhelocMffe2gvyFj8Wxu9sot0cStVqOGxTZniSnQW(s4HVO6LCMOfyNQ4nGdZkc2TlStO(Kynv4llNpa3bjSnQW(s4HVO6LCMOfyNQ4nWXKez3UWormqyfESWn3ozTkhGqwAC9ynoqyNWgHTtYjHqtLsJkMa7ekMe3meAysiHg8iHoQ4xc1ee6KCmOXbc9e2gvyFjGjGJZc4NQdeXAYrcBJkSVeTa70KZAJdeYEnsim(hQdsZGf7pCycmyp5aXGWu)d1)JYBvYxocsZGfi4rWbVfiiSCC9lknwjAFTC(aSO0yLOP5A58byrPXkHlu)d1)JYBvYxocsZGfi4rWbVfiiSCC9lknwjKjblU6oRSIbcRWlWfllY4(A58byrPXkrB1)q9)O8cCXYIm(fLgReUv)d1)JYlWfllY4xuASs0oHRz30KL6FO(FuEr8ReaNn4bt1bxBr)LbccSOIF2CeeMekZ1Y5dWIsJvc3Q)H6)r5fXVsaC2GhmvhCTf9xgiiWIk(zZrqysy7ePo7MMSu)d1)JYlIFLa4SbpyQo4Al6v8ZMJcyU6w9pu)pkVi(vcGZg8GP6GRTOFrPXkHmxlNpalknwjYoBcBJkSVeTa7u4FyFXUDHLLdZ96f4ILfz8mWBACyUxVi(vcGZg8GP6GRTONbE2UHJHpndwGGhbh8wGGWYX1pQWsInnoVq4(A58byrPXkHmWsvxjSnQW(s0cStvdeeyuH9faYeb71iHWe4ILfzyxeRPcyjy3UWCyUxVaxSSiJNboHTrf2xIwGDQAGGaJkSVaqMiyVgje2boW)sa(l43oUSlI1ubSeSBxyom3R)ah4Fja)f8BhxpdCcBJkSVeTa7u1abbgvyFbGmrWEnsiShow4YUiwtfWsWUDHfMekJl5wXBYKA3Naog(0mybcEeCWBbcclhx)OcljsyBuH9LOfyNEnra(li4rWbVfiiSCCzxLrbHGy2CmeWsWUDHP4nV0K2fkERnSZDNfw4MNXhMecIhinPLjrtdw4MNXhMecIhinPLXLCR(hQ)hL)AIqa(l4YSz8lknwjKjHp1nnQ)H6)r5pWb(xcWFb)2X1VO0yLqgwY29j6OdZ96D(c7mIa4S4bOJom3RNboHTrf2xIwGDkMgocb4NvID7ctXBEPjTlu8wByjCNfw4MNXhMecIhinPLjrtJ6FO(FuEbUyzrg)IsJvczyPPblCZZ4dtcbXdKM0Y4sUv)d1)JYFnria)fCz2m(fLgReYKWN6Mg1)q9)O8h4a)lb4VGF746xuASsidlz7(eom3R35lSZicGZIhEg4e2gvyFjAb2PHLJla(ajXUkJccbXS5yiGLGD7ct9sopqeRjhDR4nV0K2fkERnmwCNfw4MNXhMecIhinPLjrtJ6FO(FuEbUyzrg)IsJvczyPPblCZZ4dtcbXdKM0Y4sUv)d1)JYFnria)fCz2m(fLgReYKWN6Mg1)q9)O8h4a)lb4VGF746xuASsidlz7(eD0H5E9oFHDgraCw8a0rhM71ZaNW2Oc7lrlWovXBahMveSBxyQpjwtf(YY5dWDq3Q)H6)r5VdczfceXlb3VO0yLOnlP2DwkEZlnPDHI3AdlH7rfwseGfkzOawc37yDaMeRWp9UWBvBwCTPrXBEPjTlu8wByS4EuHLebyHsgkAdJLSjSnQW(s0cStvdeeyuH9faYeb71iHWuDGaVSlI1ubSeSBxyNigiScVaxSSidHTrf2xIwGDQAGGaJkSVaqMiyVgjeMQde4ILfzyxeRPcyjy3UWIbcRWlWfllYqyBuH9LOfyNQgiiWOc7laKjc2RrcHjc2fXAQawc2TlSrfwseGfkzOqMZjSnQW(s0cStvdeeyuH9faYeb71iHWMhzxeRPcyjy3UWgvyjrawOKHI2WoNWgHTrf2xc)8iSdEBHSkh03j)laCMsXtyBuH9LWpp2cStXc3C7K1QCaczPTLD7ctXBEPjTlu8wByS4glCZZ4dtcbXdKM0TzPPrXBEPjTlu8wByUeHTrf2xc)8ylWova3QYQCGANcbYnLC2Tlm1l58arSMC0Dwom3RVpLcb)fO4nwL5zG300rhM7178f2zebWzXdqhDyUxpd8SjSnQW(s4NhBb2PxtecWFbxMnd72fgw4MNXhMecIhinPBJPrftGGWKWMgfV5LM0UqXBYalbHTrf2xc)8ylWoDnHv5abtbKBk5SRYOGqqmBogcyjy3UWYkgiSc)bVTqwLd67K)faotP4DR(hQ)hLFnHv5abtbKBk5(oZoH9vB1)q9)O8h82czvoOVt(xa4mLI3VO0yLOfxkB3zP(hQ)hL)AIqa(l4YSz8lknwjAFEtJI3Adl1ztyBuH9LWpp2cStxgbVv5aw10rWHvD2TlmhM71VmcERYbSQPJGdR6((Fue2gvyFj8ZJTa7umnCecWpRe72fMI38stAxO4T2WsqyBuH9LWpp2cStVMia)fe8i4G3ceewoUSRYOGqqmBogcyjy3UWu8MxAs7cfV1g25e2gvyFj8ZJTa7ufVbCywrWUDHP4nV0K2fkERnmwiSnQW(s4NhBb2PQDuYHSkhWQMocGSC(OSkND7cZH5E9bpcqj44(RaOg4JYIF9IyuYBNGv6glCZZ4dtcbXdKM0TX0OIjqqysOls4w9pu)pk)1eHa8xWLzZ4xuASs0gtJkMabHjHe2gvyFj8ZJTa70WYXfaFGKyxLrbHGy2CmeWsWUDHP4nV0K2fkERnmwCN1jIbcRWZBbq9soFtJ6LCEGiwtoMnHTrf2xc)8ylWoDw1uii(DXky3UWu8MxAs7cfV1gwccBJkSVe(5XwGDQaUvLv5a1ofcKBk5SBxyQxY5bIyn5O7Su)d1)JY78f2zebWzXd)IsJvI2S00Cc1NeRPcFHQ9H(TNT7Su8wByPUPr9pu)pk)1eHa8xWLzZ4xuASs0ovBAu)d1)JYFnria)fCz2m(fLgReTp3TI3Ad7C3yHBEgFysiiEqQDvMennyHBEgFysiiEG0KwgyzDElNFYv)d1)JYFnria)fCz2m(fLgReYK6SBACyUxVi(vcGZg8GP6GRTONbE2e2gvyFj8ZJTa7ufVboMKi72fM6LCEGiwtosyBuH9LWpp2cStVqzSkhiWfowbqUPKZUDH5WCVENxoa((kF)pk2TkWDzGhWsqyBuH9LWpp2cStDGgL8NjaYnLC2vzuqiiMnhdbSeSBxyQxY5bIyn5O7SCyUxVZlhaFFLNbEttmqyfEElaQxY5DdFXKGCv3NWhwoUa4dKKBfVbJf3Q)H6)r5VMieG)cUmBg)IsJvczoVPrXBEPjTlu8MmWs4g(Ijb5QUpHxa3QYQCGANcbYnLC3yHBEgFysiiEG0KwMZZMWgHTrf2xcVQde4fMvjF5iindwGGhbh8wGGWYXLD7c7ejN1ghi0Z)qDqAgSCNL6FO(Fu(1ewLdemfqUPK7xuASsidlnnNq9jXAQWlpZAtLT7SoH6tI1uHVq1(q)2BAu)d1)JY78f2zebWzXd)IsJvczyj7MMRLZhGfLgReYWsQjSnQW(s4vDGaVTa704zu8G)c64e8SBxyxlNpalknwjANvIuHRUyzk8(Bo6VtmqG4zu8N8eS4A2nnom3Rxe)kbWzdEWuDW1w03)JYnCm8PzWce8i4G3ceewoU(rfws0DwNq9jXAQWxOAFOF7nnom3R35lSZicGZIhEg4z30KL6FO(FuERs(YrqAgSabpco4TabHLJRFrPXkr7RLZhGfLgRez72H5E9oFHDgraCw8WZaVPX5fc3xlNpalknwjKjHRe2gvyFj8QoqG3wGD6boW)sa(l43oUSBxyzTJ1bysSc)07cVvTDPu30SJ1bysSc)07cpd8SDR(hQ)hLFnHv5abtbKBk5(fLgReYGPrftGGWKq3Q)H6)r5Tk5lhbPzWce8i4G3ceewoU(fLgReTZIfxBHfxp5ltH3FZrVvjF54kaDeYY5JSBACEHW91Y5dWIsJvczop1e2gvyFj8QoqG3wGD6DqiRqGiEj4SBxyQxY5bIyn5O7S2X6amjwHF6DH3Q2jCTPzhRdWKyf(P3fEg4ztyBuH9LWR6abEBb2P3bcclWVDCz3UW2X6amjwHF6DH3Q2N7AtZowhGjXk8tVl8mWjSnQW(s4vDGaVTa7uNVWoJiaolEWUDHDchM7178f2zebWzXdpdC3zP4T2WyX91Y5dWIsJvI2PQRUZs9pu)pkVi(vcGZg8GP6GRTOxXpBokA7AtJ6FO(FuEr8ReaNn4bt1bxBr)IsJvI2jCnB3zbhdFAgSabpco4TabHLJRFuHLeBAu)d1)JYBvYxocsZGfi4rWbVfiiSCC9lknwjANW1MMKZAJde65FOoindwz30KLI3AdJf3xlNpalknwjKbwQ6Q7SGJHpndwGGhbNDElqqy546hvyjXMg1)q9)O8wL8LJG0mybcEeCWBbcclhx)IsJvI2xlNpalknwjY2DwQ)H6)r5fXVsaC2GhmvhCTf9k(zZrrBxBAu)d1)JYlIFLa4SbpyQo4Al6xuASs0(A58byrPXkrtJdZ96fXVsaC2GhmvhCTf9mWZo7MgNxiCFTC(aSO0yLqMePo7MgNxiCFTC(aSO0yLqMeU6w8mqow19q40bozay6rcoesyBuH9LWR6abEBb2PI4xjaoBWdMQdU2IGRLEcKD7ct9vNXcV6)TB1eyh83lwclj6XACGWoHTrf2xcVQde4TfyNkIFLa4SbpyQo4AlYUDHP(hQ)hLxe)kbWzdEWuDW1w0R4NnhfWyPP5A58byrPXkHmS4Attw7yDaMeRWp9UWVO0yLODIu30K1juFsSMk8YZS2uUpH6tI1uHVq1(q)2Z2DwzTJ1bysSc)07cVvTv)d1)JYlIFLa4SbpyQo4Al6VmqqGfv8ZMJGWKWMMtSJ1bysSc)07cpM2eHiB3zP(hQ)hL3QKVCeKMblqWJGdElqqy546xuASs0w9pu)pkVi(vcGZg8GP6GRTO)YabbwuXpBocctcBAsoRnoqON)H6G0myLD2Uv)d1)JYFnria)fCz2m(fLgReYaJv6wXBTHXIB1)q9)O8h82czvoOVt(xa4mLI3VO0yLqgyjyjBcBJkSVeEvhiWBlWove)kbWzdEWuDW1wKD7ct9jXAQWlpZAt5olhM71FGd8VeG)c(TJRNbEttwxlNpalknwjKr9pu)pk)boW)sa(l43oU(fLgRennQ)H6)r5pWb(xcWFb)2X1VO0yLOT6FO(FuEr8ReaNn4bt1bxBr)LbccSOIF2CeeMeMTB1)q9)O8xtecWFbxMnJFrPXkHmWyLUv8wByS4w9pu)pk)bVTqwLd67K)faotP49lknwjKbwcwYMW2Oc7lHx1bc82cStfXVsaC2GhmvhCTfz3UWuFsSMk8fQ2h63U7o6WCVENVWoJiaolEa6OdZ96zG7ol4y4tZGfi4rWbVfiiSCC9JkSKyttYzTXbc98puhKMbRMg1)q9)O8wL8LJG0mybcEeCWBbcclhx)IsJvI2Q)H6)r5fXVsaC2GhmvhCTf9xgiiWIk(zZrqysytJ6FO(FuERs(YrqAgSabpco4TabHLJRFrPXkr7ZDnBcBJkSVeEvhiWBlWoLrGalqj2RrcHzLqTmX4aHGZKzQGrc0XKMcz3UWGJHpndwGGhbh8wGGWYX1pQWsInnoVq4(A58byrPXkHmS4kHTrf2xcVQde4TfyNYiqGfOe71iHWcEeCTveaHLBqSBxyWXWNMblqWJGdElqqy546hvyjXMg1)q9)O8wL8LJG0mybcEeCWBbcclhx)IsJvI2PQRUVwoFawuASs0(CxDTPX5fc3xlNpalknwjKHfxjSnQW(s4vDGaVTa70JDcEr8fYUDHbhdFAgSabpco4TabHLJRFuHLeBACEHW91Y5dWIsJvczyXvcBJkSVeEvhiWBlWonhA62e)kaotphz3UWGJHpndwGGhbh8wGGWYX1pQWsInnoVq4(A58byrPXkHmS4kHTrf2xcVQde4TfyNYiqGfOe71iHW6lo9RTiijkeie72f2jsoRnoqOpndwGVamceeRvYXOPr9pu)pkVvjF5iindwGGhbh8wGGWYX1VO0yLOnlU6gog(0mybcEeCWBbcclhx)IsJvczyX1MMKZAJde65FOoindwe2gvyFj8QoqG3wGDkJabwGsSxJectWp9)iFhbCq8bkXUDHbhdFAgSabpco4TabHLJRFuHLeBACEHW91Y5dWIsJvczyX1MMtSmfE)nh9wL8LJRa0rilNpiSnQW(s4vDGaVTa7ugbcSaLyVgjewWJGRTIaiSCdID7cdog(0mybcEeCWBbcclhx)IsJvI2jsDtJ6FO(FuERs(YrqAgSabpco4TabHLJRFrPXkr7u1v3xlNpalknwjAFURU2048cH7RLZhGfLgReYWIRe2gvyFj8QoqG3wGDkJabwGsSxJecdNn4DwCKJRaysWhvWUDHDIKZAJde6tZGf4laJabXALCmAAu)d1)JYBvYxocsZGfi4rWbVfiiSCC9lknwjAZIRUHJHpndwGGhbh8wGGWYX1VO0yLqgwCTPj5S24aHE(hQdsZGfHTrf2xcVQde4TfyNYiqGfOKGD7c7ejN1ghi0NMblWxagbcI1k5y00O(hQ)hL3QKVCeKMblqWJGdElqqy546xuASs0MfxBAsoRnoqON)H6G0myryBuH9LWR6abEBb2PXZO4b)fiFwPHD7c7A58byrPXkrBwPRnnWXWNMblqWJGdElqqy546hvyjXMMKZAJde65FOoindwnnoVq4(A58byrPXkHmjsvcBJkSVeEvhiWBlWo1b6)o4YSzy3UWu)d1)JYBvYxocsZGfi4rWbVfiiSCC9lknwjAFURnnjN1ghi0Z)qDqAgSAACEHW91Y5dWIsJvczyXvcBJkSVeEvhiWBlWo1bxbUYTkND7ct9pu)pkVvjF5iindwGGhbh8wGGWYX1VO0yLO95U20KCwBCGqp)d1bPzWQPX5fc3xlNpalknwjKjrQjSnQW(s4vDGaVTa7uilNpeawftpxcRGW2Oc7lHx1bc82cStV2Ioq)3z3UWu)d1)JYBvYxocsZGfi4rWbVfiiSCC9lknwjAFURnnjN1ghi0Z)qDqAgSAACEHW91Y5dWIsJvczs4kHTrf2xcVQde4TfyNoLcfXoqa1abXUDHP(hQ)hL3QKVCeKMblqWJGdElqqy546xuASs0(CxBAsoRnoqON)H6G0my1048cH7RLZhGfLgReYWIRe2gvyFj8QoqG3wGDQZKd(liwtjxWUDH5WCVEr8ReaNn4bt1bxBrF)pkcBJkSVeEvhiWBlWo9cHcE1o3GD7cZH5E9cCXYIm((FuUDyUxVZxyNreaNfpaD0H5E99)OC7WCVENVWoJiaolE47)r5olXZa5yv3dNremqiaxg4H9vtJ4zGCSQ7t(qtyqiq8qjXkYMDRcCxg4bWKKWUnbclb7wf4UmWdqo07mqWsWUvbUld8ayxyINbYXQUp5dnHbHaXdLeRGWgHTrf2xcVQde4ILfzGLCwBCGq2RrcHjWfllYaCywrW(dhMad2toqmim1)q9)O8cCXYIm(fLgReYKOPbog(0mybcEeCWBbcclhx)Oclj6w9pu)pkVaxSSiJFrPXkr7ZDTPX5fc3xlNpalknwjKHfxjSnQW(s4vDGaxSSitlWo1QKVCeKMblqWJGdElqqy54YUDHDIKZAJde65FOoindwnnoVq4(A58byrPXkHmSKAcBJkSVeEvhiWfllY0cStDG(VdUmBg2TlSKZAJde6f4ILfzaomRiiSnQW(s4vDGaxSSitlWo1bxbUYTkND7cl5S24aHEbUyzrgGdZkccBJkSVeEvhiWfllY0cStHSC(qayvm9CjSccBJkSVeEvhiWfllY0cStV2Ioq)3z3UWsoRnoqOxGlwwKb4WSIGW2Oc7lHx1bcCXYImTa70PuOi2bcOgii2TlSKZAJde6f4ILfzaomRiiSnQW(s4vDGaxSSitlWo1zYb)feRPKly3UWsoRnoqOxGlwwKb4WSIGW2Oc7lHx1bcCXYImTa704zu8G)c64e8SBxyxlNpalknwjANvIuHRUyzk8(Bo6VtmqG4zu8N8eS4A2nnWXWNMblqWJGdElqqy546hvyjr3zDc1NeRPcFHQ9H(T304WCVENVWoJiaolE4zGNDttwQ)H6)r5Tk5lhbPzWce8i4G3ceewoU(fLgReTVwoFawuASsKTBhM7178f2zebWzXdpd8MgNxiCFTC(aSO0yLqMeUsyBuH9LWR6abUyzrMwGDA8mkEWFbYNvAy3UWUwoFawuASs0Mv6AtdCm8PzWce8i4G3ceewoU(rfwsSPX5fc3xlNpalknwjKjHRe2gvyFj8QoqGlwwKPfyNEGd8VeG)c(TJl72fM6FO(Fu(1ewLdemfqUPK7xuASsidMgvmbcctcjSnQW(s4vDGaxSSitlWo1kHAzIXbcbNjZubJeOJjnfYUDHLCwBCGqVaxSSidWHzfrtJZleUVwoFawuASsidlUsyBuH9LWR6abUyzrMwGDkJabwGsSxJecl4rW1wraewUbXUDHLCwBCGqVaxSSidWHzfrtJZleUVwoFawuASsidlUsyBuH9LWR6abUyzrMwGD6XobVi(cz3UWsoRnoqOxGlwwKb4WSIGW2Oc7lHx1bcCXYImTa70COPBt8Ra4m9CKD7cl5S24aHEbUyzrgGdZkccBJkSVeEvhiWfllY0cStzeiWcuI9AKqyc(P)h57iGdIpqj2Tlm4y4tZGfi4rWbVfiiSCC9JkSKytJZleUVwoFawuASsidlU20CILPW7V5O3QKVCCfGocz58bHTrf2xcVQde4ILfzAb2PmceybkXEnsimC2G3zXroUcGjbFub72f2jsoRnoqOpndwGVamceeRvYXOPr9pu)pkVvjF5iindwGGhbh8wGGWYX1VO0yLOnlU20KCwBCGqp)d1bPzWIW2Oc7lHx1bcCXYImTa7ugbcSaLeSBxyNi5S24aH(0myb(cWiqqSwjhJMg1)q9)O8wL8LJG0mybcEeCWBbcclhx)IsJvI2S4AttYzTXbc98puhKMblcBJkSVeEvhiWfllY0cStVdczfceXlbNW2Oc7lHx1bcCXYImTa707abHf43oUe2gvyFj8QoqGlwwKPfyN68f2zebWzXd2TlmNxiCFTC(aSO0yLqMePUPjlfV1gglUZ6A58byrPXkr7u1v3zLL6FO(FuEbUyzrg)IsJvI2jCTPXH5E9cCXYImEg4nnQ)H6)r5f4ILfz8mWZ2DwWXWNMblqWJGdElqqy546hvyjXMg1)q9)O8wL8LJG0mybcEeCWBbcclhx)IsJvI2jCTPj5S24aHE(hQdsZGv2zNDttwxlNpalknwjKbwQ6Q7SGJHpndwGGhbNDElqqy546hvyjXMg1)q9)O8wL8LJG0mybcEeCWBbcclhx)IsJvI2xlNpalknwjYo7SjSnQW(s4vDGaxSSitlWovGlwwKHD7ct9pu)pk)AcRYbcMci3uY9lknwjKHLMgNxiCFTC(aSO0yLqMePMW2Oc7lHx1bcCXYImTa7uNjh8xqSMsUGW2Oc7lHx1bcCXYImTa70lek4v7Cd2TlmhM71lWfllY47)r52H5E9oFHDgraCw8a0rhM713)JYTdZ96D(c7mIa4S4HV)hL7SepdKJvDpCgrWaHaCzGh2xnnINbYXQUp5dnHbHaXdLeRiB2TkWDzGhatsc72eiSeSBvG7Yapa5qVZablb7wf4UmWdGDHjEgihR6(Kp0egecepusSccBe2gvyFj8pCSWf21eb4VGGhbh8wGGWYXLDvgfecIzZXqalb72fMI38stAxO4T2WoNW2Oc7lH)HJfUTa7umnCecWpRe72fwmqyfEfVbCywr4XACGWUBfV5LM0UqXBTHDoHTrf2xc)dhlCBb2PHLJla(ajXUkJccbXS5yiGLGD7ct9sopqeRjhDR4nV0K2fkERnmwiSnQW(s4F4yHBlWovXBGJjjYUDHP4nV0K2fkEdgle2gvyFj8pCSWTfyNIPHJqa(zLiSnQW(s4F4yHBlWonSCCbWhij2vzuqiiMnhdbSeSBxykEZlnPDHI3AdJfcBe2gvyFj8cCXYImWUMieG)cUmBg2TlmhM71lWfllY4xuASsitccBJkSVeEbUyzrMwGDQaUvLv5a1ofcKBk5SBxyQxY5bIyn5O7SgvyjrawOKHI2WoVPzuHLebyHsgkANW9ju)d1)JYVMWQCGGPaYnLCpd8SjSnQW(s4f4ILfzAb2PRjSkhiykGCtjNDvgfecIzZXqalb72fM6LCEGiwtosyBuH9LWlWfllY0cStVMieG)cUmBg2TlSrfwseGfkzOOnSZjSnQW(s4f4ILfzAb2Pc4wvwLdu7uiqUPKZUDHPEjNhiI1KJUDyUxFFkfc(lqXBSkZZaNW2Oc7lHxGlwwKPfyN6ank5ptaKBk5SRYOGqqmBogcyjy3UWuVKZdeXAYr3om3R)ah4Fja)f8BhxpdC3Q)H6)r5xtyvoqWua5MsUFrPXkrBwiSnQW(s4f4ILfzAb2PxtecWFbxMnd7wf4UmWdGDHDc1)q9)O8RjSkhiykGCtj3ZaNW2Oc7lHxGlwwKPfyNkGBvzvoqTtHa5Mso72fM6LCEGiwto6UJom3R35lSZicGZIhGo6WCVEg4e2gvyFj8cCXYImTa70RjcWFbbpco4TabHLJl7QmkieeZMJHawc2TlmfVjZ5e2gvyFj8cCXYImTa7uhOrj)zcGCtjNDvgfecIzZXqalb72fM6LCEGiwto20CIyGWk88wauVKZtyBuH9LWlWfllY0cStfWTQSkhO2PqGCtjNWgHTrf2xcViGDWBlKv5G(o5FbGZukE2TlSSCyUxp81K(TBdea(hyf2a5fXOKldRSPXH5E9oFHDgraCw8WVO0yLqg1)q9)O8RjSkhiykGCtj3VO0yLWTdZ96D(c7mIa4S4HNbUB4y4tZGfi4rWbVfiiSCC9JkSKy2UZAhRdWKyf(P3fERAR(hQ)hL)G3wiRYb9DY)caNPu8(oZoH91j3vFQOPrahHGaXS5yiANiBcBJkSVeEr0cStXc3C7K1QCaczPTLD7ctXBEPjTlu8wByS4glCZZ4dtcbXdKM0TpVPrXBEPjTlu8wByUK7SWc38m(WKqq8aPjDBwAAob8ftcYvDFcFy54cGpqsztyBuH9LWlIwGDQaUvLv5a1ofcKBk5SBxyQxY5bIyn5OBhM713NsHG)cu8gRY8mWDN1owhGjXk8tVl8w12H5E99Pui4VafVXQm)IsJvcxWstZowhGjXk8tVl8mWZMW2Oc7lHxeTa70lek4v7Cd2TkWDzGhatsc72eiSeSBvG7Yapa2fMdZ96t(qtyqiq8qjXka8mst9w3ZaVPblCZZ4dtcbXdKM0YCEtJ6FO(Fu(1ewLdemfqUPK7xuASsidlnnQ)H6)r5VMieG)cUmBg)IsJvczyHD7ct8mqow19jFOjmieiEOKyfUDyUxVi(vcGZg8GP6GRTOV)hL7o6WCVENVWoJiaolEa6OdZ967)rryBuH9LWlIwGD6AcRYbcMci3uYzxLrbHGy2CmeWsWUDHP(hQ)hLxGlwwKXVO0yLODIMMtedewHxGlwwKXDwQ)H6)r5pWb(xcWFb)2X1VO0yLOTl10Cc1NeRPcV8mRnv2e2gvyFj8IOfyNEnria)fCz2mSBxyzTJ1bysSc)07cVvTv)d1)JYFnria)fCz2m(oZoH91j3vFQOPzhRdWKyf(P3fEg4z7olSWnpJpmjeepqAs3gtJkMabHjHUirtJI38stAxO4nzGLOPXH5E9I4xjaoBWdMQdU2I(fLgReYGPrftGGWKWwsKDtZ1Y5dWIsJvczW0OIjqqysyljAA6OdZ96D(c7mIa4S4bOJom3RNbEtJdZ96HVM0VDBGaW)dC9mWjSnQW(s4frlWovTJsoKv5aw10raKLZhLv5SBxyom3Rp4rakbh3Ffa1aFuw8RxeJsE7eSs3yHBEgFysiiEG0KUnMgvmbcctcDrc3Q)H6)r5xtyvoqWua5MsUFrPXkrBmnQyceeMe204WCV(GhbOeCC)vaud8rzXVErmk5Tt4sUZs9pu)pkVaxSSiJFrPXkHmP2DmqyfEbUyzrMMg1)q9)O8h4a)lb4VGF746xuASsitQDR(Kynv4LNzTPAAUwoFawuASsitQZMW2Oc7lHxeTa70LrWBvoGvnDeCyvND7cZH5E9lJG3QCaRA6i4WQUV)hL7rfwseGfkzOODccBJkSVeEr0cStVMia)fe8i4G3ceewoUSRYOGqqmBogcyjy3UWu8MmNtyBuH9LWlIwGDkMgocb4NvID7ctXBEPjTlu8wByjiSnQW(s4frlWovXBahMveSBxykEZlnPDHI3AdlH7rfwseGfkzOawc37yDaMeRWp9UWBvBwCTPrXBEPjTlu8wByS4EuHLebyHsgkAdJfcBJkSVeEr0cStv8g4ysISBxyNWH5E9Wxt63Unqa4)bUEg4e2gvyFj8IOfyNgwoUa4dKe7QmkieeZMJHawc2Tlm1l58arSMC0TI38stAxO4T2WyXTdZ96fXVsaC2GhmvhCTf99)OiSnQW(s4frlWova3QYQCGANcbYnLC2TlmhM71R4naw4MNXlIrjV95U6IuFYhvyjrawOKHc3om3Rxe)kbWzdEWuDW1w03)JYDwQ)H6)r5xtyvoqWua5MsUFrPXkrBwCR(hQ)hL)AIqa(l4YSz8lknwjAZstJ6FO(Fu(1ewLdemfqUPK7xuASsiZ5Uv)d1)JYFnria)fCz2m(fLgReTp3TI3AFEtJ6FO(Fu(1ewLdemfqUPK7xuASs0(C3Q)H6)r5VMieG)cUmBg)IsJvczo3TI3A7snnkEZlnPDHI3Kbwc3yHBEgFysiiEG0KwgwYUPXH5E9kEdGfU5z8IyuYBNWv3xlNpalknwjK5KsyBuH9LWlIwGDQd0OK)mbqUPKZUkJccbXS5yiGLGD7ct9sopqeRjhDNvmqyfEbUyzrg3Q)H6)r5f4ILfz8lknwjK58Mg1)q9)O8RjSkhiykGCtj3VO0yLODc3Q)H6)r5VMieG)cUmBg)IsJvI2jAAu)d1)JYVMWQCGGPaYnLC)IsJvczo3T6FO(Fu(Rjcb4VGlZMXVO0yLO95Uv8wBwAAu)d1)JYVMWQCGGPaYnLC)IsJvI2N7w9pu)pk)1eHa8xWLzZ4xuASsiZ5Uv8w7ZBAu8w7u304WCVENxoa((kpd8SjSnQW(s4frlWonSCCbWhij2vzuqiiMnhdbSeSBxyQxY5bIyn5OBfV5LM0UqXBTHXcHTrf2xcViAb2PZQMcbXVlwb72fMI38stAxO4T2WsqyBuH9LWlIwGD6fkJv5abUWXkaYnLC2TkWDzGhWsWUDHDc1NeRPcFHQ9H(T304WCVE4Rj9B3gia8pWkSbYZaNW2Oc7lHxeTa7uhOrj)zcGCtjNDvgfecIzZXqalb72fM6LCEGiwto6w9pu)pk)1eHa8xWLzZ4xuASsiZ5Uv8gmwCdFXKGCv3NWhwoUa4dKKBSWnpJpmjeepi1UktccBJkSVeEr0cStDGgL8NjaYnLC2vzuqiiMnhdbSeSBxyQxY5bIyn5OBSWnpJpmjeepqAsldlUZsXBEPjTlu8MmWs00aFXKGCv3NWhwoUa4dKu2e2iSnQW(s4pWb(xcWFb)2XfMAGGaJkSVaqMiyVgjeMQde4LDrSMkGLGD7c7eXaHv4f4ILfziSnQW(s4pWb(xcWFb)2XTfyNQgiiWOc7laKjc2RrcHP6abUyzrg2fXAQawc2TlSyGWk8cCXYIme2gvyFj8h4a)lb4VGF742cStXc3C7K1QCaczPTLD7ctXBEPjTlu8wByS4glCZZ4dtcbXdKM0TpNW2Oc7lH)ah4Fja)f8Bh3wGD6AcRYbcMci3uYzxLrbHGy2CmeWsqyBuH9LWFGd8VeG)c(TJBlWo9AIqa(l4YSzy3UWgvyjrawOKHI2WyXTdZ96pWb(xcWFb)2XfCC4xuASsitccBJkSVe(dCG)La8xWVDCBb2Ph82czvoOVt(xa4mLIND7cBuHLebyHsgkAdJfcBJkSVe(dCG)La8xWVDCBb2Pc4wvwLdu7uiqUPKZUDHPEjNhiI1KJUZAuHLebyHsgkAd7C3om3R)ah4Fja)f8BhxWXHNbEtJdZ967tPqWFbkEJvzEg4ztyBuH9LWFGd8VeG)c(TJBlWoftdhHa8ZkXUDHP4nyU62H5E9h4a)lb4VGF74coo8lknwjKXLiSnQW(s4pWb(xcWFb)2XTfyNEnra(li4rWbVfiiSCCzxLrbHGy2CmeWsWUDHP4nyU62H5E9h4a)lb4VGF74coo8lknwjKXLiSnQW(s4pWb(xcWFb)2XTfyNEWBlKv5G(o5FbGZukEcBJkSVe(dCG)La8xWVDCBb2PoqJs(Zea5Mso7QmkieeZMJHawc2Tlm1l58arSMC0T6FO(Fu(Rjcb4VGlZMXVO0yLWT6FO(Fu(1ewLdemfqUPK7xuASs42H5E9h4a)lb4VGF74coo8mWjSnQW(s4pWb(xcWFb)2XTfyNgwoUa4dKe7QmkieeZMJHawc2TlmfVbZv3om3R)ah4Fja)f8BhxWXHFrPXkHmUeHTrf2xc)boW)sa(l43oUTa70Rjcb4VGlZMHDRcCxg4bSeSBvG7YapaMKe2Tjqyjy3UWCyUx)boW)sa(l43oUGJdpdC3om3Rxe)kbWzdEWuDW1w0ZaNW2Oc7lH)ah4Fja)f8Bh3wGDQaUvLv5a1ofcKBk5SBxyom3RxXBaSWnpJxeJsE7ZD1fP(KpQWsIaSqjdfe2gvyFj8h4a)lb4VGF742cStVMia)fe8i4G3ceewoUSRYOGqqmBogcyjy3UWu8MmNtyBuH9LWFGd8VeG)c(TJBlWoftdhHa8ZkXUDHP4nV0K2fkERnSee2gvyFj8h4a)lb4VGF742cStv8gWHzfb72fMI38stAxO4T2WYkrlJkSKialuYqr7eztyBuH9LWFGd8VeG)c(TJBlWonSCCbWhij2vzuqiiMnhdbSeSBxyzDIyGWk88wauVKZ30OEjNhiI1KJz7wXBEPjTlu8wBySqyBuH9LWFGd8VeG)c(TJBlWo1bAuYFMai3uYzxLrbHGy2CmeWsWUDHPEjNhiI1KJUhvyjrawOKHczGDUBfV1g25nnom3R)ah4Fja)f8BhxWXHNboHTrf2xc)boW)sa(l43oUTa7ufVboMKiHTrf2xc)boW)sa(l43oUTa70lugRYbcCHJvaKBk5SBvG7YapGLqh6qRb]] )


end