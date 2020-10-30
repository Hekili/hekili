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
    
    spec:RegisterPack( "Windwalker", 20201030, [[dSeXJbqiuf6rOkQnbH(KuuP0OivYPivQvjfvQEfPWSGGBrkYUKQFrQyysrogvyzQk9mPqtdsfxdsvBdsL6BsrHXjfLohQI08qv6EsP9broiQIWcrv1djfftevr0fjfLSrPOQpkfvkgjKkPCssrPALQkEjKkXnjfLYoHu(jKkjdvkQWsLIk5Pk1uHOUQuu0wHujvFvkQO9I4Vinyqhw0IPspgQjJIltSzv5ZuvJgvonLvJQGxtQA2k52O0UL8BGHtkTCvEojtx46uLTlf8DQOXJQY5vvTEsr18HK9RyIdcYKntgcbTVn9Tjhn1ytDhn9Trh8uYo(1kKT2eRp9fYUswHSBoTIXzU0lhzRn)xGKHGmzRaEhwiBY21ZwHM9I4s2mzie0(203MC0uJn1D003gDGoKTsRGjO9fDZtjBoJHrkIlzZikmzZZdS50kgN5sVCduZgO0pF45bIUchax5gyJnHWa)203Mi7LPcfbzYgZqvYJGmbnheKjBPs3LWq4NSXNfYzjzZJdSH8S0DjDoWIHYNNudefQb(mFUGEcBALAG8oWVONStCyGISTQbGEHYNNuKGG2xcYKDIdduK9lxlPOGJroYwQ0Djme(jbbTgjit2jomqr2UGsy8ub19eNKTuP7syi8tccAOdbzYoXHbkY2PKAbLIcEuWXihzlv6Uegc)KGGg6jit2sLUlHHWpzJplKZsYgZzD2KVbQPbI5SbIu7aDq2jomqr25HZsOb4oPcsqqdDtqMSLkDxcdHFYgFwiNLKDKNVeDojxbxxlogiVTd0b6hiId01796QaCSujVGJMfd9zN0zaolYoXHbkYoaEyok4rzKm4ibbTMbbzYwQ0Djme(jB8zHCws2yayXaCw9NPcff8OpV7VFcBALAG8oWVdefQb(mFUGEcBALAG8oqhFj7ehgOiB3faWqbpAWjuPe2FsqqRzjit2jomqr2(E5XyzrbpAQ5YbcoYwQ0Djme(jbbnEkbzYoXHbkY2j4wmniwrprbQSWczlv6Uegc)KGGMJMiit2sLUlHHWpzJplKZsYMhhidi6yqHLkUmeg6BLSc117Q(jSPvQbI4a11a11a5Xbg5sQO7KZULv(uMl9bfvRxH56sLUlHzGOqnqmaSyaoRUto7ww5tzU0huuTEfMRFcBALAG6EGioqmaSyaoR(zkR8PkVIQ3W67NWMwPgiIdedalgGZQ)mvOOGh95D)9tytRudeXb669EDvaowQKxWrZIH(St6maN1a19arHAGpZNlONWMwPgiVdSzj7ehgOiBmOWsfxgcd9TswHee0C4GGmzN4WafzhCc1RCbEfd9boSq2sLUlHHWpjiO54lbzYoXHbkYwR3zVFR8PURufKTuP7syi8tccAoAKGmzlv6Uegc)Kn(Sqolj7ipFj6HXk0aq1Id63MgisdSXMgikudmYZxIoNKRGRRfhdK32b(TjYoXHbkY(KuRv(03kzffjiO5aDiit2jomqr2pa2tjm0uZLZcH6kjlzlv6Uegc)KGGMd0tqMSLkDxcdHFYgFwiNLKTuY5)pqEhi60ezN4WafzZkSG7NcE0Lh2yOmNKSksqqZb6MGmzN4WafzFMwTlHAfvPnXczlv6Uegc)KGGMJMbbzYwQ0Djme(jB8zHCws2yayXaCwDvaowQKxWrZIH(St6yU88f1aBh43bIc1aFMpxqpHnTsnqEh43Mgikud01796krcoR8Px6lDpTdefQbQRbIbGfdWz1Dxaadf8ObNqLsy)7NWMwPgOgd0XarAGyayXaCwDvaowQKxWrZIH(St6pV1IEcMlpFHggRmquOgipoqrPKclD3faWqbpAWjuPe2)oBYdGBG6EGioqmaSyaoR(ZuHIcE0N393pHnTsnqEhOJMgiIdeZzdeP2b(DGioqmaSyaoRUto7ww5tzU0huuTEfMRFcBALAG8oqhFj7ehgOiBvaowQKxWrZIH(StibbnhnlbzYwQ0Djme(j7kzfYovCnKLOOxQ5GJIbxUi7ehgOi7uX1qwIIEPMdokgC5Iee0CWtjit2wfY1qUiBEAtKTwCq5KCfCKDtD0t2jomqr2bWdZrbpQ(8ytYwQ0Djme(jbbTVnrqMSLkDxcdHFYgFwiNLK9Z85c6jSPvQbI0aD8f9defQb669EDvaowQKxWrZIH(St6EAhikud8z(Cb9e20k1a5DGFBIStCyGISDxaad95D)KGG2xheKjBPs3LWq4NSXNfYzjz)mFUGEcBALAGinqhnl6hikud01796QaCSujVGJMfd9zN090oquOg4Z85c6jSPvQbY7a)2ezN4Wafz7kNso9w5tccAF)sqMStCyGISxMpxOO8GhJpRubzlv6Uegc)KGG23gjit2sLUlHHWpzJplKZsY(z(Cb9e20k1arAGo(I(bIc1aD9EVUkahlvYl4OzXqF2jDpTdefQb(mFUGEcBALAG8oWVnr2jomqr2p7e3faWqccAFrhcYKTuP7syi8t24Zc5SKSD9EVUkahlvYl4OzXqF2jDgGZIStCyGISZclQ4YffNRfjibzRKtkl(jitqZbbzYwQ0Djme(jB8zHCws2UEVxxjNuw83pHnTsnqEhOJbIc1atCyniuPewtudePb6GStCyGISFMkuuWJ(8UFsqq7lbzYwQ0Djme(jB8zHCws2yaRlGQIZ0ldeXbQRbM4WAqOsjSMOgisd87arHAGjoSgeQucRjQbI0aDmqehipoqmaSyaoR(zkR8PkVIQ3W67EAhOUj7ehgOiBLwRkR8P4llHQ3W6jbbTgjit2sLUlHHWpzN4WafzFMYkFQYRO6nSEYgFwiNLKngW6cOQ4m9czJ)XlHg55lHIGMdsqqdDiit2sLUlHHWpzJplKZsYgdyDbuvCMEzGioqDnqxV3RZKfwOGhfZz8G190oquOgOR371zYcluWJI5mEWOPMlNfs3t7a1nzN4WafzR0AvzLpfFzju9gwpjiOHEcYKTvHCNN2GApY2hZ0pHnTs12ezN4Wafz)mvOOGh95D)KTuP7syi8tccAOBcYKTuP7syi8t2jomqr2ptfuWJgCc1jNfcnmF5iB8zHCws2yoBG8oWgjB8pEj0ipFjue0CqccAndcYKTuP7syi8t2jomqr2UReRh4fu9gwpzJplKZsYgdyDbuvCMEzGOqnqECGrUKk6CwqXawxqxQ0DjmKn(hVeAKNVekcAoibbTMLGmzN4WafzR0AvzLpfFzju9gwpzlv6Uegc)KGeKnJ8sVvqqMGMdcYKDIdduKTsRKhLllgQkotVq2sLUlHHWpjiO9LGmzlv6Uegc)KnqlzRKGStCyGISBiplDxcz3qU8eYgdalgGZQBvda9cLppPObNqDYzHqdZxU(jSPvQbI0aFMpxqpHnTsnquOg4Z85c6jSPvQbY7aD8TPbI4aFMpxqpHnTsnqKgigawmaNvxjNuw83pHnTsnqehigawmaNvxjNuw83pHnTsnqKgOJMi7gYJwjRq2CGfdLppPibbTgjit2sLUlHHWpzJplKZsYwxd01796k5KYI)UN2bIc1aD9EVUkahlvYl4OzXqF2jDpTdu3deXbQvIoFEsrdoH6KZcHgMVC9ehwdYarHAGpZNlONWMwPgiVTdeD3ezN4WafzRfegOibbn0HGmzlv6Uegc)Kn(SqoljBxV3RRKtkl(7EAj7ehgOiBCUw0ehgOOltfK9YubTswHSvYjLf)KGGg6jit2sLUlHHWpzJplKZsYomwzG8oq0pqehiMZgiVde9deXbYJduReD(8KIgCc1jNfcnmF56joSgeYoXHbkYgNRfnXHbk6YubzVmvqRKviBGwPKJee0q3eKjBPs3LWq4NStCyGISFMkOGhn4eQtoleAy(Yr24Zc5SKSXCwNn5BGAAGyoBGi1oWghiIduxduk58)7HXk0aqzt(giVd0XarHAGsjN)FpmwHgakBY3a5DGOZarCGyayXaCw9NPcff8OpV7VFcBALAG8oqhD0pqDt24F8sOrE(sOiO5Gee0AgeKjBPs3LWq4NSXNfYzjzJ5SoBY3a10aXC2arQDGogOgduukPWshdQ3YWbnlgQko7jD2Kha3arCG6AGsjN)FpmwHgakBY3a5DGogikudedalgGZQRKtkl(7NWMwPgiVd87arHAGsjN)FpmwHgakBY3a5DGOZarCGyayXaCw9NPcff8OpV7VFcBALAG8oqhD0pqDt2jomqr2cFALfLlpwsqqRzjit2sLUlHHWpzN4WafzhMVCuT5ILSXNfYzjzJbSUaQkotVmqehiMZ6SjFdutdeZzdeP2b(DGioqDnqPKZ)VhgRqdaLn5BG8oqhdefQbIbGfdWz1vYjLf)9tytRudK3b(DGOqnqPKZ)VhgRqdaLn5BG8oq0zGioqmaSyaoR(ZuHIcE0N393pHnTsnqEhOJo6hOUjB8pEj0ipFjue0CqccA8ucYKTuP7syi8t24Zc5SKS5Xbg5sQORKtkl(7sLUlHHStCyGISX5ArtCyGIUmvq2ltf0kzfYgZqvYJee0C0ebzYwQ0Djme(jB8zHCws2rUKk6k5KYI)UuP7syi7ehgOiBCUw0ehgOOltfK9YubTswHSXmuLCszXpjiO5WbbzYwQ0Djme(jB8zHCws2joSgeQucRjQbY7aBKStCyGISX5ArtCyGIUmvq2ltf0kzfYwfKGGMJVeKjBPs3LWq4NSXNfYzjzN4WAqOsjSMOgisTdSrYoXHbkYgNRfnXHbk6YubzVmvqRKvi7eiKGeKT2tWaw3miitqZbbzYoXHbkY(Tefh(Yxq2sLUlHHWpjiO9LGmzlv6Uegc)KnqlzRKGStCyGISBiplDxcz3qU8eYUjYUH8OvYkKnFEsrbf1tj04SsVeKGGwJeKjBPs3LWq4NSXNfYzjzZJdmYLurxjNuw83LkDxcZarHAG84aJCjv0FMkOGhn4eQtoleAy(Y1LkDxcdzN4WafzJ5mQR3PcsqqdDiit2sLUlHHWpzJplKZsYMhhyKlPIUuY5BAUv(uzz8jxxQ0DjmKDIdduKnMZOoZgesqcYobcbzcAoiit2sLUlHHWpzJplKZsY21796o5SBzLpL5sFqr16vyUUNwYoXHbkY2jNDlR8Pmx6dkQwVcZrccAFjit2sLUlHHWpzJplKZsYgZzD2KVbQPbI5SbIu7a)oqehOuY5)3dJvObGYM8nqKg43bIc1aXCwNn5BGAAGyoBGi1oq0HStCyGISLsoFtZTYNklJp7ibbTgjit2sLUlHHWpzJplKZsYgdyDbuvCMEzGioqDnqxV3RZKfwOGhfZz8G190oquOgOR371zYcluWJI5mEWOPMlNfs3t7a1nzN4WafzR0AvzLpfFzju9gwpjiOHoeKjBPs3LWq4NSXNfYzjzlLC()9WyfAaOSjFdePbk8jyVqOHXkdutd0XarHAGyoRZM8nqnnqmNnqEBhOJbIc1aD9EVUkahlvYl4OzXqF2j9tytRuKDIdduK9ZuHIcE0N39tccAONGmzlv6Uegc)KDIdduK9zkR8PkVIQ3W6jB8zHCws26AGrUKk6o5SBzLpL5sFqr16vyUUuP7sygiIdedalgGZQFMYkFQYRO6nS(oJ3LHbQbI0aXaWIb4S6o5SBzLpL5sFqr16vyU(jSPvQbQXarNbQ7bI4a11aXaWIb4S6ptfkk4rFE3F)e20k1arAGnoquOgiMZgisTde9du3Kn(hVeAKNVekcAoibbn0nbzYwQ0Djme(jB8zHCws2UEVx)8uCw5t5HKrOoTIPZaCwKDIdduK95P4SYNYdjJqDAfdjiO1miit2sLUlHHWpzJplKZsYgdyDbuvCMEzGioqDnqDnqmNnqKgyJdefQbIbGfdWz1FMkuuWJ(8U)(jSPvQbI0ar3du3deXbQRbI5SbIu7ar)arHAGyayXaCw9NPcff8OpV7VFcBALAGinWVdu3defQbkLC()9WyfAaOSjFdK32b24a1nzN4WafzR0AvzLpfFzju9gwpjiO1SeKjBPs3LWq4NSXNfYzjzJ5SoBY3a10aXC2arQDGogOgduukPWshdQ3YWbnlgQko7jD2KhahzN4Wafzl8PvwuU8yjbbnEkbzYwQ0Djme(j7ehgOi7NPck4rdoH6KZcHgMVCKn(SqoljBmN1zt(gOMgiMZgisTdSrYg)JxcnYZxcfbnhKGGMJMiit2sLUlHHWpzJplKZsYgZzD2KVbQPbI5SbIu7a)s2jomqr2yoJ66DQGee0C4GGmzlv6Uegc)KDIdduKDy(Yr1MlwYgFwiNLKnMZ6SjFdutdeZzdeP2b(DGioqDnqECGrUKk6CwqXawxqxQ0DjmdefQbIbSUaQkotVmqDt24F8sOrE(sOiO5Gee0C8LGmzlv6Uegc)Kn(SqoljBmG1fqvXz6fYoXHbkYgZzuNzdcjiO5OrcYKTuP7syi8t2jomqr2V1Vv(uLCALkO6nSEYgFwiNLKTR371Db6PApaUZaCwKTvHCNN2GSDqccAoqhcYKTuP7syi8t2jomqr2UReRh4fu9gwpzJplKZsYgdyDbuvCMEzGioqDnqxV3R7c0t1EaC3t7arHAGrUKk6CwqXawxqxQ0DjmdeXbQ9KgO(yMUJEy(Yr1Ml2bI4aXC2aBh43bI4aXaWIb4S6ptfkk4rFE3F)e20k1a5DGnoquOgiMZ6SjFdutdeZzdK32b6yGioqTN0a1hZ0D0vATQSYNIVSeQEdRFG6MSX)4LqJ88LqrqZbjibzJzOk5KYIFcYe0CqqMSLkDxcdHFYgOLSvsq2jomqr2nKNLUlHSBixEczJbGfdWz1vYjLf)9tytRudK3b6yGOqnWN5Zf0tytRudK3b(TjYUH8OvYkKTsoPS4N66DQGee0(sqMSLkDxcdHFYgFwiNLKnpoWgYZs3L05algkFEsnquOg4Z85c6jSPvQbY7a)IEYoXHbkY2Qga6fkFEsrccAnsqMStCyGISF5AjffCmYr2sLUlHHWpjiOHoeKj7ehgOiBxqjmEQG6EItYwQ0Djme(jbbn0tqMStCyGISDkPwqPOGhfCmYr2sLUlHHWpjiOHUjit2sLUlHHWpzJplKZsY(z(Cb9e20k1arAGoAw0pquOgyd5zP7s6k5KYIFQR3PIbIc1aFMpxqpHnTsnqEhyJONStCyGIS99YJXYIcE0uZLdeCKGGwZGGmzlv6Uegc)Kn(Sqolj7gYZs3L0vYjLf)uxVtfKDIdduKTtWTyAqSIEIcuzHfsqqRzjit2sLUlHHWpzJplKZsYUH8S0DjDLCszXp117ubzN4Wafz7Uaagk4rdoHkLW(tccA8ucYKTuP7syi8t24Zc5SKS11aXaWIb4S6k5KYI)(jSPvQbIc1aXaWIb4S6yqHLkUmeg6BLSshZLNVOgy7a)oqDpqehipoqgq0XGclvCzim03kzfQR3v9tytRudeXbQRbIbGfdWz1ptzLpv5vu9gwF)e20k1arCGyayXaCw9NPcff8OpV7VFcBALAGOqnWN5Zf0tytRudK3b2Sdu3KDIdduKnguyPIldHH(wjRqccAoAIGmzN4WafzhCc1RCbEfd9boSq2sLUlHHWpjiO5WbbzYoXHbkYwR3zVFR8PURufKTuP7syi8tccAo(sqMSLkDxcdHFYgFwiNLKDKNVe9WyfAaOAXb9BtdePb2ytdefQbg55lrNtYvW11IJbYB7a)20arHAGrE(s0dJvObGYyYa5DGFj7ehgOi7tsTw5tFRKvuKGGMJgjit2jomqr2pa2tjm0uZLZcH6kjlzlv6Uegc)KGGMd0HGmzlv6Uegc)Kn(SqoljBPKZ)FG8oq0PjYoXHbkYMvyb3pf8OlpSXqzojzvKGGMd0tqMStCyGISptR2LqTIQ0MyHSLkDxcdHFsqqZb6MGmzlv6Uegc)Kn(Sqolj7N5Zf0tytRudePb64l6hikudSH8S0DjDLCszXp117ubzN4Wafz7Uaag6Z7(jbbnhndcYKTuP7syi8t24Zc5SKSFMpxqpHnTsnqKgOJMf9defQb2qEw6UKUsoPS4N66DQGStCyGISDLtjNER8jbbnhnlbzYwQ0Djme(jB8zHCws2yoRZM8nqnnqmNnqKAhOdYoXHbkYopCwcna3jvqccAo4PeKj7ehgOi7L5Zfkkp4X4Zkvq2sLUlHHWpjiO9TjcYKTuP7syi8t24Zc5SKSFMpxqpHnTsnqKgOJVOFGOqnWgYZs3L0vYjLf)uxVtfKDIdduK9ZoXDbamKGG2xheKjBPs3LWq4NSXNfYzjz)mFUGEcBALAGinqhFr)arHAGnKNLUlPRKtkl(PUENki7ehgOi7SWIkUCrX5ArccAF)sqMSLkDxcdHFYgFwiNLKDd5zP7s6k5KYIFQR3PcYoXHbkY2n9PGhnodRxrccAFBKGmzlv6Uegc)KDLSczNkUgYsu0l1CWrXGlxKDIdduKDQ4AilrrVuZbhfdUCrccAFrhcYKTuP7syi8t24Zc5SKSJ88LOZj5k46AXXa5TDGoqpzN4Wafzhapmhf8OmsgCKGG2x0tqMSTkKRHCr280MiBT4GYj5k4i7M6ONStCyGISdGhMJcEu95XMKTuP7syi8tccAFr3eKjBPs3LWq4NSXNfYzjzJbGfdWz1ptzLpv5vu9gwF)e20k1a5DGFhikud8z(Cb9e20k1a5DGoqpzN4WafzRKtkl(jbbTVndcYKDIdduKTB6tbpACgwVISLkDxcdHFsqcYwfeKjO5GGmzN4Wafz7KZULv(uMl9bfvRxH5iBPs3LWq4Nee0(sqMSLkDxcdHFYgFwiNLKnMZ6SjFdutdeZzdeP2b(DGioqPKZ)VhgRqdaLn5BGinWghikudeZzD2KVbQPbI5SbIu7arNbI4a11aLso))EyScnau2KVbI0a)oquOgipoqTN0a1hZ0D0dZxoQ2CXoqDt2jomqr2sjNVP5w5tLLXNDKGGwJeKjBPs3LWq4NSXNfYzjzJbSUaQkotVmqehOUgOR371zYcluWJI5mEW6EAhikud01796mzHfk4rXCgpy0uZLZcP7PDG6MStCyGISvATQSYNIVSeQEdRNee0qhcYKDIdduK9ZuHIcE0N39t2sLUlHHWpjiOHEcYKTuP7syi8t2jomqr2NPSYNQ8kQEdRNSXNfYzjzJbGfdWz1vYjLf)9tytRudePb6yGOqnqECGrUKk6k5KYI)UuP7syiB8pEj0ipFjue0CqccAOBcYKTuP7syi8t24Zc5SKSD9EV(5P4SYNYdjJqDAftNb4SgiIdmXH1GqLsynrnqKgOdYoXHbkY(8uCw5t5HKrOoTIHee0AgeKjBPs3LWq4NSXNfYzjzJ5SoBY3a10aXC2arQDGogOgduukPWshdQ3YWbnlgQko7jD2KhahzN4Wafzl8PvwuU8yjbbTMLGmzlv6Uegc)KDIdduK9Zubf8ObNqDYzHqdZxoYgFwiNLKnMZgiVdSrYg)JxcnYZxcfbnhKGGgpLGmzlv6Uegc)Kn(SqoljBmN1zt(gOMgiMZgisTd0bzN4WafzJ5mQR3PcsqqZrteKj7ehgOiBmNrDMniKTuP7syi8tccAoCqqMSLkDxcdHFYoXHbkYomF5OAZflzJplKZsYgdyDbuvCMEzGioqmN1zt(gOMgiMZgisTd87arCGUEVxxfGJLk5fC0SyOp7KodWzr24F8sOrE(sOiO5Gee0C8LGmzlv6Uegc)Kn(SqoljBxV3RJ5mQuY5)3vrI1pqKgyJnnqnnq0pWM7dmXH1GqLsynrnqehigW6cOQ4m9YarCGUEVxxfGJLk5fC0SyOp7KodWznqehOUgigawmaNv)mLv(uLxr1By99tytRudePb(DGioqmaSyaoR(ZuHIcE0N393pHnTsnqKg43bIc1aXaWIb4S6NPSYNQ8kQEdRVFcBALAG8oWghiIdedalgGZQ)mvOOGh95D)9tytRudePb24arCGyoBGinWghikudedalgGZQFMYkFQYRO6nS((jSPvQbI0aBCGioqmaSyaoR(ZuHIcE0N393pHnTsnqEhyJdeXbI5SbI0arNbIc1aXCwNn5BGAAGyoBG82oqhdeXbkLC()9WyfAaOSjFdK3b(DG6EGOqnqxV3RJ5mQuY5)3vrI1pqKgOJMgiId8z(Cb9e20k1a5DGndYoXHbkYwP1QYkFk(YsO6nSEsqqZrJeKjBPs3LWq4NStCyGISDxjwpWlO6nSEYgFwiNLKngW6cOQ4m9YarCG6AGrUKk6k5KYI)UuP7sygiIdedalgGZQRKtkl(7NWMwPgiVdSXbIc1aXaWIb4S6NPSYNQ8kQEdRVFcBALAGinqhdeXbIbGfdWz1FMkuuWJ(8U)(jSPvQbI0aDmquOgigawmaNv)mLv(uLxr1By99tytRudK3b24arCGyayXaCw9NPcff8OpV7VFcBALAGinWghiIdeZzdePb(DGOqnqmaSyaoR(zkR8PkVIQ3W67NWMwPgisdSXbI4aXaWIb4S6ptfkk4rFE3F)e20k1a5DGnoqehiMZgisdSXbIc1aXC2arAGOFGOqnqxV3R7c0t1EaC3t7a1nzJ)XlHg55lHIGMdsqqZb6qqMSLkDxcdHFYoXHbkYomF5OAZflzJplKZsYgdyDbuvCMEzGioqmN1zt(gOMgiMZgisTd8lzJ)XlHg55lHIGMdsqqZb6jit2wfYDEAdY2bzN4Wafz)w)w5tvYPvQGQ3W6jBPs3LWq4Nee0CGUjit2sLUlHHWpzN4Wafz7UsSEGxq1By9Kn(SqoljBmG1fqvXz6LbI4aXaWIb4S6ptfkk4rFE3F)e20k1a5DGnoqehiMZgy7a)oqehO2tAG6Jz6o6H5lhvBUyhiIduk58)7HXk0aqrFtdK3b6GSX)4LqJ88LqrqZbjiO5OzqqMSLkDxcdHFYoXHbkY2DLy9aVGQ3W6jB8zHCws2yaRlGQIZ0ldeXbkLC()9WyfAaOSjFdK3b(DGioqDnqmN1zt(gOMgiMZgiVTd0XarHAGApPbQpMP7OhMVCuT5IDG6MSX)4LqJ88LqrqZbjibzd0kLCeKjO5GGmzlv6Uegc)KDIdduK9Zubf8ObNqDYzHqdZxoYgFwiNLKnMZ6SjFdutdeZzdeP2b2izJ)XlHg5D(sOiBhKGG2xcYKTuP7syi8t24Zc5SKSJCjv0XCg117urxQ0DjmdeXbI5SoBY3a10aXC2arQDGns2jomqr2cFALfLlpwsqqRrcYKTuP7syi8t2jomqr2H5lhvBUyjB8zHCws2yaRlGQIZ0ldeXbI5SoBY3a10aXC2arQDGFjB8pEj0ipFjue0CqccAOdbzYoXHbkYw4tRSOC5Xs2sLUlHHWpjiOHEcYKTuP7syi8t2jomqr2H5lhvBUyjB8zHCws2yoRZM8nqnnqmNnqKAh4xYg)JxcnYZxcfbnhKGeKGSBqoLbkcAFB6BtoA6lpLSDMxzLVIS1SZQfCHWmWMDGjomqnWLPcvF(q2PxWboYEBSAgYw7bE2siBEEGnNwX4mx6LBGA2aL(5dppq0v4a4k3aBSjeg43M(208z(WZduZIpb7fcZaDLh4KbIbSUzmqxX3kvFG8eySOnudSaLM4YJ95TgyIdduQbcQ1FF(K4WaLQR9emG1ndnA15Tefh(YxmFsCyGs11EcgW6MHgT60qEw6UeeQKvA5ZtkkOOEkHgNv6LabG2wLei0qU8K2MMpjomqP6ApbdyDZqJwDWCg117ubc2RLhJCjv0vYjLf)DPs3LWGcfpg5sQO)mvqbpAWjuNCwi0W8LRlv6UeM5tIdduQU2tWaw3m0OvhmNrDMniiyVwEmYLurxk58nn3kFQSm(KRlv6UeM5Z8HNhOMfFc2leMbkni3)adJvgyWjdmXb4gOPgy2qAR0Dj95tIdduQwLwjpkxwmuvCMEz(WZdeD98S0Djdm4YyGoT1AGHSwd8h4nq7nWFG3aDAR1alrygyagOZ0IbgGbItvmqKb8K6WagybIb6mRyGbyG4ufd0IbMXaZ1AGz9Zcoz(K4WaLsJwDAiplDxccvYkTCGfdLppPqaOTvjbcnKlpPfdalgGZQBvda9cLppPObNqDYzHqdZxU(jSPvkKEMpxqpHnTsHc1Z85c6jSPvkED8TjeFMpxqpHnTsHegawmaNvxjNuw83pHnTsHigawmaNvxjNuw83pHnTsHKJMMp88aBMkzGAbHbQbAVbULtkl(hOPgONwegi4gOli4g4wZQ5hywmdezap5aZtgONwegi4gyWjdmYZxIb60wRbYyYaDAbNvdeD30avcgumQ5tIdduknA1rlimqHG9A1LR371vYjLf)DpTOq569EDvaowQKxWrZIH(St6EA1nIALOZNNu0GtOo5SqOH5lxpXH1GGc1Z85c6jSPvkEBr3nnF45bQzY1AGbNmWTCszX)atCyGAGltfd0EdClNuw8pqtnqS3DsfR)b6PD(K4WaLsJwDW5ArtCyGIUmvGqLSsRsoPS4hb71669EDLCszXF3t78HNh4aBMkzGnpiAorEG2BGd8h4nW8KbYAkLv(dmJbUKufdSXbI5megiprXmWFG3afl4KBG5jdmDbEXadWaXP2bkLC()imqWnqLCszX)an1atxGxmWamqmGvgONwegi4gyZdA(bAQbIbSw5pqpTdmlMb(d8gOtBTgio1oqPKZ)FGkaOMpjomqP0OvhCUw0ehgOOltfiujR0c0kLCiyV2WyfErpIyoJx0JipQvIoFEsrdoH6KZcHgMVC9ehwdY8jXHbkLgT68mvqbpAWjuNCwi0W8Ldb8pEj0ipFjuToqWETyoRZM8PjmNHuBJiQlPKZ)VhgRqdaLn5JxhOqjLC()9WyfAaOSjF8IoiIbGfdWz1FMkuuWJ(8U)(jSPvkED0rVUNpjomqP0OvhHpTYIYLhlc2RfZzD2KpnH5mKADOHOusHLoguVLHdAwmuvC2t6Sjpaoe1LuY5)3dJvObGYM8XRduOWaWIb4S6k5KYI)(jSPvkE)IcLuY5)3dJvObGYM8Xl6GigawmaNv)zQqrbp6Z7(7NWMwP41rh96E(K4WaLsJwDcZxoQ2CXIa(hVeAKNVeQwhiyVwmG1fqvXz6feXCwNn5ttyodP2ViQlPKZ)VhgRqdaLn5JxhOqHbGfdWz1vYjLf)9tytRu8(ffkPKZ)VhgRqdaLn5Jx0brmaSyaoR(ZuHIcE0N393pHnTsXRJo6198jXHbkLgT6GZ1IM4WafDzQaHkzLwmdvjpeSxlpg5sQORKtkl(7sLUlHz(K4WaLsJwDW5ArtCyGIUmvGqLSslMHQKtkl(rWETrUKk6k5KYI)UuP7syMp88a1m5AnWGtg4g5bM4Wa1axMkgO9gyWjNmW8Kb(DGGBGlrPgOucRjQ5tIdduknA1bNRfnXHbk6YubcvYkTQab71M4WAqOsjSMO4TX5dppqntUwdm4KbYta0SgyIddudCzQyG2BGbNCYaZtgyJdeCdKfCYaLsynrnFsCyGsPrRo4CTOjomqrxMkqOswPnbcc2RnXH1GqLsynrHuBJZN5dppqEcCyGs15jaAwd0ud0QqkgHzGpWnqpLmqNwWnq01eCyykpbddvZSKSbzGzXmqS3DsfR)bwIWOgyagORmqG2WynnxyMpjomqP6jqADYz3YkFkZL(GIQ1RWCiyVwxV3R7KZULv(uMl9bfvRxH56EANpjomqP6jq0OvhPKZ30CR8PYY4ZoeSxlMZ6SjFAcZzi1(frPKZ)VhgRqdaLn5dPVOqH5SoBYNMWCgsTOZ8jXHbkvpbIgT6O0AvzLpfFzju9gwpc2RfdyDbuvCMEbrD569EDMSWcf8OyoJhSUNwuOC9EVotwyHcEumNXdgn1C5Sq6EA198jXHbkvpbIgT68mvOOGh95D)iyVwPKZ)VhgRqdaLn5djHpb7fcnmwrtoqHcZzD2KpnH5mEBDGcLR371vb4yPsEbhnlg6ZoPFcBALA(K4WaLQNarJwDotzLpv5vu9gwpc4F8sOrE(sOADGG9A1vKlPIUto7ww5tzU0huuTEfMRlv6UegeXaWIb4S6NPSYNQ8kQEdRVZ4DzyGcjmaSyaoRUto7ww5tzU0huuTEfMRFcBALsd0r3iQlmaSyaoR(ZuHIcE0N393pHnTsHuJOqH5mKArVUNpjomqP6jq0OvNZtXzLpLhsgH60kgeSxRR371ppfNv(uEizeQtRy6maN18jXHbkvpbIgT6O0AvzLpfFzju9gwpc2RfdyDbuvCMEbrDPlmNHuJOqHbGfdWz1FMkuuWJ(8U)(jSPvkKq36grDH5mKArpkuyayXaCw9NPcff8OpV7VFcBALcPV6gfkPKZ)VhgRqdaLn5J32g198jXHbkvpbIgT6i8PvwuU8yrWETyoRZM8PjmNHuRdneLskS0XG6TmCqZIHQIZEsNn5bWnFsCyGs1tGOrRoptfuWJgCc1jNfcnmF5qa)JxcnYZxcvRdeSxlMZ6SjFAcZzi1248jXHbkvpbIgT6G5mQR3PceSxlMZ6SjFAcZzi1(D(K4WaLQNarJwDcZxoQ2CXIa(hVeAKNVeQwhiyVwmN1zt(0eMZqQ9lI6IhJCjv05SGIbSUGUuP7syqHcdyDbuvCMEr3ZNehgOu9eiA0QdMZOoZgeeSxlgW6cOQ4m9Y8jXHbkvpbIgT68w)w5tvYPvQGQ3W6rWETUEVx3fONQ9a4odWzHGvHCNN2O1X8jXHbkvpbIgT64UsSEGxq1By9iG)XlHg55lHQ1bc2RfdyDbuvCMEbrD569EDxGEQ2dG7EArHkYLurNZckgW6c6sLUlHbrTN0a1hZ0D0dZxoQ2CXIiMZA)IigawmaNv)zQqrbp6Z7(7NWMwP4TruOWCwNn5ttyoJ3whiQ9KgO(yMUJUsRvLv(u8LLq1By96E(mF45bUdWXIWa1SYl4qyGzXmWM3ozGAgayXaCwQ5tIdduQoMHQKxRvna0lu(8KIgCc1jNfcnmF5qWET8yd5zP7s6CGfdLppPqH6z(Cb9e20kfVFr)8jXHbkvhZqvYtJwDE5AjffCmYnFsCyGs1XmuL80OvhxqjmEQG6EIZ5tIdduQoMHQKNgT64usTGsrbpk4yKB(WZdSzQKbYtC4SKbIm4oPIbAVb(d8gyEYaznLYk)bMXaxsQIb6yGAgoB(K4WaLQJzOk5PrRo5HZsOb4oPceSxlMZ6SjFAcZzi16y(K4WaLQJzOk5PrRobWdZrbpkJKbhc2RnYZxIoNKRGRRfh826a9i669EDvaowQKxWrZIH(St6maN18jXHbkvhZqvYtJwDCxaadf8ObNqLsy)rWETyayXaCw9NPcff8OpV7VFcBALI3VOq9mFUGEcBALIxhFNpjomqP6ygQsEA0QJVxEmwwuWJMAUCGGB(K4WaLQJzOk5PrRoob3IPbXk6jkqLfwMpjomqP6ygQsEA0QdguyPIldHH(wjRGG9A5rgq0XGclvCzim03kzfQR3v9tytRuiQlDXJrUKk6o5SBzLpL5sFqr16vyUUuP7syqHcdalgGZQ7KZULv(uMl9bfvRxH56NWMwP0nIyayXaCw9Zuw5tvEfvVH13pHnTsHigawmaNv)zQqrbp6Z7(7NWMwPq01796QaCSujVGJMfd9zN0zaolDJc1Z85c6jSPvkEB25tIdduQoMHQKNgT6eCc1RCbEfd9boSmFsCyGs1XmuL80OvhTEN9(TYN6UsvmFsCyGs1XmuL80OvNtsTw5tFRKvuiyV2ipFj6HXk0aq1Id63MqQXMqHkYZxIoNKRGRRfh82(TP5tIdduQoMHQKNgT68aypLWqtnxoleQRKSZNehgOuDmdvjpnA1Hvyb3pf8OlpSXqzojzviyVwPKZ)Nx0PP5tIdduQoMHQKNgT6CMwTlHAfvPnXY8jXHbkvhZqvYtJwDub4yPsEbhnlg6Zobb71IbGfdWz1vb4yPsEbhnlg6ZoPJ5YZxuTFrH6z(Cb9e20kfVFBcfkxV3RRej4SYNEPV090IcLUWaWIb4S6UlaGHcE0GtOsjS)9tytRuA4ajmaSyaoRUkahlvYl4OzXqF2j9N3ArpbZLNVqdJvqHIhfLskS0Dxaadf8ObNqLsy)7SjpaoDJigawmaNv)zQqrbp6Z7(7NWMwP41rtiI5mKA)IigawmaNv3jNDlR8Pmx6dkQwVcZ1pHnTsXRJVZNehgOuDmdvjpnA1XtjuleweQKvAtfxdzjk6LAo4OyWLR5tIdduQoMHQKNgT6eapmhf8O6ZJnrWQqUgYvlpTje0IdkNKRGRTPo6Np88aBMkzG8VaaMb28E3)aT3arg4H5gi4nqEsjdUMBvdedalgGZAGMAG(NKHCdm4YAGn20a1vWzQbAfE5XiQb6KZwYargWtoqtnqS3DsfR)bM4WAq0ncdeCde8EdedalgGZAGo5KAG)aVbMNmqoWIXk)bcQamqKb8KimqWnqNCsnWGtgyKNVed0udmDbEXadWazmz(K4WaLQJzOk5PrRoUlaGH(8UFeSx7Z85c6jSPvkKC8f9Oq569EDvaowQKxWrZIH(St6EArH6z(Cb9e20kfVFBA(K4WaLQJzOk5PrRoUYPKtVv(iyV2N5Zf0tytRui5OzrpkuUEVxxfGJLk5fC0SyOp7KUNwuOEMpxqpHnTsX73MMpjomqP6ygQsEA0QZY85cfLh8y8zLkMpjomqP6ygQsEA0QZZoXDbamiyV2N5Zf0tytRui54l6rHY1796QaCSujVGJMfd9zN090Ic1Z85c6jSPvkE)208jXHbkvhZqvYtJwDYclQ4YffNRfc2R9z(Cb9e20kfsoAw0JcLR371vb4yPsEbhnlg6ZoP7PffQN5Zf0tytRu8(TPehgOuDmdvjpnA1Xn9PGhnodRxHG9AD9EVUkahlvYl4OzXqF2jDgGZA(mF45bULtkl(hOMbawmaNLA(K4WaLQJzOk5KYI)2gYZs3LGqLSsRsoPS4N66DQabG2wLei0qU8KwmaSyaoRUsoPS4VFcBALIxhOq9mFUGEcBALI3VnnFsCyGs1XmuLCszXVgT6yvda9cLppPObNqDYzHqdZxoeSxlp2qEw6UKohyXq5ZtkuOEMpxqpHnTsX7x0pFsCyGs1XmuLCszXVgT68Y1skk4yKB(K4WaLQJzOk5KYIFnA1XfucJNkOUN4C(K4WaLQJzOk5KYIFnA1XPKAbLIcEuWXi38jXHbkvhZqvYjLf)A0QJVxEmwwuWJMAUCGGdb71(mFUGEcBALcjhnl6rHQH8S0DjDLCszXp117ubkupZNlONWMwP4Tr0pFsCyGs1XmuLCszXVgT64eClMgeRONOavwybb712qEw6UKUsoPS4N66DQy(K4WaLQJzOk5KYIFnA1XDbamuWJgCcvkH9hb712qEw6UKUsoPS4N66DQy(K4WaLQJzOk5KYIFnA1bdkSuXLHWqFRKvqWET6cdalgGZQRKtkl(7NWMwPqHcdalgGZQJbfwQ4YqyOVvYkDmxE(IQ9RUrKhzarhdkSuXLHWqFRKvOUEx1pHnTsHOUWaWIb4S6NPSYNQ8kQEdRVFcBALcrmaSyaoR(ZuHIcE0N393pHnTsHc1Z85c6jSPvkEBwDpFsCyGs1XmuLCszXVgT6eCc1RCbEfd9boSmFsCyGs1XmuLCszXVgT6O17S3Vv(u3vQI5tIdduQoMHQKtkl(1OvNtsTw5tFRKvuiyV2ipFj6HXk0aq1Id63MqQXMqHkYZxIoNKRGRRfh82(TjuOI88LOhgRqdaLXeE)oFsCyGs1XmuLCszXVgT68aypLWqtnxoleQRKSZNehgOuDmdvjNuw8RrRoScl4(PGhD5HngkZjjRcb71kLC()8IonnFsCyGs1XmuLCszXVgT6CMwTlHAfvPnXY8jXHbkvhZqvYjLf)A0QJ7cayOpV7hb71(mFUGEcBALcjhFrpkunKNLUlPRKtkl(PUENkMpjomqP6ygQsoPS4xJwDCLtjNER8rWETpZNlONWMwPqYrZIEuOAiplDxsxjNuw8tD9ovmFsCyGs1XmuLCszXVgT6KholHgG7KkqWETyoRZM8PjmNHuRJ5tIdduQoMHQKtkl(1OvNL5Zfkkp4X4ZkvmFsCyGs1XmuLCszXVgT68StCxaadc2R9z(Cb9e20kfso(IEuOAiplDxsxjNuw8tD9ovmFsCyGs1XmuLCszXVgT6KfwuXLlkoxleSx7Z85c6jSPvkKC8f9Oq1qEw6UKUsoPS4N66DQy(K4WaLQJzOk5KYIFnA1Xn9PGhnodRxHG9ABiplDxsxjNuw8tD9ovmFsCyGs1XmuLCszXVgT64PeQfclcvYkTPIRHSef9snhCum4Y18jXHbkvhZqvYjLf)A0Qta8WCuWJYizWHG9AJ88LOZj5k46AXbVToq)8jXHbkvhZqvYjLf)A0Qta8WCuWJQpp2ebRc5AixT80MqqloOCsUcU2M6OF(K4WaLQJzOk5KYIFnA1rjNuw8JG9AXaWIb4S6NPSYNQ8kQEdRVFcBALI3VOq9mFUGEcBALIxhOF(K4WaLQJzOk5KYIFnA1Xn9PGhnodRxnFMp88arxPvk5MpjomqP6aTsjx7Zubf8ObNqDYzHqdZxoeW)4LqJ8oFjuToqWETyoRZM8PjmNHuBJZNehgOuDGwPKtJwDe(0klkxESiyV2ixsfDmNrD9ov0LkDxcdIyoRZM8PjmNHuBJZNehgOuDGwPKtJwDcZxoQ2CXIa(hVeAKNVeQwhiyVwmG1fqvXz6feXCwNn5ttyodP2VZNehgOuDGwPKtJwDe(0klkxESZNehgOuDGwPKtJwDcZxoQ2CXIa(hVeAKNVeQwhiyVwmN1zt(0eMZqQ978z(WZdS54mWzX)aBo5SLmWTCszX)a1SRgyZu78jXHbkvxjNuw83(mvOOGh95D)iyVwxV3RRKtkl(7NWMwP41bkujoSgeQucRjkKCmFsCyGs1vYjLf)A0QJsRvLv(u8LLq1By9iyVwmG1fqvXz6fe1vIdRbHkLWAIcPVOqL4WAqOsjSMOqYbI8igawmaNv)mLv(uLxr1By9DpT6E(K4WaLQRKtkl(1OvNZuw5tvEfvVH1Ja(hVeAKNVeQwhiyVwmG1fqvXz6L5tIdduQUsoPS4xJwDuATQSYNIVSeQEdRhb71IbSUaQkotVGOUC9EVotwyHcEumNXdw3tlkuUEVxNjlSqbpkMZ4bJMAUCwiDpT6E(WZdezotnqN2AnqCQIb28GMFGzXmqRc5opTXadozGyUSkznq7nWGtgyZnAgEYbAQbEsY8pWSygOcWkbNv(dKZ85KBGGAGbNmqTNbol(h4YuXa1vZ1gDr3d0udmBin3LmFsCyGs1vYjLf)A0QZZuHIcE0N39JGvHCNN2GAVwFmt)e20kvBtZNehgOuDLCszXVgT68mvqbpAWjuNCwi0W8Ldb8pEj0ipFjuToqWETyoJ3gNp88aBMkzG8dqxqyGwmqN2AnqqT(hO7jP(bYMQqU)bAVbIUMfduZayDbd0uden0vipWixsfcZ8jXHbkvxjNuw8RrRoUReRh4fu9gwpc4F8sOrE(sOADGG9AXawxavfNPxqHIhJCjv05SGIbSUGUuP7syMpjomqP6k5KYIFnA1rP1QYkFk(YsO6nS(5Z8HNh42k)LmWipFjgyZXzGZI)5tIdduQUkADYz3YkFkZL(GIQ1RWCZNehgOuDvOrRosjNVP5w5tLLXNDiyVwmN1zt(0eMZqQ9lIsjN)FpmwHgakBYhsnIcfMZ6SjFAcZzi1IoiQlPKZ)VhgRqdaLn5dPVOqXJApPbQpMP7OhMVCuT5Iv3ZNehgOuDvOrRokTwvw5tXxwcvVH1JG9AXawxavfNPxquxUEVxNjlSqbpkMZ4bR7PffkxV3RZKfwOGhfZz8GrtnxolKUNwDpFsCyGs1vHgT68mvOOGh95D)ZhEEGntLmWMRn6Yab1aJ88LqnqNwWb8IbQzlp9de8gyWjduZCzjdKrC9EpegO9gOwGszUlbHbMfZaT3a3YjLf)d0udmJbUKufd87avcgumQbMoZ)5tIdduQUk0OvNZuw5tvEfvVH1Ja(hVeAKNVeQwhiyVwmaSyaoRUsoPS4VFcBALcjhOqXJrUKk6k5KYI)UuP7syMpjomqP6QqJwDopfNv(uEizeQtRyqWETUEVx)8uCw5t5HKrOoTIPZaCwiM4WAqOsjSMOqYX8jXHbkvxfA0QJWNwzr5YJfb71I5SoBYNMWCgsTo0qukPWshdQ3YWbnlgQko7jD2Kha38jXHbkvxfA0QZZubf8ObNqDYzHqdZxoeW)4LqJ88Lq16ab71I5mEBC(WZdSzQKbQz4FG2BG)aVbMNmqwWjdm4YAGnnqndNnW0z(pW3byhiBY3aZIzGCzdYaDmqPe2Fegi4gyEYazbNmWGlRb6yGAgoBGPZ8FGVdWoq2KV5tIdduQUk0OvhmNrD9ovGG9AXCwNn5ttyodPwhZNehgOuDvOrRoyoJ6mBqMp88aBMkzGi3Cmq7nWFG3aZtgi6mqWnqwWjdeZzdmDM)d8Da2bYM8nWSygiYaEYbMfZa3Awn)aZtgOli4gybIb6PD(K4WaLQRcnA1jmF5OAZflc4F8sOrE(sOADGG9AXawxavfNPxqeZzD2KpnH5mKA)IOR371vb4yPsEbhnlg6ZoPZaCwZNehgOuDvOrRokTwvw5tXxwcvVH1JG9AD9EVoMZOsjN)Fxfjwpsn2KMqFZ9ehwdcvkH1efIyaRlGQIZ0li669EDvaowQKxWrZIH(St6maNfI6cdalgGZQFMYkFQYRO6nS((jSPvkK(IigawmaNv)zQqrbp6Z7(7NWMwPq6lkuyayXaCw9Zuw5tvEfvVH13pHnTsXBJiIbGfdWz1FMkuuWJ(8U)(jSPvkKAermNHuJOqHbGfdWz1ptzLpv5vu9gwF)e20kfsnIigawmaNv)zQqrbp6Z7(7NWMwP4TreXCgsOdkuyoRZM8PjmNXBRdeLso))EyScnau2KpE)QBuOC9EVoMZOsjN)FxfjwpsoAcXN5Zf0tytRu82mMp88aBMkzG8dqxgO9gOli4gyZdA(bMfZaBU2OldmpzGfigiEbuccdeCdS5AJUmqtnq8cOKbMfZaBEqZpqtnWcedeVakzGzXmWFG3a5YgKbYcozGbxwd87aXCgcdeCdS5bn)an1aXlGsgyZ1gDzGMAGfigiEbuYaZIzG)aVbYLnidKfCYadUSgyJdeZzimqWnWFG3a5YgKbYcozGbxwde9deZzimqWnq7nWFG3a9LyG5a1Ea88jXHbkvxfA0QJ7kX6bEbvVH1Ja(hVeAKNVeQwhiyVwmG1fqvXz6fe1vKlPIUsoPS4Vlv6UegeXaWIb4S6k5KYI)(jSPvkEBefkmaSyaoR(zkR8PkVIQ3W67NWMwPqYbIyayXaCw9NPcff8OpV7VFcBALcjhOqHbGfdWz1ptzLpv5vu9gwF)e20kfVnIigawmaNv)zQqrbp6Z7(7NWMwPqQreXCgsFrHcdalgGZQFMYkFQYRO6nS((jSPvkKAermaSyaoR(ZuHIcE0N393pHnTsXBJiI5mKAefkmNHe6rHY1796Ua9uTha390Q75tIdduQUk0OvNW8LJQnxSiG)XlHg55lHQ1bc2RfdyDbuvCMEbrmN1zt(0eMZqQ978HNhyZujdS53OldmlMbAvi35PngOfdufxA(CXatN5)8jXHbkvxfA0QZB9BLpvjNwPcQEdRhbRc5opTrRJ5dppWMPsgi)a0LbAVb28GMFGMAG4fqjdmlMb(d8gix2GmWVdeZzdmlMb(d8UbUsvmq)fWnxd0zQgiYnhimqWnq7nWFG3aZtgy6c8IbgGbItTduk58)hywmduSGtUb(d8UbUsvmqFmZaDMQbICZXab3aT3a)bEdmpzGlrPgyWL1a)oqmNnW0z(pW3byhio1Q1k)5tIdduQUk0Ovh3vI1d8cQEdRhb8pEj0ipFjuToqWETyaRlGQIZ0liIbGfdWz1FMkuuWJ(8U)(jSPvkEBermN1(frTN0a1hZ0D0dZxoQ2CXIOuY5)3dJvObGI(M41X8jXHbkvxfA0QJ7kX6bEbvVH1Ja(hVeAKNVeQwhiyVwmG1fqvXz6feLso))EyScnau2KpE)IOUWCwNn5ttyoJ3whOqP9KgO(yMUJEy(Yr1MlwDtcsqia]] )

end