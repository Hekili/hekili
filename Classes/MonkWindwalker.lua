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
    
    spec:RegisterPack( "Windwalker", 20201013, [[dSupKbqiifEejiBsvvFIeuuJIuKtrkQvrckYRirMfeClsPAxs1ViLmmPOogvyzqONjfAAqk11ib2gKI6BKsPgNuKCosq18ifUNuAFqKdskLyHKOEOuemrsqPlcPiTrPi1hLIOsJukIQojPuswPQkVesrCtsPKANqQ(jjOWqLIiwQueLNQutfI6QsrOTkfrfFvkI0EH6Vinyqhw0IPspgXKrXLj2SQ8zQYOjPttz1qk51KQMTsUnkTBj)gy4KklxLNJQPlCDQQTlf8DQOXtcDEvL1tkfZhs2VIXoWiJ3mziy0rSzeB2rZoAS3SchXgDOa8o(0j4TUKOp9e8UswbVBsTIXzU0lhERl)wGKbJmEZb(hrWB8213wH2Qc7I3mziy0rSzeB2rZoAS3SchXgD0iEZ1jem6iIMv44TQXWif2fVzeobVvOb2KAfJZCPxUbQTgu6NFk0avyqcGRCd0rJimqeBgXMX7LXdogz8MWq5YdJmgDhyKXBPs3LWGvgVjNfYzjEJgdSH8S0DjDvWIHQOVudefQb(mp1GEcBAfFGAmqevaENKWafEBvda9cvrFPWbgDeXiJ3jjmqH3VCTKIcog5WBPs3LWGvghy0BeJmENKWafE7ckHXNhu3tCI3sLUlHbRmoWOJ2yKX7KegOWBNsQduCk4rbhJC4TuP7syWkJdm6kaJmElv6UegSY4n5SqolXBIQ1ztfhO2hir1gisTd0bENKWafENhjlHgG7KkWbgD0mgz8wQ0DjmyLXBYzHCwI3U(VxNhGJLk5fQ0SyOp7KodWzH3jjmqH3bWNOsbpkJKHkoWORTXiJ3sLUlHbRmEtolKZs8MaalgGZQ)mEWPGh95FF9tytR4duJbI4arHAGpZtnONWMwXhOgd0bI4Dscdu4T7cayOGhnufQuc7hoWO3uyKX7KegOWBp)8ySSOGhn1g5aHkElv6UegSY4aJUchJmENKWafE7eClMgeRONWbvwebVLkDxcdwzCGr3rZyKXBPs3LWGvgVjNfYzjEJgdKbeDcOisfxgcd9TswH66Fv)e20k(a)pqnnqnnq0yGrUKk6ovTBzLhL5spqr15xe1UuP7sygikudKaalgGZQ7u1ULvEuMl9afvNFru7NWMwXhOMh4)bsaGfdWz1pJBLhL7xu9grF)e20k(a)pqcaSyaoR(Z4bNcE0N)91pHnTIpW)d01)968aCSujVqLMfd9zN0zaoRbQ5bIc1aFMNAqpHnTIpqngytH3jjmqH3eqrKkUmeg6BLScoWO7Wbgz8ojHbk8oufQF5c8lg6dCebVLkDxcdwzCGr3bIyKX7KegOWBD(N9(SYJ6UsEG3sLUlHbRmoWO7OrmY4TuP7syWkJ3KZc5SeVJ88KOhgRqdavhjOi28arAGn28arHAGrEEs0vLCfQDDKyGA0oqeBgVtsyGcVpj1zLh9TswHJdm6oqBmY4Dscdu49dq85cdn1g5SqOUsYI3sLUlHbRmoWO7qbyKXBPs3LWGvgVjNfYzjElLCEFduJbI2nJ3jjmqH3Scl4(OGhD5tmgkZjjlhhy0DGMXiJ3jjmqH3NPt3sOwr56sIG3sLUlHbRmoWO7qBJrgVLkDxcdwz8MCwiNL4nbawmaNvNhGJLk5fQ0SyOp7KornppHpW2bI4arHAGpZtnONWMwXhOgdeXMhikud01)96CrcvR8Ox6jDFDdefQbQPbsaGfdWz1Dxaadf8OHQqLsy)6NWMwXhOsd0XarAGeayXaCwDEaowQKxOsZIH(St6p)1IEcrnppHggRmquOgiAmqHZLIiD3faWqbpAOkuPe2VoBIwGBGAEG)hibawmaNv)z8Gtbp6Z)(6NWMwXhOgd0rZd8)ajQ2arQDGioW)dKaalgGZQ7u1ULvEuMl9afvNFru7NWMwXhOgd0bI4Dscdu4npahlvYluPzXqF2j4aJUJMcJmElv6UegSY4DLScENC1gYs40l1gWrjGlx4Dscdu4DYvBilHtVuBahLaUCHdm6ou4yKXBRc5Aix4TcVz8whjOQsUcv8U5UcW7KegOW7a4tuPGhvFESjElv6UegSY4aJoInJrgVLkDxcdwz8MCwiNL49Z8ud6jSPv8bI0aDGOcgikud01)968aCSujVqLMfd9zN091nquOg4Z8ud6jSPv8bQXarSz8ojHbk82Dbam0N)9Hdm6i6aJmElv6UegSY4n5SqolX7N5Pg0tytR4dePb6OPuWarHAGU(VxNhGJLk5fQ0SyOp7KUVUbIc1aFMNAqpHnTIpqngiInJ3jjmqH3UYXLtVvE4aJoIiIrgVtsyGcVxMNAWPOLpJhRubElv6UegSY4aJoInIrgVLkDxcdwz8MCwiNL49Z8ud6jSPv8bI0aDGOcgikud01)968aCSujVqLMfd9zN091nquOg4Z8ud6jSPv8bQXarSz8ojHbk8(zN4UaagCGrhr0gJmElv6UegSY4n5SqolXBx)3RZdWXsL8cvAwm0NDsNb4SW7KegOW7SicpUCrj5AHdCG3aDsjhgzm6oWiJ3sLUlHbRmENKWafE)mEqbpAOkuNQwi0W8KdVjFKLqJ88KGJr3boWOJigz8wQ0DjmyLXBYzHCwI3rUKk6evJ66F8Olv6Ueg8ojHbk8wuuNSOQ5XIdm6nIrgVLkDxcdwz8ojHbk8omp5O6YflEtolKZs8MayDbuECMEzG)hir16SPIdu7dKOAdeP2bIiEt(ilHg55jbhJUdCGrhTXiJ3sLUlHbRmEtolKZs8MOAD2uXbQ9bsuTb2oWghikudKOAD2uXbQ9bsuTb2oqh4Dscdu4TOOozrvZJfhy0vagz8wQ0DjmyLXBYzHCwI3rUKk6QwqjawxqxQ0Djm4Dscdu49B9zLhLlNoPcQEJOhhy0rZyKXBPs3LWGvgVjNfYzjEJgdKlryLhVNRfWj9X1pW)dmYLurx1ckbW6c6sLUlHbVtsyGcVjxs0VSYJIwjJqxMNAuw5Hdm6ABmY4TuP7syWkJ3jjmqH3H5jhvxUyXBYzHCwI3evRZMkoqTpqIQnqKAhiI4n5JSeAKNNeCm6oWboWBg5L(RaJmgDhyKX7KegOWBUojpQAwmuECMEbVLkDxcdwzCGrhrmY4TuP7syWkJ3aD4nxc8ojHbk8UH8S0Dj4Dd5YxWBcaSyaoRUvna0luf9LIgQc1PQfcnmp56NWMwXhisd8zEQb9e20k(arHAGpZtnONWMwXhOgd0bInpW)d8zEQb9e20k(arAGeayXaCwDUCszXx)e20k(a)pqcaSyaoRoxoPS4RFcBAfFGinqhnJ3nKhTswbVvblgQI(sHdm6nIrgVLkDxcdwz8MCwiNL4TMgOR)715YjLfFDFDdefQb66)EDEaowQKxOsZIH(St6(6gOMh4)bQtIUI(srdvH6u1cHgMNC9KewdYarHAGpZtnONWMwXhOgTden3mENKWafERdegOWbgD0gJmElv6UegSY4n5SqolXBx)3RZLtkl(6(6W7KegOWBsUw0KegOOlJh49Y4bTswbV5YjLfF4aJUcWiJ3sLUlHbRmEtolKZs8omwzGAmqfmW)dKOAduJbQGb(FGOXa1jrxrFPOHQqDQAHqdZtUEscRbbVtsyGcVj5ArtsyGIUmEG3lJh0kzf8gOtk5WbgD0mgz8wQ0DjmyLX7KegOW7NXdk4rdvH6u1cHgMNC4n5SqolXBIQ1ztfhO2hir1gisTdSXb(FGAAGsjN3xpmwHgakBQ4a1yGogikuduk58(6HXk0aqztfhOgdeTh4)bsaGfdWz1Fgp4uWJ(8VV(jSPv8bQXaD0vWa1mEt(ilHg55jbhJUdCGrxBJrgVLkDxcdwz8MCwiNL4nr16SPIdu7dKOAdeP2b6yGknqHZLIiDcOElJe0SyO84SN0zt0cCd8)a10aLsoVVEyScnau2uXbQXaDmquOgibawmaNvNlNuw81pHnTIpqngiIdefQbkLCEF9WyfAaOSPIduJbI2d8)ajaWIb4S6pJhCk4rF(3x)e20k(a1yGo6kyGAgVtsyGcVff1jlQAES4aJEtHrgVLkDxcdwz8ojHbk8omp5O6YflEtolKZs8MayDbuECMEzG)hir16SPIdu7dKOAdeP2bI4a)pqnnqPKZ7RhgRqdaLnvCGAmqhdefQbsaGfdWz15YjLfF9tytR4duJbI4arHAGsjN3xpmwHgakBQ4a1yGO9a)pqcaSyaoR(Z4bNcE0N)91pHnTIpqngOJUcgOMXBYhzj0ippj4y0DGdm6kCmY4TuP7syWkJ3KZc5SeVrJbg5sQOZLtkl(6sLUlHbVtsyGcVj5ArtsyGIUmEG3lJh0kzf8MWq5Ydhy0D0mgz8wQ0DjmyLXBYzHCwI3rUKk6C5KYIVUuP7syW7KegOWBsUw0KegOOlJh49Y4bTswbVjmuUCszXhoWO7Wbgz8wQ0DjmyLXBYzHCwI3jjSgeQucRj8bQXaBeVtsyGcVj5ArtsyGIUmEG3lJh0kzf8Mh4aJUdeXiJ3sLUlHbRmEtolKZs8ojH1GqLsynHpqKAhyJ4Dscdu4njxlAscdu0LXd8Ez8GwjRG3jqWboWBDNqaSUzGrgJUdmY4TuP7syWkJ3aD4nxc8ojHbk8UH8S0Dj4Dd5YxW7MX7gYJwjRG3k6lffuuFUqJZk9sGdm6iIrgVLkDxcdwz8MCwiNL4nAmWixsfDUCszXxxQ0DjmdefQbIgdmYLur)z8GcE0qvOovTqOH5jxxQ0Djm4Dscdu4nr1OU(hpWbg9gXiJ3sLUlHbRmEtolKZs8gngyKlPIUuY5zAJvEuzzkkxxQ0Djm4Dscdu4nr1OoZgeCGd8obcgzm6oWiJ3jjmqH3ovTBzLhL5spqr15xev8wQ0DjmyLXbgDeXiJ3sLUlHbRmEtolKZs8MOAD2uXbQ9bsuTbIu7arCG)hOuY591dJvObGYMkoqKgyJdefQbsuToBQ4a1(ajQ2arQDGO9a)pqnnqPKZ7RhgRqdaLnvCGinqehikudengOUtAG6ry6o6H5jhvxUyhOMX7KegOWBPKZZ0gR8OYYu0oCGrVrmY4TuP7syWkJ3KZc5SeVjawxaLhNPxg4)bQPb66)EDMSicf8OevdTSUVUbIc1aD9FVotweHcEuIQHwgn1g5Sq6(6gOMX7KegOWBUoRkR8OKllHQ3i6XbgD0gJmElv6UegSY4n5SqolXBPKZ7RhgRqdaLnvCGinqrrH4hcnmwzGAFGogikud01)968aCSujVqLMfd9zN0pHnTIJ3jjmqH3pJhCk4rF(3hoWORamY4TuP7syWkJ3jjmqH3NXTYJY9lQEJOhVjNfYzjERPbg5sQO7u1ULvEuMl9afvNFru7sLUlHzG)hibawmaNv)mUvEuUFr1Be9Dg)lddudePbsaGfdWz1DQA3YkpkZLEGIQZViQ9tytR4duPb24a18a)pqnnqcaSyaoR(Z4bNcE0N)91pHnTIpqKgyJdefQbsuTbIu7avWa1mEt(ilHg55jbhJUdCGrhnJrgVLkDxcdwz8MCwiNL4TR)71pFUQvEu0kzeQtRy6maNfENKWafEF(CvR8OOvYiuNwXGdm6ABmY4TuP7syWkJ3KZc5SeVjawxaLhNPxg4)bQPbQPbsuTbI0aBCGOqnqcaSyaoR(Z4bNcE0N)91pHnTIpqKgiAEGAEG)hOMgir1gisTdubdefQbsaGfdWz1Fgp4uWJ(8VV(jSPv8bI0arCGAEGOqnqPKZ7RhgRqdaLnvCGA0oWghOMX7KegOWBUoRkR8OKllHQ3i6Xbg9McJmElv6UegSY4n5SqolXBIQ1ztfhO2hir1gisTd0XavAGcNlfr6eq9wgjOzXq5XzpPZMOf4W7KegOWBrrDYIQMhloWORWXiJ3sLUlHbRmEtolKZs8MOAD2uXbQ9bsuTbIu7aBeVtsyGcVjQg11)4bEt(ilHg55jbhJUdCGr3rZyKXBPs3LWGvgVtsyGcVdZtoQUCXI3KZc5SeVjQwNnvCGAFGevBGi1oqeh4)bQPbIgdmYLurx1ckbW6c6sLUlHzGOqnqcG1fq5Xz6LbQz8M8rwcnYZtcogDh4aJUdhyKXBPs3LWGvgVjNfYzjEtaSUakpotVG3jjmqH3evJ6mBqWbgDhiIrgVLkDxcdwz8ojHbk8(T(SYJYLtNubvVr0J3KZc5SeVD9FVUlqpv3biDgGZcVTkK781f4TdCGr3rJyKXBPs3LWGvgVtsyGcVDxjrpWpO6nIE8MCwiNL4nbW6cO84m9Ya)pqnnqx)3R7c0t1Das3x3arHAGrUKk6QwqjawxqxQ0Djmd8)a1Dsdupct3rpmp5O6Yf7a)pqnnqIQ1ztfhO2hir1gisTd0bApW)duk58(6HXk0aqvqZduJb6yGOqnqIQnW2bI4a)pqcaSyaoR(Z4bNcE0N)91pHnTIpqngyJduZduZ4n5JSeAKNNeCm6oWboWBcdLlNuw8HrgJUdmY4TuP7syWkJ3aD4nxc8ojHbk8UH8S0Dj4Dd5YxWBcaSyaoRoxoPS4RFcBAfFGAmqhdefQb(mp1GEcBAfFGAmqeBgVBipALScEZLtkl(OU(hpWbgDeXiJ3sLUlHbRmEtolKZs8gngyd5zP7s6QGfdvrFPgikud8zEQb9e20k(a1yGiQa8ojHbk82Qga6fQI(sHdm6nIrgVtsyGcVF5AjffCmYH3sLUlHbRmoWOJ2yKX7KegOWBxqjm(8G6EIt8wQ0DjmyLXbgDfGrgVtsyGcVDkPoqXPGhfCmYH3sLUlHbRmoWOJMXiJ3sLUlHbRmEtolKZs8(zEQb9e20k(arAGoAkfmquOgyd5zP7s6C5KYIpQR)XJbIc1aFMNAqpHnTIpqngyJkaVtsyGcV98ZJXYIcE0uBKdeQ4aJU2gJmElv6UegSY4n5SqolX7gYZs3L05YjLfFux)Jh4Dscdu4TtWTyAqSIEchuzreCGrVPWiJ3sLUlHbRmEtolKZs8UH8S0DjDUCszXh11)4bENKWafE7Uaagk4rdvHkLW(Hdm6kCmY4TuP7syWkJ3KZc5SeV10ajaWIb4S6C5KYIV(jSPv8bIc1ajaWIb4S6eqrKkUmeg6BLSsNOMNNWhy7arCGAEG)hiAmqgq0jGIivCzim03kzfQR)v9tytR4d8)a10ajaWIb4S6NXTYJY9lQEJOVFcBAfFG)hibawmaNv)z8Gtbp6Z)(6NWMwXhikud8zEQb9e20k(a1yGn1a1mENKWafEtafrQ4YqyOVvYk4aJUJMXiJ3jjmqH3HQq9lxGFXqFGJi4TuP7syWkJdm6oCGrgVtsyGcV15F27ZkpQ7k5bElv6UegSY4aJUdeXiJ3sLUlHbRmEtolKZs8oYZtIEyScnauDKGIyZdePb2yZdefQbg55jrxvYvO21rIbQr7arS5bIc1aJ88KOhgRqdaLXKbQXareVtsyGcVpj1zLh9TswHJdm6oAeJmENKWafE)aeFUWqtTroleQRKS4TuP7syWkJdm6oqBmY4TuP7syWkJ3KZc5SeVLsoVVbQXar7MX7KegOWBwHfCFuWJU8jgdL5KKLJdm6ouagz8ojHbk8(mD6wc1kkxxse8wQ0DjmyLXbgDhOzmY4TuP7syWkJ3KZc5SeVFMNAqpHnTIpqKgOdevWarHAGnKNLUlPZLtkl(OU(hpW7KegOWB3faWqF(3hoWO7qBJrgVLkDxcdwz8MCwiNL49Z8ud6jSPv8bI0aD0ukyGOqnWgYZs3L05YjLfFux)Jh4Dscdu4TRCC50BLhoWO7OPWiJ3sLUlHbRmEtolKZs8MOAD2uXbQ9bsuTbIu7aDG3jjmqH35rYsOb4oPcCGr3HchJmENKWafEVmp1GtrlFgpwPc8wQ0DjmyLXbgDeBgJmElv6UegSY4n5SqolX7N5Pg0tytR4dePb6arfmquOgyd5zP7s6C5KYIpQR)Xd8ojHbk8(zN4UaagCGrhrhyKXBPs3LWGvgVjNfYzjE)mp1GEcBAfFGinqhiQGbIc1aBiplDxsNlNuw8rD9pEG3jjmqH3zreEC5IsY1chy0rermY4TuP7syWkJ3KZc5SeVBiplDxsNlNuw8rD9pEG3jjmqH3UPhf8OXze9CCGrhXgXiJ3sLUlHbRmExjRG3jxTHSeo9sTbCuc4YfENKWafENC1gYs40l1gWrjGlx4aJoIOngz8ojHbk8oa(evk4rzKmuXBPs3LWGvghy0rubyKXBRc5Aix4TcVz8whjOQsUcv8U5UcW7KegOW7a4tuPGhvFESjElv6UegSY4aJoIOzmY4TuP7syWkJ3KZc5SeVjaWIb4S6NXTYJY9lQEJOVFcBAfFGAmqehikud8zEQb9e20k(a1yGouaENKWafEZLtkl(WbgDe12yKX7KegOWB30JcE04mIEoElv6UegSY4ah4npWiJr3bgz8ojHbk82PQDlR8Omx6bkQo)IOI3sLUlHbRmoWOJigz8wQ0DjmyLXBYzHCwI3evRZMkoqTpqIQnqKAhiId8)aLsoVVEyScnau2uXbI0aBCGOqnqIQ1ztfhO2hir1gisTdeTh4)bQPbkLCEF9WyfAaOSPIdePbI4arHAGOXa1Dsdupct3rpmp5O6Yf7a1mENKWafElLCEM2yLhvwMI2Hdm6nIrgVLkDxcdwz8MCwiNL4nbW6cO84m9Ya)pqnnqx)3RZKfrOGhLOAOL191nquOgOR)71zYIiuWJsun0YOP2iNfs3x3a1mENKWafEZ1zvzLhLCzju9grpoWOJ2yKX7KegOW7NXdof8Op)7dVLkDxcdwzCGrxbyKXBPs3LWGvgVtsyGcVpJBLhL7xu9grpEtolKZs8MaalgGZQZLtkl(6NWMwXhisd0XarHAGOXaJCjv05YjLfFDPs3LWG3KpYsOrEEsWXO7ahy0rZyKXBPs3LWGvgVjNfYzjE76)E9ZNRALhfTsgH60kModWznW)dmjH1GqLsynHpqKgOd8ojHbk8(85Qw5rrRKrOoTIbhy012yKXBPs3LWGvgVjNfYzjEtuToBQ4a1(ajQ2arQDGogOsdu4CPisNaQ3Yibnlgkpo7jD2eTahENKWafElkQtwu18yXbg9McJmElv6UegSY4Dscdu49Z4bf8OHQqDQAHqdZto8MCwiNL4nr1gOgdSr8M8rwcnYZtcogDh4aJUchJmElv6UegSY4n5SqolXBIQ1ztfhO2hir1gisTd0bENKWafEtunQR)XdCGr3rZyKX7KegOWBIQrDMni4TuP7syWkJdm6oCGrgVLkDxcdwz8ojHbk8omp5O6YflEtolKZs8MayDbuECMEzG)hir16SPIdu7dKOAdeP2bI4a)pqx)3RZdWXsL8cvAwm0NDsNb4SWBYhzj0ippj4y0DGdm6oqeJmElv6UegSY4n5SqolXBx)3RtunQuY5915rs0pqKgyJnpqTpqfmqfMgyscRbHkLWAcFG)hibW6cO84m9Ya)pqx)3RZdWXsL8cvAwm0NDsNb4Sg4)bQPbsaGfdWz1pJBLhL7xu9grF)e20k(arAGioW)dKaalgGZQ)mEWPGh95FF9tytR4dePbI4arHAGeayXaCw9Z4w5r5(fvVr03pHnTIpqngyJd8)ajaWIb4S6pJhCk4rF(3x)e20k(arAGnoW)dKOAdePb24arHAGeayXaCw9Z4w5r5(fvVr03pHnTIpqKgyJd8)ajaWIb4S6pJhCk4rF(3x)e20k(a1yGnoW)dKOAdePbI2defQbsuToBQ4a1(ajQ2a1ODGog4)bkLCEF9WyfAaOSPIduJbI4a18arHAGU(VxNOAuPKZ7RZJKOFGinqhnpW)d8zEQb9e20k(a1yGAB8ojHbk8MRZQYkpk5YsO6nIECGr3rJyKXBPs3LWGvgVtsyGcVDxjrpWpO6nIE8MCwiNL4nbW6cO84m9Ya)pqnnWixsfDUCszXxxQ0Djmd8)ajaWIb4S6C5KYIV(jSPv8bQXaBCGOqnqcaSyaoR(zCR8OC)IQ3i67NWMwXhisd0Xa)pqcaSyaoR(Z4bNcE0N)91pHnTIpqKgOJbIc1ajaWIb4S6NXTYJY9lQEJOVFcBAfFGAmWgh4)bsaGfdWz1Fgp4uWJ(8VV(jSPv8bI0aBCG)hir1gisdeXbIc1ajaWIb4S6NXTYJY9lQEJOVFcBAfFGinWgh4)bsaGfdWz1Fgp4uWJ(8VV(jSPv8bQXaBCG)hir1gisdSXbIc1ajQ2arAGkyGOqnqx)3R7c0t1Das3x3a1mEt(ilHg55jbhJUdCGr3bAJrgVLkDxcdwz8ojHbk8omp5O6YflEtolKZs8MayDbuECMEzG)hir16SPIdu7dKOAdeP2bIiEt(ilHg55jbhJUdCGr3HcWiJ3wfYD(6c82bENKWafE)wFw5r5YPtQGQ3i6XBPs3LWGvghy0DGMXiJ3sLUlHbRmENKWafE7UsIEGFq1Be94n5SqolXBcG1fq5Xz6Lb(FGeayXaCw9NXdof8Op)7RFcBAfFGAmWgh4)bsuTb2oqeh4)bQ7KgOEeMUJEyEYr1Ll2b(FGsjN3xpmwHgaQcAEGAmqh4n5JSeAKNNeCm6oWbgDhABmY4TuP7syWkJ3jjmqH3URKOh4hu9grpEtolKZs8MayDbuECMEzG)hOuY591dJvObGYMkoqngiId8)a10ajQwNnvCGAFGevBGA0oqhdefQbQ7KgOEeMUJEyEYr1Ll2bQz8M8rwcnYZtcogDh4ah4nxoPS4dJmgDhyKXBPs3LWGvgVjNfYzjE76)EDUCszXx)e20k(a1yGogikudmjH1GqLsynHpqKgOd8ojHbk8(z8Gtbp6Z)(WbgDeXiJ3sLUlHbRmEtolKZs8MayDbuECMEzG)hOMgyscRbHkLWAcFGinqehikudmjH1GqLsynHpqKgOJb(FGOXajaWIb4S6NXTYJY9lQEJOV7RBGAgVtsyGcV56SQSYJsUSeQEJOhhy0BeJmElv6UegSY4Dscdu49zCR8OC)IQ3i6XBYzHCwI3eaRlGYJZ0l4n5JSeAKNNeCm6oWbgD0gJmElv6UegSY4n5SqolXBcG1fq5Xz6Lb(FGAAGU(VxNjlIqbpkr1qlR7RBGOqnqx)3RZKfrOGhLOAOLrtTrolKUVUbQz8ojHbk8MRZQYkpk5YsO6nIECGrxbyKXBRc5oFDb1E4ThHPFcBAfVTz8ojHbk8(z8Gtbp6Z)(WBPs3LWGvghy0rZyKXBPs3LWGvgVtsyGcVFgpOGhnufQtvleAyEYH3KZc5SeVjQ2a1yGnI3KpYsOrEEsWXO7ahy012yKXBPs3LWGvgVtsyGcVDxjrpWpO6nIE8MCwiNL4nbW6cO84m9YarHAGOXaJCjv0vTGsaSUGUuP7syWBYhzj0ippj4y0DGdm6nfgz8ojHbk8MRZQYkpk5YsO6nIE8wQ0DjmyLXboWbE3GCCduy0rSzeB2rZoCG3oZRSYJJ3ARy1bUqygytnWKegOg4Y4bVp)WBDh4zlbVvOb2KAfJZCPxUbQTgu6NFk0avyqcGRCd0rJimqeBgXMNFZpfAGOPkke)qygOR8aNmqcG1nJb6kEwX7duBHqeDbFGfO0UAESp)1atsyGIpqqT(6ZVKegO4DDNqaSUzOuRwnKNLUlbHkzLwf9LIckQpxOXzLEjqaORLlbcnKlFPT55xscdu8UUtiaw3muQvlIQrD9pEGG9ArJixsfDUCszXxxQ0DjmOqHgrUKk6pJhuWJgQc1PQfcnmp56sLUlHz(LKWafVR7ecG1ndLA1IOAuNzdcc2RfnICjv0LsoptBSYJkltr56sLUlHz(n)uObIMQOq8dHzGsdY9nWWyLbgQYatsaUbA8bMnK2kDxsF(PqdenvrH4hcZaLgK7BGHXkdmuLbMKaCd04dmBiTv6UK(8ljHbkElxNKhvnlgkpotVm)uOb2KtEw6UKbgQzmqN2AnWqwRb(b8hO9g4hWFGoT1AGLimdmad0zAXadWajjpgiYafwTyadSaXaDMvmWamqsYJbAXaZyG5AnWS(ybNm)ssyGIRuRwnKNLUlbHkzLwvWIHQOVuia01YLaHgYLV0saGfdWz1TQbGEHQOVu0qvOovTqOH5jx)e20kospZtnONWMwXrH6zEQb9e20kUgoqS5)pZtnONWMwXrIaalgGZQZLtkl(6NWMwX)taGfdWz15YjLfF9tytR4i5O55NcnWMixgOoqyGAG2BGB5KYIVbA8b6RdHbcUb6cc1bUrtB6bMfZargOWoW8Kb6RdHbcUbgQYaJ88KyGoT1AGmMmqNwOA1arZnpqUqafdF(LKWafxPwT0bcduiyVwn56)EDUCszXx3xhkuU(VxNhGJLk5fQ0SyOp7KUVon)xNeDf9LIgQc1PQfcnmp56jjSgeuOEMNAqpHnTIRrlAU55NcnWMqUwdmuLbULtkl(gyscdudCz8yG2BGB5KYIVbA8bs8VtQy9nqFDZVKegO4k1QfjxlAscdu0LXdeQKvA5YjLfFiyVwx)3RZLtkl(6(6MFk0ahytKldSPbrtkYd0EdCGFa)bMNmqwJZTYBGzmWLK8yGnoqIQHWa1wkMb(b8hOyHQCdmpzGPlWpgyagij1nqPKZ7dHbcUbYLtkl(gOXhy6c8JbgGbsaSYa91HWab3aBAqtpqJpqcG1kVb6RBGzXmWpG)aDAR1ajPUbkLCEFdKda18ljHbkUsTArY1IMKWafDz8aHkzLwGoPKdb71ggROHc(tunnuWF0qNeDf9LIgQc1PQfcnmp56jjSgK5xscduCLA16z8GcE0qvOovTqOH5jhcKpYsOrEEsWBDGG9AjQwNnvu7evdP2g)RjPKZ7RhgRqdaLnvudhOqjLCEF9WyfAaOSPIAG2)jaWIb4S6pJhCk4rF(3x)e20kUgo6kqZZVKegO4k1QLOOozrvZJfb71suToBQO2jQgsTous4CPisNaQ3Yibnlgkpo7jD2eTa3FnjLCEF9WyfAaOSPIA4afkcaSyaoRoxoPS4RFcBAfxderHsk58(6HXk0aqztf1aT)taGfdWz1Fgp4uWJ(8VV(jSPvCnC0vGMNFjjmqXvQvRW8KJQlxSiq(ilHg55jbV1bc2RLayDbuECME5pr16SPIANOAi1I4FnjLCEF9WyfAaOSPIA4afkcaSyaoRoxoPS4RFcBAfxderHsk58(6HXk0aqztf1aT)taGfdWz1Fgp4uWJ(8VV(jSPvCnC0vGMNFjjmqXvQvlsUw0KegOOlJhiujR0syOC5HG9ArJixsfDUCszXxxQ0DjmZVKegO4k1QfjxlAscdu0LXdeQKvAjmuUCszXhc2RnYLurNlNuw81LkDxcZ8tHgytixRbgQYa3ipWKegOg4Y4XaT3adv5KbMNmqehi4g4s48bkLWAcF(LKWafxPwTi5ArtsyGIUmEGqLSslpqWETjjSgeQucRjCnAC(PqdSjKR1advzGAla00bMKWa1axgpgO9gyOkNmW8Kb24ab3azbNmqPewt4ZVKegO4k1QfjxlAscdu0LXdeQKvAtGGG9AtsyniuPewt4i1248B(PqduBHegO4DTfaA6an(aTkKIryg4dCd0Nld0PfQdSjVqcJq1wyyOnHLKnidmlMbs8VtQy9nWseg(adWaDLbc0fgRPncZ8ljHbkEpbsRtv7ww5rzU0duuD(frD(LKWafVNarPwTKsoptBSYJkltr7qWETevRZMkQDIQHulI)LsoVVEyScnau2urKAefkIQ1ztf1or1qQfT)RjPKZ7RhgRqdaLnvejerHcn0Dsdupct3rpmp5O6YfRMNFjjmqX7jquQvlUoRkR8OKllHQ3i6rWETeaRlGYJZ0l)1KR)71zYIiuWJsun0Y6(6qHY1)96mzrek4rjQgAz0uBKZcP7RtZZVKegO49eik1Q1Z4bNcE0N)9HG9ALsoVVEyScnau2urKeffIFi0WyfT7afkx)3RZdWXsL8cvAwm0NDs)e20k(8ljHbkEpbIsTADg3kpk3VO6nIEeiFKLqJ88KG36ab71QPixsfDNQ2TSYJYCPhOO68lIAxQ0Djm)jaWIb4S6NXTYJY9lQEJOVZ4FzyGcjcaSyaoRUtv7ww5rzU0duuD(frTFcBAfxPg18FnraGfdWz1Fgp4uWJ(8VV(jSPvCKAefkIQHuRc088ljHbkEpbIsTAD(CvR8OOvYiuNwXGG9AD9FV(5ZvTYJIwjJqDAftNb4SMFjjmqX7jquQvlUoRkR8OKllHQ3i6rWETeaRlGYJZ0l)1KMiQgsnIcfbawmaNv)z8Gtbp6Z)(6NWMwXrcnR5)AIOAi1QauOiaWIb4S6pJhCk4rF(3x)e20kosiQzuOKsoVVEyScnau2urnABuZZVKegO49eik1QLOOozrvZJfb71suToBQO2jQgsTous4CPisNaQ3Yibnlgkpo7jD2eTa38ljHbkEpbIsTArunQR)XdeSxlr16SPIANOAi16ijHbkEpbIsTA9mEqbpAOkuNQwi0W8KdbYhzj0ippj4ToqWETevRZMkQDIQHuBJZVKegO49eik1QvyEYr1LlweiFKLqJ88KG36ab71suToBQO2jQgsTi(xtOrKlPIUQfucG1f0LkDxcdkueaRlGYJZ0lAE(LKWafVNarPwTiQg1z2GGG9AjawxaLhNPxMFjjmqX7jquQvR36ZkpkxoDsfu9grpc2R11)96Ua9uDhG0zaoleSkK781fToMFjjmqX7jquQvl3vs0d8dQEJOhbYhzj0ippj4ToqWETeaRlGYJZ0l)1KR)71Db6P6oaP7RdfQixsfDvlOeaRlOlv6UeM)6oPbQhHP7OhMNCuD5I9VMiQwNnvu7evdPwhO9FPKZ7RhgRqdavbnRHduOiQwlI)jaWIb4S6pJhCk4rF(3x)e20kUgnQznp)MFk0a3b4yryGOP5fQimWSygytBNmWMaaSyaol(8ljHbkENWq5YR1Qga6fQI(srdvH6u1cHgMNCiyVw0OH8S0DjDvWIHQOVuOq9mp1GEcBAfxdevW8ljHbkENWq5YtPwTE5AjffCmYn)ssyGI3jmuU8uQvlxqjm(8G6EIZ5xscdu8oHHYLNsTA5usDGItbpk4yKB(PqdSjYLbQTCKSKbIm4oPIbAVb(b8hyEYazno3kVbMXaxsYJb6yGnbvB(LKWafVtyOC5PuRw5rYsOb4oPceSxlr16SPIANOAi16y(LKWafVtyOC5PuRwbWNOsbpkJKHkc2R11)968aCSujVqLMfd9zN0zaoR5xscdu8oHHYLNsTA5Uaagk4rdvHkLW(HG9AjaWIb4S6pJhCk4rF(3x)e20kUgiIc1Z8ud6jSPvCnCG48ljHbkENWq5YtPwT88ZJXYIcE0uBKdeQZVKegO4DcdLlpLA1Yj4wmniwrpHdQSiY8ljHbkENWq5YtPwTiGIivCzim03kzfeSxlAWaIobuePIldHH(wjRqD9VQFcBAf)VM0eAe5sQO7u1ULvEuMl9afvNFru7sLUlHbfkcaSyaoRUtv7ww5rzU0duuD(frTFcBAfxZ)jaWIb4S6NXTYJY9lQEJOVFcBAf)pbawmaNv)z8Gtbp6Z)(6NWMwX)76)EDEaowQKxOsZIH(St6maNLMrH6zEQb9e20kUgn18ljHbkENWq5YtPwTcvH6xUa)IH(ahrMFjjmqX7egkxEk1QLo)ZEFw5rDxjpMFjjmqX7egkxEk1Q1jPoR8OVvYkCeSxBKNNe9WyfAaO6ibfXMrQXMrHkYZtIUQKRqTRJeA0IyZZVKegO4DcdLlpLA16bi(CHHMAJCwiuxjzNFjjmqX7egkxEk1QfRWcUpk4rx(eJHYCsYYrWETsjN3NgODZZVKegO4DcdLlpLA16mD6wc1kkxxsK5xscdu8oHHYLNsTAXdWXsL8cvAwm0NDcc2RLaalgGZQZdWXsL8cvAwm0NDsNOMNNWBrefQN5Pg0tytR4AGyZOq56)EDUiHQvE0l9KUVouO0ebawmaNv3DbamuWJgQcvkH9RFcBAfxjhiraGfdWz15b4yPsEHknlg6ZoP)8xl6je188eAySckuOHW5srKU7cayOGhnufQuc7xNnrlWP5)eayXaCw9NXdof8Op)7RFcBAfxdhn)NOAi1I4FcaSyaoRUtv7ww5rzU0duuD(frTFcBAfxdhio)ssyGI3jmuU8uQvlFUqTqyrOswPn5QnKLWPxQnGJsaxUMFjjmqX7egkxEk1Qva8jQuWJQpp2ebRc5AixTk8MrqhjOQsUc12M7ky(PqdSjYLbQ8caygyt7FFd0EdezGprDGG3avyLmuvyMpqcaSyaoRbA8b6DsgYnWqnRb2yZdutHQXhOvKLpJWhOtvBjdezGc7an(aj(3jvS(gyscRbrZimqWnqW7nqcaSyaoRb6uvQb(b8hyEYavblgR8giOcWargOWIWab3aDQk1advzGrEEsmqJpW0f4hdmadKXK5xscdu8oHHYLNsTA5Uaag6Z)(qWETpZtnONWMwXrYbIkafkx)3RZdWXsL8cvAwm0NDs3xhkupZtnONWMwX1aXMNFjjmqX7egkxEk1QLRCC50BLhc2R9zEQb9e20kosoAkfGcLR)715b4yPsEHknlg6ZoP7RdfQN5Pg0tytR4AGyZZVKegO4DcdLlpLA1AzEQbNIw(mESsfZVKegO4DcdLlpLA16zN4UaageSx7Z8ud6jSPvCKCGOcqHY1)968aCSujVqLMfd9zN091Hc1Z8ud6jSPvCnqS55xscdu8oHHYLNsTALfr4XLlkjxleSx7Z8ud6jSPvCKC0ukafkx)3RZdWXsL8cvAwm0NDs3xhkupZtnONWMwX1aXMtsyGI3jmuU8uQvl30JcE04mIEoc2R11)968aCSujVqLMfd9zN0zaoR538tHg4woPS4BGnbayXaCw85xscdu8oHHYLtkl(ABiplDxccvYkTC5KYIpQR)Xdea6A5sGqd5YxAjaWIb4S6C5KYIV(jSPvCnCGc1Z8ud6jSPvCnqS55xscdu8oHHYLtkl(uQvlRAaOxOk6lfnufQtvleAyEYHG9ArJgYZs3L0vblgQI(sHc1Z8ud6jSPvCnqubZVKegO4DcdLlNuw8PuRwVCTKIcog5MFjjmqX7egkxoPS4tPwTCbLW4ZdQ7joNFjjmqX7egkxoPS4tPwTCkPoqXPGhfCmYn)ssyGI3jmuUCszXNsTA55NhJLff8OP2ihiurWETpZtnONWMwXrYrtPauOAiplDxsNlNuw8rD9pEGc1Z8ud6jSPvCnAubZVKegO4DcdLlNuw8PuRwob3IPbXk6jCqLfrqWETnKNLUlPZLtkl(OU(hpMFjjmqX7egkxoPS4tPwTCxaadf8OHQqLsy)qWETnKNLUlPZLtkl(OU(hpMFjjmqX7egkxoPS4tPwTiGIivCzim03kzfeSxRMiaWIb4S6C5KYIV(jSPvCuOiaWIb4S6eqrKkUmeg6BLSsNOMNNWBruZ)rdgq0jGIivCzim03kzfQR)v9tytR4)1ebawmaNv)mUvEuUFr1Be99tytR4)jaWIb4S6pJhCk4rF(3x)e20kokupZtnONWMwX1OP088ljHbkENWq5YjLfFk1QvOku)Yf4xm0h4iY8ljHbkENWq5YjLfFk1QLo)ZEFw5rDxjpMFjjmqX7egkxoPS4tPwToj1zLh9TswHJG9AJ88KOhgRqdavhjOi2msn2mkurEEs0vLCfQDDKqJweBgfQippj6HXk0aqzmrdeNFjjmqX7egkxoPS4tPwTEaIpxyOP2iNfc1vs25xscdu8oHHYLtkl(uQvlwHfCFuWJU8jgdL5KKLJG9ALsoVpnq7MNFjjmqX7egkxoPS4tPwTotNULqTIY1Lez(LKWafVtyOC5KYIpLA1YDbam0N)9HG9AFMNAqpHnTIJKdevakunKNLUlPZLtkl(OU(hpMFjjmqX7egkxoPS4tPwTCLJlNER8qWETpZtnONWMwXrYrtPauOAiplDxsNlNuw8rD9pEm)ssyGI3jmuUCszXNsTALhjlHgG7KkqWETevRZMkQDIQHuRJ5xscdu8oHHYLtkl(uQvRL5PgCkA5Z4Xkvm)ssyGI3jmuUCszXNsTA9StCxaadc2R9zEQb9e20kosoqubOq1qEw6UKoxoPS4J66F8y(LKWafVtyOC5KYIpLA1klIWJlxusUwiyV2N5Pg0tytR4i5arfGcvd5zP7s6C5KYIpQR)XJ5xscdu8oHHYLtkl(uQvl30JcE04mIEoc2RTH8S0DjDUCszXh11)4X8ljHbkENWq5YjLfFk1QLpxOwiSiujR0MC1gYs40l1gWrjGlxZVKegO4DcdLlNuw8PuRwbWNOsbpkJKH68ljHbkENWq5YjLfFk1Qva8jQuWJQpp2ebRc5AixTk8MrqhjOQsUc12M7ky(LKWafVtyOC5KYIpLA1IlNuw8HG9AjaWIb4S6NXTYJY9lQEJOVFcBAfxderH6zEQb9e20kUgouW8ljHbkENWq5YjLfFk1QLB6rbpACgrpF(n)uObQWqNuYn)ssyGI3b6KsU2NXdk4rdvH6u1cHgMNCiq(ilHg55jbV1X8ljHbkEhOtk5uQvlrrDYIQMhlc2RnYLurNOAux)JhDPs3LWm)ssyGI3b6KsoLA1kmp5O6YflcKpYsOrEEsWBDGG9AjawxaLhNPx(tuToBQO2jQgsTio)ssyGI3b6KsoLA1suuNSOQ5XIG9AjQwNnvu7evRTruOiQwNnvu7evR1X8ljHbkEhOtk5uQvR36ZkpkxoDsfu9grpc2RnYLurx1ckbW6c6sLUlHz(LKWafVd0jLCk1Qf5sI(LvEu0kze6Y8uJYkpeSxlAWLiSYJ3Z1c4K(46)h5sQORAbLayDbDPs3LWm)ssyGI3b6KsoLA1kmp5O6YflcKpYsOrEEsWBDGG9AjQwNnvu7evdPweNFZpfAGnjNbol(gytQQTKbULtkl(gO2k(aBI6MFjjmqX7C5KYIV2NXdof8Op)7db7166)EDUCszXx)e20kUgoqHkjH1GqLsynHJKJ5xscdu8oxoPS4tPwT46SQSYJsUSeQEJOhb71saSUakpotV8xtjjSgeQucRjCKqefQKewdcvkH1eoso(JgeayXaCw9Z4w5r5(fvVr0391P55xscdu8oxoPS4tPwToJBLhL7xu9grpcKpYsOrEEsWBDGG9AjawxaLhNPxMFjjmqX7C5KYIpLA1IRZQYkpk5YsO6nIEeSxlbW6cO84m9YFn56)EDMSicf8OevdTSUVouOC9FVotweHcEuIQHwgn1g5Sq6(6088tHgiYQgFGoT1AGKKhdSPbn9aZIzGwfYD(6IbgQYajQzvYAG2BGHQmWMCBckSd04d8KK5BGzXmqoGvcvR8gOQ5Pk3ab1advzG6odCw8nWLXJbQPMSnAIMhOXhy2qAUlz(LKWafVZLtkl(uQvRNXdof8Op)7dbRc5oFDb1ETEeM(jSPv82MNFjjmqX7C5KYIpLA16z8GcE0qvOovTqOH5jhcKpYsOrEEsWBDGG9AjQMgno)uOb2e5YavgGMGWaTyGoT1AGGA9nq3ts9dKn5HCFd0EdSjVfdSjayDbd04deDfgipWixsfcZ8ljHbkENlNuw8PuRwURKOh4hu9grpcKpYsOrEEsWBDGG9AjawxaLhNPxqHcnICjv0vTGsaSUGUuP7syMFjjmqX7C5KYIpLA1IRZQYkpk5YsO6nI(538tHg42kVLmWippjgytYzGZIV5xscdu8opADQA3YkpkZLEGIQZViQZVKegO4DEOuRwsjNNPnw5rLLPODiyVwIQ1ztf1or1qQfX)sjN3xpmwHgakBQisnIcfr16SPIANOAi1I2)1KuY591dJvObGYMkIeIOqHg6oPbQhHP7OhMNCuD5IvZZVKegO4DEOuRwCDwvw5rjxwcvVr0JG9AjawxaLhNPx(Rjx)3RZKfrOGhLOAOL191HcLR)71zYIiuWJsun0YOP2iNfs3xNMNFjjmqX78qPwTEgp4uWJ(8VV5NcnWMixgyt2gnzGGAGrEEsWhOtlub(Xa1wNN(bcEdmuLb2eUSKbYiU(Vhcd0EduhGZn3LGWaZIzG2BGB5KYIVbA8bMXaxsYJbI4a5cbum8bMoZV5xscdu8opuQvRZ4w5r5(fvVr0Ja5JSeAKNNe8whiyVwcaSyaoRoxoPS4RFcBAfhjhOqHgrUKk6C5KYIVUuP7syMFjjmqX78qPwToFUQvEu0kzeQtRyqWETU(Vx)85Qw5rrRKrOoTIPZaCw)tsyniuPewt4i5y(LKWafVZdLA1suuNSOQ5XIG9AjQwNnvu7evdPwhkjCUuePta1BzKGMfdLhN9KoBIwGB(LKWafVZdLA16z8GcE0qvOovTqOH5jhcKpYsOrEEsWBDGG9AjQMgno)uOb2e5YaBckpq7nWpG)aZtgil4KbgQznWMhytq1gy6m)g47aSdKnvCGzXmq1SbzGogOuc7hcdeCdmpzGSGtgyOM1aDmWMGQnW0z(nW3byhiBQ48ljHbkENhk1Qfr1OU(hpqWETevRZMkQDIQHuRJ5xscdu8opuQvlIQrDMniZpfAGnrUmqKBsgO9g4hWFG5jdeThi4gil4KbsuTbMoZVb(oa7aztfhywmdezGc7aZIzGB00MEG5jd0feQdSaXa91n)ssyGI35HsTAfMNCuD5IfbYhzj0ippj4ToqWETeaRlGYJZ0l)jQwNnvu7evdPwe)76)EDEaowQKxOsZIH(St6maN18ljHbkENhk1QfxNvLvEuYLLq1Be9iyVwx)3RtunQuY5915rs0JuJnRDfOWuscRbHkLWAc)pbW6cO84m9YFx)3RZdWXsL8cvAwm0NDsNb4S(RjcaSyaoR(zCR8OC)IQ3i67NWMwXrcX)eayXaCw9NXdof8Op)7RFcBAfhjerHIaalgGZQFg3kpk3VO6nI((jSPvCnA8pbawmaNv)z8Gtbp6Z)(6NWMwXrQX)evdPgrHIaalgGZQFg3kpk3VO6nI((jSPvCKA8pbawmaNv)z8Gtbp6Z)(6NWMwX1OX)evdj0gfkIQ1ztf1or10O1XFPKZ7RhgRqdaLnvude1mkuU(VxNOAuPKZ7RZJKOhjhn))zEQb9e20kUgA75NcnWMixgOYa0KbAVb6cc1b20GMEGzXmWMSnAYaZtgybIbswaUGWab3aBY2Ojd04dKSaCzGzXmWMg00d04dSaXajlaxgywmd8d4pq1SbzGSGtgyOM1arCGevdHbcUb20GMEGgFGKfGldSjBJMmqJpWcedKSaCzGzXmWpG)avZgKbYcozGHAwdSXbsunegi4g4hWFGQzdYazbNmWqnRbQGbsunegi4gO9g4hWFGEsmWCG6oaz(LKWafVZdLA1YDLe9a)GQ3i6rG8rwcnYZtcERdeSxlbW6cO84m9YFnf5sQOZLtkl(6sLUlH5pbawmaNvNlNuw81pHnTIRrJOqraGfdWz1pJBLhL7xu9grF)e20koso(taGfdWz1Fgp4uWJ(8VV(jSPvCKCGcfbawmaNv)mUvEuUFr1Be99tytR4A04FcaSyaoR(Z4bNcE0N)91pHnTIJuJ)jQgsiIcfbawmaNv)mUvEuUFr1Be99tytR4i14FcaSyaoR(Z4bNcE0N)91pHnTIRrJ)jQgsnIcfr1qsbOq56)EDxGEQUdq6(6088ljHbkENhk1QvyEYr1LlweiFKLqJ88KG36ab71saSUakpotV8NOAD2urTtunKArC(PqdSjYLb20B0KbMfZaTkK781fd0IbYJlnp1yGPZ8B(LKWafVZdLA16T(SYJYLtNubvVr0JGvHCNVUO1X8tHgytKlduzaAYaT3aBAqtpqJpqYcWLbMfZa)a(dunBqgiIdKOAdmlMb(b8VbUsEmqVfWnxd0zYhiYnjimqWnq7nWpG)aZtgy6c8JbgGbssDduk58(gywmduSqvUb(b8VbUsEmqpcZaDM8bICtYab3aT3a)a(dmpzGlHZhyOM1arCGevBGPZ8BGVdWoqsQtNvEZVKegO4DEOuRwURKOh4hu9grpcKpYsOrEEsWBDGG9AjawxaLhNPx(taGfdWz1Fgp4uWJ(8VV(jSPvCnA8pr1Ar8VUtAG6ry6o6H5jhvxUy)lLCEF9WyfAaOkOznCm)ssyGI35HsTA5UsIEGFq1Be9iq(ilHg55jbV1bc2RLayDbuECME5VuY591dJvObGYMkQbI)1er16SPIANOAA06afkDN0a1JW0D0dZtoQUCXQz8o9dvWH3njaGEBz4ahym]] )

end