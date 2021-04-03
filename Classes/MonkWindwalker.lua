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


    spec:RegisterPack( "Windwalker", 20210403, [[dSuFdcqisr8ifaTjb1Nif1OGsCkOKwLGGEfvKzbv1TGQyxu1VeKgMQGJrkTmsHNPannvH6AcI2MQq6BkamoOkPZPa06uazEeK7Pq7tbDqvHOfsf1dHQunrOkf5IccyJQcH8rvHGtsks1kvf9svHqntOkXnHQuu7ek1pHQuyPKIuEkOMkb1xHQuASccTxu9xGbtYHLAXc8yuMSIUmYMvvFwOgnP60uwTcOEnuz2GCBcTBj)wLHtGJtkswUspNOPl66uPTlK(oumEH48uH1liqZxvA)qMRLlmhE2jXXwJh0q7dp(Hb9A1(yTp(r5WPdbehwqZW1XehUArIdJ3A1etdHJwoSG2b01tUWCy55UmIdZHdCnOutV4bC4zNehBnEqdTp84hg0Rv7J1(4b5WsbeJJTgp6aYH1T5KkEahEssghgV1QjMgchTifEZxHd98rkyniKsd8rknEqdTONONcJHACi1JitMsK6(i1Ji31bszvs76kirkOl2yE0tHXqnoKcwGvLvXifEF7IqQhXgdhsbDXgZJE(iNtKk4KYVfRNiftNy4KivEiLyxoqk8oEtifv5AK0ZHHmzk5cZHpburlxyo2A5cZHPQdGOj3zoCZs7ko83Kj4(GuNay0TKaPftlhMTwsR1CyMU5f7iifEqkMUHudhrQb5WmhmicK9UXuk5WA5jhBn4cZHPQdGOj3zomBTKwR5Wzdrv6z6giWDLPNQoaIMivyKIPBEXocsHhKIPBi1WrKAqoCZs7komfrabb07vKNCShKlmhMQoaIMCN5WnlTR4WPftlqqdjYHzRL0AnhMDIbhqMRHJqQWift38IDeKcpift3qQHJiLgCyMdgebYEJPuYXwlp5y)yUWCyQ6aiAYDMdZwlP1Aomt38IDeKcpift3qQrKsdoCZs7komt3ay6Oep5yhsUWC4ML2vCykIaccO3RihMQoaIMCN5jh7hLlmhMQoaIMCN5WnlTR4WPftlqqdjYHzRL0AnhMPBEXocsHhKIPBi1WrKsdomZbdIazVXuk5yRLN8KdJHAbxjb3hC7KwUWCS1YfMdtvhartUZC4tahwsjhUzPDfhoAVwharC4OnKlXHdC)FpgQfCLeCFWTtAbyW4xsSTsIuHrkSGuS7GMhMYVM0QyG0Ta4mgo)sITvsKAisf4()Emul4kj4(GBN0cWGXVKyBLePcJubU)Vhd1cUscUp42jTamy8lj2wjrkHqknqQ3xKIDh08Wu(1KwfdKUfaNXW5xsSTsIu4bPcC)FpgQfCLeCFWTtAbyW4xsSTsIudrknqQWivG7)7XqTGRKG7dUDsladg)sITvsKsiK6Xifw5Wr7fuTiXHdGAgUZnb4mgoqr0KM8KJTgCH5Wu1bq0K7mhMTwsR1CynbPYgIQ0lPLklD4PQdGOjhUzPDfhM1qqGML2vaitMCyitMGQfjomBcK0NNCShKlmhMQoaIMCN5WS1sATMdNnevPxslvw6WtvhartoCZs7komRHGanlTRaqMm5WqMmbvlsCy2eiPLklDWto2pMlmhMQoaIMCN5WS1sATMdZ0nVyhbPWdsX0nKA4isPbsfgPOI2yh(0ejqEaXocsnePgKd3S0UIdtfTXwiOvXacYIylp5yhsUWCyQ6aiAYDMd3S0UIdVM0QyG0Ta4mgoomZbdIazVXuk5yRLNCSFuUWCyQ6aiAYDMdZwlP1AoCZslkbOIensIudhrknqQWivG7)7XqTGRKG7dUDsladg)sITvsKsiKslhUzPDfh(BYucUp47Uo4jh7baxyomvDaen5oZHzRL0AnhUzPfLaurIgjrQHJiLgC4ML2vCym62czvmyUD8vabUftNNCSXRCH5Wu1bq0K7mhMTwsR1Cy2jgCazUgocPcJunlTOeGks0ijsnCePgePcJubU)Vhd1cUscUp42jTamy8Uc4WnlTR4WsbwvwfdyBxeaNXWXto2dixyomvDaen5oZHBwAxXHdGAgUZnb4mgoomBTKwR5WStm4aYCnCesfgPAwArjavKOrsKsOrKsdKkmsfTxRdGiFauZWDUjaNXWbkIM0KdN9gtjW(CyEYXw7dCH5Wu1bq0K7mhMTwsR1Cy2jgCazUgocPcJubU)VF2fJa3hW0Tb28Uc4WnlTR4WsbwvwfdyBxeaNXWXto2A1YfMd3S0UIdJr3wiRIbZTJVciWTy6CyQ6aiAYDMNCS1QbxyomvDaen5oZHzRL0AnhoW9)9Y8wra1BQd6Ac(2sExbivyKABBcOOuL(EoLERqQHif7oO5HP8FtMsW9bF31HF6UDAxHuHqK6b)JYHBwAxXH)MmLG7d(URdoSvjTRRGeyFoCG7)7XqTGRKG7dUDsladgVRaEYXw7GCH5Wu1bq0K7mhMTwsR1C4a3)3Z0nav0g7WlZMHdPgIud(asHhKkKiviePAwArjavKOrsoCZs7koSuGvLvXa22fbWzmC8KJT2hZfMdtvhartUZC4ML2vC4VjtW9bPobWOBjbslMwomBTKwR5WmDdPecPgKdZCWGiq2BmLso2A5jhBTHKlmhMQoaIMCN5WS1sATMdZ0nVyhbPWdsX0nKA4isPLd3S0UIdtreqqa9Ef5jhBTpkxyomvDaen5oZHzRL0AnhMPBEXocsHhKIPBi1WrKcliLwKYjKQzPfLaurIgjrQHiLwKcRC4ML2vCyMUbcCxzYto2AhaCH5Wu1bq0K7mhUzPDfhoTyAbcAiromBTKwR5WybP0eKkBiQsVULa2jgCEQ6aiAIuVVif7edoGmxdhHuyfPcJumDZl2rqk8GumDdPgoIuAWHzoyqei7nMsjhBT8KJTw8kxyomvDaen5oZHBwAxXHdGAgUZnb4mgoomBTKwR5WnlTOeGks0ijsj0isnisfgPy6gsnCePgePEFrQa3)3JHAbxjb3hC7KwagmExbC4S3ykb2NdZto2AhqUWC4ML2vCyMUbW0rjomvDaen5oZto2A8axyoSvjTRRGKdRLd3S0UId)HCyvmqsRaQsaoJHJdtvhartUZ8KNCyjTuzPdUWCS1YfMdtvhartUZCy2AjTwZHdC)FVKwQS0HFjX2kjsjesPLd3S0UId)nzkb3h8Dxh8KJTgCH5Wu1bq0K7mhMTwsR1Cy2jgCazUgocPcJuybPAwArjavKOrsKA4isnis9(IunlTOeGks0ijsneP0IuHrknbPy3bnpmLFnPvXaPBbWzmCExbifw5WnlTR4WsbwvwfdyBxeaNXWXto2dYfMdtvhartUZC4ML2vC41KwfdKUfaNXWXHzRL0AnhMDIbhqMRHJ4WmhmicK9gtPKJTwEYX(XCH5Wu1bq0K7mhMTwsR1C4MLwucqfjAKePgoIudYHBwAxXH)MmLG7d(URdEYXoKCH5Wu1bq0K7mhMTwsR1Cy2jgCazUgocPcJubU)VF2fJa3hW0Tb28Uc4WnlTR4WsbwvwfdyBxeaNXWXto2pkxyomvDaen5oZHBwAxXHdGAgUZnb4mgoomBTKwR5WStm4aYCnCesfgPcC)FpgQfCLeCFWTtA9UcqQWif7oO5HP8RjTkgiDlaoJHZVKyBLePgIuAWHzoyqei7nMsjhBT8KJ9aGlmh2QK21vqcSphoW9)9sAPYshExbHz3bnpmLFnPvXaPBbWzmC(L6PdoCZs7ko83KPeCFW3DDWHPQdGOj3zEYXgVYfMdtvhartUZCy2AjTwZHzNyWbK5A4iKkmsnPa3)3hCfnDLjiyjmExbC4ML2vCyPaRkRIbSTlcGZy44jh7bKlmhMQoaIMCN5WnlTR4WFtMG7dsDcGr3scKwmTCy2AjTwZHz6gsjesnihM5GbrGS3ykLCS1Yto2AFGlmhMQoaIMCN5WnlTR4Wbqnd35MaCgdhhMTwsR1Cy2jgCazUgocPEFrknbPYgIQ0RBjGDIbNNQoaIMCyMdgebYEJPuYXwlp5yRvlxyoCZs7koSuGvLvXa22fbWzmCCyQ6aiAYDMN8KdZMajTuzPdUWCS1YfMdtvhartUZC4tahwsjhUzPDfhoAVwharC4OnKlXHz3bnpmLxslvw6WVKyBLePecP0IuVViLak9rCPcK6eaJULeiTyA9nlTOesfgPy3bnpmLxslvw6WVKyBLePgIud(as9(IubNuIuHrQVfRNGLeBRKiLqiLgpWHJ2lOArIdlPLklDacCxzYto2AWfMdtvhartUZCy2AjTwZH1eKkAVwharE9dAcI4sfs9(IubNuIuHrQVfRNGLeBRKiLqiLgHKd3S0UIdBv0dhbI4sfp5ypixyomvDaen5oZHzRL0AnhoAVwharEjTuzPdqG7ktoCZs7koCa0DtW3DDWto2pMlmhMQoaIMCN5WS1sATMdhTxRdGiVKwQS0biWDLjhUzPDfhoGwjT4SkMNCSdjxyoCZs7komKfRNsWa7oJfPk5Wu1bq0K7mp5y)OCH5Wu1bq0K7mhMTwsR1C4O9ADae5L0sLLoabURm5WnlTR4WFBPaO7M8KJ9aGlmhMQoaIMCN5WS1sATMdhTxRdGiVKwQS0biWDLjhUzPDfhUlgjZTHaSgcINCSXRCH5Wu1bq0K7mhMTwsR1C4O9ADae5L0sLLoabURm5WnlTR4WbDm4(GCngojp5ypGCH5Wu1bq0K7mhMTwsR1C4VfRNGLeBRKi1qKcliLw86difEqQ1TO)TXK)3zdbYZLP7PQdGOjsfcrkTA8asHvK69fPeqPpIlvGuNay0TKaPftRVzPfLqQ3xKk4KsKkms9Ty9eSKyBLePecP0(ahUzPDfhopxMo4(Gj1Pop5yR9bUWCyQ6aiAYDMdZwlP1Ao83I1tWsITvsKAisnGpGuVViLak9rCPcK6eaJULeiTyA9nlTOes9(IubNuIuHrQVfRNGLeBRKiLqiL2h4WnlTR4W55Y0b3hGRxXMNCS1QLlmhMQoaIMCN5WS1sATMdZUdAEyk)AsRIbs3cGZy48lj2wjrkHqkkcXCtcKMiXHBwAxXHXqTGRKG7dUDslp5yRvdUWCyQ6aiAYDMdZwlP1AoC0EToaI8sAPYshGa3vMC4ML2vCyRKS1n7aicOPC7kDfbtkQXiEYXw7GCH5Wu1bq0K7mhMTwsR1C4O9ADae5L0sLLoabURm5WnlTR4Wy2o1L5vep5yR9XCH5Wu1bq0K7mhMTwsR1C4O9ADae5L0sLLoabURm5WnlTR4WXq9068wjiONXep5yRnKCH5Wu1bq0K7mhMTwsR1CynbPI2R1bqKpIlvGRaUscKRv4OePEFrk2DqZdt5Tk6HJarCPcK6eaJULeiTyA9lj2wjrQHiLgpGuVViv0EToaI86h0eeXLkoCZs7koSRKawsIsEYXw7JYfMd3S0UId)BcYkciZtuahMQoaIMCN5jhBTdaUWC4ML2vC4Fdbrf42jTCyQ6aiAYDMNCS1Ix5cZHBwAxXHdUIMUYeeSegomvDaen5oZto2AhqUWCyQ6aiAYDMdZwlP1Aom7oO5HP8RjTkgiDlaoJHZVKyBLePecP0aPEFrQGtkrQWi13I1tWsITvsKsiKsBi5WnlTR4WsAPYsh8KJTgpWfMd3S0UIdh0XG7dY1y4KCyQ6aiAYDMN8KdltUWCS1YfMdtvhartUZCy2AjTwZH32MakkvPVNtP3kKAisXUdAEykpgDBHSkgm3o(kGa3IP7NUBN2viviePEWJxrQ3xKABBcOOuL(EoLExbC4ML2vCym62czvmyUD8vabUftNNCS1GlmhMQoaIMCN5WS1sATMdZ0nVyhbPWdsX0nKA4isPbsfgPOI2yh(0ejqEaXocsnePgePEFrkMU5f7iifEqkMUHudhrQhJuHrkSGuurBSdFAIeipGyhbPgIuAGuVViLMGucwkkiMn9A9PftlqqdjIuyLd3S0UIdtfTXwiOvXacYIylp5ypixyomvDaen5oZHzRL0AnhMDIbhqMRHJqQWivG7)7NDXiW9bmDBGnVRaKkmsHfKABBcOOuL(EoLERqQHivG7)7NDXiW9bmDBGn)sITvsKcpiLgi17lsTTnbuuQsFpNsVRaKcRC4ML2vCyPaRkRIbSTlcGZy44jh7hZfMdtvhartUZC4ML2vC41KwfdKUfaNXWXHzRL0AnhMDh08WuEjTuzPd)sITvsKAisPfPEFrknbPYgIQ0lPLklD4PQdGOjhM5GbrGS3ykLCS1Yto2HKlmhMQoaIMCN5WS1sATMdJfKABBcOOuL(EoLERqQHif7oO5HP8FtMsW9bF31HF6UDAxHuHqK6bpEfPEFrQTTjGIsv675u6DfGuyfPcJuybPOI2yh(0ejqEaXocsnePOieZnjqAIesHhKsls9(IumDZl2rqk8GumDdPeAeP0IuVVivG7)7L5TIaQ3uh01e8TL8lj2wjrkHqkkcXCtcKMiHuoHuArkSIuVVi13I1tWsITvsKsiKIIqm3KaPjsiLtiLwoCZs7ko83KPeCFW3DDWto2pkxyomvDaen5oZHzRL0AnhoW9)9Pobirb0EReWAbnZYB9YSz4qQHiL2bePcJuurBSdFAIeipGyhbPgIuueI5MeinrcPWdsPfPcJuS7GMhMYVM0QyG0Ta4mgo)sITvsKAisrriMBsG0ejK69fPcC)FFQtasuaT3kbSwqZS8wVmBgoKAisP9XivyKclif7oO5HP8sAPYsh(LeBRKiLqivirQWiv2quLEjTuzPdpvDaenrQ3xKIDh08WuEmul4kj4(GBN06xsSTsIucHuHePcJuSlkvDLECowRlK69fP(wSEcwsSTsIucHuHePWkhUzPDfhMTndhKvXGbUNeaYI1ZYQyEYXEaWfMdtvhartUZCy2AjTwZHdC)F)6k1TkgmW9KaySA6NhMcPcJunlTOeGks0ijsneP0YHBwAxXHxxPUvXGbUNeaJvtEYXgVYfMdtvhartUZC4ML2vC4VjtW9bPobWOBjbslMwomBTKwR5WmDdPecPgKdZCWGiq2BmLso2A5jh7bKlmhMQoaIMCN5WS1sATMdZ0nVyhbPWdsX0nKA4isPLd3S0UIdtreqqa9Ef5jhBTpWfMdtvhartUZCy2AjTwZHz6MxSJGu4bPy6gsnCeP0IuHrQMLwucqfjAKePgrkTivyKABBcOOuL(EoLERqQHiLgpGuVVift38IDeKcpift3qQHJiLgivyKQzPfLaurIgjrQHJiLgC4ML2vCyMUbcCxzYto2A1YfMd3S0UIdZ0naMokXHPQdGOj3zEYXwRgCH5Wu1bq0K7mhUzPDfhoTyAbcAiromBTKwR5WStm4aYCnCesfgPy6MxSJGu4bPy6gsnCeP0aPcJubU)VxM3kcOEtDqxtW3wYppmfhM5GbrGS3ykLCS1Yto2AhKlmhMQoaIMCN5WS1sATMdh4()EMUbOI2yhEz2mCi1qKAWhqk8GuHePcHivZslkbOIensIuHrQa3)3lZBfbuVPoORj4Bl5NhMcPcJuybPy3bnpmLFnPvXaPBbWzmC(LeBRKi1qKsdKkmsXUdAEyk)3KPeCFW3DD4xsSTsIudrknqQ3xKIDh08Wu(1KwfdKUfaNXW5xsSTsIucHudIuHrk2DqZdt5)MmLG7d(URd)sITvsKAisnisfgPy6gsnePgePEFrk2DqZdt5xtAvmq6waCgdNFjX2kjsnePgePcJuS7GMhMY)nzkb3h8Dxh(LeBRKiLqi1GivyKIPBi1qK6Xi17lsX0nVyhbPWdsX0nKsOrKslsfgPOI2yh(0ejqEaXocsjesPbsHvK69fPcC)Fpt3aurBSdVmBgoKAisP9bKkms9Ty9eSKyBLePecPgaC4ML2vCyPaRkRIbSTlcGZy44jhBTpMlmhMQoaIMCN5WnlTR4Wbqnd35MaCgdhhMTwsR1Cy2jgCazUgocPcJuybPYgIQ0lPLklD4PQdGOjsfgPy3bnpmLxslvw6WVKyBLePecPgePEFrk2DqZdt5xtAvmq6waCgdNFjX2kjsneP0IuHrk2DqZdt5)MmLG7d(URd)sITvsKAisPfPEFrk2DqZdt5xtAvmq6waCgdNFjX2kjsjesnisfgPy3bnpmL)BYucUp47Uo8lj2wjrQHi1GivyKIPBi1qKsdK69fPy3bnpmLFnPvXaPBbWzmC(LeBRKi1qKAqKkmsXUdAEyk)3KPeCFW3DD4xsSTsIucHudIuHrkMUHudrQbrQ3xKIPBi1qKkKi17lsf4()(GdhqWEmVRaKcRCyMdgebYEJPuYXwlp5yRnKCH5Wu1bq0K7mhUzPDfhoTyAbcAiromBTKwR5WStm4aYCnCesfgPy6MxSJGu4bPy6gsnCeP0GdZCWGiq2BmLso2A5jhBTpkxyomvDaen5oZHzRL0AnhMPBEXocsHhKIPBi1WrKslhUzPDfhUxwxeiVDPk5jhBTdaUWCyRsAxxbjhwlhUzPDfh(d5WQyGKwbuLaCgdhhMQoaIMCN5jhBT4vUWCyQ6aiAYDMd3S0UIdha1mCNBcWzmCCy2AjTwZHzNyWbK5A4iKkmsXUdAEyk)3KPeCFW3DD4xsSTsIucHudIuHrkMUHuJiLgivyKsWsrbXSPxRpTyAbcAirKkmsrfTXo8PjsG8aH8bKsiKslhM5GbrGS3ykLCS1Yto2AhqUWCyQ6aiAYDMd3S0UIdha1mCNBcWzmCCy2AjTwZHzNyWbK5A4iKkmsrfTXo8PjsG8aIDeKsiKsdKkmsHfKIPBEXocsHhKIPBiLqJiLwK69fPeSuuqmB616tlMwGGgsePWkhM5GbrGS3ykLCS1YtEYHztGK(CH5yRLlmhMQoaIMCN5WS1sATMdRjiv0EToaI86h0eeXLkK69fPcoPePcJuFlwpblj2wjrkHqkncjhUzPDfh2QOhoceXLkEYXwdUWCyQ6aiAYDMdZwlP1Ao83I1tWsITvsKAisHfKslE9bKcpi16w0)2yY)7SHa55Y09u1bq0ePcHiLwnEaPWks9(IubU)VxM3kcOEtDqxtW3wYppmfsfgPeqPpIlvGuNay0TKaPftRVzPfLqQ3xKk4KsKkms9Ty9eSKyBLePecP0(ahUzPDfhopxMo4(Gj1Pop5ypixyomvDaen5oZHzRL0Anhgli122eqrPk99Ck9wHudrQhhsK69fP22MakkvPVNtP3vasHvKkmsXUdAEyk)AsRIbs3cGZy48lj2wjrkHqkkcXCtcKMiXHBwAxXHXqTGRKG7dUDslp5y)yUWCyQ6aiAYDMdZwlP1Aom7edoGmxdhHuHrkSGuBBtafLQ03ZP0BfsneP0(as9(IuBBtafLQ03ZP07kaPWkhUzPDfh(3eKveqMNOaEYXoKCH5Wu1bq0K7mhMTwsR1C4TTjGIsv675u6TcPgIud(as9(IuBBtafLQ03ZP07kGd3S0UId)BiiQa3oPLNCSFuUWCyQ6aiAYDMdZwlP1Ao822eqrPk99Ck9wHudrQq(as9(IuBBtafLQ03ZP07kGd3S0UIdhCfnDLjiyjmCyiRiaBYHF0h4jh7baxyomvDaen5oZHzRL0AnhMD101sp7UDAvN0eC)pvslk5PQdGOjhUzPDfhwM3kcOEtDqxtW3wc8TiDs8KJnELlmhMQoaIMCN5WS1sATMdZUdAEykVmVveq9M6GUMGVTKNP3BmjrQrKsdK69fPcoPePcJuFlwpblj2wjrkHqknEaPEFrkSGuBBtafLQ03ZP0VKyBLePgIuAdjs9(IuAcsXUOu1v6X5yTUqQWifwqkSGuBBtafLQ03ZP0BfsnePy3bnpmLxM3kcOEtDqxtW3wY)DHGalX07nMaPjsi17lsPji122eqrPk99Ck9uetMsKcRivyKclif7oO5HP8wf9WrGiUubsDcGr3scKwmT(LeBRKi1qKIDh08WuEzERiG6n1bDnbFBj)3fccSetV3ycKMiHuVViv0EToaI86h0eeXLkKcRifwrQWif7oO5HP8FtMsW9bF31HFjX2kjsj0isnGivyKIPBi1WrKsdKkmsXUdAEykpgDBHSkgm3o(kGa3IP7xsSTsIucnIuA1aPWkhUzPDfhwM3kcOEtDqxtW3wINCShqUWCyQ6aiAYDMdZwlP1Aom7IsvxPhNJ16cPcJuybPcC)FpgQfCLeCFWTtA9UcqQ3xKclivWjLivyK6BX6jyjX2kjsjesXUdAEykpgQfCLeCFWTtA9lj2wjrQ3xKIDh08WuEmul4kj4(GBN06xsSTsIudrk2DqZdt5L5TIaQ3uh01e8TL8FxiiWsm9EJjqAIesHvKkmsXUdAEyk)3KPeCFW3DD4xsSTsIucnIudisfgPy6gsnCeP0aPcJuS7GMhMYJr3wiRIbZTJVciWTy6(LeBRKiLqJiLwnqkSYHBwAxXHL5TIaQ3uh01e8TL4jhBTpWfMdtvhartUZCy2AjTwZHfqPpIlvGuNay0TKaPftRVzPfLqQ3xKk4KsKkms9Ty9eSKyBLePecP04boCZs7koSvs26MDaeb0uUDLUIGjf1yep5yRvlxyomvDaen5oZHzRL0AnhwaL(iUubsDcGr3scKwmT(MLwucPEFrQGtkrQWi13I1tWsITvsKsiKsJh4WnlTR4Wy2o1L5vep5yRvdUWCyQ6aiAYDMdZwlP1AoSak9rCPcK6eaJULeiTyA9nlTOes9(IubNuIuHrQVfRNGLeBRKiLqiLgpWHBwAxXHJH6P15TsqqpJjEYXw7GCH5Wu1bq0K7mhMTwsR1CynbPI2R1bqKpIlvGRaUscKRv4OePEFrk2DqZdt5Tk6HJarCPcK6eaJULeiTyA9lj2wjrQHiLgpGuVViv0EToaI86h0eeXLkoCZs7koSRKawsIsEYXw7J5cZHPQdGOj3zomBTKwR5WFlwpblj2wjrQHiL2qoGi17lsjGsFexQaPobWOBjbslMwFZslkHuVViv0EToaI86h0eeXLkoCZs7koCEUmDW9b46vS5jhBTHKlmhMQoaIMCN5WS1sATMdZUdAEykVvrpCeiIlvGuNay0TKaPftRFjX2kjsnePg8bK69fPI2R1bqKx)GMGiUuHuVVivWjLivyK6BX6jyjX2kjsjesPXdC4ML2vC4aO7MGV76GNCS1(OCH5Wu1bq0K7mhMTwsR1Cy2DqZdt5Tk6HJarCPcK6eaJULeiTyA9lj2wjrQHi1GpGuVViv0EToaI86h0eeXLkK69fPcoPePcJuFlwpblj2wjrkHqkTHKd3S0UIdhqRKwCwfZto2AhaCH5WnlTR4WqwSEkbdS7mwKQKdtvhartUZ8KJTw8kxyomvDaen5oZHzRL0AnhMDh08WuERIE4iqexQaPobWOBjbslMw)sITvsKAisn4di17lsfTxRdGiV(bnbrCPcPEFrQGtkrQWi13I1tWsITvsKsiKs7dC4ML2vC4VTua0DtEYXw7aYfMdtvhartUZCy2AjTwZHz3bnpmL3QOhoceXLkqQtam6wsG0IP1VKyBLePgIud(as9(Iur716aiYRFqtqexQqQ3xKk4KsKkms9Ty9eSKyBLePecP04boCZs7koCxmsMBdbyneep5yRXdCH5Wu1bq0K7mhMTwsR1C4a3)3lZBfbuVPoORj4Bl5NhMId3S0UIdh0XG7dY1y4K8KNC4j9BxOKlmhBTCH5WnlTR4WsbuVa9UMazUgoIdtvhartUZ8KJTgCH5Wu1bq0K7mh(eWHLuYHBwAxXHJ2R1bqehoAd5sCy2DqZdt5Tk6HJarCPcK6eaJULeiTyA9lj2wjrQHi13I1tWsITvsK69fP(wSEcwsSTsIucHuA14bKkms9Ty9eSKyBLePgIuS7GMhMYlPLklD4xsSTsIuHrk2DqZdt5L0sLLo8lj2wjrQHiL2h4Wr7fuTiXH1pOjiIlv8KJ9GCH5Wu1bq0K7mhMTwsR1CySGubU)Vxslvw6W7kaPEFrQa3)3lZBfbuVPoORj4Bl5DfGuyfPcJucO0hXLkqQtam6wsG0IP13S0Isi17lsfCsjsfgP(wSEcwsSTsIucnIup6dC4ML2vCybxAxXto2pMlmhMQoaIMCN5WS1sATMdh4()EjTuzPdVRaoCZs7komRHGanlTRaqMm5WqMmbvlsCyjTuzPdEYXoKCH5Wu1bq0K7mhMTwsR1C4a3)3JHAbxjb3hC7KwVRaoCZs7komRHGanlTRaqMm5WqMmbvlsCymul4kj4(GBN0Yto2pkxyomvDaen5oZHzRL0AnhonrcPecPEmsfgPy6gsjesfsKkmsPjiLak9rCPcK6eaJULeiTyA9nlTOehUzPDfhM1qqGML2vaitMCyitMGQfjo8jGkA5jh7baxyomvDaen5oZHBwAxXH)Mmb3hK6eaJULeiTyA5WS1sATMdZ0nVyhbPWdsX0nKA4isnisfgPWcsrfTXo8PjsG8aIDeKsiKsls9(IuurBSdFAIeipGyhbPecPEmsfgPy3bnpmL)BYucUp47Uo8lj2wjrkHqkT(qIuVVif7oO5HP8yOwWvsW9b3oP1VKyBLePecP0aPWkhM5GbrGS3ykLCS1Yto24vUWCyQ6aiAYDMdZwlP1Aomt38IDeKcpift3qQHJiLwKkmsHfKIkAJD4ttKa5be7iiLqiLwK69fPy3bnpmLxslvw6WVKyBLePecP0aPEFrkQOn2HpnrcKhqSJGucHupgPcJuS7GMhMY)nzkb3h8Dxh(LeBRKiLqiLwFirQ3xKIDh08WuEmul4kj4(GBN06xsSTsIucHuAGuyLd3S0UIdtreqqa9Ef5jh7bKlmhMQoaIMCN5WnlTR4WPftlqqdjYHzRL0AnhMDIbhqMRHJqQWift38IDeKcpift3qQHJiLgivyKclifv0g7WNMibYdi2rqkHqkTi17lsXUdAEykVKwQS0HFjX2kjsjesPbs9(IuurBSdFAIeipGyhbPecPEmsfgPy3bnpmL)BYucUp47Uo8lj2wjrkHqkT(qIuVVif7oO5HP8yOwWvsW9b3oP1VKyBLePecP0aPWkhM5GbrGS3ykLCS1Yto2AFGlmhMQoaIMCN5WS1sATMdRjiv2quLEjTuzPdpvDaen5WnlTR4WSgcc0S0UcazYKddzYeuTiXHztGK(8KJTwTCH5Wu1bq0K7mhMTwsR1C4SHOk9sAPYshEQ6aiAYHBwAxXHzneeOzPDfaYKjhgYKjOArIdZMajTuzPdEYXwRgCH5Wu1bq0K7mhMTwsR1C4MLwucqfjAKePecPgKd3S0UIdZAiiqZs7kaKjtomKjtq1IehwM8KJT2b5cZHPQdGOj3zomBTKwR5WnlTOeGks0ijsnCePgKd3S0UIdZAiiqZs7kaKjtomKjtq1IehUpIN8Kdlyj2jg0jxyo2A5cZHBwAxXHdUmHOj4d1oOjgRIb5fXkomvDaen5oZto2AWfMdtvhartUZC4tahwsjhUzPDfhoAVwharC4OnKlXHjnLRjqan9wjzRB2bqeqt52v6kcMuuJri17lsrAkxtGaA6JH6P15TsqqpJjK69fPinLRjqan9y2o1L5vehoAVGQfjoCexQaxbCLeixRWrjp5ypixyomvDaen5oZHzRL0AnhwtqQSHOk9sAPYshEQ6aiAIuVViLMGuzdrv6)Mmb3hK6eaJULeiTyA9u1bq0Kd3S0UIdZ0nqG7ktEYX(XCH5Wu1bq0K7mhMTwsR1CynbPYgIQ0tfTXwiOvXacYIqRNQoaIMC4ML2vCyMUbW0rjEYtoCFexyo2A5cZHBwAxXHXOBlKvXG52Xxbe4wmDomvDaen5oZto2AWfMdtvhartUZCy2AjTwZHz6MxSJGu4bPy6gsnCeP0aPcJuurBSdFAIeipGyhbPgIuAGuVVift38IDeKcpift3qQHJi1J5WnlTR4WurBSfcAvmGGSi2Yto2dYfMdtvhartUZCy2AjTwZHzNyWbK5A4iKkmsHfKkW9)9ZUye4(aMUnWM3vas9(IutkW9)9bxrtxzccwcJ3vasHvoCZs7koSuGvLvXa22fbWzmC8KJ9J5cZHPQdGOj3zomBTKwR5WurBSdFAIeipGyhbPgIuueI5MeinrcPEFrkMU5f7iifEqkMUHucnIuA5WnlTR4WFtMsW9bF31bp5yhsUWCyQ6aiAYDMd3S0UIdVM0QyG0Ta4mgoomBTKwR5WybPYgIQ0Jr3wiRIbZTJVciWTy6EQ6aiAIuHrk2DqZdt5xtAvmq6waCgdNF6UDAxHudrk2DqZdt5XOBlKvXG52Xxbe4wmD)sITvsKYjK6XifwrQWifwqk2DqZdt5)MmLG7d(URd)sITvsKAisnis9(IumDdPgoIuHePWkhM5GbrGS3ykLCS1Yto2pkxyomvDaen5oZHzRL0AnhoW9)9RRu3QyWa3tcGXQPFEykoCZs7ko86k1TkgmW9KaySAYto2daUWCyQ6aiAYDMdZwlP1Aomt38IDeKcpift3qQHJiLwoCZs7komfrabb07vKNCSXRCH5Wu1bq0K7mhUzPDfh(BYeCFqQtam6wsG0IPLdZwlP1Aomt38IDeKcpift3qQHJi1GCyMdgebYEJPuYXwlp5ypGCH5Wu1bq0K7mhMTwsR1CyMU5f7iifEqkMUHudhrkn4WnlTR4WmDde4UYKNCS1(axyomvDaen5oZHzRL0AnhoW9)9Pobirb0EReWAbnZYB9YSz4qQHiL2bePcJuurBSdFAIeipGyhbPgIuueI5MeinrcPWdsPfPcJuS7GMhMY)nzkb3h8Dxh(LeBRKi1qKIIqm3KaPjsC4ML2vCy22mCqwfdg4EsailwplRI5jhBTA5cZHPQdGOj3zoCZs7koCAX0ce0qICy2AjTwZHz6MxSJGu4bPy6gsnCeP0aPcJuybP0eKkBiQsVULa2jgCEQ6aiAIuVVif7edoGmxdhHuyLdZCWGiq2BmLso2A5jhBTAWfMdtvhartUZCy2AjTwZHz6MxSJGu4bPy6gsnCeP0YHBwAxXH7L1fbYBxQsEYXw7GCH5Wu1bq0K7mhMTwsR1Cy2jgCazUgocPcJuybPy3bnpmLp4kA6ktqWsy8lj2wjrQHiLgi17lsPjif7IsvxPVi2Eq3orkSIuHrkSGumDdPgoIuHePEFrk2DqZdt5)MmLG7d(URd)sITvsKAis9Oi17lsXUdAEyk)3KPeCFW3DD4xsSTsIudrQbrQWift3qQHJi1GivyKIkAJD4ttKa5bc5diLqiLwK69fPOI2yh(0ejqEaXocsj0isHfKAqKYjKAqKkeIuS7GMhMY)nzkb3h8Dxh(LeBRKiLqivirkSIuVVivG7)7L5TIaQ3uh01e8TL8UcqkSYHBwAxXHLcSQSkgW2UiaoJHJNCS1(yUWCyQ6aiAYDMdZwlP1Aom7edoGmxdhXHBwAxXHz6gathL4jhBTHKlmhMQoaIMCN5WnlTR4WFihwfdK0kGQeGZy44WS1sATMdh4()(GdhqWEm)8WuCyRsAxxbjhwlp5yR9r5cZHPQdGOj3zoCZs7koCauZWDUjaNXWXHzRL0AnhMDIbhqMRHJqQWifwqQa3)3hC4ac2J5DfGuVViv2quLEDlbStm48u1bq0ePcJucwkkiMn9A9PftlqqdjIuHrkMUHuJiLgivyKIDh08Wu(Vjtj4(GV76WVKyBLePecPgePEFrkMU5f7iifEqkMUHucnIuArQWiLGLIcIztVwVuGvLvXa22fbWzmCivyKIkAJD4ttKa5be7iiLqi1Gifw5WmhmicK9gtPKJTwEYtEYHJsR0UIJTgpOH2hg8b8khgtVLvXsomE7JutdBnDSFegiKcPewNqktuWTjs9VfP0mgQfCLeCFWTtA1msTKMY1wAIuYtKqQ2npXoPjsX07kMKE0t8IvesPXaHu49RIsBstKsZzdrv6drnJu5HuAoBiQsFi6PQdGOPMrQorQqa8g4fKclAJGvp6jEXkcPgCGqk8(vrPnPjsP5SHOk9HOMrQ8qknNnevPpe9u1bq0uZivNiviaEd8csHfTrWQh9eVyfHud4aHuAAK4fLMiLOvduiIumDIHdPWsDjs1rBdQdGiKYkKIeDH60UcRifw0gbRE0t8IvesPDamqifE)QO0M0eP0C2quL(quZivEiLMZgIQ0hIEQ6aiAQzKclAJGvp6jEXkcP0IxhiKstJeVO0ePeTAGcrKIPtmCifwQlrQoABqDaeHuwHuKOluN2vyfPWI2iy1JEIEI3(i10Wwth7hHbcPqkH1jKYefCBIu)BrknlPLklDOzKAjnLRT0ePKNiHuTBEIDstKIP3vmj9ON4fRiKs7ddesH3VkkTjnrknNnevPpe1msLhsP5SHOk9HONQoaIMAgP6ePcbWBGxqkSOncw9ONON4TpsnnS10X(ryGqkKsyDcPmrb3Mi1)wKsZSjqslvw6qZi1sAkxBPjsjprcPA38e7KMiftVRys6rpXlwri1aoqifE)QO0M0eP086w0)2yYhIAgPYdP086w0)2yYhIEQ6aiAQzKclAJGvp6j6jE7JutdBnDSFegiKcPewNqktuWTjs9VfP0Sm1msTKMY1wAIuYtKqQ2npXoPjsX07kMKE0t8Ives94bcPW7xfL2KMiLMZgIQ0hIAgPYdP0C2quL(q0tvhartnJuDIuHa4nWlifw0gbRE0t8Ives9OdesH3VkkTjnrknNnevPpe1msLhsP5SHOk9HONQoaIMAgPWI2iy1JEIxSIqkTpEGqk8(vrPnPjsP5SHOk9HOMrQ8qknNnevPpe9u1bq0uZifw0gbRE0t0t82hPMg2A6y)imqifsjSoHuMOGBtK6FlsPz2eiPVMrQL0uU2stKsEIes1U5j2jnrkMExXK0JEIxSIqkngiKcVFvuAtAIuAEDl6FBm5drnJu5HuAEDl6FBm5drpvDaen1msHfTrWQh9e9eV9rQPHTMo2pcdesHucRtiLjk42eP(3IuAEs)2fk1msTKMY1wAIuYtKqQ2npXoPjsX07kMKE0t8IvesP9HbcPW7xfL2KMiLMZgIQ0hIAgPYdP0C2quL(q0tvhartnJuDIuHa4nWlifw0gbRE0t8IvesPv7aHu49RIsBstKsZzdrv6drnJu5HuAoBiQsFi6PQdGOPMrQorQqa8g4fKclAJGvp6j6jE7JutdBnDSFegiKcPewNqktuWTjs9VfP0CFKMrQL0uU2stKsEIes1U5j2jnrkMExXK0JEIxSIqQqoqifE)QO0M0eP0C2quL(quZivEiLMZgIQ0hIEQ6aiAQzKclAJGvp6jEXkcP0QDGqk8(vrPnPjsP5SHOk9HOMrQ8qknNnevPpe9u1bq0uZifw0gbRE0t8IvesP9rhiKcVFvuAtAIuAoBiQsFiQzKkpKsZzdrv6drpvDaen1msHfTrWQh9e9utxuWTjnrQbePAwAxHuqMmLE0toSG9(geXHhGdqKcV1QjMgchTifEZxHd9CaoarQhPG1GqknWhP04bn0IEIEoahGiLWyOghs9iYKPePUps9iYDDGuwL0UUcsKc6InMh9CaoarkHXqnoKcwGvLvXifEF7IqQhXgdhsbDXgZJEoahGi1JCorQGtk)wSEIumDIHtIu5HuID5aPW74nHuuLRrsp6j65aCaIuHariMBstKkG(3sif7ed6ePcOyRKEK6rYyKGuIu1v4rVxXVles1S0UsIuxb5WJE2S0Us6fSe7ed60PXqdUmHOj4d1oOjgRIb5fXk0ZML2vsVGLyNyqNongA0EToaIWVArAmIlvGRaUscKRv4Oe)tWOKs8J2qU0iPPCnbcOP3kjBDZoaIaAk3UsxrWKIAm69L0uUMab00hd1tRZBLGGEgtVVKMY1eiGMEmBN6Y8kc9SzPDL0lyj2jg0PtJHY0nqG7kt8T)OMKnevPxslvw6WtvharZ3xnjBiQs)3Kj4(GuNay0TKaPftRNQoaIMONnlTRKEblXoXGoDAmuMUbW0rj8T)OMKnevPNkAJTqqRIbeKfHwpvDaenrprphGdqKkeicXCtAIuuuADGuPjsivQtivZYBrktIuD02G6aiYJE2S0Usokfq9c07AcK5A4i0ZML2vsNgdnAVwhar4xTinQFqtqexQW)emkPe)OnKlnYUdAEykVvrpCeiIlvGuNay0TKaPftRFjX2k5WVfRNGLeBRKVVFlwpblj2wjfsRgpe(BX6jyjX2k5q2DqZdt5L0sLLo8lj2wjdZUdAEykVKwQS0HFjX2k5qTpGE2S0Us60yOcU0UcF7pILa3)3lPLklD4Df8(g4()EzERiG6n1bDnbFBjVRaSgwaL(iUubsDcGr3scKwmT(MLwu69n4KYWFlwpblj2wjfA8rFa9SzPDL0PXqzneeOzPDfaYKj(vlsJsAPYsh4B)Xa3)3lPLklD4DfGE2S0Us60yOSgcc0S0UcazYe)QfPrmul4kj4(GBN0IV9hdC)FpgQfCLeCFWTtA9UcqpBwAxjDAmuwdbbAwAxbGmzIF1I04jGkAX3(JPjsc94WmDtOqgwteqPpIlvGuNay0TKaPftRVzPfLqpBwAxjDAm0VjtW9bPobWOBjbslMw8zoyqei7nMs5Ow8T)it38IDe8W0THJdgglurBSdFAIeipGyhriTVVurBSdFAIeipGyhrOhhMDh08Wu(Vjtj4(GV76WVKyBLuiT(q((YUdAEykpgQfCLeCFWTtA9lj2wjfsdSIE2S0Us60yOuebeeqVxr8T)it38IDe8W0THJAdJfQOn2HpnrcKhqSJiK23x2DqZdt5L0sLLo8lj2wjfsJ3xQOn2HpnrcKhqSJi0JdZUdAEyk)3KPeCFW3DD4xsSTskKwFiFFz3bnpmLhd1cUscUp42jT(LeBRKcPbwrpBwAxjDAm00IPfiOHeXN5GbrGS3ykLJAX3(JStm4aYCnCuyMU5f7i4HPBdh1imwOI2yh(0ejqEaXoIqAFFz3bnpmLxslvw6WVKyBLuinEFPI2yh(0ejqEaXoIqpom7oO5HP8FtMsW9bF31HFjX2kPqA9H89LDh08WuEmul4kj4(GBN06xsSTskKgyf9SzPDL0PXqzneeOzPDfaYKj(vlsJSjqsF8T)OMKnevPxslvw6a9SzPDL0PXqzneeOzPDfaYKj(vlsJSjqslvw6aF7pMnevPxslvw6a9SzPDL0PXqzneeOzPDfaYKj(vlsJYeF7p2S0IsaQirJKcni6zZs7kPtJHYAiiqZs7kaKjt8RwKg7JW3(JnlTOeGks0i5WXbrprpBwAxj99rJy0TfYQyWC74RacClMo6zZs7kPVpYPXqPI2yle0QyabzrSfF7pY0nVyhbpmDB4OgHPI2yh(0ejqEaXoYqnEFz6MxSJGhMUnC8XONnlTRK((iNgdvkWQYQyaB7Ia4mgo8T)i7edoGmxdhfglbU)VF2fJa3hW0Tb28UcEFNuG7)7dUIMUYeeSegVRaSIE2S0Us67JCAm0Vjtj4(GV76aF7psfTXo8PjsG8aIDKHueI5Meinr69LPBEXocEy6MqJArpBwAxj99rong6AsRIbs3cGZy4WN5GbrGS3ykLJAX3(JyjBiQspgDBHSkgm3o(kGa3IPhMDh08Wu(1KwfdKUfaNXW5NUBN2vdz3bnpmLhJUTqwfdMBhFfqGBX09lj2wjD6Xynmwy3bnpmL)BYucUp47Uo8lj2wjho47lt3gogsSIE2S0Us67JCAm01vQBvmyG7jbWy1eF7pg4()(1vQBvmyG7jbWy10ppmf6zZs7kPVpYPXqPiciiGEVI4B)rMU5f7i4HPBdh1IE2S0Us67JCAm0VjtW9bPobWOBjbslMw8zoyqei7nMs5Ow8T)it38IDe8W0THJdIE2S0Us67JCAmuMUbcCxzIV9hz6MxSJGhMUnCud0ZML2vsFFKtJHY2MHdYQyWa3tcazX6zzvm(2FmW9)9Pobirb0EReWAbnZYB9YSz4gQDadtfTXo8PjsG8aIDKHueI5MeinrcpAdZUdAEyk)3KPeCFW3DD4xsSTsoKIqm3KaPjsONnlTRK((iNgdnTyAbcAir8zoyqei7nMs5Ow8T)it38IDe8W0THJAeglAs2quLEDlbStm4EFzNyWbK5A4iSIE2S0Us67JCAm0EzDrG82LQeF7pY0nVyhbpmDB4Ow0ZML2vsFFKtJHkfyvzvmGTDraCgdh(2FKDIbhqMRHJcJf2DqZdt5dUIMUYeeSeg)sITvYHA8(QjSlkvDL(Iy7bD7eRHXct3gogY3x2DqZdt5)MmLG7d(URd)sITvYHp67l7oO5HP8FtMsW9bF31HFjX2k5WbdZ0THJdgMkAJD4ttKa5bc5dcP99LkAJD4ttKa5be7icnILbDAWqi7oO5HP8FtMsW9bF31HFjX2kPqHeRVVbU)VxM3kcOEtDqxtW3wY7kaRONnlTRK((iNgdLPBamDucF7pYoXGdiZ1WrONnlTRK((iNgd9d5WQyGKwbuLaCgdh(2FmW9)9bhoGG9y(5HPW3QK21vqoQf9SzPDL03h50yObqnd35MaCgdh(mhmicK9gtPCul(2FKDIbhqMRHJcJLa3)3hC4ac2J5Df8(MnevPx3sa7edUWcwkkiMn9A9PftlqqdjgMPBJAeMDh08Wu(Vjtj4(GV76WVKyBLuObFFz6MxSJGhMUj0O2WcwkkiMn9A9sbwvwfdyBxeaNXWfMkAJD4ttKa5be7icniwrprpBwAxj9Sjqs)rRIE4iqexQaPobWOBjbslMw8T)OMeTxRdGiV(bnbrCP69n4KYWFlwpblj2wjfsJqIE2S0Us6ztGK(ongAEUmDW9btQtD8T)43I1tWsITvYHyrlE9b8SUf9VnM8)oBiqEUm9qOwnEaRVVbU)VxM3kcOEtDqxtW3wYppmvybu6J4sfi1jagDljqAX06BwArP33Gtkd)Ty9eSKyBLuiTpGE2S0Us6ztGK(ongkgQfCLeCFWTtAX3(JyzBBcOOuL(EoLERg(4q((UTnbuuQsFpNsVRaSgMDh08Wu(1KwfdKUfaNXW5xsSTskefHyUjbstKqpBwAxj9SjqsFNgd93eKveqMNOa8T)i7edoGmxdhfglBBtafLQ03ZP0B1qTp8(UTnbuuQsFpNsVRaSIE2S0Us6ztGK(ong6VHGOcC7Kw8T)422eqrPk99Ck9wnCWhEF32MakkvPVNtP3va6zZs7kPNnbs670yObxrtxzccwcd(2FCBBcOOuL(EoLERggYhEF32MakkvPVNtP3va(qwra2C8rFa9SzPDL0ZMaj9DAmuzERiG6n1bDnbFBjW3I0jHV9hzxnDT0ZUBNw1jnb3)tL0IsEQ6aiAIE2S0Us6ztGK(ongQmVveq9M6GUMGVTe(2FKDh08WuEzERiG6n1bDnbFBjptV3ysoQX7BWjLH)wSEcwsSTskKgp8(ILTTjGIsv675u6xsSTsouBiFF1e2fLQUspohR1vySGLTTjGIsv675u6TAi7oO5HP8Y8wra1BQd6Ac(2s(VleeyjMEVXeinr69vt22MakkvPVNtPNIyYuI1WyHDh08WuERIE4iqexQaPobWOBjbslMw)sITvYHS7GMhMYlZBfbuVPoORj4Bl5)UqqGLy69gtG0eP33O9ADae51pOjiIlvyfRHz3bnpmL)BYucUp47Uo8lj2wjfACadZ0THJAeMDh08WuEm62czvmyUD8vabUft3VKyBLuOrTAGv0ZML2vspBcK03PXqL5TIaQ3uh01e8TLW3(JSlkvDLECowRRWyjW9)9yOwWvsW9b3oP17k49flbNug(BX6jyjX2kPqS7GMhMYJHAbxjb3hC7Kw)sITvY3x2DqZdt5XqTGRKG7dUDsRFjX2k5q2DqZdt5L5TIaQ3uh01e8TL8FxiiWsm9EJjqAIewdZUdAEyk)3KPeCFW3DD4xsSTsk04agMPBdh1im7oO5HP8y0TfYQyWC74RacClMUFjX2kPqJA1aRONnlTRKE2eiPVtJHALKTUzharanLBxPRiysrngHV9hfqPpIlvGuNay0TKaPftRVzPfLEFdoPm83I1tWsITvsH04b0ZML2vspBcK03PXqXSDQlZRi8T)Oak9rCPcK6eaJULeiTyA9nlTO07BWjLH)wSEcwsSTskKgpGE2S0Us6ztGK(ongAmupToVvcc6zmHV9hfqPpIlvGuNay0TKaPftRVzPfLEFdoPm83I1tWsITvsH04b0ZML2vspBcK03PXqDLeWssuIV9h1KO9ADae5J4sf4kGRKa5AfokFFz3bnpmL3QOhoceXLkqQtam6wsG0IP1VKyBLCOgp8(gTxRdGiV(bnbrCPc9SzPDL0ZMaj9DAm08Cz6G7dW1RyJV9h)wSEcwsSTsouBihW3xbu6J4sfi1jagDljqAX06BwArP33O9ADae51pOjiIlvONnlTRKE2eiPVtJHgaD3e8Dxh4B)r2DqZdt5Tk6HJarCPcK6eaJULeiTyA9lj2wjho4dVVr716aiYRFqtqexQEFdoPm83I1tWsITvsH04b0ZML2vspBcK03PXqdOvsloRIX3(JS7GMhMYBv0dhbI4sfi1jagDljqAX06xsSTsoCWhEFJ2R1bqKx)GMGiUu9(gCsz4VfRNGLeBRKcPnKONnlTRKE2eiPVtJHczX6PemWUZyrQs0ZML2vspBcK03PXq)2sbq3nX3(JS7GMhMYBv0dhbI4sfi1jagDljqAX06xsSTsoCWhEFJ2R1bqKx)GMGiUu9(gCsz4VfRNGLeBRKcP9b0ZML2vspBcK03PXq7IrYCBiaRHGW3(JS7GMhMYBv0dhbI4sfi1jagDljqAX06xsSTsoCWhEFJ2R1bqKx)GMGiUu9(gCsz4VfRNGLeBRKcPXdONnlTRKE2eiPVtJHg0XG7dY1y4K4B)Xa3)3lZBfbuVPoORj4Bl5NhMc9e9SzPDL0ZMajTuzPJXO9ADaeHF1I0OKwQS0biWDLj(NGrjL4hTHCPr2DqZdt5L0sLLo8lj2wjfs77Rak9rCPcK6eaJULeiTyA9nlTOuy2DqZdt5L0sLLo8lj2wjho4dVVbNug(BX6jyjX2kPqA8a6zZs7kPNnbsAPYshongQvrpCeiIlvGuNay0TKaPftl(2FutI2R1bqKx)GMGiUu9(gCsz4VfRNGLeBRKcPrirpBwAxj9Sjqslvw6WPXqdGUBc(URd8T)y0EToaI8sAPYshGa3vMONnlTRKE2eiPLklD40yOb0kPfNvX4B)XO9ADae5L0sLLoabURmrpBwAxj9Sjqslvw6WPXqHSy9ucgy3zSivj6zZs7kPNnbsAPYshong63wka6Uj(2FmAVwharEjTuzPdqG7kt0ZML2vspBcK0sLLoCAm0UyKm3gcWAii8T)y0EToaI8sAPYshGa3vMONnlTRKE2eiPLklD40yObDm4(GCngoj(2FmAVwharEjTuzPdqG7kt0ZML2vspBcK0sLLoCAm08Cz6G7dMuN64B)XVfRNGLeBRKdXIw86d4zDl6FBm5)D2qG8Cz6HqTA8awFFfqPpIlvGuNay0TKaPftRVzPfLEFdoPm83I1tWsITvsH0(a6zZs7kPNnbsAPYshongAEUmDW9b46vSX3(JFlwpblj2wjhoGp8(kGsFexQaPobWOBjbslMwFZslk9(gCsz4VfRNGLeBRKcP9b0ZML2vspBcK0sLLoCAmumul4kj4(GBN0IV9hz3bnpmLFnPvXaPBbWzmC(LeBRKcrriMBsG0ej0ZML2vspBcK0sLLoCAmuRKS1n7aicOPC7kDfbtkQXi8T)y0EToaI8sAPYshGa3vMONnlTRKE2eiPLklD40yOy2o1L5ve(2FmAVwharEjTuzPdqG7kt0ZML2vspBcK0sLLoCAm0yOEADERee0ZycF7pgTxRdGiVKwQS0biWDLj6zZs7kPNnbsAPYshongQRKawsIs8T)OMeTxRdGiFexQaxbCLeixRWr57l7oO5HP8wf9WrGiUubsDcGr3scKwmT(LeBRKd14H33O9ADae51pOjiIlvONnlTRKE2eiPLklD40yO)MGSIaY8efGE2S0Us6ztGKwQS0HtJH(BiiQa3oPf9SzPDL0ZMajTuzPdNgdn4kA6ktqWsyqpBwAxj9Sjqslvw6WPXqL0sLLoW3(JS7GMhMYVM0QyG0Ta4mgo)sITvsH049n4KYWFlwpblj2wjfsBirpBwAxj9Sjqslvw6WPXqd6yW9b5AmCs0t0ZML2vs)jGkAh)Mmb3hK6eaJULeiTyAXN5GbrGS3nMs5Ow8T)it38IDe8W0THJdIE2S0Us6pburRtJHsreqqa9EfX3(Jzdrv6z6giWDLPNQoaIMHz6MxSJGhMUnCCq0ZML2vs)jGkADAm00IPfiOHeXN5GbrGS3ykLJAX3(JStm4aYCnCuyMU5f7i4HPBdh1a9SzPDL0FcOIwNgdLPBamDucF7pY0nVyhbpmDBud0ZML2vs)jGkADAmukIaccO3Ri6zZs7kP)eqfTongAAX0ce0qI4ZCWGiq2BmLYrT4B)rMU5f7i4HPBdh1a9e9SzPDL0lPLklDm(nzkb3h8Dxh4B)Xa3)3lPLklD4xsSTskKw0ZML2vsVKwQS0HtJHkfyvzvmGTDraCgdh(2FKDIbhqMRHJcJLMLwucqfjAKC44GVVnlTOeGks0i5qTH1e2DqZdt5xtAvmq6waCgdN3vawrpBwAxj9sAPYshong6AsRIbs3cGZy4WN5GbrGS3ykLJAX3(JStm4aYCnCe6zZs7kPxslvw6WPXq)MmLG7d(URd8T)yZslkbOIensoCCq0ZML2vsVKwQS0HtJHkfyvzvmGTDraCgdh(2FKDIbhqMRHJch4()(zxmcCFat3gyZ7ka9SzPDL0lPLklD40yObqnd35MaCgdh(mhmicK9gtPCul(2FKDIbhqMRHJch4()Emul4kj4(GBN06DfeMDh08Wu(1KwfdKUfaNXW5xsSTsoud0ZML2vsVKwQS0HtJH(nzkb3h8Dxh4Bvs76kib2FmW9)9sAPYshExbHz3bnpmLFnPvXaPBbWzmC(L6Pd0ZML2vsVKwQS0HtJHkfyvzvmGTDraCgdh(2FKDIbhqMRHJcpPa3)3hCfnDLjiyjmExbONnlTRKEjTuzPdNgd9BYeCFqQtam6wsG0IPfFMdgebYEJPuoQfF7pY0nHge9SzPDL0lPLklD40yObqnd35MaCgdh(mhmicK9gtPCul(2FKDIbhqMRHJEF1KSHOk96wcyNyWHE2S0Us6L0sLLoCAmuPaRkRIbSTlcGZy4qprpBwAxj9YCeJUTqwfdMBhFfqGBX0X3(JBBtafLQ03ZP0B1q2DqZdt5XOBlKvXG52Xxbe4wmD)0D70Uke(GhV((UTnbuuQsFpNsVRa0ZML2vsVmDAmuQOn2cbTkgqqweBX3(JmDZl2rWdt3goQryQOn2HpnrcKhqSJmCW3xMU5f7i4HPBdhFCySqfTXo8PjsG8aIDKHA8(QjcwkkiMn9A9PftlqqdjIv0ZML2vsVmDAmuPaRkRIbSTlcGZy4W3(JStm4aYCnCu4a3)3p7IrG7dy62aBExbHXY22eqrPk99Ck9wnmW9)9ZUye4(aMUnWMFjX2kjE049DBBcOOuL(EoLExbyf9SzPDL0ltNgdDnPvXaPBbWzmC4ZCWGiq2BmLYrT4B)r2DqZdt5L0sLLo8lj2wjhQ99vtYgIQ0lPLklDGE2S0Us6LPtJH(nzkb3h8Dxh4B)rSSTnbuuQsFpNsVvdz3bnpmL)BYucUp47Uo8t3Tt7Qq4dE867722eqrPk99Ck9UcWAySqfTXo8PjsG8aIDKHueI5MeinrcpAFFz6MxSJGhMUj0O233a3)3lZBfbuVPoORj4Bl5xsSTskefHyUjbstKCslwFF)wSEcwsSTskefHyUjbstKCsl6zZs7kPxMongkBBgoiRIbdCpjaKfRNLvX4B)Xa3)3N6eGefq7TsaRf0mlV1lZMHBO2bmmv0g7WNMibYdi2rgsriMBsG0ej8Onm7oO5HP8RjTkgiDlaoJHZVKyBLCifHyUjbstKEFdC)FFQtasuaT3kbSwqZS8wVmBgUHAFCySWUdAEykVKwQS0HFjX2kPqHmC2quLEjTuzPJ3x2DqZdt5XqTGRKG7dUDsRFjX2kPqHmm7IsvxPhNJ16699BX6jyjX2kPqHeRONnlTRKEz60yORRu3QyWa3tcGXQj(2FmW9)9RRu3QyWa3tcGXQPFEyQWnlTOeGks0i5qTONnlTRKEz60yOFtMG7dsDcGr3scKwmT4ZCWGiq2BmLYrT4B)rMUj0GONnlTRKEz60yOuebeeqVxr8T)it38IDe8W0THJArpBwAxj9Y0PXqz6giWDLj(2FKPBEXocEy62WrTHBwArjavKOrYrTH32MakkvPVNtP3QHA8W7lt38IDe8W0THJAeUzPfLaurIgjhoQb6zZs7kPxMongkt3ay6Oe6zZs7kPxMongAAX0ce0qI4ZCWGiq2BmLYrT4B)r2jgCazUgokmt38IDe8W0THJAeoW9)9Y8wra1BQd6Ac(2s(5HPqpBwAxj9Y0PXqLcSQSkgW2UiaoJHdF7pg4()EMUbOI2yhEz2mCdh8b8eYqyZslkbOIensgoW9)9Y8wra1BQd6Ac(2s(5HPcJf2DqZdt5xtAvmq6waCgdNFjX2k5qncZUdAEyk)3KPeCFW3DD4xsSTsouJ3x2DqZdt5xtAvmq6waCgdNFjX2kPqdgMDh08Wu(Vjtj4(GV76WVKyBLC4GHz62WbFFz3bnpmLFnPvXaPBbWzmC(LeBRKdhmm7oO5HP8FtMsW9bF31HFjX2kPqdgMPBdF87lt38IDe8W0nHg1gMkAJD4ttKa5be7icPbwFFdC)Fpt3aurBSdVmBgUHAFi83I1tWsITvsHgaONnlTRKEz60yObqnd35MaCgdh(mhmicK9gtPCul(2FKDIbhqMRHJcJLSHOk9sAPYshHz3bnpmLxslvw6WVKyBLuObFFz3bnpmLFnPvXaPBbWzmC(LeBRKd1gMDh08Wu(Vjtj4(GV76WVKyBLCO23x2DqZdt5xtAvmq6waCgdNFjX2kPqdgMDh08Wu(Vjtj4(GV76WVKyBLC4GHz62qnEFz3bnpmLFnPvXaPBbWzmC(LeBRKdhmm7oO5HP8FtMsW9bF31HFjX2kPqdgMPBdh89LPBdd57BG7)7doCab7X8UcWk6zZs7kPxMongAAX0ce0qI4ZCWGiq2BmLYrT4B)r2jgCazUgokmt38IDe8W0THJAGE2S0Us6LPtJH2lRlcK3UuL4B)rMU5f7i4HPBdh1IE2S0Us6LPtJH(HCyvmqsRaQsaoJHdFRsAxxb5Ow0ZML2vsVmDAm0aOMH7CtaoJHdFMdgebYEJPuoQfF7pYoXGdiZ1WrHz3bnpmL)BYucUp47Uo8lj2wjfAWWmDBuJWcwkkiMn9A9PftlqqdjgMkAJD4ttKa5bc5dcPf9SzPDL0ltNgdnaQz4o3eGZy4WN5GbrGS3ykLJAX3(JStm4aYCnCuyQOn2HpnrcKhqSJiKgHXct38IDe8W0nHg1((kyPOGy20R1NwmTabnKiwrprpBwAxj9yOwWvsW9b3oPDmAVwhar4xTinga1mCNBcWzmCGIOjnX)emkPe)OnKlng4()Emul4kj4(GBN0cWGXVKyBLmmwy3bnpmLFnPvXaPBbWzmC(LeBRKddC)FpgQfCLeCFWTtAbyW4xsSTsgoW9)9yOwWvsW9b3oPfGbJFjX2kPqA8(YUdAEyk)AsRIbs3cGZy48lj2wjXtG7)7XqTGRKG7dUDsladg)sITvYHAeoW9)9yOwWvsW9b3oPfGbJFjX2kPqpgRONnlTRKEmul4kj4(GBN060yOSgcc0S0UcazYe)QfPr2eiPp(2FutYgIQ0lPLklDGE2S0Us6XqTGRKG7dUDsRtJHYAiiqZs7kaKjt8RwKgztGKwQS0b(2FmBiQsVKwQS0b6zZs7kPhd1cUscUp42jTongkv0gBHGwfdiilIT4B)rMU5f7i4HPBdh1imv0g7WNMibYdi2rgoi6zZs7kPhd1cUscUp42jTong6AsRIbs3cGZy4WN5GbrGS3ykLJArpBwAxj9yOwWvsW9b3oP1PXq)MmLG7d(URd8T)yZslkbOIensoCuJWbU)Vhd1cUscUp42jTamy8lj2wjfsl6zZs7kPhd1cUscUp42jTongkgDBHSkgm3o(kGa3IPJV9hBwArjavKOrYHJAGE2S0Us6XqTGRKG7dUDsRtJHkfyvzvmGTDraCgdh(2FKDIbhqMRHJc3S0IsaQirJKdhhmCG7)7XqTGRKG7dUDsladgVRa0ZML2vspgQfCLeCFWTtADAm0aOMH7CtaoJHd)S3ykb2Fu0QbAsbU)VxSxCG7dsDcW2Ui)sITvs8T)i7edoGmxdhfUzPfLaurIgjfAuJWr716aiYha1mCNBcWzmCGIOjnrpBwAxj9yOwWvsW9b3oP1PXqLcSQSkgW2UiaoJHdF7pYoXGdiZ1WrHdC)F)SlgbUpGPBdS5DfGE2S0Us6XqTGRKG7dUDsRtJHIr3wiRIbZTJVciWTy6ONnlTRKEmul4kj4(GBN060yOFtMsW9bF31b(wL0UUcsG9hdC)FpgQfCLeCFWTtAbyW4DfGV9hdC)FVmVveq9M6GUMGVTK3vq4TTjGIsv675u6TAi7oO5HP8FtMsW9bF31HF6UDAxfcFW)OONnlTRKEmul4kj4(GBN060yOsbwvwfdyBxeaNXWHV9hdC)Fpt3aurBSdVmBgUHd(aEcziSzPfLaurIgjrpBwAxj9yOwWvsW9b3oP1PXq)Mmb3hK6eaJULeiTyAXN5GbrGS3ykLJAX3(JmDtObrpBwAxj9yOwWvsW9b3oP1PXqPiciiGEVI4B)rMU5f7i4HPBdh1IE2S0Us6XqTGRKG7dUDsRtJHY0nqG7kt8T)it38IDe8W0THJyrRtnlTOeGks0i5qTyf9SzPDL0JHAbxjb3hC7KwNgdnTyAbcAir8zoyqei7nMs5Ow8T)iw0KSHOk96wcyNyW9(YoXGdiZ1Wrynmt38IDe8W0THJAGE2S0Us6XqTGRKG7dUDsRtJHga1mCNBcWzmC4N9gtjW(JIwnqtkW9)9I9IdCFqQta22f5xsSTsIV9hBwArjavKOrsHghmmt3goo47BG7)7XqTGRKG7dUDsladgVRa0ZML2vspgQfCLeCFWTtADAmuMUbW0rj0ZML2vspgQfCLeCFWTtADAm0pKdRIbsAfqvcWzmC4Bvs76kih1YHB3u)womSjI35jp5Ca]] )


end