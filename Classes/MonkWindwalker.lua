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
            id = 322109,
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
    
    spec:RegisterPack( "Windwalker", 20200822, [[d4KNqcqisP8isPQnPu1NukOgfqvNcOYReLmliQBrkv2Li)sPOHHu1XukTmG4zkvAAKI4AivSnLkQVPuOmoLk05uQG1PuG08as3dQAFifhuPawOOupKuKAIkfQUOsfHnIuP6JkvezKkfOCsLcuTsKsVePsPzQuGOBQuru7KuYpvkqOHIuPOLQuq6PizQKcxvPI0wvkqWxrQuySkfe7LK)IyWQ6WsTyk1JjmzkUmQnd4ZIQrdLtt1QjfjVgOmBLCBiTBf)wYWffhxPqwoONt00fUoLSDiY3HkJNuuNhcRhPsMpPA)QSARsdfLPdwPfi0dc90VJGasAl9B3bq2zfvGidROY0cW6CwrnnkROOB4JbxVaJHkQmnIv1gLgkkzzbfSIsrzB5Ryd(OSvuMoyLwGqpi0t)occiPT0VDh3UZkkzgwO0cKDEhuuyUXWJYwrzyPqrP93t3WhdUEbgdVFNCnGD0Q93tR1cX9GSZiFpi0dc9kQLldPsdfLWqKmGsdLwBvAOO4PTxSrLTIsa9GHEROSTaassgYJhisMc3CVU(9aEowqGmA7J8EqVhe6OOAr41OO8bPcmMOzlEuHslquAOO4PTxSrLTIsa9GHEROa8CSGaz02h590C)2DKo3RRFV2UhPg6T9Ity1YqIYC)(7fvTmfUjfLLaJuaed3bwcYOTpY7bf)9B1K711VhWZXccKrBFK3d697UZkQweEnkQCRgA8EifaPPlgwbMkuATRsdffpT9InQSvucOhm0BfLOQLPWnPOSeyKcGy4oWsqgT9rEpn3tND8ED97fvTmfUjfLLaJuaed3bwcYOTpY7b9EqUxx)EKAO32loHvldjkZ9663d45ybbYOTpY7b9EqOxr1IWRrrHRGldsSpeilRPhbRcLwAIsdffpT9InQSvucOhm0BfLaZtOTMVx7UxG53td(73E)(75HH5isHJYKOiOTMVNg83tFIokQweEnkQgk6HjrbH8eQqPfDuAOO4PTxSrLTIQfHxJIAzjdyzjj51YWdjZYcTZzfLa6bd9wrjQAzkCtkklbgPaigUdSeKrBFK3d69BVxx)ErvltHBsrzjWifaXWDGLGmA7J8EAUhe6Vxx)EKAO32loHvldjkZ9663d45ybbYOTpY7bf)9GqVIAAuwrTSKbSSKK8Az4HKzzH25SkuATZknuu802l2OYwr1IWRrrLVAJ3rbLeu20RLxJIsa9GHEROevTmfUjfLLaJuaed3bwcYOTpY7b9(T3RRFVOQLPWnPOSeyKcGy4oWsqgT9rEpn3dc93RRFpsn0B7fNWQLHeL5ED97b8CSGaz02h59GI)EqOxrXaaSiitJYkQ8vB8okOKGYMET8AuHsRnMsdffpT9InQSvuTi8Auu5R24DuqjHrTxmQIsa9GHEROa8CSGaz02h590C)w6Sd3RRFVOQLPWnPOSeyKcGy4oWsqgT9rEpO3V9ED97rQHEBV4ewTmKOmkkgaGfbzAuwrLVAJ3rbLeg1EXOQqP1oQ0qrXtBVyJkBfLa6bd9wrPT7rQHEBV4ewTmKOm3V)EWFV2UN3ilptg2KeieRkG14cI9QLX9663lQAzkCtsGqSQawJli2RwgjiJ2(iVhu83V9EWD)(7b)9cm)EAUF79663ZddZrCpO3Rj0Fp4uuTi8AuurzjWifaXWDGPcLw7GsdffpT9InQSvucOhm0BfLOQLPWnjzuquc3WaJ0JHa4qojWAyolVh)9GCVU(9MksrzjWifaXWDGLGmA7J8ED97b8CSGaz02h59GEpi0FVU(9G)EBlaGeUcUmiX(qGSSMEeCcYOTpY7P5(T0FVU(9IQwMc3KWvWLbj2hcKL10JGtqgT9rEpn3lQAzkCtsgfeLWnmWi9yiaoKtawRfbYcSgMZKWr5711VxB3ZsjpcoHRGldsSpeilRPhbNqBnvbVhC3V)EWFVOQLPWnPOSeyKcGy4oWsqgT9rEpn3lQAzkCtsgfeLWnmWi9yiaoKtawRfbYcSgMZKWr5711VhPg6T9Ity1YqIYC)(71298gz5zYWMKb622lFYj(awMYCp4UF)9IQwMc3KaCzijfabWcIibz02h59GI)(D4(93lW87Pb)97E)(7fvTmfUjHdZHlFYjgyNxdjJ1iWsqgT9rEpO4VF7UkQweEnkkzuquc3WaJ0JHa4qwfkT2sVsdffpT9InQSvucOhm0BffGNJfeiJ2(iVNM73sND4ED97nvKIYsGrkaIH7albz02h59663Jud92EXjSAzirzuuTi8AuurzjWifabSgI2QqP12Tknuu802l2OYwrjGEWqVvuIQwMc3KIYsGrkaIH7albz02h590CVMqN711VhPg6T9Ity1YqIYC)(7fvTmfUjb4YqskacGfercYOTpY7b9EqUxx)EaphliqgT9rEpO3VfK711VhWZXccKrBFK3tZ9BPN(73FpGNJfeiJ2(iVh073UL(73Fp4Vxu1Yu4MeGldjPaiawqejiJ2(iVh0739ED97fvTmfUjHdZHlFYjgyNxdjJ1iWsqgT9rEpO3tN711Vxu1Yu4Me0L(KtKwdbmxawcYOTpY7b9E6Cp4uuTi8Auu2RQmKcGeymHhgfHkuATfeLgkkEA7fBuzROeqpyO3kkTDVPIKOgbpbSd2qawnktSTGtcYOTpY73Fp4Vh83lQAzkCtsuJGNa2bBiaRgLtqgT9rEpO4Vxu1Yu4MuuwcmsbqmChyjiJ2(iVpR73EVU(9i1qVTxCcRwgsuM7b397Vh83RT7JEXtKWH5WLp5edSZRHKXAeyjEA7fBUxx)ErvltHBs4WC4YNCIb251qYyncSeKrBFK3dU73FVOQLPWnjOl9jNiTgcyUaSeKrBFK3V)ErvltHBsaUmKKcGaybrKGmA7J8(93BBbaKKrbrjCddmspgcGd5KPWn3RRFVPIuuwcmsbqmChyjiJ2(iVhC3RRFpGNJfeiJ2(iVh073rfvlcVgfLOgbpbSd2qawnkRcLwB3vPHIIN2EXgv2kkb0dg6TIsu1Yu4MuuwcmsbqmChyjiJ2(iVNM73L(711VhPg6T9Ity1YqIYCVU(9aEowqGmA7J8EqVhe6vuTi8Auu2RQmealicvO0ARMO0qrXtBVyJkBfLa6bd9wrjQAzkCtkklbgPaigUdSeKrBFK3tZ97s)9663Jud92EXjSAzirzUxx)EaphliqgT9rEpO3VLokQweEnkkBgkziy(KRcLwBPJsdfvlcVgf1YZXcjrtzzYr5juu802l2OYwfkT2UZknuu802l2OYwrjGEWqVvuIQwMc3KIYsGrkaIH7albz02h590C)U0FVU(9i1qVTxCcRwgsuM711VhWZXccKrBFK3d69BPxr1IWRrrb4q2EvLrfkT2UXuAOO4PTxSrLTIsa9GHEROevTmfUjfLLaJuaed3bwcYOTpY7P5(DP)ED97rQHEBV4ewTmKOm3RRFpGNJfeiJ2(iVh07bHEfvlcVgfvpcwgWEre9APcLwB3rLgkQweEnkk7oNuaKa6cWKkkEA7fBuzRcLwB3bLgkkEA7fBuzROAr41OOYucW4q60fBiIcnJv0HxdXWi5cwrjGEWqVvuIQwMc3KIYsGrkaIH7albz02h590C)U0FVU(9i1qVTxCcRwgsugf10OSIktjaJdPtxSHik0mwrhEnedJKlyvO0ce6vAOO4PTxSrLTIQfHxJIcYOvWKCl30JGjggjxWkkb0dg6TIsu1Yu4MuuwcmsbqmChyjiJ2(iVNM73L(711VhPg6T9Ity1YqIYOOMgLvuqgTcMKB5MEemXWi5cwfkTazRsdffpT9InQSvuTi8Auu5R24DuqjXUn5SIsa9GHEROevTmfUjfLLaJuaed3bwcYOTpY7P5EqO)ED97rQHEBV4ewTmKOm3RRFpGNJfeiJ2(iVh07bHEffdaWIGmnkROYxTX7OGsIDBYzvO0cequAOO4PTxSrLTIQfHxJIkVxSOxlgkj2vnkkb0dg6TIsu1Yu4MuuwcmsbqmChyjiJ2(iVNM7PdDUxx)EKAO32loHvldjkZ9663d45ybbYOTpY7b9(TGOOMgLvu59If9AXqjXUQrfkTazxLgkkEA7fBuzROAr41OOWb9aZNCIKZr5jifaXazz05DGPOeqpyO3kkrvltHBsrzjWifaXWDGLGmA7J8EAUhe6Vxx)EKAO32loHvldjkJIAAuwrHd6bMp5ejNJYtqkaIbYYOZ7atfkTartuAOO4PTxSrLTIQfHxJIQLyi1dljWMUkiruWEPOeqpyO3kkKAO32lofLHudXsYKa6dyCC)(7b)9IQwMc3KIYsGrkaIH7albz02h590CpiBVxx)EKAO32loHvldjkZ9G7(93d(7nSTfaqc20vbjIc2lIHTTaasMc3CVU(92waajzuquc3WaJ0JHa4qobz02h590C)2DVxx)EaphliqgT9rEV2DVOQLPWnPOSeyKcGy4oWsqgT9rEpO3Rj0F)(7fvTmfUjfLLaJuaed3bwcYOTpY7b9EqOZ9663d45ybbYOTpY7b9EqOZ9GtrnnkROAjgs9WscSPRcsefSxQqPfi0rPHIIN2EXgv2kQweEnkQwIHupSKaB6QGerb7LIsa9GHERO029i1qVTxCkkdPgILKjb0hW44(93d(7nSTfaqc20vbjIc2lIHTTaasMc3CVU(9G)ETDpVrwEMmSjzGUT9YNCIpGLPm3RRFF0WCosHJYKOizebzx6Vh073X7b397Vh83BQifLLaJuaed3bwcYOTpY711Vxu1Yu4MuuwcmsbqmChyjiJ2(iVpR73H7P5EaphliqgT9rEp4UF)92waajzuquc3WaJ0JHa4qozL5ED97b8CSGaz02h59GEpi05EWPOMgLvuTedPEyjb20vbjIc2lvO0cKDwPHIQfHxJIkWyI1yxwJHauqbRO4PTxSrLTkuAbYgtPHIQfHxJIkJf0bq4toXE1YqrXtBVyJkBvO0cKDuPHIIN2EXgv2kkb0dg6TIY2caijzipEGizkCZ97Vh83hnmNJu4OmjksgrqaH(7P5(DP)ED97JgMZrcJ7vGLYiI7bf)9Gq)9G7ED97JgMZrkCuMefX489GEpikQweEnkki3z8jNaSAuwQcLwGSdknuuTi8AuuaLWsYgstxm0dMyZnQIIN2EXgv2QqP1U0R0qrXtBVyJkBfLa6bd9wrXddZrCpO3Rj0ROAr41OOqz0cIGuaKLLWnedKBuPkuAT7wLgkQweEnkkONjZIj(qKzAbRO4PTxSrLTkuATliknuuTi8Auu2DoPaib0fGjvu802l2OYwfkT2DxLgkkEA7fBuzROeqpyO3kkWFpVrwEMmSjjqiwvaRXfe7vlJ73FVOQLPWnjbcXQcynUGyVAzKGmA7J8EqXFpi0Fp4Uxx)ETDpVrwEMmSjjqiwvaRXfe7vldfvlcVgfLLKjEWOsvOcfLHbARvO0qP1wLgkkEA7fBuzROQmkkjhkQweEnkkKAO32lwrHuVSyfLOQLPWnPOSeyKcGy4oWsqgT9rEFw3Vd3tZ9rdZ5ifoktIIyC(ED97129rV4jssgYJhis802l2C)(7129i1qVTxCkkdPgILKjb0hW44(93ZBKLNjdBsgOBBV8jN4dyzkZ97VpAyohPWrzsuKmIGSl93d69B3L(73FF0WCosHJYKOizebzx6VNM73X711VhWZXccKrBFK3d69B3L(73FpGNJfeiJ2(iVNM7fvTmfUjjzipEGibz02h597Vxu1Yu4MKKH84bIeKrBFK3tZ9GCVU(92waajjd5XdejRm3V)EaphliqgT9rEpn3VDRIcPgsMgLvuy1YqIYOcLwGO0qr1IWRrrjZWnKG1JHidOdgRO4PTxSrLTkuATRsdffpT9InQSvucOhm0BfLTfaqsYqE8arYkZ9663BBbaKKrbrjCddmspgcGd5KvM73FVPIuuwcmsbqmChyjiJ2(iVxx)EaphliqgT9rEpO4VFNPxr1IWRrrLPcVgvO0stuAOO4PTxSrLTIsa9GHEROeyEcT189A39cm)EAWFpi3V)EWFF0lEIKKH84bIepT9In3RRFV2U3urkklbgPaigUdSeKrBFK3dU73FVTfaqsYqE8arYu4M73Fp4VNhgMJifoktIIG2A(EqVF79663h9INijzipEGiXtBVyZ97Vxu1Yu4MKKH84bIeKrBFK3d69GCVU(9A7(Ox8ejjd5XdejEA7fBUF)9IQwMc3KIYsGrkaIH7albz02h59GE)U3V)ETDpsn0B7fNWQLHeL5ED975HH5isHJYKOiOTMVh071K73FVOQLPWnjaxgssbqaSGisqgT9rEpO3VnrN7bNIQfHxJIcYiXqjtWAiQkuArhLgkQweEnkkGMx(WezuOzuu802l2OYwfkT2zLgkkEA7fBuzROAr41OOaCzqkasGXeCyEWKWZzOIsa9GHEROeyEcT189A39cm)EAWF)U3V)EBlaGKKH84bIKPWn3V)EBlaGKK5aZNCcSZ5KPWn3V)EWFppmmhrkCuMefbT189GE)2711Vp6fprsYqE8arIN2EXM73FVOQLPWnjjd5XdejiJ2(iVh07b5ED97129rV4jssgYJhis802l2C)(7fvTmfUjfLLaJuaed3bwcYOTpY7b9(DVF)9A7EKAO32loHvldjkZ9663ZddZrKchLjrrqBnFpO3Rj3V)ErvltHBsaUmKKcGaybrKGmA7J8EqVFBIo3dofLaHyXKOH5CivATvfkT2yknuu802l2OYwr1IWRrrfEodjz6fQIsa9GHERO029Ic1Ui2qUb7(93lW8eAR571U7fy(90G)EqUF)9G)(Ox8ejjd5XdejEA7fBUxx)ETDVPIuuwcmsbqmChyjiJ2(iVxx)(weosmHhg1z590Cpi3dU73FVTfaqsYCG5tob25CYu4M73FVTfaqsYqE8arYu4M73Fp4VNhgMJifoktIIG2A(EqVF79663h9INijzipEGiXtBVyZ97Vxu1Yu4MKKH84bIeKrBFK3d69GCVU(9A7(Ox8ejjd5XdejEA7fBUF)9IQwMc3KIYsGrkaIH7albz02h59GE)U3V)ETDpsn0B7fNWQLHeL5ED975HH5isHJYKOiOTMVh071K73FVOQLPWnjaxgssbqaSGisqgT9rEpO3VnrN7bNIsGqSys0WCoKkT2QcLw7OsdffpT9InQSvucOhm0BfL2Up6fprcWLbPaibgtWH5btcpNHjEA7fBUF)9zGmsKCHjTnfEodjz6f697VpCu(EqXF)UkQweEnkkbMtW1iXQqP1oO0qrXtBVyJkBfLa6bd9wrf9INijzipEGiXtBVyJIQfHxJIs0RfPfHxdz5YqrTCzqMgLvucdrYqE8aHkuATLELgkkEA7fBuzROeqpyO3kkTDF0lEIKKH84bIepT9InkQweEnkkrVwKweEnKLldf1YLbzAuwrjmejdOcLwB3Q0qrXtBVyJkBfLa6bd9wrzBbaKKmKhpqKSYOOAr41OOe9ArAr41qwUmuulxgKPrzfLKH84bcvO0Aliknuu802l2OYwrjGEWqVvuTiCKycpmQZY7b9(DvuTi8AuuIETiTi8AilxgkQLldY0OSIsgQqP12DvAOO4PTxSrLTIsa9GHEROAr4iXeEyuNL3td(73vr1IWRrrj61I0IWRHSCzOOwUmitJYkQUyvOcfvgilku7ouAO0ARsdfvlcVgfvMk8Auu802l2OYwfkTarPHIIN2EXgv2kQkJIsYHIQfHxJIcPg6T9Ivui1llwrXBKLNjdBsceIvfWACbXE1Y4ED975nYYZKHnPLLmGLLKKxldpKmll0oNVxx)EEJS8mzytkF1gVJckj2TjNVxx)EEJS8mzytkF1gVJckjOSPxlVM711VN3ilptg2KGmAfmj3Yn9iyIHrYfSIcPgsMgLvurzi1qSKmjG(aghQqP1Uknuu802l2OYwrvzuusouuTi8Auui1qVTxSIcPEzXkQT7GIsa9GHERO029rV4jssgYJhis802l2C)(7b)9i1qVTxCkkdPgILKjb0hW44ED975nYYZKHnPwIHupSKaB6QGerb719GtrHudjtJYkkGAcsbqYu4yijdKffQDhebwpdVuHslnrPHIIN2EXgv2kQPrzfvtxsSg2scqnbPaizkCmur1IWRrr10LeRHTKautqkasMchdvHsl6O0qrXtBVyJkBfLa6bd9wrPT7JEXtKKmKhpqK4PTxS5ED97129rV4jsaUmifajWycompys45mmXtBVyJIQfHxJIsG5eBlOmuHsRDwPHIIN2EXgv2kkb0dg6TIk6fprcWLbPaibgtWH5btcpNHjEA7fBUxx)Ewk5rWjrnalxeKEmezaDaoH2AQcQOAr41OOeyobxJeRcLwBmLgkQweEnkkFqQaJjA2IhffpT9InQSvHsRDuPHIQfHxJIk3QHgVhsbqA6IHvGPO4PTxSrLTkuHIQlwPHsRTknuuTi8Auu4WC4YNCIb251qYyncmffpT9InQSvHslquAOO4PTxSrLTIsa9GHERO029zGmsKCHjTnfEodjz6f697VxG53dk(73E)(75HH5iUh07Pd9kQweEnkkEyyUtx(Kt4LRzhQcLw7Q0qrXtBVyJkBfLa6bd9wrXddZrKchLjrrqBnFpn3V9ED97xCopMgIiPzlEKe7oIfNZnmXtBVyZ97Vxu1Yu4Me0L(KtKwdbmxawcYOTpY7b9(weEnjaxgssbqaSGisIwg3N190rr1IWRrrb4YqskacGfeHkuAPjknuu802l2OYwr1IWRrrbDPp5eP1qaZfGPOeqpyO3kkWFF0lEIeomhU8jNyGDEnKmwJalXtBVyZ97Vxu1Yu4Me0L(KtKwdbmxawYyb7WR5EAUxu1Yu4MeomhU8jNyGDEnKmwJalbz02h59zDVMCp4UF)9G)ErvltHBsaUmKKcGaybrKGmA7J8EAUF3711VxG53td(7PZ9GtrjqiwmjAyohsLwBvHsl6O0qrXtBVyJkBfLa6bd9wrzBbaKGwsmFYjAQ2WeC(ysMc3OOAr41OOGwsmFYjAQ2WeC(yuHsRDwPHIIN2EXgv2kkb0dg6TIsuO2frgqhm((93d(7b)9G)EbMFpn3V79663lQAzkCtcWLHKuaealiIeKrBFK3tZ9789G7(93d(7fy(90G)E6CVU(9IQwMc3KaCzijfabWcIibz02h590Cpi3dU7b39663ZddZrKchLjrrqBnFpO4VF3711V32caiz6rWKcGiWCnLNGClI7bNIQfHxJIsMXNXNCIa2dtaZfGPcLwBmLgkkEA7fBuzROeqpyO3kkbMNqBnFV2DVaZVNg83dIIQfHxJIcYiXqjtWAiQkuATJknuu802l2OYwrjGEWqVvucmpH2A(ET7EbMFpn4VFxfvlcVgfLaZj2wqzOcLw7GsdffpT9InQSvuTi8AuuaUmifajWycompys45murjGEWqVvucmpH2A(ET7EbMFpn4VFxfLaHyXKOH5CivATvfkT2sVsdffpT9InQSvuTi8AuuHNZqsMEHQOeqpyO3kkbMNqBnFV2DVaZVNg83dY97Vh83RT7JEXtKW8Giku7kXtBVyZ9663RT7ffQDrSHCd29GtrjqiwmjAyohsLwBvHsRTBvAOO4PTxSrLTIsa9GHERO029Ic1Ui2qUbtr1IWRrrjWCcUgjwfkT2cIsdffpT9InQSvuTi8Auuale(KtKmmdpbbmxaMIsa9GHEROSTaas2fyKmWsKmfUrr5tWqOvMqrTvfkT2URsdffpT9InQSvuTi8Auu2RwawzfeWCbykkb0dg6TIsuO2frgqhm((93d(7TTaas2fyKmWsKSYCVU(9G)(Ox8ejmpiIc1Us802l2C)(7ZazKi5ctABk8CgsY0l073FVaZVh071K7b39GtrjqiwmjAyohsLwBvHsRTAIsdffpT9InQSvucOhm0BfLOqTlImGoySIQfHxJIsMXNXNCIa2dtaZfGPcvOOegIKH84bcLgkT2Q0qrXtBVyJkBfLa6bd9wrzBbaKKmKhpqKmfU5ED97b8CSGaz02h59GEpi0rr1IWRrr5dsfymrZw8OcLwGO0qrXtBVyJkBfvlcVgfvtxsSg2scqnbPaizkCmurjGEWqVvu2waajjd5XdejtHBUF)9G)ErvltHBssgYJhisqgT9rEpO3dc93RRFpGNJfeiJ2(iVh071e6VhCkQPrzfvtxsSg2scqnbPaizkCmufkT2vPHIIN2EXgv2kkb0dg6TIY2caijzipEGizkCZ97Vh83d45ybbYOTpY7P5(T7iDUxx)ErvltHBssgYJhisqgT9rEpO4VFJDp4Uxx)EaphliqgT9rEpO3VlDuuTi8Auu5wn049qkastxmScmvO0stuAOO4PTxSrLTIsa9GHEROevTmfUjjzipEGibz02h590Cpi0FVU(9aEowqGmA7J8EqVhe6vuTi8Auu2RQmealicvO0Ioknuu802l2OYwrjGEWqVvuIQwMc3KKmKhpqKGmA7J8EAUhe6Vxx)EaphliqgT9rEpO3VLokQweEnkkBgkziy(KRcLw7SsdffpT9InQSvucOhm0BfLTfaqsYqE8arYu4M73FVaZtOTMVx7UxG53td(73E)(75HH5isHJYKOiOTMVNg83tFIokQweEnkQgk6HjrbH8eQqP1gtPHIQfHxJIA55yHKOPSm5O8ekkEA7fBuzRcLw7OsdffpT9InQSvucOhm0BfLOQLPWnjjd5XdejiJ2(iVNM7bH(711VhWZXccKrBFK3d69BPxr1IWRrrb4q2EvLrfkT2bLgkkEA7fBuzROeqpyO3kkrvltHBssgYJhisqgT9rEpn3dc93RRFpGNJfeiJ2(iVh07bHEfvlcVgfvpcwgWEre9APcLwBPxPHIQfHxJIYUZjfajGUamPIIN2EXgv2QqP12Tknuu802l2OYwr1IWRrrTSKbSSKK8Az4HKzzH25SIsa9GHEROevTmfUjfLLaJuaed3bwcYOTpY7b9(T3RRFVOQLPWnPOSeyKcGy4oWsqgT9rEpn3dc93RRFpsn0B7fNWQLHeL5ED97b8CSGaz02h59GI)EqOxrnnkROwwYawwssETm8qYSSq7CwfkT2cIsdffpT9InQSvuTi8Auu5R24DuqjbLn9A51OOeqpyO3kkrvltHBsrzjWifaXWDGLGmA7J8EqVF79663lQAzkCtkklbgPaigUdSeKrBFK3tZ9Gq)9663Jud92EXjSAzirzUxx)EaphliqgT9rEpO4Vhe6vumaalcY0OSIkF1gVJckjOSPxlVgvO0A7Uknuu802l2OYwr1IWRrrLVAJ3rbLeg1EXOkkb0dg6TIcWZXccKrBFK3tZ9BPZoCVU(9IQwMc3KIYsGrkaIH7albz02h59GE)2711VhPg6T9Ity1YqIYOOyaaweKPrzfv(QnEhfusyu7fJQcLwB1eLgkkEA7fBuzROeqpyO3kkTDpsn0B7fNWQLHeLrr1IWRrrfLLaJuaed3bMkuATLoknuu802l2OYwrjGEWqVvuaEowqGmA7J8EAUFlD2H711V3urkklbgPaigUdSeKrBFK3RRFpsn0B7fNWQLHeLrr1IWRrrfLLaJuaeWAiARcLwB3zLgkkEA7fBuzROAr41OOYucW4q60fBiIcnJv0HxdXWi5cwrjGEWqVvu2waajjd5XdejtHBUF)9G)ErvltHBsrzjWifaXWDGLGmA7J8EAUFl93RRFpsn0B7fNWQLHeL5EWDVU(9aEowqGmA7J8EqVNokQPrzfvMsaghsNUydruOzSIo8AiggjxWQqP12nMsdffpT9InQSvucOhm0BfLTfaqsYqE8arYu4M73Fp4Vxu1Yu4MKKH84bIeKrBFK3tZ9Gq)9663lQAzkCtsYqE8arcYOTpY7b9EqUhC3RRFpGNJfeiJ2(iVh073shfvlcVgfL9QkdPaibgt4HrrOcLwB3rLgkkEA7fBuzROAr41OOGmAfmj3Yn9iyIHrYfSIsa9GHEROevTmfUjfLLaJuaed3bwcYOTpY7P5(T0FVU(9i1qVTxCcRwgsugf10OSIcYOvWKCl30JGjggjxWQqP12DqPHIIN2EXgv2kQweEnkQ8vB8okOKy3MCwrjGEWqVvuIQwMc3KKmKhpqKGmA7J8EAUhe6Vxx)EaphliqgT9rEpO3dc9kkgaGfbzAuwrLVAJ3rbLe72KZQqPfi0R0qrXtBVyJkBfvlcVgfvEVyrVwmusSRAuucOhm0BfLOQLPWnjjd5XdejiJ2(iVNM7bH(711VhWZXccKrBFK3d69GqVIAAuwrL3lw0RfdLe7QgvO0cKTknuu802l2OYwr1IWRrrHd6bMp5ejNJYtqkaIbYYOZ7atrjGEWqVvuIQwMc3KIYsGrkaIH7albz02h590C)w6Vxx)EKAO32loHvldjkJIAAuwrHd6bMp5ejNJYtqkaIbYYOZ7atfkTabeLgkkEA7fBuzROAr41OOAjgs9WscSPRcsefSxkkb0dg6TIYW2waajytxfKikyVig22caizkCZ9663BBbaKKmKhpqKGmA7J8EAUFhUxx)EaphliqgT9rEpO3dcDuutJYkQwIHupSKaB6QGerb7LkuAbYUknuu802l2OYwrjGEWqVvu2waajjd5XdejtHBUF)9G)ErvltHBssgYJhisqgT9rEpn3VLo3RRFVOQLPWnjjd5XdejiJ2(iVh07b5EWDVU(9aEowqGmA7J8EqVhe6vuTi8Auu4k4YGe7dbYYA6rWQqPfiAIsdffpT9InQSvucOhm0BfLTfaqsYqE8arYu4M73Fp4Vxu1Yu4MKKH84bIeKrBFK3RRFVOQLPWnjrncEcyhSHaSAuojWAyolVh)9GCp4UF)9A7EtfjrncEcyhSHaSAuMyBbNeKrBFK3V)EWFVOQLPWnjOl9jNiTgcyUaSeKrBFK3V)ErvltHBsaUmKKcGaybrKGmA7J8ED97b8CSGaz02h59GE)oEp4uuTi8AuuIAe8eWoydby1OSkuAbcDuAOOAr41OOKmKhpqOO4PTxSrLTkuAbYoR0qrXtBVyJkBfLa6bd9wrzBbaKKmKhpqKmfUrr1IWRrrfymXASlRXqakOGvHslq2yknuu802l2OYwrjGEWqVvu2waajjd5XdejtHBuuTi8AuuzSGoacFYj2RwgQqPfi7OsdffpT9InQSvucOhm0BfLTfaqsYqE8arYu4M73Fp4VpAyohPWrzsuKmIGac93tZ97s)9663hnmNJeg3RalLre3dk(7bH(7b39663hnmNJu4OmjkIX57b9EquuTi8AuuqUZ4toby1OSufkTazhuAOO4PTxSrLTIsa9GHEROSTaassgYJhisMc3OOAr41OOakHLKnKMUyOhmXMBuvO0Ax6vAOO4PTxSrLTIsa9GHEROSTaassgYJhisMc3C)(75HH5iUh071e6vuTi8AuuOmAbrqkaYYs4gIbYnQufkT2DRsdffpT9InQSvucOhm0BfLTfaqsYqE8arYu4gfvlcVgff0ZKzXeFiYmTGvHsRDbrPHIIN2EXgv2kkb0dg6TIY2caijzipEGizkCJIQfHxJIYUZjfajGUamPkuAT7Uknuu802l2OYwrjGEWqVvu2waajjd5XdejtHBUF)9G)EWFpVrwEMmSjjqiwvaRXfe7vlJ73FVOQLPWnjbcXQcynUGyVAzKGmA7J8EqXFpi0Fp4Uxx)ETDpVrwEMmSjjqiwvaRXfe7vlJ7bNIQfHxJIYsYepyuPkuHIsgknuATvPHIQfHxJIchMdx(KtmWoVgsgRrGPO4PTxSrLTkuAbIsdffpT9InQSvucOhm0Bfv0lEIKKH84bIepT9In3RRFVOQLPWnPOSeyKcGy4oWsqgT9rEpn3VZ3RRFpsn0B7fNWQLHeLrr1IWRrrb4YqskacGfeHkuATRsdffpT9InQSvuTi8Auuqx6torAneWCbykkb0dg6TIk6fprsYqE8arIN2EXM711Vxu1Yu4MuuwcmsbqmChyjiJ2(iVNM7b5ED97rQHEBV4ewTmKOmkkbcXIjrdZ5qQ0ARkuAPjknuu802l2OYwrjGEWqVvu2waajOLeZNCIMQnmbNpMKPWn3V)(weosmHhg1z590C)wfvlcVgff0sI5tort1gMGZhJkuArhLgkkEA7fBuzROeqpyO3kkbMNqBnFV2DVaZVNM73QOAr41OOGmsmuYeSgIQcLw7SsdffpT9InQSvuTi8AuuaUmifajWycompys45murjGEWqVvucm)EqVFxfLaHyXKOH5CivATvfkT2yknuu802l2OYwrjGEWqVvucm)EqXF)U3V)EEyyoI7b9E6qVIQfHxJIIhgM70Lp5eE5A2HQqP1oQ0qrXtBVyJkBfLa6bd9wrjW8eAR571U7fy(90Cp93V)(weosmHhg1z594VF79663lW8eAR571U7fy(90C)wfvlcVgfLaZj2wqzOcLw7GsdffpT9InQSvuTi8AuuHNZqsMEHQOeqpyO3kkrHAxezaDW473FVaZtOTMVx7UxG53tZ97E)(7129MksrzjWifaXWDGLGmA7J8(93BBbaKKrbrjCddmspgcGd5KPWnkkbcXIjrdZ5qQ0ARkuATLELgkQweEnkkbMtW1iXkkEA7fBuzRcLwB3Q0qrXtBVyJkBfLa6bd9wrjku7IidOdgF)(7TTaasMEemPaicmxt5ji3Iqr1IWRrrjZ4Z4tora7HjG5cWuHsRTGO0qrXtBVyJkBfvlcVgfL9QfGvwbbmxaMIsa9GHEROefQDrKb0bJVF)9G)EWFF0lEIKKH84bIepT9In3RRFVOQLPWnPOSeyKcGy4oWsqgT9rEpn3dY9663Jud92EXjSAzirzUhC3V)EWFVOQLPWnjOl9jNiTgcyUaSeKrBFK3tZ9GC)(7fvTmfUjb4YqskacGfercYOTpY7P5EqUxx)ErvltHBsqx6torAneWCbyjiJ2(iVh0739(93lQAzkCtcWLHKuaealiIeKrBFK3tZ97E)(7fy(90Cpi3RRFVOQLPWnjOl9jNiTgcyUaSeKrBFK3tZ97E)(7fvTmfUjb4YqskacGfercYOTpY7b9(DVF)9cm)EAUxtUxx)EbMFpn3tN7b39663BBbaKSlWizGLizL5EWPOeielMenmNdPsRTQqP12DvAOO4PTxSrLTIQfHxJIk8CgsY0lufLa6bd9wrjku7IidOdgF)(7fyEcT189A39cm)EAUFRIsGqSys0WCoKkT2QcLwB1eLgkkFcgcTYekQTkQweEnkkGfcFYjsgMHNGaMlatrXtBVyJkBvO0AlDuAOO4PTxSrLTIQfHxJIYE1cWkRGaMlatrjGEWqVvuIc1UiYa6GX3V)EWFVOQLPWnjaxgssbqaSGisqgT9rEpO3V797VxG53J)EqUxx)EEyyoIu4OmjkcAR57b9(T3dU73Fp4VpdKrIKlmPTPWZzijtVqVxx)EbMNqBnFV2DVaZVh07b5EWPOeielMenmNdPsRTQqfkkjd5XdeknuATvPHIIN2EXgv2kkb0dg6TIY2caijzipEGibz02h59GE)2711VVfHJet4HrDwEpn3Vvr1IWRrrb4YqskacGfeHkuAbIsdffpT9InQSvucOhm0BfLOqTlImGoy897Vh833IWrIj8WOolVNM7b5ED97Br4iXeEyuNL3tZ9BVF)9A7ErvltHBsqx6torAneWCbyjRm3dofvlcVgfLmJpJp5ebShMaMlatfkT2vPHIIN2EXgv2kQweEnkkOl9jNiTgcyUamfLa6bd9wrjku7IidOdgROeielMenmNdPsRTQqPLMO0qr5tWqOvMG4akQCHjbz02hjE6vuTi8AuuaUmKKcGaybrOO4PTxSrLTkuArhLgkkEA7fBuzROAr41OOaCzqkasGXeCyEWKWZzOIsa9GHEROey(9GE)UkkbcXIjrdZ5qQ0ARkuATZknuu802l2OYwrjGEWqVvucmpH2A(ET7EbMFpn3V9(93ZddZrKchLjrrqBnFpO3Vvr1IWRrrbzKyOKjynevfkT2yknuu802l2OYwr1IWRrrzVAbyLvqaZfGPOeqpyO3kkrHAxezaDW4711VxB3h9INiH5bruO2vIN2EXgfLaHyXKOH5CivATvfkT2rLgkQweEnkkzgFgFYjcypmbmxaMIIN2EXgv2QqfQqrHedLEnkTaHEqON(ngi7CceffUgo(Klvu0n2aBOATbxRDsBqV)EnW47D0mfmUhOG3VHfgIKb2W3d5nYYHS5EzHY33wrH2bBUxG1tolthTBq6dFpi0zd69A6AqIHbBUFdhoktIIKreKnKnKeKrBFKB47J6(nC4Omjksgrq2q2q2W3d(TAgCPJ2Jw6gBGnuT2GR1oPnO3FVgy89oAMcg3duW73WggOTwXg(EiVrwoKn3llu((2kk0oyZ9cSEYzz6ODdsF473Ub9EnDniXWGn3VHdhLjrrYicYgYgscYOTpYn89rD)goCuMefjJiiBiBiB47bpiAgCPJ2J2n4OzkyWM73y33IWR5(Lldz6Ovr1wbwbvuBWyW8LROYalaFXkkT)E6g(yW1lWy497KRbSJwT)(nGvULmUheqq(EqOhe6pApA1(73j0mlSc2CVnduq(ErHA3X92CUpY09BaHGZeY7NA0oSgIcyTUVfHxJ8(AwishTA)9Ti8AKPmqwuO2DGhy1sWoA1(7Br41itzGSOqT7il8BcuL5Ov7VVfHxJmLbYIc1UJSWVzBLJYt0HxZrR2Fp10zKyvCpSDZ92waaS5Ez0H8EBgOG89Ic1UJ7T5CFK33J5(mqw7Yur4t(9U8EtnC6Ov7VVfHxJmLbYIc1UJSWVPC6msSkiYOd5rBlcVgzkdKffQDhzHFZmv41C0Q93RPXybyY7DG7ruw3J1iX333hqFaJJ75nYYZKHn3hyDCpUEc59rDVnFVLKn3hvohym8ECEGDVg1g)OTfHxJmLbYIc1UJSWVjsn0B7fJ80Om(OmKAiwsMeqFaJdKRm4LCGms9YIXZBKLNjdBsceIvfWACbXE1YqxN3ilptg2KwwYawwssETm8qYSSq7CwxN3ilptg2KYxTX7OGsIDBYzDDEJS8mzytkF1gVJckjOSPxlVgDDEJS8mzytcYOvWKCl30JGjggjxWhTA)9BqOHEBV47dSoUhNVw3h8ADpIY6Eh4EeL194816(HzZ9rDpU2J7J6ErlJ71O24BAQ7NkUhxpX9rDVOLX9ECFh33R199GaTG8rBlcVgzw43ePg6T9IrEAugpwTmKOmixzWl5azK6LfJxu1Yu4MuuwcmsbqmChyjiJ2(iZAhOjAyohPWrzsueJZ66Al6fprsYqE8arIN2EXM9AdPg6T9Itrzi1qSKmjG(agh75nYYZKHnjd0TTx(Kt8bSmLzF0WCosHJYKOizebzx6tqgT9rc62DPFF0WCosHJYKOizebzx6tqgT9rsZoQRd45ybbYOTpsq3Ul97b8CSGaz02hjnIQwMc3KKmKhpqKGmA7JCVOQLPWnjjd5XdejiJ2(iPbeDDBlaGKKH84bIKvM9aEowqGmA7JKMTBpABr41itzGSOqT7il8BIud92EXipnkJhOMGuaKmfogsYazrHA3brG1ZWlKRm4LCGms9YIXVDhq2bWRTOx8ejjd5XdejEA7fB2dEKAO32lofLHudXsYKa6dyCORZBKLNjdBsTedPEyjb20vbjIc2lWD02IWRrMYazrHA3rw430sYepyuKNgLX30LeRHTKautqkasMchdpABr41itzGSOqT7il8BkWCITfugi7a41w0lEIKKH84bIepT9In66Al6fprcWLbPaibgtWH5btcpNHjEA7fBoABr41itzGSOqT7il8BkWCcUgjgzhaF0lEIeGldsbqcmMGdZdMeEodt802l2ORZsjpcojQby5IG0JHidOdWj0wtvWJ2weEnYugilku7oYc)M(Gubgt0SfpKaJj4W8GjHNZWJ2weEnYugilku7oYc)M5wn049qkastxmScSJ2JwT)(DcnZcRGn3ZiXqe3hokFFGX33IOG37Y7BKAF12loD02IWRrIxMHBibRhdrgqhm(Ov7VFNk57ZuHxZ9oW9umKhpqCVlV3kdY3xW7TRa7EQDc6(99yUxJAJFFd57TYG89f8(aJVpAyoh3JZxR7noFpopW85(DM(7LSOgJ8OTfHxJml8BMPcVgKDa82waajjd5XdejRm662waajzuquc3WaJ0JHa4qozLzVPIuuwcmsbqmChyjiJ2(i11b8CSGaz02hjO43z6pABr41iZc)Mqgjgkzcwdrr2bWlW8eARzTtG50GhK9Gp6fprsYqE8arIN2EXgDDTzQifLLaJuaed3bwcYOTpsWT32caijzipEGizkCZEWZddZrKchLjrrqBnd6wD9Ox8ejjd5XdejEA7fB2lQAzkCtsYqE8arcYOTpsqbrxxBrV4jssgYJhis802l2Sxu1Yu4MuuwcmsbqmChyjiJ2(ibD39AdPg6T9Ity1YqIYORZddZrKchLjrrqBndQMSxu1Yu4MeGldjPaiawqejiJ2(ibDBIoG7OTfHxJml8Bc08YhMiJcnZrR2F)ovY3t3RGUHg37a3FpIY6(gY3J6sPp533X9lULX97EVaZr((nWyU)Ejd5XdeiF)gym3FF2vStCFd57NkU3kdY3Vb0AJFpIY6E2dmgEFd57B7YkUpQ7fDM75HH5iq((cEVKH84bI7D59TDzf3h19IcLV3kdY3xW71O2437Y7B7YkUpQ7ffkFVvgKVVG3t3l6(9U8ErH6t(9wzUVhZ9ikR7X5R19IoZ98WWCe3lRAoABr41iZc)MaUmifajWycompys45mezbcXIjrdZ5qIFlYoaEbMNqBnRDcmNg87U32caijzipEGizkCZEBlaGKK5aZNCcSZ5KPWn7bppmmhrkCuMefbT1mOB11JEXtKKmKhpqK4PTxSzVOQLPWnjjd5XdejiJ2(ibfeDDTf9INijzipEGiXtBVyZErvltHBsrzjWifaXWDGLGmA7Je0D3RnKAO32loHvldjkJUopmmhrkCuMefbT1mOAYErvltHBsaUmKKcGaybrKGmA7Je0Tj6aUJwT)(DQKVxd6M37a37X94QjU3gYny3J2YGHiq((nGwB87BiFpQlL(KFFh3V4wg3dY9cmh573aATXV32ZVxu1Yu4g59nKVFQ4ERmiF)gqRn(9ikR7zpWy49nKVVTlR4(OUx0zUNhgMJa57l49sgYJhiU3L332LvCFu3lku(ERmiFFbVxJAJFVlVxuO(KFVvgKVVG3t3l6(9U8ErH6t(9wzUVhZ9ikR7X5R19IoZ98WWCe3lRAoABr41iZc)MHNZqsMEHISaHyXKOH5CiXVfzhaV2efQDrSHCd2EbMNqBnRDcmNg8GSh8rV4jssgYJhis802l2ORRntfPOSeyKcGy4oWsqgT9rQR3IWrIj8WOolPbeWT32caijzoW8jNa7CozkCZEBlaGKKH84bIKPWn7bppmmhrkCuMefbT1mOB11JEXtKKmKhpqK4PTxSzVOQLPWnjjd5XdejiJ2(ibfeDDTf9INijzipEGiXtBVyZErvltHBsrzjWifaXWDGLGmA7Je0D3RnKAO32loHvldjkJUopmmhrkCuMefbT1mOAYErvltHBsaUmKKcGaybrKGmA7Je0Tj6aUJ2weEnYSWVPaZj4AKyKDa8Al6fprcWLbPaibgtWH5btcpNHjEA7fB2NbYirYfM02u45mKKPxO7dhLbf)UhTTi8AKzHFtrVwKweEnKLldKNgLXlmejd5Xdei7a4JEXtKKmKhpqK4PTxS5OTfHxJml8Bk61I0IWRHSCzG80OmEHHizaKDa8Al6fprsYqE8arIN2EXMJwT)EnDVw3hy89umKhpqCFlcVM7xUmU3bUNIH84bI7D59cliKNyH4ERmhTTi8AKzHFtrVwKweEnKLldKNgLXlzipEGazhaVTfaqsYqE8arYkZrR2FVMUxR7dm(EknUVfHxZ9lxg37a3hymKVVH89GCFbVFXs598WOolpABr41iZc)MIETiTi8AilxgipnkJxgi7a4Br4iXeEyuNLGU7rR2FVMUxR7dm((nqTtCFlcVM7xUmU3bUpWyiFFd5739(cEpAb575HrDwE02IWRrMf(nf9ArAr41qwUmqEAugFxmYoa(weosmHhg1zjn439O9Ov7VFdicVgzAdu7e37Y79j4XWM7bk49ws(ECEGD)gmweUGSbmgIMEXns899yUxybH8ele3pmBK3h19289vMWrD6InhTTi8AKPUy84WC4YNCIb251qYyncSJ2weEnYuxCw43KhgM70Lp5eE5A2Hi7a41wgiJejxysBtHNZqsMEHUxG5GIF7EEyyocqPd9hTTi8AKPU4SWVjGldjPaiawqei7a45HH5isHJYKOiOTMPzRU(IZ5X0qejnBXJKy3rS4CUHjEA7fB2lQAzkCtc6sFYjsRHaMlalbz02hjOTi8AsaUmKKcGaybrKeTmYIohTTi8AKPU4SWVj0L(KtKwdbmxagYceIftIgMZHe)wKDa8Gp6fprchMdx(KtmWoVgsgRrGL4PTxSzVOQLPWnjOl9jNiTgcyUaSKXc2HxdnIQwMc3KWH5WLp5edSZRHKXAeyjiJ2(iZsta3EWlQAzkCtcWLHKuaealiIeKrBFK0SRUUaZPbpDa3rBlcVgzQlol8BcTKy(Kt0uTHj48XGSdG32caibTKy(Kt0uTHj48XKmfU5OTfHxJm1fNf(nLz8z8jNiG9WeWCbyi7a4ffQDrKb0bJ3dEWdEbMtZU66IQwMc3KaCzijfabWcIibz02hjn7m42dEbMtdE6ORlQAzkCtcWLHKuaealiIeKrBFK0ac4aNUopmmhrkCuMefbT1mO43vx32caiz6rWKcGiWCnLNGClcWD02IWRrM6IZc)Mqgjgkzcwdrr2bWlW8eARzTtG50GhKJ2weEnYuxCw43uG5eBlOmq2bWlW8eARzTtG50GF3J2weEnYuxCw43eWLbPaibgtWH5btcpNHilqiwmjAyohs8Br2bWlW8eARzTtG50GF3J2weEnYuxCw43m8CgsY0luKfielMenmNdj(Ti7a4fyEcT1S2jWCAWdYEWRTOx8ejmpiIc1Us802l2ORRnrHAxeBi3GbUJ2weEnYuxCw43uG5eCnsmYoaETjku7Iyd5gSJ2weEnYuxCw43eyHWNCIKHz4jiG5cWq2bWBBbaKSlWizGLizkCdY(emeALjWV9OTfHxJm1fNf(nTxTaSYkiG5cWqwGqSys0WCoK43ISdGxuO2frgqhmEp4TTaas2fyKmWsKSYORd(Ox8ejmpiIc1Us802l2SpdKrIKlmPTPWZzijtVq3lWCq1eWbUJ2weEnYuxCw43uMXNXNCIa2dtaZfGHSdGxuO2frgqhm(O9Ov7Vxtx1Yu4g5rBlcVgzsyisgaVpivGXenBXdjWycompys45mezhaVTfaqsYqE8arYu4gDDaphliqgT9rcki05OTfHxJmjmejdKf(nZTAOX7HuaKMUyyfyi7a4b8CSGaz02hjnB3r6ORRnKAO32loHvldjkZErvltHBsrzjWifaXWDGLGmA7Jeu8B1eDDaphliqgT9rc6U78rBlcVgzsyisgil8BIRGldsSpeilRPhbJSdGxu1Yu4MuuwcmsbqmChyjiJ2(iPHo7OUUOQLPWnPOSeyKcGy4oWsqgT9rcki66i1qVTxCcRwgsugDDaphliqgT9rcki0F0Q93VtL89BaOOh(EnkiKN4Eh4EeL19nKVh1LsFYVVJ7xClJ73EVMgZVVhZ94Qzdh3l6m3ZddZrCpopW85E6t05EjlQXipABr41itcdrYazHFZgk6HjrbH8ei7a4fyEcT1S2jWCAWVDppmmhrkCuMefbT1mn4PprNJ2weEnYKWqKmqw430sYepyuKNgLXVSKbSSKK8Az4HKzzH25mYoaErvltHBsrzjWifaXWDGLGmA7Je0T66IQwMc3KIYsGrkaIH7albz02hjnGqVUosn0B7fNWQLHeLrxhWZXccKrBFKGIhe6pABr41itcdrYazHFtljt8GrrMbayrqMgLXNVAJ3rbLeu20RLxdYoaErvltHBsrzjWifaXWDGLGmA7Je0T66IQwMc3KIYsGrkaIH7albz02hjnGqVUosn0B7fNWQLHeLrxhWZXccKrBFKGIhe6pABr41itcdrYazHFtljt8GrrMbayrqMgLXNVAJ3rbLeg1EXOi7a4b8CSGaz02hjnBPZoORlQAzkCtkklbgPaigUdSeKrBFKGUvxhPg6T9Ity1YqIYC02IWRrMegIKbYc)MrzjWifaXWDGHSdGxBi1qVTxCcRwgsuM9GxB8gz5zYWMKaHyvbSgxqSxTm01fvTmfUjjqiwvaRXfe7vlJeKrBFKGIFl42dEbMtZwDDEyyocq1e6b3rBlcVgzsyisgil8BkJcIs4ggyKEmeahYiJSdGxu1Yu4MKmkikHByGr6XqaCiNeynmNL4brx3urkklbgPaigUdSeKrBFK66aEowqGmA7JeuqOxxh82waajCfCzqI9Hazzn9i4eKrBFK0SLEDDrvltHBs4k4YGe7dbYYA6rWjiJ2(iPru1Yu4MKmkikHByGr6XqaCiNaSwlcKfynmNjHJY66AJLsEeCcxbxgKyFiqwwtpcoH2AQccU9Gxu1Yu4MuuwcmsbqmChyjiJ2(iPru1Yu4MKmkikHByGr6XqaCiNaSwlcKfynmNjHJY66i1qVTxCcRwgsuM9AJ3ilptg2Kmq32E5toXhWYugWTxu1Yu4MeGldjPaiawqejiJ2(ibf)oSxG50GF39IQwMc3KWH5WLp5edSZRHKXAeyjiJ2(ibf)2DpABr41itcdrYazHFZOSeyKcGawdrBKDa8aEowqGmA7JKMT0zh01nvKIYsGrkaIH7albz02hPUosn0B7fNWQLHeL5OTfHxJmjmejdKf(nTxvzifajWycpmkcKDa8IQwMc3KIYsGrkaIH7albz02hjnAcD01rQHEBV4ewTmKOm7fvTmfUjb4YqskacGfercYOTpsqbrxhWZXccKrBFKGUfeDDaphliqgT9rsZw6PFpGNJfeiJ2(ibD7w63dErvltHBsaUmKKcGaybrKGmA7Je0D11fvTmfUjHdZHlFYjgyNxdjJ1iWsqgT9rckD01fvTmfUjbDPp5eP1qaZfGLGmA7Jeu6aUJ2weEnYKWqKmqw43uuJGNa2bBiaRgLr2bWRntfjrncEcyhSHaSAuMyBbNeKrBFK7bp4fvTmfUjjQrWta7GneGvJYjiJ2(ibfVOQLPWnPOSeyKcGy4oWsqgT9rM1wDDKAO32loHvldjkd42dETf9INiHdZHlFYjgyNxdjJ1iWs802l2ORlQAzkCtchMdx(KtmWoVgsgRrGLGmA7JeC7fvTmfUjbDPp5eP1qaZfGLGmA7JCVOQLPWnjaxgssbqaSGisqgT9rU32caijJcIs4ggyKEmeahYjtHB01nvKIYsGrkaIH7albz02hj401b8CSGaz02hjO74rR2F)ovY3N9QkZ90DliI7DG71OSey3xa3VX5oW2WY7fvTmfU5ExEFoK7GH3hy9C)U0Fp4dmxEVpILLHL3JdZx89AuB87D59cliKNyH4(weosm4q((cEFbaCVOQLPWn3JdJN7ruw33q(ESAz8j)(AI6EnQnoY3xW7XHXZ9bgFF0WCoU3L332LvCFu3BC(OTfHxJmjmejdKf(nTxvziawqei7a4fvTmfUjfLLaJuaed3bwcYOTpsA2LEDDKAO32loHvldjkJUoGNJfeiJ2(ibfe6pABr41itcdrYazHFtBgkziy(KJSdGxu1Yu4MuuwcmsbqmChyjiJ2(iPzx611rQHEBV4ewTmKOm66aEowqGmA7Je0T05OTfHxJmjmejdKf(nxEowijAkltokpXrBlcVgzsyisgil8Bc4q2EvLbzhaVOQLPWnPOSeyKcGy4oWsqgT9rsZU0RRJud92EXjSAzirz01b8CSGaz02hjOBP)OTfHxJmjmejdKf(n7rWYa2lIOxlKDa8IQwMc3KIYsGrkaIH7albz02hjn7sVUosn0B7fNWQLHeLrxhWZXccKrBFKGcc9hTTi8AKjHHizGSWVPDNtkasaDbyYJ2weEnYKWqKmqw430sYepyuKNgLXNPeGXH0Pl2qefAgROdVgIHrYfmYi7a4fvTmfUjfLLaJuaed3bwcYOTpsA2LEDDKAO32loHvldjkZrBlcVgzsyisgil8BAjzIhmkYtJY4HmAfmj3Yn9iyIHrYfmYoaErvltHBsrzjWifaXWDGLGmA7JKMDPxxhPg6T9Ity1YqIYC02IWRrMegIKbYc)MwsM4bJImdaWIGmnkJpF1gVJckj2TjNr2bWlQAzkCtkklbgPaigUdSeKrBFK0ac966i1qVTxCcRwgsugDDaphliqgT9rcki0F02IWRrMegIKbYc)MwsM4bJI80Om(8EXIETyOKyx1GSdGxu1Yu4MuuwcmsbqmChyjiJ2(iPHo0rxhPg6T9Ity1YqIYORd45ybbYOTpsq3cYrBlcVgzsyisgil8BAjzIhmkYtJY4Xb9aZNCIKZr5jifaXazz05DGHSdGxu1Yu4MuuwcmsbqmChyjiJ2(iPbe611rQHEBV4ewTmKOmhTTi8AKjHHizGSWVPLKjEWOipnkJVLyi1dljWMUkiruWEHSdGhPg6T9Itrzi1qSKmjG(agh7bVOQLPWnPOSeyKcGy4oWsqgT9rsdiB11rQHEBV4ewTmKOmGBp4nSTfaqc20vbjIc2lIHTTaasMc3ORBBbaKKrbrjCddmspgcGd5eKrBFK0SDxDDaphliqgT9rQDIQwMc3KIYsGrkaIH7albz02hjOAc97fvTmfUjfLLaJuaed3bwcYOTpsqbHo66aEowqGmA7JeuqOd4oABr41itcdrYazHFtljt8GrrEAugFlXqQhwsGnDvqIOG9czhaV2qQHEBV4uugsneljtcOpGXXEWByBlaGeSPRcsefSxedBBbaKmfUrxh8AJ3ilptg2Kmq32E5toXhWYugD9OH5CKchLjrrYicYU0NGmA7Je0DeC7bVPIuuwcmsbqmChyjiJ2(i11fvTmfUjfLLaJuaed3bwcYOTpYS2bAa8CSGaz02hj42BBbaKKrbrjCddmspgcGd5KvgDDaphliqgT9rcki0bChTTi8AKjHHizGSWVzGXeRXUSgdbOGc(OTfHxJmjmejdKf(nZybDae(KtSxTmoA1(73GvlZ9BOCNXN87P7RgLL3duW7znZcRGVh2toFFbVhmFTU32caqI89oW9zkP0TxC6(nWcxJqEFarCFu3NZX9bgF)QWXY4ErvltHBU3ULS5(AUVrQ9vBV475HrDwMoABr41itcdrYazHFti3z8jNaSAuwISdG32caijzipEGizkCZEWhnmNJu4OmjksgrqaHEA2LED9OH5CKW4EfyPmIau8Gqp401JgMZrkCuMefX4mOGC02IWRrMegIKbYc)MaLWsYgstxm0dMyZn6rBlcVgzsyisgil8BIYOfebPaillHBigi3OsKDa88WWCeGQj0F02IWRrMegIKbYc)MqptMft8HiZ0c(OTfHxJmjmejdKf(nT7CsbqcOlatE02IWRrMegIKbYc)MwsM4bJkr2bWdEEJS8mzytsGqSQawJli2Rwg7fvTmfUjjqiwvaRXfe7vlJeKrBFKGIhe6bNUU24nYYZKHnjbcXQcynUGyVAzC0E0Q93RPRAzkCJ8OTfHxJmjmejd5Xde49bPcmMOzlEibgtWH5btcpNHi7a4TTaassgYJhisMc3ORd45ybbYOTpsqbHohTTi8AKjHHizipEGil8BAjzIhmkYtJY4B6sI1WwsaQjifajtHJHi7a4TTaassgYJhisMc3Sh8IQwMc3KKmKhpqKGmA7JeuqOxxhWZXccKrBFKGQj0dUJ2weEnYKWqKmKhpqKf(nZTAOX7HuaKMUyyfyi7a4TTaassgYJhisMc3Sh8aEowqGmA7JKMT7iD01fvTmfUjjzipEGibz02hjO43yGtxhWZXccKrBFKGUlDoABr41itcdrYqE8arw430EvLHaybrGSdGxu1Yu4MKKH84bIeKrBFK0ac966aEowqGmA7JeuqO)OTfHxJmjmejd5XdezHFtBgkziy(KJSdGxu1Yu4MKKH84bIeKrBFK0ac966aEowqGmA7Je0T05Ov7VFNk573aqrp89AuqipX9oW9umKhpqCVlVFQ4ERmiFFpM7ruw33q(Euxk9j)(oUFXTmUF79AAmh577XCpUA2WX9IoZ98WWCe3JZdmFUN(eDUxYIAmYJ2weEnYKWqKmKhpqKf(nBOOhMefeYtGSdG32caijzipEGizkCZEbMNqBnRDcmNg8B3ZddZrKchLjrrqBntdE6t05OTfHxJmjmejd5XdezHFZLNJfsIMYYKJYtC02IWRrMegIKH84bISWVjGdz7vvgKDa8IQwMc3KKmKhpqKGmA7JKgqOxxhWZXccKrBFKGUL(J2weEnYKWqKmKhpqKf(n7rWYa2lIOxlKDa8IQwMc3KKmKhpqKGmA7JKgqOxxhWZXccKrBFKGcc9hTTi8AKjHHizipEGil8BA35KcGeqxaM8OTfHxJmjmejd5XdezHFtljt8GrrEAug)YsgWYssYRLHhsMLfANZi7a4fvTmfUjfLLaJuaed3bwcYOTpsq3QRlQAzkCtkklbgPaigUdSeKrBFK0ac966i1qVTxCcRwgsugDDaphliqgT9rckEqO)OTfHxJmjmejd5XdezHFtljt8GrrMbayrqMgLXNVAJ3rbLeu20RLxdYoaErvltHBsrzjWifaXWDGLGmA7Je0T66IQwMc3KIYsGrkaIH7albz02hjnGqVUosn0B7fNWQLHeLrxhWZXccKrBFKGIhe6pABr41itcdrYqE8arw430sYepyuKzaaweKPrz85R24DuqjHrTxmkYoaEaphliqgT9rsZw6Sd66IQwMc3KIYsGrkaIH7albz02hjOB11rQHEBV4ewTmKOmhTTi8AKjHHizipEGil8BgLLaJuaed3bgYoaETHud92EXjSAzirzoABr41itcdrYqE8arw43mklbgPaiG1q0gzhapGNJfeiJ2(iPzlD2bDDtfPOSeyKcGy4oWsqgT9rQRJud92EXjSAzirzoABr41itcdrYqE8arw430sYepyuKNgLXNPeGXH0Pl2qefAgROdVgIHrYfmYoaEBlaGKKH84bIKPWn7bVOQLPWnPOSeyKcGy4oWsqgT9rsZw611rQHEBV4ewTmKOmGtxhWZXccKrBFKGsNJ2weEnYKWqKmKhpqKf(nTxvzifajWycpmkcKDa82waajjd5XdejtHB2dErvltHBssgYJhisqgT9rsdi0RRlQAzkCtsYqE8arcYOTpsqbbC66aEowqGmA7Je0T05OTfHxJmjmejd5XdezHFtljt8GrrEAugpKrRGj5wUPhbtmmsUGr2bWlQAzkCtkklbgPaigUdSeKrBFK0SLEDDKAO32loHvldjkZrBlcVgzsyisgYJhiYc)MwsM4bJImdaWIGmnkJpF1gVJckj2TjNr2bWlQAzkCtsYqE8arcYOTpsAaHEDDaphliqgT9rcki0F02IWRrMegIKH84bISWVPLKjEWOipnkJpVxSOxlgkj2vni7a4fvTmfUjjzipEGibz02hjnGqVUoGNJfeiJ2(ibfe6pABr41itcdrYqE8arw430sYepyuKNgLXJd6bMp5ejNJYtqkaIbYYOZ7adzhaVOQLPWnPOSeyKcGy4oWsqgT9rsZw611rQHEBV4ewTmKOmhTTi8AKjHHizipEGil8BAjzIhmkYtJY4Bjgs9WscSPRcsefSxi7a4nSTfaqc20vbjIc2lIHTTaasMc3ORBBbaKKmKhpqKGmA7JKMDqxhWZXccKrBFKGccDoABr41itcdrYqE8arw43exbxgKyFiqwwtpcgzhaVTfaqsYqE8arYu4M9Gxu1Yu4MKKH84bIeKrBFK0SLo66IQwMc3KKmKhpqKGmA7JeuqaNUoGNJfeiJ2(ibfe6pABr41itcdrYqE8arw43uuJGNa2bBiaRgLr2bWBBbaKKmKhpqKmfUzp4fvTmfUjjzipEGibz02hPUUOQLPWnjrncEcyhSHaSAuojWAyolXdc42RntfjrncEcyhSHaSAuMyBbNeKrBFK7bVOQLPWnjOl9jNiTgcyUaSeKrBFK7fvTmfUjb4YqskacGfercYOTpsDDaphliqgT9rc6ocUJ2weEnYKWqKmKhpqKf(nLmKhpqC02IWRrMegIKH84bISWVzGXeRXUSgdbOGcgzhaVTfaqsYqE8arYu4MJ2weEnYKWqKmKhpqKf(nZybDae(KtSxTmq2bWBBbaKKmKhpqKmfU5OTfHxJmjmejd5XdezHFti3z8jNaSAuwISdG32caijzipEGizkCZEWhnmNJu4OmjksgrqaHEA2LED9OH5CKW4EfyPmIau8Gqp401JgMZrkCuMefX4mOGC02IWRrMegIKH84bISWVjqjSKSH00fd9Gj2CJISdG32caijzipEGizkCZrBlcVgzsyisgYJhiYc)MOmAbrqkaYYs4gIbYnQezhaVTfaqsYqE8arYu4M98WWCeGQj0F02IWRrMegIKH84bISWVj0ZKzXeFiYmTGr2bWBBbaKKmKhpqKmfU5OTfHxJmjmejd5XdezHFt7oNuaKa6cWKi7a4TTaassgYJhisMc3C02IWRrMegIKH84bISWVPLKjEWOsKDa82waajjd5XdejtHB2dEWZBKLNjdBsceIvfWACbXE1YyVOQLPWnjbcXQcynUGyVAzKGmA7Jeu8Gqp4011gVrwEMmSjjqiwvaRXfe7vldWD0E0Q93t3e6f0de3JdZx89sgYJhiU3L3BL5OTfHxJmjzipEGapGldjPaiawqei7a4TTaassgYJhisqgT9rc6wD9weosmHhg1zjnBpABr41itsgYJhiYc)MYm(m(KteWEycyUamKDa8Ic1UiYa6GX7bFlchjMWdJ6SKgq01Br4iXeEyuNL0SDV2evTmfUjbDPp5eP1qaZfGLSYaUJ2weEnYKKH84bISWVj0L(KtKwdbmxagYceIftIgMZHe)wKDa8Ic1UiYa6GXhTA)9AG5Y7X5R19Iwg3t3l6(99yU3NGHqRmX9bgFVaRNHx37a3hy897K00B87D59qUniUVhZ9YcLdmFYVhZZXy491CFGX3Nb6f0de3VCzCp43qPOBb39U8(gP2xT9IthTTi8AKjjd5XdezHFtaxgssbqaSGiq2NGHqRmbXbWNlmjiJ2(iXt)rBlcVgzsYqE8arw43eWLbPaibgtWH5btcpNHilqiwmjAyohs8Br2bWlWCq39OTfHxJmjzipEGil8BczKyOKjynefzhaVaZtOTM1obMtZ298WWCePWrzsue0wZGU9Ov7VFNk57ZUOBr(EpUhNVw3xZcX92qUb7E0wgmeX9oW9BW84EnDHAx37Y71AdIACF0lEc2C02IWRrMKmKhpqKf(nTxTaSYkiG5cWqwGqSys0WCoK43ISdGxuO2frgqhmwxxBrV4jsyEqefQDL4PTxS5OTfHxJmjzipEGil8BkZ4Z4tora7HjG5cWoApABr41itYapomhU8jNyGDEnKmwJa7OTfHxJmjJSWVjGldjPaiawqei7a4JEXtKKmKhpqK4PTxSrxxu1Yu4MuuwcmsbqmChyjiJ2(iPzN11rQHEBV4ewTmKOmhTA)97ujF)gkfD791CF0WCoK3JZdSYkUFNCdb7(c4(aJVxtd7HV3W2waaiFVdCFMskD7fJ899yU3bUxJAJFVlVVJ7xClJ7b5EjlQXiVVX1ioABr41itYil8BcDPp5eP1qaZfGHSaHyXKOH5CiXVfzhaF0lEIKKH84bIepT9In66IQwMc3KIYsGrkaIH7albz02hjnGORJud92EXjSAzirzoABr41itYil8BcTKy(Kt0uTHj48XGSdG32caibTKy(Kt0uTHj48XKmfUzFlchjMWdJ6SKMThTTi8AKjzKf(nHmsmuYeSgIISdGxG5j0wZANaZPz7rBlcVgzsgzHFtaxgKcGeymbhMhmj8CgISaHyXKOH5CiXVfzhaVaZbD3J2weEnYKmYc)M8WWCNU8jNWlxZoezhaVaZbf)U75HH5iaLo0F0Q93VtL89A6SV3bUhrzDFd57rliFFG1Z90FVMgZVVX1iUhawO3J2A((Em3J1iX3V9EEyueiFFbVVH89OfKVpW65(T3RPX87BCnI7bGf69OTMpABr41itYil8BkWCITfugi7a4fyEcT1S2jWCAOFFlchjMWdJ6Se)wDDbMNqBnRDcmNMThTA)97ujFVg0nV3bUhrzDFd571K7l49OfKVxG5334Ae3dal07rBnFFpM71O2433J5EQDc6(9nKV3UcS7NkU3kZrBlcVgzsgzHFZWZzijtVqrwGqSys0WCoK43ISdGxuO2frgqhmEVaZtOTM1obMtZU71MPIuuwcmsbqmChyjiJ2(i3BBbaKKrbrjCddmspgcGd5KPWnhTTi8AKjzKf(nfyobxJeF02IWRrMKrw43uMXNXNCIa2dtaZfGHSdGxuO2frgqhmEVTfaqY0JGjfarG5Akpb5wehTA)97ujFF2fD79oW92vGDpDVO733J5(nuk627BiF)uX9IvjzKVVG3VHsr3EVlVxSkjFFpM7P7fD)ExE)uX9Ivj577XCpIY6ESgj(E0cY3hy9Cpi3lWCKVVG3t3l6(9U8EXQK89BOu0T37Y7NkUxSkjFFpM7ruw3J1iX3Jwq((aRN739EbMJ89f8EeL19yns89OfKVpW65E6CVaZr((cEVdCpIY6(CoUVVpdSehTTi8AKjzKf(nTxTaSYkiG5cWqwGqSys0WCoK43ISdGxuO2frgqhmEp4bF0lEIKKH84bIepT9In66IQwMc3KIYsGrkaIH7albz02hjnGORJud92EXjSAzirza3EWlQAzkCtc6sFYjsRHaMlalbz02hjnGSxu1Yu4MeGldjPaiawqejiJ2(iPbeDDrvltHBsqx6torAneWCbyjiJ2(ibD39IQwMc3KaCzijfabWcIibz02hjn7UxG50aIUUOQLPWnjOl9jNiTgcyUaSeKrBFK0S7ErvltHBsaUmKKcGaybrKGmA7Je0D3lWCA0eDDbMtdDaNUUTfaqYUaJKbwIKvgWD02IWRrMKrw43m8CgsY0luKfielMenmNdj(Ti7a4ffQDrKb0bJ3lW8eARzTtG50S9Ov7VFNk57P7u0T33J5EFcgcTYe37X9Ya2EowCFJRrC02IWRrMKrw43eyHWNCIKHz4jiG5cWq2NGHqRmb(ThTA)97ujFF2fD79oW909IUFVlVxSkjFFpM7ruw3J1iX3dY9cm)(Em3JOSG3VAzCF(QS7194A59Aq3e57l49oW9ikR7BiFFBxwX9rDVOZCppmmhX99yUN9aJH3JOSG3VAzCFUWCpUwEVg0nVVG37a3JOSUVH89lwkVpW65EqUxG5334Ae3dal07fDMm(KF02IWRrMKrw430E1cWkRGaMladzbcXIjrdZ5qIFlYoaErHAxezaDW49Gxu1Yu4MeGldjPaiawqejiJ2(ibD39cmhpi668WWCePWrzsue0wZGUfC7bFgiJejxysBtHNZqsMEHQRlW8eARzTtG5Gcc4uHkuka]] )

end