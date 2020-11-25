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
            id = 201318,
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

        potion = "unbridled_fury",

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

    spec:RegisterSetting( "tok_damage", 80, {
        name = "Required Damage for |T651728:0|t Touch of Karma",
        desc = "If set above zero, |T651728:0|t Touch of Karma will only be recommended while you have incoming damage.",
        type = "range",
        min = 0,
        max = 99,
        step = 0.1,
        width = "full",
    } )
    
    spec:RegisterPack( "Windwalker", 20201123, [[dq0fgcqiQu5rKOK2KuXOGK6uOiwfjkYRiHMfkQBHI0UOQFrLYWKk1XOswgKYZKkzAqs6AKOABKOW3irPghvQQZbjH5ra3tQAFQihKefLSqsKhsIIsDrsuISrsucDssuu1kjqVKefv6MKOeStivdLeLOEQknvsWvjrrfFLeff7fQ)cmysDyjlMkEmOjRWLr2meFwknAs60uwnvQYRjOzROBJs7w0VvA4eYYv1ZjA6cxxk2oK47OW4vrDEc16HKO5Rc7hvJDHvaFhvqy0rRB062Ll06Y7s5OA3OQYaFdXIi8vubfwTe(MflHVkZy5Grnfsp(kQep3AGvaFLBZdj8fFDASzOmFIDW3rfegD06gTUD5cTU8UuoQ2nQ2f(kfrqm6OPmqf4RQnguIDW3bjH4RYkxRmJLdg1ui9CTYcBkKlOYkxJ(IcX6qpxJwxmZ1O1nADJVttgsSc47kIs6XkGr3fwb8LYYzsdSs4BbdBt8fXKbyraHkbyOAbbcRLE8f(wqVv4lu18S1zUMPCnu146t9CDx4lumCsGO(VLcj(6chy0rdRa(sz5mPbwj8f(wqVv4Butkdpu1aonVm8uwotAW1D4AOQ5zRZCnt5AOQX1N656UW3cg2M4lDwenbQ1ZIdm6DHvaFPSCM0aRe(wWW2eFdRLEGOAYIVW3c6TcFHlRZcKXBcjUUdxdvnpBDMRzkxdvnU(upxJg(cfdNeiQVLcjgDx4aJoQIvaFPSCM0aRe(cFlO3k8fQAE26mxZuUgQACDpxJg(wWW2eFHQgGrHcHdm6khRa(wWW2eFPZIOjqTEw8LYYzsdSs4aJUYaRa(sz5mPbwj8TGHTj(gwl9ar1KfFHVf0Bf(cvnpBDMRzkxdvnU(upxJg(cfdNeiQVLcjgDx4ah4ldQeTPeSiG9h0JvaJUlSc4lLLZKgyLWx4Bb9wHVUJRJAsz4L0tPfI9uwotAGVfmSnXxynNGcg2MGPjd8DAYaKflHVWbqsi4aJoAyfWxklNjnWkHVW3c6TcFJAsz4L0tPfI9uwotAGVfmSnXxynNGcg2MGPjd8DAYaKflHVWbqspLwighy07cRa(sz5mPbwj8f(wqVv4lu18S1zUMPCnu146t9CnACDhUMs6Bf7dJLaXcyRZC9jUUl8TGHTj(sj9TgQ0YwanTZ2Jdm6Okwb8LYYzsdSs4BbdBt89nPLTaztceAqH4lumCsGO(wkKy0DHdm6khRa(sz5mPbwj8f(wqVv4lQ5A3X1rnPm8QwaGlRZ6PSCM0GR7W1Wnhnw4H1e2mRGgaz8Mqs6PSCM0GRpo4A4Y6Saz8MqIRzcx3HRDAqq8JkHeyraqvZ9mFJi8TGHTj(kfzzAzla(vsaHguioWORmWkGVuwotAGvcFHVf0Bf(wWWqHausSgj56t9CnACDhU2PbbXZGkrBkblcy)b9agm8pXwwk5Ab4Ax4BbdBt8fXKHeSiaKMxmoWORSXkGVuwotAGvcFHVf0Bf(wWWqHausSgj56t9CnA4BbdBt8LHQ9tlBbJVA3eiQjHQ4aJU7JvaFPSCM0aRe(cFlO3k8f1CT746OMugEvlaWL1z9uwotAW1D4A4MJgl8WAcBMvqdGmEtij9uwotAW1hhCnCzDwGmEtiX1mHR7W1fmmuiaLeRrsU(upx3fx3HRDAqq8mOs0MsWIa2FqpGbdFJi8TGHTj(kfzzAzla(vsaHguioWOJkWkGVuwotAGvcFlyyBIVoZckCBcGqdkeFHVf0Bf(cxwNfiJ3esCDhUUGHHcbOKynsY1c0Z1OHVqXWjbI6BPqIr3foWO7QBSc4BbdBt8LHQ9tlBbJVA3eiQjHQ4lLLZKgyLWbgDxUWkGVuwotAGvcFHVf0Bf(60GG4LX(SaQ(qfu5aGyp5BeX1D46VSbGqHYWxJH0BjxFIRH7ohlJ0JyYqcweasZl2pA(kSn5ALjUUBVYaFlyyBIViMmKGfbG08IXxld6)grb(6chy0DHgwb8LYYzsdSs4l8TGERWxNgeepu1ausFRyVmkOqU(ex3v3Cnt5ALZ1ktCDbddfcqjXAKeFlyyBIVsrwMw2cGFLeqObfIdm6U6cRa(sz5mPbwj8TGHTj(IyYaSiGqLamuTGaH1sp(cFlO3k8fQACTaCDx4lumCsGO(wkKy0DHdm6UqvSc4lLLZKgyLWx4Bb9wHVqvZZwN5AMY1qvJRp1Z1UW3cg2M4lDwenbQ1ZIdm6Uuowb8LYYzsdSs4l8TGERWxOQ5zRZCnt5AOQX1N65AuZ1U4Af56cggkeGsI1ijxFIRDX1mbFlyyBIVqvd408Yahy0DPmWkGVuwotAGvcFlyyBIVH1spqunzXx4Bb9wHVOMRDhxh1KYWRAbaUSoRNYYzsdU(4GRHlRZcKXBcjUMjCDhUgQAE26mxZuUgQAC9PEUgn8fkgojquFlfsm6UWbgDxkBSc4BbdBt8fQAagfke(sz5mPbwjCGr3L7JvaFPSCM0aRe(wWW2eFDMfu42eaHgui(cFlO3k8fQAC9PEUUlU(4GRDAqq8mOs0MsWIa2FqpGbdFJi8fkgojquFlfsm6UWbgDxOcSc4RLb9FJOaFDHVfmSnXxKPylBbs6frzaeAqH4lLLZKgyLWboWxj9uAHyScy0DHvaFPSCM0aRe(cFlO3k81PbbXlPNsle7FITSuY1cW1UW3cg2M4lIjdjyrainVyCGrhnSc4lLLZKgyLW3Syj8TKQOujjbFHk3ha3VM4BbdBt8TKQOujjbFHk3ha3VM4aJExyfWxklNjnWkHVW3c6TcFrnx7oUoQjLHx1caCzDwpLLZKgCDhUgU5OXcpSMWMzf0aiJ3esspLLZKgC9XbxdxwNfiJ3esCnt46oCnQ56cggkeGsI1ijxFQNR7IRpo46cggkeGsI1ijxFIRDX1D4A3X1WDNJLr6FtAzlq2KaHguOVrexZe8TGHTj(kfzzAzla(vsaHguioWOJQyfWxklNjnWkHVfmSnX33Kw2cKnjqObfIVW3c6TcFHlRZcKXBcj8fkgojquFlfsm6UWbgDLJvaFPSCM0aRe(cFlO3k8TGHHcbOKynsY1N656UW3cg2M4lIjdjyrainVyCGrxzGvaFPSCM0aRe(cFlO3k8f1CT746OMugEvlaWL1z9uwotAW1D4A4MJgl8WAcBMvqdGmEtij9uwotAW1hhCnCzDwGmEtiX1mHR7W1onii(rLqcSiaOQ5EMVre(wWW2eFLISmTSfa)kjGqdkehy0v2yfWxklNjnWkHVfmSnXxNzbfUnbqObfIVW3c6TcFrnxdxwNfiJ3esC9Xbx7oUoQjLHx1caCzDwpLLZKgCnt46oCTtdcINbvI2ucweW(d6bmy4BeX1D4A4UZXYi9VjTSfiBsGqdk0)eBzPKRpX1OHVqXWjbI6BPqIr3foWO7(yfWxld6)grb(6cFlyyBIViMmalciujadvliqyT0JVuwotAGvchy0rfyfWxklNjnWkHVW3c6TcFrnx7oUoQjLHx1caCzDwpLLZKgCDhUgU5OXcpSMWMzf0aiJ3esspLLZKgC9XbxdxwNfiJ3esCnt46oC9GCAqq8oBsJgzaCEIHVre(wWW2eFLISmTSfa)kjGqdkehy0D1nwb8LYYzsdSs4BbdBt8fXKbyraHkbyOAbbcRLE8f(wqVv4lu14Ab46UWxOy4Kar9TuiXO7chy0D5cRa(sz5mPbwj8TGHTj(6mlOWTjacnOq8f(wqVv4lCzDwGmEtiX1hhCT746OMugEvlaWL1z9uwotAGVqXWjbI6BPqIr3foWO7cnSc4BbdBt8vkYY0Ywa8RKacnOq8LYYzsdSs4ah4lCaK0tPfIXkGr3fwb8LYYzsdSs47kcFLuGVfmSnXxuQ3kNjHVOuZgcFH7ohlJ0lPNsle7FITSuY1cW1U46JdUwef(ZnuccvcWq1ccewl9(cggkex3HRH7ohlJ0lPNsle7FITSuY1N46U6MRpo4AeRvnapXwwk5Ab4A06gFrPEqwSe(kPNsledCAEzGdm6OHvaFPSCM0aRe(cFlO3k81DCnk1BLZK8Q7Cao3qjxFCW1iwRAaEITSuY1cW1OPC8TGHTj(AjkRqcCUHsCGrVlSc4lLLZKgyLW3Syj8TKQOujjbFHk3ha3VM4BbdBt8TKQOujjbFHk3ha3VM4aJoQIvaFlyyBIVnscybXkXxklNjnWkHdm6khRa(sz5mPbwj8f(wqVv4lk1BLZK8s6P0cXaNMxg4BbdBt81zU7aG08IXbgDLbwb8LYYzsdSs4l8TGERWxuQ3kNj5L0tPfIbonVmW3cg2M4Rd9s6fAzloWORSXkGVuwotAGvcFHVf0Bf(IyTQb4j2YsjxFIRD5(kNRpo4AuQ3kNj5L0tPfIbonVm46JdUgXAvdWtSLLsUwaUUlLJVfmSnX32M6hwLGfbuOs63qfhy0DFSc4lLLZKgyLWx4Bb9wHVOuVvotYlPNsledCAEzGVfmSnXxg7phOqwcEsUzLqchy0rfyfWxklNjnWkHVW3c6TcFrPERCMKxspLwig408YaFlyyBIVoZDhGfbeQeGsIvmoWO7QBSc4lLLZKgyLWx4Bb9wHVOMRH7ohlJ0lPNsle7FITSuY1hhCnC35yzKE4MqkJVcAaqMfl5HQ13ssUUNRrJRzcx3HRDhxp2Wd3esz8vqdaYSyjGtZN(NyllLCDhUg1CnC35yzK(3Kw2cKnjqObf6FITSuY1D4A4UZXYi9iMmKGfbG08I9pXwwk56JdUgXAvdWtSLLsUwaU295AMGVfmSnXx4MqkJVcAaqMflHdm6UCHvaFlyyBIVHkbAsNTjhaK9He(sz5mPbwjCGr3fAyfW3cg2M4ROM3qeBzlWzwYaFPSCM0aReoWO7QlSc4lLLZKgyLWx4Bb9wHVr9Tu4dJLaXcebdaADZ1N46U6MRpo46O(wk8QundvViyW1c0Z1O1nxFCW1r9Tu4dJLaXcggX1cW1OHVfmSnX3Nkrw2cqMfljXbgDxOkwb8TGHTj(ISWgjnafQKEliGdvS4lLLZKgyLWbgDxkhRa(sz5mPbwj8f(wqVv4lL03kMRfGRr1UX3cg2M4llXUVyWIaMnqBagpvSsCGr3LYaRa(wWW2eFFtKOjbSeifvqcFPSCM0aReoWO7szJvaFPSCM0aRe(cFlO3k8fQAE26mxZuUgQAC9PEU2f(wWW2eFRhwjbI9FkdCGr3L7JvaFlyyBIVtRvnKa3Rz0YszGVuwotAGvchy0DHkWkGVuwotAGvcFHVf0Bf(Is9w5mjVKEkTqmWP5Lb(wWW2eFrSNCM7oWbgD06gRa(sz5mPbwj8f(wqVv4lk1BLZK8s6P0cXaNMxg4BbdBt8TsijJVMaynN4aJoAUWkGVuwotAGvcFHVf0Bf(Is9w5mjVKEkTqmWP5Lb(wWW2eFDQwWIaI3GcL4aJoAOHvaFPSCM0aRe(cFlO3k8fXAvdWtSLLsU(ex7Y97MRpo4Aru4p3qjiujadvliqyT07lyyOqC9XbxJyTQb4j2Ysjxlax7QB8TGHTj(gBdufSiGbvHkoWOJwxyfWxklNjnWkHVW3c6TcFrSw1a8eBzPKRpX1OIU56JdUwef(ZnuccvcWq1ccewl9(cggkexFCW1iwRAaEITSuY1cW1U6gFlyyBIVX2avblcqy9SfoWOJgQIvaFPSCM0aRe(cFlO3k8fU7CSms)BslBbYMei0Gc9pXwwk5Ab4A6mbBcceglHVfmSnXxgujAtjyra7pOhhy0rt5yfW3cg2M4lsrtljGmwwr4lLLZKgyLWbgD0ugyfW3cg2M4lsnNuc2Fqp(sz5mPbwjCGrhnLnwb8TGHTj(6SjnAKbW5jg4lLLZKgyLWbgD0CFSc4lLLZKgyLWx4Bb9wHVWDNJLr6FtAzlq2KaHguO)j2YsjxlaxJgxFCW1iwRAaEITSuY1cW1Uuo(wWW2eFL0tPfIXbgD0qfyfW3cg2M4Rt1cweq8guOeFPSCM0aReoWb(kdScy0DHvaFPSCM0aRe(cFlO3k89lBaiuOm81yi9wY1N4A4UZXYi9muTFAzly8v7Marnju1pA(kSn5ALjUUBV7Z1hhC9x2aqOqz4RXq6BeHVfmSnXxgQ2pTSfm(QDtGOMeQIdm6OHvaFPSCM0aRe(cFlO3k8fQAE26mxZuUgQAC9PEUgnUUdxtj9TI9HXsGybS1zU(ex3fxFCW1qvZZwN5AMY1qvJRp1Z1Okx3HRrnxtj9TI9HXsGybS1zU(exJgxFCW1UJRf9ekGw4W7Yhwl9ar1KLRzc(wWW2eFPK(wdvAzlGM2z7Xbg9UWkGVuwotAGvcFHVf0Bf(IAU2DCDutkdVQfa4Y6SEklNjn46oCnCZrJfEynHnZkObqgVjKKEklNjn46JdUgUSolqgVjK4AMW1D4ANgee)Osibweau1CpZ3iIR7W1OMR)YgacfkdFngsVLC9jU2PbbXpQesGfbavn3Z8pXwwk5AMY1OX1hhC9x2aqOqz4RXq6BeX1mbFlyyBIVsrwMw2cGFLeqObfIdm6Okwb8LYYzsdSs4BbdBt89nPLTaztceAqH4l8TGERWx4UZXYi9s6P0cX(NyllLC9jU2fxFCW1UJRJAsz4L0tPfI9uwotAGVqXWjbI6BPqIr3foWORCSc4lLLZKgyLWx4Bb9wHVOMR)YgacfkdFngsVLC9jUgU7CSmspIjdjyrainVy)O5RW2KRvM46U9UpxFCW1FzdaHcLHVgdPVrexZeUUdxJAUMs6Bf7dJLaXcyRZC9jUMotWMGaHXsCnt5AxC9XbxdvnpBDMRzkxdvnUwGEU2fxFCW1oniiEzSplGQpubvoai2t(NyllLCTaCnDMGnbbcJL4Af5AxCnt46JdUgXAvdWtSLLsUwaUMotWMGaHXsCTICTl8TGHTj(IyYqcweasZlghy0vgyfWxklNjnWkHVW3c6TcFDAqq8Hkbiwr0VVealrf0I99YOGc56tCTlubx3HRPK(wX(WyjqSa26mxFIRPZeSjiqySexZuU2fx3HRH7ohlJ0)M0YwGSjbcnOq)tSLLsU(extNjytqGWyjU(4GRDAqq8Hkbiwr0VVealrf0I99YOGc56tCTluLR7W1OMRH7ohlJ0lPNsle7FITSuY1cW1kNR7W1rnPm8s6P0cXEklNjn46JdUgU7CSmspdQeTPeSiG9h07FITSuY1cW1kNR7W1WffkRm8cf)wLC9XbxJyTQb4j2YsjxlaxRCUMj4BbdBt8f(fu40YwG7vdcmTw1iTSfhy0v2yfWxklNjnWkHVW3c6TcFDAqq8FJu1YwG7vdcWWYHFSmsUUdxxWWqHausSgj56tCTl8TGHTj((nsvlBbUxniadlh4aJU7JvaFPSCM0aRe(wWW2eFrmzaweqOsagQwqGWAPhFHVf0Bf(cvnUwaUUl8fkgojquFlfsm6UWbgDubwb8LYYzsdSs4l8TGERWxOQ5zRZCnt5AOQX1N65Ax4BbdBt8LolIMa16zXbgDxDJvaFPSCM0aRe(cFlO3k8fQAE26mxZuUgQAC9PEU2fx3HRlyyOqakjwJKCDpx7IR7W1FzdaHcLHVgdP3sU(exJw3C9XbxdvnpBDMRzkxdvnU(upxJgx3HRlyyOqakjwJKC9PEUgn8TGHTj(cvnGtZldCGr3LlSc4BbdBt8fQAagfke(sz5mPbwjCGr3fAyfWxklNjnWkHVfmSnX3WAPhiQMS4l8TGERWx4Y6Saz8MqIR7W1qvZZwN5AMY1qvJRp1Z1OX1D4ANgeeVm2Nfq1hQGkhae7j)yzK4lumCsGO(wkKy0DHdm6U6cRa(sz5mPbwj8f(wqVv4RtdcIhQAakPVvSxgfuixFIR7QBUMPCTY5ALjUUGHHcbOKynsY1D4ANgeeVm2Nfq1hQGkhae7j)yzKCDhUg1CnC35yzK(3Kw2cKnjqObf6FITSuY1N4A046oCnC35yzKEetgsWIaqAEX(NyllLC9jUgnU(4GRH7ohlJ0)M0YwGSjbcnOq)tSLLsUwaUUlUUdxd3DowgPhXKHeSiaKMxS)j2YsjxFIR7IR7W1qvJRpX1DX1hhCnC35yzK(3Kw2cKnjqObf6FITSuY1N46U46oCnC35yzKEetgsWIaqAEX(NyllLCTaCDxCDhUgQAC9jUgv56JdUgQAE26mxZuUgQACTa9CTlUUdxtj9TI9HXsGybS1zUwaUgnUMjC9Xbx70GG4HQgGs6Bf7LrbfY1N4AxDZ1D4AeRvnapXwwk5Ab4ALn(wWW2eFLISmTSfa)kjGqdkehy0DHQyfWxklNjnWkHVfmSnXxNzbfUnbqObfIVW3c6TcFHlRZcKXBcjUUdxJAUoQjLHxspLwi2tz5mPbx3HRH7ohlJ0lPNsle7FITSuY1cW1DX1hhCnC35yzK(3Kw2cKnjqObf6FITSuY1N4AxCDhUgU7CSmspIjdjyrainVy)tSLLsU(ex7IRpo4A4UZXYi9VjTSfiBsGqdk0)eBzPKRfGR7IR7W1WDNJLr6rmziblcaP5f7FITSuY1N46U46oCnu146tCnAC9Xbxd3DowgP)nPLTaztceAqH(NyllLC9jUUlUUdxd3DowgPhXKHeSiaKMxS)j2Ysjxlax3fx3HRHQgxFIR7IRpo4AOQX1N4ALZ1hhCTtdcI3zfce9l03iIRzc(cfdNeiQVLcjgDx4aJUlLJvaFPSCM0aRe(wWW2eFdRLEGOAYIVW3c6TcFHlRZcKXBcjUUdxdvnpBDMRzkxdvnU(upxJg(cfdNeiQVLcjgDx4aJUlLbwb81YG(VruGVUW3cg2M4lYuSLTaj9IOmacnOq8LYYzsdSs4aJUlLnwb8LYYzsdSs4BbdBt81zwqHBtaeAqH4l8TGERWx4Y6Saz8MqIR7W1WDNJLr6rmziblcaP5f7FITSuY1cW1DX1D4AOQX19CnACDhUw0tOaAHdVlFyT0devtwUUdxtj9TI9HXsGybkVBUwaU2f(cfdNeiQVLcjgDx4aJUl3hRa(sz5mPbwj8TGHTj(6mlOWTjacnOq8f(wqVv4lCzDwGmEtiX1D4AkPVvSpmwcelGToZ1cW1OX1D4AuZ1qvZZwN5AMY1qvJRfONRDX1hhCTONqb0chEx(WAPhiQMSCntWxOy4Kar9TuiXO7ch4aFHdGKqWkGr3fwb8LYYzsdSs4l8TGERWx3X1OuVvotYRUZb4CdLC9XbxJyTQb4j2YsjxlaxJMYX3cg2M4RLOScjW5gkXbgD0WkGVuwotAGvcFHVf0Bf(cvnpBDMRzkxdvnU(upx7cFlyyBIV1dRKaX(pLboWO3fwb8LYYzsdSs4l8TGERWxNgeeVm2Nfq1hQGkhae7j)yzKCDhUwef(ZnuccvcWq1ccewl9(cggkexFCW1iwRAaEITSuY1cW1U6MRpo4AeRvnapXwwk56tCTl3VB8TGHTj(gBdufSiGbvHkoWOJQyfWxklNjnWkHVW3c6TcFrnx)Lnaekug(AmKEl56tCnQQCU(4GR)YgacfkdFngsFJiUMjCDhUgU7CSms)BslBbYMei0Gc9pXwwk5Ab4A6mbBcceglHVfmSnXxgujAtjyra7pOhhy0vowb8LYYzsdSs4l8TGERWx4Y6Saz8MqIR7W1OMR)YgacfkdFngsVLC9jU2v3C9Xbx)Lnaekug(AmK(grCntW3cg2M4lsrtljGmwwr4aJUYaRa(sz5mPbwj8f(wqVv47x2aqOqz4RXq6TKRpX1D1nxFCW1FzdaHcLHVgdPVre(wWW2eFrQ5KsW(d6XbgDLnwb8LYYzsdSs4l8TGERW3VSbGqHYWxJH0BjxFIRvE3C9Xbx)Lnaekug(AmK(gr4BbdBt81ztA0idGZtmW3PLeaoWxLr34aJU7JvaFPSCM0aRe(cFlO3k8fU7CSmsVm2Nfq1hQGkhae7jpuT(wsY19CnAC9XbxJyTQb4j2YsjxlaxJw3C9XbxJAU(lBaiuOm81yi9pXwwk56tCTlLZ1hhCT74A4IcLvgEHIFRsUUdxJAUg1C9x2aqOqz4RXq6TKRpX1WDNJLr6LX(SaQ(qfu5aGyp5rAMtWtq16BjqySexFCW1UJR)YgacfkdFngspD2KHKRzcx3HRrnxd3DowgP3suwHe4CdLGqLamuTGaH1sV)j2YsjxFIRH7ohlJ0lJ9zbu9HkOYbaXEYJ0mNGNGQ13sGWyjU(4GRrPERCMKxDNdW5gk5AMW1mHR7W1WDNJLr6rmziblcaP5f7FITSuY1c0Z1OcUUdxdvnU(upxJgx3HRH7ohlJ0Zq1(PLTGXxTBce1Kqv)tSLLsUwGEU2fACntW3cg2M4Rm2Nfq1hQGkhae7jCGrhvGvaFPSCM0aRe(cFlO3k8fUOqzLHxO43QKR7W1OMRDAqq8mOs0MsWIa2FqVVrexFCW1OMRrSw1a8eBzPKRfGRH7ohlJ0ZGkrBkblcy)b9(NyllLC9Xbxd3DowgPNbvI2ucweW(d69pXwwk56tCnC35yzKEzSplGQpubvoai2tEKM5e8euT(wceglX1mHR7W1WDNJLr6rmziblcaP5f7FITSuY1c0Z1OcUUdxdvnU(upxJgx3HRH7ohlJ0Zq1(PLTGXxTBce1Kqv)tSLLsUwGEU2fACntW3cg2M4Rm2Nfq1hQGkhae7jCGr3v3yfWxklNjnWkHVW3c6TcFH7ohlJ0JyYqcweasZl2)eBzPKRfGRrJRpo4AeRvnapXwwk5Ab4AxOHVfmSnXxN5UdWIacvcqjXkghy0D5cRa(wWW2eFBBQFyvcweqHkPFdv8LYYzsdSs4aJUl0WkGVfmSnXxg7phOqwcEsUzLqcFPSCM0aReoWO7QlSc4lLLZKgyLWx4Bb9wHVUJRhB4HBcPm(kObazwSeWP5t)tSLLsUUdxJAUg1CT746OMugEgQ2pTSfm(QDtGOMeQ6PSCM0GRpo4A4UZXYi9muTFAzly8v7Marnju1)eBzPKRzcx3HRH7ohlJ0)M0YwGSjbcnOq)tSLLsUUdxd3DowgPhXKHeSiaKMxS)j2Ysjx3HRDAqq8YyFwavFOcQCaqSN8JLrY1mHRpo4AeRvnapXwwk5Ab4A3hFlyyBIVWnHugFf0aGmlwchy0DHQyfW3cg2M4BOsGM0zBYbazFiHVuwotAGvchy0DPCSc4BbdBt8vuZBiITSf4mlzGVuwotAGvchy0DPmWkGVuwotAGvcFHVf0Bf(g13sHpmwcelqemaO1nxFIR7QBU(4GRJ6BPWRs1mu9IGbxlqpxJw34BbdBt89PsKLTaKzXssCGr3LYgRa(wWW2eFrwyJKgGcvsVfeWHkw8LYYzsdSs4aJUl3hRa(sz5mPbwj8f(wqVv4lL03kMRfGRr1UX3cg2M4llXUVyWIaMnqBagpvSsCGr3fQaRa(wWW2eFFtKOjbSeifvqcFPSCM0aReoWOJw3yfWxklNjnWkHVW3c6TcFH7ohlJ0lJ9zbu9HkOYbaXEYdvRVLKCDpxJgxFCW1iwRAaEITSuY1cW1O1nxFCW1oniiEjrHQLTGVAjFJiU(4GRrnxd3DowgP3zU7aSiGqLausSI9pXwwk5Af5AxC9jUgU7CSmsVm2Nfq1hQGkhae7jpsZCcEcQwFlbcJL46JdU2DCnjLucjVZC3byraHkbOKyf7zl3BFUMjCDhUgU7CSmspIjdjyrainVy)tSLLsUwaU2v3CDhUgQAC9PEUgnUUdxd3DowgPNHQ9tlBbJVA3eiQjHQ(NyllLCTaCTl0W3cg2M4Rm2Nfq1hQGkhae7jCGrhnxyfWxklNjnWkHVzXs4BjvrPssc(cvUpaUFnX3cg2M4BjvrPssc(cvUpaUFnXbgD0qdRa(wWW2eFBKeWcIvIVuwotAGvchy0rRlSc4lLLZKgyLWx4Bb9wHViwRAaEITSuY1N4AxkhvW1hhCTik8NBOeeQeGHQfeiSw69fmmuiU(4GRrPERCMKxDNdW5gkX3cg2M4BSnqvWIaewpBHdm6OHQyfWxklNjnWkHVW3c6TcFH7ohlJ0BjkRqcCUHsqOsagQwqGWAP3)eBzPKRpX1D1nxFCW1OuVvotYRUZb4CdLC9XbxJyTQb4j2YsjxlaxJw34BbdBt81zU7aG08IXbgD0uowb8LYYzsdSs4l8TGERWx4UZXYi9wIYkKaNBOeeQeGHQfeiSw69pXwwk56tCDxDZ1hhCnk1BLZK8Q7Cao3qjxFCW1iwRAaEITSuY1cW1Uuo(wWW2eFDOxsVqlBXbgD0ugyfW3cg2M470AvdjW9AgTSug4lLLZKgyLWbgD0u2yfWxklNjnWkHVW3c6TcFH7ohlJ0BjkRqcCUHsqOsagQwqGWAP3)eBzPKRpX1D1nxFCW1OuVvotYRUZb4CdLC9XbxJyTQb4j2Ysjxlax7QB8TGHTj(Iyp5m3DGdm6O5(yfWxklNjnWkHVW3c6TcFH7ohlJ0BjkRqcCUHsqOsagQwqGWAP3)eBzPKRpX1D1nxFCW1OuVvotYRUZb4CdLC9XbxJyTQb4j2YsjxlaxJw34BbdBt8TsijJVMaynN4aJoAOcSc4lLLZKgyLWx4Bb9wHVoniiEzSplGQpubvoai2t(XYiX3cg2M4Rt1cweq8guOeh4aFhes1mdScy0DHvaFlyyBIVsru9a1khaz8MqcFPSCM0aReoWOJgwb8LYYzsdSs47kcFLuGVfmSnXxuQ3kNjHVOuZgcFH7ohlJ0BjkRqcCUHsqOsagQwqGWAP3)eBzPKRpX1iwRAaEITSuY1hhCnI1QgGNyllLCTaCTl06MR7W1iwRAaEITSuY1N4A4UZXYi9s6P0cX(NyllLCDhUgU7CSmsVKEkTqS)j2YsjxFIRD1n(Is9GSyj8vDNdW5gkXbg9UWkGVuwotAGvcFHVf0Bf(IAU2PbbXlPNsle7BeX1hhCTtdcIxg7ZcO6dvqLdaI9KVrexZeUUdxlIc)5gkbHkbyOAbbcRLEFbddfIRpo4AeRvnapXwwk5Ab65ALr34BbdBt8v0g2M4aJoQIvaFPSCM0aRe(cFlO3k81PbbXlPNsle7BeHVfmSnXxynNGcg2MGPjd8DAYaKflHVs6P0cX4aJUYXkGVuwotAGvcFHVf0Bf(60GG4zqLOnLGfbS)GEFJi8TGHTj(cR5euWW2emnzGVttgGSyj8LbvI2ucweW(d6XbgDLbwb8LYYzsdSs4l8TGERW3WyjUwaUgv56oCnu14Ab4ALZ1D4A3X1IOWFUHsqOsagQwqGWAP3xWWqHW3cg2M4lSMtqbdBtW0Kb(onzaYILW3veL0Jdm6kBSc4lLLZKgyLW3cg2M4lIjdWIacvcWq1ccewl94l8TGERWxOQ5zRZCnt5AOQX1N656U46oCnQ5AkPVvSpmwcelGToZ1cW1U46JdUMs6Bf7dJLaXcyRZCTaCnQY1D4A4UZXYi9iMmKGfbG08I9pXwwk5Ab4AxELZ1hhCnC35yzKEgujAtjyra7pO3)eBzPKRfGRrJRzc(cfdNeiQVLcjgDx4aJU7JvaFPSCM0aRe(cFlO3k8fQAE26mxZuUgQAC9PEU2fx3HRrnxtj9TI9HXsGybS1zUwaU2fxFCW1WDNJLr6L0tPfI9pXwwk5Ab4A046JdUMs6Bf7dJLaXcyRZCTaCnQY1D4A4UZXYi9iMmKGfbG08I9pXwwk5Ab4AxELZ1hhCnC35yzKEgujAtjyra7pO3)eBzPKRfGRrJRzc(wWW2eFPZIOjqTEwCGrhvGvaFPSCM0aRe(wWW2eFdRLEGOAYIVW3c6TcFHlRZcKXBcjUUdxdvnpBDMRzkxdvnU(upxJgx3HRrnxtj9TI9HXsGybS1zUwaU2fxFCW1WDNJLr6L0tPfI9pXwwk5Ab4A046JdUMs6Bf7dJLaXcyRZCTaCnQY1D4A4UZXYi9iMmKGfbG08I9pXwwk5Ab4AxELZ1hhCnC35yzKEgujAtjyra7pO3)eBzPKRfGRrJRzc(cfdNeiQVLcjgDx4aJURUXkGVuwotAGvcFHVf0Bf(6oUoQjLHxspLwi2tz5mPb(wWW2eFH1CckyyBcMMmW3PjdqwSe(chajHGdm6UCHvaFPSCM0aRe(cFlO3k8nQjLHxspLwi2tz5mPb(wWW2eFH1CckyyBcMMmW3PjdqwSe(chaj9uAHyCGr3fAyfWxklNjnWkHVW3c6TcFlyyOqakjwJKCTaCDx4BbdBt8fwZjOGHTjyAYaFNMmazXs4RmWbgDxDHvaFPSCM0aRe(cFlO3k8TGHHcbOKynsY1N656UW3cg2M4lSMtqbdBtW0Kb(onzaYILW3AjCGd8v0tWL1PcScy0DHvaFlyyBIVI2W2eFPSCM0aReoWOJgwb8LYYzsdSs47kcFLuGVfmSnXxuQ3kNjHVOuZgcF7gFrPEqwSe(EUHsWMGgjbI3sHuGdm6DHvaFPSCM0aRe(cFlO3k81DCDutkdVKEkTqSNYYzsdU(4GRDhxh1KYWJyYaSiGqLamuTGaH1sVNYYzsd8TGHTj(cvnGtZldCGrhvXkGVuwotAGvcFHVf0Bf(6oUoQjLHNs6BnuPLTaAANP3tz5mPb(wWW2eFHQgGrHcHdCGV1syfWO7cRa(wWW2eFzOA)0YwW4R2nbIAsOk(sz5mPbwjCGrhnSc4lLLZKgyLWx4Bb9wHVqvZZwN5AMY1qvJRp1Z1OX1D4AkPVvSpmwcelGToZ1N4A046JdUgQAE26mxZuUgQAC9PEUgvX3cg2M4lL03AOslBb00oBpoWO3fwb8LYYzsdSs4l8TGERWxuZ1UJRJAsz4vTaaxwN1tz5mPbx3HRHBoASWdRjSzwbnaY4nHK0tz5mPbxFCW1WL1zbY4nHexZeUUdxJAU2PbbXpQesGfbavn3Z8nI46JdUEqoniiENnPrJmaopXW3iIRzc(wWW2eFLISmTSfa)kjGqdkehy0rvSc4lLLZKgyLWx4Bb9wHVusFRyFySeiwaBDMRpX10zc2eeimwIRpo4AOQ5zRZCnt5AOQX1c0Z1UW3cg2M4lIjdjyrainVyCGrx5yfWxklNjnWkHVfmSnX33Kw2cKnjqObfIVW3c6TcFrnxh1KYWZq1(PLTGXxTBce1KqvpLLZKgCDhUgU7CSms)BslBbYMei0Gc9JMVcBtU(exd3DowgPNHQ9tlBbJVA3eiQjHQ(NyllLCTICnQY1mHR7W1OMRH7ohlJ0JyYqcweasZl2)eBzPKRpX1DX1hhCnu146t9CTY5AMGVqXWjbI6BPqIr3foWORmWkGVuwotAGvcFHVf0Bf(60GG4)gPQLTa3RgeGHLd)yzK4BbdBt89BKQw2cCVAqagwoWbgDLnwb8LYYzsdSs4l8TGERWxuZ1UJRJAsz4vTaaxwN1tz5mPbx3HRHBoASWdRjSzwbnaY4nHK0tz5mPbxFCW1WL1zbY4nHexZeUUdxJAUg1CnC35yzKENnPrJmaopXW)eBzPKRpX1OX1D4AuZ1qvJRpX1DX1hhCnC35yzKEetgsWIaqAEX(NyllLC9jUwzW1mHR7W1OMRHQgxFQNRvoxFCW1WDNJLr6rmziblcaP5f7FITSuY1N4A04AMW1mHRpo4AkPVvSpmwcelGToZ1c0Z1DX1mbFlyyBIVsrwMw2cGFLeqObfIdm6Upwb8LYYzsdSs4l8TGERWxOQ5zRZCnt5AOQX1N65Ax4BbdBt8LolIMa16zXbgDubwb8LYYzsdSs4BbdBt8fXKbyraHkbyOAbbcRLE8f(wqVv4lu18S1zUMPCnu146t9CDx4lumCsGO(wkKy0DHdm6U6gRa(sz5mPbwj8f(wqVv4lu18S1zUMPCnu146t9CnA4BbdBt8fQAaNMxg4aJUlxyfWxklNjnWkHVW3c6TcFDAqq8Hkbiwr0VVealrf0I99YOGc56tCTlubx3HRPK(wX(WyjqSa26mxFIRPZeSjiqySexZuU2fx3HRH7ohlJ0JyYqcweasZl2)eBzPKRpX10zc2eeimwcFlyyBIVWVGcNw2cCVAqGP1QgPLT4aJUl0WkGVuwotAGvcFlyyBIVH1spqunzXx4Bb9wHVqvZZwN5AMY1qvJRp1Z1OX1D4AuZ1UJRJAsz4vTaaxwN1tz5mPbxFCW1WL1zbY4nHexZe8fkgojquFlfsm6UWbgDxDHvaFPSCM0aRe(cFlO3k8fUSolqgVjKW3cg2M4lu1amkuiCGr3fQIvaFPSCM0aRe(wWW2eFrMITSfiPxeLbqObfIVW3c6TcFDAqq8oRqGOFH(XYiXxld6)grb(6chy0DPCSc4lLLZKgyLW3cg2M4RZSGc3Mai0GcXx4Bb9wHVWL1zbY4nHex3HRrnx70GG4DwHar)c9nI46JdUoQjLHx1caCzDwpLLZKgCDhUw0tOaAHdVlFyT0devtwUUdxdvnUUNRrJR7W1WDNJLr6rmziblcaP5f7FITSuY1cW1DX1hhCnu18S1zUMPCnu14Ab65AxCDhUw0tOaAHdVlVuKLPLTa4xjbeAqHCDhUMs6Bf7dJLaXcyRZCTaCDxCntWxOy4Kar9TuiXO7ch4ah4lk0lTnXOJw3O1TRU7QBpA4lJ6tlBL4RY8SI2pObxJk46cg2MC90KH0ZfeFf9lInj8vzLRvMXYbJAkKEUwzHnfYfuzLRrFrHyDONRrRlM5A06gTU5cYfuzLRvw6mbBcAW1oeY(exdxwNk4AhQ1sPNRvMfesIcjxNBYu16zrAMCDbdBtjxV5uSNlybdBtPx0tWL1PIErByBYfSGHTP0l6j4Y6uHI9UHs9w5mjMZIL6p3qjytqJKaXBPqkyEf1lPGzuQzd13nxWcg2MsVONGlRtfk27gu1aonVmy2q6DxutkdVKEkTqSNYYzsJJd3f1KYWJyYaSiGqLamuTGaH1sVNYYzsdUGfmSnLErpbxwNkuS3nOQbyuOqmBi9UlQjLHNs6BnuPLTaAANP3tz5mPbxqUGkRCTYsNjytqdUMqHEXCDySexhQexxWyFU2KCDHszZYzsEUGfmSnL9sru9a1khaz8MqIlybdBtPI9UHs9w5mjMZIL6v35aCUHsMxr9skygLA2q9WDNJLr6TeLvibo3qjiujadvliqyT07FITSuEcXAvdWtSLLYJdeRvnapXwwkfWfAD3bXAvdWtSLLYtWDNJLr6L0tPfI9pXwwk7a3DowgPxspLwi2)eBzP8KRU5cwWW2uQyVBI2W2KzdPh1oniiEj9uAHyFJOJdNgeeVm2Nfq1hQGkhae7jFJiM0ref(ZnuccvcWq1ccewl9(cggk0XbI1QgGNyllLc0Rm6MlybdBtPI9UbR5euWW2emnzWCwSuVKEkTqmZgsVtdcIxspLwi23iIlybdBtPI9UbR5euWW2emnzWCwSupdQeTPeSiG9h0ZSH070GG4zqLOnLGfbS)GEFJiUGfmSnLk27gSMtqbdBtW0KbZzXs9RikPNzdPpmwsauTdu1eq5DCNik8NBOeeQeGHQfeiSw69fmmuiUGfmSnLk27gIjdWIacvcWq1ccewl9mdfdNeiQVLczVlMnKEOQ5zRZmfQAN67QdQPK(wX(WyjqSa26SaUooOK(wX(WyjqSa26SaOAh4UZXYi9iMmKGfbG08I9pXwwkfWLx5hhWDNJLr6zqLOnLGfbS)GE)tSLLsbqJjCblyyBkvS3n6SiAcuRNLzdPhQAE26mtHQ2PExDqnL03k2hglbIfWwNfW1XbC35yzKEj9uAHy)tSLLsbq74Gs6Bf7dJLaXcyRZcGQDG7ohlJ0JyYqcweasZl2)eBzPuaxELFCa3DowgPNbvI2ucweW(d69pXwwkfanMWfSGHTPuXE3cRLEGOAYYmumCsGO(wkK9Uy2q6HlRZcKXBcPoqvZZwNzku1o1Jwhutj9TI9HXsGybS1zbCDCa3DowgPxspLwi2)eBzPua0ooOK(wX(WyjqSa26SaOAh4UZXYi9iMmKGfbG08I9pXwwkfWLx5hhWDNJLr6zqLOnLGfbS)GE)tSLLsbqJjCblyyBkvS3nynNGcg2MGPjdMZIL6HdGKqy2q6DxutkdVKEkTqSNYYzsdUGfmSnLk27gSMtqbdBtW0KbZzXs9WbqspLwiMzdPpQjLHxspLwi2tz5mPbxWcg2Msf7DdwZjOGHTjyAYG5SyPEzWSH0xWWqHausSgjfOlUGfmSnLk27gSMtqbdBtW0KbZzXs91smBi9fmmuiaLeRrYt9DXfKlybdBtPVwQNHQ9tlBbJVA3eiQjHQCblyyBk91sk27gL03AOslBb00oBpZgspu18S1zMcvTt9O1Hs6Bf7dJLaXcyRZNq74aQAE26mtHQ2PEuLlybdBtPVwsXE3KISmTSfa)kjGqdkKzdPh1UlQjLHx1caCzDwpLLZKgDGBoASWdRjSzwbnaY4nHK0tz5mPXXbCzDwGmEtiXKoO2PbbXpQesGfbavn3Z8nIoogKtdcI3ztA0idGZtm8nIycxWcg2MsFTKI9UHyYqcweasZlMzdPNs6Bf7dJLaXcyRZNOZeSjiqyS0Xbu18S1zMcvnb6DXfSGHTP0xlPyVBVjTSfiBsGqdkKzOy4Kar9Tui7DXSH0J6OMugEgQ2pTSfm(QDtGOMeQ6PSCM0OdC35yzK(3Kw2cKnjqObf6hnFf2MNG7ohlJ0Zq1(PLTGXxTBce1Kqv)tSLLsfrvM0b1WDNJLr6rmziblcaP5f7FITSuEQRJdOQDQx5mHlybdBtPVwsXE3(gPQLTa3RgeGHLdMnKENgee)3ivTSf4E1GamSC4hlJKlybdBtPVwsXE3KISmTSfa)kjGqdkKzdPh1UlQjLHx1caCzDwpLLZKgDGBoASWdRjSzwbnaY4nHK0tz5mPXXbCzDwGmEtiXKoOg1WDNJLr6D2KgnYa48ed)tSLLYtO1b1qv7uxhhWDNJLr6rmziblcaP5f7FITSuEszWKoOgQAN6v(XbC35yzKEetgsWIaqAEX(NyllLNqJjm54Gs6Bf7dJLaXcyRZc03ft4cwWW2u6RLuS3n6SiAcuRNLzdPhQAE26mtHQ2PExCblyyBk91sk27gIjdWIacvcWq1ccewl9mdfdNeiQVLczVlMnKEOQ5zRZmfQAN67IlybdBtPVwsXE3GQgWP5LbZgspu18S1zMcvTt9OXfSGHTP0xlPyVBWVGcNw2cCVAqGP1QgPLTmBi9onii(qLaeRi63xcGLOcAX(EzuqHNCHk6qj9TI9HXsGybS15t0zc2eeimwIPU6a3DowgPhXKHeSiaKMxS)j2Ys5j6mbBcceglXfSGHTP0xlPyVBH1spqunzzgkgojquFlfYExmZSH0dvnpBDMPqv7upADqT7IAsz4vTaaxwN1tz5mPXXbCzDwGmEtiXeUGfmSnL(Ajf7DdQAagfkeZgspCzDwGmEtiXfSGHTP0xlPyVBitXw2cK0lIYai0Gcz2q6DAqq8oRqGOFH(XYiz2YG(Vru07IlybdBtPVwsXE3CMfu42eaHguiZqXWjbI6BPq27IzdPhUSolqgVjK6GANgeeVZkei6xOVr0XrutkdVQfa4Y6SEklNjn6i6juaTWH3LpSw6bIQjBhOQ1Jwh4UZXYi9iMmKGfbG08I9pXwwkfORJdOQ5zRZmfQAc07QJONqb0chExEPiltlBbWVsci0Gc7qj9TI9HXsGybS1zb6IjCb5cwWW2u6HdGKq6TeLvibo3qjiujadvliqyT0ZSH07ouQ3kNj5v35aCUHYJdeRvnapXwwkfanLZfSGHTP0dhajHOyVB1dRKaX(pLbZgspu18S1zMcvTt9U4cwWW2u6HdGKquS3TyBGQGfbmOkuz2q6DAqq8YyFwavFOcQCaqSN8JLr2ref(ZnuccvcWq1ccewl9(cggk0XbI1QgGNyllLc4Q7JdeRvnapXwwkp5Y97MlybdBtPhoascrXE3yqLOnLGfbS)GEMnKEu)Lnaekug(AmKElpHQk)44lBaiuOm81yi9nIysh4UZXYi9VjTSfiBsGqdk0)eBzPua6mbBcceglXfSGHTP0dhajHOyVBifnTKaYyzfXSH0dxwNfiJ3esDq9x2aqOqz4RXq6T8KRUpo(YgacfkdFngsFJiMWfSGHTP0dhajHOyVBi1Csjy)b9mBi9FzdaHcLHVgdP3YtD19XXx2aqOqz4RXq6BeXfSGHTP0dhajHOyVBoBsJgzaCEIbZgs)x2aqOqz4RXq6T8KY7(44lBaiuOm81yi9nIyEAjbGJELr3CblyyBk9Wbqsik27Mm2Nfq1hQGkhae7jMnKE4UZXYi9YyFwavFOcQCaqSN8q16BjzpAhhiwRAaEITSukaADFCG6VSbGqHYWxJH0)eBzP8KlLFC4o4IcLvgEHIFRYoOg1FzdaHcLHVgdP3YtWDNJLr6LX(SaQ(qfu5aGyp5rAMtWtq16BjqyS0XH7(YgacfkdFngspD2KHKjDqnC35yzKElrzfsGZnuccvcWq1ccewl9(NyllLNG7ohlJ0lJ9zbu9HkOYbaXEYJ0mNGNGQ13sGWyPJduQ3kNj5v35aCUHsMWKoWDNJLr6rmziblcaP5f7FITSukqpQOdu1o1Jwh4UZXYi9muTFAzly8v7Marnju1)eBzPuGExOXeUGfmSnLE4aijef7Dtg7ZcO6dvqLdaI9eZgspCrHYkdVqXVvzhu70GG4zqLOnLGfbS)GEFJOJduJyTQb4j2YsPaWDNJLr6zqLOnLGfbS)GE)tSLLYJd4UZXYi9mOs0MsWIa2FqV)j2Ys5j4UZXYi9YyFwavFOcQCaqSN8inZj4jOA9TeimwIjDG7ohlJ0JyYqcweasZl2)eBzPuGEurhOQDQhToWDNJLr6zOA)0YwW4R2nbIAsOQ)j2YsPa9UqJjCblyyBk9Wbqsik27MZC3byraHkbOKyfZSH0d3DowgPhXKHeSiaKMxS)j2YsPaODCGyTQb4j2YsPaUqJlybdBtPhoascrXE3ABQFyvcweqHkPFdvUGfmSnLE4aijef7DJX(ZbkKLGNKBwjK4cwWW2u6HdGKquS3n4MqkJVcAaqMflXSH07UXgE4MqkJVcAaqMflbCA(0)eBzPSdQrT7IAsz4zOA)0YwW4R2nbIAsOQNYYzsJJd4UZXYi9muTFAzly8v7Marnju1)eBzPKjDG7ohlJ0)M0YwGSjbcnOq)tSLLYoWDNJLr6rmziblcaP5f7FITSu2XPbbXlJ9zbu9HkOYbaXEYpwgjtooqSw1a8eBzPua3NlybdBtPhoascrXE3cvc0KoBtoai7djUGfmSnLE4aijef7DtuZBiITSf4mlzWfSGHTP0dhajHOyVBpvISSfGmlwsYSH0h13sHpmwcelqemaO19PU6(4iQVLcVkvZq1lcgc0Jw3CblyyBk9Wbqsik27gYcBK0auOs6TGaouXYfSGHTP0dhajHOyVBSe7(Iblcy2aTby8uXkz2q6PK(wXcGQDZfSGHTP0dhajHOyVBVjs0KawcKIkiXfSGHTP0dhajHOyVBYyFwavFOcQCaqSNy2q6H7ohlJ0lJ9zbu9HkOYbaXEYdvRVLK9ODCGyTQb4j2YsPaO19XHtdcIxsuOAzl4RwY3i64a1WDNJLr6DM7oalciujaLeRy)tSLLsfDDcU7CSmsVm2Nfq1hQGkhae7jpsZCcEcQwFlbcJLooChjLucjVZC3byraHkbOKyf7zl3BFM0bU7CSmspIjdjyrainVy)tSLLsbC1DhOQDQhToWDNJLr6zOA)0YwW4R2nbIAsOQ)j2YsPaUqJlybdBtPhoascrXE3AKeWcIL5SyP(sQIsLKe8fQCFaC)AYfSGHTP0dhajHOyVBnscybXk5cwWW2u6HdGKquS3TyBGQGfbiSE2IzdPhXAvdWtSLLYtUuoQ44qef(ZnuccvcWq1ccewl9(cggk0Xbk1BLZK8Q7Cao3qjxWcg2MspCaKeII9U5m3DaqAEXmBi9WDNJLr6TeLvibo3qjiujadvliqyT07FITSuEQRUpoqPERCMKxDNdW5gkpoqSw1a8eBzPua06MlybdBtPhoascrXE3COxsVqlBz2q6H7ohlJ0BjkRqcCUHsqOsagQwqGWAP3)eBzP8uxDFCGs9w5mjV6ohGZnuECGyTQb4j2YsPaUuoxWcg2MspCaKeII9UnTw1qcCVMrllLbxWcg2MspCaKeII9UHyp5m3DWSH0d3DowgP3suwHe4CdLGqLamuTGaH1sV)j2Ys5PU6(4aL6TYzsE1DoaNBO84aXAvdWtSLLsbC1nxWcg2MspCaKeII9UvjKKXxtaSMtMnKE4UZXYi9wIYkKaNBOeeQeGHQfeiSw69pXwwkp1v3hhOuVvotYRUZb4CdLhhiwRAaEITSukaADZfSGHTP0dhajHOyVBovlyraXBqHsMnKENgeeVm2Nfq1hQGkhae7j)yzKCb5cwWW2u6HdGKEkTqCpk1BLZKyolwQxspLwig408YG5vuVKcMrPMnupC35yzKEj9uAHy)tSLLsbCDCiIc)5gkbHkbyOAbbcRLEFbddfQdC35yzKEj9uAHy)tSLLYtD19XbI1QgGNyllLcGw3CblyyBk9WbqspLwiwXE3SeLvibo3qjiujadvliqyT0ZSH07ouQ3kNj5v35aCUHYJdeRvnapXwwkfanLZfSGHTP0dhaj9uAHyf7DRrsaliwMZIL6lPkkvssWxOY9bW9RjxWcg2MspCaK0tPfIvS3TgjbSGyLCblyyBk9WbqspLwiwXE3CM7oainVyMnKEuQ3kNj5L0tPfIbonVm4cwWW2u6HdGKEkTqSI9U5qVKEHw2YSH0Js9w5mjVKEkTqmWP5LbxWcg2MspCaK0tPfIvS3T2M6hwLGfbuOs63qLzdPhXAvdWtSLLYtUCFLFCGs9w5mjVKEkTqmWP5LXXbI1QgGNyllLc0LY5cwWW2u6HdGKEkTqSI9UXy)5afYsWtYnResmBi9OuVvotYlPNsledCAEzWfSGHTP0dhaj9uAHyf7DZzU7aSiGqLausSIz2q6rPERCMKxspLwig408YGlybdBtPhoas6P0cXk27gCtiLXxbnaiZILy2q6rnC35yzKEj9uAHy)tSLLYJd4UZXYi9WnHugFf0aGmlwYdvRVLK9OXKoUBSHhUjKY4RGgaKzXsaNMp9pXwwk7GA4UZXYi9VjTSfiBsGqdk0)eBzPSdC35yzKEetgsWIaqAEX(NyllLhhiwRAaEITSukG7ZeUGfmSnLE4aiPNsleRyVBHkbAsNTjhaK9HexWcg2MspCaK0tPfIvS3nrnVHi2YwGZSKbxWcg2MspCaK0tPfIvS3TNkrw2cqMfljz2q6J6BPWhglbIficga06(uxDFCe13sHxLQzO6fbdb6rR7JJO(wk8HXsGybdJeanUGfmSnLE4aiPNsleRyVBilSrsdqHkP3cc4qflxWcg2MspCaK0tPfIvS3nwIDFXGfbmBG2amEQyLmBi9usFRybq1U5cwWW2u6HdGKEkTqSI9U9MirtcyjqkQGexWcg2MspCaK0tPfIvS3T6HvsGy)NYGzdPhQAE26mtHQ2PExCblyyBk9WbqspLwiwXE3MwRAibUxZOLLYGlybdBtPhoas6P0cXk27gI9KZC3bZgspk1BLZK8s6P0cXaNMxgCblyyBk9WbqspLwiwXE3QesY4RjawZjZgspk1BLZK8s6P0cXaNMxgCblyyBk9WbqspLwiwXE3CQwWIaI3GcLmBi9OuVvotYlPNsledCAEzWfSGHTP0dhaj9uAHyf7Dl2gOkyradQcvMnKEeRvnapXwwkp5Y97(4qef(ZnuccvcWq1ccewl9(cggk0XbI1QgGNyllLc4QBUGfmSnLE4aiPNsleRyVBX2avblcqy9SfZgspI1QgGNyllLNqfDFCiIc)5gkbHkbyOAbbcRLEFbddf64aXAvdWtSLLsbC1nxWcg2MspCaK0tPfIvS3ngujAtjyra7pONzdPhU7CSms)BslBbYMei0Gc9pXwwkfGotWMGaHXsCblyyBk9WbqspLwiwXE3qkAAjbKXYkIlybdBtPhoas6P0cXk27gsnNuc2FqpxWcg2MspCaK0tPfIvS3nNnPrJmaopXGlybdBtPhoas6P0cXk27MKEkTqmZgspC35yzK(3Kw2cKnjqObf6FITSukaAhhiwRAaEITSukGlLZfSGHTP0dhaj9uAHyf7DZPAblciEdkuYfKlybdBtPFfrj99iMmalciujadvliqyT0ZmumCsGO(VLczVlMnKEOQ5zRZmfQAN67IlybdBtPFfrj9k27gDwenbQ1ZYSH0h1KYWdvnGtZldpLLZKgDGQMNToZuOQDQVlUGfmSnL(veL0RyVBH1spqunzzgkgojquFlfYExmBi9WL1zbY4nHuhOQ5zRZmfQAN6rJlybdBtPFfrj9k27gu1amkuiMnKEOQ5zRZmfQA9OXfSGHTP0VIOKEf7DJolIMa16z5cwWW2u6xrusVI9Ufwl9ar1KLzOy4Kar9Tui7DXSH0dvnpBDMPqv7upACb5cwWW2u6L0tPfI7rmziblcaP5fZSH070GG4L0tPfI9pXwwkfWfxWcg2MsVKEkTqSI9U1ijGfelZzXs9LufLkjj4lu5(a4(1KlybdBtPxspLwiwXE3KISmTSfa)kjGqdkKzdPh1UlQjLHx1caCzDwpLLZKgDGBoASWdRjSzwbnaY4nHK0tz5mPXXbCzDwGmEtiXKoOUGHHcbOKynsEQVRJJcggkeGsI1i5jxDChC35yzK(3Kw2cKnjqObf6BeXeUGfmSnLEj9uAHyf7D7nPLTaztceAqHmdfdNeiQVLczVlMnKE4Y6Saz8MqIlybdBtPxspLwiwXE3qmziblcaP5fZSH0xWWqHausSgjp13fxWcg2MsVKEkTqSI9UjfzzAzla(vsaHguiZgspQDxutkdVQfa4Y6SEklNjn6a3C0yHhwtyZScAaKXBcjPNYYzsJJd4Y6Saz8MqIjDCAqq8JkHeyraqvZ9mFJiUGfmSnLEj9uAHyf7DZzwqHBtaeAqHmdfdNeiQVLczVlMnKEudxwNfiJ3eshhUlQjLHx1caCzDwpLLZKgmPJtdcINbvI2ucweW(d6bmy4Be1bU7CSms)BslBbYMei0Gc9pXwwkpHgxWcg2MsVKEkTqSI9UHyYaSiGqLamuTGaH1spZwg0)nIIExCblyyBk9s6P0cXk27MuKLPLTa4xjbeAqHmBi9O2DrnPm8QwaGlRZ6PSCM0OdCZrJfEynHnZkObqgVjKKEklNjnooGlRZcKXBcjM0zqoniiENnPrJmaopXW3iIlybdBtPxspLwiwXE3qmzaweqOsagQwqGWAPNzOy4Kar9Tui7DXSH0dvnb6IlybdBtPxspLwiwXE3CMfu42eaHguiZqXWjbI6BPq27IzdPhUSolqgVjKooCxutkdVQfa4Y6SEklNjn4cwWW2u6L0tPfIvS3nPiltlBbWVsci0Gc5cYfSGHTP0lJEgQ2pTSfm(QDtGOMeQYSH0)Lnaekug(AmKElpb3DowgPNHQ9tlBbJVA3eiQjHQ(rZxHTPYu3E3)44lBaiuOm81yi9nI4cwWW2u6LHI9Urj9TgQ0YwanTZ2ZSH0dvnpBDMPqv7upADOK(wX(WyjqSa268PUooGQMNToZuOQDQhv7GAkPVvSpmwcelGToFcTJd3j6juaTWH3LpSw6bIQjlt4cwWW2u6LHI9UjfzzAzla(vsaHguiZgspQDxutkdVQfa4Y6SEklNjn6a3C0yHhwtyZScAaKXBcjPNYYzsJJd4Y6Saz8MqIjDCAqq8JkHeyraqvZ9mFJOoO(lBaiuOm81yi9wEYPbbXpQesGfbavn3Z8pXwwkzkAhhFzdaHcLHVgdPVret4cwWW2u6LHI9U9M0YwGSjbcnOqMHIHtce13sHS3fZgspC35yzKEj9uAHy)tSLLYtUooCxutkdVKEkTqSNYYzsdUGfmSnLEzOyVBiMmKGfbG08Iz2q6r9x2aqOqz4RXq6T8eC35yzKEetgsWIaqAEX(rZxHTPYu3E3)44lBaiuOm81yi9nIyshutj9TI9HXsGybS15t0zc2eeimwIPUooGQMNToZuOQjqVRJdNgeeVm2Nfq1hQGkhae7j)tSLLsbOZeSjiqySKIUyYXbI1QgGNyllLcqNjytqGWyjfDXfSGHTP0ldf7Dd(fu40YwG7vdcmTw1iTSLzdP3PbbXhQeGyfr)(saSevql23lJck8KlurhkPVvSpmwcelGToFIotWMGaHXsm1vh4UZXYi9VjTSfiBsGqdk0)eBzP8eDMGnbbcJLooCAqq8Hkbiwr0VVealrf0I99YOGcp5cv7GA4UZXYi9s6P0cX(NyllLcO8ornPm8s6P0cXEklNjnooG7ohlJ0ZGkrBkblcy)b9(NyllLcO8oWffkRm8cf)wLhhiwRAaEITSukGYzcxWcg2MsVmuS3TVrQAzlW9Qbbyy5GzdP3PbbX)nsvlBbUxniadlh(XYi7uWWqHausSgjp5IlybdBtPxgk27gIjdWIacvcWq1ccewl9mdfdNeiQVLczVlMnKEOQjqxCblyyBk9YqXE3OZIOjqTEwMnKEOQ5zRZmfQAN6DXfSGHTP0ldf7DdQAaNMxgmBi9qvZZwNzku1o17QtbddfcqjXAKS3vNVSbGqHYWxJH0B5j06(4aQAE26mtHQ2PE06uWWqHausSgjp1JgxWcg2MsVmuS3nOQbyuOqCblyyBk9YqXE3cRLEGOAYYmumCsGO(wkK9UyMzdPhUSolqgVjK6avnpBDMPqv7upADCAqq8YyFwavFOcQCaqSN8JLrYfSGHTP0ldf7DtkYY0Ywa8RKacnOqMnKENgeepu1ausFRyVmkOWtD1ntvUYubddfcqjXAKSJtdcIxg7ZcO6dvqLdaI9KFSmYoOgU7CSms)BslBbYMei0Gc9pXwwkpHwh4UZXYi9iMmKGfbG08I9pXwwkpH2XbC35yzK(3Kw2cKnjqObf6FITSukqxDG7ohlJ0JyYqcweasZl2)eBzP8uxDGQ2PUooG7ohlJ0)M0YwGSjbcnOq)tSLLYtD1bU7CSmspIjdjyrainVy)tSLLsb6Qdu1oHQhhqvZZwNzku1eO3vhkPVvSpmwcelGTolaAm54WPbbXdvnaL03k2lJck8KRU7GyTQb4j2YsPakBUGfmSnLEzOyVBoZckCBcGqdkKzOy4Kar9Tui7DXSH0dxwNfiJ3esDqDutkdVKEkTqSNYYzsJoWDNJLr6L0tPfI9pXwwkfORJd4UZXYi9VjTSfiBsGqdk0)eBzP8KRoWDNJLr6rmziblcaP5f7FITSuEY1XbC35yzK(3Kw2cKnjqObf6FITSukqxDG7ohlJ0JyYqcweasZl2)eBzP8uxDGQ2j0ooG7ohlJ0)M0YwGSjbcnOq)tSLLYtD1bU7CSmspIjdjyrainVy)tSLLsb6Qdu1o11Xbu1oP8JdNgeeVZkei6xOVret4cwWW2u6LHI9Ufwl9ar1KLzOy4Kar9Tui7DXmZgspCzDwGmEti1bQAE26mtHQ2PE04cwWW2u6LHI9UHmfBzlqsVikdGqdkKzld6)grrVlUGkRCTYCKexR0QmxU2q4ALfxLf5AtY1W5kjUUYbxlEB4A1cfIRrJRHQgxx5GRfVnpxplzW1TZ1PMCnJsY1kOSmZC9(CTHW1I3gUUEIRlNTj46y5AyjIRPK(wXCDLdUMSqLEUw828C9SKbx3chCnJsY1kOSmxVpxBiCT4THRRN46jjLCDOwjxJgxdvnUUyuI5AKFz5AyjsKLTCblyyBk9YqXE3CMfu42eaHguiZqXWjbI6BPq27IzdPhUSolqgVjK6a3DowgPhXKHeSiaKMxS)j2YsPaD1bQA9O1r0tOaAHdVlFyT0devt2ousFRyFySeiwGY7waxCblyyBk9YqXE3CMfu42eaHguiZqXWjbI6BPq27IzdPhUSolqgVjK6qj9TI9HXsGybS1zbqRdQHQMNToZuOQjqVRJdrpHcOfo8U8H1spqunzzcxqUGfmSnLEgujAtjyra7pOVhwZjOGHTjyAYG5SyPE4aijeMnKE3f1KYWlPNsle7PSCM0GlybdBtPNbvI2ucweW(d6vS3nynNGcg2MGPjdMZIL6HdGKEkTqmZgsFutkdVKEkTqSNYYzsdUGfmSnLEgujAtjyra7pOxXE3OK(wdvAzlGM2z7z2q6HQMNToZuOQDQhTousFRyFySeiwaBD(uxCblyyBk9mOs0MsWIa2FqVI9U9M0YwGSjbcnOqMHIHtce13sHS3fxWcg2MspdQeTPeSiG9h0RyVBsrwMw2cGFLeqObfYSH0JA3f1KYWRAbaUSoRNYYzsJoWnhnw4H1e2mRGgaz8Mqs6PSCM044aUSolqgVjKyshNgee)Osibweau1CpZ3iIlybdBtPNbvI2ucweW(d6vS3netgsWIaqAEXmBi9fmmuiaLeRrYt9O1XPbbXZGkrBkblcy)b9agm8pXwwkfWfxWcg2MspdQeTPeSiG9h0RyVBmuTFAzly8v7MarnjuLzdPVGHHcbOKynsEQhnUGfmSnLEgujAtjyra7pOxXE3KISmTSfa)kjGqdkKzdPh1UlQjLHx1caCzDwpLLZKgDGBoASWdRjSzwbnaY4nHK0tz5mPXXbCzDwGmEtiXKofmmuiaLeRrYt9D1XPbbXZGkrBkblcy)b9agm8nI4cwWW2u6zqLOnLGfbS)GEf7DZzwqHBtaeAqHmdfdNeiQVLczVlMnKE4Y6Saz8MqQtbddfcqjXAKuGE04cwWW2u6zqLOnLGfbS)GEf7DJHQ9tlBbJVA3eiQjHQCblyyBk9mOs0MsWIa2FqVI9UHyYqcweasZlMzld6)grrVlMnKENgeeVm2Nfq1hQGkhae7jFJOoFzdaHcLHVgdP3YtWDNJLr6rmziblcaP5f7hnFf2MktD7vgCblyyBk9mOs0MsWIa2FqVI9UjfzzAzla(vsaHguiZgsVtdcIhQAakPVvSxgfu4PU6MPkxzQGHHcbOKynsYfSGHTP0ZGkrBkblcy)b9k27gIjdWIacvcWq1ccewl9mdfdNeiQVLczVlMnKEOQjqxCblyyBk9mOs0MsWIa2FqVI9UrNfrtGA9SmBi9qvZZwNzku1o17IlybdBtPNbvI2ucweW(d6vS3nOQbCAEzWSH0dvnpBDMPqv7upQDPybddfcqjXAK8KlMWfSGHTP0ZGkrBkblcy)b9k27wyT0devtwMHIHtce13sHS3fZmBi9O2DrnPm8QwaGlRZ6PSCM044aUSolqgVjKyshOQ5zRZmfQAN6rJlybdBtPNbvI2ucweW(d6vS3nOQbyuOqCblyyBk9mOs0MsWIa2FqVI9U5mlOWTjacnOqMHIHtce13sHS3fZgspu1o131XHtdcINbvI2ucweW(d6bmy4BeXfSGHTP0ZGkrBkblcy)b9k27gYuSLTaj9IOmacnOqMTmO)Bef9UW3Qju3hFVgRYSXboWya]] )

end