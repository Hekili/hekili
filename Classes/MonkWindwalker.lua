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


    spec:RegisterPack( "Windwalker", 20220530, [[Hekili:D3tAVnos29BXyb4i1UTIiLK72lKeWMj7gSD2mbiEa28jtrlrzZXsKAjP8rGH(TNxvKSyD8QdsB39S5l9Hj5RE17(QkFJ)n)6nxVjQm(MFjyCqW4lhpDK)xcUC2KBUU8LdX3C9HO1peDh8psJ2d)5FpjDZtr7EioN8Ox2LfTHaIISJ5RHhFZ13Emzx5Fn9MBXHBa8UhIxd)4lV6MRVpzZM4Q3nUynp0pT6)ml9HtF7BhtJpTA6NpTIaNtF703(57JYVlU4pE6BxCA1V(uC0dNw9xskkloTkBl8ppM)YPvjPLX55hpuEA1US7swpI)TV(qsAAs6DNw9Z5reW)FKS(bHx8pTzZPv3MvuSn5U7byS((41palqz2Pv7JsHf4N)3oTkoTmpjUG7tssVyD2(BJGp5VSlU4(15rBlhDZ17i4hHoLDiofiD)6n)cLYhNgD7U4n38VEZ1rRltYsV56TWRgMTnS8(4WNUpPmoSm5oc1EDo8FYtIG)19jJ2h98PvxqWSKtRwU40kGHT(L17GxNqEGvdwHsGmlTmTqPmAhSbgbai82J5fLJQFRtR8OGfDjAWY4NpeVle4e7jlYen7fkMhEiA3Eb0hOqzHfaT7Hy9lwa((zQ29JcuQasdUq2Npf9ymbiZiabzRWby4TUSB7k33eL3CniiEilTGWOZY3Glr0c7ZajVkUvrCECAs5lnmlqBcOJRljFD7wnA3UWQ)tirYRs(lSsbE9MWI4TojA8oTyvaXKCsEsbOogwCmn8bqv0noFZhF7oWcv2XYMp1GCww2UnzpLoIOJrP9BbJfJYJ3hLKwi(ksOKWlD7XTBhjZbdF6PrhpGJ6Z0l0kJJuyVjkDDmbYGG0VLqbBZUTO22v4AIPRQ9mISA7kyez5n6Wiie49fEneWmu(oYAUjp6oGnF4y667Luw(Q7BrcyFmoemeUhSEwBAXoH1cf4Q3K90tRMR1eQ)y3T5q2l(6mt6RxdhfqdayDA15ium6dgkACJAeNUmYk2wnCrTvo2mlGPaaeQPNw96Ru8R1YeqAdPS6w)iK3rK7pSZ279LTzijzt25exQ39YOIYiIBCG4mzmf2ZoT6tYepRYr(VD7mYSR5mb8wxPvuNoBjXxW1fZNMOUOp1AaleOBUMtIC7UxO21IZHirA2l8Fn86mt2gDkrXDMlcEXdFdgw070rHmoqRPccPdxNWJksQ1k(XdcQnAebC3nfkY7M7R2VfDtAGe(93Bs3vbqfSPKFNCYUuR9GViiAhMSfIoYa7whzS3oV2et3A3MLgV5i4z5284NcR)Hoqz)o6LQJmnIoLbR5AwuFEZry7zzBl8reIyEj7aX8tjHT2a1hJaSfEo9FvhxzdiQD6Pg6As6Jzpeh(8X402DWJr7oc6z7kiQOnYm4wWACEP9LQ9YqnId5jsLnOjlgYdNGX1RQJl4H4YreCwwoyuLncrTN3asz0qmif0qZhDpSwuQODOoRLLXr9XSN2UuS1rMH2ajIPlqcnAxijpdZ2rTcSB3LLTXbZOwb02K8ykWmh6Tv4CBCo8OhavgMPTEcOO7OwpGSZEOGzrJreZxt0hlZYHVUuY2NSfjxuLACpljfSSkK1Vwf9v(X04TzG1IrBJaqbl)X133cbiYm)GX0qcDvYFqTZ9hbGaiwA868SDGNfUyPeSlx5UNfRktXHBhPSC8BgPT3WwpBQlJfTd)XcbEqPfeo2M4OY7TKKrF4dxn2rYApX7hGuAISKttR3KoH69we6JIZy0szF2Hxz3gT)L2O76nQAp8kybIFoE9rQ0aXFAZ6Ouwktje9BzLhtVlojphiwfLjPVuuzL2ULlR7FIJZkx9Axfw2qiOgaM15hlj)8W)XrWyXX9Wx)ycPe1VNiNH1HLhgc69uoiBvucIQVVOdhCjlVSdLMLhmGMVMwf9nHrPj7JcVnQeqIxEFXg9ldb5KJ5Mfe59rGW7D5rfha99YyHAv8wnNfmMfOBRTLkD38cGZTJ8fTbmwhSPcgrWF9(nT6T(UDrBsIa3XfafzZDuMvGUW3j7uiEdWIwrYDjVZkxYaNGignOZwskxiln8yrmjSJ0hIlLIz2vVSn8e1yoBjcKvb(690yBc0vFR4O8Y7b7(ruUzY(dWd(XI)vuzu8ISrMWhL22iq8dctd0F3FqkiTGPIV5UDeSNAHw6f1hvRjVnZAdsIvpo9(VUCCZZgylDe)XC(MzVrJBz1VToITkO7K2EN5x(A5x0LEiFiJYKQf8BEb07V)EHEQbDouiuaHaCOSC9jG4uKabwTx4ZLAhF7Cce6sGyoisIL6RWsr2XD3MKUz0bytDe8JgtkSdarH4OoZbPbpzXmYwxxm7KNjxijgQ8y2UOYeaxkY29inLjUxC)(yI17yPYQ20Tx(39UDz3gTJ8Iv1vTeRKhTKIb1y6H8K9GYDceX7bWFtAj8VAQUnWoUsB4U8mn78E9jZ45a1MPLMhLSjmMqMgfTztbiOtLJzRpA3JgT5ieRcq6OrXpE0xR2tfhI3TRPgti95aVtugRMHJ1e1YUb7JyeYlykrYFD)Q3mIYHSePGYrLupepX(qQRgiARne36XTAaMkBjMQa9bYlA49h3hLMLSb2xV(ADxxijqaHffUp655tE9vBIDZd4Eh0(WopOtQBiLeQ5TmwVEJETyrjQPt4nslTc5YL6MhCtzGJv7IhEbqJuQWr3AySdkCIuvCfnub1MDLkNLUa8Pmsf6BQsQC78iUj9597JjAQlzuAdp9zoHv9gH9YK30CL55qhbZRprBlbFP9K62ILoRtmpgV)qCojA(1rqODjWULRxK(xrjRDGM65IXBLVLT9SJrtveFrRj9m6RPvdqi6g9Y)maPi7JZENj2y7CaRPw8)TOnXH08ZsTwVukDi)yX9Sp8jIruM1WkFyI9oKZSH8hYkOkInM3EJB0NizhNUGUoMcOKc2d0yLPjBh8E4JtDvheR2zvWy2M2vx5NQRUo3dUngAo4HfNV(Ep5coGik61gBWQOLgnZe1swSn2b6C2yoyhO8ZdbRN(2xILUUeZLxIPMDwPXeDv(r8fygLT5pwtQtFXAWFVdZBYaZXPy2kFxi9(or6xQ2)0pargNLk7ViZeMid9)otiVRhcpKNTUjcF9ZQZ7T9inRLHIayXlIu3bXkCSGrzJ9Fdn1vH4RWM)iHrvYuXHDxNOBmBMH(d5XpgE36nJ8h1YLWSomBCvPr0Wo0nNhUVb0BnYRPqDAJ6wZUaxoTzOm2AU4eAMkaxD40wOj00GAaKb5l2AOVMhbgsBWW8jyDqO7u39EB9V0SVDRvLXkv8FU7sU(qQ6zRy)izwVfgXBHiPFcz0x8GPZSvxaNuXftj1RhstdQsX48Q)6tU0NoxiAt40(XAYDhMPs9eXMolyPkGIn6Xyjg0Sqt0UqAAsKXSLpZuDGvBjKP(b1gQjMMrvZGR(MXsg1nxJOAI7p2od1yG0i54htlI(WP(slPzlG1gnSRvs67OdVvf5Kvl8DXrBcV9LW4NJ2Fa4snc16BrMP57nDZXKYraLaIAnnQmEdyxyBCAbWEuHm22f(JNj1N2CPCCJ1SGfLK(zxaX(JGqCBVCXI0YtRtjMyKdLygDxS94UDagxTz4Qk5zQWl(5QdSPQORR6a9dv03ZxphszybT3BEkMaARckARUeaGFGyhHqWEBfZdHLo4KHjUVwAqvIAT9Q3kyLWyto6od53HuDdhqlenMkcVT(ouPXjk5bzB1S)D4ZD1HNUP2(7KYvNxMjJDJRORUUUmaIor46mMFjA9(wwNmHf)zooBJ6ofsjonBJoTVDcjnSEMkFj(mo((HwsZ6OUAT9plJtOUrf1Pz10P9rNfYDymLDDyp1N8HtOUJZMe2CvQTuIgMRsT4ewCwDMSQ12XKXDHGlJ)MQ646O13thCLO1)JJGv1nHL5XrfhZjNh229DfjN7CRk0(l23(eyCMfyH83SSPlbIFt0ZXUuaO2TNjuU0W4YwSokVkkcW(qCEA0oAU7BJXY4v7lho1fSLuuHADATRAjYe12GR)4MxvpdruGzGRhZ2QBNVSF)TTAyoIJCS(cpQQh3PZEtpoPDGVc1Q)XoyibgUHu6knDIHcI4GMCdsQEi(mmMY)OqsXdhOldv73be0Ndbfo0Hb69O(Df)48(kEygnmXV2gMcgaLpuJbu)BnpMgCvr4VDCZD7vpwJt0Na9hWehBSpaifxTAJ(9D6J3eVn64U2rqM5X8aG4H3tW7M7VabkPSH86JODlaEK7aAlEuNDvceP6Is)Ol6QhH51TRXRPKwMMqcvB4TzaRmZeEgFABLQj7cRfLflx65kiKxFaZsH6RAft4Rb5yhwsEkTAbPhYFA9B9UI0cVoioH2Gch3vSyzztJxTXnvLt(D2xv2h1xEw69YAVnKnvRt58WyTK6McWXPeMQ7obxvxoKr)BJ9aZPMR(M2vDbpTmrUCR)nD(clJ)4Tyz(srQ1A3xpSErQ3ZjZ(Wubr5zo6WQ7Ox91visRnAJkXL5Ff5UeSrSrZCUupjlAE6urvF9Z4J)i500noPYbnYJNzRWS342LWIfQGVBubd(BMZ6y0pqsfA7J5YZ18TGglxgIGtFhlU))bHSxYCMo7tnnTGAEDBK8SXXpjcIztpRHGAqUvU2pFuZo(j9x1D6Zlx)K81y2CkNekHLN8)sAIeqrEob)IpaZHOC8KD3gB7fYPsrSvcQ4DA1A9XzyUrLzfZPNGHUUEf2MOumoEpwNOS4Q0Ca(E1vWRsIo3MvwclF42DrVeV5jcZUm75K03C(oX)JJjhoeVbKZ11QKAllnVOCLQLECBVnKEG2QSl9Ek9yq65sfpw6PglxCB4Wi1UJfGpl8aUmtfOYg1TuTBPr)3LqwL0TbRVmLhEywFkskReLKLDq7XSfbhd(WAIvg5yOs4e26j8B5iL60brd1k9CX5gx5KY1JJHzBE54nXNpfdMxl5bqS9eoYN4ULPc4CQdD15pX4XpOMSuzKQ6GQ1TtVjLdIFW04OxyN)S(pF)IrFP7oHP3XXJtcmmXvAovdO636hOkkLKGSFGh(s9Yc43EsMoSIAVEg1e1RXGCpRJ36U48OUEDeB(mJ0nRFAQPJqiOvBfBtRgV(Oqq365Ex68BQER9Qkn1CsqmK8WckMoHA1zcDQMTT2vz1BDwZDZzGX7km(7Twe)H6hWd0tYJKck7ysjvW7MZ5JUP2W9JjZGtihilcrtVcINPJ5ZAHJdKdSPjM8wkVyimiTgOQGTUZSdqcHybliuRQFdBmBYyimLOCc4HW0(7)P)7F5V(l)7)XtRoT6xVhOvj7pKLxEA12S8tR(j5ms)jiPT4QG9itAlXEy0riRqYaXs2qrP3r)fDXFlHetQpa2Folfqa6J)PAA9)Zpv9Bid2)VHMd)CYVsm(Z)x)nGH5)8qgGcEVaKFpGunao9nl0QM8L6inAC3Xi59MvuJlBUUHDxjHCTJVed)4(rQeT69OSGqpbZx7ly0ivjdpwR1yGR9N0hbIYUrSN8MqNkymT7stcF)LVXV3V)iGv6zvfq6gnvwF3zrgHDLmNPFqrM00pO8L(jLOXE4S(It4WBIS1mhXoxfbQBo9BtgWDrY(lt7i5UhqYknkklUB0NES9e3v9Wf2BMSWOg)v6MN8zxvvxysg(0FrAbpgcv8y59zq(PxNS)Njv9lBBcPKC)H)WPvQ)weJ8tv)njg5N2(BtmY)7Io9BumXVWYVvXQF5U(Bwm(pd)3Uyn7K)CvoPeWtuRJRYcK8Y3gFheT6iakRxhFGSTsZsVGurGTh31qBjB20DVaGR()pIvj1Zx8VOR2P4VDtfs)mPqHlqQt4NZoSOa(lAbux4q9tF9vT1oL7rT1nL7hQTMPCVJs9s5EMuTs5EIH6KItxARgk(Zz1(4ZjBxCgs3B0(vKS1OFKTIEQkTe)iT(XvfbPKy2bweIbNeqKi6XOKDKpSvUyHYadXEKcRNn5hIm8UmkplfgnGxFv4)ErxG0C)GXEdgi1kfpbaUuBhc90(KL(Jh(6Rd66e6mxyH966NV0FM9vTE8xwm2c4BOqcO0WHwySqqBA4RY9c2YYxJMZd8azzYTiO(PYz(x5rQQHcHi4xZvrMpfGLlpxi1lGMsQm0ZYCuaFoyaxuWz(Ilhpeh1o7Df3mVQY9iRIB1a(px1vTf(e0szyDScg5IgOcoSZFOvWwnKjcaJQFmLknmZ7mBJ8e3kOPm2FwOgkvRrDfBUa(7LlM4nqTgmZ9rVLlN6zUSqZ9hnJ7sUuxZ)Nhm07mlD6HBN1wgFfK3xhYR1Kf5w48dENHoti8BO2cVHYD4k0NNWUn43J7w35Jc(4vDX7zE4mwgmZBGeZVslOPd6WpqD8lwgmg2jIurXpd(jcgsuMicc6Iw2uQw6u7Q5vz5lOMFMKVyhbcIXSodi4V5)ErIX8j2baKnMbiawuirA1eUg8YlqBiPWRaRfsbIv0ggG364xF1Sq4q51sqONSkQ6il5B0LGe08f(YWtQVSyA1nbFHsl8S2H3LU1D3ZNo0BGzD7LtO7MLlMPqwuA)kZ7MMBuuPV3KHAmwqVCxjdirRkck6kVQMUuY2MM6Q6s)R8SiMCHVf7QcVTm2zXRGKJGgdiSU8qSx3QQOWBf7BPD(JtQJM7L5sW5ZzQDWCi1moi)z76WE5LwFJjE1XWO0zsnrWSyWKZN8jlE)iPxymuumzWM8qf6tNSqVAJdzYEcnm8ZSAUOYze6qO1aigi3JWxFvwYXtRZnqqZcPAISPrpZ98drfA(KH8omQCwUWqwTu)NQhzloXrd3a7NjDjIasJiYOCcE45IfmukF85bZK3deDAHROmBzRjMp(a)Vo(c0RMTpbPZBueLG42sLtZ(gn4vH0TDOEdIvUyOhkqrZL0NlPotKrJzw((sh7gDY59KskLKGeqIFDkyNu92oBO(qgAwwEFnEDI7niy85bJ)K(l2b895emnaHy5vToHSH9hJUHrHD7f9gb0iaBckWqGLaRKkHHYHR9Dfiv7Slh75w9OwoMpBndfKIuAnVbwlhtN4RekRQDtQYnYMIuHfjmq9ECRJyGKDH3BAMubtn6dxJU6mD6WE6Uf2qeMWwZWQllTkvahU61CeSvWZbQ4IafpwaDvrbKjRaMDgi7S0dpComTyZ4KArDbpZ4xvA8sjUiI19fgrLyOT4EwCLxToJBjMbrgfGzctplvKWpqxrgbUKix1AvBCOWoDMi(7h6ftU0BG5Ic4DMYft2qplFID7XQYsD0czxP8De8tqJfP5g)OQ(o6UBUO1bZgbOtyd4Gr0pkeQgQ53GXwX6eTDq1j8UFlABBx)axeLw02)1IyLvBuDwreT9t2jeQtsgx1b5a52I7e2G673kfqQJ4gxjEpPDAVROvmzChOgIiSHg1tq(kQbR4VbvzQjFFx96RIV3sFP3R6oUQV4O2RqQ2WWnFDv5E2iIlm14Q0n4KyXfO8jXb4OJmZGX6teNxVe5kOrp6x87ASu8MzIGQIIZeDBR6NyosX0zVebbeV1LeIq2fIXe0nQ7s3T3NsF3xAsqc0L)JCL9r30S7aPp0LgtPw42sIvpvTf0bbcsxOsyew28lrwaT3Jsw7yVNLInHu0bYp)Zi3dsKI9kDJhj8J4Xt5lwjLcUw18WfIJ6sZpUU)kvd8sY2ptYFnH8XgQMP8CXO0zAFRgbmm3rt05qSAzdJ3vyzT7bSrjzGSr3lvn(cilBZwav7zmqkYI0barlsD8JfSP0XVv0Qqx)yz96o(9IT8s3B9HwIEBs4DR2YDRqis1A7TudEvIfZ1U7elNC73t05JRVaV)uSoGIAYcY)sTlhwxfysnU0PaDa29seOrlTJgv7sY9FeROyM9FeRGXSP)iwWFq1rGHny5P3rt6wZg)9LU9bKNLd5qPz3(9jB1UGFc92t)l12KoTE6LB(gAO)T9PsYmjPpvd0hqhPTxvHD38eIzC13N0vv7v4Tt0tnDCJ08jPY2)H3STHA9z08pDYxrGB5LHheNwzK33SRAyO)OYOQASUx8omIBvq6C5rRRocc2OVXIFWkCOyqFg9yeyjm1tTVm672I)DhPKWJwa0WOxOmpNIYbmPu1p9ChN0Tk5lUzCfPMONPv5ry8f4wAhMBu8XjJx3rEVRGQ9ExtPIQxutyGRBdLMUMzADOwwg4cnGxH1etP3eghN5Dzu0DJbZXzADIkdXOjpPFUUHfuYkXNFBYYv1vA0FZhtNz25xHMfvJ(OnUnEoR2gSTHOtvKL2o3mN1FA8OV(6RfGXQDnu2L(8kVLokIGR7GIAyVAnf4IalZcvrPK7tlE1ASnk7(k8(J7JsZsQA3d2qAYf8HHydyVd(yae8zt(qTvCutQDIv2LswCY6Q2GgBvFAEg3GOODWjMImHPYClzd2gfxfPJIIPyJfiYjesAg1LNy3xnmNuyvi4CFLzFv8X2oog1lOGzJNIZfTCspEVFhNxFDoCepgioSQt90NkY8zEsYuommoWhjjrjt(NjlI11dYH8jIYhrKTNoVkvcEv35oOq5CGV(J50EHSKSdrUJsM9omAlM4CZrdfge0Uw(UsYBY4lM9jXnRndQwNy(L2oaaldCWVWeBaP6yC4GlML2a18kqnv5yjG4slOPgVkKsFPjWy(xKymDkqmpLdEVEdeUqdSEkJ8Tdex5joWEDLNuFUZMXcjKDKuKnF1BTlj44(zEQomkKtNt75W5Zjc3mfsTRbniyf7gDtUXfYkysb)47GCIOEtidMcKWbYLgkbkUiC(EKDZT4TFMzvG55VxhIwmiBjSsJFB3i5M5)wJDbpn7WNeoo6yyz)ZVXiyXRstpWp0u4EZ7i54eM0B6x)dxcbyUf8eMgG2qPg4FUCaFdnckRfOBXy9eRgZvtjhOalNAvT2ZDNN6CWrVJkQIaE(IMJLATVHEic1euQz5mZoSO3vQ38)n]] )


end