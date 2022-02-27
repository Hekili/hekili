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


    spec:RegisterPack( "Windwalker", 20220226, [[dSemPcqiPu1JePcBse9jKOgLOQoLuIvjLk6vIQmlIWTOsyxu1VKszyIuogvQLHeEMkktJkrUMivTnrQ03urLACIurNdjcRtfvmpKu3du2NkYbrIuTqPKEOkQYerIuIlkLk0gLsL4JirkoPuQGvIK8sKiLAMQOQUjsKsANer)ukvQwQuQuEksnvQK(QkQKXsLO2lP(lWGr5Wkwmv8ysMSuDzOnRsFwugnrDAkRgjIEnrA2GCBcTBj)wvdhuDCKiz5k9CunDHRtW2fHVRcJxu58IK1lLkP5lf7hXA3Ax109jqTKuKgfuKgfuKUEkOWLsZLCjnDKcoQPHpkPtgQPRre10NlR6hdKuC10WNuq)01UQP5VWQqnTM2rWGI2Hs7OP7tGAjPinkOinkOiD9uqHlLMlrHMMdhvAjPiDPeAAzR3Xs7OP7ixPPpxw1pgiP4syuA9lPeQAxqNvy2uegfPxccJI0OGccvPJ0bHQZtE2mKFoeQCbH56bosjS2fJhCc7Vew7IWMIWSkWDfGheg0NzkpHkxqyUEGJucJgUvLvze25TtHegL2MskHb9zMYtOYfegLEVtyopNFTm5GWuYOskNWINWeNkfHDEuAHWWkwd5EcvUGWO07DcZkxOErNjiS2fiKlR25gEnnKXdU2vn9dhlC1UQL0T2vnnwJde21TQPhvyFPPVgpa)feYi4q2ceewgUAA1AbU2OPvYMxCYryUGWuYgHDcgHDMMwLsbHGy2mm4AjDRdTKuODvtJ14aHDDRAA1AbU2OPJbcRWRKnGJWYdpwJde2jSKeMs28ItocZfeMs2iStWiSZ00JkSV00yo4ieqEwrDOL8mTRAASghiSRBvtpQW(sthwgUa4dKOMwTwGRnAA1l68aESMuKWssykzZlo5imxqykzJWobJWOqtRsPGqqmBggCTKU1Hwsxs7QMgRXbc76w10Q1cCTrtRKnV4KJWCbHPKncdgHrHMEuH9LMwjBGJjbQdTKPx7QMEuH9LMgZbhHaYZkQPXACGWUUvDOLmD1UQPXACGWUUvn9Oc7lnDyz4cGpqIAA1AbU2OPvYMxCYryUGWuYgHDcgHrHMwLsbHGy2mm4AjDRdDOPpWb(xCWFb)2Xv7Qws3Ax10ynoqyx3QM(HRP5yOPhvyFPPtmRnoqOMoXajGAAhH71FGd8V4G)c(TJl44WVO4yfNWssy5tyQ)H6)r5xJBvgGluaPMsQFrXXkoHDIWCeUx)boW)Id(l43oUGJd)IIJvCcljH5iCV(dCG)fh8xWVDCbhh(ffhR4eg1egfE3ewtdHP(hQ)hLFnUvzaUqbKAkP(ffhR4eMlimhH71FGd8V4G)c(TJl44WVO4yfNWoryU9uccljH5iCV(dCG)fh8xWVDCbhh(ffhR4eg1eMl5DtynneMJW96DG(VdjWdVaCcljH5iCVERs8sXLd6iKLjhEb4ewscZr4E9wL4LIlh0rilto8lkowXjmQjmhH71FGd8V4G)c(TJl44WVO4yfNWArtNywqnIOM2bAusFHai1usbfIDSRdTKuODvtJ14aHDDRAA1AbU2OPBpHfdewHNJlwwKYJ14aHDnnpwtfAjDRPhvyFPPvdeeyuH9faY4HMgY4bOgrutR6aoE1HwYZ0UQPXACGWUUvnTATaxB00XaHv454ILfP8ynoqyxtZJ1uHws3A6rf2xAA1abbgvyFbGmEOPHmEaQre10QoGJlwwKshAjDjTRAASghiSRBvtRwlW1gnTs28ItocZfeMs2iStWimkiSKegw4MLYhMicIhio5iSte2zA6rf2xAASWnZAxTkdGqwoB1HwY0RDvtJ14aHDDRA6rf2xA614wLb4cfqQPKQPvPuqiiMnddUws36qlz6QDvtJ14aHDDRAA1AbU2OPhvyjqawOOHCc7emcJccljH5iCV(dCG)fh8xWVDCbhh(ffhR4eg1eMBn9Oc7ln914bh8xWvytPdTKNBTRAASghiSRBvtRwlW1gn9OclbcWcfnKtyNGryuOPhvyFPPpKTfYQmqFNSVaWfkLSo0sMo1UQPXACGWUUvnTATaxB00Qx05b8ynPiHLKWgvyjqawOOHCc7emc7mcljH5iCV(dCG)fh8xWVDCbhhEb4A6rf2xAAoCRkRYaQDkei1us1HwskH2vnnwJde21TQPhvyFPPDGgL0xiasnLunTATaxB00Qx05b8ynPiHLKWgvyjqawOOHCcJAyegfewsclXS24aHEhOrj9fcGutjfui2XUMwLsbHGy2mm4AjDRdTKUtt7QMgRXbc76w10Q1cCTrtRErNhWJ1KIewscZr4E99Pui4VaLSrjnVaCn9Oc7lnnhUvLvza1ofcKAkP6qlPB3Ax10ynoqyx3QMwTwGRnAALSryWiS0iSKeMJW96pWb(xCWFb)2XfCC4xuCSItyutyUKMEuH9LMgZbhHaYZkQdTKUPq7QMgRXbc76w10JkSV00xJhG)cczeCiBbccldxnTATaxB00kzJWGryPryjjmhH71FGd8V4G)c(TJl44WVO4yfNWOMWCjnTkLccbXSzyW1s6whAjDFM2vn9Oc7ln9HSTqwLb67K9faUqPK10ynoqyx3Qo0s62L0UQPXACGWUUvn9Oc7lnDyz4cGpqIAA1AbU2OPvYgHbJWsJWssyoc3R)ah4FXb)f8BhxWXHFrXXkoHrnH5sAAvkfecIzZWGRL0To0s6o9Ax10ynoqyx3QMwTwGRnAAhH71ZJFfb4SHmyQo4Al6fGtyjjSDSoatGv4NEN7TIWoryQ)H6)r5Vgp4G)cUcBkFxyNW(IWANewA(0vtpQW(stFnEWb)fCf2uAARcCxb4HM2To0s6oD1UQPXACGWUUvnTATaxB00oc3RxjBaSWnlLNhJskHDIWolncZfew6jS2jHnQWsGaSqrd5A6rf2xAAoCRkRYaQDkei1us1Hws3NBTRAASghiSRBvtpQW(stFnEa(liKrWHSfiiSmC10Q1cCTrtRKncJAc7mnTkLccbXSzyW1s6whAjDNo1UQPXACGWUUvnTATaxB00kzZlo5imxqykzJWobJWCRPhvyFPPXCWriG8SI6qlPBkH2vnnwJde21TQPvRf4AJMwjBEXjhH5cctjBe2jyew(eMBclpcBuHLabyHIgYjSteMBcRfn9Oc7lnTs2aoclp0Hwskst7QMgRXbc76w10JkSV00HLHla(ajQPvRf4AJMoFcR9ewmqyfEzlaQx059ynoqyNWAAim1l68aESMuKWAHWssykzZlo5imxqykzJWobJWOqtRsPGqqmBggCTKU1HwskCRDvtJ14aHDDRA6rf2xAAhOrj9fcGutjvtRwlW1gn9OclbcWcfnKtyudJWoJWssykzJWobJWoJWAAimhH71FGd8V4G)c(TJl44WlaxtRsPGqqmBggCTKU1HwskOq7QMEuH9LMwjBGJjbQPXACGWUUvDOLKIZ0UQPTkWDfGhAA3A6rf2xA6lukRYaCCHJvaKAkPAASghiSRBvh6qtZXfllsPDvlPBTRAASghiSRBvtRwlW1gnTJW9654ILfP8lkowXjmQjm3A6rf2xA6RXdo4VGRWMshAjPq7QMgRXbc76w10Q1cCTrtRErNhWJ1KIewsclFcBuHLabyHIgYjStWiSZiSMgcBuHLabyHIgYjSteMBcljH1Ect9pu)pk)ACRYaCHci1us9cWjSw00JkSV00C4wvwLbu7uiqQPKQdTKNPDvtJ14aHDDRA6rf2xA614wLb4cfqQPKQPvRf4AJMw9IopGhRjf10QukieeZMHbxlPBDOL0L0UQPXACGWUUvnTATaxB00JkSeialu0qoHDcgHDMMEuH9LM(A8Gd(l4kSP0HwY0RDvtJ14aHDDRAA1AbU2OPvVOZd4XAsrcljH5iCV((uke8xGs2OKMxaUMEuH9LMMd3QYQmGANcbsnLuDOLmD1UQPXACGWUUvn9Oc7lnTd0OK(cbqQPKQPvRf4AJMw9IopGhRjfjSKeMJW96pWb(xCWFb)2X1laNWssyQ)H6)r5xJBvgGluaPMsQFrXXkoHDIWOqtRsPGqqmBggCTKU1HwYZT2vnTvbURa8ayxnD7v)d1)JYVg3QmaxOasnLuVaCn9Oc7ln914bh8xWvytPPXACGWUUvDOLmDQDvtJ14aHDDRAA1AbU2OPvVOZd4XAsrcljH1rhH7178f2f4bWzXdqhDeUxVaCn9Oc7lnnhUvLvza1ofcKAkP6qljLq7QMgRXbc76w10JkSV00xJhG)cczeCiBbccldxnTATaxB00kzJWOMWottRsPGqqmBggCTKU1Hws3PPDvtJ14aHDDRA6rf2xAAhOrj9fcGutjvtRwlW1gnT6fDEapwtksynnew7jSyGWk8YwauVOZ7XACGWUMwLsbHGy2mm4AjDRdTKUDRDvtpQW(stZHBvzvgqTtHaPMsQMgRXbc76w1Ho00QoGJlwwKs7Qws3Ax10ynoqyx3QM(HRP5yOPhvyFPPtmRnoqOMoXajGAA1)q9)O8CCXYIu(ffhR4eg1eMBcRPHWGJHpNawGqgbhYwGGWYW1pQWsGewsct9pu)pkphxSSiLFrXXkoHDIWolncRPHWCEoNWssyxltoalkowXjmQjmksttNywqnIOMMJlwwKc4iS8qhAjPq7QMgRXbc76w10Q1cCTrt3EclXS24aHE5hQdYjGfH10qyopNtyjjSRLjhGffhR4eg1egfPxtpQW(stBvIxkcYjGLo0sEM2vnnwJde21TQPvRf4AJMoXS24aHEoUyzrkGJWYdn9Oc7lnTd0)DWvytPdTKUK2vnnwJde21TQPvRf4AJMoXS24aHEoUyzrkGJWYdn9Oc7lnTdUCCLAvMo0sMETRA6rf2xAAilto4akPqpteRqtJ14aHDDR6qlz6QDvtJ14aHDDRAA1AbU2OPtmRnoqONJlwwKc4iS8qtpQW(stFTfDG(VRdTKNBTRAASghiSRBvtRwlW1gnDIzTXbc9CCXYIuahHLhA6rf2xA6Puip2bcOgiiDOLmDQDvtJ14aHDDRAA1AbU2OPtmRnoqONJlwwKc4iS8qtpQW(st7mzG)cI1us56qljLq7QMgRXbc76w10Q1cCTrtFTm5aSO4yfNWory5tyUtNPryUGWwHcV)MH(7edeiEbLShRXbc7ew7KWCtrAewlewtdHbhdFobSaHmcoKTabHLHRFuHLajSKew(ew7jm1NaRPcFHQ9H(TtynneMJW96D(c7c8a4S4HxaoH1cH10qy5tyQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4e2jc7AzYbyrXXkoH1cHLKWCeUxVZxyxGhaNfp8cWjSMgcZ55CcljHDTm5aSO4yfNWOMWCNMMEuH9LMoEbLm4VGooHSo0s6onTRAASghiSRBvtRwlW1gn91YKdWIIJvCc7eHrjsJWAAim4y4ZjGfiKrWHSfiiSmC9JkSeiH10qyopNtyjjSRLjhGffhR4eg1eM7000JkSV00XlOKb)fiDwXrhAjD7w7QMgRXbc76w10Q1cCTrtR(hQ)hLFnUvzaUqbKAkP(ffhR4eg1egMdvcbccte10JkSV00h4a)lo4VGF74QdTKUPq7QMgRXbc76w10Q1cCTrtNywBCGqphxSSifWry5bH10qyopNtyjjSRLjhGffhR4eg1egfPPPhvyFPPTIRwHyCGqaLsyQqqe0XeMc1Hws3NPDvtJ14aHDDRA6rf2xA6qgbxB5bGBzgKMwTwGRnA6eZAJde654ILfPaoclpiSMgcZ55CcljHDTm5aSO4yfNWOMWOinnDnIOMoKrW1wEa4wMbPdTKUDjTRAASghiSRBvtRwlW1gnDIzTXbc9CCXYIuahHLhA6rf2xA6JDczE8fQdTKUtV2vnnwJde21TQPvRf4AJMoXS24aHEoUyzrkGJWYdn9Oc7lnDg00Tj(LdCMEgQdTKUtxTRAASghiSRBvtpQW(stZLN(FKTdhoi(af10Q1cCTrtdhdFobSaHmcoKTabHLHRFuHLajSMgcZ55CcljHDTm5aSO4yfNWOMWOincRPHWApHTcfE)nd9wL4LIlh0rilto8ynoqyxtxJiQP5Yt)pY2HdheFGI6qlP7ZT2vnnwJde21TQPvRf4AJMU9ewIzTXbc95eWc8fqGJGyTskgewtdHP(hQ)hL3QeVueKtalqiJGdzlqqyz46xuCSItyNimksJWAAiSeZAJde6LFOoiNawA6rf2xAAbocSaf56qlP70P2vn9Oc7ln9DqiRqapEr4AASghiSRBvhAjDtj0UQPhvyFPPVdeewGF74QPXACGWUUvDOLKI00UQPXACGWUUvnTATaxB00opNtyjjSRLjhGffhR4eg1eM70tynnew(eMs2iStWimkiSKew(e21YKdWIIJvCc7eHLUPryjjS8jS8jm1)q9)O8CCXYIu(ffhR4e2jcZDAewtdH5iCVEoUyzrkVaCcRPHWu)d1)JYZXflls5fGtyTqyjjS8jm4y4ZjGfiKrWHSfiiSmC9JkSeiH10qyQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4e2jcZDAewtdHLywBCGqV8d1b5eWIWAHWAHWAHWAAiS8jSRLjhGffhR4eg1WiS0nncljHLpHbhdFobSaHmcoxYwGGWYW1pQWsGewtdHP(hQ)hL3QeVueKtalqiJGdzlqqyz46xuCSItyNiSRLjhGffhR4ewlewlewlA6rf2xAANVWUapaolEOdTKu4w7QMgRXbc76w10Q1cCTrtR(hQ)hLFnUvzaUqbKAkP(ffhR4eg1egfewtdH58CoHLKWUwMCawuCSItyutyUtVMEuH9LMMJlwwKshAjPGcTRA6rf2xAANjd8xqSMskxtJ14aHDDR6qljfNPDvtJ14aHDDRAA1AbU2OPDeUxphxSSiLV)hfHLKWCeUxVZxyxGhaNfpaD0r4E99)OiSKeMJW96D(c7c8a4S4HV)hfHLKWYNW4VaKJvDpCbEiaHaCfGh2xESghiStynneg)fGCSQ7t8qtyqiG)qjWk8ynoqyNWArtBvG7kapa2vtZFbihR6(ep0egec4pucScnTvbURa8ayIIy3Ma10U10JkSV00xiKlR25gAARcCxb4bid6DginTBDOdnnp0UQL0T2vnnwJde21TQPvRf4AJMEhRdWeyf(P35ERiSteM6FO(Fu(dzBHSkd03j7laCHsj77c7e2xew7KWsZNojSMgcBhRdWeyf(P35Eb4A6rf2xA6dzBHSkd03j7laCHsjRdTKuODvtJ14aHDDRAA1AbU2OPvYMxCYryUGWuYgHDcgHrbHLKWWc3Su(Werq8aXjhHDIWoJWAAimLS5fNCeMlimLSryNGryUeHLKWYNWWc3Su(Werq8aXjhHDIWOGWAAiS2tyWxmbit19U9HLHla(ajsyTOPhvyFPPXc3mRD1Qmacz5SvhAjpt7QMgRXbc76w10Q1cCTrtRErNhWJ1KIewscZr4E99Pui4VaLSrjnVaCcljHLpHTJ1bycSc)07CVve2jcZr4E99Pui4VaLSrjn)IIJvCcZfegfewtdHTJ1bycSc)07CVaCcRfn9Oc7lnnhUvLvza1ofcKAkP6qlPlPDvtJ14aHDDRAA1AbU2OP5VaKJvDFIhAcdcb8hkbwHhRXbc7ewscZr4E984xraoBidMQdU2I((FuewscRJoc3R35lSlWdGZIhGo6iCV((FuAARcCxb4bWUAAhH71N4HMWGqa)HsGvaKfeN6TUxaEtdw4MLYhMicIhio5O(SMg1)q9)O8RXTkdWfkGutj1VO4yfNAkAAu)d1)JYFnEWb)fCf2u(ffhR4utHM2Qa3vaEamrrSBtGAA3A6rf2xA6leYLv7CdDOLm9Ax10ynoqyx3QMEuH9LMEnUvzaUqbKAkPAA1AbU2OPv)d1)JYZXflls5xuCSItyNim3ewtdH1EclgiScphxSSiLhRXbc7ewsclFct9pu)pk)boW)Id(l43oU(ffhR4e2jcZLiSMgcR9eM6tG1uHxAQ1MIWArtRsPGqqmBggCTKU1HwY0v7QMgRXbc76w10Q1cCTrtNpHTJ1bycSc)07CVve2jct9pu)pk)14bh8xWvyt57c7e2xew7KWsZNojSMgcBhRdWeyf(P35Eb4ewlewsclFcdlCZs5dtebXdeNCe2jcdZHkHabHjIeMlim3ewtdHPKnV4KJWCbHPKncJAyeMBcRPHWCeUxpp(veGZgYGP6GRTOFrXXkoHrnHH5qLqGGWerclpcZnH1cH10qyxltoalkowXjmQjmmhQeceeMisy5ryUjSMgcRJoc3R35lSlWdGZIhGo6iCVEb4A6rf2xA6RXdo4VGRWMshAjp3Ax10ynoqyx3QMwTwGRnAAhH71hYiafHJ7VCGAGpkl(1ZJrjLWoryUPeewscdlCZs5dtebXdeNCe2jcdZHkHabHjIeMlim3ewsct9pu)pk)ACRYaCHci1us9lkowXjStegMdvcbcctejSMgcZr4E9Hmcqr44(lhOg4JYIF98yusjSteMBxIWssy5tyQ)H6)r554ILfP8lkowXjmQjS0tyjjSyGWk8CCXYIuESghiStynneM6FO(Fu(dCG)fh8xWVDC9lkowXjmQjS0tyjjm1NaRPcV0uRnfH10qyxltoalkowXjmQjS0tyTOPhvyFPPv7OKczvgGsoDeazzYrzvMo0sMo1UQPXACGWUUvnTATaxB00oc3RFf4YwLbOKthbhw199)OiSKe2OclbcWcfnKtyNim3A6rf2xA6vGlBvgGsoDeCyvxhAjPeAx10ynoqyx3QMEuH9LM(A8a8xqiJGdzlqqyz4QPvRf4AJMwjBeg1e2zAAvkfecIzZWGRL0To0s6onTRAASghiSRBvtRwlW1gnTs28ItocZfeMs2iStWim3A6rf2xAAmhCecipROo0s62T2vnnwJde21TQPvRf4AJMwjBEXjhH5cctjBe2jyeMBcljHnQWsGaSqrd5egmcZnHLKW2X6ambwHF6DU3kc7eHrrAewtdHPKnV4KJWCbHPKnc7emcJccljHnQWsGaSqrd5e2jyegfA6rf2xAALSbCewEOdTKUPq7QMEuH9LMwjBGJjbQPXACGWUUvDOL09zAx10ynoqyx3QMEuH9LMoSmCbWhirnTATaxB00Qx05b8ynPiHLKWuYMxCYryUGWuYgHDcgHrbHLKWCeUxpp(veGZgYGP6GRTOV)hLMwLsbHGy2mm4AjDRdTKUDjTRAASghiSRBvtRwlW1gnTJW96vYgalCZs55XOKsyNiSZsJWCbHLEcRDsyJkSeialu0qoHLKWCeUxpp(veGZgYGP6GRTOV)hfHLKWYNWu)d1)JYVg3QmaxOasnLu)IIJvCc7eHrbHLKWu)d1)JYFnEWb)fCf2u(ffhR4e2jcJccRPHWu)d1)JYVg3QmaxOasnLu)IIJvCcJAc7mcljHP(hQ)hL)A8Gd(l4kSP8lkowXjSte2zewsctjBe2jc7mcRPHWu)d1)JYVg3QmaxOasnLu)IIJvCc7eHDgHLKWu)d1)JYFnEWb)fCf2u(ffhR4eg1e2zewsctjBe2jcZLiSMgctjBEXjhH5cctjBeg1Wim3ewscdlCZs5dtebXdeNCeg1egfewlewtdH5iCVELSbWc3SuEEmkPe2jcZDAewsc7AzYbyrXXkoHrnHDU10JkSV00C4wvwLbu7uiqQPKQdTKUtV2vnnwJde21TQPhvyFPPDGgL0xiasnLunTATaxB00Qx05b8ynPiHLKWYNWIbcRWZXflls5XACGWoHLKWu)d1)JYZXflls5xuCSItyutyNrynneM6FO(Fu(14wLb4cfqQPK6xuCSItyNim3ewsct9pu)pk)14bh8xWvyt5xuCSItyNim3ewtdHP(hQ)hLFnUvzaUqbKAkP(ffhR4eg1e2zewsct9pu)pk)14bh8xWvyt5xuCSItyNiSZiSKeMs2iStegfewtdHP(hQ)hLFnUvzaUqbKAkP(ffhR4e2jc7mcljHP(hQ)hL)A8Gd(l4kSP8lkowXjmQjSZiSKeMs2iSte2zewtdHPKnc7eHLEcRPHWCeUxVZlfaFFLxaoH1IMwLsbHGy2mm4AjDRdTKUtxTRAASghiSRBvtpQW(sthwgUa4dKOMwTwGRnAA1l68aESMuKWssykzZlo5imxqykzJWobJWOqtRsPGqqmBggCTKU1Hws3NBTRAASghiSRBvtRwlW1gnTs28ItocZfeMs2iStWim3A6rf2xA6zvtHG43fRqhAjDNo1UQPTkWDfGhAA3A6rf2xA6lukRYaCCHJvaKAkPAASghiSRBvhAjDtj0UQPXACGWUUvn9Oc7lnTd0OK(cbqQPKQPvRf4AJMw9IopGhRjfjSKeM6FO(Fu(RXdo4VGRWMYVO4yfNWOMWoJWssykzJWGryuqyjjm4lMaKP6E3(WYWfaFGejSKegw4MLYhMicIhK(0imQjm3AAvkfecIzZWGRL0To0ssrAAx10ynoqyx3QMEuH9LM2bAusFHai1us10Q1cCTrtRErNhWJ1KIewscdlCZs5dtebXdeNCeg1egfewsclFctjBEXjhH5cctjBeg1Wim3ewtdHbFXeGmv372hwgUa4dKiH1IMwLsbHGy2mm4AjDRdDOPvDahVAx1s6w7QMgRXbc76w10Q1cCTrt3EclXS24aHE5hQdYjGfHLKWYNWu)d1)JYVg3QmaxOasnLu)IIJvCcJAcJccRPHWApHP(eynv4LMATPiSwiSKew(ew7jm1NaRPcFHQ9H(TtynneM6FO(FuENVWUapaolE4xuCSItyutyuqyTqynne21YKdWIIJvCcJAcJI0RPhvyFPPTkXlfb5eWshAjPq7QMgRXbc76w10Q1cCTrtFTm5aSO4yfNWory5tyUtNPryUGWwHcV)MH(7edeiEbLShRXbc7ew7KWCtrAewlewtdH5iCVEE8RiaNnKbt1bxBrF)pkcljHbhdFobSaHmcoKTabHLHRFuHLajSKew(ew7jm1NaRPcFHQ9H(TtynneMJW96D(c7c8a4S4HxaoH1cH10qy5tyQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4e2jc7AzYbyrXXkoH1cHLKWCeUxVZxyxGhaNfp8cWjSMgcZ55CcljHDTm5aSO4yfNWOMWCNMMEuH9LMoEbLm4VGooHSo0sEM2vnnwJde21TQPvRf4AJMoFcBhRdWeyf(P35ERiSteMlLEcRPHW2X6ambwHF6DUxaoH1cHLKWu)d1)JYVg3QmaxOasnLu)IIJvCcJAcdZHkHabHjIewsct9pu)pkVvjEPiiNawGqgbhYwGGWYW1VO4yfNWory5tyuKgHLhHrrAew7KWwHcV)MHERs8sXLd6iKLjhESghiStyTqynneMZZ5ewsc7AzYbyrXXkoHrnHDw610JkSV00h4a)lo4VGF74QdTKUK2vnnwJde21TQPvRf4AJMw9IopGhRjfjSKew(e2owhGjWk8tVZ9wryNim3Prynne2owhGjWk8tVZ9cWjSw00JkSV003bHScb84fHRdTKPx7QMgRXbc76w10Q1cCTrtVJ1bycSc)07CVve2jc7S0iSMgcBhRdWeyf(P35Eb4A6rf2xA67abHf43oU6qlz6QDvtJ14aHDDRAA1AbU2OPvYgHDcgHrbHLKWUwMCawuCSItyNiS0nncljHLpHP(hQ)hLNh)kcWzdzWuDW1w0RKNnd5e2jclncRPHWu)d1)JYZJFfb4SHmyQo4Al6xuCSItyNim3PryTqyjjS8jm4y4ZjGfiKrWHSfiiSmC9JkSeiH10qyQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4e2jcZDAewtdHLywBCGqV8d1b5eWIWAHWAAiS8jmLSryNGryuqyjjSRLjhGffhR4eg1WiS0nncljHLpHbhdFobSaHmcoxYwGGWYW1pQWsGewtdHP(hQ)hL3QeVueKtalqiJGdzlqqyz46xuCSItyNiSRLjhGffhR4ewlewsclFct9pu)pkpp(veGZgYGP6GRTOxjpBgYjStewAewtdHP(hQ)hLNh)kcWzdzWuDW1w0VO4yfNWoryxltoalkowXjSMgcZr4E984xraoBidMQdU2IEb4ewlewlewtdHDTm5aSO4yfNWOMWCNEn9Oc7lnTZxyxGhaNfp0HwYZT2vnnwJde21TQPvRf4AJMw9vxWcV6)TB1eyh83lwClb6XACGWUMEuH9LMMh)kcWzdzWuDW1weCTCtG6qlz6u7QMgRXbc76w10Q1cCTrtR(hQ)hLNh)kcWzdzWuDW1w0RKNnd5egmcJccRPHWUwMCawuCSItyutyuKgH10qy5ty7yDaMaRWp9o3VO4yfNWoryUtpH10qy5tyTNWuFcSMk8stT2uewscR9eM6tG1uHVq1(q)2jSwiSKew(ew(e2owhGjWk8tVZ9wryNim1)q9)O884xraoBidMQdU2I(RaeeyrL8SziimrKWAAiS2ty7yDaMaRWp9o3J5mEWjSwiSKew(eM6FO(FuERs8srqobSaHmcoKTabHLHRFrXXkoHDIWu)d1)JYZJFfb4SHmyQo4Al6VcqqGfvYZMHGWercRPHWsmRnoqOx(H6GCcyryTqyTqyjjm1)q9)O8xJhCWFbxHnLFrXXkoHrnmcJsqyjjmLSryNGryuqyjjm1)q9)O8hY2czvgOVt2xa4cLs2VO4yfNWOggH5MccRfn9Oc7lnnp(veGZgYGP6GRTOo0ssj0UQPXACGWUUvnTATaxB00QpbwtfEPPwBkcljHLpH5iCV(dCG)fh8xWVDC9cWjSMgclFc7AzYbyrXXkoHrnHP(hQ)hL)ah4FXb)f8Bhx)IIJvCcRPHWu)d1)JYFGd8V4G)c(TJRFrXXkoHDIWu)d1)JYZJFfb4SHmyQo4Al6VcqqGfvYZMHGWercRfcljHP(hQ)hL)A8Gd(l4kSP8lkowXjmQHryuccljHPKnc7emcJccljHP(hQ)hL)q2wiRYa9DY(caxOuY(ffhR4eg1Wim3uqyTOPhvyFPP5XVIaC2qgmvhCTf1Hws3PPDvtJ14aHDDRAA1AbU2OPvFcSMk8fQ2h63oHLKW6OJW96D(c7c8a4S4bOJoc3RxaoHLKWYNWGJHpNawGqgbhYwGGWYW1pQWsGewtdHLywBCGqV8d1b5eWIWAAim1)q9)O8wL4LIGCcybczeCiBbccldx)IIJvCc7eHP(hQ)hLNh)kcWzdzWuDW1w0FfGGalQKNndbHjIewtdHP(hQ)hL3QeVueKtalqiJGdzlqqyz46xuCSItyNiSZsJWArtpQW(stZJFfb4SHmyQo4AlQdTKUDRDvtJ14aHDDRA6rf2xAAR4QvighieqPeMkeebDmHPqnTATaxB00WXWNtalqiJGdzlqqyz46hvyjqcRPHWCEoNWssyxltoalkowXjmQjmksttxJiQPTIRwHyCGqaLsyQqqe0XeMc1Hws3uODvtJ14aHDDRA6rf2xA6qgbxB5bGBzgKMwTwGRnAA4y4ZjGfiKrWHSfiiSmC9JkSeiH10qyQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4e2jclDtJWssyxltoalkowXjSte2zPLgH10qyopNtyjjSRLjhGffhR4eg1egfPPPRre10HmcU2Yda3YmiDOL09zAx10ynoqyx3QMwTwGRnAA4y4ZjGfiKrWHSfiiSmC9JkSeiH10qyopNtyjjSRLjhGffhR4eg1egfPPPhvyFPPp2jK5XxOo0s62L0UQPXACGWUUvnTATaxB00WXWNtalqiJGdzlqqyz46hvyjqcRPHWCEoNWssyxltoalkowXjmQjmksttpQW(stNbnDBIF5aNPNH6qlP70RDvtJ14aHDDRA6rf2xA6(It)AlcsGCocPPvRf4AJMU9ewIzTXbc95eWc8fqGJGyTskgewtdHP(hQ)hL3QeVueKtalqiJGdzlqqyz46xuCSItyNimksJWssyWXWNtalqiJGdzlqqyz46xuCSItyutyuKgH10qyjM1ghi0l)qDqobS001iIA6(It)AlcsGCocPdTKUtxTRAASghiSRBvtpQW(stZLN(FKTdhoi(af10Q1cCTrtdhdFobSaHmcoKTabHLHRFuHLajSMgcZ55CcljHDTm5aSO4yfNWOMWOincRPHWApHTcfE)nd9wL4LIlh0rilto8ynoqyxtxJiQP5Yt)pY2HdheFGI6qlP7ZT2vnnwJde21TQPvRf4AJMU9ewIzTXbc95eWc8fqGJGyTskgewtdHP(hQ)hL3QeVueKtalqiJGdzlqqyz46xuCSItyNimksJWAAiSeZAJde6LFOoiNawA6rf2xAAbocSaf56qlP70P2vnnwJde21TQPvRf4AJM(AzYbyrXXkoHDIWOePrynnegCm85eWceYi4q2ceewgU(rfwcKWAAiSeZAJde6LFOoiNawewtdH58CoHLKWUwMCawuCSItyutyUtxn9Oc7lnD8ckzWFbsNvC0Hws3ucTRAASghiSRBvtRwlW1gnT6FO(FuERs8srqobSaHmcoKTabHLHRFrXXkoHDIWolncRPHWsmRnoqOx(H6GCcyrynneMZZ5ewsc7AzYbyrXXkoHrnHrrAA6rf2xAAhO)7GRWMshAjPinTRAASghiSRBvtRwlW1gnT6FO(FuERs8srqobSaHmcoKTabHLHRFrXXkoHDIWolncRPHWsmRnoqOx(H6GCcyrynneMZZ5ewsc7AzYbyrXXkoHrnH5o9A6rf2xAAhC54k1QmDOLKc3Ax10JkSV00qwMCWbusHEMiwHMgRXbc76w1HwskOq7QMgRXbc76w10Q1cCTrtR(hQ)hL3QeVueKtalqiJGdzlqqyz46xuCSItyNiSZsJWAAiSeZAJde6LFOoiNawewtdH58CoHLKWUwMCawuCSItyutyUtttpQW(stFTfDG(VRdTKuCM2vnnwJde21TQPvRf4AJMw9pu)pkVvjEPiiNawGqgbhYwGGWYW1VO4yfNWoryNLgH10qyjM1ghi0l)qDqobSiSMgcZ55CcljHDTm5aSO4yfNWOMWOinn9Oc7ln9ukKh7abudeKo0ssHlPDvtJ14aHDDRAA1AbU2OPDeUxpp(veGZgYGP6GRTOV)hLMEuH9LM2zYa)feRPKY1HwsksV2vnnwJde21TQPvRf4AJM2r4E9CCXYIu((FuewscZr4E9oFHDbEaCw8a0rhH713)JIWssyoc3R35lSlWdGZIh((FuewsclFcJ)cqow19Wf4HaecWvaEyF5XACGWoH10qy8xaYXQUpXdnHbHa(dLaRWJ14aHDcRfnTvbURa8ayxnn)fGCSQ7t8qtyqiG)qjWk00wf4UcWdGjkIDBcut7wtpQW(stFHqUSANBOPTkWDfGhGmO3zG00U1Ho00D8ocqH2vTKU1UQPhvyFPP5WXzbYt1b8ynPOMgRXbc76w1Hwsk0UQPXACGWUUvn9dxtZXqtpQW(stNywBCGqnDIbsa10Q)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4e2jc7AzYbyrXXkoH10qyxltoalkowXjmxqyQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4eg1eMBksJWssy5ty5tyXaHv454ILfP8ynoqyNWssyxltoalkowXjSteM6FO(FuEoUyzrk)IIJvCcljHP(hQ)hLNJlwwKYVO4yfNWoryUtJWAHWAAiS8jm1)q9)O884xraoBidMQdU2I(RaeeyrL8SziimrKWOMWUwMCawuCSItyjjm1)q9)O884xraoBidMQdU2I(RaeeyrL8SziimrKWoryUtpH1cH10qy5tyQ)H6)r55XVIaC2qgmvhCTf9k5zZqoHbJWsJWssyQ)H6)r55XVIaC2qgmvhCTf9lkowXjmQjSRLjhGffhR4ewlewlA6eZcQre10YpuhKtalDOL8mTRAASghiSRBvtRwlW1gnD(eMJW9654ILfP8cWjSMgcZr4E984xraoBidMQdU2IEb4ewlewscdog(CcybczeCiBbccldx)OclbsynneMZZ5ewsc7AzYbyrXXkoHrnmclDtttpQW(std)d7lDOL0L0UQPXACGWUUvnTATaxB00oc3RNJlwwKYlaxtZJ1uHws3A6rf2xAA1abbgvyFbGmEOPHmEaQre10CCXYIu6qlz61UQPXACGWUUvnTATaxB00oc3R)ah4FXb)f8BhxVaCnnpwtfAjDRPhvyFPPvdeeyuH9faY4HMgY4bOgrutFGd8V4G)c(TJRo0sMUAx10ynoqyx3QMwTwGRnA6WercJAcZLiSKeMs2imQjS0tyjjS2tyWXWNtalqiJGdzlqqyz46hvyjqnnpwtfAjDRPhvyFPPvdeeyuH9faY4HMgY4bOgrut)WXcxDOL8CRDvtJ14aHDDRA6rf2xA6RXdWFbHmcoKTabHLHRMwTwGRnAALS5fNCeMlimLSryNGryNryjjS8jmSWnlLpmreepqCYryutyUjSMgcdlCZs5dtebXdeNCeg1eMlryjjm1)q9)O8xJhCWFbxHnLFrXXkoHrnH52NEcRPHWu)d1)JYFGd8V4G)c(TJRFrXXkoHrnHrbH1cHLKWApH1rhH7178f2f4bWzXdqhDeUxVaCnTkLccbXSzyW1s6whAjtNAx10ynoqyx3QMwTwGRnAALS5fNCeMlimLSryNGryUjSKew(egw4MLYhMicIhio5imQjm3ewtdHP(hQ)hLNJlwwKYVO4yfNWOMWOGWAAimSWnlLpmreepqCYryutyUeHLKWu)d1)JYFnEWb)fCf2u(ffhR4eg1eMBF6jSMgct9pu)pk)boW)Id(l43oU(ffhR4eg1egfewlewscR9eMJW96D(c7c8a4S4HxaUMEuH9LMgZbhHaYZkQdTKucTRAASghiSRBvtpQW(sthwgUa4dKOMwTwGRnAA1l68aESMuKWssykzZlo5imxqykzJWobJWOGWssy5tyyHBwkFyIiiEG4KJWOMWCtynneM6FO(FuEoUyzrk)IIJvCcJAcJccRPHWWc3Su(Werq8aXjhHrnH5sewsct9pu)pk)14bh8xWvyt5xuCSItyutyU9PNWAAim1)q9)O8h4a)lo4VGF746xuCSItyutyuqyTqyjjS2tyD0r4E9oFHDbEaCw8a0rhH71laxtRsPGqqmBggCTKU1Hws3PPDvtJ14aHDDRAA1AbU2OPBpHfdewHNJlwwKYJ14aHDnnpwtfAjDRPhvyFPPvdeeyuH9faY4HMgY4bOgrutR6aoE1Hws3U1UQPXACGWUUvnTATaxB00XaHv454ILfP8ynoqyxtZJ1uHws3A6rf2xAA1abbgvyFbGmEOPHmEaQre10QoGJlwwKshAjDtH2vnnwJde21TQPvRf4AJMEuHLabyHIgYjmQjSZ008ynvOL0TMEuH9LMwnqqGrf2xaiJhAAiJhGAernnp0Hws3NPDvtJ14aHDDRAA1AbU2OPhvyjqawOOHCc7emc7mnnpwtfAjDRPhvyFPPvdeeyuH9faY4HMgY4bOgrutppQdDOPHVO6fDMq7Qws3Ax10JkSV00oFeqyhCHMuy)WQmq85SstJ14aHDDR6qljfAx10ynoqyx3QM(HRP5yOPhvyFPPtmRnoqOMoXajGAAKsjyWHJDVvC1keJdecOuctfcIGoMWuiH10qyiLsWGdh7(mOPBt8lh4m9mKWAAimKsjyWHJD)XoHmp(cjSMgcdPucgC4y3)jWvjpBg2btzIdWzIa3uewtdHHukbdoCS75Yt)pY2HdheFGIewtdHHukbdoCS7dzeCTLhaULzqA6eZcQre105eWc8fqGJGyTskg6ql5zAx10JkSV00xiKlR25gAASghiSRBvhAjDjTRAASghiSRBvtRwlW1gnD7jm1NaRPcFzzYb4oOMEuH9LMwjBahHLh6qlz61UQPXACGWUUvnTATaxB00TNWIbcRWJfUzw7QvzaeYYHRhRXbc7A6rf2xAALSboMeOo0HMEEu7Qws3Ax10JkSV00hY2czvgOVt2xa4cLswtJ14aHDDR6qljfAx10ynoqyx3QMwTwGRnAALS5fNCeMlimLSryNGryuqyjjmSWnlLpmreepqCYryNimkiSMgctjBEXjhH5cctjBe2jyeMlPPhvyFPPXc3mRD1Qmacz5SvhAjpt7QMgRXbc76w10Q1cCTrtRErNhWJ1KIewsclFcZr4E99Pui4VaLSrjnVaCcRPHW6OJW96D(c7c8a4S4bOJoc3RxaoH1IMEuH9LMMd3QYQmGANcbsnLuDOL0L0UQPXACGWUUvnTATaxB00yHBwkFyIiiEG4KJWoryyoujeiimrKWAAimLS5fNCeMlimLSryudJWCRPhvyFPPVgp4G)cUcBkDOLm9Ax10ynoqyx3QMEuH9LMEnUvzaUqbKAkPAA1AbU2OPZNWIbcRWFiBlKvzG(ozFbGlukzpwJde2jSKeM6FO(Fu(14wLb4cfqQPK67c7e2xe2jct9pu)pk)HSTqwLb67K9faUqPK9lkowXjS8imxIWAHWssy5tyQ)H6)r5Vgp4G)cUcBk)IIJvCc7eHDgH10qykzJWobJWspH1IMwLsbHGy2mm4AjDRdTKPR2vnnwJde21TQPvRf4AJM2r4E9Rax2QmaLC6i4WQUV)hLMEuH9LMEf4YwLbOKthbhw11HwYZT2vnnwJde21TQPvRf4AJMwjBEXjhH5cctjBe2jyeMBn9Oc7lnnMdocbKNvuhAjtNAx10ynoqyx3QMEuH9LM(A8a8xqiJGdzlqqyz4QPvRf4AJMwjBEXjhH5cctjBe2jye2zAAvkfecIzZWGRL0To0ssj0UQPXACGWUUvnTATaxB00kzZlo5imxqykzJWobJWOqtpQW(stRKnGJWYdDOL0DAAx10ynoqyx3QMwTwGRnAAhH71hYiafHJ7VCGAGpkl(1ZJrjLWoryUPeewscdlCZs5dtebXdeNCe2jcdZHkHabHjIeMlim3ewsct9pu)pk)14bh8xWvyt5xuCSItyNimmhQeceeMiQPhvyFPPv7OKczvgGsoDeazzYrzvMo0s62T2vnnwJde21TQPhvyFPPdldxa8bsutRwlW1gnTs28ItocZfeMs2iStWimkiSKew(ew7jSyGWk8YwauVOZ7XACGWoH10qyQx05b8ynPiH1IMwLsbHGy2mm4AjDRdTKUPq7QMgRXbc76w10Q1cCTrtRKnV4KJWCbHPKnc7emcZTMEuH9LMEw1uii(DXk0Hws3NPDvtJ14aHDDRAA1AbU2OPvVOZd4XAsrcljHLpHP(hQ)hL35lSlWdGZIh(ffhR4e2jcJccRPHWApHP(eynv4luTp0VDcRfcljHLpHPKnc7emcl9ewtdHP(hQ)hL)A8Gd(l4kSP8lkowXjStew6synneM6FO(Fu(RXdo4VGRWMYVO4yfNWoryNryjjmLSryNGryNryjjmSWnlLpmreepi9PryutyUjSMgcdlCZs5dtebXdeNCeg1WiS8jSZiS8iSZiS2jHP(hQ)hL)A8Gd(l4kSP8lkowXjmQjS0tyTqynneMJW965XVIaC2qgmvhCTf9cWjSw00JkSV00C4wvwLbu7uiqQPKQdTKUDjTRAASghiSRBvtRwlW1gnT6fDEapwtkQPhvyFPPvYg4ysG6qlP70RDvtJ14aHDDRA6rf2xA6lukRYaCCHJvaKAkPAA1AbU2OPDeUxVZlfaFFLV)hLM2Qa3vaEOPDRdTKUtxTRAASghiSRBvtpQW(st7ankPVqaKAkPAA1AbU2OPvVOZd4XAsrcljHLpH5iCVENxka((kVaCcRPHWIbcRWlBbq9IoVhRXbc7ewscd(IjazQU3TpSmCbWhircljHPKncdgHrbHLKWu)d1)JYFnEWb)fCf2u(ffhR4eg1e2zewtdHPKnV4KJWCbHPKncJAyeMBcljHbFXeGmv372ZHBvzvgqTtHaPMskHLKWWc3Su(Werq8aXjhHrnHDgH1IMwLsbHGy2mm4AjDRdDOdnDcC52xAjPinkOinkOWTM(y2YQmUM(CrP3Ujz7GKuAohcJWCvgjmte(VbHD)LWO8boW)Id(l43oUuMWwKsjyl2jm(lIe2ieV4eyNWuYtLHCpHQZ3kKWO4CiSZ7Re4gyNWOCmqyfExMYew8egLJbcRW7YESghiStzcBccRDSD)8jS8DNRfpHQZ3kKWo7CiSZ7Re4gyNWOCmqyfExMYew8egLJbcRW7YESghiStzcBccRDSD)8jS8DNRfpHQZ3kKWOiTZHWoVVsGBGDcJYXaHv4DzktyXtyuogiScVl7XACGWoLjS8DNRfpHkcvNlk92njBhKKsZ5qyeMRYiHzIW)niS7VegL54ILfPOmHTiLsWwSty8xejSriEXjWoHPKNkd5EcvNVviH5oTZHWoVVsGBGDcJYXaHv4DzktyXtyuogiScVl7XACGWoLjSjiS2X29ZNWY3DUw8eQiuDUO0B3KSDqsknNdHryUkJeMjc)3GWU)syuw1bCCXYIuuMWwKsjyl2jm(lIe2ieV4eyNWuYtLHCpHQZ3kKWOeNdHDEFLa3a7egLxHcV)MHExMYew8egLxHcV)MHEx2J14aHDkty57oxlEcvNVviH5oDphc78(kbUb2jmkVcfE)nd9UmLjS4jmkVcfE)nd9UShRXbc7uMWMGWAhB3pFclF35AXtO68Tcjmko7CiSZ7Re4gyNWOm)fGCSQ7DzktyXtyuM)cqow19UShRXbc7uMWYNICT4jurO6CrP3Ujz7GKuAohcJWCvgjmte(VbHD)LWOmpOmHTiLsWwSty8xejSriEXjWoHPKNkd5EcvNVviH5sNdHDEFLa3a7egL5VaKJvDVltzclEcJY8xaYXQU3L9ynoqyNYew(UZ1INq15BfsyP)CiSZ7Re4gyNWOCmqyfExMYew8egLJbcRW7YESghiStzclF35AXtO68TcjSZ95qyN3xjWnWoHr5yGWk8UmLjS4jmkhdewH3L9ynoqyNYew(UZ1INq15BfsyUt)5qyN3xjWnWoHr5yGWk8UmLjS4jmkhdewH3L9ynoqyNYew(UZ1INqfHQZfLE7MKTdssP5CimcZvzKWmr4)ge29xcJYQoGJxktylsPeSf7eg)frcBeIxCcStyk5PYqUNq15BfsyuCoe259vcCdStyuEfk8(Bg6DzktyXtyuEfk8(Bg6DzpwJde2PmHLV7CT4juD(wHe2zNdHDEFLa3a7egLxHcV)MHExMYew8egLxHcV)MHEx2J14aHDkty57oxlEcvNVviH5oDphc78(kbUb2jmkVcfE)nd9UmLjS4jmkVcfE)nd9UShRXbc7uMWMGWAhB3pFclF35AXtO68Tcjmks)5qyN3xjWnWoHrz(la5yv37YuMWINWOm)fGCSQ7DzpwJde2PmHLpf5AXtOIq15IsVDtY2bjP0CoegH5QmsyMi8Fdc7(lHr5oEhbOGYe2IukbBXoHXFrKWgH4fNa7eMsEQmK7juD(wHegfNdHDEFLa3a7egLJbcRW7YuMWINWOCmqyfEx2J14aHDkty57oxlEcvNVviH5oTZHWoVVsGBGDcJYXaHv4DzktyXtyuogiScVl7XACGWoLjSjiS2X29ZNWY3DUw8eQoFRqcZT7ZHWoVVsGBGDcJYXaHv4DzktyXtyuogiScVl7XACGWoLjSjiS2X29ZNWY3DUw8eQiuDUO0B3KSDqsknNdHryUkJeMjc)3GWU)syuEEKYe2IukbBXoHXFrKWgH4fNa7eMsEQmK7juD(wHew6phc78(kbUb2jmkhdewH3LPmHfpHr5yGWk8UShRXbc7uMWY3DUw8eQoFRqcZT7ZHWoVVsGBGDcJYXaHv4DzktyXtyuogiScVl7XACGWoLjS8DNRfpHQZ3kKWCNUNdHDEFLa3a7egLJbcRW7YuMWINWOCmqyfEx2J14aHDkty57oxlEcveQAheH)BGDcJsqyJkSVimiJhCpHknn89VgeQPthPdc7Czv)yGKIlHrP1VKsOkDKoiS2f0zfMnfHrr6LGWOinkOGqv6iDqOkDKoiSZtE2mKFoeQshPdcZfeMRh4iLWAxmEWjS)syTlcBkcZQa3vaEqyqFMP8eQshPdcZfeMRh4iLWOHBvzvgHDE7uiHrPTPKsyqFMP8eQshPdcZfegLEVtyopNFTm5GWuYOskNWINWeNkfHDEuAHWWkwd5EcvPJ0bH5ccJsV3jmRCH6fDMGWAxGqUSANB4jurOkDKoiS2XCOsiWoH5G3Frct9IotqyoyMvCpHrPRui8Gty1xUqEwXRaeHnQW(ItyFbLYtOAuH9f3dFr1l6mrEWAZ5Jac7Gl0Kc7hwLbIpNveQgvyFX9Wxu9IotKhS2smRnoqOe1iIWYjGf4lGahbXALumK4HdJJHejgibegsPem4WXU3kUAfIXbcbukHPcbrqhtykSPbPucgC4y3NbnDBIF5aNPNHnniLsWGdh7(JDczE8f20GukbdoCS7)e4QKNnd7GPmXb4mrGBQMgKsjyWHJDpxE6)r2oC4G4duSPbPucgC4y3hYi4AlpaClZGiunQW(I7HVO6fDMipyTDHqUSANBqOAuH9f3dFr1l6mrEWAtjBahHLhsyxyTx9jWAQWxwMCaUdsOAuH9f3dFr1l6mrEWAtjBGJjbkHDH1(yGWk8yHBM1UAvgaHSC46XACGWoHkcvPJ0bH1oMdvcb2jmmbUPiSWerclKrcBuXVeMXjSjXyqJde6junQW(IdJdhNfipvhWJ1KIeQgvyFXZdwBjM1ghiuIAeryYpuhKtaljE4W4yirIbsaHP(hQ)hL3QeVueKtalqiJGdzlqqyz46xuCSIF6AzYbyrXXkEtZ1YKdWIIJvCxO(hQ)hL3QeVueKtalqiJGdzlqqyz46xuCSItTBkslz(5hdewHNJlwwKk51YKdWIIJv8tQ)H6)r554ILfP8lkowXtQ(hQ)hLNJlwwKYVO4yf)K70APPjF1)q9)O884xraoBidMQdU2I(RaeeyrL8SziimrK6RLjhGffhR4jv)d1)JYZJFfb4SHmyQo4Al6VcqqGfvYZMHGWeXtUtFlnn5R(hQ)hLNh)kcWzdzWuDW1w0RKNnd5WslP6FO(FuEE8RiaNnKbt1bxBr)IIJvCQVwMCawuCSI3sleQgvyFXZdwBW)W(sc7clFhH71ZXflls5fG304iCVEE8RiaNnKbt1bxBrVa8wschdFobSaHmcoKTabHLHRFuHLaBACEop51YKdWIIJvCQHLUPrOAuH9fppyTPgiiWOc7laKXdjQreHXXfllsjbpwtfWClHDH5iCVEoUyzrkVaCcvJkSV45bRn1abbgvyFbGmEirnIiSdCG)fh8xWVDCLGhRPcyULWUWCeUx)boW)Id(l43oUEb4eQgvyFXZdwBQbccmQW(caz8qIAerypCSWvcESMkG5wc7clmrKAxkPs2Oo9jBpCm85eWceYi4q2ceewgU(rfwcKq1Oc7lEEWA7A8a8xqiJGdzlqqyz4kHkLccbXSzyWH5wc7ctjBEXjNluY2jyNLmFSWnlLpmreepqCYrT7MgSWnlLpmreepqCYrTlLu9pu)pk)14bh8xWvyt5xuCSItTBF6BAu)d1)JYFGd8V4G)c(TJRFrXXko1u0sY23rhH7178f2f4bWzXdqhDeUxVaCcvJkSV45bRnmhCecipROe2fMs28ItoxOKTtWCNmFSWnlLpmreepqCYrT7Mg1)q9)O8CCXYIu(ffhR4utrtdw4MLYhMicIhio5O2LsQ(hQ)hL)A8Gd(l4kSP8lkowXP2Tp9nnQ)H6)r5pWb(xCWFb)2X1VO4yfNAkAjz7DeUxVZxyxGhaNfp8cWjunQW(INhS2cldxa8bsucvkfecIzZWGdZTe2fM6fDEapwtkMujBEXjNluY2jyuKmFSWnlLpmreepqCYrT7Mg1)q9)O8CCXYIu(ffhR4utrtdw4MLYhMicIhio5O2LsQ(hQ)hL)A8Gd(l4kSP8lkowXP2Tp9nnQ)H6)r5pWb(xCWFb)2X1VO4yfNAkAjz77OJW96D(c7c8a4S4bOJoc3RxaoHQrf2x88G1MAGGaJkSVaqgpKOgreMQd44vcESMkG5wc7cR9XaHv454ILfPiunQW(INhS2udeeyuH9faY4He1iIWuDahxSSiLe8ynvaZTe2fwmqyfEoUyzrkcvJkSV45bRn1abbgvyFbGmEirnIimEibpwtfWClHDHnQWsGaSqrd5uFgHQrf2x88G1MAGGaJkSVaqgpKOgre28Oe8ynvaZTe2f2OclbcWcfnKFc2zeQiunQW(I7NhHDiBlKvzG(ozFbGlukzcvJkSV4(5X8G1gw4MzTRwLbqilNTsyxykzZlo5CHs2obJIKyHBwkFyIiiEG4K7efnnkzZlo5CHs2obZLiunQW(I7NhZdwBC4wvwLbu7uiqQPKkHDHPErNhWJ1KIjZ3r4E99Pui4VaLSrjnVa8MMo6iCVENVWUapaolEa6OJW96fG3cHQrf2xC)8yEWA7A8Gd(l4kSPKWUWWc3Su(Werq8aXj3jmhQeceeMi20OKnV4KZfkzJAyUjunQW(I7NhZdwBRXTkdWfkGutjvcvkfecIzZWGdZTe2fw(XaHv4pKTfYQmqFNSVaWfkLCs1)q9)O8RXTkdWfkGutj13f2jSVoP(hQ)hL)q2wiRYa9DY(caxOuY(ffhR455sTKmF1)q9)O8xJhCWFbxHnLFrXXk(PZAAuY2jyPVfcvJkSV4(5X8G12kWLTkdqjNocoSQlHDH5iCV(vGlBvgGsoDeCyv33)JIq1Oc7lUFEmpyTH5GJqa5zfLWUWuYMxCY5cLSDcMBcvJkSV4(5X8G1214b4VGqgbhYwGGWYWvcvkfecIzZWGdZTe2fMs28ItoxOKTtWoJq1Oc7lUFEmpyTPKnGJWYdjSlmLS5fNCUqjBNGrbHQrf2xC)8yEWAtTJskKvzak50raKLjhLvzsyxyoc3RpKrakch3F5a1aFuw8RNhJs6j3uIKyHBwkFyIiiEG4K7eMdvcbccteDH7KQ)H6)r5Vgp4G)cUcBk)IIJv8tyoujeiimrKq1Oc7lUFEmpyTfwgUa4dKOeQukieeZMHbhMBjSlmLS5fNCUqjBNGrrY8BFmqyfEzlaQx05BAuVOZd4XAsXwiunQW(I7NhZdwBZQMcbXVlwHe2fMs28ItoxOKTtWCtOAuH9f3ppMhS24WTQSkdO2PqGutjvc7ct9IopGhRjftMV6FO(FuENVWUapaolE4xuCSIFIIMM2R(eynv4luTp0V9wsMVs2obl9nnQ)H6)r5Vgp4G)cUcBk)IIJv8tPBtJ6FO(Fu(RXdo4VGRWMYVO4yf)0zjvY2jyNLelCZs5dtebXdsFAu7UPblCZs5dtebXdeNCudl)ZY7S2P6FO(Fu(RXdo4VGRWMYVO4yfN603stJJW965XVIaC2qgmvhCTf9cWBHq1Oc7lUFEmpyTPKnWXKaLWUWuVOZd4XAsrcvJkSV4(5X8G12fkLvzaoUWXkasnLujSlmhH7178sbW3x57)rjHvbURa8aMBcvJkSV4(5X8G1Md0OK(cbqQPKkHkLccbXSzyWH5wc7ct9IopGhRjftMVJW96DEPa47R8cWBAIbcRWlBbq9IoFs4lMaKP6E3(WYWfaFGetQKnyuKu9pu)pk)14bh8xWvyt5xuCSIt9znnkzZlo5CHs2OgM7KWxmbit19U9C4wvwLbu7uiqQPKMelCZs5dtebXdeNCuFwleQiunQW(I7vDahVWSkXlfb5eWceYi4q2ceewgUsyxyTpXS24aHE5hQdYjGvY8v)d1)JYVg3QmaxOasnLu)IIJvCQPOPP9QpbwtfEPPwBQwsMF7vFcSMk8fQ2h63EtJ6FO(FuENVWUapaolE4xuCSItnfT00CTm5aSO4yfNAkspHQrf2xCVQd44npyTfVGsg8xqhNqwc7c7AzYbyrXXk(P8DNotZfRqH3FZq)DIbceVGsUD6MI0APPXr4E984xraoBidMQdU2I((FujHJHpNawGqgbhYwGGWYW1pQWsGjZV9Qpbwtf(cv7d9BVPXr4E9oFHDbEaCw8WlaVLMM8v)d1)JYBvIxkcYjGfiKrWHSfiiSmC9lkowXpDTm5aSO4yfVLKoc3R35lSlWdGZIhEb4nnopNN8AzYbyrXXko1UtJq1Oc7lUx1bC8MhS2oWb(xCWFb)2Xvc7cl)DSoatGv4NEN7T6KlL(MMDSoatGv4NEN7fG3ss1)q9)O8RXTkdWfkGutj1VO4yfNAmhQeceeMiMu9pu)pkVvjEPiiNawGqgbhYwGGWYW1VO4yf)u(uKwEuKw7Cfk8(Bg6TkXlfxoOJqwMC0stJZZ5jVwMCawuCSIt9zPNq1Oc7lUx1bC8MhS2Udczfc4Xlcxc7ct9IopGhRjftM)owhGjWk8tVZ9wDYDAnn7yDaMaRWp9o3laVfcvJkSV4EvhWXBEWA7oqqyb(TJRe2f2owhGjWk8tVZ9wD6S0AA2X6ambwHF6DUxaoHQrf2xCVQd44npyT58f2f4bWzXdjSlmLSDcgfjVwMCawuCSIFkDtlz(Q)H6)r55XVIaC2qgmvhCTf9k5zZq(P0AAu)d1)JYZJFfb4SHmyQo4Al6xuCSIFYDATKmF4y4ZjGfiKrWHSfiiSmC9JkSeytJ6FO(FuERs8srqobSaHmcoKTabHLHRFrXXk(j3P10KywBCGqV8d1b5eWQLMM8vY2jyuK8AzYbyrXXko1Ws30sMpCm85eWceYi4CjBbccldx)Oclb20O(hQ)hL3QeVueKtalqiJGdzlqqyz46xuCSIF6AzYbyrXXkEljZx9pu)pkpp(veGZgYGP6GRTOxjpBgYpLwtJ6FO(FuEE8RiaNnKbt1bxBr)IIJv8txltoalkowXBACeUxpp(veGZgYGP6GRTOxaElT00CTm5aSO4yfNA3PNq1Oc7lUx1bC8MhS24XVIaC2qgmvhCTfbxl3eOe2fM6RUGfE1)B3QjWo4VxS4wc0J14aHDcvJkSV4EvhWXBEWAJh)kcWzdzWuDW1wuc7ct9pu)pkpp(veGZgYGP6GRTOxjpBgYHrrtZ1YKdWIIJvCQPiTMM83X6ambwHF6DUFrXXk(j3PVPj)2R(eynv4LMATPs2E1NaRPcFHQ9H(T3sY8ZFhRdWeyf(P35ERoP(hQ)hLNh)kcWzdzWuDW1w0FfGGalQKNndbHjInnTFhRdWeyf(P35EmNXdEljZx9pu)pkVvjEPiiNawGqgbhYwGGWYW1VO4yf)K6FO(FuEE8RiaNnKbt1bxBr)vaccSOsE2meeMi20KywBCGqV8d1b5eWQLwsQ(hQ)hL)A8Gd(l4kSP8lkowXPggLiPs2obJIKQ)H6)r5pKTfYQmqFNSVaWfkLSFrXXko1WCtrleQgvyFX9QoGJ38G1gp(veGZgYGP6GRTOe2fM6tG1uHxAQ1Mkz(oc3R)ah4FXb)f8BhxVa8MM8VwMCawuCSItT6FO(Fu(dCG)fh8xWVDC9lkowXBAu)d1)JYFGd8V4G)c(TJRFrXXk(j1)q9)O884xraoBidMQdU2I(RaeeyrL8SziimrSLKQ)H6)r5Vgp4G)cUcBk)IIJvCQHrjsQKTtWOiP6FO(Fu(dzBHSkd03j7laCHsj7xuCSItnm3u0cHQrf2xCVQd44npyTXJFfb4SHmyQo4AlkHDHP(eynv4luTp0V9KD0r4E9oFHDbEaCw8a0rhH71lapz(WXWNtalqiJGdzlqqyz46hvyjWMMeZAJde6LFOoiNawnnQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4Nu)d1)JYZJFfb4SHmyQo4Al6VcqqGfvYZMHGWeXMg1)q9)O8wL4LIGCcybczeCiBbccldx)IIJv8tNLwleQgvyFX9QoGJ38G1MahbwGIsuJicZkUAfIXbcbukHPcbrqhtykuc7cdog(CcybczeCiBbccldx)Oclb2048CEYRLjhGffhR4utrAeQgvyFX9QoGJ38G1MahbwGIsuJiclKrW1wEa4wMbjHDHbhdFobSaHmcoKTabHLHRFuHLaBAu)d1)JYBvIxkcYjGfiKrWHSfiiSmC9lkowXpLUPL8AzYbyrXXk(PZslTMgNNZtETm5aSO4yfNAksJq1Oc7lUx1bC8MhS2o2jK5XxOe2fgCm85eWceYi4q2ceewgU(rfwcSPX558KxltoalkowXPMI0iunQW(I7vDahV5bRTmOPBt8lh4m9muc7cdog(CcybczeCiBbccldx)Oclb2048CEYRLjhGffhR4utrAeQgvyFX9QoGJ38G1MahbwGIsuJicRV40V2IGeiNJqsyxyTpXS24aH(Ccyb(ciWrqSwjfJMg1)q9)O8wL4LIGCcybczeCiBbccldx)IIJv8tuKws4y4ZjGfiKrWHSfiiSmC9lkowXPMI0AAsmRnoqOx(H6GCcyrOAuH9f3R6aoEZdwBcCeybkkrnIimU80)JSD4WbXhOOe2fgCm85eWceYi4q2ceewgU(rfwcSPX558KxltoalkowXPMI0AAA)ku493m0BvIxkUCqhHSm5Gq1Oc7lUx1bC8MhS2e4iWcuKlHDH1(eZAJde6ZjGf4lGahbXALumAAu)d1)JYBvIxkcYjGfiKrWHSfiiSmC9lkowXprrAnnjM1ghi0l)qDqobSiunQW(I7vDahV5bRT4fuYG)cKoR4iHDHDTm5aSO4yf)eLiTMg4y4ZjGfiKrWHSfiiSmC9JkSeyttIzTXbc9YpuhKtaRMgNNZtETm5aSO4yfNA3PlHQrf2xCVQd44npyT5a9FhCf2usyxyQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4NolTMMeZAJde6LFOoiNawnnopNN8AzYbyrXXko1uKgHQrf2xCVQd44npyT5GlhxPwLjHDHP(hQ)hL3QeVueKtalqiJGdzlqqyz46xuCSIF6S0AAsmRnoqOx(H6GCcy1048CEYRLjhGffhR4u7o9eQgvyFX9QoGJ38G1gKLjhCaLuONjIvqOAuH9f3R6aoEZdwBxBrhO)7syxyQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4NolTMMeZAJde6LFOoiNawnnopNN8AzYbyrXXko1UtJq1Oc7lUx1bC8MhS2MsH8yhiGAGGKWUWu)d1)JYBvIxkcYjGfiKrWHSfiiSmC9lkowXpDwAnnjM1ghi0l)qDqobSAACEop51YKdWIIJvCQPincvJkSV4EvhWXBEWAZzYa)feRPKYLWUWCeUxpp(veGZgYGP6GRTOV)hfHQrf2xCVQd44npyTDHqUSANBiHDH5iCVEoUyzrkF)pQKoc3R35lSlWdGZIhGo6iCV((FujDeUxVZxyxGhaNfp89)OsMp)fGCSQ7HlWdbieGRa8W(QPH)cqow19jEOjmieWFOeyfTiHvbURa8ayIIy3MaH5wcRcCxb4bid6DgiyULWQa3vaEaSlm(la5yv3N4HMWGqa)HsGvqOIq1Oc7lUx1bCCXYIuWsmRnoqOe1iIW44ILfPaoclpK4HdJJHejgibeM6FO(FuEoUyzrk)IIJvCQD30ahdFobSaHmcoKTabHLHRFuHLatQ(hQ)hLNJlwwKYVO4yf)0zP1048CEYRLjhGffhR4utrAeQgvyFX9QoGJlwwKkpyTzvIxkcYjGfiKrWHSfiiSmCLWUWAFIzTXbc9YpuhKtaRMgNNZtETm5aSO4yfNAkspHQrf2xCVQd44ILfPYdwBoq)3bxHnLe2fwIzTXbc9CCXYIuahHLheQgvyFX9QoGJlwwKkpyT5GlhxPwLjHDHLywBCGqphxSSifWry5bHQrf2xCVQd44ILfPYdwBqwMCWbusHEMiwbHQrf2xCVQd44ILfPYdwBxBrhO)7syxyjM1ghi0ZXfllsbCewEqOAuH9f3R6aoUyzrQ8G12ukKh7abudeKe2fwIzTXbc9CCXYIuahHLheQgvyFX9QoGJlwwKkpyT5mzG)cI1us5syxyjM1ghi0ZXfllsbCewEqOAuH9f3R6aoUyzrQ8G1w8ckzWFbDCczjSlSRLjhGffhR4NY3D6mnxScfE)nd93jgiq8ck52PBksRLMg4y4ZjGfiKrWHSfiiSmC9JkSeyY8BV6tG1uHVq1(q)2BACeUxVZxyxGhaNfp8cWBPPjF1)q9)O8wL4LIGCcybczeCiBbccldx)IIJv8txltoalkowXBjPJW96D(c7c8a4S4HxaEtJZZ5jVwMCawuCSItT70iunQW(I7vDahxSSivEWAlEbLm4VaPZkosyxyxltoalkowXprjsRPbog(CcybczeCiBbccldx)Oclb2048CEYRLjhGffhR4u7oncvJkSV4EvhWXfllsLhS2oWb(xCWFb)2Xvc7ct9pu)pk)ACRYaCHci1us9lkowXPgZHkHabHjIeQgvyFX9QoGJlwwKkpyTzfxTcX4aHakLWuHGiOJjmfkHDHLywBCGqphxSSifWry5rtJZZ5jVwMCawuCSItnfPrOAuH9f3R6aoUyzrQ8G1MahbwGIsuJiclKrW1wEa4wMbjHDHLywBCGqphxSSifWry5rtJZZ5jVwMCawuCSItnfPrOAuH9f3R6aoUyzrQ8G12XoHmp(cLWUWsmRnoqONJlwwKc4iS8Gq1Oc7lUx1bCCXYIu5bRTmOPBt8lh4m9muc7clXS24aHEoUyzrkGJWYdcvJkSV4EvhWXfllsLhS2e4iWcuuIAeryC5P)hz7WHdIpqrjSlm4y4ZjGfiKrWHSfiiSmC9JkSeytJZZ5jVwMCawuCSItnfP100(vOW7VzO3QeVuC5GoczzYbHQrf2xCVQd44ILfPYdwBcCeybkYLWUWAFIzTXbc95eWc8fqGJGyTskgnnQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4NOiTMMeZAJde6LFOoiNaweQgvyFX9QoGJlwwKkpyTDheYkeWJxeoHQrf2xCVQd44ILfPYdwB3bcclWVDCjunQW(I7vDahxSSivEWAZ5lSlWdGZIhsyxyopNN8AzYbyrXXko1UtFtt(kz7emksM)1YKdWIIJv8tPBAjZpF1)q9)O8CCXYIu(ffhR4NCNwtJJW9654ILfP8cWBAu)d1)JYZXflls5fG3sY8HJHpNawGqgbhYwGGWYW1pQWsGnnQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4NCNwttIzTXbc9YpuhKtaRwAPLMM8VwMCawuCSItnS0nTK5dhdFobSaHmcoxYwGGWYW1pQWsGnnQ)H6)r5TkXlfb5eWceYi4q2ceewgU(ffhR4NUwMCawuCSI3slTqOAuH9f3R6aoUyzrQ8G1ghxSSiLe2fM6FO(Fu(14wLb4cfqQPK6xuCSItnfnnopNN8AzYbyrXXko1UtpHQrf2xCVQd44ILfPYdwBotg4VGynLuoHQrf2xCVQd44ILfPYdwBxiKlR25gsyxyoc3RNJlwwKY3)JkPJW96D(c7c8a4S4bOJoc3RV)hvshH7178f2f4bWzXdF)pQK5ZFbihR6E4c8qacb4kapSVAA4VaKJvDFIhAcdcb8hkbwrlsyvG7kapaMOi2TjqyULWQa3vaEaYGENbcMBjSkWDfGha7cJ)cqow19jEOjmieWFOeyfeQiunQW(I7F4yHlSRXdWFbHmcoKTabHLHReQukieeZMHbhMBjSlmLS5fNCUqjBNGDgHQrf2xC)dhlCZdwByo4ieqEwrjSlSyGWk8kzd4iS8WJ14aH9KkzZlo5CHs2ob7mcvJkSV4(how4MhS2cldxa8bsucvkfecIzZWGdZTe2fM6fDEapwtkMujBEXjNluY2jyuqOAuH9f3)WXc38G1Ms2ahtcuc7ctjBEXjNluYgmkiunQW(I7F4yHBEWAdZbhHaYZksOAuH9f3)WXc38G1wyz4cGpqIsOsPGqqmBggCyULWUWuYMxCY5cLSDcgfeQiunQW(I754ILfPGDnEWb)fCf2usyxyoc3RNJlwwKYVO4yfNA3eQgvyFX9CCXYIu5bRnoCRkRYaQDkei1usLWUWuVOZd4XAsXK5pQWsGaSqrd5NGDwtZOclbcWcfnKFYDY2R(hQ)hLFnUvzaUqbKAkPEb4TqOAuH9f3ZXfllsLhS2wJBvgGluaPMsQeQukieeZMHbhMBjSlm1l68aESMuKq1Oc7lUNJlwwKkpyTDnEWb)fCf2usyxyJkSeialu0q(jyNrOAuH9f3ZXfllsLhS24WTQSkdO2PqGutjvc7ct9IopGhRjft6iCV((uke8xGs2OKMxaoHQrf2xCphxSSivEWAZbAusFHai1usLqLsbHGy2mm4WClHDHPErNhWJ1KIjDeUx)boW)Id(l43oUEb4jv)d1)JYVg3QmaxOasnLu)IIJv8tuqOAuH9f3ZXfllsLhS2Ugp4G)cUcBkjSkWDfGha7cR9Q)H6)r5xJBvgGluaPMsQxaoHQrf2xCphxSSivEWAJd3QYQmGANcbsnLujSlm1l68aESMumzhDeUxVZxyxGhaNfpaD0r4E9cWjunQW(I754ILfPYdwBxJhG)cczeCiBbccldxjuPuqiiMnddom3syxykzJ6ZiunQW(I754ILfPYdwBoqJs6leaPMsQeQukieeZMHbhMBjSlm1l68aESMuSPP9XaHv4LTaOErNNq1Oc7lUNJlwwKkpyTXHBvzvgqTtHaPMskHkcvJkSV4EEa7q2wiRYa9DY(caxOuYsyxy7yDaMaRWp9o3B1j1)q9)O8hY2czvgOVt2xa4cLs23f2jSVANP5tNnn7yDaMaRWp9o3laNq1Oc7lUNh5bRnSWnZAxTkdGqwoBLWUWuYMxCY5cLSDcgfjXc3Su(Werq8aXj3PZAAuYMxCY5cLSDcMlLmFSWnlLpmreepqCYDIIMM2dFXeGmv372hwgUa4dKyleQgvyFX98ipyTXHBvzvgqTtHaPMsQe2fM6fDEapwtkM0r4E99Pui4VaLSrjnVa8K5VJ1bycSc)07CVvNCeUxFFkfc(lqjBusZVO4yf3fu00SJ1bycSc)07CVa8wiunQW(I75rEWA7cHCz1o3qcRcCxb4bWefXUnbcZTewf4UcWdGDH5iCV(ep0egec4pucScGSG4uV19cWBAWc3Su(Werq8aXjh1N10O(hQ)hLFnUvzaUqbKAkP(ffhR4utrtJ6FO(Fu(RXdo4VGRWMYVO4yfNAkKWUW4VaKJvDFIhAcdcb8hkbwrshH71ZJFfb4SHmyQo4Al67)rLSJoc3R35lSlWdGZIhGo6iCV((FueQgvyFX98ipyTTg3QmaxOasnLujuPuqiiMnddom3syxyQ)H6)r554ILfP8lkowXp5UPP9XaHv454ILfPsMV6FO(Fu(dCG)fh8xWVDC9lkowXp5snnTx9jWAQWln1At1cHQrf2xCppYdwBxJhCWFbxHnLe2fw(7yDaMaRWp9o3B1j1)q9)O8xJhCWFbxHnLVlStyF1otZNoBA2X6ambwHF6DUxaEljZhlCZs5dtebXdeNCNWCOsiqqyIOlC30OKnV4KZfkzJAyUBACeUxpp(veGZgYGP6GRTOFrXXko1youjeiimrmp3T00CTm5aSO4yfNAmhQeceeMiMN7MMo6iCVENVWUapaolEa6OJW96fGtOAuH9f3ZJ8G1MAhLuiRYauYPJailtokRYKWUWCeUxFiJaueoU)YbQb(OS4xppgL0tUPejXc3Su(Werq8aXj3jmhQeceeMi6c3jv)d1)JYVg3QmaxOasnLu)IIJv8tyoujeiimrSPXr4E9Hmcqr44(lhOg4JYIF98yusp52LsMV6FO(FuEoUyzrk)IIJvCQtFYyGWk8CCXYIunnQ)H6)r5pWb(xCWFb)2X1VO4yfN60Nu9jWAQWln1At10CTm5aSO4yfN603cHQrf2xCppYdwBRax2QmaLC6i4WQUe2fMJW96xbUSvzak50rWHvDF)pQKJkSeialu0q(j3eQgvyFX98ipyTDnEa(liKrWHSfiiSmCLqLsbHGy2mm4WClHDHPKnQpJq1Oc7lUNh5bRnmhCecipROe2fMs28ItoxOKTtWCtOAuH9f3ZJ8G1Ms2aoclpKWUWuYMxCY5cLSDcM7KJkSeialu0qom3j3X6ambwHF6DU3QtuKwtJs28ItoxOKTtWOi5OclbcWcfnKFcgfeQgvyFX98ipyTPKnWXKajunQW(I75rEWAlSmCbWhirjuPuqiiMnddom3syxyQx05b8ynPysLS5fNCUqjBNGrrshH71ZJFfb4SHmyQo4Al67)rrOAuH9f3ZJ8G1ghUvLvza1ofcKAkPsyxyoc3RxjBaSWnlLNhJs6PZsZfPVDoQWsGaSqrd5jDeUxpp(veGZgYGP6GRTOV)hvY8v)d1)JYVg3QmaxOasnLu)IIJv8tuKu9pu)pk)14bh8xWvyt5xuCSIFIIMg1)q9)O8RXTkdWfkGutj1VO4yfN6ZsQ(hQ)hL)A8Gd(l4kSP8lkowXpDwsLSD6SMg1)q9)O8RXTkdWfkGutj1VO4yf)0zjv)d1)JYFnEWb)fCf2u(ffhR4uFwsLSDYLAAuYMxCY5cLSrnm3jXc3Su(Werq8aXjh1u0stJJW96vYgalCZs55XOKEYDAjVwMCawuCSIt95Mq1Oc7lUNh5bRnhOrj9fcGutjvcvkfecIzZWGdZTe2fM6fDEapwtkMm)yGWk8CCXYIujv)d1)JYZXflls5xuCSIt9znnQ)H6)r5xJBvgGluaPMsQFrXXk(j3jv)d1)JYFnEWb)fCf2u(ffhR4NC30O(hQ)hLFnUvzaUqbKAkP(ffhR4uFws1)q9)O8xJhCWFbxHnLFrXXk(PZsQKTtu00O(hQ)hLFnUvzaUqbKAkP(ffhR4NolP6FO(Fu(RXdo4VGRWMYVO4yfN6ZsQKTtN10OKTtPVPXr4E9oVua89vEb4TqOAuH9f3ZJ8G1wyz4cGpqIsOsPGqqmBggCyULWUWuVOZd4XAsXKkzZlo5CHs2obJccvJkSV4EEKhS2MvnfcIFxScjSlmLS5fNCUqjBNG5Mq1Oc7lUNh5bRTlukRYaCCHJvaKAkPsyvG7kapG5Mq1Oc7lUNh5bRnhOrj9fcGutjvcvkfecIzZWGdZTe2fM6fDEapwtkMu9pu)pk)14bh8xWvyt5xuCSIt9zjvYgmkscFXeGmv372hwgUa4dKysSWnlLpmreepi9PrTBcvJkSV4EEKhS2CGgL0xiasnLujuPuqiiMnddom3syxyQx05b8ynPysSWnlLpmreepqCYrnfjZxjBEXjNluYg1WC30aFXeGmv372hwgUa4dKyleQiunQW(I7pWb(xCWFb)2XfwIzTXbcLOgreMd0OK(cbqQPKcke7yxIhomogsKyGeqyoc3R)ah4FXb)f8BhxWXHFrXXkEY8v)d1)JYVg3QmaxOasnLu)IIJv8toc3R)ah4FXb)f8BhxWXHFrXXkEshH71FGd8V4G)c(TJl44WVO4yfNAk8UBAu)d1)JYVg3QmaxOasnLu)IIJvCx4iCV(dCG)fh8xWVDCbhh(ffhR4NC7PejDeUx)boW)Id(l43oUGJd)IIJvCQDjV7MghH717a9FhsGhEb4jDeUxVvjEP4YbDeYYKdVa8Koc3R3QeVuC5GoczzYHFrXXko1oc3R)ah4FXb)f8BhxWXHFrXXkEleQgvyFX9h4a)lo4VGF74MhS2udeeyuH9faY4He1iIWuDahVsWJ1ubm3syxyTpgiScphxSSifHQrf2xC)boW)Id(l43oU5bRn1abbgvyFbGmEirnIimvhWXfllsjbpwtfWClHDHfdewHNJlwwKIq1Oc7lU)ah4FXb)f8Bh38G1gw4MzTRwLbqilNTsyxykzZlo5CHs2obJIKyHBwkFyIiiEG4K70zeQgvyFX9h4a)lo4VGF74MhS2wJBvgGluaPMsQeQukieeZMHbhMBcvJkSV4(dCG)fh8xWVDCZdwBxJhCWFbxHnLe2f2OclbcWcfnKFcgfjDeUx)boW)Id(l43oUGJd)IIJvCQDtOAuH9f3FGd8V4G)c(TJBEWA7q2wiRYa9DY(caxOuYsyxyJkSeialu0q(jyuqOAuH9f3FGd8V4G)c(TJBEWAJd3QYQmGANcbsnLujSlm1l68aESMum5OclbcWcfnKFc2zjDeUx)boW)Id(l43oUGJdVaCcvJkSV4(dCG)fh8xWVDCZdwBoqJs6leaPMsQeQukieeZMHbhMBjSlm1l68aESMum5OclbcWcfnKtnmksMywBCGqVd0OK(cbqQPKcke7yNq1Oc7lU)ah4FXb)f8Bh38G1ghUvLvza1ofcKAkPsyxyQx05b8ynPyshH713NsHG)cuYgL08cWjunQW(I7pWb(xCWFb)2XnpyTH5GJqa5zfLWUWuYgS0s6iCV(dCG)fh8xWVDCbhh(ffhR4u7seQgvyFX9h4a)lo4VGF74MhS2Ugpa)feYi4q2ceewgUsOsPGqqmBggCyULWUWuYgS0s6iCV(dCG)fh8xWVDCbhh(ffhR4u7seQgvyFX9h4a)lo4VGF74MhS2oKTfYQmqFNSVaWfkLmHQrf2xC)boW)Id(l43oU5bRTWYWfaFGeLqLsbHGy2mm4WClHDHPKnyPL0r4E9h4a)lo4VGF74coo8lkowXP2LiunQW(I7pWb(xCWFb)2XnpyTDnEWb)fCf2usyvG7kapG5wc7cZr4E984xraoBidMQdU2IEb4j3X6ambwHF6DU3QtQ)H6)r5Vgp4G)cUcBkFxyNW(QDMMpDjunQW(I7pWb(xCWFb)2XnpyTXHBvzvgqTtHaPMsQe2fMJW96vYgalCZs55XOKE6S0Cr6BNJkSeialu0qoHQrf2xC)boW)Id(l43oU5bRTRXdWFbHmcoKTabHLHReQukieeZMHbhMBjSlmLSr9zeQgvyFX9h4a)lo4VGF74MhS2WCWriG8SIsyxykzZlo5CHs2obZnHQrf2xC)boW)Id(l43oU5bRnLSbCewEiHDHPKnV4KZfkz7eS8DN3OclbcWcfnKFYDleQgvyFX9h4a)lo4VGF74MhS2cldxa8bsucvkfecIzZWGdZTe2fw(TpgiScVSfa1l68nnQx05b8ynPyljvYMxCY5cLSDcgfeQgvyFX9h4a)lo4VGF74MhS2CGgL0xiasnLujuPuqiiMnddom3syxyJkSeialu0qo1WolPs2ob7SMghH71FGd8V4G)c(TJl44WlaNq1Oc7lU)ah4FXb)f8Bh38G1Ms2ahtcKq1Oc7lU)ah4FXb)f8Bh38G12fkLvzaoUWXkasnLujSkWDfGhWCRPhHq(xnnTjEE6qhAna]] )


end