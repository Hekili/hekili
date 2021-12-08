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


    spec:RegisterPack( "Windwalker", 20211207, [[dSekHcqiPO6rcvP2Ka(ekrJsO0PeQSkHQKxjumlIQUffHDrPFjfzysHogf1YiQ8mLuMgkHUMqvTnPO4BsrPghfr6CkPkRtjvmpuQUhISpLKdkufAHsbpujv1efQcYffQIAJcvb8rLujoPqvKvIs6LcvbAMOe4Mcvb1orP8tLujTuPOKEkkMkfPVQKk1yPiQ9sQ)cmyKoSIftHhJQjlvxgAZk1NfYOjPtt1QrjOxtuMnc3Me7wYVv1WruhNIiwUkpNW0fDDISDb67sPXlOoVGSEPOeZxj2pO1M1MQz6tIA2KRr5mBwUgB2w5wZSjn(RPzYqKrnd5HlBIqntnkOMzD7vVDiKHNMH8eI4NU2unJ4LooQz0mgsorgpvAdntFsuZMCnkNzZY1yZ2k3AMnPS46PzeKrUMn5AM1tZO69owAdnthfCnZ62RE7qidpinE4VKbzLTpiQyGhKUwJYdPY1OCMHSczD9vNlcfRdKvtaPM2IJminEaxKci93qA8asxii1ReVtICcPeFKZTqwnbKAAloYGugYEvEfbPR)nfcPXd6CzqkXh5ClKvtaPXJ9oKA8cX2JutiLRICzcinFivzQqq66hpeKIvEokSAgcxKcTPAMNmw4PnvZMzTPAgSgdcSRBqZm80)sZSDrc(nivrqRQNii9i80m8Zt88rZWvDRYegsnbKYvDiDfjiDnndpeNab5CxeMcnJzDQztoTPAgSgdcSRBqZWppXZhntoeyLwUQdmKorAXAmiWoKgas5QUvzcdPMas5QoKUIeKUMMz4P)LMbdtgjaQZPOtnBRPnvZG1yqGDDdAMHN(xAM0JWdqEiu0m8Zt88rZWFfJhiYZLHqAaiLR6wLjmKAciLR6q6ksqQCAgEiobcY5IWuOzZSo1SXIAt1myngeyx3GMHFEINpAgUQBvMWqQjGuUQdPKGu50mdp9V0mCvh0obrDQzl(At1mdp9V0myyYibqDofndwJbb21nOtnBnJ2undwJbb21nOzgE6FPzspcpa5HqrZWppXZhndx1Tktyi1eqkx1H0vKGu50m8qCceKZfHPqZMzDQtntloK)sa(n4VoEAt1SzwBQMbRXGa76g0mpznJatnZWt)lntW58XGa1mbhcjuZyiT32wCi)La8BWFD8aTT2dvgVeqAainwiL)pr)Bl75cVIacPciZ5YShQmEjG0vqQH0EBBXH8xcWVb)1Xd02Apuz8saPbGudP922Id5VeGFd(RJhOT1EOY4LaszhsLZAgsxwGu()e9VTSNl8kciKkGmNlZEOY4LasnbKAiT32wCi)La8BWFD8aTT2dvgVeq6ki1SD9G0aqQH0EBBXH8xcWVb)1Xd02Apuz8saPSdPSO1mKUSaPgs7T1G4)oHKiTsKH0aqQH0EB9k4ldpbOJeEKAALidPbGudP926vWxgEcqhj8i10EOY4LaszhsnK2BBloK)sa(n4VoEG2w7HkJxcinontW5a1OGAgdIHl7LsGmNldui2XUo1SjN2undwJbb21nOz4NN45JMP5qAoeyLwbEy5zilwJbb21mI8CEQzZSMz4P)LMHpeeGHN(xacxKAgcxKGAuqndVde4wNA2wtBQMbRXGa76g0m8Zt88rZKdbwPvGhwEgYI1yqGDnJipNNA2mRzgE6FPz4dbby4P)fGWfPMHWfjOgfuZW7abEy5ziDQzJf1MQzWAmiWUUbnd)8epF0mCv3QmHHutaPCvhsxrcsLdsdaPyHxuiB6kiiFGYegsxbPRPzgE6FPzWcViVzXRias4H9tNA2IV2undwJbb21nOzgE6FPzox4veqivazoxMMHhItGGCUimfA2mRtnBnJ2undwJbb21nOz4NN45JMz4PhebyHkokG0vKGu5G0aqQH0EBBXH8xcWVb)1Xd02Apuz8saPSdPM1mdp9V0mBxKcWVbBPlKo1S1S1MQzWAmiWUUbnd)8epF0mdp9GialuXrbKUIeKkNMz4P)LMPv1pcVIa9BI(cqwQ4Q6uZMjvBQMbRXGa76g0m8Zt88rZWFfJhiYZLHqAaiD4PhebyHkokG0vKG01G0aqQH0EBBXH8xcWVb)1Xd02ALiRzgE6FPzeK9Q8kcWVPqGmNltNA2wpTPAgSgdcSRBqZm80)sZyqmCzVucK5CzAg(5jE(Oz4VIXde55YqinaKo80dIaSqfhfqk7KGu5G0aqAW58XGaTgedx2lLazoxgOqSJDndpeNab5Cryk0SzwNA2m3O2undwJbb21nOz4NN45JMH)kgpqKNldH0aqQH0EB7tXrWVbCvNf6wjYAMHN(xAgbzVkVIa8BkeiZ5Y0PMnZM1MQzWAmiWUUbnd)8epF0mCvhsjbPncPbGudP922Id5VeGFd(RJhOT1EOY4LaszhszrnZWt)lndgMmsauNtrNA2mlN2undwJbb21nOzgE6FPz2Uib)gKQiOv1teKEeEAg(5jE(Oz4QoKscsBesdaPgs7TTfhYFja)g8xhpqBR9qLXlbKYoKYIAgEiobcY5IWuOzZSo1SzEnTPAMHN(xAMwv)i8kc0Vj6lazPIRQzWAmiWUUbDQzZmlQnvZG1yqGDDdAMHN(xAM0JWdqEiu0m8Zt88rZWvDiLeK2iKgasnK2BBloK)sa(n4VoEG2w7HkJxciLDiLf1m8qCceKZfHPqZMzDQzZC81MQzWAmiWUUbnd)8epF0mgs7TvK)PaW5svWuDW2p0krgsdaP34DageR0o9UW6fKUcs5)t0)2YUDrka)gSLUq2U0nP)fKgVG0gTnJMz4P)LMz7Iua(nylDH0mEL4DsKtGV1mgs7TTfhYFja)g8xhpqBRvISo1SzUz0MQzWAmiWUUbnd)8epF0mgs7TLR6aSWlkKvKdxgKUcsxRri1eqA8H04fKo80dIaSqfhfAMHN(xAgbzVkVIa8BkeiZ5Y0PMnZnBTPAgSgdcSRBqZm80)sZSDrc(nivrqRQNii9i80m8Zt88rZWvDiLDiDnndpeNab5Cryk0SzwNA2mBs1MQzWAmiWUUbnd)8epF0mCv3QmHHutaPCvhsxrcsnRzgE6FPzWWKrcG6Ck6uZM51tBQMbRXGa76g0m8Zt88rZWvDRYegsnbKYvDiDfjinwi1mKgdKo80dIaSqfhfq6ki1mKgNMz4P)LMHR6adPtK6uZMCnQnvZG1yqGDDdAMHN(xAM0JWdqEiu0m8Zt88rZelK2CinhcSsRQNa(Ry8wSgdcSdPllqk)vmEGipxgcPXbPbGuUQBvMWqQjGuUQdPRibPYPz4H4eiiNlctHMnZ6uZMCM1MQzWAmiWUUbnZWt)lnJbXWL9sjqMZLPz4NN45JMz4PhebyHkokGu2jbPRbPbGuUQdPRibPRbPllqQH0EBBXH8xcWVb)1Xd02ALiRz4H4eiiNlctHMnZ6uZMCYPnvZm80)sZWvDq7ee1myngeyx3Go1Sj3AAt1mEL4DsKtnJznZWt)lnZMiKxrabEKXkbYCUmndwJbb21nOtDQze4HLNH0MQzZS2undwJbb21nOz4NN45JMXqAVTc8WYZq2dvgVeqk7qQznZWt)lnZ2fPa8BWw6cPtnBYPnvZG1yqGDDdAg(5jE(Oz4VIXde55YqinaKglKo80dIaSqfhfq6ksq6Aq6YcKo80dIaSqfhfq6ki1mKgasBoKY)NO)TL9CHxraHubK5CzwjYqACAMHN(xAgbzVkVIa8BkeiZ5Y0PMT10MQzWAmiWUUbnZWt)lnZ5cVIacPciZ5Y0m8Zt88rZWFfJhiYZLHAgEiobcY5IWuOzZSo1SXIAt1myngeyx3GMHFEINpAMHNEqeGfQ4OasxrcsxtZm80)sZSDrka)gSLUq6uZw81MQzWAmiWUUbnd)8epF0m8xX4bI8CziKgasnK2BBFkoc(nGR6Sq3krwZm80)sZii7v5veGFtHazoxMo1S1mAt1myngeyx3GMz4P)LMXGy4YEPeiZ5Y0m8Zt88rZWFfJhiYZLHqAai1qAVTT4q(lb43G)64zLidPbGu()e9VTSNl8kciKkGmNlZEOY4LasxbPYPz4H4eiiNlctHMnZ6uZwZwBQMXReVtICc8TMXqAVTc8WYZqwjYb4)t0)2YEUWRiGqQaYCUm7HtpKMz4P)LMz7Iua(nylDH0myngeyx3Go1Szs1MQzWAmiWUUbnd)8epF0m8xX4bI8CziKgas7OH0EBn(c7sIeyCylOJgs7TvISMz4P)LMrq2RYRia)McbYCUmDQzB90MQzWAmiWUUbnZWt)lnZ2fj43GufbTQEIG0JWtZWppXZhndx1Hu2H010m8qCceKZfHPqZMzDQzZCJAt1myngeyx3GMz4P)LMXGy4YEPeiZ5Y0m8Zt88rZWFfJhiYZLHq6YcK2CinhcSsRQNa(Ry8wSgdcSRz4H4eiiNlctHMnZ6uZMzZAt1mdp9V0mcYEvEfb43uiqMZLPzWAmiWUUbDQtndVde4HLNH0MQzZS2undwJbb21nOzEYAgbMAMHN(xAMGZ5JbbQzcoesOMH)pr)BlRapS8mK9qLXlbKYoKAgsxwGuYyAdlHfivrqRQNii9i8Sdp9GiKgas5)t0)2YkWdlpdzpuz8saPRG01AesxwGuJxiG0aq62JutWHkJxciLDivUg1mbNduJcQze4HLNHagsNi1PMn50MQzWAmiWUUbnd)8epF0mnhsdoNpgeOv9j6GWsybPllqQXleqAaiD7rQj4qLXlbKYoKkx81mdp9V0mEf8LHGWsyPtnBRPnvZG1yqGDDdAg(5jE(OzcoNpgeOvGhwEgcyiDIuZm80)sZyq8FhSLUq6uZglQnvZG1yqGDDdAg(5jE(OzcoNpgeOvGhwEgcyiDIuZm80)sZyGNapzEfPtnBXxBQMz4P)LMHWJutbGfk1JuWk1myngeyx3Go1S1mAt1myngeyx3GMHFEINpAMGZ5JbbAf4HLNHagsNi1mdp9V0mB)qdI)76uZwZwBQMbRXGa76g0m8Zt88rZeCoFmiqRapS8meWq6ePMz4P)LMzkokYBia8HGqNA2mPAt1myngeyx3GMHFEINpAMGZ5JbbAf4HLNHagsNi1mdp9V0mgte43G8CUmHo1STEAt1myngeyx3GMHFEINpAMThPMGdvgVeq6kinwi1SjTri1eq6jv4(Vi0UNCia5lXvTyngeyhsJxqQz5AesJdsxwGuYyAdlHfivrqRQNii9i8Sdp9GiKgasJfsBoKY)GynvAlKFpXFDiDzbsnK2BRXxyxsKaJdBTsKH04G0LfinwiL)pr)BlRxbFziiSewGufbTQEIG0JWZEOY4LasxbPBpsnbhQmEjG04G0aqQH0EBn(c7sIeyCyRvImKUSaPgVqaPbG0ThPMGdvgVeqk7qQ5g1mdp9V0m5lXvb)g0Xjv1PMnZnQnvZG1yqGDDdAg(5jE(Oz4)t0)2YEUWRiGqQaYCUm7HkJxciLDifdJCPebPRGAMHN(xAMwCi)La8BWFD80PMnZM1MQzWAmiWUUbnd)8epF0mbNZhdc0kWdlpdbmKorQzgE6FPz8sWpPCmiqGjrAQusb0XGoh1PMnZYPnvZG1yqGDDdAg(5jE(OzcoNpgeOvGhwEgcyiDIuZm80)sZ0EtQkYVqDQzZ8AAt1myngeyx3GMHFEINpAMGZ5JbbAf4HLNHagsNi1mdp9V0mret3N8pbWy6rOo1SzMf1MQzWAmiWUUbnZWt)lnJqD6FB0ncYG8turZWppXZhndzmTHLWcKQiOv1teKEeE2HNEqesxwGuJxiG0aq62JutWHkJxciLDivUgH0LfiT5q6jv4(Vi06vWxgEcqhj8i10I1yqGDntnkOMrOo9Vn6gbzq(jQOtnBMJV2undwJbb21nOz4NN45JMP5qAW58XGaTHLWc8fqsGG88sgMq6YcKY)NO)TL1RGVmeewclqQIGwvprq6r4zpuz8saPRGu5AesxwG0GZ5JbbAvFIoiSewAMHN(xAgjbc8eve6uZM5MrBQMz4P)LMzpiHxiqKVczndwJbb21nOtnBMB2At1mdp9V0m7HGalWFD80myngeyx3Go1Sz2KQnvZG1yqGDDdAg(5jE(OzmEHasdaPBpsnbhQmEjGu2HuZXhsxwG0yHuUQdPRibPYbPbG0yH0ThPMGdvgVeq6kiTzAesdaPXcPXcP8)j6FBzf4HLNHShQmEjG0vqQ5gH0Lfi1qAVTc8WYZqwjYq6YcKY)NO)TLvGhwEgYkrgsJdsdaPXcPKX0gwclqQIGwvprq6r4zhE6briDzbs5)t0)2Y6vWxgcclHfivrqRQNii9i8ShQmEjG0vqQ5gH0Lfin4C(yqGw1NOdclHfKghKghKghKUSaPXcPBpsnbhQmEjGu2jbPntJqAainwiLmM2WsybsveSUv9ebPhHND4PheH0LfiL)pr)BlRxbFziiSewGufbTQEIG0JWZEOY4LasxbPBpsnbhQmEjG04G04G040mdp9V0mgFHDjrcmoSvNA2mVEAt1myngeyx3GMHFEINpAg()e9VTSNl8kciKkGmNlZEOY4LaszhsLdsxwGuJxiG0aq62JutWHkJxciLDi1C81mdp9V0mc8WYZq6uZMCnQnvZm80)sZymrGFdYZ5YeAgSgdcSRBqNA2KZS2undwJbb21nOz4NN45JMr8segE1TKLePebcWtIC6FzXAmiWoKgasnK2BRapS8mKT)TfKgas7OH0EBn(c7sIeyCylOJgs7TT)TfKgasnK2BRXxyxsKaJdBT9VT0mdp9V0mBcuOYVzN6uNAgrQnvZMzTPAgSgdcSRBqZWppXZhnZnEhGbXkTtVlSEbPRGu()e9VTSTQ(r4veOFt0xaYsfx12LUj9VG04fK2O1KcPllq6nEhGbXkTtVlSsK1mdp9V0mTQ(r4veOFt0xaYsfxvNA2KtBQMbRXGa76g0m8Zt88rZWvDRYegsnbKYvDiDfjivoinaKIfErHSPRGG8bktyiDfKUgKUSaPCv3QmHHutaPCvhsxrcszrinaKglKIfErHSPRGG8bktyiDfKkhKUSaPnhsjFyqqeVBnBtpcpa5HqbsJtZm80)sZGfErEZIxraKWd7No1STM2undwJbb21nOz4NN45JMH)kgpqKNldH0aqQH0EB7tXrWVbCvNf6wjYqAainwi9gVdWGyL2P3fwVG0vqQH0EB7tXrWVbCvNf62dvgVeqQjGu5G0Lfi9gVdWGyL2P3fwjYqACAMHN(xAgbzVkVIa8BkeiZ5Y0PMnwuBQMbRXGa76g0mdp9V0mNl8kciKkGmNltZWppXZhnd)FI(3wwbEy5zi7HkJxciDfKAgsxwG0MdP5qGvAf4HLNHSyngeyhsdaPXcP8)j6FBzBXH8xcWVb)1XZEOY4LasxbPSiKUSaPnhs5FqSMkTYcD(uqACAgEiobcY5IWuOzZSo1SfFTPAgSgdcSRBqZWppXZhntSq6nEhGbXkTtVlSEbPRGu()e9VTSBxKcWVbBPlKTlDt6FbPXliTrRjfsxwG0B8oadIvANExyLidPXbPbG0yHuSWlkKnDfeKpqzcdPRGummYLseKUccPMasndPllqkx1Tktyi1eqkx1Hu2jbPMH0Lfi1qAVTI8pfaoxQcMQd2(H2dvgVeqk7qkgg5sjcsxbH0yGuZqACq6YcKU9i1eCOY4LaszhsXWixkrq6kiKgdKAgsxwG0oAiT3wJVWUKibgh2c6OH0EBLiRzgE6FPz2UifGFd2sxiDQzRz0MQzWAmiWUUbnd)8epF0mgs7TnvraQqgV)ea(qE4E(NvKdxgKUcsnVEqAaifl8Icztxbb5duMWq6kifdJCPebPRGqQjGuZqAaiL)pr)Bl75cVIacPciZ5YShQmEjG0vqkgg5sjcsxbH0Lfi1qAVTPkcqfY49NaWhYd3Z)SIC4YG0vqQzwesdaPXcP8)j6FBzf4HLNHShQmEjGu2H04dPbG0CiWkTc8WYZqwSgdcSdPllqk)FI(3w2wCi)La8BWFD8ShQmEjGu2H04dPbGu(heRPsRSqNpfKUSaPBpsnbhQmEjGu2H04dPXPzgE6FPz43WLr4veGfoDeq4rQz5vKo1S1S1MQzWAmiWUUbnd)8epF0mgs7T9KeQEfbyHthbTE1T9VTG0aq6WtpicWcvCuaPRGuZAMHN(xAMtsO6veGfoDe06vxNA2mPAt1myngeyx3GMz4P)LMz7Ie8BqQIGwvprq6r4Pz4NN45JMHR6qk7q6AAgEiobcY5IWuOzZSo1STEAt1myngeyx3GMHFEINpAgUQBvMWqQjGuUQdPRibPM1mdp9V0myyYibqDofDQzZCJAt1myngeyx3GMHFEINpAgUQBvMWqQjGuUQdPRibPMH0aq6WtpicWcvCuaPKGuZqAai9gVdWGyL2P3fwVG0vqQCncPllqkx1Tktyi1eqkx1H0vKGu5G0aq6WtpicWcvCuaPRibPYPzgE6FPz4QoWq6ePo1Sz2S2unZWt)lndx1bTtquZG1yqGDDd6uZMz50MQzWAmiWUUbnZWt)lnt6r4bipekAg(5jE(Oz4VIXde55YqinaKYvDRYegsnbKYvDiDfjivoinaKAiT3wr(NcaNlvbt1bB)qB)BlndpeNab5Cryk0SzwNA2mVM2undwJbb21nOz4NN45JMXqAVTCvhGfErHSIC4YG0vq6AncPMasJpKgVG0HNEqeGfQ4OasdaPgs7TvK)PaW5svWuDW2p02)2csdaPXcP8)j6FBzpx4veqivazoxM9qLXlbKUcsLdsdaP8)j6FBz3UifGFd2sxi7HkJxciDfKkhKUSaP8)j6FBzpx4veqivazoxM9qLXlbKYoKUgKgas5)t0)2YUDrka)gSLUq2dvgVeq6kiDninaKYvDiDfKUgKUSaP8)j6FBzpx4veqivazoxM9qLXlbKUcsxdsdaP8)j6FBz3UifGFd2sxi7HkJxciLDiDninaKYvDiDfKYIq6YcKYvDRYegsnbKYvDiLDsqQzinaKIfErHSPRGG8bktyiLDivoinoiDzbsnK2Blx1byHxuiRihUmiDfKAUrinaKU9i1eCOY4LaszhsB2AMHN(xAgbzVkVIa8BkeiZ5Y0PMnZSO2undwJbb21nOzgE6FPzmigUSxkbYCUmnd)8epF0m8xX4bI8CziKgasJfsZHaR0kWdlpdzXAmiWoKgas5)t0)2YkWdlpdzpuz8saPSdPRbPllqk)FI(3w2ZfEfbesfqMZLzpuz8saPRGuZqAaiL)pr)Bl72fPa8BWw6czpuz8saPRGuZq6YcKY)NO)TL9CHxraHubK5Cz2dvgVeqk7q6AqAaiL)pr)Bl72fPa8BWw6czpuz8saPRG01G0aqkx1H0vqQCq6YcKY)NO)TL9CHxraHubK5Cz2dvgVeq6kiDninaKY)NO)TLD7Iua(nylDHShQmEjGu2H01G0aqkx1H0vq6Aq6YcKYvDiDfKgFiDzbsnK2BRXldq(EUvImKgNMHhItGGCUimfA2mRtnBMJV2undwJbb21nOzgE6FPzspcpa5HqrZWppXZhnd)vmEGipxgcPbGuUQBvMWqQjGuUQdPRibPYPz4H4eiiNlctHMnZ6uZM5MrBQMbRXGa76g0m8Zt88rZWvDRYegsnbKYvDiDfji1SMz4P)LMzo(uii)7Wk1PMnZnBTPAgVs8ojYPMXSMz4P)LMzteYRiGapYyLazoxMMbRXGa76g0PMnZMuTPAgSgdcSRBqZm80)sZyqmCzVucK5CzAg(5jE(Oz4VIXde55YqinaKY)NO)TLD7Iua(nylDHShQmEjGu2H01G0aqkx1HusqQCqAaiL8Hbbr8U1Sn9i8aKhcfinaKIfErHSPRGG8bXVriLDi1SMHhItGGCUimfA2mRtnBMxpTPAgSgdcSRBqZm80)sZyqmCzVucK5CzAg(5jE(Oz4VIXde55YqinaKIfErHSPRGG8bktyiLDivoinaKglKYvDRYegsnbKYvDiLDsqQziDzbsjFyqqeVBnBtpcpa5HqbsJtZWdXjqqoxeMcnBM1Po1m8oqGBTPA2mRnvZG1yqGDDdAg(5jE(OzAoKgCoFmiqR6t0bHLWcsdaPXcP8)j6FBzpx4veqivazoxM9qLXlbKYoKkhKUSaPnhs5FqSMkTYcD(uqACqAainwiT5qk)dI1uPTq(9e)1H0LfiL)pr)BlRXxyxsKaJdBThQmEjGu2Hu5G04G0LfiD7rQj4qLXlbKYoKkx81mdp9V0mEf8LHGWsyPtnBYPnvZG1yqGDDdAg(5jE(Oz2EKAcouz8saPRG0yHuZM0gHutaPNuH7)Iq7EYHaKVex1I1yqGDinEbPMLRrinoiDzbsnK2BRi)tbGZLQGP6GTFOT)TfKgasjJPnSewGufbTQEIG0JWZo80dIqAainwiT5qk)dI1uPTq(9e)1H0Lfi1qAVTgFHDjrcmoS1krgsJdsxwG0yHu()e9VTSEf8LHGWsybsve0Q6jcspcp7HkJxciDfKU9i1eCOY4LasJdsdaPgs7T14lSljsGXHTwjYq6YcKA8cbKgas3EKAcouz8saPSdPMBuZm80)sZKVexf8BqhNuvNA2wtBQMbRXGa76g0m8Zt88rZelKEJ3byqSs707cRxq6kiLfJpKUSaP34DageR0o9UWkrgsJdsdaP8)j6FBzpx4veqivazoxM9qLXlbKYoKIHrUuIG0vqinaKY)NO)TL1RGVmeewclqQIGwvprq6r4zpuz8saPRG0yHu5AesJbsLRrinEbPNuH7)IqRxbFz4jaDKWJutlwJbb2H04G0Lfi14fcinaKU9i1eCOY4Laszhsxl(AMHN(xAMwCi)La8BWFD80PMnwuBQMbRXGa76g0m8Zt88rZWFfJhiYZLHqAainwi9gVdWGyL2P3fwVG0vqQ5gH0Lfi9gVdWGyL2P3fwjYqACAMHN(xAM9GeEHar(kK1PMT4RnvZG1yqGDDdAg(5jE(OzUX7amiwPD6DH1liDfKUwJq6YcKEJ3byqSs707cReznZWt)lnZEiiWc8xhpDQzRz0MQzWAmiWUUbnd)8epF0mCvhsxrcsLdsdaPBpsnbhQmEjG0vqAZ0iKgasJfs5)t0)2YkY)ua4CPkyQoy7hA5QZfHciDfK2iKUSaP8)j6FBzf5FkaCUufmvhS9dThQmEjG0vqQ5gH04G0aqASqkzmTHLWcKQiOv1teKEeE2HNEqesxwGu()e9VTSEf8LHGWsybsve0Q6jcspcp7HkJxciDfKAUriDzbsdoNpgeOv9j6GWsybPXbPllqASqkx1H0vKGu5G0aq62JutWHkJxciLDsqAZ0iKgasJfsjJPnSewGufbRBvprq6r4zhE6briDzbs5)t0)2Y6vWxgcclHfivrqRQNii9i8ShQmEjG0vq62JutWHkJxcinoinaKglKY)NO)TLvK)PaW5svWuDW2p0YvNlcfq6kiTriDzbs5)t0)2YkY)ua4CPkyQoy7hApuz8saPRG0ThPMGdvgVeq6YcKAiT3wr(NcaNlvbt1bB)qRezinoinoiDzbs3EKAcouz8saPSdPMJVMz4P)LMX4lSljsGXHT6uZwZwBQMbRXGa76g0m8Zt88rZW)Ql5PL))19AsSd(9glHheTyngeyxZm80)sZiY)ua4CPkyQoy7hc2E4jrDQzZKQnvZG1yqGDDdAg(5jE(Oz4)t0)2YkY)ua4CPkyQoy7hA5QZfHciLeKkhKUSaPBpsnbhQmEjGu2Hu5AesxwG0yH0B8oadIvANExypuz8saPRGuZXhsxwG0yH0MdP8piwtLwzHoFkinaK2CiL)bXAQ0wi)EI)6qACqAainwinwi9gVdWGyL2P3fwVG0vqk)FI(3wwr(NcaNlvbt1bB)q7wIGaCixDUieKUccPllqAZH0B8oadIvANExyXWUifqACqAainwiL)pr)BlRxbFziiSewGufbTQEIG0JWZEOY4LasxbP8)j6FBzf5FkaCUufmvhS9dTBjccWHC15Iqq6kiKUSaPbNZhdc0Q(eDqyjSG04G04G0aqk)FI(3w2Tlsb43GT0fYEOY4LaszNeKUEqAaiLR6q6ksqQCqAaiL)pr)BlBRQFeEfb63e9fGSuXvThQmEjGu2jbPMLdsJtZm80)sZiY)ua4CPkyQoy7hQtnBRN2undwJbb21nOz4NN45JMH)bXAQ0kl05tbPbG0yHudP922Id5VeGFd(RJNvImKUSaPXcPBpsnbhQmEjGu2Hu()e9VTST4q(lb43G)64zpuz8saPllqk)FI(3w2wCi)La8BWFD8ShQmEjG0vqk)FI(3wwr(NcaNlvbt1bB)q7wIGaCixDUieKUccPXbPbGu()e9VTSBxKcWVbBPlK9qLXlbKYojiD9G0aqkx1H0vKGu5G0aqk)FI(3w2wv)i8kc0Vj6lazPIRApuz8saPStcsnlhKgNMz4P)LMrK)PaW5svWuDW2puNA2m3O2undwJbb21nOz4NN45JMH)bXAQ0wi)EI)6qAaiTJgs7T14lSljsGXHTGoAiT3wjYqAainwiLmM2Wsybsve0Q6jcspcp7WtpicPllqAW58XGaTQprhewcliDzbs5)t0)2Y6vWxgcclHfivrqRQNii9i8ShQmEjG0vqk)FI(3wwr(NcaNlvbt1bB)q7wIGaCixDUieKUccPllqk)FI(3wwVc(YqqyjSaPkcAv9ebPhHN9qLXlbKUcsxRrinonZWt)lnJi)tbGZLQGP6GTFOo1Sz2S2undwJbb21nOz4NN45JMHmM2Wsybsve0Q6jcspcp7WtpicPllqQXleqAaiD7rQj4qLXlbKYoKkxJAMHN(xAgVe8tkhdceysKMkLuaDmOZrDQzZSCAt1myngeyx3GMHFEINpAgYyAdlHfivrqRQNii9i8Sdp9GiKUSaPgVqaPbG0ThPMGdvgVeqk7qQCnQzgE6FPzAVjvf5xOo1SzEnTPAgSgdcSRBqZWppXZhndzmTHLWcKQiOv1teKEeE2HNEqesxwGuJxiG0aq62JutWHkJxciLDivUg1mdp9V0mret3N8pbWy6rOo1SzMf1MQzWAmiWUUbnZWt)lnt)WPV9dbbrHaj0m8Zt88rZ0Cin4C(yqG2Wsyb(cijqqEEjdtiDzbs5)t0)2Y6vWxgcclHfivrqRQNii9i8ShQmEjG0vqQCncPbGuYyAdlHfivrqRQNii9i8ShQmEjGu2Hu5AesxwG0GZ5JbbAvFIoiSewAMAuqnt)WPV9dbbrHaj0PMnZXxBQMbRXGa76g0mdp9V0mc1P)Tr3iidYprfnd)8epF0mKX0gwclqQIGwvprq6r4zhE6briDzbsnEHasdaPBpsnbhQmEjGu2Hu5AesxwG0MdPNuH7)IqRxbFz4jaDKWJutlwJbb21m1OGAgH60)2OBeKb5NOIo1SzUz0MQzWAmiWUUbnd)8epF0mnhsdoNpgeOnSewGVasceKNxYWesxwGu()e9VTSEf8LHGWsybsve0Q6jcspcp7HkJxciDfKkxJq6YcKgCoFmiqR6t0bHLWsZm80)sZijqGNOIqNA2m3S1MQzWAmiWUUbnd)8epF0mBpsnbhQmEjG0vq661iKUSaPKX0gwclqQIGwvprq6r4zhE6briDzbsdoNpgeOv9j6GWsybPllqQXleqAaiD7rQj4qLXlbKYoKAUz0mdp9V0m5lXvb)giBoLrNA2mBs1MQzWAmiWUUbnd)8epF0m8)j6FBz9k4ldbHLWcKQiOv1teKEeE2dvgVeq6kiDTgH0Lfin4C(yqGw1NOdclHfKUSaPgVqaPbG0ThPMGdvgVeqk7qQCnQzgE6FPzmi(Vd2sxiDQzZ86PnvZG1yqGDDdAg(5jE(Oz4)t0)2Y6vWxgcclHfivrqRQNii9i8ShQmEjG0vq6AncPllqAW58XGaTQprhewcliDzbsnEHasdaPBpsnbhQmEjGu2HuZXxZm80)sZyGNapzEfPtnBY1O2unZWt)lndHhPMcaluQhPGvQzWAmiWUUbDQztoZAt1myngeyx3GMHFEINpAg()e9VTSEf8LHGWsybsve0Q6jcspcp7HkJxciDfKUwJq6YcKgCoFmiqR6t0bHLWcsxwGuJxiG0aq62JutWHkJxciLDi1CJAMHN(xAMTFObX)DDQzto50MQzWAmiWUUbnd)8epF0m8)j6FBz9k4ldbHLWcKQiOv1teKEeE2dvgVeq6kiDTgH0Lfin4C(yqGw1NOdclHfKUSaPgVqaPbG0ThPMGdvgVeqk7qQCnQzgE6FPzMIJI8gcaFii0PMn5wtBQMbRXGa76g0m8Zt88rZyiT3wr(NcaNlvbt1bB)qB)BlnZWt)lnJXeb(nipNltOtnBYXIAt1myngeyx3GMHFEINpAgXlry4v3swsKseiapjYP)LfRXGa7qAai1qAVTI8pfaoxQcMQd2(H2(3wqAaiTJgs7T14lSljsGXHTGoAiT32(3wqAai1qAVTgFHDjrcmoS12)2sZm80)sZSjqHk)MDQtDQz64EKisTPA2mRnvZm80)sZiiJZbuNQde55YqndwJbb21nOtnBYPnvZG1yqGDDdAMNSMrGPMz4P)LMj4C(yqGAMGdHeQz4)t0)2Y6vWxgcclHfivrqRQNii9i8ShQmEjG0vq62JutWHkJxciDzbs3EKAcouz8saPMas5)t0)2Y6vWxgcclHfivrqRQNii9i8ShQmEjGu2HuZY1iKgasJfsJfsZHaR0kWdlpdzXAmiWoKgas3EKAcouz8saPRGu()e9VTSc8WYZq2dvgVeqAaiL)pr)BlRapS8mK9qLXlbKUcsn3iKghKUSaPXcP8)j6FBzf5FkaCUufmvhS9dTBjccWHC15Iqq6kiKYoKU9i1eCOY4LasdaP8)j6FBzf5FkaCUufmvhS9dTBjccWHC15Iqq6kiKUcsnhFinoiDzbsJfs5)t0)2YkY)ua4CPkyQoy7hA5QZfHciLeK2iKgas5)t0)2YkY)ua4CPkyQoy7hApuz8saPSdPBpsnbhQmEjG04G040mbNduJcQzuFIoiSew6uZ2AAt1myngeyx3GMHFEINpAMyHudP92kWdlpdzLidPllqQH0EBf5FkaCUufmvhS9dTsKH04G0aqkzmTHLWcKQiOv1teKEeE2HNEqesxwGuJxiG0aq62JutWHkJxciLDsqAZ0OMz4P)LMH8N(x6uZglQnvZG1yqGDDdAg(5jE(OzmK2BRapS8mKvISMrKNZtnBM1mdp9V0m8HGam80)cq4IuZq4IeuJcQze4HLNH0PMT4RnvZG1yqGDDdAg(5jE(OzmK2BBloK)sa(n4VoEwjYAgrEop1SzwZm80)sZWhccWWt)laHlsndHlsqnkOMPfhYFja)g8xhpDQzRz0MQzWAmiWUUbnd)8epF0mPRGqk7qklcPbGuUQdPSdPXhsdaPnhsjJPnSewGufbTQEIG0JWZo80dIAgrEop1SzwZm80)sZWhccWWt)laHlsndHlsqnkOM5jJfE6uZwZwBQMbRXGa76g0mdp9V0mBxKGFdsve0Q6jcspcpnd)8epF0mCv3QmHHutaPCvhsxrcsxdsdaPXcPyHxuiB6kiiFGYegszhsndPllqkw4ffYMUccYhOmHHu2HuwesdaP8)j6FBz3UifGFd2sxi7HkJxciLDi1Sn(q6YcKY)NO)TLTfhYFja)g8xhp7HkJxciLDivoinoinaK2CiTJgs7T14lSljsGXHTGoAiT3wjYAgEiobcY5IWuOzZSo1Szs1MQzWAmiWUUbnd)8epF0mCv3QmHHutaPCvhsxrcsndPbG0yHuSWlkKnDfeKpqzcdPSdPMH0LfiL)pr)BlRapS8mK9qLXlbKYoKkhKUSaPyHxuiB6kiiFGYegszhszrinaKY)NO)TLD7Iua(nylDHShQmEjGu2HuZ24dPllqk)FI(3w2wCi)La8BWFD8ShQmEjGu2Hu5G04G0aqAZHudP92A8f2LejW4WwReznZWt)lndgMmsauNtrNA2wpTPAgSgdcSRBqZm80)sZKEeEaYdHIMHFEINpAg(Ry8arEUmesdaPCv3QmHHutaPCvhsxrcsLdsdaPXcPyHxuiB6kiiFGYegszhsndPllqk)FI(3wwbEy5zi7HkJxciLDivoiDzbsXcVOq20vqq(aLjmKYoKYIqAaiL)pr)Bl72fPa8BWw6czpuz8saPSdPMTXhsxwGu()e9VTST4q(lb43G)64zpuz8saPSdPYbPXbPbG0MdPD0qAVTgFHDjrcmoSf0rdP92krwZWdXjqqoxeMcnBM1PMnZnQnvZG1yqGDDdAg(5jE(OzAoKMdbwPvGhwEgYI1yqGDnJipNNA2mRzgE6FPz4dbby4P)fGWfPMHWfjOgfuZW7abU1PMnZM1MQzWAmiWUUbnd)8epF0m5qGvAf4HLNHSyngeyxZiYZ5PMnZAMHN(xAg(qqagE6FbiCrQziCrcQrb1m8oqGhwEgsNA2mlN2undwJbb21nOz4NN45JMz4PhebyHkokGu2H010mI8CEQzZSMz4P)LMHpeeGHN(xacxKAgcxKGAuqnJi1PMnZRPnvZG1yqGDDdAg(5jE(OzgE6brawOIJciDfjiDnnJipNNA2mRzgE6FPz4dbby4P)fGWfPMHWfjOgfuZmpQtDQziFi)vmMuBQMnZAt1mdp9V0mgFMeyhSjMqyV1Riq(H9sZG1yqGDDd6uZMCAt1myngeyx3GM5jRzeyQzgE6FPzcoNpgeOMj4qiHAg0Ki5KjJDRxc(jLJbbcmjstLskGog05iKUSaPOjrYjtg72iIP7t(Naym9iesxwGu0Ki5KjJDB7nPQi)cH0LfifnjsozYy3(bXJRoxe2bt5kdWyYeVqq6YcKIMejNmzSBfQt)BJUrqgKFIkAMGZbQrb1mHLWc8fqsGG88sgM6uZ2AAt1mdp9V0mBcuOYVzNAgSgdcSRBqNA2yrTPAgSgdcSRBqZWppXZhntZH0CiWkTc8WYZqwSgdcSdPllqAZH0CiWkTBxKGFdsve0Q6jcspcplwJbb21mdp9V0mCvhyiDIuNA2IV2undwJbb21nOz4NN45JMP5qAoeyLwSWlYBw8kcGeEy8SyngeyxZm80)sZWvDq7ee1Po1mZJAt1SzwBQMz4P)LMPv1pcVIa9BI(cqwQ4QAgSgdcSRBqNA2KtBQMbRXGa76g0m8Zt88rZWvDRYegsnbKYvDiDfjivoinaKIfErHSPRGG8bktyiDfKkhKUSaPCv3QmHHutaPCvhsxrcszrnZWt)lndw4f5nlEfbqcpSF6uZ2AAt1myngeyx3GMHFEINpAg(Ry8arEUmesdaPXcPgs7TTpfhb)gWvDwOBLidPllqAhnK2BRXxyxsKaJdBbD0qAVTsKH040mdp9V0mcYEvEfb43uiqMZLPtnBSO2undwJbb21nOz4NN45JMbl8Icztxbb5duMWq6kifdJCPebPRGq6YcKYvDRYegsnbKYvDiLDsqQznZWt)lnZ2fPa8BWw6cPtnBXxBQMbRXGa76g0mdp9V0mNl8kciKkGmNltZWppXZhntSqAoeyL2wv)i8kc0Vj6lazPIRAXAmiWoKgas5)t0)2YEUWRiGqQaYCUmBx6M0)csxbP8)j6FBzBv9JWRiq)MOVaKLkUQ9qLXlbKgdKYIqACqAainwiL)pr)Bl72fPa8BWw6czpuz8saPRG01G0LfiLR6q6ksqA8H040m8qCceKZfHPqZMzDQzRz0MQzWAmiWUUbnd)8epF0mgs7T9KeQEfbyHthbTE1T9VT0mdp9V0mNKq1RialC6iO1RUo1S1S1MQzWAmiWUUbnd)8epF0mCv3QmHHutaPCvhsxrcsnRzgE6FPzWWKrcG6Ck6uZMjvBQMbRXGa76g0mdp9V0mBxKGFdsve0Q6jcspcpnd)8epF0mCv3QmHHutaPCvhsxrcsxtZWdXjqqoxeMcnBM1PMT1tBQMbRXGa76g0m8Zt88rZWvDRYegsnbKYvDiDfjivonZWt)lndx1bgsNi1PMnZnQnvZG1yqGDDdAg(5jE(OzmK2BBQIauHmE)ja8H8W98pRihUmiDfKAE9G0aqkw4ffYMUccYhOmHH0vqkgg5sjcsxbHutaPMH0aqk)FI(3w2Tlsb43GT0fYEOY4LasxbPyyKlLiiDfuZm80)sZWVHlJWRialC6iGWJuZYRiDQzZSzTPAgSgdcSRBqZm80)sZKEeEaYdHIMHFEINpAgUQBvMWqQjGuUQdPRibPYbPbG0yH0MdP5qGvAv9eWFfJ3I1yqGDiDzbs5VIXde55YqinondpeNab5Cryk0SzwNA2mlN2undwJbb21nOz4NN45JMHR6wLjmKAciLR6q6ksqQznZWt)lnZC8Pqq(3HvQtnBMxtBQMbRXGa76g0m8Zt88rZWFfJhiYZLHqAainwiL)pr)BlRXxyxsKaJdBThQmEjG0vqQCq6YcK2CiL)bXAQ0wi)EI)6qACqAainwiLR6q6ksqA8H0LfiL)pr)Bl72fPa8BWw6czpuz8saPRG0MbsxwGu()e9VTSBxKcWVbBPlK9qLXlbKUcsxdsdaPCvhsxrcsxdsdaPyHxuiB6kiiFq8BeszhsndPllqkw4ffYMUccYhOmHHu2jbPXcPRbPXaPRbPXliL)pr)Bl72fPa8BWw6czpuz8saPSdPXhsJdsxwGudP92kY)ua4CPkyQoy7hALidPXPzgE6FPzeK9Q8kcWVPqGmNltNA2mZIAt1myngeyx3GMHFEINpAg(Ry8arEUmuZm80)sZWvDq7ee1PMnZXxBQMbRXGa76g0mdp9V0mBIqEfbe4rgReiZ5Y0m8Zt88rZyiT3wJxgG89CB)BlnJxjENe5uZywNA2m3mAt1myngeyx3GMz4P)LMXGy4YEPeiZ5Y0m8Zt88rZWFfJhiYZLHqAainwi1qAVTgVma575wjYq6YcKMdbwPv1ta)vmElwJbb2H0aqk5ddcI4DRzB6r4bipekqAaiLR6qkjivoinaKY)NO)TLD7Iua(nylDHShQmEjGu2H01G0LfiLR6wLjmKAciLR6qk7KGuZqAaiL8Hbbr8U1Svq2RYRia)McbYCUminaKIfErHSPRGG8bktyiLDiDninondpeNab5Cryk0SzwN6uNAMG4j8V0SjxJYz2Sz5wtZ0ox5vKqZSUJhBwzlEIT1L1bsHutvri1vi)xcP7)Guw2Id5VeGFd(RJhlH0dnjs(HDiv8kiKos5Rmj2HuU6urOWczLf4fcPYToq66)vq8sSdPSmhcSsRjZsinFiLL5qGvAnzlwJbb2zjKojKgpVUYcG0ynhoolKvwGxiKU26aPR)xbXlXoKYYCiWkTMmlH08HuwMdbwP1KTyngeyNLq6KqA886klasJ1C44SqwzbEHqQCnUoq66)vq8sSdPSmhcSsRjZsinFiLL5qGvAnzlwJbb2zjKgR5WXzHSczDDhp2SYw8eBRlRdKcPMQIqQRq(Ves3)bPSuGhwEgILq6HMej)WoKkEfeshP8vMe7qkxDQiuyHSYc8cHuZnUoq66)vq8sSdPSmhcSsRjZsinFiLL5qGvAnzlwJbb2zjKojKgpVUYcG0ynhoolKviRR74XMv2INyBDzDGui1uvesDfY)Lq6(piLL8oqGhwEgILq6HMej)WoKkEfeshP8vMe7qkxDQiuyHSYc8cH01BDG01)RG4Lyhsz5jv4(Vi0AYSesZhsz5jv4(Vi0AYwSgdcSZsinwZHJZczLf4fcPMzX1bsx)VcIxIDiLLNuH7)IqRjZsinFiLLNuH7)IqRjBXAmiWolH0jH0451vwaKgR5WXzHSYc8cHu5mVoq66)vq8sSdPSu8segE1TMmlH08HuwkEjcdV6wt2I1yqGDwcPXAoCCwiRqwx3XJnRSfpX26Y6aPqQPQiK6kK)lH09FqklfjlH0dnjs(HDiv8kiKos5Rmj2HuU6urOWczLf4fcPS46aPR)xbXlXoKYYCiWkTMmlH08HuwMdbwP1KTyngeyNLqASMdhNfYklWlesBM1bsx)VcIxIDiLL5qGvAnzwcP5dPSmhcSsRjBXAmiWolH0ynhoolKvwGxiKAMfxhiD9)kiEj2HuwMdbwP1KzjKMpKYYCiWkTMSfRXGa7SesJ1C44SqwHSUUJhBwzlEIT1L1bsHutvri1vi)xcP7)GuwY7abUzjKEOjrYpSdPIxbH0rkFLjXoKYvNkcfwiRSaVqivU1bsx)VcIxIDiLLNuH7)IqRjZsinFiLLNuH7)IqRjBXAmiWolH0ynhoolKvwGxiKU26aPR)xbXlXoKYYtQW9FrO1KzjKMpKYYtQW9FrO1KTyngeyNLqASMdhNfYklWlesnh)1bsx)VcIxIDiLLNuH7)IqRjZsinFiLLNuH7)IqRjBXAmiWolH0jH0451vwaKgR5WXzHSYc8cHu5yX1bsx)VcIxIDiLLIxIWWRU1KzjKMpKYsXlry4v3AYwSgdcSZsinwZHJZczfY66oESzLT4j2wxwhifsnvfHuxH8FjKU)dszzh3JerYsi9qtIKFyhsfVccPJu(ktIDiLRovekSqwzbEHqQCRdKU(FfeVe7qklZHaR0AYSesZhszzoeyLwt2I1yqGDwcPXAoCCwiRSaVqi1CJRdKU(FfeVe7qklZHaR0AYSesZhszzoeyLwt2I1yqGDwcPtcPXZRRSainwZHJZczLf4fcPMnVoq66)vq8sSdPSmhcSsRjZsinFiLL5qGvAnzlwJbb2zjKojKgpVUYcG0ynhoolKviRR74XMv2INyBDzDGui1uvesDfY)Lq6(piLLZJSesp0Ki5h2HuXRGq6iLVYKyhs5QtfHclKvwGxiKg)1bsx)VcIxIDiLL5qGvAnzwcP5dPSmhcSsRjBXAmiWolH0ynhoolKvwGxiKA286aPR)xbXlXoKYYCiWkTMmlH08HuwMdbwP1KTyngeyNLqASMdhNfYklWlesn3mRdKU(FfeVe7qklZHaR0AYSesZhszzoeyLwt2I1yqGDwcPXAoCCwiRqwJNui)xIDiD9G0HN(xqkHlsHfYQMH89BNa1mX74nKUU9Q3oeYWdsJh(lzqwJ3XBiLTpiQyGhKUwJYdPY1OCMHScznEhVH01xDUiuSoqwJ3XBi1eqQPT4idsJhWfPas)nKgpG0fcs9kX7KiNqkXh5ClK14D8gsnbKAAloYGugYEvEfbPR)nfcPXd6CzqkXh5ClK14D8gsnbKgp27qQXleBpsnHuUkYLjG08HuLPcbPRF8qqkw55OWczfYA8oEdPXZHrUuIDi1a3)Hqk)vmMesnWiVewinEKZrYPasRVmH6CkBjciD4P)Las)IiKfY6Wt)lHL8H8xXyYyi1KXNjb2bBIje2B9kcKFyVGSo80)syjFi)vmMmgsnfCoFmiq5RrbjfwclWxajbcYZlzyk)tMKat5doesij0Ki5KjJDRxc(jLJbbcmjstLskGog054YcAsKCYKXUnIy6(K)jagtpcxwqtIKtMm2TT3KQI8lCzbnjsozYy3(bXJRoxe2bt5kdWyYeVqllOjrYjtg7wH60)2OBeKb5NOcK1HN(xcl5d5VIXKXqQPnbku53StiRdp9VewYhYFfJjJHutCvhyiDIuEFtQ55qGvAf4HLNHSyngeyFzP55qGvA3Uib)gKQiOv1teKEeEwSgdcSdzD4P)LWs(q(RymzmKAIR6G2jikVVj18CiWkTyHxK3S4veaj8W4zXAmiWoKviRX74nKgphg5sj2HumiEHG00vqinvriD45FqQlG0j44eJbbAHSo80)sqsqgNdOovhiYZLHqwhE6FjIHutbNZhdcu(AuqsQprhewcl5FYKeykFWHqcjX)NO)TL1RGVmeewclqQIGwvprq6r4zpuz8sSA7rQj4qLXlXYY2JutWHkJxctW)NO)TL1RGVmeewclqQIGwvprq6r4zpuz8sWUz5AmqSXMdbwPvGhwEgkW2JutWHkJxIv8)j6FBzf4HLNHShQmEjcW)NO)TLvGhwEgYEOY4LyL5gJBzjw()e9VTSI8pfaoxQcMQd2(H2Tebb4qU6CriiDfK9ThPMGdvgVeb4)t0)2YkY)ua4CPkyQoy7hA3seeGd5QZfHG0vWvMJFCllXY)NO)TLvK)PaW5svWuDW2p0YvNlcfKAma)FI(3wwr(NcaNlvbt1bB)q7HkJxc23EKAcouz8sexCqwhE6FjIHutK)0)sEFtkwdP92kWdlpdzLiVSyiT3wr(NcaNlvbt1bB)qRe54cqgtByjSaPkcAv9ebPhHND4PhexwmEHiW2JutWHkJxc2j1mnczD4P)LigsnXhccWWt)laHls5RrbjjWdlpdjVipNNKmlVVjziT3wbEy5ziReziRdp9VeXqQj(qqagE6FbiCrkFnkiPwCi)La8BWFD8KxKNZtsML33KmK2BBloK)sa(n4VoEwjYqwhE6FjIHut8HGam80)cq4Iu(AuqspzSWtErEopjzwEFtkDfKDwmax1zp(bAozmTHLWcKQiOv1teKEeE2HNEqeY6Wt)lrmKAA7Ie8BqQIGwvprq6r4jppeNab5CrykizwEFtIR6wLjSj4Q(ksRfiwSWlkKnDfeKpqzcZU5LfSWlkKnDfeKpqzcZolgG)pr)Bl72fPa8BWw6czpuz8sWUzB8xw4)t0)2Y2Id5VeGFd(RJN9qLXlb7YfxGM3rdP92A8f2LejW4WwqhnK2BReziRdp9VeXqQjmmzKaOoNI8(Mex1TktytWv9vKmhiwSWlkKnDfeKpqzcZU5Lf()e9VTSc8WYZq2dvgVeSl3Ycw4ffYMUccYhOmHzNfdW)NO)TLD7Iua(nylDHShQmEjy3Sn(ll8)j6FBzBXH8xcWVb)1XZEOY4LGD5IlqZnK2BRXxyxsKaJdBTsKHSo80)sedPMspcpa5HqrEEiobcY5IWuqYS8(Me)vmEGipxggGR6wLjSj4Q(ksYfiwSWlkKnDfeKpqzcZU5Lf()e9VTSc8WYZq2dvgVeSl3Ycw4ffYMUccYhOmHzNfdW)NO)TLD7Iua(nylDHShQmEjy3Sn(ll8)j6FBzBXH8xcWVb)1XZEOY4LGD5IlqZ7OH0EBn(c7sIeyCylOJgs7TvImK1HN(xIyi1eFiiadp9VaeUiLVgfKeVde4wErEopjzwEFtQ55qGvAf4HLNHGSo80)sedPM4dbby4P)fGWfP81OGK4DGapS8mK8I8CEsYS8(MuoeyLwbEy5ziiRdp9VeXqQj(qqagE6FbiCrkFnkijrkVipNNKmlVVjn80dIaSqfhfSVgK1HN(xIyi1eFiiadp9VaeUiLVgfK08O8I8CEsYS8(M0WtpicWcvCuSI0AqwHSo80)syNhj1Q6hHxrG(nrFbilvCviRdp9Ve25Xyi1ew4f5nlEfbqcpSFY7BsCv3QmHnbx1xrsUayHxuiB6kiiFGYeELCllCv3QmHnbx1xrIfHSo80)syNhJHutcYEvEfb43uiqMZLjVVjXFfJhiYZLHbI1qAVT9P4i43aUQZcDRe5LLoAiT3wJVWUKibgh2c6OH0EBLihhK1HN(xc78ymKAA7Iua(nylDHK33KWcVOq20vqq(aLj8kmmYLseKUcUSWvDRYe2eCvNDsMHSo80)syNhJHutNl8kciKkGmNltEEiobcY5IWuqYS8(MuS5qGvABv9JWRiq)MOVaKLkUAa()e9VTSNl8kciKkGmNlZ2LUj9VwX)NO)TLTv1pcVIa9BI(cqwQ4Q2dvgVeXWIXfiw()e9VTSBxKcWVbBPlK9qLXlXQ1ww4Q(ksXpoiRdp9Ve25Xyi10jju9kcWcNocA9QlVVjziT32tsO6veGfoDe06v32)2cY6Wt)lHDEmgsnHHjJea15uK33K4QUvzcBcUQVIKziRdp9Ve25Xyi102fj43GufbTQEIG0JWtEEiobcY5IWuqYS8(Mex1TktytWv9vKwdY6Wt)lHDEmgsnXvDGH0js59njUQBvMWMGR6RijhK1HN(xc78ymKAIFdxgHxraw40raHhPMLxrY7Bsgs7TnvraQqgV)ea(qE4E(NvKdx2kZRxaSWlkKnDfeKpqzcVcdJCPebPRGMWCa()e9VTSBxKcWVbBPlK9qLXlXkmmYLseKUcczD4P)LWopgdPMspcpa5HqrEEiobcY5IWuqYS8(Mex1TktytWv9vKKlqSnphcSsRQNa(Ry8ll8xX4bI8CzyCqwhE6FjSZJXqQP54tHG8VdRuEFtIR6wLjSj4Q(ksMHSo80)syNhJHutcYEvEfb43uiqMZLjVVjXFfJhiYZLHbIL)pr)BlRXxyxsKaJdBThQmEjwj3YsZ5FqSMkTfYVN4VECbILR6Rif)Lf()e9VTSBxKcWVbBPlK9qLXlXQMzzH)pr)Bl72fPa8BWw6czpuz8sSATaCvFfP1cGfErHSPRGG8bXVr2nVSGfErHSPRGG8bkty2jf7AXSw8I)pr)Bl72fPa8BWw6czpuz8sWE8JBzXqAVTI8pfaoxQcMQd2(HwjYXbzD4P)LWopgdPM4QoODcIY7Bs8xX4bI8CziK1HN(xc78ymKAAteYRiGapYyLazoxM8(MKH0EBnEzaY3ZT9VTK3ReVtICsYmK1HN(xc78ymKAYGy4YEPeiZ5YKNhItGGCUimfKmlVVjXFfJhiYZLHbI1qAVTgVma575wjYll5qGvAv9eWFfJpa5ddcI4DRzB6r4bipekb4Qoj5cW)NO)TLD7Iua(nylDHShQmEjyFTLfUQBvMWMGR6StYCaYhgeeX7wZwbzVkVIa8BkeiZ5YcGfErHSPRGG8bkty2xloiRqwhE6FjS8oqGBsEf8LHGWsybsve0Q6jcspcp59nPMhCoFmiqR6t0bHLWkqS8)j6FBzpx4veqivazoxM9qLXlb7YTS0C(heRPsRSqNpvCbIT58piwtL2c53t8xFzH)pr)BlRXxyxsKaJdBThQmEjyxU4ww2EKAcouz8sWUCXhY6Wt)lHL3bcChdPMYxIRc(nOJtQkVVjT9i1eCOY4LyvSMnPnAItQW9FrODp5qaYxIRgVmlxJXTSyiT3wr(NcaNlvbt1bB)qB)BRaKX0gwclqQIGwvprq6r4zhE6bXaX2C(heRPsBH87j(RVSyiT3wJVWUKibgh2ALih3YsS8)j6FBz9k4ldbHLWcKQiOv1teKEeE2dvgVeR2EKAcouz8sexadP92A8f2LejW4WwRe5LfJxicS9i1eCOY4LGDZnczD4P)LWY7abUJHutT4q(lb43G)64jVVjf7nEhGbXkTtVlSETIfJ)YYnEhGbXkTtVlSsKJla)FI(3w2ZfEfbesfqMZLzpuz8sWogg5sjcsxbdW)NO)TL1RGVmeewclqQIGwvprq6r4zpuz8sSkw5Amg5AmEDsfU)lcTEf8LHNa0rcpsnJBzX4fIaBpsnbhQmEjyFT4dzD4P)LWY7abUJHut7bj8cbI8vilVVjXFfJhiYZLHbI9gVdWGyL2P3fwVwzUXLLB8oadIvANExyLihhK1HN(xclVde4ogsnThccSa)1XtEFt6gVdWGyL2P3fwVwTwJll34DageR0o9UWkrgY6Wt)lHL3bcChdPMm(c7sIeyCyR8(Mex1xrsUaBpsnbhQmEjw1mngiw()e9VTSI8pfaoxQcMQd2(HwU6CrOyvJll8)j6FBzf5FkaCUufmvhS9dThQmEjwzUX4celzmTHLWcKQiOv1teKEeE2HNEqCzH)pr)BlRxbFziiSewGufbTQEIG0JWZEOY4LyL5gxwcoNpgeOv9j6GWsyf3YsSCvFfj5cS9i1eCOY4LGDsntJbILmM2WsybsveSUv9ebPhHND4Phexw4)t0)2Y6vWxgcclHfivrqRQNii9i8ShQmEjwT9i1eCOY4LiUaXY)NO)TLvK)PaW5svWuDW2p0YvNlcfRACzH)pr)BlRi)tbGZLQGP6GTFO9qLXlXQThPMGdvgVellgs7TvK)PaW5svWuDW2p0kroU4ww2EKAcouz8sWU54dzD4P)LWY7abUJHutI8pfaoxQcMQd2(HGThEsuEFtI)vxYtl))R71Kyh87nwcpiAXAmiWoK1HN(xclVde4ogsnjY)ua4CPkyQoy7hkVVjX)NO)TLvK)PaW5svWuDW2p0YvNlcfKKBzz7rQj4qLXlb7Y14YsS34DageR0o9UWEOY4LyL54VSeBZ5FqSMkTYcD(ubAo)dI1uPTq(9e)1JlqSXEJ3byqSs707cRxR4)t0)2YkY)ua4CPkyQoy7hA3seeGd5QZfHG0vWLLMFJ3byqSs707clg2fPiUaXY)NO)TL1RGVmeewclqQIGwvprq6r4zpuz8sSI)pr)BlRi)tbGZLQGP6GTFODlrqaoKRoxecsxbxwcoNpgeOv9j6GWsyfxCb4)t0)2YUDrka)gSLUq2dvgVeStA9cWv9vKKla)FI(3w2wv)i8kc0Vj6lazPIRApuz8sWojZYfhK1HN(xclVde4ogsnjY)ua4CPkyQoy7hkVVjX)GynvALf68PceRH0EBBXH8xcWVb)1XZkrEzj2ThPMGdvgVeSZ)NO)TLTfhYFja)g8xhp7HkJxILf()e9VTST4q(lb43G)64zpuz8sSI)pr)BlRi)tbGZLQGP6GTFODlrqaoKRoxecsxbJla)FI(3w2Tlsb43GT0fYEOY4LGDsRxaUQVIKCb4)t0)2Y2Q6hHxrG(nrFbilvCv7HkJxc2jzwU4GSo80)sy5DGa3XqQjr(NcaNlvbt1bB)q59nj(heRPsBH87j(RhOJgs7T14lSljsGXHTGoAiT3wjYbILmM2Wsybsve0Q6jcspcp7WtpiUSeCoFmiqR6t0bHLWAzH)pr)BlRxbFziiSewGufbTQEIG0JWZEOY4Lyf)FI(3wwr(NcaNlvbt1bB)q7wIGaCixDUieKUcUSW)NO)TL1RGVmeewclqQIGwvprq6r4zpuz8sSATgJdY6Wt)lHL3bcChdPM8sWpPCmiqGjrAQusb0XGohL33KiJPnSewGufbTQEIG0JWZo80dIllgVqey7rQj4qLXlb7Y1iK1HN(xclVde4ogsn1EtQkYVq59njYyAdlHfivrqRQNii9i8Sdp9G4YIXleb2EKAcouz8sWUCnczD4P)LWY7abUJHutret3N8pbWy6rO8(MezmTHLWcKQiOv1teKEeE2HNEqCzX4fIaBpsnbhQmEjyxUgHSo80)sy5DGa3XqQjjbc8evKVgfKu)WPV9dbbrHajK33KAEW58XGaTHLWc8fqsGG88sgMll8)j6FBz9k4ldbHLWcKQiOv1teKEeE2dvgVeRKRXaKX0gwclqQIGwvprq6r4zpuz8sWUCnUSeCoFmiqR6t0bHLWcY6Wt)lHL3bcChdPMKeiWtur(Auqsc1P)Tr3iidYprf59njYyAdlHfivrqRQNii9i8Sdp9G4YIXleb2EKAcouz8sWUCnUS08tQW9FrO1RGVm8eGos4rQjK1HN(xclVde4ogsnjjqGNOIqEFtQ5bNZhdc0gwclWxajbcYZlzyUSW)NO)TL1RGVmeewclqQIGwvprq6r4zpuz8sSsUgxwcoNpgeOv9j6GWsybzD4P)LWY7abUJHut5lXvb)giBoLrEFtA7rQj4qLXlXQ1RXLfYyAdlHfivrqRQNii9i8Sdp9G4YsW58XGaTQprhewcRLfJxicS9i1eCOY4LGDZndK1HN(xclVde4ogsnzq8FhSLUqY7Bs8)j6FBz9k4ldbHLWcKQiOv1teKEeE2dvgVeRwRXLLGZ5JbbAvFIoiSewllgVqey7rQj4qLXlb7Y1iK1HN(xclVde4ogsnzGNapzEfjVVjX)NO)TL1RGVmeewclqQIGwvprq6r4zpuz8sSATgxwcoNpgeOv9j6GWsyTSy8crGThPMGdvgVeSBo(qwhE6FjS8oqG7yi1eHhPMcaluQhPGvczD4P)LWY7abUJHutB)qdI)7Y7Bs8)j6FBz9k4ldbHLWcKQiOv1teKEeE2dvgVeRwRXLLGZ5JbbAvFIoiSewllgVqey7rQj4qLXlb7MBeY6Wt)lHL3bcChdPMMIJI8gcaFiiK33K4)t0)2Y6vWxgcclHfivrqRQNii9i8ShQmEjwTwJllbNZhdc0Q(eDqyjSwwmEHiW2JutWHkJxc2LRriRdp9VewEhiWDmKAYyIa)gKNZLjK33KmK2BRi)tbGZLQGP6GTFOT)TfK1HN(xclVde4ogsnTjqHk)MDkVVjjEjcdV6wYsIuIab4jro9VcyiT3wr(NcaNlvbt1bB)qB)BRaD0qAVTgFHDjrcmoSf0rdP922)2kGH0EBn(c7sIeyCyRT)TfKviRdp9VewEhiWdlpdrk4C(yqGYxJcssGhwEgcyiDIu(NmjbMYhCiKqs8)j6FBzf4HLNHShQmEjy38YczmTHLWcKQiOv1teKEeE2HNEqma)FI(3wwbEy5zi7HkJxIvR14YIXleb2EKAcouz8sWUCnczD4P)LWY7abEy5zOyi1KxbFziiSewGufbTQEIG0JWtEFtQ5bNZhdc0Q(eDqyjSwwmEHiW2JutWHkJxc2Ll(qwhE6FjS8oqGhwEgkgsnzq8FhSLUqY7BsbNZhdc0kWdlpdbmKorczD4P)LWY7abEy5zOyi1KbEc8K5vK8(MuW58XGaTc8WYZqadPtKqwhE6FjS8oqGhwEgkgsnr4rQPaWcL6rkyLqwhE6FjS8oqGhwEgkgsnT9dni(VlVVjfCoFmiqRapS8meWq6ejK1HN(xclVde4HLNHIHuttXrrEdbGpeeY7BsbNZhdc0kWdlpdbmKorczD4P)LWY7abEy5zOyi1KXeb(nipNltiVVjfCoFmiqRapS8meWq6ejK1HN(xclVde4HLNHIHut5lXvb)g0XjvL33K2EKAcouz8sSkwZM0gnXjv4(Vi0UNCia5lXvJxMLRX4wwiJPnSewGufbTQEIG0JWZo80dIbIT58piwtL2c53t8xFzXqAVTgFHDjrcmoS1kroULLy5)t0)2Y6vWxgcclHfivrqRQNii9i8ShQmEjwT9i1eCOY4LiUags7T14lSljsGXHTwjYllgVqey7rQj4qLXlb7MBeY6Wt)lHL3bc8WYZqXqQPwCi)La8BWFD8K33K4)t0)2YEUWRiGqQaYCUm7HkJxc2XWixkrq6kiK1HN(xclVde4HLNHIHutEj4NuogeiWKinvkPa6yqNJY7BsbNZhdc0kWdlpdbmKorczD4P)LWY7abEy5zOyi1u7nPQi)cL33KcoNpgeOvGhwEgcyiDIeY6Wt)lHL3bc8WYZqXqQPiIP7t(Naym9iuEFtk4C(yqGwbEy5ziGH0jsiRdp9VewEhiWdlpdfdPMKeiWtur(Auqsc1P)Tr3iidYprf59njYyAdlHfivrqRQNii9i8Sdp9G4YIXleb2EKAcouz8sWUCnUS08tQW9FrO1RGVm8eGos4rQjK1HN(xclVde4HLNHIHutsce4jQiK33KAEW58XGaTHLWc8fqsGG88sgMll8)j6FBz9k4ldbHLWcKQiOv1teKEeE2dvgVeRKRXLLGZ5JbbAvFIoiSewqwhE6FjS8oqGhwEgkgsnThKWleiYxHmK1HN(xclVde4HLNHIHut7HGalWFD8GSo80)sy5DGapS8mumKAY4lSljsGXHTY7BsgVqey7rQj4qLXlb7MJ)YsSCvFfj5ce72JutWHkJxIvntJbInw()e9VTSc8WYZq2dvgVeRm34YIH0EBf4HLNHSsKxw4)t0)2YkWdlpdzLihxGyjJPnSewGufbTQEIG0JWZo80dIll8)j6FBz9k4ldbHLWcKQiOv1teKEeE2dvgVeRm34YsW58XGaTQprhewcR4IlULLy3EKAcouz8sWoPMPXaXsgtByjSaPkcw3QEIG0JWZo80dIll8)j6FBz9k4ldbHLWcKQiOv1teKEeE2dvgVeR2EKAcouz8sexCXbzD4P)LWY7abEy5zOyi1KapS8mK8(Me)FI(3w2ZfEfbesfqMZLzpuz8sWUCllgVqey7rQj4qLXlb7MJpK1HN(xclVde4HLNHIHutgte43G8CUmbK1HN(xclVde4HLNHIHutBcuOYVzNY7BsIxIWWRULSKiLiqaEsKt)Rags7TvGhwEgY2)2kqhnK2BRXxyxsKaJdBbD0qAVT9VTcyiT3wJVWUKibgh2A7FBbzfY6Wt)lH9jJfEK2Uib)gKQiOv1teKEeEYZdXjqqo3fHPGKz59njUQBvMWMGR6RiTgK1HN(xc7tgl8IHutyyYibqDof59nPCiWkTCvhyiDI0I1yqG9aCv3QmHnbx1xrAniRdp9Ve2Nmw4fdPMspcpa5HqrEEiobcY5IWuqYS8(Me)vmEGipxggGR6wLjSj4Q(ksYbzD4P)LW(KXcVyi1ex1bTtquEFtIR6wLjSj4Qoj5GSo80)syFYyHxmKAcdtgjaQZPazD4P)LW(KXcVyi1u6r4bipekYZdXjqqoxeMcsML33K4QUvzcBcUQVIKCqwHSo80)syf4HLNHiTDrka)gSLUqY7Bsgs7TvGhwEgYEOY4LGDZqwhE6FjSc8WYZqXqQjbzVkVIa8BkeiZ5YK33K4VIXde55YWaXo80dIaSqfhfRiT2YYWtpicWcvCuSYCGMZ)NO)TL9CHxraHubK5CzwjYXbzD4P)LWkWdlpdfdPMox4veqivazoxM88qCceKZfHPGKz59nj(Ry8arEUmeY6Wt)lHvGhwEgkgsnTDrka)gSLUqY7Bsdp9GialuXrXksRbzD4P)LWkWdlpdfdPMeK9Q8kcWVPqGmNltEFtI)kgpqKNlddyiT32(uCe8Bax1zHUvImK1HN(xcRapS8mumKAYGy4YEPeiZ5YKNhItGGCUimfKmlVVjXFfJhiYZLHbmK2BBloK)sa(n4VoEwjYb4)t0)2YEUWRiGqQaYCUm7HkJxIvYbzD4P)LWkWdlpdfdPM2UifGFd2sxi59kX7KiNaFtYqAVTc8WYZqwjYb4)t0)2YEUWRiGqQaYCUm7HtpeK1HN(xcRapS8mumKAsq2RYRia)McbYCUm59nj(Ry8arEUmmqhnK2BRXxyxsKaJdBbD0qAVTsKHSo80)syf4HLNHIHutBxKGFdsve0Q6jcspcp55H4eiiNlctbjZY7BsCvN91GSo80)syf4HLNHIHutgedx2lLazoxM88qCceKZfHPGKz59nj(Ry8arEUmCzP55qGvAv9eWFfJhY6Wt)lHvGhwEgkgsnji7v5veGFtHazoxgKviRdp9VewrsQv1pcVIa9BI(cqwQ4QY7Bs34DageR0o9UW61k()e9VTSTQ(r4veOFt0xaYsfx12LUj9VIxnAnPll34DageR0o9UWkrgY6Wt)lHvKXqQjSWlYBw8kcGeEy)K33K4QUvzcBcUQVIKCbWcVOq20vqq(aLj8Q1ww4QUvzcBcUQVIelgiwSWlkKnDfeKpqzcVsULLMt(WGGiE3A2MEeEaYdHsCqwhE6FjSImgsnji7v5veGFtHazoxM8(Me)vmEGipxggWqAVT9P4i43aUQZcDRe5aXEJ3byqSs707cRxRmK2BBFkoc(nGR6Sq3EOY4LWeYTSCJ3byqSs707cRe54GSo80)syfzmKA6CHxraHubK5CzYZdXjqqoxeMcsML33K4)t0)2YkWdlpdzpuz8sSY8YsZZHaR0kWdlpdfiw()e9VTST4q(lb43G)64zpuz8sSIfxwAo)dI1uPvwOZNkoiRdp9VewrgdPM2UifGFd2sxi59nPyVX7amiwPD6DH1Rv8)j6FBz3UifGFd2sxiBx6M0)kE1O1KUSCJ3byqSs707cRe54celw4ffYMUccYhOmHxHHrUuIG0vqtyEzHR6wLjSj4Qo7KmVSyiT3wr(NcaNlvbt1bB)q7HkJxc2XWixkrq6kymMJBzz7rQj4qLXlb7yyKlLiiDfmgZllD0qAVTgFHDjrcmoSf0rdP92krgY6Wt)lHvKXqQj(nCzeEfbyHthbeEKAwEfjVVjziT32ufbOcz8(ta4d5H75FwroCzRmVEbWcVOq20vqq(aLj8kmmYLseKUcAcZb4)t0)2YEUWRiGqQaYCUm7HkJxIvyyKlLiiDfCzXqAVTPkcqfY49NaWhYd3Z)SIC4YwzMfdel)FI(3wwbEy5zi7HkJxc2JFGCiWkTc8WYZqll8)j6FBzBXH8xcWVb)1XZEOY4LG94hG)bXAQ0kl05tTSS9i1eCOY4LG94hhK1HN(xcRiJHutNKq1RialC6iO1RU8(MKH0EBpjHQxraw40rqRxDB)BRadp9GialuXrXkZqwhE6FjSImgsnTDrc(nivrqRQNii9i8KNhItGGCUimfKmlVVjXvD2xdY6Wt)lHvKXqQjmmzKaOoNI8(Mex1TktytWv9vKmdzD4P)LWkYyi1ex1bgsNiL33K4QUvzcBcUQVIK5adp9GialuXrbjZbUX7amiwPD6DH1RvY14Ycx1TktytWv9vKKlWWtpicWcvCuSIKCqwhE6FjSImgsnXvDq7eeHSo80)syfzmKAk9i8aKhcf55H4eiiNlctbjZY7Bs8xX4bI8CzyaUQBvMWMGR6RijxadP92kY)ua4CPkyQoy7hA7FBbzD4P)LWkYyi1KGSxLxra(nfcK5CzY7Bsgs7TLR6aSWlkKvKdx2Q1A0eXpEn80dIaSqfhfbmK2BRi)tbGZLQGP6GTFOT)TvGy5)t0)2YEUWRiGqQaYCUm7HkJxIvYfG)pr)Bl72fPa8BWw6czpuz8sSsULf()e9VTSNl8kciKkGmNlZEOY4LG91cW)NO)TLD7Iua(nylDHShQmEjwTwaUQVATLf()e9VTSNl8kciKkGmNlZEOY4Ly1Ab4)t0)2YUDrka)gSLUq2dvgVeSVwaUQVIfxw4QUvzcBcUQZojZbWcVOq20vqq(aLjm7Yf3YIH0EB5Qoal8Iczf5WLTYCJb2EKAcouz8sWEZgY6Wt)lHvKXqQjdIHl7LsGmNltEEiobcY5IWuqYS8(Me)vmEGipxggi2CiWkTc8WYZqb4)t0)2YkWdlpdzpuz8sW(All8)j6FBzpx4veqivazoxM9qLXlXkZb4)t0)2YUDrka)gSLUq2dvgVeRmVSW)NO)TL9CHxraHubK5Cz2dvgVeSVwa()e9VTSBxKcWVbBPlK9qLXlXQ1cWv9vYTSW)NO)TL9CHxraHubK5Cz2dvgVeRwla)FI(3w2Tlsb43GT0fYEOY4LG91cWv9vRTSWv9vXFzXqAVTgVma575wjYXbzD4P)LWkYyi1u6r4bipekYZdXjqqoxeMcsML33K4VIXde55YWaCv3QmHnbx1xrsoiRdp9VewrgdPMMJpfcY)oSs59njUQBvMWMGR6RizgY6Wt)lHvKXqQPnriVIac8iJvcK5CzY7vI3jrojzgY6Wt)lHvKXqQjdIHl7LsGmNltEEiobcY5IWuqYS8(Me)vmEGipxggG)pr)Bl72fPa8BWw6czpuz8sW(Ab4Qoj5cq(WGGiE3A2MEeEaYdHsaSWlkKnDfeKpi(nYUziRdp9VewrgdPMmigUSxkbYCUm55H4eiiNlctbjZY7Bs8xX4bI8CzyaSWlkKnDfeKpqzcZUCbILR6wLjSj4Qo7KmVSq(WGGiE3A2MEeEaYdHsCqwHSo80)syBXH8xcWVb)1XJuW58XGaLVgfKKbXWL9sjqMZLbke7yx(NmjbMYhCiKqsgs7TTfhYFja)g8xhpqBR9qLXlrGy5)t0)2YEUWRiGqQaYCUm7HkJxIvgs7TTfhYFja)g8xhpqBR9qLXlradP922Id5VeGFd(RJhOT1EOY4LGD5SMxw4)t0)2YEUWRiGqQaYCUm7HkJxctyiT32wCi)La8BWFD8aTT2dvgVeRmBxVags7TTfhYFja)g8xhpqBR9qLXlb7SO18YIH0EBni(VtijsRe5ags7T1RGVm8eGos4rQPvICadP926vWxgEcqhj8i10EOY4LGDdP922Id5VeGFd(RJhOT1EOY4LioiRdp9Ve2wCi)La8BWFD8IHut8HGam80)cq4Iu(Auqs8oqGB5f558KKz59nPMNdbwPvGhwEgcY6Wt)lHTfhYFja)g8xhVyi1eFiiadp9VaeUiLVgfKeVde4HLNHKxKNZtsML33KYHaR0kWdlpdbzD4P)LW2Id5VeGFd(RJxmKAcl8I8MfVIaiHh2p59njUQBvMWMGR6RijxaSWlkKnDfeKpqzcVAniRdp9Ve2wCi)La8BWFD8IHutNl8kciKkGmNltEEiobcY5IWuqYmK1HN(xcBloK)sa(n4VoEXqQPTlsb43GT0fsEFtA4PhebyHkokwrsUags7TTfhYFja)g8xhpqBR9qLXlb7MHSo80)syBXH8xcWVb)1Xlgsn1Q6hHxrG(nrFbilvCv59nPHNEqeGfQ4Oyfj5GSo80)syBXH8xcWVb)1Xlgsnji7v5veGFtHazoxM8(Me)vmEGipxggy4PhebyHkokwrATags7TTfhYFja)g8xhpqBRvImK1HN(xcBloK)sa(n4VoEXqQjdIHl7LsGmNltEEiobcY5IWuqYS8(Me)vmEGipxggy4PhebyHkokyNKCbcoNpgeO1Gy4YEPeiZ5YafIDSdzD4P)LW2Id5VeGFd(RJxmKAsq2RYRia)McbYCUm59nj(Ry8arEUmmGH0EB7tXrWVbCvNf6wjYqwhE6FjST4q(lb43G)64fdPMWWKrcG6CkY7BsCvNuJbmK2BBloK)sa(n4VoEG2w7HkJxc2zriRdp9Ve2wCi)La8BWFD8IHutBxKGFdsve0Q6jcspcp55H4eiiNlctbjZY7BsCvNuJbmK2BBloK)sa(n4VoEG2w7HkJxc2zriRdp9Ve2wCi)La8BWFD8IHutTQ(r4veOFt0xaYsfxfY6Wt)lHTfhYFja)g8xhVyi1u6r4bipekYZdXjqqoxeMcsML33K4QoPgdyiT32wCi)La8BWFD8aTT2dvgVeSZIqwhE6FjST4q(lb43G)64fdPM2UifGFd2sxi59kX7KiNaFtYqAVTT4q(lb43G)64bABTsKL33KmK2BRi)tbGZLQGP6GTFOvICGB8oadIvANExy9Af)FI(3w2Tlsb43GT0fY2LUj9VIxnABgiRdp9Ve2wCi)La8BWFD8IHutcYEvEfb43uiqMZLjVVjziT3wUQdWcVOqwroCzRwRrte)41WtpicWcvCuazD4P)LW2Id5VeGFd(RJxmKAA7Ie8BqQIGwvprq6r4jppeNab5CrykizwEFtIR6SVgK1HN(xcBloK)sa(n4VoEXqQjmmzKaOoNI8(Mex1TktytWv9vKmdzD4P)LW2Id5VeGFd(RJxmKAIR6adPtKY7BsCv3QmHnbx1xrkwZXm80dIaSqfhfRmhhK1HN(xcBloK)sa(n4VoEXqQP0JWdqEiuKNhItGGCUimfKmlVVjfBZZHaR0Q6jG)kg)Yc)vmEGipxggxaUQBvMWMGR6RijhK1HN(xcBloK)sa(n4VoEXqQjdIHl7LsGmNltEEiobcY5IWuqYS8(M0WtpicWcvCuWoP1cWv9vKwBzXqAVTT4q(lb43G)64bABTsKHSo80)syBXH8xcWVb)1XlgsnXvDq7eeHSo80)syBXH8xcWVb)1XlgsnTjc5veqGhzSsGmNltEVs8ojYjjZAMrkv)tZW4kRVo1Pwd]] )


end