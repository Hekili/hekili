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
    
    spec:RegisterPack( "Windwalker", 20201217.2, [[d00n5bqicL6rekOnjj9jQOAuGuDkekRIqbEfvOzHiUfcv7IQ(LeyyGuogPyzeQEMcX0iuY1KGSnfs5Bek04iuKZPqI1rffMhvW9uW(KqhucQ0cPI8qjOQjsffrxKkkXgviv6JkKQ6KsqfReK8sQOi0mjuu3KkksTteYpvivmuQOizPkKQ8uv1urKUkvue8vQOKgRcjTxK(lWGj6WsTyj6XqnzfDzuBguFwsnAs1PPSAjO8Ae1SvLBtWUf9BLgoHCCQOOwUkpNKPlCDQ02vO(ocgVK48KsRNkk18bX(HmvdLu6F2btjsCOjo00iUgXOx8rgzuG2i0FOvet)IAm5UMP)Sfy63z1YjH(rMp6xuR9T9Ksk9Rw3dZ0p9x6AVOWjPL0)SdMsK4qtCOPrCnIrV4JmIyuCXe9ReXykrIpAJc9RBZjN0s6FYkm9lgIKoRwoj0pY8HKotVjzeuIHiPZKmMfk5dj1igjbjfhAIdneuiOedrssjWnzKC01uHcjxyKC0190IKwg8DUIcK8T1g2t)ptfkkP0)kIt(OKsjsdLu6NZU8XtQt0FJdBt6h2ubyHbHodiOBbdcRMp6hFwWN10pw38cDfKK4ijw3qYIdi5i0pwl(XGOVRMdf9RHguIeNsk9Zzx(4j1j6hFwWN10F0podpw3aLUNk8C2LpEIKvrsSU5f6kijXrsSUHKfhqYrO)gh2M0pxre)a69jqdkrJqjL(5SlF8K6e9Jpl4ZA6hVcLlqfNrMrYQijw38cDfKK4ijw3qYIdiP40FJdBt6pSA(aI6Na9J1IFmi6RMdfLin0GsKyrjL(5SlF8K6e9Jpl4ZA6hRBEHUcssCKeRBi5asko934W2K(X6gGqpMPbLOcrjL(BCyBs)Cfr8dO3Na9Zzx(4j1jAqjA0OKs)C2LpEsDI(XNf8zn9J1nVqxbjjosI1nKS4asko934W2K(dRMpGO(jq)yT4hdI(Q5qrjsdnOb9tGBrBQalmyVjFusPePHsk9Zzx(4j1j6VXHTj9J73d04W2e8mvq)4Zc(SM(fBKm6hNHxXhNwO1Zzx(4j9)mvaYwGPF8eOyyAqjsCkP0pND5JNuNO)gh2M0pUFpqJdBtWZub9Jpl4ZA6p6hNHxXhNwO1Zzx(4j9)mvaYwGPF8eO4Jtl0sdkrJqjL(5SlF8K6e9Jpl4ZA6hRBEHUcssCKeRBizXbKuCKSksYjF1A9HjWGybcDfKSisoc934W2K(5KVAZzBznGFwf7ObLiXIsk9Zzx(4j1j6VXHTj9FMYYAGYnbKnmz6hRf)yq0xnhkkrAObLOcrjL(5SlF8K6e9Jpl4ZA6hVcLlqfNrMrYQizPlmSF2jMblmaRBfM5Dfr)noSnPFLiltlRb4Rtgq2WKPbLOrJsk9Zzx(4j1j6hFwWN10FJdBmd4KfmwHKfhqsXrYQizPlmSNa3I2ubwyWEt(aei4pwOTuHKoGKAO)gh2M0pSPcfyHbWUNwAqjsmsjL(5SlF8K6e9Jpl4ZA6VXHnMbCYcgRqYIdiP40FJdBt6NGUDplRbZRR3eiYnX60GsKyIsk9Zzx(4j1j6hFwWN10pEfkxGkoJmJKvrYgh2ygWjlyScjloGKJGKvrYsxyypbUfTPcSWG9M8biqW7kI(BCyBs)krwMwwdWxNmGSHjtdkrJcLu6NZU8XtQt0p(SGpRPF8kuUavCgzgjRIKnoSXmGtwWyfs6Wasko934W2K(lFnM86gaYgMm9J1IFmi6RMdfLin0GsKgOrjL(BCyBs)e0T7zznyED9MarUjwN(5SlF8K6enOePrdLu63YGVZvuamy6V0fg2tGBrBQalmyVjFace8UIOFo7YhpPor)noSnPFytfkWcdGDpT0p(SGpRP)sxyyVk2taW9f6GoNay7yVRiKSksETnb8yodFpNkVLizrKeV7BUespSPcfyHbWUNw)096W2ejfdqsO5hnAqjsJ4usPFo7YhpPor)4Zc(SM(lDHH9yDdWjF1A9QOXKrYIi5iqdjjoswiKumajBCyJzaNSGXk6VXHTj9RezzAznaFDYaYgMmnOePzekP0pND5JNuNOF8zbFwt)yDdjDajhH(BCyBs)WMkalmi0zabDlyqy18r)yT4hdI(Q5qrjsdnOePrSOKs)C2LpEsDI(XNf8zn9J1nVqxbjjosI1nKS4asQH(BCyBs)Cfr8dO3NanOePPqusPFo7YhpPor)4Zc(SM(X6MxORGKehjX6gswCajHosQbjDejBCyJzaNSGXkKSisQbjjg934W2K(X6gO09ubnOePz0OKs)C2LpEsDI(XNf8zn9dDKuSrYOFCgEDla4vOC9C2LpEIKqGGK4vOCbQ4mYmssmKSksI1nVqxbjjosI1nKS4asko934W2K(dRMpGO(jq)yT4hdI(Q5qrjsdnOePrmsjL(BCyBs)yDdqOhZ0pND5JNuNObLinIjkP0pND5JNuNOF8zbFwt)yDdjloGKJGKqGGKLUWWEcClAtfyHb7n5dqGG3ve934W2K(lFnM86gaYgMm9J1IFmi6RMdfLin0GsKMrHsk9BzW35kkOFn0FJdBt6h(P1YAGIprCgaYgMm9Zzx(4j1jAqd6xXhNwOLskLinusPFo7YhpPor)4Zc(SM(lDHH9k(40cT(JfAlviPdiPg6VXHTj9dBQqbwyaS7PLguIeNsk9Zzx(4j1j6pBbM(TuHp3OlFmWz2TZWvam5XgMP)gh2M0VLk85gD5JboZUDgUcGjp2WmnOencLu6NZU8XtQt0F2cm9ppUNW2XGXSsXp6VXHTj9ppUNW2XGXSsXpAqjsSOKs)C2LpEsDI(XNf8zn9JxHYfOIZiZizvKe6izJdBmd4KfmwHKfhqYrqsiqqYgh2ygWjlyScjlIKAqYQiPyJK4DFZLq6ptzznq5MaYgMS3vessm6VXHTj9RezzAznaFDYaYgMmnOevikP0pND5JNuNOF8zbFwt)4vOCbQ4mYm934W2K(ptzznq5MaYgMm9J1IFmi6RMdfLin0Gs0OrjL(5SlF8K6e9Jpl4ZA6VXHnMbCYcgRqYIdi5i0FJdBt6h2uHcSWay3tlnOejgPKs)C2LpEsDI(XNf8zn9JxHYfOIZiZizvKS0fg2p7eZGfgG1TcZ8UIO)gh2M0VsKLPL1a81jdiByY0GsKyIsk9Zzx(4j1j6hFwWN10pEfkxGkoJmJKvrYsxyypbUfTPcSWG9M8biqW7kcjRIK4DFZLq6ptzznq5MaYgMS)yH2sfswejfN(BCyBs)LVgtEDdazdtM(XAXpge9vZHIsKgAqjAuOKs)wg8DUIcGbt)r)4m8k(40cTEo7YhpRI39nxcP)mLL1aLBciByY(J7Pw6VXHTj9dBQqbwyaS7PL(5SlF8K6enOePbAusPFo7YhpPor)4Zc(SM(XRq5cuXzKzKSkso5sxyyF5M80vfGYJj4Dfr)noSnPFLiltlRb4Rtgq2WKPbLinAOKs)C2LpEsDI(XNf8zn9J1nK0bKCe6VXHTj9dBQaSWGqNbe0TGbHvZh9J1IFmi6RMdfLin0GsKgXPKs)C2LpEsDI(XNf8zn9JxHYfOIZiZijeiiPyJKr)4m86waWRq565SlF8K(BCyBs)LVgtEDdazdtM(XAXpge9vZHIsKgAqjsZiusP)gh2M0VsKLPL1a81jdiByY0pND5JNuNObnOF8eO4Jtl0sjLsKgkP0pND5JNuNO)ve9R4G(BCyBs)J7Z6Yht)J7Nlt)4DFZLq6v8XPfA9hl0wQqshqsnijeiiPio8vC5ee6mGGUfmiSA(8noSXmswfjX7(MlH0R4Jtl06pwOTuHKfrYrGgscbcscB16b4yH2sfs6asko0O)X9bYwGPFfFCAHwqP7PcAqjsCkP0pND5JNuNOF8zbFwt)InsoUpRlFSxFFtqfxorsiqqsyRwpahl0wQqshqsXle934W2K(TC8sMbvC5KguIgHsk9Zzx(4j1j6pBbM(BL(4ozf4AN9Ea8E9J(BCyBs)TsFCNScCTZEpaEV(rdkrIfLu6VXHTj97QyGfSGI(5SlF8K6enOevikP0pND5JNuNOF8zbFwt)yDZl0vqsIJKyDdjloGKAO)gh2M0FF4ozqS3XzqdkrJgLu6VXHTj9)SA9qbkm3zTaNb9Zzx(4j1jAqjsmsjL(5SlF8K6e9Jpl4ZA6FCFwx(yVIpoTqlO09ub934W2K(HTJlF7oPbLiXeLu6NZU8XtQt0p(SGpRP)X9zD5J9k(40cTGs3tf0FJdBt6VtmRIRFaC)E0Gs0OqjL(5SlF8K6e9Jpl4ZA6FCFwx(yVIpoTqlO09ub934W2K(l7AWcdIZWKv0GsKgOrjL(5SlF8K6e9Jpl4ZA6h2Q1dWXcTLkKSisQrmbnKeceKueh(kUCccDgqq3cgewnF(gh2ygjHabjHTA9aCSqBPcjDaj1an6VXHTj9hRlwhSWGj3HonOePrdLu6NZU8XtQt0p(SGpRPFyRwpahl0wQqYIi5OanKeceKueh(kUCccDgqq3cgewnF(gh2ygjHabjHTA9aCSqBPcjDaj1an6VXHTj9hRlwhSWaY9j00GsKgXPKs)C2LpEsDI(XNf8zn9J39nxcP)mLL1aLBciByY(JfAlviPdijxHXUbdctGP)gh2M0pbUfTPcSWG9M8rdkrAgHsk934W2K(HB(zjduXkiI(5SlF8K6enOePrSOKs)noSnPF4(94eS3Kp6NZU8XtQt0GsKMcrjL(BCyBs)LBYtxvakpMa9Zzx(4j1jAqjsZOrjL(5SlF8K6e9Jpl4ZA6hV7BUes)zklRbk3eq2WK9hl0wQqshqsXrsiqqsyRwpahl0wQqshqsnfI(BCyBs)k(40cT0GsKgXiLu6VXHTj9x21GfgeNHjROFo7YhpPordAq)QGskLinusPFo7YhpPor)4Zc(SM(V2MaEmNHVNtL3sKSisI39nxcPNGUDplRbZRR3eiYnX6(P71HTjskgGKqZlMqsiqqYRTjGhZz475u5Dfr)noSnPFc629SSgmVUEtGi3eRtdkrItjL(5SlF8K6e9Jpl4ZA6hRBEHUcssCKeRBizXbKuCKSksYjF1A9HjWGybcDfKSisocscbcsI1nVqxbjjosI1nKS4askwizvKe6ijN8vR1hMadIfi0vqYIiP4ijeiiPyJKIoEmOgp9A8HvZhqu)eqsIr)noSnPFo5R2C2wwd4NvXoAqjAekP0pND5JNuNOF8zbFwt)4vOCbQ4mYmswfjlDHH9ZoXmyHbyDRWmVRiKSkscDK8ABc4XCg(EovElrYIizPlmSF2jMblmaRBfM5pwOTuHKehjfhjHabjV2MaEmNHVNtL3vessm6VXHTj9RezzAznaFDYaYgMmnOejwusPFo7YhpPor)4Zc(SM(X7(MlH0R4Jtl06pwOTuHKfrsnijeiiPyJKr)4m8k(40cTEo7YhpP)gh2M0)zklRbk3eq2WKPFSw8JbrF1COOePHguIkeLu6NZU8XtQt0p(SGpRPFOJKxBtapMZW3ZPYBjswejX7(MlH0dBQqbwyaS7P1pDVoSnrsXaKeAEXescbcsETnb8yodFpNkVRiKKyizvKe6ijN8vR1hMadIfi0vqYIijxHXUbdctGrsIJKAqsiqqsSU5f6kijXrsSUHKomGKAqsiqqYsxyyVk2taW9f6GoNay7y)XcTLkK0bKKRWy3GbHjWiPJiPgKKyijeiijSvRhGJfAlviPdijxHXUbdctGrshrsn0FJdBt6h2uHcSWay3tlnOenAusPFo7YhpPor)4Zc(SM(lDHH9Hodybr8TNcGBrn2I98QOXKrYIiPMrbjRIKCYxTwFycmiwGqxbjlIKCfg7gmimbgjjosQbjRIK4DFZLq6ptzznq5MaYgMS)yH2sfswej5km2nyqycmscbcsw6cd7dDgWcI4Bpfa3IASf75vrJjJKfrsnIfswfjHosI39nxcPxXhNwO1FSqBPcjDajleswfjJ(Xz4v8XPfA9C2LpEIKqGGK4DFZLq6jWTOnvGfgS3Kp)XcTLkK0bKSqizvKeVJ5SZWtw7zDIKqGGKWwTEaowOTuHKoGKfcjjg934W2K(XxJj)SSguy9KbpRwpslRPbLiXiLu6NZU8XtQt0p(SGpRP)sxyy)5Q0TSguy9KbeSC6NlHejRIKnoSXmGtwWyfswej1q)noSnP)ZvPBznOW6jdiy5KguIetusPFo7YhpPor)4Zc(SM(X6gs6asoc934W2K(HnvawyqOZac6wWGWQ5J(XAXpge9vZHIsKgAqjAuOKs)C2LpEsDI(XNf8zn9J1nVqxbjjosI1nKS4asQH(BCyBs)Cfr8dO3NanOePbAusPFo7YhpPor)4Zc(SM(X6MxORGKehjX6gswCaj1GKvrYgh2ygWjlyScjhqsnizvK8ABc4XCg(EovElrYIiP4qdjHabjX6MxORGKehjX6gswCajfhjRIKnoSXmGtwWyfswCajfN(BCyBs)yDdu6EQGguI0OHsk934W2K(X6gGqpMPFo7YhpPordkrAeNsk9Zzx(4j1j6hFwWN10pEfkxGkoJmJKvrsSU5f6kijXrsSUHKfhqsXrYQizPlmSxf7ja4(cDqNtaSDSFUes6VXHTj9hwnFar9tG(XAXpge9vZHIsKgAqjsZiusPFo7YhpPor)4Zc(SM(lDHH9yDdWjF1A9QOXKrYIi5iqdjjoswiKumajBCyJzaNSGXkKSksw6cd7vXEcaUVqh05eaBh7NlHejRIKqhjX7(MlH0FMYYAGYnbKnmz)XcTLkKSiskoswfjX7(MlH0dBQqbwyaS7P1FSqBPcjlIKIJKqGGK4DFZLq6ptzznq5MaYgMS)yH2sfs6asocswfjX7(MlH0dBQqbwyaS7P1FSqBPcjlIKJGKvrsSUHKfrYrqsiqqs8UV5si9NPSSgOCtazdt2FSqBPcjlIKJGKvrs8UV5si9WMkuGfga7EA9hl0wQqshqYrqYQijw3qYIiPyHKqGGKyDZl0vqsIJKyDdjDyaj1GKvrso5RwRpmbgelqORGKoGKIJKedjHabjlDHH9yDdWjF1A9QOXKrYIiPgOHKvrsyRwpahl0wQqshqsXi934W2K(vISmTSgGVozazdtMguI0iwusPFo7YhpPor)4Zc(SM(XRq5cuXzKzKSkscDKm6hNHxXhNwO1Zzx(4jswfjX7(MlH0R4Jtl06pwOTuHKoGKJGKqGGK4DFZLq6ptzznq5MaYgMS)yH2sfswej1GKvrs8UV5si9WMkuGfga7EA9hl0wQqYIiPgKeceKeV7BUes)zklRbk3eq2WK9hl0wQqshqYrqYQijE33CjKEytfkWcdGDpT(JfAlvizrKCeKSksI1nKSiskoscbcsI39nxcP)mLL1aLBciByY(JfAlvizrKCeKSksI39nxcPh2uHcSWay3tR)yH2sfs6asocswfjX6gswejhbjHabjX6gswejlescbcsw6cd7lxYar3I9UIqsIr)noSnP)YxJjVUbGSHjt)yT4hdI(Q5qrjsdnOePPqusPFo7YhpPor)4Zc(SM(XRq5cuXzKzKSksI1nVqxbjjosI1nKS4asko934W2K(dRMpGO(jq)yT4hdI(Q5qrjsdnOePz0OKs)wg8DUIc6xd934W2K(HFATSgO4teNbGSHjt)C2LpEsDIguI0igPKs)C2LpEsDI(XNf8zn9JxHYfOIZiZizvKeV7BUespSPcfyHbWUNw)XcTLkK0bKCeKSksI1nKCajfhjRIKIoEmOgp9A8HvZhqu)eqYQijN8vR1hMadIfuiOHKoGKAO)gh2M0F5RXKx3aq2WKPFSw8JbrF1COOePHguI0iMOKs)C2LpEsDI(XNf8zn9JxHYfOIZiZizvKKt(Q16dtGbXce6kiPdiP4izvKe6ijw38cDfKK4ijw3qshgqsnijeiiPOJhdQXtVgFy18be1pbKKy0FJdBt6V81yYRBaiByY0pwl(XGOVAouuI0qdAq)4jqXWusPePHsk9Zzx(4j1j6hFwWN10VyJKJ7Z6Yh7133euXLtKeceKe2Q1dWXcTLkK0bKu8cr)noSnPFlhVKzqfxoPbLiXPKs)C2LpEsDI(XNf8zn9J1nVqxbjjosI1nKS4asQH(BCyBs)9H7KbXEhNbnOencLu6NZU8XtQt0p(SGpRP)sxyyVk2taW9f6GoNay7y)CjKizvKueh(kUCccDgqq3cgewnF(gh2ygjHabjHTA9aCSqBPcjDaj1anKeceKe2Q1dWXcTLkKSisQrmbn6VXHTj9hRlwhSWGj3HonOejwusPFo7YhpPor)4Zc(SM(HosETnb8yodFpNkVLizrKuSkescbcsETnb8yodFpNkVRiKKyizvKeV7BUes)zklRbk3eq2WK9hl0wQqshqsUcJDdgeMat)noSnPFcClAtfyHb7n5JguIkeLu6NZU8XtQt0p(SGpRPF8kuUavCgzgjRIKqhjV2MaEmNHVNtL3sKSisQbAijeii512eWJ5m89CQ8UIqsIr)noSnPF4MFwYavScIObLOrJsk9Zzx(4j1j6hFwWN10)12eWJ5m89CQ8wIKfrYrGgscbcsETnb8yodFpNkVRi6VXHTj9d3VhNG9M8rdkrIrkP0pND5JNuNO)gh2M0F5M80vfGYJjq)4Zc(SM(V2MaEmNHVNtL3sKSiswiOHKqGGKxBtapMZW3ZPY7kI(FwYa8K(hnOrdkrIjkP0pND5JNuNOF8zbFwt)4DFZLq6vXEcaUVqh05eaBh7X69vZkKCajfhjHabjHTA9aCSqBPcjDajfhAijeiij0rYRTjGhZz475u5pwOTuHKfrsnfcjHabjfBKeVJ5SZWtw7zDIKvrsOJKqhjV2MaEmNHVNtL3sKSisI39nxcPxf7ja4(cDqNtaSDSh299ahJ17RMbHjWijeiiPyJKxBtapMZW3ZPYZvmvOqsIHKvrsOJK4DFZLq6TC8sMbvC5ee6mGGUfmiSA(8hl0wQqYIijE33CjKEvSNaG7l0bDobW2XEy33dCmwVVAgeMaJKqGGKJ7Z6Yh7133euXLtKKyijXqYQijE33CjKEytfkWcdGDpT(JfAlviPddi5OGKvrsSUHKfhqsXrYQijE33CjKEc629SSgmVUEtGi3eR7pwOTuHKomGKAehjjg934W2K(vXEcaUVqh05eaBhtdkrJcLu6NZU8XtQt0p(SGpRPF8oMZodpzTN1jswfjHosw6cd7jWTOnvGfgS3KpVRiKeceKe6ijSvRhGJfAlviPdijE33CjKEcClAtfyHb7n5ZFSqBPcjHabjX7(MlH0tGBrBQalmyVjF(JfAlvizrKeV7BUesVk2taW9f6GoNay7ypS77bogR3xndctGrsIHKvrs8UV5si9WMkuGfga7EA9hl0wQqshgqYrbjRIKyDdjloGKIJKvrs8UV5si9e0T7zznyED9MarUjw3FSqBPcjDyaj1iossm6VXHTj9RI9eaCFHoOZja2oMguI0ankP0pND5JNuNOF8zbFwt)4DFZLq6vXEcaUVqh05eaBh7X69vZkKCajfhjHabjHTA9aCSqBPcjDajfhAijeiizPlmSxXCOBzn46A27kcjHabjHosI39nxcPV8T7eSWGqNbCYcA9hl0wQqshrsnizrKeV7BUesVk2taW9f6GoNay7ypS77bogR3xndctGrsiqqsXgjzLItm7lF7oblmi0zaNSGwVqxy7HKedjRIK4DFZLq6HnvOalma2906pwOTuHKoGKAGgswfjX6gswCajfhjRIK4DFZLq6jOB3ZYAW866nbICtSU)yH2sfs6asQrC6VXHTj9RI9eaCFHoOZja2oMguI0OHsk9Zzx(4j1j6pBbM(BL(4ozf4AN9Ea8E9J(BCyBs)TsFCNScCTZEpaEV(rdkrAeNsk934W2K(DvmWcwqr)C2LpEsDIguI0mcLu6NZU8XtQt0p(SGpRPFyRwpahl0wQqYIiPMcnkijeiiPio8vC5ee6mGGUfmiSA(8noSXmscbcsoUpRlFSxFFtqfxoP)gh2M0FSUyDWcdi3NqtdkrAelkP0pND5JNuNOF8zbFwt)4DFZLq6TC8sMbvC5ee6mGGUfmiSA(8hl0wQqYIi5iqdjHabjh3N1Lp2RVVjOIlNijeiijSvRhGJfAlviPdiP4qJ(BCyBs)LVDNay3tlnOePPqusPFo7YhpPor)4Zc(SM(X7(MlH0B54LmdQ4Yji0zabDlyqy185pwOTuHKfrYrGgscbcsoUpRlFSxFFtqfxorsiqqsyRwpahl0wQqshqsnfI(BCyBs)L8P4JSL10GsKMrJsk934W2K(FwTEOafM7SwGZG(5SlF8K6enOePrmsjL(5SlF8K6e9Jpl4ZA6hV7BUesVLJxYmOIlNGqNbe0TGbHvZN)yH2sfswejhbAijeii54(SU8XE99nbvC5ejHabjHTA9aCSqBPcjDaj1an6VXHTj9dBhx(2DsdkrAetusPFo7YhpPor)4Zc(SM(X7(MlH0B54LmdQ4Yji0zabDlyqy185pwOTuHKfrYrGgscbcsoUpRlFSxFFtqfxorsiqqsyRwpahl0wQqshqsXHg934W2K(7eZQ46ha3VhnOePzuOKs)C2LpEsDI(XNf8zn9x6cd7vXEcaUVqh05eaBh7NlHK(BCyBs)LDnyHbXzyYkAqd6FYWT7lOKsjsdLu6VXHTj9ReX9b07CcuXzKz6NZU8XtQt0GsK4usPFo7YhpPor)Ri6xXb934W2K(h3N1LpM(h3pxM(X7(MlH0B54LmdQ4Yji0zabDlyqy185pwOTuHKfrsyRwpahl0wQqsiqqsyRwpahl0wQqshqsnIdnKSkscB16b4yH2sfswejX7(MlH0R4Jtl06pwOTuHKvrs8UV5si9k(40cT(JfAlvizrKud0O)X9bYwGPF99nbvC5KguIgHsk9Zzx(4j1j6hFwWN10p0rYsxyyVIpoTqR3vescbcsw6cd7vXEcaUVqh05eaBh7DfHKedjRIKI4WxXLtqOZac6wWGWQ5Z34WgZijeiijSvRhGJfAlviPddi5Obn6VXHTj9lAdBtAqjsSOKs)C2LpEsDI(BCyBs)4(9anoSnbptf0p(SGpRP)sxyyVIpoTqR3ve9)mvaYwGPFfFCAHwAqjQqusPFo7YhpPor)noSnPFC)EGgh2MGNPc6hFwWN10FPlmSNa3I2ubwyWEt(8UIO)NPcq2cm9tGBrBQalmyVjF0Gs0OrjL(5SlF8K6e934W2K(X97bACyBcEMkOF8zbFwt)HjWiPdiPyHKvrsSUHKoGKfcjRIKInskIdFfxobHodiOBbdcRMpFJdBmt)ptfGSfy6FfXjF0GsKyKsk9Zzx(4j1j6hFwWN10pw38cDfKK4ijw3qYIdi5iizvKe6ijN8vR1hMadIfi0vqshqsnijeiijN8vR1hMadIfi0vqshqsXcjRIK4DFZLq6HnvOalma2906pwOTuHKoGKA8fcjHabjX7(MlH0tGBrBQalmyVjF(JfAlviPdiP4ijXO)gh2M0pSPcWcdcDgqq3cgewnF0pwl(XGOVAouuI0qdkrIjkP0pND5JNuNOF8zbFwt)yDZl0vqsIJKyDdjloGKAqYQij0rso5RwRpmbgelqORGKoGKAqsiqqs8UV5si9k(40cT(JfAlviPdiP4ijeiijN8vR1hMadIfi0vqshqsXcjRIK4DFZLq6HnvOalma2906pwOTuHKoGKA8fcjHabjX7(MlH0tGBrBQalmyVjF(JfAlviPdiP4ijXO)gh2M0pxre)a69jqdkrJcLu6NZU8XtQt0p(SGpRPF8kuUavCgzgjRIKyDZl0vqsIJKyDdjloGKIJKvrsOJKCYxTwFycmiwGqxbjDaj1GKqGGK4DFZLq6v8XPfA9hl0wQqshqsXrsiqqso5RwRpmbgelqORGKoGKIfswfjX7(MlH0dBQqbwyaS7P1FSqBPcjDaj14lescbcsI39nxcPNa3I2ubwyWEt(8hl0wQqshqsXrsIr)noSnP)WQ5diQFc0pwl(XGOVAouuI0qdkrAGgLu6NZU8XtQt0FJdBt6h3VhOXHTj4zQG(XNf8zn9l2iz0podVIpoTqRNZU8Xt6)zQaKTat)4jqXW0GsKgnusPFo7YhpPor)noSnPFC)EGgh2MGNPc6hFwWN10F0podVIpoTqRNZU8Xt6)zQaKTat)4jqXhNwOLguI0ioLu6NZU8XtQt0FJdBt6h3VhOXHTj4zQG(XNf8zn934WgZaozbJviPdi5i0)ZubiBbM(vbnOePzekP0pND5JNuNO)gh2M0pUFpqJdBtWZub9Jpl4ZA6VXHnMbCYcgRqYIdi5i0)ZubiBbM(7LPbnOFrhJxHYoOKsjsdLu6VXHTj9lAdBt6NZU8XtQt0GsK4usP)gh2M0F5gXJNa4xRLNeSSgeBflPFo7YhpPordkrJqjL(5SlF8K6e9VIOFfh0FJdBt6FCFwx(y6FC)Cz6hA0)4(azlW0FfxobBcCvmioljZbnOejwusPFo7YhpPor)4Zc(SM(fBKm6hNHxXhNwO1Zzx(4jscbcsk2iz0podpSPcWcdcDgqq3cgewnFEo7YhpP)gh2M0pw3aLUNkObLOcrjL(5SlF8K6e9Jpl4ZA6xSrYOFCgEo5R2C2wwd4NvHppND5JN0FJdBt6hRBac9yMg0G(7LPKsjsdLu6VXHTj9tq3UNL1G511Bce5MyD6NZU8XtQt0GsK4usPFo7YhpPor)4Zc(SM(X6MxORGKehjX6gswCajfhjRIKCYxTwFycmiwGqxbjlIKIJKqGGKyDZl0vqsIJKyDdjloGKIf934W2K(5KVAZzBznGFwf7ObLOrOKs)C2LpEsDI(XNf8zn9JxHYfOIZiZizvKe6izPlmSF2jMblmaRBfM5DfHKqGGKtU0fg2xUjpDvbO8ycExrijXO)gh2M0VsKLPL1a81jdiByY0GsKyrjL(5SlF8K6e9Jpl4ZA6Nt(Q16dtGbXce6kizrKKRWy3GbHjWijeiijw38cDfKK4ijw3qshgqsn0FJdBt6h2uHcSWay3tlnOevikP0pND5JNuNOF8zbFwt)qhjJ(Xz4jOB3ZYAW866nbICtSUNZU8XtKSksI39nxcP)mLL1aLBciByY(P71HTjswejX7(MlH0tq3UNL1G511Bce5MyD)XcTLkK0rKuSqsIHKvrsOJK4DFZLq6HnvOalma2906pwOTuHKfrYrqsiqqsSUHKfhqYcHKeJ(BCyBs)NPSSgOCtazdtM(XAXpge9vZHIsKgAqjA0OKs)C2LpEsDI(XNf8zn9x6cd7pxLUL1GcRNmGGLt)CjK0FJdBt6)Cv6wwdkSEYacwoPbLiXiLu6NZU8XtQt0p(SGpRPF8kuUavCgzgjRIKqhjHosI39nxcPVCtE6Qcq5Xe8hl0wQqYIiP4izvKe6ijw3qYIi5iijeiijE33CjKEytfkWcdGDpT(JfAlvizrKC0qsIHKvrsOJKyDdjloGKfcjHabjX7(MlH0dBQqbwyaS7P1FSqBPcjlIKIJKedjjgscbcsYjF1A9HjWGybcDfK0HbKCeKKy0FJdBt6xjYY0YAa(6KbKnmzAqjsmrjL(5SlF8K6e9Jpl4ZA6hRBEHUcssCKeRBizXbKud934W2K(5kI4hqVpbAqjAuOKs)C2LpEsDI(XNf8zn9J1nVqxbjjosI1nKS4asoc934W2K(HnvawyqOZac6wWGWQ5J(XAXpge9vZHIsKgAqjsd0OKs)C2LpEsDI(XNf8zn9J1nVqxbjjosI1nKS4asko934W2K(X6gO09ubnOePrdLu6NZU8XtQt0p(SGpRP)sxyyFOZawqeF7Pa4wuJTypVkAmzKSisQzuqYQijN8vR1hMadIfi0vqYIijxHXUbdctGrsIJKAqYQijE33CjKEytfkWcdGDpT(JfAlvizrKKRWy3GbHjW0FJdBt6hFnM8ZYAqH1tg8SA9iTSMguI0ioLu6NZU8XtQt0p(SGpRPFSU5f6kijXrsSUHKfhqsXrYQij0rsXgjJ(Xz41TaGxHY1Zzx(4jscbcsIxHYfOIZiZijXO)gh2M0Fy18be1pb6hRf)yq0xnhkkrAObLinJqjL(5SlF8K6e9Jpl4ZA6hVcLlqfNrMP)gh2M0pw3ae6XmnOePrSOKs)wg8DUIc6xd9Zzx(4j1j6hFwWN10FPlmSVCjdeDl2pxcj934W2K(HFATSgO4teNbGSHjtdkrAkeLu6NZU8XtQt0p(SGpRPF8kuUavCgzgjRIKqhjlDHH9LlzGOBXExrijeiiz0podVUfa8kuUEo7YhprYQiPOJhdQXtVgFy18be1pbKSksI1nKCajfhjRIK4DFZLq6HnvOalma2906pwOTuHKoGKJGKqGGKyDZl0vqsIJKyDdjDyaj1GKvrsrhpguJNEnELiltlRb4Rtgq2WKrYQijN8vR1hMadIfi0vqshqYrqsIr)noSnP)YxJjVUbGSHjt)yT4hdI(Q5qrjsdnObnO)X8PSnPejo0ehAAexJy0RH(j0xAzTI(DwlCh9iQWHOrFNbsIKKQZiPjiAVajH3djDobUfTPcSWG9M85CK8yNzx74jsQwbgjB3yf6GNijwVZAw5rqjMTKrsnodKSWV5y(cEIKop6hNHFuDosgls68OFCg(r1Zzx(4PZrYoqsNLrhXmscDnviMhbLy2sgjf3zGKf(nhZxWtK05r)4m8JQZrYyrsNh9JZWpQEo7YhpDos2bs6Sm6iMrsORPcX8iOeZwYiPMrZzGKf(nhZxWtK05r)4m8JQZrYyrsNh9JZWpQEo7YhpDoscDnviMhbfckN1c3rpIkCiA03zGKijP6msAcI2lqs49qsNR4Jtl06CK8yNzx74jsQwbgjB3yf6GNijwVZAw5rqjMTKrsnI7mqYc)MJ5l4js68OFCg(r15izSiPZJ(Xz4hvpND5JNohj7ajDwgDeZij01uHyEeuiOCwlCh9iQWHOrFNbsIKKQZiPjiAVajH3djDUkCosESZSRD8ejvRaJKTBScDWtKeR3znR8iOeZwYiPy5mqYc)MJ5l4js68OFCg(r15izSiPZJ(Xz4hvpND5JNohj7ajDwgDeZij01uHyEeuIzlzKC0CgizHFZX8f8ejDE0pod)O6CKmwK05r)4m8JQNZU8XtNJKqxtfI5rqjMTKrsnILZajl8BoMVGNiPZJ(Xz4hvNJKXIKop6hNHFu9C2LpE6CKe6AQqmpckeuoRfUJEev4q0OVZajrss1zK0eeTxGKW7HKoFYWT7lCosESZSRD8ejvRaJKTBScDWtKeR3znR8iOeZwYiPgO5mqYc)MJ5l4js68OFCg(r15izSiPZJ(Xz4hvpND5JNohj7ajDwgDeZij01uHyEeuIzlzKuJgNbsw43CmFbprsNh9JZWpQohjJfjDE0pod)O65SlF805izhiPZYOJygjHUMkeZJGcbLZAH7Ohrfoen67mqsKKuDgjnbr7fij8EiPZ7LDosESZSRD8ejvRaJKTBScDWtKeR3znR8iOeZwYizHCgizHFZX8f8ejDE0pod)O6CKmwK05r)4m8JQNZU8XtNJKqxtfI5rqjMTKrsnI7mqYc)MJ5l4js68OFCg(r15izSiPZJ(Xz4hvpND5JNohjHUMkeZJGsmBjJKAkKZajl8BoMVGNiPZJ(Xz4hvNJKXIKop6hNHFu9C2LpE6CKe6AQqmpckeufocI2l4jsokizJdBtK8zQq5rqr)TBOVh9)nHcp9l6wy7X0Vyis6SA5Kq)iZhs6m9MKrqjgIKotYywOKpKuJyKeKuCOjo0qqHGsmejjLa3KrYrxtfkKCHrYrx3tlsAzW35kkqY3wBypckeuIHiPZsfg7g8ejlz49yKeVcLDGKLCTLkpsw4IXSOqHK5MexVpby3hs24W2uHKB(06rq14W2u5fDmEfk7yq0g2MiOACyBQ8IogVcLD44qbLBepEcGFTwEsWYAqSvSebvJdBtLx0X4vOSdhhkyCFwx(ysYwGhQ4YjytGRIbXzjzoizfnO4GKX9ZLhGgcQgh2MkVOJXRqzhoouaw3aLUNkiXGhe7OFCgEfFCAHwpND5JNqGi2r)4m8WMkalmi0zabDlyqy1855SlF8ebvJdBtLx0X4vOSdhhkaRBac9yMedEqSJ(Xz45KVAZzBznGFwf(8C2LpEIGcbLyis6SuHXUbprsEmFArYWeyKm0zKSXXEiPPqYECBVU8XEeunoSnvdkrCFa9oNavCgzgbvJdBtLJdfmUpRlFmjzlWd67BcQ4YjjRObfhKmUFU8aE33CjKElhVKzqfxobHodiOBbdcRMp)XcTLQIWwTEaowOTubbcSvRhGJfAlvoOrCOvf2Q1dWXcTLQI4DFZLq6v8XPfA9hl0wQQI39nxcPxXhNwO1FSqBPQOgOHGQXHTPYXHceTHTjjg8a0lDHH9k(40cTExrqGu6cd7vXEcaUVqh05eaBh7DfrSQI4WxXLtqOZac6wWGWQ5Z34WgZqGaB16b4yH2sLddJg0qq14W2u54qb4(9anoSnbptfKKTapO4Jtl0sIbpu6cd7v8XPfA9UIqq14W2u54qb4(9anoSnbptfKKTapqGBrBQalmyVjFKyWdLUWWEcClAtfyHb7n5Z7kcbvJdBtLJdfG73d04W2e8mvqs2c8WkIt(iXGhctGDqSQI1nhkuvXweh(kUCccDgqq3cgewnF(gh2ygbvJdBtLJdfaBQaSWGqNbe0TGbHvZhjyT4hdI(Q5qnOHedEaRBEHUcXX6wXHrQcDo5RwRpmbgelqOR4Ggiq4KVAT(WeyqSaHUIdIvv8UV5si9WMkuGfga7EA9hl0wQCqJVqqGG39nxcPNa3I2ubwyWEt(8hl0wQCqCIHGQXHTPYXHc4kI4hqVpbsm4bSU5f6kehRBfh0uf6CYxTwFycmiwGqxXbnqGG39nxcPxXhNwO1FSqBPYbXHaHt(Q16dtGbXce6koiwvX7(MlH0dBQqbwyaS7P1FSqBPYbn(cbbcE33CjKEcClAtfyHb7n5ZFSqBPYbXjgcQgh2MkhhkiSA(aI6NajyT4hdI(Q5qnOHedEaVcLlqfNrMRI1nVqxH4yDR4G4vHoN8vR1hMadIfi0vCqdei4DFZLq6v8XPfA9hl0wQCqCiq4KVAT(WeyqSaHUIdIvv8UV5si9WMkuGfga7EA9hl0wQCqJVqqGG39nxcPNa3I2ubwyWEt(8hl0wQCqCIHGQXHTPYXHcW97bACyBcEMkijBbEapbkgMedEqSJ(Xz4v8XPfArq14W2u54qb4(9anoSnbptfKKTapGNafFCAHwsm4HOFCgEfFCAHweunoSnvoouaUFpqJdBtWZubjzlWdQGedEOXHnMbCYcgRCyeeunoSnvoouaUFpqJdBtWZubjzlWd9YKyWdnoSXmGtwWyvXHrqqHGQXHTPY3lpqq3UNL1G511Bce5MyDeunoSnv(EzhhkGt(QnNTL1a(zvSJedEaRBEHUcXX6wXbXRYjF1A9HjWGybcDLIIdbcw38cDfIJ1TIdIfcQgh2MkFVSJdfOezzAznaFDYaYgMmjg8aEfkxGkoJmxf6LUWW(zNygSWaSUvyM3veeitU0fg2xUjpDvbO8ycExredbvJdBtLVx2XHcGnvOalma290sIbpWjF1A9HjWGybcDLICfg7gmimbgceSU5f6kehRBomObbvJdBtLVx2XHcotzznq5MaYgMmjyT4hdI(Q5qnOHedEa6r)4m8e0T7zznyED9MarUjwVkE33CjK(ZuwwduUjGSHj7NUxh2MfX7(MlH0tq3UNL1G511Bce5MyD)XcTLkhflIvf64DFZLq6HnvOalma2906pwOTuvCeiqW6wXHcrmeunoSnv(Ezhhk4Cv6wwdkSEYacwojXGhkDHH9NRs3YAqH1tgqWYPFUeseunoSnv(EzhhkqjYY0YAa(6KbKnmzsm4b8kuUavCgzUk0HoE33CjK(Yn5PRkaLhtWFSqBPQO4vHow3kocei4DFZLq6HnvOalma2906pwOTuvC0iwvOJ1TIdfcce8UV5si9WMkuGfga7EA9hl0wQkkoXigeiCYxTwFycmiwGqxXHHrigcQgh2MkFVSJdfWveXpGEFcKyWdyDZl0viow3koObbvJdBtLVx2XHcGnvawyqOZac6wWGWQ5JeSw8JbrF1COg0qIbpG1nVqxH4yDR4WiiOACyBQ89Yoouaw3aLUNkiXGhW6MxORqCSUvCqCeunoSnv(EzhhkaFnM8ZYAqH1tg8SA9iTSMedEO0fg2h6mGfeX3EkaUf1yl2ZRIgtUOMrPkN8vR1hMadIfi0vkYvySBWGWeyIRPkE33CjKEytfkWcdGDpT(JfAlvf5km2nyqycmcQgh2MkFVSJdfewnFar9tGeSw8JbrF1COg0qIbpG1nVqxH4yDR4G4vHUyh9JZWRBbaVcLlei4vOCbQ4mYmXqq14W2u57LDCOaSUbi0Jzsm4b8kuUavCgzgbvJdBtLVx2XHcGFATSgO4teNbGSHjtIbpu6cd7lxYar3I9ZLqsILbFNROyqdcQgh2MkFVSJdfu(Am51naKnmzsWAXpge9vZHAqdjg8aEfkxGkoJmxf6LUWW(YLmq0TyVRiiqI(Xz41TaGxHYTQOJhdQXtVgFy18be1pHQyDBq8Q4DFZLq6HnvOalma2906pwOTu5WiqGG1nVqxH4yDZHbnvfD8yqnE614vISmTSgGVozazdtUkN8vR1hMadIfi0vCyeIHGcbvJdBtLhpbkgEWYXlzguXLtqOZac6wWGWQ5JedEqSh3N1Lp2RVVjOIlNqGaB16b4yH2sLdIxieunoSnvE8eOyyhhkOpCNmi274miXGhW6MxORqCSUvCqdcQgh2MkpEcumSJdfeRlwhSWGj3Hojg8qPlmSxf7ja4(cDqNtaSDSFUeYQI4WxXLtqOZac6wWGWQ5Z34WgZqGaB16b4yH2sLdAGgeiWwTEaowOTuvuJycAiOACyBQ84jqXWoouabUfTPcSWG9M8rIbpa9RTjGhZz475u5TSOyviiqU2MaEmNHVNtL3veXQI39nxcP)mLL1aLBciByY(JfAlvoWvySBWGWeyeunoSnvE8eOyyhhkaU5NLmqfRGism4b8kuUavCgzUk0V2MaEmNHVNtL3YIAGgeixBtapMZW3ZPY7kIyiOACyBQ84jqXWoouaC)ECc2BYhjg8W12eWJ5m89CQ8wwCeObbY12eWJ5m89CQ8UIqq14W2u5XtGIHDCOGYn5PRkaLhtGedE4ABc4XCg(EovEllwiObbY12eWJ5m89CQ8UIi5zjdWZHrdAiOACyBQ84jqXWoouGk2taW9f6GoNay7ysm4b8UV5si9Qypba3xOd6CcGTJ9y9(Qz1G4qGaB16b4yH2sLdIdniqG(12eWJ5m89CQ8hl0wQkQPqqGi24DmNDgEYApRZQqh6xBtapMZW3ZPYBzr8UV5si9Qypba3xOd6CcGTJ9WUVh4ySEF1mimbgceX(ABc4XCg(EovEUIPcfXQcD8UV5si9woEjZGkUCccDgqq3cgewnF(JfAlvfX7(MlH0RI9eaCFHoOZja2o2d7(EGJX69vZGWeyiqg3N1Lp2RVVjOIlNeJyvX7(MlH0dBQqbwyaS7P1FSqBPYHHrPkw3koiEv8UV5si9e0T7zznyED9MarUjw3FSqBPYHbnItmeunoSnvE8eOyyhhkqf7ja4(cDqNtaSDmjg8aEhZzNHNS2Z6Sk0lDHH9e4w0MkWcd2BYN3veeiqh2Q1dWXcTLkhW7(MlH0tGBrBQalmyVjF(JfAlvqGG39nxcPNa3I2ubwyWEt(8hl0wQkI39nxcPxf7ja4(cDqNtaSDSh299ahJ17RMbHjWeRkE33CjKEytfkWcdGDpT(JfAlvommkvX6wXbXRI39nxcPNGUDplRbZRR3eiYnX6(JfAlvomOrCIHGQXHTPYJNafd74qbQypba3xOd6CcGTJjXGhW7(MlH0RI9eaCFHoOZja2o2J17RMvdIdbcSvRhGJfAlvoio0GaP0fg2Ryo0TSgCDn7Dfbbc0X7(MlH0x(2DcwyqOZaozbT(JfAlvoQPiE33CjKEvSNaG7l0bDobW2XEy33dCmwVVAgeMadbIyZkfNy2x(2DcwyqOZaozbTEHUW2JyvX7(MlH0dBQqbwyaS7P1FSqBPYbnqRkw3koiEv8UV5si9e0T7zznyED9MarUjw3FSqBPYbnIJGQXHTPYJNafd74qbUkgyblqs2c8qR0h3jRax7S3dG3RFiOACyBQ84jqXWoouGRIbwWckeunoSnvE8eOyyhhkiwxSoyHbK7tOjXGhGTA9aCSqBPQOMcnkqGiIdFfxobHodiOBbdcRMpFJdBmdbY4(SU8XE99nbvC5ebvJdBtLhpbkg2XHckF7obWUNwsm4b8UV5si9woEjZGkUCccDgqq3cgewnF(JfAlvfhbAqGmUpRlFSxFFtqfxoHab2Q1dWXcTLkhehAiOACyBQ84jqXWoouqjFk(iBznjg8aE33CjKElhVKzqfxobHodiOBbdcRMp)XcTLQIJaniqg3N1Lp2RVVjOIlNqGaB16b4yH2sLdAkecQgh2MkpEcumSJdf8SA9qbkm3zTaNbcQgh2MkpEcumSJdfaBhx(2DsIbpG39nxcP3YXlzguXLtqOZac6wWGWQ5ZFSqBPQ4iqdcKX9zD5J967BcQ4YjeiWwTEaowOTu5GgOHGQXHTPYJNafd74qbDIzvC9dG73JedEaV7BUesVLJxYmOIlNGqNbe0TGbHvZN)yH2svXrGgeiJ7Z6Yh7133euXLtiqGTA9aCSqBPYbXHgcQgh2MkpEcumSJdfu21GfgeNHjRiXGhkDHH9Qypba3xOd6CcGTJ9ZLqIGcbvJdBtLhpbk(40cTdJ7Z6Yhts2c8GIpoTqlO09ubjRObfhKmUFU8aE33CjKEfFCAHw)XcTLkh0abIio8vC5ee6mGGUfmiSA(8noSXCv8UV5si9k(40cT(JfAlvfhbAqGaB16b4yH2sLdIdneunoSnvE8eO4Jtl064qbwoEjZGkUCccDgqq3cgewnFKyWdI94(SU8XE99nbvC5eceyRwpahl0wQCq8cHGQXHTPYJNafFCAHwhhkWvXalybsYwGhAL(4ozf4AN9Ea8E9dbvJdBtLhpbk(40cToouGRIbwWckeunoSnvE8eO4Jtl064qb9H7KbXEhNbjg8aw38cDfIJ1TIdAqq14W2u5XtGIpoTqRJdf8SA9qbkm3zTaNbcQgh2MkpEcu8XPfADCOay74Y3Utsm4HX9zD5J9k(40cTGs3tfiOACyBQ84jqXhNwO1XHc6eZQ46ha3Vhjg8W4(SU8XEfFCAHwqP7PceunoSnvE8eO4Jtl064qbLDnyHbXzyYksm4HX9zD5J9k(40cTGs3tfiOACyBQ84jqXhNwO1XHcI1fRdwyWK7qNedEa2Q1dWXcTLQIAetqdcerC4R4Yji0zabDlyqy185BCyJziqGTA9aCSqBPYbnqdbvJdBtLhpbk(40cToouqSUyDWcdi3NqtIbpaB16b4yH2svXrbAqGiIdFfxobHodiOBbdcRMpFJdBmdbcSvRhGJfAlvoObAiOACyBQ84jqXhNwO1XHciWTOnvGfgS3Kpsm4b8UV5si9NPSSgOCtazdt2FSqBPYbUcJDdgeMaJGQXHTPYJNafFCAHwhhkaU5NLmqfRGieunoSnvE8eO4Jtl064qbW97XjyVjFiOACyBQ84jqXhNwO1XHck3KNUQauEmbeunoSnvE8eO4Jtl064qbk(40cTKyWd4DFZLq6ptzznq5MaYgMS)yH2sLdIdbcSvRhGJfAlvoOPqiOACyBQ84jqXhNwO1XHck7AWcdIZWKviOqq14W2u5xrCY3aSPcWcdcDgqq3cgewnFKG1IFmi67Q5qnOHedEaRBEHUcXX6wXHrqq14W2u5xrCYNJdfWveXpGEFcKyWdr)4m8yDdu6EQWZzx(4zvSU5f6kehRBfhgbbvJdBtLFfXjFoouqy18be1pbsWAXpge9vZHAqdjg8aEfkxGkoJmxfRBEHUcXX6wXbXrq14W2u5xrCYNJdfG1naHEmtIbpG1nVqxH4yDBqCeunoSnv(veN854qbCfr8dO3NacQgh2Mk)kIt(CCOGWQ5diQFcKG1IFmi6RMd1Ggsm4bSU5f6kehRBfhehbfcQgh2MkVIpoTq7aSPcfyHbWUNwsm4HsxyyVIpoTqR)yH2sLdAqq14W2u5v8XPfADCOaxfdSGfijBbEWsf(CJU8XaNz3odxbWKhBygbvJdBtLxXhNwO1XHcCvmWcwGKSf4H5X9e2ogmMvk(HGQXHTPYR4Jtl064qbkrwMwwdWxNmGSHjtIbpGxHYfOIZiZvHEJdBmd4KfmwvCyeiqACyJzaNSGXQIAQk24DFZLq6ptzznq5MaYgMS3veXqq14W2u5v8XPfADCOGZuwwduUjGSHjtcwl(XGOVAoudAiXGhWRq5cuXzKzeunoSnvEfFCAHwhhka2uHcSWay3tljg8qJdBmd4KfmwvCyeeunoSnvEfFCAHwhhkqjYY0YAa(6KbKnmzsm4b8kuUavCgzUAPlmSF2jMblmaRBfM5DfHGQXHTPYR4Jtl064qbLVgtEDdazdtMeSw8JbrF1COg0qIbpGxHYfOIZiZvlDHH9e4w0MkWcd2BYhGabVROQ4DFZLq6ptzznq5MaYgMS)yH2svrXrq14W2u5v8XPfADCOaytfkWcdGDpTKyzW35kkag8q0podVIpoTqRNZU8XZQ4DFZLq6ptzznq5MaYgMS)4EQfbvJdBtLxXhNwO1XHcuISmTSgGVozazdtMedEaVcLlqfNrMRo5sxyyF5M80vfGYJj4DfHGQXHTPYR4Jtl064qbWMkalmi0zabDlyqy18rcwl(XGOVAoudAiXGhW6MdJGGQXHTPYR4Jtl064qbLVgtEDdazdtMeSw8JbrF1COg0qIbpGxHYfOIZiZqGi2r)4m86waWRq5IGQXHTPYR4Jtl064qbkrwMwwdWxNmGSHjJGcbvJdBtLxfde0T7zznyED9MarUjwNedE4ABc4XCg(EovEllI39nxcPNGUDplRbZRR3eiYnX6(P71HTPya08IjiqU2MaEmNHVNtL3vecQgh2MkVkCCOao5R2C2wwd4NvXosm4bSU5f6kehRBfheVkN8vR1hMadIfi0vkoceiyDZl0viow3koiwvHoN8vR1hMadIfi0vkkoeiITOJhdQXtVgFy18be1pbIHGQXHTPYRchhkqjYY0YAa(6KbKnmzsm4b8kuUavCgzUAPlmSF2jMblmaRBfM5Dfvf6xBtapMZW3ZPYBzXsxyy)Stmdwyaw3kmZFSqBPI4IdbY12eWJ5m89CQ8UIigcQgh2MkVkCCOGZuwwduUjGSHjtcwl(XGOVAoudAiXGhW7(MlH0R4Jtl06pwOTuvudeiID0podVIpoTqlcQgh2MkVkCCOaytfkWcdGDpTKyWdq)ABc4XCg(EovEllI39nxcPh2uHcSWay3tRF6EDyBkganVyccKRTjGhZz475u5DfrSQqNt(Q16dtGbXce6kf5km2nyqycmX1abcw38cDfIJ1nhg0absPlmSxf7ja4(cDqNtaSDS)yH2sLdCfg7gmimb2rnedceyRwpahl0wQCGRWy3GbHjWoQbbvJdBtLxfooua(Am5NL1GcRNm4z16rAznjg8qPlmSp0zaliIV9uaClQXwSNxfnMCrnJsvo5RwRpmbgelqORuKRWy3GbHjWextv8UV5si9NPSSgOCtazdt2FSqBPQixHXUbdctGHaP0fg2h6mGfeX3EkaUf1yl2ZRIgtUOgXQk0X7(MlH0R4Jtl06pwOTu5qHQg9JZWR4Jtl0cbcE33CjKEcClAtfyHb7n5ZFSqBPYHcvfVJ5SZWtw7zDcbcSvRhGJfAlvouiIHGQXHTPYRchhk4Cv6wwdkSEYacwojXGhkDHH9NRs3YAqH1tgqWYPFUeYQnoSXmGtwWyvrniOACyBQ8QWXHcGnvawyqOZac6wWGWQ5JeSw8JbrF1COg0qIbpG1nhgbbvJdBtLxfoouaxre)a69jqIbpG1nVqxH4yDR4GgeunoSnvEv44qbyDdu6EQGedEaRBEHUcXX6wXbnvBCyJzaNSGXQbnvV2MaEmNHVNtL3YIIdniqW6MxORqCSUvCq8QnoSXmGtwWyvXbXrq14W2u5vHJdfG1naHEmJGQXHTPYRchhkiSA(aI6NajyT4hdI(Q5qnOHesm4b8kuUavCgzUkw38cDfIJ1TIdIxT0fg2RI9eaCFHoOZja2o2pxcjcQgh2MkVkCCOaLiltlRb4Rtgq2WKjXGhkDHH9yDdWjF1A9QOXKloc0iEHedACyJzaNSGXQQLUWWEvSNaG7l0bDobW2X(5siRcD8UV5si9NPSSgOCtazdt2FSqBPQO4vX7(MlH0dBQqbwyaS7P1FSqBPQO4qGG39nxcP)mLL1aLBciByY(JfAlvomsv8UV5si9WMkuGfga7EA9hl0wQkosvSUvCeiqW7(MlH0FMYYAGYnbKnmz)XcTLQIJufV7BUespSPcfyHbWUNw)XcTLkhgPkw3kkwqGG1nVqxH4yDZHbnv5KVAT(WeyqSaHUIdItmiqkDHH9yDdWjF1A9QOXKlQbAvHTA9aCSqBPYbXicQgh2MkVkCCOGYxJjVUbGSHjtcwl(XGOVAoudAiXGhWRq5cuXzK5Qqp6hNHxXhNwOTkE33CjKEfFCAHw)XcTLkhgbce8UV5si9NPSSgOCtazdt2FSqBPQOMQ4DFZLq6HnvOalma2906pwOTuvudei4DFZLq6ptzznq5MaYgMS)yH2sLdJufV7BUespSPcfyHbWUNw)XcTLQIJufRBffhce8UV5si9NPSSgOCtazdt2FSqBPQ4ivX7(MlH0dBQqbwyaS7P1FSqBPYHrQI1TIJabcw3kwiiqkDHH9LlzGOBXExredbvJdBtLxfoouqy18be1pbsWAXpge9vZHAqdjKyWd4vOCbQ4mYCvSU5f6kehRBfhehbvJdBtLxfooua8tRL1afFI4maKnmzsSm47CffdAqqjgIKotqXiPtRZersdgjhD3rxK0uij(Tkgj7CIKAxxKuVhZiP4ijw3qYoNiP219qYxRcKS(TL9djj0kKKuNPibj3djnyKu76IK9XizxUUbsglsIBrijN8vRfj7CIKSf68HKAx3djFTkqYA8ejj0kKKuNPqY9qsdgj1UUizFms(yLcjd9orsXrsSUHKnHwlscFRasIBrISSgbvJdBtLxfoouq5RXKx3aq2WKjbRf)yq0xnhQbnKyWd4vOCbQ4mYCv8UV5si9WMkuGfga7EA9hl0wQCyKQyDBq8QIoEmOgp9A8HvZhqu)eQYjF1A9HjWGybfcAoObbvJdBtLxfoouq5RXKx3aq2WKjbRf)yq0xnhQbnKyWd4vOCbQ4mYCvo5RwRpmbgelqOR4G4vHow38cDfIJ1nhg0abIOJhdQXtVgFy18be1pbIHGcbvJdBtLNa3I2ubwyWEt(gW97bACyBcEMkijBbEapbkgMedEqSJ(Xz4v8XPfArq14W2u5jWTOnvGfgS3Kphhka3VhOXHTj4zQGKSf4b8eO4Jtl0sIbpe9JZWR4Jtl0IGQXHTPYtGBrBQalmyVjFoouaN8vBoBlRb8ZQyhjg8aw38cDfIJ1TIdIxLt(Q16dtGbXce6kfhbbvJdBtLNa3I2ubwyWEt(CCOGZuwwduUjGSHjtcwl(XGOVAoudAqq14W2u5jWTOnvGfgS3KphhkqjYY0YAa(6KbKnmzsm4b8kuUavCgzUAPlmSF2jMblmaRBfM5DfHGQXHTPYtGBrBQalmyVjFoouaSPcfyHbWUNwsm4Hgh2ygWjlySQ4G4vlDHH9e4w0MkWcd2BYhGab)XcTLkh0GGQXHTPYtGBrBQalmyVjFoouabD7EwwdMxxVjqKBI1jXGhACyJzaNSGXQIdIJGQXHTPYtGBrBQalmyVjFoouGsKLPL1a81jdiByYKyWd4vOCbQ4mYC1gh2ygWjlySQ4WivlDHH9e4w0MkWcd2BYhGabVRieunoSnvEcClAtfyHb7n5ZXHckFnM86gaYgMmjyT4hdI(Q5qnOHedEaVcLlqfNrMR24WgZaozbJvomiocQgh2MkpbUfTPcSWG9M854qbe0T7zznyED9MarUjwhbvJdBtLNa3I2ubwyWEt(CCOaytfkWcdGDpTKyzW35kkag8qPlmSNa3I2ubwyWEt(aei4DfrIbpu6cd7vXEcaUVqh05eaBh7Dfv9ABc4XCg(EovEllI39nxcPh2uHcSWay3tRF6EDyBkgan)OHGQXHTPYtGBrBQalmyVjFoouGsKLPL1a81jdiByYKyWdLUWWESUb4KVATEv0yYfhbAeVqIbnoSXmGtwWyfcQgh2MkpbUfTPcSWG9M854qbWMkalmi0zabDlyqy18rcwl(XGOVAoudAiXGhW6MdJGGQXHTPYtGBrBQalmyVjFoouaxre)a69jqIbpG1nVqxH4yDR4GgeunoSnvEcClAtfyHb7n5ZXHcW6gO09ubjg8aw38cDfIJ1TIdqxJJnoSXmGtwWyvrnedbvJdBtLNa3I2ubwyWEt(CCOGWQ5diQFcKG1IFmi6RMd1Ggsm4bOl2r)4m86waWRq5cbcEfkxGkoJmtSQyDZl0viow3koiocQgh2MkpbUfTPcSWG9M854qbyDdqOhZiOACyBQ8e4w0MkWcd2BYNJdfu(Am51naKnmzsWAXpge9vZHAqdjg8aw3komceiLUWWEcClAtfyHb7n5dqGG3vecQgh2MkpbUfTPcSWG9M854qbWpTwwdu8jIZaq2WKjXYGVZvumOHg0Gsb]] )

end