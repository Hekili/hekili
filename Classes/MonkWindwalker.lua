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
            cooldown = 180,
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
                summonPet( "xuen", 45 )

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
    
    spec:RegisterPack( "Windwalker", 20201025, [[dSexJbqiqQ8isqTjq4tGuLQrrkYPif1QaPkLxrkmlqYTivQDjv)IuXWKI6yKQwMQQEMuOPrc01aPSnqQQVrQKACsr05KIG5rcDpP0(arhKujXcjr9qsqAIKGOlsccBuks9rPiP0iLIKQtsQKKvQQYlbPkUjPssTtqPFcsvYqLIKSuPirpvPMkO4QsrOTkfjfFvksyVq9xKgmKdlAXuPhJyYO4YeBwv(mvz0K0PPSAsaVMkmBLCBuA3s(nWWjLwUkphvtx46uvBxk47urJNe58QkRNujMpOA)kgRhddEZKHGH9FZ)BwFZ)HwxFZ6Bu)F8o(0k4T2K4i9e8UswbVBkSIXzUCihERn)wGKbddEZb(hrWB8213wHUQc7I3mziyy)38)M138FO113S(g1RhV5Afcg2)q)MaERAmmsHDXBgHtWBfEqnfwX4mxoKBq6QbLJ5NcpiOxKa4k3G(RGqnO)n)Vz8Ez8GJHbVjmuU8WWGHvpgg8wQ0DjmyLXBYzHCwI3q3GAiplDxsxfSyOk5l1GGdFqpZtnONWMwXhKId6p0W7KegOWBRAa4qOk5lfoWW(hddENKWafE)Y1skk4yKdVLkDxcdwzCGHTrmm4Dscdu4TlOegFEqDpXjElv6UegSY4adRcIHbVtsyGcVDkPwqXPGhfCmYH3sLUlHbRmoWWcnmm4TuP7syWkJ3KZc5SeVjQwNnvAq6EqevBqq2oi94Dscdu4DEKSeAaUtQahyyH(yyWBPs3LWGvgVjNfYzjEh55jrxvYvO21sIbPy7G0dTbbXGC9FVopahlvYluPzXqF2jDgGZcVtsyGcVdGprLcEugjdvCGHvxJHbVLkDxcdwz8MCwiNL4nbawmaNv)z8Gtbp6Z)(6NWMwXhKId6)GGdFqpZtnONWMwXhKIds)F8ojHbk82DbamuWJgQcvkH9dhyyBsmm4Dscdu4TNFEmwwuWJM6ICGqfVLkDxcdwzCGHTjGHbVtsyGcVDcUftdIv0t4GklIG3sLUlHbRmoWWQVzmm4TuP7syWkJ3KZc5SeVHUbXaIobuePIldHH(wjRqD9VQFcBAfFqqminninniOBqrUKk6ovTBzLhL5spqr16xe1UuP7sygeC4dIaalgGZQ7u1ULvEuMl9afvRFru7NWMwXhKMheedIaalgGZQFg3kpk3VOomIJ(jSPv8bbXGiaWIb4S6pJhCk4rF(3x)e20k(GGyqU(VxNhGJLk5fQ0SyOp7KodWzninpi4Wh0Z8ud6jSPv8bP4GAs8ojHbk8MakIuXLHWqFRKvWbgw96XWG3jjmqH3HQq9lxGFXqFGJi4TuP7syWkJdmS6)JHbVtsyGcV16F27ZkpQ7k5bElv6UegSY4adR(gXWG3sLUlHbRmEtolKZs8oYZtIEyScnauTKG(V5bb5GAS5bbh(GI88KORk5ku7AjXGuSDq)BgVtsyGcVpj1ALh9TswHJdmS6vqmm4Dscdu49dq85cdn1f5SqOUsYI3sLUlHbRmoWWQhAyyWBPs3LWGvgVjNfYzjElLCEFdsXbPGnJ3jjmqH3Scl4(OGhD5tmgkZjjlhhyy1d9XWG3jjmqH3NPv7sOwr5AtIG3sLUlHbRmoWWQxxJHbVLkDxcdwz8MCwiNL4nbawmaNvNhGJLk5fQ0SyOp7KornppHpO2b9FqWHpON5Pg0tytR4dsXb9V5bbh(GC9FVoxKq1kp6LEs3x7GGdFqAAqeayXaCwD3faWqbpAOkuPe2V(jSPv8bPXG0piihebawmaNvNhGJLk5fQ0SyOp7K(ZFTONquZZtOHXkdco8bbDds4CPis3DbamuWJgQcvkH9RZMka4gKMheedIaalgGZQ)mEWPGh95FF9tytR4dsXbPV5bbXGiQ2GGSDq)heedIaalgGZQ7u1ULvEuMl9afvRFru7NWMwXhKIds)F8ojHbk8MhGJLk5fQ0SyOp7eCGHvFtIHbVLkDxcdwz8UswbVtUAdzjC6L6c4OeWLl8ojHbk8o5QnKLWPxQlGJsaxUWbgw9nbmm4TvHCnKl8Uj0mERLeuvjxHkE3ChA4Dscdu4Da8jQuWJ6ip2eVLkDxcdwzCGH9FZyyWBPs3LWGvgVjNfYzjE)mp1GEcBAfFqqoi9)H2GGdFqU(VxNhGJLk5fQ0SyOp7KUV2bbh(GEMNAqpHnTIpifh0)MX7KegOWB3faWqF(3hoWW(xpgg8wQ0DjmyLXBYzHCwI3pZtnONWMwXheKdsFtcTbbh(GC9FVopahlvYluPzXqF2jDFTdco8b9mp1GEcBAfFqkoO)nJ3jjmqH3UYXLZHvE4ad7))yyW7KegOW7L5PgCQc4Z4XkvG3sLUlHbRmoWW(Vrmm4TuP7syWkJ3KZc5SeVFMNAqpHnTIpiihK()qBqWHpix)3RZdWXsL8cvAwm0NDs3x7GGdFqpZtnONWMwXhKId6FZ4Dscdu49ZoXDbam4ad7FfeddElv6UegSY4n5SqolXBx)3RZdWXsL8cvAwm0NDsNb4SW7KegOW7SicpUCrj5AHdCG3aTsjhggmS6XWG3sLUlHbRmENKWafE)mEqbpAOkuNQwi0W8KdVjNfYzjEtuToBQ0G09GiQ2GGSDqnI3KpYsOrENNeC8wpoWW(hddElv6UegSY4n5SqolX7ixsfDIQrD9pE0LkDxcZGGyqevRZMkniDpiIQniiBhuJ4Dscdu4TOKwzrvZJfhyyBeddElv6UegSY4Dscdu4DyEYr1Mlw8MCwiNL4nbW6cO84mhYGGyqevRZMkniDpiIQniiBh0F8M8rwcnYZtcogw94adRcIHbVtsyGcVfL0klQAES4TuP7syWkJdmSqdddElv6UegSY4Dscdu4DyEYr1Mlw8MCwiNL4nr16SPsds3dIOAdcY2b9hVjFKLqJ88KGJHvpoWbEZiV0FfyyWWQhddENKWafEZ1k5rvZIHYJZCi4TuP7syWkJdmS)XWG3sLUlHbRmEd0I3CjW7KegOW7gYZs3LG3nKlFbVjaWIb4S6w1aWHqvYxkAOkuNQwi0W8KRFcBAfFqqoON5Pg0tytR4dco8b9mp1GEcBAfFqkoi9)BEqqmON5Pg0tytR4dcYbraGfdWz15YjLfF9tytR4dcIbraGfdWz15YjLfF9tytR4dcYbPVz8UH8OvYk4TkyXqvYxkCGHTrmm4TuP7syWkJ3KZc5SeV10GC9FVoxoPS4R7RDqWHpix)3RZdWXsL8cvAwm0NDs3x7G08GGyqALORKVu0qvOovTqOH5jxpjH1Gmi4Wh0Z8ud6jSPv8bPy7GG(nJ3jjmqH3AbHbkCGHvbXWG3sLUlHbRmEtolKZs821)96C5KYIVUVw8ojHbk8MKRfnjHbk6Y4bEVmEqRKvWBUCszXhoWWcnmm4TuP7syWkJ3KZc5SeVdJvgKIdcAdcIbruTbP4GG2GGyqq3G0krxjFPOHQqDQAHqdZtUEscRbbVtsyGcVj5ArtsyGIUmEG3lJh0kzf8gOvk5WbgwOpgg8wQ0DjmyLX7KegOW7NXdk4rdvH6u1cHgMNC4n5SqolXBIQ1ztLgKUher1geKTdQXbbXG00GKsoVVEyScnau2uPbP4G0pi4WhKuY591dJvObGYMknifhKcoiigebawmaNv)z8Gtbp6Z)(6NWMwXhKIdsFhAdsZ4n5JSeAKNNeCmS6XbgwDngg8wQ0DjmyLXBYzHCwI3evRZMkniDpiIQniiBhK(bPXGeoxkI0jG6TmsqZIHYJZEsNnvaWniigKMgKuY591dJvObGYMknifhK(bbh(GiaWIb4S6C5KYIV(jSPv8bP4G(pi4WhKuY591dJvObGYMknifhKcoiigebawmaNv)z8Gtbp6Z)(6NWMwXhKIdsFhAdsZ4Dscdu4TOKwzrvZJfhyyBsmm4TuP7syWkJ3jjmqH3H5jhvBUyXBYzHCwI3eaRlGYJZCidcIbruToBQ0G09GiQ2GGSDq)heedstdsk58(6HXk0aqztLgKIds)GGdFqeayXaCwDUCszXx)e20k(GuCq)heC4dsk58(6HXk0aqztLgKIdsbheedIaalgGZQ)mEWPGh95FF9tytR4dsXbPVdTbPz8M8rwcnYZtcogw94adBtaddElv6UegSY4n5SqolXBOBqrUKk6C5KYIVUuP7syW7KegOWBsUw0KegOOlJh49Y4bTswbVjmuU8Wbgw9nJHbVLkDxcdwz8MCwiNL4DKlPIoxoPS4Rlv6Ueg8ojHbk8MKRfnjHbk6Y4bEVmEqRKvWBcdLlNuw8HdmS61JHbVLkDxcdwz8MCwiNL4DscRbHkLWAcFqkoOgX7KegOWBsUw0KegOOlJh49Y4bTswbV5boWWQ)pgg8wQ0DjmyLXBYzHCwI3jjSgeQucRj8bbz7GAeVtsyGcVj5ArtsyGIUmEG3lJh0kzf8obcoWbER9ecG1ndmmyy1JHbVtsyGcVFlHRsU8f4TuP7syWkJdmS)XWG3sLUlHbRmEd0I3CjW7KegOW7gYZs3LG3nKlFbVBgVBipALScERKVuuqr95cnoRCiboWW2igg8wQ0DjmyLXBYzHCwI3q3GICjv05YjLfFDPs3LWmi4Whe0nOixsf9NXdk4rdvH6u1cHgMNCDPs3LWG3jjmqH3evJ66F8ahyyvqmm4TuP7syWkJ3KZc5SeVHUbf5sQOlLCEMUyLhvwMsY1LkDxcdENKWafEtunQZSbbh4aV5YjLfFyyWWQhddElv6UegSY4n5SqolXBx)3RZLtkl(6NWMwXhKIds)GGdFqjjSgeQucRj8bb5G0J3jjmqH3pJhCk4rF(3hoWW(hddElv6UegSY4n5SqolXBcG1fq5XzoKbbXG00GssyniuPewt4dcYb9FqWHpOKewdcvkH1e(GGCq6heedc6gebawmaNv)mUvEuUFrDyehDFTdsZ4Dscdu4nxRvLvEuYLLqDyeh4adBJyyWBPs3LWGvgVtsyGcVpJBLhL7xuhgXbEtolKZs8MayDbuECMdbVjFKLqJ88KGJHvpoWWQGyyWBPs3LWGvgVjNfYzjEtaSUakpoZHmiigKMgKR)71zYIiuWJsunfW6(AheC4dY1)96mzrek4rjQMcy0uxKZcP7RDqAgVtsyGcV5ATQSYJsUSeQdJ4ahyyHggg82QqUZxBqThE7ry6NWMwXBBgVtsyGcVFgp4uWJ(8Vp8wQ0DjmyLXbgwOpgg8wQ0DjmyLX7KegOW7NXdk4rdvH6u1cHgMNC4n5SqolXBIQnifhuJ4n5JSeAKNNeCmS6XbgwDngg8wQ0DjmyLX7KegOWB3vsCa8dQdJ4aVjNfYzjEtaSUakpoZHmi4Whe0nOixsfDvlOeaRlOlv6Ueg8M8rwcnYZtcogw94adBtIHbVtsyGcV5ATQSYJsUSeQdJ4aVLkDxcdwzCGd8MWq5YjLfFyyWWQhddElv6UegSY4nqlEZLaVtsyGcVBiplDxcE3qU8f8MaalgGZQZLtkl(6NWMwXhKIds)GGdFqpZtnONWMwXhKId6FZ4Dd5rRKvWBUCszXh11)4boWW(hddElv6UegSY4n5SqolXBOBqnKNLUlPRcwmuL8LAqWHpON5Pg0tytR4dsXb9hA4Dscdu4TvnaCiuL8LchyyBeddENKWafE)Y1skk4yKdVLkDxcdwzCGHvbXWG3jjmqH3UGsy85b19eN4TuP7syWkJdmSqdddENKWafE7usTGItbpk4yKdVLkDxcdwzCGHf6JHbVLkDxcdwz8MCwiNL49Z8ud6jSPv8bb5G03KqBqWHpOgYZs3L05YjLfFux)Jhdco8b9mp1GEcBAfFqkoOgHgENKWafE75NhJLff8OPUihiuXbgwDngg8wQ0DjmyLXBYzHCwI3nKNLUlPZLtkl(OU(hpW7KegOWBNGBX0Gyf9eoOYIi4adBtIHbVLkDxcdwz8MCwiNL4Dd5zP7s6C5KYIpQR)Xd8ojHbk82DbamuWJgQcvkH9dhyyBcyyWBPs3LWGvgVjNfYzjERPbraGfdWz15YjLfF9tytR4dco8braGfdWz1jGIivCzim03kzLornppHpO2b9FqAEqqmiOBqmGOtafrQ4YqyOVvYkux)R6NWMwXheedstdIaalgGZQFg3kpk3VOomIJ(jSPv8bbXGiaWIb4S6pJhCk4rF(3x)e20k(GGdFqpZtnONWMwXhKIdQjhKMX7KegOWBcOisfxgcd9Tswbhyy13mgg8ojHbk8oufQF5c8lg6dCebVLkDxcdwzCGHvVEmm4Dscdu4Tw)ZEFw5rDxjpWBPs3LWGvghyy1)hddElv6UegSY4n5SqolX7ippj6HXk0aq1sc6)MheKdQXMheC4dkYZtIUQKRqTRLedsX2b9V5bbh(GI88KOhgRqdaLXKbP4G(J3jjmqH3NKATYJ(wjRWXbgw9nIHbVtsyGcVFaIpxyOPUiNfc1vsw8wQ0DjmyLXbgw9kigg8wQ0DjmyLXBYzHCwI3sjN33GuCqkyZ4Dscdu4nRWcUpk4rx(eJHYCsYYXbgw9qdddENKWafEFMwTlHAfLRnjcElv6UegSY4adREOpgg8wQ0DjmyLXBYzHCwI3pZtnONWMwXheKds)FOni4Whud5zP7s6C5KYIpQR)Xd8ojHbk82Dbam0N)9HdmS611yyWBPs3LWGvgVjNfYzjE)mp1GEcBAfFqqoi9nj0geC4dQH8S0DjDUCszXh11)4bENKWafE7khxohw5HdmS6Bsmm4TuP7syWkJ3KZc5SeVjQwNnvAq6EqevBqq2oi94Dscdu4DEKSeAaUtQahyy13eWWG3jjmqH3lZtn4ufWNXJvQaVLkDxcdwzCGH9FZyyWBPs3LWGvgVjNfYzjE)mp1GEcBAfFqqoi9)H2GGdFqnKNLUlPZLtkl(OU(hpW7KegOW7NDI7cayWbg2)6XWG3sLUlHbRmEtolKZs8(zEQb9e20k(GGCq6)dTbbh(GAiplDxsNlNuw8rD9pEG3jjmqH3zreEC5IsY1chyy))hddElv6UegSY4n5SqolX7gYZs3L05YjLfFux)Jh4Dscdu4TB6rbpACgXbhhyy)3igg8wQ0DjmyLX7kzf8o5QnKLWPxQlGJsaxUW7KegOW7KR2qwcNEPUaokbC5chyy)RGyyWBPs3LWGvgVjNfYzjEh55jrxvYvO21sIbPy7G0dn8ojHbk8oa(evk4rzKmuXbg2)qdddEBvixd5cVBcnJ3AjbvvYvOI3n3HgENKWafEhaFIkf8OoYJnXBPs3LWGvghyy)d9XWG3sLUlHbRmEtolKZs8MaalgGZQFg3kpk3VOomIJ(jSPv8bP4G(pi4Wh0Z8ud6jSPv8bP4G0dn8ojHbk8MlNuw8HdmS)11yyW7KegOWB30JcE04mIdoElv6UegSY4ah4npWWGHvpgg8ojHbk82PQDlR8Omx6bkQw)IOI3sLUlHbRmoWW(hddElv6UegSY4n5SqolXBIQ1ztLgKUher1geKTd6)GGyqsjN3xpmwHgakBQ0GGCqnoi4Wher16SPsds3dIOAdcY2bPGdcIbPPbjLCEF9WyfAaOSPsdcYb9FqWHpiOBqApPbQhHPRVhMNCuT5IDqAgVtsyGcVLsoptxSYJkltj7Wbg2gXWG3sLUlHbRmEtolKZs8MayDbuECMdzqqminnix)3RZKfrOGhLOAkG191oi4WhKR)71zYIiuWJsunfWOPUiNfs3x7G0mENKWafEZ1AvzLhLCzjuhgXboWWQGyyW7KegOW7NXdof8Op)7dVLkDxcdwzCGHfAyyWBPs3LWGvgVtsyGcVpJBLhL7xuhgXbEtolKZs8MaalgGZQZLtkl(6NWMwXheKds)GGdFqq3GICjv05YjLfFDPs3LWG3KpYsOrEEsWXWQhhyyH(yyWBPs3LWGvgVjNfYzjE76)E9ZNRALhvbsgH60kModWzniiguscRbHkLWAcFqqoi94Dscdu495ZvTYJQajJqDAfdoWWQRXWG3sLUlHbRmEtolKZs8MOAD2uPbP7bruTbbz7G0pingKW5srKobuVLrcAwmuEC2t6SPcao8ojHbk8wusRSOQ5XIdmSnjgg8wQ0DjmyLX7KegOW7NXdk4rdvH6u1cHgMNC4n5SqolXBIQnifhuJ4n5JSeAKNNeCmS6Xbg2Magg8wQ0DjmyLXBYzHCwI3evRZMkniDpiIQniiBhKE8ojHbk8MOAux)Jh4adR(MXWG3jjmqH3evJ6mBqWBPs3LWGvghyy1RhddElv6UegSY4Dscdu4DyEYr1Mlw8MCwiNL4nbW6cO84mhYGGyqevRZMkniDpiIQniiBh0)bbXGC9FVopahlvYluPzXqF2jDgGZcVjFKLqJ88KGJHvpoWWQ)pgg8wQ0DjmyLXBYzHCwI3U(VxNOAuPKZ7RZJK4yqqoOgBEq6EqqBqqVnOKewdcvkH1e(GGyqeaRlGYJZCidcIb56)EDEaowQKxOsZIH(St6maN1GGyqAAqeayXaCw9Z4w5r5(f1HrC0pHnTIpiih0)bbXGiaWIb4S6pJhCk4rF(3x)e20k(GGCq)heC4dIaalgGZQFg3kpk3VOomIJ(jSPv8bP4GACqqmicaSyaoR(Z4bNcE0N)91pHnTIpiihuJdcIbruTbb5GACqWHpicaSyaoR(zCR8OC)I6Wio6NWMwXheKdQXbbXGiaWIb4S6pJhCk4rF(3x)e20k(GuCqnoiiger1geKdsbheC4dIOAD2uPbP7bruTbPy7G0piigKuY591dJvObGYMknifh0)bP5bbh(GC9FVor1OsjN3xNhjXXGGCq6BEqqmON5Pg0tytR4dsXbPRX7KegOWBUwRkR8OKllH6WioWbgw9nIHbVLkDxcdwz8ojHbk82DLeha)G6WioWBYzHCwI3eaRlGYJZCidcIbPPbf5sQOZLtkl(6sLUlHzqqmicaSyaoRoxoPS4RFcBAfFqkoOgheC4dIaalgGZQFg3kpk3VOomIJ(jSPv8bb5G0piigebawmaNv)z8Gtbp6Z)(6NWMwXheKds)GGdFqeayXaCw9Z4w5r5(f1HrC0pHnTIpifhuJdcIbraGfdWz1Fgp4uWJ(8VV(jSPv8bb5GACqqmiIQniih0)bbh(GiaWIb4S6NXTYJY9lQdJ4OFcBAfFqqoOgheedIaalgGZQ)mEWPGh95FF9tytR4dsXb14GGyqevBqqoOgheC4dIOAdcYbbTbbh(GC9FVUlWbv7biDFTdsZ4n5JSeAKNNeCmS6Xbgw9kigg8wQ0DjmyLX7KegOW7W8KJQnxS4n5SqolXBcG1fq5XzoKbbXGiQwNnvAq6EqevBqq2oO)4n5JSeAKNNeCmS6Xbgw9qdddEBvi35RnWB94Dscdu49B9zLhLlNwPcQdJ4aVLkDxcdwzCGHvp0hddElv6UegSY4Dscdu4T7kjoa(b1HrCG3KZc5SeVjawxaLhN5qgeedIaalgGZQ)mEWPGh95FF9tytR4dsXb14GGyqevBqTd6)GGyqApPbQhHPRVhMNCuT5IDqqmiPKZ7RhgRqdafAnpifhKE8M8rwcnYZtcogw94adREDngg8wQ0DjmyLX7KegOWB3vsCa8dQdJ4aVjNfYzjEtaSUakpoZHmiigKuY591dJvObGYMknifh0)bbXG00GiQwNnvAq6EqevBqk2oi9dco8bP9KgOEeMU(EyEYr1Ml2bPz8M8rwcnYZtcogw94ah4Dcemmyy1JHbVtsyGcVDQA3YkpkZLEGIQ1ViQ4TuP7syWkJdmS)XWG3sLUlHbRmEtolKZs8MOAD2uPbP7bruTbbz7G(piigKuY591dJvObGYMkniihuJdco8bruToBQ0G09GiQ2GGSDqk4GGyqAAqsjN3xpmwHgakBQ0GGCq)heC4dc6gK2tAG6ry667H5jhvBUyhKMX7KegOWBPKZZ0fR8OYYuYoCGHTrmm4TuP7syWkJ3KZc5SeVjawxaLhN5qgeedstdY1)96mzrek4rjQMcyDFTdco8b56)EDMSicf8OevtbmAQlYzH091oinJ3jjmqH3CTwvw5rjxwc1HrCGdmSkigg8wQ0DjmyLXBYzHCwI3sjN3xpmwHgakBQ0GGCqIscXpeAySYG09G0pi4WhKR)715b4yPsEHknlg6ZoPFcBAfhVtsyGcVFgp4uWJ(8VpCGHfAyyWBPs3LWGvgVtsyGcVpJBLhL7xuhgXbEtolKZs8wtdkYLur3PQDlR8Omx6bkQw)IO2LkDxcZGGyqeayXaCw9Z4w5r5(f1HrC0z8VmmqniihebawmaNv3PQDlR8Omx6bkQw)IO2pHnTIpinguJdsZdcIbPPbraGfdWz1Fgp4uWJ(8VV(jSPv8bb5GACqWHpiIQniiBhe0gKMXBYhzj0ippj4yy1JdmSqFmm4TuP7syWkJ3KZc5SeVD9FV(5ZvTYJQajJqDAftNb4SW7KegOW7ZNRALhvbsgH60kgCGHvxJHbVLkDxcdwz8MCwiNL4nbW6cO84mhYGGyqAAqAAqevBqqoOgheC4dIaalgGZQ)mEWPGh95FF9tytR4dcYbb9hKMheedstdIOAdcY2bbTbbh(GiaWIb4S6pJhCk4rF(3x)e20k(GGCq)hKMheC4dsk58(6HXk0aqztLgKITdQXbPz8ojHbk8MR1QYkpk5YsOomIdCGHTjXWG3sLUlHbRmEtolKZs8MOAD2uPbP7bruTbbz7G0pingKW5srKobuVLrcAwmuEC2t6SPcao8ojHbk8wusRSOQ5XIdmSnbmm4TuP7syWkJ3KZc5SeVjQwNnvAq6EqevBqq2oOgX7KegOWBIQrD9pEG3KpYsOrEEsWXWQhhyy13mgg8wQ0DjmyLX7KegOW7W8KJQnxS4n5SqolXBIQ1ztLgKUher1geKTd6)GGyqAAqq3GICjv0vTGsaSUGUuP7sygeC4dIayDbuECMdzqAgVjFKLqJ88KGJHvpoWWQxpgg8wQ0DjmyLXBYzHCwI3eaRlGYJZCi4Dscdu4nr1OoZgeCGHv)Fmm4TuP7syWkJ3jjmqH3V1NvEuUCALkOomId8MCwiNL4TR)71DboOApaPZaCw4TvHCNV2aV1JdmS6BeddElv6UegSY4Dscdu4T7kjoa(b1HrCG3KZc5SeVjawxaLhN5qgeedstdY1)96UahuThG091oi4WhuKlPIUQfucG1f0LkDxcZGGyqApPbQhHPRVhMNCuT5IDqqminniIQ1ztLgKUher1geKTds)GGyqsjN3xpmwHgak0AEqkoi9dco8bruTb1oO)dcIbraGfdWz1Fgp4uWJ(8VV(jSPv8bP4GACqAEqAgVjFKLqJ88KGJHvpoWboW7gKJBGcd7)M)3S(M)dn82zELvEC8wxfRwWfcZGAYbLKWa1Gwgp495hER9apBj4TcpOMcRyCMlhYniD1GYX8tHhe0lsaCLBq)Hgud6FZ)BE(n)u4bPqOKq8dHzqUYdCYGiaw3mgKR4zfVpiDfcr0g8bvGs3Q5X(8xdkjHbk(Ga16Rp)ssyGI31EcbW6MHgT68wcxLC5lMFjjmqX7ApHayDZqJwDAiplDxcuvYkTk5lffuuFUqJZkhsafqBlxcOAix(sBZZVKegO4DTNqaSUzOrRoevJ66F8ak71cDrUKk6C5KYIVUuP7syGdh6ICjv0FgpOGhnufQtvleAyEY1LkDxcZ8ljHbkEx7jeaRBgA0Qdr1OoZgeOSxl0f5sQOlLCEMUyLhvwMsY1LkDxcZ8B(PWdsHqjH4hcZGKgK7BqHXkdkuLbLKaCdY4dkBiTv6UK(8ljHbkElxRKhvnlgkpoZHm)u4b1utEw6UKbfQzmiN2AnOqwRb9b8hK9g0hWFqoT1AqLimdkadYzAXGcWGijpgemafsDyadQaXGCMvmOamisYJbzXGYyq5AnOS(ybNm)ssyGIRrRonKNLUlbQkzLwvWIHQKVuqb02YLaQgYLV0saGfdWz1TQbGdHQKVu0qvOovTqOH5jx)e20koKpZtnONWMwXHd)zEQb9e20kUI6)3mepZtnONWMwXHKaalgGZQZLtkl(6NWMwXHGaalgGZQZLtkl(6NWMwXHuFZZpfEqnrUmiTGWa1GS3G2YjLfFdY4dYxludcCdYfeQdARq00dklMbbdqHCq5jdYxludcCdkuLbf55jXGCAR1GymzqoTq1Qbb9BEqCHakg(8ljHbkUgT6OfegOGYETAY1)96C5KYIVUVw4WD9FVopahlvYluPzXqF2jDFTAgcTs0vYxkAOkuNQwi0W8KRNKWAqGd)zEQb9e20kUITq)MNFk8GuO5AnOqvg0woPS4BqjjmqnOLXJbzVbTLtkl(gKXheX)oPI13G81o)ssyGIRrRoKCTOjjmqrxgpGQswPLlNuw8bL9AD9FVoxoPS4R7RD(PWdAqnrUmOMgenfWmi7nOb9b8huEYGyno3kVbLXGwsYJb14GiQgudsxPyg0hWFqIfQYnO8KbLUa)yqbyqKu7GKsoVpOge4gexoPS4BqgFqPlWpguagebWkdYxludcCdQPbn9Gm(GiawR8gKV2bLfZG(a(dYPTwdIKAhKuY59nioauZVKegO4A0QdjxlAscdu0LXdOQKvAbALsoOSxBySIIqdcIQPi0Ga60krxjFPOHQqDQAHqdZtUEscRbz(LKWafxJwDEgpOGhnufQtvleAyEYbf5JSeAKNNe8w9qzVwIQ1ztL0nr1GSTri0KuY591dJvObGYMkPOE4WLsoVVEyScnau2ujfvqiiaWIb4S6pJhCk4rF(3x)e20kUI67qtZZVKegO4A0QJOKwzrvZJfk71suToBQKUjQgKT61q4CPisNaQ3Yibnlgkpo7jD2ubaheAsk58(6HXk0aqztLuupC4eayXaCwDUCszXx)e20kUI)Hdxk58(6HXk0aqztLuubHGaalgGZQ)mEWPGh95FF9tytR4kQVdnnp)ssyGIRrRoH5jhvBUyHI8rwcnYZtcEREOSxlbW6cO84mhceevRZMkPBIQbz7Fi0KuY591dJvObGYMkPOE4WjaWIb4S6C5KYIV(jSPvCf)dhUuY591dJvObGYMkPOccbbawmaNv)z8Gtbp6Z)(6NWMwXvuFhAAE(LKWafxJwDi5ArtsyGIUmEavLSslHHYLhu2Rf6ICjv05YjLfFDPs3LWm)ssyGIRrRoKCTOjjmqrxgpGQswPLWq5YjLfFqzV2ixsfDUCszXxxQ0DjmZpfEqk0CTguOkdAdZGssyGAqlJhdYEdkuLtguEYG(piWnOLW5dskH1e(8ljHbkUgT6qY1IMKWafDz8aQkzLwEaL9AtsyniuPewt4k248tHhKcnxRbfQYG0vakedkjHbQbTmEmi7nOqvozq5jdQXbbUbXcozqsjSMWNFjjmqX1OvhsUw0KegOOlJhqvjR0Mabk71MKWAqOsjSMWHSTX538tHhKUcjmqX76kafIbz8bzvifJWmOh4gKpxgKtluhutDHegHQRWWqvOljBqguwmdI4FNuX6BqLim8bfGb5kdcOnmwtxeM5xscdu8EcKwNQ2TSYJYCPhOOA9lI68ljHbkEpbIgT6iLCEMUyLhvwMs2bL9AjQwNnvs3evdY2)qiLCEF9WyfAaOSPsq2iC4evRZMkPBIQbzRccHMKsoVVEyScnau2uji)dho0P9KgOEeMU(EyEYr1Mlwnp)ssyGI3tGOrRoCTwvw5rjxwc1HrCaL9AjawxaLhN5qGqtU(VxNjlIqbpkr1uaR7RfoCx)3RZKfrOGhLOAkGrtDrolKUVwnp)ssyGI3tGOrRopJhCk4rF(3hu2Rvk58(6HXk0aqztLGuusi(HqdJv0TE4WD9FVopahlvYluPzXqF2j9tytR4ZVKegO49eiA0QZzCR8OC)I6WioGI8rwcnYZtcEREOSxRMICjv0DQA3YkpkZLEGIQ1ViQDPs3LWabbawmaNv)mUvEuUFrDyehDg)ldduqsaGfdWz1DQA3YkpkZLEGIQ1ViQ9tytR4A0OMHqteayXaCw9NXdof8Op)7RFcBAfhYgHdNOAq2cnnp)ssyGI3tGOrRoNpx1kpQcKmc1PvmqzVwx)3RF(CvR8OkqYiuNwX0zaoR5xscdu8EcenA1HR1QYkpk5YsOomIdOSxlbW6cO84mhceAstevdYgHdNaalgGZQ)mEWPGh95FF9tytR4qc91meAIOAq2cn4WjaWIb4S6pJhCk4rF(3x)e20koK)1mC4sjN3xpmwHgakBQKITnQ55xscdu8EcenA1rusRSOQ5XcL9AjQwNnvs3evdYw9AiCUuePta1BzKGMfdLhN9KoBQaGB(LKWafVNarJwDiQg11)4bu2RLOAD2ujDtuniB1NKWafVNarJwDEgpOGhnufQtvleAyEYbf5JSeAKNNe8w9qzVwIQ1ztL0nr1GSTX5xscdu8EcenA1jmp5OAZfluKpYsOrEEsWB1dL9AjQwNnvs3evdY2)qOjOlYLurx1ckbW6c6sLUlHboCcG1fq5Xzoenp)ssyGI3tGOrRoevJ6mBqGYETeaRlGYJZCiZVKegO49eiA0QZB9zLhLlNwPcQdJ4ak7166)EDxGdQ2dq6maNfuwfYD(AJw9ZVKegO49eiA0QJ7kjoa(b1HrCaf5JSeAKNNe8w9qzVwcG1fq5Xzoei0KR)71DboOApaP7Rfo8ixsfDvlOeaRlOlv6Uegi0EsdupctxFpmp5OAZfleAIOAD2ujDtuniB1dHuY591dJvObGcTMvupC4evR9peeayXaCw9NXdof8Op)7RFcBAfxXg1SMNFZpfEq7aCSqnifI8cvOguwmdQPTtgKcfawmaNfF(LKWafVtyOC51AvdahcvjFPOHQqDQAHqdZtoOSxl01qEw6UKUkyXqvYxk4WFMNAqpHnTIR4FOn)ssyGI3jmuU80OvNxUwsrbhJCZVKegO4DcdLlpnA1XfucJppOUN4C(LKWafVtyOC5PrRooLulO4uWJcog5MFk8GAICzq6khjlzqWaUtQyq2BqFa)bLNmiwJZTYBqzmOLK8yq6hKcv1MFjjmqX7egkxEA0QtEKSeAaUtQak71suToBQKUjQgKT6NFjjmqX7egkxEA0Qta8jQuWJYizOcL9AJ88KORk5ku7AjHIT6HgeU(VxNhGJLk5fQ0SyOp7KodWzn)ssyGI3jmuU80Ovh3faWqbpAOkuPe2pOSxlbawmaNv)z8Gtbp6Z)(6NWMwXv8pC4pZtnONWMwXvu))5xscdu8oHHYLNgT645NhJLff8OPUihiuNFjjmqX7egkxEA0QJtWTyAqSIEchuzrK5xscdu8oHHYLNgT6qafrQ4YqyOVvYkqzVwOJbeDcOisfxgcd9TswH66Fv)e20koeAstqxKlPIUtv7ww5rzU0duuT(frTlv6Ueg4WjaWIb4S6ovTBzLhL5spqr16xe1(jSPvCndbbawmaNv)mUvEuUFrDyeh9tytR4qqaGfdWz1Fgp4uWJ(8VV(jSPvCiC9FVopahlvYluPzXqF2jDgGZsZWH)mp1GEcBAfxXMC(LKWafVtyOC5PrRoHQq9lxGFXqFGJiZVKegO4DcdLlpnA1rR)zVpR8OURKhZVKegO4DcdLlpnA15KuRvE03kzfou2RnYZtIEyScnauTKG(VziBSz4WJ88KORk5ku7AjHIT)BE(LKWafVtyOC5PrRopaXNlm0uxKZcH6kj78ljHbkENWq5YtJwDyfwW9rbp6YNymuMtswou2Rvk58(uubBE(LKWafVtyOC5PrRoNPv7sOwr5AtIm)ssyGI3jmuU80OvhEaowQKxOsZIH(StGYETeayXaCwDEaowQKxOsZIH(St6e188eE7F4WFMNAqpHnTIR4)MHd31)96CrcvR8Ox6jDFTWHRjcaSyaoRU7cayOGhnufQuc7x)e20kUg6HKaalgGZQZdWXsL8cvAwm0NDs)5Vw0tiQ55j0Wyf4WHoHZLIiD3faWqbpAOkuPe2VoBQaGtZqqaGfdWz1Fgp4uWJ(8VV(jSPvCf13meevdY2)qqaGfdWz1DQA3YkpkZLEGIQ1ViQ9tytR4kQ))8ljHbkENWq5YtJwD85c1cHfQkzL2KR2qwcNEPUaokbC5A(LKWafVtyOC5PrRobWNOsbpQJ8ytOSkKRHC12eAgkTKGQk5kuBBUdT5NcpOMixgKYlaGzqnT)9ni7niya(e1bbEdsHuYqf6D(GiaWIb4SgKXhK3jzi3Gc1SguJnpinfQgFqwrw(mcFqovTLmiyakKdY4dI4FNuX6BqjjSgend1Ga3GaV3GiaWIb4SgKtvPg0hWFq5jdsfSySYBqGkadcgGcjudcCdYPQudkuLbf55jXGm(GsxGFmOamigtMFjjmqX7egkxEA0QJ7cayOp)7dk71(mp1GEcBAfhs9)HgC4U(VxNhGJLk5fQ0SyOp7KUVw4WFMNAqpHnTIR4)MNFjjmqX7egkxEA0QJRCC5CyLhu2R9zEQb9e20koK6BsObhUR)715b4yPsEHknlg6ZoP7Rfo8N5Pg0tytR4k(V55xscdu8oHHYLNgT6Smp1GtvaFgpwPI5xscdu8oHHYLNgT68StCxaadu2R9zEQb9e20koK6)dn4WD9FVopahlvYluPzXqF2jDFTWH)mp1GEcBAfxX)np)ssyGI3jmuU80OvNSicpUCrj5AbL9AFMNAqpHnTIdP(MeAWH76)EDEaowQKxOsZIH(St6(AHd)zEQb9e20kUI)BojHbkENWq5YtJwDCtpk4rJZio4qzVwx)3RZdWXsL8cvAwm0NDsNb4SMFZpfEqB5KYIVbPqbGfdWzXNFjjmqX7egkxoPS4RTH8S0DjqvjR0YLtkl(OU(hpGcOTLlbunKlFPLaalgGZQZLtkl(6NWMwXvupC4pZtnONWMwXv8FZZVKegO4DcdLlNuw8PrRow1aWHqvYxkAOkuNQwi0W8Kdk71cDnKNLUlPRcwmuL8Lco8N5Pg0tytR4k(hAZVKegO4DcdLlNuw8PrRoVCTKIcog5MFjjmqX7egkxoPS4tJwDCbLW4ZdQ7joNFjjmqX7egkxoPS4tJwDCkPwqXPGhfCmYn)ssyGI3jmuUCszXNgT645NhJLff8OPUihiuHYETpZtnONWMwXHuFtcn4WBiplDxsNlNuw8rD9pEah(Z8ud6jSPvCfBeAZVKegO4DcdLlNuw8PrRoob3IPbXk6jCqLfrGYETnKNLUlPZLtkl(OU(hpMFjjmqX7egkxoPS4tJwDCxaadf8OHQqLsy)GYETnKNLUlPZLtkl(OU(hpMFjjmqX7egkxoPS4tJwDiGIivCzim03kzfOSxRMiaWIb4S6C5KYIV(jSPvC4WjaWIb4S6eqrKkUmeg6BLSsNOMNNWB)RziGogq0jGIivCzim03kzfQR)v9tytR4qOjcaSyaoR(zCR8OC)I6Wio6NWMwXHGaalgGZQ)mEWPGh95FF9tytR4WH)mp1GEcBAfxXMuZZVKegO4DcdLlNuw8PrRoHQq9lxGFXqFGJiZVKegO4DcdLlNuw8PrRoA9p79zLh1DL8y(LKWafVtyOC5KYIpnA15KuRvE03kzfou2RnYZtIEyScnauTKG(VziBSz4WJ88KORk5ku7AjHIT)Bgo8ippj6HXk0aqzmrX)ZVKegO4DcdLlNuw8PrRopaXNlm0uxKZcH6kj78ljHbkENWq5YjLfFA0QdRWcUpk4rx(eJHYCsYYHYETsjN3NIkyZZVKegO4DcdLlNuw8PrRoNPv7sOwr5AtIm)ssyGI3jmuUCszXNgT64Uaag6Z)(GYETpZtnONWMwXHu)FObhEd5zP7s6C5KYIpQR)XJ5xscdu8oHHYLtkl(0Ovhx54Y5WkpOSx7Z8ud6jSPvCi13Kqdo8gYZs3L05YjLfFux)JhZVKegO4DcdLlNuw8PrRo5rYsOb4oPcOSxlr16SPs6MOAq2QF(LKWafVtyOC5KYIpnA1zzEQbNQa(mESsfZVKegO4DcdLlNuw8PrRop7e3faWaL9AFMNAqpHnTIdP()qdo8gYZs3L05YjLfFux)JhZVKegO4DcdLlNuw8PrRozreEC5IsY1ck71(mp1GEcBAfhs9)HgC4nKNLUlPZLtkl(OU(hpMFjjmqX7egkxoPS4tJwDCtpk4rJZio4qzV2gYZs3L05YjLfFux)JhZVKegO4DcdLlNuw8PrRo(CHAHWcvLSsBYvBilHtVuxahLaUCn)ssyGI3jmuUCszXNgT6eaFIkf8OmsgQqzV2ippj6QsUc1UwsOyREOn)ssyGI3jmuUCszXNgT6eaFIkf8OoYJnHYQqUgYvBtOzO0scQQKRqTT5o0MFjjmqX7egkxoPS4tJwD4YjLfFqzVwcaSyaoR(zCR8OC)I6Wio6NWMwXv8pC4pZtnONWMwXvup0MFjjmqX7egkxoPS4tJwDCtpk4rJZio4ZV5NcpiOxALsU5xscdu8oqRuY1(mEqbpAOkuNQwi0W8KdkYhzj0iVZtcEREOSxlr16SPs6MOAq2248ljHbkEhOvk50OvhrjTYIQMhlu2RnYLurNOAux)JhDPs3LWabr16SPs6MOAq2248ljHbkEhOvk50OvNW8KJQnxSqr(ilHg55jbVvpu2RLayDbuECMdbcIQ1ztL0nr1GS9)8ljHbkEhOvk50OvhrjTYIQMh78ljHbkEhOvk50OvNW8KJQnxSqr(ilHg55jbVvpu2RLOAD2ujDtuniB)p)MFk8GAQodCw8nOMcvBjdAlNuw8niDv8b1e1o)ssyGI35YjLfFTpJhCk4rF(3hu2R11)96C5KYIV(jSPvCf1dhEscRbHkLWAchs9ZVKegO4DUCszXNgT6W1AvzLhLCzjuhgXbu2RLayDbuECMdbcnLKWAqOsjSMWH8pC4jjSgeQucRjCi1db0raGfdWz1pJBLhL7xuhgXr3xRMNFjjmqX7C5KYIpnA15mUvEuUFrDyehqr(ilHg55jbVvpu2RLayDbuECMdz(LKWafVZLtkl(0OvhUwRkR8OKllH6WioGYETeaRlGYJZCiqOjx)3RZKfrOGhLOAkG191chUR)71zYIiuWJsunfWOPUiNfs3xRMNFk8GGr14dYPTwdIK8yqnnOPhuwmdYQqUZxBmOqvgernRswdYEdkuLb1uRcvHCqgFqNKmFdklMbXbSsOAL3Gunpv5geOguOkds7zGZIVbTmEmin1uUHE08Gm(GYgsZDjZVKegO4DUCszXNgT68mEWPGh95FFqzvi35RnO2R1JW0pHnTI3288ljHbkENlNuw8PrRopJhuWJgQc1PQfcnmp5GI8rwcnYZtcEREOSxlr1uSX5NcpOMixgKYaOhOgKfdYPTwdcuRVb5Es6yqSjpK7Bq2Bqn1TyqkuaRlyqgFqWc9cMbf5sQqyMFjjmqX7C5KYIpnA1XDLeha)G6WioGI8rwcnYZtcEREOSxlbW6cO84mhcC4qxKlPIUQfucG1f0LkDxcZ8ljHbkENlNuw8PrRoCTwvw5rjxwc1HrCm)MFk8G2w5TKbf55jXGAQodCw8n)ssyGI35rRtv7ww5rzU0duuT(frD(LKWafVZdnA1rk58mDXkpQSmLSdk71suToBQKUjQgKT)Hqk58(6HXk0aqztLGSr4WjQwNnvs3evdYwfecnjLCEF9WyfAaOSPsq(hoCOt7jnq9imD99W8KJQnxSAE(LKWafVZdnA1HR1QYkpk5YsOomIdOSxlbW6cO84mhceAY1)96mzrek4rjQMcyDFTWH76)EDMSicf8OevtbmAQlYzH091Q55xscdu8op0OvNNXdof8Op)7B(PWdQjYLb1uUHEgeOguKNNe8b50cvGFmiD155yqG3Gcvzqk0llzqmIR)7b1GS3G0c4CZDjqnOSygK9g0woPS4BqgFqzmOLK8yq)hexiGIHpO0z(n)ssyGI35HgT6Cg3kpk3VOomIdOiFKLqJ88KG3Qhk71saGfdWz15YjLfF9tytR4qQhoCOlYLurNlNuw81LkDxcZ8ljHbkENhA0QZ5ZvTYJQajJqDAfdu2R11)96Npx1kpQcKmc1PvmDgGZcIKewdcvkH1eoK6NFjjmqX78qJwDeL0klQAESqzVwIQ1ztL0nr1GSvVgcNlfr6eq9wgjOzXq5XzpPZMka4MFjjmqX78qJwDEgpOGhnufQtvleAyEYbf5JSeAKNNe8w9qzVwIQPyJZpfEqnrUmifQYdYEd6d4pO8KbXcozqHAwdQ5bPqvTbLoZVb9oa7GytLguwmdsnBqgK(bjLW(b1Ga3GYtgel4KbfQzni9dsHQAdkDMFd6Da2bXMkn)ssyGI35HgT6qunQR)XdOSxlr16SPs6MOAq2QF(LKWafVZdnA1HOAuNzdY8tHhutKldcMMQbzVb9b8huEYGuWbbUbXcozqevBqPZ8BqVdWoi2uPbLfZGGbOqoOSyg0wHOPhuEYGCbH6GkqmiFTZVKegO4DEOrRoH5jhvBUyHI8rwcnYZtcEREOSxlbW6cO84mhceevRZMkPBIQbz7FiC9FVopahlvYluPzXqF2jDgGZA(LKWafVZdnA1HR1QYkpk5YsOomIdOSxRR)71jQgvk58(68ijoGSXM1n0GEljH1GqLsynHdbbW6cO84mhceU(VxNhGJLk5fQ0SyOp7KodWzbHMiaWIb4S6NXTYJY9lQdJ4OFcBAfhY)qqaGfdWz1Fgp4uWJ(8VV(jSPvCi)dhobawmaNv)mUvEuUFrDyeh9tytR4k2ieeayXaCw9NXdof8Op)7RFcBAfhYgHGOAq2iC4eayXaCw9Z4w5r5(f1HrC0pHnTIdzJqqaGfdWz1Fgp4uWJ(8VV(jSPvCfBecIQbPcchor16SPs6MOAk2QhcPKZ7RhgRqdaLnvsX)AgoCx)3RtunQuY5915rsCaP(MH4zEQb9e20kUI665NcpOMixgKYaONbzVb5cc1b10GMEqzXmOMYn0ZGYtgubIbrwaUa1Ga3GAk3qpdY4dISaCzqzXmOMg00dY4dQaXGilaxguwmd6d4pi1SbzqSGtguOM1G(piIQb1Ga3GAAqtpiJpiYcWLb1uUHEgKXhubIbrwaUmOSyg0hWFqQzdYGybNmOqnRb14GiQgudcCd6d4pi1SbzqSGtguOM1GG2GiQgudcCdYEd6d4pipjguoiThGm)ssyGI35HgT64UsIdGFqDyehqr(ilHg55jbVvpu2RLayDbuECMdbcnf5sQOZLtkl(6sLUlHbccaSyaoRoxoPS4RFcBAfxXgHdNaalgGZQFg3kpk3VOomIJ(jSPvCi1dbbawmaNv)z8Gtbp6Z)(6NWMwXHupC4eayXaCw9Z4w5r5(f1HrC0pHnTIRyJqqaGfdWz1Fgp4uWJ(8VV(jSPvCiBecIQb5F4WjaWIb4S6NXTYJY9lQdJ4OFcBAfhYgHGaalgGZQ)mEWPGh95FF9tytR4k2ieevdYgHdNOAqcn4WD9FVUlWbv7biDFTAE(LKWafVZdnA1jmp5OAZfluKpYsOrEEsWB1dL9AjawxaLhN5qGGOAD2ujDtuniB)p)u4b1e5YGA6n0ZGYIzqwfYD(AJbzXG4XLMNAmO0z(n)ssyGI35HgT68wFw5r5YPvQG6WioGYQqUZxB0QF(PWdQjYLbPma6zq2BqnnOPhKXhezb4YGYIzqFa)bPMnid6)GiQ2GYIzqFa)BqRKhdYBbCZ1GCM8bbttfudcCdYEd6d4pO8KbLUa)yqbyqKu7GKsoVVbLfZGeluLBqFa)BqRKhdYJWmiNjFqW0uniWni7nOpG)GYtg0s48bfQznO)dIOAdkDMFd6Da2brsTATYB(LKWafVZdnA1XDLeha)G6WioGI8rwcnYZtcEREOSxlbW6cO84mhceeayXaCw9NXdof8Op)7RFcBAfxXgHGOAT)Hq7jnq9imD99W8KJQnxSqiLCEF9WyfAaOqRzf1p)ssyGI35HgT64UsIdGFqDyehqr(ilHg55jbVvpu2RLayDbuECMdbcPKZ7RhgRqdaLnvsX)qOjIQ1ztL0nr1uSvpC4ApPbQhHPRVhMNCuT5IvZ4D6hQGdV3gRcfh4aJb]] )

end