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
    
    spec:RegisterPack( "Windwalker", 20201029, [[dSKzJbqiqk9isqTjq4tsrsPrrQKtrQuRsksQEfPWSar3Iuu7sQ(fPIHjf1XOcltvPNjfAAKaDnqQ2gif(MuemoPi6CKG08iHUNuAFGKdscclKe1djfHjscIUiPiYgLIuFukskgjifvojPiQwPQIxcsrUjPik7eu6NGuugQuKWsLIK8uLAQGIRkfH2kifv9vPir7fXFrAWqoSOftLEmutgfxMyZQYNPkJMKonLvtc41KQMTsUnkTBj)gy4KslxLNJQPlCDQQTlf8DQOXtICEvvRNuKMpOA)kM4GadzZKHqG9BZFB2rZn2CV5MHo0OXMKSJFTczRnX6tpHSRKvi7MsRyCMl9Yr2AZ)fiziWq2CG)HfYMSD9TvOjViUKntgcb2Vn)Tzhn3yZ9MBg6q)7xYMRvWey)cnuOKTQXWifXLSzeoMSv4b1uAfJZCPxUbPjdu6Npk8GGMHdGRCd6RcfYb9T5Vnt2lJhCcmKnMHYLhbgcSoiWq2sLUlHHOmzJplKZsYgAhud5zP7s6QGfdvjFPgeC4d6zEQb9e20k(GuCqFHozN4WafzBvda9cvjFPibb2Veyi7ehgOi7xUwsrbhJCKTuP7syiktccSnsGHStCyGISDbLW4ZdQ7jojBPs3LWquMeeyvqcmKDIdduKTtj1ckof8OGJroYwQ0DjmeLjbbwOtGHSLkDxcdrzYgFwiNLKnw16SPsdsZdcRAdcQ2b5GStCyGISZdNLqdWDsfKGal0Gadzlv6UegIYKn(Sqolj7ippj6QsUc1UwCmifBhKdOpiigKR)715b4yPsEHknlg6ZoPZaCwKDIdduKDa8XQuWJYizOsccSnbcmKTuP7syikt24Zc5SKSXaWIb4S6pJhCk4rF(3F)e20k(GuCqFheC4d6zEQb9e20k(GuCqo(s2jomqr2UlaGHcE0qvOsjS)KGaBtsGHStCyGIS98ZJXYIcE0utLdeQKTuP7syiktccSkucmKDIdduKTtWTyAqSIEchuzHfYwQ0DjmeLjbbwhntGHSLkDxcdrzYgFwiNLKn0oigq0XGclvCzim03kzfQR)v9tytR4dcIbPRbPRbbTdkYLur3PQDlR8Omx6bkQw)cR2LkDxcZGGdFqyayXaCwDNQ2TSYJYCPhOOA9lSA)e20k(G09GGyqyayXaCw9Z4w5r5(fvVH13pHnTIpiigegawmaNv)z8Gtbp6Z)(7NWMwXheedY1)968aCSujVqLMfd9zN0zaoRbP7bbh(GEMNAqpHnTIpifhuts2jomqr2yqHLkUmeg6BLScjiW6WbbgYoXHbkYoufQF5c8lg6dCyHSLkDxcdrzsqG1XxcmKDIdduKTw)ZE)w5rDxjpiBPs3LWquMeeyD0ibgYwQ0DjmeLjB8zHCws2rEEs0dJvObGQfh0VnpiOguJnpi4WhuKNNeDvjxHAxlogKITd6BZKDIdduK9jPwR8OVvYkCsqG1HcsGHStCyGISFaSpxyOPMkNfc1vswYwQ0DjmeLjbbwhqNadzlv6UegIYKn(SqoljBPKZ7FqkoifSzYoXHbkYMvyb3pf8OlFSXqzojz5KGaRdObbgYoXHbkY(mTAxc1kkxBIfYwQ0DjmeLjbbwhnbcmKTuP7syikt24Zc5SKSXaWIb4S68aCSujVqLMfd9zN0XQ55j8b1oOVdco8b9mp1GEcBAfFqkoOVnpi4WhKR)715IeQw5rV0t6(AheC4dsxdcdalgGZQ7Uaagk4rdvHkLW(3pHnTIpingKJbb1GWaWIb4S68aCSujVqLMfd9zN0F(Rf9eSAEEcnmwzqWHpiODqcNlfw6UlaGHcE0qvOsjS)D2uba3G09GGyqyayXaCw9NXdof8Op)7VFcBAfFqkoihnpiigew1geuTd67GGyqyayXaCwDNQ2TSYJYCPhOOA9lSA)e20k(GuCqo(s2jomqr28aCSujVqLMfd9zNqccSoAscmKTuP7syikt2vYkKDYvBilHtVutbhfdUCr2jomqr2jxTHSeo9snfCum4YfjiW6qHsGHSTkKRHCr2k0MjBT4GQk5kuj7M7qNStCyGISdGpwLcEu95XMKTuP7syiktccSFBMadzlv6UegIYKn(Sqolj7N5Pg0tytR4dcQb54l0heC4dY1)968aCSujVqLMfd9zN091oi4Wh0Z8ud6jSPv8bP4G(2mzN4Wafz7Uaag6Z)(jbb2VoiWq2sLUlHHOmzJplKZsY(zEQb9e20k(GGAqoAsOpi4WhKR)715b4yPsEHknlg6ZoP7RDqWHpON5Pg0tytR4dsXb9TzYoXHbkY2voUC6TYJeey)(LadzN4WafzVmp1GtvaFgpwPcYwQ0DjmeLjbb2VnsGHSLkDxcdrzYgFwiNLK9Z8ud6jSPv8bb1GC8f6dco8b56)EDEaowQKxOsZIH(St6(AheC4d6zEQb9e20k(GuCqFBMStCyGISF2jUlaGHeey)QGeyiBPs3LWquMSXNfYzjz76)EDEaowQKxOsZIH(St6maNfzN4WafzNfw4XLlkoxlsqcYobcbgcSoiWq2jomqr2ovTBzLhL5spqr16xyvYwQ0DjmeLjbb2VeyiBPs3LWquMSXNfYzjzJvToBQ0G08GWQ2GGQDqFheedsk58(7HXk0aqztLgeudQXbbh(GWQwNnvAqAEqyvBqq1oifCqqmiDniPKZ7VhgRqdaLnvAqqnOVdco8bbTds7jnq9WmDh9W8KJQnxSds3KDIdduKTuY5zAQvEuzzkzhjiW2ibgYwQ0DjmeLjB8zHCws2yaRlGYJZ0ldcIbPRb56)EDMSWcf8OyvtbSUV2bbh(GC9FVotwyHcEuSQPagn1u5Sq6(AhKUj7ehgOiBUwRkR8O4llHQ3W6jbbwfKadzlv6UegIYKn(SqoljBPKZ7VhgRqdaLnvAqqnirjb7hcnmwzqAEqogeC4dY1)968aCSujVqLMfd9zN0pHnTIt2jomqr2pJhCk4rF(3pjiWcDcmKTuP7syikt2jomqr2NXTYJY9lQEdRNSXNfYzjzRRbf5sQO7u1ULvEuMl9afvRFHv7sLUlHzqqmimaSyaoR(zCR8OC)IQ3W67m(xggOgeudcdalgGZQ7u1ULvEuMl9afvRFHv7NWMwXhKgdQXbP7bbXG01GWaWIb4S6pJhCk4rF(3F)e20k(GGAqnoi4Whew1geuTdc6ds3Kn(hVeAKNNeCcSoibbwObbgYwQ0DjmeLjB8zHCws2U(Vx)85Qw5rvGKrOoTIPZaCwKDIdduK95ZvTYJQajJqDAfdjiW2eiWq2sLUlHHOmzJplKZsYgdyDbuECMEzqqmiDniDniSQniOguJdco8bHbGfdWz1Fgp4uWJ(8V)(jSPv8bb1GGgds3dcIbPRbHvTbbv7GG(GGdFqyayXaCw9NXdof8Op)7VFcBAfFqqnOVds3dco8bjLCE)9WyfAaOSPsdsX2b14G0nzN4WafzZ1AvzLhfFzju9gwpjiW2KeyiBPs3LWquMSXNfYzjzJvToBQ0G08GWQ2GGQDqogKgds4CPWshdQ3YWbnlgkpo7jD2ubahzN4WafzlkPvwu18yjbbwfkbgYwQ0DjmeLjB8zHCws2yvRZMkninpiSQniOAhuJKDIdduKnw1OU(hpiB8pEj0ippj4eyDqccSoAMadzlv6UegIYKDIdduKDyEYr1MlwYgFwiNLKnw16SPsdsZdcRAdcQ2b9DqqmiDniODqrUKk6QwqXawxqxQ0Djmdco8bHbSUakpotVmiDt24F8sOrEEsWjW6GeeyD4Gadzlv6UegIYKn(SqoljBmG1fq5Xz6fYoXHbkYgRAuNzdcjiW64lbgYwQ0DjmeLj7ehgOi7363kpkxoTsfu9gwpzJplKZsY21)96Ua9uTha3zaolY2QqUZxBq2oibbwhnsGHSLkDxcdrzYoXHbkY2DLy9a)GQ3W6jB8zHCws2yaRlGYJZ0ldcIbPRb56)EDxGEQ2dG7(AheC4dkYLurx1ckgW6c6sLUlHzqqmiTN0a1dZ0D0dZtoQ2CXoiigew1gu7G(oiigegawmaNv)z8Gtbp6Z)(7NWMwXhKIdQXbbh(GWQwNnvAqAEqyvBqk2oihdcIbP9KgOEyMUJoxRvLvEu8LLq1By9ds3Kn(hVeAKNNeCcSoibjiBg5L(RGadbwheyi7ehgOiBUwjpQAwmuECMEHSLkDxcdrzsqG9lbgYwQ0DjmeLjBGwYMlbzN4Wafz3qEw6UeYUHC5lKngawmaNv3Qga6fQs(srdvH6u1cHgMNC9tytR4dcQb9mp1GEcBAfFqWHpON5Pg0tytR4dsXb54BZdcIb9mp1GEcBAfFqqnimaSyaoRoxoPS4VFcBAfFqqmimaSyaoRoxoPS4VFcBAfFqqnihnt2nKhTswHSvblgQs(srccSnsGHSLkDxcdrzYgFwiNLKTUgKR)715YjLf)DFTdco8b56)EDEaowQKxOsZIH(St6(AhKUheedsReDL8LIgQc1PQfcnmp56joSgKbbh(GEMNAqpHnTIpifBhe0OzYoXHbkYwlimqrccSkibgYwQ0DjmeLjB8zHCws2U(VxNlNuw8391s2jomqr24CTOjomqrxgpi7LXdALSczZLtkl(jbbwOtGHSLkDxcdrzYgFwiNLKDySYGuCqqFqqmiSQnifhe0heedcAhKwj6k5lfnufQtvleAyEY1tCyniKDIdduKnoxlAIddu0LXdYEz8GwjRq2aTsjhjiWcniWq2sLUlHHOmzN4Wafz)mEqbpAOkuNQwi0W8KJSXNfYzjzJvToBQ0G08GWQ2GGQDqnoiigKUgKuY593dJvObGYMknifhKJbbh(GKsoV)EyScnau2uPbP4GuWbbXGWaWIb4S6pJhCk4rF(3F)e20k(GuCqo6qFq6MSX)4LqJ88KGtG1bjiW2eiWq2sLUlHHOmzJplKZsYgRAD2uPbP5bHvTbbv7GCmingKW5sHLoguVLHdAwmuEC2t6SPcaUbbXG01GKsoV)EyScnau2uPbP4GCmi4WhegawmaNvNlNuw83pHnTIpifh03bbh(GKsoV)EyScnau2uPbP4GuWbbXGWaWIb4S6pJhCk4rF(3F)e20k(GuCqo6qFq6MStCyGISfL0klQAESKGaBtsGHSLkDxcdrzYoXHbkYomp5OAZflzJplKZsYgdyDbuECMEzqqmiSQ1ztLgKMhew1geuTd67GGyq6AqsjN3FpmwHgakBQ0GuCqogeC4dcdalgGZQZLtkl(7NWMwXhKId67GGdFqsjN3FpmwHgakBQ0GuCqk4GGyqyayXaCw9NXdof8Op)7VFcBAfFqkoihDOpiDt24F8sOrEEsWjW6GeeyvOeyiBPs3LWquMSXNfYzjzdTdkYLurNlNuw83LkDxcdzN4WafzJZ1IM4WafDz8GSxgpOvYkKnMHYLhjiW6OzcmKTuP7syikt24Zc5SKSJCjv05YjLf)DPs3LWq2jomqr24CTOjomqrxgpi7LXdALSczJzOC5KYIFsqG1HdcmKTuP7syikt24Zc5SKStCyniuPewt4dsXb1izN4WafzJZ1IM4WafDz8GSxgpOvYkKnpibbwhFjWq2sLUlHHOmzJplKZsYoXH1GqLsynHpiOAhuJKDIdduKnoxlAIddu0LXdYEz8GwjRq2jqibjiBTNGbSUzqGHaRdcmKDIdduK9BjCv8LVGSLkDxcdrzsqG9lbgYwQ0DjmeLjBGwYMlbzN4Wafz3qEw6UeYUHC5lKDZKDd5rRKviBL8LIckQpxOXzLEjibb2gjWq2sLUlHHOmzJplKZsYgAhuKlPIoxoPS4Vlv6UeMbbh(GG2bf5sQO)mEqbpAOkuNQwi0W8KRlv6UegYoXHbkYgRAux)JhKGaRcsGHSLkDxcdrzYgFwiNLKn0oOixsfDPKZZ0uR8OYYusUUuP7syi7ehgOiBSQrDMniKGeKnxoPS4NadbwheyiBPs3LWquMSXNfYzjz76)EDUCszXF)e20k(GuCqogeC4dkXH1GqLsynHpiOgKdYoXHbkY(z8Gtbp6Z)(jbb2VeyiBPs3LWquMSXNfYzjzJbSUakpotVmiigKUguIdRbHkLWAcFqqnOVdco8bL4WAqOsjSMWheudYXGGyqq7GWaWIb4S6NXTYJY9lQEdRV7RDq6MStCyGIS5ATQSYJIVSeQEdRNeeyBKadzlv6UegIYKDIdduK9zCR8OC)IQ3W6jB8zHCws2yaRlGYJZ0lKn(hVeAKNNeCcSoibbwfKadzlv6UegIYKn(SqoljBmG1fq5Xz6LbbXG01GC9FVotwyHcEuSQPaw3x7GGdFqU(VxNjlSqbpkw1uaJMAQCwiDFTds3KDIdduKnxRvLvEu8LLq1By9KGal0jWq2wfYD(AdQ9iBpmt)e20kEBZKDIdduK9Z4bNcE0N)9t2sLUlHHOmjiWcniWq2sLUlHHOmzN4Wafz)mEqbpAOkuNQwi0W8KJSXNfYzjzJvTbP4GAKSX)4LqJ88KGtG1bjiW2eiWq2sLUlHHOmzN4Wafz7UsSEGFq1By9Kn(SqoljBmG1fq5Xz6Lbbh(GG2bf5sQORAbfdyDbDPs3LWq24F8sOrEEsWjW6GeeyBscmKDIdduKnxRvLvEu8LLq1By9KTuP7syiktcsq2ygkxoPS4NadbwheyiBPs3LWquMSbAjBUeKDIdduKDd5zP7si7gYLVq2yayXaCwDUCszXF)e20k(GuCqogeC4d6zEQb9e20k(GuCqFBMSBipALSczZLtkl(PU(hpibb2VeyiBPs3LWquMSXNfYzjzdTdQH8S0DjDvWIHQKVudco8b9mp1GEcBAfFqkoOVqNStCyGISTQbGEHQKVuKGaBJeyi7ehgOi7xUwsrbhJCKTuP7syiktccSkibgYoXHbkY2fucJppOUN4KSLkDxcdrzsqGf6eyi7ehgOiBNsQfuCk4rbhJCKTuP7syiktccSqdcmKTuP7syikt24Zc5SKSFMNAqpHnTIpiOgKJMe6dco8b1qEw6UKoxoPS4N66F8yqWHpON5Pg0tytR4dsXb1i0j7ehgOiBp)8ySSOGhn1u5aHkjiW2eiWq2sLUlHHOmzJplKZsYUH8S0DjDUCszXp11)4bzN4Wafz7eClMgeRONWbvwyHeeyBscmKTuP7syikt24Zc5SKSBiplDxsNlNuw8tD9pEq2jomqr2UlaGHcE0qvOsjS)KGaRcLadzlv6UegIYKn(SqoljBDnimaSyaoRoxoPS4VFcBAfFqWHpimaSyaoRoguyPIldHH(wjR0XQ55j8b1oOVds3dcIbbTdIbeDmOWsfxgcd9TswH66Fv)e20k(GGyq6AqyayXaCw9Z4w5r5(fvVH13pHnTIpiigegawmaNv)z8Gtbp6Z)(7NWMwXheC4d6zEQb9e20k(GuCqn5G0nzN4WafzJbfwQ4YqyOVvYkKGaRJMjWq2jomqr2HQq9lxGFXqFGdlKTuP7syiktccSoCqGHStCyGIS16F273kpQ7k5bzlv6UegIYKGaRJVeyiBPs3LWquMSXNfYzjzh55jrpmwHgaQwCq)28GGAqn28GGdFqrEEs0vLCfQDT4yqk2oOVnpi4WhuKNNe9WyfAaOmMmifh0xYoXHbkY(KuRvE03kzfojiW6OrcmKDIdduK9dG95cdn1u5SqOUsYs2sLUlHHOmjiW6qbjWq2sLUlHHOmzJplKZsYwk58(hKIdsbBMStCyGISzfwW9tbp6YhBmuMtswojiW6a6eyi7ehgOi7Z0QDjuROCTjwiBPs3LWquMeeyDaniWq2sLUlHHOmzJplKZsY(zEQb9e20k(GGAqo(c9bbh(GAiplDxsNlNuw8tD9pEq2jomqr2UlaGH(8VFsqG1rtGadzlv6UegIYKn(Sqolj7N5Pg0tytR4dcQb5OjH(GGdFqnKNLUlPZLtkl(PU(hpi7ehgOiBx54YP3kpsqG1rtsGHSLkDxcdrzYgFwiNLKnw16SPsdsZdcRAdcQ2b5GStCyGISZdNLqdWDsfKGaRdfkbgYoXHbkYEzEQbNQa(mESsfKTuP7syiktccSFBMadzlv6UegIYKn(Sqolj7N5Pg0tytR4dcQb54l0heC4dQH8S0DjDUCszXp11)4bzN4Wafz)StCxaadjiW(1bbgYwQ0DjmeLjB8zHCws2pZtnONWMwXheudYXxOpi4Whud5zP7s6C5KYIFQR)XdYoXHbkYolSWJlxuCUwKGa73VeyiBPs3LWquMSXNfYzjz3qEw6UKoxoPS4N66F8GStCyGISDtpk4rJZW65KGa73gjWq2sLUlHHOmzxjRq2jxTHSeo9snfCum4YfzN4WafzNC1gYs40l1uWrXGlxKGa7xfKadzlv6UegIYKn(Sqolj7ippj6QsUc1UwCmifBhKdOt2jomqr2bWhRsbpkJKHkjiW(f6eyiBRc5AixKTcTzYwloOQsUcvYU5o0j7ehgOi7a4JvPGhvFESjzlv6UegIYKGa7xObbgYwQ0DjmeLjB8zHCws2yayXaCw9Z4w5r5(fvVH13pHnTIpifh03bbh(GEMNAqpHnTIpifhKdOt2jomqr2C5KYIFsqG9BtGadzN4Wafz7MEuWJgNH1ZjBPs3LWquMeKGS5bbgcSoiWq2jomqr2ovTBzLhL5spqr16xyvYwQ0DjmeLjbb2VeyiBPs3LWquMSXNfYzjzJvToBQ0G08GWQ2GGQDqFheedsk58(7HXk0aqztLgeudQXbbh(GWQwNnvAqAEqyvBqq1oifCqqmiDniPKZ7VhgRqdaLnvAqqnOVdco8bbTds7jnq9WmDh9W8KJQnxSds3KDIdduKTuY5zAQvEuzzkzhjiW2ibgYwQ0DjmeLjB8zHCws2yaRlGYJZ0ldcIbPRb56)EDMSWcf8OyvtbSUV2bbh(GC9FVotwyHcEuSQPagn1u5Sq6(AhKUj7ehgOiBUwRkR8O4llHQ3W6jbbwfKadzN4Wafz)mEWPGh95F)KTuP7syiktccSqNadzlv6UegIYKDIdduK9zCR8OC)IQ3W6jB8zHCws2yayXaCwDUCszXF)e20k(GGAqogeC4dcAhuKlPIoxoPS4Vlv6UegYg)JxcnYZtcobwhKGal0Gadzlv6UegIYKn(SqoljBx)3RF(CvR8OkqYiuNwX0zaoRbbXGsCyniuPewt4dcQb5GStCyGISpFUQvEufizeQtRyibb2MabgYwQ0DjmeLjB8zHCws2yvRZMkninpiSQniOAhKJbPXGeoxkS0XG6TmCqZIHYJZEsNnvaWr2jomqr2IsALfvnpwsqGTjjWq2sLUlHHOmzN4Wafz)mEqbpAOkuNQwi0W8KJSXNfYzjzJvTbP4GAKSX)4LqJ88KGtG1bjiWQqjWq2sLUlHHOmzJplKZsYgRAD2uPbP5bHvTbbv7GCq2jomqr2yvJ66F8GeeyD0mbgYoXHbkYgRAuNzdczlv6UegIYKGaRdheyiBPs3LWquMStCyGISdZtoQ2CXs24Zc5SKSXawxaLhNPxgeedcRAD2uPbP5bHvTbbv7G(oiigKR)715b4yPsEHknlg6ZoPZaCwKn(hVeAKNNeCcSoibbwhFjWq2sLUlHHOmzJplKZsY21)96yvJkLCE)DEKy9dcQb1yZdsZdc6dQP(GsCyniuPewt4dcIbHbSUakpotVmiigKR)715b4yPsEHknlg6ZoPZaCwdcIbPRbHbGfdWz1pJBLhL7xu9gwF)e20k(GGAqFheedcdalgGZQ)mEWPGh95F)9tytR4dcQb9DqWHpimaSyaoR(zCR8OC)IQ3W67NWMwXhKIdQXbbXGWaWIb4S6pJhCk4rF(3F)e20k(GGAqnoiigew1geudQXbbh(GWaWIb4S6NXTYJY9lQEdRVFcBAfFqqnOgheedcdalgGZQ)mEWPGh95F)9tytR4dsXb14GGyqyvBqqnifCqWHpiSQ1ztLgKMhew1gKITdYXGGyqsjN3FpmwHgakBQ0GuCqFhKUheC4dY1)96yvJkLCE)DEKy9dcQb5O5bbXGEMNAqpHnTIpifhutGStCyGIS5ATQSYJIVSeQEdRNeeyD0ibgYwQ0DjmeLj7ehgOiB3vI1d8dQEdRNSXNfYzjzJbSUakpotVmiigKUguKlPIoxoPS4Vlv6UeMbbXGWaWIb4S6C5KYI)(jSPv8bP4GACqWHpimaSyaoR(zCR8OC)IQ3W67NWMwXheudYXGGyqyayXaCw9NXdof8Op)7VFcBAfFqqnihdco8bHbGfdWz1pJBLhL7xu9gwF)e20k(GuCqnoiigegawmaNv)z8Gtbp6Z)(7NWMwXheudQXbbXGWQ2GGAqFheC4dcdalgGZQFg3kpk3VO6nS((jSPv8bb1GACqqmimaSyaoR(Z4bNcE0N)93pHnTIpifhuJdcIbHvTbb1GACqWHpiSQniOge0heC4dY1)96Ua9uTha391oiDt24F8sOrEEsWjW6GeeyDOGeyiBPs3LWquMStCyGISdZtoQ2CXs24Zc5SKSXawxaLhNPxgeedcRAD2uPbP5bHvTbbv7G(s24F8sOrEEsWjW6GeeyDaDcmKTvHCNV2GSDq2jomqr2V1VvEuUCALkO6nSEYwQ0DjmeLjbbwhqdcmKTuP7syikt2jomqr2UReRh4hu9gwpzJplKZsYgdyDbuECMEzqqmimaSyaoR(Z4bNcE0N)93pHnTIpifhuJdcIbHvTb1oOVdcIbP9KgOEyMUJEyEYr1Ml2bbXGKsoV)EyScnauO38GuCqoiB8pEj0ippj4eyDqccSoAceyiBPs3LWquMStCyGISDxjwpWpO6nSEYgFwiNLKngW6cO84m9YGGyqsjN3FpmwHgakBQ0GuCqFheedsxdcRAD2uPbP5bHvTbPy7GCmi4WhK2tAG6Hz6o6H5jhvBUyhKUjB8pEj0ippj4eyDqcsq2aTsjhbgcSoiWq2sLUlHHOmzN4Wafz)mEqbpAOkuNQwi0W8KJSXNfYzjzJvToBQ0G08GWQ2GGQDqns24F8sOrENNeCY2bjiW(Ladzlv6UegIYKn(Sqolj7ixsfDSQrD9pE0LkDxcZGGyqyvRZMkninpiSQniOAhuJKDIdduKTOKwzrvZJLeeyBKadzlv6UegIYKDIdduKDyEYr1MlwYgFwiNLKngW6cO84m9YGGyqyvRZMkninpiSQniOAh0xYg)JxcnYZtcobwhKGaRcsGHStCyGISfL0klQAESKTuP7syiktccSqNadzlv6UegIYKDIdduKDyEYr1MlwYgFwiNLKnw16SPsdsZdcRAdcQ2b9LSX)4LqJ88KGtG1bjibji7gKJBGIa73M)2SJM)cniBN5vw5XjBn5SAbximdQjhuIddudAz8G3NpKD6hQGJS3gRMGS1EGNTeYwHhutPvmoZLE5gKMmqPF(OWdcAgoaUYnOVkuih03M)288z(OWdstsjb7hcZGCLh4KbHbSUzmixXZkEFqkeySOn4dQaLMvZJ95VguIddu8bbQ1FF(K4WafVR9emG1ndnA15TeUk(YxmFsCyGI31EcgW6MHgT60qEw6UeiRKvAvYxkkOO(CHgNv6LasG2wUeq2qU8L2MNpjomqX7ApbdyDZqJwDWQg11)4bK2RfAJCjv05YjLf)DPs3LWaho0g5sQO)mEqbpAOkuNQwi0W8KRlv6UeM5tIddu8U2tWaw3m0OvhSQrDMniqAVwOnYLurxk58mn1kpQSmLKRlv6UeM5Z8rHhKMKsc2peMbjni3)GcJvguOkdkXb4gKXhu2qAR0Dj95tIddu8wUwjpQAwmuECMEz(OWdcA(8S0DjdkuZyqoT1AqHSwd6h4pi7nOFG)GCAR1GkryguagKZ0IbfGbHtEmiyakK6WagubIb5mRyqbyq4KhdYIbLXGY1Aqz9Zcoz(K4WafxJwDAiplDxcKvYkTQGfdvjFPGeOTLlbKnKlFPfdalgGZQBvda9cvjFPOHQqDQAHqdZtU(jSPvCOEMNAqpHnTIdh(Z8ud6jSPvCfD8TziEMNAqpHnTIdfgawmaNvNlNuw83pHnTIdbgawmaNvNlNuw83pHnTIdLJMNpk8GAICzqAbHbQbzVbTLtkl(hKXhKVwihe4gKliuh0wtQPhuwmdcgGc5GYtgKVwihe4guOkdkYZtIb50wRbXyYGCAHQvdcA08G4cgum85tIdduCnA1rlimqbP9A1LR)715YjLf)DFTWH76)EDEaowQKxOsZIH(St6(A1neALORKVu0qvOovTqOH5jxpXH1Gah(Z8ud6jSPvCfBHgnpFu4bPjY1AqHQmOTCszX)GsCyGAqlJhdYEdAlNuw8piJpiS)DsfR)b5RD(K4WafxJwDW5ArtCyGIUmEazLSslxoPS4hs7166)EDUCszXF3x78rHh0GAICzqnniAkHzq2Bqd6h4pO8KbXACUvEdkJbTKKhdQXbHvnihKcrXmOFG)GeluLBq5jdkDb(XGcWGWP2bjLCE)qoiWniUCszX)Gm(GsxGFmOamimGvgKVwihe4gutdA6bz8bHbSw5niFTdklMb9d8hKtBTgeo1oiPKZ7FqCaOMpjomqX1OvhCUw0ehgOOlJhqwjR0c0kLCqAV2WyffHoeyvtrOdb0QvIUs(srdvH6u1cHgMNC9ehwdY8jXHbkUgT68mEqbpAOkuNQwi0W8Kds8pEj0ippj4ToG0ETyvRZMkPzSQbvBJqOlPKZ7VhgRqdaLnvsrhWHlLCE)9WyfAaOSPskQGqGbGfdWz1Fgp4uWJ(8V)(jSPvCfD0HUUNpjomqX1OvhrjTYIQMhlK2RfRAD2ujnJvnOADOHW5sHLoguVLHdAwmuEC2t6SPcaoi0LuY593dJvObGYMkPOd4WXaWIb4S6C5KYI)(jSPvCf)chUuY593dJvObGYMkPOccbgawmaNv)z8Gtbp6Z)(7NWMwXv0rh66E(K4WafxJwDcZtoQ2CXcj(hVeAKNNe8whqAVwmG1fq5Xz6fiWQwNnvsZyvdQ2VqOlPKZ7VhgRqdaLnvsrhWHJbGfdWz15YjLf)9tytR4k(foCPKZ7VhgRqdaLnvsrfecmaSyaoR(Z4bNcE0N)93pHnTIROJo0198jXHbkUgT6GZ1IM4WafDz8aYkzLwmdLlpiTxl0g5sQOZLtkl(7sLUlHz(K4WafxJwDW5ArtCyGIUmEazLSslMHYLtkl(H0ETrUKk6C5KYI)UuP7syMpk8G0e5AnOqvg0gMbL4Wa1GwgpgK9guOkNmO8Kb9DqGBqlHZhKucRj85tIdduCnA1bNRfnXHbk6Y4bKvYkT8as71M4WAqOsjSMWvSX5JcpinrUwdkuLbPqa0KguIddudAz8yq2BqHQCYGYtguJdcCdIfCYGKsynHpFsCyGIRrRo4CTOjomqrxgpGSswPnbcK2RnXH1GqLsynHdvBJZN5JcpifcCyGI3viaAsdY4dYQqkgHzqpWniFUmiNwOoiO5eCyyQcbddvtSKSbzqzXmiS)DsfR)bvIWWhuagKRmiG2WynnvyMpjomqX7jqADQA3YkpkZLEGIQ1VWQZNehgO49eiA0QJuY5zAQvEuzzkzhK2RfRAD2ujnJvnOA)cHuY593dJvObGYMkbvJWHJvToBQKMXQguTkie6sk58(7HXk0aqztLG6lC4qR2tAG6Hz6o6H5jhvBUy198jXHbkEpbIgT6W1AvzLhfFzju9gwpK2RfdyDbuECMEbcD56)EDMSWcf8OyvtbSUVw4WD9FVotwyHcEuSQPagn1u5Sq6(A198jXHbkEpbIgT68mEWPGh95F)qAVwPKZ7VhgRqdaLnvckrjb7hcnmwrZoGd31)968aCSujVqLMfd9zN0pHnTIpFsCyGI3tGOrRoNXTYJY9lQEdRhs8pEj0ippj4ToG0ET6kYLur3PQDlR8Omx6bkQw)cR2LkDxcdeyayXaCw9Z4w5r5(fvVH13z8VmmqbfgawmaNv3PQDlR8Omx6bkQw)cR2pHnTIRrJ6gcDHbGfdWz1Fgp4uWJ(8V)(jSPvCOAeoCSQbvl0198jXHbkEpbIgT6C(CvR8OkqYiuNwXaP9AD9FV(5ZvTYJQajJqDAftNb4SMpjomqX7jq0OvhUwRkR8O4llHQ3W6H0ETyaRlGYJZ0lqOlDHvnOAeoCmaSyaoR(Z4bNcE0N)93pHnTIdf0q3qOlSQbvl0HdhdalgGZQ)mEWPGh95F)9tytR4q9v3WHlLCE)9WyfAaOSPsk22OUNpjomqX7jq0OvhrjTYIQMhlK2RfRAD2ujnJvnOADOHW5sHLoguVLHdAwmuEC2t6SPcaU5tIddu8EcenA1bRAux)JhqAVwSQ1ztL0mw1GQ1rIddu8EcenA15z8GcE0qvOovTqOH5jhK4F8sOrEEsWBDaP9AXQwNnvsZyvdQ2gNpjomqX7jq0OvNW8KJQnxSqI)XlHg55jbV1bK2RfRAD2ujnJvnOA)cHUG2ixsfDvlOyaRlOlv6Ueg4WXawxaLhNPx098jXHbkEpbIgT6GvnQZSbbs71IbSUakpotVmFsCyGI3tGOrRoV1VvEuUCALkO6nSEiTxRR)71Db6PApaUZaCwqAvi35RnADmFsCyGI3tGOrRoUReRh4hu9gwpK4F8sOrEEsWBDaP9AXawxaLhNPxGqxU(Vx3fONQ9a4UVw4WJCjv0vTGIbSUGUuP7syGq7jnq9WmDh9W8KJQnxSqGvT2VqGbGfdWz1Fgp4uWJ(8V)(jSPvCfBeoCSQ1ztL0mw1uS1beApPbQhMP7OZ1AvzLhfFzju9gwVUNpZhfEq7aCSqoinP8cvihuwmdQPTtgKMaawmaNfF(K4WafVJzOC51Avda9cvjFPOHQqDQAHqdZtoiTxl02qEw6UKUkyXqvYxk4WFMNAqpHnTIR4xOpFsCyGI3XmuU80OvNxUwsrbhJCZNehgO4DmdLlpnA1XfucJppOUN4C(K4WafVJzOC5PrRooLulO4uWJcog5Mpk8GAICzqkeholzqWaUtQyq2Bq)a)bLNmiwJZTYBqzmOLK8yqogKMq1MpjomqX7ygkxEA0QtE4SeAaUtQas71IvToBQKMXQguToMpjomqX7ygkxEA0Qta8XQuWJYizOcP9AJ88KORk5ku7AXHIToGoeU(VxNhGJLk5fQ0SyOp7KodWznFsCyGI3XmuU80Ovh3faWqbpAOkuPe2FiTxlgawmaNv)z8Gtbp6Z)(7NWMwXv8lC4pZtnONWMwXv0X35tIddu8oMHYLNgT645NhJLff8OPMkhiuNpjomqX7ygkxEA0QJtWTyAqSIEchuzHL5tIddu8oMHYLNgT6GbfwQ4YqyOVvYkqAVwOLbeDmOWsfxgcd9TswH66Fv)e20koe6sxqBKlPIUtv7ww5rzU0duuT(fwTlv6Ueg4WXaWIb4S6ovTBzLhL5spqr16xy1(jSPvCDdbgawmaNv)mUvEuUFr1By99tytR4qGbGfdWz1Fgp4uWJ(8V)(jSPvCiC9FVopahlvYluPzXqF2jDgGZs3WH)mp1GEcBAfxXMC(K4WafVJzOC5PrRoHQq9lxGFXqFGdlZNehgO4DmdLlpnA1rR)zVFR8OURKhZNehgO4DmdLlpnA15KuRvE03kzfoK2RnYZtIEyScnauT4G(TzOASz4WJ88KORk5ku7AXHITFBE(K4WafVJzOC5PrRopa2Nlm0utLZcH6kj78jXHbkEhZq5YtJwDyfwW9tbp6YhBmuMtswoK2Rvk58(vubBE(K4WafVJzOC5PrRoNPv7sOwr5AtSmFsCyGI3XmuU80OvhEaowQKxOsZIH(StG0ETyayXaCwDEaowQKxOsZIH(St6y188eE7x4WFMNAqpHnTIR43MHd31)96CrcvR8Ox6jDFTWHRlmaSyaoRU7cayOGhnufQuc7F)e20kUgoGcdalgGZQZdWXsL8cvAwm0NDs)5Vw0tWQ55j0Wyf4WHwHZLclD3faWqbpAOkuPe2)oBQaGt3qGbGfdWz1Fgp4uWJ(8V)(jSPvCfD0meyvdQ2VqGbGfdWz1DQA3YkpkZLEGIQ1VWQ9tytR4k6478jXHbkEhZq5YtJwD85c1cHfYkzL2KR2qwcNEPMcokgC5A(K4WafVJzOC5PrRobWhRsbpQ(8ytiTkKRHC1QqBgsT4GQk5kuBBUd95JcpOMixgKYlaGzqnT)9pi7niya(y1bbEdsHuYqTPw(GWaWIb4SgKXhK3jzi3Gc1SguJnpiDfQgFqwHx(mcFqovTLmiyakKdY4dc7FNuX6FqjoSgeDd5Ga3GaV3GWaWIb4SgKtvPg0pWFq5jdsfSySYBqGkadcgGcjKdcCdYPQudkuLbf55jXGm(GsxGFmOamigtMpjomqX7ygkxEA0QJ7cayOp)7hs71(mp1GEcBAfhkhFHoC4U(VxNhGJLk5fQ0SyOp7KUVw4WFMNAqpHnTIR43MNpjomqX7ygkxEA0QJRCC50BLhK2R9zEQb9e20kouoAsOdhUR)715b4yPsEHknlg6ZoP7Rfo8N5Pg0tytR4k(T55tIddu8oMHYLNgT6Smp1GtvaFgpwPI5tIddu8oMHYLNgT68StCxaadK2R9zEQb9e20kouo(cD4WD9FVopahlvYluPzXqF2jDFTWH)mp1GEcBAfxXVnpFsCyGI3XmuU80OvNSWcpUCrX5AbP9AFMNAqpHnTIdLJMe6WH76)EDEaowQKxOsZIH(St6(AHd)zEQb9e20kUIFBoXHbkEhZq5YtJwDCtpk4rJZW65qAVwx)3RZdWXsL8cvAwm0NDsNb4SMpZhfEqB5KYI)bPjaGfdWzXNpjomqX7ygkxoPS4VTH8S0DjqwjR0YLtkl(PU(hpGeOTLlbKnKlFPfdalgGZQZLtkl(7NWMwXv0bC4pZtnONWMwXv8BZZNehgO4DmdLlNuw8RrRow1aqVqvYxkAOkuNQwi0W8Kds71cTnKNLUlPRcwmuL8Lco8N5Pg0tytR4k(f6ZNehgO4DmdLlNuw8RrRoVCTKIcog5MpjomqX7ygkxoPS4xJwDCbLW4ZdQ7joNpjomqX7ygkxoPS4xJwDCkPwqXPGhfCmYnFsCyGI3XmuUCszXVgT645NhJLff8OPMkhiuH0ETpZtnONWMwXHYrtcD4WBiplDxsNlNuw8tD9pEah(Z8ud6jSPvCfBe6ZNehgO4DmdLlNuw8RrRoob3IPbXk6jCqLfwG0ETnKNLUlPZLtkl(PU(hpMpjomqX7ygkxoPS4xJwDCxaadf8OHQqLsy)H0ETnKNLUlPZLtkl(PU(hpMpjomqX7ygkxoPS4xJwDWGclvCzim03kzfiTxRUWaWIb4S6C5KYI)(jSPvC4WXaWIb4S6yqHLkUmeg6BLSshRMNNWB)QBiGwgq0XGclvCzim03kzfQR)v9tytR4qOlmaSyaoR(zCR8OC)IQ3W67NWMwXHadalgGZQ)mEWPGh95F)9tytR4WH)mp1GEcBAfxXMu3ZNehgO4DmdLlNuw8RrRoHQq9lxGFXqFGdlZNehgO4DmdLlNuw8RrRoA9p79BLh1DL8y(K4WafVJzOC5KYIFnA15KuRvE03kzfoK2RnYZtIEyScnauT4G(TzOASz4WJ88KORk5ku7AXHITFBgo8ippj6HXk0aqzmrXVZNehgO4DmdLlNuw8RrRopa2Nlm0utLZcH6kj78jXHbkEhZq5YjLf)A0QdRWcUFk4rx(yJHYCsYYH0ETsjN3VIkyZZNehgO4DmdLlNuw8RrRoNPv7sOwr5AtSmFsCyGI3XmuUCszXVgT64Uaag6Z)(H0ETpZtnONWMwXHYXxOdhEd5zP7s6C5KYIFQR)XJ5tIddu8oMHYLtkl(1Ovhx54YP3kpiTx7Z8ud6jSPvCOC0Kqho8gYZs3L05YjLf)ux)JhZNehgO4DmdLlNuw8RrRo5HZsOb4oPciTxlw16SPsAgRAq16y(K4WafVJzOC5KYIFnA1zzEQbNQa(mESsfZNehgO4DmdLlNuw8RrRop7e3faWaP9AFMNAqpHnTIdLJVqho8gYZs3L05YjLf)ux)JhZNehgO4DmdLlNuw8RrRozHfEC5IIZ1cs71(mp1GEcBAfhkhFHoC4nKNLUlPZLtkl(PU(hpMpjomqX7ygkxoPS4xJwDCtpk4rJZW65qAV2gYZs3L05YjLf)ux)JhZNehgO4DmdLlNuw8RrRo(CHAHWczLSsBYvBilHtVutbhfdUCnFsCyGI3XmuUCszXVgT6eaFSkf8OmsgQqAV2ippj6QsUc1UwCOyRdOpFsCyGI3XmuUCszXVgT6eaFSkf8O6ZJnH0QqUgYvRcTzi1IdQQKRqTT5o0NpjomqX7ygkxoPS4xJwD4YjLf)qAVwmaSyaoR(zCR8OC)IQ3W67NWMwXv8lC4pZtnONWMwXv0b0NpjomqX7ygkxoPS4xJwDCtpk4rJZW65ZN5JcpiOzALsU5tIddu8oqRuY1(mEqbpAOkuNQwi0W8Kds8pEj0iVZtcERdiTxlw16SPsAgRAq1248jXHbkEhOvk50OvhrjTYIQMhlK2RnYLurhRAux)JhDPs3LWabw16SPsAgRAq1248jXHbkEhOvk50OvNW8KJQnxSqI)XlHg55jbV1bK2RfdyDbuECMEbcSQ1ztL0mw1GQ978jXHbkEhOvk50OvhrjTYIQMh78jXHbkEhOvk50OvNW8KJQnxSqI)XlHg55jbV1bK2RfRAD2ujnJvnOA)oFMpk8GAkodCw8pOMsvBjdAlNuw8pin58b1e1oFsCyGI35YjLf)TpJhCk4rF(3pK2R11)96C5KYI)(jSPvCfDahEIdRbHkLWAchkhZNehgO4DUCszXVgT6W1AvzLhfFzju9gwpK2RfdyDbuECMEbcDL4WAqOsjSMWH6lC4joSgeQucRjCOCab0IbGfdWz1pJBLhL7xu9gwF3xRUNpjomqX7C5KYIFnA15mUvEuUFr1By9qI)XlHg55jbV1bK2RfdyDbuECMEz(K4WafVZLtkl(1OvhUwRkR8O4llHQ3W6H0ETyaRlGYJZ0lqOlx)3RZKfwOGhfRAkG191chUR)71zYcluWJIvnfWOPMkNfs3xRUNpk8GGr14dYPTwdcN8yqnnOPhuwmdYQqUZxBmOqvgewnRswdYEdkuLb1uJMqHCqgFqNKm)dklMbXbSsOAL3Gunpv5geOguOkds7zGZI)bTmEmiD1uTHM09Gm(GYgsZDjZNehgO4DUCszXVgT68mEWPGh95F)qAvi35RnO2R1dZ0pHnTI3288jXHbkENlNuw8RrRopJhuWJgQc1PQfcnmp5Ge)JxcnYZtcERdiTxlw1uSX5JcpOMixgKYaOjihKfdYPTwdcuR)b5EsQFqSjpK7Fq2BqqZzXG0eawxWGm(GGfAgmdkYLuHWmFsCyGI35YjLf)A0QJ7kX6b(bvVH1dj(hVeAKNNe8whqAVwmG1fq5Xz6f4WH2ixsfDvlOyaRlOlv6UeM5tIddu8oxoPS4xJwD4ATQSYJIVSeQEdRF(mFu4bTTYBjdkYZtIb1uCg4S4F(K4WafVZJwNQ2TSYJYCPhOOA9lS68jXHbkENhA0QJuY5zAQvEuzzkzhK2RfRAD2ujnJvnOA)cHuY593dJvObGYMkbvJWHJvToBQKMXQguTkie6sk58(7HXk0aqztLG6lC4qR2tAG6Hz6o6H5jhvBUy198jXHbkENhA0QdxRvLvEu8LLq1By9qAVwmG1fq5Xz6fi0LR)71zYcluWJIvnfW6(AHd31)96mzHfk4rXQMcy0utLZcP7Rv3ZNehgO4DEOrRopJhCk4rF(3)8rHhutKldQPAdnniqnOippj4dYPfQa)yqAYYt)GaVbfQYG0exwYGyex)3dYbzVbPfW5M7sGCqzXmi7nOTCszX)Gm(GYyqlj5XG(oiUGbfdFqPZ8F(K4WafVZdnA15mUvEuUFr1By9qI)XlHg55jbV1bK2RfdalgGZQZLtkl(7NWMwXHYbC4qBKlPIoxoPS4Vlv6UeM5tIddu8op0OvNZNRALhvbsgH60kgiTxRR)71pFUQvEufizeQtRy6maNfejoSgeQucRjCOCmFsCyGI35HgT6ikPvwu18yH0ETyvRZMkPzSQbvRdneoxkS0XG6TmCqZIHYJZEsNnvaWnFsCyGI35HgT68mEqbpAOkuNQwi0W8Kds8pEj0ippj4ToG0ETyvtXgNpk8GAICzqAcLhK9g0pWFq5jdIfCYGc1SguZdstOAdkDM)d6Da2bXMknOSygKA2GmihdskH9hYbbUbLNmiwWjdkuZAqogKMq1gu6m)h07aSdInvA(K4WafVZdnA1bRAux)JhqAVwSQ1ztL0mw1GQ1X8jXHbkENhA0Qdw1OoZgK5JcpOMixgemnfdYEd6h4pO8KbPGdcCdIfCYGWQ2GsN5)GEhGDqSPsdklMbbdqHCqzXmOTMutpO8Kb5cc1bvGyq(ANpjomqX78qJwDcZtoQ2CXcj(hVeAKNNe8whqAVwmG1fq5Xz6fiWQwNnvsZyvdQ2Vq46)EDEaowQKxOsZIH(St6maN18jXHbkENhA0QdxRvLvEu8LLq1By9qAVwx)3RJvnQuY5935rI1dvJnRzO3upXH1GqLsynHdbgW6cO84m9ceU(VxNhGJLk5fQ0SyOp7KodWzbHUWaWIb4S6NXTYJY9lQEdRVFcBAfhQVqGbGfdWz1Fgp4uWJ(8V)(jSPvCO(chogawmaNv)mUvEuUFr1By99tytR4k2ieyayXaCw9NXdof8Op)7VFcBAfhQgHaRAq1iC4yayXaCw9Z4w5r5(fvVH13pHnTIdvJqGbGfdWz1Fgp4uWJ(8V)(jSPvCfBecSQbLcchow16SPsAgRAk26acPKZ7VhgRqdaLnvsXV6goCx)3RJvnQuY5935rI1dLJMH4zEQb9e20kUInH5JcpOMixgKYaOPbzVb5cc1b10GMEqzXmOMQn00GYtgubIbHxaUa5Ga3GAQ2qtdY4dcVaCzqzXmOMg00dY4dQaXGWlaxguwmd6h4pi1SbzqSGtguOM1G(oiSQb5Ga3GAAqtpiJpi8cWLb1uTHMgKXhubIbHxaUmOSyg0pWFqQzdYGybNmOqnRb14GWQgKdcCd6h4pi1SbzqSGtguOM1GG(GWQgKdcCdYEd6h4pipjguoiThapFsCyGI35HgT64UsSEGFq1By9qI)XlHg55jbV1bK2RfdyDbuECMEbcDf5sQOZLtkl(7sLUlHbcmaSyaoRoxoPS4VFcBAfxXgHdhdalgGZQFg3kpk3VO6nS((jSPvCOCabgawmaNv)z8Gtbp6Z)(7NWMwXHYbC4yayXaCw9Z4w5r5(fvVH13pHnTIRyJqGbGfdWz1Fgp4uWJ(8V)(jSPvCOAecSQb1x4WXaWIb4S6NXTYJY9lQEdRVFcBAfhQgHadalgGZQ)mEWPGh95F)9tytR4k2ieyvdQgHdhRAqbD4WD9FVUlqpv7bWDFT6E(K4WafVZdnA1jmp5OAZflK4F8sOrEEsWBDaP9AXawxaLhNPxGaRAD2ujnJvnOA)oFu4b1e5YGA6n00GYIzqwfYD(AJbzXG4XLMNAmO0z(pFsCyGI35HgT68w)w5r5YPvQGQ3W6H0QqUZxB06y(OWdQjYLbPmaAAq2BqnnOPhKXheEb4YGYIzq)a)bPMnid67GWQ2GYIzq)a)BqRKhdYBbCZ1GCM8bbttbKdcCdYEd6h4pO8KbLUa)yqbyq4u7GKsoV)bLfZGeluLBq)a)BqRKhdYdZmiNjFqW0umiWni7nOFG)GYtg0s48bfQznOVdcRAdkDM)d6Da2bHtTATYB(K4WafVZdnA1XDLy9a)GQ3W6He)JxcnYZtcERdiTxlgW6cO84m9ceyayXaCw9NXdof8Op)7VFcBAfxXgHaRATFHq7jnq9WmDh9W8KJQnxSqiLCE)9WyfAaOqVzfDmFsCyGI35HgT64UsSEGFq1By9qI)XlHg55jbV1bK2RfdyDbuECMEbcPKZ7VhgRqdaLnvsXVqOlSQ1ztL0mw1uS1bC4ApPbQhMP7OhMNCuT5Iv3KGeeca]] )

end