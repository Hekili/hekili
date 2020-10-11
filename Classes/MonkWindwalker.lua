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
    
    spec:RegisterPack( "Windwalker", 20201011, [[dSKcQbqisf1JqPuBcO8jPcv0Oiv4uKs1QKQOuVIuYSqb3Iuk7sk)IuPHjv0XivTmsHNjvPPHsrxtQGTjvH(gPI04KQGZjvrMhkv3tPSpGQdIsjzHKIEiPIyIOusDrukrBeLc9rPcvLrkvOcNuQIswPuvVuQIQBkvOs7ef5NsfQYqrPeAPsvu8uatff6QsfkBvQqv1xrPeSxO(lIbd6WswSGEmstgIltSzi9zHA0OQttz1OuWRfWSvYTrLDl63QmCbA5Q65KmDQUUq2okQVJsgVuPZRuTEPcz(az)kgRhZigaPCbZKgDQrN67uV(M(EqJEuVgyaFpOGbcw0avSGbYItWaSfSeHvTcipgiyTVUcbZigqDrpvWayGWiB59SsCigaPCbZKgDQrN67uV(M(EqJESZEadOckumtA0J9egG3qqKehIbqeffdW2dKTGLiSQva5hyh3ldm9z7b2XJ6xO8duVEggOgDQrNyGG)HAlbdW2dKTGLiSQva5hyh3ldm9z7bcibDHlu(bQrpYWa1Otn6C6p9z7bYw2vOrUGmWqb9EzG0JlS8bgkXwQAdKTIsLGUAG5LAJVEo0O1alQBxQg4LR920VOUDPQf8f6XfwUwB6g8C7YPFrD7svl4l0JlSCT20nsjeZfogYIt2QosXxFPiOx6KdLe8yj)0VOUDPQf8f6XfwUwB6s5ncRIzHbdDtN9AjP3Ku(yRJSmMilRR8njRWLGm9N(S9azl7k0ixqgOWS87d0nozGoVmWI63pqtnWI5Ywv4sAtF2EGSLDfAKliduyw(9b6gNmqNxgyr97hOPgyXCzRkCjTPFrD7s1MkOupHVseIYFlGm9z7b2XF9wfUKb68Lpqw2AnqxwRbUFrd0qh4(fnqw2AnWueKb63azvMpq)giTu(az8yR1f5gyE(azvPpq)giTu(anFGLpWATgyL7C3lt)I62LkT20L56TkCjmKfNSXFles3ijz4cUPeNbMRvKSrVBHCSYMLmFbes3ijjoVqyXBUqClw(2lCLLkWrTyEN8cxzPceiulM3jVWvwQyxVgDcgQfZ7Kx4klvGtVBHCSYMsEjnFV9cxzPcm6DlKJv2uYlP57Tx4klvGRVZPpBpWoMsgyWZTlhOHoqa5L089bAQbgfKHbE)adpNFGaSLSXbwjYaz8yRhy9YaJcYWaVFGoVmqV(yXhilBTgiIjdKL58woWESZbQe6LiQPFrD7sLwB6g8C7sgm0nDegHI2uYlP57TOGGafgHI2u(9CePENNujcb1EPffu7Gfu8w3ijjoVqyXBUqClw(wrDJzbeiulM3jVWvwQyFRh7C6Z2duNuR1aDEzGaYlP57dSOUD5axMYhOHoqa5L089bAQbsJ(xsFTpWOGt)I62LkT20LwRfPOUDjzzkNHS4KnL8sA(odg6wyekAtjVKMV3Ico9z7b2XuYazJNZwGXbAOdCG7x0aRxgiNPuwgpWYh4skLpWEhiL3yyGSvjYa3VObkMZl)aRxgyfEr(a9BG0k4aLu(4Dgg49dujVKMVpqtnWk8IC)gi94KbgfKHbE)azJhBCGMAG0JZY4bgfCGvImW9lAGSS1AG0k4aLu(49bQUlN(f1TlvATPlTwlsrD7sYYuodzXjBxqjLNbdDZnoH9oagL3yVdGPZbfV1nssIZlew8Mle3ILVvu3ywM(f1TlvATPlQPCYHsCEHWI3CH4wS8mq3PlH41hlUAtpdg6gL3ACvxTr5nW36fmDiP8X7n34eIFeUQl76bbss5J3BUXje)iCvx2ztWO3Tqowzd1uUICOe0OFV9cxzPID9ToO9PFrD7sLwB6kDdklcF9CmyOBuERXvD1gL3aFtpy6qs5J3BUXje)iCvx21dce9UfYXkBk5L0892lCLLk21aeijLpEV5gNq8JWvDzNnbJE3c5yLnut5kYHsqJ(92lCLLk2136G2N(f1TlvATPRBXYtcwlogO70Lq86JfxTPNbdDJECHhr5VfqaJYBnUQR2O8g4BAaMoKu(49MBCcXpcx1LD9GarVBHCSYMsEjnFV9cxzPIDnabss5J3BUXje)iCvx2ztWO3Tqowzd1uUICOe0OFV9cxzPID9ToO9PFrD7sLwB6sR1Iuu3UKSmLZqwCYgfHOeugm0nD2RLKEtjVKMV3KScxcY0VOUDPsRnDP1ArkQBxswMYzilozJIquYlP57myOBETK0Bk5L089MKv4sqM(S9a1j1AnqNxgiaJdSOUD5axMYhOHoqNxEzG1lduJbE)axIsnqjfotut)I62LkT20LwRfPOUDjzzkNHS4KnLZGHUvu3ywiskCMOyV3PpBpqDsTwd05LbYwDSLdSOUD5axMYhOHoqNxEzG1ldS3bE)a5UxgOKcNjQPFrD7sLwB6sR1Iuu3UKSmLZqwCYwDcdg6wrDJzHiPWzIc8TEN(tF2EGSvu3Uu1yRo2YbAQbAPljIGmq07hyKsgilZ5hyhhc1nkHTcbHOtwsXSmWkrgin6Fj91(atrqud0Vbgkd8c6gN1rcY0VOUDPQvNSXI3(LLXeKVIVKemkP8t)I62LQwDIwB6kP8Xwhzzmrwwx7zWq3O8wJR6QnkVb(MgGjP8X7n34eIFeUQl4AaceL3ACvxTr5nW3yZPFrD7svRorRnDrnLRihkbn63zWq3Ku(49MBCcXpcx1fCPRqJCH4gNm9lQBxQA1jATP7BklJjQOKeWObyGUtxcXRpwC1MEgm0nD41ssVXI3(LLXeKVIVKemkP8njRWLGag9UfYXkBVPSmMOIssaJgOHe9LBxco9UfYXkBS4TFzzmb5R4ljbJskF7fUYsLwSP2bth07wihRSHAkxroucA0V3EHRSubEVGar5nW36G2N(f1TlvT6eT209Ju8wgtydfIqyzjcdg6wyekA7Ju8wgtydfIqyzjsd5yLt)I62LQwDIwB6QcAzAzmH(vkKagnadg6g94cpIYFlGaMo0HoO8g49cce9UfYXkBOMYvKdLGg97Tx4klvG3JAhmDq5nW36aiq07wihRSHAkxroucA0V3EHRSubUgAx7GajP8X7n34eIFeUQl7B9ccuyekAdPsQqoucL3ydwlkO2N(f1TlvT6eT20v6guwe(65yWq3O8wJR6QnkVb(M(PFrD7svRorRnDP8gjm6vodg6gL3ACvxTr5nW36D6xu3Uu1Qt0Atxut5KdL48cHfV5cXTy5zGUtxcXRpwC1MEgm0nkV14QUAJYBGV170VOUDPQvNO1MUUflpjyT4yGUtxcXRpwC1MEgm0nkV14QUAJYBGVPby6qN9AjP34nNqpUWRjzfUeeqGOhx4ru(BbeTp9lQBxQA1jATPlL3iSkMfgm0n6XfEeL)waz6xu3Uu1Qt0Atx01ULXeL8bL0jbmAagm0TWiu0w4fGe8pAd5yLmyPl)hf030p9lQBxQA1jATPB4QObUiNeWObyGUtxcXRpwC1MEgm0n6XfEeL)wabmDegHI2cVaKG)rBrbbbshETK0B8MtOhx41KScxccybFHzsmfPPV5wS8KG1IdmkVXoBQDTp9N(S9ab875yyGSL178mmWkrgiB0EzG6K7wihRun9lQBxQAueIsq3SK5lGq6gjjX5fclEZfIBXYZGHUPZmxVvHlPXFles3ijbbc1I5DYlCLLk21Odt)I62LQgfHOeuT20fTwljj3Ji)0VOUDPQrrikbvRnDdVuqIuoj8fwt)I62LQgfHOeuT20LLubVurouY9iYp9lQBxQAueIsq1At34O6rSkjhkP6i5pNNbdDd1I5DYlCLLkW13dDccuqXBDJKK48cHfV5cXTy5Bf1nMLPFrD7svJIqucQwB6Y6(fcZILKxuxwjvyWq3qTyEN8cxzPc8EQtqGckERBKKeNxiS4nxiUflFROUXSaceQfZ7Kx4klvSRVZPpBpWoMsgiB1tRugiJ3)s6d0qh4(fnW6LbYzkLLXdS8bUKs5du)a1j820VOUDPQrrikbvRnDRNwPq87FjDgm0nkV14QUAJYBGVPF6xu3Uu1OieLGQ1MU(fr5jhkbrkNNbdDlmcfTP875is9opPsecQ9sd5yLGfu8w3ijjoVqyXBUqClw(wrDJzbeiulM3jVWvwQyxFNGaHAX8o5fUYsf467HoN(f1TlvnkcrjOATPRYVNJi178KkriO2lmWGHUrVBHCSYMYVNJi178KkriO2lnkF9XIAtdqGqTyEN8cxzPIDn6eeiDqVBHCSYMLmFbes3ijjoVqyXBUqClw(2lCLLkWP3Tqowzt53ZrK6DEsLieu7LgA0ArEHYxFSqCJtabI56TkCjn(BHq6gjP2bJE3c5yLnut5kYHsqJ(92lCLLk236jWO8g4B9cg9UfYXkBS4TFzzmb5R4ljbJskF7fUYsf7B61y6xu3Uu1OieLGQ1MU(fr5jhkjq9Cfdg6gQfZ7Kx4klvGRVd9eiqbfV1nssIZlew8Mle3ILVvu3ywabI56TkCjn(BHq6gj50VOUDPQrrikbvRnDdx3HqouIZlejfUDgm0n6DlKJv2SK5lGq6gjjX5fclEZfIBXY3EHRSuboB2bqGyUERcxsJ)wiKUrscg9UfYXkBOMYvKdLGg97Tx4klvSRbiqE9XI3CJti(rqmHD9AacKxFS4n34eIFeetaxFNDcMxFS4n34eIFeetyxV(obth07wihRSHAkxroucA0V3EHRSuXEVGarVBHCSYglE7xwgtq(k(ssWOKY3EHRSuXEhabIE3c5yLT3uwgturjjGrd0EHRSuXEh0(0VOUDPQrrikbvRnDPxsL0)Yfec6Q4egm0nDg58g9sQK(xUGqqxfNqcJ(S9cxzPcmDOd6DlKJv2OxsL0)Yfec6Q4K2lCLLk23O3TqowzZsMVacPBKKeNxiS4nxiUflF7fUYsLw6bbI56TkCjn(BHq6gjP2bth6Sxlj9glE7xwgtq(k(ssWOKY3KScxcciq07wihRSXI3(LLXeKVIVKemkP8Tx4klvAhm6DlKJv2EtzzmrfLKagnq7fUYsfy07wihRSHAkxroucA0V3EHRSubwyekAt53ZrK6DEsLieu7LgYXkbbc58MFruEYHsqKY5BVWvwQ0oiqE9XI3CJti(rqmH9Ey6xu3Uu1OieLGQ1MU(fr5jhkjq9Cfdw6YZCT26Pozii1j8sTC(ToBDy6Z2dSJPKbQ56oKbYgJ(9bAOdKXlIYpWdDGS1s58DCQgi9UfYXkhOPgy8lLl)aD(khyVDoqD48MAGwsxriIAGS4TLmqgp26bAQbsJ(xsFTpWI6gZI2zyG3pWdfDG07wihRCGS4LCG7x0aRxgi)TqSmEGx63az8yRzyG3pqw8soqNxgOxFS4d0udScViFG(nqetM(f1TlvnkcrjOATPB46oecA0VZGHUrVBHCSYMLmFbes3ijjoVqyXBUqClw(2lCLLkW7TtqGyUERcxsJ)wiKUrscceQfZ7Kx4klvSRrNt)I62LQgfHOeuT20nuEL8bSmMbdDJE3c5yLnlz(ciKUrssCEHWI3CH4wS8Tx4klvG3BNGaXC9wfUKg)TqiDJKeeiulM3jVWvwQyxFhM(f1TlvnkcrjOATP7YI5DfHneHeZjPp9lQBxQAueIsq1Atxu7LW1DimyOB07wihRSzjZxaH0nssIZlew8Mle3ILV9cxzPc8E7eeiMR3QWL04VfcPBKKGaHAX8o5fUYsf767C6xu3Uu1OieLGQ1MUvsfL)1IqR1IbdDJE3c5yLnlz(ciKUrssCEHWI3CH4wS8Tx4klvG3BNGaXC9wfUKg)TqiDJKeeiulM3jVWvwQyxJoN(f1TlvnkcrjOATPByftouI)gnGA6xu3Uu1OieLGQ1MUrkHyUWXqwCYwP4zUsrr(QJUNqVVwt)I62LQgfHOeuT2015fsugErjcb9EQm9lQBxQAueIsq1At3GrVHUBzmjCvkF6xu3Uu1OieLGQ1MUVubTmMGUkorn9lQBxQAueIsq1Atx0JgPees1rYBUqcLIB6xu3Uu1OieLGQ1MUCc397KdLSIOgcb5LItXGHUjP8X7SZMDo9lQBxQAueIsq1At33cgCjeljQGfvM(f1TlvnkcrjOATPByftouI)gnGIbdDlmcfTP875is9opPsecQ9sd5yLt)PpBpqa5L089bQtUBHCSs10VOUDPQrrik5L089nMR3QWLWqwCYMsEjnFNeg9kNHl4MsCgyUwrYg9UfYXkBk5L0892lCLLk21dcuqXBDJKK48cHfV5cXTy5Bf1nMfWO3TqowztjVKMV3EHRSubEVDcceQfZ7Kx4klvSRrNt)I62LQgfHOKxsZ31Atxlz(ciKUrssCEHWI3CH4wS8myOB6mZ1Bv4sA83cH0nssqGqTyEN8cxzPIDn6W0VOUDPQrrik5L08DT20fTwljj3Ji)0VOUDPQrrik5L08DT20n8sbjs5KWxyn9lQBxQAueIsEjnFxRnDzjvWlvKdLCpI8tF2EGmYBQbUSugilBTgyOmWx4oMLbA5a7PwNnnM(f1TlvnkcrjVKMVR1MUXr1Jyvsous1rYFopdg6gZ1Bv4sAk5L08Dsy0R8PFrD7svJIquYlP57ATPB46oecA0VZGHUXC9wfUKMsEjnFNeg9kF6xu3Uu1OieL8sA(UwB6gkVs(awgZGHUXC9wfUKMsEjnFNeg9kF6Z2dSJPKbYw90kLbY49VK(an0bUFrdSEzGCMszz8alFGlPu(a1pqDcVn9lQBxQAueIsEjnFxRnDRNwPq87FjDgm0nkV14QUAJYBGVPF6xu3Uu1OieL8sA(UwB6USyExrydriXCs6t)I62LQgfHOKxsZ31Atxu7LW1DimyOBmxVvHlPPKxsZ3jHrVYN(f1TlvnkcrjVKMVR1MUvsfL)1IqR1IbdDJ56TkCjnL8sA(ojm6v(0VOUDPQrrik5L08DT20nSIjhkXFJgqn9lQBxQAueIsEjnFxRnDdx3HqouIZlejfUDgm0nMR3QWL0uYlP57KWOx5t)I62LQgfHOKxsZ31At3iLqmx4yilozRu8mxPOiF1r3tO3xlgm0nMR3QWL0uYlP57KWOx5t)I62LQgfHOKxsZ31At3iLqmx4umyOBmxVvHlPPKxsZ3jHrVYN(f1TlvnkcrjVKMVR1MUSUFHWSyj5f1Lvsfgm0TWiu0MsEjnFVHCSsW0b9UfYXkBk5L0892lCLLkW13bqGO3TqowztjVKMV3EHRSuXUgAheiV(yXBUXje)iiMWUgDo9lQBxQAueIsEjnFxRnDPxsL0)Yfec6Q4egm0TWiu0MsEjnFVHCSsW0b9UfYXkBk5L0892lCLLkqGO3TqowzJEjvs)lxqiORItAu(6Jf1MgAhmDg58g9sQK(xUGqqxfNqcJ(S9cxzPcmDqVBHCSY2BklJjQOKeWObAVWvwQaJE3c5yLnut5kYHsqJ(92lCLLkqG86JfV5gNq8JGyc79G2N(f1TlvnkcrjVKMVR1MU(fr5jhkbrkNNbdDd1I5DYlCLLkW13dDccuqXBDJKK48cHfV5cXTy5Bf1nMfqGqTyEN8cxzPID9Do9lQBxQAueIsEjnFxRnD9lIYtousG65kgm0nulM3jVWvwQaVN6eeOGI36gjjX5fclEZfIBXY3kQBmlGaHAX8o5fUYsf767C6xu3Uu1OieL8sA(UwB6QKxsZ3N(f1TlvnkcrjVKMVR1MUoVqIYWlkriO3tfgm0TWiu0MsEjnFVHCSYPFrD7svJIquYlP57ATPBWO3q3TmMeUkLZGHUfgHI2uYlP57nKJvo9lQBxQAueIsEjnFxRnDFPcAzmbDvCIIbdDlmcfTPKxsZ3BihRC6xu3Uu1OieL8sA(UwB6IE0iLGqQosEZfsOuCmyOBHrOOnL8sA(Ed5yLt)I62LQgfHOKxsZ31AtxoH7(DYHswrudHG8sXPyWq3cJqrBk5L089gYXkbts5J3zNn7C6xu3Uu1OieL8sA(UwB6(wWGlHyjrfSOcdg6wyekAtjVKMV3qow50VOUDPQrrik5L08DT20nSIjhkXFJgqn9N(S9a74fus5N(f1TlvTlOKYVHAkNCOeNxiS4nxiUflpd0D6siE9XIR20p9lQBxQAxqjLxRnDLUbLfHVEogm0nVws6nkVrcJEL3KScxcY0VOUDPQDbLuET201Ty5jbRfhd0D6siE9XIR20ZGHUrpUWJO83ciGr5Tgx1vBuEd8nnM(f1TlvTlOKYR1MUs3GYIWxphdg6gL3ACvxTr5TTEbbIYBnUQR2O82M(PFrD7sv7ckP8ATPl6A3YyIs(Gs6Kagnadg6Mxlj9gV5e6XfEnjRWLGm9lQBxQAxqjLxRnDDlwEsWAXXaDNUeIxFS4Qn9myOBuERXvD1gL3aFtJP)0VOUDPQPKxsZ33qnLRihkbn63zWq3cJqrBk5L0892lCLLk21dcurDJzHiPWzIcC9t)I62LQMsEjnFxRnDvbTmTmMq)kfsaJgGbdDJECHhr5Vfqathf1nMfIKcNjkW1aeOI6gZcrsHZef46btNP3Tqowz7nLLXevuscy0aTOGAF6xu3Uu1uYlP57ATP7BklJjQOKeWObyGUtxcXRpwC1MEgm0n6XfEeL)waz6xu3Uu1uYlP57ATPRkOLPLXe6xPqcy0amyOB0Jl8ik)TacyHrOOnKkPc5qjuEJnyTOGtF2EGmYBQbYYwRbslLpq24XghyLid0sx(pkOpqNxgiLVYuwd0qhOZldSJpDcB9an1aFPq2hyLiduDCIZBz8a5TyE5h4Ld05Lbg8T7nFFGlt5duh9ma9CTpqtnWI5YcxY0VOUDPQPKxsZ31Atxut5kYHsqJ(DgS0L)Jc6edDlMI0EHRSuT150VOUDPQPKxsZ31Atxut5KdL48cHfV5cXTy5zGUtxcXRpwC1MEgm0nkVXEVt)I62LQMsEjnFxRnDLUbLfHVEogm0nkV14QUAJYBGRhmjLpEV5gNq8JWvDzx)0NThyhtjduZRNZWanFGSS1AGxU2hy4lvGbYvkx(9bAOdSJdZhOo54cVbAQbYuhpghOxljDbz6xu3Uu1uYlP57ATPB4QObUiNeWObyGUtxcXRpwC1MEgm0n6XfEeL)wabeiD2RLKEJ3Cc94cVMKv4sqM(f1TlvnL8sA(UwB6QcAzAzmH(vkKagnW0F6Z2deWY4LmqV(yXhyW3U389PFrD7svt5BS4TFzzmb5R4ljbJsk)0VOUDPQPCT20vs5JToYYyISSU2ZGHUr5Tgx1vBuEd8nnats5J3BUXje)iCvxW7feikV14QUAJYBGVXMGPdjLpEV5gNq8JWvDbxdqG05GVWmjMI003ClwEsWAXP9PFrD7svt5ATPRkOLPLXe6xPqcy0amyOB0Jl8ik)TacyHrOOnKkPc5qjuEJnyTOGtF2EGDmLmWEgGE(aVCGE9XIRgilZ5ViFGDCRpWap0b68Ya1jFLYarKWiuuggOHoWGNszHlHHbwjYan0bciVKMVpqtnWYh4skLpqngOsOxIOgyXQ2N(f1TlvnLR1MUVPSmMOIssaJgGb6oDjeV(yXvB6zWq3O3TqowztjVKMV3EHRSubUEqG0zVws6nL8sA(EtYkCjit)I62LQMY1Atxut5kYHsqJ(Dgm0nDiP8X7n34eIFeUQl4sxHg5cXnorB6bbIYBnUQR2O8g7B61oiqOwmVtEHRSuXU0vOrUqCJt0spiqHrOOnLFphrQ35jvIqqTxAVWvwQ0ME2LUcnYfIBCY0VOUDPQPCT209Ju8wgtydfIqyzjcdg6wyekA7Ju8wgtydfIqyzjsd5yLGvu3ywiskCMOax)0VOUDPQPCT20v6guwe(65yWq3O8wJR6QnkVb(M(PFrD7svt5ATPlQPCYHsCEHWI3CH4wS8mq3PlH41hlUAtpdg6gL3yV3PpBpWoMsgOorZbAOdC)Igy9Ya5UxgOZx5a7CG6eEBGfRAFGO)XnqUQ7aRezG8fZYa1pqjfUDgg49dSEzGC3ld05RCG6hOoH3gyXQ2hi6FCdKR6o9lQBxQAkxRnDP8gjm6vodg6gL3ACvxTr5nW30p9lQBxQAkxRnDP8gHvXSm9z7b2XuYazKT4an0bUFrdSEzGS5aVFGC3ldKYBdSyv7de9pUbYvDhyLidKXJTEGvImqa2s24aRxgy458dmpFGrbN(f1TlvnLR1MUUflpjyT4yGUtxcXRpwC1MEgm0n6XfEeL)wabmkV14QUAJYBGVPbyHrOOnLFphrQ35jvIqqTxAihRC6xu3Uu1uUwB6QcAzAzmH(vkKagnadg6wyekAJYBejLpEVP8Iga8E7uBDONDrDJzHiPWzIcm6XfEeL)wabmDqVBHCSY2BklJjQOKeWObAVWvwQaxdWO3Tqowzd1uUICOe0OFV9cxzPcCnabIE3c5yLT3uwgturjjGrd0EHRSuXEVGrVBHCSYgQPCf5qjOr)E7fUYsf49cgL3aVxqGO3Tqowz7nLLXevuscy0aTx4klvG3ly07wihRSHAkxroucA0V3EHRSuXEVGr5nWztqGO8wJR6QnkVX(MEWKu(49MBCcXpcx1LDn0oiqHrOOnkVrKu(49MYlAaW13jyOwmVtEHRSuXUoD6Z2dSJPKbQ51ZhOHoWWZ5hiB8yJdSsKb2Za0Zhy9YaZZhiDDkHHbE)a7za65d0udKUoLmWkrgiB8yJd0udmpFG01PKbwjYa3VObYxmldK7EzGoFLduJbs5ngg49dKnESXbAQbsxNsgypdqpFGMAG55dKUoLmWkrg4(fnq(IzzGC3ld05RCG9oqkVXWaVFG7x0a5lMLbYDVmqNVYb2Hbs5ngg49d0qh4(fnWyXhynWG)rN(f1TlvnLR1MUHRIg4ICsaJgGb6oDjeV(yXvB6zWq3Ohx4ru(BbeW0Hxlj9MsEjnFVjzfUeeWO3TqowztjVKMV3EHRSuXEVGarVBHCSY2BklJjQOKeWObAVWvwQaxpy07wihRSHAkxroucA0V3EHRSubUEqGO3Tqowz7nLLXevuscy0aTx4klvS3ly07wihRSHAkxroucA0V3EHRSubEVGr5nW1aei6DlKJv2EtzzmrfLKagnq7fUYsf49cg9UfYXkBOMYvKdLGg97Tx4klvS3lyuEd8EbbIYBG3bqGcJqrBHxasW)OTOGAF6xu3Uu1uUwB66wS8KG1IJb6oDjeV(yXvB6zWq3Ohx4ru(BbeWO8wJR6QnkVb(MgtF2EGDmLmq2iqpFGvImqlD5)OG(anFGk)llM3hyXQ2N(f1TlvnLR1MUORDlJjk5dkPtcy0amyPl)hf030p9z7b2XuYa1865d0qhiB8yJd0udKUoLmWkrg4(fnq(IzzGAmqkVnWkrg4(f9dCvkFGXRlSwdKvPgiJSfzyG3pqdDG7x0aRxgyfEr(a9BG0k4aLu(49bwjYafZ5LFG7x0pWvP8bgtrgiRsnqgzloW7hOHoW9lAG1ldCjk1aD(khOgdKYBdSyv7de9pUbsRGbTmE6xu3Uu1uUwB6gUkAGlYjbmAagO70Lq86JfxTPNbdDJECHhr5VfqaJE3c5yLnut5kYHsqJ(92lCLLk27fmkVTPbybFHzsmfPPV5wS8KG1IdmjLpEV5gNq8J0Hozx)0VOUDPQPCT20nCv0axKtcy0amq3PlH41hlUAtpdg6g94cpIYFlGaMKYhV3CJti(r4QUSRby6GYBnUQR2O8g7B6bbk4lmtIPin9n3ILNeSwCAhdWS8k7smtA0PgD2zpPrpIbyvFAzScd0ZIl49UGmWEyGf1Tlh4YuUQn9Xalt5kmJyakcrjOygXmPhZigqYkCjiynXa03C5TcdOZdK56TkCjn(BHq6gj5abbAGOwmVtEHRSunq2hOgDaduu3UedyjZxaH0nssSJzsdmJyGI62Lya0ATKKCpI8yajRWLGG1e7yM6fZigOOUDjgi8sbjs5KWxyHbKScxccwtSJzInXmIbkQBxIbyjvWlvKdLCpI8yajRWLGG1e7yM6aMrmGKv4sqWAIbOV5YBfga1I5DYlCLLQbc(a13dDoqqGgyqXBDJKK48cHfV5cXTy5Bf1nMfmqrD7smqCu9iwLKdLuDK8NZJDmt9iMrmGKv4sqWAIbOV5YBfga1I5DYlCLLQbc(a7PohiiqdmO4TUrssCEHWI3CH4wS8TI6gZYabbAGOwmVtEHRSunq2hO(oXaf1TlXaSUFHWSyj5f1LvsfSJzsNIzedizfUeeSMya6BU8wHbO8wJR6oqTnqkVnqW3gOEmqrD7smq90kfIF)lPJDmt9aMrmGKv4sqWAIbOV5YBfgimcfTP875is9opPsecQ9sd5yLdeSbgu8w3ijjoVqyXBUqClw(wrDJzzGGanqulM3jVWvwQgi7duFNdeeObIAX8o5fUYs1abFG67HoXaf1TlXa(fr5jhkbrkNh7yM6jmJyajRWLGG1edqFZL3kma9UfYXkBk)EoIuVZtQeHGAV0O81hlQbUnqngiiqde1I5DYlCLLQbY(a1OZbcc0a1XaP3TqowzZsMVacPBKKeNxiS4nxiUflF7fUYs1abFG07wihRSP875is9opPsecQ9sdnATiVq5RpwiUXjdeeObYC9wfUKg)TqiDJKCGAFGGnq6DlKJv2qnLRihkbn63BVWvwQgi7BdSNgiydKYBde8Tb27abBG07wihRSXI3(LLXeKVIVKemkP8Tx4klvdK9TbQxdmqrD7smGYVNJi178KkriO2lyhZK(oXmIbKScxccwtma9nxERWaOwmVtEHRSunqWhO(o0tdeeObgu8w3ijjoVqyXBUqClw(wrDJzzGGanqMR3QWL04VfcPBKKyGI62Lya)IO8KdLeOEUc7yM0RhZigqYkCjiynXa03C5TcdqVBHCSYMLmFbes3ijjoVqyXBUqClw(2lCLLQbc(azZomqqGgiZ1Bv4sA83cH0nsYbc2aP3Tqowzd1uUICOe0OFV9cxzPAGSpqngiiqd0Rpw8MBCcXpcIjdK9bQxJbcc0a96JfV5gNq8JGyYabFG67SZbc2a96JfV5gNq8JGyYazFG6135abBG6yG07wihRSHAkxroucA0V3EHRSunq2hyVdeeObsVBHCSYglE7xwgtq(k(ssWOKY3EHRSunq2hyhgiiqdKE3c5yLT3uwgturjjGrd0EHRSunq2hyhgO2Xaf1TlXaHR7qihkX5fIKc3o2XmPxdmJyajRWLGG1edqFZL3kmGopqKZB0lPs6F5ccbDvCcjm6Z2lCLLQbc2a1Xa1XaP3TqowzJEjvs)lxqiORItAVWvwQgi7BdKE3c5yLnlz(ciKUrssCEHWI3CH4wS8Tx4klvduRbQFGGanqMR3QWL04VfcPBKKdu7deSbQJbQZd0RLKEJfV9llJjiFfFjjyus5BswHlbzGGanq6DlKJv2yXB)YYycYxXxscgLu(2lCLLQbQ9bc2aP3Tqowz7nLLXevuscy0aTx4klvdeSbsVBHCSYgQPCf5qjOr)E7fUYs1abBGHrOOnLFphrQ35jvIqqTxAihRCGGanqKZB(fr5jhkbrkNV9cxzPAGAFGGanqV(yXBUXje)iiMmq2hypGbkQBxIbOxsL0)Yfec6Q4eSJzsFVygXaw6YZCTWa9uNyGGuNWl1Y5XaD26agOOUDjgWVikp5qjbQNRWaswHlbbRj2XmPNnXmIbKScxccwtma9nxERWa07wihRSzjZxaH0nssIZlew8Mle3ILV9cxzPAGGpWE7CGGanqMR3QWL04VfcPBKKdeeObIAX8o5fUYs1azFGA0jgOOUDjgiCDhcbn63XoMj9DaZigqYkCjiynXa03C5TcdqVBHCSYMLmFbes3ijjoVqyXBUqClw(2lCLLQbc(a7TZbcc0azUERcxsJ)wiKUrsoqqGgiQfZ7Kx4klvdK9bQVdyGI62LyGq5vYhWYySJzsFpIzeduu3UedSSyExrydriXCs6yajRWLGG1e7yM0RtXmIbKScxccwtma9nxERWa07wihRSzjZxaH0nssIZlew8Mle3ILV9cxzPAGGpWE7CGGanqMR3QWL04VfcPBKKdeeObIAX8o5fUYs1azFG67eduu3UedGAVeUUdb7yM03dygXaswHlbbRjgG(MlVvya6DlKJv2SK5lGq6gjjX5fclEZfIBXY3EHRSunqWhyVDoqqGgiZ1Bv4sA83cH0nsYbcc0arTyEN8cxzPAGSpqn6eduu3Uedujvu(xlcTwlSJzsFpHzeduu3UedewXKdL4VrdOWaswHlbbRj2XmPrNygXaswHlbbRjgilobdukEMRuuKV6O7j07RfgOOUDjgOu8mxPOiF1r3tO3xlSJzsd9ygXaf1TlXaoVqIYWlkriO3tfmGKv4sqWAIDmtAObMrmqrD7smqWO3q3TmMeUkLJbKScxccwtSJzsJEXmIbkQBxIbEPcAzmbDvCIcdizfUeeSMyhZKgSjMrmqrD7sma6rJuccP6i5nxiHsXHbKScxccwtSJzsJoGzedizfUeeSMya6BU8wHbKu(49bY(azZoXaf1TlXaCc397KdLSIOgcb5LItHDmtA0JygXaf1TlXaVfm4siwsublQGbKScxccwtSJzsdDkMrmGKv4sqWAIbOV5YBfgimcfTP875is9opPsecQ9sd5yLyGI62LyGWkMCOe)nAaf2XogOobZiMj9ygXaf1TlXaS4TFzzmb5R4ljbJskpgqYkCjiynXoMjnWmIbKScxccwtma9nxERWauERXvDhO2giL3gi4BduJbc2aLu(49MBCcXpcx1DGGpqngiiqdKYBnUQ7a12aP82abFBGSjgOOUDjgqs5JToYYyISSU2JDmt9IzedizfUeeSMya6BU8wHbKu(49MBCcXpcx1DGGpqPRqJCH4gNGbkQBxIbqnLRihkbn63XoMj2eZigqYkCjiynXaf1TlXaVPSmMOIssaJgadqFZL3kmGogOxlj9glE7xwgtq(k(ssWOKY3KScxcYabBG07wihRS9MYYyIkkjbmAGgs0xUD5abFG07wihRSXI3(LLXeKVIVKemkP8Tx4klvduRbYMdu7deSbQJbsVBHCSYgQPCf5qjOr)E7fUYs1abFG9oqqGgiL3gi4BdSddu7ya6oDjeV(yXvyM0JDmtDaZigqYkCjiynXa03C5TcdegHI2(ifVLXe2qHiewwI0qowjgOOUDjg4Ju8wgtydfIqyzjc2Xm1JygXaswHlbbRjgG(MlVvya6XfEeL)wazGGnqDmqDmqDmqkVnqWhyVdeeObsVBHCSYgQPCf5qjOr)E7fUYs1abFG94a1(abBG6yGuEBGGVnWomqqGgi9UfYXkBOMYvKdLGg97Tx4klvde8bQXa1(a1(abbAGskF8EZnoH4hHR6oq23gyVdeeObggHI2qQKkKdLq5n2G1IcoqTJbkQBxIbubTmTmMq)kfsaJga7yM0PygXaswHlbbRjgG(MlVvyakV14QUduBdKYBde8TbQhduu3UediDdklcF9CyhZupGzedizfUeeSMya6BU8wHbO8wJR6oqTnqkVnqW3gyVyGI62LyakVrcJELJDmt9eMrmGKv4sqWAIbkQBxIbqnLtouIZlew8Mle3ILhdqFZL3kmaL3ACv3bQTbs5Tbc(2a7fdq3PlH41hlUcZKESJzsFNygXaswHlbbRjgOOUDjgWTy5jbRfhgG(MlVvyakV14QUduBdKYBde8TbQXabBG6yG68a9AjP34nNqpUWRjzfUeKbcc0aPhx4ru(BbKbQDmaDNUeIxFS4kmt6XoMj96XmIbKScxccwtma9nxERWa0Jl8ik)TacgOOUDjgGYBewfZc2XmPxdmJyajRWLGG1eduu3UedGU2TmMOKpOKojGrdGbOV5YBfgimcfTfEbib)J2qowjgWsx(pkOJb0JDmt67fZigqYkCjiynXaf1TlXaHRIg4ICsaJgadqFZL3kma94cpIYFlGmqWgOogyyekAl8cqc(hTffCGGanqDmqVws6nEZj0Jl8AswHlbzGGnWGVWmjMI003ClwEsWAXnqWgiL3gi7dKnhO2hO2Xa0D6siE9XIRWmPh7yhdGiOv0YXmIzspMrmqrD7smGkOupHVseIYFlGGbKScxccwtSJzsdmJyajRWLGG1edCbXakXXaf1TlXamxVvHlbdWCTIema9UfYXkBwY8fqiDJKK48cHfV5cXTy5BVWvwQgi4de1I5DYlCLLQbcc0arTyEN8cxzPAGSpq9A05abBGOwmVtEHRSunqWhi9UfYXkBk5L0892lCLLQbc2aP3TqowztjVKMV3EHRSunqWhO(oXamxpjlobdWFles3ijXoMPEXmIbKScxccwtma9nxERWa6yGHrOOnL8sA(Elk4abbAGHrOOnLFphrQ35jvIqqTxArbhO2hiydmO4TUrssCEHWI3CH4wS8TI6gZYabbAGOwmVtEHRSunq23gyp2jgOOUDjgi452LyhZeBIzedizfUeeSMya6BU8wHbcJqrBk5L089wuqmqrD7smaTwlsrD7sYYuogyzkNKfNGbuYlP57yhZuhWmIbKScxccwtma9nxERWaUXjdK9b2Hbc2aP82azFGDyGGnqDEGbfV1nssIZlew8Mle3ILVvu3ywWaf1TlXa0ATif1Tljlt5yGLPCswCcg4ckP8yhZupIzedizfUeeSMyGI62Lyaut5KdL48cHfV5cXTy5Xa03C5Tcdq5Tgx1DGABGuEBGGVnWEhiyduhdus5J3BUXje)iCv3bY(a1pqqGgOKYhV3CJti(r4QUdK9bYMdeSbsVBHCSYgQPCf5qjOr)E7fUYs1azFG6BDyGAhdq3PlH41hlUcZKESJzsNIzedizfUeeSMya6BU8wHbO8wJR6oqTnqkVnqW3gO(bc2a1XaLu(49MBCcXpcx1DGSpq9deeObsVBHCSYMsEjnFV9cxzPAGSpqngiiqdus5J3BUXje)iCv3bY(azZbc2aP3Tqowzd1uUICOe0OFV9cxzPAGSpq9TomqTJbkQBxIbKUbLfHVEoSJzQhWmIbKScxccwtmqrD7smGBXYtcwloma9nxERWa0Jl8ik)TaYabBGuERXvDhO2giL3gi4BduJbc2a1XaLu(49MBCcXpcx1DGSpq9deeObsVBHCSYMsEjnFV9cxzPAGSpqngiiqdus5J3BUXje)iCv3bY(azZbc2aP3Tqowzd1uUICOe0OFV9cxzPAGSpq9TomqTJbO70Lq86JfxHzsp2Xm1tygXaswHlbbRjgG(MlVvyaDEGETK0Bk5L089MKv4sqWaf1TlXa0ATif1Tljlt5yGLPCswCcgGIquck2XmPVtmJyajRWLGG1edqFZL3kmGxlj9MsEjnFVjzfUeemqrD7smaTwlsrD7sYYuogyzkNKfNGbOieL8sA(o2XmPxpMrmGKv4sqWAIbOV5YBfgOOUXSqKu4mrnq2hyVyGI62LyaATwKI62LKLPCmWYuojlobdOCSJzsVgygXaswHlbbRjgG(MlVvyGI6gZcrsHZe1abFBG9IbkQBxIbO1ArkQBxswMYXalt5KS4emqDc2Xogi4l0JlSCmJyM0Jzeduu3Uede8C7smGKv4sqWAIDmtAGzedizfUeeSMyGS4emq1rk(6lfb9sNCOKGhl5Xaf1TlXavhP4RVue0lDYHscESKh7yM6fZigqYkCjiynXa03C5TcdOZd0RLKEts5JToYYyISSUY3KScxccgOOUDjgGYBewfZc2XogqjVKMVJzeZKEmJyajRWLGG1edqFZL3kmqyekAtjVKMV3EHRSunq2hO(bcc0alQBmlejfotude8bQhduu3UedGAkxroucA0VJDmtAGzedizfUeeSMya6BU8wHbOhx4ru(BbKbc2a1XalQBmlejfotude8bQXabbAGf1nMfIKcNjQbc(a1pqWgOopq6DlKJv2EtzzmrfLKagnqlk4a1ogOOUDjgqf0Y0Yyc9RuibmAaSJzQxmJyajRWLGG1eduu3Ued8MYYyIkkjbmAama9nxERWa0Jl8ik)TacgGUtxcXRpwCfMj9yhZeBIzedizfUeeSMya6BU8wHbOhx4ru(BbKbc2adJqrBivsfYHsO8gBWArbXaf1TlXaQGwMwgtOFLcjGrdGDmtDaZigWsx(pkOtmumqmfP9cxzPARtmqrD7smaQPCf5qjOr)ogqYkCjiynXoMPEeZigqYkCjiynXaf1TlXaOMYjhkX5fclEZfIBXYJbOV5YBfgGYBdK9b2lgGUtxcXRpwCfMj9yhZKofZigqYkCjiynXa03C5Tcdq5Tgx1DGABGuEBGGpq9deSbkP8X7n34eIFeUQ7azFG6Xaf1TlXas3GYIWxph2Xm1dygXaswHlbbRjgOOUDjgiCv0axKtcy0aya6BU8wHbOhx4ru(BbKbcc0a15b61ssVXBoHECHxtYkCjiya6oDjeV(yXvyM0JDmt9eMrmqrD7smGkOLPLXe6xPqcy0ayajRWLGG1e7yhdqrik5L08DmJyM0JzedizfUeeSMyGligqjogOOUDjgG56TkCjyaMRvKGbO3TqowztjVKMV3EHRSunq2hO(bcc0adkERBKKeNxiS4nxiUflFROUXSmqWgi9UfYXkBk5L0892lCLLQbc(a7TZbcc0arTyEN8cxzPAGSpqn6edWC9KS4emGsEjnFNeg9kh7yM0aZigqYkCjiynXa03C5TcdOZdK56TkCjn(BHq6gj5abbAGOwmVtEHRSunq2hOgDaduu3UedyjZxaH0nssSJzQxmJyGI62Lya0ATKKCpI8yajRWLGG1e7yMytmJyGI62LyGWlfKiLtcFHfgqYkCjiynXoMPoGzeduu3UedWsQGxQihk5Ee5XaswHlbbRj2Xm1JygXaswHlbbRjgG(MlVvyaMR3QWL0uYlP57KWOx5yGI62LyG4O6rSkjhkP6i5pNh7yM0PygXaswHlbbRjgG(MlVvyaMR3QWL0uYlP57KWOx5yGI62LyGW1Die0OFh7yM6bmJyajRWLGG1edqFZL3kmaZ1Bv4sAk5L08Dsy0RCmqrD7smqO8k5dyzm2Xm1tygXaswHlbbRjgG(MlVvyakV14QUduBdKYBde8TbQhduu3UedupTsH43)s6yhZK(oXmIbkQBxIbwwmVRiSHiKyojDmGKv4sqWAIDmt61JzedizfUeeSMya6BU8wHbyUERcxstjVKMVtcJELJbkQBxIbqTxcx3HGDmt61aZigqYkCjiynXa03C5TcdWC9wfUKMsEjnFNeg9khduu3Uedujvu(xlcTwlSJzsFVygXaf1TlXaHvm5qj(B0akmGKv4sqWAIDmt6ztmJyajRWLGG1edqFZL3kmaZ1Bv4sAk5L08Dsy0RCmqrD7smq46oeYHsCEHiPWTJDmt67aMrmGKv4sqWAIbkQBxIbkfpZvkkYxD09e691cdqFZL3kmaZ1Bv4sAk5L08Dsy0RCmqwCcgOu8mxPOiF1r3tO3xlSJzsFpIzedizfUeeSMya6BU8wHbyUERcxstjVKMVtcJELJbkQBxIbIucXCHtHDmt61PygXaswHlbbRjgG(MlVvyGWiu0MsEjnFVHCSYbc2a1XaP3TqowztjVKMV3EHRSunqWhO(omqqGgi9UfYXkBk5L0892lCLLQbY(a1yGAFGGanqV(yXBUXje)iiMmq2hOgDIbkQBxIbyD)cHzXsYlQlRKkyhZK(EaZigqYkCjiynXa03C5TcdegHI2uYlP57nKJvoqWgOogi9UfYXkBk5L0892lCLLQbcc0aP3TqowzJEjvs)lxqiORItAu(6Jf1a3gOgdu7deSbQZde58g9sQK(xUGqqxfNqcJ(S9cxzPAGGnqDmq6DlKJv2EtzzmrfLKagnq7fUYs1abBG07wihRSHAkxroucA0V3EHRSunqqGgOxFS4n34eIFeetgi7dShgO2Xaf1TlXa0lPs6F5ccbDvCc2XmPVNWmIbKScxccwtma9nxERWaOwmVtEHRSunqWhO(EOZbcc0adkERBKKeNxiS4nxiUflFROUXSmqqGgiQfZ7Kx4klvdK9bQVtmqrD7smGFruEYHsqKY5XoMjn6eZigqYkCjiynXa03C5TcdGAX8o5fUYs1abFG9uNdeeObgu8w3ijjoVqyXBUqClw(wrDJzzGGanqulM3jVWvwQgi7duFNyGI62Lya)IO8KdLeOEUc7yM0qpMrmqrD7smGsEjnFhdizfUeeSMyhZKgAGzedizfUeeSMya6BU8wHbcJqrBk5L089gYXkXaf1TlXaoVqIYWlkriO3tfSJzsJEXmIbKScxccwtma9nxERWaHrOOnL8sA(Ed5yLyGI62LyGGrVHUBzmjCvkh7yM0GnXmIbKScxccwtma9nxERWaHrOOnL8sA(Ed5yLyGI62LyGxQGwgtqxfNOWoMjn6aMrmGKv4sqWAIbOV5YBfgimcfTPKxsZ3BihReduu3UedGE0iLGqQosEZfsOuCyhZKg9iMrmGKv4sqWAIbOV5YBfgimcfTPKxsZ3BihRCGGnqjLpEFGSpq2StmqrD7smaNWD)o5qjRiQHqqEP4uyhZKg6umJyajRWLGG1edqFZL3kmqyekAtjVKMV3qowjgOOUDjg4TGbxcXsIkyrfSJzsJEaZigOOUDjgiSIjhkXFJgqHbKScxccwtSJDmGYXmIzspMrmqrD7smalE7xwgtq(k(ssWOKYJbKScxccwtSJzsdmJyajRWLGG1edqFZL3kmaL3ACv3bQTbs5Tbc(2a1yGGnqjLpEV5gNq8JWvDhi4dS3bcc0aP8wJR6oqTnqkVnqW3giBoqWgOogOKYhV3CJti(r4QUde8bQXabbAG68ad(cZKykstFZTy5jbRf3a1ogOOUDjgqs5JToYYyISSU2JDmt9IzedizfUeeSMya6BU8wHbOhx4ru(BbKbc2adJqrBivsfYHsO8gBWArbXaf1TlXaQGwMwgtOFLcjGrdGDmtSjMrmGKv4sqWAIbkQBxIbEtzzmrfLKagnagG(MlVvya6DlKJv2uYlP57Tx4klvde8bQFGGanqDEGETK0Bk5L089MKv4sqWa0D6siE9XIRWmPh7yM6aMrmGKv4sqWAIbOV5YBfgqhdus5J3BUXje)iCv3bc(aLUcnYfIBCYa12a1pqqGgiL3ACv3bQTbs5TbY(2a1pqTpqqGgiQfZ7Kx4klvdK9bkDfAKle34KbQ1a1pqqGgyyekAt53ZrK6DEsLieu7L2lCLLQbQTbQFGSpqPRqJCH4gNGbkQBxIbqnLRihkbn63XoMPEeZigqYkCjiynXa03C5TcdegHI2(ifVLXe2qHiewwI0qow5abBGf1nMfIKcNjQbc(a1JbkQBxIb(ifVLXe2qHiewwIGDmt6umJyajRWLGG1edqFZL3kmaL3ACv3bQTbs5Tbc(2a1JbkQBxIbKUbLfHVEoSJzQhWmIbKScxccwtmqrD7smaQPCYHsCEHWI3CH4wS8ya6BU8wHbO82azFG9IbO70Lq86JfxHzsp2Xm1tygXaswHlbbRjgG(MlVvyakV14QUduBdKYBde8TbQhduu3Uedq5nsy0RCSJzsFNygXaf1TlXauEJWQywWaswHlbbRj2XmPxpMrmGKv4sqWAIbkQBxIbClwEsWAXHbOV5YBfgGECHhr5VfqgiydKYBnUQ7a12aP82abFBGAmqWgyyekAt53ZrK6DEsLieu7LgYXkXa0D6siE9XIRWmPh7yM0RbMrmGKv4sqWAIbOV5YBfgimcfTr5nIKYhV3uErdmqWhyVDoqTnWomWE2dSOUXSqKu4mrnqWgi94cpIYFlGmqWgOogi9UfYXkBVPSmMOIssaJgO9cxzPAGGpqngiydKE3c5yLnut5kYHsqJ(92lCLLQbc(a1yGGanq6DlKJv2EtzzmrfLKagnq7fUYs1azFG9oqWgi9UfYXkBOMYvKdLGg97Tx4klvde8b27abBGuEBGGpWEhiiqdKE3c5yLT3uwgturjjGrd0EHRSunqWhyVdeSbsVBHCSYgQPCf5qjOr)E7fUYs1azFG9oqWgiL3gi4dKnhiiqdKYBnUQ7a12aP82azFBG6hiydus5J3BUXje)iCv3bY(a1yGAFGGanWWiu0gL3iskF8Et5fnWabFG67CGGnqulM3jVWvwQgi7duNIbkQBxIbubTmTmMq)kfsaJga7yM03lMrmGKv4sqWAIbkQBxIbcxfnWf5KagnagG(MlVvya6XfEeL)wazGGnqDmqVws6nL8sA(EtYkCjideSbsVBHCSYMsEjnFV9cxzPAGSpWEhiiqdKE3c5yLT3uwgturjjGrd0EHRSunqWhO(bc2aP3Tqowzd1uUICOe0OFV9cxzPAGGpq9deeObsVBHCSY2BklJjQOKeWObAVWvwQgi7dS3bc2aP3Tqowzd1uUICOe0OFV9cxzPAGGpWEhiydKYBde8bQXabbAG07wihRS9MYYyIkkjbmAG2lCLLQbc(a7DGGnq6DlKJv2qnLRihkbn63BVWvwQgi7dS3bc2aP82abFG9oqqGgiL3gi4dSddeeObggHI2cVaKG)rBrbhO2Xa0D6siE9XIRWmPh7yM0ZMygXaswHlbbRjgOOUDjgWTy5jbRfhgG(MlVvya6XfEeL)wazGGnqkV14QUduBdKYBde8TbQbgGUtxcXRpwCfMj9yhZK(oGzedyPl)hf0Xa6Xaf1TlXaORDlJjk5dkPtcy0ayajRWLGG1e7yM03JygXaswHlbbRjgOOUDjgiCv0axKtcy0aya6BU8wHbOhx4ru(BbKbc2aP3Tqowzd1uUICOe0OFV9cxzPAGSpWEhiydKYBdCBGAmqWgyWxyMetrA6BUflpjyT4giydus5J3BUXje)iDOZbY(a1JbO70Lq86JfxHzsp2XmPxNIzedizfUeeSMyGI62LyGWvrdCrojGrdGbOV5YBfgGECHhr5Vfqgiydus5J3BUXje)iCv3bY(a1yGGnqDmqkV14QUduBdKYBdK9TbQFGGanWGVWmjMI003ClwEsWAXnqTJbO70Lq86JfxHzsp2Xog4ckP8ygXmPhZigqYkCjiynXaf1TlXaOMYjhkX5fclEZfIBXYJbO70Lq86JfxHzsp2XmPbMrmGKv4sqWAIbOV5YBfgWRLKEJYBKWOx5njRWLGGbkQBxIbKUbLfHVEoSJzQxmJyajRWLGG1eduu3Ued4wS8KG1IddqFZL3kma94cpIYFlGmqWgiL3ACv3bQTbs5Tbc(2a1adq3PlH41hlUcZKESJzInXmIbKScxccwtma9nxERWauERXvDhO2giL3g42a7DGGanqkV14QUduBdKYBdCBG6Xaf1TlXas3GYIWxph2Xm1bmJyajRWLGG1edqFZL3kmGxlj9gV5e6XfEnjRWLGGbkQBxIbqx7wgtuYhusNeWObWoMPEeZigqYkCjiynXaf1TlXaUflpjyT4Wa03C5Tcdq5Tgx1DGABGuEBGGVnqnWa0D6siE9XIRWmPh7yh7yGkY5VhdWw8Ua2YWo2Xya]] )

end