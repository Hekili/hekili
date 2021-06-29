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


    spec:RegisterPack( "Windwalker", 20210628, [[dSK1BcqiLu5rkjjBsaFIOuJsk4usHwfvG8kbLzru1TOcAxu1VusmmbvhJkAzefptjLPruIRjK02es03usvmoQa6CkjL1PKunpus3dr2Nu0bPcuwOqQhsusnrQav5IkjrTrLuLYhvsvYjvscwjkXlvsvQMjrj5MubQQDsu5NubQSuLKqpfftLk0xvssnwHe2lP(lWGr6Wkwmv6XOAYs1LH2Ss9zHA0K40uwTsQQxJsnBeUnr2TKFRQHJOoovawUkpNW0fDDsA7cY3LsJxioVaTELKiZxj2pO1o1oQz6tIA5KjCzCgEukJd0lZAR5mCzrZKbjJAgYdN9eJAMAKqnZQ2QE7qWgpnd5jiXpDTJAgXRECuZOzCvnICvO0UAM(KOwozcxgNHhLY4a9YS2Aod3PMrqg5A5KjkxnnJI17yPD1mDuW1mRAR6TdbB8Guh8)InKfwulesLXbkpKkt4Y4eYcKfhBXHnKUEZePas)nKUEt9ccPwL4DQKtiL4JnUhYIJT4WgsziBvzvmKkRVPqiD9UXzdPeFSX9qwCW6Di19fITfRKqkxb5SfqA(qQ0ubHuzTdEqkw5zOWRzimrk0oQzEYyHN2rTCo1oQzWACjWUoAnZWt7lnZ2ej43GubbTkwIG0IXtZWplXZgndxX8stei1HqkxXG0MKG010m8GCceKZDXyk0mo1Pwoz0oQzWACjWUoAnd)SepB0m5qGv65kgWv9ePhRXLa7qAaiLRyEPjcK6qiLRyqAtsq6AAMHN2xAgmczKaOmNKo1YTM2rndwJlb21rRzgEAFPzslgpa5HqsZWplXZgnd)LCFGipJncPbGuUI5LMiqQdHuUIbPnjbPYOz4b5eiiNlgtHwoN6ulNSODuZG14sGDD0Ag(zjE2Oz4kMxAIaPoes5kgKscsLrZm80(sZWvmq7ec1PwUOQDuZm80(sZGriJeaL5K0mynUeyxhTo1YfLAh1mynUeyxhTMz4P9LMjTy8aKhcjnd)SepB0mCfZlnrGuhcPCfdsBscsLrZWdYjqqoxmMcTCo1Po1mT4q(lb43G)64PDulNtTJAgSgxcSRJwZ8K1mcm1mdpTV0mHMZgxcuZeAiurnJR6E7BXH8xcWVb)1Xd026puASsaPbG0gGu()e9VT8NjSkgiulaBJZ2FO0yLasBcPUQ7TVfhYFja)g8xhpqBR)qPXkbKgasDv3BFloK)sa(n4VoEG2w)HsJvciLvivgVtiDzbs5)t0)2YFMWQyGqTaSnoB)HsJvci1HqQR6E7BXH8xcWVb)1Xd026puASsaPnHuN(vdsdaPUQ7TVfhYFja)g8xhpqBR)qPXkbKYkKklENq6YcK6QU3ExI)7eQI0RsgsdaPUQ7T3QqpB8eGosyXkPxLmKgasDv3BVvHE24jaDKWIvs)HsJvciLvi1vDV9T4q(lb43G)64bAB9hknwjG0g1mHMduJeQzCjgo7xnbSnoBqHyh76ulNmAh1mynUeyxhTMHFwINnAM1bP5qGv6f4HLLb9ynUeyxZm80(sZWhccWWt7laHjsndHjsqnsOMH3bcCRtTCRPDuZG14sGDD0Ag(zjE2OzYHaR0lWdlld6XACjWUMz4P9LMHpeeGHN2xactKAgctKGAKqndVde4HLLb1Pwozr7OMbRXLa76O1m8Zs8SrZWvmV0ebsDiKYvmiTjjivginaKIfEXb9PjHG8bsteiTjKUMMz4P9LMbl8ITvjRIbiHfXoDQLlQAh1mynUeyxhTMz4P9LM5mHvXaHAbyBC2AgEqobcY5IXuOLZPo1YfLAh1mynUeyxhTMHFwINnAMHNwieGfkzOasBscsLbsdaPUQ7TVfhYFja)g8xhpqBR)qPXkbKYkK6uZm80(sZSnrka)gSvVG6ul36r7OMbRXLa76O1m8Zs8SrZm80cHaSqjdfqAtsqQmAMHN2xAMwf7iSkg0Vj(laz1IROtTCoqTJAgSgxcSRJwZWplXZgnd)LCFGipJncPbG0HNwieGfkzOasBscsxdsdaPUQ7TVfhYFja)g8xhpqBRxLSMz4P9LMrq2QYQya)McbSnoBDQLB10oQzWACjWUoAnZWt7lnJlXWz)QjGTXzRz4NL4zJMH)sUpqKNXgH0aq6WtlecWcLmuaPSscsLbsdaPHMZgxc07smC2VAcyBC2GcXo21m8GCceKZfJPqlNtDQLZz4Ah1mynUeyxhTMHFwINnAg(l5(arEgBesdaPUQ7TVpfhb)gWvS138QK1mdpTV0mcYwvwfd43uiGTXzRtTCoDQDuZG14sGDD0Ag(zjE2Oz4kgKscsdhsdaPUQ7TVfhYFja)g8xhpqBR)qPXkbKYkKklAMHN2xAgmczKaOmNKo1Y5ugTJAgSgxcSRJwZm80(sZSnrc(nivqqRILiiTy80m8Zs8SrZWvmiLeKgoKgasDv3BFloK)sa(n4VoEG2w)HsJvciLvivw0m8GCceKZfJPqlNtDQLZ5AAh1mdpTV0mTk2ryvmOFt8xaYQfxrZG14sGDD06ulNtzr7OMbRXLa76O1mdpTV0mPfJhG8qiPz4NL4zJMHRyqkjinCinaK6QU3(wCi)La8BWFD8aTT(dLgReqkRqQSOzY5IXeyBntyqAdqAhDv3BVGDWdhUcaJOmQI0(YRsgsDqqQmHdPnQtTCoJQ2rndwJlb21rRz4NL4zJMXvDV9I8pjaoxQaMQd22HEvYqAai9gRdWqyL(P3fERG0Mqk)FI(3w(Tjsb43GT6f03vVjTVGuheKgUpk1mdpTV0mBtKcWVbB1lOMXQeVtLCcSTMXvDV9T4q(lb43G)64bAB9QK1PwoNrP2rndwJlb21rRz4NL4zJMXvDV9CfdGfEXb9IC4SH0Mq6AHdPoesJkK6GG0HNwieGfkzOqZm80(sZiiBvzvmGFtHa2gNTo1Y5C9ODuZG14sGDD0AMHN2xAMTjsWVbPccAvSebPfJNMHFwINnAgUIbPScPRPz4b5eiiNlgtHwoN6ulNthO2rndwJlb21rRz4NL4zJMHRyEPjcK6qiLRyqAtsqQtnZWt7lndgHmsauMtsNA5CUAAh1mynUeyxhTMHFwINnAgUI5LMiqQdHuUIbPnjbPnaPoH0WG0HNwieGfkzOasBcPoH0g1mdpTV0mCfd4QEIuNA5KjCTJAgSgxcSRJwZm80(sZKwmEaYdHKMHFwINnAMgG01bP5qGv6vSeWFj33J14sGDiDzbs5VK7de5zSriTrinaKYvmV0ebsDiKYvmiTjjivgndpiNab5CXyk0Y5uNA5KXP2rndwJlb21rRzgEAFPzCjgo7xnbSnoBnd)SepB0mdpTqialuYqbKYkjiDninaKYvmiTjjiDniDzbsDv3BFloK)sa(n4VoEG2wVkzndpiNab5CXyk0Y5uNA5KrgTJAMHN2xAgUIbANqOMbRXLa76O1Pwozwt7OMXQeVtLCQzCQzgEAFPz2ebTkgiWJmwjGTXzRzWACjWUoADQtnJapSSmO2rTCo1oQzWACjWUoAnd)SepB0mUQ7TxGhwwg0FO0yLaszfsDQzgEAFPz2MifGFd2QxqDQLtgTJAgSgxcSRJwZWplXZgnd)LCFGipJncPbG0gG0HNwieGfkzOasBscsxdsxwG0HNwieGfkzOasBcPoH0aq66Gu()e9VT8NjSkgiulaBJZ2RsgsBuZm80(sZiiBvzvmGFtHa2gNTo1YTM2rndwJlb21rRzgEAFPzotyvmqOwa2gNTMHFwINnAg(l5(arEgBuZWdYjqqoxmMcTCo1Pwozr7OMbRXLa76O1m8Zs8SrZm80cHaSqjdfqAtsq6AAMHN2xAMTjsb43GT6fuNA5IQ2rndwJlb21rRz4NL4zJMH)sUpqKNXgH0aqQR6E77tXrWVbCfB9nVkznZWt7lnJGSvLvXa(nfcyBC26ulxuQDuZG14sGDD0AMHN2xAgxIHZ(vtaBJZwZWplXZgnd)LCFGipJncPbGux1923Id5VeGFd(RJNxLmKgas5)t0)2YFMWQyGqTaSnoB)HsJvciTjKkJMHhKtGGCUymfA5CQtTCRhTJAgRs8ovYjW2Agx192lWdlld6vjhG)pr)Bl)zcRIbc1cW24S9ho9GAMHN2xAMTjsb43GT6fuZG14sGDD06ulNdu7OMbRXLa76O1m8Zs8SrZWFj3hiYZyJqAaiTJUQ7T39lSRksG7HTGo6QU3EvYAMHN2xAgbzRkRIb8BkeW24S1PwUvt7OMbRXLa76O1mdpTV0mBtKGFdsfe0Qyjcslgpnd)SepB0mCfdszfsxtZWdYjqqoxmMcTCo1PwoNHRDuZG14sGDD0AMHN2xAgxIHZ(vtaBJZwZWplXZgnd)LCFGipJncPllq66G0CiWk9kwc4VK77XACjWUMHhKtGGCUymfA5CQtTCoDQDuZm80(sZiiBvzvmGFtHa2gNTMbRXLa76O1Po1m8oqGhwwgu7OwoNAh1mynUeyxhTM5jRzeyQzgEAFPzcnNnUeOMj0qOIAg()e9VT8c8WYYG(dLgReqkRqQtiDzbsjJPpIkwGubbTkwIG0IXZp80cHqAaiL)pr)BlVapSSmO)qPXkbK2esxlCiDzbsDFHasdaPBlwjbhknwjGuwHuzcxZeAoqnsOMrGhwwge4QEIuNA5Kr7OMbRXLa76O1m8Zs8SrZSoin0C24sGELNOdIOIfKUSaPUVqaPbG0TfRKGdLgReqkRqQmrvZm80(sZyvONncIOILo1YTM2rndwJlb21rRz4NL4zJMj0C24sGEbEyzzqGR6jsnZWt7lnJlX)DWw9cQtTCYI2rndwJlb21rRz4NL4zJMj0C24sGEbEyzzqGR6jsnZWt7lnJlEc8yBvSo1YfvTJAMHN2xAgclwjfG1xThlHvQzWACjWUoADQLlk1oQzWACjWUoAnd)SepB0mHMZgxc0lWdlldcCvprQzgEAFPz22HUe)31PwU1J2rndwJlb21rRz4NL4zJMj0C24sGEbEyzzqGR6jsnZWt7lnZuCuK3qa4dbHo1Y5a1oQzWACjWUoAnd)SepB0mHMZgxc0lWdlldcCvprQzgEAFPzCNyWVb5zC2cDQLB10oQzWACjWUoAnd)SepB0mBlwjbhknwjG0MqAdqQthy4qQdH0tTW9FXOFp5qaYxLR4XACjWoK6GGuNYeoK2iKUSaPKX0hrflqQGGwflrqAX45hEAHqiDzbsDFHasdaPBlwjbhknwjGuwHuNHRzgEAFPzYxLRa(nOJtQOtTCodx7OMbRXLa76O1m8Zs8SrZSTyLeCO0yLasBcPRw4q6YcKsgtFevSaPccAvSebPfJNF4PfcH0Lfi19fcinaKUTyLeCO0yLaszfsDgUMz4P9LMjFvUc43a2Zjn6ulNtNAh1mynUeyxhTMHFwINnAg()e9VT8NjSkgiulaBJZ2FO0yLaszfsXiixnrqAsOMz4P9LMPfhYFja)g8xhpDQLZPmAh1mynUeyxhTMHFwINnAMqZzJlb6f4HLLbbUQNi1mdpTV0mwj4NAoUeiWbOovQkb6yiJJ6ulNZ10oQzWACjWUoAnd)SepB0mHMZgxc0lWdlldcCvprQzgEAFPzAVjve5xOo1Y5uw0oQzWACjWUoAnd)SepB0mHMZgxc0lWdlldcCvprQzgEAFPzIjMUn5FcG70JrDQLZzu1oQzWACjWUoAnd)SepB0mRdsdnNnUeOpIkwGVaQceKNvSXesxwGu()e9VT8wf6zJGiQybsfe0Qyjcslgp)HsJvciTjKkt4q6YcKgAoBCjqVYt0bruXsZm80(sZOkqGLOKqNA5CgLAh1mdpTV0m7bjScbI8LiRzWACjWUoADQLZ56r7OMz4P9LMzpeeyb(RJNMbRXLa76O1PwoNoqTJAgSgxcSRJwZWplXZgnJ7leqAaiDBXkj4qPXkbKYkK6mQq6YcK2aKYvmiTjjivginaK2aKUTyLeCO0yLasBcPrz4qAaiTbiTbiL)pr)BlVapSSmO)qPXkbK2esDgoKUSaPUQ7TxGhwwg0RsgsxwGu()e9VT8c8WYYGEvYqAJqAaiTbiLmM(iQybsfe0Qyjcslgp)WtlecPllqk)FI(3wERc9SrqevSaPccAvSebPfJN)qPXkbK2esDgoKUSaPHMZgxc0R8eDqevSG0gH0gH0gH0LfiTbiDBXkj4qPXkbKYkjinkdhsdaPnaPKX0hrflqQGGvTILiiTy88dpTqiKUSaP8)j6FB5Tk0ZgbruXcKkiOvXseKwmE(dLgReqAtiDBXkj4qPXkbK2iK2iK2OMz4P9LMX9lSRksG7HT6ulNZvt7OMbRXLa76O1m8Zs8SrZW)NO)TL)mHvXaHAbyBC2(dLgReqkRqQmq6YcK6(cbKgas3wSscouASsaPScPoJQMz4P9LMrGhwwguNA5KjCTJAMHN2xAg3jg8BqEgNTqZG14sGDD06ulNmo1oQzWACjWUoAnd)SepB0mIxLW1QUNSQivjqaEQKt7lpwJlb2H0aqQR6E7f4HLLb99VTG0aqAhDv3BV7xyxvKa3dBbD0vDV99VT0mdpTV0mBcuOWVzN6uNAgrQDulNtTJAgSgxcSRJwZWplXZgnZnwhGHWk9tVl8wbPnHu()e9VT8Tk2ryvmOFt8xaYQfxX3vVjTVGuheKgU3bcPllq6nwhGHWk9tVl8QK1mdpTV0mTk2ryvmOFt8xaYQfxrNA5Kr7OMbRXLa76O1m8Zs8SrZWvmV0ebsDiKYvmiTjjivginaKIfEXb9PjHG8bsteiTjKUgKUSaPCfZlnrGuhcPCfdsBscsLfinaK2aKIfEXb9PjHG8bsteiTjKkdKUSaPRdsjFyiqmV7D6tlgpa5HqcsBuZm80(sZGfEX2QKvXaKWIyNo1YTM2rndwJlb21rRz4NL4zJMH)sUpqKNXgH0aqQR6E77tXrWVbCfB9nVkzinaK2aKEJ1byiSs)07cVvqAti1vDV99P4i43aUIT(M)qPXkbK6qivgiDzbsVX6amewPF6DHxLmK2OMz4P9LMrq2QYQya)McbSnoBDQLtw0oQzWACjWUoAnZWt7lnZzcRIbc1cW24S1m8Zs8SrZW)NO)TLxGhwwg0FO0yLasBcPoH0LfiDDqAoeyLEbEyzzqpwJlb2H0aqAdqk)FI(3w(wCi)La8BWFD88hknwjG0MqQSaPllq66Gu(hcRPsp7GNnfK2OMHhKtGGCUymfA5CQtTCrv7OMbRXLa76O1m8Zs8SrZ0aKEJ1byiSs)07cVvqAtiL)pr)Bl)2ePa8BWw9c67Q3K2xqQdcsd37aH0Lfi9gRdWqyL(P3fEvYqAJqAaiTbifl8Id6ttcb5dKMiqAtifJGC1ebPjHqQdHuNq6YcKYvmV0ebsDiKYvmiLvsqQtiDzbsDv3BVi)tcGZLkGP6GTDO)qPXkbKYkKIrqUAIG0Kqinmi1jK2iKUSaPBlwjbhknwjGuwHumcYvteKMecPHbPoH0LfiTJUQ7T39lSRksG7HTGo6QU3EvYAMHN2xAMTjsb43GT6fuNA5IsTJAgSgxcSRJwZWplXZgnJR6E7tfeGsKX7pbGpKhUL)5f5WzdPnHuNRgKgasXcV4G(0Kqq(aPjcK2esXiixnrqAsiK6qi1jKgas5)t0)2YFMWQyGqTaSnoB)HsJvciTjKIrqUAIG0KqiDzbsDv3BFQGauImE)ja8H8WT8pVihoBiTjK6uwG0aqAdqk)FI(3wEbEyzzq)HsJvciLvinQqAainhcSsVapSSmOhRXLa7q6YcKY)NO)TLVfhYFja)g8xhp)HsJvciLvinQqAaiL)HWAQ0Zo4ztbPllq62IvsWHsJvciLvinQqAJAMHN2xAg(nC2ewfdw)PJaclwjlRI1PwU1J2rndwJlb21rRz4NL4zJMXvDV9NQqXQyW6pDe0Av33)2csdaPdpTqialuYqbK2esDQzgEAFPzovHIvXG1F6iO1QUo1Y5a1oQzWACjWUoAnZWt7lnZ2ej43GubbTkwIG0IXtZWplXZgndxXGuwH010m8GCceKZfJPqlNtDQLB10oQzWACjWUoAnd)SepB0mCfZlnrGuhcPCfdsBscsDQzgEAFPzWiKrcGYCs6ulNZW1oQzWACjWUoAnd)SepB0mCfZlnrGuhcPCfdsBscsDcPbG0HNwieGfkzOasjbPoH0aq6nwhGHWk9tVl8wbPnHuzchsxwGuUI5LMiqQdHuUIbPnjbPYaPbG0HNwieGfkzOasBscsLrZm80(sZWvmGR6jsDQLZPtTJAMHN2xAgUIbANqOMbRXLa76O1PwoNYODuZG14sGDD0AMHN2xAM0IXdqEiK0m8Zs8SrZWFj3hiYZyJqAaiLRyEPjcK6qiLRyqAtsqQmqAai1vDV9I8pjaoxQaMQd22H((3wAgEqobcY5IXuOLZPo1Y5CnTJAgSgxcSRJwZWplXZgnJR6E75kgal8Id6f5WzdPnH01chsDiKgvi1bbPdpTqialuYqbKgasDv3BVi)tcGZLkGP6GTDOV)TfKgasBas5)t0)2YFMWQyGqTaSnoB)HsJvciTjKkdKgas5)t0)2YVnrka)gSvVG(dLgReqAtivgiDzbs5)t0)2YFMWQyGqTaSnoB)HsJvciLviDninaKY)NO)TLFBIua(nyREb9hknwjG0Mq6AqAaiLRyqAtiDniDzbs5)t0)2YFMWQyGqTaSnoB)HsJvciTjKUgKgas5)t0)2YVnrka)gSvVG(dLgReqkRq6AqAaiLRyqAtivwG0LfiLRyEPjcK6qiLRyqkRKGuNqAaifl8Id6ttcb5dKMiqkRqQmqAJq6YcK6QU3EUIbWcV4GEroC2qAti1z4qAaiDBXkj4qPXkbKYkKUE0mdpTV0mcYwvwfd43uiGTXzRtTCoLfTJAgSgxcSRJwZm80(sZ4smC2VAcyBC2Ag(zjE2Oz4VK7de5zSrinaK2aKMdbwPxGhwwg0J14sGDinaKY)NO)TLxGhwwg0FO0yLaszfsxdsxwGu()e9VT8NjSkgiulaBJZ2FO0yLasBcPoH0aqk)FI(3w(Tjsb43GT6f0FO0yLasBcPoH0LfiL)pr)Bl)zcRIbc1cW24S9hknwjGuwH01G0aqk)FI(3w(Tjsb43GT6f0FO0yLasBcPRbPbGuUIbPnHuzG0LfiL)pr)Bl)zcRIbc1cW24S9hknwjG0Mq6AqAaiL)pr)Bl)2ePa8BWw9c6puASsaPScPRbPbGuUIbPnH01G0LfiLRyqAtinQq6YcK6QU3E3NnG89CVkziTrndpiNab5CXyk0Y5uNA5CgvTJAgSgxcSRJwZm80(sZKwmEaYdHKMHFwINnAg(l5(arEgBesdaPCfZlnrGuhcPCfdsBscsLrZWdYjqqoxmMcTCo1PwoNrP2rndwJlb21rRz4NL4zJMHRyEPjcK6qiLRyqAtsqQtnZWt7lnZC8Pqq(3HvQtTCoxpAh1mwL4DQKtnJtnZWt7lnZMiOvXabEKXkbSnoBndwJlb21rRtTCoDGAh1mynUeyxhTMz4P9LMXLy4SF1eW24S1m8Zs8SrZWFj3hiYZyJqAaiL)pr)Bl)2ePa8BWw9c6puASsaPScPRbPbGuUIbPKGuzG0aqk5ddbI5DVtFAX4bipesqAaifl8Id6ttcb5dIA4qkRqQtndpiNab5CXyk0Y5uNA5CUAAh1mynUeyxhTMz4P9LMXLy4SF1eW24S1m8Zs8SrZWFj3hiYZyJqAaifl8Id6ttcb5dKMiqkRqQmqAaiTbiLRyEPjcK6qiLRyqkRKGuNq6YcKs(WqGyE370NwmEaYdHeK2OMHhKtGGCUymfA5CQtDQz4DGa3Ah1Y5u7OMbRXLa76O1m8Zs8SrZSoin0C24sGELNOdIOIfKgasBas5)t0)2YFMWQyGqTaSnoB)HsJvciLvivgiDzbsxhKY)qynv6zh8SPG0gH0aqAdq66Gu(hcRPsFH87j(RdPllqk)FI(3wE3VWUQibUh26puASsaPScPYaPncPllq62IvsWHsJvciLvivMOQzgEAFPzSk0ZgbruXsNA5Kr7OMbRXLa76O1m8Zs8SrZSTyLeCO0yLasBcPnaPoDGHdPoesp1c3)fJ(9KdbiFvUIhRXLa7qQdcsDkt4qAJq6YcK6QU3Er(NeaNlvat1bB7qF)BlinaKsgtFevSaPccAvSebPfJNF4PfcH0Lfi19fcinaKUTyLeCO0yLaszfsDgUMz4P9LMjFvUc43GooPIo1YTM2rndwJlb21rRz4NL4zJMPbi9gRdWqyL(P3fERG0MqQSeviDzbsVX6amewPF6DHxLmK2iKgas5)t0)2YFMWQyGqTaSnoB)HsJvciLvifJGC1ebPjHqAaiL)pr)BlVvHE2iiIkwGubbTkwIG0IXZFO0yLasBcPnaPYeoKggKkt4qQdcsp1c3)fJERc9SXta6iHfRKESgxcSdPncPllqQ7leqAaiDBXkj4qPXkbKYkKUwu1mdpTV0mT4q(lb43G)64PtTCYI2rndwJlb21rRz4NL4zJMH)sUpqKNXgH0aqAdq6nwhGHWk9tVl8wbPnHuNHdPllq6nwhGHWk9tVl8QKH0g1mdpTV0m7bjScbI8LiRtTCrv7OMbRXLa76O1m8Zs8SrZCJ1byiSs)07cVvqAtiDTWH0Lfi9gRdWqyL(P3fEvYAMHN2xAM9qqGf4VoE6ulxuQDuZG14sGDD0Ag(zjE2Oz4kgK2KeKkdKgas3wSscouASsaPnH0OmCinaK2aKY)NO)TLxK)jbW5sfWuDW2o0ZvMlgfqAtinCiDzbs5)t0)2YlY)Ka4CPcyQoyBh6puASsaPnHuNHdPncPbG0gGuYy6JOIfivqqRILiiTy88dpTqiKUSaP8)j6FB5Tk0ZgbruXcKkiOvXseKwmE(dLgReqAti1z4q6YcKgAoBCjqVYt0bruXcsBesxwG0gGuUIbPnjbPYaPbG0TfRKGdLgReqkRKG0OmCinaK2aKsgtFevSaPccw1kwIG0IXZp80cHq6YcKY)NO)TL3QqpBeerflqQGGwflrqAX45puASsaPnH0TfRKGdLgReqAJqAaiTbiL)pr)BlVi)tcGZLkGP6GTDONRmxmkG0MqA4q6YcKY)NO)TLxK)jbW5sfWuDW2o0FO0yLasBcPBlwjbhknwjG0Lfi1vDV9I8pjaoxQaMQd22HEvYqAJqAJq6YcKUTyLeCO0yLaszfsDgvnZWt7lnJ7xyxvKa3dB1PwU1J2rndwJlb21rRz4NL4zJMH)vx1sp))RB1Kyh87nwcle6XACjWUMz4P9LMrK)jbW5sfWuDW2oeSTitI6ulNdu7OMbRXLa76O1m8Zs8SrZW)NO)TLxK)jbW5sfWuDW2o0ZvMlgfqkjivgiDzbs3wSscouASsaPScPYeoKUSaPnaP3yDagcR0p9UWFO0yLasBcPoJkKUSaPnaPRds5FiSMk9SdE2uqAaiDDqk)dH1uPVq(9e)1H0gH0aqAdqAdq6nwhGHWk9tVl8wbPnHu()e9VT8I8pjaoxQaMQd22H(Tkbb4qUYCXiinjesxwG01bP3yDagcR0p9UWJrmrkG0gH0aqAdqk)FI(3wERc9SrqevSaPccAvSebPfJN)qPXkbK2es5)t0)2YlY)Ka4CPcyQoyBh63QeeGd5kZfJG0KqiDzbsdnNnUeOx5j6GiQybPncPncPbGu()e9VT8BtKcWVbB1lO)qPXkbKYkjiD1G0aqkxXG0MKGuzG0aqk)FI(3w(wf7iSkg0Vj(laz1IR4puASsaPSscsDkdK2OMz4P9LMrK)jbW5sfWuDW2ouNA5wnTJAgSgxcSRJwZWplXZgnd)dH1uPNDWZMcsdaPnaPUQ7TVfhYFja)g8xhpVkziDzbsBas3wSscouASsaPScP8)j6FB5BXH8xcWVb)1XZFO0yLasxwGu()e9VT8T4q(lb43G)645puASsaPnHu()e9VT8I8pjaoxQaMQd22H(Tkbb4qUYCXiinjesBesdaP8)j6FB53MifGFd2Qxq)HsJvciLvsq6QbPbGuUIbPnjbPYaPbGu()e9VT8Tk2ryvmOFt8xaYQfxXFO0yLaszLeK6ugiTrnZWt7lnJi)tcGZLkGP6GTDOo1Y5mCTJAgSgxcSRJwZWplXZgnd)dH1uPVq(9e)1H0aqAhDv3BV7xyxvKa3dBbD0vDV9QKH0aqAdqkzm9ruXcKkiOvXseKwmE(HNwiesxwG0qZzJlb6vEIoiIkwq6YcKY)NO)TL3QqpBeerflqQGGwflrqAX45puASsaPnHu()e9VT8I8pjaoxQaMQd22H(Tkbb4qUYCXiinjesxwGu()e9VT8wf6zJGiQybsfe0Qyjcslgp)HsJvciTjKUw4qAJAMHN2xAgr(NeaNlvat1bB7qDQLZPtTJAgSgxcSRJwZWplXZgndzm9ruXcKkiOvXseKwmE(HNwiesxwGu3xiG0aq62IvsWHsJvciLvivMW1mdpTV0mwj4NAoUeiWbOovQkb6yiJJ6ulNtz0oQzWACjWUoAnd)SepB0mKX0hrflqQGGwflrqAX45hEAHqiDzbsDFHasdaPBlwjbhknwjGuwHuzcxZm80(sZ0EtQiYVqDQLZ5AAh1mynUeyxhTMHFwINnAgYy6JOIfivqqRILiiTy88dpTqiKUSaPUVqaPbG0TfRKGdLgReqkRqQmHRzgEAFPzIjMUn5FcG70JrDQLZPSODuZG14sGDD0AMHN2xAM(HtFBhccHcbsOz4NL4zJMzDqAO5SXLa9ruXc8fqvGG8SInMq6YcKY)NO)TL3QqpBeerflqQGGwflrqAX45puASsaPnHuzchsdaPKX0hrflqQGGwflrqAX45puASsaPScPYeoKUSaPHMZgxc0R8eDqevS0m1iHAM(HtFBhccHcbsOtTCoJQ2rndwJlb21rRz4NL4zJMzDqAO5SXLa9ruXc8fqvGG8SInMq6YcKY)NO)TL3QqpBeerflqQGGwflrqAX45puASsaPnHuzchsxwG0qZzJlb6vEIoiIkwAMHN2xAgvbcSeLe6ulNZOu7OMbRXLa76O1m8Zs8SrZSTyLeCO0yLasBcPRw4q6YcKsgtFevSaPccAvSebPfJNF4PfcH0Lfin0C24sGELNOdIOIfKUSaPUVqaPbG0TfRKGdLgReqkRqQZOuZm80(sZKVkxb8Ba75KgDQLZ56r7OMbRXLa76O1m8Zs8SrZW)NO)TL3QqpBeerflqQGGwflrqAX45puASsaPnH01chsxwG0qZzJlb6vEIoiIkwq6YcK6(cbKgas3wSscouASsaPScPYeUMz4P9LMXL4)oyREb1PwoNoqTJAgSgxcSRJwZWplXZgnd)FI(3wERc9SrqevSaPccAvSebPfJN)qPXkbK2esxlCiDzbsdnNnUeOx5j6GiQybPllqQ7leqAaiDBXkj4qPXkbKYkK6mQAMHN2xAgx8e4X2QyDQLZ5QPDuZm80(sZqyXkPaS(Q9yjSsndwJlb21rRtTCYeU2rndwJlb21rRz4NL4zJMH)pr)BlVvHE2iiIkwGubbTkwIG0IXZFO0yLasBcPRfoKUSaPHMZgxc0R8eDqevSG0Lfi19fcinaKUTyLeCO0yLaszfsDgUMz4P9LMzBh6s8FxNA5KXP2rndwJlb21rRz4NL4zJMH)pr)BlVvHE2iiIkwGubbTkwIG0IXZFO0yLasBcPRfoKUSaPHMZgxc0R8eDqevSG0Lfi19fcinaKUTyLeCO0yLaszfsLjCnZWt7lnZuCuK3qa4dbHo1YjJmAh1mynUeyxhTMHFwINnAgx192lY)Ka4CPcyQoyBh67FBPzgEAFPzCNyWVb5zC2cDQLtM10oQzWACjWUoAnd)SepB0mIxLW1QUNSQivjqaEQKt7lpwJlb2H0aqQR6E7f5FsaCUubmvhSTd99VTG0aqAhDv3BV7xyxvKa3dBbD0vDV99VT0mdpTV0mBcuOWVzN6uNAMoUhvIu7OwoNAh1mdpTV0mcY4CaLP6arEgBuZG14sGDD06ulNmAh1mynUeyxhTM5jRzeyQzgEAFPzcnNnUeOMj0qOIAg()e9VT8wf6zJGiQybsfe0Qyjcslgp)HsJvciTjKUTyLeCO0yLasxwG0TfRKGdLgReqQdHu()e9VT8wf6zJGiQybsfe0Qyjcslgp)HsJvciLvi1PmHdPbG0gG0gG0CiWk9c8WYYGESgxcSdPbG0TfRKGdLgReqAtiL)pr)BlVapSSmO)qPXkbKgas5)t0)2YlWdlld6puASsaPnHuNHdPncPllqAdqk)FI(3wEr(NeaNlvat1bB7q)wLGaCixzUyeKMecPScPBlwjbhknwjG0aqk)FI(3wEr(NeaNlvat1bB7q)wLGaCixzUyeKMecPnHuNrfsBesxwG0gGu()e9VT8I8pjaoxQaMQd22HEUYCXOasjbPHdPbGu()e9VT8I8pjaoxQaMQd22H(dLgReqkRq62IvsWHsJvciTriTrntO5a1iHAgLNOdIOILo1YTM2rndwJlb21rRz4NL4zJMPbi1vDV9c8WYYGEvYq6YcK6QU3Er(NeaNlvat1bB7qVkziTrinaKsgtFevSaPccAvSebPfJNF4PfcH0Lfi19fcinaKUTyLeCO0yLaszLeKgLHRzgEAFPzi)P9Lo1YjlAh1mynUeyxhTMHFwINnAgx192lWdlld6vjRzgEAFPz4dbby4P9fGWePMHWejOgjuZiWdlldQtTCrv7OMbRXLa76O1m8Zs8SrZ4QU3(wCi)La8BWFD88QK1mdpTV0m8HGam80(cqyIuZqyIeuJeQzAXH8xcWVb)1XtNA5IsTJAgSgxcSRJwZWplXZgntAsiKYkKklqAaiLRyqkRqAuH0aq66GuYy6JOIfivqqRILiiTy88dpTqOMz4P9LMHpeeGHN2xactKAgctKGAKqnZtgl80PwU1J2rndwJlb21rRzgEAFPz2Mib)gKkiOvXseKwmEAg(zjE2Oz4kMxAIaPoes5kgK2KeKUgKgasBasXcV4G(0Kqq(aPjcKYkK6esxwGuSWloOpnjeKpqAIaPScPYcKgas5)t0)2YVnrka)gSvVG(dLgReqkRqQtFuH0LfiL)pr)BlFloK)sa(n4VoE(dLgReqkRqQmqAJqAaiDDqAhDv3BV7xyxvKa3dBbD0vDV9QK1m8GCceKZfJPqlNtDQLZbQDuZG14sGDD0Ag(zjE2Oz4kMxAIaPoes5kgK2KeK6esdaPnaPyHxCqFAsiiFG0ebszfsDcPllqk)FI(3wEbEyzzq)HsJvciLvivgiDzbsXcV4G(0Kqq(aPjcKYkKklqAaiL)pr)Bl)2ePa8BWw9c6puASsaPScPo9rfsxwGu()e9VT8T4q(lb43G)645puASsaPScPYaPncPbG01bPUQ7T39lSRksG7HTEvYAMHN2xAgmczKaOmNKo1YTAAh1mynUeyxhTMz4P9LMjTy8aKhcjnd)SepB0m8xY9bI8m2iKgas5kMxAIaPoes5kgK2KeKkdKgasBasXcV4G(0Kqq(aPjcKYkK6esxwGu()e9VT8c8WYYG(dLgReqkRqQmq6YcKIfEXb9PjHG8bsteiLvivwG0aqk)FI(3w(Tjsb43GT6f0FO0yLaszfsD6JkKUSaP8)j6FB5BXH8xcWVb)1XZFO0yLaszfsLbsBesdaPRds7OR6E7D)c7QIe4EylOJUQ7TxLSMHhKtGGCUymfA5CQtTCodx7OMbRXLa76O1m8Zs8SrZSoinhcSsVapSSmOhRXLa7AMHN2xAg(qqagEAFbimrQzimrcQrc1m8oqGBDQLZPtTJAgSgxcSRJwZWplXZgntoeyLEbEyzzqpwJlb21mdpTV0m8HGam80(cqyIuZqyIeuJeQz4DGapSSmOo1Y5ugTJAgSgxcSRJwZWplXZgnZWtlecWcLmuaPScPRPzgEAFPz4dbby4P9fGWePMHWejOgjuZisDQLZ5AAh1mynUeyxhTMHFwINnAMHNwieGfkzOasBscsxtZm80(sZWhccWWt7laHjsndHjsqnsOMzEuN6uZq(q(l5oP2rTCo1oQzgEAFPzC)mjWoytmbXERvXG8JyLMbRXLa76O1Pwoz0oQzWACjWUoAnZtwZiWuZm80(sZeAoBCjqntOHqf1mOdq1itg7ERe8tnhxce4auNkvLaDmKXriDzbsrhGQrMm29Xet3M8pbWD6XiKUSaPOdq1itg7(2Bsfr(fcPllqk6aunYKXU)dHhxzUySdMYKgG7KjEbH0LfifDaQgzYy3luM(3gFJGmi)eL0mHMduJeQzIOIf4lGQab5zfBm1PwU10oQzWACjWUoAnd)SepB0mRdsZHaR0lWdlld6XACjWoKUSaPRdsZHaR0Vnrc(nivqqRILiiTy88ynUeyxZm80(sZWvmGR6jsDQLtw0oQzWACjWUoAnd)SepB0mRdsZHaR0JfEX2QKvXaKWIGNhRXLa7AMHN2xAgUIbANqOo1PMzEu7OwoNAh1mdpTV0mTk2ryvmOFt8xaYQfxrZG14sGDD06ulNmAh1mynUeyxhTMHFwINnAgUI5LMiqQdHuUIbPnjbPYaPbGuSWloOpnjeKpqAIaPnHuzG0LfiLRyEPjcK6qiLRyqAtsqQSOzgEAFPzWcVyBvYQyasyrStNA5wt7OMbRXLa76O1m8Zs8SrZWFj3hiYZyJqAaiTbi1vDV99P4i43aUIT(MxLmKUSaPD0vDV9UFHDvrcCpSf0rx192RsgsBuZm80(sZiiBvzvmGFtHa2gNTo1YjlAh1mynUeyxhTMHFwINnAgSWloOpnjeKpqAIaPnHumcYvteKMecPllqkxX8stei1HqkxXGuwjbPo1mdpTV0mBtKcWVbB1lOo1YfvTJAgSgxcSRJwZm80(sZCMWQyGqTaSnoBnd)SepB0mnaP5qGv6BvSJWQyq)M4VaKvlUIhRXLa7qAaiL)pr)Bl)zcRIbc1cW24S9D1Bs7liTjKY)NO)TLVvXocRIb9BI)cqwT4k(dLgReqAyqQSaPncPbG0gGu()e9VT8BtKcWVbB1lO)qPXkbK2esxdsxwGuUIbPnjbPrfsBuZWdYjqqoxmMcTCo1PwUOu7OMbRXLa76O1m8Zs8SrZ4QU3(tvOyvmy9NocATQ77FBPzgEAFPzovHIvXG1F6iO1QUo1YTE0oQzWACjWUoAnd)SepB0mCfZlnrGuhcPCfdsBscsDQzgEAFPzWiKrcGYCs6ulNdu7OMbRXLa76O1mdpTV0mBtKGFdsfe0Qyjcslgpnd)SepB0mCfZlnrGuhcPCfdsBscsxtZWdYjqqoxmMcTCo1PwUvt7OMbRXLa76O1m8Zs8SrZWvmV0ebsDiKYvmiTjjivgnZWt7lndxXaUQNi1PwoNHRDuZG14sGDD0Ag(zjE2OzCv3BFQGauImE)ja8H8WT8pVihoBiTjK6C1G0aqkw4fh0NMecYhinrG0Mqkgb5QjcstcHuhcPoH0aqk)FI(3w(Tjsb43GT6f0FO0yLasBcPyeKRMiinjuZm80(sZWVHZMWQyW6pDeqyXkzzvSo1Y50P2rndwJlb21rRzgEAFPzslgpa5HqsZWplXZgndxX8stei1HqkxXG0MKGuzG0aqAdq66G0CiWk9kwc4VK77XACjWoKUSaP8xY9bI8m2iK2OMHhKtGGCUymfA5CQtTCoLr7OMbRXLa76O1m8Zs8SrZWvmV0ebsDiKYvmiTjji1PMz4P9LMzo(uii)7Wk1PwoNRPDuZG14sGDD0Ag(zjE2Oz4VK7de5zSrinaK2aKY)NO)TL39lSRksG7HT(dLgReqAtivgiDzbsxhKY)qynv6lKFpXFDiTrinaK2aKYvmiTjjinQq6YcKY)NO)TLFBIua(nyREb9hknwjG0MqAucPllqk)FI(3w(Tjsb43GT6f0FO0yLasBcPRbPbGuUIbPnjbPRbPbGuSWloOpnjeKpiQHdPScPoH0Lfifl8Id6ttcb5dKMiqkRKG0gG01G0WG01GuheKY)NO)TLFBIua(nyREb9hknwjGuwH0OcPncPllqQR6E7f5FsaCUubmvhSTd9QKH0g1mdpTV0mcYwvwfd43uiGTXzRtTCoLfTJAgSgxcSRJwZWplXZgnd)LCFGipJnQzgEAFPz4kgODcH6ulNZOQDuZG14sGDD0AMHN2xAMnrqRIbc8iJvcyBC2Ag(zjE2OzCv3BV7Zgq(EUV)TLMXQeVtLCQzCQtTCoJsTJAgSgxcSRJwZm80(sZ4smC2VAcyBC2Ag(zjE2Oz4VK7de5zSrinaK2aK6QU3E3NnG89CVkziDzbsZHaR0RyjG)sUVhRXLa7qAaiL8HHaX8U3PpTy8aKhcjinaKYvmiLeKkdKgas5)t0)2YVnrka)gSvVG(dLgReqkRq6Aq6YcKYvmV0ebsDiKYvmiLvsqQtinaKs(WqGyE370liBvzvmGFtHa2gNnKgasXcV4G(0Kqq(aPjcKYkKUgK2OMHhKtGGCUymfA5CQtDQtnti8e2xA5KjCzCgEukZ6rZ0oxzvSqZSQDWwfLBvqU1RvhsHuhvqi1Ki)xcP7)Guz3Id5VeGFd(RJNSH0dDaQ2HDiv8siKoQ5lnj2HuUYuXOWdzrwzfcPYS6qQS(Rq4LyhsLDoeyL(Oq2qA(qQSZHaR0hfESgxcSlBiDsiDv2bNScsBWzKg9qwKvwHq6ARoKkR)keEj2HuzNdbwPpkKnKMpKk7CiWk9rHhRXLa7YgsNesxLDWjRG0gCgPrpKfzLviK6uwwDiDveL(qyhsLSA1JciLRGC2qAd1Nq6eAmIXLaHuRGuusLys7RgH0gCgPrpKfzLviKkt4RoKkR)keEj2HuzNdbwPpkKnKMpKk7CiWk9rHhRXLa7YgsBWzKg9qwGSSQDWwfLBvqU1RvhsHuhvqi1Ki)xcP7)GuzlWdlldkBi9qhGQDyhsfVecPJA(stIDiLRmvmk8qwKvwHqQZWxDivw)vi8sSdPYohcSsFuiBinFiv25qGv6JcpwJlb2LnKojKUk7GtwbPn4msJEilqww1oyRIYTki361QdPqQJkiKAsK)lH09FqQS5DGapSSmOSH0dDaQ2HDiv8siKoQ5lnj2HuUYuXOWdzrwzfcPR2QdPY6VcHxIDiv2NAH7)IrFuiBinFiv2NAH7)IrFu4XACjWUSH0gCgPrpKfzLviKkJZvhsL1FfcVe7qQSfVkHRvDFuiBinFiv2IxLW1QUpk8ynUeyx2qAdoJ0OhYcKLvTd2QOCRcYTET6qkK6OccPMe5)siD)hKkBrkBi9qhGQDyhsfVecPJA(stIDiLRmvmk8qwKvwHqQSS6qQS(Rq4LyhsLDoeyL(Oq2qA(qQSZHaR0hfESgxcSlBiTbNrA0dzrwzfcPr5QdPY6VcHxIDiv25qGv6JczdP5dPYohcSsFu4XACjWUSH0gCgPrpKfzLviK6uwwDivw)vi8sSdPYohcSsFuiBinFiv25qGv6JcpwJlb2LnK2GZin6HSazzv7GTkk3QGCRxRoKcPoQGqQjr(Ves3)bPYM3bcClBi9qhGQDyhsfVecPJA(stIDiLRmvmk8qwKvwHqQmRoKkR)keEj2HuzFQfU)lg9rHSH08HuzFQfU)lg9rHhRXLa7YgsBWzKg9qwKvwHq6ARoKkR)keEj2HuzFQfU)lg9rHSH08HuzFQfU)lg9rHhRXLa7YgsBWzKg9qwKvwHqQmRT6qQS(Rq4LyhsLT4vjCTQ7JczdP5dPYw8QeUw19rHhRXLa7YgsBWzKg9qwGSSQDWwfLBvqU1RvhsHuhvqi1Ki)xcP7)Guz3X9OsKYgsp0bOAh2HuXlHq6OMV0Kyhs5ktfJcpKfzLviKkZQdPY6VcHxIDiv25qGv6JczdP5dPYohcSsFu4XACjWUSH0gCgPrpKfzLviK6m8vhsL1FfcVe7qQSZHaR0hfYgsZhsLDoeyL(OWJ14sGDzdPtcPRYo4KvqAdoJ0OhYISYkesD6C1Huz9xHWlXoKk7CiWk9rHSH08HuzNdbwPpk8ynUeyx2q6Kq6QSdozfK2GZin6HSazzv7GTkk3QGCRxRoKcPoQGqQjr(Ves3)bPYEEu2q6Hoav7WoKkEjesh18LMe7qkxzQyu4HSiRScH0OU6qQS(Rq4LyhsLDoeyL(Oq2qA(qQSZHaR0hfESgxcSlBiTbNrA0dzrwzfcPoDU6qQS(Rq4LyhsLDoeyL(Oq2qA(qQSZHaR0hfESgxcSlBiTbNrA0dzrwzfcPoJYvhsL1FfcVe7qQSZHaR0hfYgsZhsLDoeyL(OWJ14sGDzdPn4msJEilqwwfKi)xIDiD1G0HN2xqkHjsHhYIMzutL)0mmMKSwZq((TrGAMv1Qcsx1w1Bhc24bPo4)fBilRQvfKYIAHqQmoq5HuzcxgNqwGSSQwvqQJT4WgsxVzIuaP)gsxVPEbHuRs8ovYjKs8Xg3dzzvTQGuhBXHnKYq2QYQyivwFtHq66DJZgsj(yJ7HSSQwvqQdwVdPUVqSTyLes5kiNTasZhsLMkiKkRDWdsXkpdfEilqwwvRkiDvocYvtSdPU4(pes5VK7KqQlgBLWdPoyCosofqA9LdvMtARsaPdpTVeq6xeb9qwgEAFj8KpK)sUtggPvC)mjWoytmbXERvXG8JyfKLHN2xcp5d5VK7KHrALqZzJlbkFnsiPiQyb(cOkqqEwXgt5FYKeykFOHqfjHoavJmzS7TsWp1CCjqGdqDQuvc0XqghxwqhGQrMm29Xet3M8pbWD6X4Yc6aunYKXUV9MurKFHllOdq1itg7(peECL5IXoyktAaUtM4fCzbDaQgzYy3luM(3gFJGmi)eLGSm80(s4jFi)LCNmmsRWvmGR6js5TnP1LdbwPxGhwwg0J14sG9LL1LdbwPFBIe8BqQGGwflrqAX45XACjWoKLHN2xcp5d5VK7KHrAfUIbANqO82M06YHaR0JfEX2QKvXaKWIGNhRXLa7qwGSSQwvq6QCeKRMyhsXq4festtcH0ubH0HN)bPMasNqJrmUeOhYYWt7lbjbzCoGYuDGipJnczz4P9LimsReAoBCjq5RrcjP8eDqevSK)jtsGP8HgcvKe)FI(3wERc9SrqevSaPccAvSebPfJN)qPXkrZTfRKGdLgRellBlwjbhknwjCi)FI(3wERc9SrqevSaPccAvSebPfJN)qPXkbRoLj8an0qoeyLEbEyzzWaBlwjbhknwjAY)NO)TLxGhwwg0FO0yLia)FI(3wEbEyzzq)HsJvIModVXLLg4)t0)2YlY)Ka4CPcyQoyBh63QeeGd5kZfJG0Kqw3wSscouASseG)pr)BlVi)tcGZLkGP6GTDOFRsqaoKRmxmcstcB6mQnUS0a)FI(3wEr(NeaNlvat1bB7qpxzUyuqk8a8)j6FB5f5FsaCUubmvhSTd9hknwjyDBXkj4qPXkrJnczz4P9LimsRq(t7l5TnPgCv3BVapSSmOxL8YIR6E7f5FsaCUubmvhSTd9QKBmazm9ruXcKkiOvXseKwmE(HNwiCzX9fIaBlwjbhknwjyLuugoKLHN2xIWiTcFiiadpTVaeMiLVgjKKapSSmO82MKR6E7f4HLLb9QKHSm80(segPv4dbby4P9fGWeP81iHKAXH8xcWVb)1XtEBtYvDV9T4q(lb43G)645vjdzz4P9LimsRWhccWWt7laHjs5Rrcj9KXcp5TnP0KqwLLaCfJ1OgyDKX0hrflqQGGwflrqAX45hEAHqildpTVeHrALTjsWVbPccAvSebPfJN88GCceKZfJPGKt5TnjUI5LMioKRynjTwGgWcV4G(0Kqq(aPjcRoxwWcV4G(0Kqq(aPjcRYsa()e9VT8BtKcWVbB1lO)qPXkbRo9rDzH)pr)BlFloK)sa(n4VoE(dLgReSktJbwxhDv3BV7xyxvKa3dBbD0vDV9QKHSm80(segPvWiKrcGYCsYBBsCfZlnrCixXAsYzGgWcV4G(0Kqq(aPjcRoxw4)t0)2YlWdlld6puASsWQmllyHxCqFAsiiFG0eHvzja)FI(3w(Tjsb43GT6f0FO0yLGvN(OUSW)NO)TLVfhYFja)g8xhp)HsJvcwLPXaRZvDV9UFHDvrcCpS1RsgYYWt7lryKwjTy8aKhcj55b5eiiNlgtbjNYBBs8xY9bI8m2yaUI5LMioKRynjjtGgWcV4G(0Kqq(aPjcRoxw4)t0)2YlWdlld6puASsWQmllyHxCqFAsiiFG0eHvzja)FI(3w(Tjsb43GT6f0FO0yLGvN(OUSW)NO)TLVfhYFja)g8xhp)HsJvcwLPXaRRJUQ7T39lSRksG7HTGo6QU3EvYqwgEAFjcJ0k8HGam80(cqyIu(AKqs8oqGB5TnP1LdbwPxGhwwgeYYWt7lryKwHpeeGHN2xactKYxJesI3bc8WYYGYBBs5qGv6f4HLLbHSm80(segPv4dbby4P9fGWeP81iHKeP82M0WtlecWcLmuW6AqwgEAFjcJ0k8HGam80(cqyIu(AKqsZJYBBsdpTqialuYqrtsRbzbYYWt7lHFEKuRIDewfd63e)fGSAXvGSm80(s4NhdJ0kyHxSTkzvmajSi2jVTjXvmV0eXHCfRjjzcGfEXb9PjHG8bstKMYSSWvmV0eXHCfRjjzbYYWt7lHFEmmsRiiBvzvmGFtHa2gNT82Me)LCFGipJngObx1923NIJGFd4k26BEvYllD0vDV9UFHDvrcCpSf0rx192RsUrildpTVe(5XWiTY2ePa8BWw9ckVTjHfEXb9PjHG8bstKMyeKRMiinjCzHRyEPjId5kgRKCczz4P9LWppggPvotyvmqOwa2gNT88GCceKZfJPGKt5TnPgYHaR03QyhHvXG(nXFbiRwCLa8)j6FB5ptyvmqOwa2gNTVREtAF1K)pr)BlFRIDewfd63e)fGSAXv8hknwjctwAmqd8)j6FB53MifGFd2Qxq)HsJvIMRTSWvSMKIAJqwgEAFj8ZJHrALtvOyvmy9NocATQlVTj5QU3(tvOyvmy9NocATQ77FBbzz4P9LWppggPvWiKrcGYCsYBBsCfZlnrCixXAsYjKLHN2xc)8yyKwzBIe8BqQGGwflrqAX4jppiNab5CXyki5uEBtIRyEPjId5kwtsRbzz4P9LWppggPv4kgWv9eP82MexX8stehYvSMKKbYYWt7lHFEmmsRWVHZMWQyW6pDeqyXkzzvS82MKR6E7tfeGsKX7pbGpKhUL)5f5Wz305Qfal8Id6ttcb5dKMinXiixnrqAsOdDgG)pr)Bl)2ePa8BWw9c6puASs0eJGC1ebPjHqwgEAFj8ZJHrAL0IXdqEiKKNhKtGGCUymfKCkVTjXvmV0eXHCfRjjzc0W6YHaR0RyjG)sU)Yc)LCFGipJn2iKLHN2xc)8yyKwzo(uii)7WkL32K4kMxAI4qUI1KKtildpTVe(5XWiTIGSvLvXa(nfcyBC2YBBs8xY9bI8m2yGg4)t0)2Y7(f2vfjW9Ww)HsJvIMYSSSo(hcRPsFH87j(R3yGg4kwtsrDzH)pr)Bl)2ePa8BWw9c6puASs0mkxw4)t0)2YVnrka)gSvVG(dLgRenxlaxXAsATayHxCqFAsiiFqudNvNllyHxCqFAsiiFG0eHvsnSwyR5G4)t0)2YVnrka)gSvVG(dLgReSg1gxwCv3BVi)tcGZLkGP6GTDOxLCJqwgEAFj8ZJHrAfUIbANqO82Me)LCFGipJnczz4P9LWppggPv2ebTkgiWJmwjGTXzlVTj5QU3E3NnG89CF)Bl5TkX7ujNKCczz4P9LWppggPvCjgo7xnbSnoB55b5eiiNlgtbjNYBBs8xY9bI8m2yGgCv3BV7Zgq(EUxL8YsoeyLEflb8xY9dq(WqGyE370NwmEaYdHuaUIrsMa8)j6FB53MifGFd2Qxq)HsJvcwxBzHRyEPjId5kgRKCgG8HHaX8U3Pxq2QYQya)McbSno7ayHxCqFAsiiFG0eH11AeYcKLHN2xcpVde4MKvHE2iiIkwGubbTkwIG0IXtEBtADHMZgxc0R8eDqevSc0a)FI(3w(ZewfdeQfGTXz7puASsWQmllRJ)HWAQ0Zo4zt1yGgwh)dH1uPVq(9e)1xw4)t0)2Y7(f2vfjW9Ww)HsJvcwLPXLLTfRKGdLgReSktuHSm80(s45DGa3HrAL8v5kGFd64KkYBBsBlwjbhknwjA2Gthy4o8ulC)xm63toeG8v5koiNYeEJllUQ7TxK)jbW5sfWuDW2o03)2kazm9ruXcKkiOvXseKwmE(HNwiCzX9fIaBlwjbhknwjy1z4qwgEAFj88oqG7WiTsloK)sa(n4VoEYBBsnCJ1byiSs)07cVvnLLOUSCJ1byiSs)07cVk5gdW)NO)TL)mHvXaHAbyBC2(dLgReSIrqUAIG0KWa8)j6FB5Tk0ZgbruXcKkiOvXseKwmE(dLgRenBqMWdtMWDqNAH7)IrVvHE24jaDKWIvYgxwCFHiW2IvsWHsJvcwxlQqwgEAFj88oqG7WiTYEqcRqGiFjYYBBs8xY9bI8m2yGgUX6amewPF6DH3QModFz5gRdWqyL(P3fEvYnczz4P9LWZ7abUdJ0k7HGalWFD8K32KUX6amewPF6DH3QMRf(YYnwhGHWk9tVl8QKHSm80(s45DGa3HrAf3VWUQibUh2kVTjXvSMKKjW2IvsWHsJvIMrz4bAG)pr)BlVi)tcGZLkGP6GTDONRmxmkAg(Yc)FI(3wEr(NeaNlvat1bB7q)HsJvIModVXanqgtFevSaPccAvSebPfJNF4Pfcxw4)t0)2YBvONncIOIfivqqRILiiTy88hknwjA6m8LLqZzJlb6vEIoiIkwnUS0axXAssMaBlwjbhknwjyLuugEGgiJPpIkwGubbRAflrqAX45hEAHWLf()e9VT8wf6zJGiQybsfe0Qyjcslgp)HsJvIMBlwjbhknwjAmqd8)j6FB5f5FsaCUubmvhSTd9CL5IrrZWxw4)t0)2YlY)Ka4CPcyQoyBh6puASs0CBXkj4qPXkXYIR6E7f5FsaCUubmvhSTd9QKBSXLLTfRKGdLgReS6mQqwgEAFj88oqG7WiTIi)tcGZLkGP6GTDiyBrMeL32K4F1vT0Z))6wnj2b)EJLWcHESgxcSdzz4P9LWZ7abUdJ0kI8pjaoxQaMQd22HYBBs8)j6FB5f5FsaCUubmvhSTd9CL5Irbjzww2wSscouASsWQmHVS0WnwhGHWk9tVl8hknwjA6mQllnSo(hcRPsp7GNnvG1X)qynv6lKFpXF9gd0qd3yDagcR0p9UWBvt()e9VT8I8pjaoxQaMQd22H(Tkbb4qUYCXiinjCzzD3yDagcR0p9UWJrmrkAmqd8)j6FB5Tk0ZgbruXcKkiOvXseKwmE(dLgRen5)t0)2YlY)Ka4CPcyQoyBh63QeeGd5kZfJG0KWLLqZzJlb6vEIoiIkwn2ya()e9VT8BtKcWVbB1lO)qPXkbRKwTaCfRjjzcW)NO)TLVvXocRIb9BI)cqwT4k(dLgReSsYPmnczz4P9LWZ7abUdJ0kI8pjaoxQaMQd22HYBBs8pewtLE2bpBQan4QU3(wCi)La8BWFD88QKxwAyBXkj4qPXkbR8)j6FB5BXH8xcWVb)1XZFO0yLyzH)pr)BlFloK)sa(n4VoE(dLgRen5)t0)2YlY)Ka4CPcyQoyBh63QeeGd5kZfJG0KWgdW)NO)TLFBIua(nyREb9hknwjyL0QfGRynjjta()e9VT8Tk2ryvmOFt8xaYQfxXFO0yLGvsoLPrildpTVeEEhiWDyKwrK)jbW5sfWuDW2ouEBtI)HWAQ0xi)EI)6b6OR6E7D)c7QIe4EylOJUQ7TxLCGgiJPpIkwGubbTkwIG0IXZp80cHllHMZgxc0R8eDqevSww4)t0)2YBvONncIOIfivqqRILiiTy88hknwjAY)NO)TLxK)jbW5sfWuDW2o0VvjiahYvMlgbPjHll8)j6FB5Tk0ZgbruXcKkiOvXseKwmE(dLgRenxl8gHSm80(s45DGa3HrAfRe8tnhxce4auNkvLaDmKXr5TnjYy6JOIfivqqRILiiTy88dpTq4YI7leb2wSscouASsWQmHdzz4P9LWZ7abUdJ0kT3KkI8luEBtImM(iQybsfe0Qyjcslgp)WtleUS4(crGTfRKGdLgReSkt4qwgEAFj88oqG7WiTsmX0Tj)taCNEmkVTjrgtFevSaPccAvSebPfJNF4PfcxwCFHiW2IvsWHsJvcwLjCildpTVeEEhiWDyKwrvGalrj5Rrcj1pC6B7qqiuiqc5TnP1fAoBCjqFevSaFbufiipRyJ5Yc)FI(3wERc9SrqevSaPccAvSebPfJN)qPXkrtzcpazm9ruXcKkiOvXseKwmE(dLgReSkt4llHMZgxc0R8eDqevSGSm80(s45DGa3HrAfvbcSeLeYBBsRl0C24sG(iQyb(cOkqqEwXgZLf()e9VT8wf6zJGiQybsfe0Qyjcslgp)HsJvIMYe(YsO5SXLa9kprherflildpTVeEEhiWDyKwjFvUc43a2ZjnYBBsBlwjbhknwjAUAHVSqgtFevSaPccAvSebPfJNF4PfcxwcnNnUeOx5j6GiQyTS4(crGTfRKGdLgReS6mkHSm80(s45DGa3HrAfxI)7GT6fuEBtI)pr)BlVvHE2iiIkwGubbTkwIG0IXZFO0yLO5AHVSeAoBCjqVYt0bruXAzX9fIaBlwjbhknwjyvMWHSm80(s45DGa3HrAfx8e4X2Qy5Tnj()e9VT8wf6zJGiQybsfe0Qyjcslgp)HsJvIMRf(YsO5SXLa9kprherfRLf3xicSTyLeCO0yLGvNrfYYWt7lHN3bcChgPviSyLuawF1ESewjKLHN2xcpVde4omsRSTdDj(VlVTjX)NO)TL3QqpBeerflqQGGwflrqAX45puASs0CTWxwcnNnUeOx5j6GiQyTS4(crGTfRKGdLgReS6mCildpTVeEEhiWDyKwzkokYBia8HGqEBtI)pr)BlVvHE2iiIkwGubbTkwIG0IXZFO0yLO5AHVSeAoBCjqVYt0bruXAzX9fIaBlwjbhknwjyvMWHSm80(s45DGa3HrAf3jg8BqEgNTqEBtYvDV9I8pjaoxQaMQd22H((3wqwgEAFj88oqG7WiTYMafk8B2P82MK4vjCTQ7jRksvceGNk50(kGR6E7f5FsaCUubmvhSTd99VTc0rx1927(f2vfjW9WwqhDv3BF)BlilqwgEAFj88oqGhwwgKuO5SXLaLVgjKKapSSmiWv9eP8pzscmLp0qOIK4)t0)2YlWdlld6puASsWQZLfYy6JOIfivqqRILiiTy88dpTqya()e9VT8c8WYYG(dLgRenxl8Lf3xicSTyLeCO0yLGvzchYYWt7lHN3bc8WYYGHrAfRc9SrqevSaPccAvSebPfJN82M06cnNnUeOx5j6GiQyTS4(crGTfRKGdLgReSktuHSm80(s45DGapSSmyyKwXL4)oyREbL32KcnNnUeOxGhwwge4QEIeYYWt7lHN3bc8WYYGHrAfx8e4X2Qy5TnPqZzJlb6f4HLLbbUQNiHSm80(s45DGapSSmyyKwHWIvsby9v7XsyLqwgEAFj88oqGhwwgmmsRSTdDj(VlVTjfAoBCjqVapSSmiWv9ejKLHN2xcpVde4HLLbdJ0ktXrrEdbGpeeYBBsHMZgxc0lWdlldcCvprczz4P9LWZ7abEyzzWWiTI7ed(nipJZwiVTjfAoBCjqVapSSmiWv9ejKLHN2xcpVde4HLLbdJ0k5RYva)g0XjvK32K2wSscouASs0SbNoWWD4Pw4(Vy0VNCia5RYvCqoLj8gxwiJPpIkwGubbTkwIG0IXZp80cHllUVqeyBXkj4qPXkbRodhYYWt7lHN3bc8WYYGHrAL8v5kGFdypN0iVTjTTyLeCO0yLO5Qf(Yczm9ruXcKkiOvXseKwmE(HNwiCzX9fIaBlwjbhknwjy1z4qwgEAFj88oqGhwwgmmsR0Id5VeGFd(RJN82Me)FI(3w(ZewfdeQfGTXz7puASsWkgb5QjcstcHSm80(s45DGapSSmyyKwXkb)uZXLaboa1PsvjqhdzCuEBtk0C24sGEbEyzzqGR6jsildpTVeEEhiWdlldggPvAVjve5xO82MuO5SXLa9c8WYYGax1tKqwgEAFj88oqGhwwgmmsRetmDBY)ea3PhJYBBsHMZgxc0lWdlldcCvprczz4P9LWZ7abEyzzWWiTIQabwIsc5TnP1fAoBCjqFevSaFbufiipRyJ5Yc)FI(3wERc9SrqevSaPccAvSebPfJN)qPXkrtzcFzj0C24sGELNOdIOIfKLHN2xcpVde4HLLbdJ0k7bjScbI8Lidzz4P9LWZ7abEyzzWWiTYEiiWc8xhpildpTVeEEhiWdlldggPvC)c7QIe4EyR82MK7leb2wSscouASsWQZOUS0axXAssManSTyLeCO0yLOzugEGgAG)pr)BlVapSSmO)qPXkrtNHVS4QU3EbEyzzqVk5Lf()e9VT8c8WYYGEvYngObYy6JOIfivqqRILiiTy88dpTq4Yc)FI(3wERc9SrqevSaPccAvSebPfJN)qPXkrtNHVSeAoBCjqVYt0bruXQXgBCzPHTfRKGdLgReSskkdpqdKX0hrflqQGGvTILiiTy88dpTq4Yc)FI(3wERc9SrqevSaPccAvSebPfJN)qPXkrZTfRKGdLgRen2yJqwgEAFj88oqGhwwgmmsRiWdlldkVTjX)NO)TL)mHvXaHAbyBC2(dLgReSkZYI7leb2wSscouASsWQZOczz4P9LWZ7abEyzzWWiTI7ed(nipJZwazz4P9LWZ7abEyzzWWiTYMafk8B2P82MK4vjCTQ7jRksvceGNk50(kGR6E7f4HLLb99VTc0rx1927(f2vfjW9WwqhDv3BF)BlilqwgEAFj8pzSWJ02ej43GubbTkwIG0IXtEEqobcY5UymfKCkVTjXvmV0eXHCfRjP1GSm80(s4FYyHxyKwbJqgjakZjjVTjLdbwPNRyax1tKESgxcShGRyEPjId5kwtsRbzz4P9LW)KXcVWiTsAX4bipesYZdYjqqoxmMcsoL32K4VK7de5zSXaCfZlnrCixXAssgildpTVe(Nmw4fgPv4kgODcHYBBsCfZlnrCixXijdKLHN2xc)tgl8cJ0kyeYibqzojildpTVe(Nmw4fgPvslgpa5HqsEEqobcY5IXuqYP82MexX8stehYvSMKKbYcKLHN2xcVapSSmiPTjsb43GT6fuEBtYvDV9c8WYYG(dLgReS6eYYWt7lHxGhwwgmmsRiiBvzvmGFtHa2gNT82Me)LCFGipJngOHHNwieGfkzOOjP1wwgEAHqawOKHIModSo()e9VT8NjSkgiulaBJZ2RsUrildpTVeEbEyzzWWiTYzcRIbc1cW24SLNhKtGGCUymfKCkVTjXFj3hiYZyJqwgEAFj8c8WYYGHrALTjsb43GT6fuEBtA4PfcbyHsgkAsAnildpTVeEbEyzzWWiTIGSvLvXa(nfcyBC2YBBs8xY9bI8m2yax1923NIJGFd4k26BEvYqwgEAFj8c8WYYGHrAfxIHZ(vtaBJZwEEqobcY5IXuqYP82Me)LCFGipJngWvDV9T4q(lb43G)645vjhG)pr)Bl)zcRIbc1cW24S9hknwjAkdKLHN2xcVapSSmyyKwzBIua(nyREbL3QeVtLCcSnjx192lWdlld6vjhG)pr)Bl)zcRIbc1cW24S9ho9GqwgEAFj8c8WYYGHrAfbzRkRIb8BkeW24SL32K4VK7de5zSXaD0vDV9UFHDvrcCpSf0rx192RsgYYWt7lHxGhwwgmmsRSnrc(nivqqRILiiTy8KNhKtGGCUymfKCkVTjXvmwxdYYWt7lHxGhwwgmmsR4smC2VAcyBC2YZdYjqqoxmMcsoL32K4VK7de5zSXLL1LdbwPxXsa)LCFildpTVeEbEyzzWWiTIGSvLvXa(nfcyBC2qwGSm80(s4fjPwf7iSkg0Vj(laz1IRiVTjDJ1byiSs)07cVvn5)t0)2Y3QyhHvXG(nXFbiRwCfFx9M0(YbfU3bUSCJ1byiSs)07cVkzildpTVeErggPvWcVyBvYQyasyrStEBtIRyEPjId5kwtsYeal8Id6ttcb5dKMinxBzHRyEPjId5kwtsYsGgWcV4G(0Kqq(aPjstzwwwh5ddbI5DVtFAX4bipesnczz4P9LWlYWiTIGSvLvXa(nfcyBC2YBBs8xY9bI8m2yax1923NIJGFd4k26BEvYbA4gRdWqyL(P3fERA6QU3((uCe8BaxXwFZFO0yLWHYSSCJ1byiSs)07cVk5gHSm80(s4fzyKw5mHvXaHAbyBC2YZdYjqqoxmMcsoL32K4)t0)2YlWdlld6puASs005YY6YHaR0lWdlldgOb()e9VT8T4q(lb43G)645puASs0uwwwwh)dH1uPNDWZMQrildpTVeErggPv2MifGFd2Qxq5TnPgUX6amewPF6DH3QM8)j6FB53MifGFd2QxqFx9M0(YbfU3bUSCJ1byiSs)07cVk5gd0aw4fh0NMecYhinrAIrqUAIG0Kqh6CzHRyEPjId5kgRKCUS4QU3Er(NeaNlvat1bB7q)HsJvcwXiixnrqAsyyoBCzzBXkj4qPXkbRyeKRMiinjmmNllD0vDV9UFHDvrcCpSf0rx192RsgYYWt7lHxKHrAf(nC2ewfdw)PJaclwjlRIL32KCv3BFQGauImE)ja8H8WT8pViho7MoxTayHxCqFAsiiFG0ePjgb5QjcstcDOZa8)j6FB5ptyvmqOwa2gNT)qPXkrtmcYvteKMeUS4QU3(ubbOez8(ta4d5HB5FEroC2nDklbAG)pr)BlVapSSmO)qPXkbRrnqoeyLEbEyzzWLf()e9VT8T4q(lb43G)645puASsWAudW)qynv6zh8SPww2wSscouASsWAuBeYYWt7lHxKHrALtvOyvmy9NocATQlVTj5QU3(tvOyvmy9NocATQ77FBfy4PfcbyHsgkA6eYYWt7lHxKHrALTjsWVbPccAvSebPfJN88GCceKZfJPGKt5TnjUIX6AqwgEAFj8ImmsRGriJeaL5KK32K4kMxAI4qUI1KKtildpTVeErggPv4kgWv9eP82MexX8stehYvSMKCgy4PfcbyHsgki5mWnwhGHWk9tVl8w1uMWxw4kMxAI4qUI1KKmbgEAHqawOKHIMKKbYYWt7lHxKHrAfUIbANqiKLHN2xcVidJ0kPfJhG8qijppiNab5CXyki5uEBtI)sUpqKNXgdWvmV0eXHCfRjjzc4QU3Er(NeaNlvat1bB7qF)BlildpTVeErggPveKTQSkgWVPqaBJZwEBtYvDV9CfdGfEXb9IC4SBUw4omQoOHNwieGfkzOiGR6E7f5FsaCUubmvhSTd99VTc0a)FI(3w(ZewfdeQfGTXz7puASs0uMa8)j6FB53MifGFd2Qxq)HsJvIMYSSW)NO)TL)mHvXaHAbyBC2(dLgReSUwa()e9VT8BtKcWVbB1lO)qPXkrZ1cWvSMRTSW)NO)TL)mHvXaHAbyBC2(dLgRenxla)FI(3w(Tjsb43GT6f0FO0yLG11cWvSMYYYcxX8stehYvmwj5maw4fh0NMecYhinryvMgxwCv3BpxXayHxCqViho7ModpW2IvsWHsJvcwxpqwgEAFj8ImmsR4smC2VAcyBC2YZdYjqqoxmMcsoL32K4VK7de5zSXanKdbwPxGhwwgma)FI(3wEbEyzzq)HsJvcwxBzH)pr)Bl)zcRIbc1cW24S9hknwjA6ma)FI(3w(Tjsb43GT6f0FO0yLOPZLf()e9VT8NjSkgiulaBJZ2FO0yLG11cW)NO)TLFBIua(nyREb9hknwjAUwaUI1uMLf()e9VT8NjSkgiulaBJZ2FO0yLO5Ab4)t0)2YVnrka)gSvVG(dLgReSUwaUI1CTLfUI1mQllUQ7T39zdiFp3RsUrildpTVeErggPvslgpa5HqsEEqobcY5IXuqYP82Me)LCFGipJngGRyEPjId5kwtsYazz4P9LWlYWiTYC8Pqq(3HvkVTjXvmV0eXHCfRjjNqwgEAFj8ImmsRSjcAvmqGhzSsaBJZwERs8ovYjjNqwgEAFj8ImmsR4smC2VAcyBC2YZdYjqqoxmMcsoL32K4VK7de5zSXa8)j6FB53MifGFd2Qxq)HsJvcwxlaxXijtaYhgceZ7EN(0IXdqEiKcGfEXb9PjHG8brnCwDczz4P9LWlYWiTIlXWz)QjGTXzlppiNab5CXyki5uEBtI)sUpqKNXgdGfEXb9PjHG8bstewLjqdCfZlnrCixXyLKZLfYhgceZ7EN(0IXdqEiKAeYcKLHN2xcFloK)sa(n4VoEKcnNnUeO81iHKCjgo7xnbSnoBqHyh7Y)KjjWu(qdHksYvDV9T4q(lb43G)64bAB9hknwjc0a)FI(3w(ZewfdeQfGTXz7puASs00vDV9T4q(lb43G)64bAB9hknwjc4QU3(wCi)La8BWFD8aTT(dLgReSkJ35Yc)FI(3w(ZewfdeQfGTXz7puASs4qx1923Id5VeGFd(RJhOT1FO0yLOPt)QfWvDV9T4q(lb43G)64bAB9hknwjyvw8oxwCv3BVlX)Dcvr6vjhWvDV9wf6zJNa0rclwj9QKd4QU3ERc9SXta6iHfRK(dLgReS6QU3(wCi)La8BWFD8aTT(dLgRenczz4P9LW3Id5VeGFd(RJxyKwHpeeGHN2xactKYxJesI3bcClVTjTUCiWk9c8WYYGqwgEAFj8T4q(lb43G)64fgPv4dbby4P9fGWeP81iHK4DGapSSmO82MuoeyLEbEyzzqildpTVe(wCi)La8BWFD8cJ0kyHxSTkzvmajSi2jVTjXvmV0eXHCfRjjzcGfEXb9PjHG8bstKMRbzz4P9LW3Id5VeGFd(RJxyKw5mHvXaHAbyBC2YZdYjqqoxmMcsoHSm80(s4BXH8xcWVb)1XlmsRSnrka)gSvVGYBBsdpTqialuYqrtsYeWvDV9T4q(lb43G)64bAB9hknwjy1jKLHN2xcFloK)sa(n4VoEHrALwf7iSkg0Vj(laz1IRiVTjn80cHaSqjdfnjjdKLHN2xcFloK)sa(n4VoEHrAfbzRkRIb8BkeW24SL32K4VK7de5zSXadpTqialuYqrtsRfWvDV9T4q(lb43G)64bAB9QKHSm80(s4BXH8xcWVb)1XlmsR4smC2VAcyBC2YZdYjqqoxmMcsoL32K4VK7de5zSXadpTqialuYqbRKKjqO5SXLa9UedN9RMa2gNnOqSJDildpTVe(wCi)La8BWFD8cJ0kcYwvwfd43uiGTXzlVTjXFj3hiYZyJbCv3BFFkoc(nGRyRV5vjdzz4P9LW3Id5VeGFd(RJxyKwbJqgjakZjjVTjXvmsHhWvDV9T4q(lb43G)64bAB9hknwjyvwGSm80(s4BXH8xcWVb)1XlmsRSnrc(nivqqRILiiTy8KNhKtGGCUymfKCkVTjXvmsHhWvDV9T4q(lb43G)64bAB9hknwjyvwGSm80(s4BXH8xcWVb)1XlmsR0QyhHvXG(nXFbiRwCfildpTVe(wCi)La8BWFD8cJ0kPfJhG8qijFoxmMaBtsYQvVJUQ7TxAo2GFdsfeWVPq)HsJvIWAOJUQ7TxWo4HdxbGrugvrAF5vj7GKj8gL32K4kgPWd4QU3(wCi)La8BWFD8aTT(dLgReSklqwgEAFj8T4q(lb43G)64fgPv2MifGFd2Qxq5TkX7ujNaBtYvDV9T4q(lb43G)64bAB9QKL32KCv3BVi)tcGZLkGP6GTDOxLCGBSoadHv6NEx4TQj)FI(3w(Tjsb43GT6f03vVjTVCqH7JsildpTVe(wCi)La8BWFD8cJ0kcYwvwfd43uiGTXzlVTj5QU3EUIbWcV4GEroC2nxlChgvh0WtlecWcLmuazz4P9LW3Id5VeGFd(RJxyKwzBIe8BqQGGwflrqAX4jppiNab5CXyki5uEBtIRySUgKLHN2xcFloK)sa(n4VoEHrAfmczKaOmNK82MexX8stehYvSMKCczz4P9LW3Id5VeGFd(RJxyKwHRyax1tKYBBsCfZlnrCixXAsQbNHn80cHaSqjdfnD2iKLHN2xcFloK)sa(n4VoEHrAL0IXdqEiKKNhKtGGCUymfKCkVTj1W6YHaR0RyjG)sU)Yc)LCFGipJn2yaUI5LMioKRynjjdKLHN2xcFloK)sa(n4VoEHrAfxIHZ(vtaBJZwEEqobcY5IXuqYP82M0WtlecWcLmuWkP1cWvSMKwBzXvDV9T4q(lb43G)64bAB9QKHSm80(s4BXH8xcWVb)1XlmsRWvmq7ecHSm80(s4BXH8xcWVb)1XlmsRSjcAvmqGhzSsaBJZwERs8ovYjjN6uNAn]] )


end