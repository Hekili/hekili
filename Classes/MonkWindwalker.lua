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
    
    spec:RegisterPack( "Windwalker", 20201213, [[duuSgcqiQu5rqsk2KcmkueNcsQvbjP6vuiZcf1TqrAxu1VOqnmvKogvYYGuEMkIPrLcxJkL2gKK8nQuuJJkv15GKW8iG7Pq7tbDqijL0cPGEiKKsmrQue5IuPiyJuPiPtsLIeRKa9sijLQBsLIq7es1qPsrupvLMkf4QqskLVsLIu7fQ)QQbtPdlzXuXJbnzP6YiBgIplLgnfDAsRMkv51e0Sv0TrPDl63knCcz5apNOPlCDPy7qIVJcJxf15juRhsIMVkSFun2f2a8TxbHrhTtr7uxO56eVRtC5YLBX3qSicFfvqHvlHVzXs4RBAn7mQPqcGVIkXZT6ydWx52aGe(IVon6mCtjXo4BVccJoANI2PUqZ1jExN4YLl0WxPicIrhnufQaFn1ENsSd(2jjeFr1WTUP1SZOMcja36M4Mc5cIQHBDtIGeRdb4wxNWm3I2PODk(ovziXgGVRikja2am6UWgGVuwotQJneFlyOBIViQm(f5dt6zyQb9H2sa8fc0GaAHVqt1ZwN5wMYTqtLBhoYTNGVqXWj9rbaTuiXxx4aJoAydWxklNj1XgIVqGgeql8nQjLHhAQVtdqgEklNj152bCl0u9S1zULPCl0u52HJC7j4BbdDt8LolIMVzbyXbg9tWgGVuwotQJneFlyOBIVH2sGxunzXxiqdcOf(cxwN9LbqfsC7aUfAQE26m3YuUfAQC7WrUfn8fkgoPpkqlfsm6UWbgD3aBa(sz5mPo2q8fc0GaAHVqt1ZwN5wMYTqtLBh5w0W3cg6M4l0uFgfkeoWO7wSb4BbdDt8LolIMVzbyXxklNj1XgIdm6OkSb4lLLZK6ydX3cg6M4BOTe4fvtw8fc0GaAHVqt1ZwN5wMYTqtLBhoYTOHVqXWj9rbAPqIr3foWb(YGkrBk)f5xqNaydWO7cBa(sz5mPo2q8fc0GaAHVUJBJAsz4LeGsne7PSCMuhFlyOBIVWAo)cg6M)uLb(ovz8zXs4lS)scbhy0rdBa(sz5mPo2q8fc0GaAHVrnPm8scqPgI9uwotQJVfm0nXxynNFbdDZFQYaFNQm(Syj8f2FjbOudX4aJ(jydWxklNj1XgIVqGgeql8fAQE26m3YuUfAQC7WrUfnUDa3sjbAf7dLL(yF26m3oKBpbFlyOBIVusGwfvQz7tt9ScWbgD3aBa(sz5mPo2q8TGHUj(cuPMTVSjFHkui(cfdN0hfOLcjgDx4aJUBXgGVuwotQJneFHaniGw4lt4w3XTrnPm8MA8WL1z9uwotQZTd4w4M9gn8WAcBMvq9xgavij9uwotQZThhClCzD2xgaviXTOMBhWTonii(ELq6xKhAQUN6BeHVfm0nXxPintnBFiOs6fQqH4aJoQcBa(sz5mPo2q8fc0GaAHVfmuuONsIvjj3oCKBrJBhWToniiEgujAt5Vi)c6e4zWWdi2stj3ka36cFlyOBIViQmK)I8inaX4aJUBgBa(sz5mPo2q8fc0GaAHVfmuuONsIvjj3oCKBrdFlyOBIVmmvWuZ2VdQ2nFrnj0ehy0DFSb4lLLZK6ydXxiqdcOf(YeU1DCButkdVPgpCzDwpLLZK6C7aUfUzVrdpSMWMzfu)LbqfsspLLZK6C7Xb3cxwN9LbqfsClQ52bCBbdff6PKyvsYTdh52t42bCRtdcINbvI2u(lYVGobEgm8nIW3cg6M4RuKMPMTpeuj9cvOqCGrhvGnaFPSCMuhBi(wWq3eFDMfu42eVqfkeFHaniGw4lCzD2xgaviXTd42cgkk0tjXQKKBfyKBrdFHIHt6Jc0sHeJUlCGr31PydW3cg6M4ldtfm1S97GQDZxutcnXxklNj1XgIdm6UCHnaFPSCMuhBi(cbAqaTWxNgeeVmwa7tfim)k7pIciFJiUDa3ckT)ekug(Q3LEn52HClC3zFzKEevgYFrEKgGyFVbuHUj3IQZTN6rv4BbdDt8frLH8xKhPbigF1miaOru8kc(60GG4zqLOnL)I8lOtGNbdFJiCGr3fAydWxklNj1XgIVqGgeql81PbbXdn1Nsc0k2lJckKBhYTNCk3YuU1TClQo3wWqrHEkjwLK4BbdDt8vksZuZ2hcQKEHkuioWO76eSb4lLLZK6ydX3cg6M4lIkJFr(WKEgMAqFOTeaFHaniGw4l0u5wb42tWxOy4K(OaTuiXO7chy0D5gydWxklNj1XgIVqGgeql8fAQE26m3YuUfAQC7WrU1f(wWq3eFPZIO5BwawCGr3LBXgGVuwotQJneFHaniGw4l0u9S1zULPCl0u52HJClt4wxCRrCBbdff6PKyvsYTd5wxClQX3cg6M4l0uFNgGmWbgDxOkSb4lLLZK6ydX3cg6M4BOTe4fvtw8fc0GaAHVmHBDh3g1KYWBQXdxwN1tz5mPo3ECWTWL1zFzauHe3IAUDa3cnvpBDMBzk3cnvUD4i3Ig(cfdN0hfOLcjgDx4aJUl3m2a8TGHUj(cn1NrHcHVuwotQJnehy0D5(ydWxklNj1XgIVfm0nXxNzbfUnXluHcXxiqdcOf(cnvUD4i3Ec3ECWToniiEgujAt5Vi)c6e4zWW3icFHIHt6Jc0sHeJUlCGr3fQaBa(QzqaqJOaFDHVfm0nXxKPynBFjberz8cvOq8LYYzsDSH4ah4RKauQHySby0DHnaFPSCMuhBi(cbAqaTWxNgeeVKauQHypGylnLCRaCRl8TGHUj(IOYq(lYJ0aeJdm6OHnaFPSCMuhBi(MflHVL0eLkj5dku5cE4cQj(wWq3eFlPjkvsYhuOYf8WfutCGr)eSb4lLLZK6ydXxiqdcOf(YeU1DCButkdVPgpCzDwpLLZK6C7aUfUzVrdpSMWMzfu)LbqfsspLLZK6C7Xb3cxwN9LbqfsClQ52bClt42cgkk0tjXQKKBhoYTNWThhCBbdff6PKyvsYTd5wxC7aU1DClC3zFzKEGk1S9Ln5luHc9nI4wuJVfm0nXxPintnBFiOs6fQqH4aJUBGnaFPSCMuhBi(wWq3eFbQuZ2x2KVqfkeFHaniGw4lCzD2xgaviHVqXWj9rbAPqIr3foWO7wSb4lLLZK6ydXxiqdcOf(wWqrHEkjwLKC7WrU9e8TGHUj(IOYq(lYJ0aeJdm6OkSb4lLLZK6ydXxiqdcOf(YeU1DCButkdVPgpCzDwpLLZK6C7aUfUzVrdpSMWMzfu)LbqfsspLLZK6C7Xb3cxwN9LbqfsClQ52bCRtdcIVxjK(f5HMQ7P(gr4BbdDt8vksZuZ2hcQKEHkuioWO7MXgGVuwotQJneFlyOBIVoZckCBIxOcfIVqGgeql8LjClCzD2xgaviXThhCR742OMugEtnE4Y6SEklNj15wuZTd4wNgeepdQeTP8xKFbDc8my4BeXTd4w4UZ(Yi9avQz7lBYxOcf6beBPPKBhYTOHVqXWj9rbAPqIr3foWO7(ydWxndcaAef4Rl8TGHUj(IOY4xKpmPNHPg0hAlbWxklNj1XgIdm6OcSb4lLLZK6ydXxiqdcOf(YeU1DCButkdVPgpCzDwpLLZK6C7aUfUzVrdpSMWMzfu)LbqfsspLLZK6C7Xb3cxwN9LbqfsClQ52bCBNCAqq8oBs9gz8oaIHVre(wWq3eFLI0m1S9HGkPxOcfIdm6UofBa(sz5mPo2q8TGHUj(IOY4xKpmPNHPg0hAlbWxiqdcOf(cnvUvaU9e8fkgoPpkqlfsm6UWbgDxUWgGVuwotQJneFlyOBIVoZckCBIxOcfIVqGgeql8fUSo7ldGkK42JdU1DCButkdVPgpCzDwpLLZK64lumCsFuGwkKy0DHdm6UqdBa(wWq3eFLI0m1S9HGkPxOcfIVuwotQJneh4aFH9xsak1qm2am6UWgGVuwotQJneFxr4RKc8TGHUj(Isb0Yzs4lk1SHWx4UZ(Yi9scqPgI9aIT0uYTcWTU42JdUvef(Znu(Hj9mm1G(qBjGVGHIcXTd4w4UZ(Yi9scqPgI9aIT0uYTd52toLBpo4weT1mEaXwAk5wb4w0ofFrPaFwSe(kjaLAi(DAaYahy0rdBa(sz5mPo2q8fc0GaAHVUJBrPaA5mjV5o7)5gk52JdUfrBnJhqSLMsUvaUfn3IVfm0nXxnrzfs)5gkXbg9tWgGVuwotQJneFZILW3sAIsLK8bfQCbpCb1eFlyOBIVL0eLkj5dku5cE4cQjoWO7gydW3cg6M4BJKEniwj(sz5mPo2qCGr3TydWxklNj1XgIVqGgeql8fLcOLZK8scqPgIFNgGmW3cg6M4RZC3(J0aeJdm6OkSb4lLLZK6ydXxiqdcOf(Isb0YzsEjbOudXVtdqg4BbdDt81HasciuZwCGr3nJnaFPSCMuhBi(cbAqaTWxeT1mEaXwAk52HCRl33TC7Xb3Isb0YzsEjbOudXVtdqgC7Xb3IOTMXdi2stj3ka3EIBX3cg6M4BBtb6AL)I8fQKaByIdm6Up2a8LYYzsDSH4leObb0cFrPaA5mjVKauQH43Pbid8TGHUj(YybZokKMpGKBwjKWbgDub2a8LYYzsDSH4leObb0cFrPaA5mjVKauQH43Pbid8TGHUj(6m3T)lYhM0tjXkghy0DDk2a8LYYzsDSH4leObb0cFzc3c3D2xgPxsak1qShqSLMsU94GBH7o7lJ0d3eszaQG6pYSyjp0SaTKKBh5w04wuZTd4w3XT9n8WnHugGkO(Jmlw6DAaPhqSLMsUDa3YeUfU7SVmspqLA2(YM8fQqHEaXwAk52bClC3zFzKEevgYFrEKgGypGylnLC7Xb3IOTMXdi2stj3ka36(ClQX3cg6M4lCtiLbOcQ)iZILWbgDxUWgGVfm0nX3WK(M0zBY(JSaiHVuwotQJnehy0DHg2a8TGHUj(kQbOiI1S9DMLmWxklNj1XgIdm6UobBa(sz5mPo2q8fc0GaAHVrbAPWhkl9X(IGXJ2PC7qU9Kt52JdUnkqlfEtQMHPxem4wbg5w0oLBpo42OaTu4dLL(y)UsCRaClA4BbdDt8fqLinBFKzXssCGr3LBGnaFlyOBIVilSrs9VqLeqd6DOIfFPSCMuhBioWO7YTydWxklNj1XgIVqGgeql8Lsc0kMBfGBDJtX3cg6M4llXUaX)I8ZgO2)oGkwjoWO7cvHnaFlyOBIVavKOj9A(srfKWxklNj1XgIdm6UCZydWxklNj1XgIVqGgeql8fAQE26m3YuUfAQC7WrU1f(wWq3eFlaSs6JfaOmWbgDxUp2a8TGHUj(o1wZq(UxtVLLYaFPSCMuhBioWO7cvGnaFPSCMuhBi(cbAqaTWxukGwotYljaLAi(DAaYaFlyOBIVikGCM72XbgD0ofBa(sz5mPo2q8fc0GaAHVOuaTCMKxsak1q870aKb(wWq3eFResYauZhwZjoWOJMlSb4lLLZK6ydXxiqdcOf(Isb0YzsEjbOudXVtdqg4BbdDt81PA)f5dGcfkXbgD0qdBa(sz5mPo2q8fc0GaAHViARz8aIT0uYTd5wxU)PC7Xb3kIc)5gk)WKEgMAqFOTeWxWqrH42JdUfrBnJhqSLMsUvaU11P4BbdDt8n2gO5ViFNQWehy0r7eSb4lLLZK6ydXxiqdcOf(IOTMXdi2stj3oKBrfNYThhCRik8NBO8dt6zyQb9H2saFbdffIBpo4weT1mEaXwAk5wb4wxNIVfm0nX3yBGM)I8claBHdm6O5gydWxklNj1XgIVqGgeql8fU7SVmspqLA2(YM8fQqHEaXwAk5wb4w6mbBc6dLLW3cg6M4ldQeTP8xKFbDcGdm6O5wSb4BbdDt8fPOPM0lJLve(sz5mPo2qCGrhnuf2a8TGHUj(IuZjL)c6eaFPSCMuhBioWOJMBgBa(wWq3eFD2K6nY4Daed8LYYzsDSH4aJoAUp2a8LYYzsDSH4leObb0cFH7o7lJ0duPMTVSjFHkuOhqSLMsUvaUfnU94GBr0wZ4beBPPKBfGBD5w8TGHUj(kjaLAighy0rdvGnaFlyOBIVov7ViFauOqj(sz5mPo2qCGd8vgydWO7cBa(sz5mPo2q8fc0GaAHVGs7pHcLHV6DPxtUDi3c3D2xgPNHPcMA2(Dq1U5lQjHM(EdOcDtUfvNBp17(C7Xb3ckT)ekug(Q3L(gr4BbdDt8LHPcMA2(Dq1U5lQjHM4aJoAydWxklNj1XgIVqGgeql8fAQE26m3YuUfAQC7WrUfnUDa3sjbAf7dLL(yF26m3oKBpHBpo4wOP6zRZClt5wOPYTdh5w3GBhWTmHBPKaTI9HYsFSpBDMBhYTOXThhCR74wracLVf29U8H2sGxunz5wuJVfm0nXxkjqRIk1S9PPEwb4aJ(jydWxklNj1XgIVqGgeql8LjCR742OMugEtnE4Y6SEklNj152bClCZEJgEynHnZkO(ldGkKKEklNj152JdUfUSo7ldGkK4wuZTd4wNgeeFVsi9lYdnv3t9nI42bClt4wqP9NqHYWx9U0Rj3oKBDAqq89kH0Vip0uDp1di2stj3YuUfnU94GBbL2FcfkdF17sFJiUf14BbdDt8vksZuZ2hcQKEHkuioWO7gydWxklNj1XgIVfm0nXxGk1S9Ln5luHcXxiqdcOf(c3D2xgPxsak1qShqSLMsUDi36IBpo4w3XTrnPm8scqPgI9uwotQJVqXWj9rbAPqIr3foWO7wSb4lLLZK6ydXxiqdcOf(YeUfuA)juOm8vVl9AYTd5w4UZ(Yi9iQmK)I8inaX(EdOcDtUfvNBp17(C7Xb3ckT)ekug(Q3L(grClQ52bClt4wkjqRyFOS0h7ZwN52HClDMGnb9HYsClt5wxC7Xb3cnvpBDMBzk3cnvUvGrU1f3ECWToniiEzSa2Nkqy(v2FefqEaXwAk5wb4w6mbBc6dLL4wJ4wxClQ52JdUfrBnJhqSLMsUvaULotWMG(qzjU1iU1f(wWq3eFruzi)f5rAaIXbgDuf2a8LYYzsDSH4leObb0cFDAqq8Hj9eRicSa5dlrfuJf4LrbfYTd5wxOcUDa3sjbAf7dLL(yF26m3oKBPZeSjOpuwIBzk36IBhWTWDN9Lr6bQuZ2x2KVqfk0di2stj3oKBPZeSjOpuwIBpo4wNgeeFyspXkIalq(Wsub1ybEzuqHC7qU1LBWTd4wMWTWDN9Lr6LeGsne7beBPPKBfGBDl3oGBJAsz4LeGsne7PSCMuNBpo4w4UZ(Yi9mOs0MYFr(f0jGhqSLMsUvaU1TC7aUfUOqzLHxOyGwj3ECWTiARz8aIT0uYTcWTULBrn(wWq3eFHGckCQz77EvN(P2AgPMT4aJUBgBa(sz5mPo2q8fc0GaAHVoniiEqJ0uZ239Qo9m0S77lJKBhWTfmuuONsIvjj3oKBDHVfm0nXxqJ0uZ239Qo9m0SJdm6Up2a8LYYzsDSH4BbdDt8frLXViFyspdtnOp0wcGVqGgeql8fAQCRaC7j4lumCsFuGwkKy0DHdm6OcSb4lLLZK6ydXxiqdcOf(cnvpBDMBzk3cnvUD4i36cFlyOBIV0zr08nlaloWO76uSb4lLLZK6ydXxiqdcOf(cnvpBDMBzk3cnvUD4i36IBhWTfmuuONsIvjj3oYTU42bClO0(tOqz4REx61KBhYTODk3ECWTqt1ZwN5wMYTqtLBhoYTOXTd42cgkk0tjXQKKBhoYTOHVfm0nXxOP(onazGdm6UCHnaFlyOBIVqt9zuOq4lLLZK6ydXbgDxOHnaFPSCMuhBi(wWq3eFdTLaVOAYIVqGgeql8fUSo7ldGkK42bCl0u9S1zULPCl0u52HJClAC7aU1PbbXlJfW(ubcZVY(JOaY3xgj(cfdN0hfOLcjgDx4aJURtWgGVuwotQJneFHaniGw4RtdcIhAQpLeOvSxgfui3oKBp5uULPCRB5wuDUTGHIc9usSkj52bCRtdcIxglG9PceMFL9hrbKVVmsUDa3YeUfU7SVmspqLA2(YM8fQqHEaXwAk52HClAC7aUfU7SVmspIkd5VipsdqShqSLMsUDi3Ig3ECWTWDN9Lr6bQuZ2x2KVqfk0di2stj3ka3Ec3oGBH7o7lJ0JOYq(lYJ0ae7beBPPKBhYTNWTd4wOPYTd52t42JdUfU7SVmspqLA2(YM8fQqHEaXwAk52HC7jC7aUfU7SVmspIkd5VipsdqShqSLMsUvaU9eUDa3cnvUDi36gC7Xb3cnvpBDMBzk3cnvUvGrU1f3oGBPKaTI9HYsFSpBDMBfGBrJBrn3ECWToniiEOP(usGwXEzuqHC7qU11PC7aUfrBnJhqSLMsUvaU1nJVfm0nXxPintnBFiOs6fQqH4aJUl3aBa(sz5mPo2q8TGHUj(6mlOWTjEHkui(cbAqaTWx4Y6SVmaQqIBhWTmHBJAsz4LeGsne7PSCMuNBhWTWDN9Lr6LeGsne7beBPPKBfGBpHBpo4w4UZ(Yi9avQz7lBYxOcf6beBPPKBhYTU42bClC3zFzKEevgYFrEKgGypGylnLC7qU1f3ECWTWDN9Lr6bQuZ2x2KVqfk0di2stj3ka3Ec3oGBH7o7lJ0JOYq(lYJ0ae7beBPPKBhYTNWTd4wOPYTd5w042JdUfU7SVmspqLA2(YM8fQqHEaXwAk52HC7jC7aUfU7SVmspIkd5VipsdqShqSLMsUvaU9eUDa3cnvUDi3Ec3ECWTqtLBhYTULBpo4wNgeeVZk8fbwOVre3IA8fkgoPpkqlfsm6UWbgDxUfBa(sz5mPo2q8TGHUj(gAlbEr1KfFHaniGw4lCzD2xgaviXTd4wOP6zRZClt5wOPYTdh5w0WxOy4K(OaTuiXO7chy0DHQWgGVAgea0ikWxx4BbdDt8fzkwZ2xsarugVqfkeFPSCMuhBioWO7YnJnaFPSCMuhBi(wWq3eFDMfu42eVqfkeFHaniGw4lCzD2xgaviXTd4w4UZ(Yi9iQmK)I8inaXEaXwAk5wb42t42bCl0u52rUfnUDa3kcqO8TWU3Lp0wc8IQjl3oGBPKaTI9HYsFSVBpLBfGBDHVqXWj9rbAPqIr3foWO7Y9XgGVuwotQJneFlyOBIVoZckCBIxOcfIVqGgeql8fUSo7ldGkK42bClLeOvSpuw6J9zRZCRaClAC7aULjCl0u9S1zULPCl0u5wbg5wxC7Xb3kcqO8TWU3Lp0wc8IQjl3IA8fkgoPpkqlfsm6UWboWxy)Lec2am6UWgGVuwotQJneFHaniGw4R74wukGwotYBUZ(FUHsU94GBr0wZ4beBPPKBfGBrZT4BbdDt8vtuwH0FUHsCGrhnSb4lLLZK6ydXxiqdcOf(cnvpBDMBzk3cnvUD4i36cFlyOBIVfawj9Xcaug4aJ(jydWxklNj1XgIVqGgeql81PbbXlJfW(ubcZVY(JOaY3xgj3oGBfrH)CdLFyspdtnOp0wc4lyOOqC7Xb3IOTMXdi2stj3ka366uU94GBr0wZ4beBPPKBhYTUC)tX3cg6M4BSnqZFr(ovHjoWO7gydWxklNj1XgIVqGgeql8LjClO0(tOqz4REx61KBhYTUHB52JdUfuA)juOm8vVl9nI4wuZTd4w4UZ(Yi9avQz7lBYxOcf6beBPPKBfGBPZeSjOpuwcFlyOBIVmOs0MYFr(f0jaoWO7wSb4lLLZK6ydXxiqdcOf(cxwN9LbqfsC7aULjClO0(tOqz4REx61KBhYTUoLBpo4wqP9NqHYWx9U03iIBrn(wWq3eFrkAQj9YyzfHdm6OkSb4lLLZK6ydXxiqdcOf(ckT)ekug(Q3LEn52HC7jNYThhClO0(tOqz4REx6BeHVfm0nXxKAoP8xqNa4aJUBgBa(sz5mPo2q8fc0GaAHVGs7pHcLHV6DPxtUDi362t52JdUfuA)juOm8vVl9nIW3cg6M4RZMuVrgVdGyGVtnPh2Xxu1P4aJU7JnaFPSCMuhBi(cbAqaTWx4UZ(Yi9YybSpvGW8RS)ikG8qZc0ssUDKBrJBpo4weT1mEaXwAk5wb4w0oLBpo4wMWTGs7pHcLHV6DPhqSLMsUDi36YTC7Xb36oUfUOqzLHxOyGwj3oGBzc3YeUfuA)juOm8vVl9AYTd5w4UZ(Yi9YybSpvGW8RS)ikG8inZ5diOzbAPpuwIBpo4w3XTGs7pHcLHV6DPNoRYqYTOMBhWTmHBH7o7lJ0RjkRq6p3q5hM0ZWud6dTLaEaXwAk52HClC3zFzKEzSa2Nkqy(v2FefqEKM58be0SaT0hklXThhClkfqlNj5n3z)p3qj3IAUf1C7aUfU7SVmspIkd5VipsdqShqSLMsUvGrUfvWTd4wOPYTdh5w042bClC3zFzKEgMkyQz73bv7MVOMeA6beBPPKBfyKBDHg3IA8TGHUj(kJfW(ubcZVY(JOachy0rfydWxklNj1XgIVqGgeql8fUOqzLHxOyGwj3oGBzc360GG4zqLOnL)I8lOtaFJiU94GBzc3IOTMXdi2stj3ka3c3D2xgPNbvI2u(lYVGob8aIT0uYThhClC3zFzKEgujAt5Vi)c6eWdi2stj3oKBH7o7lJ0lJfW(ubcZVY(JOaYJ0mNpGGMfOL(qzjUf1C7aUfU7SVmspIkd5VipsdqShqSLMsUvGrUfvWTd4wOPYTdh5w042bClC3zFzKEgMkyQz73bv7MVOMeA6beBPPKBfyKBDHg3IA8TGHUj(kJfW(ubcZVY(JOachy0DDk2a8LYYzsDSH4leObb0cFH7o7lJ0JOYq(lYJ0ae7beBPPKBfGBrJBpo4weT1mEaXwAk5wb4wxOHVfm0nXxN5U9Fr(WKEkjwX4aJUlxydW3cg6M4BBtb6AL)I8fQKaByIVuwotQJnehy0DHg2a8TGHUj(YybZokKMpGKBwjKWxklNj1XgIdm6UobBa(sz5mPo2q8fc0GaAHVUJB7B4HBcPmavq9hzwS070aspGylnLC7aULjClt4w3XTrnPm8mmvWuZ2VdQ2nFrnj00tz5mPo3ECWTWDN9Lr6zyQGPMTFhuTB(IAsOPhqSLMsUf1C7aUfU7SVmspqLA2(YM8fQqHEaXwAk52bClC3zFzKEevgYFrEKgGypGylnLC7aU1PbbXlJfW(ubcZVY(JOaY3xgj3IAU94GBr0wZ4beBPPKBfGBDF8TGHUj(c3eszaQG6pYSyjCGr3LBGnaFlyOBIVHj9nPZ2K9hzbqcFPSCMuhBioWO7YTydW3cg6M4ROgGIiwZ23zwYaFPSCMuhBioWO7cvHnaFPSCMuhBi(cbAqaTW3OaTu4dLL(yFrW4r7uUDi3EYPC7Xb3gfOLcVjvZW0lcgCRaJClANIVfm0nXxavI0S9rMfljXbgDxUzSb4BbdDt8fzHnsQ)fQKaAqVdvS4lLLZK6ydXbgDxUp2a8LYYzsDSH4leObb0cFPKaTI5wb4w34u8TGHUj(YsSlq8Vi)SbQ9VdOIvIdm6UqfydW3cg6M4lqfjAsVMVuubj8LYYzsDSH4aJoANInaFPSCMuhBi(cbAqaTWx4UZ(Yi9YybSpvGW8RS)ikG8qZc0ssUDKBrJBpo4weT1mEaXwAk5wb4w0oLBpo4wNgeeVKOWuZ2huTKVre3ECWTmHBH7o7lJ07m3T)lYhM0tjXk2di2stj3Ae36IBhYTWDN9Lr6LXcyFQaH5xz)rua5rAMZhqqZc0sFOSe3ECWTUJBjPKsi5DM72)f5dt6PKyf7zl3BbClQ52bClC3zFzKEevgYFrEKgGypGylnLCRaCRRt52bCl0u52HJClAC7aUfU7SVmspdtfm1S97GQDZxutcn9aIT0uYTcWTUqdFlyOBIVYybSpvGW8RS)ikGWbgD0CHnaFPSCMuhBi(MflHVL0eLkj5dku5cE4cQj(wWq3eFlPjkvsYhuOYf8WfutCGrhn0WgGVfm0nX3gj9AqSs8LYYzsDSH4aJoANGnaFPSCMuhBi(cbAqaTWxeT1mEaXwAk52HCRl3Ik42JdUvef(Znu(Hj9mm1G(qBjGVGHIcXThhClkfqlNj5n3z)p3qj(wWq3eFJTbA(lYlSaSfoWOJMBGnaFPSCMuhBi(cbAqaTWx4UZ(Yi9AIYkK(Znu(Hj9mm1G(qBjGhqSLMsUDi3EYPC7Xb3Isb0YzsEZD2)ZnuYThhClI2AgpGylnLCRaClANIVfm0nXxN5U9hPbighy0rZTydWxklNj1XgIVqGgeql8fU7SVmsVMOScP)CdLFyspdtnOp0wc4beBPPKBhYTNCk3ECWTOuaTCMK3CN9)CdLC7Xb3IOTMXdi2stj3ka36YT4BbdDt81HasciuZwCGrhnuf2a8TGHUj(o1wZq(UxtVLLYaFPSCMuhBioWOJMBgBa(sz5mPo2q8fc0GaAHVWDN9Lr61eLvi9NBO8dt6zyQb9H2sapGylnLC7qU9Kt52JdUfLcOLZK8M7S)NBOKBpo4weT1mEaXwAk5wb4wxNIVfm0nXxefqoZD74aJoAUp2a8LYYzsDSH4leObb0cFH7o7lJ0RjkRq6p3q5hM0ZWud6dTLaEaXwAk52HC7jNYThhClkfqlNj5n3z)p3qj3ECWTiARz8aIT0uYTcWTODk(wWq3eFResYauZhwZjoWOJgQaBa(sz5mPo2q8fc0GaAHVoniiEzSa2Nkqy(v2Fefq((YiX3cg6M4Rt1(lYhafkuIdCGVDcPAMb2am6UWgGVfm0nXxPiQaVzL9xgaviHVuwotQJnehy0rdBa(sz5mPo2q8DfHVskW3cg6M4lkfqlNjHVOuZgcFH7o7lJ0RjkRq6p3q5hM0ZWud6dTLaEaXwAk52HClI2AgpGylnLC7Xb3IOTMXdi2stj3ka36cTt52bClI2AgpGylnLC7qUfU7SVmsVKauQHypGylnLC7aUfU7SVmsVKauQHypGylnLC7qU11P4lkf4ZILWxZD2)ZnuIdm6NGnaFPSCMuhBi(cbAqaTWxMWToniiEjbOudX(grC7Xb360GG4LXcyFQaH5xz)rua5BeXTOMBhWTIOWFUHYpmPNHPg0hAlb8fmuuiU94GBr0wZ4beBPPKBfyKBrvNIVfm0nXxrBOBIdm6Ub2a8LYYzsDSH4leObb0cFDAqq8scqPgI9nIW3cg6M4lSMZVGHU5pvzGVtvgFwSe(kjaLAighy0Dl2a8LYYzsDSH4leObb0cFDAqq8mOs0MYFr(f0jGVre(wWq3eFH1C(fm0n)Pkd8DQY4ZILWxgujAt5Vi)c6eahy0rvydWxklNj1XgIVqGgeql8nuwIBfGBDdUDa3cnvUvaU1TC7aU1DCRik8NBO8dt6zyQb9H2saFbdffcFlyOBIVWAo)cg6M)uLb(ovz8zXs47kIscGdm6UzSb4lLLZK6ydX3cg6M4lIkJFr(WKEgMAqFOTeaFHaniGw4l0u9S1zULPCl0u52HJC7jC7aULjClLeOvSpuw6J9zRZCRaCRlU94GBPKaTI9HYsFSpBDMBfGBDdUDa3c3D2xgPhrLH8xKhPbi2di2stj3ka36Y7wU94GBH7o7lJ0ZGkrBk)f5xqNaEaXwAk5wb4w04wuJVqXWj9rbAPqIr3foWO7(ydWxklNj1XgIVqGgeql8fAQE26m3YuUfAQC7WrU1f3oGBzc3sjbAf7dLL(yF26m3ka36IBpo4w4UZ(Yi9scqPgI9aIT0uYTcWTOXThhClLeOvSpuw6J9zRZCRaCRBWTd4w4UZ(Yi9iQmK)I8inaXEaXwAk5wb4wxE3YThhClC3zFzKEgujAt5Vi)c6eWdi2stj3ka3Ig3IA8TGHUj(sNfrZ3SaS4aJoQaBa(sz5mPo2q8TGHUj(gAlbEr1KfFHaniGw4lCzD2xgaviXTd4wOP6zRZClt5wOPYTdh5w042bClt4wkjqRyFOS0h7ZwN5wb4wxC7Xb3c3D2xgPxsak1qShqSLMsUvaUfnU94GBPKaTI9HYsFSpBDMBfGBDdUDa3c3D2xgPhrLH8xKhPbi2di2stj3ka36Y7wU94GBH7o7lJ0ZGkrBk)f5xqNaEaXwAk5wb4w04wuJVqXWj9rbAPqIr3foWO76uSb4lLLZK6ydXxiqdcOf(6oUnQjLHxsak1qSNYYzsD8TGHUj(cR58lyOB(tvg47uLXNflHVW(ljeCGr3LlSb4lLLZK6ydXxiqdcOf(g1KYWljaLAi2tz5mPo(wWq3eFH1C(fm0n)Pkd8DQY4ZILWxy)LeGsneJdm6UqdBa(sz5mPo2q8fc0GaAHVfmuuONsIvjj3ka3Ec(wWq3eFH1C(fm0n)Pkd8DQY4ZILWxzGdm6UobBa(sz5mPo2q8fc0GaAHVfmuuONsIvjj3oCKBpbFlyOBIVWAo)cg6M)uLb(ovz8zXs4BTeoWb(kcqWL1PcSby0DHnaFlyOBIVI2q3eFPSCMuhBioWOJg2a8TGHUj(6SrmP(JmlXuNHMTFSN1eFPSCMuhBioWOFc2a8LYYzsDSH47kcFLuGVfm0nXxukGwotcFrPMne(Ek(Isb(Syj89CdL)MFJK(aOPqkWbgD3aBa(sz5mPo2q8fc0GaAHVUJBJAsz4LeGsne7PSCMuNBpo4w3XTrnPm8iQm(f5dt6zyQb9H2sapLLZK64BbdDt8fAQVtdqg4aJUBXgGVuwotQJneFHaniGw4R742OMugEkjqRIk1S9PPEMaEklNj1X3cg6M4l0uFgfkeoWb(wlHnaJUlSb4BbdDt8LHPcMA2(Dq1U5lQjHM4lLLZK6ydXbgD0WgGVuwotQJneFHaniGw4l0u9S1zULPCl0u52HJClAC7aULsc0k2hkl9X(S1zUDi3Ig3ECWTqt1ZwN5wMYTqtLBhoYTUb(wWq3eFPKaTkQuZ2NM6zfGdm6NGnaFPSCMuhBi(cbAqaTWxMWTUJBJAsz4n14HlRZ6PSCMuNBhWTWn7nA4H1e2mRG6VmaQqs6PSCMuNBpo4w4Y6SVmaQqIBrn3oGBzc360GG47vcPFrEOP6EQVre3ECWTDYPbbX7Sj1BKX7aig(grClQX3cg6M4RuKMPMTpeuj9cvOqCGr3nWgGVuwotQJneFHaniGw4lLeOvSpuw6J9zRZC7qULotWMG(qzjU94GBHMQNToZTmLBHMk3kWi36cFlyOBIViQmK)I8inaX4aJUBXgGVuwotQJneFlyOBIVavQz7lBYxOcfIVqGgeql8LjCButkdpdtfm1S97GQDZxutcn9uwotQZTd4w4UZ(Yi9avQz7lBYxOcf67nGk0n52HClC3zFzKEgMkyQz73bv7MVOMeA6beBPPKBnIBDdUf1C7aULjClC3zFzKEevgYFrEKgGypGylnLC7qU9eU94GBHMk3oCKBDl3IA8fkgoPpkqlfsm6UWbgDuf2a8LYYzsDSH4leObb0cFDAqq8GgPPMTV7vD6zOz33xgj(wWq3eFbnstnBF3R60ZqZooWO7MXgGVuwotQJneFHaniGw4lt4w3XTrnPm8MA8WL1z9uwotQZTd4w4M9gn8WAcBMvq9xgavij9uwotQZThhClCzD2xgaviXTOMBhWTmHBzc3c3D2xgP3ztQ3iJ3bqm8aIT0uYTd5w042bClt4wOPYTd52t42JdUfU7SVmspIkd5VipsdqShqSLMsUDi3IQ4wuZTd4wMWTqtLBhoYTULBpo4w4UZ(Yi9iQmK)I8inaXEaXwAk52HClAClQ5wuZThhClLeOvSpuw6J9zRZCRaJC7jClQX3cg6M4RuKMPMTpeuj9cvOqCGr39XgGVuwotQJneFHaniGw4l0u9S1zULPCl0u52HJCRl8TGHUj(sNfrZ3SaS4aJoQaBa(sz5mPo2q8TGHUj(IOY4xKpmPNHPg0hAlbWxiqdcOf(cnvpBDMBzk3cnvUD4i3Ec(cfdN0hfOLcjgDx4aJURtXgGVuwotQJneFHaniGw4l0u9S1zULPCl0u52HJClA4BbdDt8fAQVtdqg4aJUlxydWxklNj1XgIVqGgeql81PbbXhM0tSIiWcKpSevqnwGxgfui3oKBDHk42bClLeOvSpuw6J9zRZC7qULotWMG(qzjULPCRlUDa3c3D2xgPhrLH8xKhPbi2di2stj3oKBPZeSjOpuwcFlyOBIVqqbfo1S9DVQt)uBnJuZwCGr3fAydWxklNj1XgIVfm0nX3qBjWlQMS4leObb0cFHMQNToZTmLBHMk3oCKBrJBhWTmHBDh3g1KYWBQXdxwN1tz5mPo3ECWTWL1zFzauHe3IA8fkgoPpkqlfsm6UWbgDxNGnaFPSCMuhBi(cbAqaTWx4Y6SVmaQqcFlyOBIVqt9zuOq4aJUl3aBa(sz5mPo2q8TGHUj(ImfRz7ljGikJxOcfIVqGgeql81PbbX7ScFrGf67lJeF1miaOruGVUWbgDxUfBa(sz5mPo2q8TGHUj(6mlOWTjEHkui(cbAqaTWx4Y6SVmaQqIBhWTmHBDAqq8oRWxeyH(grC7Xb3g1KYWBQXdxwN1tz5mPo3oGBfbiu(wy37YhAlbEr1KLBhWTqtLBh5w042bClC3zFzKEevgYFrEKgGypGylnLCRaC7jC7Xb3cnvpBDMBzk3cnvUvGrU1f3oGBfbiu(wy37YlfPzQz7dbvsVqfkKBhWTusGwX(qzPp2NToZTcWTNWTOgFHIHt6Jc0sHeJUlCGdCGVOqaPUjgD0ofTtD5cTtWxgfi1SvIVUPWkAbb15wub3wWq3KBNQmKEUG4RiWIOtcFr1WTUP1SZOMcja36M4Mc5cIQHBDtIGeRdb4wxNWm3I2PODkxqUGOA4w3eotWMG6CRdHSaIBHlRtfCRd1QP0ZTOAfcjrHKBZnzQzbyrAMCBbdDtj3U5uSNlybdDtPxeGGlRtfJI2q3KlybdDtPxeGGlRtfgnASZgXK6pYSetDgA2(XEwtUGfm0nLEracUSovy0OXOuaTCMeZzXsJNBO838BK0hanfsbZROrjfmJsnBOXt5cwWq3u6fbi4Y6uHrJgdn13PbidMvKr3f1KYWljaLAi2tz5mP(XH7IAsz4ruz8lYhM0ZWud6dTLaEklNj15cwWq3u6fbi4Y6uHrJgdn1NrHcXSIm6UOMugEkjqRIk1S9PPEMaEklNj15cYfevd36MWzc2euNBjuiGyUnuwIBdtIBlySaUvLCBHsPZYzsEUGfm0nLJsrubEZk7VmaQqIlybdDtPrJgJsb0YzsmNflnAUZ(FUHsMxrJskygLA2qJWDN9Lr61eLvi9NBO8dt6zyQb9H2sapGylnLdr0wZ4beBPP84arBnJhqSLMsbCH2Pdq0wZ4beBPPCiC3zFzKEjbOudXEaXwAkha3D2xgPxsak1qShqSLMYHUoLlybdDtPrJglAdDtMvKrM40GG4LeGsne7BeDC40GG4LXcyFQaH5xz)rua5BeH6bIOWFUHYpmPNHPg0hAlb8fmuuOJdeT1mEaXwAkfyevDkxWcg6MsJgngwZ5xWq38NQmyolwAusak1qmZkYOtdcIxsak1qSVrexWcg6MsJgngwZ5xWq38NQmyolwAKbvI2u(lYVGobywrgDAqq8mOs0MYFr(f0jGVrexWcg6MsJgngwZ5xWq38NQmyolwACfrjbywrgdLLeWnganvbC7a3jIc)5gk)WKEgMAqFOTeWxWqrH4cwWq3uA0OXiQm(f5dt6zyQb9H2saMHIHt6Jc0sHC0fZkYi0u9S1zMcn1HJNmGjusGwX(qzPp2NTolGRJdkjqRyFOS0h7ZwNfWnga3D2xgPhrLH8xKhPbi2di2stPaU8U94aU7SVmspdQeTP8xKFbDc4beBPPua0qnxWcg6MsJgnMolIMVzbyzwrgHMQNToZuOPoC01aMqjbAf7dLL(yF26SaUooG7o7lJ0ljaLAi2di2stPaODCqjbAf7dLL(yF26SaUXa4UZ(Yi9iQmK)I8inaXEaXwAkfWL3ThhWDN9Lr6zqLOnL)I8lOtapGylnLcGgQ5cwWq3uA0OXH2sGxunzzgkgoPpkqlfYrxmRiJWL1zFzauH0aOP6zRZmfAQdhrBatOKaTI9HYsFSpBDwaxhhWDN9Lr6LeGsne7beBPPua0ooOKaTI9HYsFSpBDwa3yaC3zFzKEevgYFrEKgGypGylnLc4Y72Jd4UZ(Yi9mOs0MYFr(f0jGhqSLMsbqd1CblyOBknA0yynNFbdDZFQYG5SyPry)LecZkYO7IAsz4LeGsne7PSCMuNlybdDtPrJgdR58lyOB(tvgmNflnc7VKauQHyMvKXOMugEjbOudXEklNj15cwWq3uA0OXWAo)cg6M)uLbZzXsJYGzfzSGHIc9usSkjf4eUGfm0nLgnAmSMZVGHU5pvzWCwS0yTeZkYybdff6PKyvsoC8eUGCblyOBk91sJmmvWuZ2VdQ2nFrnj0KlybdDtPVwYOrJPKaTkQuZ2NM6zfWSImcnvpBDMPqtD4iAdOKaTI9HYsFSpBDEiAhhqt1ZwNzk0uho6gCblyOBk91sgnASuKMPMTpeuj9cvOqMvKrM4UOMugEtnE4Y6SEklNj1ha3S3OHhwtyZScQ)YaOcjPNYYzs9Jd4Y6SVmaQqc1dyItdcIVxjK(f5HMQ7P(grhhDYPbbX7Sj1BKX7aig(grOMlybdDtPVwYOrJruzi)f5rAaIzwrgPKaTI9HYsFSpBDEiDMGnb9HYshhqt1ZwNzk0ufy0fxWcg6MsFTKrJgduPMTVSjFHkuiZqXWj9rbAPqo6IzfzKjrnPm8mmvWuZ2VdQ2nFrnj00tz5mP(a4UZ(Yi9avQz7lBYxOcf67nGk0nhc3D2xgPNHPcMA2(Dq1U5lQjHMEaXwAknYnq9aMa3D2xgPhrLH8xKhPbi2di2st5WtooGM6Wr3IAUGfm0nL(AjJgng0in1S9DVQtpdn7mRiJoniiEqJ0uZ239Qo9m0S77lJKlybdDtPVwYOrJLI0m1S9HGkPxOcfYSImYe3f1KYWBQXdxwN1tz5mP(a4M9gn8WAcBMvq9xgavij9uwotQFCaxwN9LbqfsOEatycC3zFzKENnPEJmEhaXWdi2st5q0gWeOPo8KJd4UZ(Yi9iQmK)I8inaXEaXwAkhIQq9aMan1HJU94aU7SVmspIkd5VipsdqShqSLMYHOHAuFCqjbAf7dLL(yF26SaJNGAUGfm0nL(AjJgnMolIMVzbyzwrgHMQNToZuOPoC0fxWcg6MsFTKrJgJOY4xKpmPNHPg0hAlbygkgoPpkqlfYrxmRiJqt1ZwNzk0uhoEcxWcg6MsFTKrJgdn13PbidMvKrOP6zRZmfAQdhrJlybdDtPVwYOrJHGckCQz77EvN(P2AgPMTmRiJonii(WKEIvebwG8HLOcQXc8YOGch6cvmGsc0k2hkl9X(S15H0zc2e0hklXuxdG7o7lJ0JOYq(lYJ0ae7beBPPCiDMGnb9HYsCblyOBk91sgnACOTe4fvtwMHIHt6Jc0sHC0fZmRiJqt1ZwNzk0uhoI2aM4UOMugEtnE4Y6SEklNj1poGlRZ(YaOcjuZfSGHUP0xlz0OXqt9zuOqmRiJWL1zFzauHexWcg6MsFTKrJgJmfRz7ljGikJxOcfYSIm60GG4DwHViWc99LrYSMbbanIIrxCblyOBk91sgnASZSGc3M4fQqHmdfdN0hfOLc5OlMvKr4Y6SVmaQqAatCAqq8oRWxeyH(grhhrnPm8MA8WL1z9uwotQpqeGq5BHDVlFOTe4fvt2bqtDeTbWDN9Lr6ruzi)f5rAaI9aIT0ukWjhhqt1ZwNzk0ufy01aracLVf29U8srAMA2(qqL0luHchqjbAf7dLL(yF26SaNGAUGCblyOBk9W(ljKrnrzfs)5gk)WKEgMAqFOTeGzfz0DOuaTCMK3CN9)CdLhhiARz8aIT0ukaAULlybdDtPh2FjHy0OXfawj9XcaugmRiJqt1ZwNzk0uho6IlybdDtPh2FjHy0OXX2an)f57ufMmRiJoniiEzSa2Nkqy(v2Fefq((YihiIc)5gk)WKEgMAqFOTeWxWqrHooq0wZ4beBPPuaxNECGOTMXdi2st5qxU)PCblyOBk9W(ljeJgnMbvI2u(lYVGobywrgzcO0(tOqz4REx61COB42JdqP9NqHYWx9U03ic1dG7o7lJ0duPMTVSjFHkuOhqSLMsbOZeSjOpuwIlybdDtPh2FjHy0OXifn1KEzSSIywrgHlRZ(YaOcPbmbuA)juOm8vVl9Ao01PhhGs7pHcLHV6DPVreQ5cwWq3u6H9xsignAmsnNu(lOtaMvKrqP9NqHYWx9U0R5Wto94auA)juOm8vVl9nI4cwWq3u6H9xsignASZMuVrgVdGyWSImckT)ekug(Q3LEnh62tpoaL2FcfkdF17sFJiMNAspSpIQoLlybdDtPh2FjHy0OXYybSpvGW8RS)ikGywrgH7o7lJ0lJfW(ubcZVY(JOaYdnlqljhr74arBnJhqSLMsbq70JdMakT)ekug(Q3LEaXwAkh6YThhUdUOqzLHxOyGw5aMWeqP9NqHYWx9U0R5q4UZ(Yi9YybSpvGW8RS)ikG8inZ5diOzbAPpuw64WDGs7pHcLHV6DPNoRYqI6bmbU7SVmsVMOScP)CdLFyspdtnOp0wc4beBPPCiC3zFzKEzSa2Nkqy(v2FefqEKM58be0SaT0hklDCGsb0YzsEZD2)ZnuIAupaU7SVmspIkd5VipsdqShqSLMsbgrfdGM6Wr0ga3D2xgPNHPcMA2(Dq1U5lQjHMEaXwAkfy0fAOMlybdDtPh2FjHy0OXYybSpvGW8RS)ikGywrgHlkuwz4fkgOvoGjoniiEgujAt5Vi)c6eW3i64GjiARz8aIT0ukaC3zFzKEgujAt5Vi)c6eWdi2st5XbC3zFzKEgujAt5Vi)c6eWdi2st5q4UZ(Yi9YybSpvGW8RS)ikG8inZ5diOzbAPpuwc1dG7o7lJ0JOYq(lYJ0ae7beBPPuGruXaOPoCeTbWDN9Lr6zyQGPMTFhuTB(IAsOPhqSLMsbgDHgQ5cwWq3u6H9xsignASZC3(ViFyspLeRyMvKr4UZ(Yi9iQmK)I8inaXEaXwAkfaTJdeT1mEaXwAkfWfACblyOBk9W(ljeJgnUTPaDTYFr(cvsGnm5cwWq3u6H9xsignAmJfm7OqA(asUzLqIlybdDtPh2FjHy0OXWnHugGkO(JmlwIzfz0D9n8WnHugGkO(Jmlw6DAaPhqSLMYbmHjUlQjLHNHPcMA2(Dq1U5lQjHMEklNj1poG7o7lJ0ZWubtnB)oOA38f1KqtpGylnLOEaC3zFzKEGk1S9Ln5luHc9aIT0uoaU7SVmspIkd5VipsdqShqSLMYboniiEzSa2Nkqy(v2Fefq((Yir9XbI2AgpGylnLc4(CblyOBk9W(ljeJgnomPVjD2MS)ilasCblyOBk9W(ljeJgnwudqreRz77mlzWfSGHUP0d7VKqmA0yavI0S9rMfljzwrgJc0sHpuw6J9fbJhTthEYPhhrbAPWBs1mm9IGHaJODkxWcg6MspS)scXOrJrwyJK6FHkjGg07qflxWcg6MspS)scXOrJzj2fi(xKF2a1(3buXkzwrgPKaTIfWnoLlybdDtPh2FjHy0OXavKOj9A(srfK4cwWq3u6H9xsignASmwa7tfim)k7pIciMvKr4UZ(Yi9YybSpvGW8RS)ikG8qZc0sYr0ooq0wZ4beBPPua0o94WPbbXljkm1S9bvl5BeDCWe4UZ(Yi9oZD7)I8Hj9usSI9aIT0uAKRHWDN9Lr6LXcyFQaH5xz)rua5rAMZhqqZc0sFOS0XH7iPKsi5DM72)f5dt6PKyf7zl3BbOEaC3zFzKEevgYFrEKgGypGylnLc460bqtD4iAdG7o7lJ0ZWubtnB)oOA38f1KqtpGylnLc4cnUGfm0nLEy)LeIrJg3iPxdIL5SyPXsAIsLK8bfQCbpCb1KlybdDtPh2FjHy0OXns61GyLCblyOBk9W(ljeJgno2gO5ViVWcWwmRiJiARz8aIT0uo0LBrfhhIOWFUHYpmPNHPg0hAlb8fmuuOJdukGwotYBUZ(FUHsUGfm0nLEy)LeIrJg7m3T)inaXmRiJWDN9Lr61eLvi9NBO8dt6zyQb9H2sapGylnLdp50JdukGwotYBUZ(FUHYJdeT1mEaXwAkfaTt5cwWq3u6H9xsignASdbKeqOMTmRiJWDN9Lr61eLvi9NBO8dt6zyQb9H2sapGylnLdp50JdukGwotYBUZ(FUHYJdeT1mEaXwAkfWLB5cwWq3u6H9xsignA8uBnd57En9wwkdUGfm0nLEy)LeIrJgJOaYzUBNzfzeU7SVmsVMOScP)CdLFyspdtnOp0wc4beBPPC4jNECGsb0YzsEZD2)ZnuECGOTMXdi2stPaUoLlybdDtPh2FjHy0OXvcjzaQ5dR5KzfzeU7SVmsVMOScP)CdLFyspdtnOp0wc4beBPPC4jNECGsb0YzsEZD2)ZnuECGOTMXdi2stPaODkxWcg6MspS)scXOrJDQ2Fr(aOqHsMvKrNgeeVmwa7tfim)k7pIciFFzKCb5cwWq3u6H9xsak1q8ikfqlNjXCwS0OKauQH43PbidMxrJskygLA2qJWDN9Lr6LeGsne7beBPPuaxhhIOWFUHYpmPNHPg0hAlb8fmuuObWDN9Lr6LeGsne7beBPPC4jNECGOTMXdi2stPaODkxWcg6MspS)scqPgInA0ynrzfs)5gk)WKEgMAqFOTeGzfz0DOuaTCMK3CN9)CdLhhiARz8aIT0ukaAULlybdDtPh2FjbOudXgnACJKEniwMZILglPjkvsYhuOYf8WfutUGfm0nLEy)LeGsneB0OXns61GyLCblyOBk9W(ljaLAi2OrJDM72FKgGyMvKrukGwotYljaLAi(DAaYGlybdDtPh2FjbOudXgnASdbKeqOMTmRiJOuaTCMKxsak1q870aKbxWcg6MspS)scqPgInA042Mc01k)f5lujb2WKzfzerBnJhqSLMYHUCF3ECGsb0YzsEjbOudXVtdqghhiARz8aIT0ukWjULlybdDtPh2FjbOudXgnAmJfm7OqA(asUzLqIzfzeLcOLZK8scqPgIFNgGm4cwWq3u6H9xsak1qSrJg7m3T)lYhM0tjXkMzfzeLcOLZK8scqPgIFNgGm4cwWq3u6H9xsak1qSrJgd3eszaQG6pYSyjMvKrMa3D2xgPxsak1qShqSLMYJd4UZ(Yi9WnHugGkO(JmlwYdnlqljhrd1dCxFdpCtiLbOcQ)iZILENgq6beBPPCatG7o7lJ0duPMTVSjFHkuOhqSLMYbWDN9Lr6ruzi)f5rAaI9aIT0uECGOTMXdi2stPaUpQ5cwWq3u6H9xsak1qSrJghM03KoBt2FKfajUGfm0nLEy)LeGsneB0OXIAakIynBFNzjdUGfm0nLEy)LeGsneB0OXaQePz7JmlwsYSImgfOLcFOS0h7lcgpANo8KtpoIc0sH3KQzy6fbdbgr70JJOaTu4dLL(y)UscGgxWcg6MspS)scqPgInA0yKf2iP(xOscOb9ouXYfSGHUP0d7VKauQHyJgnMLyxG4Fr(zdu7FhqfRKzfzKsc0kwa34uUGfm0nLEy)LeGsneB0OXavKOj9A(srfK4cwWq3u6H9xsak1qSrJgxayL0hlaqzWSImcnvpBDMPqtD4OlUGfm0nLEy)LeGsneB0OXtT1mKV710BzPm4cwWq3u6H9xsak1qSrJgJOaYzUBNzfzeLcOLZK8scqPgIFNgGm4cwWq3u6H9xsak1qSrJgxjKKbOMpSMtMvKrukGwotYljaLAi(DAaYGlybdDtPh2FjbOudXgnASt1(lYhafkuYSImIsb0YzsEjbOudXVtdqgCblyOBk9W(ljaLAi2OrJJTbA(lY3Pkmzwrgr0wZ4beBPPCOl3)0Jdru4p3q5hM0ZWud6dTLa(cgkk0XbI2AgpGylnLc46uUGfm0nLEy)LeGsneB0OXX2an)f5fwa2IzfzerBnJhqSLMYHOItpoerH)CdLFyspdtnOp0wc4lyOOqhhiARz8aIT0ukGRt5cwWq3u6H9xsak1qSrJgZGkrBk)f5xqNamRiJWDN9Lr6bQuZ2x2KVqfk0di2stPa0zc2e0hklXfSGHUP0d7VKauQHyJgngPOPM0lJLvexWcg6MspS)scqPgInA0yKAoP8xqNaCblyOBk9W(ljaLAi2OrJD2K6nY4DaedUGfm0nLEy)LeGsneB0OXscqPgIzwrgH7o7lJ0duPMTVSjFHkuOhqSLMsbq74arBnJhqSLMsbC5wUGfm0nLEy)LeGsneB0OXov7ViFauOqjxqUGfm0nL(veLeyerLXViFyspdtnOp0wcWmumCsFuaqlfYrxmRiJqt1ZwNzk0uhoEcxWcg6Ms)kIscy0OX0zr08nlalZkYyutkdp0uFNgGm8uwotQpaAQE26mtHM6WXt4cwWq3u6xrusaJgno0wc8IQjlZqXWj9rbAPqo6IzfzeUSo7ldGkKganvpBDMPqtD4iACblyOBk9RikjGrJgdn1NrHcXSImcnvpBDMPqtDenUGfm0nL(veLeWOrJPZIO5BwawUGfm0nL(veLeWOrJdTLaVOAYYmumCsFuGwkKJUywrgHMQNToZuOPoCenUGCblyOBk9scqPgIhruzi)f5rAaIzwrgDAqq8scqPgI9aIT0ukGlUGfm0nLEjbOudXgnACJKEniwMZILglPjkvsYhuOYf8WfutUGfm0nLEjbOudXgnASuKMPMTpeuj9cvOqMvKrM4UOMugEtnE4Y6SEklNj1ha3S3OHhwtyZScQ)YaOcjPNYYzs9Jd4Y6SVmaQqc1dysbdff6PKyvsoC8KJJcgkk0tjXQKCORbUdU7SVmspqLA2(YM8fQqH(grOMlybdDtPxsak1qSrJgduPMTVSjFHkuiZqXWj9rbAPqo6IzfzeUSo7ldGkK4cwWq3u6LeGsneB0OXiQmK)I8inaXmRiJfmuuONsIvj5WXt4cwWq3u6LeGsneB0OXsrAMA2(qqL0luHczwrgzI7IAsz4n14HlRZ6PSCMuFaCZEJgEynHnZkO(ldGkKKEklNj1poGlRZ(YaOcjupWPbbX3Res)I8qt19uFJiUGfm0nLEjbOudXgnASZSGc3M4fQqHmdfdN0hfOLc5OlMvKrMaxwN9LbqfshhUlQjLH3uJhUSoRNYYzsDupWPbbXZGkrBk)f5xqNapdg(grdG7o7lJ0duPMTVSjFHkuOhqSLMYHOXfSGHUP0ljaLAi2OrJruz8lYhM0ZWud6dTLamRzqaqJOy0fxWcg6MsVKauQHyJgnwksZuZ2hcQKEHkuiZkYitCxutkdVPgpCzDwpLLZK6dGB2B0WdRjSzwb1FzauHK0tz5mP(XbCzD2xgaviH6bDYPbbX7Sj1BKX7aig(grCblyOBk9scqPgInA0yevg)I8Hj9mm1G(qBjaZqXWj9rbAPqo6IzfzeAQcCcxWcg6MsVKauQHyJgn2zwqHBt8cvOqMHIHt6Jc0sHC0fZkYiCzD2xgaviDC4UOMugEtnE4Y6SEklNj15cwWq3u6LeGsneB0OXsrAMA2(qqL0luHc5cYfSGHUP0lJrgMkyQz73bv7MVOMeAYSImckT)ekug(Q3LEnhc3D2xgPNHPcMA2(Dq1U5lQjHM(EdOcDtu9t9U)XbO0(tOqz4REx6BeXfSGHUP0ldJgnMsc0QOsnBFAQNvaZkYi0u9S1zMcn1HJOnGsc0k2hkl9X(S15HNCCanvpBDMPqtD4OBmGjusGwX(qzPp2NTopeTJd3jcqO8TWU3Lp0wc8IQjlQ5cwWq3u6LHrJglfPzQz7dbvsVqfkKzfzKjUlQjLH3uJhUSoRNYYzs9bWn7nA4H1e2mRG6VmaQqs6PSCMu)4aUSo7ldGkKq9aNgeeFVsi9lYdnv3t9nIgWeqP9NqHYWx9U0R5qNgeeFVsi9lYdnv3t9aIT0uYu0ooaL2FcfkdF17sFJiuZfSGHUP0ldJgngOsnBFzt(cvOqMHIHt6Jc0sHC0fZkYiC3zFzKEjbOudXEaXwAkh664WDrnPm8scqPgI9uwotQZfSGHUP0ldJgngrLH8xKhPbiMzfzKjGs7pHcLHV6DPxZHWDN9Lr6ruzi)f5rAaI99gqf6MO6N6D)JdqP9NqHYWx9U03ic1dycLeOvSpuw6J9zRZdPZeSjOpuwIPUooGMQNToZuOPkWORJdNgeeVmwa7tfim)k7pIcipGylnLcqNjytqFOSKrUq9XbI2AgpGylnLcqNjytqFOSKrU4cwWq3u6LHrJgdbfu4uZ239Qo9tT1msnBzwrgDAqq8Hj9eRicSa5dlrfuJf4Lrbfo0fQyaLeOvSpuw6J9zRZdPZeSjOpuwIPUga3D2xgPhOsnBFzt(cvOqpGylnLdPZeSjOpuw64WPbbXhM0tSIiWcKpSevqnwGxgfu4qxUXaMa3D2xgPxsak1qShqSLMsbC7GOMugEjbOudXEklNj1poG7o7lJ0ZGkrBk)f5xqNaEaXwAkfWTdGlkuwz4fkgOvECGOTMXdi2stPaUf1CblyOBk9YWOrJbnstnBF3R60ZqZoZkYOtdcIh0in1S9DVQtpdn7((YihuWqrHEkjwLKdDXfSGHUP0ldJgngrLXViFyspdtnOp0wcWmumCsFuGwkKJUywrgHMQaNWfSGHUP0ldJgnMolIMVzbyzwrgHMQNToZuOPoC0fxWcg6MsVmmA0yOP(onazWSImcnvpBDMPqtD4ORbfmuuONsIvj5ORbGs7pHcLHV6DPxZHOD6Xb0u9S1zMcn1HJOnOGHIc9usSkjhoIgxWcg6MsVmmA0yOP(mkuiUGfm0nLEzy0OXH2sGxunzzgkgoPpkqlfYrxmZSImcxwN9LbqfsdGMQNToZuOPoCeTboniiEzSa2Nkqy(v2Fefq((Yi5cwWq3u6LHrJglfPzQz7dbvsVqfkKzfz0PbbXdn1Nsc0k2lJckC4jNYu3IQxWqrHEkjwLKdCAqq8YybSpvGW8RS)ikG89LroGjWDN9Lr6bQuZ2x2KVqfk0di2st5q0ga3D2xgPhrLH8xKhPbi2di2st5q0ooG7o7lJ0duPMTVSjFHkuOhqSLMsbozaC3zFzKEevgYFrEKgGypGylnLdpza0uhEYXbC3zFzKEGk1S9Ln5luHc9aIT0uo8KbWDN9Lr6ruzi)f5rAaI9aIT0ukWjdGM6q344aAQE26mtHMQaJUgqjbAf7dLL(yF26SaOH6JdNgeep0uFkjqRyVmkOWHUoDaI2AgpGylnLc4M5cwWq3u6LHrJg7mlOWTjEHkuiZqXWj9rbAPqo6IzfzeUSo7ldGkKgWKOMugEjbOudXEklNj1ha3D2xgPxsak1qShqSLMsbo54aU7SVmspqLA2(YM8fQqHEaXwAkh6AaC3zFzKEevgYFrEKgGypGylnLdDDCa3D2xgPhOsnBFzt(cvOqpGylnLcCYa4UZ(Yi9iQmK)I8inaXEaXwAkhEYaOPoeTJd4UZ(Yi9avQz7lBYxOcf6beBPPC4jdG7o7lJ0JOYq(lYJ0ae7beBPPuGtgan1HNCCan1HU94WPbbX7ScFrGf6BeHAUGfm0nLEzy0OXH2sGxunzzgkgoPpkqlfYrxmZSImcxwN9LbqfsdGMQNToZuOPoCenUGfm0nLEzy0OXitXA2(sciIY4fQqHmRzqaqJOy0fxqunClQ2Ke3A4IQDUvr4w3ux3u5wvYTW5kjUTYo3kEB4wZcfIBrJBHMk3wzNBfVnaUDwYGBBNRtn5wgLKBnWnzM52fWTkc3kEB42cqCB5Snb3gl3clrClLeOvm3wzNBjnmja3kEBaC7SKb32c7ClJsYTg4Mm3UaUvr4wXBd3waIBNKuYTHzLClACl0u52IrjMBrall3clrI0SLlybdDtPxggnASZSGc3M4fQqHmdfdN0hfOLc5OlMvKr4Y6SVmaQqAaC3zFzKEevgYFrEKgGypGylnLcCYaOPoI2aracLVf29U8H2sGxunzhqjbAf7dLL(yF3EQaU4cwWq3u6LHrJg7mlOWTjEHkuiZqXWj9rbAPqo6IzfzeUSo7ldGkKgqjbAf7dLL(yF26SaOnGjqt1ZwNzk0ufy01XHiaHY3c7Ex(qBjWlQMSOMlixWcg6MspdQeTP8xKFbDcmcR58lyOB(tvgmNflnc7VKqywrgDxutkdVKauQHypLLZK6CblyOBk9mOs0MYFr(f0jGrJgdR58lyOB(tvgmNflnc7VKauQHyMvKXOMugEjbOudXEklNj15cwWq3u6zqLOnL)I8lOtaJgnMsc0QOsnBFAQNvaZkYi0u9S1zMcn1HJOnGsc0k2hkl9X(S15HNWfSGHUP0ZGkrBk)f5xqNagnAmqLA2(YM8fQqHmdfdN0hfOLc5OlUGfm0nLEgujAt5Vi)c6eWOrJLI0m1S9HGkPxOcfYSImYe3f1KYWBQXdxwN1tz5mP(a4M9gn8WAcBMvq9xgavij9uwotQFCaxwN9LbqfsOEGtdcIVxjK(f5HMQ7P(grCblyOBk9mOs0MYFr(f0jGrJgJOYq(lYJ0aeZSImwWqrHEkjwLKdhrBGtdcINbvI2u(lYVGobEgm8aIT0ukGlUGfm0nLEgujAt5Vi)c6eWOrJzyQGPMTFhuTB(IAsOjZkYybdff6PKyvsoCenUGfm0nLEgujAt5Vi)c6eWOrJLI0m1S9HGkPxOcfYSImYe3f1KYWBQXdxwN1tz5mP(a4M9gn8WAcBMvq9xgavij9uwotQFCaxwN9LbqfsOEqbdff6PKyvsoC8KboniiEgujAt5Vi)c6e4zWW3iIlybdDtPNbvI2u(lYVGobmA0yNzbfUnXluHczgkgoPpkqlfYrxmRiJWL1zFzauH0Gcgkk0tjXQKuGr04cwWq3u6zqLOnL)I8lOtaJgnMHPcMA2(Dq1U5lQjHMCblyOBk9mOs0MYFr(f0jGrJgJOYq(lYJ0aeZSMbbanIIxrgDAqq8mOs0MYFr(f0jWZGHVreZkYOtdcIxglG9PceMFL9hrbKVr0aqP9NqHYWx9U0R5q4UZ(Yi9iQmK)I8inaX(EdOcDtu9t9OkUGfm0nLEgujAt5Vi)c6eWOrJLI0m1S9HGkPxOcfYSIm60GG4HM6tjbAf7Lrbfo8KtzQBr1lyOOqpLeRssUGfm0nLEgujAt5Vi)c6eWOrJruz8lYhM0ZWud6dTLamdfdN0hfOLc5OlMvKrOPkWjCblyOBk9mOs0MYFr(f0jGrJgtNfrZ3SaSmRiJqt1ZwNzk0uho6IlybdDtPNbvI2u(lYVGobmA0yOP(onazWSImcnvpBDMPqtD4itCzubdff6PKyvso0fQ5cwWq3u6zqLOnL)I8lOtaJgno0wc8IQjlZqXWj9rbAPqo6IzMvKrM4UOMugEtnE4Y6SEklNj1poGlRZ(YaOcjupaAQE26mtHM6Wr04cwWq3u6zqLOnL)I8lOtaJgngAQpJcfIlybdDtPNbvI2u(lYVGobmA0yNzbfUnXluHczgkgoPpkqlfYrxmRiJqtD44jhhoniiEgujAt5Vi)c6e4zWW3iIlybdDtPNbvI2u(lYVGobmA0yKPynBFjberz8cvOqM1miaOrum6cFRMWCb47vzr1coWbgd]] )

end