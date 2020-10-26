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
    
    spec:RegisterPack( "Windwalker", 20201026, [[dSuvKbqiqQ6rKGAtQk9jqQu1Oif1PivYQaPsLxrImlq0TivQDjv)IuXWKI6yuHLbcptkY0ib6AGu2MuO6BKG04KcPZjfcZJe6EsP9bsoiPiYcjfEiPimrsq0fjbHncsfFukuknsPqP6KKIOSsvfVeKk5MKIOANGs)eKkLHkfkzPsHcpvPMkO4QsHOTkfkfFvku0Er8xKgmKdlAXuPhd1KrXLj2SQ8zQYOjPttz1KaEnPQzRKBJs7wYVbgoP0Yv55OA6cxNQA7sbFNkA8KOoVQQ1tksZhuTFftCqGHSzYqiWcrZq0SJMHOX7ouOn1OqRrq2XVwHS1My9PNq2vYkKDJPvmoZLE5iBT5)cKmeyiBoW)Wczt2U(2k0KvexYMjdHalendrZoAgIgV7qH2uJQGqq2CTcMalenEJGSvnggPiUKnJWXKTcpOgtRyCMl9Ynin5Gs)8rHhe0nCaCLBqq04qoiiAgIMj7LXdobgYgZq5YJadbwheyiBPs3LWq0GSXNfYzjzd9dQH8S0DjDvWIHQSVudco8b9mp1GEcBAfFqkoiiGgzN4WafzBvda9cvzFPibbwiiWq2jomqr2VCTKIcog5iBPs3LWq0GeeyBIadzN4Wafz7ckHXNhu3tCs2sLUlHHObjiWQGeyi7ehgOiBNsQfuCk4rbhJCKTuP7syiAqccSqJadzlv6UegIgKn(SqoljBSQ1ztLhKUhew1geuTdYbzN4WafzNholHgG7Kkibb2gNadzlv6UegIgKn(Sqolj7ippj6QsUc1UwCmifBhKdOnOVdY1)968aCSujVqLMfd9zN0zaolYoXHbkYoa(yvk4rzKmujbbwfkbgYwQ0DjmeniB8zHCws2yayXaCw9NXdof8Op)7VFcBAfFqkoiigeC4d6zEQb9e20k(GuCqoGGStCyGISDxaadf8OHQqLsy)jbb2gLadzN4Wafz75NhJLff8OPMkhiujBPs3LWq0GeeyBeeyi7ehgOiBNGBX0Gyf9eoOYclKTuP7syiAqccSoAMadzlv6UegIgKn(SqoljBOFqmGOJbfwQ4YqyOVvYkux)R6NWMwXh03bP5bP5bb9dkYLur3PQDlR8Omx6bkQw)cR2LkDxcZGGdFqyayXaCwDNQ2TSYJYCPhOOA9lSA)e20k(G01G(oimaSyaoR(zCR8OC)IQ3W67NWMwXh03bHbGfdWz1Fgp4uWJ(8V)(jSPv8b9DqU(VxNhGJLk5fQ0SyOp7KodWzniDni4Wh0Z8ud6jSPv8bP4GAuYoXHbkYgdkSuXLHWqFRKvibbwhoiWq2jomqr2HQq9lxGFXqFGdlKTuP7syiAqccSoGGadzN4WafzR1)S3VvEu3vYdYwQ0DjmenibbwhnrGHSLkDxcdrdYgFwiNLKDKNNe9WyfAaOAXbfIMheudQPMheC4dkYZtIUQKRqTRfhdsX2bbrZKDIdduK9jPwR8OVvYkCsqG1HcsGHStCyGISFaSpxyOPMkNfc1vswYwQ0DjmenibbwhqJadzlv6UegIgKn(SqoljBPKZ7FqkoifSzYoXHbkYMvyb3pf8OlFSXqzojz5KGaRJgNadzN4WafzFMwTlHAfLRnXczlv6UegIgKGaRdfkbgYwQ0DjmeniB8zHCws2yayXaCwDEaowQKxOsZIH(St6y188e(GAheedco8b9mp1GEcBAfFqkoiiAEqWHpix)3RZfjuTYJEPN091oi4WhKMhegawmaNv3DbamuWJgQcvkH9VFcBAfFqknihdcQbHbGfdWz15b4yPsEHknlg6ZoP)8xl6jy188eAySYGGdFqq)GeoxkS0Dxaadf8OHQqLsy)7SPcaUbPRb9DqyayXaCw9NXdof8Op)7VFcBAfFqkoihnpOVdcRAdcQ2bbXG(oimaSyaoRUtv7ww5rzU0duuT(fwTFcBAfFqkoihqq2jomqr28aCSujVqLMfd9zNqccSoAucmKTuP7syiAq2vYkKDYvBilHtVutbhfdUCr2jomqr2jxTHSeo9snfCum4YfjiW6OrqGHSTkKRHCr2nIMjBT4GQk5kuj7M7qJStCyGISdGpwLcEu95XMKTuP7syiAqccSq0mbgYwQ0DjmeniB8zHCws2pZtnONWMwXheudYbeqBqWHpix)3RZdWXsL8cvAwm0NDs3x7GGdFqpZtnONWMwXhKIdcIMj7ehgOiB3faWqF(3pjiWcHdcmKTuP7syiAq24Zc5SKSFMNAqpHnTIpiOgKJgfAdco8b56)EDEaowQKxOsZIH(St6(AheC4d6zEQb9e20k(GuCqq0mzN4Wafz7khxo9w5rccSqabbgYoXHbkYEzEQbNQa(mESsfKTuP7syiAqccSq0ebgYwQ0DjmeniB8zHCws2pZtnONWMwXheudYbeqBqWHpix)3RZdWXsL8cvAwm0NDs3x7GGdFqpZtnONWMwXhKIdcIMj7ehgOi7NDI7cayibbwiuqcmKTuP7syiAq24Zc5SKSD9FVopahlvYluPzXqF2jDgGZIStCyGISZcl84YffNRfjibzd0kLCeyiW6Gadzlv6UegIgKDIdduK9Z4bf8OHQqDQAHqdZtoYgFwiNLKnw16SPYds3dcRAdcQ2b1ezJ)XlHg5DEsWjBhKGaleeyiBPs3LWq0GSXNfYzjzh5sQOJvnQR)XJUuP7syg03bHvToBQ8G09GWQ2GGQDqnr2jomqr2IYALfvnpwsqGTjcmKTuP7syiAq2jomqr2H5jhvBUyjB8zHCws2yaRlGYJZ0ld67GWQwNnvEq6EqyvBqq1oiiiB8pEj0ippj4eyDqccSkibgYoXHbkYwuwRSOQ5Xs2sLUlHHObjiWcncmKTuP7syiAq2jomqr2H5jhvBUyjB8zHCws2yvRZMkpiDpiSQniOAheeKn(hVeAKNNeCcSoibjiBg5L(RGadbwheyi7ehgOiBUwjpQAwmuECMEHSLkDxcdrdsqGfccmKTuP7syiAq2aTKnxcYoXHbkYUH8S0DjKDd5YxiBmaSyaoRUvna0luL9LIgQc1PQfcnmp56NWMwXheud6zEQb9e20k(GGdFqpZtnONWMwXhKIdYbenpOVd6zEQb9e20k(GGAqyayXaCwDUCszXF)e20k(G(oimaSyaoRoxoPS4VFcBAfFqqnihnt2nKhTswHSvblgQY(srccSnrGHSLkDxcdrdYgFwiNLKTMhKR)715YjLf)DFTdco8b56)EDEaowQKxOsZIH(St6(AhKUg03bPvIUY(srdvH6u1cHgMNC9ehwdYGGdFqpZtnONWMwXhKITdQXBMStCyGIS1ccduKGaRcsGHSLkDxcdrdYgFwiNLKTR)715YjLf)DFTKDIdduKnoxlAIddu0LXdYEz8GwjRq2C5KYIFsqGfAeyiBPs3LWq0GSXNfYzjzhgRmifhe0g03bHvTbP4GG2G(oiOFqALORSVu0qvOovTqOH5jxpXH1Gq2jomqr24CTOjomqrxgpi7LXdALSczd0kLCKGaBJtGHSLkDxcdrdYoXHbkY(z8GcE0qvOovTqOH5jhzJplKZsYgRAD2u5bP7bHvTbbv7GAAqFhKMhKuY593dJvObGYMkpifhKJbbh(GKsoV)EyScnau2u5bP4GuWb9DqyayXaCw9NXdof8Op)7VFcBAfFqkoihDOniDr24F8sOrEEsWjW6GeeyvOeyiBPs3LWq0GSXNfYzjzJvToBQ8G09GWQ2GGQDqogKsds4CPWshdQ3YWbnlgkpo7jD2uba3G(oinpiPKZ7VhgRqdaLnvEqkoihdco8bHbGfdWz15YjLf)9tytR4dsXbbXGGdFqsjN3FpmwHgakBQ8GuCqk4G(oimaSyaoR(Z4bNcE0N)93pHnTIpifhKJo0gKUi7ehgOiBrzTYIQMhljiW2OeyiBPs3LWq0GStCyGISdZtoQ2CXs24Zc5SKSXawxaLhNPxg03bHvToBQ8G09GWQ2GGQDqqmOVdsZdsk58(7HXk0aqztLhKIdYXGGdFqyayXaCwDUCszXF)e20k(GuCqqmi4WhKuY593dJvObGYMkpifhKcoOVdcdalgGZQ)mEWPGh95F)9tytR4dsXb5OdTbPlYg)JxcnYZtcobwhKGaBJGadzlv6UegIgKn(SqoljBOFqrUKk6C5KYI)UuP7syi7ehgOiBCUw0ehgOOlJhK9Y4bTswHSXmuU8ibbwhntGHSLkDxcdrdYgFwiNLKDKlPIoxoPS4Vlv6UegYoXHbkYgNRfnXHbk6Y4bzVmEqRKviBmdLlNuw8tccSoCqGHSLkDxcdrdYgFwiNLKDIdRbHkLWAcFqkoOMi7ehgOiBCUw0ehgOOlJhK9Y4bTswHS5bjiW6accmKTuP7syiAq24Zc5SKStCyniuPewt4dcQ2b1ezN4WafzJZ1IM4WafDz8GSxgpOvYkKDcesqcYw7jyaRBgeyiW6GadzN4Wafz)wcxfF5liBPs3LWq0GeeyHGadzlv6UegIgKnqlzZLGStCyGISBiplDxcz3qU8fYUzYUH8OvYkKTY(srbf1Nl04SsVeKGaBteyiBPs3LWq0GSXNfYzjzd9dkYLurNlNuw83LkDxcZGGdFqq)GICjv0FgpOGhnufQtvleAyEY1LkDxcdzN4WafzJvnQR)XdsqGvbjWq2sLUlHHObzJplKZsYg6huKlPIUuY5zAQvEuzzklxxQ0DjmKDIdduKnw1OoZgesqcYobcbgcSoiWq2jomqr2ovTBzLhL5spqr16xyvYwQ0DjmenibbwiiWq2sLUlHHObzJplKZsYgRAD2u5bP7bHvTbbv7GGyqFhKuY593dJvObGYMkpiOgutdco8bHvToBQ8G09GWQ2GGQDqk4G(oinpiPKZ7VhgRqdaLnvEqqniigeC4dc6hK2tAG6Hz6o6H5jhvBUyhKUi7ehgOiBPKZZ0uR8OYYu2osqGTjcmKTuP7syiAq24Zc5SKSXawxaLhNPxg03bP5b56)EDMSWcf8OyvtbSUV2bbh(GC9FVotwyHcEuSQPagn1u5Sq6(AhKUi7ehgOiBUwRkR8O4llHQ3W6jbbwfKadzlv6UegIgKn(SqoljBPKZ7VhgRqdaLnvEqqnirzb7hcnmwzq6EqogeC4dY1)968aCSujVqLMfd9zN0pHnTIt2jomqr2pJhCk4rF(3pjiWcncmKTuP7syiAq2jomqr2NXTYJY9lQEdRNSXNfYzjzR5bf5sQO7u1ULvEuMl9afvRFHv7sLUlHzqFhegawmaNv)mUvEuUFr1By9Dg)lddudcQbHbGfdWz1DQA3YkpkZLEGIQ1VWQ9tytR4dsPb10G01G(oinpimaSyaoR(Z4bNcE0N)93pHnTIpiOgutdco8bHvTbbv7GG2G0fzJ)XlHg55jbNaRdsqGTXjWq2sLUlHHObzJplKZsY21)96Npx1kpQcKmc1PvmDgGZIStCyGISpFUQvEufizeQtRyibbwfkbgYwQ0DjmeniB8zHCws2yaRlGYJZ0ld67G08G08GWQ2GGAqnni4WhegawmaNv)z8Gtbp6Z)(7NWMwXheudQXhKUg03bP5bHvTbbv7GG2GGdFqyayXaCw9NXdof8Op)7VFcBAfFqqniigKUgeC4dsk58(7HXk0aqztLhKITdQPbPlYoXHbkYMR1QYkpk(YsO6nSEsqGTrjWq2sLUlHHObzJplKZsYgRAD2u5bP7bHvTbbv7GCmiLgKW5sHLoguVLHdAwmuEC2t6SPcaoYoXHbkYwuwRSOQ5XsccSnccmKTuP7syiAq24Zc5SKSXQwNnvEq6EqyvBqq1oOMi7ehgOiBSQrD9pEq24F8sOrEEsWjW6GeeyD0mbgYwQ0Djmeni7ehgOi7W8KJQnxSKn(SqoljBSQ1ztLhKUhew1geuTdcIb9DqAEqq)GICjv0vTGIbSUGUuP7sygeC4dcdyDbuECMEzq6ISX)4LqJ88KGtG1bjiW6WbbgYwQ0DjmeniB8zHCws2yaRlGYJZ0lKDIdduKnw1OoZgesqG1beeyiBPs3LWq0GStCyGISFRFR8OC50kvq1By9Kn(SqoljBx)3R7c0t1EaCNb4SiBRc5oFTbz7GeeyD0ebgYwQ0Djmeni7ehgOiB3vI1d8dQEdRNSXNfYzjzJbSUakpotVmOVdsZdY1)96Ua9uTha391oi4WhuKlPIUQfumG1f0LkDxcZG(oiTN0a1dZ0D0dZtoQ2CXoOVdsZdcRAD2u5bP7bHvTbbv7GCmOVdsk58(7HXk0aqHwZdsXb5yqWHpiSQnO2bbXG(oimaSyaoR(Z4bNcE0N)93pHnTIpifhutdsxdsxKn(hVeAKNNeCcSoibbwhkibgYwQ0Djmeni7ehgOiB3vI1d8dQEdRNSXNfYzjzJbSUakpotVmOVdcRADg5zylgu7GAEqFhK2tAG6Hz6o6CTwvw5rXxwcvVH1t24F8sOrEEsWjW6GeKGSXmuUCszXpbgcSoiWq2sLUlHHObzd0s2Cji7ehgOi7gYZs3Lq2nKlFHSXaWIb4S6C5KYI)(jSPv8bP4GCmi4Wh0Z8ud6jSPv8bP4GGOzYUH8OvYkKnxoPS4N66F8GeeyHGadzlv6UegIgKn(SqoljBOFqnKNLUlPRcwmuL9LAqWHpON5Pg0tytR4dsXbbb0i7ehgOiBRAaOxOk7lfjiW2ebgYoXHbkY(LRLuuWXihzlv6UegIgKGaRcsGHStCyGISDbLW4ZdQ7jojBPs3LWq0GeeyHgbgYoXHbkY2PKAbfNcEuWXihzlv6UegIgKGaBJtGHSLkDxcdrdYgFwiNLK9Z8ud6jSPv8bb1GC0OqBqWHpOgYZs3L05YjLf)ux)Jhdco8b9mp1GEcBAfFqkoOMGgzN4Wafz75NhJLff8OPMkhiujbbwfkbgYwQ0DjmeniB8zHCws2nKNLUlPZLtkl(PU(hpi7ehgOiBNGBX0Gyf9eoOYclKGaBJsGHSLkDxcdrdYgFwiNLKDd5zP7s6C5KYIFQR)XdYoXHbkY2DbamuWJgQcvkH9NeeyBeeyiBPs3LWq0GSXNfYzjzR5bHbGfdWz15YjLf)9tytR4dco8bHbGfdWz1XGclvCzim03kzLownppHpO2bbXG01G(oiOFqmGOJbfwQ4YqyOVvYkux)R6NWMwXh03bP5bHbGfdWz1pJBLhL7xu9gwF)e20k(G(oimaSyaoR(Z4bNcE0N)93pHnTIpi4Wh0Z8ud6jSPv8bP4GA0bPlYoXHbkYgdkSuXLHWqFRKvibbwhntGHStCyGISdvH6xUa)IH(ahwiBPs3LWq0GeeyD4GadzN4WafzR1)S3VvEu3vYdYwQ0DjmenibbwhqqGHSLkDxcdrdYgFwiNLKDKNNe9WyfAaOAXbfIMheudQPMheC4dkYZtIUQKRqTRfhdsX2bbrZdco8bf55jrpmwHgakJjdsXbbbzN4WafzFsQ1kp6BLScNeeyD0ebgYoXHbkY(bW(CHHMAQCwiuxjzjBPs3LWq0GeeyDOGeyiBPs3LWq0GSXNfYzjzlLCE)dsXbPGnt2jomqr2Scl4(PGhD5JngkZjjlNeeyDancmKDIdduK9zA1UeQvuU2elKTuP7syiAqccSoACcmKTuP7syiAq24Zc5SKSFMNAqpHnTIpiOgKdiG2GGdFqnKNLUlPZLtkl(PU(hpi7ehgOiB3faWqF(3pjiW6qHsGHSLkDxcdrdYgFwiNLK9Z8ud6jSPv8bb1GC0OqBqWHpOgYZs3L05YjLf)ux)JhKDIdduKTRCC50BLhjiW6OrjWq2sLUlHHObzJplKZsYgRAD2u5bP7bHvTbbv7GCq2jomqr25HZsOb4oPcsqG1rJGadzN4WafzVmp1GtvaFgpwPcYwQ0DjmenibbwiAMadzlv6UegIgKn(Sqolj7N5Pg0tytR4dcQb5acOni4Whud5zP7s6C5KYIFQR)XdYoXHbkY(zN4UaagsqGfcheyiBPs3LWq0GSXNfYzjz)mp1GEcBAfFqqnihqaTbbh(GAiplDxsNlNuw8tD9pEq2jomqr2zHfEC5IIZ1IeeyHaccmKTuP7syiAq24Zc5SKSBiplDxsNlNuw8tD9pEq2jomqr2UPhf8OXzy9CsqGfIMiWq2sLUlHHObzxjRq2jxTHSeo9snfCum4YfzN4WafzNC1gYs40l1uWrXGlxKGalekibgYwQ0DjmeniB8zHCws2rEEs0vLCfQDT4yqk2oihqJStCyGISdGpwLcEugjdvsqGfcOrGHSTkKRHCr2nIMjBT4GQk5kuj7M7qJStCyGISdGpwLcEu95XMKTuP7syiAqccSq04eyiBPs3LWq0GSXNfYzjzJbGfdWz1pJBLhL7xu9gwF)e20k(GuCqqmi4Wh0Z8ud6jSPv8bP4GCanYoXHbkYMlNuw8tccSqOqjWq2jomqr2UPhf8OXzy9CYwQ0DjmenibjiBEqGHaRdcmKDIdduKTtv7ww5rzU0duuT(fwLSLkDxcdrdsqGfccmKTuP7syiAq24Zc5SKSXQwNnvEq6EqyvBqq1oiig03bjLCE)9WyfAaOSPYdcQb10GGdFqyvRZMkpiDpiSQniOAhKcoOVdsZdsk58(7HXk0aqztLheudcIbbh(GG(bP9KgOEyMUJEyEYr1Ml2bPlYoXHbkYwk58mn1kpQSmLTJeeyBIadzlv6UegIgKn(SqoljBmG1fq5Xz6Lb9DqAEqU(VxNjlSqbpkw1uaR7RDqWHpix)3RZKfwOGhfRAkGrtnvolKUV2bPlYoXHbkYMR1QYkpk(YsO6nSEsqGvbjWq2jomqr2pJhCk4rF(3pzlv6UegIgKGal0iWq2sLUlHHObzN4WafzFg3kpk3VO6nSEYgFwiNLKngawmaNvNlNuw83pHnTIpiOgKJbbh(GG(bf5sQOZLtkl(7sLUlHHSX)4LqJ88KGtG1bjiW24eyiBPs3LWq0GSXNfYzjz76)E9ZNRALhvbsgH60kModWznOVdkXH1GqLsynHpiOgKdYoXHbkY(85Qw5rvGKrOoTIHeeyvOeyiBPs3LWq0GSXNfYzjzJvToBQ8G09GWQ2GGQDqogKsds4CPWshdQ3YWbnlgkpo7jD2ubahzN4WafzlkRvwu18yjbb2gLadzlv6UegIgKDIdduK9Z4bf8OHQqDQAHqdZtoYgFwiNLKnw1gKIdQjYg)JxcnYZtcobwhKGaBJGadzlv6UegIgKn(SqoljBSQ1ztLhKUhew1geuTdYbzN4WafzJvnQR)XdsqG1rZeyi7ehgOiBSQrDMniKTuP7syiAqccSoCqGHSLkDxcdrdYoXHbkYomp5OAZflzJplKZsYgdyDbuECMEzqFhew16SPYds3dcRAdcQ2bbXG(oix)3RZdWXsL8cvAwm0NDsNb4SiB8pEj0ippj4eyDqccSoGGadzlv6UegIgKn(SqoljBx)3RJvnQuY5935rI1piOgutnpiDpiOniO7guIdRbHkLWAcFqFhegW6cO84m9YG(oix)3RZdWXsL8cvAwm0NDsNb4Sg03bP5bHbGfdWz1pJBLhL7xu9gwF)e20k(GGAqqmOVdcdalgGZQ)mEWPGh95F)9tytR4dcQbbXGGdFqyayXaCw9Z4w5r5(fvVH13pHnTIpifhutd67GWaWIb4S6pJhCk4rF(3F)e20k(GGAqnnOVdcRAdcQb10GGdFqyayXaCw9Z4w5r5(fvVH13pHnTIpiOgutd67GWaWIb4S6pJhCk4rF(3F)e20k(GuCqnnOVdcRAdcQbPGdco8bHvToBQ8G09GWQ2GuSDqog03bjLCE)9WyfAaOSPYdsXbbXG01GGdFqU(VxhRAuPKZ7VZJeRFqqnihnpOVd6zEQb9e20k(GuCqkuYoXHbkYMR1QYkpk(YsO6nSEsqG1rteyiBPs3LWq0GStCyGISDxjwpWpO6nSEYgFwiNLKngW6cO84m9YG(oinpOixsfDUCszXFxQ0Djmd67GWaWIb4S6C5KYI)(jSPv8bP4GAAqWHpimaSyaoR(zCR8OC)IQ3W67NWMwXheudYXG(oimaSyaoR(Z4bNcE0N)93pHnTIpiOgKJbbh(GWaWIb4S6NXTYJY9lQEdRVFcBAfFqkoOMg03bHbGfdWz1Fgp4uWJ(8V)(jSPv8bb1GAAqFhew1geudcIbbh(GWaWIb4S6NXTYJY9lQEdRVFcBAfFqqnOMg03bHbGfdWz1Fgp4uWJ(8V)(jSPv8bP4GAAqFhew1geudQPbbh(GWQ2GGAqqBqWHpix)3R7c0t1EaC3x7G0fzJ)XlHg55jbNaRdsqG1HcsGHSLkDxcdrdYoXHbkYomp5OAZflzJplKZsYgdyDbuECMEzqFhew16SPYds3dcRAdcQ2bbbzJ)XlHg55jbNaRdsqG1b0iWq2wfYD(AdY2bzN4Wafz)w)w5r5YPvQGQ3W6jBPs3LWq0GeeyD04eyiBPs3LWq0GStCyGISDxjwpWpO6nSEYgFwiNLKngW6cO84m9YG(oimaSyaoR(Z4bNcE0N)93pHnTIpifhutd67GWQ2GAheed67G0Esdupmt3rpmp5OAZf7G(oiPKZ7VhgRqdafAnpifhKdYg)JxcnYZtcobwhKGaRdfkbgYwQ0Djmeni7ehgOiB3vI1d8dQEdRNSXNfYzjzJbSUakpotVmOVdsk58(7HXk0aqztLhKIdcIb9DqAEqyvRZMkpiDpiSQnifBhKJbbh(G0Esdupmt3rpmp5OAZf7G0fzJ)XlHg55jbNaRdsqcYMlNuw8tGHaRdcmKTuP7syiAq24Zc5SKSD9FVoxoPS4VFcBAfFqkoihdco8bL4WAqOsjSMWheudYbzN4Wafz)mEWPGh95F)KGaleeyiBPs3LWq0GSXNfYzjzJbSUakpotVmOVdsZdkXH1GqLsynHpiOgeedco8bL4WAqOsjSMWheudYXG(oiOFqyayXaCw9Z4w5r5(fvVH1391oiDr2jomqr2CTwvw5rXxwcvVH1tccSnrGHSLkDxcdrdYoXHbkY(mUvEuUFr1By9Kn(SqoljBmG1fq5Xz6fYg)JxcnYZtcobwhKGaRcsGHSLkDxcdrdYgFwiNLKngW6cO84m9YG(oinpix)3RZKfwOGhfRAkG191oi4WhKR)71zYcluWJIvnfWOPMkNfs3x7G0fzN4WafzZ1AvzLhfFzju9gwpjiWcncmKTvHCNV2GApY2dZ0pHnTI32mzN4Wafz)mEWPGh95F)KTuP7syiAqccSnobgYwQ0Djmeni7ehgOi7NXdk4rdvH6u1cHgMNCKn(SqoljBSQnifhutKn(hVeAKNNeCcSoibbwfkbgYwQ0Djmeni7ehgOiB3vI1d8dQEdRNSXNfYzjzJbSUakpotVmi4Whe0pOixsfDvlOyaRlOlv6UegYg)JxcnYZtcobwhKGaBJsGHStCyGIS5ATQSYJIVSeQEdRNSLkDxcdrdsqcsq2nih3afbwiAgIMD0meqJSDMxzLhNS1KXQfCHWmOgDqjomqnOLXdEF(q2ApWZwczRWdQX0kgN5sVCdstoO0pFu4bbDdhax5geeqdYbbrZq088z(OWdsHqzb7hcZGCLh4KbHbSUzmixXZkEFqAsySOn4dQaLUvZJ95VguIddu8bbQ1FF(K4WafVR9emG1ndLA15TeUk(YxmFsCyGI31EcgW6MHsT60qEw6UeiRKvAv2xkkOO(CHgNv6LasG2wUeq2qU8L2MNpjomqX7ApbdyDZqPwDWQg11)4bK2Rf6JCjv05YjLf)DPs3LWaho0h5sQO)mEqbpAOkuNQwi0W8KRlv6UeM5tIddu8U2tWaw3muQvhSQrDMniqAVwOpYLurxk58mn1kpQSmLLRlv6UeM5Z8rHhKcHYc2peMbjni3)GcJvguOkdkXb4gKXhu2qAR0Dj95tIddu8wUwjpQAwmuECMEz(OWdQXM8S0DjdkuZyqoT1AqHSwd6h4pi7nOFG)GCAR1GkryguagKZ0IbfGbHtEmiyakK6WagubIb5mRyqbyq4KhdYIbLXGY1Aqz9Zcoz(K4WafxPwDAiplDxcKvYkTQGfdvzFPGeOTLlbKnKlFPfdalgGZQBvda9cvzFPOHQqDQAHqdZtU(jSPvCOEMNAqpHnTIdh(Z8ud6jSPvCfDarZFFMNAqpHnTIdfgawmaNvNlNuw83pHnTI)fdalgGZQZLtkl(7NWMwXHYrZZhfEqnsUmiTGWa1GS3G2YjLf)dY4dYxlKdcCdYfeQdARqaDguwmdcgGc5GYtgKVwihe4guOkdkYZtIb50wRbXyYGCAHQvdQXBEqCbdkg(8jXHbkUsT6OfegOG0ETA21)96C5KYI)UVw4WD9FVopahlvYluPzXqF2jDFT66Rwj6k7lfnufQtvleAyEY1tCyniWH)mp1GEcBAfxX2gV55JcpinrUwdkuLbTLtkl(huIddudAz8yq2BqB5KYI)bz8bH9VtQy9piFTZNehgO4k1QdoxlAIddu0LXdiRKvA5YjLf)qAVwx)3RZLtkl(7(ANpk8GguJKldc6aIgtygK9g0G(b(dkpzqSgNBL3GYyqlj5XGAAqyvdYbPjvmd6h4piXcv5guEYGsxGFmOamiCQDqsjN3pKdcCdIlNuw8piJpO0f4hdkadcdyLb5RfYbbUbbDaqNbz8bHbSw5niFTdklMb9d8hKtBTgeo1oiPKZ7FqCaOMpjomqXvQvhCUw0ehgOOlJhqwjR0c0kLCqAV2WyffH2xSQPi0(c9ALORSVu0qvOovTqOH5jxpXH1GmFsCyGIRuRopJhuWJgQc1PQfcnmp5Ge)JxcnYZtcERdiTxlw16SPY6gRAq120xnlLCE)9WyfAaOSPYk6aoCPKZ7VhgRqdaLnvwrf8lgawmaNv)z8Gtbp6Z)(7NWMwXv0rhA6A(K4WafxPwDeL1klQAESqAVwSQ1ztL1nw1GQ1HscNlfw6yq9wgoOzXq5XzpPZMka4(QzPKZ7VhgRqdaLnvwrhWHJbGfdWz15YjLf)9tytR4kcbC4sjN3FpmwHgakBQSIk4xmaSyaoR(Z4bNcE0N)93pHnTIROJo0018jXHbkUsT6eMNCuT5Ifs8pEj0ippj4ToG0ETyaRlGYJZ0lFXQwNnvw3yvdQwi(QzPKZ7VhgRqdaLnvwrhWHJbGfdWz15YjLf)9tytR4kcbC4sjN3FpmwHgakBQSIk4xmaSyaoR(Z4bNcE0N)93pHnTIROJo0018jXHbkUsT6GZ1IM4WafDz8aYkzLwmdLlpiTxl0h5sQOZLtkl(7sLUlHz(K4WafxPwDW5ArtCyGIUmEazLSslMHYLtkl(H0ETrUKk6C5KYI)UuP7syMpk8G0e5AnOqvg0gMbL4Wa1GwgpgK9guOkNmO8KbbXGa3GwcNpiPewt4ZNehgO4k1QdoxlAIddu0LXdiRKvA5bK2RnXH1GqLsynHRytZhfEqAICTguOkdstcOqmOehgOg0Y4XGS3Gcv5KbLNmOMge4gel4KbjLWAcF(K4WafxPwDW5ArtCyGIUmEazLSsBceiTxBIdRbHkLWAchQ2MMpZhfEqAs4WafVRjbuigKXhKvHumcZGEGBq(CzqoTqDqn2fCyyQMeddvtSKSbzqzXmiS)DsfR)bvIWWhuagKRmiG2WynnvyMpjomqX7jqADQA3YkpkZLEGIQ1VWQZNehgO49eik1QJuY5zAQvEuzzkBhK2RfRAD2uzDJvnOAH4RuY593dJvObGYMkdvtWHJvToBQSUXQguTk4xnlLCE)9WyfAaOSPYqbbC4qV2tAG6Hz6o6H5jhvBUy118jXHbkEpbIsT6W1AvzLhfFzju9gwpK2RfdyDbuECME5RMD9FVotwyHcEuSQPaw3xlC4U(VxNjlSqbpkw1uaJMAQCwiDFT6A(K4WafVNarPwDEgp4uWJ(8VFiTxRuY593dJvObGYMkdLOSG9dHggROBhWH76)EDEaowQKxOsZIH(St6NWMwXNpjomqX7jquQvNZ4w5r5(fvVH1dj(hVeAKNNe8whqAVwnh5sQO7u1ULvEuMl9afvRFHv7sLUlH5lgawmaNv)mUvEuUFr1By9Dg)ldduqHbGfdWz1DQA3YkpkZLEGIQ1VWQ9tytR4k1KU(QzmaSyaoR(Z4bNcE0N)93pHnTIdvtWHJvnOAHMUMpjomqX7jquQvNZNRALhvbsgH60kgiTxRR)71pFUQvEufizeQtRy6maN18jXHbkEpbIsT6W1AvzLhfFzju9gwpK2RfdyDbuECME5RM1mw1GQj4WXaWIb4S6pJhCk4rF(3F)e20kounUU(QzSQbvl0GdhdalgGZQ)mEWPGh95F)9tytR4qbHUGdxk58(7HXk0aqztLvSTjDnFsCyGI3tGOuRoIYALfvnpwiTxlw16SPY6gRAq16qjHZLclDmOEldh0SyO84SN0ztfaCZNehgO49eik1Qdw1OU(hpG0ETyvRZMkRBSQbvRJehgO49eik1QZZ4bf8OHQqDQAHqdZtoiX)4LqJ88KG36as71IvToBQSUXQguTnnFsCyGI3tGOuRoH5jhvBUyHe)JxcnYZtcERdiTxlw16SPY6gRAq1cXxnd9rUKk6QwqXawxqxQ0DjmWHJbSUakpotVOR5tIddu8EceLA1bRAuNzdcK2RfdyDbuECMEz(K4WafVNarPwDERFR8OC50kvq1By9qAVwx)3R7c0t1EaCNb4SG0QqUZxB06y(K4WafVNarPwDCxjwpWpO6nSEiX)4LqJ88KG36as71IbSUakpotV8vZU(Vx3fONQ9a4UVw4WJCjv0vTGIbSUGUuP7sy(Q9KgOEyMUJEyEYr1Ml2VAgRAD2uzDJvnOAD8vk58(7HXk0aqHwZk6aoCSQ1cXxmaSyaoR(Z4bNcE0N)93pHnTIRyt6sxZNehgO49eik1QJ7kX6b(bvVH1dj(hVeAKNNe8whqAVwmG1fq5Xz6LVyvRZipdBrBZF1Esdupmt3rNR1QYkpk(YsO6nS(5Z8z(OWdAhGJfYbPqKxOc5GYIzqqh7KbPjaGfdWzXNpjomqX7ygkxETw1aqVqv2xkAOkuNQwi0W8Kds71c9nKNLUlPRcwmuL9Lco8N5Pg0tytR4kcb0MpjomqX7ygkxEk1QZlxlPOGJrU5tIddu8oMHYLNsT64ckHXNhu3tCoFsCyGI3XmuU8uQvhNsQfuCk4rbhJCZhfEqnsUminPdNLmiya3jvmi7nOFG)GYtgeRX5w5nOmg0ssEmihdstOAZNehgO4DmdLlpLA1jpCwcna3jvaP9AXQwNnvw3yvdQwhZNehgO4DmdLlpLA1ja(yvk4rzKmuH0ETrEEs0vLCfQDT4qXwhq7RR)715b4yPsEHknlg6ZoPZaCwZNehgO4DmdLlpLA1XDbamuWJgQcvkH9hs71IbGfdWz1Fgp4uWJ(8V)(jSPvCfHao8N5Pg0tytR4k6aI5tIddu8oMHYLNsT645NhJLff8OPMkhiuNpjomqX7ygkxEk1QJtWTyAqSIEchuzHL5tIddu8oMHYLNsT6GbfwQ4YqyOVvYkqAVwONbeDmOWsfxgcd9TswH66Fv)e20k(xnRzOpYLur3PQDlR8Omx6bkQw)cR2LkDxcdC4yayXaCwDNQ2TSYJYCPhOOA9lSA)e20kUU(IbGfdWz1pJBLhL7xu9gwF)e20k(xmaSyaoR(Z4bNcE0N)93pHnTI)11)968aCSujVqLMfd9zN0zaolDbh(Z8ud6jSPvCfB05tIddu8oMHYLNsT6eQc1VCb(fd9boSmFsCyGI3XmuU8uQvhT(N9(TYJ6UsEmFsCyGI3XmuU8uQvNtsTw5rFRKv4qAV2ippj6HXk0aq1IdkendvtndhEKNNeDvjxHAxlouSfIMNpjomqX7ygkxEk1QZdG95cdn1u5SqOUsYoFsCyGI3XmuU8uQvhwHfC)uWJU8XgdL5KKLdP9ALsoVFfvWMNpjomqX7ygkxEk1QZzA1UeQvuU2elZNehgO4DmdLlpLA1HhGJLk5fQ0SyOp7eiTxlgawmaNvNhGJLk5fQ0SyOp7KownppH3cbC4pZtnONWMwXveIMHd31)96CrcvR8Ox6jDFTWHRzmaSyaoRU7cayOGhnufQuc7F)e20kUsoGcdalgGZQZdWXsL8cvAwm0NDs)5Vw0tWQ55j0Wyf4WHEHZLclD3faWqbpAOkuPe2)oBQaGtxFXaWIb4S6pJhCk4rF(3F)e20kUIoA(lw1GQfIVyayXaCwDNQ2TSYJYCPhOOA9lSA)e20kUIoGy(K4WafVJzOC5PuRo(CHAHWczLSsBYvBilHtVutbhfdUCnFsCyGI3XmuU8uQvNa4JvPGhvFESjKwfY1qUABendPwCqvLCfQTn3H28rHhuJKldsJfaWmiOJ)9pi7niya(y1bbEdsHuYqf6E(GWaWIb4SgKXhK3jzi3Gc1SgutnpinhQgFqwHx(mcFqovTLmiyakKdY4dc7FNuX6FqjoSgeDb5Ga3GaV3GWaWIb4SgKtvPg0pWFq5jdsfSySYBqGkadcgGcjKdcCdYPQudkuLbf55jXGm(GsxGFmOamigtMpjomqX7ygkxEk1QJ7cayOp)7hs71(mp1GEcBAfhkhqan4WD9FVopahlvYluPzXqF2jDFTWH)mp1GEcBAfxriAE(K4WafVJzOC5PuRoUYXLtVvEqAV2N5Pg0tytR4q5OrHgC4U(VxNhGJLk5fQ0SyOp7KUVw4WFMNAqpHnTIRienpFsCyGI3XmuU8uQvNL5PgCQc4Z4XkvmFsCyGI3XmuU8uQvNNDI7cayG0ETpZtnONWMwXHYbeqdoCx)3RZdWXsL8cvAwm0NDs3xlC4pZtnONWMwXveIMNpjomqX7ygkxEk1QtwyHhxUO4CTG0ETpZtnONWMwXHYrJcn4WD9FVopahlvYluPzXqF2jDFTWH)mp1GEcBAfxriAoXHbkEhZq5YtPwDCtpk4rJZW65qAVwx)3RZdWXsL8cvAwm0NDsNb4SMpZhfEqB5KYI)bPjaGfdWzXNpjomqX7ygkxoPS4VTH8S0DjqwjR0YLtkl(PU(hpGeOTLlbKnKlFPfdalgGZQZLtkl(7NWMwXv0bC4pZtnONWMwXveIMNpjomqX7ygkxoPS4xPwDSQbGEHQSVu0qvOovTqOH5jhK2Rf6BiplDxsxfSyOk7lfC4pZtnONWMwXvecOnFsCyGI3XmuUCszXVsT68Y1skk4yKB(K4WafVJzOC5KYIFLA1XfucJppOUN4C(K4WafVJzOC5KYIFLA1XPKAbfNcEuWXi38jXHbkEhZq5YjLf)k1QJNFEmwwuWJMAQCGqfs71(mp1GEcBAfhkhnk0GdVH8S0DjDUCszXp11)4bC4pZtnONWMwXvSjOnFsCyGI3XmuUCszXVsT64eClMgeRONWbvwybs712qEw6UKoxoPS4N66F8y(K4WafVJzOC5KYIFLA1XDbamuWJgQcvkH9hs712qEw6UKoxoPS4N66F8y(K4WafVJzOC5KYIFLA1bdkSuXLHWqFRKvG0ETAgdalgGZQZLtkl(7NWMwXHdhdalgGZQJbfwQ4YqyOVvYkDSAEEcVfcD9f6zarhdkSuXLHWqFRKvOU(x1pHnTI)vZyayXaCw9Z4w5r5(fvVH13pHnTI)fdalgGZQ)mEWPGh95F)9tytR4WH)mp1GEcBAfxXgvxZNehgO4DmdLlNuw8RuRoHQq9lxGFXqFGdlZNehgO4DmdLlNuw8RuRoA9p79BLh1DL8y(K4WafVJzOC5KYIFLA15KuRvE03kzfoK2RnYZtIEyScnauT4GcrZq1uZWHh55jrxvYvO21IdfBHOz4WJ88KOhgRqdaLXefHy(K4WafVJzOC5KYIFLA15bW(CHHMAQCwiuxjzNpjomqX7ygkxoPS4xPwDyfwW9tbp6YhBmuMtswoK2Rvk58(vubBE(K4WafVJzOC5KYIFLA15mTAxc1kkxBIL5tIddu8oMHYLtkl(vQvh3faWqF(3pK2R9zEQb9e20kouoGaAWH3qEw6UKoxoPS4N66F8y(K4WafVJzOC5KYIFLA1XvoUC6TYds71(mp1GEcBAfhkhnk0GdVH8S0DjDUCszXp11)4X8jXHbkEhZq5YjLf)k1QtE4SeAaUtQas71IvToBQSUXQguToMpjomqX7ygkxoPS4xPwDwMNAWPkGpJhRuX8jXHbkEhZq5YjLf)k1QZZoXDbamqAV2N5Pg0tytR4q5acObhEd5zP7s6C5KYIFQR)XJ5tIddu8oMHYLtkl(vQvNSWcpUCrX5AbP9AFMNAqpHnTIdLdiGgC4nKNLUlPZLtkl(PU(hpMpjomqX7ygkxoPS4xPwDCtpk4rJZW65qAV2gYZs3L05YjLf)ux)JhZNehgO4DmdLlNuw8RuRo(CHAHWczLSsBYvBilHtVutbhfdUCnFsCyGI3XmuUCszXVsT6eaFSkf8OmsgQqAV2ippj6QsUc1UwCOyRdOnFsCyGI3XmuUCszXVsT6eaFSkf8O6ZJnH0QqUgYvBJOzi1IdQQKRqTT5o0MpjomqX7ygkxoPS4xPwD4YjLf)qAVwmaSyaoR(zCR8OC)IQ3W67NWMwXvec4WFMNAqpHnTIROdOnFsCyGI3XmuUCszXVsT64MEuWJgNH1ZNpZhfEqq30kLCZNehgO4DGwPKR9z8GcE0qvOovTqOH5jhK4F8sOrENNe8whqAVwSQ1ztL1nw1GQTP5tIddu8oqRuYPuRoIYALfvnpwiTxBKlPIow1OU(hp6sLUlH5lw16SPY6gRAq1208jXHbkEhOvk5uQvNW8KJQnxSqI)XlHg55jbV1bK2RfdyDbuECME5lw16SPY6gRAq1cX8jXHbkEhOvk5uQvhrzTYIQMh78jXHbkEhOvk5uQvNW8KJQnxSqI)XlHg55jbV1bK2RfRAD2uzDJvnOAHy(mFu4b1yDg4S4FqnMQ2sg0woPS4FqAY4dQrQD(K4WafVZLtkl(BFgp4uWJ(8VFiTxRR)715YjLf)9tytR4k6ao8ehwdcvkH1eouoMpjomqX7C5KYIFLA1HR1QYkpk(YsO6nSEiTxlgW6cO84m9YxnN4WAqOsjSMWHcc4WtCyniuPewt4q54l0JbGfdWz1pJBLhL7xu9gwF3xRUMpjomqX7C5KYIFLA15mUvEuUFr1By9qI)XlHg55jbV1bK2RfdyDbuECMEz(K4WafVZLtkl(vQvhUwRkR8O4llHQ3W6H0ETyaRlGYJZ0lF1SR)71zYcluWJIvnfW6(AHd31)96mzHfk4rXQMcy0utLZcP7RvxZhfEqWOA8b50wRbHtEmiOda6mOSygKvHCNV2yqHQmiSAwLSgK9guOkdQXwnHc5Gm(Gojz(huwmdIdyLq1kVbPAEQYniqnOqvgK2ZaNf)dAz8yqAUXydDPRbz8bLnKM7sMpjomqX7C5KYIFLA15z8Gtbp6Z)(H0QqUZxBqTxRhMPFcBAfVT55tIddu8oxoPS4xPwDEgpOGhnufQtvleAyEYbj(hVeAKNNe8whqAVwSQPytZhfEqnsUminaqxqoilgKtBTgeOw)dY9Ku)GytEi3)GS3GASBXG0eawxWGm(GGf6gmdkYLuHWmFsCyGI35YjLf)k1QJ7kX6b(bvVH1dj(hVeAKNNe8whqAVwmG1fq5Xz6f4WH(ixsfDvlOyaRlOlv6UeM5tIddu8oxoPS4xPwD4ATQSYJIVSeQEdRF(mFu4bTTYBjdkYZtIb1yDg4S4F(K4WafVZJwNQ2TSYJYCPhOOA9lS68jXHbkENhk1QJuY5zAQvEuzzkBhK2RfRAD2uzDJvnOAH4RuY593dJvObGYMkdvtWHJvToBQSUXQguTk4xnlLCE)9WyfAaOSPYqbbC4qV2tAG6Hz6o6H5jhvBUy118jXHbkENhk1QdxRvLvEu8LLq1By9qAVwmG1fq5Xz6LVA21)96mzHfk4rXQMcyDFTWH76)EDMSWcf8OyvtbmAQPYzH091QR5tIddu8opuQvNNXdof8Op)7F(OWdQrYLb1ySHUgeOguKNNe8b50cvGFmin55PFqG3GcvzqAIllzqmIR)7b5GS3G0c4CZDjqoOSygK9g0woPS4FqgFqzmOLK8yqqmiUGbfdFqPZ8F(K4WafVZdLA15mUvEuUFr1By9qI)XlHg55jbV1bK2RfdalgGZQZLtkl(7NWMwXHYbC4qFKlPIoxoPS4Vlv6UeM5tIddu8opuQvNZNRALhvbsgH60kgiTxRR)71pFUQvEufizeQtRy6maN13ehwdcvkH1eouoMpjomqX78qPwDeL1klQAESqAVwSQ1ztL1nw1GQ1HscNlfw6yq9wgoOzXq5XzpPZMka4MpjomqX78qPwDEgpOGhnufQtvleAyEYbj(hVeAKNNe8whqAVwSQPytZhfEqnsUminHgdYEd6h4pO8KbXcozqHAwdQ5bPjuTbLoZ)b9oa7GytLhuwmdsnBqgKJbjLW(d5Ga3GYtgel4KbfQznihdstOAdkDM)d6Da2bXMkpFsCyGI35HsT6GvnQR)XdiTxlw16SPY6gRAq16y(K4WafVZdLA1bRAuNzdY8rHhuJKldcMgRbzVb9d8huEYGuWbbUbXcozqyvBqPZ8FqVdWoi2u5bLfZGGbOqoOSyg0wHa6mO8Kb5cc1bvGyq(ANpjomqX78qPwDcZtoQ2CXcj(hVeAKNNe8whqAVwmG1fq5Xz6LVyvRZMkRBSQbvleFD9FVopahlvYluPzXqF2jDgGZA(K4WafVZdLA1HR1QYkpk(YsO6nSEiTxRR)71XQgvk58(78iX6HQPM1n0GUlXH1GqLsynH)fdyDbuECME5RR)715b4yPsEHknlg6ZoPZaCwF1mgawmaNv)mUvEuUFr1By99tytR4qbXxmaSyaoR(Z4bNcE0N)93pHnTIdfeWHJbGfdWz1pJBLhL7xu9gwF)e20kUIn9fdalgGZQ)mEWPGh95F)9tytR4q10xSQbvtWHJbGfdWz1pJBLhL7xu9gwF)e20koun9fdalgGZQ)mEWPGh95F)9tytR4k20xSQbLcchow16SPY6gRAk264RuY593dJvObGYMkRie6coCx)3RJvnQuY5935rI1dLJM)(mp1GEcBAfxrf68rHhuJKldsda01GS3GCbH6GGoaOZGYIzqngBORbLNmOcedcVaCbYbbUb1ySHUgKXheEb4YGYIzqqha0zqgFqfigeEb4YGYIzq)a)bPMnidIfCYGc1SgeedcRAqoiWniOda6miJpi8cWLb1ySHUgKXhubIbHxaUmOSyg0pWFqQzdYGybNmOqnRb10GWQgKdcCd6h4pi1SbzqSGtguOM1GG2GWQgKdcCdYEd6h4pipjguoiThapFsCyGI35HsT64UsSEGFq1By9qI)XlHg55jbV1bK2RfdyDbuECME5RMJCjv05YjLf)DPs3LW8fdalgGZQZLtkl(7NWMwXvSj4WXaWIb4S6NXTYJY9lQEdRVFcBAfhkhFXaWIb4S6pJhCk4rF(3F)e20kouoGdhdalgGZQFg3kpk3VO6nS((jSPvCfB6lgawmaNv)z8Gtbp6Z)(7NWMwXHQPVyvdkiGdhdalgGZQFg3kpk3VO6nS((jSPvCOA6lgawmaNv)z8Gtbp6Z)(7NWMwXvSPVyvdQMGdhRAqbn4WD9FVUlqpv7bWDFT6A(K4WafVZdLA1jmp5OAZflK4F8sOrEEsWBDaP9AXawxaLhNPx(IvToBQSUXQguTqmFu4b1i5YGGoBORbLfZGSkK781gdYIbXJlnp1yqPZ8F(K4WafVZdLA15T(TYJYLtRubvVH1dPvHCNV2O1X8rHhuJKldsda01GS3GGoaOZGm(GWlaxguwmd6h4pi1SbzqqmiSQnOSyg0pW)g0k5XG8wa3CniNjFqW0yb5Ga3GS3G(b(dkpzqPlWpguageo1oiPKZ7FqzXmiXcv5g0pW)g0k5XG8WmdYzYhemnwdcCdYEd6h4pO8KbTeoFqHAwdcIbHvTbLoZ)b9oa7GWPwTw5nFsCyGI35HsT64UsSEGFq1By9qI)XlHg55jbV1bK2RfdyDbuECME5lgawmaNv)z8Gtbp6Z)(7NWMwXvSPVyvRfIVApPbQhMP7OhMNCuT5I9RuY593dJvObGcTMv0X8jXHbkENhk1QJ7kX6b(bvVH1dj(hVeAKNNe8whqAVwmG1fq5Xz6LVsjN3FpmwHgakBQSIq8vZyvRZMkRBSQPyRd4W1Esdupmt3rpmp5OAZfRUi70pubhzVnwnbjibHa]] )

end