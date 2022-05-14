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


    spec:RegisterPack( "Windwalker", 20220514, [[dS0q6cqiPeEKuIQnrk9jusnkbXPeKwLGc9kPKMfkv3Iuu7IQ(LuQggPQoMaTmuINPsvtJuextqPTjOOVPsfmous05uPIwNkvY8qPCpizFQuoOGcAHsP8qusyIQuHWfLsuSrbfOpkOaoPuIsRKu4LQuHOzQsL6MQuH0ojv5NOKuSuusk9ucnvbvFfLKQXsks7Lk)fyWqDyflMOEmjtwQUmYMvXNLIrtKttz1OKKxtQmBiUnb7wYVv1WHuhxkrwUsphvtx01rX2fW3vjJxO68cL1RsfQ5lK9dAxqx4oX(KKtpw0Nfw0pSb1eFWWut0e91eNygdn5erpkDtd5eRrGCIS6w1VgeD06erpXq(P7c3jYFMvrorNOmJHKTSLt2j2NKC6XI(SWI(HnOM4dgMAclAY9oroAs50JLW8oDIswVtLt2j2jUYjYQBv)Aq0rleFh9lDqnUJoXG4GAc7qml6ZclqnGAWkKMTH43fudndXHFrJoiomOXtoe)hiomiZgdITkPDzqNqmY3ykpudndXHFrJoiweTvLvnqmRyNIG47inLoig5BmLhQHMH4WWEhILFo)ynsjeRKiLooeNpelmvmiMvChbetvUgX9qn0mehg27qSvAw9cYtcXHbriUKANt6DIigp5UWDIpAQO1fUtVGUWDIunYiu31MtuTwsRnorLK5fM4qSMHyLKbX3qbX37ehvAF5epgpb)bKse4sYscKwdTorvmfcbYzBOK70lOlD6XIlCNivJmc1DT5evRL0AJtmheQsVsYaYmlp9unYiuhI1cXkjZlmXHyndXkjdIVHcIV3joQ0(YjsXrtiaPzfCPtV7DH7ePAKrOURnNOATKwBCIQxq(b8CnDeeRfIvsMxyIdXAgIvsgeFdfeZItCuP9LtmTgAbOhebNOkMcHa5SnuYD6f0Lo90ex4orQgzeQ7AZjQwlP1gNOsY8ctCiwZqSsYGyuqmloXrL2xorLKbUMaKlD6fwx4oXrL2xorkoAcbinRGtKQrgH6U2CPtVW0fUtKQrgH6U2CIQ1sATXjQKmVWehI1meRKmi(gkiMfN4Os7lNyAn0cqpicorvmfcbYzBOK70lOlDPt8Ig0FXb)b8BNwx4o9c6c3js1iJqDxBor1AjT24eBbeNdcvPNtlvwgZt1iJqDNipxtLo9c6ehvAF5evdccyuP9faX4PteX4jOgbYjQ6aoDCPtpwCH7ePAKrOURnNOATKwBCI5Gqv650sLLX8unYiu3jYZ1uPtVGoXrL2xor1GGagvAFbqmE6ermEcQrGCIQoGtlvwgZLo9U3fUtKQrgH6U2CIQ1sATXjQKmVWehI1meRKmi(gkiMfiwletfTnX8PjqG8bctCi(geFVtCuP9LtKkABS7yRAaeIf3wx60ttCH7ePAKrOURnN4Os7lN4ACRAaCMcOZu6CIQykecKZ2qj3Pxqx60lSUWDIunYiu31MtuTwsRnor1li)aEUMocI1cXQ)r6)v5pgp5G)aomBm)scJvCiwleR(hP)xLFnUvnaotb0zkD(LegR4qSwiwM5C8x0G(lo4pGF70cUU8mODIJkTVCIYiJs3ZKaDMsNtuftHqGC2gk5o9c6sNEHPlCNivJmc1DT5evRL0AJtuM5C8x0G(lo4pGF70cUU8mOHyTqSmZ5455VcaA2ucmvhCSL8mOHyTqClGyoLa5Vy4(0OLfwjGf0kiwlepQ0cqaQibJ4qmBqmlorRsAxg0PtmOt0QK2LbDcmbbQBtsoXGoXrL2xoXJXto4pGdZgZLo9UdUWDIunYiu31MtuTwsRnorzMZXFrd6V4G)a(Ttl46YZGgI1cXYmNJNN)kaOztjWuDWXwYZGgI1cXCkbYFXW9PrllSsalOvqCueepQ0cqaQibJ4q8nuqmlqSwiwM5C8x0G(lo4pGF70cUU8ljmwXHy2G4GoXrL2xoXJXto4pGdZgZLo9yLUWDIJkTVCIxs2IyvdOVtZxa0mLsYjs1iJqDxBU0P3D6c3js1iJqDxBor1AjT24evVG8d45A6iiwlehcepQ0cqaQibJ4q8nuq89qSwiwM5C8x0G(lo4pGF70cUU8mOH4OiiwM5C89Pue4paLKXQmpdAiouN4Os7lNihTvLvna1ofb0zkDU0Pxq9DH7ePAKrOURnNOATKwBCIkjdIrbX6dXAHyzMZXFrd6V4G)a(Ttl46YVKWyfhIzdI1eiokcIvsgeZgeFVtCuP9Lt8y8e8hqkrGljljqAn06evXuieiNTHsUtVGU0PxWGUWDIunYiu31MtuTwsRnorLK5fM4qSMHyLKbX3qbXbDIJkTVCIuC0ecqAwbx60lilUWDIunYiu31MtuTwsRnorLK5fM4qSMHyLKbX3qbXHaXbH4wH4rLwacqfjyehIVbXbH4qDIJkTVCIkjdiZS80Lo9cEVlCNivJmc1DT5evRL0AJtujzqmkiwFiwlelZCo(lAq)fh8hWVDAbxx(LegR4qmBqSMaXrrqCiqClG4CqOk9swcuVG87PAKrOoehfbXQxq(b8CnDeehkeRfIvsMxyIdXAgIvsgeFdfeZItCuP9LtmTgAbOhebNOkMcHa5SnuYD6f0Lo9cQjUWDIunYiu31MtuTwsRnorzMZXRKmav02eZZZrPdIVbX3RpeRzioSqCyeIhvAbiavKGrCN4Os7lNihTvLvna1ofb0zkDU0PxWW6c3js1iJqDxBor1AjT24evVG8d45A6iiwlepQ0cqaQibJ4qmBOG47HyTqSsYG4BOG47H4OiiwM5C8x0G(lo4pGF70cUU8mODIJkTVCIYiJs3ZKaDMsNtuftHqGC2gk5o9c6sNEbdtx4oXrL2xorLKbUMaKtKQrgH6U2CPtVG3bx4orRsAxg0PtmOtCuP9Lt8GeZQgaNw0uLaDMsNtKQrgH6U2CPlDICAPYYyUWD6f0fUtKQrgH6U2CIQ1sATXjkZCoEoTuzzm)scJvCiMnioOtCuP9Lt8y8Kd(d4WSXCPtpwCH7ePAKrOURnNOATKwBCIQxq(b8CnDeeRfIdbIhvAbiavKGrCi(gki(EiokcIhvAbiavKGrCi(geheI1cXTaIv)J0)RYVg3QgaNPa6mLopdAiouN4Os7lNihTvLvna1ofb0zkDU0P39UWDIunYiu31MtuTwsRnor1li)aEUMoYjoQ0(YjUg3QgaNPa6mLoNOkMcHa5SnuYD6f0Lo90ex4orQgzeQ7AZjQwlP1gN4OslabOIemIdX3qbX37ehvAF5epgp5G)aomBmx60lSUWDIunYiu31MtuTwsRnor1li)aEUMocI1cXYmNJVpLIa)bOKmwL5zq7ehvAF5e5OTQSQbO2PiGotPZLo9ctx4orQgzeQ7AZjQwlP1gNO6fKFapxthbXAHyzMZXFrd6V4G)a(TtRNbneRfIv)J0)RYVg3QgaNPa6mLo)scJvCi(geZItCuP9Ltugzu6EMeOZu6CIQykecKZ2qj3Pxqx607o4c3jAvs7YGob2Xj2c1)i9)Q8RXTQbWzkGotPZZG2joQ0(YjEmEYb)bCy2yorQgzeQ7AZLo9yLUWDIunYiu31MtuTwsRnor1li)aEUMocI1cXDsM5C8YFrDgEcKx6c0jzMZXZG2joQ0(YjYrBvzvdqTtraDMsNlD6DNUWDIunYiu31MtuTwsRnorLKbXSbX37ehvAF5epgpb)bKse4sYscKwdTorvmfcbYzBOK70lOlD6fuFx4orQgzeQ7AZjQwlP1gNO6fKFapxthbXrrqClG4CqOk9swcuVG87PAKrOUtCuP9Ltugzu6EMeOZu6CIQykecKZ2qj3Pxqx60lyqx4oXrL2xoroARkRAaQDkcOZu6CIunYiu31MlDPtu1bCAPYYyUWD6f0fUtKQrgH6U2CIpANiNs74ehvAF5edmRnYiKtmWSGAeiNiNwQSmgqMz5PtmWGWqor1)i9)Q8CAPYYy(LegR4qmBqCqiokcIrtPpodvGuIaxswsG0AO1pQ0cqqSwiw9ps)VkpNwQSmMFjHXkoeFdIVxFiokcILFohI1cXhRrkbljmwXHy2Gyw03jgyqyiaHWjNO6FK(FvEoTuzzm)scJvCiMnioiehfbXQ)r6)v550sLLX8ljmwXH4Bq896dXrrqS8Z5qSwi(ynsjyjHXkoeZgeZI(or1AjT24eZbHQ0BvGxhbIZqLNQrgH6U0PhlUWDIunYiu31MtuTwsRnoXwaXbM1gzeYl9iDqCgQG4Oiiw(5CiwleFSgPeSKWyfhIzdIzjSoXrL2xorRc86iqCgQCPtV7DH7ePAKrOURnNOATKwBCIbM1gzeYZPLklJbKzwE6ehvAF5eNsr8CheGAqqCPtpnXfUtKQrgH6U2CIQ1sATXjgywBKripNwQSmgqMz5PtCuP9Ltug5)o4WSXCPtVW6c3js1iJqDxBor1AjT24edmRnYiKNtlvwgdiZS80joQ0(YjESLKr(V7sNEHPlCNivJmc1DT5evRL0AJtmWS2iJqEoTuzzmGmZYtN4Os7lNOmTCA1zvJlD6DhCH7ePAKrOURnNOATKwBCIbM1gzeYZPLklJbKzwE6ehvAF5eLNgWFa5AkDCx60Jv6c3joQ0(YjoRAkcK)UuLorQgzeQ7AZLo9Utx4orQgzeQ7AZjQwlP1gNyoiuLERc86iqCgQ8unYiuhI1cXHaXhRrkbljmwXH4BqCiqCqwP(qSMH4LPOZVnK)m5GaYNrj5PAKrOoehgH4GSOpehkehfbXOP0hNHkqkrGljljqAn06hvAbiiwlehce3ciw9bOAQ0xKAFKF7qCueelZCoE5VOodpbYlD5zqdXHcXrrqCiqS6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXkoeFdIpwJucwsySIdXHcXAHyzMZXl)f1z4jqEPlpdAiokcILFohI1cXhRrkbljmwXHy2G4G6dXH6ehvAF5eZNrjb(dOttk5sNEb13fUtKQrgH6U2CIQ1sATXjMdcvP3QaVoceNHkpvJmc1HyTqCiq8XAKsWscJvCi(geFN6dXrrqmAk9XzOcKse4sYscKwdT(rLwacIJIGy5NZHyTq8XAKsWscJvCiMnioO(qCOoXrL2xoX8zusG)a0nRW4sNEbd6c3js1iJqDxBor1AjT24eBbeNdcvP3QaVoceNHkpvJmc1HyTqCiq8XAKsWscJvCi(gehcehKvQpeRziEzk68Bd5ptoiG8zusEQgzeQdXHrioil6dXHcXrrqSmZ54L)I6m8eiV0LNbnehfbXYpNdXAH4J1iLGLegR4qmBqCq9H4qDIJkTVCI5ZOKa)b0PjLCPtVGS4c3js1iJqDxBor1AjT24eBbeNdcvP3QaVoceNHkpvJmc1HyTqCiq8XAKsWscJvCi(geFN6dXrrqS8Z5qSwi(ynsjyjHXkoeZgehmmH4qDIJkTVCI5ZOKa)bOBwHXLo9cEVlCNivJmc1DT5evRL0AJtu9ps)Vk)ACRAaCMcOZu68ljmwXHy2GykoPyscKMa5ehvAF5eVOb9xCWFa)2P1Lo9cQjUWDIunYiu31MtSgbYjYQ(KPAiBxqN4PvX4a1GG4ehvAF5ezvFYunKTlOt80QyCGAqqCIQ1sATXjgywBKripNwQSmgqMz5jehfbXYpNdXAH4J1iLGLegR4qmBqml67sNEbdRlCNivJmc1DT5eRrGCIwXvltoYieOLyMkzeaDkGPiN4Os7lNOvC1YKJmcbAjMPsgbqNcykYjQwlP1gNyGzTrgH8CAPYYyazMLNqCueel)CoeRfIpwJucwsySIdXSbXSOVlD6fmmDH7ePAKrOURnNyncKt8ANuINFroXrL2xoXRDsjE(f5evRL0AJtmWS2iJqEoTuzzmGmZYtiokcILFohI1cXhRrkbljmwXHy2Gyw03Lo9cEhCH7ePAKrOURnNyncKt8dqRsA2gQdMYegG8KjTXCIJkTVCIFaAvsZ2qDWuMWaKNmPnMtuTwsRnoXaZAJmc550sLLXaYmlpH4Oiiw(5CiwleFSgPeSKWyfhIzdIzrFx60liR0fUtKQrgH6U2CI1iqorU00)RMD4Ob5NKGtCuP9LtKln9)QzhoAq(jj4evRL0AJtenL(4mubsjcCjzjbsRHw)OslabXrrqS8Z5qSwi(ynsjyjHXkoeZgeZI(qCuee3ciEzk68Bd5TkWRJwoOtiwJu6PAKrOUlD6f8oDH7ePAKrOURnNOATKwBCIbM1gzeYZPLklJbKzwE6ehvAF5eBqMUn5VCG80Bix60Jf9DH7ePAKrOURnNyncKtmLiWXwEc4wJH4ehvAF5etjcCSLNaU1yior1AjT24edmRnYiKNtlvwgdiZS8eIJIGy5NZHyTq8XAKsWscJvCiMniMf9DPtpwc6c3js1iJqDxBor1AjT24eBbehywBKriFCgQaFby4eixR0rjehfbXQ)r6)v5TkWRJaXzOcKse4sYscKwdT(LegR4q8niMf9H4OiioWS2iJqEPhPdIZqLtCuP9LtKHtaljbUlD6XclUWDIJkTVCINHqSIa88fq7ePAKrOURnx60JL7DH7ehvAF5epdccvGF706ePAKrOURnx60JfnXfUtKQrgH6U2CIQ1sATXjk)CoeRfIpwJucwsySIdXSbXbdlehfbXHaXkjdIVHcIzbI1cXHaXhRrkbljmwXH4BqCyQpeRfIdbIdbIv)J0)RYZPLklJ5xsySIdX3G4G6dXrrqSmZ5450sLLX8mOH4Oiiw9ps)VkpNwQSmMNbnehkeRfIdbIrtPpodvGuIaxswsG0AO1pQ0cqqCueeR(hP)xL3QaVoceNHkqkrGljljqAn06xsySIdX3G4G6dXrrqCGzTrgH8spsheNHkiouiouiouiokcIdbIpwJucwsySIdXSHcIdt9HyTqCiqmAk9XzOcKseGvxYscKwdT(rLwacIJIGy1)i9)Q8wf41rG4mubsjcCjzjbsRHw)scJvCi(geFSgPeSKWyfhIdfIdfId1joQ0(Yjk)f1z4jqEPlx60JLW6c3js1iJqDxBor1AjT24ev)J0)RYVg3QgaNPa6mLo)scJvCiMniMfiokcILFohI1cXhRrkbljmwXHy2G4GH1joQ0(YjYPLklJ5sNESeMUWDIJkTVCIYtd4pGCnLoUtKQrgH6U2CPtpwUdUWDIunYiu31MtuTwsRnorzMZXZPLklJ57)vbXAHyzMZXl)f1z4jqEPlqNKzohF)VkiwlelZCoE5VOodpbYlD57)vbXAH4qGy(ZGiBv3JMHNmieGwg0P9LNQrgH6qCueeZFgezR6(apYKgcb4psaQspvJmc1H4qDIwL0UmOtGDCI8Nbr2QUpWJmPHqa(JeGQ0jAvs7YGobMGa1TjjNyqN4Os7lN4bH4sQDoPt0QK2LbDcAqE5bXjg0LU0jYtx4o9c6c3js1iJqDxBor1AjT24edbILzohp61e(TBdca9NuL2G455O0bXSbX3jehfbXYmNJx(lQZWtG8sx(LegR4qmBqS6FK(Fv(14w1a4mfqNP05xsySIdXAHyzMZXl)f1z4jqEPlpdAiwleJMsFCgQaPebUKSKaP1qRFuPfGG4qHyTqCiq8owhqbOk9tVZ9wbX3Gy1)i9)Q8xs2IyvdOVtZxa0mLsY3z2jTVG4WieRVNvcXrrqmhnHGaYzBOKdX3G4GqCOoXrL2xoXljBrSQb03P5laAMsj5sNES4c3js1iJqDxBor1AjT24evsMxyIdXAgIvsgeFdfeZceRfIPI2My(0eiq(aHjoeFdIVhIJIGyLK5fM4qSMHyLKbX3qbXAceRfIdbIPI2My(0eiq(aHjoeFdIzbIJIG4waXOxkaOr19b9P1qla9GiaXH6ehvAF5ePI2g7o2QgaHyXT1Lo9U3fUtKQrgH6U2CIQ1sATXjQEb5hWZ10rqSwiwM5C89Pue4paLKXQmpdAiwlehceVJ1buaQs)07CVvq8niwM5C89Pue4paLKXQm)scJvCiwZqmlqCueeVJ1buaQs)07CpdAiouN4Os7lNihTvLvna1ofb0zkDU0PNM4c3js1iJqDxBor1AjT24e5pdISvDFGhzsdHa8hjavPNQrgH6qSwiwM5C888xbanBkbMQdo2s((FvqSwiUtYmNJx(lQZWtG8sxGojZCo((FvorRsAxg0jWoorzMZXh4rM0qia)rcqvcKyeM6TUNbDuev02eZNMabYhimXz7(Oi1)i9)Q8RXTQbWzkGotPZVKWyfNnwIIu)J0)RYFmEYb)bCy2y(LegR4SXIt0QK2LbDcmbbQBtsoXGoXrL2xoXdcXLu7Csx60lSUWDIunYiu31MtuTwsRnor1)i9)Q8CAPYYy(LegR4q8nioiehfbXTaIZbHQ0ZPLklJ5PAKrOoeRfIdbIv)J0)RYFrd6V4G)a(TtRFjHXkoeFdI1eiokcIBbeR(aunv61fBTPG4qDIJkTVCIRXTQbWzkGotPZjQIPqiqoBdLCNEbDPtVW0fUtKQrgH6U2CIQ1sATXjgceVJ1buaQs)07CVvq8niw9ps)Vk)X4jh8hWHzJ57m7K2xqCyeI13ZkH4OiiEhRdOauL(P35Eg0qCOqSwioeiMkABI5ttGa5deM4q8niMItkMKaPjqqSMH4GqCueeRKmVWehI1meRKmiMnuqCqiokcILzohpp)vaqZMsGP6GJTKFjHXkoeZgetXjftsG0eiiUvioiehkehfbXhRrkbljmwXHy2GykoPyscKMabXTcXbH4OiiUtYmNJx(lQZWtG8sxGojZCoEg0qCueelZCoE0Rj8B3gea6)IwpdAN4Os7lN4X4jh8hWHzJ5sNE3bx4orQgzeQ7AZjQwlP1gNOmZ54tjcqcOP9xoqnOhLL)655O0bX3G4G3jeRfIPI2My(0eiq(aHjoeFdIP4KIjjqAceeRzioieRfIv)J0)RYVg3QgaNPa6mLo)scJvCi(getXjftsG0eiiokcILzohFkrasanT)YbQb9OS8xpphLoi(gehutGyTqCiqS6FK(FvEoTuzzm)scJvCiMnioSqSwioheQspNwQSmMNQrgH6qCueeR(hP)xL)Ig0FXb)b8BNw)scJvCiMnioSqSwiw9bOAQ0Rl2AtbXrrq8XAKsWscJvCiMnioSqCOoXrL2xor1okDiw1ayvtNaiwJuww14sNESsx4orQgzeQ7AZjQwlP1gNOmZ54xgUKvnaw10jWLvDF)VkiwlepQ0cqaQibJ4q8nioOtCuP9LtCz4sw1ayvtNaxw1DPtV70fUtKQrgH6U2CIQ1sATXjQKmiMni(EN4Os7lN4X4j4pGuIaxswsG0AO1jQIPqiqoBdLCNEbDPtVG67c3js1iJqDxBor1AjT24evsMxyIdXAgIvsgeFdfeh0joQ0(YjsXrtiaPzfCPtVGbDH7ePAKrOURnNOATKwBCIkjZlmXHyndXkjdIVHcIdcXAH4rLwacqfjyehIrbXbHyTq8owhqbOk9tVZ9wbX3Gyw0hIJIGyLK5fM4qSMHyLKbX3qbXSaXAH4rLwacqfjyehIVHcIzXjoQ0(YjQKmGmZYtx60lilUWDIunYiu31MtuTwsRnoXwaXYmNJh9Ac)2TbbG(VO1ZG2joQ0(YjQKmW1eGCPtVG37c3js1iJqDxBor1AjT24evVG8d45A6iiwleRKmVWehI1meRKmi(gkiMfiwlelZCoEE(RaGMnLat1bhBjF)VkN4Os7lNyAn0cqpicorvmfcbYzBOK70lOlD6futCH7ePAKrOURnNOATKwBCIYmNJxjzaQOTjMNNJsheFdIVxFiwZqCyH4WiepQ0cqaQibJ4qSwiwM5C888xbanBkbMQdo2s((FvqSwioeiw9ps)Vk)ACRAaCMcOZu68ljmwXH4BqmlqSwiw9ps)Vk)X4jh8hWHzJ5xsySIdX3GywG4Oiiw9ps)Vk)ACRAaCMcOZu68ljmwXHy2G47HyTqS6FK(Fv(JXto4pGdZgZVKWyfhIVbX3dXAHyLKbX3G47H4Oiiw9ps)Vk)ACRAaCMcOZu68ljmwXH4Bq89qSwiw9ps)Vk)X4jh8hWHzJ5xsySIdXSbX3dXAHyLKbX3GynbIJIGyLK5fM4qSMHyLKbXSHcIdcXAHyQOTjMpnbcKpqyIdXSbXSaXHcXrrqSmZ54vsgGkABI555O0bX3G4G6dXAH4J1iLGLegR4qmBq8DWjoQ0(YjYrBvzvdqTtraDMsNlD6fmSUWDIunYiu31MtuTwsRnor1li)aEUMocI1cXHaX5Gqv650sLLX8unYiuhI1cXQ)r6)v550sLLX8ljmwXHy2G47H4Oiiw9ps)Vk)ACRAaCMcOZu68ljmwXH4BqCqiwleR(hP)xL)y8Kd(d4WSX8ljmwXH4BqCqiokcIv)J0)RYVg3QgaNPa6mLo)scJvCiMni(EiwleR(hP)xL)y8Kd(d4WSX8ljmwXH4Bq89qSwiwjzq8niMfiokcIv)J0)RYVg3QgaNPa6mLo)scJvCi(geFpeRfIv)J0)RYFmEYb)bCy2y(LegR4qmBq89qSwiwjzq8ni(EiokcIvsgeFdIdlehfbXYmNJx(1bqVVYZGgId1joQ0(YjkJmkDptc0zkDorvmfcbYzBOK70lOlD6fmmDH7ePAKrOURnNOATKwBCIQxq(b8CnDeeRfIvsMxyIdXAgIvsgeFdfeZItCuP9LtmTgAbOhebNOkMcHa5SnuYD6f0Lo9cEhCH7ePAKrOURnNOATKwBCIkjZlmXHyndXkjdIVHcId6ehvAF5eNvnfbYFxQsx60liR0fUt0QK2LbD6ed6ePAKrOURnNOATKwBCITaIvFaQMk9fP2h53oehfbXYmNJh9Ac)2TbbG(tQsBq8mODIJkTVCIhKyw1a40IMQeOZu6CPtVG3PlCNivJmc1DT5evRL0AJtu9cYpGNRPJGyTqS6FK(Fv(JXto4pGdZgZVKWyfhIzdIVhI1cXkjdIrbXSaXAHy0lfa0O6(G(0AOfGEqeGyTqmv02eZNMabYhew9Hy2G4GoXrL2xorzKrP7zsGotPZjQIPqiqoBdLCNEbDPtpw03fUtKQrgH6U2CIQ1sATXjQEb5hWZ10rqSwiMkABI5ttGa5deM4qmBqmlqSwioeiwjzEHjoeRziwjzqmBOG4GqCueeJEPaGgv3h0NwdTa0dIaehQtCuP9Ltugzu6EMeOZu6CIQykecKZ2qj3Pxqx6sNOQd40XfUtVGUWDIunYiu31MtuTwsRnoXwaXbM1gzeYl9iDqCgQGyTqCiqS6FK(Fv(14w1a4mfqNP05xsySIdXSbXSaXrrqClGy1hGQPsVUyRnfehkeRfIdbIBbeR(aunv6lsTpYVDiokcIv)J0)RYl)f1z4jqEPl)scJvCiMniMfiouiokcIpwJucwsySIdXSbXSewN4Os7lNOvbEDeiodvU0PhlUWDIunYiu31MtuTwsRnoXCqOk9wf41rG4mu5PAKrOoeRfIdbIpwJucwsySIdX3G4qG4GSs9HyndXltrNFBi)zYbbKpJsYt1iJqDiomcXbzrFiouiokcILzohpp)vaqZMsGP6GJTKV)xfeRfIrtPpodvGuIaxswsG0AO1pQ0cqqSwioeiUfqS6dq1uPVi1(i)2H4OiiwM5C8YFrDgEcKx6YZGgIdfIJIG4qGy1)i9)Q8wf41rG4mubsjcCjzjbsRHw)scJvCi(geFSgPeSKWyfhIdfI1cXYmNJx(lQZWtG8sxEg0qCueel)CoeRfIpwJucwsySIdXSbXb1hId1joQ0(YjMpJsc8hqNMuYLo9U3fUtKQrgH6U2CIQ1sATXj2cioheQsVvbEDeiodvEQgzeQdXAH4qG4J1iLGLegR4q8nioeioiRuFiwZq8Yu053gYFMCqa5ZOK8unYiuhIdJqCqw0hIdfIJIGyzMZXZZFfa0SPeyQo4yl57)vbXAH4qG4waXQpavtL(Iu7J8BhIJIGyzMZXl)f1z4jqEPlpdAiouiokcILFohI1cXhRrkbljmwXHy2G4G6dXH6ehvAF5eZNrjb(dOttk5sNEAIlCNivJmc1DT5evRL0AJtmeiEhRdOauL(P35ERG4BqSMewiokcI3X6akavPF6DUNbnehkeRfIv)J0)RYVg3QgaNPa6mLo)scJvCiMniMItkMKaPjqqSwiw9ps)VkVvbEDeiodvGuIaxswsG0AO1VKWyfhIVbXHaXSOpe3keZI(qCyeIxMIo)2qERc86OLd6eI1iLEQgzeQdXHcXrrqS8Z5qSwi(ynsjyjHXkoeZgeFFyDIJkTVCIx0G(lo4pGF706sNEH1fUtKQrgH6U2CIQ1sATXjQEb5hWZ10rqSwioeiEhRdOauL(P35ERG4BqCq9H4OiiEhRdOauL(P35Eg0qCOoXrL2xoXZqiwraE(cODPtVW0fUtKQrgH6U2CIQ1sATXjUJ1buaQs)07CVvq8ni(E9H4OiiEhRdOauL(P35Eg0oXrL2xoXZGGqf43oTU0P3DWfUtKQrgH6U2CIQ1sATXj2ciwM5C8YFrDgEcKx6YZGgI1cXHaXkjdIVHcIzbI1cXhRrkbljmwXH4BqCyQpeRfIdbIv)J0)RYZZFfa0SPeyQo4yl5vsZ2qCi(geRpehfbXQ)r6)v555VcaA2ucmvhCSL8ljmwXH4BqCq9H4qHyTqCiqmAk9XzOcKse4sYscKwdT(rLwacIJIGy1)i9)Q8wf41rG4mubsjcCjzjbsRHw)scJvCi(gehuFiokcIdmRnYiKx6r6G4mubXHcXrrqCiqSsYG4BOGywGyTq8XAKsWscJvCiMnuqCyQpeRfIdbIrtPpodvGuIaS6swsG0AO1pQ0cqqCueeR(hP)xL3QaVoceNHkqkrGljljqAn06xsySIdX3G4J1iLGLegR4qCOqSwioeiw9ps)Vkpp)vaqZMsGP6GJTKxjnBdXH4BqS(qCueeR(hP)xLNN)kaOztjWuDWXwYVKWyfhIVbXhRrkbljmwXH4OiiwM5C888xbanBkbMQdo2sEg0qCOqCOqCueel)CoeRfIpwJucwsySIdXSbXbdlehkehfbXYpNdXAH4J1iLGLegR4qmBqCq9HyTqm)zqKTQ7rOPdKJbO4JaAeYt1iJqDN4Os7lNO8xuNHNa5LUCPtpwPlCNivJmc1DT5evRL0AJtu9vNXsV6)TB1Kuh8NdvCla5PAKrOUtCuP9LtKN)kaOztjWuDWXwcCS4tsU0P3D6c3js1iJqDxBor1AjT24ev)J0)RYZZFfa0SPeyQo4yl5vsZ2qCigfeZcehfbXhRrkbljmwXHy2Gyw0hIJIG4qG4DSoGcqv6NEN7xsySIdX3G4GHfIJIG4qG4waXQpavtLEDXwBkiwle3ciw9bOAQ0xKAFKF7qCOqSwioeioeiEhRdOauL(P35ERG4BqS6FK(FvEE(RaGMnLat1bhBj)HbbbSKsA2gcKMabXrrqClG4DSoGcqv6NEN7P4gp5qCOqSwioeiw9ps)VkVvbEDeiodvGuIaxswsG0AO1VKWyfhIVbXQ)r6)v555VcaA2ucmvhCSL8hgeeWskPzBiqAceehfbXbM1gzeYl9iDqCgQG4qH4qHyTqS6FK(Fv(JXto4pGdZgZVKWyfhIzdfeFNqSwiwjzq8nuqmlqSwiw9ps)Vk)LKTiw1a6708fantPK8ljmwXHy2qbXbzbId1joQ0(YjYZFfa0SPeyQo4yl5sNEb13fUtKQrgH6U2CIQ1sATXjQ(aunv61fBTPGyTqCiqSmZ54VOb9xCWFa)2P1ZGgIJIG4qG4J1iLGLegR4qmBqS6FK(Fv(lAq)fh8hWVDA9ljmwXH4Oiiw9ps)Vk)fnO)Id(d43oT(LegR4q8niw9ps)Vkpp)vaqZMsGP6GJTK)WGGawsjnBdbstGG4qHyTqS6FK(Fv(JXto4pGdZgZVKWyfhIzdfeFNqSwiwjzq8nuqmlqSwiw9ps)Vk)LKTiw1a6708fantPK8ljmwXHy2qbXbzbId1joQ0(YjYZFfa0SPeyQo4yl5sNEbd6c3js1iJqDxBor1AjT24evFaQMk9fP2h53oeRfI7KmZ54L)I6m8eiV0fOtYmNJNbneRfIdbIrtPpodvGuIaxswsG0AO1pQ0cqqCueehywBKriV0J0bXzOcIJIGy1)i9)Q8wf41rG4mubsjcCjzjbsRHw)scJvCi(geR(hP)xLNN)kaOztjWuDWXwYFyqqalPKMTHaPjqqCueeR(hP)xL3QaVoceNHkqkrGljljqAn06xsySIdX3G471hId1joQ0(YjYZFfa0SPeyQo4yl5sNEbzXfUtKQrgH6U2CI1iqorw1Nmvdz7c6epTkghOgeeN4Os7lNiR6tMQHSDbDINwfJdudcItuTwsRnor0u6JZqfiLiWLKLeiTgA9JkTaeehfbXQ)r6)v5TkWRJaXzOcKse4sYscKwdT(LegR4q8niom1hI1cXhRrkbljmwXH4BqCqwP(qCueel)CoeRfIpwJucwsySIdXSbXSOVlD6f8Ex4orQgzeQ7AZjwJa5eTIRwMCKriqlXmvYia6uatroXrL2xorR4QLjhzec0smtLmcGofWuKtuTwsRnor0u6JZqfiLiWLKLeiTgA9JkTaeehfbXYpNdXAH4J1iLGLegR4qmBqml67sNEb1ex4orQgzeQ7AZjwJa5eV2jL45xKtCuP9Lt8ANuINFror1AjT24ertPpodvGuIaxswsG0AO1pQ0cqqCueel)CoeRfIpwJucwsySIdXSbXSOVlD6fmSUWDIunYiu31MtSgbYjYLM(F1Sdhni)KeCIJkTVCICPP)xn7WrdYpjbNOATKwBCIOP0hNHkqkrGljljqAn06hvAbiiokcILFohI1cXhRrkbljmwXHy2Gyw0hIJIG4waXltrNFBiVvbED0YbDcXAKspvJmc1DPtVGHPlCNivJmc1DT5eRrGCIFaAvsZ2qDWuMWaKNmPnMtCuP9Lt8dqRsA2gQdMYegG8KjTXCIQ1sATXjIMsFCgQaPebUKSKaP1qRFuPfGG4Oiiw9ps)VkVvbEDeiodvGuIaxswsG0AO1VKWyfhIVbX3P(qCueel)CoeRfIpwJucwsySIdXSbXSOVlD6f8o4c3js1iJqDxBor1AjT24ertPpodvGuIaxswsG0AO1pQ0cqqCueel)CoeRfIpwJucwsySIdXSbXbdRtCuP9LtSbz62K)YbYtVHCPtVGSsx4orQgzeQ7AZjwJa5etjcCSLNaU1yioXrL2xoXuIahB5jGBngItuTwsRnor0u6JZqfiLiWLKLeiTgA9ljmwXH4BqCWWcXrrqS6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXkoeFdIdt9HyTq8XAKsWscJvCi(geFV(6dXrrqS8Z5qSwi(ynsjyjHXkoeZgeZI(U0PxW70fUtKQrgH6U2CI1iqor1OKiWFaJQLySL6GCPHZSe3joQ0(YjQgLeb(dyuTeJTuhKlnCML4or1AjT24ehvAbiavKGrCiMniMfiwlelZCo(r1sm2sDW1uDpdAiokcIhvAbiavKGrCi(geheI1cXYmNJFuTeJTuhmXjpdAiokcILFohI1cXhRrkbljmwXHy2Gyw03Lo9yrFx4orQgzeQ7AZjwJa5e5Qz5G)ao7K0wdcGNRDiN4Os7lNixnlh8hWzNK2Aqa8CTd5evRL0AJtSfqSmZ545Qz5G)ao7K0wdcGNRDiGM4zqdXrrqS8Z5qSwi(ynsjyjHXkoeZgeFFyDPtpwc6c3js1iJqDxBor1AjT24eBbehywBKriFCgQaFby4eixR0rjehfbXQ)r6)v5TkWRJaXzOcKse4sYscKwdT(LegR4q8niMf9HyTqmAk9XzOcKse4sYscKwdT(LegR4qmBqml6dXrrqCGzTrgH8spsheNHkN4Os7lNidNawscCx60JfwCH7ePAKrOURnNOATKwBCI5Gqv6TkWRJaXzOYt1iJqDiwlehceFSgPeSKWyfhIVbX3P(qCueeJMsFCgQaPebUKSKaP1qRFuPfGG4OiioWS2iJqEPhPdIZqfehfbXYpNdXAH4J1iLGLegR4qmBqCWWeId1joQ0(YjMpJsc8hGUzfgx60JL7DH7ePAKrOURnNOATKwBCITaIZbHQ0BvGxhbIZqLNQrgH6qSwioei(ynsjyjHXkoeFdIdg27eIJIG4aZAJmc5LEKoiodvqCOoXrL2xoX8zusG)a0nRW4sNESOjUWDIunYiu31MtuTwsRnor1)i9)Q8wf41rG4mubsjcCjzjbsRHw)scJvCi(geFV(qCueehywBKriV0J0bXzOcIJIGy5NZHyTq8XAKsWscJvCiMniMf9DIJkTVCItPiEUdcqniiU0PhlH1fUtKQrgH6U2CIQ1sATXjQ(hP)xL3QaVoceNHkqkrGljljqAn06xsySIdX3G471hIJIG4aZAJmc5LEKoiodvqCueel)CoeRfIpwJucwsySIdXSbXSOVtCuP9Ltug5)o4WSXCPtpwctx4orQgzeQ7AZjQwlP1gNO6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXkoeFdIVxFiokcIdmRnYiKx6r6G4mubXrrqS8Z5qSwi(ynsjyjHXkoeZgehuFN4Os7lN4Xwsg5)UlD6XYDWfUtKQrgH6U2CIQ1sATXjQ(hP)xL3QaVoceNHkqkrGljljqAn06xsySIdX3G471hIJIG4aZAJmc5LEKoiodvqCueel)CoeRfIpwJucwsySIdXSbXbdRtCuP9LtuMwoT6SQXLo9yHv6c3js1iJqDxBor1AjT24eLzohpp)vaqZMsGP6GJTKV)xLtCuP9LtuEAa)bKRP0XDPtpwUtx4oXrL2xoreRrk5awftVrGQ0js1iJqDxBU0P3967c3js1iJqDxBor1AjT24eLzohpNwQSmMV)xfeRfILzohV8xuNHNa5LUaDsM5C89)QGyTqSmZ54L)I6m8eiV0LV)xfeRfIdbI5pdISvDpAgEYGqaAzqN2xEQgzeQdXrrqm)zqKTQ7d8itAieG)ibOk9unYiuhId1jAvs7YGob2XjYFgezR6(apYKgcb4psaQsNOvjTld6eyccu3MKCIbDIJkTVCIheIlP25KorRsAxg0jOb5LheNyqx6sNyNodds6c3Pxqx4oXrL2xoroAAwG0uDapxth5ePAKrOURnx60Jfx4orQgzeQ7AZj(ODICkDIJkTVCIbM1gzeYjgyqyiNO6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXkoeFdIpwJucwsySIdXrrq8XAKsWscJvCiwZqS6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXkoeZgehKf9HyTqCiqCiqCoiuLEoTuzzmpvJmc1HyTq8XAKsWscJvCi(geR(hP)xLNtlvwgZVKWyfhI1cXQ)r6)v550sLLX8ljmwXH4BqCq9H4qH4Oiioeiw9ps)Vkpp)vaqZMsGP6GJTK)WGGawsjnBdbstGGy2G4J1iLGLegR4qSwiw9ps)Vkpp)vaqZMsGP6GJTK)WGGawsjnBdbstGG4BqCWWcXHcXrrqCiqS6FK(FvEE(RaGMnLat1bhBjVsA2gIdXOGy9HyTqS6FK(FvEE(RaGMnLat1bhBj)scJvCiMni(ynsjyjHXkoehkehQtmWSGAeiNO0J0bXzOYLo9U3fUtKQrgH6U2CIQ1sATXjMdcvP3QaVoceNHkpvJmc1HyTqCiqCiqSmZ5450sLLX8mOH4OiiwM5C888xbanBkbMQdo2sEg0qCOqSwignL(4mubsjcCjzjbsRHw)OslabXrrqS8Z5qSwi(ynsjyjHXkoeZgkiom1hId1joQ0(YjI(t7lx60ttCH7ePAKrOURnNOATKwBCITaIZbHQ0BvGxhbIZqLNQrgH6qSwioeioeiwM5C8CAPYYyEg0qCueelZCoEE(RaGMnLat1bhBjpdAiouiwleFSgPeSKWyfhIzdfehM6dXH6ehvAF5er)P9LlD6fwx4orQgzeQ7AZjQwlP1gNOmZ5450sLLX8mODI8Cnv60lOtCuP9LtuniiGrL2xaeJNoreJNGAeiNiNwQSmMlD6fMUWDIunYiu31MtuTwsRnorzMZXFrd6V4G)a(TtRNbTtKNRPsNEbDIJkTVCIQbbbmQ0(cGy80jIy8euJa5eVOb9xCWFa)2P1Lo9UdUWDIunYiu31MtuTwsRnoX0eiiMniwtGyTqSsYGy2G4WcXAH4waXOP0hNHkqkrGljljqAn06hvAbiNipxtLo9c6ehvAF5evdccyuP9faX4PteX4jOgbYj(OPIwx60Jv6c3js1iJqDxBor1AjT24evsMxyIdXAgIvsgeFdfeFpeRfIdbIPI2My(0eiq(aHjoeZgeheIJIGyQOTjMpnbcKpqyIdXSbXAceRfIv)J0)RYFmEYb)bCy2y(LegR4qmBqCqFyH4Oiiw9ps)Vk)fnO)Id(d43oT(LegR4qmBqmlqCOqSwiUfqCNKzohV8xuNHNa5LUaDsM5C8mODIJkTVCIhJNG)asjcCjzjbsRHwNOkMcHa5SnuYD6f0Lo9Utx4orQgzeQ7AZjQwlP1gNOsY8ctCiwZqSsYG4BOG4GqSwioeiMkABI5ttGa5deM4qmBqCqiokcIv)J0)RYZPLklJ5xsySIdXSbXSaXrrqmv02eZNMabYhimXHy2GynbI1cXQ)r6)v5pgp5G)aomBm)scJvCiMnioOpSqCueeR(hP)xL)Ig0FXb)b8BNw)scJvCiMniMfiouiwle3ciwM5C8YFrDgEcKx6YZG2joQ0(YjsXrtiaPzfCPtVG67c3js1iJqDxBor1AjT24evVG8d45A6iiwleRKmVWehI1meRKmi(gkiMfiwlehcetfTnX8PjqG8bctCiMnioiehfbXQ)r6)v550sLLX8ljmwXHy2GywG4OiiMkABI5ttGa5deM4qmBqSMaXAHy1)i9)Q8hJNCWFahMnMFjHXkoeZgeh0hwiokcIv)J0)RYFrd6V4G)a(TtRFjHXkoeZgeZcehkeRfIBbe3jzMZXl)f1z4jqEPlqNKzohpdAN4Os7lNyAn0cqpicorvmfcbYzBOK70lOlD6fmOlCNivJmc1DT5evRL0AJtu9bOAQ0xwJucodbXAHy1)i9)Q8NHqSIa88fq7xsySIdX3GywcleRfIdbIvsMxyIdXAgIvsgeFdfeheI1cXJkTaeGksWioeJcIdcXAH4DSoGcqv6NEN7TcIVbXSOpehfbXkjZlmXHyndXkjdIVHcIzbI1cXJkTaeGksWioeFdfeZcehQtCuP9LtujzazMLNU0PxqwCH7ePAKrOURnNOATKwBCITaIZbHQ0ZPLklJ5PAKrOUtKNRPsNEbDIJkTVCIQbbbmQ0(cGy80jIy8euJa5evDaNoU0PxW7DH7ePAKrOURnNOATKwBCI5Gqv650sLLX8unYiu3jYZ1uPtVGoXrL2xor1GGagvAFbqmE6ermEcQrGCIQoGtlvwgZLo9cQjUWDIunYiu31MtuTwsRnoXrLwacqfjyehIzdIV3jYZ1uPtVGoXrL2xor1GGagvAFbqmE6ermEcQrGCI80Lo9cgwx4orQgzeQ7AZjQwlP1gN4OslabOIemIdX3qbX37e55AQ0PxqN4Os7lNOAqqaJkTVaigpDIigpb1iqoX5jx6sNi6LuVG8KUWD6f0fUtCuP9Ltu(ZeH6GdYeJ6xw1aYpUvorQgzeQ7AZLo9yXfUtKQrgH6U2CIpANiNsN4Os7lNyGzTrgHCIbgegYjsTeJHgn19wXvltoYieOLyMkzeaDkGPiiokcIPwIXqJM6(gKPBt(lhip9gcIJIGyQLym0OPU)ANuINFrqCueetTeJHgn19FaAvsZ2qDWuMWaKNmPngehfbXulXyOrtDpxA6)vZoC0G8tsaIJIGyQLym0OPUpLiWXwEc4wJHaXrrqm1smgA0u3RgLeb(dyuTeJTuhKlnCML4oXaZcQrGCIXzOc8fGHtGCTshLU0P39UWDIJkTVCIheIlP25KorQgzeQ7AZLo90ex4orQgzeQ7AZjQwlP1gNylGy1hGQPsFznsj4mKtCuP9LtujzazMLNU0PxyDH7ePAKrOURnNOATKwBCITaIZbHQ0tfTn2DSvnacXItRNQrgH6oXrL2xorLKbUMaKlDPtCEYfUtVGUWDIJkTVCIxs2IyvdOVtZxa0mLsYjs1iJqDxBU0PhlUWDIunYiu31MtuTwsRnorLK5fM4qSMHyLKbX3qbXSaXAHyQOTjMpnbcKpqyIdX3GywG4OiiwjzEHjoeRziwjzq8nuqSM4ehvAF5ePI2g7o2QgaHyXT1Lo9U3fUtKQrgH6U2CIQ1sATXjQEb5hWZ10rqSwioeiwM5C89Pue4paLKXQmpdAiokcI7KmZ54L)I6m8eiV0fOtYmNJNbnehQtCuP9LtKJ2QYQgGANIa6mLox60ttCH7ePAKrOURnNOATKwBCIurBtmFAceiFGWehIVbXuCsXKeinbcIJIGyLK5fM4qSMHyLKbXSHcId6ehvAF5epgp5G)aomBmx60lSUWDIunYiu31MtuTwsRnoXqG4CqOk9xs2IyvdOVtZxa0mLsYt1iJqDiwleR(hP)xLFnUvnaotb0zkD(oZoP9feFdIv)J0)RYFjzlIvnG(onFbqZukj)scJvCiUviwtG4qHyTqCiqS6FK(Fv(JXto4pGdZgZVKWyfhIVbX3dXrrqSsYG4BOG4WcXH6ehvAF5exJBvdGZuaDMsNtuftHqGC2gk5o9c6sNEHPlCNivJmc1DT5evRL0AJtuM5C8ldxYQgaRA6e4YQUV)xLtCuP9LtCz4sw1ayvtNaxw1DPtV7GlCNivJmc1DT5evRL0AJtujzEHjoeRziwjzq8nuqCqN4Os7lNifhnHaKMvWLo9yLUWDIunYiu31MtuTwsRnorLK5fM4qSMHyLKbX3qbX37ehvAF5epgpb)bKse4sYscKwdTorvmfcbYzBOK70lOlD6DNUWDIunYiu31MtuTwsRnorLK5fM4qSMHyLKbX3qbXS4ehvAF5evsgqMz5PlD6fuFx4orQgzeQ7AZjQwlP1gNOmZ54tjcqcOP9xoqnOhLL)655O0bX3G4G3jeRfIPI2My(0eiq(aHjoeFdIP4KIjjqAceeRzioieRfIv)J0)RYFmEYb)bCy2y(LegR4q8niMItkMKaPjqoXrL2xor1okDiw1ayvtNaiwJuww14sNEbd6c3js1iJqDxBor1AjT24evsMxyIdXAgIvsgeFdfeZceRfIdbIBbeNdcvPxYsG6fKFpvJmc1H4Oiiw9cYpGNRPJG4qDIJkTVCIP1qla9Gi4evXuieiNTHsUtVGU0PxqwCH7ePAKrOURnNOATKwBCIkjZlmXHyndXkjdIVHcId6ehvAF5eNvnfbYFxQsx60l49UWDIunYiu31MtuTwsRnor1li)aEUMocI1cXHaXQ)r6)v5L)I6m8eiV0LFjHXkoeFdIzbIJIG4waXQpavtL(Iu7J8BhIdfI1cXHaXkjdIVHcIdlehfbXQ)r6)v5pgp5G)aomBm)scJvCi(gehMqCueeR(hP)xL)y8Kd(d4WSX8ljmwXH4Bq89qSwiwjzq8nuq89qSwiMkABI5ttGa5dcR(qmBqCqiokcIPI2My(0eiq(aHjoeZgkioei(EiUvi(EiomcXQ)r6)v5pgp5G)aomBm)scJvCiMnioSqCOqCueelZCoEE(RaGMnLat1bhBjpdAiouN4Os7lNihTvLvna1ofb0zkDU0PxqnXfUtKQrgH6U2CIQ1sATXjQEb5hWZ10roXrL2xorLKbUMaKlD6fmSUWDIwL0UmOtNyqNivJmc1DT5ehvAF5epiXSQbWPfnvjqNP05evRL0AJtuM5C8YVoa69v((FvU0PxWW0fUtKQrgH6U2CIQ1sATXjQEb5hWZ10rqSwioeiwM5C8YVoa69vEg0qCueeNdcvPxYsG6fKFpvJmc1HyTqm6LcaAuDFqFAn0cqpicqSwiwjzqmkiMfiwleR(hP)xL)y8Kd(d4WSX8ljmwXHy2G47H4OiiwjzEHjoeRziwjzqmBOG4GqSwig9sbanQUpONJ2QYQgGANIa6mLoiwletfTnX8PjqG8bctCiMni(EiouN4Os7lNOmYO09mjqNP05evXuieiNTHsUtVGU0LU0jgGwU9Ltpw0Nfw0pS6h0jEnBzvd3jYQhgYQvVww9cdCxqmehUebXMa6Fti(8leZ6lAq)fh8hWVDAzneVulXyl1Hy(lqq8WKVWKuhIvst1qCpuJ72kcIdExqmR4Ra0MuhIzDoiuLEnL1qC(qmRZbHQ0RPEQgzeQZAiEsiULHvZDdXHemEOEOg3TveeZYDbXSIVcqBsDiM15Gqv61uwdX5dXSoheQsVM6PAKrOoRH4jH4wgwn3nehsW4H6HAC3wrqCW7VliMv8vaAtQdXSoheQsVMYAioFiM15Gqv61upvJmc1znehsW4H6HAa1GvpmKvRETS6fg4UGyioCjcInb0)Mq85xiM1CAPYYySgIxQLySL6qm)fiiEyYxysQdXkPPAiUhQXDBfbXb1)UGywXxbOnPoeZ6CqOk9AkRH48HywNdcvPxt9unYiuN1q8KqCldRM7gIdjy8q9qnGAWQhgYQvVww9cdCxqmehUebXMa6Fti(8leZAvhWPLklJXAiEPwIXwQdX8xGG4HjFHjPoeRKMQH4EOg3TveeFN3feZk(kaTj1HywVmfD(TH8AkRH48HywVmfD(TH8AQNQrgH6SgIdjy8q9qnUBRiioyW7cIzfFfG2K6qmRxMIo)2qEnL1qC(qmRxMIo)2qEn1t1iJqDwdXHemEOEOg3TveehKvExqmR4Ra0MuhIz9Yu053gYRPSgIZhIz9Yu053gYRPEQgzeQZAiEsiULHvZDdXHemEOEOg3TveeZYD4UGywXxbOnPoeZA(ZGiBv3RPSgIZhIzn)zqKTQ71upvJmc1znehclXd1d1aQbREyiRw9Az1lmWDbXqC4seeBcO)nH4ZVqmR5jRH4LAjgBPoeZFbcIhM8fMK6qSsAQgI7HAC3wrqSMCxqmR4Ra0MuhIzn)zqKTQ71uwdX5dXSM)miYw19AQNQrgH6SgIdjy8q9qnUBRiioS3feZk(kaTj1HywNdcvPxtzneNpeZ6CqOk9AQNQrgH6SgIdjy8q9qnUBRii(oCxqmR4Ra0MuhIzDoiuLEnL1qC(qmRZbHQ0RPEQgzeQZAioKGXd1d14UTIG4GH9UGywXxbOnPoeZ6CqOk9AkRH48HywNdcvPxt9unYiuN1qCibJhQhQbudw9WqwT61YQxyG7cIH4WLii2eq)BcXNFHywR6aoDyneVulXyl1Hy(lqq8WKVWKuhIvst1qCpuJ72kcIz5UGywXxbOnPoeZ6LPOZVnKxtzneNpeZ6LPOZVnKxt9unYiuN1qCibJhQhQXDBfbX3FxqmR4Ra0MuhIz9Yu053gYRPSgIZhIz9Yu053gYRPEQgzeQZAioKGXd1d14UTIGyn5UGywXxbOnPoeZ6LPOZVnKxtzneNpeZ6LPOZVnKxt9unYiuN1qCibJhQhQXDBfbX3H7cIzfFfG2K6qmR5pdISvDVMYAioFiM18Nbr2QUxt9unYiuN1q8KqCldRM7gIdjy8q9qnUBRiioyyVliMv8vaAtQdXSEzk68Bd51uwdX5dXSEzk68Bd51upvJmc1znepje3YWQ5UH4qcgpupuJ72kcIVx)7cIzfFfG2K6qmR5pdISvDVMYAioFiM18Nbr2QUxt9unYiuN1qCiSepupudOgS6HHSA1RLvVWa3fedXHlrqSjG(3eIp)cXSUtNHbjzneVulXyl1Hy(lqq8WKVWKuhIvst1qCpuJ72kcIz5UGywXxbOnPoeZ6CqOk9AkRH48HywNdcvPxt9unYiuN1qCibJhQhQXDBfbXbz5UGywXxbOnPoeZ6CqOk9AkRH48HywNdcvPxt9unYiuN1q8KqCldRM7gIdjy8q9qnUBRiio493feZk(kaTj1HywNdcvPxtzneNpeZ6CqOk9AQNQrgH6SgINeIBzy1C3qCibJhQhQbudw9WqwT61YQxyG7cIH4WLii2eq)BcXNFHywppXAiEPwIXwQdX8xGG4HjFHjPoeRKMQH4EOg3Tveeh27cIzfFfG2K6qmRZbHQ0RPSgIZhIzDoiuLEn1t1iJqDwdXHemEOEOg3Tveehm4DbXSIVcqBsDiM15Gqv61uwdX5dXSoheQsVM6PAKrOoRH4qcgpupuJ72kcIdgM3feZk(kaTj1HywNdcvPxtzneNpeZ6CqOk9AQNQrgH6SgIdjy8q9qnGA0YkG(3K6q8DcXJkTVGyeJNCpudNi69pgc5eB5TCiMv3Q(1GOJwi(o6x6GA0YB5q8D0jgehutyhIzrFwybQbuJwElhIzfsZ2q87cQrlVLdXAgId)IgDqCyqJNCi(pqCyqMngeBvs7YGoHyKVXuEOgT8woeRzio8lA0bXIOTQSQbIzf7ueeFhPP0bXiFJP8qnA5TCiwZqCyyVdXYpNFSgPeIvsKshhIZhIfMkgeZkUJaIPkxJ4EOgT8woeRziomS3HyR0S6fKNeIddIqCj1oN0d1aQrlVLdXTmXjftsDiwMo)sqS6fKNeILPgR4EiomuPi0jhIRV0S0SchgeiEuP9fhI)cjMhQXOs7lUh9sQxqEYwr1U8Njc1bhKjg1VSQbKFCRGAmQ0(I7rVK6fKNSvuThywBKri2RrGqfNHkWxagobY1kDuY(JgfNs2dmimekQLym0OPU3kUAzYrgHaTeZujJaOtbmfffrTeJHgn19nit3M8xoqE6nuue1smgA0u3FTtkXZVOOiQLym0OPU)dqRsA2gQdMYegG8KjTXIIOwIXqJM6EU00)RMD4Ob5NKque1smgA0u3Nse4ylpbCRXqIIOwIXqJM6E1OKiWFaJQLySL6GCPHZSehQXOs7lUh9sQxqEYwr1(bH4sQDojuJrL2xCp6LuVG8KTIQDLKbKzwEYUDq1c1hGQPsFznsj4meuJrL2xCp6LuVG8KTIQDLKbUMae72bvlYbHQ0tfTn2DSvnacXItRNQrgH6qnGA0YB5qCltCsXKuhIPa0gdIttGG4uIG4rL)cXghINaJHmYiKhQXOs7lokoAAwG0uDapxthb1yuP9fVvuThywBKri2RrGqj9iDqCgQy)rJItj7bgegcL6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXk(TJ1iLGLegR4rrhRrkbljmwX1S6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXkoBbzrFTHesoiuLEoTuzzmThRrkbljmwXVP(hP)xLNtlvwgZVKWyfxR6FK(FvEoTuzzm)scJv8Bb1p0OOqu)J0)RYZZFfa0SPeyQo4yl5pmiiGLusZ2qG0ei2owJucwsySIRv9ps)Vkpp)vaqZMsGP6GJTK)WGGawsjnBdbstGUfmSHgffI6FK(FvEE(RaGMnLat1bhBjVsA2gIJsFTQ)r6)v555VcaA2ucmvhCSL8ljmwXz7ynsjyjHXkEOHc1yuP9fVvuTJ(t7l2TdQCqOk9wf41rG4mu5PAKrOU2qcrM5C8CAPYYyEg0rrYmNJNN)kaOztjWuDWXwYZGouTOP0hNHkqkrGljljqAn06hvAbOOi5NZ1ESgPeSKWyfNnuHP(Hc1yuP9fVvuTJ(t7l2TdQwKdcvP3QaVoceNHkpvJmc11gsiYmNJNtlvwgZZGoksM5C888xbanBkbMQdo2sEg0HQ9ynsjyjHXkoBOct9dfQXOs7lEROAxniiGrL2xaeJNSxJaHItlvwgJDEUMkrfKD7GsM5C8CAPYYyEg0qngvAFXBfv7QbbbmQ0(cGy8K9Aeiux0G(lo4pGF70YopxtLOcYUDqjZCo(lAq)fh8hWVDA9mOHAmQ0(I3kQ2vdccyuP9faX4j71iqOE0url78CnvIki72bvAceBAIwLKXwy12c0u6JZqfiLiWLKLeiTgA9JkTaeuJrL2x8wr1(X4j4pGuIaxswsG0AOLDvmfcbYzBOKJki72bLsY8ctCnRKSBOUxBiurBtmFAceiFGWeNTGrrurBtmFAceiFGWeNnnrR6FK(Fv(JXto4pGdZgZVKWyfNTG(WgfP(hP)xL)Ig0FXb)b8BNw)scJvC2yjuTTOtYmNJx(lQZWtG8sxGojZCoEg0qngvAFXBfv7uC0ecqAwb2TdkLK5fM4Awjz3qfuBiurBtmFAceiFGWeNTGrrQ)r6)v550sLLX8ljmwXzJLOiQOTjMpnbcKpqyIZMMOv9ps)Vk)X4jh8hWHzJ5xsySIZwqFyJIu)J0)RYFrd6V4G)a(TtRFjHXkoBSeQ2wiZCoE5VOodpbYlD5zqd1yuP9fVvuTNwdTa0dIa7QykecKZ2qjhvq2Tdk1li)aEUMosRsY8ctCnRKSBOyrBiurBtmFAceiFGWeNTGrrQ)r6)v550sLLX8ljmwXzJLOiQOTjMpnbcKpqyIZMMOv9ps)Vk)X4jh8hWHzJ5xsySIZwqFyJIu)J0)RYFrd6V4G)a(TtRFjHXkoBSeQ2w0jzMZXl)f1z4jqEPlqNKzohpdAOgJkTV4TIQDLKbKzwEYUDqP(aunv6lRrkbNH0Q(hP)xL)meIveGNVaA)scJv8BSewTHOKmVWexZkj7gQGAhvAbiavKGrCub1UJ1buaQs)07CVv3yr)OiLK5fM4Awjz3qXI2rLwacqfjye)gkwcfQXOs7lEROAxniiGrL2xaeJNSxJaHs1bC6WopxtLOcYUDq1ICqOk9CAPYYyqngvAFXBfv7QbbbmQ0(cGy8K9AeiuQoGtlvwgJDEUMkrfKD7GkheQspNwQSmguJrL2x8wr1UAqqaJkTVaigpzVgbcfpzNNRPsubz3oOgvAbiavKGrC2UhQXOs7lEROAxniiGrL2xaeJNSxJaHAEIDEUMkrfKD7GAuPfGaurcgXVH6EOgqngvAFX9ZtOUKSfXQgqFNMVaOzkLeuJrL2xC)8uROANkABS7yRAaeIf3w2TdkLK5fM4Awjz3qXIwQOTjMpnbcKpqyIFJLOiLK5fM4Awjz3qPjqngvAFX9ZtTIQDoARkRAaQDkcOZu6y3oOuVG8d45A6iTHiZCo((ukc8hGsYyvMNbDuuNKzohV8xuNHNa5LUaDsM5C8mOdfQXOs7lUFEQvuTFmEYb)bCy2ySBhuurBtmFAceiFGWe)gfNumjbstGIIusMxyIRzLKXgQGqngvAFX9ZtTIQ914w1a4mfqNP0XUkMcHa5SnuYrfKD7GkKCqOk9xs2IyvdOVtZxa0mLssR6FK(Fv(14w1a4mfqNP057m7K2x3u)J0)RYFjzlIvnG(onFbqZukj)scJv8w1Kq1gI6FK(Fv(JXto4pGdZgZVKWyf)29rrkj7gQWgkuJrL2xC)8uROAFz4sw1ayvtNaxw1z3oOKzoh)YWLSQbWQMobUSQ77)vb1yuP9f3pp1kQ2P4OjeG0ScSBhukjZlmX1SsYUHkiuJrL2xC)8uROA)y8e8hqkrGljljqAn0YUkMcHa5SnuYrfKD7GsjzEHjUMvs2nu3d1yuP9f3pp1kQ2vsgqMz5j72bLsY8ctCnRKSBOybQXOs7lUFEQvuTR2rPdXQgaRA6eaXAKYYQg2TdkzMZXNseGeqt7VCGAqpkl)1ZZrP7wW7ulv02eZNMabYhimXVrXjftsG0einhuR6FK(Fv(JXto4pGdZgZVKWyf)gfNumjbstGGAmQ0(I7NNAfv7P1qla9GiWUkMcHa5SnuYrfKD7GsjzEHjUMvs2nuSOnKwKdcvPxYsG6fK)Oi1li)aEUMokuOgJkTV4(5Pwr1(SQPiq(7svYUDqPKmVWexZkj7gQGqngvAFX9ZtTIQDoARkRAaQDkcOZu6y3oOuVG8d45A6iTHO(hP)xLx(lQZWtG8sx(LegR43yjkQfQpavtL(Iu7J8BpuTHOKSBOcBuK6FK(Fv(JXto4pGdZgZVKWyf)wygfP(hP)xL)y8Kd(d4WSX8ljmwXVDVwLKDd19API2My(0eiq(GWQpBbJIOI2My(0eiq(aHjoBOc5(wVpmQ(hP)xL)y8Kd(d4WSX8ljmwXzlSHgfjZCoEE(RaGMnLat1bhBjpd6qHAmQ0(I7NNAfv7kjdCnbi2Tdk1li)aEUMocQXOs7lUFEQvuTFqIzvdGtlAQsGotPJD7GsM5C8YVoa69v((FvSBvs7YGorfeQXOs7lUFEQvuTlJmkDptc0zkDSRIPqiqoBdLCubz3oOuVG8d45A6iTHiZCoE5xha9(kpd6OOCqOk9swcuVG8Rf9sbanQUpOpTgAbOhebTkjdflAv)J0)RYFmEYb)bCy2y(LegR4SDFuKsY8ctCnRKm2qful6LcaAuDFqphTvLvna1ofb0zkDAPI2My(0eiq(aHjoB3hkudOgJkTV4EvhWPdkRc86iqCgQaPebUKSKaP1ql72bvlcmRnYiKx6r6G4muPne1)i9)Q8RXTQbWzkGotPZVKWyfNnwIIAH6dq1uPxxS1MkuTH0c1hGQPsFrQ9r(ThfP(hP)xLx(lQZWtG8sx(LegR4SXsOrrhRrkbljmwXzJLWc1yuP9f3R6aoDAfv75ZOKa)b0PjLy3oOYbHQ0BvGxhbIZqLNQrgH6Ad5ynsjyjHXk(TqcYk1xZltrNFBi)zYbbKpJskmgKf9dnksM5C888xbanBkbMQdo2s((FvArtPpodvGuIaxswsG0AO1pQ0cqAdPfQpavtL(Iu7J8BpksM5C8YFrDgEcKx6YZGo0OOqu)J0)RYBvGxhbIZqfiLiWLKLeiTgA9ljmwXVDSgPeSKWyfpuTYmNJx(lQZWtG8sxEg0rrYpNR9ynsjyjHXkoBb1puOgJkTV4EvhWPtROApFgLe4pGonPe72bvlYbHQ0BvGxhbIZqLNQrgH6Ad5ynsjyjHXk(TqcYk1xZltrNFBi)zYbbKpJskmgKf9dnksM5C888xbanBkbMQdo2s((FvAdPfQpavtL(Iu7J8BpksM5C8YFrDgEcKx6YZGo0Oi5NZ1ESgPeSKWyfNTG6hkuJrL2xCVQd40PvuTFrd6V4G)a(Ttl72bvi7yDafGQ0p9o3B1nnjSrr7yDafGQ0p9o3ZGouTQ)r6)v5xJBvdGZuaDMsNFjHXkoBuCsXKeinbsR6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXk(Tqyr)wzr)W4Yu053gYBvGxhTCqNqSgPm0Oi5NZ1ESgPeSKWyfNT7dluJrL2xCVQd40PvuTFgcXkcWZxan72bL6fKFapxthPnKDSoGcqv6NEN7T6wq9JI2X6akavPF6DUNbDOqngvAFX9QoGtNwr1(zqqOc8BNw2TdQDSoGcqv6NEN7T6296hfTJ1buaQs)07CpdAOgJkTV4EvhWPtROAx(lQZWtG8sxSBhuTqM5C8YFrDgEcKx6YZGwBikj7gkw0ESgPeSKWyf)wyQV2qu)J0)RYZZFfa0SPeyQo4yl5vsZ2q8B6hfP(hP)xLNN)kaOztjWuDWXwYVKWyf)wq9dvBiOP0hNHkqkrGljljqAn06hvAbOOi1)i9)Q8wf41rG4mubsjcCjzjbsRHw)scJv8Bb1pkkWS2iJqEPhPdIZqvOrrHOKSBOyr7XAKsWscJvC2qfM6Rne0u6JZqfiLiaRUKLeiTgA9JkTauuK6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXk(TJ1iLGLegR4HQne1)i9)Q888xbanBkbMQdo2sEL0Sne)M(rrQ)r6)v555VcaA2ucmvhCSL8ljmwXVDSgPeSKWyfpksM5C888xbanBkbMQdo2sEg0HgAuK8Z5ApwJucwsySIZwWWgAuK8Z5ApwJucwsySIZwq91YFgezR6EeA6a5yak(iGgHGAmQ0(I7vDaNoTIQDE(RaGMnLat1bhBjWXIpjXUDqP(QZyPx9)2TAsQd(ZHkUfG8unYiuhQXOs7lUx1bC60kQ255VcaA2ucmvhCSLy3oOu)J0)RYZZFfa0SPeyQo4yl5vsZ2qCuSefDSgPeSKWyfNnw0pkkKDSoGcqv6NEN7xsySIFlyyJIcPfQpavtLEDXwBkTTq9bOAQ0xKAFKF7HQnKq2X6akavPF6DU3QBQ)r6)v555VcaA2ucmvhCSL8hgeeWskPzBiqAcuuul2X6akavPF6DUNIB8KhQ2qu)J0)RYBvGxhbIZqfiLiWLKLeiTgA9ljmwXVP(hP)xLNN)kaOztjWuDWXwYFyqqalPKMTHaPjqrrbM1gzeYl9iDqCgQcnuTQ)r6)v5pgp5G)aomBm)scJvC2qDNAvs2nuSOv9ps)Vk)LKTiw1a6708fantPK8ljmwXzdvqwcfQXOs7lUx1bC60kQ255VcaA2ucmvhCSLy3oOuFaQMk96IT2uAdrM5C8x0G(lo4pGF706zqhffYXAKsWscJvC2u)J0)RYFrd6V4G)a(TtRFjHXkEuK6FK(Fv(lAq)fh8hWVDA9ljmwXVP(hP)xLNN)kaOztjWuDWXwYFyqqalPKMTHaPjqHQv9ps)Vk)X4jh8hWHzJ5xsySIZgQ7uRsYUHIfTQ)r6)v5VKSfXQgqFNMVaOzkLKFjHXkoBOcYsOqngvAFX9QoGtNwr1op)vaqZMsGP6GJTe72bL6dq1uPVi1(i)212jzMZXl)f1z4jqEPlqNKzohpdATHGMsFCgQaPebUKSKaP1qRFuPfGIIcmRnYiKx6r6G4muffP(hP)xL3QaVoceNHkqkrGljljqAn06xsySIFt9ps)Vkpp)vaqZMsGP6GJTK)WGGawsjnBdbstGIIu)J0)RYBvGxhbIZqfiLiWLKLeiTgA9ljmwXVDV(Hc1yuP9f3R6aoDAfv7mCcyjjWEncekw1Nmvdz7c6epTkghOgee2Tdk0u6JZqfiLiWLKLeiTgA9JkTauuK6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXk(TWuFThRrkbljmwXVfKvQFuK8Z5ApwJucwsySIZgl6d1yuP9f3R6aoDAfv7mCcyjjWEncekR4QLjhzec0smtLmcGofWue72bfAk9XzOcKse4sYscKwdT(rLwakks(5CThRrkbljmwXzJf9HAmQ0(I7vDaNoTIQDgobSKeyVgbc11oPep)Iy3oOqtPpodvGuIaxswsG0AO1pQ0cqrrYpNR9ynsjyjHXkoBSOpuJrL2xCVQd40PvuTZWjGLKa71iqO4st)VA2HJgKFscSBhuOP0hNHkqkrGljljqAn06hvAbOOi5NZ1ESgPeSKWyfNnw0pkQfltrNFBiVvbED0YbDcXAKsOgJkTV4EvhWPtROANHtaljb2RrGq9bOvjnBd1btzcdqEYK2ySBhuOP0hNHkqkrGljljqAn06hvAbOOi1)i9)Q8wf41rG4mubsjcCjzjbsRHw)scJv8B3P(rrYpNR9ynsjyjHXkoBSOpuJrL2xCVQd40PvuT3GmDBYF5a5P3qSBhuOP0hNHkqkrGljljqAn06hvAbOOi5NZ1ESgPeSKWyfNTGHfQXOs7lUx1bC60kQ2z4eWssG9AeiuPebo2Yta3Ame2Tdk0u6JZqfiLiWLKLeiTgA9ljmwXVfmSrrQ)r6)v5TkWRJaXzOcKse4sYscKwdT(LegR43ct91ESgPeSKWyf)296RFuK8Z5ApwJucwsySIZgl6d1yuP9f3R6aoDAfv7mCcyjjWEncek1OKiWFaJQLySL6GCPHZSeND7GAuPfGaurcgXzJfTYmNJFuTeJTuhCnv3ZGokAuPfGaurcgXVfuRmZ54hvlXyl1btCYZGoks(5CThRrkbljmwXzJf9HAmQ0(I7vDaNoTIQDgobSKeyVgbcfxnlh8hWzNK2Aqa8CTdXUDq1czMZXZvZYb)bC2jPTgeapx7qanXZGoks(5CThRrkbljmwXz7(Wc1yuP9f3R6aoDAfv7mCcyjjWz3oOArGzTrgH8XzOc8fGHtGCTshLrrQ)r6)v5TkWRJaXzOcKse4sYscKwdT(LegR43yrFTOP0hNHkqkrGljljqAn06xsySIZgl6hffywBKriV0J0bXzOcQXOs7lUx1bC60kQ2ZNrjb(dq3Scd72bvoiuLERc86iqCgQ8unYiuxBihRrkbljmwXVDN6hfHMsFCgQaPebUKSKaP1qRFuPfGIIcmRnYiKx6r6G4muffj)CU2J1iLGLegR4SfmmdfQXOs7lUx1bC60kQ2ZNrjb(dq3Scd72bvlYbHQ0BvGxhbIZqLNQrgH6Ad5ynsjyjHXk(TGH9oJIcmRnYiKx6r6G4mufkuJrL2xCVQd40PvuTpLI45oia1GGWUDqP(hP)xL3QaVoceNHkqkrGljljqAn06xsySIF7E9JIcmRnYiKx6r6G4muffj)CU2J1iLGLegR4SXI(qngvAFX9QoGtNwr1UmY)DWHzJXUDqP(hP)xL3QaVoceNHkqkrGljljqAn06xsySIF7E9JIcmRnYiKx6r6G4muffj)CU2J1iLGLegR4SXI(qngvAFX9QoGtNwr1(Xwsg5)o72bL6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXk(T71pkkWS2iJqEPhPdIZqvuK8Z5ApwJucwsySIZwq9HAmQ0(I7vDaNoTIQDzA50QZQg2Tdk1)i9)Q8wf41rG4mubsjcCjzjbsRHw)scJv8B3RFuuGzTrgH8spsheNHQOi5NZ1ESgPeSKWyfNTGHfQXOs7lUx1bC60kQ2LNgWFa5AkDC2TdkzMZXZZFfa0SPeyQo4yl57)vb1yuP9f3R6aoDAfv7iwJuYbSkMEJavjuJrL2xCVQd40PvuTFqiUKANtYUDqjZCoEoTuzzmF)VkTYmNJx(lQZWtG8sxGojZCo((FvALzohV8xuNHNa5LU89)Q0gc)zqKTQ7rZWtgecqld60(kkI)miYw19bEKjnecWFKauLHYUvjTld6eyccu3MKqfKDRsAxg0jOb5Lheubz3QK2LbDcSdk(ZGiBv3h4rM0qia)rcqvc1aQXOs7lUx1bCAPYYyOcmRnYie71iqO40sLLXaYmlpz)rJItPDyx9v3s7lu5Gqv6TkWRJaXzOYt1iJqD2dmimek1)i9)Q8CAPYYy(LegR4SfmkcnL(4mubsjcCjzjbsRHw)OslaPv9ps)VkpNwQSmMFjHXk(T71pks(5CThRrkbljmwXzJf9zpWGWqacHtOu)J0)RYZPLklJ5xsySIZwWOi1)i9)Q8CAPYYy(LegR43Ux)Oi5NZ1ESgPeSKWyfNnw0hQXOs7lUx1bCAPYYyTIQDRc86iqCgQaPebUKSKaP1ql72bvlcmRnYiKx6r6G4muffj)CU2J1iLGLegR4SXsyHAmQ0(I7vDaNwQSmwROAFkfXZDqaQbbHD7GkWS2iJqEoTuzzmGmZYtOgJkTV4EvhWPLklJ1kQ2Lr(VdomBm2TdQaZAJmc550sLLXaYmlpHAmQ0(I7vDaNwQSmwROA)yljJ8FND7GkWS2iJqEoTuzzmGmZYtOgJkTV4EvhWPLklJ1kQ2LPLtRoRAy3oOcmRnYiKNtlvwgdiZS8eQXOs7lUx1bCAPYYyTIQD5Pb8hqUMshND7GkWS2iJqEoTuzzmGmZYtOgJkTV4EvhWPLklJ1kQ2NvnfbYFxQsOgJkTV4EvhWPLklJ1kQ2ZNrjb(dOttkXUDqLdcvP3QaVoceNHkpvJmc11gYXAKsWscJv8BHeKvQVMxMIo)2q(ZKdciFgLuymil6hAueAk9XzOcKse4sYscKwdT(rLwasBiTq9bOAQ0xKAFKF7rrYmNJx(lQZWtG8sxEg0HgffI6FK(FvERc86iqCgQaPebUKSKaP1qRFjHXk(TJ1iLGLegR4HQvM5C8YFrDgEcKx6YZGoks(5CThRrkbljmwXzlO(Hc1yuP9f3R6aoTuzzSwr1E(mkjWFa6Mvyy3oOYbHQ0BvGxhbIZqLNQrgH6Ad5ynsjyjHXk(T7u)Oi0u6JZqfiLiWLKLeiTgA9JkTauuK8Z5ApwJucwsySIZwq9dfQXOs7lUx1bCAPYYyTIQ98zusG)a60KsSBhuTiheQsVvbEDeiodvEQgzeQRnKJ1iLGLegR43cjiRuFnVmfD(TH8Njheq(mkPWyqw0p0OizMZXl)f1z4jqEPlpd6Oi5NZ1ESgPeSKWyfNTG6hkuJrL2xCVQd40sLLXAfv75ZOKa)bOBwHHD7GQf5Gqv6TkWRJaXzOYt1iJqDTHCSgPeSKWyf)2DQFuK8Z5ApwJucwsySIZwWWmuOgJkTV4EvhWPLklJ1kQ2VOb9xCWFa)2PLD7Gs9ps)Vk)ACRAaCMcOZu68ljmwXzJItkMKaPjqqngvAFX9QoGtlvwgRvuTZWjGLKa71iqOyvFYunKTlOt80QyCGAqqy3oOcmRnYiKNtlvwgdiZS8mks(5CThRrkbljmwXzJf9HAmQ0(I7vDaNwQSmwROANHtaljb2RrGqzfxTm5iJqGwIzQKra0PaMIy3oOcmRnYiKNtlvwgdiZS8mks(5CThRrkbljmwXzJf9HAmQ0(I7vDaNwQSmwROANHtaljb2RrGqDTtkXZVi2TdQaZAJmc550sLLXaYmlpJIKFox7XAKsWscJvC2yrFOgJkTV4EvhWPLklJ1kQ2z4eWssG9AeiuFaAvsZ2qDWuMWaKNmPng72bvGzTrgH8CAPYYyazMLNrrYpNR9ynsjyjHXkoBSOpuJrL2xCVQd40sLLXAfv7mCcyjjWEncekU00)RMD4Ob5NKa72bfAk9XzOcKse4sYscKwdT(rLwakks(5CThRrkbljmwXzJf9JIAXYu053gYBvGxhTCqNqSgPeQXOs7lUx1bCAPYYyTIQ9gKPBt(lhip9gID7GkWS2iJqEoTuzzmGmZYtOgJkTV4EvhWPLklJ1kQ2z4eWssG9AeiuPebo2Yta3Ame2TdQaZAJmc550sLLXaYmlpJIKFox7XAKsWscJvC2yrFOgJkTV4EvhWPLklJ1kQ2z4eWssGZUDq1IaZAJmc5JZqf4ladNa5ALokJIu)J0)RYBvGxhbIZqfiLiWLKLeiTgA9ljmwXVXI(rrbM1gzeYl9iDqCgQGAmQ0(I7vDaNwQSmwROA)meIveGNVaAOgJkTV4EvhWPLklJ1kQ2pdccvGF70c1yuP9f3R6aoTuzzSwr1U8xuNHNa5LUy3oOKFox7XAKsWscJvC2cg2OOqus2nuSOnKJ1iLGLegR43ct91gsiQ)r6)v550sLLX8ljmwXVfu)OizMZXZPLklJ5zqhfP(hP)xLNtlvwgZZGouTHGMsFCgQaPebUKSKaP1qRFuPfGIIu)J0)RYBvGxhbIZqfiLiWLKLeiTgA9ljmwXVfu)OOaZAJmc5LEKoiodvHgAOrrHCSgPeSKWyfNnuHP(AdbnL(4mubsjcWQlzjbsRHw)OslaffP(hP)xL3QaVoceNHkqkrGljljqAn06xsySIF7ynsjyjHXkEOHgkuJrL2xCVQd40sLLXAfv7CAPYYySBhuQ)r6)v5xJBvdGZuaDMsNFjHXkoBSefj)CU2J1iLGLegR4SfmSqngvAFX9QoGtlvwgRvuTlpnG)aY1u64qngvAFX9QoGtlvwgRvuTFqiUKANtYUDqjZCoEoTuzzmF)VkTYmNJx(lQZWtG8sxGojZCo((FvALzohV8xuNHNa5LU89)Q0gc)zqKTQ7rZWtgecqld60(kkI)miYw19bEKjnecWFKauLHYUvjTld6eyccu3MKqfKDRsAxg0jOb5Lheubz3QK2LbDcSdk(ZGiBv3h4rM0qia)rcqvc1aQXOs7lU)rtfTOogpb)bKse4sYscKwdTSRIPqiqoBdLCubz3oOusMxyIRzLKDd19qngvAFX9pAQOTvuTtXrtiaPzfy3oOYbHQ0RKmGmZYtpvJmc11QKmVWexZkj7gQ7HAmQ0(I7F0urBROApTgAbOheb2vXuieiNTHsoQGSBhuQxq(b8CnDKwLK5fM4Awjz3qXcuJrL2xC)JMkABfv7kjdCnbi2TdkLK5fM4AwjzOybQXOs7lU)rtfTTIQDkoAcbinRauJrL2xC)JMkABfv7P1qla9GiWUkMcHa5SnuYrfKD7GsjzEHjUMvs2nuSa1aQXOs7lUNtlvwgd1X4jh8hWHzJXUDqjZCoEoTuzzm)scJvC2cc1yuP9f3ZPLklJ1kQ25OTQSQbO2PiGotPJD7Gs9cYpGNRPJ0gYOslabOIemIFd19rrJkTaeGksWi(TGABH6FK(Fv(14w1a4mfqNP05zqhkuJrL2xCpNwQSmwROAFnUvnaotb0zkDSRIPqiqoBdLCubz3oOuVG8d45A6iOgJkTV4EoTuzzSwr1(X4jh8hWHzJXUDqnQ0cqaQibJ43qDpuJrL2xCpNwQSmwROANJ2QYQgGANIa6mLo2Tdk1li)aEUMosRmZ547tPiWFakjJvzEg0qngvAFX9CAPYYyTIQDzKrP7zsGotPJDvmfcbYzBOKJki72bL6fKFapxthPvM5C8x0G(lo4pGF706zqRv9ps)Vk)ACRAaCMcOZu68ljmwXVXcuJrL2xCpNwQSmwROA)y8Kd(d4WSXy3QK2LbDcSdQwO(hP)xLFnUvnaotb0zkDEg0qngvAFX9CAPYYyTIQDoARkRAaQDkcOZu6y3oOuVG8d45A6iTDsM5C8YFrDgEcKx6c0jzMZXZGgQXOs7lUNtlvwgRvuTFmEc(diLiWLKLeiTgAzxftHqGC2gk5OcYUDqPKm2UhQXOs7lUNtlvwgRvuTlJmkDptc0zkDSRIPqiqoBdLCubz3oOuVG8d45A6OOOwKdcvPxYsG6fKFOgJkTV4EoTuzzSwr1ohTvLvna1ofb0zkDqnGAmQ0(I75jQljBrSQb03P5laAMsjXUDqfImZ54rVMWVDBqaO)KQ0gepphLo2UZOizMZXl)f1z4jqEPl)scJvC2u)J0)RYVg3QgaNPa6mLo)scJvCTYmNJx(lQZWtG8sxEg0ArtPpodvGuIaxswsG0AO1pQ0cqHQnKDSoGcqv6NEN7T6M6FK(Fv(ljBrSQb03P5laAMsj57m7K2xHr99SYOioAcbbKZ2qj)wWqHAmQ0(I75zROANkABS7yRAaeIf3w2TdkLK5fM4Awjz3qXIwQOTjMpnbcKpqyIF7(OiLK5fM4Awjz3qPjAdHkABI5ttGa5deM43yjkQfOxkaOr19b9P1qla9GiekuJrL2xCppBfv7C0wvw1au7ueqNP0XUDqPEb5hWZ10rALzohFFkfb(dqjzSkZZGwBi7yDafGQ0p9o3B1nzMZX3NsrG)ausgRY8ljmwX1mlrr7yDafGQ0p9o3ZGouOgJkTV4EE2kQ2piexsTZjz3QK2LbDcmbbQBtsOcYUvjTld6eyhuYmNJpWJmPHqa(JeGQeiXim1BDpd6OiQOTjMpnbcKpqyIZ29rrQ)r6)v5xJBvdGZuaDMsNFjHXkoBSefP(hP)xL)y8Kd(d4WSX8ljmwXzJf2Tdk(ZGiBv3h4rM0qia)rcqvQvM5C888xbanBkbMQdo2s((FvA7KmZ54L)I6m8eiV0fOtYmNJV)xfuJrL2xCppBfv7RXTQbWzkGotPJDvmfcbYzBOKJki72bL6FK(FvEoTuzzm)scJv8BbJIAroiuLEoTuzzmTHO(hP)xL)Ig0FXb)b8BNw)scJv8BAsuuluFaQMk96IT2uHc1yuP9f3ZZwr1(X4jh8hWHzJXUDqfYowhqbOk9tVZ9wDt9ps)Vk)X4jh8hWHzJ57m7K2xHr99SYOODSoGcqv6NEN7zqhQ2qOI2My(0eiq(aHj(nkoPyscKMaP5GrrkjZlmX1SsYydvWOizMZXZZFfa0SPeyQo4yl5xsySIZgfNumjbstGAnyOrrhRrkbljmwXzJItkMKaPjqTgmkQtYmNJx(lQZWtG8sxGojZCoEg0rrYmNJh9Ac)2TbbG(VO1ZGgQXOs7lUNNTIQD1okDiw1ayvtNaiwJuww1WUDqjZCo(uIaKaAA)Ldud6rz5VEEokD3cENAPI2My(0eiq(aHj(nkoPyscKMaP5GAv)J0)RYVg3QgaNPa6mLo)scJv8BuCsXKeinbkksM5C8Pebib00(lhOg0JYYF98Cu6Ufut0gI6FK(FvEoTuzzm)scJvC2cR2CqOk9CAPYYyrrQ)r6)v5VOb9xCWFa)2P1VKWyfNTWQv9bOAQ0Rl2AtffDSgPeSKWyfNTWgkuJrL2xCppBfv7ldxYQgaRA6e4YQo72bLmZ54xgUKvnaw10jWLvDF)VkTJkTaeGksWi(TGqngvAFX98SvuTFmEc(diLiWLKLeiTgAzxftHqGC2gk5OcYUDqPKm2UhQXOs7lUNNTIQDkoAcbinRa72bLsY8ctCnRKSBOcc1yuP9f3ZZwr1UsYaYmlpz3oOusMxyIRzLKDdvqTJkTaeGksWioQGA3X6akavPF6DU3QBSOFuKsY8ctCnRKSBOyr7OslabOIemIFdflqngvAFX98SvuTRKmW1eGy3oOAHmZ54rVMWVDBqaO)lA9mOHAmQ0(I75zROApTgAbOheb2vXuieiNTHsoQGSBhuQxq(b8CnDKwLK5fM4Awjz3qXIwzMZXZZFfa0SPeyQo4yl57)vb1yuP9f3ZZwr1ohTvLvna1ofb0zkDSBhuYmNJxjzaQOTjMNNJs3T71xZHnmoQ0cqaQibJ4ALzohpp)vaqZMsGP6GJTKV)xL2qu)J0)RYVg3QgaNPa6mLo)scJv8BSOv9ps)Vk)X4jh8hWHzJ5xsySIFJLOi1)i9)Q8RXTQbWzkGotPZVKWyfNT71Q(hP)xL)y8Kd(d4WSX8ljmwXVDVwLKD7(Oi1)i9)Q8RXTQbWzkGotPZVKWyf)29Av)J0)RYFmEYb)bCy2y(LegR4SDVwLKDttIIusMxyIRzLKXgQGAPI2My(0eiq(aHjoBSeAuKmZ54vsgGkABI555O0DlO(ApwJucwsySIZ2DaQXOs7lUNNTIQDzKrP7zsGotPJDvmfcbYzBOKJki72bL6fKFapxthPnKCqOk9CAPYYyAv)J0)RYZPLklJ5xsySIZ29rrQ)r6)v5xJBvdGZuaDMsNFjHXk(TGAv)J0)RYFmEYb)bCy2y(LegR43cgfP(hP)xLFnUvnaotb0zkD(LegR4SDVw1)i9)Q8hJNCWFahMnMFjHXk(T71QKSBSefP(hP)xLFnUvnaotb0zkD(LegR43UxR6FK(Fv(JXto4pGdZgZVKWyfNT71QKSB3hfPKSBHnksM5C8YVoa69vEg0Hc1yuP9f3ZZwr1EAn0cqpicSRIPqiqoBdLCubz3oOuVG8d45A6iTkjZlmX1SsYUHIfOgJkTV4EE2kQ2NvnfbYFxQs2TdkLK5fM4Awjz3qfeQXOs7lUNNTIQ9dsmRAaCArtvc0zkDSBvs7YGorfKD7GQfQpavtL(Iu7J8BpksM5C8Oxt43Unia0FsvAdINbnuJrL2xCppBfv7YiJs3ZKaDMsh7QykecKZ2qjhvq2Tdk1li)aEUMosR6FK(Fv(JXto4pGdZgZVKWyfNT71QKmuSOf9sbanQUpOpTgAbOhebTurBtmFAceiFqy1NTGqngvAFX98SvuTlJmkDptc0zkDSRIPqiqoBdLCubz3oOuVG8d45A6iTurBtmFAceiFGWeNnw0gIsY8ctCnRKm2qfmkc9sbanQUpOpTgAbOheHqHAa1yuP9f3Frd6V4G)a(Ttlk1GGagvAFbqmEYEncekvhWPd78CnvIki72bvlYbHQ0ZPLklJb1yuP9f3Frd6V4G)a(TtBROAxniiGrL2xaeJNSxJaHs1bCAPYYySZZ1ujQGSBhu5Gqv650sLLXGAmQ0(I7VOb9xCWFa)2PTvuTtfTn2DSvnacXIBl72bLsY8ctCnRKSBOyrlv02eZNMabYhimXVDpuJrL2xC)fnO)Id(d43oTTIQ914w1a4mfqNP0XUkMcHa5SnuYrfeQXOs7lU)Ig0FXb)b8BN2wr1UmYO09mjqNP0XUkMcHa5SnuYrfKD7Gs9cYpGNRPJ0Q(hP)xL)y8Kd(d4WSX8ljmwX1Q(hP)xLFnUvnaotb0zkD(LegR4ALzoh)fnO)Id(d43oTGRlpdAOgJkTV4(lAq)fh8hWVDABfv7hJNCWFahMng7wL0UmOtubz3QK2LbDcmbbQBtsOcYUDqjZCo(lAq)fh8hWVDAbxxEg0ALzohpp)vaqZMsGP6GJTKNbT2wWPei)fd3NgTSWkbSGwPDuPfGaurcgXzJfOgJkTV4(lAq)fh8hWVDABfv7hJNCWFahMng72bLmZ54VOb9xCWFa)2PfCD5zqRvM5C888xbanBkbMQdo2sEg0A5ucK)IH7tJwwyLawqRIIgvAbiavKGr8BOyrRmZ54VOb9xCWFa)2PfCD5xsySIZwqOgJkTV4(lAq)fh8hWVDABfv7xs2IyvdOVtZxa0mLscQXOs7lU)Ig0FXb)b8BN2wr1ohTvLvna1ofb0zkDSBhuQxq(b8CnDK2qgvAbiavKGr8BOUxRmZ54VOb9xCWFa)2PfCD5zqhfjZCo((ukc8hGsYyvMNbDOqngvAFX9x0G(lo4pGF702kQ2pgpb)bKse4sYscKwdTSRIPqiqoBdLCubz3oOusgk91kZCo(lAq)fh8hWVDAbxx(LegR4SPjrrkjJT7HAmQ0(I7VOb9xCWFa)2PTvuTtXrtiaPzfy3oOusMxyIRzLKDdvqOgJkTV4(lAq)fh8hWVDABfv7kjdiZS8KD7GsjzEHjUMvs2nuHeS1rLwacqfjye)wWqHAmQ0(I7VOb9xCWFa)2PTvuTNwdTa0dIa7QykecKZ2qjhvq2TdkLKHsFTYmNJ)Ig0FXb)b8BNwW1LFjHXkoBAsuuiTiheQsVKLa1li)rrQxq(b8CnDuOAvsMxyIRzLKDdflqngvAFX9x0G(lo4pGF702kQ25OTQSQbO2PiGotPJD7GsM5C8kjdqfTnX88Cu6UDV(AoSHXrLwacqfjyehQXOs7lU)Ig0FXb)b8BN2wr1UmYO09mjqNP0XUkMcHa5SnuYrfKD7Gs9cYpGNRPJ0oQ0cqaQibJ4SH6ETkj7gQ7JIKzoh)fnO)Id(d43oTGRlpdAOgJkTV4(lAq)fh8hWVDABfv7kjdCnbiOgJkTV4(lAq)fh8hWVDABfv7hKyw1a40IMQeOZu6y3QK2LbDIkOtCysPFDIIMaRWLU05aa]] )


end