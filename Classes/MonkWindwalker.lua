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
    
    spec:RegisterPack( "Windwalker", 20210307, [[dOKw4bqisj5rIa0MuGpHO0OaKofGyvIa1Riv1SquDlef7IQ(Li0WaihJuSmcQNjQQPrkHRjcABIQuFtuLyCKsuNtufToakMhPu3tH2NOYbjLiwiPkpeGQUOOkPncqf(OiG6KKsKwjaEjavuZeGs3eGkYobu)ueiwQiG8uv1ujiFfGknwsj1Er6VGgmrhwQflspgQjROlJAZa9zrz0uXPPSArv41iYSvLBtODl53knCcCCrG0Yv55KmDHRtL2Uc67i04frNNuz9Iay(iy)qMQHke9p7GPalmGewdGYhq5fVWclmGewlO)qNaM(f0ysDgt)vlY0pGRvtI9JeF0VGw3B7jvi6xTUhMPF6p11EHwArtP)zhmfyHbKWAau(akV4fwyHbKM8K(vcymfyHZ78K(DS5KlAk9pzfM(bCTAsSFK4djbCAlsiaaCWPNBF6qsn5j5iPWasyniaqaierUjHKaomvOqYfejbC4E6qsRc(oxbbs(2md7raierUjHKFbwvwLHKa(RlgjbC2WKqY3Mzyp9)mvOOcr)RaU4JkefynuHOFU60hpP6r)noSTOFqtfWfegomKOJfmmSm(OF8zbFwt)yhZl2jrsYGKyhdjZnIK5t)yD4hdJ(Umou0VgAqbwyQq0pxD6JNu9OF8zbFwt)r)4k8yhdM6EQWZvN(4jsoajXoMxStIKKbjXogsMBejZN(BCyBr)Csb8d60NinOaNpvi6NRo9XtQE0FJdBl6pSm(Gc6Ni9Jpl4ZA6hVIPlufNrIrYbij2X8IDsKKmij2XqYCJiPW0pwh(XWOVmouuG1qdkWAbvi6NRo9XtQE0p(SGpRPFSJ5f7KijzqsSJHKJiPW0FJdBl6h7yqI9qMguGtivi6VXHTf9ZjfWpOtFI0pxD6JNu9Obf48Mke9ZvN(4jvp6VXHTf9hwgFqb9tK(XNf8zn9JDmVyNejjdsIDmKm3iskm9J1HFmm6lJdffyn0Gg0prUfSLcUGW9M8rfIcSgQq0pxD6JNu9OF8zbFwt)Afsg9JRWR4Jll055QtF8K(BCyBr)4(9GnoSTGptf0)ZubSArM(XtOIbPbfyHPcr)C1PpEs1J(XNf8zn9h9JRWR4Jll055QtF8K(BCyBr)4(9GnoSTGptf0)ZubSArM(XtOIpUSqhnOaNpvi6NRo9XtQE0p(SGpRPFSJ5f7KijzqsSJHK5grsHrYbijx8LPZhMidJfk2jrYCiz(0FJdBl6Nl(YSeaRYG8ZsAhnOaRfuHOFU60hpP6r)noSTO)ZuwLbvUfKKHjr)yD4hdJ(Y4qrbwdnOaNqQq0pxD6JNu9OF8zbFwt)4vmDHQ4msmsoajtDbb9ZUWmCbHyhlpmVRa6VXHTf9ReyvzvgeFDXqsgMenOaN3uHOFU60hpP6r)4Zc(SM(BCydzixSOXkKm3iskmsoajtDbb9e5wWwk4cc3BYhKir)XITvkKuBKud934W2I(bnvOGlie090rdkW5fQq0pxD6JNu9OF8zbFwt)noSHmKlw0yfsMBejfM(BCyBr)eDS7zvgCED2wqbUf2HguG1YuHOFU60hpP6r)4Zc(SM(XRy6cvXzKyKCas24WgYqUyrJvizUrKmFKCasM6cc6jYTGTuWfeU3KpirIExb0FJdBl6xjWQYQmi(6IHKmmjAqbopPcr)C1PpEs1J(BCyBr)PVgtADdijdtI(XNf8zn9JxX0fQIZiXi5aKSXHnKHCXIgRqsThrsHPFSo8JHrFzCOOaRHguG1aiQq0FJdBl6NOJDpRYGZRZ2ckWTWo0pxD6JNu9ObfynAOcr)C1PpEs1J(XNf8zn9N6cc6vXEIqUVWb21ecAh7DfGKdqYRTjKhYv475u5TcjZHK4DFZLy5bnvOGlie0905NUxh2wizcgjbKpVP)gh2w0pOPcfCbHGUNo63QGVZvqanq6p1fe0tKBbBPGliCVjFqIe9UcObfynctfI(5QtF8KQh9Jpl4ZA6p1fe0JDmix8LPZRIgtcjZHK5diKKmizcrYems24WgYqUyrJv0FJdBl6xjWQYQmi(6IHKmmjAqbwt(uHOFU60hpP6r)noSTOFqtfWfegomKOJfmmSm(OF8zbFwt)yhdj1gjZN(X6Wpgg9LXHIcSgAqbwJwqfI(5QtF8KQh9Jpl4ZA6h7yEXojssgKe7yizUrKud934W2I(5Kc4h0PprAqbwtcPcr)C1PpEs1J(XNf8zn9JDmVyNejjdsIDmKm3iscuKudsQps24WgYqUyrJvizoKudsce6VXHTf9JDmyQ7PcAqbwtEtfI(5QtF8KQh934W2I(dlJpOG(js)4Zc(SM(bksQviz0pUcVJfq8kMUEU60hprsceqs8kMUqvCgjgjbcsoajXoMxStIKKbjXogsMBejfM(X6Wpgg9LXHIcSgAqbwtEHke934W2I(XogKypKPFU60hpP6rdkWA0YuHOFU60hpP6r)noSTO)0xJjTUbKKHjr)4Zc(SM(XogsMBejZhjjqajtDbb9e5wWwk4cc3BYhKirVRa6hRd)yy0xghkkWAObfyn5jvi63QGVZvqq)AO)gh2w0p4tNvzqfFc4kGKmmj6NRo9XtQE0Gg0VIpUSqhvikWAOcr)C1PpEs1J(XNf8zn9N6cc6v8XLf68hl2wPqsTrsn0FJdBl6h0uHcUGqq3thnOalmvi6VXHTf97QyOfSOI(5QtF8KQhnOaNpvi6NRo9XtQE0p(SGpRPF8kMUqvCgjgjhGKafjBCydzixSOXkKm3isMpssGas24WgYqUyrJvizoKudsoaj1kKeV7BUel)zkRYGk3csYWK8UcqsGq)noSTOFLaRkRYG4RlgsYWKObfyTGke9ZvN(4jvp6VXHTf9FMYQmOYTGKmmj6hFwWN10pEftxOkoJet)yD4hdJ(Y4qrbwdnOaNqQq0pxD6JNu9OF8zbFwt)noSHmKlw0yfsMBejZN(BCyBr)GMkuWfec6E6Obf48Mke9ZvN(4jvp6hFwWN10pEftxOkoJeJKdqYuxqq)Slmdxqi2XYdZ7kG(BCyBr)kbwvwLbXxxmKKHjrdkW5fQq0pxD6JNu9O)gh2w0F6RXKw3asYWKOF8zbFwt)4vmDHQ4msmsoajtDbb9e5wWwk4cc3BYhKirVRaKCasI39nxIL)mLvzqLBbjzys(JfBRuizoKuy6hRd)yy0xghkkWAObfyTmvi63QGVZvqanq6p1fe0R4Jll05DfmaV7BUel)zkRYGk3csYWK8h3tD0FJdBl6h0uHcUGqq3th9ZvN(4jvpAqbopPcr)C1PpEs1J(XNf8zn9JxX0fQIZiXi5aKCYPUGG(0T4PRkGPht07kG(BCyBr)kbwvwLbXxxmKKHjrdkWAaevi6NRo9XtQE0FJdBl6h0ubCbHHddj6ybddlJp6hFwWN10p2XqsTrY8PFSo8JHrFzCOOaRHguG1OHke9ZvN(4jvp6VXHTf9N(AmP1nGKmmj6hFwWN10pEftxOkoJeJKeiGKAfsg9JRW7ybeVIPRNRo9Xt6hRd)yy0xghkkWAObfynctfI(BCyBr)kbwvwLbXxxmKKHjr)C1PpEs1Jg0G(XtOIpUSqhvikWAOcr)C1PpEs1J(xb0VId6VXHTf9pSpRtFm9pSFUm9J39nxILxXhxwOZFSyBLcj1gj1GKeiGKc4WN0Lly4WqIowWWWY4Z34WgYi5aKeV7BUelVIpUSqN)yX2kfsMdjZhqijbcijOL5eWJfBRuiP2iPWaI(h2hSArM(v8XLf6GPUNkObfyHPcr)C1PpEs1J(XNf8zn9Rvi5W(So9XEN9nHjD5cjjqajbTmNaESyBLcj1gjfoH0FJdBl63QHljgM0LlAqboFQq0FJdBl63vXqlyrf9ZvN(4jvpAqbwlOcr)C1PpEs1J(XNf8zn9JDmVyNejjdsIDmKm3isQH(BCyBr)9H7IHXEhxbnOaNqQq0FJdBl6)zzoHcMhUZmrUc6NRo9XtQE0GcCEtfI(5QtF8KQh9Jpl4ZA6FyFwN(yVIpUSqhm19ub934W2I(bTJtF7oPbf48cvi6NRo9XtQE0p(SGpRP)H9zD6J9k(4YcDWu3tf0FJdBl6VlmRIRFqC)E0GcSwMke9ZvN(4jvp6hFwWN10)W(So9XEfFCzHoyQ7Pc6VXHTf9N2zWfegNHjPObf48Kke9ZvN(4jvp6hFwWN10pOL5eWJfBRuizoKeOiPgTmGqsYGKNBXG7LXEWo6hmwxSJNRo9XtKmbJKAegqijqqsceqsbC4t6YfmCyirhlyyyz85BCydzKKabKe0YCc4XITvkKuBKudGO)gh2w0FSUyh4ccNCho0GcSgarfI(5QtF8KQh9Jpl4ZA6h0YCc4XITvkKmhsMNacjjqajfWHpPlxWWHHeDSGHHLXNVXHnKrsceqsqlZjGhl2wPqsTrsnaI(BCyBr)X6IDGliKuFInnOaRrdvi6NRo9XtQE0p(SGpRPF8UV5sS8NPSkdQClijdtYFSyBLcj1gj5Km2nyyyIm934W2I(jYTGTuWfeU3KpAqbwJWuHO)gh2w0pyZpRyOkwrb0pxD6JNu9Obfyn5tfI(BCyBr)G97XfCVjF0pxD6JNu9ObfynAbvi6VXHTf9NUfpDvbm9yI0pxD6JNu9ObfynjKke9ZvN(4jvp6hFwWN10pE33Cjw(ZuwLbvUfKKHj5pwSTsHKAJKcJKeiGKGwMtapwSTsHKAJKAsi934W2I(v8XLf6Obfyn5nvi6VXHTf9N2zWfegNHjPOFU60hpP6rdAq)QGkefynuHOFU60hpP6r)4Zc(SM(V2MqEixHVNtL3kKmhsI39nxILNOJDpRYGZRZ2ckWTWo(P71HTfsMGrsa51Yijbci512eYd5k89CQ8UcO)gh2w0prh7EwLbNxNTfuGBHDObfyHPcr)C1PpEs1J(XNf8zn9JDmVyNejjdsIDmKm3iskmsoaj5IVmD(WezySqXojsMdjZhjjqajXoMxStIKKbjXogsMBej1cKCascuKKl(Y05dtKHXcf7KizoKuyKKabKuRqsbhpeMHNEn(WY4dkOFIijqO)gh2w0px8LzjawLb5NL0oAqboFQq0pxD6JNu9OF8zbFwt)4vmDHQ4msmsoajtDbb9ZUWmCbHyhlpmVRaKCascuK8ABc5HCf(EovERqYCizQliOF2fMHlie7y5H5pwSTsHKKbjfgjjqajV2MqEixHVNtL3vasce6VXHTf9ReyvzvgeFDXqsgMenOaRfuHOFU60hpP6r)noSTO)ZuwLbvUfKKHjr)4Zc(SM(X7(MlXYR4Jll05pwSTsHK5qsnijbciPwHKr)4k8k(4YcDEU60hpPFSo8JHrFzCOOaRHguGtivi6NRo9XtQE0p(SGpRPFGIKxBtipKRW3ZPYBfsMdjX7(MlXYdAQqbxqiO7PZpDVoSTqYemsciVwgjjqajV2MqEixHVNtL3vasceKCascuKKl(Y05dtKHXcf7KizoKKtYy3GHHjYijzqsnijbcij2X8IDsKKmij2XqsThrsnijbcizQliOxf7jc5(chyxtiODS)yX2kfsQnsYjzSBWWWezKuFKudsceKKabKe0YCc4XITvkKuBKKtYy3GHHjYiP(iPg6VXHTf9dAQqbxqiO7PJguGZBQq0pxD6JNu9OF8zbFwt)PUGG(WHHSOa(2tbXTGgBXEEv0ysizoKutEIKdqsU4ltNpmrggluStIK5qsojJDdggMiJKKbj1GKdqs8UV5sS8NPSkdQClijdtYFSyBLcjZHKCsg7gmmmrgjjqajtDbb9Hddzrb8TNcIBbn2I98QOXKqYCiPgTajhGKafjX7(MlXYR4Jll05pwSTsHKAJKjejhGKr)4k8k(4YcDEU60hprsceqs8UV5sS8e5wWwk4cc3BYN)yX2kfsQnsMqKCasI3HC1v4jP7SUqsceqsqlZjGhl2wPqsTrYeIKaH(BCyBr)4RXKEwLbZJEYWNL5eLvz0GcCEHke9ZvN(4jvp6hFwWN10FQliO)CvowLbZJEYqIwn9ZLyHKdqYgh2qgYflAScjZHKAO)gh2w0)5QCSkdMh9KHeTAsdkWAzQq0pxD6JNu9O)gh2w0pOPc4ccdhgs0XcggwgF0p(SGpRPFSJHKAJK5t)yD4hdJ(Y4qrbwdnOaNNuHOFU60hpP6r)4Zc(SM(XoMxStIKKbjXogsMBej1q)noSTOFoPa(bD6tKguG1aiQq0pxD6JNu9OF8zbFwt)yhZl2jrsYGKyhdjZnIKAqYbizJdBid5IfnwHKJiPgKCasETnH8qUcFpNkVvizoKuyaHKeiGKyhZl2jrsYGKyhdjZnIKcJKdqYgh2qgYflAScjZnIKct)noSTOFSJbtDpvqdkWA0qfI(BCyBr)yhdsShY0pxD6JNu9ObfynctfI(5QtF8KQh934W2I(dlJpOG(js)4Zc(SM(XRy6cvXzKyKCasIDmVyNejjdsIDmKm3iskmsoajtDbb9Qypri3x4a7AcbTJ9ZLyr)yD4hdJ(Y4qrbwdnOaRjFQq0pxD6JNu9OF8zbFwt)PUGGESJb5IVmDEv0ysizoKmFaHKKbjtisMGrYgh2qgYflAScjhGKPUGGEvSNiK7lCGDnHG2X(5sSqYbijqrs8UV5sS8NPSkdQClijdtYFSyBLcjZHKcJKdqs8UV5sS8GMkuWfec6E68hl2wPqYCiPWijbcijE33Cjw(ZuwLbvUfKKHj5pwSTsHKAJK5JKdqs8UV5sS8GMkuWfec6E68hl2wPqYCiz(i5aKe7yizoKmFKKabKeV7BUel)zkRYGk3csYWK8hl2wPqYCiz(i5aKeV7BUelpOPcfCbHGUNo)XITvkKuBKmFKCasIDmKmhsQfijbcij2X8IDsKKmij2XqsThrsni5aKKl(Y05dtKHXcf7KiP2iPWijqqsceqYuxqqp2XGCXxMoVkAmjKmhsQbqi5aKe0YCc4XITvkKuBKmVq)noSTOFLaRkRYG4RlgsYWKObfynAbvi6NRo9XtQE0FJdBl6p91ysRBajzys0p(SGpRPF8kMUqvCgjgjhGKafjJ(Xv4v8XLf68C1PpEIKdqs8UV5sS8k(4YcD(JfBRuiP2iz(ijbcijE33Cjw(ZuwLbvUfKKHj5pwSTsHK5qsni5aKeV7BUelpOPcfCbHGUNo)XITvkKmhsQbjjqajX7(MlXYFMYQmOYTGKmmj)XITvkKuBKmFKCasI39nxILh0uHcUGqq3tN)yX2kfsMdjZhjhGKyhdjZHKcJKeiGK4DFZLy5ptzvgu5wqsgMK)yX2kfsMdjZhjhGK4DFZLy5bnvOGlie0905pwSTsHKAJK5JKdqsSJHK5qY8rsceqsSJHK5qYeIKeiGKPUGG(0LeuWTyVRaKei0pwh(XWOVmouuG1qdkWAsivi6NRo9XtQE0FJdBl6pSm(Gc6Ni9Jpl4ZA6hVIPlufNrIrYbij2X8IDsKKmij2XqYCJiPW0pwh(XWOVmouuG1qdkWAYBQq0VvbFNRGG(1q)noSTOFWNoRYGk(eWvajzys0pxD6JNu9Obfyn5fQq0pxD6JNu9O)gh2w0F6RXKw3asYWKOF8zbFwt)4vmDHQ4msmsoajX7(MlXYdAQqbxqiO7PZFSyBLcj1gjZhjhGKyhdjhrsHrYbiPGJhcZWtVgFyz8bf0prKCasYfFz68HjYWyHjeqiP2iPg6hRd)yy0xghkkWAObfynAzQq0pxD6JNu9O)gh2w0F6RXKw3asYWKOF8zbFwt)4vmDHQ4msmsoaj5IVmD(WezySqXojsQnskmsoajbksIDmVyNejjdsIDmKu7rKudssGask44HWm80RXhwgFqb9tejbc9J1HFmm6lJdffyn0Gg0pEcvmivikWAOcr)C1PpEs1J(XNf8zn9Rvi5W(So9XEN9nHjD5cjjqajbTmNaESyBLcj1gjfoH0FJdBl63QHljgM0LlAqbwyQq0pxD6JNu9OF8zbFwt)yhZl2jrsYGKyhdjZnIKAO)gh2w0FF4UyyS3XvqdkW5tfI(5QtF8KQh9Jpl4ZA6h0YCc4XITvkKmhscuKuJwgqijzqYZTyW9Yypyh9dgRl2XZvN(4jsMGrsncdiKeiijbcizQliOxf7jc5(chyxtiODSFUelKCaskGdFsxUGHddj6ybddlJpFJdBiJKeiGKGwMtapwSTsHKAJKAae934W2I(J1f7axq4K7WHguG1cQq0pxD6JNu9OF8zbFwt)afjV2MqEixHVNtL3kKmhsQfjejjqajV2MqEixHVNtL3vasceKCasI39nxIL)mLvzqLBbjzys(JfBRuiP2ijNKXUbddtKP)gh2w0prUfSLcUGW9M8rdkWjKke9ZvN(4jvp6hFwWN10pEftxOkoJeJKdqsGIKxBtipKRW3ZPYBfsMdj1aiKKabK8ABc5HCf(EovExbijqO)gh2w0pyZpRyOkwrb0GcCEtfI(5QtF8KQh9Jpl4ZA6)ABc5HCf(EovERqYCiz(acjjqajV2MqEixHVNtL3va934W2I(b73Jl4Et(Obf48cvi6NRo9XtQE0p(SGpRP)RTjKhYv475u5TcjZHKjeqijbci512eYd5k89CQ8UcO)gh2w0F6w80vfW0Jjs)pRyiEs)5nGObfyTmvi6NRo9XtQE0p(SGpRPF8wtxl84DVPvDWt4ccYLYgYEU60hpP)gh2w0Vk2teY9foWUMqq7yiOLSdMguGZtQq0pxD6JNu9OF8zbFwt)4DFZLy5vXEIqUVWb21ecAh7Xo9LXkKCejfgjjqajbTmNaESyBLcj1gjfgqijbcijqrYRTjKhYv475u5pwSTsHK5qsnjejjqaj1kKeVd5QRWts3zDHKdqsGIKafjV2MqEixHVNtL3kKmhsI39nxILxf7jc5(chyxtiODSh099GhJD6lJHHjYijbciPwHKxBtipKRW3ZPYZjnvOqsGGKdqsGIK4DFZLy5TA4sIHjD5cgomKOJfmmSm(8hl2wPqYCijE33CjwEvSNiK7lCGDnHG2XEq33dEm2PVmggMiJKeiGKd7Z60h7D23eM0LlKeiijqqYbijE33CjwEqtfk4ccbDpD(JfBRuiP2JizEIKdqsSJHK5grsHrYbijE33CjwEIo29SkdoVoBlOa3c74pwSTsHKApIKAegjbc934W2I(vXEIqUVWb21ecAhtdkWAaevi6NRo9XtQE0p(SGpRPF8oKRUcpjDN1fsoajbksM6cc6jYTGTuWfeU3KpVRaKKabKeOijOL5eWJfBRuiP2ijE33CjwEIClylfCbH7n5ZFSyBLcjjqajX7(MlXYtKBbBPGliCVjF(JfBRuizoKeV7BUelVk2teY9foWUMqq7ypO77bpg70xgddtKrsGGKdqs8UV5sS8GMkuWfec6E68hl2wPqsThrY8ejhGKyhdjZnIKcJKdqs8UV5sS8eDS7zvgCED2wqbUf2XFSyBLcj1Eej1imsce6VXHTf9RI9eHCFHdSRje0oMguG1OHke934W2I(Dvm0cwur)C1PpEs1JguG1imvi6NRo9XtQE0p(SGpRPFqlZjGhl2wPqYCiPMeMNijbciPao8jD5cgomKOJfmmSm(8noSHmssGasoSpRtFS3zFtysxUO)gh2w0FSUyh4ccj1NytdkWAYNke9ZvN(4jvp6hFwWN10pE33CjwERgUKyysxUGHddj6ybddlJp)XITvkKmhsMpGqsceqYH9zD6J9o7Bct6YfssGascAzob8yX2kfsQnskmGO)gh2w0F6B3je090rdkWA0cQq0pxD6JNu9OF8zbFwt)4DFZLy5TA4sIHjD5cgomKOJfmmSm(8hl2wPqYCiz(acjjqajh2N1Pp27SVjmPlxijbcijOL5eWJfBRuiP2iPMes)noSTO)u(u8rYQmAqbwtcPcr)noSTO)NL5ekyE4oZe5kOFU60hpP6rdkWAYBQq0pxD6JNu9OF8zbFwt)4DFZLy5TA4sIHjD5cgomKOJfmmSm(8hl2wPqYCiz(acjjqajh2N1Pp27SVjmPlxijbcijOL5eWJfBRuiP2iPgar)noSTOFq7403UtAqbwtEHke9ZvN(4jvp6hFwWN10pE33CjwERgUKyysxUGHddj6ybddlJp)XITvkKmhsMpGqsceqYH9zD6J9o7Bct6YfssGascAzob8yX2kfsQnskmGO)gh2w0Fxywfx)G4(9ObfynAzQq0pxD6JNu9OF8zbFwt)PUGGEvSNiK7lCGDnHG2X(5sSO)gh2w0FANbxqyCgMKIg0G(Nmy7(cQquG1qfI(5QtF8KQh9pzf(mbHTf9NxtYy3GNijpKpDizyImsgoms24ypK0uizpSTxN(yp934W2I(vc4(GoDnHQ4msmnOalmvi6NRo9XtQE0)kG(vCq)noSTO)H9zD6JP)H9ZLPF8UV5sS8wnCjXWKUCbdhgs0XcggwgF(JfBRuizoKe0YCc4XITvkKKabKe0YCc4XITvkKuBKuJWacjhGKGwMtapwSTsHK5qs8UV5sS8k(4YcD(JfBRui5aKeV7BUelVIpUSqN)yX2kfsMdj1ai6FyFWQfz63zFtysxUObf48Pcr)C1PpEs1J(XNf8zn9duKm1fe0R4Jll05DfGKeiGKPUGGEvSNiK7lCGDnHG2XExbijqqYbiPao8jD5cgomKOJfmmSm(8noSHmssGascAzob8yX2kfsQ9isM3aI(BCyBr)c2W2IguG1cQq0pxD6JNu9OF8zbFwt)PUGGEfFCzHoVRa6VXHTf9J73d24W2c(mvq)ptfWQfz6xXhxwOJguGtivi6NRo9XtQE0p(SGpRP)uxqqprUfSLcUGW9M85Dfq)noSTOFC)EWgh2wWNPc6)zQawTit)e5wWwk4cc3BYhnOaN3uHOFU60hpP6r)4Zc(SM(dtKrsTrsTajhGKyhdj1gjtisoaj1kKuah(KUCbdhgs0XcggwgF(gh2qM(BCyBr)4(9GnoSTGptf0)ZubSArM(xbCXhnOaNxOcr)C1PpEs1J(BCyBr)GMkGlimCyirhlyyyz8r)4Zc(SM(XoMxStIKKbjXogsMBejZhjhGKafj5IVmD(WezySqXojsQnsQbjjqaj5IVmD(WezySqXojsQnsQfi5aKeV7BUelpOPcfCbHGUNo)XITvkKuBKuJpHijbcijE33CjwEIClylfCbH7n5ZFSyBLcj1gjfgjbc9J1HFmm6lJdffyn0GcSwMke9ZvN(4jvp6hFwWN10p2X8IDsKKmij2XqYCJiPgKCascuKKl(Y05dtKHXcf7KiP2iPgKKabKeV7BUelVIpUSqN)yX2kfsQnskmssGasYfFz68HjYWyHIDsKuBKulqYbijE33CjwEqtfk4ccbDpD(JfBRuiP2iPgFcrsceqs8UV5sS8e5wWwk4cc3BYN)yX2kfsQnskmsce6VXHTf9ZjfWpOtFI0GcCEsfI(5QtF8KQh934W2I(dlJpOG(js)4Zc(SM(XRy6cvXzKyKCasIDmVyNejjdsIDmKm3iskmsoajbksYfFz68HjYWyHIDsKuBKudssGasI39nxILxXhxwOZFSyBLcj1gjfgjjqaj5IVmD(WezySqXojsQnsQfi5aKeV7BUelpOPcfCbHGUNo)XITvkKuBKuJpHijbcijE33CjwEIClylfCbH7n5ZFSyBLcj1gjfgjbc9J1HFmm6lJdffyn0GcSgarfI(5QtF8KQh9Jpl4ZA6xRqYOFCfEfFCzHopxD6JN0FJdBl6h3VhSXHTf8zQG(FMkGvlY0pEcvminOaRrdvi6NRo9XtQE0p(SGpRP)OFCfEfFCzHopxD6JN0FJdBl6h3VhSXHTf8zQG(FMkGvlY0pEcv8XLf6ObfynctfI(5QtF8KQh9Jpl4ZA6VXHnKHCXIgRqsTrY8P)gh2w0pUFpyJdBl4Zub9)mvaRwKPFvqdkWAYNke9ZvN(4jvp6hFwWN10FJdBid5IfnwHK5grY8P)gh2w0pUFpyJdBl4Zub9)mvaRwKP)EzAqd6xWX4vmTdQquG1qfI(5QtF8KQh9pzf(mbHTf9NxtYy3GNizkdUhJK4vmTdKmLZSs5rsTemMfekKS2Imo9jc6(qYgh2wkKCRNop934W2I(fSHTfnOalmvi6VXHTf9NUr84je8164jrRYGXM0k6NRo9XtQE0GcC(uHOFU60hpP6r)Ra6xXb934W2I(h2N1PpM(h2pxM(be9pSpy1Im9N0Ll4wqxfdJZksCqdkWAbvi6NRo9XtQE0p(SGpRPFTcjJ(Xv4v8XLf68C1PpEIKeiGKAfsg9JRWdAQaUGWWHHeDSGHHLXNNRo9Xt6VXHTf9JDmyQ7PcAqboHuHOFU60hpP6r)4Zc(SM(1kKm6hxHNl(YSeaRYG8ZsYNNRo9Xt6VXHTf9JDmiXEitdAq)9YuHOaRHke934W2I(j6y3ZQm486STGcClSd9ZvN(4jvpAqbwyQq0pxD6JNu9OF8zbFwt)yhZl2jrsYGKyhdjZnIKcJKdqsU4ltNpmrggluStIK5qsHrsceqsSJ5f7KijzqsSJHK5grsTG(BCyBr)CXxMLayvgKFws7Obf48Pcr)C1PpEs1J(XNf8zn9JxX0fQIZiXi5aKeOizQliOF2fMHlie7y5H5DfGKeiGKto1fe0NUfpDvbm9yIExbijqO)gh2w0VsGvLvzq81fdjzys0GcSwqfI(5QtF8KQh9Jpl4ZA6Nl(Y05dtKHXcf7KizoKKtYy3GHHjYijbcij2X8IDsKKmij2XqsThrsn0FJdBl6h0uHcUGqq3thnOaNqQq0pxD6JNu9O)gh2w0)zkRYGk3csYWKOF8zbFwt)afjJ(Xv4j6y3ZQm486STGcClSJNRo9XtKCasI39nxIL)mLvzqLBbjzys(P71HTfsMdjX7(MlXYt0XUNvzW51zBbf4wyh)XITvkKuFKulqsGGKdqsGIK4DFZLy5bnvOGlie0905pwSTsHK5qY8rsceqsSJHK5grYeIKaH(X6Wpgg9LXHIcSgAqboVPcr)C1PpEs1J(XNf8zn9N6cc6pxLJvzW8ONmKOvt)Cjw0FJdBl6)CvowLbZJEYqIwnPbf48cvi6NRo9XtQE0p(SGpRPF8kMUqvCgjgjhGKafjbksI39nxILpDlE6Qcy6Xe9hl2wPqYCiPWi5aKeOij2XqYCiz(ijbcijE33CjwEqtfk4ccbDpD(JfBRuizoKmVrsGGKdqsGIKyhdjZnIKjejjqajX7(MlXYdAQqbxqiO7PZFSyBLcjZHKcJKabjbcssGasQvijEhYvxHVy8TV9Mi5aKKl(Y05dtKHXcf7KizoKmdprsGq)noSTOFLaRkRYG4RlgsYWKObfyTmvi6NRo9XtQE0p(SGpRPFSJ5f7KijzqsSJHK5grsn0FJdBl6NtkGFqN(ePbf48Kke9ZvN(4jvp6VXHTf9dAQaUGWWHHeDSGHHLXh9Jpl4ZA6h7yEXojssgKe7yizUrKmF6hRd)yy0xghkkWAObfynaIke9ZvN(4jvp6hFwWN10p2X8IDsKKmij2XqYCJiPW0FJdBl6h7yWu3tf0GcSgnuHOFU60hpP6r)4Zc(SM(tDbb9Hddzrb8TNcIBbn2I98QOXKqYCiPM8ejhGKCXxMoFyImmwOyNejZHKCsg7gmmmrgjjdsQbjhGK4DFZLy5bnvOGlie0905pwSTsHK5qsojJDdggMit)noSTOF81yspRYG5rpz4ZYCIYQmAqbwJWuHOFU60hpP6r)noSTO)WY4dkOFI0p(SGpRPFSJ5f7KijzqsSJHK5grsHrYbijqrsTcjJ(Xv4DSaIxX01ZvN(4jssGasIxX0fQIZiXijqOFSo8JHrFzCOOaRHguG1Kpvi6NRo9XtQE0FJdBl6xjWQYQmi(6IHKmmj6FYk8zccBl6hW3pS7RdEIK)4msSI(XNf8zn9JxX0fQIZiXi5aKeV101cpUFy3xh8eQIZiXkpxD6JN0GcSgTGke9ZvN(4jvp6hFwWN10pEftxOkoJet)noSTOFSJbj2dzAqbwtcPcr)C1PpEs1J(BCyBr)GpDwLbv8jGRasYWKOF8zbFwt)PUGG(0LeuWTy)Cjw0VvbFNRGG(1qdkWAYBQq0pxD6JNu9O)gh2w0F6RXKw3asYWKOF8zbFwt)4vmDHQ4msmsoajbksM6cc6txsqb3I9UcqsceqYOFCfEhlG4vmD9C1PpEIKdqsbhpeMHNEn(WY4dkOFIi5aKe7yi5iskmsoajX7(MlXYdAQqbxqiO7PZFSyBLcj1gjZhjjqajXoMxStIKKbjXogsQ9isQbjhGKcoEimdp9A8kbwvwLbXxxmKKHjHKdqsU4ltNpmrggluStIKAJK5JKaH(X6Wpgg9LXHIcSgAqdAq)d5tzBrbwyajSgaPryHPFI9vwLPOFaxTKeiG1sbobgWGKiPqomsAIc2lqsW9qsYsKBbBPGliCVjFKfjpob11oEIKQvKrY2nwXo4jsID6kJvEeaawRyKudGbjb8BnKVGNijzJ(Xv41AYIKXIKKn6hxHxR9C1PpEswKSdKmVMGayrsGQjjq8iaaSwXiPWagKeWV1q(cEIKKn6hxHxRjlsglss2OFCfET2ZvN(4jzrYoqY8AccGfjbQMKaXJaaWAfJKAYBadsc43AiFbprsYg9JRWR1KfjJfjjB0pUcVw75QtF8KSijq1KeiEeaiaaC1ssGawlf4eyadsIKc5WiPjkyVajb3djjRIpUSqhzrYJtqDTJNiPAfzKSDJvSdEIKyNUYyLhbaG1kgj1ObWGKa(TgYxWtKKSr)4k8AnzrYyrsYg9JRWR1EU60hpjls2bsMxtqaSijq1KeiEeaiaaC1ssGawlf4eyadsIKc5WiPjkyVajb3djjlEcv8XLf6ilsECcQRD8ejvRiJKTBSIDWtKe70vgR8iaaSwXizEcyqsa)wd5l4jss2ZTyW9YyVwtwKmwKKSNBXG7LXET2ZvN(4jzrsGQjjq8iaqaa4QLKabSwkWjWagKejfYHrstuWEbscUhsswvqwK84eux74jsQwrgjB3yf7GNij2PRmw5raayTIrsTaWGKa(TgYxWtKKSr)4k8AnzrYyrsYg9JRWR1EU60hpjls2bsMxtqaSijq1KeiEeaawRyKmVbmijGFRH8f8ejjB0pUcVwtwKmwKKSr)4k8ATNRo9XtYIKavtsG4raayTIrsnAbGbjb8BnKVGNijzJ(Xv41AYIKXIKKn6hxHxR9C1PpEswKeOAscepcaeaaUAjjqaRLcCcmGbjrsHCyK0efSxGKG7HKKfpHkgKSi5XjOU2XtKuTIms2UXk2bprsStxzSYJaaWAfJK5dyqsa)wd5l4jss2ZTyW9YyVwtwKmwKKSNBXG7LXET2ZvN(4jzrsGQjjq8iaqaa4QLKabSwkWjWagKejfYHrstuWEbscUhss2jd2UVGSi5XjOU2XtKuTIms2UXk2bprsStxzSYJaaWAfJKAaeGbjb8BnKVGNijzJ(Xv41AYIKXIKKn6hxHxR9C1PpEswKSdKmVMGayrsGQjjq8iaaSwXiPgnagKeWV1q(cEIKKn6hxHxRjlsglss2OFCfET2ZvN(4jzrYoqY8AccGfjbQMKaXJaabaGRwsceWAPaNadyqsKuihgjnrb7fij4Eijz7LjlsECcQRD8ejvRiJKTBSIDWtKe70vgR8iaaSwXizcbmijGFRH8f8ejjB0pUcVwtwKmwKKSr)4k8ATNRo9XtYIKavtsG4raayTIrsncdyqsa)wd5l4jss2OFCfETMSizSijzJ(Xv41ApxD6JNKfjbQMKaXJaaWAfJKAYhWGKa(TgYxWtKKS4TMUw41AYIKXIKKfV101cVw75QtF8KSizhizEnbbWIKavtsG4raayTIrsn5nGbjb8BnKVGNijzJ(Xv41AYIKXIKKn6hxHxR9C1PpEswKeOAscepcaeaAPIc2l4jsMNizJdBlK8zQq5raq)cUf0Em9NaIKaUwnj2ps8HKaoTfjeajGijGdo9C7thsQjpjhjfgqcRbbacGeqKuiICtcjbCyQqHKlisc4W90HKwf8DUccK8Tzg2JaibejfIi3KqYVaRkRYqsa)1fJKaoBysi5BZmShbacGeqKmVMKXUbprYugCpgjXRyAhizkNzLYJKAjymliuizTfzC6te09HKnoSTui5wpDEeanoSTuEbhJxX0ogfSHTfcGgh2wkVGJXRyAh6pMy6gXJNqWxRJNeTkdgBsRqa04W2s5fCmEft7q)Xeh2N1PpM8Qf5XKUCb3c6QyyCwrIdYxbJkoiFy)C5raHaOXHTLYl4y8kM2H(JjIDmyQ7PcYnWrTk6hxHxXhxwOZZvN(4jbcAv0pUcpOPc4ccdhgs0XcggwgFEU60hpra04W2s5fCmEft7q)XeXogKypKj3ah1QOFCfEU4lZsaSkdYpljFEU60hpraGaibejZRjzSBWtKKhYNoKmmrgjdhgjBCShsAkKSh22RtFShbqJdBl1Osa3h0PRjufNrIra04W2sP)yId7Z60htE1I8OZ(MWKUCr(kyuXb5d7NlpI39nxIL3QHljgM0Lly4WqIowWWWY4ZFSyBLkhOL5eWJfBRueiaAzob8yX2kL2AegqdaTmNaESyBLkhE33CjwEfFCzHo)XITvQb4DFZLy5v8XLf68hl2wPYPbqiaACyBP0FmrbByBrUboc0uxqqVIpUSqN3vabcPUGGEvSNiK7lCGDnHG2XExbazGao8jD5cgomKOJfmmSm(8noSHmbcGwMtapwSTsP9yEdieanoSTu6pMiUFpyJdBl4Zub5vlYJk(4YcDKBGJPUGGEfFCzHoVRaeanoSTu6pMiUFpyJdBl4Zub5vlYJe5wWwk4cc3BYh5g4yQliONi3c2sbxq4Et(8Ucqa04W2sP)yI4(9GnoSTGptfKxTipUc4IpYnWXWezT1Ibyht7eoqReWHpPlxWWHHeDSGHHLXNVXHnKra04W2sP)yIGMkGlimCyirhlyyyz8rowh(XWOVmouJAi3ahXoMxStsgSJLBm)baLl(Y05dtKHXcf7KARHabU4ltNpmrggluStQTwmaV7BUelpOPcfCbHGUNo)XITvkT14tibc4DFZLy5jYTGTuWfeU3Kp)XITvkTfgiiaACyBP0FmroPa(bD6tKCdCe7yEXojzWowUrndakx8LPZhMidJfk2j1wdbc4DFZLy5v8XLf68hl2wP0wyce4IVmD(WezySqXoP2AXa8UV5sS8GMkuWfec6E68hl2wP0wJpHeiG39nxILNi3c2sbxq4Et(8hl2wP0wyGGaOXHTLs)XedlJpOG(jsowh(XWOVmouJAi3ahXRy6cvXzK4byhZl2jjd2XYnk8aGYfFz68HjYWyHIDsT1qGaE33CjwEfFCzHo)XITvkTfMabU4ltNpmrggluStQTwmaV7BUelpOPcfCbHGUNo)XITvkT14tibc4DFZLy5jYTGTuWfeU3Kp)XITvkTfgiiaACyBP0FmrC)EWgh2wWNPcYRwKhXtOIbj3ah1QOFCfEfFCzHoeanoSTu6pMiUFpyJdBl4Zub5vlYJ4juXhxwOJCdCm6hxHxXhxwOdbqJdBlL(JjI73d24W2c(mvqE1I8Oki3ahBCydzixSOXkTZhbqJdBlL(JjI73d24W2c(mvqE1I8yVm5g4yJdBid5IfnwLBmFeaiaACyBP89YJeDS7zvgCED2wqbUf2bbqJdBlLVxw)Xe5IVmlbWQmi)SK2rUboIDmVyNKmyhl3OWd4IVmD(WezySqXozoHjqa7yEXojzWowUrTabqJdBlLVxw)XevcSQSkdIVUyijdtICdCeVIPlufNrIha0uxqq)Slmdxqi2XYdZ7kGaHjN6cc6t3INUQaMEmrVRaGGaOXHTLY3lR)yIGMkuWfec6E6i3ah5IVmD(WezySqXozoojJDdggMitGa2X8IDsYGDmTh1GaOXHTLY3lR)yINPSkdQClijdtICSo8JHrFzCOg1qUboc0OFCfEIo29SkdoVoBlOa3c7maV7BUel)zkRYGk3csYWK8t3RdBRC4DFZLy5j6y3ZQm486STGcClSJ)yX2kL(Abqgau8UV5sS8GMkuWfec6E68hl2wPYLpbcyhl3ycbccGgh2wkFVS(JjEUkhRYG5rpzirRMKBGJPUGG(Zv5yvgmp6jdjA10pxIfcGgh2wkFVS(JjQeyvzvgeFDXqsgMe5g4iEftxOkoJepaOafV7BUelF6w80vfW0Jj6pwSTsLt4baf7y5YNab8UV5sS8GMkuWfec6E68hl2wPYL3azaqXowUXesGaE33CjwEqtfk4ccbDpD(JfBRu5egiaHabTcVd5QRWxm(23EZbCXxMoFyImmwOyNmxgEceeanoSTu(Ez9htKtkGFqN(ej3ahXoMxStsgSJLBudcGgh2wkFVS(JjcAQaUGWWHHeDSGHHLXh5yD4hdJ(Y4qnQHCdCe7yEXojzWowUX8ra04W2s57L1FmrSJbtDpvqUboIDmVyNKmyhl3OWiaACyBP89Y6pMi(AmPNvzW8ONm8zzorzvg5g4yQliOpCyilkGV9uqClOXwSNxfnMuon55aU4ltNpmrggluStMJtYy3GHHjYKrZa8UV5sS8GMkuWfec6E68hl2wPYXjzSBWWWezeanoSTu(Ez9htmSm(Gc6Ni5yD4hdJ(Y4qnQHCdCe7yEXojzWowUrHhauTk6hxH3XciEftxceWRy6cvXzKyGGaibejb89d7(6GNi5poJeRqa04W2s57L1FmrLaRkRYG4RlgsYWKi3ahXRy6cvXzK4b4TMUw4X9d7(6GNqvCgjwHaOXHTLY3lR)yIyhdsShYKBGJ4vmDHQ4msmcGgh2wkFVS(Jjc(0zvguXNaUcijdtICdCm1fe0NUKGcUf7NlXICRc(oxbXOgeanoSTu(Ez9htm91ysRBajzysKJ1HFmm6lJd1OgYnWr8kMUqvCgjEaqtDbb9PljOGBXExbeie9JRW7ybeVIP7abhpeMHNEn(WY4dkOFIdWo2OWdW7(MlXYdAQqbxqiO7PZFSyBLs78jqa7yEXojzWoM2JAgi44HWm80RXReyvzvgeFDXqsgM0aU4ltNpmrggluStQD(abbacGgh2wkpEcvm4OvdxsmmPlxWWHHeDSGHHLXh5g4OwnSpRtFS3zFtysxUiqa0YCc4XITvkTfoHiaACyBP84juXG6pMyF4UyyS3XvqUboIDmVyNKmyhl3OgeanoSTuE8eQyq9htmwxSdCbHtUdhYnWrqlZjGhl2wPYbunAzarMZTyW9Yypyh9dgRl2jbRryabecesDbb9Qypri3x4a7AcbTJ9ZLynqah(KUCbdhgs0XcggwgF(gh2qMabqlZjGhl2wP0wdGqa04W2s5XtOIb1FmrIClylfCbH7n5JCdCeOxBtipKRW3ZPYBvoTiHeiCTnH8qUcFpNkVRaGmaV7BUel)zkRYGk3csYWK8hl2wP0MtYy3GHHjYiaACyBP84juXG6pMiyZpRyOkwrbKBGJ4vmDHQ4ms8aGETnH8qUcFpNkVv50aiceU2MqEixHVNtL3vaqqa04W2s5XtOIb1FmrW(94cU3KpYnWXRTjKhYv475u5Tkx(aIaHRTjKhYv475u5DfGaOXHTLYJNqfdQ)yIPBXtxvatpMi5g4412eYd5k89CQ8wLlHaIaHRTjKhYv475u5Dfq(ZkgINJ5nGqa04W2s5XtOIb1FmrvSNiK7lCGDnHG2Xqqlzhm5g4iERPRfE8U30Qo4jCbb5szdzpxD6JNiaACyBP84juXG6pMOk2teY9foWUMqq7yYnWr8UV5sS8Qypri3x4a7AcbTJ9yN(Yy1OWeiaAzob8yX2kL2cdicea612eYd5k89CQ8hl2wPYPjHeiOv4DixDfEs6oRRbafOxBtipKRW3ZPYBvo8UV5sS8Qypri3x4a7AcbTJ9GUVh8yStFzmmmrMabT6ABc5HCf(EovEoPPcfqgau8UV5sS8wnCjXWKUCbdhgs0XcggwgF(JfBRu5W7(MlXYRI9eHCFHdSRje0o2d6(EWJXo9LXWWezceg2N1Pp27SVjmPlxabidW7(MlXYdAQqbxqiO7PZFSyBLs7X8Ca2XYnk8a8UV5sS8eDS7zvgCED2wqbUf2XFSyBLs7rncdeeanoSTuE8eQyq9htuf7jc5(chyxtiODm5g4iEhYvxHNKUZ6AaqtDbb9e5wWwk4cc3BYN3vabcaf0YCc4XITvkTX7(MlXYtKBbBPGliCVjF(JfBRueiG39nxILNi3c2sbxq4Et(8hl2wPYH39nxILxf7jc5(chyxtiODSh099GhJD6lJHHjYazaE33CjwEqtfk4ccbDpD(JfBRuApMNdWowUrHhG39nxILNOJDpRYGZRZ2ckWTWo(JfBRuApQryGGaOXHTLYJNqfdQ)yIUkgAblQqa04W2s5XtOIb1FmXyDXoWfesQpXMCdCe0YCc4XITvQCAsyEsGGao8jD5cgomKOJfmmSm(8noSHmbcd7Z60h7D23eM0LleanoSTuE8eQyq9htm9T7ec6E6i3ahX7(MlXYB1WLedt6YfmCyirhlyyyz85pwSTsLlFarGWW(So9XEN9nHjD5IabqlZjGhl2wP0wyaHaOXHTLYJNqfdQ)yIP8P4JKvzKBGJ4DFZLy5TA4sIHjD5cgomKOJfmmSm(8hl2wPYLpGiqyyFwN(yVZ(MWKUCrGaOL5eWJfBRuARjHiaACyBP84juXG6pM4ZYCcfmpCNzICfiaACyBP84juXG6pMiODC6B3j5g4iE33CjwERgUKyysxUGHddj6ybddlJp)XITvQC5diceg2N1Pp27SVjmPlxeiaAzob8yX2kL2AaecGgh2wkpEcvmO(Jj2fMvX1piUFpYnWr8UV5sS8wnCjXWKUCbdhgs0XcggwgF(JfBRu5YhqeimSpRtFS3zFtysxUiqa0YCc4XITvkTfgqiaACyBP84juXG6pMyANbxqyCgMKICdCm1fe0RI9eHCFHdSRje0o2pxIfcaeanoSTuE8eQ4Jll0noSpRtFm5vlYJk(4YcDWu3tfKVcgvCq(W(5YJ4DFZLy5v8XLf68hl2wP0wdbcc4WN0Lly4WqIowWWWY4Z34WgYdW7(MlXYR4Jll05pwSTsLlFarGaOL5eWJfBRuAlmGqa04W2s5XtOIpUSqN(JjA1WLedt6YfmCyirhlyyyz8rUboQvd7Z60h7D23eM0LlceaTmNaESyBLsBHticGgh2wkpEcv8XLf60FmrxfdTGfviaACyBP84juXhxwOt)Xe7d3fdJ9oUcYnWrSJ5f7KKb7y5g1GaOXHTLYJNqfFCzHo9ht8zzoHcMhUZmrUceanoSTuE8eQ4Jll0P)yIG2XPVDNKBGJd7Z60h7v8XLf6GPUNkqa04W2s5XtOIpUSqN(Jj2fMvX1piUFpYnWXH9zD6J9k(4YcDWu3tfiaACyBP84juXhxwOt)Xet7m4ccJZWKuKBGJd7Z60h7v8XLf6GPUNkqa04W2s5XtOIpUSqN(JjgRl2bUGWj3Hd5g4iOL5eWJfBRu5aQgTmGiZ5wm4EzShSJ(bJ1f7KG1imGacbcc4WN0Lly4WqIowWWWY4Z34WgYeiaAzob8yX2kL2AaecGgh2wkpEcv8XLf60FmXyDXoWfesQpXMCdCe0YCc4XITvQC5jGiqqah(KUCbdhgs0XcggwgF(gh2qMabqlZjGhl2wP0wdGqa04W2s5XtOIpUSqN(JjsKBbBPGliCVjFKBGJ4DFZLy5ptzvgu5wqsgMK)yX2kL2Csg7gmmmrgbqJdBlLhpHk(4YcD6pMiyZpRyOkwrbiaACyBP84juXhxwOt)Xeb73Jl4Et(qa04W2s5XtOIpUSqN(JjMUfpDvbm9yIiaACyBP84juXhxwOt)Xev8XLf6i3ahX7(MlXYFMYQmOYTGKmmj)XITvkTfMabqlZjGhl2wP0wtcra04W2s5XtOIpUSqN(JjM2zWfegNHjPqaGaOXHTLYVc4IVrqtfWfegomKOJfmmSm(ihRd)yy03LXHAud5g4i2X8IDsYGDSCJ5JaOXHTLYVc4Ip9htKtkGFqN(ej3ahJ(Xv4Xogm19uHNRo9XZbyhZl2jjd2XYnMpcGgh2wk)kGl(0FmXWY4dkOFIKJ1HFmm6lJd1OgYnWr8kMUqvCgjEa2X8IDsYGDSCJcJaOXHTLYVc4Ip9hte7yqI9qMCdCe7yEXojzWo2OWiaACyBP8RaU4t)Xe5Kc4h0PpreanoSTu(vax8P)yIHLXhuq)ejhRd)yy0xghQrnKBGJyhZl2jjd2XYnkmcaeanoSTuEfFCzHUrqtfk4ccbDpDKBGJPUGGEfFCzHo)XITvkT1GaOXHTLYR4Jll0P)yIUkgAblQqa04W2s5v8XLf60FmrLaRkRYG4RlgsYWKi3ahXRy6cvXzK4baTXHnKHCXIgRYnMpbcnoSHmKlw0yvond0k8UV5sS8NPSkdQClijdtY7kaiiaACyBP8k(4YcD6pM4zkRYGk3csYWKihRd)yy0xghQrnKBGJ4vmDHQ4msmcGgh2wkVIpUSqN(JjcAQqbxqiO7PJCdCSXHnKHCXIgRYnMpcGgh2wkVIpUSqN(JjQeyvzvgeFDXqsgMe5g4iEftxOkoJepi1fe0p7cZWfeIDS8W8Ucqa04W2s5v8XLf60FmX0xJjTUbKKHjrowh(XWOVmouJAi3ahXRy6cvXzK4bPUGGEIClylfCbH7n5dsKO3vWa8UV5sS8NPSkdQClijdtYFSyBLkNWiaACyBP8k(4YcD6pMiOPcfCbHGUNoYTk47CfeqdCm1fe0R4Jll05DfmaV7BUel)zkRYGk3csYWK8h3tDiaACyBP8k(4YcD6pMOsGvLvzq81fdjzysKBGJ4vmDHQ4ms8GjN6cc6t3INUQaMEmrVRaeanoSTuEfFCzHo9hte0ubCbHHddj6ybddlJpYX6Wpgg9LXHAud5g4i2X0oFeanoSTuEfFCzHo9htm91ysRBajzysKJ1HFmm6lJd1OgYnWr8kMUqvCgjMabTk6hxH3XciEftxeanoSTuEfFCzHo9htujWQYQmi(6IHKmmjeaiaACyBP8QyKOJDpRYGZRZ2ckWTWoKBGJxBtipKRW3ZPYBvo8UV5sS8eDS7zvgCED2wqbUf2XpDVoSTsWaYRLjq4ABc5HCf(EovExbiaACyBP8Qq)Xe5IVmlbWQmi)SK2rUboIDmVyNKmyhl3OWd4IVmD(WezySqXozU8jqa7yEXojzWowUrTyaq5IVmD(WezySqXozoHjqqReC8qygE614dlJpOG(jceeanoSTuEvO)yIkbwvwLbXxxmKKHjrUboIxX0fQIZiXdsDbb9ZUWmCbHyhlpmVRGba9ABc5HCf(EovERYL6cc6NDHz4ccXowEy(JfBRuKryceU2MqEixHVNtL3vaqqa04W2s5vH(JjEMYQmOYTGKmmjYX6Wpgg9LXHAud5g4iE33CjwEfFCzHo)XITvQCAiqqRI(Xv4v8XLf6qa04W2s5vH(JjcAQqbxqiO7PJCdCeOxBtipKRW3ZPYBvo8UV5sS8GMkuWfec6E68t3RdBRemG8AzceU2MqEixHVNtL3vaqgauU4ltNpmrggluStMJtYy3GHHjYKrdbcyhZl2jjd2X0EudbcPUGGEvSNiK7lCGDnHG2X(JfBRuAZjzSBWWWez91aeceaTmNaESyBLsBojJDdggMiRVgeanoSTuEvO)yI4RXKEwLbZJEYWNL5eLvzKBGJPUGG(WHHSOa(2tbXTGgBXEEv0ys50KNd4IVmD(WezySqXozoojJDdggMitgndW7(MlXYFMYQmOYTGKmmj)XITvQCCsg7gmmmrMaHuxqqF4WqwuaF7PG4wqJTypVkAmPCA0IbafV7BUelVIpUSqN)yX2kL2jCq0pUcVIpUSqhbc4DFZLy5jYTGTuWfeU3Kp)XITvkTt4a8oKRUcpjDN1fbcGwMtapwSTsPDcbccGgh2wkVk0FmXZv5yvgmp6jdjA1KCdCm1fe0FUkhRYG5rpzirRM(5sSg04WgYqUyrJv50GaOXHTLYRc9hte0ubCbHHddj6ybddlJpYX6Wpgg9LXHAud5g4i2X0oFeanoSTuEvO)yICsb8d60Ni5g4i2X8IDsYGDSCJAqa04W2s5vH(JjIDmyQ7PcYnWrSJ5f7KKb7y5g1mOXHnKHCXIgRg1m4ABc5HCf(EovERYjmGiqa7yEXojzWowUrHh04WgYqUyrJv5gfgbqJdBlLxf6pMi2XGe7HmcGgh2wkVk0FmXWY4dkOFIKJ1HFmm6lJd1OgYnWr8kMUqvCgjEa2X8IDsYGDSCJcpi1fe0RI9eHCFHdSRje0o2pxIfcGgh2wkVk0FmrLaRkRYG4RlgsYWKi3ahtDbb9yhdYfFz68QOXKYLpGitctWnoSHmKlw0y1GuxqqVk2teY9foWUMqq7y)CjwdakE33Cjw(ZuwLbvUfKKHj5pwSTsLt4b4DFZLy5bnvOGlie0905pwSTsLtyceW7(MlXYFMYQmOYTGKmmj)XITvkTZFaE33CjwEqtfk4ccbDpD(JfBRu5YFa2XYLpbc4DFZLy5ptzvgu5wqsgMK)yX2kvU8hG39nxILh0uHcUGqq3tN)yX2kL25pa7y50cceWoMxStsgSJP9OMbCXxMoFyImmwOyNuBHbcbcPUGGESJb5IVmDEv0ys50aObGwMtapwSTsPDEbbqJdBlLxf6pMy6RXKw3asYWKihRd)yy0xghQrnKBGJ4vmDHQ4ms8aGg9JRWR4Jll0naV7BUelVIpUSqN)yX2kL25tGaE33Cjw(ZuwLbvUfKKHj5pwSTsLtZa8UV5sS8GMkuWfec6E68hl2wPYPHab8UV5sS8NPSkdQClijdtYFSyBLs78hG39nxILh0uHcUGqq3tN)yX2kvU8hGDSCctGaE33Cjw(ZuwLbvUfKKHj5pwSTsLl)b4DFZLy5bnvOGlie0905pwSTsPD(dWowU8jqa7y5sibcPUGG(0LeuWTyVRaGGaOXHTLYRc9htmSm(Gc6Ni5yD4hdJ(Y4qnQHCdCeVIPlufNrIhGDmVyNKmyhl3OWiaACyBP8Qq)XebF6SkdQ4taxbKKHjrUvbFNRGyudcGgh2wkVk0FmX0xJjTUbKKHjrowh(XWOVmouJAi3ahXRy6cvXzK4b4DFZLy5bnvOGlie0905pwSTsPD(dWo2OWdeC8qygE614dlJpOG(joGl(Y05dtKHXctiG0wdcGgh2wkVk0FmX0xJjTUbKKHjrowh(XWOVmouJAi3ahXRy6cvXzK4bCXxMoFyImmwOyNuBHhauSJ5f7KKb7yApQHabbhpeMHNEn(WY4dkOFIabbacGgh2wkprUfSLcUGW9M8nI73d24W2c(mvqE1I8iEcvmi5g4Owf9JRWR4Jll0HaOXHTLYtKBbBPGliCVjF6pMiUFpyJdBl4Zub5vlYJ4juXhxwOJCdCm6hxHxXhxwOdbqJdBlLNi3c2sbxq4Et(0FmrU4lZsaSkdYplPDKBGJyhZl2jjd2XYnk8aU4ltNpmrggluStMlFeanoSTuEIClylfCbH7n5t)Xeptzvgu5wqsgMe5yD4hdJ(Y4qnQbbqJdBlLNi3c2sbxq4Et(0FmrLaRkRYG4RlgsYWKi3ahXRy6cvXzK4bPUGG(zxygUGqSJLhM3vacGgh2wkprUfSLcUGW9M8P)yIGMkuWfec6E6i3ahBCydzixSOXQCJcpi1fe0tKBbBPGliCVjFqIe9hl2wP0wdcGgh2wkprUfSLcUGW9M8P)yIeDS7zvgCED2wqbUf2HCdCSXHnKHCXIgRYnkmcGgh2wkprUfSLcUGW9M8P)yIkbwvwLbXxxmKKHjrUboIxX0fQIZiXdACydzixSOXQCJ5pi1fe0tKBbBPGliCVjFqIe9Ucqa04W2s5jYTGTuWfeU3Kp9htm91ysRBajzysKJ1HFmm6lJd1OgYnWr8kMUqvCgjEqJdBid5IfnwP9OWiaACyBP8e5wWwk4cc3BYN(Jjs0XUNvzW51zBbf4wyheanoSTuEIClylfCbH7n5t)XebnvOGlie090rUvbFNRGaAGJPUGGEIClylfCbH7n5dsKO3va5g4yQliOxf7jc5(chyxtiODS3vWGRTjKhYv475u5TkhE33CjwEqtfk4ccbDpD(P71HTvcgq(8gbqJdBlLNi3c2sbxq4Et(0FmrLaRkRYG4RlgsYWKi3ahtDbb9yhdYfFz68QOXKYLpGitctWnoSHmKlw0yfcGgh2wkprUfSLcUGW9M8P)yIGMkGlimCyirhlyyyz8rowh(XWOVmouJAi3ahXoM25JaOXHTLYtKBbBPGliCVjF6pMiNua)Go9jsUboIDmVyNKmyhl3OgeanoSTuEIClylfCbH7n5t)XeXogm19ub5g4i2X8IDsYGDSCJavJ(noSHmKlw0yvonabbqJdBlLNi3c2sbxq4Et(0FmXWY4dkOFIKJ1HFmm6lJd1OgYnWrGQvr)4k8owaXRy6sGaEftxOkoJedKbyhZl2jjd2XYnkmcGgh2wkprUfSLcUGW9M8P)yIyhdsShYiaACyBP8e5wWwk4cc3BYN(JjM(AmP1nGKmmjYX6Wpgg9LXHAud5g4i2XYnMpbcPUGGEIClylfCbH7n5dsKO3vacGgh2wkprUfSLcUGW9M8P)yIGpDwLbv8jGRasYWKi3QGVZvqmQH(B3Wzp6)BIaEAqdkfa]] )

end