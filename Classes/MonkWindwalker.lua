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
    
    spec:RegisterPack( "Windwalker", 20210117, [[dW082bqisu5risfBsH8jsugfGYPaOwLii9ksQMfI4waQ2fv9lrOHbqogjSmsKNjQQPHiPRjcSnrvQVrIQmoeP05evjRdrcZJi19uW(evoiIuLfss5HKOQUiIuvBuufvFuufXjrKIwjaEPOks1mrKOBkQIe7eq(POkkdvufjTurq0tbAQejxvufP8vePWyfb1Er6VGgmHdl1IfPhd1Kv0LrTzv1NfLrtfNMYQfvHxJOMTQCBIA3s(TsdNioUiiSCvEoPMUW1PsBxH67i04frNNKSEePsZhb7hYufuPOGZoykqkbiLuaifkuEEfaIubKs5ffmujHPGsAm5oJPGvlZuqsdRMe7hz(OGsAvVTNuPOG619WmfKcM6AVG0SOPuWzhmfiLaKskaKcfkpVcarQasPeqb1symfiLY78Ic6yZjx0uk4K1ykiPdsqAy1Ky)iZhsKNYwKraq6Gea0LBFQqcfkpsqcLaKskqaGaG0bjKIi3KrI8CthAKy)irEU7PcjSk47CLeiXBZmSNc(mDOPsrbxjCXhvkkqkOsrb5QtF8KQgfSXHTff8B6aUFy4WqIowWWWY4JcIpl4ZAki2X8YDsKa4ib2XqICdir(uqSk8JHrFxghAkOcAqbsjQuuqU60hpPQrbXNf8znfm6hxHh7yWu3thEU60hprIrib2X8YDsKa4ib2XqICdir(uWgh2wuqoPe(bD6tMguGYNkffKRo9XtQAuWgh2wuWWY4dkPFYuq8zbFwtbXRC6c1XzKzKyesGDmVCNejaosGDmKi3asOefeRc)yy0xghAkqkObfisLkffKRo9XtQAuq8zbFwtbXoMxUtIeahjWogsmGekrbBCyBrbXogKypMPbfOeqLIc24W2IcYjLWpOtFYuqU60hpPQrdkq5nvkkixD6JNu1OGnoSTOGHLXhus)KPG4Zc(SMcIDmVCNejaosGDmKi3asOefeRc)yy0xghAkqkObnOGe5wYwA4(H7n5JkffifuPOGC1PpEsvJcIpl4ZAkOYHer)4k8A(4YcvEU60hpPGnoSTOG4(9GnoSTGpthuWNPdy1YmfepHA(tdkqkrLIcYvN(4jvnki(SGpRPGr)4k8A(4YcvEU60hpPGnoSTOG4(9GnoSTGpthuWNPdy1YmfepHA(4Ycv0Gcu(uPOGC1PpEsvJcIpl4ZAki2X8YDsKa4ib2XqICdiHsiXiKGl(Yu5dtMHXcL7KiroKiFkyJdBlkix8LzKUwLb5NL0oAqbIuPsrb5QtF8KQgfSXHTff8mTvzqTBbjByYuqSk8JHrFzCOPaPGguGsavkkixD6JNu1OG4Zc(SMcIx50fQJZiZiXiKi19)9ZUWmC)qSJLhM3vcfSXHTffulXQYQmi(6IHKnmzAqbkVPsrb5QtF8KQgfeFwWN1uWgh2ygYflBSgjYnGekHeJqIu3)3tKBjBPH7hU3KpirI(JLBR0iH0iHckyJdBlk430HgUF439urdkqkpQuuqU60hpPQrbXNf8znfSXHnMHCXYgRrICdiHsuWgh2wuqIo29SkdoVoBlOe3c7qdkqKwQuuqU60hpPQrbXNf8znfeVYPluhNrMrIrirJdBmd5ILnwJe5gqI8rIrirQ7)7jYTKT0W9d3BYhKirVRekyJdBlkOwIvLvzq81fdjByY0GcuErLIcYvN(4jvnkyJdBlky6RXKx3as2WKPG4Zc(SMcIx50fQJZiZiXiKOXHnMHCXYgRrcPhqcLOGyv4hdJ(Y4qtbsbnOaPaquPOGnoSTOGeDS7zvgCED2wqjUf2HcYvN(4jvnAqbsHcQuuqU60hpPQrbXNf8znfm19)96ypzi3x4a7Ac)2XExjiXiK4ABc5XCf(Eo1ERqICibE33Cjw(VPdnC)WV7PYpDVoSTqIeksaiFEtbBCyBrb)Mo0W9d)UNkkOvbFNRKaAFkyQ7)7jYTKT0W9d3BYhKirVReAqbsHsuPOGC1PpEsvJcIpl4ZAkyQ7)7XogKl(Yu51rJjJe5qI8besaCKibircfjACyJzixSSXAkyJdBlkOwIvLvzq81fdjByY0GcKI8Psrb5QtF8KQgfSXHTff8B6aUFy4WqIowWWWY4JcIpl4ZAki2XqcPrI8PGyv4hdJ(Y4qtbsbnOaPGuPsrb5QtF8KQgfeFwWN1uqSJ5L7KibWrcSJHe5gqcfuWgh2wuqoPe(bD6tMguGuKaQuuqU60hpPQrbXNf8znfe7yE5ojsaCKa7yirUbKayiHcKqDKOXHnMHCXYgRrICiHcKaWuWgh2wuqSJbtDpDqdkqkYBQuuqU60hpPQrbBCyBrbdlJpOK(jtbXNf8znfeyiHYHer)4k8owaXRC665QtF8ejiqajWRC6c1XzKzKaWiXiKa7yE5ojsaCKa7yirUbKqjkiwf(XWOVmo0uGuqdkqkuEuPOGnoSTOGyhdsShZuqU60hpPQrdkqkiTuPOGC1PpEsvJc24W2IcM(Am51nGKnmzki(SGpRPGyhdjYnGe5JeeiGePU)VNi3s2sd3pCVjFqIe9UsOGyv4hdJ(Y4qtbsbnOaPiVOsrbTk47CLeuqfuWgh2wuW)tLvzqnFs4kGKnmzkixD6JNu1ObnOGA(4YcvuPOaPGkffKRo9XtQAuq8zbFwtbtD)FVMpUSqL)y52knsinsOGc24W2Ic(nDOH7h(Dpv0GcKsuPOGnoSTOGUAgAblRPGC1PpEsvJguGYNkffKRo9XtQAuq8zbFwtbXRC6c1XzKzKyesamKOXHnMHCXYgRrICdir(ibbcirJdBmd5ILnwJe5qcfiXiKq5qc8UV5sS8NPTkdQDlizdt27kbjamfSXHTffulXQYQmi(6IHKnmzAqbIuPsrb5QtF8KQgfSXHTff8mTvzqTBbjByYuq8zbFwtbXRC6c1XzKzkiwf(XWOVmo0uGuqdkqjGkffKRo9XtQAuq8zbFwtbBCyJzixSSXAKi3asKpfSXHTff8B6qd3p87EQObfO8MkffKRo9XtQAuq8zbFwtbXRC6c1XzKzKyesK6()(zxygUFi2XYdZ7kHc24W2IcQLyvzvgeFDXqYgMmnOaP8Osrb5QtF8KQgfSXHTffm91yYRBajByYuq8zbFwtbXRC6c1XzKzKyesK6()EIClzlnC)W9M8bjs07kbjgHe4DFZLy5ptBvgu7wqYgMS)y52knsKdjuIcIvHFmm6lJdnfif0GcePLkff0QGVZvsaTpfm19)9A(4YcvExjJW7(MlXYFM2QmO2TGKnmz)X9uffSXHTff8B6qd3p87EQOGC1PpEsvJguGYlQuuqU60hpPQrbXNf8znfeVYPluhNrMrIriXKtD)FF6w80vhW0Jj6DLqbBCyBrb1sSQSkdIVUyizdtMguGuaiQuuqU60hpPQrbBCyBrb)MoG7hgomKOJfmmSm(OG4Zc(SMcIDmKqAKiFkiwf(XWOVmo0uGuqdkqkuqLIcYvN(4jvnkyJdBlky6RXKx3as2WKPG4Zc(SMcIx50fQJZiZibbciHYHer)4k8owaXRC665QtF8KcIvHFmm6lJdnfif0GcKcLOsrbBCyBrb1sSQSkdIVUyizdtMcYvN(4jvnAqdkiEc18XLfQOsrbsbvkkixD6JNu1OGRekOMdkyJdBlk44(So9XuWX9ZLPG4DFZLy518XLfQ8hl3wPrcPrcfibbciHeo8jD5cgomKOJfmmSm(8noSXmsmcjW7(MlXYR5Jllu5pwUTsJe5qI8besqGas8TmNaESCBLgjKgjucquWX9bRwMPGA(4YcvWu3th0GcKsuPOGC1PpEsvJcIpl4ZAkOYHeJ7Z60h7D23eM0LlKGabK4Bzob8y52knsinsOucOGnoSTOGwnEjZWKUCrdkq5tLIc24W2Ic6QzOfSSMcYvN(4jvnAqbIuPsrb5QtF8KQgfeFwWN1uqSJ5L7KibWrcSJHe5gqcfuWgh2wuW(WDXWyVJRGguGsavkkyJdBlk4ZYCcnmpCNzYCfuqU60hpPQrdkq5nvkkixD6JNu1OG4Zc(SMcoUpRtFSxZhxwOcM6E6Gc24W2Ic(TJtF7oPbfiLhvkkixD6JNu1OG4Zc(SMcoUpRtFSxZhxwOcM6E6Gc24W2Ic2fM1X1piUFpAqbI0sLIcYvN(4jvnki(SGpRPGJ7Z60h718XLfQGPUNoOGnoSTOGPDgC)W4mmznnOaLxuPOGC1PpEsvJcIpl4ZAk43YCc4XYTvAKihsamKqbPfqibWrIZT4)EzS)3r)GX6ID8C1PpEIejuKqHsacjamsqGasiHdFsxUGHddj6ybddlJpFJdBmJeeiGeFlZjGhl3wPrcPrcfaIc24W2IcgRl2bUF4K7WHguGuaiQuuqU60hpPQrbXNf8znf8Bzob8y52knsKdjYlaHeeiGes4WN0Lly4WqIowWWWY4Z34WgZibbciX3YCc4XYTvAKqAKqbGOGnoSTOGX6IDG7hsUp5MguGuOGkffKRo9XtQAuq8zbFwtbX7(MlXYFM2QmO2TGKnmz)XYTvAKqAKGtYy3GHHjZuWgh2wuqIClzlnC)W9M8rdkqkuIkffSXHTff838ZkgQJvwcfKRo9XtQA0GcKI8PsrbBCyBrb)97XfCVjFuqU60hpPQrdkqkivQuuWgh2wuW0T4PRoGPhtKcYvN(4jvnAqbsrcOsrb5QtF8KQgfeFwWN1uq8UV5sS8NPTkdQDlizdt2FSCBLgjKgjucjiqaj(wMtapwUTsJesJeksafSXHTffuZhxwOIguGuK3uPOGnoSTOGPDgC)W4mmznfKRo9XtQA0GguqDqLIcKcQuuqU60hpPQrbXNf8znf8ABc5XCf(Eo1ERqICibE33CjwEIo29SkdoVoBlOe3c74NUxh2wircfjaKN0IeeiGexBtipMRW3ZP27kHc24W2Ics0XUNvzW51zBbL4wyhAqbsjQuuqU60hpPQrbXNf8znfe7yE5ojsaCKa7yirUbKqjKyesWfFzQ8HjZWyHYDsKihsKpsqGasGDmVCNejaosGDmKi3asqQiXiKayibx8LPYhMmdJfk3jrICiHsibbciHYHesoEmmdp9k8HLXhus)KrcatbBCyBrb5IVmJ01Qmi)SK2rdkq5tLIcYvN(4jvnki(SGpRPG4voDH64mYmsmcjsD)F)Slmd3pe7y5H5DLGeJqcGHexBtipMRW3ZP2BfsKdjsD)F)Slmd3pe7y5H5pwUTsJeahjucjiqajU2MqEmxHVNtT3vcsaykyJdBlkOwIvLvzq81fdjByY0GcePsLIcYvN(4jvnkyJdBlk4zARYGA3cs2WKPG4Zc(SMcI39nxILxZhxwOYFSCBLgjYHekqcceqcLdjI(Xv418XLfQ8C1PpEsbXQWpgg9LXHMcKcAqbkbuPOGC1PpEsvJcIpl4ZAkiWqIRTjKhZv475u7TcjYHe4DFZLy5)Mo0W9d)UNk)096W2cjsOibG8KwKGabK4ABc5XCf(Eo1ExjibGrIribWqcU4ltLpmzggluUtIe5qcojJDdggMmJeahjuGeeiGeyhZl3jrcGJeyhdjKEajuGeeiGePU)Vxh7jd5(chyxt43o2FSCBLgjKgj4Km2nyyyYmsOosOajamsqGas8TmNaESCBLgjKgj4Km2nyyyYmsOosOGc24W2Ic(nDOH7h(Dpv0GcuEtLIcYvN(4jvnki(SGpRPGPU)VpCyillHV90qClPXwSNxhnMmsKdjuKxiXiKGl(Yu5dtMHXcL7KiroKGtYy3GHHjZibWrcfiXiKaV7BUel)zARYGA3cs2WK9hl3wPrICibNKXUbddtMrcceqIu3)3homKLLW3EAiUL0yl2ZRJgtgjYHekivKyesamKaV7BUelVMpUSqL)y52knsinsKaKyese9JRWR5Jllu55QtF8ejiqajW7(MlXYtKBjBPH7hU3Kp)XYTvAKqAKibiXiKaVJ5QRWtw1zDHeeiGeFlZjGhl3wPrcPrIeGeaMc24W2IcIVgt(zvgmp6jdFwMtuwLrdkqkpQuuqU60hpPQrbXNf8znfm19)9NR2XQmyE0tgs0QPFUelKyes04WgZqUyzJ1iroKqbfSXHTff8C1owLbZJEYqIwnPbfislvkkixD6JNu1OGnoSTOGFthW9ddhgs0XcggwgFuq8zbFwtbXogsinsKpfeRc)yy0xghAkqkObfO8IkffKRo9XtQAuq8zbFwtbXoMxUtIeahjWogsKBajuqbBCyBrb5Ks4h0PpzAqbsbGOsrb5QtF8KQgfeFwWN1uqSJ5L7KibWrcSJHe5gqcfiXiKOXHnMHCXYgRrIbKqbsmcjU2MqEmxHVNtT3kKihsOeGqcceqcSJ5L7KibWrcSJHe5gqcLqIrirJdBmd5ILnwJe5gqcLOGnoSTOGyhdM6E6GguGuOGkffSXHTffe7yqI9yMcYvN(4jvnAqbsHsuPOGC1PpEsvJc24W2IcgwgFqj9tMcIpl4ZAkiELtxOooJmJeJqcSJ5L7KibWrcSJHe5gqcLqIrirQ7)71XEYqUVWb21e(TJ9ZLyrbXQWpgg9LXHMcKcAqbsr(uPOGC1PpEsvJcIpl4ZAkyQ7)7XogKl(Yu51rJjJe5qI8besaCKibircfjACyJzixSSXAKyesK6()EDSNmK7lCGDnHF7y)CjwiXiKayibE33Cjw(Z0wLb1UfKSHj7pwUTsJe5qcLqIribE33Cjw(VPdnC)WV7PYFSCBLgjYHekHeeiGe4DFZLy5ptBvgu7wqYgMS)y52knsinsKpsmcjW7(MlXY)nDOH7h(Dpv(JLBR0iroKiFKyesGDmKihsKpsqGasG39nxIL)mTvzqTBbjByY(JLBR0iroKiFKyesG39nxIL)B6qd3p87EQ8hl3wPrcPrI8rIrib2XqICibPIeeiGeyhZl3jrcGJeyhdjKEajuGeJqcU4ltLpmzggluUtIesJekHeagjiqajsD)Fp2XGCXxMkVoAmzKihsOaqiXiK4Bzob8y52knsinsO8OGnoSTOGAjwvwLbXxxmKSHjtdkqkivQuuqU60hpPQrbBCyBrbtFnM86gqYgMmfeFwWN1uq8kNUqDCgzgjgHeadjI(Xv418XLfQ8C1PpEIeJqc8UV5sS8A(4Ycv(JLBR0iH0ir(ibbcibE33Cjw(Z0wLb1UfKSHj7pwUTsJe5qcfiXiKaV7BUel)30HgUF439u5pwUTsJe5qcfibbcibE33Cjw(Z0wLb1UfKSHj7pwUTsJesJe5JeJqc8UV5sS8FthA4(HF3tL)y52knsKdjYhjgHeyhdjYHekHeeiGe4DFZLy5ptBvgu7wqYgMS)y52knsKdjYhjgHe4DFZLy5)Mo0W9d)UNk)XYTvAKqAKiFKyesGDmKihsKpsqGasGDmKihsKaKGabKi19)9PlzOKBXExjibGPGyv4hdJ(Y4qtbsbnOaPibuPOGC1PpEsvJc24W2IcgwgFqj9tMcIpl4ZAkiELtxOooJmJeJqcSJ5L7KibWrcSJHe5gqcLOGyv4hdJ(Y4qtbsbnOaPiVPsrbTk47CLeuqfuWgh2wuW)tLvzqnFs4kGKnmzkixD6JNu1ObfifkpQuuqU60hpPQrbBCyBrbtFnM86gqYgMmfeFwWN1uq8kNUqDCgzgjgHe4DFZLy5)Mo0W9d)UNk)XYTvAKqAKiFKyesGDmKyajucjgHesoEmmdp9k8HLXhus)KrIribx8LPYhMmdJfMaaHesJekOGyv4hdJ(Y4qtbsbnOaPG0sLIcYvN(4jvnkyJdBlky6RXKx3as2WKPG4Zc(SMcIx50fQJZiZiXiKGl(Yu5dtMHXcL7KiH0iHsiXiKayib2X8YDsKa4ib2XqcPhqcfibbciHKJhdZWtVcFyz8bL0pzKaWuqSk8JHrFzCOPaPGg0GcINqn)PsrbsbvkkixD6JNu1OG4Zc(SMcQCiX4(So9XEN9nHjD5cjiqaj(wMtapwUTsJesJekLakyJdBlkOvJxYmmPlx0GcKsuPOGC1PpEsvJcIpl4ZAki2X8YDsKa4ib2XqICdiHckyJdBlkyF4UyyS3Xvqdkq5tLIcYvN(4jvnki(SGpRPGFlZjGhl3wPrICibWqcfKwaHeahjo3I)7LX(Fh9dgRl2XZvN(4jsKqrcfkbiKaWibbcirQ7)71XEYqUVWb21e(TJ9ZLyHeJqcjC4t6YfmCyirhlyyyz85BCyJzKGabK4Bzob8y52knsinsOaquWgh2wuWyDXoW9dNCho0GcePsLIcYvN(4jvnki(SGpRPGadjU2MqEmxHVNtT3kKihsqQjajiqajU2MqEmxHVNtT3vcsayKyesG39nxIL)mTvzqTBbjByY(JLBR0iH0ibNKXUbddtMPGnoSTOGe5wYwA4(H7n5JguGsavkkixD6JNu1OG4Zc(SMcIx50fQJZiZiXiKayiX12eYJ5k89CQ9wHe5qcfacjiqajU2MqEmxHVNtT3vcsaykyJdBlk4V5NvmuhRSeAqbkVPsrb5QtF8KQgfeFwWN1uWRTjKhZv475u7TcjYHe5diKGabK4ABc5XCf(Eo1ExjuWgh2wuWF)ECb3BYhnOaP8Osrb5QtF8KQgfeFwWN1uWRTjKhZv475u7TcjYHejaqibbciX12eYJ5k89CQ9UsOGnoSTOGPBXtxDatpMif8zfdXtkyEdiAqbI0sLIcYvN(4jvnki(SGpRPG4TMUw4X7EtR6GNW9)5sBJzpxD6JNuWgh2wuqDSNmK7lCGDnHF7y43s2btdkq5fvkkixD6JNu1OG4Zc(SMcI39nxILxh7jd5(chyxt43o2JD6lJ1iXasOesqGas8TmNaESCBLgjKgjucqibbcibWqIRTjKhZv475u7pwUTsJe5qcfjajiqajuoKaVJ5QRWtw1zDHeJqcGHeadjU2MqEmxHVNtT3kKihsG39nxILxh7jd5(chyxt43o2)DFp4XyN(YyyyYmsqGasOCiX12eYJ5k89CQ9CsthAKaWiXiKayibE33CjwERgVKzysxUGHddj6ybddlJp)XYTvAKihsG39nxILxh7jd5(chyxt43o2)DFp4XyN(YyyyYmsqGasmUpRtFS3zFtysxUqcaJeagjgHe4DFZLy5)Mo0W9d)UNk)XYTvAKq6bKiVqIrib2XqICdiHsiXiKaV7BUelprh7EwLbNxNTfuIBHD8hl3wPrcPhqcfkHeaMc24W2IcQJ9KHCFHdSRj8BhtdkqkaevkkixD6JNu1OG4Zc(SMcI3XC1v4jR6SUqIribWqIu3)3tKBjBPH7hU3KpVReKGabKayiX3YCc4XYTvAKqAKaV7BUelprULSLgUF4Et(8hl3wPrcceqc8UV5sS8e5wYwA4(H7n5ZFSCBLgjYHe4DFZLy51XEYqUVWb21e(TJ9F33dEm2PVmggMmJeagjgHe4DFZLy5)Mo0W9d)UNk)XYTvAKq6bKiVqIrib2XqICdiHsiXiKaV7BUelprh7EwLbNxNTfuIBHD8hl3wPrcPhqcfkHeaMc24W2IcQJ9KHCFHdSRj8BhtdkqkuqLIc24W2Ic6QzOfSSMcYvN(4jvnAqbsHsuPOGC1PpEsvJcIpl4ZAk43YCc4XYTvAKihsOib5fsqGasiHdFsxUGHddj6ybddlJpFJdBmJeeiGeJ7Z60h7D23eM0LlkyJdBlkySUyh4(HK7tUPbfif5tLIcYvN(4jvnki(SGpRPG4DFZLy5TA8sMHjD5cgomKOJfmmSm(8hl3wPrICir(acjiqajg3N1Pp27SVjmPlxibbciX3YCc4XYTvAKqAKqjarbBCyBrbtF7oHF3tfnOaPGuPsrb5QtF8KQgfeFwWN1uq8UV5sS8wnEjZWKUCbdhgs0XcggwgF(JLBR0iroKiFaHeeiGeJ7Z60h7D23eM0LlKGabK4Bzob8y52knsinsOibuWgh2wuWu(08r2QmAqbsrcOsrbBCyBrbFwMtOH5H7mtMRGcYvN(4jvnAqbsrEtLIcYvN(4jvnki(SGpRPG4DFZLy5TA8sMHjD5cgomKOJfmmSm(8hl3wPrICir(acjiqajg3N1Pp27SVjmPlxibbciX3YCc4XYTvAKqAKqbGOGnoSTOGF7403UtAqbsHYJkffKRo9XtQAuq8zbFwtbX7(MlXYB14Lmdt6YfmCyirhlyyyz85pwUTsJe5qI8besqGasmUpRtFS3zFtysxUqcceqIVL5eWJLBR0iH0iHsaIc24W2Ic2fM1X1piUFpAqbsbPLkffKRo9XtQAuq8zbFwtbtD)FVo2tgY9foWUMWVDSFUelkyJdBlkyANb3pmodtwtdAqbN8VDFbvkkqkOsrbBCyBrb1s4(GoDnH64mYmfKRo9XtQA0GcKsuPOGC1PpEsvJcUsOGAoOGnoSTOGJ7Z60htbh3pxMcI39nxIL3QXlzgM0Lly4WqIowWWWY4ZFSCBLgjYHeFlZjGhl3wPrcceqIVL5eWJLBR0iH0iHcLaesmcj(wMtapwUTsJe5qc8UV5sS8A(4Ycv(JLBR0iXiKaV7BUelVMpUSqL)y52knsKdjuaik44(GvlZuqN9nHjD5IguGYNkffKRo9XtQAuq8zbFwtbbgsK6()EnFCzHkVReKGabKi19)96ypzi3x4a7Ac)2XExjibGrIriHeo8jD5cgomKOJfmmSm(8noSXmsqGas8TmNaESCBLgjKEajYBarbBCyBrbLSHTfnOarQuPOGC1PpEsvJcIpl4ZAkyQ7)718XLfQ8UsOGnoSTOG4(9GnoSTGpthuWNPdy1YmfuZhxwOIguGsavkkixD6JNu1OG4Zc(SMcM6()EIClzlnC)W9M85DLqbBCyBrbX97bBCyBbFMoOGpthWQLzkirULSLgUF4Et(ObfO8MkffKRo9XtQAuq8zbFwtbdtMrcPrcsfjgHeyhdjKgjsasmcjuoKqch(KUCbdhgs0XcggwgF(gh2yMc24W2IcI73d24W2c(mDqbFMoGvlZuWvcx8rdkqkpQuuqU60hpPQrbBCyBrb)MoG7hgomKOJfmmSm(OG4Zc(SMcIDmVCNejaosGDmKi3asKpsmcjagsWfFzQ8HjZWyHYDsKqAKqbsqGasWfFzQ8HjZWyHYDsKqAKGurIribE33Cjw(VPdnC)WV7PYFSCBLgjKgju4tasqGasG39nxILNi3s2sd3pCVjF(JLBR0iH0iHsibGPGyv4hdJ(Y4qtbsbnOarAPsrb5QtF8KQgfeFwWN1uqSJ5L7KibWrcSJHe5gqcfiXiKayibx8LPYhMmdJfk3jrcPrcfibbcibE33CjwEnFCzHk)XYTvAKqAKqjKGabKGl(Yu5dtMHXcL7KiH0ibPIeJqc8UV5sS8FthA4(HF3tL)y52knsinsOWNaKGabKaV7BUelprULSLgUF4Et(8hl3wPrcPrcLqcatbBCyBrb5Ks4h0PpzAqbkVOsrb5QtF8KQgfSXHTffmSm(Gs6NmfeFwWN1uq8kNUqDCgzgjgHeyhZl3jrcGJeyhdjYnGekHeJqcGHeCXxMkFyYmmwOCNejKgjuGeeiGe4DFZLy518XLfQ8hl3wPrcPrcLqcceqcU4ltLpmzggluUtIesJeKksmcjW7(MlXY)nDOH7h(Dpv(JLBR0iH0iHcFcqcceqc8UV5sS8e5wYwA4(H7n5ZFSCBLgjKgjucjamfeRc)yy0xghAkqkObfifaIkffKRo9XtQAuq8zbFwtbvoKi6hxHxZhxwOYZvN(4jfSXHTffe3VhSXHTf8z6Gc(mDaRwMPG4juZFAqbsHcQuuqU60hpPQrbXNf8znfm6hxHxZhxwOYZvN(4jfSXHTffe3VhSXHTf8z6Gc(mDaRwMPG4juZhxwOIguGuOevkkixD6JNu1OG4Zc(SMc24WgZqUyzJ1iH0ir(uWgh2wuqC)EWgh2wWNPdk4Z0bSAzMcQdAqbsr(uPOGC1PpEsvJcIpl4ZAkyJdBmd5ILnwJe5gqI8PGnoSTOG4(9GnoSTGpthuWNPdy1YmfSxMg0Gck5y8kN2bvkkqkOsrbBCyBrbLSHTffKRo9XtQA0GcKsuPOGnoSTOGPBepEc)VwfpjAvgm2Kwrb5QtF8KQgnOaLpvkkixD6JNu1OGRekOMdkyJdBlk44(So9XuWX9ZLPGaIcoUpy1YmfmPlxWTGUAggNvK5GguGivQuuqU60hpPQrbXNf8znfu5qIOFCfEnFCzHkpxD6JNibbciHYHer)4k8FthW9ddhgs0XcggwgFEU60hpPGnoSTOGyhdM6E6GguGsavkkixD6JNu1OG4Zc(SMcQCir0pUcpx8LzKUwLb5NLKppxD6JNuWgh2wuqSJbj2JzAqdkyVmvkkqkOsrbBCyBrbj6y3ZQm486STGsClSdfKRo9XtQA0GcKsuPOGC1PpEsvJcIpl4ZAki2X8YDsKa4ib2XqICdiHsiXiKGl(Yu5dtMHXcL7KiroKqjKGabKa7yE5ojsaCKa7yirUbKGuPGnoSTOGCXxMr6AvgKFws7ObfO8Psrb5QtF8KQgfeFwWN1uq8kNUqDCgzgjgHeadjsD)F)Slmd3pe7y5H5DLGeeiGeto19)9PBXtxDatpMO3vcsaykyJdBlkOwIvLvzq81fdjByY0GcePsLIcYvN(4jvnki(SGpRPGCXxMkFyYmmwOCNejYHeCsg7gmmmzgjiqajWoMxUtIeahjWogsi9asOGc24W2Ic(nDOH7h(Dpv0GcucOsrb5QtF8KQgfSXHTff8mTvzqTBbjByYuq8zbFwtbbgse9JRWt0XUNvzW51zBbL4wyhpxD6JNiXiKaV7BUel)zARYGA3cs2WK9t3RdBlKihsG39nxILNOJDpRYGZRZ2ckXTWo(JLBR0iH6ibPIeagjgHeadjW7(MlXY)nDOH7h(Dpv(JLBR0iroKiFKGabKa7yirUbKibibGPGyv4hdJ(Y4qtbsbnOaL3uPOGC1PpEsvJcIpl4ZAkyQ7)7pxTJvzW8ONmKOvt)CjwuWgh2wuWZv7yvgmp6jdjA1KguGuEuPOGC1PpEsvJcIpl4ZAkiELtxOooJmJeJqcGHeadjW7(MlXYNUfpD1bm9yI(JLBR0iroKqjKyesamKa7yiroKiFKGabKaV7BUel)30HgUF439u5pwUTsJe5qI8gjamsmcjagsGDmKi3asKaKGabKaV7BUel)30HgUF439u5pwUTsJe5qcLqcaJeagjiqaj4IVmv(WKzySq5ojsi9asKpsaykyJdBlkOwIvLvzq81fdjByY0GcePLkffKRo9XtQAuq8zbFwtbXoMxUtIeahjWogsKBajuqbBCyBrb5Ks4h0PpzAqbkVOsrb5QtF8KQgfSXHTff8B6aUFy4WqIowWWWY4JcIpl4ZAki2X8YDsKa4ib2XqICdir(uqSk8JHrFzCOPaPGguGuaiQuuqU60hpPQrbXNf8znfe7yE5ojsaCKa7yirUbKqjkyJdBlki2XGPUNoObfifkOsrb5QtF8KQgfeFwWN1uWu3)3homKLLW3EAiUL0yl2ZRJgtgjYHekYlKyesWfFzQ8HjZWyHYDsKihsWjzSBWWWKzKa4iHcKyesG39nxIL)B6qd3p87EQ8hl3wPrICibNKXUbddtMPGnoSTOG4RXKFwLbZJEYWNL5eLvz0GcKcLOsrb5QtF8KQgfSXHTffmSm(Gs6NmfeFwWN1uqSJ5L7KibWrcSJHe5gqcLqIribWqcLdjI(Xv4DSaIx501ZvN(4jsqGasGx50fQJZiZibGPGyv4hdJ(Y4qtbsbnOaPiFQuuqU60hpPQrbXNf8znfeVYPluhNrMPGnoSTOGyhdsShZ0GcKcsLkffKRo9XtQAuWgh2wuW)tLvzqnFs4kGKnmzki(SGpRPGPU)VpDjdLCl2pxIff0QGVZvsqbvqdkqksavkkixD6JNu1OGnoSTOGPVgtEDdizdtMcIpl4ZAkiELtxOooJmJeJqcGHePU)VpDjdLCl27kbjiqajI(Xv4DSaIx501ZvN(4jsmcjKC8yygE6v4dlJpOK(jJeJqcSJHediHsiXiKaV7BUel)30HgUF439u5pwUTsJesJe5JeeiGeyhZl3jrcGJeyhdjKEajuGeJqcjhpgMHNEfETeRkRYG4Rlgs2WKrIribx8LPYhMmdJfk3jrcPrI8rcatbXQWpgg9LXHMcKcAqdAqbhZN22IcKsasjaPqjLsafKyFLvzAkiPbPxcjqKMaLNqkqcKqkhgjmzj7fiXFpKqze5wYwA4(H7n5tziXXjeU2XtKqVYms0UXk3bprcStxzS2JaGuAfJekifiHYFRX8f8ejuw0pUcFcRmKiwKqzr)4k8jSNRo9XtLHeDGeK(5zKsKaykscypcasPvmsOePaju(BnMVGNiHYI(Xv4tyLHeXIekl6hxHpH9C1PpEQmKOdKG0ppJuIeatrsa7raqkTIrcf5nPaju(BnMVGNiHYI(Xv4tyLHeXIekl6hxHpH9C1PpEQmKaykscypcaeaKgKEjKarAcuEcPajqcPCyKWKLSxGe)9qcLP5JlluPmK44ecx74jsOxzgjA3yL7GNib2PRmw7raqkTIrcfkifiHYFRX8f8ejuw0pUcFcRmKiwKqzr)4k8jSNRo9XtLHeDGeK(5zKsKaykscypcaeaKgKEjKarAcuEcPajqcPCyKWKLSxGe)9qcLHNqnFCzHkLHehNq4Ahprc9kZir7gRCh8ejWoDLXApcasPvmsKxKcKq5V1y(cEIek7Cl(Vxg7tyLHeXIek7Cl(Vxg7typxD6JNkdjaMIKa2JaabaPbPxcjqKMaLNqkqcKqkhgjmzj7fiXFpKqz6qziXXjeU2XtKqVYms0UXk3bprcStxzS2JaGuAfJeKkPaju(BnMVGNiHYI(Xv4tyLHeXIekl6hxHpH9C1PpEQmKOdKG0ppJuIeatrsa7raqkTIrI8MuGek)TgZxWtKqzr)4k8jSYqIyrcLf9JRWNWEU60hpvgsamfjbShbaP0kgjuqQKcKq5V1y(cEIekl6hxHpHvgselsOSOFCf(e2ZvN(4PYqcGPijG9iaqaqAq6LqcePjq5jKcKajKYHrctwYEbs83djugEc18xziXXjeU2XtKqVYms0UXk3bprcStxzS2JaGuAfJe5tkqcL)wJ5l4jsOSZT4)EzSpHvgselsOSZT4)EzSpH9C1PpEQmKaykscypcaeaKgKEjKarAcuEcPajqcPCyKWKLSxGe)9qcLn5F7(cLHehNq4Ahprc9kZir7gRCh8ejWoDLXApcasPvmsOaqKcKq5V1y(cEIekl6hxHpHvgselsOSOFCf(e2ZvN(4PYqIoqcs)8msjsamfjbShbaP0kgjuOGuGek)TgZxWtKqzr)4k8jSYqIyrcLf9JRWNWEU60hpvgs0bsq6NNrkrcGPijG9iaqaqAq6LqcePjq5jKcKajKYHrctwYEbs83djuwVSYqIJtiCTJNiHELzKODJvUdEIeyNUYyThbaP0kgjsaPaju(BnMVGNiHYI(Xv4tyLHeXIekl6hxHpH9C1PpEQmKaykscypcasPvmsOqjsbsO83AmFbprcLf9JRWNWkdjIfjuw0pUcFc75QtF8uzibWuKeWEeaKsRyKqrcifiHYFRX8f8ejuw0pUcFcRmKiwKqzr)4k8jSNRo9XtLHeatrsa7raGaG0uwYEbprI8cjACyBHepthApcakOKB)2JPGKoibPHvtI9JmFirEkBrgbaPdsaqxU9PcjuO8ibjucqkPabacashKqkICtgjYZnDOrI9Je55UNkKWQGVZvsGeVnZWEeaiaiDqcs)Km2n4jsKY)9yKaVYPDGePCMvApsq6HXSKqJe1wa3Pp5V7djACyBPrITEQ8iaACyBP9sogVYPDmizdBleanoST0EjhJx50ouFiX0nIhpH)xRINeTkdgBsRqa04W2s7LCmELt7q9Heh3N1PpMKQL5HKUCb3c6QzyCwrMdswjdAoizC)C5baHaOXHTL2l5y8kN2H6djIDmyQ7PdsS)GYf9JRWR5Jllu55QtF8KabLl6hxH)B6aUFy4WqIowWWWY4ZZvN(4jcGgh2wAVKJXRCAhQpKi2XGe7Xmj2Fq5I(Xv45IVmJ01Qmi)SK855QtF8ebacashKG0pjJDdEIe8y(uHeHjZir4WirJJ9qctJe942ED6J9iaACyBPh0s4(GoDnH64mYmcGgh2wA1hsCCFwN(ysQwMhC23eM0LlswjdAoizC)C5b8UV5sS8wnEjZWKUCbdhgs0XcggwgF(JLBR05(wMtapwUTstGW3YCc4XYTvAPvOeGg9TmNaESCBLohE33CjwEnFCzHk)XYTv6r4DFZLy518XLfQ8hl3wPZPaqiaACyBPvFirjByBrI9hawQ7)718XLfQ8Usiqi19)96ypzi3x4a7Ac)2XExjaEKeo8jD5cgomKOJfmmSm(8noSXmbcFlZjGhl3wPLEiVbecGgh2wA1hse3VhSXHTf8z6GKQL5bnFCzHksS)qQ7)718XLfQ8Usqa04W2sR(qI4(9GnoSTGpthKuTmpqKBjBPH7hU3KpsS)qQ7)7jYTKT0W9d3BYN3vccGgh2wA1hse3VhSXHTf8z6GKQL5Hvcx8rI9hctMLMuhHDmPtWiLtch(KUCbdhgs0XcggwgF(gh2ygbqJdBlT6dj(nDa3pmCyirhlyyyz8rcwf(XWOVmo0dkiX(dyhZl3jbo2XYnK)iGXfFzQ8HjZWyHYDsPvqGax8LPYhMmdJfk3jLMuhH39nxIL)B6qd3p87EQ8hl3wPLwHpbeiG39nxILNi3s2sd3pCVjF(JLBR0sReGra04W2sR(qICsj8d60Nmj2Fa7yE5ojWXowUbfJagx8LPYhMmdJfk3jLwbbc4DFZLy518XLfQ8hl3wPLwjce4IVmv(WKzySq5oP0K6i8UV5sS8FthA4(HF3tL)y52kT0k8jGab8UV5sS8e5wYwA4(H7n5ZFSCBLwALamcGgh2wA1hsmSm(Gs6Nmjyv4hdJ(Y4qpOGe7pGx50fQJZiZJWoMxUtcCSJLBqPraJl(Yu5dtMHXcL7KsRGab8UV5sS8A(4Ycv(JLBR0sRebcCXxMkFyYmmwOCNuAsDeE33Cjw(VPdnC)WV7PYFSCBLwAf(eqGaE33CjwEIClzlnC)W9M85pwUTslTsagbqJdBlT6djI73d24W2c(mDqs1Y8aEc18Ne7pOCr)4k8A(4YcviaACyBPvFirC)EWgh2wWNPdsQwMhWtOMpUSqfj2Fi6hxHxZhxwOcbqJdBlT6djI73d24W2c(mDqs1Y8GoiX(dnoSXmKlw2yT05JaOXHTLw9HeX97bBCyBbFMoiPAzEOxMe7p04WgZqUyzJ15gYhbacGgh2wAFV8arh7EwLbNxNTfuIBHDqa04W2s77LvFirU4lZiDTkdYplPDKy)bSJ5L7Kah7y5guAex8LPYhMmdJfk3jZPebcyhZl3jbo2XYnqQiaACyBP99YQpKOwIvLvzq81fdjByYKy)b8kNUqDCgzEeWsD)F)Slmd3pe7y5H5DLqGWKtD)FF6w80vhW0Jj6DLayeanoST0(Ez1hs8B6qd3p87EQiX(dCXxMkFyYmmwOCNmhNKXUbddtMjqa7yE5ojWXoM0dkqa04W2s77LvFiXZ0wLb1UfKSHjtcwf(XWOVmo0dkiX(dal6hxHNOJDpRYGZRZ2ckXTWoJW7(MlXYFM2QmO2TGKnmz)096W2khE33CjwEIo29SkdoVoBlOe3c74pwUTsRoPc4radV7BUel)30HgUF439u5pwUTsNlFceWowUHeayeanoST0(Ez1hs8C1owLbZJEYqIwnjX(dPU)V)C1owLbZJEYqIwn9ZLyHaOXHTL23lR(qIAjwvwLbXxxmKSHjtI9hWRC6c1XzK5rady4DFZLy5t3INU6aMEmr)XYTv6Ckncyyhlx(eiG39nxIL)B6qd3p87EQ8hl3wPZL3aEeWWowUHeqGaE33Cjw(VPdnC)WV7PYFSCBLoNsagWeiWfFzQ8HjZWyHYDsPhYhWiaACyBP99YQpKiNuc)Go9jtI9hWoMxUtcCSJLBqbcGgh2wAFVS6dj(nDa3pmCyirhlyyyz8rcwf(XWOVmo0dkiX(dyhZl3jbo2XYnKpcGgh2wAFVS6djIDmyQ7PdsS)a2X8YDsGJDSCdkHaOXHTL23lR(qI4RXKFwLbZJEYWNL5eLvzKy)Hu3)3homKLLW3EAiUL0yl2ZRJgtoNI8Aex8LPYhMmdJfk3jZXjzSBWWWKzGRyeE33Cjw(VPdnC)WV7PYFSCBLohNKXUbddtMra04W2s77LvFiXWY4dkPFYKGvHFmm6lJd9GcsS)a2X8YDsGJDSCdkncykx0pUcVJfq8kNUeiGx50fQJZiZagbqJdBlTVxw9HeXogKypMjX(d4voDH64mYmcGgh2wAFVS6dj(FQSkdQ5tcxbKSHjtI9hsD)FF6sgk5wSFUelsSk47CLedkqa04W2s77LvFiX0xJjVUbKSHjtcwf(XWOVmo0dkiX(d4voDH64mY8iGL6()(0LmuYTyVReceI(Xv4DSaIx50DKKJhdZWtVcFyz8bL0p5ryhBqPr4DFZLy5)Mo0W9d)UNk)XYTvAPZNabSJ5L7Kah7yspOyKKJhdZWtVcVwIvLvzq81fdjByYJ4IVmv(WKzySq5oP05dyeaiaACyBP94juZ)bRgVKzysxUGHddj6ybddlJpsS)GYnUpRtFS3zFtysxUiq4Bzob8y52kT0kLaeanoST0E8eQ5V6dj2hUlgg7DCfKy)bSJ5L7Kah7y5guGaOXHTL2JNqn)vFiXyDXoW9dNChoKy)HVL5eWJLBR05aMcslGa(5w8FVm2)7OFWyDXojufkbiatGqQ7)71XEYqUVWb21e(TJ9ZLynsch(KUCbdhgs0XcggwgF(gh2yMaHVL5eWJLBR0sRaqiaACyBP94juZF1hsKi3s2sd3pCVjFKy)bGDTnH8yUcFpNAVv5i1eqGW12eYJ5k89CQ9Usa8i8UV5sS8NPTkdQDlizdt2FSCBLwAojJDdggMmJaOXHTL2JNqn)vFiXFZpRyOowzjKy)b8kNUqDCgzEeWU2MqEmxHVNtT3QCkaebcxBtipMRW3ZP27kbWiaACyBP94juZF1hs83VhxW9M8rI9hU2MqEmxHVNtT3QC5diceU2MqEmxHVNtT3vccGgh2wApEc18x9Het3INU6aMEmrsS)W12eYJ5k89CQ9wLlbaIaHRTjKhZv475u7DLqYZkgINd5nGqa04W2s7XtOM)QpKOo2tgY9foWUMWVDm8Bj7GjX(d4TMUw4X7EtR6GNW9)5sBJzpxD6JNiaACyBP94juZF1hsuh7jd5(chyxt43oMe7pG39nxILxh7jd5(chyxt43o2JD6lJ1dkrGW3YCc4XYTvAPvcqeiaSRTjKhZv475u7pwUTsNtrciqq5W7yU6k8KvDwxJagWU2MqEmxHVNtT3QC4DFZLy51XEYqUVWb21e(TJ9F33dEm2PVmggMmtGGYDTnH8yUcFpNApN00HgWJagE33CjwERgVKzysxUGHddj6ybddlJp)XYTv6C4DFZLy51XEYqUVWb21e(TJ9F33dEm2PVmggMmtGW4(So9XEN9nHjD5cWaEeE33Cjw(VPdnC)WV7PYFSCBLw6H8Ae2XYnO0i8UV5sS8eDS7zvgCED2wqjUf2XFSCBLw6bfkbyeanoST0E8eQ5V6djQJ9KHCFHdSRj8BhtI9hW7yU6k8KvDwxJawQ7)7jYTKT0W9d3BYN3vcbca7Bzob8y52kT04DFZLy5jYTKT0W9d3BYN)y52knbc4DFZLy5jYTKT0W9d3BYN)y52kDo8UV5sS86ypzi3x4a7Ac)2X(V77bpg70xgddtMb8i8UV5sS8FthA4(HF3tL)y52kT0d51iSJLBqPr4DFZLy5j6y3ZQm486STGsClSJ)y52kT0dkucWiaACyBP94juZF1hs0vZqlyzncGgh2wApEc18x9HeJ1f7a3pKCFYnj2F4Bzob8y52kDofjiViqqch(KUCbdhgs0XcggwgF(gh2yMaHX9zD6J9o7Bct6YfcGgh2wApEc18x9HetF7oHF3tfj2FaV7BUelVvJxYmmPlxWWHHeDSGHHLXN)y52kDU8bebcJ7Z60h7D23eM0Llce(wMtapwUTslTsacbqJdBlThpHA(R(qIP8P5JSvzKy)b8UV5sS8wnEjZWKUCbdhgs0XcggwgF(JLBR05YhqeimUpRtFS3zFtysxUiq4Bzob8y52kT0ksacGgh2wApEc18x9HeFwMtOH5H7mtMRabqJdBlThpHA(R(qIF7403UtsS)aE33CjwERgVKzysxUGHddj6ybddlJp)XYTv6C5diceg3N1Pp27SVjmPlxei8TmNaESCBLwAfacbqJdBlThpHA(R(qIDHzDC9dI73Je7pG39nxIL3QXlzgM0Lly4WqIowWWWY4ZFSCBLox(aIaHX9zD6J9o7Bct6YfbcFlZjGhl3wPLwjaHaOXHTL2JNqn)vFiX0odUFyCgMSMe7pK6()EDSNmK7lCGDnHF7y)Cjwiaqa04W2s7XtOMpUSq1W4(So9XKuTmpO5JllubtDpDqYkzqZbjJ7NlpG39nxILxZhxwOYFSCBLwAfeiiHdFsxUGHddj6ybddlJpFJdBmpcV7BUelVMpUSqL)y52kDU8bebcFlZjGhl3wPLwjaHaOXHTL2JNqnFCzHk1hs0QXlzgM0Lly4WqIowWWWY4Je7pOCJ7Z60h7D23eM0Llce(wMtapwUTslTsjabqJdBlThpHA(4YcvQpKORMHwWYAeanoST0E8eQ5JlluP(qI9H7IHXEhxbj2Fa7yE5ojWXowUbfiaACyBP94juZhxwOs9HeFwMtOH5H7mtMRabqJdBlThpHA(4YcvQpK43oo9T7Ke7pmUpRtFSxZhxwOcM6E6abqJdBlThpHA(4YcvQpKyxywhx)G4(9iX(dJ7Z60h718XLfQGPUNoqa04W2s7XtOMpUSqL6djM2zW9dJZWK1Ky)HX9zD6J9A(4YcvWu3thiaACyBP94juZhxwOs9HeJ1f7a3pCYD4qI9h(wMtapwUTsNdykiTac4NBX)9Yy)VJ(bJ1f7KqvOeGambcs4WN0Lly4WqIowWWWY4Z34WgZei8TmNaESCBLwAfacbqJdBlThpHA(4YcvQpKySUyh4(HK7tUjX(dFlZjGhl3wPZLxaIabjC4t6YfmCyirhlyyyz85BCyJzce(wMtapwUTslTcaHaOXHTL2JNqnFCzHk1hsKi3s2sd3pCVjFKy)b8UV5sS8NPTkdQDlizdt2FSCBLwAojJDdggMmJaOXHTL2JNqnFCzHk1hs838ZkgQJvwccGgh2wApEc18XLfQuFiXF)ECb3BYhcGgh2wApEc18XLfQuFiX0T4PRoGPhtebqJdBlThpHA(4YcvQpKOMpUSqfj2FaV7BUel)zARYGA3cs2WK9hl3wPLwjce(wMtapwUTslTIeGaOXHTL2JNqnFCzHk1hsmTZG7hgNHjRraGaOXHTL2Vs4IVHVPd4(HHddj6ybddlJpsWQWpgg9DzCOhuqI9hWoMxUtcCSJLBiFeanoST0(vcx8P(qICsj8d60Nmj2Fi6hxHh7yWu3thEU60hphHDmVCNe4yhl3q(iaACyBP9ReU4t9HedlJpOK(jtcwf(XWOVmo0dkiX(d4voDH64mY8iSJ5L7Kah7y5gucbqJdBlTFLWfFQpKi2XGe7Xmj2Fa7yE5ojWXo2GsiaACyBP9ReU4t9He5Ks4h0PpzeanoST0(vcx8P(qIHLXhus)KjbRc)yy0xgh6bfKy)bSJ5L7Kah7y5gucbacGgh2wAVMpUSq1W30HgUF439urI9hsD)FVMpUSqL)y52kT0kqa04W2s718XLfQuFirxndTGL1iaACyBP9A(4YcvQpKOwIvLvzq81fdjByYKy)b8kNUqDCgzEeWACyJzixSSX6Cd5tGqJdBmd5ILnwNtXiLdV7BUel)zARYGA3cs2WK9UsamcGgh2wAVMpUSqL6djEM2QmO2TGKnmzsWQWpgg9LXHEqbj2FaVYPluhNrMra04W2s718XLfQuFiXVPdnC)WV7PIe7p04WgZqUyzJ15gYhbqJdBlTxZhxwOs9He1sSQSkdIVUyizdtMe7pGx50fQJZiZJsD)F)Slmd3pe7y5H5DLGaOXHTL2R5JlluP(qIPVgtEDdizdtMeSk8JHrFzCOhuqI9hWRC6c1XzK5rPU)VNi3s2sd3pCVjFqIe9UsgH39nxIL)mTvzqTBbjByY(JLBR05ucbqJdBlTxZhxwOs9He)Mo0W9d)UNksSk47CLeq7pK6()EnFCzHkVRKr4DFZLy5ptBvgu7wqYgMS)4EQcbqJdBlTxZhxwOs9He1sSQSkdIVUyizdtMe7pGx50fQJZiZJMCQ7)7t3INU6aMEmrVReeanoST0EnFCzHk1hs8B6aUFy4WqIowWWWY4JeSk8JHrFzCOhuqI9hWoM05JaOXHTL2R5JlluP(qIPVgtEDdizdtMeSk8JHrFzCOhuqI9hWRC6c1XzKzceuUOFCfEhlG4voDra04W2s718XLfQuFirTeRkRYG4Rlgs2WKraGaOXHTL2RJbIo29SkdoVoBlOe3c7qI9hU2MqEmxHVNtT3QC4DFZLy5j6y3ZQm486STGsClSJF6EDyBLqbKN0sGW12eYJ5k89CQ9Usqa04W2s71H6djYfFzgPRvzq(zjTJe7pGDmVCNe4yhl3GsJ4IVmv(WKzySq5ozU8jqa7yE5ojWXowUbsDeW4IVmv(WKzySq5ozoLiqq5KC8yygE6v4dlJpOK(jdyeanoST0EDO(qIAjwvwLbXxxmKSHjtI9hWRC6c1XzK5rPU)VF2fMH7hIDS8W8UsgbSRTjKhZv475u7TkxQ7)7NDHz4(Hyhlpm)XYTvAGRebcxBtipMRW3ZP27kbWiaACyBP96q9HeptBvgu7wqYgMmjyv4hdJ(Y4qpOGe7pG39nxILxZhxwOYFSCBLoNcceuUOFCfEnFCzHkeanoST0EDO(qIFthA4(HF3tfj2FayxBtipMRW3ZP2Bvo8UV5sS8FthA4(HF3tLF6EDyBLqbKN0sGW12eYJ5k89CQ9Usa8iGXfFzQ8HjZWyHYDYCCsg7gmmmzg4kiqa7yE5ojWXoM0dkiqi19)96ypzi3x4a7Ac)2X(JLBR0sZjzSBWWWKz1vayce(wMtapwUTslnNKXUbddtMvxbcGgh2wAVouFir81yYpRYG5rpz4ZYCIYQmsS)qQ7)7dhgYYs4Bpne3sASf751rJjNtrEnIl(Yu5dtMHXcL7K54Km2nyyyYmWvmcV7BUel)zARYGA3cs2WK9hl3wPZXjzSBWWWKzcesD)FF4WqwwcF7PH4wsJTypVoAm5Cki1radV7BUelVMpUSqL)y52kT0jyu0pUcVMpUSqfbc4DFZLy5jYTKT0W9d3BYN)y52kT0jyeEhZvxHNSQZ6IaHVL5eWJLBR0sNaaJaOXHTL2Rd1hs8C1owLbZJEYqIwnjX(dPU)V)C1owLbZJEYqIwn9ZLynQXHnMHCXYgRZPabqJdBlTxhQpK430bC)WWHHeDSGHHLXhjyv4hdJ(Y4qpOGe7pGDmPZhbqJdBlTxhQpKiNuc)Go9jtI9hWoMxUtcCSJLBqbcGgh2wAVouFirSJbtDpDqI9hWoMxUtcCSJLBqXOgh2ygYflBSEqXORTjKhZv475u7TkNsaIabSJ5L7Kah7y5guAuJdBmd5ILnwNBqjeanoST0EDO(qIyhdsShZiaACyBP96q9HedlJpOK(jtcwf(XWOVmo0dkiHe7pGx50fQJZiZJWoMxUtcCSJLBqPrPU)Vxh7jd5(chyxt43o2pxIfcGgh2wAVouFirTeRkRYG4Rlgs2WKjX(dPU)Vh7yqU4ltLxhnMCU8beWtqcTXHnMHCXYgRhL6()EDSNmK7lCGDnHF7y)CjwJagE33Cjw(Z0wLb1UfKSHj7pwUTsNtPr4DFZLy5)Mo0W9d)UNk)XYTv6CkrGaE33Cjw(Z0wLb1UfKSHj7pwUTslD(JW7(MlXY)nDOH7h(Dpv(JLBR05YFe2XYLpbc4DFZLy5ptBvgu7wqYgMS)y52kDU8hH39nxIL)B6qd3p87EQ8hl3wPLo)ryhlhPsGa2X8YDsGJDmPhumIl(Yu5dtMHXcL7KsReGjqi19)9yhdYfFzQ86OXKZPaqJ(wMtapwUTslTYdbqJdBlTxhQpKy6RXKx3as2WKjbRc)yy0xgh6bfKy)b8kNUqDCgzEeWI(Xv418XLfQgH39nxILxZhxwOYFSCBLw68jqaV7BUel)zARYGA3cs2WK9hl3wPZPyeE33Cjw(VPdnC)WV7PYFSCBLoNcceW7(MlXYFM2QmO2TGKnmz)XYTvAPZFeE33Cjw(VPdnC)WV7PYFSCBLox(JWowoLiqaV7BUel)zARYGA3cs2WK9hl3wPZL)i8UV5sS8FthA4(HF3tL)y52kT05pc7y5YNabSJLlbeiK6()(0LmuYTyVReaJaOXHTL2Rd1hsmSm(Gs6Nmjyv4hdJ(Y4qpOGesS)aELtxOooJmpc7yE5ojWXowUbLqa04W2s71H6dj(FQSkdQ5tcxbKSHjtIvbFNRKyqbcashKipnnJeQT5PJe2hjYZ38CKW0ib(TAgj6AIeQwxKWPhZiHsib2XqIUMiHQ19qIxRdKi7TP9dji2AKqQ8ujbj2djSpsOADrI(yKOtx3ajIfjWTeKGl(YuHeDnrc2ch(qcvR7HeVwhirgEIeeBnsivEQiXEiH9rcvRls0hJepwRrIWPlKqjKa7yirtSvHe)BLrcClrIvziaACyBP96q9HetFnM86gqYgMmjyv4hdJ(Y4qpOGe7pGx50fQJZiZJW7(MlXY)nDOH7h(Dpv(JLBR0sN)iSJnO0ijhpgMHNEf(WY4dkPFYJ4IVmv(WKzySWeaiPvGaOXHTL2Rd1hsm91yYRBajByYKGvHFmm6lJd9GcsS)aELtxOooJmpIl(Yu5dtMHXcL7KsR0iGHDmVCNe4yht6bfeii54XWm80RWhwgFqj9tgWiaqa04W2s7jYTKT0W9d3BY3aUFpyJdBl4Z0bjvlZd4juZFsS)GYf9JRWR5JlluHaOXHTL2tKBjBPH7hU3Kp1hse3VhSXHTf8z6GKQL5b8eQ5JllurI9hI(Xv418XLfQqa04W2s7jYTKT0W9d3BYN6djYfFzgPRvzq(zjTJe7pGDmVCNe4yhl3GsJ4IVmv(WKzySq5ozU8ra04W2s7jYTKT0W9d3BYN6djEM2QmO2TGKnmzsWQWpgg9LXHEqbcGgh2wAprULSLgUF4Et(uFirTeRkRYG4Rlgs2WKjX(d4voDH64mY8Ou3)3p7cZW9dXowEyExjiaACyBP9e5wYwA4(H7n5t9He)Mo0W9d)UNksS)qJdBmd5ILnwNBqPrPU)VNi3s2sd3pCVjFqIe9hl3wPLwbcGgh2wAprULSLgUF4Et(uFirIo29SkdoVoBlOe3c7qI9hACyJzixSSX6CdkHaOXHTL2tKBjBPH7hU3Kp1hsulXQYQmi(6IHKnmzsS)aELtxOooJmpQXHnMHCXYgRZnK)Ou3)3tKBjBPH7hU3KpirIExjiaACyBP9e5wYwA4(H7n5t9HetFnM86gqYgMmjyv4hdJ(Y4qpOGe7pGx50fQJZiZJACyJzixSSXAPhucbqJdBlTNi3s2sd3pCVjFQpKirh7EwLbNxNTfuIBHDqa04W2s7jYTKT0W9d3BYN6dj(nDOH7h(DpvKyvW35kjG2Fi19)9e5wYwA4(H7n5dsKO3vcj2Fi19)96ypzi3x4a7Ac)2XExjJU2MqEmxHVNtT3QC4DFZLy5)Mo0W9d)UNk)096W2kHciFEJaOXHTL2tKBjBPH7hU3Kp1hsulXQYQmi(6IHKnmzsS)qQ7)7XogKl(Yu51rJjNlFab8eKqBCyJzixSSXAeanoST0EIClzlnC)W9M8P(qIFthW9ddhgs0XcggwgFKGvHFmm6lJd9GcsS)a2XKoFeanoST0EIClzlnC)W9M8P(qICsj8d60Nmj2Fa7yE5ojWXowUbfiaACyBP9e5wYwA4(H7n5t9HeXogm190bj2Fa7yE5ojWXowUbGPq9gh2ygYflBSoNcaJaOXHTL2tKBjBPH7hU3Kp1hsmSm(Gs6Nmjyv4hdJ(Y4qpOGe7pamLl6hxH3XciELtxceWRC6c1XzKzapc7yE5ojWXowUbLqa04W2s7jYTKT0W9d3BYN6djIDmiXEmJaOXHTL2tKBjBPH7hU3Kp1hsm91yYRBajByYKGvHFmm6lJd9GcsS)a2XYnKpbcPU)VNi3s2sd3pCVjFqIe9Usqa04W2s7jYTKT0W9d3BYN6dj(FQSkdQ5tcxbKSHjtIvbFNRKyqbfSDdN9OGGMSYNg0Gsb]] )

end