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

            handler = function ()
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

            handler = function ()
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

            handler = function ()
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
    
    spec:RegisterPack( "Windwalker", 20191111, [[dWeJjbqiQQYJOQInrv5tGcPgfvOtrf8kufZcu1TqbTlP8lqLHHcCmuvldf1ZePAAGcUgvvABGc13afLghQs4CGISouLiZdf5EuL9Hs5GuvvAHOu9qqr1ePQQaxevjQnsvvvFKQQc1iPQQsNKQQkwPi5LGIIMjvvf0nPQQi7uQQFsvvHmuQQkQLckepvvMkO0vbfs(kOOWEb(lsdgQdlzXKQhRYKvvxMyZKYNfXOPsNMYQrvQEniMTOUnQSBf)gYWbPJJQKwoINtY0fUUuz7OqFxQY4fPCEuY6rvkZNkA)knGpawW7xHa6Zmd4dt85ZNFJpZPNUFzg8cwqfWdADqQeb8MItapyg287vzicb8GwSYO6dGf8uOoYjGNBeqv8sWbxIfUD6TdXbNY46YvyO5iLwaNY4o4ap9olh(pdqh8(viG(mZa(WeF(8534ZC6mGbmdEkOYb6ZmmgMapx7)LbOdEFrDGNFwmmdB(9QmeHSy)tObYMYpl2ncOkEj4GlXc3o92H4GtzCD5km0CKslGtzChCBk)S4(igfoDHSy(8HFXmZa(W0MAt5NfdZDRjru8sBk)SygUyyeHdXOS4huPil2)TM)IFbXGil(qZpm0OwSJU18ZYFX6SwC9)OXH2MYplMHlggr4qmkl2))GzUyICiooz(vyOzXo2ZY5fRlhItwCTyOerZH2MYplMHlgM7wtIS4OijsqnTfhOfFSUSqJIKiHQTP8ZIz4IHreoeJYILrijSw8vqx85khKfRHil2)BQqTyK2I9)Dewl2rLXT4VPPjezozXMAXJKKTetplWVy9UyXqZfRf)nnnHiZjl2ulwzjJPzxnHdTnLFwmdxS)9)L)IHrPKf7)ecNAXogeBGiHc(flX1CObEztfkaSG39bWc6Zhal4vxyOb8SHreeHMwNmGNmLEw(a2bbOpZaybV6cdnGxNsOwiCkWtMsplFa7Ga0pDaSGNmLEw(a2bVP4eWJXIyLEwO2eYOSGfnXskgr5GIuNLZvytcLi1fic4vxyOb8ySiwPNfQnHmklyrtSKIruoOi1z5Cf2KqjsDbIacqFyaal4vxyOb80Zi0NQ1rybEYu6z5dyheG((fal4vxyOb80fIsiqSjb8KP0ZYhWoia9HXaybpzk9S8bSdEhXcHyf4DUwJRsBXmCXNRTy28wm)f7BXYiKewTW4eAGOCvAlMnVfZGMFbV6cdnGxrUAeAGiezcqa6dZcGf8Qlm0aEzlXnuuEV7NWjtaEYu6z5dyheG(8caSGxDHHgWtZiIEgH(GNmLEw(a2bbOpmbGf8Qlm0aE1CIkivMEvodEYu6z5dyheG(8zaawWtMsplFa7GxDHHgW7QCMwxyOHMnvaEztf0P4eWlqFqa6ZNpawWtMsplFa7G3rSqiwbEhcL)OEttfichvks4sR5t1mI0o3IKiQf7TyMxStNl2XfFiu(J6nnntfkksJQ1ry1icxzJAXm5TyyAX(w85AlMnVfN(I9T4dHYFuVP1Z1izBsOFsLGgk0U5CBeHRSrTyM8wmFyyX(w8Hq5pQ30cu35srA0VuHBJiCLnQfZM3IHjgSyhwStNlomoHgi63KfZK3I573f705I)OOfOUZLI0OFPc3gr4kBuGxDHHgWtfichvks4sR5t1mIacqF(mdGf8KP0ZYhWo4DeleIvG3hfTdnNmbPc5t1YfNq17itJiCLnQfZK3Izg8Qlm0aEhAozcsfYNQLlobeG(8thal4vxyOb80Zi0NI0OHRqLr4ybEYu6z5dyheG(8HbaSGxDHHgWlCfA3OJ6Mpvdrob8KP0ZYhWoia957xaSGxDHHgWdAhX0yztcvpxQa8KP0ZYhWoia95dJbWcE1fgAapn01PKpT4nHyHq1LId8KP0ZYhWoia95dZcGf8KP0ZYhWo4nfNaEqrhejugVjF6H4G2fvyOH(fgTtaV6cdnGhu0brcLXBYNEioODrfgAOFHr7eW7iwieRaVpkAbQ7CPin6xQWTreUYgfia95ZlaWcEYu6z5dyh8MItaVs5YynIIskEdrOhIuzWRUWqd4vkxgRruusXBic9qKkdEhXcHyf454IDCXcV2zqHk)2X6YOGGg7O65sfl23Ipek)r9M2X6YOGGg7O65sfnIWv2OwmBElMzgSyhwStNl2Flw41odku53owxgfe0yhvpxQyXoSyFl2Xf)f9onTgP4neHEisLPFrVttR9r9Mf705IDCX(BXcV2zqHk)2Ny66zBsO2abk6VyNoxCuKejAHXj0arHEbnDgSyMwmVyXoSyFlwVttRPceHJkfjCP18PAgrAeHRSrTy2wm)0xStNlomoHgi63KfZ0IzM)IDaeG(8HjaSGNmLEw(a2bVJyHqSc8oek)r9MgXu2KqvDdfIDqAeHRSrTyM8wmZl2PZfhgNqde9BYIzYBX8zg8Qlm0aEkHiJfSabOpZmaal4jtPNLpGDW7iwieRapzescRfZ0IHbgSyFlwVttRPceHJkfjCP18PAgrADqbV6cdnGhNWHiSOinAU7Sp9tKItbcqFM5dGf8Qlm0aEedk0SqTHQGwNaEYu6z5dyheG(mZmawWtMsplFa7G3rSqiwbEoUyHx7mOqLF7yDzuqqJDu9CPIf7BXhcL)OEt7yDzuqqJDu9CPIgr4kBulMjVfZmdwSdl2PZf7Vfl8ANbfQ8BhRlJccASJQNlvaE1fgAaVoLqTq4uGaeGhrbjlkfawqF(aybV6cdnGxpxJKTjH(jvcAOq7MZf8KP0ZYhWoia9zgal4vxyOb80mvOOinQwhHf4jtPNLpGDqa6NoawWtMsplFa7G3rSqiwbE6DAAnvGiCuPiHlTMpvZisRd6ID6CXhcL)OEtRNRrY2Kq)KkbnuODZ52icxzJAXmTyya8Qlm0aEetztcv1nui2bb8owxwOrrsKqb6ZheG(WaawWtMsplFa7G3rSqiwbE6DAAnsNY1MekVxFH2ZMF7J6nl23IRlmgfQmcNjQfZ2I5dE1fgAapsNY1MekVxFH2ZMpia99lawWtMsplFa7G3rSqiwbENR14Q0wmdx85AlMnVfZm4vxyOb8icJcrju3IWbcqFymawWtMsplFa7G3rSqiwbENRTyM8wmZGxDHHgWtZubfPrdxH2Z1cHgwIqabOpmlawWtMsplFa7G3rSqiwbENRTyM8wC6l23ILrijSwmtl2Vma8Qlm0aEYiKeJ3SjHkzlnJacqFEbawWtMsplFa7G3rSqiwbEhIthrvbXGil23I1700A)AoHI0ONRX7wJi1fGxDHHgWtb1MXMe6rQrOqSdcia9HjaSGNmLEw(a2bVJyHqSc8oeNoIQcIbrwSVf74Ipek)r9MMMPcffPr16iSAeHRSrTy2wmmSyNox85AlMnVfddl2PZf74IpxBXElM5f7BXqjcJ0K7343clriuOvMBXoSyhaV6cdnGNEUoiOUGcXoiG3X6YcnksIekqF(Ga0NpdaWcE1fgAaVZ1O9kgfWtMsplFa7Ga0NpFaSGNmLEw(a2bVJyHqSc8oxRXvPTygU4Z1wmBElM)I9T46cJrHkJWzIAXElM)ID6CXNR14Q0wmdx85AlMnVfZm4vxyOb8oxJQ3rubia95ZmawWZMqiKoOb4Xh8KP0ZYhWo4vxyOb80YSSjHQecuzcke7GaEhXcHyf4bLimstUFJFtpxheuxqHyhKf7BXNRTy2wC6Ga0NF6aybpzk9S8bSdEhXcHyf4DUwJRsBXmCXNRTyMwmZGxDHHgWJykBsOQUHcXoiG3X6YcnksIekqF(Ga0NpmaGf8KP0ZYhWo4DeleIvG3H40ruvqmiYI9T4Z1ACvAlMHl(CTfZM3Izg8Qlm0aEHLiek0kZbEhRll0OijsOa95dcqF((fal4jtPNLpGDWRUWqd4rmLnjuv3qHyheW7yDzHgfjrcfOpFqacW7lAvxoaWc6Zhal4vxyOb8uqLIqDR5tvbXGiGNmLEw(a2bbOpZaybpBcHWyLbpyIbGh0lOUsLdxWJbn)cE1fgAaVa1DUuKgfsr4kWtMsplFa7Ga0pDaSGNmLEw(a2bVJyHqSc80700AkHiJfSADqxStNlwVttRPceHJkfjCP18PAgrADqxStNl2Xf7VfhvwMOPeImwWQjtPNL)I9T4GydejAqjORvjw2cwnIuxSyhwStNlwVttRPNrOFUtfnIuxSyNoxCuKejAHXj0ar)MSyM8wmmMbGxDHHgWdkkm0acqFyaal4jtPNLpGDWRUWqd4DvotRlm0qZMkaVJyHqSc80700AkHiJfSADqbVSPc6uCc4PeImwWceG((fal4jtPNLpGDW7iwieRaphxSmcjHvlmoHgikxL2IzAX8xStNl2XfhvwMOPeImwWQjtPNL)I9T4dHYFuVPPeImwWQreUYg1IzAXmVyhwSdl23IpxRXvPTygU4Z1wmBElMzWRUWqd4regfIsOUfHdeG(WyaSGNmLEw(a2bVJyHqSc8CCXYiKewTW4eAGOCvAlMPfZFXoDUyhxCuzzIMsiYybRMmLEw(l23Ipek)r9MMsiYybRgr4kBulMPfZ8IDyXoDUyhxSmcjHvlmoHgikxL2IzAXWWI9T4dHYFuVPPzQqrrAuTocRgr4kBulMPfZV53f7WIDyX(w85AnUkTfZWfFU2IzZBXPdE1fgAapntfuKgnCfApxleAyjcbeG(WSaybpzk9S8bSdEhXcHyf45VfFioDevNifKf7BXoUyzescRwyCcnquUkTfZ0I5VyNoxSJloQSmrtjezSGvtMspl)f7BXhcL)OEttjezSGvJiCLnQfZ0IzEXoSyNoxSJlwgHKWQfgNqdeLRsBXmTyyyX(w8Hq5pQ300mvOOinQwhHvJiCLnQfZ0I5387IDyXoSyFl(CTgxL2Iz4IpxBXS5TyMxSVf7Vf)rrlqDNlfPr)sfUnIWv2OaV6cdnGxyjcHcTYCG3X6YcnksIekqF(Ga0NxaGf8KP0ZYhWo4vxyOb8UkNP1fgAOztfGx2ubDkob8Upia9HjaSGNmLEw(a2bV6cdnG3v5mTUWqdnBQa8oIfcXkWZFlgAqwSVfxxymkuzeotulMPfN(I9T4I3eIfsdbvgk0kZrvbXGiQMmLEw(l23I93IlEtiwiTKmIWII0OHRq)vVPjtPNLp4LnvqNItapIcswukqa6ZNbaybpzk9S8bSdE1fgAaVRYzADHHgA2ub4DeleIvGxDHXOqLr4mrTyMwC6Gx2ubDkob8ubia95Zhal4jtPNLpGDWRUWqd4DvotRlm0qZMkaVJyHqSc8QlmgfQmcNjQfZM3Ith8YMkOtXjGxHeqacWdkroeNEfayb95dGf8Qlm0aEqrHHgWtMsplFa7Ga0NzaSGNmLEw(a2bVJyHqSc8CCX(BXrLLjAkHiJfSAYu6z5VyNoxS)wCuzzIMMPcksJgUcTNRfcnSeH0KP0ZYFXoaE1fgAaVZ1O6Devacq)0bWcE1fgAaVZ1O9kgfWtMsplFa7GaeGxHeaSG(8bWcEYu6z5dyh8oIfcXkWZXfhvwMO1Z1izBsOFsLGgk0U5CBYu6z5VyFl(qO8h1BA9Cns2Me6NujOHcTBo3gr4kBulMPf73f7WI9T4dHYFuVPPzQqrrAuTocRgr4kBulMTfNo4vxyOb8iMYMeQQBOqSdc4DSUSqJIKiHc0Npia9zgal4vxyOb865AKSnj0pPsqdfA3CUGNmLEw(a2bbOF6aybpzk9S8bSdEhXcHyf45VfdLimstUFJFlSeHqHwzUf7BXNRTyM8wm)f7BXYiKewlMPf7xgaE1fgAapzesIXB2KqLSLMrabOpmaGf8Qlm0aEAMkuuKgvRJWc8KP0ZYhWoia99lawWtMsplFa7G3rSqiwbE6DAAnsNY1MekVxFH2ZMF7J6nGxDHHgWJ0PCTjHY71xO9S5dcqFymawWtMsplFa7G3rSqiwbEhIthrvbXGil23IDCXoUyhx85AlMTfN(ID6CXhcL)OEttZuHII0OADewnIWv2OwmBlggVyhwSVf74IpxBXS5Ty)UyNox8Hq5pQ300mvOOinQwhHvJiCLnQfZ2IzEXoSyhwStNlwgHKWQfgNqdeLRsBXm5T40xSdGxDHHgWtb1MXMe6rQrOqSdcia9HzbWcEYu6z5dyh8oIfcXkW7CTgxL2Iz4IpxBXS5TyMbV6cdnGhryuikH6weoqa6ZlaWcEYu6z5dyh8oIfcXkW7CTfZK3Ith8Qlm0aENRr17iQaeG(WeawWtMsplFa7G3rSqiwbENR14Q0wmdx85AlMnVfNo4vxyOb80mvqrA0WvO9CTqOHLieqa6ZNbaybpzk9S8bSdEhXcHyf4DUwJRsBXmCXNRTy28wmZl23IDCX(BXrLLjAUwqpeNoQjtPNL)ID6CX(BXhIthr1jsbzXoaE1fgAaVWsecfAL5aVJ1LfAuKejuG(8bbOpF(aybpzk9S8bSdEhXcHyf45VfFioDevNifeWRUWqd4DUgTxXOacqF(mdGf8KP0ZYhWo4DeleIvG3H40ruvqmiYI9TyhxSENMwthbHcLGUwh0f705IDCXrLLjAUwqpeNoQjtPNL)I9TyOeHrAY9B8BHLiek0kZTyFl(CTfZ0IHHf7WIDa8Qlm0aE656GG6cke7GaEhRll0OijsOa95dcqaEkHiJfSaWc6Zhal4jtPNLpGDW7iwieRaV6cJrHkJWzIAXmT40xStNlgkryKMC)g)McQnJnj0JuJqHyheWRUWqd4rmLnjuv3qHyheW7yDzHgfjrcfOpFqa6ZmawWtMsplFa7G3rSqiwbEoUy9onTMEgH(5ov06GUyFlgkryKMC)g)gXu2KqvDdfIDqwSdl2PZfR3PP1ucrgly1icxzJAXmTy(l2PZf74IRlmgfQmcNjQfZ2I5VyFlUUWyuOYiCMOwmtl2Vl2bWRUWqd4PzQqrrAuToclqa6NoawWtMsplFa7G3rSqiwbErLLjAUwqpeNoQjtPNL)I9TyzescRwyCcnquUkTfZ0IzEX(wmuIWin5(n(n9CDqqDbfIDqwSVfFU2IzYBXmdE1fgAapntfuKgnCfApxleAyjcbeG(WaawWtMsplFa7G3rSqiwbErLLjAUwqpeNoQjtPNL)I9TyzescRwyCcnquUkTfZ0I5VyFlgkryKMC)g)MEUoiOUGcXoil23IpxRXvPTygU4Z1wmBElMzWRUWqd4fwIqOqRmhia99lawWtMsplFa7G3rSqiwbEhIthrvbXGil23IDCX1fgJcvgHZe1IzZBXPVyNoxSJloQSmrZ1c6H40rnzk9S8xSVfdLimstUFJFtpxheuxqHyhKf7WID6CXoU46cJrHkJWzIAXElM5f7BXqjcJ0K73430Z1bb1fui2bzXoSyhaV6cdnGNcQnJnj0JuJqHyheqa6dJbWcEYu6z5dyh8Qlm0aE656GG6cke7GaEhRll0OijsOa95dcqaEQaalOpFaSGxDHHgWRNRrY2Kq)KkbnuODZ5cEYu6z5dyheG(mdGf8KP0ZYhWo4DeleIvG35AlMnVf7xWRUWqd4rmLnjuv3qHyheW7yDzHgfjrcfOpFqa6NoawWRUWqd4PzQqrrAuToclWtMsplFa7Ga0hgaWcEYu6z5dyh8Qlm0aEetztcv1nui2bb8owxwOrrsKqb6ZheG((fal4jtPNLpGDW7iwieRap9onTgPt5AtcL3RVq7zZV9r9Mf7BX1fgJcvgHZe1IzBX8bV6cdnGhPt5AtcL3RVq7zZheG(WyaSGNmLEw(a2bVJyHqSc8oxRXvPTygU4Z1wmBElMzWRUWqd4regfIsOUfHdeG(WSaybpzk9S8bSdEhXcHyf4DU2IzYBXmdE1fgAapntfuKgnCfApxleAyjcbeG(8caSGNmLEw(a2bVJyHqSc8oxBXm5T40xSVflJqsyTyMwSFza4vxyOb8KrijgVztcvYwAgbeG(WeawWtMsplFa7G3rSqiwbEhIthrvbXGil23I1700A)AoHI0ONRX7wJi1fGxDHHgWtb1MXMe6rQrOqSdcia95ZaaSGNmLEw(a2bVJyHqSc8oeNoIQcIbrwSVf74Ipek)r9MgXu2KqvDdfIDqAeHRSrTy2wC6l2PZfFU2IzZBXPVyhwSVf74Ipek)r9MMMPcffPr16iSAeHRSrTy2wmmSyNox85AlMnVfddl2PZf74IpxBXElM5f7BXqjcJ0K7343clriuOvMBXoSyhaV6cdnGNEUoiOUGcXoiG3X6YcnksIekqF(Ga0NpFaSGxDHHgW7CnAVIrb8KP0ZYhWoia95ZmawWtMsplFa7G3rSqiwbENR14Q0wmdx85AlMnVfZFX(wCDHXOqLr4mrTyVfZFXoDU4Z1ACvAlMHl(CTfZM3Izg8Qlm0aENRr17iQaeG(8thal4jtPNLpGDW7iwieRaVdXPJOQGyqKf7BXNR14Q0wmdx85AlMnVfZm4vxyOb8clriuOvMd8owxwOrrsKqb6ZheG(8HbaSGNnHqiDqdWJp4jtPNLpGDWRUWqd4PLzztcvjeOYeui2bb8oIfcXkWdkryKMC)g)MEUoiOUGcXoil23IpxBXST40bbiaVa9bWc6Zhal4jtPNLpGDW7iwieRapHx7mOqLF7yDzuqqJDu9CPIf7BXrrsKOfgNqde9BYIzBXW0I9T4dHYFuVPDSUmkiOXoQEUurJiCLnQfZK3Izg8Qlm0aEbQ7CPin6xQWfeG(mdGf8KP0ZYhWo4DeleIvGN)wSWRDguOYVDSUmkiOXoQEUuXI9TyHx7mOqLF7tmD9SnjuBGaf9xSVfhgNqde9BYIzBXW0I9TyhxCuKejAHXj0arHEbnDgSy28wm)0zWID6CXrrsKOfgNqdef6f00zWIzAX8If7a4vxyOb8cu35srA0VuHlia9thal4jtPNLpGDW7iwieRap)TyHx7mOqLF7yDzuqqJDu9CPIf7BX(BXcV2zqHk)2Ny66zBsO2abk6VyFlomoHgi63KfZ2IHjWRUWqd4fOUZLI0OFPcxqacqaEmkeLHgqFMzaFyIbWeZ(f86vKXMef45)Wbfrc5VyEXIRlm0S4SPcvBtbEqjinllGNFwmmdB(9QmeHSy)tObYMYpl2ncOkEj4GlXc3o92H4GtzCD5km0CKslGtzChCBk)S4(igfoDHSy(8HFXmZa(W0MAt5NfdZDRjru8sBk)SygUyyeHdXOS4huPil2)TM)IFbXGil(qZpm0OwSJU18ZYFX6SwC9)OXH2MYplMHlggr4qmkl2))GzUyICiooz(vyOzXo2ZY5fRlhItwCTyOerZH2MYplMHlgM7wtIS4OijsqnTfhOfFSUSqJIKiHQTP8ZIz4IHreoeJYILrijSw8vqx85khKfRHil2)BQqTyK2I9)Dewl2rLXT4VPPjezozXMAXJKKTetplWVy9UyXqZfRf)nnnHiZjl2ulwzjJPzxnHdTnLFwmdxS)9)L)IHrPKf7)ecNAXogeBGiHc(flX1COTP2u(zX8YPjxxi)fRlAiIS4dXPxXI1LeBuTf7FVtGgQfpOHHUfHtRlV46cdnQfJMmR2MYplUUWqJQbLihItVcpTCPGSP8ZIRlm0OAqjYH40RGhp40qO)MYplUUWqJQbLihItVcE8GR6s4KjQWqZMYpl(nfuLlkwmPS)I1700K)IvrfQfRlAiIS4dXPxXI1LeBulUM)IHsegcffHnjl2ul(JgPTP8ZIRlm0OAqjYH40RGhp4utbv5IcQkQqTPQlm0OAqjYH40RGhp4GIcdnBQ6cdnQguICio9k4XdUZ1O6DevaVP55O)Iklt0ucrgly1KP0ZY3Pt)fvwMOPzQGI0OHRq75AHqdlrinzk9S8DytvxyOr1GsKdXPxbpEWDUgTxXOSP2u(zX8YPjxxi)flmkewlomozXHRS46cezXMAXfJLLl9S02u(zX1fgAuEvxGOve1bztvxyOrXJhCkOsrOU18PQGyqKnvDHHgfpEWfOUZLI0OqkcxbVnHqySYEWedGh6fuxPYHRhdA(Dt5Nf7FgfgAwSPT4NqKXcwlgrw8lqeo4xmVCrcx4xCn)f7)nIS4IilUd6IrKfZc1T4IilM0nJnjlwjezSG1IR5V4AXCLnlwfvS4Gydejwmuc6uWVyezXSqDlUiYI7MVqwC4klw00KlwmsBX6ze6N7ub8lgrwCuKejwCyCYId0I)MSytT4eIuHqwmISyHx7Q8Id0IHXmytvxyOrXJhCqrHHg4nnp9onTMsiYybRwhuNo1700AQar4OsrcxAnFQMrKwhuNoD0FrLLjAkHiJfSAYu6z57li2arIguc6AvILTGvJi1fo40PENMwtpJq)CNkAePUWPZOijs0cJtObI(nHjpymd2u1fgAu84b3v5mTUWqdnBQa(P4epLqKXcwWBAE6DAAnLqKXcwToOBQ6cdnkE8GJimkeLqDlch8MMNJYiKewTW4eAGOCvAmX3PthJklt0ucrgly1KP0ZY33Hq5pQ30ucrgly1icxzJIjMDWbFNR14Q0y45AS5X8MQUWqJIhp40mvqrA0WvO9CTqOHLie4nnphLrijSAHXj0ar5Q0yIVtNogvwMOPeImwWQjtPNLVVdHYFuVPPeImwWQreUYgftm7GtNokJqsy1cJtObIYvPXem47qO8h1BAAMkuuKgvRJWQreUYgft8B(1bh8DUwJRsJHNRXMx6BQ6cdnkE8GlSeHqHwzo4pwxwOrrsKq5XhEtZZFhIthr1jsbXNJYiKewTW4eAGOCvAmX3PthJklt0ucrgly1KP0ZY33Hq5pQ30ucrgly1icxzJIjMDWPthLrijSAHXj0ar5Q0ycg8Diu(J6nnntfkksJQ1ry1icxzJIj(n)6Gd(oxRXvPXWZ1yZJzF(7JIwG6oxksJ(LkCBeHRSrTPQlm0O4XdURYzADHHgA2ub8tXjE3Ft5NfdZRCEXHRSyyKhmt)dfLAX1fgAwC2uXInTf7FeuzwS)5kZT4xqmiIcg9In1ILP0ZYh(fxZFX(hNrewlgPT4WvwS)bvpoy0QftQbYIn1IhuSyzk9S83u1fgAu84b3v5mTUWqdnBQa(P4epIcswuk4nnp)bni(QlmgfQmcNjkMs3xXBcXcPHGkdfAL5OQGyqevtMsplFF(R4nHyH0sYiclksJgUc9x9MMmLEw(Bk)SyyELZloCLf)GDX1fgAwC2uXInTfhUcrwCrKfZ8IrKfNfLAXYiCMO2u1fgAu84b3v5mTUWqdnBQa(P4epvaVP5vxymkuzeotumL(MYplgMx58IdxzX(xeV8IRlm0S4SPIfBAloCfIS4Iilo9fJilMdrKflJWzIAtvxyOrXJhCxLZ06cdn0SPc4NIt8kKaVP5vxymkuzeotuS5L(MAt5Nf7FVWqJQ5Fr8Yl2ul2MqMV8xSgIS4oLS4Ew4Uy)x5c7O(3)NcZZsXOS4A(l(6iezImRfpI8vloqlwxwmcAyCgVj)nvDHHgvRqIhXu2KqvDdfIDqG)yDzHgfjrcLhF4nnphJklt065AKSnj0pPsqdfA3CUnzk9S89Diu(J6nTEUgjBtc9tQe0qH2nNBJiCLnkM8Rd(oek)r9MMMPcffPr16iSAeHRSrXw6BQ6cdnQwHeE8GRNRrY2Kq)KkbnuODZ5UPQlm0OAfs4XdozesIXB2KqLSLMrG3088huIWin5(n(TWsecfAL58DUgtE89jJqsyXKFzWMQUWqJQviHhp40mvOOinQwhH1MQUWqJQviHhp4iDkxBsO8E9fApB(WBAE6DAAnsNY1MekVxFH2ZMF7J6nBQ6cdnQwHeE8Gtb1MXMe6rQrOqSdc8MM3H40ruvqmiIphD0XZ1ylDNopek)r9MMMPcffPr16iSAeHRSrXgm2bFoEUgBE(1PZdHYFuVPPzQqrrAuTocRgr4kBuSXSdo40PmcjHvlmoHgikxLgtEP7WMQUWqJQviHhp4icJcrju3IWbVP5DUwJRsJHNRXMhZBQ6cdnQwHeE8G7CnQEhrfWBAENRXKx6BQ6cdnQwHeE8GtZubfPrdxH2Z1cHgwIqG308oxRXvPXWZ1yZl9nvDHHgvRqcpEWfwIqOqRmh8hRll0OijsO84dVP5DUwJRsJHNRXMhZ(C0FrLLjAUwqpeNoQjtPNLVtN(7qC6iQorkioSPQlm0OAfs4XdUZ1O9kgf4nnp)DioDevNifKnLFwCDHHgvRqcpEWPLzztcvjeOYeui2bbEtZtVttRPJGqHsqx7J6nWBtiesh0WJ)MQUWqJQviHhp40Z1bb1fui2bb(J1LfAuKejuE8H308oeNoIQcIbr85OENMwthbHcLGUwhuNoDmQSmrZ1c6H40rnzk9S89bLimstUFJFlSeHqHwzoFNRXem4GdBQnLFwmmhHYFuVrTPQlm0OA33ZggrqeAADYqdxH2Z1cHgwIq2u1fgAuT7ZJhCDkHAHWP2u1fgAuT7ZJhCDkHAHWb)uCIhJfXk9SqTjKrzblAILumIYbfPolNRWMekrQlqKnvDHHgv7(84bNEgH(uTocRnvDHHgv7(84bNUqucbInjBk)SyyukzX(xYvJSyyreImXInTfZc1T4IilMZukBswCflolLkwm)fdZDTfxZFX9qdm6yXxbDXYiKewlUNfU2Syg087IvYHMVAtvxyOr1UppEWvKRgHgicrMaEtZ7CTgxLgdpxJnp((KrijSAHXj0ar5Q0yZJbn)UPQlm0OA3Nhp4YwIBOO8E3pHtMytvxyOr1UppEWPzerpJq)nvDHHgv7(84bxnNOcsLPxLZBQ6cdnQ295XdURYzADHHgA2ub8tXjEb6VPQlm0OA3Nhp4ubIWrLIeU0A(unJiWBAEhcL)OEttfichvks4sR5t1mI0o3IKikpMD60XdHYFuVPPzQqrrAuTocRgr4kBum5bt(oxJnV09Diu(J6nTEUgjBtc9tQe0qH2nNBJiCLnkM84dd(oek)r9MwG6oxksJ(LkCBeHRSrXMhmXahC6mmoHgi63eM847xNo)OOfOUZLI0OFPc3gr4kBuBQ6cdnQ295XdUdnNmbPc5t1YfNaVP59rr7qZjtqQq(uTCXju9oY0icxzJIjpM3u1fgAuT7ZJhC6ze6trA0WvOYiCS2u1fgAuT7ZJhCHRq7gDu38PAiYjBQ6cdnQ295XdoODetJLnju9CPInvDHHgv7(84bNg66uYNw8MqSqO6sXTPQlm0OA3Nhp46uc1cHd(P4epOOdIekJ3Kp9qCq7Ikm0q)cJ2jWBAEFu0cu35srA0VuHBJiCLnQnvDHHgv7(84bxNsOwiCWpfN4vkxgRruusXBic9qKkdVP55OJcV2zqHk)2X6YOGGg7O65sf(oek)r9M2X6YOGGg7O65sfnIWv2OyZJzg4GtN(t41odku53owxgfe0yhvpxQWbFo(f9onTgP4neHEisLPFrVttR9r9gNoD0FcV2zqHk)2Ny66zBsO2abk670zuKejAHXj0arHEbnDgWeVWbF6DAAnvGiCuPiHlTMpvZisJiCLnk24NUtNHXj0ar)MWeZ8DytvxyOr1UppEWPeImwWcEtZ7qO8h1BAetztcv1nui2bPreUYgftEm70zyCcnq0Vjm5XN5nvDHHgv7(84bhNWHiSOinAU7Sp9tKItbVP5jJqsyXemWaF6DAAnvGiCuPiHlTMpvZisRd6MQUWqJQDFE8GJyqHMfQnuf06KnvDHHgv7(84bxNsOwiCk4nnphfETZGcv(TJ1Lrbbn2r1ZLk8Diu(J6nTJ1Lrbbn2r1ZLkAeHRSrXKhZmWbNo9NWRDguOYVDSUmkiOXoQEUuXMAtvxyOr1ikizrP865AKSnj0pPsqdfA3CUBQ6cdnQgrbjlkfpEWPzQqrrAuTocRnvDHHgvJOGKfLIhp4iMYMeQQBOqSdc8hRll0OijsO84dVP5P3PP1ubIWrLIeU0A(unJiToOoDEiu(J6nTEUgjBtc9tQe0qH2nNBJiCLnkMGHnvDHHgvJOGKfLIhp4iDkxBsO8E9fApB(WBAE6DAAnsNY1MekVxFH2ZMF7J6n(QlmgfQmcNjk24VPQlm0OAefKSOu84bhryuikH6weo4nnVZ1ACvAm8Cn28yEtvxyOr1ikizrP4XdontfuKgnCfApxleAyjcbEtZ7CnM8yEtvxyOr1ikizrP4XdozesIXB2KqLSLMrG308oxJjV09jJqsyXKFzWMQUWqJQruqYIsXJhCkO2m2KqpsncfIDqG308oeNoIQcIbr8P3PP1(1CcfPrpxJ3TgrQl2u1fgAunIcswukE8GtpxheuxqHyhe4pwxwOrrsKq5XhEtZ7qC6iQkigeXNJhcL)OEttZuHII0OADewnIWv2OydgC68Cn28GbNoD8CnpM9bLimstUFJFlSeHqHwzohCytvxyOr1ikizrP4XdUZ1O9kgLnvDHHgvJOGKfLIhp4oxJQ3rub8MM35AnUkngEUgBE89vxymkuzeotuE8D68CTgxLgdpxJnpM3u1fgAunIcswukE8GtlZYMeQsiqLjOqSdc8MMhuIWin5(n(n9CDqqDbfIDq8DUgBPdVnHqiDqdp(BQ6cdnQgrbjlkfpEWrmLnjuv3qHyhe4pwxwOrrsKq5XhEtZ7CTgxLgdpxJjM3u1fgAunIcswukE8GlSeHqHwzo4pwxwOrrsKq5XhEtZ7qC6iQkigeX35AnUkngEUgBEmVPQlm0OAefKSOu84bhXu2KqvDdfIDqG)yDzHgfjrcLh)n1MYpl(jezSG1IHsmeXcwBQ6cdnQMsiYyblpIPSjHQ6gke7Ga)X6YcnksIekp(WBAE1fgJcvgHZeftP70juIWin5(n(nfuBgBsOhPgHcXoiBQ6cdnQMsiYyblE8GtZuHII0OADewWBAEoQ3PP10Zi0p3PIwhuFqjcJ0K7343iMYMeQQBOqSdIdoDQ3PP1ucrgly1icxzJIj(oD6yDHXOqLr4mrXgFF1fgJcvgHZeft(1HnvDHHgvtjezSGfpEWPzQGI0OHRq75AHqdlriWBAErLLjAUwqpeNoQjtPNLVpzescRwyCcnquUknMy2huIWin5(n(n9CDqqDbfIDq8DUgtEmVPQlm0OAkHiJfS4XdUWsecfAL5G308Iklt0CTGEioDutMsplFFYiKewTW4eAGOCvAmX3huIWin5(n(n9CDqqDbfIDq8DUwJRsJHNRXMhZBQ6cdnQMsiYyblE8Gtb1MXMe6rQrOqSdc8MM3H40ruvqmiIphRlmgfQmcNjk28s3PthJklt0CTGEioDutMsplFFqjcJ0K73430Z1bb1fui2bXbNoDSUWyuOYiCMO8y2huIWin5(n(n9CDqqDbfIDqCWHnvDHHgvtjezSGfpEWPNRdcQlOqSdc8hRll0OijsO84VP2u1fgAunv41Z1izBsOFsLGgk0U5C3u1fgAunvWJhCetztcv1nui2bb(J1LfAuKejuE8H308oxJnp)UPQlm0OAQGhp40mvOOinQwhH1MQUWqJQPcE8GJykBsOQUHcXoiWFSUSqJIKiHYJ)MQUWqJQPcE8GJ0PCTjHY71xO9S5dVP5P3PP1iDkxBsO8E9fApB(TpQ34RUWyuOYiCMOyJ)MQUWqJQPcE8GJimkeLqDlch8MM35AnUkngEUgBEmVPQlm0OAQGhp40mvqrA0WvO9CTqOHLie4nnVZ1yYJ5nvDHHgvtf84bNmcjX4nBsOs2sZiWBAENRXKx6(KrijSyYVmytvxyOr1ubpEWPGAZytc9i1iui2bbEtZ7qC6iQkigeXNENMw7xZjuKg9CnE3AePUytvxyOr1ubpEWPNRdcQlOqSdc8hRll0OijsO84dVP5DioDevfedI4ZXdHYFuVPrmLnjuv3qHyhKgr4kBuSLUtNNRXMx6o4ZXdHYFuVPPzQqrrAuTocRgr4kBuSbdoDEUgBEWGtNoEUMhZ(GsegPj3VXVfwIqOqRmNdoSPQlm0OAQGhp4oxJ2Ryu2u1fgAunvWJhCNRr17iQaEtZ7CTgxLgdpxJnp((QlmgfQmcNjkp(oDEUwJRsJHNRXMhZBQ6cdnQMk4XdUWsecfAL5G)yDzHgfjrcLhF4nnVdXPJOQGyqeFNR14Q0y45AS5X8MQUWqJQPcE8GtlZYMeQsiqLjOqSdc8MMhuIWin5(n(n9CDqqDbfIDq8DUgBPdVnHqiDqdp(BQnvDHHgvlqFVa1DUuKg9lv4cVP5j8ANbfQ8BhRlJccASJQNlv4lksIeTW4eAGOFtydM8Diu(J6nTJ1Lrbbn2r1ZLkAeHRSrXKhZBQ6cdnQwG(84bxG6oxksJ(LkCH3088NWRDguOYVDSUmkiOXoQEUuHpHx7mOqLF7tmD9SnjuBGaf99fgNqde9BcBWKphJIKirlmoHgik0lOPZa284NodC6mksIeTW4eAGOqVGModyIx4WMQUWqJQfOppEWfOUZLI0OFPcx4nnp)j8ANbfQ8BhRlJccASJQNlv4ZFcV2zqHk)2Ny66zBsO2abk67lmoHgi63e2GjWR6cxeb8EghmheGaaa]] )

end