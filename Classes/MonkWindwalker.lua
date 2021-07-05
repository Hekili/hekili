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
                local app = state.buff.crackling_jade_lightning.applied
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


    spec:RegisterPack( "Windwalker", 20210705, [[dS0cFcqiLK6rkPiBsaFcLuJsk4usHwLGk6vcjZIe1TOs0UOQFPKyyckhJk1YiHEMsQMgkjDnbvTnLK4BkPGXrLGoNskzDkjP5rcUhISpPOdkOcTqHupeLenrbvqUOGkPnkOc4JkPqoPGkXkrjEPGkqZujL6McQGANKi)ujfQLkOs5POyQuj9vLuuJLkH2lP(lWGr6Wkwmv8yunzP6YqBwP(SqnAI60uwnkj8AuQzJWTjYUL8BvnCe1XPsGLRYZjmDrxNK2UG8DLy8cX5fO1lOs18Ls7h0A3Ax1m9jrTskgMIUdBnew49H5cdFyS66AMmizuZqE4SNyuZuJeQzwZw1xgc24Pzipbj(PRDvZiE1JJAgnJJQrKHlL2rZ0Ne1kPyyk6oS1qyH3hMlm8HXQU1mcYixRKIRYAPzKTEhlTJMPJcUMznBvFziyJhKgo8xSHSWIkrqin8kdPkgMIUHSazX1fCydPHdyIuaP)gsdhq9ccPwL4DQKtiL4JnUhYIRl4WgsziBvzvmKYkVPqinCqJZgsj(yJ7HSeo27qQZleBlwoHuUmYzlG08HuPPccPSYWHGuSYZqHxZqyIuODvZ8KXcpTRALCRDvZG14qGDD0AMHN2xAMTjsWVbPmcwKTebPfJNMHFwINnAgUS5LMiqQlHuUSbPnjbPRRz4b5eiiN7IXuOzCRtTskQDvZG14qGDD0Ag(zjE2OzYHaR0ZLnGJ6jspwJdb2H0aqkx28stei1Lqkx2G0MKG011mdpTV0myeYibqEojDQvADTRAgSghcSRJwZm80(sZKwmEaYdHKMHFwINnAg(l58arEgBesdaPCzZlnrGuxcPCzdsBscsvuZWdYjqqoxmMcTsU1Pwjwv7QMbRXHa76O1m8Zs8SrZWLnV0ebsDjKYLniLeKQOMz4P9LMHlBGLjeQtTsHx7QMz4P9LMbJqgjaYZjPzWACiWUoADQvAv0UQzWACiWUoAnZWt7lntAX4bipesAg(zjE2Oz4YMxAIaPUes5YgK2KeKQOMHhKtGGCUymfALCRtDQzwWH8xcWVb)1Xt7Qwj3Ax1mynoeyxhTM5jRzeyQzgEAFPzcnNnoeOMj0qOIAgh192VGd5VeGFd(RJhyzXFO0yLasdaPnaP8)j6)s5ptyvmqOwa2gNT)qPXkbK2esDu3B)coK)sa(n4VoEGLf)HsJvcinaK6OU3(fCi)La8BWFD8all(dLgReqQcqQIE3qABlKY)NO)lL)mHvXaHAbyBC2(dLgReqQlHuh192VGd5VeGFd(RJhyzXFO0yLasBcPU9RfKgasDu3B)coK)sa(n4VoEGLf)HsJvcivbiLv9UH02wi1rDV9oe)3jufPxLmKgasDu3BVvHE24jaDKWILtVkzinaK6OU3ERc9SXta6iHflN(dLgReqQcqQJ6E7xWH8xcWVb)1XdSS4puASsaPnQzcnhOgjuZ4qmC2VAcyBC2GcXo21Pwjf1UQzWACiWUoAnd)SepB0mRgsZHaR0lWdlld6XACiWUMz4P9LMHpeeGHN2xactKAgctKGAKqndVde4wNALwx7QMbRXHa76O1m8Zs8SrZKdbwPxGhwwg0J14qGDnZWt7lndFiiadpTVaeMi1meMib1iHAgEhiWdlldQtTsSQ2vndwJdb21rRz4NL4zJMHlBEPjcK6siLlBqAtsqQIqAaifl8Id6ttcb5dKMiqAtiDDnZWt7lndw4fBH7wfdqclID6uRu41UQzWACiWUoAnZWt7lnZzcRIbc1cW24S1m8GCceKZfJPqRKBDQvAv0UQzWACiWUoAnd)SepB0mdpTqialuYqbK2KeKQiKgasDu3B)coK)sa(n4VoEGLf)HsJvcivbi1TMz4P9LMzBIua(nyREb1PwP1G2vndwJdb21rRz4NL4zJMz4PfcbyHsgkG0MKGuf1mdpTV0mlY2ryvmOFt8xaYQfxwNALCHAx1mynoeyxhTMHFwINnAg(l58arEgBesdaPdpTqialuYqbK2KeKUoKgasDu3B)coK)sa(n4VoEGLfVkznZWt7lnJGSvLvXa(nfcyBC26uR0APDvZG14qGDD0AMHN2xAghIHZ(vtaBJZwZWplXZgnd)LCEGipJncPbG0HNwieGfkzOasvGeKQiKgasdnNnoeO3Hy4SF1eW24SbfIDSRz4b5eiiNlgtHwj36uRK7W0UQzWACiWUoAnd)SepB0m8xY5bI8m2iKgasDu3BFFkoc(nGlBScZRswZm80(sZiiBvzvmGFtHa2gNTo1k52T2vndwJdb21rRz4NL4zJMHlBqkjinminaK6OU3(fCi)La8BWFD8all(dLgReqQcqkRQzgEAFPzWiKrcG8Cs6uRKBf1UQzWACiWUoAnZWt7lnZ2ej43GugblYwIG0IXtZWplXZgndx2GusqAyqAai1rDV9l4q(lb43G)64bww8hknwjGufGuwvZWdYjqqoxmMcTsU1Pwj3RRDvZm80(sZSiBhHvXG(nXFbiRwCzndwJdb21rRtTsUzvTRAgSghcSRJwZm80(sZKwmEaYdHKMHFwINnAgUSbPKG0WG0aqQJ6E7xWH8xcWVb)1XdSS4puASsaPkaPSQMjNlgtGT1mrbPnaPD0rDV9c2bpC4YamI8Oks7lVkzinCcPkggK2Oo1k5o8Ax1mynoeyxhTMHFwINnAgh192lY)Ka4CPmyQoyBh6vjdPbG0BSoadHv6NEx4TcsBcP8)j6)s53MifGFd2QxqFx9M0(csdNqAy(vrZm80(sZSnrka)gSvVGAgRs8ovYjW2Agh192VGd5VeGFd(RJhyzXRswNALCVkAx1mynoeyxhTMHFwINnAgh192ZLnaw4fh0lYHZgsBcPRhgK6sin8qA4eshEAHqawOKHcnZWt7lnJGSvLvXa(nfcyBC26uRK71G2vndwJdb21rRzgEAFPz2Mib)gKYiyr2seKwmEAg(zjE2Oz4YgKQaKUUMHhKtGGCUymfALCRtTsUDHAx1mynoeyxhTMHFwINnAgUS5LMiqQlHuUSbPnjbPU1mdpTV0myeYibqEojDQvY9APDvZG14qGDD0Ag(zjE2Oz4YMxAIaPUes5YgK2KeK2aK6gsJcshEAHqawOKHciTjK6gsBuZm80(sZWLnGJ6jsDQvsXW0UQzWACiWUoAnZWt7lntAX4bipesAg(zjE2OzAasxnKMdbwPx2sa)LCEpwJdb2H02wiL)sopqKNXgH0gH0aqkx28stei1Lqkx2G0MKGuf1m8GCceKZfJPqRKBDQvsr3Ax1mynoeyxhTMz4P9LMXHy4SF1eW24S1m8Zs8SrZm80cHaSqjdfqQcKG01H0aqkx2G0MKG01H02wi1rDV9l4q(lb43G)64bww8QK1m8GCceKZfJPqRKBDQvsrf1UQzgEAFPz4YgyzcHAgSghcSRJwNALuCDTRAgRs8ovYPMXTMz4P9LMzte0QyGapYyLa2gNTMbRXHa76O1Po1mc8WYYGAx1k5w7QMbRXHa76O1m8Zs8SrZ4OU3EbEyzzq)HsJvcivbi1TMz4P9LMzBIua(nyREb1Pwjf1UQzWACiWUoAnd)SepB0m8xY5bI8m2iKgasBashEAHqawOKHciTjjiDDiTTfshEAHqawOKHciTjK6gsdaPRgs5)t0)LYFMWQyGqTaSnoBVkziTrnZWt7lnJGSvLvXa(nfcyBC26uR06Ax1mynoeyxhTMz4P9LM5mHvXaHAbyBC2Ag(zjE2Oz4VKZde5zSrndpiNab5CXyk0k5wNALyvTRAgSghcSRJwZWplXZgnZWtlecWcLmuaPnjbPRRzgEAFPz2MifGFd2QxqDQvk8Ax1mynoeyxhTMHFwINnAg(l58arEgBesdaPoQ7TVpfhb)gWLnwH5vjRzgEAFPzeKTQSkgWVPqaBJZwNALwfTRAgSghcSRJwZm80(sZ4qmC2VAcyBC2Ag(zjE2Oz4VKZde5zSrinaK6OU3(fCi)La8BWFD88QKH0aqk)FI(Vu(ZewfdeQfGTXz7puASsaPnHuf1m8GCceKZfJPqRKBDQvAnODvZyvI3Psob2wZ4OU3EbEyzzqVk5a8)j6)s5ptyvmqOwa2gNT)WPhuZm80(sZSnrka)gSvVGAgSghcSRJwNALCHAx1mynoeyxhTMHFwINnAg(l58arEgBesdaPD0rDV9oFHDvrcCoCb0rh192RswZm80(sZiiBvzvmGFtHa2gNTo1kTwAx1mynoeyxhTMz4P9LMzBIe8BqkJGfzlrqAX4Pz4NL4zJMHlBqQcq66AgEqobcY5IXuOvYTo1k5omTRAgSghcSRJwZm80(sZ4qmC2VAcyBC2Ag(zjE2Oz4VKZde5zSriTTfsxnKMdbwPx2sa)LCEpwJdb21m8GCceKZfJPqRKBDQvYTBTRAMHN2xAgbzRkRIb8BkeW24S1mynoeyxhTo1PMH3bc8WYYGAx1k5w7QMbRXHa76O1mpznJatnZWt7lntO5SXHa1mHgcvuZW)NO)lLxGhwwg0FO0yLasvasDdPTTqkzm9ruXcKYiyr2seKwmE(HNwiesdaP8)j6)s5f4HLLb9hknwjG0Mq66HbPTTqQZleqAaiDBXYj4qPXkbKQaKQyyAMqZbQrc1mc8WYYGah1tK6uRKIAx1mynoeyxhTMHFwINnAMvdPHMZghc0l)eDqevSG02wi15fcinaKUTy5eCO0yLasvasvm8AMHN2xAgRc9SrqevS0PwP11UQzWACiWUoAnd)SepB0mHMZghc0lWdlldcCuprQzgEAFPzCi(Vd2QxqDQvIv1UQzWACiWUoAnd)SepB0mHMZghc0lWdlldcCuprQzgEAFPzCWtGhBRI1PwPWRDvZm80(sZqyXYPaWku7XsyLAgSghcSRJwNALwfTRAgSghcSRJwZWplXZgntO5SXHa9c8WYYGah1tKAMHN2xAMTDOdX)DDQvAnODvZG14qGDD0Ag(zjE2OzcnNnoeOxGhwwge4OEIuZm80(sZmfhf5nea(qqOtTsUqTRAgSghcSRJwZWplXZgntO5SXHa9c8WYYGah1tKAMHN2xAgNjg8BqEgNTqNALwlTRAgSghcSRJwZWplXZgnZ2ILtWHsJvciTjK2aK62fggK6si9ulC)xm63toeG8v5YESghcSdPHti1TIHbPncPTTqkzm9ruXcKYiyr2seKwmE(HNwiesBBHuNxiG0aq62ILtWHsJvcivbi1DyAMHN2xAM8v5YGFd64KY6uRK7W0UQzWACiWUoAnd)SepB0mBlwobhknwjG0Mq6AfgK22cPKX0hrflqkJGfzlrqAX45hEAHqiTTfsDEHasdaPBlwobhknwjGufGu3HPzgEAFPzYxLld(nG9CsJo1k52T2vndwJdb21rRz4NL4zJMH)pr)xk)zcRIbc1cW24S9hknwjGufGumcYvteKMeQzgEAFPzwWH8xcWVb)1XtNALCRO2vndwJdb21rRz4NL4zJMj0C24qGEbEyzzqGJ6jsnZWt7lnJvc(PMJdbcCbQtLQsGogY4Oo1k5EDTRAgSghcSRJwZWplXZgntO5SXHa9c8WYYGah1tKAMHN2xAMLBszr(fQtTsUzvTRAgSghcSRJwZWplXZgntO5SXHa9c8WYYGah1tKAMHN2xAMyIPBt(Na4m9yuNALChETRAgSghcSRJwZm80(sZiKN(VeFJGmi)eL0m8Zs8SrZqgtFevSaPmcwKTebPfJNF4PfcH02wi15fcinaKUTy5eCO0yLasvasvmmiTTfsxnKEQfU)lg9wf6zJNa0rclwo9ynoeyxZuJeQzeYt)xIVrqgKFIs6uRK7vr7QMbRXHa76O1m8Zs8SrZSAin0C24qG(iQyb(cOkqqEwXgtiTTfs5)t0)LYBvONncIOIfiLrWISLiiTy88hknwjG0MqQIHbPTTqAO5SXHa9YprherflnZWt7lnJQabwIscDQvY9Aq7QMz4P9LMzpiHviqKVezndwJdb21rRtTsUDHAx1mdpTV0m7HGalWFD80mynoeyxhTo1k5ET0UQzWACiWUoAnd)SepB0moVqaPbG0TflNGdLgReqQcqQ7WdPTTqAdqkx2G0MKGufH0aqAdq62ILtWHsJvciTjKUkHbPbG0gG0gGu()e9FP8c8WYYG(dLgReqAti1DyqABlK6OU3EbEyzzqVkziTTfs5)t0)LYlWdlld6vjdPncPbG0gGuYy6JOIfiLrWISLiiTy88dpTqiK22cP8)j6)s5Tk0ZgbruXcKYiyr2seKwmE(dLgReqAti1DyqABlKgAoBCiqV8t0bruXcsBesBesBesBBH0gG0TflNGdLgReqQcKG0vjminaK2aKsgtFevSaPmcwZYwIG0IXZp80cHqABlKY)NO)lL3QqpBeerflqkJGfzlrqAX45puASsaPnH0TflNGdLgReqAJqAJqAJAMHN2xAgNVWUQibohUOtTskgM2vndwJdb21rRz4NL4zJMH)pr)xk)zcRIbc1cW24S9hknwjGufGufH02wi15fcinaKUTy5eCO0yLasvasDhEnZWt7lnJapSSmOo1kPOBTRAMHN2xAgNjg8BqEgNTqZG14qGDD06uRKIkQDvZG14qGDD0Ag(zjE2OzeVkHJvDpzvrQsGa8ujN2xESghcSdPbGuh192lWdlld67)sbPbG0o6OU3ENVWUQibohUa6OJ6E77)sPzgEAFPz2eOqMFZo1Po1mIu7Qwj3Ax1mynoeyxhTMHFwINnAMBSoadHv6NEx4TcsBcP8)j6)s5xKTJWQyq)M4VaKvlUSVREtAFbPHtinmVlesBBH0BSoadHv6NEx4vjRzgEAFPzwKTJWQyq)M4VaKvlUSo1kPO2vndwJdb21rRz4NL4zJMHlBEPjcK6siLlBqAtsqQIqAaifl8Id6ttcb5dKMiqAtiDDiTTfs5YMxAIaPUes5YgK2KeKYQqAaiTbifl8Id6ttcb5dKMiqAtivriTTfsxnKs(WqGyE372NwmEaYdHeK2OMz4P9LMbl8ITWDRIbiHfXoDQvADTRAgSghcSRJwZWplXZgnd)LCEGipJncPbGuh1923NIJGFd4YgRW8QKH0aqAdq6nwhGHWk9tVl8wbPnHuh1923NIJGFd4YgRW8hknwjGuxcPkcPTTq6nwhGHWk9tVl8QKH0g1mdpTV0mcYwvwfd43uiGTXzRtTsSQ2vndwJdb21rRzgEAFPzotyvmqOwa2gNTMHFwINnAg()e9FP8c8WYYG(dLgReqAti1nK22cPRgsZHaR0lWdlld6XACiWoKgasBas5)t0)LYVGd5VeGFd(RJN)qPXkbK2eszviTTfsxnKY)qynv6zh8SPG0g1m8GCceKZfJPqRKBDQvk8Ax1mynoeyxhTMHFwINnAMgG0BSoadHv6NEx4TcsBcP8)j6)s53MifGFd2QxqFx9M0(csdNqAyExiK22cP3yDagcR0p9UWRsgsBesdaPnaPyHxCqFAsiiFG0ebsBcPyeKRMiinjesDjK6gsBBHuUS5LMiqQlHuUSbPkqcsDdPTTqQJ6E7f5FsaCUugmvhSTd9hknwjGufGumcYvteKMecPrbPUH0gH02wiDBXYj4qPXkbKQaKIrqUAIG0Kqinki1nK22cPD0rDV9oFHDvrcCoCb0rh192RswZm80(sZSnrka)gSvVG6uR0QODvZG14qGDD0Ag(zjE2OzCu3BFkJauImE)ja8H8WT8pVihoBiTjK6ETG0aqkw4fh0NMecYhinrG0Mqkgb5QjcstcHuxcPUH0aqk)FI(Vu(ZewfdeQfGTXz7puASsaPnHumcYvteKMecPTTqQJ6E7tzeGsKX7pbGpKhUL)5f5WzdPnHu3SkKgasBas5)t0)LYlWdlld6puASsaPkaPHhsdaP5qGv6f4HLLb9ynoeyhsBBHu()e9FP8l4q(lb43G)645puASsaPkaPHhsdaP8pewtLE2bpBkiTTfs3wSCcouASsaPkaPHhsBuZm80(sZWVHZMWQyaRy6iGWILZYQyDQvAnODvZG14qGDD0Ag(zjE2OzCu3B)PkKTkgWkMocwSQ77)sbPbG0HNwieGfkzOasBcPU1mdpTV0mNQq2QyaRy6iyXQUo1k5c1UQzWACiWUoAnZWt7lnZ2ej43GugblYwIG0IXtZWplXZgndx2GufG011m8GCceKZfJPqRKBDQvAT0UQzWACiWUoAnd)SepB0mCzZlnrGuxcPCzdsBscsDRzgEAFPzWiKrcG8Cs6uRK7W0UQzWACiWUoAnd)SepB0mCzZlnrGuxcPCzdsBscsDdPbG0HNwieGfkzOasjbPUH0aq6nwhGHWk9tVl8wbPnHufddsBBHuUS5LMiqQlHuUSbPnjbPkcPbG0HNwieGfkzOasBscsvuZm80(sZWLnGJ6jsDQvYTBTRAMHN2xAgUSbwMqOMbRXHa76O1Pwj3kQDvZG14qGDD0AMHN2xAM0IXdqEiK0m8Zs8SrZWFjNhiYZyJqAaiLlBEPjcK6siLlBqAtsqQIqAai1rDV9I8pjaoxkdMQd22H((VuAgEqobcY5IXuOvYTo1k5EDTRAgSghcSRJwZWplXZgnJJ6E75Ygal8Id6f5WzdPnH01ddsDjKgEinCcPdpTqialuYqbKgasDu3BVi)tcGZLYGP6GTDOV)lfKgasBas5)t0)LYFMWQyGqTaSnoB)HsJvciTjKQiKgas5)t0)LYVnrka)gSvVG(dLgReqAtivriTTfs5)t0)LYFMWQyGqTaSnoB)HsJvcivbiDDinaKY)NO)lLFBIua(nyREb9hknwjG0Mq66qAaiLlBqAtiDDiTTfs5)t0)LYFMWQyGqTaSnoB)HsJvciTjKUoKgas5)t0)LYVnrka)gSvVG(dLgReqQcq66qAaiLlBqAtiLvH02wiLlBEPjcK6siLlBqQcKGu3qAaifl8Id6ttcb5dKMiqQcqQIqAJqABlK6OU3EUSbWcV4GEroC2qAti1DyqAaiDBXYj4qPXkbKQaKUg0mdpTV0mcYwvwfd43uiGTXzRtTsUzvTRAgSghcSRJwZm80(sZ4qmC2VAcyBC2Ag(zjE2Oz4VKZde5zSrinaK2aKMdbwPxGhwwg0J14qGDinaKY)NO)lLxGhwwg0FO0yLasvasxhsBBHu()e9FP8NjSkgiulaBJZ2FO0yLasBcPUH0aqk)FI(Vu(Tjsb43GT6f0FO0yLasBcPUH02wiL)pr)xk)zcRIbc1cW24S9hknwjGufG01H0aqk)FI(Vu(Tjsb43GT6f0FO0yLasBcPRdPbGuUSbPnHufH02wiL)pr)xk)zcRIbc1cW24S9hknwjG0Mq66qAaiL)pr)xk)2ePa8BWw9c6puASsaPkaPRdPbGuUSbPnH01H02wiLlBqAtin8qABlK6OU3ENNnG89CVkziTrndpiNab5CXyk0k5wNALChETRAgSghcSRJwZm80(sZKwmEaYdHKMHFwINnAg(l58arEgBesdaPCzZlnrGuxcPCzdsBscsvuZWdYjqqoxmMcTsU1Pwj3RI2vndwJdb21rRz4NL4zJMHlBEPjcK6siLlBqAtsqQBnZWt7lnZC8Pqq(3HvQtTsUxdAx1mwL4DQKtnJBnZWt7lnZMiOvXabEKXkbSnoBndwJdb21rRtTsUDHAx1mynoeyxhTMz4P9LMXHy4SF1eW24S1m8Zs8SrZWFjNhiYZyJqAaiL)pr)xk)2ePa8BWw9c6puASsaPkaPRdPbGuUSbPKGufH0aqk5ddbI5DVBFAX4bipesqAaifl8Id6ttcb5dcFyqQcqQBndpiNab5CXyk0k5wNALCVwAx1mynoeyxhTMz4P9LMXHy4SF1eW24S1m8Zs8SrZWFjNhiYZyJqAaifl8Id6ttcb5dKMiqQcqQIqAaiTbiLlBEPjcK6siLlBqQcKGu3qABlKs(WqGyE372NwmEaYdHeK2OMHhKtGGCUymfALCRtDQz4DGa3Ax1k5w7QMbRXHa76O1m8Zs8SrZSAin0C24qGE5NOdIOIfKgasBas5)t0)LYFMWQyGqTaSnoB)HsJvcivbivriTTfsxnKY)qynv6zh8SPG0gH0aqAdq6QHu(hcRPsFH87j(RdPTTqk)FI(VuENVWUQibohU4puASsaPkaPkcPncPTTq62ILtWHsJvcivbivXWRzgEAFPzSk0ZgbruXsNALuu7QMbRXHa76O1m8Zs8SrZSTy5eCO0yLasBcPnaPUDHHbPUesp1c3)fJ(9KdbiFvUShRXHa7qA4esDRyyqAJqABlK6OU3Er(NeaNlLbt1bB7qF)xkinaKsgtFevSaPmcwKTebPfJNF4PfcH02wi15fcinaKUTy5eCO0yLasvasDhMMz4P9LMjFvUm43GooPSo1kTU2vndwJdb21rRz4NL4zJMPbi9gRdWqyL(P3fERG0MqkRgEiTTfsVX6amewPF6DHxLmK2iKgas5)t0)LYFMWQyGqTaSnoB)HsJvcivbifJGC1ebPjHqAaiL)pr)xkVvHE2iiIkwGugblYwIG0IXZFO0yLasBcPnaPkggKgfKQyyqA4esp1c3)fJERc9SXta6iHflNESghcSdPncPTTqQZleqAaiDBXYj4qPXkbKQaKUE41mdpTV0ml4q(lb43G)64PtTsSQ2vndwJdb21rRz4NL4zJMH)sopqKNXgH0aqAdq6nwhGHWk9tVl8wbPnHu3HbPTTq6nwhGHWk9tVl8QKH0g1mdpTV0m7bjScbI8LiRtTsHx7QMbRXHa76O1m8Zs8SrZCJ1byiSs)07cVvqAtiD9WG02wi9gRdWqyL(P3fEvYAMHN2xAM9qqGf4VoE6uR0QODvZG14qGDD0Ag(zjE2Oz4YgK2KeKQiKgas3wSCcouASsaPnH0vjminaK2aKY)NO)lLxK)jbW5szWuDW2o0ZLNlgfqAtinmiTTfs5)t0)LYlY)Ka4CPmyQoyBh6puASsaPnHu3HbPncPbG0gGuYy6JOIfiLrWISLiiTy88dpTqiK22cP8)j6)s5Tk0ZgbruXcKYiyr2seKwmE(dLgReqAti1DyqABlKgAoBCiqV8t0bruXcsBesBBH0gGuUSbPnjbPkcPbG0TflNGdLgReqQcKG0vjminaK2aKsgtFevSaPmcwZYwIG0IXZp80cHqABlKY)NO)lL3QqpBeerflqkJGfzlrqAX45puASsaPnH0TflNGdLgReqAJqAaiTbiL)pr)xkVi)tcGZLYGP6GTDONlpxmkG0MqAyqABlKY)NO)lLxK)jbW5szWuDW2o0FO0yLasBcPBlwobhknwjG02wi1rDV9I8pjaoxkdMQd22HEvYqAJqAJqABlKUTy5eCO0yLasvasDhEnZWt7lnJZxyxvKaNdx0PwP1G2vndwJdb21rRz4NL4zJMH)vx1sp))RB1Kyh87nwcle6XACiWUMz4P9LMrK)jbW5szWuDW2oeSTitI6uRKlu7QMbRXHa76O1m8Zs8SrZW)NO)lLxK)jbW5szWuDW2o0ZLNlgfqkjivriTTfs3wSCcouASsaPkaPkggK22cPnaP3yDagcR0p9UWFO0yLasBcPUdpK22cPnaPRgs5FiSMk9SdE2uqAaiD1qk)dH1uPVq(9e)1H0gH0aqAdqAdq6nwhGHWk9tVl8wbPnHu()e9FP8I8pjaoxkdMQd22H(Tkbb4qU8CXiinjesBBH0vdP3yDagcR0p9UWJrmrkG0gH0aqAdqk)FI(VuERc9SrqevSaPmcwKTebPfJN)qPXkbK2es5)t0)LYlY)Ka4CPmyQoyBh63QeeGd5YZfJG0KqiTTfsdnNnoeOx(j6GiQybPncPncPbGu()e9FP8BtKcWVbB1lO)qPXkbKQajiDTG0aqkx2G0MKGufH0aqk)FI(Vu(fz7iSkg0Vj(laz1Il7puASsaPkqcsDRiK2OMz4P9LMrK)jbW5szWuDW2ouNALwlTRAgSghcSRJwZWplXZgnd)dH1uPNDWZMcsdaPnaPoQ7TFbhYFja)g8xhpVkziTTfsBas3wSCcouASsaPkaP8)j6)s5xWH8xcWVb)1XZFO0yLasBBHu()e9FP8l4q(lb43G)645puASsaPnHu()e9FP8I8pjaoxkdMQd22H(Tkbb4qU8CXiinjesBesdaP8)j6)s53MifGFd2Qxq)HsJvcivbsq6AbPbGuUSbPnjbPkcPbGu()e9FP8lY2ryvmOFt8xaYQfx2FO0yLasvGeK6wriTrnZWt7lnJi)tcGZLYGP6GTDOo1k5omTRAgSghcSRJwZWplXZgnd)dH1uPVq(9e)1H0aqAhDu3BVZxyxvKaNdxaD0rDV9QKH0aqAdqkzm9ruXcKYiyr2seKwmE(HNwiesBBH0qZzJdb6LFIoiIkwqABlKY)NO)lL3QqpBeerflqkJGfzlrqAX45puASsaPnHu()e9FP8I8pjaoxkdMQd22H(Tkbb4qU8CXiinjesBBHu()e9FP8wf6zJGiQybszeSiBjcslgp)HsJvciTjKUEyqAJAMHN2xAgr(NeaNlLbt1bB7qDQvYTBTRAgSghcSRJwZWplXZgndzm9ruXcKYiyr2seKwmE(HNwiesBBHuNxiG0aq62ILtWHsJvcivbivXW0mdpTV0mwj4NAooeiWfOovQkb6yiJJ6uRKBf1UQzWACiWUoAnd)SepB0mKX0hrflqkJGfzlrqAX45hEAHqiTTfsDEHasdaPBlwobhknwjGufGufdtZm80(sZSCtklYVqDQvY96Ax1mynoeyxhTMHFwINnAgYy6JOIfiLrWISLiiTy88dpTqiK22cPoVqaPbG0TflNGdLgReqQcqQIHPzgEAFPzIjMUn5FcGZ0JrDQvYnRQDvZG14qGDD0AMHN2xAM(HtFBhccHcbsOz4NL4zJMz1qAO5SXHa9ruXc8fqvGG8SInMqABlKY)NO)lL3QqpBeerflqkJGfzlrqAX45puASsaPnHufddsdaPKX0hrflqkJGfzlrqAX45puASsaPkaPkggK22cPHMZghc0l)eDqevS0m1iHAM(HtFBhccHcbsOtTsUdV2vndwJdb21rRzgEAFPzeYt)xIVrqgKFIsAg(zjE2OziJPpIkwGugblYwIG0IXZp80cHqABlK68cbKgas3wSCcouASsaPkaPkggK22cPRgsp1c3)fJERc9SXta6iHflNESghcSRzQrc1mc5P)lX3iidYprjDQvY9QODvZG14qGDD0Ag(zjE2OzwnKgAoBCiqFevSaFbufiipRyJjK22cP8)j6)s5Tk0ZgbruXcKYiyr2seKwmE(dLgReqAtivXWG02win0C24qGE5NOdIOILMz4P9LMrvGalrjHo1k5EnODvZG14qGDD0Ag(zjE2Oz2wSCcouASsaPnH01kmiTTfsjJPpIkwGugblYwIG0IXZp80cHqABlKgAoBCiqV8t0bruXcsBBHuNxiG0aq62ILtWHsJvcivbi19QOzgEAFPzYxLld(nG9CsJo1k52fQDvZG14qGDD0Ag(zjE2Oz4)t0)LYBvONncIOIfiLrWISLiiTy88hknwjG0Mq66HbPTTqAO5SXHa9YprherfliTTfsDEHasdaPBlwobhknwjGufGufdtZm80(sZ4q8FhSvVG6uRK71s7QMbRXHa76O1m8Zs8SrZW)NO)lL3QqpBeerflqkJGfzlrqAX45puASsaPnH01ddsBBH0qZzJdb6LFIoiIkwqABlK68cbKgas3wSCcouASsaPkaPUdVMz4P9LMXbpbESTkwNALummTRAMHN2xAgclwofawHApwcRuZG14qGDD06uRKIU1UQzWACiWUoAnd)SepB0m8)j6)s5Tk0ZgbruXcKYiyr2seKwmE(dLgReqAtiD9WG02win0C24qGE5NOdIOIfK22cPoVqaPbG0TflNGdLgReqQcqQ7W0mdpTV0mB7qhI)76uRKIkQDvZG14qGDD0Ag(zjE2Oz4)t0)LYBvONncIOIfiLrWISLiiTy88hknwjG0Mq66HbPTTqAO5SXHa9YprherfliTTfsDEHasdaPBlwobhknwjGufGufdtZm80(sZmfhf5nea(qqOtTskUU2vndwJdb21rRz4NL4zJMXrDV9I8pjaoxkdMQd22H((VuAMHN2xAgNjg8BqEgNTqNALuKv1UQzWACiWUoAnd)SepB0mIxLWXQUNSQivjqaEQKt7lpwJdb2H0aqQJ6E7f5FsaCUugmvhSTd99FPG0aqAhDu3BVZxyxvKaNdxaD0rDV99FP0mdpTV0mBcuiZVzN6uNAMoUhvIu7Qwj3Ax1mdpTV0mcY4Ca5P6arEgBuZG14qGDD06uRKIAx1mynoeyxhTM5jRzeyQzgEAFPzcnNnoeOMj0qOIAg()e9FP8wf6zJGiQybszeSiBjcslgp)HsJvciTjKUTy5eCO0yLasBBH0TflNGdLgReqQlHu()e9FP8wf6zJGiQybszeSiBjcslgp)HsJvcivbi1TIHbPbG0gG0gG0CiWk9c8WYYGESghcSdPbG0TflNGdLgReqAtiL)pr)xkVapSSmO)qPXkbKgas5)t0)LYlWdlld6puASsaPnHu3HbPncPTTqAdqk)FI(VuEr(NeaNlLbt1bB7q)wLGaCixEUyeKMecPkaPBlwobhknwjG0aqk)FI(VuEr(NeaNlLbt1bB7q)wLGaCixEUyeKMecPnHu3HhsBesBBH0gGu()e9FP8I8pjaoxkdMQd22HEU8CXOasjbPHbPbGu()e9FP8I8pjaoxkdMQd22H(dLgReqQcq62ILtWHsJvciTriTrntO5a1iHAg5NOdIOILo1kTU2vndwJdb21rRz4NL4zJMPbi1rDV9c8WYYGEvYqABlK6OU3Er(NeaNlLbt1bB7qVkziTrinaKsgtFevSaPmcwKTebPfJNF4PfcH02wi15fcinaKUTy5eCO0yLasvGeKUkHPzgEAFPzi)P9Lo1kXQAx1mynoeyxhTMHFwINnAgh192lWdlld6vjRzgEAFPz4dbby4P9fGWePMHWejOgjuZiWdlldQtTsHx7QMbRXHa76O1m8Zs8SrZ4OU3(fCi)La8BWFD88QK1mdpTV0m8HGam80(cqyIuZqyIeuJeQzwWH8xcWVb)1XtNALwfTRAgSghcSRJwZWplXZgntAsiKQaKYQqAaiLlBqQcqA4H0aq6QHuYy6JOIfiLrWISLiiTy88dpTqOMz4P9LMHpeeGHN2xactKAgctKGAKqnZtgl80PwP1G2vndwJdb21rRzgEAFPz2Mib)gKYiyr2seKwmEAg(zjE2Oz4YMxAIaPUes5YgK2KeKUoKgasBasXcV4G(0Kqq(aPjcKQaK6gsBBHuSWloOpnjeKpqAIaPkaPSkKgas5)t0)LYVnrka)gSvVG(dLgReqQcqQBF4H02wiL)pr)xk)coK)sa(n4VoE(dLgReqQcqQIqAJqAaiD1qAhDu3BVZxyxvKaNdxaD0rDV9QK1m8GCceKZfJPqRKBDQvYfQDvZG14qGDD0Ag(zjE2Oz4YMxAIaPUes5YgK2KeK6gsdaPnaPyHxCqFAsiiFG0ebsvasDdPTTqk)FI(VuEbEyzzq)HsJvcivbivriTTfsXcV4G(0Kqq(aPjcKQaKYQqAaiL)pr)xk)2ePa8BWw9c6puASsaPkaPU9HhsBBHu()e9FP8l4q(lb43G)645puASsaPkaPkcPncPbG0vdPoQ7T35lSRksGZHlEvYAMHN2xAgmczKaipNKo1kTwAx1mynoeyxhTMz4P9LMjTy8aKhcjnd)SepB0m8xY5bI8m2iKgas5YMxAIaPUes5YgK2KeKQiKgasBasXcV4G(0Kqq(aPjcKQaK6gsBBHu()e9FP8c8WYYG(dLgReqQcqQIqABlKIfEXb9PjHG8bsteivbiLvH0aqk)FI(Vu(Tjsb43GT6f0FO0yLasvasD7dpK22cP8)j6)s5xWH8xcWVb)1XZFO0yLasvasvesBesdaPRgs7OJ6E7D(c7QIe4C4cOJoQ7TxLSMHhKtGGCUymfALCRtTsUdt7QMbRXHa76O1m8Zs8SrZSAinhcSsVapSSmOhRXHa7AMHN2xAg(qqagEAFbimrQzimrcQrc1m8oqGBDQvYTBTRAgSghcSRJwZWplXZgntoeyLEbEyzzqpwJdb21mdpTV0m8HGam80(cqyIuZqyIeuJeQz4DGapSSmOo1k5wrTRAgSghcSRJwZWplXZgnZWtlecWcLmuaPkaPRRzgEAFPz4dbby4P9fGWePMHWejOgjuZisDQvY96Ax1mynoeyxhTMHFwINnAMHNwieGfkzOasBscsxxZm80(sZWhccWWt7laHjsndHjsqnsOMzEuN6uZq(q(l5mP2vTsU1UQzgEAFPzC(mjWoytmbX(IvXG8JyLMbRXHa76O1Pwjf1UQzWACiWUoAnZtwZiWuZm80(sZeAoBCiqntOHqf1mOlq1itg7ERe8tnhhce4cuNkvLaDmKXriTTfsrxGQrMm29Xet3M8pbWz6XiK22cPOlq1itg7(LBszr(fcPTTqk6cunYKXU)dHhxEUySdMYKgGZKjEbH02wifDbQgzYy3lKN(VeFJGmi)eL0mHMduJeQzIOIf4lGQab5zfBm1PwP11UQzWACiWUoAnd)SepB0mRgsZHaR0lWdlld6XACiWoK22cPRgsZHaR0Vnrc(niLrWISLiiTy88ynoeyxZm80(sZWLnGJ6jsDQvIv1UQzWACiWUoAnd)SepB0mRgsZHaR0JfEXw4UvXaKWIGNhRXHa7AMHN2xAgUSbwMqOo1PMzEu7Qwj3Ax1mdpTV0mlY2ryvmOFt8xaYQfxwZG14qGDD06uRKIAx1mynoeyxhTMHFwINnAgUS5LMiqQlHuUSbPnjbPkcPbGuSWloOpnjeKpqAIaPnHufH02wiLlBEPjcK6siLlBqAtsqkRQzgEAFPzWcVylC3QyasyrStNALwx7QMbRXHa76O1m8Zs8SrZWFjNhiYZyJqAaiTbi1rDV99P4i43aUSXkmVkziTTfs7OJ6E7D(c7QIe4C4cOJoQ7TxLmK2OMz4P9LMrq2QYQya)McbSnoBDQvIv1UQzWACiWUoAnd)SepB0myHxCqFAsiiFG0ebsBcPyeKRMiinjesBBHuUS5LMiqQlHuUSbPkqcsDRzgEAFPz2MifGFd2QxqDQvk8Ax1mynoeyxhTMz4P9LM5mHvXaHAbyBC2Ag(zjE2OzAasZHaR0ViBhHvXG(nXFbiRwCzpwJdb2H0aqk)FI(Vu(ZewfdeQfGTXz77Q3K2xqAtiL)pr)xk)ISDewfd63e)fGSAXL9hknwjG0OGuwfsBesdaPnaP8)j6)s53MifGFd2Qxq)HsJvciTjKUoK22cPCzdsBscsdpK2OMHhKtGGCUymfALCRtTsRI2vndwJdb21rRz4NL4zJMXrDV9NQq2QyaRy6iyXQUV)lLMz4P9LM5ufYwfdyfthblw11PwP1G2vndwJdb21rRz4NL4zJMHlBEPjcK6siLlBqAtsqQBnZWt7lndgHmsaKNtsNALCHAx1mynoeyxhTMz4P9LMzBIe8BqkJGfzlrqAX4Pz4NL4zJMHlBEPjcK6siLlBqAtsq66AgEqobcY5IXuOvYTo1kTwAx1mynoeyxhTMHFwINnAgUS5LMiqQlHuUSbPnjbPkQzgEAFPz4YgWr9ePo1k5omTRAgSghcSRJwZWplXZgnJJ6E7tzeGsKX7pbGpKhUL)5f5WzdPnHu3RfKgasXcV4G(0Kqq(aPjcK2esXiixnrqAsiK6si1nKgas5)t0)LYVnrka)gSvVG(dLgReqAtifJGC1ebPjHAMHN2xAg(nC2ewfdyfthbewSCwwfRtTsUDRDvZG14qGDD0AMHN2xAM0IXdqEiK0m8Zs8SrZWLnV0ebsDjKYLniTjjivrinaK2aKUAinhcSsVSLa(l58ESghcSdPTTqk)LCEGipJncPnQz4b5eiiNlgtHwj36uRKBf1UQzWACiWUoAnd)SepB0mCzZlnrGuxcPCzdsBscsDRzgEAFPzMJpfcY)oSsDQvY96Ax1mynoeyxhTMHFwINnAg(l58arEgBesdaPnaP8)j6)s5D(c7QIe4C4I)qPXkbK2esvesBBH0vdP8pewtL(c53t8xhsBesdaPnaPCzdsBscsdpK22cP8)j6)s53MifGFd2Qxq)HsJvciTjKUkqABlKY)NO)lLFBIua(nyREb9hknwjG0Mq66qAaiLlBqAtsq66qAaifl8Id6ttcb5dcFyqQcqQBiTTfsXcV4G(0Kqq(aPjcKQajiTbiDDinkiDDinCcP8)j6)s53MifGFd2Qxq)HsJvcivbin8qAJqABlK6OU3Er(NeaNlLbt1bB7qVkziTrnZWt7lnJGSvLvXa(nfcyBC26uRKBwv7QMbRXHa76O1m8Zs8SrZWFjNhiYZyJAMHN2xAgUSbwMqOo1k5o8Ax1mynoeyxhTMz4P9LMzte0QyGapYyLa2gNTMHFwINnAgh19278SbKVN77)sPzSkX7ujNAg36uRK7vr7QMbRXHa76O1mdpTV0moedN9RMa2gNTMHFwINnAg(l58arEgBesdaPnaPoQ7T35zdiFp3RsgsBBH0CiWk9Ywc4VKZ7XACiWoKgasjFyiqmV7D7tlgpa5HqcsdaPCzdsjbPkcPbGu()e9FP8BtKcWVbB1lO)qPXkbKQaKUoK22cPCzZlnrGuxcPCzdsvGeK6gsdaPKpmeiM39U9cYwvwfd43uiGTXzdPbGuSWloOpnjeKpqAIaPkaPRdPnQz4b5eiiNlgtHwj36uN6uZecpH9Lwjfdtr3HTkk6c1mlZvwfl0mR5WXWnLcxuAnAvHui1vzesnjY)Lq6(piL1l4q(lb43G)64XAi9qxGQDyhsfVecPJA(stIDiLlpvmk8qwwBRqivXvfszLFfcVe7qkRZHaR07ISgsZhszDoeyLEx0J14qGDwdPtcPHRRXRnK2G7in6HSS2wHq66RkKYk)keEj2HuwNdbwP3fznKMpKY6CiWk9UOhRXHa7SgsNesdxxJxBiTb3rA0dzzTTcHu3S6QcPHBO0hc7qQKvRQlcPCzKZgsBO(esNqJrmoeiKAfKIsQetAF1iK2G7in6HSS2wHqQIHTQqkR8Rq4LyhszDoeyLExK1qA(qkRZHaR07IESghcSZAiTb3rA0dzbYYAoCmCtPWfLwJwvifsDvgHutI8FjKU)dszTapSSmiRH0dDbQ2HDiv8siKoQ5lnj2HuU8uXOWdzzTTcHu3HTQqkR8Rq4LyhszDoeyLExK1qA(qkRZHaR07IESghcSZAiDsinCDnETH0gChPrpKfilR5WXWnLcxuAnAvHui1vzesnjY)Lq6(piL18oqGhwwgK1q6HUav7WoKkEjesh18LMe7qkxEQyu4HSS2wHq6ATQqkR8Rq4Lyhsz9Pw4(Vy07ISgsZhsz9Pw4(Vy07IESghcSZAiTb3rA0dzzTTcHu3HFvHuw5xHWlXoKY6tTW9FXO3fznKMpKY6tTW9FXO3f9ynoeyN1q6KqA46A8AdPn4osJEilRTviKQOIRkKYk)keEj2HuwlEvchR6ExK1qA(qkRfVkHJvDVl6XACiWoRH0gChPrpKfilR5WXWnLcxuAnAvHui1vzesnjY)Lq6(piL1IK1q6HUav7WoKkEjesh18LMe7qkxEQyu4HSS2wHqkRUQqkR8Rq4LyhszDoeyLExK1qA(qkRZHaR07IESghcSZAiTb3rA0dzzTTcH0vzvHuw5xHWlXoKY6CiWk9UiRH08HuwNdbwP3f9ynoeyN1qAdUJ0OhYYABfcPUz1vfszLFfcVe7qkRZHaR07ISgsZhszDoeyLEx0J14qGDwdPn4osJEilqwwZHJHBkfUO0A0QcPqQRYiKAsK)lH09FqkR5DGa3Sgsp0fOAh2HuXlHq6OMV0Kyhs5YtfJcpKL12kesvCvHuw5xHWlXoKY6tTW9FXO3fznKMpKY6tTW9FXO3f9ynoeyN1qAdUJ0OhYYABfcPRVQqkR8Rq4Lyhsz9Pw4(Vy07ISgsZhsz9Pw4(Vy07IESghcSZAiTb3rA0dzzTTcHu3HFvHuw5xHWlXoKY6tTW9FXO3fznKMpKY6tTW9FXO3f9ynoeyN1q6KqA46A8AdPn4osJEilRTviKQiRUQqkR8Rq4LyhszT4vjCSQ7DrwdP5dPSw8Qeow19UOhRXHa7SgsBWDKg9qwGSSMdhd3ukCrP1OvfsHuxLri1Ki)xcP7)Guw3X9OsKSgsp0fOAh2HuXlHq6OMV0Kyhs5YtfJcpKL12kesvCvHuw5xHWlXoKY6CiWk9UiRH08HuwNdbwP3f9ynoeyN1qAdUJ0OhYYABfcPUdBvHuw5xHWlXoKY6CiWk9UiRH08HuwNdbwP3f9ynoeyN1q6KqA46A8AdPn4osJEilRTviK629QcPSYVcHxIDiL15qGv6DrwdP5dPSohcSsVl6XACiWoRH0jH0W1141gsBWDKg9qwGSSMdhd3ukCrP1OvfsHuxLri1Ki)xcP7)GuwppYAi9qxGQDyhsfVecPJA(stIDiLlpvmk8qwwBRqin8RkKYk)keEj2HuwNdbwP3fznKMpKY6CiWk9UOhRXHa7SgsBWDKg9qwwBRqi1T7vfszLFfcVe7qkRZHaR07ISgsZhszDoeyLEx0J14qGDwdPn4osJEilRTviK6EvwviLv(vi8sSdPSohcSsVlYAinFiL15qGv6DrpwJdb2znK2G7in6HSazjCrI8Fj2H01cshEAFbPeMifEilAMrnL)tZWysSsnd573gbQzwtRjiDnBvFziyJhKgo8xSHSSMwtqklQebH0WRmKQyyk6gYcKL10AcsDDbh2qA4aMifq6VH0WbuVGqQvjENk5esj(yJ7HSSMwtqQRl4WgsziBvzvmKYkVPqinCqJZgsj(yJ7HSSMwtqA4yVdPoVqSTy5es5YiNTasZhsLMkiKYkdhcsXkpdfEilqwwtRjinCncYvtSdPo4(pes5VKZKqQdgBLWdPHJCosofqA9LlLNtARsaPdpTVeq6xeb9qwgEAFj8KpK)sotgfPvC(mjWoytmbX(IvXG8JyfKLHN2xcp5d5VKZKrrALqZzJdbQCnsiPiQyb(cOkqqEwXgtLFYKeyQCOHqfjHUavJmzS7TsWp1CCiqGlqDQuvc0XqghBBrxGQrMm29Xet3M8pbWz6XyBl6cunYKXUF5MuwKFHTTOlq1itg7(peEC55IXoyktAaotM4fSTfDbQgzYy3lKN(VeFJGmi)eLGSm80(s4jFi)LCMmksRWLnGJ6jsLTnPvNdbwPxGhwwg0J14qG922vNdbwPFBIe8BqkJGfzlrqAX45XACiWoKLHN2xcp5d5VKZKrrAfUSbwMqOY2M0QZHaR0JfEXw4UvXaKWIGNhRXHa7qwGSSMwtqA4AeKRMyhsXq4festtcH0ugH0HN)bPMasNqJrmoeOhYYWt7lbjbzCoG8uDGipJnczz4P9LiksReAoBCiqLRrcjj)eDqevSu(jtsGPYHgcvKe)FI(VuERc9SrqevSaPmcwKTebPfJN)qPXkrZTflNGdLgReTTBlwobhknwjCj)FI(VuERc9SrqevSaPmcwKTebPfJN)qPXkHcUvmSan0qoeyLEbEyzzWaBlwobhknwjAY)NO)lLxGhwwg0FO0yLia)FI(VuEbEyzzq)HsJvIMUdRX22g4)t0)LYlY)Ka4CPmyQoyBh63QeeGd5YZfJG0Kqf2wSCcouASseG)pr)xkVi)tcGZLYGP6GTDOFRsqaoKlpxmcstcB6o8n222a)FI(VuEr(NeaNlLbt1bB7qpxEUyuqkSa8)j6)s5f5FsaCUugmvhSTd9hknwjuyBXYj4qPXkrJnczz4P9LiksRq(t7lLTnPgCu3BVapSSmOxLCBRJ6E7f5FsaCUugmvhSTd9QKBmazm9ruXcKYiyr2seKwmE(HNwiST15fIaBlwobhknwjuG0QegKLHN2xIOiTcFiiadpTVaeMivUgjKKapSSmOY2MKJ6E7f4HLLb9QKHSm80(sefPv4dbby4P9fGWePY1iHKwWH8xcWVb)1XtzBtYrDV9l4q(lb43G)645vjdzz4P9LiksRWhccWWt7laHjsLRrcj9KXcpLTnP0Kqfy1aCztHWhy1KX0hrflqkJGfzlrqAX45hEAHqildpTVerrALTjsWVbPmcwKTebPfJNY8GCceKZfJPGKBLTnjUS5LMiUKlBnjTEGgWcV4G(0Kqq(aPjIcUBBXcV4G(0Kqq(aPjIcSAa()e9FP8BtKcWVbB1lO)qPXkHcU9HVTL)pr)xk)coK)sa(n4VoE(dLgRekOyJbwDhDu3BVZxyxvKaNdxaD0rDV9QKHSm80(sefPvWiKrcG8CskBBsCzZlnrCjx2AsYDGgWcV4G(0Kqq(aPjIcUBB5)t0)LYlWdlld6puASsOGITTyHxCqFAsiiFG0erbwna)FI(Vu(Tjsb43GT6f0FO0yLqb3(W32Y)NO)lLFbhYFja)g8xhp)HsJvcfuSXaR2rDV9oFHDvrcCoCXRsgYYWt7lruKwjTy8aKhcjL5b5eiiNlgtbj3kBBs8xY5bI8m2yaUS5LMiUKlBnjPyGgWcV4G(0Kqq(aPjIcUBB5)t0)LYlWdlld6puASsOGITTyHxCqFAsiiFG0erbwna)FI(Vu(Tjsb43GT6f0FO0yLqb3(W32Y)NO)lLFbhYFja)g8xhp)HsJvcfuSXaRUJoQ7T35lSRksGZHlGo6OU3EvYqwgEAFjII0k8HGam80(cqyIu5AKqs8oqGBLTnPvNdbwPxGhwwgeYYWt7lruKwHpeeGHN2xactKkxJesI3bc8WYYGkBBs5qGv6f4HLLbHSm80(sefPv4dbby4P9fGWePY1iHKePY2M0WtlecWcLmuOW6qwgEAFjII0k8HGam80(cqyIu5AKqsZJkBBsdpTqialuYqrtsRdzbYYWt7lHFEK0ISDewfd63e)fGSAXLHSm80(s4NhJI0kyHxSfUBvmajSi2PSTjXLnV0eXLCzRjjfdGfEXb9PjHG8bstKMk22YLnV0eXLCzRjjwfYYWt7lHFEmksRiiBvzvmGFtHa2gNTY2Me)LCEGipJngObh1923NIJGFd4YgRW8QKBB7OJ6E7D(c7QIe4C4cOJoQ7TxLCJqwgEAFj8ZJrrALTjsb43GT6fuzBtcl8Id6ttcb5dKMinXiixnrqAsyBlx28stexYLnfi5gYYWt7lHFEmksRCMWQyGqTaSnoBL5b5eiiNlgtbj3kBBsnKdbwPFr2ocRIb9BI)cqwT4Yb4)t0)LYFMWQyGqTaSnoBFx9M0(Qj)FI(Vu(fz7iSkg0Vj(laz1Il7puASsefR2yGg4)t0)LYVnrka)gSvVG(dLgRenxVTLlBnjf(gHSm80(s4NhJI0kNQq2QyaRy6iyXQUY2MKJ6E7pvHSvXawX0rWIvDF)xkildpTVe(5XOiTcgHmsaKNtszBtIlBEPjIl5YwtsUHSm80(s4NhJI0kBtKGFdszeSiBjcslgpL5b5eiiNlgtbj3kBBsCzZlnrCjx2AsADildpTVe(5XOiTcx2aoQNiv22K4YMxAI4sUS1KKIqwgEAFj8ZJrrAf(nC2ewfdyfthbewSCwwfRSTj5OU3(ugbOez8(ta4d5HB5FEroC2nDVwbWcV4G(0Kqq(aPjstmcYvteKMe6s3b4)t0)LYVnrka)gSvVG(dLgRenXiixnrqAsiKLHN2xc)8yuKwjTy8aKhcjL5b5eiiNlgtbj3kBBsCzZlnrCjx2AssXanS6CiWk9Ywc4VKZ32YFjNhiYZyJnczz4P9LWppgfPvMJpfcY)oSsLTnjUS5LMiUKlBnj5gYYWt7lHFEmksRiiBvzvmGFtHa2gNTY2Me)LCEGipJngOb()e9FP8oFHDvrcCoCXFO0yLOPITTRM)HWAQ0xi)EI)6ngObUS1Ku4BB5)t0)LYVnrka)gSvVG(dLgRenxL2w()e9FP8BtKcWVbB1lO)qPXkrZ1dWLTMKwpaw4fh0NMecYhe(WuWDBlw4fh0NMecYhinruGudRh16Ht()e9FP8BtKcWVbB1lO)qPXkHcHVX2wh192lY)Ka4CPmyQoyBh6vj3iKLHN2xc)8yuKwHlBGLjeQSTjXFjNhiYZyJqwgEAFj8ZJrrALnrqRIbc8iJvcyBC2kBBsoQ7T35zdiFp33)LszRs8ovYjj3qwgEAFj8ZJrrAfhIHZ(vtaBJZwzEqobcY5IXuqYTY2Me)LCEGipJngObh19278SbKVN7vj32MdbwPx2sa)LC(aKpmeiM39U9PfJhG8qifGlBKuma)FI(Vu(Tjsb43GT6f0FO0yLqH1BB5YMxAI4sUSPaj3biFyiqmV7D7fKTQSkgWVPqaBJZoaw4fh0NMecYhinruy9gHSazz4P9LWZ7abUjzvONncIOIfiLrWISLiiTy8u22KwDO5SXHa9YprherfRanW)NO)lL)mHvXaHAbyBC2(dLgRekOyB7Q5FiSMk9SdE2ungOHvZ)qynv6lKFpXF92w()e9FP8oFHDvrcCoCXFO0yLqbfBSTDBXYj4qPXkHckgEildpTVeEEhiWDuKwjFvUm43GooPSY2M02ILtWHsJvIMn42fgMlp1c3)fJ(9KdbiFvUC40TIH1yBRJ6E7f5FsaCUugmvhSTd99FPcqgtFevSaPmcwKTebPfJNF4PfcBBDEHiW2ILtWHsJvcfChgKLHN2xcpVde4oksRSGd5VeGFd(RJNY2Mud3yDagcR0p9UWBvtwn8TT3yDagcR0p9UWRsUXa8)j6)s5ptyvmqOwa2gNT)qPXkHcyeKRMiinjma)FI(VuERc9SrqevSaPmcwKTebPfJN)qPXkrZgumSOumSW5Pw4(Vy0BvONnEcqhjSy5SX2wNxicSTy5eCO0yLqH1dpKLHN2xcpVde4oksRShKWkeiYxISY2Me)LCEGipJngOHBSoadHv6NEx4TQP7WABVX6amewPF6DHxLCJqwgEAFj88oqG7OiTYEiiWc8xhpLTnPBSoadHv6NEx4TQ56H12EJ1byiSs)07cVkzildpTVeEEhiWDuKwX5lSRksGZHlkBBsCzRjjfdSTy5eCO0yLO5QewGg4)t0)LYlY)Ka4CPmyQoyBh65YZfJIMH12Y)NO)lLxK)jbW5szWuDW2o0FO0yLOP7WAmqdKX0hrflqkJGfzlrqAX45hEAHW2w()e9FP8wf6zJGiQybszeSiBjcslgp)HsJvIMUdRTn0C24qGE5NOdIOIvJTTnWLTMKumW2ILtWHsJvcfiTkHfObYy6JOIfiLrWAw2seKwmE(HNwiSTL)pr)xkVvHE2iiIkwGugblYwIG0IXZFO0yLO52ILtWHsJvIgd0a)FI(VuEr(NeaNlLbt1bB7qpxEUyu0mS2w()e9FP8I8pjaoxkdMQd22H(dLgRen3wSCcouASs026OU3Er(NeaNlLbt1bB7qVk5gBSTDBXYj4qPXkHcUdpKLHN2xcpVde4oksRiY)Ka4CPmyQoyBhc2wKjrLTnj(xDvl98)VUvtIDWV3yjSqOhRXHa7qwgEAFj88oqG7OiTIi)tcGZLYGP6GTDOY2Me)FI(VuEr(NeaNlLbt1bB7qpxEUyuqsX22TflNGdLgRekOyyTTnCJ1byiSs)07c)HsJvIMUdFBBdRM)HWAQ0Zo4ztfy18pewtL(c53t8xVXan0WnwhGHWk9tVl8w1K)pr)xkVi)tcGZLYGP6GTDOFRsqaoKlpxmcstcBBx9nwhGHWk9tVl8yetKIgd0a)FI(VuERc9SrqevSaPmcwKTebPfJN)qPXkrt()e9FP8I8pjaoxkdMQd22H(Tkbb4qU8CXiinjSTn0C24qGE5NOdIOIvJngG)pr)xk)2ePa8BWw9c6puASsOaP1kax2AssXa8)j6)s5xKTJWQyq)M4VaKvlUS)qPXkHcKCRyJqwgEAFj88oqG7OiTIi)tcGZLYGP6GTDOY2Me)dH1uPNDWZMkqdoQ7TFbhYFja)g8xhpVk522g2wSCcouASsOa)FI(Vu(fCi)La8BWFD88hknwjAB5)t0)LYVGd5VeGFd(RJN)qPXkrt()e9FP8I8pjaoxkdMQd22H(Tkbb4qU8CXiinjSXa8)j6)s53MifGFd2Qxq)HsJvcfiTwb4YwtskgG)pr)xk)ISDewfd63e)fGSAXL9hknwjuGKBfBeYYWt7lHN3bcChfPve5FsaCUugmvhSTdv22K4FiSMk9fYVN4VEGo6OU3ENVWUQibohUa6OJ6E7vjhObYy6JOIfiLrWISLiiTy88dpTqyBBO5SXHa9YprherfR2w()e9FP8wf6zJGiQybszeSiBjcslgp)HsJvIM8)j6)s5f5FsaCUugmvhSTd9BvccWHC55IrqAsyBl)FI(VuERc9SrqevSaPmcwKTebPfJN)qPXkrZ1dRrildpTVeEEhiWDuKwXkb)uZXHabUa1PsvjqhdzCuzBtImM(iQybszeSiBjcslgp)Wtle2268crGTflNGdLgRekOyyqwgEAFj88oqG7OiTYYnPSi)cv22KiJPpIkwGugblYwIG0IXZp80cHTToVqeyBXYj4qPXkHckggKLHN2xcpVde4oksRetmDBY)eaNPhJkBBsKX0hrflqkJGfzlrqAX45hEAHW2wNxicSTy5eCO0yLqbfddYYWt7lHN3bcChfPvufiWsus5AKqs9dN(2oeecfcKqzBtA1HMZghc0hrflWxavbcYZk2y22Y)NO)lL3QqpBeerflqkJGfzlrqAX45puASs0uXWcqgtFevSaPmcwKTebPfJN)qPXkHckgwBBO5SXHa9YprherflildpTVeEEhiWDuKwrvGalrjLRrcjjKN(VeFJGmi)eLu22KiJPpIkwGugblYwIG0IXZp80cHTToVqeyBXYj4qPXkHckgwB7Qp1c3)fJERc9SXta6iHflNqwgEAFj88oqG7OiTIQabwIscLTnPvhAoBCiqFevSaFbufiipRyJzBl)FI(VuERc9SrqevSaPmcwKTebPfJN)qPXkrtfdRTn0C24qGE5NOdIOIfKLHN2xcpVde4oksRKVkxg8Ba75KgLTnPTflNGdLgRenxRWABjJPpIkwGugblYwIG0IXZp80cHTTHMZghc0l)eDqevSABDEHiW2ILtWHsJvcfCVkqwgEAFj88oqG7OiTIdX)DWw9cQSTjX)NO)lL3QqpBeerflqkJGfzlrqAX45puASs0C9WABdnNnoeOx(j6GiQy1268crGTflNGdLgRekOyyqwgEAFj88oqG7OiTIdEc8yBvSY2Me)FI(VuERc9SrqevSaPmcwKTebPfJN)qPXkrZ1dRTn0C24qGE5NOdIOIvBRZleb2wSCcouASsOG7Wdzz4P9LWZ7abUJI0kewSCkaSc1ESewjKLHN2xcpVde4oksRSTdDi(VRSTjX)NO)lL3QqpBeerflqkJGfzlrqAX45puASs0C9WABdnNnoeOx(j6GiQy1268crGTflNGdLgRek4omildpTVeEEhiWDuKwzkokYBia8HGqzBtI)pr)xkVvHE2iiIkwGugblYwIG0IXZFO0yLO56H12gAoBCiqV8t0bruXQT15fIaBlwobhknwjuqXWGSm80(s45DGa3rrAfNjg8BqEgNTqzBtYrDV9I8pjaoxkdMQd22H((VuqwgEAFj88oqG7OiTYMafY8B2PY2MK4vjCSQ7jRksvceGNk50(kGJ6E7f5FsaCUugmvhSTd99FPc0rh19278f2vfjW5WfqhDu3BF)xkilqwgEAFj88oqGhwwgKuO5SXHavUgjKKapSSmiWr9ePYpzscmvo0qOIK4)t0)LYlWdlld6puASsOG72wYy6JOIfiLrWISLiiTy88dpTqya()e9FP8c8WYYG(dLgRenxpS2wNxicSTy5eCO0yLqbfddYYWt7lHN3bc8WYYGrrAfRc9SrqevSaPmcwKTebPfJNY2M0QdnNnoeOx(j6GiQy1268crGTflNGdLgRekOy4HSm80(s45DGapSSmyuKwXH4)oyREbv22KcnNnoeOxGhwwge4OEIeYYWt7lHN3bc8WYYGrrAfh8e4X2QyLTnPqZzJdb6f4HLLbboQNiHSm80(s45DGapSSmyuKwHWILtbGvO2JLWkHSm80(s45DGapSSmyuKwzBh6q8FxzBtk0C24qGEbEyzzqGJ6jsildpTVeEEhiWdlldgfPvMIJI8gcaFiiu22KcnNnoeOxGhwwge4OEIeYYWt7lHN3bc8WYYGrrAfNjg8BqEgNTqzBtk0C24qGEbEyzzqGJ6jsildpTVeEEhiWdlldgfPvYxLld(nOJtkRSTjTTy5eCO0yLOzdUDHH5YtTW9FXOFp5qaYxLlhoDRyyn22sgtFevSaPmcwKTebPfJNF4PfcBBDEHiW2ILtWHsJvcfChgKLHN2xcpVde4HLLbJI0k5RYLb)gWEoPrzBtABXYj4qPXkrZ1kS2wYy6JOIfiLrWISLiiTy88dpTqyBRZleb2wSCcouASsOG7WGSm80(s45DGapSSmyuKwzbhYFja)g8xhpLTnj()e9FP8NjSkgiulaBJZ2FO0yLqbmcYvteKMeczz4P9LWZ7abEyzzWOiTIvc(PMJdbcCbQtLQsGogY4OY2MuO5SXHa9c8WYYGah1tKqwgEAFj88oqGhwwgmksRSCtklYVqLTnPqZzJdb6f4HLLbboQNiHSm80(s45DGapSSmyuKwjMy62K)jaotpgv22KcnNnoeOxGhwwge4OEIeYYWt7lHN3bc8WYYGrrAfvbcSeLuUgjKKqE6)s8ncYG8tuszBtImM(iQybszeSiBjcslgp)Wtle2268crGTflNGdLgRekOyyTTR(ulC)xm6Tk0ZgpbOJewSCczz4P9LWZ7abEyzzWOiTIQabwIscLTnPvhAoBCiqFevSaFbufiipRyJzBl)FI(VuERc9SrqevSaPmcwKTebPfJN)qPXkrtfdRTn0C24qGE5NOdIOIfKLHN2xcpVde4HLLbJI0k7bjScbI8Lidzz4P9LWZ7abEyzzWOiTYEiiWc8xhpildpTVeEEhiWdlldgfPvC(c7QIe4C4IY2MKZleb2wSCcouASsOG7W322ax2AssXanSTy5eCO0yLO5QewGgAG)pr)xkVapSSmO)qPXkrt3H126OU3EbEyzzqVk52w()e9FP8c8WYYGEvYngObYy6JOIfiLrWISLiiTy88dpTqyBl)FI(VuERc9SrqevSaPmcwKTebPfJN)qPXkrt3H12gAoBCiqV8t0bruXQXgBSTTHTflNGdLgRekqAvclqdKX0hrflqkJG1SSLiiTy88dpTqyBl)FI(VuERc9SrqevSaPmcwKTebPfJN)qPXkrZTflNGdLgRen2yJqwgEAFj88oqGhwwgmksRiWdlldQSTjX)NO)lL)mHvXaHAbyBC2(dLgRekOyBRZleb2wSCcouASsOG7Wdzz4P9LWZ7abEyzzWOiTIZed(nipJZwazz4P9LWZ7abEyzzWOiTYMafY8B2PY2MK4vjCSQ7jRksvceGNk50(kGJ6E7f4HLLb99FPc0rh19278f2vfjW5WfqhDu3BF)xkilqwgEAFj8pzSWJ02ej43GugblYwIG0IXtzEqobcY5UymfKCRSTjXLnV0eXLCzRjP1HSm80(s4FYyHxuKwbJqgjaYZjPSTjLdbwPNlBah1tKESghcShGlBEPjIl5YwtsRdzz4P9LW)KXcVOiTsAX4bipeskZdYjqqoxmMcsUv22K4VKZde5zSXaCzZlnrCjx2AssrildpTVe(Nmw4ffPv4YgyzcHkBBsCzZlnrCjx2iPiKLHN2xc)tgl8II0kyeYibqEojildpTVe(Nmw4ffPvslgpa5HqszEqobcY5IXuqYTY2Mex28stexYLTMKueYcKLHN2xcVapSSmiPTjsb43GT6fuzBtYrDV9c8WYYG(dLgRek4gYYWt7lHxGhwwgmksRiiBvzvmGFtHa2gNTY2Me)LCEGipJngOHHNwieGfkzOOjP1BBhEAHqawOKHIMUdSA()e9FP8NjSkgiulaBJZ2RsUrildpTVeEbEyzzWOiTYzcRIbc1cW24SvMhKtGGCUymfKCRSTjXFjNhiYZyJqwgEAFj8c8WYYGrrALTjsb43GT6fuzBtA4PfcbyHsgkAsADildpTVeEbEyzzWOiTIGSvLvXa(nfcyBC2kBBs8xY5bI8m2yah1923NIJGFd4YgRW8QKHSm80(s4f4HLLbJI0koedN9RMa2gNTY8GCceKZfJPGKBLTnj(l58arEgBmGJ6E7xWH8xcWVb)1XZRsoa)FI(Vu(ZewfdeQfGTXz7puASs0urildpTVeEbEyzzWOiTY2ePa8BWw9cQSvjENk5eyBsoQ7TxGhwwg0Rsoa)FI(Vu(ZewfdeQfGTXz7pC6bHSm80(s4f4HLLbJI0kcYwvwfd43uiGTXzRSTjXFjNhiYZyJb6OJ6E7D(c7QIe4C4cOJoQ7TxLmKLHN2xcVapSSmyuKwzBIe8BqkJGfzlrqAX4PmpiNab5CXyki5wzBtIlBkSoKLHN2xcVapSSmyuKwXHy4SF1eW24SvMhKtGGCUymfKCRSTjXFjNhiYZyJTTRohcSsVSLa(l58qwgEAFj8c8WYYGrrAfbzRkRIb8BkeW24SHSazz4P9LWlsslY2ryvmOFt8xaYQfxwzBt6gRdWqyL(P3fERAY)NO)lLFr2ocRIb9BI)cqwT4Y(U6nP9v4mmVlST9gRdWqyL(P3fEvYqwgEAFj8ImksRGfEXw4UvXaKWIyNY2Mex28stexYLTMKumaw4fh0NMecYhinrAUEBlx28stexYLTMKy1anGfEXb9PjHG8bstKMk22UAYhgceZ7E3(0IXdqEiKAeYYWt7lHxKrrAfbzRkRIb8BkeW24Sv22K4VKZde5zSXaoQ7TVpfhb)gWLnwH5vjhOHBSoadHv6NEx4TQPJ6E77tXrWVbCzJvy(dLgReUuX22BSoadHv6NEx4vj3iKLHN2xcViJI0kNjSkgiulaBJZwzEqobcY5IXuqYTY2Me)FI(VuEbEyzzq)HsJvIMUBBxDoeyLEbEyzzWanW)NO)lLFbhYFja)g8xhp)HsJvIMSAB7Q5FiSMk9SdE2unczz4P9LWlYOiTY2ePa8BWw9cQSTj1WnwhGHWk9tVl8w1K)pr)xk)2ePa8BWw9c67Q3K2xHZW8UW22BSoadHv6NEx4vj3yGgWcV4G(0Kqq(aPjstmcYvteKMe6s3TTCzZlnrCjx2uGK72wh192lY)Ka4CPmyQoyBh6puASsOagb5QjcstcJYDJTTBlwobhknwjuaJGC1ebPjHr5UTTJoQ7T35lSRksGZHlGo6OU3EvYqwgEAFj8ImksRWVHZMWQyaRy6iGWILZYQyLTnjh192NYiaLiJ3FcaFipCl)ZlYHZUP71kaw4fh0NMecYhinrAIrqUAIG0Kqx6oa)FI(Vu(ZewfdeQfGTXz7puASs0eJGC1ebPjHTToQ7TpLrakrgV)ea(qE4w(NxKdNDt3SAGg4)t0)LYlWdlld6puASsOq4dKdbwPxGhwwgSTL)pr)xk)coK)sa(n4VoE(dLgReke(a8pewtLE2bpBQ22TflNGdLgReke(gHSm80(s4fzuKw5ufYwfdyfthblw1v22KCu3B)PkKTkgWkMocwSQ77)sfy4PfcbyHsgkA6gYYWt7lHxKrrALTjsWVbPmcwKTebPfJNY8GCceKZfJPGKBLTnjUSPW6qwgEAFj8ImksRGriJea55Ku22K4YMxAI4sUS1KKBildpTVeErgfPv4YgWr9ePY2Mex28stexYLTMKChy4PfcbyHsgki5oWnwhGHWk9tVl8w1uXWAB5YMxAI4sUS1KKIbgEAHqawOKHIMKueYYWt7lHxKrrAfUSbwMqiKLHN2xcViJI0kPfJhG8qiPmpiNab5CXyki5wzBtI)sopqKNXgdWLnV0eXLCzRjjfd4OU3Er(NeaNlLbt1bB7qF)xkildpTVeErgfPveKTQSkgWVPqaBJZwzBtYrDV9CzdGfEXb9IC4SBUEyUm8HZHNwieGfkzOiGJ6E7f5FsaCUugmvhSTd99FPc0a)FI(Vu(ZewfdeQfGTXz7puASs0uXa8)j6)s53MifGFd2Qxq)HsJvIMk22Y)NO)lL)mHvXaHAbyBC2(dLgRekSEa()e9FP8BtKcWVbB1lO)qPXkrZ1dWLTMR32Y)NO)lL)mHvXaHAbyBC2(dLgRenxpa)FI(Vu(Tjsb43GT6f0FO0yLqH1dWLTMSABlx28stexYLnfi5oaw4fh0NMecYhinruqXgBBDu3Bpx2ayHxCqViho7MUdlW2ILtWHsJvcfwdqwgEAFj8ImksR4qmC2VAcyBC2kZdYjqqoxmMcsUv22K4VKZde5zSXanKdbwPxGhwwgma)FI(VuEbEyzzq)HsJvcfwVTL)pr)xk)zcRIbc1cW24S9hknwjA6oa)FI(Vu(Tjsb43GT6f0FO0yLOP72w()e9FP8NjSkgiulaBJZ2FO0yLqH1dW)NO)lLFBIua(nyREb9hknwjAUEaUS1uX2w()e9FP8NjSkgiulaBJZ2FO0yLO56b4)t0)LYVnrka)gSvVG(dLgRekSEaUS1C92wUS1m8TToQ7T35zdiFp3RsUrildpTVeErgfPvslgpa5HqszEqobcY5IXuqYTY2Me)LCEGipJngGlBEPjIl5Ywtskczz4P9LWlYOiTYC8Pqq(3HvQSTjXLnV0eXLCzRjj3qwgEAFj8ImksRSjcAvmqGhzSsaBJZwzRs8ovYjj3qwgEAFj8ImksR4qmC2VAcyBC2kZdYjqqoxmMcsUv22K4VKZde5zSXa8)j6)s53MifGFd2Qxq)HsJvcfwpax2iPyaYhgceZ7E3(0IXdqEiKcGfEXb9PjHG8bHpmfCdzz4P9LWlYOiTIdXWz)QjGTXzRmpiNab5CXyki5wzBtI)sopqKNXgdGfEXb9PjHG8bstefumqdCzZlnrCjx2uGK72wYhgceZ7E3(0IXdqEiKAeYcKLHN2xc)coK)sa(n4VoEKcnNnoeOY1iHKCigo7xnbSnoBqHyh7k)KjjWu5qdHksYrDV9l4q(lb43G)64bww8hknwjc0a)FI(Vu(ZewfdeQfGTXz7puASs00rDV9l4q(lb43G)64bww8hknwjc4OU3(fCi)La8BWFD8all(dLgRekOO3DBl)FI(Vu(ZewfdeQfGTXz7puASs4sh192VGd5VeGFd(RJhyzXFO0yLOPB)AfWrDV9l4q(lb43G)64bww8hknwjuGv9UBBDu3BVdX)Dcvr6vjhWrDV9wf6zJNa0rclwo9QKd4OU3ERc9SXta6iHflN(dLgRek4OU3(fCi)La8BWFD8all(dLgRenczz4P9LWVGd5VeGFd(RJxuKwHpeeGHN2xactKkxJesI3bcCRSTjT6CiWk9c8WYYGqwgEAFj8l4q(lb43G)64ffPv4dbby4P9fGWePY1iHK4DGapSSmOY2MuoeyLEbEyzzqildpTVe(fCi)La8BWFD8II0kyHxSfUBvmajSi2PSTjXLnV0eXLCzRjjfdGfEXb9PjHG8bstKMRdzz4P9LWVGd5VeGFd(RJxuKw5mHvXaHAbyBC2kZdYjqqoxmMcsUHSm80(s4xWH8xcWVb)1XlksRSnrka)gSvVGkBBsdpTqialuYqrtskgWrDV9l4q(lb43G)64bww8hknwjuWnKLHN2xc)coK)sa(n4VoErrALfz7iSkg0Vj(laz1IlRSTjn80cHaSqjdfnjPiKLHN2xc)coK)sa(n4VoErrAfbzRkRIb8BkeW24Sv22K4VKZde5zSXadpTqialuYqrtsRhWrDV9l4q(lb43G)64bww8QKHSm80(s4xWH8xcWVb)1XlksR4qmC2VAcyBC2kZdYjqqoxmMcsUv22K4VKZde5zSXadpTqialuYqHcKumqO5SXHa9oedN9RMa2gNnOqSJDildpTVe(fCi)La8BWFD8II0kcYwvwfd43uiGTXzRSTjXFjNhiYZyJbCu3BFFkoc(nGlBScZRsgYYWt7lHFbhYFja)g8xhVOiTcgHmsaKNtszBtIlBKclGJ6E7xWH8xcWVb)1XdSS4puASsOaRczz4P9LWVGd5VeGFd(RJxuKwzBIe8BqkJGfzlrqAX4PmpiNab5CXyki5wzBtIlBKclGJ6E7xWH8xcWVb)1XdSS4puASsOaRczz4P9LWVGd5VeGFd(RJxuKwzr2ocRIb9BI)cqwT4YqwgEAFj8l4q(lb43G)64ffPvslgpa5Hqs5CUymb2MKKvRAhDu3BV0CSb)gKYiGFtH(dLgRer1qhDu3BVGDWdhUmaJipQI0(YRsoCQyynQSTjXLnsHfWrDV9l4q(lb43G)64bww8hknwjuGvHSm80(s4xWH8xcWVb)1XlksRSnrka)gSvVGkBvI3Psob2MKJ6E7xWH8xcWVb)1XdSS4vjRSTj5OU3Er(NeaNlLbt1bB7qVk5a3yDagcR0p9UWBvt()e9FP8BtKcWVbB1lOVREtAFfodZVkqwgEAFj8l4q(lb43G)64ffPveKTQSkgWVPqaBJZwzBtYrDV9CzdGfEXb9IC4SBUEyUm8HZHNwieGfkzOaYYWt7lHFbhYFja)g8xhVOiTY2ej43GugblYwIG0IXtzEqobcY5IXuqYTY2Mex2uyDildpTVe(fCi)La8BWFD8II0kyeYibqEojLTnjUS5LMiUKlBnj5gYYWt7lHFbhYFja)g8xhVOiTcx2aoQNiv22K4YMxAI4sUS1KudUJA4PfcbyHsgkA6UrildpTVe(fCi)La8BWFD8II0kPfJhG8qiPmpiNab5CXyki5wzBtQHvNdbwPx2sa)LC(2w(l58arEgBSXaCzZlnrCjx2AssrildpTVe(fCi)La8BWFD8II0koedN9RMa2gNTY8GCceKZfJPGKBLTnPHNwieGfkzOqbsRhGlBnjTEBRJ6E7xWH8xcWVb)1XdSS4vjdzz4P9LWVGd5VeGFd(RJxuKwHlBGLjeczz4P9LWVGd5VeGFd(RJxuKwzte0QyGapYyLa2gNTYwL4DQKtsU1Po1Aa]] )


end