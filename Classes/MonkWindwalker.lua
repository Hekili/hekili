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


    spec:RegisterPack( "Windwalker", 20211123, [[dSeWGcqiPO6rcvP2Ka(ekrJsO0PeQSkHQKxjumlIu3IcXUO0VKImmPqhJcwgkvptjLPHsORjuvBtkk(MsQsJtOkCoLuX6usLMhrY9qK9PKCqkKuluk4HkPQMifssUOqvuBKcjHpkfLYjfQISsusVKcjrZeLa3KcjP2jkLFkfLQLkfL0trXuPq9vLufJLcP2lP(lWGr6Wkwmf9yunzP6YqBwP(SqgnjDAQwnkb9AIy2iCBsSBj)wvdhrDCkKy5Q8Cctx01jQTlqFxknEb15fK1lfLy(kX(bT2G2yntFsuZg7nYUbdgyFnl7SZIRZAnJMjdrg1mKhUKjc1m1OGAM1Jx92HqcEAgYtiIF6AJ1mIx(4OMrZyk7ez8uPn1m9jrnBS3i7gmyG91SSZolUoRzqZiiJCnBS3mRJMr17DS0MAMok4AM1Jx92HqcEqQr1FjbYkBFquXepi1WAsdPS3i7gGSczD9vNlcfRlKvJaPg3IJei1OcxKci93qQrfYxii1ReVtMCcPeFKZTqwncKAClosGugYEvEfbPR)nfcPgv6CjqkXh5ClKvJaPg19oKA(cX2JutiLRICjcinFivzQqq66BufKIvEokSAgcxKcTXAMNmw4PnwZMbTXAgSgtcSRBqZm80)sZSDrc(nivrqRQNii9i80m8Zt88rZWvDRYegsncKYvDiDfjiDnndpeNab5CxeMcnJbDQzJDTXAgSgtcSRBqZWppXZhntoeyLwUQdmLprAXAmjWoKgas5QUvzcdPgbs5QoKUIeKUMMz4P)LMbdtgjaQZPOtnBRPnwZG1ysGDDdAMHN(xAM0JWdqEiu0m8Zt88rZWFfZhiYZLGqAaiLR6wLjmKAeiLR6q6ksqk7AgEiobcY5IWuOzZGo1SXIAJ1mynMeyx3GMHFEINpAgUQBvMWqQrGuUQdPKGu21mdp9V0mCvh0obrDQzl(AJ1mdp9V0myyYibqDofndwJjb21nOtnBnJ2yndwJjb21nOzgE6FPzspcpa5HqrZWppXZhndx1Tktyi1iqkx1H0vKGu21m8qCceKZfHPqZMbDQtntloK)sa(n4VoEAJ1SzqBSMbRXKa76g0mpznJatnZWt)lntW58XKa1mbhczuZykV32wCi)La8BWFD8aTT2dvgVeqAainwiL)pr)Bl75cVIac5ciX5sShQmEjG0vqQP8EBBXH8xcWVb)1Xd02Apuz8saPbGut5922Id5VeGFd(RJhOT1EOY4LasLcsz3AasxwGu()e9VTSNl8kciKlGeNlXEOY4LasncKAkV32wCi)La8BWFD8aTT2dvgVeq6ki1GDDG0aqQP8EBBXH8xcWVb)1Xd02Apuz8saPsbPSO1aKUSaPMY7T1K4)oHSiTYKH0aqQP8EB9k4lbpbOJeEKAALjdPbGut5926vWxcEcqhj8i10EOY4LasLcsnL3BBloK)sa(n4VoEG2w7HkJxcinontW5a1OGAgtIHl5LtGeNlbui2XUo1SXU2yndwJjb21nOz4NN45JMP5qAoeyLwbEy5zilwJjb21mI8CEQzZGMz4P)LMHpeeGHN(xacxKAgcxKGAuqndVde4wNA2wtBSMbRXKa76g0m8Zt88rZKdbwPvGhwEgYI1ysGDnJipNNA2mOzgE6FPz4dbby4P)fGWfPMHWfjOgfuZW7abEy5ziDQzJf1gRzWAmjWUUbnd)8epF0mCv3QmHHuJaPCvhsxrcszhsdaPyHxuiB6kiiFGYegsxbPRPzgE6FPzWcViVzXRias4H9tNA2IV2yndwJjb21nOzgE6FPzox4veqixajoxIMHhItGGCUimfA2mOtnBnJ2yndwJjb21nOz4NN45JMz4PhebyHkokG0vKGu2H0aqQP8EBBXH8xcWVb)1Xd02Apuz8saPsbPg0mdp9V0mBxKcWVbB5lKo1STE1gRzWAmjWUUbnd)8epF0mdp9GialuXrbKUIeKYUMz4P)LMPv1pcVIa9BI(cqwU4Q6uZw8qBSMbRXKa76g0m8Zt88rZWFfZhiYZLGqAaiD4PhebyHkokG0vKG01G0aqQP8EBBXH8xcWVb)1Xd02ALjRzgE6FPzeK9Q8kcWVPqGeNlrNA2whTXAgSgtcSRBqZm80)sZysmCjVCcK4CjAg(5jE(Oz4VI5de55sqinaKo80dIaSqfhfqQuKGu2H0aqAW58XKaTMedxYlNajoxcOqSJDndpeNab5Cryk0SzqNA2m0O2yndwJjb21nOz4NN45JMH)kMpqKNlbH0aqQP8EB7tXrWVbCvNf6wzYAMHN(xAgbzVkVIa8BkeiX5s0PMndg0gRzWAmjWUUbnd)8epF0mCvhsjbPncPbGut5922Id5VeGFd(RJhOT1EOY4LasLcszrnZWt)lndgMmsauNtrNA2mWU2yndwJjb21nOzgE6FPz2Uib)gKQiOv1teKEeEAg(5jE(Oz4QoKscsBesdaPMY7TTfhYFja)g8xhpqBR9qLXlbKkfKYIAgEiobcY5IWuOzZGo1SzynTXAMHN(xAMwv)i8kc0Vj6laz5IRQzWAmjWUUbDQzZalQnwZG1ysGDDdAMHN(xAM0JWdqEiu0m8Zt88rZWvDiLeK2iKgasnL3BBloK)sa(n4VoEG2w7HkJxcivkiLf1m8qCceKZfHPqZMbDQzZq81gRzWAmjWUUbnd)8epF0mMY7TvK)PaW5svWuDW2p0ktgsdaP34DageR0o9UW6fKUcs5)t0)2YUDrka)gSLVq2U8nP)fKgVG0gTnJMz4P)LMz7Iua(nylFH0mEL4DYKtGV1mMY7TTfhYFja)g8xhpqBRvMSo1SzOz0gRzWAmjWUUbnd)8epF0mMY7TLR6aSWlkKvKdxcKUcsxRri1iqA8H04fKo80dIaSqfhfAMHN(xAgbzVkVIa8BkeiX5s0PMndRxTXAgSgtcSRBqZm80)sZSDrc(nivrqRQNii9i80m8Zt88rZWvDivkiDnndpeNab5Cryk0SzqNA2mep0gRzWAmjWUUbnd)8epF0mCv3QmHHuJaPCvhsxrcsnOzgE6FPzWWKrcG6Ck6uZMH1rBSMbRXKa76g0m8Zt88rZWvDRYegsncKYvDiDfjinwi1aKgdKo80dIaSqfhfq6ki1aKgNMz4P)LMHR6at5tK6uZg7nQnwZG1ysGDDdAMHN(xAM0JWdqEiu0m8Zt88rZelK2CinhcSsRQNa(Ry(wSgtcSdPllqk)vmFGipxccPXbPbGuUQBvMWqQrGuUQdPRibPSRz4H4eiiNlctHMnd6uZg7g0gRzWAmjWUUbnZWt)lnJjXWL8YjqIZLOz4NN45JMz4PhebyHkokGuPibPRbPbGuUQdPRibPRbPllqQP8EBBXH8xcWVb)1Xd02ALjRz4H4eiiNlctHMnd6uZg7SRnwZm80)sZWvDq7ee1mynMeyx3Go1SX(AAJ1mEL4DYKtnJbnZWt)lnZMiKxrabEKXkbsCUendwJjb21nOtDQze4HLNH0gRzZG2yndwJjb21nOz4NN45JMXuEVTc8WYZq2dvgVeqQuqQbnZWt)lnZ2fPa8BWw(cPtnBSRnwZG1ysGDDdAg(5jE(Oz4VI5de55sqinaKglKo80dIaSqfhfq6ksq6Aq6YcKo80dIaSqfhfq6ki1aKgasBoKY)NO)TL9CHxraHCbK4CjwzYqACAMHN(xAgbzVkVIa8BkeiX5s0PMT10gRzWAmjWUUbnZWt)lnZ5cVIac5ciX5s0m8Zt88rZWFfZhiYZLGAgEiobcY5IWuOzZGo1SXIAJ1mynMeyx3GMHFEINpAMHNEqeGfQ4OasxrcsxtZm80)sZSDrka)gSLVq6uZw81gRzWAmjWUUbnd)8epF0m8xX8bI8CjiKgasnL3BBFkoc(nGR6Sq3ktwZm80)sZii7v5veGFtHajoxIo1S1mAJ1mynMeyx3GMz4P)LMXKy4sE5eiX5s0m8Zt88rZWFfZhiYZLGqAai1uEVTT4q(lb43G)64zLjdPbGu()e9VTSNl8kciKlGeNlXEOY4LasxbPSRz4H4eiiNlctHMnd6uZ26vBSMXReVtMCc8TMXuEVTc8WYZqwzYb4)t0)2YEUWRiGqUasCUe7HtpKMz4P)LMz7Iua(nylFH0mynMeyx3Go1Sfp0gRzWAmjWUUbnd)8epF0m8xX8bI8CjiKgas7OP8EBn)c7YIeyEylOJMY7TvMSMz4P)LMrq2RYRia)McbsCUeDQzBD0gRzWAmjWUUbnZWt)lnZ2fj43GufbTQEIG0JWtZWppXZhndx1HuPG010m8qCceKZfHPqZMbDQzZqJAJ1mynMeyx3GMz4P)LMXKy4sE5eiX5s0m8Zt88rZWFfZhiYZLGq6YcK2CinhcSsRQNa(Ry(wSgtcSRz4H4eiiNlctHMnd6uZMbdAJ1mdp9V0mcYEvEfb43uiqIZLOzWAmjWUUbDQtndVde4HLNH0gRzZG2yndwJjb21nOzEYAgbMAMHN(xAMGZ5JjbQzcoeYOMH)pr)BlRapS8mK9qLXlbKkfKAasxwGuYyAdlJfivrqRQNii9i8Sdp9GiKgas5)t0)2YkWdlpdzpuz8saPRG01AesxwGuZxiG0aq62JutWHkJxcivkiL9g1mbNduJcQze4HLNHaMYNi1PMn21gRzWAmjWUUbnd)8epF0mnhsdoNpMeOv9j6GWYybPllqQ5leqAaiD7rQj4qLXlbKkfKYE81mdp9V0mEf8LGGWYyPtnBRPnwZG1ysGDDdAg(5jE(OzcoNpMeOvGhwEgcykFIuZm80)sZys8FhSLVq6uZglQnwZG1ysGDDdAg(5jE(OzcoNpMeOvGhwEgcykFIuZm80)sZyINapjEfPtnBXxBSMz4P)LMHWJutbGfk3JuWk1mynMeyx3Go1S1mAJ1mynMeyx3GMHFEINpAMGZ5JjbAf4HLNHaMYNi1mdp9V0mB)qtI)76uZ26vBSMbRXKa76g0m8Zt88rZeCoFmjqRapS8meWu(ePMz4P)LMzkokYBia8HGqNA2IhAJ1mynMeyx3GMHFEINpAMGZ5JjbAf4HLNHaMYNi1mdp9V0mMte43G8CUeHo1SToAJ1mynMeyx3GMHFEINpAMThPMGdvgVeq6kinwi1q8Ori1iq6jx4(Vi0UNCia5lZvTynMeyhsJxqQb2BesJdsxwGuYyAdlJfivrqRQNii9i8Sdp9GiKgasJfsBoKY)GynvAlKFpXFDiDzbsnL3BR5xyxwKaZdBTYKH04G0LfinwiL)pr)BlRxbFjiiSmwGufbTQEIG0JWZEOY4LasxbPBpsnbhQmEjG04G0aqQP8EBn)c7YIeyEyRvMmKUSaPMVqaPbG0ThPMGdvgVeqQuqQHg1mdp9V0m5lZvb)g0Xjv1PMndnQnwZG1ysGDDdAg(5jE(Oz4)t0)2YEUWRiGqUasCUe7HkJxcivkifdJC5ebPRGAMHN(xAMwCi)La8BWFD80PMndg0gRzWAmjWUUbnd)8epF0mbNZhtc0kWdlpdbmLprQzgE6FPz8sWp5CmjqGrrEQuwb0XGoh1PMndSRnwZG1ysGDDdAg(5jE(OzcoNpMeOvGhwEgcykFIuZm80)sZ0EtQkYVqDQzZWAAJ1mynMeyx3GMHFEINpAMGZ5JjbAf4HLNHaMYNi1mdp9V0mret3N8pbWC6rOo1SzGf1gRzWAmjWUUbnZWt)lnJqD6FB0ncYG8turZWppXZhndzmTHLXcKQiOv1teKEeE2HNEqesxwGuZxiG0aq62JutWHkJxcivkiL9gH0LfiT5q6jx4(Vi06vWxcEcqhj8i10I1ysGDntnkOMrOo9Vn6gbzq(jQOtnBgIV2yndwJjb21nOz4NN45JMP5qAW58XKaTHLXc8fqwGG88scMq6YcKY)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8saPRGu2BesxwG0GZ5JjbAvFIoiSmwAMHN(xAgzbc8eve6uZMHMrBSMz4P)LMzpiHxiqKVczndwJjb21nOtnBgwVAJ1mdp9V0m7HGalWFD80mynMeyx3Go1SziEOnwZG1ysGDDdAg(5jE(OzmFHasdaPBpsnbhQmEjGuPGudXhsxwG0yHuUQdPRibPSdPbG0yH0ThPMGdvgVeq6kiTzAesdaPXcPXcP8)j6FBzf4HLNHShQmEjG0vqQHgH0Lfi1uEVTc8WYZqwzYq6YcKY)NO)TLvGhwEgYktgsJdsdaPXcPKX0gwglqQIGwvprq6r4zhE6briDzbs5)t0)2Y6vWxccclJfivrqRQNii9i8ShQmEjG0vqQHgH0Lfin4C(ysGw1NOdclJfKghKghKghKUSaPXcPBpsnbhQmEjGuPibPntJqAainwiLmM2WYybsveSEu9ebPhHND4PheH0LfiL)pr)BlRxbFjiiSmwGufbTQEIG0JWZEOY4LasxbPBpsnbhQmEjG04G04G040mdp9V0mMFHDzrcmpSvNA2mSoAJ1mynMeyx3GMHFEINpAg()e9VTSNl8kciKlGeNlXEOY4LasLcszhsxwGuZxiG0aq62JutWHkJxcivki1q81mdp9V0mc8WYZq6uZg7nQnwZm80)sZyorGFdYZ5seAgSgtcSRBqNA2y3G2yndwJjb21nOz4NN45JMr8YeME1TKLfPmbcWtMC6FzXAmjWoKgasnL3BRapS8mKT)TfKgas7OP8EBn)c7YIeyEylOJMY7TT)TLMz4P)LMztGcv(n7uN6uZisTXA2mOnwZG1ysGDDdAg(5jE(OzUX7amiwPD6DH1liDfKY)NO)TLTv1pcVIa9BI(cqwU4Q2U8nP)fKgVG0gTXdiDzbsVX7amiwPD6DHvMSMz4P)LMPv1pcVIa9BI(cqwU4Q6uZg7AJ1mynMeyx3GMHFEINpAgUQBvMWqQrGuUQdPRibPSdPbGuSWlkKnDfeKpqzcdPRG01G0LfiLR6wLjmKAeiLR6q6ksqklcPbG0yHuSWlkKnDfeKpqzcdPRGu2H0LfiT5qk5ddcI4DRbB6r4bipekqACAMHN(xAgSWlYBw8kcGeEy)0PMT10gRzWAmjWUUbnd)8epF0m8xX8bI8CjiKgasnL3BBFkoc(nGR6Sq3ktgsdaPXcP34DageR0o9UW6fKUcsnL3BBFkoc(nGR6Sq3EOY4LasncKYoKUSaP34DageR0o9UWktgsJtZm80)sZii7v5veGFtHajoxIo1SXIAJ1mynMeyx3GMz4P)LM5CHxraHCbK4CjAg(5jE(Oz4)t0)2YkWdlpdzpuz8saPRGudq6YcK2CinhcSsRapS8mKfRXKa7qAainwiL)pr)BlBloK)sa(n4VoE2dvgVeq6kiLfH0LfiT5qk)dI1uPvsOZNcsJtZWdXjqqoxeMcnBg0PMT4RnwZG1ysGDDdAg(5jE(OzIfsVX7amiwPD6DH1liDfKY)NO)TLD7Iua(nylFHSD5Bs)linEbPnAJhq6YcKEJ3byqSs707cRmzinoinaKglKIfErHSPRGG8bktyiDfKIHrUCIG0vqi1iqQbiDzbs5QUvzcdPgbs5QoKkfji1aKUSaPMY7TvK)PaW5svWuDW2p0EOY4LasLcsXWixorq6kiKgdKAasJdsxwG0ThPMGdvgVeqQuqkgg5YjcsxbH0yGudq6YcK2rt592A(f2LfjW8WwqhnL3BRmznZWt)lnZ2fPa8BWw(cPtnBnJ2yndwJjb21nOz4NN45JMXuEVTPkcqfY49NaWhYd3Z)SIC4sG0vqQH1bsdaPyHxuiB6kiiFGYegsxbPyyKlNiiDfesncKAasdaP8)j6FBzpx4veqixajoxI9qLXlbKUcsXWixorq6kiKUSaPMY7TnvraQqgV)ea(qE4E(NvKdxcKUcsnWIqAainwiL)pr)BlRapS8mK9qLXlbKkfKgFinaKMdbwPvGhwEgYI1ysGDiDzbs5)t0)2Y2Id5VeGFd(RJN9qLXlbKkfKgFinaKY)GynvALe68PG0LfiD7rQj4qLXlbKkfKgFinonZWt)lnd)gUecVIaSWPJacpsnlVI0PMT1R2yndwJjb21nOz4NN45JMXuEVTNSq1RialC6iO1RUT)TfKgashE6brawOIJciDfKAqZm80)sZCYcvVIaSWPJGwV66uZw8qBSMbRXKa76g0mdp9V0mBxKGFdsve0Q6jcspcpnd)8epF0mCvhsLcsxtZWdXjqqoxeMcnBg0PMT1rBSMbRXKa76g0m8Zt88rZWvDRYegsncKYvDiDfji1GMz4P)LMbdtgjaQZPOtnBgAuBSMbRXKa76g0m8Zt88rZWvDRYegsncKYvDiDfji1aKgashE6brawOIJciLeKAasdaP34DageR0o9UW6fKUcszVriDzbs5QUvzcdPgbs5QoKUIeKYoKgashE6brawOIJciDfjiLDnZWt)lndx1bMYNi1PMndg0gRzgE6FPz4QoODcIAgSgtcSRBqNA2mWU2yndwJjb21nOzgE6FPzspcpa5HqrZWppXZhnd)vmFGipxccPbGuUQBvMWqQrGuUQdPRibPSdPbGut592kY)ua4CPkyQoy7hA7FBPz4H4eiiNlctHMnd6uZMH10gRzWAmjWUUbnd)8epF0mMY7TLR6aSWlkKvKdxcKUcsxRri1iqA8H04fKo80dIaSqfhfqAai1uEVTI8pfaoxQcMQd2(H2(3wqAainwiL)pr)Bl75cVIac5ciX5sShQmEjG0vqk7qAaiL)pr)Bl72fPa8BWw(czpuz8saPRGu2H0LfiL)pr)Bl75cVIac5ciX5sShQmEjGuPG01G0aqk)FI(3w2Tlsb43GT8fYEOY4LasxbPRbPbGuUQdPRG01G0LfiL)pr)Bl75cVIac5ciX5sShQmEjG0vq6AqAaiL)pr)Bl72fPa8BWw(czpuz8saPsbPRbPbGuUQdPRGuwesxwGuUQBvMWqQrGuUQdPsrcsnaPbGuSWlkKnDfeKpqzcdPsbPSdPXbPllqQP8EB5Qoal8Iczf5WLaPRGudncPbG0ThPMGdvgVeqQuq66vZm80)sZii7v5veGFtHajoxIo1SzGf1gRzWAmjWUUbnZWt)lnJjXWL8YjqIZLOz4NN45JMH)kMpqKNlbH0aqASqAoeyLwbEy5zilwJjb2H0aqk)FI(3wwbEy5zi7HkJxcivkiDniDzbs5)t0)2YEUWRiGqUasCUe7HkJxciDfKAasdaP8)j6FBz3UifGFd2Yxi7HkJxciDfKAasxwGu()e9VTSNl8kciKlGeNlXEOY4LasLcsxdsdaP8)j6FBz3UifGFd2Yxi7HkJxciDfKUgKgas5QoKUcszhsxwGu()e9VTSNl8kciKlGeNlXEOY4LasxbPRbPbGu()e9VTSBxKcWVbB5lK9qLXlbKkfKUgKgas5QoKUcsxdsxwGuUQdPRG04dPllqQP8EBnFjaY3ZTYKH040m8qCceKZfHPqZMbDQzZq81gRzWAmjWUUbnZWt)lnt6r4bipekAg(5jE(Oz4VI5de55sqinaKYvDRYegsncKYvDiDfjiLDndpeNab5Cryk0SzqNA2m0mAJ1mynMeyx3GMHFEINpAgUQBvMWqQrGuUQdPRibPg0mdp9V0mZXNcb5FhwPo1Szy9QnwZ4vI3jto1mg0mdp9V0mBIqEfbe4rgReiX5s0mynMeyx3Go1SziEOnwZG1ysGDDdAMHN(xAgtIHl5LtGeNlrZWppXZhnd)vmFGipxccPbGu()e9VTSBxKcWVbB5lK9qLXlbKkfKUgKgas5QoKscszhsdaPKpmiiI3TgSPhHhG8qOaPbGuSWlkKnDfeKpi(ncPsbPg0m8qCceKZfHPqZMbDQzZW6OnwZG1ysGDDdAMHN(xAgtIHl5LtGeNlrZWppXZhnd)vmFGipxccPbGuSWlkKnDfeKpqzcdPsbPSdPbG0yHuUQBvMWqQrGuUQdPsrcsnaPllqk5ddcI4DRbB6r4bipekqACAgEiobcY5IWuOzZGo1PMH3bcCRnwZMbTXAgSgtcSRBqZWppXZhntZH0GZ5JjbAvFIoiSmwqAainwiL)pr)Bl75cVIac5ciX5sShQmEjGuPGu2H0LfiT5qk)dI1uPvsOZNcsJdsdaPXcPnhs5FqSMkTfYVN4VoKUSaP8)j6FBzn)c7YIeyEyR9qLXlbKkfKYoKghKUSaPBpsnbhQmEjGuPGu2JVMz4P)LMXRGVeeewglDQzJDTXAgSgtcSRBqZWppXZhnZ2JutWHkJxciDfKglKAiE0iKAei9KlC)xeA3toeG8L5QwSgtcSdPXli1a7ncPXbPllqQP8EBf5FkaCUufmvhS9dT9VTG0aqkzmTHLXcKQiOv1teKEeE2HNEqesdaPXcPnhs5FqSMkTfYVN4VoKUSaPMY7T18lSllsG5HTwzYqACq6YcKglKY)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8saPRG0ThPMGdvgVeqACqAai1uEVTMFHDzrcmpS1ktgsxwGuZxiG0aq62JutWHkJxcivki1qJAMHN(xAM8L5QGFd64KQ6uZ2AAJ1mynMeyx3GMHFEINpAMyH0B8oadIvANExy9csxbPSy8H0Lfi9gVdWGyL2P3fwzYqACqAaiL)pr)Bl75cVIac5ciX5sShQmEjGuPGummYLteKUccPbGu()e9VTSEf8LGGWYybsve0Q6jcspcp7HkJxciDfKglKYEJqAmqk7ncPXli9KlC)xeA9k4lbpbOJeEKAAXAmjWoKghKUSaPMVqaPbG0ThPMGdvgVeqQuq6AXxZm80)sZ0Id5VeGFd(RJNo1SXIAJ1mynMeyx3GMHFEINpAg(Ry(arEUeesdaPXcP34DageR0o9UW6fKUcsn0iKUSaP34DageR0o9UWktgsJtZm80)sZShKWleiYxHSo1SfFTXAgSgtcSRBqZWppXZhnZnEhGbXkTtVlSEbPRG01AesxwG0B8oadIvANExyLjRzgE6FPz2dbbwG)64PtnBnJ2yndwJjb21nOz4NN45JMHR6q6ksqk7qAaiD7rQj4qLXlbKUcsBMgH0aqASqk)FI(3wwr(NcaNlvbt1bB)qlxDUiuaPRG0gH0LfiL)pr)BlRi)tbGZLQGP6GTFO9qLXlbKUcsn0iKghKgasJfsjJPnSmwGufbTQEIG0JWZo80dIq6YcKY)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8saPRGudncPllqAW58XKaTQprhewglinoiDzbsJfs5QoKUIeKYoKgas3EKAcouz8saPsrcsBMgH0aqASqkzmTHLXcKQiy9O6jcspcp7WtpicPllqk)FI(3wwVc(sqqyzSaPkcAv9ebPhHN9qLXlbKUcs3EKAcouz8saPXbPbG0yHu()e9VTSI8pfaoxQcMQd2(HwU6CrOasxbPncPllqk)FI(3wwr(NcaNlvbt1bB)q7HkJxciDfKU9i1eCOY4LasxwGut592kY)ua4CPkyQoy7hALjdPXbPXbPllq62JutWHkJxcivki1q81mdp9V0mMFHDzrcmpSvNA2wVAJ1mynMeyx3GMHFEINpAg(xDzpT8)VUxtIDWV3yj8GOfRXKa7AMHN(xAgr(NcaNlvbt1bB)qW2dpjQtnBXdTXAgSgtcSRBqZWppXZhnd)FI(3wwr(NcaNlvbt1bB)qlxDUiuaPKGu2H0LfiD7rQj4qLXlbKkfKYEJq6YcKglKEJ3byqSs707c7HkJxciDfKAi(q6YcKglK2CiL)bXAQ0kj05tbPbG0MdP8piwtL2c53t8xhsJdsdaPXcPXcP34DageR0o9UW6fKUcs5)t0)2YkY)ua4CPkyQoy7hA3YeeGd5QZfHG0vqiDzbsBoKEJ3byqSs707clg2fPasJdsdaPXcP8)j6FBz9k4lbbHLXcKQiOv1teKEeE2dvgVeq6kiL)pr)BlRi)tbGZLQGP6GTFODltqaoKRoxecsxbH0Lfin4C(ysGw1NOdclJfKghKghKgas5)t0)2YUDrka)gSLVq2dvgVeqQuKG01bsdaPCvhsxrcszhsdaP8)j6FBzBv9JWRiq)MOVaKLlUQ9qLXlbKkfji1a7qACAMHN(xAgr(NcaNlvbt1bB)qDQzBD0gRzWAmjWUUbnd)8epF0m8piwtLwjHoFkinaKglKAkV32wCi)La8BWFD8SYKH0LfinwiD7rQj4qLXlbKkfKY)NO)TLTfhYFja)g8xhp7HkJxciDzbs5)t0)2Y2Id5VeGFd(RJN9qLXlbKUcs5)t0)2YkY)ua4CPkyQoy7hA3YeeGd5QZfHG0vqinoinaKY)NO)TLD7Iua(nylFHShQmEjGuPibPRdKgas5QoKUIeKYoKgas5)t0)2Y2Q6hHxrG(nrFbilxCv7HkJxcivksqQb2H040mdp9V0mI8pfaoxQcMQd2(H6uZMHg1gRzWAmjWUUbnd)8epF0m8piwtL2c53t8xhsdaPD0uEVTMFHDzrcmpSf0rt592ktgsdaPXcPKX0gwglqQIGwvprq6r4zhE6briDzbsdoNpMeOv9j6GWYybPllqk)FI(3wwVc(sqqyzSaPkcAv9ebPhHN9qLXlbKUcs5)t0)2YkY)ua4CPkyQoy7hA3YeeGd5QZfHG0vqiDzbs5)t0)2Y6vWxccclJfivrqRQNii9i8ShQmEjG0vq6AncPXPzgE6FPze5FkaCUufmvhS9d1PMndg0gRzWAmjWUUbnd)8epF0mKX0gwglqQIGwvprq6r4zhE6briDzbsnFHasdaPBpsnbhQmEjGuPGu2BuZm80)sZ4LGFY5ysGaJI8uPScOJbDoQtnBgyxBSMbRXKa76g0m8Zt88rZqgtByzSaPkcAv9ebPhHND4PheH0Lfi18fcinaKU9i1eCOY4LasLcszVrnZWt)lnt7nPQi)c1PMndRPnwZG1ysGDDdAg(5jE(OziJPnSmwGufbTQEIG0JWZo80dIq6YcKA(cbKgas3EKAcouz8saPsbPS3OMz4P)LMjIy6(K)jaMtpc1PMndSO2yndwJjb21nOzgE6FPz6ho9TFiiikeiHMHFEINpAMMdPbNZhtc0gwglWxazbcYZljycPllqk)FI(3wwVc(sqqyzSaPkcAv9ebPhHN9qLXlbKUcszVrinaKsgtByzSaPkcAv9ebPhHN9qLXlbKkfKYEJq6YcKgCoFmjqR6t0bHLXsZuJcQz6ho9TFiiikeiHo1Szi(AJ1mynMeyx3GMz4P)LMrOo9Vn6gbzq(jQOz4NN45JMHmM2WYybsve0Q6jcspcp7WtpicPllqQ5leqAaiD7rQj4qLXlbKkfKYEJq6YcK2Ci9KlC)xeA9k4lbpbOJeEKAAXAmjWUMPgfuZiuN(3gDJGmi)ev0PMndnJ2yndwJjb21nOz4NN45JMP5qAW58XKaTHLXc8fqwGG88scMq6YcKY)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8saPRGu2BesxwG0GZ5JjbAvFIoiSmwAMHN(xAgzbc8eve6uZMH1R2yndwJjb21nOz4NN45JMz7rQj4qLXlbKUcsxNgH0LfiLmM2WYybsve0Q6jcspcp7WtpicPllqAW58XKaTQprhewgliDzbsnFHasdaPBpsnbhQmEjGuPGudnJMz4P)LMjFzUk43ajZPm6uZMH4H2yndwJjb21nOz4NN45JMH)pr)BlRxbFjiiSmwGufbTQEIG0JWZEOY4LasxbPR1iKUSaPbNZhtc0Q(eDqyzSG0Lfi18fcinaKU9i1eCOY4LasLcszVrnZWt)lnJjX)DWw(cPtnBgwhTXAgSgtcSRBqZWppXZhnd)FI(3wwVc(sqqyzSaPkcAv9ebPhHN9qLXlbKUcsxRriDzbsdoNpMeOv9j6GWYybPllqQ5leqAaiD7rQj4qLXlbKkfKAi(AMHN(xAgt8e4jXRiDQzJ9g1gRzgE6FPzi8i1uayHY9ifSsndwJjb21nOtnBSBqBSMbRXKa76g0m8Zt88rZW)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8saPRG01AesxwG0GZ5JjbAvFIoiSmwq6YcKA(cbKgas3EKAcouz8saPsbPgAuZm80)sZS9dnj(VRtnBSZU2yndwJjb21nOz4NN45JMH)pr)BlRxbFjiiSmwGufbTQEIG0JWZEOY4LasxbPR1iKUSaPbNZhtc0Q(eDqyzSG0Lfi18fcinaKU9i1eCOY4LasLcszVrnZWt)lnZuCuK3qa4dbHo1SX(AAJ1mynMeyx3GMHFEINpAgt592kY)ua4CPkyQoy7hA7FBPzgE6FPzmNiWVb55CjcDQzJDwuBSMbRXKa76g0m8Zt88rZiEzctV6wYYIuMab4jto9VSynMeyhsdaPMY7TvK)PaW5svWuDW2p02)2csdaPD0uEVTMFHDzrcmpSf0rt5922)2sZm80)sZSjqHk)MDQtDQz64EKjsTXA2mOnwZm80)sZiiJZbuNQde55sqndwJjb21nOtnBSRnwZG1ysGDDdAMNSMrGPMz4P)LMj4C(ysGAMGdHmQz4)t0)2Y6vWxccclJfivrqRQNii9i8ShQmEjG0vq62JutWHkJxciDzbs3EKAcouz8saPgbs5)t0)2Y6vWxccclJfivrqRQNii9i8ShQmEjGuPGudS3iKgasJfsJfsZHaR0kWdlpdzXAmjWoKgas3EKAcouz8saPRGu()e9VTSc8WYZq2dvgVeqAaiL)pr)BlRapS8mK9qLXlbKUcsn0iKghKUSaPXcP8)j6FBzf5FkaCUufmvhS9dTBzccWHC15Iqq6kiKkfKU9i1eCOY4LasdaP8)j6FBzf5FkaCUufmvhS9dTBzccWHC15Iqq6kiKUcsneFinoiDzbsJfs5)t0)2YkY)ua4CPkyQoy7hA5QZfHciLeK2iKgas5)t0)2YkY)ua4CPkyQoy7hApuz8saPsbPBpsnbhQmEjG04G040mbNduJcQzuFIoiSmw6uZ2AAJ1mynMeyx3GMHFEINpAMyHut592kWdlpdzLjdPllqQP8EBf5FkaCUufmvhS9dTYKH04G0aqkzmTHLXcKQiOv1teKEeE2HNEqesxwGuZxiG0aq62JutWHkJxcivksqAZ0OMz4P)LMH8N(x6uZglQnwZG1ysGDDdAg(5jE(OzmL3BRapS8mKvMSMrKNZtnBg0mdp9V0m8HGam80)cq4IuZq4IeuJcQze4HLNH0PMT4RnwZG1ysGDDdAg(5jE(OzmL3BBloK)sa(n4VoEwzYAgrEop1SzqZm80)sZWhccWWt)laHlsndHlsqnkOMPfhYFja)g8xhpDQzRz0gRzWAmjWUUbnd)8epF0mPRGqQuqklcPbGuUQdPsbPXhsdaPnhsjJPnSmwGufbTQEIG0JWZo80dIAgrEop1SzqZm80)sZWhccWWt)laHlsndHlsqnkOM5jJfE6uZ26vBSMbRXKa76g0mdp9V0mBxKGFdsve0Q6jcspcpnd)8epF0mCv3QmHHuJaPCvhsxrcsxdsdaPXcPyHxuiB6kiiFGYegsLcsnaPllqkw4ffYMUccYhOmHHuPGuwesdaP8)j6FBz3UifGFd2Yxi7HkJxcivki1Gn(q6YcKY)NO)TLTfhYFja)g8xhp7HkJxcivkiLDinoinaK2CiTJMY7T18lSllsG5HTGoAkV3wzYAgEiobcY5IWuOzZGo1Sfp0gRzWAmjWUUbnd)8epF0mCv3QmHHuJaPCvhsxrcsnaPbG0yHuSWlkKnDfeKpqzcdPsbPgG0LfiL)pr)BlRapS8mK9qLXlbKkfKYoKUSaPyHxuiB6kiiFGYegsLcszrinaKY)NO)TLD7Iua(nylFHShQmEjGuPGud24dPllqk)FI(3w2wCi)La8BWFD8ShQmEjGuPGu2H04G0aqAZHut592A(f2LfjW8WwRmznZWt)lndgMmsauNtrNA2whTXAgSgtcSRBqZm80)sZKEeEaYdHIMHFEINpAg(Ry(arEUeesdaPCv3QmHHuJaPCvhsxrcszhsdaPXcPyHxuiB6kiiFGYegsLcsnaPllqk)FI(3wwbEy5zi7HkJxcivkiLDiDzbsXcVOq20vqq(aLjmKkfKYIqAaiL)pr)Bl72fPa8BWw(czpuz8saPsbPgSXhsxwGu()e9VTST4q(lb43G)64zpuz8saPsbPSdPXbPbG0MdPD0uEVTMFHDzrcmpSf0rt592ktwZWdXjqqoxeMcnBg0PMndnQnwZG1ysGDDdAg(5jE(OzAoKMdbwPvGhwEgYI1ysGDnJipNNA2mOzgE6FPz4dbby4P)fGWfPMHWfjOgfuZW7abU1PMndg0gRzWAmjWUUbnd)8epF0m5qGvAf4HLNHSynMeyxZiYZ5PMndAMHN(xAg(qqagE6FbiCrQziCrcQrb1m8oqGhwEgsNA2mWU2yndwJjb21nOz4NN45JMz4PhebyHkokGuPG010mI8CEQzZGMz4P)LMHpeeGHN(xacxKAgcxKGAuqnJi1PMndRPnwZG1ysGDDdAg(5jE(OzgE6brawOIJciDfjiDnnJipNNA2mOzgE6FPz4dbby4P)fGWfPMHWfjOgfuZmpQtDQziFi)vmNuBSMndAJ1mdp9V0mMFMeyhSjMqyV1Riq(H9sZG1ysGDDd6uZg7AJ1mynMeyx3GM5jRzeyQzgE6FPzcoNpMeOMj4qiJAg0Oi7KjJDRxc(jNJjbcmkYtLYkGog05iKUSaPOrr2jtg72iIP7t(Nayo9iesxwGu0Oi7KjJDB7nPQi)cH0LfifnkYozYy3(bXJRoxe2bt5kdWCYeVqq6YcKIgfzNmzSBfQt)BJUrqgKFIkAMGZbQrb1mHLXc8fqwGG88scM6uZ2AAJ1mdp9V0mBcuOYVzNAgSgtcSRBqNA2yrTXAgSgtcSRBqZWppXZhntZH0CiWkTc8WYZqwSgtcSdPllqAZH0CiWkTBxKGFdsve0Q6jcspcplwJjb21mdp9V0mCvhykFIuNA2IV2yndwJjb21nOz4NN45JMP5qAoeyLwSWlYBw8kcGeEy8SynMeyxZm80)sZWvDq7ee1Po1mZJAJ1SzqBSMz4P)LMPv1pcVIa9BI(cqwU4QAgSgtcSRBqNA2yxBSMbRXKa76g0m8Zt88rZWvDRYegsncKYvDiDfjiLDinaKIfErHSPRGG8bktyiDfKYoKUSaPCv3QmHHuJaPCvhsxrcszrnZWt)lndw4f5nlEfbqcpSF6uZ2AAJ1mynMeyx3GMHFEINpAg(Ry(arEUeesdaPXcPMY7TTpfhb)gWvDwOBLjdPllqAhnL3BR5xyxwKaZdBbD0uEVTYKH040mdp9V0mcYEvEfb43uiqIZLOtnBSO2yndwJjb21nOz4NN45JMbl8Icztxbb5duMWq6kifdJC5ebPRGq6YcKYvDRYegsncKYvDivksqQbnZWt)lnZ2fPa8BWw(cPtnBXxBSMbRXKa76g0mdp9V0mNl8kciKlGeNlrZWppXZhntSqAoeyL2wv)i8kc0Vj6laz5IRAXAmjWoKgas5)t0)2YEUWRiGqUasCUeBx(M0)csxbP8)j6FBzBv9JWRiq)MOVaKLlUQ9qLXlbKgdKYIqACqAainwiL)pr)Bl72fPa8BWw(czpuz8saPRG01G0LfiLR6q6ksqA8H040m8qCceKZfHPqZMbDQzRz0gRzWAmjWUUbnd)8epF0mMY7T9KfQEfbyHthbTE1T9VT0mdp9V0mNSq1RialC6iO1RUo1STE1gRzWAmjWUUbnd)8epF0mCv3QmHHuJaPCvhsxrcsnOzgE6FPzWWKrcG6Ck6uZw8qBSMbRXKa76g0mdp9V0mBxKGFdsve0Q6jcspcpnd)8epF0mCv3QmHHuJaPCvhsxrcsxtZWdXjqqoxeMcnBg0PMT1rBSMbRXKa76g0m8Zt88rZWvDRYegsncKYvDiDfjiLDnZWt)lndx1bMYNi1PMndnQnwZG1ysGDDdAg(5jE(OzmL3BBQIauHmE)ja8H8W98pRihUeiDfKAyDG0aqkw4ffYMUccYhOmHH0vqkgg5YjcsxbHuJaPgG0aqk)FI(3w2Tlsb43GT8fYEOY4LasxbPyyKlNiiDfuZm80)sZWVHlHWRialC6iGWJuZYRiDQzZGbTXAgSgtcSRBqZm80)sZKEeEaYdHIMHFEINpAgUQBvMWqQrGuUQdPRibPSdPbG0yH0MdP5qGvAv9eWFfZ3I1ysGDiDzbs5VI5de55sqinondpeNab5Cryk0SzqNA2mWU2yndwJjb21nOz4NN45JMHR6wLjmKAeiLR6q6ksqQbnZWt)lnZC8Pqq(3HvQtnBgwtBSMbRXKa76g0m8Zt88rZWFfZhiYZLGqAainwiL)pr)BlR5xyxwKaZdBThQmEjG0vqk7q6YcK2CiL)bXAQ0wi)EI)6qACqAainwiLR6q6ksqA8H0LfiL)pr)Bl72fPa8BWw(czpuz8saPRG0MbsxwGu()e9VTSBxKcWVbB5lK9qLXlbKUcsxdsdaPCvhsxrcsxdsdaPyHxuiB6kiiFq8BesLcsnaPllqkw4ffYMUccYhOmHHuPibPXcPRbPXaPRbPXliL)pr)Bl72fPa8BWw(czpuz8saPsbPXhsJdsxwGut592kY)ua4CPkyQoy7hALjdPXPzgE6FPzeK9Q8kcWVPqGeNlrNA2mWIAJ1mynMeyx3GMHFEINpAg(Ry(arEUeuZm80)sZWvDq7ee1PMndXxBSMbRXKa76g0mdp9V0mBIqEfbe4rgReiX5s0m8Zt88rZykV3wZxcG89CB)BlnJxjENm5uZyqNA2m0mAJ1mynMeyx3GMz4P)LMXKy4sE5eiX5s0m8Zt88rZWFfZhiYZLGqAainwi1uEVTMVea575wzYq6YcKMdbwPv1ta)vmFlwJjb2H0aqk5ddcI4DRbB6r4bipekqAaiLR6qkjiLDinaKY)NO)TLD7Iua(nylFHShQmEjGuPG01G0LfiLR6wLjmKAeiLR6qQuKGudqAaiL8Hbbr8U1Gvq2RYRia)McbsCUeinaKIfErHSPRGG8bktyivkiDninondpeNab5Cryk0SzqN6uNAMG4j8V0SXEJSBOX4b7RJMPDUYRiHMz9yu3SYw8eBnBRlKcPgRIqQRq(Ves3)bPSSfhYFja)g8xhpwcPhAuK9d7qQ4vqiDKZxzsSdPC1PIqHfYklWleszFDH01)RG4LyhszzoeyLwJMLqA(qklZHaR0A0wSgtcSZsiDsinEUzNfaPXAiCCwiRSaVqiDT1fsx)VcIxIDiLL5qGvAnAwcP5dPSmhcSsRrBXAmjWolH0jH045MDwaKgRHWXzHSYc8cHu2BCDH01)RG4LyhszzoeyLwJMLqA(qklZHaR0A0wSgtcSZsinwdHJZczfY66XOUzLT4j2A2wxifsnwfHuxH8FjKU)dszPapS8melH0dnkY(HDiv8kiKoY5Rmj2HuU6urOWczLf4fcPgACDH01)RG4LyhszzoeyLwJMLqA(qklZHaR0A0wSgtcSZsiDsinEUzNfaPXAiCCwiRqwxpg1nRSfpXwZ26cPqQXQiK6kK)lH09Fqkl5DGapS8melH0dnkY(HDiv8kiKoY5Rmj2HuU6urOWczLf4fcPRZ6cPR)xbXlXoKYYtUW9FrO1OzjKMpKYYtUW9FrO1OTynMeyNLqASgchNfYklWlesnWIRlKU(FfeVe7qklp5c3)fHwJMLqA(qklp5c3)fHwJ2I1ysGDwcPtcPXZn7SainwdHJZczLf4fcPSByDH01)RG4LyhszP4Ljm9QBnAwcP5dPSu8YeME1TgTfRXKa7SesJ1q44SqwHSUEmQBwzlEITMT1fsHuJvri1vi)xcP7)GuwkswcPhAuK9d7qQ4vqiDKZxzsSdPC1PIqHfYklWleszX1fsx)VcIxIDiLL5qGvAnAwcP5dPSmhcSsRrBXAmjWolH0yneoolKvwGxiK2mRlKU(FfeVe7qklZHaR0A0SesZhszzoeyLwJ2I1ysGDwcPXAiCCwiRSaVqi1alUUq66)vq8sSdPSmhcSsRrZsinFiLL5qGvAnAlwJjb2zjKgRHWXzHSczD9yu3SYw8eBnBRlKcPgRIqQRq(Ves3)bPSK3bcCZsi9qJISFyhsfVccPJC(ktIDiLRovekSqwzbEHqk7RlKU(FfeVe7qklp5c3)fHwJMLqA(qklp5c3)fHwJ2I1ysGDwcPXAiCCwiRSaVqiDT1fsx)VcIxIDiLLNCH7)IqRrZsinFiLLNCH7)IqRrBXAmjWolH0yneoolKvwGxiKAi(RlKU(FfeVe7qklp5c3)fHwJMLqA(qklp5c3)fHwJ2I1ysGDwcPtcPXZn7SainwdHJZczLf4fcPSZIRlKU(FfeVe7qklfVmHPxDRrZsinFiLLIxMW0RU1OTynMeyNLqASgchNfYkK11JrDZkBXtS1STUqkKASkcPUc5)siD)hKYYoUhzIKLq6Hgfz)WoKkEfesh58vMe7qkxDQiuyHSYc8cHu2xxiD9)kiEj2HuwMdbwP1OzjKMpKYYCiWkTgTfRXKa7SesJ1q44SqwzbEHqQHgxxiD9)kiEj2HuwMdbwP1OzjKMpKYYCiWkTgTfRXKa7SesNesJNB2zbqASgchNfYklWlesnyyDH01)RG4LyhszzoeyLwJMLqA(qklZHaR0A0wSgtcSZsiDsinEUzNfaPXAiCCwiRqwxpg1nRSfpXwZ26cPqQXQiK6kK)lH09FqklNhzjKEOrr2pSdPIxbH0roFLjXoKYvNkcfwiRSaVqin(RlKU(FfeVe7qklZHaR0A0SesZhszzoeyLwJ2I1ysGDwcPXAiCCwiRSaVqi1GH1fsx)VcIxIDiLL5qGvAnAwcP5dPSmhcSsRrBXAmjWolH0yneoolKvwGxiKAOzwxiD9)kiEj2HuwMdbwP1OzjKMpKYYCiWkTgTfRXKa7SesJ1q44SqwHSgpPq(Ve7q66aPdp9VGucxKclKvnd573obQzI3XBiD94vVDiKGhKAu9xsGSgVJ3qkBFquXepi1WAsdPS3i7gGScznEhVH01xDUiuSUqwJ3XBi1iqQXT4ibsnQWfPas)nKAuH8fcs9kX7KjNqkXh5ClK14D8gsncKAClosGugYEvEfbPR)nfcPgv6CjqkXh5ClK14D8gsncKAu37qQ5leBpsnHuUkYLiG08HuLPcbPRVrvqkw55OWczfYA8oEdPXZHrUCIDi1e3)Hqk)vmNesnXiVewi1OMZrYPasRVmI6CkBzciD4P)Las)IiKfY6Wt)lHL8H8xXCYyi1K5Njb2bBIje2B9kcKFyVGSo80)syjFi)vmNmgsnfCoFmjqPRrbjfwglWxazbcYZljyk9tMKatPdoeYij0Oi7KjJDRxc(jNJjbcmkYtLYkGog054YcAuKDYKXUnIy6(K)jaMtpcxwqJIStMm2TT3KQI8lCzbnkYozYy3(bXJRoxe2bt5kdWCYeVqllOrr2jtg7wH60)2OBeKb5NOcK1HN(xcl5d5VI5KXqQPnbku53StiRdp9VewYhYFfZjJHutCvhykFIuAFtQ55qGvAf4HLNHSynMeyFzP55qGvA3Uib)gKQiOv1teKEeEwSgtcSdzD4P)LWs(q(RyozmKAIR6G2jikTVj18CiWkTyHxK3S4veaj8W4zXAmjWoKviRX74nKgphg5Yj2HumiEHG00vqinvriD45FqQlG0j44eJjbAHSo80)sqsqgNdOovhiYZLGqwhE6FjIHutbNZhtcu6AuqsQprhewglPFYKeykDWHqgjX)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8sSA7rQj4qLXlXYY2JutWHkJxcJW)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8siLb2BmqSXMdbwPvGhwEgkW2JutWHkJxIv8)j6FBzf4HLNHShQmEjcW)NO)TLvGhwEgYEOY4LyLHgJBzjw()e9VTSI8pfaoxQcMQd2(H2Tmbb4qU6CriiDfuQThPMGdvgVeb4)t0)2YkY)ua4CPkyQoy7hA3YeeGd5QZfHG0vWvgIFCllXY)NO)TLvK)PaW5svWuDW2p0YvNlcfKAma)FI(3wwr(NcaNlvbt1bB)q7HkJxcP2EKAcouz8sexCqwhE6FjIHutK)0)sAFtkwt592kWdlpdzLjVSykV3wr(NcaNlvbt1bB)qRm54cqgtByzSaPkcAv9ebPhHND4PhexwmFHiW2JutWHkJxcPi1mnczD4P)LigsnXhccWWt)laHlsPRrbjjWdlpdjTipNNKmiTVjzkV3wbEy5ziRmziRdp9VeXqQj(qqagE6FbiCrkDnkiPwCi)La8BWFD8KwKNZtsgK23KmL3BBloK)sa(n4VoEwzYqwhE6FjIHut8HGam80)cq4Iu6AuqspzSWtArEopjzqAFtkDfukwmax1Lk(bAozmTHLXcKQiOv1teKEeE2HNEqeY6Wt)lrmKAA7Ie8BqQIGwvprq6r4jnpeNab5CrykizqAFtIR6wLjSr4Q(ksRfiwSWlkKnDfeKpqzclLHLfSWlkKnDfeKpqzclflgG)pr)Bl72fPa8BWw(czpuz8siLbB8xw4)t0)2Y2Id5VeGFd(RJN9qLXlHuShxGM3rt592A(f2LfjW8WwqhnL3BRmziRdp9VeXqQjmmzKaOoNI0(Mex1TktyJWv9vKmeiwSWlkKnDfeKpqzclLHLf()e9VTSc8WYZq2dvgVesX(Ycw4ffYMUccYhOmHLIfdW)NO)TLD7Iua(nylFHShQmEjKYGn(ll8)j6FBzBXH8xcWVb)1XZEOY4Lqk2JlqZnL3BR5xyxwKaZdBTYKHSo80)sedPMspcpa5HqrAEiobcY5IWuqYG0(Me)vmFGipxcgGR6wLjSr4Q(ksShiwSWlkKnDfeKpqzclLHLf()e9VTSc8WYZq2dvgVesX(Ycw4ffYMUccYhOmHLIfdW)NO)TLD7Iua(nylFHShQmEjKYGn(ll8)j6FBzBXH8xcWVb)1XZEOY4Lqk2JlqZ7OP8EBn)c7YIeyEylOJMY7TvMmK1HN(xIyi1eFiiadp9VaeUiLUgfKeVde4wArEopjzqAFtQ55qGvAf4HLNHGSo80)sedPM4dbby4P)fGWfP01OGK4DGapS8mK0I8CEsYG0(MuoeyLwbEy5ziiRdp9VeXqQj(qqagE6FbiCrkDnkijrkTipNNKmiTVjn80dIaSqfhfsTgK1HN(xIyi1eFiiadp9VaeUiLUgfK08O0I8CEsYG0(M0WtpicWcvCuSI0AqwHSo80)syNhj1Q6hHxrG(nrFbilxCviRdp9Ve25Xyi1ew4f5nlEfbqcpSFs7BsCv3QmHncx1xrI9ayHxuiB6kiiFGYeEf7llCv3QmHncx1xrIfHSo80)syNhJHutcYEvEfb43uiqIZLiTVjXFfZhiYZLGbI1uEVT9P4i43aUQZcDRm5LLoAkV3wZVWUSibMh2c6OP8EBLjhhK1HN(xc78ymKAA7Iua(nylFHK23KWcVOq20vqq(aLj8kmmYLteKUcUSWvDRYe2iCvxksgGSo80)syNhJHutNl8kciKlGeNlrAEiobcY5IWuqYG0(MuS5qGvABv9JWRiq)MOVaKLlUAa()e9VTSNl8kciKlGeNlX2LVj9VwX)NO)TLTv1pcVIa9BI(cqwU4Q2dvgVeXWIXfiw()e9VTSBxKcWVbB5lK9qLXlXQ1ww4Q(ksXpoiRdp9Ve25Xyi10jlu9kcWcNocA9QlTVjzkV32twO6veGfoDe06v32)2cY6Wt)lHDEmgsnHHjJea15uK23K4QUvzcBeUQVIKbiRdp9Ve25Xyi102fj43GufbTQEIG0JWtAEiobcY5IWuqYG0(Mex1TktyJWv9vKwdY6Wt)lHDEmgsnXvDGP8jsP9njUQBvMWgHR6RiXoK1HN(xc78ymKAIFdxcHxraw40raHhPMLxrs7BsMY7TnvraQqgV)ea(qE4E(NvKdxYkdRtaSWlkKnDfeKpqzcVcdJC5ebPRGgXqa()e9VTSBxKcWVbB5lK9qLXlXkmmYLteKUcczD4P)LWopgdPMspcpa5HqrAEiobcY5IWuqYG0(Mex1TktyJWv9vKypqSnphcSsRQNa(Ry(ll8xX8bI8CjyCqwhE6FjSZJXqQP54tHG8VdRuAFtIR6wLjSr4Q(ksgGSo80)syNhJHutcYEvEfb43uiqIZLiTVjXFfZhiYZLGbIL)pr)BlR5xyxwKaZdBThQmEjwX(YsZ5FqSMkTfYVN4VECbILR6Rif)Lf()e9VTSBxKcWVbB5lK9qLXlXQMzzH)pr)Bl72fPa8BWw(czpuz8sSATaCvFfP1cGfErHSPRGG8bXVrPmSSGfErHSPRGG8bktyPif7AXSw8I)pr)Bl72fPa8BWw(czpuz8siv8JBzXuEVTI8pfaoxQcMQd2(HwzYXbzD4P)LWopgdPM4QoODcIs7Bs8xX8bI8CjiK1HN(xc78ymKAAteYRiGapYyLajoxI0(MKP8EBnFjaY3ZT9VTK2ReVtMCsYaK1HN(xc78ymKAYKy4sE5eiX5sKMhItGGCUimfKmiTVjXFfZhiYZLGbI1uEVTMVea575wzYll5qGvAv9eWFfZpa5ddcI4DRbB6r4bipekb4Qoj2dW)NO)TLD7Iua(nylFHShQmEjKATLfUQBvMWgHR6srYqaYhgeeX7wdwbzVkVIa8BkeiX5scGfErHSPRGG8bktyPwloiRqwhE6FjS8oqGBsEf8LGGWYybsve0Q6jcspcpP9nPMhCoFmjqR6t0bHLXkqS8)j6FBzpx4veqixajoxI9qLXlHuSVS0C(heRPsRKqNpvCbIT58piwtL2c53t8xFzH)pr)BlR5xyxwKaZdBThQmEjKI94ww2EKAcouz8sif7XhY6Wt)lHL3bcChdPMYxMRc(nOJtQkTVjT9i1eCOY4LyvSgIhnAKtUW9FrODp5qaYxMRgVmWEJXTSykV3wr(NcaNlvbt1bB)qB)BRaKX0gwglqQIGwvprq6r4zhE6bXaX2C(heRPsBH87j(RVSykV3wZVWUSibMh2ALjh3YsS8)j6FBz9k4lbbHLXcKQiOv1teKEeE2dvgVeR2EKAcouz8sexat592A(f2LfjW8WwRm5LfZxicS9i1eCOY4LqkdnczD4P)LWY7abUJHutT4q(lb43G)64jTVjf7nEhGbXkTtVlSETIfJ)YYnEhGbXkTtVlSYKJla)FI(3w2ZfEfbeYfqIZLypuz8sifgg5YjcsxbdW)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8sSkw2Bmg2BmEDYfU)lcTEf8LGNa0rcpsnJBzX8fIaBpsnbhQmEjKAT4dzD4P)LWY7abUJHut7bj8cbI8vilTVjXFfZhiYZLGbI9gVdWGyL2P3fwVwzOXLLB8oadIvANExyLjhhK1HN(xclVde4ogsnThccSa)1XtAFt6gVdWGyL2P3fwVwTwJll34DageR0o9UWktgY6Wt)lHL3bcChdPMm)c7YIeyEyR0(Mex1xrI9aBpsnbhQmEjw1mngiw()e9VTSI8pfaoxQcMQd2(HwU6CrOyvJll8)j6FBzf5FkaCUufmvhS9dThQmEjwzOX4celzmTHLXcKQiOv1teKEeE2HNEqCzH)pr)BlRxbFjiiSmwGufbTQEIG0JWZEOY4LyLHgxwcoNpMeOv9j6GWYyf3YsSCvFfj2dS9i1eCOY4LqksntJbILmM2WYybsveSEu9ebPhHND4Phexw4)t0)2Y6vWxccclJfivrqRQNii9i8ShQmEjwT9i1eCOY4LiUaXY)NO)TLvK)PaW5svWuDW2p0YvNlcfRACzH)pr)BlRi)tbGZLQGP6GTFO9qLXlXQThPMGdvgVellMY7TvK)PaW5svWuDW2p0ktoU4ww2EKAcouz8siLH4dzD4P)LWY7abUJHutI8pfaoxQcMQd2(HGThEsuAFtI)vx2tl))R71Kyh87nwcpiAXAmjWoK1HN(xclVde4ogsnjY)ua4CPkyQoy7hkTVjX)NO)TLvK)PaW5svWuDW2p0YvNlcfKyFzz7rQj4qLXlHuS34YsS34DageR0o9UWEOY4LyLH4VSeBZ5FqSMkTscD(ubAo)dI1uPTq(9e)1JlqSXEJ3byqSs707cRxR4)t0)2YkY)ua4CPkyQoy7hA3YeeGd5QZfHG0vWLLMFJ3byqSs707clg2fPiUaXY)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8sSI)pr)BlRi)tbGZLQGP6GTFODltqaoKRoxecsxbxwcoNpMeOv9j6GWYyfxCb4)t0)2YUDrka)gSLVq2dvgVesrADcWv9vKypa)FI(3w2wv)i8kc0Vj6laz5IRApuz8sifjdShhK1HN(xclVde4ogsnjY)ua4CPkyQoy7hkTVjX)GynvALe68PceRP8EBBXH8xcWVb)1XZktEzj2ThPMGdvgVesX)NO)TLTfhYFja)g8xhp7HkJxILf()e9VTST4q(lb43G)64zpuz8sSI)pr)BlRi)tbGZLQGP6GTFODltqaoKRoxecsxbJla)FI(3w2Tlsb43GT8fYEOY4LqksRtaUQVIe7b4)t0)2Y2Q6hHxrG(nrFbilxCv7HkJxcPizG94GSo80)sy5DGa3XqQjr(NcaNlvbt1bB)qP9nj(heRPsBH87j(RhOJMY7T18lSllsG5HTGoAkV3wzYbILmM2WYybsve0Q6jcspcp7WtpiUSeCoFmjqR6t0bHLXAzH)pr)BlRxbFjiiSmwGufbTQEIG0JWZEOY4Lyf)FI(3wwr(NcaNlvbt1bB)q7wMGaCixDUieKUcUSW)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8sSATgJdY6Wt)lHL3bcChdPM8sWp5CmjqGrrEQuwb0XGohL23KiJPnSmwGufbTQEIG0JWZo80dIllMVqey7rQj4qLXlHuS3iK1HN(xclVde4ogsn1EtQkYVqP9njYyAdlJfivrqRQNii9i8Sdp9G4YI5leb2EKAcouz8sif7nczD4P)LWY7abUJHutret3N8pbWC6rO0(MezmTHLXcKQiOv1teKEeE2HNEqCzX8fIaBpsnbhQmEjKI9gHSo80)sy5DGa3XqQjzbc8evKUgfKu)WPV9dbbrHajK23KAEW58XKaTHLXc8fqwGG88scMll8)j6FBz9k4lbbHLXcKQiOv1teKEeE2dvgVeRyVXaKX0gwglqQIGwvprq6r4zpuz8sif7nUSeCoFmjqR6t0bHLXcY6Wt)lHL3bcChdPMKfiWtur6Auqsc1P)Tr3iidYprfP9njYyAdlJfivrqRQNii9i8Sdp9G4YI5leb2EKAcouz8sif7nUS08tUW9FrO1RGVe8eGos4rQjK1HN(xclVde4ogsnjlqGNOIqAFtQ5bNZhtc0gwglWxazbcYZljyUSW)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8sSI9gxwcoNpMeOv9j6GWYybzD4P)LWY7abUJHut5lZvb)gizoLrAFtA7rQj4qLXlXQ1PXLfYyAdlJfivrqRQNii9i8Sdp9G4YsW58XKaTQprhewgRLfZxicS9i1eCOY4LqkdndK1HN(xclVde4ogsnzs8FhSLVqs7Bs8)j6FBz9k4lbbHLXcKQiOv1teKEeE2dvgVeRwRXLLGZ5JjbAvFIoiSmwllMVqey7rQj4qLXlHuS3iK1HN(xclVde4ogsnzINapjEfjTVjX)NO)TL1RGVeeewglqQIGwvprq6r4zpuz8sSATgxwcoNpMeOv9j6GWYyTSy(crGThPMGdvgVeszi(qwhE6FjS8oqG7yi1eHhPMcaluUhPGvczD4P)LWY7abUJHutB)qtI)7s7Bs8)j6FBz9k4lbbHLXcKQiOv1teKEeE2dvgVeRwRXLLGZ5JjbAvFIoiSmwllMVqey7rQj4qLXlHugAeY6Wt)lHL3bcChdPMMIJI8gcaFiiK23K4)t0)2Y6vWxccclJfivrqRQNii9i8ShQmEjwTwJllbNZhtc0Q(eDqyzSwwmFHiW2JutWHkJxcPyVriRdp9VewEhiWDmKAYCIa)gKNZLiK23KmL3BRi)tbGZLQGP6GTFOT)TfK1HN(xclVde4ogsnTjqHk)MDkTVjjEzctV6wYYIuMab4jto9VcykV3wr(NcaNlvbt1bB)qB)BRaD0uEVTMFHDzrcmpSf0rt5922)2cYkK1HN(xclVde4HLNHifCoFmjqPRrbjjWdlpdbmLprk9tMKatPdoeYij()e9VTSc8WYZq2dvgVeszyzHmM2WYybsve0Q6jcspcp7WtpigG)pr)BlRapS8mK9qLXlXQ1ACzX8fIaBpsnbhQmEjKI9gHSo80)sy5DGapS8mumKAYRGVeeewglqQIGwvprq6r4jTVj18GZ5JjbAvFIoiSmwllMVqey7rQj4qLXlHuShFiRdp9VewEhiWdlpdfdPMmj(Vd2YxiP9nPGZ5JjbAf4HLNHaMYNiHSo80)sy5DGapS8mumKAYepbEs8ksAFtk4C(ysGwbEy5ziGP8jsiRdp9VewEhiWdlpdfdPMi8i1uayHY9ifSsiRdp9VewEhiWdlpdfdPM2(HMe)3L23KcoNpMeOvGhwEgcykFIeY6Wt)lHL3bc8WYZqXqQPP4OiVHaWhccP9nPGZ5JjbAf4HLNHaMYNiHSo80)sy5DGapS8mumKAYCIa)gKNZLiK23KcoNpMeOvGhwEgcykFIeY6Wt)lHL3bc8WYZqXqQP8L5QGFd64KQs7BsBpsnbhQmEjwfRH4rJg5KlC)xeA3toeG8L5QXldS3yCllKX0gwglqQIGwvprq6r4zhE6bXaX2C(heRPsBH87j(RVSykV3wZVWUSibMh2ALjh3YsS8)j6FBz9k4lbbHLXcKQiOv1teKEeE2dvgVeR2EKAcouz8sexat592A(f2LfjW8WwRm5LfZxicS9i1eCOY4LqkdnczD4P)LWY7abEy5zOyi1uloK)sa(n4VoEs7Bs8)j6FBzpx4veqixajoxI9qLXlHuyyKlNiiDfeY6Wt)lHL3bc8WYZqXqQjVe8tohtceyuKNkLvaDmOZrP9nPGZ5JjbAf4HLNHaMYNiHSo80)sy5DGapS8mumKAQ9MuvKFHs7BsbNZhtc0kWdlpdbmLprczD4P)LWY7abEy5zOyi1ueX09j)tamNEekTVjfCoFmjqRapS8meWu(ejK1HN(xclVde4HLNHIHutYce4jQiDnkijH60)2OBeKb5NOI0(MezmTHLXcKQiOv1teKEeE2HNEqCzX8fIaBpsnbhQmEjKI9gxwA(jx4(Vi06vWxcEcqhj8i1eY6Wt)lHL3bc8WYZqXqQjzbc8eves7Bsnp4C(ysG2WYyb(cilqqEEjbZLf()e9VTSEf8LGGWYybsve0Q6jcspcp7HkJxIvS34YsW58XKaTQprhewgliRdp9VewEhiWdlpdfdPM2ds4fce5RqgY6Wt)lHL3bc8WYZqXqQP9qqGf4VoEqwhE6FjS8oqGhwEgkgsnz(f2LfjW8WwP9njZxicS9i1eCOY4LqkdXFzjwUQVIe7bID7rQj4qLXlXQMPXaXgl)FI(3wwbEy5zi7HkJxIvgACzXuEVTc8WYZqwzYll8)j6FBzf4HLNHSYKJlqSKX0gwglqQIGwvprq6r4zhE6bXLf()e9VTSEf8LGGWYybsve0Q6jcspcp7HkJxIvgACzj4C(ysGw1NOdclJvCXf3YsSBpsnbhQmEjKIuZ0yGyjJPnSmwGufbRhvprq6r4zhE6bXLf()e9VTSEf8LGGWYybsve0Q6jcspcp7HkJxIvBpsnbhQmEjIlU4GSo80)sy5DGapS8mumKAsGhwEgsAFtI)pr)Bl75cVIac5ciX5sShQmEjKI9LfZxicS9i1eCOY4LqkdXhY6Wt)lHL3bc8WYZqXqQjZjc8BqEoxIaY6Wt)lHL3bc8WYZqXqQPnbku53StP9njXlty6v3swwKYeiapzYP)vat592kWdlpdz7FBfOJMY7T18lSllsG5HTGoAkV32(3wqwHSo80)syFYyHhPTlsWVbPkcAv9ebPhHN08qCceKZDrykizqAFtIR6wLjSr4Q(ksRbzD4P)LW(KXcVyi1egMmsauNtrAFtkhcSslx1bMYNiTynMeypax1TktyJWv9vKwdY6Wt)lH9jJfEXqQP0JWdqEiuKMhItGGCUimfKmiTVjXFfZhiYZLGb4QUvzcBeUQVIe7qwhE6FjSpzSWlgsnXvDq7eeL23K4QUvzcBeUQtIDiRdp9Ve2Nmw4fdPMWWKrcG6CkqwhE6FjSpzSWlgsnLEeEaYdHI08qCceKZfHPGKbP9njUQBvMWgHR6RiXoKviRdp9VewbEy5zisBxKcWVbB5lK0(MKP8EBf4HLNHShQmEjKYaK1HN(xcRapS8mumKAsq2RYRia)McbsCUeP9nj(Ry(arEUemqSdp9GialuXrXksRTSm80dIaSqfhfRmeO58)j6FBzpx4veqixajoxIvMCCqwhE6FjSc8WYZqXqQPZfEfbeYfqIZLinpeNab5CrykizqAFtI)kMpqKNlbHSo80)syf4HLNHIHutBxKcWVbB5lK0(M0WtpicWcvCuSI0AqwhE6FjSc8WYZqXqQjbzVkVIa8BkeiX5sK23K4VI5de55sWaMY7TTpfhb)gWvDwOBLjdzD4P)LWkWdlpdfdPMmjgUKxobsCUeP5H4eiiNlctbjds7Bs8xX8bI8Cjyat5922Id5VeGFd(RJNvMCa()e9VTSNl8kciKlGeNlXEOY4Lyf7qwhE6FjSc8WYZqXqQPTlsb43GT8fsAVs8ozYjW3KmL3BRapS8mKvMCa()e9VTSNl8kciKlGeNlXE40dbzD4P)LWkWdlpdfdPMeK9Q8kcWVPqGeNlrAFtI)kMpqKNlbd0rt592A(f2LfjW8WwqhnL3BRmziRdp9VewbEy5zOyi102fj43GufbTQEIG0JWtAEiobcY5IWuqYG0(Mex1LAniRdp9VewbEy5zOyi1KjXWL8YjqIZLinpeNab5CrykizqAFtI)kMpqKNlbxwAEoeyLwvpb8xX8HSo80)syf4HLNHIHutcYEvEfb43uiqIZLazfY6Wt)lHvKKAv9JWRiq)MOVaKLlUQ0(M0nEhGbXkTtVlSETI)pr)BlBRQFeEfb63e9fGSCXvTD5Bs)R4vJ24XYYnEhGbXkTtVlSYKHSo80)syfzmKAcl8I8MfVIaiHh2pP9njUQBvMWgHR6RiXEaSWlkKnDfeKpqzcVATLfUQBvMWgHR6RiXIbIfl8Icztxbb5duMWRyFzP5KpmiiI3TgSPhHhG8qOehK1HN(xcRiJHutcYEvEfb43uiqIZLiTVjXFfZhiYZLGbmL3BBFkoc(nGR6Sq3ktoqS34DageR0o9UW61kt5922NIJGFd4Qol0ThQmEjmc7ll34DageR0o9UWktooiRdp9VewrgdPMox4veqixajoxI08qCceKZfHPGKbP9nj()e9VTSc8WYZq2dvgVeRmSS08CiWkTc8WYZqbIL)pr)BlBloK)sa(n4VoE2dvgVeRyXLLMZ)GynvALe68PIdY6Wt)lHvKXqQPTlsb43GT8fsAFtk2B8oadIvANExy9Af)FI(3w2Tlsb43GT8fY2LVj9VIxnAJhll34DageR0o9UWktoUaXIfErHSPRGG8bkt4vyyKlNiiDf0igww4QUvzcBeUQlfjdllMY7TvK)PaW5svWuDW2p0EOY4LqkmmYLteKUcgJH4ww2EKAcouz8sifgg5YjcsxbJXWYshnL3BR5xyxwKaZdBbD0uEVTYKHSo80)syfzmKAIFdxcHxraw40raHhPMLxrs7BsMY7TnvraQqgV)ea(qE4E(NvKdxYkdRtaSWlkKnDfeKpqzcVcdJC5ebPRGgXqa()e9VTSNl8kciKlGeNlXEOY4Lyfgg5YjcsxbxwmL3BBQIauHmE)ja8H8W98pRihUKvgyXaXY)NO)TLvGhwEgYEOY4LqQ4hihcSsRapS8m0Yc)FI(3w2wCi)La8BWFD8ShQmEjKk(b4FqSMkTscD(ullBpsnbhQmEjKk(XbzD4P)LWkYyi10jlu9kcWcNocA9QlTVjzkV32twO6veGfoDe06v32)2kWWtpicWcvCuSYaK1HN(xcRiJHutBxKGFdsve0Q6jcspcpP5H4eiiNlctbjds7BsCvxQ1GSo80)syfzmKAcdtgjaQZPiTVjXvDRYe2iCvFfjdqwhE6FjSImgsnXvDGP8jsP9njUQBvMWgHR6RiziWWtpicWcvCuqYqGB8oadIvANExy9Af7nUSWvDRYe2iCvFfj2dm80dIaSqfhfRiXoK1HN(xcRiJHutCvh0obriRdp9VewrgdPMspcpa5HqrAEiobcY5IWuqYG0(Me)vmFGipxcgGR6wLjSr4Q(ksShWuEVTI8pfaoxQcMQd2(H2(3wqwhE6FjSImgsnji7v5veGFtHajoxI0(MKP8EB5Qoal8Iczf5WLSATgns8Jxdp9GialuXrrat592kY)ua4CPkyQoy7hA7FBfiw()e9VTSNl8kciKlGeNlXEOY4Lyf7b4)t0)2YUDrka)gSLVq2dvgVeRyFzH)pr)Bl75cVIac5ciX5sShQmEjKATa8)j6FBz3UifGFd2Yxi7HkJxIvRfGR6RwBzH)pr)Bl75cVIac5ciX5sShQmEjwTwa()e9VTSBxKcWVbB5lK9qLXlHuRfGR6RyXLfUQBvMWgHR6srYqaSWlkKnDfeKpqzclf7XTSykV3wUQdWcVOqwroCjRm0yGThPMGdvgVesTEHSo80)syfzmKAYKy4sE5eiX5sKMhItGGCUimfKmiTVjXFfZhiYZLGbInhcSsRapS8mua()e9VTSc8WYZq2dvgVesT2Yc)FI(3w2ZfEfbeYfqIZLypuz8sSYqa()e9VTSBxKcWVbB5lK9qLXlXkdll8)j6FBzpx4veqixajoxI9qLXlHuRfG)pr)Bl72fPa8BWw(czpuz8sSATaCvFf7ll8)j6FBzpx4veqixajoxI9qLXlXQ1cW)NO)TLD7Iua(nylFHShQmEjKATaCvF1AllCvFv8xwmL3BR5lbq(EUvMCCqwhE6FjSImgsnLEeEaYdHI08qCceKZfHPGKbP9nj(Ry(arEUemax1TktyJWv9vKyhY6Wt)lHvKXqQP54tHG8VdRuAFtIR6wLjSr4Q(ksgGSo80)syfzmKAAteYRiGapYyLajoxI0EL4DYKtsgGSo80)syfzmKAYKy4sE5eiX5sKMhItGGCUimfKmiTVjXFfZhiYZLGb4)t0)2YUDrka)gSLVq2dvgVesTwaUQtI9aKpmiiI3TgSPhHhG8qOeal8Icztxbb5dIFJszaY6Wt)lHvKXqQjtIHl5LtGeNlrAEiobcY5IWuqYG0(Me)vmFGipxcgal8Icztxbb5duMWsXEGy5QUvzcBeUQlfjdllKpmiiI3TgSPhHhG8qOehKviRdp9Ve2wCi)La8BWFD8ifCoFmjqPRrbjzsmCjVCcK4CjGcXo2L(jtsGP0bhczKKP8EBBXH8xcWVb)1Xd02Apuz8seiw()e9VTSNl8kciKlGeNlXEOY4LyLP8EBBXH8xcWVb)1Xd02Apuz8seWuEVTT4q(lb43G)64bABThQmEjKIDRHLf()e9VTSNl8kciKlGeNlXEOY4LWiMY7TTfhYFja)g8xhpqBR9qLXlXkd21jGP8EBBXH8xcWVb)1Xd02Apuz8siflAnSSykV3wtI)7eYI0ktoGP8EB9k4lbpbOJeEKAALjhWuEVTEf8LGNa0rcpsnThQmEjKYuEVTT4q(lb43G)64bABThQmEjIdY6Wt)lHTfhYFja)g8xhVyi1eFiiadp9VaeUiLUgfKeVde4wArEopjzqAFtQ55qGvAf4HLNHGSo80)syBXH8xcWVb)1XlgsnXhccWWt)laHlsPRrbjX7abEy5ziPf558KKbP9nPCiWkTc8WYZqqwhE6FjST4q(lb43G)64fdPMWcViVzXRias4H9tAFtIR6wLjSr4Q(ksShal8Icztxbb5duMWRwdY6Wt)lHTfhYFja)g8xhVyi105cVIac5ciX5sKMhItGGCUimfKmazD4P)LW2Id5VeGFd(RJxmKAA7Iua(nylFHK23KgE6brawOIJIvKypGP8EBBXH8xcWVb)1Xd02Apuz8siLbiRdp9Ve2wCi)La8BWFD8IHutTQ(r4veOFt0xaYYfxvAFtA4PhebyHkokwrIDiRdp9Ve2wCi)La8BWFD8IHutcYEvEfb43uiqIZLiTVjXFfZhiYZLGbgE6brawOIJIvKwlGP8EBBXH8xcWVb)1Xd02ALjdzD4P)LW2Id5VeGFd(RJxmKAYKy4sE5eiX5sKMhItGGCUimfKmiTVjXFfZhiYZLGbgE6brawOIJcPiXEGGZ5JjbAnjgUKxobsCUeqHyh7qwhE6FjST4q(lb43G)64fdPMeK9Q8kcWVPqGeNlrAFtI)kMpqKNlbdykV32(uCe8Bax1zHUvMmK1HN(xcBloK)sa(n4VoEXqQjmmzKaOoNI0(Mex1j1yat5922Id5VeGFd(RJhOT1EOY4LqkweY6Wt)lHTfhYFja)g8xhVyi102fj43GufbTQEIG0JWtAEiobcY5IWuqYG0(Mex1j1yat5922Id5VeGFd(RJhOT1EOY4LqkweY6Wt)lHTfhYFja)g8xhVyi1uRQFeEfb63e9fGSCXvHSo80)syBXH8xcWVb)1XlgsnLEeEaYdHI08qCceKZfHPGKbP9njUQtQXaMY7TTfhYFja)g8xhpqBR9qLXlHuSiK1HN(xcBloK)sa(n4VoEXqQPTlsb43GT8fsAVs8ozYjW3KmL3BBloK)sa(n4VoEG2wRmzP9njt592kY)ua4CPkyQoy7hALjh4gVdWGyL2P3fwVwX)NO)TLD7Iua(nylFHSD5Bs)R4vJ2MbY6Wt)lHTfhYFja)g8xhVyi1KGSxLxra(nfcK4Cjs7BsMY7TLR6aSWlkKvKdxYQ1A0iXpEn80dIaSqfhfqwhE6FjST4q(lb43G)64fdPM2Uib)gKQiOv1teKEeEsZdXjqqoxeMcsgK23K4QUuRbzD4P)LW2Id5VeGFd(RJxmKAcdtgjaQZPiTVjXvDRYe2iCvFfjdqwhE6FjST4q(lb43G)64fdPM4QoWu(eP0(Mex1TktyJWv9vKI1qmdp9GialuXrXkdXbzD4P)LW2Id5VeGFd(RJxmKAk9i8aKhcfP5H4eiiNlctbjds7BsX28CiWkTQEc4VI5VSWFfZhiYZLGXfGR6wLjSr4Q(ksSdzD4P)LW2Id5VeGFd(RJxmKAYKy4sE5eiX5sKMhItGGCUimfKmiTVjn80dIaSqfhfsrATaCvFfP1wwmL3BBloK)sa(n4VoEG2wRmziRdp9Ve2wCi)La8BWFD8IHutCvh0obriRdp9Ve2wCi)La8BWFD8IHutBIqEfbe4rgReiX5sK2ReVtMCsYGMzKt1)0mmUY6RtDQ1a]] )


end