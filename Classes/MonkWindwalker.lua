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
        rushing_jade_wind = 23122, -- 261715
        invoke_xuen = 22102, -- 123904

        spiritual_focus = 22107, -- 280197
        whirling_dragon_punch = 22105, -- 152175
        serenity = 21191, -- 152173
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3572, -- 214027
        relentless = 3573, -- 196029
        gladiators_medallion = 3574, -- 208683

        disabling_reach = 3050, -- 201769
        grapple_weapon = 3052, -- 233759
        tigereye_brew = 675, -- 247483
        turbo_fists = 3745, -- 287681
        pressure_points = 3744, -- 287599
        reverse_harm = 852, -- 287771
        wind_waker = 3737, -- 287506
        alpha_tiger = 3734, -- 287503
        ride_the_wind = 77, -- 201372
        fortifying_brew = 73, -- 201318
    } )

    -- Auras
    spec:RegisterAuras( {
        bok_proc = {
            id = 116768,
            duration = 15,
        },
        chi_torpedo = {
            id = 119085,
            duration = 10,
            max_stack = 2,
        },
        dampen_harm = {
            id = 122278,
            duration = 10
        },
        diffuse_magic = {
            id = 122783,
            duration = 6
        },
        disable = {
            id = 116095,
            duration = 15,
        },
        disable_root = {
            id = 116706,
            duration = 8,
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
        leg_sweep = {
            id = 119381,
            duration = 3,
        },
        mark_of_the_crane = {
            id = 228287,
            duration = 15,
        },
        mystic_touch = {
            id = 113746,
            duration = 60,
        },
        paralysis = {
            id = 115078,
            duration = 15,
        },
        power_strikes = {
            id = 129914,
            duration = 3600,
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
            duration = function () return 9 * haste end,
            max_stack = 1,
            dot = "buff",
        },
        serenity = {
            id = 152173,
            duration = 12,
        },
        spinning_crane_kick = {
            id = 101546,
            duration = function () return 1.5 * haste end,
        },
        storm_earth_and_fire = {
            id = 137639,
            duration = 15,
        },
        the_emperors_capacitor = {
            id = 235054,
            duration = 3600,
            max_stack = 20,
        },
        tigers_lust = {
            id = 116841,
            duration = 6,
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
        whirling_dragon_punch = {
            id = 152175,
            duration = 1,
        },
        windwalking = {
            id = 157411,
            duration = 3600,
            max_stack = 1,
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

    --[[ spec:RegisterEvent( "UNIT_POWER_UPDATE", function( event, unit, power )
        if unit == "player" and power == "CHI" then
            tp_chi_pending = false
        end
    end ) ]]


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

        if level < 116 then
            if equipped.the_emperors_capacitor and resource == 'chi' then
                addStack( "the_emperors_capacitor", 30, 1 )
            end
        end
    end )

    local reverse_harm_target

    spec:RegisterHook( "reset_precast", function ()
        chiSpent = 0

        if actual_combo == "tiger_palm" and chi.current < 2 and now - action.tiger_palm.lastCast > 0.2 then
            actual_combo = "none"
        end

        --[[ if tp_chi_pending then
            if Hekili.ActiveDebug then Hekili:Debug( "Generating 2 additional Chi as Tiger Palm was cast but Chi did not appear to be gained yet." ) end
            gain( 2, "chi" )
        end ]]

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
            charges = 2,
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

            spend = 20,
            spendPerSec = 20,
            spendType = "energy",

            startsCombat = true,
            texture = 606542,

            start = function ()
                applyDebuff( "target", "crackling_jade_lightning" )
                removeBuff( "the_emperors_capacitor" )   
            end,
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

            toggle = "cooldowns",

            startsCombat = true,
            texture = 775460,

            handler = function ()
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
                gain( energy.max, "energy" )
                gain( 2, "chi" )
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
                if level < 116 and equipped.katsuos_eclipse then return 2 end
                return 3
            end,
            spendType = "chi",

            startsCombat = true,
            texture = 627606,

            cycle = "mark_of_the_crane",
            aura = "mark_of_the_crane",

            start = function ()
                if level < 116 and set_bonus.tier20_4pc == 1 then applyBuff( "pressure_point", 5 + action.fists_of_fury.cast ) end
                if buff.fury_of_xuen.stack >= 50 then
                    applyBuff( "fury_of_xuen_haste" )
                    summonPet( "xuen", 8 )
                    removeBuff( "fury_of_xuen" )
                end
                if pvptalent.turbo_fists.enabled then
                    applyDebuff( "target", "heavyhanded_strikes", action.fists_of_fury.cast_time + 2 )
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

                if azerite.sunrise_technique.enabled then applyDebuff( "target", "sunrise_technique" ) end
            end,
        },


        roll = {
            id = 109132,
            cast = 0,
            charges = function () return talent.celerity.enabled and 2 or nil end,
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

                applyDebuff( "target", "mark_of_the_crane" )

                gain( buff.power_strikes.up and 3 or 2, "chi" )
                removeBuff( "power_strikes" )
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
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 606552,

            cycle = "touch_of_death",

            handler = function ()
                if level < 116 and equipped.hidden_masters_forbidden_touch and buff.hidden_masters_forbidden_touch.down then
                    applyBuff( "hidden_masters_forbidden_touch" )
                end
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

            usable = function () return ( index > 1 or IsUsableSpell( 152175 ) ) and cooldown.fists_of_fury.remains > 0 and cooldown.rising_sun_kick.remains > 0 end,

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
    
    spec:RegisterPack( "Windwalker", 20200802, [[d4ejscqivcEeujTjvQ(KkLWOakDkGIxPs0SGKUfuPAxI8lsvggPWXujTmG4zQumnKQQRHuLTHuv8nvkrJtLs5CQusRJuPI5bKUhu1(qQCqsLslKuvpeQeMOkH4IKkvzJqLOpQsPsgjPsL6KQuQyLqfVePQuZKuPs6MQuQu7KuXpjvQenuvkv1srQk5PizQKIUQkH0wjvQe(QkLQmwsLQAVK8xedwvhwQflkpMWKP4YO2mGplQgnuonvRMuP41qIzRIBdXUv63sgoP0Xvjulh0ZjA6cxNs2oq13rkJNujNhsTEOsz(uQ9Ry1vLMkkthSshq0aen0420aKeixPNgGqpfvGwlRO02cu6CwrTncROU981qRpOWqfL2g9PAJstfLSSGcwrHfHwPUJE6L7bMvwsui6jDeRthETcyde6jDeHEkQml)e3oRktrz6Gv6aIgGOHg3MgGKa5k90aequusTSqPdi0NBvrH5gdVQmfLHLcffUo)TNVgA9bfgo)T7ArzWbxNhlcTsDh90l3dmRSKOq0t6iwNo8AfWgi0t6ic9gCW151Tw5wYyEqqDEq0aengCgCW15Xfy9MZsDNbhCDECFE6lgPaNNNsl3W51D3RzEQa6OWZlQ1eETY5blwVMdBMpd98TXulysdo4684(84cSEZ55JgMZbXbMpQ5fOfhMenmNdzAWbxNh3NN(IrkW555LH5ONx0ANxGXcuMhOGZJlDziNVaMhxAbrppyLoY8ghaGH8k45D58lNF8Cp7WOoFMvmV2tJEEJdaWqEf88UCEPNVoGl6natAWbxNh3Nx3AmSz(lQKN)2jye58GnG(IchsuNNdrcmjf1XLHuPPIsyisgqPPsNRknvu82zh2O0xrjGEWqVvuzwaajjd51d0jtrBN32EEaphliqgP9vopOZdc9uuTi8Avu(cEHct0LfVQqPdiknvu82zh2O0xrjGEWqVvuaEowqGms7RCE6M)6TrV5TTN)cZdEd9o7WjS6yirzM)(8IQoMI2MIYsGrkaIH7albzK2x58GIF(R0)822Zd45ybbYiTVY5bD(BOpkQweETkQCRgA8EjfaPXngwbMku6CJstffVD2Hnk9vucOhm0BfLOQJPOTPOSeyKcGy4oWsqgP9vopDZtVBBEB75fvDmfTnfLLaJuaed3bwcYiTVY5bDEqM32EEWBO3zhoHvhdjkZ822Zd45ybbYiTVY5bDEq0qr1IWRvrrRGhd4SVeilRTxbRcLo0VstffVD2Hnk9vucOhm0BfLaZtiTUMh3NxG5Zth(5Vo)955LH5OtHJWKOiiTUMNo8ZRrIEkQweETkQgk6LjrbH8gQqPd9uAQO4TZoSrPVIQfHxRI6yjdyzjj51XWlr7XcPZzfLa6bd9wrjQ6ykABkklbgPaigUdSeKrAFLZd68xN32EErvhtrBtrzjWifaXWDGLGms7RCE6MhenM32EEWBO3zhoHvhdjkZ822Zd45ybbYiTVY5bf)8GOHIABewrDSKbSSKK86y4LO9yH05Sku6qFuAQO4TZoSrPVIQfHxRIk)0gVJckjiSPphVwfLa6bd9wrjQ6ykABkklbgPaigUdSeKrAFLZd68xN32EErvhtrBtrzjWifaXWDGLGms7RCE6MhenM32EEWBO3zhoHvhdjkZ822Zd45ybbYiTVY5bf)8GOHIIbayrq2gHvu5N24DuqjbHn9541QcLo3sLMkkE7SdBu6ROAr41QOYpTX7OGscJKDyefLa6bd9wrb45ybbYiTVY5PB(R07wN32EErvhtrBtrzjWifaXWDGLGms7RCEqN)6822ZdEd9o7WjS6yirzuumaalcY2iSIk)0gVJckjms2HruHsNBtPPII3o7WgL(kkb0dg6TI6cZdEd9o7WjS6yirzM)(8GD(lmpFXwUwTSjjqlovaR1fKStlJ5TTNxu1Xu02KaT4ubSwxqYoTmsqgP9vopO4N)68Gz(7Zd25fy(80n)15TTNNxgMJEEqNN(1yEWOOAr41QOIYsGrkaIH7atfkDUvLMkkE7SdBu6ROeqpyO3kkrvhtrBtYOGieUHbgPxdbWHCsG1WCwop(5bzEB75nvKIYsGrkaIH7albzK2x5822Zd45ybbYiTVY5bDEq0yEB75b78zwaajAf8yaN9LazzT9k4eKrAFLZt38x1yEB75fvDmfTnrRGhd4SVeilRTxbNGms7RCE6Mxu1Xu02KmkicHByGr61qaCiNaSohcKfynmNjHJWZBBp)fMNLsEfCIwbpgWzFjqwwBVcoH06McopyM)(8GDErvhtrBtrzjWifaXWDGLGms7RCE6Mxu1Xu02KmkicHByGr61qaCiNaSohcKfynmNjHJWZBBpp4n07SdNWQJHeLz(7ZFH55l2Y1QLnjd0ZYo(Mt8ffTLzEWm)95fvDmfTnb4YqskacGfeDcYiTVY5bf)83683NxG5Zth(5Vz(7ZlQ6ykABIgMdp(MtmWoVwIwRvGLGms7RCEqXp)1BuuTi8AvuYOGieUHbgPxdbWHSku6CvdLMkkE7SdBu6ROeqpyO3kkaphliqgP9vopDZFLE36822ZBQifLLaJuaed3bwcYiTVY5TTNh8g6D2Hty1XqIYOOAr41QOIYsGrkacknePvHsNRxvAQO4TZoSrPVIsa9GHEROevDmfTnfLLaJuaed3bwcYiTVY5PBE6NEZBBpp4n07SdNWQJHeLz(7ZlQ6ykABcWLHKuaeali6eKrAFLZd68GmVT98aEowqGms7RCEqN)kiZBBppGNJfeiJ0(kNNU5VQHgZFFEaphliqgP9vopOZF9QgZFFEWoVOQJPOTjaxgssbqaSGOtqgP9vopOZFZ822ZlQ6ykABIgMdp(MtmWoVwIwRvGLGms7RCEqNNEZBBpVOQJPOTjOl9nNiTwckUaLeKrAFLZd680BEWOOAr41QOYovzifajWycVmcAvO05kiknvu82zh2O0xrjGEWqVvuxyEtfjrTcEdyhSHaCAeMKzb3eKrAFLZFFEWopyNxu1Xu02KOwbVbSd2qaoncNGms7RCEqXpVOQJPOTPOSeyKcGy4oWsqgP9vo)LZFDEB75bVHEND4ewDmKOmZdM5VppyN)cZh9H3irdZHhFZjgyNxlrR1kWs82zh2mVT98IQoMI2MOH5WJV5edSZRLO1AfyjiJ0(kNhmZFFErvhtrBtqx6BorATeuCbkjiJ0(kN)(8IQoMI2MaCzijfabWcIobzK2x583NpZcaijJcIq4ggyKEneahYjtrBN32EEtfPOSeyKcGy4oWsqgP9vopyM32EEaphliqgP9vopOZFBkQweETkkrTcEdyhSHaCAewfkDUEJstffVD2Hnk9vucOhm0BfLOQJPOTPOSeyKcGy4oWsqgP9vopDZFJgZBBpp4n07SdNWQJHeLzEB75b8CSGazK2x58GopiAOOAr41QOYovziawq0QqPZv6xPPII3o7WgL(kkb0dg6TIsu1Xu02uuwcmsbqmChyjiJ0(kNNU5VrJ5TTNh8g6D2Hty1XqIYmVT98aEowqGms7RCEqN)k9uuTi8AvuzmuYqu8nxfkDUspLMkQweETkQJNJfsIUXYKJWBOO4TZoSrPVku6CL(O0urXBNDyJsFfLa6bd9wrjQ6ykABkklbgPaigUdSeKrAFLZt383OX822ZdEd9o7WjS6yirzM32EEaphliqgP9vopOZFvdfvlcVwffGd5StvgvO056TuPPII3o7WgL(kkb0dg6TIsu1Xu02uuwcmsbqmChyjiJ0(kNNU5VrJ5TTNh8g6D2Hty1XqIYmVT98aEowqGms7RCEqNhenuuTi8Avu9kyza7dr0NJku6C92uAQOAr41QOY6CsbqcOlqrQO4TZoSrPVku6C9wvAQO4TZoSrPVIQfHxRIsBjqHdPJBSHikeTwrhETeddUlyfLa6bd9wrjQ6ykABkklbgPaigUdSeKrAFLZt383OX822ZdEd9o7WjS6yirzuuBJWkkTLafoKoUXgIOq0AfD41smm4UGvHshq0qPPII3o7WgL(kQweETkkiJubtYTCtVcMyyWDbROeqpyO3kkrvhtrBtrzjWifaXWDGLGms7RCE6M)gnM32EEWBO3zhoHvhdjkJIABewrbzKkysULB6vWeddUlyvO0bKRknvu82zh2O0xr1IWRvrLFAJ3rbLKS2KZkkb0dg6TIsu1Xu02uuwcmsbqmChyjiJ0(kNNU5brJ5TTNh8g6D2Hty1XqIYmVT98aEowqGms7RCEqNhenuumaalcY2iSIk)0gVJckjzTjNvHshqarPPII3o7WgL(kQweETkQ8(WI(CyOKKv1QOeqpyO3kkrvhtrBtrzjWifaXWDGLGms7RCE6MNE0BEB75bVHEND4ewDmKOmZBBppGNJfeiJ0(kNh05VcIIABewrL3hw0NddLKSQwvO0bKBuAQO4TZoSrPVIQfHxRIIg0dmFZjsohH3GuaedKLrN3bMIsa9GHEROevDmfTnfLLaJuaed3bwcYiTVY5PBEq0yEB75bVHEND4ewDmKOmkQTryffnOhy(MtKCocVbPaigilJoVdmvO0be6xPPII3o7WgL(kQweETkQwIbEVSKaBCRGerb7JIsa9GHEROaVHEND4uugsTeljtcOVOWX83NhSZlQ6ykABkklbgPaigUdSeKrAFLZt38GCDEB75bVHEND4ewDmKOmZdM5VppyN3WzwaajyJBfKikyFigoZcaizkA7822ZNzbaKKrbriCddmsVgcGd5eKrAFLZt38xVzEB75b8CSGazK2x584(8IQoMI2MIYsGrkaIH7albzK2x58Gop9RX83Nxu1Xu02uuwcmsbqmChyjiJ0(kNh05bHEZBBppGNJfeiJ0(kNh05bHEZdgf12iSIQLyG3lljWg3kiruW(OcLoGqpLMkkE7SdBu6ROAr41QOAjg49YscSXTcsefSpkkb0dg6TI6cZdEd9o7WPOmKAjwsMeqFrHJ5VppyN3WzwaajyJBfKikyFigoZcaizkA7822Zd25VW88fB5A1YMKb6zzhFZj(II2YmVT98rdZ5ifoctIIOveKB0yEqN)2MhmZFFEWoVPIuuwcmsbqmChyjiJ0(kN32EErvhtrBtrzjWifaXWDGLGms7RC(lN)wNNU5b8CSGazK2x58Gz(7ZNzbaKKrbriCddmsVgcGd5KL25TTNhWZXccKrAFLZd68GqV5bJIABewr1smW7LLeyJBfKikyFuHshqOpknvuTi8AvubgtS2SYAneGckyffVD2Hnk9vHshqULknvuTi8AvuATGoaAFZjzNwgkkE7SdBu6RcLoGCBknvu82zh2O0xrjGEWqVvurdZ5ifoctIIOveeq0yE6M)gnM32E(OH5CKW4(eyjTIyEqXppiAOOAr41QOGCR13CcWPryPku6aYTQ0ur1IWRvrbucljBinUXqpysg3ikkE7SdBu6RcLo3OHstffVD2Hnk9vucOhm0BffVmmh98Gop9RHIQfHxRIcHrkiAsbqowc3qmqUrKQqPZnxvAQOAr41QOGUwThM4lrQTfSII3o7WgL(QqPZnGO0ur1IWRvrL15KcGeqxGIurXBNDyJsFvO05MBuAQO4TZoSrPVIsa9GHEROa788fB5A1YMKaT4ubSwxqYoTmM)(8IQoMI2MeOfNkG16cs2PLrcYiTVY5bf)8GOX8GzEB75VW88fB5A1YMKaT4ubSwxqYoTmuuTi8AvuwsM4bJivHkuuggOToHstLoxvAQOAr41QOKA5gsW61qKb0rHvu82zh2O0xfkDarPPII3o7WgL(kQsRIsYHIQfHxRIc8g6D2HvuG3hlwrjQ6ykABkklbgPaigUdSeKrAFLZF583680nF0WCosHJWKOigNN32E(lmF0hEJKKH86b6eVD2HnZFF(lmp4n07SdNIYqQLyjzsa9ffoM)(88fB5A1YMKb6zzhFZj(II2Ym)95JgMZrkCeMefrRii3OX8Go)1B0y(7ZhnmNJu4imjkIwrqUrJ5PB(BBEB75b8CSGazK2x58Go)1B0y(7Zd45ybbYiTVY5PBErvhtrBtsgYRhOtqgP9vo)95fvDmfTnjziVEGobzK2x580npiZBBpFMfaqsYqE9aDYs783NhWZXccKrAFLZt38xVQOaVHKTryffwDmKOmQqPZnknvu82zh2O0xrjGEWqVvuzwaajjd51d0jlTZBBpFMfaqsgfeHWnmWi9AiaoKtwAN)(8MksrzjWifaXWDGLGms7RCEB75b8CSGazK2x58GIFE6JgkQweETkkTv41QcLo0VstffVD2Hnk9vucOhm0BfLaZtiTUMh3NxG5Zth(5bz(7Zd25J(WBKKmKxpqN4TZoSzEB75VW8MksrzjWifaXWDGLGms7RCEWm)95ZSaassgYRhOtMI2o)95b788YWC0PWrysueKwxZd68xN32E(Op8gjjd51d0jE7SdBM)(8IQoMI2MKmKxpqNGms7RCEqNhK5TTN)cZh9H3ijziVEGoXBNDyZ83Nxu1Xu02uuwcmsbqmChyjiJ0(kNh05Vz(7ZFH5bVHEND4ewDmKOmZBBppVmmhDkCeMefbP118Gop9p)95fvDmfTnb4YqskacGfeDcYiTVY5bD(Rj6npyuuTi8AvuqgCgkzcwdruHsh6P0urXBNDyJsFfvlcVwffGldsbqcmMqdZdMeEodvucOhm0BfLaZtiTUMh3NxG5Zth(5Vz(7ZNzbaKKmKxpqNmfTD(7ZNzbaKKmhy(MtGDoNmfTD(7Zd255LH5OtHJWKOiiTUMh05VoVT98rF4nssgYRhOt82zh2m)95fvDmfTnjziVEGobzK2x58GopiZBBp)fMp6dVrsYqE9aDI3o7WM5VpVOQJPOTPOSeyKcGy4oWsqgP9vopOZFZ83N)cZdEd9o7WjS6yirzM32EEEzyo6u4imjkcsRR5bDE6F(7ZlQ6ykABcWLHKuaeali6eKrAFLZd68xt0BEWOOeOfhMenmNdPsNRQqPd9rPPII3o7WgL(kQweETkQWZzirBFquucOhm0Bf1fMxuizfjdYnkZFFEbMNqADnpUpVaZNNo8ZdY83NhSZh9H3ijziVEGoXBNDyZ822ZFH5nvKIYsGrkaIH7albzK2x5822Z3IWbNj8YiolNNU5bzEWm)95ZSaassMdmFZjWoNtMI2o)95ZSaassgYRhOtMI2o)95b788YWC0PWrysueKwxZd68xN32E(Op8gjjd51d0jE7SdBM)(8IQoMI2MKmKxpqNGms7RCEqNhK5TTN)cZh9H3ijziVEGoXBNDyZ83Nxu1Xu02uuwcmsbqmChyjiJ0(kNh05Vz(7ZFH5bVHEND4ewDmKOmZBBppVmmhDkCeMefbP118Gop9p)95fvDmfTnb4YqskacGfeDcYiTVY5bD(Rj6npyuuc0IdtIgMZHuPZvvO05wQ0urXBNDyJsFfLa6bd9wrjW85XppiZFFETqgCsUWKUMcpNHeT9bz(7ZhocppO4N)gfvlcVwfLaZj0AWzvO052uAQO4TZoSrPVIsa9GHEROey(84NhK5VpVwidojxysxtHNZqI2(Gm)95dhHNhu8ZFJIQfHxRIsG5KmlOmuHsNBvPPII3o7WgL(kkb0dg6TIsG5ZJFEqM)(8AHm4KCHjDnfEodjA7dY83NpCeEEqXp)nkQweETkkGdAFZjsgQL3GGIlqrfkDUQHstffVD2Hnk9vucOhm0Bfv0hEJKKH86b6eVD2HnkQweETkkrFoKweETKJldf1XLbzBewrjmejd51d0QqPZ1Rknvu82zh2O0xrjGEWqVvuxy(Op8gjjd51d0jE7SdBuuTi8AvuI(CiTi8AjhxgkQJldY2iSIsyisgqfkDUcIstffVD2Hnk9vucOhm0BfvMfaqsYqE9aDYsRIQfHxRIs0NdPfHxl54YqrDCzq2gHvusgYRhOvHsNR3O0urXBNDyJsFfLa6bd9wr1IWbNj8YiolNh05Vrr1IWRvrj6ZH0IWRLCCzOOoUmiBJWkkzOcLoxPFLMkkE7SdBu6ROeqpyO3kQweo4mHxgXz580HF(BuuTi8AvuI(CiTi8AjhxgkQJldY2iSIQlwfQqrPfYIcjRdLMkDUQ0ur1IWRvrPTcVwffVD2Hnk9vHshquAQO4TZoSrPVIQ0QOKCOOAr41QOaVHENDyff49XIvu8fB5A1YMKaT4ubSwxqYoTmM32EE(ITCTAzt6yjdyzjj51XWlr7XcPZ55TTNNVylxRw2KYpTX7OGsswBY55TTNNVylxRw2KYpTX7OGsccB6ZXRDEB755l2Y1QLnjiJubtYTCtVcMyyWDbROaVHKTryfvugsTeljtcOVOWHku6CJstffVD2Hnk9vuLwfLKdfvlcVwff4n07SdROaVpwSI66TQOeqpyO3kQlmF0hEJKKH86b6eVD2HnZFFEWop4n07SdNIYqQLyjzsa9ffoM32EE(ITCTAztQLyG3lljWg3kiruW(mpyuuG3qY2iSIcO2GuaeTfngs0czrHK1brG17YhvO0H(vAQO4TZoSrPVIABewr14MeRHTKauBqkaI2IgdvuTi8AvunUjXAylja1gKcGOTOXqvO0HEknvu82zh2O0xrjGEWqVvurF4nsaUmifajWycnmpys45mmXBNDyZ822ZZsjVcojQf44IG0RHidOdWjKw3uqfvlcVwfLaZj0AWzvO0H(O0ur1IWRvr5l4fkmrxw8QO4TZoSrPVku6ClvAQOAr41QOYTAOX7LuaKg3yyfykkE7SdBu6RcvOO6IvAQ05QstfvlcVwffnmhE8nNyGDETeTwRatrXBNDyJsFvO0beLMkkE7SdBu6ROeqpyO3kQlmVwidojxysxtHNZqI2(Gm)95fy(8GIF(RZFFEEzyo65bDE6PHIQfHxRIIxgM74MV5e(46YHQqPZnknvu82zh2O0xrjGEWqVvu8YWC0PWrysueKwxZt38xvuTi8AvuaUmKKcGaybrRcLo0VstffVD2Hnk9vuTi8Avuqx6BorATeuCbkkkb0dg6TIcSZh9H3irdZHhFZjgyNxlrR1kWs82zh2m)95fvDmfTnbDPV5eP1sqXfOKmwWo8ANNU5fvDmfTnrdZHhFZjgyNxlrR1kWsqgP9vo)LZt)ZdM5VppyNxu1Xu02eGldjPaiawq0jiJ0(kNNU5VzEB75fy(80HFE6npyuuc0IdtIgMZHuPZvvO0HEknvu82zh2O0xrjGEWqVvuzwaajOLeZ3CIUPnmHMVMKPOTkQweETkkOLeZ3CIUPnmHMVgvO0H(O0urXBNDyJsFfLa6bd9wrjkKSIidOJcp)95b78GDEWoVaZNNU5VzEB75fvDmfTnb4YqskacGfeDcYiTVY5PBE6Z8Gz(7Zd25fy(80HFE6nVT98IQoMI2MaCzijfabWcIobzK2x580npiZdM5bZ822ZZldZrNchHjrrqADnpO4N)M5TTNpZcaiz6vWKcGiWCDJNGClI5bJIQfHxRIsQ1313CIa2ltqXfOOcLo3sLMkkE7SdBu6ROeqpyO3kkbMNqADnpUpVaZNNo8ZdIIQfHxRIcYGZqjtWAiIku6CBknvu82zh2O0xrjGEWqVvucmpH06AECFEbMppD4N)QIQfHxRIsG5KmlOmuHsNBvPPII3o7WgL(kQweETkkaxgKcGeymHgMhmj8CgQOeqpyO3kkbMNqADnpUpVaZNNo8ZFJIsGwCys0WCoKkDUQcLox1qPPII3o7WgL(kQweETkQWZzirBFquucOhm0BfLaZtiTUMh3NxG5Zth(5bz(7Zd25VW8rF4nsyEqefswL4TZoSzEB75VW8IcjRizqUrzEWOOeOfhMenmNdPsNRQqPZ1Rknvu82zh2O0xrjGEWqVvuxyErHKvKmi3OOOAr41QOeyoHwdoRcLoxbrPPII3o7WgL(kQweETkkGdAFZjsgQL3GGIlqrrjGEWqVvuzwaaPScfIwyjsMI2QO8nyi0sBOOUQcLoxVrPPII3o7WgL(kQweETkQStlqPScckUaffLa6bd9wrjkKSIidOJcp)95b78zwaaPScfIwyjswAN32EEWoF0hEJeMherHKvjE7SdBM)(8AHm4KCHjDnfEodjA7dY83NxG5Zd680)8GzEWOOeOfhMenmNdPsNRQqfkkHHiziVEGwPPsNRknvu82zh2O0xrjGEWqVvuzwaajjd51d0jtrBN32EEaphliqgP9vopOZdc9uuTi8Avu(cEHct0LfVQqPdiknvu82zh2O0xr1IWRvr14MeRHTKauBqkaI2IgdvucOhm0BfvMfaqsYqE9aDYu025VppyNxu1Xu02KKH86b6eKrAFLZd68GOX822Zd45ybbYiTVY5bDE6xJ5bJIABewr14MeRHTKauBqkaI2IgdvHsNBuAQO4TZoSrPVIsa9GHEROYSaassgYRhOtMI2o)95b78aEowqGms7RCE6M)6TrV5TTNxu1Xu02KKH86b6eKrAFLZdk(5VLZdM5TTNhWZXccKrAFLZd683qpfvlcVwfvUvdnEVKcG04gdRatfkDOFLMkkE7SdBu6ROeqpyO3kkrvhtrBtsgYRhOtqgP9vopDZdIgZBBppGNJfeiJ0(kNh05brdfvlcVwfv2PkdbWcIwfkDONstffVD2Hnk9vucOhm0BfLOQJPOTjjd51d0jiJ0(kNNU5brJ5TTNhWZXccKrAFLZd68xPNIQfHxRIkJHsgIIV5QqPd9rPPII3o7WgL(kkb0dg6TIkZcaijziVEGozkA783NxG5jKwxZJ7ZlW85Pd)8xN)(88YWC0PWrysueKwxZth(51irpfvlcVwfvdf9YKOGqEdvO05wQ0ur1IWRvrD8CSqs0nwMCeEdffVD2Hnk9vHsNBtPPII3o7WgL(kkb0dg6TIsu1Xu02KKH86b6eKrAFLZt38GOX822Zd45ybbYiTVY5bD(RAOOAr41QOaCiNDQYOcLo3QstffVD2Hnk9vucOhm0BfLOQJPOTjjd51d0jiJ0(kNNU5brJ5TTNhWZXccKrAFLZd68GOHIQfHxRIQxbldyFiI(CuHsNRAO0ur1IWRvrL15KcGeqxGIurXBNDyJsFvO056vLMkkE7SdBu6ROAr41QOowYawwssEDm8s0ESq6CwrjGEWqVvuIQoMI2MIYsGrkaIH7albzK2x58Go)15TTNxu1Xu02uuwcmsbqmChyjiJ0(kNNU5brJ5TTNh8g6D2Hty1XqIYmVT98aEowqGms7RCEqXppiAOO2gHvuhlzalljjVogEjApwiDoRcLoxbrPPII3o7WgL(kQweETkQ8tB8okOKGWM(C8AvucOhm0BfLOQJPOTPOSeyKcGy4oWsqgP9vopOZFDEB75fvDmfTnfLLaJuaed3bwcYiTVY5PBEq0yEB75bVHEND4ewDmKOmZBBppGNJfeiJ0(kNhu8ZdIgkkgaGfbzBewrLFAJ3rbLee20NJxRku6C9gLMkkE7SdBu6ROAr41QOYpTX7OGscJKDyefLa6bd9wrb45ybbYiTVY5PB(R07wN32EErvhtrBtrzjWifaXWDGLGms7RCEqN)6822ZdEd9o7WjS6yirzuumaalcY2iSIk)0gVJckjms2HruHsNR0VstffVD2Hnk9vucOhm0Bf1fMh8g6D2Hty1XqIYOOAr41QOIYsGrkaIH7atfkDUspLMkkE7SdBu6ROeqpyO3kkaphliqgP9vopDZFLE36822ZBQifLLaJuaed3bwcYiTVY5TTNh8g6D2Hty1XqIYOOAr41QOIYsGrkacknePvHsNR0hLMkkE7SdBu6ROAr41QO0wcu4q64gBiIcrRv0HxlXWG7cwrjGEWqVvuzwaajjd51d0jtrBN)(8GDErvhtrBtrzjWifaXWDGLGms7RCE6M)QgZBBpp4n07SdNWQJHeLzEWmVT98aEowqGms7RCEqNNEkQTryfL2sGchsh3ydruiATIo8AjggCxWQqPZ1BPstffVD2Hnk9vucOhm0BfvMfaqsYqE9aDYu025VppyNxu1Xu02KKH86b6eKrAFLZt38GOX822ZlQ6ykABsYqE9aDcYiTVY5bDEqMhmZBBppGNJfeiJ0(kNh05VspfvlcVwfv2PkdPaibgt4LrqRcLoxVnLMkkE7SdBu6ROAr41QOGmsfmj3Yn9kyIHb3fSIsa9GHEROevDmfTnfLLaJuaed3bwcYiTVY5PB(RAmVT98G3qVZoCcRogsugf12iSIcYivWKCl30RGjggCxWQqPZ1BvPPII3o7WgL(kQweETkQ8tB8okOKK1MCwrjGEWqVvuIQoMI2MKmKxpqNGms7RCE6MhenM32EEaphliqgP9vopOZdIgkkgaGfbzBewrLFAJ3rbLKS2KZQqPdiAO0urXBNDyJsFfvlcVwfvEFyrFomusYQAvucOhm0BfLOQJPOTjjd51d0jiJ0(kNNU5brJ5TTNhWZXccKrAFLZd68GOHIABewrL3hw0NddLKSQwvO0bKRknvu82zh2O0xr1IWRvrrd6bMV5ejNJWBqkaIbYYOZ7atrjGEWqVvuIQoMI2MIYsGrkaIH7albzK2x580n)vnM32EEWBO3zhoHvhdjkJIABewrrd6bMV5ejNJWBqkaIbYYOZ7atfkDabeLMkkE7SdBu6ROAr41QOAjg49YscSXTcsefSpkkb0dg6TIYWzwaajyJBfKikyFigoZcaizkA7822ZNzbaKKmKxpqNGms7RCE6M)wN32EEaphliqgP9vopOZdc9uuBJWkQwIbEVSKaBCRGerb7Jku6aYnknvu82zh2O0xrjGEWqVvuzwaajjd51d0jtrBN)(8GDErvhtrBtsgYRhOtqgP9vopDZFLEZBBpVOQJPOTjjd51d0jiJ0(kNh05bzEWmVT98aEowqGms7RCEqNhenuuTi8Avu0k4Xao7lbYYA7vWQqPdi0VstffVD2Hnk9vucOhm0BfvMfaqsYqE9aDYu025VppyNxu1Xu02KKH86b6eKrAFLZBBpVOQJPOTjrTcEdyhSHaCAeojWAyolNh)8GmpyM)(8xyEtfjrTcEdyhSHaCAeMKzb3eKrAFLZFFEWoVOQJPOTjOl9nNiTwckUaLeKrAFLZFFErvhtrBtaUmKKcGaybrNGms7RCEB75b8CSGazK2x58Go)TnpyuuTi8AvuIAf8gWoydb40iSku6ac9uAQOAr41QOKmKxpqRO4TZoSrPVku6ac9rPPII3o7WgL(kkb0dg6TIkZcaijziVEGozkARIQfHxRIkWyI1MvwRHauqbRcLoGClvAQO4TZoSrPVIsa9GHEROYSaassgYRhOtMI2QOAr41QO0AbDa0(MtYoTmuHshqUnLMkkE7SdBu6ROeqpyO3kQmlaGKKH86b6KPOTZFFEWoF0WCosHJWKOiAfbbenMNU5VrJ5TTNpAyohjmUpbwsRiMhu8ZdIgZdM5TTNpAyohPWrysueJZZd68GOOAr41QOGCR13CcWPryPku6aYTQ0urXBNDyJsFfLa6bd9wrLzbaKKmKxpqNmfTvr1IWRvrbucljBinUXqpysg3iQqPZnAO0urXBNDyJsFfLa6bd9wrLzbaKKmKxpqNmfTD(7ZZldZrppOZt)AOOAr41QOqyKcIMuaKJLWnedKBePku6CZvLMkkE7SdBu6ROeqpyO3kQmlaGKKH86b6KPOTkQweETkkORv7Hj(sKABbRcLo3aIstffVD2Hnk9vucOhm0BfvMfaqsYqE9aDYu0wfvlcVwfvwNtkasaDbksvO05MBuAQO4TZoSrPVIsa9GHEROYSaassgYRhOtMI2o)95b78GDE(ITCTAztsGwCQawRlizNwgZFFErvhtrBtc0ItfWADbj70YibzK2x58GIFEq0yEWmVT98xyE(ITCTAztsGwCQawRlizNwgZdgfvlcVwfLLKjEWisvOcfLmuAQ05QstfvlcVwffnmhE8nNyGDETeTwRatrXBNDyJsFvO0beLMkkE7SdBu6ROeqpyO3kQOp8gjjd51d0jE7SdBM32EErvhtrBtrzjWifaXWDGLGms7RCE6MN(mVT98G3qVZoCcRogsugfvlcVwffGldjPaiawq0QqPZnknvu82zh2O0xr1IWRvrbDPV5eP1sqXfOOOeqpyO3kQOp8gjjd51d0jE7SdBM32EErvhtrBtrzjWifaXWDGLGms7RCE6MhK5TTNh8g6D2Hty1XqIYOOeOfhMenmNdPsNRQqPd9R0urXBNDyJsFfLa6bd9wrLzbaKGwsmFZj6M2WeA(AsMI2o)95Br4GZeEzeNLZt38xvuTi8AvuqljMV5eDtBycnFnQqPd9uAQO4TZoSrPVIsa9GHEROeyEcP1184(8cmFE6M)QIQfHxRIcYGZqjtWAiIku6qFuAQO4TZoSrPVIQfHxRIcWLbPaibgtOH5btcpNHkkb0dg6TIsG5Zd683OOeOfhMenmNdPsNRQqPZTuPPII3o7WgL(kkb0dg6TIsG5Zdk(5Vz(7ZZldZrppOZtpnuuTi8Avu8YWCh38nNWhxxoufkDUnLMkkE7SdBu6ROeqpyO3kkbMNqADnpUpVaZNNU51y(7Z3IWbNj8YiolNh)8xN32EEbMNqADnpUpVaZNNU5VQOAr41QOeyojZckdvO05wvAQO4TZoSrPVIQfHxRIk8Cgs02hefLa6bd9wrjkKSIidOJcp)95fyEcP1184(8cmFE6M)M5Vp)fM3urkklbgPaigUdSeKrAFLZFF(mlaGKmkicHByGr61qaCiNmfTvrjqlomjAyohsLoxvHsNRAO0ur1IWRvrjWCcTgCwrXBNDyJsFvO056vLMkkE7SdBu6ROeqpyO3kkrHKvezaDu45VpFMfaqY0RGjfarG56gpb5wekQweETkkPwFxFZjcyVmbfxGIku6CfeLMkkE7SdBu6ROAr41QOYoTaLYkiO4cuuucOhm0BfLOqYkImGok883NhSZd25J(WBKKmKxpqN4TZoSzEB75fvDmfTnfLLaJuaed3bwcYiTVY5PBEqM32EEWBO3zhoHvhdjkZ8Gz(7Zd25fvDmfTnbDPV5eP1sqXfOKGms7RCE6MhK5VpVOQJPOTjaxgssbqaSGOtqgP9vopDZdY822ZlQ6ykABc6sFZjsRLGIlqjbzK2x58Go)nZFFErvhtrBtaUmKKcGaybrNGms7RCE6M)M5VpVaZNNU5bzEB75fvDmfTnbDPV5eP1sqXfOKGms7RCE6M)M5VpVOQJPOTjaxgssbqaSGOtqgP9vopOZFZ83NxG5Zt380)822ZlW85PBE6npyM32E(mlaGuwHcrlSejlTZdgfLaT4WKOH5Civ6CvfkDUEJstffVD2Hnk9vuTi8AvuHNZqI2(GOOeqpyO3kkrHKvezaDu45VpVaZtiTUMh3NxG5Zt38xvuc0IdtIgMZHuPZvvO05k9R0ur5BWqOL2qrDvr1IWRvrbCq7BorYqT8geuCbkkkE7SdBu6RcLoxPNstffVD2Hnk9vuTi8AvuzNwGszfeuCbkkkb0dg6TIsuizfrgqhfE(7Zd25fvDmfTnb4YqskacGfeDcYiTVY5bD(BM)(8cmFE8ZdY822ZZldZrNchHjrrqADnpOZFDEWm)95b78AHm4KCHjDnfEodjA7dY822ZlW8esRR5X95fy(8GopiZdgfLaT4WKOH5Civ6CvfQqrjziVEGwPPsNRknvu82zh2O0xrjGEWqVvuzwaajjd51d0jiJ0(kNh05VoVT98TiCWzcVmIZY5PB(RkQweETkkaxgssbqaSGOvHshquAQO4TZoSrPVIsa9GHEROefswrKb0rHN)(8GD(weo4mHxgXz580npiZBBpFlchCMWlJ4SCE6M)683N)cZlQ6ykABc6sFZjsRLGIlqjzPDEWOOAr41QOKA9D9nNiG9YeuCbkQqPZnknvu82zh2O0xr1IWRvrbDPV5eP1sqXfOOOeqpyO3kkrHKvezaDuyfLaT4WKOH5Civ6CvfkDOFLMkkFdgcT0gehqrLlmjiJ0(kXRHIQfHxRIcWLHKuaealiAffVD2Hnk9vHsh6P0urXBNDyJsFfvlcVwffGldsbqcmMqdZdMeEodvucOhm0BfLaZNh05VrrjqlomjAyohsLoxvHsh6JstffVD2Hnk9vucOhm0BfLaZtiTUMh3NxG5Zt38xN)(88YWC0PWrysueKwxZd68xvuTi8AvuqgCgkzcwdruHsNBPstffVD2Hnk9vuTi8AvuzNwGszfeuCbkkkb0dg6TIsuizfrgqhfEEB75VW8rF4nsyEqefswL4TZoSrrjqlomjAyohsLoxvHsNBtPPIQfHxRIsQ1313CIa2ltqXfOOO4TZoSrPVkuHkuuGZqPxRshq0aen0G(aYnkkAnC9nxQOU90T0x6C7OZTlDN5NxtmEEhrBbJ5bk483cHHizGBX8q(ITCiBMxwi88TvuiDWM5fy9MZY0GJUR(YZdc90DMhxul4mmyZ83IWrysueTIGO7R7NGms7R8wmFuZFlchHjrr0kcIUVU)TyEWEvxGjn4m4C7PBPV052rNBx6oZpVMy88oI2cgZduW5VfggOToXTyEiFXwoKnZlleE(2kkKoyZ8cSEZzzAWr3vF55br3zECrTGZWGnZFlchHjrr0kcIUVUFcYiTVYBX8rn)TiCeMefrRii6(6(3I5bli6cmPbNbNBheTfmyZ83Y5Br41o)XLHmn4OO0cla)WkkCD(BpFn06dkmC(B31IYGdUopweAL6o6PxUhywzjrHON0rSoD41kGnqON0re6n4GRZRBTYTKX8GG68GObiAm4m4GRZJlW6nNL6odo4684(80xmsboppLwUHZR7UxZ8ub0rHNxuRj8ALZdwSEnh2mFg65BJPwWKgCW15X95Xfy9MZZhnmNdIdmFuZlqlomjAyohY0GdUopUpp9fJuGZZZldZrpVO1oVaJfOmpqbNhx6YqoFbmpU0cIEEWkDK5noaad5vWZ7Y5xo)45E2HrD(mRyETNg98ghaGH8k45D58spFDax0BaM0GdUopUpVU1yyZ8xujp)TtWiY5bBa9ffoKOophIeysdodo4686E6IfwbBMpJbkipVOqY6y(mo3xzAEDRqWAd58BT4owdraSoZ3IWRvoFTh0PbhCD(weETYKwilkKSoWdCAjkdo468Ti8ALjTqwuizDCjE9aQYm4GRZ3IWRvM0czrHK1XL41RTYr4n6WRDWbxNNABTsSkMh2Uz(mlaa2mVm6qoFgduqEErHK1X8zCUVY571mVwiJ7ARi8nFExoVPwon4GRZ3IWRvM0czrHK1XL41tUTwjwfez0HCWPfHxRmPfYIcjRJlXRN2k8AhCW15XfySaf58oW8OlR5XAW5575dOVOWX88fB5A1YM5dSoMNwVHC(OMpJN3sYM5JkNdmgopnpWMxZ6Im40IWRvM0czrHK1XL41d8g6D2HrDBegFugsTeljtcOVOWbQLw8soqf8(yX45l2Y1QLnjbAXPcyTUGKDAzyBZxSLRvlBshlzalljjVogEjApwiDoBBZxSLRvlBs5N24DuqjjRn5STnFXwUwTSjLFAJ3rbLee20NJxRTnFXwUwTSjbzKkysULB6vWeddUl4bNweETYKwilkKSoUeVEG3qVZomQBJW4bQnifarBrJHeTqwuizDqey9U8b1slEjhOcEFSy8xVvuDa8xi6dVrsYqE9aDI3o7WM7Gf8g6D2Htrzi1sSKmjG(Ich228fB5A1YMulXaVxwsGnUvqIOG9bmdoTi8ALjTqwuizDCjE9SKmXdgb1Try8nUjXAylja1gKcGOTOXWbNweETYKwilkKSoUeVEcmNqRbNr1bWh9H3ib4YGuaKaJj0W8GjHNZWeVD2Hn22SuYRGtIAboUii9AiYa6aCcP1nfCWPfHxRmPfYIcjRJlXRNVGxOWeDzXljWycnmpys45mCWPfHxRmPfYIcjRJlXRxUvdnEVKcG04gdRaBWzWbxNx3txSWkyZ8m4me98HJWZhy88Tik48UC(g82pD2HtdoTi8AL4LA5gsW61qKb0rHhCW15VOsEETv41oVdmpfd51d0Z7Y5T0I68fC(SkWMNs3dxoFVM51SUiZ3qEElTOoFbNpW45JgMZX808ZzEJZZtZdmFNN(OX8swuRro4GRZR7Ig6D2HNpW6yEA(5mFWNZ8OlR5DG5rxwZtZpN5xMnZh180ApMpQ5fTmMxZ6IONPMFRyEA9gZh18IwgZ7X8DmFFoZ3lAKcYdoTi8ALxIxpWBO3zhg1Try8y1XqIYGAPfVKdubVpwmErvhtrBtrzjWifaXWDGLGms7R8YBLUOH5CKchHjrrmoBBFHOp8gjjd51d0jE7SdBUFbWBO3zhofLHulXsYKa6lkCCNVylxRw2Kmqpl74BoXxu0wM7rdZ5ifoctIIOveKB0ibzK2xjOxVrJ7rdZ5ifoctIIOveKB0ibzK2xjD3MTnGNJfeiJ0(kb96nAChWZXccKrAFL0jQ6ykABsYqE9aDcYiTVY7IQoMI2MKmKxpqNGms7RKoqSTZSaassgYRhOtwAVd45ybbYiTVs6UEDWbxN)Ik551wHx78oW8umKxpqpVlN3slQZxW5ZQaBEkDpC589AMxZ6ImFd55T0I68fC(aJNpAyohZtZpN5noppnpW8DE6JgZlzrTg5GtlcVw5L41tBfETO6a4ZSaassgYRhOtwATTZSaasYOGieUHbgPxdbWHCYs7DtfPOSeyKcGy4oWsqgP9vABd45ybbYiTVsqXtF0yWPfHxR8s86bzWzOKjynebvhaVaZtiTUWDbMthEqUd2Op8gjjd51d0jE7SdBSTVGPIuuwcmsbqmChyjiJ0(kbZ9mlaGKKH86b6KPOT3blVmmhDkCeMefbP1fOxTTJ(WBKKmKxpqN4TZoS5UOQJPOTjjd51d0jiJ0(kbfeB7le9H3ijziVEGoXBNDyZDrvhtrBtrzjWifaXWDGLGms7Re0BUFbWBO3zhoHvhdjkJTnVmmhDkCeMefbP1fO0)DrvhtrBtaUmKKcGaybrNGms7Re0Rj6bMbhCD(lQKNhxwXTNMZ7aZpp6YA(gYZJ4sPV5Z3X8hULX83mVaZrDED7AMFEjd51d0OoVUDnZpV(vO7nFd553kM3slQZRB15Imp6YAE2dmgoFd557SYkMpQ5fT255LH5OrD(coVKH86b65D58DwzfZh18IcHN3slQZxW51SUiZ7Y57SYkMpQ5ffcpVLwuNVGZJllC58UCErH4B(8wANVxZ8OlR5P5NZ8Iw788YWC0ZlRAhCAr41kVeVEaUmifajWycnmpys45mevbAXHjrdZ5qI)kQoaEbMNqADH7cmNo83CpZcaijziVEGozkA79mlaGKK5aZ3CcSZ5KPOT3blVmmhDkCeMefbP1fOxTTJ(WBKKmKxpqN4TZoS5UOQJPOTjjd51d0jiJ0(kbfeB7le9H3ijziVEGoXBNDyZDrvhtrBtrzjWifaXWDGLGms7Re0BUFbWBO3zhoHvhdjkJTnVmmhDkCeMefbP1fO0)DrvhtrBtaUmKKcGaybrNGms7Re0Rj6bMbhCD(lQKNxZB)5DG59yEA1gZNb5gL5rAzWq0OoVUvNlY8nKNhXLsFZNVJ5pClJ5bzEbMJ686wDUiZN55ZlQ6ykARC(gYZVvmVLwuNx3QZfzE0L18ShymC(gYZ3zLvmFuZlATZZldZrJ68fCEjd51d0Z7Y57SYkMpQ5ffcpVLwuNVGZRzDrM3LZlkeFZN3slQZxW5XLfUCExoVOq8nFElTZ3RzE0L1808ZzErRDEEzyo65LvTdoTi8ALxIxVWZzirBFqqvGwCys0WCoK4VIQdG)cIcjRizqUr5UaZtiTUWDbMthEqUd2Op8gjjd51d0jE7SdBSTVGPIuuwcmsbqmChyjiJ0(kTTBr4GZeEzeNL0bcyUNzbaKKmhy(MtGDoNmfT9EMfaqsYqE9aDYu027GLxgMJofoctIIG06c0R22rF4nssgYRhOt82zh2Cxu1Xu02KKH86b6eKrAFLGcIT9fI(WBKKmKxpqN4TZoS5UOQJPOTPOSeyKcGy4oWsqgP9vc6n3Va4n07SdNWQJHeLX2MxgMJofoctIIG06cu6)UOQJPOTjaxgssbqaSGOtqgP9vc61e9aZGtlcVw5L41tG5eAn4mQoaEbMJhK7AHm4KCHjDnfEodjA7dY9WryqXFZGtlcVw5L41tG5KmlOmq1bWlWC8GCxlKbNKlmPRPWZzirBFqUhocdk(BgCAr41kVeVEah0(MtKmulVbbfxGcQoaEbMJhK7AHm4KCHjDnfEodjA7dY9WryqXFZGtlcVw5L41t0NdPfHxl54Ya1Try8cdrYqE9anQoa(Op8gjjd51d0jE7SdBgCAr41kVeVEI(CiTi8AjhxgOUncJxyisgavha)fI(WBKKmKxpqN4TZoSzWbxNhx0NZ8bgppfd51d0Z3IWRD(JlJ5DG5PyiVEGEExoVWcc5noON3s7GtlcVw5L41t0NdPfHxl54Ya1Try8sgYRhOr1bWNzbaKKmKxpqNS0o4GRZJl6Zz(aJNNsZ5Br41o)XLX8oW8bgd55BippiZxW5pSuopVmIZYbNweETYlXRNOphslcVwYXLbQBJW4LbQoa(weo4mHxgXzjO3m4GRZJl6Zz(aJNx3w6EZ3IWRD(JlJ5DG5dmgYZ3qE(BMVGZJuqEEEzeNLdoTi8ALxIxprFoKweETKJldu3gHX3fJQdGVfHdot4LrCwsh(BgCgCW151TIWRvM0TLU38UCEFdEnSzEGcoVLKNNMhyZR7MfHli6wJHGloCdopFVM5fwqiVXb98lZg58rnFgpFPnCeh3yZGtlcVwzQlgpnmhE8nNyGDETeTwRaBWPfHxRm1fFjE94LH5oU5BoHpUUCiQoa(lOfYGtYfM01u45mKOTpi3fyoO4VENxgMJgu6PXGtlcVwzQl(s86b4YqskacGfenQoaEEzyo6u4imjkcsRl6Uo40IWRvM6IVeVEqx6BorATeuCbkOkqlomjAyohs8xr1bWd2Op8gjAyo84BoXa78AjATwbwI3o7WM7IQoMI2MGU03CI0AjO4cusglyhET0jQ6ykABIgMdp(MtmWoVwIwRvGLGms7R8s6hm3bROQJPOTjaxgssbqaSGOtqgP9vs3n22cmNo80dmdoTi8ALPU4lXRh0sI5Bor30gMqZxdQoa(mlaGe0sI5Bor30gMqZxtYu02bNweETYux8L41tQ1313CIa2ltqXfOGQdGxuizfrgqhf(oyblyfyoD3yBlQ6ykABcWLHKuaeali6eKrAFL0rFaZDWkWC6WtpBBrvhtrBtaUmKKcGaybrNGms7RKoqadyST5LH5OtHJWKOiiTUaf)n22zwaajtVcMuaebMRB8eKBraMbNweETYux8L41dYGZqjtWAicQoaEbMNqADH7cmNo8Gm4GRZJlSGqEJd65Xfy(86BbLX8UC((qRrlNp3b3385VoVaZN335LoIyEgCEN3bM3J5X8qopsb55dSEN)68rdZ5yEzn)TZ8soMpWC58rn)1bNweETYux8L41tG5KmlOmq1bWlW8esRlCxG50H)6GtlcVwzQl(s86b4YGuaKaJj0W8GjHNZqufOfhMenmNdj(RO6a4fyEcP1fUlWC6WFZGtlcVwzQl(s86fEodjA7dcQc0IdtIgMZHe)vuDa8cmpH06c3fyoD4b5oyVq0hEJeMherHKvjE7SdBSTVGOqYksgKBuaZGtlcVwzQl(s86jWCcTgCgvha)fefswrYGCJYGtlcVwzQl(s86bCq7BorYqT8geuCbkO6a4ZSaaszfkeTWsKmfTfvFdgcT0g4Vo40IWRvM6IVeVEzNwGszfeuCbkOkqlomjAyohs8xr1bWlkKSIidOJcFhSzwaaPScfIwyjswATTbB0hEJeMherHKvjE7SdBURfYGtYfM01u45mKOTpi3fyoO0pyaZGZGdUopUOQJPOTYbNweETYKWqKmaEFbVqHj6YIxsGXeAyEWKWZziQoa(mlaGKKH86b6KPOT22aEowqGms7ReuqO3GtlcVwzsyisg4s86LB1qJ3lPainUXWkWq1bWd45ybbYiTVs6UEB0Z2(cG3qVZoCcRogsuM7IQoMI2MIYsGrkaIH7albzK2xjO4Vs)22aEowqGms7Re0BOpdoTi8ALjHHizGlXRhTcEmGZ(sGSS2EfmQoaErvhtrBtrzjWifaXWDGLGms7RKo6DB22IQoMI2MIYsGrkaIH7albzK2xjOGyBdEd9o7WjS6yirzSTb8CSGazK2xjOGOXGdUo)fvYZRBHIE551SGqEJ5DG5rxwZ3qEEexk9nF(oM)WTmM)684cmF(EnZtR2BrmVO1opVmmh9808aZ351irV5LSOwJCWPfHxRmjmejdCjE9AOOxMefeYBGQdGxG5jKwx4UaZPd)178YWC0PWrysueKwx0HxJe9gCAr41ktcdrYaxIxpljt8GrqDBeg)XsgWYssYRJHxI2JfsNZO6a4fvDmfTnfLLaJuaed3bwcYiTVsqVABlQ6ykABkklbgPaigUdSeKrAFL0bIg22G3qVZoCcRogsugBBaphliqgP9vckEq0yWPfHxRmjmejdCjE9SKmXdgbvgaGfbzBegF(PnEhfusqytFoETO6a4fvDmfTnfLLaJuaed3bwcYiTVsqVABlQ6ykABkklbgPaigUdSeKrAFL0bIg22G3qVZoCcRogsugBBaphliqgP9vckEq0yWPfHxRmjmejdCjE9SKmXdgbvgaGfbzBegF(PnEhfusyKSdJGQdGhWZXccKrAFL0DLE3QTTOQJPOTPOSeyKcGy4oWsqgP9vc6vBBWBO3zhoHvhdjkZGtlcVwzsyisg4s86fLLaJuaed3bgQoa(laEd9o7WjS6yirzUd2lWxSLRvlBsc0ItfWADbj70YW2wu1Xu02KaT4ubSwxqYoTmsqgP9vck(RG5oyfyoDxTT5LH5ObL(1amdoTi8ALjHHizGlXRNmkicHByGr61qaCiJkQoaErvhtrBtYOGieUHbgPxdbWHCsG1WCwIheBBtfPOSeyKcGy4oWsqgP9vABd45ybbYiTVsqbrdBBWMzbaKOvWJbC2xcKL12RGtqgP9vs3vnSTfvDmfTnrRGhd4SVeilRTxbNGms7RKorvhtrBtYOGieUHbgPxdbWHCcW6CiqwG1WCMeocBBFbwk5vWjAf8yaN9LazzT9k4esRBkiyUdwrvhtrBtrzjWifaXWDGLGms7RKorvhtrBtYOGieUHbgPxdbWHCcW6CiqwG1WCMeocBBdEd9o7WjS6yirzUFb(ITCTAztYa9SSJV5eFrrBzaZDrvhtrBtaUmKKcGaybrNGms7Reu836DbMth(BUlQ6ykABIgMdp(MtmWoVwIwRvGLGms7Reu8xVzWPfHxRmjmejdCjE9IYsGrkacknePr1bWd45ybbYiTVs6UsVB122urkklbgPaigUdSeKrAFL22G3qVZoCcRogsuMbNweETYKWqKmWL41l7uLHuaKaJj8YiOr1bWlQ6ykABkklbgPaigUdSeKrAFL0r)0Z2g8g6D2Hty1XqIYCxu1Xu02eGldjPaiawq0jiJ0(kbfeBBaphliqgP9vc6vqSTb8CSGazK2xjDx1qJ7aEowqGms7Re0Rx14oyfvDmfTnb4YqskacGfeDcYiTVsqVX2wu1Xu02enmhE8nNyGDETeTwRalbzK2xjO0Z2wu1Xu02e0L(MtKwlbfxGscYiTVsqPhygCAr41ktcdrYaxIxprTcEdyhSHaCAegvha)fmvKe1k4nGDWgcWPrysMfCtqgP9vEhSGvu1Xu02KOwbVbSd2qaoncNGms7Reu8IQoMI2MIYsGrkaIH7albzK2x5LxTTbVHEND4ewDmKOmG5oyVq0hEJenmhE8nNyGDETeTwRalXBNDyJTTOQJPOTjAyo84BoXa78AjATwbwcYiTVsWCxu1Xu02e0L(MtKwlbfxGscYiTVY7IQoMI2MaCzijfabWcIobzK2x59mlaGKmkicHByGr61qaCiNmfT122urkklbgPaigUdSeKrAFLGX2gWZXccKrAFLGEBdo468xujpV(NQmZJlTGON3bMxZYsGnFbm)fH7a7wiNxu1Xu025D585qUdgoFG1783OX8GnWC58(kowgwopnm)WZRzDrM3LZlSGqEJd65Br4GZGb15l48faW8IQoMI2opnmENhDznFd55XQJX385RnQ51SUiOoFbNNggVZhy88rdZ5yExoFNvwX8rnVX5bNweETYKWqKmWL41l7uLHaybrJQdGxu1Xu02uuwcmsbqmChyjiJ0(kP7gnSTbVHEND4ewDmKOm22aEowqGms7Reuq0yWPfHxRmjmejdCjE9YyOKHO4BoQoaErvhtrBtrzjWifaXWDGLGms7RKUB0W2g8g6D2Hty1XqIYyBd45ybbYiTVsqVsVbNweETYKWqKmWL41745yHKOBSm5i8gdoTi8ALjHHizGlXRhGd5StvguDa8IQoMI2MIYsGrkaIH7albzK2xjD3OHTn4n07SdNWQJHeLX2gWZXccKrAFLGEvJbNweETYKWqKmWL41RxbldyFiI(Cq1bWlQ6ykABkklbgPaigUdSeKrAFL0DJg22G3qVZoCcRogsugBBaphliqgP9vckiAm40IWRvMegIKbUeVEzDoPaib0fOihCAr41ktcdrYaxIxpljt8GrqDBegV2sGchsh3ydruiATIo8AjggCxWOIQdGxu1Xu02uuwcmsbqmChyjiJ0(kP7gnSTbVHEND4ewDmKOmdoTi8ALjHHizGlXRNLKjEWiOUncJhYivWKCl30RGjggCxWO6a4fvDmfTnfLLaJuaed3bwcYiTVs6UrdBBWBO3zhoHvhdjkZGtlcVwzsyisg4s86zjzIhmcQmaalcY2im(8tB8okOKK1MCgvhaVOQJPOTPOSeyKcGy4oWsqgP9vshiAyBdEd9o7WjS6yirzSTb8CSGazK2xjOGOXGtlcVwzsyisg4s86zjzIhmcQBJW4Z7dl6ZHHsswvlQoaErvhtrBtrzjWifaXWDGLGms7RKo6rpBBWBO3zhoHvhdjkJTnGNJfeiJ0(kb9kidoTi8ALjHHizGlXRNLKjEWiOUncJNg0dmFZjsohH3GuaedKLrN3bgQoaErvhtrBtrzjWifaXWDGLGms7RKoq0W2g8g6D2Hty1XqIYm40IWRvMegIKbUeVEwsM4bJG62im(wIbEVSKaBCRGerb7dQoaEWBO3zhofLHulXsYKa6lkCChSIQoMI2MIYsGrkaIH7albzK2xjDGC12g8g6D2Hty1XqIYaM7G1WzwaajyJBfKikyFigoZcaizkARTDMfaqsgfeHWnmWi9AiaoKtqgP9vs31BSTb8CSGazK2xjUlQ6ykABkklbgPaigUdSeKrAFLGs)ACxu1Xu02uuwcmsbqmChyjiJ0(kbfe6zBd45ybbYiTVsqbHEGzWPfHxRmjmejdCjE9SKmXdgb1Try8Ted8Ezjb24wbjIc2huDa8xa8g6D2Htrzi1sSKmjG(Ich3bRHZSaasWg3kiruW(qmCMfaqYu0wBBWEb(ITCTAztYa9SSJV5eFrrBzSTJgMZrkCeMefrRii3OrcYiTVsqVnWChSMksrzjWifaXWDGLGms7R02wu1Xu02uuwcmsbqmChyjiJ0(kV8wPdWZXccKrAFLG5EMfaqsgfeHWnmWi9AiaoKtwATTb8CSGazK2xjOGqpWm40IWRvMegIKbUeVEbgtS2SYAneGck4bNweETYKWqKmWL41tRf0bq7Boj70YyWPfHxRmjmejdCjE9GCR13CcWPryjQoa(OH5CKchHjrr0kcciAq3nAyBhnmNJeg3NalPveGIhengCAr41ktcdrYaxIxpGsyjzdPXng6btY4gzWPfHxRmjmejdCjE9qyKcIMuaKJLWnedKBejQoaEEzyoAqPFngCAr41ktcdrYaxIxpORv7Hj(sKABbp40IWRvMegIKbUeVEzDoPaib0fOihCAr41ktcdrYaxIxpljt8GrKO6a4blFXwUwTSjjqlovaR1fKStlJ7IQoMI2MeOfNkG16cs2PLrcYiTVsqXdIgGX2(c8fB5A1YMKaT4ubSwxqYoTmgCgCW15XfvDmfTvo40IWRvMegIKH86bA8(cEHct0LfVKaJj0W8GjHNZquDa8zwaajjd51d0jtrBTTb8CSGazK2xjOGqVbNweETYKWqKmKxpqFjE9SKmXdgb1Try8nUjXAylja1gKcGOTOXquDa8zwaajjd51d0jtrBVdwrvhtrBtsgYRhOtqgP9vckiAyBd45ybbYiTVsqPFnaZGtlcVwzsyisgYRhOVeVE5wn049skasJBmScmuDa8zwaajjd51d0jtrBVdwaphliqgP9vs31BJE22IQoMI2MKmKxpqNGms7Reu83sWyBd45ybbYiTVsqVHEdoTi8ALjHHiziVEG(s86LDQYqaSGOr1bWlQ6ykABsYqE9aDcYiTVs6ardBBaphliqgP9vckiAm40IWRvMegIKH86b6lXRxgdLmefFZr1bWlQ6ykABsYqE9aDcYiTVs6ardBBaphliqgP9vc6v6n4GRZFrL886wOOxEEnliK3yEhyEkgYRhON3LZVvmVLwuNVxZ8OlR5BippIlL(MpFhZF4wgZFDECbMJ689AMNwT3IyErRDEEzyo65P5bMVZRrIEZlzrTg5GtlcVwzsyisgYRhOVeVEnu0ltIcc5nq1bWNzbaKKmKxpqNmfT9UaZtiTUWDbMth(R35LH5OtHJWKOiiTUOdVgj6n40IWRvMegIKH86b6lXR3XZXcjr3yzYr4ngCAr41ktcdrYqE9a9L41dWHC2PkdQoaErvhtrBtsgYRhOtqgP9vshiAyBd45ybbYiTVsqVQXGtlcVwzsyisgYRhOVeVE9kyza7dr0NdQoaErvhtrBtsgYRhOtqgP9vshiAyBd45ybbYiTVsqbrJbNweETYKWqKmKxpqFjE9Y6CsbqcOlqro40IWRvMegIKH86b6lXRNLKjEWiOUncJ)yjdyzjj51XWlr7XcPZzuDa8IQoMI2MIYsGrkaIH7albzK2xjOxTTfvDmfTnfLLaJuaed3bwcYiTVs6ardBBWBO3zhoHvhdjkJTnGNJfeiJ0(kbfpiAm40IWRvMegIKH86b6lXRNLKjEWiOYaaSiiBJW4ZpTX7OGsccB6ZXRfvhaVOQJPOTPOSeyKcGy4oWsqgP9vc6vBBrvhtrBtrzjWifaXWDGLGms7RKoq0W2g8g6D2Hty1XqIYyBd45ybbYiTVsqXdIgdoTi8ALjHHiziVEG(s86zjzIhmcQmaalcY2im(8tB8okOKWizhgbvhapGNJfeiJ0(kP7k9UvBBrvhtrBtrzjWifaXWDGLGms7Re0R22G3qVZoCcRogsuMbNweETYKWqKmKxpqFjE9IYsGrkaIH7advha)faVHEND4ewDmKOmdoTi8ALjHHiziVEG(s86fLLaJuaeuAisJQdGhWZXccKrAFL0DLE3QTTPIuuwcmsbqmChyjiJ0(kTTbVHEND4ewDmKOmdoTi8ALjHHiziVEG(s86zjzIhmcQBJW41wcu4q64gBiIcrRv0HxlXWG7cgvhaFMfaqsYqE9aDYu027Gvu1Xu02uuwcmsbqmChyjiJ0(kP7Qg22G3qVZoCcRogsugWyBd45ybbYiTVsqP3GtlcVwzsyisgYRhOVeVEzNQmKcGeymHxgbnQoa(mlaGKKH86b6KPOT3bROQJPOTjjd51d0jiJ0(kPdenSTfvDmfTnjziVEGobzK2xjOGagBBaphliqgP9vc6v6n40IWRvMegIKH86b6lXRNLKjEWiOUncJhYivWKCl30RGjggCxWO6a4fvDmfTnfLLaJuaed3bwcYiTVs6UQHTn4n07SdNWQJHeLzWPfHxRmjmejd51d0xIxpljt8GrqLbayrq2gHXNFAJ3rbLKS2KZO6a4fvDmfTnjziVEGobzK2xjDGOHTnGNJfeiJ0(kbfengCAr41ktcdrYqE9a9L41ZsYepyeu3gHXN3hw0NddLKSQwuDa8IQoMI2MKmKxpqNGms7RKoq0W2gWZXccKrAFLGcIgdoTi8ALjHHiziVEG(s86zjzIhmcQBJW4Pb9aZ3CIKZr4nifaXazz05DGHQdGxu1Xu02uuwcmsbqmChyjiJ0(kP7Qg22G3qVZoCcRogsuMbNweETYKWqKmKxpqFjE9SKmXdgb1Try8Ted8Ezjb24wbjIc2huDa8goZcaibBCRGerb7dXWzwaajtrBTTZSaassgYRhOtqgP9vs3TABd45ybbYiTVsqbHEdoTi8ALjHHiziVEG(s86rRGhd4SVeilRTxbJQdGpZcaijziVEGozkA7DWkQ6ykABsYqE9aDcYiTVs6UspBBrvhtrBtsgYRhOtqgP9vckiGX2gWZXccKrAFLGcIgdoTi8ALjHHiziVEG(s86jQvWBa7GneGtJWO6a4ZSaassgYRhOtMI2EhSIQoMI2MKmKxpqNGms7R02wu1Xu02KOwbVbSd2qaoncNeynmNL4bbm3VGPIKOwbVbSd2qaonctYSGBcYiTVY7Gvu1Xu02e0L(MtKwlbfxGscYiTVY7IQoMI2MaCzijfabWcIobzK2xPTnGNJfeiJ0(kb92aZGtlcVwzsyisgYRhOVeVEsgYRhOhCAr41ktcdrYqE9a9L41lWyI1MvwRHauqbJQdGpZcaijziVEGozkA7GtlcVwzsyisgYRhOVeVEATGoaAFZjzNwgO6a4ZSaassgYRhOtMI2o40IWRvMegIKH86b6lXRhKBT(Mtaonclr1bWNzbaKKmKxpqNmfT9oyJgMZrkCeMefrRiiGObD3OHTD0WCosyCFcSKwrakEq0am22rdZ5ifoctIIyCguqgCAr41ktcdrYqE9a9L41dOews2qACJHEWKmUrq1bWNzbaKKmKxpqNmfTDWPfHxRmjmejd51d0xIxpegPGOjfa5yjCdXa5grIQdGpZcaijziVEGozkA7DEzyoAqPFngCAr41ktcdrYqE9a9L41d6A1EyIVeP2wWO6a4ZSaassgYRhOtMI2o40IWRvMegIKH86b6lXRxwNtkasaDbksuDa8zwaajjd51d0jtrBhCAr41ktcdrYqE9a9L41ZsYepyejQoa(mlaGKKH86b6KPOT3bly5l2Y1QLnjbAXPcyTUGKDAzCxu1Xu02KaT4ubSwxqYoTmsqgP9vckEq0am22xGVylxRw2KeOfNkG16cs2PLbygCgCW15V9HEb9a980W8dpVKH86b65D58wAhCAr41ktsgYRhOXd4YqskacGfenQoa(mlaGKKH86b6eKrAFLGE12UfHdot4LrCws31bNweETYKKH86b6lXRNuRVRV5ebSxMGIlqbvhaVOqYkImGok8DW2IWbNj8YiolPdeB7weo4mHxgXzjDxVFbrvhtrBtqx6BorATeuCbkjlTGzWPfHxRmjziVEG(s86bDPV5eP1sqXfOGQaT4WKOH5CiXFfvhaVOqYkImGok8GdUoVMyUCEA(5mVOLX84YcxoFVM59nyi0sBmFGXZlW6D5Z8oW8bgp)TlCXfzExopKBd6571mVSq4aZ385X8CmgoFTZhy88AHEb9a98hxgZdw6lk6BWmVlNVbV9tND40GtlcVwzsYqE9a9L41dWLHKuaealiAu9nyi0sBqCa85ctcYiTVs8Am40IWRvMKmKxpqFjE9aCzqkasGXeAyEWKWZziQc0IdtIgMZHe)vuDa8cmh0BgCAr41ktsgYRhOVeVEqgCgkzcwdrq1bWlW8esRlCxG50D9oVmmhDkCeMefbP1fOxhCW15VOsEE9l6BuN3J5P5NZ81EqpFgKBuMhPLbdrpVdmVUBpMhxuiz18UCED0DPMZh9H3GndoTi8ALjjd51d0xIxVStlqPScckUafufOfhMenmNdj(RO6a4ffswrKb0rHTTVq0hEJeMherHKvjE7SdBgCAr41ktsgYRhOVeVEsT(U(MteWEzckUaLbNbNweETYKmWtdZHhFZjgyNxlrR1kWgCAr41ktY4s86b4YqskacGfenQoa(Op8gjjd51d0jE7SdBSTfvDmfTnfLLaJuaed3bwcYiTVs6Op22G3qVZoCcRogsuMbhCD(lQKNN(II(E(ANpAyohY5P5bwzfZF7UHOmFbmFGXZJlG9YZB4mlaauN3bMxBjLE2HrD(EnZ7aZRzDrM3LZ3X8hULX8GmVKf1AKZ30A0doTi8ALjzCjE9GU03CI0AjO4cuqvGwCys0WCoK4VIQdGp6dVrsYqE9aDI3o7WgBBrvhtrBtrzjWifaXWDGLGms7RKoqSTbVHEND4ewDmKOmdoTi8ALjzCjE9GwsmFZj6M2WeA(Aq1bWNzbaKGwsmFZj6M2WeA(AsMI2EVfHdot4LrCws31bNweETYKmUeVEqgCgkzcwdrq1bWlW8esRlCxG50DDWPfHxRmjJlXRhGldsbqcmMqdZdMeEodrvGwCys0WCoK4VIQdGxG5GEZGtlcVwzsgxIxpEzyUJB(Mt4JRlhIQdGxG5GI)M78YWC0GspngCW15VOsEECH(Z7aZJUSMVH88ifKNpW6DEnMhxG5Z30A0ZdalK5rADnFVM5XAW55VopVmcAuNVGZ3qEEKcYZhy9o)15Xfy(8nTg98aWczEKwxdoTi8ALjzCjE9eyojZckduDa8cmpH06c3fyoDACVfHdot4LrCwI)QTTaZtiTUWDbMt31bhCD(lQKNxZB)5DG5rxwZ3qEE6F(copsb55fy(8nTg98aWczEKwxZ3RzEnRlY89AMNs3dxoFd55ZQaB(TI5T0o40IWRvMKXL41l8Cgs02heufOfhMenmNdj(RO6a4ffswrKb0rHVlW8esRlCxG50DZ9lyQifLLaJuaed3bwcYiTVY7zwaajzuqec3WaJ0RHa4qozkA7GtlcVwzsgxIxpbMtO1GZdoTi8ALjzCjE9KA9D9nNiG9YeuCbkO6a4ffswrKb0rHVNzbaKm9kysbqeyUUXtqUfXGdUo)fvYZRFrFpVdmFwfyZJllC589AMN(II(E(gYZVvmV4usg15l480xu03Z7Y5fNsYZ3RzECzHlN3LZVvmV4usE(EnZJUSMhRbNNhPG88bwVZdY8cmh15l484YcxoVlNxCkjpp9ff998UC(TI5fNsYZ3RzE0L18yn488ifKNpW6D(BMxG5OoFbNhDznpwdoppsb55dSENNEZlWCuNVGZ7aZJUSMpNJ5751clXGtlcVwzsgxIxVStlqPScckUafufOfhMenmNdj(RO6a4ffswrKb0rHVdwWg9H3ijziVEGoXBNDyJTTOQJPOTPOSeyKcGy4oWsqgP9vshi22G3qVZoCcRogsugWChSIQoMI2MGU03CI0AjO4cusqgP9vshi3fvDmfTnb4YqskacGfeDcYiTVs6aX2wu1Xu02e0L(MtKwlbfxGscYiTVsqV5UOQJPOTjaxgssbqaSGOtqgP9vs3n3fyoDGyBlQ6ykABc6sFZjsRLGIlqjbzK2xjD3Cxu1Xu02eGldjPaiawq0jiJ0(kb9M7cmNo632wG50rpWyBNzbaKYkuiAHLizPfmdoTi8ALjzCjE9cpNHeT9bbvbAXHjrdZ5qI)kQoaErHKvezaDu47cmpH06c3fyoDxhCW15VOsEECjf9989AM33GHqlTX8EmVmGTNJfZ30A0doTi8ALjzCjE9aoO9nNizOwEdckUafu9nyi0sBG)6GdUo)fvYZRFrFpVdmpUSWLZ7Y5fNsYZ3RzE0L18yn488GmVaZNVxZ8Oll48NwgZNFQS(mpTwoVM3(OoFbN3bMhDznFd557SYkMpQ5fT255LH5ONVxZ8ShymCE0LfC(tlJ5ZfM5P1Y5182F(coVdmp6YA(gYZFyPC(aR35bzEbMpFtRrppaSqMx0A16B(GtlcVwzsgxIxVStlqPScckUafufOfhMenmNdj(RO6a4ffswrKb0rHVdwrvhtrBtaUmKKcGaybrNGms7Re0BUlWC8GyBZldZrNchHjrrqADb6vWChSAHm4KCHjDnfEodjA7dITTaZtiTUWDbMdkiGrr1wbwbvuuocUqfQqPa]] )

end