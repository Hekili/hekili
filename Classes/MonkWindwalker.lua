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
    
    spec:RegisterPack( "Windwalker", 20201222, [[d0KF2bqisvXJqkK2KO0NeHmkKIofbLvHuiEfPkZcj6wiH2fv9lrWWqcogP0Yqk9mfIPHuW1ivvBtHeFteQmoKc15uiL1rqLMhPI7PG9jkoiPQKwiPspKuvQjsqvOlsqvAJIqv9rfsvDssvjwjO4Leuf0mjOIBsqvu7eu6NIqvgkbvrwQcPkpvvMkb5Qeuf4ReuvnwfsAVi(lWGj6WsTyr6XqnzfDzuBgKplQgnvCAkRwekVgPA2QQBtODl53knCcCCcQklxLNtY0fUovA7kuFhjnEr05jfRxHuz(GQ9dzIwIqK3SdMalTuGwkOLwAP1RLggHgOL8cncyYtqJP35m5vTitEc)wnP2F68rEcAn)TNeHip16EyM8iVux7h6lfjL8MDWeyPLc0sbT0slTET0aTJcTJqEkbmMalTJYOrEo2CYfjL8MSctE0OiPWVvtQ9NoFiPWZBrhbdnksk8iJzXu(qsAPLsKKwkqlfqWGGHgfjfIk30rYeFtfkKCHqYeF3tdsAvW35kiqY)MByp59nvOicrERaU4JiebwTeHipU60ppj6sEnoSTipitfGfceomGQJfmiSC(ip8zbFwtEyhZl2jrskIKyhdjZmGKJqEyn4pdI(UCouKNwsqGLwIqKhxD6NNeDjp8zbFwtEr)5k8yhdK6EQWZvN(5jsMfjXoMxStIKuejXogsMzajhH8ACyBrECsb8h40NijiWocriYJRo9ZtIUKh(SGpRjp8kMUavCgDgjZIKyhZl2jrskIKyhdjZmGK0sEnoSTiVWY5diO)IKhwd(ZGOVCouey1sccS0ariYJRo9ZtIUKh(SGpRjpSJ5f7KijfrsSJHKdijTKxJdBlYd7yaQ9yMeey1priYRXHTf5XjfWFGtFIKhxD6NNeDjbb2rHie5XvN(5jrxYdFwWN1Kh2X8IDsKKIij2XqYmdijTKxJdBlYlSC(ac6Vi5H1G)mi6lNdfbwTKGeKhvUfSLcSqG9M8reIaRwIqKhxD6NNeDjVgh2wKhU)FqJdBlW3ub5Hpl4ZAYtFqYO)CfEfFCzHgpxD6NNK33ubOArM8WtGIHibbwAjcrEC1PFEs0L8ACyBrE4()bnoSTaFtfKh(SGpRjVO)CfEfFCzHgpxD6NNK33ubOArM8WtGIpUSqdjiWocriYJRo9ZtIUKh(SGpRjpSJ5f7KijfrsSJHKzgqsArYSijx8LRXhMidIfi2jrYmi5iKxJdBlYJl(YTrNv5a(BjTJeeyPbIqKhxD6NNeDjVgh2wK3zkRYbk3cq3W0jpSg8NbrF5COiWQLeey1priYJRo9ZtIUKh(SGpRjp8kMUavCgDgjZIKPUqq(zxygSqaSJLyM3va514W2I8ucSQSkhGVUyaDdtNeeyhfIqKhxD6NNeDjp8zbFwtEnoSXmGlw0yfsMzajPfjZIKPUqqEQClylfyHa7n5dqLQ)yX2kfsQdsQL8ACyBrEqMkuGfca5EAibb2ehriYJRo9ZtIUKh(SGpRjVgh2ygWflAScjZmGK0sEnoSTipQo29TkhmVoFlGa3c7qccS0yIqKhxD6NNeDjp8zbFwtE4vmDbQ4m6msMfjBCyJzaxSOXkKmZasocsMfjtDHG8u5wWwkWcb2BYhGkvVRaYRXHTf5PeyvzvoaFDXa6gMojiWoAeHipU60ppj6sE4Zc(SM8WRy6cuXz0zKmls24WgZaUyrJviPodijTKxJdBlYl93y6RBaOBy6Khwd(ZGOVCouey1sccSAPariYRXHTf5r1XUVv5G515Bbe4wyhYJRo9ZtIUKGaRwTeHipRc(oxbbWGiVuxiipvUfSLcSqG9M8bOs17kG84Qt)8KOl514W2I8GmvOaleaY90qE4Zc(SM8sDHG8Qypra3x4a6AcGSJ9UcqYSi512eWJ5k89CQ8wHKzqs8U)5sT8qMkuGfca5EA8t3RdBlKKgbjPGFuibbwT0seI84Qt)8KOl5Hpl4ZAYl1fcYJDmax8LRXRIgthjZGKJqbKKIiP(rsAeKSXHnMbCXIgRiVgh2wKNsGvLv5a81fdOBy6KGaR2ricrEC1PFEs0L8WNf8zn5HDmKuhKCeYRXHTf5bzQaSqGWHbuDSGbHLZh5H1G)mi6lNdfbwTKGaRwAGie5XvN(5jrxYdFwWN1Kh2X8IDsKKIij2XqYmdiPwYRXHTf5XjfWFGtFIKGaRw9teI84Qt)8KOl5Hpl4ZAYd7yEXojssrKe7yizMbKKMiPwKupKSXHnMbCXIgRqYmiPwKuyKxJdBlYd7yGu3tfKGaR2rHie5XvN(5jrxYdFwWN1Khnrs9bjJ(Zv4DSaGxX01ZvN(5jschosIxX0fOIZOZiPWqYSij2X8IDsKKIij2XqYmdijTKxJdBlYlSC(ac6Vi5H1G)mi6lNdfbwTKGaR2ehriYRXHTf5HDma1EmtEC1PFEs0Leey1sJjcrEC1PFEs0L8WNf8zn5HDmKmZasocschosM6cb5PYTGTuGfcS3KpavQExbKxJdBlYl93y6RBaOBy6Khwd(ZGOVCouey1sccSAhnIqKNvbFNRGG80sEnoSTipOVgRYbk(eWvaOBy6KhxD6NNeDjbjipfFCzHgIqey1seI84Qt)8KOl5Hpl4ZAYl1fcYR4Jll04pwSTsHK6GKAjVgh2wKhKPcfyHaqUNgsqGLwIqKhxD6NNeDjVQfzYZkf(CJo9ZaHp3UcxrWKhByM8ACyBrEwPWNB0PFgi852v4kcM8ydZKGa7ieHipU60ppj6sEvlYK384EczhdgZkf)jVgh2wK384EczhdgZkf)jbbwAGie5XvN(5jrxYdFwWN1KhEftxGkoJoJKzrsAIKnoSXmGlw0yfsMzajhbjHdhjBCyJzaxSOXkKmdsQfjZIK6dsI39pxQL)mLv5aLBbOBy6ExbiPWiVgh2wKNsGvLv5a81fdOBy6KGaR(jcrEC1PFEs0L8WNf8zn5HxX0fOIZOZKxJdBlY7mLv5aLBbOBy6Khwd(ZGOVCouey1sccSJcriYJRo9ZtIUKh(SGpRjVgh2ygWflAScjZmGKJqEnoSTipitfkWcbGCpnKGaBIJie5XvN(5jrxYdFwWN1KhEftxGkoJoJKzrYuxii)Slmdwia2XsmZ7kG8ACyBrEkbwvwLdWxxmGUHPtccS0yIqKhxD6NNeDjp8zbFwtE4vmDbQ4m6msMfjtDHG8u5wWwkWcb2BYhGkvVRaKmlsI39pxQL)mLv5aLBbOBy6(JfBRuizgKKwYRXHTf5L(Bm91na0nmDYdRb)zq0xohkcSAjbb2rJie5zvW35kiage5L6cb5v8XLfA8UcYI39pxQL)mLv5aLBbOBy6(J7PgYRXHTf5bzQqbwiaK7PH84Qt)8KOljiWQLceHipU60ppj6sE4Zc(SM8WRy6cuXz0zKmlso5uxiiF6w80vfG0JP6DfqEnoSTipLaRkRYb4Rlgq3W0jbbwTAjcrEC1PFEs0L8WNf8zn5HDmKuhKCeYRXHTf5bzQaSqGWHbuDSGbHLZh5H1G)mi6lNdfbwTKGaRwAjcrEC1PFEs0L8WNf8zn5HxX0fOIZOZijC4iP(GKr)5k8owaWRy665Qt)8K8ACyBrEP)gtFDdaDdtN8WAWFge9LZHIaRwsqGv7ieHiVgh2wKNsGvLv5a81fdOBy6KhxD6NNeDjbjip8eO4Jll0qeIaRwIqKhxD6NNeDjVva5P4G8ACyBrEJ7Z60ptEJ7VltE4D)ZLA5v8XLfA8hl2wPqsDqsTijC4iPao8jD5ceomGQJfmiSC(8noSXmsMfjX7(Nl1YR4Jll04pwSTsHKzqYrOaschoscz5ob4yX2kfsQdsslfiVX9bQwKjpfFCzHgqQ7PcsqGLwIqKhxD6NNeDjp8zbFwtE6dsoUpRt)S3z)tqsxUqs4Wrsil3jahl2wPqsDqsA1p514W2I8SA8sNbjD5IeeyhHie5XvN(5jrxYRArM8ALZ4Uyf46r3Ea8E9N8ACyBrETYzCxScC9OBpaEV(tccS0ariYRXHTf55QyGfSOI84Qt)8KOljiWQFIqKhxD6NNeDjp8zbFwtEyhZl2jrskIKyhdjZmGKAjVgh2wKxF4UyqS3XvqccSJcriYRXHTf59TCNqbsm3zUixb5XvN(5jrxsqGnXreI84Qt)8KOl5Hpl4ZAYBCFwN(zVIpUSqdi19ub514W2I8GSJt)7ojbbwAmriYJRo9ZtIUKh(SGpRjVX9zD6N9k(4YcnGu3tfKxJdBlYRlmRIR)aC))KGa7OreI84Qt)8KOl5Hpl4ZAYBCFwN(zVIpUSqdi19ub514W2I8s7CWcbIZW0vKGaRwkqeI84Qt)8KOl5Hpl4ZAYdYYDcWXITvkKmdsQLgtbKeoCKuah(KUCbchgq1XcgewoF(gh2ygjHdhjHSCNaCSyBLcj1bj1sbYRXHTf5fRl2bSqGj3HdjiWQvlriYJRo9ZtIUKh(SGpRjpil3jahl2wPqYmi5OrbKeoCKuah(KUCbchgq1XcgewoF(gh2ygjHdhjHSCNaCSyBLcj1bj1sbYRXHTf5fRl2bSqa69j2KGaRwAjcrEC1PFEs0L8WNf8zn5H39pxQL)mLv5aLBbOBy6(JfBRuiPoijNKXUbdctKjVgh2wKhvUfSLcSqG9M8rccSAhHie514W2I8GA(BfduXkkG84Qt)8KOljiWQLgicrEnoSTipO()5cS3KpYJRo9ZtIUKGaRw9teI8ACyBrEPBXtxvaspMk5XvN(5jrxsqGv7OqeI84Qt)8KOl5Hpl4ZAYdV7FUul)zkRYbk3cq3W09hl2wPqsDqsArs4Wrsil3jahl2wPqsDqsT6N8ACyBrEk(4YcnKGaR2ehriYRXHTf5L25GfceNHPRipU60ppj6scsqEQGiebwTeHipU60ppj6sE4Zc(SM8U2MaEmxHVNtL3kKmdsI39pxQLNQJDFRYbZRZ3ciWTWo(P71HTfssJGKuWtJrs4WrYRTjGhZv475u5DfqEnoSTipQo29TkhmVoFlGa3c7qccS0seI84Qt)8KOl5Hpl4ZAYd7yEXojssrKe7yizMbKKwKmlsYfF5A8HjYGybIDsKmdsocschosIDmVyNejPisIDmKmZassdizwKKMijx8LRXhMidIfi2jrYmijTijC4iP(GKcoEmihp9A9HLZhqq)frsHrEnoSTipU4l3gDwLd4VL0osqGDeIqKhxD6NNeDjp8zbFwtE4vmDbQ4m6msMfjtDHG8ZUWmyHayhlXmVRaKmlsstK8ABc4XCf(EovERqYmizQleKF2fMblea7yjM5pwSTsHKuejPfjHdhjV2MaEmxHVNtL3vaskmYRXHTf5PeyvzvoaFDXa6gMojiWsdeHipU60ppj6sE4Zc(SM8W7(Nl1YR4Jll04pwSTsHKzqsTijC4iP(GKr)5k8k(4YcnEU60ppjVgh2wK3zkRYbk3cq3W0jpSg8NbrF5COiWQLeey1priYJRo9ZtIUKh(SGpRjpAIKxBtapMRW3ZPYBfsMbjX7(Nl1YdzQqbwiaK7PXpDVoSTqsAeKKcEAmschosETnb8yUcFpNkVRaKuyizwKKMijx8LRXhMidIfi2jrYmijNKXUbdctKrskIKArs4WrsSJ5f7KijfrsSJHK6mGKArs4WrYuxiiVk2teW9foGUMai7y)XITvkKuhKKtYy3GbHjYiPEiPwKuyijC4ijKL7eGJfBRuiPoijNKXUbdctKrs9qsTKxJdBlYdYuHcSqai3tdjiWokeHipU60ppj6sE4Zc(SM8sDHG8Hddyrb8TNcGBbn2I98QOX0rYmiP2rdjZIKCXxUgFyImiwGyNejZGKCsg7gmimrgjPisQfjZIK4D)ZLA5ptzvoq5wa6gMU)yX2kfsMbj5Km2nyqyImschosM6cb5dhgWIc4Bpfa3cASf75vrJPJKzqsT0asMfjPjsI39pxQLxXhxwOXFSyBLcj1bj1psMfjJ(Zv4v8XLfA8C1PFEIKWHJK4D)ZLA5PYTGTuGfcS3Kp)XITvkKuhKu)izwKeVJ5QRWtxZzDHKWHJKqwUtaowSTsHK6GK6hjfg514W2I8WxJP)TkhKy9KbFl3jkRYjbb2ehriYJRo9ZtIUKh(SGpRjVuxii)5QCSkhKy9KbuTA6Nl1cjZIKnoSXmGlw0yfsMbj1sEnoSTiVZv5yvoiX6jdOA1KeeyPXeHipU60ppj6sE4Zc(SM8WogsQdsoc514W2I8Gmvawiq4WaQowWGWY5J8WAWFge9LZHIaRwsqGD0icrEC1PFEs0L8WNf8zn5HDmVyNejPisIDmKmZasQL8ACyBrECsb8h40NijiWQLceHipU60ppj6sE4Zc(SM8WoMxStIKuejXogsMzaj1IKzrYgh2ygWflAScjhqsTizwK8ABc4XCf(EovERqYmijTuajHdhjXoMxStIKuejXogsMzajPfjZIKnoSXmGlw0yfsMzajPL8ACyBrEyhdK6EQGeey1QLie514W2I8WogGApMjpU60ppj6sccSAPLie5XvN(5jrxYdFwWN1KhEftxGkoJoJKzrsSJ5f7KijfrsSJHKzgqsArYSizQleKxf7jc4(chqxtaKDSFUulYRXHTf5fwoFab9xK8WAWFge9LZHIaRwsqGv7ieHipU60ppj6sE4Zc(SM8sDHG8yhdWfF5A8QOX0rYmi5iuajPisQFKKgbjBCyJzaxSOXkKmlsM6cb5vXEIaUVWb01eazh7Nl1cjZIK0ejX7(Nl1YFMYQCGYTa0nmD)XITvkKmdsslsMfjX7(Nl1YdzQqbwiaK7PXFSyBLcjZGK0IKWHJK4D)ZLA5ptzvoq5wa6gMU)yX2kfsQdsocsMfjX7(Nl1YdzQqbwiaK7PXFSyBLcjZGKJGKzrsSJHKzqYrqs4Wrs8U)5sT8NPSkhOClaDdt3FSyBLcjZGKJGKzrs8U)5sT8qMkuGfca5EA8hl2wPqsDqYrqYSij2XqYmijnGKWHJKyhZl2jrskIKyhdj1zaj1IKzrsU4lxJpmrgelqStIK6GK0IKcdjHdhjtDHG8yhdWfF5A8QOX0rYmiPwkGKzrsil3jahl2wPqsDqYeh514W2I8ucSQSkhGVUyaDdtNeey1sdeHipU60ppj6sE4Zc(SM8WRy6cuXz0zKmlsstKm6pxHxXhxwOXZvN(5jsMfjX7(Nl1YR4Jll04pwSTsHK6GKJGKWHJK4D)ZLA5ptzvoq5wa6gMU)yX2kfsMbj1IKzrs8U)5sT8qMkuGfca5EA8hl2wPqYmiPwKeoCKeV7FUul)zkRYbk3cq3W09hl2wPqsDqYrqYSijE3)CPwEitfkWcbGCpn(JfBRuizgKCeKmlsIDmKmdsslschosI39pxQL)mLv5aLBbOBy6(JfBRuizgKCeKmlsI39pxQLhYuHcSqai3tJ)yX2kfsQdsocsMfjXogsMbjhbjHdhjXogsMbj1pschosM6cb5tx6ab3I9UcqsHrEnoSTiV0FJPVUbGUHPtEyn4pdI(Y5qrGvljiWQv)eHipU60ppj6sE4Zc(SM8WRy6cuXz0zKmlsIDmVyNejPisIDmKmZassl514W2I8clNpGG(lsEyn4pdI(Y5qrGvljiWQDuicrEwf8DUccYtl514W2I8G(ASkhO4taxbGUHPtEC1PFEs0Leey1M4icrEC1PFEs0L8WNf8zn5HxX0fOIZOZizwKeV7FUulpKPcfyHaqUNg)XITvkKuhKCeKmlsIDmKCajPfjZIKcoEmihp9A9HLZhqq)frYSijx8LRXhMidIfOFkGK6GKAjVgh2wKx6VX0x3aq3W0jpSg8NbrF5COiWQLeey1sJjcrEC1PFEs0L8WNf8zn5HxX0fOIZOZizwKKl(Y14dtKbXce7KiPoijTizwKKMij2X8IDsKKIij2XqsDgqsTijC4iPGJhdYXtVwFy58be0FrKuyKxJdBlYl93y6RBaOBy6Khwd(ZGOVCouey1scsqE4jqXqeHiWQLie5XvN(5jrxYdFwWN1KN(GKJ7Z60p7D2)eK0LlKeoCKeYYDcWXITvkKuhKKw9tEnoSTipRgV0zqsxUibbwAjcrEC1PFEs0L8WNf8zn5HDmVyNejPisIDmKmZasQL8ACyBrE9H7IbXEhxbjiWocriYJRo9ZtIUKh(SGpRjVuxiiVk2teW9foGUMai7y)CPwizwKuah(KUCbchgq1XcgewoF(gh2ygjHdhjHSCNaCSyBLcj1bj1sbKeoCKeYYDcWXITvkKmdsQLgtbYRXHTf5fRl2bSqGj3HdjiWsdeHipU60ppj6sE4Zc(SM8OjsETnb8yUcFpNkVvizgKKg0pschosETnb8yUcFpNkVRaKuyizwKeV7FUul)zkRYbk3cq3W09hl2wPqsDqsojJDdgeMitEnoSTipQClylfyHa7n5Jeey1priYJRo9ZtIUKh(SGpRjp8kMUavCgDgjZIK0ejV2MaEmxHVNtL3kKmdsQLcijC4i512eWJ5k89CQ8UcqsHrEnoSTipOM)wXavSIcibb2rHie5XvN(5jrxYdFwWN1K312eWJ5k89CQ8wHKzqYrOaschosETnb8yUcFpNkVRaYRXHTf5b1)pxG9M8rccSjoIqKhxD6NNeDjVgh2wKx6w80vfG0JPsE4Zc(SM8U2MaEmxHVNtL3kKmdsQFkGKWHJKxBtapMRW3ZPY7kG8(wXa8K8gfkqccS0yIqKhxD6NNeDjp8zbFwtE4TMUw4X7EtR6GNGfcIlLnM9C1PFEsEnoSTipvSNiG7lCaDnbq2XailzhmjiWoAeHipU60ppj6sE4Zc(SM8W7(Nl1YRI9ebCFHdORjaYo2JD6lNvi5asslschoscz5ob4yX2kfsQdsslfqs4WrsAIKxBtapMRW3ZPYFSyBLcjZGKA1pschosQpijEhZvxHNUMZ6cjZIK0ejPjsETnb8yUcFpNkVvizgKeV7FUulVk2teW9foGUMai7ypK7)dog70xodctKrs4Wrs9bjV2MaEmxHVNtLNtAQqHKcdjZIK0ejX7(Nl1YB14Lods6YfiCyavhlyqy585pwSTsHKzqs8U)5sT8Qypra3x4a6AcGSJ9qU)p4yStF5mimrgjHdhjh3N1PF27S)jiPlxiPWqsHHKzrs8U)5sT8qMkuGfca5EA8hl2wPqsDgqYrdjZIKyhdjZmGK0IKzrs8U)5sT8uDS7BvoyED(wabUf2XFSyBLcj1zaj1slskmYRXHTf5PI9ebCFHdORjaYoMeey1sbIqKhxD6NNeDjp8zbFwtE4DmxDfE6AoRlKmlsstKm1fcYtLBbBPaleyVjFExbijC4ijnrsil3jahl2wPqsDqs8U)5sT8u5wWwkWcb2BYN)yX2kfschosI39pxQLNk3c2sbwiWEt(8hl2wPqYmijE3)CPwEvSNiG7lCaDnbq2XEi3)hCm2PVCgeMiJKcdjZIK4D)ZLA5HmvOaleaY904pwSTsHK6mGKJgsMfjXogsMzajPfjZIK4D)ZLA5P6y33QCW868TacClSJ)yX2kfsQZasQLwKuyKxJdBlYtf7jc4(chqxtaKDmjiWQvlriYRXHTf55QyGfSOI84Qt)8KOljiWQLwIqKhxD6NNeDjp8zbFwtEqwUtaowSTsHKzqsT6F0qs4WrsbC4t6YfiCyavhlyqy585BCyJzKeoCKCCFwN(zVZ(NGKUCrEnoSTiVyDXoGfcqVpXMeey1ocriYJRo9ZtIUKh(SGpRjp8U)5sT8wnEPZGKUCbchgq1XcgewoF(JfBRuizgKCekGKWHJKJ7Z60p7D2)eK0LlKeoCKeYYDcWXITvkKuhKKwkqEnoSTiV0)UtaK7PHeey1sdeHipU60ppj6sE4Zc(SM8W7(Nl1YB14Lods6YfiCyavhlyqy585pwSTsHKzqYrOaschosoUpRt)S3z)tqsxUqs4Wrsil3jahl2wPqsDqsT6N8ACyBrEP8P4JUv5KGaRw9teI8ACyBrEFl3juGeZDMlYvqEC1PFEs0Leey1okeHipU60ppj6sE4Zc(SM8W7(Nl1YB14Lods6YfiCyavhlyqy585pwSTsHKzqYrOaschosoUpRt)S3z)tqsxUqs4Wrsil3jahl2wPqsDqsTuG8ACyBrEq2XP)DNKGaR2ehriYJRo9ZtIUKh(SGpRjp8U)5sT8wnEPZGKUCbchgq1XcgewoF(JfBRuizgKCekGKWHJKJ7Z60p7D2)eK0LlKeoCKeYYDcWXITvkKuhKKwkqEnoSTiVUWSkU(dW9)tccSAPXeHipU60ppj6sE4Zc(SM8sDHG8Qypra3x4a6AcGSJ9ZLArEnoSTiV0ohSqG4mmDfjib5nzO29heHiWQLie514W2I8uc4(aoDnbQ4m6m5XvN(5jrxsqGLwIqKhxD6NNeDjVva5P4G8ACyBrEJ7Z60ptEJ7VltE4D)ZLA5TA8sNbjD5ceomGQJfmiSC(8hl2wPqYmijKL7eGJfBRuijC4ijKL7eGJfBRuiPoiPwAPasMfjHSCNaCSyBLcjZGK4D)ZLA5v8XLfA8hl2wPqYSijE3)CPwEfFCzHg)XITvkKmdsQLcK34(avlYKNZ(NGKUCrccSJqeI84Qt)8KOl5Hpl4ZAYJMizQleKxXhxwOX7kajHdhjtDHG8Qypra3x4a6AcGSJ9UcqsHHKzrsbC4t6YfiCyavhlyqy585BCyJzKeoCKeYYDcWXITvkKuNbKCuOa514W2I8eSHTfjiWsdeHipU60ppj6sEnoSTipC))Ggh2wGVPcYdFwWN1KxQleKxXhxwOX7kG8(MkavlYKNIpUSqdjiWQFIqKhxD6NNeDjVgh2wKhU)FqJdBlW3ub5Hpl4ZAYl1fcYtLBbBPaleyVjFExbK33ubOArM8OYTGTuGfcS3KpsqGDuicrEC1PFEs0L8ACyBrE4()bnoSTaFtfKh(SGpRjVWezKuhKKgqYSij2XqsDqs9JKzrs9bjfWHpPlxGWHbuDSGbHLZNVXHnMjVVPcq1Im5Tc4IpsqGnXreI84Qt)8KOl5Hpl4ZAYd7yEXojssrKe7yizMbKCeKmlsstKKl(Y14dtKbXce7KiPoiPwKeoCKKl(Y14dtKbXce7KiPoijnGKzrs8U)5sT8qMkuGfca5EA8hl2wPqsDqsTE9JKWHJK4D)ZLA5PYTGTuGfcS3Kp)XITvkKuhKKwKuyKxJdBlYdYubyHaHddO6ybdclNpYdRb)zq0xohkcSAjbbwAmriYJRo9ZtIUKh(SGpRjpSJ5f7KijfrsSJHKzgqsTizwKKMijx8LRXhMidIfi2jrsDqsTijC4ijE3)CPwEfFCzHg)XITvkKuhKKwKeoCKKl(Y14dtKbXce7KiPoijnGKzrs8U)5sT8qMkuGfca5EA8hl2wPqsDqsTE9JKWHJK4D)ZLA5PYTGTuGfcS3Kp)XITvkKuhKKwKuyKxJdBlYJtkG)aN(ejbb2rJie5XvN(5jrxYdFwWN1KhEftxGkoJoJKzrsSJ5f7KijfrsSJHKzgqsArYSijnrsU4lxJpmrgelqStIK6GKArs4Wrs8U)5sT8k(4Ycn(JfBRuiPoijTijC4ijx8LRXhMidIfi2jrsDqsAajZIK4D)ZLA5HmvOaleaY904pwSTsHK6GKA96hjHdhjX7(Nl1YtLBbBPaleyVjF(JfBRuiPoijTiPWiVgh2wKxy58be0FrYdRb)zq0xohkcSAjbbwTuGie5XvN(5jrxYRXHTf5H7)h04W2c8nvqE4Zc(SM80hKm6pxHxXhxwOXZvN(5j59nvaQwKjp8eOyisqGvRwIqKhxD6NNeDjVgh2wKhU)FqJdBlW3ub5Hpl4ZAYl6pxHxXhxwOXZvN(5j59nvaQwKjp8eO4Jll0qccSAPLie5XvN(5jrxYRXHTf5H7)h04W2c8nvqE4Zc(SM8ACyJzaxSOXkKuhKCeY7BQauTitEQGeey1ocriYJRo9ZtIUKxJdBlYd3)pOXHTf4BQG8WNf8zn514WgZaUyrJvizMbKCeY7BQauTitE9YKGeKNGJXRyAheHiWQLie514W2I8eSHTf5XvN(5jrxsqGLwIqKxJdBlYlDJ4Zta0V1WtQwLdInPvKhxD6NNeDjbb2ricrEC1PFEs0L8wbKNIdYRXHTf5nUpRt)m5nU)Um5rbYBCFGQfzYlPlxGTaUkgeNv05GeeyPbIqKhxD6NNeDjp8zbFwtE6dsg9NRWR4Jll045Qt)8ejHdhj1hKm6pxHhYubyHaHddO6ybdclNppxD6NNKxJdBlYd7yGu3tfKGaR(jcrEC1PFEs0L8WNf8zn5Ppiz0FUcpx8LBJoRYb83sYNNRo9ZtYRXHTf5HDma1EmtcsqE9YeHiWQLie514W2I8O6y33QCW868TacClSd5XvN(5jrxsqGLwIqKhxD6NNeDjp8zbFwtEyhZl2jrskIKyhdjZmGK0IKzrsU4lxJpmrgelqStIKzqsArs4WrsSJ5f7KijfrsSJHKzgqsAG8ACyBrECXxUn6SkhWFlPDKGa7ieHipU60ppj6sE4Zc(SM8WRy6cuXz0zKmlsstKm1fcYp7cZGfcGDSeZ8Ucqs4WrYjN6cb5t3INUQaKEmvVRaKuyKxJdBlYtjWQYQCa(6Ib0nmDsqGLgicrEC1PFEs0L8WNf8zn5XfF5A8HjYGybIDsKmdsYjzSBWGWezKeoCKe7yEXojssrKe7yiPodiPwYRXHTf5bzQqbwiaK7PHeey1priYJRo9ZtIUKh(SGpRjpAIKr)5k8uDS7BvoyED(wabUf2XZvN(5jsMfjX7(Nl1YFMYQCGYTa0nmD)096W2cjZGK4D)ZLA5P6y33QCW868TacClSJ)yX2kfsQhssdiPWqYSijnrs8U)5sT8qMkuGfca5EA8hl2wPqYmi5iijC4ij2XqYmdiP(rsHrEnoSTiVZuwLduUfGUHPtEyn4pdI(Y5qrGvljiWokeHipU60ppj6sE4Zc(SM8sDHG8NRYXQCqI1tgq1QPFUulYRXHTf5DUkhRYbjwpzavRMKGaBIJie5XvN(5jrxYdFwWN1KhEftxGkoJoJKzrsAIK0ejX7(Nl1YNUfpDvbi9yQ(JfBRuizgKKwKmlsstKe7yizgKCeKeoCKeV7FUulpKPcfyHaqUNg)XITvkKmdsokiPWqYSijnrsSJHKzgqs9JKWHJK4D)ZLA5HmvOaleaY904pwSTsHKzqsArsHHKcdjHdhj5IVCn(WezqSaXojsQZasocskmYRXHTf5PeyvzvoaFDXa6gMojiWsJjcrEC1PFEs0L8WNf8zn5HDmVyNejPisIDmKmZasQL8ACyBrECsb8h40NijiWoAeHipU60ppj6sE4Zc(SM8WoMxStIKuejXogsMzajhH8ACyBrEqMkaleiCyavhlyqy58rEyn4pdI(Y5qrGvljiWQLceHipU60ppj6sE4Zc(SM8WoMxStIKuejXogsMzajPL8ACyBrEyhdK6EQGeey1QLie5XvN(5jrxYdFwWN1KxQleKpCyalkGV9uaClOXwSNxfnMosMbj1oAizwKKl(Y14dtKbXce7KizgKKtYy3GbHjYijfrsTizwKeV7FUulpKPcfyHaqUNg)XITvkKmdsYjzSBWGWezYRXHTf5HVgt)BvoiX6jd(wUtuwLtccSAPLie5XvN(5jrxYdFwWN1Kh2X8IDsKKIij2XqYmdijTizwKKMiP(GKr)5k8owaWRy665Qt)8ejHdhjXRy6cuXz0zKuyKxJdBlYlSC(ac6Vi5H1G)mi6lNdfbwTKGaR2ricrEC1PFEs0L8WNf8zn5HxX0fOIZOZKxJdBlYd7yaQ9yMeey1sdeHipRc(oxbb5PL84Qt)8KOl5Hpl4ZAYl1fcYNU0bcUf7Nl1I8ACyBrEqFnwLdu8jGRaq3W0jbbwT6Nie5XvN(5jrxYdFwWN1KhEftxGkoJoJKzrsAIKPUqq(0LoqWTyVRaKeoCKm6pxH3XcaEftxpxD6NNizwKuWXJb54PxRpSC(ac6VisMfjXogsoGK0IKzrs8U)5sT8qMkuGfca5EA8hl2wPqsDqYrqs4WrsSJ5f7KijfrsSJHK6mGKArYSiPGJhdYXtVwVsGvLv5a81fdOBy6izwKKl(Y14dtKbXce7KiPoi5iiPWiVgh2wKx6VX0x3aq3W0jpSg8NbrF5COiWQLeKGeK3y(u2weyPLc0sbT0slfipQ9vwLRipHF91rpy1xGD0x4IKiPqomsAIc2lqsO9qYerLBbBPaleyVjFjcjpw4Z1oEIKQvKrY2nwXo4jsID6kNvEemchRyKuRWfj13BnMVGNizII(Zv4h1eHKXIKjk6pxHFu9C1PFEMiKSdKu4nXt4GK0uBsH5rWiCSIrsAfUiP(ERX8f8ejtu0FUc)OMiKmwKmrr)5k8JQNRo9ZZeHKDGKcVjEchKKMAtkmpcgHJvmsQDueUiP(ERX8f8ejtu0FUc)OMiKmwKmrr)5k8JQNRo9ZZeHK0uBsH5rWGGr4xFD0dw9fyh9fUijskKdJKMOG9cKeApKmrk(4Ycnjcjpw4Z1oEIKQvKrY2nwXo4jsID6kNvEemchRyKulTcxKuFV1y(cEIKjk6pxHFutesglsMOO)Cf(r1ZvN(5zIqYoqsH3epHdsstTjfMhbdcgHF91rpy1xGD0x4IKiPqomsAIc2lqsO9qYePIeHKhl85Ahprs1kYiz7gRyh8ejXoDLZkpcgHJvmssdcxKuFV1y(cEIKjk6pxHFutesglsMOO)Cf(r1ZvN(5zIqYoqsH3epHdsstTjfMhbJWXkgjhfHlsQV3AmFbprYef9NRWpQjcjJfjtu0FUc)O65Qt)8mrijn1MuyEemchRyKulniCrs99wJ5l4jsMOO)Cf(rnrizSizII(Zv4hvpxD6NNjcjPP2KcZJGbbJWV(6OhS6lWo6lCrsKuihgjnrb7fij0EizIMmu7(JeHKhl85Ahprs1kYiz7gRyh8ejXoDLZkpcgHJvmsQLccxKuFV1y(cEIKjk6pxHFutesglsMOO)Cf(r1ZvN(5zIqYoqsH3epHdsstTjfMhbJWXkgj1Qv4IK67TgZxWtKmrr)5k8JAIqYyrYef9NRWpQEU60pptes2bsk8M4jCqsAQnPW8iyqWi8RVo6bR(cSJ(cxKejfYHrstuWEbscThsMOE5eHKhl85Ahprs1kYiz7gRyh8ejXoDLZkpcgHJvmsQFHlsQV3AmFbprYef9NRWpQjcjJfjtu0FUc)O65Qt)8mrijn1MuyEemchRyKulTcxKuFV1y(cEIKjk6pxHFutesglsMOO)Cf(r1ZvN(5zIqsAQnPW8iyeowXiPw9lCrs99wJ5l4jsMOO)Cf(rnrizSizII(Zv4hvpxD6NNjcjPP2KcZJGbbJ(IOG9cEIKJgs24W2cj)MkuEemKx7go7rEptuFtEcUfY(m5rJIKc)wnP2F68HKcpVfDem0OiPWJmMft5djPLwkrsAPaTuabdcgAuKuiQCthjt8nvOqYfcjt8DpniPvbFNRGaj)BUH9iyqWqJIKcVjzSBWtKmLH2Jrs8kM2bsMY5wP8iP(kgZccfswBrrN(eHC)izJdBlfsU1xJhbtJdBlLxWX4vmTJbbByBHGPXHTLYl4y8kM2HEdjKUr85ja63A4jvRYbXM0kemnoSTuEbhJxX0o0BiHX9zD6NPSArEiPlxGTaUkgeNv05GYvWGIdkh3FxEGciyACyBP8cogVIPDO3qcyhdK6EQGsdAqFI(Zv4v8XLfA8C1PFEchU(e9NRWdzQaSqGWHbuDSGbHLZNNRo9ZtemnoSTuEbhJxX0o0BibSJbO2JzknOb9j6pxHNl(YTrNv5a(Bj5ZZvN(5jcgem0OiPWBsg7g8ej5X8PbjdtKrYWHrYgh7HKMcj7XT970p7rW04W2snOeW9bC6AcuXz0zemnoSTu6nKW4(So9ZuwTip4S)jiPlxuUcguCq54(7Yd4D)ZLA5TA8sNbjD5ceomGQJfmiSC(8hl2wPYaz5ob4yX2kfC4qwUtaowSTsPJwAPqwil3jahl2wPYG39pxQLxXhxwOXFSyBLklE3)CPwEfFCzHg)XITvQmAPacMgh2wk9gsqWg2wuAqd0m1fcYR4Jll04DfahEQleKxf7jc4(chqxtaKDS3vGWYkGdFsxUaHddO6ybdclNpFJdBmdhoKL7eGJfBRu6mmkuabtJdBlLEdjG7)h04W2c8nvqz1I8GIpUSqdLg0qQleKxXhxwOX7kabtJdBlLEdjG7)h04W2c8nvqz1I8avUfSLcSqG9M8rPbnK6cb5PYTGTuGfcS3KpVRaemnoSTu6nKaU)FqJdBlW3ubLvlYdRaU4JsdAimrwhAil2X0r)z1hbC4t6YfiCyavhlyqy585BCyJzemnoSTu6nKaKPcWcbchgq1XcgewoFuI1G)mi6lNd1GwknObSJ5f7Kue7yzggjln5IVCn(WezqSaXoPoAHdNl(Y14dtKbXce7K6qdzX7(Nl1YdzQqbwiaK7PXFSyBLshTE9dhoE3)CPwEQClylfyHa7n5ZFSyBLshAfgcMgh2wk9gsGtkG)aN(eP0GgWoMxStsrSJLzqBwAYfF5A8HjYGybIDsD0choE3)CPwEfFCzHg)XITvkDOfoCU4lxJpmrgelqStQdnKfV7FUulpKPcfyHaqUNg)XITvkD061pC44D)ZLA5PYTGTuGfcS3Kp)XITvkDOvyiyACyBP0BiHWY5diO)IuI1G)mi6lNd1GwknOb8kMUavCgDol2X8IDskIDSmd0MLMCXxUgFyImiwGyNuhTWHJ39pxQLxXhxwOXFSyBLshAHdNl(Y14dtKbXce7K6qdzX7(Nl1YdzQqbwiaK7PXFSyBLshTE9dhoE3)CPwEQClylfyHa7n5ZFSyBLshAfgcMgh2wk9gsa3)pOXHTf4BQGYQf5b8eOyiknOb9j6pxHxXhxwObbtJdBlLEdjG7)h04W2c8nvqz1I8aEcu8XLfAO0GgI(Zv4v8XLfAqW04W2sP3qc4()bnoSTaFtfuwTipOcknOHgh2ygWflASsNrqW04W2sP3qc4()bnoSTaFtfuwTip0ltPbn04WgZaUyrJvzggbbdcMgh2wkFV8avh7(wLdMxNVfqGBHDqW04W2s57L1BibU4l3gDwLd4VL0oknObSJ5f7Kue7yzgOnlx8LRXhMidIfi2jZqlC4yhZl2jPi2XYmqdiyACyBP89Y6nKGsGvLv5a81fdOBy6uAqd4vmDbQ4m6CwAM6cb5NDHzWcbWowIzExbWHp5uxiiF6w80vfG0JP6DfimemnoSTu(Ez9gsaYuHcSqai3tdLg0ax8LRXhMidIfi2jZWjzSBWGWez4WXoMxStsrSJPZGwemnoSTu(Ez9gs4mLv5aLBbOBy6uI1G)mi6lNd1GwknObAg9NRWt1XUVv5G515Bbe4wyNS4D)ZLA5ptzvoq5wa6gMUF6EDyBLbV7FUulpvh7(wLdMxNVfqGBHD8hl2wP0JgewwAI39pxQLhYuHcSqai3tJ)yX2kvMrGdh7yzg0VWqW04W2s57L1BiHZv5yvoiX6jdOA1KsdAi1fcYFUkhRYbjwpzavRM(5sTqW04W2s57L1BibLaRkRYb4Rlgq3W0P0GgWRy6cuXz05S0KM4D)ZLA5t3INUQaKEmv)XITvQm0MLMyhlZiWHJ39pxQLhYuHcSqai3tJ)yX2kvMrryzPj2XYmOF4WX7(Nl1YdzQqbwiaK7PXFSyBLkdTctyWHZfF5A8HjYGybIDsDggryiyACyBP89Y6nKaNua)bo9jsPbnGDmVyNKIyhlZGwemnoSTu(Ez9gsaYubyHaHddO6ybdclNpkXAWFge9LZHAqlLg0a2X8IDskIDSmdJGGPXHTLY3lR3qcyhdK6EQGsdAa7yEXojfXowMbArW04W2s57L1Bib81y6FRYbjwpzW3YDIYQCknOHuxiiF4WawuaF7Pa4wqJTypVkAm9mAhTSCXxUgFyImiwGyNmdNKXUbdctKPO2S4D)ZLA5HmvOaleaY904pwSTsLHtYy3GbHjYiyACyBP89Y6nKqy58be0FrkXAWFge9LZHAqlLg0a2X8IDskIDSmd0MLM6t0FUcVJfa8kMUWHJxX0fOIZOZcdbtJdBlLVxwVHeWogGApMP0GgWRy6cuXz0zemnoSTu(Ez9gsa6RXQCGIpbCfa6gMoLg0qQleKpDPdeCl2pxQfLwf8DUcIbTiyACyBP89Y6nKq6VX0x3aq3W0PeRb)zq0xohQbTuAqd4vmDbQ4m6CwAM6cb5tx6ab3I9UcGdp6pxH3XcaEft3ScoEmihp9A9HLZhqq)fZIDSbAZI39pxQLhYuHcSqai3tJ)yX2kLoJaho2X8IDskIDmDg0MvWXJb54PxRxjWQYQCa(6Ib0nm9SCXxUgFyImiwGyNuNregcgemnoSTuE8eOyObRgV0zqsxUaHddO6ybdclNpknOb9zCFwN(zVZ(NGKUCbhoKL7eGJfBRu6qR(rW04W2s5XtGIH0BiH(WDXGyVJRGsdAa7yEXojfXowMbTiyACyBP84jqXq6nKqSUyhWcbMChouAqdPUqqEvSNiG7lCaDnbq2X(5sTYkGdFsxUaHddO6ybdclNpFJdBmdhoKL7eGJfBRu6OLcWHdz5ob4yX2kvgT0ykGGPXHTLYJNafdP3qcu5wWwkWcb2BYhLg0anV2MaEmxHVNtL3Qm0G(Hd)ABc4XCf(EovExbcllE3)CPw(ZuwLduUfGUHP7pwSTsPdNKXUbdctKrW04W2s5XtGIH0BibOM)wXavSIcO0GgWRy6cuXz05S08ABc4XCf(EovERYOLcWHFTnb8yUcFpNkVRaHHGPXHTLYJNafdP3qcq9)ZfyVjFuAqdxBtapMRW3ZPYBvMrOaC4xBtapMRW3ZPY7kabtJdBlLhpbkgsVHes3INUQaKEmvknOHRTjGhZv475u5TkJ(PaC4xBtapMRW3ZPY7kGYVvmaphgfkGGPXHTLYJNafdP3qcQypra3x4a6AcGSJbqwYoyknOb8wtxl84DVPvDWtWcbXLYgZEU60pprW04W2s5XtGIH0BibvSNiG7lCaDnbq2XuAqd4D)ZLA5vXEIaUVWb01eazh7Xo9LZQbAHdhYYDcWXITvkDOLcWHtZRTjGhZv475u5pwSTsLrR(HdxFW7yU6k801CwxzPjnV2MaEmxHVNtL3Qm4D)ZLA5vXEIaUVWb01eazh7HC)FWXyN(YzqyImC46Z12eWJ5k89CQ8CstfkHLLM4D)ZLA5TA8sNbjD5ceomGQJfmiSC(8hl2wPYG39pxQLxf7jc4(chqxtaKDShY9)bhJD6lNbHjYWHpUpRt)S3z)tqsxUeMWYI39pxQLhYuHcSqai3tJ)yX2kLodJwwSJLzG2S4D)ZLA5P6y33QCW868TacClSJ)yX2kLodAPvyiyACyBP84jqXq6nKGk2teW9foGUMai7yknOb8oMRUcpDnN1vwAM6cb5PYTGTuGfcS3KpVRa4WPjKL7eGJfBRu6G39pxQLNk3c2sbwiWEt(8hl2wPGdhV7FUulpvUfSLcSqG9M85pwSTsLbV7FUulVk2teW9foGUMai7ypK7)dog70xodctKfww8U)5sT8qMkuGfca5EA8hl2wP0zy0YIDSmd0MfV7FUulpvh7(wLdMxNVfqGBHD8hl2wP0zqlTcdbtJdBlLhpbkgsVHeCvmWcwuHGPXHTLYJNafdP3qcX6IDaleGEFInLg0aKL7eGJfBRuz0Q)rdoCbC4t6YfiCyavhlyqy585BCyJz4Wh3N1PF27S)jiPlxiyACyBP84jqXq6nKq6F3jaY90qPbnG39pxQL3QXlDgK0Llq4WaQowWGWY5ZFSyBLkZiuao8X9zD6N9o7Fcs6YfC4qwUtaowSTsPdTuabtJdBlLhpbkgsVHes5tXhDRYP0GgW7(Nl1YB14Lods6YfiCyavhlyqy585pwSTsLzekah(4(So9ZEN9pbjD5coCil3jahl2wP0rR(rW04W2s5XtGIH0BiHVL7ekqI5oZf5kqW04W2s5XtGIH0Bibi740)UtknOb8U)5sT8wnEPZGKUCbchgq1XcgewoF(JfBRuzgHcWHpUpRt)S3z)tqsxUGdhYYDcWXITvkD0sbemnoSTuE8eOyi9gsOlmRIR)aC))uAqd4D)ZLA5TA8sNbjD5ceomGQJfmiSC(8hl2wPYmcfGdFCFwN(zVZ(NGKUCbhoKL7eGJfBRu6qlfqW04W2s5XtGIH0BiH0ohSqG4mmDfLg0qQleKxf7jc4(chqxtaKDSFUulemiyACyBP84jqXhxwOzyCFwN(zkRwKhu8XLfAaPUNkOCfmO4GYX93LhW7(Nl1YR4Jll04pwSTsPJw4WfWHpPlxGWHbuDSGbHLZNVXHnMZI39pxQLxXhxwOXFSyBLkZiuaoCil3jahl2wP0HwkGGPXHTLYJNafFCzHg9gsWQXlDgK0Llq4WaQowWGWY5JsdAqFg3N1PF27S)jiPlxWHdz5ob4yX2kLo0QFemnoSTuE8eO4Jll0O3qcUkgyblsz1I8qRCg3fRaxp62dG3R)iyACyBP84jqXhxwOrVHeCvmWcwuHGPXHTLYJNafFCzHg9gsOpCxmi274kO0GgWoMxStsrSJLzqlcMgh2wkpEcu8XLfA0BiHVL7ekqI5oZf5kqW04W2s5XtGIpUSqJEdjazhN(3DsPbnmUpRt)SxXhxwObK6EQabtJdBlLhpbk(4Ycn6nKqxywfx)b4()P0Ggg3N1PF2R4Jll0asDpvGGPXHTLYJNafFCzHg9gsiTZbleiodtxrPbnmUpRt)SxXhxwObK6EQabtJdBlLhpbk(4Ycn6nKqSUyhWcbMChouAqdqwUtaowSTsLrlnMcWHlGdFsxUaHddO6ybdclNpFJdBmdhoKL7eGJfBRu6OLciyACyBP84jqXhxwOrVHeI1f7awia9(eBknObil3jahl2wPYmAuaoCbC4t6YfiCyavhlyqy585BCyJz4WHSCNaCSyBLshTuabtJdBlLhpbk(4Ycn6nKavUfSLcSqG9M8rPbnG39pxQL)mLv5aLBbOBy6(JfBRu6WjzSBWGWezemnoSTuE8eO4Jll0O3qcqn)TIbQyffGGPXHTLYJNafFCzHg9gsaQ)FUa7n5dbtJdBlLhpbk(4Ycn6nKq6w80vfG0JPIGPXHTLYJNafFCzHg9gsqXhxwOHsdAaV7FUul)zkRYbk3cq3W09hl2wP0Hw4WHSCNaCSyBLshT6hbtJdBlLhpbk(4Ycn6nKqANdwiqCgMUcbdcMgh2wk)kGl(gGmvawiq4WaQowWGWY5JsSg8NbrFxohQbTuAqdyhZl2jPi2XYmmccMgh2wk)kGl(0BiboPa(dC6tKsdAi6pxHh7yGu3tfEU60ppZIDmVyNKIyhlZWiiyACyBP8RaU4tVHeclNpGG(lsjwd(ZGOVCoudAP0GgWRy6cuXz05SyhZl2jPi2XYmqlcMgh2wk)kGl(0BibSJbO2JzknObSJ5f7Kue7yd0IGPXHTLYVc4Ip9gsGtkG)aN(erW04W2s5xbCXNEdjewoFab9xKsSg8NbrF5COg0sPbnGDmVyNKIyhlZaTiyqW04W2s5v8XLfAgGmvOaleaY90qPbnK6cb5v8XLfA8hl2wP0rlcMgh2wkVIpUSqJEdj4QyGfSiLvlYdwPWNB0PFgi852v4kcM8ydZiyACyBP8k(4Ycn6nKGRIbwWIuwTipmpUNq2XGXSsXFemnoSTuEfFCzHg9gsqjWQYQCa(6Ib0nmDknOb8kMUavCgDolnBCyJzaxSOXQmdJahEJdBmd4IfnwLrBw9bV7FUul)zkRYbk3cq3W09UcegcMgh2wkVIpUSqJEdjCMYQCGYTa0nmDkXAWFge9LZHAqlLg0aEftxGkoJoJGPXHTLYR4Jll0O3qcqMkuGfca5EAO0GgACyJzaxSOXQmdJGGPXHTLYR4Jll0O3qckbwvwLdWxxmGUHPtPbnGxX0fOIZOZztDHG8ZUWmyHayhlXmVRaemnoSTuEfFCzHg9gsi93y6RBaOBy6uI1G)mi6lNd1GwknOb8kMUavCgDoBQleKNk3c2sbwiWEt(auP6DfKfV7FUul)zkRYbk3cq3W09hl2wPYqlcMgh2wkVIpUSqJEdjazQqbwiaK7PHsRc(oxbbWGgsDHG8k(4YcnExbzX7(Nl1YFMYQCGYTa0nmD)X9udcMgh2wkVIpUSqJEdjOeyvzvoaFDXa6gMoLg0aEftxGkoJoNDYPUqq(0T4PRkaPht17kabtJdBlLxXhxwOrVHeGmvawiq4WaQowWGWY5JsSg8NbrF5COg0sPbnGDmDgbbtJdBlLxXhxwOrVHes)nM(6ga6gMoLyn4pdI(Y5qnOLsdAaVIPlqfNrNHdxFI(Zv4DSaGxX0fbtJdBlLxXhxwOrVHeucSQSkhGVUyaDdthbdcMgh2wkVkgO6y33QCW868TacClSdLg0W12eWJ5k89CQ8wLbV7FUulpvh7(wLdMxNVfqGBHD8t3RdBlAek4PXWHFTnb8yUcFpNkVRaemnoSTuEvO3qcCXxUn6SkhWFlPDuAqdyhZl2jPi2XYmqBwU4lxJpmrgelqStMze4WXoMxStsrSJLzGgYstU4lxJpmrgelqStMHw4W1hbhpgKJNET(WY5diO)IcdbtJdBlLxf6nKGsGvLv5a81fdOBy6uAqd4vmDbQ4m6C2uxii)Slmdwia2XsmZ7kilnV2MaEmxHVNtL3QmPUqq(zxygSqaSJLyM)yX2kffPfo8RTjGhZv475u5DfimemnoSTuEvO3qcNPSkhOClaDdtNsSg8NbrF5COg0sPbnG39pxQLxXhxwOXFSyBLkJw4W1NO)CfEfFCzHgemnoSTuEvO3qcqMkuGfca5EAO0GgO512eWJ5k89CQ8wLbV7FUulpKPcfyHaqUNg)096W2IgHcEAmC4xBtapMRW3ZPY7kqyzPjx8LRXhMidIfi2jZWjzSBWGWezkQfoCSJ5f7Kue7y6mOfo8uxiiVk2teW9foGUMai7y)XITvkD4Km2nyqyISEAfgC4qwUtaowSTsPdNKXUbdctK1tlcMgh2wkVk0Bib81y6FRYbjwpzW3YDIYQCknOHuxiiF4WawuaF7Pa4wqJTypVkAm9mAhTSCXxUgFyImiwGyNmdNKXUbdctKPO2S4D)ZLA5ptzvoq5wa6gMU)yX2kvgojJDdgeMidhEQleKpCyalkGV9uaClOXwSNxfnMEgT0qwAI39pxQLxXhxwOXFSyBLsh9Nn6pxHxXhxwOboC8U)5sT8u5wWwkWcb2BYN)yX2kLo6plEhZvxHNUMZ6coCil3jahl2wP0r)cdbtJdBlLxf6nKW5QCSkhKy9KbuTAsPbnK6cb5pxLJv5GeRNmGQvt)CPwzBCyJzaxSOXQmArW04W2s5vHEdjazQaSqGWHbuDSGbHLZhLyn4pdI(Y5qnOLsdAa7y6mccMgh2wkVk0BiboPa(dC6tKsdAa7yEXojfXowMbTiyACyBP8QqVHeWogi19ubLg0a2X8IDskIDSmdAZ24WgZaUyrJvdAZETnb8yUcFpNkVvzOLcWHJDmVyNKIyhlZaTzBCyJzaxSOXQmd0IGPXHTLYRc9gsa7yaQ9ygbtJdBlLxf6nKqy58be0FrkXAWFge9LZHAqlLuAqd4vmDbQ4m6CwSJ5f7Kue7yzgOnBQleKxf7jc4(chqxtaKDSFUulemnoSTuEvO3qckbwvwLdWxxmGUHPtPbnK6cb5XogGl(Y14vrJPNzekqr9tJ04WgZaUyrJvztDHG8Qypra3x4a6AcGSJ9ZLALLM4D)ZLA5ptzvoq5wa6gMU)yX2kvgAZI39pxQLhYuHcSqai3tJ)yX2kvgAHdhV7FUul)zkRYbk3cq3W09hl2wP0zKS4D)ZLA5HmvOaleaY904pwSTsLzKSyhlZiWHJ39pxQL)mLv5aLBbOBy6(JfBRuzgjlE3)CPwEitfkWcbGCpn(JfBRu6mswSJLHgGdh7yEXojfXoModAZYfF5A8HjYGybIDsDOvyWHN6cb5XogGl(Y14vrJPNrlfYcz5ob4yX2kLojoemnoSTuEvO3qcP)gtFDdaDdtNsSg8NbrF5COg0sPbnGxX0fOIZOZzPz0FUcVIpUSqtw8U)5sT8k(4Ycn(JfBRu6mcC44D)ZLA5ptzvoq5wa6gMU)yX2kvgTzX7(Nl1YdzQqbwiaK7PXFSyBLkJw4WX7(Nl1YFMYQCGYTa0nmD)XITvkDgjlE3)CPwEitfkWcbGCpn(JfBRuzgjl2XYqlC44D)ZLA5ptzvoq5wa6gMU)yX2kvMrYI39pxQLhYuHcSqai3tJ)yX2kLoJKf7yzgboCSJLr)WHN6cb5tx6ab3I9UcegcMgh2wkVk0BiHWY5diO)IuI1G)mi6lNd1GwkP0GgWRy6cuXz05SyhZl2jPi2XYmqlcMgh2wkVk0BibOVgRYbk(eWvaOBy6uAvW35kig0IGHgfjfEGIrsDxHhIKgesM4Vj(iPPqs8Fvms21ej1SUiPtpMrsArsSJHKDnrsnR7HK)wfiz(Ft7pssTviPqcprjsUhsAqiPM1fj7JrYoDDdKmwKe3cqsU4lxds21ejzlC4dj1SUhs(BvGK54jssTviPqcpHK7HKgesQzDrY(yK8ZkfsgoDHK0IKyhdjBQTgKe6wrKe3ceyvocMgh2wkVk0BiH0FJPVUbGUHPtjwd(ZGOVCoudAP0GgWRy6cuXz05S4D)ZLA5HmvOaleaY904pwSTsPZizXo2aTzfC8yqoE616dlNpGG(lMLl(Y14dtKbXc0pf0rlcMgh2wkVk0BiH0FJPVUbGUHPtjwd(ZGOVCoudAP0GgWRy6cuXz05SCXxUgFyImiwGyNuhAZstSJ5f7Kue7y6mOfoCbhpgKJNET(WY5diO)IcdbdcMgh2wkpvUfSLcSqG9M8nG7)h04W2c8nvqz1I8aEcumeLg0G(e9NRWR4Jll0GGPXHTLYtLBbBPaleyVjF6nKaU)FqJdBlW3ubLvlYd4jqXhxwOHsdAi6pxHxXhxwObbtJdBlLNk3c2sbwiWEt(0BibU4l3gDwLd4VL0oknObSJ5f7Kue7yzgOnlx8LRXhMidIfi2jZmccMgh2wkpvUfSLcSqG9M8P3qcNPSkhOClaDdtNsSg8NbrF5COg0IGPXHTLYtLBbBPaleyVjF6nKGsGvLv5a81fdOBy6uAqd4vmDbQ4m6C2uxii)Slmdwia2XsmZ7kabtJdBlLNk3c2sbwiWEt(0BibitfkWcbGCpnuAqdnoSXmGlw0yvMbAZM6cb5PYTGTuGfcS3KpavQ(JfBRu6OfbtJdBlLNk3c2sbwiWEt(0BibQo29TkhmVoFlGa3c7qPbn04WgZaUyrJvzgOfbtJdBlLNk3c2sbwiWEt(0BibLaRkRYb4Rlgq3W0P0GgWRy6cuXz05SnoSXmGlw0yvMHrYM6cb5PYTGTuGfcS3KpavQExbiyACyBP8u5wWwkWcb2BYNEdjK(Bm91na0nmDkXAWFge9LZHAqlLg0aEftxGkoJoNTXHnMbCXIgR0zGwemnoSTuEQClylfyHa7n5tVHeO6y33QCW868TacClSdcMgh2wkpvUfSLcSqG9M8P3qcqMkuGfca5EAO0QGVZvqamOHuxiipvUfSLcSqG9M8bOs17kGsdAi1fcYRI9ebCFHdORjaYo27ki712eWJ5k89CQ8wLbV7FUulpKPcfyHaqUNg)096W2IgHc(rbbtJdBlLNk3c2sbwiWEt(0BibLaRkRYb4Rlgq3W0P0GgsDHG8yhdWfF5A8QOX0ZmcfOO(PrACyJzaxSOXkemnoSTuEQClylfyHa7n5tVHeGmvawiq4WaQowWGWY5JsSg8NbrF5COg0sPbnGDmDgbbtJdBlLNk3c2sbwiWEt(0BiboPa(dC6tKsdAa7yEXojfXowMbTiyACyBP8u5wWwkWcb2BYNEdjGDmqQ7PcknObSJ5f7Kue7yzgOPw9ACyJzaxSOXQmAfgcMgh2wkpvUfSLcSqG9M8P3qcHLZhqq)fPeRb)zq0xohQbTuAqd0uFI(Zv4DSaGxX0foC8kMUavCgDwyzXoMxStsrSJLzGwemnoSTuEQClylfyHa7n5tVHeWogGApMrW04W2s5PYTGTuGfcS3Kp9gsi93y6RBaOBy6uI1G)mi6lNd1GwknObSJLzye4WtDHG8u5wWwkWcb2BYhGkvVRaemnoSTuEQClylfyHa7n5tVHeG(ASkhO4taxbGUHPtPvbFNRGyqljibHa]] )

end