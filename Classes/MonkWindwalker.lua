-- MonkWindwalker.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


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
        faeline_stomp = {
            id = 327104,
            duration = 30,
            max_stack = 1,
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

        recently_rushing_tiger_palm = {
            id = 337341,
            duration = 30,
            max_stack = 1,
        },

        rushing_tiger_palm = {
            duration = 6,
            max_stack = 1,
            generate = function( t, auraType )
                local rrtp = debuff.recently_rushing_tiger_palm.remains

                if rrtp > 24 then
                    t.count = 1
                    t.expires = query_time + rrtp - 24
                    t.applied = debuff.recently_rushing_tiger_palm.applied
                    t.caster = "player"

                    return
                end

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end
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
                return 1
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

                cooldown.rising_sun_kick.expires = max( 0, cooldown.rising_sun_kick.expires - 1 )
                cooldown.fists_of_fury.expires = max( 0, cooldown.fists_of_fury.expires - 1 )

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
            gcd = "spell",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 608938,

            talent = "energizing_elixir",

            handler = function ()
                gain( 2, "chi" )
                applyBuff( "energizing_elixir" )
            end,
        },


        faeline_stomp = {
            id = 327104,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 3636842,

            toggle = "essences",
            
            handler = function ()
                applyBuff( "faeline_stomp" )
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
                return 3
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

            talent = "invoke_xuen",

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
            end,
        },


        paralysis = {
            id = 115078,
            cast = 0,
            cooldown = 45,
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
                return 2
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

            spend = 1,
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
            gcd = "spell",

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

            spend = function () return buff.dance_of_chiji.up and 0 or 2 end,
            spendType = "chi",

            startsCombat = true,
            texture = 606543,

            start = function ()
                removeBuff( "dance_of_chiji" )

                removeBuff( "chi_energy" ) -- legendary
            end,
        },


        storm_earth_and_fire = {
            id = function () return buff.storm_earth_and_fire.up and 221771 or 137639 end,
            cast = 0,
            charges = 2,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136038,

            notalent = "serenity",
            nobuff = "storm_earth_and_fire",

            handler = function ()
                applyBuff( "storm_earth_and_fire" )
            end,

            copy = { 137639, 221771 }
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

                if legendary.rushing_tiger_palm.enabled and target.minR >= 10 then
                    setDistance( 5 )
                    applyDebuff( "target", "rushing_tiger_palm" )
                    applyDebuff( "target", "recently_rushing_tiger_palm" )
                end

                gain( 2, "chi" )

                applyDebuff( "target", "mark_of_the_crane" )
            end,
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
            id = 115080,
            cast = 0,
            cooldown = function () return legendary.fatal_touch.enabled and 120 or 180 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 606552,

            cycle = "touch_of_death",

            usable = function () return target.is_player and target.health.pct < 35 or target.health.pct < 15, "requires low health target" end,

            handler = function ()
                applyDebuff( "target", "touch_of_death" )
            end,
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

    spec:RegisterSetting( "allow_fsk", true, {
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
    
    spec:RegisterPack( "Windwalker", 20200726.2, [[d40hqcqisP8isPQnPu1NukugfqPtbu8krjZcI6wKsLDjYVukAyivDmLsldi9mLknnsrCnKk2Msf6BKIuJtPI6CkvW6ukqAEaX9GQ2hsXbvkOwOOupuPaMOsHQlQuryJivQ(OsfrgPsbkNuPavReP0lrQuAMkfi6Mkve1ojL8tLceAOivkAPkfKEksMkPWvvQiTvLce8vKkfgRsbXEj5VigSQoSulMs9yctMIlJAZa(SOA0q50uTAsrYRbQMTsUnK2TIFlz4IIJRuilh0ZjA6cxNs2oe57qLXtkQZdH1JujZNuTFvwTvPHIY0bR0cu6bLE610GUJjqbL(Dy7oROcezyfvMwaENZkQPrzffDdFm46f4murLPrSQ2O0qrjllOGvukkBlFfBWhLTIY0bR0cu6bLE610GUJjqbLEnn97OIsMHfkTaDh3bffMBm8OSvugwkuuA)90n8XGRxGZW73jxd4hTA)90ATqCpO7iY3dk9GsVIA5YqQ0qrjmejdO0qP1wLgkkEA7fBuzROeqpyO3kkBlaGKKH84bIKPWn3RRFpGNJfeiJ2(iVhK7bLokQweEnkkFqQaNjA2IhvO0cuLgkkEA7fBuzROeqpyO3kkaphliqgT9rEpn3VDNPZ9663RT7rQHEBV4ewTmKOm3V)ErvltHBsrzjWifaXWDGLGmA7J8EqWF)wn5ED97b8CSGaz02h59GC)U7OIQfHxJIk3QHgVhsbqA6IHvGPcLw7Q0qrXtBVyJkBfLa6bd9wrjQAzkCtkklbgPaigUdSeKrBFK3tZ90zNVxx)ErvltHBsrzjWifaXWDGLGmA7J8EqUh0711VhPg6T9Ity1YqIYCVU(9aEowqGmA7J8EqUhu6vuTi8Auu4k4YGe7dbYYA6rWQqPLMO0qrXtBVyJkBfLa6bd9wrjW8eAR571U7fy(90G)(T3V)EEyyoIu4OmjkcAR57Pb)90NOJIQfHxJIQHIEysuqipHkuArhLgkkEA7fBuzROAr41OOwwYawwssETm8qYSSq7CwrjGEWqVvuIQwMc3KIYsGrkaIH7albz02h59GC)2711Vxu1Yu4MuuwcmsbqmChyjiJ2(iVNM7bL(711VhPg6T9Ity1YqIYCVU(9aEowqGmA7J8EqWFpO0ROMgLvullzalljjVwgEizwwODoRcLw7OsdffpT9InQSvuTi8Auu5R24DuqjbLn9A51OOeqpyO3kkrvltHBsrzjWifaXWDGLGmA7J8EqUF79663lQAzkCtkklbgPaigUdSeKrBFK3tZ9Gs)9663Jud92EXjSAzirzUxx)EaphliqgT9rEpi4Vhu6vumaalcY0OSIkF1gVJckjOSPxlVgvO0stR0qrXtBVyJkBfvlcVgfv(QnEhfusyu7fJQOeqpyO3kkaphliqgT9rEpn3VLo7W9663lQAzkCtkklbgPaigUdSeKrBFK3dY9BVxx)EKAO32loHvldjkJIIbayrqMgLvu5R24DuqjHrTxmQkuATZknuu802l2OYwrjGEWqVvuA7EKAO32loHvldjkZ97VhS3RT75nYYZKHnjbcXQcynUGyVAzCVU(9IQwMc3KeieRkG14cI9QLrcYOTpY7bb)9BVhm3V)EWEVaZVNM73EVU(98WWCe3dY9Ac93dgfvlcVgfvuwcmsbqmChyQqP1oO0qrXtBVyJkBfLa6bd9wrjQAzkCtsgfeLWnmWi9yiaoKtcSgMZY7XFpO3RRFVPIuuwcmsbqmChyjiJ2(iVxx)EaphliqgT9rEpi3dk93RRFpyV32caiHRGldsSpeilRPhbNGmA7J8EAUFl93RRFVOQLPWnjCfCzqI9Hazzn9i4eKrBFK3tZ9IQwMc3KKrbrjCddmspgcGd5eG1ArGSaRH5mjCu(ED97129SuYJGt4k4YGe7dbYYA6rWj0wtvW7bZ97VhS3lQAzkCtkklbgPaigUdSeKrBFK3tZ9IQwMc3KKrbrjCddmspgcGd5eG1ArGSaRH5mjCu(ED97rQHEBV4ewTmKOm3V)ETDpVrwEMmSjzGUT9YNCIpGNPm3dM73FVOQLPWnjaxgssbqaSGisqgT9rEpi4VFhUF)9cm)EAWF)U3V)ErvltHBs4WC4YNCIb251qYyncSeKrBFK3dc(73URIQfHxJIsgfeLWnmWi9yiaoKvHsRT0R0qrXtBVyJkBfLa6bd9wrb45ybbYOTpY7P5(T0zhUxx)EtfPOSeyKcGy4oWsqgT9rEVU(9i1qVTxCcRwgsugfvlcVgfvuwcmsbqaVHOTkuATDRsdffpT9InQSvucOhm0BfLOQLPWnPOSeyKcGy4oWsqgT9rEpn3Rj05ED97rQHEBV4ewTmKOm3V)ErvltHBsaUmKKcGaybrKGmA7J8EqUh0711VhWZXccKrBFK3dY9Bb9ED97b8CSGaz02h590C)w6P)(93d45ybbYOTpY7b5(TBP)(93d27fvTmfUjb4YqskacGfercYOTpY7b5(DVxx)ErvltHBs4WC4YNCIb251qYyncSeKrBFK3dY905ED97fvTmfUjbDPp5eP1qa3fGNGmA7J8EqUNo3dgfvlcVgfL9QkdPaibgt4HrrOcLwBbvPHIIN2EXgv2kkb0dg6TIsB3BQijQrWta7GneGvJYeBl4KGmA7J8(93d27b79IQwMc3Ke1i4jGDWgcWQr5eKrBFK3dc(7fvTmfUjfLLaJuaed3bwcYOTpY7Z6(T3RRFpsn0B7fNWQLHeL5EWC)(7b79A7(Ox8ejCyoC5toXa78AizSgbwIN2EXM711Vxu1Yu4MeomhU8jNyGDEnKmwJalbz02h59G5(93lQAzkCtc6sFYjsRHaUlapbz02h597Vxu1Yu4MeGldjPaiawqejiJ2(iVF)92waajzuquc3WaJ0JHa4qozkCZ9663BQifLLaJuaed3bwcYOTpY7bZ9663d45ybbYOTpY7b5(Dwr1IWRrrjQrWta7GneGvJYQqP12DvAOO4PTxSrLTIsa9GHEROevTmfUjfLLaJuaed3bwcYOTpY7P5(DP)ED97rQHEBV4ewTmKOm3RRFpGNJfeiJ2(iVhK7bLEfvlcVgfL9QkdbWcIqfkT2Qjknuu802l2OYwrjGEWqVvuIQwMc3KIYsGrkaIH7albz02h590C)U0FVU(9i1qVTxCcRwgsuM711VhWZXccKrBFK3dY9BPJIQfHxJIYMHsgcUp5QqP1w6O0qr1IWRrrT8CSqs0uwMCuEcffpT9InQSvHsRT7OsdffpT9InQSvucOhm0BfLOQLPWnPOSeyKcGy4oWsqgT9rEpn3Vl93RRFpsn0B7fNWQLHeL5ED97b8CSGaz02h59GC)w6vuTi8AuuaoKTxvzuHsRTAALgkkEA7fBuzROeqpyO3kkrvltHBsrzjWifaXWDGLGmA7J8EAUFx6Vxx)EKAO32loHvldjkZ9663d45ybbYOTpY7b5EqPxr1IWRrr1JGLbSxerVwQqP12DwPHIQfHxJIYUZjfajGUaCPIIN2EXgv2QqP12DqPHIIN2EXgv2kQweEnkQmLaCoKoDXgIOqZyfD41qmmsUGvucOhm0BfLOQLPWnPOSeyKcGy4oWsqgT9rEpn3Vl93RRFpsn0B7fNWQLHeLrrnnkROYucW5q60fBiIcnJv0HxdXWi5cwfkTaLELgkkEA7fBuzROAr41OOGmAfmj3Yn9iyIHrYfSIsa9GHEROevTmfUjfLLaJuaed3bwcYOTpY7P5(DP)ED97rQHEBV4ewTmKOmkQPrzffKrRGj5wUPhbtmmsUGvHslq3Q0qrXtBVyJkBfvlcVgfv(QnEhfusSBtoROeqpyO3kkrvltHBsrzjWifaXWDGLGmA7J8EAUhu6Vxx)EKAO32loHvldjkZ9663d45ybbYOTpY7b5EqPxrXaaSiitJYkQ8vB8okOKy3MCwfkTafuLgkkEA7fBuzROAr41OOY7fl61IHsIDvJIsa9GHEROevTmfUjfLLaJuaed3bwcYOTpY7P5E6qN711VhPg6T9Ity1YqIYCVU(9aEowqGmA7J8EqUFlOkQPrzfvEVyrVwmusSRAuHslq3vPHIIN2EXgv2kQweEnkkCqpW8jNi5CuEcsbqmqwgDEhykkb0dg6TIsu1Yu4MuuwcmsbqmChyjiJ2(iVNM7bL(711VhPg6T9Ity1YqIYOOMgLvu4GEG5torY5O8eKcGyGSm68oWuHslq1eLgkkEA7fBuzROAr41OOAjgs9WscSPRcsefSxkkb0dg6TIcPg6T9Itrzi1qSKmjG(aoh3V)EWEVOQLPWnPOSeyKcGy4oWsqgT9rEpn3d62711VhPg6T9Ity1YqIYCpyUF)9G9EdBBbaKGnDvqIOG9IyyBlaGKPWn3RRFVTfaqsgfeLWnmWi9yiaoKtqgT9rEpn3VD3711VhWZXccKrBFK3RD3lQAzkCtkklbgPaigUdSeKrBFK3dY9Ac93V)ErvltHBsrzjWifaXWDGLGmA7J8EqUhu6CVU(9aEowqGmA7J8EqUhu6CpyuutJYkQwIHupSKaB6QGerb7LkuAbkDuAOO4PTxSrLTIQfHxJIQLyi1dljWMUkiruWEPOeqpyO3kkTDpsn0B7fNIYqQHyjzsa9bCoUF)9G9EdBBbaKGnDvqIOG9IyyBlaGKPWn3RRFpyVxB3ZBKLNjdBsgOBBV8jN4d4zkZ9663hnmNJu4Omjksgrq2L(7b5(D(EWC)(7b79MksrzjWifaXWDGLGmA7J8ED97fvTmfUjfLLaJuaed3bwcYOTpY7Z6(D4EAUhWZXccKrBFK3dM73FVTfaqsgfeLWnmWi9yiaoKtwzUxx)EaphliqgT9rEpi3dkDUhmkQPrzfvlXqQhwsGnDvqIOG9sfkTaDhvAOOAr41OOcmMyn2L1yiafuWkkEA7fBuzRcLwGQPvAOOAr41OOYybDae(KtSxTmuu802l2OYwfkTaDNvAOO4PTxSrLTIsa9GHEROSTaassgYJhisMc3C)(7b79rdZ5ifoktIIKreeqP)EAUFx6Vxx)(OH5CKW4EfyPmI4EqWFpO0FpyUxx)(OH5CKchLjrrmoFpi3dQIQfHxJIcYDgFYjaRgLLQqPfO7GsdfvlcVgffqjSKSH00fd9Gj2CJQO4PTxSrLTkuATl9knuu802l2OYwrjGEWqVvu8WWCe3dY9Ac9kQweEnkkugTGiifazzjCdXa5gvQcLw7UvPHIQfHxJIc6zYSyIpezMwWkkEA7fBuzRcLw7cQsdfvlcVgfLDNtkasaDb4sffpT9InQSvHsRD3vPHIIN2EXgv2kkb0dg6TIcS3ZBKLNjdBsceIvfWACbXE1Y4(93lQAzkCtsGqSQawJli2RwgjiJ2(iVhe83dk93dM711VxB3ZBKLNjdBsceIvfWACbXE1Yqr1IWRrrzjzIhmQufQqrzyG2AfknuATvPHIIN2EXgv2kQkJIsYHIQfHxJIcPg6T9Ivui1llwrjQAzkCtkklbgPaigUdSeKrBFK3N197W90CF0WCosHJYKOigNVxx)ETDF0lEIKKH84bIepT9In3V)ETDpsn0B7fNIYqQHyjzsa9bCoUF)98gz5zYWMKb622lFYj(aEMYC)(7JgMZrkCuMefjJii7s)9GC)2DP)(93hnmNJu4Omjksgrq2L(7P5(D(ED97b8CSGaz02h59GC)2DP)(93d45ybbYOTpY7P5ErvltHBssgYJhisqgT9rE)(7fvTmfUjjzipEGibz02h590CpO3RRFVTfaqsYqE8arYkZ97VhWZXccKrBFK3tZ9B3QOqQHKPrzffwTmKOmQqPfOknuuTi8AuuYmCdjy9yiYa6GZkkEA7fBuzRcLw7Q0qrXtBVyJkBfLa6bd9wrzBbaKKmKhpqKSYCVU(92waajzuquc3WaJ0JHa4qozL5(93BQifLLaJuaed3bwcYOTpY711VhWZXccKrBFK3dc(73r6vuTi8AuuzQWRrfkT0eLgkkEA7fBuzROeqpyO3kkbMNqBnFV2DVaZVNg83d697VhS3h9INijzipEGiXtBVyZ9663RT7nvKIYsGrkaIH7albz02h59G5(93BBbaKKmKhpqKmfU5(93d275HH5isHJYKOiOTMVhK73EVU(9rV4jssgYJhis802l2C)(7fvTmfUjjzipEGibz02h59GCpO3RRFV2Up6fprsYqE8arIN2EXM73FVOQLPWnPOSeyKcGy4oWsqgT9rEpi3V797VxB3Jud92EXjSAzirzUxx)EEyyoIu4OmjkcAR57b5En5(93lQAzkCtcWLHKuaealiIeKrBFK3dY9Bt05EWOOAr41OOGmsmuYeSgIQcLw0rPHIQfHxJIcO5LpmrgfAgffpT9InQSvHsRDuPHIIN2EXgv2kQweEnkkaxgKcGeymbhMhmj8CgQOeqpyO3kkbMNqBnFV2DVaZVNg83V797V32caijzipEGizkCZ97V32caijzoW8jNa7CozkCZ97VhS3ZddZrKchLjrrqBnFpi3V9ED97JEXtKKmKhpqK4PTxS5(93lQAzkCtsYqE8arcYOTpY7b5EqVxx)ETDF0lEIKKH84bIepT9In3V)ErvltHBsrzjWifaXWDGLGmA7J8EqUF373FV2UhPg6T9Ity1YqIYCVU(98WWCePWrzsue0wZ3dY9AY97Vxu1Yu4MeGldjPaiawqejiJ2(iVhK73MOZ9GrrjqiwmjAyohsLwBvHslnTsdffpT9InQSvuTi8AuuHNZqsMEHQOeqpyO3kkTDVOqTlInKBWVF)9cmpH2A(ET7EbMFpn4Vh073FpyVp6fprsYqE8arIN2EXM711VxB3BQifLLaJuaed3bwcYOTpY711VVfHJet4HrDwEpn3d69G5(93BBbaKKmhy(KtGDoNmfU5(93BBbaKKmKhpqKmfU5(93d275HH5isHJYKOiOTMVhK73EVU(9rV4jssgYJhis802l2C)(7fvTmfUjjzipEGibz02h59GCpO3RRFV2Up6fprsYqE8arIN2EXM73FVOQLPWnPOSeyKcGy4oWsqgT9rEpi3V797VxB3Jud92EXjSAzirzUxx)EEyyoIu4OmjkcAR57b5En5(93lQAzkCtcWLHKuaealiIeKrBFK3dY9Bt05EWOOeielMenmNdPsRTQqP1oR0qrXtBVyJkBfLa6bd9wrPT7JEXtKaCzqkasGXeCyEWKWZzyIN2EXM73FFgiJejxysBtHNZqsMEHE)(7dhLVhe83VRIQfHxJIsG5eCnsSkuATdknuu802l2OYwrjGEWqVvurV4jssgYJhis802l2OOAr41OOe9ArAr41qwUmuulxgKPrzfLWqKmKhpqOcLwBPxPHIIN2EXgv2kkb0dg6TIsB3h9INijzipEGiXtBVyJIQfHxJIs0RfPfHxdz5YqrTCzqMgLvucdrYaQqP12Tknuu802l2OYwrjGEWqVvu2waajjd5XdejRmkQweEnkkrVwKweEnKLldf1YLbzAuwrjzipEGqfkT2cQsdffpT9InQSvucOhm0BfvlchjMWdJ6S8EqUFxfvlcVgfLOxlslcVgYYLHIA5YGmnkROKHkuATDxLgkkEA7fBuzROeqpyO3kQweosmHhg1z590G)(DvuTi8AuuIETiTi8AilxgkQLldY0OSIQlwfQqrLbYIc1UdLgkT2Q0qr1IWRrrLPcVgffpT9InQSvHslqvAOO4PTxSrLTIQYOOKCOOAr41OOqQHEBVyffs9YIvu8gz5zYWMKaHyvbSgxqSxTmUxx)EEJS8mzytAzjdyzjj51YWdjZYcTZ5711VN3ilptg2KYxTX7OGsIDBY5711VN3ilptg2KYxTX7OGsckB61YR5ED975nYYZKHnjiJwbtYTCtpcMyyKCbROqQHKPrzfvugsneljtcOpGZHkuATRsdffpT9InQSvuvgfLKdfvlcVgffsn0B7fROqQxwSIA7oOOeqpyO3kkTDF0lEIKKH84bIepT9In3V)EWEpsn0B7fNIYqQHyjzsa9bCoUxx)EEJS8mzytQLyi1dljWMUkiruWEDpyuui1qY0OSIcOMGuaKmfogsYazrHA3brG1ZWlvO0stuAOO4PTxSrLTIAAuwr10LeRHTKautqkasMchdvuTi8AuunDjXAylja1eKcGKPWXqvO0Ioknuu802l2OYwrjGEWqVvuA7(Ox8ejjd5XdejEA7fBUxx)ETDF0lEIeGldsbqcmMGdZdMeEodt802l2OOAr41OOeyoX2ckdvO0AhvAOO4PTxSrLTIsa9GHEROIEXtKaCzqkasGXeCyEWKWZzyIN2EXM711VNLsEeCsudWYfbPhdrgqhGtOTMQGkQweEnkkbMtW1iXQqPLMwPHIQfHxJIYhKkWzIMT4rrXtBVyJkBvO0ANvAOOAr41OOYTAOX7HuaKMUyyfykkEA7fBuzRcvOO6IvAO0ARsdfvlcVgffomhU8jNyGDEnKmwJatrXtBVyJkBvO0cuLgkkEA7fBuzROeqpyO3kkTDFgiJejxysBtHNZqsMEHE)(7fy(9GG)(T3V)EEyyoI7b5E6qVIQfHxJIIhgM70Lp5eE5A2HQqP1Uknuu802l2OYwrjGEWqVvu8WWCePWrzsue0wZ3tZ9BVxx)(fNZJPHisA2IhjXUJyX5Cdt802l2C)(7fvTmfUjbDPp5eP1qa3fGNGmA7J8EqUVfHxtcWLHKuaealiIKOLX9zDpDuuTi8AuuaUmKKcGaybrOcLwAIsdffpT9InQSvuTi8Auuqx6torAneWDb4kkb0dg6TIcS3h9INiHdZHlFYjgyNxdjJ1iWs802l2C)(7fvTmfUjbDPp5eP1qa3fGNmwWo8AUNM7fvTmfUjHdZHlFYjgyNxdjJ1iWsqgT9rEFw3Rj3dM73FpyVxu1Yu4MeGldjPaiawqejiJ2(iVNM739ED97fy(90G)E6CpyuuceIftIgMZHuP1wvO0Ioknuu802l2OYwrjGEWqVvu2waajOLeZNCIMQnmbNpMKPWnkQweEnkkOLeZNCIMQnmbNpgvO0AhvAOO4PTxSrLTIsa9GHEROefQDrKb0bNVF)9G9EWEpyVxG53tZ97EVU(9IQwMc3KaCzijfabWcIibz02h590C)oEpyUF)9G9EbMFpn4VNo3RRFVOQLPWnjaxgssbqaSGisqgT9rEpn3d69G5EWCVU(98WWCePWrzsue0wZ3dc(739ED97TTaasMEemPaicmxt5ji3I4EWOOAr41OOKz8z8jNiG9WeWDb4QqPLMwPHIIN2EXgv2kkb0dg6TIsG5j0wZ3RD3lW87Pb)9GQOAr41OOGmsmuYeSgIQcLw7SsdffpT9InQSvucOhm0BfLaZtOTMVx7UxG53td(73vr1IWRrrjWCITfugQqP1oO0qrXtBVyJkBfvlcVgffGldsbqcmMGdZdMeEodvucOhm0BfLaZtOTMVx7UxG53td(73vrjqiwmjAyohsLwBvHsRT0R0qrXtBVyJkBfvlcVgfv45mKKPxOkkb0dg6TIsG5j0wZ3RD3lW87Pb)9GE)(7b79A7(Ox8ejmpiIc1Us802l2CVU(9A7ErHAxeBi3GFpyuuceIftIgMZHuP1wvO0A7wLgkkEA7fBuzROeqpyO3kkTDVOqTlInKBWvuTi8AuucmNGRrIvHsRTGQ0qrXtBVyJkBfvlcVgffWcHp5ejdZWtqa3fGROeqpyO3kkBlaGKDbojdSejtHBuu(emeALjuuBvHsRT7Q0qrXtBVyJkBfvlcVgfL9QfGxwbbCxaUIsa9GHEROefQDrKb0bNVF)9G9EBlaGKDbojdSejRm3RRFpyVp6fprcZdIOqTRepT9In3V)(mqgjsUWK2McpNHKm9c9(93lW87b5En5EWCpyuuceIftIgMZHuP1wvOcfLWqKmKhpqO0qP1wLgkkEA7fBuzROeqpyO3kkBlaGKKH84bIKPWn3RRFpGNJfeiJ2(iVhK7bLokQweEnkkFqQaNjA2IhvO0cuLgkkEA7fBuzROAr41OOA6sI1WwsaQjifajtHJHkkb0dg6TIY2caijzipEGizkCZ97VhS3lQAzkCtsYqE8arcYOTpY7b5EqP)ED97b8CSGaz02h59GCVMq)9GrrnnkROA6sI1WwsaQjifajtHJHQqP1Uknuu802l2OYwrjGEWqVvu2waajjd5XdejtHBUF)9G9EaphliqgT9rEpn3VDNPZ9663lQAzkCtsYqE8arcYOTpY7bb)9A67bZ9663d45ybbYOTpY7b5(DPJIQfHxJIk3QHgVhsbqA6IHvGPcLwAIsdffpT9InQSvucOhm0BfLOQLPWnjjd5XdejiJ2(iVNM7bL(711VhWZXccKrBFK3dY9GsVIQfHxJIYEvLHaybrOcLw0rPHIIN2EXgv2kkb0dg6TIsu1Yu4MKKH84bIeKrBFK3tZ9Gs)9663d45ybbYOTpY7b5(T0rr1IWRrrzZqjdb3NCvO0AhvAOO4PTxSrLTIsa9GHEROSTaassgYJhisMc3C)(7fyEcT189A39cm)EAWF)273FppmmhrkCuMefbT1890G)E6t0rr1IWRrr1qrpmjkiKNqfkT00knuuTi8AuulphlKenLLjhLNqrXtBVyJkBvO0ANvAOO4PTxSrLTIsa9GHEROevTmfUjjzipEGibz02h590CpO0FVU(9aEowqGmA7J8EqUFl9kQweEnkkahY2RQmQqP1oO0qrXtBVyJkBfLa6bd9wrjQAzkCtsYqE8arcYOTpY7P5EqP)ED97b8CSGaz02h59GCpO0ROAr41OO6rWYa2lIOxlvO0Al9knuuTi8Auu2DoPaib0fGlvu802l2OYwfkT2UvPHIIN2EXgv2kQweEnkQLLmGLLKKxldpKmll0oNvucOhm0BfLOQLPWnPOSeyKcGy4oWsqgT9rEpi3V9ED97fvTmfUjfLLaJuaed3bwcYOTpY7P5EqP)ED97rQHEBV4ewTmKOm3RRFpGNJfeiJ2(iVhe83dk9kQPrzf1YsgWYssYRLHhsMLfANZQqP1wqvAOO4PTxSrLTIQfHxJIkF1gVJckjOSPxlVgfLa6bd9wrjQAzkCtkklbgPaigUdSeKrBFK3dY9BVxx)ErvltHBsrzjWifaXWDGLGmA7J8EAUhu6Vxx)EKAO32loHvldjkZ9663d45ybbYOTpY7bb)9GsVIIbayrqMgLvu5R24DuqjbLn9A51OcLwB3vPHIIN2EXgv2kQweEnkQ8vB8okOKWO2lgvrjGEWqVvuaEowqGmA7J8EAUFlD2H711Vxu1Yu4MuuwcmsbqmChyjiJ2(iVhK73EVU(9i1qVTxCcRwgsugffdaWIGmnkROYxTX7OGscJAVyuvO0ARMO0qrXtBVyJkBfLa6bd9wrPT7rQHEBV4ewTmKOmkQweEnkQOSeyKcGy4oWuHsRT0rPHIIN2EXgv2kkb0dg6TIcWZXccKrBFK3tZ9BPZoCVU(9MksrzjWifaXWDGLGmA7J8ED97rQHEBV4ewTmKOmkQweEnkQOSeyKcGaEdrBvO0A7oQ0qrXtBVyJkBfvlcVgfvMsaohsNUydruOzSIo8AiggjxWkkb0dg6TIY2caijzipEGizkCZ97VhS3lQAzkCtkklbgPaigUdSeKrBFK3tZ9BP)ED97rQHEBV4ewTmKOm3dM711VhWZXccKrBFK3dY90rrnnkROYucW5q60fBiIcnJv0HxdXWi5cwfkT2QPvAOO4PTxSrLTIsa9GHEROSTaassgYJhisMc3C)(7b79IQwMc3KKmKhpqKGmA7J8EAUhu6Vxx)ErvltHBssgYJhisqgT9rEpi3d69G5ED97b8CSGaz02h59GC)w6OOAr41OOSxvzifajWycpmkcvO0A7oR0qrXtBVyJkBfvlcVgffKrRGj5wUPhbtmmsUGvucOhm0BfLOQLPWnPOSeyKcGy4oWsqgT9rEpn3VL(711VhPg6T9Ity1YqIYOOMgLvuqgTcMKB5MEemXWi5cwfkT2Udknuu802l2OYwr1IWRrrLVAJ3rbLe72KZkkb0dg6TIsu1Yu4MKKH84bIeKrBFK3tZ9Gs)9663d45ybbYOTpY7b5EqPxrXaaSiitJYkQ8vB8okOKy3MCwfkTaLELgkkEA7fBuzROAr41OOY7fl61IHsIDvJIsa9GHEROevTmfUjjzipEGibz02h590CpO0FVU(9aEowqGmA7J8EqUhu6vutJYkQ8EXIETyOKyx1OcLwGUvPHIIN2EXgv2kQweEnkkCqpW8jNi5CuEcsbqmqwgDEhykkb0dg6TIsu1Yu4MuuwcmsbqmChyjiJ2(iVNM73s)9663Jud92EXjSAzirzuutJYkkCqpW8jNi5CuEcsbqmqwgDEhyQqPfOGQ0qrXtBVyJkBfvlcVgfvlXqQhwsGnDvqIOG9srjGEWqVvug22caibB6QGerb7fXW2waajtHBUxx)EBlaGKKH84bIeKrBFK3tZ97W9663d45ybbYOTpY7b5EqPJIAAuwr1smK6HLeytxfKikyVuHslq3vPHIIN2EXgv2kkb0dg6TIY2caijzipEGizkCZ97VhS3lQAzkCtsYqE8arcYOTpY7P5(T05ED97fvTmfUjjzipEGibz02h59GCpO3dM711VhWZXccKrBFK3dY9GsVIQfHxJIcxbxgKyFiqwwtpcwfkTavtuAOO4PTxSrLTIsa9GHEROSTaassgYJhisMc3C)(7b79IQwMc3KKmKhpqKGmA7J8ED97fvTmfUjjQrWta7GneGvJYjbwdZz594Vh07bZ97VxB3BQijQrWta7GneGvJYeBl4KGmA7J8(93d27fvTmfUjbDPp5eP1qa3fGNGmA7J8(93lQAzkCtcWLHKuaealiIeKrBFK3RRFpGNJfeiJ2(iVhK7357bJIQfHxJIsuJGNa2bBiaRgLvHslqPJsdfvlcVgfLKH84bcffpT9InQSvHslq3rLgkkEA7fBuzROeqpyO3kkBlaGKKH84bIKPWnkQweEnkQaJjwJDzngcqbfSkuAbQMwPHIIN2EXgv2kkb0dg6TIY2caijzipEGizkCJIQfHxJIkJf0bq4toXE1YqfkTaDNvAOO4PTxSrLTIsa9GHEROSTaassgYJhisMc3C)(7b79rdZ5ifoktIIKreeqP)EAUFx6Vxx)(OH5CKW4EfyPmI4EqWFpO0FpyUxx)(OH5CKchLjrrmoFpi3dQIQfHxJIcYDgFYjaRgLLQqPfO7GsdffpT9InQSvucOhm0BfLTfaqsYqE8arYu4gfvlcVgffqjSKSH00fd9Gj2CJQcLw7sVsdffpT9InQSvucOhm0BfLTfaqsYqE8arYu4M73FppmmhX9GCVMqVIQfHxJIcLrlicsbqwwc3qmqUrLQqP1UBvAOO4PTxSrLTIsa9GHEROSTaassgYJhisMc3OOAr41OOGEMmlM4drMPfSkuATlOknuu802l2OYwrjGEWqVvu2waajjd5XdejtHBuuTi8Auu2DoPaib0fGlvHsRD3vPHIIN2EXgv2kkb0dg6TIY2caijzipEGizkCZ97VhS3d275nYYZKHnjbcXQcynUGyVAzC)(7fvTmfUjjqiwvaRXfe7vlJeKrBFK3dc(7bL(7bZ9663RT75nYYZKHnjbcXQcynUGyVAzCpyuuTi8AuuwsM4bJkvHkuuYqPHsRTknuuTi8Auu4WC4YNCIb251qYyncmffpT9InQSvHslqvAOO4PTxSrLTIsa9GHEROIEXtKKmKhpqK4PTxS5ED97fvTmfUjfLLaJuaed3bwcYOTpY7P5(D8ED97rQHEBV4ewTmKOmkQweEnkkaxgssbqaSGiuHsRDvAOO4PTxSrLTIQfHxJIc6sFYjsRHaUlaxrjGEWqVvurV4jssgYJhis802l2CVU(9IQwMc3KIYsGrkaIH7albz02h590CpO3RRFpsn0B7fNWQLHeLrrjqiwmjAyohsLwBvHslnrPHIIN2EXgv2kkb0dg6TIY2caibTKy(Kt0uTHj48XKmfU5(933IWrIj8WOolVNM73QOAr41OOGwsmFYjAQ2WeC(yuHsl6O0qrXtBVyJkBfLa6bd9wrjW8eAR571U7fy(90C)wfvlcVgffKrIHsMG1quvO0AhvAOO4PTxSrLTIQfHxJIcWLbPaibgtWH5btcpNHkkb0dg6TIsG53dY97QOeielMenmNdPsRTQqPLMwPHIIN2EXgv2kkb0dg6TIsG53dc(739(93ZddZrCpi3th6vuTi8Auu8WWCNU8jNWlxZoufkT2zLgkkEA7fBuzROeqpyO3kkbMNqBnFV2DVaZVNM7P)(933IWrIj8WOolVh)9BVxx)EbMNqBnFV2DVaZVNM73QOAr41OOeyoX2ckdvO0AhuAOO4PTxSrLTIQfHxJIk8CgsY0lufLa6bd9wrjku7IidOdoF)(7fyEcT189A39cm)EAUF373FV2U3urkklbgPaigUdSeKrBFK3V)EBlaGKmkikHByGr6XqaCiNmfUrrjqiwmjAyohsLwBvHsRT0R0qr1IWRrrjWCcUgjwrXtBVyJkBvO0A7wLgkkEA7fBuzROeqpyO3kkrHAxezaDW573FVTfaqY0JGjfarG5Akpb5wekQweEnkkzgFgFYjcypmbCxaUkuATfuLgkkEA7fBuzROAr41OOSxTa8YkiG7cWvucOhm0BfLOqTlImGo4897VhS3d27JEXtKKmKhpqK4PTxS5ED97fvTmfUjfLLaJuaed3bwcYOTpY7P5EqVxx)EKAO32loHvldjkZ9G5(93d27fvTmfUjbDPp5eP1qa3fGNGmA7J8EAUh073FVOQLPWnjaxgssbqaSGisqgT9rEpn3d69663lQAzkCtc6sFYjsRHaUlapbz02h59GC)U3V)ErvltHBsaUmKKcGaybrKGmA7J8EAUF373FVaZVNM7b9ED97fvTmfUjbDPp5eP1qa3fGNGmA7J8EAUF373FVOQLPWnjaxgssbqaSGisqgT9rEpi3V797VxG53tZ9AY9663lW87P5E6CpyUxx)EBlaGKDbojdSejRm3dgfLaHyXKOH5CivATvfkT2URsdffpT9InQSvuTi8AuuHNZqsMEHQOeqpyO3kkrHAxezaDW573FVaZtOTMVx7UxG53tZ9BvuceIftIgMZHuP1wvO0ARMO0qr5tWqOvMqrTvr1IWRrrbSq4torYWm8eeWDb4kkEA7fBuzRcLwBPJsdffpT9InQSvuTi8Auu2RwaEzfeWDb4kkb0dg6TIsuO2frgqhC((93d27fvTmfUjb4YqskacGfercYOTpY7b5(DVF)9cm)E83d69663ZddZrKchLjrrqBnFpi3V9EWC)(7b79zGmsKCHjTnfEodjz6f69663lW8eAR571U7fy(9GCpO3dgfLaHyXKOH5CivATvfQqrjzipEGqPHsRTknuu802l2OYwrjGEWqVvu2waajjd5XdejiJ2(iVhK73EVU(9TiCKycpmQZY7P5(TkQweEnkkaxgssbqaSGiuHslqvAOO4PTxSrLTIsa9GHEROefQDrKb0bNVF)9G9(weosmHhg1z590CpO3RRFFlchjMWdJ6S8EAUF797VxB3lQAzkCtc6sFYjsRHaUlapzL5EWOOAr41OOKz8z8jNiG9WeWDb4QqP1Uknuu802l2OYwr1IWRrrbDPp5eP1qa3fGROeqpyO3kkrHAxezaDWzfLaHyXKOH5CivATvfkT0eLgkkFcgcTYeehqrLlmjiJ2(iXtVIQfHxJIcWLHKuaealicffpT9InQSvHsl6O0qrXtBVyJkBfvlcVgffGldsbqcmMGdZdMeEodvucOhm0BfLaZVhK73vrjqiwmjAyohsLwBvHsRDuPHIIN2EXgv2kkb0dg6TIsG5j0wZ3RD3lW87P5(T3V)EEyyoIu4OmjkcAR57b5(TkQweEnkkiJedLmbRHOQqPLMwPHIIN2EXgv2kQweEnkk7vlaVScc4UaCfLa6bd9wrjku7IidOdoFVU(9A7(Ox8ejmpiIc1Us802l2OOeielMenmNdPsRTQqP1oR0qr1IWRrrjZ4Z4tora7HjG7cWvu802l2OYwfQqfkkKyO0RrPfO0dk90RPbDhvu4A44tUurr3ydVHQ1gCT2jTb9(71aJV3rZuW4EGcE)gtyisgyJDpK3ilhYM7LfkFFBffAhS5Ebwp5SmD0UbPp89GsNnO3VbQbjggS5(nw4Omjksgrq2q2qsqgT9rUXUpQ73yHJYKOizebzdzdzJDpy3QzWKoApAPBSH3q1AdUw7K2GE)9AGX37OzkyCpqbVFJzyG2AfBS7H8gz5q2CVSq57BROq7Gn3lW6jNLPJ2ni9HVF7g073a1Gedd2C)glCuMefjJiiBiBijiJ2(i3y3h19BSWrzsuKmIGSHSHSXUhSGQzWKoApA3GJMPGbBUxtFFlcVM7xUmKPJwfvgyb4lwrP93t3WhdUEbodVFNCnGF0Q93tR1cX9GUJiFpO0dk9hThTA)97eAMfwbBU3MbkiFVOqT74EBo3hz6(nSqWzc59tnAhwdrbSw33IWRrEFnlePJwT)(weEnYugilku7oWdSAj4hTA)9Ti8AKPmqwuO2DKf(nbQYC0Q933IWRrMYazrHA3rw43STYr5j6WR5Ov7VNA6msSkUh2U5EBlaa2CVm6qEVnduq(ErHA3X92CUpY77XCFgiRDzQi8j)ExEVPgoD0Q933IWRrMYazrHA3rw43uoDgjwfez0H8OTfHxJmLbYIc1UJSWVzMk8AoA1(73aySaC59oW9ikR7XAK4777dOpGZX98gz5zYWM7dSoUhxpH8(OU3MV3sYM7JkNdmgEpopWUxJAJF02IWRrMYazrHA3rw43ePg6T9IrEAugFugsneljtcOpGZbYvg8soqgPEzX45nYYZKHnjbcXQcynUGyVAzORZBKLNjdBsllzalljjVwgEizwwODoRRZBKLNjdBs5R24DuqjXUn5SUoVrwEMmSjLVAJ3rbLeu20RLxJUoVrwEMmSjbz0kysULB6rWedJKl4JwT)(ni0qVTx89bwh3JZxR7dETUhrzDVdCpIY6EC(AD)WS5(OUhx7X9rDVOLX9AuB8nn19tf3JRN4(OUx0Y4EpUVJ7716(EqGwq(OTfHxJml8BIud92EXipnkJhRwgsugKRm4LCGms9YIXlQAzkCtkklbgPaigUdSeKrBFKzTd0enmNJu4OmjkIXzDDTf9INijzipEGiXtBVyZETHud92EXPOmKAiwsMeqFaNJ98gz5zYWMKb622lFYj(aEMYSpAyohPWrzsuKmIGSl9jiJ2(ibz7U0VpAyohPWrzsuKmIGSl9jiJ2(iPzN11b8CSGaz02hjiB3L(9aEowqGmA7JKgrvltHBssgYJhisqgT9rUxu1Yu4MKKH84bIeKrBFK0aQUUTfaqsYqE8arYkZEaphliqgT9rsZ2ThTTi8AKPmqwuO2DKf(nrQHEBVyKNgLXdutqkasMchdjzGSOqT7GiW6z4fYvg8soqgPEzX43Udi7a41w0lEIKKH84bIepT9In7blsn0B7fNIYqQHyjzsa9bCo015nYYZKHnPwIHupSKaB6QGerb7fyoABr41itzGSOqT7il8BAjzIhmkYtJY4B6sI1WwsaQjifajtHJHhTTi8AKPmqwuO2DKf(nfyoX2ckdKDa8Al6fprsYqE8arIN2EXgDDTf9INib4YGuaKaJj4W8GjHNZWepT9InhTTi8AKPmqwuO2DKf(nfyobxJeJSdGp6fprcWLbPaibgtWH5btcpNHjEA7fB01zPKhbNe1aSCrq6XqKb0b4eARPk4rBlcVgzkdKffQDhzHFtFqQaNjA2IhsGXeCyEWKWZz4rBlcVgzkdKffQDhzHFZCRgA8EifaPPlgwb2r7rR2F)oHMzHvWM7zKyiI7dhLVpW47BruW7D59nsTVA7fNoABr41iXlZWnKG1JHidOdoF0Q93VtL89zQWR5Eh4EkgYJhiU3L3BLb57l492vGDp1obD)(Em3RrTXVVH89wzq((cEFGX3hnmNJ7X5R19gNVhNhy(C)os)9swuJrE02IWRrMf(nZuHxdYoaEBlaGKKH84bIKvgDDBlaGKmkikHByGr6XqaCiNSYS3urkklbgPaigUdSeKrBFK66aEowqGmA7Jee87i9hTTi8AKzHFtiJedLmbRHOi7a4fyEcT1S2jWCAWd6EWg9INijzipEGiXtBVyJUU2mvKIYsGrkaIH7albz02hjy2BBbaKKmKhpqKmfUzpy5HH5isHJYKOiOTMbzRUE0lEIKKH84bIepT9In7fvTmfUjjzipEGibz02hjiGQRRTOx8ejjd5XdejEA7fB2lQAzkCtkklbgPaigUdSeKrBFKGS7ETHud92EXjSAzirz015HH5isHJYKOiOTMbrt2lQAzkCtcWLHKuaealiIeKrBFKGSnrhWC02IWRrMf(nbAE5dtKrHM5Ov7VFNk57P7vq3qJ7DG7VhrzDFd57rDP0N8774(f3Y4(DVxG5iF)gEm3FVKH84bcKVFdpM7Vp7k2jUVH89tf3BLb573WATXVhrzDp7bgdVVH89TDzf3h19IoZ98WWCeiFFbVxYqE8aX9U8(2USI7J6ErHY3BLb57l49AuB87D59TDzf3h19IcLV3kdY3xW7P7fD)ExEVOq9j)ERm33J5EeL194816ErN5EEyyoI7LvnhTTi8AKzHFtaxgKcGeymbhMhmj8CgISaHyXKOH5CiXVfzhaVaZtOTM1obMtd(D3BBbaKKmKhpqKmfUzVTfaqsYCG5tob25CYu4M9GLhgMJifoktIIG2AgKT66rV4jssgYJhis802l2Sxu1Yu4MKKH84bIeKrBFKGaQUU2IEXtKKmKhpqK4PTxSzVOQLPWnPOSeyKcGy4oWsqgT9rcYU71gsn0B7fNWQLHeLrxNhgMJifoktIIG2AgenzVOQLPWnjaxgssbqaSGisqgT9rcY2eDaZrR2F)ovY3RbDZ7DG794EC1e3Bd5g87rBzWqeiF)gwRn(9nKVh1LsFYVVJ7xClJ7b9EbMJ89ByT243B753lQAzkCJ8(gY3pvCVvgKVFdR1g)EeL19Shym8(gY332LvCFu3l6m3ZddZrG89f8Ejd5Xde37Y7B7YkUpQ7ffkFVvgKVVG3RrTXV3L3lkuFYV3kdY3xW7P7fD)ExEVOq9j)ERm33J5EeL194816ErN5EEyyoI7LvnhTTi8AKzHFZWZzijtVqrwGqSys0WCoK43ISdGxBIc1Ui2qUbFVaZtOTM1obMtdEq3d2Ox8ejjd5XdejEA7fB011MPIuuwcmsbqmChyjiJ2(i11Br4iXeEyuNL0aky2BBbaKKmhy(KtGDoNmfUzVTfaqsYqE8arYu4M9GLhgMJifoktIIG2AgKT66rV4jssgYJhis802l2Sxu1Yu4MKKH84bIeKrBFKGaQUU2IEXtKKmKhpqK4PTxSzVOQLPWnPOSeyKcGy4oWsqgT9rcYU71gsn0B7fNWQLHeLrxNhgMJifoktIIG2AgenzVOQLPWnjaxgssbqaSGisqgT9rcY2eDaZrBlcVgzw43uG5eCnsmYoaETf9INib4YGuaKaJj4W8GjHNZWepT9In7ZazKi5ctABk8CgsY0l09HJYGGF3J2weEnYSWVPOxlslcVgYYLbYtJY4fgIKH84bcKDa8rV4jssgYJhis802l2C02IWRrMf(nf9ArAr41qwUmqEAugVWqKmaYoaETf9INijzipEGiXtBVyZrR2F)gOxR7dm(EkgYJhiUVfHxZ9lxg37a3tXqE8aX9U8EHfeYtSqCVvMJ2weEnYSWVPOxlslcVgYYLbYtJY4LmKhpqGSdG32caijzipEGizL5Ov7VFd0R19bgFpLg33IWR5(LlJ7DG7dmgY33q(EqVVG3VyP8EEyuNLhTTi8AKzHFtrVwKweEnKLldKNgLXldKDa8TiCKycpmQZsq29Ov7VFd0R19bgF)gU2jUVfHxZ9lxg37a3hymKVVH897EFbVhTG898WOolpABr41iZc)MIETiTi8AilxgipnkJVlgzhaFlchjMWdJ6SKg87E0E0Q93VHfHxJmTHRDI7D59(e8yyZ9af8EljFpopWUFdglcxq2WgdzdS4gj((Em3lSGqEIfI7hMnY7J6EB((kt4OoDXMJ2weEnYuxmECyoC5toXa78AizSgb2rBlcVgzQlol8BYddZD6YNCcVCn7qKDa8AldKrIKlmPTPWZzijtVq3lWCqWVDppmmhbi0H(J2weEnYuxCw43eWLHKuaealicKDa88WWCePWrzsue0wZ0SvxFX58yAiIKMT4rsS7iwCo3WepT9In7fvTmfUjbDPp5eP1qa3fGNGmA7JeKweEnjaxgssbqaSGisIwgzrNJ2weEnYuxCw43e6sFYjsRHaUlahzbcXIjrdZ5qIFlYoaEWg9INiHdZHlFYjgyNxdjJ1iWs802l2Sxu1Yu4Me0L(KtKwdbCxaEYyb7WRHgrvltHBs4WC4YNCIb251qYyncSeKrBFKzPjGzpyfvTmfUjb4YqskacGfercYOTpsA2vxxG50GNoG5OTfHxJm1fNf(nHwsmFYjAQ2WeC(yq2bWBBbaKGwsmFYjAQ2WeC(ysMc3C02IWRrM6IZc)MYm(m(KteWEyc4UaCKDa8Ic1UiYa6GZ7blybRaZPzxDDrvltHBsaUmKKcGaybrKGmA7JKMDem7bRaZPbpD01fvTmfUjb4YqskacGfercYOTpsAafmGrxNhgMJifoktIIG2Age87QRBBbaKm9iysbqeyUMYtqUfbyoABr41itDXzHFtiJedLmbRHOi7a4fyEcT1S2jWCAWd6rBlcVgzQlol8BkWCITfugi7a4fyEcT1S2jWCAWV7rBlcVgzQlol8Bc4YGuaKaJj4W8GjHNZqKfielMenmNdj(Ti7a4fyEcT1S2jWCAWV7rBlcVgzQlol8BgEodjz6fkYceIftIgMZHe)wKDa8cmpH2Aw7eyon4bDpy1w0lEIeMherHAxjEA7fB011MOqTlInKBWbZrBlcVgzQlol8BkWCcUgjgzhaV2efQDrSHCd(rBlcVgzQlol8BcSq4torYWm8eeWDb4i7a4TTaas2f4KmWsKmfUbzFcgcTYe43E02IWRrM6IZc)M2RwaEzfeWDb4ilqiwmjAyohs8Br2bWlku7IidOdoVhS2waaj7cCsgyjswz01bB0lEIeMherHAxjEA7fB2NbYirYfM02u45mKKPxO7fyoiAcyaZr7rR2F)gOQLPWnYJ2weEnYKWqKmaEFqQaNjA2IhsGXeCyEWKWZziYoaEBlaGKKH84bIKPWn66aEowqGmA7JeeqPZrBlcVgzsyisgil8BMB1qJ3dPainDXWkWq2bWd45ybbYOTpsA2UZ0rxxBi1qVTxCcRwgsuM9IQwMc3KIYsGrkaIH7albz02hji43Qj66aEowqGmA7JeKD3XJ2weEnYKWqKmqw43exbxgKyFiqwwtpcgzhaVOQLPWnPOSeyKcGy4oWsqgT9rsdD2zDDrvltHBsrzjWifaXWDGLGmA7Jeeq11rQHEBV4ewTmKOm66aEowqGmA7JeeqP)Ov7VFNk573Wqrp89AuqipX9oW9ikR7BiFpQlL(KFFh3V4wg3V9(naMFFpM7XvZglUx0zUNhgMJ4ECEG5Z90NOZ9swuJrE02IWRrMegIKbYc)Mnu0dtIcc5jq2bWlW8eARzTtG50GF7EEyyoIu4OmjkcARzAWtFIohTTi8AKjHHizGSWVPLKjEWOipnkJFzjdyzjj51YWdjZYcTZzKDa8IQwMc3KIYsGrkaIH7albz02hjiB11fvTmfUjfLLaJuaed3bwcYOTpsAaLEDDKAO32loHvldjkJUoGNJfeiJ2(ibbpO0F02IWRrMegIKbYc)MwsM4bJImdaWIGmnkJpF1gVJckjOSPxlVgKDa8IQwMc3KIYsGrkaIH7albz02hjiB11fvTmfUjfLLaJuaed3bwcYOTpsAaLEDDKAO32loHvldjkJUoGNJfeiJ2(ibbpO0F02IWRrMegIKbYc)MwsM4bJImdaWIGmnkJpF1gVJckjmQ9Irr2bWd45ybbYOTpsA2sNDqxxu1Yu4MuuwcmsbqmChyjiJ2(ibzRUosn0B7fNWQLHeL5OTfHxJmjmejdKf(nJYsGrkaIH7adzhaV2qQHEBV4ewTmKOm7bR24nYYZKHnjbcXQcynUGyVAzORlQAzkCtsGqSQawJli2RwgjiJ2(ibb)wWShScmNMT668WWCeGOj0dMJ2weEnYKWqKmqw43ugfeLWnmWi9yiaoKrgzhaVOQLPWnjzuquc3WaJ0JHa4qojWAyolXdQUUPIuuwcmsbqmChyjiJ2(i11b8CSGaz02hjiGsVUoyTTaas4k4YGe7dbYYA6rWjiJ2(iPzl966IQwMc3KWvWLbj2hcKL10JGtqgT9rsJOQLPWnjzuquc3WaJ0JHa4qobyTweilWAyotchL111glL8i4eUcUmiX(qGSSMEeCcT1ufem7bROQLPWnPOSeyKcGy4oWsqgT9rsJOQLPWnjzuquc3WaJ0JHa4qobyTweilWAyotchL11rQHEBV4ewTmKOm71gVrwEMmSjzGUT9YNCIpGNPmGzVOQLPWnjaxgssbqaSGisqgT9rcc(DyVaZPb)U7fvTmfUjHdZHlFYjgyNxdjJ1iWsqgT9rcc(T7E02IWRrMegIKbYc)MrzjWifab8gI2i7a4b8CSGaz02hjnBPZoORBQifLLaJuaed3bwcYOTpsDDKAO32loHvldjkZrBlcVgzsyisgil8BAVQYqkasGXeEyuei7a4fvTmfUjfLLaJuaed3bwcYOTpsA0e6ORJud92EXjSAzirz2lQAzkCtcWLHKuaealiIeKrBFKGaQUoGNJfeiJ2(ibzlO66aEowqGmA7JKMT0t)EaphliqgT9rcY2T0VhSIQwMc3KaCzijfabWcIibz02hji7QRlQAzkCtchMdx(KtmWoVgsgRrGLGmA7Jee6ORlQAzkCtc6sFYjsRHaUlapbz02hji0bmhTTi8AKjHHizGSWVPOgbpbSd2qawnkJSdGxBMksIAe8eWoydby1OmX2cojiJ2(i3dwWkQAzkCtsuJGNa2bBiaRgLtqgT9rccErvltHBsrzjWifaXWDGLGmA7JmRT66i1qVTxCcRwgsugWShSAl6fprchMdx(KtmWoVgsgRrGL4PTxSrxxu1Yu4MeomhU8jNyGDEnKmwJalbz02hjy2lQAzkCtc6sFYjsRHaUlapbz02h5ErvltHBsaUmKKcGaybrKGmA7JCVTfaqsgfeLWnmWi9yiaoKtMc3ORBQifLLaJuaed3bwcYOTpsWORd45ybbYOTpsq25JwT)(DQKVp7vvM7P7wqe37a3RrzjWUVaUFJZDGTXK3lQAzkCZ9U8(Ci3bdVpW65(DP)EWgyU8EFelldlVhhMV471O2437Y7fwqipXcX9TiCKyWG89f8(ca4ErvltHBUhhgp3JOSUVH89y1Y4t(91e19AuBCKVVG3JdJN7dm((OH5CCVlVVTlR4(OU348rBlcVgzsyisgil8BAVQYqaSGiq2bWlQAzkCtkklbgPaigUdSeKrBFK0Sl966i1qVTxCcRwgsugDDaphliqgT9rccO0F02IWRrMegIKbYc)M2muYqW9jhzhaVOQLPWnPOSeyKcGy4oWsqgT9rsZU0RRJud92EXjSAzirz01b8CSGaz02hjiBPZrBlcVgzsyisgil8BU8CSqs0uwMCuEIJ2weEnYKWqKmqw43eWHS9QkdYoaErvltHBsrzjWifaXWDGLGmA7JKMDPxxhPg6T9Ity1YqIYORd45ybbYOTpsq2s)rBlcVgzsyisgil8B2JGLbSxerVwi7a4fvTmfUjfLLaJuaed3bwcYOTpsA2LEDDKAO32loHvldjkJUoGNJfeiJ2(ibbu6pABr41itcdrYazHFt7oNuaKa6cWLhTTi8AKjHHizGSWVPLKjEWOipnkJptjaNdPtxSHik0mwrhEnedJKlyKr2bWlQAzkCtkklbgPaigUdSeKrBFK0Sl966i1qVTxCcRwgsuMJ2weEnYKWqKmqw430sYepyuKNgLXdz0kysULB6rWedJKlyKDa8IQwMc3KIYsGrkaIH7albz02hjn7sVUosn0B7fNWQLHeL5OTfHxJmjmejdKf(nTKmXdgfzgaGfbzAugF(QnEhfusSBtoJSdGxu1Yu4MuuwcmsbqmChyjiJ2(iPbu611rQHEBV4ewTmKOm66aEowqGmA7JeeqP)OTfHxJmjmejdKf(nTKmXdgf5Prz859If9AXqjXUQbzhaVOQLPWnPOSeyKcGy4oWsqgT9rsdDOJUosn0B7fNWQLHeLrxhWZXccKrBFKGSf0J2weEnYKWqKmqw430sYepyuKNgLXJd6bMp5ejNJYtqkaIbYYOZ7adzhaVOQLPWnPOSeyKcGy4oWsqgT9rsdO0RRJud92EXjSAzirzoABr41itcdrYazHFtljt8GrrEAugFlXqQhwsGnDvqIOG9czhapsn0B7fNIYqQHyjzsa9bCo2dwrvltHBsrzjWifaXWDGLGmA7JKgq3QRJud92EXjSAzirzaZEWAyBlaGeSPRcsefSxedBBbaKmfUrx32caijJcIs4ggyKEmeahYjiJ2(iPz7U66aEowqGmA7Ju7evTmfUjfLLaJuaed3bwcYOTpsq0e63lQAzkCtkklbgPaigUdSeKrBFKGakD01b8CSGaz02hjiGshWC02IWRrMegIKbYc)MwsM4bJI80Om(wIHupSKaB6QGerb7fYoaETHud92EXPOmKAiwsMeqFaNJ9G1W2waajytxfKikyVig22caizkCJUoy1gVrwEMmSjzGUT9YNCIpGNPm66rdZ5ifoktIIKreKDPpbz02hji7my2dwtfPOSeyKcGy4oWsqgT9rQRlQAzkCtkklbgPaigUdSeKrBFKzTd0a45ybbYOTpsWS32caijJcIs4ggyKEmeahYjRm66aEowqGmA7JeeqPdyoABr41itcdrYazHFZaJjwJDzngcqbf8rBlcVgzsyisgil8BMXc6ai8jNyVAzC0Q93VbRwM73q5oJp53t3xnklVhOG3ZAMfwbFpSNC((cEp4(ADVTfaGe57DG7ZusPBV409B4fUgH8(aI4(OUpNJ7dm((vHJLX9IQwMc3CVDlzZ91CFJu7R2EX3ZdJ6SmD02IWRrMegIKbYc)MqUZ4toby1OSezhaVTfaqsYqE8arYu4M9GnAyohPWrzsuKmIGak90Sl966rdZ5iHX9kWszebi4bLEWORhnmNJu4OmjkIXzqa9OTfHxJmjmejdKf(nbkHLKnKMUyOhmXMB0J2weEnYKWqKmqw43eLrlicsbqwwc3qmqUrLi7a45HH5iartO)OTfHxJmjmejdKf(nHEMmlM4drMPf8rBlcVgzsyisgil8BA35KcGeqxaU8OTfHxJmjmejdKf(nTKmXdgvISdGhS8gz5zYWMKaHyvbSgxqSxTm2lQAzkCtsGqSQawJli2RwgjiJ2(ibbpO0dgDDTXBKLNjdBsceIvfWACbXE1Y4O9Ov7VFdu1Yu4g5rBlcVgzsyisgYJhiW7dsf4mrZw8qcmMGdZdMeEodr2bWBBbaKKmKhpqKmfUrxhWZXccKrBFKGakDoABr41itcdrYqE8arw430sYepyuKNgLX30LeRHTKautqkasMchdr2bWBBbaKKmKhpqKmfUzpyfvTmfUjjzipEGibz02hjiGsVUoGNJfeiJ2(ibrtOhmhTTi8AKjHHizipEGil8BMB1qJ3dPainDXWkWq2bWBBbaKKmKhpqKmfUzpyb8CSGaz02hjnB3z6ORlQAzkCtsYqE8arcYOTpsqWRPbJUoGNJfeiJ2(ibzx6C02IWRrMegIKH84bISWVP9QkdbWcIazhaVOQLPWnjjd5XdejiJ2(iPbu611b8CSGaz02hjiGs)rBlcVgzsyisgYJhiYc)M2muYqW9jhzhaVOQLPWnjjd5XdejiJ2(iPbu611b8CSGaz02hjiBPZrR2F)ovY3VHHIE471OGqEI7DG7PyipEG4ExE)uX9wzq((Em3JOSUVH89OUu6t(9DC)IBzC)273ayoY33J5EC1SXI7fDM75HH5iUhNhy(Cp9j6CVKf1yKhTTi8AKjHHizipEGil8B2qrpmjkiKNazhaVTfaqsYqE8arYu4M9cmpH2Aw7eyon43UNhgMJifoktIIG2AMg80NOZrBlcVgzsyisgYJhiYc)MlphlKenLLjhLN4OTfHxJmjmejd5XdezHFtahY2RQmi7a4fvTmfUjjzipEGibz02hjnGsVUoGNJfeiJ2(ibzl9hTTi8AKjHHizipEGil8B2JGLbSxerVwi7a4fvTmfUjjzipEGibz02hjnGsVUoGNJfeiJ2(ibbu6pABr41itcdrYqE8arw430UZjfajGUaC5rBlcVgzsyisgYJhiYc)MwsM4bJI80Om(LLmGLLKKxldpKmll0oNr2bWlQAzkCtkklbgPaigUdSeKrBFKGSvxxu1Yu4MuuwcmsbqmChyjiJ2(iPbu611rQHEBV4ewTmKOm66aEowqGmA7Jee8Gs)rBlcVgzsyisgYJhiYc)MwsM4bJImdaWIGmnkJpF1gVJckjOSPxlVgKDa8IQwMc3KIYsGrkaIH7albz02hjiB11fvTmfUjfLLaJuaed3bwcYOTpsAaLEDDKAO32loHvldjkJUoGNJfeiJ2(ibbpO0F02IWRrMegIKH84bISWVPLKjEWOiZaaSiitJY4ZxTX7OGscJAVyuKDa8aEowqGmA7JKMT0zh01fvTmfUjfLLaJuaed3bwcYOTpsq2QRJud92EXjSAzirzoABr41itcdrYqE8arw43mklbgPaigUdmKDa8AdPg6T9Ity1YqIYC02IWRrMegIKH84bISWVzuwcmsbqaVHOnYoaEaphliqgT9rsZw6Sd66MksrzjWifaXWDGLGmA7JuxhPg6T9Ity1YqIYC02IWRrMegIKH84bISWVPLKjEWOipnkJptjaNdPtxSHik0mwrhEnedJKlyKDa82waajjd5XdejtHB2dwrvltHBsrzjWifaXWDGLGmA7JKMT0RRJud92EXjSAzirzaJUoGNJfeiJ2(ibHohTTi8AKjHHizipEGil8BAVQYqkasGXeEyuei7a4TTaassgYJhisMc3ShSIQwMc3KKmKhpqKGmA7JKgqPxxxu1Yu4MKKH84bIeKrBFKGaky01b8CSGaz02hjiBPZrBlcVgzsyisgYJhiYc)MwsM4bJI80OmEiJwbtYTCtpcMyyKCbJSdGxu1Yu4MuuwcmsbqmChyjiJ2(iPzl966i1qVTxCcRwgsuMJ2weEnYKWqKmKhpqKf(nTKmXdgfzgaGfbzAugF(QnEhfusSBtoJSdGxu1Yu4MKKH84bIeKrBFK0ak966aEowqGmA7JeeqP)OTfHxJmjmejd5XdezHFtljt8GrrEAugFEVyrVwmusSRAq2bWlQAzkCtsYqE8arcYOTpsAaLEDDaphliqgT9rccO0F02IWRrMegIKH84bISWVPLKjEWOipnkJhh0dmFYjsohLNGuaedKLrN3bgYoaErvltHBsrzjWifaXWDGLGmA7JKMT0RRJud92EXjSAzirzoABr41itcdrYqE8arw430sYepyuKNgLX3smK6HLeytxfKikyVq2bWByBlaGeSPRcsefSxedBBbaKmfUrx32caijzipEGibz02hjn7GUoGNJfeiJ2(ibbu6C02IWRrMegIKH84bISWVjUcUmiX(qGSSMEemYoaEBlaGKKH84bIKPWn7bROQLPWnjjd5XdejiJ2(iPzlD01fvTmfUjjzipEGibz02hjiGcgDDaphliqgT9rccO0F02IWRrMegIKH84bISWVPOgbpbSd2qawnkJSdG32caijzipEGizkCZEWkQAzkCtsYqE8arcYOTpsDDrvltHBsIAe8eWoydby1OCsG1WCwIhuWSxBMksIAe8eWoydby1OmX2cojiJ2(i3dwrvltHBsqx6torAneWDb4jiJ2(i3lQAzkCtcWLHKuaealiIeKrBFK66aEowqGmA7JeKDgmhTTi8AKjHHizipEGil8BkzipEG4OTfHxJmjmejd5XdezHFZaJjwJDzngcqbfmYoaEBlaGKKH84bIKPWnhTTi8AKjHHizipEGil8BMXc6ai8jNyVAzGSdG32caijzipEGizkCZrBlcVgzsyisgYJhiYc)MqUZ4toby1OSezhaVTfaqsYqE8arYu4M9GnAyohPWrzsuKmIGak90Sl966rdZ5iHX9kWszebi4bLEWORhnmNJu4OmjkIXzqa9OTfHxJmjmejd5XdezHFtGsyjzdPPlg6btS5gfzhaVTfaqsYqE8arYu4MJ2weEnYKWqKmKhpqKf(nrz0cIGuaKLLWnedKBujYoaEBlaGKKH84bIKPWn75HH5iartO)OTfHxJmjmejd5XdezHFtONjZIj(qKzAbJSdG32caijzipEGizkCZrBlcVgzsyisgYJhiYc)M2DoPaib0fGlr2bWBBbaKKmKhpqKmfU5OTfHxJmjmejd5XdezHFtljt8GrLi7a4TTaassgYJhisMc3ShSGL3ilptg2KeieRkG14cI9QLXErvltHBsceIvfWACbXE1Yibz02hji4bLEWORRnEJS8mzytsGqSQawJli2RwgG5O9Ov7VNUj0lOhiUhhMV47LmKhpqCVlV3kZrBlcVgzsYqE8abEaxgssbqaSGiq2bWBBbaKKmKhpqKGmA7JeKT66TiCKycpmQZsA2E02IWRrMKmKhpqKf(nLz8z8jNiG9WeWDb4i7a4ffQDrKb0bN3d2weosmHhg1zjnGQR3IWrIj8WOolPz7ETjQAzkCtc6sFYjsRHaUlapzLbmhTTi8AKjjd5XdezHFtOl9jNiTgc4UaCKfielMenmNdj(Ti7a4ffQDrKb0bNpA1(71aZL3JZxR7fTmUNUx0977XCVpbdHwzI7dm(EbwpdVU3bUpW473jTb2437Y7HCBqCFpM7Lfkhy(KFpMNJXW7R5(aJVpd0lOhiUF5Y4EWUHsr3cM7D59nsTVA7fNoABr41itsgYJhiYc)MaUmKKcGaybrGSpbdHwzcIdGpxysqgT9rIN(J2weEnYKKH84bISWVjGldsbqcmMGdZdMeEodrwGqSys0WCoK43ISdGxG5GS7rBlcVgzsYqE8arw43eYiXqjtWAikYoaEbMNqBnRDcmNMT75HH5isHJYKOiOTMbz7rR2F)ovY3NDr3I89ECpoFTUVMfI7THCd(9OTmyiI7DG73G5X9BGc1UU3L3R1ge14(Ox8eS5OTfHxJmjzipEGil8BAVAb4Lvqa3fGJSaHyXKOH5CiXVfzhaVOqTlImGo4SUU2IEXtKW8Giku7kXtBVyZrBlcVgzsYqE8arw43uMXNXNCIa2dta3fGF0E02IWRrMKbECyoC5toXa78AizSgb2rBlcVgzsgzHFtaxgssbqaSGiq2bWh9INijzipEGiXtBVyJUUOQLPWnPOSeyKcGy4oWsqgT9rsZoQRJud92EXjSAzirzoA1(73Ps((nuk627R5(OH5CiVhNhyLvC)o5gc(9fW9bgF)ga2dFVHTTaaq(Eh4(mLu62lg577XCVdCVg1g)ExEFh3V4wg3d69swuJrEFJRrC02IWRrMKrw43e6sFYjsRHaUlahzbcXIjrdZ5qIFlYoa(Ox8ejjd5XdejEA7fB01fvTmfUjfLLaJuaed3bwcYOTpsAavxhPg6T9Ity1YqIYC02IWRrMKrw43eAjX8jNOPAdtW5JbzhaVTfaqcAjX8jNOPAdtW5JjzkCZ(weosmHhg1zjnBpABr41itYil8BczKyOKjynefzhaVaZtOTM1obMtZ2J2weEnYKmYc)MaUmifajWycompys45mezbcXIjrdZ5qIFlYoaEbMdYUhTTi8AKjzKf(n5HH5oD5toHxUMDiYoaEbMdc(D3ZddZracDO)Ov7VFNk573azFVdCpIY6(gY3Jwq((aRN7P)(naMFFJRrCpaSqVhT1899yUhRrIVF798WOiq((cEFd57rliFFG1Z9BVFdG5334Ae3dal07rBnF02IWRrMKrw43uG5eBlOmq2bWlW8eARzTtG50q)(weosmHhg1zj(T66cmpH2Aw7eyonBpA1(73Ps(EnOBEVdCpIY6(gY3Rj3xW7rliFVaZVVX1iUhawO3J2A((Em3RrTXVVhZ9u7e097BiFVDfy3pvCVvMJ2weEnYKmYc)MHNZqsMEHISaHyXKOH5CiXVfzhaVOqTlImGo48EbMNqBnRDcmNMD3RntfPOSeyKcGy4oWsqgT9rU32caijJcIs4ggyKEmeahYjtHBoABr41itYil8BkWCcUgj(OTfHxJmjJSWVPmJpJp5ebShMaUlahzhaVOqTlImGo48EBlaGKPhbtkaIaZ1uEcYTioA1(73Ps((Sl627DG7TRa7E6Er3VVhZ9BOu0T33q((PI7fRsYiFFbVFdLIU9ExEVyvs((Em3t3l6(9U8(PI7fRsY33J5EeL19yns89OfKVpW65EqVxG5iFFbVNUx097D59Ivj573qPOBV3L3pvCVyvs((Em3JOSUhRrIVhTG89bwp3V79cmh57l49ikR7XAK47rliFFG1Z905EbMJ89f8Eh4EeL195CCFFFgyjoABr41itYil8BAVAb4Lvqa3fGJSaHyXKOH5CiXVfzhaVOqTlImGo48EWc2Ox8ejjd5XdejEA7fB01fvTmfUjfLLaJuaed3bwcYOTpsAavxhPg6T9Ity1YqIYaM9Gvu1Yu4Me0L(KtKwdbCxaEcYOTpsAaDVOQLPWnjaxgssbqaSGisqgT9rsdO66IQwMc3KGU0NCI0AiG7cWtqgT9rcYU7fvTmfUjb4YqskacGfercYOTpsA2DVaZPbuDDrvltHBsqx6torAneWDb4jiJ2(iPz39IQwMc3KaCzijfabWcIibz02hji7UxG50Oj66cmNg6agDDBlaGKDbojdSejRmG5OTfHxJmjJSWVz45mKKPxOilqiwmjAyohs8Br2bWlku7IidOdoVxG5j0wZANaZPz7rR2F)ovY3t3POBVVhZ9(emeALjU3J7LbS9CS4(gxJ4OTfHxJmjJSWVjWcHp5ejdZWtqa3fGJSpbdHwzc8BpA1(73Ps((Sl627DG7P7fD)ExEVyvs((Em3JOSUhRrIVh07fy(99yUhrzbVF1Y4(8vz3R7X1Y71GUjY3xW7DG7ruw33q((2USI7J6ErN5EEyyoI77XCp7bgdVhrzbVF1Y4(CH5ECT8EnOBEFbV3bUhrzDFd57xSuEFG1Z9GEVaZVVX1iUhawO3l6mz8j)OTfHxJmjJSWVP9QfGxwbbCxaoYceIftIgMZHe)wKDa8Ic1UiYa6GZ7bROQLPWnjaxgssbqaSGisqgT9rcYU7fyoEq115HH5isHJYKOiOTMbzly2d2mqgjsUWK2McpNHKm9cvxxG5j0wZANaZbbuWOOARaRGkQnym4(YvHkuka]] )

end