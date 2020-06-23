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
    
    spec:RegisterPack( "Windwalker", 20200623, [[d4u7rcqikP8iOsAtkv9jLkHrbeDkGWRukAwqQUfuPSlr(fLKHrkCmLsldO8mLkMgsv11qQY2GkHVrkv14uQuoNsL06iLk18as3dPSpKkhKuQYcvk8qKQIjsjv1fPKQ0gHkrFuPsfgjsvPCsKQsSsOIxskvYmrQkvDtLkv0ojL8tKQsLgksvjTuLkv9uKmvsrxvPs0wrQkv8vLkvASusvSxs(lIbRQdl1IfLhtyYuCzuBgWNfvJgkNMQvtkv8AiLzRKBdXUv8BjdNsCCkPYYb9CIMUW1PuBhO67qvJNukNhswpuPA(KQ9RYQTknvuMoyLwGPbyAObUaSDsB1(GTZwfvGYcROS0c06CwrnncRO2D9XGVxOXqfLLg1QAJstfLSSHcwrHfHfP2TvwL7bMDwsuiwjDe7vhEncydewjDeHvkQmBFf0xgvMIY0bR0cmnatdnWfGTtAR2hSDuuslSqPfy4IDvrH5gdpQmfLHLcffUE)URpg89cngE)UZAq7WbxVhlclsTBRSk3dm7SKOqSs6i2Ro8AeWgiSs6icRoCW17XXE47bBh0VhmnatJdNdhC9E6dwp5Su7(WbxVh3UF3Zif489uw4gEp9TEm3tfqhn(ErnMWRrEpiX6XSyZ9zOUVnMAar6WbxVh3UN(G1toFF0WCoioW9rDVaLyXKOH5Citho4694297EgPaNVNhgMJ6ErB5Ebglq7EGcEpU0LH8(c4ECPne19Gu6i3BCaagYJGV3L3pC(YZ9SfJ(9z2X9wwnQ7noaad5rW37Y7LE(4aUONaePdhC9EC7ETNXWM73Ls(E6lbJiVhKb0h04qI(9CisGiPOwUmKknvucdrYaknvATvPPIINoBXg1gkkb0dg6TIkZgaijzipEGkzk8Z9663d45ybbYiTpY7b9EWONIQfHxJIYhWl0yI2S5rfkTatPPIINoBXg1gkkb0dg6TIcWZXccKrAFK3t39B3n6DVU(9w7EWBO3zloHvldjkZ97Vxu1Yu4Nuu2cmsbqmChyjiJ0(iVhuA3VL(Vxx)EaphliqgP9rEpO3VdUqr1IWRrrLB3qJ3dPainUZWkWuHsRDuAQO4PZwSrTHIsa9GHEROevTmf(jfLTaJuaed3bwcYiTpY7P7E6TB3RRFVOQLPWpPOSfyKcGy4oWsqgP9rEpO3d29663dEd9oBXjSAzirzUxx)EaphliqgP9rEpO3dMgkQweEnkk8fCzaN9Hazzn9iyvO0I(vAQO4PZwSrTHIsa9GHEROeyEcP129429cm)E6OD)273FppmmhvkCeMefbP1290r7Ens0tr1IWRrr1qrpmjkiKNqfkTONstffpD2InQnuuTi8AuulBzalBjjVwgEiww2iDoROeqpyO3kkrvltHFsrzlWifaXWDGLGms7J8EqVF79663lQAzk8tkkBbgPaigUdSeKrAFK3t39GPX9663dEd9oBXjSAzirzUxx)EaphliqgP9rEpO0UhmnuutJWkQLTmGLTKKxldpellBKoNvHslCHstffpD2InQnuuTi8Auu5R24DuqjbHn9A51OOeqpyO3kkrvltHFsrzlWifaXWDGLGms7J8EqVF79663lQAzk8tkkBbgPaigUdSeKrAFK3t39GPX9663dEd9oBXjSAzirzUxx)EaphliqgP9rEpO0UhmnuumaalcY0iSIkF1gVJckjiSPxlVgvO0s7R0urXtNTyJAdfvlcVgfv(QnEhfusyKSfJOOeqpyO3kkaphliqgP9rEpD3VLE769663lQAzk8tkkBbgPaigUdSeKrAFK3d69BVxx)EWBO3zloHvldjkJIIbayrqMgHvu5R24DuqjHrYwmIkuATBknvu80zl2O2qrjGEWqVvuw7EWBO3zloHvldjkZ97VhK3BT7zRZ2TyHnjbkXQcynUGKTAzCVU(9IQwMc)KeOeRkG14cs2QLrcYiTpY7bL29BVhe3V)EqEVaZVNU73EVU(98WWCu3d690Vg3dcfvlcVgfvu2cmsbqmChyQqP1UQ0urXtNTyJAdfLa6bd9wrjQAzk8tsgfeHWnmWi9yiaoKtcSgMZY7PDpy3RRFVPIuu2cmsbqmChyjiJ0(iVxx)EaphliqgP9rEpO3dMg3RRFpiVpZgaiHVGld4SpeilRPhbNGms7J8E6UFRg3RRFVOQLPWpj8fCzaN9Hazzn9i4eKrAFK3t39IQwMc)KKrbriCddmspgcGd5eG9ArGSaRH5mjCe(ED97T29SuYJGt4l4Yao7dbYYA6rWjKw7uW7bX97VhK3lQAzk8tkkBbgPaigUdSeKrAFK3t39IQwMc)KKrbriCddmspgcGd5eG9ArGSaRH5mjCe(ED97bVHENT4ewTmKOm3V)ERDpBD2UflSjzGEw2YNCIpOzPm3dI73FVOQLPWpjaxgssbqaSHOsqgP9rEpO0UFxVF)9cm)E6OD)o3V)ErvltHFs4XC4YNCIb251qSypcSeKrAFK3dkT73UJIQfHxJIsgfeHWnmWi9yiaoKvHsRTAO0urXtNTyJAdfLa6bd9wrb45ybbYiTpY7P7(T0BxVxx)EtfPOSfyKcGy4oWsqgP9rEVU(9G3qVZwCcRwgsugfvlcVgfvu2cmsbqqRHiTkuATDRstffpD2InQnuucOhm0BfLOQLPWpPOSfyKcGy4oWsqgP9rEpD3t)07ED97bVHENT4ewTmKOm3V)ErvltHFsaUmKKcGaydrLGms7J8EqVhS711VhWZXccKrAFK3d69Bb7ED97b8CSGazK2h590D)wn04(93d45ybbYiTpY7b9(TB14(93dY7fvTmf(jb4YqskacGnevcYiTpY7b9(DUxx)ErvltHFs4XC4YNCIb251qSypcSeKrAFK3d6907ED97fvTmf(jbDPp5eP9qqZfOLGms7J8EqVNE3dcfvlcVgfv2QkdPaibgt4HrqPcLwBbtPPIINoBXg1gkkb0dg6TIYA3BQijQrWta7GneGvJWKmB4KGms7J8(93dY7b59IQwMc)Ke1i4jGDWgcWQr4eKrAFK3dkT7fvTmf(jfLTaJuaed3bwcYiTpY738(T3RRFp4n07SfNWQLHeL5EqC)(7b59w7(Ox8ej8yoC5toXa78AiwShbwINoBXM711Vxu1Yu4NeEmhU8jNyGDEnel2JalbzK2h59G4(93lQAzk8tc6sFYjs7HGMlqlbzK2h597Vxu1Yu4NeGldjPaia2qujiJ0(iVF)9z2aajzuqec3WaJ0JHa4qozk8Z9663BQifLTaJuaed3bwcYiTpY7bX9663d45ybbYiTpY7b9(Dtr1IWRrrjQrWta7GneGvJWQqP12DuAQO4PZwSrTHIsa9GHEROevTmf(jfLTaJuaed3bwcYiTpY7P7(D04ED97bVHENT4ewTmKOm3RRFpGNJfeiJ0(iVh07btdfvlcVgfv2QkdbWgIsfkT2s)knvu80zl2O2qrjGEWqVvuIQwMc)KIYwGrkaIH7albzK2h590D)oACVU(9G3qVZwCcRwgsuM711VhWZXccKrAFK3d69BPNIQfHxJIkJHsgIMp5QqP1w6P0ur1IWRrrT8CSqs0o2MCeEcffpD2InQnuHsRT4cLMkkE6SfBuBOOeqpyO3kkrvltHFsrzlWifaXWDGLGms7J8E6UFhnUxx)EWBO3zloHvldjkZ9663d45ybbYiTpY7b9(TAOOAr41OOaCiNTQYOcLwB1(knvu80zl2O2qrjGEWqVvuIQwMc)KIYwGrkaIH7albzK2h590D)oACVU(9G3qVZwCcRwgsuM711VhWZXccKrAFK3d69GPHIQfHxJIQhbldyViIETuHsRT7MstfvlcVgfvwNtkasaDbAsffpD2InQnuHsRT7QstffpD2InQnuuTi8AuuwkbACiDCNnerHyXo6WRHyyWDbROeqpyO3kkrvltHFsrzlWifaXWDGLGms7J8E6UFhnUxx)EWBO3zloHvldjkJIAAewrzPeOXH0XD2qefIf7OdVgIHb3fSkuAbMgknvu80zl2O2qr1IWRrrbzKkysUTB6rWeddUlyfLa6bd9wrjQAzk8tkkBbgPaigUdSeKrAFK3t397OX9663dEd9oBXjSAzirzuutJWkkiJubtYTDtpcMyyWDbRcLwGTvPPIINoBXg1gkQweEnkQ8vB8okOKK1MCwrjGEWqVvuIQwMc)KIYwGrkaIH7albzK2h590DpyACVU(9G3qVZwCcRwgsuM711VhWZXccKrAFK3d69GPHIIbayrqMgHvu5R24DuqjjRn5SkuAbgyknvu80zl2O2qr1IWRrrL3lw0RfdLKSQgfLa6bd9wrjQAzk8tkkBbgPaigUdSeKrAFK3t390JE3RRFp4n07SfNWQLHeL5ED97b8CSGazK2h59GE)wWuutJWkQ8EXIETyOKKv1OcLwGTJstffpD2InQnuuTi8Auu4HEG5torY5i8eKcGyGSm68oWuucOhm0BfLOQLPWpPOSfyKcGy4oWsqgP9rEpD3dMg3RRFp4n07SfNWQLHeLrrnncROWd9aZNCIKZr4jifaXazz05DGPcLwGr)knvu80zl2O2qr1IWRrr1smW7HLeyJ7fKikyVuucOhm0Bff4n07SfNIYqQHylzsa9bnoUF)9G8ErvltHFsrzlWifaXWDGLGms7J8E6UhST3RRFp4n07SfNWQLHeL5EqC)(7b59goZgaibBCVGerb7fXWz2aajtHFUxx)(mBaGKmkicHByGr6XqaCiNGms7J8E6UF7o3RRFpGNJfeiJ0(iVh3Uxu1Yu4Nuu2cmsbqmChyjiJ0(iVh07PFnUF)9IQwMc)KIYwGrkaIH7albzK2h59GEpy07ED97b8CSGazK2h59GEpy07EqOOMgHvuTed8Eyjb24EbjIc2lvO0cm6P0urXtNTyJAdfvlcVgfvlXaVhwsGnUxqIOG9srjGEWqVvuw7EWBO3zlofLHudXwYKa6dACC)(7b59goZgaibBCVGerb7fXWz2aajtHFUxx)EqEV1UNToB3If2KmqplB5toXh0SuM711VpAyohPWrysuelIGSJg3d69729G4(93dY7nvKIYwGrkaIH7albzK2h59663lQAzk8tkkBbgPaigUdSeKrAFK3V597690DpGNJfeiJ0(iVhe3V)(mBaGKmkicHByGr6XqaCiNSTCVU(9aEowqGms7J8EqVhm6DpiuutJWkQwIbEpSKaBCVGerb7LkuAbgUqPPIQfHxJIkWyI9Kv2JHauqbRO4PZwSrTHkuAbM2xPPIQfHxJIYIn0bq5tojB1YqrXtNTyJAdvO0cSDtPPIINoBXg1gkkb0dg6TIkZgaijzipEGkzk8Z97VhK3hnmNJu4imjkIfrqatJ7P7(D04ED97JgMZrcJ7vGLSiI7bL29GPX9G4ED97JgMZrkCeMefX489GEpykQweEnkki3w8jNaSAewQcLwGTRknvuTi8AuuaLWwYgsJ7m0dMKXnIIINoBXg1gQqP1oAO0urXtNTyJAdfLa6bd9wrXddZrDpO3t)AOOAr41OOqyKcIIuaKLTWnedKBePkuATZwLMkQweEnkkOBXYIj(qKwAbRO4PZwSrTHkuATdyknvuTi8AuuzDoPaib0fOjvu80zl2O2qfkT2zhLMkkE6SfBuBOOeqpyO3kkqEpBD2UflSjjqjwvaRXfKSvlJ73FVOQLPWpjbkXQcynUGKTAzKGms7J8EqPDpyACpiUxx)ERDpBD2UflSjjqjwvaRXfKSvldfvlcVgfLTKjEWisvOcfLHbA7vO0uP1wLMkkE6SfBuBOOklkkjhkQweEnkkWBO3zlwrbEVSzfLOQLPWpPOSfyKcGy4oWsqgP9rE)M3VR3t39rdZ5ifoctIIyC(ED97T29rV4jssgYJhOs80zl2C)(7T29G3qVZwCkkdPgITKjb0h044(93ZwNTBXcBsgONLT8jN4dAwkZ97VpAyohPWrysuelIGSJg3d69B3rJ73FF0WCosHJWKOiwebzhnUNU73T711VhWZXccKrAFK3d69B3rJ73FpGNJfeiJ0(iVNU7fvTmf(jjzipEGkbzK2h597Vxu1Yu4NKKH84bQeKrAFK3t39GDVU(9z2aajjd5XdujBl3V)EaphliqgP9rEpD3VDRIc8gsMgHvuy1YqIYOcLwGP0ur1IWRrrjTWnKG1JHidOJgRO4PZwSrTHkuATJstffpD2InQnuucOhm0BfvMnaqsYqE8avY2Y9663NzdaKKrbriCddmspgcGd5KTL73FVPIuu2cmsbqmChyjiJ0(iVxx)EaphliqgP9rEpO0UhxOHIQfHxJIYsfEnQqPf9R0urXtNTyJAdfLa6bd9wrjW8esRT7XT7fy(90r7EWUF)9G8(Ox8ejjd5XdujE6SfBUxx)ERDVPIuu2cmsbqmChyjiJ0(iVhe3V)(mBaGKKH84bQKPWp3V)EqEppmmhvkCeMefbP129GE)2711Vp6fprsYqE8avINoBXM73FVOQLPWpjjd5XdujiJ0(iVh07b7ED97T29rV4jssgYJhOs80zl2C)(7fvTmf(jfLTaJuaed3bwcYiTpY7b9(DUF)9w7EWBO3zloHvldjkZ9663ZddZrLchHjrrqATDpO3t)3V)ErvltHFsaUmKKcGaydrLGms7J8EqVFBIE3dcfvlcVgffKbNHsMG1qevO0IEknvu80zl2O2qr1IWRrrb4YGuaKaJj4X8GjHNZqfLa6bd9wrjW8esRT7XT7fy(90r7(DUF)9z2aajjd5XdujtHFUF)9z2aajjZbMp5eyNZjtHFUF)9G8EEyyoQu4imjkcsRT7b9(T3RRFF0lEIKKH84bQepD2In3V)ErvltHFssgYJhOsqgP9rEpO3d29663BT7JEXtKKmKhpqL4PZwS5(93lQAzk8tkkBbgPaigUdSeKrAFK3d697C)(7T29G3qVZwCcRwgsuM711VNhgMJkfoctIIG0A7EqVN(VF)9IQwMc)KaCzijfabWgIkbzK2h59GE)2e9UhekkbkXIjrdZ5qQ0ARkuAHluAQO4PZwSrTHIQfHxJIk8CgsS0lefLa6bd9wrzT7ffswrYGCJ297VxG5jKwB3JB3lW87PJ29GD)(7b59rV4jssgYJhOs80zl2CVU(9w7EtfPOSfyKcGy4oWsqgP9rEVU(9TiCWzcpmIZY7P7EWUhe3V)(mBaGKK5aZNCcSZ5KPWp3V)(mBaGKKH84bQKPWp3V)EqEppmmhvkCeMefbP129GE)2711Vp6fprsYqE8avINoBXM73FVOQLPWpjjd5XdujiJ0(iVh07b7ED97T29rV4jssgYJhOs80zl2C)(7fvTmf(jfLTaJuaed3bwcYiTpY7b9(DUF)9w7EWBO3zloHvldjkZ9663ZddZrLchHjrrqATDpO3t)3V)ErvltHFsaUmKKcGaydrLGms7J8EqVFBIE3dcfLaLyXKOH5CivATvfkT0(knvu80zl2O2qrjGEWqVvuw7(Ox8ejaxgKcGeymbpMhmj8CgM4PZwS5(93BbYGtYfM02u45mKyPxi3V)(Wr47bL297OOAr41OOeyobFdoRcLw7MstffpD2InQnuucOhm0Bfv0lEIKKH84bQepD2InkQweEnkkrVwKweEnKLldf1YLbzAewrjmejd5XduQqP1UQ0urXtNTyJAdfLa6bd9wrzT7JEXtKKmKhpqL4PZwSrr1IWRrrj61I0IWRHSCzOOwUmitJWkkHHizavO0ARgknvu80zl2O2qrjGEWqVvuz2aajjd5XdujBlkQweEnkkrVwKweEnKLldf1YLbzAewrjzipEGsfkT2UvPPIINoBXg1gkkb0dg6TIQfHdot4HrCwEpO3VJIQfHxJIs0RfPfHxdz5YqrTCzqMgHvuYqfkT2cMstffpD2InQnuucOhm0BfvlchCMWdJ4S8E6OD)okQweEnkkrVwKweEnKLldf1YLbzAewr1fRcvOOSazrHK1HstLwBvAQOAr41OOSuHxJIINoBXg1gQqPfyknvu80zl2O2qrvwuusouuTi8AuuG3qVZwSIc8EzZkk26SDlwytsGsSQawJlizRwg3RRFpBD2UflSjTSLbSSLK8Az4HyzzJ0589663ZwNTBXcBs5R24DuqjjRn589663ZwNTBXcBs5R24DuqjbHn9A51CVU(9S1z7wSWMeKrQGj52UPhbtmm4UGvuG3qY0iSIkkdPgITKjb0h04qfkT2rPPIINoBXg1gkQYIIsYHIQfHxJIc8g6D2IvuG3lBwrTDxvucOhm0BfL1Up6fprsYqE8avINoBXM73FpiVh8g6D2Itrzi1qSLmjG(Ggh3RRFpBD2UflSj1smW7HLeyJ7fKikyVUhekkWBizAewrbutqkaILcpdjwGSOqY6GiW6z4LkuAr)knvu80zl2O2qrnncROACxI1WwsaQjifaXsHNHkQweEnkQg3LynSLeGAcsbqSu4zOkuArpLMkkE6SfBuBOOeqpyO3kkRDF0lEIKKH84bQepD2In3RRFV1Up6fprcWLbPaibgtWJ5btcpNHjE6SfBuuTi8AuucmNKzdLHkuAHluAQO4PZwSrTHIsa9GHEROIEXtKaCzqkasGXe8yEWKWZzyINoBXM711VNLsEeCsudWYfbPhdrgqhGtiT2PGkQweEnkkbMtW3GZQqPL2xPPIQfHxJIYhWl0yI2S5rrXtNTyJAdvO0A3uAQOAr41OOYTBOX7HuaKg3zyfykkE6SfBuBOcvOO6IvAQ0ARstfvlcVgffEmhU8jNyGDEnel2JatrXtNTyJAdvO0cmLMkkE6SfBuBOOeqpyO3kkRDVfidojxysBtHNZqILEHC)(7fy(9Gs7(T3V)EEyyoQ7b9E6PHIQfHxJIIhgM74Up5eE5AZHQqP1oknvu80zl2O2qrjGEWqVvu8WWCuPWrysueKwB3t39BvuTi8AuuaUmKKcGaydrPcLw0VstffpD2InQnuuTi8Auuqx6torApe0CbAkkb0dg6TIcK3h9INiHhZHlFYjgyNxdXI9iWs80zl2C)(7fvTmf(jbDPp5eP9qqZfOLm2Wo8AUNU7fvTmf(jHhZHlFYjgyNxdXI9iWsqgP9rE)M3t)3dI73FpiVxu1Yu4NeGldjPaia2qujiJ0(iVNU735ED97fy(90r7E6DpiuucuIftIgMZHuP1wvO0IEknvu80zl2O2qrjGEWqVvuz2aajOTeZNCI2PnmbVpMKPWpkQweEnkkOTeZNCI2PnmbVpgvO0cxO0urXtNTyJAdfLa6bd9wrjkKSIidOJgF)(7b59G8EqEVaZVNU735ED97fvTmf(jb4YqskacGnevcYiTpY7P7ECX9G4(93dY7fy(90r7E6DVU(9IQwMc)KaCzijfabWgIkbzK2h590Dpy3dI7bX9663ZddZrLchHjrrqATDpO0UFN711VpZgaiz6rWKcGiWCTJNGClI7bHIQfHxJIsAXNXNCIa2dtqZfOPcLwAFLMkkE6SfBuBOOeqpyO3kkbMNqATDpUDVaZVNoA3dMIQfHxJIcYGZqjtWAiIkuATBknvu80zl2O2qrjGEWqVvucmpH0A7EC7EbMFpD0UFhfvlcVgfLaZjz2qzOcLw7QstffpD2InQnuuTi8AuuaUmifajWycEmpys45murjGEWqVvucmpH0A7EC7EbMFpD0UFhfLaLyXKOH5CivATvfkT2QHstffpD2InQnuuTi8AuuHNZqILEHOOeqpyO3kkbMNqATDpUDVaZVNoA3d297VhK3BT7JEXtKW8GikKSkXtNTyZ9663BT7ffswrYGCJ29GqrjqjwmjAyohsLwBvHsRTBvAQO4PZwSrTHIsa9GHEROS29IcjRizqUrtr1IWRrrjWCc(gCwfkT2cMstffpD2InQnuuTi8Auualu(KtKm0cpbbnxGMIsa9GHEROYSbaszfAelWsKmf(rr5tWqOTLqrTvfkT2UJstffpD2InQnuuTi8AuuzRwGwzhe0CbAkkb0dg6TIsuizfrgqhn((93dY7ZSbaszfAelWsKSTCVU(9G8(Ox8ejmpiIcjRs80zl2C)(7TazWj5ctABk8CgsS0lK73FVaZVh07P)7bX9GqrjqjwmjAyohsLwBvHkuucdrYqE8aLstLwBvAQO4PZwSrTHIsa9GHEROYSbassgYJhOsMc)CVU(9aEowqGms7J8EqVhm6POAr41OO8b8cnMOnBEuHslWuAQO4PZwSrTHIQfHxJIQXDjwdBjbOMGuaelfEgQOeqpyO3kQmBaGKKH84bQKPWp3V)EqEVOQLPWpjjd5XdujiJ0(iVh07btJ711VhWZXccKrAFK3d690Vg3dcf10iSIQXDjwdBjbOMGuaelfEgQcLw7O0urXtNTyJAdfLa6bd9wrLzdaKKmKhpqLmf(5(93dY7b8CSGazK2h590D)2DJE3RRFVOQLPWpjjd5XdujiJ0(iVhuA3R9Vhe3RRFpGNJfeiJ0(iVh073HEkQweEnkQC7gA8EifaPXDgwbMkuAr)knvu80zl2O2qrjGEWqVvuIQwMc)KKmKhpqLGms7J8E6UhmnUxx)EaphliqgP9rEpO3dMgkQweEnkQSvvgcGneLkuArpLMkkE6SfBuBOOeqpyO3kkrvltHFssgYJhOsqgP9rEpD3dMg3RRFpGNJfeiJ0(iVh073spfvlcVgfvgdLmenFYvHslCHstffpD2InQnuucOhm0BfvMnaqsYqE8avYu4N73FVaZtiT2Uh3UxG53thT73E)(75HH5OsHJWKOiiT2UNoA3RrIEkQweEnkQgk6HjrbH8eQqPL2xPPIQfHxJIA55yHKODSn5i8ekkE6SfBuBOcLw7MstffpD2InQnuucOhm0BfLOQLPWpjjd5XdujiJ0(iVNU7btJ711VhWZXccKrAFK3d69B1qr1IWRrrb4qoBvLrfkT2vLMkkE6SfBuBOOeqpyO3kkrvltHFssgYJhOsqgP9rEpD3dMg3RRFpGNJfeiJ0(iVh07btdfvlcVgfvpcwgWEre9APcLwB1qPPIQfHxJIkRZjfajGUanPIINoBXg1gQqP12Tknvu80zl2O2qr1IWRrrTSLbSSLK8Az4HyzzJ05SIsa9GHEROevTmf(jfLTaJuaed3bwcYiTpY7b9(T3RRFVOQLPWpPOSfyKcGy4oWsqgP9rEpD3dMg3RRFp4n07SfNWQLHeL5ED97b8CSGazK2h59Gs7EW0qrnncROw2Yaw2ssETm8qSSSr6CwfkT2cMstffpD2InQnuuTi8Auu5R24DuqjbHn9A51OOeqpyO3kkrvltHFsrzlWifaXWDGLGms7J8EqVF79663lQAzk8tkkBbgPaigUdSeKrAFK3t39GPX9663dEd9oBXjSAzirzUxx)EaphliqgP9rEpO0UhmnuumaalcY0iSIkF1gVJckjiSPxlVgvO0A7oknvu80zl2O2qr1IWRrrLVAJ3rbLegjBXikkb0dg6TIcWZXccKrAFK3t39BP3UEVU(9IQwMc)KIYwGrkaIH7albzK2h59GE)2711Vh8g6D2Ity1YqIYOOyaaweKPryfv(QnEhfusyKSfJOcLwBPFLMkkE6SfBuBOOeqpyO3kkRDp4n07SfNWQLHeLrr1IWRrrfLTaJuaed3bMkuATLEknvu80zl2O2qrjGEWqVvuaEowqGms7J8E6UFl921711V3urkkBbgPaigUdSeKrAFK3RRFp4n07SfNWQLHeLrr1IWRrrfLTaJuae0AisRcLwBXfknvu80zl2O2qr1IWRrrzPeOXH0XD2qefIf7OdVgIHb3fSIsa9GHEROYSbassgYJhOsMc)C)(7b59IQwMc)KIYwGrkaIH7albzK2h590D)wnUxx)EWBO3zloHvldjkZ9G4ED97b8CSGazK2h59GEp9uutJWkklLanoKoUZgIOqSyhD41qmm4UGvHsRTAFLMkkE6SfBuBOOeqpyO3kQmBaGKKH84bQKPWp3V)EqEVOQLPWpjjd5XdujiJ0(iVNU7btJ711Vxu1Yu4NKKH84bQeKrAFK3d69GDpiUxx)EaphliqgP9rEpO3VLEkQweEnkQSvvgsbqcmMWdJGsfkT2UBknvu80zl2O2qr1IWRrrbzKkysUTB6rWeddUlyfLa6bd9wrjQAzk8tkkBbgPaigUdSeKrAFK3t39B14ED97bVHENT4ewTmKOmkQPryffKrQGj52UPhbtmm4UGvHsRT7QstffpD2InQnuuTi8Auu5R24DuqjjRn5SIsa9GHEROevTmf(jjzipEGkbzK2h590DpyACVU(9aEowqGms7J8EqVhmnuumaalcY0iSIkF1gVJckjzTjNvHslW0qPPIINoBXg1gkQweEnkQ8EXIETyOKKv1OOeqpyO3kkrvltHFssgYJhOsqgP9rEpD3dMg3RRFpGNJfeiJ0(iVh07btdf10iSIkVxSOxlgkjzvnQqPfyBvAQO4PZwSrTHIQfHxJIcp0dmFYjsohHNGuaedKLrN3bMIsa9GHEROevTmf(jfLTaJuaed3bwcYiTpY7P7(TACVU(9G3qVZwCcRwgsugf10iSIcp0dmFYjsohHNGuaedKLrN3bMkuAbgyknvu80zl2O2qr1IWRrr1smW7HLeyJ7fKikyVuucOhm0BfLHZSbasWg3liruWErmCMnaqYu4N711VpZgaijzipEGkbzK2h590D)UEVU(9aEowqGms7J8EqVhm6POMgHvuTed8Eyjb24EbjIc2lvO0cSDuAQO4PZwSrTHIsa9GHEROYSbassgYJhOsMc)C)(7b59IQwMc)KKmKhpqLGms7J8E6UFl9Uxx)ErvltHFssgYJhOsqgP9rEpO3d29G4ED97b8CSGazK2h59GEpyAOOAr41OOWxWLbC2hcKL10JGvHslWOFLMkkE6SfBuBOOeqpyO3kQmBaGKKH84bQKPWp3V)EqEVOQLPWpjjd5XdujiJ0(iVxx)ErvltHFsIAe8eWoydby1iCsG1WCwEpT7b7EqC)(7T29MksIAe8eWoydby1imjZgojiJ0(iVF)9G8ErvltHFsqx6torApe0CbAjiJ0(iVF)9IQwMc)KaCzijfabWgIkbzK2h59663d45ybbYiTpY7b9(D7EqOOAr41OOe1i4jGDWgcWQryvO0cm6P0ur1IWRrrjzipEGsrXtNTyJAdvO0cmCHstffpD2InQnuucOhm0BfvMnaqsYqE8avYu4hfvlcVgfvGXe7jRShdbOGcwfkTat7R0urXtNTyJAdfLa6bd9wrLzdaKKmKhpqLmf(rr1IWRrrzXg6aO8jNKTAzOcLwGTBknvu80zl2O2qrjGEWqVvuz2aajjd5XdujtHFUF)9G8(OH5CKchHjrrSiccyACpD3VJg3RRFF0WCosyCVcSKfrCpO0UhmnUhe3RRFF0WCosHJWKOigNVh07btr1IWRrrb52Ip5eGvJWsvO0cSDvPPIINoBXg1gkkb0dg6TIkZgaijzipEGkzk8JIQfHxJIcOe2s2qACNHEWKmUruHsRD0qPPIINoBXg1gkkb0dg6TIkZgaijzipEGkzk8Z97VNhgMJ6EqVN(1qr1IWRrrHWifefPailBHBigi3isvO0ANTknvu80zl2O2qrjGEWqVvuz2aajjd5XdujtHFuuTi8Auuq3ILft8HiT0cwfkT2bmLMkkE6SfBuBOOeqpyO3kQmBaGKKH84bQKPWpkQweEnkQSoNuaKa6c0KQqP1o7O0urXtNTyJAdfLa6bd9wrLzdaKKmKhpqLmf(5(93dY7b59S1z7wSWMKaLyvbSgxqYwTmUF)9IQwMc)KeOeRkG14cs2QLrcYiTpY7bL29GPX9G4ED97T29S1z7wSWMKaLyvbSgxqYwTmUhekQweEnkkBjt8GrKQqfkkzO0uP1wLMkQweEnkk8yoC5toXa78AiwShbMIINoBXg1gQqPfyknvu80zl2O2qrjGEWqVvurV4jssgYJhOs80zl2CVU(9IQwMc)KIYwGrkaIH7albzK2h590DpU4ED97bVHENT4ewTmKOmkQweEnkkaxgssbqaSHOuHsRDuAQO4PZwSrTHIQfHxJIc6sFYjs7HGMlqtrjGEWqVvurV4jssgYJhOs80zl2CVU(9IQwMc)KIYwGrkaIH7albzK2h590Dpy3RRFp4n07SfNWQLHeLrrjqjwmjAyohsLwBvHsl6xPPIINoBXg1gkkb0dg6TIkZgaibTLy(Kt0oTHj49XKmf(5(933IWbNj8WiolVNU73QOAr41OOG2smFYjAN2We8(yuHsl6P0urXtNTyJAdfLa6bd9wrjW8esRT7XT7fy(90D)wfvlcVgffKbNHsMG1qevO0cxO0urXtNTyJAdfvlcVgffGldsbqcmMGhZdMeEodvucOhm0BfLaZVh073rrjqjwmjAyohsLwBvHslTVstffpD2InQnuucOhm0BfLaZVhuA3VZ97VNhgMJ6EqVNEAOOAr41OO4HH5oU7toHxU2COkuATBknvu80zl2O2qrjGEWqVvucmpH0A7EC7EbMFpD3RX97VVfHdot4HrCwEpT73EVU(9cmpH0A7EC7EbMFpD3Vvr1IWRrrjWCsMnugQqP1UQ0urXtNTyJAdfvlcVgfv45mKyPxikkb0dg6TIsuizfrgqhn((93lW8esRT7XT7fy(90D)o3V)ERDVPIuu2cmsbqmChyjiJ0(iVF)9z2aajzuqec3WaJ0JHa4qozk8JIsGsSys0WCoKkT2QcLwB1qPPIQfHxJIsG5e8n4SIINoBXg1gQqP12Tknvu80zl2O2qrjGEWqVvuIcjRiYa6OX3V)(mBaGKPhbtkaIaZ1oEcYTiuuTi8Auusl(m(KteWEycAUanvO0Alyknvu80zl2O2qr1IWRrrLTAbALDqqZfOPOeqpyO3kkrHKvezaD0473FpiVhK3h9INijzipEGkXtNTyZ9663lQAzk8tkkBbgPaigUdSeKrAFK3t39GDVU(9G3qVZwCcRwgsuM7bX97VhK3lQAzk8tc6sFYjs7HGMlqlbzK2h590Dpy3V)ErvltHFsaUmKKcGaydrLGms7J8E6UhS711Vxu1Yu4Ne0L(KtK2dbnxGwcYiTpY7b9(DUF)9IQwMc)KaCzijfabWgIkbzK2h590D)o3V)EbMFpD3d29663lQAzk8tc6sFYjs7HGMlqlbzK2h590D)o3V)ErvltHFsaUmKKcGaydrLGms7J8EqVFN73FVaZVNU7P)711VxG53t3907EqCVU(9z2aaPScnIfyjs2wUhekkbkXIjrdZ5qQ0ARkuATDhLMkkE6SfBuBOOAr41OOcpNHel9crrjGEWqVvuIcjRiYa6OX3V)EbMNqATDpUDVaZVNU73QOeOelMenmNdPsRTQqP1w6xPPIYNGHqBlHIARIQfHxJIcyHYNCIKHw4jiO5c0uu80zl2O2qfkT2spLMkkE6SfBuBOOAr41OOYwTaTYoiO5c0uucOhm0BfLOqYkImGoA897VhK3lQAzk8tcWLHKuaeaBiQeKrAFK3d697C)(7fy(90UhS711VNhgMJkfoctIIG0A7EqVF79G4(93dY7TazWj5ctABk8CgsS0lK711VxG5jKwB3JB3lW87b9EWUhekkbkXIjrdZ5qQ0ARkuHIsYqE8aLstLwBvAQO4PZwSrTHIsa9GHEROYSbassgYJhOsqgP9rEpO3V9ED97Br4GZeEyeNL3t39BvuTi8AuuaUmKKcGaydrPcLwGP0urXtNTyJAdfLa6bd9wrjkKSIidOJgF)(7b59TiCWzcpmIZY7P7EWUxx)(weo4mHhgXz590D)273FV1Uxu1Yu4Ne0L(KtK2dbnxGwY2Y9Gqr1IWRrrjT4Z4tora7HjO5c0uHsRDuAQO4PZwSrTHIQfHxJIc6sFYjs7HGMlqtrjGEWqVvuIcjRiYa6OXkkbkXIjrdZ5qQ0ARkuAr)knvu(emeABjioGIkxysqgP9rstdfvlcVgffGldjPaia2qukkE6SfBuBOcLw0tPPIINoBXg1gkQweEnkkaxgKcGeymbpMhmj8CgQOeqpyO3kkbMFpO3VJIsGsSys0WCoKkT2QcLw4cLMkkE6SfBuBOOeqpyO3kkbMNqATDpUDVaZVNU73E)(75HH5OsHJWKOiiT2Uh073QOAr41OOGm4muYeSgIOcLwAFLMkkE6SfBuBOOAr41OOYwTaTYoiO5c0uucOhm0BfLOqYkImGoA89663BT7JEXtKW8GikKSkXtNTyJIsGsSys0WCoKkT2QcLw7MstfvlcVgfL0IpJp5ebShMGMlqtrXtNTyJAdvOcvOOaNHsVgLwGPbyAObUyl9ROW3WXNCPIA3v7T71I(Iw7o0UV)EnX47DelfmUhOG3VlegIKb2f3dzRZ2HS5EzHW332rH0bBUxG1toltho037dFpy0t7(E6tnGZWGn3VlchHjrrSicI1J1tcYiTpYDX9rD)UiCeMefXIiiwpwp7I7b5wTbI0HZHZUR2B3Rf9fT2DODF)9AIX37iwkyCpqbVFxyyG2Ef7I7HS1z7q2CVSq47B7Oq6Gn3lW6jNLPdh679HVFR2990NAaNHbBUFxeoctIIyreeRhRNeKrAFK7I7J6(Dr4imjkIfrqSESE2f3dsW0gishoho0xqSuWGn3R9VVfHxZ9lxgY0HJIYcSa8fROW173D9XGVxOXW73DwdAho469yryrQDBLv5EGzNLefIvshXE1HxJa2aHvshry1HdUEpo2dFpy7G(9GPbyAC4C4GR3tFW6jNLA3ho4694297EgPaNVNYc3W7PV1J5EQa6OX3lQXeEnY7bjwpMfBUpd19TXudisho4694290hSEY57JgMZbXbUpQ7fOelMenmNdz6WbxVh3UF3Zif4898WWCu3lAl3lWybA3duW7XLUmK3xa3JlTHOUhKsh5EJdaWqEe89U8(HZxEUNTy0VpZoU3YQrDVXbayipc(ExEV0ZhhWf9eGiD4GR3JB3R9mg2C)UuY3tFjye59GmG(Gghs0VNdrcePdNdhC9ERxTXc7Gn3NXafKVxuizDCFgN7JmDV2tiylH8(PgCdRHia2R7Br41iVVMfQ0HdUEFlcVgzYcKffswh0awTeTdhC9(weEnYKfilkKSo2KMvavzoCW17Br41itwGSOqY6ytAw125i8eD41C4GR3tnTfjwf3dB3CFMnaaBUxgDiVpJbkiFVOqY64(mo3h599yU3cKXnlve(KFVlV3udNoCW17Br41itwGSOqY6ytAwjN2IeRcIm6qE40IWRrMSazrHK1XM0SYsfEnho4690hmwGM8Eh4EuL99yn48999b0h044E26SDlwyZ9bwh3JVNqEFu3NX3BlzZ9rLZbgdVhVhy3Rzz9pCAr41itwGSOqY6ytAwbEd9oBXOpnctlkdPgITKjb0h04a9YcnjhOdEVSzAS1z7wSWMKaLyvbSgxqYwTm01zRZ2TyHnPLTmGLTKKxldpellBKoN11zRZ2TyHnP8vB8okOKK1MCwxNToB3If2KYxTX7OGsccB61YRrxNToB3If2KGmsfmj32n9iyIHb3f8HdUEp9DAO3zl((aRJ7X7R19bVw3JQSV3bUhvzFpEFTUFy2CFu3JV94(OUx0Y4EnlRVvM6(PI7X3tCFu3lAzCVh33X99ADFpOqkiF40IWRrUjnRaVHENTy0NgHPHvldjkd6LfAsoqh8EzZ0evTmf(jfLTaJuaed3bwcYiTpYn3v6IgMZrkCeMefX4SUU1IEXtKKmKhpqL4PZwSzV1aVHENT4uugsneBjtcOpOXXE26SDlwytYa9SSLp5eFqZsz2hnmNJu4imjkIfrq2rJeKrAFKGUDhn2hnmNJu4imjkIfrq2rJeKrAFK0TB66aEowqGms7Je0T7OXEaphliqgP9rsNOQLPWpjjd5XdujiJ0(i3lQAzk8tsYqE8avcYiTps6atxpZgaijzipEGkzBzpGNJfeiJ0(iPB72dNweEnYKfilkKSo2KMvG3qVZwm6tJW0aQjifaXsHNHelqwuizDqey9m8c9YcnjhOdEVSzAB3v0DaAwl6fprsYqE8avINoBXM9Ge8g6D2Itrzi1qSLmjG(Ggh66S1z7wSWMulXaVhwsGnUxqIOG9cehoTi8AKjlqwuizDSjnRSLmXdgb9PryAnUlXAylja1eKcGyPWZWdNweEnYKfilkKSo2KMvcmNKzdLb6oanRf9INijzipEGkXtNTyJUU1IEXtKaCzqkasGXe8yEWKWZzyINoBXMdNweEnYKfilkKSo2KMvcmNGVbNr3bOf9INib4YGuaKaJj4X8GjHNZWepD2In66SuYJGtIAawUii9yiYa6aCcP1of8WPfHxJmzbYIcjRJnPzLpGxOXeTzZdjWycEmpys45m8WPfHxJmzbYIcjRJnPzvUDdnEpKcG04odRa7W5WbxV36vBSWoyZ9m4me19HJW3hy89Tik49U8(g82xD2IthoTi8AK0Kw4gsW6XqKb0rJpCW173Ls(Elv41CVdCpfd5Xdu37Y7TTG(9f8(SkWUNY6fxEFpM71SS(33q(EBlOFFbVpW47JgMZX94916EJZ3J3dmFUhxOX9swuJrE40IWRrUjnRSuHxd6oaTmBaGKKH84bQKTfD9mBaGKmkicHByGr6XqaCiNSTS3urkkBbgPaigUdSeKrAFK66aEowqGms7JeuA4cnoCAr41i3KMvqgCgkzcwdrq3bOjW8esRnCtG50rdS9Gm6fprsYqE8avINoBXgDDRzQifLTaJuaed3bwcYiTpsqSpZgaijzipEGkzk8ZEqYddZrLchHjrrqATb6wD9Ox8ejjd5XdujE6SfB2lQAzk8tsYqE8avcYiTpsqbtx3ArV4jssgYJhOs80zl2Sxu1Yu4Nuu2cmsbqmChyjiJ0(ibDN9wd8g6D2Ity1YqIYORZddZrLchHjrrqATbk9Vxu1Yu4NeGldjPaia2qujiJ0(ibDBIEG4WbxVFxk57XLvS7Q59oW93JQSVVH89iUu6t(9DC)IBzC)o3lWC0Vx7nM7VxYqE8af63R9gZ93VrfwV33q((PI7TTG(9ApTS(3JQSVN9aJH33q((oRSJ7J6ErB5EEyyok0VVG3lzipEG6ExEFNv2X9rDVOq47TTG(9f8EnlR)9U8(oRSJ7J6ErHW3BBb97l494YcxEVlVxui(KFVTL77XCpQY(E8(ADVOTCppmmh19YQMdNweEnYnPzfGldsbqcmMGhZdMeEodrxGsSys0WCoK02IUdqtG5jKwB4MaZPJ2o7ZSbassgYJhOsMc)SpZgaijzoW8jNa7Cozk8ZEqYddZrLchHjrrqATb6wD9Ox8ejjd5XdujE6SfB2lQAzk8tsYqE8avcYiTpsqbtx3ArV4jssgYJhOs80zl2Sxu1Yu4Nuu2cmsbqmChyjiJ0(ibDN9wd8g6D2Ity1YqIYORZddZrLchHjrrqATbk9Vxu1Yu4NeGldjPaia2qujiJ0(ibDBIEG4WbxVFxk571K(69oW9ECp(AI7ZGCJ29iTmyik0Vx7PL1)(gY3J4sPp533X9lULX9GDVaZr)ETNww)7Z887fvTmf(rEFd57NkU32c63R90Y6FpQY(E2dmgEFd577SYoUpQ7fTL75HH5Oq)(cEVKH84bQ7D59Dwzh3h19IcHV32c63xW71SS(37Y7ffIp53BBb97l494YcxEVlVxui(KFVTL77XCpQY(E8(ADVOTCppmmh19YQMdNweEnYnPzv45mKyPxiOlqjwmjAyohsABr3bOznrHKvKmi3OTxG5jKwB4MaZPJgy7bz0lEIKKH84bQepD2In66wZurkkBbgPaigUdSeKrAFK66TiCWzcpmIZs6ade7ZSbassMdmFYjWoNtMc)SpZgaijzipEGkzk8ZEqYddZrLchHjrrqATb6wD9Ox8ejjd5XdujE6SfB2lQAzk8tsYqE8avcYiTpsqbtx3ArV4jssgYJhOs80zl2Sxu1Yu4Nuu2cmsbqmChyjiJ0(ibDN9wd8g6D2Ity1YqIYORZddZrLchHjrrqATbk9Vxu1Yu4NeGldjPaia2qujiJ0(ibDBIEG4WPfHxJCtAwjWCc(gCgDhGM1IEXtKaCzqkasGXe8yEWKWZzyINoBXM9wGm4KCHjTnfEodjw6fY(WryqPTZHtlcVg5M0Ss0RfPfHxdz5Ya9PryAcdrYqE8af6oaTOx8ejjd5XdujE6SfBoCAr41i3KMvIETiTi8AilxgOpncttyisgaDhGM1IEXtKKmKhpqL4PZwS5WbxVN(0R19bgFpfd5Xdu33IWR5(LlJ7DG7PyipEG6ExEVWgc5jwOU32YHtlcVg5M0Ss0RfPfHxdz5Ya9PryAsgYJhOq3bOLzdaKKmKhpqLSTC4GR3tF616(aJVNsZ7Br41C)YLX9oW9bgd57BiFpy3xW7xSuEppmIZYdNweEnYnPzLOxlslcVgYYLb6tJW0Kb6oaTweo4mHhgXzjO7C4GR3tF616(aJVx7vwV33IWR5(LlJ7DG7dmgY33q((DUVG3Juq(EEyeNLhoTi8AKBsZkrVwKweEnKLld0NgHP1fJUdqRfHdot4HrCwshTDoCoCW171EIWRrM0EL179U8EFcEmS5EGcEVTKVhVhy3tFJfHliApJHqFwCdoFFpM7f2qipXc19dZg59rDFgFFzjCeh3zZHtlcVgzQlMgEmhU8jNyGDEnel2Ja7WPfHxJm1fVjnR4HH5oU7toHxU2Ci6oanRzbYGtYfM02u45mKyPxi7fyoO02UNhgMJcu6PXHtlcVgzQlEtAwb4YqskacGnef6oanEyyoQu4imjkcsRn62E40IWRrM6I3KMvqx6torApe0CbAOlqjwmjAyohsABr3bObYOx8ej8yoC5toXa78AiwShbwINoBXM9IQwMc)KGU0NCI0EiO5c0sgByhEn0jQAzk8tcpMdx(KtmWoVgIf7rGLGms7JCt6he7bPOQLPWpjaxgssbqaSHOsqgP9rs3o66cmNoA0dehoTi8AKPU4nPzf0wI5tor70gMG3hd6oaTmBaGe0wI5tor70gMG3htYu4NdNweEnYux8M0SsAXNXNCIa2dtqZfOHUdqtuizfrgqhnEpibjifyoD7ORlQAzk8tcWLHKuaeaBiQeKrAFK0HlaXEqkWC6OrpDDrvltHFsaUmKKcGaydrLGms7JKoWabi015HH5OsHJWKOiiT2aL2o66z2aajtpcMuaebMRD8eKBraIdNweEnYux8M0ScYGZqjtWAic6oanbMNqATHBcmNoAGD40IWRrM6I3KMvcmNKzdLb6oanbMNqATHBcmNoA7C40IWRrM6I3KMvaUmifajWycEmpys45meDbkXIjrdZ5qsBl6oanbMNqATHBcmNoA7C40IWRrM6I3KMvHNZqILEHGUaLyXKOH5CiPTfDhGMaZtiT2WnbMthnW2dsRf9INiH5bruizvINoBXgDDRjkKSIKb5gnqC40IWRrM6I3KMvcmNGVbNr3bOznrHKvKmi3OD40IWRrM6I3KMvalu(KtKm0cpbbnxGg6oaTmBaGuwHgXcSejtHFq3NGHqBlbTThoTi8AKPU4nPzv2QfOv2bbnxGg6cuIftIgMZHK2w0DaAIcjRiYa6OX7bzMnaqkRqJybwIKTfDDqg9INiH5bruizvINoBXM9wGm4KCHjTnfEodjw6fYEbMdk9dcqC4C4GR3tFQAzk8J8WPfHxJmjmejdqZhWl0yI2S5HeymbpMhmj8CgIUdqlZgaijzipEGkzk8JUoGNJfeiJ0(ibfm6D40IWRrMegIKb2KMv52n049qkasJ7mScm0DaAaEowqGms7JKUT7g901Tg4n07SfNWQLHeLzVOQLPWpPOSfyKcGy4oWsqgP9rckTT0VUoGNJfeiJ0(ibDhCXHtlcVgzsyisgytAwHVGld4SpeilRPhbJUdqtu1Yu4Nuu2cmsbqmChyjiJ0(iPJE7MUUOQLPWpPOSfyKcGy4oWsqgP9rcky66G3qVZwCcRwgsugDDaphliqgP9rckyAC4GR3VlL89ApOOh(EnliKN4Eh4EuL99nKVhXLsFYVVJ7xClJ73Ep9bZVVhZ94Rzxe3lAl3ZddZrDpEpW85Ens07EjlQXipCAr41itcdrYaBsZQgk6HjrbH8eO7a0eyEcP1gUjWC6OTDppmmhvkCeMefbP1gD00irVdNweEnYKWqKmWM0SYwYepye0NgHPTSLbSSLK8Az4HyzzJ05m6oanrvltHFsrzlWifaXWDGLGms7Je0T66IQwMc)KIYwGrkaIH7albzK2hjDGPHUo4n07SfNWQLHeLrxhWZXccKrAFKGsdmnoCAr41itcdrYaBsZkBjt8GrqNbayrqMgHPLVAJ3rbLee20RLxd6oanrvltHFsrzlWifaXWDGLGms7Je0T66IQwMc)KIYwGrkaIH7albzK2hjDGPHUo4n07SfNWQLHeLrxhWZXccKrAFKGsdmnoCAr41itcdrYaBsZkBjt8GrqNbayrqMgHPLVAJ3rbLegjBXiO7a0a8CSGazK2hjDBP3UQRlQAzk8tkkBbgPaigUdSeKrAFKGUvxh8g6D2Ity1YqIYC40IWRrMegIKb2KMvrzlWifaXWDGHUdqZAG3qVZwCcRwgsuM9G0AS1z7wSWMKaLyvbSgxqYwTm01fvTmf(jjqjwvaRXfKSvlJeKrAFKGsBli2dsbMt3wDDEyyokqPFnaXHtlcVgzsyisgytAwjJcIq4ggyKEmeahYOJUdqtu1Yu4NKmkicHByGr6XqaCiNeynmNL0atx3urkkBbgPaigUdSeKrAFK66aEowqGms7JeuW0qxhKz2aaj8fCzaN9Hazzn9i4eKrAFK0TvdDDrvltHFs4l4Yao7dbYYA6rWjiJ0(iPtu1Yu4NKmkicHByGr6XqaCiNaSxlcKfynmNjHJW66wJLsEeCcFbxgWzFiqwwtpcoH0ANccI9Guu1Yu4Nuu2cmsbqmChyjiJ0(iPtu1Yu4NKmkicHByGr6XqaCiNaSxlcKfynmNjHJW66G3qVZwCcRwgsuM9wJToB3If2KmqplB5toXh0SugqSxu1Yu4NeGldjPaia2qujiJ0(ibL2UUxG50rBN9IQwMc)KWJ5WLp5edSZRHyXEeyjiJ0(ibL22DoCAr41itcdrYaBsZQOSfyKcGGwdrA0DaAaEowqGms7JKUT0Bx11nvKIYwGrkaIH7albzK2hPUo4n07SfNWQLHeL5WPfHxJmjmejdSjnRYwvzifajWycpmck0DaAIQwMc)KIYwGrkaIH7albzK2hjD0p901bVHENT4ewTmKOm7fvTmf(jb4YqskacGnevcYiTpsqbtxhWZXccKrAFKGUfmDDaphliqgP9rs3wn0ypGNJfeiJ0(ibD7wn2dsrvltHFsaUmKKcGaydrLGms7Je0D01fvTmf(jHhZHlFYjgyNxdXI9iWsqgP9rck901fvTmf(jbDPp5eP9qqZfOLGms7Jeu6bIdNweEnYKWqKmWM0SsuJGNa2bBiaRgHr3bOzntfjrncEcyhSHaSAeMKzdNeKrAFK7bjifvTmf(jjQrWta7GneGvJWjiJ0(ibLMOQLPWpPOSfyKcGy4oWsqgP9rU5wDDWBO3zloHvldjkdi2dsRf9INiHhZHlFYjgyNxdXI9iWs80zl2ORlQAzk8tcpMdx(KtmWoVgIf7rGLGms7Jee7fvTmf(jbDPp5eP9qqZfOLGms7JCVOQLPWpjaxgssbqaSHOsqgP9rUpZgaijJcIq4ggyKEmeahYjtHF01nvKIYwGrkaIH7albzK2hji01b8CSGazK2hjO72HdUE)UuY3VXQkZ94sBiQ7DG71SSfy3xa3B95oW2fY7fvTmf(5ExEFoK7GH3hy9C)oACpidmxEVpILTHL3JhZx89Aww)7D59cBiKNyH6(weo4miq)(cEFbaCVOQLPWp3JhJN7rv233q(ESAz8j)(AI6EnlRp63xW7XJXZ9bgFF0WCoU3L33zLDCFu3BC(WPfHxJmjmejdSjnRYwvzia2quO7a0evTmf(jfLTaJuaed3bwcYiTps62rdDDWBO3zloHvldjkJUoGNJfeiJ0(ibfmnoCAr41itcdrYaBsZQmgkziA(KJUdqtu1Yu4Nuu2cmsbqmChyjiJ0(iPBhn01bVHENT4ewTmKOm66aEowqGms7Je0T07WPfHxJmjmejdSjnRwEowijAhBtocpXHtlcVgzsyisgytAwb4qoBvLbDhGMOQLPWpPOSfyKcGy4oWsqgP9rs3oAORdEd9oBXjSAzirz01b8CSGazK2hjOB14WPfHxJmjmejdSjnR6rWYa2lIOxl0DaAIQwMc)KIYwGrkaIH7albzK2hjD7OHUo4n07SfNWQLHeLrxhWZXccKrAFKGcMghoTi8AKjHHizGnPzvwNtkasaDbAYdNweEnYKWqKmWM0SYwYepye0NgHPzPeOXH0XD2qefIf7OdVgIHb3fm6O7a0evTmf(jfLTaJuaed3bwcYiTps62rdDDWBO3zloHvldjkZHtlcVgzsyisgytAwzlzIhmc6tJW0Gmsfmj32n9iyIHb3fm6oanrvltHFsrzlWifaXWDGLGms7JKUD0qxh8g6D2Ity1YqIYC40IWRrMegIKb2KMv2sM4bJGodaWIGmnctlF1gVJckjzTjNr3bOjQAzk8tkkBbgPaigUdSeKrAFK0bMg66G3qVZwCcRwgsugDDaphliqgP9rckyAC40IWRrMegIKb2KMv2sM4bJG(0imT8EXIETyOKKv1GUdqtu1Yu4Nuu2cmsbqmChyjiJ0(iPJE0txh8g6D2Ity1YqIYORd45ybbYiTpsq3c2HtlcVgzsyisgytAwzlzIhmc6tJW0Wd9aZNCIKZr4jifaXazz05DGHUdqtu1Yu4Nuu2cmsbqmChyjiJ0(iPdmn01bVHENT4ewTmKOmhoTi8AKjHHizGnPzLTKjEWiOpnctRLyG3dljWg3liruWEHUdqd8g6D2Itrzi1qSLmjG(Ggh7bPOQLPWpPOSfyKcGy4oWsqgP9rshyB11bVHENT4ewTmKOmGypinCMnaqc24EbjIc2lIHZSbasMc)ORNzdaKKrbriCddmspgcGd5eKrAFK0TDhDDaphliqgP9rIBIQwMc)KIYwGrkaIH7albzK2hjO0Vg7fvTmf(jfLTaJuaed3bwcYiTpsqbJE66aEowqGms7JeuWOhioCAr41itcdrYaBsZkBjt8GrqFAeMwlXaVhwsGnUxqIOG9cDhGM1aVHENT4uugsneBjtcOpOXXEqA4mBaGeSX9csefSxedNzdaKmf(rxhKwJToB3If2KmqplB5toXh0SugD9OH5CKchHjrrSicYoAKGms7Je0Dde7bPPIuu2cmsbqmChyjiJ0(i11fvTmf(jfLTaJuaed3bwcYiTpYn3v6a8CSGazK2hji2NzdaKKrbriCddmspgcGd5KTfDDaphliqgP9rcky0dehoTi8AKjHHizGnPzvGXe7jRShdbOGc(WPfHxJmjmejdSjnRSydDau(KtYwTmoCW17PVvlZ97EUT4t(94YvJWY7bk49S2yHDW3d7jNVVG3JMVw3Nzdair)Eh4ElLu6zloDV2BHVrjVpGOUpQ7Z54(aJVFv4zzCVOQLPWp3N1s2CFn33G3(QZw898WiolthoTi8AKjHHizGnPzfKBl(Ktawnclr3bOLzdaKKmKhpqLmf(zpiJgMZrkCeMefXIiiGPbD7OHUE0WCosyCVcSKfraknW0ae66rdZ5ifoctIIyCguWoCAr41itcdrYaBsZkGsylzdPXDg6btY4g5WPfHxJmjmejdSjnRqyKcIIuaKLTWnedKBej6oanEyyokqPFnoCAr41itcdrYaBsZkOBXYIj(qKwAbF40IWRrMegIKb2KMvzDoPaib0fOjpCAr41itcdrYaBsZkBjt8GrKO7a0ajBD2UflSjjqjwvaRXfKSvlJ9IQwMc)KeOeRkG14cs2QLrcYiTpsqPbMgGqx3AS1z7wSWMKaLyvbSgxqYwTmoCoCW17PpvTmf(rE40IWRrMegIKH84bkA(aEHgt0MnpKaJj4X8GjHNZq0DaAz2aajjd5XdujtHF01b8CSGazK2hjOGrVdNweEnYKWqKmKhpqTjnRSLmXdgb9PryAnUlXAylja1eKcGyPWZq0DaAz2aajjd5XdujtHF2dsrvltHFssgYJhOsqgP9rckyAORd45ybbYiTpsqPFnaXHtlcVgzsyisgYJhO2KMv52n049qkasJ7mScm0DaAz2aajjd5XdujtHF2dsaphliqgP9rs32DJE66IQwMc)KKmKhpqLGms7JeuAAFqORd45ybbYiTpsq3HEhoTi8AKjHHizipEGAtAwLTQYqaSHOq3bOjQAzk8tsYqE8avcYiTps6atdDDaphliqgP9rckyAC40IWRrMegIKH84bQnPzvgdLmenFYr3bOjQAzk8tsYqE8avcYiTps6atdDDaphliqgP9rc6w6D4GR3VlL89ApOOh(EnliKN4Eh4EkgYJhOU3L3pvCVTf0VVhZ9Ok77BiFpIlL(KFFh3V4wg3V9E6dMJ(99yUhFn7I4ErB5EEyyoQ7X7bMp3RrIE3lzrng5HtlcVgzsyisgYJhO2KMvnu0dtIcc5jq3bOLzdaKKmKhpqLmf(zVaZtiT2WnbMthTT75HH5OsHJWKOiiT2OJMgj6D40IWRrMegIKH84bQnPz1YZXcjr7yBYr4joCAr41itcdrYqE8a1M0ScWHC2Qkd6oanrvltHFssgYJhOsqgP9rshyAORd45ybbYiTpsq3QXHtlcVgzsyisgYJhO2KMv9iyza7fr0Rf6oanrvltHFssgYJhOsqgP9rshyAORd45ybbYiTpsqbtJdNweEnYKWqKmKhpqTjnRY6CsbqcOlqtE40IWRrMegIKH84bQnPzLTKjEWiOpnctBzldyzlj51YWdXYYgPZz0DaAIQwMc)KIYwGrkaIH7albzK2hjOB11fvTmf(jfLTaJuaed3bwcYiTps6atdDDWBO3zloHvldjkJUoGNJfeiJ0(ibLgyAC40IWRrMegIKH84bQnPzLTKjEWiOZaaSiitJW0YxTX7OGsccB61YRbDhGMOQLPWpPOSfyKcGy4oWsqgP9rc6wDDrvltHFsrzlWifaXWDGLGms7JKoW0qxh8g6D2Ity1YqIYORd45ybbYiTpsqPbMghoTi8AKjHHizipEGAtAwzlzIhmc6maalcY0imT8vB8okOKWizlgbDhGgGNJfeiJ0(iPBl92vDDrvltHFsrzlWifaXWDGLGms7Je0T66G3qVZwCcRwgsuMdNweEnYKWqKmKhpqTjnRIYwGrkaIH7adDhGM1aVHENT4ewTmKOmhoTi8AKjHHizipEGAtAwfLTaJuae0AisJUdqdWZXccKrAFK0TLE7QUUPIuu2cmsbqmChyjiJ0(i11bVHENT4ewTmKOmhoTi8AKjHHizipEGAtAwzlzIhmc6tJW0Suc04q64oBiIcXID0HxdXWG7cgDhGwMnaqsYqE8avYu4N9Guu1Yu4Nuu2cmsbqmChyjiJ0(iPBRg66G3qVZwCcRwgsugqORd45ybbYiTpsqP3HtlcVgzsyisgYJhO2KMvzRQmKcGeymHhgbf6oaTmBaGKKH84bQKPWp7bPOQLPWpjjd5XdujiJ0(iPdmn01fvTmf(jjzipEGkbzK2hjOGbcDDaphliqgP9rc6w6D40IWRrMegIKH84bQnPzLTKjEWiOpnctdYivWKCB30JGjggCxWO7a0evTmf(jfLTaJuaed3bwcYiTps62QHUo4n07SfNWQLHeL5WPfHxJmjmejd5XduBsZkBjt8GrqNbayrqMgHPLVAJ3rbLKS2KZO7a0evTmf(jjzipEGkbzK2hjDGPHUoGNJfeiJ0(ibfmnoCAr41itcdrYqE8a1M0SYwYepye0NgHPL3lw0RfdLKSQg0DaAIQwMc)KKmKhpqLGms7JKoW0qxhWZXccKrAFKGcMghoTi8AKjHHizipEGAtAwzlzIhmc6tJW0Wd9aZNCIKZr4jifaXazz05DGHUdqtu1Yu4Nuu2cmsbqmChyjiJ0(iPBRg66G3qVZwCcRwgsuMdNweEnYKWqKmKhpqTjnRSLmXdgb9PryATed8Eyjb24EbjIc2l0DaAgoZgaibBCVGerb7fXWz2aajtHF01ZSbassgYJhOsqgP9rs3UQRd45ybbYiTpsqbJEhoTi8AKjHHizipEGAtAwHVGld4SpeilRPhbJUdqlZgaijzipEGkzk8ZEqkQAzk8tsYqE8avcYiTps62spDDrvltHFssgYJhOsqgP9rckyGqxhWZXccKrAFKGcMghoTi8AKjHHizipEGAtAwjQrWta7GneGvJWO7a0YSbassgYJhOsMc)ShKIQwMc)KKmKhpqLGms7Juxxu1Yu4NKOgbpbSd2qawncNeynmNL0ade7TMPIKOgbpbSd2qawnctYSHtcYiTpY9Guu1Yu4Ne0L(KtK2dbnxGwcYiTpY9IQwMc)KaCzijfabWgIkbzK2hPUoGNJfeiJ0(ibD3aXHtlcVgzsyisgYJhO2KMvsgYJhOoCAr41itcdrYqE8a1M0SkWyI9Kv2JHauqbJUdqlZgaijzipEGkzk8ZHtlcVgzsyisgYJhO2KMvwSHoakFYjzRwgO7a0YSbassgYJhOsMc)C40IWRrMegIKH84bQnPzfKBl(Ktawnclr3bOLzdaKKmKhpqLmf(zpiJgMZrkCeMefXIiiGPbD7OHUE0WCosyCVcSKfraknW0ae66rdZ5ifoctIIyCguWoCAr41itcdrYqE8a1M0ScOe2s2qACNHEWKmUrq3bOLzdaKKmKhpqLmf(5WPfHxJmjmejd5XduBsZkegPGOifazzlCdXa5grIUdqlZgaijzipEGkzk8ZEEyyokqPFnoCAr41itcdrYqE8a1M0Sc6wSSyIpePLwWO7a0YSbassgYJhOsMc)C40IWRrMegIKH84bQnPzvwNtkasaDbAs0DaAz2aajjd5XdujtHFoCAr41itcdrYqE8a1M0SYwYepyej6oaTmBaGKKH84bQKPWp7bjizRZ2TyHnjbkXQcynUGKTAzSxu1Yu4NKaLyvbSgxqYwTmsqgP9rcknW0ae66wJToB3If2KeOeRkG14cs2QLbioCoCW17PVc9c6bQ7XJ5l(Ejd5Xdu37Y7TTC40IWRrMKmKhpqrdWLHKuaeaBik0DaAz2aajjd5XdujiJ0(ibDRUElchCMWdJ4SKUThoTi8AKjjd5XduBsZkPfFgFYjcypmbnxGg6oanrHKvezaD049GSfHdot4HrCwshy66TiCWzcpmIZs62U3AIQwMc)KGU0NCI0EiO5c0s2waXHtlcVgzsYqE8a1M0Sc6sFYjs7HGMlqdDbkXIjrdZ5qsBl6oanrHKvezaD04dhC9EnXC594916ErlJ7XLfU8(Em37tWqOTL4(aJVxG1ZWR7DG7dm((Dh0hR)9U8Ei3gu33J5EzHWbMp53J55ym8(AUpW47Ta9c6bQ7xUmUhK7EkTlqCVlVVbV9vNT40HtlcVgzsYqE8a1M0ScWLHKuaeaBik09jyi02sqCaA5ctcYiTpsAAC40IWRrMKmKhpqTjnRaCzqkasGXe8yEWKWZzi6cuIftIgMZHK2w0DaAcmh0DoCAr41itsgYJhO2KMvqgCgkzcwdrq3bOjW8esRnCtG50TDppmmhvkCeMefbP1gOBpCW173Ls((nkTl0V3J7X7R191SqDFgKB0UhPLbdrDVdCp9npUN(uiz19U8ETOVRM3h9INGnhoTi8AKjjd5XduBsZQSvlqRSdcAUan0fOelMenmNdjTTO7a0efswrKb0rJ11Tw0lEIeMherHKvjE6SfBoCAr41itsgYJhO2KMvsl(m(KteWEycAUaTdNdNweEnYKmOHhZHlFYjgyNxdXI9iWoCAr41itYytAwb4YqskacGnef6oaTOx8ejjd5XdujE6SfB01fvTmf(jfLTaJuaed3bwcYiTps6Wf66G3qVZwCcRwgsuMdhC9(DPKVF3tPDDFn3hnmNd5949aRSJ73D2q0UVaUpW47PpWE47nCMnaa637a3BPKspBXOFFpM7DG71SS(37Y774(f3Y4EWUxYIAmY7B8nQdNweEnYKm2KMvqx6torApe0CbAOlqjwmjAyohsABr3bOf9INijzipEGkXtNTyJUUOQLPWpPOSfyKcGy4oWsqgP9rshy66G3qVZwCcRwgsuMdNweEnYKm2KMvqBjMp5eTtBycEFmO7a0YSbasqBjMp5eTtBycEFmjtHF23IWbNj8WiolPB7HtlcVgzsgBsZkidodLmbRHiO7a0eyEcP1gUjWC62E40IWRrMKXM0ScWLbPaibgtWJ5btcpNHOlqjwmjAyohsABr3bOjWCq35WPfHxJmjJnPzfpmm3XDFYj8Y1Mdr3bOjWCqPTZEEyyokqPNgho4697sjFp9zJ7DG7rv233q(EKcY3hy9CVg3tFW87B8nQ7bGfY9iT2UVhZ9yn489BVNhgbf63xW7BiFpsb57dSEUF790hm)(gFJ6EayHCpsRTdNweEnYKm2KMvcmNKzdLb6oanbMNqATHBcmNon23IWbNj8WiolPTvxxG5jKwB4MaZPB7HdUE)UuY3Rj917DG7rv233q(E6)(cEpsb57fy(9n(g19aWc5EKwB33J5EnlR)99yUNY6fxEFd57ZQa7(PI7TTC40IWRrMKXM0Sk8CgsS0le0fOelMenmNdjTTO7a0efswrKb0rJ3lW8esRnCtG50TZERzQifLTaJuaed3bwcYiTpY9z2aajzuqec3WaJ0JHa4qozk8ZHtlcVgzsgBsZkbMtW3GZhoTi8AKjzSjnRKw8z8jNiG9We0CbAO7a0efswrKb0rJ3NzdaKm9iysbqeyU2XtqUfXHdUE)UuY3VrPDDVdCFwfy3JllC599yUF3tPDDFd57NkUxSkjJ(9f8(DpL219U8EXQK899yUhxw4Y7D59tf3lwLKVVhZ9Ok77XAW57rkiFFG1Z9GDVaZr)(cEpUSWL37Y7fRsY3V7P0UU3L3pvCVyvs((Em3JQSVhRbNVhPG89bwp3VZ9cmh97l49Ok77XAW57rkiFFG1Z907EbMJ(9f8Eh4EuL995CCFFVfyjoCAr41itYytAwLTAbALDqqZfOHUaLyXKOH5CiPTfDhGMOqYkImGoA8EqcYOx8ejjd5XdujE6SfB01fvTmf(jfLTaJuaed3bwcYiTps6atxh8g6D2Ity1YqIYaI9Guu1Yu4Ne0L(KtK2dbnxGwcYiTps6aBVOQLPWpjaxgssbqaSHOsqgP9rshy66IQwMc)KGU0NCI0EiO5c0sqgP9rc6o7fvTmf(jb4YqskacGnevcYiTps62zVaZPdmDDrvltHFsqx6torApe0CbAjiJ0(iPBN9IQwMc)KaCzijfabWgIkbzK2hjO7SxG50r)66cmNo6bcD9mBaGuwHgXcSejBlG4WPfHxJmjJnPzv45mKyPxiOlqjwmjAyohsABr3bOjkKSIidOJgVxG5jKwB4MaZPB7HdUE)UuY3JlP0UUVhZ9(emeABjU3J7LbS9CS4(gFJ6WPfHxJmjJnPzfWcLp5ejdTWtqqZfOHUpbdH2wcABpCW173Ls((nkTR7DG7XLfU8ExEVyvs((Em3JQSVhRbNVhS7fy(99yUhvzdVF1Y4(8vL1R7X3Y71K(k63xW7DG7rv233q((oRSJ7J6ErB5EEyyoQ77XCp7bgdVhvzdVF1Y4(CH5E8T8EnPVEFbV3bUhvzFFd57xSuEFG1Z9GDVaZVVX3OUhawi3lAlw8j)WPfHxJmjJnPzv2QfOv2bbnxGg6cuIftIgMZHK2w0DaAIcjRiYa6OX7bPOQLPWpjaxgssbqaSHOsqgP9rc6o7fyonW015HH5OsHJWKOiiT2aDli2dslqgCsUWK2McpNHel9crxxG5jKwB4MaZbfmqOOA7aRGkkkhH(OcvOua]] )

end