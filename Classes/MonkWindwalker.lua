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
            return buff.weapons_of_order_buff.up and ( c - 1 ) or c
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

                if buff.weapons_of_order.up then applyBuff( "weapons_of_order_buff" ) end
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

            bind = "storm_earth_and_fire_focus",

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
            cast = 0,
            cooldown = 0,
            icd = 1,
            gcd = "spell",

            startsCombat = true,
            texture = 236188,

            notalent = "serenity",
            buff = "storm_earth_and_fire",

            bind = "storm_earth_and_fire_focus",
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
    
    spec:RegisterPack( "Windwalker", 20201217, [[d00ghcqisbEKejQnPi(KePgfIWPavAviIuVIu0SqKUfPq7IQ(fPQgMIuhJuzziONPizAiI6AseTnqf5BKcY4avW5Ki06KiO5HO6EsQ9jrDqerIfsQYdbviteuHcxuIeAJseq(iIiPtkrISse4LGkuYmjfu3uIaQDcQ6NGkunuqfkAPseGNQQMkIYvbvOuFvIemwqf1EH6VadMKdl1ILWJHmzfUmQndYNLKrtfNMYQLiPxtknBv52eSBr)wPHtihxIaTCvEortx46uPTRO67i04vuopHA9iIy(GY(rASomz4)OdgdpHtt406iuNgYRRejSe1PHW)qSig)f1iTDfJ)zlW4FPGLdI9tlF4VOw8B7bMm8xUUhIXF8VW1ErPuIlW)rhmgEcNMWP1rOonKxxjsyjoDjI)srmcdpHWPse)DSXGtCb(pyjc)lLPQsblhe7Nw(OQsG3ulLGszQcogmIfk4JQ0PHiLQiCAcNg)FMmKyYW)veN8HjddVomz4pNDXJhy9W)gf2M4pKjdWcbchgq0XcgewfF4p6SGpRXFKJ5f6zuLgPkKJrvLRPQPWFKy0JbrFxfhs8xhoWWtiMm8NZU4XdSE4p6SGpRX)OFCgEKJbkCpz45SlE8GQMqvihZl0ZOknsvihJQkxtvtH)nkSnXFEMi(bC6tahy4Nctg(Zzx84bwp8VrHTj(hwfFar9ta)rNf8zn(JwHIfiJZ0Yu1eQc5yEHEgvPrQc5yuv5AQIq8hjg9yq0xfhsm86WbgEsgtg(Zzx84bwp8hDwWN14pYX8c9mQsJufYXOQAQIq8VrHTj(JCmaXEoJdm8Letg(3OW2e)5zI4hWPpb8NZU4XdSE4adpCctg(Zzx84bwp8VrHTj(hwfFar9ta)rNf8zn(JCmVqpJQ0ivHCmQQCnvri(JeJEmi6RIdjgED4ah4prUfTPeSqG9g8HjddVomz4pNDXJhy9WF0zbFwJ)Aavf9JZWl5Jtle75SlE8a)BuyBI)O(9ankSnbptg4)ZKbiBbg)rdGKHWbgEcXKH)C2fpEG1d)rNf8zn(h9JZWl5Jtle75SlE8a)BuyBI)O(9ankSnbptg4)ZKbiBbg)rdGKpoTqmoWWpfMm8NZU4XdSE4p6SGpRXFKJ5f6zuLgPkKJrvLRPkcPQjufN8vj2hMadIfi0ZOQYu1u4FJcBt8Nt(QmsILva(zZSdhy4jzmz4pNDXJhy9W)gf2M4)zslRas3eO1qAXFKy0JbrFvCiXWRdhy4ljMm8NZU4XdSE4p6SGpRXF0kuSazCMwMQMqvfUqq(rNigSqaKJvQM3ve(3OW2e)LISmTScGUozGwdPfhy4HtyYWFo7IhpW6H)OZc(Sg)BuyZzaNSGXsQQCnvrivnHQkCHG8e5w0MsWcb2BWhGir)XcTLsQICQsh(3OW2e)HmzibleaY9eJdm8Aimz4pNDXJhy9WF0zbFwJ)nkS5mGtwWyjvvUMQie)BuyBI)eDS7zzfyCD1MarUjYbhy4HdyYWFo7IhpW6H)OZc(Sg)rRqXcKXzAzQAcv1OWMZaozbJLuv5AQAkQAcvv4cb5jYTOnLGfcS3GparIExr4FJcBt8xkYY0Yka66KbAnKwCGHVeXKH)C2fpEG1d)BuyBI)fVgPDDdGwdPf)rNf8zn(JwHIfiJZ0Yu1eQQrHnNbCYcglPkYRPkcXFKy0JbrFvCiXWRdhy41nnMm8VrHTj(t0XUNLvGX1vBce5Mih8NZU4XdSE4adVoDyYWFo7IhpW6H)OZc(Sg)lCHG8Yypba3x4a6CaGSJ9UIOQju112aWZ5m89yi9wsvLPk0UVXsm9qMmKGfca5EI9d3RdBtQIKMQM2dNW)gf2M4pKjdjyHaqUNy83YGVZvuami8VWfcYtKBrBkbleyVbFaIe9UIWbgEDeIjd)5SlE8aRh(Jol4ZA8VWfcYJCmaN8vj2lJgPLQktvtnnvPrQQKufjnv1OWMZaozbJL4FJcBt8xkYY0Yka66KbAnKwCGHx3uyYWFo7IhpW6H)nkSnXFitgGfceomGOJfmiSk(WF0zbFwJ)ihJQiNQMc)rIrpge9vXHedVoCGHxhjJjd)5SlE8aRh(Jol4ZA8h5yEHEgvPrQc5yuv5AQsh(3OW2e)5zI4hWPpbCGHxxjXKH)C2fpEG1d)rNf8zn(JCmVqpJQ0ivHCmQQCnvrcQshvPjv1OWMZaozbJLuvzQshvbx8VrHTj(JCmqH7jdCGHxhCctg(Zzx84bwp8VrHTj(hwfFar9ta)rNf8zn(tcQsdOQOFCgEhlaOvOy9C2fpEqvWGrvOvOybY4mTmvbxQAcvHCmVqpJQ0ivHCmQQCnvri(JeJEmi6RIdjgED4adVoneMm8VrHTj(JCmaXEoJ)C2fpEG1dhy41bhWKH)C2fpEG1d)BuyBI)fVgPDDdGwdPf)rNf8zn(JCmQQCnvnfvbdgvv4cb5jYTOnLGfcS3GparIExr4psm6XGOVkoKy41Hdm86krmz4VLbFNROa)1H)nkSnXFONylRas(eXza0AiT4pNDXJhy9WboWFjFCAHymzy41Hjd)5SlE8aRh(Jol4ZA8VWfcYl5Jtle7pwOTusvKtv6W)gf2M4pKjdjyHaqUNyCGHNqmz4pNDXJhy9W)Sfy83sj6CJU4XGsq3odxbWGNBig)BuyBI)wkrNB0fpguc62z4kag8CdX4ad)uyYWFo7IhpW6H)zlW4)44EazhdMZsj)W)gf2M4)44EazhdMZsj)WbgEsgtg(Zzx84bwp8hDwWN14pAfkwGmotltvtOksqvnkS5mGtwWyjvvUMQMIQGbJQAuyZzaNSGXsQQmvPJQMqvAavH29nwIP)mPLvaPBc0AiTExrufCX)gf2M4VuKLPLva01jd0AiT4adFjXKH)C2fpEG1d)BuyBI)NjTSciDtGwdPf)rNf8zn(JwHIfiJZ0Y4psm6XGOVkoKy41Hdm8Wjmz4pNDXJhy9WF0zbFwJ)nkS5mGtwWyjvvUMQMc)BuyBI)qMmKGfca5EIXbgEneMm8NZU4XdSE4p6SGpRXF0kuSazCMwMQMqvfUqq(rNigSqaKJvQM3ve(3OW2e)LISmTScGUozGwdPfhy4HdyYWFo7IhpW6H)nkSnX)IxJ0UUbqRH0I)OZc(Sg)rRqXcKXzAzQAcvv4cb5jYTOnLGfcS3GparIExru1eQcT7BSet)zslRas3eO1qA9hl0wkPQYufH4psm6XGOVkoKy41Hdm8LiMm83YGVZvuami8xdq7(glX0FM0YkG0nbAnKwVRi8VrHTj(dzYqcwiaK7jg)5SlE8aRhoWWRBAmz4pNDXJhy9WF0zbFwJ)OvOybY4mTmvnHQgCHleKVytE4kdqXXe9UIW)gf2M4VuKLPLva01jd0AiT4adVoDyYWFo7IhpW6H)nkSnXFitgGfceomGOJfmiSk(WF0zbFwJ)ihJQiNQMc)rIrpge9vXHedVoCGHxhHyYWFo7IhpW6H)nkSnX)IxJ0UUbqRH0I)OZc(Sg)rRqXcKXzAzQcgmQsdOQOFCgEhlaOvOy9C2fpEG)iXOhdI(Q4qIHxhoWWRBkmz4FJcBt8xkYY0Yka66KbAnKw8NZU4XdSE4ah4pAaK8XPfIXKHHxhMm8NZU4XdSE4)kc)LCG)nkSnX)59zDXJX)59ZLXF0UVXsm9s(40cX(JfAlLuf5uLoQcgmQseh(zUCcchgq0XcgewfF(gf2CMQMqvODFJLy6L8XPfI9hl0wkPQYu1uttvWGrvqwLtaowOTusvKtveon(pVpq2cm(l5JtledkCpzGdm8eIjd)5SlE8aRh(Jol4ZA8xdOQ59zDXJ9o7BaM5Yjvbdgvbzvob4yH2sjvrovryjX)gf2M4VLZxTmyMlN4ad)uyYWFo7IhpW6H)zlW4FlDM3jlbxts2dG2RF4FJcBt8VLoZ7KLGRjj7bq71pCGHNKXKH)nkSnXFxjdSGfK4pNDXJhy9Wbg(sIjd)5SlE8aRh(Jol4ZA8FEFwx8yVKpoTqmOW9Kb(3OW2e)lE7oaqUNyCGHhoHjd)5SlE8aRh(Jol4ZA8FEFwx8yVKpoTqmOW9Kb(3OW2e)l4tYNwlRWbgEneMm8NZU4XdSE4p6SGpRXFiRYjahl0wkPQYuLo4qjPkyWOQ59zDXJ9s(40cXGc3tgufmyufKv5eGJfAlLuf5u1uLe)BuyBI)vU9nSobleOjj8THdoWWdhWKH)C2fpEG1d)rNf8zn(pVpRlESxYhNwigu4EYa)BuyBI)e37nMZwcowUzNighy4lrmz4pNDXJhy9WF0zbFwJ)Z7Z6Ih7L8XPfIbfUNmW)gf2M4FXB3byHaHdd4KfeJdm86Mgtg(Zzx84bwp8hDwWN14pjOk0UVXsm9s(40cX(JfAlLufmyufA33yjME0MioJRdEaGETa7ro9vXsQQMQiKQGlvnHQ0aQASHhTjIZ46GhaOxlWGc3l9hl0wkPQjufjOk0UVXsm9NjTSciDtGwdP1FSqBPKQMqvODFJLy6HmzibleaY9e7pwOTusvWGrvqwLtaowOTusvKtvWbQcU4FJcBt8hTjIZ46GhaOxlW4adVoDyYW)gf2M4F4Wa3SyDZbaApeJ)C2fpEG1dhy41riMm8VrHTj(lY9miXwwbkETmWFo7IhpW6Hdm86Mctg(Zzx84bwp8hDwWN14F0xfh(WeyqSarOaq40uvzQAQPPkyWOQOVko8oC)chViuqvKxtveonvbdgvf9vXHpmbgelyymvrovri(3OW2e)pUfzzfa61cSehy41rYyYW)gf2M4p0ICL8a0Ke(SGbfClG)C2fpEG1dhy41vsmz4pNDXJhy9WF0zbFwJ)CYxLyQICQIKNg)BuyBI)cSWEIble45ISbyCCliXbgEDWjmz4FJcBt8)mrIEmWsGuuJy8NZU4XdSE4adVoneMm8NZU4XdSE4p6SGpRXFKJ5f6zuLgPkKJrvLRPkD4FJcBt8VpuNmi274mWbgEDWbmz4FJcBt8)zvoHeuQUJkbod8NZU4XdSE4adVUsetg(Zzx84bwp8hDwWN14)8(SU4XEjFCAHyqH7jd8VrHTj(dzhx82DGdm8eonMm8NZU4XdSE4p6SGpRX)59zDXJ9s(40cXGc3tg4FJcBt8VtelJRFau)E4adpH6WKH)C2fpEG1d)rNf8zn(pVpRlESxYhNwigu4EYa)BuyBI)fDfyHaXziTsCGHNqcXKH)C2fpEG1d)rNf8zn(dzvob4yH2sjvvMQ0bhMMQGbJQeXHFMlNGWHbeDSGbHvXNVrHnNPkyWOkiRYjahl0wkPkYPkDtJ)nkSnX)yDroGfcm4oCWbgEcNctg(Zzx84bwp8hDwWN14pKv5eGJfAlLuvzQQeNMQGbJQeXHFMlNGWHbeDSGbHvXNVrHnNPkyWOkiRYjahl0wkPkYPkDtJ)nkSnX)yDroGfcOTpHghy4jKKXKH)C2fpEG1d)rNf8zn(J29nwIP)mPLvaPBc0AiT(JfAlLuf5ufpJrUbdctGX)gf2M4prUfTPeSqG9g8Hdm8ewsmz4FJcBt8hQ5NLmqgRGi8NZU4XdSE4adpHWjmz4FJcBt8hQFpob7n4d)5SlE8aRhoWWtOgctg(3OW2e)l2KhUYauCmr8NZU4XdSE4adpHWbmz4pNDXJhy9WF0zbFwJ)ODFJLy6ptAzfq6MaTgsR)yH2sjvrovrivbdgvbzvob4yH2sjvrovPRK4FJcBt8xYhNwighy4jSeXKH)nkSnX)IUcSqG4mKwj(Zzx84bwpCGd8xgyYWWRdtg(Zzx84bwp8hDwWN14)12aWZ5m89yi9wsvLPk0UVXsm9eDS7zzfyCD1MarUjYXpCVoSnPksAQAApCGQGbJQU2gaEoNHVhdP3ve(3OW2e)j6y3ZYkW46QnbICtKdoWWtiMm8NZU4XdSE4p6SGpRXFKJ5f6zuLgPkKJrvLRPkcPQjufN8vj2hMadIfi0ZOQYu1uufmyufYX8c9mQsJufYXOQY1ufjtvtOksqvCYxLyFycmiwGqpJQktvesvWGrvAavj645Gk0WRZhwfFar9tGQGl(3OW2e)5KVkJKyzfGF2m7Wbg(PWKH)C2fpEG1d)rNf8zn(JwHIfiJZ0Yu1eQQWfcYp6eXGfcGCSs18UIOQjufjOQRTbGNZz47Xq6TKQktvfUqq(rNigSqaKJvQM)yH2sjvPrQIqQcgmQ6ABa45Cg(EmKExrufCX)gf2M4VuKLPLva01jd0AiT4adpjJjd)5SlE8aRh(3OW2e)ptAzfq6MaTgsl(Jol4ZA8hT7BSetVKpoTqS)yH2sjvvMQ0rvWGrvAavf9JZWl5Jtle75SlE8a)rIrpge9vXHedVoCGHVKyYWFo7IhpW6H)OZc(Sg)jbvDTna8CodFpgsVLuvzQcT7BSetpKjdjyHaqUNy)W96W2KQiPPQP9WbQcgmQ6ABa45Cg(EmKExrufCPQjufjOko5RsSpmbgelqONrvLPkEgJCdgeMatvAKQ0rvWGrvihZl0ZOknsvihJQiVMQ0rvWGrvfUqqEzSNaG7lCaDoaq2X(JfAlLuf5ufpJrUbdctGPknPkDufCPkyWOkiRYjahl0wkPkYPkEgJCdgeMatvAsv6W)gf2M4pKjdjyHaqUNyCGHhoHjd)5SlE8aRh(Jol4ZA8VWfcYhomGfeX3EsaQf1il2ZlJgPLQktv6krQAcvXjFvI9HjWGybc9mQQmvXZyKBWGWeyQsJuLoQAcvH29nwIP)mPLvaPBc0AiT(JfAlLuvzQINXi3GbHjWufmyuvHleKpCyaliIV9KaulQrwSNxgnslvvMQ0rYu1eQIeufA33yjMEjFCAHy)XcTLsQICQQKu1eQk6hNHxYhNwi2Zzx84bvbdgvH29nwIPNi3I2ucwiWEd(8hl0wkPkYPQssvtOk0oNZodVwXN1jvbdgvbzvob4yH2sjvrovvsQcU4FJcBt8hDns7ZYkqP2dg8SkNiTSchy41qyYWFo7IhpW6H)OZc(Sg)lCHG8NR0XYkqP2dgq0YHFSetQAcv1OWMZaozbJLuvzQsh(3OW2e)pxPJLvGsThmGOLdCGHhoGjd)5SlE8aRh(3OW2e)Hmzawiq4WaIowWGWQ4d)rNf8zn(JCmQICQAk8hjg9yq0xfhsm86Wbg(setg(Zzx84bwp8hDwWN14pYX8c9mQsJufYXOQY1uLo8VrHTj(ZZeXpGtFc4adVUPXKH)C2fpEG1d)rNf8zn(JCmVqpJQ0ivHCmQQCnvPJQMqvnkS5mGtwWyjvvtv6OQju112aWZ5m89yi9wsvLPkcNMQGbJQqoMxONrvAKQqogvvUMQiKQMqvnkS5mGtwWyjvvUMQie)BuyBI)ihdu4EYahy41Pdtg(3OW2e)rogGypNXFo7IhpW6Hdm86ietg(Zzx84bwp8VrHTj(hwfFar9ta)rNf8zn(JwHIfiJZ0Yu1eQc5yEHEgvPrQc5yuv5AQIqQAcvv4cb5LXEcaUVWb05aazh7hlXe)rIrpge9vXHedVoCGHx3uyYWFo7IhpW6H)OZc(Sg)lCHG8ihdWjFvI9YOrAPQYu1uttvAKQkjvrstvnkS5mGtwWyjvnHQkCHG8Yypba3x4a6CaGSJ9JLysvtOksqvODFJLy6ptAzfq6MaTgsR)yH2sjvvMQiKQMqvODFJLy6HmzibleaY9e7pwOTusvLPkcPkyWOk0UVXsm9NjTSciDtGwdP1FSqBPKQiNQMIQMqvODFJLy6HmzibleaY9e7pwOTusvLPQPOQjufYXOQYu1uufmyufA33yjM(ZKwwbKUjqRH06pwOTusvLPQPOQjufA33yjMEitgsWcbGCpX(JfAlLuf5u1uu1eQc5yuvzQIKPkyWOkKJ5f6zuLgPkKJrvKxtv6OQjufN8vj2hMadIfi0ZOkYPkcPk4svWGrvfUqqEKJb4KVkXEz0iTuvzQs30u1eQcYQCcWXcTLsQICQsdH)nkSnXFPiltlRaORtgO1qAXbgEDKmMm8NZU4XdSE4FJcBt8V41iTRBa0AiT4p6SGpRXF0kuSazCMwMQMqvKGQI(Xz4L8XPfI9C2fpEqvtOk0UVXsm9s(40cX(JfAlLuf5u1uufmyufA33yjM(ZKwwbKUjqRH06pwOTusvLPkDu1eQcT7BSetpKjdjyHaqUNy)XcTLsQQmvPJQGbJQq7(glX0FM0YkG0nbAnKw)XcTLsQICQAkQAcvH29nwIPhYKHeSqai3tS)yH2sjvvMQMIQMqvihJQktvesvWGrvODFJLy6ptAzfq6MaTgsR)yH2sjvvMQMIQMqvODFJLy6HmzibleaY9e7pwOTusvKtvtrvtOkKJrvLPQPOkyWOkKJrvLPQssvWGrvfUqq(Ivlq0TiVRiQcU4psm6XGOVkoKy41Hdm86kjMm8NZU4XdSE4FJcBt8pSk(aI6Na(Jol4ZA8hTcflqgNPLPQjufYX8c9mQsJufYXOQY1ufH4psm6XGOVkoKy41Hdm86GtyYWFld(oxrb(Rd)BuyBI)qpXwwbK8jIZaO1qAXFo7IhpW6Hdm860qyYWFo7IhpW6H)nkSnX)IxJ0UUbqRH0I)OZc(Sg)rRqXcKXzAzQAcvH29nwIPhYKHeSqai3tS)yH2sjvrovnfvnHQqogvvtvesvtOkrhphuHgED(WQ4diQFcu1eQIt(Qe7dtGbXck50uf5uLo8hjg9yq0xfhsm86WbgEDWbmz4pNDXJhy9W)gf2M4FXRrAx3aO1qAXF0zbFwJ)OvOybY4mTmvnHQ4KVkX(WeyqSaHEgvrovrivnHQibvHCmVqpJQ0ivHCmQI8AQshvbdgvj645Gk0WRZhwfFar9tGQGl(JeJEmi6RIdjgED4ah4pAaKmeMmm86WKH)C2fpEG1d)rNf8zn(Rbu18(SU4XEN9naZC5KQGbJQGSkNaCSqBPKQiNQiSK4FJcBt83Y5RwgmZLtCGHNqmz4pNDXJhy9WF0zbFwJ)ihZl0ZOknsvihJQkxtv6W)gf2M4FFOozqS3XzGdm8tHjd)5SlE8aRh(Jol4ZA8VWfcYlJ9eaCFHdOZbaYo2pwIjvnHQeXHFMlNGWHbeDSGbHvXNVrHnNPkyWOkiRYjahl0wkPkYPkDttvWGrvqwLtaowOTusvLPkDWHPX)gf2M4FSUihWcbgCho4adpjJjd)5SlE8aRh(Jol4ZA8Neu112aWZ5m89yi9wsvLPksUKufmyu112aWZ5m89yi9UIOk4svtOk0UVXsm9NjTSciDtGwdP1FSqBPKQiNQ4zmYnyqycm(3OW2e)jYTOnLGfcS3GpCGHVKyYWFo7IhpW6H)OZc(Sg)rRqXcKXzAzQAcvrcQ6ABa45Cg(EmKElPQYuLUPPkyWOQRTbGNZz47Xq6DfrvWf)BuyBI)qn)SKbYyfeHdm8Wjmz4pNDXJhy9WF0zbFwJ)xBdapNZW3JH0BjvvMQMAAQcgmQ6ABa45Cg(EmKExr4FJcBt8hQFpob7n4dhy41qyYWFo7IhpW6H)OZc(Sg)V2gaEoNHVhdP3sQQmvvYPPkyWOQRTbGNZz47Xq6DfH)nkSnX)In5HRmafhte)FwYa0a)HttJdm8Wbmz4pNDXJhy9WF0zbFwJ)ODFJLy6LXEcaUVWb05aazh7ro9vXsQQMQiKQGbJQGSkNaCSqBPKQiNQiCAQcgmQIeu112aWZ5m89yi9hl0wkPQYuLUssvWGrvAavH25C2z41k(SoPQjufjOksqvxBdapNZW3JH0BjvvMQq7(glX0lJ9eaCFHdOZbaYo2d5(EGJro9vXGWeyQcgmQsdOQRTbGNZz47Xq65zMmKufCPQjufjOk0UVXsm9woF1YGzUCcchgq0XcgewfF(JfAlLuvzQcT7BSetVm2taW9foGohai7ypK77bog50xfdctGPkyWOQ59zDXJ9o7BaM5YjvbxQcUu1eQcT7BSetpKjdjyHaqUNy)XcTLsQI8AQQePQjufYXOQY1ufHu1eQcT7BSetprh7EwwbgxxTjqKBIC8hl0wkPkYRPkDesvWf)BuyBI)Yypba3x4a6CaGSJXbg(setg(Zzx84bwp8hDwWN14pANZzNHxR4Z6KQMqvKGQkCHG8e5w0MsWcb2BWN3vevbdgvrcQcYQCcWXcTLsQICQcT7BSetprUfTPeSqG9g85pwOTusvWGrvODFJLy6jYTOnLGfcS3Gp)XcTLsQQmvH29nwIPxg7ja4(chqNdaKDShY99ahJC6RIbHjWufCPQjufA33yjMEitgsWcbGCpX(JfAlLuf51uvjsvtOkKJrvLRPkcPQjufA33yjMEIo29SScmUUAtGi3e54pwOTusvKxtv6iKQGl(3OW2e)LXEcaUVWb05aazhJdm86Mgtg(Zzx84bwp8hDwWN14pA33yjMEitgsWcbGCpX(JfAlLuf5ufHufmyufKv5eGJfAlLuf5uLocX)gf2M4FXB3byHaHdd4KfeJdm860Hjd)BuyBI)vU9nSobleOjj8THd(Zzx84bwpCGHxhHyYW)gf2M4pX9EJ5SLGJLB2jIXFo7IhpW6Hdm86Mctg(Zzx84bwp8hDwWN14VgqvJn8OnrCgxh8aa9Abgu4EP)yH2sjvnHQibvrcQsdOQOFCgEIo29SScmUUAtGi3e545SlE8GQGbJQq7(glX0t0XUNLvGX1vBce5Mih)XcTLsQcUu1eQcT7BSet)zslRas3eO1qA9hl0wkPQjufA33yjMEitgsWcbGCpX(JfAlLu1eQQWfcYlJ9eaCFHdOZbaYo2pwIjvbxQcgmQcYQCcWXcTLsQICQcoG)nkSnXF0MioJRdEaGETaJdm86izmz4FJcBt8pCyGBwSU5aaThIXFo7IhpW6Hdm86kjMm8VrHTj(lY9miXwwbkETmWFo7IhpW6Hdm86GtyYWFo7IhpW6H)OZc(Sg)J(Q4WhMadIficfacNMQktvtnnvbdgvf9vXH3H7x44fHcQI8AQIWPX)gf2M4)XTilRaqVwGL4adVoneMm8VrHTj(dTixjpanjHplyqb3c4pNDXJhy9WbgEDWbmz4pNDXJhy9WF0zbFwJ)CYxLyQICQIKNg)BuyBI)cSWEIble45ISbyCCliXbgEDLiMm8VrHTj(FMirpgyjqkQrm(Zzx84bwpCGHNWPXKH)C2fpEG1d)rNf8zn(J29nwIPxg7ja4(chqNdaKDSh50xflPQAQIqQcgmQcYQCcWXcTLsQICQIWPPkyWOQcxiiVK5WXYkW1vS3vevbdgvrcQcT7BSetFXB3byHaHdd4Kfe7pwOTusvAsv6OQYufA33yjMEzSNaG7lCaDoaq2XEi33dCmYPVkgeMatvWGrvAavXsjNi2x82Dawiq4WaozbXEHUu3JQGlvnHQq7(glX0dzYqcwiaK7j2FSqBPKQiNQ0nnvnHQqogvvUMQiKQMqvODFJLy6j6y3ZYkW46QnbICtKJ)yH2sjvrovPJq8VrHTj(lJ9eaCFHdOZbaYoghy4juhMm8NZU4XdSE4F2cm(3sN5DYsW1KK9aO96h(3OW2e)BPZ8ozj4AsYEa0E9dhy4jKqmz4FJcBt83vYalybj(Zzx84bwpCGHNWPWKH)C2fpEG1d)rNf8zn(dzvob4yH2sjvvMQ0vYsKQGbJQeXHFMlNGWHbeDSGbHvXNVrHnNPkyWOQ59zDXJ9o7BaM5Yj(3OW2e)J1f5awiG2(eACGHNqsgtg(Zzx84bwp8hDwWN14pA33yjMElNVAzWmxobHddi6ybdcRIp)XcTLsQQmvn10ufmyu18(SU4XEN9naZC5KQGbJQGSkNaCSqBPKQiNQiCA8VrHTj(x82DaGCpX4adpHLetg(Zzx84bwp8hDwWN14pA33yjMElNVAzWmxobHddi6ybdcRIp)XcTLsQQmvn10ufmyu18(SU4XEN9naZC5KQGbJQGSkNaCSqBPKQiNQ0vs8VrHTj(xWNKpTwwHdm8ecNWKH)nkSnX)Nv5esqP6oQe4mWFo7IhpW6Hdm8eQHWKH)C2fpEG1d)rNf8zn(J29nwIP3Y5RwgmZLtq4WaIowWGWQ4ZFSqBPKQktvtnnvbdgvnVpRlES3zFdWmxoPkyWOkiRYjahl0wkPkYPkDtJ)nkSnXFi74I3UdCGHNq4aMm8NZU4XdSE4p6SGpRXF0UVXsm9woF1YGzUCcchgq0XcgewfF(JfAlLuvzQAQPPkyWOQ59zDXJ9o7BaM5Yjvbdgvbzvob4yH2sjvrovr404FJcBt8VtelJRFau)E4adpHLiMm8NZU4XdSE4p6SGpRX)cxiiVm2taW9foGohai7y)yjM4FJcBt8VORaleiodPvIdCG)dgQDFbMmm86WKH)nkSnXFPiUpGtNdGmotlJ)C2fpEG1dhy4jetg(Zzx84bwp8FfH)soW)gf2M4)8(SU4X4)8(5Y4pA33yjMElNVAzWmxobHddi6ybdcRIp)XcTLsQQmvbzvob4yH2sjvbdgvbzvob4yH2sjvrovPJWPPQjufKv5eGJfAlLuvzQcT7BSetVKpoTqS)yH2sjvnHQq7(glX0l5Jtle7pwOTusvLPkDtJ)Z7dKTaJ)o7BaM5YjoWWpfMm8NZU4XdSE4p6SGpRXFsqvfUqqEjFCAHyVRiQcgmQQWfcYlJ9eaCFHdOZbaYo27kIQGlvnHQeXHFMlNGWHbeDSGbHvXNVrHnNPkyWOkiRYjahl0wkPkYRPk4004FJcBt8x0g2M4adpjJjd)5SlE8aRh(Jol4ZA8VWfcYl5Jtle7DfH)nkSnXFu)EGgf2MGNjd8)zYaKTaJ)s(40cX4adFjXKH)C2fpEG1d)rNf8zn(x4cb5jYTOnLGfcS3GpVRi8VrHTj(J63d0OW2e8mzG)ptgGSfy8Ni3I2ucwiWEd(WbgE4eMm8NZU4XdSE4p6SGpRX)WeyQICQIKPQjufYXOkYPQssvtOknGQeXHFMlNGWHbeDSGbHvXNVrHnNX)gf2M4pQFpqJcBtWZKb()mzaYwGX)veN8Hdm8Aimz4pNDXJhy9W)gf2M4pKjdWcbchgq0XcgewfF4p6SGpRXFKJ5f6zuLgPkKJrvLRPQPOQjufjOko5RsSpmbgelqONrvKtv6OkyWOko5RsSpmbgelqONrvKtvKmvnHQq7(glX0dzYqcwiaK7j2FSqBPKQiNQ05ljvbdgvH29nwIPNi3I2ucwiWEd(8hl0wkPkYPkcPk4I)iXOhdI(Q4qIHxhoWWdhWKH)C2fpEG1d)rNf8zn(JCmVqpJQ0ivHCmQQCnvPJQMqvKGQ4KVkX(WeyqSaHEgvrovPJQGbJQq7(glX0l5Jtle7pwOTusvKtvesvWGrvCYxLyFycmiwGqpJQiNQizQAcvH29nwIPhYKHeSqai3tS)yH2sjvrovPZxsQcgmQcT7BSetprUfTPeSqG9g85pwOTusvKtvesvWf)BuyBI)8mr8d40NaoWWxIyYWFo7IhpW6H)nkSnX)WQ4diQFc4p6SGpRXF0kuSazCMwMQMqvihZl0ZOknsvihJQkxtvesvtOksqvCYxLyFycmiwGqpJQiNQ0rvWGrvODFJLy6L8XPfI9hl0wkPkYPkcPkyWOko5RsSpmbgelqONrvKtvKmvnHQq7(glX0dzYqcwiaK7j2FSqBPKQiNQ05ljvbdgvH29nwIPNi3I2ucwiWEd(8hl0wkPkYPkcPk4I)iXOhdI(Q4qIHxhoWWRBAmz4pNDXJhy9WF0zbFwJ)Aavf9JZWl5Jtle75SlE8a)BuyBI)O(9ankSnbptg4)ZKbiBbg)rdGKHWbgED6WKH)C2fpEG1d)rNf8zn(h9JZWl5Jtle75SlE8a)BuyBI)O(9ankSnbptg4)ZKbiBbg)rdGKpoTqmoWWRJqmz4pNDXJhy9WF0zbFwJ)nkS5mGtwWyjvrovnf(3OW2e)r97bAuyBcEMmW)Njdq2cm(ldCGHx3uyYWFo7IhpW6H)OZc(Sg)BuyZzaNSGXsQQCnvnf(3OW2e)r97bAuyBcEMmW)Njdq2cm(3lJdCG)IogTcfDGjddVomz4FJcBt8x0g2M4pNDXJhy9WbgEcXKH)nkSnX)InIhpaqVwmpiAzfi2zwI)C2fpEG1dhy4Nctg(Zzx84bwp8FfH)soW)gf2M4)8(SU4X4)8(5Y4)04)8(azlW4)mxobBcCLmiol1YboWWtYyYWFo7IhpW6H)OZc(Sg)1aQk6hNHxYhNwi2Zzx84bvbdgvPbuv0podpKjdWcbchgq0XcgewfFEo7IhpW)gf2M4pYXafUNmWbg(sIjd)5SlE8aRh(Jol4ZA8xdOQOFCgEo5RYijwwb4NnJppNDXJh4FJcBt8h5yaI9Cgh4a)7LXKHHxhMm8VrHTj(t0XUNLvGX1vBce5Mih8NZU4XdSE4adpHyYWFo7IhpW6H)OZc(Sg)roMxONrvAKQqogvvUMQiKQMqvCYxLyFycmiwGqpJQktvesvWGrvihZl0ZOknsvihJQkxtvKm(3OW2e)5KVkJKyzfGF2m7Wbg(PWKH)C2fpEG1d)rNf8zn(JwHIfiJZ0Yu1eQIeuvHleKF0jIblea5yLQ5DfrvWGrvdUWfcYxSjpCLbO4yIExrufCX)gf2M4VuKLPLva01jd0AiT4adpjJjd)5SlE8aRh(Jol4ZA8Nt(Qe7dtGbXce6zuvzQINXi3GbHjWufmyufYX8c9mQsJufYXOkYRPkD4FJcBt8hYKHeSqai3tmoWWxsmz4pNDXJhy9W)gf2M4)zslRas3eO1qAXF0zbFwJ)KGQI(Xz4j6y3ZYkW46QnbICtKJNZU4XdQAcvH29nwIP)mPLvaPBc0AiT(H71HTjvvMQq7(glX0t0XUNLvGX1vBce5Mih)XcTLsQstQIKPk4svtOksqvODFJLy6HmzibleaY9e7pwOTusvLPQPOkyWOkKJrvLRPQssvWf)rIrpge9vXHedVoCGHhoHjd)5SlE8aRh(Jol4ZA8VWfcYFUshlRaLApyarlh(XsmX)gf2M4)5kDSScuQ9GbeTCGdm8Aimz4pNDXJhy9WF0zbFwJ)OvOybY4mTmvnHQibvrcQcT7BSetFXM8WvgGIJj6pwOTusvLPkcPQjufjOkKJrvLPQPOkyWOk0UVXsm9qMmKGfca5EI9hl0wkPQYufCIQGlvnHQibvHCmQQCnvvsQcgmQcT7BSetpKjdjyHaqUNy)XcTLsQQmvrivbxQcUufmyufN8vj2hMadIfi0ZOkYRPQPOk4I)nkSnXFPiltlRaORtgO1qAXbgE4aMm8NZU4XdSE4p6SGpRXFKJ5f6zuLgPkKJrvLRPkD4FJcBt8NNjIFaN(eWbg(setg(Zzx84bwp8VrHTj(dzYaSqGWHbeDSGbHvXh(Jol4ZA8h5yEHEgvPrQc5yuv5AQAk8hjg9yq0xfhsm86WbgEDtJjd)5SlE8aRh(Jol4ZA8h5yEHEgvPrQc5yuv5AQIq8VrHTj(JCmqH7jdCGHxNomz4pNDXJhy9WF0zbFwJ)fUqq(WHbSGi(2tcqTOgzXEEz0iTuvzQsxjsvtOko5RsSpmbgelqONrvLPkEgJCdgeMatvAKQ0rvtOk0UVXsm9qMmKGfca5EI9hl0wkPQYufpJrUbdctGX)gf2M4p6AK2NLvGsThm4zvorAzfoWWRJqmz4pNDXJhy9W)gf2M4Fyv8be1pb8hDwWN14pYX8c9mQsJufYXOQY1ufHu1eQIeuLgqvr)4m8owaqRqX65SlE8GQGbJQqRqXcKXzAzQcU4psm6XGOVkoKy41Hdm86Mctg(Zzx84bwp8hDwWN14pAfkwGmotlJ)nkSnXFKJbi2ZzCGHxhjJjd)5SlE8aRh(3OW2e)HEITSci5teNbqRH0I)OZc(Sg)lCHG8fRwGOBr(XsmXFld(oxrb(Rdhy41vsmz4pNDXJhy9W)gf2M4FXRrAx3aO1qAXF0zbFwJ)OvOybY4mTmvnHQibvv4cb5lwTar3I8UIOkyWOQOFCgEhlaOvOy9C2fpEqvtOkrhphuHgED(WQ4diQFcu1eQc5yuvnvrivnHQq7(glX0dzYqcwiaK7j2FSqBPKQiNQMIQGbJQqoMxONrvAKQqogvrEnvPJQMqvIoEoOcn868srwMwwbqxNmqRH0svtOko5RsSpmbgelqONrvKtvtrvWf)rIrpge9vXHedVoCGdCG)Z5tABIHNWPjCADeQBk8NyFPLvs8VuGKsja4lLGNKAjKQOkYCyQYeeTxqvq7rvLMi3I2ucwiWEd(knvDCjORD8GQKRatvTBScDWdQc50zfl9uc0WwYuLUsivbhT5C(cEqvLo6hNHhoxAQkwQQ0r)4m8WzpNDXJhLMQ6GQkfHJRHPksOBgC9uc0WwYufHLqQcoAZ58f8GQkD0podpCU0uvSuvPJ(Xz4HZEo7Ihpknv1bvvkchxdtvKq3m46PeOHTKPkDWPsivbhT5C(cEqvLo6hNHhoxAQkwQQ0r)4m8WzpNDXJhLMQiHUzW1tjGsqPajLsaWxkbpj1sivrvK5WuLjiAVGQG2JQkTKpoTqCPPQJlbDTJhuLCfyQQDJvOdEqviNoRyPNsGg2sMQ0ryjKQGJ2CoFbpOQsh9JZWdNlnvflvv6OFCgE4SNZU4XJstvDqvLIWX1Wufj0ndUEkbuckfiPuca(sj4jPwcPkQImhMQmbr7fuf0EuvPLrPPQJlbDTJhuLCfyQQDJvOdEqviNoRyPNsGg2sMQi5sivbhT5C(cEqvLo6hNHhoxAQkwQQ0r)4m8WzpNDXJhLMQ6GQkfHJRHPksOBgC9uc0WwYufCQesvWrBoNVGhuvPJ(Xz4HZLMQILQkD0podpC2Zzx84rPPksOBgC9uc0WwYuLosUesvWrBoNVGhuvPJ(Xz4HZLMQILQkD0podpC2Zzx84rPPksOBgC9ucOeukqsPea8LsWtsTesvufzomvzcI2lOkO9OQspyO29fLMQoUe01oEqvYvGPQ2nwHo4bvHC6SILEkbAylzQs30LqQcoAZ58f8GQkD0podpCU0uvSuvPJ(Xz4HZEo7Ihpknv1bvvkchxdtvKq3m46PeOHTKPkD6kHufC0MZ5l4bvv6OFCgE4CPPQyPQsh9JZWdN9C2fpEuAQQdQQueoUgMQiHUzW1tjGsqPajLsaWxkbpj1sivrvK5WuLjiAVGQG2JQkDVCPPQJlbDTJhuLCfyQQDJvOdEqviNoRyPNsGg2sMQkzjKQGJ2CoFbpOQsh9JZWdNlnvflvv6OFCgE4SNZU4XJstvKq3m46PeOHTKPkDewcPk4OnNZxWdQQ0r)4m8W5stvXsvLo6hNHho75SlE8O0ufj0ndUEkbAylzQsxjlHufC0MZ5l4bvv6OFCgE4CPPQyPQsh9JZWdN9C2fpEuAQIe6MbxpLakbLscI2l4bvvIuvJcBtQ6zYq6PeG)TB4Sh()nb4i8x0Tq2JX)szQQuWYbX(PLpQQe4n1sjOuMQGJbJyHc(OkDAisPkcNMWPPeqjOuMQkfNXi3GhuvbdThtvOvOOdQQGRSu6PkskielkKuvUPgD6taY9rvnkSnLu1MpXEkbnkSnLErhJwHIoQfTHTjLGgf2MsVOJrRqrhAwRFXgXJhaOxlMheTSce7mlPe0OW2u6fDmAfk6qZA9N3N1fpM0Sf46zUCc2e4kzqCwQLdsxr1soiDE)C56PPe0OW2u6fDmAfk6qZA9rogOW9KbPguTge9JZWl5Jtle75SlE8agmni6hNHhYKbyHaHddi6ybdcRIppNDXJhucAuyBk9IogTcfDOzT(ihdqSNZKAq1Aq0podpN8vzKelRa8ZMXNNZU4XdkbuckLPQsXzmYn4bvXZ5tmvfMatvHdtvnk2JQmjv1ZB71fp2tjOrHTPSwkI7d405aiJZ0YucAuyBk1Sw)59zDXJjnBbU2zFdWmxojDfvl5G059ZLRr7(glX0B58vldM5YjiCyarhlyqyv85pwOTuwgYQCcWXcTLsyWGSkNaCSqBPKCDeo9eiRYjahl0wklJ29nwIPxYhNwi2FSqBPCcA33yjMEjFCAHy)XcTLYY6MMsqJcBtPM16lAdBtsnOAsu4cb5L8XPfI9UIGbRWfcYlJ9eaCFHdOZbaYo27kcUteXHFMlNGWHbeDSGbHvXNVrHnNHbdYQCcWXcTLsYRHtttjOrHTPuZA9r97bAuyBcEMminBbUwYhNwiMudQUWfcYl5Jtle7DfrjOrHTPuZA9r97bAuyBcEMminBbUMi3I2ucwiWEd(i1GQlCHG8e5w0MsWcb2BWN3veLGgf2MsnR1h1VhOrHTj4zYG0Sf46veN8rQbvhMatojpb5yKxYjAGio8ZC5eeomGOJfmiSk(8nkS5mLGgf2MsnR1hYKbyHaHddi6ybdcRIpsrIrpge9vXHSwhPgunYX8c9mnICSY1tnHeCYxLyFycmiwGqpJCDWGXjFvI9HjWGybc9mYj5jODFJLy6HmzibleaY9e7pwOTusUoFjHbdT7BSetprUfTPeSqG9g85pwOTusoHWLsqJcBtPM16ZZeXpGtFcKAq1ihZl0Z0iYXkxRBcj4KVkX(WeyqSaHEg56GbdT7BSetVKpoTqS)yH2sj5ecdgN8vj2hMadIfi0ZiNKNG29nwIPhYKHeSqai3tS)yH2sj568Legm0UVXsm9e5w0MsWcb2BWN)yH2sj5ecxkbnkSnLAwRFyv8be1pbsrIrpge9vXHSwhPgunAfkwGmotlpb5yEHEMgrow5AcNqco5RsSpmbgelqONrUoyWq7(glX0l5Jtle7pwOTusoHWGXjFvI9HjWGybc9mYj5jODFJLy6HmzibleaY9e7pwOTusUoFjHbdT7BSetprUfTPeSqG9g85pwOTusoHWLsqJcBtPM16J63d0OW2e8mzqA2cCnAaKmePguTge9JZWl5JtletjOrHTPuZA9r97bAuyBcEMminBbUgnas(40cXKAq1r)4m8s(40cXucAuyBk1SwFu)EGgf2MGNjdsZwGRLbPguDJcBod4Kfmws(uucAuyBk1SwFu)EGgf2MGNjdsZwGR7Lj1GQBuyZzaNSGXYY1trjGsqJcBtPVxUMOJDplRaJRR2eiYnroucAuyBk99YAwRpN8vzKelRa8ZMzhPgunYX8c9mnICSY1eoHt(Qe7dtGbXce6zLjegmKJ5f6zAe5yLRjzkbnkSnL(EznR1xkYY0Yka66KbAnKwsnOA0kuSazCMwEcjkCHG8JormyHaihRunVRiyWgCHleKVytE4kdqXXe9UIGlLGgf2MsFVSM16dzYqcwiaK7jMudQMt(Qe7dtGbXce6zL5zmYnyqycmmyihZl0Z0iYXiVwhLGgf2MsFVSM16FM0YkG0nbAnKwsrIrpge9vXHSwhPgunjI(Xz4j6y3ZYkW46QnbICtKZe0UVXsm9NjTSciDtGwdP1pCVoSnlJ29nwIPNOJDplRaJRR2eiYnro(JfAlLAsYWDcjq7(glX0dzYqcwiaK7j2FSqBPS8uWGHCSY1LeUucAuyBk99YAwR)5kDSScuQ9GbeTCqQbvx4cb5pxPJLvGsThmGOLd)yjMucAuyBk99YAwRVuKLPLva01jd0AiTKAq1OvOybY4mT8esqc0UVXsm9fBYdxzakoMO)yH2szzcNqcKJvEkyWq7(glX0dzYqcwiaK7j2FSqBPSmCcUtibYXkxxsyWq7(glX0dzYqcwiaK7j2FSqBPSmHWfUWGXjFvI9HjWGybc9mYRNcUucAuyBk99YAwRppte)ao9jqQbvJCmVqptJihRCTokbnkSnL(EznR1hYKbyHaHddi6ybdcRIpsrIrpge9vXHSwhPgunYX8c9mnICSY1trjOrHTP03lRzT(ihdu4EYGudQg5yEHEMgrow5AcPe0OW2u67L1SwF01iTplRaLApyWZQCI0YksnO6cxiiF4WawqeF7jbOwuJSypVmAK2Y6kXjCYxLyFycmiwGqpRmpJrUbdctG1OUjODFJLy6HmzibleaY9e7pwOTuwMNXi3GbHjWucAuyBk99YAwRFyv8be1pbsrIrpge9vXHSwhPgunYX8c9mnICSY1eoHeAq0podVJfa0kuSWGHwHIfiJZ0YWLsqJcBtPVxwZA9rogGypNj1GQrRqXcKXzAzkbnkSnL(EznR1h6j2YkGKprCgaTgslPguDHleKVy1ceDlYpwIjPwg8DUIIADucAuyBk99YAwRFXRrAx3aO1qAjfjg9yq0xfhYADKAq1OvOybY4mT8esu4cb5lwTar3I8UIGbl6hNH3XcaAfk2jIoEoOcn868HvXhqu)eMGCSAcNG29nwIPhYKHeSqai3tS)yH2sj5tbdgYX8c9mnICmYR1nr0XZbvOHxNxkYY0Yka66KbAnK2jCYxLyFycmiwGqpJ8PGlLakbnkSnLE0aizOAlNVAzWmxobHddi6ybdcRIpsnOAnyEFwx8yVZ(gGzUCcdgKv5eGJfAlLKtyjPe0OW2u6rdGKH0Sw)(qDYGyVJZGudQg5yEHEMgrow5ADucAuyBk9ObqYqAwRFSUihWcbgChoKAq1fUqqEzSNaG7lCaDoaq2X(XsmNiId)mxobHddi6ybdcRIpFJcBoddgKv5eGJfAlLKRBAyWGSkNaCSqBPSSo4W0ucAuyBk9ObqYqAwRprUfTPeSqG9g8rQbvtIRTbGNZz47Xq6TSmjxsyWU2gaEoNHVhdP3veCNG29nwIP)mPLvaPBc0AiT(JfAlLKZZyKBWGWeykbnkSnLE0aizinR1hQ5NLmqgRGisnOA0kuSazCMwEcjU2gaEoNHVhdP3YY6MggSRTbGNZz47Xq6DfbxkbnkSnLE0aizinR1hQFpob7n4JudQ(ABa45Cg(EmKEllp10WGDTna8CodFpgsVRikbnkSnLE0aizinR1VytE4kdqXXej1GQV2gaEoNHVhdP3YYLCAyWU2gaEoNHVhdP3vePplzaAudNMMsqJcBtPhnasgsZA9LXEcaUVWb05aazhtQbvJ29nwIPxg7ja4(chqNdaKDSh50xflRjegmiRYjahl0wkjNWPHbJexBdapNZW3JH0FSqBPSSUscdMgG25C2z41k(SoNqcsCTna8CodFpgsVLLr7(glX0lJ9eaCFHdOZbaYo2d5(EGJro9vXGWeyyW0GRTbGNZz47Xq65zMmKWDcjq7(glX0B58vldM5YjiCyarhlyqyv85pwOTuwgT7BSetVm2taW9foGohai7ypK77bog50xfdctGHbBEFwx8yVZ(gGzUCcx4obT7BSetpKjdjyHaqUNy)XcTLsYRlXjihRCnHtq7(glX0t0XUNLvGX1vBce5Mih)XcTLsYR1riCPe0OW2u6rdGKH0SwFzSNaG7lCaDoaq2XKAq1ODoNDgETIpRZjKOWfcYtKBrBkbleyVbFExrWGrciRYjahl0wkjhT7BSetprUfTPeSqG9g85pwOTucdgA33yjMEIClAtjyHa7n4ZFSqBPSmA33yjMEzSNaG7lCaDoaq2XEi33dCmYPVkgeMad3jODFJLy6HmzibleaY9e7pwOTusEDjob5yLRjCcA33yjMEIo29SScmUUAtGi3e54pwOTusETocHlLGgf2MspAaKmKM16x82Dawiq4WaozbXKAq1ODFJLy6HmzibleaY9e7pwOTusoHWGbzvob4yH2sj56iKsqJcBtPhnasgsZA9RC7ByDcwiqts4BdhkbnkSnLE0aizinR1N4EVXC2sWXYn7eXucAuyBk9ObqYqAwRpAteNX1bpaqVwGj1GQ1GXgE0MioJRdEaGETadkCV0FSqBPCcjiHge9JZWt0XUNLvGX1vBce5MihpNDXJhWGH29nwIPNOJDplRaJRR2eiYnro(JfAlLWDcA33yjM(ZKwwbKUjqRH06pwOTuobT7BSetpKjdjyHaqUNy)XcTLYjfUqqEzSNaG7lCaDoaq2X(XsmHlmyqwLtaowOTusoCGsqJcBtPhnasgsZA9dhg4MfRBoaq7HykbnkSnLE0aizinR1xK7zqITScu8AzqjOrHTP0JgajdPzT(h3ISSca9AbwsQbvh9vXHpmbgelqekaeoD5PMggSOVko8oC)chViuqEnHttjOrHTP0JgajdPzT(qlYvYdqts4ZcguWTaLGgf2MspAaKmKM16lWc7jgSqGNlYgGXXTGKudQMt(QetojpnLGgf2MspAaKmKM16FMirpgyjqkQrmLGgf2MspAaKmKM16lJ9eaCFHdOZbaYoMudQgT7BSetVm2taW9foGohai7ypYPVkwwtimyqwLtaowOTusoHtddwHleKxYC4yzf46k27kcgmsG29nwIPV4T7aSqGWHbCYcI9hl0wk1uxz0UVXsm9Yypba3x4a6CaGSJ9qUVh4yKtFvmimbggmnGLsorSV4T7aSqGWHbCYcI9cDPUhCNG29nwIPhYKHeSqai3tS)yH2sj56MEcYXkxt4e0UVXsm9eDS7zzfyCD1MarUjYXFSqBPKCDesjOrHTP0JgajdPzT(UsgyblqA2cCDlDM3jlbxts2dG2RFucAuyBk9ObqYqAwRVRKbwWcskbnkSnLE0aizinR1pwxKdyHaA7tOj1GQHSkNaCSqBPSSUswIWGjId)mxobHddi6ybdcRIpFJcBodd28(SU4XEN9naZC5KsqJcBtPhnasgsZA9lE7oaqUNysnOA0UVXsm9woF1YGzUCcchgq0XcgewfF(JfAlLLNAAyWM3N1fp27SVbyMlNWGbzvob4yH2sj5eonLGgf2MspAaKmKM16xWNKpTwwrQbvJ29nwIP3Y5RwgmZLtq4WaIowWGWQ4ZFSqBPS8utdd28(SU4XEN9naZC5egmiRYjahl0wkjxxjPe0OW2u6rdGKH0Sw)Nv5esqP6oQe4mOe0OW2u6rdGKH0SwFi74I3UdsnOA0UVXsm9woF1YGzUCcchgq0XcgewfF(JfAlLLNAAyWM3N1fp27SVbyMlNWGbzvob4yH2sj56MMsqJcBtPhnasgsZA97eXY46ha1VhPgunA33yjMElNVAzWmxobHddi6ybdcRIp)XcTLYYtnnmyZ7Z6Ih7D23amZLtyWGSkNaCSqBPKCcNMsqJcBtPhnasgsZA9l6kWcbIZqALKAq1fUqqEzSNaG7lCaDoaq2X(XsmPeqjOrHTP0JgajFCAH4659zDXJjnBbUwYhNwigu4EYG0vuTKdsN3pxUgT7BSetVKpoTqS)yH2sj56Gbteh(zUCcchgq0XcgewfF(gf2CEcA33yjMEjFCAHy)XcTLYYtnnmyqwLtaowOTusoHttjOrHTP0JgajFCAHynR13Y5RwgmZLtq4WaIowWGWQ4JudQwdM3N1fp27SVbyMlNWGbzvob4yH2sj5ewskbnkSnLE0ai5JtleRzT(UsgyblqA2cCDlDM3jlbxts2dG2RFucAuyBk9ObqYhNwiwZA9DLmWcwqsjOrHTP0JgajFCAHynR1V4T7aa5EIj1GQN3N1fp2l5JtledkCpzqjOrHTP0JgajFCAHynR1VGpjFATSIudQEEFwx8yVKpoTqmOW9KbLGgf2MspAaK8XPfI1Sw)k3(gwNGfc0Ke(2WHudQgYQCcWXcTLYY6GdLegS59zDXJ9s(40cXGc3tgWGbzvob4yH2sj5tvskbnkSnLE0ai5JtleRzT(e37nMZwcowUzNiMudQEEFwx8yVKpoTqmOW9KbLGgf2MspAaK8XPfI1Sw)I3UdWcbchgWjliMudQEEFwx8yVKpoTqmOW9KbLGgf2MspAaK8XPfI1SwF0MioJRdEaGETatQbvtc0UVXsm9s(40cX(JfAlLWGH29nwIPhTjIZ46GhaOxlWEKtFvSSMq4ordgB4rBI4mUo4ba61cmOW9s)XcTLYjKaT7BSet)zslRas3eO1qA9hl0wkNG29nwIPhYKHeSqai3tS)yH2sjmyqwLtaowOTusoCaUucAuyBk9ObqYhNwiwZA9dhg4MfRBoaq7HykbnkSnLE0ai5JtleRzT(ICpdsSLvGIxldkbnkSnLE0ai5JtleRzT(h3ISSca9AbwsQbvh9vXHpmbgelqekaeoD5PMggSOVko8oC)chViuqEnHtddw0xfh(WeyqSGHXKtiLGgf2MspAaK8XPfI1SwFOf5k5bOjj8zbdk4wGsqJcBtPhnas(40cXAwRValSNyWcbEUiBagh3cssnOAo5Rsm5K80ucAuyBk9ObqYhNwiwZA9ptKOhdSeif1iMsqJcBtPhnas(40cXAwRFFOozqS3XzqQbvJCmVqptJihRCTokbnkSnLE0ai5JtleRzT(pRYjKGs1DujWzqjOrHTP0JgajFCAHynR1hYoU4T7GudQEEFwx8yVKpoTqmOW9KbLGgf2MspAaK8XPfI1Sw)orSmU(bq97rQbvpVpRlESxYhNwigu4EYGsqJcBtPhnas(40cXAwRFrxbwiqCgsRKudQEEFwx8yVKpoTqmOW9KbLGgf2MspAaK8XPfI1Sw)yDroGfcm4oCi1GQHSkNaCSqBPSSo4W0WGjId)mxobHddi6ybdcRIpFJcBoddgKv5eGJfAlLKRBAkbnkSnLE0ai5JtleRzT(X6ICaleqBFcnPgunKv5eGJfAlLLlXPHbteh(zUCcchgq0XcgewfF(gf2CggmiRYjahl0wkjx30ucAuyBk9ObqYhNwiwZA9jYTOnLGfcS3GpsnOA0UVXsm9NjTSciDtGwdP1FSqBPKCEgJCdgeMatjOrHTP0JgajFCAHynR1hQ5NLmqgRGikbnkSnLE0ai5JtleRzT(q97XjyVbFucAuyBk9ObqYhNwiwZA9l2KhUYauCmrkbnkSnLE0ai5JtleRzT(s(40cXKAq1ODFJLy6ptAzfq6MaTgsR)yH2sj5ecdgKv5eGJfAlLKRRKucAuyBk9ObqYhNwiwZA9l6kWcbIZqALucOe0OW2u6xrCYxnKjdWcbchgq0XcgewfFKIeJEmi67Q4qwRJudQg5yEHEMgrow56POe0OW2u6xrCYNM16ZZeXpGtFcKAq1r)4m8ihdu4EYWZzx84XeKJ5f6zAe5yLRNIsqJcBtPFfXjFAwRFyv8be1pbsrIrpge9vXHSwhPgunAfkwGmotlpb5yEHEMgrow5AcPe0OW2u6xrCYNM16JCmaXEotQbvJCmVqptJihRMqkbnkSnL(veN8PzT(8mr8d40NaLGgf2Ms)kIt(0Sw)WQ4diQFcKIeJEmi6RIdzTosnOAKJ5f6zAe5yLRjKsaLGgf2MsVKpoTqCnKjdjyHaqUNysnO6cxiiVKpoTqS)yH2sj56Oe0OW2u6L8XPfI1SwFxjdSGfinBbU2sj6CJU4XGsq3odxbWGNBiMsqJcBtPxYhNwiwZA9DLmWcwG0Sf46XX9aYogmNLs(rjOrHTP0l5JtleRzT(srwMwwbqxNmqRH0sQbvJwHIfiJZ0YtirJcBod4KfmwwUEkyWAuyZzaNSGXYY6MObODFJLy6ptAzfq6MaTgsR3veCPe0OW2u6L8XPfI1Sw)ZKwwbKUjqRH0sksm6XGOVkoK16i1GQrRqXcKXzAzkbnkSnLEjFCAHynR1hYKHeSqai3tmPguDJcBod4KfmwwUEkkbnkSnLEjFCAHynR1xkYY0Yka66KbAnKwsnOA0kuSazCMwEsHleKF0jIblea5yLQ5DfrjOrHTP0l5JtleRzT(fVgPDDdGwdPLuKy0JbrFvCiR1rQbvJwHIfiJZ0YtkCHG8e5w0MsWcb2BWhGirVROjODFJLy6ptAzfq6MaTgsR)yH2szzcPe0OW2u6L8XPfI1SwFitgsWcbGCpXKAzW35kkaguTgG29nwIP)mPLvaPBc0AiTExrucAuyBk9s(40cXAwRVuKLPLva01jd0AiTKAq1OvOybY4mT8Kbx4cb5l2KhUYauCmrVRikbnkSnLEjFCAHynR1hYKbyHaHddi6ybdcRIpsrIrpge9vXHSwhPgunYXiFkkbnkSnLEjFCAHynR1V41iTRBa0AiTKIeJEmi6RIdzTosnOA0kuSazCMwggmni6hNH3XcaAfkwkbnkSnLEjFCAHynR1xkYY0Yka66KbAnKwkbucAuyBk9YOMOJDplRaJRR2eiYnroKAq1xBdapNZW3JH0Bzz0UVXsm9eDS7zzfyCD1MarUjYXpCVoSnjPN2dhGb7ABa45Cg(EmKExrucAuyBk9YqZA95KVkJKyzfGF2m7i1GQroMxONPrKJvUMWjCYxLyFycmiwGqpR8uWGHCmVqptJihRCnjpHeCYxLyFycmiwGqpRmHWGPbIoEoOcn868HvXhqu)eGlLGgf2MsVm0SwFPiltlRaORtgO1qAj1GQrRqXcKXzA5jfUqq(rNigSqaKJvQM3v0esCTna8CodFpgsVLLlCHG8JormyHaihRun)XcTLsnsimyxBdapNZW3JH07kcUucAuyBk9YqZA9ptAzfq6MaTgslPiXOhdI(Q4qwRJudQgT7BSetVKpoTqS)yH2szzDWGPbr)4m8s(40cXucAuyBk9YqZA9HmzibleaY9etQbvtIRTbGNZz47Xq6TSmA33yjMEitgsWcbGCpX(H71HTjj90E4amyxBdapNZW3JH07kcUtibN8vj2hMadIfi0ZkZZyKBWGWeynQdgmKJ5f6zAe5yKxRdgScxiiVm2taW9foGohai7y)XcTLsY5zmYnyqycSM6GlmyqwLtaowOTusopJrUbdctG1uhLGgf2MsVm0SwF01iTplRaLApyWZQCI0YksnO6cxiiF4WawqeF7jbOwuJSypVmAK2Y6kXjCYxLyFycmiwGqpRmpJrUbdctG1OUjODFJLy6ptAzfq6MaTgsR)yH2szzEgJCdgeMaddwHleKpCyaliIV9KaulQrwSNxgnsBzDK8esG29nwIPxYhNwi2FSqBPK8soj6hNHxYhNwiggm0UVXsm9e5w0MsWcb2BWN)yH2sj5LCcANZzNHxR4Z6egmiRYjahl0wkjVKWLsqJcBtPxgAwR)5kDSScuQ9GbeTCqQbvx4cb5pxPJLvGsThmGOLd)yjMtAuyZzaNSGXYY6Oe0OW2u6LHM16dzYaSqGWHbeDSGbHvXhPiXOhdI(Q4qwRJudQg5yKpfLGgf2MsVm0SwFEMi(bC6tGudQg5yEHEMgrow5ADucAuyBk9YqZA9rogOW9KbPgunYX8c9mnICSY16M0OWMZaozbJL16MCTna8CodFpgsVLLjCAyWqoMxONPrKJvUMWjnkS5mGtwWyz5AcPe0OW2u6LHM16JCmaXEotjOrHTP0ldnR1pSk(aI6NaPiXOhdI(Q4qwRJusnOA0kuSazCMwEcYX8c9mnICSY1eoPWfcYlJ9eaCFHdOZbaYo2pwIjLGgf2MsVm0SwFPiltlRaORtgO1qAj1GQlCHG8ihdWjFvI9YOrAlp10ASKK0nkS5mGtwWy5KcxiiVm2taW9foGohai7y)yjMtibA33yjM(ZKwwbKUjqRH06pwOTuwMWjODFJLy6HmzibleaY9e7pwOTuwMqyWq7(glX0FM0YkG0nbAnKw)XcTLsYNAcA33yjMEitgsWcbGCpX(JfAlLLNAcYXkpfmyODFJLy6ptAzfq6MaTgsR)yH2sz5PMG29nwIPhYKHeSqai3tS)yH2sj5tnb5yLjzyWqoMxONPrKJrETUjCYxLyFycmiwGqpJCcHlmyfUqqEKJb4KVkXEz0iTL1n9eiRYjahl0wkjxdrjOrHTP0ldnR1V41iTRBa0AiTKIeJEmi6RIdzTosnOA0kuSazCMwEcjI(Xz4L8XPfING29nwIPxYhNwi2FSqBPK8PGbdT7BSet)zslRas3eO1qA9hl0wklRBcA33yjMEitgsWcbGCpX(JfAlLL1bdgA33yjM(ZKwwbKUjqRH06pwOTus(utq7(glX0dzYqcwiaK7j2FSqBPS8utqowzcHbdT7BSet)zslRas3eO1qA9hl0wklp1e0UVXsm9qMmKGfca5EI9hl0wkjFQjihR8uWGHCSYLegScxiiFXQfi6wK3veCPe0OW2u6LHM16hwfFar9tGuKy0JbrFvCiR1rkPgunAfkwGmotlpb5yEHEMgrow5AcPe0OW2u6LHM16d9eBzfqYNiodGwdPLuld(oxrrTokbLYufCSLmvP3chlQYGOQsG2sGOktsvO3kzQQZbvjEDPkNEotvesvihJQ6CqvIx3JQETmOQQ3w0pQIylPkYGJjPu1EuLbrvIxxQQpMQ6I1nOQyPkulIQ4KVkXuvNdQITWHpQs86Eu1RLbvvHgufXwsvKbhtQApQYGOkXRlv1htvpwkPQWPtQIqQc5yuvtSftvq3kqvOwKilROe0OW2u6LHM16x8AK21naAnKwsrIrpge9vXHSwhPgunAfkwGmotlpbT7BSetpKjdjyHaqUNy)XcTLsYNAcYXQjCIOJNdQqdVoFyv8be1pHjCYxLyFycmiwqjNMCDucAuyBk9YqZA9lEns76gaTgslPiXOhdI(Q4qwRJudQgTcflqgNPLNWjFvI9HjWGybc9mYjCcjqoMxONPrKJrEToyWeD8CqfA415dRIpGO(jaxkbucAuyBk9e5w0MsWcb2BWxnQFpqJcBtWZKbPzlW1ObqYqKAq1Aq0podVKpoTqmLGgf2MsprUfTPeSqG9g8PzT(O(9ankSnbptgKMTaxJgajFCAHysnO6OFCgEjFCAHykbnkSnLEIClAtjyHa7n4tZA95KVkJKyzfGF2m7i1GQroMxONPrKJvUMWjCYxLyFycmiwGqpR8uucAuyBk9e5w0MsWcb2BWNM16FM0YkG0nbAnKwsrIrpge9vXHSwhLGgf2MsprUfTPeSqG9g8PzT(srwMwwbqxNmqRH0sQbvJwHIfiJZ0YtkCHG8JormyHaihRunVRikbnkSnLEIClAtjyHa7n4tZA9HmzibleaY9etQbv3OWMZaozbJLLRjCsHleKNi3I2ucwiWEd(aej6pwOTusUokbnkSnLEIClAtjyHa7n4tZA9j6y3ZYkW46QnbICtKdPguDJcBod4KfmwwUMqkbnkSnLEIClAtjyHa7n4tZA9LISmTScGUozGwdPLudQgTcflqgNPLN0OWMZaozbJLLRNAsHleKNi3I2ucwiWEd(aej6DfrjOrHTP0tKBrBkbleyVbFAwRFXRrAx3aO1qAjfjg9yq0xfhYADKAq1OvOybY4mT8Kgf2CgWjlySK8AcPe0OW2u6jYTOnLGfcS3GpnR1NOJDplRaJRR2eiYnroucAuyBk9e5w0MsWcb2BWNM16dzYqcwiaK7jMuld(oxrbWGQlCHG8e5w0MsWcb2BWhGirVRisnO6cxiiVm2taW9foGohai7yVROjxBdapNZW3JH0Bzz0UVXsm9qMmKGfca5EI9d3RdBts6P9WjkbnkSnLEIClAtjyHa7n4tZA9LISmTScGUozGwdPLudQUWfcYJCmaN8vj2lJgPT8utRXsss3OWMZaozbJLucAuyBk9e5w0MsWcb2BWNM16dzYaSqGWHbeDSGbHvXhPiXOhdI(Q4qwRJudQg5yKpfLGgf2MsprUfTPeSqG9g8PzT(8mr8d40NaPgunYX8c9mnICSY16Oe0OW2u6jYTOnLGfcS3GpnR1h5yGc3tgKAq1ihZl0Z0iYXkxtcDA2OWMZaozbJLL1bxkbnkSnLEIClAtjyHa7n4tZA9dRIpGO(jqksm6XGOVkoK16i1GQjHge9JZW7ybaTcflmyOvOybY4mTmCNGCmVqptJihRCnHucAuyBk9e5w0MsWcb2BWNM16JCmaXEotjOrHTP0tKBrBkbleyVbFAwRFXRrAx3aO1qAjfjg9yq0xfhYADKAq1ihRC9uWGv4cb5jYTOnLGfcS3GparIExrucAuyBk9e5w0MsWcb2BWNM16d9eBzfqYNiodGwdPLuld(oxrrToCGdmga]] )

end