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


    spec:RegisterPet( "xuen_the_white_tiger", 63508, "invoke_xuen", 24 )


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

            tick_time = function () return haste end,

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
                summonPet( "xuen_the_white_tiger", 24 )

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
            id = 137639,
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

            bind = "storm_earth_and_fire_focus",

            auras = {
                -- Conduit
                coordinated_offensive = {
                    id = 336602,
                    duration = 15,
                    max_stack = 1
                }
            }
        },


        storm_earth_and_fire_fixate = {
            id = 221771,
            cast = 0,
            cooldown = 0,
            icd = 1,
            gcd = "spell",

            startsCombat = true,
            texture = 236188,

            notalent = "serenity",
            buff = "storm_earth_and_fire",

            bind = "storm_earth_and_fire_focus",
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
    
    spec:RegisterPack( "Windwalker", 20201220, [[d0uk5bqieP6rGKuBss6tsqgfcLtHq1QajjVIk0Sqe3crYUOQFjbggiXXiflJq1ZuiMgiPUgvuTnfs5BurPghijoNcjwhIuAEub3tb7tcDqjOslKkYdLGQMivuGUivuOnQqQ0hviv1jLGkwji1lPIcOzIif3KkkO2jc5NkKkgkvuqwQcPkpvvnvcLRsffGVsff1yviP9I0FbgmrhwQflrpgQjROlJAZG6ZsQrtQonLvlbLxJOMTQCBc2TOFR0WjKJtffz5Q8CsMUW1PsBxH67iy8sIZtkTEQOK5dI9dzQgQy0)SdMsK4qrCOOrCXHIhkJcud1I7C6p0kIPFrnMCxZ0F2cm97mB5Kq)iZh9lQ1(2EsfJ(vR7Hz6N(lDTxu4K0s6F2btjsCOiou0iU4qXdLrbQHAnqf6xjIXuIeF0gf6x3MtoPL0)Kvy6hQgjDMTCsOFK5djDgEtYiOHQrsNbzmluYhsQbQqcskouehkiOrqdvJKIrGBYi5ORPcfsUWi5OR7PfjTm47Cffi5BRnSN(FMkuuXO)veN8rfJsKgQy0pND5JNuNO)gh2M0pSPcWcdcDgqq3cgewnF0p(SGpRPFSU5f6kijPqsSUHKfhqYrOFSw8JbrFxnhk6xdnOejovm6NZU8XtQt0p(SGpRP)OFCgESUbkDpv45SlF8ejRIKyDZl0vqssHKyDdjloGKJq)noSnPFUIi(b07tGguIgHkg9Zzx(4j1j6VXHTj9hwnFar9tG(XNf8zn9JxHYfOIZiZizvKeRBEHUcsskKeRBizXbKuC6hRf)yq0xnhkkrAObLiOMkg9Zzx(4j1j6hFwWN10pw38cDfKKuijw3qYbKuC6VXHTj9J1naHEmtdkroNkg934W2K(5kI4hqVpb6NZU8XtQt0Gs0OrfJ(5SlF8K6e934W2K(dRMpGO(jq)4Zc(SM(X6MxORGKKcjX6gswCajfN(XAXpge9vZHIsKgAqd6Na3I2ubwyWEt(OIrjsdvm6NZU8XtQt0p(SGpRPFshjJ(Xz4v8XPfA9C2LpEs)noSnPFC)EGgh2MGNPc6)zQaKTat)4jqXW0GsK4uXOFo7YhpPor)4Zc(SM(J(Xz4v8XPfA9C2LpEs)noSnPFC)EGgh2MGNPc6)zQaKTat)4jqXhNwOLguIgHkg9Zzx(4j1j6hFwWN10pw38cDfKKuijw3qYIdiP4izvKKt(Q16dtGbXce6kizrKCe6VXHTj9ZjF1MZYYAa)Sk2rdkrqnvm6NZU8XtQt0FJdBt6)mLL1aLBciByY0pwl(XGOVAouuI0qdkroNkg9Zzx(4j1j6hFwWN10pEfkxGkoJmJKvrYsxyy)Stmdwyaw3kmZ7kI(BCyBs)krwMwwdWxNmGSHjtdkrJgvm6NZU8XtQt0p(SGpRP)gh2ygWjlyScjloGKIJKvrYsxyypbUfTPcSWG9M8biqWFSqBPcjDaj1q)noSnPFytfkWcdGDpT0GsKZMkg9Zzx(4j1j6hFwWN10FJdBmd4KfmwHKfhqsXP)gh2M0pbD7EwwdMxxVjqKBI1PbLiOcvm6NZU8XtQt0p(SGpRPF8kuUavCgzgjRIKnoSXmGtwWyfswCajhbjRIKLUWWEcClAtfyHb7n5dqGG3ve934W2K(vISmTSgGVozazdtMguIgfQy0pND5JNuNO)gh2M0F5RXKx3aq2WKPF8zbFwt)4vOCbQ4mYmswfjBCyJzaNSGXkK0HbKuC6hRf)yq0xnhkkrAObLinqHkg934W2K(jOB3ZYAW866nbICtSo9Zzx(4j1jAqjsJgQy0pND5JNuNOF8zbFwt)LUWWEvSNaG7l0bDobW2XExrizvK8ABc4XCg(EovElrYIijE33CjKEytfkWcdGDpT(P71HTjscvHKqXpA0FJdBt6h2uHcSWay3tl9BzW35kkagm9x6cd7jWTOnvGfgS3KpabcExr0GsKgXPIr)C2LpEsDI(XNf8zn9x6cd7X6gGt(Q16vrJjJKfrYrGcsskK05ijufs24WgZaozbJv0FJdBt6xjYY0YAa(6KbKnmzAqjsZiuXOFo7YhpPor)noSnPFytfGfge6mGGUfmiSA(OF8zbFwt)yDdjDajhH(XAXpge9vZHIsKgAqjsdutfJ(5SlF8K6e9Jpl4ZA6hRBEHUcsskKeRBizXbKud934W2K(5kI4hqVpbAqjsJZPIr)C2LpEsDI(XNf8zn9J1nVqxbjjfsI1nKS4assmKuds6is24WgZaozbJvizrKudssC6VXHTj9J1nqP7PcAqjsZOrfJ(5SlF8K6e934W2K(dRMpGO(jq)4Zc(SM(jgss6iz0podVUfa8kuUEo7Yhprsiqqs8kuUavCgzgjjoswfjX6MxORGKKcjX6gswCajfN(XAXpge9vZHIsKgAqjsJZMkg934W2K(X6gGqpMPFo7YhpPordkrAGkuXOFo7YhpPor)noSnP)YxJjVUbGSHjt)4Zc(SM(X6gswCajhbjHabjlDHH9e4w0MkWcd2BYhGabVRi6hRf)yq0xnhkkrAObLinJcvm63YGVZvuq)AO)gh2M0p8tRL1afFI4maKnmz6NZU8XtQt0Gg0VIpoTqlvmkrAOIr)C2LpEsDI(XNf8zn9x6cd7v8XPfA9hl0wQqshqsn0FJdBt6h2uHcSWay3tlnOejovm6NZU8XtQt0F2cm9BPcFUrx(yGZKBNHRayYJnmt)noSnPFlv4Zn6YhdCMC7mCfatESHzAqjAeQy0pND5JNuNO)Sfy6FECpHTJbJzLIF0FJdBt6FECpHTJbJzLIF0GseutfJ(5SlF8K6e9Jpl4ZA6hVcLlqfNrMrYQijXqYgh2ygWjlyScjloGKJGKqGGKnoSXmGtwWyfswej1GKvrsshjX7(MlH0FMYYAGYnbKnmzVRiKK40FJdBt6xjYY0YAa(6KbKnmzAqjY5uXOFo7YhpPor)noSnP)ZuwwduUjGSHjt)4Zc(SM(XRq5cuXzKz6hRf)yq0xnhkkrAObLOrJkg9Zzx(4j1j6hFwWN10FJdBmd4KfmwHKfhqYrO)gh2M0pSPcfyHbWUNwAqjYztfJ(5SlF8K6e9Jpl4ZA6hVcLlqfNrMrYQizPlmSF2jMblmaRBfM5Dfr)noSnPFLiltlRb4Rtgq2WKPbLiOcvm6NZU8XtQt0FJdBt6V81yYRBaiByY0p(SGpRPF8kuUavCgzgjRIKLUWWEcClAtfyHb7n5dqGG3veswfjX7(MlH0FMYYAGYnbKnmz)XcTLkKSisko9J1IFmi6RMdfLin0Gs0OqfJ(Tm47CffadM(lDHH9k(40cTExrvX7(MlH0FMYYAGYnbKnmz)X9ul934W2K(HnvOalma290s)C2LpEsDIguI0afQy0pND5JNuNOF8zbFwt)4vOCbQ4mYmswfjNCPlmSVCtE6Qcq5Xe8UIO)gh2M0VsKLPL1a81jdiByY0GsKgnuXOFo7YhpPor)noSnPFytfGfge6mGGUfmiSA(OF8zbFwt)yDdjDajhH(XAXpge9vZHIsKgAqjsJ4uXOFo7YhpPor)noSnP)YxJjVUbGSHjt)4Zc(SM(XRq5cuXzKzKeceKK0rYOFCgEDla4vOC9C2LpEs)yT4hdI(Q5qrjsdnOePzeQy0FJdBt6xjYY0YAa(6KbKnmz6NZU8XtQt0Gg0pEcu8XPfAPIrjsdvm6NZU8XtQt0)kI(vCq)noSnP)X9zD5JP)X9ZLPF8UV5si9k(40cT(JfAlviPdiPgKeceKueh(kUCccDgqq3cgewnF(gh2ygjRIK4DFZLq6v8XPfA9hl0wQqYIi5iqbjHabjHTA9aCSqBPcjDajfhk0)4(azlW0VIpoTqlO09ubnOejovm6NZU8XtQt0p(SGpRPFshjh3N1Lp2RVVjOIlNijeiijSvRhGJfAlviPdiP4oN(BCyBs)woEjZGkUCsdkrJqfJ(5SlF8K6e9NTat)TsFCNScCTZApaEV(r)noSnP)wPpUtwbU2zThaVx)ObLiOMkg934W2K(DvmWcwqr)C2LpEsDIguICovm6NZU8XtQt0p(SGpRPFSU5f6kijPqsSUHKfhqsn0FJdBt6VpCNmi274mObLOrJkg934W2K(FwTEOafM7SwGZG(5SlF8K6enOe5SPIr)C2LpEsDI(XNf8zn9pUpRlFSxXhNwOfu6EQG(BCyBs)W2XLVDN0GseuHkg9Zzx(4j1j6hFwWN10)4(SU8XEfFCAHwqP7Pc6VXHTj93jMvX1paUFpAqjAuOIr)C2LpEsDI(XNf8zn9pUpRlFSxXhNwOfu6EQG(BCyBs)LDnyHbXzyYkAqjsduOIr)C2LpEsDI(XNf8zn9dB16b4yH2sfswej1avGcscbcskIdFfxobHodiOBbdcRMpFJdBmJKqGGKWwTEaowOTuHKoGKAGc934W2K(J1fRdwyWK7qNguI0OHkg9Zzx(4j1j6hFwWN10pSvRhGJfAlvizrKCuGcscbcskIdFfxobHodiOBbdcRMpFJdBmJKqGGKWwTEaowOTuHKoGKAGc934W2K(J1fRdwya5(eAAqjsJ4uXOFo7YhpPor)4Zc(SM(X7(MlH0FMYYAGYnbKnmz)XcTLkK0bKKRWy3GbHjW0FJdBt6Na3I2ubwyWEt(ObLinJqfJ(BCyBs)Wn)SKbQyfer)C2LpEsDIguI0a1uXO)gh2M0pC)ECc2BYh9Zzx(4j1jAqjsJZPIr)noSnP)Yn5PRkaLhtG(5SlF8K6enOePz0OIr)C2LpEsDI(XNf8zn9J39nxcP)mLL1aLBciByY(JfAlviPdiP4ijeiijSvRhGJfAlviPdiPgNt)noSnPFfFCAHwAqjsJZMkg934W2K(l7AWcdIZWKv0pND5JNuNObnOFvqfJsKgQy0pND5JNuNOF8zbFwt)xBtapMZW3ZPYBjswejX7(MlH0tq3UNL1G511Bce5MyD)096W2ejHQqsO4Hkijeii512eWJ5m89CQ8UIO)gh2M0pbD7EwwdMxxVjqKBI1PbLiXPIr)C2LpEsDI(XNf8zn9J1nVqxbjjfsI1nKS4askoswfj5KVAT(WeyqSaHUcswejhbjHabjX6MxORGKKcjX6gswCajHAKSkssmKKt(Q16dtGbXce6kizrKuCKeceKK0rsrhpguJNEn(WQ5diQFcijXP)gh2M0pN8vBollRb8ZQyhnOencvm6NZU8XtQt0p(SGpRPF8kuUavCgzgjRIKLUWW(zNygSWaSUvyM3veswfjjgsETnb8yodFpNkVLizrKS0fg2p7eZGfgG1TcZ8hl0wQqssHKIJKqGGKxBtapMZW3ZPY7kcjjo934W2K(vISmTSgGVozazdtMguIGAQy0pND5JNuNO)gh2M0)zklRbk3eq2WKPF8zbFwt)4DFZLq6v8XPfA9hl0wQqYIiPgKeceKK0rYOFCgEfFCAHwpND5JN0pwl(XGOVAouuI0qdkroNkg9Zzx(4j1j6hFwWN10pXqYRTjGhZz475u5TejlIK4DFZLq6HnvOalma2906NUxh2MijufscfpubjHabjV2MaEmNHVNtL3vessCKSkssmKKt(Q16dtGbXce6kizrKKRWy3GbHjWijPqsnijeiijw38cDfKKuijw3qshgqsnijeiizPlmSxf7ja4(cDqNtaSDS)yH2sfs6asYvySBWGWeyK0rKudssCKeceKe2Q1dWXcTLkK0bKKRWy3GbHjWiPJiPg6VXHTj9dBQqbwyaS7PLguIgnQy0pND5JNuNOF8zbFwt)LUWW(qNbSGi(2tbWTOgBXEEv0yYizrKuZOGKvrso5RwRpmbgelqORGKfrsUcJDdgeMaJKKcj1GKvrs8UV5si9NPSSgOCtazdt2FSqBPcjlIKCfg7gmimbgjHabjlDHH9Hodybr8TNcGBrn2I98QOXKrYIiPgOgjRIKedjX7(MlH0R4Jtl06pwOTuHKoGKohjRIKr)4m8k(40cTEo7Yhprsiqqs8UV5si9e4w0MkWcd2BYN)yH2sfs6as6CKSksI3XC2z4jR9SorsiqqsyRwpahl0wQqshqsNJKeN(BCyBs)4RXKFwwdkSEYGNvRhPL10GsKZMkg9Zzx(4j1j6hFwWN10FPlmS)Cv6wwdkSEYacwo9ZLqIKvrYgh2ygWjlyScjlIKAO)gh2M0)5Q0TSguy9KbeSCsdkrqfQy0pND5JNuNO)gh2M0pSPcWcdcDgqq3cgewnF0p(SGpRPFSUHKoGKJq)yT4hdI(Q5qrjsdnOenkuXOFo7YhpPor)4Zc(SM(X6MxORGKKcjX6gswCaj1q)noSnPFUIi(b07tGguI0afQy0pND5JNuNOF8zbFwt)yDZl0vqssHKyDdjloGKAqYQizJdBmd4KfmwHKdiPgKSksETnb8yodFpNkVLizrKuCOGKqGGKyDZl0vqssHKyDdjloGKIJKvrYgh2ygWjlyScjloGKIt)noSnPFSUbkDpvqdkrA0qfJ(BCyBs)yDdqOhZ0pND5JNuNObLinItfJ(5SlF8K6e934W2K(dRMpGO(jq)4Zc(SM(XRq5cuXzKzKSksI1nVqxbjjfsI1nKS4askoswfjlDHH9Qypba3xOd6CcGTJ9ZLqs)yT4hdI(Q5qrjsdnOePzeQy0pND5JNuNOF8zbFwt)LUWWESUb4KVATEv0yYizrKCeOGKKcjDoscvHKnoSXmGtwWyfswfjlDHH9Qypba3xOd6CcGTJ9ZLqIKvrsIHK4DFZLq6ptzznq5MaYgMS)yH2sfswejfhjRIK4DFZLq6HnvOalma2906pwOTuHKfrsXrsiqqs8UV5si9NPSSgOCtazdt2FSqBPcjDajhbjRIK4DFZLq6HnvOalma2906pwOTuHKfrYrqYQijw3qYIi5iijeiijE33CjK(ZuwwduUjGSHj7pwOTuHKfrYrqYQijE33CjKEytfkWcdGDpT(JfAlviPdi5iizvKeRBizrKeQrsiqqsSU5f6kijPqsSUHKomGKAqYQijN8vR1hMadIfi0vqshqsXrsIJKqGGKLUWWESUb4KVATEv0yYizrKuduqYQijSvRhGJfAlviPdiPZM(BCyBs)krwMwwdWxNmGSHjtdkrAGAQy0pND5JNuNO)gh2M0F5RXKx3aq2WKPF8zbFwt)4vOCbQ4mYmswfjjgsg9JZWR4Jtl065SlF8ejRIK4DFZLq6v8XPfA9hl0wQqshqYrqsiqqs8UV5si9NPSSgOCtazdt2FSqBPcjlIKAqYQijE33CjKEytfkWcdGDpT(JfAlvizrKudscbcsI39nxcP)mLL1aLBciByY(JfAlviPdi5iizvKeV7BUespSPcfyHbWUNw)XcTLkKSisocswfjX6gswejfhjHabjX7(MlH0FMYYAGYnbKnmz)XcTLkKSisocswfjX7(MlH0dBQqbwyaS7P1FSqBPcjDajhbjRIKyDdjlIKJGKqGGKyDdjlIKohjHabjlDHH9LlzGOBXExrijXPFSw8JbrF1COOePHguI04CQy0pND5JNuNO)gh2M0Fy18be1pb6hFwWN10pEfkxGkoJmJKvrsSU5f6kijPqsSUHKfhqsXPFSw8JbrF1COOePHguI0mAuXOFld(oxrb9RH(BCyBs)WpTwwdu8jIZaq2WKPFo7YhpPordkrAC2uXOFo7YhpPor)noSnP)YxJjVUbGSHjt)4Zc(SM(XRq5cuXzKzKSksI39nxcPh2uHcSWay3tR)yH2sfs6asocswfjX6gsoGKIJKvrsrhpguJNEn(WQ5diQFcizvKKt(Q16dtGbXcCouqshqsn0pwl(XGOVAouuI0qdkrAGkuXOFo7YhpPor)noSnP)YxJjVUbGSHjt)4Zc(SM(XRq5cuXzKzKSksYjF1A9HjWGybcDfK0bKuCKSkssmKeRBEHUcsskKeRBiPddiPgKeceKu0XJb14PxJpSA(aI6NassC6hRf)yq0xnhkkrAObnOF8eOyyQyuI0qfJ(5SlF8K6e9Jpl4ZA6N0rYX9zD5J967BcQ4YjscbcscB16b4yH2sfs6askUZP)gh2M0VLJxYmOIlN0GsK4uXOFo7YhpPor)4Zc(SM(X6MxORGKKcjX6gswCaj1q)noSnP)(WDYGyVJZGguIgHkg9Zzx(4j1j6hFwWN10FPlmSxf7ja4(cDqNtaSDSFUesKSkskIdFfxobHodiOBbdcRMpFJdBmJKqGGKWwTEaowOTuHKoGKAGcscbcscB16b4yH2sfswej1avGc934W2K(J1fRdwyWK7qNguIGAQy0pND5JNuNOF8zbFwt)edjV2MaEmNHVNtL3sKSisc1ohjHabjV2MaEmNHVNtL3vessCKSksI39nxcP)mLL1aLBciByY(JfAlviPdijxHXUbdctGP)gh2M0pbUfTPcSWG9M8rdkroNkg9Zzx(4j1j6hFwWN10pEfkxGkoJmJKvrsIHKxBtapMZW3ZPYBjswej1afKeceK8ABc4XCg(EovExrijXP)gh2M0pCZplzGkwbr0Gs0OrfJ(5SlF8K6e9Jpl4ZA6)ABc4XCg(EovElrYIi5iqbjHabjV2MaEmNHVNtL3ve934W2K(H73JtWEt(ObLiNnvm6NZU8XtQt0p(SGpRP)RTjGhZz475u5TejlIKohkijeii512eWJ5m89CQ8UIO)gh2M0F5M80vfGYJjq)plzaEs)JguObLiOcvm6NZU8XtQt0p(SGpRPF8UV5si9Qypba3xOd6CcGTJ9y9(QzfsoGKIJKqGGKWwTEaowOTuHKoGKIdfKeceKKyi512eWJ5m89CQ8hl0wQqYIiPgNJKqGGKKosI3XC2z4jR9SorYQijXqsIHKxBtapMZW3ZPYBjswejX7(MlH0RI9eaCFHoOZja2o2d7(EGJX69vZGWeyKeceKK0rYRTjGhZz475u55kMkuijXrYQijXqs8UV5si9woEjZGkUCccDgqq3cgewnF(JfAlvizrKeV7BUesVk2taW9f6GoNay7ypS77bogR3xndctGrsiqqYX9zD5J967BcQ4YjssCKK4izvKeV7BUespSPcfyHbWUNw)XcTLkK0HbKCuqYQijw3qYIdiP4izvKeV7BUespbD7EwwdMxxVjqKBI19hl0wQqshgqsnIJKeN(BCyBs)Qypba3xOd6CcGTJPbLOrHkg9Zzx(4j1j6hFwWN10pEhZzNHNS2Z6ejRIKedjlDHH9e4w0MkWcd2BYN3vescbcssmKe2Q1dWXcTLkK0bKeV7BUespbUfTPcSWG9M85pwOTuHKqGGK4DFZLq6jWTOnvGfgS3Kp)XcTLkKSisI39nxcPxf7ja4(cDqNtaSDSh299ahJ17RMbHjWijXrYQijE33CjKEytfkWcdGDpT(JfAlviPddi5OGKvrsSUHKfhqsXrYQijE33CjKEc629SSgmVUEtGi3eR7pwOTuHKomGKAehjjo934W2K(vXEcaUVqh05eaBhtdkrAGcvm6NZU8XtQt0p(SGpRPF8UV5si9Qypba3xOd6CcGTJ9y9(QzfsoGKIJKqGGKWwTEaowOTuHKoGKIdfKeceKS0fg2Ryo0TSgCDn7DfHKqGGKedjX7(MlH0x(2DcwyqOZaozbT(JfAlviPJiPgKSisI39nxcPxf7ja4(cDqNtaSDSh299ahJ17RMbHjWijeiijPJKSsXjM9LVDNGfge6mGtwqRxOlS9qsIJKvrs8UV5si9WMkuGfga7EA9hl0wQqshqsnqbjRIKyDdjloGKIJKvrs8UV5si9e0T7zznyED9MarUjw3FSqBPcjDaj1io934W2K(vXEcaUVqh05eaBhtdkrA0qfJ(5SlF8K6e9NTat)TsFCNScCTZApaEV(r)noSnP)wPpUtwbU2zThaVx)ObLinItfJ(BCyBs)UkgyblOOFo7YhpPordkrAgHkg9Zzx(4j1j6hFwWN10pSvRhGJfAlvizrKuJZhfKeceKueh(kUCccDgqq3cgewnF(gh2ygjHabjh3N1Lp2RVVjOIlN0FJdBt6pwxSoyHbK7tOPbLinqnvm6NZU8XtQt0p(SGpRPF8UV5si9woEjZGkUCccDgqq3cgewnF(JfAlvizrKCeOGKqGGKJ7Z6Yh7133euXLtKeceKe2Q1dWXcTLkK0bKuCOq)noSnP)Y3UtaS7PLguI04CQy0pND5JNuNOF8zbFwt)4DFZLq6TC8sMbvC5ee6mGGUfmiSA(8hl0wQqYIi5iqbjHabjh3N1Lp2RVVjOIlNijeiijSvRhGJfAlviPdiPgNt)noSnP)s(u8r2YAAqjsZOrfJ(BCyBs)pRwpuGcZDwlWzq)C2LpEsDIguI04SPIr)C2LpEsDI(XNf8zn9J39nxcP3YXlzguXLtqOZac6wWGWQ5ZFSqBPcjlIKJafKeceKCCFwx(yV((MGkUCIKqGGKWwTEaowOTuHKoGKAGc934W2K(HTJlF7oPbLinqfQy0pND5JNuNOF8zbFwt)4DFZLq6TC8sMbvC5ee6mGGUfmiSA(8hl0wQqYIi5iqbjHabjh3N1Lp2RVVjOIlNijeiijSvRhGJfAlviPdiP4qH(BCyBs)DIzvC9dG73JguI0mkuXOFo7YhpPor)4Zc(SM(lDHH9Qypba3xOd6CcGTJ9ZLqs)noSnP)YUgSWG4mmzfnOb9pz429fuXOePHkg934W2K(vI4(a6DobQ4mYm9Zzx(4j1jAqjsCQy0pND5JNuNO)ve9R4G(BCyBs)J7Z6Yht)J7Nlt)4DFZLq6TC8sMbvC5ee6mGGUfmiSA(8hl0wQqYIijSvRhGJfAlvijeiijSvRhGJfAlviPdiPgXHcswfjHTA9aCSqBPcjlIK4DFZLq6v8XPfA9hl0wQqYQijE33CjKEfFCAHw)XcTLkKSisQbk0)4(azlW0V((MGkUCsdkrJqfJ(5SlF8K6e9Jpl4ZA6NyizPlmSxXhNwO17kcjHabjlDHH9Qypba3xOd6CcGTJ9UIqsIJKvrsrC4R4Yji0zabDlyqy185BCyJzKeceKe2Q1dWXcTLkK0HbKC0Gc934W2K(fTHTjnOeb1uXOFo7YhpPor)4Zc(SM(lDHH9k(40cTExr0FJdBt6h3VhOXHTj4zQG(FMkazlW0VIpoTqlnOe5CQy0pND5JNuNOF8zbFwt)LUWWEcClAtfyHb7n5Z7kI(BCyBs)4(9anoSnbptf0)ZubiBbM(jWTOnvGfgS3KpAqjA0OIr)C2LpEsDI(XNf8zn9hMaJKoGKqnswfjX6gs6as6CKSkss6iPio8vC5ee6mGGUfmiSA(8noSXm934W2K(X97bACyBcEMkO)NPcq2cm9VI4KpAqjYztfJ(5SlF8K6e934W2K(HnvawyqOZac6wWGWQ5J(XNf8zn9J1nVqxbjjfsI1nKS4asocswfjjgsYjF1A9HjWGybcDfK0bKudscbcsYjF1A9HjWGybcDfK0bKeQrYQijE33CjKEytfkWcdGDpT(JfAlviPdiPgVZrsiqqs8UV5si9e4w0MkWcd2BYN)yH2sfs6askossC6hRf)yq0xnhkkrAObLiOcvm6NZU8XtQt0p(SGpRPFSU5f6kijPqsSUHKfhqsnizvKKyijN8vR1hMadIfi0vqshqsnijeiijE33CjKEfFCAHw)XcTLkK0bKuCKeceKKt(Q16dtGbXce6kiPdijuJKvrs8UV5si9WMkuGfga7EA9hl0wQqshqsnENJKqGGK4DFZLq6jWTOnvGfgS3Kp)XcTLkK0bKuCKK40FJdBt6NRiIFa9(eObLOrHkg9Zzx(4j1j6VXHTj9hwnFar9tG(XNf8zn9JxHYfOIZiZizvKeRBEHUcsskKeRBizXbKuCKSkssmKKt(Q16dtGbXce6kiPdiPgKeceKeV7BUesVIpoTqR)yH2sfs6askoscbcsYjF1A9HjWGybcDfK0bKeQrYQijE33CjKEytfkWcdGDpT(JfAlviPdiPgVZrsiqqs8UV5si9e4w0MkWcd2BYN)yH2sfs6askossC6hRf)yq0xnhkkrAObLinqHkg9Zzx(4j1j6hFwWN10pPJKr)4m8k(40cTEo7YhpP)gh2M0pUFpqJdBtWZub9)mvaYwGPF8eOyyAqjsJgQy0pND5JNuNOF8zbFwt)r)4m8k(40cTEo7YhpP)gh2M0pUFpqJdBtWZub9)mvaYwGPF8eO4Jtl0sdkrAeNkg9Zzx(4j1j6hFwWN10FJdBmd4KfmwHKoGKJq)noSnPFC)EGgh2MGNPc6)zQaKTat)QGguI0mcvm6NZU8XtQt0p(SGpRP)gh2ygWjlyScjloGKJq)noSnPFC)EGgh2MGNPc6)zQaKTat)9Y0Gg0VOJXRqzhuXOePHkg934W2K(fTHTj9Zzx(4j1jAqjsCQy0FJdBt6VCJ4Xta8R1YtcwwdITIL0pND5JNuNObLOrOIr)C2LpEsDI(xr0VId6VXHTj9pUpRlFm9pUFUm9df6FCFGSfy6VIlNGnbUkgeNLK5GguIGAQy0pND5JNuNOF8zbFwt)Kosg9JZWR4Jtl065SlF8ejHabjjDKm6hNHh2ubyHbHodiOBbdcRMppND5JN0FJdBt6hRBGs3tf0GsKZPIr)C2LpEsDI(XNf8zn9t6iz0podpN8vBollRb8ZQWNNZU8Xt6VXHTj9J1naHEmtdAq)9YuXOePHkg934W2K(jOB3ZYAW866nbICtSo9Zzx(4j1jAqjsCQy0pND5JNuNOF8zbFwt)yDZl0vqssHKyDdjloGKIJKvrso5RwRpmbgelqORGKfrsXrsiqqsSU5f6kijPqsSUHKfhqsOM(BCyBs)CYxT5SSSgWpRID0Gs0iuXOFo7YhpPor)4Zc(SM(XRq5cuXzKzKSkssmKS0fg2p7eZGfgG1TcZ8UIqsiqqYjx6cd7l3KNUQauEmbVRiKK40FJdBt6xjYY0YAa(6KbKnmzAqjcQPIr)C2LpEsDI(XNf8zn9ZjF1A9HjWGybcDfKSisYvySBWGWeyKeceKeRBEHUcsskKeRBiPddiPg6VXHTj9dBQqbwyaS7PLguICovm6NZU8XtQt0FJdBt6)mLL1aLBciByY0p(SGpRPFIHKr)4m8e0T7zznyED9MarUjw3Zzx(4jswfjX7(MlH0FMYYAGYnbKnmz)096W2ejlIK4DFZLq6jOB3ZYAW866nbICtSU)yH2sfs6isc1ijXrYQijXqs8UV5si9WMkuGfga7EA9hl0wQqYIi5iijeiijw3qYIdiPZrsIt)yT4hdI(Q5qrjsdnOenAuXOFo7YhpPor)4Zc(SM(lDHH9NRs3YAqH1tgqWYPFUes6VXHTj9FUkDlRbfwpzablN0GsKZMkg9Zzx(4j1j6hFwWN10pEfkxGkoJmJKvrsIHKedjX7(MlH0xUjpDvbO8yc(JfAlvizrKuCKSkssmKeRBizrKCeKeceKeV7BUespSPcfyHbWUNw)XcTLkKSisoAijXrYQijXqsSUHKfhqsNJKqGGK4DFZLq6HnvOalma2906pwOTuHKfrsXrsIJKehjHabj5KVAT(WeyqSaHUcs6WasocssC6VXHTj9RezzAznaFDYaYgMmnOebvOIr)C2LpEsDI(XNf8zn9J1nVqxbjjfsI1nKS4asQH(BCyBs)Cfr8dO3NanOenkuXOFo7YhpPor)noSnPFytfGfge6mGGUfmiSA(OF8zbFwt)yDZl0vqssHKyDdjloGKJq)yT4hdI(Q5qrjsdnOePbkuXOFo7YhpPor)4Zc(SM(X6MxORGKKcjX6gswCajfN(BCyBs)yDdu6EQGguI0OHkg9Zzx(4j1j6hFwWN10FPlmSp0zaliIV9uaClQXwSNxfnMmswej1mkizvKKt(Q16dtGbXce6kizrKKRWy3GbHjWijPqsnizvKeV7BUespSPcfyHbWUNw)XcTLkKSisYvySBWGWey6VXHTj9JVgt(zznOW6jdEwTEKwwtdkrAeNkg9Zzx(4j1j6VXHTj9hwnFar9tG(XNf8zn9J1nVqxbjjfsI1nKS4askoswfjjgss6iz0podVUfa8kuUEo7Yhprsiqqs8kuUavCgzgjjo9J1IFmi6RMdfLin0GsKMrOIr)C2LpEsDI(XNf8zn9JxHYfOIZiZ0FJdBt6hRBac9yMguI0a1uXOFo7YhpPor)noSnPF4NwlRbk(eXzaiByY0p(SGpRP)sxyyF5sgi6wSFUes63YGVZvuq)AObLinoNkg9Zzx(4j1j6VXHTj9x(Am51naKnmz6hFwWN10pEfkxGkoJmJKvrsIHKLUWW(YLmq0TyVRiKeceKm6hNHx3caEfkxpND5JNizvKu0XJb14PxJpSA(aI6NaswfjX6gsoGKIJKvrs8UV5si9WMkuGfga7EA9hl0wQqshqYrqsiqqsSU5f6kijPqsSUHKomGKAqYQiPOJhdQXtVgVsKLPL1a81jdiByYizvKKt(Q16dtGbXce6kiPdi5iijXPFSw8JbrF1COOePHg0Gg0)y(u2MuIehkIdfnIRXz7fN(j0xAzTI(DMlCh9iQWHOrFslsIKIPZiPjiAVajH3djlebUfTPcSWG9M8viK8yNjx74jsQwbgjB3yf6GNijwVZAw5rqtASKrsnKwKSWV5y(cEIKfk6hNHFulesglswOOFCg(r1Zzx(4zHqYoqsNXrhsdssmnviUhbnPXsgjfN0IKf(nhZxWtKSqr)4m8JAHqYyrYcf9JZWpQEo7Yhples2bs6mo6qAqsIPPcX9iOjnwYiPMrJ0IKf(nhZxWtKSqr)4m8JAHqYyrYcf9JZWpQEo7YhplessmnviUhbncAN5c3rpIkCiA0N0IKiPy6msAcI2lqs49qYcP4Jtl0wiK8yNjx74jsQwbgjB3yf6GNijwVZAw5rqtASKrsnItArYc)MJ5l4jswOOFCg(rTqizSizHI(Xz4hvpND5JNfcj7ajDghDinijX0uH4Ee0iODMlCh9iQWHOrFslsIKIPZiPjiAVajH3djlKkkesESZKRD8ejvRaJKTBScDWtKeR3znR8iOjnwYijutArYc)MJ5l4jswOOFCg(rTqizSizHI(Xz4hvpND5JNfcj7ajDghDinijX0uH4Ee0KglzKC0iTizHFZX8f8ejlu0pod)OwiKmwKSqr)4m8JQNZU8XZcHKettfI7rqtASKrsnqnPfjl8BoMVGNizHI(Xz4h1cHKXIKfk6hNHFu9C2LpEwiKKyAQqCpcAe0oZfUJEev4q0OpPfjrsX0zK0eeTxGKW7HKfAYWT7lkesESZKRD8ejvRaJKTBScDWtKeR3znR8iOjnwYiPgOqArYc)MJ5l4jswOOFCg(rTqizSizHI(Xz4hvpND5JNfcj7ajDghDinijX0uH4Ee0KglzKuJgslsw43CmFbprYcf9JZWpQfcjJfjlu0pod)O65SlF8SqizhiPZ4OdPbjjMMke3JGgbTZCH7Ohrfoen6tArsKumDgjnbr7fij8EizH6LlesESZKRD8ejvRaJKTBScDWtKeR3znR8iOjnwYiPZjTizHFZX8f8ejlu0pod)OwiKmwKSqr)4m8JQNZU8XZcHKettfI7rqtASKrsnItArYc)MJ5l4jswOOFCg(rTqizSizHI(Xz4hvpND5JNfcjjMMke3JGM0yjJKACoPfjl8BoMVGNizHI(Xz4h1cHKXIKfk6hNHFu9C2LpEwiKKyAQqCpcAe0focI2l4jsokizJdBtK8zQq5rqt)IUf2Em9dvJKoZwoj0pY8HKodVjze0q1iPZGmMfk5dj1avibjfhkIdfe0iOHQrsXiWnzKC01uHcjxyKC0190IKwg8DUIcK8T1g2JGgbnuns6mwHXUbprYsgEpgjXRqzhizjxBPYJKfUymlkuizUjP07ta29HKnoSnvi5MpTEe0noSnvErhJxHYogeTHTjc6gh2MkVOJXRqzhoouq5gXJNa4xRLNeSSgeBflrq34W2u5fDmEfk7WXHcg3N1LpMKSf4HkUCc2e4QyqCwsMdswrdkoizC)C5bOGGUXHTPYl6y8ku2HJdfG1nqP7Pcsm4bsp6hNHxXhNwO1Zzx(4jeiKE0podpSPcWcdcDgqq3cgewnFEo7Yhprq34W2u5fDmEfk7WXHcW6gGqpMjXGhi9OFCgEo5R2Cwwwd4NvHppND5JNiOrqdvJKoJvySBWtKKhZNwKmmbgjdDgjBCShsAkKSh32RlFShbDJdBt1Gse3hqVZjqfNrMrq34W2u54qbJ7Z6Yhts2c8G((MGkUCsYkAqXbjJ7NlpG39nxcP3YXlzguXLtqOZac6wWGWQ5ZFSqBPQiSvRhGJfAlvqGaB16b4yH2sLdAehkvHTA9aCSqBPQiE33CjKEfFCAHw)XcTLQQ4DFZLq6v8XPfA9hl0wQkQbkiOBCyBQCCOarByBsIbpqSsxyyVIpoTqR3veeiLUWWEvSNaG7l0bDobW2XExreVQio8vC5ee6mGGUfmiSA(8noSXmeiWwTEaowOTu5WWObfe0noSnvoouaUFpqJdBtWZubjzlWdk(40cTKyWdLUWWEfFCAHwVRie0noSnvoouaUFpqJdBtWZubjzlWde4w0MkWcd2BYhjg8qPlmSNa3I2ubwyWEt(8UIqq34W2u54qb4(9anoSnbptfKKTapSI4Kpsm4HWeyhG6QyDZbNxL0fXHVIlNGqNbe0TGbHvZNVXHnMrq34W2u54qbWMkalmi0zabDlyqy18rcwl(XGOVAoudAiXGhW6MxORqkSUvCyKQeJt(Q16dtGbXce6koObceo5RwRpmbgelqOR4auxfV7BUespSPcfyHbWUNw)XcTLkh04Doei4DFZLq6jWTOnvGfgS3Kp)XcTLkheN4iOBCyBQCCOaUIi(b07tGedEaRBEHUcPW6wXbnvjgN8vR1hMadIfi0vCqdei4DFZLq6v8XPfA9hl0wQCqCiq4KVAT(WeyqSaHUIdqDv8UV5si9WMkuGfga7EA9hl0wQCqJ35qGG39nxcPNa3I2ubwyWEt(8hl0wQCqCIJGUXHTPYXHccRMpGO(jqcwl(XGOVAoudAiXGhWRq5cuXzK5QyDZl0vifw3koiEvIXjF1A9HjWGybcDfh0abcE33CjKEfFCAHw)XcTLkhehceo5RwRpmbgelqOR4auxfV7BUespSPcfyHbWUNw)XcTLkh04Doei4DFZLq6jWTOnvGfgS3Kp)XcTLkheN4iOBCyBQCCOaC)EGgh2MGNPcsYwGhWtGIHjXGhi9OFCgEfFCAHwe0noSnvoouaUFpqJdBtWZubjzlWd4jqXhNwOLedEi6hNHxXhNwOfbDJdBtLJdfG73d04W2e8mvqs2c8GkiXGhACyJzaNSGXkhgbbDJdBtLJdfG73d04W2e8mvqs2c8qVmjg8qJdBmd4KfmwvCyee0iOBCyBQ89Yde0T7zznyED9MarUjwhbDJdBtLVx2XHc4KVAZzzznGFwf7iXGhW6MxORqkSUvCq8QCYxTwFycmiwGqxPO4qGG1nVqxHuyDR4auJGUXHTPY3l74qbkrwMwwdWxNmGSHjtIbpGxHYfOIZiZvjwPlmSF2jMblmaRBfM5DfbbYKlDHH9LBYtxvakpMG3veXrq34W2u57LDCOaytfkWcdGDpTKyWdCYxTwFycmiwGqxPixHXUbdctGHabRBEHUcPW6MddAqq34W2u57LDCOGZuwwduUjGSHjtcwl(XGOVAoudAiXGhiw0podpbD7EwwdMxxVjqKBI1RI39nxcP)mLL1aLBciByY(P71HTzr8UV5si9e0T7zznyED9MarUjw3FSqBPYrOM4vjgE33CjKEytfkWcdGDpT(JfAlvfhbceSUvCW5ehbDJdBtLVx2XHcoxLUL1GcRNmGGLtsm4Hsxyy)5Q0TSguy9KbeSC6NlHebDJdBtLVx2XHcuISmTSgGVozazdtMedEaVcLlqfNrMRsmIH39nxcPVCtE6Qcq5Xe8hl0wQkkEvIH1TIJabcE33CjKEytfkWcdGDpT(JfAlvfhnIxLyyDR4GZHabV7BUespSPcfyHbWUNw)XcTLQIItCIdbcN8vR1hMadIfi0vCyyeIJGUXHTPY3l74qbCfr8dO3Najg8aw38cDfsH1TIdAqq34W2u57LDCOaytfGfge6mGGUfmiSA(ibRf)yq0xnhQbnKyWdyDZl0vifw3komcc6gh2MkFVSJdfG1nqP7Pcsm4bSU5f6kKcRBfhehbDJdBtLVx2XHcWxJj)SSguy9KbpRwpslRjXGhkDHH9Hodybr8TNcGBrn2I98QOXKlQzuQYjF1A9HjWGybcDLICfg7gmimbMuAQI39nxcPh2uHcSWay3tR)yH2svrUcJDdgeMaJGUXHTPY3l74qbHvZhqu)eibRf)yq0xnhQbnKyWdyDZl0vifw3koiEvIr6r)4m86waWRq5cbcEfkxGkoJmtCe0noSnv(EzhhkaRBac9yMedEaVcLlqfNrMrq34W2u57LDCOa4NwlRbk(eXzaiByYKyWdLUWW(YLmq0Ty)CjKKyzW35kkg0GGUXHTPY3l74qbLVgtEDdazdtMeSw8JbrF1COg0qIbpGxHYfOIZiZvjwPlmSVCjdeDl27kccKOFCgEDla4vOCRk64XGA80RXhwnFar9tOkw3geVkE33CjKEytfkWcdGDpT(JfAlvomceiyDZl0vifw3CyqtvrhpguJNEnELiltlRb4Rtgq2WKRYjF1A9HjWGybcDfhgH4iOrq34W2u5XtGIHhSC8sMbvC5ee6mGGUfmiSA(iXGhi9X9zD5J967BcQ4YjeiWwTEaowOTu5G4ohbDJdBtLhpbkg2XHc6d3jdI9oodsm4bSU5f6kKcRBfh0GGUXHTPYJNafd74qbX6I1blmyYDOtIbpu6cd7vXEcaUVqh05eaBh7NlHSQio8vC5ee6mGGUfmiSA(8noSXmeiWwTEaowOTu5GgOabcSvRhGJfAlvf1avGcc6gh2MkpEcumSJdfqGBrBQalmyVjFKyWde7ABc4XCg(EovEllc1ohcKRTjGhZz475u5Dfr8Q4DFZLq6ptzznq5MaYgMS)yH2sLdCfg7gmimbgbDJdBtLhpbkg2XHcGB(zjduXkiIedEaVcLlqfNrMRsSRTjGhZz475u5TSOgOabY12eWJ5m89CQ8UIioc6gh2MkpEcumSJdfa3VhNG9M8rIbpCTnb8yodFpNkVLfhbkqGCTnb8yodFpNkVRie0noSnvE8eOyyhhkOCtE6Qcq5XeiXGhU2MaEmNHVNtL3YIohkqGCTnb8yodFpNkVRisEwYa8Cy0Gcc6gh2MkpEcumSJdfOI9eaCFHoOZja2oMedEaV7BUesVk2taW9f6GoNay7ypwVVAwnioeiWwTEaowOTu5G4qbceIDTnb8yodFpNk)XcTLQIACoeiKoEhZzNHNS2Z6SkXi212eWJ5m89CQ8wweV7BUesVk2taW9f6GoNay7ypS77bogR3xndctGHaH0V2MaEmNHVNtLNRyQqr8QedV7BUesVLJxYmOIlNGqNbe0TGbHvZN)yH2svr8UV5si9Qypba3xOd6CcGTJ9WUVh4ySEF1mimbgcKX9zD5J967BcQ4YjXjEv8UV5si9WMkuGfga7EA9hl0wQCyyuQI1TIdIxfV7BUespbD7EwwdMxxVjqKBI19hl0wQCyqJ4ehbDJdBtLhpbkg2XHcuXEcaUVqh05eaBhtIbpG3XC2z4jR9SoRsSsxyypbUfTPcSWG9M85DfbbcXGTA9aCSqBPYb8UV5si9e4w0MkWcd2BYN)yH2sfei4DFZLq6jWTOnvGfgS3Kp)XcTLQI4DFZLq6vXEcaUVqh05eaBh7HDFpWXy9(QzqycmXRI39nxcPh2uHcSWay3tR)yH2sLddJsvSUvCq8Q4DFZLq6jOB3ZYAW866nbICtSU)yH2sLddAeN4iOBCyBQ84jqXWoouGk2taW9f6GoNay7ysm4b8UV5si9Qypba3xOd6CcGTJ9y9(Qz1G4qGaB16b4yH2sLdIdfiqkDHH9kMdDlRbxxZExrqGqm8UV5si9LVDNGfge6mGtwqR)yH2sLJAkI39nxcPxf7ja4(cDqNtaSDSh299ahJ17RMbHjWqGq6SsXjM9LVDNGfge6mGtwqRxOlS9iEv8UV5si9WMkuGfga7EA9hl0wQCqduQI1TIdIxfV7BUespbD7EwwdMxxVjqKBI19hl0wQCqJ4iOBCyBQ84jqXWoouGRIbwWcKKTap0k9XDYkW1oR9a496hc6gh2MkpEcumSJdf4QyGfSGcbDJdBtLhpbkg2XHcI1fRdwya5(eAsm4byRwpahl0wQkQX5JceiI4WxXLtqOZac6wWGWQ5Z34WgZqGmUpRlFSxFFtqfxorq34W2u5XtGIHDCOGY3UtaS7PLedEaV7BUesVLJxYmOIlNGqNbe0TGbHvZN)yH2svXrGceiJ7Z6Yh7133euXLtiqGTA9aCSqBPYbXHcc6gh2MkpEcumSJdfuYNIpYwwtIbpG39nxcP3YXlzguXLtqOZac6wWGWQ5ZFSqBPQ4iqbcKX9zD5J967BcQ4YjeiWwTEaowOTu5GgNJGUXHTPYJNafd74qbpRwpuGcZDwlWzGGUXHTPYJNafd74qbW2XLVDNKyWd4DFZLq6TC8sMbvC5ee6mGGUfmiSA(8hl0wQkocuGazCFwx(yV((MGkUCcbcSvRhGJfAlvoObkiOBCyBQ84jqXWoouqNywfx)a4(9iXGhW7(MlH0B54LmdQ4Yji0zabDlyqy185pwOTuvCeOabY4(SU8XE99nbvC5eceyRwpahl0wQCqCOGGUXHTPYJNafd74qbLDnyHbXzyYksm4HsxyyVk2taW9f6GoNay7y)CjKiOrq34W2u5XtGIpoTq7W4(SU8XKKTapO4Jtl0ckDpvqYkAqXbjJ7NlpG39nxcPxXhNwO1FSqBPYbnqGiIdFfxobHodiOBbdcRMpFJdBmxfV7BUesVIpoTqR)yH2svXrGceiWwTEaowOTu5G4qbbDJdBtLhpbk(40cToouGLJxYmOIlNGqNbe0TGbHvZhjg8aPpUpRlFSxFFtqfxoHab2Q1dWXcTLkhe35iOBCyBQ84jqXhNwO1XHcCvmWcwGKSf4HwPpUtwbU2zThaVx)qq34W2u5XtGIpoTqRJdf4QyGfSGcbDJdBtLhpbk(40cToouqF4ozqS3XzqIbpG1nVqxHuyDR4Gge0noSnvE8eO4Jtl064qbpRwpuGcZDwlWzGGUXHTPYJNafFCAHwhhka2oU8T7KedEyCFwx(yVIpoTqlO09ubc6gh2MkpEcu8XPfADCOGoXSkU(bW97rIbpmUpRlFSxXhNwOfu6EQabDJdBtLhpbk(40cToouqzxdwyqCgMSIedEyCFwx(yVIpoTqlO09ubc6gh2MkpEcu8XPfADCOGyDX6Gfgm5o0jXGhGTA9aCSqBPQOgOcuGareh(kUCccDgqq3cgewnF(gh2ygceyRwpahl0wQCqduqq34W2u5XtGIpoTqRJdfeRlwhSWaY9j0KyWdWwTEaowOTuvCuGceiI4WxXLtqOZac6wWGWQ5Z34WgZqGaB16b4yH2sLdAGcc6gh2MkpEcu8XPfADCOacClAtfyHb7n5JedEaV7BUes)zklRbk3eq2WK9hl0wQCGRWy3GbHjWiOBCyBQ84jqXhNwO1XHcGB(zjduXkicbDJdBtLhpbk(40cToouaC)ECc2BYhc6gh2MkpEcu8XPfADCOGYn5PRkaLhtabDJdBtLhpbk(40cToouGIpoTqljg8aE33CjK(ZuwwduUjGSHj7pwOTu5G4qGaB16b4yH2sLdACoc6gh2MkpEcu8XPfADCOGYUgSWG4mmzfcAe0noSnv(veN8naBQaSWGqNbe0TGbHvZhjyT4hdI(UAoudAiXGhW6MxORqkSUvCyee0noSnv(veN854qbCfr8dO3Najg8q0podpw3aLUNk8C2LpEwfRBEHUcPW6wXHrqq34W2u5xrCYNJdfewnFar9tGeSw8JbrF1COg0qIbpGxHYfOIZiZvX6MxORqkSUvCqCe0noSnv(veN854qbyDdqOhZKyWdyDZl0vifw3gehbDJdBtLFfXjFoouaxre)a69jGGUXHTPYVI4KphhkiSA(aI6NajyT4hdI(Q5qnOHedEaRBEHUcPW6wXbXrqJGUXHTPYR4Jtl0oaBQqbwyaS7PLedEO0fg2R4Jtl06pwOTu5Gge0noSnvEfFCAHwhhkWvXalybsYwGhSuHp3OlFmWzYTZWvam5XgMrq34W2u5v8XPfADCOaxfdSGfijBbEyECpHTJbJzLIFiOBCyBQ8k(40cToouGsKLPL1a81jdiByYKyWd4vOCbQ4mYCvI14WgZaozbJvfhgbcKgh2ygWjlySQOMQKoE33CjK(ZuwwduUjGSHj7DfrCe0noSnvEfFCAHwhhk4mLL1aLBciByYKG1IFmi6RMd1Ggsm4b8kuUavCgzgbDJdBtLxXhNwO1XHcGnvOalma290sIbp04WgZaozbJvfhgbbDJdBtLxXhNwO1XHcuISmTSgGVozazdtMedEaVcLlqfNrMRw6cd7NDIzWcdW6wHzExriOBCyBQ8k(40cToouq5RXKx3aq2WKjbRf)yq0xnhQbnKyWd4vOCbQ4mYC1sxyypbUfTPcSWG9M8biqW7kQkE33CjK(ZuwwduUjGSHj7pwOTuvuCe0noSnvEfFCAHwhhka2uHcSWay3tljwg8DUIcGbpu6cd7v8XPfA9UIQI39nxcP)mLL1aLBciByY(J7Pwe0noSnvEfFCAHwhhkqjYY0YAa(6KbKnmzsm4b8kuUavCgzU6KlDHH9LBYtxvakpMG3vec6gh2MkVIpoTqRJdfaBQaSWGqNbe0TGbHvZhjyT4hdI(Q5qnOHedEaRBomcc6gh2MkVIpoTqRJdfu(Am51naKnmzsWAXpge9vZHAqdjg8aEfkxGkoJmdbcPh9JZWRBbaVcLlc6gh2MkVIpoTqRJdfOezzAznaFDYaYgMmcAe0noSnvEvmqq3UNL1G511Bce5MyDsm4HRTjGhZz475u5TSiE33CjKEc629SSgmVUEtGi3eR7NUxh2MqvqXdvGa5ABc4XCg(EovExriOBCyBQ8QWXHc4KVAZzzznGFwf7iXGhW6MxORqkSUvCq8QCYxTwFycmiwGqxP4iqGG1nVqxHuyDR4auxLyCYxTwFycmiwGqxPO4qGq6IoEmOgp9A8HvZhqu)eioc6gh2MkVkCCOaLiltlRb4Rtgq2WKjXGhWRq5cuXzK5QLUWW(zNygSWaSUvyM3vuvIDTnb8yodFpNkVLflDHH9ZoXmyHbyDRWm)XcTLksjoeixBtapMZW3ZPY7kI4iOBCyBQ8QWXHcotzznq5MaYgMmjyT4hdI(Q5qnOHedEaV7BUesVIpoTqR)yH2svrnqGq6r)4m8k(40cTiOBCyBQ8QWXHcGnvOalma290sIbpqSRTjGhZz475u5TSiE33CjKEytfkWcdGDpT(P71HTjufu8qfiqU2MaEmNHVNtL3veXRsmo5RwRpmbgelqORuKRWy3GbHjWKsdeiyDZl0vifw3CyqdeiLUWWEvSNaG7l0bDobW2X(JfAlvoWvySBWGWeyh1qCiqGTA9aCSqBPYbUcJDdgeMa7Oge0noSnvEv44qb4RXKFwwdkSEYGNvRhPL1KyWdLUWW(qNbSGi(2tbWTOgBXEEv0yYf1mkv5KVAT(WeyqSaHUsrUcJDdgeMatknvX7(MlH0FMYYAGYnbKnmz)XcTLQICfg7gmimbgcKsxyyFOZawqeF7Pa4wuJTypVkAm5IAG6QedV7BUesVIpoTqR)yH2sLdoVA0podVIpoTqlei4DFZLq6jWTOnvGfgS3Kp)XcTLkhCEv8oMZodpzTN1jeiWwTEaowOTu5GZjoc6gh2MkVkCCOGZvPBznOW6jdiy5KedEO0fg2FUkDlRbfwpzablN(5siR24WgZaozbJvf1GGUXHTPYRchhka2ubyHbHodiOBbdcRMpsWAXpge9vZHAqdjg8aw3Cyee0noSnvEv44qbCfr8dO3Najg8aw38cDfsH1TIdAqq34W2u5vHJdfG1nqP7Pcsm4bSU5f6kKcRBfh0uTXHnMbCYcgRg0u9ABc4XCg(EovEllkouGabRBEHUcPW6wXbXR24WgZaozbJvfhehbDJdBtLxfoouaw3ae6Xmc6gh2MkVkCCOGWQ5diQFcKG1IFmi6RMd1GgsiXGhWRq5cuXzK5QyDZl0vifw3koiE1sxyyVk2taW9f6GoNay7y)CjKiOBCyBQ8QWXHcuISmTSgGVozazdtMedEO0fg2J1naN8vR1RIgtU4iqHuohQQXHnMbCYcgRQw6cd7vXEcaUVqh05eaBh7NlHSkXW7(MlH0FMYYAGYnbKnmz)XcTLQIIxfV7BUespSPcfyHbWUNw)XcTLQIIdbcE33CjK(ZuwwduUjGSHj7pwOTu5WivX7(MlH0dBQqbwyaS7P1FSqBPQ4ivX6wXrGabV7BUes)zklRbk3eq2WK9hl0wQkosv8UV5si9WMkuGfga7EA9hl0wQCyKQyDRiudbcw38cDfsH1nhg0uLt(Q16dtGbXce6koioXHaP0fg2J1naN8vR1RIgtUOgOuf2Q1dWXcTLkhC2iOBCyBQ8QWXHckFnM86gaYgMmjyT4hdI(Q5qnOHedEaVcLlqfNrMRsSOFCgEfFCAH2Q4DFZLq6v8XPfA9hl0wQCyeiqW7(MlH0FMYYAGYnbKnmz)XcTLQIAQI39nxcPh2uHcSWay3tR)yH2svrnqGG39nxcP)mLL1aLBciByY(JfAlvomsv8UV5si9WMkuGfga7EA9hl0wQkosvSUvuCiqW7(MlH0FMYYAGYnbKnmz)XcTLQIJufV7BUespSPcfyHbWUNw)XcTLkhgPkw3koceiyDROZHaP0fg2xUKbIUf7DfrCe0noSnvEv44qbHvZhqu)eibRf)yq0xnhQbnKqIbpGxHYfOIZiZvX6MxORqkSUvCqCe0noSnvEv44qbWpTwwdu8jIZaq2WKjXYGVZvumObbnuns6mafJKoTodejnyKC0DhDrstHK43QyKSZjsQDDrs9EmJKIJKyDdj7CIKAx3djFTkqY63w2pKKqRqsXCgIeKCpK0GrsTRls2hJKD56gizSijUfHKCYxTwKSZjsYwOZhsQDDpK81QajRXtKKqRqsXCgcj3djnyKu76IK9Xi5JvkKm07ejfhjX6gs2eATij8TcijUfjYYAe0noSnvEv44qbLVgtEDdazdtMeSw8JbrF1COg0qIbpGxHYfOIZiZvX7(MlH0dBQqbwyaS7P1FSqBPYHrQI1TbXRk64XGA80RXhwnFar9tOkN8vR1hMadIf4CO4Gge0noSnvEv44qbLVgtEDdazdtMeSw8JbrF1COg0qIbpGxHYfOIZiZv5KVAT(WeyqSaHUIdIxLyyDZl0vifw3CyqdeiIoEmOgp9A8HvZhqu)eiocAe0noSnvEcClAtfyHb7n5Ba3VhOXHTj4zQGKSf4b8eOyysm4bsp6hNHxXhNwOfbDJdBtLNa3I2ubwyWEt(CCOaC)EGgh2MGNPcsYwGhWtGIpoTqljg8q0podVIpoTqlc6gh2MkpbUfTPcSWG9M854qbCYxT5SSSgWpRIDKyWdyDZl0vifw3koiEvo5RwRpmbgelqORuCee0noSnvEcClAtfyHb7n5ZXHcotzznq5MaYgMmjyT4hdI(Q5qnObbDJdBtLNa3I2ubwyWEt(CCOaLiltlRb4Rtgq2WKjXGhWRq5cuXzK5QLUWW(zNygSWaSUvyM3vec6gh2MkpbUfTPcSWG9M854qbWMkuGfga7EAjXGhACyJzaNSGXQIdIxT0fg2tGBrBQalmyVjFace8hl0wQCqdc6gh2MkpbUfTPcSWG9M854qbe0T7zznyED9MarUjwNedEOXHnMbCYcgRkoioc6gh2MkpbUfTPcSWG9M854qbkrwMwwdWxNmGSHjtIbpGxHYfOIZiZvBCyJzaNSGXQIdJuT0fg2tGBrBQalmyVjFace8UIqq34W2u5jWTOnvGfgS3KphhkO81yYRBaiByYKG1IFmi6RMd1Ggsm4b8kuUavCgzUAJdBmd4Kfmw5WG4iOBCyBQ8e4w0MkWcd2BYNJdfqq3UNL1G511Bce5MyDe0noSnvEcClAtfyHb7n5ZXHcGnvOalma290sILbFNROayWdLUWWEcClAtfyHb7n5dqGG3vejg8qPlmSxf7ja4(cDqNtaSDS3vu1RTjGhZz475u5TSiE33CjKEytfkWcdGDpT(P71HTjufu8Jgc6gh2MkpbUfTPcSWG9M854qbkrwMwwdWxNmGSHjtIbpu6cd7X6gGt(Q16vrJjxCeOqkNdv14WgZaozbJviOBCyBQ8e4w0MkWcd2BYNJdfaBQaSWGqNbe0TGbHvZhjyT4hdI(Q5qnOHedEaRBomcc6gh2MkpbUfTPcSWG9M854qbCfr8dO3Najg8aw38cDfsH1TIdAqq34W2u5jWTOnvGfgS3KphhkaRBGs3tfKyWdyDZl0vifw3koqmno24WgZaozbJvf1qCe0noSnvEcClAtfyHb7n5ZXHccRMpGO(jqcwl(XGOVAoudAiXGhigPh9JZWRBbaVcLlei4vOCbQ4mYmXRI1nVqxHuyDR4G4iOBCyBQ8e4w0MkWcd2BYNJdfG1naHEmJGUXHTPYtGBrBQalmyVjFoouq5RXKx3aq2WKjbRf)yq0xnhQbnKyWdyDR4WiqGu6cd7jWTOnvGfgS3KpabcExriOBCyBQ8e4w0MkWcd2BYNJdfa)0AznqXNiodazdtMeld(oxrXGg6VDd99O)Vju4PbnOua]] )

end