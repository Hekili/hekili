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
            id = 116768,
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


    spec:RegisterPack( "Windwalker", 20210823, [[dSKKGcqiPO6rkPI2Ka(ekOrjOCkbvRIkH6vcjZIKQBrLODrv)skYWKcogvQLrs6zkPmnuGUMqQ2Muu8nLuPghvc5CkPkRtkknpsI7Hi7tj5Gujiluk0drb0ePsqLlkKsAJujO4JkPcoPqkXkrHEjvckntLuv3KkbvTtsk)ujvOLkKs5PO0uPs6RkPsgRqk2lP(lWGr6Wkwmv8yunzP6YqBwP(SqnAsCAkRgfGxJIMnc3Mq7wYVvz4iQJtLalxvpNOPl66eSDb67sPXleNxqwVqkvZxj2pO1U1UQz7tIA1uTbvD3Gls118UxVgC7Mb1SziYOML8WzoXOMTgruZUUSQ3oemXxZsEcrCtx7QMvEcph1SAwhbJiJwkTJMTpjQvt1gu1DdUivxZ7E9AWT710SsYixRMQnZ6PzvSEhlTJMTJsUMDDzvVDiyIpK6c)vmHm6cjelitiv11uhsvTbvDdzeYORT4WesDHXKPesVnK6cJWhcsTkX)fiNqkXfBCpKrxBXHjKYs2QYQyiLb(tHqQlSgNjKsCXg3dz0fQ3HuNtk3wSscPCfKZucP5bPItfcszGUWbPyLVHsVMLWKPu7QM9iJf(Ax1Q5w7QMfRXHa76g1SdpTR0SBtMGBdsfe0QyjcslgFnl)TeFB0SCfZlorGuxcPCfdsxrcsxtZYdXjqqo)hJPuZ6wNA1uv7QMfRXHa76g1S83s8TrZMdbwPNRyahHxMESghcSdPbGuUI5fNiqQlHuUIbPRibPRPzhEAxPzXiKrcGY8I6uR2AAx1Synoeyx3OMD4PDLMnTy8bKhcrnl)TeFB0S8t05aY8nMiKgas5kMxCIaPUes5kgKUIeKQQMLhItGGC(ymLA1CRtTAmO2vnlwJdb21nQz5VL4BJMLRyEXjcK6siLRyqkjivvn7Wt7knlxXaTtquNA1IU2vn7Wt7knlgHmsauMxuZI14qGDDJ6uRwZODvZI14qGDDJA2HN2vA20IXhqEie1S83s8TrZYvmV4ebsDjKYvmiDfjivvnlpeNab58Xyk1Q5wN6uZ2Id5RKGBdUVJV2vTAU1UQzXACiWUUrn7rwZkXuZo80UsZgCEBCiqnBWHqa1Soc7TVfhYxjb3gCFhFqBR)rXXkjKgasdds53r0V2Y)M0QyGuOamnot)JIJvsiDfK6iS3(wCiFLeCBW9D8bTT(hfhRKqAai1ryV9T4q(kj42G774dAB9pkowjHuvGuv9UH0LfiLFhr)Al)BsRIbsHcW04m9pkowjHuxcPoc7TVfhYxjb3gCFhFqBR)rXXkjKUcsD7xpinaK6iS3(wCiFLeCBW9D8bTT(hfhRKqQkqkd6DdPllqQJWE7DiURtiitVazinaK6iS3ERcEmXxc6iHfRKEbYqAai1ryV9wf8yIVe0rclwj9pkowjHuvGuhH923Id5RKGBdUVJpOT1)O4yLesdxZgCEqnIOM1Hy4mpHeW04mbfIDSRtTAQQDvZI14qGDDJAw(Bj(2OzBoKMdbwPxIpwwgYJ14qGDn7Wt7knlFiiadpTRaeMm1SeMmb1iIAwEhiXTo1QTM2vnlwJdb21nQz5VL4BJMnhcSsVeFSSmKhRXHa7A2HN2vAw(qqagEAxbimzQzjmzcQre1S8oqIpwwgsNA1yqTRAwSghcSRBuZYFlX3gnlxX8Itei1LqkxXG0vKGuvH0aqkw4hhYNMicYdiorG0vq6AA2HN2vAwSWp2I2TkgGewe71PwTORDvZI14qGDDJA2HN2vA23KwfdKcfGPXzQz5H4eiiNpgtPwn36uRwZODvZI14qGDDJAw(Bj(2OzhEAbrawOOHsiDfjivvinaK6iS3(wCiFLeCBW9D8bTT(hfhRKqQkqQBn7Wt7kn72KPeCBWw4dPtTARBTRAwSghcSRBuZYFlX3gn7WtlicWcfnucPRibPQQzhEAxPzBvSNWQyq)N4RaKfkUIo1Q5I0UQzXACiWUUrnl)TeFB0S8t05aY8nMiKgashEAbrawOOHsiDfjiDninaK6iS3(wCiFLeCBW9D8bTTEbYA2HN2vAwjzRkRIb8FkeW04m1PwT1t7QMfRXHa76g1SdpTR0SoedN5jKaMgNPML)wIVnAw(j6Caz(gtesdaPdpTGialu0qjKQcjivvinaKgCEBCiqVdXWzEcjGPXzcke7yxZYdXjqqoFmMsTAU1Pwn3nODvZI14qGDDJAw(Bj(2Oz5NOZbK5BmrinaK6iS3((uCeCBaxXyaMxGSMD4PDLMvs2QYQya)NcbmnotDQvZTBTRAwSghcSRBuZYFlX3gnlxXGusqAdqAai1ryV9T4q(kj42G774dAB9pkowjHuvGuguZo80UsZIriJeaL5f1Pwn3QQDvZI14qGDDJA2HN2vA2TjtWTbPccAvSebPfJVML)wIVnAwUIbPKG0gG0aqQJWE7BXH8vsWTb33Xh026FuCSscPQaPmOMLhItGGC(ymLA1CRtTAUxt7QMD4PDLMTvXEcRIb9FIVcqwO4kAwSghcSRBuNA1CZGAx1Synoeyx3OMD4PDLMnTy8bKhcrnl)TeFB0SCfdsjbPnaPbGuhH923Id5RKGBdUVJpOT1)O4yLesvbszqnBoFmMaBRzJcsdds7OJWE7Lmd94WvayeLrqM2vEbYqQlgsvTbinCDQvZD01UQzXACiWUUrnl)TeFB0Soc7TxM3lcW5tfWuDW2E0lqgsdaP)yDageR0p9U0BfKUcs53r0V2YVnzkb3gSf(q(UWpPDfK6IH0g8nJMD4PDLMDBYucUnyl8H0SwL4)cKtGT1Soc7TVfhYxjb3gCFhFqBRxGSo1Q5Uz0UQzXACiWUUrnl)TeFB0Soc7TNRyaSWpoKxMdNjKUcsxRbi1LqA0HuxmKo80cIaSqrdLA2HN2vAwjzRkRIb8FkeW04m1Pwn3RBTRAwSghcSRBuZo80UsZUnzcUnivqqRILiiTy81S83s8TrZYvmivfiDnnlpeNab58Xyk1Q5wNA1C7I0UQzXACiWUUrnl)TeFB0SCfZlorGuxcPCfdsxrcsDRzhEAxPzXiKrcGY8I6uRM71t7QMfRXHa76g1S83s8TrZYvmV4ebsDjKYvmiDfjinmi1nKgfKo80cIaSqrdLq6ki1nKgUMD4PDLMLRyahHxM6uRMQnODvZI14qGDDJA2HN2vA20IXhqEie1S83s8TrZggK2CinhcSsVILa(j6CESghcSdPllqk)eDoGmFJjcPHdPbGuUI5fNiqQlHuUIbPRibPQQz5H4eiiNpgtPwn36uRMQU1UQzXACiWUUrn7Wt7knRdXWzEcjGPXzQz5VL4BJMD4PfebyHIgkHuvibPRbPbGuUIbPRibPRbPllqQJWE7BXH8vsWTb33Xh026fiRz5H4eiiNpgtPwn36uRMQQQDvZo80UsZYvmq7ee1Synoeyx3Oo1QP6AAx1SwL4)cKtnRBn7Wt7kn7MiKvXaj(KXkbmnotnlwJdb21nQtDQzL4JLLH0UQvZT2vnlwJdb21nQz5VL4BJM1ryV9s8XYYq(hfhRKqQkqQBn7Wt7kn72KPeCBWw4dPtTAQQDvZI14qGDDJAw(Bj(2Oz5NOZbK5BmrinaKggKo80cIaSqrdLq6ksq6Aq6YcKo80cIaSqrdLq6ki1nKgasBoKYVJOFTL)nPvXaPqbyACMEbYqA4A2HN2vAwjzRkRIb8FkeW04m1PwT10UQzXACiWUUrn7Wt7kn7BsRIbsHcW04m1S83s8TrZYprNdiZ3yIAwEiobcY5JXuQvZTo1QXGAx1Synoeyx3OML)wIVnA2HNwqeGfkAOesxrcsxtZo80UsZUnzkb3gSf(q6uRw01UQzXACiWUUrnl)TeFB0S8t05aY8nMiKgasDe2BFFkocUnGRymaZlqwZo80UsZkjBvzvmG)tHaMgNPo1Q1mAx1Synoeyx3OMD4PDLM1Hy4mpHeW04m1S83s8TrZYprNdiZ3yIqAai1ryV9T4q(kj42G7747fidPbGu(De9RT8VjTkgifkatJZ0)O4yLesxbPQQz5H4eiiNpgtPwn36uR26w7QM1Qe)xGCcSTM1ryV9s8XYYqEbYb43r0V2Y)M0QyGuOamnot)JtpKMD4PDLMDBYucUnyl8H0Synoeyx3Oo1Q5I0UQzXACiWUUrnl)TeFB0S8t05aY8nMiKgas7OJWE7DUc7cYe48ylOJoc7TxGSMD4PDLMvs2QYQya)NcbmnotDQvB90UQzXACiWUUrn7Wt7kn72Kj42GubbTkwIG0IXxZYFlX3gnlxXGuvG010S8qCceKZhJPuRMBDQvZDdAx1Synoeyx3OMD4PDLM1Hy4mpHeW04m1S83s8TrZYprNdiZ3yIq6YcK2CinhcSsVILa(j6CESghcSRz5H4eiiNpgtPwn36uRMB3Ax1SdpTR0SsYwvwfd4)uiGPXzQzXACiWUUrDQtnlVdK4JLLH0UQvZT2vnlwJdb21nQzpYAwjMA2HN2vA2GZBJdbQzdoecOMLFhr)AlVeFSSmK)rXXkjKQcK6gsxwGuYy6JiGfivqqRILiiTy89dpTGiKgas53r0V2YlXhlld5FuCSscPRG01AasxwGuNtkH0aq62IvsWJIJvsivfiv1g0SbNhuJiQzL4JLLHaocVm1Pwnv1UQzXACiWUUrnl)TeFB0SnhsdoVnoeOx5i6GicybPllqQZjLqAaiDBXkj4rXXkjKQcKQA01SdpTR0Swf8yIGicyPtTARPDvZI14qGDDJAw(Bj(2OzdoVnoeOxIpwwgc4i8YuZo80UsZ6qCxhSf(q6uRgdQDvZI14qGDDJAw(Bj(2OzdoVnoeOxIpwwgc4i8YuZo80UsZ6GVeFMwfRtTArx7QMD4PDLMLWIvsjGbi0JfXk1Synoeyx3Oo1Q1mAx1Synoeyx3OML)wIVnA2GZBJdb6L4JLLHaocVm1SdpTR0SB7rhI766uR26w7QMfRXHa76g1S83s8TrZgCEBCiqVeFSSmeWr4LPMD4PDLMDkokZFia8HGqNA1CrAx1Synoeyx3OML)wIVnA2GZBJdb6L4JLLHaocVm1SdpTR0Sotm42G8notPo1QTEAx1Synoeyx3OML)wIVnA2TfRKGhfhRKq6kinmi1TlQbi1Lq6lu4((y0VNCia5jWv8ynoeyhsDXqQBvBasdhsxwGuYy6JiGfivqqRILiiTy89dpTGiKgasddsBoKYVGynv6lK)hX9DiDzbsDe2BVZvyxqMaNhB9cKH0WH0LfinmiLFhr)AlVvbpMiiIawGubbTkwIG0IX3)O4yLesxbPBlwjbpkowjH0WH0aqQJWE7DUc7cYe48yRxGmKUSaPoNucPbG0TfRKGhfhRKqQkqQ7g0SdpTR0S5jWva3g0Xjv0Pwn3nODvZI14qGDDJAw(Bj(2Oz53r0V2Y)M0QyGuOamnot)JIJvsivfifJGCHebPjIA2HN2vA2wCiFLeCBW9D81Pwn3U1UQzXACiWUUrnl)TeFB0SbN3ghc0lXhlldbCeEzQzhEAxPzTsYFHCCiqGlqyQuqe0XGgh1Pwn3QQDvZI14qGDDJAw(Bj(2OzdoVnoeOxIpwwgc4i8YuZo80UsZ2(tQiZRqDQvZ9AAx1Synoeyx3OML)wIVnA2GZBJdb6L4JLLHaocVm1SdpTR0SXet3M8EjWz6XOo1Q5Mb1UQzXACiWUUrn7Wt7knRuz6xB8psYG8suuZYFlX3gnlzm9reWcKkiOvXseKwm((HNwqesxwGuNtkH0aq62IvsWJIJvsivfiv1gG0LfiT5q6lu4((y0BvWJj(sqhjSyL0J14qGDnBnIOMvQm9Rn(hjzqEjkQtTAUJU2vnlwJdb21nQz5VL4BJMT5qAW5TXHa9reWcCfqqIG8TIjMq6YcKYVJOFTL3QGhteeralqQGGwflrqAX47FuCSscPRGuvBasxwG0GZBJdb6voIoiIawA2HN2vAwbjcSefL6uRM7Mr7QMD4PDLMDpiHviqMNiznlwJdb21nQtTAUx3Ax1SdpTR0S7HGalW9D81Synoeyx3Oo1Q52fPDvZI14qGDDJAw(Bj(2OzDoPesdaPBlwjbpkowjHuvGu3rhsxwG0WGuUIbPRibPQcPbG0WG0TfRKGhfhRKq6kiTzAasdaPHbPHbP87i6xB5L4JLLH8pkowjH0vqQ7gG0Lfi1ryV9s8XYYqEbYq6YcKYVJOFTLxIpwwgYlqgsdhsdaPHbPKX0hralqQGGwflrqAX47hEAbriDzbs53r0V2YBvWJjcIiGfivqqRILiiTy89pkowjH0vqQ7gG0Lfin4824qGELJOdIiGfKgoKgoKgoKUSaPHbPBlwjbpkowjHuvibPntdqAainmiLmM(icybsfeSUuSebPfJVF4PfeH0LfiLFhr)AlVvbpMiiIawGubbTkwIG0IX3)O4yLesxbPBlwjbpkowjH0WH0WH0W1SdpTR0SoxHDbzcCESvNA1CVEAx1Synoeyx3OML)wIVnAw(De9RT8VjTkgifkatJZ0)O4yLesvbsvfsxwGuNtkH0aq62IvsWJIJvsivfi1D01SdpTR0Ss8XYYq6uRMQnODvZo80UsZ6mXGBdY34mLAwSghcSRBuNA1u1T2vnlwJdb21nQz5VL4BJMvEceow19KfKPabcWxGCAx5XACiWoKgasDe2BVeFSSmKVFTfKgas7OJWE7DUc7cYe48ylOJoc7TVFTLMD4PDLMDtGsf(p7uN6uZktTRA1CRDvZI14qGDDJAw(Bj(2Oz)X6amiwPF6DP3kiDfKYVJOFTLVvXEcRIb9FIVcqwO4k(UWpPDfK6IH0g8UiiDzbs)X6amiwPF6DPxGSMD4PDLMTvXEcRIb9FIVcqwO4k6uRMQAx1Synoeyx3OML)wIVnAwUI5fNiqQlHuUIbPRibPQcPbGuSWpoKpnreKhqCIaPRG01G0LfiLRyEXjcK6siLRyq6ksqkdcPbG0WGuSWpoKpnreKhqCIaPRGuvH0LfiT5qk5hdcI5DVBFAX4dipeIqA4A2HN2vAwSWp2I2TkgGewe71PwT10UQzXACiWUUrnl)TeFB0S8t05aY8nMiKgasDe2BFFkocUnGRymaZlqgsdaPHbP)yDageR0p9U0BfKUcsDe2BFFkocUnGRymaZ)O4yLesDjKQkKUSaP)yDageR0p9U0lqgsdxZo80UsZkjBvzvmG)tHaMgNPo1QXGAx1Synoeyx3OMD4PDLM9nPvXaPqbyACMAw(Bj(2Oz53r0V2YlXhlld5FuCSscPRGu3q6YcK2CinhcSsVeFSSmKhRXHa7qAainmiLFhr)AlFloKVscUn4(o((hfhRKq6kiLbH0LfiT5qk)cI1uPNzO3McsdxZYdXjqqoFmMsTAU1PwTORDvZI14qGDDJAw(Bj(2Ozdds)X6amiwPF6DP3kiDfKYVJOFTLFBYucUnyl8H8DHFs7ki1fdPn4Drq6YcK(J1byqSs)07sVazinCinaKggKIf(XH8PjIG8aIteiDfKIrqUqIG0eri1LqQBiDzbs5kMxCIaPUes5kgKQcji1nKUSaPoc7TxM3lcW5tfWuDW2E0)O4yLesvbsXiixirqAIiKgfK6gsdhsxwG0TfRKGhfhRKqQkqkgb5cjcsteH0OGu3q6YcK2rhH927Cf2fKjW5XwqhDe2BVazn7Wt7kn72KPeCBWw4dPtTAnJ2vnlwJdb21nQz5VL4BJM1ryV9PccqrY4FVeWhYd3Y79YC4mH0vqQ71dsdaPyHFCiFAIiipG4ebsxbPyeKlKiinresDjK6gsdaP87i6xB5FtAvmqkuaMgNP)rXXkjKUcsXiixirqAIiKUSaPoc7Tpvqaksg)7La(qE4wEVxMdNjKUcsDZGqAainmiLFhr)AlVeFSSmK)rXXkjKQcKgDinaKMdbwPxIpwwgYJ14qGDiDzbs53r0V2Y3Id5RKGBdUVJV)rXXkjKQcKgDinaKYVGynv6zg6TPG0LfiDBXkj4rXXkjKQcKgDinCn7Wt7knl)hotcRIbmGPJaclwjlRI1PwT1T2vnlwJdb21nQz5VL4BJM1ryV9VGuXQyady6iO1QUVFTfKgashEAbrawOOHsiDfK6wZo80UsZ(csfRIbmGPJGwR66uRMls7QMfRXHa76g1SdpTR0SBtMGBdsfe0QyjcslgFnl)TeFB0SCfdsvbsxtZYdXjqqoFmMsTAU1PwT1t7QMfRXHa76g1S83s8TrZYvmV4ebsDjKYvmiDfji1TMD4PDLMfJqgjakZlQtTAUBq7QMfRXHa76g1S83s8TrZYvmV4ebsDjKYvmiDfji1nKgashEAbrawOOHsiLeK6gsdaP)yDageR0p9U0BfKUcsvTbiDzbs5kMxCIaPUes5kgKUIeKQkKgashEAbrawOOHsiDfjivvn7Wt7knlxXaocVm1Pwn3U1UQzhEAxPz5kgODcIAwSghcSRBuNA1CRQ2vnlwJdb21nQzhEAxPztlgFa5HquZYFlX3gnl)eDoGmFJjcPbGuUI5fNiqQlHuUIbPRibPQcPbGuhH92lZ7fb48PcyQoyBp67xBPz5H4eiiNpgtPwn36uRM710UQzXACiWUUrnl)TeFB0Soc7TNRyaSWpoKxMdNjKUcsxRbi1LqA0HuxmKo80cIaSqrdLqAai1ryV9Y8EraoFQaMQd22J((1wqAainmiLFhr)Al)BsRIbsHcW04m9pkowjH0vqQQqAaiLFhr)Al)2KPeCBWw4d5FuCSscPRGuvH0LfiLFhr)Al)BsRIbsHcW04m9pkowjHuvG01G0aqk)oI(1w(Tjtj42GTWhY)O4yLesxbPRbPbGuUIbPRG01G0LfiLFhr)Al)BsRIbsHcW04m9pkowjH0vq6AqAaiLFhr)Al)2KPeCBWw4d5FuCSscPQaPRbPbGuUIbPRGugesxwGuUI5fNiqQlHuUIbPQqcsDdPbGuSWpoKpnreKhqCIaPQaPQcPHdPllqQJWE75kgal8Jd5L5WzcPRGu3naPbG0TfRKGhfhRKqQkq66wZo80UsZkjBvzvmG)tHaMgNPo1Q5Mb1UQzXACiWUUrn7Wt7knRdXWzEcjGPXzQz5VL4BJMLFIohqMVXeH0aqAyqAoeyLEj(yzzipwJdb2H0aqk)oI(1wEj(yzzi)JIJvsivfiDniDzbs53r0V2Y)M0QyGuOamnot)JIJvsiDfK6gsdaP87i6xB53MmLGBd2cFi)JIJvsiDfK6gsxwGu(De9RT8VjTkgifkatJZ0)O4yLesvbsxdsdaP87i6xB53MmLGBd2cFi)JIJvsiDfKUgKgas5kgKUcsvfsxwGu(De9RT8VjTkgifkatJZ0)O4yLesxbPRbPbGu(De9RT8BtMsWTbBHpK)rXXkjKQcKUgKgas5kgKUcsxdsxwGuUIbPRG0OdPllqQJWE7DoMaY)X9cKH0W1S8qCceKZhJPuRMBDQvZD01UQzXACiWUUrn7Wt7knBAX4dipeIAw(Bj(2Oz5NOZbK5BmrinaKYvmV4ebsDjKYvmiDfjivvnlpeNab58Xyk1Q5wNA1C3mAx1Synoeyx3OML)wIVnAwUI5fNiqQlHuUIbPRibPU1SdpTR0SZZNcb59pwPo1Q5EDRDvZAvI)lqo1SU1SdpTR0SBIqwfdK4tgReW04m1Synoeyx3Oo1Q52fPDvZI14qGDDJA2HN2vAwhIHZ8esatJZuZYFlX3gnl)eDoGmFJjcPbGu(De9RT8BtMsWTbBHpK)rXXkjKQcKUgKgas5kgKscsvfsdaPKFmiiM39U9PfJpG8qicPbGuSWpoKpnreKhi6naPQaPU1S8qCceKZhJPuRMBDQvZ96PDvZI14qGDDJA2HN2vAwhIHZ8esatJZuZYFlX3gnl)eDoGmFJjcPbGuSWpoKpnreKhqCIaPQaPQcPbG0WGuUI5fNiqQlHuUIbPQqcsDdPllqk5hdcI5DVBFAX4dipeIqA4AwEiobcY5JXuQvZTo1PML3bsCRDvRMBTRAwSghcSRBuZYFlX3gnBZH0GZBJdb6voIoiIawqAainmiLFhr)Al)BsRIbsHcW04m9pkowjHuvGuvH0LfiT5qk)cI1uPNzO3McsdhsdaPHbPnhs5xqSMk9fY)J4(oKUSaP87i6xB5DUc7cYe48yR)rXXkjKQcKQkKgoKUSaPBlwjbpkowjHuvGuvJUMD4PDLM1QGhteeralDQvtvTRAwSghcSRBuZYFlX3gn72IvsWJIJvsiDfKggK62f1aK6si9fkCFFm63toeG8e4kESghcSdPUyi1TQnaPHdPllqQJWE7L59IaC(ubmvhSTh99RTG0aqkzm9reWcKkiOvXseKwm((HNwqesdaPHbPnhs5xqSMk9fY)J4(oKUSaPoc7T35kSlitGZJTEbYqA4q6YcKggKYVJOFTL3QGhteeralqQGGwflrqAX47FuCSscPRG0TfRKGhfhRKqA4qAai1ryV9oxHDbzcCES1lqgsxwGuNtkH0aq62IvsWJIJvsivfi1DdA2HN2vA28e4kGBd64Kk6uR2AAx1Synoeyx3OML)wIVnA2WG0FSoadIv6NEx6TcsxbPmy0H0Lfi9hRdWGyL(P3LEbYqA4qAaiLFhr)Al)BsRIbsHcW04m9pkowjHuvGumcYfseKMicPbGu(De9RT8wf8yIGicybsfe0QyjcslgF)JIJvsiDfKggKQAdqAuqQQnaPUyi9fkCFFm6Tk4XeFjOJewSs6XACiWoKgoKUSaPoNucPbG0TfRKGhfhRKqQkq6ArxZo80UsZ2Id5RKGBdUVJVo1QXGAx1Synoeyx3OML)wIVnAw(j6Caz(gtesdaPHbP)yDageR0p9U0BfKUcsD3aKUSaP)yDageR0p9U0lqgsdxZo80UsZUhKWkeiZtKSo1QfDTRAwSghcSRBuZYFlX3gn7pwhGbXk9tVl9wbPRG01AasxwG0FSoadIv6NEx6fiRzhEAxPz3dbbwG774RtTAnJ2vnlwJdb21nQz5VL4BJMLRyq6ksqQQqAaiDBXkj4rXXkjKUcsBMgG0aqAyqk)oI(1wEzEViaNpvat1bB7rpxz(yucPRG0gG0LfiLFhr)AlVmVxeGZNkGP6GT9O)rXXkjKUcsD3aKgoKgasddsjJPpIawGubbTkwIG0IX3p80cIq6YcKYVJOFTL3QGhteeralqQGGwflrqAX47FuCSscPRGu3naPllqAW5TXHa9khrheralinCiDzbsdds5kgKUIeKQkKgas3wSscEuCSscPQqcsBMgG0aqAyqkzm9reWcKkiyDPyjcslgF)WtlicPllqk)oI(1wERcEmrqebSaPccAvSebPfJV)rXXkjKUcs3wSscEuCSscPHdPbG0WGu(De9RT8Y8EraoFQaMQd22JEUY8XOesxbPnaPllqk)oI(1wEzEViaNpvat1bB7r)JIJvsiDfKUTyLe8O4yLesxwGuhH92lZ7fb48PcyQoyBp6fidPHdPHdPllq62IvsWJIJvsivfi1D01SdpTR0SoxHDbzcCESvNA1w3Ax1Synoeyx3OML)wIVnAw(vDbl987(UvtIDWT3yjTGOhRXHa7A2HN2vAwzEViaNpvat1bB7rW2ImjQtTAUiTRAwSghcSRBuZYFlX3gnl)oI(1wEzEViaNpvat1bB7rpxz(yucPKGuvH0LfiDBXkj4rXXkjKQcKQAdq6YcKggK(J1byqSs)07s)JIJvsiDfK6o6q6YcKggK2CiLFbXAQ0Zm0BtbPbG0MdP8liwtL(c5)rCFhsdhsdaPHbPHbP)yDageR0p9U0BfKUcs53r0V2YlZ7fb48PcyQoyBp63ceeGh5kZhJG0eriDzbsBoK(J1byqSs)07spgXKPesdhsdaPHbP87i6xB5Tk4XebreWcKkiOvXseKwm((hfhRKq6kiLFhr)AlVmVxeGZNkGP6GT9OFlqqaEKRmFmcsteH0Lfin4824qGELJOdIiGfKgoKgoKgas53r0V2YVnzkb3gSf(q(hfhRKqQkKG01dsdaPCfdsxrcsvfsdaP87i6xB5BvSNWQyq)N4RaKfkUI)rXXkjKQcji1TQqA4A2HN2vAwzEViaNpvat1bB7rDQvB90UQzXACiWUUrnl)TeFB0S8liwtLEMHEBkinaKggK6iS3(wCiFLeCBW9D89cKH0LfinmiDBXkj4rXXkjKQcKYVJOFTLVfhYxjb3gCFhF)JIJvsiDzbs53r0V2Y3Id5RKGBdUVJV)rXXkjKUcs53r0V2YlZ7fb48PcyQoyBp63ceeGh5kZhJG0erinCinaKYVJOFTLFBYucUnyl8H8pkowjHuvibPRhKgas5kgKUIeKQkKgas53r0V2Y3QypHvXG(pXxbiluCf)JIJvsivfsqQBvH0W1SdpTR0SY8EraoFQaMQd22J6uRM7g0UQzXACiWUUrnl)TeFB0S8liwtL(c5)rCFhsdaPD0ryV9oxHDbzcCESf0rhH92lqgsdaPHbPKX0hralqQGGwflrqAX47hEAbriDzbsdoVnoeOx5i6GicybPllqk)oI(1wERcEmrqebSaPccAvSebPfJV)rXXkjKUcs53r0V2YlZ7fb48PcyQoyBp63ceeGh5kZhJG0eriDzbs53r0V2YBvWJjcIiGfivqqRILiiTy89pkowjH0vq6AnaPHRzhEAxPzL59IaC(ubmvhSTh1Pwn3U1UQzXACiWUUrnl)TeFB0SKX0hralqQGGwflrqAX47hEAbriDzbsDoPesdaPBlwjbpkowjHuvGuvBqZo80UsZALK)c54qGaxGWuPGiOJbnoQtTAUvv7QMfRXHa76g1S83s8TrZsgtFebSaPccAvSebPfJVF4PfeH0Lfi15KsinaKUTyLe8O4yLesvbsvTbn7Wt7knB7pPImVc1Pwn3RPDvZI14qGDDJAw(Bj(2OzjJPpIawGubbTkwIG0IX3p80cIq6YcK6CsjKgas3wSscEuCSscPQaPQ2GMD4PDLMnMy62K3lbotpg1Pwn3mO2vnlwJdb21nQzhEAxPz7po9T9iiikLiHML)wIVnA2MdPbN3ghc0hralWvabjcY3kMycPllqk)oI(1wERcEmrqebSaPccAvSebPfJV)rXXkjKUcsvTbinaKsgtFebSaPccAvSebPfJV)rXXkjKQcKQAdq6YcKgCEBCiqVYr0breWsZwJiQz7po9T9iiikLiHo1Q5o6Ax1Synoeyx3OMD4PDLMvQm9Rn(hjzqEjkQz5VL4BJMLmM(icybsfe0QyjcslgF)WtlicPllqQZjLqAaiDBXkj4rXXkjKQcKQAdq6YcK2Ci9fkCFFm6Tk4XeFjOJewSs6XACiWUMTgruZkvM(1g)JKmiVef1Pwn3nJ2vnlwJdb21nQz5VL4BJMT5qAW5TXHa9reWcCfqqIG8TIjMq6YcKYVJOFTL3QGhteeralqQGGwflrqAX47FuCSscPRGuvBasxwG0GZBJdb6voIoiIawA2HN2vAwbjcSefL6uRM71T2vnlwJdb21nQz5VL4BJMDBXkj4rXXkjKUcsxVgG0LfiLmM(icybsfe0QyjcslgF)WtlicPllqAW5TXHa9khrheraliDzbsDoPesdaPBlwjbpkowjHuvGu3nJMD4PDLMnpbUc42aMZlo6uRMBxK2vnlwJdb21nQz5VL4BJMLFhr)AlVvbpMiiIawGubbTkwIG0IX3)O4yLesxbPR1aKUSaPbN3ghc0RCeDqebSG0Lfi15KsinaKUTyLe8O4yLesvbsvTbn7Wt7knRdXDDWw4dPtTAUxpTRAwSghcSRBuZYFlX3gnl)oI(1wERcEmrqebSaPccAvSebPfJV)rXXkjKUcsxRbiDzbsdoVnoeOx5i6GicybPllqQZjLqAaiDBXkj4rXXkjKQcK6o6A2HN2vAwh8L4Z0QyDQvt1g0UQzhEAxPzjSyLucyac9yrSsnlwJdb21nQtTAQ6w7QMfRXHa76g1S83s8TrZYVJOFTL3QGhteeralqQGGwflrqAX47FuCSscPRG01AasxwG0GZBJdb6voIoiIawq6YcK6CsjKgas3wSscEuCSscPQaPUBqZo80UsZUThDiURRtTAQQQ2vnlwJdb21nQz5VL4BJMLFhr)AlVvbpMiiIawGubbTkwIG0IX3)O4yLesxbPR1aKUSaPbN3ghc0RCeDqebSG0Lfi15KsinaKUTyLe8O4yLesvbsvTbn7Wt7kn7uCuM)qa4dbHo1QP6AAx1Synoeyx3OML)wIVnAwhH92lZ7fb48PcyQoyBp67xBPzhEAxPzDMyWTb5BCMsDQvtvgu7QMfRXHa76g1S83s8TrZkpbchR6EYcYuGab4lqoTR8ynoeyhsdaPoc7TxM3lcW5tfWuDW2E03V2csdaPD0ryV9oxHDbzcCESf0rhH923V2sZo80UsZUjqPc)NDQtDQz74EeisTRA1CRDvZo80UsZkjJZduMQdK5BmrnlwJdb21nQtTAQQDvZI14qGDDJA2JSMvIPMD4PDLMn4824qGA2GdHaQz53r0V2YBvWJjcIiGfivqqRILiiTy89pkowjH0vq62IvsWJIJvsiDzbs3wSscEuCSscPUes53r0V2YBvWJjcIiGfivqqRILiiTy89pkowjHuvGu3Q2aKgasddsddsZHaR0lXhlld5XACiWoKgas3wSscEuCSscPRGu(De9RT8s8XYYq(hfhRKqAaiLFhr)AlVeFSSmK)rXXkjKUcsD3aKgoKUSaPHbP87i6xB5L59IaC(ubmvhSTh9BbccWJCL5JrqAIiKQcKUTyLe8O4yLesdaP87i6xB5L59IaC(ubmvhSTh9BbccWJCL5JrqAIiKUcsDhDinCiDzbsdds53r0V2YlZ7fb48PcyQoyBp65kZhJsiLeK2aKgas53r0V2YlZ7fb48PcyQoyBp6FuCSscPQaPBlwjbpkowjH0WH0W1SbNhuJiQzvoIoiIaw6uR2AAx1Synoeyx3OML)wIVnA2WGuhH92lXhlld5fidPllqQJWE7L59IaC(ubmvhSTh9cKH0WH0aqkzm9reWcKkiOvXseKwm((HNwqesxwGuNtkH0aq62IvsWJIJvsivfsqAZ0GMD4PDLML8L2v6uRgdQDvZI14qGDDJAw(Bj(2OzDe2BVeFSSmKxGSMD4PDLMLpeeGHN2vactMAwctMGAernReFSSmKo1QfDTRAwSghcSRBuZYFlX3gnRJWE7BXH8vsWTb33X3lqwZo80UsZYhccWWt7kaHjtnlHjtqnIOMTfhYxjb3gCFhFDQvRz0UQzXACiWUUrnl)TeFB0SPjIqQkqkdcPbGuUIbPQaPrhsdaPnhsjJPpIawGubbTkwIG0IX3p80cIA2HN2vAw(qqagEAxbimzQzjmzcQre1ShzSWxNA1w3Ax1Synoeyx3OMD4PDLMDBYeCBqQGGwflrqAX4Rz5VL4BJMLRyEXjcK6siLRyq6ksq6AqAainmifl8Jd5tteb5beNiqQkqQBiDzbsXc)4q(0erqEaXjcKQcKYGqAaiLFhr)Al)2KPeCBWw4d5FuCSscPQaPU9rhsxwGu(De9RT8T4q(kj42G7747FuCSscPQaPQcPHdPbG0MdPD0ryV9oxHDbzcCESf0rhH92lqwZYdXjqqoFmMsTAU1PwnxK2vnlwJdb21nQz5VL4BJMLRyEXjcK6siLRyq6ksqQBinaKggKIf(XH8PjIG8aIteivfi1nKUSaP87i6xB5L4JLLH8pkowjHuvGuvH0Lfifl8Jd5tteb5beNiqQkqkdcPbGu(De9RT8BtMsWTbBHpK)rXXkjKQcK62hDiDzbs53r0V2Y3Id5RKGBdUVJV)rXXkjKQcKQkKgoKgasBoK6iS3ENRWUGmbop26fiRzhEAxPzXiKrcGY8I6uR26PDvZI14qGDDJA2HN2vA20IXhqEie1S83s8TrZYprNdiZ3yIqAaiLRyEXjcK6siLRyq6ksqQQqAainmifl8Jd5tteb5beNiqQkqQBiDzbs53r0V2YlXhlld5FuCSscPQaPQcPllqkw4hhYNMicYdiorGuvGugesdaP87i6xB53MmLGBd2cFi)JIJvsivfi1Tp6q6YcKYVJOFTLVfhYxjb3gCFhF)JIJvsivfivvinCinaK2CiTJoc7T35kSlitGZJTGo6iS3EbYAwEiobcY5JXuQvZTo1Q5UbTRAwSghcSRBuZYFlX3gnBZH0CiWk9s8XYYqESghcSRzhEAxPz5dbby4PDfGWKPMLWKjOgruZY7ajU1Pwn3U1UQzXACiWUUrnl)TeFB0S5qGv6L4JLLH8ynoeyxZo80UsZYhccWWt7kaHjtnlHjtqnIOML3bs8XYYq6uRMBv1UQzXACiWUUrnl)TeFB0SdpTGialu0qjKQcKUMMD4PDLMLpeeGHN2vactMAwctMGAernRm1Pwn3RPDvZI14qGDDJAw(Bj(2OzhEAbrawOOHsiDfjiDnn7Wt7knlFiiadpTRaeMm1SeMmb1iIA25qDQtnl5h5NOZKAx1Q5w7QMD4PDLM15YKa7GnXec7TwfdYlIvAwSghcSRBuNA1uv7QMfRXHa76g1ShznRetn7Wt7knBW5TXHa1SbhcbuZIUabJmzS7TsYFHCCiqGlqyQuqe0XGghH0LfifDbcgzYy3htmDBY7LaNPhJq6YcKIUabJmzS7B)jvK5viKUSaPOlqWitg7(li(CL5JXoyktCaotM4hcsxwGu0fiyKjJDVuz6xB8psYG8suuZgCEqnIOMnIawGRacseKVvmXuNA1wt7QMD4PDLMDtGsf(p7uZI14qGDDJ6uRgdQDvZI14qGDDJAw(Bj(2OzBoKMdbwPxIpwwgYJ14qGDiDzbsBoKMdbwPFBYeCBqQGGwflrqAX47XACiWUMD4PDLMLRyahHxM6uRw01UQzXACiWUUrnl)TeFB0SnhsZHaR0Jf(Xw0UvXaKWIGVhRXHa7A2HN2vAwUIbANGOo1PMDou7Qwn3Ax1SdpTR0STk2tyvmO)t8vaYcfxrZI14qGDDJ6uRMQAx1Synoeyx3OML)wIVnAwUI5fNiqQlHuUIbPRibPQcPbGuSWpoKpnreKhqCIaPRGuvH0LfiLRyEXjcK6siLRyq6ksqkdQzhEAxPzXc)ylA3QyasyrSxNA1wt7QMfRXHa76g1S83s8TrZYprNdiZ3yIqAainmi1ryV99P4i42aUIXamVaziDzbs7OJWE7DUc7cYe48ylOJoc7TxGmKgUMD4PDLMvs2QYQya)NcbmnotDQvJb1UQzXACiWUUrnl)TeFB0SyHFCiFAIiipG4ebsxbPyeKlKiinresxwGuUI5fNiqQlHuUIbPQqcsDRzhEAxPz3MmLGBd2cFiDQvl6Ax1Synoeyx3OMD4PDLM9nPvXaPqbyACMAw(Bj(2OzddsZHaR03QypHvXG(pXxbiluCfpwJdb2H0aqk)oI(1w(3KwfdKcfGPXz67c)K2vq6kiLFhr)AlFRI9ewfd6)eFfGSqXv8pkowjH0OGugesdhsdaPHbP87i6xB53MmLGBd2cFi)JIJvsiDfKUgKUSaPCfdsxrcsJoKgUMLhItGGC(ymLA1CRtTAnJ2vnlwJdb21nQz5VL4BJM1ryV9VGuXQyady6iO1QUVFTLMD4PDLM9fKkwfdyathbTw11PwT1T2vnlwJdb21nQz5VL4BJMLRyEXjcK6siLRyq6ksqQBn7Wt7knlgHmsauMxuNA1CrAx1Synoeyx3OMD4PDLMDBYeCBqQGGwflrqAX4Rz5VL4BJMLRyEXjcK6siLRyq6ksq6AAwEiobcY5JXuQvZTo1QTEAx1Synoeyx3OML)wIVnAwUI5fNiqQlHuUIbPRibPQQzhEAxPz5kgWr4LPo1Q5UbTRAwSghcSRBuZYFlX3gnRJWE7tfeGIKX)EjGpKhUL37L5WzcPRGu3RhKgasXc)4q(0erqEaXjcKUcsXiixirqAIiK6si1nKgas53r0V2YVnzkb3gSf(q(hfhRKq6kifJGCHebPjIA2HN2vAw(pCMewfdyathbewSswwfRtTAUDRDvZI14qGDDJA2HN2vA20IXhqEie1S83s8TrZYvmV4ebsDjKYvmiDfjivvinaKggK2CinhcSsVILa(j6CESghcSdPllqk)eDoGmFJjcPHRz5H4eiiNpgtPwn36uRMBv1UQzXACiWUUrnl)TeFB0SCfZlorGuxcPCfdsxrcsDRzhEAxPzNNpfcY7FSsDQvZ9AAx1Synoeyx3OML)wIVnAw(j6Caz(gtesdaPHbP87i6xB5DUc7cYe48yR)rXXkjKUcsvfsxwG0MdP8liwtL(c5)rCFhsdhsdaPHbPCfdsxrcsJoKUSaP87i6xB53MmLGBd2cFi)JIJvsiDfK2mq6YcKYVJOFTLFBYucUnyl8H8pkowjH0vq6AqAaiLRyq6ksq6AqAaifl8Jd5tteb5bIEdqQkqQBiDzbsXc)4q(0erqEaXjcKQcjinmiDninkiDni1fdP87i6xB53MmLGBd2cFi)JIJvsivfin6qA4q6YcK6iS3EzEViaNpvat1bB7rVazinCn7Wt7knRKSvLvXa(pfcyACM6uRMBgu7QMfRXHa76g1S83s8TrZYprNdiZ3yIA2HN2vAwUIbANGOo1Q5o6Ax1Synoeyx3OMD4PDLMDteYQyGeFYyLaMgNPML)wIVnAwhH927CmbK)J77xBPzTkX)fiNAw36uRM7Mr7QMfRXHa76g1SdpTR0SoedN5jKaMgNPML)wIVnAw(j6Caz(gtesdaPHbPoc7T35yci)h3lqgsxwG0CiWk9kwc4NOZ5XACiWoKgasj)yqqmV7D7tlgFa5HqesdaPCfdsjbPQcPbGu(De9RT8BtMsWTbBHpK)rXXkjKQcKUgKUSaPCfZlorGuxcPCfdsvHeK6gsdaPKFmiiM39U9sYwvwfd4)uiGPXzcPbGuSWpoKpnreKhqCIaPQaPRbPHRz5H4eiiNpgtPwn36uN6uZgeFPDLwnvBqv3nSUvDnnB78LvXsn76YfkAtTOf1whAwifsDvbHutK89jKUVhszyloKVscUn4(o(mesF0fiyp2Hu5jIq6iKN4Kyhs5ktfJspKX13kesvTzHug4vbXpXoKYWCiWk9rddH08GugMdbwPpA8ynoeyNHq6KqA06646dPH5os4EiJRVviKUwZcPmWRcIFIDiLH5qGv6JggcP5bPmmhcSsF04XACiWodH0jH0O11X1hsdZDKW9qgxFRqi1nd2SqA0gkEbXoKkAvZgnqkxb5mH0WQlH0j4yeJdbcPwbPOOaXK2vHdPH5os4EiJRVviKQAdnlKYaVki(j2HugMdbwPpAyiKMhKYWCiWk9rJhRXHa7mesdZDKW9qgHmUUCHI2ulArT1HMfsHuxvqi1ejFFcP77HugkXhlldXqi9rxGG9yhsLNicPJqEItIDiLRmvmk9qgxFRqi1DdnlKYaVki(j2HugMdbwPpAyiKMhKYWCiWk9rJhRXHa7mesNesJwxhxFinm3rc3dzeY46YfkAtTOf1whAwifsDvbHutK89jKUVhsziVdK4JLLHyiK(OlqWESdPYteH0ripXjXoKYvMkgLEiJRVviKUEnlKYaVki(j2Hug(cfUVpg9rddH08Gug(cfUVpg9rJhRXHa7mesdZDKW9qgxFRqi1nd2Sqkd8QG4Nyhsz4lu4((y0hnmesZdsz4lu4((y0hnESghcSZqiDsinADDC9H0WChjCpKX13kesv1DZcPmWRcIFIDiLHYtGWXQUpAyiKMhKYq5jq4yv3hnESghcSZqinm3rc3dzeY46YfkAtTOf1whAwifsDvbHutK89jKUVhszOmziK(OlqWESdPYteH0ripXjXoKYvMkgLEiJRVviKYGnlKYaVki(j2HugMdbwPpAyiKMhKYWCiWk9rJhRXHa7mesdZDKW9qgxFRqiTzAwiLbEvq8tSdPmmhcSsF0WqinpiLH5qGv6JgpwJdb2ziKgM7iH7HmU(wHqQBgSzHug4vbXpXoKYWCiWk9rddH08GugMdbwPpA8ynoeyNHqAyUJeUhYiKX1Llu0MArlQTo0SqkK6QccPMi57tiDFpKYqEhiXndH0hDbc2JDivEIiKoc5joj2HuUYuXO0dzC9TcHuvBwiLbEvq8tSdPm8fkCFFm6JggcP5bPm8fkCFFm6JgpwJdb2ziKgM7iH7HmU(wHq6AnlKYaVki(j2Hug(cfUVpg9rddH08Gug(cfUVpg9rJhRXHa7mesdZDKW9qgxFRqi1D0BwiLbEvq8tSdPm8fkCFFm6JggcP5bPm8fkCFFm6JgpwJdb2ziKojKgTUoU(qAyUJeUhY46BfcPQYGnlKYaVki(j2HugkpbchR6(OHHqAEqkdLNaHJvDF04XACiWodH0WChjCpKriJRlxOOn1IwuBDOzHui1vfesnrY3Nq6(EiLHDCpcejdH0hDbc2JDivEIiKoc5joj2HuUYuXO0dzC9TcHuvBwiLbEvq8tSdPmmhcSsF0WqinpiLH5qGv6JgpwJdb2ziKgM7iH7HmU(wHqQ7gAwiLbEvq8tSdPmmhcSsF0WqinpiLH5qGv6JgpwJdb2ziKojKgTUoU(qAyUJeUhY46BfcPUD3Sqkd8QG4NyhszyoeyL(OHHqAEqkdZHaR0hnESghcSZqiDsinADDC9H0WChjCpKriJRlxOOn1IwuBDOzHui1vfesnrY3Nq6(EiLHZHmesF0fiyp2Hu5jIq6iKN4Kyhs5ktfJspKX13kesJEZcPmWRcIFIDiLH5qGv6JggcP5bPmmhcSsF04XACiWodH0WChjCpKX13kesD7UzHug4vbXpXoKYWCiWk9rddH08GugMdbwPpA8ynoeyNHqAyUJeUhY46BfcPUBMMfszGxfe)e7qkdZHaR0hnmesZdszyoeyL(OXJ14qGDgcPH5os4EiJqgJwejFFIDiD9G0HN2vqkHjtPhYOML8FBJa1SRZ1jKUUSQ3oemXhsDH)kMqgxNRti1fsiwqMqQQRPoKQAdQ6gYiKX156esDTfhMqQlmMmLq6THuxye(qqQvj(Va5esjUyJ7HmUoxNqQRT4WeszjBvzvmKYa)Pqi1fwJZesjUyJ7HmUoxNqQluVdPoNuUTyLes5kiNPesZdsfNkeKYaDHdsXkFdLEiJqgxNRtinAncYfsSdPo4(Ees5NOZKqQdgBL0dPUqCosoLqADLlvMxClqaPdpTRKq6veH8qghEAxj9KFKFIotgfPMCUmjWoytmHWERvXG8IyfKXHN2vsp5h5NOZKrrQPGZBJdbQEnIiPicybUciirq(wXet1pYKKyQEWHqajHUabJmzS7TsYFHCCiqGlqyQuqe0XGghxwqxGGrMm29Xet3M8EjWz6X4Yc6cemYKXUV9NurMxHllOlqWitg7(li(CL5JXoyktCaotM4hAzbDbcgzYy3lvM(1g)JKmiVefHmo80Us6j)i)eDMmksnTjqPc)NDczC4PDL0t(r(j6mzuKAIRyahHxMQBBsnphcSsVeFSSmKhRXHa7llnphcSs)2Kj42GubbTkwIG0IX3J14qGDiJdpTRKEYpYprNjJIutCfd0obr1TnPMNdbwPhl8JTODRIbiHfbFpwJdb2HmczCDUoH0O1iixiXoKIbXpeKMMicPPccPdpVhsnjKobhJyCiqpKXHN2vsssY48aLP6az(gteY4Wt7kzuKAk4824qGQxJiss5i6GicyP(rMKet1doecij(De9RT8wf8yIGicybsfe0QyjcslgF)JIJvYvBlwjbpkowjxw2wSscEuCSs6s(De9RT8wf8yIGicybsfe0QyjcslgF)JIJvsvCRAdbclSCiWk9s8XYYqb2wSscEuCSsUIFhr)AlVeFSSmK)rXXkza(De9RT8s8XYYq(hfhRKRC3q4llHXVJOFTLxM3lcW5tfWuDW2E0VfiiapYvMpgbPjIQSTyLe8O4yLma)oI(1wEzEViaNpvat1bB7r)wGGa8ixz(yeKMiUYD0dFzjm(De9RT8Y8EraoFQaMQd22JEUY8XOKudb43r0V2YlZ7fb48PcyQoyBp6FuCSsQY2IvsWJIJvYWdhY4Wt7kzuKAI8L2vQBBsH5iS3Ej(yzziVa5LfhH92lZ7fb48PcyQoyBp6fihEaYy6JiGfivqqRILiiTy89dpTG4YIZjLb2wSscEuCSsQcPMPbiJdpTRKrrQj(qqagEAxbimzQEnIijj(yzzi1TnjhH92lXhlld5fidzC4PDLmksnXhccWWt7kaHjt1Rrej1Id5RKGBdUVJV62MKJWE7BXH8vsWTb33X3lqgY4Wt7kzuKAIpeeGHN2vactMQxJis6iJf(QBBsPjIQWGb4kMkrpqZjJPpIawGubbTkwIG0IX3p80cIqghEAxjJIutBtMGBdsfe0QyjcslgF15H4eiiNpgtjj3QBBsCfZlorCjxXwrATaHHf(XH8PjIG8aItevCVSGf(XH8PjIG8aItevyWa87i6xB53MmLGBd2cFi)JIJvsvC7J(Yc)oI(1w(wCiFLeCBW9D89pkowjvr1Wd08o6iS3ENRWUGmbop2c6OJWE7fidzC4PDLmksnHriJeaL5fv32K4kMxCI4sUITIK7aHHf(XH8PjIG8aItevCVSWVJOFTLxIpwwgY)O4yLufvxwWc)4q(0erqEaXjIkmya(De9RT8BtMsWTbBHpK)rXXkPkU9rFzHFhr)AlFloKVscUn4(o((hfhRKQOA4bAUJWE7DUc7cYe48yRxGmKXHN2vYOi1uAX4dipeIQZdXjqqoFmMssUv32K4NOZbK5BmXaCfZlorCjxXwrs1aHHf(XH8PjIG8aItevCVSWVJOFTLxIpwwgY)O4yLufvxwWc)4q(0erqEaXjIkmya(De9RT8BtMsWTbBHpK)rXXkPkU9rFzHFhr)AlFloKVscUn4(o((hfhRKQOA4bAEhDe2BVZvyxqMaNhBbD0ryV9cKHmo80UsgfPM4dbby4PDfGWKP61iIK4DGe3QBBsnphcSsVeFSSmeKXHN2vYOi1eFiiadpTRaeMmvVgrKeVdK4JLLHu32KYHaR0lXhlldbzC4PDLmksnXhccWWt7kaHjt1Rrejjt1TnPHNwqeGfkAOuL1Gmo80UsgfPM4dbby4PDfGWKP61iIKMdv32KgEAbrawOOHYvKwdYiKXHN2vs)CiPwf7jSkg0)j(kazHIRazC4PDL0phgfPMWc)ylA3QyasyrSxDBtIRyEXjIl5k2ksQgal8Jd5tteb5beNiRuDzHRyEXjIl5k2ksmiKXHN2vs)CyuKAss2QYQya)Ncbmnot1Tnj(j6Caz(gtmqyoc7TVpfhb3gWvmgG5fiVS0rhH927Cf2fKjW5XwqhDe2BVa5WHmo80Us6NdJIutBtMsWTbBHpK62Mew4hhYNMicYdiorwHrqUqIG0eXLfUI5fNiUKRyQqYnKXHN2vs)CyuKA6nPvXaPqbyACMQZdXjqqoFmMssUv32KclhcSsFRI9ewfd6)eFfGSqXvcWVJOFTL)nPvXaPqbyACM(UWpPD1k(De9RT8Tk2tyvmO)t8vaYcfxX)O4yLmkgm8aHXVJOFTLFBYucUnyl8H8pkowjxT2YcxXwrk6HdzC4PDL0phgfPMEbPIvXagW0rqRvD1TnjhH92)csfRIbmGPJGwR6((1wqghEAxj9ZHrrQjmczKaOmVO62MexX8ItexYvSvKCdzC4PDL0phgfPM2Mmb3gKkiOvXseKwm(QZdXjqqoFmMssUv32K4kMxCI4sUITI0AqghEAxj9ZHrrQjUIbCeEzQUTjXvmV4eXLCfBfjvHmo80Us6NdJIut8F4mjSkgWaMociSyLSSkwDBtYryV9PccqrY4FVeWhYd3Y79YC4mx5E9cGf(XH8PjIG8aItKvyeKlKiinr0LUdWVJOFTLFBYucUnyl8H8pkowjxHrqUqIG0eriJdpTRK(5WOi1uAX4dipeIQZdXjqqoFmMssUv32K4kMxCI4sUITIKQbcR55qGv6vSeWprNBzHFIohqMVXedhY4Wt7kPFomksnnpFkeK3)yLQBBsCfZlorCjxXwrYnKXHN2vs)CyuKAss2QYQya)Ncbmnot1Tnj(j6Caz(gtmqy87i6xB5DUc7cYe48yR)rXXk5kvxwAo)cI1uPVq(Fe33dpqyCfBfPOVSWVJOFTLFBYucUnyl8H8pkowjx1mll87i6xB53MmLGBd2cFi)JIJvYvRfGRyRiTwaSWpoKpnreKhi6nOI7LfSWpoKpnreKhqCIOcPWwlQ1CX87i6xB53MmLGBd2cFi)JIJvsvIE4lloc7TxM3lcW5tfWuDW2E0lqoCiJdpTRK(5WOi1exXaTtquDBtIFIohqMVXeHmo80Us6NdJIutBIqwfdK4tgReW04mv32KCe2BVZXeq(pUVFTL6wL4)cKtsUHmo80Us6NdJIutoedN5jKaMgNP68qCceKZhJPKKB1Tnj(j6Caz(gtmqyoc7T35yci)h3lqEzjhcSsVILa(j6Cbi)yqqmV7D7tlgFa5HqmaxXiPAa(De9RT8BtMsWTbBHpK)rXXkPkRTSWvmV4eXLCftfsUdq(XGGyE372ljBvzvmG)tHaMgNzaSWpoKpnreKhqCIOYAHdzeY4Wt7kPN3bsCtYQGhteeralqQGGwflrqAX4RUTj18GZBJdb6voIoiIawbcJFhr)Al)BsRIbsHcW04m9pkowjvr1LLMZVGynv6zg6TPcpqynNFbXAQ0xi)pI77ll87i6xB5DUc7cYe48yR)rXXkPkQg(YY2IvsWJIJvsvun6qghEAxj98oqI7Oi1uEcCfWTbDCsf1TnPTfRKGhfhRKRcZTlQbx(cfUVpg97jhcqEcCfxSBvBi8LfhH92lZ7fb48PcyQoyBp67xBfGmM(icybsfe0QyjcslgF)WtligiSMZVGynv6lK)hX99LfhH927Cf2fKjW5XwVa5WxwcJFhr)AlVvbpMiiIawGubbTkwIG0IX3)O4yLC12IvsWJIJvYWd4iS3ENRWUGmbop26fiVS4CszGTfRKGhfhRKQ4UbiJdpTRKEEhiXDuKAQfhYxjb3gCFhF1TnPW(X6amiwPF6DP3Qvmy0xw(X6amiwPF6DPxGC4b43r0V2Y)M0QyGuOamnot)JIJvsvWiixirqAIya(De9RT8wf8yIGicybsfe0QyjcslgF)JIJvYvHPAdrPAdU4xOW99XO3QGht8LGosyXkz4lloNugyBXkj4rXXkPkRfDiJdpTRKEEhiXDuKAApiHviqMNiz1Tnj(j6Caz(gtmqy)yDageR0p9U0B1k3nSS8J1byqSs)07sVa5WHmo80Us65DGe3rrQP9qqGf4(o(QBBs)yDageR0p9U0B1Q1Ayz5hRdWGyL(P3LEbYqghEAxj98oqI7Oi1KZvyxqMaNhBv32K4k2ksQgyBXkj4rXXk5QMPHaHXVJOFTLxM3lcW5tfWuDW2E0ZvMpgLRAyzHFhr)AlVmVxeGZNkGP6GT9O)rXXk5k3neEGWiJPpIawGubbTkwIG0IX3p80cIll87i6xB5Tk4XebreWcKkiOvXseKwm((hfhRKRC3WYsW5TXHa9khrheraRWxwcJRyRiPAGTfRKGhfhRKQqQzAiqyKX0hralqQGG1LILiiTy89dpTG4Yc)oI(1wERcEmrqebSaPccAvSebPfJV)rXXk5QTfRKGhfhRKHhim(De9RT8Y8EraoFQaMQd22JEUY8XOCvdll87i6xB5L59IaC(ubmvhSTh9pkowjxTTyLe8O4yLCzXryV9Y8EraoFQaMQd22JEbYHh(YY2IvsWJIJvsvChDiJdpTRKEEhiXDuKAsM3lcW5tfWuDW2EeSTitIQBBs8R6cw6539DRMe7GBVXsAbrpwJdb2Hmo80Us65DGe3rrQjzEViaNpvat1bB7r1Tnj(De9RT8Y8EraoFQaMQd22JEUY8XOKKQllBlwjbpkowjvr1gwwc7hRdWGyL(P3L(hfhRKRCh9LLWAo)cI1uPNzO3MkqZ5xqSMk9fY)J4(E4bclSFSoadIv6NEx6TAf)oI(1wEzEViaNpvat1bB7r)wGGa8ixz(yeKMiUS08FSoadIv6NEx6XiMmLHhim(De9RT8wf8yIGicybsfe0QyjcslgF)JIJvYv87i6xB5L59IaC(ubmvhSTh9BbccWJCL5JrqAI4YsW5TXHa9khrheraRWdpa)oI(1w(Tjtj42GTWhY)O4yLufsRxaUITIKQb43r0V2Y3QypHvXG(pXxbiluCf)JIJvsvi5w1WHmo80Us65DGe3rrQjzEViaNpvat1bB7r1Tnj(feRPspZqVnvGWCe2BFloKVscUn4(o(EbYllHTTyLe8O4yLuf(De9RT8T4q(kj42G7747FuCSsUSWVJOFTLVfhYxjb3gCFhF)JIJvYv87i6xB5L59IaC(ubmvhSTh9BbccWJCL5JrqAIy4b43r0V2YVnzkb3gSf(q(hfhRKQqA9cWvSvKuna)oI(1w(wf7jSkg0)j(kazHIR4FuCSsQcj3QgoKXHN2vspVdK4oksnjZ7fb48PcyQoyBpQUTjXVGynv6lK)hX99aD0ryV9oxHDbzcCESf0rhH92lqoqyKX0hralqQGGwflrqAX47hEAbXLLGZBJdb6voIoiIawll87i6xB5Tk4XebreWcKkiOvXseKwm((hfhRKR43r0V2YlZ7fb48PcyQoyBp63ceeGh5kZhJG0eXLf(De9RT8wf8yIGicybsfe0QyjcslgF)JIJvYvR1q4qghEAxj98oqI7Oi1Kvs(lKJdbcCbctLcIGog04O62Mezm9reWcKkiOvXseKwm((HNwqCzX5KYaBlwjbpkowjvr1gGmo80Us65DGe3rrQP2FsfzEfQUTjrgtFebSaPccAvSebPfJVF4PfexwCoPmW2IvsWJIJvsvuTbiJdpTRKEEhiXDuKAkMy62K3lbotpgv32KiJPpIawGubbTkwIG0IX3p80cIlloNugyBXkj4rXXkPkQ2aKXHN2vspVdK4oksnjirGLOO61iIK6po9T9iiikLiH62MuZdoVnoeOpIawGRacseKVvmXCzHFhr)AlVvbpMiiIawGubbTkwIG0IX3)O4yLCLQneGmM(icybsfe0QyjcslgF)JIJvsvuTHLLGZBJdb6voIoiIawqghEAxj98oqI7Oi1KGebwIIQxJissQm9Rn(hjzqEjkQUTjrgtFebSaPccAvSebPfJVF4PfexwCoPmW2IvsWJIJvsvuTHLLM)cfUVpg9wf8yIVe0rclwjHmo80Us65DGe3rrQjbjcSefLQBBsnp4824qG(icybUciirq(wXeZLf(De9RT8wf8yIGicybsfe0QyjcslgF)JIJvYvQ2WYsW5TXHa9khrheraliJdpTRKEEhiXDuKAkpbUc42aMZloQBBsBlwjbpkowjxTEnSSqgtFebSaPccAvSebPfJVF4PfexwcoVnoeOx5i6GicyTS4CszGTfRKGhfhRKQ4UzGmo80Us65DGe3rrQjhI76GTWhsDBtIFhr)AlVvbpMiiIawGubbTkwIG0IX3)O4yLC1AnSSeCEBCiqVYr0breWAzX5KYaBlwjbpkowjvr1gGmo80Us65DGe3rrQjh8L4Z0Qy1Tnj(De9RT8wf8yIGicybsfe0QyjcslgF)JIJvYvR1WYsW5TXHa9khrheraRLfNtkdSTyLe8O4yLuf3rhY4Wt7kPN3bsChfPMiSyLucyac9yrSsiJdpTRKEEhiXDuKAABp6qCxxDBtIFhr)AlVvbpMiiIawGubbTkwIG0IX3)O4yLC1AnSSeCEBCiqVYr0breWAzX5KYaBlwjbpkowjvXDdqghEAxj98oqI7Oi10uCuM)qa4dbH62Me)oI(1wERcEmrqebSaPccAvSebPfJV)rXXk5Q1Ayzj4824qGELJOdIiG1YIZjLb2wSscEuCSsQIQnazC4PDL0Z7ajUJIutotm42G8notP62MKJWE7L59IaC(ubmvhSTh99RTGmo80Us65DGe3rrQPnbkv4)St1Tnj5jq4yv3twqMceiaFbYPDvahH92lZ7fb48PcyQoyBp67xBfOJoc7T35kSlitGZJTGo6iS3((1wqgHmo80Us65DGeFSSmePGZBJdbQEnIijj(yzziGJWlt1pYKKyQEWHqajXVJOFTLxIpwwgY)O4yLuf3llKX0hralqQGGwflrqAX47hEAbXa87i6xB5L4JLLH8pkowjxTwdlloNugyBXkj4rXXkPkQ2aKXHN2vspVdK4JLLHIIutwf8yIGicybsfe0QyjcslgF1TnPMhCEBCiqVYr0breWAzX5KYaBlwjbpkowjvr1OdzC4PDL0Z7aj(yzzOOi1KdXDDWw4dPUTjfCEBCiqVeFSSmeWr4LjKXHN2vspVdK4JLLHIIuto4lXNPvXQBBsbN3ghc0lXhlldbCeEzczC4PDL0Z7aj(yzzOOi1eHfRKsadqOhlIvczC4PDL0Z7aj(yzzOOi102E0H4UU62MuW5TXHa9s8XYYqahHxMqghEAxj98oqIpwwgkksnnfhL5pea(qqOUTjfCEBCiqVeFSSmeWr4LjKXHN2vspVdK4JLLHIIutotm42G8notP62MuW5TXHa9s8XYYqahHxMqghEAxj98oqIpwwgkksnLNaxbCBqhNurDBtABXkj4rXXk5QWC7IAWLVqH77Jr)EYHaKNaxXf7w1gcFzHmM(icybsfe0QyjcslgF)WtligiSMZVGynv6lK)hX99LfhH927Cf2fKjW5XwVa5WxwcJFhr)AlVvbpMiiIawGubbTkwIG0IX3)O4yLC12IvsWJIJvYWd4iS3ENRWUGmbop26fiVS4CszGTfRKGhfhRKQ4UbiJdpTRKEEhiXhlldffPMAXH8vsWTb33XxDBtIFhr)Al)BsRIbsHcW04m9pkowjvbJGCHebPjIqghEAxj98oqIpwwgkksnzLK)c54qGaxGWuPGiOJbnoQUTjfCEBCiqVeFSSmeWr4LjKXHN2vspVdK4JLLHIIutT)KkY8kuDBtk4824qGEj(yzziGJWltiJdpTRKEEhiXhlldffPMIjMUn59sGZ0Jr1TnPGZBJdb6L4JLLHaocVmHmo80Us65DGeFSSmuuKAsqIalrr1RrejjvM(1g)JKmiVefv32KiJPpIawGubbTkwIG0IX3p80cIlloNugyBXkj4rXXkPkQ2WYsZFHc33hJERcEmXxc6iHfRKqghEAxj98oqIpwwgkksnjirGLOOuDBtQ5bN3ghc0hralWvabjcY3kMyUSWVJOFTL3QGhteeralqQGGwflrqAX47FuCSsUs1gwwcoVnoeOx5i6GicybzC4PDL0Z7aj(yzzOOi10EqcRqGmprYqghEAxj98oqIpwwgkksnThccSa33XhY4Wt7kPN3bs8XYYqrrQjNRWUGmbop2QUTj5CszGTfRKGhfhRKQ4o6llHXvSvKunqyBlwjbpkowjx1mneiSW43r0V2YlXhlld5FuCSsUYDdlloc7TxIpwwgYlqEzHFhr)AlVeFSSmKxGC4bcJmM(icybsfe0QyjcslgF)WtliUSWVJOFTL3QGhteeralqQGGwflrqAX47FuCSsUYDdllbN3ghc0RCeDqebScp8WxwcBBXkj4rXXkPkKAMgcegzm9reWcKkiyDPyjcslgF)WtliUSWVJOFTL3QGhteeralqQGGwflrqAX47FuCSsUABXkj4rXXkz4HhoKXHN2vspVdK4JLLHIIuts8XYYqQBBs87i6xB5FtAvmqkuaMgNP)rXXkPkQUS4CszGTfRKGhfhRKQ4o6qghEAxj98oqIpwwgkksn5mXGBdY34mLqghEAxj98oqIpwwgkksnTjqPc)NDQUTjjpbchR6EYcYuGab4lqoTRc4iS3Ej(yzziF)ARaD0ryV9oxHDbzcCESf0rhH923V2cYiKXHN2vs)rgl8jTnzcUnivqqRILiiTy8vNhItGGC(pgtjj3QBBsCfZlorCjxXwrAniJdpTRK(Jmw4hfPMWiKrcGY8IQBBs5qGv65kgWr4LPhRXHa7b4kMxCI4sUITI0AqghEAxj9hzSWpksnLwm(aYdHO68qCceKZhJPKKB1Tnj(j6Caz(gtmaxX8ItexYvSvKufY4Wt7kP)iJf(rrQjUIbANGO62MexX8ItexYvmsQczC4PDL0FKXc)Oi1egHmsauMxeY4Wt7kP)iJf(rrQP0IXhqEievNhItGGC(ymLKCRUTjXvmV4eXLCfBfjvHmczC4PDL0lXhlldrABYucUnyl8Hu32KCe2BVeFSSmK)rXXkPkUHmo80Us6L4JLLHIIutsYwvwfd4)uiGPXzQUTjXprNdiZ3yIbcB4PfebyHIgkxrATLLHNwqeGfkAOCL7anNFhr)Al)BsRIbsHcW04m9cKdhY4Wt7kPxIpwwgkksn9M0QyGuOamnot15H4eiiNpgtjj3QBBs8t05aY8nMiKXHN2vsVeFSSmuuKAABYucUnyl8Hu32KgEAbrawOOHYvKwdY4Wt7kPxIpwwgkksnjjBvzvmG)tHaMgNP62Me)eDoGmFJjgWryV99P4i42aUIXamVaziJdpTRKEj(yzzOOi1KdXWzEcjGPXzQopeNab58Xykj5wDBtIFIohqMVXed4iS3(wCiFLeCBW9D89cKdWVJOFTL)nPvXaPqbyACM(hfhRKRufY4Wt7kPxIpwwgkksnTnzkb3gSf(qQBvI)lqob2MKJWE7L4JLLH8cKdWVJOFTL)nPvXaPqbyACM(hNEiiJdpTRKEj(yzzOOi1KKSvLvXa(pfcyACMQBBs8t05aY8nMyGo6iS3ENRWUGmbop2c6OJWE7fidzC4PDL0lXhlldffPM2Mmb3gKkiOvXseKwm(QZdXjqqoFmMssUv32K4kMkRbzC4PDL0lXhlldffPMCigoZtibmnot15H4eiiNpgtjj3QBBs8t05aY8nM4YsZZHaR0RyjGFIohKXHN2vsVeFSSmuuKAss2QYQya)NcbmnotiJqghEAxj9YKuRI9ewfd6)eFfGSqXvu32K(X6amiwPF6DP3Qv87i6xB5BvSNWQyq)N4RaKfkUIVl8tAx5IBW7Iww(X6amiwPF6DPxGmKXHN2vsVmJIutyHFSfTBvmajSi2RUTjXvmV4eXLCfBfjvdGf(XH8PjIG8aItKvRTSWvmV4eXLCfBfjgmqyyHFCiFAIiipG4ezLQllnN8JbbX8U3TpTy8bKhcXWHmo80Us6LzuKAss2QYQya)Ncbmnot1Tnj(j6Caz(gtmGJWE77tXrWTbCfJbyEbYbc7hRdWGyL(P3LERw5iS3((uCeCBaxXyaM)rXXkPlvDz5hRdWGyL(P3LEbYHdzC4PDL0lZOi10BsRIbsHcW04mvNhItGGC(ymLKCRUTjXVJOFTLxIpwwgY)O4yLCL7LLMNdbwPxIpwwgkqy87i6xB5BXH8vsWTb33X3)O4yLCfdUS0C(feRPspZqVnv4qghEAxj9YmksnTnzkb3gSf(qQBBsH9J1byqSs)07sVvR43r0V2YVnzkb3gSf(q(UWpPDLlUbVlAz5hRdWGyL(P3LEbYHhimSWpoKpnreKhqCIScJGCHebPjIU09YcxX8ItexYvmvi5EzXryV9Y8EraoFQaMQd22J(hfhRKQGrqUqIG0eXOCh(YY2IvsWJIJvsvWiixirqAIyuUxw6OJWE7DUc7cYe48ylOJoc7TxGmKXHN2vsVmJIut8F4mjSkgWaMociSyLSSkwDBtYryV9PccqrY4FVeWhYd3Y79YC4mx5E9cGf(XH8PjIG8aItKvyeKlKiinr0LUdWVJOFTL)nPvXaPqbyACM(hfhRKRWiixirqAI4YIJWE7tfeGIKX)EjGpKhUL37L5WzUYndgim(De9RT8s8XYYq(hfhRKQe9a5qGv6L4JLLHww43r0V2Y3Id5RKGBdUVJV)rXXkPkrpa)cI1uPNzO3MAzzBXkj4rXXkPkrpCiJdpTRKEzgfPMEbPIvXagW0rqRvD1TnjhH92)csfRIbmGPJGwR6((1wbgEAbrawOOHYvUHmo80Us6LzuKAABYeCBqQGGwflrqAX4RopeNab58Xykj5wDBtIRyQSgKXHN2vsVmJIutyeYibqzEr1TnjUI5fNiUKRyRi5gY4Wt7kPxMrrQjUIbCeEzQUTjXvmV4eXLCfBfj3bgEAbrawOOHssUd8J1byqSs)07sVvRuTHLfUI5fNiUKRyRiPAGHNwqeGfkAOCfjvHmo80Us6LzuKAIRyG2jiczC4PDL0lZOi1uAX4dipeIQZdXjqqoFmMssUv32K4NOZbK5BmXaCfZlorCjxXwrs1aoc7TxM3lcW5tfWuDW2E03V2cY4Wt7kPxMrrQjjzRkRIb8FkeW04mv32KCe2BpxXayHFCiVmhoZvR1GlJUlE4PfebyHIgkd4iS3EzEViaNpvat1bB7rF)ARaHXVJOFTL)nPvXaPqbyACM(hfhRKRuna)oI(1w(Tjtj42GTWhY)O4yLCLQll87i6xB5FtAvmqkuaMgNP)rXXkPkRfGFhr)Al)2KPeCBWw4d5FuCSsUATaCfB1All87i6xB5FtAvmqkuaMgNP)rXXk5Q1cWVJOFTLFBYucUnyl8H8pkowjvzTaCfBfdUSWvmV4eXLCftfsUdGf(XH8PjIG8aItevun8LfhH92Zvmaw4hhYlZHZCL7gcSTyLe8O4yLuL1nKXHN2vsVmJIutoedN5jKaMgNP68qCceKZhJPKKB1Tnj(j6Caz(gtmqy5qGv6L4JLLHcWVJOFTLxIpwwgY)O4yLuL1ww43r0V2Y)M0QyGuOamnot)JIJvYvUdWVJOFTLFBYucUnyl8H8pkowjx5EzHFhr)Al)BsRIbsHcW04m9pkowjvzTa87i6xB53MmLGBd2cFi)JIJvYvRfGRyRuDzHFhr)Al)BsRIbsHcW04m9pkowjxTwa(De9RT8BtMsWTbBHpK)rXXkPkRfGRyRwBzHRyRI(YIJWE7DoMaY)X9cKdhY4Wt7kPxMrrQP0IXhqEievNhItGGC(ymLKCRUTjXprNdiZ3yIb4kMxCI4sUITIKQqghEAxj9YmksnnpFkeK3)yLQBBsCfZlorCjxXwrYnKXHN2vsVmJIutBIqwfdK4tgReW04mv3Qe)xGCsYnKXHN2vsVmJIutoedN5jKaMgNP68qCceKZhJPKKB1Tnj(j6Caz(gtma)oI(1w(Tjtj42GTWhY)O4yLuL1cWvmsQgG8JbbX8U3TpTy8bKhcXayHFCiFAIiipq0Bqf3qghEAxj9Ymksn5qmCMNqcyACMQZdXjqqoFmMssUv32K4NOZbK5BmXayHFCiFAIiipG4erfvdegxX8ItexYvmvi5EzH8JbbX8U3TpTy8bKhcXWHmczC4PDL03Id5RKGBdUVJpPGZBJdbQEnIijhIHZ8esatJZeui2XU6hzssmvp4qiGKCe2BFloKVscUn4(o(G2w)JIJvYaHXVJOFTL)nPvXaPqbyACM(hfhRKRCe2BFloKVscUn4(o(G2w)JIJvYaoc7TVfhYxjb3gCFhFqBR)rXXkPkQ6DVSWVJOFTL)nPvXaPqbyACM(hfhRKU0ryV9T4q(kj42G774dAB9pkowjx52VEbCe2BFloKVscUn4(o(G2w)JIJvsvyqV7LfhH927qCxNqqMEbYbCe2BVvbpM4lbDKWIvsVa5aoc7T3QGht8LGosyXkP)rXXkPkoc7TVfhYxjb3gCFhFqBR)rXXkz4qghEAxj9T4q(kj42G774hfPM4dbby4PDfGWKP61iIK4DGe3QBBsnphcSsVeFSSmeKXHN2vsFloKVscUn4(o(rrQj(qqagEAxbimzQEnIijEhiXhlldPUTjLdbwPxIpwwgcY4Wt7kPVfhYxjb3gCFh)Oi1ew4hBr7wfdqclI9QBBsCfZlorCjxXwrs1ayHFCiFAIiipG4ez1AqghEAxj9T4q(kj42G774hfPMEtAvmqkuaMgNP68qCceKZhJPKKBiJdpTRK(wCiFLeCBW9D8JIutBtMsWTbBHpK62M0WtlicWcfnuUIKQbCe2BFloKVscUn4(o(G2w)JIJvsvCdzC4PDL03Id5RKGBdUVJFuKAQvXEcRIb9FIVcqwO4kQBBsdpTGialu0q5ksQczC4PDL03Id5RKGBdUVJFuKAss2QYQya)Ncbmnot1Tnj(j6Caz(gtmWWtlicWcfnuUI0AbCe2BFloKVscUn4(o(G2wVaziJdpTRK(wCiFLeCBW9D8JIutoedN5jKaMgNP68qCceKZhJPKKB1Tnj(j6Caz(gtmWWtlicWcfnuQcjvdeCEBCiqVdXWzEcjGPXzcke7yhY4Wt7kPVfhYxjb3gCFh)Oi1KKSvLvXa(pfcyACMQBBs8t05aY8nMyahH923NIJGBd4kgdW8cKHmo80Us6BXH8vsWTb33XpksnHriJeaL5fv32K4kgPgc4iS3(wCiFLeCBW9D8bTT(hfhRKQWGqghEAxj9T4q(kj42G774hfPM2Mmb3gKkiOvXseKwm(QZdXjqqoFmMssUv32K4kgPgc4iS3(wCiFLeCBW9D8bTT(hfhRKQWGqghEAxj9T4q(kj42G774hfPMAvSNWQyq)N4RaKfkUcKXHN2vsFloKVscUn4(o(rrQP0IXhqEievpNpgtGTjjAvZ2rhH92loptWTbPcc4)uO)rXXkzuH1rhH92lzg6XHRaWikJGmTR8cKDXQ2q4QBBsCfJudbCe2BFloKVscUn4(o(G2w)JIJvsvyqiJdpTRK(wCiFLeCBW9D8JIutBtMsWTbBHpK6wL4)cKtGTj5iS3(wCiFLeCBW9D8bTTEbYQBBsoc7TxM3lcW5tfWuDW2E0lqoWpwhGbXk9tVl9wTIFhr)Al)2KPeCBWw4d57c)K2vU4g8ndKXHN2vsFloKVscUn4(o(rrQjjzRkRIb8FkeW04mv32KCe2BpxXayHFCiVmhoZvR1GlJUlE4PfebyHIgkHmo80Us6BXH8vsWTb33XpksnTnzcUnivqqRILiiTy8vNhItGGC(ymLKCRUTjXvmvwdY4Wt7kPVfhYxjb3gCFh)Oi1egHmsauMxuDBtIRyEXjIl5k2ksUHmo80Us6BXH8vsWTb33XpksnXvmGJWlt1TnjUI5fNiUKRyRifM7OgEAbrawOOHYvUdhY4Wt7kPVfhYxjb3gCFh)Oi1uAX4dipeIQZdXjqqoFmMssUv32KcR55qGv6vSeWprNBzHFIohqMVXedpaxX8ItexYvSvKufY4Wt7kPVfhYxjb3gCFh)Oi1KdXWzEcjGPXzQopeNab58Xykj5wDBtA4PfebyHIgkvH0Ab4k2ksRTS4iS3(wCiFLeCBW9D8bTTEbYqghEAxj9T4q(kj42G774hfPM4kgODcIqghEAxj9T4q(kj42G774hfPM2eHSkgiXNmwjGPXzQUvj(Va5KKBn7iKk3RzznrgOo1Pwd]] )


end