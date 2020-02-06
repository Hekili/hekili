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

    spec:RegisterStateExpr( "combo_break", function () return this_action == virtual_combo and combos[ virtual_combo ] end )

    spec:RegisterStateExpr( "combo_strike", function () return not combos[ this_action ] or this_action ~= virtual_combo end )


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
        if prev_gcd[1].tiger_palm and ( class.abilities.tiger_palm.lastCast == 0 or combat == 0 or class.abilities.tiger_palm.lastCast < combat - 0.05 ) then
            prev_gcd.override = "none"
            prev.override = "none"
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

            usable = function ()
                return incoming_damage_3s >= health.max * 0.2
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

    spec:RegisterSetting( "optimize_reverse_harm", false, {
        name = "Optimize |T627486:0|t Reverse Harm",
        desc = "If checked, the |T627486:0|t Reverse Harm's caption will show the recommended target's name.",
        type = "toggle",
        width = 1.5
    } ) 
    
    spec:RegisterPack( "Windwalker", 20200124, [[dKe3obqirepseLnjs9jePu1Oijofj0Rijnlcv3sePDjQFrinmvP6ysjldr1ZKszAQsX1iPQTjLQ8nsQuJtevohIuTosQiZdrCpvX(ibhKKkzHKuEijvyIisbxKKkQnkIQAKisPCsruLwPQKxkIQWnfrv0ojugkIuQSuePONIWujexfrk5RisH2ls)f0GHCyjlMuEmWKf6YO2mr(SumAI60uTAPuvVMenBP62eSBL(TIHRQCCPuz5q9CbtNY1jvBhr57IKXJi58IW6vLsZxv1(vzAlQiuIyzmvmYFN83FVf5Vj)oP)g1DR3qjSeFmL4RakRgMsSLatjin6Bmv1vYykXxLOpvKkcLim6yatjKn7lOojQOnUjRRLbJGObxqVxMplaxsMObxaikLqt37wY7s1OeXYyQyK)o5V)ElYFt(Ds)nQ7wKtjcFmGkg5ThPtjK9yKxQgLiYbaLizhI0OVXuvxjJpuYZzvEVs2HKn7lOojQOnUjRRLbJGObxqVxMplaxsMObxai69kzh6vT6foXHiVL4hI83j)9719kzhsDixBdhuNUxj7qj9qKMSWqgFiIpUWhI0wTXdryyxjFiWSrZNnCivKRn254H0sCOkgNvX89kzhkPhI0KfgY4dL8jsECimdgbbEJL5ZEivs59(H0yWiWhQo0hMLumFVs2Hs6HuhY12WhYkCdBqx6q2CiqcqNHwHBylKVxj7qj9qKMSWqgFiEzCtIdbQVdbKzGYdjn4dL89Gfo0iDOKVooXHuj4chk6ssmMxaFipCOLB6EJR1zXpKMUDOVEL4qrxsIX8c4d5Hdf8M1LCqTMI57vYouspK6kg54HiTc8HsEnwiCivmSVkzli(HydKvmtj6EWcurOerwQ07gveQyTOIqjkG5ZsjcFCHHY1gHbd7kzkbVLwNJu1OgvmYPIqj81ymzvNsq6Vtj(aguMRUjtjEpREkrbmFwkHn6az4ibvwyHIsWBP15ivnQrfRnQiucElTohPQrjay3ySxucnDjPCGX86wIS(3H()puCSSn6az4ibJCzYzmlu(go0))HsYHSQZRLdmMx3sK5T06C8qPpKH9vjB5p8aYvJ3DlrgZfWo0))H00LKYA9zID9GLXCbSd9)FiZfyOnWOZhIKNd1EVtjkG5Zsj(gZNLAuXEdvekbVLwNJu1OeaSBm2lkHMUKuoWyEDlrw)JsuaZNLsaQEhwaZNf29Grj6EWGBjWuIaJ51TeuJkM6PIqj4T06CKQgLaGDJXErju5q8Y4MezZfyOnqHIuhIKd16q))hsLdzvNxlhymVULiZBP154HsFiWm94KAZbgZRBjYywO8nCisoe5hsXdP4HsFiGSNfksDOKEiGSFifEoe5uIcy(SucmtgJdmuUWcuJkw7rfHsWBP15ivnkba7gJ9IsOYH4LXnjYMlWqBGcfPoejhQ1H()pKkhYQoVwoWyEDlrM3sRZXdL(qGz6Xj1MdmMx3sKXSq5B4qKCiYpKIh6))qQCiEzCtIS5cm0gOqrQdrYHEZHsFiWm94KAZsEWcWrckPJtKXSq5B4qKCOwz1FifpKIhk9HaYEwOi1Hs6HaY(Hu45qTrjkG5ZsjK8GbhjOjZWuYUXqZBym1OIPUPIqj4T06CKQgLOaMplLW8ggd)QUaLaGDJXErjsYHaJG2a1WCP8qPpKkhIxg3KiBUadTbkuK6qKCOwh6))qQCiR68A5aJ51TezElTohpu6dbMPhNuBoWyEDlrgZcLVHdrYHi)qkEO))dPYH4LXnjYMlWqBGcfPoejh6nhk9HaZ0JtQnl5blahjOKoorgZcLVHdrYHALv)Hu8qkEO0hci7zHIuhkPhci7hsHNdr(HsFOKCO4yzB0bYWrcg5YKZywO8nqjajaDgAfUHTavSwuJkwYrfHsWBP15ivnkba7gJ9IsKKdzvNxll5bdosqtMHPKDJHM3W4mVLwNJhk9HmxGpejphQnkrbmFwkbq2HPkYyQrfJ0PIqj4T06CKQgLOaMplLau9oSaMplS7bJs09Gb3sGPeGi1OI16DQiucElTohPQrjay3ySxuIcyozmKxwW5WHi5qTrjkG5ZsjavVdlG5Zc7EWOeDpyWTeykrWOgvSwTOIqj4T06CKQgLaGDJXErjkG5KXqEzbNdhsHNd1gLOaMplLau9oSaMplS7bJs09Gb3sGPe1WuJAucBIurOI1IkcLG3sRZrQAuca2ng7fLGBNU)9XXmibOpgEwha16vWou6dzfUHTS5cm0gy05dPWHi9dL(qGz6Xj1Mbja9XWZ6aOwVcwgZcLVHdrYZHArjkG5ZsjSrhidhjyKltMAuXiNkcLG3sRZrQAuca2ng7fLijhIBNU)9XXmibOpgEwha16vWou6dXTt3)(4yoIDnTUVnqFv(nXdL(qwHBylBUadTbgD(qkCis)qPpKkhYkCdBzZfyOnWpGbB79dPWZHA127h6))qwHBylBUadTb(bmyBVFisouYDifPefW8zPe2OdKHJemYLjtnQyTrfHsWBP15ivnkba7gJ9IsKKdXTt3)(4ygKa0hdpRdGA9kyhk9HsYH42P7FFCmhXUMw33gOVk)M4HsFiRWnSLnxGH2aJoFifoePtjkG5ZsjSrhidhjyKltMAuJs8HzWiOvgveQyTOIqjkG5Zsj(gZNLsWBP15ivnQrfJCQiucElTohPQrjMpkrGnkrbmFwkbzf2lTotjiR66mLGBNU)9XXCfKjRwoaX1Bhmem4QFO0hsLdXTt3)(4ygKa0hdpRdGA9kyh6))qC709VpoM76bdp6byZ0J8c)66cvdFO))dXTt3)(4yUPxrVSbhGAvSHp0))H42P7FFCm30ROx2Gdqbow9Up7HuKsqwHHBjWucWGRomo6ADgAteolupWuJkwBurOe8wADosvJsaWUXyVOeQCOKCiR68A5aJ51TezElTohp0))HsYHSQZRLL8GbhjOjZWuYUXqZByCM3sRZXdPiLOaMplLai7qnDCWOgvS3qfHsWBP15ivnkba7gJ9IsyvNxll5bdosqtMHPKDJHM3W4mVLwNJuIcy(SucGSdtvKXuJkM6PIqjkG5Zsj8LSrjdjLoVucElTohPQrnQyThvekrbmFwkrJEHJETWrcwVLXJjtj4T06CKQg1OgLOgMkcvSwurOe8wADosvJsuaZNLsG9GVnWG(cv6aLuca2ng7fLqLdzvNxlNs2XDFBGrC1ml8tFbYzElTohpu6dbMPhNuBoLSJ7(2aJ4Qzw4N(cKZywO8nCisoK6pKIhk9HaZ0JtQnl5blahjOKoorgZcLVHdPWHAJsasa6m0kCdBbQyTOgvmYPIqjkG5Zsjsj74UVnWiUAMf(PVazkbVLwNJu1OgvS2OIqj4T06CKQgLaGDJXErjsYH(WmzWgqm3kBEdJHFvx4qPpeq2pejphQ1HsFiEzCtIdrYHu)7uIcy(SucEzCJ)wFBGC3jLJPgvS3qfHsuaZNLsi5blahjOKoobLG3sRZrQAuJkM6PIqj4T06CKQgLaGDJXErj00LKYy9GSVnW2VImmLVXCCsTuIcy(SucSEq23gy7xrgMY3i1OI1EurOe8wADosvJsaWUXyVOeGrqBGbd7k5dL(qQCivoKkhci7hsHd12H()peyMECsTzjpyb4ibL0XjYywO8nCifou7Difpu6dPYHaY(Hu45qQ)q))hcmtpoP2SKhSaCKGs64ezmlu(goKchI8dP4Hu8q))hIxg3KiBUadTbkuK6qK8CO2oKIuIcy(SuIWNVRVnqaUwgQ0bkPgvm1nvekbVLwNJu1OeaSBm2lkbq2ZcfPouspeq2pKcphICkrbmFwkbMjJXbgkxybQrfl5OIqj4T06CKQgLaGDJXErjaY(Hi55qTrjkG5ZsjaYouthhmQrfJ0PIqj4T06CKQgLaGDJXErjaYEwOi1Hs6HaY(Hu45qTrjkG5ZsjK8GbhjOjZWuYUXqZBym1OI16DQiucElTohPQrjkG5ZsjmVHXWVQlqjay3ySxucGSNfksDOKEiGSFifEoe5hk9Hu5qj5qw151YYUbbJG2K5T06C8q))hkjhcmcAdudZLYdPiLaKa0zOv4g2cuXArnQyTArfHsWBP15ivnkba7gJ9IsKKdbgbTbQH5sjLOaMplLai7Wufzm1OI1ICQiucElTohPQrjkG5Zsj06fq5OBqLoqjLaGDJXErjaJG2adg2vYhk9Hu5qA6sszTrj8dpGS(3H()pKkhYQoVww2niye0MmVLwNJhk9H(WmzWgqm3kBEdJHFvx4qPpeq2pejh6nhsXdPiLaKa0zOv4g2cuXArnQrjcmMx3sqfHkwlQiucElTohPQrjkG5ZsjWEW3gyqFHkDGskba7gJ9IsuaZjJH8YcohoejhQTd9)FOpmtgSbeZTYHpFxFBGaCTmuPdusjajaDgAfUHTavSwuJkg5urOe8wADosvJsaWUXyVOeQCinDjPSwFMyxpyz9VdL(qFyMmydiMBLXEW3gyqFHkDGYdP4H()pKMUKuoWyEDlrgZcLVHdrYHADO))dPYHkG5KXqEzbNdhsHd16qPpubmNmgYll4C4qKCi1FifPefW8zPesEWcWrckPJtqnQyTrfHsWBP15ivnkba7gJ9IsyvNxll7gemcAtM3sRZXdL(q8Y4MezZfyOnqHIuhIKdr(HsFOpmtgSbeZTYA9cOC0nOshO8qPpeq2pejphICkrbmFwkHKhm4ibnzgMs2ngAEdJPgvS3qfHsWBP15ivnkba7gJ9IsyvNxll7gemcAtM3sRZXdL(q8Y4MezZfyOnqHIuhIKd16qPp0hMjd2aI5wzTEbuo6guPduEO0hci7zHIuhkPhci7hsHNdroLOaMplLW8ggd)QUa1OIPEQiucElTohPQrjay3ySxucWiOnWGHDL8HsFivoubmNmgYll4C4qk8CO2o0))Hu5qw151YYUbbJG2K5T06C8qPp0hMjd2aI5wzTEbuo6guPduEifp0))Hu5qfWCYyiVSGZHd9CiYpu6d9HzYGnGyUvwRxaLJUbv6aLhsXdPiLOaMplLi8576BdeGRLHkDGsQrfR9OIqj4T06CKQgLOaMplLqRxaLJUbv6aLucqcqNHwHBylqfRf1OgLiyurOI1IkcLOaMplLiLSJ7(2aJ4Qzw4N(cKPe8wADosvJAuXiNkcLOaMplLqYdwaosqjDCckbVLwNJu1OgvS2OIqj4T06CKQgLOaMplLa7bFBGb9fQ0bkPeaSBm2lkbq2pKcphs9ucqcqNHwHBylqfRf1OI9gQiucElTohPQrjkG5ZsjWEW3gyqFHkDGskbibOZqRWnSfOI1IAuXupvekbVLwNJu1OeaSBm2lkHMUKugRhK9Tb2(vKHP8nMJtQ9qPpubmNmgYll4C4qkCOwuIcy(SucSEq23gy7xrgMY3i1OI1EurOe8wADosvJsaWUXyVOeazpluK6qj9qaz)qk8CiYPefW8zPeyMmghyOCHfOgvm1nvekbVLwNJu1OeaSBm2lkbq2pejphICkrbmFwkHKhm4ibnzgMs2ngAEdJPgvSKJkcLG3sRZrQAuca2ng7fLai7hIKNd12HsFiEzCtIdrYHu)7uIcy(SucEzCJ)wFBGC3jLJPgvmsNkcLG3sRZrQAuca2ng7fLamcAdmyyxjFO0hstxskhRfWWrccK923ZyUagLOaMplLi8576BdeGRLHkDGsQrfR17urOe8wADosvJsuaZNLsO1lGYr3GkDGskba7gJ9IsagbTbgmSRKpu6dPYHaZ0JtQnJ9GVnWG(cv6aLzmlu(goKchQTd9)FiGSFifEouBhsXdL(qQCiWm94KAZsEWcWrckPJtKXSq5B4qkCO3CO))dbK9dPWZHEZH()pKkhci7h65qKFO0h6dZKbBaXCRS5nmg(vDHdP4HuKsasa6m0kCdBbQyTOgvSwTOIqjkG5ZsjaYomvrgtj4T06CKQg1OI1ICQiucElTohPQrjay3ySxucGSNfksDOKEiGSFifEouRdL(qfWCYyiVSGZHd9COwh6))qazpluK6qj9qaz)qk8CiYPefW8zPeazhQPJdg1OI1QnQiucElTohPQrjkG5ZsjmVHXWVQlqjay3ySxucWiOnWGHDL8HsFiGSNfksDOKEiGSFifEoe5ucqcqNHwHBylqfRf1OI16nurOe8wADosvJsuaZNLsi1t4BdmW4pEnOshOKsaWUXyVOeFyMmydiMBL16fq5OBqLoq5HsFiGSFifouBucFngJ1)mkrlQrnkbisfHkwlQiuIcy(SucFjBuYqsPZlLG3sRZrQAuJkg5urOe8wADosvJsaWUXyVOewHBylBUadTbgD(qkCOwjN6p0))Hu5qj5qC709VpoMJyxtR7Bd0xLFt8q))hIBNU)9XXmibOpgEwha16vWo0))HSc3WwwMRUjN)a2Hi5qT9(Hu8qPpeyMECsTzB0bYWrcg5YKZywO8nCisEouR3CO))dXTt3)(4yoIDnTUVnqFv(nXdL(qwHBylBUadTb(bmyBVFisoe5VFO))dzfUHTS5cm0gy05drYHAt9uIcy(SuIg9ch9AHJeSElJhtMAuXAJkcLG3sRZrQAuca2ng7fLamtpoP2Sn6az4ibJCzYzmlu(goKchs9j3H()peyMECsTzB0bYWrcg5YKZywO8nCisoe5h6))qwHBylBUadTbgD(qKCiYFNsuaZNLsKAW9izSVqmhMTwatnQyVHkcLOaMplLqRptekPJtqj4T06CKQg1OIPEQiuIcy(SucnghySsFBOe8wADosvJAuXApQiucElTohPQrjay3ySxucGSNfksDOKEiGSFifEouRdL(q8Y4MezZfyOnqHIuhsHNd9Ew9uIcy(SuIcdQLH2GX8AuJkM6MkcLOaMplLO7nYwa2(6XgbEnkbVLwNJu1OgvSKJkcLOaMplLqRAGJe0WoqzGsWBP15ivnQrfJ0PIqj4T06CKQgLOaMplLau9oSaMplS7bJs09Gb3sGPe2ePgvSwVtfHsWBP15ivnkba7gJ9IsaMPhNuBoydwaYf2KH1gHsoMZa5c3WHd9CiYp0))Hu5qj5qCiWlGZPgCpsg7leZHzRfWzHQ9h8H()pKkhstxskNAW9izSVqmhMTwaN1)o0))HaZ0JtQnNAW9izSVqmhMTwaNXSq5B4qkCiWm94KAZbBWcqUWMmS2iuYXCwsV3Hygix4ggAUaFifpKIhk9Hu5qGz6Xj1MTrhidhjyKltoJzHY3WHu4qGz6Xj1Md2GfGCHnzyTrOKJ5SKEVdXmqUWnm0Cb(q))hcmtpoP2Sn6az4ibJCzYzmlu(goKchYkCdBzZfyOnWOZhsXdL(qGz6Xj1ML8GfGJeushNiJzHY3WHi55qK(HsFiGSFifEouBhk9HaZ0JtQnNs2XDFBGrC1ml8tFbYzmlu(goejphQvBh6))qXXY2OdKHJemYLjNXSq5B4q))hYCbgAdm68Hi5qK)oLOaMplLiydwaYf2KH1gHsoMPgvSwTOIqj4T06CKQgLaGDJXErjIJLTrhidhjyKltoJzHY3WH()pKv4g2YMlWqBGrNpejhQf5uIcy(SucT(mr4ibnzgYllKGAuXArovekbVLwNJu1OeaSBm2lkb3oD)7JJzqcqFm8SoaQ1RGDO0hcmtpoP2mibOpgEwha16vWYywO8nCifEoe5VFO))dLKdXTt3)(4ygKa0hdpRdGA9kyuIcy(Suc9adDJfcuJkwR2OIqj4T06CKQgLaGDJXErjIJLTrhidhjyKltoJzHY3WH()pKv4g2YMlWqBGrNpejhQv7rjkG5ZsjQfWbdxDiO6DQrfR1BOIqj4T06CKQgLaGDJXErjIJLTrhidhjyKltoJzHY3WH()pKv4g2YMlWqBGrNpejhI0PefW8zPesoM16ZePgvSwQNkcLG3sRZrQAuca2ng7fLijhkowgmlGxdxghHs9sGHA64nJzHY3WHsFivoeyMECsTzWSaEnCzCek1lboJzHY3WHi55qGz6Xj1MTrhidhjyKltoJzHY3WHsFivoKvDETCkzh39TbgXvZSWp9fiN5T06C8qPpeyMECsT5uYoU7BdmIRMzHF6lqoJzHY3WHu8qPpeyMECsTzSh8Tbg0xOshOmJzHY3WHsFiWm94KAZsEWcWrckPJtKXSq5B4qPpKMUKuoydwaYf2KH1gHsoMZXj1EO))dfhlBJoqgosWixMCgZcLVHdP4H()pK5cm0gy05drYHsokrbmFwkbywaVgUmocL6LatnQyTApQiucElTohPQrjay3ySxucZfyOnWOZhsHd1k5A7q))hkow2gDGmCKGrUm5mMfkFdh6))qMlWqBGrNpejhQvBuIcy(SucnghySsFBOgvSwQBQiucElTohPQrjkG5Zsj(gGs2c(B5iemcF6wz(SWitMdykba7gJ9IsehlBJoqgosWixMCgZcLVbkXwcmL4Bakzl4VLJqWi8PBL5ZcJmzoGPgvSwjhvekbVLwNJu1OefW8zPevqMSA5aexVDWqWGRoLaGDJXErjiRWEP15myWvhghDTodTjcNfQh4dL(qGz6Xj1MTrhidhjyKltoJzHY3WHu45qK32HsFivouK10LKY46TdgcgC1HrwtxskhNu7H()pKMUKuoydwaYf2KH1gHsoMZywO8nCifouR2o0))HmxGH2aJoFOKEiWm94KAZ2OdKHJemYLjNXSq5B4qKCO38(HsFiWm94KAZ2OdKHJemYLjNXSq5B4qKCiYB7q))hYCbgAdm68Hi5qKR(dPiLylbMsubzYQLdqC92bdbdU6uJkwlsNkcLG3sRZrQAuIcy(SuIkitwTCaIR3oyiyWvNsaWUXyVOej5qKvyV06Cgm4QdJJUwNH2eHZc1d8HsFivouK10LKY46TdgcgC1HrwtxskhNu7H()pKkhkjhIBNU)9XXCe7AADFBG(Q8BIh6))qwHBylBUadTb(bmyBVFisouYDifpu6dPYHIJLTrhidhjyKltoJzHY3WH()peyMECsTzB0bYWrcg5YKZywO8nCivpePFifoKv4g2YMlWqBGrNpu6dPPljLd2GfGCHnzyTrOKJ5S(3H()pK5cm0gy05drYHix9hsXdPiLylbMsubzYQLdqC92bdbdU6uJkg5VtfHsuaZNLsyYmuF1g9ncLgmGPe8wADosvJAuXiVfvekrbmFwkXNo2Ls4BduRxbJsWBP15ivnQrfJCYPIqjkG5ZsjWC95BduQxcCGsWBP15ivnQrfJ82OIqjkG5ZsjKgGEGJW6Tm2ngQXLaLG3sRZrQAuJkg5VHkcLG3sRZrQAuca2ng7fLamtpoP2m2d(2ad6luPduMXSq5B4qK8CiYp0))HmxGH2aJoFisEoulYPefW8zPebgZRBjOgvmYvpvekbVLwNJu1OeaSBm2lkbVmUjXHi5qV59dL(qA6ss5GnybixytgwBek5yoR)rjkG5ZsjeyHbNaosWUoWJWiMlHa1OIrE7rfHsuaZNLsG9VVod9fg(katj4T06CKQg1OIrU6MkcLOaMplLqpWq3yHaLG3sRZrQAuJAuJsqgJd(SuXi)9wKERwTArjsv413MaLi5v4BWghpK6(qfW8zpu3dwiFVOeF4rY7mLizhI0OVXuvxjJpuYZzvEVs2HKn7lOojQOnUjRRLbJGObxqVxMplaxsMObxai69kzh6vT6foXHiVL4hI83j)9719kzhsDixBdhuNUxj7qj9qKMSWqgFiIpUWhI0wTXdryyxjFiWSrZNnCivKRn254H0sCOkgNvX89kzhkPhI0KfgY4dL8jsECimdgbbEJL5ZEivs59(H0yWiWhQo0hMLumFVs2Hs6HuhY12WhYkCdBqx6q2CiqcqNHwHBylKVxj7qj9qKMSWqgFiEzCtIdbQVdbKzGYdjn4dL89Gfo0iDOKVooXHuj4chk6ssmMxaFipCOLB6EJR1zXpKMUDOVEL4qrxsIX8c4d5Hdf8M1LCqTMI57vYouspK6kg54HiTc8HsEnwiCivmSVkzli(HydKvmFVUxj7qQZKIb6ghpKglny(qGrqRSdPXn(gYhsDba8Nfo0oBsLlSGKE)qfW8zdhA2EI89kzhQaMpBi)HzWiOv2JuVckVxj7qfW8zd5pmdgbTYu9ruPzI3RKDOcy(SH8hMbJGwzQ(iAP3iWRvMp79kzhIyRVG8yhcxE8qA6ssC8qbRSWH0yPbZhcmcALDinUX3WHQnEOpmN0VXmFBoKhouCwoFVs2HkG5ZgYFygmcALP6JOHT(cYJbdwzH7vbmF2q(dZGrqRmvFe9BmF27vbmF2q(dZGrqRmvFeLSc7LwNfFlb(bm4QdJJUwNH2eHZc1dS4Z3tGnXjR668d3oD)7JJ5kitwTCaIR3oyiyWvpTkC709VpoMbja9XWZ6aOwVc2)p3oD)7JJ5UEWWJEa2m9iVWVUUq1W))C709VpoMB6v0lBWbOwfB4)FUD6(3hhZn9k6Ln4auGJvV7ZQ49QaMpBi)HzWiOvMQpIcKDOMooyI7spQKeR68A5aJ51TezElToh))tIvDETSKhm4ibnzgMs2ngAEdJZ8wADoQ49QaMpBi)HzWiOvMQpIcKDyQImwCx6XQoVwwYdgCKGMmdtj7gdnVHXzElTohVxfW8zd5pmdgbTYu9ruFjBuYqsPZl0Kzykz3yO5nm(EvaZNnK)Wmye0kt1hrB0lC0RfosW6TmEm5719kzhsDMumq344HyYyCIdzUaFitMpubSbFipCOISY7LwNZ3RKDOcy(SHNs3gyzwbuEVkG5Zgu9r0WhxyOCTryWWUs(EvaZNnO6JO2OdKHJeuzHfkX91ymzv)H0Fx8pGbL5QBYpVNv)9kzhI0UX8zpKlDicgZRBjo0GpeHnybXpK6CHnzXpuTXdL8DmFOcZhs)7qd(qjg9dvy(qy9D9T5qbgZRBjouTXdvhsO89qbRSdzyFvY2H(Wdii(Hg8Hsm6hQW8H03iJpKjZhILKyGDOr6qA9zID9Gj(Hg8HSc3W2HmxGpKnhk68H8WHAWCzm(qd(qC70R(HS5qT373Rcy(SbvFe9BmFwXDPhnDjPCGX86wIS(3)FCSSn6az4ibJCzYzmlu(g()tIvDETCGX86wImVLwNJPnSVkzl)HhqUA8UBjYyUa2)VMUKuwRptSRhSmMlG9)BUadTbgDMKN2797vbmF2GQpIcQEhwaZNf29Gj(wc8tGX86wcXDPhnDjPCGX86wIS(39QaMpBq1hrXmzmoWq5cliUl9OcVmUjr2CbgAduOifjT()vXQoVwoWyEDlrM3sRZX0Gz6Xj1MdmMx3sKXSq5BGeYvuX0azpluKkPazxHhYVxfW8zdQ(iQKhm4ibnzgMs2ngAEdJf3LEuHxg3KiBUadTbkuKIKw))QyvNxlhymVULiZBP15yAWm94KAZbgZRBjYywO8nqc5k()RcVmUjr2CbgAduOifjVjnyMECsTzjpyb4ibL0XjYywO8nqsRS6vuX0azpluKkPazxHN2UxfW8zdQ(iQ5nmg(vDbXbjaDgAfUHTWtlXDPNKagbTbQH5szAv4LXnjYMlWqBGcfPiP1)Vkw151YbgZRBjY8wADoMgmtpoP2CGX86wImMfkFdKqUI))QWlJBsKnxGH2afksrYBsdMPhNuBwYdwaosqjDCImMfkFdK0kREfvmnq2ZcfPskq2v4H80jjow2gDGmCKGrUm5mMfkFd3Rcy(SbvFefi7WufzS4U0tsSQZRLL8GbhjOjZWuYUXqZByCM3sRZX0MlWK8029QaMpBq1hrbvVdlG5Zc7EWeFlb(beVxj7qQJQ3pKjZhIqKdvaZN9qDpyhYLoKjZy(qfMpe5hAWhQZHWH4LfCoCVkG5Zgu9ruq17Wcy(SWUhmX3sGFcM4U0tbmNmgYll4CGK2Uxj7qQJQ3pKjZhsDnQZhQaMp7H6EWoKlDitMX8HkmFO2o0GpKWG5dXll4C4EvaZNnO6JOGQ3HfW8zHDpyIVLa)udlUl9uaZjJH8Ycohu4PT719kzhsDbmF2qwDnQZhYdhYxJ3ihpK0GpKEGpuk3KpePngyoaQUIrO6OZfz8HQnEiGogZR1tCOL5y4q2Cin(qZN5c(B549QaMpBixd)G9GVnWG(cv6aLIdsa6m0kCdBHNwI7spQyvNxlNs2XDFBGrC1ml8tFbYzElTohtdMPhNuBoLSJ7(2aJ4Qzw4N(cKZywO8nqI6vmnyMECsTzjpyb4ibL0XjYywO8nOqB3Rcy(SHCnSQpIMs2XDFBGrC1ml8tFbY3Rcy(SHCnSQpIYlJB836BdK7oPCS4U0ts(WmzWgqm3kBEdJHFvxinq2j5PvAEzCtcsu)73Rcy(SHCnSQpIk5blahjOKooX9QaMpBixdR6JOy9GSVnW2VImmLVrXDPhnDjPmwpi7BdS9Ridt5BmhNu79QaMpBixdR6JOHpFxFBGaCTmuPdukUl9agbTbgmSRKtRIkQaKDfA7)hmtpoP2SKhSaCKGs64ezmlu(guO9umTkazxHh1))dMPhNuBwYdwaosqjDCImMfkFdkqUIk()ZlJBsKnxGH2afksrYtBkEVkG5ZgY1WQ(ikMjJXbgkxybXDPhGSNfksLuGSRWd53Rcy(SHCnSQpIcKDOMooyI7spazNKN2UxfW8zd5AyvFevYdgCKGMmdtj7gdnVHXI7spazpluKkPazxHN2UxfW8zd5AyvFe18ggd)QUG4GeGodTc3Ww4PL4U0dq2ZcfPskq2v4H80QKeR68Azz3GGrqBY8wADo()NeWiOnqnmxkv8EvaZNnKRHv9ruGSdtvKXI7spjbmcAdudZLY7vYoubmF2qUgw1hrL6j8Tbgy8hVguPdukUl9OPljL1gLWp8aYXj1kUVgJX6F2tR7vbmF2qUgw1hr16fq5OBqLoqP4GeGodTc3Ww4PL4U0dye0gyWWUsoTkA6sszTrj8dpGS(3)Vkw151YYUbbJG2K5T06Cm9hMjd2aI5wzZBym8R6cPbYojVrrfVx3RKDi1Xm94KAd3Rcy(SHmi(4lzJsgskDEHMmdtj7gdnVHX3Rcy(SHmiQ6JOn6fo61chjy9wgpMS4U0Jv4g2YMlWqBGrNvOvYP()Fvsc3oD)7JJ5i2106(2a9v53e))52P7FFCmdsa6JHN1bqTEfS)FRWnSLL5QBY5pGrsBVRyAWm94KAZ2OdKHJemYLjNXSq5BGKNwV5)NBNU)9XXCe7AADFBG(Q8BIPTc3Ww2CbgAd8dyW2ENeYF))3kCdBzZfyOnWOZK0M6VxfW8zdzqu1hrtn4EKm2xiMdZwlGf3LEaZ0JtQnBJoqgosWixMCgZcLVbfuFY9)dMPhNuB2gDGmCKGrUm5mMfkFdKq()Vv4g2YMlWqBGrNjH83VxfW8zdzqu1hr16ZeHs64e3Rcy(SHmiQ6JOAmoWyL(2CVs2HiTc8HuxyqT8HezWyETd5shkXOFOcZhsWdbFBouzhQZvWouRdPoK9dvB8qPML0E7qG67q8Y4MehkLBY(EO3ZQ)qbgmBmCVkG5ZgYGOQpIwyqTm0gmMxtCx6bi7zHIujfi7k80knVmUjr2CbgAduOiLcpVNv)9QaMpBidIQ(iA3BKTaS91Jnc8A3Rcy(SHmiQ6JOAvdCKGg2bkd3Rcy(SHmiQ6JOGQ3HfW8zHDpyIVLa)yt8EvaZNnKbrvFenydwaYf2KH1gHsoMfxCx6bmtpoP2CWgSaKlSjdRncLCmNbYfUHdpK))Rss4qGxaNtn4EKm2xiMdZwlGZcv7p4)Fv00LKYPgCpsg7leZHzRfWz9V)FWm94KAZPgCpsg7leZHzRfWzmlu(guamtpoP2CWgSaKlSjdRncLCmNL07DiMbYfUHHMlWkQyAvaZ0JtQnBJoqgosWixMCgZcLVbfaZ0JtQnhSbla5cBYWAJqjhZzj9EhIzGCHByO5c8)pyMECsTzB0bYWrcg5YKZywO8nOGv4g2YMlWqBGrNvmnyMECsTzjpyb4ibL0XjYywO8nqYdPNgi7k80wAWm94KAZPKDC33gyexnZc)0xGCgZcLVbsEA12)FCSSn6az4ibJCzYzmlu(g()nxGH2aJotc5VFVkG5ZgYGOQpIQ1NjchjOjZqEzHeI7spXXY2OdKHJemYLjNXSq5B4)3kCdBzZfyOnWOZK0I87vbmF2qgev9ru9adDJfcI7spC709VpoMbja9XWZ6aOwVcwAWm94KAZGeG(y4zDauRxblJzHY3GcpK)()Fs42P7FFCmdsa6JHN1bqTEfS7vYoePvGpK6AbCWWv)qQJQ3puuh7BZHez0bYhAKoePbUm57vbmF2qgev9r0AbCWWvhcQExCx6jow2gDGmCKGrUm5mMfkFd))wHBylBUadTbgDMKwT39kzhI0kWhk57ywRpt8qrDSVnhsKrhiFOr6qKg4YKVxfW8zdzqu1hrLCmR1NjkUl9ehlBJoqgosWixMCgZcLVH)FRWnSLnxGH2aJotcPFVkG5ZgYGOQpIcMfWRHlJJqPEjWI7spjjowgmlGxdxghHs9sGHA64nJzHY3qAvaZ0JtQndMfWRHlJJqPEjWzmlu(gi5bmtpoP2Sn6az4ibJCzYzmlu(gsRIvDETCkzh39TbgXvZSWp9fiN5T06CmnyMECsT5uYoU7BdmIRMzHF6lqoJzHY3GIPbZ0JtQnJ9GVnWG(cv6aLzmlu(gsdMPhNuBwYdwaosqjDCImMfkFdP10LKYbBWcqUWMmS2iuYXCooP2))4yzB0bYWrcg5YKZywO8nO4)V5cm0gy0zssU7vYoePvGpKAmoWyL(2COOo23MdjYOdKp0iDisdCzY3Rcy(SHmiQ6JOAmoWyL(2iUl9yUadTbgDwHwjxB))XXY2OdKHJemYLjNXSq5B4)3CbgAdm6mjTA7EvaZNnKbrvFevpWq3ybX3sGF(gGs2c(B5iemcF6wz(SWitMdyXDPN4yzB0bYWrcg5YKZywO8nCVkG5ZgYGOQpIQhyOBSG4BjWpvqMSA5aexVDWqWGRU4U0dzf2lToNbdU6W4OR1zOnr4Sq9aNgmtpoP2Sn6az4ibJCzYzmlu(gu4H82sRsK10LKY46TdgcgC1HrwtxskhNu7)VMUKuoydwaYf2KH1gHsoMZywO8nOqR2()nxGH2aJoNuWm94KAZ2OdKHJemYLjNXSq5BGK38EAWm94KAZ2OdKHJemYLjNXSq5BGeYB7)3CbgAdm6mjKREfVxfW8zdzqu1hr1dm0nwq8Te4NkitwTCaIR3oyiyWvxCx6jjKvyV06Cgm4QdJJUwNH2eHZc1dCAvISMUKugxVDWqWGRomYA6ss54KA))vjjC709VpoMJyxtR7Bd0xLFt8)3kCdBzZfyOnWpGbB7DssoftRsCSSn6az4ibJCzYzmlu(g()bZ0JtQnBJoqgosWixMCgZcLVbvjDfSc3Ww2CbgAdm6CAnDjPCWgSaKlSjdRncLCmN1)()nxGH2aJotc5QxrfVxfW8zdzqu1hrnzgQVAJ(gHsdgW3Rcy(SHmiQ6JOF6yxkHVnqTEfS7vbmF2qgev9rumxF(2aL6LahUxfW8zdzqu1hrLgGEGJW6Tm2ngQXLW9QaMpBidIQ(iAGX86wcXDPhWm94KAZyp4BdmOVqLoqzgZcLVbsEi))3CbgAdm6mjpTi)EvaZNnKbrvFevGfgCc4ib76apcJyUecI7sp8Y4MeK8M3tRPljLd2GfGCHnzyTrOKJ5S(39QaMpBidIQ(ik2)(6m0xy4Ra89QaMpBidIQ(iQEGHUXcH719kzhIGX86wId9H9b7wI7vbmF2qoWyEDlXd2d(2ad6luPdukoibOZqRWnSfEAjUl9uaZjJH8YcohiPT))pmtgSbeZTYHpFxFBGaCTmuPduEVkG5ZgYbgZRBju9rujpyb4ibL0Xje3LEurtxskR1Nj21dww)l9hMjd2aI5wzSh8Tbg0xOshOuX)FnDjPCGX86wImMfkFdK06)xLcyozmKxwW5GcTsxaZjJH8Ycohir9kEVkG5ZgYbgZRBju9rujpyWrcAYmmLSBm08gglUl9yvNxll7gemcAtM3sRZX08Y4MezZfyOnqHIuKqE6pmtgSbeZTYA9cOC0nOshOmnq2j5H87vbmF2qoWyEDlHQpIAEdJHFvxqCx6XQoVww2niye0MmVLwNJP5LXnjYMlWqBGcfPiPv6pmtgSbeZTYA9cOC0nOshOmnq2ZcfPskq2v4H87vbmF2qoWyEDlHQpIg(8D9TbcW1YqLoqP4U0dye0gyWWUsoTkfWCYyiVSGZbfEA7)xfR68Azz3GGrqBY8wADoM(dZKbBaXCRSwVakhDdQ0bkv8)xLcyozmKxwW5Wd5P)WmzWgqm3kR1lGYr3GkDGsfv8EvaZNnKdmMx3sO6JOA9cOC0nOshOuCqcqNHwHByl806EDVkG5ZgYb7jLSJ7(2aJ4Qzw4N(cKVxfW8zd5GP6JOsEWcWrckPJtCVkG5ZgYbt1hrXEW3gyqFHkDGsXbjaDgAfUHTWtlXDPhGSRWJ6VxfW8zd5GP6JOyp4BdmOVqLoqP4GeGodTc3Ww4P19QaMpBihmvFefRhK9Tb2(vKHP8nkUl9OPljLX6bzFBGTFfzykFJ54KAtxaZjJH8YcohuO19QaMpBihmvFefZKX4adLlSG4U0dq2ZcfPskq2v4H87vbmF2qoyQ(iQKhm4ibnzgMs2ngAEdJf3LEaYojpKFVkG5ZgYbt1hr5LXn(B9TbYDNuowCx6bi7K80wAEzCtcsu)73Rcy(SHCWu9r0WNVRVnqaUwgQ0bkf3LEaJG2adg2vYP10LKYXAbmCKGazV99mMlGDVkG5ZgYbt1hr16fq5OBqLoqP4GeGodTc3Ww4PL4U0dye0gyWWUsoTkGz6Xj1MXEW3gyqFHkDGYmMfkFdk02)pq2v4PnftRcyMECsTzjpyb4ibL0XjYywO8nOWB()bYUcpV5)xfGS)qE6pmtgSbeZTYM3Wy4x1fuuX7vbmF2qoyQ(ikq2HPkY47vbmF2qoyQ(ikq2HA64GjUl9aK9SqrQKcKDfEALUaMtgd5LfCo806)hi7zHIujfi7k8q(9QaMpBihmvFe18ggd)QUG4GeGodTc3Ww4PL4U0dye0gyWWUsonq2ZcfPskq2v4H87vbmF2qoyQ(iQupHVnWaJ)41GkDGsXDPNpmtgSbeZTYA9cOC0nOshOmnq2vOnX91ymw)ZEADVUxfW8zdzBIp2OdKHJemYLjlUl9WTt3)(4ygKa0hdpRdGA9kyPTc3Ww2CbgAdm6ScKEAWm94KAZGeG(y4zDauRxblJzHY3ajpTUxfW8zdzBIQ(iQn6az4ibJCzYI7spjHBNU)9XXmibOpgEwha16vWsZTt3)(4yoIDnTUVnqFv(nX0wHBylBUadTbgDwbspTkwHBylBUadTb(bmyBVRWtR2E))3kCdBzZfyOnWpGbB7DssofVxfW8zdzBIQ(iQn6az4ibJCzYI7spjHBNU)9XXmibOpgEwha16vWsNeUD6(3hhZrSRP19Tb6RYVjM2kCdBzZfyOnWOZkq6uIs3KhmLGWfuhuJAuka]] )

end