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
    
    spec:RegisterPack( "Windwalker", 20210121, [[dSuk5bqicL8ijvQ2Kc8jeLgLQkDkvvSkjG6vKQAwiQUfIIDrv)scAyQk1XiOLri9mjvnncfDnjqBtsL8njvkJJqHoNKkADQkH3PQKIMhHQ7Pq7ts5Gsa0cjv5HQkjxKqb2OQsk8rja1jjuqRuvXlvvsjZuvj6MQkPu7uvv)ucqwQeq6PaMkH4RQkPASek1Er6VGgmrhwQfljpgQjROlJAZa9zjA0uXPPSAjv41i0SvLBtk7w0VvA4e44saXYv55KmDHRtL2Uc67iY4LqNNuz9say(iy)qMkKkcfy2bt)l63Ik8BHIk0l631xVO1jfi0jGPacAmXUKPazRXuGVULts9JiFuabTU32tQiua16EyMcqbQCTxigM0kkWSdM(x0Vfv43cfvOx0VRVErfLcOeWy6FrRR6Kc4yZjN0kkWKvykqDhj)6woj1pI8HKFT3Ki6tDhj)0PBF6qsrfsosk63Ike9b9PUJKIqIBIi5xdtfkKCbrYVgUNoK0YGVZvqGKVT0WE0N6oskcjUjIKacSmTSej)QRtgj)AzyIi5Bln8xtKShU2ejN8R1PqYoNiPLbxEDWi5x1pS7RdEIKaXzezLNc8mvOOIqbwbCYhve6FHurOaC2vpEs1Jc04W2KcaAQaUGWWHHKCSGHHvYhfaFwWN1uaSJ516IijzqsSJHK1grY6PayD4hdJ(UsouuaH0G(xuQiuao7QhpP6rbWNf8znfi6hNHh7yWk3tfEo7QhprYbij2X8ADrKKmij2XqYAJiz9uGgh2MuaUOa(bD6tJg0)1tfHcWzx94jvpkqJdBtkqyL8bf0pnka(SGpRPa4vRAHQ4mImsoajXoMxRlIKKbjXogswBejfLcG1HFmm6RKdf9VqAq)lMurOaC2vpEs1JcGpl4ZAka2X8ADrKKmij2XqYrKuukqJdBtka2XGK6HmnO)livekqJdBtkaxua)Go9Prb4SRE8KQhnO)RlQiuao7QhpP6rbACyBsbcRKpOG(PrbWNf8znfa7yETUissgKe7yizTrKuukawh(XWOVsou0)cPbnOaK4wWMk4cc3BYhve6FHurOaC2vpEs1JcGpl4ZAkGyHKr)4m8k(40cDEo7QhpPanoSnPa4(9GnoSnHptfuGNPcy2AmfapHkgKg0)IsfHcWzx94jvpka(SGpRPar)4m8k(40cDEo7QhpPanoSnPa4(9GnoSnHptfuGNPcy2AmfapHk(40cD0G(VEQiuao7QhpP6rbWNf8znfa7yETUissgKe7yizTrKuuKCasYjFL68HPXWyHADrKSgswpfOXHTjfGt(kTcallH8ZkAhnO)ftQiuao7QhpP6rbACyBsbotzzju5MqIgMifaRd)yy0xjhk6FH0G(VGurOaC2vpEs1JcGpl4ZAkaE1QwOkoJiJKdqYkxqq)Stmdxqi2XQdZ7kGc04W2KcOeyzAzjeFDYqIgMinO)RlQiuao7QhpP6rbWNf8znfOXHnKHCYAgRqYAJiPOi5aKSYfe0tIBbBQGliCVjFqsK8hR1wQqsXrsHuGgh2Muaqtfk4ccbDpD0G(VUrfHcWzx94jvpka(SGpRPanoSHmKtwZyfswBejfLc04W2KcqYXUNLLW51LBcf4MyhAq)lgPIqb4SRE8KQhfaFwWN1ua8QvTqvCgrgjhGKnoSHmKtwZyfswBejRhjhGKvUGGEsClytfCbH7n5dsIK3vafOXHTjfqjWY0Ysi(6KHenmrAq)xNurOaC2vpEs1Jc04W2Kcu9AmX1nGenmrka(SGpRPa4vRAHQ4mImsoajBCydziNSMXkKu8rKuukawh(XWOVsou0)cPb9VWVPIqbACyBsbi5y3ZYs486YnHcCtSdfGZU6XtQE0G(xOqQiuao7QhpP6rbWNf8znfOYfe0RI90GCFHdSZje0o27kajhGKxBtipKZW3ZPYBjswdjX7(MlP0dAQqbxqiO7PZpDVoSnrYcms(TVUOanoSnPaGMkuWfec6E6Oawg8DUccObsbQCbb9K4wWMk4cc3BYhKejVRaAq)luuQiuao7QhpP6rbWNf8znfOYfe0JDmiN8vQZRIgtejRHK1)nssgKSGizbgjBCydziNSMXkkqJdBtkGsGLPLLq81jdjAyI0G(xy9urOaC2vpEs1Jc04W2KcaAQaUGWWHHKCSGHHvYhfaFwWN1uaSJHKIJK1tbW6Wpgg9vYHI(xinO)fkMurOaC2vpEs1JcGpl4ZAka2X8ADrKKmij2XqYAJiPqkqJdBtkaxua)Go9Prd6FHfKkcfGZU6XtQEua8zbFwtbWoMxRlIKKbjXogswBej)fjfIK6JKnoSHmKtwZyfswdjfIK)qbACyBsbWogSY9ubnO)fwxurOaC2vpEs1Jc04W2KcewjFqb9tJcGpl4ZAkWViPyHKr)4m8owaXRw165SRE8ejjqajXRw1cvXzezK8hKCasIDmVwxejjdsIDmKS2iskkfaRd)yy0xjhk6FH0G(xyDJkcfOXHTjfa7yqs9qMcWzx94jvpAq)lumsfHcWzx94jvpkqJdBtkq1RXex3as0WePa4Zc(SMcGDmKS2iswpssGasw5cc6jXTGnvWfeU3KpijsExbuaSo8JHrFLCOO)fsd6FH1jvekGLbFNRGGciKc04W2Kca(0zzjuXNaodirdtKcWzx94jvpAqdkGIpoTqhve6FHurOaC2vpEs1JcGpl4ZAkqLliOxXhNwOZFSwBPcjfhjfsbACyBsbanvOGlie090rd6FrPIqbACyBsbCvm0cwtrb4SRE8KQhnO)RNkcfGZU6XtQEua8zbFwtbWRw1cvXzezKCas(ls24WgYqoznJvizTrKSEKKabKSXHnKHCYAgRqYAiPqKCaskwijE33CjL(ZuwwcvUjKOHj6DfGK)qbACyBsbucSmTSeIVozirdtKg0)IjvekaND1JNu9OanoSnPaNPSSeQCtirdtKcGpl4ZAkaE1QwOkoJitbW6Wpgg9vYHI(xinO)livekaND1JNu9Oa4Zc(SMc04WgYqoznJvizTrKSEkqJdBtkaOPcfCbHGUNoAq)xxurOaC2vpEs1JcGpl4ZAkaE1QwOkoJiJKdqYkxqq)Stmdxqi2XQdZ7kGc04W2KcOeyzAzjeFDYqIgMinO)RBurOaC2vpEs1Jc04W2Kcu9AmX1nGenmrka(SGpRPa4vRAHQ4mImsoajRCbb9K4wWMk4cc3BYhKejVRaKCasI39nxsP)mLLLqLBcjAyI(J1AlviznKuukawh(XWOVsou0)cPb9VyKkcfWYGVZvqanqkqLliOxXhNwOZ7kyaE33CjL(ZuwwcvUjKOHj6pUN6OanoSnPaGMkuWfec6E6OaC2vpEs1Jg0)1jvekaND1JNu9Oa4Zc(SMcGxTQfQIZiYi5aKCYvUGG(Qn5PRkGvhtY7kGc04W2KcOeyzAzjeFDYqIgMinO)f(nvekaND1JNu9OanoSnPaGMkGlimCyijhlyyyL8rbWNf8znfa7yiP4iz9uaSo8JHrFLCOO)fsd6FHcPIqb4SRE8KQhfOXHTjfO61yIRBajAyIua8zbFwtbWRw1cvXzezKKabKuSqYOFCgEhlG4vRA9C2vpEsbW6Wpgg9vYHI(xinO)fkkvekqJdBtkGsGLPLLq81jdjAyIuao7QhpP6rdAqbWtOIpoTqhve6FHurOaC2vpEs1JcScOakoOanoSnPad7Z6Qhtbg2pxMcG39nxsPxXhNwOZFSwBPcjfhjfIKeiGKc4Wx0Lty4WqsowWWWk5Z34WgYi5aKeV7BUKsVIpoTqN)yT2sfswdjR)BKKabKe0kDc4XATLkKuCKu0VPad7dMTgtbu8XPf6GvUNkOb9VOurOaC2vpEs1JcGpl4ZAkGyHKd7Z6Qh7D23ew0LtKKabKe0kDc4XATLkKuCKu0csbACyBsbSC4sKHfD5Kg0)1tfHc04W2Kc4QyOfSMIcWzx94jvpAq)lMurOaC2vpEs1JcGpl4ZAka2X8ADrKKmij2XqYAJiPqkqJdBtkqF4ozyS3Xzqd6)csfHc04W2Kc8SsNqbRd3zPgNbfGZU6XtQE0G(VUOIqb4SRE8KQhfaFwWN1uGH9zD1J9k(40cDWk3tfuGgh2Muaq74Q3UtAq)x3OIqb4SRE8KQhfaFwWN1uGH9zD1J9k(40cDWk3tfuGgh2MuGoXSkU(bX97rd6FXivekaND1JNu9Oa4Zc(SMcmSpRRESxXhNwOdw5EQGc04W2Kcu1LWfegNHjQOb9FDsfHcWzx94jvpka(SGpRPaGwPtapwRTuHK1qYFrsHIXVrsYGKNBYG7vYEWo6hmwxSJNZU6XtKSaJKcf9BK8hKKabKuah(IUCcdhgsYXcggwjF(gh2qgjjqajbTsNaESwBPcjfhjf(nfOXHTjfiwxSdCbHtUdhAq)l8BQiuao7QhpP6rbWNf8znfa0kDc4XATLkKSgswNFJKeiGKc4Wx0Lty4WqsowWWWk5Z34WgYijbcijOv6eWJ1AlviP4iPWVPanoSnPaX6IDGliKyFAnnO)fkKkcfGZU6XtQEua8zbFwtbW7(MlP0FMYYsOYnHenmr)XATLkKuCKKlYy3GHHPXuGgh2MuasClytfCbH7n5Jg0)cfLkcfOXHTjfaS5NLmufRMakaND1JNu9Ob9VW6PIqbACyBsba73Jt4Et(OaC2vpEs1Jg0)cftQiuGgh2MuGQn5PRkGvhtIcWzx94jvpAq)lSGurOaC2vpEs1JcGpl4ZAkaE33CjL(ZuwwcvUjKOHj6pwRTuHKIJKIIKeiGKGwPtapwRTuHKIJKclifOXHTjfqXhNwOJg0)cRlQiuGgh2MuGQUeUGW4mmrffGZU6XtQE0GguavqfH(xivekaND1JNu9Oa4Zc(SMcCTnH8qodFpNkVLiznKeV7BUKspjh7EwwcNxxUjuGBID8t3RdBtKSaJKF7fJijbci512eYd5m89CQ8UcOanoSnPaKCS7zzjCED5MqbUj2Hg0)IsfHcWzx94jvpka(SGpRPayhZR1frsYGKyhdjRnIKIIKdqso5RuNpmnggluRlIK1qY6rsceqsSJ516IijzqsSJHK1grsXejhGK)IKCYxPoFyAmmwOwxejRHKIIKeiGKIfsk44HWs80l0hwjFqb9tdj)Hc04W2KcWjFLwbGLLq(zfTJg0)1tfHcWzx94jvpka(SGpRPa4vRAHQ4mImsoajRCbb9ZoXmCbHyhRomVRaKCas(lsETnH8qodFpNkVLiznKSYfe0p7eZWfeIDS6W8hR1wQqsYGKIIKeiGKxBtipKZW3ZPY7kaj)Hc04W2KcOeyzAzjeFDYqIgMinO)ftQiuao7QhpP6rbACyBsbotzzju5MqIgMifaFwWN1ua8UV5sk9k(40cD(J1AlviznKuissGaskwiz0podVIpoTqNNZU6Xtkawh(XWOVsou0)cPb9FbPIqb4SRE8KQhfaFwWN1uGFrYRTjKhYz475u5TejRHK4DFZLu6bnvOGlie0905NUxh2Mizbgj)2lgrsceqYRTjKhYz475u5DfGK)GKdqYFrso5RuNpmnggluRlIK1qsUiJDdggMgJKKbjfIKeiGKyhZR1frsYGKyhdjfFejfIKeiGKvUGGEvSNgK7lCGDoHG2X(J1AlviP4ijxKXUbddtJrs9rsHi5pijbcijOv6eWJ1AlviP4ijxKXUbddtJrs9rsHuGgh2Muaqtfk4ccbDpD0G(VUOIqb4SRE8KQhfaFwWN1uGkxqqF4WqwtaF7PG4wqJTypVkAmrKSgskSorYbijN8vQZhMgdJfQ1frYAijxKXUbddtJrsYGKcrYbijE33CjL(ZuwwcvUjKOHj6pwRTuHK1qsUiJDdggMgJKeiGKvUGG(WHHSMa(2tbXTGgBXEEv0yIiznKuOyIKdqYFrs8UV5sk9k(40cD(J1AlviP4izbrYbiz0podVIpoTqNNZU6XtKKabKeV7BUKspjUfSPcUGW9M85pwRTuHKIJKfejhGK4DiNDgEI6oRtKKabKe0kDc4XATLkKuCKSGi5puGgh2Mua81yIpllH1rpz4ZkDI0YsAq)x3OIqb4SRE8KQhfaFwWN1uGkxqq)5QCSSewh9KHKSC6NlPejhGKnoSHmKtwZyfswdjfsbACyBsboxLJLLW6ONmKKLtAq)lgPIqb4SRE8KQhfOXHTjfa0ubCbHHddj5ybddRKpka(SGpRPayhdjfhjRNcG1HFmm6RKdf9VqAq)xNurOaC2vpEs1JcGpl4ZAka2X8ADrKKmij2XqYAJiPqkqJdBtkaxua)Go9Prd6FHFtfHcWzx94jvpka(SGpRPayhZR1frsYGKyhdjRnIKcrYbizJdBid5K1mwHKJiPqKCasETnH8qodFpNkVLiznKu0VrsceqsSJ516IijzqsSJHK1grsrrYbizJdBid5K1mwHK1grsrPanoSnPayhdw5EQGg0)cfsfHcWzx94jvpka(SGpRPa4nNUw4X9d7(6GNqvCgrw55SRE8ejhGKkb87bJ(k5q5vcSmTSeIVozirdtejRHKcPanoSnPakbwMwwcXxNmKOHjsd6FHIsfHc04W2KcGDmiPEitb4SRE8KQhnO)fwpvekaND1JNu9OanoSnPaHvYhuq)0Oa4Zc(SMcGxTQfQIZiYi5aKe7yETUissgKe7yizTrKuuKCasw5cc6vXEAqUVWb25ecAh7NlPKcG1HFmm6RKdf9VqAq)lumPIqb4SRE8KQhfaFwWN1uGkxqqp2XGCYxPoVkAmrKSgsw)3ijzqYcIKfyKSXHnKHCYAgRqYbizLliOxf7Pb5(chyNtiODSFUKsKCas(lsI39nxsP)mLLLqLBcjAyI(J1AlviznKuuKCasI39nxsPh0uHcUGqq3tN)yT2sfswdjffjjqajX7(MlP0FMYYsOYnHenmr)XATLkKuCKSEKCasI39nxsPh0uHcUGqq3tN)yT2sfswdjRhjhGKyhdjRHK1JKeiGK4DFZLu6ptzzju5MqIgMO)yT2sfswdjRhjhGK4DFZLu6bnvOGlie0905pwRTuHKIJK1JKdqsSJHK1qsXejjqajXoMxRlIKKbjXogsk(iskejhGKCYxPoFyAmmwOwxejfhjffj)bjjqajRCbb9yhdYjFL68QOXerYAiPWVrYbijOv6eWJ1AlviP4izDJc04W2KcOeyzAzjeFDYqIgMinO)fwqQiuao7QhpP6rbACyBsbQEnM46gqIgMifaFwWN1ua8QvTqvCgrgjhGK)IKr)4m8k(40cDEo7QhprYbijE33CjLEfFCAHo)XATLkKuCKSEKKabKeV7BUKs)zkllHk3es0We9hR1wQqYAiPqKCasI39nxsPh0uHcUGqq3tN)yT2sfswdjfIKeiGK4DFZLu6ptzzju5MqIgMO)yT2sfskoswpsoajX7(MlP0dAQqbxqiO7PZFSwBPcjRHK1JKdqsSJHK1qsrrsceqs8UV5sk9NPSSeQCtirdt0FSwBPcjRHK1JKdqs8UV5sk9GMkuWfec6E68hR1wQqsXrY6rYbij2XqYAiz9ijbcij2XqYAizbrsceqYkxqqF1sek4wS3vas(dfaRd)yy0xjhk6FH0G(xyDrfHcWzx94jvpkqJdBtkqyL8bf0pnka(SGpRPa4vRAHQ4mImsoajXoMxRlIKKbjXogswBejfLcG1HFmm6RKdf9VqAq)lSUrfHcyzW35kiOacPanoSnPaGpDwwcv8jGZas0WePaC2vpEs1Jg0)cfJurOaC2vpEs1Jc04W2Kcu9AmX1nGenmrka(SGpRPa4vRAHQ4mImsoajX7(MlP0dAQqbxqiO7PZFSwBPcjfhjRhjhGKyhdjhrsrrYbiPGJhclXtVqFyL8bf0pnKCasYjFL68HPXWyHf8BKuCKuifaRd)yy0xjhk6FH0G(xyDsfHcWzx94jvpkqJdBtkq1RXex3as0WePa4Zc(SMcGxTQfQIZiYi5aKKt(k15dtJHXc16IiP4iPOi5aK8xKe7yETUissgKe7yiP4JiPqKKabKuWXdHL4PxOpSs(Gc6Ngs(dfaRd)yy0xjhk6FH0Ggua8eQyqQi0)cPIqb4SRE8KQhfaFwWN1uaXcjh2N1vp27SVjSOlNijbcijOv6eWJ1AlviP4iPOfKc04W2Kcy5WLidl6YjnO)fLkcfGZU6XtQEua8zbFwtbWoMxRlIKKbjXogswBejfsbACyBsb6d3jdJ9oodAq)xpvekaND1JNu9Oa4Zc(SMcaALob8yT2sfswdj)fjfkg)gjjdsEUjdUxj7b7OFWyDXoEo7QhprYcmsku0VrYFqsceqYkxqqVk2tdY9foWoNqq7y)CjLi5aKuah(IUCcdhgsYXcggwjF(gh2qgjjqajbTsNaESwBPcjfhjf(nfOXHTjfiwxSdCbHtUdhAq)lMurOaC2vpEs1JcGpl4ZAkWVi512eYd5m89CQ8wIK1qsXSGijbci512eYd5m89CQ8UcqYFqYbijE33CjL(ZuwwcvUjKOHj6pwRTuHKIJKCrg7gmmmnMc04W2KcqIBbBQGliCVjF0G(VGurOaC2vpEs1JcGpl4ZAkaE1QwOkoJiJKdqYFrYRTjKhYz475u5TejRHKc)gjjqajV2MqEiNHVNtL3vas(dfOXHTjfaS5NLmufRMaAq)xxurOaC2vpEs1JcGpl4ZAkW12eYd5m89CQ8wIK1qY6)gjjqajV2MqEiNHVNtL3vafOXHTjfaSFpoH7n5Jg0)1nQiuao7QhpP6rbWNf8znf4ABc5HCg(EovElrYAizb)gjjqajV2MqEiNHVNtL3vafOXHTjfOAtE6Qcy1XKOaplziEsbQRVPb9VyKkcfGZU6XtQEua8zbFwtbWBoDTWJ39Mw2bpHliiNkBi75SRE8Kc04W2KcOI90GCFHdSZje0ogcAf7GPb9FDsfHcWzx94jvpka(SGpRPa4DFZLu6vXEAqUVWb25ecAh7Xo9vYkKCejffjjqajbTsNaESwBPcjfhjf9BKKabK8xK8ABc5HCg(Eov(J1AlviznKuybrsceqsXcjX7qo7m8e1DwNi5aK8xK8xK8ABc5HCg(EovElrYAijE33CjLEvSNgK7lCGDoHG2XEq33dEm2PVsggMgJKeiGKIfsETnH8qodFpNkpx0uHcj)bjhGK)IK4DFZLu6TC4sKHfD5egomKKJfmmSs(8hR1wQqYAijE33CjLEvSNgK7lCGDoHG2XEq33dEm2PVsggMgJKeiGKd7Z6Qh7D23ew0LtK8hK8hKCasI39nxsPh0uHcUGqq3tN)yT2sfsk(iswNi5aKe7yizTrKuuKCasI39nxsPNKJDpllHZRl3ekWnXo(J1AlviP4JiPqrrYFOanoSnPaQypni3x4a7CcbTJPb9VWVPIqb4SRE8KQhfaFwWN1ua8oKZodprDN1jsoaj)fjRCbb9K4wWMk4cc3BYN3vassGas(lscALob8yT2sfskosI39nxsPNe3c2ubxq4Et(8hR1wQqsceqs8UV5sk9K4wWMk4cc3BYN)yT2sfswdjX7(MlP0RI90GCFHdSZje0o2d6(EWJXo9vYWW0yK8hKCasI39nxsPh0uHcUGqq3tN)yT2sfsk(iswNi5aKe7yizTrKuuKCasI39nxsPNKJDpllHZRl3ekWnXo(J1AlviP4JiPqrrYFOanoSnPaQypni3x4a7CcbTJPb9VqHurOanoSnPaUkgAbRPOaC2vpEs1Jg0)cfLkcfGZU6XtQEua8zbFwtbaTsNaESwBPcjRHKclyDIKeiGKc4Wx0Lty4WqsowWWWk5Z34WgYijbci5W(SU6XEN9nHfD5Kc04W2KceRl2bUGqI9P10G(xy9urOaC2vpEs1JcGpl4ZAkaE33CjLElhUezyrxoHHddj5ybddRKp)XATLkKSgsw)3ijbci5W(SU6XEN9nHfD5ejjqajbTsNaESwBPcjfhjf9BkqJdBtkq1B3je090rd6FHIjvekaND1JNu9Oa4Zc(SMcG39nxsP3YHlrgw0Lty4WqsowWWWk5ZFSwBPcjRHK1)nssGasoSpRRES3zFtyrxorsceqsqR0jGhR1wQqsXrsHfKc04W2KcuXNIpIwwsd6FHfKkcfOXHTjf4zLoHcwhUZsnodkaND1JNu9Ob9VW6IkcfGZU6XtQEua8zbFwtbW7(MlP0B5WLidl6YjmCyijhlyyyL85pwRTuHK1qY6)gjjqajh2N1vp27SVjSOlNijbcijOv6eWJ1AlviP4iPWVPanoSnPaG2XvVDN0G(xyDJkcfGZU6XtQEua8zbFwtbW7(MlP0B5WLidl6YjmCyijhlyyyL85pwRTuHK1qY6)gjjqajh2N1vp27SVjSOlNijbcijOv6eWJ1AlviP4iPOFtbACyBsb6eZQ46he3VhnO)fkgPIqb4SRE8KQhfaFwWN1uGkxqqVk2tdY9foWoNqq7y)CjLuGgh2MuGQUeUGW4mmrfnObfyYGT7lOIq)lKkcfOXHTjfqjG7d605eQIZiYuao7QhpP6rd6FrPIqb4SRE8KQhfyfqbuCqbACyBsbg2N1vpMcmSFUmfaV7BUKsVLdxImSOlNWWHHKCSGHHvYN)yT2sfswdjbTsNaESwBPcjjqajbTsNaESwBPcjfhjfk63i5aKe0kDc4XATLkKSgsI39nxsPxXhNwOZFSwBPcjhGK4DFZLu6v8XPf68hR1wQqYAiPWVPad7dMTgtbC23ew0LtAq)xpvekaND1JNu9Oa4Zc(SMc8lsw5cc6v8XPf68UcqsceqYkxqqVk2tdY9foWoNqq7yVRaK8hKCaskGdFrxoHHddj5ybddRKpFJdBiJKeiGKGwPtapwRTuHKIpIK113uGgh2MuabByBsd6FXKkcfGZU6XtQEua8zbFwtbQCbb9k(40cDExbuGgh2MuaC)EWgh2MWNPckWZubmBnMcO4Jtl0rd6)csfHcWzx94jvpka(SGpRPavUGGEsClytfCbH7n5Z7kGc04W2KcG73d24W2e(mvqbEMkGzRXuasClytfCbH7n5Jg0)1fvekaND1JNu9Oa4Zc(SMceMgJKIJKIjsoajXogskoswqKCaskwiPao8fD5egomKKJfmmSs(8noSHmfOXHTjfa3VhSXHTj8zQGc8mvaZwJPaRao5Jg0)1nQiuao7QhpP6rbACyBsbanvaxqy4WqsowWWWk5JcGpl4ZAka2X8ADrKKmij2XqYAJiz9i5aK8xKKt(k15dtJHXc16IiP4iPqKKabKKt(k15dtJHXc16IiP4iPyIKdqs8UV5sk9GMkuWfec6E68hR1wQqsXrsH(cIKeiGK4DFZLu6jXTGnvWfeU3Kp)XATLkKuCKuuK8hkawh(XWOVsou0)cPb9VyKkcfGZU6XtQEua8zbFwtbWoMxRlIKKbjXogswBejfIKdqYFrso5RuNpmnggluRlIKIJKcrsceqs8UV5sk9k(40cD(J1AlviP4iPOijbcijN8vQZhMgdJfQ1frsXrsXejhGK4DFZLu6bnvOGlie0905pwRTuHKIJKc9fejjqajX7(MlP0tIBbBQGliCVjF(J1AlviP4iPOi5puGgh2MuaUOa(bD6tJg0)1jvekaND1JNu9OanoSnPaHvYhuq)0Oa4Zc(SMcGxTQfQIZiYi5aKe7yETUissgKe7yizTrKuuKCas(lsYjFL68HPXWyHADrKuCKuissGasI39nxsPxXhNwOZFSwBPcjfhjffjjqaj5KVsD(W0yySqTUiskoskMi5aKeV7BUKspOPcfCbHGUNo)XATLkKuCKuOVGijbcijE33CjLEsClytfCbH7n5ZFSwBPcjfhjffj)HcG1HFmm6RKdf9VqAq)l8BQiuao7QhpP6rbWNf8znfqSqYOFCgEfFCAHopND1JNuGgh2MuaC)EWgh2MWNPckWZubmBnMcGNqfdsd6FHcPIqb4SRE8KQhfaFwWN1uGOFCgEfFCAHopND1JNuGgh2MuaC)EWgh2MWNPckWZubmBnMcGNqfFCAHoAq)luuQiuao7QhpP6rbWNf8znfOXHnKHCYAgRqsXrY6PanoSnPa4(9GnoSnHptfuGNPcy2Amfqf0G(xy9urOaC2vpEs1JcGpl4ZAkqJdBid5K1mwHK1grY6PanoSnPa4(9GnoSnHptfuGNPcy2AmfOxMg0Gci4y8Qv1bve6FHurOanoSnPac2W2KcWzx94jvpAq)lkvekqJdBtkq1gXJNqWxRJNKSSegBrlPaC2vpEs1Jg0)1tfHcWzx94jvpkWkGcO4Gc04W2KcmSpRREmfyy)CzkW3uGH9bZwJPafD5eUj0vXW4SKih0G(xmPIqb4SRE8KQhfaFwWN1uaXcjJ(Xz4v8XPf68C2vpEIKeiGKIfsg9JZWdAQaUGWWHHKCSGHHvYNNZU6XtkqJdBtka2XGvUNkOb9FbPIqb4SRE8KQhfaFwWN1uaXcjJ(Xz45KVsRaWYsi)SI855SRE8Kc04W2KcGDmiPEitdAqb6LPIq)lKkcfOXHTjfGKJDpllHZRl3ekWnXouao7QhpP6rd6FrPIqb4SRE8KQhfaFwWN1uaSJ516IijzqsSJHK1grsrrYbijN8vQZhMgdJfQ1frYAiPOijbcij2X8ADrKKmij2XqYAJiPysbACyBsb4KVsRaWYsi)SI2rd6)6PIqb4SRE8KQhfaFwWN1ua8QvTqvCgrgjhGK)IKvUGG(zNygUGqSJvhM3vassGaso5kxqqF1M80vfWQJj5DfGK)qbACyBsbucSmTSeIVozirdtKg0)IjvekaND1JNu9Oa4Zc(SMcWjFL68HPXWyHADrKSgsYfzSBWWW0yKKabKe7yETUissgKe7yiP4JiPqkqJdBtkaOPcfCbHGUNoAq)xqQiuao7QhpP6rbACyBsbotzzju5MqIgMifaFwWN1uGFrYOFCgEso29SSeoVUCtOa3e745SRE8ejhGK4DFZLu6ptzzju5MqIgMOF6EDyBIK1qs8UV5sk9KCS7zzjCED5MqbUj2XFSwBPcj1hjftK8hKCas(lsI39nxsPh0uHcUGqq3tN)yT2sfswdjRhjjqajXogswBejlis(dfaRd)yy0xjhk6FH0G(VUOIqb4SRE8KQhfaFwWN1uGkxqq)5QCSSewh9KHKSC6NlPKc04W2KcCUkhllH1rpzijlN0G(VUrfHcWzx94jvpka(SGpRPa4vRAHQ4mImsoaj)fj)fjX7(MlP0xTjpDvbS6ys(J1AlviznKuuKCas(lsIDmKSgswpssGasI39nxsPh0uHcUGqq3tN)yT2sfswdjRlK8hKCas(lsIDmKS2iswqKKabKeV7BUKspOPcfCbHGUNo)XATLkKSgskks(ds(dssGaskwijEhYzNHpz8TV9Mi5aKKt(k15dtJHXc16IiznKSeprYFOanoSnPakbwMwwcXxNmKOHjsd6FXivekaND1JNu9Oa4Zc(SMcGDmVwxejjdsIDmKS2iskKc04W2KcWffWpOtFA0G(VoPIqb4SRE8KQhfOXHTjfa0ubCbHHddj5ybddRKpka(SGpRPayhZR1frsYGKyhdjRnIK1tbW6Wpgg9vYHI(xinO)f(nvekaND1JNu9Oa4Zc(SMcGDmVwxejjdsIDmKS2iskkfOXHTjfa7yWk3tf0G(xOqQiuao7QhpP6rbWNf8znfOYfe0homK1eW3EkiUf0yl2ZRIgtejRHKcRtKCasYjFL68HPXWyHADrKSgsYfzSBWWW0yKKmiPqKCasI39nxsPh0uHcUGqq3tN)yT2sfswdj5Im2nyyyAmfOXHTjfaFnM4ZYsyD0tg(SsNiTSKg0)cfLkcfGZU6XtQEuGgh2MuGWk5dkOFAua8zbFwtbWoMxRlIKKbjXogswBejffjhGK)IKIfsg9JZW7ybeVAvRNZU6XtKKabKeVAvlufNrKrYFOayD4hdJ(k5qr)lKg0)cRNkcfGZU6XtQEua8zbFwtbWBoDTWJ7h291bpHQ4mISYZzx94jfOXHTjfqjWY0Ysi(6KHenmrAq)lumPIqb4SRE8KQhfaFwWN1ua8QvTqvCgrMc04W2KcGDmiPEitd6FHfKkcfGZU6XtQEuGgh2MuaWNollHk(eWzajAyIua8zbFwtbQCbb9vlrOGBX(5skPawg8DUcckGqAq)lSUOIqb4SRE8KQhfOXHTjfO61yIRBajAyIua8zbFwtbWRw1cvXzezKCas(lsw5cc6RwIqb3I9UcqsceqYOFCgEhlG4vRA9C2vpEIKdqsbhpewINEH(Wk5dkOFAi5aKe7yi5iskksoajX7(MlP0dAQqbxqiO7PZFSwBPcjfhjRhjjqajXoMxRlIKKbjXogsk(iskejhGKcoEiSep9c9kbwMwwcXxNmKOHjIKdqso5RuNpmnggluRlIKIJK1JK)qbW6Wpgg9vYHI(xinObnOad5tzBs)l63Ik8BHcRBuas9LwwQOaF9cWc0)IH)lG)cKejfXHrsttWEbscUhsswsClytfCbH7n5JSi5XfiU2XtKuTAms2UXQ1bprsStNLSYJ(8LwYiPWVaj)QnhYxWtKKSr)4m8InzrYyrsYg9JZWl2Eo7Qhpjls2bskgua9Li5Vcl(Jh95lTKrsr)cK8R2CiFbprsYg9JZWl2KfjJfjjB0podVy75SRE8KSizhiPyqb0xIK)kS4pE0NV0sgjfwxFbs(vBoKVGNijzJ(Xz4fBYIKXIKKn6hNHxS9C2vpEswK8xHf)XJ(G(81lalq)lg(Va(lqsKuehgjnnb7fij4Eijzv8XPf6ilsECbIRD8ejvRgJKTBSADWtKe70zjR8OpFPLmsku4xGKF1Md5l4jss2OFCgEXMSizSijzJ(Xz4fBpND1JNKfj7ajfdkG(sK8xHf)XJ(G(81lalq)lg(Va(lqsKuehgjnnb7fij4EijzXtOIpoTqhzrYJlqCTJNiPA1yKSDJvRdEIKyNolzLh95lTKrY68lqYVAZH8f8ejj75Mm4ELSxSjlsglss2ZnzW9kzVy75SRE8KSi5Vcl(Jh9b95RxawG(xm8Fb8xGKiPiomsAAc2lqsW9qsYQcYIKhxG4Ahprs1QXiz7gRwh8ejXoDwYkp6ZxAjJKI5xGKF1Md5l4jss2OFCgEXMSizSijzJ(Xz4fBpND1JNKfj7ajfdkG(sK8xHf)XJ(8LwYizD9fi5xT5q(cEIKKn6hNHxSjlsglss2OFCgEX2Zzx94jzrYFfw8hp6ZxAjJKcf(fi5xT5q(cEIKKfV501cVytwKmwKKS4nNUw4fBpND1JNKfj)vyXF8OpFPLmskSGFbs(vBoKVGNijzJ(Xz4fBYIKXIKKn6hNHxS9C2vpEswK8xHf)XJ(G(81lalq)lg(Va(lqsKuehgjnnb7fij4EijzXtOIbjlsECbIRD8ejvRgJKTBSADWtKe70zjR8OpFPLmsw)xGKF1Md5l4jss2ZnzW9kzVytwKmwKKSNBYG7vYEX2Zzx94jzrYFfw8hp6d6ZxVaSa9Vy4)c4VajrsrCyK00eSxGKG7HKKDYGT7lilsECbIRD8ejvRgJKTBSADWtKe70zjR8OpFPLmsk87Vaj)QnhYxWtKKSr)4m8InzrYyrsYg9JZWl2Eo7Qhpjls2bskgua9Li5Vcl(Jh95lTKrsHc)cK8R2CiFbprsYg9JZWl2KfjJfjjB0podVy75SRE8KSizhiPyqb0xIK)kS4pE0h0NVEbyb6FXW)fWFbsIKI4WiPPjyVajb3djjBVmzrYJlqCTJNiPA1yKSDJvRdEIKyNolzLh95lTKrYc(fi5xT5q(cEIKKn6hNHxSjlsglss2OFCgEX2Zzx94jzrYFfw8hp6ZxAjJKcf9lqYVAZH8f8ejjB0podVytwKmwKKSr)4m8ITNZU6XtYIK)kS4pE0NV0sgjfw)xGKF1Md5l4jssw8Mtxl8InzrYyrsYI3C6AHxS9C2vpEswKSdKumOa6lrYFfw8hp6ZxAjJKcRRVaj)QnhYxWtKKSr)4m8InzrYyrsYg9JZWl2Eo7Qhpjls(RWI)4rFqFed1eSxWtKSorYgh2Mi5ZuHYJ(qbA3WzpkaGP9vuab3cApMcu3rYVULts9JiFi5x7njI(u3rYpD62NoKuuHKJKI(TOcrFqFQ7iPiK4Mis(1WuHcjxqK8RH7PdjTm47Cfei5BlnSh9PUJKIqIBIijGaltllrYV66KrYVwgMis(2sd)1ej7HRnrYj)ADkKSZjsAzWLxhms(v9d7(6GNijqCgrw5rFqFQ7iPyqrg7g8ejRyW9yKeVAvDGKvCPLkpswaIXSGqHK5MKXPpnq3hs24W2uHKB(05rFACyBQ8cogVAvDmkydBt0Ngh2MkVGJXRwvh6pwy1gXJNqWxRJNKSSegBrlrFACyBQ8cogVAvDO)yHd7Z6QhtE2A8yrxoHBcDvmmoljYb5RGrfhKpSFU843OpnoSnvEbhJxTQo0FSqSJbRCpvqUbokwr)4m8k(40cDEo7QhpjqqSI(Xz4bnvaxqy4WqsowWWWk5ZZzx94j6tJdBtLxWX4vRQd9hle7yqs9qMCdCuSI(Xz45KVsRaWYsi)SI855SRE8e9b9PUJKIbfzSBWtKKhYNoKmmngjdhgjBCShsAkKSh22RRESh9PXHTPAujG7d605eQIZiYOpnoSnv6pw4W(SU6XKNTgp6SVjSOlNKVcgvCq(W(5YJ4DFZLu6TC4sKHfD5egomKKJfmmSs(8hR1wQQbALob8yT2sfbcGwPtapwRTujUqr)EaOv6eWJ1Alv1W7(MlP0R4Jtl05pwRTunaV7BUKsVIpoTqN)yT2svnHFJ(04W2uP)yHc2W2KCdC83kxqqVIpoTqN3vabcvUGGEvSNgK7lCGDoHG2XExb)mqah(IUCcdhgsYXcggwjF(gh2qMabqR0jGhR1wQeFSU(g9PXHTPs)XcX97bBCyBcFMkipBnEuXhNwOJCdCSYfe0R4Jtl05DfG(04W2uP)yH4(9GnoSnHptfKNTgpsIBbBQGliCVjFKBGJvUGGEsClytfCbH7n5Z7ka9PXHTPs)XcX97bBCyBcFMkipBnECfWjFKBGJHPXIlMdWoM4fCGyjGdFrxoHHddj5ybddRKpFJdBiJ(04W2uP)yHGMkGlimCyijhlyyyL8rowh(XWOVsouJcj3ahXoMxRlsgSJvBS(b)YjFL68HPXWyHADrXfsGaN8vQZhMgdJfQ1ffxmhG39nxsPh0uHcUGqq3tN)yT2sL4c9fKab8UV5sk9K4wWMk4cc3BYN)yT2sL4I(d6tJdBtL(JfYffWpOtFAKBGJyhZR1fjd2XQnkCWVCYxPoFyAmmwOwxuCHeiG39nxsPxXhNwOZFSwBPsCrjqGt(k15dtJHXc16IIlMdW7(MlP0dAQqbxqiO7PZFSwBPsCH(csGaE33CjLEsClytfCbH7n5ZFSwBPsCr)b9PXHTPs)XcdRKpOG(Prowh(XWOVsouJcj3ahXRw1cvXze5byhZR1fjd2XQnk6GF5KVsD(W0yySqTUO4cjqaV7BUKsVIpoTqN)yT2sL4IsGaN8vQZhMgdJfQ1ffxmhG39nxsPh0uHcUGqq3tN)yT2sL4c9fKab8UV5sk9K4wWMk4cc3BYN)yT2sL4I(d6tJdBtL(JfI73d24W2e(mvqE2A8iEcvmi5g4Oyf9JZWR4Jtl0H(04W2uP)yH4(9GnoSnHptfKNTgpINqfFCAHoYnWXOFCgEfFCAHo0Ngh2Mk9hle3VhSXHTj8zQG8S14rvqUbo24WgYqoznJvIxp6tJdBtL(JfI73d24W2e(mvqE2A8yVm5g4yJdBid5K1mwvBSE0h0Ngh2MkFV8ijh7EwwcNxxUjuGBIDqFACyBQ89Y6pwiN8vAfawwc5Nv0oYnWrSJ516IKb7y1gfDaN8vQZhMgdJfQ1fRjkbcyhZR1fjd2XQnkMOpnoSnv(Ez9hlujWY0Ysi(6KHenmrYnWr8QvTqvCgrEWVvUGG(zNygUGqSJvhM3vabctUYfe0xTjpDvbS6ysExb)G(04W2u57L1FSqqtfk4ccbDpDKBGJCYxPoFyAmmwOwxSgxKXUbddtJjqa7yETUizWoM4JcrFACyBQ89Y6pw4zkllHk3es0WejhRd)yy0xjhQrHKBGJ)g9JZWtYXUNLLW51LBcf4MyNb4DFZLu6ptzzju5MqIgMOF6EDyBwdV7BUKspjh7EwwcNxxUjuGBID8hR1wQ0xm)zWV4DFZLu6bnvOGlie0905pwRTuvREceWowTXc(d6tJdBtLVxw)XcpxLJLLW6ONmKKLtYnWXkxqq)5QCSSewh9KHKSC6NlPe9PXHTPY3lR)yHkbwMwwcXxNmKOHjsUboIxTQfQIZiYd(9x8UV5sk9vBYtxvaRoMK)yT2svnrh8l2XQvpbc4DFZLu6bnvOGlie0905pwRTuvRU(zWVyhR2ybjqaV7BUKspOPcfCbHGUNo)XATLQAI(Zpeiiw4DiNDg(KX3(2BoGt(k15dtJHXc16I1kXZFqFACyBQ89Y6pwixua)Go9PrUboIDmVwxKmyhR2Oq0Ngh2MkFVS(JfcAQaUGWWHHKCSGHHvYh5yD4hdJ(k5qnkKCdCe7yETUizWowTX6rFACyBQ89Y6pwi2XGvUNki3ahXoMxRlsgSJvBuu0Ngh2MkFVS(JfIVgt8zzjSo6jdFwPtKwwsUbow5cc6dhgYAc4Bpfe3cASf75vrJjwtyDoGt(k15dtJHXc16I14Im2nyyyAmzeoaV7BUKspOPcfCbHGUNo)XATLQACrg7gmmmng9PXHTPY3lR)yHHvYhuq)0ihRd)yy0xjhQrHKBGJyhZR1fjd2XQnk6GFfROFCgEhlG4vRAjqaVAvlufNrK)b9PUJKFv)WUVo4jsceNrKvOpnoSnv(Ez9hlujWY0Ysi(6KHenmrYnWr8Mtxl84(HDFDWtOkoJiRqFACyBQ89Y6pwi2XGK6Hm5g4iE1QwOkoJiJ(04W2u57L1FSqWNollHk(eWzajAyIKBGJvUGG(QLiuWTy)CjLKBzW35kigfI(04W2u57L1FSWQxJjUUbKOHjsowh(XWOVsouJcj3ahXRw1cvXze5b)w5cc6RwIqb3I9Uciqi6hNH3XciE1Q2bcoEiSep9c9HvYhuq)0gGDSrrhG39nxsPh0uHcUGqq3tN)yT2sL41tGa2X8ADrYGDmXhfoqWXdHL4PxOxjWY0Ysi(6KHenmXbCYxPoFyAmmwOwxu86)b9b9PXHTPYJNqfdoA5WLidl6YjmCyijhlyyyL8rUbokwd7Z6Qh7D23ew0LtceaTsNaESwBPsCrli6tJdBtLhpHkgu)Xc7d3jdJ9oodYnWrSJ516IKb7y1gfI(04W2u5XtOIb1FSWyDXoWfeo5oCi3ahbTsNaESwBPQ2VcfJFtMZnzW9kzpyh9dgRl2Palu0V)HaHkxqqVk2tdY9foWoNqq7y)CjLdeWHVOlNWWHHKCSGHHvYNVXHnKjqa0kDc4XATLkXf(n6tJdBtLhpHkgu)XcjXTGnvWfeU3KpYnWXFV2MqEiNHVNtL3YAIzbjq4ABc5HCg(EovExb)maV7BUKs)zkllHk3es0We9hR1wQeNlYy3GHHPXOpnoSnvE8eQyq9hleS5NLmufRMaYnWr8QvTqvCgrEWVxBtipKZW3ZPYBznHFtGW12eYd5m89CQ8Uc(b9PXHTPYJNqfdQ)yHG97XjCVjFKBGJxBtipKZW3ZPYBzT6)MaHRTjKhYz475u5DfG(04W2u5XtOIb1FSWQn5PRkGvhtICdC8ABc5HCg(EovElRvWVjq4ABc5HCg(EovExbK)SKH45yD9n6tJdBtLhpHkgu)XcvXEAqUVWb25ecAhdbTIDWKBGJ4nNUw4X7Etl7GNWfeKtLnK9C2vpEI(04W2u5XtOIb1FSqvSNgK7lCGDoHG2XKBGJ4DFZLu6vXEAqUVWb25ecAh7Xo9vYQrrjqa0kDc4XATLkXf9Bce(9ABc5HCg(Eov(J1Alv1ewqceel8oKZodprDN15GF)9ABc5HCg(EovElRH39nxsPxf7Pb5(chyNtiODSh099GhJD6RKHHPXeiiwxBtipKZW3ZPYZfnvO(zWV4DFZLu6TC4sKHfD5egomKKJfmmSs(8hR1wQQH39nxsPxf7Pb5(chyNtiODSh099GhJD6RKHHPXeimSpRRES3zFtyrxo)5Nb4DFZLu6bnvOGlie0905pwRTuj(yDoa7y1gfDaE33CjLEso29SSeoVUCtOa3e74pwRTuj(Oqr)b9PXHTPYJNqfdQ)yHQypni3x4a7CcbTJj3ahX7qo7m8e1DwNd(TYfe0tIBbBQGliCVjFExbei8lOv6eWJ1AlvIJ39nxsPNe3c2ubxq4Et(8hR1wQiqaV7BUKspjUfSPcUGW9M85pwRTuvdV7BUKsVk2tdY9foWoNqq7ypO77bpg70xjddtJ)zaE33CjLEqtfk4ccbDpD(J1AlvIpwNdWowTrrhG39nxsPNKJDpllHZRl3ekWnXo(J1AlvIpku0FqFACyBQ84juXG6pwORIHwWAk0Ngh2MkpEcvmO(JfgRl2bUGqI9P1KBGJGwPtapwRTuvtybRtceeWHVOlNWWHHKCSGHHvYNVXHnKjqyyFwx9yVZ(MWIUCI(04W2u5XtOIb1FSWQ3UtiO7PJCdCeV7BUKsVLdxImSOlNWWHHKCSGHHvYN)yT2svT6)MaHH9zD1J9o7Bcl6YjbcGwPtapwRTujUOFJ(04W2u5XtOIb1FSWk(u8r0YsYnWr8UV5sk9woCjYWIUCcdhgsYXcggwjF(J1Alv1Q)Bceg2N1vp27SVjSOlNeiaALob8yT2sL4cli6tJdBtLhpHkgu)XcFwPtOG1H7SuJZa9PXHTPYJNqfdQ)yHG2XvVDNKBGJ4DFZLu6TC4sKHfD5egomKKJfmmSs(8hR1wQQv)3eimSpRRES3zFtyrxojqa0kDc4XATLkXf(n6tJdBtLhpHkgu)Xc7eZQ46he3Vh5g4iE33CjLElhUezyrxoHHddj5ybddRKp)XATLQA1)nbcd7Z6Qh7D23ew0LtceaTsNaESwBPsCr)g9PXHTPYJNqfdQ)yHvDjCbHXzyIkYnWXkxqqVk2tdY9foWoNqq7y)CjLOpOpnoSnvE8eQ4Jtl0noSpRREm5zRXJk(40cDWk3tfKVcgvCq(W(5YJ4DFZLu6v8XPf68hR1wQexibcc4Wx0Lty4WqsowWWWk5Z34WgYdW7(MlP0R4Jtl05pwRTuvR(Vjqa0kDc4XATLkXf9B0Ngh2MkpEcv8XPf60FSqlhUezyrxoHHddj5ybddRKpYnWrXAyFwx9yVZ(MWIUCsGaOv6eWJ1AlvIlAbrFACyBQ84juXhNwOt)XcDvm0cwtH(04W2u5XtOIpoTqN(Jf2hUtgg7DCgKBGJyhZR1fjd2XQnke9PXHTPYJNqfFCAHo9hl8zLoHcwhUZsnod0Ngh2MkpEcv8XPf60FSqq74Q3UtYnWXH9zD1J9k(40cDWk3tfOpnoSnvE8eQ4Jtl0P)yHDIzvC9dI73JCdCCyFwx9yVIpoTqhSY9ub6tJdBtLhpHk(40cD6pwyvxcxqyCgMOICdCCyFwx9yVIpoTqhSY9ub6tJdBtLhpHk(40cD6pwySUyh4ccNChoKBGJGwPtapwRTuv7xHIXVjZ5Mm4ELShSJ(bJ1f7uGfk63)qGGao8fD5egomKKJfmmSs(8noSHmbcGwPtapwRTujUWVrFACyBQ84juXhNwOt)XcJ1f7axqiX(0AYnWrqR0jGhR1wQQvNFtGGao8fD5egomKKJfmmSs(8noSHmbcGwPtapwRTujUWVrFACyBQ84juXhNwOt)XcjXTGnvWfeU3KpYnWr8UV5sk9NPSSeQCtirdt0FSwBPsCUiJDdggMgJ(04W2u5XtOIpoTqN(Jfc28ZsgQIvta6tJdBtLhpHk(40cD6pwiy)ECc3BYh6tJdBtLhpHk(40cD6pwy1M80vfWQJjH(04W2u5XtOIpoTqN(JfQ4Jtl0rUboI39nxsP)mLLLqLBcjAyI(J1AlvIlkbcGwPtapwRTujUWcI(04W2u5XtOIpoTqN(Jfw1LWfegNHjQqFqFACyBQ8Rao5Be0ubCbHHddj5ybddRKpYX6Wpgg9DLCOgfsUboIDmVwxKmyhR2y9OpnoSnv(vaN8P)yHCrb8d60Ng5g4y0podp2XGvUNk8C2vpEoa7yETUizWowTX6rFACyBQ8Rao5t)XcdRKpOG(Prowh(XWOVsouJcj3ahXRw1cvXze5byhZR1fjd2XQnkk6tJdBtLFfWjF6pwi2XGK6Hm5g4i2X8ADrYGDSrrrFACyBQ8Rao5t)Xc5Ic4h0Ppn0Ngh2Mk)kGt(0FSWWk5dkOFAKJ1HFmm6RKd1OqYnWrSJ516IKb7y1gff9b9PXHTPYR4Jtl0ncAQqbxqiO7PJCdCSYfe0R4Jtl05pwRTujUq0Ngh2MkVIpoTqN(Jf6QyOfSMc9PXHTPYR4Jtl0P)yHkbwMwwcXxNmKOHjsUboIxTQfQIZiYd(TXHnKHCYAgRQnwpbcnoSHmKtwZyvnHdel8UV5sk9NPSSeQCtirdt07k4h0Ngh2MkVIpoTqN(JfEMYYsOYnHenmrYX6Wpgg9vYHAui5g4iE1QwOkoJiJ(04W2u5v8XPf60FSqqtfk4ccbDpDKBGJnoSHmKtwZyvTX6rFACyBQ8k(40cD6pwOsGLPLLq81jdjAyIKBGJ4vRAHQ4mI8Gkxqq)Stmdxqi2XQdZ7ka9PXHTPYR4Jtl0P)yHvVgtCDdirdtKCSo8JHrFLCOgfsUboIxTQfQIZiYdQCbb9K4wWMk4cc3BYhKejVRGb4DFZLu6ptzzju5MqIgMO)yT2svnrrFACyBQ8k(40cD6pwiOPcfCbHGUNoYTm47CfeqdCSYfe0R4Jtl05DfmaV7BUKs)zkllHk3es0We9h3tDOpnoSnvEfFCAHo9hlujWY0Ysi(6KHenmrYnWr8QvTqvCgrEWKRCbb9vBYtxvaRoMK3va6tJdBtLxXhNwOt)Xcbnvaxqy4WqsowWWWk5JCSo8JHrFLCOgfsUboIDmXRh9PXHTPYR4Jtl0P)yHvVgtCDdirdtKCSo8JHrFLCOgfsUboIxTQfQIZiYeiiwr)4m8owaXRw1I(04W2u5v8XPf60FSqLaltllH4Rtgs0WerFqFACyBQ8QyKKJDpllHZRl3ekWnXoKBGJxBtipKZW3ZPYBzn8UV5sk9KCS7zzjCED5MqbUj2XpDVoSnlWF7fJeiCTnH8qodFpNkVRa0Ngh2MkVk0FSqo5R0kaSSeYpRODKBGJyhZR1fjd2XQnk6ao5RuNpmnggluRlwREceWoMxRlsgSJvBumh8lN8vQZhMgdJfQ1fRjkbcILGJhclXtVqFyL8bf0pTFqFACyBQ8Qq)XcvcSmTSeIVozirdtKCdCeVAvlufNrKhu5cc6NDIz4ccXowDyExbd(9ABc5HCg(EovElRv5cc6NDIz4ccXowDy(J1AlvKruceU2MqEiNHVNtL3vWpOpnoSnvEvO)yHNPSSeQCtirdtKCSo8JHrFLCOgfsUboI39nxsPxXhNwOZFSwBPQMqceeROFCgEfFCAHo0Ngh2MkVk0FSqqtfk4ccbDpDKBGJ)ETnH8qodFpNkVL1W7(MlP0dAQqbxqiO7PZpDVoSnlWF7fJeiCTnH8qodFpNkVRGFg8lN8vQZhMgdJfQ1fRXfzSBWWW0yYiKabSJ516IKb7yIpkKaHkxqqVk2tdY9foWoNqq7y)XATLkX5Im2nyyyAS(c)HabqR0jGhR1wQeNlYy3GHHPX6le9PXHTPYRc9hleFnM4ZYsyD0tg(SsNiTSKCdCSYfe0homK1eW3EkiUf0yl2ZRIgtSMW6CaN8vQZhMgdJfQ1fRXfzSBWWW0yYiCaE33CjL(ZuwwcvUjKOHj6pwRTuvJlYy3GHHPXeiu5cc6dhgYAc4Bpfe3cASf75vrJjwtOyo4x8UV5sk9k(40cD(J1AlvIxWbr)4m8k(40cDeiG39nxsPNe3c2ubxq4Et(8hR1wQeVGdW7qo7m8e1DwNeiaALob8yT2sL4f8h0Ngh2MkVk0FSWZv5yzjSo6jdjz5KCdCSYfe0FUkhllH1rpzijlN(5skh04WgYqoznJv1eI(04W2u5vH(JfcAQaUGWWHHKCSGHHvYh5yD4hdJ(k5qnkKCdCe7yIxp6tJdBtLxf6pwixua)Go9PrUboIDmVwxKmyhR2Oq0Ngh2MkVk0FSqSJbRCpvqUboIDmVwxKmyhR2OWbnoSHmKtwZy1OWbxBtipKZW3ZPYBznr)MabSJ516IKb7y1gfDqJdBid5K1mwvBuu0Ngh2MkVk0FSqLaltllH4Rtgs0Wej3ahXBoDTWJ7h291bpHQ4mISAGsa)EWOVsouELaltllH4Rtgs0WeRje9PXHTPYRc9hle7yqs9qg9PXHTPYRc9hlmSs(Gc6Ng5yD4hdJ(k5qnkKCdCeVAvlufNrKhGDmVwxKmyhR2OOdQCbb9Qypni3x4a7CcbTJ9ZLuI(04W2u5vH(JfQeyzAzjeFDYqIgMi5g4yLliOh7yqo5RuNxfnMyT6)MmfSa34WgYqoznJvdQCbb9Qypni3x4a7CcbTJ9ZLuo4x8UV5sk9NPSSeQCtirdt0FSwBPQMOdW7(MlP0dAQqbxqiO7PZFSwBPQMOeiG39nxsP)mLLLqLBcjAyI(J1AlvIx)a8UV5sk9GMkuWfec6E68hR1wQQv)aSJvREceW7(MlP0FMYYsOYnHenmr)XATLQA1paV7BUKspOPcfCbHGUNo)XATLkXRFa2XQjMeiGDmVwxKmyht8rHd4KVsD(W0yySqTUO4I(dbcvUGGESJb5KVsDEv0yI1e(9aqR0jGhR1wQeVUH(04W2u5vH(Jfw9AmX1nGenmrYX6Wpgg9vYHAui5g4iE1QwOkoJip43OFCgEfFCAHUb4DFZLu6v8XPf68hR1wQeVEceW7(MlP0FMYYsOYnHenmr)XATLQAchG39nxsPh0uHcUGqq3tN)yT2svnHeiG39nxsP)mLLLqLBcjAyI(J1AlvIx)a8UV5sk9GMkuWfec6E68hR1wQQv)aSJvtuceW7(MlP0FMYYsOYnHenmr)XATLQA1paV7BUKspOPcfCbHGUNo)XATLkXRFa2XQvpbcyhRwbjqOYfe0xTeHcUf7Df8d6tJdBtLxf6pwyyL8bf0pnYX6Wpgg9vYHAui5g4iE1QwOkoJipa7yETUizWowTrrrFACyBQ8Qq)XcbF6SSeQ4taNbKOHjsULbFNRGyui6tJdBtLxf6pwy1RXex3as0WejhRd)yy0xjhQrHKBGJ4vRAHQ4mI8a8UV5sk9GMkuWfec6E68hR1wQeV(byhBu0bcoEiSep9c9HvYhuq)0gWjFL68HPXWyHf8BXfI(04W2u5vH(Jfw9AmX1nGenmrYX6Wpgg9vYHAui5g4iE1QwOkoJipGt(k15dtJHXc16IIl6GFXoMxRlsgSJj(OqceeC8qyjE6f6dRKpOG(P9d6d6tJdBtLNe3c2ubxq4Et(gX97bBCyBcFMkipBnEepHkgKCdCuSI(Xz4v8XPf6qFACyBQ8K4wWMk4cc3BYN(JfI73d24W2e(mvqE2A8iEcv8XPf6i3ahJ(Xz4v8XPf6qFACyBQ8K4wWMk4cc3BYN(JfYjFLwbGLLq(zfTJCdCe7yETUizWowTrrhWjFL68HPXWyHADXA1J(04W2u5jXTGnvWfeU3Kp9hl8mLLLqLBcjAyIKJ1HFmm6RKd1Oq0Ngh2MkpjUfSPcUGW9M8P)yHkbwMwwcXxNmKOHjsUboIxTQfQIZiYdQCbb9ZoXmCbHyhRomVRa0Ngh2MkpjUfSPcUGW9M8P)yHGMkuWfec6E6i3ahBCydziNSMXQAJIoOYfe0tIBbBQGliCVjFqsK8hR1wQexi6tJdBtLNe3c2ubxq4Et(0FSqso29SSeoVUCtOa3e7qUbo24WgYqoznJv1gff9PXHTPYtIBbBQGliCVjF6pwOsGLPLLq81jdjAyIKBGJ4vRAHQ4mI8Ggh2qgYjRzSQ2y9dQCbb9K4wWMk4cc3BYhKejVRa0Ngh2MkpjUfSPcUGW9M8P)yHvVgtCDdirdtKCSo8JHrFLCOgfsUboIxTQfQIZiYdACydziNSMXkXhff9PXHTPYtIBbBQGliCVjF6pwijh7EwwcNxxUjuGBIDqFACyBQ8K4wWMk4cc3BYN(JfcAQqbxqiO7PJCld(oxbb0ahRCbb9K4wWMk4cc3BYhKejVRaYnWXkxqqVk2tdY9foWoNqq7yVRGbxBtipKZW3ZPYBzn8UV5sk9GMkuWfec6E68t3RdBZc83(6c9PXHTPYtIBbBQGliCVjF6pwOsGLPLLq81jdjAyIKBGJvUGGESJb5KVsDEv0yI1Q)BYuWcCJdBid5K1mwH(04W2u5jXTGnvWfeU3Kp9hle0ubCbHHddj5ybddRKpYX6Wpgg9vYHAui5g4i2XeVE0Ngh2MkpjUfSPcUGW9M8P)yHCrb8d60Ng5g4i2X8ADrYGDSAJcrFACyBQ8K4wWMk4cc3BYN(JfIDmyL7PcYnWrSJ516IKb7y1g)vO(noSHmKtwZyvnH)G(04W2u5jXTGnvWfeU3Kp9hlmSs(Gc6Ng5yD4hdJ(k5qnkKCdC8xXk6hNH3XciE1QwceWRw1cvXze5FgGDmVwxKmyhR2OOOpnoSnvEsClytfCbH7n5t)XcXogKupKrFACyBQ8K4wWMk4cc3BYN(Jfw9AmX1nGenmrYX6Wpgg9vYHAui5g4i2XQnwpbcvUGGEsClytfCbH7n5dsIK3va6tJdBtLNe3c2ubxq4Et(0FSqWNollHk(eWzajAyIKBzW35kigfsdAqPa]] )

end