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
    
    spec:RegisterPack( "Windwalker", 20200614, [[d4e7pcqiaPhHIInbGprsPmkjvDkjvELKsZciDluuAxs8lsQggj4ykfldiEMsPMgGW1qr12ae13ukHgNsj6CkLK1rsrmpa6EOu7df6GKuOfkP4HKqYevkbxKKIQnciYhvkPIrscP0jvkPQvII8ssksZKesvDtLsQ0ojj9tsivPHscPYsvkP8ucMkjXvjPuTvsivXxjHumwskk7Lu)fYGv1HvSyj5XOAYuCzKndvFwPA0e60cRMKcEnky2k52qz3Q8BrdNeDCskz5GEortNQRtP2oG67OKXtc15bQ1tcX8PK9l16nAv0cMXjTQGOaikOaqEdqu2WCqaYByUwWbRK0ckhodZoPfUbJ0ckAIZWAwmqqTGYb8khJwfTGmTHCsli6UsPAI6QVhUODvHNyQldm714rEC4G7QldmU6AHk7y5B9NUslygN0QcIcGOGca5narzdZbbiVzBTGujX1QccqER0cIHXqNUslyijxlWm9ROjodRzXab7FRBEm0mXm9l6UsPAI6QVhUODvHNyQldm714rEC4G7QldmU6ntmt)mzFu)Bacq7hefarHMPMjMPFfL4C7KunPzIz6Nz7FRryjWu)ckPb2VI25m9l4WGbQFEEgpYt2F9IZzwKP)kW9pgtE1vAMyM(z2(vuIZTt97dCNCuG3VN9ZbZxeYh4o5YsZeZ0pZ2)wJWsGP(PJG7G7Npk7NlsCg6hpH9dKcPl7pX7hizdb3F9YaRFtGJtq64u)HS)J2xXEuTiq7VY27x5Aa3VjWXjiDCQ)q2Vm2Vap4Z51vAMyM(z2(vJgdz6xTlP(36Dct2F9omogixcA)KZl1v0cRq6sTkAbUbjjCTkAv3Ovrlq3uTiJUgTahgobJrluzJJxKeKUWbxmjRRFlR(9aJqEImb1pG9dcZ1cd3J80cXbCYaHuSnDAxRkiAv0c0nvlYORrlWHHtWy0cEGriprMG6NX(3SLmVFlR(bA)apWyQwurmxgKNM(bOFEMltY6kEAZfrjoYqJlwGe2eNSFaz3)gGOFlR(9aJqEImb1pG9VnZ1cd3J80c72d0eZHsC0OiemDrTRvDBTkAb6MQfz01Of4WWjymAbEMltY6kEAZfrjoYqJlwGe2eNSFg7N5Bz)ww9ZZCzswxXtBUikXrgACXcKWM4K9dy)G0VLv)apWyQwurmxgKNM(TS63dmc5jYeu)a2pikOfgUh5PfyLWLbykoeKK5nhN0UwvGqRIwGUPArgDnAbomCcgJwGlgfSrX9ZS9ZfJ(zKD)B6hG(PJG7GlEGripryJI7Nr29RqH5AHH7rEAHbYNJqEcH05AxRkZ1QOfOBQwKrxJwy4EKNwyzlDyAlr75Yqhs5YgB2jTahgobJrlWZCzswxXtBUikXrgACXcKWM4K9dy)B63YQFEMltY6kEAZfrjoYqJlwGe2eNSFg7hef63YQFG2pWdmMQfveZLb5PPFlR(9aJqEImb1pG9dcZ1c3GrAHLT0HPTeTNldDiLlBSzN0UwvGSwfTaDt1Im6A0cd3J80c7RXeJNqjcJmZAf5Pf4WWjymAbEMltY6kEAZfrjoYqJlwGe2eNSFa7Ft)ww9ZZCzswxXtBUikXrgACXcKWM4K9Zy)GOq)ww9d0(bEGXuTOIyUmipn9Bz1VhyeYtKjO(bSFquqlCdgPf2xJjgpHsegzM1kYt7Av3IAv0c0nvlYORrlWHHtWy0caTFGhymvlQiMldYtt)a0F99d0(j1YouQKmfoy(kDyEbhvTgP3VLv)8mxMK1v4G5R0H5fCu1AKEbsytCY(bKD)B6VU(bO)67Nlg9Zy)B63YQF6i4o4(bSFGqH(RtlmCpYtl4PnxeL4idnUO21QULAv0c0nvlYORrlWHHtWy0c8mxMK1vKEcXq0aDr0CgeEaPcxCG7KSF29ds)ww9BsV4PnxeL4idnUybsytCY(TS63dmc5jYeu)a2pik0VLv)13FLnoEHvcxgGP4qqsM3CCQajSjoz)m2)gf63YQFEMltY6kSs4YamfhcsY8MJtfiHnXj7NX(5zUmjRRi9eIHOb6IO5mi8asfC71cbjU4a3jKhyu)ww9d0(jPKoovyLWLbykoeKK5nhNkyJAiH9xx)a0F99ZZCzswxXtBUikXrgACXcKWM4K9Zy)8mxMK1vKEcXq0aDr0CgeEaPcU9AHGexCG7eYdmQFlR(bEGXuTOIyUmipn9dq)aTFsTSdLkjtXaJQQvC7O4yqzA6VU(bOFEMltY6k4H0LOehHBdbxGe2eNSFaz3)w1pa9ZfJ(zKD)B3pa9ZZCzswxHLyaxXTJmWzppKs7JlwGe2eNSFaz3)MT1cd3J80cspHyiAGUiAodcpGK21QUvAv0c0nvlYORrlWHHtWy0c8mxMK1v80MlIsCKHgxSajSjoz)m2pqW8(TS6h4bgt1IkI5YG800pa9ZZCzswxbpKUeL4iCBi4cKWM4K9dy)G0VLv)EGriprMG6hW(3as)ww97bgH8ezcQFg7FJck0pa97bgH8ezcQFa7FZgf6hG(RVFEMltY6k4H0LOehHBdbxGe2eNSFa7F7(TS6NN5YKSUclXaUIBhzGZEEiL2hxSajSjoz)a2pZ73YQFEMltY6kWqg3osAFigcodfiHnXj7hW(zE)1PfgUh5PfQwzAqjoYfjeDegyTRvDJcAv0c0nvlYORrlWHHtWy0caTFt6fEEC6C44KbHVgmcvzdVcKWM4K9dq)13F99ZZCzswxHNhNohoozq4RbJkqcBIt2pGS7NN5YKSUIN2CruIJm04IfiHnXj7V2(30VLv)apWyQwurmxgKNM(RRFa6V((bA)(SOZlSed4kUDKbo75HuAFCXcDt1Im9Bz1ppZLjzDfwIbCf3oYaN98qkTpUybsytCY(RRFa6NN5YKSUcmKXTJK2hIHGZqbsytCY(bOFEMltY6k4H0LOehHBdbxGe2eNSFa6VYghVi9eIHOb6IO5mi8asftY663YQFt6fpT5IOehzOXflqcBIt2FD9Bz1VhyeYtKjO(bS)TulmCpYtlWZJtNdhNmi81GrAxR6MnAv0c0nvlYORrlWHHtWy0c8mxMK1v80MlIsCKHgxSajSjoz)m2)2k0VLv)apWyQwurmxgKNM(TS63dmc5jYeu)a2pikOfgUh5PfQwzAq42qWAxR6gq0QOfOBQwKrxJwGddNGXOf4zUmjRR4PnxeL4idnUybsytCY(zS)TvOFlR(bEGXuTOIyUmipn9Bz1VhyeYtKjO(bS)nmxlmCpYtlurqjbziUDTRvDZ2Av0cd3J80cRyx0Li1GTzhJoxlq3uTiJUgTRvDdqOvrlq3uTiJUgTahgobJrlWZCzswxXtBUikXrgACXcKWM4K9Zy)BRq)ww9d8aJPArfXCzqEA63YQFpWiKNitq9dy)BuqlmCpYtlGhqQALPr7Av3WCTkAb6MQfz01Of4WWjymAbEMltY6kEAZfrjoYqJlwGe2eNSFg7FBf63YQFGhymvlQiMldYtt)ww97bgH8ezcQFa7hef0cd3J80cZXjPdNfIpRL21QUbiRvrlmCpYtlun7Oeh5WGZGulq3uTiJUgTRvDZwuRIwGUPArgDnAHH7rEAbLjNbYLHIqgepXuA7Jh5HmeWbN0cCy4emgTapZLjzDfpT5IOehzOXflqcBIt2pJ9VTc9Bz1pq7h4bgt1IkI5YG80OfUbJ0cktodKldfHmiEIP02hpYdziGdoPDTQB2sTkAb6MQfz01OfgUh5PfGew6eA3omZXjKHao4KwGddNGXOf4zUmjRR4PnxeL4idnUybsytCY(zS)TvOFlR(bA)apWyQwurmxgKNgTWnyKwasyPtOD7WmhNqgc4GtAxR6MTsRIwGUPArgDnAHH7rEAH91yIXtOevnMDslWHHtWy0c8mxMK1v80MlIsCKHgxSajSjoz)m2pik0VLv)aTFGhymvlQiMldYtt)ww97bgH8ezcQFa7hef0c3GrAH91yIXtOevnMDs7AvbrbTkAb6MQfz01OfgUh5Pf2NfXN1IGsuvMNwGddNGXOf4zUmjRR4PnxeL4idnUybsytCY(zSFMZ8(TS6h4bgt1IkI5YG800VLv)EGriprMG6hW(3aIw4gmslSplIpRfbLOQmpTRvfKnAv0c0nvlYORrlmCpYtlWcgUyC7ijTJrNJsCKbssF2hxulWHHtWy0c8mxMK1v80MlIsCKHgxSajSjoz)m2pik0VLv)aTFGhymvlQiMldYtJw4gmslWcgUyC7ijTJrNJsCKbssF2hxu7AvbbeTkAb6MQfz01OfgUh5PfgPiWZrseCuKeI4jCwAbomCcgJwa4bgt1IkEAq5HSLeYHXXa59dq)13ppZLjzDfpT5IOehzOXflqcBIt2pJ9dYM(TS6h4bgt1IkI5YG800FD9dq)13VHQSXXlWrrsiINWzHmuLnoEXKSU(TS6VYghVi9eIHOb6IO5mi8asfiHnXj7NX(3SD)ww97bgH8ezcQFMTFEMltY6kEAZfrjoYqJlwGe2eNSFa7hiuOFa6NN5YKSUIN2CruIJm04IfiHnXj7hW(bH59Bz1VhyeYtKjO(bSFqyE)1PfUbJ0cJue45ijcokscr8eolTRvfKT1QOfOBQwKrxJwy4EKNwyKIaphjrWrrsiINWzPf4WWjymAbG2pWdmMQfv80GYdzljKdJJbY7hG(RVFdvzJJxGJIKqepHZczOkBC8IjzD9Bz1F99d0(j1YouQKmfdmQQwXTJIJbLPPFlR(9bUtEXdmc5jsj3rBRq)a2)w2FD9dq)13Vj9IN2CruIJm04IfiHnXj73YQFEMltY6kEAZfrjoYqJlwGe2eNS)A7FR6NX(9aJqEImb1FD9dq)v244fPNqmenqxenNbHhqQyRSFlR(9aJqEImb1pG9dcZ7VoTWnyKwyKIaphjrWrrsiINWzPDTQGaeAv0cd3J80cUiHSVQ0(mi8eYjTaDt1Im6A0UwvqyUwfTWW9ipTGsByGdoUDu1AKUwGUPArgDnAxRkiazTkAb6MQfz01OfgUh5PfG0OmUDe(AWiPwGddNGXOf8bUtEXdmc5jYeu)a2)McZ73YQ)67V((9bUtErKMLlwuY9(zS)TuH(TS63h4o5frAwUyrj37hq29dIc9xx)a0F99pCpaMq0rybj7ND)B63YQFFG7Kx8aJqEImb1pJ9dYw1FD9xx)ww9xF)(a3jV4bgH8ePK7iquOFg7FBf6hG(RV)H7bWeIocliz)S7Ft)ww97dCN8IhyeYtKjO(zSFGai6VU(RtlWbZxeYh4o5sTQB0Uwvq2IAv0cd3J80c4j3wsg0OiemCcvrdMwGUPArgDnAxRkiBPwfTaDt1Im6A0cCy4emgTaDeChC)a2pqOGwy4EKNwaJWsiyuIJw28WGmqAWKAxRkiBLwfTWW9ipTamuQCrO4qsLdN0c0nvlYORr7Av3wbTkAHH7rEAHQzhL4ihgCgKAb6MQfz01ODTQBVrRIwGUPArgDnAbomCcgJwO((j1YouQKmfoy(kDyEbhvTgP3pa9ZZCzswxHdMVshMxWrvRr6fiHnXj7hq29dIc9xx)ww9d0(j1YouQKmfoy(kDyEbhvTgPRfgUh5PfSLekCctQDTRfme(yVCTkAv3OvrlmCpYtlivsdejoNbjDyWaPfOBQwKrxJ21QcIwfTqCobbEwAHTsbTGsUJePz5IAbfkmxlmCpYtl4PnxeL4iggi2OfOBQwKrxJ21QUTwfTaDt1Im6A0cCy4emgTqLnoErsq6chCXwz)ww9xzJJxKEcXq0aDr0CgeEaPITY(bOFt6fpT5IOehzOXflqcBIt2VLv)EGriprMG6hq29dKvqlmCpYtlOm9ipTRvfi0QOfOBQwKrxJwGddNGXOf4IrbBuC)mB)CXOFgz3pi9dq)13Vpl68IKG0fo4cDt1Im9Bz1pq73KEXtBUikXrgACXcKWM4K9xx)a0FLnoErsq6chCXKSU(bO)67NocUdU4bgH8eHnkUFa7Ft)ww97ZIoVijiDHdUq3uTit)a0ppZLjzDfjbPlCWfiHnXj7hW(bPFlR(bA)(SOZlscsx4Gl0nvlY0pa9ZZCzswxXtBUikXrgACXcKWM4K9dy)B3pa9d0(bEGXuTOIyUmipn9Bz1pDeChCXdmc5jcBuC)a2pq0pa9ZZCzswxbpKUeL4iCBi4cKWM4K9dy)BkmV)60cd3J80cqcyckjK4aX0UwvMRvrlq3uTiJUgTWW9ipTaEiDuIJCrcXsmCc5Xob1cCy4emgTaxmkyJI7Nz7Nlg9Zi7(3UFa6VYghVijiDHdUyswx)a0FLnoErsKlg3oco7uXKSU(bO)67NocUdU4bgH8eHnkUFa7Ft)ww97ZIoVijiDHdUq3uTit)a0ppZLjzDfjbPlCWfiHnXj7hW(bPFlR(bA)(SOZlscsx4Gl0nvlY0pa9ZZCzswxXtBUikXrgACXcKWM4K9dy)B3pa9d0(bEGXuTOIyUmipn9Bz1pDeChCXdmc5jcBuC)a2pq0pa9ZZCzswxbpKUeL4iCBi4cKWM4K9dy)BkmV)60cCW8fH8bUtUuR6gTRvfiRvrlq3uTiJUgTWW9ipTGh7eePCwyAbomCcgJwaO9ZtSQevbPHH(bOFUyuWgf3pZ2pxm6Nr29ds)a0F997ZIoVijiDHdUq3uTit)ww9d0(nPx80MlIsCKHgxSajSjoz)ww9pCpaMq0rybj7NX(bP)66hG(RSXXlsICX42rWzNkMK11pa9xzJJxKeKUWbxmjRRFa6V((PJG7GlEGripryJI7hW(30VLv)(SOZlscsx4Gl0nvlY0pa9ZZCzswxrsq6chCbsytCY(bSFq63YQFG2Vpl68IKG0fo4cDt1Im9dq)8mxMK1v80MlIsCKHgxSajSjoz)a2)29dq)aTFGhymvlQiMldYtt)ww9thb3bx8aJqEIWgf3pG9de9dq)8mxMK1vWdPlrjoc3gcUajSjoz)a2)McZ7VoTahmFriFG7Kl1QUr7Av3IAv0c0nvlYORrlWHHtWy0caTFFw05f8q6Oeh5IeILy4eYJDcwOBQwKPFa6xjKagTZnLnfp2jis5SW6hG(9aJ6hq29VTwy4EKNwGlgiwdWK21QULAv0c0nvlYORrlWHHtWy0c(SOZlscsx4Gl0nvlYOfgUh5Pf4ZAHgUh5HwH01cRq6OBWiTa3GKeKUWbRDTQBLwfTaDt1Im6A0cCy4emgTaq73NfDErsq6chCHUPArgTWW9ipTaFwl0W9ip0kKUwyfshDdgPf4gKKW1Uw1nkOvrlq3uTiJUgTahgobJrluzJJxKeKUWbxSvQfgUh5Pf4ZAHgUh5HwH01cRq6OBWiTGKG0foyTRvDZgTkAb6MQfz01Of4WWjymAHH7bWeIocliz)a2)2AHH7rEAb(SwOH7rEOviDTWkKo6gmsliDTRvDdiAv0c0nvlYORrlWHHtWy0cd3dGjeDewqY(zKD)BRfgUh5Pf4ZAHgUh5HwH01cRq6OBWiTWKK21UwqjK4jw14Av0QUrRIwy4EKNwqz6rEAb6MQfz01ODTQGOvrlq3uTiJUgTqQulijxlmCpYtla8aJPArAbGNLnPfi1YouQKmfoy(kDyEbhvTgP3VLv)KAzhkvsMYYw6W0wI2ZLHoKYLn2St9Bz1pPw2HsLKPSVgtmEcLOQXSt9Bz1pPw2HsLKPSVgtmEcLimYmRvKx)ww9tQLDOujzkqclDcTBhM54eYqahCsla8ar3GrAbpnO8q2sc5W4yGCTRvDBTkAb6MQfz01OfsLAbj5AHH7rEAbGhymvlsla8SSjTapZLjzDfpT5IOehzOXflqcBIt2FT9Vv9Zy)(a3jV4bgH8ezcQFlR(bA)(SOZlscsx4Gl0nvlY0pa9d0(bEGXuTOINguEiBjHCyCmqE)a0pPw2HsLKPyGrv1kUDuCmOmn9dq)(a3jV4bgH8ePK7OTvOFa7FZ2k0pa97dCN8IhyeYtKsUJ2wH(zS)TSFlR(9aJqEImb1pG9VzBf6hG(9aJqEImb1pJ9ZZCzswxrsq6chCbsytCY(bOFEMltY6kscsx4GlqcBIt2pJ9ds)ww9xzJJxKeKUWbxSv2pa97dCN8IhyeYtKjO(zS)nB0capq0nyKwqmxgKNgTRvfi0QOfOBQwKrxJwivQfKKRfgUh5PfaEGXuTiTaWZYM0cB2kTahgobJrla0(9zrNxKeKUWbxOBQwKPFa6V((bEGXuTOINguEiBjHCyCmqE)ww9tQLDOujzkJue45ijcokscr8eoR(Rtla8ar3GrAb88CuIJuMSiisjK4jw14iU4ChT0UwvMRvrlq3uTiJUgTWnyKwyueP4ahjcpphL4iLjlcQfgUh5PfgfrkoWrIWZZrjoszYIGAxRkqwRIwGUPArgDnAbomCcgJwaO97ZIoVijiDHdUq3uTit)ww9d0(9zrNxWdPJsCKlsiwIHtip2jyHUPArgTWW9ipTaxmqv2qPRDTQBrTkAb6MQfz01Of4WWjymAbFw05f8q6Oeh5IeILy4eYJDcwOBQwKPFlR(jPKoov45HVcUJMZGKomWPc2OgsOwy4EKNwGlgiwdWK21QULAv0cd3J80cXbCYaHuSnDAb6MQfz01ODTQBLwfTWW9ipTWU9anXCOehnkcbtxulq3uTiJUgTRDTWKKwfTQB0QOfgUh5PfyjgWvC7idC2ZdP0(4IAb6MQfz01ODTQGOvrlq3uTiJUgTahgobJrla0(vcjGr7CtztXJDcIuolS(bOFUy0pGS7Ft)a0pDeChC)a2pZvqlmCpYtlqhb3dfjUDeTcfhqTRvDBTkAb6MQfz01Of4WWjymAb6i4o4IhyeYte2O4(zS)nAHH7rEAb8q6suIJWTHG1UwvGqRIwGUPArgDnAHH7rEAbyiJBhjTpedbNbTahgobJrluF)(SOZlSed4kUDKbo75HuAFCXcDt1Im9dq)8mxMK1vGHmUDK0(qmeCgkgB44rE9Zy)8mxMK1vyjgWvC7idC2ZdP0(4IfiHnXj7V2(bI(RRFa6V((5zUmjRRGhsxIsCeUneCbsytCY(zS)T73YQFUy0pJS7N59xNwGdMViKpWDYLAv3ODTQmxRIwGUPArgDnAbomCcgJwOYghVaTLIXTJudJHqSIZumjRtlmCpYtlaTLIXTJudJHqSIZODTQazTkAb6MQfz01Of4WWjymAbEIvLiPddgO(bO)67V((RVFUy0pJ9VD)ww9ZZCzswxbpKUeL4iCBi4cKWM4K9Zy)a5(RRFa6V((5Ir)mYUFM3VLv)8mxMK1vWdPlrjoc3gcUajSjoz)m2pi9xx)11VLv)0rWDWfpWiKNiSrX9di7(3UFlR(RSXXlM54ekXrCXqnefinCV)60cd3J80csLXDXTJ4W5iedbNbTRvDlQvrlq3uTiJUgTahgobJrlWfJc2O4(z2(5Ir)mYUFq0cd3J80cqcyckjK4aX0Uw1TuRIwGUPArgDnAbomCcgJwGlgfSrX9ZS9ZfJ(zKD)BRfgUh5Pf4IbQYgkDTRvDR0QOfOBQwKrxJwy4EKNwapKokXrUiHyjgoH8yNGAbomCcgJwGlgfSrX9ZS9ZfJ(zKD)BRf4G5lc5dCNCPw1nAxR6gf0QOfOBQwKrxJwy4EKNwWJDcIuolmTahgobJrlWfJc2O4(z2(5Ir)mYUFq6hG(RVFG2Vpl68Iy4iEIvLf6MQfz63YQFG2ppXQsufKgg6VoTahmFriFG7Kl1QUr7Av3SrRIwGUPArgDnAbomCcgJwaO9ZtSQevbPHbTWW9ipTaxmqSgGjTRvDdiAv0c0nvlYORrlmCpYtlGVah3ossqL05igcodAbomCcgJwOYghVuLmGuctEXKSoTqCobH2kDTWgTRvDZ2Av0c0nvlYORrlmCpYtluTgodPTJyi4mOf4WWjymAbEIvLiPddgO(bO)67VYghVuLmGuctEXwz)ww9xF)(SOZlIHJ4jwvwOBQwKPFa6xjKagTZnLnfp2jis5SW6hG(5Ir)a2pq0FD9xNwGdMViKpWDYLAv3ODTRf4gKKG0foyTkAv3Ovrlq3uTiJUgTahgobJrluzJJxKeKUWbxmjRRFlR(9aJqEImb1pG9dcZ1cd3J80cXbCYaHuSnDAxRkiAv0c0nvlYORrlmCpYtlmkIuCGJeHNNJsCKYKfb1cCy4emgTqLnoErsq6chCXKSU(bO)67NN5YKSUIKG0fo4cKWM4K9dy)GOq)ww97bgH8ezcQFa7hiuO)60c3GrAHrrKIdCKi88CuIJuMSiO21QUTwfTaDt1Im6A0cCy4emgTqLnoErsq6chCXKSU(bO)673dmc5jYeu)m2)MTK59Bz1ppZLjzDfjbPlCWfiHnXj7hq29Vf7VU(TS63dmc5jYeu)a2)2mxlmCpYtlSBpqtmhkXrJIqW0f1UwvGqRIwGUPArgDnAbomCcgJwGN5YKSUIKG0fo4cKWM4K9Zy)GOq)ww97bgH8ezcQFa7hef0cd3J80cvRmniCBiyTRvL5Av0c0nvlYORrlWHHtWy0c8mxMK1vKeKUWbxGe2eNSFg7hef63YQFpWiKNitq9dy)ByUwy4EKNwOIGscYqC7AxRkqwRIwGUPArgDnAbomCcgJwOYghVijiDHdUyswx)a0pxmkyJI7Nz7Nlg9Zi7(30pa9thb3bx8aJqEIWgf3pJS7xHcZ1cd3J80cdKphH8ecPZ1Uw1TOwfTWW9ipTWk2fDjsnyB2XOZ1c0nvlYORr7Av3sTkAb6MQfz01Of4WWjymAbEMltY6kscsx4GlqcBIt2pJ9dIc9Bz1VhyeYtKjO(bS)nkOfgUh5PfWdivTY0ODTQBLwfTaDt1Im6A0cCy4emgTapZLjzDfjbPlCWfiHnXj7NX(brH(TS63dmc5jYeu)a2pikOfgUh5PfMJtsholeFwlTRvDJcAv0cd3J80cvZokXrom4mi1c0nvlYORr7Av3SrRIwGUPArgDnAHH7rEAHLT0HPTeTNldDiLlBSzN0cCy4emgTapZLjzDfpT5IOehzOXflqcBIt2pG9VPFlR(5zUmjRR4PnxeL4idnUybsytCY(zSFquOFlR(bA)apWyQwurmxgKNM(TS63dmc5jYeu)a2pimxlCdgPfw2shM2s0EUm0HuUSXMDs7Av3aIwfTaDt1Im6A0cd3J80c7RXeJNqjcJmZAf5Pf4WWjymAbEMltY6kEAZfrjoYqJlwGe2eNSFa7Ft)ww9ZZCzswxXtBUikXrgACXcKWM4K9Zy)GOq)ww9d0(bEGXuTOIyUmipn9Bz1VhyeYtKjO(bSFquqlCdgPf2xJjgpHsegzM1kYt7Av3STwfTaDt1Im6A0cCy4emgTaq7h4bgt1IkI5YG80OfgUh5Pf80MlIsCKHgxu7Av3aeAv0c0nvlYORrlmCpYtlOm5mqUmueYG4jMsBF8ipKHao4KwGddNGXOfQSXXlscsx4GlMK11pa9xF)8mxMK1v80MlIsCKHgxSajSjoz)m2)gf63YQFG2pWdmMQfveZLb5PP)663YQFpWiKNitq9dy)mxlCdgPfuMCgixgkczq8etPTpEKhYqahCs7Av3WCTkAb6MQfz01Of4WWjymAHkBC8IKG0fo4IjzD9dq)13ppZLjzDfjbPlCWfiHnXj7NX(brH(TS6NN5YKSUIKG0fo4cKWM4K9dy)G0FD9Bz1VhyeYtKjO(bS)nmxlmCpYtluTY0GsCKlsi6imWAxR6gGSwfTaDt1Im6A0cd3J80cqclDcTBhM54eYqahCslWHHtWy0c8mxMK1v80MlIsCKHgxSajSjoz)m2)gf63YQFG2pWdmMQfveZLb5PrlCdgPfGew6eA3omZXjKHao4K21QUzlQvrlq3uTiJUgTWW9ipTW(AmX4juIQgZoPf4WWjymAbEMltY6kscsx4GlqcBIt2pJ9dIc9Bz1VhyeYtKjO(bSFquqlCdgPf2xJjgpHsu1y2jTRvDZwQvrlq3uTiJUgTWW9ipTW(Si(SweuIQY80cCy4emgTapZLjzDfjbPlCWfiHnXj7NX(brH(TS63dmc5jYeu)a2pikOfUbJ0c7ZI4ZArqjQkZt7Av3SvAv0c0nvlYORrlmCpYtlWcgUyC7ijTJrNJsCKbssF2hxulWHHtWy0c8mxMK1v80MlIsCKHgxSajSjoz)m2)gf63YQFG2pWdmMQfveZLb5PrlCdgPfybdxmUDKK2XOZrjoYajPp7JlQDTQGOGwfTaDt1Im6A0cd3J80cJue45ijcokscr8eolTahgobJrlyOkBC8cCuKeI4jCwidvzJJxmjRRFlR(RSXXlscsx4GlqcBIt2pJ9Vv9Bz1VhyeYtKjO(bSFqyUw4gmslmsrGNJKi4OijeXt4S0Uwvq2Ovrlq3uTiJUgTahgobJrluzJJxKeKUWbxmjRRFa6V((5zUmjRRijiDHdUajSjoz)m2)gM3VLv)8mxMK1vKeKUWbxGe2eNSFa7hK(RRFlR(9aJqEImb1pG9dIcAHH7rEAbwjCzaMIdbjzEZXjTRvfeq0QOfOBQwKrxJwGddNGXOfQSXXlscsx4GlMK11pa9xF)8mxMK1vKeKUWbxGe2eNSFlR(5zUmjRRWZJtNdhNmi81GrfU4a3jz)S7hK(RRFa6hO9BsVWZJtNdhNmi81GrOkB4vGe2eNSFa6V((5zUmjRRadzC7iP9Hyi4muGe2eNSFa6NN5YKSUcEiDjkXr42qWfiHnXj73YQFpWiKNitq9dy)Bz)1PfgUh5Pf45XPZHJtge(AWiTRvfKT1QOfgUh5PfKeKUWbRfOBQwKrxJ21QccqOvrlq3uTiJUgTahgobJrluzJJxKeKUWbxmjRtlmCpYtl4IeY(Qs7ZGWtiN0UwvqyUwfTaDt1Im6A0cCy4emgTqLnoErsq6chCXKSoTWW9ipTGsByGdoUDu1AKU21QccqwRIwGUPArgDnAHH7rEAbinkJBhHVgmsQf4WWjymAHkBC8IKG0fo4IjzD9dq)13VpWDYlEGriprMG6hW(3uyE)ww9xF)13VpWDYlI0SCXIsU3pJ9VLk0VLv)(a3jVisZYflk5E)aYUFquO)66hG(RV)H7bWeIocliz)S7Ft)ww97dCN8IhyeYtKjO(zSFq2Q(RR)663YQ)673h4o5fpWiKNiLChbIc9Zy)BRq)a0F99pCpaMq0rybj7ND)B63YQFFG7Kx8aJqEImb1pJ9dear)11FD9xNwGdMViKpWDYLAv3ODTQGSf1QOfOBQwKrxJwGddNGXOfQSXXlscsx4GlMK1PfgUh5PfWtUTKmOrriy4eQIgmTRvfKTuRIwGUPArgDnAbomCcgJwOYghVijiDHdUyswx)a0pDeChC)a2pqOGwy4EKNwaJWsiyuIJw28WGmqAWKAxRkiBLwfTaDt1Im6A0cCy4emgTqLnoErsq6chCXKSoTWW9ipTamuQCrO4qsLdN0Uw1TvqRIwGUPArgDnAbomCcgJwOYghVijiDHdUyswNwy4EKNwOA2rjoYHbNbP21QU9gTkAb6MQfz01Of4WWjymAHkBC8IKG0fo4IjzD9dq)13F99tQLDOujzkCW8v6W8coQAnsVFa6NN5YKSUchmFLomVGJQwJ0lqcBIt2pGS7hef6VU(TS6hO9tQLDOujzkCW8v6W8coQAnsV)60cd3J80c2scfoHj1U21csxRIw1nAv0cd3J80cSed4kUDKbo75HuAFCrTaDt1Im6A0Uwvq0QOfOBQwKrxJwGddNGXOf8zrNxKeKUWbxOBQwKPFlR(5zUmjRR4PnxeL4idnUybsytCY(zSFGC)ww9d8aJPArfXCzqEA0cd3J80c4H0LOehHBdbRDTQBRvrlq3uTiJUgTWW9ipTamKXTJK2hIHGZGwGddNGXOf4zUmjRR4PnxeL4idnUybsytCY(zSFq63YQFGhymvlQiMldYtJwGdMViKpWDYLAv3ODTQaHwfTaDt1Im6A0cCy4emgTqLnoEbAlfJBhPggdHyfNPyswx)a0)W9aycrhHfKSFg7FJwy4EKNwaAlfJBhPggdHyfNr7AvzUwfTaDt1Im6A0cCy4emgTaxmkyJI7Nz7Nlg9Zy)B0cd3J80cqcyckjK4aX0UwvGSwfTaDt1Im6A0cd3J80c4H0rjoYfjelXWjKh7eulWHHtWy0cCXOFa7FBTahmFriFG7Kl1QUr7Av3IAv0c0nvlYORrlWHHtWy0cCXOFaz3)29dq)0rWDW9dy)mxbTWW9ipTaDeCpuK42r0kuCa1Uw1TuRIwGUPArgDnAbomCcgJwGlgfSrX9ZS9ZfJ(zSFf6hG(hUhati6iSGK9ZU)n9Bz1pxmkyJI7Nz7Nlg9Zy)B0cd3J80cCXavzdLU21QUvAv0c0nvlYORrlmCpYtl4XobrkNfMwGddNGXOf4jwvIKomyG6hG(5IrbBuC)mB)CXOFg7F7(bOFG2Vj9IN2CruIJm04IfiHnXj7hG(RSXXlspHyiAGUiAodcpGuXKSoTahmFriFG7Kl1QUr7Av3OGwfTWW9ipTaxmqSgGjTaDt1Im6A0Uw1nB0QOfOBQwKrxJwGddNGXOf4jwvIKomyG6hG(RSXXlM54ekXrCXqnefinCxlmCpYtlivg3f3oIdNJqmeCg0Uw1nGOvrlq3uTiJUgTWW9ipTq1A4mK2oIHGZGwGddNGXOf4jwvIKomyG6hG(RV)67NN5YKSUIN2CruIJm04IfiHnXj7NX(bPFlR(bEGXuTOIyUmipn9xx)a0F99ZZCzswxbgY42rs7dXqWzOajSjoz)m2pi9dq)8mxMK1vWdPlrjoc3gcUajSjoz)m2pi9Bz1ppZLjzDfyiJBhjTpedbNHcKWM4K9dy)B3pa9ZZCzswxbpKUeL4iCBi4cKWM4K9Zy)B3pa9ZfJ(zSFq63YQFEMltY6kWqg3osAFigcodfiHnXj7NX(3UFa6NN5YKSUcEiDjkXr42qWfiHnXj7hW(3UFa6Nlg9Zy)ar)ww9ZfJ(zSFM3FD9Bz1FLnoEPkzaPeM8ITY(RtlWbZxeYh4o5sTQB0Uw1nBRvrlq3uTiJUgTWW9ipTGh7eePCwyAbomCcgJwGNyvjs6WGbQFa6NlgfSrX9ZS9ZfJ(zS)nAboy(Iq(a3jxQvDJ21QUbi0QOfIZji0wPRf2OfgUh5PfWxGJBhjjOs6CedbNbTaDt1Im6A0Uw1nmxRIwGUPArgDnAHH7rEAHQ1WziTDedbNbTahgobJrluF)8mxMK1vWdPlrjoc3gcUajSjoz)a2)29dq)CXOF29ds)ww9thb3bx8aJqEIWgf3pG9VP)66hG(RVFLqcy0o3u2u8yNGiLZcRFlR(5IrbBuC)mB)CXOFa7hK(RtlWbZxeYh4o5sTQB0U21cscsx4G1QOvDJwfTaDt1Im6A0cCy4emgTqLnoErsq6chCbsytCY(bS)n9Bz1)W9aycrhHfKSFg7FJwy4EKNwapKUeL4iCBiyTRvfeTkAb6MQfz01Of4WWjymAbEIvLiPddgO(bO)67F4EamHOJWcs2pJ9ds)ww9pCpaMq0rybj7NX(30pa9d0(5zUmjRRadzC7iP9Hyi4muSv2FDAHH7rEAbPY4U42rC4CeIHGZG21QUTwfTaDt1Im6A0cd3J80cWqg3osAFigcodAbomCcgJwGNyvjs6WGbslWbZxeYh4o5sTQB0UwvGqRIwioNGqBLokW1c7CtbsytCs2kOfgUh5PfWdPlrjoc3gcwlq3uTiJUgTRvL5Av0c0nvlYORrlmCpYtlGhshL4ixKqSedNqEStqTahgobJrlWfJ(bS)T1cCW8fH8bUtUuR6gTRvfiRvrlq3uTiJUgTahgobJrlWfJc2O4(z2(5Ir)m2)M(bOF6i4o4IhyeYte2O4(bS)nAHH7rEAbibmbLesCGyAxR6wuRIwGUPArgDnAHH7rEAHQ1WziTDedbNbTahgobJrlWtSQejDyWa1VLv)aTFFw05fXWr8eRkl0nvlYOf4G5lc5dCNCPw1nAxR6wQvrlmCpYtlivg3f3oIdNJqmeCg0c0nvlYORr7Ax7AbGjOmYtRkikaIckaekSvAbwd8IBxQfu0Og3AQU1R6wh1K(7xfrQ)atzc9(Xty)QnUbjjC1w)qsTSdiz6xMyu)JTNyJtM(5IZTtYsZKI(Xr9dY2Qj9ROYdyc6KPF1MhyeYtKsUJuZuZkqcBItQ263Z(vBEGriprk5osntntT1F9BuCDLMPMjfnQXTMQB9QU1rnP)(vrK6pWuMqVF8e2VAtjK4jw14QT(HKAzhqY0VmXO(hBpXgNm9ZfNBNKLMjf9JJ6FB1K(vu5bmbDY0VAZdmc5jsj3rQzQzfiHnXjvB97z)QnpWiKNiLChPMPMP26VEquCDLMPMPTEmLj0jt)BX(hUh51)kKUS0mPfuct8yrAbMPFfnXzynlgiy)BDZJHMjMPFr3vkvtux99WfTRk8etDzGzVgpYJdhCxDzGXvVzIz6Nj7J6FdqaA)GOaik0m1mXm9ROeNBNKQjntmt)mB)BnclbM6xqjnW(v0oNPFbhgmq9ZZZ4rEY(RxCoZIm9xbU)XyYRUsZeZ0pZ2VIsCUDQFFG7KJc8(9SFoy(Iq(a3jxwAMyM(z2(3Aewcm1pDeChC)8rz)CrIZq)4jSFGuiDz)jE)ajBi4(Rxgy9BcCCcshN6pK9F0(k2JQfbA)v2E)kxd4(nboobPJt9hY(LX(f4bFoVUsZeZ0pZ2VA0yit)QDj1)wVtyY(R3HXXa5sq7NCEPUsZuZeZ0VAUIjUTtM(Ri8es9ZtSQX7VI2Jtw6xnY5Ksx2)LhZkoqmC7v)d3J8K9N3cCPzIz6F4EKNSOes8eRAC24RrYqZeZ0)W9ipzrjK4jw141YwD8mnntmt)d3J8KfLqINyvJxlB1h7Dm68XJ8AMyM(fUrPum9(Hty6VYghNm9l9XL9xr4jK6NNyvJ3FfThNS)5m9ResmRY09427pK9BYJkntmt)d3J8KfLqINyvJxlB1L3OukMos6JlBMgUh5jlkHepXQgVw2QRm9iVMjMPFfLiXzq2FG3p40UFXbyQ)PFhghdK3pPw2HsLKPFxC8(znNl73Z(RO(TLKPFp3jxKG9ZkCX(vj3cntd3J8KfLqINyvJxlB1bEGXuTiqVbJy7PbLhYwsihghdKdAQKTKCqbEw2eBsTSdLkjtHdMVshMxWrvRr6wwKAzhkvsMYYw6W0wI2ZLHoKYLn2StwwKAzhkvsMY(AmX4juIQgZozzrQLDOujzk7RXeJNqjcJmZAf5zzrQLDOujzkqclDcTBhM54eYqahCQzIz6xrpdmMQf1VloE)SI1QFNwR(bN29h49doT7NvSw9Fez63Z(znH3VN9ZhP3Vk5wqDt2)LE)SMZ73Z(5J07p8(hV)zT6FoWyjKAMgUh5jlkHepXQgVw2Qd8aJPArGEdgXwmxgKNgqtLSLKdkWZYMyZZCzswxXtBUikXrgACXcKWM4K1Uvm6dCN8IhyeYtKjillG6ZIoVijiDHdUq3uTidaaf4bgt1IkEAq5HSLeYHXXa5aqQLDOujzkgyuvTIBhfhdktda(a3jV4bgH8ePK7OTvOajSjojGB2wba8bUtEXdmc5jsj3rBRqbsytCsg3sllpWiKNitqaUzBfaWdmc5jYeeJ8mxMK1vKeKUWbxGe2eNeaEMltY6kscsx4GlqcBItYiiwwv244fjbPlCWfBLa4dCN8IhyeYtKjig3SPzA4EKNSOes8eRA8AzRoWdmMQfb6nyeB88CuIJuMSiisjK4jw14iU4ChTanvYwsoOaplBI9MTc0aNnq9zrNxKeKUWbxOBQwKbG6bEGXuTOINguEiBjHCyCmqULfPw2HsLKPmsrGNJKi4OijeXt4SQRzA4EKNSOes8eRA8AzRUTKqHtyGEdgXEueP4ahjcpphL4iLjlc2mnCpYtwucjEIvnETSvNlgOkBO0bnWzduFw05fjbPlCWf6MQfzSSaQpl68cEiDuIJCrcXsmCc5Xobl0nvlY0mnCpYtwucjEIvnETSvNlgiwdWeOboBFw05f8q6Oeh5IeILy4eYJDcwOBQwKXYIKs64uHNh(k4oAods6WaNkyJAiHntd3J8KfLqINyvJxlB1Jd4KbcPyB6qUiHyjgoH8yNGntd3J8KfLqINyvJxlB13ThOjMdL4Orriy6Intntmt)Q5kM42oz6NaMGG73dmQFxK6F4Ec7pK9papXAQwuPzA4EKNKTujnqK4CgK0HbduZ0W9ipzTSv3tBUikXrmmqSb04Ccc8SyVvkaQsUJePz5ISvOW8MjMPF1UK6xz6rE9h49lqq6chC)HSFBLG2Fc7VkDX(fuZbs9pNPFvYTq)dK63wjO9NW(DrQFFG7K3pRyT63eu)ScxmU(bYk0VK45zKntd3J8K1YwDLPh5bAGZUYghVijiDHdUyR0YQYghVi9eIHOb6IO5mi8asfBLaysV4PnxeL4idnUybsytCsllpWiKNitqaYgiRqZ0W9ipzTSvhsatqjHehigOboBUyuWgfZSCXGr2Gaq9(SOZlscsx4Gl0nvlYyzbut6fpT5IOehzOXflqcBItwhav244fjbPlCWftY6aOE6i4o4IhyeYte2Oya3yz5ZIoVijiDHdUq3uTida8mxMK1vKeKUWbxGe2eNeqqSSaQpl68IKG0fo4cDt1ImaWZCzswxXtBUikXrgACXcKWM4KaUnaaf4bgt1IkI5YG80yzrhb3bx8aJqEIWgfdiqaapZLjzDf8q6suIJWTHGlqcBItc4McZRRzIz6xTlP(bsPROrL(d8(7hCA3)aP(XcPmU9(hV)fnsV)T7NlgG2VA8m93VKG0foyq7xnEM(7VM0vZ7FGu)x69BRe0(vJQUf6hCA3pfUib7FGu)tvA797z)8rz)0rWDWG2Fc7xsq6chC)HS)PkT9(9SFEIr9BRe0(ty)QKBH(dz)tvA797z)8eJ63wjO9NW(bsjqQ)q2ppXIBVFBL9pNPFWPD)SI1QF(OSF6i4o4(LzEntd3J8K1YwD8q6Oeh5IeILy4eYJDcckhmFriFG7KlzVb0aNnxmkyJIzwUyWi7TbOYghVijiDHdUyswhav244fjrUyC7i4StftY6aOE6i4o4IhyeYte2Oya3yz5ZIoVijiDHdUq3uTida8mxMK1vKeKUWbxGe2eNeqqSSaQpl68IKG0fo4cDt1ImaWZCzswxXtBUikXrgACXcKWM4KaUnaaf4bgt1IkI5YG80yzrhb3bx8aJqEIWgfdiqaapZLjzDf8q6suIJWTHGlqcBItc4McZRRzIz6xTlP(vrrx)bE)H3pR88(RG0Wq)yJ0jiyq7xnQ6wO)bs9JfszC79pE)lAKE)G0pxmaTF1OQBH(RI9(5zUmjRt2)aP(V073wjO9RgvDl0p40UFkCrc2)aP(NQ0273Z(5JY(PJG7GbT)e2VKG0fo4(dz)tvA797z)8eJ63wjO9NW(vj3c9hY(5jwC79BRe0(ty)aPei1Fi7NNyXT3VTY(NZ0p40UFwXA1pFu2pDeChC)YmVMPH7rEYAzRUh7eePCwyGYbZxeYh4o5s2BanWzduEIvLOkinmaaxmkyJIzwUyWiBqaOEFw05fjbPlCWf6MQfzSSaQj9IN2CruIJm04IfiHnXjTSgUhati6iSGKmcsDauzJJxKe5IXTJGZovmjRdGkBC8IKG0fo4IjzDaupDeChCXdmc5jcBumGBSS8zrNxKeKUWbxOBQwKbaEMltY6kscsx4GlqcBItciiwwa1NfDErsq6chCHUPArga4zUmjRR4PnxeL4idnUybsytCsa3gaGc8aJPArfXCzqEASSOJG7GlEGripryJIbeiaGN5YKSUcEiDjkXr42qWfiHnXjbCtH511mnCpYtwlB15IbI1ambAGZgO(SOZl4H0rjoYfjelXWjKh7eSq3uTidakHeWODUPSP4XobrkNfgaEGraYE7MPH7rEYAzRoFwl0W9ip0kKoO3GrS5gKKG0foyqdC2(SOZlscsx4Gl0nvlY0mnCpYtwlB15ZAHgUh5HwH0b9gmIn3GKeoOboBG6ZIoVijiDHdUq3uTitZeZ0VIAwR(DrQFbcsx4G7F4EKx)Rq69h49lqq6chC)HSFUnesNVa3VTYMPH7rEYAzRoFwl0W9ip0kKoO3GrSLeKUWbdAGZUYghVijiDHdUyRSzIz6xrnRv)Ui1VGk9pCpYR)vi9(d8(Drcs9pqQFq6pH9ViPSF6iSGKntd3J8K1YwD(SwOH7rEOviDqVbJylDqdC2d3dGjeDewqsa3UzIz6xrnRv)Ui1VAmvZ7F4EKx)Rq69h497IeK6FGu)B3Fc7hlHu)0rybjBMgUh5jRLT68zTqd3J8qRq6GEdgXEsc0aN9W9aycrhHfKKr2B3m1mXm9Rg5EKNSOgt18(dz)X50zit)4jSFBj1pRWf7xrlX9GJuJgdsrTObyQ)5m9ZTHq68f4(pImY(9S)kQ)uPhyHIqMMPH7rEYYKeBwIbCf3oYaN98qkTpUyZ0W9ipzzsQw2Qthb3dfjUDeTcfhqqdC2avjKagTZnLnfp2jis5SWaGlgaYEda0rWDWaYCfAMgUh5jlts1YwD8q6suIJWTHGbnWzthb3bx8aJqEIWgfZ4MMPH7rEYYKuTSvhgY42rs7dXqWzauoy(Iq(a3jxYEdObo769zrNxyjgWvC7idC2ZdP0(4If6MQfzaGN5YKSUcmKXTJK2hIHGZqXydhpYJrEMltY6kSed4kUDKbo75HuAFCXcKWM4K1ce1bq98mxMK1vWdPlrjoc3gcUajSjojJBBzXfdgzZ86AMgUh5jlts1YwDOTumUDKAymeIvCgqdC2v244fOTumUDKAymeIvCMIjzDntd3J8KLjPAzRUuzCxC7ioCocXqWza0aNnpXQsK0Hbdea1xF9CXGXTTS4zUmjRRGhsxIsCeUneCbsytCsgbY1bq9CXGr2m3YIN5YKSUcEiDjkXr42qWfiHnXjzeK6QZYIocUdU4bgH8eHnkgq2BBzvzJJxmZXjuIJ4IHAikqA4EDntd3J8KLjPAzRoKaMGscjoqmqdC2CXOGnkMz5IbJSbPzA4EKNSmjvlB15IbQYgkDqdC2CXOGnkMz5IbJS3UzA4EKNSmjvlB1XdPJsCKlsiwIHtip2jiOCW8fH8bUtUK9gqdC2CXOGnkMz5IbJS3UzA4EKNSmjvlB19yNGiLZcduoy(Iq(a3jxYEdOboBUyuWgfZSCXGr2Gaq9a1NfDErmCepXQYcDt1ImwwaLNyvjQcsdd11mnCpYtwMKQLT6CXaXAaManWzduEIvLOkinm0mnCpYtwMKQLT64lWXTJKeujDoIHGZaObo7kBC8svYasjm5ftY6anoNGqBLo7nntd3J8KLjPAzRE1A4mK2oIHGZaOCW8fH8bUtUK9gqdC28eRkrshgmqauFLnoEPkzaPeM8ITslR69zrNxedhXtSQSq3uTidakHeWODUPSP4XobrkNfgaCXaqGOU6AMAMyM(vuzUmjRt2mnCpYtw4gKKWzhhWjdesX20HCrcXsmCc5XobbnWzxzJJxKeKUWbxmjRZYYdmc5jYeeGGW8MPH7rEYc3GKeETSvF3EGMyouIJgfHGPlcAGZ2dmc5jYeeJB2sMBzbuGhymvlQiMldYtda8mxMK1v80MlIsCKHgxSajSjojGS3aewwEGriprMGaCBM3mnCpYtw4gKKWRLT6Ss4YamfhcsY8MJtGg4S5zUmjRR4PnxeL4idnUybsytCsgz(wAzXZCzswxXtBUikXrgACXcKWM4KacILfWdmMQfveZLb5PXYYdmc5jYeeGGOqZeZ0VAxs9RgH85O(vjHq68(d8(bN29pqQFSqkJBV)X7FrJ07Ft)kkXO)5m9Zkp1M3pFu2pDeChC)ScxmU(vOW8(LeppJSzA4EKNSWnijHxlB1hiFoc5jesNdAGZMlgfSrXmlxmyK9gaOJG7GlEGripryJIzKTcfM3mnCpYtw4gKKWRLT62scfoHb6nye7LT0HPTeTNldDiLlBSzNanWzZZCzswxXtBUikXrgACXcKWM4KaUXYIN5YKSUIN2CruIJm04IfiHnXjzeefSSakWdmMQfveZLb5PXYYdmc5jYeeGGW8MPH7rEYc3GKeETSv3wsOWjmqVbJyVVgtmEcLimYmRvKhOboBEMltY6kEAZfrjoYqJlwGe2eNeWnww8mxMK1v80MlIsCKHgxSajSjojJGOGLfqbEGXuTOIyUmipnwwEGriprMGaeefAMgUh5jlCdss41YwDpT5IOehzOXfbnWzduGhymvlQiMldYtda1dusTSdLkjtHdMVshMxWrvRr6ww8mxMK1v4G5R0H5fCu1AKEbsytCsazVPoaQNlgmUXYIocUdgqGqH6AMgUh5jlCdss41YwDPNqmenqxenNbHhqc0aNnpZLjzDfPNqmenqxenNbHhqQWfh4ojzdILLj9IN2CruIJm04IfiHnXjTS8aJqEImbbiikyzvFLnoEHvcxgGP4qqsM3CCQajSjojJBuWYIN5YKSUcReUmatXHGKmV54ubsytCsg5zUmjRRi9eIHOb6IO5mi8asfC71cbjU4a3jKhyKLfqjPKoovyLWLbykoeKK5nhNkyJAiH1bq98mxMK1v80MlIsCKHgxSajSjojJ8mxMK1vKEcXq0aDr0CgeEaPcU9AHGexCG7eYdmYYc4bgt1IkI5YG80aaqj1YouQKmfdmQQwXTJIJbLPPoa4zUmjRRGhsxIsCeUneCbsytCsazVvaWfdgzVna8mxMK1vyjgWvC7idC2ZdP0(4IfiHnXjbK9MTBMgUh5jlCdss41Yw9QvMguIJCrcrhHbg0aNnpZLjzDfpT5IOehzOXflqcBItYiqWCllGhymvlQiMldYtda8mxMK1vWdPlrjoc3gcUajSjojGGyz5bgH8ezccWnGyz5bgH8ezcIXnkOaaEGriprMGaCZgfaOEEMltY6k4H0LOehHBdbxGe2eNeWTTS4zUmjRRWsmGR42rg4SNhsP9XflqcBItciZTS4zUmjRRadzC7iP9Hyi4muGe2eNeqMxxZ0W9ipzHBqscVw2QZZJtNdhNmi81GrGg4SbQj9cppoDoCCYGWxdgHQSHxbsytCsaQVEEMltY6k88405WXjdcFnyubsytCsazZZCzswxXtBUikXrgACXcKWM4K1UXYc4bgt1IkI5YG80uha1duFw05fwIbCf3oYaN98qkTpUyHUPArgllEMltY6kSed4kUDKbo75HuAFCXcKWM4K1bapZLjzDfyiJBhjTpedbNHcKWM4KaWZCzswxbpKUeL4iCBi4cKWM4KauzJJxKEcXq0aDr0CgeEaPIjzDwwM0lEAZfrjoYqJlwGe2eNSollpWiKNitqaULntmt)QDj1FnRmn9dKSHG7pW7xL0Ml2FI3)wGgxuTj7NN5YKSU(dz)7qACc2Vlox)BRq)17IHS)44lBdj7NLySO(vj3c9hY(52qiD(cC)d3dGP6aT)e2FIJ3ppZLjzD9ZsKU(bN29pqQFXCzIBV)88SFvYTaO9NW(zjsx)Ui1VpWDY7pK9pvPT3VN9BcQzA4EKNSWnijHxlB1RwzAq42qWGg4S5zUmjRR4PnxeL4idnUybsytCsg3wbllGhymvlQiMldYtJLLhyeYtKjiabrHMPH7rEYc3GKeETSvVIGscYqC7Gg4S5zUmjRR4PnxeL4idnUybsytCsg3wbllGhymvlQiMldYtJLLhyeYtKjia3W8MPH7rEYc3GKeETSvFf7IUePgSn7y05ntd3J8KfUbjj8AzRoEaPQvMgqdC28mxMK1v80MlIsCKHgxSajSjojJBRGLfWdmMQfveZLb5PXYYdmc5jYeeGBuOzA4EKNSWnijHxlB1NJtsholeFwlqdC28mxMK1v80MlIsCKHgxSajSjojJBRGLfWdmMQfveZLb5PXYYdmc5jYeeGGOqZ0W9ipzHBqscVw2Qxn7Oeh5WGZGSzA4EKNSWnijHxlB1TLekCcd0BWi2ktodKldfHmiEIP02hpYdziGdobkOboBEMltY6kEAZfrjoYqJlwGe2eNKXTvWYcOapWyQwurmxgKNMMPH7rEYc3GKeETSv3wsOWjmqVbJydjS0j0UDyMJtidbCWjqdC28mxMK1v80MlIsCKHgxSajSjojJBRGLfqbEGXuTOIyUmipnntd3J8KfUbjj8AzRUTKqHtyGEdgXEFnMy8ekrvJzNanWzZZCzswxXtBUikXrgACXcKWM4KmcIcwwaf4bgt1IkI5YG80yz5bgH8ezccqquOzA4EKNSWnijHxlB1TLekCcd0BWi27ZI4ZArqjQkZd0aNnpZLjzDfpT5IOehzOXflqcBItYiZzULfWdmMQfveZLb5PXYYdmc5jYeeGBaPzA4EKNSWnijHxlB1TLekCcd0BWi2SGHlg3oss7y05OehzGK0N9XfbnWzZZCzswxXtBUikXrgACXcKWM4KmcIcwwaf4bgt1IkI5YG800mnCpYtw4gKKWRLT62scfoHb6nye7rkc8CKebhfjHiEcNfOboBGhymvlQ4PbLhYwsihghdKdq98mxMK1v80MlIsCKHgxSajSjojJGSXYc4bgt1IkI5YG80uha1BOkBC8cCuKeI4jCwidvzJJxmjRZYQYghVi9eIHOb6IO5mi8asfiHnXjzCZ2wwEGriprMGywEMltY6kEAZfrjoYqJlwGe2eNeqGqba4zUmjRR4PnxeL4idnUybsytCsabH5wwEGriprMGaeeMxxZ0W9ipzHBqscVw2QBlju4egO3GrShPiWZrseCuKeI4jCwGg4SbkWdmMQfv80GYdzljKdJJbYbOEdvzJJxGJIKqepHZczOkBC8IjzDww1dusTSdLkjtXaJQQvC7O4yqzASS8bUtEXdmc5jsj3rBRqbsytCsa3Y6aOEt6fpT5IOehzOXflqcBItAzXZCzswxXtBUikXrgACXcKWM4K1Uvm6bgH8ezcQoaQSXXlspHyiAGUiAodcpGuXwPLLhyeYtKjiabH511mnCpYtw4gKKWRLT6UiHSVQ0(mi8eYPMPH7rEYc3GKeETSvxPnmWbh3oQAnsVzIz6xrBUm9V1OrzC79dKwdgj7hpH9tkM42o1pCUDQ)e2pdXA1FLnoUe0(d8(vMszuTOs)QXfRbSSFhcUFp7FN8(DrQ)vYIKE)8mxMK11F1ijt)51)a8eRPAr9thHfKS0mnCpYtw4gKKWRLT6qAug3ocFnyKeuoy(Iq(a3jxYEdOboBFG7Kx8aJqEImbb4McZTSQVEFG7KxePz5IfLCNXTubllFG7KxePz5IfLChq2GOqDau)W9aycrhHfKK9gllFG7Kx8aJqEImbXiiBvD1zzvVpWDYlEGriprk5ocefyCBfaO(H7bWeIoclij7nww(a3jV4bgH8ezcIrGaiQRUMPH7rEYc3GKeETSvhp52sYGgfHGHtOkAWAMgUh5jlCdss41YwDmclHGrjoAzZddYaPbtcAGZMocUdgqGqHMPH7rEYc3GKeETSvhgkvUiuCiPYHtntd3J8KfUbjj8AzRE1SJsCKddodYMPH7rEYc3GKeETSv3wsOWjmjObo76j1YouQKmfoy(kDyEbhvTgPdapZLjzDfoy(kDyEbhvTgPxGe2eNeq2GOqDwwaLul7qPsYu4G5R0H5fCu1AKEZuZeZ0VIkZLjzDYMPH7rEYc3GKeKUWbZooGtgiKITPd5IeILy4eYJDccAGZUYghVijiDHdUyswNLLhyeYtKjiabH5ntd3J8KfUbjjiDHdUw2QBlju4egO3GrShfrkoWrIWZZrjoszYIGGg4SRSXXlscsx4GlMK1bq98mxMK1vKeKUWbxGe2eNeqquWYYdmc5jYeeGaHc11mnCpYtw4gKKG0fo4AzR(U9anXCOehnkcbtxe0aNDLnoErsq6chCXKSoaQ3dmc5jYeeJB2sMBzXZCzswxrsq6chCbsytCsazVfRZYYdmc5jYeeGBZ8MPH7rEYc3GKeKUWbxlB1RwzAq42qWGg4S5zUmjRRijiDHdUajSjojJGOGLLhyeYtKjiabrHMPH7rEYc3GKeKUWbxlB1RiOKGme3oOboBEMltY6kscsx4GlqcBItYiikyz5bgH8ezccWnmVzIz6xTlP(vJq(Cu)QKqiDE)bE)ceKUWb3Fi7)sVFBLG2)CM(bN29pqQFSqkJBV)X7FrJ07Ft)kkXa0(NZ0pR8uBE)8rz)0rWDW9ZkCX46xHcZ7xs88mYMPH7rEYc3GKeKUWbxlB1hiFoc5jesNdAGZUYghVijiDHdUyswhaCXOGnkMz5IbJS3aaDeChCXdmc5jcBumJSvOW8MPH7rEYc3GKeKUWbxlB1xXUOlrQbBZogDEZ0W9ipzHBqscsx4GRLT64bKQwzAanWzZZCzswxrsq6chCbsytCsgbrbllpWiKNitqaUrHMPH7rEYc3GKeKUWbxlB1NJtsholeFwlqdC28mxMK1vKeKUWbxGe2eNKrquWYYdmc5jYeeGGOqZ0W9ipzHBqscsx4GRLT6vZokXrom4miBMgUh5jlCdssq6chCTSv3wsOWjmqVbJyVSLomTLO9CzOdPCzJn7eOboBEMltY6kEAZfrjoYqJlwGe2eNeWnww8mxMK1v80MlIsCKHgxSajSjojJGOGLfqbEGXuTOIyUmipnwwEGriprMGaeeM3mnCpYtw4gKKG0fo4AzRUTKqHtyGEdgXEFnMy8ekryKzwRipqdC28mxMK1v80MlIsCKHgxSajSjojGBSS4zUmjRR4PnxeL4idnUybsytCsgbrbllGc8aJPArfXCzqEASS8aJqEImbbiik0mnCpYtw4gKKG0fo4AzRUN2CruIJm04IGg4SbkWdmMQfveZLb5PPzA4EKNSWnijbPlCW1YwDBjHcNWa9gmITYKZa5YqridINykT9XJ8qgc4GtGg4SRSXXlscsx4GlMK1bq98mxMK1v80MlIsCKHgxSajSjojJBuWYcOapWyQwurmxgKNM6SS8aJqEImbbiZBMgUh5jlCdssq6chCTSvVALPbL4ixKq0ryGbnWzxzJJxKeKUWbxmjRdG65zUmjRRijiDHdUajSjojJGOGLfpZLjzDfjbPlCWfiHnXjbeK6SS8aJqEImbb4gM3mnCpYtw4gKKG0fo4AzRUTKqHtyGEdgXgsyPtOD7WmhNqgc4GtGg4S5zUmjRR4PnxeL4idnUybsytCsg3OGLfqbEGXuTOIyUmipnntd3J8KfUbjjiDHdUw2QBlju4egO3GrS3xJjgpHsu1y2jqdC28mxMK1vKeKUWbxGe2eNKrquWYYdmc5jYeeGGOqZ0W9ipzHBqscsx4GRLT62scfoHb6nye79zr8zTiOevL5bAGZMN5YKSUIKG0fo4cKWM4KmcIcwwEGriprMGaeefAMgUh5jlCdssq6chCTSv3wsOWjmqVbJyZcgUyC7ijTJrNJsCKbssF2hxe0aNnpZLjzDfpT5IOehzOXflqcBItY4gfSSakWdmMQfveZLb5PPzA4EKNSWnijbPlCW1YwDBjHcNWa9gmI9ifbEosIGJIKqepHZc0aNTHQSXXlWrrsiINWzHmuLnoEXKSolRkBC8IKG0fo4cKWM4KmUvwwEGriprMGaeeM3mnCpYtw4gKKG0fo4AzRoReUmatXHGKmV54eObo7kBC8IKG0fo4IjzDauppZLjzDfjbPlCWfiHnXjzCdZTS4zUmjRRijiDHdUajSjojGGuNLLhyeYtKjiabrHMPH7rEYc3GKeKUWbxlB155XPZHJtge(AWiqdC2v244fjbPlCWftY6aOEEMltY6kscsx4GlqcBItAzXZCzswxHNhNohoozq4RbJkCXbUts2Guhaa1KEHNhNohoozq4RbJqv2WRajSjoja1ZZCzswxbgY42rs7dXqWzOajSjoja8mxMK1vWdPlrjoc3gcUajSjoPLLhyeYtKjia3Y6AMgUh5jlCdssq6chCTSvxsq6chCZ0W9ipzHBqscsx4GRLT6UiHSVQ0(mi8eYjqdC2v244fjbPlCWftY6AMgUh5jlCdssq6chCTSvxPnmWbh3oQAnsh0aNDLnoErsq6chCXKSUMjMPFfT5Y0)wJgLXT3pqAnyKSF8e2pPyIB7u)W52P(ty)meRv)v244sq7pW7xzkLr1Ik9RgxSgWY(Di4(9S)DY73fP(xjls69ZZCzswx)vJKm9Nx)dWtSMQf1pDewqYsZ0W9ipzHBqscsx4GRLT6qAug3ocFnyKeuoy(Iq(a3jxYEdObo7kBC8IKG0fo4IjzDauVpWDYlEGriprMGaCtH5ww1xVpWDYlI0SCXIsUZ4wQGLLpWDYlI0SCXIsUdiBquOoaQF4EamHOJWcsYEJLLpWDYlEGriprMGyeKTQU6SSQ3h4o5fpWiKNiLChbIcmUTcau)W9aycrhHfKK9gllFG7Kx8aJqEImbXiqae1vxDntd3J8KfUbjjiDHdUw2QJNCBjzqJIqWWjufnyGg4SRSXXlscsx4GlMK11mnCpYtw4gKKG0fo4AzRogHLqWOehTS5HbzG0GjbnWzxzJJxKeKUWbxmjRda6i4oyabcfAMgUh5jlCdssq6chCTSvhgkvUiuCiPYHtGg4SRSXXlscsx4GlMK11mnCpYtw4gKKG0fo4AzRE1SJsCKddodsqdC2v244fjbPlCWftY6AMgUh5jlCdssq6chCTSv3wsOWjmjObo7kBC8IKG0fo4IjzDauF9KAzhkvsMchmFLomVGJQwJ0bGN5YKSUchmFLomVGJQwJ0lqcBItciBquOollGsQLDOujzkCW8v6W8coQAnsVUMPMjMPFfDWiHHdUFwIXI6xsq6chC)HSFBLntd3J8KfjbPlCWSXdPlrjoc3gcg0aNDLnoErsq6chCbsytCsa3yznCpaMq0rybjzCtZ0W9ipzrsq6chCTSvxQmUlUDehohHyi4maAGZMNyvjs6WGbcG6hUhati6iSGKmcIL1W9aycrhHfKKXnaauEMltY6kWqg3osAFigcodfBL11mnCpYtwKeKUWbxlB1HHmUDK0(qmeCgaLdMViKpWDYLS3aAGZMNyvjs6WGbQzIz6xfXq2pRyT6NpsVFGucK6Fot)X5eeAR073fP(5IZD0Q)aVFxK6FRJIAl0Fi7hsJbC)Zz6xMyKlg3E)IXUib7pV(DrQFLWiHHdU)vi9(RFRjOMwx)HS)b4jwt1Ikntd3J8KfjbPlCW1YwD8q6suIJWTHGbnoNGqBLokWzVZnfiHnXjzRqZ0W9ipzrsq6chCTSvhpKokXrUiHyjgoH8yNGGYbZxeYh4o5s2BanWzZfda3UzA4EKNSijiDHdUw2QdjGjOKqIded0aNnxmkyJIzwUyW4gaOJG7GlEGripryJIbCtZeZ0VAxs9xtQMcA)H3pRyT6pVf4(RG0Wq)yJ0ji4(d8(v0gE)kQeRk7pK9RQIEvPFFw05KPzA4EKNSijiDHdUw2QxTgodPTJyi4makhmFriFG7KlzVb0aNnpXQsK0HbdKLfq9zrNxedhXtSQSq3uTitZ0W9ipzrsq6chCTSvxQmUlUDehohHyi4m0m1mnCpYtwKoBwIbCf3oYaN98qkTpUyZ0W9ipzr61YwD8q6suIJWTHGbnWz7ZIoVijiDHdUq3uTiJLfpZLjzDfpT5IOehzOXflqcBItYiq2Yc4bgt1IkI5YG800mXm9R2Lu)Bnb10(ZRFFG7Kl7Nv4IPT3)w3bYq)jE)Ui1VIcoh1VHQSXXbT)aVFLPugvlc0(NZ0FG3Vk5wO)q2)49VOr69ds)sINNr2)WAa3mnCpYtwKETSvhgY42rs7dXqWzauoy(Iq(a3jxYEdOboBEMltY6kEAZfrjoYqJlwGe2eNKrqSSaEGXuTOIyUmipnntd3J8KfPxlB1H2sX42rQHXqiwXzanWzxzJJxG2sX42rQHXqiwXzkMK1bWW9aycrhHfKKXnntd3J8KfPxlB1HeWeusiXbIbAGZMlgfSrXmlxmyCtZ0W9ipzr61YwD8q6Oeh5IeILy4eYJDcckhmFriFG7KlzVb0aNnxmaC7MPH7rEYI0RLT60rW9qrIBhrRqXbe0aNnxmaK92aqhb3bdiZvOzIz6xTlP(vu10FG3p40U)bs9JLqQFxCU(vOFfLy0)WAa3pomX6hBuC)Zz6xCaM6Ft)0ryGbT)e2)aP(Xsi1Vlox)B6xrjg9pSgW9JdtS(Xgf3mnCpYtwKETSvNlgOkBO0bnWzZfJc2OyMLlgmQaad3dGjeDewqs2BSS4IrbBumZYfdg30mXm9R2Lu)QOOR)aVFWPD)dK6hi6pH9JLqQFUy0)WAa3pomX6hBuC)Zz6xLCl0)CM(fuZbs9pqQ)Q0f7)sVFBLntd3J8KfPxlB19yNGiLZcduoy(Iq(a3jxYEdOboBEIvLiPddgia4IrbBumZYfdg3gaGAsV4PnxeL4idnUybsytCsaQSXXlspHyiAGUiAodcpGuXKSUMPH7rEYI0RLT6CXaXAaMAMgUh5jlsVw2Qlvg3f3oIdNJqmeCganWzZtSQejDyWabqLnoEXmhNqjoIlgQHOaPH7ntmt)QDj1FnPAA)bE)vPl2pqkbs9pNP)TMGAA)dK6)sVF(kLeO9NW(3AcQP9hY(5Rus9pNPFGucK6pK9FP3pFLsQ)5m9doT7xCaM6hlHu)U4C9ds)CXa0(ty)aPei1Fi7NVsj1)wtqnT)q2)LE)8vkP(NZ0p40UFXbyQFSes97IZ1)29Zfdq7pH9doT7xCaM6hlHu)U4C9Z8(5IbO9NW(d8(bN29VtE)t)kHjVzA4EKNSi9AzRE1A4mK2oIHGZaOCW8fH8bUtUK9gqdC28eRkrshgmqauF98mxMK1v80MlIsCKHgxSajSjojJGyzb8aJPArfXCzqEAQdG65zUmjRRadzC7iP9Hyi4muGe2eNKrqaGN5YKSUcEiDjkXr42qWfiHnXjzeellEMltY6kWqg3osAFigcodfiHnXjbCBa4zUmjRRGhsxIsCeUneCbsytCsg3gaUyWiiww8mxMK1vGHmUDK0(qmeCgkqcBItY42aWZCzswxbpKUeL4iCBi4cKWM4KaUnaCXGrGWYIlgmY86SSQSXXlvjdiLWKxSvwxZ0W9ipzr61YwDp2jis5SWaLdMViKpWDYLS3aAGZMNyvjs6WGbcaUyuWgfZSCXGXnntmt)QDj1pqsqnT)5m9hNtqOTsV)W7x6Wj2f9(hwd4MPH7rEYI0RLT64lWXTJKeujDoIHGZaOX5eeAR0zVPzIz6xTlP(Rjvt7pW7hiLaP(dz)8vkP(NZ0p40UFXbyQFq6Nlg9pNPFWPnS)1i9(3xz1S6N1i7xffDG2Fc7pW7hCA3)aP(NQ0273Z(5JY(PJG7G7Fot)u4IeSFWPnS)1i9(35M(znY(vrrx)jS)aVFWPD)dK6Frsz)U4C9ds)CXO)H1aUFCyI1pFuQmU9MPH7rEYI0RLT6vRHZqA7igcodGYbZxeYh4o5s2BanWzxppZLjzDf8q6suIJWTHGlqcBItc42aWfd2Gyzrhb3bx8aJqEIWgfd4M6aOELqcy0o3u2u8yNGiLZcZYIlgfSrXmlxmaeK60cJTlMqTGqGPO0U21Aa]] )

end