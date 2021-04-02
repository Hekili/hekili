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
    
    spec:RegisterPack( "Windwalker", 20210308, [[dSuHdcqisr8ivHWMeuFIuuJckXPGsAvcc6vurMfuLBbvLDrv)sqAyQcogP0YifEMc00GQQUMGOTPku(McaJtviDofqwNcqZJGCpfAFkOdcvv0cPI6HKIutubqQlkiGnQai(OcG6KKIKwPQOxQaizMQcv3uviQDcL6NQcrwkPiXtb1ujO(kuvHXki0Er1FbgmjhwQflWJrzYk6YiBwv9zHA0KQttz1kG61qLzdYTj0UL8BvgoboouvPLR0ZjA6IUovA7cPVdfJxiopvy9cc08vL2pK5A5cZHNDsCS14bn0(WGp8OEn04HbdjhoDiG4WcAgUoM4WvlsCy8dRMyAiC0YHf0oGUEYfMdlp3LrCyoCGRbLAQfpGdp7K4yRXdAO9HbF4r9AOXddQLdlfqmo2A8ydehw3MtQ4bC4jjzCy8dRMyAiC0IupYxHd98rUxMos9O4HuA8GgArprpfgd14qQbiMmLi19rQbiURdKYQK21vqIuqxSX8ONcJHACifSaRkRIrkn92fHudqzmCif0fBmp6j(5CIubNu(Ty9ePy6edNePYdPe7Ybs9Ty9eSKyBLePy6edN0ZHHmzk5cZHpburlxyo2A5cZHPQdGOj3zoCZs7ko83Kj4(GuNay0TKaPftlhMTwsR1CyMU5f7iif(qkMUHudhrQb5WmhmicK9UXuk5WA5jhBn4cZHPQdGOj3zomBTKwR5Wzdrv6z6giWDLPNQoaIMivyKIPBEXocsHpKIPBi1WrKAqoCZs7komfrabb07vKNCShKlmhMQoaIMCN5WnlTR4WPftlqqdjYHzRL0AnhMDIbhqMRHJqQWift38IDeKcFift3qQHJiLgCyMdgebYEJPuYXwlp5yJ)CH5Wu1bq0K7mhMTwsR1CyMU5f7iif(qkMUHuJiLgC4ML2vCyMUbW0rjEYXoKCH5WnlTR4WuebeeqVxromvDaen5oZto2pgxyomvDaen5oZHBwAxXHtlMwGGgsKdZwlP1Aomt38IDeKcFift3qQHJiLgCyMdgebYEJPuYXwlp5jhgd1cUscUp42jTCH5yRLlmhMQoaIMCN5WNaoSKsoCZs7koC0EToaI4WrBixIdh4()Emul4kj4(GBN0cWGXVKyBLePcJuybPy3bnpmLFnPvXaPBbWzmC(LeBRKi1qKkW9)9yOwWvsW9b3oPfGbJFjX2kjsfgPcC)FpgQfCLeCFWTtAbyW4xsSTsIucHuAGuVVif7oO5HP8RjTkgiDlaoJHZVKyBLePWhsf4()Emul4kj4(GBN0cWGXVKyBLePgIuAGuHrQa3)3JHAbxjb3hC7Kwagm(LeBRKiLqif(JuyLdhTxq1IehoaQz4o3eGZy4afrtAYto2AWfMdtvhartUZCy2AjTwZH1eKkBiQsVKwQS0HNQoaIMC4ML2vCywdbbAwAxbGmzYHHmzcQwK4WSjqsFEYXEqUWCyQ6aiAYDMdZwlP1AoC2quLEjTuzPdpvDaen5WnlTR4WSgcc0S0UcazYKddzYeuTiXHztGKwQS0bp5yJ)CH5Wu1bq0K7mhMTwsR1CyMU5f7iif(qkMUHudhrknqQWifv0g7WNMibYdi2rqQHi1GC4ML2vCyQOn2cbTkgqqweB5jh7qYfMdtvhartUZC4ML2vC41KwfdKUfaNXWXHzoyqei7nMsjhBT8KJ9JXfMdtvhartUZCy2AjTwZHBwArjavKOrsKA4isPbsfgPcC)FpgQfCLeCFWTtAbyW4xsSTsIucHuA5WnlTR4WFtMsW9bF31bp5ypa4cZHPQdGOj3zomBTKwR5WnlTOeGks0ijsnCeP0Gd3S0UIdJr3wiRIbZTJVciWTy68KJ9JYfMdtvhartUZCy2AjTwZHzNyWbK5A4iKkms1S0IsaQirJKi1WrKAqKkmsf4()Emul4kj4(GBN0cWGX7kGd3S0UIdlfyvzvmGTDraCgdhp5ypqCH5Wu1bq0K7mhUzPDfhoaQz4o3eGZy44WS1sATMdZoXGdiZ1WrivyKQzPfLaurIgjrkHgrknqQWiv0EToaI8bqnd35MaCgdhOiAstoC2BmLa7ZH5jhBTpWfMdtvhartUZCy2AjTwZHzNyWbK5A4iKkmsf4()(zxmcCFat3gyZ7kGd3S0UIdlfyvzvmGTDraCgdhp5yRvlxyoCZs7komgDBHSkgm3o(kGa3IPZHPQdGOj3zEYXwRgCH5Wu1bq0K7mhMTwsR1C4a3)3lZBfbuVPoORj4Bl5DfGuHrQTTjGIsv675u6TcPgIuS7GMhMY)nzkb3h8Dxh(P72PDfsfcrQh8pghUzPDfh(BYucUp47Uo4WwL0UUcsG95WbU)Vhd1cUscUp42jTamy8Uc4jhBTdYfMdtvhartUZCy2AjTwZHdC)Fpt3aurBSdVmBgoKAisn4dif(qQqIuHqKQzPfLaurIgj5WnlTR4WsbwvwfdyBxeaNXWXto2AXFUWCyQ6aiAYDMd3S0UId)nzcUpi1jagDljqAX0YHzRL0AnhMPBiLqi1GCyMdgebYEJPuYXwlp5yRnKCH5Wu1bq0K7mhMTwsR1CyMU5f7iif(qkMUHudhrkTC4ML2vCykIaccO3Rip5yR9X4cZHPQdGOj3zomBTKwR5WmDZl2rqk8HumDdPgoIuybP0IuoHunlTOeGks0ijsneP0IuyLd3S0UIdZ0nqG7ktEYXw7aGlmhMQoaIMCN5WnlTR4WPftlqqdjYHzRL0AnhgliLMGuzdrv61TeWoXGZtvhartK69fPyNyWbK5A4iKcRivyKIPBEXocsHpKIPBi1WrKsdomZbdIazVXuk5yRLNCS1(OCH5Wu1bq0K7mhUzPDfhoaQz4o3eGZy44WS1sATMd3S0IsaQirJKiLqJi1GivyKIPBi1WrKAqK69fPcC)FpgQfCLeCFWTtAbyW4DfWHZEJPeyFomp5yRDG4cZHBwAxXHz6gathL4Wu1bq0K7mp5yRXdCH5WwL0UUcsoSwoCZs7ko8hYHvXajTcOkb4mgoomvDaen5oZtEYHL0sLLo4cZXwlxyomvDaen5oZHzRL0AnhoW9)9sAPYsh(LeBRKiLqiLwoCZs7ko83KPeCFW3DDWto2AWfMdtvhartUZCy2AjTwZHzNyWbK5A4iKkmsHfKQzPfLaurIgjrQHJi1Gi17ls1S0IsaQirJKi1qKslsfgP0eKIDh08Wu(1KwfdKUfaNXW5DfGuyLd3S0UIdlfyvzvmGTDraCgdhp5ypixyomvDaen5oZHBwAxXHxtAvmq6waCgdhhMTwsR1Cy2jgCazUgoIdZCWGiq2BmLso2A5jhB8NlmhMQoaIMCN5WS1sATMd3S0IsaQirJKi1WrKAqoCZs7ko83KPeCFW3DDWto2HKlmhMQoaIMCN5WS1sATMdZoXGdiZ1WrivyKkW9)9ZUye4(aMUnWM3vahUzPDfhwkWQYQyaB7Ia4mgoEYX(X4cZHPQdGOj3zoCZs7koCauZWDUjaNXWXHzRL0AnhMDIbhqMRHJqQWivG7)7XqTGRKG7dUDsR3vasfgPy3bnpmLFnPvXaPBbWzmC(LeBRKi1qKsdomZbdIazVXuk5yRLNCShaCH5WwL0UUcsG95WbU)Vxslvw6W7kim7oO5HP8RjTkgiDlaoJHZVupDWHBwAxXH)MmLG7d(URdomvDaen5oZto2pkxyomvDaen5oZHzRL0AnhMDIbhqMRHJqQWi1KcC)FFWv00vMGGLW4DfWHBwAxXHLcSQSkgW2UiaoJHJNCShiUWCyQ6aiAYDMd3S0UId)nzcUpi1jagDljqAX0YHzRL0AnhMPBiLqi1GCyMdgebYEJPuYXwlp5yR9bUWCyQ6aiAYDMd3S0UIdha1mCNBcWzmCCy2AjTwZHzNyWbK5A4iK69fP0eKkBiQsVULa2jgCEQ6aiAYHzoyqei7nMsjhBT8KJTwTCH5WnlTR4WsbwvwfdyBxeaNXWXHPQdGOj3zEYtomBcK0sLLo4cZXwlxyomvDaen5oZHpbCyjLC4ML2vC4O9ADaeXHJ2qUehMDh08WuEjTuzPd)sITvsKsiKsls9(IucO0hXLkqQtam6wsG0IP13S0IsivyKIDh08WuEjTuzPd)sITvsKAisn4di17lsfCsjsfgP(wSEcwsSTsIucHuA8ahoAVGQfjoSKwQS0biWDLjp5yRbxyomvDaen5oZHzRL0AnhwtqQO9ADae51pOjiIlvi17lsfCsjsfgP(wSEcwsSTsIucHuAesoCZs7koSvrpCeiIlv8KJ9GCH5Wu1bq0K7mhMTwsR1C4O9ADae5L0sLLoabURm5WnlTR4Wbq3nbF31bp5yJ)CH5Wu1bq0K7mhMTwsR1C4O9ADae5L0sLLoabURm5WnlTR4Wb0kPfNvX8KJDi5cZHBwAxXHHSy9ucgy3zSivjhMQoaIMCN5jh7hJlmhMQoaIMCN5WS1sATMdhTxRdGiVKwQS0biWDLjhUzPDfh(BlfaD3KNCShaCH5Wu1bq0K7mhMTwsR1C4O9ADae5L0sLLoabURm5WnlTR4WDXizUneG1qq8KJ9JYfMdtvhartUZCy2AjTwZHJ2R1bqKxslvw6ae4UYKd3S0UIdh0XG7dY1y4K8KJ9aXfMdtvhartUZCy2AjTwZH)wSEcwsSTsIudrkSGuAF0hqk8HuRBr)BJj)VZgcKNlt3tvhartKkeIuA14bKcRi17lsjGsFexQaPobWOBjbslMwFZslkHuVVivWjLivyK6BX6jyjX2kjsjesP9boCZs7koCEUmDW9btQtDEYXw7dCH5Wu1bq0K7mhMTwsR1C4VfRNGLeBRKi1qKAGEaPEFrkbu6J4sfi1jagDljqAX06BwArjK69fPcoPePcJuFlwpblj2wjrkHqkTpWHBwAxXHZZLPdUpaxVInp5yRvlxyomvDaen5oZHzRL0AnhMDh08Wu(1KwfdKUfaNXW5xsSTsIucHuueI5MeinrId3S0UIdJHAbxjb3hC7KwEYXwRgCH5Wu1bq0K7mhMTwsR1C4O9ADae5L0sLLoabURm5WnlTR4WwjzRB2bqea)62v6kcMuuJr8KJT2b5cZHPQdGOj3zomBTKwR5Wr716aiYlPLklDacCxzYHBwAxXHXSDQlZRiEYXwl(ZfMdtvhartUZCy2AjTwZHJ2R1bqKxslvw6ae4UYKd3S0UIdhd1tRZBLGGEgt8KJT2qYfMdtvhartUZCy2AjTwZH1eKkAVwhar(iUubUc4kjqUwHJsK69fPy3bnpmL3QOhoceXLkqQtam6wsG0IP1VKyBLePgIuA8as9(Iur716aiYRFqtqexQ4WnlTR4WUscyjjk5jhBTpgxyoCZs7ko8VjiRiGmprbCyQ6aiAYDMNCS1oa4cZHBwAxXH)neevGBN0YHPQdGOj3zEYXw7JYfMd3S0UIdhCfnDLjiyjmCyQ6aiAYDMNCS1oqCH5Wu1bq0K7mhMTwsR1Cy2DqZdt5xtAvmq6waCgdNFjX2kjsjesPbs9(IubNuIuHrQVfRNGLeBRKiLqiL2qYHBwAxXHL0sLLo4jhBnEGlmhUzPDfhoOJb3hKRXWj5Wu1bq0K7mp5jhwMCH5yRLlmhMQoaIMCN5WS1sATMdVTnbuuQsFpNsVvi1qKIDh08WuEm62czvmyUD8vabUft3pD3oTRqQqis9G)rrQ3xKABBcOOuL(EoLExbC4ML2vCym62czvmyUD8vabUftNNCS1GlmhMQoaIMCN5WS1sATMdZ0nVyhbPWhsX0nKA4isPbsfgPOI2yh(0ejqEaXocsnePgePEFrkMU5f7iif(qkMUHudhrk8hPcJuybPOI2yh(0ejqEaXocsneP0aPEFrknbPeSuuqmB616tlMwGGgsePWkhUzPDfhMkAJTqqRIbeKfXwEYXEqUWCyQ6aiAYDMdZwlP1Aom7edoGmxdhHuHrQa3)3p7IrG7dy62aBExbivyKcli122eqrPk99Ck9wHudrQa3)3p7IrG7dy62aB(LeBRKif(qknqQ3xKABBcOOuL(EoLExbifw5WnlTR4WsbwvwfdyBxeaNXWXto24pxyomvDaen5oZHBwAxXHxtAvmq6waCgdhhMTwsR1Cy2DqZdt5L0sLLo8lj2wjrQHiLwK69fP0eKkBiQsVKwQS0HNQoaIMCyMdgebYEJPuYXwlp5yhsUWCyQ6aiAYDMdZwlP1AomwqQTTjGIsv675u6TcPgIuS7GMhMY)nzkb3h8Dxh(P72PDfsfcrQh8pks9(IuBBtafLQ03ZP07kaPWksfgPWcsrfTXo8PjsG8aIDeKAisrriMBsG0ejKcFiLwK69fPy6MxSJGu4dPy6gsj0isPfPEFrQa3)3lZBfbuVPoORj4Bl5xsSTsIucHuueI5MeinrcPCcP0IuyfPEFrQVfRNGLeBRKiLqiffHyUjbstKqkNqkTC4ML2vC4Vjtj4(GV76GNCSFmUWCyQ6aiAYDMdZwlP1AoCG7)7tDcqIcO9wjG1cAML36LzZWHudrkTdesfgPOI2yh(0ejqEaXocsnePOieZnjqAIesHpKslsfgPy3bnpmLFnPvXaPBbWzmC(LeBRKi1qKIIqm3KaPjsi17lsf4()(uNaKOaAVvcyTGMz5TEz2mCi1qKsl(JuHrkSGuS7GMhMYlPLklD4xsSTsIucHuHePcJuzdrv6L0sLLo8u1bq0ePEFrk2DqZdt5XqTGRKG7dUDsRFjX2kjsjesfsKkmsXUOu1v6X5yTUqQ3xK6BX6jyjX2kjsjesfsKcRC4ML2vCy22mCqwfdg4EsailwplRI5jh7baxyomvDaen5oZHzRL0AnhoW9)9RRu3QyWa3tcGXQPFEykKkms1S0IsaQirJKi1qKslhUzPDfhEDL6wfdg4Esamwn5jh7hLlmhMQoaIMCN5WnlTR4WFtMG7dsDcGr3scKwmTCy2AjTwZHz6gsjesnihM5GbrGS3ykLCS1Yto2dexyomvDaen5oZHzRL0AnhMPBEXocsHpKIPBi1WrKslhUzPDfhMIiGGa69kYto2AFGlmhMQoaIMCN5WS1sATMdZ0nVyhbPWhsX0nKA4isPfPcJunlTOeGks0ijsnIuArQWi122eqrPk99Ck9wHudrknEaPEFrkMU5f7iif(qkMUHudhrknqQWivZslkbOIensIudhrkn4WnlTR4WmDde4UYKNCS1QLlmhUzPDfhMPBamDuIdtvhartUZ8KJTwn4cZHPQdGOj3zoCZs7koCAX0ce0qICy2AjTwZHzNyWbK5A4iKkmsX0nVyhbPWhsX0nKA4isPbsfgPcC)FVmVveq9M6GUMGVTKFEykomZbdIazVXuk5yRLNCS1oixyomvDaen5oZHzRL0AnhoW9)9mDdqfTXo8YSz4qQHi1GpGu4dPcjsfcrQMLwucqfjAKePcJubU)VxM3kcOEtDqxtW3wYppmfsfgPWcsXUdAEyk)AsRIbs3cGZy48lj2wjrQHiLgivyKIDh08Wu(Vjtj4(GV76WVKyBLePgIuAGuVVif7oO5HP8RjTkgiDlaoJHZVKyBLePecPgePcJuS7GMhMY)nzkb3h8Dxh(LeBRKi1qKAqKkmsX0nKAisnis9(IuS7GMhMYVM0QyG0Ta4mgo)sITvsKAisnisfgPy3bnpmL)BYucUp47Uo8lj2wjrkHqQbrQWift3qQHif(JuVVift38IDeKcFift3qkHgrkTivyKIkAJD4ttKa5be7iiLqiLgifwrQ3xKkW9)9mDdqfTXo8YSz4qQHiL2hqQWi13I1tWsITvsKsiKAaWHBwAxXHLcSQSkgW2UiaoJHJNCS1I)CH5Wu1bq0K7mhUzPDfhoaQz4o3eGZy44WS1sATMdZoXGdiZ1WrivyKcliv2quLEjTuzPdpvDaenrQWif7oO5HP8sAPYsh(LeBRKiLqi1Gi17lsXUdAEyk)AsRIbs3cGZy48lj2wjrQHiLwKkmsXUdAEyk)3KPeCFW3DD4xsSTsIudrkTi17lsXUdAEyk)AsRIbs3cGZy48lj2wjrkHqQbrQWif7oO5HP8FtMsW9bF31HFjX2kjsnePgePcJumDdPgIuAGuVVif7oO5HP8RjTkgiDlaoJHZVKyBLePgIudIuHrk2DqZdt5)MmLG7d(URd)sITvsKsiKAqKkmsX0nKAisnis9(IumDdPgIuHePEFrQa3)3hC4ac2J5DfGuyLdZCWGiq2BmLso2A5jhBTHKlmhMQoaIMCN5WnlTR4WPftlqqdjYHzRL0AnhMDIbhqMRHJqQWift38IDeKcFift3qQHJiLgCyMdgebYEJPuYXwlp5yR9X4cZHPQdGOj3zomBTKwR5WmDZl2rqk8HumDdPgoIuA5WnlTR4W9Y6Ia5Tlvjp5yRDaWfMdBvs76ki5WA5WnlTR4WFihwfdK0kGQeGZy44Wu1bq0K7mp5yR9r5cZHPQdGOj3zoCZs7koCauZWDUjaNXWXHzRL0AnhMDIbhqMRHJqQWif7oO5HP8FtMsW9bF31HFjX2kjsjesnisfgPy6gsnIuAGuHrkblffeZMET(0IPfiOHerQWifv0g7WNMibYdeYhqkHqkTCyMdgebYEJPuYXwlp5yRDG4cZHPQdGOj3zoCZs7koCauZWDUjaNXWXHzRL0AnhMDIbhqMRHJqQWifv0g7WNMibYdi2rqkHqknqQWifwqkMU5f7iif(qkMUHucnIuArQ3xKsWsrbXSPxRpTyAbcAirKcRCyMdgebYEJPuYXwlp5jhMnbs6ZfMJTwUWCyQ6aiAYDMdZwlP1AoSMGur716aiYRFqtqexQqQ3xKk4KsKkms9Ty9eSKyBLePecP0iKC4ML2vCyRIE4iqexQ4jhBn4cZHPQdGOj3zomBTKwR5WFlwpblj2wjrQHifwqkTp6dif(qQ1TO)TXK)3zdbYZLP7PQdGOjsfcrkTA8asHvK69fPcC)FVmVveq9M6GUMGVTKFEykKkmsjGsFexQaPobWOBjbslMwFZslkHuVVivWjLivyK6BX6jyjX2kjsjesP9boCZs7koCEUmDW9btQtDEYXEqUWCyQ6aiAYDMdZwlP1AomwqQTTjGIsv675u6TcPgIu4FirQ3xKABBcOOuL(EoLExbifwrQWif7oO5HP8RjTkgiDlaoJHZVKyBLePecPOieZnjqAIehUzPDfhgd1cUscUp42jT8KJn(ZfMdtvhartUZCy2AjTwZHzNyWbK5A4iKkmsHfKABBcOOuL(EoLERqQHiL2hqQ3xKABBcOOuL(EoLExbifw5WnlTR4W)MGSIaY8efWto2HKlmhMQoaIMCN5WS1sATMdVTnbuuQsFpNsVvi1qKAWhqQ3xKABBcOOuL(EoLExbC4ML2vC4Fdbrf42jT8KJ9JXfMdtvhartUZCy2AjTwZH32MakkvPVNtP3kKAisfYhqQ3xKABBcOOuL(EoLExbC4ML2vC4GROPRmbblHHddzfbyto8J9ap5ypa4cZHPQdGOj3zomBTKwR5WSRMUw6z3TtR6KMG7)PsArjpvDaen5WnlTR4WY8wra1BQd6Ac(2sGVfPtINCSFuUWCyQ6aiAYDMdZwlP1Aom7oO5HP8Y8wra1BQd6Ac(2sEMEVXKePgrknqQ3xKk4KsKkms9Ty9eSKyBLePecP04bK69fPWcsTTnbuuQsFpNs)sITvsKAisPnKi17lsPjif7IsvxPhNJ16cPcJuybPWcsTTnbuuQsFpNsVvi1qKIDh08WuEzERiG6n1bDnbFBj)3fccSetV3ycKMiHuVViLMGuBBtafLQ03ZP0trmzkrkSIuHrkSGuS7GMhMYBv0dhbI4sfi1jagDljqAX06xsSTsIudrk2DqZdt5L5TIaQ3uh01e8TL8FxiiWsm9EJjqAIes9(Iur716aiYRFqtqexQqkSIuyfPcJuS7GMhMY)nzkb3h8Dxh(LeBRKiLqJi1aHuHrkMUHudhrknqQWif7oO5HP8y0TfYQyWC74RacClMUFjX2kjsj0isPvdKcRC4ML2vCyzERiG6n1bDnbFBjEYXEG4cZHPQdGOj3zomBTKwR5WSlkvDLECowRlKkmsHfKkW9)9yOwWvsW9b3oP17kaPEFrkSGubNuIuHrQVfRNGLeBRKiLqif7oO5HP8yOwWvsW9b3oP1VKyBLePEFrk2DqZdt5XqTGRKG7dUDsRFjX2kjsnePy3bnpmLxM3kcOEtDqxtW3wY)DHGalX07nMaPjsifwrQWif7oO5HP8FtMsW9bF31HFjX2kjsj0isnqivyKIPBi1WrKsdKkmsXUdAEykpgDBHSkgm3o(kGa3IP7xsSTsIucnIuA1aPWkhUzPDfhwM3kcOEtDqxtW3wINCS1(axyomvDaen5oZHzRL0AnhwaL(iUubsDcGr3scKwmT(MLwucPEFrQGtkrQWi13I1tWsITvsKsiKsJh4WnlTR4WwjzRB2bqea)62v6kcMuuJr8KJTwTCH5Wu1bq0K7mhMTwsR1Cybu6J4sfi1jagDljqAX06BwArjK69fPcoPePcJuFlwpblj2wjrkHqknEGd3S0UIdJz7uxMxr8KJTwn4cZHPQdGOj3zomBTKwR5WcO0hXLkqQtam6wsG0IP13S0Isi17lsfCsjsfgP(wSEcwsSTsIucHuA8ahUzPDfhogQNwN3kbb9mM4jhBTdYfMdtvhartUZCy2AjTwZH1eKkAVwhar(iUubUc4kjqUwHJsK69fPy3bnpmL3QOhoceXLkqQtam6wsG0IP1VKyBLePgIuA8as9(Iur716aiYRFqtqexQ4WnlTR4WUscyjjk5jhBT4pxyomvDaen5oZHzRL0Anh(BX6jyjX2kjsneP0gYbcPEFrkbu6J4sfi1jagDljqAX06BwArjK69fPI2R1bqKx)GMGiUuXHBwAxXHZZLPdUpaxVInp5yRnKCH5Wu1bq0K7mhMTwsR1Cy2DqZdt5Tk6HJarCPcK6eaJULeiTyA9lj2wjrQHi1GpGuVViv0EToaI86h0eeXLkK69fPcoPePcJuFlwpblj2wjrkHqknEGd3S0UIdhaD3e8Dxh8KJT2hJlmhMQoaIMCN5WS1sATMdZUdAEykVvrpCeiIlvGuNay0TKaPftRFjX2kjsnePg8bK69fPI2R1bqKx)GMGiUuHuVVivWjLivyK6BX6jyjX2kjsjesPnKC4ML2vC4aAL0IZQyEYXw7aGlmhUzPDfhgYI1tjyGDNXIuLCyQ6aiAYDMNCS1(OCH5Wu1bq0K7mhMTwsR1Cy2DqZdt5Tk6HJarCPcK6eaJULeiTyA9lj2wjrQHi1GpGuVViv0EToaI86h0eeXLkK69fPcoPePcJuFlwpblj2wjrkHqkTpWHBwAxXH)2sbq3n5jhBTdexyomvDaen5oZHzRL0AnhMDh08WuERIE4iqexQaPobWOBjbslMw)sITvsKAisn4di17lsfTxRdGiV(bnbrCPcPEFrQGtkrQWi13I1tWsITvsKsiKsJh4WnlTR4WDXizUneG1qq8KJTgpWfMdtvhartUZCy2AjTwZHdC)FVmVveq9M6GUMGVTKFEykoCZs7koCqhdUpixJHtYtEYHN0VDHsUWCS1YfMd3S0UIdlfq9c07AcK5A4iomvDaen5oZto2AWfMdtvhartUZC4tahwsjhUzPDfhoAVwharC4OnKlXHz3bnpmL3QOhoceXLkqQtam6wsG0IP1VKyBLePgIuFlwpblj2wjrQ3xK6BX6jyjX2kjsjesPvJhqQWi13I1tWsITvsKAisXUdAEykVKwQS0HFjX2kjsfgPy3bnpmLxslvw6WVKyBLePgIuAFGdhTxq1Iehw)GMGiUuXto2dYfMdtvhartUZCy2AjTwZHXcsf4()EjTuzPdVRaK69fPcC)FVmVveq9M6GUMGVTK3vasHvKkmsjGsFexQaPobWOBjbslMwFZslkHuVVivWjLivyK6BX6jyjX2kjsj0is9ypWHBwAxXHfCPDfp5yJ)CH5Wu1bq0K7mhMTwsR1C4a3)3lPLklD4DfWHBwAxXHzneeOzPDfaYKjhgYKjOArIdlPLklDWto2HKlmhMQoaIMCN5WS1sATMdh4()Emul4kj4(GBN06DfWHBwAxXHzneeOzPDfaYKjhgYKjOArIdJHAbxjb3hC7KwEYX(X4cZHPQdGOj3zomBTKwR5WPjsiLqif(JuHrkMUHucHuHePcJuAcsjGsFexQaPobWOBjbslMwFZslkXHBwAxXHzneeOzPDfaYKjhgYKjOArIdFcOIwEYXEaWfMdtvhartUZC4ML2vC4VjtW9bPobWOBjbslMwomBTKwR5WmDZl2rqk8HumDdPgoIudIuHrkSGuurBSdFAIeipGyhbPecP0IuVVifv0g7WNMibYdi2rqkHqk8hPcJuS7GMhMY)nzkb3h8Dxh(LeBRKiLqiLwFirQ3xKIDh08WuEmul4kj4(GBN06xsSTsIucHuAGuyLdZCWGiq2BmLso2A5jh7hLlmhMQoaIMCN5WS1sATMdZ0nVyhbPWhsX0nKA4isPfPcJuybPOI2yh(0ejqEaXocsjesPfPEFrk2DqZdt5L0sLLo8lj2wjrkHqknqQ3xKIkAJD4ttKa5be7iiLqif(JuHrk2DqZdt5)MmLG7d(URd)sITvsKsiKsRpKi17lsXUdAEykpgQfCLeCFWTtA9lj2wjrkHqknqkSYHBwAxXHPiciiGEVI8KJ9aXfMdtvhartUZC4ML2vC40IPfiOHe5WS1sATMdZoXGdiZ1WrivyKIPBEXocsHpKIPBi1WrKsdKkmsHfKIkAJD4ttKa5be7iiLqiLwK69fPy3bnpmLxslvw6WVKyBLePecP0aPEFrkQOn2HpnrcKhqSJGucHu4psfgPy3bnpmL)BYucUp47Uo8lj2wjrkHqkT(qIuVVif7oO5HP8yOwWvsW9b3oP1VKyBLePecP0aPWkhM5GbrGS3ykLCS1Yto2AFGlmhMQoaIMCN5WS1sATMdRjiv2quLEjTuzPdpvDaen5WnlTR4WSgcc0S0UcazYKddzYeuTiXHztGK(8KJTwTCH5Wu1bq0K7mhMTwsR1C4SHOk9sAPYshEQ6aiAYHBwAxXHzneeOzPDfaYKjhgYKjOArIdZMajTuzPdEYXwRgCH5Wu1bq0K7mhMTwsR1C4MLwucqfjAKePecPgKd3S0UIdZAiiqZs7kaKjtomKjtq1IehwM8KJT2b5cZHPQdGOj3zomBTKwR5WnlTOeGks0ijsnCePgKd3S0UIdZAiiqZs7kaKjtomKjtq1IehUpIN8Kdlyj2jg0jxyo2A5cZHBwAxXHdUmHOj4d1oOjgRIb5fXkomvDaen5oZto2AWfMdtvhartUZC4tahwsjhUzPDfhoAVwharC4OnKlXHj8RRjqan9wjzRB2bqea)62v6kcMuuJri17lsr4xxtGaA6JH6P15TsqqpJjK69fPi8RRjqan9y2o1L5vehoAVGQfjoCexQaxbCLeixRWrjp5ypixyomvDaen5oZHzRL0AnhwtqQSHOk9sAPYshEQ6aiAIuVViLMGuzdrv6)Mmb3hK6eaJULeiTyA9u1bq0Kd3S0UIdZ0nqG7ktEYXg)5cZHPQdGOj3zomBTKwR5WAcsLnevPNkAJTqqRIbeKfHwpvDaen5WnlTR4WmDdGPJs8KNC4(iUWCS1YfMd3S0UIdJr3wiRIbZTJVciWTy6CyQ6aiAYDMNCS1GlmhMQoaIMCN5WS1sATMdZ0nVyhbPWhsX0nKA4isPbsfgPOI2yh(0ejqEaXocsneP0aPEFrkMU5f7iif(qkMUHudhrk8Nd3S0UIdtfTXwiOvXacYIylp5ypixyomvDaen5oZHzRL0AnhMDIbhqMRHJqQWifwqQa3)3p7IrG7dy62aBExbi17lsnPa3)3hCfnDLjiyjmExbifw5WnlTR4WsbwvwfdyBxeaNXWXto24pxyomvDaen5oZHzRL0AnhMkAJD4ttKa5be7ii1qKIIqm3KaPjsi17lsX0nVyhbPWhsX0nKsOrKslhUzPDfh(BYucUp47Uo4jh7qYfMdtvhartUZC4ML2vC41KwfdKUfaNXWXHzRL0Anhgliv2quLEm62czvmyUD8vabUft3tvhartKkmsXUdAEyk)AsRIbs3cGZy48t3Tt7kKAisXUdAEykpgDBHSkgm3o(kGa3IP7xsSTsIuoHu4psHvKkmsHfKIDh08Wu(Vjtj4(GV76WVKyBLePgIudIuVVift3qQHJivirkSYHzoyqei7nMsjhBT8KJ9JXfMdtvhartUZCy2AjTwZHdC)F)6k1TkgmW9KaySA6NhMId3S0UIdVUsDRIbdCpjagRM8KJ9aGlmhMQoaIMCN5WS1sATMdZ0nVyhbPWhsX0nKA4isPLd3S0UIdtreqqa9Ef5jh7hLlmhMQoaIMCN5WnlTR4WFtMG7dsDcGr3scKwmTCy2AjTwZHz6MxSJGu4dPy6gsnCePgKdZCWGiq2BmLso2A5jh7bIlmhMQoaIMCN5WS1sATMdZ0nVyhbPWhsX0nKA4isPbhUzPDfhMPBGa3vM8KJT2h4cZHPQdGOj3zomBTKwR5WbU)Vp1jajkG2BLawlOzwERxMndhsneP0oqivyKIkAJD4ttKa5be7ii1qKIIqm3KaPjsif(qkTivyKIDh08Wu(Vjtj4(GV76WVKyBLePgIuueI5MeinrId3S0UIdZ2MHdYQyWa3tcazX6zzvmp5yRvlxyomvDaen5oZHBwAxXHtlMwGGgsKdZwlP1Aomt38IDeKcFift3qQHJiLgivyKcliLMGuzdrv61TeWoXGZtvhartK69fPyNyWbK5A4iKcRCyMdgebYEJPuYXwlp5yRvdUWCyQ6aiAYDMdZwlP1Aomt38IDeKcFift3qQHJiLwoCZs7koCVSUiqE7svYto2AhKlmhMQoaIMCN5WS1sATMdZoXGdiZ1WrivyKclif7oO5HP8bxrtxzccwcJFjX2kjsneP0aPEFrknbPyxuQ6k9fX2d62jsHvKkmsHfKIPBi1WrKkKi17lsXUdAEyk)3KPeCFW3DD4xsSTsIudrQhdPEFrk2DqZdt5)MmLG7d(URd)sITvsKAisnisfgPy6gsnCePgePcJuurBSdFAIeipqiFaPecP0IuVVifv0g7WNMibYdi2rqkHgrkSGudIuoHudIuHqKIDh08Wu(Vjtj4(GV76WVKyBLePecPcjsHvK69fPcC)FVmVveq9M6GUMGVTK3vasHvoCZs7koSuGvLvXa22fbWzmC8KJTw8NlmhMQoaIMCN5WS1sATMdZoXGdiZ1WrC4ML2vCyMUbW0rjEYXwBi5cZHPQdGOj3zoCZs7ko8hYHvXajTcOkb4mgoomBTKwR5WbU)Vp4WbeShZppmfh2QK21vqYH1Yto2AFmUWCyQ6aiAYDMd3S0UIdha1mCNBcWzmCCy2AjTwZHzNyWbK5A4iKkmsHfKkW9)9bhoGG9yExbi17lsLnevPx3sa7edopvDaenrQWiLGLIcIztVwFAX0ce0qIivyKIPBi1isPbsfgPy3bnpmL)BYucUp47Uo8lj2wjrkHqQbrQ3xKIPBEXocsHpKIPBiLqJiLwKkmsjyPOGy20R1lfyvzvmGTDraCgdhsfgPOI2yh(0ejqEaXocsjesnisHvomZbdIazVXuk5yRLN8KNC4O0kTR4yRXdAO9HbFyaWHX0BzvSKdJFGFQPGTMk2dWdisHucRtiLjk42eP(3IuAgd1cUscUp42jTAgPwc)6Alnrk5jsiv7MNyN0ePy6Dftsp65JBfHuAmGiLM(QO0M0eP0C2quL(quZivEiLMZgIQ0hIEQ6aiAQzKQtKke4r6XrkSOncw9ONpUvesn4aIuA6RIsBstKsZzdrv6drnJu5HuAoBiQsFi6PQdGOPMrQorQqGhPhhPWI2iy1JE(4wri1anGiLMcjErPjsjA1agIiftNy4qkSuxIuD02G6aicPScPirxOoTRWksHfTrWQh98XTIqkTdGbeP00xfL2KMiLMZgIQ0hIAgPYdP0C2quL(q0tvhartnJuyrBeS6rpFCRiKs7JoGiLMcjErPjsjA1agIiftNy4qkSuxIuD02G6aicPScPirxOoTRWksHfTrWQh9e9e)a)utbBnvShGhqKcPewNqktuWTjs9VfP0SKwQS0HMrQLWVU2stKsEIes1U5j2jnrkMExXK0JE(4wriL2hgqKstFvuAtAIuAoBiQsFiQzKkpKsZzdrv6drpvDaen1ms1jsfc8i94ifw0gbRE0t0t8d8tnfS1uXEaEarkKsyDcPmrb3Mi1)wKsZSjqslvw6qZi1s4xxBPjsjprcPA38e7KMiftVRys6rpFCRiKAGgqKstFvuAtAIuAEDl6FBm5drnJu5HuAEDl6FBm5drpvDaen1msHfTrWQh9e9e)a)utbBnvShGhqKcPewNqktuWTjs9VfP0Sm1msTe(11wAIuYtKqQ2npXoPjsX07kMKE0Zh3kcPW)beP00xfL2KMiLMZgIQ0hIAgPYdP0C2quL(q0tvhartnJuDIuHapsposHfTrWQh98XTIqQhBarkn9vrPnPjsP5SHOk9HOMrQ8qknNnevPpe9u1bq0uZifw0gbRE0Zh3kcP0I)disPPVkkTjnrknNnevPpe1msLhsP5SHOk9HONQoaIMAgPWI2iy1JEIEIFGFQPGTMk2dWdisHucRtiLjk42eP(3IuAMnbs6RzKAj8RRT0ePKNiHuTBEIDstKIP3vmj9ONpUvesPXaIuA6RIsBstKsZRBr)BJjFiQzKkpKsZRBr)BJjFi6PQdGOPMrkSOncw9ONON4h4NAkyRPI9a8aIuiLW6eszIcUnrQ)TiLMN0VDHsnJulHFDTLMiL8ejKQDZtStAIum9UIjPh98XTIqkTpmGiLM(QO0M0eP0C2quL(quZivEiLMZgIQ0hIEQ6aiAQzKQtKke4r6XrkSOncw9ONpUvesPv7aIuA6RIsBstKsZzdrv6drnJu5HuAoBiQsFi6PQdGOPMrQorQqGhPhhPWI2iy1JEIEIFGFQPGTMk2dWdisHucRtiLjk42eP(3IuAUpsZi1s4xxBPjsjprcPA38e7KMiftVRys6rpFCRiKkKdisPPVkkTjnrknNnevPpe1msLhsP5SHOk9HONQoaIMAgPWI2iy1JE(4wriLwTdisPPVkkTjnrknNnevPpe1msLhsP5SHOk9HONQoaIMAgPWI2iy1JE(4wriL2hBarkn9vrPnPjsP5SHOk9HOMrQ8qknNnevPpe9u1bq0uZifw0gbRE0t0tnvrb3M0ePgiKQzPDfsbzYu6rp5WTBQFlhg2e10Cyb79niId)iEeif(HvtmneoArQh5RWHE(iEei1JCVmDK6rXdP04bn0IEIE(iEeiLWyOghsnaXKPePUpsnaXDDGuwL0UUcsKc6InMh98r8iqkHXqnoKcwGvLvXiLME7IqQbOmgoKc6InMh98r8iqk8Z5ePcoP8BX6jsX0jgojsLhsj2LdKstpansrvUgj9ONONpIhbsfceHyUjnrQa6FlHuStmOtKkGITs6rk8tgJeKsKQUcF69k(DHqQML2vsK6kihE0ZML2vsVGLyNyqNongAWLjenbFO2bnXyvmiViwHE2S0Us6fSe7ed60PXqJ2R1bqeEvlsJrCPcCfWvsGCTchL4DcgLuIx0gYLgj8RRjqan9wjzRB2bqea)62v6kcMuuJrVVe(11eiGM(yOEADERee0Zy69LWVUMab00Jz7uxMxrONnlTRKEblXoXGoDAmuMUbcCxzIN9h1KSHOk9sAPYshEQ6aiA((Qjzdrv6)Mmb3hK6eaJULeiTyA9u1bq0e9SzPDL0lyj2jg0PtJHY0naMokHN9h1KSHOk9urBSfcAvmGGSi06PQdGOj6j65J4rGuHariMBstKIIsRdKknrcPsDcPAwElszsKQJ2guharE0ZML2vYrPaQxGExtGmxdhHE2S0Us60yOr716aicVQfPr9dAcI4sfENGrjL4fTHCPr2DqZdt5Tk6HJarCPcK6eaJULeiTyA9lj2wjh(Ty9eSKyBL899BX6jyjX2kPqA14HWFlwpblj2wjhYUdAEykVKwQS0HFjX2kzy2DqZdt5L0sLLo8lj2wjhQ9b0ZML2vsNgdvWL2v4z)rSe4()EjTuzPdVRG33a3)3lZBfbuVPoORj4Bl5DfG1WcO0hXLkqQtam6wsG0IP13S0IsVVbNug(BX6jyjX2kPqJp2dONnlTRKongkRHGanlTRaqMmXRArAuslvw6ap7pg4()EjTuzPdVRa0ZML2vsNgdL1qqGML2vaitM4vTinIHAbxjb3hC7Kw8S)yG7)7XqTGRKG7dUDsR3va6zZs7kPtJHYAiiqZs7kaKjt8QwKgpburlE2Fmnrsi8pmt3ekKH1ebu6J4sfi1jagDljqAX06BwArj0ZML2vsNgd9BYeCFqQtam6wsG0IPfpMdgebYEJPuoQfp7pY0nVyhbFmDB44GHXcv0g7WNMibYdi2res77lv0g7WNMibYdi2rec)dZUdAEyk)3KPeCFW3DD4xsSTskKwFiFFz3bnpmLhd1cUscUp42jT(LeBRKcPbwrpBwAxjDAmukIaccO3RiE2FKPBEXoc(y62WrTHXcv0g7WNMibYdi2res77l7oO5HP8sAPYsh(LeBRKcPX7lv0g7WNMibYdi2rec)dZUdAEyk)3KPeCFW3DD4xsSTskKwFiFFz3bnpmLhd1cUscUp42jT(LeBRKcPbwrpBwAxjDAm00IPfiOHeXJ5GbrGS3ykLJAXZ(JStm4aYCnCuyMU5f7i4JPBdh1imwOI2yh(0ejqEaXoIqAFFz3bnpmLxslvw6WVKyBLuinEFPI2yh(0ejqEaXoIq4Fy2DqZdt5)MmLG7d(URd)sITvsH06d57l7oO5HP8yOwWvsW9b3oP1VKyBLuinWk6zZs7kPtJHYAiiqZs7kaKjt8QwKgztGK(4z)rnjBiQsVKwQS0b6zZs7kPtJHYAiiqZs7kaKjt8QwKgztGKwQS0bE2FmBiQsVKwQS0b6zZs7kPtJHYAiiqZs7kaKjt8QwKgLjE2FSzPfLaurIgjfAq0ZML2vsNgdL1qqGML2vaitM4vTin2hHN9hBwArjavKOrYHJdIEIE2S0Us67JgXOBlKvXG52Xxbe4wmD0ZML2vsFFKtJHsfTXwiOvXacYIylE2FKPBEXoc(y62WrnctfTXo8PjsG8aIDKHA8(Y0nVyhbFmDB4i(JE2S0Us67JCAmuPaRkRIbSTlcGZy4WZ(JStm4aYCnCuySe4()(zxmcCFat3gyZ7k49DsbU)Vp4kA6ktqWsy8UcWk6zZs7kPVpYPXq)MmLG7d(URd8S)iv0g7WNMibYdi2rgsriMBsG0eP3xMU5f7i4JPBcnQf9SzPDL03h50yORjTkgiDlaoJHdpMdgebYEJPuoQfp7pILSHOk9y0TfYQyWC74RacClMEy2DqZdt5xtAvmq6waCgdNF6UDAxnKDh08WuEm62czvmyUD8vabUft3VKyBL0j8hRHXc7oO5HP8FtMsW9bF31HFjX2k5WbFFz62WXqIv0ZML2vsFFKtJHUUsDRIbdCpjagRM4z)Xa3)3VUsDRIbdCpjagRM(5HPqpBwAxj99rongkfrabb07vep7pY0nVyhbFmDB4Ow0ZML2vsFFKtJH(nzcUpi1jagDljqAX0IhZbdIazVXukh1IN9hz6MxSJGpMUnCCq0ZML2vsFFKtJHY0nqG7kt8S)it38IDe8X0THJAGE2S0Us67JCAmu22mCqwfdg4EsailwplRIXZ(JbU)Vp1jajkG2BLawlOzwERxMnd3qTduyQOn2HpnrcKhqSJmKIqm3KaPjs4tBy2DqZdt5)MmLG7d(URd)sITvYHueI5Meinrc9SzPDL03h50yOPftlqqdjIhZbdIazVXukh1IN9hz6MxSJGpMUnCuJWyrtYgIQ0RBjGDIb37l7edoGmxdhHv0ZML2vsFFKtJH2lRlcK3UuL4z)rMU5f7i4JPBdh1IE2S0Us67JCAmuPaRkRIbSTlcGZy4WZ(JStm4aYCnCuySWUdAEykFWv00vMGGLW4xsSTsouJ3xnHDrPQR0xeBpOBNynmwy62WXq((YUdAEyk)3KPeCFW3DD4xsSTso8XEFz3bnpmL)BYucUp47Uo8lj2wjhoyyMUnCCWWurBSdFAIeipqiFqiTVVurBSdFAIeipGyhrOrSmOtdgcz3bnpmL)BYucUp47Uo8lj2wjfkKy99nW9)9Y8wra1BQd6Ac(2sExbyf9SzPDL03h50yOmDdGPJs4z)r2jgCazUgoc9SzPDL03h50yOFihwfdK0kGQeGZy4WZ(JbU)Vp4WbeShZppmfEwL0UUcYrTONnlTRK((iNgdnaQz4o3eGZy4WJ5GbrGS3ykLJAXZ(JStm4aYCnCuySe4()(GdhqWEmVRG33SHOk96wcyNyWfwWsrbXSPxRpTyAbcAiXWmDBuJWS7GMhMY)nzkb3h8Dxh(LeBRKcn47lt38IDe8X0nHg1gwWsrbXSPxRxkWQYQyaB7Ia4mgUWurBSdFAIeipGyhrObXk6j6zZs7kPNnbs6pAv0dhbI4sfi1jagDljqAX0IN9h1KO9ADae51pOjiIlvVVbNug(BX6jyjX2kPqAes0ZML2vspBcK03PXqZZLPdUpysDQJN9h)wSEcwsSTsoelAF0hW36w0)2yY)7SHa55Y0dHA14bS((g4()EzERiG6n1bDnbFBj)8WuHfqPpIlvGuNay0TKaPftRVzPfLEFdoPm83I1tWsITvsH0(a6zZs7kPNnbs670yOyOwWvsW9b3oPfp7pILTTjGIsv675u6TAi(hY33TTjGIsv675u6DfG1WS7GMhMYVM0QyG0Ta4mgo)sITvsHOieZnjqAIe6zZs7kPNnbs670yO)MGSIaY8efGN9hzNyWbK5A4OWyzBBcOOuL(EoLERgQ9H33TTjGIsv675u6DfGv0ZML2vspBcK03PXq)neevGBN0IN9h32MakkvPVNtP3QHd(W7722eqrPk99Ck9UcqpBwAxj9SjqsFNgdn4kA6ktqWsyWZ(JBBtafLQ03ZP0B1Wq(W7722eqrPk99Ck9UcWdYkcWMJp2dONnlTRKE2eiPVtJHkZBfbuVPoORj4Blb(wKoj8S)i7QPRLE2D70QoPj4(FQKwuYtvhart0ZML2vspBcK03PXqL5TIaQ3uh01e8TLWZ(JS7GMhMYlZBfbuVPoORj4Bl5z69gtYrnEFdoPm83I1tWsITvsH04H3xSSTnbuuQsFpNs)sITvYHAd57RMWUOu1v6X5yTUcJfSSTnbuuQsFpNsVvdz3bnpmLxM3kcOEtDqxtW3wY)DHGalX07nMaPjsVVAY22eqrPk99Ck9uetMsSgglS7GMhMYBv0dhbI4sfi1jagDljqAX06xsSTsoKDh08WuEzERiG6n1bDnbFBj)3fccSetV3ycKMi9(gTxRdGiV(bnbrCPcRynm7oO5HP8FtMsW9bF31HFjX2kPqJduyMUnCuJWS7GMhMYJr3wiRIbZTJVciWTy6(LeBRKcnQvdSIE2S0Us6ztGK(ongQmVveq9M6GUMGVTeE2FKDrPQR0JZXADfglbU)Vhd1cUscUp42jTExbVVyj4KYWFlwpblj2wjfIDh08WuEmul4kj4(GBN06xsSTs((YUdAEykpgQfCLeCFWTtA9lj2wjhYUdAEykVmVveq9M6GUMGVTK)7cbbwIP3BmbstKWAy2DqZdt5)MmLG7d(URd)sITvsHghOWmDB4OgHz3bnpmLhJUTqwfdMBhFfqGBX09lj2wjfAuRgyf9SzPDL0ZMaj9DAmuRKS1n7aicGFD7kDfbtkQXi8S)Oak9rCPcK6eaJULeiTyA9nlTO07BWjLH)wSEcwsSTskKgpGE2S0Us6ztGK(ongkMTtDzEfHN9hfqPpIlvGuNay0TKaPftRVzPfLEFdoPm83I1tWsITvsH04b0ZML2vspBcK03PXqJH6P15TsqqpJj8S)Oak9rCPcK6eaJULeiTyA9nlTO07BWjLH)wSEcwsSTskKgpGE2S0Us6ztGK(ongQRKawsIs8S)OMeTxRdGiFexQaxbCLeixRWr57l7oO5HP8wf9WrGiUubsDcGr3scKwmT(LeBRKd14H33O9ADae51pOjiIlvONnlTRKE2eiPVtJHMNlthCFaUEfB8S)43I1tWsITvYHAd5a9(kGsFexQaPobWOBjbslMwFZslk9(gTxRdGiV(bnbrCPc9SzPDL0ZMaj9DAm0aO7MGV76ap7pYUdAEykVvrpCeiIlvGuNay0TKaPftRFjX2k5WbF49nAVwharE9dAcI4s17BWjLH)wSEcwsSTskKgpGE2S0Us6ztGK(ongAaTsAXzvmE2FKDh08WuERIE4iqexQaPobWOBjbslMw)sITvYHd(W7B0EToaI86h0eeXLQ33Gtkd)Ty9eSKyBLuiTHe9SzPDL0ZMaj9DAmuilwpLGb2DglsvIE2S0Us6ztGK(ong63wka6UjE2FKDh08WuERIE4iqexQaPobWOBjbslMw)sITvYHd(W7B0EToaI86h0eeXLQ33Gtkd)Ty9eSKyBLuiTpGE2S0Us6ztGK(ongAxmsMBdbyneeE2FKDh08WuERIE4iqexQaPobWOBjbslMw)sITvYHd(W7B0EToaI86h0eeXLQ33Gtkd)Ty9eSKyBLuinEa9SzPDL0ZMaj9DAm0GogCFqUgdNep7pg4()EzERiG6n1bDnbFBj)8WuONONnlTRKE2eiPLklDmgTxRdGi8QwKgL0sLLoabURmX7emkPeVOnKlnYUdAEykVKwQS0HFjX2kPqAFFfqPpIlvGuNay0TKaPftRVzPfLcZUdAEykVKwQS0HFjX2k5WbF49n4KYWFlwpblj2wjfsJhqpBwAxj9Sjqslvw6WPXqTk6HJarCPcK6eaJULeiTyAXZ(JAs0EToaI86h0eeXLQ33Gtkd)Ty9eSKyBLuincj6zZs7kPNnbsAPYshongAa0DtW3DDGN9hJ2R1bqKxslvw6ae4UYe9SzPDL0ZMajTuzPdNgdnGwjT4Skgp7pgTxRdGiVKwQS0biWDLj6zZs7kPNnbsAPYshongkKfRNsWa7oJfPkrpBwAxj9Sjqslvw6WPXq)2sbq3nXZ(Jr716aiYlPLklDacCxzIE2S0Us6ztGKwQS0HtJH2fJK52qawdbHN9hJ2R1bqKxslvw6ae4UYe9SzPDL0ZMajTuzPdNgdnOJb3hKRXWjXZ(Jr716aiYlPLklDacCxzIE2S0Us6ztGKwQS0HtJHMNlthCFWK6uhp7p(Ty9eSKyBLCiw0(OpGV1TO)TXK)3zdbYZLPhc1QXdy99vaL(iUubsDcGr3scKwmT(MLwu69n4KYWFlwpblj2wjfs7dONnlTRKE2eiPLklD40yO55Y0b3hGRxXgp7p(Ty9eSKyBLC4a9W7Rak9rCPcK6eaJULeiTyA9nlTO07BWjLH)wSEcwsSTskK2hqpBwAxj9Sjqslvw6WPXqXqTGRKG7dUDslE2FKDh08Wu(1KwfdKUfaNXW5xsSTskefHyUjbstKqpBwAxj9Sjqslvw6WPXqTsYw3SdGia(1TR0vemPOgJWZ(Jr716aiYlPLklDacCxzIE2S0Us6ztGKwQS0HtJHIz7uxMxr4z)XO9ADae5L0sLLoabURmrpBwAxj9Sjqslvw6WPXqJH6P15TsqqpJj8S)y0EToaI8sAPYshGa3vMONnlTRKE2eiPLklD40yOUscyjjkXZ(JAs0EToaI8rCPcCfWvsGCTchLVVS7GMhMYBv0dhbI4sfi1jagDljqAX06xsSTsouJhEFJ2R1bqKx)GMGiUuHE2S0Us6ztGKwQS0HtJH(BcYkciZtua6zZs7kPNnbsAPYshong6VHGOcC7Kw0ZML2vspBcK0sLLoCAm0GROPRmbblHb9SzPDL0ZMajTuzPdNgdvslvw6ap7pYUdAEyk)AsRIbs3cGZy48lj2wjfsJ33Gtkd)Ty9eSKyBLuiTHe9SzPDL0ZMajTuzPdNgdnOJb3hKRXWjrprpBwAxj9NaQOD8BYeCFqQtam6wsG0IPfpMdgebYE3ykLJAXZ(JmDZl2rWht3gooi6zZs7kP)eqfTongkfrabb07vep7pMnevPNPBGa3vMEQ6aiAgMPBEXoc(y62WXbrpBwAxj9NaQO1PXqtlMwGGgsepMdgebYEJPuoQfp7pYoXGdiZ1WrHz6MxSJGpMUnCud0ZML2vs)jGkADAmuMUbW0rj8S)it38IDe8X0TrnqpBwAxj9NaQO1PXqPiciiGEVIONnlTRK(tav060yOPftlqqdjIhZbdIazVXukh1IN9hz6MxSJGpMUnCud0t0ZML2vsVKwQS0X43KPeCFW3DDGN9hdC)FVKwQS0HFjX2kPqArpBwAxj9sAPYshongQuGvLvXa22fbWzmC4z)r2jgCazUgokmwAwArjavKOrYHJd((2S0IsaQirJKd1gwty3bnpmLFnPvXaPBbWzmCExbyf9SzPDL0lPLklD40yORjTkgiDlaoJHdpMdgebYEJPuoQfp7pYoXGdiZ1WrONnlTRKEjTuzPdNgd9BYucUp47UoWZ(JnlTOeGks0i5WXbrpBwAxj9sAPYshongQuGvLvXa22fbWzmC4z)r2jgCazUgokCG7)7NDXiW9bmDBGnVRa0ZML2vsVKwQS0HtJHga1mCNBcWzmC4XCWGiq2BmLYrT4z)r2jgCazUgokCG7)7XqTGRKG7dUDsR3vqy2DqZdt5xtAvmq6waCgdNFjX2k5qnqpBwAxj9sAPYshong63KPeCFW3DDGNvjTRRGey)Xa3)3lPLklD4DfeMDh08Wu(1KwfdKUfaNXW5xQNoqpBwAxj9sAPYshongQuGvLvXa22fbWzmC4z)r2jgCazUgok8KcC)FFWv00vMGGLW4DfGE2S0Us6L0sLLoCAm0VjtW9bPobWOBjbslMw8yoyqei7nMs5Ow8S)it3eAq0ZML2vsVKwQS0HtJHga1mCNBcWzmC4XCWGiq2BmLYrT4z)r2jgCazUgo69vtYgIQ0RBjGDIbh6zZs7kPxslvw6WPXqLcSQSkgW2UiaoJHd9e9SzPDL0lZrm62czvmyUD8vabUfthp7pUTnbuuQsFpNsVvdz3bnpmLhJUTqwfdMBhFfqGBX09t3Tt7Qq4d(h99DBBcOOuL(EoLExbONnlTRKEz60yOurBSfcAvmGGSi2IN9hz6MxSJGpMUnCuJWurBSdFAIeipGyhz4GVVmDZl2rWht3goI)HXcv0g7WNMibYdi2rgQX7RMiyPOGy20R1NwmTabnKiwrpBwAxj9Y0PXqLcSQSkgW2UiaoJHdp7pYoXGdiZ1WrHdC)F)SlgbUpGPBdS5DfeglBBtafLQ03ZP0B1Wa3)3p7IrG7dy62aB(LeBRK4tJ33TTjGIsv675u6DfGv0ZML2vsVmDAm01KwfdKUfaNXWHhZbdIazVXukh1IN9hz3bnpmLxslvw6WVKyBLCO23xnjBiQsVKwQS0b6zZs7kPxMong63KPeCFW3DDGN9hXY22eqrPk99Ck9wnKDh08Wu(Vjtj4(GV76WpD3oTRcHp4F033TTjGIsv675u6DfG1WyHkAJD4ttKa5be7idPieZnjqAIe(0((Y0nVyhbFmDtOrTVVbU)VxM3kcOEtDqxtW3wYVKyBLuikcXCtcKMi5KwS(((Ty9eSKyBLuikcXCtcKMi5Kw0ZML2vsVmDAmu22mCqwfdg4EsailwplRIXZ(JbU)Vp1jajkG2BLawlOzwERxMnd3qTduyQOn2HpnrcKhqSJmKIqm3KaPjs4tBy2DqZdt5xtAvmq6waCgdNFjX2k5qkcXCtcKMi9(g4()(uNaKOaAVvcyTGMz5TEz2mCd1I)HXc7oO5HP8sAPYsh(LeBRKcfYWzdrv6L0sLLoEFz3bnpmLhd1cUscUp42jT(LeBRKcfYWSlkvDLECowRR33VfRNGLeBRKcfsSIE2S0Us6LPtJHUUsDRIbdCpjagRM4z)Xa3)3VUsDRIbdCpjagRM(5HPc3S0IsaQirJKd1IE2S0Us6LPtJH(nzcUpi1jagDljqAX0IhZbdIazVXukh1IN9hz6MqdIE2S0Us6LPtJHsreqqa9EfXZ(JmDZl2rWht3goQf9SzPDL0ltNgdLPBGa3vM4z)rMU5f7i4JPBdh1gUzPfLaurIgjh1gEBBcOOuL(EoLERgQXdVVmDZl2rWht3goQr4MLwucqfjAKC4OgONnlTRKEz60yOmDdGPJsONnlTRKEz60yOPftlqqdjIhZbdIazVXukh1IN9hzNyWbK5A4OWmDZl2rWht3goQr4a3)3lZBfbuVPoORj4Bl5NhMc9SzPDL0ltNgdvkWQYQyaB7Ia4mgo8S)yG7)7z6gGkAJD4LzZWnCWhWxidHnlTOeGks0iz4a3)3lZBfbuVPoORj4Bl5NhMkmwy3bnpmLFnPvXaPBbWzmC(LeBRKd1im7oO5HP8FtMsW9bF31HFjX2k5qnEFz3bnpmLFnPvXaPBbWzmC(LeBRKcnyy2DqZdt5)MmLG7d(URd)sITvYHdgMPBdh89LDh08Wu(1KwfdKUfaNXW5xsSTsoCWWS7GMhMY)nzkb3h8Dxh(LeBRKcnyyMUne)FFz6MxSJGpMUj0O2WurBSdFAIeipGyhrinW67BG7)7z6gGkAJD4LzZWnu7dH)wSEcwsSTsk0aa9SzPDL0ltNgdnaQz4o3eGZy4WJ5GbrGS3ykLJAXZ(JStm4aYCnCuySKnevPxslvw6im7oO5HP8sAPYsh(LeBRKcn47l7oO5HP8RjTkgiDlaoJHZVKyBLCO2WS7GMhMY)nzkb3h8Dxh(LeBRKd1((YUdAEyk)AsRIbs3cGZy48lj2wjfAWWS7GMhMY)nzkb3h8Dxh(LeBRKdhmmt3gQX7l7oO5HP8RjTkgiDlaoJHZVKyBLC4GHz3bnpmL)BYucUp47Uo8lj2wjfAWWmDB4GVVmDByiFFdC)FFWHdiypM3vawrpBwAxj9Y0PXqtlMwGGgsepMdgebYEJPuoQfp7pYoXGdiZ1WrHz6MxSJGpMUnCud0ZML2vsVmDAm0EzDrG82LQep7pY0nVyhbFmDB4Ow0ZML2vsVmDAm0pKdRIbsAfqvcWzmC4zvs76kih1IE2S0Us6LPtJHga1mCNBcWzmC4XCWGiq2BmLYrT4z)r2jgCazUgokm7oO5HP8FtMsW9bF31HFjX2kPqdgMPBJAewWsrbXSPxRpTyAbcAiXWurBSdFAIeipqiFqiTONnlTRKEz60yObqnd35MaCgdhEmhmicK9gtPCulE2FKDIbhqMRHJctfTXo8PjsG8aIDeH0imwy6MxSJGpMUj0O23xblffeZMET(0IPfiOHeXk6j6zZs7kPhd1cUscUp42jTJr716aicVQfPXaOMH7CtaoJHduenPjENGrjL4fTHCPXa3)3JHAbxjb3hC7Kwagm(LeBRKHXc7oO5HP8RjTkgiDlaoJHZVKyBLCyG7)7XqTGRKG7dUDsladg)sITvYWbU)Vhd1cUscUp42jTamy8lj2wjfsJ3x2DqZdt5xtAvmq6waCgdNFjX2kj(cC)FpgQfCLeCFWTtAbyW4xsSTsouJWbU)Vhd1cUscUp42jTamy8lj2wjfc)Xk6zZs7kPhd1cUscUp42jTongkRHGanlTRaqMmXRArAKnbs6JN9h1KSHOk9sAPYshONnlTRKEmul4kj4(GBN060yOSgcc0S0UcazYeVQfPr2eiPLklDGN9hZgIQ0lPLklDGE2S0Us6XqTGRKG7dUDsRtJHsfTXwiOvXacYIylE2FKPBEXoc(y62WrnctfTXo8PjsG8aIDKHdIE2S0Us6XqTGRKG7dUDsRtJHUM0QyG0Ta4mgo8yoyqei7nMs5Ow0ZML2vspgQfCLeCFWTtADAm0Vjtj4(GV76ap7p2S0IsaQirJKdh1iCG7)7XqTGRKG7dUDsladg)sITvsH0IE2S0Us6XqTGRKG7dUDsRtJHIr3wiRIbZTJVciWTy64z)XMLwucqfjAKC4OgONnlTRKEmul4kj4(GBN060yOsbwvwfdyBxeaNXWHN9hzNyWbK5A4OWnlTOeGks0i5WXbdh4()Emul4kj4(GBN0cWGX7ka9SzPDL0JHAbxjb3hC7KwNgdnaQz4o3eGZy4Wl7nMsG9hfTAaNuG7)7f7fh4(GuNaSTlYVKyBLep7pYoXGdiZ1WrHBwArjavKOrsHg1iC0EToaI8bqnd35MaCgdhOiAst0ZML2vspgQfCLeCFWTtADAmuPaRkRIbSTlcGZy4WZ(JStm4aYCnCu4a3)3p7IrG7dy62aBExbONnlTRKEmul4kj4(GBN060yOy0TfYQyWC74RacClMo6zZs7kPhd1cUscUp42jTong63KPeCFW3DDGNvjTRRGey)Xa3)3JHAbxjb3hC7KwagmExb4z)Xa3)3lZBfbuVPoORj4Bl5DfeEBBcOOuL(EoLERgYUdAEyk)3KPeCFW3DD4NUBN2vHWh8pg6zZs7kPhd1cUscUp42jTongQuGvLvXa22fbWzmC4z)Xa3)3Z0nav0g7WlZMHB4GpGVqgcBwArjavKOrs0ZML2vspgQfCLeCFWTtADAm0VjtW9bPobWOBjbslMw8yoyqei7nMs5Ow8S)it3eAq0ZML2vspgQfCLeCFWTtADAmukIaccO3RiE2FKPBEXoc(y62WrTONnlTRKEmul4kj4(GBN060yOmDde4UYep7pY0nVyhbFmDB4iw06uZslkbOIensoulwrpBwAxj9yOwWvsW9b3oP1PXqtlMwGGgsepMdgebYEJPuoQfp7pIfnjBiQsVULa2jgCVVStm4aYCnCewdZ0nVyhbFmDB4OgONnlTRKEmul4kj4(GBN060yObqnd35MaCgdhEzVXucS)OOvd4KcC)FVyV4a3hK6eGTDr(LeBRK4z)XMLwucqfjAKuOXbdZ0THJd((g4()Emul4kj4(GBN0cWGX7ka9SzPDL0JHAbxjb3hC7KwNgdLPBamDuc9SzPDL0JHAbxjb3hC7KwNgd9d5WQyGKwbuLaCgdhEwL0UUcYrT8KNCoa]] )

end