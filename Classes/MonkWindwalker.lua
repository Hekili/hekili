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


    spec:RegisterPack( "Windwalker", 20210723, [[dS0uFcqiLu5rkjv2Ka(ekPgLuWPKcTkbv4vckZIe1TOsyxu1VusmmHKJrLAzOuEMsktdLKUMGQ2Mss8nbvQXjOIoNsQY6uskZdLQ7Hi7tk6GujsTqHupeLenrQej5IcQK2ivIe(OsskNuqLyLOeVKkrIMPsQQBsLiP2jjYpvss1svss8uumvQK(QssvJLkrTxs9xGbJ0HvSyQ4XOAYs1LH2Ss9zHA0e1PPSAus41KWSr42ez3s(TQgoI64ujILRYZjmDrxNK2UG8DLy8cX5fO1RKK08Ls7h0A3Ax1m9jrTsSffBUJkCZ2AE3HB3RTgRQzYGKrnd5HRyIrntnsOMz1BvFziuGNMH8eK4NU2vnJ4vpoQz0moQgrgUuAhntFsuReBrXM7Oc3STM3D429ASXQAgbzKRvITvz90mYwVJL2rZ0rbxZS6TQVmekWdsDP(lfqwyrLiiKY2AkdPSffBUHSazX1fCuaPUuyIuaP)gsDPq9ccPwL4DQKtiL4JnUhYIRl4OasziBvzvmKYkVPqi1LsJRasj(yJ7HS4s37qQZleBlwoHuUmYviG08HuPPccPSsxQGuSYZqHxZqyIuODvZ8KXcpTRALCRDvZG14qGDD0AMHN2xAMTjsWVbPmcwKTebPfJNMHFwINnAgUS5LMiqQlGuUSbPnjbPRPz4b5eiiN7IXuOzCRtTsSPDvZG14qGDD0Ag(zjE2OzYHaR0ZLnGJ6jspwJdb2H0aqkx28stei1fqkx2G0MKG010mdpTV0myeYibqEojDQvAnTRAgSghcSRJwZm80(sZKwmEaYdHKMHFwINnAg(l58arEMcesdaPCzZlnrGuxaPCzdsBscsztZWdYjqqoxmMcTsU1Pwjwv7QMbRXHa76O1m8Zs8SrZWLnV0ebsDbKYLniLeKYMMz4P9LMHlBGLjeQtTsHx7QMz4P9LMbJqgjaYZjPzWACiWUoADQvAv0UQzWACiWUoAnZWt7lntAX4bipesAg(zjE2Oz4YMxAIaPUas5YgK2KeKYMMHhKtGGCUymfALCRtDQzwWH8xcWVb)1Xt7Qwj3Ax1mynoeyxhTM5jRzeyQzgEAFPzcnNnoeOMj0qOIAgh192VGd5VeGFd(RJhyzXFO0yLasdaPnaP8)j6)s5ptyvmqOwafgxH)qPXkbK2esDu3B)coK)sa(n4VoEGLf)HsJvcinaK6OU3(fCi)La8BWFD8all(dLgReqk7qkBE3qABlKY)NO)lL)mHvXaHAbuyCf(dLgReqQlGuh192VGd5VeGFd(RJhyzXFO0yLasBcPU9RhKgasDu3B)coK)sa(n4VoEGLf)HsJvciLDiLv9UH02wi1rDV9oe)3jufPxLmKgasDu3BVvHEf4jaDKWILtVkzinaK6OU3ERc9kWta6iHflN(dLgReqk7qQJ6E7xWH8xcWVb)1XdSS4puASsaPnQzcnhOgjuZ4qmCfVAcuyCfGcXo21Pwj20UQzWACiWUoAnd)SepB0mRdsZHaR0lWdlld6XACiWUMz4P9LMHpeeGHN2xactKAgctKGAKqndVde4wNALwt7QMbRXHa76O1m8Zs8SrZKdbwPxGhwwg0J14qGDnZWt7lndFiiadpTVaeMi1meMib1iHAgEhiWdlldQtTsSQ2vndwJdb21rRz4NL4zJMHlBEPjcK6ciLlBqAtsqkBqAaifl8Id6ttcb5dKMiqAtiDnnZWt7lndw4fBRQwfdqclID6uRu41UQzWACiWUoAnZWt7lnZzcRIbc1cOW4k0m8GCceKZfJPqRKBDQvAv0UQzWACiWUoAnd)SepB0mdpTqialuYqbK2KeKYgKgasDu3B)coK)sa(n4VoEGLf)HsJvciLDi1TMz4P9LMzBIua(nyREb1PwPWT2vndwJdb21rRz4NL4zJMz4PfcbyHsgkG0MKGu20mdpTV0mlY2ryvmOFt8xaYQfxwNALcNAx1mynoeyxhTMHFwINnAg(l58arEMcesdaPdpTqialuYqbK2KeKUgKgasDu3B)coK)sa(n4VoEGLfVkznZWt7lnJGSvLvXa(nfcuyCf6uR06PDvZG14qGDD0AMHN2xAghIHR4vtGcJRqZWplXZgnd)LCEGiptbcPbG0HNwieGfkzOaszNeKYgKgasdnNnoeO3Hy4kE1eOW4kafIDSRz4b5eiiNlgtHwj36uRK7O0UQzWACiWUoAnd)SepB0m8xY5bI8mfiKgasDu3BFFkoc(nGlBScZRswZm80(sZiiBvzvmGFtHafgxHo1k52T2vndwJdb21rRz4NL4zJMHlBqkjinkinaK6OU3(fCi)La8BWFD8all(dLgReqk7qkRQzgEAFPzWiKrcG8Cs6uRKB20UQzWACiWUoAnZWt7lnZ2ej43GugblYwIG0IXtZWplXZgndx2GusqAuqAai1rDV9l4q(lb43G)64bww8hknwjGu2HuwvZWdYjqqoxmMcTsU1Pwj3RPDvZm80(sZSiBhHvXG(nXFbiRwCzndwJdb21rRtTsUzvTRAgSghcSRJwZm80(sZKwmEaYdHKMHFwINnAgUSbPKG0OG0aqQJ6E7xWH8xcWVb)1XdSS4puASsaPSdPSQMjNlgtGT1mHbPnaPD0rDV9cfbpC4YamI8Oks7lVkzinCaPSffK2Oo1k5o8Ax1mynoeyxhTMHFwINnAgh192lY)Ka4CPmyQoyBh6vjdPbG0BSoadHv6NEx4TcsBcP8)j6)s53MifGFd2QxqFx9M0(csdhqAu(vrZm80(sZSnrka)gSvVGAgRs8ovYjW2Agh192VGd5VeGFd(RJhyzXRswNALCVkAx1mynoeyxhTMHFwINnAgh192ZLnaw4fh0lYHRasBcPRffK6cin8qA4ashEAHqawOKHcnZWt7lnJGSvLvXa(nfcuyCf6uRK7WT2vndwJdb21rRzgEAFPz2Mib)gKYiyr2seKwmEAg(zjE2Oz4YgKYoKUMMHhKtGGCUymfALCRtTsUdNAx1mynoeyxhTMHFwINnAgUS5LMiqQlGuUSbPnjbPU1mdpTV0myeYibqEojDQvY96PDvZG14qGDD0Ag(zjE2Oz4YMxAIaPUas5YgK2KeK2aK6gsddshEAHqawOKHciTjK6gsBuZm80(sZWLnGJ6jsDQvITO0UQzWACiWUoAnZWt7lntAX4bipesAg(zjE2OzAasxhKMdbwPx2sa)LCEpwJdb2H02wiL)sopqKNPaH0gH0aqkx28stei1fqkx2G0MKGu20m8GCceKZfJPqRKBDQvIn3Ax1mynoeyxhTMz4P9LMXHy4kE1eOW4k0m8Zs8SrZm80cHaSqjdfqk7KG01G0aqkx2G0MKG01G02wi1rDV9l4q(lb43G)64bww8QK1m8GCceKZfJPqRKBDQvIn20UQzgEAFPz4YgyzcHAgSghcSRJwNALyBnTRAgRs8ovYPMXTMz4P9LMzte0QyGapYyLafgxHMbRXHa76O1Po1mc8WYYGAx1k5w7QMbRXHa76O1m8Zs8SrZ4OU3EbEyzzq)HsJvciLDi1TMz4P9LMzBIua(nyREb1Pwj20UQzWACiWUoAnd)SepB0m8xY5bI8mfiKgasBashEAHqawOKHciTjjiDniTTfshEAHqawOKHciTjK6gsdaPRds5)t0)LYFMWQyGqTakmUcVkziTrnZWt7lnJGSvLvXa(nfcuyCf6uR0AAx1mynoeyxhTMz4P9LM5mHvXaHAbuyCfAg(zjE2Oz4VKZde5zkqndpiNab5CXyk0k5wNALyvTRAgSghcSRJwZWplXZgnZWtlecWcLmuaPnjbPRPzgEAFPz2MifGFd2QxqDQvk8Ax1mynoeyxhTMHFwINnAg(l58arEMcesdaPoQ7TVpfhb)gWLnwH5vjRzgEAFPzeKTQSkgWVPqGcJRqNALwfTRAgSghcSRJwZm80(sZ4qmCfVAcuyCfAg(zjE2Oz4VKZde5zkqinaK6OU3(fCi)La8BWFD88QKH0aqk)FI(Vu(ZewfdeQfqHXv4puASsaPnHu20m8GCceKZfJPqRKBDQvkCRDvZyvI3Psob2wZ4OU3EbEyzzqVk5a8)j6)s5ptyvmqOwafgxH)WPhuZm80(sZSnrka)gSvVGAgSghcSRJwNALcNAx1mynoeyxhTMHFwINnAg(l58arEMcesdaPD0rDV9oFHDvrcCoCb0rh192RswZm80(sZiiBvzvmGFtHafgxHo1kTEAx1mynoeyxhTMz4P9LMzBIe8BqkJGfzlrqAX4Pz4NL4zJMHlBqk7q6AAgEqobcY5IXuOvYTo1k5okTRAgSghcSRJwZm80(sZ4qmCfVAcuyCfAg(zjE2Oz4VKZde5zkqiTTfsxhKMdbwPx2sa)LCEpwJdb21m8GCceKZfJPqRKBDQvYTBTRAMHN2xAgbzRkRIb8BkeOW4k0mynoeyxhTo1PMH3bc8WYYGAx1k5w7QMbRXHa76O1mpznJatnZWt7lntO5SXHa1mHgcvuZW)NO)lLxGhwwg0FO0yLaszhsDdPTTqkzm9ruXcKYiyr2seKwmE(HNwiesdaP8)j6)s5f4HLLb9hknwjG0Mq6ArbPTTqQZleqAaiDBXYj4qPXkbKYoKYwuAMqZbQrc1mc8WYYGah1tK6uReBAx1mynoeyxhTMHFwINnAM1bPHMZghc0l)eDqevSG02wi15fcinaKUTy5eCO0yLaszhszl8AMHN2xAgRc9kqqevS0PwP10UQzWACiWUoAnd)SepB0mHMZghc0lWdlldcCuprQzgEAFPzCi(Vd2QxqDQvIv1UQzWACiWUoAnd)SepB0mHMZghc0lWdlldcCuprQzgEAFPzCWtGNcRI1PwPWRDvZm80(sZqyXYPaWku7XsyLAgSghcSRJwNALwfTRAgSghcSRJwZWplXZgntO5SXHa9c8WYYGah1tKAMHN2xAMTDOdX)DDQvkCRDvZG14qGDD0Ag(zjE2OzcnNnoeOxGhwwge4OEIuZm80(sZmfhf5nea(qqOtTsHtTRAgSghcSRJwZWplXZgntO5SXHa9c8WYYGah1tKAMHN2xAgNjg8BqEgxHqNALwpTRAgSghcSRJwZWplXZgnZ2ILtWHsJvciTjK2aK6oCgfK6ci9ulC)xm63toeG8v5YESghcSdPHdi1nBrbPncPTTqkzm9ruXcKYiyr2seKwmE(HNwiesBBHuNxiG0aq62ILtWHsJvciLDi1DuAMHN2xAM8v5YGFd64KY6uRK7O0UQzWACiWUoAnd)SepB0mBlwobhknwjG0Mq66ffK22cPKX0hrflqkJGfzlrqAX45hEAHqiTTfsDEHasdaPBlwobhknwjGu2Hu3rPzgEAFPzYxLld(nqXCsJo1k52T2vndwJdb21rRz4NL4zJMH)pr)xk)zcRIbc1cOW4k8hknwjGu2HumcYvteKMeQzgEAFPzwWH8xcWVb)1XtNALCZM2vndwJdb21rRz4NL4zJMj0C24qGEbEyzzqGJ6jsnZWt7lnJvc(PMJdbcCjQtLQsGogY4Oo1k5EnTRAgSghcSRJwZWplXZgntO5SXHa9c8WYYGah1tKAMHN2xAMLBszr(fQtTsUzvTRAgSghcSRJwZWplXZgntO5SXHa9c8WYYGah1tKAMHN2xAMyIPBt(Na4m9yuNALChETRAgSghcSRJwZm80(sZiKN(VeFJGmi)eL0m8Zs8SrZqgtFevSaPmcwKTebPfJNF4PfcH02wi15fcinaKUTy5eCO0yLaszhszlkiTTfsxhKEQfU)lg9wf6vGNa0rclwo9ynoeyxZuJeQzeYt)xIVrqgKFIs6uRK7vr7QMbRXHa76O1m8Zs8SrZSoin0C24qG(iQyb(cOkqqEwPatiTTfs5)t0)LYBvOxbcIOIfiLrWISLiiTy88hknwjG0MqkBrbPTTqAO5SXHa9YprherflnZWt7lnJQabwIscDQvYD4w7QMz4P9LMzpiHviqKVezndwJdb21rRtTsUdNAx1mdpTV0m7HGalWFD80mynoeyxhTo1k5E90UQzWACiWUoAnd)SepB0moVqaPbG0TflNGdLgReqk7qQ7WdPTTqAdqkx2G0MKGu2G0aqAdq62ILtWHsJvciTjKUkrbPbG0gG0gGu()e9FP8c8WYYG(dLgReqAti1DuqABlK6OU3EbEyzzqVkziTTfs5)t0)LYlWdlld6vjdPncPbG0gGuYy6JOIfiLrWISLiiTy88dpTqiK22cP8)j6)s5Tk0RabruXcKYiyr2seKwmE(dLgReqAti1DuqABlKgAoBCiqV8t0bruXcsBesBesBesBBH0gG0TflNGdLgReqk7KG0vjkinaK2aKsgtFevSaPmcw9YwIG0IXZp80cHqABlKY)NO)lL3QqVceerflqkJGfzlrqAX45puASsaPnH0TflNGdLgReqAJqAJqAJAMHN2xAgNVWUQibohUOtTsSfL2vndwJdb21rRz4NL4zJMH)pr)xk)zcRIbc1cOW4k8hknwjGu2Hu2G02wi15fcinaKUTy5eCO0yLaszhsDhEnZWt7lnJapSSmOo1kXMBTRAMHN2xAgNjg8BqEgxHqZG14qGDD06uReBSPDvZG14qGDD0Ag(zjE2OzeVkHJvDpzvrQsGa8ujN2xESghcSdPbGuh192lWdlld67)sbPbG0o6OU3ENVWUQibohUa6OJ6E77)sPzgEAFPz2eOqMFZo1Po1mIu7Qwj3Ax1mynoeyxhTMHFwINnAMBSoadHv6NEx4TcsBcP8)j6)s5xKTJWQyq)M4VaKvlUSVREtAFbPHdinkF4esBBH0BSoadHv6NEx4vjRzgEAFPzwKTJWQyq)M4VaKvlUSo1kXM2vndwJdb21rRz4NL4zJMHlBEPjcK6ciLlBqAtsqkBqAaifl8Id6ttcb5dKMiqAtiDniTTfs5YMxAIaPUas5YgK2KeKYQqAaiTbifl8Id6ttcb5dKMiqAtiLniTTfsxhKs(WqGyE372NwmEaYdHeK2OMz4P9LMbl8ITvvRIbiHfXoDQvAnTRAgSghcSRJwZWplXZgnd)LCEGiptbcPbGuh1923NIJGFd4YgRW8QKH0aqAdq6nwhGHWk9tVl8wbPnHuh1923NIJGFd4YgRW8hknwjGuxaPSbPTTq6nwhGHWk9tVl8QKH0g1mdpTV0mcYwvwfd43uiqHXvOtTsSQ2vndwJdb21rRzgEAFPzotyvmqOwafgxHMHFwINnAg()e9FP8c8WYYG(dLgReqAti1nK22cPRdsZHaR0lWdlld6XACiWoKgasBas5)t0)LYVGd5VeGFd(RJN)qPXkbK2eszviTTfsxhKY)qynv6ve8SPG0g1m8GCceKZfJPqRKBDQvk8Ax1mynoeyxhTMHFwINnAMgG0BSoadHv6NEx4TcsBcP8)j6)s53MifGFd2QxqFx9M0(csdhqAu(WjK22cP3yDagcR0p9UWRsgsBesdaPnaPyHxCqFAsiiFG0ebsBcPyeKRMiinjesDbK6gsBBHuUS5LMiqQlGuUSbPStcsDdPTTqQJ6E7f5FsaCUugmvhSTd9hknwjGu2HumcYvteKMecPHbPUH0gH02wiDBXYj4qPXkbKYoKIrqUAIG0Kqinmi1nK22cPD0rDV9oFHDvrcCoCb0rh192RswZm80(sZSnrka)gSvVG6uR0QODvZG14qGDD0Ag(zjE2OzCu3BFkJauImE)ja8H8WT8pVihUciTjK6E9G0aqkw4fh0NMecYhinrG0Mqkgb5QjcstcHuxaPUH0aqk)FI(Vu(ZewfdeQfqHXv4puASsaPnHumcYvteKMecPTTqQJ6E7tzeGsKX7pbGpKhUL)5f5WvaPnHu3SkKgasBas5)t0)LYlWdlld6puASsaPSdPHhsdaP5qGv6f4HLLb9ynoeyhsBBHu()e9FP8l4q(lb43G)645puASsaPSdPHhsdaP8pewtLEfbpBkiTTfs3wSCcouASsaPSdPHhsBuZm80(sZWVHRGWQyaRy6iGWILZYQyDQvkCRDvZG14qGDD0Ag(zjE2OzCu3B)PkKTkgWkMocwSQ77)sbPbG0HNwieGfkzOasBcPU1mdpTV0mNQq2QyaRy6iyXQUo1kfo1UQzWACiWUoAnZWt7lnZ2ej43GugblYwIG0IXtZWplXZgndx2Gu2H010m8GCceKZfJPqRKBDQvA90UQzWACiWUoAnd)SepB0mCzZlnrGuxaPCzdsBscsDRzgEAFPzWiKrcG8Cs6uRK7O0UQzWACiWUoAnd)SepB0mCzZlnrGuxaPCzdsBscsDdPbG0HNwieGfkzOasjbPUH0aq6nwhGHWk9tVl8wbPnHu2IcsBBHuUS5LMiqQlGuUSbPnjbPSbPbG0HNwieGfkzOasBscsztZm80(sZWLnGJ6jsDQvYTBTRAMHN2xAgUSbwMqOMbRXHa76O1Pwj3SPDvZG14qGDD0AMHN2xAM0IXdqEiK0m8Zs8SrZWFjNhiYZuGqAaiLlBEPjcK6ciLlBqAtsqkBqAai1rDV9I8pjaoxkdMQd22H((VuAgEqobcY5IXuOvYTo1k5EnTRAgSghcSRJwZWplXZgnJJ6E75Ygal8Id6f5WvaPnH01IcsDbKgEinCaPdpTqialuYqbKgasDu3BVi)tcGZLYGP6GTDOV)lfKgasBas5)t0)LYFMWQyGqTakmUc)HsJvciTjKYgKgas5)t0)LYVnrka)gSvVG(dLgReqAtiLniTTfs5)t0)LYFMWQyGqTakmUc)HsJvciLDiDninaKY)NO)lLFBIua(nyREb9hknwjG0Mq6AqAaiLlBqAtiDniTTfs5)t0)LYFMWQyGqTakmUc)HsJvciTjKUgKgas5)t0)LYVnrka)gSvVG(dLgReqk7q6AqAaiLlBqAtiLvH02wiLlBEPjcK6ciLlBqk7KGu3qAaifl8Id6ttcb5dKMiqk7qkBqAJqABlK6OU3EUSbWcV4GEroCfqAti1DuqAaiDBXYj4qPXkbKYoKgU1mdpTV0mcYwvwfd43uiqHXvOtTsUzvTRAgSghcSRJwZm80(sZ4qmCfVAcuyCfAg(zjE2Oz4VKZde5zkqinaK2aKMdbwPxGhwwg0J14qGDinaKY)NO)lLxGhwwg0FO0yLaszhsxdsBBHu()e9FP8NjSkgiulGcJRWFO0yLasBcPUH0aqk)FI(Vu(Tjsb43GT6f0FO0yLasBcPUH02wiL)pr)xk)zcRIbc1cOW4k8hknwjGu2H01G0aqk)FI(Vu(Tjsb43GT6f0FO0yLasBcPRbPbGuUSbPnHu2G02wiL)pr)xk)zcRIbc1cOW4k8hknwjG0Mq6AqAaiL)pr)xk)2ePa8BWw9c6puASsaPSdPRbPbGuUSbPnH01G02wiLlBqAtin8qABlK6OU3ENxbG89CVkziTrndpiNab5CXyk0k5wNALChETRAgSghcSRJwZm80(sZKwmEaYdHKMHFwINnAg(l58arEMcesdaPCzZlnrGuxaPCzdsBscsztZWdYjqqoxmMcTsU1Pwj3RI2vndwJdb21rRz4NL4zJMHlBEPjcK6ciLlBqAtsqQBnZWt7lnZC8Pqq(3HvQtTsUd3Ax1mwL4DQKtnJBnZWt7lnZMiOvXabEKXkbkmUcndwJdb21rRtTsUdNAx1mynoeyxhTMz4P9LMXHy4kE1eOW4k0m8Zs8SrZWFjNhiYZuGqAaiL)pr)xk)2ePa8BWw9c6puASsaPSdPRbPbGuUSbPKGu2G0aqk5ddbI5DVBFAX4bipesqAaifl8Id6ttcb5dcFuqk7qQBndpiNab5CXyk0k5wNALCVEAx1mynoeyxhTMz4P9LMXHy4kE1eOW4k0m8Zs8SrZWFjNhiYZuGqAaifl8Id6ttcb5dKMiqk7qkBqAaiTbiLlBEPjcK6ciLlBqk7KGu3qABlKs(WqGyE372NwmEaYdHeK2OMHhKtGGCUymfALCRtDQz4DGa3Ax1k5w7QMbRXHa76O1m8Zs8SrZSoin0C24qGE5NOdIOIfKgasBas5)t0)LYFMWQyGqTakmUc)HsJvciLDiLniTTfsxhKY)qynv6ve8SPG0gH0aqAdq66Gu(hcRPsFH87j(RdPTTqk)FI(VuENVWUQibohU4puASsaPSdPSbPncPTTq62ILtWHsJvciLDiLTWRzgEAFPzSk0RabruXsNALyt7QMbRXHa76O1m8Zs8SrZSTy5eCO0yLasBcPnaPUdNrbPUasp1c3)fJ(9KdbiFvUShRXHa7qA4asDZwuqAJqABlK6OU3Er(NeaNlLbt1bB7qF)xkinaKsgtFevSaPmcwKTebPfJNF4PfcH02wi15fcinaKUTy5eCO0yLaszhsDhLMz4P9LMjFvUm43GooPSo1kTM2vndwJdb21rRz4NL4zJMPbi9gRdWqyL(P3fERG0MqkRgEiTTfsVX6amewPF6DHxLmK2iKgas5)t0)LYFMWQyGqTakmUc)HsJvciLDifJGC1ebPjHqAaiL)pr)xkVvHEfiiIkwGugblYwIG0IXZFO0yLasBcPnaPSffKggKYwuqA4asp1c3)fJERc9kWta6iHflNESghcSdPncPTTqQZleqAaiDBXYj4qPXkbKYoKUw41mdpTV0ml4q(lb43G)64PtTsSQ2vndwJdb21rRz4NL4zJMH)sopqKNPaH0aqAdq6nwhGHWk9tVl8wbPnHu3rbPTTq6nwhGHWk9tVl8QKH0g1mdpTV0m7bjScbI8LiRtTsHx7QMbRXHa76O1m8Zs8SrZCJ1byiSs)07cVvqAtiDTOG02wi9gRdWqyL(P3fEvYAMHN2xAM9qqGf4VoE6uR0QODvZG14qGDD0Ag(zjE2Oz4YgK2KeKYgKgas3wSCcouASsaPnH0vjkinaK2aKY)NO)lLxK)jbW5szWuDW2o0ZLNlgfqAtinkiTTfs5)t0)LYlY)Ka4CPmyQoyBh6puASsaPnHu3rbPncPbG0gGuYy6JOIfiLrWISLiiTy88dpTqiK22cP8)j6)s5Tk0RabruXcKYiyr2seKwmE(dLgReqAti1DuqABlKgAoBCiqV8t0bruXcsBesBBH0gGuUSbPnjbPSbPbG0TflNGdLgReqk7KG0vjkinaK2aKsgtFevSaPmcw9YwIG0IXZp80cHqABlKY)NO)lL3QqVceerflqkJGfzlrqAX45puASsaPnH0TflNGdLgReqAJqAaiTbiL)pr)xkVi)tcGZLYGP6GTDONlpxmkG0MqAuqABlKY)NO)lLxK)jbW5szWuDW2o0FO0yLasBcPBlwobhknwjG02wi1rDV9I8pjaoxkdMQd22HEvYqAJqAJqABlKUTy5eCO0yLaszhsDhEnZWt7lnJZxyxvKaNdx0PwPWT2vndwJdb21rRz4NL4zJMH)vx1sp))RB1Kyh87nwcle6XACiWUMz4P9LMrK)jbW5szWuDW2oeSTitI6uRu4u7QMbRXHa76O1m8Zs8SrZW)NO)lLxK)jbW5szWuDW2o0ZLNlgfqkjiLniTTfs3wSCcouASsaPSdPSffK22cPnaP3yDagcR0p9UWFO0yLasBcPUdpK22cPnaPRds5FiSMk9kcE2uqAaiDDqk)dH1uPVq(9e)1H0gH0aqAdqAdq6nwhGHWk9tVl8wbPnHu()e9FP8I8pjaoxkdMQd22H(Tkbb4qU8CXiinjesBBH01bP3yDagcR0p9UWJrmrkG0gH0aqAdqk)FI(VuERc9kqqevSaPmcwKTebPfJN)qPXkbK2es5)t0)LYlY)Ka4CPmyQoyBh63QeeGd5YZfJG0KqiTTfsdnNnoeOx(j6GiQybPncPncPbGu()e9FP8BtKcWVbB1lO)qPXkbKYojiD9G0aqkx2G0MKGu2G0aqk)FI(Vu(fz7iSkg0Vj(laz1Il7puASsaPStcsDZgK2OMz4P9LMrK)jbW5szWuDW2ouNALwpTRAgSghcSRJwZWplXZgnd)dH1uPxrWZMcsdaPnaPoQ7TFbhYFja)g8xhpVkziTTfsBas3wSCcouASsaPSdP8)j6)s5xWH8xcWVb)1XZFO0yLasBBHu()e9FP8l4q(lb43G)645puASsaPnHu()e9FP8I8pjaoxkdMQd22H(Tkbb4qU8CXiinjesBesdaP8)j6)s53MifGFd2Qxq)HsJvciLDsq66bPbGuUSbPnjbPSbPbGu()e9FP8lY2ryvmOFt8xaYQfx2FO0yLaszNeK6MniTrnZWt7lnJi)tcGZLYGP6GTDOo1k5okTRAgSghcSRJwZWplXZgnd)dH1uPVq(9e)1H0aqAhDu3BVZxyxvKaNdxaD0rDV9QKH0aqAdqkzm9ruXcKYiyr2seKwmE(HNwiesBBH0qZzJdb6LFIoiIkwqABlKY)NO)lL3QqVceerflqkJGfzlrqAX45puASsaPnHu()e9FP8I8pjaoxkdMQd22H(Tkbb4qU8CXiinjesBBHu()e9FP8wf6vGGiQybszeSiBjcslgp)HsJvciTjKUwuqAJAMHN2xAgr(NeaNlLbt1bB7qDQvYTBTRAgSghcSRJwZWplXZgndzm9ruXcKYiyr2seKwmE(HNwiesBBHuNxiG0aq62ILtWHsJvciLDiLTO0mdpTV0mwj4NAooeiWLOovQkb6yiJJ6uRKB20UQzWACiWUoAnd)SepB0mKX0hrflqkJGfzlrqAX45hEAHqiTTfsDEHasdaPBlwobhknwjGu2Hu2IsZm80(sZSCtklYVqDQvY9AAx1mynoeyxhTMHFwINnAgYy6JOIfiLrWISLiiTy88dpTqiK22cPoVqaPbG0TflNGdLgReqk7qkBrPzgEAFPzIjMUn5FcGZ0JrDQvYnRQDvZG14qGDD0AMHN2xAM(HtFBhccHcbsOz4NL4zJMzDqAO5SXHa9ruXc8fqvGG8SsbMqABlKY)NO)lL3QqVceerflqkJGfzlrqAX45puASsaPnHu2IcsdaPKX0hrflqkJGfzlrqAX45puASsaPSdPSffK22cPHMZghc0l)eDqevS0m1iHAM(HtFBhccHcbsOtTsUdV2vndwJdb21rRzgEAFPzeYt)xIVrqgKFIsAg(zjE2OziJPpIkwGugblYwIG0IXZp80cHqABlK68cbKgas3wSCcouASsaPSdPSffK22cPRdsp1c3)fJERc9kWta6iHflNESghcSRzQrc1mc5P)lX3iidYprjDQvY9QODvZG14qGDD0Ag(zjE2OzwhKgAoBCiqFevSaFbufiipRuGjK22cP8)j6)s5Tk0RabruXcKYiyr2seKwmE(dLgReqAtiLTOG02win0C24qGE5NOdIOILMz4P9LMrvGalrjHo1k5oCRDvZG14qGDD0Ag(zjE2Oz2wSCcouASsaPnH01lkiTTfsjJPpIkwGugblYwIG0IXZp80cHqABlKgAoBCiqV8t0bruXcsBBHuNxiG0aq62ILtWHsJvciLDi19QOzgEAFPzYxLld(nqXCsJo1k5oCQDvZG14qGDD0Ag(zjE2Oz4)t0)LYBvOxbcIOIfiLrWISLiiTy88hknwjG0Mq6ArbPTTqAO5SXHa9YprherfliTTfsDEHasdaPBlwobhknwjGu2Hu2IsZm80(sZ4q8FhSvVG6uRK71t7QMbRXHa76O1m8Zs8SrZW)NO)lL3QqVceerflqkJGfzlrqAX45puASsaPnH01IcsBBH0qZzJdb6LFIoiIkwqABlK68cbKgas3wSCcouASsaPSdPUdVMz4P9LMXbpbEkSkwNALylkTRAMHN2xAgclwofawHApwcRuZG14qGDD06uReBU1UQzWACiWUoAnd)SepB0m8)j6)s5Tk0RabruXcKYiyr2seKwmE(dLgReqAtiDTOG02win0C24qGE5NOdIOIfK22cPoVqaPbG0TflNGdLgReqk7qQ7O0mdpTV0mB7qhI)76uReBSPDvZG14qGDD0Ag(zjE2Oz4)t0)LYBvOxbcIOIfiLrWISLiiTy88hknwjG0Mq6ArbPTTqAO5SXHa9YprherfliTTfsDEHasdaPBlwobhknwjGu2Hu2IsZm80(sZmfhf5nea(qqOtTsSTM2vndwJdb21rRz4NL4zJMXrDV9I8pjaoxkdMQd22H((VuAMHN2xAgNjg8BqEgxHqNALyJv1UQzWACiWUoAnd)SepB0mIxLWXQUNSQivjqaEQKt7lpwJdb2H0aqQJ6E7f5FsaCUugmvhSTd99FPG0aqAhDu3BVZxyxvKaNdxaD0rDV99FP0mdpTV0mBcuiZVzN6uNAMoUhvIu7Qwj3Ax1mdpTV0mcY4Ca5P6arEMcuZG14qGDD06uReBAx1mynoeyxhTM5jRzeyQzgEAFPzcnNnoeOMj0qOIAg()e9FP8wf6vGGiQybszeSiBjcslgp)HsJvciTjKUTy5eCO0yLasBBH0TflNGdLgReqQlGu()e9FP8wf6vGGiQybszeSiBjcslgp)HsJvciLDi1nBrbPbG0gG0gG0CiWk9c8WYYGESghcSdPbG0TflNGdLgReqAtiL)pr)xkVapSSmO)qPXkbKgas5)t0)LYlWdlld6puASsaPnHu3rbPncPTTqAdqk)FI(VuEr(NeaNlLbt1bB7q)wLGaCixEUyeKMecPSdPBlwobhknwjG0aqk)FI(VuEr(NeaNlLbt1bB7q)wLGaCixEUyeKMecPnHu3HhsBesBBH0gGu()e9FP8I8pjaoxkdMQd22HEU8CXOasjbPrbPbGu()e9FP8I8pjaoxkdMQd22H(dLgReqk7q62ILtWHsJvciTriTrntO5a1iHAg5NOdIOILo1kTM2vndwJdb21rRz4NL4zJMPbi1rDV9c8WYYGEvYqABlK6OU3Er(NeaNlLbt1bB7qVkziTrinaKsgtFevSaPmcwKTebPfJNF4PfcH02wi15fcinaKUTy5eCO0yLaszNeKUkrPzgEAFPzi)P9Lo1kXQAx1mynoeyxhTMHFwINnAgh192lWdlld6vjRzgEAFPz4dbby4P9fGWePMHWejOgjuZiWdlldQtTsHx7QMbRXHa76O1m8Zs8SrZ4OU3(fCi)La8BWFD88QK1mdpTV0m8HGam80(cqyIuZqyIeuJeQzwWH8xcWVb)1XtNALwfTRAgSghcSRJwZWplXZgntAsiKYoKYQqAaiLlBqk7qA4H0aq66GuYy6JOIfiLrWISLiiTy88dpTqOMz4P9LMHpeeGHN2xactKAgctKGAKqnZtgl80PwPWT2vndwJdb21rRzgEAFPz2Mib)gKYiyr2seKwmEAg(zjE2Oz4YMxAIaPUas5YgK2KeKUgKgasBasXcV4G(0Kqq(aPjcKYoK6gsBBHuSWloOpnjeKpqAIaPSdPSkKgas5)t0)LYVnrka)gSvVG(dLgReqk7qQBF4H02wiL)pr)xk)coK)sa(n4VoE(dLgReqk7qkBqAJqAaiDDqAhDu3BVZxyxvKaNdxaD0rDV9QK1m8GCceKZfJPqRKBDQvkCQDvZG14qGDD0Ag(zjE2Oz4YMxAIaPUas5YgK2KeK6gsdaPnaPyHxCqFAsiiFG0ebszhsDdPTTqk)FI(VuEbEyzzq)HsJvciLDiLniTTfsXcV4G(0Kqq(aPjcKYoKYQqAaiL)pr)xk)2ePa8BWw9c6puASsaPSdPU9HhsBBHu()e9FP8l4q(lb43G)645puASsaPSdPSbPncPbG01bPoQ7T35lSRksGZHlEvYAMHN2xAgmczKaipNKo1kTEAx1mynoeyxhTMz4P9LMjTy8aKhcjnd)SepB0m8xY5bI8mfiKgas5YMxAIaPUas5YgK2KeKYgKgasBasXcV4G(0Kqq(aPjcKYoK6gsBBHu()e9FP8c8WYYG(dLgReqk7qkBqABlKIfEXb9PjHG8bsteiLDiLvH0aqk)FI(Vu(Tjsb43GT6f0FO0yLaszhsD7dpK22cP8)j6)s5xWH8xcWVb)1XZFO0yLaszhszdsBesdaPRds7OJ6E7D(c7QIe4C4cOJoQ7TxLSMHhKtGGCUymfALCRtTsUJs7QMbRXHa76O1m8Zs8SrZSoinhcSsVapSSmOhRXHa7AMHN2xAg(qqagEAFbimrQzimrcQrc1m8oqGBDQvYTBTRAgSghcSRJwZWplXZgntoeyLEbEyzzqpwJdb21mdpTV0m8HGam80(cqyIuZqyIeuJeQz4DGapSSmOo1k5MnTRAgSghcSRJwZWplXZgnZWtlecWcLmuaPSdPRPzgEAFPz4dbby4P9fGWePMHWejOgjuZisDQvY9AAx1mynoeyxhTMHFwINnAMHNwieGfkzOasBscsxtZm80(sZWhccWWt7laHjsndHjsqnsOMzEuN6uZq(q(l5mP2vTsU1UQzgEAFPzC(mjWoytmbX(IvXG8JyLMbRXHa76O1Pwj20UQzWACiWUoAnZtwZiWuZm80(sZeAoBCiqntOHqf1mOlr1itg7ERe8tnhhce4suNkvLaDmKXriTTfsrxIQrMm29Xet3M8pbWz6XiK22cPOlr1itg7(LBszr(fcPTTqk6sunYKXU)dHhxEUySdMYKgGZKjEbH02wifDjQgzYy3lKN(VeFJGmi)eL0mHMduJeQzIOIf4lGQab5zLcm1PwP10UQzgEAFPz2eOqMFZo1mynoeyxhTo1kXQAx1mynoeyxhTMHFwINnAM1bP5qGv6f4HLLb9ynoeyhsBBH01bP5qGv63Mib)gKYiyr2seKwmEESghcSRzgEAFPz4YgWr9ePo1kfETRAgSghcSRJwZWplXZgnZ6G0CiWk9yHxSTQAvmajSi45XACiWUMz4P9LMHlBGLjeQtDQzMh1UQvYT2vnZWt7lnZISDewfd63e)fGSAXL1mynoeyxhTo1kXM2vndwJdb21rRz4NL4zJMHlBEPjcK6ciLlBqAtsqkBqAaifl8Id6ttcb5dKMiqAtiLniTTfs5YMxAIaPUas5YgK2KeKYQAMHN2xAgSWl2wvTkgGewe70PwP10UQzWACiWUoAnd)SepB0m8xY5bI8mfiKgasBasDu3BFFkoc(nGlBScZRsgsBBH0o6OU3ENVWUQibohUa6OJ6E7vjdPnQzgEAFPzeKTQSkgWVPqGcJRqNALyvTRAgSghcSRJwZWplXZgndw4fh0NMecYhinrG0Mqkgb5QjcstcH02wiLlBEPjcK6ciLlBqk7KGu3AMHN2xAMTjsb43GT6fuNALcV2vndwJdb21rRzgEAFPzotyvmqOwafgxHMHFwINnAMgG0CiWk9lY2ryvmOFt8xaYQfx2J14qGDinaKY)NO)lL)mHvXaHAbuyCf(U6nP9fK2es5)t0)LYViBhHvXG(nXFbiRwCz)HsJvcinmiLvH0gH0aqAdqk)FI(Vu(Tjsb43GT6f0FO0yLasBcPRbPTTqkx2G0MKG0WdPnQz4b5eiiNlgtHwj36uR0QODvZG14qGDD0Ag(zjE2OzCu3B)PkKTkgWkMocwSQ77)sPzgEAFPzovHSvXawX0rWIvDDQvkCRDvZG14qGDD0Ag(zjE2Oz4YMxAIaPUas5YgK2KeK6wZm80(sZGriJea55K0PwPWP2vndwJdb21rRzgEAFPz2Mib)gKYiyr2seKwmEAg(zjE2Oz4YMxAIaPUas5YgK2KeKUMMHhKtGGCUymfALCRtTsRN2vndwJdb21rRz4NL4zJMHlBEPjcK6ciLlBqAtsqkBAMHN2xAgUSbCuprQtTsUJs7QMbRXHa76O1m8Zs8SrZ4OU3(ugbOez8(ta4d5HB5FEroCfqAti196bPbGuSWloOpnjeKpqAIaPnHumcYvteKMecPUasDdPbGu()e9FP8BtKcWVbB1lO)qPXkbK2esXiixnrqAsOMz4P9LMHFdxbHvXawX0raHflNLvX6uRKB3Ax1mynoeyxhTMz4P9LMjTy8aKhcjnd)SepB0mCzZlnrGuxaPCzdsBscszdsdaPnaPRdsZHaR0lBjG)soVhRXHa7qABlKYFjNhiYZuGqAJAgEqobcY5IXuOvYTo1k5MnTRAgSghcSRJwZWplXZgndx28stei1fqkx2G0MKGu3AMHN2xAM54tHG8VdRuNALCVM2vndwJdb21rRz4NL4zJMH)sopqKNPaH0aqAdqk)FI(VuENVWUQibohU4puASsaPnHu2G02wiDDqk)dH1uPVq(9e)1H0gH0aqAdqkx2G0MKG0WdPTTqk)FI(Vu(Tjsb43GT6f0FO0yLasBcPRcK22cP8)j6)s53MifGFd2Qxq)HsJvciTjKUgKgas5YgK2KeKUgKgasXcV4G(0Kqq(GWhfKYoK6gsBBHuSWloOpnjeKpqAIaPStcsBasxdsddsxdsdhqk)FI(Vu(Tjsb43GT6f0FO0yLaszhsdpK2iK22cPoQ7TxK)jbW5szWuDW2o0RsgsBuZm80(sZiiBvzvmGFtHafgxHo1k5Mv1UQzWACiWUoAnd)SepB0m8xY5bI8mfOMz4P9LMHlBGLjeQtTsUdV2vndwJdb21rRzgEAFPz2ebTkgiWJmwjqHXvOz4NL4zJMXrDV9oVca575((VuAgRs8ovYPMXTo1k5Ev0UQzWACiWUoAnZWt7lnJdXWv8QjqHXvOz4NL4zJMH)sopqKNPaH0aqAdqQJ6E7DEfaY3Z9QKH02winhcSsVSLa(l58ESghcSdPbGuYhgceZ7E3(0IXdqEiKG0aqkx2GusqkBqAaiL)pr)xk)2ePa8BWw9c6puASsaPSdPRbPTTqkx28stei1fqkx2Gu2jbPUH0aqk5ddbI5DVBVGSvLvXa(nfcuyCfqAaifl8Id6ttcb5dKMiqk7q6AqAJAgEqobcY5IXuOvYTo1Po1mHWtyFPvITOyZDuH7OcVMzzUYQyHMz17sVQOu4IsRARgKcPUkJqQjr(Ves3)bPSEbhYFja)g8xhpwdPh6suTd7qQ4LqiDuZxAsSdPC5PIrHhYY6BfcPSTAqkR8Rq4LyhszDoeyLExM1qA(qkRZHaR07YESghcSZAiDsinCDvF9H0gChPrpKL13kesxB1Guw5xHWlXoKY6CiWk9UmRH08HuwNdbwP3L9ynoeyN1q6KqA46Q(6dPn4osJEilRVviK6MvxniDvbL(qyhsLSA1CziLlJCfqAd1Nq6eAmIXHaHuRGuusLys7RgH0gChPrpKL13keszlQvdszLFfcVe7qkRZHaR07YSgsZhszDoeyLEx2J14qGDwdPn4osJEilqww9U0RkkfUO0Q2QbPqQRYiKAsK)lH09FqkRf4HLLbznKEOlr1oSdPIxcH0rnFPjXoKYLNkgfEilRVviK6oQvdszLFfcVe7qkRZHaR07YSgsZhszDoeyLEx2J14qGDwdPtcPHRR6RpK2G7in6HSazz17sVQOu4IsRARgKcPUkJqQjr(Ves3)bPSM3bc8WYYGSgsp0LOAh2HuXlHq6OMV0Kyhs5YtfJcpKL13kesxVvdszLFfcVe7qkRp1c3)fJExM1qA(qkRp1c3)fJEx2J14qGDwdPn4osJEilRVviK6o8RgKYk)keEj2HuwFQfU)lg9UmRH08HuwFQfU)lg9UShRXHa7SgsNesdxx1xFiTb3rA0dzz9TcHu2yB1Guw5xHWlXoKYAXRs4yv37YSgsZhszT4vjCSQ7DzpwJdb2znK2G7in6HSazz17sVQOu4IsRARgKcPUkJqQjr(Ves3)bPSwKSgsp0LOAh2HuXlHq6OMV0Kyhs5YtfJcpKL13kesz1vdszLFfcVe7qkRZHaR07YSgsZhszDoeyLEx2J14qGDwdPn4osJEilRVviKUkRgKYk)keEj2HuwNdbwP3LznKMpKY6CiWk9UShRXHa7SgsBWDKg9qwwFRqi1nRUAqkR8Rq4LyhszDoeyLExM1qA(qkRZHaR07YESghcSZAiTb3rA0dzbYYQ3LEvrPWfLw1wnifsDvgHutI8FjKU)dsznVde4M1q6HUev7WoKkEjesh18LMe7qkxEQyu4HSS(wHqkBRgKYk)keEj2HuwFQfU)lg9UmRH08HuwFQfU)lg9UShRXHa7SgsBWDKg9qwwFRqiDTvdszLFfcVe7qkRp1c3)fJExM1qA(qkRp1c3)fJEx2J14qGDwdPn4osJEilRVviK6o8RgKYk)keEj2HuwFQfU)lg9UmRH08HuwFQfU)lg9UShRXHa7SgsNesdxx1xFiTb3rA0dzz9TcHu2y1vdszLFfcVe7qkRfVkHJvDVlZAinFiL1IxLWXQU3L9ynoeyN1qAdUJ0OhYcKLvVl9QIsHlkTQTAqkK6QmcPMe5)siD)hKY6oUhvIK1q6HUev7WoKkEjesh18LMe7qkxEQyu4HSS(wHqkBRgKYk)keEj2HuwNdbwP3LznKMpKY6CiWk9UShRXHa7SgsBWDKg9qwwFRqi1DuRgKYk)keEj2HuwNdbwP3LznKMpKY6CiWk9UShRXHa7SgsNesdxx1xFiTb3rA0dzz9TcHu3UxniLv(vi8sSdPSohcSsVlZAinFiL15qGv6DzpwJdb2znKojKgUUQV(qAdUJ0OhYcKLvVl9QIsHlkTQTAqkK6QmcPMe5)siD)hKY65rwdPh6suTd7qQ4LqiDuZxAsSdPC5PIrHhYY6BfcPHF1Guw5xHWlXoKY6CiWk9UmRH08HuwNdbwP3L9ynoeyN1qAdUJ0OhYY6BfcPUDVAqkR8Rq4LyhszDoeyLExM1qA(qkRZHaR07YESghcSZAiTb3rA0dzz9TcHu3RYQbPSYVcHxIDiL15qGv6DzwdP5dPSohcSsVl7XACiWoRH0gChPrpKfilHlsK)lXoKUEq6Wt7liLWePWdzrZmQP8FAggtIvQziF)2iqnZQB1bPRER6ldHc8GuxQ)sbKLv3QdszrLiiKY2AkdPSffBUHSazz1T6GuxxWrbK6sHjsbK(Bi1Lc1liKAvI3PsoHuIp24EilRUvhK66cokGugYwvwfdPSYBkesDP04kGuIp24EilRUvhK6s37qQZleBlwoHuUmYviG08HuPPccPSsxQGuSYZqHhYcKLv3QdsdxJGC1e7qQdU)dHu(l5mjK6GXwj8qQlnNJKtbKwF5c55K2Qeq6Wt7lbK(frqpKLHN2xcp5d5VKZKHrAfNptcSd2etqSVyvmi)iwbzz4P9LWt(q(l5mzyKwj0C24qGkxJeskIkwGVaQceKNvkWu5NmjbMkhAiursOlr1itg7ERe8tnhhce4suNkvLaDmKXX2w0LOAKjJDFmX0Tj)taCMEm22IUevJmzS7xUjLf5xyBl6sunYKXU)dHhxEUySdMYKgGZKjEbBBrxIQrMm29c5P)lX3iidYprjildpTVeEYhYFjNjdJ0kBcuiZVzNqwgEAFj8KpK)sotggPv4YgWr9ePY2M06YHaR0lWdlld6XACiWEB76YHaR0Vnrc(niLrWISLiiTy88ynoeyhYYWt7lHN8H8xYzYWiTcx2altiuzBtAD5qGv6XcVyBv1QyasyrWZJ14qGDilqwwDRoinCncYvtSdPyi8ccPPjHqAkJq6WZ)GutaPtOXighc0dzz4P9LGKGmohqEQoqKNPaHSm80(segPvcnNnoeOY1iHKKFIoiIkwk)KjjWu5qdHksI)pr)xkVvHEfiiIkwGugblYwIG0IXZFO0yLO52ILtWHsJvI22TflNGdLgReUG)pr)xkVvHEfiiIkwGugblYwIG0IXZFO0yLGD3SfvGgAihcSsVapSSmyGTflNGdLgRen5)t0)LYlWdlld6puASseG)pr)xkVapSSmO)qPXkrt3r1yBBd8)j6)s5f5FsaCUugmvhSTd9BvccWHC55IrqAsi7BlwobhknwjcW)NO)lLxK)jbW5szWuDW2o0VvjiahYLNlgbPjHnDh(gBBBG)pr)xkVi)tcGZLYGP6GTDONlpxmkifva()e9FP8I8pjaoxkdMQd22H(dLgReSVTy5eCO0yLOXgHSm80(segPvi)P9LY2MudoQ7TxGhwwg0RsUT1rDV9I8pjaoxkdMQd22HEvYngGmM(iQybszeSiBjcslgp)Wtle2268crGTflNGdLgReStAvIcYYWt7lryKwHpeeGHN2xactKkxJessGhwwguzBtYrDV9c8WYYGEvYqwgEAFjcJ0k8HGam80(cqyIu5AKqsl4q(lb43G)64PSTj5OU3(fCi)La8BWFD88QKHSm80(segPv4dbby4P9fGWePY1iHKEYyHNY2MuAsi7SAaUSXE4dSoYy6JOIfiLrWISLiiTy88dpTqiKLHN2xIWiTY2ej43GugblYwIG0IXtzEqobcY5IXuqYTY2Mex28stexWLTMKwlqdyHxCqFAsiiFG0eHD3TTyHxCqFAsiiFG0eHDwna)FI(Vu(Tjsb43GT6f0FO0yLGD3(W32Y)NO)lLFbhYFja)g8xhp)HsJvc2zRXaRRJoQ7T35lSRksGZHlGo6OU3EvYqwgEAFjcJ0kyeYibqEojLTnjUS5LMiUGlBnj5oqdyHxCqFAsiiFG0eHD3TT8)j6)s5f4HLLb9hknwjyNT2wSWloOpnjeKpqAIWoRgG)pr)xk)2ePa8BWw9c6puASsWUBF4BB5)t0)LYVGd5VeGFd(RJN)qPXkb7S1yG15OU3ENVWUQibohU4vjdzz4P9LimsRKwmEaYdHKY8GCceKZfJPGKBLTnj(l58arEMcmax28stexWLTMKylqdyHxCqFAsiiFG0eHD3TT8)j6)s5f4HLLb9hknwjyNT2wSWloOpnjeKpqAIWoRgG)pr)xk)2ePa8BWw9c6puASsWUBF4BB5)t0)LYVGd5VeGFd(RJN)qPXkb7S1yG11rh19278f2vfjW5WfqhDu3BVkzildpTVeHrAf(qqagEAFbimrQCnsijEhiWTY2M06YHaR0lWdlldczz4P9LimsRWhccWWt7laHjsLRrcjX7abEyzzqLTnPCiWk9c8WYYGqwgEAFjcJ0k8HGam80(cqyIu5AKqsIuzBtA4PfcbyHsgkyFnildpTVeHrAf(qqagEAFbimrQCnsiP5rLTnPHNwieGfkzOOjP1GSazz4P9LWppsAr2ocRIb9BI)cqwT4YqwgEAFj8ZJHrAfSWl2wvTkgGewe7u22K4YMxAI4cUS1KeBbWcV4G(0Kqq(aPjst2AB5YMxAI4cUS1KeRczz4P9LWppggPveKTQSkgWVPqGcJRqzBtI)sopqKNPad0GJ6E77tXrWVbCzJvyEvYTTD0rDV9oFHDvrcCoCb0rh192RsUrildpTVe(5XWiTY2ePa8BWw9cQSTjHfEXb9PjHG8bstKMyeKRMiinjSTLlBEPjIl4Yg7KCdzz4P9LWppggPvotyvmqOwafgxHY8GCceKZfJPGKBLTnPgYHaR0ViBhHvXG(nXFbiRwC5a8)j6)s5ptyvmqOwafgxHVREtAF1K)pr)xk)ISDewfd63e)fGSAXL9hknwjcJvBmqd8)j6)s53MifGFd2Qxq)HsJvIMR12YLTMKcFJqwgEAFj8ZJHrALtviBvmGvmDeSyvxzBtYrDV9NQq2QyaRy6iyXQUV)lfKLHN2xc)8yyKwbJqgjaYZjPSTjXLnV0eXfCzRjj3qwgEAFj8ZJHrALTjsWVbPmcwKTebPfJNY8GCceKZfJPGKBLTnjUS5LMiUGlBnjTgKLHN2xc)8yyKwHlBah1tKkBBsCzZlnrCbx2AsInildpTVe(5XWiTc)gUccRIbSIPJaclwolRIv22KCu3BFkJauImE)ja8H8WT8pVihUIMUxVayHxCqFAsiiFG0ePjgb5QjcstcDH7a8)j6)s53MifGFd2Qxq)HsJvIMyeKRMiinjeYYWt7lHFEmmsRKwmEaYdHKY8GCceKZfJPGKBLTnjUS5LMiUGlBnjXwGgwxoeyLEzlb8xY5BB5VKZde5zkWgHSm80(s4NhdJ0kZXNcb5FhwPY2Mex28stexWLTMKCdzz4P9LWppggPveKTQSkgWVPqGcJRqzBtI)sopqKNPad0a)FI(VuENVWUQibohU4puASs0KT221X)qynv6lKFpXF9gd0ax2Ask8TT8)j6)s53MifGFd2Qxq)HsJvIMRsBl)FI(Vu(Tjsb43GT6f0FO0yLO5Ab4YwtsRfal8Id6ttcb5dcFuS7UTfl8Id6ttcb5dKMiStQH1cBTWb)FI(Vu(Tjsb43GT6f0FO0yLG9W3yBRJ6E7f5FsaCUugmvhSTd9QKBeYYWt7lHFEmmsRWLnWYecv22K4VKZde5zkqildpTVe(5XWiTYMiOvXabEKXkbkmUcLTnjh19278kaKVN77)sPSvjENk5KKBildpTVe(5XWiTIdXWv8QjqHXvOmpiNab5CXyki5wzBtI)sopqKNPad0GJ6E7DEfaY3Z9QKBBZHaR0lBjG)soFaYhgceZ7E3(0IXdqEiKcWLnsSfG)pr)xk)2ePa8BWw9c6puASsW(ATTCzZlnrCbx2yNK7aKpmeiM39U9cYwvwfd43uiqHXveal8Id6ttcb5dKMiSVwJqwGSm80(s45DGa3KSk0RabruXcKYiyr2seKwmEkBBsRl0C24qGE5NOdIOIvGg4)t0)LYFMWQyGqTakmUc)HsJvc2zRTDD8pewtLEfbpBQgd0W64FiSMk9fYVN4VEBl)FI(VuENVWUQibohU4puASsWoBn22UTy5eCO0yLGD2cpKLHN2xcpVde4omsRKVkxg8BqhNuwzBtABXYj4qPXkrZgChoJYfNAH7)Ir)EYHaKVkxoC4MTOAST1rDV9I8pjaoxkdMQd22H((VubiJPpIkwGugblYwIG0IXZp80cHTToVqeyBXYj4qPXkb7UJcYYWt7lHN3bcChgPvwWH8xcWVb)1XtzBtQHBSoadHv6NEx4TQjRg(22BSoadHv6NEx4vj3ya()e9FP8NjSkgiulGcJRWFO0yLGDmcYvteKMegG)pr)xkVvHEfiiIkwGugblYwIG0IXZFO0yLOzdSfvySfv44ulC)xm6Tk0RapbOJewSC2yBRZleb2wSCcouASsW(AHhYYWt7lHN3bcChgPv2dsyfce5lrwzBtI)sopqKNPad0WnwhGHWk9tVl8w10DuTT3yDagcR0p9UWRsUrildpTVeEEhiWDyKwzpeeyb(RJNY2M0nwhGHWk9tVl8w1CTOABVX6amewPF6DHxLmKLHN2xcpVde4omsR48f2vfjW5WfLTnjUS1KeBb2wSCcouASs0CvIkqd8)j6)s5f5FsaCUugmvhSTd9C55IrrZOAB5)t0)LYlY)Ka4CPmyQoyBh6puASs00DungObYy6JOIfiLrWISLiiTy88dpTqyBl)FI(VuERc9kqqevSaPmcwKTebPfJN)qPXkrt3r12gAoBCiqV8t0bruXQX22g4YwtsSfyBXYj4qPXkb7KwLOc0azm9ruXcKYiy1lBjcslgp)Wtle22Y)NO)lL3QqVceerflqkJGfzlrqAX45puASs0CBXYj4qPXkrJbAG)pr)xkVi)tcGZLYGP6GTDONlpxmkAgvBl)FI(VuEr(NeaNlLbt1bB7q)HsJvIMBlwobhknwjABDu3BVi)tcGZLYGP6GTDOxLCJn22UTy5eCO0yLGD3HhYYWt7lHN3bcChgPve5FsaCUugmvhSTdbBlYKOY2Me)RUQLE()x3QjXo43BSewi0J14qGDildpTVeEEhiWDyKwrK)jbW5szWuDW2ouzBtI)pr)xkVi)tcGZLYGP6GTDONlpxmkiXwB72ILtWHsJvc2zlQ22gUX6amewPF6DH)qPXkrt3HVTTH1X)qynv6ve8SPcSo(hcRPsFH87j(R3yGgA4gRdWqyL(P3fERAY)NO)lLxK)jbW5szWuDW2o0VvjiahYLNlgbPjHTTR7gRdWqyL(P3fEmIjsrJbAG)pr)xkVvHEfiiIkwGugblYwIG0IXZFO0yLOj)FI(VuEr(NeaNlLbt1bB7q)wLGaCixEUyeKMe22gAoBCiqV8t0bruXQXgdW)NO)lLFBIua(nyREb9hknwjyN06fGlBnjXwa()e9FP8lY2ryvmOFt8xaYQfx2FO0yLGDsUzRrildpTVeEEhiWDyKwrK)jbW5szWuDW2ouzBtI)HWAQ0Ri4ztfObh192VGd5VeGFd(RJNxLCBBdBlwobhknwjyN)pr)xk)coK)sa(n4VoE(dLgReTT8)j6)s5xWH8xcWVb)1XZFO0yLOj)FI(VuEr(NeaNlLbt1bB7q)wLGaCixEUyeKMe2ya()e9FP8BtKcWVbB1lO)qPXkb7KwVaCzRjj2cW)NO)lLFr2ocRIb9BI)cqwT4Y(dLgReStYnBnczz4P9LWZ7abUdJ0kI8pjaoxkdMQd22HkBBs8pewtL(c53t8xpqhDu3BVZxyxvKaNdxaD0rDV9QKd0azm9ruXcKYiyr2seKwmE(HNwiSTn0C24qGE5NOdIOIvBl)FI(VuERc9kqqevSaPmcwKTebPfJN)qPXkrt()e9FP8I8pjaoxkdMQd22H(Tkbb4qU8CXiinjSTL)pr)xkVvHEfiiIkwGugblYwIG0IXZFO0yLO5Ar1iKLHN2xcpVde4omsRyLGFQ54qGaxI6uPQeOJHmoQSTjrgtFevSaPmcwKTebPfJNF4PfcBBDEHiW2ILtWHsJvc2zlkildpTVeEEhiWDyKwz5MuwKFHkBBsKX0hrflqkJGfzlrqAX45hEAHW2wNxicSTy5eCO0yLGD2IcYYWt7lHN3bcChgPvIjMUn5FcGZ0JrLTnjYy6JOIfiLrWISLiiTy88dpTqyBRZleb2wSCcouASsWoBrbzz4P9LWZ7abUdJ0kQceyjkPCnsiP(HtFBhccHcbsOSTjTUqZzJdb6JOIf4lGQab5zLcmBB5)t0)LYBvOxbcIOIfiLrWISLiiTy88hknwjAYwubiJPpIkwGugblYwIG0IXZFO0yLGD2IQTn0C24qGE5NOdIOIfKLHN2xcpVde4omsROkqGLOKY1iHKeYt)xIVrqgKFIskBBsKX0hrflqkJGfzlrqAX45hEAHW2wNxicSTy5eCO0yLGD2IQTDDNAH7)IrVvHEf4jaDKWILtildpTVeEEhiWDyKwrvGalrjHY2M06cnNnoeOpIkwGVaQceKNvkWSTL)pr)xkVvHEfiiIkwGugblYwIG0IXZFO0yLOjBr12gAoBCiqV8t0bruXcYYWt7lHN3bcChgPvYxLld(nqXCsJY2M02ILtWHsJvIMRxuTTKX0hrflqkJGfzlrqAX45hEAHW22qZzJdb6LFIoiIkwTToVqeyBXYj4qPXkb7UxfildpTVeEEhiWDyKwXH4)oyREbv22K4)t0)LYBvOxbcIOIfiLrWISLiiTy88hknwjAUwuTTHMZghc0l)eDqevSABDEHiW2ILtWHsJvc2zlkildpTVeEEhiWDyKwXbpbEkSkwzBtI)pr)xkVvHEfiiIkwGugblYwIG0IXZFO0yLO5Ar12gAoBCiqV8t0bruXQT15fIaBlwobhknwjy3D4HSm80(s45DGa3HrAfclwofawHApwcReYYWt7lHN3bcChgPv22Hoe)3v22K4)t0)LYBvOxbcIOIfiLrWISLiiTy88hknwjAUwuTTHMZghc0l)eDqevSABDEHiW2ILtWHsJvc2DhfKLHN2xcpVde4omsRmfhf5nea(qqOSTjX)NO)lL3QqVceerflqkJGfzlrqAX45puASs0CTOABdnNnoeOx(j6GiQy1268crGTflNGdLgReSZwuqwgEAFj88oqG7WiTIZed(nipJRqOSTj5OU3Er(NeaNlLbt1bB7qF)xkildpTVeEEhiWDyKwztGcz(n7uzBts8Qeow19KvfPkbcWtLCAFfWrDV9I8pjaoxkdMQd22H((Vub6OJ6E7D(c7QIe4C4cOJoQ7TV)lfKfildpTVeEEhiWdlldsk0C24qGkxJessGhwwge4OEIu5NmjbMkhAiurs8)j6)s5f4HLLb9hknwjy3DBlzm9ruXcKYiyr2seKwmE(HNwima)FI(VuEbEyzzq)HsJvIMRfvBRZleb2wSCcouASsWoBrbzz4P9LWZ7abEyzzWWiTIvHEfiiIkwGugblYwIG0IXtzBtADHMZghc0l)eDqevSABDEHiW2ILtWHsJvc2zl8qwgEAFj88oqGhwwgmmsR4q8FhSvVGkBBsHMZghc0lWdlldcCuprczz4P9LWZ7abEyzzWWiTIdEc8uyvSY2MuO5SXHa9c8WYYGah1tKqwgEAFj88oqGhwwgmmsRqyXYPaWku7XsyLqwgEAFj88oqGhwwgmmsRSTdDi(VRSTjfAoBCiqVapSSmiWr9ejKLHN2xcpVde4HLLbdJ0ktXrrEdbGpeekBBsHMZghc0lWdlldcCuprczz4P9LWZ7abEyzzWWiTIZed(nipJRqOSTjfAoBCiqVapSSmiWr9ejKLHN2xcpVde4HLLbdJ0k5RYLb)g0XjLv22K2wSCcouASs0Sb3HZOCXPw4(Vy0VNCia5RYLdhUzlQgBBjJPpIkwGugblYwIG0IXZp80cHTToVqeyBXYj4qPXkb7UJcYYWt7lHN3bc8WYYGHrAL8v5YGFdumN0OSTjTTy5eCO0yLO56fvBlzm9ruXcKYiyr2seKwmE(HNwiST15fIaBlwobhknwjy3DuqwgEAFj88oqGhwwgmmsRSGd5VeGFd(RJNY2Me)FI(Vu(ZewfdeQfqHXv4puASsWogb5QjcstcHSm80(s45DGapSSmyyKwXkb)uZXHabUe1PsvjqhdzCuzBtk0C24qGEbEyzzqGJ6jsildpTVeEEhiWdlldggPvwUjLf5xOY2MuO5SXHa9c8WYYGah1tKqwgEAFj88oqGhwwgmmsRetmDBY)eaNPhJkBBsHMZghc0lWdlldcCuprczz4P9LWZ7abEyzzWWiTIQabwIskxJessip9Fj(gbzq(jkPSTjrgtFevSaPmcwKTebPfJNF4PfcBBDEHiW2ILtWHsJvc2zlQ221DQfU)lg9wf6vGNa0rclwoHSm80(s45DGapSSmyyKwrvGalrjHY2M06cnNnoeOpIkwGVaQceKNvkWSTL)pr)xkVvHEfiiIkwGugblYwIG0IXZFO0yLOjBr12gAoBCiqV8t0bruXcYYWt7lHN3bc8WYYGHrAL9GewHar(sKHSm80(s45DGapSSmyyKwzpeeyb(RJhKLHN2xcpVde4HLLbdJ0koFHDvrcCoCrzBtY5fIaBlwobhknwjy3D4BBBGlBnjXwGg2wSCcouASs0CvIkqdnW)NO)lLxGhwwg0FO0yLOP7OABDu3BVapSSmOxLCBl)FI(VuEbEyzzqVk5gd0azm9ruXcKYiyr2seKwmE(HNwiSTL)pr)xkVvHEfiiIkwGugblYwIG0IXZFO0yLOP7OABdnNnoeOx(j6GiQy1yJn222W2ILtWHsJvc2jTkrfObYy6JOIfiLrWQx2seKwmE(HNwiSTL)pr)xkVvHEfiiIkwGugblYwIG0IXZFO0yLO52ILtWHsJvIgBSrildpTVeEEhiWdlldggPve4HLLbv22K4)t0)LYFMWQyGqTakmUc)HsJvc2zRT15fIaBlwobhknwjy3D4HSm80(s45DGapSSmyyKwXzIb)gKNXviGSm80(s45DGapSSmyyKwztGcz(n7uzBts8Qeow19KvfPkbcWtLCAFfWrDV9c8WYYG((Vub6OJ6E7D(c7QIe4C4cOJoQ7TV)lfKfildpTVe(Nmw4rABIe8BqkJGfzlrqAX4PmpiNab5CxmMcsUv22K4YMxAI4cUS1K0AqwgEAFj8pzSWlmsRGriJea55Ku22KYHaR0ZLnGJ6jspwJdb2dWLnV0eXfCzRjP1GSm80(s4FYyHxyKwjTy8aKhcjL5b5eiiNlgtbj3kBBs8xY5bI8mfyaUS5LMiUGlBnjXgKLHN2xc)tgl8cJ0kCzdSmHqLTnjUS5LMiUGlBKydYYWt7lH)jJfEHrAfmczKaipNeKLHN2xc)tgl8cJ0kPfJhG8qiPmpiNab5CXyki5wzBtIlBEPjIl4YwtsSbzbYYWt7lHxGhwwgK02ePa8BWw9cQSTj5OU3EbEyzzq)HsJvc2Ddzz4P9LWlWdlldggPveKTQSkgWVPqGcJRqzBtI)sopqKNPad0WWtlecWcLmu0K0ATTdpTqialuYqrt3bwh)FI(Vu(ZewfdeQfqHXv4vj3iKLHN2xcVapSSmyyKw5mHvXaHAbuyCfkZdYjqqoxmMcsUv22K4VKZde5zkqildpTVeEbEyzzWWiTY2ePa8BWw9cQSTjn80cHaSqjdfnjTgKLHN2xcVapSSmyyKwrq2QYQya)McbkmUcLTnj(l58arEMcmGJ6E77tXrWVbCzJvyEvYqwgEAFj8c8WYYGHrAfhIHR4vtGcJRqzEqobcY5IXuqYTY2Me)LCEGiptbgWrDV9l4q(lb43G)645vjhG)pr)xk)zcRIbc1cOW4k8hknwjAYgKLHN2xcVapSSmyyKwzBIua(nyREbv2QeVtLCcSnjh192lWdlld6vjhG)pr)xk)zcRIbc1cOW4k8ho9GqwgEAFj8c8WYYGHrAfbzRkRIb8BkeOW4ku22K4VKZde5zkWaD0rDV9oFHDvrcCoCb0rh192RsgYYWt7lHxGhwwgmmsRSnrc(niLrWISLiiTy8uMhKtGGCUymfKCRSTjXLn2xdYYWt7lHxGhwwgmmsR4qmCfVAcuyCfkZdYjqqoxmMcsUv22K4VKZde5zkW221LdbwPx2sa)LCEildpTVeEbEyzzWWiTIGSvLvXa(nfcuyCfqwGSm80(s4fjPfz7iSkg0Vj(laz1IlRSTjDJ1byiSs)07cVvn5)t0)LYViBhHvXG(nXFbiRwCzFx9M0(kCeLpC22EJ1byiSs)07cVkzildpTVeErggPvWcVyBv1QyasyrStzBtIlBEPjIl4YwtsSfal8Id6ttcb5dKMinxRTLlBEPjIl4YwtsSAGgWcV4G(0Kqq(aPjst2ABxh5ddbI5DVBFAX4bipesnczz4P9LWlYWiTIGSvLvXa(nfcuyCfkBBs8xY5bI8mfyah1923NIJGFd4YgRW8QKd0WnwhGHWk9tVl8w10rDV99P4i43aUSXkm)HsJvcxWwB7nwhGHWk9tVl8QKBeYYWt7lHxKHrALZewfdeQfqHXvOmpiNab5CXyki5wzBtI)pr)xkVapSSmO)qPXkrt3TTRlhcSsVapSSmyGg4)t0)LYVGd5VeGFd(RJN)qPXkrtwTTDD8pewtLEfbpBQgHSm80(s4fzyKwzBIua(nyREbv22KA4gRdWqyL(P3fERAY)NO)lLFBIua(nyREb9D1Bs7RWru(WzB7nwhGHWk9tVl8QKBmqdyHxCqFAsiiFG0ePjgb5QjcstcDH72wUS5LMiUGlBStYDBRJ6E7f5FsaCUugmvhSTd9hknwjyhJGC1ebPjHH5UX22TflNGdLgReSJrqUAIG0KWWC322rh19278f2vfjW5WfqhDu3BVkzildpTVeErggPv43WvqyvmGvmDeqyXYzzvSY2MKJ6E7tzeGsKX7pbGpKhUL)5f5Wv0096fal8Id6ttcb5dKMinXiixnrqAsOlChG)pr)xk)zcRIbc1cOW4k8hknwjAIrqUAIG0KW2wh192NYiaLiJ3FcaFipCl)ZlYHROPBwnqd8)j6)s5f4HLLb9hknwjyp8bYHaR0lWdlld22Y)NO)lLFbhYFja)g8xhp)HsJvc2dFa(hcRPsVIGNnvB72ILtWHsJvc2dFJqwgEAFj8ImmsRCQczRIbSIPJGfR6kBBsoQ7T)ufYwfdyfthblw199FPcm80cHaSqjdfnDdzz4P9LWlYWiTY2ej43GugblYwIG0IXtzEqobcY5IXuqYTY2Mex2yFnildpTVeErggPvWiKrcG8CskBBsCzZlnrCbx2AsYnKLHN2xcVidJ0kCzd4OEIuzBtIlBEPjIl4YwtsUdm80cHaSqjdfKCh4gRdWqyL(P3fERAYwuTTCzZlnrCbx2AsITadpTqialuYqrtsSbzz4P9LWlYWiTcx2altieYYWt7lHxKHrAL0IXdqEiKuMhKtGGCUymfKCRSTjXFjNhiYZuGb4YMxAI4cUS1KeBbCu3BVi)tcGZLYGP6GTDOV)lfKLHN2xcVidJ0kcYwvwfd43uiqHXvOSTj5OU3EUSbWcV4GEroCfnxlkxe(WXWtlecWcLmueWrDV9I8pjaoxkdMQd22H((VubAG)pr)xk)zcRIbc1cOW4k8hknwjAYwa()e9FP8BtKcWVbB1lO)qPXkrt2AB5)t0)LYFMWQyGqTakmUc)HsJvc2xla)FI(Vu(Tjsb43GT6f0FO0yLO5Ab4YwZ1AB5)t0)LYFMWQyGqTakmUc)HsJvIMRfG)pr)xk)2ePa8BWw9c6puASsW(Ab4YwtwTTLlBEPjIl4Yg7KChal8Id6ttcb5dKMiSZwJTToQ7TNlBaSWloOxKdxrt3rfyBXYj4qPXkb7HBildpTVeErggPvCigUIxnbkmUcL5b5eiiNlgtbj3kBBs8xY5bI8mfyGgYHaR0lWdlldgG)pr)xkVapSSmO)qPXkb7R12Y)NO)lL)mHvXaHAbuyCf(dLgRenDhG)pr)xk)2ePa8BWw9c6puASs00DBl)FI(Vu(ZewfdeQfqHXv4puASsW(Ab4)t0)LYVnrka)gSvVG(dLgRenxlax2AYwBl)FI(Vu(ZewfdeQfqHXv4puASs0CTa8)j6)s53MifGFd2Qxq)HsJvc2xlax2AUwBlx2Ag(2wh19278kaKVN7vj3iKLHN2xcVidJ0kPfJhG8qiPmpiNab5CXyki5wzBtI)sopqKNPadWLnV0eXfCzRjj2GSm80(s4fzyKwzo(uii)7Wkv22K4YMxAI4cUS1KKBildpTVeErggPv2ebTkgiWJmwjqHXvOSvjENk5KKBildpTVeErggPvCigUIxnbkmUcL5b5eiiNlgtbj3kBBs8xY5bI8mfya()e9FP8BtKcWVbB1lO)qPXkb7RfGlBKyla5ddbI5DVBFAX4bipesbWcV4G(0Kqq(GWhf7UHSm80(s4fzyKwXHy4kE1eOW4kuMhKtGGCUymfKCRSTjXFjNhiYZuGbWcV4G(0Kqq(aPjc7SfObUS5LMiUGlBStYDBl5ddbI5DVBFAX4bipesnczbYYWt7lHFbhYFja)g8xhpsHMZghcu5AKqsoedxXRMafgxbOqSJDLFYKeyQCOHqfj5OU3(fCi)La8BWFD8all(dLgRebAG)pr)xk)zcRIbc1cOW4k8hknwjA6OU3(fCi)La8BWFD8all(dLgRebCu3B)coK)sa(n4VoEGLf)HsJvc2zZ7UTL)pr)xk)zcRIbc1cOW4k8hknwjCHJ6E7xWH8xcWVb)1XdSS4puASs00TF9c4OU3(fCi)La8BWFD8all(dLgReSZQE3TToQ7T3H4)oHQi9QKd4OU3ERc9kWta6iHflNEvYbCu3BVvHEf4jaDKWILt)HsJvc2Du3B)coK)sa(n4VoEGLf)HsJvIgHSm80(s4xWH8xcWVb)1XlmsRWhccWWt7laHjsLRrcjX7abUv22KwxoeyLEbEyzzqildpTVe(fCi)La8BWFD8cJ0k8HGam80(cqyIu5AKqs8oqGhwwguzBtkhcSsVapSSmiKLHN2xc)coK)sa(n4VoEHrAfSWl2wvTkgGewe7u22K4YMxAI4cUS1KeBbWcV4G(0Kqq(aPjsZ1GSm80(s4xWH8xcWVb)1XlmsRCMWQyGqTakmUcL5b5eiiNlgtbj3qwgEAFj8l4q(lb43G)64fgPv2MifGFd2QxqLTnPHNwieGfkzOOjj2c4OU3(fCi)La8BWFD8all(dLgReS7gYYWt7lHFbhYFja)g8xhVWiTYISDewfd63e)fGSAXLv22KgEAHqawOKHIMKydYYWt7lHFbhYFja)g8xhVWiTIGSvLvXa(nfcuyCfkBBs8xY5bI8mfyGHNwieGfkzOOjP1c4OU3(fCi)La8BWFD8allEvYqwgEAFj8l4q(lb43G)64fgPvCigUIxnbkmUcL5b5eiiNlgtbj3kBBs8xY5bI8mfyGHNwieGfkzOGDsSfi0C24qGEhIHR4vtGcJRaui2XoKLHN2xc)coK)sa(n4VoEHrAfbzRkRIb8BkeOW4ku22K4VKZde5zkWaoQ7TVpfhb)gWLnwH5vjdzz4P9LWVGd5VeGFd(RJxyKwbJqgjaYZjPSTjXLnsrfWrDV9l4q(lb43G)64bww8hknwjyNvHSm80(s4xWH8xcWVb)1XlmsRSnrc(niLrWISLiiTy8uMhKtGGCUymfKCRSTjXLnsrfWrDV9l4q(lb43G)64bww8hknwjyNvHSm80(s4xWH8xcWVb)1XlmsRSiBhHvXG(nXFbiRwCzildpTVe(fCi)La8BWFD8cJ0kPfJhG8qiPCoxmMaBtsYQvRJoQ7TxAofGFdszeWVPq)HsJvIWAOJoQ7TxOi4HdxgGrKhvrAF5vjhoylQgv22K4YgPOc4OU3(fCi)La8BWFD8all(dLgReSZQqwgEAFj8l4q(lb43G)64fgPv2MifGFd2QxqLTkX7ujNaBtYrDV9l4q(lb43G)64bww8QKv22KCu3BVi)tcGZLYGP6GTDOxLCGBSoadHv6NEx4TQj)FI(Vu(Tjsb43GT6f03vVjTVchr5xfildpTVe(fCi)La8BWFD8cJ0kcYwvwfd43uiqHXvOSTj5OU3EUSbWcV4GEroCfnxlkxe(WXWtlecWcLmuazz4P9LWVGd5VeGFd(RJxyKwzBIe8BqkJGfzlrqAX4PmpiNab5CXyki5wzBtIlBSVgKLHN2xc)coK)sa(n4VoEHrAfmczKaipNKY2Mex28stexWLTMKCdzz4P9LWVGd5VeGFd(RJxyKwHlBah1tKkBBsCzZlnrCbx2AsQb3Hn80cHaSqjdfnD3iKLHN2xc)coK)sa(n4VoEHrAL0IXdqEiKuMhKtGGCUymfKCRSTj1W6YHaR0lBjG)soFBl)LCEGiptb2yaUS5LMiUGlBnjXgKLHN2xc)coK)sa(n4VoEHrAfhIHR4vtGcJRqzEqobcY5IXuqYTY2M0WtlecWcLmuWoP1cWLTMKwRT1rDV9l4q(lb43G)64bww8QKHSm80(s4xWH8xcWVb)1XlmsRWLnWYecHSm80(s4xWH8xcWVb)1XlmsRSjcAvmqGhzSsGcJRqzRs8ovYjj36uNAna]] )


end