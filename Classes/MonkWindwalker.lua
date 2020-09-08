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
    
    spec:RegisterPack( "Windwalker", 20200908, [[d4K(scqisv1JakAtkv9jLkIrbrCkGsVsPOzbvClis2Li)IuLHHK6ykLwgq6zkvAAKk4AKcTnis13uQOmosvX5uQqRJuHY8aI7bvTpKKdskiluPWdbkyIKQsDrsbvBeOqFuPIkgPsfjoPsfPwjuPxcrkMPsfj5MkvuPDsQ0pjfumusbLwkeP0trQPsk6QKQs2Qsfj1xvQOQXsQq1Ej5VigSQoSulwuEmHjtXLrTzaFwunAOCAQwnPc51quZwj3gs7wLFlz4KshxPcwoONt00fUoLSDGQVJeJNurNhcRNuG5tP2VIvBvAQOnDWkDbLAqPM6DKA9jrT(qT(q9oQOdeAzfT2wGCNZk6Rrzf9oVFgk9czgQO12iwvBuAQOLLfuWkASi0k1X0tVCpWSYsIcvpPJAT6WRtaBGqpPJk0trNz5RyN(uzkAthSsxqPguQPEhPwFsuRpuRpuRpkAPwwO0fuK(oQOXCJHpvMI2WsHIgmNFN3pdLEHmdNFNBDip4cMZJfHwPoME6L7bMvwsuO6jDuRvhEDcyde6jDuHEdUG580S2GrZy486doZdk1Gs9G7GlyopyaRVCwQJn4cMZJuZJ0YOf4880A5go)oL(mZthqhzEErDMWRtopsW6ZSyZ8ziMVnM6aBAWfmNhPMhmG1xopF0WCoioW8rnVaHyXKOH5CitdUG58i18iTmAboppFmmhX8Iw78cmwG88afCEWOld58fW8GrliI5rI0rN34aamKpbpVlN)48LN7zlgN5ZSI51UAeZBCaagYNGN3LZl98ZbCrFbytdUG58i18AiJHnZRVK8870bJkNhjb0pK5qIZ8CisGnn4cMZJuZRHmg2mFFvGXW53qddsZ8rnVgsdJg(8AHEb9aX8uW4BEeL18h3WfI5XAW55bSwR5bdyEsrVCzivAQOfgIKbuAQ0DRstfnFD2InQnu0cOhm0BfDMfaqsYq(8arYuuU5TTNhWZXccKrB)KZdY8GQrfDlcVofTFGxiZeDAXNku6cQstfnFD2InQnu0cOhm0BfnGNJfeiJ2(jNNQ53QpACEB751)8G3qVZwCcRwgsuM53pVOQLPOCPOSeyKcGy4oWsqgT9topi4NFRomVT98aEowqGmA7NCEqMFxKUIUfHxNIo3QHgVpsbqAnGHvGPcLU7Q0urZxNTyJAdfTa6bd9wrlQAzkkxkklbgPaigUdSeKrB)KZt18AuFM32EErvltr5srzjWifaXWDGLGmA7NCEqMh05TTNh8g6D2Ity1YqIYmVT98aEowqGmA7NCEqMhuQv0Ti86u0uk4Yao7hbYY66tWQqPRoO0urZxNTyJAdfTa6bd9wrlW8eARZ5rQ5fy(8uHF(TZVFE(yyoIu4OmjkcARZ5Pc)8uN0OIUfHxNIUHI(ysuqiFHku6QrLMkA(6SfBuBOOBr41POxwYawwssETm8r0USq7CwrlGEWqVv0IQwMIYLIYsGrkaIH7albz02p58Gm)25TTNxu1YuuUuuwcmsbqmChyjiJ2(jNNQ5bL65TTNh8g6D2Ity1YqIYmVT98aEowqGmA7NCEqWppOuROVgLv0llzalljjVwg(iAxwODoRcLUiDLMkA(6SfBuBOOBr41POZxTX7OGsckB61YRtrlGEWqVv0IQwMIYLIYsGrkaIH7albz02p58Gm)25TTNxu1YuuUuuwcmsbqmChyjiJ2(jNNQ5bL65TTNh8g6D2Ity1YqIYmVT98aEowqGmA7NCEqWppOuROzaaweKRrzfD(QnEhfusqztVwEDQqP7otPPIMVoBXg1gk6weEDk68vB8okOKWOzlgvrlGEWqVv0aEowqGmA7NCEQMFRg3X5TTNxu1YuuUuuwcmsbqmChyjiJ2(jNhK53oVT98G3qVZwCcRwgsugfndaWIGCnkROZxTX7OGscJMTyuvO0vFuAQO5RZwSrTHIwa9GHERO1)8G3qVZwCcRwgsuM53ppsMx)ZZ7GLRvlBsceIvfW6CbjB1YyEB75fvTmfLljqiwvaRZfKSvlJeKrB)KZdc(53opyNF)8izEbMppvZVDEB755JH5iMhK51bQNhSk6weEDk6OSeyKcGy4oWuHs3DuPPIMVoBXg1gkAb0dg6TIwu1YuuUKmkikHByGr6ZqaCiNeynmNLZJFEqN32EEtfPOSeyKcGy4oWsqgT9toVT98aEowqGmA7NCEqMhuQN32EEKmFMfaqIsbxgWz)iqwwxFcobz02p58un)wQN32EErvltr5suk4Yao7hbYY66tWjiJ2(jNNQ5fvTmfLljJcIs4ggyK(meahYjaR1IazbwdZzs4O8822ZR)5zPKpbNOuWLbC2pcKL11NGtOToQGZd253ppsMxu1YuuUuuwcmsbqmChyjiJ2(jNNQ5fvTmfLljJcIs4ggyK(meahYjaR1IazbwdZzs4O8822ZdEd9oBXjSAzirzMF)86FEEhSCTAztYa9SSLF5e)qwBzMhSZVFErvltr5saUmKKcGaybrKGmA7NCEqWp)oo)(5fy(8uHF(DNF)8IQwMIYLOG5WLF5edSZRJO16eyjiJ2(jNhe8ZVDxfDlcVofTmkikHByGr6ZqaCiRcLUBPwPPIMVoBXg1gkAb0dg6TIgWZXccKrB)KZt18B14ooVT98MksrzjWifaXWDGLGmA7NCEB75bVHENT4ewTmKOmk6weEDk6OSeyKcGGCdrBvO0D7wLMkA(6SfBuBOOfqpyO3kArvltr5srzjWifaXWDGLGmA7NCEQMxh04822ZdEd9oBXjSAzirzMF)8IQwMIYLaCzijfabWcIibz02p58GmpOZBBppGNJfeiJ2(jNhK53c6822Zd45ybbYOTFY5PA(Tut987NhWZXccKrB)KZdY8B3s987NhjZlQAzkkxcWLHKuaealiIeKrB)KZdY87oVT98IQwMIYLOG5WLF5edSZRJO16eyjiJ2(jNhK514822ZlQAzkkxc6s)YjsRJGSlqobz02p58GmVgNhSk6weEDk6SvvgsbqcmMWhJIqfkD3cQstfnFD2InQnu0cOhm0BfT(N3ursuNGVa2bBiaRgLjzwWlbz02p587NhjZJK5fvTmfLljQtWxa7GneGvJYjiJ2(jNhe8ZlQAzkkxkklbgPaigUdSeKrB)KZV58BN32EEWBO3zloHvldjkZ8GD(9ZJK51)8rV4lsuWC4YVCIb251r0ADcSeFD2InZBBpVOQLPOCjkyoC5xoXa786iATobwcYOTFY5b787Nxu1YuuUe0L(LtKwhbzxGCcYOTFY53pVOQLPOCjaxgssbqaSGisqgT9to)(5ZSaasYOGOeUHbgPpdbWHCYuuU5TTN3urkklbgPaigUdSeKrB)KZd25TTNhWZXccKrB)KZdY86JIUfHxNIwuNGVa2bBiaRgLvHs3T7Q0urZxNTyJAdfTa6bd9wrlQAzkkxkklbgPaigUdSeKrB)KZt187s9822ZdEd9oBXjSAzirzM32EEaphliqgT9topiZdk1k6weEDk6SvvgcGfeHku6UvhuAQO5RZwSrTHIwa9GHEROfvTmfLlfLLaJuaed3bwcYOTFY5PA(DPEEB75bVHENT4ewTmKOmZBBppGNJfeiJ2(jNhK53QrfDlcVofDgdLmez)YvHs3TAuPPIUfHxNIE55yHKOJSm5O8fkA(6SfBuBOcLUBr6knv081zl2O2qrlGEWqVv0IQwMIYLIYsGrkaIH7albz02p58un)UupVT98G3qVZwCcRwgsuM5TTNhWZXccKrB)KZdY8BPwr3IWRtrd4qoBvLrfkD3UZuAQO5RZwSrTHIwa9GHEROfvTmfLlfLLaJuaed3bwcYOTFY5PA(DPEEB75bVHENT4ewTmKOmZBBppGNJfeiJ2(jNhK5bLAfDlcVofDFcwgWEre9APcLUB1hLMk6weEDk6SoNuaKa6cKLkA(6SfBuBOcLUB3rLMkA(6SfBuBOOBr41PO1wcK5q6AaBiIcvRv0HxhXWG7cwrlGEWqVv0IQwMIYLIYsGrkaIH7albz02p58un)UupVT98G3qVZwCcRwgsugf91OSIwBjqMdPRbSHikuTwrhEDeddUlyvO0fuQvAQO5RZwSrTHIUfHxNIgYOvWKCl30NGjggCxWkAb0dg6TIwu1YuuUuuwcmsbqmChyjiJ2(jNNQ53L65TTNh8g6D2Ity1YqIYOOVgLv0qgTcMKB5M(emXWG7cwfkDbDRstfnFD2InQnu0Ti86u05R24DuqjjRn5SIwa9GHEROfvTmfLlfLLaJuaed3bwcYOTFY5PAEqPEEB75bVHENT4ewTmKOmZBBppGNJfeiJ2(jNhK5bLAfndaWIGCnkROZxTX7OGsswBYzvO0fuqvAQO5RZwSrTHIUfHxNIoVxSOxlgkjzvDkAb0dg6TIwu1YuuUuuwcmsbqmChyjiJ2(jNNQ51OgN32EEWBO3zloHvldjkZ822Zd45ybbYOTFY5bz(TGQOVgLv059If9AXqjjRQtfkDbDxLMkA(6SfBuBOOBr41POPa9aZVCIKZr5lifaXazz05DGPOfqpyO3kArvltr5srzjWifaXWDGLGmA7NCEQMhuQN32EEWBO3zloHvldjkJI(Auwrtb6bMF5ejNJYxqkaIbYYOZ7atfkDbvhuAQO5RZwSrTHIUfHxNIULyG3hljWwdkiruWEPOfqpyO3kAWBO3zlofLHuhXsYKa6hYCm)(5rY8IQwMIYLIYsGrkaIH7albz02p58unpOBN32EEWBO3zloHvldjkZ8GD(9ZJK5nCMfaqc2AqbjIc2lIHZSaasMIYnVT98zwaajzuquc3WaJ0NHa4qobz02p58un)2DN32EEaphliqgT9topsnVOQLPOCPOSeyKcGy4oWsqgT9topiZRdup)(5fvTmfLlfLLaJuaed3bwcYOTFY5bzEq14822Zd45ybbYOTFY5bzEq148GvrFnkROBjg49XscS1GcsefSxQqPlOAuPPIMVoBXg1gk6weEDk6wIbEFSKaBnOGerb7LIwa9GHERO1)8G3qVZwCkkdPoILKjb0pK5y(9ZJK5nCMfaqc2AqbjIc2lIHZSaasMIYnVT98izE9ppVdwUwTSjzGEw2YVCIFiRTmZBBpF0WCosHJYKOiAfbzxQNhK51N5b787NhjZBQifLLaJuaed3bwcYOTFY5TTNxu1YuuUuuwcmsbqmChyjiJ2(jNFZ53X5PAEaphliqgT9topyNF)8zwaajzuquc3WaJ0NHa4qozPDEB75b8CSGaz02p58GmpOACEWQOVgLv0Ted8(yjb2AqbjIc2lvO0fuKUstfDlcVofDGXeRlRSodbOGcwrZxNTyJAdvO0f0DMstfDlcVofTwlOdGWVCs2QLHIMVoBXg1gQqPlO6JstfnFD2InQnu0cOhm0BfD0WCosHJYKOiAfbbuQNNQ53L65TTNpAyohjmUxbwsRiMhe8Zdk1k6weEDkAi3A9lNaSAuwQcLUGUJknv0Ti86u0aLWsYgsRbm0dMKXnQIMVoBXg1gQqP7UuR0urZxNTyJAdfTa6bd9wrZhdZrmpiZRduROBr41POrz0cIGuaKLLWnedKBuPku6U7wLMk6weEDkAORv7Ij(rKABbRO5RZwSrTHku6UlOknv0Ti86u0zDoPaib0filv081zl2O2qfkD3DxLMkA(6SfBuBOOfqpyO3kAKmpVdwUwTSjjqiwvaRZfKSvlJ53pVOQLPOCjbcXQcyDUGKTAzKGmA7NCEqWppOuppyN32EE9ppVdwUwTSjjqiwvaRZfKSvldfDlcVofTLKjEWOsvOcfTHbARvO0uP7wLMk6weEDkAPwUHeS(mezaDKzfnFD2InQnuHsxqvAQO5RZwSrTHIU0QOLCOOBr41PObVHENTyfn49YIv0IQwMIYLIYsGrkaIH7albz02p58Bo)oopvZhnmNJu4OmjkIX55TTNx)Zh9IVijziFEGiXxNTyZ87Nx)ZdEd9oBXPOmK6iwsMeq)qMJ53ppVdwUwTSjzGEw2YVCIFiRTmZVF(OH5CKchLjrr0kcYUuppiZVDxQNF)8rdZ5ifoktIIOveKDPEEQMxFM32EEaphliqgT9topiZVDxQNF)8aEowqGmA7NCEQMxu1YuuUKKH85bIeKrB)KZVFErvltr5ssgYNhisqgT9topvZd6822ZNzbaKKmKppqKS0o)(5b8CSGaz02p58un)2TkAWBi5AuwrJvldjkJku6URstfnFD2InQnu0cOhm0BfDMfaqsYq(8arYs7822ZNzbaKKrbrjCddmsFgcGd5KL253pVPIuuwcmsbqmChyjiJ2(jN32EEaphliqgT9topi4NhPtTIUfHxNIwBfEDQqPRoO0urZxNTyJAdfTa6bd9wrlW8eARZ5rQ5fy(8uHFEqNF)8iz(Ox8fjjd5Zdej(6SfBM32EE9pVPIuuwcmsbqmChyjiJ2(jNhSZVF(mlaGKKH85bIKPOCZVFEKmpFmmhrkCuMefbT158Gm)25TTNp6fFrsYq(8arIVoBXM53pVOQLPOCjjd5ZdejiJ2(jNhK5bDEB751)8rV4lssgYNhis81zl2m)(5fvTmfLlfLLaJuaed3bwcYOTFY5bz(DNF)86FEWBO3zloHvldjkZ822ZZhdZrKchLjrrqBDopiZRdZVFErvltr5saUmKKcGaybrKGmA7NCEqMFBsJZdwfDlcVofnKbNHsMG1quvO0vJknv081zl2O2qr3IWRtrd4YGuaKaJjuW8GjHNZqfTa6bd9wrlW8eARZ5rQ5fy(8uHF(DNF)8zwaajjd5Zdejtr5MF)8zwaajjZbMF5eyNZjtr5MF)8izE(yyoIu4OmjkcARZ5bz(TZBBpF0l(IKKH85bIeFD2InZVFErvltr5ssgYNhisqgT9topiZd6822ZR)5JEXxKKmKppqK4RZwSz(9ZlQAzkkxkklbgPaigUdSeKrB)KZdY87o)(51)8G3qVZwCcRwgsuM5TTNNpgMJifoktIIG26CEqMxhMF)8IQwMIYLaCzijfabWcIibz02p58Gm)2KgNhSkAbcXIjrdZ5qQ0DRku6I0vAQO5RZwSrTHIUfHxNIo8Cgs02lufTa6bd9wrR)5ffAwrYGCJ887NxG5j0wNZJuZlW85Pc)8Go)(5rY8rV4lssgYNhis81zl2mVT986FEtfPOSeyKcGy4oWsqgT9toVT98TiCWzcFmQZY5PAEqNhSZVF(mlaGKK5aZVCcSZ5KPOCZVF(mlaGKKH85bIKPOCZVFEKmpFmmhrkCuMefbT158Gm)25TTNp6fFrsYq(8arIVoBXM53pVOQLPOCjjd5ZdejiJ2(jNhK5bDEB751)8rV4lssgYNhis81zl2m)(5fvTmfLlfLLaJuaed3bwcYOTFY5bz(DNF)86FEWBO3zloHvldjkZ822ZZhdZrKchLjrrqBDopiZRdZVFErvltr5saUmKKcGaybrKGmA7NCEqMFBsJZdwfTaHyXKOH5Civ6UvfkD3zknv081zl2O2qrlGEWqVv0cmFE8Zd687NxlKbNKlmPTPWZzirBVqNF)8HJYZdc(53vr3IWRtrlWCcLgCwfkD1hLMkA(6SfBuBOOfqpyO3kAbMpp(5bD(9ZRfYGtYfM02u45mKOTxOZVF(Wr55bb)87QOBr41POfyojZckdvO0DhvAQO5RZwSrTHIwa9GHEROfy(84Nh053pVwidojxysBtHNZqI2EHo)(5dhLNhe8ZVRIUfHxNIgyHWVCIKHA5lii7cKvHs3TuR0urZxNTyJAdfTa6bd9wrh9IVijziFEGiXxNTyJIUfHxNIw0RfPfHxhz5YqrVCzqUgLv0cdrYq(8aHku6UDRstfnFD2InQnu0cOhm0BfT(Np6fFrsYq(8arIVoBXgfDlcVofTOxlslcVoYYLHIE5YGCnkROfgIKbuHs3TGQ0urZxNTyJAdfTa6bd9wrNzbaKKmKppqKS0QOBr41POf9ArAr41rwUmu0lxgKRrzfTKH85bcvO0D7Uknv081zl2O2qrlGEWqVv0TiCWzcFmQZY5bz(Dv0Ti86u0IETiTi86ilxgk6LldY1OSIwgQqP7wDqPPIMVoBXg1gkAb0dg6TIUfHdot4JrDwopv4NFxfDlcVofTOxlslcVoYYLHIE5YGCnkRO7IvHku0AHSOqZ6qPPs3Tknv0Ti86u0ARWRtrZxNTyJAdvO0fuLMkA(6SfBuBOOlTkAjhk6weEDkAWBO3zlwrdEVSyfnVdwUwTSjjqiwvaRZfKSvlJ5TTNN3blxRw2KwwYawwssETm8r0USq7CEEB755DWY1QLnP8vB8okOKK1MCEEB755DWY1QLnP8vB8okOKGYMET86M32EEEhSCTAztcYOvWKCl30NGjggCxWkAWBi5AuwrhLHuhXsYKa6hYCOcLU7Q0urZxNTyJAdfDPvrl5qr3IWRtrdEd9oBXkAW7LfRO3UJkAb0dg6TIw)Zh9IVijziFEGiXxNTyZ87NhjZdEd9oBXPOmK6iwsMeq)qMJ5TTNN3blxRw2KAjg49XscS1GcsefSxZdwfn4nKCnkRObQlifarBrHHeTqwuOzDqey9D8sfkD1bLMkA(6SfBuBOOVgLv0TgiXAylja1fKcGOTOWqfDlcVofDRbsSg2scqDbPaiAlkmufkD1OstfnFD2InQnu0cOhm0BfD0l(IeGldsbqcmMqbZdMeEodt81zl2mVT98SuYNGtI6awUii9ziYa6aCcT1rfur3IWRtrlWCcLgCwfkDr6knv0Ti86u0(bEHmt0PfFkA(6SfBuBOcLU7mLMk6weEDk6CRgA8(ifaP1agwbMIMVoBXg1gQqfk6UyLMkD3Q0ur3IWRtrtbZHl)YjgyNxhrR1jWu081zl2O2qfkDbvPPIMVoBXg1gkAb0dg6TIw)ZRfYGtYfM02u45mKOTxOZVFEbMppi4NF787NNpgMJyEqMxJuROBr41PO5JH5Ug4xoHxUoDOku6URstfnFD2InQnu0cOhm0BfnFmmhrkCuMefbT158un)wfDlcVofnGldjPaiawqeQqPRoO0urZxNTyJAdfDlcVofn0L(LtKwhbzxGSIwa9GHEROrY8rV4lsuWC4YVCIb251r0ADcSeFD2InZVFErvltr5sqx6xorADeKDbYjJfSdVU5PAErvltr5suWC4YVCIb251r0ADcSeKrB)KZV586W8GD(9ZJK5fvTmfLlb4YqskacGfercYOTFY5PA(DN32EEbMppv4NxJZdwfTaHyXKOH5Civ6UvfkD1OstfnFD2InQnu0cOhm0BfDMfaqcAjX8lNOJAdtO4NjzkkNIUfHxNIgAjX8lNOJAdtO4NrfkDr6knv081zl2O2qrlGEWqVv0IcnRiYa6iZZVFEKmpsMhjZlW85PA(DN32EErvltr5saUmKKcGaybrKGmA7NCEQMhPppyNF)8izEbMppv4NxJZBBpVOQLPOCjaxgssbqaSGisqgT9topvZd68GDEWoVT988XWCePWrzsue0wNZdc(53DEB75ZSaasM(emPaicmxh5ji3IyEWQOBr41POLA978lNiG9XeKDbYQqP7otPPIMVoBXg1gkAb0dg6TIwG5j0wNZJuZlW85Pc)8GQOBr41POHm4muYeSgIQcLU6JstfnFD2InQnu0cOhm0BfTaZtOToNhPMxG5Ztf(53QOBr41POfyojZckdvO0DhvAQO5RZwSrTHIUfHxNIgWLbPaibgtOG5btcpNHkAb0dg6TIwG5j0wNZJuZlW85Pc)87QOfielMenmNdPs3TQqP7wQvAQO5RZwSrTHIUfHxNIo8Cgs02lufTa6bd9wrlW8eARZ5rQ5fy(8uHFEqNF)8izE9pF0l(IeMherHMvj(6SfBM32EE9pVOqZksgKBKNhSkAbcXIjrdZ5qQ0DRku6UDRstfnFD2InQnu0cOhm0BfT(NxuOzfjdYnYk6weEDkAbMtO0GZQqP7wqvAQO5RZwSrTHIUfHxNIgyHWVCIKHA5lii7cKv0cOhm0BfDMfaqkRqMOfwIKPOCkA)cgcT0gk6TQqP72DvAQO5RZwSrTHIUfHxNIoB1cKlRGGSlqwrlGEWqVv0IcnRiYa6iZZVFEKmFMfaqkRqMOfwIKL25TTNhjZh9IViH5bruOzvIVoBXM53pVwidojxysBtHNZqI2EHo)(5fy(8GmVompyN32EEbMNqBDopsnVaZNhK5bDEWQOfielMenmNdPs3TQqfkAHHiziFEGqPPs3Tknv081zl2O2qrlGEWqVv0zwaajjd5Zdejtr5M32EEaphliqgT9topiZdQgv0Ti86u0(bEHmt0PfFQqPlOknv081zl2O2qr3IWRtr3AGeRHTKauxqkaI2Icdv0cOhm0BfDMfaqsYq(8arYuuU53ppsMxu1YuuUKKH85bIeKrB)KZdY8Gs9822Zd45ybbYOTFY5bzEDG65bRI(Auwr3AGeRHTKauxqkaI2IcdvHs3DvAQO5RZwSrTHIwa9GHEROZSaassgYNhisMIYn)(5rY8aEowqGmA7NCEQMFR(OX5TTNxu1YuuUKKH85bIeKrB)KZdc(53zZd25TTNhWZXccKrB)KZdY87QrfDlcVofDUvdnEFKcG0AadRatfkD1bLMkA(6SfBuBOOfqpyO3kArvltr5ssgYNhisqgT9topvZdk1ZBBppGNJfeiJ2(jNhK5bLAfDlcVofD2QkdbWcIqfkD1OstfnFD2InQnu0cOhm0BfTOQLPOCjjd5ZdejiJ2(jNNQ5bL65TTNhWZXccKrB)KZdY8B1OIUfHxNIoJHsgISF5QqPlsxPPIMVoBXg1gkAb0dg6TIoZcaijziFEGizkk387NxG5j0wNZJuZlW85Pc)8BNF)88XWCePWrzsue0wNZtf(5PoPrfDlcVofDdf9XKOGq(cvO0DNP0ur3IWRtrV8CSqs0rwMCu(cfnFD2InQnuHsx9rPPIMVoBXg1gkAb0dg6TIwu1YuuUKKH85bIeKrB)KZt18Gs9822Zd45ybbYOTFY5bz(TuROBr41PObCiNTQYOcLU7OstfnFD2InQnu0cOhm0BfTOQLPOCjjd5ZdejiJ2(jNNQ5bL65TTNhWZXccKrB)KZdY8GsTIUfHxNIUpbldyViIETuHs3TuR0ur3IWRtrN15KcGeqxGSurZxNTyJAdvO0D7wLMkA(6SfBuBOOBr41POxwYawwssETm8r0USq7CwrlGEWqVv0IQwMIYLIYsGrkaIH7albz02p58Gm)25TTNxu1YuuUuuwcmsbqmChyjiJ2(jNNQ5bL65TTNh8g6D2Ity1YqIYmVT98aEowqGmA7NCEqWppOuROVgLv0llzalljjVwg(iAxwODoRcLUBbvPPIMVoBXg1gk6weEDk68vB8okOKGYMET86u0cOhm0BfTOQLPOCPOSeyKcGy4oWsqgT9topiZVDEB75fvTmfLlfLLaJuaed3bwcYOTFY5PAEqPEEB75bVHENT4ewTmKOmZBBppGNJfeiJ2(jNhe8Zdk1kAgaGfb5AuwrNVAJ3rbLeu20RLxNku6UDxLMkA(6SfBuBOOBr41POZxTX7OGscJMTyufTa6bd9wrd45ybbYOTFY5PA(TAChN32EErvltr5srzjWifaXWDGLGmA7NCEqMF7822ZdEd9oBXjSAzirzu0maalcY1OSIoF1gVJckjmA2IrvHs3T6GstfnFD2InQnu0cOhm0BfT(Nh8g6D2Ity1YqIYOOBr41POJYsGrkaIH7atfkD3QrLMkA(6SfBuBOOfqpyO3kAaphliqgT9topvZVvJ74822ZBQifLLaJuaed3bwcYOTFY5TTNh8g6D2Ity1YqIYOOBr41POJYsGrkacYneTvHs3TiDLMkA(6SfBuBOOBr41PO1wcK5q6AaBiIcvRv0HxhXWG7cwrlGEWqVv0zwaajjd5Zdejtr5MF)8izErvltr5srzjWifaXWDGLGmA7NCEQMFl1ZBBpp4n07SfNWQLHeLzEWoVT98aEowqGmA7NCEqMxJk6RrzfT2sGmhsxdydruOATIo86iggCxWQqP72DMstfnFD2InQnu0cOhm0BfDMfaqsYq(8arYuuU53ppsMxu1YuuUKKH85bIeKrB)KZt18Gs9822ZlQAzkkxsYq(8arcYOTFY5bzEqNhSZBBppGNJfeiJ2(jNhK53QrfDlcVofD2QkdPaibgt4JrrOcLUB1hLMkA(6SfBuBOOBr41POHmAfmj3Yn9jyIHb3fSIwa9GHEROfvTmfLlfLLaJuaed3bwcYOTFY5PA(TupVT98G3qVZwCcRwgsugf91OSIgYOvWKCl30NGjggCxWQqP72DuPPIMVoBXg1gk6weEDk68vB8okOKK1MCwrlGEWqVv0IQwMIYLKmKppqKGmA7NCEQMhuQN32EEaphliqgT9topiZdk1kAgaGfb5AuwrNVAJ3rbLKS2KZQqPlOuR0urZxNTyJAdfDlcVofDEVyrVwmusYQ6u0cOhm0BfTOQLPOCjjd5ZdejiJ2(jNNQ5bL65TTNhWZXccKrB)KZdY8GsTI(AuwrN3lw0RfdLKSQovO0f0Tknv081zl2O2qr3IWRtrtb6bMF5ejNJYxqkaIbYYOZ7atrlGEWqVv0IQwMIYLIYsGrkaIH7albz02p58un)wQN32EEWBO3zloHvldjkJI(Auwrtb6bMF5ejNJYxqkaIbYYOZ7atfkDbfuLMkA(6SfBuBOOBr41POBjg49XscS1GcsefSxkAb0dg6TI2WzwaajyRbfKikyVigoZcaizkk3822ZNzbaKKmKppqKGmA7NCEQMFhN32EEaphliqgT9topiZdQgv0xJYk6wIbEFSKaBnOGerb7Lku6c6Uknv081zl2O2qrlGEWqVv0zwaajjd5Zdejtr5MF)8izErvltr5ssgYNhisqgT9topvZVvJZBBpVOQLPOCjjd5ZdejiJ2(jNhK5bDEWoVT98aEowqGmA7NCEqMhuQv0Ti86u0uk4Yao7hbYY66tWQqPlO6GstfnFD2InQnu0cOhm0BfDMfaqsYq(8arYuuU53ppsMxu1YuuUKKH85bIeKrB)KZBBpVOQLPOCjrDc(cyhSHaSAuojWAyolNh)8GopyNF)86FEtfjrDc(cyhSHaSAuMKzbVeKrB)KZVFEKmVOQLPOCjOl9lNiTocYUa5eKrB)KZVFErvltr5saUmKKcGaybrKGmA7NCEB75b8CSGaz02p58GmV(mpyv0Ti86u0I6e8fWoydby1OSku6cQgvAQOBr41POLmKppqOO5RZwSrTHku6cksxPPIMVoBXg1gkAb0dg6TIoZcaijziFEGizkkNIUfHxNIoWyI1LvwNHauqbRcLUGUZuAQO5RZwSrTHIwa9GHEROZSaassgYNhisMIYPOBr41PO1AbDae(LtYwTmuHsxq1hLMkA(6SfBuBOOfqpyO3k6mlaGKKH85bIKPOCZVFEKmF0WCosHJYKOiAfbbuQNNQ53L65TTNpAyohjmUxbwsRiMhe8Zdk1Zd25TTNpAyohPWrzsueJZZdY8GQOBr41POHCR1VCcWQrzPku6c6oQ0urZxNTyJAdfTa6bd9wrNzbaKKmKppqKmfLtr3IWRtrducljBiTgWqpysg3OQqP7UuR0urZxNTyJAdfTa6bd9wrNzbaKKmKppqKmfLB(9ZZhdZrmpiZRduROBr41POrz0cIGuaKLLWnedKBuPku6U7wLMkA(6SfBuBOOfqpyO3k6mlaGKKH85bIKPOCk6weEDkAORv7Ij(rKABbRcLU7cQstfnFD2InQnu0cOhm0BfDMfaqsYq(8arYuuofDlcVofDwNtkasaDbYsvO0D3DvAQO5RZwSrTHIwa9GHEROZSaassgYNhisMIYn)(5rY8izEEhSCTAztsGqSQawNlizRwgZVFErvltr5sceIvfW6CbjB1Yibz02p58GGFEqPEEWoVT986FEEhSCTAztsGqSQawNlizRwgZdwfDlcVofTLKjEWOsvOcfTmuAQ0DRstfDlcVofnfmhU8lNyGDEDeTwNatrZxNTyJAdvO0fuLMkA(6SfBuBOOfqpyO3k6Ox8fjjd5Zdej(6SfBM32EErvltr5srzjWifaXWDGLGmA7NCEQMhPpVT98G3qVZwCcRwgsugfDlcVofnGldjPaiawqeQqP7Uknv081zl2O2qr3IWRtrdDPF5eP1rq2fiROfqpyO3k6Ox8fjjd5Zdej(6SfBM32EErvltr5srzjWifaXWDGLGmA7NCEQMh05TTNh8g6D2Ity1YqIYOOfielMenmNdPs3TQqPRoO0urZxNTyJAdfTa6bd9wrNzbaKGwsm)Yj6O2Wek(zsMIYn)(5Br4GZe(yuNLZt18Bv0Ti86u0qljMF5eDuBycf)mQqPRgvAQO5RZwSrTHIwa9GHEROfyEcT158i18cmFEQMFRIUfHxNIgYGZqjtWAiQku6I0vAQO5RZwSrTHIUfHxNIgWLbPaibgtOG5btcpNHkAb0dg6TIwG5ZdY87QOfielMenmNdPs3TQqP7otPPIMVoBXg1gkAb0dg6TIwG5Zdc(53D(9ZZhdZrmpiZRrQv0Ti86u08XWCxd8lNWlxNoufkD1hLMkA(6SfBuBOOfqpyO3kAbMNqBDopsnVaZNNQ5PE(9Z3IWbNj8XOolNh)8BN32EEbMNqBDopsnVaZNNQ53QOBr41POfyojZckdvO0DhvAQO5RZwSrTHIUfHxNIo8Cgs02lufTa6bd9wrlk0SIidOJmp)(5fyEcT158i18cmFEQMF353pV(N3urkklbgPaigUdSeKrB)KZVF(mlaGKmkikHByGr6ZqaCiNmfLtrlqiwmjAyohsLUBvHs3TuR0ur3IWRtrlWCcLgCwrZxNTyJAdvO0D7wLMkA(6SfBuBOOfqpyO3kArHMvezaDK553pFMfaqY0NGjfarG56ipb5wek6weEDkAPw)o)YjcyFmbzxGSku6UfuLMkA(6SfBuBOOBr41POZwTa5Ykii7cKv0cOhm0BfTOqZkImGoY887NhjZJK5JEXxKKmKppqK4RZwSzEB75fvTmfLlfLLaJuaed3bwcYOTFY5PAEqN32EEWBO3zloHvldjkZ8GD(9ZJK5fvTmfLlbDPF5eP1rq2fiNGmA7NCEQMh053pVOQLPOCjaxgssbqaSGisqgT9topvZd6822ZlQAzkkxc6s)YjsRJGSlqobz02p58Gm)UZVFErvltr5saUmKKcGaybrKGmA7NCEQMF353pVaZNNQ5bDEB75fvTmfLlbDPF5eP1rq2fiNGmA7NCEQMF353pVOQLPOCjaxgssbqaSGisqgT9topiZV787NxG5Zt186W822ZlW85PAEnopyN32E(mlaGuwHmrlSejlTZdwfTaHyXKOH5Civ6UvfkD3URstfnFD2InQnu0Ti86u0HNZqI2EHQOfqpyO3kArHMvezaDK553pVaZtOToNhPMxG5Zt18Bv0ceIftIgMZHuP7wvO0DRoO0ur7xWqOL2qrVvr3IWRtrdSq4xorYqT8feKDbYkA(6SfBuBOcLUB1OstfnFD2InQnu0Ti86u0zRwGCzfeKDbYkAb0dg6TIwuOzfrgqhzE(9ZJK5fvTmfLlb4YqskacGfercYOTFY5bz(DNF)8cmFE8Zd6822ZZhdZrKchLjrrqBDopiZVDEWo)(5rY8AHm4KCHjTnfEodjA7f6822ZlW8eARZ5rQ5fy(8GmpOZdwfTaHyXKOH5Civ6UvfQqrlziFEGqPPs3Tknv081zl2O2qrlGEWqVv0zwaajjd5ZdejiJ2(jNhK53oVT98TiCWzcFmQZY5PA(Tk6weEDkAaxgssbqaSGiuHsxqvAQO5RZwSrTHIwa9GHEROffAwrKb0rMNF)8iz(weo4mHpg1z58unpOZBBpFlchCMWhJ6SCEQMF787Nx)ZlQAzkkxc6s)YjsRJGSlqozPDEWQOBr41POLA978lNiG9XeKDbYQqP7Uknv081zl2O2qr3IWRtrdDPF5eP1rq2fiROfqpyO3kArHMvezaDKzfTaHyXKOH5Civ6UvfkD1bLMkA)cgcT0gehqrNlmjiJ2(jXtTIUfHxNIgWLHKuaealicfnFD2InQnuHsxnQ0urZxNTyJAdfDlcVofnGldsbqcmMqbZdMeEodv0cOhm0BfTaZNhK53vrlqiwmjAyohsLUBvHsxKUstfnFD2InQnu0cOhm0BfTaZtOToNhPMxG5Zt18BNF)88XWCePWrzsue0wNZdY8Bv0Ti86u0qgCgkzcwdrvHs3DMstfnFD2InQnu0Ti86u0zRwGCzfeKDbYkAb0dg6TIwuOzfrgqhzEEB751)8rV4lsyEqefAwL4RZwSrrlqiwmjAyohsLUBvHsx9rPPIUfHxNIwQ1VZVCIa2htq2fiRO5RZwSrTHkuHku0GZqPxNsxqPguQPwFOgufnLgE(Llv078AiKwD3P1DNJo28ZRjgpVJQTGX8afC(DIWqKmWozEiVdwoKnZlluE(2kk0oyZ8cS(YzzAWDNk)45bvJ6yZdgQdCggSz(Ds4OmjkIwrq0X1XtqgT9tUtMpQ53jHJYKOiAfbrhxhFNmps2QtWMgChC351qiT6UtR7ohDS5NxtmEEhvBbJ5bk487edd0wRyNmpK3blhYM5LfkpFBffAhSzEbwF5Smn4UtLF88GQJnpyOoWzyWM53jHJYKOiAfbrhxhpbz02p5oz(OMFNeoktIIOveeDCD8DY8ibuDc20G7G7onQ2cgSz(D28Ti86MF5YqMgCv0TvGvqfnTJcgu0AHfGVyfnyo)oVFgk9czgo)o36qEWfmNhlcTsDm90l3dmRSKOq1t6OwRo86eWgi0t6Oc9gCbZ5PzTbJMXW51hCMhuQbL6b3bxWCEWawF5SuhBWfmNhPMhPLrlW55P1YnC(Dk9zMNoGoY88I6mHxNCEKG1NzXM5ZqmFBm1b20GlyopsnpyaRVCE(OH5CqCG5JAEbcXIjrdZ5qMgCbZ5rQ5rAz0cCEE(yyoI5fT25fySa55bk48GrxgY5lG5bJwqeZJePJoVXbayiFcEExo)X5lp3ZwmoZNzfZRD1iM34aamKpbpVlNx65Nd4I(cWMgCbZ5rQ51qgdBMxFj553PdgvopscOFiZHeN55qKaBAWfmNhPMxdzmSz((QaJHZVHggKM5JAEnKggn851c9c6bI5PGX38ikR5pUHleZJ1GZZdyTwZdgW80G7GlyoVgUozHvWM5ZyGcYZlk0SoMpJZ9tMMxdjeS2qo)vhsH1quaR18Ti86KZx3crAWfmNVfHxNmPfYIcnRd8aRwI8GlyoFlcVozslKffAwhBIxpGQmdUG58Ti86KjTqwuOzDSjE9ARCu(Io86gCbZ5PVwReRI5HTBMpZcaGnZlJoKZNXafKNxuOzDmFgN7NC((mZRfYiL2kc)YN3LZBQJtdUG58Ti86KjTqwuOzDSjE9KxRvIvbrgDihCBr41jtAHSOqZ6yt86PTcVUbxWCEWaglqwoVdmpIYAESgCE(E(a6hYCmpVdwUwTSz(aRJ5P0xiNpQ5Z45TKSz(OY5aJHZtXdS51S03dUTi86KjTqwuOzDSjE9aVHENTyCUgLXhLHuhXsYKa6hYCGtPfVKdCaVxwmEEhSCTAztsGqSQawNlizRwg228oy5A1YM0YsgWYssYRLHpI2LfANZ228oy5A1YMu(QnEhfusYAtoBBZ7GLRvlBs5R24DuqjbLn9A51zBZ7GLRvlBsqgTcMKB5M(emXWG7cEWTfHxNmPfYIcnRJnXRh4n07SfJZ1OmEG6csbq0wuyirlKffAwhebwFhVWP0IxYboG3llg)2DehhaV(JEXxKKmKppqK4RZwSzpsaVHENT4uugsDeljtcOFiZHTnVdwUwTSj1smW7JLeyRbfKikyVa7GBlcVozslKffAwhBIxpljt8GrX5AugFRbsSg2scqDbPaiAlkmCWTfHxNmPfYIcnRJnXRNaZjuAWzCCa8rV4lsaUmifajWycfmpys45mmXxNTyJTnlL8j4KOoGLlcsFgImGoaNqBDubhCBr41jtAHSOqZ6yt865h4fYmrNw8rcmMqbZdMeEodhCBr41jtAHSOqZ6yt86LB1qJ3hPaiTgWWkWgChCbZ51W1jlSc2mpdodrmF4O88bgpFlIcoVlNVbV9vNT40GBlcVojEPwUHeS(mezaDK5bxWCE9LKNxBfEDZ7aZtZq(8aX8UCElT4mFbNpRcS5P1WbJZ3NzEnl998nKN3sloZxW5dmE(OH5CmpfFTM3488u8aZV5r6upVKf1zKdUG587u3qVZw88bwhZtXxR5dETMhrznVdmpIYAEk(An)XSz(OMNs7X8rnVOLX8Aw6B9m18xfZtPVy(OMx0YyEpMVJ571A((qGwqEWTfHxNCt86bEd9oBX4CnkJhRwgsugCkT4LCGd49YIXlQAzkkxkklbgPaigUdSeKrB)KBUJufnmNJu4OmjkIXzBB9h9IVijziFEGiXxNTyZE9dEd9oBXPOmK6iwsMeq)qMJ98oy5A1YMKb6zzl)Yj(HS2YSpAyohPWrzsueTIGSl1jiJ2(jbz7UuVpAyohPWrzsueTIGSl1jiJ2(jPsFSTb8CSGaz02pjiB3L69aEowqGmA7NKkrvltr5ssgYNhisqgT9tUxu1YuuUKKH85bIeKrB)KubQTDMfaqsYq(8arYs7EaphliqgT9ts12TdUG586ljpV2k86M3bMNMH85bI5D58wAXz(coFwfyZtRHdgNVpZ8Aw675BipVLwCMVGZhy88rdZ5yEk(AnVX55P4bMFZJ0PEEjlQZihCBr41j3eVEARWRdhhaFMfaqsYq(8arYsRTDMfaqsgfeLWnmWi9ziaoKtwA3BQifLLaJuaed3bwcYOTFsBBaphliqgT9tccEKo1dUTi86KBIxpidodLmbRHO44a4fyEcT1jsjWCQWd6EKe9IVijziFEGiXxNTyJTT(nvKIYsGrkaIH7albz02pjy3NzbaKKmKppqKmfLBps4JH5isHJYKOiOTobzRTD0l(IKKH85bIeFD2In7fvTmfLljziFEGibz02pjiGABR)Ox8fjjd5Zdej(6SfB2lQAzkkxkklbgPaigUdSeKrB)KGS7E9dEd9oBXjSAzirzST5JH5isHJYKOiOTobrh2lQAzkkxcWLHKuaealiIeKrB)KGSnPrWo4cMZRVK88GXk251CEhy(5ruwZ3qEEuxk9lF(oMFXTmMF35fyooZRHoZ8ZlziFEGaN51qNz(53Ocn85Bip)vX8wAXzEnKU675ruwZZEGXW5BipFNvwX8rnVO1opFmmhboZxW5LmKppqmVlNVZkRy(OMxuO88wAXz(coVML(EExoFNvwX8rnVOq55T0IZ8fCEWybgN3LZlku)YN3s789zMhrznpfFTMx0ANNpgMJyEzv3GBlcVo5M41dWLbPaibgtOG5btcpNH4iqiwmjAyohs8BXXbWlW8eARtKsG5uHF39zwaajjd5Zdejtr52NzbaKKmhy(LtGDoNmfLBps4JH5isHJYKOiOTobzRTD0l(IKKH85bIeFD2In7fvTmfLljziFEGibz02pjiGABR)Ox8fjjd5Zdej(6SfB2lQAzkkxkklbgPaigUdSeKrB)KGS7E9dEd9oBXjSAzirzST5JH5isHJYKOiOTobrh2lQAzkkxcWLHKuaealiIeKrB)KGSnPrWo4cMZRVK88AQHDEhyEpMNsDX8zqUrEE0wgmeboZRH0vFpFd55rDP0V857y(f3YyEqNxG54mVgsx998zE(8IQwMIYjNVH88xfZBPfN51q6QVNhrznp7bgdNVH88DwzfZh18Iw788XWCe4mFbNxYq(8aX8UC(oRSI5JAErHYZBPfN5l48Aw675D58Ic1V85T0IZ8fCEWybgN3LZlku)YN3s789zMhrznpfFTMx0ANNpgMJyEzv3GBlcVo5M41l8Cgs02luCeielMenmNdj(T44a41VOqZksgKBK3lW8eARtKsG5uHh09ij6fFrsYq(8arIVoBXgBB9BQifLLaJuaed3bwcYOTFsB7weo4mHpg1zjvGc29zwaajjZbMF5eyNZjtr52NzbaKKmKppqKmfLBps4JH5isHJYKOiOTobzRTD0l(IKKH85bIeFD2In7fvTmfLljziFEGibz02pjiGABR)Ox8fjjd5Zdej(6SfB2lQAzkkxkklbgPaigUdSeKrB)KGS7E9dEd9oBXjSAzirzST5JH5isHJYKOiOTobrh2lQAzkkxcWLHKuaealiIeKrB)KGSnPrWo42IWRtUjE9eyoHsdoJJdGxG54bDVwidojxysBtHNZqI2EHUpCuge87o42IWRtUjE9eyojZckdCCa8cmhpO71czWj5ctABk8Cgs02l09HJYGGF3b3weEDYnXRhWcHF5ejd1Yxqq2fiJJdGxG54bDVwidojxysBtHNZqI2EHUpCuge87o42IWRtUjE9e9ArAr41rwUmW5AugVWqKmKppqGJdGp6fFrsYq(8arIVoBXMb3weEDYnXRNOxlslcVoYYLboxJY4fgIKbWXbWR)Ox8fjjd5Zdej(6SfBgCbZ5bd9AnFGXZtZq(8aX8Ti86MF5YyEhyEAgYNhiM3LZlSGq(IfI5T0o42IWRtUjE9e9ArAr41rwUmW5AugVKH85bcCCa8zwaajjd5ZdejlTdUG58GHETMpW45P1C(weEDZVCzmVdmFGXqE(gYZd68fC(flLZZhJ6SCWTfHxNCt86j61I0IWRJSCzGZ1OmEzGJdGVfHdot4JrDwcYUdUG58GHETMpW451qLg(8Ti86MF5YyEhy(aJH88nKNF35l48OfKNNpg1z5GBlcVo5M41t0RfPfHxhz5YaNRrz8DX44a4Br4GZe(yuNLuHF3b3bxWCEnKi86KjnuPHpVlN3VGpdBMhOGZBj55P4b287uyr4cIgYyiGHf3GZZ3NzEHfeYxSqm)XSroFuZNXZxAdh11a2m42IWRtM6IXtbZHl)YjgyNxhrR1jWgCBr41jtDXBIxp(yyURb(Lt4LRthIJdGx)AHm4KCHjTnfEodjA7f6EbMdc(T75JH5iarJup42IWRtM6I3eVEaUmKKcGaybrGJdGNpgMJifoktIIG26KQTdUTi86KPU4nXRh0L(LtKwhbzxGmoceIftIgMZHe)wCCa8ij6fFrIcMdx(LtmWoVoIwRtGL4RZwSzVOQLPOCjOl9lNiTocYUa5KXc2HxhvIQwMIYLOG5WLF5edSZRJO16eyjiJ2(j3uha7EKiQAzkkxcWLHKuaealiIeKrB)KuTRTTaZPcVgb7GBlcVozQlEt86bTKy(Lt0rTHju8ZGJdGpZcaibTKy(Lt0rTHju8ZKmfLBWTfHxNm1fVjE9KA978lNiG9XeKDbY44a4ffAwrKb0rM3JeKGebMt1U22IQwMIYLaCzijfabWcIibz02pjviDWUhjcmNk8A02wu1YuuUeGldjPaiawqejiJ2(jPcuWcwBB(yyoIu4OmjkcARtqWVRTDMfaqY0NGjfarG56ipb5weGDWTfHxNm1fVjE9Gm4muYeSgIIJdGxG5j0wNiLaZPcpOdUG58GbliKVyHyEWaMp)gwqzmVlNVxuAeY5ZDW9lF(TZlW859BEPJkMNbNV5DG59yEmpKZJwqE(aRV53oF0WCoMxwZVtpVKJ5dmxoFuZVDWTfHxNm1fVjE9eyojZckdCCa8cmpH26ePeyov43o42IWRtM6I3eVEaUmifajWycfmpys45mehbcXIjrdZ5qIFlooaEbMNqBDIucmNk87o42IWRtM6I3eVEHNZqI2EHIJaHyXKOH5CiXVfhhaVaZtOTorkbMtfEq3Je9h9IViH5bruOzvIVoBXgBB9lk0SIKb5gzWo42IWRtM6I3eVEcmNqPbNXXbWRFrHMvKmi3ip42IWRtM6I3eVEale(LtKmulFbbzxGmooa(mlaGuwHmrlSejtr5WXVGHqlTb(TdUTi86KPU4nXRx2QfixwbbzxGmoceIftIgMZHe)wCCa8IcnRiYa6iZ7rsMfaqkRqMOfwIKLwBBKe9IViH5bruOzvIVoBXM9AHm4KCHjTnfEodjA7f6EbMdIoawBBbMNqBDIucmheqb7G7GlyopyOQLPOCYb3weEDYKWqKmaE)aVqMj60IpsGXekyEWKWZziooa(mlaGKKH85bIKPOC22aEowqGmA7Neeq14GBlcVozsyisgyt86LB1qJ3hPaiTgWWkWWXbWd45ybbYOTFsQ2QpA02w)G3qVZwCcRwgsuM9IQwMIYLIYsGrkaIH7albz02pji43Qd22aEowqGmA7NeKDr6dUTi86KjHHizGnXRhLcUmGZ(rGSSU(emooaErvltr5srzjWifaXWDGLGmA7NKknQp22IQwMIYLIYsGrkaIH7albz02pjiGABdEd9oBXjSAzirzSTb8CSGaz02pjiGs9GlyoV(sYZRHGI(451SGq(I5DG5ruwZ3qEEuxk9lF(oMFXTmMF78GbmF((mZtPUDsmVO1opFmmhX8u8aZV5PoPX5LSOoJCWTfHxNmjmejdSjE9AOOpMefeYxGJdGxG5j0wNiLaZPc)298XWCePWrzsue0wNuHN6KghCBr41jtcdrYaBIxpljt8GrX5Aug)YsgWYssYRLHpI2LfANZ44a4fvTmfLlfLLaJuaed3bwcYOTFsq2ABlQAzkkxkklbgPaigUdSeKrB)Kubk122G3qVZwCcRwgsugBBaphliqgT9tccEqPEWTfHxNmjmejdSjE9SKmXdgfhgaGfb5AugF(QnEhfusqztVwED44a4fvTmfLlfLLaJuaed3bwcYOTFsq2ABlQAzkkxkklbgPaigUdSeKrB)Kubk122G3qVZwCcRwgsugBBaphliqgT9tccEqPEWTfHxNmjmejdSjE9SKmXdgfhgaGfb5AugF(QnEhfusy0SfJIJdGhWZXccKrB)KuTvJ7OTTOQLPOCPOSeyKcGy4oWsqgT9tcYwBBWBO3zloHvldjkZGBlcVozsyisgyt86fLLaJuaed3bgooaE9dEd9oBXjSAzirz2Je9Z7GLRvlBsceIvfW6CbjB1YW2wu1YuuUKaHyvbSoxqYwTmsqgT9tcc(TGDpseyovBTT5JH5iarhOgSdUTi86KjHHizGnXRNmkikHByGr6ZqaCiJdooaErvltr5sYOGOeUHbgPpdbWHCsG1WCwIhuBBtfPOSeyKcGy4oWsqgT9tABd45ybbYOTFsqaLABBKKzbaKOuWLbC2pcKL11NGtqgT9ts1wQTTfvTmfLlrPGld4SFeilRRpbNGmA7NKkrvltr5sYOGOeUHbgPpdbWHCcWATiqwG1WCMeokBBRFwk5tWjkfCzaN9JazzD9j4eARJkiy3Jervltr5srzjWifaXWDGLGmA7NKkrvltr5sYOGOeUHbgPpdbWHCcWATiqwG1WCMeokBBdEd9oBXjSAzirz2RFEhSCTAztYa9SSLF5e)qwBza7Ervltr5saUmKKcGaybrKGmA7Nee874EbMtf(D3lQAzkkxIcMdx(LtmWoVoIwRtGLGmA7Nee8B3DWTfHxNmjmejdSjE9IYsGrkacYneTXXbWd45ybbYOTFsQ2QXD022urkklbgPaigUdSeKrB)K22G3qVZwCcRwgsuMb3weEDYKWqKmWM41lBvLHuaKaJj8XOiWXbWlQAzkkxkklbgPaigUdSeKrB)KuPdA02g8g6D2Ity1YqIYSxu1YuuUeGldjPaiawqejiJ2(jbbuBBaphliqgT9tcYwqTTb8CSGaz02pjvBPM69aEowqGmA7NeKTBPEpsevTmfLlb4YqskacGfercYOTFsq212wu1YuuUefmhU8lNyGDEDeTwNalbz02pjiA02wu1YuuUe0L(LtKwhbzxGCcYOTFsq0iyhCBr41jtcdrYaBIxprDc(cyhSHaSAughhaV(nvKe1j4lGDWgcWQrzsMf8sqgT9tUhjiru1YuuUKOobFbSd2qawnkNGmA7Nee8IQwMIYLIYsGrkaIH7albz02p5MBTTbVHENT4ewTmKOmGDps0F0l(IefmhU8lNyGDEDeTwNalXxNTyJTTOQLPOCjkyoC5xoXa786iATobwcYOTFsWUxu1YuuUe0L(LtKwhbzxGCcYOTFY9IQwMIYLaCzijfabWcIibz02p5(mlaGKmkikHByGr6ZqaCiNmfLZ22urkklbgPaigUdSeKrB)KG12gWZXccKrB)KGOpdUG586ljp)gRQmZdgTGiM3bMxZYsGnFbmV(M7aBNiNxu1YuuU5D585qUdgoFG1387s98ijWC58(jwwgwopfmFXZRzPVN3LZlSGq(IfI5Br4GZGfN5l48faW8IQwMIYnpfm(MhrznFd55XQLXV85RlQ51S034mFbNNcgFZhy88rdZ5yExoFNvwX8rnVX5b3weEDYKWqKmWM41lBvLHaybrGJdGxu1YuuUuuwcmsbqmChyjiJ2(jPAxQTTbVHENT4ewTmKOm22aEowqGmA7NeeqPEWTfHxNmjmejdSjE9YyOKHi7xoooaErvltr5srzjWifaXWDGLGmA7NKQDP22g8g6D2Ity1YqIYyBd45ybbYOTFsq2QXb3weEDYKWqKmWM41B55yHKOJSm5O8fdUTi86KjHHizGnXRhGd5SvvgCCa8IQwMIYLIYsGrkaIH7albz02pjv7sTTn4n07SfNWQLHeLX2gWZXccKrB)KGSL6b3weEDYKWqKmWM41RpbldyViIETWXbWlQAzkkxkklbgPaigUdSeKrB)KuTl122G3qVZwCcRwgsugBBaphliqgT9tccOup42IWRtMegIKb2eVEzDoPaib0filhCBr41jtcdrYaBIxpljt8GrX5AugV2sGmhsxdydruOATIo86iggCxW4GJdGxu1YuuUuuwcmsbqmChyjiJ2(jPAxQTTbVHENT4ewTmKOmdUTi86KjHHizGnXRNLKjEWO4CnkJhYOvWKCl30NGjggCxW44a4fvTmfLlfLLaJuaed3bwcYOTFsQ2LABBWBO3zloHvldjkZGBlcVozsyisgyt86zjzIhmkomaalcY1Om(8vB8okOKK1MCghhaVOQLPOCPOSeyKcGy4oWsqgT9tsfOuBBdEd9oBXjSAzirzSTb8CSGaz02pjiGs9GBlcVozsyisgyt86zjzIhmkoxJY4Z7fl61IHsswvhooaErvltr5srzjWifaXWDGLGmA7NKknQrBBWBO3zloHvldjkJTnGNJfeiJ2(jbzlOdUTi86KjHHizGnXRNLKjEWO4CnkJNc0dm)YjsohLVGuaedKLrN3bgooaErvltr5srzjWifaXWDGLGmA7NKkqP22g8g6D2Ity1YqIYm42IWRtMegIKb2eVEwsM4bJIZ1Om(wIbEFSKaBnOGerb7fooaEWBO3zlofLHuhXsYKa6hYCShjIQwMIYLIYsGrkaIH7albz02pjvGU12g8g6D2Ity1YqIYa29iXWzwaajyRbfKikyVigoZcaizkkNTDMfaqsgfeLWnmWi9ziaoKtqgT9ts12DTTb8CSGaz02pjsjQAzkkxkklbgPaigUdSeKrB)KGOduVxu1YuuUuuwcmsbqmChyjiJ2(jbbunABd45ybbYOTFsqavJGDWTfHxNmjmejdSjE9SKmXdgfNRrz8Ted8(yjb2AqbjIc2lCCa86h8g6D2Itrzi1rSKmjG(Hmh7rIHZSaasWwdkiruWErmCMfaqYuuoBBKOFEhSCTAztYa9SSLF5e)qwBzSTJgMZrkCuMefrRii7sDcYOTFsq0hWUhjMksrzjWifaXWDGLGmA7N02wu1YuuUuuwcmsbqmChyjiJ2(j3ChPcWZXccKrB)KGDFMfaqsgfeLWnmWi9ziaoKtwATTb8CSGaz02pjiGQrWo42IWRtMegIKb2eVEbgtSUSY6meGck4b3weEDYKWqKmWM41tRf0bq4xojB1YyWTfHxNmjmejdSjE9GCR1VCcWQrzjooa(OH5CKchLjrr0kccOut1UuBBhnmNJeg3RalPveGGhuQhCBr41jtcdrYaBIxpGsyjzdP1ag6btY4gDWTfHxNmjmejdSjE9qz0cIGuaKLLWnedKBujooaE(yyocq0bQhCBr41jtcdrYaBIxpORv7Ij(rKABbp42IWRtMegIKb2eVEzDoPaib0filhCBr41jtcdrYaBIxpljt8GrL44a4rcVdwUwTSjjqiwvaRZfKSvlJ9IQwMIYLeieRkG15cs2QLrcYOTFsqWdk1G12w)8oy5A1YMKaHyvbSoxqYwTmgChCbZ5bdvTmfLto42IWRtMegIKH85bc8(bEHmt0PfFKaJjuW8GjHNZqCCa8zwaajjd5Zdejtr5STb8CSGaz02pjiGQXb3weEDYKWqKmKppqSjE9SKmXdgfNRrz8TgiXAylja1fKcGOTOWqCCa8zwaajjd5Zdejtr52Jervltr5ssgYNhisqgT9tccOuBBd45ybbYOTFsq0bQb7GBlcVozsyisgYNhi2eVE5wn049rkasRbmScmCCa8zwaajjd5Zdejtr52JeaphliqgT9ts1w9rJ22IQwMIYLKmKppqKGmA7Nee87mWABd45ybbYOTFsq2vJdUTi86KjHHiziFEGyt86LTQYqaSGiWXbWlQAzkkxsYq(8arcYOTFsQaLABBaphliqgT9tccOup42IWRtMegIKH85bInXRxgdLmez)YXXbWlQAzkkxsYq(8arcYOTFsQaLABBaphliqgT9tcYwno4cMZRVK88AiOOpEEnliKVyEhyEAgYNhiM3LZFvmVLwCMVpZ8ikR5BippQlL(LpFhZV4wgZVDEWaMJZ89zMNsD7KyErRDE(yyoI5P4bMFZtDsJZlzrDg5GBlcVozsyisgYNhi2eVEnu0htIcc5lWXbWNzbaKKmKppqKmfLBVaZtOTorkbMtf(T75JH5isHJYKOiOToPcp1jno42IWRtMegIKH85bInXR3YZXcjrhzzYr5lgCBr41jtcdrYq(8aXM41dWHC2QkdooaErvltr5ssgYNhisqgT9tsfOuBBd45ybbYOTFsq2s9GBlcVozsyisgYNhi2eVE9jyza7fr0RfooaErvltr5ssgYNhisqgT9tsfOuBBd45ybbYOTFsqaL6b3weEDYKWqKmKppqSjE9Y6CsbqcOlqwo42IWRtMegIKH85bInXRNLKjEWO4CnkJFzjdyzjj51YWhr7YcTZzCCa8IQwMIYLIYsGrkaIH7albz02pjiBTTfvTmfLlfLLaJuaed3bwcYOTFsQaLABBWBO3zloHvldjkJTnGNJfeiJ2(jbbpOup42IWRtMegIKH85bInXRNLKjEWO4WaaSiixJY4ZxTX7OGsckB61YRdhhaVOQLPOCPOSeyKcGy4oWsqgT9tcYwBBrvltr5srzjWifaXWDGLGmA7NKkqP22g8g6D2Ity1YqIYyBd45ybbYOTFsqWdk1dUTi86KjHHiziFEGyt86zjzIhmkomaalcY1Om(8vB8okOKWOzlgfhhapGNJfeiJ2(jPARg3rBBrvltr5srzjWifaXWDGLGmA7NeKT22G3qVZwCcRwgsuMb3weEDYKWqKmKppqSjE9IYsGrkaIH7adhhaV(bVHENT4ewTmKOmdUTi86KjHHiziFEGyt86fLLaJuaeKBiAJJdGhWZXccKrB)KuTvJ7OTTPIuuwcmsbqmChyjiJ2(jTTbVHENT4ewTmKOmdUTi86KjHHiziFEGyt86zjzIhmkoxJY41wcK5q6AaBiIcvRv0HxhXWG7cghhaFMfaqsYq(8arYuuU9iru1YuuUuuwcmsbqmChyjiJ2(jPAl122G3qVZwCcRwgsugWABd45ybbYOTFsq04GBlcVozsyisgYNhi2eVEzRQmKcGeymHpgfbooa(mlaGKKH85bIKPOC7rIOQLPOCjjd5ZdejiJ2(jPcuQTTfvTmfLljziFEGibz02pjiGcwBBaphliqgT9tcYwno42IWRtMegIKH85bInXRNLKjEWO4CnkJhYOvWKCl30NGjggCxW44a4fvTmfLlfLLaJuaed3bwcYOTFsQ2sTTn4n07SfNWQLHeLzWTfHxNmjmejd5ZdeBIxpljt8GrXHbayrqUgLXNVAJ3rbLKS2KZ44a4fvTmfLljziFEGibz02pjvGsTTnGNJfeiJ2(jbbuQhCBr41jtcdrYq(8aXM41ZsYepyuCUgLXN3lw0RfdLKSQoCCa8IQwMIYLKmKppqKGmA7NKkqP22gWZXccKrB)KGak1dUTi86KjHHiziFEGyt86zjzIhmkoxJY4Pa9aZVCIKZr5lifaXazz05DGHJdGxu1YuuUuuwcmsbqmChyjiJ2(jPAl122G3qVZwCcRwgsuMb3weEDYKWqKmKppqSjE9SKmXdgfNRrz8Ted8(yjb2AqbjIc2lCCa8goZcaibBnOGerb7fXWzwaajtr5STZSaassgYNhisqgT9ts1oABd45ybbYOTFsqavJdUTi86KjHHiziFEGyt86rPGld4SFeilRRpbJJdGpZcaijziFEGizkk3EKiQAzkkxsYq(8arcYOTFsQ2QrBBrvltr5ssgYNhisqgT9tccOG12gWZXccKrB)KGak1dUTi86KjHHiziFEGyt86jQtWxa7GneGvJY44a4ZSaassgYNhisMIYThjIQwMIYLKmKppqKGmA7N02wu1YuuUKOobFbSd2qawnkNeynmNL4bfS71VPIKOobFbSd2qawnktYSGxcYOTFY9iru1YuuUe0L(LtKwhbzxGCcYOTFY9IQwMIYLaCzijfabWcIibz02pPTnGNJfeiJ2(jbrFa7GBlcVozsyisgYNhi2eVEsgYNhigCBr41jtcdrYq(8aXM41lWyI1LvwNHauqbJJdGpZcaijziFEGizkk3GBlcVozsyisgYNhi2eVEATGoac)YjzRwg44a4ZSaassgYNhisMIYn42IWRtMegIKH85bInXRhKBT(LtawnklXXbWNzbaKKmKppqKmfLBpsIgMZrkCuMefrRiiGsnv7sTTD0WCosyCVcSKwracEqPgS22rdZ5ifoktIIyCgeqhCBr41jtcdrYq(8aXM41dOews2qAnGHEWKmUrXXbWNzbaKKmKppqKmfLBWTfHxNmjmejd5ZdeBIxpugTGiifazzjCdXa5gvIJdGpZcaijziFEGizkk3E(yyocq0bQhCBr41jtcdrYq(8aXM41d6A1UyIFeP2wW44a4ZSaassgYNhisMIYn42IWRtMegIKH85bInXRxwNtkasaDbYsCCa8zwaajjd5Zdejtr5gCBr41jtcdrYq(8aXM41ZsYepyujooa(mlaGKKH85bIKPOC7rcs4DWY1QLnjbcXQcyDUGKTAzSxu1YuuUKaHyvbSoxqYwTmsqgT9tccEqPgS226N3blxRw2KeieRkG15cs2QLbyhChCbZ51Wc9c6bI5PG5lEEjd5ZdeZ7Y5T0o42IWRtMKmKppqGhWLHKuaealicCCa8zwaajjd5ZdejiJ2(jbzRTDlchCMWhJ6SKQTdUTi86Kjjd5ZdeBIxpPw)o)YjcyFmbzxGmooaErHMvezaDK59iPfHdot4JrDwsfO22TiCWzcFmQZsQ2Ux)IQwMIYLGU0VCI06ii7cKtwAb7GBlcVozsYq(8aXM41d6s)YjsRJGSlqghbcXIjrdZ5qIFlooaErHMvezaDK5bxWCEnXC58u81AErlJ5bJfyC((mZ7xWqOL2y(aJNxG13XR5DG5dmE(DoGb998UCEi3geZ3NzEzHYbMF5ZJ55ymC(6MpW451c9c6bI5xUmMhjiT0inGDExoFdE7RoBXPb3weEDYKKH85bInXRhGldjPaiawqe44xWqOL2G4a4ZfMeKrB)K4PEWTfHxNmjziFEGyt86b4YGuaKaJjuW8GjHNZqCeielMenmNdj(T44a4fyoi7o42IWRtMKmKppqSjE9Gm4muYeSgIIJdGxG5j0wNiLaZPA7E(yyoIu4OmjkcARtq2o4cMZRVK88Buin4mVhZtXxR5RBHy(mi3ippAldgIyEhy(DkEmpyOqZQ5D586QHrZ5JEXxWMb3weEDYKKH85bInXRx2QfixwbbzxGmoceIftIgMZHe)wCCa8IcnRiYa6iZ226p6fFrcZdIOqZQeFD2IndUTi86Kjjd5ZdeBIxpPw)o)YjcyFmbzxG8G7GBlcVozsg4PG5WLF5edSZRJO16eydUTi86KjzSjE9aCzijfabWcIahhaF0l(IKKH85bIeFD2In22IQwMIYLIYsGrkaIH7albz02pjviDBBWBO3zloHvldjkZGlyoV(sYZJ0sJ0mFDZhnmNd58u8aRSI5352qKNVaMpW45bdW(45nCMfaaoZ7aZRTKspBX4mFFM5DG51S03Z7Y57y(f3YyEqNxYI6mY5BknIb3weEDYKm2eVEqx6xorADeKDbY4iqiwmjAyohs8BXXbWh9IVijziFEGiXxNTyJTTOQLPOCPOSeyKcGy4oWsqgT9tsfO22G3qVZwCcRwgsuMb3weEDYKm2eVEqljMF5eDuBycf)m44a4ZSaasqljMF5eDuBycf)mjtr523IWbNj8XOolPA7GBlcVozsgBIxpidodLmbRHO44a4fyEcT1jsjWCQ2o42IWRtMKXM41dWLbPaibgtOG5btcpNH4iqiwmjAyohs8BXXbWlWCq2DWTfHxNmjJnXRhFmm31a)Yj8Y1PdXXbWlWCqWV7E(yyocq0i1dUG586ljppyyJ5DG5ruwZ3qEE0cYZhy9np1ZdgW85BknI5bGf68OToNVpZ8yn488BNNpgfboZxW5BippAb55dS(MF78GbmF(MsJyEayHopARZb3weEDYKm2eVEcmNKzbLbooaEbMNqBDIucmNkQ33IWbNj8XOolXV12wG5j0wNiLaZPA7GlyoV(sYZRPg25DG5ruwZ3qEEDy(copAb55fy(8nLgX8aWcDE0wNZ3NzEnl9989zMNwdhmoFd55ZQaB(RI5T0o42IWRtMKXM41l8Cgs02luCeielMenmNdj(T44a4ffAwrKb0rM3lW8eARtKsG5uT7E9BQifLLaJuaed3bwcYOTFY9zwaajzuquc3WaJ0NHa4qozkk3GBlcVozsgBIxpbMtO0GZdUTi86KjzSjE9KA978lNiG9XeKDbY44a4ffAwrKb0rM3NzbaKm9jysbqeyUoYtqUfXGlyoV(sYZVrH0mVdmFwfyZdglW489zMhPLgPz(gYZFvmVyvsgN5l48iT0inZ7Y5fRsYZ3NzEWybgN3LZFvmVyvsE((mZJOSMhRbNNhTG88bwFZd68cmhN5l48GXcmoVlNxSkjppslnsZ8UC(RI5fRsYZ3NzEeL18yn488OfKNpW6B(DNxG54mFbNhrznpwdoppAb55dS(MxJZlWCCMVGZ7aZJOSMpNJ5751clXGBlcVozsgBIxVSvlqUSccYUazCeielMenmNdj(T44a4ffAwrKb0rM3JeKe9IVijziFEGiXxNTyJTTOQLPOCPOSeyKcGy4oWsqgT9tsfO22G3qVZwCcRwgsugWUhjIQwMIYLGU0VCI06ii7cKtqgT9tsfO7fvTmfLlb4YqskacGfercYOTFsQa12wu1YuuUe0L(LtKwhbzxGCcYOTFsq2DVOQLPOCjaxgssbqaSGisqgT9ts1U7fyovGABlQAzkkxc6s)YjsRJGSlqobz02pjv7Uxu1YuuUeGldjPaiawqejiJ2(jbz39cmNkDW2wG5uPrWABNzbaKYkKjAHLizPfSdUTi86KjzSjE9cpNHeT9cfhbcXIjrdZ5qIFlooaErHMvezaDK59cmpH26ePeyovBhCbZ51xsEEWinsZ89zM3VGHqlTX8EmVmGTNJfZ3uAedUTi86KjzSjE9awi8lNizOw(ccYUazC8lyi0sBGF7GlyoV(sYZVrH0mVdmpySaJZ7Y5fRsYZ3NzEeL18yn488GoVaZNVpZ8ikl48RwgZNVQSEnpLwoVMAyXz(coVdmpIYA(gYZ3zLvmFuZlATZZhdZrmFFM5zpWy48ikl48RwgZNlmZtPLZRPg25l48oW8ikR5Bip)ILY5dS(Mh05fy(8nLgX8aWcDErRvRF5dUTi86KjzSjE9YwTa5Ykii7cKXrGqSys0WCoK43IJdGxuOzfrgqhzEpsevTmfLlb4YqskacGfercYOTFsq2DVaZXdQTnFmmhrkCuMefbT1jiBb7EKOfYGtYfM02u45mKOTxO22cmpH26ePeyoiGcwvOcLca]] )

end