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
    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event )
        local _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

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


    spec:RegisterPack( "Windwalker", 20220315, [[dSuwScqiveEevIYMOs9juOgLGYPeuTkveLxjLywKe3IkHDrv)sfPHjioMawgk4zQOAAujY1eKABcs6BOqKXrLO6CQOW6urrZdf19aL9jL6GOqQwOuspefctufrcxufryJOqk9ruifNufr0krrEPkIentvuYnvrK0ojj9tvevwQkIQEkQmvQK(kke1yfKyVK6VadgQdRyXuXJjAYs1Lr2Sk9zHA0K40uwnkK8AsQzdYTrv7wYVv1WbvhxfLA5k9Cctx01rPTlqFxfgVq68cX6vrKA(sX(HSoG2vnxFssRkdHWadHCEGq7d4Yz4mCPZ1Cze4KMd(ivpXKMRgEsZXiBv)yGutRMd(eb6NU2vnN4zxjP50CoSguEswAhnxFssRkdHWadHCEGq7d4Yz4mo)m0Cc4KuRkdH6zO5uSENkTJMRtcPMJr2Q(XaPMwe(K6xQrmDsDwPcchGbvqygcHbgqm5YCziMyekZgtIZeXKlqyxpOrncZO1ePaH)lcZOLDJGWwL0USWteg6JnPhXKlqyxpOrncZb3QYQyeMrStri8jLMuncd9XM0JyYfimJEVJWoVqCTyLeHLkKuTaHZhH5NkccZioPaHPkxJeEetUaHz07De2kxiFENjrygTqKqrUZn9AoitKcTRAUhov0QDvRAaTRAoQghiQRBvZnY0(sZDnrc(liviWHILeiTyA1CY1sATrZjvmp)efHDbclvmeUnme(CnNmIeIa5SXuk0QgqNAvzq7QMJQXbI66w1CY1sATrZLdevPxQyah2vKEQghiQJWUryPI55NOiSlqyPIHWTHHWNR5gzAFP5OOWjiGYS86uR65Ax1Cunoqux3QMBKP9LMlTyAbWhiEnNCTKwB0CYN35bICn1ec7gHLkMNFIIWUaHLkgc3ggcZGMtgrcrGC2ykfAvdOtTQUK2vnhvJde11TQ5KRL0AJMtQyE(jkc7cewQyimmeMbn3it7lnNuXahtqsNAvdT2vn3it7lnhffobbuMLxZr14arDDR6uRAOQDvZr14arDDRAUrM2xAU0IPfaFG41CY1sATrZjvmp)efHDbclvmeUnmeMbnNmIeIa5SXuk0QgqN6uZDqd8VeG)c(TtR2vTQb0UQ5OACGOUUvnNCTKwB0CNaHZbIQ0lOLklJ4PACGOUMtKRjtTQb0CJmTV0CYbccmY0(cazIuZbzIeudpP5KDGGU6uRkdAx1Cunoqux3QMtUwsRnAUCGOk9cAPYYiEQghiQR5e5AYuRAan3it7lnNCGGaJmTVaqMi1CqMib1WtAozhiOLklJOtTQNRDvZr14arDDRAo5AjT2O5KkMNFIIWUaHLkgc3ggcZac7gHPI24i(04jq(a(jkc3gHpxZnY0(sZrfTX2jTvXacYIARo1Q6sAx1Cunoqux3QMBKP9LMBnHvXabBbuBs1AozejebYzJPuOvnGo1QgATRAoQghiQRBvZjxlP1gn3itlibOI4nsGWTHHWmGWUryh271Fqd8VeG)c(Ttl44WVe)yLaHzgHdO5gzAFP5UMifG)cUSBeDQvnu1UQ5OACGOUUvnNCTKwB0CJmTGeGkI3ibc3ggcZGMBKP9LM7qXwiRIb9DI)caNTKk6uRkJK2vnhvJde11TQ5KRL0AJMt(8opqKRPMqy3iCyi8itlibOI4nsGWTHHWNJWUryh271Fqd8VeG)c(Ttl44WZchHBAqyh2713NssG)cKkgJY8SWr4W1CJmTV0Cc4wvwfdK7ueqTjvRtTQUCTRAoQghiQRBvZjxlP1gnNuXqyyiCiiSBe2H9E9h0a)lb4VGF70coo8lXpwjqyMryxsZnY0(sZrrHtqaLz51Pw1Zq7QMJQXbI66w1CJmTV0CxtKG)csfcCOyjbslMwnNCTKwB0CsfdHHHWHGWUryh271Fqd8VeG)c(Ttl44WVe)yLaHzgHDjnNmIeIa5SXuk0QgqNAvdeI2vn3it7ln3HITqwfd67e)faoBjv0Cunoqux3Qo1QgiG2vnhvJde11TQ5gzAFP5CGgP6NnbQnPAnNCTKwB0CYN35bICn1ec7gHL)d1)JYFnrka)fCz3i(L4hReiSBew(pu)pk)AcRIbc2cO2KQ9lXpwjqy3iSd796pOb(xcWFb)2PfCC4zHR5KrKqeiNnMsHw1a6uRAag0UQ5OACGOUUvn3it7lnxAX0cGpq8Ao5AjT2O5KkgcddHdbHDJWoS3R)Gg4Fja)f8BNwWXHFj(XkbcZmc7sAozejebYzJPuOvnGo1Qg4CTRAoQghiQRBvZjxlP1gnNd796pOb(xcWFb)2PfCC4zHJWUryh271lYF5b0SPcyQo4Al5zHR5SkPDzHNAUaAoRsAxw4jW45PUnjP5cO5gzAFP5UMifG)cUSBeDQvnGlPDvZr14arDDRAo5AjT2O5CyVxVuXaurBCeVihPAeUncFEiiSlq4qJWNmeEKPfKaur8gj0CJmTV0Cc4wvwfdK7ueqTjvRtTQbcT2vnhvJde11TQ5gzAFP5UMib)fKke4qXscKwmTAo5AjT2O5KkgcZmcFUMtgrcrGC2ykfAvdOtTQbcvTRAoQghiQRBvZjxlP1gnNuX88tue2fiSuXq42Wq4aAUrM2xAokkCccOmlVo1QgGrs7QMJQXbI66w1CY1sATrZjvmp)efHDbclvmeUnmeomeoac3ccpY0csaQiEJeiCBeoachUMBKP9LMtQyah2vK6uRAaxU2vnhvJde11TQ5gzAFP5slMwa8bIxZjxlP1gnxyi8jq4CGOk9kwcKpVZ7PACGOoc30GWYN35bICn1echoc7gHLkMNFIIWUaHLkgc3ggcZGMtgrcrGC2ykfAvdOtTQbodTRAoQghiQRBvZnY0(sZ5ans1pBcuBs1Ao5AjT2O5KpVZde5AQje2ncpY0csaQiEJeimZWq4Zry3iSuXq42Wq4Zr4Mge2H9E9h0a)lb4VGF70coo8SW1CYisicKZgtPqRAaDQvLHq0UQ5gzAFP5Kkg4ycsAoQghiQRBvNAvziG2vnNvjTll8uZfqZnY0(sZDHIyvmqqlCQsGAtQwZr14arDDR6uNAobTuzzeTRAvdODvZr14arDDRAo5AjT2O5CyVxVGwQSmIFj(XkbcZmchqZnY0(sZDnrka)fCz3i6uRkdAx1Cunoqux3QMtUwsRnAo5Z78arUMAcHDJWHHWJmTGeGkI3ibc3ggcFoc30GWJmTGeGkI3ibc3gHdGWUr4tGWY)H6)r5xtyvmqWwa1MuTNfochUMBKP9LMta3QYQyGCNIaQnPADQv9CTRAoQghiQRBvZnY0(sZTMWQyGGTaQnPAnNCTKwB0CYN35bICn1KMtgrcrGC2ykfAvdOtTQUK2vnhvJde11TQ5KRL0AJMBKPfKaur8gjq42Wq4Z1CJmTV0CxtKcWFbx2nIo1QgATRAoQghiQRBvZjxlP1gnN85DEGixtnHWUryh2713NssG)cKkgJY8SW1CJmTV0Cc4wvwfdK7ueqTjvRtTQHQ2vnhvJde11TQ5gzAFP5CGgP6NnbQnPAnNCTKwB0CYN35bICn1ec7gHDyVx)bnW)sa(l43oTEw4iSBew(pu)pk)AcRIbc2cO2KQ9lXpwjq42imdAozejebYzJPuOvnGo1QYiPDvZzvs7Ycpb2vZDc5)q9)O8RjSkgiylGAtQ2ZcxZnY0(sZDnrka)fCz3iAoQghiQRBvNAvD5Ax1Cunoqux3QMtUwsRnAo5Z78arUMAcHDJWDYH9E9oFrDwrcCw6a0jh271ZcxZnY0(sZjGBvzvmqUtra1MuTo1QEgAx1Cunoqux3QMBKP9LM7AIe8xqQqGdfljqAX0Q5KRL0AJMtQyimZi85AozejebYzJPuOvnGo1QgieTRAoQghiQRBvZnY0(sZ5ans1pBcuBs1Ao5AjT2O5KpVZde5AQjeUPbHpbcNdevPxXsG85DEpvJde11CYisicKZgtPqRAaDQvnqaTRAUrM2xAobCRkRIbYDkcO2KQ1Cunoqux3Qo1PMt2bcAPYYiAx1Qgq7QMJQXbI66w1CpCnNGsn3it7lnxWzTXbI0CbhiwsZj)hQ)hLxqlvwgXVe)yLaHzgHdGWnnimCk9rzPcKke4qXscKwmT(rMwqcHDJWY)H6)r5f0sLLr8lXpwjq42i85HGWnniSZleiSBe(AXkjyj(XkbcZmcZqiAUGZcQHN0CcAPYYiah2vK6uRkdAx1Cunoqux3QMtUwsRnAUtGWbN1ghiYR8qDquwQq4Mge25fce2ncFTyLeSe)yLaHzgHzi0AUrM2xAoRc(QjquwQ0Pw1Z1UQ5OACGOUUvnNCTKwB0CbN1ghiYlOLklJaCyxrQ5gzAFP5CG(VdUSBeDQv1L0UQ5OACGOUUvnNCTKwB0CbN1ghiYlOLklJaCyxrQ5gzAFP5COvqRARI1Pw1qRDvZnY0(sZbzXkPaWOy7X8uLAoQghiQRBvNAvdvTRAoQghiQRBvZjxlP1gnxWzTXbI8cAPYYiah2vKAUrM2xAURTKd0)DDQvLrs7QMJQXbI66w1CY1sATrZfCwBCGiVGwQSmcWHDfPMBKP9LMBkjjYDGaYbcsNAvD5Ax1Cunoqux3QMtUwsRnAUGZAJde5f0sLLraoSRi1CJmTV0Cotm4VGCnPAHo1QEgAx1Cunoqux3QMtUwsRnAURfRKGL4hReiCBeomeoGlpee2fi8Yw093yYFNCGa5Zkv8unoquhHpziCagcbHdhHBAqy4u6JYsfiviWHILeiTyA9JmTGec7gHddHpbcl)Gunv6lsUp0VDeUPbHDyVxVZxuNvKaNLo8SWr4Wr4Mgeomew(pu)pkVvbF1eiklvGuHahkwsG0IP1Ve)yLaHBJWxlwjblXpwjq4Wry3iSd796D(I6SIe4S0HNfoc30GWoVqGWUr4RfRKGL4hReimZiCGq0CJmTV0C5Zkva)f0Pjv0Pw1aHODvZr14arDDRAo5AjT2O5UwSscwIFSsGWTr4ZieeUPbHHtPpklvGuHahkwsG0IP1pY0csiCtdc78cbc7gHVwSscwIFSsGWmJWbcrZnY0(sZLpRub8xG6z5hDQvnqaTRAoQghiQRBvZjxlP1gnN8FO(Fu(1ewfdeSfqTjv7xIFSsGWmJWuusYMeinEsZnY0(sZDqd8VeG)c(TtRo1QgGbTRAoQghiQRBvZjxlP1gnxWzTXbI8cAPYYiah2vKiCtdc78cbc7gHVwSscwIFSsGWmJWmeIMBKP9LMZkHCzZXbIaNn7ujlpOtbnjPtTQbox7QMJQXbI66w1CJmTV0CPcbU2ksGWIninNCTKwB0CbN1ghiYlOLklJaCyxrIWnniSZleiSBe(AXkjyj(XkbcZmcZqiAUA4jnxQqGRTIeiSydsNAvd4sAx1Cunoqux3QMtUwsRnAUGZAJde5f0sLLraoSRi1CJmTV0Ch7KkI8lsNAvdeATRAoQghiQRBvZjxlP1gnxWzTXbI8cAPYYiah2vKAUrM2xAUyOPBt(Ra4m9ysNAvdeQAx1Cunoqux3QMBKP9LMtOm9)iEhbCq(jXR5KRL0AJMdoL(OSubsfcCOyjbslMw)itliHWnniSZleiSBe(AXkjyj(XkbcZmcZqiiCtdcFceEzl6(Bm5Tk4RMwbOtqwSs6PACGOUMRgEsZjuM(FeVJaoi)K41Pw1amsAx1Cunoqux3QMtUwsRnAUtGWbN1ghiYhLLkWxawbbY1k1uIWnniS8FO(FuERc(QjquwQaPcbouSKaPftRFj(Xkbc3gHzieeUPbHdoRnoqKx5H6GOSuP5gzAFP5yfeWsIxOtTQbC5Ax1CJmTV0C3HGSIaI85HR5OACGOUUvDQvnWzODvZnY0(sZDhiiQa)2PvZr14arDDR6uRkdHODvZr14arDDRAo5AjT2O5CEHaHDJWxlwjblXpwjqyMr4aHgHBAq4WqyPIHWTHHWmGWUr4Wq4RfRKGL4hReiCBeoudbHDJWHHWHHWY)H6)r5f0sLLr8lXpwjq42iCGqq4Mge2H9E9cAPYYiEw4iCtdcl)hQ)hLxqlvwgXZchHdhHDJWHHWWP0hLLkqQqGdfljqAX06hzAbjeUPbHL)d1)JYBvWxnbIYsfiviWHILeiTyA9lXpwjq42iCGqq4Mgeo4S24arELhQdIYsfchochochoc30GWHHWxlwjblXpwjqyMHHWHAiiSBeomegoL(OSubsfcWiRyjbslMw)itliHWnniS8FO(FuERc(QjquwQaPcbouSKaPftRFj(Xkbc3gHVwSscwIFSsGWHJWHJWHR5gzAFP5C(I6SIe4S0Ho1QYqaTRAoQghiQRBvZjxlP1gnN8FO(Fu(1ewfdeSfqTjv7xIFSsGWmJWmGWnniSZleiSBe(AXkjyj(XkbcZmchi0AUrM2xAobTuzzeDQvLbg0UQ5gzAFP5CMyWFb5As1cnhvJde11TQtTQmCU2vnhvJde11TQ5KRL0AJMZH9E9cAPYYi((FuiSBe2H9E9oFrDwrcCw6a0jh2713)JcHDJWoS3R35lQZksGZsh((FuiSBeomew8Sqow19WzfjlebOLfEAF5PACGOoc30GWINfYXQUp4dnPbraXdfKQ0t14arDeoCnNvjTll8eyxnN4zHCSQ7d(qtAqeq8qbPk1CwL0USWtGXZtDBssZfqZnY0(sZDHiHICNBQ5SkPDzHNGyO3zG0Cb0Po1CIu7Qw1aAx1Cunoqux3QMtUwsRnAUWqyh271dFn(F72abG)jvPnqEros1imZi8zGWnniSd796D(I6SIe4S0HFj(XkbcZmcl)hQ)hLFnHvXabBbuBs1(L4hReiSBe2H9E9oFrDwrcCw6WZchHDJWWP0hLLkqQqGdfljqAX06hzAbjeoCe2nchgcVJ1buqQs)07cVviCBew(pu)pk)HITqwfd67e)faoBjv8D2Ds7le(KHWH4D5iCtdclGtqqGC2ykfiCBeoachUMBKP9LM7qXwiRIb9DI)caNTKk6uRkdAx1Cunoqux3QMtUwsRnAoPI55NOiSlqyPIHWTHHWmGWUryQOnoIpnEcKpGFIIWTr4Zr4MgewQyE(jkc7cewQyiCByiSlHWUr4WqyQOnoIpnEcKpGFIIWTrygq4Mge(eim8LccILDFaFAX0cGpq8iC4AUrM2xAoQOn2oPTkgqqwuB1Pw1Z1UQ5OACGOUUvnNCTKwB0CYN35bICn1ec7gHDyVxFFkjb(lqQymkZZchHDJWHHW7yDafKQ0p9UWBfc3gHDyVxFFkjb(lqQymkZVe)yLaHDbcZac30GW7yDafKQ0p9UWZchHdxZnY0(sZjGBvzvmqUtra1MuTo1Q6sAx1Cunoqux3QMtUwsRnAoXZc5yv3h8HM0GiG4Hcsv6PACGOoc7gHDyVxVi)LhqZMkGP6GRTKV)hfc7gH7Kd796D(I6SIe4S0bOtoS3RV)hLMZQK2LfEcSRMZH9E9bFOjniciEOGuLafw(PER7zH30qfTXr8PXtG8b8tuMpVPr(pu)pk)AcRIbc2cO2KQ9lXpwjyMHMg5)q9)O8xtKcWFbx2nIFj(XkbZmO5SkPDzHNaJNN62KKMlGMBKP9LM7crcf5o3uNAvdT2vnhvJde11TQ5gzAFP5wtyvmqWwa1MuTMtUwsRnAo5)q9)O8cAPYYi(L4hReiCBeoac30GWNaHZbIQ0lOLklJ4PACGOoc7gHddHL)d1)JYFqd8VeG)c(TtRFj(Xkbc3gHDjeUPbHpbcl)Gunv6vhzTPq4W1CYisicKZgtPqRAaDQvnu1UQ5OACGOUUvnNCTKwB0CHHW7yDafKQ0p9UWBfc3gHL)d1)JYFnrka)fCz3i(o7oP9fcFYq4q8UCeUPbH3X6akivPF6DHNfochoc7gHddHPI24i(04jq(a(jkc3gHPOKKnjqA8ec7ceoac30GWsfZZprryxGWsfdHzggchaHBAqyh271lYF5b0SPcyQo4Al5xIFSsGWmJWuusYMeinEcHBbHdGWHJWnni81IvsWs8JvceMzeMIss2KaPXtiCliCaeUPbH7Kd796D(I6SIe4S0bOtoS3RNfoc30GWoS3Rh(A8)2Tbca)pO1ZcxZnY0(sZDnrka)fCz3i6uRkJK2vnhvJde11TQ5KRL0AJMZH9E9PcbiE40(Raih4J0YF9ICKQr42iCGZaHDJWurBCeFA8eiFa)efHBJWuusYMeinEcHDbchaHDJWY)H6)r5xtyvmqWwa1MuTFj(Xkbc3gHPOKKnjqA8ec30GWoS3RpviaXdN2Ffa5aFKw(RxKJunc3gHd4siSBeomew(pu)pkVGwQSmIFj(XkbcZmchAe2ncNdevPxqlvwgXt14arDeUPbHL)d1)JYFqd8VeG)c(TtRFj(XkbcZmchAe2ncl)Gunv6vhzTPq4Mge(AXkjyj(XkbcZmchAeoCn3it7lnNChPAiRIbmQPtailwjlRI1PwvxU2vnhvJde11TQ5KRL0AJMZH9E9lRqXQyaJA6e4WQUV)hfc7gHhzAbjaveVrceUnchqZnY0(sZTScfRIbmQPtGdR66uR6zODvZr14arDDRAUrM2xAURjsWFbPcbouSKaPftRMtUwsRnAoPIHWmJWNR5KrKqeiNnMsHw1a6uRAGq0UQ5OACGOUUvnNCTKwB0CsfZZprryxGWsfdHBddHdO5gzAFP5OOWjiGYS86uRAGaAx1Cunoqux3QMtUwsRnAoPI55NOiSlqyPIHWTHHWbqy3i8itlibOI4nsGWWq4aiSBeEhRdOGuL(P3fERq42imdHGWnniSuX88tue2fiSuXq42Wqygqy3i8itlibOI4nsGWTHHWmO5gzAFP5KkgWHDfPo1QgGbTRAoQghiQRBvZjxlP1gn3jqyh271dFn(F72abG)h06zHR5gzAFP5Kkg4ycs6uRAGZ1UQ5OACGOUUvn3it7lnxAX0cGpq8Ao5AjT2O5KpVZde5AQje2nclvmp)efHDbclvmeUnmeMbe2nc7WEVEr(lpGMnvat1bxBjF)pknNmIeIa5SXuk0QgqNAvd4sAx1Cunoqux3QMtUwsRnAoh271lvmav0ghXlYrQgHBJWNhcc7ceo0i8jdHhzAbjaveVrce2nc7WEVEr(lpGMnvat1bxBjF)pke2nchgcl)hQ)hLFnHvXabBbuBs1(L4hReiCBeMbe2ncl)hQ)hL)AIua(l4YUr8lXpwjq42imdiCtdcl)hQ)hLFnHvXabBbuBs1(L4hReimZi85iSBew(pu)pk)1ePa8xWLDJ4xIFSsGWTr4Zry3iSuXq42i85iCtdcl)hQ)hLFnHvXabBbuBs1(L4hReiCBe(Ce2ncl)hQ)hL)AIua(l4YUr8lXpwjqyMr4Zry3iSuXq42iSlHWnniSuX88tue2fiSuXqyMHHWbqy3imv0ghXNgpbYhWprryMrygq4Wr4Mge2H9E9sfdqfTXr8ICKQr42iCGqqy3i81IvsWs8JvceMzeMrsZnY0(sZjGBvzvmqUtra1MuTo1Qgi0Ax1Cunoqux3QMBKP9LMZbAKQF2eO2KQ1CY1sATrZjFENhiY1utiSBeomeohiQsVGwQSmINQXbI6iSBew(pu)pkVGwQSmIFj(XkbcZmcFoc30GWY)H6)r5xtyvmqWwa1MuTFj(Xkbc3gHdGWUry5)q9)O8xtKcWFbx2nIFj(Xkbc3gHdGWnniS8FO(Fu(1ewfdeSfqTjv7xIFSsGWmJWNJWUry5)q9)O8xtKcWFbx2nIFj(Xkbc3gHphHDJWsfdHBJWmGWnniS8FO(Fu(1ewfdeSfqTjv7xIFSsGWTr4Zry3iS8FO(Fu(Rjsb4VGl7gXVe)yLaHzgHphHDJWsfdHBJWNJWnniSuXq42iCOr4Mge2H9E9oVAa89LEw4iC4AozejebYzJPuOvnGo1Qgiu1UQ5OACGOUUvn3it7lnxAX0cGpq8Ao5AjT2O5KpVZde5AQje2nclvmp)efHDbclvmeUnmeMbnNmIeIa5SXuk0QgqNAvdWiPDvZr14arDDRAo5AjT2O5KkMNFIIWUaHLkgc3ggchqZnY0(sZnRCkcK)UuL6uRAaxU2vnhvJde11TQ5KRL0AJM7eiS8ds1uPVi5(q)2r4Mge2H9E9WxJ)3Unqa4FsvAdKNfUMBKP9LM7cfXQyGGw4uLa1MuTMZQK2LfEQ5cOtTQbodTRAoQghiQRBvZnY0(sZ5ans1pBcuBs1Ao5AjT2O5KpVZde5AQje2ncl)hQ)hL)AIua(l4YUr8lXpwjqyMr4Zry3iSuXqyyimdiSBeg(sbbXYUpGpTyAbWhiEe2nctfTXr8PXtG8bHoeeMzeoGMtgrcrGC2ykfAvdOtTQmeI2vnhvJde11TQ5gzAFP5CGgP6NnbQnPAnNCTKwB0CYN35bICn1ec7gHPI24i(04jq(a(jkcZmcZac7gHddHLkMNFIIWUaHLkgcZmmeoac30GWWxkiiw29b8Pftla(aXJWHR5KrKqeiNnMsHw1a6uNAozhiOR2vTQb0UQ5OACGOUUvnNCTKwB0CNaHdoRnoqKx5H6GOSuHWUr4Wqy5)q9)O8RjSkgiylGAtQ2Ve)yLaHzgHzaHBAq4tGWYpivtLE1rwBkeoCe2nchgcFcew(bPAQ0xKCFOF7iCtdcl)hQ)hL35lQZksGZsh(L4hReimZimdiC4iCtdcFTyLeSe)yLaHzgHzi0AUrM2xAoRc(QjquwQ0Pwvg0UQ5OACGOUUvnNCTKwB0CxlwjblXpwjq42iCyiCaxEiiSlq4LTO7VXK)o5abYNvQ4PACGOocFYq4amecchoc30GWoS3RxK)YdOztfWuDW1wY3)JcHDJWWP0hLLkqQqGdfljqAX06hzAbje2nchgcFcew(bPAQ0xKCFOF7iCtdc7WEVENVOoRibolD4zHJWHJWnniCyiS8FO(FuERc(QjquwQaPcbouSKaPftRFj(Xkbc3gHVwSscwIFSsGWHJWUryh27178f1zfjWzPdplCeUPbHDEHaHDJWxlwjblXpwjqyMr4aHO5gzAFP5YNvQa(lOttQOtTQNRDvZr14arDDRAo5AjT2O5cdH3X6akivPF6DH3keUnc7sHgHBAq4DSoGcsv6NEx4zHJWHJWUry5)q9)O8RjSkgiylGAtQ2Ve)yLaHzgHPOKKnjqA8ec7gHL)d1)JYBvWxnbIYsfiviWHILeiTyA9lXpwjq42iCyimdHGWTGWmeccFYq4LTO7VXK3QGVAAfGobzXkPNQXbI6iC4iCtdc78cbc7gHVwSscwIFSsGWmJWNhAn3it7ln3bnW)sa(l43oT6uRQlPDvZr14arDDRAo5AjT2O5KpVZde5AQje2nchgcVJ1buqQs)07cVviCBeoqiiCtdcVJ1buqQs)07cplCeoCn3it7ln3DiiRiGiFE46uRAO1UQ5OACGOUUvnNCTKwB0C7yDafKQ0p9UWBfc3gHppeeUPbH3X6akivPF6DHNfUMBKP9LM7oqqub(TtRo1QgQAx1Cunoqux3QMtUwsRnAUtGWoS3R35lQZksGZshEw4iSBeomewQyiCByimdiSBe(AXkjyj(Xkbc3gHd1qqy3iCyiS8FO(FuEr(lpGMnvat1bxBjVuz2ysGWTr4qq4Mgew(pu)pkVi)LhqZMkGP6GRTKFj(Xkbc3gHdecchoc7gHddHHtPpklvGuHahkwsG0IP1pY0csiCtdcl)hQ)hL3QGVAceLLkqQqGdfljqAX06xIFSsGWTr4aHGWnniCWzTXbI8kpuheLLkeoCeUPbHddHLkgc3ggcZac7gHVwSscwIFSsGWmddHd1qqy3iCyimCk9rzPcKkeGrwXscKwmT(rMwqcHBAqy5)q9)O8wf8vtGOSubsfcCOyjbslMw)s8JvceUncFTyLeSe)yLaHdhHDJWHHWY)H6)r5f5V8aA2ubmvhCTL8sLzJjbc3gHdbHBAqy5)q9)O8I8xEanBQaMQdU2s(L4hReiCBe(AXkjyj(Xkbc30GWoS3RxK)YdOztfWuDW1wYZchHdhHdhHBAqyNxiqy3i81IvsWs8JvceMzeoqOr4Wr4Mge25fce2ncFTyLeSe)yLaHzgHdecc7gHfplKJvDpenDGteafD4HdrEQghiQR5gzAFP5C(I6SIe4S0Ho1QYiPDvZr14arDDRAo5AjT2O5KF1zT0l)F7wnj1b)9sLWcsEQghiQR5gzAFP5e5V8aA2ubmvhCTLaxl6KKo1Q6Y1UQ5OACGOUUvnNCTKwB0CY)H6)r5f5V8aA2ubmvhCTL8sLzJjbcddHzaHBAq4RfRKGL4hReimZimdHGWnniCyi8owhqbPk9tVl8lXpwjq42iCGqJWnniCyi8jqy5hKQPsV6iRnfc7gHpbcl)Gunv6lsUp0VDeoCe2nchgchgcVJ1buqQs)07cVviCBew(pu)pkVi)LhqZMkGP6GRTK)YcbbwsQmBmbsJNq4Mge(ei8owhqbPk9tVl8uutKceoCe2nchgcl)hQ)hL3QGVAceLLkqQqGdfljqAX06xIFSsGWTry5)q9)O8I8xEanBQaMQdU2s(lleeyjPYSXeinEcHBAq4GZAJde5vEOoiklviC4iC4iSBew(pu)pk)1ePa8xWLDJ4xIFSsGWmddHpde2nclvmeUnmeMbe2ncl)hQ)hL)qXwiRIb9DI)caNTKk(L4hReimZWq4amGWHR5gzAFP5e5V8aA2ubmvhCTL0Pw1Zq7QMJQXbI66w1CY1sATrZj)Gunv6vhzTPqy3iCyiSd796pOb(xcWFb)2P1ZchHBAq4Wq4RfRKGL4hReimZiS8FO(Fu(dAG)La8xWVDA9lXpwjq4Mgew(pu)pk)bnW)sa(l43oT(L4hReiCBew(pu)pkVi)LhqZMkGP6GRTK)YcbbwsQmBmbsJNq4Wry3iS8FO(Fu(Rjsb4VGl7gXVe)yLaHzggcFgiSBewQyiCByimdiSBew(pu)pk)HITqwfd67e)faoBjv8lXpwjqyMHHWbyaHdxZnY0(sZjYF5b0SPcyQo4AlPtTQbcr7QMJQXbI66w1CY1sATrZj)Gunv6lsUp0VDe2nc3jh27178f1zfjWzPdqNCyVxplCe2nchgcdNsFuwQaPcbouSKaPftRFKPfKq4Mgeo4S24arELhQdIYsfc30GWY)H6)r5Tk4RMarzPcKke4qXscKwmT(L4hReiCBew(pu)pkVi)LhqZMkGP6GRTK)YcbbwsQmBmbsJNq4Mgew(pu)pkVvbF1eiklvGuHahkwsG0IP1Ve)yLaHBJWNhcchUMBKP9LMtK)YdOztfWuDW1wsNAvdeq7QMJQXbI66w1CJmTV0CwjKlBooqe4SzNkz5bDkOjjnNCTKwB0CWP0hLLkqQqGdfljqAX06hzAbjeUPbHDEHaHDJWxlwjblXpwjqyMrygcrZvdpP5Ssix2CCGiWzZovYYd6uqts6uRAag0UQ5OACGOUUvn3it7lnxQqGRTIeiSydsZjxlP1gnhCk9rzPcKke4qXscKwmT(rMwqcHBAqy5)q9)O8wf8vtGOSubsfcCOyjbslMw)s8JvceUnchQHGWUr4RfRKGL4hReiCBe(8qcbHBAqyNxiqy3i81IvsWs8JvceMzeMHq0C1WtAUuHaxBfjqyXgKo1Qg4CTRAoQghiQRBvZjxlP1gnhCk9rzPcKke4qXscKwmT(rMwqcHBAqyNxiqy3i81IvsWs8JvceMzeMHq0CJmTV0Ch7KkI8lsNAvd4sAx1Cunoqux3QMtUwsRnAo4u6JYsfiviWHILeiTyA9JmTGec30GWoVqGWUr4RfRKGL4hReimZimdHO5gzAFP5IHMUn5VcGZ0JjDQvnqO1UQ5OACGOUUvn3it7lnxFPPFTLabjHGG0CY1sATrZDceo4S24ar(OSub(cWkiqUwPMseUPbHL)d1)JYBvWxnbIYsfiviWHILeiTyA9lXpwjq42imdHGWUry4u6JYsfiviWHILeiTyA9lXpwjqyMrygcbHBAq4GZAJde5vEOoiklvAUA4jnxFPPFTLabjHGG0Pw1aHQ2vnhvJde11TQ5gzAFP5ekt)pI3rahKFs8Ao5AjT2O5GtPpklvGuHahkwsG0IP1pY0csiCtdc78cbc7gHVwSscwIFSsGWmJWmecc30GWNaHx2IU)gtERc(QPva6eKfRKEQghiQR5QHN0CcLP)hX7iGdYpjEDQvnaJK2vnhvJde11TQ5gzAFP5sfcCTvKaHfBqAo5AjT2O5GtPpklvGuHahkwsG0IP1Ve)yLaHBJWbcnc30GWY)H6)r5Tk4RMarzPcKke4qXscKwmT(L4hReiCBeoudbHDJWxlwjblXpwjq42i85Hecc30GWoVqGWUr4RfRKGL4hReimZimdHO5QHN0CPcbU2ksGWIniDQvnGlx7QMJQXbI66w1CY1sATrZDceo4S24ar(OSub(cWkiqUwPMseUPbHL)d1)JYBvWxnbIYsfiviWHILeiTyA9lXpwjq42imdHGWnniCWzTXbI8kpuheLLkn3it7lnhRGaws8cDQvnWzODvZr14arDDRAo5AjT2O5UwSscwIFSsGWTr4ZieeUPbHHtPpklvGuHahkwsG0IP1pY0csiCtdchCwBCGiVYd1brzPcHBAqyNxiqy3i81IvsWs8JvceMzeoqOQ5gzAFP5YNvQa(lq9S8Jo1QYqiAx1Cunoqux3QMtUwsRnAo5)q9)O8wf8vtGOSubsfcCOyjbslMw)s8JvceUncFEiiCtdchCwBCGiVYd1brzPcHBAqyNxiqy3i81IvsWs8JvceMzeMHq0CJmTV0Coq)3bx2nIo1QYqaTRAoQghiQRBvZjxlP1gnN8FO(FuERc(QjquwQaPcbouSKaPftRFj(Xkbc3gHppeeUPbHdoRnoqKx5H6GOSuHWnniSZleiSBe(AXkjyj(XkbcZmchi0AUrM2xAohAf0Q2QyDQvLbg0UQ5gzAFP5GSyLuayuS9yEQsnhvJde11TQtTQmCU2vnhvJde11TQ5KRL0AJMt(pu)pkVvbF1eiklvGuHahkwsG0IP1Ve)yLaHBJWNhcc30GWbN1ghiYR8qDquwQq4Mge25fce2ncFTyLeSe)yLaHzgHdeIMBKP9LM7Al5a9FxNAvzWL0UQ5OACGOUUvnNCTKwB0CY)H6)r5Tk4RMarzPcKke4qXscKwmT(L4hReiCBe(8qq4Mgeo4S24arELhQdIYsfc30GWoVqGWUr4RfRKGL4hReimZimdHO5gzAFP5MssIChiGCGG0PwvgcT2vnhvJde11TQ5KRL0AJMZH9E9I8xEanBQaMQdU2s((FuAUrM2xAoNjg8xqUMuTqNAvziu1UQ5OACGOUUvnNCTKwB0CoS3RxqlvwgX3)JcHDJWoS3R35lQZksGZshGo5WEV((FuiSBe2H9E9oFrDwrcCw6W3)JcHDJWHHWINfYXQUhoRizHiaTSWt7lpvJde1r4Mgew8Sqow19bFOjniciEOGuLEQghiQJWHR5SkPDzHNa7Q5eplKJvDFWhAsdIaIhkivPMZQK2LfEcmEEQBtsAUaAUrM2xAUlejuK7CtnNvjTll8eed9odKMlGo1PMRt3Hfk1UQvnG2vn3it7lnNaonlqzQoqKRPM0Cunoqux3Qo1QYG2vnhvJde11TQ5E4AobLAUrM2xAUGZAJdeP5coqSKMt(pu)pkVvbF1eiklvGuHahkwsG0IP1Ve)yLaHBJWxlwjblXpwjq4Mge(AXkjyj(Xkbc7cew(pu)pkVvbF1eiklvGuHahkwsG0IP1Ve)yLaHzgHdWqiiSBeomeomeohiQsVGwQSmINQXbI6iSBe(AXkjyj(Xkbc3gHL)d1)JYlOLklJ4xIFSsGWUry5)q9)O8cAPYYi(L4hReiCBeoqiiC4iCtdchgcl)hQ)hLxK)YdOztfWuDW1wYFzHGaljvMnMaPXtimZi81IvsWs8Jvce2ncl)hQ)hLxK)YdOztfWuDW1wYFzHGaljvMnMaPXtiCBeoqOr4Wr4Mgeomew(pu)pkVi)LhqZMkGP6GRTKxQmBmjqyyiCiiSBew(pu)pkVi)LhqZMkGP6GRTKFj(XkbcZmcFTyLeSe)yLaHdhHdxZfCwqn8KMt5H6GOSuPtTQNRDvZr14arDDRAo5AjT2O5cdHDyVxVGwQSmINfoc30GWoS3RxK)YdOztfWuDW1wYZchHdhHDJWWP0hLLkqQqGdfljqAX06hzAbjeUPbHDEHaHDJWxlwjblXpwjqyMHHWHAiAUrM2xAo4FAFPtTQUK2vnhvJde11TQ5KRL0AJMZH9E9cAPYYiEw4AorUMm1QgqZnY0(sZjhiiWit7laKjsnhKjsqn8KMtqlvwgrNAvdT2vnhvJde11TQ5KRL0AJMZH9E9h0a)lb4VGF706zHR5e5AYuRAan3it7lnNCGGaJmTVaqMi1CqMib1WtAUdAG)La8xWVDA1Pw1qv7QMJQXbI66w1CY1sATrZLgpHWmJWUec7gHLkgcZmchAe2ncFcegoL(OSubsfcCOyjbslMw)itliP5e5AYuRAan3it7lnNCGGaJmTVaqMi1CqMib1WtAUhov0QtTQmsAx1Cunoqux3QMBKP9LM7AIe8xqQqGdfljqAX0Q5KRL0AJMtQyE(jkc7cewQyiCByi85iSBeomeMkAJJ4tJNa5d4NOimZiCaeUPbHPI24i(04jq(a(jkcZmc7siSBew(pu)pk)1ePa8xWLDJ4xIFSsGWmJWb8HgHBAqy5)q9)O8h0a)lb4VGF706xIFSsGWmJWmGWHJWUr4tGWDYH9E9oFrDwrcCw6a0jh271ZcxZjJiHiqoBmLcTQb0PwvxU2vnhvJde11TQ5KRL0AJMtQyE(jkc7cewQyiCByiCae2nchgctfTXr8PXtG8b8tueMzeoac30GWY)H6)r5f0sLLr8lXpwjqyMrygq4MgeMkAJJ4tJNa5d4NOimZiSlHWUry5)q9)O8xtKcWFbx2nIFj(XkbcZmchWhAeUPbHL)d1)JYFqd8VeG)c(TtRFj(XkbcZmcZachoc7gHpbc7WEVENVOoRibolD4zHR5gzAFP5OOWjiGYS86uR6zODvZr14arDDRAUrM2xAU0IPfaFG41CY1sATrZjFENhiY1utiSBewQyE(jkc7cewQyiCByimdiSBeomeMkAJJ4tJNa5d4NOimZiCaeUPbHL)d1)JYlOLklJ4xIFSsGWmJWmGWnnimv0ghXNgpbYhWprryMryxcHDJWY)H6)r5VMifG)cUSBe)s8JvceMzeoGp0iCtdcl)hQ)hL)Gg4Fja)f8BNw)s8JvceMzeMbeoCe2ncFceUtoS3R35lQZksGZshGo5WEVEw4AozejebYzJPuOvnGo1QgieTRAoQghiQRBvZjxlP1gnN8ds1uPVSyLeChcHDJWY)H6)r5Vdbzfbe5Zd3Ve)yLaHBJWmeAe2nchgclvmp)efHDbclvmeUnmeoac7gHhzAbjaveVrceggchaHDJW7yDafKQ0p9UWBfc3gHzieeUPbHLkMNFIIWUaHLkgc3ggcZac7gHhzAbjaveVrceUnmeMbeoCn3it7lnNuXaoSRi1Pw1ab0UQ5OACGOUUvnNCTKwB0CNaHZbIQ0lOLklJ4PACGOUMtKRjtTQb0CJmTV0CYbccmY0(cazIuZbzIeudpP5KDGGU6uRAag0UQ5OACGOUUvnNCTKwB0C5arv6f0sLLr8unoquxZjY1KPw1aAUrM2xAo5abbgzAFbGmrQ5GmrcQHN0CYoqqlvwgrNAvdCU2vnhvJde11TQ5KRL0AJMBKPfKaur8gjqyMr4Z1CICnzQvnGMBKP9LMtoqqGrM2xaitKAoitKGA4jnNi1Pw1aUK2vnhvJde11TQ5KRL0AJMBKPfKaur8gjq42Wq4Z1CICnzQvnGMBKP9LMtoqqGrM2xaitKAoitKGA4jn38Ko1PMd(sYN3zsTRAvdODvZnY0(sZ58zcrDWfAIq9dRIb5h1knhvJde11TQtTQmODvZr14arDDRAUhUMtqPMBKP9LMl4S24arAUGdelP5OZM1GdN6EReYLnhhicC2StLS8Gof0Kec30GW0zZAWHtDFm00Tj)vaCMEmHWnnimD2SgC4u3FStQiYVieUPbHPZM1GdN6(piTsLzJPoykJFaotM0gbHBAqy6Szn4WPUxOm9)iEhbCq(jXJWnnimD2SgC4u3Nke4ARibcl2Gq4MgeMoBwdoCQ7LJuHa)fmYZM1wQdYLgb7scnxWzb1WtAUOSub(cWkiqUwPMsDQv9CTRAUrM2xAUlejuK7CtnhvJde11TQtTQUK2vnhvJde11TQ5KRL0AJM7eiS8ds1uPVSyLeChsZnY0(sZjvmGd7ksDQvn0Ax1Cunoqux3QMtUwsRnAUtGW5arv6PI2y7K2QyabzrP1t14arDn3it7lnNuXahtqsN6uZnpPDvRAaTRAUrM2xAUdfBHSkg03j(laC2sQO5OACGOUUvDQvLbTRAoQghiQRBvZjxlP1gnNuX88tue2fiSuXq42Wqygqy3imv0ghXNgpbYhWprr42imdiCtdclvmp)efHDbclvmeUnme2L0CJmTV0CurBSDsBvmGGSO2QtTQNRDvZr14arDDRAo5AjT2O5KpVZde5AQje2nchgc7WEV((usc8xGuXyuMNfoc30GWDYH9E9oFrDwrcCw6a0jh271ZchHdxZnY0(sZjGBvzvmqUtra1MuTo1Q6sAx1Cunoqux3QMtUwsRnAoQOnoIpnEcKpGFIIWTrykkjztcKgpHWnniSuX88tue2fiSuXqyMHHWb0CJmTV0CxtKcWFbx2nIo1QgATRAoQghiQRBvZnY0(sZTMWQyGGTaQnPAnNCTKwB0CHHW5arv6puSfYQyqFN4VaWzlPINQXbI6iSBew(pu)pk)AcRIbc2cO2KQ9D2Ds7leUncl)hQ)hL)qXwiRIb9DI)caNTKk(L4hReiCliSlHWHJWUr4Wqy5)q9)O8xtKcWFbx2nIFj(Xkbc3gHphHBAqyPIHWTHHWHgHdxZjJiHiqoBmLcTQb0Pw1qv7QMJQXbI66w1CY1sATrZ5WEV(LvOyvmGrnDcCyv33)JsZnY0(sZTScfRIbmQPtGdR66uRkJK2vnhvJde11TQ5KRL0AJMtQyE(jkc7cewQyiCByiCan3it7lnhffobbuMLxNAvD5Ax1Cunoqux3QMBKP9LM7AIe8xqQqGdfljqAX0Q5KRL0AJMtQyE(jkc7cewQyiCByi85AozejebYzJPuOvnGo1QEgAx1Cunoqux3QMtUwsRnAoPI55NOiSlqyPIHWTHHWmO5gzAFP5KkgWHDfPo1QgieTRAoQghiQRBvZjxlP1gnNd796tfcq8WP9xbqoWhPL)6f5ivJWTr4aNbc7gHPI24i(04jq(a(jkc3gHPOKKnjqA8ec7ceoac7gHL)d1)JYFnrka)fCz3i(L4hReiCBeMIss2KaPXtAUrM2xAo5os1qwfdyutNaqwSswwfRtTQbcODvZr14arDDRAUrM2xAU0IPfaFG41CY1sATrZjvmp)efHDbclvmeUnmeMbe2nchgcFceohiQsVILa5Z78EQghiQJWnniS85DEGixtnHWHR5KrKqeiNnMsHw1a6uRAag0UQ5OACGOUUvnNCTKwB0CsfZZprryxGWsfdHBddHdO5gzAFP5MvofbYFxQsDQvnW5Ax1Cunoqux3QMtUwsRnAo5Z78arUMAcHDJWHHWY)H6)r5D(I6SIe4S0HFj(Xkbc3gHzaHBAq4tGWYpivtL(IK7d9BhHdhHDJWHHWsfdHBddHdnc30GWY)H6)r5VMifG)cUSBe)s8JvceUnchQiCtdcl)hQ)hL)AIua(l4YUr8lXpwjq42i85iSBewQyiCByi85iSBeMkAJJ4tJNa5dcDiimZiCaeUPbHPI24i(04jq(a(jkcZmmeome(CeUfe(Ce(KHWY)H6)r5VMifG)cUSBe)s8JvceMzeo0iC4iCtdc7WEVEr(lpGMnvat1bxBjplCeoCn3it7lnNaUvLvXa5ofbuBs16uRAaxs7QMJQXbI66w1CY1sATrZjFENhiY1utAUrM2xAoPIboMGKo1Qgi0Ax1Cunoqux3QMBKP9LM7cfXQyGGw4uLa1MuTMtUwsRnAoh27178QbW3x67)rP5SkPDzHNAUa6uRAGqv7QMJQXbI66w1CJmTV0CoqJu9ZMa1MuTMtUwsRnAo5Z78arUMAcHDJWHHWoS3R35vdGVV0ZchHBAq4CGOk9kwcKpVZ7PACGOoc7gHHVuqqSS7d4tlMwa8bIhHDJWsfdHHHWmGWUry5)q9)O8xtKcWFbx2nIFj(XkbcZmcFoc30GWsfZZprryxGWsfdHzggchaHDJWWxkiiw29b8c4wvwfdK7ueqTjvJWUryQOnoIpnEcKpGFIIWmJWNJWHR5KrKqeiNnMsHw1a6uN6uZfKwH9LwvgcHbgcHbgcvn3XSLvXcnhJmJ(jVQNKQYO5mrye2vfcHnE4)Mi89xeMXh0a)lb4VGF70YyeEPZM1wQJWINNq4HnF(jPoclvMkMeEetNLvech4mrygXxbPnPocZ4CGOk9HcJr48rygNdevPpu8unoquNXi8Ki8jXj3zHWHfiA4EetNLvecZWzIWmIVcsBsDeMX5arv6dfgJW5JWmohiQsFO4PACGOoJr4jr4tItUZcHdlq0W9iMolRieoGl)mrygXxbPnPocZ4CGOk9HcJr48rygNdevPpu8unoquNXiCybIgUhXeIjgzg9tEvpjvLrZzIWiSRkecB8W)nr47VimJf0sLLrymcV0zZAl1ryXZti8WMp)KuhHLktftcpIPZYkcHdeYzIWmIVcsBsDeMX5arv6dfgJW5JWmohiQsFO4PACGOoJr4jr4tItUZcHdlq0W9iMqmXiZOFYR6jPQmAotegHDvHqyJh(VjcF)fHzSSde0sLLrymcV0zZAl1ryXZti8WMp)KuhHLktftcpIPZYkcHpJZeHzeFfK2K6imJx2IU)gt(qHXiC(imJx2IU)gt(qXt14arDgJWHfiA4EetNLvechiupteMr8vqAtQJWmEzl6(Bm5dfgJW5JWmEzl6(Bm5dfpvJde1zmcpjcFsCYDwiCybIgUhX0zzfHWmC(zIWmIVcsBsDeMXINfYXQUpuymcNpcZyXZc5yv3hkEQghiQZyeomgIgUhXeIjgzg9tEvpjvLrZzIWiSRkecB8W)nr47VimJfjJr4LoBwBPoclEEcHh285NK6iSuzQys4rmDwwriSlDMimJ4RG0MuhHzS4zHCSQ7dfgJW5JWmw8Sqow19HINQXbI6mgHdlq0W9iMolRieo0NjcZi(kiTj1rygNdevPpuymcNpcZ4CGOk9HINQXbI6mgHdlq0W9iMolRieMr6mrygXxbPnPocZ4CGOk9HcJr48rygNdevPpu8unoquNXiCybIgUhX0zzfHWbc9zIWmIVcsBsDeMX5arv6dfgJW5JWmohiQsFO4PACGOoJr4WcenCpIjetmYm6N8QEsQkJMZeHryxvie24H)BIW3Frygl7abDzmcV0zZAl1ryXZti8WMp)KuhHLktftcpIPZYkcHz4mrygXxbPnPocZ4LTO7VXKpuymcNpcZ4LTO7VXKpu8unoquNXiCybIgUhX0zzfHWNFMimJ4RG0MuhHz8Yw093yYhkmgHZhHz8Yw093yYhkEQghiQZyeoSard3Jy6SSIq4q9mrygXxbPnPocZyXZc5yv3hkmgHZhHzS4zHCSQ7dfpvJde1zmcpjcFsCYDwiCybIgUhX0zzfHWbc1ZeHzeFfK2K6imJx2IU)gt(qHXiC(imJx2IU)gt(qXt14arDgJWtIWNeNCNfchwGOH7rmDwwrimdH6zIWmIVcsBsDeMXINfYXQUpuymcNpcZyXZc5yv3hkEQghiQZyeomgIgUhXeIjgzg9tEvpjvLrZzIWiSRkecB8W)nr47VimJ70DyHsgJWlD2S2sDew88ecpS5Zpj1ryPYuXKWJy6SSIqygoteMr8vqAtQJWmohiQsFOWyeoFeMX5arv6dfpvJde1zmchwGOH7rmDwwriCGaNjcZi(kiTj1rygNdevPpuymcNpcZ4CGOk9HINQXbI6mgHNeHpjo5oleoSard3Jy6SSIq4amCMimJ4RG0MuhHzCoquL(qHXiC(imJZbIQ0hkEQghiQZyeEse(K4K7Sq4WcenCpIjetmYm6N8QEsQkJMZeHryxvie24H)BIW3FrygppXyeEPZM1wQJWINNq4HnF(jPoclvMkMeEetNLvech6ZeHzeFfK2K6imJZbIQ0hkmgHZhHzCoquL(qXt14arDgJWHfiA4EetNLvechiWzIWmIVcsBsDeMX5arv6dfgJW5JWmohiQsFO4PACGOoJr4WcenCpIPZYkcHdeQNjcZi(kiTj1rygNdevPpuymcNpcZ4CGOk9HINQXbI6mgHdlq0W9iMqmDsYd)3K6i8zGWJmTVqyitKcpIjn3WMk)Q54mEgHMd((xdI0CUmxgcZiBv)yGutlcFs9l1iMCzUme(K6SsfeoadQGWmecdmGyYL5Yqm5YCzimJqz2ysCMiMCzUme2fiSRh0OgHz0AIuGW)fHz0YUrqyRsAxw4jcd9XM0JyYL5YqyxGWUEqJAeMdUvLvXimJyNIq4tknPAeg6JnPhXKlZLHWUaHz07De25fIRfRKiSuHKQfiC(im)urqygXjfimv5AKWJyYL5YqyxGWm69ocBLlKpVZKimJwisOi35MEetiMCzUme(KikjztQJWo09xcHLpVZKiSdfBLWJWm6sjbpfiC9LluML)YcHWJmTVei8xqr8iMgzAFj8Wxs(8ot2cStD(mHOo4cnrO(HvXG8JAfIPrM2xcp8LKpVZKTa70GZAJdePsn8eSOSub(cWkiqUwPMsvE4WeuQsWbILGrNnRbho19wjKlBooqe4SzNkz5bDkOjPMg6Szn4WPUpgA62K)kaotpMAAOZM1GdN6(JDsfr(f10qNnRbho19FqALkZgtDWug)aCMmPnstdD2SgC4u3luM(FeVJaoi)K4BAOZM1GdN6(uHaxBfjqyXgutdD2SgC4u3lhPcb(lyKNnRTuhKlnc2LeiMgzAFj8Wxs(8ot2cStVqKqrUZnrmnY0(s4HVK85DMSfyNkvmGd7ksvSlSti)Gunv6llwjb3HqmnY0(s4HVK85DMSfyNkvmWXeKuXUWoroquLEQOn2oPTkgqqwuA9unoquhXeIjxMldHpjIss2K6imfK2iiCA8ecNkecpY8xe2ei8eCmOXbI8iMgzAFjGjGtZcuMQde5AQjetJmTVeTa70GZAJdePsn8emLhQdIYsLkpCyckvj4aXsWK)d1)JYBvWxnbIYsfiviWHILeiTyA9lXpwjAFTyLeSe)yLOP5AXkjyj(XkHlK)d1)JYBvWxnbIYsfiviWHILeiTyA9lXpwjyoadH4oSWYbIQ0lOLklJ4(AXkjyj(XkrB5)q9)O8cAPYYi(L4hReUL)d1)JYlOLklJ4xIFSs0oqiH30eM8FO(FuEr(lpGMnvat1bxBj)LfccSKuz2ycKgpX81IvsWs8Jvc3Y)H6)r5f5V8aA2ubmvhCTL8xwiiWssLzJjqA8u7aHo8MMWK)d1)JYlYF5b0SPcyQo4Al5LkZgtcyH4w(pu)pkVi)LhqZMkGP6GRTKFj(XkbZxlwjblXpwjcpCetJmTVeTa7u4FAFPIDHfMd796f0sLLr8SWBACyVxVi)LhqZMkGP6GRTKNfE4UHtPpklvGuHahkwsG0IP1pY0csnnoVq4(AXkjyj(XkbZWc1qqmnY0(s0cStLdeeyKP9faYePk1WtWe0sLLrurKRjtybuXUWCyVxVGwQSmINfoIPrM2xIwGDQCGGaJmTVaqMivPgEc2bnW)sa(l43oTQiY1KjSaQyxyoS3R)Gg4Fja)f8BNwplCetJmTVeTa7u5abbgzAFbGmrQsn8eShov0QIixtMWcOIDHLgpXSl5wQymhA3NaoL(OSubsfcCOyjbslMw)itliHyAKP9LOfyNEnrc(liviWHILeiTyAvrgrcrGC2ykfWcOIDHjvmp)e1fsfRnSZDhgv0ghXNgpbYhWprzoqtdv0ghXNgpbYhWprz2LCl)hQ)hL)AIua(l4YUr8lXpwjyoGp0nnY)H6)r5pOb(xcWFb)2P1Ve)yLGzgc39j6Kd796D(I6SIe4S0bOtoS3RNfoIPrM2xIwGDkffobbuMLxf7ctQyE(jQlKkwBybChgv0ghXNgpbYhWprzoqtJ8FO(FuEbTuzze)s8JvcMzOPHkAJJ4tJNa5d4NOm7sUL)d1)JYFnrka)fCz3i(L4hRemhWh6Mg5)q9)O8h0a)lb4VGF706xIFSsWmdH7(eoS3R35lQZksGZshEw4iMgzAFjAb2PPftla(aXRImIeIa5SXukGfqf7ct(8opqKRPMClvmp)e1fsfRnmgChgv0ghXNgpbYhWprzoqtJ8FO(FuEbTuzze)s8JvcMzOPHkAJJ4tJNa5d4NOm7sUL)d1)JYFnrka)fCz3i(L4hRemhWh6Mg5)q9)O8h0a)lb4VGF706xIFSsWmdH7(eDYH9E9oFrDwrcCw6a0jh271ZchX0it7lrlWovQyah2vKQyxyYpivtL(YIvsWDi3Y)H6)r5Vdbzfbe5Zd3Ve)yLOndH2DysfZZprDHuXAdlG7rMwqcqfXBKawa37yDafKQ0p9UWBvBgcPPrQyE(jQlKkwBym4EKPfKaur8gjAdJHWrmnY0(s0cStLdeeyKP9faYePk1WtWKDGGUQiY1KjSaQyxyNihiQsVGwQSmcIPrM2xIwGDQCGGaJmTVaqMivPgEcMSde0sLLrurKRjtybuXUWYbIQ0lOLklJGyAKP9LOfyNkhiiWit7laKjsvQHNGjsve5AYewavSlSrMwqcqfXBKG5ZrmnY0(s0cStLdeeyKP9faYePk1WtWMNurKRjtybuXUWgzAbjaveVrI2WohXeIPrM2xc)8eSdfBHSkg03j(laC2sQGyAKP9LWpp1cStPI2y7K2QyabzrTvf7ctQyE(jQlKkwBym4MkAJJ4tJNa5d4NOTzOPrQyE(jQlKkwByUeIPrM2xc)8ulWova3QYQyGCNIaQnPAvSlm5Z78arUMAYDyoS3RVpLKa)fivmgL5zH300jh27178f1zfjWzPdqNCyVxpl8WrmnY0(s4NNAb2PxtKcWFbx2nIk2fgv0ghXNgpbYhWprBtrjjBsG04PMgPI55NOUqQymdlaIPrM2xc)8ulWoDnHvXabBbuBs1QiJiHiqoBmLcybuXUWclhiQs)HITqwfd67e)faoBjvCl)hQ)hLFnHvXabBbuBs1(o7oP9vB5)q9)O8hk2czvmOVt8xa4SLuXVe)yLOfxkC3Hj)hQ)hL)AIua(l4YUr8lXpwjAFEtJuXAdl0HJyAKP9LWpp1cStxwHIvXag10jWHvDvSlmh271VScfRIbmQPtGdR6((FuiMgzAFj8ZtTa7ukkCccOmlVk2fMuX88tuxivS2WcGyAKP9LWpp1cStVMib)fKke4qXscKwmTQiJiHiqoBmLcybuXUWKkMNFI6cPI1g25iMgzAFj8ZtTa7uPIbCyxrQIDHjvmp)e1fsfRnmgqmnY0(s4NNAb2PYDKQHSkgWOMobGSyLSSkwf7cZH9E9PcbiE40(Raih4J0YF9ICKQBh4mCtfTXr8PXtG8b8t02uusYMeinEYfbCl)hQ)hL)AIua(l4YUr8lXpwjAtrjjBsG04jetJmTVe(5PwGDAAX0cGpq8QiJiHiqoBmLcybuXUWKkMNFI6cPI1ggdUd7e5arv6vSeiFENVPr(8opqKRPMchX0it7lHFEQfyNoRCkcK)UuLQyxysfZZprDHuXAdlaIPrM2xc)8ulWova3QYQyGCNIaQnPAvSlm5Z78arUMAYDyY)H6)r5D(I6SIe4S0HFj(XkrBgAAoH8ds1uPVi5(q)2d3DysfRnSq30i)hQ)hL)AIua(l4YUr8lXpwjAhQnnY)H6)r5VMifG)cUSBe)s8JvI2N7wQyTHDUBQOnoIpnEcKpi0HWCGMgQOnoIpnEcKpGFIYmSWoVLZpzY)H6)r5VMifG)cUSBe)s8JvcMdD4nnoS3RxK)YdOztfWuDW1wYZcpCetJmTVe(5PwGDQuXahtqsf7ct(8opqKRPMqmnY0(s4NNAb2PxOiwfde0cNQeO2KQvXUWCyVxVZRgaFFPV)hLkwL0USWtybqmnY0(s4NNAb2PoqJu9ZMa1MuTkYisicKZgtPawavSlm5Z78arUMAYDyoS3R35vdGVV0ZcVPjhiQsVILa5Z78UHVuqqSS7d4tlMwa8bI3TuXGXGB5)q9)O8xtKcWFbx2nIFj(XkbZN30ivmp)e1fsfJzybCdFPGGyz3hWlGBvzvmqUtra1MuTBQOnoIpnEcKpGFIY85HJycX0it7lHx2bc6cZQGVAceLLkqQqGdfljqAX0QIDHDIGZAJde5vEOoiklvUdt(pu)pk)AcRIbc2cO2KQ9lXpwjyMHMMti)Gunv6vhzTPc3DyNq(bPAQ0xKCFOF7nnY)H6)r5D(I6SIe4S0HFj(XkbZmeEtZ1IvsWs8JvcMzi0iMgzAFj8Yoqq3wGDA(SsfWFbDAsfvSlSRfRKGL4hReTdlGlpexSSfD)nM83jhiq(SsLtwagcj8Mgh271lYF5b0SPcyQo4Al57)r5goL(OSubsfcCOyjbslMw)itli5oSti)Gunv6lsUp0V9Mgh27178f1zfjWzPdpl8WBAct(pu)pkVvbF1eiklvGuHahkwsG0IP1Ve)yLO91IvsWs8JvIWD7WEVENVOoRibolD4zH3048cH7RfRKGL4hRemhieetJmTVeEzhiOBlWo9Gg4Fja)f8BNwvSlSW2X6akivPF6DH3Q2UuOBA2X6akivPF6DHNfE4UL)d1)JYVMWQyGGTaQnPA)s8JvcMPOKKnjqA8KB5)q9)O8wf8vtGOSubsfcCOyjbslMw)s8JvI2HXqiTWqiNSLTO7VXK3QGVAAfGobzXkz4nnoVq4(AXkjyj(XkbZNhAetJmTVeEzhiOBlWo9oeKveqKppCvSlm5Z78arUMAYDy7yDafKQ0p9UWBv7aH00SJ1buqQs)07cpl8WrmnY0(s4LDGGUTa707abrf43oTQyxy7yDafKQ0p9UWBv7ZdPPzhRdOGuL(P3fEw4iMgzAFj8Yoqq3wGDQZxuNvKaNLouXUWoHd796D(I6SIe4S0HNfU7WKkwBym4(AXkjyj(Xkr7qne3Hj)hQ)hLxK)YdOztfWuDW1wYlvMnMeTdPPr(pu)pkVi)LhqZMkGP6GRTKFj(Xkr7aHeU7WGtPpklvGuHahkwsG0IP1pY0csnnY)H6)r5Tk4RMarzPcKke4qXscKwmT(L4hReTdesttWzTXbI8kpuheLLQWBActQyTHXG7RfRKGL4hRemdludXDyWP0hLLkqQqagzfljqAX06hzAbPMg5)q9)O8wf8vtGOSubsfcCOyjbslMw)s8JvI2xlwjblXpwjc3DyY)H6)r5f5V8aA2ubmvhCTL8sLzJjr7qAAK)d1)JYlYF5b0SPcyQo4Al5xIFSs0(AXkjyj(XkrtJd796f5V8aA2ubmvhCTL8SWdp8MgNxiCFTyLeSe)yLG5aHo8MgNxiCFTyLeSe)yLG5aH4w8Sqow19q00borau0HhoeHyAKP9LWl7abDBb2PI8xEanBQaMQdU2sGRfDssf7ct(vN1sV8)TB1Kuh83lvcli5PACGOoIPrM2xcVSde0TfyNkYF5b0SPcyQo4AlPIDHj)hQ)hLxK)YdOztfWuDW1wYlvMnMeWyOP5AXkjyj(XkbZmestty7yDafKQ0p9UWVe)yLODGq30e2jKFqQMk9QJS2uUpH8ds1uPVi5(q)2d3DyHTJ1buqQs)07cVvTL)d1)JYlYF5b0SPcyQo4Al5VSqqGLKkZgtG04PMMtSJ1buqQs)07cpf1ePiC3Hj)hQ)hL3QGVAceLLkqQqGdfljqAX06xIFSs0w(pu)pkVi)LhqZMkGP6GRTK)YcbbwsQmBmbsJNAAcoRnoqKx5H6GOSufE4UL)d1)JYFnrka)fCz3i(L4hRemd7mClvS2WyWT8FO(Fu(dfBHSkg03j(laC2sQ4xIFSsWmSameoIPrM2xcVSde0TfyNkYF5b0SPcyQo4AlPIDHj)Gunv6vhzTPChMd796pOb(xcWFb)2P1ZcVPjSRfRKGL4hReml)hQ)hL)Gg4Fja)f8BNw)s8JvIMg5)q9)O8h0a)lb4VGF706xIFSs0w(pu)pkVi)LhqZMkGP6GRTK)YcbbwsQmBmbsJNc3T8FO(Fu(Rjsb4VGl7gXVe)yLGzyNHBPI1ggdUL)d1)JYFOylKvXG(oXFbGZwsf)s8JvcMHfGHWrmnY0(s4LDGGUTa7ur(lpGMnvat1bxBjvSlm5hKQPsFrY9H(T7UtoS3R35lQZksGZshGo5WEVEw4UddoL(OSubsfcCOyjbslMw)itli10eCwBCGiVYd1brzPQPr(pu)pkVvbF1eiklvGuHahkwsG0IP1Ve)yLOT8FO(FuEr(lpGMnvat1bxBj)LfccSKuz2ycKgp10i)hQ)hL3QGVAceLLkqQqGdfljqAX06xIFSs0(8qchX0it7lHx2bc62cStzfeWsIxLA4jywjKlBooqe4SzNkz5bDkOjjvSlm4u6JYsfiviWHILeiTyA9JmTGutJZleUVwSscwIFSsWmdHGyAKP9LWl7abDBb2PSccyjXRsn8eSuHaxBfjqyXgKk2fgCk9rzPcKke4qXscKwmT(rMwqQPr(pu)pkVvbF1eiklvGuHahkwsG0IP1Ve)yLODOgI7RfRKGL4hReTppKqAACEHW91IvsWs8JvcMzieetJmTVeEzhiOBlWo9yNurKFrQyxyWP0hLLkqQqGdfljqAX06hzAbPMgNxiCFTyLeSe)yLGzgcbX0it7lHx2bc62cStJHMUn5VcGZ0JjvSlm4u6JYsfiviWHILeiTyA9JmTGutJZleUVwSscwIFSsWmdHGyAKP9LWl7abDBb2PSccyjXRsn8eS(st)AlbcscbbPIDHDIGZAJde5JYsf4laRGa5ALAkBAK)d1)JYBvWxnbIYsfiviWHILeiTyA9lXpwjAZqiUHtPpklvGuHahkwsG0IP1Ve)yLGzgcPPj4S24arELhQdIYsfIPrM2xcVSde0TfyNYkiGLeVk1WtWekt)pI3rahKFs8QyxyWP0hLLkqQqGdfljqAX06hzAbPMgNxiCFTyLeSe)yLGzgcPP5elBr3FJjVvbF10kaDcYIvsetJmTVeEzhiOBlWoLvqaljEvQHNGLke4ARibcl2GuXUWGtPpklvGuHahkwsG0IP1Ve)yLODGq30i)hQ)hL3QGVAceLLkqQqGdfljqAX06xIFSs0oudX91IvsWs8JvI2NhsinnoVq4(AXkjyj(XkbZmecIPrM2xcVSde0TfyNYkiGLeVqf7c7ebN1ghiYhLLkWxawbbY1k1u20i)hQ)hL3QGVAceLLkqQqGdfljqAX06xIFSs0MHqAAcoRnoqKx5H6GOSuHyAKP9LWl7abDBb2P5Zkva)fOEw(rf7c7AXkjyj(Xkr7ZiKMg4u6JYsfiviWHILeiTyA9JmTGuttWzTXbI8kpuheLLQMgNxiCFTyLeSe)yLG5aHkIPrM2xcVSde0TfyN6a9FhCz3iQyxyY)H6)r5Tk4RMarzPcKke4qXscKwmT(L4hReTppKMMGZAJde5vEOoiklvnnoVq4(AXkjyj(XkbZmecIPrM2xcVSde0TfyN6qRGw1wfRIDHj)hQ)hL3QGVAceLLkqQqGdfljqAX06xIFSs0(8qAAcoRnoqKx5H6GOSu1048cH7RfRKGL4hRemhi0iMgzAFj8Yoqq3wGDkKfRKcaJIThZtvIyAKP9LWl7abDBb2PxBjhO)7QyxyY)H6)r5Tk4RMarzPcKke4qXscKwmT(L4hReTppKMMGZAJde5vEOoiklvnnoVq4(AXkjyj(XkbZbcbX0it7lHx2bc62cStNssIChiGCGGuXUWK)d1)JYBvWxnbIYsfiviWHILeiTyA9lXpwjAFEinnbN1ghiYR8qDquwQAACEHW91IvsWs8JvcMzieetJmTVeEzhiOBlWo1zIb)fKRjvluXUWCyVxVi)LhqZMkGP6GRTKV)hfIPrM2xcVSde0TfyNEHiHICNBQIDH5WEVEbTuzzeF)pk3oS3R35lQZksGZshGo5WEV((FuUDyVxVZxuNvKaNLo89)OChM4zHCSQ7HZkswicqll80(QPr8Sqow19bFOjniciEOGuLHRIvjTll8ey88u3MKGfqfRsAxw4jig6DgiybuXQK2LfEcSlmXZc5yv3h8HM0GiG4HcsvIycX0it7lHx2bcAPYYiWcoRnoqKk1WtWe0sLLraoSRiv5HdtqPkbhiwcM8FO(FuEbTuzze)s8JvcMd00aNsFuwQaPcbouSKaPftRFKPfKCl)hQ)hLxqlvwgXVe)yLO95H0048cH7RfRKGL4hRemZqiiMgzAFj8YoqqlvwgPfyNAvWxnbIYsfiviWHILeiTyAvXUWorWzTXbI8kpuheLLQMgNxiCFTyLeSe)yLGzgcnIPrM2xcVSde0sLLrAb2Poq)3bx2nIk2fwWzTXbI8cAPYYiah2vKiMgzAFj8YoqqlvwgPfyN6qRGw1wfRIDHfCwBCGiVGwQSmcWHDfjIPrM2xcVSde0sLLrAb2PqwSskamk2EmpvjIPrM2xcVSde0sLLrAb2PxBjhO)7QyxybN1ghiYlOLklJaCyxrIyAKP9LWl7abTuzzKwGD6ussK7abKdeKk2fwWzTXbI8cAPYYiah2vKiMgzAFj8YoqqlvwgPfyN6mXG)cY1KQfQyxybN1ghiYlOLklJaCyxrIyAKP9LWl7abTuzzKwGDA(SsfWFbDAsfvSlSRfRKGL4hReTdlGlpexSSfD)nM83jhiq(SsLtwagcj8Mg4u6JYsfiviWHILeiTyA9JmTGK7WoH8ds1uPVi5(q)2BACyVxVZxuNvKaNLo8SWdVPjm5)q9)O8wf8vtGOSubsfcCOyjbslMw)s8JvI2xlwjblXpwjc3Td796D(I6SIe4S0HNfEtJZleUVwSscwIFSsWCGqqmnY0(s4LDGGwQSmslWonFwPc4Va1ZYpQyxyxlwjblXpwjAFgH00aNsFuwQaPcbouSKaPftRFKPfKAACEHW91IvsWs8JvcMdecIPrM2xcVSde0sLLrAb2Ph0a)lb4VGF70QIDHj)hQ)hLFnHvXabBbuBs1(L4hRemtrjjBsG04jetJmTVeEzhiOLklJ0cStTsix2CCGiWzZovYYd6uqtsQyxybN1ghiYlOLklJaCyxr2048cH7RfRKGL4hRemZqiiMgzAFj8YoqqlvwgPfyNYkiGLeVk1WtWsfcCTvKaHfBqQyxybN1ghiYlOLklJaCyxr2048cH7RfRKGL4hRemZqiiMgzAFj8YoqqlvwgPfyNEStQiYVivSlSGZAJde5f0sLLraoSRirmnY0(s4LDGGwQSmslWongA62K)kaotpMuXUWcoRnoqKxqlvwgb4WUIeX0it7lHx2bcAPYYiTa7uwbbSK4vPgEcMqz6)r8oc4G8tIxf7cdoL(OSubsfcCOyjbslMw)itli1048cH7RfRKGL4hRemZqinnNyzl6(Bm5Tk4RMwbOtqwSsIyAKP9LWl7abTuzzKwGDkRGaws8cvSlSteCwBCGiFuwQaFbyfeixRutztJ8FO(FuERc(QjquwQaPcbouSKaPftRFj(XkrBgcPPj4S24arELhQdIYsfIPrM2xcVSde0sLLrAb2P3HGSIaI85HJyAKP9LWl7abTuzzKwGD6DGGOc8BNwetJmTVeEzhiOLklJ0cStD(I6SIe4S0Hk2fMZleUVwSscwIFSsWCGq30eMuXAdJb3HDTyLeSe)yLODOgI7Wct(pu)pkVGwQSmIFj(Xkr7aH004WEVEbTuzzepl8Mg5)q9)O8cAPYYiEw4H7om4u6JYsfiviWHILeiTyA9JmTGutJ8FO(FuERc(QjquwQaPcbouSKaPftRFj(Xkr7aH00eCwBCGiVYd1brzPk8WdVPjSRfRKGL4hRemdludXDyWP0hLLkqQqagzfljqAX06hzAbPMg5)q9)O8wf8vtGOSubsfcCOyjbslMw)s8JvI2xlwjblXpwjcp8WrmnY0(s4LDGGwQSmslWovqlvwgrf7ct(pu)pk)AcRIbc2cO2KQ9lXpwjyMHMgNxiCFTyLeSe)yLG5aHgX0it7lHx2bcAPYYiTa7uNjg8xqUMuTaX0it7lHx2bcAPYYiTa70lejuK7CtvSlmh271lOLklJ47)r52H9E9oFrDwrcCw6a0jh2713)JYTd796D(I6SIe4S0HV)hL7WeplKJvDpCwrYcraAzHN2xnnINfYXQUp4dnPbraXdfKQmCvSkPDzHNaJNN62KeSaQyvs7YcpbXqVZablGkwL0USWtGDHjEwihR6(Gp0KgebepuqQsetiMgzAFj8pCQOf21ej4VGuHahkwsG0IPvfzejebYzJPualGk2fMuX88tuxivS2WohX0it7lH)HtfTTa7ukkCccOmlVk2fwoquLEPIbCyxr6PACGOUBPI55NOUqQyTHDoIPrM2xc)dNkABb2PPftla(aXRImIeIa5SXukGfqf7ct(8opqKRPMClvmp)e1fsfRnmgqmnY0(s4F4urBlWovQyGJjiPIDHjvmp)e1fsfdgdiMgzAFj8pCQOTfyNsrHtqaLz5rmnY0(s4F4urBlWonTyAbWhiEvKrKqeiNnMsbSaQyxysfZZprDHuXAdJbetiMgzAFj8cAPYYiWUMifG)cUSBevSlmh271lOLklJ4xIFSsWCaetJmTVeEbTuzzKwGDQaUvLvXa5ofbuBs1QyxyYN35bICn1K7WgzAbjaveVrI2WoVPzKPfKaur8gjAhW9jK)d1)JYVMWQyGGTaQnPApl8WrmnY0(s4f0sLLrAb2PRjSkgiylGAtQwfzejebYzJPualGk2fM85DEGixtnHyAKP9LWlOLklJ0cStVMifG)cUSBevSlSrMwqcqfXBKOnSZrmnY0(s4f0sLLrAb2Pc4wvwfdK7ueqTjvRIDHjFENhiY1utUDyVxFFkjb(lqQymkZZchX0it7lHxqlvwgPfyN6ans1pBcuBs1QiJiHiqoBmLcybuXUWKpVZde5AQj3oS3R)Gg4Fja)f8BNwplC3Y)H6)r5xtyvmqWwa1MuTFj(XkrBgqmnY0(s4f0sLLrAb2PxtKcWFbx2nIkwL0USWtGDHDc5)q9)O8RjSkgiylGAtQ2ZchX0it7lHxqlvwgPfyNkGBvzvmqUtra1MuTk2fM85DEGixtn5UtoS3R35lQZksGZshGo5WEVEw4iMgzAFj8cAPYYiTa70RjsWFbPcbouSKaPftRkYisicKZgtPawavSlmPIX85iMgzAFj8cAPYYiTa7uhOrQ(ztGAtQwfzejebYzJPualGk2fM85DEGixtn10CICGOk9kwcKpVZJyAKP9LWlOLklJ0cStfWTQSkgi3PiGAtQgXeIPrM2xcViHDOylKvXG(oXFbGZwsfvSlSWCyVxp814)TBdea(NuL2a5f5ivZ8z004WEVENVOoRibolD4xIFSsWS8FO(Fu(1ewfdeSfqTjv7xIFSs42H9E9oFrDwrcCw6WZc3nCk9rzPcKke4qXscKwmT(rMwqkC3HTJ1buqQs)07cVvTL)d1)JYFOylKvXG(oXFbGZwsfFNDN0(6KfI3L30iGtqqGC2ykfTdeoIPrM2xcViBb2PurBSDsBvmGGSO2QIDHjvmp)e1fsfRnmgCtfTXr8PXtG8b8t02N30ivmp)e1fsfRnmxYDyurBCeFA8eiFa)eTndnnNa(sbbXYUpGpTyAbWhi(WrmnY0(s4fzlWova3QYQyGCNIaQnPAvSlm5Z78arUMAYTd7967tjjWFbsfJrzEw4UdBhRdOGuL(P3fERA7WEV((usc8xGuXyuMFj(XkHlyOPzhRdOGuL(P3fEw4HJyAKP9LWlYwGD6fIekYDUPkwL0USWtGXZtDBscwavSkPDzHNa7cZH9E9bFOjniciEOGuLafw(PER7zH30qfTXr8PXtG8b8tuMpVPr(pu)pk)AcRIbc2cO2KQ9lXpwjyMHMg5)q9)O8xtKcWFbx2nIFj(XkbZmOIDHjEwihR6(Gp0KgebepuqQs3oS3RxK)YdOztfWuDW1wY3)JYDNCyVxVZxuNvKaNLoaDYH9E99)OqmnY0(s4fzlWoDnHvXabBbuBs1QiJiHiqoBmLcybuXUWK)d1)JYlOLklJ4xIFSs0oqtZjYbIQ0lOLklJ4om5)q9)O8h0a)lb4VGF706xIFSs02LAAoH8ds1uPxDK1MkCetJmTVeEr2cStVMifG)cUSBevSlSW2X6akivPF6DH3Q2Y)H6)r5VMifG)cUSBeFNDN0(6KfI3L30SJ1buqQs)07cpl8WDhgv0ghXNgpbYhWprBtrjjBsG04jxeOPrQyE(jQlKkgZWc004WEVEr(lpGMnvat1bxBj)s8JvcMPOKKnjqA8ulbcVP5AXkjyj(XkbZuusYMeinEQLannDYH9E9oFrDwrcCw6a0jh271ZcVPXH9E9WxJ)3Unqa4)bTEw4iMgzAFj8ISfyNk3rQgYQyaJA6eaYIvYYQyvSlmh271NkeG4Ht7VcGCGpsl)1lYrQUDGZWnv0ghXNgpbYhWprBtrjjBsG04jxeWT8FO(Fu(1ewfdeSfqTjv7xIFSs0MIss2KaPXtnnoS3RpviaXdN2Ffa5aFKw(RxKJuD7aUK7WK)d1)JYlOLklJ4xIFSsWCODNdevPxqlvwgPPr(pu)pk)bnW)sa(l43oT(L4hRemhA3YpivtLE1rwBQMMRfRKGL4hRemh6WrmnY0(s4fzlWoDzfkwfdyutNahw1vXUWCyVx)YkuSkgWOMoboSQ77)r5EKPfKaur8gjAhaX0it7lHxKTa70RjsWFbPcbouSKaPftRkYisicKZgtPawavSlmPIX85iMgzAFj8ISfyNsrHtqaLz5vXUWKkMNFI6cPI1gwaetJmTVeEr2cStLkgWHDfPk2fMuX88tuxivS2Wc4EKPfKaur8gjGfW9owhqbPk9tVl8w1MHqAAKkMNFI6cPI1ggdUhzAbjaveVrI2WyaX0it7lHxKTa7uPIboMGKk2f2jCyVxp814)TBdea(FqRNfoIPrM2xcViBb2PPftla(aXRImIeIa5SXukGfqf7ct(8opqKRPMClvmp)e1fsfRnmgC7WEVEr(lpGMnvat1bxBjF)pketJmTVeEr2cStfWTQSkgi3PiGAtQwf7cZH9E9sfdqfTXr8ICKQBFEiUi0NSrMwqcqfXBKWTd796f5V8aA2ubmvhCTL89)OChM8FO(Fu(1ewfdeSfqTjv7xIFSs0Mb3Y)H6)r5VMifG)cUSBe)s8JvI2m00i)hQ)hLFnHvXabBbuBs1(L4hRemFUB5)q9)O8xtKcWFbx2nIFj(Xkr7ZDlvS2N30i)hQ)hLFnHvXabBbuBs1(L4hReTp3T8FO(Fu(Rjsb4VGl7gXVe)yLG5ZDlvS2UutJuX88tuxivmMHfWnv0ghXNgpbYhWprzMHWBACyVxVuXaurBCeVihP62bcX91IvsWs8JvcMzKqmnY0(s4fzlWo1bAKQF2eO2KQvrgrcrGC2ykfWcOIDHjFENhiY1utUdlhiQsVGwQSmIB5)q9)O8cAPYYi(L4hRemFEtJ8FO(Fu(1ewfdeSfqTjv7xIFSs0oGB5)q9)O8xtKcWFbx2nIFj(Xkr7annY)H6)r5xtyvmqWwa1MuTFj(XkbZN7w(pu)pk)1ePa8xWLDJ4xIFSs0(C3sfRndnnY)H6)r5xtyvmqWwa1MuTFj(Xkr7ZDl)hQ)hL)AIua(l4YUr8lXpwjy(C3sfR95nnsfRDOBACyVxVZRgaFFPNfE4iMgzAFj8ISfyNMwmTa4deVkYisicKZgtPawavSlm5Z78arUMAYTuX88tuxivS2WyaX0it7lHxKTa70zLtrG83LQuf7ctQyE(jQlKkwBybqmnY0(s4fzlWo9cfXQyGGw4uLa1MuTkwL0USWtybuXUWoH8ds1uPVi5(q)2BACyVxp814)TBdea(NuL2a5zHJyAKP9LWlYwGDQd0iv)SjqTjvRImIeIa5SXukGfqf7ct(8opqKRPMCl)hQ)hL)AIua(l4YUr8lXpwjy(C3sfdgdUHVuqqSS7d4tlMwa8bI3nv0ghXNgpbYhe6qyoaIPrM2xcViBb2PoqJu9ZMa1MuTkYisicKZgtPawavSlm5Z78arUMAYnv0ghXNgpbYhWprzMb3Hjvmp)e1fsfJzybAAGVuqqSS7d4tlMwa8bIpCetiMgzAFj8h0a)lb4VGF70ctoqqGrM2xaitKQudpbt2bc6QIixtMWcOIDHDICGOk9cAPYYiiMgzAFj8h0a)lb4VGF702cStLdeeyKP9faYePk1WtWKDGGwQSmIkICnzclGk2fwoquLEbTuzzeetJmTVe(dAG)La8xWVDABb2PurBSDsBvmGGSO2QIDHjvmp)e1fsfRnmgCtfTXr8PXtG8b8t02NJyAKP9LWFqd8VeG)c(TtBlWoDnHvXabBbuBs1QiJiHiqoBmLcybqmnY0(s4pOb(xcWFb)2PTfyNEnrka)fCz3iQyxyJmTGeGkI3irBym42H9E9h0a)lb4VGF70coo8lXpwjyoaIPrM2xc)bnW)sa(l43oTTa70dfBHSkg03j(laC2sQOIDHnY0csaQiEJeTHXaIPrM2xc)bnW)sa(l43oTTa7ubCRkRIbYDkcO2KQvXUWKpVZde5AQj3HnY0csaQiEJeTHDUBh271Fqd8VeG)c(Ttl44WZcVPXH9E99PKe4VaPIXOmpl8WrmnY0(s4pOb(xcWFb)2PTfyNsrHtqaLz5vXUWKkgSqC7WEV(dAG)La8xWVDAbhh(L4hRem7siMgzAFj8h0a)lb4VGF702cStVMib)fKke4qXscKwmTQiJiHiqoBmLcybuXUWKkgSqC7WEV(dAG)La8xWVDAbhh(L4hRem7siMgzAFj8h0a)lb4VGF702cStpuSfYQyqFN4VaWzlPcIPrM2xc)bnW)sa(l43oTTa7uhOrQ(ztGAtQwfzejebYzJPualGk2fM85DEGixtn5w(pu)pk)1ePa8xWLDJ4xIFSs4w(pu)pk)AcRIbc2cO2KQ9lXpwjC7WEV(dAG)La8xWVDAbhhEw4iMgzAFj8h0a)lb4VGF702cSttlMwa8bIxfzejebYzJPualGk2fMuXGfIBh271Fqd8VeG)c(Ttl44WVe)yLGzxcX0it7lH)Gg4Fja)f8BN2wGD61ePa8xWLDJOIvjTll8ewavSkPDzHNaJNN62KeSaQyxyoS3R)Gg4Fja)f8BNwWXHNfUBh271lYF5b0SPcyQo4Al5zHJyAKP9LWFqd8VeG)c(TtBlWova3QYQyGCNIaQnPAvSlmh271lvmav0ghXlYrQU95H4IqFYgzAbjaveVrcetJmTVe(dAG)La8xWVDABb2PxtKG)csfcCOyjbslMwvKrKqeiNnMsbSaQyxysfJ5ZrmnY0(s4pOb(xcWFb)2PTfyNsrHtqaLz5vXUWKkMNFI6cPI1gwaetJmTVe(dAG)La8xWVDABb2Psfd4WUIuf7ctQyE(jQlKkwByHfOLrMwqcqfXBKODGWrmnY0(s4pOb(xcWFb)2PTfyNMwmTa4deVkYisicKZgtPawavSlSWoroquLEflbYN35BAKpVZde5AQPWDlvmp)e1fsfRnmgqmnY0(s4pOb(xcWFb)2PTfyN6ans1pBcuBs1QiJiHiqoBmLcybuXUWKpVZde5AQj3JmTGeGkI3ibZWo3TuXAd78Mgh271Fqd8VeG)c(Ttl44WZchX0it7lH)Gg4Fja)f8BN2wGDQuXahtqcX0it7lH)Gg4Fja)f8BN2wGD6fkIvXabTWPkbQnPAvSkPDzHNWcOtDQ1]] )


end