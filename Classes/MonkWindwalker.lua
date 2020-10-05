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
    
    spec:RegisterPack( "Windwalker", 20200926, [[d40AscqisP8isPQnPu1NukOgLQQ6uQQYROu1Sqq3IuQSlj(LsrddPQJPuzzQk9mLsMgsL6AivSnLsPVPukmoLsLZPuiRtPa08uvCpeAFifhuPGSqkvEiPe1evkfDrLsvSrsj0hvkvjJuPaYjvkGALiLEjPe0mvka6MkLQu7Ku0pvka0qjLaTuLcupfjtLu4QkLQARkfa8vsjGXQuGSxs(ludg4WsTys1JjmzkUmQnRkFwsnAeDAQwnPe51QQmBLCBiTBf)w0WPuoUsHA5GEortx46sY2rGVdrJNusNhcRhPsMpLSFvwTtPHIY0bR08l9FPN(n672w2TBRTOFBOOce2yfLTw8RRzf10OSIslGpgK96hdvu2AeRSnknuuYSckyfLIsVYxXg4rPROmDWkn)s)x6PFJ(UTLD726lD2ifL0gluA(DB3iffPBm8O0vugwkuuA)b0c4JbzV(XWdS9oNFhTA)bOyBbJQZWd8DBj8aFP)l9kQLldPsdfLWGL8tPHsZDknuu806l2OStrjGEWqVvu6vVxrYqE8arXKiNdyzDGNxtgyiJ2(ipWNd8LokQweEokkFii)XyTwXJkuA(vPHIQfHNJI61Rfp4eAyOIINwFXgLDQqP5wknuuTi8Cuu65WMkzG1HmsffpT(Ink7uHst6wPHIQfHNJIcj32YrIZhoHggQO4P1xSrzNkuAshLgkkEA9fBu2POeqpyO3kQNxtgyiJ2(ipanhy32rNdyzDaTDacAO36lUqMldosZb2FarMltICkrwjiX5dB4oilqgT9rEGpepWo6(awwh451KbgYOTpYd85aBTTkQweEokQ6QgA8EW5d30fdZGufkn3wLgkkEA9fBu2POeqpyO3kkrMltICkrwjiX5dB4oilqgT9rEaAoaD2UdyzDarMltICkrwjiX5dB4oilqgT9rEGph47bSSoabn0B9fxiZLbhP5awwh451KbgYOTpYd85aFPxr1IWZrrHmHldbSpyilZPhbRcLMBdLgkkEA9fBu2POeqpyO3kkbPxqBTEaT7acs)a0q8a7oW(dWddRruchLXrIrBTEaAiEa6l0rr1IWZrr1qrpmosiKNqfkn3oLgkkEA9fBu2POAr45OOwvYaMvsCDUm8GTTQq7AwrjGEWqVvuImxMe5uISsqIZh2WDqwGmA7J8aFoWUdyzDarMltICkrwjiX5dB4oilqgT9rEaAoWx6pGL1biOHERV4czUm4inhWY6apVMmWqgT9rEGpepWx6vutJYkQvLmGzLexNldpyBRk0UMvHsZnsPHIINwFXgLDkQweEokQ6vB8osOeJYMET8CuucOhm0BfLiZLjroLiReK48HnChKfiJ2(ipWNdS7awwhqK5YKiNsKvcsC(WgUdYcKrBFKhGMd8L(dyzDacAO36lUqMldosZbSSoWZRjdmKrBFKh4dXd8LEff)ESiWtJYkQ6vB8osOeJYMET8CuHsZD0R0qrXtRVyJYofvlcphfv9QnEhjuIzu9fJQOeqpyO3kQNxtgyiJ2(ipanhyhD2OdyzDarMltICkrwjiX5dB4oilqgT9rEGphy3bSSoabn0B9fxiZLbhPrrXVhlc80OSIQE1gVJekXmQ(IrvHsZD7uAOO4P1xSrzNIsa9GHERO02biOHERV4czUm4inhy)b()aA7a8gx52SXMIaHyLbmhxG1xTmoGL1bezUmjYPiqiwzaZXfy9vlJcKrBFKh4dXdS7a)DG9h4)dii9dqZb2DalRdWddRrCGphGUP)a)POAr45OOISsqIZh2WDqQcLM7(Q0qrXtRVyJYofLa6bd9wrjYCzsKtrgjefZnmiX9yWphYfbzdRz5biEGVhWY6aMmkrwjiX5dB4oilqgT9rEalRd88AYadz02h5b(CGV0FalRd8)b0REVcYeUmeW(GHSmNEeCbYOTpYdqZb2r)bSSoGiZLjrofKjCziG9bdzzo9i4cKrBFKhGMdiYCzsKtrgjefZnmiX9yWphYLx1AHHSGSH1moCu(awwhqBhGLsEeCbzcxgcyFWqwMtpcUG2APeEG)oW(d8)bezUmjYPezLGeNpSH7GSaz02h5bO5aImxMe5uKrcrXCddsCpg8ZHC5vTwyiliBynJdhLpGL1biOHERV4czUm4inhy)b02b4nUYTzJnfd011x(uJ95NT0CG)oW(diYCzsKt55YqIZh(vbruGmA7J8aFiEGn6a7pGG0panepWwhy)bezUmjYPGK0HlFQXgyxNd2w1iilqgT9rEGpepWUTuuTi8CuuYiHOyUHbjUhd(5qwfkn3TLsdffpT(Ink7uucOhm0Bf1ZRjdmKrBFKhGMdSJoB0bSSoGjJsKvcsC(WgUdYcKrBFKhWY6ae0qV1xCHmxgCKgfvlcphfvKvcsC(W)AiARcLM7OBLgkkEA9fBu2POeqpyO3kkrMltICkrwjiX5dB4oilqgT9rEaAoaDtNdyzDacAO36lUqMldosZb2FarMltICkpxgsC(WVkiIcKrBFKh4Zb(EalRd88AYadz02h5b(CGDFpGL1bEEnzGHmA7J8a0CGD0t)b2FGNxtgyiJ2(ipWNdSBh9hy)b()aImxMe5uEUmK48HFvqefiJ2(ipWNdS1bSSoGiZLjrofKKoC5tn2a76CW2QgbzbYOTpYd85a05awwhqK5YKiNc0L(uJLvd(Nl(vGmA7J8aFoaDoWFkQweEokk9vMgC(WbjJ5HrrOcLM7OJsdffpT(Ink7uucOhm0BfL2oGjJIihbpbSd2GFRgLX6vWPaz02h5b2FG)pW)hqK5YKiNIihbpbSd2GFRgLlqgT9rEGpepGiZLjroLiReK48HnChKfiJ2(ipG9hy3bSSoabn0B9fxiZLbhP5a)DG9h4)dOTde9INOGK0HlFQXgyxNd2w1iil806l2CalRdiYCzsKtbjPdx(uJnWUohSTQrqwGmA7J8a)DG9hqK5YKiNc0L(uJLvd(Nl(vGmA7J8a7pGiZLjroLNldjoF4xferbYOTpYdS)a6vVxrgjefZnmiX9yWphYftICoGL1bmzuISsqIZh2WDqwGmA7J8a)DalRd88AYadz02h5b(CGTtr1IWZrrjYrWta7Gn43QrzvO0C32Q0qrXtRVyJYofLa6bd9wrjYCzsKtjYkbjoFyd3bzbYOTpYdqZb2I(dyzDacAO36lUqMldosZbSSoWZRjdmKrBFKh4Zb(sVIQfHNJIsFLPb)QGiuHsZDBdLgkkEA9fBu2POeqpyO3kkrMltICkrwjiX5dB4oilqgT9rEaAoWw0FalRdqqd9wFXfYCzWrAoGL1bEEnzGHmA7J8aFoWo6OOAr45OO0zOKH)8Pwfkn3TDknuuTi8CuulVMmKyTuLPgLNqrXtRVyJYovO0C3gP0qrXtRVyJYofLa6bd9wrjYCzsKtjYkbjoFyd3bzbYOTpYdqZb2I(dyzDacAO36lUqMldosZbSSoWZRjdmKrBFKh4Zb2rVIQfHNJI65qwFLPrfkn)sVsdffpT(Ink7uucOhm0BfLiZLjroLiReK48HnChKfiJ2(ipanhyl6pGL1biOHERV4czUm4inhWY6apVMmWqgT9rEGph4l9kQweEokQEeSmG9cl61sfkn)UtPHIQfHNJIsVRX5dhqx8tQO4P1xSrzNkuA(9RsdffpT(Ink7uuTi8Cuu2sXpoKoDXgSirTvfD45GnmbUGvucOhm0BfLiZLjroLiReK48HnChKfiJ2(ipanhyl6pGL1biOHERV4czUm4inkQPrzfLTu8JdPtxSblsuBvrhEoydtGlyvO087wknuu806l2OStr1IWZrrbz0myCDLB6rWydtGlyfLa6bd9wrjYCzsKtjYkbjoFyd3bzbYOTpYdqZb2I(dyzDacAO36lUqMldosJIAAuwrbz0myCDLB6rWydtGlyvO08lDR0qrXtRVyJYofvlcphfv9QnEhjuI1BtnROeqpyO3kkrMltICkrwjiX5dB4oilqgT9rEaAoWx6pGL1biOHERV4czUm4inhWY6apVMmWqgT9rEGph4l9kk(9yrGNgLvu1R24DKqjwVn1SkuA(Loknuu806l2OStr1IWZrrv3lw0RfdLy9mhfLa6bd9wrjYCzsKtjYkbjoFyd3bzbYOTpYdqZbOdDoGL1biOHERV4czUm4inhWY6apVMmWqgT9rEGphy3xf10OSIQUxSOxlgkX6zoQqP53TvPHIINwFXgLDkQweEokkKqpi9Pgl5AuEcC(WgilJUUdsfLa6bd9wrjYCzsKtjYkbjoFyd3bzbYOTpYdqZb(s)bSSoabn0B9fxiZLbhPrrnnkROqc9G0NASKRr5jW5dBGSm66oivHsZVBdLgkkEA9fBu2POAr45OOAjjb9WsmSPReIfjSxkkb0dg6TIIGg6T(IlrAW5GRKmoG(8JJdS)a)FarMltICkrwjiX5dB4oilqgT9rEaAoW3DhWY6ae0qV1xCHmxgCKMd83b2FG)pGH1REVcSPReIfjSxydRx9EftICoGL1b0REVImsikMByqI7XGFoKlqgT9rEaAoWUToGL1bEEnzGHmA7J8aA3bezUmjYPezLGeNpSH7GSaz02h5b(Ca6M(dS)aImxMe5uISsqIZh2WDqwGmA7J8aFoWx6CalRd88AYadz02h5b(CGV05a)POMgLvuTKKGEyjg20vcXIe2lvO0872P0qrXtRVyJYofvlcphfvljjOhwIHnDLqSiH9srjGEWqVvuA7ae0qV1xCjsdohCLKXb0NFCCG9h4)dyy9Q3RaB6kHyrc7f2W6vVxXKiNdyzDG)pG2oaVXvUnBSPyGUU(YNASp)SLMdyzDGOH1CuchLXrITjc8w0FGphy7oWFhy)b()aMmkrwjiX5dB4oilqgT9rEalRdiYCzsKtjYkbjoFyd3bzbYOTpYdy)b2OdqZbEEnzGHmA7J8a)DG9hqV69kYiHOyUHbjUhd(5qUuz7awwh451KbgYOTpYd85aFPZb(trnnkROAjjb9WsmSPReIfjSxQqP53nsPHIQfHNJIkizC1ONvJb)sOGvu806l2OStfkn3IELgkQweEokkBvq)HWNAS(QLHIINwFXgLDQqP5w7uAOO4P1xSrzNIsa9GHERO0REVIKH84bIIjrohy)b()ardR5OeokJJeBte4V0FaAoWw0FalRdenSMJcj3RGSyteh4dXd8L(d83bSSoq0WAokHJY4iXgNpWNd8vr1IWZrrb52Mp143QrzPkuAU1xLgkQweEokQxkQKSb30fd9GX6CJQO4P1xSrzNkuAU1wknuu806l2OStrjGEWqVvu8WWAeh4ZbOB6vuTi8CuuOmAcrGZhEvjCd2a5gvQcLMBr3knuuTi8Cuuq3MTfJ9blT1cwrXtRVyJYovO0Cl6O0qr1IWZrrP3148HdOl(jvu806l2OStfkn3ABvAOO4P1xSrzNIsa9GHERO()a8gx52SXMIaHyLbmhxG1xTmoW(diYCzsKtrGqSYaMJlW6RwgfiJ2(ipWhIh4l9h4VdyzDaTDaEJRCB2ytrGqSYaMJlW6RwgkQweEokQkjJ9GrLQqfkkd)6QvO0qP5oLgkkEA9fBu2POsBkkjhkQweEokkcAO36lwrrqVQyfLiZLjroLiReK48HnChKfiJ2(ipG9hyJoanhiAynhLWrzCKyJZhWY6aA7arV4jksgYJhik806l2CG9hqBhGGg6T(IlrAW5GRKmoG(8JJdS)a8gx52SXMIb666lFQX(8ZwAoW(denSMJs4OmosSnrG3I(d85a72I(dS)ardR5OeokJJeBte4TO)a0CGT7awwh451KbgYOTpYd85a72I(dS)apVMmWqgT9rEaAoGiZLjrofjd5XdefiJ2(ipW(diYCzsKtrYqE8arbYOTpYdqZb(EalRdOx9Efjd5XdeLkBhy)bEEnzGHmA7J8a0CGD7uue0q80OSIImxgCKgvO08RsdfvlcphfL0g3qmzpgSmG(pwrXtRVyJYovO0ClLgkkEA9fBu2POeqpyO3kk9Q3RizipEGOuz7awwhqV69kYiHOyUHbjUhd(5qUuz7a7pGjJsKvcsC(WgUdYcKrBFKhWY6apVMmWqgT9rEGpepW2sVIQfHNJIYwgEoQqPjDR0qrXtRVyJYofLa6bd9wrji9cAR1dODhqq6hGgIh47b2FG)pq0lEIIKH84bIcpT(InhWY6aA7aMmkrwjiX5dB4oilqgT9rEG)oW(dOx9Efjd5XdeftICoW(d8)b4HH1ikHJY4iXOTwpWNdS7awwhi6fprrYqE8arHNwFXMdS)aImxMe5uKmKhpquGmA7J8aFoW3dyzDaTDGOx8efjd5XdefEA9fBoW(diYCzsKtjYkbjoFyd3bzbYOTpYd85aBDG9hqBhGGg6T(IlK5YGJ0CalRdWddRruchLXrIrBTEGphGUpW(diYCzsKt55YqIZh(vbruGmA7J8aFoWUcDoWFkQweEokkitadLmMSHOQqPjDuAOOAr45OOEnV8HXYirTPO4P1xSrzNkuAUTknuu806l2OStr1IWZrr9CzGZhoizmsspyC41murjGEWqVvucsVG2A9aA3beK(bOH4b26a7pGE17vKmKhpqumjY5a7pGE17vKmhK(uJHDnxmjY5a7pW)hGhgwJOeokJJeJ2A9aFoWUdyzDGOx8efjd5XdefEA9fBoW(diYCzsKtrYqE8arbYOTpYd85aFpGL1b02bIEXtuKmKhpqu4P1xS5a7pGiZLjroLiReK48HnChKfiJ2(ipWNdS1b2FaTDacAO36lUqMldosZbSSoapmSgrjCughjgT16b(Ca6(a7pGiZLjroLNldjoF4xferbYOTpYd85a7k05a)POeielghnSMdPsZDQqP52qPHIINwFXgLDkQweEokQWRzi2wVqvucOhm0BfL2oGir1tSoK7Fhy)beKEbT16b0Udii9dqdXd89a7pW)hi6fprrYqE8arHNwFXMdyzDaTDatgLiReK48HnChKfiJ2(ipGL1bAr4eWyEyuNLhGMd89a)DG9hqV69ksMdsFQXWUMlMe5CG9hqV69ksgYJhikMe5CG9h4)dWddRruchLXrIrBTEGphy3bSSoq0lEIIKH84bIcpT(Inhy)bezUmjYPizipEGOaz02h5b(CGVhWY6aA7arV4jksgYJhik806l2CG9hqK5YKiNsKvcsC(WgUdYcKrBFKh4Zb26a7pG2oabn0B9fxiZLbhP5awwhGhgwJOeokJJeJ2A9aFoaDFG9hqK5YKiNYZLHeNp8RcIOaz02h5b(CGDf6CG)uuceIfJJgwZHuP5ovO0C7uAOO4P1xSrzNIsa9GHERO02bIEXtuEUmW5dhKmgjPhmo8Agw4P1xS5a7pGnitaUwyk7kHxZqSTEHEG9hiCu(aFiEGTuuTi8CuucshJSjGvHsZnsPHIINwFXgLDkkb0dg6TIk6fprrYqE8arHNwFXgfvlcphfLOxlClcph8YLHIA5YapnkROegSKH84bcvO0Ch9knuu806l2OStrjGEWqVvuA7arV4jksgYJhik806l2OOAr45OOe9AHBr45GxUmuulxg4PrzfLWGL8tfkn3TtPHIINwFXgLDkkb0dg6TIsV69ksgYJhikv2uuTi8CuuIETWTi8CWlxgkQLld80OSIsYqE8aHkuAU7RsdffpT(Ink7uucOhm0BfvlcNagZdJ6S8aFoWwkQweEokkrVw4weEo4Lldf1YLbEAuwrjdvO0C3wknuu806l2OStrjGEWqVvuTiCcympmQZYdqdXdSLIQfHNJIs0RfUfHNdE5YqrTCzGNgLvuDYQqfkkBqwKO6DO0qP5oLgkQweEokkBz45OO4P1xSrzNkuA(vPHIINwFXgLDkQ0MIsYHIQfHNJIIGg6T(Ivue0RkwrXBCLBZgBkceIvgWCCbwF1Y4awwhG34k3Mn2uwvYaMvsCDUm8GTTQq7A(awwhG34k3Mn2uQxTX7iHsSEBQ5dyzDaEJRCB2ytPE1gVJekXOSPxlpNdyzDaEJRCB2ytbYOzW46k30JGXgMaxWkkcAiEAuwrfPbNdUsY4a6ZpouHsZTuAOO4P1xSrzNIkTPOKCOOAr45OOiOHERVyffb9QIvu72ifLa6bd9wrPTde9INOizipEGOWtRVyZb2FG)pabn0B9fxI0GZbxjzCa95hhhWY6a8gx52SXMsljjOhwIHnDLqSiH96a)POiOH4Przf1lNaNpSTejdX2GSir17ali7z4LkuAs3knuu806l2OStrnnkROA6ss2WwIF5e48HTLizOIQfHNJIQPljzdBj(LtGZh2wIKHQqPjDuAOO4P1xSrzNIsa9GHERO02bIEXtuKmKhpqu4P1xS5awwhqBhi6fpr55YaNpCqYyKKEW4WRzyHNwFXgfvlcphfLG0X6vqzOcLMBRsdffpT(Ink7uucOhm0Bfv0lEIYZLboF4GKXij9GXHxZWcpT(InhWY6aSuYJGlICElxe4Emyza9hxqBTucvuTi8CuucshJSjGvHsZTHsdfvlcphfLpeK)ySwR4rrXtRVyJYovO0C7uAOOAr45OOQRAOX7bNpCtxmmdsffpT(Ink7uHkuuDYknuAUtPHIQfHNJIcjPdx(uJnWUohSTQrqQO4P1xSrzNkuA(vPHIINwFXgLDkkb0dg6TIsBhWgKjaxlmLDLWRzi2wVqpW(dii9d8H4b2DG9hGhgwJ4aFoaDOxr1IWZrrXddRD6YNAmVCT6qvO0ClLgkkEA9fBu2POeqpyO3kkEyynIs4OmosmAR1dqZb2DalRdS4AEmnerrRv8iX6DelUMByHNwFXMdS)aImxMe5uGU0NASSAW)CXVcKrBFKh4ZbAr45uEUmK48HFvqefrlJdy)bOJIQfHNJI65YqIZh(vbrOcLM0TsdffpT(Ink7uuTi8Cuuqx6tnwwn4FU4NIsa9GHERO()arV4jkijD4YNASb215GTvncYcpT(Inhy)bezUmjYPaDPp1yz1G)5IFftfSdpNdqZbezUmjYPGK0HlFQXgyxNd2w1iilqgT9rEa7paDFG)oW(d8)bezUmjYP8CziX5d)QGikqgT9rEaAoWwhWY6acs)a0q8a05a)POeielghnSMdPsZDQqPjDuAOO4P1xSrzNIsa9GHERO0REVcSss6tnwl1ggJ0htXKihfvlcphffSss6tnwl1ggJ0hJkuAUTknuu806l2OStrjGEWqVvuIevpXYa6)4dS)a)FG)pW)hqq6hGMdS1bSSoGiZLjroLNldjoF4xferbYOTpYdqZb22d83b2FG)pGG0panepaDoGL1bezUmjYP8CziX5d)QGikqgT9rEaAoW3d83b(7awwhGhgwJOeokJJeJ2A9aFiEGToGL1b0REVIPhbJZhwq6AjVa5weh4pfvlcphfL0MpJp1ybShg)Zf)uHsZTHsdffpT(Ink7uucOhm0BfLG0lOTwpG2DabPFaAiEGVkQweEokkitadLmMSHOQqP52P0qrXtRVyJYofLa6bd9wrji9cAR1dODhqq6hGgIhylfvlcphfLG0X6vqzOcLMBKsdffpT(Ink7uuTi8Cuupxg48HdsgJK0dghEndvucOhm0BfLG0lOTwpG2DabPFaAiEGTuuceIfJJgwZHuP5ovO0Ch9knuu806l2OStr1IWZrrfEndX26fQIsa9GHEROeKEbT16b0Udii9dqdXd89a7pW)hqBhi6fprH0dSir1ZcpT(InhWY6aA7aIevpX6qU)DG)uuceIfJJgwZHuP5ovO0C3oLgkkEA9fBu2POeqpyO3kkTDarIQNyDi3)uuTi8CuucshJSjGvHsZDFvAOO4P1xSrzNIQfHNJI6Tq4tnwYqB8e4FU4NIsa9GHERO0REVIE(dBdMIIjrokkFcgcRSfkQDQqP5UTuAOO4P1xSrzNIQfHNJIsF1IFzvG)5IFkkb0dg6TIsKO6jwgq)hFG9h4)dOx9Ef98h2gmfLkBhWY6a)FGOx8efspWIevpl806l2CG9hWgKjaxlmLDLWRzi2wVqpW(dii9d85a09b(7a)POeielghnSMdPsZDQqP5o6wPHIINwFXgLDkkb0dg6TIsKO6jwgq)hROAr45OOK28z8PglG9W4FU4NkuHIsyWsgYJhiuAO0CNsdffpT(Ink7uucOhm0BfLE17vKmKhpqumjY5awwh451KbgYOTpYd85aFPJIQfHNJIYhcYFmwRv8OcLMFvAOOAr45OOE9AXdoHggQO4P1xSrzNkuAULsdfvlcphfLEoSPsgyDiJurXtRVyJYovO0KUvAOOAr45OOqYTTCK48HtOHHkkEA9fBu2PcLM0rPHIINwFXgLDkQweEokQMUKKnSL4xoboFyBjsgQOeqpyO3kk9Q3RizipEGOysKZb2FG)pGiZLjrofjd5XdefiJ2(ipWNd8L(dyzDGNxtgyiJ2(ipWNdq30FG)uutJYkQMUKKnSL4xoboFyBjsgQcLMBRsdffpT(Ink7uucOhm0BfLE17vKmKhpqumjY5a7pW)h451KbgYOTpYdqZb2TD05awwhqK5YKiNIKH84bIcKrBFKh4dXdSnoWFhWY6apVMmWqgT9rEGphyl6OOAr45OOQRAOX7bNpCtxmmdsvO0CBO0qrXtRVyJYofLa6bd9wrjYCzsKtrYqE8arbYOTpYdqZb(s)bSSoWZRjdmKrBFKh4Zb(sVIQfHNJIsFLPb)QGiuHsZTtPHIINwFXgLDkkb0dg6TIsK5YKiNIKH84bIcKrBFKhGMd8L(dyzDGNxtgyiJ2(ipWNdSJokQweEokkDgkz4pFQvHsZnsPHIINwFXgLDkkb0dg6TIsV69ksgYJhikMe5CG9hqq6f0wRhq7oGG0panepWUdS)a8WWAeLWrzCKy0wRhGgIhG(cDuuTi8Cuunu0dJJec5juHsZD0R0qr1IWZrrT8AYqI1svMAuEcffpT(Ink7uHsZD7uAOO4P1xSrzNIsa9GHEROezUmjYPizipEGOaz02h5bO5aFP)awwh451KbgYOTpYd85a7Oxr1IWZrr9CiRVY0OcLM7(Q0qrXtRVyJYofLa6bd9wrjYCzsKtrYqE8arbYOTpYdqZb(s)bSSoWZRjdmKrBFKh4Zb(sVIQfHNJIQhbldyVWIETuHsZDBP0qr1IWZrrP3148HdOl(jvu806l2OStfkn3r3knuu806l2OStr1IWZrrTQKbmRK46Cz4bBBvH21SIsa9GHEROezUmjYPezLGeNpSH7GSaz02h5b(CGDhWY6aImxMe5uISsqIZh2WDqwGmA7J8a0CGV0FalRdqqd9wFXfYCzWrAoGL1bEEnzGHmA7J8aFiEGV0ROMgLvuRkzaZkjUoxgEW2wvODnRcLM7OJsdffpT(Ink7uuTi8Cuu1R24DKqjgLn9A55OOeqpyO3kkrMltICkrwjiX5dB4oilqgT9rEGphy3bSSoGiZLjroLiReK48HnChKfiJ2(ipanh4l9hWY6ae0qV1xCHmxgCKMdyzDGNxtgyiJ2(ipWhIh4l9kk(9yrGNgLvu1R24DKqjgLn9A55OcLM72wLgkkEA9fBu2POAr45OOQxTX7iHsmJQVyufLa6bd9wr98AYadz02h5bO5a7OZgDalRdiYCzsKtjYkbjoFyd3bzbYOTpYd85a7oGL1biOHERV4czUm4inkk(9yrGNgLvu1R24DKqjMr1xmQkuAUBBO0qrXtRVyJYofLa6bd9wrPTdqqd9wFXfYCzWrAuuTi8CuurwjiX5dB4oivHsZDBNsdffpT(Ink7uucOhm0Bf1ZRjdmKrBFKhGMdSJoB0bSSoGjJsKvcsC(WgUdYcKrBFKhWY6ae0qV1xCHmxgCKgfvlcphfvKvcsC(W)AiARcLM72iLgkkEA9fBu2POAr45OOSLIFCiD6InyrIARk6WZbBycCbROeqpyO3kk9Q3RizipEGOysKZb2FG)pGiZLjroLiReK48HnChKfiJ2(ipanhyh9hWY6ae0qV1xCHmxgCKMd83bSSoWZRjdmKrBFKh4ZbOJIAAuwrzlf)4q60fBWIe1wv0HNd2We4cwfkn)sVsdffpT(Ink7uucOhm0BfLE17vKmKhpqumjY5a7pW)hqK5YKiNIKH84bIcKrBFKhGMd8L(dyzDarMltICksgYJhikqgT9rEGph47b(7awwh451KbgYOTpYd85a7OJIQfHNJIsFLPbNpCqYyEyueQqP53Dknuu806l2OStr1IWZrrbz0myCDLB6rWydtGlyfLa6bd9wrjYCzsKtjYkbjoFyd3bzbYOTpYdqZb2r)bSSoabn0B9fxiZLbhPrrnnkROGmAgmUUYn9iySHjWfSkuA(9RsdffpT(Ink7uuTi8Cuu1R24DKqjwVn1SIsa9GHEROezUmjYPizipEGOaz02h5bO5aFP)awwh451KbgYOTpYd85aFPxrXVhlc80OSIQE1gVJekX6TPMvHsZVBP0qrXtRVyJYofvlcphfvDVyrVwmuI1ZCuucOhm0BfLiZLjrofjd5XdefiJ2(ipanh4l9hWY6apVMmWqgT9rEGph4l9kQPrzfvDVyrVwmuI1ZCuHsZV0TsdffpT(Ink7uuTi8CuuiHEq6tnwY1O8e48HnqwgDDhKkkb0dg6TIsK5YKiNsKvcsC(WgUdYcKrBFKhGMdSJ(dyzDacAO36lUqMldosJIAAuwrHe6bPp1yjxJYtGZh2azz01DqQcLMFPJsdffpT(Ink7uuTi8CuuTKKGEyjg20vcXIe2lfLa6bd9wrzy9Q3RaB6kHyrc7f2W6vVxXKiNdyzDa9Q3RizipEGOaz02h5bO5aB0bSSoWZRjdmKrBFKh4Zb(shf10OSIQLKe0dlXWMUsiwKWEPcLMF3wLgkkEA9fBu2POeqpyO3kk9Q3RizipEGOysKZb2FG)pGiZLjrofjd5XdefiJ2(ipanhyhDoGL1bezUmjYPizipEGOaz02h5b(CGVh4VdyzDGNxtgyiJ2(ipWNd8LEfvlcphffYeUmeW(GHSmNEeSkuA(DBO0qrXtRVyJYofLa6bd9wrPx9Efjd5XdeftICoW(d8)bezUmjYPizipEGOaz02h5bSSoGiZLjrofrocEcyhSb)wnkxeKnSMLhG4b(EG)oW(dOTdyYOiYrWta7Gn43QrzSEfCkqgT9rEG9h4)diYCzsKtb6sFQXYQb)Zf)kqgT9rEG9hqK5YKiNYZLHeNp8RcIOaz02h5bSSoWZRjdmKrBFKh4Zb2Ud8NIQfHNJIsKJGNa2bBWVvJYQqP53TtPHIQfHNJIsYqE8aHIINwFXgLDQqP53nsPHIINwFXgLDkkb0dg6TIsV69ksgYJhikMe5OOAr45OOcsgxn6z1yWVekyvO0Cl6vAOO4P1xSrzNIsa9GHERO0REVIKH84bIIjrokQweEokkBvq)HWNAS(QLHkuAU1oLgkkEA9fBu2POeqpyO3kk9Q3RizipEGOysKZb2FG)pq0WAokHJY4iX2eb(l9hGMdSf9hWY6ardR5OqY9kil2eXb(q8aFP)a)DalRdenSMJs4OmosSX5d85aFvuTi8CuuqUT5tn(TAuwQcLMB9vPHIINwFXgLDkkb0dg6TIsV69ksgYJhikMe5OOAr45OOEPOsYgCtxm0dgRZnQkuAU1wknuu806l2OStrjGEWqVvu6vVxrYqE8arXKiNdS)a8WWAeh4ZbOB6vuTi8CuuOmAcrGZhEvjCd2a5gvQcLMBr3knuu806l2OStrjGEWqVvu6vVxrYqE8arXKihfvlcphff0TzBXyFWsBTGvHsZTOJsdffpT(Ink7uucOhm0BfLE17vKmKhpqumjYrr1IWZrrP3148HdOl(jvHsZT2wLgkkEA9fBu2POeqpyO3kk9Q3RizipEGOysKZb2FG)pW)hG34k3Mn2ueieRmG54cS(QLXb2FarMltICkceIvgWCCbwF1YOaz02h5b(q8aFP)a)DalRdOTdWBCLBZgBkceIvgWCCbwF1Y4a)POAr45OOQKm2dgvQcvOOKHsdLM7uAOOAr45OOqs6WLp1ydSRZbBRAeKkkEA9fBu2PcLMFvAOO4P1xSrzNIsa9GHEROIEXtuKmKhpqu4P1xS5awwhqK5YKiNsKvcsC(WgUdYcKrBFKhGMdSThWY6ae0qV1xCHmxgCKgfvlcphf1ZLHeNp8RcIqfkn3sPHIINwFXgLDkQweEokkOl9PglRg8px8trjGEWqVvurV4jksgYJhik806l2CalRdiYCzsKtjYkbjoFyd3bzbYOTpYdqZb(EalRdqqd9wFXfYCzWrAuuceIfJJgwZHuP5ovO0KUvAOO4P1xSrzNIsa9GHERO0REVcSss6tnwl1ggJ0htXKiNdS)aTiCcympmQZYdqZb2POAr45OOGvssFQXAP2WyK(yuHst6O0qrXtRVyJYofLa6bd9wrji9cAR1dODhqq6hGMdStr1IWZrrbzcyOKXKnevfkn3wLgkkEA9fBu2POAr45OOEUmW5dhKmgjPhmo8AgQOeqpyO3kkbPFGphylfLaHyX4OH1CivAUtfkn3gknuu806l2OStrjGEWqVvucs)aFiEGToW(dWddRrCGphGo0ROAr45OO4HH1oD5tnMxUwDOkuAUDknuu806l2OStrjGEWqVvucsVG2A9aA3beK(bO5a0FG9hOfHtaJ5HrDwEaIhy3bSSoGG0lOTwpG2DabPFaAoWofvlcphfLG0X6vqzOcLMBKsdffpT(Ink7uuTi8CuuHxZqSTEHQOeqpyO3kkrIQNyza9F8b2FabPxqBTEaT7acs)a0CGToW(dOTdyYOezLGeNpSH7GSaz02h5b2Fa9Q3RiJeII5ggK4Em4Nd5IjrokkbcXIXrdR5qQ0CNkuAUJELgkQweEokkbPJr2eWkkEA9fBu2PcLM72P0qrXtRVyJYofLa6bd9wrjsu9eldO)JpW(dOx9EftpcgNpSG01sEbYTiuuTi8CuusB(m(uJfWEy8px8tfkn39vPHIINwFXgLDkQweEokk9vl(Lvb(Nl(POeqpyO3kkrIQNyza9F8b2FG)pW)hi6fprrYqE8arHNwFXMdyzDarMltICkrwjiX5dB4oilqgT9rEaAoW3dyzDacAO36lUqMldosZb(7a7pW)hqK5YKiNc0L(uJLvd(Nl(vGmA7J8a0CGVhy)bezUmjYP8CziX5d)QGikqgT9rEaAoW3dyzDarMltICkqx6tnwwn4FU4xbYOTpYd85aBDG9hqK5YKiNYZLHeNp8RcIOaz02h5bO5aBDG9hqq6hGMd89awwhqK5YKiNc0L(uJLvd(Nl(vGmA7J8a0CGToW(diYCzsKt55YqIZh(vbruGmA7J8aFoWwhy)beK(bO5a09bSSoGG0panhGoh4VdyzDa9Q3RON)W2GPOuz7a)POeielghnSMdPsZDQqP5UTuAOO4P1xSrzNIQfHNJIk8AgIT1lufLa6bd9wrjsu9eldO)JpW(dii9cAR1dODhqq6hGMdStrjqiwmoAynhsLM7uHsZD0TsdfLpbdHv2cf1ofvlcphf1BHWNASKH24jW)CXpffpT(Ink7uHsZD0rPHIINwFXgLDkQweEokk9vl(Lvb(Nl(POeqpyO3kkrIQNyza9F8b2FG)pGiZLjroLNldjoF4xferbYOTpYd85aBDG9hqq6hG4b(EalRdWddRruchLXrIrBTEGphy3b(7a7pW)hWgKjaxlmLDLWRzi2wVqpGL1beKEbT16b0Udii9d85aFpWFkkbcXIXrdR5qQ0CNkuHIsYqE8aHsdLM7uAOO4P1xSrzNIsa9GHERO0REVIKH84bIcKrBFKh4Zb2DalRd0IWjGX8WOolpanhyNIQfHNJI65YqIZh(vbrOcLMFvAOO4P1xSrzNIsa9GHEROejQEILb0)Xhy)b()aTiCcympmQZYdqZb(EalRd0IWjGX8WOolpanhy3b2FaTDarMltICkqx6tnwwn4FU4xPY2b(tr1IWZrrjT5Z4tnwa7HX)CXpvO0ClLgkkEA9fBu2POAr45OOGU0NASSAW)CXpfLa6bd9wrjsu9eldO)JvuceIfJJgwZHuP5ovO0KUvAOO8jyiSYwG9NIQwykqgT9rsKEfvlcphf1ZLHeNp8RcIqrXtRVyJYovO0Koknuu806l2OStr1IWZrr9CzGZhoizmsspyC41murjGEWqVvucs)aFoWwkkbcXIXrdR5qQ0CNkuAUTknuu806l2OStrjGEWqVvucsVG2A9aA3beK(bO5a7oW(dWddRruchLXrIrBTEGphyNIQfHNJIcYeWqjJjBiQkuAUnuAOO4P1xSrzNIQfHNJIsF1IFzvG)5IFkkb0dg6TIsKO6jwgq)hFalRdOTde9INOq6bwKO6zHNwFXgfLaHyX4OH1CivAUtfkn3oLgkQweEokkPnFgFQXcypm(Nl(PO4P1xSrzNkuHkuueWqPNJsZV0)LE63UVFvuiB44tTurPfydTbR5gyn3ETb8ahqds(aoQTegh4LWdSHfgSKFB4da5nUYHS5aYeLpqxfjAhS5acYEQzz5ODdqF4d8D72aEaTCoeWWGnhydhokJJeBte4nOnOcKrBFKB4de5b2WHJY4iX2ebEdAdAdFG)3P1)khThTAb2qBWAUbwZTxBapWb0GKpGJAlHXbEj8aByd)6QvSHpaK34khYMditu(aDvKODWMdii7PMLLJ2na9HpWUnGhqlNdbmmyZb2WHJY4iX2ebEdAdQaz02h5g(arEGnC4OmosSnrG3G2G2Wh4)VA9VYr7r7gyuBjmyZb2ghOfHNZbwUmKLJwfvxfKjurTbI)5lxrzdMpFXkkT)aAb8XGSx)y4b2ENZVJwT)auSTGr1z4b(UTeEGV0)L(J2JwT)aBpALfvbBoGo)siFarIQ3Xb05AFKLdSHec2wipWKJ2r2q0x16aTi8CKhiNfIYrR2FGweEoYInilsu9oi(wT83rR2FGweEoYInilsu9oSN4MVmnhTA)bAr45il2GSir17WEIB2v1O8eD45C0Q9hGAABsYmoaSDZb0REp2Caz0H8a68lH8bejQEhhqNR9rEGEmhWgK1oBze(uFaxEatoC5Ov7pqlcphzXgKfjQEh2tCt502KKzGLrhYJ2weEoYInilsu9oSN4M2YWZ5Ov7pGwMKf)KhWFharwDaYMa(a9bcOp)44a8gx52SXMdeKDCaK9eYde5b05dujzZbISMdsgEaKEqEanYT5rBlcphzXgKfjQEh2tCtcAO36lMWPrzIrAW5GRKmoG(8JdctBeLCqib9QIjYBCLBZgBkceIvgWCCbwF1YWYI34k3Mn2uwvYaMvsCDUm8GTTQq7A2YI34k3Mn2uQxTX7iHsSEBQzllEJRCB2ytPE1gVJekXOSPxlphllEJRCB2ytbYOzW46k30JGXgMaxWhTA)b2aqd9wFXhii74ai916abVwharwDa)Daez1bq6R1bgMnhiYdGS94arEarlJdOrUn30KhyY4ai7joqKhq0Y4aECGooqVwhOheOjKpABr45iTN4Me0qV1xmHtJYejZLbhPHW0grjhesqVQyIImxMe5uISsqIZh2WDqwGmA7J0(nIMOH1CuchLXrInoBzPTOx8efjd5XdefEA9fB2RncAO36lUePbNdUsY4a6Zpo2ZBCLBZgBkgORRV8Pg7ZpBPzF0WAokHJY4iX2ebEl6lqgT9r(z3w0VpAynhLWrzCKyBIaVf9fiJ2(iPz7SSEEnzGHmA7J8ZUTOF)ZRjdmKrBFK0iYCzsKtrYqE8arbYOTpY9ImxMe5uKmKhpquGmA7JKMVww6vVxrYqE8arPY2(NxtgyiJ2(iPz3UJ2weEoYInilsu9oSN4Me0qV1xmHtJYeF5e48HTLizi2gKfjQEhybzpdVimTruYbHe0RkM4UnIq)ruBrV4jksgYJhik806l2S)FcAO36lUePbNdUsY4a6ZpoSS4nUYTzJnLwssqpSedB6kHyrc71FhTTi8CKfBqwKO6DypXnRKm2dgLWPrzInDjjBylXVCcC(W2sKm8OTfHNJSydYIevVd7jUPG0X6vqzqO)iQTOx8efjd5XdefEA9fBSS0w0lEIYZLboF4GKXij9GXHxZWcpT(InhTTi8CKfBqwKO6DypXnfKogztatO)ig9INO8CzGZhoizmsspyC41mSWtRVyJLflL8i4IiN3YfbUhdwgq)Xf0wlLWJ2weEoYInilsu9oSN4M(qq(JXATIhCqYyKKEW4WRz4rBlcphzXgKfjQEh2tCZ6QgA8EW5d30fdZG8O9Ov7pW2JwzrvWMdWeWqehiCu(abjFGwej8aU8anbTVA9fxoABr45ijkTXnet2JbldO)JpA1(dS9L8bSLHNZb83bOyipEG4aU8av2i8aj8a6zqEaQThT4b6XCanYT5bAiFGkBeEGeEGGKpq0WAooasFToGX5dG0dsFoW2s)bKSihJ8OTfHNJ0EIBAldphc9hr9Q3RizipEGOuzZYsV69kYiHOyUHbjUhd(5qUuzBVjJsKvcsC(WgUdYcKrBFKwwpVMmWqgT9r(H42s)rBlcphP9e3eYeWqjJjBikH(JOG0lOTw1obPtdXV7)p6fprrYqE8arHNwFXgllTzYOezLGeNpSH7GSaz02h5F71REVIKH84bIIjro7)NhgwJOeokJJeJ2A9ZolROx8efjd5XdefEA9fB2lYCzsKtrYqE8arbYOTpYpFTS0w0lEIIKH84bIcpT(In7fzUmjYPezLGeNpSH7GSaz02h5NT2RncAO36lUqMldosJLfpmSgrjCughjgT16h6EViZLjroLNldjoF4xferbYOTpYp7k05VJ2weEos7jU5R5LpmwgjQTJwT)aBFjFaTygAb04a(7aharwDGgYha1LsFQpqhhyXTmoWwhqq6eEGn0yoWbKmKhpqq4b2qJ5ahWUm2Eoqd5dmzCGkBeEGnKMBZdGiRoa7bjdpqd5d06zvCGipGOTDaEyynccpqcpGKH84bId4Yd06zvCGipGir5duzJWdKWdOrUnpGlpqRNvXbI8aIeLpqLncpqcpGwm1IhWLhqKO(uFGkBhOhZbqKvhaPVwhq02oapmSgXbKzohTTi8CK2tCZNldC(WbjJrs6bJdVMHekqiwmoAynhsI7i0FefKEbT1Q2jiDAiU1E9Q3RizipEGOysKZE9Q3Rizoi9Pgd7AUysKZ()5HH1ikHJY4iXOTw)SZYk6fprrYqE8arHNwFXM9ImxMe5uKmKhpquGmA7J8ZxllTf9INOizipEGOWtRVyZErMltICkrwjiX5dB4oilqgT9r(zR9AJGg6T(IlK5YGJ0yzXddRruchLXrIrBT(HU3lYCzsKt55YqIZh(vbruGmA7J8ZUcD(7Ov7pW2xYhqdTGhWFhWJdGmN4a6qU)Da0wgmebHhydP528anKpaQlL(uFGooWIBzCGVhqq6eEGnKMBZdO71hqK5YKih5bAiFGjJduzJWdSH0CBEaez1bypiz4bAiFGwpRIde5beTTdWddRrq4bs4bKmKhpqCaxEGwpRIde5bejkFGkBeEGeEanYT5bC5bejQp1hOYgHhiHhqlMAXd4YdisuFQpqLTd0J5aiYQdG0xRdiABhGhgwJ4aYmNJ2weEos7jUz41meBRxOekqiwmoAynhsI7i0Fe1Mir1tSoK7F7fKEbT1Q2jiDAi(D))rV4jksgYJhik806l2yzPntgLiReK48HnChKfiJ2(iTSAr4eWyEyuNL089V96vVxrYCq6tng21CXKiN96vVxrYqE8arXKiN9)ZddRruchLXrIrBT(zNLv0lEIIKH84bIcpT(In7fzUmjYPizipEGOaz02h5NVwwAl6fprrYqE8arHNwFXM9ImxMe5uISsqIZh2WDqwGmA7J8Zw71gbn0B9fxiZLbhPXYIhgwJOeokJJeJ2A9dDVxK5YKiNYZLHeNp8RcIOaz02h5NDf683rBlcphP9e3uq6yKnbmH(JO2IEXtuEUmW5dhKmgjPhmo8Agw4P1xSzVnitaUwyk7kHxZqSTEHUpCu(dXToABr45iTN4MIETWTi8CWlxgeonktuyWsgYJhii0FeJEXtuKmKhpqu4P1xS5OTfHNJ0EIBk61c3IWZbVCzq40OmrHbl5hH(JO2IEXtuKmKhpqu4P1xS5Ov7pGwUxRdeK8bOyipEG4aTi8CoWYLXb83bOyipEG4aU8aIkiKNyH4av2oABr45iTN4MIETWTi8CWlxgeonktuYqE8abH(JOE17vKmKhpquQSD0Q9hql3R1bcs(auACGweEohy5Y4a(7abjd5d0q(aFpqcpWILYdWdJ6S8OTfHNJ0EIBk61c3IWZbVCzq40OmrzqO)i2IWjGX8WOol)S1rR2FaTCVwhii5dSHYTNd0IWZ5alxghWFhiiziFGgYhyRdKWdGMq(a8WOolpABr45iTN4MIETWTi8CWlxgeonktStMq)rSfHtaJ5HrDwsdXToApA1(dSHeHNJSSHYTNd4Yd4tWJHnh4LWduj5dG0dYdSbIfHlWBiJbRLxCtaFGEmhqubH8elehyy2ipqKhqNpqAlCuNUyZrBlcphzPtMisshU8PgBGDDoyBvJG8OTfHNJS0jBpXn5HH1oD5tnMxUwDiH(JO2SbzcW1ctzxj8AgIT1l09cs)dXD75HH1i(qh6pABr45ilDY2tCZNldjoF4xfebH(JipmSgrjCughjgT1kn7SSwCnpMgIOO1kEKy9oIfxZnSWtRVyZErMltICkqx6tnwwn4FU4xbYOTpYpTi8CkpxgsC(WVkiIIOLH905OTfHNJS0jBpXnHU0NASSAW)CXpcfielghnSMdjXDe6pI)h9INOGK0HlFQXgyxNd2w1iil806l2SxK5YKiNc0L(uJLvd(Nl(vmvWo8COrK5YKiNcsshU8PgBGDDoyBvJGSaz02hP909F7)xK5YKiNYZLHeNp8RcIOaz02hjnBzzjiDAisN)oABr45ilDY2tCtyLK0NASwQnmgPpgc9hr9Q3RaRKK(uJ1sTHXi9XumjY5OTfHNJS0jBpXnL28z8PglG9W4FU4hH(JOir1tSmG(pE))))VG0PzlllrMltICkpxgsC(WVkiIcKrBFK0ST)T)FbPtdr6yzjYCzsKt55YqIZh(vbruGmA7JKMV)9NLfpmSgrjCughjgT16hIBzzPx9EftpcgNpSG01sEbYTi(7OTfHNJS0jBpXnHmbmuYyYgIsO)iki9cARvTtq60q87rBlcphzPt2EIBkiDSEfuge6pIcsVG2Av7eKone36OTfHNJS0jBpXnFUmW5dhKmgjPhmo8AgsOaHyX4OH1CijUJq)ruq6f0wRANG0PH4whTTi8CKLoz7jUz41meBRxOekqiwmoAynhsI7i0FefKEbT1Q2jiDAi(D))Al6fprH0dSir1ZcpT(InwwAtKO6jwhY9V)oABr45ilDY2tCtbPJr2eWe6pIAtKO6jwhY9VJ2weEoYsNS9e38Tq4tnwYqB8e4FU4hH(JOE17v0ZFyBWuumjYHqFcgcRSfe3D02IWZrw6KTN4M6Rw8lRc8px8JqbcXIXrdR5qsChH(JOir1tSmG(pE))6vVxrp)HTbtrPYML1)rV4jkKEGfjQEw4P1xSzVnitaUwyk7kHxZqSTEHUxq6FO7)(7OTfHNJS0jBpXnL28z8PglG9W4FU4hH(JOir1tSmG(p(O9Ov7pGwoZLjroYJ2weEoYIWGL8JOpeK)ySwR4bhKmgjPhmo8AgsO)iQx9Efjd5XdeftICSSEEnzGHmA7J8Zx6C02IWZrwegSKFeF9AXdoHggE02IWZrwegSKFe1ZHnvYaRdzKhTTi8CKfHbl5hrKCBlhjoF4eAy4rBlcphzryWs(zpXnRRAOX7bNpCtxmmdsc9hXNxtgyiJ2(iPz32rhllTrqd9wFXfYCzWrA2lYCzsKtjYkbjoFyd3bzbYOTpYpe3r3wwpVMmWqgT9r(zRT9OTfHNJSimyj)SN4Mit4Yqa7dgYYC6rWe6pIImxMe5uISsqIZh2WDqwGmA7JKg6SDwwImxMe5uISsqIZh2WDqwGmA7J8ZxllcAO36lUqMldosJL1ZRjdmKrBFKF(s)rR2FGTVKpWgck6HpGgjeYtCa)Daez1bAiFauxk9P(aDCGf3Y4a7oGwM0pqpMdGmNnCCarB7a8WWAehaPhK(Ca6l05aswKJrE02IWZrwegSKF2tCZgk6HXrcH8ee6pIcsVG2Av7eKone3TNhgwJOeokJJeJ2ALgI0xOZrBlcphzryWs(zpXnRKm2dgLWPrzIRkzaZkjUoxgEW2wvODntO)ikYCzsKtjYkbjoFyd3bzbYOTpYp7SSezUmjYPezLGeNpSH7GSaz02hjnFP3YIGg6T(IlK5YGJ0yz98AYadz02h5hIFP)OTfHNJSimyj)SN4Mvsg7bJsi)ESiWtJYeRxTX7iHsmkB61YZHq)ruK5YKiNsKvcsC(WgUdYcKrBFKF2zzjYCzsKtjYkbjoFyd3bzbYOTpsA(sVLfbn0B9fxiZLbhPXY651KbgYOTpYpe)s)rBlcphzryWs(zpXnRKm2dgLq(9yrGNgLjwVAJ3rcLygvFXOe6pIpVMmWqgT9rsZo6SrwwImxMe5uISsqIZh2WDqwGmA7J8ZollcAO36lUqMldosZrBlcphzryWs(zpXnJSsqIZh2WDqsO)iQncAO36lUqMldosZ()1gVXvUnBSPiqiwzaZXfy9vldllrMltICkceIvgWCCbwF1YOaz02h5hI7(B))csNMDww8WWAeFOB6)7OTfHNJSimyj)SN4MYiHOyUHbjUhd(5qMqc9hrrMltICkYiHOyUHbjUhd(5qUiiBynlj(1YYKrjYkbjoFyd3bzbYOTpslRNxtgyiJ2(i)8LElR)1REVcYeUmeW(GHSmNEeCbYOTpsA2rVLLiZLjrofKjCziG9bdzzo9i4cKrBFK0iYCzsKtrgjefZnmiX9yWphYLx1AHHSGSH1moCu2YsBSuYJGlit4Yqa7dgYYC6rWf0wlLW)2)ViZLjroLiReK48HnChKfiJ2(iPrK5YKiNImsikMByqI7XGFoKlVQ1cdzbzdRzC4OSLfbn0B9fxiZLbhPzV24nUYTzJnfd011x(uJ95NT083ErMltICkpxgsC(WVkiIcKrBFKFiUr7fKone3AViZLjrofKKoC5tn2a76CW2QgbzbYOTpYpe3T1rBlcphzryWs(zpXnJSsqIZh(xdrBc9hXNxtgyiJ2(iPzhD2illtgLiReK48HnChKfiJ2(iTSiOHERV4czUm4inhTTi8CKfHbl5N9e3uFLPbNpCqYyEyuee6pIImxMe5uISsqIZh2WDqwGmA7JKg6Mowwe0qV1xCHmxgCKM9ImxMe5uEUmK48HFvqefiJ2(i)81Y651KbgYOTpYp7(Az98AYadz02hjn7ON(9pVMmWqgT9r(z3o63)ViZLjroLNldjoF4xferbYOTpYpBzzjYCzsKtbjPdx(uJnWUohSTQrqwGmA7J8dDSSezUmjYPaDPp1yz1G)5IFfiJ2(i)qN)oABr45ilcdwYp7jUPihbpbSd2GFRgLj0Fe1MjJIihbpbSd2GFRgLX6vWPaz02h5())xK5YKiNIihbpbSd2GFRgLlqgT9r(HOiZLjroLiReK48HnChKfiJ2(iTFNLfbn0B9fxiZLbhP5V9)RTOx8efKKoC5tn2a76CW2QgbzHNwFXgllrMltICkijD4YNASb215GTvncYcKrBFK)TxK5YKiNc0L(uJLvd(Nl(vGmA7JCViZLjroLNldjoF4xferbYOTpY96vVxrgjefZnmiX9yWphYftICSSmzuISsqIZh2WDqwGmA7J8plRNxtgyiJ2(i)SDhTA)b2(s(a2TY0CaTyfeXb83b0iReKhiFhyBYDqUHLhqK5YKiNd4Ydud5oy4bcYEoWw0FG)dsxEaFeRkdlpassFXhqJCBEaxEarfeYtSqCGweob8FeEGeEG89oGiZLjrohajjpharwDGgYhGmxgFQpqorEanYTjHhiHhajjphii5denSMJd4Yd06zvCGipGX5J2weEoYIWGL8ZEIBQVY0GFvqee6pIImxMe5uISsqIZh2WDqwGmA7JKMTO3YIGg6T(IlK5YGJ0yz98AYadz02h5NV0F02IWZrwegSKF2tCtDgkz4pFQj0FefzUmjYPezLGeNpSH7GSaz02hjnBrVLfbn0B9fxiZLbhPXY651KbgYOTpYp7OZrBlcphzryWs(zpXnxEnziXAPktnkpXrBlcphzryWs(zpXnFoK1xzAi0FefzUmjYPezLGeNpSH7GSaz02hjnBrVLfbn0B9fxiZLbhPXY651KbgYOTpYp7O)OTfHNJSimyj)SN4M9iyza7fw0RfH(JOiZLjroLiReK48HnChKfiJ2(iPzl6TSiOHERV4czUm4inwwpVMmWqgT9r(5l9hTTi8CKfHbl5N9e3uVRX5dhqx8tE02IWZrwegSKF2tCZkjJ9GrjCAuMOTu8JdPtxSblsuBvrhEoydtGlycj0FefzUmjYPezLGeNpSH7GSaz02hjnBrVLfbn0B9fxiZLbhP5OTfHNJSimyj)SN4Mvsg7bJs40OmriJMbJRRCtpcgBycCbtO)ikYCzsKtjYkbjoFyd3bzbYOTpsA2IEllcAO36lUqMldosZrBlcphzryWs(zpXnRKm2dgLq(9yrGNgLjwVAJ3rcLy92uZe6pIImxMe5uISsqIZh2WDqwGmA7JKMV0Bzrqd9wFXfYCzWrASSEEnzGHmA7J8Zx6pABr45ilcdwYp7jUzLKXEWOeonktSUxSOxlgkX6zoe6pIImxMe5uISsqIZh2WDqwGmA7JKg6qhllcAO36lUqMldosJL1ZRjdmKrBFKF299OTfHNJSimyj)SN4Mvsg7bJs40OmrKqpi9Pgl5AuEcC(WgilJUUdsc9hrrMltICkrwjiX5dB4oilqgT9rsZx6TSiOHERV4czUm4inhTTi8CKfHbl5N9e3SsYypyucNgLj2ssc6HLyytxjelsyVi0FejOHERV4sKgCo4kjJdOp)4y))ImxMe5uISsqIZh2WDqwGmA7JKMV7SSiOHERV4czUm4in)T)FdRx9EfytxjelsyVWgwV69kMe5yzPx9EfzKqum3WGe3Jb)CixGmA7JKMDBzz98AYadz02hP2jYCzsKtjYkbjoFyd3bzbYOTpYp0n97fzUmjYPezLGeNpSH7GSaz02h5NV0XY651KbgYOTpYpFPZFhTTi8CKfHbl5N9e3SsYypyucNgLj2ssc6HLyytxjelsyVi0Fe1gbn0B9fxI0GZbxjzCa95hh7)3W6vVxb20vcXIe2lSH1REVIjroww)RnEJRCB2ytXaDD9Lp1yF(zlnwwrdR5OeokJJeBte4TOVaz02h5NT7V9)BYOezLGeNpSH7GSaz02hPLLiZLjroLiReK48HnChKfiJ2(iTFJO551KbgYOTpY)2Rx9EfzKqum3WGe3Jb)CixQSzz98AYadz02h5NV05VJ2weEoYIWGL8ZEIBgKmUA0ZQXGFjuWhTTi8CKfHbl5N9e30wf0Fi8PgRVAzC0Q9hyduUmhydMBB(uFaT4Qrz5bEj8aSwzrvWha2tnFGeEGF(ADa9Q3ts4b83bSLsPRV4Yb2qlKnc5bciIde5bQ54abjFGvIKLXbezUmjY5a6TKnhiNd0e0(Q1x8b4HrDwwoABr45ilcdwYp7jUjKBB(uJFRgLLe6pI6vVxrYqE8arXKiN9)hnSMJs4OmosSnrG)spnBrVLv0WAokKCVcYInr8H4x6)ZYkAynhLWrzCKyJZF(E02IWZrwegSKF2tCZxkQKSb30fd9GX6CJE02IWZrwegSKF2tCtugnHiW5dVQeUbBGCJkj0Fe5HH1i(q30F02IWZrwegSKF2tCtOBZ2IX(GL2AbF02IWZrwegSKF2tCt9UgNpCaDXp5rBlcphzryWs(zpXnRKm2dgvsO)i(pVXvUnBSPiqiwzaZXfy9vlJ9ImxMe5ueieRmG54cS(QLrbYOTpYpe)s)FwwAJ34k3Mn2ueieRmG54cS(QLXr7rR2FaTCMltICKhTTi8CKfHblzipEGGOpeK)ySwR4bhKmgjPhmo8AgsO)iQx9Efjd5XdeftICSSEEnzGHmA7J8Zx6C02IWZrwegSKH84bcIVET4bNqddpABr45ilcdwYqE8abr9CytLmW6qg5rBlcphzryWsgYJhiiIKBB5iX5dNqddpABr45ilcdwYqE8aH9e3SsYypyucNgLj20LKSHTe)YjW5dBlrYqc9hr9Q3RizipEGOysKZ()fzUmjYPizipEGOaz02h5NV0Bz98AYadz02h5h6M()oABr45ilcdwYqE8aH9e3SUQHgVhC(WnDXWmij0Fe1REVIKH84bIIjro7))51KbgYOTpsA2TD0XYsK5YKiNIKH84bIcKrBFKFiUn(ZY651KbgYOTpYpBrNJ2weEoYIWGLmKhpqypXn1xzAWVkicc9hrrMltICksgYJhikqgT9rsZx6TSEEnzGHmA7J8Zx6pABr45ilcdwYqE8aH9e3uNHsg(ZNAc9hrrMltICksgYJhikqgT9rsZx6TSEEnzGHmA7J8Zo6C0Q9hy7l5dSHGIE4dOrcH8ehWFhGIH84bId4YdmzCGkBeEGEmharwDGgYha1LsFQpqhhyXTmoWUdOLjDcpqpMdGmNnCCarB7a8WWAehaPhK(Ca6l05aswKJrE02IWZrwegSKH84bc7jUzdf9W4iHqEcc9hr9Q3RizipEGOysKZEbPxqBTQDcsNgI72ZddRruchLXrIrBTsdr6l05OTfHNJSimyjd5Xde2tCZLxtgsSwQYuJYtC02IWZrwegSKH84bc7jU5ZHS(ktdH(JOiZLjrofjd5XdefiJ2(iP5l9wwpVMmWqgT9r(zh9hTTi8CKfHblzipEGWEIB2JGLbSxyrVwe6pIImxMe5uKmKhpquGmA7JKMV0Bz98AYadz02h5NV0F02IWZrwegSKH84bc7jUPExJZhoGU4N8OTfHNJSimyjd5Xde2tCZkjJ9GrjCAuM4QsgWSsIRZLHhSTvfAxZe6pIImxMe5uISsqIZh2WDqwGmA7J8ZollrMltICkrwjiX5dB4oilqgT9rsZx6TSiOHERV4czUm4inwwpVMmWqgT9r(H4x6pABr45ilcdwYqE8aH9e3SsYypyuc53JfbEAuMy9QnEhjuIrztVwEoe6pIImxMe5uISsqIZh2WDqwGmA7J8ZollrMltICkrwjiX5dB4oilqgT9rsZx6TSiOHERV4czUm4inwwpVMmWqgT9r(H4x6pABr45ilcdwYqE8aH9e3SsYypyuc53JfbEAuMy9QnEhjuIzu9fJsO)i(8AYadz02hjn7OZgzzjYCzsKtjYkbjoFyd3bzbYOTpYp7SSiOHERV4czUm4inhTTi8CKfHblzipEGWEIBgzLGeNpSH7GKq)ruBe0qV1xCHmxgCKMJ2weEoYIWGLmKhpqypXnJSsqIZh(xdrBc9hXNxtgyiJ2(iPzhD2illtgLiReK48HnChKfiJ2(iTSiOHERV4czUm4inhTTi8CKfHblzipEGWEIBwjzShmkHtJYeTLIFCiD6InyrIARk6WZbBycCbtO)iQx9Efjd5XdeftIC2)ViZLjroLiReK48HnChKfiJ2(iPzh9wwe0qV1xCHmxgCKM)SSEEnzGHmA7J8dDoABr45ilcdwYqE8aH9e3uFLPbNpCqYyEyuee6pI6vVxrYqE8arXKiN9)lYCzsKtrYqE8arbYOTpsA(sVLLiZLjrofjd5XdefiJ2(i)89plRNxtgyiJ2(i)SJohTTi8CKfHblzipEGWEIBwjzShmkHtJYeHmAgmUUYn9iySHjWfmH(JOiZLjroLiReK48HnChKfiJ2(iPzh9wwe0qV1xCHmxgCKMJ2weEoYIWGLmKhpqypXnRKm2dgLq(9yrGNgLjwVAJ3rcLy92uZe6pIImxMe5uKmKhpquGmA7JKMV0Bz98AYadz02h5NV0F02IWZrwegSKH84bc7jUzLKXEWOeonktSUxSOxlgkX6zoe6pIImxMe5uKmKhpquGmA7JKMV0Bz98AYadz02h5NV0F02IWZrwegSKH84bc7jUzLKXEWOeonktej0dsFQXsUgLNaNpSbYYOR7GKq)ruK5YKiNsKvcsC(WgUdYcKrBFK0SJEllcAO36lUqMldosZrBlcphzryWsgYJhiSN4Mvsg7bJs40OmXwssqpSedB6kHyrc7fH(JOH1REVcSPReIfjSxydRx9EftICSS0REVIKH84bIcKrBFK0SrwwpVMmWqgT9r(5lDoABr45ilcdwYqE8aH9e3ezcxgcyFWqwMtpcMq)ruV69ksgYJhikMe5S)FrMltICksgYJhikqgT9rsZo6yzjYCzsKtrYqE8arbYOTpYpF)ZY651KbgYOTpYpFP)OTfHNJSimyjd5Xde2tCtrocEcyhSb)wnktO)iQx9Efjd5XdeftIC2)ViZLjrofjd5XdefiJ2(iTSezUmjYPiYrWta7Gn43Qr5IGSH1SK43)2RntgfrocEcyhSb)wnkJ1RGtbYOTpY9)lYCzsKtb6sFQXYQb)Zf)kqgT9rUxK5YKiNYZLHeNp8RcIOaz02hPL1ZRjdmKrBFKF2U)oABr45ilcdwYqE8aH9e3uYqE8aXrBlcphzryWsgYJhiSN4MbjJRg9SAm4xcfmH(JOE17vKmKhpqumjY5OTfHNJSimyjd5Xde2tCtBvq)HWNAS(QLbH(JOE17vKmKhpqumjY5OTfHNJSimyjd5Xde2tCti328Pg)wnklj0Fe1REVIKH84bIIjro7)pAynhLWrzCKyBIa)LEA2IElROH1Cui5EfKfBI4dXV0)NLv0WAokHJY4iXgN)89OTfHNJSimyjd5Xde2tCZxkQKSb30fd9GX6CJsO)iQx9Efjd5XdeftICoABr45ilcdwYqE8aH9e3eLrticC(WRkHBWgi3Osc9hr9Q3RizipEGOysKZEEyynIp0n9hTTi8CKfHblzipEGWEIBcDB2wm2hS0wlyc9hr9Q3RizipEGOysKZrBlcphzryWsgYJhiSN4M6DnoF4a6IFsc9hr9Q3RizipEGOysKZrBlcphzryWsgYJhiSN4Mvsg7bJkj0Fe1REVIKH84bIIjro7))FEJRCB2ytrGqSYaMJlW6Rwg7fzUmjYPiqiwzaZXfy9vlJcKrBFKFi(L()SS0gVXvUnBSPiqiwzaZXfy9vlJ)oApA1(dOfe6j0dehajPV4dizipEG4aU8av2oABr45ilsgYJhii(CziX5d)QGii0Fe1REVIKH84bIcKrBFKF2zz1IWjGX8WOolPz3rBlcphzrYqE8aH9e3uAZNXNASa2dJ)5IFe6pIIevpXYa6)49)3IWjGX8WOolP5RLvlcNagZdJ6SKMD71MiZLjrofOl9PglRg8px8Ruz7VJ2weEoYIKH84bc7jUj0L(uJLvd(Nl(rOaHyX4OH1CijUJq)ruKO6jwgq)hF0Q9hqdsxEaK(ADarlJdOftT4b6XCaFcgcRSfhii5dii7z41b83bcs(aBV0YBZd4Yda52G4a9yoGmr5G0N6dq61Km8a5CGGKpGnONqpqCGLlJd8)gmLw4FhWLhOjO9vRV4YrBlcphzrYqE8aH9e385YqIZh(vbrqOpbdHv2cS)iwlmfiJ2(ijs)rBlcphzrYqE8aH9e385YaNpCqYyKKEW4WRziHceIfJJgwZHK4oc9hrbP)zRJ2weEoYIKH84bc7jUjKjGHsgt2quc9hrbPxqBTQDcsNMD75HH1ikHJY4iXOTw)S7Ov7pW2xYhWUulKWd4Xbq6R1bYzH4a6qU)Da0wgmeXb83b2a5Xb0YjQEEaxEan3aOghi6fpbBoABr45ilsgYJhiSN4M6Rw8lRc8px8JqbcXIXrdR5qsChH(JOir1tSmG(p2YsBrV4jkKEGfjQEw4P1xS5OTfHNJSizipEGWEIBkT5Z4tnwa7HX)CXVJ2J2weEoYImiIK0HlFQXgyxNd2w1iipABr45ilYWEIB(CziX5d)QGii0FeJEXtuKmKhpqu4P1xSXYsK5YKiNsKvcsC(WgUdYcKrBFK0STwwe0qV1xCHmxgCKMJwT)aBFjFGnykTWdKZbIgwZH8ai9GmRIdS9UH)oq(oqqYhqld7HpGH1REpcpG)oGTukD9ft4b6XCa)DanYT5bC5b64alULXb(EajlYXipqJSrC02IWZrwKH9e3e6sFQXYQb)Zf)iuGqSyC0WAoKe3rO)ig9INOizipEGOWtRVyJLLiZLjroLiReK48HnChKfiJ2(iP5RLfbn0B9fxiZLbhP5OTfHNJSid7jUjSss6tnwl1ggJ0hdH(JOE17vGvssFQXAP2WyK(ykMe5SVfHtaJ5HrDwsZUJ2weEoYImSN4MqMagkzmzdrj0FefKEbT1Q2jiDA2D02IWZrwKH9e385YaNpCqYyKKEW4WRziHceIfJJgwZHK4oc9hrbP)zRJ2weEoYImSN4M8WWANU8PgZlxRoKq)ruq6FiU1EEyynIp0H(JwT)aBFjFaTSDhWFharwDGgYhanH8bcYEoa9hqlt6hOr2ioWdMOhaT16b6XCaYMa(a7oapmkccpqcpqd5dGMq(abzphy3b0YK(bAKnId8Gj6bqBTE02IWZrwKH9e3uq6y9kOmi0FefKEbT1Q2jiDAOFFlcNagZdJ6SK4ollbPxqBTQDcsNMDhTA)b2(s(aAOf8a(7aiYQd0q(a09bs4bqtiFabPFGgzJ4apyIEa0wRhOhZb0i3MhOhZbO2E0IhOH8b0ZG8atghOY2rBlcphzrg2tCZWRzi2wVqjuGqSyC0WAoKe3rO)iksu9eldO)J3li9cARvTtq60S1ETzYOezLGeNpSH7GSaz02h5E9Q3RiJeII5ggK4Em4Nd5IjrohTTi8CKfzypXnfKogztaF02IWZrwKH9e3uAZNXNASa2dJ)5IFe6pIIevpXYa6)496vVxX0JGX5dliDTKxGClIJwT)aBFjFa7sTWd4VdONb5b0IPw8a9yoWgmLw4bAiFGjJdiwPKj8aj8aBWuAHhWLhqSsjFGEmhqlMAXd4YdmzCaXkL8b6XCaez1biBc4dGMq(abzph47beKoHhiHhqlMAXd4YdiwPKpWgmLw4bC5bMmoGyLs(a9yoaIS6aKnb8bqtiFGGSNdS1beKoHhiHharwDaYMa(aOjKpqq2ZbOZbeKoHhiHhWFharwDGAooqFaBWuC02IWZrwKH9e3uF1IFzvG)5IFekqiwmoAynhsI7i0FefjQEILb0)X7)))Ox8efjd5XdefEA9fBSSezUmjYPezLGeNpSH7GSaz02hjnFTSiOHERV4czUm4in)T)FrMltICkqx6tnwwn4FU4xbYOTpsA(UxK5YKiNYZLHeNp8RcIOaz02hjnFTSezUmjYPaDPp1yz1G)5IFfiJ2(i)S1ErMltICkpxgsC(WVkiIcKrBFK0S1EbPtZxllrMltICkqx6tnwwn4FU4xbYOTpsA2AViZLjroLNldjoF4xferbYOTpYpBTxq60q3wwcsNg68NLLE17v0ZFyBWuuQS93rBlcphzrg2tCZWRzi2wVqjuGqSyC0WAoKe3rO)iksu9eldO)J3li9cARvTtq60S7Ov7pW2xYhqlsPfEGEmhWNGHWkBXb84aYa2EnzCGgzJ4OTfHNJSid7jU5BHWNASKH24jW)CXpc9jyiSYwqC3rR2FGTVKpGDPw4b83b0IPw8aU8aIvk5d0J5aiYQdq2eWh47beK(b6XCaezf8aRwghOEL696aiB5b0qliHhiHhWFharwDGgYhO1ZQ4arEarB7a8WWAehOhZbypiz4bqKvWdSAzCGAH5aiB5b0ql4bs4b83bqKvhOH8bwSuEGGSNd89acs)anYgXbEWe9aI2MnFQpABr45ilYWEIBQVAXVSkW)CXpcfielghnSMdjXDe6pIIevpXYa6)49)lYCzsKt55YqIZh(vbruGmA7J8Zw7fKoXVww8WWAeLWrzCKy0wRF293()TbzcW1ctzxj8AgIT1lullbPxqBTQDcs)Z3)uHkuka]] )

end