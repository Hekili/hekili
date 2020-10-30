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
    
    spec:RegisterPack( "Windwalker", 20201030.2, [[dS0tKbqisGEejO2ei6tGsQQrrQuNIujRcusvEfPWSaHBrkYUKQFrQyysrDmQWYuv6zsHMgOexduQTbkjFJeKgNueDoPiyEKq3tkTpqQdskkzHKipKuumrsq0fjbHnkfP(OuKuAKsrs1jjfLYkvv8sqjLBskkv7eu8tqjvgQuKKLkfj8uLAQGKRkfH2QuKu8vPir7fYFrAWqDyrlMk9yetgfxMyZQYNPQgnjDAkRMeWRjvnBLCBuA3s(nWWjLwUkphvtx46uLTlf8DQOXtI68QQwpPOA(GQ9RyKdeuOntgccMVn)Tzhn3yZDhWYxfAJWk0o(1kOT2KOp9f0UswbTBkTIXzU0lhARn)xGKbbfAZbEhrqB021ZwHMTc5I2mziiy(283MD0CJn3DalFvOncB0MRviiy(cRAcOTQXWifYfTzeobTv4b3uAfJZCPxUbRzhu6Npk8GH1rcGRCdUXMHyWFB(BZO9Y4bhbfAtyOC5HGcbJdeuOTuP7syqkH2KZc5SeTvWb3qEw6UKUkyXqv2tQbdh(GFMVAqpHnTIpyfh8xyJ2jjmqH2w1aqVqv2tkuGG5lck0ojHbk0(LRLuuWXihAlv6UegKsOabtJiOq7KegOqBxqjmE8G6EIt0wQ0DjmiLqbcgybbfANKWafA7usTGItbpk4yKdTLkDxcdsjuGGb2iOqBPs3LWGucTjNfYzjAtuToBQ8G10GjQ2GHUDWoq7KegOq78izj0aCNubkqWaRqqH2sLUlHbPeAtolKZs0oYZxIUQKRqTRLedwX2b7a2dgYb769EDEaowQKxOsZIH(St6maNfANKWafAhapIkf8OmsgQOabJcfbfAlv6UegKsOn5SqolrBcaSyaoR(Z4bNcE0N393pHnTIpyfh83bdh(GFMVAqpHnTIpyfhSJVODscduOT7cayOGhnufQuc7pkqW0KiOq7KegOqBFV8ySSOGhn1C5aHkAlv6UegKsOabttabfANKWafA7eClMgeRONWbvwebTLkDxcdsjuGGXrZiOqBPs3LWGucTjNfYzjARGdMbeDcOisfxgcd9TswH66Dv)e20k(GHCW6EW6EWk4GJCjv0DQA3YkFkZL(GIQ1RiQDPs3LWmy4WhmbawmaNv3PQDlR8Pmx6dkQwVIO2pHnTIpyDnyihmbawmaNv)mUv(uUxr1Be99tytR4dgYbtaGfdWz1Fgp4uWJ(8U)(jSPv8bd5GD9EVopahlvYluPzXqF2jDgGZAW6AWWHp4N5Rg0tytR4dwXb3KODscduOnbuePIldHH(wjRGcemoCGGcTtsyGcTdvH6vUaVIH(ahrqBPs3LWGucfiyC8fbfANKWafAR17S3Vv(u3vYd0wQ0DjmiLqbcghnIGcTLkDxcdsj0MCwiNLODKNVe9WyfAaOAjb9BZdg6b3yZdgo8bh55lrxvYvO21sIbRy7G)2mANKWafAFsQ1kF6BLSchfiyCaliOq7KegOq7hG4XfgAQ5YzHqDLKfTLkDxcdsjuGGXbSrqH2sLUlHbPeAtolKZs0wk58)hSIdgwAgTtsyGcTzfwW9tbp6YJymuMtswokqW4awHGcTtsyGcTptR2LqTIY1MebTLkDxcdsjuGGXHcfbfAlv6UegKsOn5SqolrBcaSyaoRopahlvYluPzXqF2jDIAE(cFWTd(7GHdFWpZxnONWMwXhSId(BZdgo8b769EDUiHQv(0l9LUN2bdh(G19GjaWIb4S6UlaGHcE0qvOsjS)9tytR4dwJb7yWqpycaSyaoRopahlvYluPzXqF2j9N3ArpHOMNVqdJvgmC4dwbhSW5srKU7cayOGhnufQuc7FNnvaWnyDnyihmbawmaNv)z8Gtbp6Z7(7NWMwXhSId2rZdgYbtuTbdD7G)oyihmbawmaNv3PQDlR8Pmx6dkQwVIO2pHnTIpyfhSJVODscduOnpahlvYluPzXqF2jOabJJMebfAlv6UegKsODLScANC1gYs40l1CWrjGlxODscduODYvBilHtVuZbhLaUCHcemoAciOq7KegOqBpUqTqy5OTuP7syqkHcemFBgbfABvixd5cTBcnJ2AjbvvYvOI2n3HnANKWafAhapIkf8O6ZJnrBPs3LWGucfiy(6abfAlv6UegKsOn5Sqolr7N5Rg0tytR4dg6b74lShmC4d217968aCSujVqLMfd9zN090oy4Wh8Z8vd6jSPv8bR4G)2mANKWafA7Uaag6Z7(rbcMVFrqH2sLUlHbPeAtolKZs0(z(Qb9e20k(GHEWoAsypy4WhSR3715b4yPsEHknlg6ZoP7PDWWHp4N5Rg0tytR4dwXb)Tz0ojHbk02voUC6TYhfiy(2ick0ojHbk0Ez(QbNQaEm(SsfOTuP7syqkHcemFHfeuOTuP7syqkH2KZc5SeTFMVAqpHnTIpyOhSJVWEWWHpyxV3RZdWXsL8cvAwm0NDs3t7GHdFWpZxnONWMwXhSId(BZODscduO9ZoXDbamOabZxyJGcTLkDxcdsj0MCwiNLOTR3715b4yPsEHknlg6ZoPZaCwODscduODweHhxUOKCTqbkqBGwPKdbfcghiOqBPs3LWGucTtsyGcTFgpOGhnufQtvleAy(YH2KZc5SeTjQwNnvEWAAWevBWq3o4grBYpzj0iVZxcoA7afiy(IGcTLkDxcdsj0MCwiNLODKlPIor1OUEhp6sLUlHzWqoyIQ1ztLhSMgmr1gm0TdUr0ojHbk0wuwRSOQ5XIcemnIGcTLkDxcdsj0ojHbk0omF5OAZflAtolKZs0MayDbuECMEzWqoyIQ1ztLhSMgmr1gm0Td(lAt(jlHg55lbhbJduGGbwqqH2jjmqH2IYALfvnpw0wQ0DjmiLqbcgyJGcTLkDxcdsj0ojHbk0omF5OAZflAtolKZs0MOAD2u5bRPbtuTbdD7G)I2KFYsOrE(sWrW4afOaTzKx6TceuiyCGGcTtsyGcT5AL8OQzXq5Xz6f0wQ0DjmiLqbcMViOqBPs3LWGucTbArBUeODscduODd5zP7sq7gYLNG2eayXaCwDRAaOxOk7jfnufQtvleAy(Y1pHnTIpyOh8Z8vd6jSPv8bdh(GFMVAqpHnTIpyfhSJVnpyih8Z8vd6jSPv8bd9GjaWIb4S6C5KYI)(jSPv8bd5GjaWIb4S6C5KYI)(jSPv8bd9GD0mA3qE0kzf0wfSyOk7jfkqW0ick0wQ0DjmiLqBYzHCwI26EWUEVxNlNuw8390oy4WhSR3715b4yPsEHknlg6ZoP7PDW6AWqoyTs0v2tkAOkuNQwi0W8LRNKWAqgmC4d(z(Qb9e20k(GvSDWWQMr7KegOqBTGWafkqWaliOqBPs3LWGucTjNfYzjA769EDUCszXF3tlANKWafAtY1IMKWafDz8aTxgpOvYkOnxoPS4hfiyGnck0wQ0DjmiLqBYzHCwI2HXkdwXbd7bd5GjQ2GvCWWEWqoyfCWALORSNu0qvOovTqOH5lxpjH1GG2jjmqH2KCTOjjmqrxgpq7LXdALScAd0kLCOabdScbfAlv6UegKsODscduO9Z4bf8OHQqDQAHqdZxo0MCwiNLOnr16SPYdwtdMOAdg62b34GHCW6EWsjN)FpmwHgakBQ8GvCWogmC4dwk58)7HXk0aqztLhSIdgwgmKdMaalgGZQ)mEWPGh95D)9tytR4dwXb7Od7bRl0M8twcnYZxcocghOabJcfbfAlv6UegKsOn5SqolrBIQ1ztLhSMgmr1gm0Td2XG1yWcNlfr6eq9wgjOzXq5XzpPZMka4gmKdw3dwk58)7HXk0aqztLhSId2XGHdFWeayXaCwDUCszXF)e20k(GvCWFhmC4dwk58)7HXk0aqztLhSIdgwgmKdMaalgGZQ)mEWPGh95D)9tytR4dwXb7Od7bRl0ojHbk0wuwRSOQ5XIcemnjck0wQ0DjmiLq7KegOq7W8LJQnxSOn5SqolrBcG1fq5Xz6Lbd5GjQwNnvEWAAWevBWq3o4VdgYbR7blLC()9WyfAaOSPYdwXb7yWWHpycaSyaoRoxoPS4VFcBAfFWko4Vdgo8blLC()9WyfAaOSPYdwXbdldgYbtaGfdWz1Fgp4uWJ(8U)(jSPv8bR4GD0H9G1fAt(jlHg55lbhbJduGGPjGGcTLkDxcdsj0MCwiNLOTco4ixsfDUCszXFxQ0DjmODscduOnjxlAscdu0LXd0Ez8GwjRG2egkxEOabJJMrqH2sLUlHbPeAtolKZs0oYLurNlNuw83LkDxcdANKWafAtY1IMKWafDz8aTxgpOvYkOnHHYLtkl(rbcghoqqH2sLUlHbPeAtolKZs0ojH1GqLsynHpyfhCJODscduOnjxlAscdu0LXd0Ez8GwjRG28afiyC8fbfAlv6UegKsOn5Sqolr7KewdcvkH1e(GHUDWnI2jjmqH2KCTOjjmqrxgpq7LXdALScANabfOaT1EcbW6MbckemoqqH2jjmqH2VLWvjx(c0wQ0DjmiLqbcMViOqBPs3LWGucTbArBUeODscduODd5zP7sq7gYLNG2nJ2nKhTswbTv2tkkOOECHgNv6LafiyAebfAlv6UegKsOn5SqolrBfCWrUKk6C5KYI)UuP7sygmC4dwbhCKlPI(Z4bf8OHQqDQAHqdZxUUuP7syq7KegOqBIQrD9oEGcemWcck0wQ0DjmiLqBYzHCwI2k4GJCjv0LsoFtZTYNkltz56sLUlHbTtsyGcTjQg1z2GGcuG2C5KYIFeuiyCGGcTLkDxcdsj0MCwiNLOTR3715YjLf)9tytR4dwXb7yWWHp4KewdcvkH1e(GHEWoq7KegOq7NXdof8OpV7hfiy(IGcTLkDxcdsj0MCwiNLOnbW6cO84m9YGHCW6EWjjSgeQucRj8bd9G)oy4WhCscRbHkLWAcFWqpyhdgYbRGdMaalgGZQFg3kFk3RO6nI(UN2bRl0ojHbk0MR1QYkFk5YsO6nIEuGGPreuOTuP7syqkH2jjmqH2NXTYNY9kQEJOhTjNfYzjAtaSUakpotVG2KFYsOrE(sWrW4afiyGfeuOTuP7syqkH2KZc5SeTjawxaLhNPxgmKdw3d21796mzrek4rjQMcyDpTdgo8b769EDMSicf8OevtbmAQ5YzH090oyDH2jjmqH2CTwvw5tjxwcvVr0JcemWgbfABvi35PnO2dT9jm9tytR4TnJ2jjmqH2pJhCk4rFE3pAlv6UegKsOabdScbfAlv6UegKsODscduO9Z4bf8OHQqDQAHqdZxo0MCwiNLOnr1gSIdUr0M8twcnYZxcocghOabJcfbfAlv6UegKsODscduOT7kj6bEbvVr0J2KZc5SeTjawxaLhNPxgmC4dwbhCKlPIUQfucG1f0LkDxcdAt(jlHg55lbhbJduGGPjrqH2jjmqH2CTwvw5tjxwcvVr0J2sLUlHbPekqbAtyOC5KYIFeuiyCGGcTLkDxcdsj0gOfT5sG2jjmqH2nKNLUlbTBixEcAtaGfdWz15YjLf)9tytR4dwXb7yWWHp4N5Rg0tytR4dwXb)Tz0UH8OvYkOnxoPS4N66D8afiy(IGcTLkDxcdsj0MCwiNLOTco4gYZs3L0vblgQYEsny4Wh8Z8vd6jSPv8bR4G)cB0ojHbk02Qga6fQYEsHcemnIGcTtsyGcTF5AjffCmYH2sLUlHbPekqWaliOq7KegOqBxqjmE8G6EIt0wQ0DjmiLqbcgyJGcTtsyGcTDkPwqXPGhfCmYH2sLUlHbPekqWaRqqH2sLUlHbPeAtolKZs0(z(Qb9e20k(GHEWoAsypy4WhCd5zP7s6C5KYIFQR3XJbdh(GFMVAqpHnTIpyfhCJWgTtsyGcT99YJXYIcE0uZLdeQOabJcfbfAlv6UegKsOn5Sqolr7gYZs3L05YjLf)uxVJhODscduOTtWTyAqSIEchuzreuGGPjrqH2sLUlHbPeAtolKZs0UH8S0DjDUCszXp1174bANKWafA7Uaagk4rdvHkLW(JcemnbeuOTuP7syqkH2KZc5SeT19GjaWIb4S6C5KYI)(jSPv8bdh(GjaWIb4S6eqrKkUmeg6BLSsNOMNVWhC7G)oyDnyihScoygq0jGIivCzim03kzfQR3v9tytR4dgYbR7btaGfdWz1pJBLpL7vu9grF)e20k(GHCWeayXaCw9NXdof8OpV7VFcBAfFWWHp4N5Rg0tytR4dwXb3KdwxODscduOnbuePIldHH(wjRGcemoAgbfANKWafAhQc1RCbEfd9boIG2sLUlHbPekqW4Wbck0ojHbk0wR3zVFR8PURKhOTuP7syqkHcemo(IGcTLkDxcdsj0MCwiNLODKNVe9WyfAaOAjb9BZdg6b3yZdgo8bh55lrxvYvO21sIbRy7G)28GHdFWrE(s0dJvObGYyYGvCWFr7KegOq7tsTw5tFRKv4OabJJgrqH2jjmqH2paXJlm0uZLZcH6kjlAlv6UegKsOabJdybbfAlv6UegKsOn5SqolrBPKZ)FWkoyyPz0ojHbk0Mvyb3pf8OlpIXqzojz5OabJdyJGcTtsyGcTptR2LqTIY1MebTLkDxcdsjuGGXbScbfAlv6UegKsOn5Sqolr7N5Rg0tytR4dg6b74lShmC4dUH8S0DjDUCszXp1174bANKWafA7Uaag6Z7(rbcghkueuOTuP7syqkH2KZc5SeTFMVAqpHnTIpyOhSJMe2dgo8b3qEw6UKoxoPS4N66D8aTtsyGcTDLJlNER8rbcghnjck0wQ0DjmiLqBYzHCwI2evRZMkpynnyIQnyOBhSd0ojHbk0opswcna3jvGcemoAciOq7KegOq7L5RgCQc4X4ZkvG2sLUlHbPekqW8TzeuOTuP7syqkH2KZc5SeTFMVAqpHnTIpyOhSJVWEWWHp4gYZs3L05YjLf)uxVJhODscduO9ZoXDbamOabZxhiOqBPs3LWGucTjNfYzjA)mF1GEcBAfFWqpyhFH9GHdFWnKNLUlPZLtkl(PUEhpq7KegOq7SicpUCrj5AHcemF)IGcTLkDxcdsj0MCwiNLODd5zP7s6C5KYIFQR3Xd0ojHbk02n9PGhnoJONJcemFBebfAlv6UegKsODLScANC1gYs40l1CWrjGlxODscduODYvBilHtVuZbhLaUCHcemFHfeuODscduOThxOwiSC0wQ0DjmiLqbcMVWgbfAlv6UegKsOn5Sqolr7ipFj6QsUc1UwsmyfBhSdyJ2jjmqH2bWJOsbpkJKHkkqW8fwHGcTTkKRHCH2nHMrBTKGQk5kur7M7WgTtsyGcTdGhrLcEu95XMOTuP7syqkHcemFvOiOqBPs3LWGucTjNfYzjAtaGfdWz1pJBLpL7vu9grF)e20k(GvCWFhmC4d(z(Qb9e20k(GvCWoGnANKWafAZLtkl(rbcMVnjck0ojHbk02n9PGhnoJONJ2sLUlHbPekqbAZdeuiyCGGcTtsyGcTDQA3YkFkZL(GIQ1RiQOTuP7syqkHcemFrqH2sLUlHbPeAtolKZs0MOAD2u5bRPbtuTbdD7G)oyihSuY5)3dJvObGYMkpyOhCJdgo8btuToBQ8G10GjQ2GHUDWWYGHCW6EWsjN)FpmwHgakBQ8GHEWFhmC4dwbhS2tAG6ty6o6H5lhvBUyhSUq7KegOqBPKZ30CR8PYYu2ouGGPreuOTuP7syqkH2KZc5SeTjawxaLhNPxgmKdw3d21796mzrek4rjQMcyDpTdgo8b769EDMSicf8OevtbmAQ5YzH090oyDH2jjmqH2CTwvw5tjxwcvVr0JcemWcck0ojHbk0(z8Gtbp6Z7(rBPs3LWGucfiyGnck0wQ0DjmiLq7KegOq7Z4w5t5EfvVr0J2KZc5SeTjaWIb4S6C5KYI)(jSPv8bd9GDmy4WhSco4ixsfDUCszXFxQ0DjmOn5NSeAKNVeCemoqbcgyfck0wQ0DjmiLqBYzHCwI2UEVx)84Qw5tvGKrOoTIPZaCwdgYbNKWAqOsjSMWhm0d2bANKWafAFECvR8PkqYiuNwXGcemkueuOTuP7syqkH2KZc5SeTjQwNnvEWAAWevBWq3oyhdwJblCUuePta1BzKGMfdLhN9KoBQaGdTtsyGcTfL1klQAESOabttIGcTLkDxcdsj0ojHbk0(z8GcE0qvOovTqOH5lhAtolKZs0MOAdwXb3iAt(jlHg55lbhbJduGGPjGGcTLkDxcdsj0MCwiNLOnr16SPYdwtdMOAdg62b7aTtsyGcTjQg1174bkqW4OzeuODscduOnr1OoZge0wQ0DjmiLqbcghoqqH2sLUlHbPeANKWafAhMVCuT5IfTjNfYzjAtaSUakpotVmyihmr16SPYdwtdMOAdg62b)DWqoyxV3RZdWXsL8cvAwm0NDsNb4SqBYpzj0ipFj4iyCGcemo(IGcTLkDxcdsj0MCwiNLOTR371jQgvk58)78ij6hm0dUXMhSMgmShmSEdojH1GqLsynHpyihmbW6cO84m9YGHCWUEVxNhGJLk5fQ0SyOp7KodWznyihSUhmbawmaNv)mUv(uUxr1Be99tytR4dg6b)DWqoycaSyaoR(Z4bNcE0N393pHnTIpyOh83bdh(GjaWIb4S6NXTYNY9kQEJOVFcBAfFWko4ghmKdMaalgGZQ)mEWPGh95D)9tytR4dg6b34GHCWevBWqp4ghmC4dMaalgGZQFg3kFk3RO6nI((jSPv8bd9GBCWqoycaSyaoR(Z4bNcE0N393pHnTIpyfhCJdgYbtuTbd9GHLbdh(GjQwNnvEWAAWevBWk2oyhdgYblLC()9WyfAaOSPYdwXb)DW6AWWHpyxV3RtunQuY5)35rs0pyOhSJMhmKd(z(Qb9e20k(GvCWku0ojHbk0MR1QYkFk5YsO6nIEuGGXrJiOqBPs3LWGucTtsyGcTDxjrpWlO6nIE0MCwiNLOnbW6cO84m9YGHCW6EWrUKk6C5KYI)UuP7sygmKdMaalgGZQZLtkl(7NWMwXhSIdUXbdh(GjaWIb4S6NXTYNY9kQEJOVFcBAfFWqpyhdgYbtaGfdWz1Fgp4uWJ(8U)(jSPv8bd9GDmy4WhmbawmaNv)mUv(uUxr1Be99tytR4dwXb34GHCWeayXaCw9NXdof8OpV7VFcBAfFWqp4ghmKdMOAdg6b)DWWHpycaSyaoR(zCR8PCVIQ3i67NWMwXhm0dUXbd5GjaWIb4S6pJhCk4rFE3F)e20k(GvCWnoyihmr1gm0dUXbdh(GjQ2GHEWWEWWHpyxV3R7c0t1Eas3t7G1fAt(jlHg55lbhbJduGGXbSGGcTLkDxcdsj0ojHbk0omF5OAZflAtolKZs0MayDbuECMEzWqoyIQ1ztLhSMgmr1gm0Td(lAt(jlHg55lbhbJduGGXbSrqH2wfYDEAd02bANKWafA)w)w5t5YPvQGQ3i6rBPs3LWGucfiyCaRqqH2sLUlHbPeANKWafA7UsIEGxq1Be9On5SqolrBcG1fq5Xz6Lbd5GjaWIb4S6pJhCk4rFE3F)e20k(GvCWnoyihmr1gC7G)oyihS2tAG6ty6o6H5lhvBUyhmKdwk58)7HXk0aqHDZdwXb7aTj)KLqJ88LGJGXbkqW4qHIGcTLkDxcdsj0ojHbk02DLe9aVGQ3i6rBYzHCwI2eaRlGYJZ0ldgYblLC()9WyfAaOSPYdwXb)DWqoyDpyIQ1ztLhSMgmr1gSITd2XGHdFWApPbQpHP7OhMVCuT5IDW6cTj)KLqJ88LGJGXbkqbANabbfcghiOqBPs3LWGucTjNfYzjA769EDNQ2TSYNYCPpOOA9kIA3tlANKWafA7u1ULv(uMl9bfvRxrurbcMViOqBPs3LWGucTjNfYzjAtuToBQ8G10GjQ2GHUDWFhmKdwk58)7HXk0aqztLhm0d(7GHdFWevRZMkpynnyIQnyOBhmSG2jjmqH2sjNVP5w5tLLPSDOabtJiOqBPs3LWGucTjNfYzjAtaSUakpotVmyihSUhSR371zYIiuWJsunfW6EAhmC4d21796mzrek4rjQMcy0uZLZcP7PDW6cTtsyGcT5ATQSYNsUSeQEJOhfiyGfeuOTuP7syqkH2KZc5SeTLso))EyScnau2u5bd9GfLfIxi0WyLbRPb7yWWHpyIQ1ztLhSMgmr1gSITd2XGHdFWUEVxNhGJLk5fQ0SyOp7K(jSPvC0ojHbk0(z8Gtbp6Z7(rbcgyJGcTLkDxcdsj0ojHbk0(mUv(uUxr1Be9On5SqolrBDp4ixsfDNQ2TSYNYCPpOOA9kIAxQ0DjmdgYbtaGfdWz1pJBLpL7vu9grFNX7YWa1GHEWeayXaCwDNQ2TSYNYCPpOOA9kIA)e20k(G1yWWYG11GHCW6EWeayXaCw9NXdof8OpV7VFcBAfFWqp4ghmC4dMOAdg62bd7bRl0M8twcnYZxcocghOabdScbfAlv6UegKsOn5SqolrBxV3RFECvR8PkqYiuNwX0zaol0ojHbk0(84Qw5tvGKrOoTIbfiyuOiOqBPs3LWGucTjNfYzjAtaSUakpotVmyihSUhSUhmr1gm0dUXbdh(GjaWIb4S6pJhCk4rFE3F)e20k(GHEWWQbRRbd5G19GjQ2GHUDWWEWWHpycaSyaoR(Z4bNcE0N393pHnTIpyOh83bRRbdh(GLso))EyScnau2u5bRy7GBCW6cTtsyGcT5ATQSYNsUSeQEJOhfiyAseuOTuP7syqkH2KZc5SeTjQwNnvEWAAWevBWq3oyhdwJblCUuePta1BzKGMfdLhN9KoBQaGdTtsyGcTfL1klQAESOabttabfAlv6UegKsODscduO9Z4bf8OHQqDQAHqdZxo0MCwiNLOnr16SPYdwtdMOAdg62b3iAt(jlHg55lbhbJduGGXrZiOqBPs3LWGucTjNfYzjAtuToBQ8G10GjQ2GHUDWFr7KegOqBIQrD9oEGcemoCGGcTLkDxcdsj0ojHbk0omF5OAZflAtolKZs0MOAD2u5bRPbtuTbdD7G)oyihSUhSco4ixsfDvlOeaRlOlv6UeMbdh(GjawxaLhNPxgSUqBYpzj0ipFj4iyCGcemo(IGcTLkDxcdsj0MCwiNLOnbW6cO84m9cANKWafAtunQZSbbfiyC0ick0wQ0DjmiLq7KegOq7363kFkxoTsfu9grpAtolKZs021796Ua9uThG0zaol02QqUZtBG2oqbcghWcck0wQ0DjmiLq7KegOqB3vs0d8cQEJOhTjNfYzjAtaSUakpotVmyihSUhSR371Db6PApaP7PDWWHp4ixsfDvlOeaRlOlv6UeMbd5G1EsduFct3rpmF5OAZf7GHCWevBWTd(7GHCWeayXaCw9NXdof8OpV7VFcBAfFWko4ghmC4dMOAD2u5bRPbtuTbRy7GDmyihS2tAG6ty6o6CTwvw5tjxwcvVr0pyDH2KFYsOrE(sWrW4afOafODdYXnqHG5BZFB2rZn2C3bA7mVYkFoARzJvl4cHzWn5GtsyGAWlJh8(8bT1EGNTe0wHhCtPvmoZLE5gSMDqPF(OWdgwhjaUYn4gBgIb)T5VnpFMpk8GviuwiEHWmyx5bozWeaRBgd2v8TI3hSMfHiAd(GlqPj18yFERbNKWafFWGA93NpjjmqX7ApHayDZqJwDElHRsU8fZNKegO4DTNqaSUzOrRonKNLUlbIkzLwL9KIckQhxOXzLEjGaOTLlbenKlpPT55tscdu8U2tiaw3m0OvhIQrD9oEaH9AvWixsfDUCszXFxQ0DjmWHRGrUKk6pJhuWJgQc1PQfcnmF56sLUlHz(KKWafVR9ecG1ndnA1HOAuNzdce2RvbJCjv0LsoFtZTYNkltz56sLUlHz(mFu4bRqOSq8cHzWsdY9p4WyLbhQYGtsaUbB8bNnK2kDxsF(KKWafVLRvYJQMfdLhNPxMpk8GBQjplDxYGd1mgStBTgCiR1G)bEd2Ed(h4nyN2An4seMbhGb7mTyWbyWKKhdgkGcPomGbxGyWoZkgCagmj5XGTyWzm4CTgCw)SGtMpjjmqX1OvNgYZs3LarLSsRkyXqv2tkiaAB5sard5YtAjaWIb4S6w1aqVqv2tkAOkuNQwi0W8LRFcBAfh6N5Rg0tytR4WH)mF1GEcBAfxrhFBgYN5Rg0tytR4qtaGfdWz15YjLf)9tytR4qsaGfdWz15YjLf)9tytR4q7O55Jcp4MixgSwqyGAW2BWB5KYI)bB8b7PfIbdUb7cc1bVviA6bNfZGHcOqo48Kb7PfIbdUbhQYGJ88LyWoT1AWmMmyNwOA1GHvnpyUqafdF(KKWafxJwD0ccduqyVwD769EDUCszXF3tlC4UEVxNhGJLk5fQ0SyOp7KUNwDbPwj6k7jfnufQtvleAy(Y1tsyniWH)mF1GEcBAfxXwyvZZhfEWAMCTgCOkdElNuw8p4KegOg8Y4XGT3G3YjLf)d24dM4DNuX6FWEANpjjmqX1OvhsUw0KegOOlJhqujR0YLtkl(HWETUEVxNlNuw8390oFu4bp4MixgCtdIMsOgS9g8G)bEdopzWSgNBL)GZyWlj5XGBCWevdIbRzvmd(h4nyXcv5gCEYGtxGxm4amysQDWsjN)pedgCdMlNuw8pyJp40f4fdoadMayLb7PfIbdUb30GMEWgFWeaRv(d2t7GZIzW)aVb70wRbtsTdwk58)hmhaQ5tscduCnA1HKRfnjHbk6Y4bevYkTaTsjhe2Rnmwrrydjr1ue2qQGALORSNu0qvOovTqOH5lxpjH1GmFssyGIRrRopJhuWJgQc1PQfcnmF5GG8twcnYZxcERdiSxlr16SPYAIOAq32iK6wk58)7HXk0aqztLv0bC4sjN)FpmwHgakBQSIWcKeayXaCw9NXdof8OpV7VFcBAfxrhDyRR5tscduCnA1ruwRSOQ5XcH9AjQwNnvwtevd6whAiCUuePta1BzKGMfdLhN9KoBQaGdsDlLC()9WyfAaOSPYk6aoCcaSyaoRoxoPS4VFcBAfxXVWHlLC()9WyfAaOSPYkclqsaGfdWz1Fgp4uWJ(8U)(jSPvCfD0HTUMpjjmqX1OvNW8LJQnxSqq(jlHg55lbV1be2RLayDbuECMEbsIQ1ztL1er1GU9lK6wk58)7HXk0aqztLv0bC4eayXaCwDUCszXF)e20kUIFHdxk58)7HXk0aqztLvewGKaalgGZQ)mEWPGh95D)9tytR4k6OdBDnFssyGIRrRoKCTOjjmqrxgpGOswPLWq5Ydc71QGrUKk6C5KYI)UuP7syMpjjmqX1OvhsUw0KegOOlJhqujR0syOC5KYIFiSxBKlPIoxoPS4Vlv6UeM5JcpyntUwdouLbVHAWjjmqn4LXJbBVbhQYjdopzWFhm4g8s48blLWAcF(KKWafxJwDi5ArtsyGIUmEarLSslpGWETjjSgeQucRjCfBC(OWdwZKR1GdvzWAwafIbNKWa1GxgpgS9gCOkNm48Kb34Gb3GzbNmyPewt4ZNKegO4A0QdjxlAscdu0LXdiQKvAtGaH9AtsyniuPewt4q3248z(OWdwZIegO4DnlGcXGn(GTkKIryg8dCd2Jld2PfQdUPUqcJq1SyyOAMLKnidolMbt8UtQy9p4seg(GdWGDLbd0ggRP5cZ8jjHbkEpbsRtv7ww5tzU0huuTEfrfc71669EDNQ2TSYNYCPpOOA9kIA3t78jjHbkEpbIgT6iLC(MMBLpvwMY2bH9AjQwNnvwtevd62VqkLC()9WyfAaOSPYq)foCIQ1ztL1er1GUfwMpjjmqX7jq0OvhUwRkR8PKllHQ3i6HWETeaRlGYJZ0lqQBxV3RZKfrOGhLOAkG190chUR371zYIiuWJsunfWOPMlNfs3tRUMpjjmqX7jq0OvNNXdof8OpV7hc71kLC()9WyfAaOSPYqlkleVqOHXkAYbC4evRZMkRjIQPyRd4WD9EVopahlvYluPzXqF2j9tytR4ZNKegO49eiA0QZzCR8PCVIQ3i6HG8twcnYZxcERdiSxRUJCjv0DQA3YkFkZL(GIQ1RiQDPs3LWajbawmaNv)mUv(uUxr1Be9DgVldduqtaGfdWz1DQA3YkFkZL(GIQ1RiQ9tytR4Aal6csDtaGfdWz1Fgp4uWJ(8U)(jSPvCOBeoCIQbDlS118jjHbkEpbIgT6CECvR8PkqYiuNwXaH9AD9EV(5XvTYNQajJqDAftNb4SMpjjmqX7jq0OvhUwRkR8PKllHQ3i6HWETeaRlGYJZ0lqQBDtunOBeoCcaSyaoR(Z4bNcE0N393pHnTIdnSsxqQBIQbDlSHdNaalgGZQ)mEWPGh95D)9tytR4q)vxWHlLC()9WyfAaOSPYk22OUMpjjmqX7jq0OvhrzTYIQMhle2RLOAD2uznrunOBDOHW5srKobuVLrcAwmuEC2t6SPcaU5tscdu8EcenA15z8GcE0qvOovTqOH5lheKFYsOrE(sWBDaH9AjQwNnvwtevd62gNpjjmqX7jq0OvhIQrD9oEaH9AjQwNnvwtevd62VZNKegO49eiA0Qty(Yr1Mlwii)KLqJ88LG36ac71suToBQSMiQg0TFHu3kyKlPIUQfucG1f0LkDxcdC4eaRlGYJZ0l6A(KKWafVNarJwDiQg1z2GaH9AjawxaLhNPxMpjjmqX7jq0OvN363kFkxoTsfu9grpe2R11796Ua9uThG0zaoliSkK780gToMpjjmqX7jq0Ovh3vs0d8cQEJOhcYpzj0ipFj4ToGWETeaRlGYJZ0lqQBxV3R7c0t1Eas3tlC4rUKk6QwqjawxqxQ0DjmqQ9KgO(eMUJEy(Yr1MlwijQw7xijaWIb4S6pJhCk4rFE3F)e20kUInchor16SPYAIOAk26asTN0a1NW0D05ATQSYNsUSeQEJOxxZN5Jcp4DaowigScrEHkedolMb302jdwZaalgGZIpFssyGI3jmuU8ATQbGEHQSNu0qvOovTqOH5lhe2RvbBiplDxsxfSyOk7jfC4pZxnONWMwXv8lSNpjjmqX7egkxEA0QZlxlPOGJrU5tscdu8oHHYLNgT64ckHXJhu3tCoFssyGI3jmuU80OvhNsQfuCk4rbhJCZhfEWnrUmynRJKLmyOa3jvmy7n4FG3GZtgmRX5w5p4mg8ssEmyhdwZOAZNKegO4DcdLlpnA1jpswcna3jvaH9AjQwNnvwtevd6whZNKegO4DcdLlpnA1jaEevk4rzKmuHWETrE(s0vLCfQDTKqXwhWgsxV3RZdWXsL8cvAwm0NDsNb4SMpjjmqX7egkxEA0QJ7cayOGhnufQuc7pe2RLaalgGZQ)mEWPGh95D)9tytR4k(fo8N5Rg0tytR4k6478jjHbkENWq5YtJwD89YJXYIcE0uZLdeQZNKegO4DcdLlpnA1Xj4wmniwrpHdQSiY8jjHbkENWq5YtJwDiGIivCzim03kzfiSxRcYaIobuePIldHH(wjRqD9UQFcBAfhsDRBfmYLur3PQDlR8Pmx6dkQwVIO2LkDxcdC4eayXaCwDNQ2TSYNYCPpOOA9kIA)e20kUUGKaalgGZQFg3kFk3RO6nI((jSPvCijaWIb4S6pJhCk4rFE3F)e20koKUEVxNhGJLk5fQ0SyOp7KodWzPl4WFMVAqpHnTIRytoFssyGI3jmuU80OvNqvOELlWRyOpWrK5tscdu8oHHYLNgT6O17S3Vv(u3vYJ5tscdu8oHHYLNgT6CsQ1kF6BLSchc71g55lrpmwHgaQwsq)2m0n2mC4rE(s0vLCfQDTKqX2VnpFssyGI3jmuU80OvNhG4XfgAQ5YzHqDLKD(KKWafVtyOC5PrRoScl4(PGhD5rmgkZjjlhc71kLC()kclnpFssyGI3jmuU80OvNZ0QDjuROCTjrMpjjmqX7egkxEA0QdpahlvYluPzXqF2jqyVwcaSyaoRopahlvYluPzXqF2jDIAE(cV9lC4pZxnONWMwXv8BZWH769EDUiHQv(0l9LUNw4W1nbawmaNv3DbamuWJgQcvkH9VFcBAfxdhqtaGfdWz15b4yPsEHknlg6ZoP)8wl6je188fAyScC4kOW5srKU7cayOGhnufQuc7FNnvaWPlijaWIb4S6pJhCk4rFE3F)e20kUIoAgsIQbD7xijaWIb4S6ovTBzLpL5sFqr16ve1(jSPvCfD8D(KKWafVtyOC5PrRoECHAHWcrLSsBYvBilHtVuZbhLaUCnFssyGI3jmuU80OvhpUqTqy5ZNKegO4DcdLlpnA1jaEevk4r1NhBcHvHCnKR2MqZqOLeuvjxHABZDypFu4b3e5YGvAbamdUP9U)bBVbdfWJOoyWBWkKsgQW6ZhmbawmaN1Gn(G9pjd5gCOM1GBS5bR7q14d2kYYJr4d2PQTKbdfqHCWgFWeV7Kkw)dojH1GOligm4gm49gmbawmaN1GDQk1G)bEdopzWQGfJv(dgubyWqbuiHyWGBWovLAWHQm4ipFjgSXhC6c8IbhGbZyY8jjHbkENWq5YtJwDCxaad95D)qyV2N5Rg0tytR4q74lSHd317968aCSujVqLMfd9zN090ch(Z8vd6jSPvCf)288jjHbkENWq5YtJwDCLJlNER8HWETpZxnONWMwXH2rtcB4WD9EVopahlvYluPzXqF2jDpTWH)mF1GEcBAfxXVnpFssyGI3jmuU80OvNL5RgCQc4X4ZkvmFssyGI3jmuU80OvNNDI7cayGWETpZxnONWMwXH2XxydhUR3715b4yPsEHknlg6ZoP7Pfo8N5Rg0tytR4k(T55tscdu8oHHYLNgT6Kfr4XLlkjxliSx7Z8vd6jSPvCOD0KWgoCxV3RZdWXsL8cvAwm0NDs3tlC4pZxnONWMwXv8BZjjmqX7egkxEA0QJB6tbpACgrphc71669EDEaowQKxOsZIH(St6maN18z(OWdElNuw8pyndaSyaol(8jjHbkENWq5YjLf)TnKNLUlbIkzLwUCszXp1174beaTTCjGOHC5jTeayXaCwDUCszXF)e20kUIoGd)z(Qb9e20kUIFBE(KKWafVtyOC5KYIFnA1XQga6fQYEsrdvH6u1cHgMVCqyVwfSH8S0DjDvWIHQSNuWH)mF1GEcBAfxXVWE(KKWafVtyOC5KYIFnA15LRLuuWXi38jjHbkENWq5YjLf)A0QJlOegpEqDpX58jjHbkENWq5YjLf)A0QJtj1ckof8OGJrU5tscdu8oHHYLtkl(1OvhFV8ySSOGhn1C5aHke2R9z(Qb9e20ko0oAsydhEd5zP7s6C5KYIFQR3Xd4WFMVAqpHnTIRyJWE(KKWafVtyOC5KYIFnA1Xj4wmniwrpHdQSice2RTH8S0DjDUCszXp1174X8jjHbkENWq5YjLf)A0QJ7cayOGhnufQuc7pe2RTH8S0DjDUCszXp1174X8jjHbkENWq5YjLf)A0QdbuePIldHH(wjRaH9A1nbawmaNvNlNuw83pHnTIdhobawmaNvNakIuXLHWqFRKv6e188fE7xDbPcYaIobuePIldHH(wjRqD9UQFcBAfhsDtaGfdWz1pJBLpL7vu9grF)e20koKeayXaCw9NXdof8OpV7VFcBAfho8N5Rg0tytR4k2K6A(KKWafVtyOC5KYIFnA1jufQx5c8kg6dCez(KKWafVtyOC5KYIFnA1rR3zVFR8PURKhZNKegO4DcdLlNuw8RrRoNKATYN(wjRWHWETrE(s0dJvObGQLe0VndDJndhEKNVeDvjxHAxljuS9BZWHh55lrpmwHgakJjk(D(KKWafVtyOC5KYIFnA15biECHHMAUCwiuxjzNpjjmqX7egkxoPS4xJwDyfwW9tbp6YJymuMtswoe2Rvk58)vewAE(KKWafVtyOC5KYIFnA15mTAxc1kkxBsK5tscdu8oHHYLtkl(1Ovh3faWqFE3pe2R9z(Qb9e20ko0o(cB4WBiplDxsNlNuw8tD9oEmFssyGI3jmuUCszXVgT64khxo9w5dH9AFMVAqpHnTIdTJMe2WH3qEw6UKoxoPS4N66D8y(KKWafVtyOC5KYIFnA1jpswcna3jvaH9AjQwNnvwtevd6whZNKegO4DcdLlNuw8RrRolZxn4ufWJXNvQy(KKWafVtyOC5KYIFnA15zN4UaagiSx7Z8vd6jSPvCOD8f2WH3qEw6UKoxoPS4N66D8y(KKWafVtyOC5KYIFnA1jlIWJlxusUwqyV2N5Rg0tytR4q74lSHdVH8S0DjDUCszXp1174X8jjHbkENWq5YjLf)A0QJB6tbpACgrphc712qEw6UKoxoPS4N66D8y(KKWafVtyOC5KYIFnA1XJlulewiQKvAtUAdzjC6LAo4OeWLR5tscdu8oHHYLtkl(1OvhpUqTqy5ZNKegO4DcdLlNuw8RrRobWJOsbpkJKHke2RnYZxIUQKRqTRLek26a2ZNKegO4DcdLlNuw8RrRobWJOsbpQ(8ytiSkKRHC12eAgcTKGQk5kuBBUd75tscdu8oHHYLtkl(1OvhUCszXpe2RLaalgGZQFg3kFk3RO6nI((jSPvCf)ch(Z8vd6jSPvCfDa75tscdu8oHHYLtkl(1Ovh30NcE04mIE(8z(OWdgwNwPKB(KKWafVd0kLCTpJhuWJgQc1PQfcnmF5GG8twcnY78LG36ac71suToBQSMiQg0TnoFssyGI3bALsonA1ruwRSOQ5XcH9AJCjv0jQg1174rxQ0DjmqsuToBQSMiQg0TnoFssyGI3bALsonA1jmF5OAZfleKFYsOrE(sWBDaH9AjawxaLhNPxGKOAD2uznrunOB)oFssyGI3bALsonA1ruwRSOQ5XoFssyGI3bALsonA1jmF5OAZfleKFYsOrE(sWBDaH9AjQwNnvwtevd62VZN5Jcp4MQZaNf)dUPu1wYG3YjLf)dwZgFWnrTZNKegO4DUCszXF7Z4bNcE0N39dH9AD9EVoxoPS4VFcBAfxrhWHNKWAqOsjSMWH2X8jjHbkENlNuw8RrRoCTwvw5tjxwcvVr0dH9AjawxaLhNPxGu3jjSgeQucRjCO)chEscRbHkLWAchAhqQGeayXaCw9Z4w5t5EfvVr0390QR5tscdu8oxoPS4xJwDoJBLpL7vu9grpeKFYsOrE(sWBDaH9AjawxaLhNPxMpjjmqX7C5KYIFnA1HR1QYkFk5YsO6nIEiSxlbW6cO84m9cK621796mzrek4rjQMcyDpTWH769EDMSicf8OevtbmAQ5YzH090QR5JcpyOun(GDAR1GjjpgCtdA6bNfZGTkK780gdouLbtuZQK1GT3GdvzWn1QzuihSXh8jjZ)GZIzWCaReQw5pyvZxvUbdQbhQYG1Eg4S4FWlJhdw3nfBynDnyJp4SH0CxY8jjHbkENlNuw8RrRopJhCk4rFE3pewfYDEAdQ9A9jm9tytR4TnpFssyGI35YjLf)A0QZZ4bf8OHQqDQAHqdZxoii)KLqJ88LG36ac71sunfBC(OWdUjYLbReawdIbBXGDAR1Gb16FWUNK6hmBYd5(hS9gCtDlgSMbW6cgSXhmmW6GAWrUKkeM5tscdu8oxoPS4xJwDCxjrpWlO6nIEii)KLqJ88LG36ac71saSUakpotVahUcg5sQORAbLayDbDPs3LWmFssyGI35YjLf)A0QdxRvLv(uYLLq1Be9ZN5Jcp4Tv(lzWrE(sm4MQZaNf)ZNKegO4DE06u1ULv(uMl9bfvRxruNpjjmqX78qJwDKsoFtZTYNkltz7GWETevRZMkRjIQbD7xiLso))EyScnau2uzOBeoCIQ1ztL1er1GUfwGu3sjN)FpmwHgakBQm0FHdxb1EsduFct3rpmF5OAZfRUMpjjmqX78qJwD4ATQSYNsUSeQEJOhc71saSUakpotVaPUD9EVotweHcEuIQPaw3tlC4UEVxNjlIqbpkr1uaJMAUCwiDpT6A(KKWafVZdnA15z8Gtbp6Z7(Npk8GBICzWnfByTbdQbh55lbFWoTqf4fdwZEE6hm4n4qvgSM5YsgmJ469Eqmy7nyTao3CxcedolMbBVbVLtkl(hSXhCgdEjjpg83bZfcOy4doDM)ZNKegO4DEOrRoNXTYNY9kQEJOhcYpzj0ipFj4ToGWETeayXaCwDUCszXF)e20ko0oGdxbJCjv05YjLf)DPs3LWmFssyGI35HgT6CECvR8PkqYiuNwXaH9AD9EV(5XvTYNQajJqDAftNb4SGmjH1GqLsynHdTJ5tscdu8op0OvhrzTYIQMhle2RLOAD2uznrunOBDOHW5srKobuVLrcAwmuEC2t6SPcaU5tscdu8op0OvNNXdk4rdvH6u1cHgMVCqq(jlHg55lbV1be2RLOAk248rHhCtKldwZO0GT3G)bEdopzWSGtgCOM1GBEWAgvBWPZ8FWVdWoy2u5bNfZGvZgKb7yWsjS)qmyWn48KbZcozWHAwd2XG1mQ2GtN5)GFhGDWSPYZNKegO4DEOrRoevJ66D8ac71suToBQSMiQg0ToMpjjmqX78qJwDiQg1z2GmFu4b3e5YGHQPAW2BW)aVbNNmyyzWGBWSGtgmr1gC6m)h87aSdMnvEWzXmyOakKdolMbVviA6bNNmyxqOo4ced2t78jjHbkENhA0Qty(Yr1Mlwii)KLqJ88LG36ac71saSUakpotVajr16SPYAIOAq3(fsxV3RZdWXsL8cvAwm0NDsNb4SMpjjmqX78qJwD4ATQSYNsUSeQEJOhc71669EDIQrLso))opsIEOBSznbBy9ssyniuPewt4qsaSUakpotVaPR3715b4yPsEHknlg6ZoPZaCwqQBcaSyaoR(zCR8PCVIQ3i67NWMwXH(lKeayXaCw9NXdof8OpV7VFcBAfh6VWHtaGfdWz1pJBLpL7vu9grF)e20kUIncjbawmaNv)z8Gtbp6Z7(7NWMwXHUrijQg0nchobawmaNv)mUv(uUxr1Be99tytR4q3iKeayXaCw9NXdof8OpV7VFcBAfxXgHKOAqdlWHtuToBQSMiQMIToGuk58)7HXk0aqztLv8RUGd31796evJkLC()DEKe9q7OziFMVAqpHnTIROcD(OWdUjYLbReawBW2BWUGqDWnnOPhCwmdUPydRn48KbxGyWKfGlqmyWn4MInS2Gn(GjlaxgCwmdUPbn9Gn(GlqmyYcWLbNfZG)bEdwnBqgml4KbhQzn4VdMOAqmyWn4Mg00d24dMSaCzWnfByTbB8bxGyWKfGldolMb)d8gSA2GmywWjdouZAWnoyIQbXGb3G)bEdwnBqgml4KbhQznyypyIQbXGb3GT3G)bEd2xIbNdw7biZNKegO4DEOrRoURKOh4fu9grpeKFYsOrE(sWBDaH9AjawxaLhNPxGu3rUKk6C5KYI)UuP7syGKaalgGZQZLtkl(7NWMwXvSr4WjaWIb4S6NXTYNY9kQEJOVFcBAfhAhqsaGfdWz1Fgp4uWJ(8U)(jSPvCODahobawmaNv)mUv(uUxr1Be99tytR4k2iKeayXaCw9NXdof8OpV7VFcBAfh6gHKOAq)foCcaSyaoR(zCR8PCVIQ3i67NWMwXHUrijaWIb4S6pJhCk4rFE3F)e20kUIncjr1GUr4WjQg0WgoCxV3R7c0t1Eas3tRUMpjjmqX78qJwDcZxoQ2CXcb5NSeAKNVe8whqyVwcG1fq5Xz6fijQwNnvwtevd62VZhfEWnrUm4MEdRn4SygSvHCNN2yWwmyECP5RgdoDM)ZNKegO4DEOrRoV1Vv(uUCALkO6nIEiSkK780gToMpk8GBICzWkbG1gS9gCtdA6bB8btwaUm4Syg8pWBWQzdYG)oyIQn4Syg8pW7g8k5XG9xa3CnyNjFWq1ubXGb3GT3G)bEdopzWPlWlgCagmj1oyPKZ)FWzXmyXcv5g8pW7g8k5XG9jmd2zYhmunvdgCd2Ed(h4n48KbVeoFWHAwd(7GjQ2GtN5)GFhGDWKuRwR8NpjjmqX78qJwDCxjrpWlO6nIEii)KLqJ88LG36ac71saSUakpotVajbawmaNv)z8Gtbp6Z7(7NWMwXvSrijQw7xi1EsduFct3rpmF5OAZflKsjN)FpmwHgakSBwrhZNKegO4DEOrRoURKOh4fu9grpeKFYsOrE(sWBDaH9AjawxaLhNPxGuk58)7HXk0aqztLv8lK6MOAD2uznrunfBDahU2tAG6ty6o6H5lhvBUy1fANEHk4q7TXQzqbkqia]] )

end