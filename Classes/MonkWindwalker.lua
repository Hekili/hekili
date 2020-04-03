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
            local a = Hekili.DB.profile.specs[ 269 ].abilities
            Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled = not val end,
    } ) 
    
    spec:RegisterSetting( "optimize_reverse_harm", false, {
        name = "Optimize |T627486:0|t Reverse Harm",
        desc = "If checked, |T627486:0|t Reverse Harm's caption will show the recommended target's name.",
        type = "toggle",
        width = 1.5
    } ) 
    
    spec:RegisterPack( "Windwalker", 20200402, [[d40x8bqicjpsfuBsf6tOKQgLKWPiQ6vQaZcL4wquSlj(LKOHru5yQilJq8mvuMMkQCnus2gkPY3KKunojjCojjzDOKI5bjUhk1(GKoOkQQfkj1dvrvMiHu1fLKOAJQG4JOKsAKsskDsjjfReq9susPMjeLu3eIsIDsu6NqusQHIskXsjKkpLGPsuCvjjYwHOKKVkjrzSquI9sQ)c1GvCyLwSqEmQMSGlJSzG(maJMiNMQvdrPEnGmBv62Oy3Q63snCc1XvbPLd65KmDkxxO2oe57qQXdr15HW6jKY8Lu7x06tAz0cH1iTSIiNiYj35KtKICvX5QcwDslyietAbXlhOfaPf(LH0cvz(hqVxGiOwq8I42BqlJwq1XqoPfKmtSI1uzLaCtkoQWBMkvot8DnVFoCbTkvodVsTquSFTQMxhPfcRrAzfrorKtUZjNif5QIZvfSslOetCTSIW6QkTGKhc0RJ0cbsX1choNQm)dO3lqemhKv6hOe4dNJKzIvSMkReGBsXrfEZuPYzIVR59ZHlOvPYz4vMaF4CoFXq)MJiSKJiYjICjWjWhoNZtAFaKI1KaF4CqMCeDetJeLJGyAH5u1UFihbd6ar5W7pyE)QCQqA)WLc5eHiNne6x(sc8HZbzY58K2haLJTqaKHDWCSohoc(LW2cbqMQKaF4CqMCeDetJeLd9eeaIC4R4C4sehOCaByohIRmvonyohsmerovOCMCcoiibPNt54QCEcW1b4rxILCIITCeFxe5eCqqcspNYXv5OCaVd689n5ljWhohKjNZpeOqovjfLtvJrmQCQWG(dezkwYHmEr(Iw46ktPLrlWdyfbQLrl7jTmAb63Olf0vRf4q3iOVAHOyqWIIG07gIsOr)5uxNJ5me2ACWPCqjhryLwy5M3VwWFKAGimYJPxBAzfrlJwG(n6sbD1Abo0nc6RwWCgcBno4uoOMZPQGv5uxNJOYbPf6B0Lks9nGToKZXC4DFdn6VyDmxc3G4aTMubsmR)QCqHDoNoxo115yodHTghCkhuY5mwPfwU59RfaeVWGVpUbXROrW2K0Mw2Z0YOfOFJUuqxTwGdDJG(Qf4DFdn6VyDmxc3G4aTMubsmR)QCqnhwvf5uxNdV7BOr)fRJ5s4gehO1KkqIz9xLdk5iso115G0c9n6sfP(gWwhYPUohZziS14Gt5GsoIiNwy5M3VwaDdVbKi)Xqs1)(CsBAzpNwgTa9B0Lc6Q1cCOBe0xTaxYlmlYZbzYHl55Gk7CoLZXCONGaqumNHWwJzwKNdQSZrUcR0cl38(1clKVpHTgcP30MwwwPLrlq)gDPGUATah6gb9vliQCqAH(gDPIuFdyRd5CmNkYru5qhASlwmfkCe8BBW(Doo6UklN66C4DFdn6VWrWVTb7354O7QScKyw)v5Gc7CoLJ85CmNkYHl55GAoNYPUoh6jiae5GsoNtUCKxlSCZ7xlyDmxc3G4aTMK20YY60YOfOFJUuqxTwGdDJG(Qf4DFdn6VOSgYGPfAs49dyqhsfU0cbqQCyNJi5uxNtOTI1XCjCdId0AsfiXS(RYPUohZziS14Gt5GsoIixo115urorXGGf0n8gqI8hdjv)7ZPcKyw)v5GAoNKlN66C4DFdn6VGUH3asK)yiP6FFovGeZ6VkhuZH39n0O)IYAidMwOjH3pGbDivaJVxmK4sleaHnNHYPUohrLdPu0ZPc6gEdir(JHKQ)95uHzr2nmh5Z5yovKdV7BOr)fRJ5s4gehO1KkqIz9xLdQ5W7(gA0FrznKbtl0KW7hWGoKkGX3lgsCPfcGWMZq5uxNdsl03OlvK6BaBDiNJ5iQCOdn2flMcLa0JIU(da7pqI7qoYNZXC4DFdn6Va6ktHBqmymerbsmR)QCqHDovvohZHl55Gk7ColNJ5W7(gA0FbTKdV(dahGlG(XIJFUubsmR)QCqHDoNotlSCZ7xlOSgYGPfAs49dyqhsAtlBvxlJwG(n6sbD1Abo0nc6RwG39n0O)I1XCjCdId0AsfiXS(RYb1CohRYPUohKwOVrxQi13a26qohZH39n0O)cORmfUbXGXqefiXS(RYbLCejN66CmNHWwJdoLdk5CsKCQRZXCgcBno4uoOMZj5KlNJ5yodHTghCkhuY50j5Y5yovKdV7BOr)fqxzkCdIbJHikqIz9xLdk5Cwo115W7(gA0FbTKdV(dahGlG(XIJFUubsmR)QCqjhwLtDDo8UVHg9xGUYFayv8JbY5avGeZ6VkhuYHv5iVwy5M3Vwi62Da3GytIW0tmi0Mw2QqlJwG(n6sbD1Abo0nc6Rwqu5eARW7NtVbxJcyW7Yq4Oy4xGeZ6VkNJ5urovKdV7BOr)fE)C6n4AuadExgQajM1FvoOWohE33qJ(lwhZLWnioqRjvGeZ6VkNdY5uo115G0c9n6sfP(gWwhYr(CoMtf5iQCS9sVvql5WR)aWb4cOFS44NlvOFJUuiN66C4DFdn6VGwYHx)bGdWfq)yXXpxQajM1FvoYNZXC4DFdn6VaDL)aWQ4hdKZbQajM1FvohZH39n0O)cORmfUbXGXqefiXS(RY5yorXGGfL1qgmTqtcVFad6qQeA0Fo115eARyDmxc3G4aTMubsmR)QCKpN66CmNHWwJdoLdk5ufAHLBE)AbE)C6n4AuadExgsBAzRkTmAb63Olf0vRf4q3iOVAbE33qJ(lwhZLWnioqRjvGeZ6VkhuZ5m5YPUohKwOVrxQi13a26qo115yodHTghCkhuYre50cl38(1cr3UdyWyicTPL9KCAz0c0VrxkORwlWHUrqF1c8UVHg9xSoMlHBqCGwtQajM1FvoOMZzYLtDDoiTqFJUurQVbS1HCQRZXCgcBno4uoOKZjwPfwU59RfIiOIGa5paTPL90jTmAHLBE)AHRdqYuyKDCaad9MwG(n6sbD1Atl7jr0YOfOFJUuqxTwGdDJG(Qf4DFdn6VyDmxc3G4aTMubsmR)QCqnNZKlN66CqAH(gDPIuFdyRd5uxNJ5me2ACWPCqjNtYPfwU59RfaDifD7oOnTSNotlJwG(n6sbD1Abo0nc6RwG39n0O)I1XCjCdId0AsfiXS(RYb1CotUCQRZbPf6B0Lks9nGToKtDDoMZqyRXbNYbLCeroTWYnVFTW(CszW9I579QnTSNoNwgTWYnVFTq0ca3Gyd6CGuAb63Olf0vRnTSNyLwgTa9B0Lc6Q1cl38(1cRscP9jfgUIwdX8gUxTah6gb9vlG0c9n6sfRd4(XXkcBq)bISCoMtf5W7(gA0FX6yUeUbXbAnPcKyw)v5GAoICkN66CqAH(gDPIuFdyRd5iFohZPICcuumiybUIwdX8gUxCGIIbblHg9NtDDorXGGfL1qgmTqtcVFad6qQajM1FvoOMZPZYPUohZziS14Gt5Gm5W7(gA0FX6yUeUbXbAnPcKyw)v5GsoNtUCoMdV7BOr)fRJ5s4gehO1KkqIz9xLdk5icRYPUohZziS14Gt5GsoIWQCKxl8ldPfwLes7tkmCfTgI5nCVAtl7jwNwgTa9B0Lc6Q1cl38(1cRscP9jfgUIwdX8gUxTah6gb9vliQCqAH(gDPI1bC)4yfHnO)arwohZPICcuumiybUIwdX8gUxCGIIbblHg9NtDDovKJOYHo0yxSykucqpk66paS)ajUd5uxNJTqaKvmNHWwJfZn8zYLdk5uf5iFohZPICcTvSoMlHBqCGwtQajM1Fvo115W7(gA0FX6yUeUbXbAnPcKyw)v5CqovvoOMJ5me2ACWPCKpNJ5efdcwuwdzW0cnj8(bmOdPsS4CQRZXCgcBno4uoOKJiSkh51c)YqAHvjH0(KcdxrRHyEd3R20YEQQRLrlSCZ7xlyseo(J64pGbBiN0c0VrxkORwBAzpvfAz0cl38(1cIJHoic)bGJURY0c0VrxkORwBAzpvvAz0c0VrxkORwlSCZ7xlaPvS)aWG3LHuAbo0nc6RwWwiaYkMZqyRXbNYbLCovyvo115urovKJTqaKvKO9AsfXClhuZPkKlN66CSfcGSIeTxtQiMB5Gc7CerUCKpNJ5urol3CKim9eJtQCyNZPCQRZXwiaYkMZqyRXbNYb1CePQYr(CKpN66CQihBHaiRyodHTglMByrKlhuZ5m5Y5yovKZYnhjctpX4Kkh25CkN66CSfcGSI5me2ACWPCqnNZDUCKph51cCe8lHTfcGmLw2tAtlRiYPLrlSCZ7xla28yffWROrq3iCeTmAb63Olf0vRnTSICslJwG(n6sbD1Abo0nc6RwGEccaroOKZ5KtlSCZ7xlWqmnebUbX3yUhWbiTmkTPLver0YOfwU59RfGUyXxc7pwjE5KwG(n6sbD1AtlRiNPLrlSCZ7xleTaWni2GohiLwG(n6sbD1AtBAHabUXxtlJw2tAz0cl38(1ckX0cXs7hWkd6arAb63Olf0vRnTSIOLrl4VrqK2RwOQKtliMByjAVMKwqUcR0cl38(1cwhZLWnigOfYSAb63Olf0vRnTSNPLrlq)gDPGUATah6gb9vlefdcwueKE3quIfNtDDorXGGfL1qgmTqtcVFad6qQeloNJ5eARyDmxc3G4aTMubsmR)QCQRZXCgcBno4uoOWohwNCAHLBE)AbXT59RnTSNtlJwG(n6sbD1Abo0nc6RwGl5fMf55Gm5WL8CqLDoIKZXCQihBV0BffbP3nef63OlfYPUohrLtOTI1XCjCdId0AsfiXS(RYr(CoMtumiyrrq6Ddrj0O)CoMtf5qpbbGOyodHTgZSiphuY5uo115y7LEROii9UHOq)gDPqohZH39n0O)IIG07gIcKyw)v5GsoIKtDDoIkhBV0BffbP3nef63OlfY5yo8UVHg9xSoMlHBqCGwtQajM1FvoOKZz5CmhrLdsl03OlvK6BaBDiN66CONGaqumNHWwJzwKNdk5CUCoMdV7BOr)fqxzkCdIbJHikqIz9xLdk5CQWQCKxlSCZ7xlajKiOIWslKrBAzzLwgTa9B0Lc6Q1cl38(1cGUYWni2KimAj3iS5aiOwGdDJG(Qf4sEHzrEoitoCjphuzNZz5CmNOyqWIIG07gIsOr)5CmNOyqWIIitYFay4cGkHg9NZXCQih6jiaefZziS1yMf55GsoNYPUohBV0BffbP3nef63OlfY5yo8UVHg9xueKE3quGeZ6VkhuYrKCQRZru5y7LEROii9UHOq)gDPqohZH39n0O)I1XCjCdId0AsfiXS(RYbLColNJ5iQCqAH(gDPIuFdyRd5uxNd9eeaII5me2AmZI8CqjNZLZXC4DFdn6Va6ktHBqmymerbsmR)QCqjNtfwLJ8Aboc(LW2cbqMsl7jTPLL1PLrlq)gDPGUATWYnVFTG5aiiw8Ez0cCOBe0xTGOYH3mrnocslq5CmhUKxywKNdYKdxYZbv25isohZPICS9sVvueKE3quOFJUuiN66CevoH2kwhZLWnioqRjvGeZ6VkN66CwU5iry6jgNu5GAoIKJ85CmNOyqWIIitYFay4cGkHg9NZXCIIbblkcsVBikHg9NZXCQih6jiaefZziS1yMf55GsoNYPUohBV0BffbP3nef63OlfY5yo8UVHg9xueKE3quGeZ6VkhuYrKCQRZru5y7LEROii9UHOq)gDPqohZH39n0O)I1XCjCdId0AsfiXS(RYbLColNJ5iQCqAH(gDPIuFdyRd5uxNd9eeaII5me2AmZI8CqjNZLZXC4DFdn6Va6ktHBqmymerbsmR)QCqjNtfwLJ8Aboc(LW2cbqMsl7jTPLTQRLrlq)gDPGUATah6gb9vliQCS9sVvaDLHBqSjry0sUryZbqWc9B0Lc5CmhXqcjmaEOCQyoacIfVxMCoMJ5muoOWoNZ0cl38(1cCjhJErI0Mw2QqlJwG(n6sbD1Abo0nc6RwW2l9wrrq6DdrH(n6sbTWYnVFTaFVx8YnVF81vMw46kd)ldPf4bSIG07gcTPLTQ0YOfOFJUuqxTwGdDJG(Qfevo2EP3kkcsVBik0VrxkOfwU59Rf479IxU59JVUY0cxxz4FziTapGveO20YEsoTmAb63Olf0vRf4q3iOVAHOyqWIIG07gIsSyTWYnVFTaFVx8YnVF81vMw46kd)ldPfueKE3qOnTSNoPLrlq)gDPGUATah6gb9vlSCZrIW0tmoPYbLCotlSCZ7xlW37fVCZ7hFDLPfUUYW)YqAbLPnTSNerlJwG(n6sbD1Abo0nc6Rwy5MJeHPNyCsLdQSZ5mTWYnVFTaFVx8YnVF81vMw46kd)ldPf2M0M20cIHeVzIwtlJw2tAz0cl38(1cIBZ7xlq)gDPGUATPLveTmAb63Olf0vRfAXAbfzAHLBE)AbKwOVrxslG0EJjTaDOXUyXuOWrWVTb7354O7QSCQRZHo0yxSykuUXkd2XkmG(gOhl(gZSaOCQRZHo0yxSykuaC3GVwdv4OnaGYPUoh6qJDXIPqbWDd(AnuHzOWEVE)5uxNdDOXUyXuOajM2imGypSpNWbcjNtAbKwi(xgslyDa3powryd6pqKPnTSNPLrlq)gDPGUATqlwlOitlSCZ7xlG0c9n6sAbK2BmPf4DFdn6VyDmxc3G4aTMubsmR)QCoiNQkhuZXwiaYkMZqyRXbNYPUohrLJTx6TIIG07gIc9B0Lc5CmhrLdsl03OlvSoG7hhRiSb9hiYY5yo0Hg7IftHsa6rrx)bG9hiXDiNJ5yleazfZziS1yXCdFMC5GsoNotUCoMJTqaKvmNHWwJfZn8zYLdQ5uf5uxNJ5me2ACWPCqjNtNjxohZXCgcBno4uoOMdV7BOr)ffbP3nefiXS(RY5yo8UVHg9xueKE3quGeZ6VkhuZrKCQRZjkgeSOii9UHOeloNJ5yleazfZziS14Gt5GAoNoPfqAH4FziTGuFdyRdAtl750YOfOFJUuqxTwOfRfuKPfwU59RfqAH(gDjTas7nM0cNQkTah6gb9vliQCS9sVvueKE3quOFJUuiNJ5uroiTqFJUuX6aUFCSIWg0FGilN66COdn2flMcLvjH0(KcdxrRHyEd3BoYRfqAH4FziTay)gUbXIB0eelgs8MjAnmxA)NUAtllR0YOfOFJUuqxTw4xgslSIMsAHRcd2VHBqS4gnb1cl38(1cROPKw4QWG9B4gelUrtqTPLL1PLrlq)gDPGUATah6gb9vliQCS9sVvueKE3quOFJUuiN66Cevo2EP3kGUYWni2KimAj3iS5aiyH(n6sbTWYnVFTaxYXrXqLPnTSvDTmAb63Olf0vRf4q3iOVAbBV0Bfqxz4geBsegTKBe2CaeSq)gDPqo115qkf9CQW7h86CdVFaRmOdsfMfz3qTWYnVFTaxYXOxKiTPLTk0YOfwU59Rf8hPgicJ8y61c0VrxkORwBAzRkTmAHLBE)AbaXlm47JBq8kAeSnjTa9B0Lc6Q1M20cBtAz0YEslJwy5M3VwaTKdV(dahGlG(XIJFUKwG(n6sbD1AtlRiAz0c0VrxkORwlWHUrqF1cIkhXqcjmaEOCQyoacIfVxMCoMdxYZbf25CkNJ5qpbbGihuYHvYPfwU59RfONGaCrZFay66i3HAtl7zAz0c0VrxkORwlWHUrqF1c0tqaikMZqyRXmlYZb1CoPfwU59RfaDLPWnigmgIqBAzpNwgTa9B0Lc6Q1cl38(1cqx5paSk(Xa5CG0cCOBe0xTqf5y7LERGwYHx)bGdWfq)yXXpxQq)gDPqohZH39n0O)c0v(daRIFmqohOsigUM3FoOMdV7BOr)f0so86paCaUa6hlo(5sfiXS(RY5GCoxoYNZXCQihE33qJ(lGUYu4gedgdruGeZ6VkhuZ5SCQRZHl55Gk7CyvoYRf4i4xcBleazkTSN0MwwwPLrlq)gDPGUATah6gb9vlefdcwGXkj)bGr2BGWO9pucn6xlSCZ7xlaJvs(daJS3aHr7FqBAzzDAz0c0VrxkORwlWHUrqF1c8MjQXkd6ar5CmNkYPICQihUKNdQ5Cwo115W7(gA0Fb0vMc3GyWyiIcKyw)v5GAoSUCKpNJ5uroCjphuzNdRYPUohE33qJ(lGUYu4gedgdruGeZ6VkhuZrKCKph5ZPUoh6jiaefZziS1yMf55Gc7ColN66CIIbblH95eUbXCjhz7fiTClh51cl38(1ckX()(daZH7tyGCoqAtlBvxlJwG(n6sbD1Abo0nc6RwGl5fMf55Gm5WL8CqLDoIOfwU59RfGeseuryPfYOnTSvHwgTa9B0Lc6Q1cCOBe0xTaxYlmlYZbzYHl55Gk7CotlSCZ7xlWLCCumuzAtlBvPLrlq)gDPGUATWYnVFTaORmCdInjcJwYncBoacQf4q3iOVAbUKxywKNdYKdxYZbv25CMwWwiaYWoOwqBAzpjNwgTa9B0Lc6Q1cl38(1cMdGGyX7LrlWHUrqF1cCjVWSiphKjhUKNdQSZrKCoMtf5iQCS9sVvKCdZBMOUq)gDPqo115iQC4ntuJJG0cuoYRfSfcGmSdQf0Mw2tN0YOfOFJUuqxTwGdDJG(Qfevo8MjQXrqAbslSCZ7xlWLCm6fjsBAzpjIwgTa9B0Lc6Q1cl38(1cGxe(daRiOy6nmqohiTah6gb9vlefdcwIAGWIHnVeA0VwWFJGWyXMw4K20YE6mTmAb63Olf0vRfwU59RfIUlhOo2Wa5CG0cCOBe0xTaVzIASYGoquohZPICIIbblrnqyXWMxIfNtDDovKJTx6TIKByEZe1f63OlfY5yoIHesya8q5uXCaeelEVm5CmhUKNdk5CUCKph51c2cbqg2b1cAtBAbEaRii9UHqlJw2tAz0c0VrxkORwlWHUrqF1crXGGffbP3neLqJ(ZPUohZziS14Gt5GsoIWkTWYnVFTG)i1aryKhtV20YkIwgTa9B0Lc6Q1cCOBe0xTqumiyrrq6Ddrj0O)CoMtf5yodHTghCkhuZ5uvWQCQRZH39n0O)IIG07gIcKyw)v5Gc7CQ65iFo115yodHTghCkhuY5mwPfwU59RfaeVWGVpUbXROrW2K0Mw2Z0YOfOFJUuqxTwGdDJG(Qf4DFdn6VOii9UHOajM1FvoOMJiYLtDDoMZqyRXbNYbLCeroTWYnVFTq0T7agmgIqBAzpNwgTa9B0Lc6Q1cCOBe0xTaV7BOr)ffbP3nefiXS(RYb1CerUCQRZXCgcBno4uoOKZjwPfwU59RfIiOIGa5paTPLLvAz0c0VrxkORwlWHUrqF1crXGGffbP3neLqJ(Z5yoCjVWSiphKjhUKNdQSZ5uohZHEccarXCgcBnMzrEoOYoh5kSslSCZ7xlSq((e2AiKEtBAzzDAz0cl38(1cxhGKPWi74aag6nTa9B0Lc6Q1Mw2QUwgTa9B0Lc6Q1cCOBe0xTaV7BOr)ffbP3nefiXS(RYb1CerUCQRZXCgcBno4uoOKZj50cl38(1cGoKIUDh0Mw2QqlJwG(n6sbD1Abo0nc6RwG39n0O)IIG07gIcKyw)v5GAoIixo115yodHTghCkhuYre50cl38(1c7ZjLb3lMV3R20YwvAz0cl38(1crlaCdInOZbsPfOFJUuqxT20YEsoTmAb63Olf0vRf4q3iOVAbrLdsl03OlvK6BaBDqlSCZ7xlyDmxc3G4aTMK20YE6KwgTa9B0Lc6Q1cCOBe0xTqumiyrrq6Ddrj0O)CoMtf5W7(gA0Frrq6DdrbsmR)QCqnhrKlN66C4DFdn6VOii9UHOajM1FvoOKJi5iFo115yodHTghCkhuY5eR0cl38(1cr3Ud4geBseMEIbH20YEseTmAb63Olf0vRfwU59RfwLes7tkmCfTgI5nCVAbo0nc6RwiqrXGGf4kAneZB4EXbkkgeSeA0Fo115efdcwueKE3quGeZ6VkhuZPQYPUohZziS14Gt5GsoIWkTWVmKwyvsiTpPWWv0AiM3W9QnTSNotlJwG(n6sbD1Abo0nc6RwikgeSOii9UHOeA0FohZPIC4DFdn6VOii9UHOajM1FvoOMZjwLtDDo8UVHg9xueKE3quGeZ6VkhuYrKCKpN66CmNHWwJdoLdk5iICAHLBE)Ab0n8gqI8hdjv)7ZjTPL9050YOfOFJUuqxTwGdDJG(QfIIbblkcsVBikHg9NZXCQihE33qJ(lkcsVBikqIz9xLtDDo8UVHg9x49ZP3GRrbm4DzOcxAHaivoSZrKCKpNJ5iQCcTv49ZP3GRrbm4DziCum8lqIz9xLZXCQihE33qJ(lqx5paSk(Xa5CGkqIz9xLZXC4DFdn6Va6ktHBqmymerbsmR)QCQRZXCgcBno4uoOKtvKJ8AHLBE)AbE)C6n4AuadExgsBAzpXkTmAHLBE)AbfbP3neAb63Olf0vRnTSNyDAz0c0VrxkORwlWHUrqF1crXGGffbP3neLqJ(1cl38(1cMeHJ)Oo(dyWgYjTPL9uvxlJwG(n6sbD1Abo0nc6RwikgeSOii9UHOeA0Vwy5M3VwqCm0br4paC0DvM20YEQk0YOfOFJUuqxTwy5M3VwasRy)bGbVldP0cCOBe0xTqumiyrrq6Ddrj0O)CoMtf5yleazfZziS14Gt5GsoNkSkN66CQiNkYXwiaYks0EnPIyULdQ5ufYLtDDo2cbqwrI2RjveZTCqHDoIixoYNZXCQiNLBoseMEIXjvoSZ5uo115yleazfZziS14Gt5GAoIuv5iFoYNtDDovKJTqaKvmNHWwJfZnSiYLdQ5CMC5CmNkYz5MJeHPNyCsLd7CoLtDDo2cbqwXCgcBno4uoOMZ5oxoYNJ85iVwGJGFjSTqaKP0YEsBAzpvvAz0c0VrxkORwlWHUrqF1crXGGffbP3neLqJ(1cl38(1cGnpwrb8kAe0nchrlJ20YkICAz0c0VrxkORwlWHUrqF1crXGGffbP3neLqJ(Z5yo0tqaiYbLCoNCAHLBE)AbgIPHiWni(gZ9aoaPLrPnTSICslJwG(n6sbD1Abo0nc6RwikgeSOii9UHOeA0Vwy5M3Vwa6IfFjS)yL4LtAtlRiIOLrlq)gDPGUATah6gb9vlefdcwueKE3qucn6xlSCZ7xleTaWni2GohiL20MwqzAz0YEslJwy5M3VwaTKdV(dahGlG(XIJFUKwG(n6sbD1AtlRiAz0c0VrxkORwlWHUrqF1c2EP3kkcsVBik0VrxkKtDDo8UVHg9xSoMlHBqCGwtQajM1FvoOMdRlN66CqAH(gDPIuFdyRdAHLBE)AbqxzkCdIbJHi0Mw2Z0YOfOFJUuqxTwy5M3Vwa6k)bGvXpgiNdKwGdDJG(Qf4DFdn6VyDmxc3G4aTMubsmR)QCqnhrYPUohKwOVrxQi13a26GwGJGFjSTqaKP0YEsBAzpNwgTa9B0Lc6Q1cCOBe0xTqumiybgRK8hagzVbcJ2)qj0O)CoMZYnhjctpX4KkhuZ5Kwy5M3VwagRK8hagzVbcJ2)G20YYkTmAb63Olf0vRf4q3iOVAbUKxywKNdYKdxYZb1CoPfwU59RfGeseuryPfYOnTSSoTmAb63Olf0vRfwU59RfaDLHBqSjry0sUryZbqqTah6gb9vlWL8CqjNZ0cCe8lHTfcGmLw2tAtlBvxlJwG(n6sbD1Abo0nc6RwGl55Gc7ColNJ5qpbbGihuYHvYPfwU59RfONGaCrZFay66i3HAtlBvOLrlq)gDPGUATah6gb9vlWL8cZI8CqMC4sEoOMJC5CmNLBoseMEIXjvoSZ5uo115WL8cZI8CqMC4sEoOMZjTWYnVFTaxYXrXqLPnTSvLwgTa9B0Lc6Q1cl38(1cMdGGyX7LrlWHUrqF1c8MjQXkd6ar5CmhUKxywKNdYKdxYZb1ColNJ5iQCcTvSoMlHBqCGwtQajM1FvohZjkgeSOSgYGPfAs49dyqhsLqJ(1cCe8lHTfcGmLw2tAtl7j50YOfwU59Rf4sog9IePfOFJUuqxT20YE6KwgTa9B0Lc6Q1cCOBe0xTaVzIASYGoquohZjkgeSe2Nt4geZLCKTxG0YnTWYnVFTGsS)V)aWC4(egiNdK20YEseTmAb63Olf0vRfwU59RfIUlhOo2Wa5CG0cCOBe0xTaVzIASYGoquohZPICQihE33qJ(lwhZLWnioqRjvGeZ6VkhuZrKCQRZbPf6B0Lks9nGToKJ85CmNkYH39n0O)c0v(daRIFmqohOcKyw)v5GAoIKZXC4DFdn6Va6ktHBqmymerbsmR)QCqnhrYPUohE33qJ(lqx5paSk(Xa5CGkqIz9xLdk5CwohZH39n0O)cORmfUbXGXqefiXS(RYb1ColNJ5WL8CqnhrYPUohE33qJ(lqx5paSk(Xa5CGkqIz9xLdQ5CwohZH39n0O)cORmfUbXGXqefiXS(RYbLColNJ5WL8CqnNZLtDDoCjphuZHv5iFo115efdcwIAGWIHnVeloh51cCe8lHTfcGmLw2tAtl7PZ0YOfOFJUuqxTwy5M3VwWCaeelEVmAbo0nc6RwG3mrnwzqhikNJ5WL8cZI8CqMC4sEoOMZjTahb)syBHaitPL9K20YE6CAz0c(Beegl20cN0cl38(1cGxe(daRiOy6nmqohiTa9B0Lc6Q1Mw2tSslJwG(n6sbD1AHLBE)AHO7YbQJnmqohiTah6gb9vluro8UVHg9xaDLPWnigmgIOajM1FvoOKZz5CmhUKNd7CejN66CONGaqumNHWwJzwKNdk5Ckh5Z5yovKJyiHegapuovmhabXI3lto115WL8cZI8CqMC4sEoOKJi5iVwGJGFjSTqaKP0YEsBAtlOii9UHqlJw2tAz0c0VrxkORwlWHUrqF1crXGGffbP3nefiXS(RYbLCoLtDDol3CKim9eJtQCqnNtAHLBE)AbqxzkCdIbJHi0Mwwr0YOfOFJUuqxTwGdDJG(Qf4ntuJvg0bIY5yovKZYnhjctpX4KkhuZrKCQRZz5MJeHPNyCsLdQ5CkNJ5iQC4DFdn6VaDL)aWQ4hdKZbQeloh51cl38(1ckX()(daZH7tyGCoqAtl7zAz0c0VrxkORwlSCZ7xlaDL)aWQ4hdKZbslWHUrqF1c8MjQXkd6arAboc(LW2cbqMsl7jTPL9CAz0c(Beegl2WoOwaapuGeZ6VITCAHLBE)AbqxzkCdIbJHi0c0VrxkORwBAzzLwgTa9B0Lc6Q1cl38(1cGUYWni2KimAj3iS5aiOwGdDJG(Qf4sEoOKZzAboc(LW2cbqMsl7jTPLL1PLrlq)gDPGUATah6gb9vlWL8cZI8CqMC4sEoOMZPCoMd9eeaII5me2AmZI8CqjNtAHLBE)AbiHebvewAHmAtlBvxlJwG(n6sbD1AHLBE)AHO7YbQJnmqohiTah6gb9vlWBMOgRmOdeLtDDoIkhBV0Bfj3W8MjQl0VrxkOf4i4xcBleazkTSN0Mw2QqlJwy5M3Vwqj2)3FayoCFcdKZbslq)gDPGUATPnTPfqIGkVFTSIiNiYj3zNjNwa9cF)bO0cvzNVOt2QgzzTYAYjhzKOCCgXn0YbSH5W65bSIaz95aPdn2HuihvZq5SXwZSgfYHlTpasvsGrw7pLZjwhRjNZRFKiOrHCy9MZqyRXI5ggzbzPajM1FfRphRZH1BodHTglMByKfKfwFovCc5YxsGtGRYoFrNSvnYYAL1KtoYir54mIBOLdydZH1lgs8MjAnwFoq6qJDifYr1muoBS1mRrHC4s7dGuLeyK1(t5CgRjNZRFKiOrHCy9MZqyRXI5ggzbzPajM1FfRphRZH1BodHTglMByKfKfwFovicYLVKaNaxLD(IozRAKL1kRjNCKrIYXze3qlhWgMdRFBI1NdKo0yhsHCundLZgBnZAuihU0(aivjbgzT)uovfRjhrhX0irHCy8N1GSKdxI4aLtfFB5SiT(DJUuo(NdXeFxZ7x(CQ4eYLVKaJS2FkNtYXAYr0rmnsuihg)znil5WLioq5uX3wolsRF3OlLJ)5qmX318(LpNkoHC5ljWiR9NY50zSMCeDetJefYHXFwdYsoCjIduov8TLZI063n6s54Foet8DnVF5ZPItix(scCcCvdJ4gAuiNQEol38(Z56ktvsG1cBSj1qTGGZCEAbXWg0VKw4W5uL5Fa9EbIG5GSs)aLaF4CKmtSI1uzLaCtkoQWBMkvot8DnVFoCbTkvodVYe4dNZ5lg63CeHLCerorKlbob(W5CEs7dGuSMe4dNdYKJOJyAKOCeetlmNQ29d5iyqhikhE)bZ7xLtfs7hUuiNie5SHq)YxsGpCoitoNN0(aOCSfcGmSdMJ15WrWVe2wiaYuLe4dNdYKJOJyAKOCONGaqKdFfNdxI4aLdydZ5qCLPYPbZ5qIHiYPcLZKtWbbji9CkhxLZtaUoap6sSKtuSLJ47IiNGdcsq65uoUkhLd4DqNVVjFjb(W5Gm5C(HafYPkPOCQAmIrLtfg0FGitXsoKXlYxsGtGpCov5iN4XgfYjIaBiLdVzIwlNicG)QsoNpNtInvoF)iJ0czaJV5SCZ7xLt)xeLe4dNZYnVFvrmK4nt0ASbVRcOe4dNZYnVFvrmK4nt0AhWUsWUdjWhoNLBE)QIyiXBMO1oGDLBmag6T18(tGpCoc)kwj1woW1d5efdcsHCu2AQCIiWgs5WBMO1YjIa4VkN9d5igsiJ42m)bKJRYj0pvsGpCol38(vfXqI3mrRDa7kv)kwj1gwzRPsGxU59RkIHeVzIw7a2vkUnV)e4dNZ5jrCGu54G5GOJZrArIYzZXG(dez5qhASlwmfYXKwlh07BQCSoNikNyffYXAaKjrWCq7MuoY0I(e4LBE)QIyiXBMO1oGDLiTqFJUel)YqSToG7hhRiSb9hiYyPfZwrgliT3yInDOXUyXuOWrWVTb7354O7QS6A6qJDXIPq5gRmyhRWa6BGES4BmZcGQRPdn2flMcfa3n4R1qfoAdaO6A6qJDXIPqbWDd(AnuHzOWEVE)110Hg7IftHcKyAJWaI9W(CchiKCoLaF4Cqw1c9n6s5ysRLdA)EZXO7nheDCooyoi64Cq73BoprHCSoh0RB5yDo8vz5itl6Rm058TLd69TCSoh(QSCClN1YzV3C2hbtdPe4LBE)QIyiXBMO1oGDLiTqFJUel)YqSL6BaBDGLwmBfzSG0EJj28UVHg9xSoMlHBqCGwtQajM1F1bvfQ2cbqwXCgcBno4uDTOS9sVvueKE3quOFJUu4OOqAH(gDPI1bC)4yfHnO)ar2r6qJDXIPqja9OOR)aW(dK4oC0wiaYkMZqyRXI5g(m5kqIz9xHYPZK7OTqaKvmNHWwJfZn8zYvGeZ6Vc1QOU2CgcBno4ekNotUJMZqyRXbNqL39n0O)IIG07gIcKyw)vh5DFdn6VOii9UHOajM1FfQIuxhfdcwueKE3quIfF0wiaYkMZqyRXbNq90Pe4LBE)QIyiXBMO1oGDLiTqFJUel)YqSb73WniwCJMGyXqI3mrRH5s7)0LLwmBfzSG0EJj2NQkwCq2IY2l9wrrq6DdrH(n6sHJvG0c9n6sfRd4(XXkcBq)bIS6A6qJDXIPqzvsiTpPWWv0AiM3W9kFc8YnVFvrmK4nt0AhWUYyfHDJyy5xgI9kAkPfUkmy)gUbXIB0embE5M3VQigs8MjATdyxjxYXrXqLXIdYwu2EP3kkcsVBik0VrxkuxlkBV0Bfqxz4geBsegTKBe2CaeSq)gDPqc8YnVFvrmK4nt0AhWUsUKJrVirS4GST9sVvaDLHBqSjry0sUryZbqWc9B0Lc11KsrpNk8(bVo3W7hWkd6GuHzr2nmbE5M3VQigs8MjATdyxP)i1aryKhtp2KimAj3iS5aiyc8YnVFvrmK4nt0AhWUsaXlm47JBq8kAeSnPe4e4dNtvoYjESrHCiKiiICmNHYXKOCwU1WCCvolsRF3OlvsGxU59RyRetlelTFaRmOdeLaVCZ7xDa7kToMlHBqmqlKzzXFJGiTx2vLCSiMByjAVMeB5kSkb(W5uLuuoIBZ7phhmhbcsVBiYXv5elMLCAyorTjLJqv(HKZ(HCKPf95SqkNyXSKtdZXKOCSfcGSCq73BobNYbTBs(NdRtUCueV)GkbE5M3V6a2vkUnVFwCq2rXGGffbP3neLyX11rXGGfL1qgmTqtcVFad6qQel(yOTI1XCjCdId0AsfiXS(RQRnNHWwJdoHcBwNCjWl38(vhWUsiHebvewAHmS4GS5sEHzroYWLCuzlYXkS9sVvueKE3quOFJUuOUwuH2kwhZLWnioqRjvGeZ6Vs(JrXGGffbP3neLqJ(pwb9eeaII5me2AmZICuovxB7LEROii9UHOq)gDPWrE33qJ(lkcsVBikqIz9xHIi11IY2l9wrrq6DdrH(n6sHJ8UVHg9xSoMlHBqCGwtQajM1FfkNDuuiTqFJUurQVbS1H6A6jiaefZziS1yMf5OCUJ8UVHg9xaDLPWnigmgIOajM1FfkNkSs(e4dNtvsr5CiTvLjtooyo5GOJZzHuomUs5pGCwlNlTklNZYHl5SKZ5)HCYrrq6Ddbl5C(FiNCQUTQ8CwiLZ3woXIzjNZxwrFoi64Ci3KiyolKYzJ6ylhRZHVIZHEccabl50WCueKE3qKJRYzJ6ylhRZH3muoXIzjNgMJmTOphxLZg1XwowNdVzOCIfZsonmNdPpKCCvo8MXFa5eloN9d5GOJZbTFV5WxX5qpbbGihv3Fc8YnVF1bSRe0vgUbXMeHrl5gHnhabzHJGFjSTqaKPyFIfhKnxYlmlYrgUKJk7ZogfdcwueKE3qucn6)yumiyrrKj5pamCbqLqJ(pwb9eeaII5me2AmZICuovxB7LEROii9UHOq)gDPWrE33qJ(lkcsVBikqIz9xHIi11IY2l9wrrq6DdrH(n6sHJ8UVHg9xSoMlHBqCGwtQajM1FfkNDuuiTqFJUurQVbS1H6A6jiaefZziS1yMf5OCUJ8UVHg9xaDLPWnigmgIOajM1FfkNkSs(e4dNtvsr5idRLCCWCClh09B5ebPfOCywLrqeSKZ5lROpNfs5W4kL)aYzTCU0QSCejhUKZsoNVSI(CICa5W7(gA0VkNfs58TLtSywY58Lv0NdIoohYnjcMZcPC2Oo2YX6C4R4CONGaqWsonmhfbP3ne54QC2Oo2YX6C4ndLtSywYPH5itl6ZXv5WBg)bKtSywYPH5Ci9HKJRYH3m(diNyX5SFiheDCoO97nh(koh6jiae5O6(tGxU59RoGDLMdGGyX7LHfoc(LW2cbqMI9jwCq2II3mrnocslqh5sEHzroYWLCuzlYXkS9sVvueKE3quOFJUuOUwuH2kwhZLWnioqRjvGeZ6VQUE5MJeHPNyCsHQiYFmkgeSOiYK8hagUaOsOr)hJIbblkcsVBikHg9FSc6jiaefZziS1yMf5OCQU22l9wrrq6DdrH(n6sHJ8UVHg9xueKE3quGeZ6VcfrQRfLTx6TIIG07gIc9B0Lch5DFdn6VyDmxc3G4aTMubsmR)kuo7OOqAH(gDPIuFdyRd110tqaikMZqyRXmlYr5Ch5DFdn6Va6ktHBqmymerbsmR)kuovyL8jWl38(vhWUsUKJrVirS4GSfLTx6TcORmCdInjcJwYncBoacwOFJUu4OyiHegapuovmhabXI3lZrZziuyFwc8YnVF1bSRKV3lE5M3p(6kJLFzi28awrq6DdbloiBBV0BffbP3nef63OlfsGxU59RoGDL89EXl38(XxxzS8ldXMhWkcKfhKTOS9sVvueKE3quOFJUuib(W5CE79MJjr5iqq6Ddrol38(Z56klhhmhbcsVBiYXv5WJHq6TlICIfNaVCZ7xDa7k579IxU59JVUYy5xgITIG07gcwCq2rXGGffbP3neLyXjWhoNZBV3CmjkhbzYz5M3Foxxz54G5yseKYzHuoIKtdZ5skvo0tmoPsGxU59RoGDL89EXl38(XxxzS8ldXwzS4GSxU5iry6jgNuOCwc8HZ5827nhtIY587Q8CwU59NZ1vwooyoMebPCwiLZz50WCyAiLd9eJtQe4LBE)QdyxjFVx8YnVF81vgl)YqS3MyXbzVCZrIW0tmoPqL9zjWjWhoNZNBE)QY53v554QC83OpqHCaByoXkkh0UjLtvlXnNJp)qaFExArIYz)qo8yiKE7IiNNOGkhRZjIYPfBoJlAuibE5M3VQSnXgTKdV(dahGlG(XIJFUuc8YnVFvzB6a2vspbb4IM)aW01rUdzXbzlkXqcjmaEOCQyoacIfVxMJCjhf2NospbbGafwjxc8YnVFvzB6a2vc6ktHBqmymebloiB6jiaefZziS1yMf5OEkbE5M3VQSnDa7kHUYFayv8JbY5aXchb)syBHaitX(eloi7kS9sVvql5WR)aWb4cOFS44NlvOFJUu4iV7BOr)fOR8hawf)yGCoqLqmCnVFu5DFdn6VGwYHx)bGdWfq)yXXpxQajM1F1bNt(JvW7(gA0Fb0vMc3GyWyiIcKyw)vOEwDnxYrLnRKpbE5M3VQSnDa7kHXkj)bGr2BGWO9pWIdYokgeSaJvs(daJS3aHr7FOeA0Fc8YnVFvzB6a2vQe7)7pamhUpHbY5aXIdYM3mrnwzqhi6yfvubxYr9S6AE33qJ(lGUYu4gedgdruGeZ6VcvwN8hRGl5OYMv118UVHg9xaDLPWnigmgIOajM1FfQIiV8110tqaikMZqyRXmlYrH9z11rXGGLW(Cc3GyUKJS9cKwUjFc8YnVFvzB6a2vcjKiOIWslKHfhKnxYlmlYrgUKJkBrsGxU59RkBthWUsUKJJIHkJfhKnxYlmlYrgUKJk7ZsGxU59RkBthWUsqxz4geBsegTKBe2CaeKfBHaid7GSz8N1eOOyqWcZcbc3GytIWC4(ubsmR)kwCq2CjVWSihz4soQSplbE5M3VQSnDa7knhabXI3ldl2cbqg2bzZ4pRjqrXGGfMfceUbXMeH5W9PcKyw)vS4GS5sEHzroYWLCuzlYXkeLTx6TIKByEZe1f63OlfQRffVzIACeKwGKpbE5M3VQSnDa7k5sog9IeXIdYwu8MjQXrqAbkbE5M3VQSnDa7kbVi8hawrqX0ByGCoqS4GSJIbblrnqyXWMxcn6Nf)nccJfBSpLaVCZ7xv2MoGDLr3LduhByGCoqSyleazyhKnJ)SMaffdcwywiq4geBseMd3NkqIz9xXIdYM3mrnwzqhi6yfrXGGLOgiSyyZlXIRRRW2l9wrYnmVzI6c9B0LchfdjKWa4HYPI5aiiw8EzoYLCuoN8YNaNaF4CoVUVHg9RsGxU59Rk8awrGS9hPgicJ8y6XMeHrl5gHnhabzXbzhfdcwueKE3qucn6VU2CgcBno4ekIWQe4LBE)QcpGve4bSReq8cd((4geVIgbBtIfhKT5me2ACWjupvfSQUwuiTqFJUurQVbS1HJ8UVHg9xSoMlHBqCGwtQajM1FfkSpDU6AZziS14GtOCgRsGxU59Rk8awrGhWUs0n8gqI8hdjv)7ZjwCq28UVHg9xSoMlHBqCGwtQajM1FfQSQkQR5DFdn6VyDmxc3G4aTMubsmR)kuePUgPf6B0Lks9nGTouxBodHTghCcfrKlb(W5uLuuoNpKVpLJmnesVLJdMdIooNfs5W4kL)aYzTCU0QSCoLZ5j55SFih09Z6TC4R4CONGaqKdA3K8ph5kSkhfX7pOsGxU59Rk8awrGhWUYfY3NWwdH0BS4GS5sEHzroYWLCuzF6i9eeaII5me2AmZICuzlxHvjWl38(vfEaRiWdyxP1XCjCdId0AsS4GSffsl03OlvK6BaBD4yfIIo0yxSyku4i432G97CC0DvwDnV7BOr)foc(Tny)ohhDxLvGeZ6Vcf2NK)yfCjh1t110tqaiq5CYjFc8YnVFvHhWkc8a2vQSgYGPfAs49dyqhsSWIdYM39n0O)IYAidMwOjH3pGbDiv4sleaPylsDDOTI1XCjCdId0AsfiXS(RQRnNHWwJdoHIiYvxxrumiybDdVbKi)Xqs1)(CQajM1FfQNKRUM39n0O)c6gEdir(JHKQ)95ubsmR)ku5DFdn6VOSgYGPfAs49dyqhsfW47fdjU0cbqyZzO6Arrkf9CQGUH3asK)yiP6FFovywKDdL)yf8UVHg9xSoMlHBqCGwtQajM1FfQ8UVHg9xuwdzW0cnj8(bmOdPcy89IHexAHaiS5muDnsl03OlvK6BaBD4OOOdn2flMcLa0JIU(da7pqI7G8h5DFdn6Va6ktHBqmymerbsmR)kuyxvh5soQSp7iV7BOr)f0so86paCaUa6hlo(5sfiXS(RqH9PZsGxU59Rk8awrGhWUYOB3bCdInjctpXGGfhKnV7BOr)fRJ5s4gehO1KkqIz9xH65yvDnsl03OlvK6BaBD4iV7BOr)fqxzkCdIbJHikqIz9xHIi11MZqyRXbNq5Ki11MZqyRXbNq9KCYD0CgcBno4ekNoj3Xk4DFdn6Va6ktHBqmymerbsmR)kuoRUM39n0O)cAjhE9haoaxa9Jfh)CPcKyw)vOWQ6AE33qJ(lqx5paSk(Xa5CGkqIz9xHcRKpbE5M3VQWdyfbEa7k59ZP3GRrbm4DziwCq2Ik0wH3pNEdUgfWG3LHWrXWVajM1F1XkQG39n0O)cVFo9gCnkGbVldvGeZ6Vcf28UVHg9xSoMlHBqCGwtQajM1F1bNQRrAH(gDPIuFdyRdYFScrz7LERGwYHx)bGdWfq)yXXpxQq)gDPqDnV7BOr)f0so86paCaUa6hlo(5sfiXS(RK)iV7BOr)fOR8hawf)yGCoqfiXS(RoY7(gA0Fb0vMc3GyWyiIcKyw)vhJIbblkRHmyAHMeE)ag0Huj0O)66qBfRJ5s4gehO1KkqIz9xjFDT5me2ACWjuQIe4dNtvsr5u9T7qohsmerooyoY0XCPCAWCe90AsSEvo8UVHg9NJRYbaKwJG5ys7NZzYLtfMKRYXF(noqQCql5xkhzArFoUkhEmesVDrKZYnhjsEwYPH50GG5W7(gA0FoOLOpheDColKYrQVb)bKt)wNJmTONLCAyoOLOphtIYXwiaYYXv5SrDSLJ15eCkbE5M3VQWdyfbEa7kJUDhWGXqeS4GS5DFdn6VyDmxc3G4aTMubsmR)kuptU6AKwOVrxQi13a26qDT5me2ACWjuerUe4LBE)QcpGve4bSRmIGkccK)ayXbzZ7(gA0FX6yUeUbXbAnPcKyw)vOEMC11iTqFJUurQVbS1H6AZziS14GtOCIvjWl38(vfEaRiWdyx51bizkmYooaGHElbE5M3VQWdyfbEa7kbDifD7oWIdYM39n0O)I1XCjCdId0AsfiXS(Rq9m5QRrAH(gDPIuFdyRd11MZqyRXbNq5KCjWl38(vfEaRiWdyx5(CszW9I579YIdYM39n0O)I1XCjCdId0AsfiXS(Rq9m5QRrAH(gDPIuFdyRd11MZqyRXbNqre5sGxU59Rk8awrGhWUYOfaUbXg05aPsGxU59Rk8awrGhWUYyfHDJyy5xgI9QKqAFsHHRO1qmVH7LfhKnsl03OlvSoG7hhRiSb9hiYowbV7BOr)fRJ5s4gehO1KkqIz9xHQiNQRrAH(gDPIuFdyRdYFSIaffdcwGRO1qmVH7fhOOyqWsOr)11rXGGfL1qgmTqtcVFad6qQajM1FfQNoRU2CgcBno4eYW7(gA0FX6yUeUbXbAnPcKyw)vOCo5oY7(gA0FX6yUeUbXbAnPcKyw)vOicRQRnNHWwJdoHIiSs(e4LBE)QcpGve4bSRmwry3igw(LHyVkjK2Nuy4kAneZB4EzXbzlkKwOVrxQyDa3powryd6pqKDSIaffdcwGRO1qmVH7fhOOyqWsOr)11vik6qJDXIPqja9OOR)aW(dK4ouxBleazfZziS1yXCdFMCfiXS(RqPkK)yfH2kwhZLWnioqRjvGeZ6VQUM39n0O)I1XCjCdId0AsfiXS(RoOQq1CgcBno4K8hJIbblkRHmyAHMeE)ag0HujwCDT5me2ACWjueHvYNaVCZ7xv4bSIapGDLMeHJ)Oo(dyWgYPe4LBE)QcpGve4bSRuCm0br4paC0Dvwc8HZPQTVHCeD0k2Fa5Ci3LHu5a2WCiKt8yJYbUpakNgMdq(9MtumiOILCCWCe3kLhDPsoN)f9IqLJbrKJ15aGSCmjkNBJMuwo8UVHg9Nt0QOqo9NZI063n6s5qpX4KQKaVCZ7xv4bSIapGDLqAf7pam4DziflCe8lHTfcGmf7tS4GSTfcGSI5me2ACWjuovyvDDfvyleazfjAVMurm3qTkKRU2wiaYks0EnPIyUHcBrKt(JvSCZrIW0tmoPyFQU2wiaYkMZqyRXbNqvKQsE5RRRWwiaYkMZqyRXI5gwe5q9m5owXYnhjctpX4KI9P6ABHaiRyodHTghCc1ZDo5LpbE5M3VQWdyfbEa7kbBESIc4v0iOBeoIwMe4LBE)QcpGve4bSRKHyAicCdIVXCpGdqAzuS4GSPNGaqGY5KlbE5M3VQWdyfbEa7kHUyXxc7pwjE5uc8YnVFvHhWkc8a2vgTaWni2GohivcCc8HZ586(gA0VkbE5M3VQWdyfbP3neS9hPgicJ8y6XMeHrl5gHnhabzXbzhfdcwueKE3qucn6VU2CgcBno4ekIWQe4LBE)QcpGveKE3qCa7kbeVWGVpUbXROrW2KyXbzhfdcwueKE3qucn6)yfMZqyRXbNq9uvWQ6AE33qJ(lkcsVBikqIz9xHc7QU811MZqyRXbNq5mwLaVCZ7xv4bSIG07gIdyxz0T7agmgIGfhKnV7BOr)ffbP3nefiXS(Rqve5QRnNHWwJdoHIiYLaVCZ7xv4bSIG07gIdyxzebveei)bWIdYM39n0O)IIG07gIcKyw)vOkIC11MZqyRXbNq5eRsGpCovjfLZ5d57t5itdH0B54G5iqq6DdroUkNVTCIfZso7hYbrhNZcPCyCLYFa5SwoxAvwoNY58KCwYz)qoO7N1B5WxX5qpbbGih0Uj5FoYvyvokI3FqLaVCZ7xv4bSIG07gIdyx5c57tyRHq6nwCq2rXGGffbP3neLqJ(pYL8cZICKHl5OY(0r6jiaefZziS1yMf5OYwUcRsGxU59Rk8awrq6DdXbSR86aKmfgzhhaWqVLaVCZ7xv4bSIG07gIdyxjOdPOB3bwCq28UVHg9xueKE3quGeZ6VcvrKRU2CgcBno4ekNKlbE5M3VQWdyfbP3nehWUY95KYG7fZ37LfhKnV7BOr)ffbP3nefiXS(Rqve5QRnNHWwJdoHIiYLaVCZ7xv4bSIG07gIdyxz0ca3Gyd6CGujWl38(vfEaRii9UH4a2vADmxc3G4aTMeloiBrH0c9n6sfP(gWwhsGxU59Rk8awrq6DdXbSRm62Da3GytIW0tmiyXbzhfdcwueKE3qucn6)yf8UVHg9xueKE3quGeZ6VcvrKRUM39n0O)IIG07gIcKyw)vOiI811MZqyRXbNq5eRsGxU59Rk8awrq6DdXbSRmwry3igw(LHyVkjK2Nuy4kAneZB4EzXbzhOOyqWcCfTgI5nCV4affdcwcn6VUokgeSOii9UHOajM1FfQvvDT5me2ACWjueHvjWl38(vfEaRii9UH4a2vIUH3asK)yiP6FFoXIdYokgeSOii9UHOeA0)Xk4DFdn6VOii9UHOajM1FfQNyvDnV7BOr)ffbP3nefiXS(Rqre5RRnNHWwJdoHIiYLaVCZ7xv4bSIG07gIdyxjVFo9gCnkGbVldXIdYokgeSOii9UHOeA0)Xk4DFdn6VOii9UHOajM1FvDnV7BOr)fE)C6n4AuadExgQWLwiasXwe5pkQqBfE)C6n4AuadExgchfd)cKyw)vhRG39n0O)c0v(daRIFmqohOcKyw)vh5DFdn6Va6ktHBqmymerbsmR)Q6AZziS14GtOufYNaVCZ7xv4bSIG07gIdyxPIG07gIe4LBE)QcpGveKE3qCa7knjch)rD8hWGnKtS4GSJIbblkcsVBikHg9NaVCZ7xv4bSIG07gIdyxP4yOdIWFa4O7QmwCq2rXGGffbP3neLqJ(tGpCovT9nKJOJwX(diNd5UmKkhWgMdHCIhBuoW9bq50WCaYV3CIIbbvSKJdMJ4wP8OlvY58VOxeQCmiICSohaKLJjr5CB0KYYH39n0O)CIwffYP)CwKw)Urxkh6jgNuLe4LBE)QcpGveKE3qCa7kH0k2FayW7Yqkw4i4xcBleazk2NyXbzhfdcwueKE3qucn6)yf2cbqwXCgcBno4ekNkSQUUIkSfcGSIeTxtQiMBOwfYvxBleazfjAVMurm3qHTiYj)XkwU5iry6jgNuSpvxBleazfZziS14GtOksvjV811vyleazfZziS1yXCdlICOEMChRy5MJeHPNyCsX(uDTTqaKvmNHWwJdoH65oN8YlFc8YnVFvHhWkcsVBioGDLGnpwrb8kAe0nchrldloi7OyqWIIG07gIsOr)jWl38(vfEaRii9UH4a2vYqmnebUbX3yUhWbiTmkwCq2rXGGffbP3neLqJ(pspbbGaLZjxc8YnVFvHhWkcsVBioGDLqxS4lH9hReVCIfhKDumiyrrq6Ddrj0O)e4LBE)QcpGveKE3qCa7kJwa4geBqNdKIfhKDumiyrrq6Ddrj0O)e4e4dNdRfO3q3qKdAj)s5Oii9UHihxLtS4e4LBE)QIIG07gc2GUYu4gedgdrWIdYokgeSOii9UHOajM1FfkNQRxU5iry6jgNuOEkbE5M3VQOii9UH4a2vQe7)7pamhUpHbY5aXIdYM3mrnwzqhi6yfl3CKim9eJtkufPUE5MJeHPNyCsH6PJII39n0O)c0v(daRIFmqohOsSy5tGxU59RkkcsVBioGDLqx5paSk(Xa5CGyHJGFjSTqaKPyFIfhKnVzIASYGoquc8HZrgjxLdA)EZHVklNdPpKC2pKJ)gbHXITCmjkhU0(pDZXbZXKOCyTEEI(CCvoqAdiYz)qoQMHmj)bKJKdqIG50FoMeLJyO3q3qKZ1vwovi6eyTLphxLZI063n6sLe4LBE)QIIG07gIdyxjORmfUbXGXqeS4VrqySyd7GSbWdfiXS(Rylxc8YnVFvrrq6DdXbSRe0vgUbXMeHrl5gHnhabzHJGFjSTqaKPyFIfhKnxYr5Se4LBE)QIIG07gIdyxjKqIGkclTqgwCq2CjVWSihz4soQNospbbGOyodHTgZSihLtjWhoNQKIYP6M1MLCClh0(9Mt)xe5ebPfOCywLrqe54G5u16woNxZe154QCKfz1YKJTx6nkKaVCZ7xvueKE3qCa7kJUlhOo2Wa5CGyHJGFjSTqaKPyFIfhKnVzIASYGoquDTOS9sVvKCdZBMOUq)gDPqc8YnVFvrrq6DdXbSRuj2)3FayoCFcdKZbkbobE5M3VQOm2OLC41Fa4aCb0pwC8ZLsGxU59Rkk7a2vc6ktHBqmymebloiBBV0BffbP3nef63OlfQR5DFdn6VyDmxc3G4aTMubsmR)kuzD11iTqFJUurQVbS1He4dNtvsr5i6eyTZP)CSfcGmvoODtQJTCqwzHaLtdMJjr5CEW9PCcuumiil54G5iUvkp6sSKZ(HCCWCKPf954QCwlNlTklhrYrr8(dQCw0lIe4LBE)QIYoGDLqx5paSk(Xa5CGyHJGFjSTqaKPyFIfhKnV7BOr)fRJ5s4gehO1KkqIz9xHQi11iTqFJUurQVbS1He4LBE)QIYoGDLWyLK)aWi7nqy0(hyXbzhfdcwGXkj)bGr2BGWO9pucn6)4YnhjctpX4Kc1tjWl38(vfLDa7kHeseuryPfYWIdYMl5fMf5idxYr9uc8YnVFvrzhWUsqxz4geBsegTKBe2CaeKfoc(LW2cbqMI9jwCq2CjhLZsGxU59Rkk7a2vspbb4IM)aW01rUdzXbzZLCuyF2r6jiaeOWk5sGpCovjfLZ5vDooyoi64CwiLdtdPCmP9ZrUCopjpNf9IihqyZKdZI8C2pKJ0IeLZPCONyqWsonmNfs5W0qkhtA)CoLZ5j55SOxe5acBMCywKNaVCZ7xvu2bSRKl54OyOYyXbzZL8cZICKHl5Ok3XLBoseMEIXjf7t11CjVWSihz4soQNsGpCovjfLJmSwYXbZbrhNZcPCoxonmhMgs5WL8Cw0lICaHntomlYZz)qoY0I(C2pKJqv(HKZcPCIAtkNVTCIfNaVCZ7xvu2bSR0CaeelEVmSWrWVe2wiaYuSpXIdYM3mrnwzqhi6ixYlmlYrgUKJ6zhfvOTI1XCjCdId0AsfiXS(RogfdcwuwdzW0cnj8(bmOdPsOr)jWl38(vfLDa7k5sog9IeLaVCZ7xvu2bSRuj2)3FayoCFcdKZbIfhKnVzIASYGoq0XOyqWsyFoHBqmxYr2Ebsl3sGpCovjfLt1nRDooyorTjLZH0hso7hYr0jWANZcPC(2YHFBfXsonmhrNaRDoUkh(Tvuo7hY5q6djhxLZ3wo8BROC2pKdIoohPfjkhMgs5ys7NJi5WLCwYPH5Ci9HKJRYHFBfLJOtG1ohxLZ3wo8BROC2pKdIoohPfjkhMgs5ys7NZz5WLCwYPH5GOJZrArIYHPHuoM0(5WQC4sol50WCCWCq0X5aGSC2CedBEc8YnVFvrzhWUYO7YbQJnmqohiw4i4xcBleazk2NyXbzZBMOgRmOdeDSIk4DFdn6VyDmxc3G4aTMubsmR)kufPUgPf6B0Lks9nGToi)Xk4DFdn6VaDL)aWQ4hdKZbQajM1FfQICK39n0O)cORmfUbXGXqefiXS(RqvK6AE33qJ(lqx5paSk(Xa5CGkqIz9xHYzh5DFdn6Va6ktHBqmymerbsmR)kup7ixYrvK6AE33qJ(lqx5paSk(Xa5CGkqIz9xH6zh5DFdn6Va6ktHBqmymerbsmR)kuo7ixYr9C11CjhvwjFDDumiyjQbclg28sSy5tGxU59Rkk7a2vAoacIfVxgw4i4xcBleazk2NyXbzZBMOgRmOdeDKl5fMf5idxYr9uc8HZPkPOCoebw7C2pKJ)gbHXITCClhLbxhGKLZIErKaVCZ7xvu2bSRe8IWFayfbftVHbY5aXI)gbHXIn2NsGpCovjfLt1nRDooyohsFi54QC43wr5SFiheDCoslsuoIKdxYZz)qoi6yyo3vz5a42r7nh0RkhzyTWsonmhhmheDColKYzJ6ylhRZHVIZHEccaro7hYHCtIG5GOJH5CxLLdaEih0RkhzyTKtdZXbZbrhNZcPCUKsLJjTFoIKdxYZzrViYbe2m5WxXI9hqc8YnVFvrzhWUYO7YbQJnmqohiw4i4xcBleazk2NyXbzxbV7BOr)fqxzkCdIbJHikqIz9xHYzh5soBrQRPNGaqumNHWwJzwKJYj5pwHyiHegapuovmhabXI3ltDnxYlmlYrgUKJIiYRnTP1a]] )

end