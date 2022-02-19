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

                return app + floor( t - app )
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

                return app + floor( t - app )
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
        pressure_point = {
            id = 337481,
            duration = 5,
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
            id = 152175,
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

        whirling_dragon_punch = {
            id = 196742,
            duration = function () return cooldown.rising_sun_kick.remains end,
            max_stack = 1,
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
            cast = 1.5,
            channeled = true,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.dance_of_chiji_azerite.up or buff.dance_of_chiji.up ) and 0 or weapons_of_order( 2 ) end,
            spendType = "chi",

            startsCombat = true,
            texture = 606543,

            start = function ()
                removeBuff( "dance_of_chiji" )
                removeBuff( "dance_of_chiji_azerite" )
                removeBuff( "chi_energy" )

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


    spec:RegisterPack( "Windwalker", 20211227, [[dS0bKcqiPu1JecQnjGpHcAucjNsi1QecYReIMfH0TOiSlk9lPugMushJIAzOiptjvtdfORjeABsPsFtkvyCcbCouaToLuyEOOUhOSpLKdsreTqPepujLmrPur6IcbQnsre6JkPiDsHazLOqVukveMPsk1nLsfr7Kq8tkIGLQKI4PO0uPi9vLuuJLIO2lP(lWGr6WkwmfEmrtwQUm0MvQpluJMKonvRgfGxtOMni3Me7wYVv1WbvhNIiTCvEoQMUORtW2fOVlfJxqDEbz9sPIA(kX(rS2S2unBFsulctTYetTAUvMSMJamidY06A2meCuZcFKINyuZwJcQzxZE1BgiX4PzHpHG(PRnvZYFHtIAwnRHGdLrqL2qZ2Ne1IWuRmXuRMBLjR5iadYGmPz5WrPweMAxgOMv17DS0gA2oYLA21Sx9MbsmEeA7KFjMWy7uuIkg4rOm1oeLqzQvMmtyKW4APoxmYxdcJMGqnTbhXeQjrNNCc93eQjrHleH6vI3japjuOp2LwcJMGqnTbhXeklCVkVIj016Mcj02jCPycf6JDPLWOjiutYENqnEoF7XQjHkvrPyoHMpHQmvicDTANsOyLNJClHrtqOMK9oH6LjKVIXKeQjriKRkVzNwnlKZtU2un7dhl80MQfXS2unlwJbe21TOzhz6FPz3opb)gKQiOr1teKEmEAw55jE(OzLQUvzctOMGqLQoHUcgHUUMvgscHGCUlgtUM1So1IWK2unlwJbe21TOzLNN45JMnhiSsRu1bgchpTyngqyNqdqOsv3QmHjutqOsvNqxbJqxxZoY0)sZIHHJqa15u0PwK11MQzXAmGWUUfn7it)lnB6X4bGpqkAw55jE(OzLVIXd455IrcnaHkvDRYeMqnbHkvDcDfmcLjnRmKecb5CXyY1IywNAryqTPAwSgdiSRBrZkppXZhnRu1Tktyc1eeQu1juyektA2rM(xAwPQdAMGOo1IerTPA2rM(xAwmmCecOoNIMfRXac76w0PwK2vBQMfRXac76w0SJm9V0SPhJha(aPOzLNN45JMvQ6wLjmHAccvQ6e6kyektAwzijecY5IXKRfXSo1PMTbh4FXb)g8xhpTPArmRnvZI1yaHDDlA2hUMLJPMDKP)LMn4C(yaHA2GdKaQzne2BBdoW)Id(n4VoEGMg7HkJxCcnaHgfHk)hQ)nL9CUxXaUqbe7sX2dvgV4e6kc1qyVTn4a)lo43G)64bAAShQmEXj0aeQHWEBBWb(xCWVb)1Xd00ypuz8ItOmtOmzntOlleQ8FO(3u2Z5Efd4cfqSlfBpuz8ItOMGqne2BBdoW)Id(n4VoEGMg7HkJxCcDfHA2Yaj0aeQHWEBBWb(xCWVb)1Xd00ypuz8ItOmtOmO1mHUSqOgc7T1a6)oKapTcWj0aeQHWEB9k4lgpoOJqESAAfGtObiudH926vWxmECqhH8y10EOY4fNqzMqne2BBdoW)Id(n4VoEGMg7HkJxCcnAnBW5a1OGAwdOrk(fsGyxkgui2XUo1IWK2unlwJbe21TOzLNN45JMT9eAoqyLwoEy5zilwJbe21S88CzQfXSMDKP)LMvoqqGrM(xaiNNAwiNNGAuqnRSd44wNArwxBQMfRXac76w0SYZt88rZMdewPLJhwEgYI1yaHDnlppxMArmRzhz6FPzLdeeyKP)faY5PMfY5jOgfuZk7aoEy5ziDQfHb1MQzXAmGWUUfnR88epF0Ssv3QmHjutqOsvNqxbJqzIqdqOyHxCiB6kiiFGYeMqxrORRzhz6FPzXcVyVD2Ryac5H9tNArIO2unlwJbe21TOzhz6FPzpN7vmGluaXUuSMvgscHGCUym5ArmRtTiTR2unlwJbe21TOzLNN45JMDKPhebyHkoYj0vWiuMi0aeQHWEBBWb(xCWVb)1Xd00ypuz8ItOmtOM1SJm9V0SBNNCWVbBHlKo1I0o0MQzXAmGWUUfnR88epF0SJm9GialuXroHUcgHYKMDKP)LMTr1piVIb9BI)caxOKQ6ulseqBQMfRXac76w0SYZt88rZkFfJhWZZfJeAacDKPhebyHkoYj0vWi01j0aeQHWEBBWb(xCWVb)1Xd00yfGRzhz6FPz5W9Q8kgiVPqGyxkwNAryGAt1Syngqyx3IMDKP)LM1aAKIFHei2LI1SYZt88rZkFfJhWZZfJeAacDKPhebyHkoYjuMHrOmrObi0GZ5JbeAnGgP4xibIDPyqHyh7AwzijecY5IXKRfXSo1IyUvTPAwSgdiSRBrZkppXZhnR8vmEappxmsObiudH922NsIGFdKQodWTcW1SJm9V0SC4EvEfdK3uiqSlfRtTiMnRnvZI1yaHDDlAw55jE(OzLQoHcJqBLqdqOgc7TTbh4FXb)g8xhpqtJ9qLXloHYmHYGA2rM(xAwmmCecOoNIo1IyMjTPAwSgdiSRBrZoY0)sZUDEc(nivrqJQNii9y80SYZt88rZkvDcfgH2kHgGqne2BBdoW)Id(n4VoEGMg7HkJxCcLzcLb1SYqsieKZfJjxlIzDQfX86At1SJm9V0SnQ(b5vmOFt8xa4cLuvZI1yaHDDl6ulIzguBQMfRXac76w0SJm9V0SPhJha(aPOzLNN45JMvQ6ekmcTvcnaHAiS32gCG)fh8BWFD8ann2dvgV4ekZekdQzLHKqiiNlgtUweZ6ulI5iQnvZI1yaHDDlAw55jE(Ozne2Blp)tbGZLQGP6GTFOvaoHgGqVX7amiwPD6DU1lcDfHk)hQ)nLD78Kd(nylCHSDHBs)lcncrOTABxn7it)ln725jh8BWw4cPz9kX7eGNaFRzne2BBdoW)Id(n4VoEGMgRaCDQfXC7QnvZI1yaHDDlAw55jE(Ozne2BRu1byHxCilphPycDfHUEReQji0isOricDKPhebyHkoY1SJm9V0SC4EvEfdK3uiqSlfRtTiMBhAt1Syngqyx3IMDKP)LMD78e8BqQIGgvprq6X4PzLNN45JMvQ6ekZe66AwzijecY5IXKRfXSo1IyocOnvZI1yaHDDlAw55jE(OzLQUvzctOMGqLQoHUcgHAwZoY0)sZIHHJqa15u0PweZmqTPAwSgdiSRBrZkppXZhnRu1Tktyc1eeQu1j0vWi0OiuZeAKe6itpicWcvCKtORiuZeA0A2rM(xAwPQdmeoEQtTim1Q2unlwJbe21TOzhz6FPztpgpa8bsrZkppXZhnBueA7j0CGWkTQEcKVIXBXAmGWoHUSqOYxX4b88CXiHgnHgGqLQUvzctOMGqLQoHUcgHYKMvgscHGCUym5ArmRtTimzwBQMfRXac76w0SJm9V0SgqJu8lKaXUuSMvEEINpA2rMEqeGfQ4iNqzggHUoHgGqLQoHUcgHUoHUSqOgc7TTbh4FXb)g8xhpqtJvaUMvgscHGCUym5ArmRtTimXK2un7it)lnRu1bntquZI1yaHDDl6ulctRRnvZ6vI3jap1SM1SJm9V0SBOqEfd44bhRei2LI1Syngqyx3Io1PMLJhwEgsBQweZAt1Syngqyx3IMvEEINpAwdH92YXdlpdzpuz8ItOmtOM1SJm9V0SBNNCWVbBHlKo1IWK2unlwJbe21TOzLNN45JMv(kgpGNNlgj0aeAue6itpicWcvCKtORGrORtOlle6itpicWcvCKtORiuZeAacT9eQ8FO(3u2Z5Efd4cfqSlfBfGtOrRzhz6FPz5W9Q8kgiVPqGyxkwNArwxBQMfRXac76w0SJm9V0SNZ9kgWfkGyxkwZkppXZhnR8vmEappxmQzLHKqiiNlgtUweZ6ulcdQnvZI1yaHDDlAw55jE(Ozhz6brawOIJCcDfmcDDn7it)ln725jh8BWw4cPtTiruBQMfRXac76w0SYZt88rZkFfJhWZZfJeAac1qyVT9PKi43aPQZaCRaCn7it)lnlhUxLxXa5nfce7sX6uls7QnvZI1yaHDDlA2rM(xAwdOrk(fsGyxkwZkppXZhnR8vmEappxmsObiudH922Gd8V4GFd(RJNvaoHgGqL)d1)MYEo3RyaxOaIDPy7HkJxCcDfHYKMvgscHGCUym5ArmRtTiTdTPAwVs8ob4jW3AwdH92YXdlpdzfGhq(pu)Bk75CVIbCHci2LITho9qA2rM(xA2TZto43GTWfsZI1yaHDDl6ulseqBQMfRXac76w0SYZt88rZkFfJhWZZfJeAacTJgc7T14lSlWtGXHnGoAiS3wb4A2rM(xAwoCVkVIbYBkei2LI1PwegO2unlwJbe21TOzhz6FPz3opb)gKQiOr1teKEmEAw55jE(OzLQoHYmHUUMvgscHGCUym5ArmRtTiMBvBQMfRXac76w0SJm9V0SgqJu8lKaXUuSMvEEINpAw5Ry8aEEUyKqxwi02tO5aHvAv9eiFfJ3I1yaHDnRmKecb5CXyY1IywNArmBwBQMDKP)LMLd3RYRyG8McbIDPynlwJbe21TOtDQzLDahpS8mK2uTiM1MQzXAmGWUUfn7dxZYXuZoY0)sZgCoFmGqnBWbsa1SY)H6Ftz54HLNHShQmEXjuMjuZe6YcHchtBybSaPkcAu9ebPhJNDKPhej0aeQ8FO(3uwoEy5zi7HkJxCcDfHUERe6YcHA8CoHgGq3ESAcouz8ItOmtOm1QMn4CGAuqnlhpS8meWq44Po1IWK2unlwJbe21TOzLNN45JMT9eAW58XacTQpuhewalcDzHqnEoNqdqOBpwnbhQmEXjuMjuMIOMDKP)LM1RGVyeewalDQfzDTPAwSgdiSRBrZkppXZhnBW58XacTC8WYZqadHJNA2rM(xAwdO)7GTWfsNAryqTPAwSgdiSRBrZkppXZhnBW58XacTC8WYZqadHJNA2rM(xAwd844j2RyDQfjIAt1SJm9V0SqESAYbmaHEScwPMfRXac76w0PwK2vBQMfRXac76w0SYZt88rZgCoFmGqlhpS8meWq44PMDKP)LMD7hAa9FxNArAhAt1Syngqyx3IMvEEINpA2GZ5JbeA54HLNHagchp1SJm9V0StjrEEdeqoqq6ulseqBQMfRXac76w0SYZt88rZgCoFmGqlhpS8meWq44PMDKP)LM1yIb)gKNlfZ1PwegO2unlwJbe21TOzLNN45JMD7XQj4qLXloHUIqJIqnhbALqnbHEcfU)lgT7jhiq(csvlwJbe2j0ieHAMPwj0Oj0LfcfoM2Wcybsve0O6jcspgp7itpisObi0Oi02tOYpiwtL2cL3d9xNqxwiudH92A8f2f4jW4WgRaCcnAcDzHqJIqL)d1)MY6vWxmcclGfivrqJQNii9y8ShQmEXj0ve62JvtWHkJxCcnAcnaHAiS3wJVWUapbgh2yfGtOlleQXZ5eAacD7XQj4qLXloHYmHAUvn7it)lnB(csvWVbDCsvDQfXCRAt1Syngqyx3IMvEEINpAw5)q9VPSNZ9kgWfkGyxk2EOY4fNqzMqXWOuirq6kOMDKP)LMTbh4FXb)g8xhpDQfXSzTPAwSgdiSRBrZkppXZhnBW58XacTC8WYZqadHJNA2rM(xAwV4YtihdieysfMkfuaDmOlrDQfXmtAt1Syngqyx3IMvEEINpA2GZ5JbeA54HLNHagchp1SJm9V0Sn3KQ88luNArmVU2unlwJbe21TOzLNN45JMn4C(yaHwoEy5ziGHWXtn7it)lnBm009j)JdmMEmQtTiMzqTPAwSgdiSRBrZoY0)sZYvN(3eFdhoi)ev0SYZt88rZchtBybSaPkcAu9ebPhJNDKPhej0Lfc145CcnaHU9y1eCOY4fNqzMqzQvcDzHqBpHEcfU)lgTEf8fJhh0ripwnTyngqyxZwJcQz5Qt)BIVHdhKFIk6ulI5iQnvZI1yaHDDlAw55jE(OzBpHgCoFmGqBybSaFbe4iipVeJjHUSqOY)H6Ftz9k4lgbHfWcKQiOr1teKEmE2dvgV4e6kcLPwj0Lfcn4C(yaHw1hQdclGLMDKP)LMvGJaprfUo1IyUD1MQzhz6FPz3dc5fc45RaxZI1yaHDDl6ulI52H2un7it)ln7EGGWc8xhpnlwJbe21TOtTiMJaAt1Syngqyx3IMvEEINpAwJNZj0ae62JvtWHkJxCcLzc1Cej0LfcnkcvQ6e6kyekteAacnkcD7XQj4qLXloHUIqB3wj0aeAueAueQ8FO(3uwoEy5zi7HkJxCcDfHAUvcDzHqne2BlhpS8mKvaoHUSqOY)H6Ftz54HLNHScWj0Oj0aeAuekCmTHfWcKQiOr1teKEmE2rMEqKqxwiu5)q9VPSEf8fJGWcybsve0O6jcspgp7HkJxCcDfHAUvcDzHqdoNpgqOv9H6GWcyrOrtOrtOrtOlleAue62JvtWHkJxCcLzyeA72kHgGqJIqHJPnSawGufbRzvprq6X4zhz6brcDzHqL)d1)MY6vWxmcclGfivrqJQNii9y8ShQmEXj0ve62JvtWHkJxCcnAcnAcnAn7it)lnRXxyxGNaJdB0PweZmqTPAwSgdiSRBrZkppXZhnR8FO(3u2Z5Efd4cfqSlfBpuz8ItOmtOmrOlleQXZ5eAacD7XQj4qLXloHYmHAoIA2rM(xAwoEy5ziDQfHPw1MQzhz6FPznMyWVb55sXCnlwJbe21TOtTimzwBQMfRXac76w0SYZt88rZYFbidV6w4c8uacb4jap9VSyngqyNqdqOgc7TLJhwEgY2)MIqdqOD0qyVTgFHDbEcmoSb0rdH922)MIqdqOgc7T14lSlWtGXHn2(3uA2rM(xA2neYvL3StDQtnlp1MQfXS2unlwJbe21TOzLNN45JM9gVdWGyL2P35wVi0veQ8FO(3u2gv)G8kg0Vj(laCHsQA7c3K(xeAeIqB1gbi0Lfc9gVdWGyL2P35wb4A2rM(xA2gv)G8kg0Vj(laCHsQQtTimPnvZI1yaHDDlAw55jE(OzLQUvzctOMGqLQoHUcgHYeHgGqXcV4q20vqq(aLjmHUIqxNqxwiuPQBvMWeQjiuPQtORGrOmiHgGqJIqXcV4q20vqq(aLjmHUIqzIqxwi02tOWpmiiw2TMTPhJha(aPqOrRzhz6FPzXcVyVD2Ryac5H9tNArwxBQMfRXac76w0SYZt88rZkFfJhWZZfJeAac1qyVT9PKi43aPQZaCRaCcnaHgfHEJ3byqSs707CRxe6kc1qyVT9PKi43aPQZaC7HkJxCc1eekte6YcHEJ3byqSs707CRaCcnAn7it)lnlhUxLxXa5nfce7sX6ulcdQnvZI1yaHDDlAw55jE(Oz5VaKHxDBWhAshcb8hkiwPfRXac7eAac1qyVT88pfaoxQcMQd2(H2(3ueAacTJgc7T14lSlWtGXHnGoAiS32(3uAwVs8ob4jW3AwdH92g8HM0Hqa)HcIvcufuM69Uva(Ycw4fhYMUccYhOmHzE9Lf5)q9VPSNZ9kgWfkGyxk2EOY4fNzMwwK)d1)MYUDEYb)gSfUq2dvgV4mZKM1ReVtaEcCffS7tIAwZA2rM(xA2neYvL3StDQfjIAt1Syngqyx3IMDKP)LM9CUxXaUqbe7sXAw55jE(OzL)d1)MYYXdlpdzpuz8ItORiuZe6YcH2EcnhiSslhpS8mKfRXac7eAacnkcv(pu)BkBdoW)Id(n4VoE2dvgV4e6kcLbj0LfcT9eQ8dI1uPvCOZNIqJwZkdjHqqoxmMCTiM1PwK2vBQMfRXac76w0SYZt88rZgfHEJ3byqSs707CRxe6kcv(pu)Bk725jh8BWw4cz7c3K(xeAeIqB1gbi0Lfc9gVdWGyL2P35wb4eA0eAacnkcfl8Idztxbb5duMWe6kcfdJsHebPRGeQjiuZe6YcHkvDRYeMqnbHkvDcLzyeQzcDzHqne2Blp)tbGZLQGP6GTFO9qLXloHYmHIHrPqIG0vqcnsc1mHgnHUSqOBpwnbhQmEXjuMjummkfseKUcsOrsOMj0LfcTJgc7T14lSlWtGXHnGoAiS3wb4A2rM(xA2TZto43GTWfsNArAhAt1Syngqyx3IMvEEINpAwdH92MQiavGJ3FCGCGpsp)ZYZrkMqxrOMzGeAacfl8Idztxbb5duMWe6kcfdJsHebPRGeQjiuZeAacv(pu)Bk75CVIbCHci2LIThQmEXj0vekggLcjcsxbj0Lfc1qyVTPkcqf449hhih4J0Z)S8CKIj0veQzgKqdqOrrOY)H6Ftz54HLNHShQmEXjuMj0isObi0CGWkTC8WYZqwSgdiStOlleQ8FO(3u2gCG)fh8BWFD8ShQmEXjuMj0isObiu5heRPsR4qNpfHUSqOBpwnbhQmEXjuMj0isOrRzhz6FPzL3ifd5vmGbmDea5XQz5vSo1Ieb0MQzXAmGWUUfnR88epF0Sgc7T9e4QEfdyathbnE1T9VPi0ae6itpicWcvCKtORiuZA2rM(xA2tGR6vmGbmDe04vxNAryGAt1Syngqyx3IMDKP)LMD78e8BqQIGgvprq6X4PzLNN45JMvQ6ekZe66AwzijecY5IXKRfXSo1IyUvTPAwSgdiSRBrZkppXZhnRu1Tktyc1eeQu1j0vWiuZA2rM(xAwmmCecOoNIo1Iy2S2unlwJbe21TOzLNN45JMvQ6wLjmHAccvQ6e6kyeQzcnaHoY0dIaSqfh5ekmc1mHgGqVX7amiwPD6DU1lcDfHYuRe6YcHkvDRYeMqnbHkvDcDfmcLjcnaHoY0dIaSqfh5e6kyektA2rM(xAwPQdmeoEQtTiMzsBQMDKP)LMvQ6GMjiQzXAmGWUUfDQfX86At1Syngqyx3IMDKP)LMn9y8aWhifnR88epF0SYxX4b88CXiHgGqLQUvzctOMGqLQoHUcgHYeHgGqne2Blp)tbGZLQGP6GTFOT)nLMvgscHGCUym5ArmRtTiMzqTPAwSgdiSRBrZkppXZhnRHWEBLQoal8Idz55iftORi01BLqnbHgrcncrOJm9GialuXroHgGqne2Blp)tbGZLQGP6GTFOT)nfHgGqJIqL)d1)MYEo3RyaxOaIDPy7HkJxCcDfHYeHgGqL)d1)MYUDEYb)gSfUq2dvgV4e6kcLjcDzHqL)d1)MYEo3RyaxOaIDPy7HkJxCcLzcDDcnaHk)hQ)nLD78Kd(nylCHShQmEXj0ve66eAacvQ6e6kcDDcDzHqL)d1)MYEo3RyaxOaIDPy7HkJxCcDfHUoHgGqL)d1)MYUDEYb)gSfUq2dvgV4ekZe66eAacvQ6e6kcLbj0LfcvQ6wLjmHAccvQ6ekZWiuZeAacfl8Idztxbb5duMWekZekteA0e6YcHAiS3wPQdWcV4qwEosXe6kc1CReAacD7XQj4qLXloHYmH2o0SJm9V0SC4EvEfdK3uiqSlfRtTiMJO2unlwJbe21TOzhz6FPznGgP4xibIDPynR88epF0SYxX4b88CXiHgGqJIqZbcR0YXdlpdzXAmGWoHgGqL)d1)MYYXdlpdzpuz8ItOmtORtOlleQ8FO(3u2Z5Efd4cfqSlfBpuz8ItORiuZeAacv(pu)Bk725jh8BWw4czpuz8ItORiuZe6YcHk)hQ)nL9CUxXaUqbe7sX2dvgV4ekZe66eAacv(pu)Bk725jh8BWw4czpuz8ItORi01j0aeQu1j0vekte6YcHk)hQ)nL9CUxXaUqbe7sX2dvgV4e6kcDDcnaHk)hQ)nLD78Kd(nylCHShQmEXjuMj01j0aeQu1j0ve66e6YcHkvDcDfHgrcDzHqne2BRXlga)EPvaoHgTMvgscHGCUym5ArmRtTiMBxTPAwSgdiSRBrZoY0)sZMEmEa4dKIMvEEINpAw5Ry8aEEUyKqdqOsv3QmHjutqOsvNqxbJqzsZkdjHqqoxmMCTiM1PweZTdTPAwSgdiSRBrZkppXZhnRu1Tktyc1eeQu1j0vWiuZA2rM(xA25KtHG8VdRuNArmhb0MQz9kX7eGNAwZA2rM(xA2nuiVIbC8GJvce7sXAwSgdiSRBrNArmZa1MQzXAmGWUUfn7it)lnRb0if)cjqSlfRzLNN45JMv(kgpGNNlgj0aeQ8FO(3u2TZto43GTWfYEOY4fNqzMqxNqdqOsvNqHrOmrObiu4hgeel7wZ20JXdaFGui0aekw4fhYMUccYheXwjuMjuZAwzijecY5IXKRfXSo1IWuRAt1Syngqyx3IMDKP)LM1aAKIFHei2LI1SYZt88rZkFfJhWZZfJeAacfl8Idztxbb5duMWekZekteAacnkcvQ6wLjmHAccvQ6ekZWiuZe6YcHc)WGGyz3A2MEmEa4dKcHgTMvgscHGCUym5ArmRtDQzLDah3At1IywBQMfRXac76w0SYZt88rZ2Ecn4C(yaHw1hQdclGfHgGqJIqL)d1)MYEo3RyaxOaIDPy7HkJxCcLzcLjcDzHqBpHk)GynvAfh68Pi0Oj0aeAueA7ju5heRPsBHY7H(RtOlleQ8FO(3uwJVWUapbgh2ypuz8ItOmtOmrOrtOlle62JvtWHkJxCcLzcLPiQzhz6FPz9k4lgbHfWsNArysBQMfRXac76w0SYZt88rZU9y1eCOY4fNqxrOrrOMJaTsOMGqpHc3)fJ29KdeiFbPQfRXac7eAeIqnZuReA0e6YcHAiS3wE(NcaNlvbt1bB)qB)BkcnaHchtBybSaPkcAu9ebPhJNDKPhej0aeAueA7ju5heRPsBHY7H(RtOlleQHWEBn(c7c8eyCyJvaoHgnHUSqOrrOY)H6Ftz9k4lgbHfWcKQiOr1teKEmE2dvgV4e6kcD7XQj4qLXloHgnHgGqne2BRXxyxGNaJdBScWj0Lfc145CcnaHU9y1eCOY4fNqzMqn3QMDKP)LMnFbPk43GooPQo1ISU2unlwJbe21TOzLNN45JMnkc9gVdWGyL2P35wVi0vekdgrcDzHqVX7amiwPD6DUvaoHgnHgGqL)d1)MYEo3RyaxOaIDPy7HkJxCcLzcfdJsHebPRGeAacv(pu)BkRxbFXiiSawGufbnQEIG0JXZEOY4fNqxrOrrOm1kHgjHYuReAeIqpHc3)fJwVc(IXJd6iKhRMwSgdiStOrtOlleQXZ5eAacD7XQj4qLXloHYmHUEe1SJm9V0Sn4a)lo43G)64PtTimO2unlwJbe21TOzLNN45JMv(kgpGNNlgj0aeAue6nEhGbXkTtVZTErORiuZTsOlle6nEhGbXkTtVZTcWj0O1SJm9V0S7bH8cb88vGRtTiruBQMfRXac76w0SYZt88rZEJ3byqSs707CRxe6kcD9wj0Lfc9gVdWGyL2P35wb4A2rM(xA29abHf4VoE6uls7QnvZI1yaHDDlAw55jE(OzLQoHUcgHYeHgGq3ESAcouz8ItORi02TvcnaHgfHk)hQ)nLLN)PaW5svWuDW2p0kvNlg5e6kcTvcDzHqL)d1)MYYZ)ua4CPkyQoy7hApuz8ItORiuZTsOrtObi0Oiu4yAdlGfivrqJQNii9y8SJm9GiHUSqOY)H6Ftz9k4lgbHfWcKQiOr1teKEmE2dvgV4e6kc1CRe6YcHgCoFmGqR6d1bHfWIqJMqxwi0OiuPQtORGrOmrObi0ThRMGdvgV4ekZWi02TvcnaHgfHchtBybSaPkcwZQEIG0JXZoY0dIe6YcHk)hQ)nL1RGVyeewalqQIGgvprq6X4zpuz8ItORi0ThRMGdvgV4eA0eAacnkcv(pu)Bklp)tbGZLQGP6GTFOvQoxmYj0veARe6YcHk)hQ)nLLN)PaW5svWuDW2p0EOY4fNqxrOBpwnbhQmEXj0Lfc1qyVT88pfaoxQcMQd2(Hwb4eA0eA0e6YcHU9y1eCOY4fNqzMqnhrn7it)lnRXxyxGNaJdB0PwK2H2unlwJbe21TOzLNN45JMv(vxWtR8)R71Kyh87nwCpiAXAmGWUMDKP)LMLN)PaW5svWuDW2peS9WtI6ulseqBQMfRXac76w0SYZt88rZk)hQ)nLLN)PaW5svWuDW2p0kvNlg5ekmcLjcDzHq3ESAcouz8ItOmtOm1kHUSqOrrO34DageR0o9o3EOY4fNqxrOMJiHUSqOrrOTNqLFqSMkTIdD(ueAacT9eQ8dI1uPTq59q)1j0Oj0aeAueAue6nEhGbXkTtVZTErORiu5)q9VPS88pfaoxQcMQd2(H2Taee4qP6CXiiDfKqxwi02tO34DageR0o9o3IHDEYj0Oj0aeAueQ8FO(3uwVc(IrqybSaPkcAu9ebPhJN9qLXloHUIqL)d1)MYYZ)ua4CPkyQoy7hA3cqqGdLQZfJG0vqcDzHqdoNpgqOv9H6GWcyrOrtOrtObiu5)q9VPSBNNCWVbBHlK9qLXloHYmmcLbsObiuPQtORGrOmrObiu5)q9VPSnQ(b5vmOFt8xa4cLu1EOY4fNqzggHAMjcnAn7it)lnlp)tbGZLQGP6GTFOo1IWa1MQzXAmGWUUfnR88epF0SYpiwtLwXHoFkcnaHgfHAiS32gCG)fh8BWFD8ScWj0LfcnkcD7XQj4qLXloHYmHk)hQ)nLTbh4FXb)g8xhp7HkJxCcDzHqL)d1)MY2Gd8V4GFd(RJN9qLXloHUIqL)d1)MYYZ)ua4CPkyQoy7hA3cqqGdLQZfJG0vqcnAcnaHk)hQ)nLD78Kd(nylCHShQmEXjuMHrOmqcnaHkvDcDfmcLjcnaHk)hQ)nLTr1piVIb9BI)caxOKQ2dvgV4ekZWiuZmrOrRzhz6FPz55FkaCUufmvhS9d1PweZTQnvZI1yaHDDlAw55jE(OzLFqSMkTfkVh6VoHgGq7OHWEBn(c7c8eyCydOJgc7TvaoHgGqJIqHJPnSawGufbnQEIG0JXZoY0dIe6YcHgCoFmGqR6d1bHfWIqxwiu5)q9VPSEf8fJGWcybsve0O6jcspgp7HkJxCcDfHk)hQ)nLLN)PaW5svWuDW2p0UfGGahkvNlgbPRGe6YcHk)hQ)nL1RGVyeewalqQIGgvprq6X4zpuz8ItORi01BLqJwZoY0)sZYZ)ua4CPkyQoy7hQtTiMnRnvZI1yaHDDlAw55jE(OzHJPnSawGufbnQEIG0JXZoY0dIe6YcHA8CoHgGq3ESAcouz8ItOmtOm1QMDKP)LM1lU8eYXacbMuHPsbfqhd6suNArmZK2unlwJbe21TOzLNN45JMfoM2Wcybsve0O6jcspgp7itpisOlleQXZ5eAacD7XQj4qLXloHYmHYuRA2rM(xA2MBsvE(fQtTiMxxBQMfRXac76w0SYZt88rZchtBybSaPkcAu9ebPhJNDKPhej0Lfc145CcnaHU9y1eCOY4fNqzMqzQvn7it)lnBm009j)JdmMEmQtTiMzqTPAwSgdiSRBrZoY0)sZ2pC6B)qqqKZrinR88epF0STNqdoNpgqOnSawGVacCeKNxIXKqxwiu5)q9VPSEf8fJGWcybsve0O6jcspgp7HkJxCcDfHYuReAacfoM2Wcybsve0O6jcspgp7HkJxCcLzcLPwj0Lfcn4C(yaHw1hQdclGLMTgfuZ2pC6B)qqqKZriDQfXCe1MQzXAmGWUUfn7it)lnlxD6Ft8nC4G8turZkppXZhnlCmTHfWcKQiOr1teKEmE2rMEqKqxwiuJNZj0ae62JvtWHkJxCcLzcLPwj0LfcT9e6ju4(Vy06vWxmECqhH8y10I1yaHDnBnkOMLRo9Vj(goCq(jQOtTiMBxTPAwSgdiSRBrZkppXZhnB7j0GZ5JbeAdlGf4lGahb55Lymj0Lfcv(pu)BkRxbFXiiSawGufbnQEIG0JXZEOY4fNqxrOm1kHUSqObNZhdi0Q(qDqybS0SJm9V0ScCe4jQW1PweZTdTPAwSgdiSRBrZkppXZhn72JvtWHkJxCcDfHYaBLqxwiu4yAdlGfivrqJQNii9y8SJm9GiHUSqObNZhdi0Q(qDqybSi0Lfc145CcnaHU9y1eCOY4fNqzMqn3UA2rM(xA28fKQGFdepNYOtTiMJaAt1Syngqyx3IMvEEINpAw5)q9VPSEf8fJGWcybsve0O6jcspgp7HkJxCcDfHUERe6YcHgCoFmGqR6d1bHfWIqxwiuJNZj0ae62JvtWHkJxCcLzcLPw1SJm9V0Sgq)3bBHlKo1IyMbQnvZI1yaHDDlAw55jE(OzL)d1)MY6vWxmcclGfivrqJQNii9y8ShQmEXj0ve66TsOlleAW58XacTQpuhewalcDzHqnEoNqdqOBpwnbhQmEXjuMjuZruZoY0)sZAGhhpXEfRtTim1Q2un7it)lnlKhRMCadqOhRGvQzXAmGWUUfDQfHjZAt1Syngqyx3IMvEEINpAw5)q9VPSEf8fJGWcybsve0O6jcspgp7HkJxCcDfHUERe6YcHgCoFmGqR6d1bHfWIqxwiuJNZj0ae62JvtWHkJxCcLzc1CRA2rM(xA2TFOb0)DDQfHjM0MQzXAmGWUUfnR88epF0SY)H6Ftz9k4lgbHfWcKQiOr1teKEmE2dvgV4e6kcD9wj0Lfcn4C(yaHw1hQdclGfHUSqOgpNtObi0ThRMGdvgV4ekZektTQzhz6FPzNsI88giGCGG0PweMwxBQMfRXac76w0SYZt88rZAiS3wE(NcaNlvbt1bB)qB)Bkn7it)lnRXed(nipxkMRtTimXGAt1Syngqyx3IMvEEINpAw(laz4v3cxGNcqiapb4P)LfRXac7eAac1qyVT88pfaoxQcMQd2(H2(3ueAacTJgc7T14lSlWtGXHnGoAiS32(3ueAac1qyVTgFHDbEcmoSX2)MsZoY0)sZUHqUQ8MDQtDQz74EeGsTPArmRnvZoY0)sZYHJZbuNQd455IrnlwJbe21TOtTimPnvZI1yaHDDlA2hUMLJPMDKP)LMn4C(yaHA2GdKaQzL)d1)MY6vWxmcclGfivrqJQNii9y8ShQmEXj0ve62JvtWHkJxCcDzHq3ESAcouz8ItOMGqL)d1)MY6vWxmcclGfivrqJQNii9y8ShQmEXjuMjuZm1kHgGqJIqJIqZbcR0YXdlpdzXAmGWoHgGq3ESAcouz8ItORiu5)q9VPSC8WYZq2dvgV4eAacv(pu)BklhpS8mK9qLXloHUIqn3kHgnHUSqOrrOY)H6Ftz55FkaCUufmvhS9dTBbiiWHs15Irq6kiHYmHU9y1eCOY4fNqdqOY)H6Ftz55FkaCUufmvhS9dTBbiiWHs15Irq6kiHUIqnhrcnAcDzHqJIqL)d1)MYYZ)ua4CPkyQoy7hALQZfJCcfgH2kHgGqL)d1)MYYZ)ua4CPkyQoy7hApuz8ItOmtOBpwnbhQmEXj0Oj0O1SbNduJcQzvFOoiSaw6ulY6At1Syngqyx3IMvEEINpA2OiudH92YXdlpdzfGtOlleQHWEB55FkaCUufmvhS9dTcWj0Oj0aekCmTHfWcKQiOr1teKEmE2rMEqKqxwiuJNZj0ae62JvtWHkJxCcLzyeA72QMDKP)LMf(N(x6ulcdQnvZI1yaHDDlAw55jE(Ozne2BlhpS8mKvaUMLNNltTiM1SJm9V0SYbccmY0)ca58uZc58euJcQz54HLNH0PwKiQnvZI1yaHDDlAw55jE(Ozne2BBdoW)Id(n4VoEwb4AwEEUm1IywZoY0)sZkhiiWit)laKZtnlKZtqnkOMTbh4FXb)g8xhpDQfPD1MQzXAmGWUUfnR88epF0SPRGekZekdsObiuPQtOmtOrKqdqOTNqHJPnSawGufbnQEIG0JXZoY0dIAwEEUm1IywZoY0)sZkhiiWit)laKZtnlKZtqnkOM9HJfE6uls7qBQMfRXac76w0SJm9V0SBNNGFdsve0O6jcspgpnR88epF0Ssv3QmHjutqOsvNqxbJqxNqdqOrrOyHxCiB6kiiFGYeMqzMqntOllekw4fhYMUccYhOmHjuMjugKqdqOY)H6Ftz3op5GFd2cxi7HkJxCcLzc1SnIe6YcHk)hQ)nLTbh4FXb)g8xhp7HkJxCcLzcLjcnAcnaH2EcTJgc7T14lSlWtGXHnGoAiS3wb4AwzijecY5IXKRfXSo1Ieb0MQzXAmGWUUfnR88epF0Ssv3QmHjutqOsvNqxbJqntObi0OiuSWloKnDfeKpqzctOmtOMj0Lfcv(pu)BklhpS8mK9qLXloHYmHYeHUSqOyHxCiB6kiiFGYeMqzMqzqcnaHk)hQ)nLD78Kd(nylCHShQmEXjuMjuZ2isOlleQ8FO(3u2gCG)fh8BWFD8ShQmEXjuMjuMi0Oj0aeA7judH92A8f2f4jW4WgRaCn7it)lnlggocbuNtrNAryGAt1Syngqyx3IMDKP)LMn9y8aWhifnR88epF0SYxX4b88CXiHgGqLQUvzctOMGqLQoHUcgHYeHgGqJIqXcV4q20vqq(aLjmHYmHAMqxwiu5)q9VPSC8WYZq2dvgV4ekZekte6YcHIfEXHSPRGG8bktycLzcLbj0aeQ8FO(3u2TZto43GTWfYEOY4fNqzMqnBJiHUSqOY)H6FtzBWb(xCWVb)1XZEOY4fNqzMqzIqJMqdqOTNq7OHWEBn(c7c8eyCydOJgc7TvaUMvgscHGCUym5ArmRtTiMBvBQMfRXac76w0SYZt88rZ2EcnhiSslhpS8mKfRXac7AwEEUm1IywZoY0)sZkhiiWit)laKZtnlKZtqnkOMv2bCCRtTiMnRnvZI1yaHDDlAw55jE(OzZbcR0YXdlpdzXAmGWUMLNNltTiM1SJm9V0SYbccmY0)ca58uZc58euJcQzLDahpS8mKo1IyMjTPAwSgdiSRBrZkppXZhn7itpicWcvCKtOmtORRz555YulIzn7it)lnRCGGaJm9Vaqop1Sqopb1OGAwEQtTiMxxBQMfRXac76w0SYZt88rZoY0dIaSqfh5e6kye66AwEEUm1IywZoY0)sZkhiiWit)laKZtnlKZtqnkOMDEuN6uZc)q5RymP2uTiM1MQzhz6FPzn(mHWoydnHWEJxXG8d7LMfRXac76w0PweM0MQzXAmGWUUfn7dxZYXuZoY0)sZgCoFmGqnBWbsa1SOjvWHdh7wV4YtihdieysfMkfuaDmOlrcDzHqrtQGdho2TXqt3N8poWy6XiHUSqOOjvWHdh72MBsvE(fsOllekAsfC4WXU9dINuDUySdMYvgGXKjEHi0LfcfnPcoC4y3YvN(3eFdhoi)ev0SbNduJcQzdlGf4lGahb55Lym1PwK11MQzhz6FPz3qixvEZo1Syngqyx3Io1IWGAt1Syngqyx3IMvEEINpA22tO5aHvA54HLNHSyngqyNqxwi02tO5aHvA3opb)gKQiOr1teKEmEwSgdiSRzhz6FPzLQoWq44Po1IerTPAwSgdiSRBrZkppXZhnB7j0CGWkTyHxS3o7vmaH8W4zXAmGWUMDKP)LMvQ6GMjiQtDQzNh1MQfXS2un7it)lnBJQFqEfd63e)faUqjv1Syngqyx3Io1IWK2unlwJbe21TOzLNN45JMvQ6wLjmHAccvQ6e6kyekteAacfl8Idztxbb5duMWe6kcLjcDzHqLQUvzctOMGqLQoHUcgHYGA2rM(xAwSWl2BN9kgGqEy)0PwK11MQzXAmGWUUfnR88epF0SYxX4b88CXiHgGqJIqne2BBFkjc(nqQ6ma3kaNqxwi0oAiS3wJVWUapbgh2a6OHWEBfGtOrRzhz6FPz5W9Q8kgiVPqGyxkwNAryqTPAwSgdiSRBrZkppXZhnlw4fhYMUccYhOmHj0vekggLcjcsxbj0LfcvQ6wLjmHAccvQ6ekZWiuZA2rM(xA2TZto43GTWfsNArIO2unlwJbe21TOzhz6FPzpN7vmGluaXUuSMvEEINpA2Oi0CGWkTnQ(b5vmOFt8xa4cLu1I1yaHDcnaHk)hQ)nL9CUxXaUqbe7sX2UWnP)fHUIqL)d1)MY2O6hKxXG(nXFbGlusv7HkJxCcnscLbj0Oj0aeAueQ8FO(3u2TZto43GTWfYEOY4fNqxrORtOlleQu1j0vWi0isOrRzLHKqiiNlgtUweZ6uls7QnvZI1yaHDDlAw55jE(Ozne2B7jWv9kgWaMocA8QB7FtPzhz6FPzpbUQxXagW0rqJxDDQfPDOnvZI1yaHDDlAw55jE(OzLQUvzctOMGqLQoHUcgHAwZoY0)sZIHHJqa15u0PwKiG2unlwJbe21TOzhz6FPz3opb)gKQiOr1teKEmEAw55jE(OzLQUvzctOMGqLQoHUcgHUUMvgscHGCUym5ArmRtTimqTPAwSgdiSRBrZkppXZhnRu1Tktyc1eeQu1j0vWiuM0SJm9V0SsvhyiC8uNArm3Q2unlwJbe21TOzLNN45JM1qyVTPkcqf449hhih4J0Z)S8CKIj0veQzgiHgGqXcV4q20vqq(aLjmHUIqXWOuirq6kiHAcc1mHgGqL)d1)MYUDEYb)gSfUq2dvgV4e6kcfdJsHebPRGA2rM(xAw5nsXqEfdyathbqESAwEfRtTiMnRnvZI1yaHDDlA2rM(xA20JXdaFGu0SYZt88rZkvDRYeMqnbHkvDcDfmcLjcnaHgfH2EcnhiSsRQNa5Ry8wSgdiStOlleQ8vmEappxmsOrRzLHKqiiNlgtUweZ6ulIzM0MQzXAmGWUUfnR88epF0Ssv3QmHjutqOsvNqxbJqnRzhz6FPzNtofcY)oSsDQfX86At1Syngqyx3IMvEEINpAw5Ry8aEEUyKqdqOrrOY)H6Ftzn(c7c8eyCyJ9qLXloHUIqzIqxwi02tOYpiwtL2cL3d9xNqJMqdqOrrOsvNqxbJqJiHUSqOY)H6Ftz3op5GFd2cxi7HkJxCcDfH2Ue6YcHk)hQ)nLD78Kd(nylCHShQmEXj0ve66eAacvQ6e6kye66eAacfl8Idztxbb5dIyRekZeQzcDzHqXcV4q20vqq(aLjmHYmmcnkcDDcnscDDcncrOY)H6Ftz3op5GFd2cxi7HkJxCcLzcnIeA0e6YcHAiS3wE(NcaNlvbt1bB)qRaCcnAn7it)lnlhUxLxXa5nfce7sX6ulIzguBQMfRXac76w0SYZt88rZkFfJhWZZfJA2rM(xAwPQdAMGOo1IyoIAt1Syngqyx3IMDKP)LMDdfYRyahp4yLaXUuSMvEEINpAwdH92A8IbWVxA7FtPz9kX7eGNAwZ6ulI52vBQMfRXac76w0SJm9V0SgqJu8lKaXUuSMvEEINpAw5Ry8aEEUyKqdqOrrOgc7T14fdGFV0kaNqxwi0CGWkTQEcKVIXBXAmGWoHgGqHFyqqSSBnBtpgpa8bsHqdqOsvNqHrOmrObiu5)q9VPSBNNCWVbBHlK9qLXloHYmHUoHUSqOsv3QmHjutqOsvNqzggHAMqdqOWpmiiw2TMTC4EvEfdK3uiqSlftObiuSWloKnDfeKpqzctOmtORtOrRzLHKqiiNlgtUweZ6uN6uZgepU)LweMALjZMzQ12HMTzUYRyUMDnBsUMiseKiRPRbHsOMQIeQRa)VKq3)rOmSbh4FXb)g8xhpgsOhAsf8d7ek)vqcDeYxzsStOs1PIrULW4A7fsOmTge6A9vq8sStOmmhiSsRjZqcnFcLH5aHvAnzlwJbe2ziHojHgbBsyTj0OmhoAlHX12lKqxFni016RG4LyNqzyoqyLwtMHeA(ekdZbcR0AYwSgdiSZqcDscnc2KWAtOrzoC0wcJRTxiHYuRRbHUwFfeVe7ekdZbcR0AYmKqZNqzyoqyLwt2I1yaHDgsOrzoC0wcJegxZMKRjIebjYA6AqOeQPQiH6kW)lj09Fekd54HLNHyiHEOjvWpStO8xbj0riFLjXoHkvNkg5wcJRTxiHAU11GqxRVcIxIDcLH5aHvAnzgsO5tOmmhiSsRjBXAmGWodj0jj0iytcRnHgL5WrBjmsyCnBsUMiseKiRPRbHsOMQIeQRa)VKq3)rOmu2bC8WYZqmKqp0Kk4h2ju(RGe6iKVYKyNqLQtfJClHX12lKqzGRbHUwFfeVe7ekdpHc3)fJwtMHeA(ekdpHc3)fJwt2I1yaHDgsOrzoC0wcJRTxiHAMbxdcDT(kiEj2jugEcfU)lgTMmdj08jugEcfU)lgTMSfRXac7mKqNKqJGnjS2eAuMdhTLW4A7fsOmzEni016RG4LyNqzi)fGm8QBnzgsO5tOmK)cqgE1TMSfRXac7mKqJYC4OTegjmUMnjxtejcsK101Gqjutvrc1vG)xsO7)iugYtgsOhAsf8d7ek)vqcDeYxzsStOs1PIrULW4A7fsOm4AqOR1xbXlXoHYq(laz4v3AYmKqZNqzi)fGm8QBnzlwJbe2ziHgL5WrBjmU2EHeAexdcDT(kiEj2jugMdewP1KziHMpHYWCGWkTMSfRXac7mKqJYC4OTegxBVqcTDSge6A9vq8sStOmmhiSsRjZqcnFcLH5aHvAnzlwJbe2ziHgL5WrBjmU2EHeQ5iUge6A9vq8sStOmmhiSsRjZqcnFcLH5aHvAnzlwJbe2ziHgL5WrBjmsyCnBsUMiseKiRPRbHsOMQIeQRa)VKq3)rOmu2bCCZqc9qtQGFyNq5VcsOJq(ktIDcvQovmYTegxBVqcLP1GqxRVcIxIDcLHNqH7)IrRjZqcnFcLHNqH7)IrRjBXAmGWodj0OmhoAlHX12lKqxFni016RG4LyNqz4ju4(Vy0AYmKqZNqz4ju4(Vy0AYwSgdiSZqcnkZHJ2syCT9cjuZrCni016RG4LyNqz4ju4(Vy0AYmKqZNqz4ju4(Vy0AYwSgdiSZqcDscnc2KWAtOrzoC0wcJRTxiHYedUge6A9vq8sStOmK)cqgE1TMmdj08jugYFbidV6wt2I1yaHDgsOrzoC0wcJegxZMKRjIebjYA6AqOeQPQiH6kW)lj09Fekd74EeGsgsOhAsf8d7ek)vqcDeYxzsStOs1PIrULW4A7fsOmTge6A9vq8sStOmmhiSsRjZqcnFcLH5aHvAnzlwJbe2ziHgL5WrBjmU2EHeQ5wxdcDT(kiEj2jugMdewP1KziHMpHYWCGWkTMSfRXac7mKqNKqJGnjS2eAuMdhTLW4A7fsOMnVge6A9vq8sStOmmhiSsRjZqcnFcLH5aHvAnzlwJbe2ziHojHgbBsyTj0OmhoAlHrcJRztY1erIGeznDniuc1uvKqDf4)Le6(pcLHZJmKqp0Kk4h2ju(RGe6iKVYKyNqLQtfJClHX12lKqJ4AqOR1xbXlXoHYWCGWkTMmdj08jugMdewP1KTyngqyNHeAuMdhTLW4A7fsOMnVge6A9vq8sStOmmhiSsRjZqcnFcLH5aHvAnzlwJbe2ziHgL5WrBjmU2EHeQ52Dni016RG4LyNqzyoqyLwtMHeA(ekdZbcR0AYwSgdiSZqcnkZHJ2syKWyeKc8)sStOmqcDKP)fHc58KBjmQzhHu9pnlRRSwAw43VDiuZgHJWe6A2REZajgpcTDYVetymchHj02POevmWJqzQDikHYuRmzMWiHXiCeMqxl15Ir(AqymchHjutqOM2GJyc1KOZtoH(Bc1KOWfIq9kX7eGNek0h7slHXiCeMqnbHAAdoIjuw4EvEftOR1nfsOTt4sXek0h7slHXiCeMqnbHAs27eQXZ5BpwnjuPkkfZj08juLPcrORv7ucfR8CKBjmgHJWeQjiutYENq9YeYxXysc1KieYvL3StlHrcJr4imHgbhgLcj2judC)hsOYxXysc1aJ9IBjutsPeHNCcT(YeQZPSfGi0rM(xCc9lOqwcJJm9V4w4hkFfJjJewBgFMqyhSHMqyVXRyq(H9IW4it)lUf(HYxXyYiH1wW58XacfTgfewybSaFbe4iipVeJPOpCyCmfn4ajGWqtQGdho2TEXLNqogqiWKkmvkOa6yqxIllOjvWHdh72yOP7t(hhym9yCzbnPcoC4y32CtQYZVWLf0Kk4WHJD7hepP6CXyhmLRmaJjt8cTSGMubhoCSB5Qt)BIVHdhKFIkeghz6FXTWpu(kgtgjS22qixvEZojmoY0)IBHFO8vmMmsyTjvDGHWXtr9nS2NdewPLJhwEgYI1yaH9LL2NdewPD78e8BqQIGgvprq6X4zXAmGWoHXrM(xCl8dLVIXKrcRnPQdAMGOO(gw7ZbcR0IfEXE7SxXaeYdJNfRXac7egjmgHJWeAeCyukKyNqXG4fIqtxbj0ufj0rM)rOoNqNGJdngqOLW4it)lomoCCoG6uDappxmsyCKP)fpsyTfCoFmGqrRrbHP(qDqybSe9HdJJPObhibeM8FO(3uwVc(IrqybSaPkcAu9ebPhJN9qLXl(QThRMGdvgV4llBpwnbhQmEXnH8FO(3uwVc(IrqybSaPkcAu9ebPhJN9qLXloZMzQ1arfvoqyLwoEy5zOaBpwnbhQmEXxj)hQ)nLLJhwEgYEOY4fpG8FO(3uwoEy5zi7HkJx8vMBn6LLOK)d1)MYYZ)ua4CPkyQoy7hA3cqqGdLQZfJG0vqM3ESAcouz8Ihq(pu)Bklp)tbGZLQGP6GTFODlabbouQoxmcsxbxzoIrVSeL8FO(3uwE(NcaNlvbt1bB)qRuDUyKdR1aY)H6Ftz55FkaCUufmvhS9dThQmEXzE7XQj4qLXlE0rtyCKP)fpsyTb)t)lr9nSOme2BlhpS8mKva(YIHWEB55FkaCUufmvhS9dTcWJoaCmTHfWcKQiOr1teKEmE2rMEqCzX458aBpwnbhQmEXzgw72kHXrM(x8iH1MCGGaJm9VaqopfTgfeghpS8mKO88CzcZSO(gMHWEB54HLNHScWjmoY0)IhjS2KdeeyKP)faY5PO1OGWAWb(xCWVb)1XtuEEUmHzwuFdZqyVTn4a)lo43G)64zfGtyCKP)fpsyTjhiiWit)laKZtrRrbH9WXcpr555YeMzr9nS0vqMzWasvN5igO9WX0gwalqQIGgvprq6X4zhz6brcJJm9V4rcRTTZtWVbPkcAu9ebPhJNOYqsieKZfJjhMzr9nmPQBvMWMqQ6RGTEGOWcV4q20vqq(aLjmZMxwWcV4q20vqq(aLjmZmya5)q9VPSBNNCWVbBHlK9qLXloZMTrCzr(pu)BkBdoW)Id(n4VoE2dvgV4mZu0bAFhne2BRXxyxGNaJdBaD0qyVTcWjmoY0)IhjS2WWWriG6CkI6Bysv3QmHnHu1xbZCGOWcV4q20vqq(aLjmZMxwK)d1)MYYXdlpdzpuz8IZmtllyHxCiB6kiiFGYeMzgmG8FO(3u2TZto43GTWfYEOY4fNzZ2iUSi)hQ)nLTbh4FXb)g8xhp7HkJxCMzk6aT3qyVTgFHDbEcmoSXkaNW4it)lEKWAl9y8aWhifrLHKqiiNlgtomZI6ByYxX4b88CXyaPQBvMWMqQ6RGXuGOWcV4q20vqq(aLjmZMxwK)d1)MYYXdlpdzpuz8IZmtllyHxCiB6kiiFGYeMzgmG8FO(3u2TZto43GTWfYEOY4fNzZ2iUSi)hQ)nLTbh4FXb)g8xhp7HkJxCMzk6aTVJgc7T14lSlWtGXHnGoAiS3wb4eghz6FXJewBYbccmY0)ca58u0AuqyYoGJBr555YeMzr9nS2NdewPLJhwEgIW4it)lEKWAtoqqGrM(xaiNNIwJcct2bC8WYZqIYZZLjmZI6By5aHvA54HLNHimoY0)IhjS2KdeeyKP)faY5PO1OGW4PO88CzcZSO(g2itpicWcvCKZ86eghz6FXJewBYbccmY0)ca58u0AuqyZJIYZZLjmZI6ByJm9GialuXr(kyRtyKW4it)lUDEewJQFqEfd63e)faUqjvjmoY0)IBNhJewByHxS3o7vmaH8W(jQVHjvDRYe2esvFfmMcGfEXHSPRGG8bkt4vmTSivDRYe2esvFfmgKW4it)lUDEmsyTXH7v5vmqEtHaXUuSO(gM8vmEappxmgikdH922NsIGFdKQodWTcWxw6OHWEBn(c7c8eyCydOJgc7TvaE0eghz6FXTZJrcRTTZto43GTWfsuFddl8Idztxbb5duMWRWWOuirq6k4YIu1TktytivDMHzMW4it)lUDEmsyTDo3RyaxOaIDPyrLHKqiiNlgtomZI6ByrLdewPTr1piVIb9BI)caxOKQbK)d1)MYEo3RyaxOaIDPyBx4M0)AL8FO(3u2gv)G8kg0Vj(laCHsQApuz8IhjdgDGOK)d1)MYUDEYb)gSfUq2dvgV4RwFzrQ6RGfXOjmoY0)IBNhJewBNax1Ryady6iOXRUO(gMHWEBpbUQxXagW0rqJxDB)BkcJJm9V425XiH1gggocbuNtruFdtQ6wLjSjKQ(kyMjmoY0)IBNhJewBBNNGFdsve0O6jcspgprLHKqiiNlgtomZI6Bysv3QmHnHu1xbBDcJJm9V425XiH1Mu1bgchpf13WKQUvzcBcPQVcgteghz6FXTZJrcRn5nsXqEfdyathbqESAwEflQVHziS32ufbOcC8(JdKd8r65FwEosXRmZadGfEXHSPRGG8bkt4vyyukKiiDf0eMdi)hQ)nLD78Kd(nylCHShQmEXxHHrPqIG0vqcJJm9V425XiH1w6X4bGpqkIkdjHqqoxmMCyMf13WKQUvzcBcPQVcgtbIQ95aHvAv9eiFfJFzr(kgpGNNlgJMW4it)lUDEmsyTnNCkeK)DyLI6Bysv3QmHnHu1xbZmHXrM(xC78yKWAJd3RYRyG8McbIDPyr9nm5Ry8aEEUymquY)H6Ftzn(c7c8eyCyJ9qLXl(kMwwAV8dI1uPTq59q)1JoqusvFfSiUSi)hQ)nLD78Kd(nylCHShQmEXx1UllY)H6Ftz3op5GFd2cxi7HkJx8vRhqQ6RGTEaSWloKnDfeKpiITYS5LfSWloKnDfeKpqzcZmSOwpY1JqY)H6Ftz3op5GFd2cxi7HkJxCMJy0llgc7TLN)PaW5svWuDW2p0kapAcJJm9V425XiH1Mu1bntquuFdt(kgpGNNlgjmoY0)IBNhJewBBOqEfd44bhRei2LIf13Wme2BRXlga)EPT)nLOEL4DcWtyMjmoY0)IBNhJewBgqJu8lKaXUuSOYqsieKZfJjhMzr9nm5Ry8aEEUymqugc7T14fdGFV0kaFzjhiSsRQNa5Ry8bGFyqqSSBnBtpgpa8bsjGu1HXua5)q9VPSBNNCWVbBHlK9qLXloZRVSivDRYe2esvNzyMda)WGGyz3A2YH7v5vmqEtHaXUuCaSWloKnDfeKpqzcZ86rtyKW4it)lUv2bCCdZRGVyeewalqQIGgvprq6X4jQVH1(GZ5JbeAvFOoiSawbIs(pu)Bk75CVIbCHci2LIThQmEXzMPLL2l)GynvAfh68PIoquTx(bXAQ0wO8EO)6llY)H6Ftzn(c7c8eyCyJ9qLXloZmf9YY2JvtWHkJxCMzkIeghz6FXTYoGJ7iH1w(csvWVbDCsvr9nSThRMGdvgV4RIYCeOvtCcfU)lgT7jhiq(cs1iKzMAn6LfdH92YZ)ua4CPkyQoy7hA7FtfaoM2Wcybsve0O6jcspgp7itpigiQ2l)GynvAluEp0F9LfdH92A8f2f4jW4WgRa8OxwIs(pu)BkRxbFXiiSawGufbnQEIG0JXZEOY4fF12JvtWHkJx8OdyiS3wJVWUapbgh2yfGVSy8CEGThRMGdvgV4mBUvcJJm9V4wzhWXDKWARbh4FXb)g8xhpr9nSOUX7amiwPD6DU1RvmyexwUX7amiwPD6DUvaE0bK)d1)MYEo3RyaxOaIDPy7HkJxCMXWOuirq6kya5)q9VPSEf8fJGWcybsve0O6jcspgp7HkJx8vrXuRrYuRrOtOW9FXO1RGVy84Goc5XQz0llgpNhy7XQj4qLXloZRhrcJJm9V4wzhWXDKWABpiKxiGNVcCr9nm5Ry8aEEUymqu34DageR0o9o361kZTUSCJ3byqSs707CRa8OjmoY0)IBLDah3rcRT9abHf4VoEI6By34DageR0o9o361Q1BDz5gVdWGyL2P35wb4eghz6FXTYoGJ7iH1MXxyxGNaJdBe13WKQ(kymfy7XQj4qLXl(Q2T1arj)hQ)nLLN)PaW5svWuDW2p0kvNlg5RADzr(pu)Bklp)tbGZLQGP6GTFO9qLXl(kZTgDGOGJPnSawGufbnQEIG0JXZoY0dIllY)H6Ftz9k4lgbHfWcKQiOr1teKEmE2dvgV4Rm36YsW58XacTQpuhewaROxwIsQ6RGXuGThRMGdvgV4mdRDBnquWX0gwalqQIG1SQNii9y8SJm9G4YI8FO(3uwVc(IrqybSaPkcAu9ebPhJN9qLXl(QThRMGdvgV4rhik5)q9VPS88pfaoxQcMQd2(HwP6CXiFvRllY)H6Ftz55FkaCUufmvhS9dThQmEXxT9y1eCOY4fFzXqyVT88pfaoxQcMQd2(Hwb4rh9YY2JvtWHkJxCMnhrcJJm9V4wzhWXDKWAJN)PaW5svWuDW2peS9WtII6ByYV6cEAL)FDVMe7GFVXI7brlwJbe2jmoY0)IBLDah3rcRnE(NcaNlvbt1bB)qr9nm5)q9VPS88pfaoxQcMQd2(HwP6CXihgtllBpwnbhQmEXzMPwxwI6gVdWGyL2P352dvgV4RmhXLLOAV8dI1uPvCOZNkq7LFqSMkTfkVh6VE0bIkQB8oadIvANENB9AL8FO(3uwE(NcaNlvbt1bB)q7waccCOuDUyeKUcUS0(B8oadIvANENBXWop5rhik5)q9VPSEf8fJGWcybsve0O6jcspgp7HkJx8vY)H6Ftz55FkaCUufmvhS9dTBbiiWHs15Irq6k4YsW58XacTQpuhewaROJoG8FO(3u2TZto43GTWfYEOY4fNzymWasvFfmMci)hQ)nLTr1piVIb9BI)caxOKQ2dvgV4mdZmtrtyCKP)f3k7aoUJewB88pfaoxQcMQd2(HI6ByYpiwtLwXHoFQarziS32gCG)fh8BWFD8ScWxwIA7XQj4qLXloZY)H6FtzBWb(xCWVb)1XZEOY4fFzr(pu)BkBdoW)Id(n4VoE2dvgV4RK)d1)MYYZ)ua4CPkyQoy7hA3cqqGdLQZfJG0vWOdi)hQ)nLD78Kd(nylCHShQmEXzggdmGu1xbJPaY)H6FtzBu9dYRyq)M4VaWfkPQ9qLXloZWmZu0eghz6FXTYoGJ7iH1gp)tbGZLQGP6GTFOO(gM8dI1uPTq59q)1d0rdH92A8f2f4jW4Wgqhne2BRa8arbhtBybSaPkcAu9ebPhJNDKPhexwcoNpgqOv9H6GWcyTSi)hQ)nL1RGVyeewalqQIGgvprq6X4zpuz8IVs(pu)Bklp)tbGZLQGP6GTFODlabbouQoxmcsxbxwK)d1)MY6vWxmcclGfivrqJQNii9y8ShQmEXxTERrtyCKP)f3k7aoUJewBEXLNqogqiWKkmvkOa6yqxII6ByWX0gwalqQIGgvprq6X4zhz6bXLfJNZdS9y1eCOY4fNzMALW4it)lUv2bCChjS2AUjv55xOO(ggCmTHfWcKQiOr1teKEmE2rMEqCzX458aBpwnbhQmEXzMPwjmoY0)IBLDah3rcRTyOP7t(hhym9yuuFddoM2Wcybsve0O6jcspgp7itpiUSy8CEGThRMGdvgV4mZuReghz6FXTYoGJ7iH1MahbEIkIwJccRF403(HGGiNJqI6ByTp4C(yaH2Wcyb(ciWrqEEjgZLf5)q9VPSEf8fJGWcybsve0O6jcspgp7HkJx8vm1Aa4yAdlGfivrqJQNii9y8ShQmEXzMPwxwcoNpgqOv9H6GWcyryCKP)f3k7aoUJewBcCe4jQiAnkimU60)M4B4Wb5NOIO(ggCmTHfWcKQiOr1teKEmE2rMEqCzX458aBpwnbhQmEXzMPwxwA)ju4(Vy06vWxmECqhH8y1KW4it)lUv2bCChjS2e4iWtuHlQVH1(GZ5JbeAdlGf4lGahb55LymxwK)d1)MY6vWxmcclGfivrqJQNii9y8ShQmEXxXuRllbNZhdi0Q(qDqybSimoY0)IBLDah3rcRT8fKQGFdepNYiQVHT9y1eCOY4fFfdS1Lf4yAdlGfivrqJQNii9y8SJm9G4YsW58XacTQpuhewaRLfJNZdS9y1eCOY4fNzZTlHXrM(xCRSd44osyTza9FhSfUqI6ByY)H6Ftz9k4lgbHfWcKQiOr1teKEmE2dvgV4RwV1LLGZ5JbeAvFOoiSawllgpNhy7XQj4qLXloZm1kHXrM(xCRSd44osyTzGhhpXEflQVHj)hQ)nL1RGVyeewalqQIGgvprq6X4zpuz8IVA9wxwcoNpgqOv9H6GWcyTSy8CEGThRMGdvgV4mBoIeghz6FXTYoGJ7iH1gKhRMCadqOhRGvsyCKP)f3k7aoUJewBB)qdO)7I6ByY)H6Ftz9k4lgbHfWcKQiOr1teKEmE2dvgV4RwV1LLGZ5JbeAvFOoiSawllgpNhy7XQj4qLXloZMBLW4it)lUv2bCChjS2MsI88giGCGGe13WK)d1)MY6vWxmcclGfivrqJQNii9y8ShQmEXxTERllbNZhdi0Q(qDqybSwwmEopW2JvtWHkJxCMzQvcJJm9V4wzhWXDKWAZyIb)gKNlfZf13Wme2Blp)tbGZLQGP6GTFOT)nfHXrM(xCRSd44osyTTHqUQ8MDkQVHXFbidV6w4c8uacb4jap9VcyiS3wE(NcaNlvbt1bB)qB)BQaD0qyVTgFHDbEcmoSb0rdH922)MkGHWEBn(c7c8eyCyJT)nfHrcJJm9V4wzhWXdlpdbl4C(yaHIwJccJJhwEgcyiC8u0homoMIgCGeqyY)H6Ftz54HLNHShQmEXz28YcCmTHfWcKQiOr1teKEmE2rMEqmG8FO(3uwoEy5zi7HkJx8vR36YIXZ5b2ESAcouz8IZmtTsyCKP)f3k7aoEy5zOiH1MxbFXiiSawGufbnQEIG0JXtuFdR9bNZhdi0Q(qDqybSwwmEopW2JvtWHkJxCMzkIeghz6FXTYoGJhwEgksyTza9FhSfUqI6BybNZhdi0YXdlpdbmeoEsyCKP)f3k7aoEy5zOiH1MbEC8e7vSO(gwW58XacTC8WYZqadHJNeghz6FXTYoGJhwEgksyTb5XQjhWae6XkyLeghz6FXTYoGJhwEgksyTT9dnG(VlQVHfCoFmGqlhpS8meWq44jHXrM(xCRSd44HLNHIewBtjrEEdeqoqqI6BybNZhdi0YXdlpdbmeoEsyCKP)f3k7aoEy5zOiH1MXed(nipxkMlQVHfCoFmGqlhpS8meWq44jHXrM(xCRSd44HLNHIewB5livb)g0Xjvf13W2ESAcouz8IVkkZrGwnXju4(Vy0UNCGa5livJqMzQ1OxwGJPnSawGufbnQEIG0JXZoY0dIbIQ9YpiwtL2cL3d9xFzXqyVTgFHDbEcmoSXkap6LLOK)d1)MY6vWxmcclGfivrqJQNii9y8ShQmEXxT9y1eCOY4fp6agc7T14lSlWtGXHnwb4llgpNhy7XQj4qLXloZMBLW4it)lUv2bC8WYZqrcRTgCG)fh8BWFD8e13WK)d1)MYEo3RyaxOaIDPy7HkJxCMXWOuirq6kiHXrM(xCRSd44HLNHIewBEXLNqogqiWKkmvkOa6yqxII6BybNZhdi0YXdlpdbmeoEsyCKP)f3k7aoEy5zOiH1wZnPkp)cf13WcoNpgqOLJhwEgcyiC8KW4it)lUv2bC8WYZqrcRTyOP7t(hhym9yuuFdl4C(yaHwoEy5ziGHWXtcJJm9V4wzhWXdlpdfjS2e4iWtur0AuqyC1P)nX3WHdYprfr9nm4yAdlGfivrqJQNii9y8SJm9G4YIXZ5b2ESAcouz8IZmtTUS0(tOW9FXO1RGVy84Goc5XQjHXrM(xCRSd44HLNHIewBcCe4jQWf13WAFW58XacTHfWc8fqGJG88smMllY)H6Ftz9k4lgbHfWcKQiOr1teKEmE2dvgV4RyQ1LLGZ5JbeAvFOoiSaweghz6FXTYoGJhwEgksyTTheYleWZxboHXrM(xCRSd44HLNHIewB7bcclWFD8imoY0)IBLDahpS8muKWAZ4lSlWtGXHnI6BygpNhy7XQj4qLXloZMJ4YsusvFfmMce12JvtWHkJx8vTBRbIkk5)q9VPSC8WYZq2dvgV4Rm36YIHWEB54HLNHScWxwK)d1)MYYXdlpdzfGhDGOGJPnSawGufbnQEIG0JXZoY0dIllY)H6Ftz9k4lgbHfWcKQiOr1teKEmE2dvgV4Rm36YsW58XacTQpuhewaROJo6LLO2ESAcouz8IZmS2T1arbhtBybSaPkcwZQEIG0JXZoY0dIllY)H6Ftz9k4lgbHfWcKQiOr1teKEmE2dvgV4R2ESAcouz8IhD0rtyCKP)f3k7aoEy5zOiH1ghpS8mKO(gM8FO(3u2Z5Efd4cfqSlfBpuz8IZmtllgpNhy7XQj4qLXloZMJiHXrM(xCRSd44HLNHIewBgtm43G8CPyoHXrM(xCRSd44HLNHIewBBiKRkVzNI6By8xaYWRUfUapfGqaEcWt)Ragc7TLJhwEgY2)Mkqhne2BRXxyxGNaJdBaD0qyVT9VPcyiS3wJVWUapbgh2y7FtryKW4it)lU9HJfEW2opb)gKQiOr1teKEmEIkdjHqqo3fJjhMzr9nmPQBvMWMqQ6RGToHXrM(xC7dhl8IewByy4ieqDofr9nSCGWkTsvhyiC80I1yaH9asv3QmHnHu1xbBDcJJm9V42how4fjS2spgpa8bsruzijecY5IXKdZSO(gM8vmEappxmgqQ6wLjSjKQ(kymryCKP)f3(WXcViH1Mu1bntquuFdtQ6wLjSjKQomMimoY0)IBF4yHxKWAdddhHaQZPqyCKP)f3(WXcViH1w6X4bGpqkIkdjHqqoxmMCyMf13WKQUvzcBcPQVcgtegjmoY0)IB54HLNHGTDEYb)gSfUqI6Bygc7TLJhwEgYEOY4fNzZeghz6FXTC8WYZqrcRnoCVkVIbYBkei2LIf13WKVIXd455IXarnY0dIaSqfh5RGT(YYitpicWcvCKVYCG2l)hQ)nL9CUxXaUqbe7sXwb4rtyCKP)f3YXdlpdfjS2oN7vmGluaXUuSOYqsieKZfJjhMzr9nm5Ry8aEEUyKW4it)lULJhwEgksyTTDEYb)gSfUqI6ByJm9GialuXr(kyRtyCKP)f3YXdlpdfjS24W9Q8kgiVPqGyxkwuFdt(kgpGNNlgdyiS32(use8BGu1zaUvaoHXrM(xClhpS8muKWAZaAKIFHei2LIfvgscHGCUym5WmlQVHjFfJhWZZfJbme2BBdoW)Id(n4VoEwb4bK)d1)MYEo3RyaxOaIDPy7HkJx8vmryCKP)f3YXdlpdfjS22op5GFd2cxir9kX7eGNaFdZqyVTC8WYZqwb4bK)d1)MYEo3RyaxOaIDPy7HtpeHXrM(xClhpS8muKWAJd3RYRyG8McbIDPyr9nm5Ry8aEEUymqhne2BRXxyxGNaJdBaD0qyVTcWjmoY0)IB54HLNHIewBBNNGFdsve0O6jcspgprLHKqiiNlgtomZI6BysvN51jmoY0)IB54HLNHIewBgqJu8lKaXUuSOYqsieKZfJjhMzr9nm5Ry8aEEUyCzP95aHvAv9eiFfJNW4it)lULJhwEgksyTXH7v5vmqEtHaXUumHrcJJm9V4wEcRr1piVIb9BI)caxOKQI6By34DageR0o9o361k5)q9VPSnQ(b5vmOFt8xa4cLu12fUj9VIqTAJall34DageR0o9o3kaNW4it)lULNrcRnSWl2BN9kgGqEy)e13WKQUvzcBcPQVcgtbWcV4q20vqq(aLj8Q1xwKQUvzcBcPQVcgdgikSWloKnDfeKpqzcVIPLL2d)WGGyz3A2MEmEa4dKs0eghz6FXT8msyTXH7v5vmqEtHaXUuSO(gM8vmEappxmgWqyVT9PKi43aPQZaCRa8arDJ3byqSs707CRxRme2BBFkjc(nqQ6ma3EOY4f3emTSCJ3byqSs707CRa8OjmoY0)IB5zKWABdHCv5n7uuVs8ob4jWvuWUpjcZSOEL4DcWtGVHziS32Gp0Koec4puqSsGQGYuV3TcWxwWcV4q20vqq(aLjmZRVSi)hQ)nL9CUxXaUqbe7sX2dvgV4mZ0YI8FO(3u2TZto43GTWfYEOY4fNzMe13W4VaKHxDBWhAshcb8hkiwzadH92YZ)ua4CPkyQoy7hA7FtfOJgc7T14lSlWtGXHnGoAiS32(3ueghz6FXT8msyTDo3RyaxOaIDPyrLHKqiiNlgtomZI6ByY)H6Ftz54HLNHShQmEXxzEzP95aHvA54HLNHceL8FO(3u2gCG)fh8BWFD8ShQmEXxXGllTx(bXAQ0ko05tfnHXrM(xClpJewBBNNCWVbBHlKO(gwu34DageR0o9o361k5)q9VPSBNNCWVbBHlKTlCt6FfHA1gbwwUX7amiwPD6DUvaE0bIcl8Idztxbb5duMWRWWOuirq6kOjmVSivDRYe2esvNzyMxwme2Blp)tbGZLQGP6GTFO9qLXloZyyukKiiDfmsZrVSS9y1eCOY4fNzmmkfseKUcgP5LLoAiS3wJVWUapbgh2a6OHWEBfGtyCKP)f3YZiH1M8gPyiVIbmGPJaipwnlVIf13Wme2BBQIauboE)XbYb(i98plphP4vMzGbWcV4q20vqq(aLj8kmmkfseKUcAcZbK)d1)MYEo3RyaxOaIDPy7HkJx8vyyukKiiDfCzXqyVTPkcqf449hhih4J0Z)S8CKIxzMbdeL8FO(3uwoEy5zi7HkJxCMJyGCGWkTC8WYZqllY)H6FtzBWb(xCWVb)1XZEOY4fN5igq(bXAQ0ko05tTSS9y1eCOY4fN5ignHXrM(xClpJewBNax1Ryady6iOXRUO(gMHWEBpbUQxXagW0rqJxDB)BQaJm9GialuXr(kZeghz6FXT8msyTTDEc(nivrqJQNii9y8evgscHGCUym5WmlQVHjvDMxNW4it)lULNrcRnmmCecOoNIO(gMu1Tktytiv9vWmtyCKP)f3YZiH1Mu1bgchpf13WKQUvzcBcPQVcM5aJm9GialuXromZbUX7amiwPD6DU1Rvm16YIu1Tktytiv9vWykWitpicWcvCKVcgteghz6FXT8msyTjvDqZeejmoY0)IB5zKWAl9y8aWhifrLHKqiiNlgtomZI6ByYxX4b88CXyaPQBvMWMqQ6RGXuadH92YZ)ua4CPkyQoy7hA7FtryCKP)f3YZiH1ghUxLxXa5nfce7sXI6Bygc7TvQ6aSWloKLNJu8Q1B1ermcnY0dIaSqfh5bme2Blp)tbGZLQGP6GTFOT)nvGOK)d1)MYEo3RyaxOaIDPy7HkJx8vmfq(pu)Bk725jh8BWw4czpuz8IVIPLf5)q9VPSNZ9kgWfkGyxk2EOY4fN51di)hQ)nLD78Kd(nylCHShQmEXxTEaPQVA9Lf5)q9VPSNZ9kgWfkGyxk2EOY4fF16bK)d1)MYUDEYb)gSfUq2dvgV4mVEaPQVIbxwKQUvzcBcPQZmmZbWcV4q20vqq(aLjmZmf9YIHWEBLQoal8Idz55ifVYCRb2ESAcouz8IZC7GW4it)lULNrcRndOrk(fsGyxkwuzijecY5IXKdZSO(gM8vmEappxmgiQCGWkTC8WYZqbK)d1)MYYXdlpdzpuz8IZ86llY)H6FtzpN7vmGluaXUuS9qLXl(kZbK)d1)MYUDEYb)gSfUq2dvgV4RmVSi)hQ)nL9CUxXaUqbe7sX2dvgV4mVEa5)q9VPSBNNCWVbBHlK9qLXl(Q1div9vmTSi)hQ)nL9CUxXaUqbe7sX2dvgV4RwpG8FO(3u2TZto43GTWfYEOY4fN51div9vRVSiv9vrCzXqyVTgVya87Lwb4rtyCKP)f3YZiH1w6X4bGpqkIkdjHqqoxmMCyMf13WKVIXd455IXasv3QmHnHu1xbJjcJJm9V4wEgjS2MtofcY)oSsr9nmPQBvMWMqQ6RGzMW4it)lULNrcRTnuiVIbC8GJvce7sXI6vI3japHzMW4it)lULNrcRndOrk(fsGyxkwuzijecY5IXKdZSO(gM8vmEappxmgq(pu)Bk725jh8BWw4czpuz8IZ86bKQomMca)WGGyz3A2MEmEa4dKsaSWloKnDfeKpiITYSzcJJm9V4wEgjS2mGgP4xibIDPyrLHKqiiNlgtomZI6ByYxX4b88CXyaSWloKnDfeKpqzcZmtbIsQ6wLjSjKQoZWmVSa)WGGyz3A2MEmEa4dKs0egjmoY0)IBBWb(xCWVb)1XdwW58XacfTgfeMb0if)cjqSlfdke7yx0homoMIgCGeqygc7TTbh4FXb)g8xhpqtJ9qLXlEGOK)d1)MYEo3RyaxOaIDPy7HkJx8vgc7TTbh4FXb)g8xhpqtJ9qLXlEadH922Gd8V4GFd(RJhOPXEOY4fNzMSMxwK)d1)MYEo3RyaxOaIDPy7HkJxCtyiS32gCG)fh8BWFD8ann2dvgV4RmBzGbme2BBdoW)Id(n4VoEGMg7HkJxCMzqR5LfdH92Aa9FhsGNwb4bme2BRxbFX4XbDeYJvtRa8agc7T1RGVy84Goc5XQP9qLXloZgc7TTbh4FXb)g8xhpqtJ9qLXlE0eghz6FXTn4a)lo43G)64fjS2KdeeyKP)faY5PO1OGWKDah3IYZZLjmZI6ByTphiSslhpS8meHXrM(xCBdoW)Id(n4VoErcRn5abbgz6FbGCEkAnkimzhWXdlpdjkppxMWmlQVHLdewPLJhwEgIW4it)lUTbh4FXb)g8xhViH1gw4f7TZEfdqipSFI6Bysv3QmHnHu1xbJPayHxCiB6kiiFGYeE16eghz6FXTn4a)lo43G)64fjS2oN7vmGluaXUuSOYqsieKZfJjhMzcJJm9V42gCG)fh8BWFD8IewBBNNCWVbBHlKO(g2itpicWcvCKVcgtbme2BBdoW)Id(n4VoEGMg7HkJxCMntyCKP)f32Gd8V4GFd(RJxKWARr1piVIb9BI)caxOKQI6ByJm9GialuXr(kymryCKP)f32Gd8V4GFd(RJxKWAJd3RYRyG8McbIDPyr9nm5Ry8aEEUymWitpicWcvCKVc26bme2BBdoW)Id(n4VoEGMgRaCcJJm9V42gCG)fh8BWFD8IewBgqJu8lKaXUuSOYqsieKZfJjhMzr9nm5Ry8aEEUymWitpicWcvCKZmmMceCoFmGqRb0if)cjqSlfdke7yNW4it)lUTbh4FXb)g8xhViH1ghUxLxXa5nfce7sXI6ByYxX4b88CXyadH922NsIGFdKQodWTcWjmoY0)IBBWb(xCWVb)1XlsyTHHHJqa15ue13WKQoSwdyiS32gCG)fh8BWFD8ann2dvgV4mZGeghz6FXTn4a)lo43G)64fjS22opb)gKQiOr1teKEmEIkdjHqqoxmMCyMf13WKQoSwdyiS32gCG)fh8BWFD8ann2dvgV4mZGeghz6FXTn4a)lo43G)64fjS2Au9dYRyq)M4VaWfkPkHXrM(xCBdoW)Id(n4VoErcRT0JXdaFGuevgscHGCUym5WmlQVHjvDyTgWqyVTn4a)lo43G)64bAAShQmEXzMbjmoY0)IBBWb(xCWVb)1XlsyTTDEYb)gSfUqI6vI3japb(gMHWEBBWb(xCWVb)1Xd00yfGlQVHziS3wE(NcaNlvbt1bB)qRa8a34DageR0o9o361k5)q9VPSBNNCWVbBHlKTlCt6FfHA12Ueghz6FXTn4a)lo43G)64fjS24W9Q8kgiVPqGyxkwuFdZqyVTsvhGfEXHS8CKIxTERMiIrOrMEqeGfQ4iNW4it)lUTbh4FXb)g8xhViH1225j43GufbnQEIG0JXtuzijecY5IXKdZSO(gMu1zEDcJJm9V42gCG)fh8BWFD8IewByy4ieqDofr9nmPQBvMWMqQ6RGzMW4it)lUTbh4FXb)g8xhViH1Mu1bgchpf13WKQUvzcBcPQVcwuMJCKPhebyHkoYxzoAcJJm9V42gCG)fh8BWFD8IewBPhJha(aPiQmKecb5CXyYHzwuFdlQ2NdewPv1tG8vm(Lf5Ry8aEEUym6asv3QmHnHu1xbJjcJJm9V42gCG)fh8BWFD8IewBgqJu8lKaXUuSOYqsieKZfJjhMzr9nSrMEqeGfQ4iNzyRhqQ6RGT(YIHWEBBWb(xCWVb)1Xd00yfGtyCKP)f32Gd8V4GFd(RJxKWAtQ6GMjisyCKP)f32Gd8V4GFd(RJxKWABdfYRyahp4yLaXUuSOEL4DcWtyM1Po1Aa]] )


end