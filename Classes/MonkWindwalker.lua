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
        wind_waker = 3737, -- 287506
        reverse_harm = 852, -- 287771
        pressure_points = 3744, -- 287599
        turbo_fists = 3745, -- 287681
        disabling_reach = 3050, -- 201769
        ride_the_wind = 77, -- 201372
        grapple_weapon = 3052, -- 233759
        tigereye_brew = 675, -- 247483
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
            
            toggle = "cooldowns",

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
                if legendary.keefers_skyreach.enabled and debuff.recently_rushing_tiger_palm.up and active_dot.recently_rushing_tiger_palm < cycle_enemies then return "recently_rushing_tiger_palm" end
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

                if legendary.keefers_skyreach.enabled and debuff.recently_rushing_tiger_palm.down then
                    setDistance( 5 )
                    applyDebuff( "target", "keefers_skyreach" )
                    applyDebuff( "target", "recently_rushing_tiger_palm" )
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
                recently_rushing_tiger_palm = {
                    id = 337341,
                    duration = 30,
                    max_stack = 1,
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
    
    spec:RegisterPack( "Windwalker", 20210122, [[dSuz5bqicQ8ifqAtsQ(eIsJsvLoLQkwLeO6vKQAwiQUfIIDrv)scAyQk1XiflJuYZuGMgbLUMeW2ua8nfqmockCofqTovLW7uvsrZJuQ7Pq7ts5GsGOfsQYdvvsUibfzJQkPWhLaPojbf1kvv8svLuYmvvIUPQsk1ovv1pLajlvcu6PGmvcYxvvs1yjOQ9I0FbgmrhwQfljpgQjROlJAZG6Zs0OPIttz1ka9AeA2QYTj0Uf9BLgoboUeOy5Q8CsMUW1PsBxb9Dez8sOZtQSEjqy(iy)qMQHkefA2bt)R13AP5BnAPL)BHX3dGMbcfk0jGPqcAmXUKPqzlYuOVULts9JiFuibTU32tQqui16EyMcrHQCTximN0kk0SdM(xRV1sZ3A0sl)3cJVlqbewkKsaJP)1AagykKJnNCsROqtwHPqduK8RB5Ku)iYhs(1EtIOpduK8tNU9Pdj1slYrsT(wlnOpOpduKuisCtej)AyQqHKlms(1W90HKwg8DUccK8TLg2J(mqrsHiXnrKesGLPLLi5xDDYi5xldtejFBPH)AIK9W1Mi5KFTofs25ejTm4YRdgj)Q(HDFDWtKekoJiR8uONPcfvik0kGt(Ocr)RHkefIZU6XtQEuOgh2MuiytfGfgeomGKJfmiSs(Oq4Zc(SMcHDmVyxejjdsIDmKS2isoifcRd)yq03vYHIcPHg0)ArfIcXzx94jvpke(SGpRPqr)4m8yhdu5EQWZzx94jswhjXoMxSlIKKbjXogswBejhKc14W2KcXffWpGtFI0G(FqQquio7QhpP6rHACyBsHcRKpGG(jsHWNf8znfcVIvlqfNrKrY6ij2X8IDrKKmij2XqYAJiPwuiSo8JbrFLCOO)1qd6FHLkefIZU6XtQEui8zbFwtHWoMxSlIKKbjXogsoIKArHACyBsHWogGupKPb9FbOcrHACyBsH4Ic4hWPprkeND1JNu9Ob9)aqfIcXzx94jvpkuJdBtkuyL8be0prke(SGpRPqyhZl2frsYGKyhdjRnIKArHW6Wpge9vYHI(xdnObfIe3c2ubwyWEt(Ocr)RHkefIZU6XtQEui8zbFwtHeoKm6hNHxXhNwOZZzx94jfQXHTjfc3VhOXHTj4zQGc9mvaYwKPq4jqXW0G(xlQquio7QhpP6rHWNf8znfk6hNHxXhNwOZZzx94jfQXHTjfc3VhOXHTj4zQGc9mvaYwKPq4jqXhNwOJg0)dsfIcXzx94jvpke(SGpRPqyhZl2frsYGKyhdjRnIKAHK1rso5RuNpmrgelqSlIK1qYbPqnoSnPqCYxPvqyzjGFwr7Ob9VWsfIcXzx94jvpkuJdBtk0zkllbk3eq0WePqyD4hdI(k5qr)RHg0)fGkefIZU6XtQEui8zbFwtHWRy1cuXzezKSosw5cd7NDIzWcdWo2aAExbuOgh2MuiLaltllb4Rtgq0WePb9)aqfIcXzx94jvpke(SGpRPqnoSHmGtw0yfswBej1cjRJKvUWWEsClytfyHb7n5dqIK)yX2sfsQnsQHc14W2KcbBQqbwyaS7PJg0)deQquio7QhpP6rHWNf8znfQXHnKbCYIgRqYAJiPwuOgh2Muiso29SSemVUCtGa3e7qd6FHbvikeND1JNu9Oq4Zc(SMcHxXQfOIZiYizDKSXHnKbCYIgRqYAJi5GizDKSYfg2tIBbBQalmyVjFasK8UcOqnoSnPqkbwMwwcWxNmGOHjsd6)bMkefIZU6XtQEuOgh2MuOQxJjUUbGOHjsHWNf8znfcVIvlqfNrKrY6izJdBid4KfnwHKApIKArHW6Wpge9vYHI(xdnO)18nvikuJdBtkejh7EwwcMxxUjqGBIDOqC2vpEs1Jg0)A0qfIcXzx94jvpke(SGpRPqvUWWEvSNiG7lCaDobW2XExbizDK8ABc4HCg(EovElrYAijE33CjLEytfkWcdGDpD(P71HTjswWrYV9dafQXHTjfc2uHcSWay3thfYYGVZvqamykuLlmSNe3c2ubwyWEt(aKi5Dfqd6FnArfIcXzx94jvpke(SGpRPqvUWWESJb4KVsDEv0yIiznKCWVrsYGKfajl4izJdBid4KfnwrHACyBsHucSmTSeGVozardtKg0)AgKkefIZU6XtQEuOgh2MuiytfGfgeomGKJfmiSs(Oq4Zc(SMcHDmKuBKCqkewh(XGOVsou0)AOb9VgHLkefIZU6XtQEui8zbFwtHWoMxSlIKKbjXogswBej1qHACyBsH4Ic4hWPprAq)RPauHOqC2vpEs1JcHpl4ZAke2X8IDrKKmij2XqYAJi5ViPgKuFKSXHnKbCYIgRqYAiPgK8hkuJdBtke2XavUNkOb9VMbGkefIZU6XtQEuOgh2MuOWk5diOFIui8zbFwtH(fjfoKm6hNH3XcaEfRwpND1JNijbcijEfRwGkoJiJK)GK1rsSJ5f7IijzqsSJHK1grsTOqyD4hdI(k5qr)RHg0)AgiuHOqnoSnPqyhdqQhYuio7QhpP6rd6FncdQquio7QhpP6rHACyBsHQEnM46gaIgMifcFwWN1uiSJHK1grYbrsceqYkxyypjUfSPcSWG9M8birY7kGcH1HFmi6RKdf9VgAq)RzGPcrHSm47CfeuinuOgh2Mui4Nollbk(eWzaiAyIuio7QhpP6rdAqHu8XPf6Ocr)RHkefIZU6XtQEui8zbFwtHQCHH9k(40cD(JfBlviP2iPgkuJdBtkeSPcfyHbWUNoAq)RfvikuJdBtkKRIbwWIkkeND1JNu9Ob9)GuHOqC2vpEs1JcHpl4ZAkeEfRwGkoJiJK1rYFrYgh2qgWjlAScjRnIKdIKeiGKnoSHmGtw0yfswdj1GK1rsHdjX7(MlP0FMYYsGYnbenmrVRaK8hkuJdBtkKsGLPLLa81jdiAyI0G(xyPcrH4SRE8KQhfQXHTjf6mLLLaLBciAyIui8zbFwtHWRy1cuXzezkewh(XGOVsou0)AOb9FbOcrH4SRE8KQhfcFwWN1uOgh2qgWjlAScjRnIKdsHACyBsHGnvOalma290rd6)bGkefIZU6XtQEui8zbFwtHWRy1cuXzezKSosw5cd7NDIzWcdWo2aAExbuOgh2MuiLaltllb4Rtgq0WePb9)aHkefIZU6XtQEuOgh2MuOQxJjUUbGOHjsHWNf8znfcVIvlqfNrKrY6izLlmSNe3c2ubwyWEt(aKi5DfGK1rs8UV5sk9NPSSeOCtardt0FSyBPcjRHKArHW6Wpge9vYHI(xdnO)fguHOqwg8DUccGbtHQCHH9k(40cDExb1X7(MlP0FMYYsGYnbenmr)X9uhfQXHTjfc2uHcSWay3thfIZU6XtQE0G(FGPcrH4SRE8KQhfcFwWN1ui8kwTavCgrgjRJKtUYfg2xTjpDvbO6ysExbuOgh2MuiLaltllb4Rtgq0WePb9VMVPcrH4SRE8KQhfQXHTjfc2ubyHbHddi5ybdcRKpke(SGpRPqyhdj1gjhKcH1HFmi6RKdf9VgAq)RrdvikeND1JNu9OqnoSnPqvVgtCDdardtKcHpl4ZAkeEfRwGkoJiJKeiGKchsg9JZW7ybaVIvRNZU6Xtkewh(XGOVsou0)AOb9VgTOcrHACyBsHucSmTSeGVozardtKcXzx94jvpAqdkeEcu8XPf6Ocr)RHkefIZU6XtQEuOvafsXbfQXHTjfAyFwx9yk0W(5Yui8UV5sk9k(40cD(JfBlviP2iPgKKabKuah(IUCcchgqYXcgewjF(gh2qgjRJK4DFZLu6v8XPf68hl2wQqYAi5GFJKeiGKWwPtaowSTuHKAJKA9nfAyFGSfzkKIpoTqhOY9ubnO)1IkefIZU6XtQEui8zbFwtHeoKCyFwx9yVZ(MGIUCIKeiGKWwPtaowSTuHKAJKAvakuJdBtkKLdxImOOlN0G(FqQquOgh2MuixfdSGfvuio7QhpP6rd6FHLkefIZU6XtQEui8zbFwtHWoMxSlIKKbjXogswBej1qHACyBsH6d3jdI9oodAq)xaQquOgh2MuONv6ekWa6olf5mOqC2vpEs1Jg0)davikeND1JNu9Oq4Zc(SMcnSpRRESxXhNwOdu5EQGc14W2KcbBhx92Dsd6)bcvikeND1JNu9Oq4Zc(SMcnSpRRESxXhNwOdu5EQGc14W2Kc1jMvX1paUFpAq)lmOcrH4SRE8KQhfcFwWN1uOH9zD1J9k(40cDGk3tfuOgh2MuOQUeSWG4mmrfnO)hyQquio7QhpP6rHWNf8znfc2kDcWXITLkKSgs(lsQry8nssgK8CtgEVs2d3r)aX6ID8C2vpEIKfCKuJwFJK)GKeiGKc4Wx0Ltq4WasowWGWk5Z34WgYijbcijSv6eGJfBlviP2iPMVPqnoSnPqX6IDalmyYD4qd6FnFtfIcXzx94jvpke(SGpRPqWwPtaowSTuHK1qYb(BKKabKuah(IUCcchgqYXcgewjF(gh2qgjjqajHTsNaCSyBPcj1gj18nfQXHTjfkwxSdyHbe7tSPb9VgnuHOqC2vpEs1JcHpl4ZAkeE33CjL(ZuwwcuUjGOHj6pwSTuHKAJKCrg7gmimrMc14W2KcrIBbBQalmyVjF0G(xJwuHOqnoSnPqWn)SKbQyffqH4SRE8KQhnO)1mivikuJdBtkeC)ECc2BYhfIZU6XtQE0G(xJWsfIc14W2KcvTjpDvbO6ysuio7QhpP6rd6FnfGkefIZU6XtQEui8zbFwtHW7(MlP0FMYYsGYnbenmr)XITLkKuBKulKKabKe2kDcWXITLkKuBKutbOqnoSnPqk(40cD0G(xZaqfIc14W2Kcv1LGfgeNHjQOqC2vpEs1Jg0GcPcQq0)AOcrH4SRE8KQhfcFwWN1uORTjGhYz475u5TejRHK4DFZLu6j5y3ZYsW86YnbcCtSJF6EDyBIKfCK8BVWajjqajV2MaEiNHVNtL3vafQXHTjfIKJDpllbZRl3eiWnXo0G(xlQquio7QhpP6rHWNf8znfc7yEXUissgKe7yizTrKulKSosYjFL68HjYGybIDrKSgsoissGasIDmVyxejjdsIDmKS2iskSizDK8xKKt(k15dtKbXce7IiznKulKKabKu4qsbhpeuINEn(Wk5diOFIi5puOgh2Muio5R0kiSSeWpROD0G(FqQquio7QhpP6rHWNf8znfcVIvlqfNrKrY6izLlmSF2jMblma7ydO5DfGK1rYFrYRTjGhYz475u5TejRHKvUWW(zNygSWaSJnGM)yX2sfssgKulKKabK8ABc4HCg(EovExbi5puOgh2MuiLaltllb4Rtgq0WePb9VWsfIcXzx94jvpkuJdBtk0zkllbk3eq0WePq4Zc(SMcH39nxsPxXhNwOZFSyBPcjRHKAqsceqsHdjJ(Xz4v8XPf68C2vpEsHW6Wpge9vYHI(xdnO)lavikeND1JNu9Oq4Zc(SMc9lsETnb8qodFpNkVLiznKeV7BUKspSPcfyHbWUNo)096W2ejl4i53EHbssGasETnb8qodFpNkVRaK8hKSos(lsYjFL68HjYGybIDrKSgsYfzSBWGWezKKmiPgKKabKe7yEXUissgKe7yiP2JiPgKKabKSYfg2RI9ebCFHdOZja2o2FSyBPcj1gj5Im2nyqyImsQpsQbj)bjjqajHTsNaCSyBPcj1gj5Im2nyqyImsQpsQHc14W2KcbBQqbwyaS7PJg0)davikeND1JNu9Oq4Zc(SMcv5cd7dhgWIc4Bpfa3cASf75vrJjIK1qsndmswhj5KVsD(WezqSaXUiswdj5Im2nyqyImssgKudswhjX7(MlP0FMYYsGYnbenmr)XITLkKSgsYfzSBWGWezKKabKSYfg2homGffW3EkaUf0yl2ZRIgtejRHKAewKSos(lsI39nxsPxXhNwOZFSyBPcj1gjlaswhjJ(Xz4v8XPf68C2vpEIKeiGK4DFZLu6jXTGnvGfgS3Kp)XITLkKuBKSaizDKeVd5SZWtu3zDIKeiGKWwPtaowSTuHKAJKfaj)Hc14W2KcHVgt8zzjya7jdEwPtKwwsd6)bcvikeND1JNu9Oq4Zc(SMcv5cd7pxLJLLGbSNmGKLt)CjLizDKSXHnKbCYIgRqYAiPgkuJdBtk05QCSSemG9KbKSCsd6FHbvikeND1JNu9OqnoSnPqWMkalmiCyajhlyqyL8rHWNf8znfc7yiP2i5GuiSo8JbrFLCOO)1qd6)bMkefIZU6XtQEui8zbFwtHWoMxSlIKKbjXogswBej1qHACyBsH4Ic4hWPprAq)R5BQquio7QhpP6rHWNf8znfc7yEXUissgKe7yizTrKudswhjBCydzaNSOXkKCej1GK1rYRTjGhYz475u5TejRHKA9nssGasIDmVyxejjdsIDmKS2isQfswhjBCydzaNSOXkKS2isQffQXHTjfc7yGk3tf0G(xJgQquio7QhpP6rHWNf8znfcVIvlqfNrKrY6ijEZPRfEC)WUVo4jqfNrKvEo7QhprY6iPsa)EGOVsouELaltllb4Rtgq0WerYAiPgkuJdBtkKsGLPLLa81jdiAyI0G(xJwuHOqnoSnPqyhdqQhYuio7QhpP6rd6FndsfIcXzx94jvpkuJdBtkuyL8be0prke(SGpRPq4vSAbQ4mImswhjXoMxSlIKKbjXogswBej1cjRJKvUWWEvSNiG7lCaDobW2X(5skPqyD4hdI(k5qr)RHg0)AewQquio7QhpP6rHWNf8znfQYfg2JDmaN8vQZRIgtejRHKd(nssgKSaizbhjBCydzaNSOXkKSosw5cd7vXEIaUVWb05eaBh7NlPejRJK)IK4DFZLu6ptzzjq5MaIgMO)yX2sfswdj1cjRJK4DFZLu6HnvOalma2905pwSTuHK1qsTqsceqs8UV5sk9NPSSeOCtardt0FSyBPcj1gjhejRJK4DFZLu6HnvOalma2905pwSTuHK1qYbrY6ij2XqYAi5GijbcijE33CjL(ZuwwcuUjGOHj6pwSTuHK1qYbrY6ijE33CjLEytfkWcdGDpD(JfBlviP2i5GizDKe7yiznKuyrsceqsSJ5f7IijzqsSJHKApIKAqY6ijN8vQZhMidIfi2frsTrsTqYFqsceqYkxyyp2XaCYxPoVkAmrKSgsQ5BKSoscBLob4yX2sfsQnsoqOqnoSnPqkbwMwwcWxNmGOHjsd6FnfGkefIZU6XtQEuOgh2MuOQxJjUUbGOHjsHWNf8znfcVIvlqfNrKrY6i5Viz0podVIpoTqNNZU6XtKSosI39nxsPxXhNwOZFSyBPcj1gjhejjqajX7(MlP0FMYYsGYnbenmr)XITLkKSgsQbjRJK4DFZLu6HnvOalma2905pwSTuHK1qsnijbcijE33CjL(ZuwwcuUjGOHj6pwSTuHKAJKdIK1rs8UV5sk9WMkuGfga7E68hl2wQqYAi5GizDKe7yiznKulKKabKeV7BUKs)zkllbk3eq0We9hl2wQqYAi5GizDKeV7BUKspSPcfyHbWUNo)XITLkKuBKCqKSosIDmKSgsoissGasIDmKSgswaKKabKSYfg2xTebcUf7DfGK)qHW6Wpge9vYHI(xdnO)1mauHOqC2vpEs1Jc14W2KcfwjFab9tKcHpl4ZAkeEfRwGkoJiJK1rsSJ5f7IijzqsSJHK1grsTOqyD4hdI(k5qr)RHg0)AgiuHOqwg8DUcckKgkuJdBtke8tNLLafFc4maenmrkeND1JNu9Ob9VgHbvikeND1JNu9OqnoSnPqvVgtCDdardtKcHpl4ZAkeEfRwGkoJiJK1rs8UV5sk9WMkuGfga7E68hl2wQqsTrYbrY6ij2XqYrKulKSosk44HGs80RXhwjFab9tejRJKCYxPoFyImiwqb(gj1gj1qHW6Wpge9vYHI(xdnO)1mWuHOqC2vpEs1Jc14W2Kcv9AmX1naenmrke(SGpRPq4vSAbQ4mImswhj5KVsD(WezqSaXUisQnsQfswhj)fjXoMxSlIKKbjXogsQ9isQbjjqajfC8qqjE614dRKpGG(jIK)qHW6Wpge9vYHI(xdnObfcpbkgMke9VgQquio7QhpP6rHWNf8znfs4qYH9zD1J9o7Bck6YjssGascBLob4yX2sfsQnsQvbOqnoSnPqwoCjYGIUCsd6FTOcrH4SRE8KQhfcFwWN1uiSJ5f7IijzqsSJHK1grsnuOgh2MuO(WDYGyVJZGg0)dsfIcXzx94jvpke(SGpRPqWwPtaowSTuHK1qYFrsncJVrsYGKNBYW7vYE4o6hiwxSJNZU6XtKSGJKA06BK8hKKabKSYfg2RI9ebCFHdOZja2o2pxsjswhjfWHVOlNGWHbKCSGbHvYNVXHnKrsceqsyR0jahl2wQqsTrsnFtHACyBsHI1f7awyWK7WHg0)clvikeND1JNu9Oq4Zc(SMc9lsETnb8qodFpNkVLiznKuylassGasETnb8qodFpNkVRaK8hKSosI39nxsP)mLLLaLBciAyI(JfBlviP2ijxKXUbdctKPqnoSnPqK4wWMkWcd2BYhnO)lavikeND1JNu9Oq4Zc(SMcHxXQfOIZiYizDK8xK8ABc4HCg(EovElrYAiPMVrsceqYRTjGhYz475u5DfGK)qHACyBsHGB(zjduXkkGg0)davikeND1JNu9Oq4Zc(SMcDTnb8qodFpNkVLiznKCWVrsceqYRTjGhYz475u5DfqHACyBsHG73JtWEt(Ob9)aHkefIZU6XtQEui8zbFwtHU2MaEiNHVNtL3sKSgswGVrsceqYRTjGhYz475u5DfqHACyBsHQ2KNUQauDmjk0ZsgGNuOb4BAq)lmOcrH4SRE8KQhfcFwWN1ui8Mtxl84DVPLDWtWcdZPYgYEo7QhpPqnoSnPqQypra3x4a6CcGTJbWwXoyAq)pWuHOqC2vpEs1JcHpl4ZAkeE33CjLEvSNiG7lCaDobW2XEStFLScjhrsTqsceqsyR0jahl2wQqsTrsT(gjjqaj)fjV2MaEiNHVNtL)yX2sfswdj1uaKKabKu4qs8oKZodprDN1jswhj)fj)fjV2MaEiNHVNtL3sKSgsI39nxsPxf7jc4(chqNtaSDSh299ahJD6RKbHjYijbciPWHKxBtapKZW3ZPYZfnvOqYFqY6i5VijE33CjLElhUezqrxobHddi5ybdcRKp)XITLkKSgsI39nxsPxf7jc4(chqNtaSDSh299ahJD6RKbHjYijbci5W(SU6XEN9nbfD5ej)bj)bjRJK4DFZLu6HnvOalma2905pwSTuHKApIKdmswhjXogswBej1cjRJK4DFZLu6j5y3ZYsW86YnbcCtSJ)yX2sfsQ9isQrlK8hkuJdBtkKk2teW9foGoNay7yAq)R5BQquio7QhpP6rHWNf8znfcVd5SZWtu3zDIK1rYFrYkxyypjUfSPcSWG9M85DfGKeiGK)IKWwPtaowSTuHKAJK4DFZLu6jXTGnvGfgS3Kp)XITLkKKabKeV7BUKspjUfSPcSWG9M85pwSTuHK1qs8UV5sk9Qypra3x4a6CcGTJ9WUVh4yStFLmimrgj)bjRJK4DFZLu6HnvOalma2905pwSTuHKApIKdmswhjXogswBej1cjRJK4DFZLu6j5y3ZYsW86YnbcCtSJ)yX2sfsQ9isQrlK8hkuJdBtkKk2teW9foGoNay7yAq)RrdvikuJdBtkKRIbwWIkkeND1JNu9Ob9VgTOcrH4SRE8KQhfcFwWN1uiyR0jahl2wQqYAiPMcmWijbciPao8fD5eeomGKJfmiSs(8noSHmssGasoSpRRES3zFtqrxoPqnoSnPqX6IDalmGyFInnO)1mivikeND1JNu9Oq4Zc(SMcH39nxsP3YHlrgu0Ltq4WasowWGWk5ZFSyBPcjRHKd(nssGasoSpRRES3zFtqrxorsceqsyR0jahl2wQqsTrsT(Mc14W2Kcv92DcGDpD0G(xJWsfIcXzx94jvpke(SGpRPq4DFZLu6TC4sKbfD5eeomGKJfmiSs(8hl2wQqYAi5GFJKeiGKd7Z6Qh7D23eu0LtKKabKe2kDcWXITLkKuBKutbOqnoSnPqv8P4JOLL0G(xtbOcrHACyBsHEwPtOadO7SuKZGcXzx94jvpAq)RzaOcrH4SRE8KQhfcFwWN1ui8UV5sk9woCjYGIUCcchgqYXcgewjF(JfBlviznKCWVrsceqYH9zD1J9o7Bck6YjssGascBLob4yX2sfsQnsQ5BkuJdBtkeSDC1B3jnO)1mqOcrH4SRE8KQhfcFwWN1ui8UV5sk9woCjYGIUCcchgqYXcgewjF(JfBlviznKCWVrsceqYH9zD1J9o7Bck6YjssGascBLob4yX2sfsQnsQ13uOgh2MuOoXSkU(bW97rd6FncdQquio7QhpP6rHWNf8znfQYfg2RI9ebCFHdOZja2o2pxsjfQXHTjfQQlblmiodturdAqHMmC7(cQq0)AOcrHACyBsHuc4(aoDobQ4mImfIZU6XtQE0G(xlQquio7QhpP6rHwbuifhuOgh2MuOH9zD1JPqd7NltHW7(MlP0B5WLidk6YjiCyajhlyqyL85pwSTuHK1qsyR0jahl2wQqsceqsyR0jahl2wQqsTrsnA9nswhjHTsNaCSyBPcjRHK4DFZLu6v8XPf68hl2wQqY6ijE33CjLEfFCAHo)XITLkKSgsQ5Bk0W(azlYuiN9nbfD5Kg0)dsfIcXzx94jvpke(SGpRPq)IKvUWWEfFCAHoVRaKKabKSYfg2RI9ebCFHdOZja2o27kaj)bjRJKc4Wx0Ltq4WasowWGWk5Z34WgYijbcijSv6eGJfBlviP2Ji5a8nfQXHTjfsWg2M0G(xyPcrH4SRE8KQhfcFwWN1uOkxyyVIpoTqN3vafQXHTjfc3VhOXHTj4zQGc9mvaYwKPqk(40cD0G(VauHOqC2vpEs1JcHpl4ZAkuLlmSNe3c2ubwyWEt(8UcOqnoSnPq4(9anoSnbptfuONPcq2ImfIe3c2ubwyWEt(Ob9)aqfIcXzx94jvpke(SGpRPqHjYiP2iPWIK1rsSJHKAJKfajRJKchskGdFrxobHddi5ybdcRKpFJdBitHACyBsHW97bACyBcEMkOqptfGSfzk0kGt(Ob9)aHkefIZU6XtQEuOgh2MuiytfGfgeomGKJfmiSs(Oq4Zc(SMcHDmVyxejjdsIDmKS2isoiswhj)fj5KVsD(WezqSaXUisQnsQbjjqaj5KVsD(WezqSaXUisQnskSizDKeV7BUKspSPcfyHbWUNo)XITLkKuBKuJVaijbcijE33CjLEsClytfyHb7n5ZFSyBPcj1gj1cj)HcH1HFmi6RKdf9VgAq)lmOcrH4SRE8KQhfcFwWN1uiSJ5f7IijzqsSJHK1grsnizDK8xKKt(k15dtKbXce7IiP2iPgKKabKeV7BUKsVIpoTqN)yX2sfsQnsQfssGasYjFL68HjYGybIDrKuBKuyrY6ijE33CjLEytfkWcdGDpD(JfBlviP2iPgFbqsceqs8UV5sk9K4wWMkWcd2BYN)yX2sfsQnsQfs(dfQXHTjfIlkGFaN(ePb9)atfIcXzx94jvpkuJdBtkuyL8be0prke(SGpRPq4vSAbQ4mImswhjXoMxSlIKKbjXogswBej1cjRJK)IKCYxPoFyImiwGyxej1gj1GKeiGK4DFZLu6v8XPf68hl2wQqsTrsTqsceqso5RuNpmrgelqSlIKAJKclswhjX7(MlP0dBQqbwyaS7PZFSyBPcj1gj14lassGasI39nxsPNe3c2ubwyWEt(8hl2wQqsTrsTqYFOqyD4hdI(k5qr)RHg0)A(MkefIZU6XtQEui8zbFwtHeoKm6hNHxXhNwOZZzx94jfQXHTjfc3VhOXHTj4zQGc9mvaYwKPq4jqXW0G(xJgQquio7QhpP6rHWNf8znfk6hNHxXhNwOZZzx94jfQXHTjfc3VhOXHTj4zQGc9mvaYwKPq4jqXhNwOJg0)A0IkefIZU6XtQEui8zbFwtHACydzaNSOXkKuBKCqkuJdBtkeUFpqJdBtWZubf6zQaKTitHubnO)1mivikeND1JNu9Oq4Zc(SMc14WgYaozrJvizTrKCqkuJdBtkeUFpqJdBtWZubf6zQaKTitH6LPbnOqcogVIvDqfI(xdvikuJdBtkKGnSnPqC2vpEs1Jg0)ArfIc14W2KcvTr84ja(164jjllbXw0skeND1JNu9Ob9)GuHOqC2vpEs1JcTcOqkoOqnoSnPqd7Z6QhtHg2pxMc9nfAyFGSfzkurxobBcCvmioljYbnO)fwQquio7QhpP6rHWNf8znfs4qYOFCgEfFCAHopND1JNijbciPWHKr)4m8WMkalmiCyajhlyqyL855SRE8Kc14W2KcHDmqL7PcAq)xaQquio7QhpP6rHWNf8znfs4qYOFCgEo5R0kiSSeWpRiFEo7QhpPqnoSnPqyhdqQhY0GguOEzQq0)AOcrHACyBsHi5y3ZYsW86YnbcCtSdfIZU6XtQE0G(xlQquio7QhpP6rHWNf8znfc7yEXUissgKe7yizTrKulKSosYjFL68HjYGybIDrKSgsQfssGasIDmVyxejjdsIDmKS2iskSuOgh2Muio5R0kiSSeWpROD0G(FqQquio7QhpP6rHWNf8znfcVIvlqfNrKrY6i5VizLlmSF2jMblma7ydO5DfGKeiGKtUYfg2xTjpDvbO6ysExbi5puOgh2MuiLaltllb4Rtgq0WePb9VWsfIcXzx94jvpke(SGpRPqCYxPoFyImiwGyxejRHKCrg7gmimrgjjqajXoMxSlIKKbjXogsQ9isQHc14W2KcbBQqbwyaS7PJg0)fGkefIZU6XtQEuOgh2MuOZuwwcuUjGOHjsHWNf8znf6xKm6hNHNKJDpllbZRl3eiWnXoEo7QhprY6ijE33CjL(ZuwwcuUjGOHj6NUxh2MiznKeV7BUKspjh7EwwcMxxUjqGBID8hl2wQqs9rsHfj)bjRJK)IK4DFZLu6HnvOalma2905pwSTuHK1qYbrsceqsSJHK1grYcGK)qHW6Wpge9vYHI(xdnO)haQquio7QhpP6rHWNf8znfQYfg2FUkhllbdypzajlN(5skPqnoSnPqNRYXYsWa2tgqYYjnO)hiuHOqC2vpEs1JcHpl4ZAkeEfRwGkoJiJK1rYFrYFrs8UV5sk9vBYtxvaQoMK)yX2sfswdj1cjRJK)IKyhdjRHKdIKeiGK4DFZLu6HnvOalma2905pwSTuHK1qYbaj)bjRJK)IKyhdjRnIKfajjqajX7(MlP0dBQqbwyaS7PZFSyBPcjRHKAHK)GK)GKeiGKchsI3HC2z4tgF7BVjswhj5KVsD(WezqSaXUiswdjlXtK8hkuJdBtkKsGLPLLa81jdiAyI0G(xyqfIcXzx94jvpke(SGpRPqyhZl2frsYGKyhdjRnIKAOqnoSnPqCrb8d40NinO)hyQquio7QhpP6rHACyBsHGnvawyq4WasowWGWk5JcHpl4ZAke2X8IDrKKmij2XqYAJi5GuiSo8JbrFLCOO)1qd6FnFtfIcXzx94jvpke(SGpRPqyhZl2frsYGKyhdjRnIKArHACyBsHWogOY9ubnO)1OHkefIZU6XtQEui8zbFwtHQCHH9Hddyrb8TNcGBbn2I98QOXerYAiPMbgjRJKCYxPoFyImiwGyxejRHKCrg7gmimrgjjdsQbjRJK4DFZLu6HnvOalma2905pwSTuHK1qsUiJDdgeMitHACyBsHWxJj(SSemG9KbpR0jsllPb9VgTOcrH4SRE8KQhfQXHTjfkSs(ac6NifcFwWN1uiSJ5f7IijzqsSJHK1grsTqY6i5ViPWHKr)4m8owaWRy165SRE8ejjqajXRy1cuXzezK8hkewh(XGOVsou0)AOb9VMbPcrH4SRE8KQhfcFwWN1ui8kwTavCgrgjRJK4nNUw4X9d7(6GNavCgrw55SRE8Kc14W2KcPeyzAzjaFDYaIgMinO)1iSuHOqC2vpEs1JcHpl4ZAkeEfRwGkoJitHACyBsHWogGupKPb9VMcqfIcXzx94jvpkuJdBtke8tNLLafFc4maenmrke(SGpRPqvUWW(QLiqWTy)CjLuild(oxbbfsdnO)1mauHOqC2vpEs1Jc14W2Kcv9AmX1naenmrke(SGpRPq4vSAbQ4mImswhj)fjRCHH9vlrGGBXExbijbciz0podVJfa8kwTEo7QhprY6iPGJhckXtVgFyL8be0prKSosIDmKCej1cjRJK4DFZLu6HnvOalma2905pwSTuHKAJKdIKeiGKyhZl2frsYGKyhdj1Eej1GK1rsbhpeuINEnELaltllb4Rtgq0WerY6ijN8vQZhMidIfi2frsTrYbrYFOqyD4hdI(k5qr)RHg0GguOH8PSnP)16BT08TgT0qHi1xAzPIc91lily)lm)VG(lqsKuihgjnrb7fij8EijzjXTGnvGfgS3KpYIKhxW4Ahprs1kYiz7gRyh8ejXoDwYkp6ZxAjJKA(cK8R2CiFbprsYg9JZWl8KfjJfjjB0podVW75SRE8KSizhiPWub1xIK)QP4pE0NV0sgj16lqYVAZH8f8ejjB0podVWtwKmwKKSr)4m8cVNZU6XtYIKDGKctfuFjs(RMI)4rF(slzKuZa8fi5xT5q(cEIKKn6hNHx4jlsglss2OFCgEH3Zzx94jzrYF1u8hp6d6ZxVGSG9VW8)c6VajrsHCyK0efSxGKW7HKKvXhNwOJSi5XfmU2XtKuTIms2UXk2bprsStNLSYJ(8LwYiPgnFbs(vBoKVGNijzJ(Xz4fEYIKXIKKn6hNHx49C2vpEswKSdKuyQG6lrYF1u8hp6d6ZxVGSG9VW8)c6VajrsHCyK0efSxGKW7HKKfpbk(40cDKfjpUGX1oEIKQvKrY2nwXo4jsID6SKvE0NV0sgjh4Vaj)QnhYxWtKKSNBYW7vYEHNSizSijzp3KH3RK9cVNZU6XtYIK)QP4pE0h0NVEbzb7FH5)f0FbsIKc5WiPjkyVajH3djjRkilsECbJRD8ejvRiJKTBSIDWtKe70zjR8OpFPLmskSFbs(vBoKVGNijzJ(Xz4fEYIKXIKKn6hNHx49C2vpEswKSdKuyQG6lrYF1u8hp6ZxAjJKdWxGKF1Md5l4jss2OFCgEHNSizSijzJ(Xz4fEpND1JNKfj)vtXF8OpFPLmsQrZxGKF1Md5l4jssw8Mtxl8cpzrYyrsYI3C6AHx49C2vpEswK8xnf)XJ(8LwYiPMc8fi5xT5q(cEIKKn6hNHx4jlsglss2OFCgEH3Zzx94jzrYF1u8hp6d6ZxVGSG9VW8)c6VajrsHCyK0efSxGKW7HKKfpbkgMSi5XfmU2XtKuTIms2UXk2bprsStNLSYJ(8LwYi5GFbs(vBoKVGNijzp3KH3RK9cpzrYyrsYEUjdVxj7fEpND1JNKfj)vtXF8OpOpF9cYc2)cZ)lO)cKejfYHrstuWEbscVhss2jd3UVGSi5XfmU2XtKuTIms2UXk2bprsStNLSYJ(8LwYiPMV)cK8R2CiFbprsYg9JZWl8KfjJfjjB0podVW75SRE8KSizhiPWub1xIK)QP4pE0NV0sgj1O5lqYVAZH8f8ejjB0podVWtwKmwKKSr)4m8cVNZU6XtYIKDGKctfuFjs(RMI)4rFqF(6fKfS)fM)xq)fijskKdJKMOG9cKeEpKKS9YKfjpUGX1oEIKQvKrY2nwXo4jsID6SKvE0NV0sgjlWxGKF1Md5l4jss2OFCgEHNSizSijzJ(Xz4fEpND1JNKfj)vtXF8OpFPLmsQrRVaj)QnhYxWtKKSr)4m8cpzrYyrsYg9JZWl8Eo7Qhpjls(RMI)4rF(slzKuZGFbs(vBoKVGNijzXBoDTWl8KfjJfjjlEZPRfEH3Zzx94jzrYoqsHPcQVej)vtXF8OpFPLmsQza(cK8R2CiFbprsYg9JZWl8KfjJfjjB0podVW75SRE8KSi5VAk(Jh9b9rywuWEbprYbgjBCyBIKptfkp6dfQDdN9OqqM4xrHeClS9yk0afj)6woj1pI8HKFT3Ki6Zafj)0PBF6qsT0ICKuRV1sd6d6ZafjfIe3erYVgMkui5cJKFnCpDiPLbFNRGajFBPH9OpduKuisCtejHeyzAzjs(vxNms(1YWerY3wA4VMizpCTjso5xRtHKDorsldU86GrYVQFy3xh8ejHIZiYkp6d6ZafjfMkYy3GNizfdVhJK4vSQdKSIlTu5rYcsmMfekKm3Kmo9jc7(qYgh2MkKCZNop6tJdBtLxWX4vSQJrbByBI(04W2u5fCmEfR6q)XcR2iE8ea)AD8KKLLGylAj6tJdBtLxWX4vSQd9hlCyFwx9yYZwKhl6YjytGRIbXzjroiFfmQ4G8H9ZLh)g9PXHTPYl4y8kw1H(JfIDmqL7PcYn4rHl6hNHxXhNwOZZzx94jbccx0podpSPcWcdchgqYXcgewjFEo7QhprFACyBQ8cogVIvDO)yHyhdqQhYKBWJcx0podpN8vAfewwc4NvKppND1JNOpOpduKuyQiJDdEIK8q(0HKHjYiz4WizJJ9qstHK9W2ED1J9OpnoSnvJkbCFaNoNavCgrg9PXHTPs)Xch2N1vpM8Sf5rN9nbfD5K8vWOIdYh2pxEeV7BUKsVLdxImOOlNGWHbKCSGbHvYN)yX2svnyR0jahl2wQiqa2kDcWXITLkT1O131HTsNaCSyBPQgE33CjLEfFCAHo)XITLQ64DFZLu6v8XPf68hl2wQQP5B0Ngh2Mk9hluWg2MKBWJ)w5cd7v8XPf68UciqOYfg2RI9ebCFHdOZja2o27k4N6c4Wx0Ltq4WasowWGWk5Z34WgYeiaBLob4yX2sL2JdW3OpnoSnv6pwiUFpqJdBtWZub5zlYJk(40cDKBWJvUWWEfFCAHoVRa0Ngh2Mk9hle3VhOXHTj4zQG8Sf5rsClytfyHb7n5JCdESYfg2tIBbBQalmyVjFExbOpnoSnv6pwiUFpqJdBtWZub5zlYJRao5JCdEmmrwBHTo2X0Ua1fobC4l6YjiCyajhlyqyL85BCydz0Ngh2Mk9hle2ubyHbHddi5ybdcRKpYX6Wpge9vYHAud5g8i2X8IDrYGDSAJdw)xo5RuNpmrgelqSlQTgce4KVsD(WezqSaXUO2cBD8UV5sk9WMkuGfga7E68hl2wQ0wJVaeiG39nxsPNe3c2ubwyWEt(8hl2wQ0wRFqFACyBQ0FSqUOa(bC6tKCdEe7yEXUizWowTrn1)Lt(k15dtKbXce7IARHab8UV5sk9k(40cD(JfBlvARfbcCYxPoFyImiwGyxuBHToE33CjLEytfkWcdGDpD(JfBlvARXxaceW7(MlP0tIBbBQalmyVjF(JfBlvAR1pOpnoSnv6pwyyL8be0prYX6Wpge9vYHAud5g8iEfRwGkoJixh7yEXUizWowTrTQ)lN8vQZhMidIfi2f1wdbc4DFZLu6v8XPf68hl2wQ0wlce4KVsD(WezqSaXUO2cBD8UV5sk9WMkuGfga7E68hl2wQ0wJVaeiG39nxsPNe3c2ubwyWEt(8hl2wQ0wRFqFACyBQ0FSqC)EGgh2MGNPcYZwKhXtGIHj3GhfUOFCgEfFCAHo0Ngh2Mk9hle3VhOXHTj4zQG8Sf5r8eO4Jtl0rUbpg9JZWR4Jtl0H(04W2uP)yH4(9anoSnbptfKNTipQcYn4Xgh2qgWjlASs7brFACyBQ0FSqC)EGgh2MGNPcYZwKh7Lj3GhBCydzaNSOXQAJdI(G(04W2u57Lhj5y3ZYsW86YnbcCtSd6tJdBtLVxw)Xc5KVsRGWYsa)SI2rUbpIDmVyxKmyhR2Ow15KVsD(WezqSaXUynTiqa7yEXUizWowTrHf9PXHTPY3lR)yHkbwMwwcWxNmGOHjsUbpIxXQfOIZiY1)TYfg2p7eZGfgGDSb08UciqyYvUWW(Qn5PRkavhtY7k4h0Ngh2MkFVS(JfcBQqbwyaS7PJCdEKt(k15dtKbXce7I14Im2nyqyImbcyhZl2fjd2X0Eud6tJdBtLVxw)Xcptzzjq5MaIgMi5yD4hdI(k5qnQHCdE83OFCgEso29SSemVUCtGa3e7uhV7BUKs)zkllbk3eq0We9t3RdBZA4DFZLu6j5y3ZYsW86YnbcCtSJ)yX2sL(c7p1)fV7BUKspSPcfyHbWUNo)XITLQAdsGa2XQnwGFqFACyBQ89Y6pw45QCSSemG9KbKSCsUbpw5cd7pxLJLLGbSNmGKLt)CjLOpnoSnv(Ez9hlujWY0Ysa(6KbenmrYn4r8kwTavCgrU(V)I39nxsPVAtE6Qcq1XK8hl2wQQPv9FXowTbjqaV7BUKspSPcfyHbWUNo)XITLQAdWp1)f7y1glabc4DFZLu6HnvOalma2905pwSTuvtRF(HabHdVd5SZWNm(23EZ6CYxPoFyImiwGyxSwjE(d6tJdBtLVxw)Xc5Ic4hWPprYn4rSJ5f7IKb7y1g1G(04W2u57L1FSqytfGfgeomGKJfmiSs(ihRd)yq0xjhQrnKBWJyhZl2fjd2XQnoi6tJdBtLVxw)XcXogOY9ub5g8i2X8IDrYGDSAJAH(04W2u57L1FSq81yIpllbdypzWZkDI0YsYn4XkxyyF4WawuaF7Pa4wqJTypVkAmXAAg46CYxPoFyImiwGyxSgxKXUbdctKjJM64DFZLu6HnvOalma2905pwSTuvJlYy3GbHjYOpnoSnv(Ez9hlmSs(ac6Ni5yD4hdI(k5qnQHCdEe7yEXUizWowTrTQ)RWf9JZW7ybaVIvlbc4vSAbQ4mI8pOpduK8R6h291bprsO4mISc9PXHTPY3lR)yHkbwMwwcWxNmGOHjsUbpIxXQfOIZiY1XBoDTWJ7h291bpbQ4mISc9PXHTPY3lR)yHyhdqQhYKBWJ4vSAbQ4mIm6tJdBtLVxw)XcHF6SSeO4taNbGOHjsUbpw5cd7RwIab3I9ZLusULbFNRGyud6tJdBtLVxw)XcREnM46gaIgMi5yD4hdI(k5qnQHCdEeVIvlqfNrKR)BLlmSVAjceCl27kGaHOFCgEhla4vSARl44HGs80RXhwjFab9tSo2Xg1QoE33CjLEytfkWcdGDpD(JfBlvApibcyhZl2fjd2X0EutDbhpeuINEnELaltllb4Rtgq0WeRZjFL68HjYGybIDrTh8h0h0Ngh2MkpEcum8OLdxImOOlNGWHbKCSGbHvYh5g8OWnSpRRES3zFtqrxojqa2kDcWXITLkT1QaOpnoSnvE8eOyy9hlSpCNmi274mi3GhXoMxSlsgSJvBud6tJdBtLhpbkgw)XcJ1f7awyWK7WHCdEe2kDcWXITLQA)Qry8nzo3KH3RK9WD0pqSUyNcUgT((hceQCHH9Qypra3x4a6CcGTJ9ZLuwxah(IUCcchgqYXcgewjF(gh2qMabyR0jahl2wQ0wZ3OpnoSnvE8eOyy9hlKe3c2ubwyWEt(i3Gh)9ABc4HCg(EovElRjSfGaHRTjGhYz475u5Df8tD8UV5sk9NPSSeOCtardt0FSyBPsBUiJDdgeMiJ(04W2u5XtGIH1FSq4MFwYavSIci3GhXRy1cuXze56)ETnb8qodFpNkVL108nbcxBtapKZW3ZPY7k4h0Ngh2MkpEcumS(Jfc3VhNG9M8rUbpETnb8qodFpNkVL1g8BceU2MaEiNHVNtL3va6tJdBtLhpbkgw)XcR2KNUQauDmjYn4XRTjGhYz475u5TSwb(MaHRTjGhYz475u5Dfq(ZsgGNJdW3OpnoSnvE8eOyy9hluf7jc4(chqNtaSDma2k2btUbpI3C6AHhV7nTSdEcwyyov2q2Zzx94j6tJdBtLhpbkgw)XcvXEIaUVWb05eaBhtUbpI39nxsPxf7jc4(chqNtaSDSh70xjRg1IabyR0jahl2wQ0wRVjq43RTjGhYz475u5pwSTuvttbiqq4W7qo7m8e1DwN1)93RTjGhYz475u5TSgE33CjLEvSNiG7lCaDobW2XEy33dCm2PVsgeMitGGWDTnb8qodFpNkpx0uH6N6)I39nxsP3YHlrgu0Ltq4WasowWGWk5ZFSyBPQgE33CjLEvSNiG7lCaDobW2XEy33dCm2PVsgeMitGWW(SU6XEN9nbfD58NFQJ39nxsPh2uHcSWay3tN)yX2sL2JdCDSJvBuR64DFZLu6j5y3ZYsW86YnbcCtSJ)yX2sL2JA06h0Ngh2MkpEcumS(JfQI9ebCFHdOZja2oMCdEeVd5SZWtu3zDw)3kxyypjUfSPcSWG9M85DfqGWVWwPtaowSTuPnE33CjLEsClytfyHb7n5ZFSyBPIab8UV5sk9K4wWMkWcd2BYN)yX2svn8UV5sk9Qypra3x4a6CcGTJ9WUVh4yStFLmimr(N64DFZLu6HnvOalma2905pwSTuP94axh7y1g1QoE33CjLEso29SSemVUCtGa3e74pwSTuP9OgT(b9PXHTPYJNafdR)yHUkgyblQqFACyBQ84jqXW6pwySUyhWcdi2NytUbpcBLob4yX2svnnfyGjqqah(IUCcchgqYXcgewjF(gh2qMaHH9zD1J9o7Bck6Yj6tJdBtLhpbkgw)XcRE7obWUNoYn4r8UV5sk9woCjYGIUCcchgqYXcgewjF(JfBlv1g8Bceg2N1vp27SVjOOlNeiaBLob4yX2sL2A9n6tJdBtLhpbkgw)XcR4tXhrllj3GhX7(MlP0B5WLidk6YjiCyajhlyqyL85pwSTuvBWVjqyyFwx9yVZ(MGIUCsGaSv6eGJfBlvARPaOpnoSnvE8eOyy9hl8zLoHcmGUZsrod0Ngh2MkpEcumS(JfcBhx92DsUbpI39nxsP3YHlrgu0Ltq4WasowWGWk5ZFSyBPQ2GFtGWW(SU6XEN9nbfD5KabyR0jahl2wQ0wZ3OpnoSnvE8eOyy9hlStmRIRFaC)EKBWJ4DFZLu6TC4sKbfD5eeomGKJfmiSs(8hl2wQQn43eimSpRRES3zFtqrxojqa2kDcWXITLkT16B0Ngh2MkpEcumS(Jfw1LGfgeNHjQi3GhRCHH9Qypra3x4a6CcGTJ9ZLuI(G(04W2u5XtGIpoTq34W(SU6XKNTipQ4Jtl0bQCpvq(kyuXb5d7NlpI39nxsPxXhNwOZFSyBPsBneiiGdFrxobHddi5ybdcRKpFJdBixhV7BUKsVIpoTqN)yX2svTb)MabyR0jahl2wQ0wRVrFACyBQ84jqXhNwOt)XcTC4sKbfD5eeomGKJfmiSs(i3GhfUH9zD1J9o7Bck6YjbcWwPtaowSTuPTwfa9PXHTPYJNafFCAHo9hl0vXalyrf6tJdBtLhpbk(40cD6pwyF4ozqS3XzqUbpIDmVyxKmyhR2Og0Ngh2MkpEcu8XPf60FSWNv6ekWa6olf5mqFACyBQ84jqXhNwOt)XcHTJRE7oj3Ghh2N1vp2R4Jtl0bQCpvG(04W2u5XtGIpoTqN(Jf2jMvX1paUFpYn4XH9zD1J9k(40cDGk3tfOpnoSnvE8eO4Jtl0P)yHvDjyHbXzyIkYn4XH9zD1J9k(40cDGk3tfOpnoSnvE8eO4Jtl0P)yHX6IDalmyYD4qUbpcBLob4yX2svTF1im(MmNBYW7vYE4o6hiwxStbxJwF)dbcc4Wx0Ltq4WasowWGWk5Z34WgYeiaBLob4yX2sL2A(g9PXHTPYJNafFCAHo9hlmwxSdyHbe7tSj3GhHTsNaCSyBPQ2a)nbcc4Wx0Ltq4WasowWGWk5Z34WgYeiaBLob4yX2sL2A(g9PXHTPYJNafFCAHo9hlKe3c2ubwyWEt(i3GhX7(MlP0FMYYsGYnbenmr)XITLkT5Im2nyqyIm6tJdBtLhpbk(40cD6pwiCZplzGkwrbOpnoSnvE8eO4Jtl0P)yHW97XjyVjFOpnoSnvE8eO4Jtl0P)yHvBYtxvaQoMe6tJdBtLhpbk(40cD6pwOIpoTqh5g8iE33CjL(ZuwwcuUjGOHj6pwSTuPTweiaBLob4yX2sL2Aka6tJdBtLhpbk(40cD6pwyvxcwyqCgMOc9b9PXHTPYVc4KVrytfGfgeomGKJfmiSs(ihRd)yq03vYHAud5g8i2X8IDrYGDSAJdI(04W2u5xbCYN(JfYffWpGtFIKBWJr)4m8yhdu5EQWZzx94zDSJ5f7IKb7y1ghe9PXHTPYVc4Kp9hlmSs(ac6Ni5yD4hdI(k5qnQHCdEeVIvlqfNrKRJDmVyxKmyhR2OwOpnoSnv(vaN8P)yHyhdqQhYKBWJyhZl2fjd2Xg1c9PXHTPYVc4Kp9hlKlkGFaN(erFACyBQ8Rao5t)XcdRKpGG(jsowh(XGOVsouJAi3GhXoMxSlsgSJvBul0h0Ngh2MkVIpoTq3iSPcfyHbWUNoYn4XkxyyVIpoTqN)yX2sL2AqFACyBQ8k(40cD6pwORIbwWIk0Ngh2MkVIpoTqN(JfQeyzAzjaFDYaIgMi5g8iEfRwGkoJix)3gh2qgWjlASQ24Gei04WgYaozrJv10ux4W7(MlP0FMYYsGYnbenmrVRGFqFACyBQ8k(40cD6pw4zkllbk3eq0WejhRd)yq0xjhQrnKBWJ4vSAbQ4mIm6tJdBtLxXhNwOt)XcHnvOalma290rUbp24WgYaozrJv1ghe9PXHTPYR4Jtl0P)yHkbwMwwcWxNmGOHjsUbpIxXQfOIZiY1RCHH9ZoXmyHbyhBanVRa0Ngh2MkVIpoTqN(Jfw9AmX1naenmrYX6Wpge9vYHAud5g8iEfRwGkoJixVYfg2tIBbBQalmyVjFasK8UcQJ39nxsP)mLLLaLBciAyI(JfBlv10c9PXHTPYR4Jtl0P)yHWMkuGfga7E6i3YGVZvqam4XkxyyVIpoTqN3vqD8UV5sk9NPSSeOCtardt0FCp1H(04W2u5v8XPf60FSqLaltllb4Rtgq0Wej3GhXRy1cuXze56tUYfg2xTjpDvbO6ysExbOpnoSnvEfFCAHo9hle2ubyHbHddi5ybdcRKpYX6Wpge9vYHAud5g8i2X0Eq0Ngh2MkVIpoTqN(Jfw9AmX1naenmrYX6Wpge9vYHAud5g8iEfRwGkoJitGGWf9JZW7ybaVIvl6tJdBtLxXhNwOt)XcvcSmTSeGVozardte9b9PXHTPYRIrso29SSemVUCtGa3e7qUbpETnb8qodFpNkVL1W7(MlP0tYXUNLLG51LBce4Myh)096W2SG)TxyqGW12eWd5m89CQ8UcqFACyBQ8Qq)Xc5KVsRGWYsa)SI2rUbpIDmVyxKmyhR2Ow15KVsD(WezqSaXUyTbjqa7yEXUizWowTrHT(VCYxPoFyImiwGyxSMweiiCcoEiOep9A8HvYhqq)e)b9PXHTPYRc9hlujWY0Ysa(6KbenmrYn4r8kwTavCgrUELlmSF2jMblma7ydO5Dfu)3RTjGhYz475u5TSwLlmSF2jMblma7ydO5pwSTurgTiq4ABc4HCg(EovExb)G(04W2u5vH(JfEMYYsGYnbenmrYX6Wpge9vYHAud5g8iE33CjLEfFCAHo)XITLQAAiqq4I(Xz4v8XPf6qFACyBQ8Qq)XcHnvOalma290rUbp(712eWd5m89CQ8wwdV7BUKspSPcfyHbWUNo)096W2SG)TxyqGW12eWd5m89CQ8Uc(P(VCYxPoFyImiwGyxSgxKXUbdctKjJgceWoMxSlsgSJP9OgceQCHH9Qypra3x4a6CcGTJ9hl2wQ0MlYy3GbHjY6R5hceGTsNaCSyBPsBUiJDdgeMiRVg0Ngh2MkVk0FSq81yIpllbdypzWZkDI0YsYn4XkxyyF4WawuaF7Pa4wqJTypVkAmXAAg46CYxPoFyImiwGyxSgxKXUbdctKjJM64DFZLu6ptzzjq5MaIgMO)yX2svnUiJDdgeMitGqLlmSpCyalkGV9uaClOXwSNxfnMynncB9FX7(MlP0R4Jtl05pwSTuPDbQh9JZWR4Jtl0rGaE33CjLEsClytfyHb7n5ZFSyBPs7cuhVd5SZWtu3zDsGaSv6eGJfBlvAxGFqFACyBQ8Qq)XcpxLJLLGbSNmGKLtYn4Xkxyy)5QCSSemG9KbKSC6NlPSEJdBid4Kfnwvtd6tJdBtLxf6pwiSPcWcdchgqYXcgewjFKJ1HFmi6RKd1OgYn4rSJP9GOpnoSnvEvO)yHCrb8d40Ni5g8i2X8IDrYGDSAJAqFACyBQ8Qq)XcXogOY9ub5g8i2X8IDrYGDSAJAQ34WgYaozrJvJAQFTnb8qodFpNkVL106BceWoMxSlsgSJvBuR6noSHmGtw0yvTrTqFACyBQ8Qq)XcvcSmTSeGVozardtKCdEeVIvlqfNrKRJ3C6AHh3pS7RdEcuXzezvDLa(9arFLCO8kbwMwwcWxNmGOHjwtd6tJdBtLxf6pwi2XaK6Hm6tJdBtLxf6pwyyL8be0prYX6Wpge9vYHAud5g8iEfRwGkoJixh7yEXUizWowTrTQx5cd7vXEIaUVWb05eaBh7NlPe9PXHTPYRc9hlujWY0Ysa(6KbenmrYn4Xkxyyp2XaCYxPoVkAmXAd(nzkqbVXHnKbCYIgRQx5cd7vXEIaUVWb05eaBh7NlPS(V4DFZLu6ptzzjq5MaIgMO)yX2svnTQJ39nxsPh2uHcSWay3tN)yX2svnTiqaV7BUKs)zkllbk3eq0We9hl2wQ0EW64DFZLu6HnvOalma2905pwSTuvBW6yhR2GeiG39nxsP)mLLLaLBciAyI(JfBlv1gSoE33CjLEytfkWcdGDpD(JfBlvApyDSJvtyjqa7yEXUizWoM2JAQZjFL68HjYGybIDrT16hceQCHH9yhdWjFL68QOXeRP576WwPtaowSTuP9ab9PXHTPYRc9hlS61yIRBaiAyIKJ1HFmi6RKd1OgYn4r8kwTavCgrU(Vr)4m8k(40cD1X7(MlP0R4Jtl05pwSTuP9GeiG39nxsP)mLLLaLBciAyI(JfBlv10uhV7BUKspSPcfyHbWUNo)XITLQAAiqaV7BUKs)zkllbk3eq0We9hl2wQ0EW64DFZLu6HnvOalma2905pwSTuvBW6yhRMweiG39nxsP)mLLLaLBciAyI(JfBlv1gSoE33CjLEytfkWcdGDpD(JfBlvApyDSJvBqceWowTcqGqLlmSVAjceCl27k4h0Ngh2MkVk0FSWWk5diOFIKJ1HFmi6RKd1OgYn4r8kwTavCgrUo2X8IDrYGDSAJAH(04W2u5vH(Jfc)0zzjqXNaodardtKCld(oxbXOg0Ngh2MkVk0FSWQxJjUUbGOHjsowh(XGOVsouJAi3GhXRy1cuXze564DFZLu6HnvOalma2905pwSTuP9G1Xo2Ow1fC8qqjE614dRKpGG(jwNt(k15dtKbXckW3ARb9PXHTPYRc9hlS61yIRBaiAyIKJ1HFmi6RKd1OgYn4r8kwTavCgrUoN8vQZhMidIfi2f1wR6)IDmVyxKmyht7rneii44HGs80RXhwjFab9t8h0h0Ngh2MkpjUfSPcSWG9M8nI73d04W2e8mvqE2I8iEcumm5g8OWf9JZWR4Jtl0H(04W2u5jXTGnvGfgS3Kp9hle3VhOXHTj4zQG8Sf5r8eO4Jtl0rUbpg9JZWR4Jtl0H(04W2u5jXTGnvGfgS3Kp9hlKt(kTccllb8ZkAh5g8i2X8IDrYGDSAJAvNt(k15dtKbXce7I1ge9PXHTPYtIBbBQalmyVjF6pw4zkllbk3eq0WejhRd)yq0xjhQrnOpnoSnvEsClytfyHb7n5t)XcvcSmTSeGVozardtKCdEeVIvlqfNrKRx5cd7NDIzWcdWo2aAExbOpnoSnvEsClytfyHb7n5t)XcHnvOalma290rUbp24WgYaozrJv1g1QELlmSNe3c2ubwyWEt(aKi5pwSTuPTg0Ngh2MkpjUfSPcSWG9M8P)yHKCS7zzjyED5MabUj2HCdESXHnKbCYIgRQnQf6tJdBtLNe3c2ubwyWEt(0FSqLaltllb4Rtgq0Wej3GhXRy1cuXze56noSHmGtw0yvTXbRx5cd7jXTGnvGfgS3KpajsExbOpnoSnvEsClytfyHb7n5t)XcREnM46gaIgMi5yD4hdI(k5qnQHCdEeVIvlqfNrKR34WgYaozrJvApQf6tJdBtLNe3c2ubwyWEt(0FSqso29SSemVUCtGa3e7G(04W2u5jXTGnvGfgS3Kp9hle2uHcSWay3th5wg8DUccGbpw5cd7jXTGnvGfgS3KpajsExbKBWJvUWWEvSNiG7lCaDobW2XExb1V2MaEiNHVNtL3YA4DFZLu6HnvOalma2905NUxh2Mf8V9da6tJdBtLNe3c2ubwyWEt(0FSqLaltllb4Rtgq0Wej3GhRCHH9yhdWjFL68QOXeRn43KPaf8gh2qgWjlASc9PXHTPYtIBbBQalmyVjF6pwiSPcWcdchgqYXcgewjFKJ1HFmi6RKd1OgYn4rSJP9GOpnoSnvEsClytfyHb7n5t)Xc5Ic4hWPprYn4rSJ5f7IKb7y1g1G(04W2u5jXTGnvGfgS3Kp9hle7yGk3tfKBWJyhZl2fjd2XQn(Rg9BCydzaNSOXQAA(b9PXHTPYtIBbBQalmyVjF6pwyyL8be0prYX6Wpge9vYHAud5g84Vcx0podVJfa8kwTeiGxXQfOIZiY)uh7yEXUizWowTrTqFACyBQ8K4wWMkWcd2BYN(JfIDmaPEiJ(04W2u5jXTGnvGfgS3Kp9hlS61yIRBaiAyIKJ1HFmi6RKd1OgYn4rSJvBCqceQCHH9K4wWMkWcd2BYhGejVRa0Ngh2MkpjUfSPcSWG9M8P)yHWpDwwcu8jGZaq0Wej3YGVZvqmQHg0Gsb]] )

end