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
            id = 247255,
            duration = 5,
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
        the_emperors_capacitor = {
            id = 337291,
            duration = 3600,
            max_stack = 20,
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
        dance_of_chiji = {
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

        chi_energy = {
            id = 337571,
            duration = 45,
            max_stack = 20
        }
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
        if talent.spiritual_focus.enabled then
            chiSpent = chiSpent + amt           
            cooldown.storm_earth_and_fire.expires = max( 0, cooldown.storm_earth_and_fire.expires - floor( chiSpent / 2 ) )
            chiSpent = chiSpent % 2
        end

        if legendary.the_emperors_capacitor.enabled and amt > 0 and resource == "chi" then
            addStack( "the_emperors_capacitor", nil, 1 )
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


    spec:RegisterTotem( "xuen", 620832 )


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

            handler = function ()
            end,
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

            usable = function ()
                if health.current == health.max then return false, "requires health deficit" end
                return true
            end,
            handler = function ()
                gain( ( healing_sphere.count * stat.attack_power ) + stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )
                removeBuff( "gift_of_the_ox" )
                healing_sphere.count = 0
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
        },


        fortifying_brew = {
            id = 201318,
            cast = 0,
            cooldown = 90,
            gcd = "off",

            toggle = "defensives",
            pvptalent = "fortifying_brew",

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
            cooldown = 25,
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
                summonPet( "xuen", 45 )

                if legendary.invokers_delight.enabled then
                    if buff.invokers_delight.down then stat.haste = state.haste + 0.12 end
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
                gain( 2, "chi" )
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
                removeBuff( 'pressure_point' )

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
            recharge = function () return talent.celerity.eanbled and 15 or 20 end,
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

            spend = function () return buff.dance_of_chiji.up and 0 or weapons_of_order( 2 ) end,
            spendType = "chi",

            startsCombat = true,
            texture = 606543,

            start = function ()
                removeBuff( "dance_of_chiji" )
                removeBuff( "chi_energy" )

                if debuff.bonedust_brew.up or active_dot.bonedust_brew > 0 and active_enemies > 1 then
                    gain( 1, "chi" )
                end
            end,
        },


        storm_earth_and_fire = {
            id = function () return buff.storm_earth_and_fire.up and 221771 or 137639 end,
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

            copy = { 137639, 221771 },

            auras = {
                -- Conduit
                coordinated_offensive = {
                    id = 336602,
                    duration = 15,
                    max_stack = 1
                }
            }
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

            cycle = "mark_of_the_crane",

            buff = function () return prev_gcd[1].tiger_palm and buff.hit_combo.up and "hit_combo" or nil end,

            handler = function ()
                if talent.eye_of_the_tiger.enabled then
                    applyDebuff( "target", "eye_of_the_tiger" )
                    applyBuff( "eye_of_the_tiger" )
                end

                if pvptalent.alpha_tiger.enabled and debuff.recently_challenged.down then
                    if buff.alpha_tiger.down then stat.haste = stat.haste + 0.10 end
                    applyBuff( "alpha_tiger" )
                    applyDebuff( "target", "recently_challenged" )
                end

                if legendary.rushing_tiger_palm.enabled and debuff.recently_keefers_skyreach.down then
                    setDistance( 5 )
                    applyDebuff( "target", "keefers_skyreach" )
                    applyDebuff( "target", "recently_keefers_skyreach" )
                end

                gain( 2, "chi" )

                applyDebuff( "target", "mark_of_the_crane" )
            end,

            auras = {
                keefers_skyreach = {
                    id = 344021,
                    duration = 6,
                    max_stack = 1,
                },
                recently_keefers_skyreach = {
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
            cooldown = function () return legendary.fatal_touch.enabled and 120 or 180 end,
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
                return incoming_damage_3s >= health.max * 0.2, "incoming damage not sufficient (20% / 3sec) to use"
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
            cooldown = 45,
            gcd = "spell",

            startsCombat = false,
            texture = 237585,

            handler = function ()
            end,
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

        potion = "unbridled_fury",

        package = "Windwalker",

        strict = false
    } )

    spec:RegisterSetting( "allow_fsk", false, {
        name = "Use |T606545:0|t Flying Serpent Kick",
        desc = "If unchecked, |T606545:0|t Flying Serpent Kick will not be recommended (this is the same as disabling the ability via Windwalker > Abilities > Flying Serpent Kick > Disable).",
        type = "toggle",
        width = 1.5,
        get = function () return not Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled = not val
        end,
    } ) 
    
    spec:RegisterSetting( "optimize_reverse_harm", false, {
        name = "Optimize |T627486:0|t Reverse Harm",
        desc = "If checked, |T627486:0|t Reverse Harm's caption will show the recommended target's name.",
        type = "toggle",
        width = 1.5
    } ) 
    
    spec:RegisterPack( "Windwalker", 20201011, [[dSu1QbqisPQhHsP2eq5tOusvJIuHtrQOvHsjvEfPKzbuDlsPSlP8lsLgMurhJu1Yif9mPknnPk6AsfSnukQVrkvmoPk4COuW8qP6EkL9HcoikLKfsk8qsPstuQq4IOuI2ikf5JsfIQrIsHKtIsHuRuQQxIsH6MsfIStuKFIsj0qrPeSuukepfWurHUQuH0wLkeLVIsjL9c1FrmyihwYIf0JrAYGCzIndQpluJgvDAkRwQc9AbmBLCBuz3I(TkdxGwUQEojtNQRlKTJI67OKXlv68kvRxQqnFGSFfJ1JzedavUGzsZo1St9DQxFtFp0ZEQzhWa(EqbdeSObQybdKfNGbyRzjeRAfqEmqWAFDfeMrmG6IEQGbWaHr2YzJoXHyaOYfmtA2PMDQVt96B67HE2tn7jgqfuOyM0KnZgWa8geKK4qmaKOOya2EqS1SeIvTci)G6iDzGPpBpi2Iu)cLFq61d(G0Stn7ede8pyBjya2EqS1SeIvTci)G6iDzGPpBpi2Iu)cLFq61d(G0Stn7C6p9z7bXw2vOrUanOqb(Ezq0JlS8bfkXwQAdITIsLGUAq5LAJVEo4O1GkQBxQg0LR920VOUDPQf8f6XfwUwB6g8C7YPFrD7svl4l0JlSCT20nsjeZfoWZIt2QowXxFPiWx6KdMe8yj)0VOUDPQf8f6XfwUwB6s5ncRIzbCdEt79AjP3Ku(yRJTmMilRR8njRWLan9N(S9Gyl7k0ixGgKWS87dYnozqoVmOI63pitnOI5Ywv4sAtF2EqSLDfAKlqdsyw(9b5gNmiNxgur97hKPguXCzRkCjTPFrD7s1MkOupHVsiIYFlGm9z7b1rw9wfUKb58Lpiw2AnixwRbTFrdYGh0(fniw2AnOueOb53GyvMpi)geTu(Gy86i0f6guE(GyvPpi)geTu(GmFqLpOATguL7C3lt)I62LkT20L56TkCjGNfNSXFlis3ijb)cUPehCMRvKSrVBbDSYMLmFbes3ijjoVqyXBUqClw(2lCLLkgGTyEN8cxzPceiylM3jVWvwQyxVMDcgSfZ7Kx4klvmqVBbDSYMsEjnFV9cxzPcm6DlOJv2uYlP57Tx4klvmOVZPpBpOoQsguWZTlhKbpia5L089bzQbffe8bD)GcpNFqaSLSPbvj0Gy86igu9YGIcc(GUFqoVmiV(yXhelBTgeKjdIL58woi2CNdsj0lHut)I62LkT20n452LGBWB6imcgUPKxsZ3BrbbbkmcgUP875is9opPsicS9slkOoblO4TUrssCEHWI3CH4wS8TI6gZciqWwmVtEHRSuX(gBUZPpBpiTBTwdY5LbbiVKMVpOI62LdAzkFqg8GaKxsZ3hKPgen6Fj91(GIco9lQBxQ0AtxATwKI62LKLPCWZIt2uYlP57GBWBHrWWnL8sA(Elk40NThuhvjdInDoBnghKbpObTFrdQEzqCMszz8GkFqlPu(G6DquEd8bXwLqdA)IgKyoV8dQEzqv4f5dYVbrRGdss5J3bFq3piL8sA((Gm1GQWlY9Bq0JtguuqWh09dInDSPbzQbrpolJhuuWbvj0G2VObXYwRbrRGdss5J3hK6UC6xu3UuP1MU0ATif1Tljlt5GNfNSDbLuEWn4n34e27ayuEJ9oaM2hu8w3ijjoVqyXBUqClw(wrDJzz6xu3UuP1MUWMYjhmX5fclEZfIBXYdoDNUeIxFS4Qn9GBWBuERXvD1gL3yyRxW0HKYhV3CJti(r4QUSRheijLpEV5gNq8JWvDzVNGrVBbDSYgSPCf5GjWr)E7fUYsf76BDqNt)I62LkT20v6guwe(65a3G3O8wJR6QnkVXWMEW0HKYhV3CJti(r4QUSRhei6DlOJv2uYlP57Tx4klvSRjiqskF8EZnoH4hHR6YEpbJE3c6yLnyt5kYbtGJ(92lCLLk2136GoN(f1TlvATPRBXYtcwloWP70Lq86JfxTPhCdEJECHhr5VfqaJYBnUQR2O8gdBAcMoKu(49MBCcXpcx1LD9GarVBbDSYMsEjnFV9cxzPIDnbbss5J3BUXje)iCvx27jy07wqhRSbBkxroycC0V3EHRSuXU(wh050VOUDPsRnDP1ArkQBxswMYbplozJcrucm4g8M271ssVPKxsZ3BswHlbA6xu3UuP1MU0ATif1Tljlt5GNfNSrHik5L08DWn4nVws6nL8sA(EtYkCjqtF2EqA3ATgKZldcGXbvu3UCqlt5dYGhKZlVmO6LbP5GUFqlrPgKKcNjQPFrD7sLwB6sR1Iuu3UKSmLdEwCYMYb3G3kQBmlejfotuS370NThK2TwRb58YGyRo2Ybvu3UCqlt5dYGhKZlVmO6Lb17GUFqC3ldssHZe10VOUDPsRnDP1ArkQBxswMYbplozRobCdEROUXSqKu4mrXWwVt)PpBpi2kQBxQASvhB5Gm1GS0LesGge89dksjdIL58dInkH6gLWwbbr0UlPywguLqdIg9VK(AFqPiqQb53GcLbDbDJZ6ybA6xu3Uu1Qt2yXB)YYyc0xXxscgLu(PFrD7svRorRnDLu(yRJTmMilRR9GBWBuERXvD1gL3yyttWKu(49MBCcXpcx1LbnbbIYBnUQR2O8gdB9C6xu3Uu1Qt0Atxyt5kYbtGJ(DWn4njLpEV5gNq8JWvDzq6k0ixiUXjt)I62LQwDIwB6(MYYyIkkjbmAaWP70Lq86JfxTPhCdEthETK0BS4TFzzmb6R4ljbJskFtYkCjqGrVBbDSY2BklJjQOKeWObAqrF52LmqVBbDSYglE7xwgtG(k(ssWOKY3EHRSuPvp1jy6GE3c6yLnyt5kYbtGJ(92lCLLkg6feikVXWwh050VOUDPQvNO1MUFKI3YyspwqcHLLqGBWBHrWWTpsXBzmPhliHWYsOg0XkN(f1TlvT6eT20vf0Y0Yyc9RuibmAaWn4n6XfEeL)wabmDOdDq5ng6fei6DlOJv2GnLRihmbo63BVWvwQyGnRtW0bL3yyRdGarVBbDSYgSPCf5GjWr)E7fUYsfdAQtDccKKYhV3CJti(r4QUSV1liqHrWWnOkPc5GjuERhTwuqDo9lQBxQA1jATPR0nOSi81ZbUbVr5Tgx1vBuEJHn9t)I62LQwDIwB6s5nsy0RCWn4nkV14QUAJYBmS170VOUDPQvNO1MUWMYjhmX5fclEZfIBXYdoDNUeIxFS4Qn9GBWBuERXvD1gL3yyR3PFrD7svRorRnDDlwEsWAXboDNUeIxFS4Qn9GBWBuERXvD1gL3yyttW0H271ssVXBoHECHxtYkCjqGarpUWJO83ci6C6xu3Uu1Qt0AtxkVryvmlGBWB0Jl8ik)TaY0VOUDPQvNO1MUWRDlJjk5dkPtcy0aGBWBHrWWTWlaj4F0g0Xkb3sx(pkOVPF6xu3Uu1Qt0At3WvrdCrojGrdaoDNUeIxFS4Qn9GBWB0Jl8ik)Tacy6imcgUfEbib)J2IcccKo8AjP34nNqpUWRjzfUeiWc(cZKykutFZTy5jbRfhyuEJ9EQtDo9N(S9Ga875aFqSL178GpOkHgeBYEzqA37wqhRun9lQBxQAuiIsG3SK5lGq6gjjX5fclEZfIBXYdUbVP9mxVvHlPXFlis3ijbbc2I5DYlCLLk21Sdt)I62LQgfIOeyT20fUwljj3dj)0VOUDPQrHikbwRnDdVuGIuoj8fwt)I62LQgfIOeyT20LLubVuroyY9qYp9lQBxQAuiIsG1At34O6HSkjhmP6y5pNhCdEd2I5DYlCLLkg03dDccuqXBDJKK48cHfV5cXTy5Bf1nMLPFrD7svJcrucSwB6Y6(feZILKxuxwjva3G3GTyEN8cxzPIb2qNGafu8w3ijjoVqyXBUqClw(wrDJzbeiylM3jVWvwQyxFNtF2EqDuLmi2QNwPmigV)L0hKbpO9lAq1ldIZuklJhu5dAjLYhK(bPD5TPFrD7svJcrucSwB6wpTsH43)s6GBWBuERXvD1gL3yyt)0VOUDPQrHikbwRnD9lIYtoycKuop4g8wyemCt53ZrK6DEsLqey7Lg0XkblO4TUrssCEHWI3CH4wS8TI6gZciqWwmVtEHRSuXU(obbc2I5DYlCLLkg03dDo9lQBxQAuiIsG1AtxLFphrQ35jvcrGTxahCdEJE3c6yLnLFphrQ35jvcrGTxAu(6Jf1MMGabBX8o5fUYsf7A2jiq6GE3c6yLnlz(ciKUrssCEHWI3CH4wS8Tx4klvmqVBbDSYMYVNJi178KkHiW2ln4O1I8cLV(yH4gNaceZ1Bv4sA83cI0nssDcg9Uf0XkBWMYvKdMah97Tx4klvSVXgaJYBmS1ly07wqhRSXI3(LLXeOVIVKemkP8Tx4klvSVPxZPFrD7svJcrucSwB66xeLNCWKa1ZvGBWBWwmVtEHRSuXG(oWgabkO4TUrssCEHWI3CH4wS8TI6gZciqmxVvHlPXFlis3ijN(f1TlvnkerjWATPB46oiYbtCEHiPWTdUbVrVBbDSYMLmFbes3ijjoVqyXBUqClw(2lCLLkg6zhabI56TkCjn(Bbr6gjjy07wqhRSbBkxroycC0V3EHRSuXUMGa51hlEZnoH4hbYe21RjiqE9XI3CJti(rGmHb9D2jyE9XI3CJti(rGmHD967emDqVBbDSYgSPCf5GjWr)E7fUYsf79cce9Uf0XkBS4TFzzmb6R4ljbJskF7fUYsf7Daei6DlOJv2EtzzmrfLKagnq7fUYsf7DqNt)I62LQgfIOeyT20LEjvs)lxGiWRIta3G30EOZB0lPs6F5cebEvCcjm6Z2lCLLkW0HoO3TGowzJEjvs)lxGiWRItAVWvwQyFJE3c6yLnlz(ciKUrssCEHWI3CH4wS8Tx4klvAPheiMR3QWL04VfePBKK6emDO9ETK0BS4TFzzmb6R4ljbJskFtYkCjqGarVBbDSYglE7xwgtG(k(ssWOKY3EHRSuPtWO3TGowz7nLLXevuscy0aTx4klvGrVBbDSYgSPCf5GjWr)E7fUYsfyHrWWnLFphrQ35jvcrGTxAqhReeiOZB(fr5jhmbskNV9cxzPsNGa51hlEZnoH4hbYe27HPFrD7svJcrucSwB66xeLNCWKa1ZvGBPlpZ1AJn0j4bPoHxQLZV1zRdtF2EqDuLminw3bni2u0VpidEqmEru(bDWdQJqkNNTE1GO3TGow5Gm1GIFPC5hKZx5G6TZbPdN3udYs6kcsudIfVTKbX41rmitniA0)s6R9bvu3yw0j4d6(bDWWdIE3c6yLdIfVKdA)Igu9YG4VfKLXd6s)geJxhb4d6(bXIxYb58YG86JfFqMAqv4f5dYVbbzY0VOUDPQrHikbwRnDdx3brGJ(DWn4n6DlOJv2SK5lGq6gjjX5fclEZfIBXY3EHRSuXqVDcceZ1Bv4sA83cI0nssqGGTyEN8cxzPIDn7C6xu3Uu1OqeLaR1MUHYRKpGLXGBWB07wqhRSzjZxaH0nssIZlew8Mle3ILV9cxzPIHE7eeiMR3QWL04VfePBKKGabBX8o5fUYsf767W0VOUDPQrHikbwRnDxwmVRi9yeumNK(0VOUDPQrHikbwRnDHTxcx3bbUbVrVBbDSYMLmFbes3ijjoVqyXBUqClw(2lCLLkg6TtqGyUERcxsJ)wqKUrscceSfZ7Kx4klvSRVZPFrD7svJcrucSwB6wjvu(xlcTwlWn4n6DlOJv2SK5lGq6gjjX5fclEZfIBXY3EHRSuXqVDcceZ1Bv4sA83cI0nssqGGTyEN8cxzPIDn7C6xu3Uu1OqeLaR1MUHvm5Gj(B0aQPFrD7svJcrucSwB6gPeI5ch4zXjBLIN5kff5Ro(Ec9(An9lQBxQAuiIsG1AtxNxirz4fLqe47PY0VOUDPQrHikbwRnDdg9g8ULXKWvP8PFrD7svJcrucSwB6(sf0Yyc8Q4e10VOUDPQrHikbwRnDHpAKsGivhlV5cjukUPFrD7svJcrucSwB6YjC3VtoyYkIAqeOxkof4g8MKYhVZEp7C6xu3Uu1OqeLaR1MUVfm4siwsublQm9lQBxQAuiIsG1At3WkMCWe)nAaf4g8wyemCt53ZrK6DEsLqey7Lg0XkN(tF2EqaYlP57ds7E3c6yLQPFrD7svJcruYlP57BmxVvHlb8S4KnL8sA(ojm6vo4xWnL4GZCTIKn6DlOJv2uYlP57Tx4klvSRheOGI36gjjX5fclEZfIBXY3kQBmlGrVBbDSYMsEjnFV9cxzPIHE7eeiylM3jVWvwQyxZoN(f1TlvnkerjVKMVR1MUwY8fqiDJKK48cHfV5cXTy5b3G30EMR3QWL04VfePBKKGabBX8o5fUYsf7A2HPFrD7svJcruYlP57ATPlCTwssUhs(PFrD7svJcruYlP57ATPB4LcuKYjHVWA6xu3Uu1OqeL8sA(UwB6YsQGxQihm5Ei5N(S9GyK3udAzPmiw2AnOqzqVWDmldYYbXgAD20C6xu3Uu1OqeL8sA(UwB6ghvpKvj5Gjvhl)58GBWBmxVvHlPPKxsZ3jHrVYN(f1TlvnkerjVKMVR1MUHR7GiWr)o4g8gZ1Bv4sAk5L08Dsy0R8PFrD7svJcruYlP57ATPBO8k5dyzm4g8gZ1Bv4sAk5L08Dsy0R8PpBpOoQsgeB1tRugeJ3)s6dYGh0(fnO6LbXzkLLXdQ8bTKs5ds)G0U820VOUDPQrHik5L08DT20TEALcXV)L0b3G3O8wJR6QnkVXWM(PFrD7svJcruYlP57ATP7YI5DfPhJGI5K0N(f1TlvnkerjVKMVR1MUW2lHR7Ga3G3yUERcxstjVKMVtcJELp9lQBxQAuiIsEjnFxRnDRKkk)RfHwRf4g8gZ1Bv4sAk5L08Dsy0R8PFrD7svJcruYlP57ATPByftoyI)gnGA6xu3Uu1OqeL8sA(UwB6gUUdICWeNxiskC7GBWBmxVvHlPPKxsZ3jHrVYN(f1TlvnkerjVKMVR1MUrkHyUWbEwCYwP4zUsrr(QJVNqVVwGBWBmxVvHlPPKxsZ3jHrVYN(f1TlvnkerjVKMVR1MUrkHyUWPa3G3yUERcxstjVKMVtcJELp9lQBxQAuiIsEjnFxRnDzD)cIzXsYlQlRKkGBWBHrWWnL8sA(Ed6yLGPd6DlOJv2uYlP57Tx4klvmOVdGarVBbDSYMsEjnFV9cxzPIDn1jiqE9XI3CJti(rGmHDn7C6xu3Uu1OqeL8sA(UwB6sVKkP)Llqe4vXjGBWBHrWWnL8sA(Ed6yLGPd6DlOJv2uYlP57Tx4klvGarVBbDSYg9sQK(xUarGxfN0O81hlQnn1jyAp05n6Luj9VCbIaVkoHeg9z7fUYsfy6GE3c6yLT3uwgturjjGrd0EHRSubg9Uf0XkBWMYvKdMah97Tx4klvGa51hlEZnoH4hbYe27bDo9lQBxQAuiIsEjnFxRnD9lIYtoycKuop4g8gSfZ7Kx4klvmOVh6eeOGI36gjjX5fclEZfIBXY3kQBmlGabBX8o5fUYsf767C6xu3Uu1OqeL8sA(UwB66xeLNCWKa1ZvGBWBWwmVtEHRSuXaBOtqGckERBKKeNxiS4nxiUflFROUXSaceSfZ7Kx4klvSRVZPFrD7svJcruYlP57ATPRsEjnFF6xu3Uu1OqeL8sA(UwB668cjkdVOeIaFpva3G3cJGHBk5L089g0XkN(f1TlvnkerjVKMVR1MUbJEdE3Yys4Quo4g8wyemCtjVKMV3Gow50VOUDPQrHik5L08DT209LkOLXe4vXjkWn4TWiy4MsEjnFVbDSYPFrD7svJcruYlP57ATPl8rJuceP6y5nxiHsXbUbVfgbd3uYlP57nOJvo9lQBxQAuiIsEjnFxRnD5eU73jhmzfrnic0lfNcCdElmcgUPKxsZ3BqhRemjLpEN9E250VOUDPQrHik5L08DT209TGbxcXsIkyrfWn4TWiy4MsEjnFVbDSYPFrD7svJcruYlP57ATPByftoyI)gnGA6p9z7bXwmOKYp9lQBxQAxqjLFd2uo5GjoVqyXBUqClwEWP70Lq86JfxTPF6xu3Uu1UGskVwB6kDdklcF9CGBWBETK0BuEJeg9kVjzfUeOPFrD7sv7ckP8ATPRBXYtcwloWP70Lq86JfxTPhCdEJECHhr5VfqaJYBnUQR2O8gdBAo9lQBxQAxqjLxRnDLUbLfHVEoWn4nkV14QUAJYBB9cceL3ACvxTr5Tn9t)I62LQ2fus51Atx41ULXeL8bL0jbmAaWn4nVws6nEZj0Jl8AswHlbA6xu3Uu1UGskVwB6s)IgyzzmPhliHSSyEpTmgCdEt7vI7wgRA1ADSiWQaG51ssVXBoHECHxtYkCjqt)I62LQ2fus51Atx3ILNeSwCGt3PlH41hlUAtp4g8gL3ACvxTr5ng20C6p9lQBxQAk5L089nyt5kYbtGJ(DWn4TWiy4MsEjnFV9cxzPID9Gavu3ywiskCMOyq)0VOUDPQPKxsZ31AtxvqltlJj0VsHeWOba3G3Ohx4ru(BbeW0rrDJzHiPWzIIbnbbQOUXSqKu4mrXGEW0E6DlOJv2EtzzmrfLKagnqlkOoN(f1TlvnL8sA(UwB6(MYYyIkkjbmAaWP70Lq86JfxTPhCdEJECHhr5VfqM(f1TlvnL8sA(UwB6QcAzAzmH(vkKagna4g8g94cpIYFlGawyemCdQsQqoycL36rRffC6Z2dIrEtniw2AniAP8bXMo20GQeAqw6Y)rb9b58YGO8vMYAqg8GCEzqDKRD7igKPg0lf0(GQeAqQJtCElJheVfZl)GUCqoVmOGVDV57dAzkFq6GncaBSohKPguXCzHlz6xu3Uu1uYlP57ATPlSPCf5GjWr)o4w6Y)rbDIbVftHAVWvwQ26C6xu3Uu1uYlP57ATPlSPCYbtCEHWI3CH4wS8Gt3PlH41hlUAtp4g8gL3yV3PFrD7svtjVKMVR1MUs3GYIWxph4g8gL3ACvxTr5ng0dMKYhV3CJti(r4QUSRF6Z2dQJQKbPXXgd(GmFqSS1AqxU2hu4lvGbXvkx(9bzWdInkZhK294cVbzQbXeBrghKxljDbA6xu3Uu1uYlP57ATPB4QObUiNeWObaNUtxcXRpwC1MEWn4n6XfEeL)wabeiT3RLKEJ3Cc94cVMKv4sGM(f1TlvnL8sA(UwB6QcAzAzmH(vkKagnW0F6Z2dcWY4LmiV(yXhuW3U389PFrD7svt5BS4TFzzmb6R4ljbJsk)0VOUDPQPCT20vs5JTo2YyISSU2dUbVr5Tgx1vBuEJHnnbts5J3BUXje)iCvxg6feikV14QUAJYBmS1tW0HKYhV3CJti(r4QUmOjiqAFWxyMetHA6BUflpjyT4050VOUDPQPCT20vf0Y0Yyc9RuibmAaWn4n6XfEeL)wabSWiy4guLuHCWekV1Jwlk40NThuhvjdIncaB8GUCqE9XIRgelZ5ViFqDKQpWGo4b58YG0UFLYGGKWiyyWhKbpOGNszHlb8bvj0Gm4bbiVKMVpitnOYh0skLpinhKsOxcPguXQ2N(f1TlvnLR1MUVPSmMOIssaJgaC6oDjeV(yXvB6b3G3O3TGowztjVKMV3EHRSuXGEqG0EVws6nL8sA(EtYkCjqt)I62LQMY1Atxyt5kYbtGJ(DWn4nDiP8X7n34eIFeUQldsxHg5cXnorB6bbIYBnUQR2O8g7B61jiqWwmVtEHRSuXU0vOrUqCJt0spiqHrWWnLFphrQ35jvcrGTxAVWvwQ0ME2LUcnYfIBCY0VOUDPQPCT209Ju8wgt6XcsiSSecCdElmcgU9rkElJj9ybjewwc1Gowjyf1nMfIKcNjkg0p9lQBxQAkxRnDLUbLfHVEoWn4nkV14QUAJYBmSPF6xu3Uu1uUwB6cBkNCWeNxiS4nxiUflp40D6siE9XIR20dUbVr5n27D6Z2dQJQKbPD1yqg8G2VObvVmiU7Lb58voOohK2L3guXQ2he8FCdIR6oOkHgeFXSmi9dssHBh8bD)GQxge39YGC(khK(bPD5TbvSQ9bb)h3G4QUt)I62LQMY1AtxkVrcJELdUbVr5Tgx1vBuEJHn9t)I62LQMY1AtxkVryvmltF2EqDuLmigzlmidEq7x0GQxguph09dI7EzquEBqfRAFqW)XniUQ7GQeAqmEDedQsObbWwYMgu9YGcpNFq55dkk40VOUDPQPCT201Ty5jbRfh40D6siE9XIR20dUbVrpUWJO83ciGr5Tgx1vBuEJHnnblmcgUP875is9opPsicS9sd6yLt)I62LQMY1AtxvqltlJj0VsHeWOba3G3cJGHBuEJiP8X7nLx0am0BNARdS1vu3ywiskCMOaJECHhr5Vfqath07wqhRS9MYYyIkkjbmAG2lCLLkg0em6DlOJv2GnLRihmbo63BVWvwQyqtqGO3TGowz7nLLXevuscy0aTx4klvS3ly07wqhRSbBkxroycC0V3EHRSuXqVGr5ng6fei6DlOJv2EtzzmrfLKagnq7fUYsfd9cg9Uf0XkBWMYvKdMah97Tx4klvS3lyuEJHEcceL3ACvxTr5n230dMKYhV3CJti(r4QUSRPobbkmcgUr5nIKYhV3uErdWG(obd2I5DYlCLLk21otF2EqDuLmino24bzWdk8C(bXMo20GQeAqSrayJhu9YGYZheDDkb8bD)GyJaWgpitni66uYGQeAqSPJnnitnO88brxNsguLqdA)IgeFXSmiU7Lb58voinheL3aFq3pi20XMgKPgeDDkzqSrayJhKPguE(GORtjdQsObTFrdIVywge39YGC(khuVdIYBGpO7h0(fni(IzzqC3ldY5RCqDyquEd8bD)Gm4bTFrdkw8bvdk4F0PFrD7svt5ATPB4QObUiNeWObaNUtxcXRpwC1MEWn4n6XfEeL)wabmD41ssVPKxsZ3BswHlbcm6DlOJv2uYlP57Tx4klvS3liq07wqhRS9MYYyIkkjbmAG2lCLLkg0dg9Uf0XkBWMYvKdMah97Tx4klvmOhei6DlOJv2EtzzmrfLKagnq7fUYsf79cg9Uf0XkBWMYvKdMah97Tx4klvm0lyuEJbnbbIE3c6yLT3uwgturjjGrd0EHRSuXqVGrVBbDSYgSPCf5GjWr)E7fUYsf79cgL3yOxqGO8gdDaeOWiy4w4fGe8pAlkOoN(f1TlvnLR1MUUflpjyT4aNUtxcXRpwC1MEWn4n6XfEeL)wabmkV14QUAJYBmSP50NThuhvjdInbWgpOkHgKLU8FuqFqMpiL)LfZ7dQyv7t)I62LQMY1Atx41ULXeL8bL0jbmAaWT0L)Jc6B6N(S9G6OkzqACSXdYGheB6ytdYudIUoLmOkHg0(fni(IzzqAoikVnOkHg0(f9dAvkFqXRlSwdIvPgeJSfaFq3pidEq7x0GQxgufEr(G8Bq0k4GKu(49bvj0GeZ5LFq7x0pOvP8bftHgeRsnigzlmO7hKbpO9lAq1ldAjk1GC(khKMdIYBdQyv7dc(pUbrRGbTmE6xu3Uu1uUwB6gUkAGlYjbmAaWP70Lq86JfxTPhCdEJECHhr5VfqaJE3c6yLnyt5kYbtGJ(92lCLLk27fmkVTPjybFHzsmfQPV5wS8KG1IdmjLpEV5gNq8J0Hozx)0VOUDPQPCT20nCv0axKtcy0aGt3PlH41hlUAtp4g8g94cpIYFlGaMKYhV3CJti(r4QUSRjy6GYBnUQR2O8g7B6bbk4lmtIPqn9n3ILNeSwC6edWS8k7smtA2PMDQVt96XaSQpTmwHbyJMl49UanOEyqf1Tlh0YuUQn9Xalt5kmJyakerjWygXmPhZigqYkCjqynWa03C5TcdO9dI56TkCjn(Bbr6gj5GabAqWwmVtEHRSuni2hKMDaduu3UedyjZxaH0nssSJzstmJyGI62Lya4ATKKCpK8yajRWLaH1a7yM6fZigOOUDjgi8sbks5KWxyHbKScxcewdSJzQNygXaf1TlXaSKk4LkYbtUhsEmGKv4sGWAGDmtDaZigqYkCjqynWa03C5TcdaBX8o5fUYs1Gyyq67HoheiqdkO4TUrssCEHWI3CH4wS8TI6gZcgOOUDjgioQEiRsYbtQow(Z5XoMj2mMrmGKv4sGWAGbOV5YBfga2I5DYlCLLQbXWGydDoiqGguqXBDJKK48cHfV5cXTy5Bf1nMLbbc0GGTyEN8cxzPAqSpi9DIbkQBxIbyD)cIzXsYlQlRKkyhZK2bZigqYkCjqynWa03C5Tcdq5Tgx1DqABquEBqmSni9yGI62LyG6Pvke)(xsh7yM6bmJyajRWLaH1adqFZL3kmqyemCt53ZrK6DEsLqey7Lg0XkheydkO4TUrssCEHWI3CH4wS8TI6gZYGabAqWwmVtEHRSuni2hK(oheiqdc2I5DYlCLLQbXWG03dDIbkQBxIb8lIYtoycKuop2XmXgWmIbKScxcewdma9nxERWa07wqhRSP875is9opPsicS9sJYxFSOg02G0CqGaniylM3jVWvwQge7dsZoheiqdshdIE3c6yLnlz(ciKUrssCEHWI3CH4wS8Tx4klvdIHbrVBbDSYMYVNJi178KkHiW2ln4O1I8cLV(yH4gNmiqGgeZ1Bv4sA83cI0nsYbPZbb2GO3TGowzd2uUICWe4OFV9cxzPAqSVni2WGaBquEBqmSnOEheydIE3c6yLnw82VSmMa9v8LKGrjLV9cxzPAqSVni9AIbkQBxIbu(9CePENNujeb2Eb7yM03jMrmGKv4sGWAGbOV5YBfga2I5DYlCLLQbXWG03b2WGabAqbfV1nssIZlew8Mle3ILVvu3ywgeiqdI56TkCjn(Bbr6gjjgOOUDjgWVikp5GjbQNRWoMj96XmIbKScxcewdma9nxERWa07wqhRSzjZxaH0nssIZlew8Mle3ILV9cxzPAqmmOE2Hbbc0GyUERcxsJ)wqKUrsoiWge9Uf0XkBWMYvKdMah97Tx4klvdI9bP5GabAqE9XI3CJti(rGmzqSpi9AoiqGgKxFS4n34eIFeitgeddsFNDoiWgKxFS4n34eIFeitge7dsV(oheydshdIE3c6yLnyt5kYbtGJ(92lCLLQbX(G6DqGani6DlOJv2yXB)YYyc0xXxscgLu(2lCLLQbX(G6WGabAq07wqhRS9MYYyIkkjbmAG2lCLLQbX(G6WG0jgOOUDjgiCDhe5GjoVqKu42XoMj9AIzedizfUeiSgya6BU8wHb0(bbDEJEjvs)lxGiWRItiHrF2EHRSuniWgKogKoge9Uf0XkB0lPs6F5cebEvCs7fUYs1GyFBq07wqhRSzjZxaH0nssIZlew8Mle3ILV9cxzPAqAni9dceObXC9wfUKg)TGiDJKCq6CqGniDmiTFqETK0BS4TFzzmb6R4ljbJskFtYkCjqdceObrVBbDSYglE7xwgtG(k(ssWOKY3EHRSuniDoiWge9Uf0XkBVPSmMOIssaJgO9cxzPAqGni6DlOJv2GnLRihmbo63BVWvwQgeydkmcgUP875is9opPsicS9sd6yLdceObbDEZVikp5Gjqs58Tx4klvdsNdceOb51hlEZnoH4hbYKbX(G6bmqrD7sma9sQK(xUarGxfNGDmt67fZigWsxEMRfgGn0jgii1j8sTCEmqNToGbkQBxIb8lIYtoysG65kmGKv4sGWAGDmt67jMrmGKv4sGWAGbOV5YBfgGE3c6yLnlz(ciKUrssCEHWI3CH4wS8Tx4klvdIHb1BNdceObXC9wfUKg)TGiDJKCqGaniylM3jVWvwQge7dsZoXaf1TlXaHR7GiWr)o2XmPVdygXaswHlbcRbgG(MlVvya6DlOJv2SK5lGq6gjjX5fclEZfIBXY3EHRSunigguVDoiqGgeZ1Bv4sA83cI0nsYbbc0GGTyEN8cxzPAqSpi9Daduu3UedekVs(awgJDmt6zZygXaf1TlXallM3vKEmckMtshdizfUeiSgyhZKETdMrmGKv4sGWAGbOV5YBfgGE3c6yLnlz(ciKUrssCEHWI3CH4wS8Tx4klvdIHb1BNdceObXC9wfUKg)TGiDJKCqGaniylM3jVWvwQge7dsFNyGI62Lyay7LW1DqyhZK(EaZigqYkCjqynWa03C5TcdqVBbDSYMLmFbes3ijjoVqyXBUqClw(2lCLLQbXWG6TZbbc0GyUERcxsJ)wqKUrsoiqGgeSfZ7Kx4klvdI9bPzNyGI62LyGkPIY)ArO1AHDmt6zdygXaf1TlXaHvm5Gj(B0akmGKv4sGWAGDmtA2jMrmGKv4sGWAGbYItWaLIN5kff5Ro(Ec9(AHbkQBxIbkfpZvkkYxD89e691c7yM0upMrmqrD7smGZlKOm8Isic89ubdizfUeiSgyhZKMAIzeduu3Uedem6n4DlJjHRs5yajRWLaH1a7yM0SxmJyGI62LyGxQGwgtGxfNOWaswHlbcRb2XmPzpXmIbkQBxIbGpAKsGivhlV5cjukomGKv4sGWAGDmtA2bmJyajRWLaH1adqFZL3kmGKYhVpi2hup7eduu3UedWjC3VtoyYkIAqeOxkof2XmPjBgZigOOUDjg4TGbxcXsIkyrfmGKv4sGWAGDmtAQDWmIbKScxcewdma9nxERWaHrWWnLFphrQ35jvcrGTxAqhReduu3UedewXKdM4VrdOWo2Xa1jygXmPhZigOOUDjgGfV9llJjqFfFjjyus5XaswHlbcRb2XmPjMrmGKv4sGWAGbOV5YBfgGYBnUQ7G02GO82GyyBqAoiWgKKYhV3CJti(r4QUdIHbP5GabAquERXvDhK2geL3gedBdQNyGI62LyajLp26ylJjYY6Ap2Xm1lMrmGKv4sGWAGbOV5YBfgqs5J3BUXje)iCv3bXWGKUcnYfIBCcgOOUDjga2uUICWe4OFh7yM6jMrmGKv4sGWAGbkQBxIbEtzzmrfLKagnagG(MlVvyaDmiVws6nw82VSmMa9v8LKGrjLVjzfUeObb2GO3TGowz7nLLXevuscy0anOOVC7YbXWGO3TGowzJfV9llJjqFfFjjyus5BVWvwQgKwdQNdsNdcSbPJbrVBbDSYgSPCf5GjWr)E7fUYs1Gyyq9oiqGgeL3gedBdQddsNya6oDjeV(yXvyM0JDmtDaZigqYkCjqynWa03C5Tcdegbd3(ifVLXKESGecllHAqhReduu3Ued8rkElJj9ybjewwcHDmtSzmJyajRWLaH1adqFZL3kma94cpIYFlGmiWgKogKogKogeL3geddQ3bbc0GO3TGowzd2uUICWe4OFV9cxzPAqmmi28G05GaBq6yquEBqmSnOomiqGge9Uf0XkBWMYvKdMah97Tx4klvdIHbP5G05G05GabAqskF8EZnoH4hHR6oi23guVdceObfgbd3GQKkKdMq5TE0ArbhKoXaf1TlXaQGwMwgtOFLcjGrdGDmtAhmJyajRWLaH1adqFZL3kmaL3ACv3bPTbr5TbXW2G0JbkQBxIbKUbLfHVEoSJzQhWmIbKScxcewdma9nxERWauERXvDhK2geL3gedBdQxmqrD7smaL3iHrVYXoMj2aMrmGKv4sGWAGbkQBxIbGnLtoyIZlew8Mle3ILhdqFZL3kmaL3ACv3bPTbr5TbXW2G6fdq3PlH41hlUcZKESJzsFNygXaswHlbcRbgOOUDjgWTy5jbRfhgG(MlVvyakV14QUdsBdIYBdIHTbP5GaBq6yqA)G8AjP34nNqpUWRjzfUeObbc0GOhx4ru(BbKbPtmaDNUeIxFS4kmt6XoMj96XmIbKScxcewdma9nxERWa0Jl8ik)TacgOOUDjgGYBewfZc2XmPxtmJyajRWLaH1aduu3UedaV2TmMOKpOKojGrdGbOV5YBfgimcgUfEbib)J2GowjgWsx(pkOJb0JDmt67fZigqYkCjqynWaf1TlXaHRIg4ICsaJgadqFZL3kma94cpIYFlGmiWgKoguyemCl8cqc(hTffCqGaniDmiVws6nEZj0Jl8AswHlbAqGnOGVWmjMc103ClwEsWAXniWgeL3ge7dQNdsNdsNya6oDjeV(yXvyM0JDSJbGe4kA5ygXmPhZigOOUDjgqfuQNWxjer5VfqWaswHlbcRb2XmPjMrmGKv4sGWAGbUGyaL4yGI62LyaMR3QWLGbyUwrcgGE3c6yLnlz(ciKUrssCEHWI3CH4wS8Tx4klvdIHbbBX8o5fUYs1GabAqWwmVtEHRSuni2hKEn7CqGniylM3jVWvwQgeddIE3c6yLnL8sA(E7fUYs1GaBq07wqhRSPKxsZ3BVWvwQgeddsFNyaMRNKfNGb4VfePBKKyhZuVygXaswHlbcRbgG(MlVvyaDmOWiy4MsEjnFVffCqGanOWiy4MYVNJi178KkHiW2lTOGdsNdcSbfu8w3ijjoVqyXBUqClw(wrDJzzqGaniylM3jVWvwQge7BdIn3jgOOUDjgi452LyhZupXmIbKScxcewdma9nxERWaHrWWnL8sA(ElkigOOUDjgGwRfPOUDjzzkhdSmLtYItWak5L08DSJzQdygXaswHlbcRbgG(MlVvya34KbX(G6WGaBquEBqSpOomiWgK2pOGI36gjjX5fclEZfIBXY3kQBmlyGI62LyaATwKI62LKLPCmWYuojlobdCbLuESJzInJzedizfUeiSgyGI62Lyayt5KdM48cHfV5cXTy5Xa03C5Tcdq5Tgx1DqABquEBqmSnOEheydshdss5J3BUXje)iCv3bX(G0piqGgKKYhV3CJti(r4QUdI9b1Zbb2GO3TGowzd2uUICWe4OFV9cxzPAqSpi9TomiDIbO70Lq86JfxHzsp2XmPDWmIbKScxcewdma9nxERWauERXvDhK2geL3gedBds)GaBq6yqskF8EZnoH4hHR6oi2hK(bbc0GO3TGowztjVKMV3EHRSuni2hKMdceObjP8X7n34eIFeUQ7GyFq9CqGni6DlOJv2GnLRihmbo63BVWvwQge7dsFRddsNyGI62LyaPBqzr4RNd7yM6bmJyajRWLaH1aduu3Ued4wS8KG1IddqFZL3kma94cpIYFlGmiWgeL3ACv3bPTbr5TbXW2G0CqGniDmijLpEV5gNq8JWvDhe7ds)GabAq07wqhRSPKxsZ3BVWvwQge7dsZbbc0GKu(49MBCcXpcx1DqSpOEoiWge9Uf0XkBWMYvKdMah97Tx4klvdI9bPV1HbPtmaDNUeIxFS4kmt6XoMj2aMrmGKv4sGWAGbOV5YBfgq7hKxlj9MsEjnFVjzfUeimqrD7smaTwlsrD7sYYuogyzkNKfNGbOqeLaJDmt67eZigqYkCjqynWa03C5Tcd41ssVPKxsZ3BswHlbcduu3UedqR1Iuu3UKSmLJbwMYjzXjyakerjVKMVJDmt61JzedizfUeiSgya6BU8wHbkQBmlejfotudI9b1lgOOUDjgGwRfPOUDjzzkhdSmLtYItWakh7yM0RjMrmGKv4sGWAGbOV5YBfgOOUXSqKu4mrnig2guVyGI62LyaATwKI62LKLPCmWYuojlobduNGDSJbc(c94clhZiMj9ygXaf1TlXabp3UedizfUeiSgyhZKMygXaswHlbcRbgilobduDSIV(srGV0jhmj4XsEmqrD7smq1Xk(6lfb(sNCWKGhl5XoMPEXmIbKScxcewdma9nxERWaA)G8AjP3Ku(yRJTmMilRR8njRWLaHbkQBxIbO8gHvXSGDSJbuYlP57ygXmPhZigqYkCjqynWa03C5Tcdegbd3uYlP57Tx4klvdI9bPFqGanOI6gZcrsHZe1Gyyq6Xaf1TlXaWMYvKdMah97yhZKMygXaswHlbcRbgG(MlVvya6XfEeL)wazqGniDmOI6gZcrsHZe1GyyqAoiqGgurDJzHiPWzIAqmmi9dcSbP9dIE3c6yLT3uwgturjjGrd0IcoiDIbkQBxIbubTmTmMq)kfsaJga7yM6fZigqYkCjqynWaf1TlXaVPSmMOIssaJgadqFZL3kma94cpIYFlGGbO70Lq86JfxHzsp2Xm1tmJyajRWLaH1adqFZL3kma94cpIYFlGmiWguyemCdQsQqoycL36rRffeduu3UedOcAzAzmH(vkKagna2Xm1bmJyalD5)OGoXGXaXuO2lCLLQToXaf1TlXaWMYvKdMah97yajRWLaH1a7yMyZygXaswHlbcRbgOOUDjga2uo5GjoVqyXBUqClwEma9nxERWauEBqSpOEXa0D6siE9XIRWmPh7yM0oygXaswHlbcRbgG(MlVvyakV14QUdsBdIYBdIHbPFqGnijLpEV5gNq8JWvDhe7dspgOOUDjgq6guwe(65WoMPEaZigqYkCjqynWaf1TlXaHRIg4ICsaJgadqFZL3kma94cpIYFlGmiqGgK2piVws6nEZj0Jl8AswHlbcdq3PlH41hlUcZKESJzInGzeduu3UedOcAzAzmH(vkKagnagqYkCjqynWo2XauiIsEjnFhZiMj9ygXaswHlbcRbg4cIbuIJbkQBxIbyUERcxcgG5Afjya6DlOJv2uYlP57Tx4klvdI9bPFqGanOGI36gjjX5fclEZfIBXY3kQBmldcSbrVBbDSYMsEjnFV9cxzPAqmmOE7CqGaniylM3jVWvwQge7dsZoXamxpjlobdOKxsZ3jHrVYXoMjnXmIbKScxcewdma9nxERWaA)GyUERcxsJ)wqKUrsoiqGgeSfZ7Kx4klvdI9bPzhWaf1TlXawY8fqiDJKe7yM6fZigOOUDjgaUwljj3djpgqYkCjqynWoMPEIzeduu3UedeEPafPCs4lSWaswHlbcRb2Xm1bmJyGI62Lyawsf8sf5Gj3djpgqYkCjqynWoMj2mMrmGKv4sGWAGbOV5YBfgG56TkCjnL8sA(ojm6vogOOUDjgioQEiRsYbtQow(Z5XoMjTdMrmGKv4sGWAGbOV5YBfgG56TkCjnL8sA(ojm6vogOOUDjgiCDhebo63XoMPEaZigqYkCjqynWa03C5TcdWC9wfUKMsEjnFNeg9khduu3UedekVs(awgJDmtSbmJyajRWLaH1adqFZL3kmaL3ACv3bPTbr5TbXW2G0JbkQBxIbQNwPq87FjDSJzsFNygXaf1TlXallM3vKEmckMtshdizfUeiSgyhZKE9ygXaswHlbcRbgG(MlVvyaMR3QWL0uYlP57KWOx5yGI62Lyay7LW1DqyhZKEnXmIbKScxcewdma9nxERWamxVvHlPPKxsZ3jHrVYXaf1TlXavsfL)1IqR1c7yM03lMrmqrD7smqyftoyI)gnGcdizfUeiSgyhZK(EIzedizfUeiSgya6BU8wHbyUERcxstjVKMVtcJELJbkQBxIbcx3broyIZlejfUDSJzsFhWmIbKScxcewdmqrD7smqP4zUsrr(QJVNqVVwya6BU8wHbyUERcxstjVKMVtcJELJbYItWaLIN5kff5Ro(Ec9(AHDmt6zZygXaswHlbcRbgG(MlVvyaMR3QWL0uYlP57KWOx5yGI62LyGiLqmx4uyhZKETdMrmGKv4sGWAGbOV5YBfgimcgUPKxsZ3BqhRCqGniDmi6DlOJv2uYlP57Tx4klvdIHbPVddceObrVBbDSYMsEjnFV9cxzPAqSpinhKoheiqdYRpw8MBCcXpcKjdI9bPzNyGI62Lyaw3VGywSK8I6YkPc2XmPVhWmIbKScxcewdma9nxERWaHrWWnL8sA(Ed6yLdcSbPJbrVBbDSYMsEjnFV9cxzPAqGani6DlOJv2OxsL0)Yfic8Q4KgLV(yrnOTbP5G05GaBqA)GGoVrVKkP)Llqe4vXjKWOpBVWvwQgeydshdIE3c6yLT3uwgturjjGrd0EHRSuniWge9Uf0XkBWMYvKdMah97Tx4klvdceOb51hlEZnoH4hbYKbX(G6HbPtmqrD7sma9sQK(xUarGxfNGDmt6zdygXaswHlbcRbgG(MlVvyaylM3jVWvwQgeddsFp05GabAqbfV1nssIZlew8Mle3ILVvu3ywgeiqdc2I5DYlCLLQbX(G03jgOOUDjgWVikp5Gjqs58yhZKMDIzedizfUeiSgya6BU8wHbGTyEN8cxzPAqmmi2qNdceObfu8w3ijjoVqyXBUqClw(wrDJzzqGaniylM3jVWvwQge7dsFNyGI62Lya)IO8KdMeOEUc7yM0upMrmqrD7smGsEjnFhdizfUeiSgyhZKMAIzedizfUeiSgya6BU8wHbcJGHBk5L089g0XkXaf1TlXaoVqIYWlkHiW3tfSJzsZEXmIbKScxcewdma9nxERWaHrWWnL8sA(Ed6yLyGI62LyGGrVbVBzmjCvkh7yM0SNygXaswHlbcRbgG(MlVvyGWiy4MsEjnFVbDSsmqrD7smWlvqlJjWRItuyhZKMDaZigqYkCjqynWa03C5Tcdegbd3uYlP57nOJvIbkQBxIbGpAKsGivhlV5cjukoSJzst2mMrmGKv4sGWAGbOV5YBfgimcgUPKxsZ3BqhRCqGnijLpEFqSpOE2jgOOUDjgGt4UFNCWKve1GiqVuCkSJzstTdMrmGKv4sGWAGbOV5YBfgimcgUPKxsZ3BqhReduu3Ued8wWGlHyjrfSOc2XmPzpGzeduu3UedewXKdM4VrdOWaswHlbcRb2Xogq5ygXmPhZigOOUDjgGfV9llJjqFfFjjyus5XaswHlbcRb2XmPjMrmGKv4sGWAGbOV5YBfgGYBnUQ7G02GO82GyyBqAoiWgKKYhV3CJti(r4QUdIHb17GabAquERXvDhK2geL3gedBdQNdcSbPJbjP8X7n34eIFeUQ7GyyqAoiqGgK2pOGVWmjMc103ClwEsWAXniDIbkQBxIbKu(yRJTmMilRR9yhZuVygXaswHlbcRbgG(MlVvya6XfEeL)wazqGnOWiy4guLuHCWekV1JwlkigOOUDjgqf0Y0Yyc9RuibmAaSJzQNygXaswHlbcRbgOOUDjg4nLLXevuscy0aya6BU8wHbO3TGowztjVKMV3EHRSuniggK(bbc0G0(b51ssVPKxsZ3BswHlbcdq3PlH41hlUcZKESJzQdygXaswHlbcRbgG(MlVvyaDmijLpEV5gNq8JWvDhedds6k0ixiUXjdsBds)GabAquERXvDhK2geL3ge7Bds)G05GabAqWwmVtEHRSuni2hK0vOrUqCJtgKwds)GabAqHrWWnLFphrQ35jvcrGTxAVWvwQgK2gK(bX(GKUcnYfIBCcgOOUDjga2uUICWe4OFh7yMyZygXaswHlbcRbgG(MlVvyGWiy42hP4TmM0JfKqyzjud6yLdcSbvu3ywiskCMOgeddspgOOUDjg4Ju8wgt6XcsiSSec7yM0oygXaswHlbcRbgG(MlVvyakV14QUdsBdIYBdIHTbPhduu3UediDdklcF9CyhZupGzedizfUeiSgyGI62Lyayt5KdM48cHfV5cXTy5Xa03C5Tcdq5TbX(G6fdq3PlH41hlUcZKESJzInGzedizfUeiSgya6BU8wHbO8wJR6oiTnikVnig2gKEmqrD7smaL3iHrVYXoMj9DIzeduu3Uedq5ncRIzbdizfUeiSgyhZKE9ygXaswHlbcRbgOOUDjgWTy5jbRfhgG(MlVvya6XfEeL)wazqGnikV14QUdsBdIYBdIHTbP5GaBqHrWWnLFphrQ35jvcrGTxAqhRedq3PlH41hlUcZKESJzsVMygXaswHlbcRbgG(MlVvyGWiy4gL3iskF8Et5fnWGyyq925G02G6WGyRBqf1nMfIKcNjQbb2GOhx4ru(BbKbb2G0XGO3TGowz7nLLXevuscy0aTx4klvdIHbP5GaBq07wqhRSbBkxroycC0V3EHRSuniggKMdceObrVBbDSY2BklJjQOKeWObAVWvwQge7dQ3bb2GO3TGowzd2uUICWe4OFV9cxzPAqmmOEheydIYBdIHb17GabAq07wqhRS9MYYyIkkjbmAG2lCLLQbXWG6DqGni6DlOJv2GnLRihmbo63BVWvwQge7dQ3bb2GO82Gyyq9CqGanikV14QUdsBdIYBdI9TbPFqGnijLpEV5gNq8JWvDhe7dsZbPZbbc0GcJGHBuEJiP8X7nLx0adIHbPVZbb2GGTyEN8cxzPAqSpiTdgOOUDjgqf0Y0Yyc9RuibmAaSJzsFVygXaswHlbcRbgOOUDjgiCv0axKtcy0aya6BU8wHbOhx4ru(BbKbb2G0XG8AjP3uYlP57njRWLaniWge9Uf0XkBk5L0892lCLLQbX(G6DqGani6DlOJv2EtzzmrfLKagnq7fUYs1Gyyq6heydIE3c6yLnyt5kYbtGJ(92lCLLQbXWG0piqGge9Uf0XkBVPSmMOIssaJgO9cxzPAqSpOEheydIE3c6yLnyt5kYbtGJ(92lCLLQbXWG6DqGnikVniggKMdceObrVBbDSY2BklJjQOKeWObAVWvwQgeddQ3bb2GO3TGowzd2uUICWe4OFV9cxzPAqSpOEheydIYBdIHb17GabAquEBqmmOomiqGguyemCl8cqc(hTffCq6edq3PlH41hlUcZKESJzsFpXmIbKScxcewdmqrD7smGBXYtcwloma9nxERWa0Jl8ik)TaYGaBquERXvDhK2geL3gedBdstmaDNUeIxFS4kmt6XoMj9DaZigWsx(pkOJb0JbkQBxIbGx7wgtuYhusNeWObWaswHlbcRb2XmPNnJzedizfUeiSgyGI62LyGWvrdCrojGrdGbOV5YBfgGECHhr5VfqgeydIE3c6yLnyt5kYbtGJ(92lCLLQbX(G6DqGnikVnOTbP5GaBqbFHzsmfQPV5wS8KG1IBqGnijLpEV5gNq8J0Hohe7dspgGUtxcXRpwCfMj9yhZKETdMrmGKv4sGWAGbkQBxIbcxfnWf5KagnagG(MlVvya6XfEeL)wazqGnijLpEV5gNq8JWvDhe7dsZbb2G0XGO8wJR6oiTnikVni23gK(bbc0Gc(cZKykutFZTy5jbRf3G0jgGUtxcXRpwCfMj9yh7yGlOKYJzeZKEmJyajRWLaH1aduu3UedaBkNCWeNxiS4nxiUflpgGUtxcXRpwCfMj9yhZKMygXaswHlbcRbgG(MlVvyaVws6nkVrcJEL3KScxcegOOUDjgq6guwe(65WoMPEXmIbKScxcewdmqrD7smGBXYtcwloma9nxERWa0Jl8ik)TaYGaBquERXvDhK2geL3gedBdstmaDNUeIxFS4kmt6XoMPEIzedizfUeiSgya6BU8wHbO8wJR6oiTnikVnOTb17GabAquERXvDhK2geL3g02G0JbkQBxIbKUbLfHVEoSJzQdygXaswHlbcRbgG(MlVvyaVws6nEZj0Jl8AswHlbcduu3UedaV2TmMOKpOKojGrdGDmtSzmJyajRWLaH1adqFZL3kmG2piL4ULXQwTwhlcSkWGaBqETK0B8MtOhx41KScxcegOOUDjgG(fnWYYyspwqczzX8EAzm2XmPDWmIbKScxcewdmqrD7smGBXYtcwloma9nxERWauERXvDhK2geL3gedBdstmaDNUeIxFS4kmt6Xo2XogOIC(7XaSfUlGTmSJDmg]] )

end