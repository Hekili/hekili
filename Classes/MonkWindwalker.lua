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
    
    spec:RegisterPack( "Windwalker", 20200223, [[dKejpbqirepskHnjs9jevPQrrcDksIxrsAweQULis7su)IqAyQs5ysPwgI0ZernnvPQRrsvBtkj(MusPXjLKohIQADKurMhI4EQI9rcoijvQfss5HKuHjIOk4IKurTrsQKrIOkLtkLu0kvL8sPKcUPusH2jHYqruLklfrv0tryQeIRIOk5RiQcTxK(lObd5WswmP6XatwOlJAZe5ZsXOjQtt1QLsQEnjA2s1Tjy3k9Bfdxv54sjA5q9CbtNY1jLTJO8DrY4ru58IW6vLkZxv1(vzABQiuIyzmvmsFJ03EJusto)g53o52TPewIpMs8vaLvdtj2sGPeKh9nMQ6kzmL4Rs0NksfHsegnmGPeYM9fuNev0g3K10ZGrq0GlO1lZNfGljt0GlaeLsOR5DR1CP6uIyzmvmsFJ03EJusto)g53o53Afkr4JbuXiTviFkHShJ8s1PeroaOeT4qKh9nMQ6kz8HAnoRY7vloKSzFb1jrfTXnzn9myeen4cA9Y8zb4sYen4carVxT4qQlwhRv4ehIusf)qK(gPVDVUxT4qQd5AB4G609QfhkPhI8KfgY4dr8Xf(qK3QnEicd7k5dbMnA(SHdPOCTXohpKEIdvX4SQKVxT4qj9qKNSWqgFi1frRHdHzWiiWBSmF2dPykV3pKodgb(q1H(WSKk57vlouspK6qU2g(qwHByd6shYMdbsa6m0kCdBH89QfhkPhI8KfgY4dXlJBsCiq9DiGmduEiPbFi1LhSWHgPdPU0WjoKIbx4qrxsIX8c4d5HdTCt3BC9ol(H01Sd91Rehk6ssmMxaFipCOG3SUKdQ1ujFVAXHs6Hu3Xihpe5vGpuRPXcHdPOH9vjBbXpeBGSkzkr3dwGkcLWMiveQyTPIqj4T07CKQgLaGDJXErj4wQ5FFCmdsa6JHN1bq9EfSdL(qwHBylBUadTbgD(qkCiY)qPpeyMECsTzqcqFm8SoaQ3RGLXSq5B4qK8CO2uIcy(SucB0aYWrcg5YKPgvmsPIqj4T07CKQgLaGDJXErjsYH4wQ5FFCmdsa6JHN1bq9EfSdL(qCl18VpoMJyxxV7Bd0xLFt8qPpKv4g2YMlWqBGrNpKchI8pu6dP4HSc3Ww2CbgAd8dyWKF7qk8CO2j)2H()pKv4g2YMlWqBGFadM8BhIKd1QhsfkrbmFwkHnAaz4ibJCzYuJkwYurOe8w6DosvJsaWUXyVOej5qCl18VpoMbja9XWZ6aOEVc2HsFOKCiULA(3hhZrSRR39Tb6RYVjEO0hYkCdBzZfyOnWOZhsHdr(uIcy(SucB0aYWrcg5YKPg1OeGiveQyTPIqjkG5Zsj8LSrjdjNgVucEl9ohPQrnQyKsfHsWBP35ivnkba7gJ9IsyfUHTS5cm0gy05dPWHA3QQ)q))hsXdLKdXTuZ)(4yoIDD9UVnqFv(nXd9)FiULA(3hhZGeG(y4zDauVxb7q))hYkCdBzzU6MC(dyhIKdL8BhsLdL(qGz6Xj1MTrdidhjyKltoJzHY3WHi55qTF)H()pe3sn)7JJ5i2117(2a9v53epu6dzfUHTS5cm0g4hWGj)2Hi5qK(2H()pKv4g2YMlWqBGrNpejhkz1tjkG5ZsjA0kC0RfosW6DmEmzQrflzQiucEl9ohPQrjay3ySxucWm94KAZ2ObKHJemYLjNXSq5B4qkCi13Qh6))qGz6Xj1MTrdidhjyKltoJzHY3WHi5qKEO))dzfUHTS5cm0gy05drYHi9nkrbmFwkrQb3JKX(cXCy2Abm1OI9EQiuIcy(Suc9(mrOKgobLG3sVZrQAuJkM6PIqjkG5Zsj0zCGXk9THsWBP35ivnQrfRvOIqj4T07CKQgLaGDJXErjaYEwOi3Hs6HaY(Hu45qTpu6dXlJBsKnxGH2afkYDifEo0Bz1tjkG5ZsjkmOwgAdgZRrnQyTwQiuIcy(SuIU3iBbyRRfBe41Oe8w6DosvJAuXAvQiuIcy(Suc9Qbosqd7aLbkbVLENJu1OgvmYNkcLG3sVZrQAuIcy(Sucq17Wcy(SWUhmkr3dgClbMsytKAuXA)gvekbVLENJu1OeaSBm2lkbyMECsT5GnybixytgwBek5yodKlCdho0ZHi9q))hsXdLKdXHaVaoNAW9izSVqmhMTwaNfQwFWh6))qkEiDnjPCQb3JKX(cXCy2AbCw77q))hcmtpoP2CQb3JKX(cXCy2AbCgZcLVHdPWHaZ0JtQnhSbla5cBYWAJqjhZzjTEhIzGCHByO5c8Hu5qQCO0hsXdbMPhNuB2gnGmCKGrUm5mMfkFdhsHdbMPhNuBoydwaYf2KH1gHsoMZsA9oeZa5c3WqZf4d9)FiWm94KAZ2ObKHJemYLjNXSq5B4qkCiRWnSLnxGH2aJoFivou6dbMPhNuBwYdwaosqjnCImMfkFdhIKNdr(hk9HaY(Hu45qjFO0hcmtpoP2Ckzh39TbgXvZSWpTfiNXSq5B4qK8CO2jFO))dfhlBJgqgosWixMCgZcLVHd9)FiZfyOnWOZhIKdr6BuIcy(SuIGnybixytgwBek5yMAuXA3MkcLG3sVZrQAuca2ng7fLiow2gnGmCKGrUm5mMfkFdh6))qwHBylBUadTbgD(qKCO2KsjkG5Zsj07ZeHJe0KziVSqcQrfRnPurOe8w6DosvJsaWUXyVOeCl18VpoMbja9XWZ6aOEVc2HsFiWm94KAZGeG(y4zDauVxblJzHY3WHu45qK(2H()pusoe3sn)7JJzqcqFm8SoaQ3RGrjkG5Zsj0cm0nwiqnQyTtMkcLG3sVZrQAuca2ng7fLiow2gnGmCKGrUm5mMfkFdh6))qwHBylBUadTbgD(qKCO2TcLOaMplLOwahmC1HGQ3PgvS2VNkcLG3sVZrQAuca2ng7fLiow2gnGmCKGrUm5mMfkFdh6))qwHBylBUadTbgD(qKCiYNsuaZNLsi5ywVptKAuXAREQiucEl9ohPQrjay3ySxuIKCO4yzWSaEnCzCek1lbgQRH3mMfkFdhk9Hu8qGz6Xj1MbZc41WLXrOuVe4mMfkFdhIKNdbMPhNuB2gnGmCKGrUm5mMfkFdhk9Hu8qw151YPKDC33gyexnZc)0wGCM3sVZXdL(qGz6Xj1Mtj74UVnWiUAMf(PTa5mMfkFdhsLdL(qGz6Xj1MXEW3gyqBHkDGYmMfkFdhk9HaZ0JtQnl5blahjOKgorgZcLVHdL(q6Ass5GnybixytgwBek5yohNu7H()puCSSnAaz4ibJCzYzmlu(goKkh6))qMlWqBGrNpejhQvPefW8zPeGzb8A4Y4iuQxcm1OI1UvOIqj4T07CKQgLaGDJXErjmxGH2aJoFifou7wn5d9)FO4yzB0aYWrcg5YKZywO8nCO))dzUadTbgD(qKCO2jtjkG5Zsj0zCGXk9THAuXA3APIqj4T07CKQgLOaMplL4Bakzl4VJJqWi8PzL5ZcJmzoGPeaSBm2lkrCSSnAaz4ibJCzYzmlu(gOeBjWuIVbOKTG)oocbJWNMvMplmYK5aMAuXA3QurOe8w6DosvJsuaZNLsubzYQLdqC9UbdbdU6uca2ng7fLGSc7LENZGbxDyC007m0MiCwOwGpu6dbMPhNuB2gnGmCKGrUm5mMfkFdhsHNdrAYhk9Hu8qrwxtskJR3nyiyWvhgzDnjPCCsTh6))q6Ass5GnybixytgwBek5yoJzHY3WHu4qTt(q))hYCbgAdm68Hs6HaZ0JtQnBJgqgosWixMCgZcLVHdrYHE)Bhk9HaZ0JtQnBJgqgosWixMCgZcLVHdrYHin5d9)FiZfyOnWOZhIKdrQ6pKkuITeykrfKjRwoaX17gmem4QtnQyTjFQiucEl9ohPQrjkG5ZsjQGmz1YbiUE3GHGbxDkba7gJ9IsKKdrwH9sVZzWGRomoA6DgAteolulWhk9Hu8qrwxtskJR3nyiyWvhgzDnjPCCsTh6))qkEOKCiULA(3hhZrSRR39Tb6RYVjEO))dzfUHTS5cm0g4hWGj)2Hi5qT6Hu5qPpKIhkow2gnGmCKGrUm5mMfkFdh6))qGz6Xj1MTrdidhjyKltoJzHY3WHu9qK)Hu4qwHBylBUadTbgD(qPpKUMKuoydwaYf2KH1gHsoMZAFh6))qMlWqBGrNpejhIu1FivoKkuITeykrfKjRwoaX17gmem4QtnQyK(gvekrbmFwkHjZqTvF02iuAWaMsWBP35ivnQrfJ02urOefW8zPeFAyxkHVnq9EfmkbVLENJu1OgvmsjLkcLOaMplLaZ1NVnqPEjWbkbVLENJu1OgvmstMkcLOaMplLqAaAbocR3Xy3yOoxcucEl9ohPQrnQyK(EQiucEl9ohPQrjay3ySxucWm94KAZyp4BdmOTqLoqzgZcLVHdrYZHi9q))hYCbgAdm68Hi55qTjLsuaZNLseymVULGAuXiv9urOe8w6DosvJsaWUXyVOe8Y4MehIKd9(3ou6dPRjjLd2GfGCHnzyTrOKJ5S2hLOaMplLqGfgCc4ib7AapcJyUecuJkgPTcvekrbmFwkb2)(6m0xy4RamLG3sVZrQAuJkgPTwQiuIcy(SucTadDJfcucEl9ohPQrnQrj(Wmye0lJkcvS2urOefW8zPeFJ5Zsj4T07CKQg1OIrkvekbVLENJu1OeZhLiWgLOaMplLGSc7LENPeKvDnMsWTuZ)(4yUcYKvlhG46DdgcgC1pu6dP4H4wQ5FFCmdsa6JHN1bq9EfSd9)FiULA(3hhZDTGHhTaSz6rEHFDnHQHp0))H4wQ5FFCm30ROx2Gdq9k2Wh6))qCl18VpoMB6v0lBWbOahRE3N9q))hIBPM)9XXmMfgJHnAESwadJmzoGpKkucYkmClbMsagC1HXrtVZqBIWzHAbMAuXsMkcLG3sVZrQAuca2ng7fLqXdLKdzvNxlhymVULiZBP354H()pusoKvDETSKhm4ibnzgMs2ngAEdJZ8w6DoEivOefW8zPeazhQRHdg1OI9EQiucEl9ohPQrjay3ySxucR68AzjpyWrcAYmmLSBm08ggN5T07CKsuaZNLsaKDyQImMAuXupvekrbmFwkHVKnkzi504LsWBP35ivnQrfRvOIqjkG5ZsjA0kC0RfosW6DmEmzkbVLENJu1Og1Oe1WurOI1MkcLG3sVZrQAuIcy(SucSh8Tbg0wOshOKsaWUXyVOekEiR68A5uYoU7BdmIRMzHFAlqoZBP354HsFiWm94KAZPKDC33gyexnZc)0wGCgZcLVHdrYHu)Hu5qPpeyMECsTzjpyb4ibL0WjYywO8nCifouYucqcqNHwHBylqfRn1OIrkvekrbmFwkrkzh39TbgXvZSWpTfitj4T07CKQg1OILmvekbVLENJu1OeaSBm2lkrso0hMjd2aI52zZBym8R6chk9HaY(Hi55qTpu6dXlJBsCisoK6FJsuaZNLsWlJB835BdK7o5Cm1OI9EQiuIcy(Sucjpyb4ibL0WjOe8w6DosvJAuXupvekbVLENJu1OeaSBm2lkHUMKugRfK9Tb26vKHP8nMJtQLsuaZNLsG1cY(2aB9kYWu(gPgvSwHkcLG3sVZrQAuca2ng7fLamc6dmyyxjFO0hsXdP4Hu8qaz)qkCOKp0))HaZ0JtQnl5blahjOKgorgZcLVHdPWHALdPYHsFifpeq2pKcphs9h6))qGz6Xj1ML8GfGJeusdNiJzHY3WHu4qKEivoKkh6))q8Y4MezZfyOnqHIChIKNdL8HuHsuaZNLse(8D9TbcW1YqLoqj1OI1APIqj4T07CKQgLaGDJXErjaYEwOi3Hs6HaY(Hu45qKsjkG5ZsjWmzmoWq5clqnQyTkvekbVLENJu1OeaSBm2lkbq2pejphkzkrbmFwkbq2H6A4GrnQyKpvekbVLENJu1OeaSBm2lkbq2Zcf5ouspeq2pKcphkzkrbmFwkHKhm4ibnzgMs2ngAEdJPgvS2VrfHsWBP35ivnkrbmFwkH5nmg(vDbkba7gJ9IsaK9SqrUdL0dbK9dPWZHi9qPpKIhkjhYQoVww2niye0NmVLENJh6))qj5qGrqFG6yUuEivOeGeGodTc3WwGkwBQrfRDBQiucEl9ohPQrjay3ySxuIKCiWiOpqDmxkPefW8zPeazhMQiJPgvS2KsfHsWBP35ivnkrbmFwkHEVakhndQ0bkPeaSBm2lkbye0hyWWUs(qPpKIhsxtskRpkHF4bK1(o0))Hu8qw151YYUbbJG(K5T07C8qPp0hMjd2aI52zZBym8R6chk9HaY(Hi5qV)qQCivOeGeGodTc3WwGkwBQrnkrGX86wcQiuXAtfHsWBP35ivnkrbmFwkb2d(2adAluPdusjay3ySxuIcyozmKxwW5WHi5qjFO))d9HzYGnGyUDo8576BdeGRLHkDGskbibOZqRWnSfOI1MAuXiLkcLG3sVZrQAuca2ng7fLqXdPRjjL17Ze7AblR9DO0h6dZKbBaXC7m2d(2adAluPduEivo0))H01KKYbgZRBjYywO8nCisou7d9)FifpubmNmgYll4C4qkCO2hk9HkG5KXqEzbNdhIKdP(dPcLOaMplLqYdwaosqjnCcQrflzQiucEl9ohPQrjay3ySxucR68Azz3GGrqFY8w6DoEO0hIxg3KiBUadTbkuK7qKCispu6d9HzYGnGyUDwVxaLJMbv6aLhk9HaY(Hi55qKsjkG5ZsjK8GbhjOjZWuYUXqZBym1OI9EQiucEl9ohPQrjay3ySxucR68Azz3GGrqFY8w6DoEO0hIxg3KiBUadTbkuK7qKCO2hk9H(WmzWgqm3oR3lGYrZGkDGYdL(qazpluK7qj9qaz)qk8CisPefW8zPeM3Wy4x1fOgvm1tfHsWBP35ivnkba7gJ9Isagb9bgmSRKpu6dP4HkG5KXqEzbNdhsHNdL8H()pKIhYQoVww2niye0NmVLENJhk9H(WmzWgqm3oR3lGYrZGkDGYdPYH()pKIhQaMtgd5LfCoCONdr6HsFOpmtgSbeZTZ69cOC0mOshO8qQCivOefW8zPeHpFxFBGaCTmuPdusnQyTcvekbVLENJu1OefW8zPe69cOC0mOshOKsasa6m0kCdBbQyTPg1OebJkcvS2urOefW8zPePKDC33gyexnZc)0wGmLG3sVZrQAuJkgPurOefW8zPesEWcWrckPHtqj4T07CKQg1OILmvekbVLENJu1OefW8zPeyp4BdmOTqLoqjLaGDJXErjaY(Hu45qQNsasa6m0kCdBbQyTPgvS3tfHsWBP35ivnkrbmFwkb2d(2adAluPdusjajaDgAfUHTavS2uJkM6PIqj4T07CKQgLaGDJXErj01KKYyTGSVnWwVImmLVXCCsThk9HkG5KXqEzbNdhsHd1MsuaZNLsG1cY(2aB9kYWu(gPgvSwHkcLG3sVZrQAuca2ng7fLai7zHIChkPhci7hsHNdrkLOaMplLaZKX4adLlSa1OI1APIqj4T07CKQgLaGDJXErjaY(Hi55qKsjkG5ZsjK8GbhjOjZWuYUXqZBym1OI1QurOe8w6DosvJsaWUXyVOeaz)qK8COKpu6dXlJBsCisoK6FJsuaZNLsWlJB835BdK7o5Cm1OIr(urOe8w6DosvJsaWUXyVOeGrqFGbd7k5dL(q6Ass5yTagosqGS36EgZfWOefW8zPeHpFxFBGaCTmuPdusnQyTFJkcLG3sVZrQAuIcy(Suc9EbuoAguPdusjay3ySxucWiOpWGHDL8HsFifpeyMECsTzSh8Tbg0wOshOmJzHY3WHu4qjFO))dbK9dPWZHs(qQCO0hsXdbMPhNuBwYdwaosqjnCImMfkFdhsHd9(d9)FiGSFifEo07p0))Hu8qaz)qphI0dL(qFyMmydiMBNnVHXWVQlCivoKkucqcqNHwHBylqfRn1OI1UnvekrbmFwkbq2HPkYykbVLENJu1OgvS2KsfHsWBP35ivnkba7gJ9IsaK9SqrUdL0dbK9dPWZHAFO0hQaMtgd5LfCoCONd1(q))hci7zHIChkPhci7hsHNdrkLOaMplLai7qDnCWOgvS2jtfHsWBP35ivnkrbmFwkH5nmg(vDbkba7gJ9Isagb9bgmSRKpu6dbK9SqrUdL0dbK9dPWZHiLsasa6m0kCdBbQyTPgvS2VNkcLG3sVZrQAuIcy(SucPEcFBGbg)XRbv6aLuca2ng7fL4dZKbBaXC7SEVakhndQ0bkpu6dbK9dPWHsMs4RXyS2NrjAtnQrjISuP1nQiuXAtfHsuaZNLse(4cdLRncdg2vYucEl9ohPQrnQyKsfHs4RXyYQoLG8FJs8bmOmxDtMs8ww9uIcy(SucB0aYWrcQSWcfLG3sVZrQAuJkwYurOe8w6DosvJsaWUXyVOe6Ass5aJ51TezTVd9)FO4yzB0aYWrcg5YKZywO8nCO))dLKdzvNxlhymVULiZBP354HsFid7Rs2YF4bKRgV7wImMlGDO))dPRjjL17Ze7AblJ5cyh6))qMlWqBGrNpejphQvEJsuaZNLs8nMpl1OI9EQiucEl9ohPQrjay3ySxucDnjPCGX86wIS2hLOaMplLau9oSaMplS7bJs09Gb3sGPebgZRBjOgvm1tfHsWBP35ivnkba7gJ9IsO4H4LXnjYMlWqBGcf5oejhQ9H()pKIhYQoVwoWyEDlrM3sVZXdL(qGz6Xj1MdmMx3sKXSq5B4qKCispKkhsLdL(qazpluK7qj9qaz)qk8CisPefW8zPeyMmghyOCHfOgvSwHkcLG3sVZrQAuca2ng7fLqXdXlJBsKnxGH2afkYDisou7d9)FifpKvDETCGX86wImVLENJhk9HaZ0JtQnhymVULiJzHY3WHi5qKEivo0))Hu8q8Y4MezZfyOnqHIChIKd9(dL(qGz6Xj1ML8GfGJeusdNiJzHY3WHi5qTZQ)qQCivou6dbK9SqrUdL0dbK9dPWZHsMsuaZNLsi5bdosqtMHPKDJHM3WyQrfR1sfHsWBP35ivnkrbmFwkH5nmg(vDbkba7gJ9IsKKdbgb9bQJ5s5HsFifpeVmUjr2CbgAduOi3Hi5qTp0))Hu8qw151YbgZRBjY8w6DoEO0hcmtpoP2CGX86wImMfkFdhIKdr6Hu5q))hsXdXlJBsKnxGH2afkYDiso07pu6dbMPhNuBwYdwaosqjnCImMfkFdhIKd1oR(dPYHu5qPpeq2Zcf5ouspeq2pKcphI0dL(qj5qXXY2ObKHJemYLjNXSq5BGsasa6m0kCdBbQyTPgvSwLkcLG3sVZrQAuca2ng7fLijhYQoVwwYdgCKGMmdtj7gdnVHXzEl9ohpu6dzUaFisEouYuIcy(SucGSdtvKXuJkg5tfHsWBP35ivnkrbmFwkbO6DybmFwy3dgLO7bdULatjarQrfR9BurOe8w6DosvJsaWUXyVOefWCYyiVSGZHdrYHsMsuaZNLsaQEhwaZNf29Grj6EWGBjWuIGrnQyTBtfHsWBP35ivnkba7gJ9IsuaZjJH8YcohoKcphkzkrbmFwkbO6DybmFwy3dgLO7bdULatjQHPg1OgLGmgh8zPIr6BK(2BTj99uIufE9TjqjAnf(gSXXd1ApubmF2d19GfY3lkXhEK8otjAXHip6Bmv1vY4d1ACwL3RwCizZ(cQtIkAJBYA6zWiiAWf06L5ZcWLKjAWfaIEVAXHuxSowRWjoePKk(Hi9nsF7EDVAXHuhY12Wb1P7vlouspe5jlmKXhI4Jl8HiVvB8qeg2vYhcmB08zdhsr5AJDoEi9ehQIXzvjFVAXHs6HipzHHm(qQlIwdhcZGrqG3yz(ShsXuEVFiDgmc8HQd9HzjvY3RwCOKEi1HCTn8HSc3Wg0LoKnhcKa0zOv4g2c57vlouspe5jlmKXhIxg3K4qG67qazgO8qsd(qQlpyHdnshsDPHtCifdUWHIUKeJ5fWhYdhA5MU346Dw8dPRzh6Rxjou0LKymVa(qE4qbVzDjhuRPs(E1IdL0dPUJroEiYRaFOwtJfchsrd7Rs2cIFi2azvY3R7vloK6m5yGMXXdPZsdMpeye0l7q6CJVH8Hu3aa)zHdTZMu5cliP1pubmF2WHMTNiFVAXHkG5ZgYFygmc6L9i1RGY7vloubmF2q(dZGrqVmvFevAM49QfhQaMpBi)HzWiOxMQpIwAnc8AL5ZEVAXHi26lip2HWLhpKUMKehpuWklCiDwAW8HaJGEzhsNB8nCOAJh6dZj9BmZ3Md5HdfNLZ3RwCOcy(SH8hMbJGEzQ(iAyRVG8yWGvw4EvaZNnK)Wmye0lt1hr)gZN9EvaZNnK)Wmye0lt1hrjRWEP3zX3sGFadU6W4OP3zOnr4SqTal(89eytCYQUg)WTuZ)(4yUcYKvlhG46DdgcgC1tRi3sn)7JJzqcqFm8SoaQ3RG9)ZTuZ)(4yURfm8OfGntpYl8RRjun8)p3sn)7JJ5MEf9YgCaQxXg()NBPM)9XXCtVIEzdoaf4y17(S))Cl18VpoMXSWymSrZJ1cyyKjZbSk3Rcy(SH8hMbJGEzQ(ikq2H6A4GjUl9OysSQZRLdmMx3sK5T07C8)pjw151YsEWGJe0Kzykz3yO5nmoZBP35Ok3Rcy(SH8hMbJGEzQ(ikq2HPkYyXDPhR68AzjpyWrcAYmmLSBm08ggN5T07C8EvaZNnK)Wmye0lt1hr9LSrjdjNgVqtMHPKDJHM3W47vbmF2q(dZGrqVmvFeTrRWrVw4ibR3X4XKVx3RwCi1zYXanJJhIjJXjoK5c8Hmz(qfWg8H8WHkYkVx6DoFVAXHkG5ZgEknBGLzfq59QaMpBq1hrdFCHHY1gHbd7k57vbmF2GQpIAJgqgosqLfwOe3xJXKv9hY)nX)aguMRUj)8ww93RwCiY7gZN9qU0HiymVUL4qd(qe2Gfe)qQZf2Kf)q1gpK6YX8HkmFiTVdn4dLy0ouH5dH1213MdfymVUL4q1gpuDiHY3dfSYoKH9vjBh6dpGG4hAWhkXODOcZhsBJm(qMmFiwsIb2HgPdP3Nj21cM4hAWhYkCdBhYCb(q2COOZhYdhQbZLX4dn4dXTuR6hYMd1kVDVkG5Zgu9r0VX8zf3LE01KKYbgZRBjYAF))XXY2ObKHJemYLjNXSq5B4)pjw151YbgZRBjY8w6DoM2W(QKT8hEa5QX7ULiJ5cy))6Assz9(mXUwWYyUa2)V5cm0gy0zsEAL3UxfW8zdQ(ikO6DybmFwy3dM4BjWpbgZRBje3LE01KKYbgZRBjYAF3Rcy(SbvFefZKX4adLlSG4U0JI8Y4MezZfyOnqHICK0()xrR68A5aJ51TezEl9ohtdMPhNuBoWyEDlrgZcLVbsivfvsdK9SqrUKcKDfEi9EvaZNnO6JOsEWGJe0Kzykz3yO5nmwCx6rrEzCtIS5cm0gOqrosA))ROvDETCGX86wImVLENJPbZ0JtQnhymVULiJzHY3ajKQY)VI8Y4MezZfyOnqHICK8(0Gz6Xj1ML8GfGJeusdNiJzHY3ajTZQxfvsdK9SqrUKcKDfEs(EvaZNnO6JOM3Wy4x1fehKa0zOv4g2cpTf3LEscye0hOoMlLPvKxg3KiBUadTbkuKJK2))kAvNxlhymVULiZBP35yAWm94KAZbgZRBjYywO8nqcPQ8)RiVmUjr2CbgAduOihjVpnyMECsTzjpyb4ibL0WjYywO8nqs7S6vrL0azpluKlPazxHhstNK4yzB0aYWrcg5YKZywO8nCVkG5Zgu9ruGSdtvKXI7spjXQoVwwYdgCKGMmdtj7gdnVHXzEl9ohtBUatYtY3Rcy(SbvFefu9oSaMplS7bt8Te4hq8E1IdPoQE)qMmFicroubmF2d19GDix6qMmJ5dvy(qKEObFOohchIxwW5W9QaMpBq1hrbvVdlG5Zc7EWeFlb(jyI7spfWCYyiVSGZbss(E1IdPoQE)qMmFi19OoFOcy(ShQ7b7qU0HmzgZhQW8Hs(qd(qcdMpeVSGZH7vbmF2GQpIcQEhwaZNf29Gj(wc8tnS4U0tbmNmgYll4CqHNKVx3RwCi1nW8zdz19OoFipCiFnEJC8qsd(qAb(qPCt(qK3yG5aO6ogHQJoxKXhQ24HaAymVwpXHwMJHdzZH05dnFMl4VJJ3Rcy(SHCn8d2d(2adAluPdukoibOZqRWnSfEAlUl9OOvDETCkzh39TbgXvZSWpTfiN5T07CmnyMECsT5uYoU7BdmIRMzHFAlqoJzHY3ajQxL0Gz6Xj1ML8GfGJeusdNiJzHY3GcjFVkG5ZgY1WQ(iAkzh39TbgXvZSWpTfiFVkG5ZgY1WQ(ikVmUXFNVnqU7KZXI7spj5dZKbBaXC7S5nmg(vDH0azNKN2P5LXnjir9VDVkG5ZgY1WQ(iQKhSaCKGsA4e3Rcy(SHCnSQpII1cY(2aB9kYWu(gf3LE01KKYyTGSVnWwVImmLVXCCsT3Rcy(SHCnSQpIg(8D9TbcW1YqLoqP4U0dye0hyWWUsoTIkQiq2vi5)FWm94KAZsEWcWrckPHtKXSq5BqHwrL0kcKDfEu))pyMECsTzjpyb4ibL0WjYywO8nOaPQOY)pVmUjr2CbgAduOihjpjRY9QaMpBixdR6JOyMmghyOCHfe3LEaYEwOixsbYUcpKEVkG5ZgY1WQ(ikq2H6A4GjUl9aKDsEs(EvaZNnKRHv9rujpyWrcAYmmLSBm08gglUl9aK9SqrUKcKDfEs(EvaZNnKRHv9ruZBym8R6cIdsa6m0kCdBHN2I7spazpluKlPazxHhstRysSQZRLLDdcgb9jZBP354)FsaJG(a1XCPuL7vbmF2qUgw1hrbYomvrglUl9KeWiOpqDmxkVxT4qfW8zd5AyvFevQNW3gyGXF8AqLoqP4U0JUMKuwFuc)WdihNuR4(AmgR9zpTVxfW8zd5AyvFevVxaLJMbv6aLIdsa6m0kCdBHN2I7spGrqFGbd7k50kQRjjL1hLWp8aYAF))kAvNxll7gemc6tM3sVZX0FyMmydiMBNnVHXWVQlKgi7K8Evu5EDVAXHuhZ0JtQnCVkG5ZgYG4JVKnkzi504fAYmmLSBm08ggFVkG5ZgYGOQpI2Ov4OxlCKG17y8yYI7spwHBylBUadTbgDwH2TQ6))vmjCl18VpoMJyxxV7Bd0xLFt8)NBPM)9XXmibOpgEwha17vW()Tc3WwwMRUjN)agjj)MkPbZ0JtQnBJgqgosWixMCgZcLVbsEA)()FULA(3hhZrSRR39Tb6RYVjM2kCdBzZfyOnWpGbt(nsi9T)FRWnSLnxGH2aJotsYQ)EvaZNnKbrvFen1G7rYyFHyomBTawCx6bmtpoP2SnAaz4ibJCzYzmlu(guq9T6)pyMECsTzB0aYWrcg5YKZywO8nqcP))wHBylBUadTbgDMesF7EvaZNnKbrvFevVptekPHtCVkG5ZgYGOQpIQZ4aJv6BZ9QfhI8kWhsDJb1YhsKbJ51oKlDOeJ2HkmFibpe8T5qLDOoxb7qTpK6q2puTXdLAwY7TdbQVdXlJBsCOuUj77HElR(dfyWSXW9QaMpBidIQ(iAHb1YqBWyEnXDPhGSNfkYLuGSRWt708Y4MezZfyOnqHICk88ww93Rcy(SHmiQ6JODVr2cWwxl2iWRDVkG5ZgYGOQpIQxnWrcAyhOmCVkG5ZgYGOQpIcQEhwaZNf29Gj(wc8JnX7vbmF2qgev9r0GnybixytgwBek5ywCXDPhWm94KAZbBWcqUWMmS2iuYXCgix4go8q6)VIjHdbEbCo1G7rYyFHyomBTaoluT(G))vuxtskNAW9izSVqmhMTwaN1(()bZ0JtQnNAW9izSVqmhMTwaNXSq5BqbWm94KAZbBWcqUWMmS2iuYXCwsR3Hygix4ggAUaRIkPvemtpoP2SnAaz4ibJCzYzmlu(guamtpoP2CWgSaKlSjdRncLCmNL06DiMbYfUHHMlW))Gz6Xj1MTrdidhjyKltoJzHY3GcwHBylBUadTbgDwL0Gz6Xj1ML8GfGJeusdNiJzHY3ajpKFAGSRWtYPbZ0JtQnNs2XDFBGrC1ml8tBbYzmlu(gi5PDY))XXY2ObKHJemYLjNXSq5B4)3CbgAdm6mjK(29QaMpBidIQ(iQEFMiCKGMmd5LfsiUl9ehlBJgqgosWixMCgZcLVH)FRWnSLnxGH2aJotsBsVxfW8zdzqu1hr1cm0nwiiUl9WTuZ)(4ygKa0hdpRdG69kyPbZ0JtQndsa6JHN1bq9EfSmMfkFdk8q6B))jHBPM)9XXmibOpgEwha17vWUxT4qKxb(qQ7fWbdx9dPoQE)qrnSVnhsKrdiFOr6qKh4YKVxfW8zdzqu1hrRfWbdxDiO6DXDPN4yzB0aYWrcg5YKZywO8n8)BfUHTS5cm0gy0zsA3k3RwCiYRaFi1LJz9(mXdf1W(2CirgnG8HgPdrEGlt(EvaZNnKbrvFevYXSEFMO4U0tCSSnAaz4ibJCzYzmlu(g()Tc3Ww2CbgAdm6mjK)9QaMpBidIQ(ikywaVgUmocL6LalUl9KK4yzWSaEnCzCek1lbgQRH3mMfkFdPvemtpoP2mywaVgUmocL6LaNXSq5BGKhWm94KAZ2ObKHJemYLjNXSq5BiTIw151YPKDC33gyexnZc)0wGCM3sVZX0Gz6Xj1Mtj74UVnWiUAMf(PTa5mMfkFdQKgmtpoP2m2d(2adAluPduMXSq5BinyMECsTzjpyb4ibL0WjYywO8nKwxtskhSbla5cBYWAJqjhZ54KA))JJLTrdidhjyKltoJzHY3Gk))MlWqBGrNjPvVxT4qKxb(qQX4aJv6BZHIAyFBoKiJgq(qJ0HipWLjFVkG5ZgYGOQpIQZ4aJv6BJ4U0J5cm0gy0zfA3Qj))hhlBJgqgosWixMCgZcLVH)FZfyOnWOZK0o57vbmF2qgev9ruTadDJfeFlb(5Bakzl4VJJqWi8PzL5ZcJmzoGf3LEIJLTrdidhjyKltoJzHY3W9QaMpBidIQ(iQwGHUXcIVLa)ubzYQLdqC9UbdbdU6I7spKvyV07Cgm4QdJJMENH2eHZc1cCAWm94KAZ2ObKHJemYLjNXSq5BqHhstoTIrwxtskJR3nyiyWvhgzDnjPCCsT))6Ass5GnybixytgwBek5yoJzHY3GcTt()3CbgAdm6CsbZ0JtQnBJgqgosWixMCgZcLVbsE)BPbZ0JtQnBJgqgosWixMCgZcLVbsin5)FZfyOnWOZKqQ6v5EvaZNnKbrvFevlWq3ybX3sGFQGmz1YbiUE3GHGbxDXDPNKqwH9sVZzWGRomoA6DgAteolulWPvmY6AsszC9UbdbdU6WiRRjjLJtQ9)xXKWTuZ)(4yoIDD9UVnqFv(nX)FRWnSLnxGH2a)agm53iPvvjTIXXY2ObKHJemYLjNXSq5B4)hmtpoP2SnAaz4ibJCzYzmlu(guL8vWkCdBzZfyOnWOZP11KKYbBWcqUWMmS2iuYXCw77)3CbgAdm6mjKQEvu5EvaZNnKbrvFe1KzO2QpABeknyaFVkG5ZgYGOQpI(PHDPe(2a17vWUxfW8zdzqu1hrXC95BduQxcC4EvaZNnKbrvFevAaAbocR3Xy3yOoxc3Rcy(SHmiQ6JObgZRBje3LEaZ0JtQnJ9GVnWG2cv6aLzmlu(gi5H0)FZfyOnWOZK80M07vbmF2qgev9rubwyWjGJeSRb8imI5siiUl9WlJBsqY7FlTUMKuoydwaYf2KH1gHsoMZAF3Rcy(SHmiQ6JOy)7RZqFHHVcW3Rcy(SHmiQ6JOAbg6gleUx3RwCicgZRBjo0h2hSBjUxfW8zd5aJ51Tepyp4BdmOTqLoqP4GeGodTc3Ww4PT4U0tbmNmgYll4CGKK)))WmzWgqm3oh(8D9TbcW1YqLoq59QaMpBihymVULq1hrL8GfGJeusdNqCx6rrDnjPSEFMyxlyzTV0FyMmydiMBNXEW3gyqBHkDGsv()11KKYbgZRBjYywO8nqs7)FflG5KXqEzbNdk0oDbmNmgYll4CGe1RY9QaMpBihymVULq1hrL8GbhjOjZWuYUXqZByS4U0JvDETSSBqWiOpzEl9ohtZlJBsKnxGH2afkYrcPP)WmzWgqm3oR3lGYrZGkDGY0azNKhsVxfW8zd5aJ51TeQ(iQ5nmg(vDbXDPhR68Azz3GGrqFY8w6DoMMxg3KiBUadTbkuKJK2P)WmzWgqm3oR3lGYrZGkDGY0azpluKlPazxHhsVxfW8zd5aJ51TeQ(iA4Z313giaxldv6aLI7spGrqFGbd7k50kwaZjJH8Ycohu4j5)FfTQZRLLDdcgb9jZBP35y6pmtgSbeZTZ69cOC0mOshOuL)FflG5KXqEzbNdpKM(dZKbBaXC7SEVakhndQ0bkvrL7vbmF2qoWyEDlHQpIQ3lGYrZGkDGsXbjaDgAfUHTWt7719QaMpBihSNuYoU7BdmIRMzHFAlq(EvaZNnKdMQpIk5blahjOKgoX9QaMpBihmvFef7bFBGbTfQ0bkfhKa0zOv4g2cpTf3LEaYUcpQ)EvaZNnKdMQpII9GVnWG2cv6aLIdsa6m0kCdBHN23Rcy(SHCWu9ruSwq23gyRxrgMY3O4U0JUMKugRfK9Tb26vKHP8nMJtQnDbmNmgYll4CqH23Rcy(SHCWu9rumtgJdmuUWcI7spazpluKlPazxHhsVxfW8zd5GP6JOsEWGJe0Kzykz3yO5nmwCx6bi7K8q69QaMpBihmvFeLxg34VZ3gi3DY5yXDPhGStYtYP5LXnjir9VDVkG5ZgYbt1hrdF(U(2ab4AzOshOuCx6bmc6dmyyxjNwxtskhRfWWrccK9w3ZyUa29QaMpBihmvFevVxaLJMbv6aLIdsa6m0kCdBHN2I7spGrqFGbd7k50kcMPhNuBg7bFBGbTfQ0bkZywO8nOqY))azxHNKvjTIGz6Xj1ML8GfGJeusdNiJzHY3GcV))hi7k88()FfbY(dPP)WmzWgqm3oBEdJHFvxqfvUxfW8zd5GP6JOazhMQiJVxfW8zd5GP6JOazhQRHdM4U0dq2Zcf5skq2v4PD6cyozmKxwW5Wt7)FGSNfkYLuGSRWdP3Rcy(SHCWu9ruZBym8R6cIdsa6m0kCdBHN2I7spGrqFGbd7k50azpluKlPazxHhsVxfW8zd5GP6JOs9e(2adm(JxdQ0bkf3LE(WmzWgqm3oR3lGYrZGkDGY0azxHKf3xJXyTp7P996EvaZNnKTj(yJgqgosWixMS4U0d3sn)7JJzqcqFm8SoaQ3RGL2kCdBzZfyOnWOZkq(PbZ0JtQndsa6JHN1bq9EfSmMfkFdK80(EvaZNnKTjQ6JO2ObKHJemYLjlUl9KeULA(3hhZGeG(y4zDauVxbln3sn)7JJ5i2117(2a9v53etBfUHTS5cm0gy0zfi)0kAfUHTS5cm0g4hWGj)McpTt(T)FRWnSLnxGH2a)agm53iPvv5EvaZNnKTjQ6JO2ObKHJemYLjlUl9KeULA(3hhZGeG(y4zDauVxblDs4wQ5FFCmhXUUE33gOVk)MyARWnSLnxGH2aJoRa5tjkntEWuccxqDqnQrP]] )

end