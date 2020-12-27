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

            talent = "good_karma",

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
        desc = "If set above zero, |T651728:0|t Touch of Karma will only be recommended while you have incoming damage.",
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
    
    spec:RegisterPack( "Windwalker", 20201225, [[d0Kl1bqicQ6reuHnjk9jsvAuiuofcvRsHu1Riv1SquUfcPDrv)semmeIJrkTmcYZuiMgbfxJufBtHK(MiKACeuY5uiL1rqLMhPI7PG9jkoOcjYcjv6HIqYejOI0ffHqBuHe6JkKkDsriQvcQ8scQiAMeuQBsqfv7eu1pvibdLGkklvHe1tvvtfr1vjOIWxfHiJveQ2ls)fyWeDyPwSi9yOMSIUmQndYNfvJMkonLvlcLxJiZwvUnH2TKFR0WjWXvivSCvEojtx46uPTRq9DemEr05jfRxecMpOSFit1sjN(NDWu4fIicreTcjKE8A1ZicnsIM(dncy6xqJj15m9xTit)jswnj0ps8r)cAnVTNuYPF16EyM(P)ux7fjYfnL(NDWu4fIicreTcjKE8A1ZicnIWq)kbmMcVqJ6Or)o2CYfnL(NSct)chizIKvtc9JeFiPW5BrcbNWbskCkJzXu(qsH0dziPqeriIGGdbNWbssobUjHKJIMkui5cHKJIUNgK0QGVZvqGKVn3WE6)zQqrjN(xbCXhLCk8APKt)C1PpEs1L(BCyBr)qMkaleiCyabhlyqy58r)4Zc(SM(XoMxStIKefjXogsMzajhH(XAWpge9D5COOFT0GcVquYPFU60hpP6s)4Zc(SM(J(Xv4Xogi19uHNRo9XtKmlsIDmVyNejjksIDmKmZasoc934W2I(5Kc4hWPprAqHFek50pxD6JNuDP)gh2w0Fy58be0pr6hFwWN10pEftxGkoJeJKzrsSJ5f7KijrrsSJHKzgqsHOFSg8JbrF5COOWRLgu4fgk50pxD6JNuDPF8zbFwt)yhZl2jrsIIKyhdjhqsHO)gh2w0p2Xae6XmnOWRhk50FJdBl6NtkGFaN(ePFU60hpP6sdk8JkLC6NRo9XtQU0FJdBl6pSC(ac6Ni9Jpl4ZA6h7yEXojssuKe7yizMbKui6hRb)yq0xohkk8APbnOFcClylfyHa7n5JsofETuYPFU60hpP6s)4Zc(SM(fEKm6hxHxXhxwOXZvN(4j934W2I(X97bACyBbEMkO)NPcq1Im9JNafdrdk8crjN(5QtF8KQl9Jpl4ZA6p6hxHxXhxwOXZvN(4j934W2I(X97bACyBbEMkO)NPcq1Im9JNafFCzHgAqHFek50pxD6JNuDPF8zbFwt)yhZl2jrsIIKyhdjZmGKcHKzrsU4lxJpmrgelqStIKzqYrO)gh2w0px8LBjcwLd4NL0oAqHxyOKt)C1PpEs1L(BCyBr)NPSkhOClajdtI(XAWpge9LZHIcVwAqHxpuYPFU60hpP6s)4Zc(SM(XRy6cuXzKyKmlsM6cb5NDHzWcbWowIzExb0FJdBl6xjWQYQCa(6IbKmmjAqHFuPKt)C1PpEs1L(XNf8zn934WgZaUyrJvizMbKuiKmlsM6cb5jWTGTuGfcS3Kpabc(JfBRuiPoiPw6VXHTf9dzQqbwiaK7PHgu4t0uYPFU60hpP6s)4Zc(SM(BCyJzaxSOXkKmZaske934W2I(j4y3ZQCW868TacClSdnOWlSOKt)C1PpEs1L(XNf8zn9JxX0fOIZiXizwKSXHnMbCXIgRqYmdi5iizwKm1fcYtGBbBPaleyVjFace8UcO)gh2w0VsGvLv5a81fdizys0Gc)OrjN(5QtF8KQl934W2I(tFnM06gasgMe9Jpl4ZA6hVIPlqfNrIrYSizJdBmd4IfnwHK6mGKcr)yn4hdI(Y5qrHxlnOWRLiuYP)gh2w0pbh7EwLdMxNVfqGBHDOFU60hpP6sdk8A1sjN(5QtF8KQl9Jpl4ZA6p1fcYRI9ebCFHdORjaYo27kajZIKxBtapMRW3ZPYBfsMbjX7(MlHYdzQqbwiaK7PXpDVoSTqYrpsse)Os)noSTOFitfkWcbGCpn0VvbFNRGayq0FQleKNa3c2sbwiWEt(aei4Dfqdk8AfIso9ZvN(4jvx6hFwWN10FQleKh7yaU4lxJxfnMesMbjhHiijrrs9GKJEKSXHnMbCXIgRO)gh2w0VsGvLv5a81fdizys0GcV2rOKt)C1PpEs1L(BCyBr)qMkaleiCyabhlyqy58r)4Zc(SM(XogsQdsoc9J1GFmi6lNdffET0GcVwHHso9ZvN(4jvx6hFwWN10p2X8IDsKKOij2XqYmdiPw6VXHTf9ZjfWpGtFI0GcVw9qjN(5QtF8KQl9Jpl4ZA6h7yEXojssuKe7yizMbKKyiPwKuFKSXHnMbCXIgRqYmiPwKK40FJdBl6h7yGu3tf0GcV2rLso9ZvN(4jvx6VXHTf9hwoFab9tK(XNf8zn9tmKu4rYOFCfEhla4vmD9C1PpEIKWGHK4vmDbQ4msmssCKmlsIDmVyNejjksIDmKmZaske9J1GFmi6lNdffET0GcV2enLC6VXHTf9JDmaHEmt)C1PpEs1Lgu41kSOKt)C1PpEs1L(BCyBr)PVgtADdajdtI(XNf8zn9JDmKmZasocscdgsM6cb5jWTGTuGfcS3KpabcExb0pwd(XGOVCouu41sdk8Ahnk50VvbFNRGG(1s)noSTOFONgRYbk(eWvaizys0pxD6JNuDPbnOFfFCzHgk5u41sjN(5QtF8KQl9Jpl4ZA6p1fcYR4Jll04pwSTsHK6GKAP)gh2w0pKPcfyHaqUNgAqHxik50FJdBl63vXalyrf9ZvN(4jvxAqHFek50pxD6JNuDPF8zbFwt)4vmDbQ4msmsMfjjgs24WgZaUyrJvizMbKCeKegmKSXHnMbCXIgRqYmiPwKmlsk8ijE33Cju(ZuwLduUfGKHj5DfGKeN(BCyBr)kbwvwLdWxxmGKHjrdk8cdLC6NRo9XtQU0FJdBl6)mLv5aLBbizys0p(SGpRPF8kMUavCgjM(XAWpge9LZHIcVwAqHxpuYPFU60hpP6s)4Zc(SM(BCyJzaxSOXkKmZasoc934W2I(HmvOaleaY90qdk8JkLC6NRo9XtQU0p(SGpRPF8kMUavCgjgjZIKPUqq(zxygSqaSJLyM3va934W2I(vcSQSkhGVUyajdtIgu4t0uYPFU60hpP6s)noSTO)0xJjTUbGKHjr)4Zc(SM(XRy6cuXzKyKmlsM6cb5jWTGTuGfcS3KpabcExbizwKeV7BUek)zkRYbk3cqYWK8hl2wPqYmiPq0pwd(XGOVCouu41sdk8clk50VvbFNRGayq0FQleKxXhxwOX7kilE33Cju(ZuwLduUfGKHj5pUNAO)gh2w0pKPcfyHaqUNg6NRo9XtQU0Gc)OrjN(5QtF8KQl9Jpl4ZA6hVIPlqfNrIrYSi5KtDHG8PBXtxvaspMG3va934W2I(vcSQSkhGVUyajdtIgu41sek50pxD6JNuDP)gh2w0pKPcWcbchgqWXcgewoF0p(SGpRPFSJHK6GKJq)yn4hdI(Y5qrHxlnOWRvlLC6NRo9XtQU0FJdBl6p91ysRBaizys0p(SGpRPF8kMUavCgjgjHbdjfEKm6hxH3XcaEftxpxD6JN0pwd(XGOVCouu41sdk8AfIso934W2I(vcSQSkhGVUyajdtI(5QtF8KQlnOb9JNafFCzHgk5u41sjN(5QtF8KQl9VcOFfh0FJdBl6FCFwN(y6FC)Cz6hV7BUekVIpUSqJ)yX2kfsQdsQfjHbdjfWHpPlxGWHbeCSGbHLZNVXHnMrYSijE33CjuEfFCzHg)XITvkKmdsocrqsyWqsil3jahl2wPqsDqsHic9pUpq1Im9R4Jll0asDpvqdk8crjN(5QtF8KQl9Jpl4ZA6x4rYX9zD6J9o7Bcs6Yfscdgscz5ob4yX2kfsQdskKEO)gh2w0VvJxsmiPlx0Gc)iuYP)gh2w0VRIbwWIk6NRo9XtQU0GcVWqjN(5QtF8KQl9Jpl4ZA6h7yEXojssuKe7yizMbKul934W2I(7d3fdI9oUcAqHxpuYP)gh2w0)ZYDcfiXCN5ICf0pxD6JNuDPbf(rLso9ZvN(4jvx6hFwWN10)4(So9XEfFCzHgqQ7Pc6VXHTf9dzhN(2Dsdk8jAk50pxD6JNuDPF8zbFwt)J7Z60h7v8XLfAaPUNkO)gh2w0Fxywfx)a4(9ObfEHfLC6NRo9XtQU0p(SGpRP)X9zD6J9k(4YcnGu3tf0FJdBl6pTZbleiodtsrdk8JgLC6NRo9XtQU0p(SGpRPFil3jahl2wPqYmiPwHfrqsyWqsbC4t6YfiCyabhlyqy585BCyJzKegmKeYYDcWXITvkKuhKulrO)gh2w0FSUyhWcbMCho0GcVwIqjN(5QtF8KQl9Jpl4ZA6hYYDcWXITvkKmdsoAebjHbdjfWHpPlxGWHbeCSGbHLZNVXHnMrsyWqsil3jahl2wPqsDqsTeH(BCyBr)X6IDaleGuFInnOWRvlLC6NRo9XtQU0p(SGpRPF8UV5sO8NPSkhOClajdtYFSyBLcj1bj5Km2nyqyIm934W2I(jWTGTuGfcS3KpAqHxRquYP)gh2w0puZpRyGkwrb0pxD6JNuDPbfETJqjN(BCyBr)q97XfyVjF0pxD6JNuDPbfETcdLC6VXHTf9NUfpDvbi9yc0pxD6JNuDPbfET6Hso9ZvN(4jvx6hFwWN10pE33Cju(ZuwLduUfGKHj5pwSTsHK6GKcHKWGHKqwUtaowSTsHK6GKA1d934W2I(v8XLfAObfETJkLC6VXHTf9N25GfceNHjPOFU60hpP6sdAq)QGsofETuYPFU60hpP6s)4Zc(SM(V2MaEmxHVNtL3kKmdsI39nxcLNGJDpRYbZRZ3ciWTWo(P71HTfso6rsI4fwijmyi512eWJ5k89CQ8UcO)gh2w0pbh7EwLdMxNVfqGBHDObfEHOKt)C1PpEs1L(XNf8zn9JDmVyNejjksIDmKmZaskesMfj5IVCn(WezqSaXojsMbjhbjHbdjXoMxStIKefjXogsMzajfgKmlssmKKl(Y14dtKbXce7KizgKuiKegmKu4rsbhpgKJNET(WY5diOFIijXP)gh2w0px8LBjcwLd4NL0oAqHFek50pxD6JNuDPF8zbFwt)4vmDbQ4msmsMfjtDHG8ZUWmyHayhlXmVRaKmlssmK8ABc4XCf(EovERqYmizQleKF2fMblea7yjM5pwSTsHKefjfcjHbdjV2MaEmxHVNtL3vassC6VXHTf9ReyvzvoaFDXasgMenOWlmuYPFU60hpP6s)noSTO)ZuwLduUfGKHjr)4Zc(SM(X7(MlHYR4Jll04pwSTsHKzqsTijmyiPWJKr)4k8k(4YcnEU60hpPFSg8JbrF5COOWRLgu41dLC6NRo9XtQU0p(SGpRPFIHKxBtapMRW3ZPYBfsMbjX7(MlHYdzQqbwiaK7PXpDVoSTqYrpsseVWcjHbdjV2MaEmxHVNtL3vassCKmlssmKKl(Y14dtKbXce7KizgKKtYy3GbHjYijrrsTijmyij2X8IDsKKOij2XqsDgqsTijmyizQleKxf7jc4(chqxtaKDS)yX2kfsQdsYjzSBWGWezKuFKulssCKegmKeYYDcWXITvkKuhKKtYy3GbHjYiP(iPw6VXHTf9dzQqbwiaK7PHgu4hvk50pxD6JNuDPF8zbFwt)PUqq(WHbSOa(2tbWTGgBXEEv0ysizgKu7OHKzrsU4lxJpmrgelqStIKzqsojJDdgeMiJKefj1IKzrs8UV5sO8NPSkhOClajdtYFSyBLcjZGKCsg7gmimrgjHbdjtDHG8Hddyrb8TNcGBbn2I98QOXKqYmiPwHbjZIKedjX7(MlHYR4Jll04pwSTsHK6GK6bjZIKr)4k8k(4YcnEU60hprsyWqs8UV5sO8e4wWwkWcb2BYN)yX2kfsQdsQhKmlsI3XC1v4jP5SUqsyWqsil3jahl2wPqsDqs9GKeN(BCyBr)4RXKEwLdsSEYGNL7eLv50GcFIMso9ZvN(4jvx6hFwWN10FQleK)CvowLdsSEYacwn9ZLqHKzrYgh2ygWflAScjZGKAP)gh2w0)5QCSkhKy9KbeSAsdk8clk50pxD6JNuDP)gh2w0pKPcWcbchgqWXcgewoF0p(SGpRPFSJHK6GKJq)yn4hdI(Y5qrHxlnOWpAuYPFU60hpP6s)4Zc(SM(XoMxStIKefjXogsMzaj1s)noSTOFoPa(bC6tKgu41sek50pxD6JNuDPF8zbFwt)yhZl2jrsIIKyhdjZmGKArYSizJdBmd4IfnwHKdiPwKmlsETnb8yUcFpNkVvizgKuiIGKWGHKyhZl2jrsIIKyhdjZmGKcHKzrYgh2ygWflAScjZmGKcr)noSTOFSJbsDpvqdk8A1sjN(BCyBr)yhdqOhZ0pxD6JNuDPbfETcrjN(5QtF8KQl934W2I(dlNpGG(js)4Zc(SM(XRy6cuXzKyKmlsIDmVyNejjksIDmKmZaskesMfjtDHG8Qypra3x4a6AcGSJ9ZLqr)yn4hdI(Y5qrHxlnOWRDek50pxD6JNuDPF8zbFwt)PUqqESJb4IVCnEv0ysizgKCeIGKefj1dso6rYgh2ygWflAScjZIKPUqqEvSNiG7lCaDnbq2X(5sOqYSijXqs8UV5sO8NPSkhOClajdtYFSyBLcjZGKcHKzrs8UV5sO8qMkuGfca5EA8hl2wPqYmiPqijmyijE33Cju(ZuwLduUfGKHj5pwSTsHK6GKJGKzrs8UV5sO8qMkuGfca5EA8hl2wPqYmi5iizwKe7yizgKCeKegmKeV7BUek)zkRYbk3cqYWK8hl2wPqYmi5iizwKeV7BUekpKPcfyHaqUNg)XITvkKuhKCeKmlsIDmKmdskmijmyij2X8IDsKKOij2XqsDgqsTizwKKl(Y14dtKbXce7KiPoiPqijXrsyWqYuxiip2XaCXxUgVkAmjKmdsQLiizwKeYYDcWXITvkKuhKmrt)noSTOFLaRkRYb4RlgqYWKObfETcdLC6NRo9XtQU0FJdBl6p91ysRBaizys0p(SGpRPF8kMUavCgjgjZIKedjJ(Xv4v8XLfA8C1PpEIKzrs8UV5sO8k(4Ycn(JfBRuiPoi5iijmyijE33Cju(ZuwLduUfGKHj5pwSTsHKzqsTizwKeV7BUekpKPcfyHaqUNg)XITvkKmdsQfjHbdjX7(MlHYFMYQCGYTaKmmj)XITvkKuhKCeKmlsI39nxcLhYuHcSqai3tJ)yX2kfsMbjhbjZIKyhdjZGKcHKWGHK4DFZLq5ptzvoq5wasgMK)yX2kfsMbjhbjZIK4DFZLq5HmvOaleaY904pwSTsHK6GKJGKzrsSJHKzqYrqsyWqsSJHKzqs9GKWGHKPUqq(0LeqWTyVRaKK40pwd(XGOVCouu41sdk8A1dLC6NRo9XtQU0FJdBl6pSC(ac6Ni9Jpl4ZA6hVIPlqfNrIrYSij2X8IDsKKOij2XqYmdiPq0pwd(XGOVCouu41sdk8Ahvk50VvbFNRGG(1s)noSTOFONgRYbk(eWvaizys0pxD6JNuDPbfETjAk50pxD6JNuDP)gh2w0F6RXKw3aqYWKOF8zbFwt)4vmDbQ4msmsMfjX7(MlHYdzQqbwiaK7PXFSyBLcj1bjhbjZIKyhdjhqsHqYSiPGJhdYXtVwFy58be0prKmlsYfF5A8HjYGyb6HiiPoiPw6hRb)yq0xohkk8APbfETclk50pxD6JNuDP)gh2w0F6RXKw3aqYWKOF8zbFwt)4vmDbQ4msmsMfj5IVCn(WezqSaXojsQdskesMfjjgsIDmVyNejjksIDmKuNbKulscdgsk44XGC80R1hwoFab9tejjo9J1GFmi6lNdffET0Gg0pEcumeLCk8APKt)C1PpEs1L(XNf8zn9l8i54(So9XEN9nbjD5cjHbdjHSCNaCSyBLcj1bjfsp0FJdBl63QXljgK0LlAqHxik50pxD6JNuDPF8zbFwt)yhZl2jrsIIKyhdjZmGKAP)gh2w0FF4UyqS3Xvqdk8JqjN(5QtF8KQl9Jpl4ZA6p1fcYRI9ebCFHdORjaYo2pxcfsMfjfWHpPlxGWHbeCSGbHLZNVXHnMrsyWqsil3jahl2wPqsDqsTebjHbdjHSCNaCSyBLcjZGKAfweH(BCyBr)X6IDaleyYD4qdk8cdLC6NRo9XtQU0p(SGpRPFIHKxBtapMRW3ZPYBfsMbjfg9GKWGHKxBtapMRW3ZPY7kajjosMfjX7(MlHYFMYQCGYTaKmmj)XITvkKuhKKtYy3GbHjY0FJdBl6Na3c2sbwiWEt(ObfE9qjN(5QtF8KQl9Jpl4ZA6hVIPlqfNrIrYSijXqYRTjGhZv475u5TcjZGKAjcscdgsETnb8yUcFpNkVRaKK40FJdBl6hQ5NvmqfROaAqHFuPKt)C1PpEs1L(XNf8zn9FTnb8yUcFpNkVvizgKCeIGKWGHKxBtapMRW3ZPY7kG(BCyBr)q97XfyVjF0GcFIMso9ZvN(4jvx6hFwWN10)12eWJ5k89CQ8wHKzqs9qeKegmK8ABc4XCf(EovExb0FJdBl6pDlE6Qcq6XeO)NvmapP)rLi0GcVWIso9ZvN(4jvx6hFwWN10pERPRfE8U30Qo4jyHG4szJzpxD6JN0FJdBl6xf7jc4(chqxtaKDmaYs2btdk8JgLC6NRo9XtQU0p(SGpRPF8UV5sO8Qypra3x4a6AcGSJ9yN(YzfsoGKcHKWGHKqwUtaowSTsHK6GKcreKegmKKyi512eWJ5k89CQ8hl2wPqYmiPw9GKWGHKcpsI3XC1v4jP5SUqYSijXqsIHKxBtapMRW3ZPYBfsMbjX7(MlHYRI9ebCFHdORjaYo2d5(EGJXo9LZGWezKegmKu4rYRTjGhZv475u55KMkuijXrYSijXqs8UV5sO8wnEjXGKUCbchgqWXcgewoF(JfBRuizgKeV7BUekVk2teW9foGUMai7ypK77bog70xodctKrsyWqYX9zD6J9o7Bcs6YfssCKK4izwKeV7BUekpKPcfyHaqUNg)XITvkKuNbKC0qYSij2XqYmdiPqizwKeV7BUekpbh7EwLdMxNVfqGBHD8hl2wPqsDgqsTcHKeN(BCyBr)Qypra3x4a6AcGSJPbfETeHso9ZvN(4jvx6hFwWN10pEhZvxHNKMZ6cjZIKedjtDHG8e4wWwkWcb2BYN3vascdgssmKeYYDcWXITvkKuhKeV7BUekpbUfSLcSqG9M85pwSTsHKWGHK4DFZLq5jWTGTuGfcS3Kp)XITvkKmdsI39nxcLxf7jc4(chqxtaKDShY99ahJD6lNbHjYijXrYSijE33CjuEitfkWcbGCpn(JfBRuiPodi5OHKzrsSJHKzgqsHqYSijE33CjuEco29SkhmVoFlGa3c74pwSTsHK6mGKAfcjjo934W2I(vXEIaUVWb01eazhtdk8A1sjN(BCyBr)UkgyblQOFU60hpP6sdk8AfIso9ZvN(4jvx6hFwWN10pKL7eGJfBRuizgKuREgnKegmKuah(KUCbchgqWXcgewoF(gh2ygjHbdjh3N1Pp27SVjiPlx0FJdBl6pwxSdyHaK6tSPbfETJqjN(5QtF8KQl9Jpl4ZA6hV7BUekVvJxsmiPlxGWHbeCSGbHLZN)yX2kfsMbjhHiijmyi54(So9XEN9nbjD5cjHbdjHSCNaCSyBLcj1bjfIi0FJdBl6p9T7ea5EAObfETcdLC6NRo9XtQU0p(SGpRPF8UV5sO8wnEjXGKUCbchgqWXcgewoF(JfBRuizgKCeIGKWGHKJ7Z60h7D23eK0LlKegmKeYYDcWXITvkKuhKuREO)gh2w0FkFk(izvonOWRvpuYP)gh2w0)ZYDcfiXCN5ICf0pxD6JNuDPbfETJkLC6NRo9XtQU0p(SGpRPF8UV5sO8wnEjXGKUCbchgqWXcgewoF(JfBRuizgKCeIGKWGHKJ7Z60h7D23eK0LlKegmKeYYDcWXITvkKuhKulrO)gh2w0pKDC6B3jnOWRnrtjN(5QtF8KQl9Jpl4ZA6hV7BUekVvJxsmiPlxGWHbeCSGbHLZN)yX2kfsMbjhHiijmyi54(So9XEN9nbjD5cjHbdjHSCNaCSyBLcj1bjfIi0FJdBl6VlmRIRFaC)E0GcVwHfLC6NRo9XtQU0p(SGpRP)uxiiVk2teW9foGUMai7y)Cju0FJdBl6pTZbleiodtsrdAq)tgQDFbLCk8APKt)noSTOFLaUpGtxtGkoJet)C1PpEs1Lgu4fIso9ZvN(4jvx6Ffq)koO)gh2w0)4(So9X0)4(5Y0pE33CjuERgVKyqsxUaHddi4ybdclNp)XITvkKmdscz5ob4yX2kfscdgscz5ob4yX2kfsQdsQviIGKzrsil3jahl2wPqYmijE33CjuEfFCzHg)XITvkKmlsI39nxcLxXhxwOXFSyBLcjZGKAjc9pUpq1Im97SVjiPlx0Gc)iuYPFU60hpP6s)4Zc(SM(jgsM6cb5v8XLfA8UcqsyWqYuxiiVk2teW9foGUMai7yVRaKK4izwKuah(KUCbchgqWXcgewoF(gh2ygjHbdjHSCNaCSyBLcj1zajhvIq)noSTOFbByBrdk8cdLC6NRo9XtQU0p(SGpRP)uxiiVIpUSqJ3va934W2I(X97bACyBbEMkO)NPcq1Im9R4Jll0qdk86Hso9ZvN(4jvx6hFwWN10FQleKNa3c2sbwiWEt(8UcO)gh2w0pUFpqJdBlWZub9)mvaQwKPFcClylfyHa7n5Jgu4hvk50pxD6JNuDPF8zbFwt)HjYiPoiPWGKzrsSJHK6GK6bjZIKcpskGdFsxUaHddi4ybdclNpFJdBmt)noSTOFC)EGgh2wGNPc6)zQauTit)RaU4Jgu4t0uYPFU60hpP6s)noSTOFitfGfceomGGJfmiSC(OF8zbFwt)yhZl2jrsIIKyhdjZmGKJGKzrsIHKCXxUgFyImiwGyNej1bj1IKWGHKCXxUgFyImiwGyNej1bjfgKmlsI39nxcLhYuHcSqai3tJ)yX2kfsQdsQ1RhKegmKeV7BUekpbUfSLcSqG9M85pwSTsHK6GKcHKeN(XAWpge9LZHIcVwAqHxyrjN(5QtF8KQl9Jpl4ZA6h7yEXojssuKe7yizMbKulsMfjjgsYfF5A8HjYGybIDsKuhKulscdgsI39nxcLxXhxwOXFSyBLcj1bjfcjHbdj5IVCn(WezqSaXojsQdskmizwKeV7BUekpKPcfyHaqUNg)XITvkKuhKuRxpijmyijE33CjuEcClylfyHa7n5ZFSyBLcj1bjfcjjo934W2I(5Kc4hWPprAqHF0OKt)C1PpEs1L(BCyBr)HLZhqq)ePF8zbFwt)4vmDbQ4msmsMfjXoMxStIKefjXogsMzajfcjZIKedj5IVCn(WezqSaXojsQdsQfjHbdjX7(MlHYR4Jll04pwSTsHK6GKcHKWGHKCXxUgFyImiwGyNej1bjfgKmlsI39nxcLhYuHcSqai3tJ)yX2kfsQdsQ1RhKegmKeV7BUekpbUfSLcSqG9M85pwSTsHK6GKcHKeN(XAWpge9LZHIcVwAqHxlrOKt)C1PpEs1L(XNf8zn9l8iz0pUcVIpUSqJNRo9Xt6VXHTf9J73d04W2c8mvq)ptfGQfz6hpbkgIgu41QLso9ZvN(4jvx6hFwWN10F0pUcVIpUSqJNRo9Xt6VXHTf9J73d04W2c8mvq)ptfGQfz6hpbk(4Ycn0GcVwHOKt)C1PpEs1L(XNf8zn934WgZaUyrJviPoi5i0FJdBl6h3VhOXHTf4zQG(FMkavlY0VkObfETJqjN(5QtF8KQl9Jpl4ZA6VXHnMbCXIgRqYmdi5i0FJdBl6h3VhOXHTf4zQG(FMkavlY0FVmnOb9l4y8kM2bLCk8APKt)noSTOFbByBr)C1PpEs1Lgu4fIso934W2I(t3iE8ea9An8KGv5GytAf9ZvN(4jvxAqHFek50pxD6JNuDP)va9R4G(BCyBr)J7Z60ht)J7Nlt)eH(h3hOArM(t6YfylGRIbXzfjoObfEHHso9ZvN(4jvx6hFwWN10VWJKr)4k8k(4YcnEU60hprsyWqsHhjJ(Xv4Hmvawiq4WacowWGWY5ZZvN(4j934W2I(Xogi19ubnOWRhk50pxD6JNuDPF8zbFwt)cpsg9JRWZfF5wIGv5a(zj5ZZvN(4j934W2I(XogGqpMPbnO)Ezk5u41sjN(BCyBr)eCS7zvoyED(wabUf2H(5QtF8KQlnOWleLC6NRo9XtQU0p(SGpRPFSJ5f7KijrrsSJHKzgqsHqYSijx8LRXhMidIfi2jrYmiPqijmyij2X8IDsKKOij2XqYmdiPWq)noSTOFU4l3seSkhWplPD0Gc)iuYPFU60hpP6s)4Zc(SM(XRy6cuXzKyKmlssmKm1fcYp7cZGfcGDSeZ8UcqsyWqYjN6cb5t3INUQaKEmbVRaKK40FJdBl6xjWQYQCa(6IbKmmjAqHxyOKt)C1PpEs1L(XNf8zn9ZfF5A8HjYGybIDsKmdsYjzSBWGWezKegmKe7yEXojssuKe7yiPodiPw6VXHTf9dzQqbwiaK7PHgu41dLC6NRo9XtQU0FJdBl6)mLv5aLBbizys0p(SGpRPFIHKr)4k8eCS7zvoyED(wabUf2XZvN(4jsMfjX7(MlHYFMYQCGYTaKmmj)096W2cjZGK4DFZLq5j4y3ZQCW868TacClSJ)yX2kfsQpskmijXrYSijXqs8UV5sO8qMkuGfca5EA8hl2wPqYmi5iijmyij2XqYmdiPEqsIt)yn4hdI(Y5qrHxlnOWpQuYPFU60hpP6s)4Zc(SM(tDHG8NRYXQCqI1tgqWQPFUek6VXHTf9FUkhRYbjwpzabRM0GcFIMso9ZvN(4jvx6hFwWN10pEftxGkoJeJKzrsIHKedjX7(MlHYNUfpDvbi9yc(JfBRuizgKuiKmlssmKe7yizgKCeKegmKeV7BUekpKPcfyHaqUNg)XITvkKmdsoQijXrYSijXqsSJHKzgqs9GKWGHK4DFZLq5HmvOaleaY904pwSTsHKzqsHqsIJKehjHbdj5IVCn(WezqSaXojsQZasocssC6VXHTf9ReyvzvoaFDXasgMenOWlSOKt)C1PpEs1L(XNf8zn9JDmVyNejjksIDmKmZasQL(BCyBr)Csb8d40NinOWpAuYPFU60hpP6s)noSTOFitfGfceomGGJfmiSC(OF8zbFwt)yhZl2jrsIIKyhdjZmGKJq)yn4hdI(Y5qrHxlnOWRLiuYPFU60hpP6s)4Zc(SM(XoMxStIKefjXogsMzajfI(BCyBr)yhdK6EQGgu41QLso9ZvN(4jvx6hFwWN10FQleKpCyalkGV9uaClOXwSNxfnMesMbj1oAizwKKl(Y14dtKbXce7KizgKKtYy3GbHjYijrrsTizwKeV7BUekpKPcfyHaqUNg)XITvkKmdsYjzSBWGWez6VXHTf9JVgt6zvoiX6jdEwUtuwLtdk8AfIso9ZvN(4jvx6VXHTf9hwoFab9tK(XNf8zn9JDmVyNejjksIDmKmZaskesMfjjgsk8iz0pUcVJfa8kMUEU60hprsyWqs8kMUavCgjgjjo9J1GFmi6lNdffET0GcV2rOKt)C1PpEs1L(XNf8zn9JxX0fOIZiX0FJdBl6h7yac9yMgu41kmuYPFU60hpP6s)noSTOFONgRYbk(eWvaizys0p(SGpRP)uxiiF6sci4wSFUek63QGVZvqq)APbfET6Hso9ZvN(4jvx6VXHTf9N(AmP1naKmmj6hFwWN10pEftxGkoJeJKzrsIHKPUqq(0LeqWTyVRaKegmKm6hxH3XcaEftxpxD6JNizwKuWXJb54PxRpSC(ac6NisMfjXogsoGKcHKzrs8UV5sO8qMkuGfca5EA8hl2wPqsDqYrqsyWqsSJ5f7KijrrsSJHK6mGKArYSiPGJhdYXtVwVsGvLv5a81fdizysizwKKl(Y14dtKbXce7KiPoi5iijXPFSg8JbrF5COOWRLg0Gg0)y(u2wu4fIicreTcjKq0pH(kRYv0FI0O0Om8jYWp6kCrsKKChgjnrb7fij0EiPEjWTGTuGfcS3Kp9IKhp64Ahprs1kYiz7gRyh8ejXoDLZkpcoHTvmsQv4IKjQTgZxWtKuVr)4k8jUErYyrs9g9JRWN4EU60hp1ls2bsMiokiSrsIPnjX9i4e2wXiPqcxKmrT1y(cEIK6n6hxHpX1lsglsQ3OFCf(e3ZvN(4PErYoqYeXrbHnssmTjjUhbNW2kgj1oQcxKmrT1y(cEIK6n6hxHpX1lsglsQ3OFCf(e3ZvN(4PErsIPnjX9i4qWLinknkdFIm8JUcxKejj3HrstuWEbscThsQxfFCzHg9IKhp64Ahprs1kYiz7gRyh8ejXoDLZkpcoHTvmsQvRWfjtuBnMVGNiPEJ(Xv4tC9IKXIK6n6hxHpX9C1PpEQxKSdKmrCuqyJKetBsI7rWHGlrAuAug(ez4hDfUijssUdJKMOG9cKeApKuVQqVi5XJoU2XtKuTIms2UXk2bprsStx5SYJGtyBfJKcJWfjtuBnMVGNiPEJ(Xv4tC9IKXIK6n6hxHpX9C1PpEQxKSdKmrCuqyJKetBsI7rWjSTIrYrv4IKjQTgZxWtKuVr)4k8jUErYyrs9g9JRWN4EU60hp1lssmTjjUhbNW2kgj1kmcxKmrT1y(cEIK6n6hxHpX1lsglsQ3OFCf(e3ZvN(4PErsIPnjX9i4qWLinknkdFIm8JUcxKejj3HrstuWEbscThsQ3jd1UVqVi5XJoU2XtKuTIms2UXk2bprsStx5SYJGtyBfJKAjIWfjtuBnMVGNiPEJ(Xv4tC9IKXIK6n6hxHpX9C1PpEQxKSdKmrCuqyJKetBsI7rWjSTIrsTAfUizIARX8f8ej1B0pUcFIRxKmwKuVr)4k8jUNRo9Xt9IKDGKjIJccBKKyAtsCpcoeCjsJsJYWNid)ORWfjrsYDyK0efSxGKq7HK6TxwVi5XJoU2XtKuTIms2UXk2bprsStx5SYJGtyBfJK6r4IKjQTgZxWtKuVr)4k8jUErYyrs9g9JRWN4EU60hp1lssmTjjUhbNW2kgj1kKWfjtuBnMVGNiPEJ(Xv4tC9IKXIK6n6hxHpX9C1PpEQxKKyAtsCpcoHTvmsQvpcxKmrT1y(cEIK6n6hxHpX1lsglsQ3OFCf(e3ZvN(4PErsIPnjX9i4qWLilkyVGNi5OHKnoSTqYNPcLhbh93UHZE0)3etu0VGBHSht)chizIKvtc9JeFiPW5BrcbNWbskCkJzXu(qsH0dziPqeriIGGdbNWbssobUjHKJIMkui5cHKJIUNgK0QGVZvqGKVn3WEeCi4eoqYeXKm2n4jsMYq7XijEft7ajt5CRuEKCucJzbHcjRTiQtFIqUpKSXHTLcj36PXJGRXHTLYl4y8kM2XGGnSTqW14W2s5fCmEft7q)Hes3iE8ea9An8KGv5GytAfcUgh2wkVGJXRyAh6pKW4(So9XKvTipK0LlWwaxfdIZksCq2kyqXbzJ7NlpqeeCnoSTuEbhJxX0o0FibSJbsDpvqMbni8r)4k8k(4YcnEU60hpHbt4J(Xv4Hmvawiq4WacowWGWY5ZZvN(4jcUgh2wkVGJXRyAh6pKa2Xae6Xmzg0GWh9JRWZfF5wIGv5a(zj5ZZvN(4jcoeCchizIysg7g8ej5X8PbjdtKrYWHrYgh7HKMcj7XT960h7rW14W2snOeW9bC6AcuXzKyeCnoSTu6pKW4(So9XKvTip4SVjiPlxKTcguCq24(5Yd4DFZLq5TA8sIbjD5ceomGGJfmiSC(8hl2wPYaz5ob4yX2kfmyqwUtaowSTsPJwHiswil3jahl2wPYG39nxcLxXhxwOXFSyBLklE33CjuEfFCzHg)XITvQmAjccUgh2wk9hsqWg2wKzqdel1fcYR4Jll04DfadwQleKxf7jc4(chqxtaKDS3vaXZkGdFsxUaHddi4ybdclNpFJdBmddgKL7eGJfBRu6mmQebbxJdBlL(djG73d04W2c8mvqw1I8GIpUSqdzg0qQleKxXhxwOX7kabxJdBlL(djG73d04W2c8mvqw1I8abUfSLcSqG9M8rMbnK6cb5jWTGTuGfcS3KpVRaeCnoSTu6pKaUFpqJdBlWZubzvlYdRaU4JmdAimrwhHjl2X0rpzfEbC4t6YfiCyabhlyqy585BCyJzeCnoSTu6pKaKPcWcbchgqWXcgewoFKH1GFmi6lNd1GwYmObSJ5f7Kef7yzggjlX4IVCn(WezqSaXoPoAHbJl(Y14dtKbXce7K6imzX7(MlHYdzQqbwiaK7PXFSyBLshTE9adgE33CjuEcClylfyHa7n5ZFSyBLshHiocUgh2wk9hsGtkGFaN(ejZGgWoMxStsuSJLzqBwIXfF5A8HjYGybIDsD0cdgE33CjuEfFCzHg)XITvkDecgmU4lxJpmrgelqStQJWKfV7BUekpKPcfyHaqUNg)XITvkD061dmy4DFZLq5jWTGTuGfcS3Kp)XITvkDeI4i4ACyBP0FiHWY5diOFIKH1GFmi6lNd1GwYmOb8kMUavCgjol2X8IDsIIDSmdcLLyCXxUgFyImiwGyNuhTWGH39nxcLxXhxwOXFSyBLshHGbJl(Y14dtKbXce7K6imzX7(MlHYdzQqbwiaK7PXFSyBLshTE9adgE33CjuEcClylfyHa7n5ZFSyBLshHiocUgh2wk9hsa3VhOXHTf4zQGSQf5b8eOyiYmObHp6hxHxXhxwObbxJdBlL(djG73d04W2c8mvqw1I8aEcu8XLfAiZGgI(Xv4v8XLfAqW14W2sP)qc4(9anoSTaptfKvTipOcYmOHgh2ygWflASsNrqW14W2sP)qc4(9anoSTaptfKvTip0ltMbn04WgZaUyrJvzggbbhcUgh2wkFV8abh7EwLdMxNVfqGBHDqW14W2s57L1FibU4l3seSkhWplPDKzqdyhZl2jjk2XYmiuwU4lxJpmrgelqStMriyWWoMxStsuSJLzqyqW14W2s57L1FibLaRkRYb4RlgqYWKiZGgWRy6cuXzK4Sel1fcYp7cZGfcGDSeZ8UcGbBYPUqq(0T4PRkaPhtW7kG4i4ACyBP89Y6pKaKPcfyHaqUNgYmObU4lxJpmrgelqStMHtYy3GbHjYWGHDmVyNKOyhtNbTi4ACyBP89Y6pKWzkRYbk3cqYWKidRb)yq0xohQbTKzqdel6hxHNGJDpRYbZRZ3ciWTWozX7(MlHYFMYQCGYTaKmmj)096W2kdE33CjuEco29SkhmVoFlGa3c74pwSTsPVWq8SedV7BUekpKPcfyHaqUNg)XITvQmJadg2XYmOhIJGRXHTLY3lR)qcNRYXQCqI1tgqWQjzg0qQleK)CvowLdsSEYacwn9ZLqHGRXHTLY3lR)qckbwvwLdWxxmGKHjrMbnGxX0fOIZiXzjgXW7(MlHYNUfpDvbi9yc(JfBRuzeklXWowMrGbdV7BUekpKPcfyHaqUNg)XITvQmJkXZsmSJLzqpWGH39nxcLhYuHcSqai3tJ)yX2kvgHioXHbJl(Y14dtKbXce7K6mmcXrW14W2s57L1FiboPa(bC6tKmdAa7yEXojrXowMbTi4ACyBP89Y6pKaKPcWcbchgqWXcgewoFKH1GFmi6lNd1GwYmObSJ5f7Kef7yzggbbxJdBlLVxw)HeWogi19ubzg0a2X8IDsIIDSmdcHGRXHTLY3lR)qc4RXKEwLdsSEYGNL7eLv5KzqdPUqq(WHbSOa(2tbWTGgBXEEv0ysz0oAz5IVCn(WezqSaXozgojJDdgeMituTzX7(MlHYdzQqbwiaK7PXFSyBLkdNKXUbdctKrW14W2s57L1FiHWY5diOFIKH1GFmi6lNd1GwYmObSJ5f7Kef7yzgeklXe(OFCfEhla4vmDHbdVIPlqfNrIjocUgh2wkFVS(djGDmaHEmtMbnGxX0fOIZiXi4ACyBP89Y6pKa0tJv5afFc4kaKmmjYmOHuxiiF6sci4wSFUekYSk47CfedArW14W2s57L1FiH0xJjTUbGKHjrgwd(XGOVCoudAjZGgWRy6cuXzK4Sel1fcYNUKacUf7Dfadw0pUcVJfa8kMUzfC8yqoE616dlNpGG(jMf7ydcLfV7BUekpKPcfyHaqUNg)XITvkDgbgmSJ5f7Kef7y6mOnRGJhdYXtVwVsGvLv5a81fdizysz5IVCn(WezqSaXoPoJqCeCi4ACyBP84jqXqdwnEjXGKUCbchgqWXcgewoFKzqdc)4(So9XEN9nbjD5cgmil3jahl2wP0ri9GGRXHTLYJNafdP)qc9H7IbXEhxbzg0a2X8IDsIIDSmdArW14W2s5XtGIH0FiHyDXoGfcm5oCiZGgsDHG8Qypra3x4a6AcGSJ9ZLqLvah(KUCbchgqWXcgewoF(gh2yggmil3jahl2wP0rlrGbdYYDcWXITvQmAfwebbxJdBlLhpbkgs)HeiWTGTuGfcS3KpYmObIDTnb8yUcFpNkVvzeg9ad212eWJ5k89CQ8UciEw8UV5sO8NPSkhOClajdtYFSyBLshojJDdgeMiJGRXHTLYJNafdP)qcqn)SIbQyffqMbnGxX0fOIZiXzj212eWJ5k89CQ8wLrlrGb7ABc4XCf(EovExbehbxJdBlLhpbkgs)HeG63JlWEt(iZGgU2MaEmxHVNtL3QmJqeyWU2MaEmxHVNtL3vacUgh2wkpEcumK(djKUfpDvbi9ycKzqdxBtapMRW3ZPYBvg9qeyWU2MaEmxHVNtL3vazpRyaEomQebbxJdBlLhpbkgs)HeuXEIaUVWb01eazhdGSKDWKzqd4TMUw4X7EtR6GNGfcIlLnM9C1PpEIGRXHTLYJNafdP)qcQypra3x4a6AcGSJjZGgW7(MlHYRI9ebCFHdORjaYo2JD6lNvdcbdgKL7eGJfBRu6ierGbJyxBtapMRW3ZPYFSyBLkJw9adMWJ3XC1v4jP5SUYsmIDTnb8yUcFpNkVvzW7(MlHYRI9ebCFHdORjaYo2d5(EGJXo9LZGWezyWe(RTjGhZv475u55KMkueplXW7(MlHYB14Leds6YfiCyabhlyqy585pwSTsLbV7BUekVk2teW9foGUMai7ypK77bog70xodctKHbBCFwN(yVZ(MGKUCrCINfV7BUekpKPcfyHaqUNg)XITvkDggTSyhlZGqzX7(MlHYtWXUNv5G515Bbe4wyh)XITvkDg0keXrW14W2s5XtGIH0FibvSNiG7lCaDnbq2XKzqd4DmxDfEsAoRRSel1fcYtGBbBPaleyVjFExbWGrmil3jahl2wP0bV7BUekpbUfSLcSqG9M85pwSTsbdgE33CjuEcClylfyHa7n5ZFSyBLkdE33CjuEvSNiG7lCaDnbq2XEi33dCm2PVCgeMit8S4DFZLq5HmvOaleaY904pwSTsPZWOLf7yzgeklE33CjuEco29SkhmVoFlGa3c74pwSTsPZGwHiocUgh2wkpEcumK(dj4QyGfSOcbxJdBlLhpbkgs)HeI1f7awiaP(eBYmObil3jahl2wPYOvpJgmyc4WN0Llq4WacowWGWY5Z34WgZWGnUpRtFS3zFtqsxUqW14W2s5XtGIH0FiH03UtaK7PHmdAaV7BUekVvJxsmiPlxGWHbeCSGbHLZN)yX2kvMricmyJ7Z60h7D23eK0LlyWGSCNaCSyBLshHiccUgh2wkpEcumK(djKYNIpswLtMbnG39nxcL3QXljgK0Llq4WacowWGWY5ZFSyBLkZiebgSX9zD6J9o7Bcs6YfmyqwUtaowSTsPJw9GGRXHTLYJNafdP)qcpl3juGeZDMlYvGGRXHTLYJNafdP)qcq2XPVDNKzqd4DFZLq5TA8sIbjD5ceomGGJfmiSC(8hl2wPYmcrGbBCFwN(yVZ(MGKUCbdgKL7eGJfBRu6OLii4ACyBP84jqXq6pKqxywfx)a4(9iZGgW7(MlHYB14Leds6YfiCyabhlyqy585pwSTsLzeIad24(So9XEN9nbjD5cgmil3jahl2wP0riIGGRXHTLYJNafdP)qcPDoyHaXzyskYmOHuxiiVk2teW9foGUMai7y)Cjui4qW14W2s5XtGIpUSqZW4(So9XKvTipO4Jll0asDpvq2kyqXbzJ7NlpG39nxcLxXhxwOXFSyBLshTWGjGdFsxUaHddi4ybdclNpFJdBmNfV7BUekVIpUSqJ)yX2kvMricmyqwUtaowSTsPJqebbxJdBlLhpbk(4Ycn6pKGvJxsmiPlxGWHbeCSGbHLZhzg0GWpUpRtFS3zFtqsxUGbdYYDcWXITvkDespi4ACyBP84jqXhxwOr)HeCvmWcwuHGRXHTLYJNafFCzHg9hsOpCxmi274kiZGgWoMxStsuSJLzqlcUgh2wkpEcu8XLfA0FiHNL7ekqI5oZf5kqW14W2s5XtGIpUSqJ(djazhN(2DsMbnmUpRtFSxXhxwObK6EQabxJdBlLhpbk(4Ycn6pKqxywfx)a4(9iZGgg3N1Pp2R4Jll0asDpvGGRXHTLYJNafFCzHg9hsiTZbleiodtsrMbnmUpRtFSxXhxwObK6EQabxJdBlLhpbk(4Ycn6pKqSUyhWcbMChoKzqdqwUtaowSTsLrRWIiWGjGdFsxUaHddi4ybdclNpFJdBmddgKL7eGJfBRu6OLii4ACyBP84jqXhxwOr)HeI1f7awiaP(eBYmObil3jahl2wPYmAebgmbC4t6YfiCyabhlyqy585BCyJzyWGSCNaCSyBLshTebbxJdBlLhpbk(4Ycn6pKabUfSLcSqG9M8rMbnG39nxcL)mLv5aLBbizys(JfBRu6WjzSBWGWezeCnoSTuE8eO4Jll0O)qcqn)SIbQyffGGRXHTLYJNafFCzHg9hsaQFpUa7n5dbxJdBlLhpbk(4Ycn6pKq6w80vfG0JjGGRXHTLYJNafFCzHg9hsqXhxwOHmdAaV7BUek)zkRYbk3cqYWK8hl2wP0riyWGSCNaCSyBLshT6bbxJdBlLhpbk(4Ycn6pKqANdwiqCgMKcbhcUgh2wk)kGl(gGmvawiq4WacowWGWY5JmSg8JbrFxohQbTKzqdyhZl2jjk2XYmmccUgh2wk)kGl(0FiboPa(bC6tKmdAi6hxHh7yGu3tfEU60hpZIDmVyNKOyhlZWii4ACyBP8RaU4t)HeclNpGG(jsgwd(XGOVCoudAjZGgWRy6cuXzK4SyhZl2jjk2XYmiecUgh2wk)kGl(0FibSJbi0JzYmObSJ5f7Kef7ydcHGRXHTLYVc4Ip9hsGtkGFaN(erW14W2s5xbCXN(djewoFab9tKmSg8JbrF5COg0sMbnGDmVyNKOyhlZGqi4qW14W2s5v8XLfAgGmvOaleaY90qMbnK6cb5v8XLfA8hl2wP0rlcUgh2wkVIpUSqJ(dj4QyGfSOcbxJdBlLxXhxwOr)HeucSQSkhGVUyajdtImdAaVIPlqfNrIZsSgh2ygWflASkZWiWG14WgZaUyrJvz0Mv4X7(MlHYFMYQCGYTaKmmjVRaIJGRXHTLYR4Jll0O)qcNPSkhOClajdtImSg8JbrF5COg0sMbnGxX0fOIZiXi4ACyBP8k(4Ycn6pKaKPcfyHaqUNgYmOHgh2ygWflASkZWii4ACyBP8k(4Ycn6pKGsGvLv5a81fdizysKzqd4vmDbQ4msC2uxii)Slmdwia2XsmZ7kabxJdBlLxXhxwOr)HesFnM06gasgMezyn4hdI(Y5qnOLmdAaVIPlqfNrIZM6cb5jWTGTuGfcS3KpabcExbzX7(MlHYFMYQCGYTaKmmj)XITvQmcHGRXHTLYR4Jll0O)qcqMkuGfca5EAiZQGVZvqamOHuxiiVIpUSqJ3vqw8UV5sO8NPSkhOClajdtYFCp1GGRXHTLYR4Jll0O)qckbwvwLdWxxmGKHjrMbnGxX0fOIZiXzNCQleKpDlE6Qcq6Xe8UcqW14W2s5v8XLfA0FibitfGfceomGGJfmiSC(idRb)yq0xohQbTKzqdyhtNrqW14W2s5v8XLfA0FiH0xJjTUbGKHjrgwd(XGOVCoudAjZGgWRy6cuXzKyyWe(OFCfEhla4vmDrW14W2s5v8XLfA0FibLaRkRYb4RlgqYWKqWHGRXHTLYRIbco29SkhmVoFlGa3c7qMbnCTnb8yUcFpNkVvzW7(MlHYtWXUNv5G515Bbe4wyh)096W2A0teVWcgSRTjGhZv475u5DfGGRXHTLYRc9hsGl(YTebRYb8ZsAhzg0a2X8IDsIIDSmdcLLl(Y14dtKbXce7KzgbgmSJ5f7Kef7yzgeMSeJl(Y14dtKbXce7KzecgmHxWXJb54PxRpSC(ac6NiXrW14W2s5vH(djOeyvzvoaFDXasgMezg0aEftxGkoJeNn1fcYp7cZGfcGDSeZ8UcYsSRTjGhZv475u5TktQleKF2fMblea7yjM5pwSTsruHGb7ABc4XCf(EovExbehbxJdBlLxf6pKWzkRYbk3cqYWKidRb)yq0xohQbTKzqd4DFZLq5v8XLfA8hl2wPYOfgmHp6hxHxXhxwObbxJdBlLxf6pKaKPcfyHaqUNgYmObIDTnb8yUcFpNkVvzW7(MlHYdzQqbwiaK7PXpDVoSTg9eXlSGb7ABc4XCf(EovExbeplX4IVCn(WezqSaXozgojJDdgeMituTWGHDmVyNKOyhtNbTWGL6cb5vXEIaUVWb01eazh7pwSTsPdNKXUbdctK1xlXHbdYYDcWXITvkD4Km2nyqyIS(ArW14W2s5vH(djGVgt6zvoiX6jdEwUtuwLtMbnK6cb5dhgWIc4Bpfa3cASf75vrJjLr7OLLl(Y14dtKbXce7Kz4Km2nyqyImr1MfV7BUek)zkRYbk3cqYWK8hl2wPYWjzSBWGWezyWsDHG8Hddyrb8TNcGBbn2I98QOXKYOvyYsm8UV5sO8k(4Ycn(JfBRu6ONSr)4k8k(4YcnWGH39nxcLNa3c2sbwiWEt(8hl2wP0rpzX7yU6k8K0CwxWGbz5ob4yX2kLo6H4i4ACyBP8Qq)HeoxLJv5GeRNmGGvtYmOHuxii)5QCSkhKy9KbeSA6NlHkBJdBmd4IfnwLrlcUgh2wkVk0FibitfGfceomGGJfmiSC(idRb)yq0xohQbTKzqdyhtNrqW14W2s5vH(djWjfWpGtFIKzqdyhZl2jjk2XYmOfbxJdBlLxf6pKa2XaPUNkiZGgWoMxStsuSJLzqB2gh2ygWflASAqB2RTjGhZv475u5TkJqebgmSJ5f7Kef7yzgekBJdBmd4IfnwLzqieCnoSTuEvO)qcyhdqOhZi4ACyBP8Qq)HeclNpGG(jsgwd(XGOVCoudAjJmdAaVIPlqfNrIZIDmVyNKOyhlZGqztDHG8Qypra3x4a6AcGSJ9ZLqHGRXHTLYRc9hsqjWQYQCa(6IbKmmjYmOHuxiip2XaCXxUgVkAmPmJqeIQNrFJdBmd4IfnwLn1fcYRI9ebCFHdORjaYo2pxcvwIH39nxcL)mLv5aLBbizys(JfBRuzeklE33CjuEitfkWcbGCpn(JfBRuzecgm8UV5sO8NPSkhOClajdtYFSyBLsNrYI39nxcLhYuHcSqai3tJ)yX2kvMrYIDSmJadgE33Cju(ZuwLduUfGKHj5pwSTsLzKS4DFZLq5HmvOaleaY904pwSTsPZizXowgHbgmSJ5f7Kef7y6mOnlx8LRXhMidIfi2j1riIddwQleKh7yaU4lxJxfnMugTejlKL7eGJfBRu6KOrW14W2s5vH(djK(AmP1naKmmjYWAWpge9LZHAqlzg0aEftxGkoJeNLyr)4k8k(4YcnzX7(MlHYR4Jll04pwSTsPZiWGH39nxcL)mLv5aLBbizys(JfBRuz0MfV7BUekpKPcfyHaqUNg)XITvQmAHbdV7BUek)zkRYbk3cqYWK8hl2wP0zKS4DFZLq5HmvOaleaY904pwSTsLzKSyhlJqWGH39nxcL)mLv5aLBbizys(JfBRuzgjlE33CjuEitfkWcbGCpn(JfBRu6mswSJLzeyWWowg9adwQleKpDjbeCl27kG4i4ACyBP8Qq)HeclNpGG(jsgwd(XGOVCoudAjJmdAaVIPlqfNrIZIDmVyNKOyhlZGqi4ACyBP8Qq)HeGEASkhO4taxbGKHjrMvbFNRGyqlcoHdKu4ekgj1DfojsAqi5O4okIKMcjXVvXizxtKuZ6IKo9ygjfcjXogs21ej1SUhs(AvGK5VnTFijHwHKKlCgzi5EiPbHKAwxKSpgj701nqYyrsClaj5IVCnizxtKKTWHpKuZ6Ei5RvbsMJNijHwHKKlCgsUhsAqiPM1fj7JrYhRuiz40fskesIDmKSj0AqsOBfrsClqGv5i4ACyBP8Qq)HesFnM06gasgMezyn4hdI(Y5qnOLmdAaVIPlqfNrIZI39nxcLhYuHcSqai3tJ)yX2kLoJKf7ydcLvWXJb54PxRpSC(ac6NywU4lxJpmrgelqperhTi4ACyBP8Qq)HesFnM06gasgMezyn4hdI(Y5qnOLmdAaVIPlqfNrIZYfF5A8HjYGybIDsDeklXWoMxStsuSJPZGwyWeC8yqoE616dlNpGG(jsCeCi4ACyBP8e4wWwkWcb2BY3aUFpqJdBlWZubzvlYd4jqXqKzqdcF0pUcVIpUSqdcUgh2wkpbUfSLcSqG9M8P)qc4(9anoSTaptfKvTipGNafFCzHgYmOHOFCfEfFCzHgeCnoSTuEcClylfyHa7n5t)He4IVClrWQCa)SK2rMbnGDmVyNKOyhlZGqz5IVCn(WezqSaXozMrqW14W2s5jWTGTuGfcS3Kp9hs4mLv5aLBbizysKH1GFmi6lNd1GweCnoSTuEcClylfyHa7n5t)HeucSQSkhGVUyajdtImdAaVIPlqfNrIZM6cb5NDHzWcbWowIzExbi4ACyBP8e4wWwkWcb2BYN(djazQqbwiaK7PHmdAOXHnMbCXIgRYmiu2uxiipbUfSLcSqG9M8biqWFSyBLshTi4ACyBP8e4wWwkWcb2BYN(djqWXUNv5G515Bbe4wyhYmOHgh2ygWflASkZGqi4ACyBP8e4wWwkWcb2BYN(djOeyvzvoaFDXasgMezg0aEftxGkoJeNTXHnMbCXIgRYmms2uxiipbUfSLcSqG9M8biqW7kabxJdBlLNa3c2sbwiWEt(0FiH0xJjTUbGKHjrgwd(XGOVCoudAjZGgWRy6cuXzK4SnoSXmGlw0yLodcHGRXHTLYtGBbBPaleyVjF6pKabh7EwLdMxNVfqGBHDqW14W2s5jWTGTuGfcS3Kp9hsaYuHcSqai3tdzwf8DUccGbnK6cb5jWTGTuGfcS3KpabcExbKzqdPUqqEvSNiG7lCaDnbq2XExbzV2MaEmxHVNtL3Qm4DFZLq5HmvOaleaY904NUxh2wJEI4hveCnoSTuEcClylfyHa7n5t)HeucSQSkhGVUyajdtImdAi1fcYJDmax8LRXRIgtkZieHO6z034WgZaUyrJvi4ACyBP8e4wWwkWcb2BYN(djazQaSqGWHbeCSGbHLZhzyn4hdI(Y5qnOLmdAa7y6mccUgh2wkpbUfSLcSqG9M8P)qcCsb8d40Nizg0a2X8IDsIIDSmdArW14W2s5jWTGTuGfcS3Kp9hsa7yGu3tfKzqdyhZl2jjk2XYmqmT634WgZaUyrJvz0sCeCnoSTuEcClylfyHa7n5t)HeclNpGG(jsgwd(XGOVCoudAjZGgiMWh9JRW7ybaVIPlmy4vmDbQ4msmXZIDmVyNKOyhlZGqi4ACyBP8e4wWwkWcb2BYN(djGDmaHEmJGRXHTLYtGBbBPaleyVjF6pKq6RXKw3aqYWKidRb)yq0xohQbTKzqdyhlZWiWGL6cb5jWTGTuGfcS3KpabcExbi4ACyBP8e4wWwkWcb2BYN(dja90yvoqXNaUcajdtImRc(oxbXGwAqdkf]] )

end