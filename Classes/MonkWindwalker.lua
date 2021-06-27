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
        width = 1.5
    } ) 


    spec:RegisterPack( "Windwalker", 20210627, [[dSe7Acqivu5rQiL2Ka9jQqnkPGtjfAvcj4vckZIe1TibTlQ6xQigMGQJrfTmsKNPIY0ibCnHK2MqI(gviACuHuNtfjTovKQ5bP6EqY(KIoiviXcfs9qQqyIuHKYfvrvYgvrvkFufPWjfsiRes5LQOkvZKeOUjviPANKq)KkKKLQIu0trPPsf8vvufJvfj2lP(lWGH6Wkwmv6XOAYs1Lr2Sk9zHA0e50uwTkQQxJIMne3MO2TKFR0WrHJtcKLRQNty6IUojTDb57sPXleNxaRxiHA(QW(bT2P2bnBFssROsHRKZWJsLCKENosNHh1tvZMbyqAwgdN5etA2AKjn75XQE7GWKEnlJjaYoDTdAwXQ(CsZQzDvnKmkQ0UA2(KKwrLcxjNHhLk5i9oDKodpQosnRGbX1kQuuEQAwjR3Ps7Qz7KGRzppw1BheM0dXoQVftiAOPweeRKJuziwPWvYjeniAo0sdti(8MjsbeVxi(8M6haITkP)vzKqmYgBCpenhAPHjeZYWQYQyi2r8trq85DJZeIr2yJ7HO5O07qS7kexlwkHyUeXzkG4CHy5PcaXoch1GyQY3iHxZIyIuODqZUmOIETdAfDQDqZs14IqDD0A2HN2wA2RjsWEbPebALSKaPftVML)wsVnAwUK5LNiqScHyUKbXnrbXNPz5b4ieiN)JPuOzDQtTIkPDqZs14IqDD0Aw(Bj92OzZbHQ0ZLmGR6lspvJlc1H4GqmxY8YteiwHqmxYG4MOG4Z0SdpTT0SuegecqAEzDQv8mTdAwQgxeQRJwZo802sZMwm9agdISML)wsVnAw(k7Uar(gtcIdcXCjZlprGyfcXCjdIBIcIvsZYdWriqoFmLcTIo1Pwrfq7GMLQXfH66O1S83s6TrZYLmV8ebIvieZLmigfeRKMD4PTLMLlzG2jePtTIrv7GMD4PTLMLIWGqasZlRzPACrOUoADQvmk1oOzPACrOUoAn7WtBlnBAX0dymiYAw(Bj92Oz5sMxEIaXkeI5sge3efeRKMLhGJqGC(ykfAfDQtDQzBPHXwcWEb73Px7GwrNAh0SunUiuxhTMDzOzfuQzhEABPzdnVnUiKMn0GOsAwx1713sdJTeG9c2VtpOT1)K8yLaIdcXnaX8Dr6BB5FtyvmqOwaMgNP)j5Xkbe3eIDvVxFlnm2sa2ly)o9G2w)tYJvcioie7QEV(wAySLaSxW(D6bTT(NKhReqm6qSsENq8XbeZ3fPVTL)nHvXaHAbyACM(NKhReqScHyx1713sdJTeG9c2VtpOT1)K8yLaIBcXo9NkeheIDvVxFlnm2sa2ly)o9G2w)tYJvcigDiwb8oH4Jdi2v9E9Ui72rufPxLbeheIDvVxVvHwM0laDcXILsVkdioie7QEVERcTmPxa6eIflL(NKhReqm6qSR696BPHXwcWEb73Ph026FsESsaXnQzdnpOgzsZ6ImCMRAcyACMGIOo11PwrL0oOzPACrOUoAnl)TKEB0SNdIZbHQ0lONkld4PACrOUMD4PTLMLpiiGHN2waetKAwetKGAKjnlVde0vNAfpt7GMLQXfH66O1S83s6TrZMdcvPxqpvwgWt14IqDn7WtBlnlFqqadpTTaiMi1SiMib1itAwEhiONkldOtTIkG2bnlvJlc11rRz5VL0BJMLlzE5jceRqiMlzqCtuqSsqCqiMk6Jd4ttMa5cKNiqCti(mn7WtBlnlv0hBrXwfdielI96uRyu1oOzPACrOUoAn7WtBln7BcRIbc1cW04m1S8aCecKZhtPqROtDQvmk1oOzPACrOUoAnl)TKEB0SdpTqeGks2ibe3efeReeheIDvVxFlnm2sa2ly)o9G2w)tYJvcigDi2PMD4PTLM9AIua2l4Q(b0PwrhP2bnlvJlc11rRz5VL0BJMLlzqmkioCioie7QEV(wAySLaSxW(D6bTT(NKhReqm6qScOzhEABPzPimieG08Y6uROJw7GMLQXfH66O1SdpTT0SxtKG9csjc0kzjbslMEnl)TKEB0SCjdIrbXHdXbHyx1713sdJTeG9c2VtpOT1)K8yLaIrhIvanlpahHa58Xuk0k6uNAfpvTdA2HN2wA2wj7rSkg0)jElad1IlPzPACrOUoADQv0z4Ah0SunUiuxhTMD4PTLMnTy6bmgeznl)TKEB0SCjdIrbXHdXbHyx1713sdJTeG9c2VtpOT1)K8yLaIrhIvanlpahHa58Xuk0k6uNAfD6u7GMLQXfH66O1S83s6TrZYxz3fiY3ysqCqiE4PfIaurYgjG4MOG4ZG4GqSR696BPHXwcWEb73Ph026vzOzhEABPzfmSQSkgW)PiatJZuNAfDQK2bnlvJlc11rRzhEABPzDrgoZvnbmnotnl)TKEB0S8v2DbI8nMeeheIhEAHiavKSrcigDuqSsqCqio0824IqExKHZCvtatJZeue1PUMLhGJqGC(ykfAfDQtTIopt7GMLQXfH66O1S83s6TrZYxz3fiY3ysqCqi2v9E99P4eyVaUKD(MxLHMD4PTLMvWWQYQya)NIamnotDQv0PcODqZo802sZ2kzpIvXG(pXBbyOwCjnlvJlc11rRtTIoJQ2bnlvJlc11rRz5VL0BJM1v9E9ICFzanFkbMQdU2tEvgqCqi(hRdOquL(P3fERG4MqmFxK(2w(RjsbyVGR6hW3v)jTTG4OaehUpk1SdpTT0SxtKcWEbx1pGM1QK(xLrcSRM1v9E9T0WylbyVG970dAB9Qm0PwrNrP2bnlvJlc11rRz5VL0BJM1v9E9Cjdqf9Xb8IC4mH4Mq8zHdXkeIJkehfG4HNwicqfjBKqZo802sZkyyvzvmG)traMgNPo1k60rQDqZs14IqDD0A2HN2wA2RjsWEbPebALSKaPftVML)wsVnAwUKbXOdXNPz5b4ieiNpMsHwrN6uROthT2bnlvJlc11rRz5VL0BJMLlzE5jceRqiMlzqCtuqStn7WtBlnlfHbHaKMxwNAfDEQAh0SunUiuxhTML)wsVnAwUK5LNiqScHyUKbXnrbXnaXoH4WG4HNwicqfjBKaIBcXoH4g1SdpTT0SCjd4Q(IuNAfvkCTdAwQgxeQRJwZo802sZMwm9agdISML)wsVnA2gG4ZbX5Gqv6LSeWxz31t14IqDi(4aI5RS7ce5BmjiUrioieZLmV8ebIvieZLmiUjkiwjnlpahHa58Xuk0k6uNAfvYP2bnlvJlc11rRzhEABPzDrgoZvnbmnotnl)TKEB0SdpTqeGks2ibeJoki(mioieZLmiUjki(mi(4aIDvVxFlnm2sa2ly)o9G2wVkdnlpahHa58Xuk0k6uNAfvsjTdA2HN2wAwUKbANqKMLQXfH66O1PwrLot7GM1QK(xLrQzDQzhEABPzVibSkgiONbvjGPXzQzPACrOUoADQtnRGEQSmG2bTIo1oOzPACrOUoAnl)TKEB0SUQ3RxqpvwgW)K8yLaIrhIDQzhEABPzVMifG9cUQFaDQvujTdAwQgxeQRJwZYFlP3gnlFLDxGiFJjbXbH4gG4HNwicqfjBKaIBIcIpdIpoG4HNwicqfjBKaIBcXoH4Gq85Gy(Ui9TT8VjSkgiulatJZ0RYaIBuZo802sZkyyvzvmG)traMgNPo1kEM2bnlvJlc11rRzhEABPzFtyvmqOwaMgNPML)wsVnAw(k7Uar(gtsZYdWriqoFmLcTIo1Pwrfq7GMLQXfH66O1S83s6TrZo80craQizJeqCtuq8zA2HN2wA2RjsbyVGR6hqNAfJQ2bnlvJlc11rRz5VL0BJMLVYUlqKVXKG4GqSR6967tXjWEbCj78nVkdn7WtBlnRGHvLvXa(pfbyACM6uRyuQDqZs14IqDD0A2HN2wAwxKHZCvtatJZuZYFlP3gnlFLDxGiFJjbXbHyx1713sdJTeG9c2VtVxLbeheI57I032Y)MWQyGqTamnot)tYJvciUjeRKMLhGJqGC(ykfAfDQtTIosTdAwRs6FvgjWUAwx171lONkld4vzeKVlsFBl)BcRIbc1cW04m9pn9aA2HN2wA2RjsbyVGR6hqZs14IqDD06uROJw7GMLQXfH66O1S83s6TrZYxz3fiY3ysqCqiUtUQ3R3DlQRksG7tTGo5QEVEvgA2HN2wAwbdRkRIb8FkcW04m1PwXtv7GMLQXfH66O1SdpTT0SxtKG9csjc0kzjbslMEnl)TKEB0SCjdIrhIptZYdWriqoFmLcTIo1PwrNHRDqZs14IqDD0A2HN2wAwxKHZCvtatJZuZYFlP3gnlFLDxGiFJjbXhhq85G4CqOk9swc4RS76PACrOUMLhGJqGC(ykfAfDQtTIoDQDqZo802sZkyyvzvmG)traMgNPMLQXfH66O1Po1S8oqqpvwgq7GwrNAh0SunUiuxhTMDzOzfuQzhEABPzdnVnUiKMn0GOsAw(Ui9TT8c6PYYa(NKhReqm6qSti(4aIzqPpIkvGuIaTswsG0IP3p80crqCqiMVlsFBlVGEQSmG)j5Xkbe3eIplCi(4aIDxHaIdcXxlwkbpjpwjGy0HyLcxZgAEqnYKMvqpvwga4Q(IuNAfvs7GMLQXfH66O1S83s6TrZEoio0824IqEPfPdIOsfeFCaXURqaXbH4RflLGNKhReqm6qSsrvZo802sZAvOLjbIOsLo1kEM2bnlvJlc11rRz5VL0BJMn0824IqEb9uzzaGR6lsn7WtBlnRlYUDWv9dOtTIkG2bnlvJlc11rRz5VL0BJMn0824IqEb9uzzaGR6lsn7WtBlnRl9c6zAvSo1kgvTdA2HN2wAwelwkfGZxThltvQzPACrOUoADQvmk1oOzPACrOUoAnl)TKEB0SHM3gxeYlONkldaCvFrQzhEABPzV2tUi721PwrhP2bnlvJlc11rRz5VL0BJMn0824IqEb9uzzaGR6lsn7WtBln7uCsK)Ga4dcIo1k6O1oOzPACrOUoAnl)TKEB0SHM3gxeYlONkldaCvFrQzhEABPzDNyWEb5BCMcDQv8u1oOzPACrOUoAnl)TKEB0SxlwkbpjpwjG4MqCdqSthD4qScH4xTO7(XK)o5GaYvLl5PACrOoehfGyNkfoe3ieFCaXmO0hrLkqkrGwjljqAX07hEAHii(4aIDxHaIdcXxlwkbpjpwjGy0HyNHRzhEABPzZvLlb2lOttkPtTIodx7GMLQXfH66O1S83s6TrZETyPe8K8yLaIBcXNA4q8XbeZGsFevQaPebALSKaPftVF4PfIG4Jdi2DfcioieFTyPe8K8yLaIrhIDgUMD4PTLMnxvUeyVaMZlp6uROtNAh0SunUiuxhTML)wsVnAw(Ui9TT8VjSkgiulatJZ0)K8yLaIrhIPiexnjqAYKMD4PTLMTLggBja7fSFNEDQv0PsAh0SunUiuxhTML)wsVnA2qZBJlc5f0tLLbaUQVi1SdpTT0Swj4VAoUieqbPovQkd6uiJt6uROZZ0oOzPACrOUoAnl)TKEB0SHM3gxeYlONkldaCvFrQzhEABPzB)jLe5wKo1k6ub0oOzPACrOUoAnl)TKEB0SHM3gxeYlONkldaCvFrQzhEABPzJrMUn5(cG70JjDQv0zu1oOzPACrOUoAnl)TKEB0SNdIdnVnUiKpIkvGTaQccKVvmPeIpoGy(Ui9TT8wfAzsGiQubsjc0kzjbslME)tYJvciUjeRu4q8XbehAEBCriV0I0bruPsZo802sZQkiGLKSqNAfDgLAh0SdpTT0S3HqSIaICLzOzPACrOUoADQv0PJu7GMD4PTLM9oiiub2VtVMLQXfH66O1PwrNoATdAwQgxeQRJwZYFlP3gnR7keqCqi(AXsj4j5XkbeJoe7mQq8Xbe3aeZLmiUjkiwjioie3aeFTyPe8K8yLaIBcXrz4qCqiUbiUbiMVlsFBlVGEQSmG)j5Xkbe3eIDgoeFCaXUQ3RxqpvwgWRYaIpoGy(Ui9TT8c6PYYaEvgqCJqCqiUbiMbL(iQubsjc0kzjbslME)WtlebXhhqmFxK(2wERcTmjqevQaPebALSKaPftV)j5Xkbe3eIDgoeFCaXHM3gxeYlTiDqevQG4gH4gH4gH4JdiUbi(AXsj4j5XkbeJokiokdhIdcXnaXmO0hrLkqkrGZJKLeiTy69dpTqeeFCaX8Dr6BB5Tk0YKaruPcKseOvYscKwm9(NKhReqCti(AXsj4j5Xkbe3ie3ie3OMD4PTLM1DlQRksG7tT6uROZtv7GMLQXfH66O1S83s6TrZY3fPVTL)nHvXaHAbyACM(NKhReqm6qSsq8Xbe7UcbeheIVwSucEsESsaXOdXoJQMD4PTLMvqpvwgqNAfvkCTdA2HN2wAw3jgSxq(gNPqZs14IqDD06uNAwrQDqROtTdAwQgxeQRJwZYFlP3gn7pwhqHOk9tVl8wbXnHy(Ui9TT8Ts2JyvmO)t8wagQfxY3v)jTTG4OaehU3rdXhhq8pwhqHOk9tVl8Qm0SdpTT0STs2JyvmO)t8wagQfxsNAfvs7GMLQXfH66O1S83s6TrZYLmV8ebIvieZLmiUjkiwjioietf9Xb8PjtGCbYteiUjeFgeFCaXCjZlprGyfcXCjdIBIcIvaioie3aetf9Xb8PjtGCbYteiUjeReeFCaXNdIz8uiqmV7D6tlMEaJbrgIBuZo802sZsf9XwuSvXacXIyVo1kEM2bnlvJlc11rRz5VL0BJMLVYUlqKVXKG4GqSR6967tXjWEbCj78nVkdioie3ae)J1buiQs)07cVvqCti2v9E99P4eyVaUKD(M)j5XkbeRqiwji(4aI)X6akevPF6DHxLbe3OMD4PTLMvWWQYQya)NIamnotDQvub0oOzPACrOUoAn7WtBln7BcRIbc1cW04m1S83s6TrZY3fPVTLxqpvwgW)K8yLaIBcXoH4Jdi(CqCoiuLEb9uzzapvJlc1H4GqCdqmFxK(2w(wAySLaSxW(D69pjpwjG4MqScaXhhq85Gy(gIQPspZaVnfe3OMLhGJqGC(ykfAfDQtTIrv7GMLQXfH66O1S83s6TrZ2ae)J1buiQs)07cVvqCtiMVlsFBl)1ePaSxWv9d47Q)K2wqCuaId37OH4Jdi(hRdOquL(P3fEvgqCJqCqiUbiMk6Jd4ttMa5cKNiqCtiMIqC1KaPjtqScHyNq8XbeZLmV8ebIvieZLmigDuqSti(4aIDvVxVi3xgqZNsGP6GR9K)j5XkbeJoetriUAsG0Kjiomi2je3ieFCaXxlwkbpjpwjGy0HykcXvtcKMmbXHbXoH4JdiUtUQ3R3DlQRksG7tTGo5QEVEvgA2HN2wA2RjsbyVGR6hqNAfJsTdAwQgxeQRJwZYFlP3gnRR696tjcqYmOFFbGpmgUL77f5WzcXnHyNNkeheIPI(4a(0KjqUa5jce3eIPiexnjqAYeeRqi2jeheI57I032Y)MWQyGqTamnot)tYJvciUjetriUAsG0Kji(4aIDvVxFkrasMb97la8HXWTCFVihotiUje7ubG4GqCdqmFxK(2wEb9uzza)tYJvcigDioQqCqioheQsVGEQSmGNQXfH6q8XbeZ3fPVTLVLggBja7fSFNE)tYJvcigDioQqCqiMVHOAQ0ZmWBtbXhhq81ILsWtYJvcigDioQqCJA2HN2wAw(pCMiwfdo)PtaelwklRI1PwrhP2bnlvJlc11rRz5VL0BJM1v9E9VQqYQyW5pDc0Av3332cIdcXdpTqeGks2ibe3eIDQzhEABPzFvHKvXGZF6eO1QUo1k6O1oOzPACrOUoAn7WtBln71ejyVGuIaTswsG0IPxZYFlP3gnlxYGy0H4Z0S8aCecKZhtPqROtDQv8u1oOzPACrOUoAnl)TKEB0SCjZlprGyfcXCjdIBIcIDQzhEABPzPimieG08Y6uROZW1oOzPACrOUoAnl)TKEB0SCjZlprGyfcXCjdIBIcIDcXbH4HNwicqfjBKaIrbXoH4Gq8pwhqHOk9tVl8wbXnHyLchIpoGyUK5LNiqScHyUKbXnrbXkbXbH4HNwicqfjBKaIBIcIvsZo802sZYLmGR6lsDQv0PtTdA2HN2wAwUKbANqKMLQXfH66O1PwrNkPDqZs14IqDD0A2HN2wA20IPhWyqK1S83s6TrZYxz3fiY3ysqCqiMlzE5jceRqiMlzqCtuqSsqCqi2v9E9ICFzanFkbMQdU2t((2wAwEaocbY5JPuOv0Po1k68mTdAwQgxeQRJwZYFlP3gnRR6965sgGk6Jd4f5WzcXnH4ZchIviehviokaXdpTqeGks2ibeheIDvVxVi3xgqZNsGP6GR9KVVTfeheIBaI57I032Y)MWQyGqTamnot)tYJvciUjeReeheI57I032YFnrka7fCv)a(NKhReqCtiwji(4aI57I032Y)MWQyGqTamnot)tYJvcigDi(mioieZ3fPVTL)AIua2l4Q(b8pjpwjG4Mq8zqCqiMlzqCti(mi(4aI57I032Y)MWQyGqTamnot)tYJvciUjeFgeheI57I032YFnrka7fCv)a(NKhReqm6q8zqCqiMlzqCtiwbG4JdiMlzE5jceRqiMlzqm6OGyNqCqiMk6Jd4ttMa5cKNiqm6qSsqCJq8Xbe7QEVEUKbOI(4aEroCMqCti2z4qCqi(AXsj4j5XkbeJoe7i1SdpTT0Scgwvwfd4)ueGPXzQtTIovaTdAwQgxeQRJwZo802sZ6ImCMRAcyACMAw(Bj92Oz5RS7ce5Bmjioie3aeNdcvPxqpvwgWt14IqDioieZ3fPVTLxqpvwgW)K8yLaIrhIpdIpoGy(Ui9TT8VjSkgiulatJZ0)K8yLaIBcXoH4GqmFxK(2w(RjsbyVGR6hW)K8yLaIBcXoH4JdiMVlsFBl)BcRIbc1cW04m9pjpwjGy0H4ZG4GqmFxK(2w(RjsbyVGR6hW)K8yLaIBcXNbXbHyUKbXnHyLG4JdiMVlsFBl)BcRIbc1cW04m9pjpwjG4Mq8zqCqiMVlsFBl)1ePaSxWv9d4FsESsaXOdXNbXbHyUKbXnH4ZG4JdiMlzqCtioQq8Xbe7QEVE3LjGXVCVkdiUrnlpahHa58Xuk0k6uNAfDgvTdAwQgxeQRJwZo802sZMwm9agdISML)wsVnAw(k7Uar(gtcIdcXCjZlprGyfcXCjdIBIcIvsZYdWriqoFmLcTIo1PwrNrP2bnlvJlc11rRz5VL0BJMLlzE5jceRqiMlzqCtuqStn7WtBln788PiqU)tvQtTIoDKAh0SwL0)QmsnRtn7WtBln7fjGvXab9mOkbmnotnlvJlc11rRtTIoD0Ah0SunUiuxhTMD4PTLM1fz4mx1eW04m1S83s6TrZYxz3fiY3ysqCqiMVlsFBl)1ePaSxWv9d4FsESsaXOdXNbXbHyUKbXOGyLG4GqmJNcbI5DVtFAX0dymiYqCqiMk6Jd4ttMa5cIA4qm6qStnlpahHa58Xuk0k6uNAfDEQAh0SunUiuxhTMD4PTLM1fz4mx1eW04m1S83s6TrZYxz3fiY3ysqCqiMk6Jd4ttMa5cKNiqm6qSsqCqiUbiMlzE5jceRqiMlzqm6OGyNq8XbeZ4PqGyE370Nwm9agdIme3OMLhGJqGC(ykfAfDQtDQz5DGGUAh0k6u7GMLQXfH66O1S83s6TrZEoio0824IqEPfPdIOsfeheIBaI57I032Y)MWQyGqTamnot)tYJvcigDiwji(4aIpheZ3qunv6zg4TPG4gH4GqCdq85Gy(gIQPsFr8Fr2VdXhhqmFxK(2wE3TOUQibUp16FsESsaXOdXkbXncXhhq81ILsWtYJvcigDiwPOQzhEABPzTk0YKaruPsNAfvs7GMLQXfH66O1S83s6TrZETyPe8K8yLaIBcXnaXoD0HdXkeIF1IU7ht(7KdcixvUKNQXfH6qCuaIDQu4qCJq8Xbe7QEVErUVmGMpLat1bx7jFFBlioieZGsFevQaPebALSKaPftVF4PfIG4Jdi2DfcioieFTyPe8K8yLaIrhIDgUMD4PTLMnxvUeyVGonPKo1kEM2bnlvJlc11rRz5VL0BJMTbi(hRdOquL(P3fERG4MqScevi(4aI)X6akevPF6DHxLbe3ieheI57I032Y)MWQyGqTamnot)tYJvcigDiMIqC1KaPjtqCqiMVlsFBlVvHwMeiIkvGuIaTswsG0IP3)K8yLaIBcXnaXkfoehgeRu4qCuaIF1IU7htERcTmPxa6eIflLEQgxeQdXncXhhqS7keqCqi(AXsj4j5XkbeJoeFwu1SdpTT0ST0WylbyVG970RtTIkG2bnlvJlc11rRz5VL0BJMLVYUlqKVXKG4GqCdq8pwhqHOk9tVl8wbXnHyNHdXhhq8pwhqHOk9tVl8QmG4g1SdpTT0S3HqSIaICLzOtTIrv7GMLQXfH66O1S83s6TrZ(J1buiQs)07cVvqCti(SWH4Jdi(hRdOquL(P3fEvgA2HN2wA27GGqfy)o96uRyuQDqZs14IqDD0Aw(Bj92Oz5sge3efeReeheIVwSucEsESsaXnH4OmCioie3aeZ3fPVTLxK7ldO5tjWuDW1EYZLMpMeqCtioCi(4aI57I032YlY9Lb08PeyQo4Ap5FsESsaXnHyNHdXncXbH4gGygu6JOsfiLiqRKLeiTy69dpTqeeFCaX8Dr6BB5Tk0YKaruPcKseOvYscKwm9(NKhReqCti2z4q8XbehAEBCriV0I0bruPcIBeIpoG4gGyUKbXnrbXkbXbH4RflLGNKhReqm6OG4OmCioie3aeZGsFevQaPebopswsG0IP3p80crq8XbeZ3fPVTL3QqltcerLkqkrGwjljqAX07FsESsaXnH4RflLGNKhReqCJqCqiUbiMVlsFBlVi3xgqZNsGP6GR9KNlnFmjG4MqC4q8XbeZ3fPVTLxK7ldO5tjWuDW1EY)K8yLaIBcXxlwkbpjpwjG4Jdi2v9E9ICFzanFkbMQdU2tEvgqCJqCJq8XbeFTyPe8K8yLaIrhIDgvn7WtBlnR7wuxvKa3NA1PwrhP2bnlvJlc11rRz5VL0BJMLVvx1spF3VB1KuhS3lvcle5PACrOUMD4PTLMvK7ldO5tjWuDW1EcCTits6uROJw7GMLQXfH66O1S83s6TrZY3fPVTLxK7ldO5tjWuDW1EYZLMpMeqmkiwji(4aIVwSucEsESsaXOdXkfoeFCaXnaX)yDafIQ0p9UW)K8yLaIBcXoJkeFCaXnaXNdI5BiQMk9md82uqCqi(CqmFdr1uPVi(Vi73H4gH4GqCdqCdq8pwhqHOk9tVl8wbXnHy(Ui9TT8ICFzanFkbMQdU2t(Rkcc4jU08XeinzcIpoG4ZbX)yDafIQ0p9UWtrmrkG4gH4GqCdqmFxK(2wERcTmjqevQaPebALSKaPftV)j5Xkbe3eI57I032YlY9Lb08PeyQo4Ap5VQiiGN4sZhtG0Kji(4aIdnVnUiKxAr6GiQubXncXncXbHy(Ui9TT8xtKcWEbx1pG)j5XkbeJoki(uH4GqmxYG4MOGyLG4GqmFxK(2w(wj7rSkg0)jElad1Il5FsESsaXOJcIDQee3OMD4PTLMvK7ldO5tjWuDW1EsNAfpvTdAwQgxeQRJwZYFlP3gnlFdr1uPNzG3McIdcXnaXUQ3RVLggBja7fSFNEVkdi(4aIBaIVwSucEsESsaXOdX8Dr6BB5BPHXwcWEb73P3)K8yLaIpoGy(Ui9TT8T0WylbyVG9707FsESsaXnHy(Ui9TT8ICFzanFkbMQdU2t(Rkcc4jU08XeinzcIBeIdcX8Dr6BB5VMifG9cUQFa)tYJvcigDuq8PcXbHyUKbXnrbXkbXbHy(Ui9TT8Ts2JyvmO)t8wagQfxY)K8yLaIrhfe7ujiUrn7WtBlnRi3xgqZNsGP6GR9Ko1k6mCTdAwQgxeQRJwZYFlP3gnlFdr1uPVi(Vi73H4GqCNCvVxV7wuxvKa3NAbDYv9E9QmG4GqCdqmdk9ruPcKseOvYscKwm9(HNwicIpoG4qZBJlc5LwKoiIkvq8XbeZ3fPVTL3QqltcerLkqkrGwjljqAX07FsESsaXnHy(Ui9TT8ICFzanFkbMQdU2t(Rkcc4jU08XeinzcIpoGy(Ui9TT8wfAzsGiQubsjc0kzjbslME)tYJvciUjeFw4qCJA2HN2wAwrUVmGMpLat1bx7jDQv0PtTdAwQgxeQRJwZYFlP3gnldk9ruPcKseOvYscKwm9(HNwicIpoGy3viG4Gq81ILsWtYJvcigDiwPW1SdpTT0Swj4VAoUieqbPovQkd6uiJt6uROtL0oOzPACrOUoAnl)TKEB0SmO0hrLkqkrGwjljqAX07hEAHii(4aIDxHaIdcXxlwkbpjpwjGy0HyLcxZo802sZ2(tkjYTiDQv05zAh0SunUiuxhTML)wsVnAwgu6JOsfiLiqRKLeiTy69dpTqeeFCaXURqaXbH4RflLGNKhReqm6qSsHRzhEABPzJrMUn5(cG70JjDQv0PcODqZs14IqDD0A2HN2wA2(tt)ApbcrcbHOz5VL0BJM9CqCO5TXfH8ruPcSfqvqG8TIjLq8XbeZ3fPVTL3QqltcerLkqkrGwjljqAX07FsESsaXnHyLchIdcXmO0hrLkqkrGwjljqAX07FsESsaXOdXkfoeFCaXHM3gxeYlTiDqevQ0S1itA2(tt)ApbcrcbHOtTIoJQ2bnlvJlc11rRz5VL0BJM9CqCO5TXfH8ruPcSfqvqG8TIjLq8XbeZ3fPVTL3QqltcerLkqkrGwjljqAX07FsESsaXnHyLchIpoG4qZBJlc5LwKoiIkvA2HN2wAwvbbSKKf6uROZOu7GMLQXfH66O1S83s6TrZETyPe8K8yLaIBcXNA4q8XbeZGsFevQaPebALSKaPftVF4PfIG4Jdio0824IqEPfPdIOsfeFCaXURqaXbH4RflLGNKhReqm6qSZOuZo802sZMRkxcSxaZ5LhDQv0PJu7GMLQXfH66O1S83s6TrZY3fPVTL3QqltcerLkqkrGwjljqAX07FsESsaXnH4ZchIpoG4qZBJlc5LwKoiIkvq8Xbe7UcbeheIVwSucEsESsaXOdXkfUMD4PTLM1fz3o4Q(b0PwrNoATdAwQgxeQRJwZYFlP3gnlFxK(2wERcTmjqevQaPebALSKaPftV)j5Xkbe3eIplCi(4aIdnVnUiKxAr6GiQubXhhqS7keqCqi(AXsj4j5XkbeJoe7mQA2HN2wAwx6f0Z0QyDQv05PQDqZo802sZIyXsPaC(Q9yzQsnlvJlc11rRtTIkfU2bnlvJlc11rRz5VL0BJMLVlsFBlVvHwMeiIkvGuIaTswsG0IP3)K8yLaIBcXNfoeFCaXHM3gxeYlTiDqevQG4Jdi2DfcioieFTyPe8K8yLaIrhIDgUMD4PTLM9Ap5ISBxNAfvYP2bnlvJlc11rRz5VL0BJMLVlsFBlVvHwMeiIkvGuIaTswsG0IP3)K8yLaIBcXNfoeFCaXHM3gxeYlTiDqevQG4Jdi2DfcioieFTyPe8K8yLaIrhIvkCn7WtBln7uCsK)Ga4dcIo1kQKsAh0SunUiuxhTML)wsVnAwx171lY9Lb08PeyQo4Ap57BBPzhEABPzDNyWEb5BCMcDQtnBNUJksQDqROtTdA2HN2wAwbdAEG0uDGiFJjPzPACrOUoADQvujTdAwQgxeQRJwZUm0Sck1SdpTT0SHM3gxesZgAqujnlFxK(2wERcTmjqevQaPebALSKaPftV)j5Xkbe3eIVwSucEsESsaXhhq81ILsWtYJvciwHqmFxK(2wERcTmjqevQaPebALSKaPftV)j5XkbeJoe7uPWH4GqCdqCdqCoiuLEb9uzzapvJlc1H4Gq81ILsWtYJvciUjeZ3fPVTLxqpvwgW)K8yLaIdcX8Dr6BB5f0tLLb8pjpwjG4MqSZWH4gH4JdiUbiMVlsFBlVi3xgqZNsGP6GR9K)QIGaEIlnFmbstMGy0H4RflLGNKhReqCqiMVlsFBlVi3xgqZNsGP6GR9K)QIGaEIlnFmbstMG4MqSZOcXncXhhqCdqmFxK(2wErUVmGMpLat1bx7jpxA(ysaXOG4WH4GqmFxK(2wErUVmGMpLat1bx7j)tYJvcigDi(AXsj4j5Xkbe3ie3OMn08GAKjnR0I0bruPsNAfpt7GMLQXfH66O1S83s6TrZ2ae7QEVEb9uzzaVkdi(4aIDvVxVi3xgqZNsGP6GR9KxLbe3ieheIzqPpIkvGuIaTswsG0IP3p80crq8Xbe7UcbeheIVwSucEsESsaXOJcIJYW1SdpTT0Sm202sNAfvaTdAwQgxeQRJwZYFlP3gnRR696f0tLLb8Qm0SdpTT0S8bbbm802cGyIuZIyIeuJmPzf0tLLb0PwXOQDqZs14IqDD0Aw(Bj92OzDvVxFlnm2sa2ly)o9EvgA2HN2wAw(GGagEABbqmrQzrmrcQrM0ST0WylbyVG970RtTIrP2bnlvJlc11rRz5VL0BJMnnzcIrhIvaioieZLmigDioQqCqi(Cqmdk9ruPcKseOvYscKwm9(HNwisZo802sZYheeWWtBlaIjsnlIjsqnYKMDzqf96uROJu7GMLQXfH66O1SdpTT0SxtKG9csjc0kzjbslMEnl)TKEB0SCjZlprGyfcXCjdIBIcIpdIdcXnaXurFCaFAYeixG8ebIrhIDcXhhqmv0hhWNMmbYfiprGy0HyfaIdcX8Dr6BB5VMifG9cUQFa)tYJvcigDi2PpQq8XbeZ3fPVTLVLggBja7fSFNE)tYJvcigDiwjiUrioieFoiUtUQ3R3DlQRksG7tTGo5QEVEvgAwEaocbY5JPuOv0Po1k6O1oOzPACrOUoAnl)TKEB0SCjZlprGyfcXCjdIBIcIDcXbH4gGyQOpoGpnzcKlqEIaXOdXoH4JdiMVlsFBlVGEQSmG)j5XkbeJoeReeFCaXurFCaFAYeixG8ebIrhIvaioieZ3fPVTL)AIua2l4Q(b8pjpwjGy0HyN(OcXhhqmFxK(2w(wAySLaSxW(D69pjpwjGy0HyLG4gH4Gq85Gyx1717Uf1vfjW9PwVkdn7WtBlnlfHbHaKMxwNAfpvTdAwQgxeQRJwZo802sZMwm9agdISML)wsVnAw(k7Uar(gtcIdcXCjZlprGyfcXCjdIBIcIvcIdcXnaXurFCaFAYeixG8ebIrhIDcXhhqmFxK(2wEb9uzza)tYJvcigDiwji(4aIPI(4a(0KjqUa5jceJoeRaqCqiMVlsFBl)1ePaSxWv9d4FsESsaXOdXo9rfIpoGy(Ui9TT8T0WylbyVG9707FsESsaXOdXkbXncXbH4ZbXDYv9E9UBrDvrcCFQf0jx171RYqZYdWriqoFmLcTIo1PwrNHRDqZs14IqDD0Aw(Bj92OzpheNdcvPxqpvwgWt14IqDn7WtBlnlFqqadpTTaiMi1SiMib1itAwEhiORo1k60P2bnlvJlc11rRz5VL0BJMnheQsVGEQSmGNQXfH6A2HN2wAw(GGagEABbqmrQzrmrcQrM0S8oqqpvwgqNAfDQK2bnlvJlc11rRz5VL0BJMD4PfIaurYgjGy0H4Z0SdpTT0S8bbbm802cGyIuZIyIeuJmPzfPo1k68mTdAwQgxeQRJwZYFlP3gn7WtlebOIKnsaXnrbXNPzhEABPz5dccy4PTfaXePMfXejOgzsZolPtDQzz8eFLDNu7GwrNAh0SdpTT0SUBMiuhCrMauV1QyqUrSsZs14IqDD06uROsAh0SunUiuxhTMDzOzfuQzhEABPzdnVnUiKMn0GOsAwsbPAmyqDVvc(RMJlcbuqQtLQYGofY4eeFCaXKcs1yWG6(yKPBtUVa4o9ycIpoGysbPAmyqDF7pPKi3IG4JdiMuqQgdgu3VHONlnFm1btzYdWDYK(aq8XbetkivJbdQ7fstFBJ)rWaKBsYA2qZdQrM0SruPcSfqvqG8TIjL6uR4zAh0SunUiuxhTML)wsVnA2ZbX5Gqv6f0tLLb8unUiuhIpoG4ZbX5Gqv6VMib7fKseOvYscKwm9EQgxeQRzhEABPz5sgWv9fPo1kQaAh0SunUiuxhTML)wsVnA2ZbX5Gqv6PI(ylk2QyaHyrO3t14IqDn7WtBlnlxYaTtisN6uZolPDqROtTdA2HN2wA2wj7rSkg0)jElad1IlPzPACrOUoADQvujTdAwQgxeQRJwZYFlP3gnlxY8YteiwHqmxYG4MOGyLG4Gqmv0hhWNMmbYfiprG4MqSsq8XbeZLmV8ebIvieZLmiUjkiwb0SdpTT0SurFSffBvmGqSi2RtTINPDqZs14IqDD0Aw(Bj92Oz5RS7ce5Bmjioie3ae7QEV((uCcSxaxYoFZRYaIpoG4o5QEVE3TOUQibUp1c6KR696vzaXnQzhEABPzfmSQSkgW)PiatJZuNAfvaTdAwQgxeQRJwZYFlP3gnlv0hhWNMmbYfiprG4MqmfH4QjbstMG4JdiMlzE5jceRqiMlzqm6OGyNA2HN2wA2RjsbyVGR6hqNAfJQ2bnlvJlc11rRzhEABPzFtyvmqOwaMgNPML)wsVnA2gG4CqOk9Ts2JyvmO)t8wagQfxYt14IqDioieZ3fPVTL)nHvXaHAbyACM(U6pPTfe3eI57I032Y3kzpIvXG(pXBbyOwCj)tYJvciomiwbG4gH4GqCdqmFxK(2w(RjsbyVGR6hW)K8yLaIBcXNbXhhqmxYG4MOG4OcXnQz5b4ieiNpMsHwrN6uRyuQDqZs14IqDD0Aw(Bj92OzDvVx)RkKSkgC(tNaTw199TT0SdpTT0SVQqYQyW5pDc0AvxNAfDKAh0SunUiuxhTML)wsVnAwUK5LNiqScHyUKbXnrbXo1SdpTT0SuegecqAEzDQv0rRDqZs14IqDD0A2HN2wA2RjsWEbPebALSKaPftVML)wsVnAwUK5LNiqScHyUKbXnrbXNPz5b4ieiNpMsHwrN6uR4PQDqZs14IqDD0Aw(Bj92Oz5sMxEIaXkeI5sge3efeRKMD4PTLMLlzax1xK6uROZW1oOzPACrOUoAnl)TKEB0SUQ3RpLiajZG(9fa(Wy4wUVxKdNje3eIDEQqCqiMk6Jd4ttMa5cKNiqCtiMIqC1KaPjtqScHyNqCqiMVlsFBl)1ePaSxWv9d4FsESsaXnHykcXvtcKMmPzhEABPz5)WzIyvm48NobqSyPSSkwNAfD6u7GMLQXfH66O1SdpTT0SPftpGXGiRz5VL0BJMLlzE5jceRqiMlzqCtuqSsqCqiUbi(CqCoiuLEjlb8v2D9unUiuhIpoGy(k7Uar(gtcIBuZYdWriqoFmLcTIo1PwrNkPDqZs14IqDD0Aw(Bj92Oz5sMxEIaXkeI5sge3efe7uZo802sZopFkcK7)uL6uROZZ0oOzPACrOUoAnl)TKEB0S8v2DbI8nMeeheIBaI57I032Y7Uf1vfjW9Pw)tYJvciUjeReeFCaXNdI5BiQMk9fX)fz)oe3ieheIBaI5sge3efehvi(4aI57I032YFnrka7fCv)a(NKhReqCtiokH4JdiMVlsFBl)1ePaSxWv9d4FsESsaXnH4ZG4GqmxYG4MOG4ZG4Gqmv0hhWNMmbYfe1WHy0HyNq8Xbetf9Xb8PjtGCbYteigDuqCdq8zqCyq8zqCuaI57I032YFnrka7fCv)a(NKhReqm6qCuH4gH4Jdi2v9E9ICFzanFkbMQdU2tEvgqCJA2HN2wAwbdRkRIb8FkcW04m1PwrNkG2bnlvJlc11rRz5VL0BJMLVYUlqKVXK0SdpTT0SCjd0oHiDQv0zu1oOzPACrOUoAn7WtBln7fjGvXab9mOkbmnotnl)TKEB0SUQ3R3Dzcy8l3332sZAvs)RYi1So1PwrNrP2bnlvJlc11rRzhEABPzDrgoZvnbmnotnl)TKEB0S8v2DbI8nMeeheIBaIDvVxV7YeW4xUxLbeFCaX5Gqv6LSeWxz31t14IqDioieZ4PqGyE370Nwm9agdImeheI5sgeJcIvcIdcX8Dr6BB5VMifG9cUQFa)tYJvcigDi(mi(4aI5sMxEIaXkeI5sgeJoki2jeheIz8uiqmV7D6fmSQSkgW)PiatJZeIdcXurFCaFAYeixG8ebIrhIpdIBuZYdWriqoFmLcTIo1Po1PMne9cBlTIkfUsodxbc)mnB78LvXcn75Xr50uXOifpnoDigIDqIGytMX(jeF3hIDClnm2sa2ly)o9ogIFsbPAp1HyXktq8OMR8KuhI5stftcpenfSveeR0PdXoITcrFsDi2X5Gqv6pfhdX5cXooheQs)P4PACrOUJH4jH4ZlhvkyiUbNrA0drtbBfbXND6qSJyRq0NuhIDCoiuL(tXXqCUqSJZbHQ0FkEQgxeQ7yiEsi(8YrLcgIBWzKg9q0uWwrqSsHF6qSJyRq0NuhIDCoiuL(tXXqCUqSJZbHQ0FkEQgxeQ7yiUbNrA0drdI25Xr50uXOifpnoDigIDqIGytMX(jeF3hIDSGEQSmGJH4NuqQ2tDiwSYeepQ5kpj1HyU0uXKWdrtbBfbXod)0HyhXwHOpPoe74CqOk9NIJH4CHyhNdcvP)u8unUiu3Xq8Kq85LJkfme3GZin6HO5GebX3fbzBTkgIh1FeqCl9eeRkOoeBfeNseep802cIrmrcXUQje3spbX1Mq8DvRoeBfeNseep9(wqCFYXDe0PdrdIvie7Uf1vfjW9PwqNCvVxiAq0opokNMkgfP4PXPdXqSdseeBYm2pH47(qSJ5DGGEQSmGJH4NuqQ2tDiwSYeepQ5kpj1HyU0uXKWdrtbBfbXN6PdXoITcrFsDi2XVAr39Jj)P4yioxi2XVAr39Jj)P4PACrOUJH4gCgPrpeniANhhLttfJIu8040Hyi2bjcInzg7Nq8DFi2XI0Xq8tkiv7PoelwzcIh1CLNK6qmxAQys4HOPGTIGyf40HyhXwHOpPoe74CqOk9NIJH4CHyhNdcvP)u8unUiu3XqCdoJ0OhIMc2kcIJYthIDeBfI(K6qSJZbHQ0FkogIZfIDCoiuL(tXt14IqDhdXn4msJEiAkyRii2PcC6qSJyRq0NuhIDCoiuL(tXXqCUqSJZbHQ0FkEQgxeQ7yiUbNrA0drZbjcIVlcY2AvmepQ)iG4w6jiwvqDi2kioLiiE4PTfeJyIeIDvtiULEcIRnH47QwDi2kioLiiE69TG4(KJ7iOthIgeRqi2DlQRksG7tTGo5QEVq0GODECuonvmksXtJthIHyhKii2KzSFcX39HyhZ7abDDme)Kcs1EQdXIvMG4rnx5jPoeZLMkMeEiAkyRiiwPthIDeBfI(K6qSJF1IU7ht(tXXqCUqSJF1IU7ht(tXt14IqDhdXn4msJEiAkyRii(SthIDeBfI(K6qSJF1IU7ht(tXXqCUqSJF1IU7ht(tXt14IqDhdXn4msJEiAoirq8Drq2wRIH4r9hbe3spbXQcQdXwbXPebXdpTTGyetKqSRAcXT0tqCTjeFx1QdXwbXPebXtVVfe3NCChbD6q0GyfcXUBrDvrcCFQf0jx17fIgeTZJJYPPIrrkEAC6qme7GebXMmJ9ti(Upe74oDhvK0Xq8tkiv7PoelwzcIh1CLNK6qmxAQys4HOPGTIGyLoDi2rSvi6tQdXooheQs)P4yioxi2X5Gqv6pfpvJlc1Dme3GZin6HOPGTIGyNHF6qSJyRq0NuhIDCoiuL(tXXqCUqSJZbHQ0FkEQgxeQ7yiEsi(8YrLcgIBWzKg9q0uWwrqStNNoe7i2ke9j1HyhNdcvP)uCmeNle74CqOk9NINQXfH6ogINeIpVCuPGH4gCgPrpenhKii(UiiBRvXq8O(JaIBPNGyvb1HyRG4uIG4HN2wqmIjsi2vnH4w6jiU2eIVRA1HyRG4uIG4P33cI7toUJGoDiAqScHy3TOUQibUp1c6KR69crdI25Xr50uXOifpnoDigIDqIGytMX(jeF3hID8SKJH4NuqQ2tDiwSYeepQ5kpj1HyU0uXKWdrtbBfbXr90HyhXwHOpPoe74CqOk9NIJH4CHyhNdcvP)u8unUiu3XqCdoJ0OhIMc2kcID680HyhXwHOpPoe74CqOk9NIJH4CHyhNdcvP)u8unUiu3XqCdoJ0OhIMc2kcIDgLNoe7i2ke9j1HyhNdcvP)uCmeNle74CqOk9NINQXfH6ogIBWzKg9q0CqIG47IGSTwfdXJ6pciULEcIvfuhITcItjcIhEABbXiMiHyx1eIBPNG4Ati(UQvhITcItjcINEFliUp54oc60HObXkeID3I6QIe4(ulOtUQ3leniArrYm2pPoeFQq8WtBligXePWdrtZoQP0(Awwt2rOzz871qin7P90cXNhR6Tdct6Hyh13IjeTt7PfIrtTiiwjhPYqSsHRKtiAq0oTNwi2HwAycXN3mrkG49cXN3u)aqSvj9VkJeIr2yJ7HODApTqSdT0WeIzzyvzvme7i(Pii(8UXzcXiBSX9q0oTNwi2rP3Hy3viUwSucXCjIZuaX5cXYtfaIDeoQbXuLVrcpeniAN2tleFEfH4Qj1Hyx6UpbX8v2Dsi2LITs4HyhfoNyKciU2sHsZlFvrG4HN2wciElKaEiAdpTTeEgpXxz3jdd1jUBMiuhCrMauV1QyqUrScI2WtBlHNXt8v2DYWqDsO5TXfHuUgzcvevQaBbufeiFRysPYlduckvo0GOsOifKQXGb19wj4VAoUieqbPovQkd6uiJthhKcs1yWG6(yKPBtUVa4o9y64GuqQgdgu33(tkjYTOJdsbPAmyqD)gIEU08XuhmLjpa3jt6dCCqkivJbdQ7fstFBJ)rWaKBsYq0gEABj8mEIVYUtggQt4sgWv9fPY2f15YbHQ0lONkld4PACrO(XX5YbHQ0Fnrc2liLiqRKLeiTy69unUiuhI2WtBlHNXt8v2DYWqDcxYaTtisz7I6C5Gqv6PI(ylk2QyaHyrO3t14IqDiAq0oTNwi(8kcXvtQdXui6daXPjtqCkrq8WZ9HytaXtOXqgxeYdrB4PTLaLGbnpqAQoqKVXKGOn802segQtcnVnUiKY1itOKwKoiIkvkVmqjOu5qdIkHIVlsFBlVvHwMeiIkvGuIaTswsG0IP3)K8yLO51ILsWtYJvIJJRflLGNKhRekKVlsFBlVvHwMeiIkvGuIaTswsG0IP3)K8yLaDNkfEWgAiheQsVGEQSmqWRflLGNKhRen57I032YlONkld4FsESseKVlsFBlVGEQSmG)j5XkrtNH34Xrd8Dr6BB5f5(YaA(ucmvhCTN8xveeWtCP5JjqAYe6xlwkbpjpwjcY3fPVTLxK7ldO5tjWuDW1EYFvrqapXLMpMaPjtnDg1gpoAGVlsFBlVi3xgqZNsGP6GR9KNlnFmjqfEq(Ui9TT8ICFzanFkbMQdU2t(NKhReOFTyPe8K8yLOXgHOn802segQtySPTLY2fvdUQ3RxqpvwgWRY44Wv9E9ICFzanFkbMQdU2tEvgngKbL(iQubsjc0kzjbslME)WtleDC4UcrWRflLGNKhReOJkkdhI2WtBlryOoHpiiGHN2waetKkxJmHsqpvwgqz7IYv9E9c6PYYaEvgq0gEABjcd1j8bbbm802cGyIu5AKjuT0WylbyVG970RSDr5QEV(wAySLaSxW(D69QmGOn802segQt4dccy4PTfaXePY1itOwgurVY2fvAYe6kqqUKHEudEogu6JOsfiLiqRKLeiTy69dpTqeeTHN2wIWqDY1ejyVGuIaTswsG0IPxzEaocbY5JPuGYPY2ffxY8YtefYLSMOolydurFCaFAYeixG8ebDNhhurFCaFAYeixG8ebDfiiFxK(2w(RjsbyVGR6hW)K8yLaDN(OECW3fPVTLVLggBja7fSFNE)tYJvc0vQXGNRtUQ3R3DlQRksG7tTGo5QEVEvgq0gEABjcd1juegecqAEzLTlkUK5LNikKlznr5mydurFCaFAYeixG8ebDNhh8Dr6BB5f0tLLb8pjpwjqxPJdQOpoGpnzcKlqEIGUceKVlsFBl)1ePaSxWv9d4FsESsGUtFupo47I032Y3sdJTeG9c2VtV)j5Xkb6k1yWZ5QEVE3TOUQibUp16vzarB4PTLimuNKwm9agdISY8aCecKZhtPaLtLTlk(k7Uar(gtkixY8YtefYLSMOukydurFCaFAYeixG8ebDNhh8Dr6BB5f0tLLb8pjpwjqxPJdQOpoGpnzcKlqEIGUceKVlsFBl)1ePaSxWv9d4FsESsGUtFupo47I032Y3sdJTeG9c2VtV)j5Xkb6k1yWZ1jx1717Uf1vfjW9PwqNCvVxVkdiAdpTTeHH6e(GGagEABbqmrQCnYekEhiORY2f15YbHQ0lONkldarB4PTLimuNWheeWWtBlaIjsLRrMqX7ab9uzzaLTlQCqOk9c6PYYaq0gEABjcd1j8bbbm802cGyIu5AKjuIuz7IA4PfIaurYgjq)miAdpTTeHH6e(GGagEABbqmrQCnYeQzjLTlQHNwicqfjBKOjQZGObrB4PTLWplHQvYEeRIb9FI3cWqT4sq0gEABj8ZsHH6eQOp2IITkgqiwe7v2UO4sMxEIOqUK1eLsbPI(4a(0KjqUa5jstLoo4sMxEIOqUK1eLcarB4PTLWplfgQtemSQSkgW)PiatJZuz7IIVYUlqKVXKc2GR6967tXjWEbCj78nVkJJJo5QEVE3TOUQibUp1c6KR696vz0ieTHN2wc)SuyOo5AIua2l4Q(bu2UOOI(4a(0KjqUa5jstkcXvtcKMmDCWLmV8erHCjdDuoHOn802s4NLcd1jVjSkgiulatJZuzEaocbY5JPuGYPY2fvd5Gqv6BLShXQyq)N4TamulUuq(Ui9TT8VjSkgiulatJZ03v)jTTAY3fPVTLVvYEeRIb9FI3cWqT4s(NKhReHPangSb(Ui9TT8xtKcWEbx1pG)j5XkrZZoo4swturTriAdpTTe(zPWqDYRkKSkgC(tNaTw1v2UOCvVx)RkKSkgC(tNaTw199TTGOn802s4NLcd1juegecqAEzLTlkUK5LNikKlznr5eI2WtBlHFwkmuNCnrc2liLiqRKLeiTy6vMhGJqGC(ykfOCQSDrXLmV8erHCjRjQZGOn802s4NLcd1jCjd4Q(Iuz7IIlzE5jIc5swtukbrB4PTLWplfgQt4)WzIyvm48NobqSyPSSkwz7IYv9E9Pebizg0VVaWhgd3Y99IC4mB68udsf9Xb8PjtGCbYtKMueIRMeinzsHodY3fPVTL)AIua2l4Q(b8pjpwjAsriUAsG0KjiAdpTTe(zPWqDsAX0dymiYkZdWriqoFmLcuov2UO4sMxEIOqUK1eLsbB4C5Gqv6LSeWxz394GVYUlqKVXKAeI2WtBlHFwkmuNmpFkcK7)uLkBxuCjZlpruixYAIYjeTHN2wc)SuyOorWWQYQya)NIamnotLTlk(k7Uar(gtkyd8Dr6BB5D3I6QIe4(uR)j5XkrtLooohFdr1uPVi(Vi73BmydCjRjQOECW3fPVTL)AIua2l4Q(b8pjpwjAgLhh8Dr6BB5VMifG9cUQFa)tYJvIMNfKlznrDwqQOpoGpnzcKliQHJUZJdQOpoGpnzcKlqEIGoQgolSZIc8Dr6BB5VMifG9cUQFa)tYJvc0JAJhhUQ3RxK7ldO5tjWuDW1EYRYOriAdpTTe(zPWqDcxYaTtisz7IIVYUlqKVXKGOn802s4NLcd1jxKawfde0ZGQeW04mv2UOCvVxV7YeW4xUVVTLYwL0)QmsuoHOn802s4NLcd1jUidN5QMaMgNPY8aCecKZhtPaLtLTlk(k7Uar(gtkydUQ3R3Dzcy8l3RY44iheQsVKLa(k7Ubz8uiqmV7D6tlMEaJbroixYqPuq(Ui9TT8xtKcWEbx1pG)j5Xkb6NDCWLmV8erHCjdDuodY4PqGyE370lyyvzvmG)traMgNzqQOpoGpnzcKlqEIG(zncrdI2WtBlHN3bc6IYQqltcerLkqkrGwjljqAX0RSDrDUqZBJlc5LwKoiIkvbBGVlsFBl)BcRIbc1cW04m9pjpwjqxPJJZX3qunv6zg4TPAmydNJVHOAQ0xe)xK97hh8Dr6BB5D3I6QIe4(uR)j5Xkb6k14XX1ILsWtYJvc0vkQq0gEABj88oqq3WqDsUQCjWEbDAsjLTlQRflLGNKhRenBWPJoCf(QfD3pM83jheqUQCPOGtLcVXJdx171lY9Lb08PeyQo4Ap57BBfKbL(iQubsjc0kzjbslME)WtleDC4UcrWRflLGNKhReO7mCiAdpTTeEEhiOByOoPLggBja7fSFNELTlQg(X6akevPF6DH3QMkqupo(X6akevPF6DHxLrJb57I032Y)MWQyGqTamnot)tYJvc0PiexnjqAYuq(Ui9TT8wfAzsGiQubsjc0kzjbslME)tYJvIMnOu4HPu4rHxTO7(XK3Qqlt6fGoHyXszJhhURqe8AXsj4j5Xkb6NfviAdpTTeEEhiOByOo5oeIveqKRmdLTlk(k7Uar(gtkyd)yDafIQ0p9UWBvtNHFC8J1buiQs)07cVkJgHOn802s45DGGUHH6K7GGqfy)o9kBxu)yDafIQ0p9UWBvZZc)44hRdOquL(P3fEvgq0gEABj88oqq3WqDI7wuxvKa3NAv2UO4swtukf8AXsj4j5XkrZOm8GnW3fPVTLxK7ldO5tjWuDW1EYZLMpMend)4GVlsFBlVi3xgqZNsGP6GR9K)j5XkrtNH3yWgyqPpIkvGuIaTswsG0IP3p80crhh8Dr6BB5Tk0YKaruPcKseOvYscKwm9(NKhRenDg(XrO5TXfH8slsherLQgpoAGlznrPuWRflLGNKhReOJkkdpydmO0hrLkqkrGZJKLeiTy69dpTq0XbFxK(2wERcTmjqevQaPebALSKaPftV)j5XkrZRflLGNKhRengSb(Ui9TT8ICFzanFkbMQdU2tEU08XKOz4hh8Dr6BB5f5(YaA(ucmvhCTN8pjpwjAETyPe8K8yL44Wv9E9ICFzanFkbMQdU2tEvgn24XX1ILsWtYJvc0DgviAdpTTeEEhiOByOorK7ldO5tjWuDW1EcCTitskBxu8T6Qw657(DRMK6G9EPsyHipvJlc1HOn802s45DGGUHH6erUVmGMpLat1bx7jLTlk(Ui9TT8ICFzanFkbMQdU2tEU08XKaLshhxlwkbpjpwjqxPWpoA4hRdOquL(P3f(NKhRenDg1JJgohFdr1uPNzG3Mk454BiQMk9fX)fz)EJbBOHFSoGcrv6NEx4TQjFxK(2wErUVmGMpLat1bx7j)vfbb8exA(ycKMmDCCUFSoGcrv6NEx4PiMifngSb(Ui9TT8wfAzsGiQubsjc0kzjbslME)tYJvIM8Dr6BB5f5(YaA(ucmvhCTN8xveeWtCP5JjqAY0XrO5TXfH8slsherLQgBmiFxK(2w(RjsbyVGR6hW)K8yLaDuNAqUK1eLsb57I032Y3kzpIvXG(pXBbyOwCj)tYJvc0r5uPgHOn802s45DGGUHH6erUVmGMpLat1bx7jLTlk(gIQPspZaVnvWgCvVxFlnm2sa2ly)o9EvghhnCTyPe8K8yLaD(Ui9TT8T0WylbyVG9707FsESsCCW3fPVTLVLggBja7fSFNE)tYJvIM8Dr6BB5f5(YaA(ucmvhCTN8xveeWtCP5JjqAYuJb57I032YFnrka7fCv)a(NKhReOJ6udYLSMOukiFxK(2w(wj7rSkg0)jElad1Il5FsESsGokNk1ieTHN2wcpVde0nmuNiY9Lb08PeyQo4ApPSDrX3qunv6lI)lY(9GDYv9E9UBrDvrcCFQf0jx171RYiydmO0hrLkqkrGwjljqAX07hEAHOJJqZBJlc5LwKoiIkvhh8Dr6BB5Tk0YKaruPcKseOvYscKwm9(NKhRen57I032YlY9Lb08PeyQo4Ap5VQiiGN4sZhtG0KPJd(Ui9TT8wfAzsGiQubsjc0kzjbslME)tYJvIMNfEJq0gEABj88oqq3WqDIvc(RMJlcbuqQtLQYGofY4KY2ffdk9ruPcKseOvYscKwm9(HNwi64WDfIGxlwkbpjpwjqxPWHOn802s45DGGUHH6K2FsjrUfPSDrXGsFevQaPebALSKaPftVF4PfIooCxHi41ILsWtYJvc0vkCiAdpTTeEEhiOByOojgz62K7laUtpMu2UOyqPpIkvGuIaTswsG0IP3p80crhhURqe8AXsj4j5Xkb6kfoeTHN2wcpVde0nmuNOkiGLKSY1itO6pn9R9eiejeeIY2f15cnVnUiKpIkvGTaQccKVvmP84GVlsFBlVvHwMeiIkvGuIaTswsG0IP3)K8yLOPsHhKbL(iQubsjc0kzjbslME)tYJvc0vk8JJqZBJlc5LwKoiIkvq0gEABj88oqq3WqDIQGawsYcLTlQZfAEBCriFevQaBbufeiFRys5XbFxK(2wERcTmjqevQaPebALSKaPftV)j5XkrtLc)4i0824IqEPfPdIOsfeTHN2wcpVde0nmuNKRkxcSxaZ5LhLTlQRflLGNKhRenp1WpoyqPpIkvGuIaTswsG0IP3p80crhhHM3gxeYlTiDqevQooCxHi41ILsWtYJvc0DgLq0gEABj88oqq3WqDIlYUDWv9dOSDrX3fPVTL3QqltcerLkqkrGwjljqAX07FsESs08SWpocnVnUiKxAr6GiQuDC4UcrWRflLGNKhReORu4q0gEABj88oqq3WqDIl9c6zAvSY2ffFxK(2wERcTmjqevQaPebALSKaPftV)j5XkrZZc)4i0824IqEPfPdIOs1XH7kebVwSucEsESsGUZOcrB4PTLWZ7abDdd1jiwSukaNVApwMQeI2WtBlHN3bc6ggQtU2tUi72v2UO47I032YBvOLjbIOsfiLiqRKLeiTy69pjpwjAEw4hhHM3gxeYlTiDqevQooCxHi41ILsWtYJvc0DgoeTHN2wcpVde0nmuNmfNe5pia(GGOSDrX3fPVTL3QqltcerLkqkrGwjljqAX07FsESs08SWpocnVnUiKxAr6GiQuDC4UcrWRflLGNKhReORu4q0gEABj88oqq3WqDI7ed2liFJZuOSDr5QEVErUVmGMpLat1bx7jFFBliAq0gEABj88oqqpvwgavO5TXfHuUgzcLGEQSmaWv9fPYlduckvo0GOsO47I032YlONkld4FsESsGUZJdgu6JOsfiLiqRKLeiTy69dpTquq(Ui9TT8c6PYYa(NKhRenpl8Jd3vicETyPe8K8yLaDLchI2WtBlHN3bc6PYYaHH6eRcTmjqevQaPebALSKaPftVY2f15cnVnUiKxAr6GiQuDC4UcrWRflLGNKhReORuuHOn802s45DGGEQSmqyOoXfz3o4Q(bu2UOcnVnUiKxqpvwga4Q(IeI2WtBlHN3bc6PYYaHH6ex6f0Z0QyLTlQqZBJlc5f0tLLbaUQViHOn802s45DGGEQSmqyOobXILsb48v7XYuLq0gEABj88oqqpvwgimuNCTNCr2TRSDrfAEBCriVGEQSmaWv9fjeTHN2wcpVde0tLLbcd1jtXjr(dcGpiikBxuHM3gxeYlONkldaCvFrcrB4PTLWZ7ab9uzzGWqDI7ed2liFJZuOSDrfAEBCriVGEQSmaWv9fjeTHN2wcpVde0tLLbcd1j5QYLa7f0PjLu2UOUwSucEsESs0SbNo6Wv4Rw0D)yYFNCqa5QYLIcovk8gpoyqPpIkvGuIaTswsG0IP3p80crhhURqe8AXsj4j5Xkb6odhI2WtBlHN3bc6PYYaHH6KCv5sG9cyoV8OSDrDTyPe8K8yLO5Pg(Xbdk9ruPcKseOvYscKwm9(HNwi64WDfIGxlwkbpjpwjq3z4q0gEABj88oqqpvwgimuN0sdJTeG9c2VtVY2ffFxK(2w(3ewfdeQfGPXz6FsESsGofH4QjbstMGOn802s45DGGEQSmqyOoXkb)vZXfHaki1PsvzqNczCsz7Ik0824IqEb9uzzaGR6lsiAdpTTeEEhiONkldegQtA)jLe5wKY2fvO5TXfH8c6PYYaax1xKq0gEABj88oqqpvwgimuNeJmDBY9fa3PhtkBxuHM3gxeYlONkldaCvFrcrB4PTLWZ7ab9uzzGWqDIQGawsYcLTlQZfAEBCriFevQaBbufeiFRys5XbFxK(2wERcTmjqevQaPebALSKaPftV)j5XkrtLc)4i0824IqEPfPdIOsfeTHN2wcpVde0tLLbcd1j3HqSIaICLzarB4PTLWZ7ab9uzzGWqDYDqqOcSFNEiAdpTTeEEhiONkldegQtC3I6QIe4(uRY2fL7kebVwSucEsESsGUZOEC0axYAIsPGnCTyPe8K8yLOzugEWgAGVlsFBlVGEQSmG)j5XkrtNHFC4QEVEb9uzzaVkJJd(Ui9TT8c6PYYaEvgngSbgu6JOsfiLiqRKLeiTy69dpTq0XbFxK(2wERcTmjqevQaPebALSKaPftV)j5XkrtNHFCeAEBCriV0I0bruPQXgB84OHRflLGNKhReOJkkdpydmO0hrLkqkrGZJKLeiTy69dpTq0XbFxK(2wERcTmjqevQaPebALSKaPftV)j5XkrZRflLGNKhRen2yJq0gEABj88oqqpvwgimuNiONkldOSDrX3fPVTL)nHvXaHAbyACM(NKhReOR0XH7kebVwSucEsESsGUZOcrB4PTLWZ7ab9uzzGWqDI7ed2liFJZuardI2WtBlHFzqf9OUMib7fKseOvYscKwm9kZdWriqo)htPaLtLTlkUK5LNikKlznrDgeTHN2wc)YGk6dd1juegecqAEzLTlQCqOk9Cjd4Q(I0t14Iq9GCjZlpruixYAI6miAdpTTe(Lbv0hgQtslMEaJbrwzEaocbY5JPuGYPY2ffFLDxGiFJjfKlzE5jIc5swtukbrB4PTLWVmOI(WqDcxYaTtisz7IIlzE5jIc5sgkLGOn802s4xgurFyOoHIWGqasZldrB4PTLWVmOI(WqDsAX0dymiYkZdWriqoFmLcuov2UO4sMxEIOqUK1eLsq0GOn802s4f0tLLbqDnrka7fCv)akBxuUQ3RxqpvwgW)K8yLaDNq0gEABj8c6PYYaHH6ebdRkRIb8FkcW04mv2UO4RS7ce5BmPGnm80craQizJenrD2XXWtlebOIKns00zWZX3fPVTL)nHvXaHAbyACMEvgncrB4PTLWlONkldegQtEtyvmqOwaMgNPY8aCecKZhtPaLtLTlk(k7Uar(gtcI2WtBlHxqpvwgimuNCnrka7fCv)akBxudpTqeGks2irtuNbrB4PTLWlONkldegQtemSQSkgW)PiatJZuz7IIVYUlqKVXKc6QEV((uCcSxaxYoFZRYaI2WtBlHxqpvwgimuN4ImCMRAcyACMkZdWriqoFmLcuov2UO4RS7ce5BmPGUQ3RVLggBja7fSFNEVkJG8Dr6BB5FtyvmqOwaMgNP)j5XkrtLGOn802s4f0tLLbcd1jxtKcWEbx1pGYwL0)QmsGDr5QEVEb9uzzaVkJG8Dr6BB5FtyvmqOwaMgNP)PPhaI2WtBlHxqpvwgimuNiyyvzvmG)traMgNPY2ffFLDxGiFJjfStUQ3R3DlQRksG7tTGo5QEVEvgq0gEABj8c6PYYaHH6KRjsWEbPebALSKaPftVY8aCecKZhtPaLtLTlkUKH(zq0gEABj8c6PYYaHH6exKHZCvtatJZuzEaocbY5JPuGYPY2ffFLDxGiFJjDCCUCqOk9swc4RS7crB4PTLWlONkldegQtemSQSkgW)PiatJZeIgeTHN2wcVir1kzpIvXG(pXBbyOwCjLTlQFSoGcrv6NEx4TQjFxK(2w(wj7rSkg0)jElad1Il57Q)K2wrHW9o6JJFSoGcrv6NEx4vzarB4PTLWlYWqDcv0hBrXwfdielI9kBxuCjZlpruixYAIsPGurFCaFAYeixG8eP5zhhCjZlpruixYAIsbc2av0hhWNMmbYfiprAQ0XX5y8uiqmV7D6tlMEaJbrUriAdpTTeErggQtemSQSkgW)PiatJZuz7IIVYUlqKVXKc6QEV((uCcSxaxYoFZRYiyd)yDafIQ0p9UWBvtx1713NItG9c4s25B(NKhRekuPJJFSoGcrv6NEx4vz0ieTHN2wcVidd1jVjSkgiulatJZuzEaocbY5JPuGYPY2ffFxK(2wEb9uzza)tYJvIMopooxoiuLEb9uzzGGnW3fPVTLVLggBja7fSFNE)tYJvIMkWXX54BiQMk9md82uncrB4PTLWlYWqDY1ePaSxWv9dOSDr1WpwhqHOk9tVl8w1KVlsFBl)1ePaSxWv9d47Q)K2wrHW9o6JJFSoGcrv6NEx4vz0yWgOI(4a(0KjqUa5jstkcXvtcKMmPqNhhCjZlpruixYqhLZJdx171lY9Lb08PeyQo4Ap5FsESsGofH4QjbstMcZzJhhxlwkbpjpwjqNIqC1KaPjtH584OtUQ3R3DlQRksG7tTGo5QEVEvgq0gEABj8ImmuNW)HZeXQyW5pDcGyXszzvSY2fLR696tjcqYmOFFbGpmgUL77f5Wz205PgKk6Jd4ttMa5cKNinPiexnjqAYKcDgKVlsFBl)BcRIbc1cW04m9pjpwjAsriUAsG0KPJdx171NseGKzq)(caFymCl33lYHZSPtfiyd8Dr6BB5f0tLLb8pjpwjqpQbZbHQ0lONkldCCW3fPVTLVLggBja7fSFNE)tYJvc0JAq(gIQPspZaVn1XX1ILsWtYJvc0JAJq0gEABj8ImmuN8QcjRIbN)0jqRvDLTlkx171)QcjRIbN)0jqRvDFFBRGdpTqeGks2irtNq0gEABj8ImmuNCnrc2liLiqRKLeiTy6vMhGJqGC(ykfOCQSDrXLm0pdI2WtBlHxKHH6ekcdcbinVSY2ffxY8YtefYLSMOCcrB4PTLWlYWqDcxYaUQViv2UO4sMxEIOqUK1eLZGdpTqeGks2ibkNb)X6akevPF6DH3QMkf(XbxY8YtefYLSMOuk4WtlebOIKns0eLsq0gEABj8ImmuNWLmq7eIGOn802s4fzyOojTy6bmgezL5b4ieiNpMsbkNkBxu8v2DbI8nMuqUK5LNikKlznrPuqx171lY9Lb08PeyQo4Ap57BBbrB4PTLWlYWqDIGHvLvXa(pfbyACMkBxuUQ3RNlzaQOpoGxKdNzZZcxHrnkm80craQizJebDvVxVi3xgqZNsGP6GR9KVVTvWg47I032Y)MWQyGqTamnot)tYJvIMkfKVlsFBl)1ePaSxWv9d4FsESs0uPJd(Ui9TT8VjSkgiulatJZ0)K8yLa9ZcY3fPVTL)AIua2l4Q(b8pjpwjAEwqUK18SJd(Ui9TT8VjSkgiulatJZ0)K8yLO5zb57I032YFnrka7fCv)a(NKhReOFwqUK1uboo4sMxEIOqUKHokNbPI(4a(0KjqUa5jc6k14XHR6965sgGk6Jd4f5Wz20z4bVwSucEsESsGUJeI2WtBlHxKHH6exKHZCvtatJZuzEaocbY5JPuGYPY2ffFLDxGiFJjfSHCqOk9c6PYYab57I032YlONkld4FsESsG(zhh8Dr6BB5FtyvmqOwaMgNP)j5XkrtNb57I032YFnrka7fCv)a(NKhRenDECW3fPVTL)nHvXaHAbyACM(NKhReOFwq(Ui9TT8xtKcWEbx1pG)j5XkrZZcYLSMkDCW3fPVTL)nHvXaHAbyACM(NKhRenpliFxK(2w(RjsbyVGR6hW)K8yLa9ZcYLSMNDCWLSMr94Wv9E9UltaJF5EvgncrB4PTLWlYWqDsAX0dymiYkZdWriqoFmLcuov2UO4RS7ce5BmPGCjZlpruixYAIsjiAdpTTeErggQtMNpfbY9FQsLTlkUK5LNikKlznr5eI2WtBlHxKHH6KlsaRIbc6zqvcyACMkBvs)RYir5eI2WtBlHxKHH6exKHZCvtatJZuzEaocbY5JPuGYPY2ffFLDxGiFJjfKVlsFBl)1ePaSxWv9d4FsESsG(zb5sgkLcY4PqGyE370Nwm9agdICqQOpoGpnzcKliQHJUtiAdpTTeErggQtCrgoZvnbmnotL5b4ieiNpMsbkNkBxu8v2DbI8nMuqQOpoGpnzcKlqEIGUsbBGlzE5jIc5sg6OCECW4PqGyE370Nwm9agdICJq0GOn802s4BPHXwcWEb73PhvO5TXfHuUgzcLlYWzUQjGPXzckI6ux5LbkbLkhAqujuUQ3RVLggBja7fSFNEqBR)j5XkrWg47I032Y)MWQyGqTamnot)tYJvIMUQ3RVLggBja7fSFNEqBR)j5Xkrqx1713sdJTeG9c2VtpOT1)K8yLaDL8opo47I032Y)MWQyGqTamnot)tYJvcf6QEV(wAySLaSxW(D6bTT(NKhRenD6p1GUQ3RVLggBja7fSFNEqBR)j5Xkb6kG35XHR696Dr2TJOksVkJGUQ3R3Qqlt6fGoHyXsPxLrqx171BvOLj9cqNqSyP0)K8yLaDx1713sdJTeG9c2VtpOT1)K8yLOriAdpTTe(wAySLaSxW(D6dd1j8bbbm802cGyIu5AKju8oqqxLTlQZLdcvPxqpvwgaI2WtBlHVLggBja7fSFN(WqDcFqqadpTTaiMivUgzcfVde0tLLbu2UOYbHQ0lONkldarB4PTLW3sdJTeG9c2VtFyOoHk6JTOyRIbeIfXELTlkUK5LNikKlznrPuqQOpoGpnzcKlqEI08miAdpTTe(wAySLaSxW(D6dd1jVjSkgiulatJZuzEaocbY5JPuGYjeTHN2wcFlnm2sa2ly)o9HH6KRjsbyVGR6hqz7IA4PfIaurYgjAIsPGUQ3RVLggBja7fSFNEqBR)j5Xkb6oHOn802s4BPHXwcWEb73PpmuNqryqiaP5Lv2UO4sgQWd6QEV(wAySLaSxW(D6bTT(NKhReORaq0gEABj8T0WylbyVG970hgQtUMib7fKseOvYscKwm9kZdWriqoFmLcuov2UO4sgQWd6QEV(wAySLaSxW(D6bTT(NKhReORaq0gEABj8T0WylbyVG970hgQtALShXQyq)N4TamulUeeTHN2wcFlnm2sa2ly)o9HH6K0IPhWyqKvMhGJqGC(ykfOCQSDrXLmuHh0v9E9T0WylbyVG970dAB9pjpwjqxbGOn802s4BPHXwcWEb73PpmuNiyyvzvmG)traMgNPY2ffFLDxGiFJjfC4PfIaurYgjAI6SGUQ3RVLggBja7fSFNEqBRxLbeTHN2wcFlnm2sa2ly)o9HH6exKHZCvtatJZuzEaocbY5JPuGYPY2ffFLDxGiFJjfC4PfIaurYgjqhLsbdnVnUiK3fz4mx1eW04mbfrDQdrB4PTLW3sdJTeG9c2VtFyOorWWQYQya)NIamnotLTlk(k7Uar(gtkOR6967tXjWEbCj78nVkdiAdpTTe(wAySLaSxW(D6dd1jTs2JyvmO)t8wagQfxcI2WtBlHVLggBja7fSFN(WqDY1ePaSxWv9dOSvj9VkJeyxuUQ3RVLggBja7fSFNEqBRxLHY2fLR696f5(YaA(ucmvhCTN8Qmc(J1buiQs)07cVvn57I032YFnrka7fCv)a(U6pPTvuiCFucrB4PTLW3sdJTeG9c2VtFyOorWWQYQya)NIamnotLTlkx171ZLmav0hhWlYHZS5zHRWOgfgEAHiavKSrciAdpTTe(wAySLaSxW(D6dd1jxtKG9csjc0kzjbslMEL5b4ieiNpMsbkNkBxuCjd9ZGOn802s4BPHXwcWEb73PpmuNqryqiaP5Lv2UO4sMxEIOqUK1eLtiAdpTTe(wAySLaSxW(D6dd1jCjd4Q(Iuz7IIlzE5jIc5swtun4mSHNwicqfjBKOPZgHOn802s4BPHXwcWEb73PpmuNKwm9agdISY8aCecKZhtPaLtLTlQgoxoiuLEjlb8v2Dpo4RS7ce5BmPgdYLmV8erHCjRjkLGOn802s4BPHXwcWEb73PpmuN4ImCMRAcyACMkZdWriqoFmLcuov2UOgEAHiavKSrc0rDwqUK1e1zhhUQ3RVLggBja7fSFNEqBRxLbeTHN2wcFlnm2sa2ly)o9HH6eUKbANqeeTHN2wcFlnm2sa2ly)o9HH6KlsaRIbc6zqvcyACMkBvs)RYir5uN6uRb]] )


end