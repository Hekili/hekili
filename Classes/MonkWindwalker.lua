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


    spec:RegisterPack( "Windwalker", 20210829, [[dSecGcqiPO6rckQnrL6tOenkHkNsOQvjOiVsq1SOsClsu2fv9lPidtk0XeWYiHEMsQMgkHUMGsBtkk(MuuQXrIQCoLuyDkPO5rcUhISpLKdsIkzHsbpujLAIKOsLlsIQQnsIkfFujLWjjrvzLOKEjjQuAMOe4MKOsv7Ke5NkPeTuPOKEkkMkvsFvjL0yfuyVK6VadgPdRyXuXJr1KLQldTzL6Zcz0e1PPSAuc61OuZgHBts7wYVv1WruhNevSCvEoHPl66ez7cY3LsJxOCEbA9srjMVsSFqRdODvZ0Ne1kPyJkgOrLNIRHpqZUXWU(6AMmizuZqE4SNiuZuJkQzwRw1Bhc24Pzipbj(PRDvZiEPJJAgnJJKrKkFL2rZ0Ne1kPyJkgOrLNIRHpqZUXWUEanJGmY1kPyZSgAgzR3Xs7Oz6OGRzwRw1Bhc24bPk3)fBiRkxsrsIesvCnCbsvSrfdazfY6AlpxekwtiRkdsDTfh2qQYnMifq6VHuLBKUGqQvjENe5esj(iJ7HSQmi11wCydPmKTQSkcsx7BkesvU14SHuIpY4EiRkdsvU6Di15fITfjNqkxg5SfqA(qQ6ubH01w5oifR8mu41meMifAx1mpzSWt7QwPaAx1mynoeyx3GMz4P9LMzBIe8BqkJGwzlrqAr4Pz4NL4zJMHlBE1jgKQmiLlBq6ksq66AgEqobcY5UimfAMa6uRKIAx1mynoeyx3GMHFwINnAMCiWk9Czd4iDI0J14qGDi1nKYLnV6edsvgKYLniDfjiDDnZWt7lndgJmsaKNtvNALwx7QMbRXHa76g0mdpTV0mPfHhG8qOQz4NL4zJMH)QopqKNXgHu3qkx28Qtmivzqkx2G0vKGuf1m8GCceKZfHPqRuaDQvIf1UQzWACiWUUbnd)SepB0mCzZRoXGuLbPCzdsjbPkQzgEAFPz4YgODcH6uRuy1UQzgEAFPzWyKrcG8CQAgSghcSRBqNALAgTRAgSghcSRBqZm80(sZKweEaYdHQMHFwINnAgUS5vNyqQYGuUSbPRibPkQz4b5eiiNlctHwPa6uNAMwCi)La8BWFD80UQvkG2vndwJdb21nOzEYAgbMAMHN2xAMqZzJdbQzcnesOMXrAV9T4q(lb43G)64bAB9hQowjGu3qACqk)FI(3w(ZewfbesfGTXz7puDSsaPRGuhP923Id5VeGFd(RJhOT1FO6yLasDdPos7TVfhYFja)g8xhpqBR)q1XkbKQaKQOpaKUSaP8)j6FB5ptyveqiva2gNT)q1XkbKQmi1rAV9T4q(lb43G)64bAB9hQowjG0vqAa)AaPUHuhP923Id5VeGFd(RJhOT1FO6yLasvaszrFaiDzbsDK2BVdX)Dcjr6LidPUHuhP92BvONnEcqhjSi50lrgsDdPos7T3QqpB8eGosyrYP)q1XkbKQaK6iT3(wCi)La8BWFD8aTT(dvhReqA8AMqZbQrf1moedN9lLa2gNnOqSJDDQvsrTRAgSghcSRBqZWplXZgntZH0CiWk9c8WYYGESghcSRzgEAFPz4dbby4P9fGWePMHWejOgvuZW7abU1PwP11UQzWACiWUUbnd)SepB0m5qGv6f4HLLb9ynoeyxZm80(sZWhccWWt7laHjsndHjsqnQOMH3bc8WYYG6uRelQDvZG14qGDDdAg(zjE2Oz4YMxDIbPkds5YgKUIeKQiK6gsXcVOG(0urq(a1jgKUcsxxZm80(sZGfErwZIvraKWIzNo1kfwTRAgSghcSRBqZm80(sZCMWQiGqQaSnoBndpiNab5Cryk0kfqNALAgTRAgSghcSRBqZWplXZgnZWtlecWcvnuaPRibPkcPUHuhP923Id5VeGFd(RJhOT1FO6yLasvasdOzgEAFPz2MifGFd2sxqDQvQzRDvZG14qGDDdAg(zjE2OzgEAHqawOQHciDfjivrnZWt7lntRSDewfb63e9fGSuXL1PwjLN2vndwJdb21nOz4NL4zJMH)QopqKNXgHu3q6WtlecWcvnuaPRibPRdPUHuhP923Id5VeGFd(RJhOT1lrwZm80(sZiiBvzveGFtHa2gNTo1kTgAx1mynoeyx3GMz4P9LMXHy4SFPeW24S1m8Zs8SrZWFvNhiYZyJqQBiD4PfcbyHQgkGufibPkcPUH0qZzJdb6Digo7xkbSnoBqHyh7AgEqobcY5IWuOvkGo1kfOrTRAgSghcSRBqZWplXZgnd)vDEGipJncPUHuhP923NIJGFd4Ygl08sK1mdpTV0mcYwvwfb43uiGTXzRtTsbcODvZG14qGDDdAg(zjE2Oz4YgKscsBesDdPos7TVfhYFja)g8xhpqBR)q1XkbKQaKYIAMHN2xAgmgzKaipNQo1kfqrTRAgSghcSRBqZm80(sZSnrc(niLrqRSLiiTi80m8Zs8SrZWLniLeK2iK6gsDK2BFloK)sa(n4VoEG2w)HQJvcivbiLf1m8GCceKZfHPqRuaDQvkW6Ax1mdpTV0mTY2ryveOFt0xaYsfxwZG14qGDDd6uRuawu7QMbRXHa76g0mdpTV0mPfHhG8qOQz4NL4zJMHlBqkjiTri1nK6iT3(wCi)La8BWFD8aTT(dvhReqQcqklQz4b5eiiNlctHwPa6uRuGWQDvZG14qGDDdAg(zjE2OzCK2BVi)tfGZLYGP6GTDOxImK6gsVX6amewPF6DH3kiDfKY)NO)TLFBIua(nylDb9DPBs7linmbPn6BgnZWt7lnZ2ePa8BWw6cQzSkX7KiNaBRzCK2BFloK)sa(n4VoEG2wVezDQvkqZODvZG14qGDDdAg(zjE2OzCK2Bpx2ayHxuqVihoBiDfKUEJqQYG0WcPHjiD4PfcbyHQgk0mdpTV0mcYwvwfb43uiGTXzRtTsbA2Ax1mynoeyx3GMz4P9LMzBIe8BqkJGwzlrqAr4Pz4NL4zJMHlBqQcq66AgEqobcY5IWuOvkGo1kfq5PDvZG14qGDDdAg(zjE2Oz4YMxDIbPkds5YgKUIeKgqZm80(sZGXiJea55u1PwPaRH2vndwJdb21nOz4NL4zJMHlBE1jgKQmiLlBq6ksqACqAainCiD4PfcbyHQgkG0vqAainEnZWt7lndx2aosNi1PwjfBu7QMbRXHa76g0mdpTV0mPfHhG8qOQz4NL4zJMjoiT5qAoeyLEzlb8x159ynoeyhsxwGu(R68arEgBesJhsDdPCzZRoXGuLbPCzdsxrcsvuZWdYjqqoxeMcTsb0PwjfdODvZG14qGDDdAMHN2xAghIHZ(LsaBJZwZWplXZgnZWtlecWcvnuaPkqcsxhsDdPCzdsxrcsxhsxwGuhP923Id5VeGFd(RJhOT1lrwZWdYjqqoxeMcTsb0Pwjfvu7QMz4P9LMHlBG2jeQzWACiWUUbDQvsX11UQzSkX7KiNAMaAMHN2xAMnrqRIac8iJvcyBC2AgSghcSRBqN6uZiWdlldQDvRuaTRAgSghcSRBqZWplXZgnJJ0E7f4HLLb9hQowjGufG0aAMHN2xAMTjsb43GT0fuNALuu7QMbRXHa76g0m8Zs8SrZWFvNhiYZyJqQBinoiD4PfcbyHQgkG0vKG01H0LfiD4PfcbyHQgkG0vqAai1nK2CiL)pr)Bl)zcRIacPcW24S9sKH041mdpTV0mcYwvwfb43uiGTXzRtTsRRDvZG14qGDDdAMHN2xAMZewfbesfGTXzRz4NL4zJMH)QopqKNXg1m8GCceKZfHPqRuaDQvIf1UQzWACiWUUbnd)SepB0mdpTqialu1qbKUIeKUUMz4P9LMzBIua(nylDb1PwPWQDvZG14qGDDdAg(zjE2Oz4VQZde5zSri1nK6iT3((uCe8Bax2yHMxISMz4P9LMrq2QYQia)McbSnoBDQvQz0UQzWACiWUUbnZWt7lnJdXWz)sjGTXzRz4NL4zJMH)QopqKNXgHu3qQJ0E7BXH8xcWVb)1XZlrgsDdP8)j6FB5ptyveqiva2gNT)q1XkbKUcsvuZWdYjqqoxeMcTsb0PwPMT2vnJvjENe5eyBnJJ0E7f4HLLb9sKDZ)NO)TL)mHvraHubyBC2(dNEqnZWt7lnZ2ePa8BWw6cQzWACiWUUbDQvs5PDvZG14qGDDdAg(zjE2Oz4VQZde5zSri1nK2rhP9278f2LejW5WwqhDK2BVeznZWt7lnJGSvLvra(nfcyBC26uR0AODvZG14qGDDdAMHN2xAMTjsWVbPmcALTebPfHNMHFwINnAgUSbPkaPRRz4b5eiiNlctHwPa6uRuGg1UQzWACiWUUbnZWt7lnJdXWz)sjGTXzRz4NL4zJMH)QopqKNXgH0LfiT5qAoeyLEzlb8x159ynoeyxZWdYjqqoxeMcTsb0PwPab0UQzgEAFPzeKTQSkcWVPqaBJZwZG14qGDDd6uNAgEhiWdlldQDvRuaTRAgSghcSRBqZ8K1mcm1mdpTV0mHMZghcuZeAiKqnd)FI(3wEbEyzzq)HQJvcivbinaKUSaPKX0htclqkJGwzlrqAr45hEAHqi1nKY)NO)TLxGhwwg0FO6yLasxbPR3iKUSaPoVqaPUH0TfjNGdvhReqQcqQInQzcnhOgvuZiWdlldcCKorQtTskQDvZG14qGDDdAg(zjE2OzAoKgAoBCiqV8t0bXKWcsxwGuNxiGu3q62IKtWHQJvcivbivXWQzgEAFPzSk0ZgbXKWsNALwx7QMbRXHa76g0m8Zs8SrZeAoBCiqVapSSmiWr6ePMz4P9LMXH4)oylDb1Pwjwu7QMbRXHa76g0m8Zs8SrZeAoBCiqVapSSmiWr6ePMz4P9LMXbpbESTksNALcR2vnZWt7lndHfjNcaluQhPIvQzWACiWUUbDQvQz0UQzWACiWUUbnd)SepB0mHMZghc0lWdlldcCKorQzgEAFPz22Hoe)31PwPMT2vndwJdb21nOz4NL4zJMj0C24qGEbEyzzqGJ0jsnZWt7lnZuCuK3qa4dbHo1kP80UQzWACiWUUbnd)SepB0mHMZghc0lWdlldcCKorQzgEAFPzCMiWVb5zC2cDQvAn0UQzWACiWUUbnd)SepB0mBlsobhQowjG0vqACqAaLxJqQYG0tQW9FrOFp5qaYxIl7XACiWoKgMG0ak2iKgpKUSaPKX0htclqkJGwzlrqAr45hEAHqi1nKghK2CiL)HWAQ0xi)EI)6q6YcK6iT3ENVWUKiboh26LidPXdPllqACqk)FI(3wERc9SrqmjSaPmcALTebPfHN)q1XkbKUcs3wKCcouDSsaPXdPUHuhP9278f2LejW5WwVeziDzbsDEHasDdPBlsobhQowjGufG0anQzgEAFPzYxIld(nOJtkRtTsbAu7QMbRXHa76g0m8Zs8SrZW)NO)TL)mHvraHubyBC2(dvhReqQcqkgd5sjcstf1mdpTV0mT4q(lb43G)64PtTsbcODvZG14qGDDdAg(zjE2OzcnNnoeOxGhwwge4iDIuZm80(sZyLGFs54qGaLJ0uPKkOJHmoQtTsbuu7QMbRXHa76g0m8Zs8SrZeAoBCiqVapSSmiWr6ePMz4P9LMP9MuwKFH6uRuG11UQzWACiWUUbnd)SepB0mHMZghc0lWdlldcCKorQzgEAFPzIiMUn5FcGZ0JqDQvkalQDvZG14qGDDdAMHN2xAgH80)2OBeKb5NOQMHFwINnAgYy6JjHfiLrqRSLiiTi88dpTqiKUSaPoVqaPUH0TfjNGdvhReqQcqQIncPllqAZH0tQW9FrO3QqpB8eGosyrYPhRXHa7AMAurnJqE6FB0ncYG8tuvNALcewTRAgSghcSRBqZWplXZgntZH0qZzJdb6JjHf4lGKab5zfBmH0LfiL)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLasxbPk2iKUSaPHMZghc0l)eDqmjS0mdpTV0msceyjQk0PwPanJ2vnZWt7lnZEqcRqGiFvYAgSghcSRBqNALc0S1UQzgEAFPz2dbbwG)64PzWACiWUUbDQvkGYt7QMbRXHa76g0m8Zs8SrZ48cbK6gs3wKCcouDSsaPkaPbclKUSaPXbPCzdsxrcsvesDdPXbPBlsobhQowjG0vqAZ0iK6gsJdsJds5)t0)2YlWdlld6puDSsaPRG0ancPllqQJ0E7f4HLLb9sKH0LfiL)pr)BlVapSSmOxImKgpK6gsJdsjJPpMewGugbTYwIG0IWZp80cHq6YcKY)NO)TL3QqpBeetclqkJGwzlrqAr45puDSsaPRG0ancPllqAO5SXHa9YprhetclinEinEinEiDzbsJds3wKCcouDSsaPkqcsBMgHu3qACqkzm9XKWcKYiyTkBjcslcp)WtlecPllqk)FI(3wERc9SrqmjSaPmcALTebPfHN)q1XkbKUcs3wKCcouDSsaPXdPXdPXRzgEAFPzC(c7sIe4CyRo1kfyn0UQzWACiWUUbnd)SepB0m8)j6FB5ptyveqiva2gNT)q1XkbKQaKQiKUSaPoVqaPUH0TfjNGdvhReqQcqAGWQzgEAFPze4HLLb1PwjfBu7QMz4P9LMXzIa)gKNXzl0mynoeyx3Go1kPyaTRAgSghcSRBqZWplXZgnJ4LiCSQ7jljsjceGNe50(YJ14qGDi1nK6iT3EbEyzzqF)Bli1nK2rhP9278f2LejW5WwqhDK2BF)BlnZWt7lnZMafY8B2Po1PMrKAx1kfq7QMbRXHa76g0m8Zs8SrZCJ1byiSs)07cVvq6kiL)pr)BlFRSDewfb63e9fGSuXL9DPBs7linmbPn6vEq6YcKEJ1byiSs)07cVeznZWt7lntRSDewfb63e9fGSuXL1Pwjf1UQzWACiWUUbnd)SepB0mCzZRoXGuLbPCzdsxrcsvesDdPyHxuqFAQiiFG6edsxbPRdPllqkx28Qtmivzqkx2G0vKGuwesDdPXbPyHxuqFAQiiFG6edsxbPkcPllqAZHuYhgceX7(a(0IWdqEiuH041mdpTV0myHxK1SyveajSy2PtTsRRDvZG14qGDDdAg(zjE2Oz4VQZde5zSri1nK6iT3((uCe8Bax2yHMxImK6gsJdsVX6amewPF6DH3kiDfK6iT3((uCe8Bax2yHM)q1XkbKQmivriDzbsVX6amewPF6DHxImKgVMz4P9LMrq2QYQia)McbSnoBDQvIf1UQzWACiWUUbnZWt7lnZzcRIacPcW24S1m8Zs8SrZW)NO)TLxGhwwg0FO6yLasxbPbG0LfiT5qAoeyLEbEyzzqpwJdb2Hu3qACqk)FI(3w(wCi)La8BWFD88hQowjG0vqklcPllqAZHu(hcRPsp7GNnfKgVMHhKtGGCUimfALcOtTsHv7QMbRXHa76g0m8Zs8SrZehKEJ1byiSs)07cVvq6kiL)pr)Bl)2ePa8BWw6c67s3K2xqAycsB0R8G0Lfi9gRdWqyL(P3fEjYqA8qQBinoifl8Ic6ttfb5duNyq6kifJHCPebPPIqQYG0aq6YcKYLnV6edsvgKYLnivbsqAaiDzbsDK2BVi)tfGZLYGP6GTDO)q1XkbKQaKIXqUuIG0urinCinaKgpKUSaPBlsobhQowjGufGumgYLseKMkcPHdPbG0LfiTJos7T35lSljsGZHTGo6iT3EjYAMHN2xAMTjsb43GT0fuNALAgTRAgSghcSRBqZWplXZgnJJ0E7tzeGQKX7pbGpKhUL)5f5WzdPRG0aRbK6gsXcVOG(0urq(a1jgKUcsXyixkrqAQiKQminaK6gs5)t0)2YFMWQiGqQaSnoB)HQJvciDfKIXqUuIG0uriDzbsDK2BFkJauLmE)ja8H8WT8pVihoBiDfKgGfHu3qACqk)FI(3wEbEyzzq)HQJvcivbinSqQBinhcSsVapSSmOhRXHa7q6YcKY)NO)TLVfhYFja)g8xhp)HQJvcivbinSqQBiL)HWAQ0Zo4ztbPllq62IKtWHQJvcivbinSqA8AMHN2xAg(nC2ewfbyHthbewKCwwfPtTsnBTRAgSghcSRBqZWplXZgnJJ0E7pjHSvraw40rqRvDF)Bli1nKo80cHaSqvdfq6kinGMz4P9LM5KeYwfbyHthbTw11PwjLN2vndwJdb21nOzgEAFPz2Mib)gKYiOv2seKweEAg(zjE2Oz4YgKQaKUUMHhKtGGCUimfALcOtTsRH2vndwJdb21nOz4NL4zJMHlBE1jgKQmiLlBq6ksqAanZWt7lndgJmsaKNtvNALc0O2vndwJdb21nOz4NL4zJMHlBE1jgKQmiLlBq6ksqAai1nKo80cHaSqvdfqkjinaK6gsVX6amewPF6DH3kiDfKQyJq6YcKYLnV6edsvgKYLniDfjivri1nKo80cHaSqvdfq6ksqQIAMHN2xAgUSbCKorQtTsbcODvZm80(sZWLnq7ec1mynoeyx3Go1kfqrTRAgSghcSRBqZm80(sZKweEaYdHQMHFwINnAg(R68arEgBesDdPCzZRoXGuLbPCzdsxrcsvesDdPos7TxK)PcW5szWuDW2o03)2sZWdYjqqoxeMcTsb0PwPaRRDvZG14qGDDdAg(zjE2OzCK2Bpx2ayHxuqVihoBiDfKUEJqQYG0WcPHjiD4PfcbyHQgkGu3qQJ0E7f5FQaCUugmvhSTd99VTGu3qACqk)FI(3w(ZewfbesfGTXz7puDSsaPRGufHu3qk)FI(3w(Tjsb43GT0f0FO6yLasxbPkcPllqk)FI(3w(ZewfbesfGTXz7puDSsaPkaPRdPUHu()e9VT8BtKcWVbBPlO)q1XkbKUcsxhsDdPCzdsxbPRdPllqk)FI(3w(ZewfbesfGTXz7puDSsaPRG01Hu3qk)FI(3w(Tjsb43GT0f0FO6yLasvasxhsDdPCzdsxbPSiKUSaPCzZRoXGuLbPCzdsvGeKgasDdPyHxuqFAQiiFG6edsvasvesJhsxwGuhP92ZLnaw4ff0lYHZgsxbPbAesDdPBlsobhQowjGufG0MTMz4P9LMrq2QYQia)McbSnoBDQvkalQDvZG14qGDDdAMHN2xAghIHZ(LsaBJZwZWplXZgnd)vDEGipJncPUH04G0CiWk9c8WYYGESghcSdPUHu()e9VT8c8WYYG(dvhReqQcq66q6YcKY)NO)TL)mHvraHubyBC2(dvhReq6kinaK6gs5)t0)2YVnrka)gSLUG(dvhReq6kinaKUSaP8)j6FB5ptyveqiva2gNT)q1XkbKQaKUoK6gs5)t0)2YVnrka)gSLUG(dvhReq6kiDDi1nKYLniDfKQiKUSaP8)j6FB5ptyveqiva2gNT)q1XkbKUcsxhsDdP8)j6FB53MifGFd2sxq)HQJvcivbiDDi1nKYLniDfKUoKUSaPCzdsxbPHfsxwGuhP9278SbKVN7LidPXRz4b5eiiNlctHwPa6uRuGWQDvZG14qGDDdAMHN2xAM0IWdqEiu1m8Zs8SrZWFvNhiYZyJqQBiLlBE1jgKQmiLlBq6ksqQIAgEqobcY5IWuOvkGo1kfOz0UQzWACiWUUbnd)SepB0mCzZRoXGuLbPCzdsxrcsdOzgEAFPzMJpfcY)oSsDQvkqZw7QMXQeVtICQzcOzgEAFPz2ebTkciWJmwjGTXzRzWACiWUUbDQvkGYt7QMbRXHa76g0mdpTV0moedN9lLa2gNTMHFwINnAg(R68arEgBesDdP8)j6FB53MifGFd2sxq)HQJvcivbiDDi1nKYLniLeKQiK6gsjFyiqeV7d4tlcpa5HqfsDdPyHxuqFAQiiFqyBesvasdOz4b5eiiNlctHwPa6uRuG1q7QMbRXHa76g0mdpTV0moedN9lLa2gNTMHFwINnAg(R68arEgBesDdPyHxuqFAQiiFG6edsvasvesDdPXbPCzZRoXGuLbPCzdsvGeKgasxwGuYhgceX7(a(0IWdqEiuH041m8GCceKZfHPqRuaDQtndVde4w7QwPaAx1mynoeyx3GMHFwINnAMMdPHMZghc0l)eDqmjSGu3qACqk)FI(3w(ZewfbesfGTXz7puDSsaPkaPkcPllqAZHu(hcRPsp7GNnfKgpK6gsJdsBoKY)qynv6lKFpXFDiDzbs5)t0)2Y78f2LejW5Ww)HQJvcivbivrinEiDzbs3wKCcouDSsaPkaPkgwnZWt7lnJvHE2iiMew6uRKIAx1mynoeyx3GMHFwINnAMTfjNGdvhReq6kinoinGYRrivzq6jv4(Vi0VNCia5lXL9ynoeyhsdtqAafBesJhsxwGuhP92lY)ub4CPmyQoyBh67FBbPUHuYy6JjHfiLrqRSLiiTi88dpTqiK6gsJdsBoKY)qynv6lKFpXFDiDzbsDK2BVZxyxsKaNdB9sKH04H0LfinoiL)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLasxbPBlsobhQowjG04Hu3qQJ0E7D(c7sIe4CyRxImKUSaPoVqaPUH0TfjNGdvhReqQcqAGg1mdpTV0m5lXLb)g0XjL1PwP11UQzWACiWUUbnd)SepB0mXbP3yDagcR0p9UWBfKUcszXWcPllq6nwhGHWk9tVl8sKH04Hu3qk)FI(3w(ZewfbesfGTXz7puDSsaPkaPymKlLiinvesDdP8)j6FB5Tk0ZgbXKWcKYiOv2seKweE(dvhReq6kinoivXgH0WHufBesdtq6jv4(Vi0BvONnEcqhjSi50J14qGDinEiDzbsDEHasDdPBlsobhQowjGufG01dRMz4P9LMPfhYFja)g8xhpDQvIf1UQzWACiWUUbnd)SepB0m8x15bI8m2iK6gsJdsVX6amewPF6DH3kiDfKgOriDzbsVX6amewPF6DHxImKgVMz4P9LMzpiHviqKVkzDQvkSAx1mynoeyx3GMHFwINnAMBSoadHv6NEx4TcsxbPR3iKUSaP3yDagcR0p9UWlrwZm80(sZShccSa)1XtNALAgTRAgSghcSRBqZWplXZgndx2G0vKGufHu3q62IKtWHQJvciDfK2mncPUH04Gu()e9VT8I8pvaoxkdMQd22HEU8CrOasxbPncPllqk)FI(3wEr(NkaNlLbt1bB7q)HQJvciDfKgOrinEi1nKghKsgtFmjSaPmcALTebPfHNF4PfcH0LfiL)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLasxbPbAesxwG0qZzJdb6LFIoiMewqA8q6YcKghKYLniDfjivri1nKUTi5eCO6yLasvGeK2mncPUH04GuYy6JjHfiLrWAv2seKweE(HNwiesxwGu()e9VT8wf6zJGysybsze0kBjcslcp)HQJvciDfKUTi5eCO6yLasJhsDdPXbP8)j6FB5f5FQaCUugmvhSTd9C55IqbKUcsBesxwGu()e9VT8I8pvaoxkdMQd22H(dvhReq6kiDBrYj4q1XkbKUSaPos7TxK)PcW5szWuDW2o0lrgsJhsJhsxwG0TfjNGdvhReqQcqAGWQzgEAFPzC(c7sIe4CyRo1k1S1UQzWACiWUUbnd)SepB0m8V6sw65)FDRMe7GFVXsyHqpwJdb21mdpTV0mI8pvaoxkdMQd22HGTfBsuNALuEAx1mynoeyx3GMHFwINnAg()e9VT8I8pvaoxkdMQd22HEU8CrOasjbPkcPllq62IKtWHQJvcivbivXgH0Lfinoi9gRdWqyL(P3f(dvhReq6kinqyH0LfinoiT5qk)dH1uPNDWZMcsDdPnhs5FiSMk9fYVN4VoKgpK6gsJdsJdsVX6amewPF6DH3kiDfKY)NO)TLxK)PcW5szWuDW2o0VLiiahYLNlcbPPIq6YcK2Ci9gRdWqyL(P3fEmMjsbKgpK6gsJds5)t0)2YBvONncIjHfiLrqRSLiiTi88hQowjG0vqk)FI(3wEr(NkaNlLbt1bB7q)wIGaCixEUieKMkcPllqAO5SXHa9YprhetclinEinEi1nKY)NO)TLFBIua(nylDb9hQowjGufibPRbK6gs5YgKUIeKQiK6gs5)t0)2Y3kBhHvrG(nrFbilvCz)HQJvcivbsqAafH041mdpTV0mI8pvaoxkdMQd22H6uR0AODvZG14qGDDdAg(zjE2Oz4FiSMk9SdE2uqQBinoi1rAV9T4q(lb43G)645LidPllqACq62IKtWHQJvcivbiL)pr)BlFloK)sa(n4VoE(dvhReq6YcKY)NO)TLVfhYFja)g8xhp)HQJvciDfKY)NO)TLxK)PcW5szWuDW2o0VLiiahYLNlcbPPIqA8qQBiL)pr)Bl)2ePa8BWw6c6puDSsaPkqcsxdi1nKYLniDfjivri1nKY)NO)TLVv2ocRIa9BI(cqwQ4Y(dvhReqQcKG0akcPXRzgEAFPze5FQaCUugmvhSTd1PwPanQDvZG14qGDDdAg(zjE2Oz4FiSMk9fYVN4VoK6gs7OJ0E7D(c7sIe4CylOJos7TxImK6gsJdsjJPpMewGugbTYwIG0IWZp80cHq6YcKgAoBCiqV8t0bXKWcsxwGu()e9VT8wf6zJGysybsze0kBjcslcp)HQJvciDfKY)NO)TLxK)PcW5szWuDW2o0VLiiahYLNlcbPPIq6YcKY)NO)TL3QqpBeetclqkJGwzlrqAr45puDSsaPRG01BesJxZm80(sZiY)ub4CPmyQoyBhQtTsbcODvZG14qGDDdAg(zjE2OziJPpMewGugbTYwIG0IWZp80cHq6YcK68cbK6gs3wKCcouDSsaPkaPk2OMz4P9LMXkb)KYXHabkhPPsjvqhdzCuNALcOO2vndwJdb21nOz4NL4zJMHmM(ysybsze0kBjcslcp)WtlecPllqQZleqQBiDBrYj4q1XkbKQaKQyJAMHN2xAM2Bszr(fQtTsbwx7QMbRXHa76g0m8Zs8SrZqgtFmjSaPmcALTebPfHNF4PfcH0Lfi15fci1nKUTi5eCO6yLasvasvSrnZWt7lnteX0Tj)taCMEeQtTsbyrTRAgSghcSRBqZm80(sZ0pC6B7qqiuiqcnd)SepB0mnhsdnNnoeOpMewGVasceKNvSXesxwGu()e9VT8wf6zJGysybsze0kBjcslcp)HQJvciDfKQyJqQBiLmM(ysybsze0kBjcslcp)HQJvcivbivXgH0Lfin0C24qGE5NOdIjHLMPgvuZ0pC6B7qqiuiqcDQvkqy1UQzWACiWUUbnZWt7lnJqE6FB0ncYG8tuvZWplXZgndzm9XKWcKYiOv2seKweE(HNwiesxwGuNxiGu3q62IKtWHQJvcivbivXgH0LfiT5q6jv4(Vi0BvONnEcqhjSi50J14qGDntnQOMrip9Vn6gbzq(jQQtTsbAgTRAgSghcSRBqZWplXZgntZH0qZzJdb6JjHf4lGKab5zfBmH0LfiL)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLasxbPk2iKUSaPHMZghc0l)eDqmjS0mdpTV0msceyjQk0PwPanBTRAgSghcSRBqZWplXZgnZ2IKtWHQJvciDfKUgncPllqkzm9XKWcKYiOv2seKweE(HNwiesxwG0qZzJdb6LFIoiMewq6YcK68cbK6gs3wKCcouDSsaPkaPbAgnZWt7lnt(sCzWVbSNtD0PwPakpTRAgSghcSRBqZWplXZgnd)FI(3wERc9SrqmjSaPmcALTebPfHN)q1XkbKUcsxVriDzbsdnNnoeOx(j6GysybPllqQZleqQBiDBrYj4q1XkbKQaKQyJAMHN2xAghI)7GT0fuNALcSgAx1mynoeyx3GMHFwINnAg()e9VT8wf6zJGysybsze0kBjcslcp)HQJvciDfKUEJq6YcKgAoBCiqV8t0bXKWcsxwGuNxiGu3q62IKtWHQJvcivbinqy1mdpTV0mo4jWJTvr6uRKInQDvZm80(sZqyrYPaWcL6rQyLAgSghcSRBqNALumG2vndwJdb21nOz4NL4zJMH)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLasxbPR3iKUSaPHMZghc0l)eDqmjSG0Lfi15fci1nKUTi5eCO6yLasvasd0OMz4P9LMzBh6q8FxNALuurTRAgSghcSRBqZWplXZgnd)FI(3wERc9SrqmjSaPmcALTebPfHN)q1XkbKUcsxVriDzbsdnNnoeOx(j6GysybPllqQZleqQBiDBrYj4q1XkbKQaKQyJAMHN2xAMP4OiVHaWhccDQvsX11UQzWACiWUUbnd)SepB0mos7TxK)PcW5szWuDW2o03)2sZm80(sZ4mrGFdYZ4Sf6uRKISO2vndwJdb21nOz4NL4zJMr8seow19KLePebcWtICAF5XACiWoK6gsDK2BVi)tfGZLYGP6GTDOV)TfK6gs7OJ0E7D(c7sIe4CylOJos7TV)TLMz4P9LMztGcz(n7uN6uZ0X9irKAx1kfq7QMz4P9LMrqgNdipvhiYZyJAgSghcSRBqNALuu7QMbRXHa76g0mpznJatnZWt7lntO5SXHa1mHgcjuZW)NO)TL3QqpBeetclqkJGwzlrqAr45puDSsaPRG0TfjNGdvhReq6YcKUTi5eCO6yLasvgKY)NO)TL3QqpBeetclqkJGwzlrqAr45puDSsaPkaPbuSri1nKghKghKMdbwPxGhwwg0J14qGDi1nKUTi5eCO6yLasxbP8)j6FB5f4HLLb9hQowjGu3qk)FI(3wEbEyzzq)HQJvciDfKgOrinEiDzbsJds5)t0)2YlY)ub4CPmyQoyBh63seeGd5YZfHG0urivbiDBrYj4q1XkbK6gs5)t0)2YlY)ub4CPmyQoyBh63seeGd5YZfHG0uriDfKgiSqA8q6YcKghKY)NO)TLxK)PcW5szWuDW2o0ZLNlcfqkjiTri1nKY)NO)TLxK)PcW5szWuDW2o0FO6yLasvas3wKCcouDSsaPXdPXRzcnhOgvuZi)eDqmjS0PwP11UQzWACiWUUbnd)SepB0mXbPos7TxGhwwg0lrgsxwGuhP92lY)ub4CPmyQoyBh6LidPXdPUHuYy6JjHfiLrqRSLiiTi88dpTqiKUSaPoVqaPUH0TfjNGdvhReqQcKG0MPrnZWt7lnd5pTV0Pwjwu7QMbRXHa76g0m8Zs8SrZ4iT3EbEyzzqVeznZWt7lndFiiadpTVaeMi1meMib1OIAgbEyzzqDQvkSAx1mynoeyx3GMHFwINnAghP923Id5VeGFd(RJNxISMz4P9LMHpeeGHN2xactKAgctKGAurntloK)sa(n4VoE6uRuZODvZG14qGDDdAg(zjE2OzstfHufGuwesDdPCzdsvasdlK6gsBoKsgtFmjSaPmcALTebPfHNF4Pfc1mdpTV0m8HGam80(cqyIuZqyIeuJkQzEYyHNo1k1S1UQzWACiWUUbnZWt7lnZ2ej43GugbTYwIG0IWtZWplXZgndx28Qtmivzqkx2G0vKG01Hu3qACqkw4ff0NMkcYhOoXGufG0aq6YcKIfErb9PPIG8bQtmivbiLfHu3qk)FI(3w(Tjsb43GT0f0FO6yLasvasd4dlKUSaP8)j6FB5BXH8xcWVb)1XZFO6yLasvasvesJhsDdPnhs7OJ0E7D(c7sIe4CylOJos7TxISMHhKtGGCUimfALcOtTskpTRAgSghcSRBqZWplXZgndx28Qtmivzqkx2G0vKG0aqQBinoifl8Ic6ttfb5duNyqQcqAaiDzbs5)t0)2YlWdlld6puDSsaPkaPkcPllqkw4ff0NMkcYhOoXGufGuwesDdP8)j6FB53MifGFd2sxq)HQJvcivbinGpSq6YcKY)NO)TLVfhYFja)g8xhp)HQJvcivbivrinEi1nK2Ci1rAV9oFHDjrcCoS1lrwZm80(sZGXiJea55u1PwP1q7QMbRXHa76g0mdpTV0mPfHhG8qOQz4NL4zJMH)QopqKNXgHu3qkx28Qtmivzqkx2G0vKGufHu3qACqkw4ff0NMkcYhOoXGufG0aq6YcKY)NO)TLxGhwwg0FO6yLasvasvesxwGuSWlkOpnveKpqDIbPkaPSiK6gs5)t0)2YVnrka)gSLUG(dvhReqQcqAaFyH0LfiL)pr)BlFloK)sa(n4VoE(dvhReqQcqQIqA8qQBiT5qAhDK2BVZxyxsKaNdBbD0rAV9sK1m8GCceKZfHPqRuaDQvkqJAx1mynoeyx3GMHFwINnAMMdP5qGv6f4HLLb9ynoeyxZm80(sZWhccWWt7laHjsndHjsqnQOMH3bcCRtTsbcODvZG14qGDDdAg(zjE2OzYHaR0lWdlld6XACiWUMz4P9LMHpeeGHN2xactKAgctKGAurndVde4HLLb1PwPakQDvZG14qGDDdAg(zjE2OzgEAHqawOQHcivbiDDnZWt7lndFiiadpTVaeMi1meMib1OIAgrQtTsbwx7QMbRXHa76g0m8Zs8SrZm80cHaSqvdfq6ksq66AMHN2xAg(qqagEAFbimrQzimrcQrf1mZJ6uNAgYhYFvNj1UQvkG2vnZWt7lnJZNjb2bBIji2BTkcKFmR0mynoeyx3Go1kPO2vndwJdb21nOzEYAgbMAMHN2xAMqZzJdbQzcnesOMbvosgzYy3BLGFs54qGaLJ0uPKkOJHmocPllqkQCKmYKXUpIy62K)jaotpcH0LfifvosgzYy33EtklYVqiDzbsrLJKrMm29Fi84YZfHDWuM6aCMmXliKUSaPOYrYitg7EH80)2OBeKb5NOQMj0CGAurntmjSaFbKeiipRyJPo1kTU2vnZWt7lnZMafY8B2PMbRXHa76g0Pwjwu7QMbRXHa76g0m8Zs8SrZ0CinhcSsVapSSmOhRXHa7q6YcK2CinhcSs)2ej43GugbTYwIG0IWZJ14qGDnZWt7lndx2aosNi1PwPWQDvZG14qGDDdAg(zjE2OzAoKMdbwPhl8ISMfRIaiHfdppwJdb21mdpTV0mCzd0oHqDQtnZ8O2vTsb0UQzgEAFPzALTJWQiq)MOVaKLkUSMbRXHa76g0Pwjf1UQzWACiWUUbnd)SepB0mCzZRoXGuLbPCzdsxrcsvesDdPyHxuqFAQiiFG6edsxbPkcPllqkx28Qtmivzqkx2G0vKGuwuZm80(sZGfErwZIvraKWIzNo1kTU2vndwJdb21nOz4NL4zJMH)QopqKNXgHu3qACqQJ0E77tXrWVbCzJfAEjYq6YcK2rhP9278f2LejW5WwqhDK2BVezinEnZWt7lnJGSvLvra(nfcyBC26uRelQDvZG14qGDDdAg(zjE2OzWcVOG(0urq(a1jgKUcsXyixkrqAQiKUSaPCzZRoXGuLbPCzdsvGeKgqZm80(sZSnrka)gSLUG6uRuy1UQzWACiWUUbnZWt7lnZzcRIacPcW24S1m8Zs8SrZehKMdbwPVv2ocRIa9BI(cqwQ4YESghcSdPUHu()e9VT8NjSkciKkaBJZ23LUjTVG0vqk)FI(3w(wz7iSkc0Vj6lazPIl7puDSsaPHdPSiKgpK6gsJds5)t0)2YVnrka)gSLUG(dvhReq6kiDDiDzbs5YgKUIeKgwinEndpiNab5Cryk0kfqNALAgTRAgSghcSRBqZWplXZgnJJ0E7pjHSvraw40rqRvDF)BlnZWt7lnZjjKTkcWcNocATQRtTsnBTRAgSghcSRBqZWplXZgndx28Qtmivzqkx2G0vKG0aAMHN2xAgmgzKaipNQo1kP80UQzWACiWUUbnZWt7lnZ2ej43GugbTYwIG0IWtZWplXZgndx28Qtmivzqkx2G0vKG011m8GCceKZfHPqRuaDQvAn0UQzWACiWUUbnd)SepB0mCzZRoXGuLbPCzdsxrcsvuZm80(sZWLnGJ0jsDQvkqJAx1mynoeyx3GMHFwINnAghP92NYiavjJ3FcaFipCl)ZlYHZgsxbPbwdi1nKIfErb9PPIG8bQtmiDfKIXqUuIG0urivzqAai1nKY)NO)TLFBIua(nylDb9hQowjG0vqkgd5sjcstf1mdpTV0m8B4SjSkcWcNociSi5SSksNALceq7QMbRXHa76g0mdpTV0mPfHhG8qOQz4NL4zJMHlBE1jgKQmiLlBq6ksqQIqQBinoiT5qAoeyLEzlb8x159ynoeyhsxwGu(R68arEgBesJxZWdYjqqoxeMcTsb0PwPakQDvZG14qGDDdAg(zjE2Oz4YMxDIbPkds5YgKUIeKgqZm80(sZmhFkeK)DyL6uRuG11UQzWACiWUUbnd)SepB0m8x15bI8m2iK6gsJds5)t0)2Y78f2LejW5Ww)HQJvciDfKQiKUSaPnhs5FiSMk9fYVN4VoKgpK6gsJds5YgKUIeKgwiDzbs5)t0)2YVnrka)gSLUG(dvhReq6kiTzG0LfiL)pr)Bl)2ePa8BWw6c6puDSsaPRG01Hu3qkx2G0vKG01Hu3qkw4ff0NMkcYhe2gHufG0aq6YcKIfErb9PPIG8bQtmivbsqACq66qA4q66qAycs5)t0)2YVnrka)gSLUG(dvhReqQcqAyH04H0Lfi1rAV9I8pvaoxkdMQd22HEjYqA8AMHN2xAgbzRkRIa8BkeW24S1PwPaSO2vndwJdb21nOz4NL4zJMH)QopqKNXg1mdpTV0mCzd0oHqDQvkqy1UQzWACiWUUbnZWt7lnZMiOvrabEKXkbSnoBnd)SepB0mos7T35zdiFp33)2sZyvI3jro1mb0PwPanJ2vndwJdb21nOzgEAFPzCigo7xkbSnoBnd)SepB0m8x15bI8m2iK6gsJdsDK2BVZZgq(EUxImKUSaP5qGv6LTeWFvN3J14qGDi1nKs(WqGiE3hWNweEaYdHkK6gs5YgKscsvesDdP8)j6FB53MifGFd2sxq)HQJvcivbiDDiDzbs5YMxDIbPkds5YgKQajinaK6gsjFyiqeV7d4fKTQSkcWVPqaBJZgsDdPyHxuqFAQiiFG6edsvasxhsJxZWdYjqqoxeMcTsb0Po1PMjeEc7lTsk2OIbAu5P46AM25kRIeAM1QYvZQskFkTwSMqkK6QmcPMk5)siD)hKYYwCi)La8BWFD8yjKEOYrYoSdPIxfH0rkF1jXoKYLNkcfEiRSaRqivX1esx7VcHxIDiLL5qGv6ddwcP5dPSmhcSsFy4XACiWolH0jHuL)1swaKgxGyX7HSYcScH01xtiDT)keEj2HuwMdbwPpmyjKMpKYYCiWk9HHhRXHa7SesNesv(xlzbqACbIfVhYklWkesvSX1esx7VcHxIDiLL5qGv6ddwcP5dPSmhcSsFy4XACiWolH04celEpKviRRvLRMvLu(uATynHui1vzesnvY)Lq6(piLLc8WYYGSespu5izh2HuXRIq6iLV6Kyhs5YtfHcpKvwGviKgOX1esx7VcHxIDiLL5qGv6ddwcP5dPSmhcSsFy4XACiWolH0jHuL)1swaKgxGyX7HSczDTQC1SQKYNsRfRjKcPUkJqQPs(Ves3)bPSK3bc8WYYGSespu5izh2HuXRIq6iLV6Kyhs5YtfHcpKvwGviKUgRjKU2FfcVe7qklpPc3)fH(WGLqA(qklpPc3)fH(WWJ14qGDwcPXfiw8EiRSaRqinalUMq6A)vi8sSdPS8KkC)xe6ddwcP5dPS8KkC)xe6ddpwJdb2zjKojKQ8VwYcG04celEpKvwGviKQyG1esx7VcHxIDiLLIxIWXQUpmyjKMpKYsXlr4yv3hgESghcSZsinUaXI3dzfY6Av5QzvjLpLwlwtifsDvgHutL8FjKU)dszPizjKEOYrYoSdPIxfH0rkF1jXoKYLNkcfEiRSaRqiLfxtiDT)keEj2HuwMdbwPpmyjKMpKYYCiWk9HHhRXHa7SesJlqS49qwzbwHqAZSMq6A)vi8sSdPSmhcSsFyWsinFiLL5qGv6ddpwJdb2zjKgxGyX7HSYcScH0aS4AcPR9xHWlXoKYYCiWk9HblH08HuwMdbwPpm8ynoeyNLqACbIfVhYkK11QYvZQskFkTwSMqkK6QmcPMk5)siD)hKYsEhiWnlH0dvos2HDiv8QiKos5Roj2HuU8urOWdzLfyfcPkUMq6A)vi8sSdPS8KkC)xe6ddwcP5dPS8KkC)xe6ddpwJdb2zjKgxGyX7HSYcScH01xtiDT)keEj2HuwEsfU)lc9HblH08HuwEsfU)lc9HHhRXHa7SesJlqS49qwzbwHqAGWUMq6A)vi8sSdPS8KkC)xe6ddwcP5dPS8KkC)xe6ddpwJdb2zjKojKQ8VwYcG04celEpKvwGviKQilUMq6A)vi8sSdPSu8seow19HblH08HuwkEjchR6(WWJ14qGDwcPXfiw8EiRqwxRkxnRkP8P0AXAcPqQRYiKAQK)lH09Fqkl74EKiswcPhQCKSd7qQ4vriDKYxDsSdPC5PIqHhYklWkesvCnH01(Rq4LyhszzoeyL(WGLqA(qklZHaR0hgESghcSZsinUaXI3dzLfyfcPbACnH01(Rq4LyhszzoeyL(WGLqA(qklZHaR0hgESghcSZsiDsiv5FTKfaPXfiw8EiRSaRqinqG1esx7VcHxIDiLL5qGv6ddwcP5dPSmhcSsFy4XACiWolH0jHuL)1swaKgxGyX7HSczDTQC1SQKYNsRfRjKcPUkJqQPs(Ves3)bPSCEKLq6Hkhj7WoKkEveshP8vNe7qkxEQiu4HSYcScH0WUMq6A)vi8sSdPSmhcSsFyWsinFiLL5qGv6ddpwJdb2zjKgxGyX7HSYcScH0abwtiDT)keEj2HuwMdbwPpmyjKMpKYYCiWk9HHhRXHa7SesJlqS49qwzbwHqAGMznH01(Rq4LyhszzoeyL(WGLqA(qklZHaR0hgESghcSZsinUaXI3dzfYQYNk5)sSdPRbKo80(csjmrk8qw1mKVFBeOMjmhMH01Qv92HGnEqQY9FXgYAyomdPkxsrsIesvCnCbsvSrfdazfYAyomdPRT8CrOynHSgMdZqQYGuxBXHnKQCJjsbK(Biv5gPliKAvI3jroHuIpY4EiRH5WmKQmi11wCydPmKTQSkcsx7BkesvU14SHuIpY4EiRH5WmKQmiv5Q3HuNxi2wKCcPCzKZwaP5dPQtfesxBL7GuSYZqHhYkK1WCygsv(JHCPe7qQdU)dHu(R6mjK6Grwj8qQYfNJKtbKwFPm55u3seq6Wt7lbK(frqpK1HN2xcp5d5VQZKHtQjNptcSd2etqS3Avei)ywbzD4P9LWt(q(R6mz4KAk0C24qGUuJkskMewGVasceKNvSX0LNmjbMUeAiKqsOYrYitg7ERe8tkhhceOCKMkLubDmKXXLfu5izKjJDFeX0Tj)taCMEeUSGkhjJmzS7BVjLf5x4YcQCKmYKXU)dHhxEUiSdMYuhGZKjEbxwqLJKrMm29c5P)Tr3iidYprviRdpTVeEYhYFvNjdNutBcuiZVzNqwhEAFj8KpK)QotgoPM4YgWr6ePl2MuZZHaR0lWdlld6XACiW(YsZZHaR0Vnrc(niLrqRSLiiTi88ynoeyhY6Wt7lHN8H8x1zYWj1ex2aTti0fBtQ55qGv6XcViRzXQiasyXWZJ14qGDiRqwdZHziv5pgYLsSdPyi8ccPPPIqAkJq6WZ)GutaPtOXighc0dzD4P9LGKGmohqEQoqKNXgHSo80(seoPMcnNnoeOl1OIKKFIoiMewU8KjjW0LqdHesI)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLy12IKtWHQJvILLTfjNGdvhRekJ)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLqHak2O74IlhcSsVapSSmO7TfjNGdvhReR4)t0)2YlWdlld6puDSs4M)pr)BlVapSSmO)q1XkXQang)YsC8)j6FB5f5FQaCUugmvhSTd9BjccWHC55IqqAQOcBlsobhQowjCZ)NO)TLxK)PcW5szWuDW2o0VLiiahYLNlcbPPIRce24xwIJ)pr)BlVi)tfGZLYGP6GTDONlpxeki1OB()e9VT8I8pvaoxkdMQd22H(dvhRekSTi5eCO6yLi(4HSo80(seoPMi)P9Ll2MuCos7TxGhwwg0lrEzXrAV9I8pvaoxkdMQd22HEjYX7MmM(ysybsze0kBjcslcp)WtleUS48cH7TfjNGdvhRekqQzAeY6Wt7lr4KAIpeeGHN2xactKUuJkssGhwwg0fBtYrAV9c8WYYGEjYqwhEAFjcNut8HGam80(cqyI0LAursT4q(lb43G)645ITj5iT3(wCi)La8BWFD88sKHSo80(seoPM4dbby4P9fGWePl1OIKEYyHNl2MuAQOcSOBUSPqyD3CYy6JjHfiLrqRSLiiTi88dpTqiK1HN2xIWj102ej43GugbTYwIG0IWZfEqobcY5IWuqkGl2Mex28QtmLXLTvKw3DCyHxuqFAQiiFG6etHallyHxuqFAQiiFG6etbw0n)FI(3w(Tjsb43GT0f0FO6yLqHa(WUSW)NO)TLVfhYFja)g8xhp)HQJvcfumE3nVJos7T35lSljsGZHTGo6iT3EjYqwhEAFjcNutymYibqEovxSnjUS5vNykJlBRifWDCyHxuqFAQiiFG6etHall8)j6FB5f4HLLb9hQowjuqXLfSWlkOpnveKpqDIPal6M)pr)Bl)2ePa8BWw6c6puDSsOqaFyxw4)t0)2Y3Id5VeGFd(RJN)q1XkHckgV7M7iT3ENVWUKiboh26LidzD4P9LiCsnLweEaYdHQl8GCceKZfHPGuaxSnj(R68arEgB0nx28QtmLXLTvKu0DCyHxuqFAQiiFG6etHall8)j6FB5f4HLLb9hQowjuqXLfSWlkOpnveKpqDIPal6M)pr)Bl)2ePa8BWw6c6puDSsOqaFyxw4)t0)2Y3Id5VeGFd(RJN)q1XkHckgV7M3rhP9278f2LejW5WwqhDK2BVeziRdpTVeHtQj(qqagEAFbimr6snQijEhiWTl2MuZZHaR0lWdlldczD4P9LiCsnXhccWWt7laHjsxQrfjX7abEyzzqxSnPCiWk9c8WYYGqwhEAFjcNut8HGam80(cqyI0LAursI0fBtA4PfcbyHQgkuyDiRdpTVeHtQj(qqagEAFbimr6snQiP5rxSnPHNwieGfQAOyfP1HSczD4P9LWppsQv2ocRIa9BI(cqwQ4YqwhEAFj8ZJHtQjSWlYAwSkcGewm7CX2K4YMxDIPmUSTIKIUXcVOG(0urq(a1j2kfxw4YMxDIPmUSTIelczD4P9LWppgoPMeKTQSkcWVPqaBJZ2fBtI)QopqKNXgDhNJ0E77tXrWVbCzJfAEjYllD0rAV9oFHDjrcCoSf0rhP92lroEiRdpTVe(5XWj102ePa8BWw6c6ITjHfErb9PPIG8bQtSvymKlLiinvCzHlBE1jMY4YMcKcazD4P9LWppgoPMotyveqiva2gNTl8GCceKZfHPGuaxSnP4YHaR03kBhHvrG(nrFbilvCz38)j6FB5ptyveqiva2gNTVlDtAFTI)pr)BlFRSDewfb63e9fGSuXL9hQowjcNfJ3DC8)j6FB53MifGFd2sxq)HQJvIvRVSWLTvKcB8qwhEAFj8ZJHtQPtsiBveGfoDe0Av3fBtYrAV9NKq2QialC6iO1QUV)TfK1HN2xc)8y4KAcJrgjaYZP6ITjXLnV6etzCzBfPaqwhEAFj8ZJHtQPTjsWVbPmcALTebPfHNl8GCceKZfHPGuaxSnjUS5vNykJlBRiToK1HN2xc)8y4KAIlBahPtKUyBsCzZRoXugx2wrsriRdpTVe(5XWj1e)goBcRIaSWPJaclsolRICX2KCK2BFkJauLmE)ja8H8WT8pViho7vbwd3yHxuqFAQiiFG6eBfgd5sjcstfvwa38)j6FB53MifGFd2sxq)HQJvIvymKlLiinveY6Wt7lHFEmCsnLweEaYdHQl8GCceKZfHPGuaxSnjUS5vNykJlBRiPO74AEoeyLEzlb8x15xw4VQZde5zSX4HSo80(s4NhdNutZXNcb5FhwPl2Mex28QtmLXLTvKcazD4P9LWppgoPMeKTQSkcWVPqaBJZ2fBtI)QopqKNXgDhh)FI(3wENVWUKiboh26puDSsSsXLLMZ)qynv6lKFpXF94Dhhx2wrkSll8)j6FB53MifGFd2sxq)HQJvIvnZYc)FI(3w(Tjsb43GT0f0FO6yLy16U5Y2ksR7gl8Ic6ttfb5dcBJkeyzbl8Ic6ttfb5duNykqkU1dF9We)FI(3w(Tjsb43GT0f0FO6yLqHWg)YIJ0E7f5FQaCUugmvhSTd9sKJhY6Wt7lHFEmCsnXLnq7ecDX2K4VQZde5zSriRdpTVe(5XWj10MiOvrabEKXkbSnoBxSnjhP9278SbKVN77FB5IvjENe5KuaiRdpTVe(5XWj1KdXWz)sjGTXz7cpiNab5CrykifWfBtI)QopqKNXgDhNJ0E7DE2aY3Z9sKxwYHaR0lBjG)QoVBYhgceX7(a(0IWdqEiuDZLnsk6M)pr)Bl)2ePa8BWw6c6puDSsOW6llCzZRoXugx2uGua3KpmeiI39b8cYwvwfb43uiGTXz7gl8Ic6ttfb5duNykSE8qwHSo80(s45DGa3KSk0ZgbXKWcKYiOv2seKweEUyBsnp0C24qGE5NOdIjHL744)t0)2YFMWQiGqQaSnoB)HQJvcfuCzP58pewtLE2bpBQ4DhxZ5FiSMk9fYVN4V(Yc)FI(3wENVWUKiboh26puDSsOGIXVSSTi5eCO6yLqbfdlK1HN2xcpVde4oCsnLVexg8BqhNu2fBtABrYj4q1XkXQ4cO8AuzNuH7)Iq)EYHaKVexomfqXgJFzXrAV9I8pvaoxkdMQd22H((3wUjJPpMewGugbTYwIG0IWZp80cHUJR58pewtL(c53t8xFzXrAV9oFHDjrcCoS1lro(LL44)t0)2YBvONncIjHfiLrqRSLiiTi88hQowjwTTi5eCO6yLiE3os7T35lSljsGZHTEjYlloVq4EBrYj4q1XkHcbAeY6Wt7lHN3bcChoPMAXH8xcWVb)1XZfBtkUBSoadHv6NEx4TAflg2LLBSoadHv6NEx4LihVB()e9VT8NjSkciKkaBJZ2FO6yLqbmgYLseKMk6M)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLyvCk2y4k2yy6KkC)xe6Tk0ZgpbOJewKCg)YIZleU3wKCcouDSsOW6HfY6Wt7lHN3bcChoPM2dsyfce5Rs2fBtI)QopqKNXgDh3nwhGHWk9tVl8wTkqJll3yDagcR0p9UWlroEiRdpTVeEEhiWD4KAApeeyb(RJNl2M0nwhGHWk9tVl8wTA9gxwUX6amewPF6DHxImK1HN2xcpVde4oCsn58f2LejW5WwxSnjUSTIKIU3wKCcouDSsSQzA0DC8)j6FB5f5FQaCUugmvhSTd9C55IqXQgxw4)t0)2YlY)ub4CPmyQoyBh6puDSsSkqJX7ooYy6JjHfiLrqRSLiiTi88dpTq4Yc)FI(3wERc9SrqmjSaPmcALTebPfHN)q1XkXQanUSeAoBCiqV8t0bXKWk(LL44Y2ksk6EBrYj4q1XkHcKAMgDhhzm9XKWcKYiyTkBjcslcp)WtleUSW)NO)TL3QqpBeetclqkJGwzlrqAr45puDSsSABrYj4q1Xkr8UJJ)pr)BlVi)tfGZLYGP6GTDONlpxekw14Yc)FI(3wEr(NkaNlLbt1bB7q)HQJvIvBlsobhQowjwwCK2BVi)tfGZLYGP6GTDOxIC8XVSSTi5eCO6yLqHaHfY6Wt7lHN3bcChoPMe5FQaCUugmvhSTdbBl2KOl2Me)RUKLE()x3QjXo43BSewi0J14qGDiRdpTVeEEhiWD4KAsK)PcW5szWuDW2o0fBtI)pr)BlVi)tfGZLYGP6GTDONlpxekiP4YY2IKtWHQJvcfuSXLL4UX6amewPF6DH)q1XkXQaHDzjUMZ)qynv6zh8SPC3C(hcRPsFH87j(RhV74I7gRdWqyL(P3fERwX)NO)TLxK)PcW5szWuDW2o0VLiiahYLNlcbPPIlln)gRdWqyL(P3fEmMjsr8UJJ)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLyf)FI(3wEr(NkaNlLbt1bB7q)wIGaCixEUieKMkUSeAoBCiqV8t0bXKWk(4DZ)NO)TLFBIua(nylDb9hQowjuG0A4MlBRiPOB()e9VT8TY2ryveOFt0xaYsfx2FO6yLqbsbumEiRdpTVeEEhiWD4KAsK)PcW5szWuDW2o0fBtI)HWAQ0Zo4zt5oohP923Id5VeGFd(RJNxI8YsCBlsobhQowjuG)pr)BlFloK)sa(n4VoE(dvhRell8)j6FB5BXH8xcWVb)1XZFO6yLyf)FI(3wEr(NkaNlLbt1bB7q)wIGaCixEUieKMkgVB()e9VT8BtKcWVbBPlO)q1XkHcKwd3CzBfjfDZ)NO)TLVv2ocRIa9BI(cqwQ4Y(dvhRekqkGIXdzD4P9LWZ7abUdNutI8pvaoxkdMQd22HUyBs8pewtL(c53t8x3DhDK2BVZxyxsKaNdBbD0rAV9sKDhhzm9XKWcKYiOv2seKweE(HNwiCzj0C24qGE5NOdIjH1Yc)FI(3wERc9SrqmjSaPmcALTebPfHN)q1XkXk()e9VT8I8pvaoxkdMQd22H(Tebb4qU8CriinvCzH)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLy16ngpK1HN2xcpVde4oCsnzLGFs54qGaLJ0uPKkOJHmo6ITjrgtFmjSaPmcALTebPfHNF4PfcxwCEHW92IKtWHQJvcfuSriRdpTVeEEhiWD4KAQ9MuwKFHUyBsKX0htclqkJGwzlrqAr45hEAHWLfNxiCVTi5eCO6yLqbfBeY6Wt7lHN3bcChoPMIiMUn5FcGZ0JqxSnjYy6JjHfiLrqRSLiiTi88dpTq4YIZleU3wKCcouDSsOGInczD4P9LWZ7abUdNutsceyjQ6snQiP(HtFBhccHcbs4ITj18qZzJdb6JjHf4lGKab5zfBmxw4)t0)2YBvONncIjHfiLrqRSLiiTi88hQowjwPyJUjJPpMewGugbTYwIG0IWZFO6yLqbfBCzj0C24qGE5NOdIjHfK1HN2xcpVde4oCsnjjqGLOQl1OIKeYt)BJUrqgKFIQUyBsKX0htclqkJGwzlrqAr45hEAHWLfNxiCVTi5eCO6yLqbfBCzP5NuH7)IqVvHE24jaDKWIKtiRdpTVeEEhiWD4KAssGalrvHl2MuZdnNnoeOpMewGVasceKNvSXCzH)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLyLInUSeAoBCiqV8t0bXKWcY6Wt7lHN3bcChoPMYxIld(nG9CQJl2M02IKtWHQJvIvRrJllKX0htclqkJGwzlrqAr45hEAHWLLqZzJdb6LFIoiMewlloVq4EBrYj4q1XkHcbAgiRdpTVeEEhiWD4KAYH4)oylDbDX2K4)t0)2YBvONncIjHfiLrqRSLiiTi88hQowjwTEJllHMZghc0l)eDqmjSwwCEHW92IKtWHQJvcfuSriRdpTVeEEhiWD4KAYbpbESTkYfBtI)pr)BlVvHE2iiMewGugbTYwIG0IWZFO6yLy16nUSeAoBCiqV8t0bXKWAzX5fc3BlsobhQowjuiqyHSo80(s45DGa3HtQjclsofawOupsfReY6Wt7lHN3bcChoPM22Hoe)3DX2K4)t0)2YBvONncIjHfiLrqRSLiiTi88hQowjwTEJllHMZghc0l)eDqmjSwwCEHW92IKtWHQJvcfc0iK1HN2xcpVde4oCsnnfhf5nea(qq4ITjX)NO)TL3QqpBeetclqkJGwzlrqAr45puDSsSA9gxwcnNnoeOx(j6GysyTS48cH7TfjNGdvhRekOyJqwhEAFj88oqG7Wj1KZeb(nipJZw4ITj5iT3Er(NkaNlLbt1bB7qF)BliRdpTVeEEhiWD4KAAtGcz(n70fBts8seow19KLePebcWtICAF52rAV9I8pvaoxkdMQd22H((3wU7OJ0E7D(c7sIe4CylOJos7TV)TfKviRdpTVeEEhiWdlldsk0C24qGUuJkssGhwwge4iDI0LNmjbMUeAiKqs8)j6FB5f4HLLb9hQowjuiWYczm9XKWcKYiOv2seKweE(HNwi0n)FI(3wEbEyzzq)HQJvIvR34YIZleU3wKCcouDSsOGInczD4P9LWZ7abEyzzWWj1KvHE2iiMewGugbTYwIG0IWZfBtQ5HMZghc0l)eDqmjSwwCEHW92IKtWHQJvcfumSqwhEAFj88oqGhwwgmCsn5q8FhSLUGUyBsHMZghc0lWdlldcCKorczD4P9LWZ7abEyzzWWj1KdEc8yBvKl2MuO5SXHa9c8WYYGahPtKqwhEAFj88oqGhwwgmCsnryrYPaWcL6rQyLqwhEAFj88oqGhwwgmCsnTTdDi(V7ITjfAoBCiqVapSSmiWr6ejK1HN2xcpVde4HLLbdNuttXrrEdbGpeeUyBsHMZghc0lWdlldcCKorczD4P9LWZ7abEyzzWWj1KZeb(nipJZw4ITjfAoBCiqVapSSmiWr6ejK1HN2xcpVde4HLLbdNut5lXLb)g0XjLDX2K2wKCcouDSsSkUakVgv2jv4(Vi0VNCia5lXLdtbuSX4xwiJPpMewGugbTYwIG0IWZp80cHUJR58pewtL(c53t8xFzXrAV9oFHDjrcCoS1lro(LL44)t0)2YBvONncIjHfiLrqRSLiiTi88hQowjwTTi5eCO6yLiE3os7T35lSljsGZHTEjYlloVq4EBrYj4q1XkHcbAeY6Wt7lHN3bc8WYYGHtQPwCi)La8BWFD8CX2K4)t0)2YFMWQiGqQaSnoB)HQJvcfWyixkrqAQiK1HN2xcpVde4HLLbdNutwj4Nuooeiq5invkPc6yiJJUyBsHMZghc0lWdlldcCKorczD4P9LWZ7abEyzzWWj1u7nPSi)cDX2KcnNnoeOxGhwwge4iDIeY6Wt7lHN3bc8WYYGHtQPiIPBt(Na4m9i0fBtk0C24qGEbEyzzqGJ0jsiRdpTVeEEhiWdlldgoPMKeiWsu1LAursc5P)Tr3iidYprvxSnjYy6JjHfiLrqRSLiiTi88dpTq4YIZleU3wKCcouDSsOGInUS08tQW9FrO3QqpB8eGosyrYjK1HN2xcpVde4HLLbdNutsceyjQkCX2KAEO5SXHa9XKWc8fqsGG8SInMll8)j6FB5Tk0ZgbXKWcKYiOv2seKweE(dvhReRuSXLLqZzJdb6LFIoiMewqwhEAFj88oqGhwwgmCsnThKWkeiYxLmK1HN2xcpVde4HLLbdNut7HGalWFD8GSo80(s45DGapSSmy4KAY5lSljsGZHTUyBsoVq4EBrYj4q1XkHcbc7YsCCzBfjfDh32IKtWHQJvIvntJUJlo()e9VT8c8WYYG(dvhReRc04YIJ0E7f4HLLb9sKxw4)t0)2YlWdlld6LihV74iJPpMewGugbTYwIG0IWZp80cHll8)j6FB5Tk0ZgbXKWcKYiOv2seKweE(dvhReRc04YsO5SXHa9YprhetcR4Jp(LL42wKCcouDSsOaPMPr3XrgtFmjSaPmcwRYwIG0IWZp80cHll8)j6FB5Tk0ZgbXKWcKYiOv2seKweE(dvhReR2wKCcouDSseF8XdzD4P9LWZ7abEyzzWWj1KapSSmOl2Me)FI(3w(ZewfbesfGTXz7puDSsOGIlloVq4EBrYj4q1XkHcbclK1HN2xcpVde4HLLbdNutote43G8moBbK1HN2xcpVde4HLLbdNutBcuiZVzNUyBsIxIWXQUNSKiLiqaEsKt7l3os7TxGhwwg03)2YDhDK2BVZxyxsKaNdBbD0rAV99VTGSczD4P9LW)KXcpsBtKGFdsze0kBjcslcpx4b5eiiN7IWuqkGl2Mex28QtmLXLTvKwhY6Wt7lH)jJfEHtQjmgzKaipNQl2MuoeyLEUSbCKor6XACiWUBUS5vNykJlBRiToK1HN2xc)tgl8cNutPfHhG8qO6cpiNab5CrykifWfBtI)QopqKNXgDZLnV6etzCzBfjfHSo80(s4FYyHx4KAIlBG2je6ITjXLnV6etzCzJKIqwhEAFj8pzSWlCsnHXiJea55uHSo80(s4FYyHx4KAkTi8aKhcvx4b5eiiNlctbPaUyBsCzZRoXugx2wrsriRqwhEAFj8c8WYYGK2MifGFd2sxqxSnjhP92lWdlld6puDSsOqaiRdpTVeEbEyzzWWj1KGSvLvra(nfcyBC2UyBs8x15bI8m2O74gEAHqawOQHIvKwFzz4PfcbyHQgkwfWDZ5)t0)2YFMWQiGqQaSnoBVe54HSo80(s4f4HLLbdNutNjSkciKkaBJZ2fEqobcY5IWuqkGl2Me)vDEGipJnczD4P9LWlWdlldgoPM2MifGFd2sxqxSnPHNwieGfQAOyfP1HSo80(s4f4HLLbdNutcYwvwfb43uiGTXz7ITjXFvNhiYZyJUDK2BFFkoc(nGlBSqZlrgY6Wt7lHxGhwwgmCsn5qmC2VucyBC2UWdYjqqoxeMcsbCX2K4VQZde5zSr3os7TVfhYFja)g8xhpVez38)j6FB5ptyveqiva2gNT)q1XkXkfHSo80(s4f4HLLbdNutBtKcWVbBPlOlwL4DsKtGTj5iT3EbEyzzqVez38)j6FB5ptyveqiva2gNT)WPheY6Wt7lHxGhwwgmCsnjiBvzveGFtHa2gNTl2Me)vDEGipJn6UJos7T35lSljsGZHTGo6iT3EjYqwhEAFj8c8WYYGHtQPTjsWVbPmcALTebPfHNl8GCceKZfHPGuaxSnjUSPW6qwhEAFj8c8WYYGHtQjhIHZ(LsaBJZ2fEqobcY5IWuqkGl2Me)vDEGipJnUS08CiWk9Ywc4VQZdzD4P9LWlWdlldgoPMeKTQSkcWVPqaBJZgYkK1HN2xcVij1kBhHvrG(nrFbilvCzxSnPBSoadHv6NEx4TAf)FI(3w(wz7iSkc0Vj6lazPIl77s3K2xHPg9kVLLBSoadHv6NEx4LidzD4P9LWlYWj1ew4fznlwfbqclMDUyBsCzZRoXugx2wrsr3yHxuqFAQiiFG6eB16llCzZRoXugx2wrIfDhhw4ff0NMkcYhOoXwP4YsZjFyiqeV7d4tlcpa5HqnEiRdpTVeErgoPMeKTQSkcWVPqaBJZ2fBtI)QopqKNXgD7iT3((uCe8Bax2yHMxIS74UX6amewPF6DH3Qvos7TVpfhb)gWLnwO5puDSsOmfxwUX6amewPF6DHxIC8qwhEAFj8ImCsnDMWQiGqQaSnoBx4b5eiiNlctbPaUyBs8)j6FB5f4HLLb9hQowjwfyzP55qGv6f4HLLbDhh)FI(3w(wCi)La8BWFD88hQowjwXIllnN)HWAQ0Zo4ztfpK1HN2xcVidNutBtKcWVbBPlOl2MuC3yDagcR0p9UWB1k()e9VT8BtKcWVbBPlOVlDtAFfMA0R8wwUX6amewPF6DHxIC8UJdl8Ic6ttfb5duNyRWyixkrqAQOYcSSWLnV6etzCztbsbwwCK2BVi)tfGZLYGP6GTDO)q1XkHcymKlLiinvm8aXVSSTi5eCO6yLqbmgYLseKMkgEGLLo6iT3ENVWUKiboh2c6OJ0E7LidzD4P9LWlYWj1e)goBcRIaSWPJaclsolRICX2KCK2BFkJauLmE)ja8H8WT8pViho7vbwd3yHxuqFAQiiFG6eBfgd5sjcstfvwa38)j6FB5ptyveqiva2gNT)q1XkXkmgYLseKMkUS4iT3(ugbOkz8(ta4d5HB5FEroC2RcWIUJJ)pr)BlVapSSmO)q1XkHcH1DoeyLEbEyzzWLf()e9VT8T4q(lb43G)645puDSsOqyDZ)qynv6zh8SPww2wKCcouDSsOqyJhY6Wt7lHxKHtQPtsiBveGfoDe0Av3fBtYrAV9NKq2QialC6iO1QUV)TL7HNwieGfQAOyvaiRdpTVeErgoPM2Mib)gKYiOv2seKweEUWdYjqqoxeMcsbCX2K4YMcRdzD4P9LWlYWj1egJmsaKNt1fBtIlBE1jMY4Y2ksbGSo80(s4fz4KAIlBahPtKUyBsCzZRoXugx2wrkG7HNwieGfQAOGua33yDagcR0p9UWB1kfBCzHlBE1jMY4Y2ksk6E4PfcbyHQgkwrsriRdpTVeErgoPM4YgODcHqwhEAFj8ImCsnLweEaYdHQl8GCceKZfHPGuaxSnj(R68arEgB0nx28QtmLXLTvKu0TJ0E7f5FQaCUugmvhSTd99VTGSo80(s4fz4KAsq2QYQia)McbSnoBxSnjhP92ZLnaw4ff0lYHZE16nQSWgMgEAHqawOQHc3os7TxK)PcW5szWuDW2o03)2YDC8)j6FB5ptyveqiva2gNT)q1XkXkfDZ)NO)TLFBIua(nylDb9hQowjwP4Yc)FI(3w(ZewfbesfGTXz7puDSsOW6U5)t0)2YVnrka)gSLUG(dvhReRw3nx2wT(Yc)FI(3w(ZewfbesfGTXz7puDSsSAD38)j6FB53MifGFd2sxq)HQJvcfw3nx2wXIllCzZRoXugx2uGua3yHxuqFAQiiFG6etbfJFzXrAV9CzdGfErb9IC4SxfOr3BlsobhQowjuOzdzD4P9LWlYWj1KdXWz)sjGTXz7cpiNab5CrykifWfBtI)QopqKNXgDhxoeyLEbEyzzq38)j6FB5f4HLLb9hQowjuy9Lf()e9VT8NjSkciKkaBJZ2FO6yLyva38)j6FB53MifGFd2sxq)HQJvIvbww4)t0)2YFMWQiGqQaSnoB)HQJvcfw3n)FI(3w(Tjsb43GT0f0FO6yLy16U5Y2kfxw4)t0)2YFMWQiGqQaSnoB)HQJvIvR7M)pr)Bl)2ePa8BWw6c6puDSsOW6U5Y2Q1xw4Y2QWUS4iT3ENNnG89CVe54HSo80(s4fz4KAkTi8aKhcvx4b5eiiNlctbPaUyBs8x15bI8m2OBUS5vNykJlBRiPiK1HN2xcVidNutZXNcb5FhwPl2Mex28QtmLXLTvKcazD4P9LWlYWj10MiOvrabEKXkbSnoBxSkX7KiNKcazD4P9LWlYWj1KdXWz)sjGTXz7cpiNab5CrykifWfBtI)QopqKNXgDZ)NO)TLFBIua(nylDb9hQowjuyD3CzJKIUjFyiqeV7d4tlcpa5Hq1nw4ff0NMkcYhe2gviaK1HN2xcVidNutoedN9lLa2gNTl8GCceKZfHPGuaxSnj(R68arEgB0nw4ff0NMkcYhOoXuqr3XXLnV6etzCztbsbwwiFyiqeV7d4tlcpa5HqnEiRqwhEAFj8T4q(lb43G)64rk0C24qGUuJksYHy4SFPeW24SbfIDS7YtMKatxcnesijhP923Id5VeGFd(RJhOT1FO6yLWDC8)j6FB5ptyveqiva2gNT)q1XkXkhP923Id5VeGFd(RJhOT1FO6yLWTJ0E7BXH8xcWVb)1Xd026puDSsOGI(all8)j6FB5ptyveqiva2gNT)q1XkHYCK2BFloK)sa(n4VoEG2w)HQJvIvb8RHBhP923Id5VeGFd(RJhOT1FO6yLqbw0hyzXrAV9oe)3jKePxISBhP92BvONnEcqhjSi50lr2TJ0E7Tk0ZgpbOJewKC6puDSsOGJ0E7BXH8xcWVb)1Xd026puDSsepK1HN2xcFloK)sa(n4VoEHtQj(qqagEAFbimr6snQijEhiWTl2MuZZHaR0lWdlldczD4P9LW3Id5VeGFd(RJx4KAIpeeGHN2xactKUuJksI3bc8WYYGUyBs5qGv6f4HLLbHSo80(s4BXH8xcWVb)1XlCsnHfErwZIvraKWIzNl2Mex28QtmLXLTvKu0nw4ff0NMkcYhOoXwToK1HN2xcFloK)sa(n4VoEHtQPZewfbesfGTXz7cpiNab5CrykifaY6Wt7lHVfhYFja)g8xhVWj102ePa8BWw6c6ITjn80cHaSqvdfRiPOBhP923Id5VeGFd(RJhOT1FO6yLqHaqwhEAFj8T4q(lb43G)64foPMALTJWQiq)MOVaKLkUSl2M0WtlecWcvnuSIKIqwhEAFj8T4q(lb43G)64foPMeKTQSkcWVPqaBJZ2fBtI)QopqKNXgDp80cHaSqvdfRiTUBhP923Id5VeGFd(RJhOT1lrgY6Wt7lHVfhYFja)g8xhVWj1KdXWz)sjGTXz7cpiNab5CrykifWfBtI)QopqKNXgDp80cHaSqvdfkqsr3HMZghc07qmC2VucyBC2GcXo2HSo80(s4BXH8xcWVb)1XlCsnjiBvzveGFtHa2gNTl2Me)vDEGipJn62rAV99P4i43aUSXcnVeziRdpTVe(wCi)La8BWFD8cNutymYibqEovxSnjUSrQr3os7TVfhYFja)g8xhpqBR)q1XkHcSiK1HN2xcFloK)sa(n4VoEHtQPTjsWVbPmcALTebPfHNl8GCceKZfHPGuaxSnjUSrQr3os7TVfhYFja)g8xhpqBR)q1XkHcSiK1HN2xcFloK)sa(n4VoEHtQPwz7iSkc0Vj6lazPIldzD4P9LW3Id5VeGFd(RJx4KAkTi8aKhcvx4b5eiiNlctbPaUyBsCzJuJUDK2BFloK)sa(n4VoEG2w)HQJvcfyriRdpTVe(wCi)La8BWFD8cNutBtKcWVbBPlOlwL4DsKtGTj5iT3(wCi)La8BWFD8aTTEjYUyBsos7TxK)PcW5szWuDW2o0lr29nwhGHWk9tVl8wTI)pr)Bl)2ePa8BWw6c67s3K2xHPg9ndK1HN2xcFloK)sa(n4VoEHtQjbzRkRIa8BkeW24SDX2KCK2Bpx2ayHxuqViho7vR3OYcByA4PfcbyHQgkGSo80(s4BXH8xcWVb)1XlCsnTnrc(niLrqRSLiiTi8CHhKtGGCUimfKc4ITjXLnfwhY6Wt7lHVfhYFja)g8xhVWj1egJmsaKNt1fBtIlBE1jMY4Y2ksbGSo80(s4BXH8xcWVb)1XlCsnXLnGJ0jsxSnjUS5vNykJlBRifxGWhEAHqawOQHIvbIhY6Wt7lHVfhYFja)g8xhVWj1uAr4bipeQUWdYjqqoxeMcsbCX2KIR55qGv6LTeWFvNFzH)QopqKNXgJ3nx28QtmLXLTvKueY6Wt7lHVfhYFja)g8xhVWj1KdXWz)sjGTXz7cpiNab5CrykifWfBtA4PfcbyHQgkuG06U5Y2ksRVS4iT3(wCi)La8BWFD8aTTEjYqwhEAFj8T4q(lb43G)64foPM4YgODcHqwhEAFj8T4q(lb43G)64foPM2ebTkciWJmwjGTXz7IvjENe5KuanZiLY)Pzym11wN6uRb]] )


end