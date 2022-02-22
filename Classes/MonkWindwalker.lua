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


    spec:RegisterPack( "Windwalker", 20220221, [[dSe3JcqiLK6rcLuBsaFcf0OeQCkHQwLqj5vcfZIq6wue2fL(LsIHjL0XOOwgkYZus10OiY1ek12ussFtjjACcLW5qb06usH5HI6EGY(KsDquG0cLs8qLuYerbI4IcLO2OssWhrbcNuOezLOqVefiQzQKsDtuGiTtcXpvsrAPkPiEkknvksFvjf1yPiQ9sQ)cmyKoSIftHht0KLQldTzL6Zcz0K0PPA1Oa8Ac1Sb52Ky3s(TQgoO64Oa1Yv55OA6IUobBxG(UumEb15fK1RKeA(kX(rS2S2unBFsulctTYetTYetMTm1Q51BDDnBgcoQzHpsXteQzRrb1SRzV6ndKy80SWNqq)01MQz5VWjrnRM1qWHYyPsBOz7tIAryQvMyQvMyYSLPwnVUMLdhLAryAvzGAwvV3XsBOz7ixQzxZE1BgiX4rOmi9lXegxfqJtyUqektMfLqzQvMyIWiHX1sDUiKVgegnbHAAdoIj0vbNNCc93e6QGWfIq9kX7eGNek0h5slHrtqOM2GJycLfUxLxre6ADtHekdYUumHc9rU0sy0eekdAVtOgpNV9i1KqLQOumNqZNqvMkeHUwmiHqXkph5wcJMGqzq7Dc1ltiFfJjj0vbiKRkVzNwnlKZtU2un7dhl80MQfXS2unlwJbe21TOzhz6FPz3opb)gKQiOr1teKEeEAw55jE(OzLQUvzctOMGqLQoH2ggHUUMvgscHGCUlctUM1So1IWK2unlwJbe21TOzLNN45JMnhiSsRu1bgchpTyngqyNqdqOsv3QmHjutqOsvNqBdJqxxZoY0)sZIHHJqa15u0PwK11MQzXAmGWUUfn7it)lnB6r4bGpqkAw55jE(OzLVIXd455IrcnaHkvDRYeMqnbHkvDcTnmcLjnRmKecb5CryY1IywNArmjTPAwSgdiSRBrZkppXZhnRu1Tktyc1eeQu1juyektA2rM(xAwPQdAMGOo1IeBTPA2rM(xAwmmCecOoNIMfRXac76w0PwKvvBQMfRXac76w0SJm9V0SPhHha(aPOzLNN45JMvQ6wLjmHAccvQ6eAByektAwzijecY5IWKRfXSo1PMTbh4FXb)g8xhpTPArmRnvZI1yaHDDlA2hUMLJPMDKP)LMn4C(yaHA2GdKaQzne2BBdoW)Id(n4VoEGMg7HkJxCcnaHghHk)hQ)nL9CUxraUqbe7sX2dvgV4eABc1qyVTn4a)lo43G)64bAAShQmEXj0aeQHWEBBWb(xCWVb)1Xd00ypuz8ItOmtOmzntOlleQ8FO(3u2Z5Efb4cfqSlfBpuz8ItOMGqne2BBdoW)Id(n4VoEGMg7HkJxCcTnHA2Yaj0aeQHWEBBWb(xCWVb)1Xd00ypuz8ItOmtOMK1mHUSqOgc7T1a6)oKapTcWj0aeQHWEB9k4lgpoOJqEKAAfGtObiudH926vWxmECqhH8i10EOY4fNqzMqne2BBdoW)Id(n4VoEGMg7HkJxCcnEnBW5a1OGAwdOrk(fsGyxkgui2XUo1IWK2unlwJbe21TOzLNN45JMD1eAoqyLwoEy5zilwJbe21S88CzQfXSMDKP)LMvoqqGrM(xaiNNAwiNNGAuqnRSd44wNArwxBQMfRXac76w0SYZt88rZMdewPLJhwEgYI1yaHDnlppxMArmRzhz6FPzLdeeyKP)faY5PMfY5jOgfuZk7aoEy5ziDQfXK0MQzXAmGWUUfnR88epF0Ssv3QmHjutqOsvNqBdJqzIqdqOyHxuiB6kiiFGYeMqBtORRzhz6FPzXcViFv0Riac5H9tNArIT2unlwJbe21TOzhz6FPzpN7veGluaXUuSMvgscHGCUim5ArmRtTiRQ2unlwJbe21TOzLNN45JMDKPhebyHkoYj02WiuMi0aeQHWEBBWb(xCWVb)1Xd00ypuz8ItOmtOM1SJm9V0SBNNCWVbBHlKo1ISk1MQzXAmGWUUfnR88epF0SJm9GialuXroH2ggHYKMDKP)LMTr1piVIa9BI(caxOKQ6ulsSqBQMfRXac76w0SYZt88rZkFfJhWZZfJeAacDKPhebyHkoYj02Wi01j0aeQHWEBBWb(xCWVb)1Xd00yfGRzhz6FPz5W9Q8kciVPqGyxkwNAryGAt1Syngqyx3IMDKP)LM1aAKIFHei2LI1SYZt88rZkFfJhWZZfJeAacDKPhebyHkoYjuMHrOmrObi0GZ5JbeAnGgP4xibIDPyqHyh7AwzijecY5IWKRfXSo1IyUvTPAwSgdiSRBrZkppXZhnR8vmEappxmsObiudH922NsIGFdKQodWTcW1SJm9V0SC4EvEfbK3uiqSlfRtTiMnRnvZI1yaHDDlAw55jE(OzLQoHcJqBLqdqOgc7TTbh4FXb)g8xhpqtJ9qLXloHYmHAsA2rM(xAwmmCecOoNIo1IyMjTPAwSgdiSRBrZoY0)sZUDEc(nivrqJQNii9i80SYZt88rZkvDcfgH2kHgGqne2BBdoW)Id(n4VoEGMg7HkJxCcLzc1K0SYqsieKZfHjxlIzDQfX86At1SJm9V0SnQ(b5veOFt0xa4cLuvZI1yaHDDl6ulIztsBQMfRXac76w0SJm9V0SPhHha(aPOzLNN45JMvQ6ekmcTvcnaHAiS32gCG)fh8BWFD8ann2dvgV4ekZeQjPzLHKqiiNlctUweZ6ulI5yRnvZI1yaHDDlAw55jE(Ozne2Blp)tbGZLQGP6GTFOvaoHgGqVX7amiwPD6DU1lcTnHk)hQ)nLD78Kd(nylCHSDHBs)lcnwrOTAxvn7it)ln725jh8BWw4cPz9kX7eGNaFRzne2BBdoW)Id(n4VoEGMgRaCDQfX8QQnvZI1yaHDDlAw55jE(Ozne2BRu1byHxuilphPycTnHUEReQji0ytOXkcDKPhebyHkoY1SJm9V0SC4EvEfbK3uiqSlfRtTiMxLAt1Syngqyx3IMDKP)LMD78e8BqQIGgvprq6r4PzLNN45JMvQ6ekZe66AwzijecY5IWKRfXSo1IyowOnvZI1yaHDDlAw55jE(OzLQUvzctOMGqLQoH2ggHAwZoY0)sZIHHJqa15u0PweZmqTPAwSgdiSRBrZkppXZhnRu1Tktyc1eeQu1j02Wi04iuZeAme6itpicWcvCKtOTjuZeA8A2rM(xAwPQdmeoEQtTim1Q2unlwJbe21TOzhz6FPztpcpa8bsrZkppXZhnBCe6Qj0CGWkTQEcKVIXBXAmGWoHUSqOYxX4b88CXiHgpHgGqLQUvzctOMGqLQoH2ggHYKMvgscHGCUim5ArmRtTimzwBQMfRXac76w0SJm9V0SgqJu8lKaXUuSMvEEINpA2rMEqeGfQ4iNqzggHUoHgGqLQoH2ggHUoHUSqOgc7TTbh4FXb)g8xhpqtJvaUMvgscHGCUim5ArmRtTimXK2un7it)lnRu1bntquZI1yaHDDl6ulctRRnvZ6vI3jap1SM1SJm9V0SBOqEfb44bhRei2LI1Syngqyx3Io1PMLJhwEgsBQweZAt1Syngqyx3IMvEEINpAwdH92YXdlpdzpuz8ItOmtOM1SJm9V0SBNNCWVbBHlKo1IWK2unlwJbe21TOzLNN45JMv(kgpGNNlgj0aeACe6itpicWcvCKtOTHrORtOlle6itpicWcvCKtOTjuZeAacD1eQ8FO(3u2Z5Efb4cfqSlfBfGtOXRzhz6FPz5W9Q8kciVPqGyxkwNArwxBQMfRXac76w0SJm9V0SNZ9kcWfkGyxkwZkppXZhnR8vmEappxmQzLHKqiiNlctUweZ6ulIjPnvZI1yaHDDlAw55jE(Ozhz6brawOIJCcTnmcDDn7it)ln725jh8BWw4cPtTiXwBQMfRXac76w0SYZt88rZkFfJhWZZfJeAac1qyVT9PKi43aPQZaCRaCn7it)lnlhUxLxra5nfce7sX6ulYQQnvZI1yaHDDlA2rM(xAwdOrk(fsGyxkwZkppXZhnR8vmEappxmsObiudH922Gd8V4GFd(RJNvaoHgGqL)d1)MYEo3RiaxOaIDPy7HkJxCcTnHYKMvgscHGCUim5ArmRtTiRsTPAwVs8ob4jW3AwdH92YXdlpdzfGhq(pu)Bk75CVIaCHci2LITho9qA2rM(xA2TZto43GTWfsZI1yaHDDl6ulsSqBQMfRXac76w0SYZt88rZkFfJhWZZfJeAacTJgc7T14lSlWtGXHnGoAiS3wb4A2rM(xAwoCVkVIaYBkei2LI1PwegO2unlwJbe21TOzhz6FPz3opb)gKQiOr1teKEeEAw55jE(OzLQoHYmHUUMvgscHGCUim5ArmRtTiMBvBQMfRXac76w0SJm9V0SgqJu8lKaXUuSMvEEINpAw5Ry8aEEUyKqxwi0vtO5aHvAv9eiFfJ3I1yaHDnRmKecb5CryY1IywNArmBwBQMDKP)LMLd3RYRiG8McbIDPynlwJbe21TOtDQzLDahpS8mK2uTiM1MQzXAmGWUUfn7dxZYXuZoY0)sZgCoFmGqnBWbsa1SY)H6Ftz54HLNHShQmEXjuMjuZe6YcHchtBybSaPkcAu9ebPhHNDKPhej0aeQ8FO(3uwoEy5zi7HkJxCcTnHUERe6YcHA8CoHgGq3EKAcouz8ItOmtOm1QMn4CGAuqnlhpS8meWq44Po1IWK2unlwJbe21TOzLNN45JMD1eAW58XacTQpuhewalcDzHqnEoNqdqOBpsnbhQmEXjuMjuMITMDKP)LM1RGVyeewalDQfzDTPAwSgdiSRBrZkppXZhnBW58XacTC8WYZqadHJNA2rM(xAwdO)7GTWfsNArmjTPAwSgdiSRBrZkppXZhnBW58XacTC8WYZqadHJNA2rM(xAwd844j2RiDQfj2At1SJm9V0SqEKAYbmaHEKcwPMfRXac76w0PwKvvBQMfRXac76w0SYZt88rZgCoFmGqlhpS8meWq44PMDKP)LMD7hAa9FxNArwLAt1Syngqyx3IMvEEINpA2GZ5JbeA54HLNHagchp1SJm9V0StjrEEdeqoqq6ulsSqBQMfRXac76w0SYZt88rZgCoFmGqlhpS8meWq44PMDKP)LM1yIa)gKNlfZ1PwegO2unlwJbe21TOzLNN45JMD7rQj4qLXloH2MqJJqnhlALqnbHEcfU)lcT7jhiq(csvlwJbe2j0yfHAMPwj04j0LfcfoM2Wcybsve0O6jcspcp7itpisObi04i0vtOYpiwtL2cL3d9xNqxwiudH92A8f2f4jW4WgRaCcnEcDzHqJJqL)d1)MY6vWxmcclGfivrqJQNii9i8ShQmEXj02e62JutWHkJxCcnEcnaHAiS3wJVWUapbgh2yfGtOlleQXZ5eAacD7rQj4qLXloHYmHAUvn7it)lnB(csvWVbDCsvDQfXCRAt1Syngqyx3IMvEEINpAw5)q9VPSNZ9kcWfkGyxk2EOY4fNqzMqXWOuirq6kOMDKP)LMTbh4FXb)g8xhpDQfXSzTPAwSgdiSRBrZkppXZhnBW58XacTC8WYZqadHJNA2rM(xAwV4YtihdieWGfMkfuaDmOlrDQfXmtAt1Syngqyx3IMvEEINpA2GZ5JbeA54HLNHagchp1SJm9V0Sn3KQ88luNArmVU2unlwJbe21TOzLNN45JMn4C(yaHwoEy5ziGHWXtn7it)lnBe009j)JdmMEeQtTiMnjTPAwSgdiSRBrZoY0)sZYvN(3eDdhoi)ev0SYZt88rZchtBybSaPkcAu9ebPhHNDKPhej0Lfc145CcnaHU9i1eCOY4fNqzMqzQvcDzHqxnHEcfU)lcTEf8fJhh0ripsnTyngqyxZwJcQz5Qt)BIUHdhKFIk6ulI5yRnvZI1yaHDDlAw55jE(OzxnHgCoFmGqBybSaFbe4iipVeJjHUSqOY)H6Ftz9k4lgbHfWcKQiOr1teKEeE2dvgV4eABcLPwj0Lfcn4C(yaHw1hQdclGLMDKP)LMvGJaprfUo1IyEv1MQzhz6FPz3dc5fc45RaxZI1yaHDDl6ulI5vP2un7it)ln7EGGWc8xhpnlwJbe21TOtTiMJfAt1Syngqyx3IMvEEINpAwJNZj0ae62JutWHkJxCcLzc1CSj0LfcnocvQ6eAByekteAacnocD7rQj4qLXloH2Mqx1wj0aeACeACeQ8FO(3uwoEy5zi7HkJxCcTnHAUvcDzHqne2BlhpS8mKvaoHUSqOY)H6Ftz54HLNHScWj04j0aeACekCmTHfWcKQiOr1teKEeE2rMEqKqxwiu5)q9VPSEf8fJGWcybsve0O6jcspcp7HkJxCcTnHAUvcDzHqdoNpgqOv9H6GWcyrOXtOXtOXtOlleACe62JutWHkJxCcLzye6Q2kHgGqJJqHJPnSawGufbRzvprq6r4zhz6brcDzHqL)d1)MY6vWxmcclGfivrqJQNii9i8ShQmEXj02e62JutWHkJxCcnEcnEcnEn7it)lnRXxyxGNaJdB0PweZmqTPAwSgdiSRBrZkppXZhnR8FO(3u2Z5Efb4cfqSlfBpuz8ItOmtOmrOlleQXZ5eAacD7rQj4qLXloHYmHAo2A2rM(xAwoEy5ziDQfHPw1MQzhz6FPznMiWVb55sXCnlwJbe21TOtTimzwBQMfRXac76w0SYZt88rZYFbidV6w4c8uacb4jap9VSyngqyNqdqOgc7TLJhwEgY2)MIqdqOD0qyVTgFHDbEcmoSb0rdH922)MIqdqOgc7T14lSlWtGXHn2(3uA2rM(xA2neYvL3StDQtnlp1MQfXS2unlwJbe21TOzLNN45JM9gVdWGyL2P35wVi02eQ8FO(3u2gv)G8kc0Vj6laCHsQA7c3K(xeASIqB1gli0Lfc9gVdWGyL2P35wb4A2rM(xA2gv)G8kc0Vj6laCHsQQtTimPnvZI1yaHDDlAw55jE(OzLQUvzctOMGqLQoH2ggHYeHgGqXcVOq20vqq(aLjmH2MqxNqxwiuPQBvMWeQjiuPQtOTHrOMeHgGqJJqXcVOq20vqq(aLjmH2MqzIqxwi0vtOWpmiis2TMTPhHha(aPqOXRzhz6FPzXcViFv0Riac5H9tNArwxBQMfRXac76w0SYZt88rZkFfJhWZZfJeAac1qyVT9PKi43aPQZaCRaCcnaHghHEJ3byqSs707CRxeABc1qyVT9PKi43aPQZaC7HkJxCc1eekte6YcHEJ3byqSs707CRaCcnEn7it)lnlhUxLxra5nfce7sX6ulIjPnvZI1yaHDDlAw55jE(Oz5VaKHxDBWhAshcb8hkiwPfRXac7eAac1qyVT88pfaoxQcMQd2(H2(3ueAacTJgc7T14lSlWtGXHnGoAiS32(3uAwVs8ob4jW3AwdH92g8HM0Hqa)HcIvcufuM69Uva(Ycw4ffYMUccYhOmHzE9Lf5)q9VPSNZ9kcWfkGyxk2EOY4fNzMwwK)d1)MYUDEYb)gSfUq2dvgV4mZKM1ReVtaEcCffS7tIAwZA2rM(xA2neYvL3StDQfj2At1Syngqyx3IMDKP)LM9CUxraUqbe7sXAw55jE(OzL)d1)MYYXdlpdzpuz8ItOTjuZe6YcHUAcnhiSslhpS8mKfRXac7eAacnocv(pu)BkBdoW)Id(n4VoE2dvgV4eABc1Ki0LfcD1eQ8dI1uPvCOZNIqJxZkdjHqqoxeMCTiM1PwKvvBQMfRXac76w0SYZt88rZghHEJ3byqSs707CRxeABcv(pu)Bk725jh8BWw4cz7c3K(xeASIqB1gli0Lfc9gVdWGyL2P35wb4eA8eAacnocfl8Icztxbb5duMWeABcfdJsHebPRGeQjiuZe6YcHkvDRYeMqnbHkvDcLzyeQzcDzHqne2Blp)tbGZLQGP6GTFO9qLXloHYmHIHrPqIG0vqcngc1mHgpHUSqOBpsnbhQmEXjuMjummkfseKUcsOXqOMj0LfcTJgc7T14lSlWtGXHnGoAiS3wb4A2rM(xA2TZto43GTWfsNArwLAt1Syngqyx3IMvEEINpAwdH92MQiavGJ3FCGCGpsp)ZYZrkMqBtOMzGeAacfl8Icztxbb5duMWeABcfdJsHebPRGeQjiuZeAacv(pu)Bk75CVIaCHci2LIThQmEXj02ekggLcjcsxbj0Lfc1qyVTPkcqf449hhih4J0Z)S8CKIj02eQztIqdqOXrOY)H6Ftz54HLNHShQmEXjuMj0ytObi0CGWkTC8WYZqwSgdiStOlleQ8FO(3u2gCG)fh8BWFD8ShQmEXjuMj0ytObiu5heRPsR4qNpfHUSqOBpsnbhQmEXjuMj0ytOXRzhz6FPzL3ifd5veGbmDea5rQz5vKo1Iel0MQzXAmGWUUfnR88epF0Sgc7T9e4QEfbyathbnE1T9VPi0ae6itpicWcvCKtOTjuZA2rM(xA2tGR6veGbmDe04vxNAryGAt1Syngqyx3IMDKP)LMD78e8BqQIGgvprq6r4PzLNN45JMvQ6ekZe66AwzijecY5IWKRfXSo1IyUvTPAwSgdiSRBrZkppXZhnRu1Tktyc1eeQu1j02WiuZA2rM(xAwmmCecOoNIo1Iy2S2unlwJbe21TOzLNN45JMvQ6wLjmHAccvQ6eAByeQzcnaHoY0dIaSqfh5ekmc1mHgGqVX7amiwPD6DU1lcTnHYuRe6YcHkvDRYeMqnbHkvDcTnmcLjcnaHoY0dIaSqfh5eAByektA2rM(xAwPQdmeoEQtTiMzsBQMDKP)LMvQ6GMjiQzXAmGWUUfDQfX86At1Syngqyx3IMDKP)LMn9i8aWhifnR88epF0SYxX4b88CXiHgGqLQUvzctOMGqLQoH2ggHYeHgGqne2Blp)tbGZLQGP6GTFOT)nLMvgscHGCUim5ArmRtTiMnjTPAwSgdiSRBrZkppXZhnRHWEBLQoal8Icz55iftOTj01BLqnbHgBcnwrOJm9GialuXroHgGqne2Blp)tbGZLQGP6GTFOT)nfHgGqJJqL)d1)MYEo3RiaxOaIDPy7HkJxCcTnHYeHgGqL)d1)MYUDEYb)gSfUq2dvgV4eABcLjcDzHqL)d1)MYEo3RiaxOaIDPy7HkJxCcLzcDDcnaHk)hQ)nLD78Kd(nylCHShQmEXj02e66eAacvQ6eABcDDcDzHqL)d1)MYEo3RiaxOaIDPy7HkJxCcTnHUoHgGqL)d1)MYUDEYb)gSfUq2dvgV4ekZe66eAacvQ6eABc1Ki0LfcvQ6wLjmHAccvQ6ekZWiuZeAacfl8Icztxbb5duMWekZekteA8e6YcHAiS3wPQdWcVOqwEosXeABc1CReAacD7rQj4qLXloHYmHUk1SJm9V0SC4EvEfbK3uiqSlfRtTiMJT2unlwJbe21TOzhz6FPznGgP4xibIDPynR88epF0SYxX4b88CXiHgGqJJqZbcR0YXdlpdzXAmGWoHgGqL)d1)MYYXdlpdzpuz8ItOmtORtOlleQ8FO(3u2Z5Efb4cfqSlfBpuz8ItOTjuZeAacv(pu)Bk725jh8BWw4czpuz8ItOTjuZe6YcHk)hQ)nL9CUxraUqbe7sX2dvgV4ekZe66eAacv(pu)Bk725jh8BWw4czpuz8ItOTj01j0aeQu1j02ekte6YcHk)hQ)nL9CUxraUqbe7sX2dvgV4eABcDDcnaHk)hQ)nLD78Kd(nylCHShQmEXjuMj01j0aeQu1j02e66e6YcHkvDcTnHgBcDzHqne2BRXlga)EPvaoHgVMvgscHGCUim5ArmRtTiMxvTPAwSgdiSRBrZoY0)sZMEeEa4dKIMvEEINpAw5Ry8aEEUyKqdqOsv3QmHjutqOsvNqBdJqzsZkdjHqqoxeMCTiM1PweZRsTPAwSgdiSRBrZkppXZhnRu1Tktyc1eeQu1j02WiuZA2rM(xA25KtHG8VdRuNArmhl0MQz9kX7eGNAwZA2rM(xA2nuiVIaC8GJvce7sXAwSgdiSRBrNArmZa1MQzXAmGWUUfn7it)lnRb0if)cjqSlfRzLNN45JMv(kgpGNNlgj0aeQ8FO(3u2TZto43GTWfYEOY4fNqzMqxNqdqOsvNqHrOmrObiu4hgeej7wZ20JWdaFGui0aekw4ffYMUccYhe7wjuMjuZAwzijecY5IWKRfXSo1IWuRAt1Syngqyx3IMDKP)LM1aAKIFHei2LI1SYZt88rZkFfJhWZZfJeAacfl8Icztxbb5duMWekZekteAacnocvQ6wLjmHAccvQ6ekZWiuZe6YcHc)WGGiz3A2MEeEa4dKcHgVMvgscHGCUim5ArmRtDQzLDah3At1IywBQMfRXac76w0SYZt88rZUAcn4C(yaHw1hQdclGfHgGqJJqL)d1)MYEo3RiaxOaIDPy7HkJxCcLzcLjcDzHqxnHk)GynvAfh68Pi04j0aeACe6Qju5heRPsBHY7H(RtOlleQ8FO(3uwJVWUapbgh2ypuz8ItOmtOmrOXtOlle62JutWHkJxCcLzcLPyRzhz6FPz9k4lgbHfWsNArysBQMfRXac76w0SYZt88rZU9i1eCOY4fNqBtOXrOMJfTsOMGqpHc3)fH29KdeiFbPQfRXac7eASIqnZuReA8e6YcHAiS3wE(NcaNlvbt1bB)qB)BkcnaHchtBybSaPkcAu9ebPhHNDKPhej0aeACe6Qju5heRPsBHY7H(RtOlleQHWEBn(c7c8eyCyJvaoHgpHUSqOXrOY)H6Ftz9k4lgbHfWcKQiOr1teKEeE2dvgV4eABcD7rQj4qLXloHgpHgGqne2BRXxyxGNaJdBScWj0Lfc145CcnaHU9i1eCOY4fNqzMqn3QMDKP)LMnFbPk43GooPQo1ISU2unlwJbe21TOzLNN45JMnoc9gVdWGyL2P35wVi02eQjfBcDzHqVX7amiwPD6DUvaoHgpHgGqL)d1)MYEo3RiaxOaIDPy7HkJxCcLzcfdJsHebPRGeAacv(pu)BkRxbFXiiSawGufbnQEIG0JWZEOY4fNqBtOXrOm1kHgdHYuReASIqpHc3)fHwVc(IXJd6iKhPMwSgdiStOXtOlleQXZ5eAacD7rQj4qLXloHYmHUES1SJm9V0Sn4a)lo43G)64PtTiMK2unlwJbe21TOzLNN45JMv(kgpGNNlgj0aeACe6nEhGbXkTtVZTErOTjuZTsOlle6nEhGbXkTtVZTcWj041SJm9V0S7bH8cb88vGRtTiXwBQMfRXac76w0SYZt88rZEJ3byqSs707CRxeABcD9wj0Lfc9gVdWGyL2P35wb4A2rM(xA29abHf4VoE6ulYQQnvZI1yaHDDlAw55jE(OzLQoH2ggHYeHgGq3EKAcouz8ItOTj0vTvcnaHghHk)hQ)nLLN)PaW5svWuDW2p0kvNlc5eABcTvcDzHqL)d1)MYYZ)ua4CPkyQoy7hApuz8ItOTjuZTsOXtObi04iu4yAdlGfivrqJQNii9i8SJm9GiHUSqOY)H6Ftz9k4lgbHfWcKQiOr1teKEeE2dvgV4eABc1CRe6YcHgCoFmGqR6d1bHfWIqJNqxwi04iuPQtOTHrOmrObi0ThPMGdvgV4ekZWi0vTvcnaHghHchtBybSaPkcwZQEIG0JWZoY0dIe6YcHk)hQ)nL1RGVyeewalqQIGgvprq6r4zpuz8ItOTj0ThPMGdvgV4eA8eAacnocv(pu)Bklp)tbGZLQGP6GTFOvQoxeYj02eARe6YcHk)hQ)nLLN)PaW5svWuDW2p0EOY4fNqBtOBpsnbhQmEXj0Lfc1qyVT88pfaoxQcMQd2(Hwb4eA8eA8e6YcHU9i1eCOY4fNqzMqnhBn7it)lnRXxyxGNaJdB0PwKvP2unlwJbe21TOzLNN45JMv(vxWtR8)R71Kyh87nwCpiAXAmGWUMDKP)LMLN)PaW5svWuDW2peS9WtI6ulsSqBQMfRXac76w0SYZt88rZk)hQ)nLLN)PaW5svWuDW2p0kvNlc5ekmcLjcDzHq3EKAcouz8ItOmtOm1kHUSqOXrO34DageR0o9o3EOY4fNqBtOMJnHUSqOXrORMqLFqSMkTIdD(ueAacD1eQ8dI1uPTq59q)1j04j0aeACeACe6nEhGbXkTtVZTErOTju5)q9VPS88pfaoxQcMQd2(H2Taee4qP6CriiDfKqxwi0vtO34DageR0o9o3IHDEYj04j0aeACeQ8FO(3uwVc(IrqybSaPkcAu9ebPhHN9qLXloH2MqL)d1)MYYZ)ua4CPkyQoy7hA3cqqGdLQZfHG0vqcDzHqdoNpgqOv9H6GWcyrOXtOXtObiu5)q9VPSBNNCWVbBHlK9qLXloHYmmcLbsObiuPQtOTHrOmrObiu5)q9VPSnQ(b5veOFt0xa4cLu1EOY4fNqzggHAMjcnEn7it)lnlp)tbGZLQGP6GTFOo1IWa1MQzXAmGWUUfnR88epF0SYpiwtLwXHoFkcnaHghHAiS32gCG)fh8BWFD8ScWj0LfcnocD7rQj4qLXloHYmHk)hQ)nLTbh4FXb)g8xhp7HkJxCcDzHqL)d1)MY2Gd8V4GFd(RJN9qLXloH2MqL)d1)MYYZ)ua4CPkyQoy7hA3cqqGdLQZfHG0vqcnEcnaHk)hQ)nLD78Kd(nylCHShQmEXjuMHrOmqcnaHkvDcTnmcLjcnaHk)hQ)nLTr1piVIa9BI(caxOKQ2dvgV4ekZWiuZmrOXRzhz6FPz55FkaCUufmvhS9d1PweZTQnvZI1yaHDDlAw55jE(OzLFqSMkTfkVh6VoHgGq7OHWEBn(c7c8eyCydOJgc7TvaoHgGqJJqHJPnSawGufbnQEIG0JWZoY0dIe6YcHgCoFmGqR6d1bHfWIqxwiu5)q9VPSEf8fJGWcybsve0O6jcspcp7HkJxCcTnHk)hQ)nLLN)PaW5svWuDW2p0UfGGahkvNlcbPRGe6YcHk)hQ)nL1RGVyeewalqQIGgvprq6r4zpuz8ItOTj01BLqJxZoY0)sZYZ)ua4CPkyQoy7hQtTiMnRnvZI1yaHDDlAw55jE(OzHJPnSawGufbnQEIG0JWZoY0dIe6YcHA8CoHgGq3EKAcouz8ItOmtOm1QMDKP)LM1lU8eYXacbmyHPsbfqhd6suNArmZK2unlwJbe21TOzLNN45JMfoM2Wcybsve0O6jcspcp7itpisOlleQXZ5eAacD7rQj4qLXloHYmHYuRA2rM(xA2MBsvE(fQtTiMxxBQMfRXac76w0SYZt88rZchtBybSaPkcAu9ebPhHNDKPhej0Lfc145CcnaHU9i1eCOY4fNqzMqzQvn7it)lnBe009j)JdmMEeQtTiMnjTPAwSgdiSRBrZoY0)sZ2pC6B)qqqKZrinR88epF0SRMqdoNpgqOnSawGVacCeKNxIXKqxwiu5)q9VPSEf8fJGWcybsve0O6jcspcp7HkJxCcTnHYuReAacfoM2Wcybsve0O6jcspcp7HkJxCcLzcLPwj0Lfcn4C(yaHw1hQdclGLMTgfuZ2pC6B)qqqKZriDQfXCS1MQzXAmGWUUfn7it)lnlxD6Ft0nC4G8turZkppXZhnlCmTHfWcKQiOr1teKEeE2rMEqKqxwiuJNZj0ae62JutWHkJxCcLzcLPwj0LfcD1e6ju4(Vi06vWxmECqhH8i10I1yaHDnBnkOMLRo9Vj6goCq(jQOtTiMxvTPAwSgdiSRBrZkppXZhn7Qj0GZ5JbeAdlGf4lGahb55Lymj0Lfcv(pu)BkRxbFXiiSawGufbnQEIG0JWZEOY4fNqBtOm1kHUSqObNZhdi0Q(qDqybS0SJm9V0ScCe4jQW1PweZRsTPAwSgdiSRBrZkppXZhn72JutWHkJxCcTnHYaBLqxwiu4yAdlGfivrqJQNii9i8SJm9GiHUSqObNZhdi0Q(qDqybSi0Lfc145CcnaHU9i1eCOY4fNqzMqnVQA2rM(xA28fKQGFdepNYOtTiMJfAt1Syngqyx3IMvEEINpAw5)q9VPSEf8fJGWcybsve0O6jcspcp7HkJxCcTnHUERe6YcHgCoFmGqR6d1bHfWIqxwiuJNZj0ae62JutWHkJxCcLzcLPw1SJm9V0Sgq)3bBHlKo1IyMbQnvZI1yaHDDlAw55jE(OzL)d1)MY6vWxmcclGfivrqJQNii9i8ShQmEXj02e66TsOlleAW58XacTQpuhewalcDzHqnEoNqdqOBpsnbhQmEXjuMjuZXwZoY0)sZAGhhpXEfPtTim1Q2un7it)lnlKhPMCadqOhPGvQzXAmGWUUfDQfHjZAt1Syngqyx3IMvEEINpAw5)q9VPSEf8fJGWcybsve0O6jcspcp7HkJxCcTnHUERe6YcHgCoFmGqR6d1bHfWIqxwiuJNZj0ae62JutWHkJxCcLzc1CRA2rM(xA2TFOb0)DDQfHjM0MQzXAmGWUUfnR88epF0SY)H6Ftz9k4lgbHfWcKQiOr1teKEeE2dvgV4eABcD9wj0Lfcn4C(yaHw1hQdclGfHUSqOgpNtObi0ThPMGdvgV4ekZektTQzhz6FPzNsI88giGCGG0PweMwxBQMfRXac76w0SYZt88rZAiS3wE(NcaNlvbt1bB)qB)Bkn7it)lnRXeb(nipxkMRtTimzsAt1Syngqyx3IMvEEINpAw(laz4v3cxGNcqiapb4P)LfRXac7eAac1qyVT88pfaoxQcMQd2(H2(3ueAacTJgc7T14lSlWtGXHnGoAiS32(3ueAac1qyVTgFHDbEcmoSX2)MsZoY0)sZUHqUQ8MDQtDQz74EeGsTPArmRnvZoY0)sZYHJZbuNQd455IrnlwJbe21TOtTimPnvZI1yaHDDlA2hUMLJPMDKP)LMn4C(yaHA2GdKaQzL)d1)MY6vWxmcclGfivrqJQNii9i8ShQmEXj02e62JutWHkJxCcDzHq3EKAcouz8ItOMGqL)d1)MY6vWxmcclGfivrqJQNii9i8ShQmEXjuMjuZm1kHgGqJJqJJqZbcR0YXdlpdzXAmGWoHgGq3EKAcouz8ItOTju5)q9VPSC8WYZq2dvgV4eAacv(pu)BklhpS8mK9qLXloH2Mqn3kHgpHUSqOXrOY)H6Ftz55FkaCUufmvhS9dTBbiiWHs15Iqq6kiHYmHU9i1eCOY4fNqdqOY)H6Ftz55FkaCUufmvhS9dTBbiiWHs15Iqq6kiH2MqnhBcnEcDzHqJJqL)d1)MYYZ)ua4CPkyQoy7hALQZfHCcfgH2kHgGqL)d1)MYYZ)ua4CPkyQoy7hApuz8ItOmtOBpsnbhQmEXj04j041SbNduJcQzvFOoiSaw6ulY6At1Syngqyx3IMvEEINpA24iudH92YXdlpdzfGtOlleQHWEB55FkaCUufmvhS9dTcWj04j0aekCmTHfWcKQiOr1teKEeE2rMEqKqxwiuJNZj0ae62JutWHkJxCcLzye6Q2QMDKP)LMf(N(x6ulIjPnvZI1yaHDDlAw55jE(Ozne2BlhpS8mKvaUMLNNltTiM1SJm9V0SYbccmY0)ca58uZc58euJcQz54HLNH0PwKyRnvZI1yaHDDlAw55jE(Ozne2BBdoW)Id(n4VoEwb4AwEEUm1IywZoY0)sZkhiiWit)laKZtnlKZtqnkOMTbh4FXb)g8xhpDQfzv1MQzXAmGWUUfnR88epF0SPRGekZeQjrObiuPQtOmtOXMqdqORMqHJPnSawGufbnQEIG0JWZoY0dIAwEEUm1IywZoY0)sZkhiiWit)laKZtnlKZtqnkOM9HJfE6ulYQuBQMfRXac76w0SJm9V0SBNNGFdsve0O6jcspcpnR88epF0Ssv3QmHjutqOsvNqBdJqxNqdqOXrOyHxuiB6kiiFGYeMqzMqntOllekw4ffYMUccYhOmHjuMjutIqdqOY)H6Ftz3op5GFd2cxi7HkJxCcLzc1Sn2e6YcHk)hQ)nLTbh4FXb)g8xhp7HkJxCcLzcLjcnEcnaHUAcTJgc7T14lSlWtGXHnGoAiS3wb4AwzijecY5IWKRfXSo1Iel0MQzXAmGWUUfnR88epF0Ssv3QmHjutqOsvNqBdJqntObi04iuSWlkKnDfeKpqzctOmtOMj0Lfcv(pu)BklhpS8mK9qLXloHYmHYeHUSqOyHxuiB6kiiFGYeMqzMqnjcnaHk)hQ)nLD78Kd(nylCHShQmEXjuMjuZ2ytOlleQ8FO(3u2gCG)fh8BWFD8ShQmEXjuMjuMi04j0ae6QjudH92A8f2f4jW4WgRaCn7it)lnlggocbuNtrNAryGAt1Syngqyx3IMDKP)LMn9i8aWhifnR88epF0SYxX4b88CXiHgGqLQUvzctOMGqLQoH2ggHYeHgGqJJqXcVOq20vqq(aLjmHYmHAMqxwiu5)q9VPSC8WYZq2dvgV4ekZekte6YcHIfErHSPRGG8bktycLzc1Ki0aeQ8FO(3u2TZto43GTWfYEOY4fNqzMqnBJnHUSqOY)H6FtzBWb(xCWVb)1XZEOY4fNqzMqzIqJNqdqORMq7OHWEBn(c7c8eyCydOJgc7TvaUMvgscHGCUim5ArmRtTiMBvBQMfRXac76w0SYZt88rZUAcnhiSslhpS8mKfRXac7AwEEUm1IywZoY0)sZkhiiWit)laKZtnlKZtqnkOMv2bCCRtTiMnRnvZI1yaHDDlAw55jE(OzZbcR0YXdlpdzXAmGWUMLNNltTiM1SJm9V0SYbccmY0)ca58uZc58euJcQzLDahpS8mKo1IyMjTPAwSgdiSRBrZkppXZhn7itpicWcvCKtOmtORRz555YulIzn7it)lnRCGGaJm9Vaqop1Sqopb1OGAwEQtTiMxxBQMfRXac76w0SYZt88rZoY0dIaSqfh5eABye66AwEEUm1IywZoY0)sZkhiiWit)laKZtnlKZtqnkOMDEuN6uZc)q5RymP2uTiM1MQzhz6FPzn(mHWoydnHWEJxrG8d7LMfRXac76w0PweM0MQzXAmGWUUfn7dxZYXuZoY0)sZgCoFmGqnBWbsa1SidwWHdh7wV4YtihdieWGfMkfuaDmOlrcDzHqrgSGdho2Trqt3N8poWy6riHUSqOidwWHdh72MBsvE(fsOllekYGfC4WXU9dINuDUiSdMYvgGXKjEHi0LfcfzWcoC4y3YvN(3eDdhoi)evi0LfcfzWcoC4y3MQiy7hpbCpYH0SbNduJcQzdlGf4lGahb55Lym1PwK11MQzhz6FPz3qixvEZo1Syngqyx3Io1IysAt1Syngqyx3IMvEEINpA2vtOYpiwtL2YJutWEqn7it)lnRu1bgchp1PwKyRnvZI1yaHDDlAw55jE(OzxnHMdewPfl8I8vrVIaiKhgplwJbe21SJm9V0Ssvh0mbrDQtn78O2uTiM1MQzhz6FPzBu9dYRiq)MOVaWfkPQMfRXac76w0PweM0MQzXAmGWUUfnR88epF0Ssv3QmHjutqOsvNqBdJqzIqdqOyHxuiB6kiiFGYeMqBtOmrOlleQu1Tktyc1eeQu1j02WiutsZoY0)sZIfEr(QOxraeYd7No1ISU2unlwJbe21TOzLNN45JMv(kgpGNNlgj0aeACeQHWEB7tjrWVbsvNb4wb4e6YcH2rdH92A8f2f4jW4Wgqhne2BRaCcnEn7it)lnlhUxLxra5nfce7sX6ulIjPnvZI1yaHDDlAw55jE(OzXcVOq20vqq(aLjmH2MqXWOuirq6kiHUSqOsv3QmHjutqOsvNqzggHAwZoY0)sZUDEYb)gSfUq6ulsS1MQzXAmGWUUfn7it)ln75CVIaCHci2LI1SYZt88rZghHMdewPTr1piVIa9BI(caxOKQwSgdiStObiu5)q9VPSNZ9kcWfkGyxk22fUj9Vi02eQ8FO(3u2gv)G8kc0Vj6laCHsQApuz8ItOXqOMeHgpHgGqJJqL)d1)MYUDEYb)gSfUq2dvgV4eABcDDcDzHqLQoH2ggHgBcnEnRmKecb5CryY1IywNArwvTPAwSgdiSRBrZkppXZhnRHWEBpbUQxragW0rqJxDB)Bkn7it)ln7jWv9kcWaMocA8QRtTiRsTPAwSgdiSRBrZkppXZhnRu1Tktyc1eeQu1j02WiuZA2rM(xAwmmCecOoNIo1Iel0MQzXAmGWUUfn7it)ln725j43GufbnQEIG0JWtZkppXZhnRu1Tktyc1eeQu1j02Wi011SYqsieKZfHjxlIzDQfHbQnvZI1yaHDDlAw55jE(OzLQUvzctOMGqLQoH2ggHYKMDKP)LMvQ6adHJN6ulI5w1MQzXAmGWUUfnR88epF0Sgc7TnvraQahV)4a5aFKE(NLNJumH2MqnZaj0aekw4ffYMUccYhOmHj02ekggLcjcsxbjutqOMj0aeQ8FO(3u2TZto43GTWfYEOY4fNqBtOyyukKiiDfuZoY0)sZkVrkgYRiady6iaYJuZYRiDQfXSzTPAwSgdiSRBrZoY0)sZMEeEa4dKIMvEEINpAwPQBvMWeQjiuPQtOTHrOmrObi04i0vtO5aHvAv9eiFfJ3I1yaHDcDzHqLVIXd455IrcnEnRmKecb5CryY1IywNArmZK2unlwJbe21TOzLNN45JMvQ6wLjmHAccvQ6eAByeQzn7it)ln7CYPqq(3HvQtTiMxxBQMfRXac76w0SYZt88rZkFfJhWZZfJeAacnocv(pu)BkRXxyxGNaJdBShQmEXj02ekte6YcHUAcv(bXAQ0wO8EO)6eA8eAacnocvQ6eAByeASj0Lfcv(pu)Bk725jh8BWw4czpuz8ItOTj0vLqxwiu5)q9VPSBNNCWVbBHlK9qLXloH2MqxNqdqOsvNqBdJqxNqdqOyHxuiB6kiiFqSBLqzMqntOllekw4ffYMUccYhOmHjuMHrOXrORtOXqORtOXkcv(pu)Bk725jh8BWw4czpuz8ItOmtOXMqJNqxwiudH92YZ)ua4CPkyQoy7hAfGtOXRzhz6FPz5W9Q8kciVPqGyxkwNArmBsAt1Syngqyx3IMvEEINpAw5Ry8aEEUyuZoY0)sZkvDqZee1PweZXwBQMfRXac76w0SJm9V0SBOqEfb44bhRei2LI1SYZt88rZAiS3wJxma(9sB)BknRxjENa8uZAwNArmVQAt1Syngqyx3IMDKP)LM1aAKIFHei2LI1SYZt88rZkFfJhWZZfJeAacnoc1qyVTgVya87Lwb4e6YcHMdewPv1tG8vmElwJbe2j0aek8ddcIKDRzB6r4bGpqkeAacvQ6ekmcLjcnaHk)hQ)nLD78Kd(nylCHShQmEXjuMj01j0LfcvQ6wLjmHAccvQ6ekZWiuZeAacf(HbbrYU1SLd3RYRiG8McbIDPycnaHIfErHSPRGG8bktycLzcDDcnEnRmKecb5CryY1IywN6uNA2G4X9V0IWuRmz2mtmTk1SnZvEfX1SRzg01erILeHbXAqOeQPQiH6kW)lj09FekdBWb(xCWVb)1XJHe6Hmyb)WoHYFfKqhH8vMe7eQuDQiKBjmU2EHektRbHUwFfeVe7ekdZbcR0AYmKqZNqzyoqyLwt2I1yaHDgsOtsOXYRPRnHgN5WXBjmU2EHe66RbHUwFfeVe7ekdZbcR0AYmKqZNqzyoqyLwt2I1yaHDgsOtsOXYRPRnHgN5WXBjmU2EHektTUge6A9vq8sStOmmhiSsRjZqcnFcLH5aHvAnzlwJbe2ziHgN5WXBjmsyCnZGUMisSKimiwdcLqnvfjuxb(FjHU)JqzihpS8medj0dzWc(HDcL)kiHoc5Rmj2juP6uri3syCT9cjuZTUge6A9vq8sStOmmhiSsRjZqcnFcLH5aHvAnzlwJbe2ziHojHglVMU2eACMdhVLWiHX1md6AIiXsIWGyniuc1uvKqDf4)Le6(pcLHYoGJhwEgIHe6Hmyb)WoHYFfKqhH8vMe7eQuDQiKBjmU2EHekdCni016RG4LyNqz4ju4(Vi0AYmKqZNqz4ju4(Vi0AYwSgdiSZqcnoZHJ3syCT9cjuZM0AqOR1xbXlXoHYWtOW9FrO1KziHMpHYWtOW9FrO1KTyngqyNHe6KeAS8A6AtOXzoC8wcJRTxiHYK51GqxRVcIxIDcLH8xaYWRU1KziHMpHYq(laz4v3AYwSgdiSZqcnoZHJ3syKW4AMbDnrKyjryqSgekHAQksOUc8)scD)hHYqEYqc9qgSGFyNq5VcsOJq(ktIDcvQoveYTegxBVqc1KwdcDT(kiEj2jugYFbidV6wtMHeA(ekd5VaKHxDRjBXAmGWodj04mhoElHX12lKqJ9AqOR1xbXlXoHYWCGWkTMmdj08jugMdewP1KTyngqyNHeACMdhVLW4A7fsORY1GqxRVcIxIDcLH5aHvAnzgsO5tOmmhiSsRjBXAmGWodj04mhoElHX12lKqnh71GqxRVcIxIDcLH5aHvAnzgsO5tOmmhiSsRjBXAmGWodj04mhoElHrcJRzg01erILeHbXAqOeQPQiH6kW)lj09FekdLDah3mKqpKbl4h2ju(RGe6iKVYKyNqLQtfHClHX12lKqzAni016RG4LyNqz4ju4(Vi0AYmKqZNqz4ju4(Vi0AYwSgdiSZqcnoZHJ3syCT9cj01xdcDT(kiEj2jugEcfU)lcTMmdj08jugEcfU)lcTMSfRXac7mKqJZC44TegxBVqc1CSxdcDT(kiEj2jugEcfU)lcTMmdj08jugEcfU)lcTMSfRXac7mKqNKqJLxtxBcnoZHJ3syCT9cjuMmP1GqxRVcIxIDcLH8xaYWRU1KziHMpHYq(laz4v3AYwSgdiSZqcnoZHJ3syKW4AMbDnrKyjryqSgekHAQksOUc8)scD)hHYWoUhbOKHe6Hmyb)WoHYFfKqhH8vMe7eQuDQiKBjmU2EHektRbHUwFfeVe7ekdZbcR0AYmKqZNqzyoqyLwt2I1yaHDgsOXzoC8wcJRTxiHAU11GqxRVcIxIDcLH5aHvAnzgsO5tOmmhiSsRjBXAmGWodj0jj0y5101MqJZC44TegxBVqc1S51GqxRVcIxIDcLH5aHvAnzgsO5tOmmhiSsRjBXAmGWodj0jj0y5101MqJZC44TegjmUMzqxtejwsegeRbHsOMQIeQRa)VKq3)rOmCEKHe6Hmyb)WoHYFfKqhH8vMe7eQuDQiKBjmU2EHeASxdcDT(kiEj2jugMdewP1KziHMpHYWCGWkTMSfRXac7mKqJZC44TegxBVqc1S51GqxRVcIxIDcLH5aHvAnzgsO5tOmmhiSsRjBXAmGWodj04mhoElHX12lKqnVQRbHUwFfeVe7ekdZbcR0AYmKqZNqzyoqyLwt2I1yaHDgsOXzoC8wcJegJLuG)xIDcLbsOJm9ViuiNNClHrnl873oeQzJ1XAcDn7vVzGeJhHYG0VetymwhRj0vb04eMleHYKzrjuMALjMimsymwhRj01sDUiKVgegJ1XAc1eeQPn4iMqxfCEYj0FtORccxic1ReVtaEsOqFKlTegJ1XAc1eeQPn4iMqzH7v5veHUw3uiHYGSlftOqFKlTegJ1XAc1eekdAVtOgpNV9i1KqLQOumNqZNqvMkeHUwmiHqXkph5wcJX6ynHAccLbT3juVmH8vmMKqxfGqUQ8MDAjmsymwhRj0y5WOuiXoHAG7)qcv(kgtsOgyKxClHYGkLi8KtO1xMqDoLTaeHoY0)ItOFbfYsyCKP)f3c)q5RymzmWwX4Zec7Gn0ec7nEfbYpSxeghz6FXTWpu(kgtgdSvcoNpgqOO1OGWclGf4lGahb55Lymf9HdJJPObhibegYGfC4WXU1lU8eYXacbmyHPsbfqhd6sCzbzWcoC4y3gbnDFY)4aJPhHllidwWHdh72MBsvE(fUSGmybhoCSB)G4jvNlc7GPCLbymzIxOLfKbl4WHJDlxD6Ft0nC4G8tuzzbzWcoC4y3MQiy7hpbCpYHimoY0)IBHFO8vmMmgyRSHqUQ8MDsyCKP)f3c)q5RymzmWwrQ6adHJNI6ByRw(bXAQ0wEKAc2dsyCKP)f3c)q5RymzmWwrQ6GMjikQVHT6CGWkTyHxKVk6veaH8W4zXAmGWoHrcJX6ynHglhgLcj2jumiEHi00vqcnvrcDK5FeQZj0j44qJbeAjmoY0)IdJdhNdOovhWZZfJeghz6FXJb2kbNZhdiu0AuqyQpuhewalrF4W4ykAWbsaHj)hQ)nL1RGVyeewalqQIGgvprq6r4zpuz8I3E7rQj4qLXl(YY2JutWHkJxCti)hQ)nL1RGVyeewalqQIGgvprq6r4zpuz8IZSzMAnqCXLdewPLJhwEgkW2JutWHkJx82Y)H6Ftz54HLNHShQmEXdi)hQ)nLLJhwEgYEOY4fVT5wJFzjo5)q9VPS88pfaoxQcMQd2(H2Taee4qP6CriiDfK5ThPMGdvgV4bK)d1)MYYZ)ua4CPkyQoy7hA3cqqGdLQZfHG0vW2MJD8llXj)hQ)nLLN)PaW5svWuDW2p0kvNlc5WAnG8FO(3uwE(NcaNlvbt1bB)q7HkJxCM3EKAcouz8IhF8eghz6FXJb2kW)0)suFdlodH92YXdlpdzfGVSyiS3wE(NcaNlvbt1bB)qRa84dahtBybSaPkcAu9ebPhHNDKPhexwmEopW2JutWHkJxCMHTQTsyCKP)fpgyRihiiWit)laKZtrRrbHXXdlpdjkppxMWmlQVHziS3woEy5ziRaCcJJm9V4XaBf5abbgz6FbGCEkAnkiSgCG)fh8BWFD8eLNNltyMf13Wme2BBdoW)Id(n4VoEwb4eghz6FXJb2kYbccmY0)ca58u0AuqypCSWtuEEUmHzwuFdlDfKztkGu1zo2bwnCmTHfWcKQiOr1teKEeE2rMEqKW4it)lEmWwz78e8BqQIGgvprq6r4jQmKecb5CryYHzwuFdtQ6wLjSjKQEByRhioSWlkKnDfeKpqzcZS5LfSWlkKnDfeKpqzcZSjfq(pu)Bk725jh8BWw4czpuz8IZSzBSxwK)d1)MY2Gd8V4GFd(RJN9qLXloZmfFGv3rdH92A8f2f4jW4Wgqhne2BRaCcJJm9V4XaBfmmCecOoNIO(gMu1Tktytiv92WmhioSWlkKnDfeKpqzcZS5Lf5)q9VPSC8WYZq2dvgV4mZ0Ycw4ffYMUccYhOmHz2Kci)hQ)nLD78Kd(nylCHShQmEXz2Sn2llY)H6FtzBWb(xCWVb)1XZEOY4fNzMIpWQne2BRXxyxGNaJdBScWjmoY0)IhdSvspcpa8bsruzijecY5IWKdZSO(gM8vmEappxmgqQ6wLjSjKQEBymfioSWlkKnDfeKpqzcZS5Lf5)q9VPSC8WYZq2dvgV4mZ0Ycw4ffYMUccYhOmHz2Kci)hQ)nLD78Kd(nylCHShQmEXz2Sn2llY)H6FtzBWb(xCWVb)1XZEOY4fNzMIpWQ7OHWEBn(c7c8eyCydOJgc7TvaoHXrM(x8yGTICGGaJm9VaqopfTgfeMSd44wuEEUmHzwuFdB15aHvA54HLNHimoY0)IhdSvKdeeyKP)faY5PO1OGWKDahpS8mKO88CzcZSO(gwoqyLwoEy5zicJJm9V4XaBf5abbgz6FbGCEkAnkimEkkppxMWmlQVHnY0dIaSqfh5mVoHXrM(x8yGTICGGaJm9VaqopfTgfe28OO88CzcZSO(g2itpicWcvCK3g26egjmoY0)IBNhH1O6hKxrG(nrFbGlusvcJJm9V425XyGTcw4f5RIEfbqipSFI6Bysv3QmHnHu1BdJPayHxuiB6kiiFGYeUntllsv3QmHnHu1BdZKimoY0)IBNhJb2kC4EvEfbK3uiqSlflQVHjFfJhWZZfJbIZqyVT9PKi43aPQZaCRa8LLoAiS3wJVWUapbgh2a6OHWEBfGhpHXrM(xC78ymWwz78Kd(nylCHe13WWcVOq20vqq(aLjCBmmkfseKUcUSivDRYe2esvNzyMjmoY0)IBNhJb2kNZ9kcWfkGyxkwuzijecY5IWKdZSO(gwC5aHvABu9dYRiq)MOVaWfkPAa5)q9VPSNZ9kcWfkGyxk22fUj9VAl)hQ)nLTr1piVIa9BI(caxOKQ2dvgV4XysXhio5)q9VPSBNNCWVbBHlK9qLXlE71xwKQEByXoEcJJm9V425XyGTYjWv9kcWaMocA8QlQVHziS32tGR6veGbmDe04v32)MIW4it)lUDEmgyRGHHJqa15ue13WKQUvzcBcPQ3gMzcJJm9V425XyGTY25j43GufbnQEIG0JWtuzijecY5IWKdZSO(gMu1Tktytiv92WwNW4it)lUDEmgyRivDGHWXtr9nmPQBvMWMqQ6THXeHXrM(xC78ymWwrEJumKxragW0raKhPMLxrI6Bygc7TnvraQahV)4a5aFKE(NLNJuCBZmWayHxuiB6kiiFGYeUnggLcjcsxbnH5aY)H6Ftz3op5GFd2cxi7HkJx82yyukKiiDfKW4it)lUDEmgyRKEeEa4dKIOYqsieKZfHjhMzr9nmPQBvMWMqQ6THXuG4wDoqyLwvpbYxX4xwKVIXd455IX4jmoY0)IBNhJb2kZjNcb5FhwPO(gMu1Tktytiv92WmtyCKP)f3opgdSv4W9Q8kciVPqGyxkwuFdt(kgpGNNlgdeN8FO(3uwJVWUapbgh2ypuz8I3MPLLvl)GynvAluEp0F94deNu1Bdl2llY)H6Ftz3op5GFd2cxi7HkJx82R6YI8FO(3u2TZto43GTWfYEOY4fV96bKQEByRhal8Icztxbb5dIDRmBEzbl8Icztxbb5duMWmdlU1Jz9yL8FO(3u2TZto43GTWfYEOY4fN5yh)YIHWEB55FkaCUufmvhS9dTcWJNW4it)lUDEmgyRivDqZeef13WKVIXd455IrcJJm9V425XyGTYgkKxraoEWXkbIDPyr9nmdH92A8IbWVxA7FtjQxjENa8eMzcJJm9V425XyGTIb0if)cjqSlflQmKecb5CryYHzwuFdt(kgpGNNlgdeNHWEBnEXa43lTcWxwYbcR0Q6jq(kgFa4hgeej7wZ20JWdaFGucivDymfq(pu)Bk725jh8BWw4czpuz8IZ86llsv3QmHnHu1zgM5aWpmiis2TMTC4EvEfbK3uiqSlfhal8Icztxbb5duMWmVE8egjmoY0)IBLDah3W8k4lgbHfWcKQiOr1teKEeEI6ByRo4C(yaHw1hQdclGvG4K)d1)MYEo3RiaxOaIDPy7HkJxCMzAzz1YpiwtLwXHoFQ4de3QLFqSMkTfkVh6V(YI8FO(3uwJVWUapbgh2ypuz8IZmtXVSS9i1eCOY4fNzMInHXrM(xCRSd44ogyRKVGuf8BqhNuvuFdB7rQj4qLXlE74mhlA1eNqH7)Iq7EYbcKVGunwzMPwJFzXqyVT88pfaoxQcMQd2(H2(3ubGJPnSawGufbnQEIG0JWZoY0dIbIB1YpiwtL2cL3d9xFzXqyVTgFHDbEcmoSXkap(LL4K)d1)MY6vWxmcclGfivrqJQNii9i8ShQmEXBV9i1eCOY4fp(agc7T14lSlWtGXHnwb4llgpNhy7rQj4qLXloZMBLW4it)lUv2bCChdSvAWb(xCWVb)1XtuFdlUB8oadIvANENB9QTjf7LLB8oadIvANENBfGhFa5)q9VPSNZ9kcWfkGyxk2EOY4fNzmmkfseKUcgq(pu)BkRxbFXiiSawGufbnQEIG0JWZEOY4fVDCm1Amm1AS6ekC)xeA9k4lgpoOJqEKAg)YIXZ5b2EKAcouz8IZ86XMW4it)lUv2bCChdSv2dc5fc45RaxuFdt(kgpGNNlgde3nEhGbXkTtVZTE12CRll34DageR0o9o3kapEcJJm9V4wzhWXDmWwzpqqyb(RJNO(g2nEhGbXkTtVZTE1E9wxwUX7amiwPD6DUvaoHXrM(xCRSd44ogyRy8f2f4jW4Wgr9nmPQ3ggtb2EKAcouz8I3EvBnqCY)H6Ftz55FkaCUufmvhS9dTs15IqE7wxwK)d1)MYYZ)ua4CPkyQoy7hApuz8I32CRXhio4yAdlGfivrqJQNii9i8SJm9G4YI8FO(3uwVc(IrqybSaPkcAu9ebPhHN9qLXlEBZTUSeCoFmGqR6d1bHfWk(LL4KQEBymfy7rQj4qLXloZWw1wdehCmTHfWcKQiynR6jcspcp7itpiUSi)hQ)nL1RGVyeewalqQIGgvprq6r4zpuz8I3E7rQj4qLXlE8bIt(pu)Bklp)tbGZLQGP6GTFOvQoxeYB36YI8FO(3uwE(NcaNlvbt1bB)q7HkJx82BpsnbhQmEXxwme2Blp)tbGZLQGP6GTFOvaE8XVSS9i1eCOY4fNzZXMW4it)lUv2bCChdSv45FkaCUufmvhS9dbBp8KOO(gM8RUGNw5)x3RjXo43BS4Eq0I1yaHDcJJm9V4wzhWXDmWwHN)PaW5svWuDW2puuFdt(pu)Bklp)tbGZLQGP6GTFOvQoxeYHX0YY2JutWHkJxCMzQ1LL4UX7amiwPD6DU9qLXlEBZXEzjUvl)GynvAfh68PcSA5heRPsBHY7H(RhFG4I7gVdWGyL2P35wVAl)hQ)nLLN)PaW5svWuDW2p0UfGGahkvNlcbPRGllR(gVdWGyL2P35wmSZtE8bIt(pu)BkRxbFXiiSawGufbnQEIG0JWZEOY4fVT8FO(3uwE(NcaNlvbt1bB)q7waccCOuDUieKUcUSeCoFmGqR6d1bHfWk(4di)hQ)nLD78Kd(nylCHShQmEXzggdmGu1BdJPaY)H6FtzBu9dYRiq)MOVaWfkPQ9qLXloZWmZu8eghz6FXTYoGJ7yGTcp)tbGZLQGP6GTFOO(gM8dI1uPvCOZNkqCgc7TTbh4FXb)g8xhpRa8LL42EKAcouz8IZS8FO(3u2gCG)fh8BWFD8ShQmEXxwK)d1)MY2Gd8V4GFd(RJN9qLXlEB5)q9VPS88pfaoxQcMQd2(H2Taee4qP6CriiDfm(aY)H6Ftz3op5GFd2cxi7HkJxCMHXadiv92WykG8FO(3u2gv)G8kc0Vj6laCHsQApuz8IZmmZmfpHXrM(xCRSd44ogyRWZ)ua4CPkyQoy7hkQVHj)GynvAluEp0F9aD0qyVTgFHDbEcmoSb0rdH92kapqCWX0gwalqQIGgvprq6r4zhz6bXLLGZ5JbeAvFOoiSawllY)H6Ftz9k4lgbHfWcKQiOr1teKEeE2dvgV4TL)d1)MYYZ)ua4CPkyQoy7hA3cqqGdLQZfHG0vWLf5)q9VPSEf8fJGWcybsve0O6jcspcp7HkJx82R3A8eghz6FXTYoGJ7yGTIxC5jKJbecyWctLckGog0LOO(ggCmTHfWcKQiOr1teKEeE2rMEqCzX458aBpsnbhQmEXzMPwjmoY0)IBLDah3XaBLMBsvE(fkQVHbhtBybSaPkcAu9ebPhHNDKPhexwmEopW2JutWHkJxCMzQvcJJm9V4wzhWXDmWwjcA6(K)Xbgtpcf13WGJPnSawGufbnQEIG0JWZoY0dIllgpNhy7rQj4qLXloZm1kHXrM(xCRSd44ogyRiWrGNOIO1OGW6ho9TFiiiY5iKO(g2QdoNpgqOnSawGVacCeKNxIXCzr(pu)BkRxbFXiiSawGufbnQEIG0JWZEOY4fVntTgaoM2Wcybsve0O6jcspcp7HkJxCMzQ1LLGZ5JbeAvFOoiSaweghz6FXTYoGJ7yGTIahbEIkIwJccJRo9Vj6goCq(jQiQVHbhtBybSaPkcAu9ebPhHNDKPhexwmEopW2JutWHkJxCMzQ1LLvFcfU)lcTEf8fJhh0ripsnjmoY0)IBLDah3XaBfboc8ev4I6ByRo4C(yaH2Wcyb(ciWrqEEjgZLf5)q9VPSEf8fJGWcybsve0O6jcspcp7HkJx82m16YsW58XacTQpuhewalcJJm9V4wzhWXDmWwjFbPk43aXZPmI6ByBpsnbhQmEXBZaBDzboM2Wcybsve0O6jcspcp7itpiUSeCoFmGqR6d1bHfWAzX458aBpsnbhQmEXz28QsyCKP)f3k7aoUJb2kgq)3bBHlKO(gM8FO(3uwVc(IrqybSaPkcAu9ebPhHN9qLXlE71BDzj4C(yaHw1hQdclG1YIXZ5b2EKAcouz8IZmtTsyCKP)f3k7aoUJb2kg4XXtSxrI6ByY)H6Ftz9k4lgbHfWcKQiOr1teKEeE2dvgV4TxV1LLGZ5JbeAvFOoiSawllgpNhy7rQj4qLXloZMJnHXrM(xCRSd44ogyRa5rQjhWae6rkyLeghz6FXTYoGJ7yGTY2p0a6)UO(gM8FO(3uwVc(IrqybSaPkcAu9ebPhHN9qLXlE71BDzj4C(yaHw1hQdclG1YIXZ5b2EKAcouz8IZS5wjmoY0)IBLDah3XaBLPKipVbcihiir9nm5)q9VPSEf8fJGWcybsve0O6jcspcp7HkJx82R36YsW58XacTQpuhewaRLfJNZdS9i1eCOY4fNzMALW4it)lUv2bCChdSvmMiWVb55sXCr9nmdH92YZ)ua4CPkyQoy7hA7FtryCKP)f3k7aoUJb2kBiKRkVzNI6By8xaYWRUfUapfGqaEcWt)Ragc7TLN)PaW5svWuDW2p02)Mkqhne2BRXxyxGNaJdBaD0qyVT9VPcyiS3wJVWUapbgh2y7FtryKW4it)lUv2bC8WYZqWcoNpgqOO1OGW44HLNHagchpf9HdJJPObhibeM8FO(3uwoEy5zi7HkJxCMnVSahtBybSaPkcAu9ebPhHNDKPhedi)hQ)nLLJhwEgYEOY4fV96TUSy8CEGThPMGdvgV4mZuReghz6FXTYoGJhwEgkgyR4vWxmcclGfivrqJQNii9i8e13WwDW58XacTQpuhewaRLfJNZdS9i1eCOY4fNzMInHXrM(xCRSd44HLNHIb2kgq)3bBHlKO(gwW58XacTC8WYZqadHJNeghz6FXTYoGJhwEgkgyRyGhhpXEfjQVHfCoFmGqlhpS8meWq44jHXrM(xCRSd44HLNHIb2kqEKAYbmaHEKcwjHXrM(xCRSd44HLNHIb2kB)qdO)7I6BybNZhdi0YXdlpdbmeoEsyCKP)f3k7aoEy5zOyGTYusKN3abKdeKO(gwW58XacTC8WYZqadHJNeghz6FXTYoGJhwEgkgyRymrGFdYZLI5I6BybNZhdi0YXdlpdbmeoEsyCKP)f3k7aoEy5zOyGTs(csvWVbDCsvr9nSThPMGdvgV4TJZCSOvtCcfU)lcT7jhiq(cs1yLzMAn(Lf4yAdlGfivrqJQNii9i8SJm9GyG4wT8dI1uPTq59q)1xwme2BRXxyxGNaJdBScWJFzjo5)q9VPSEf8fJGWcybsve0O6jcspcp7HkJx82BpsnbhQmEXJpGHWEBn(c7c8eyCyJva(YIXZ5b2EKAcouz8IZS5wjmoY0)IBLDahpS8mumWwPbh4FXb)g8xhpr9nm5)q9VPSNZ9kcWfkGyxk2EOY4fNzmmkfseKUcsyCKP)f3k7aoEy5zOyGTIxC5jKJbecyWctLckGog0LOO(gwW58XacTC8WYZqadHJNeghz6FXTYoGJhwEgkgyR0CtQYZVqr9nSGZ5JbeA54HLNHagchpjmoY0)IBLDahpS8mumWwjcA6(K)Xbgtpcf13WcoNpgqOLJhwEgcyiC8KW4it)lUv2bC8WYZqXaBfboc8eveTgfegxD6Ft0nC4G8turuFddoM2Wcybsve0O6jcspcp7itpiUSy8CEGThPMGdvgV4mZuRllR(ekC)xeA9k4lgpoOJqEKAsyCKP)f3k7aoEy5zOyGTIahbEIkCr9nSvhCoFmGqBybSaFbe4iipVeJ5YI8FO(3uwVc(IrqybSaPkcAu9ebPhHN9qLXlEBMADzj4C(yaHw1hQdclGfHXrM(xCRSd44HLNHIb2k7bH8cb88vGtyCKP)f3k7aoEy5zOyGTYEGGWc8xhpcJJm9V4wzhWXdlpdfdSvm(c7c8eyCyJO(gMXZ5b2EKAcouz8IZS5yVSeNu1BdJPaXT9i1eCOY4fV9Q2AG4It(pu)BklhpS8mK9qLXlEBZTUSyiS3woEy5ziRa8Lf5)q9VPSC8WYZqwb4Xhio4yAdlGfivrqJQNii9i8SJm9G4YI8FO(3uwVc(IrqybSaPkcAu9ebPhHN9qLXlEBZTUSeCoFmGqR6d1bHfWk(4JFzjUThPMGdvgV4mdBvBnqCWX0gwalqQIG1SQNii9i8SJm9G4YI8FO(3uwVc(IrqybSaPkcAu9ebPhHN9qLXlE7ThPMGdvgV4XhF8eghz6FXTYoGJhwEgkgyRWXdlpdjQVHj)hQ)nL9CUxraUqbe7sX2dvgV4mZ0YIXZ5b2EKAcouz8IZS5ytyCKP)f3k7aoEy5zOyGTIXeb(nipxkMtyCKP)f3k7aoEy5zOyGTYgc5QYB2PO(gg)fGm8QBHlWtbieGNa80)kGHWEB54HLNHS9VPc0rdH92A8f2f4jW4Wgqhne2BB)BQagc7T14lSlWtGXHn2(3uegjmoY0)IBF4yHhSTZtWVbPkcAu9ebPhHNOYqsieKZDryYHzwuFdtQ6wLjSjKQEByRtyCKP)f3(WXcVyGTcggocbuNtruFdlhiSsRu1bgchpTyngqypGu1Tktytiv92WwNW4it)lU9HJfEXaBL0JWdaFGuevgscHGCUim5WmlQVHjFfJhWZZfJbKQUvzcBcPQ3ggteghz6FXTpCSWlgyRivDqZeef13WKQUvzcBcPQdJjcJJm9V42how4fdSvWWWriG6Ckeghz6FXTpCSWlgyRKEeEa4dKIOYqsieKZfHjhMzr9nmPQBvMWMqQ6THXeHrcJJm9V4woEy5ziyBNNCWVbBHlKO(gMHWEB54HLNHShQmEXz2mHXrM(xClhpS8mumWwHd3RYRiG8McbIDPyr9nm5Ry8aEEUymqCJm9GialuXrEByRVSmY0dIaSqfh5Tnhy1Y)H6FtzpN7veGluaXUuSvaE8eghz6FXTC8WYZqXaBLZ5Efb4cfqSlflQmKecb5CryYHzwuFdt(kgpGNNlgjmoY0)IB54HLNHIb2kBNNCWVbBHlKO(g2itpicWcvCK3g26eghz6FXTC8WYZqXaBfoCVkVIaYBkei2LIf13WKVIXd455IXagc7TTpLeb)givDgGBfGtyCKP)f3YXdlpdfdSvmGgP4xibIDPyrLHKqiiNlctomZI6ByYxX4b88CXyadH922Gd8V4GFd(RJNvaEa5)q9VPSNZ9kcWfkGyxk2EOY4fVnteghz6FXTC8WYZqXaBLTZto43GTWfsuVs8ob4jW3Wme2BlhpS8mKvaEa5)q9VPSNZ9kcWfkGyxk2E40dryCKP)f3YXdlpdfdSv4W9Q8kciVPqGyxkwuFdt(kgpGNNlgd0rdH92A8f2f4jW4Wgqhne2BRaCcJJm9V4woEy5zOyGTY25j43GufbnQEIG0JWtuzijecY5IWKdZSO(gMu1zEDcJJm9V4woEy5zOyGTIb0if)cjqSlflQmKecb5CryYHzwuFdt(kgpGNNlgxwwDoqyLwvpbYxX4jmoY0)IB54HLNHIb2kC4EvEfbK3uiqSlftyKW4it)lULNWAu9dYRiq)MOVaWfkPQO(g2nEhGbXkTtVZTE1w(pu)BkBJQFqEfb63e9faUqjvTDHBs)RyvR2yXYYnEhGbXkTtVZTcWjmoY0)IB5zmWwbl8I8vrVIaiKh2pr9nmPQBvMWMqQ6THXuaSWlkKnDfeKpqzc3E9LfPQBvMWMqQ6THzsbIdl8Icztxbb5duMWTzAzz1Wpmiis2TMTPhHha(aPepHXrM(xClpJb2kC4EvEfbK3uiqSlflQVHjFfJhWZZfJbme2BBFkjc(nqQ6ma3kapqC34DageR0o9o36vBdH922NsIGFdKQodWThQmEXnbtll34DageR0o9o3kapEcJJm9V4wEgdSv2qixvEZof1ReVtaEcCffS7tIWmlQxjENa8e4Bygc7Tn4dnPdHa(dfeReOkOm17DRa8LfSWlkKnDfeKpqzcZ86llY)H6FtzpN7veGluaXUuS9qLXloZmTSi)hQ)nLD78Kd(nylCHShQmEXzMjr9nm(laz4v3g8HM0Hqa)HcIvgWqyVT88pfaoxQcMQd2(H2(3ub6OHWEBn(c7c8eyCydOJgc7TT)nfHXrM(xClpJb2kNZ9kcWfkGyxkwuzijecY5IWKdZSO(gM8FO(3uwoEy5zi7HkJx82MxwwDoqyLwoEy5zOaXj)hQ)nLTbh4FXb)g8xhp7HkJx82M0YYQLFqSMkTIdD(uXtyCKP)f3YZyGTY25jh8BWw4cjQVHf3nEhGbXkTtVZTE1w(pu)Bk725jh8BWw4cz7c3K(xXQwTXILLB8oadIvANENBfGhFG4WcVOq20vqq(aLjCBmmkfseKUcAcZllsv3QmHnHu1zgM5LfdH92YZ)ua4CPkyQoy7hApuz8IZmggLcjcsxbJXC8llBpsnbhQmEXzgdJsHebPRGXyEzPJgc7T14lSlWtGXHnGoAiS3wb4eghz6FXT8mgyRiVrkgYRiady6iaYJuZYRir9nmdH92MQiavGJ3FCGCGpsp)ZYZrkUTzgyaSWlkKnDfeKpqzc3gdJsHebPRGMWCa5)q9VPSNZ9kcWfkGyxk2EOY4fVnggLcjcsxbxwme2BBQIauboE)XbYb(i98plphP42MnPaXj)hQ)nLLJhwEgYEOY4fN5yhihiSslhpS8m0YI8FO(3u2gCG)fh8BWFD8ShQmEXzo2bKFqSMkTIdD(ullBpsnbhQmEXzo2XtyCKP)f3YZyGTYjWv9kcWaMocA8QlQVHziS32tGR6veGbmDe04v32)MkWitpicWcvCK32mHXrM(xClpJb2kBNNGFdsve0O6jcspcprLHKqiiNlctomZI6BysvN51jmoY0)IB5zmWwbddhHaQZPiQVHjvDRYe2esvVnmZeghz6FXT8mgyRivDGHWXtr9nmPQBvMWMqQ6THzoWitpicWcvCKdZCGB8oadIvANENB9QntTUSivDRYe2esvVnmMcmY0dIaSqfh5THXeHXrM(xClpJb2ksvh0mbrcJJm9V4wEgdSvspcpa8bsruzijecY5IWKdZSO(gM8vmEappxmgqQ6wLjSjKQEBymfWqyVT88pfaoxQcMQd2(H2(3ueghz6FXT8mgyRWH7v5veqEtHaXUuSO(gMHWEBLQoal8Icz55if3E9wnrSJvJm9GialuXrEadH92YZ)ua4CPkyQoy7hA7Ftfio5)q9VPSNZ9kcWfkGyxk2EOY4fVntbK)d1)MYUDEYb)gSfUq2dvgV4TzAzr(pu)Bk75CVIaCHci2LIThQmEXzE9aY)H6Ftz3op5GFd2cxi7HkJx82RhqQ6TxFzr(pu)Bk75CVIaCHci2LIThQmEXBVEa5)q9VPSBNNCWVbBHlK9qLXloZRhqQ6TnPLfPQBvMWMqQ6mdZCaSWlkKnDfeKpqzcZmtXVSyiS3wPQdWcVOqwEosXTn3AGThPMGdvgV4mVkjmoY0)IB5zmWwXaAKIFHei2LIfvgscHGCUim5WmlQVHjFfJhWZZfJbIlhiSslhpS8mua5)q9VPSC8WYZq2dvgV4mV(YI8FO(3u2Z5Efb4cfqSlfBpuz8I32Ca5)q9VPSBNNCWVbBHlK9qLXlEBZllY)H6FtzpN7veGluaXUuS9qLXloZRhq(pu)Bk725jh8BWw4czpuz8I3E9asvVntllY)H6FtzpN7veGluaXUuS9qLXlE71di)hQ)nLD78Kd(nylCHShQmEXzE9asvV96llsvVDSxwme2BRXlga)EPvaE8eghz6FXT8mgyRKEeEa4dKIOYqsieKZfHjhMzr9nm5Ry8aEEUymGu1Tktytiv92WyIW4it)lULNXaBL5KtHG8VdRuuFdtQ6wLjSjKQEByMjmoY0)IB5zmWwzdfYRiahp4yLaXUuSOEL4DcWtyMjmoY0)IB5zmWwXaAKIFHei2LIfvgscHGCUim5WmlQVHjFfJhWZZfJbK)d1)MYUDEYb)gSfUq2dvgV4mVEaPQdJPaWpmiis2TMTPhHha(aPeal8Icztxbb5dIDRmBMW4it)lULNXaBfdOrk(fsGyxkwuzijecY5IWKdZSO(gM8vmEappxmgal8Icztxbb5duMWmZuG4KQUvzcBcPQZmmZllWpmiis2TMTPhHha(aPepHrcJJm9V42gCG)fh8BWFD8GfCoFmGqrRrbHzansXVqce7sXGcXo2f9HdJJPObhibeMHWEBBWb(xCWVb)1Xd00ypuz8Ihio5)q9VPSNZ9kcWfkGyxk2EOY4fVTHWEBBWb(xCWVb)1Xd00ypuz8IhWqyVTn4a)lo43G)64bAAShQmEXzMjR5Lf5)q9VPSNZ9kcWfkGyxk2EOY4f3egc7TTbh4FXb)g8xhpqtJ9qLXlEBZwgyadH922Gd8V4GFd(RJhOPXEOY4fNztYAEzXqyVTgq)3He4PvaEadH926vWxmECqhH8i10kapGHWEB9k4lgpoOJqEKAApuz8IZSHWEBBWb(xCWVb)1Xd00ypuz8IhpHXrM(xCBdoW)Id(n4VoEXaBf5abbgz6FbGCEkAnkimzhWXTO88CzcZSO(g2QZbcR0YXdlpdryCKP)f32Gd8V4GFd(RJxmWwroqqGrM(xaiNNIwJcct2bC8WYZqIYZZLjmZI6By5aHvA54HLNHimoY0)IBBWb(xCWVb)1XlgyRGfEr(QOxraeYd7NO(gMu1Tktytiv92Wykaw4ffYMUccYhOmHBVoHXrM(xCBdoW)Id(n4VoEXaBLZ5Efb4cfqSlflQmKecb5CryYHzMW4it)lUTbh4FXb)g8xhVyGTY25jh8BWw4cjQVHnY0dIaSqfh5THXuadH922Gd8V4GFd(RJhOPXEOY4fNzZeghz6FXTn4a)lo43G)64fdSvAu9dYRiq)MOVaWfkPQO(g2itpicWcvCK3ggteghz6FXTn4a)lo43G)64fdSv4W9Q8kciVPqGyxkwuFdt(kgpGNNlgdmY0dIaSqfh5THTEadH922Gd8V4GFd(RJhOPXkaNW4it)lUTbh4FXb)g8xhVyGTIb0if)cjqSlflQmKecb5CryYHzwuFdt(kgpGNNlgdmY0dIaSqfh5mdJPabNZhdi0AansXVqce7sXGcXo2jmoY0)IBBWb(xCWVb)1XlgyRWH7v5veqEtHaXUuSO(gM8vmEappxmgWqyVT9PKi43aPQZaCRaCcJJm9V42gCG)fh8BWFD8Ib2kyy4ieqDofr9nmPQdR1agc7TTbh4FXb)g8xhpqtJ9qLXloZMeHXrM(xCBdoW)Id(n4VoEXaBLTZtWVbPkcAu9ebPhHNOYqsieKZfHjhMzr9nmPQdR1agc7TTbh4FXb)g8xhpqtJ9qLXloZMeHXrM(xCBdoW)Id(n4VoEXaBLgv)G8kc0Vj6laCHsQsyCKP)f32Gd8V4GFd(RJxmWwj9i8aWhifrLHKqiiNlctomZI6BysvhwRbme2BBdoW)Id(n4VoEGMg7HkJxCMnjcJJm9V42gCG)fh8BWFD8Ib2kBNNCWVbBHlKOEL4DcWtGVHziS32gCG)fh8BWFD8annwb4I6Bygc7TLN)PaW5svWuDW2p0kapWnEhGbXkTtVZTE1w(pu)Bk725jh8BWw4cz7c3K(xXQwTRkHXrM(xCBdoW)Id(n4VoEXaBfoCVkVIaYBkei2LIf13Wme2BRu1byHxuilphP42R3QjIDSAKPhebyHkoYjmoY0)IBBWb(xCWVb)1XlgyRSDEc(nivrqJQNii9i8evgscHGCUim5WmlQVHjvDMxNW4it)lUTbh4FXb)g8xhVyGTcggocbuNtruFdtQ6wLjSjKQEByMjmoY0)IBBWb(xCWVb)1XlgyRivDGHWXtr9nmPQBvMWMqQ6THfN5ygz6brawOIJ82MJNW4it)lUTbh4FXb)g8xhVyGTs6r4bGpqkIkdjHqqoxeMCyMf13WIB15aHvAv9eiFfJFzr(kgpGNNlgJpGu1Tktytiv92WyIW4it)lUTbh4FXb)g8xhVyGTIb0if)cjqSlflQmKecb5CryYHzwuFdBKPhebyHkoYzg26bKQEByRVSyiS32gCG)fh8BWFD8annwb4eghz6FXTn4a)lo43G)64fdSvKQoOzcIeghz6FXTn4a)lo43G)64fdSv2qH8kcWXdowjqSlflQxjENa8eMzn7iKQ)PzzDL1sN6uRb]] )


end