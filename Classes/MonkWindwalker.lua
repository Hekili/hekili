-- MonkWindwalker.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'MONK' then
    local spec = Hekili:NewSpecialization( 269 )

    spec:RegisterResource( Enum.PowerType.Energy, {
        rushing_jade_wind = {
            resource = 'energy',
            -- setting = 'forecast_fury',
            aura = 'rushing_jade_wind',

            last = function ()
                local app = state.buff.rushing_jade_wind.applied
                local t = state.query_time

                if state.buff.rushing_jade_wind.last_tick and state.buff.rushing_jade_wind.last_tick > state.buff.rushing_jade_wind.applied then app = state.buff.rushing_jade_wind.last_tick end

                return app + ( floor( ( t - app ) / ( 0.75 * state.haste ) ) * ( 0.75 * state.haste ) )
            end,

            stop = function( x )
                return x < 3
            end,

            interval = function () return 0.75 * state.haste end,
            value = -3,
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
        gladiators_medallion = 3574, -- 208683
        relentless = 3573, -- 196029
        adaptation = 3572, -- 214027
        
        tiger_style = 3737, -- 206743
        heavyhanded_strikes = 3734, -- 232054
        eminence = 3616, -- 216255
        tigereye_brew = 675, -- 247483
        grapple_weapon = 3052, -- 233759
        disabling_reach = 3050, -- 201769
        yulons_gift = 1959, -- 232879
        fast_feet = 3527, -- 201201
        control_the_mists = 852, -- 233765
        fortifying_brew = 73, -- 201318
        ride_the_wind = 77, -- 201372
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
            id = 261715,
            duration = 3600,
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

        -- Azerite Powers
        iron_fists = {
            id = 272806,
            duration = 10,
            max_stack = 1,
        },

        swift_roundhouse = {
            id = 278710,
            duration = 12,
            max_stack = 2,
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


    -- If a Tiger Palm missed, pretend we never cast it.
    -- Use RegisterEvent since we're looking outside the state table.
    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event )
        local _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()
        
        if sourceGUID == state.GUID then
            local ability = class.abilities[ spellID ] and class.abilities[ spellID ].key
            if not ability then return end

            if ability == "tiger_palm" and subtype == "SPELL_MISSED" then
                if ns.castsAll[1] == "tiger_palm" then
                    table.remove( ns.castsAll, 1 )
                elseif ns.castsAll[2] == "tiger_palm" then
                    table.remove( ns.castsAll, 2 )
                end

                if ns.castsOn[1] == "tiger_palm" then
                    table.remove( ns.castsOn, 1 )
                end

                actual_combo = prev_combo
                prev_combo = nil
                
                Hekili:ForceUpdate()
            
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
                
                if azerite.meridian_strikes.enabled and cooldown.touch_of_death.remains > 0 then
                    cooldown.touch_of_death.expires = cooldown.touch_of_death.expires - 0.25
                end
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

    spec:RegisterHook( "reset_precast", function ()
        chiSpent = 0
        if prev_gcd[1].tiger_palm and ( class.abilities.tiger_palm.lastCast == 0 or combat == 0 or class.abilities.tiger_palm.lastCast < combat ) then
            prev_gcd.override = "none"
            prev.override = "none"
        end
        spinning_crane_kick.count = nil
        virtual_combo = nil
    end )
    

    spec:RegisterHook( "IsUsable", function( spell )
        if talent.hit_combo.enabled and buff.hit_combo.up then
            if spell == 'tiger_palm' then
                local lc = class.abilities[ spell ].lastCast or 0                
                if ( combat == 0 or lc >= combat ) and last_combo == spell then return false end
            elseif last_combo == spell then return false end
        end
    end )


    spec:RegisterStateTable( "spinning_crane_kick", setmetatable( { onReset = function( self ) self.count = nil end },
        { __index = function( t, k )
                if k == 'count' then
                    t[ k ] = max( GetSpellCount( action.spinning_crane_kick.id ), active_dot.mark_of_the_crane )
                    return t[ k ]
                end
        end } ) )

    -- spec:RegisterStateExpr( "gcd", function () return 1.0 end )


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

                if azerite.swift_roundhouse.enabled then
                    addStack( "swift_roundhouse", nil, 1 )
                end
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
            break_channel = true,
            cooldown = 0,
            gcd = "spell",
            
            spend = 20,
            spendPerSec = 20,
            spendType = "energy",
            
            startsCombat = true,
            texture = 606542,

            handler = function ()
                removeBuff( "this_emperors_capacitor" )                
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
                if azerite.iron_fists.enabled and active_enemies > 3 then applyBuff( "iron_fists" ) end
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
                removeBuff( "swift_roundhouse" )

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
            end,
        },
        

        rushing_jade_wind = {
            id = 261715,
            cast = 0,
            cooldown = function ()
                if buff.rushing_jade_wind.up then return 0 end

                local x = 6 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            gcd = function () return buff.rushing_jade_wind.up and "off" or "spell" end,
            
            spend = function ()
                if buff.rushing_jade_wind.up then return 0 end
                return 3
            end,
            spendPerSec = function ()
                if buff.rushing_jade_wind.up then return 0 end
                return 3
            end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 606549,

            talent = "rushing_jade_wind",
            indicator = function () return buff.rushing_jade_wind.up and "cancel" or nil end,
            
            cycle = "mark_of_the_crane",

            handler = function ()
                if buff.rushing_jade_wind.down then
                    applyBuff( "rushing_jade_wind", 3600 )
                    active_dot.mark_of_the_crane = min( active_enemies, active_dot.mark_of_the_crane + ( debuff.mark_of_the_crane.down and 2 or 1 ) )
                    applyDebuff( "target", "mark_of_the_crane" )
                else
                    removeBuff( "rushing_jade_wind" )
                end
            end,

            copy = 148187
        },
        

        serenity = {
            id = 152173,
            cast = 0,
            cooldown = 90,
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
            gcd = "spell",
            
            startsCombat = true,
            texture = 608940,

            toggle = "interrupts",

            usable = function () return target.casting end,
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
            
            spend = 2,
            spendType = "chi",
            
            startsCombat = true,
            texture = 606543,
            
            handler = function ()                
            end,
        },
        

        storm_earth_and_fire = {
            id = 137639,
            cast = 0,
            charges = 2,
            cooldown = 90,
            recharge = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 136038,

            notalent = "serenity",
            
            handler = function ()
                applyBuff( "storm_earth_and_fire" )
            end,
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

            handler = function ()
                if talent.eye_of_the_tiger.enabled then
                    applyDebuff( "target", "eye_of_the_tiger" )
                    applyBuff( "eye_of_the_tiger" )
                end

                applyDebuff( "target", "mark_of_the_crane" )

                gain( buff.power_strikes.up and 3 or 2, "chi" )
                removeBuff( "power_strikes" )
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

            usable = function () return cooldown.fists_of_fury.remains > 0 and cooldown.rising_sun_kick.remains > 0 end,
            handler = function ()
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        package = "Windwalker",

        strict = false
    } )

    spec:RegisterPack( "Windwalker", 20180901.2021,
        [[d0KA4aqicvTiKQkpIqLlbas2KsQpbaQrjHCkjuVIsLzHeDlKQSlj9laAyaOJrkwgHYZasMgqQUgsW2aG(gPuPXbKIZHeY6aaMhLQUNsSpa5GaP0cjL8qKQYfjLQSraqQpQKKmsaqCssPQALsWlvssntsPQCtsPIDcedvjPAPkjXtvvtfqDvKQQ4RkjLZIuvL2lK)sYGv5WkwSe9yetwPUmQntWNjQrtQonvRMukVgOMTQCBkz3s9BOgos64ivv1Yb9CkMUW1jY2rQ8Dcz8kjopsz9iHA(uk7x0iniGr)9emceXaOgqdaPiaQPkgaftJyai6h0OYOp1HaEKz0Vhlg9xnV3IMhygI(uhAp8SraJ(gSeKWOV4YtpcQgaaGak7HUuzLGTa04wsVjCCtGJqaOXTiaw(WLawkm0BZ0biviwWFSbWvhYRY4BdGR(QO0o4gSA18ElAEGzy14we0VuYFH2FJkr)9emceXaOgqdaPiaQPQHIaDqxmXqFdvMGarmaKIq)nBiOV4YB18ElAEGzyEAhCdoliU80JGQbaaiGYEOlvwjylanUL0Bch3e4ieaAClcGLpCjGLcd92mDasfIf8hBaC1H8Qm(2a4QVkkTdUbRwnV3IMhygwnUfjliU8(m1GTkzyEAOmpXaOgqtE0lpTlaauamVvx7KfYcIlp6tFAz2aaYcIlp6L3QWwy64DEKXeElNhrNjGZtaITY7tLhyEaqMEN3pGoyoVI0NE)4DEEhmSN3JwEL0Yl058M9g3fxZcIlp6Lh9PpTmVZlgOmhkxipdToMvYlW5rOrESkgOmhM8kkgOmhkxiVgh5zKOsfddENxjT8M9g3fxZcIlp6Lh9PpTmVZJ(rMMWpvPKGa9lVaN3Qiz09woVcZMZB18ENxGZB7MP8X5rMMWV3eoUZdlKxOZ5TkfwT8kLeeYtKo35b5qc2ElNxGZ7dCnV8O)ILYJmDEqMECpLpoVq3n5vslpIota7TCEAVEkF8opCNxOZ5j4qtKh3bKwEENxOZ5r)mb9lVHeoUZ75MOMfYcIlpqWbBaazbXLh9YdyDoV3eSjYtI6EcopitfYgUdtEtEwJ2WW8aTRU2xEqwe0dopbi2kVqNZ77wsVjCCtFWriYl4XkVIACKNfl(IRO)ZnHbbm6t2iGrGObbm6pKWXn67nDyWSAfjUrFUNYhVrAHceiIHag95EkF8gPf63JfJ(pjtaXsgLm(T5wr9jznYm6pKWXn6)KmbelzuY43MBf1NK1iZOabcOqaJ(djCCJ(LpmEReKG0qFUNYhVrAHceiGocy0FiHJB0VKHggc2Bz0N7P8XBKwOabcfqaJ(CpLpEJ0c9jqpyOpOpr3RwZk5rV8i6EEaTKNM8wNh3muMwnClwfyL1SsEaTKhaRua9hs44g9hizAwfyiK7afiqaqeWO)qch3O)ZL1dJsBsBzlUd0N7P8XBKwOabI2fbm6pKWXn6l4qU8HXB0N7P8XBKwOabcObbm6pKWXn6pnHnbCEkY8EOp3t5J3iTqbcekcbm6Z9u(4nsl0Na9GH(G(XaL5OgUfRcSA7CEaLhfH(djCCJ(bwIORWcQnpHokqGObGiGrFUNYhVrAH(eOhm0h0NGXVnwuxnbgAP4bg6QP3kbhYvI(aLztEl5jwE2SLxr5rW43glQRcUjmkSGsqcsRczRXBtE2VKhaM368i6EEaTKhOYBDEem(TXI6k0nElRmsTcStaxHS14Tjp7xYttEfNNnB5fduMJA4wSkWQTZ5z)sEAOa6pKWXn6Bcm0sXdm0vtVvcoKrbcenAqaJ(CpLpEJ0c9jqpyOpOpbJFBSOUcDJ3YkJuRa7eWviBnEBYZ(L8elpB2YlgOmh1WTyvGvBNZZ(L80ig6pKWXn6Byi3EqdfOa9Pczc2QCceWiq0Gag95EkF8gPfkqGigcy0N7P8XBKwOabcOqaJ(CpLpEJ0cfiqaDeWOp3t5J3iTqbcekGag9hs44g9PIdh3Op3t5J3iTqbceaebm6Z9u(4nsl0Na9GH(G(fLN4ZlMh3r1WqU9GwL7P8X78SzlpXNxmpUJQGBcfwqf6SsKUhSkCzgw5EkF8oVIr)HeoUrFIURkLGMafiq0UiGr)HeoUrFIURen0XOp3t5J3iTqbkqFdd52dAiGrGObbm6Z9u(4nsl0FiHJB0h6gVLvgPwb2jGrFcnYJvXaL5WGardkqGigcy0N7P8XBKwOpb6bd9b9lkVsjbHA5dJ3pjtuLOM368Ocz6uYKDvtf6gVLvgPwb2jGZBDEIpVHIzOhC1iYfcfel1BDSKHRCpLpENxX5zZwELsccvdd52dAviBnEBYZ(80KNnB5nKWPJvCZwoBYdO80G(djCCJ(cUjmkSGsqcsdfiqafcy0N7P8XBKwOpb6bd9b9fFEuHmDkzYUQPAO6D7TSIaNMvGDc48wNxr5nKWPJvCZwoBYdOL8avE2SLxr5nKWPJvCZwoBYBjpXYBDEuHmDkzYUQPw(gcySuOa7eW5vCEfJ(djCCJ(gQE3ElRiWPzfyNagfiqaDeWOp3t5J3iTq)HeoUr)Y3qaJLcfyNag9j0ipwfduMddcenOafO)GzeWiq0Gag9hs44g9fP7WN3YQnCKXTIQut0rFUNYhVrAHceiIHag95EkF8gPf6tGEWqFqFXNhvitNsMSRAQHlZqf15zL368i6EE2VKNM8wNh3muMwE2Nhfai6pKWXn6ZndLDk2Bzf)8vCikqGakeWOp3t5J3iTqFc0dg6d6ZndLPvd3IvbwznRKhq5jwLcO)qch3OVGBcJclOeKG0qbceqhbm6Z9u(4nsl0Na9GH(G(LsccvOKr3BzL2MnRe59UUXI68wNh3muMwnClwfyL1SsEaLNg0FiHJB0hkz09wwPTzZkrEVrbcekGag95EkF8gPf6pKWXn6dDJ3YkJuRa7eWOpb6bd9b9lkVyEChvr6o85TSAdhzCROk1e9k3t5J35Topcg)2yrDvKUdFElR2Wrg3kQsnrVczRXBtE2NNmzNxX5Topcg)2yrDvWnHrHfucsqAviBnEBYdO8af6tOrESkgOmhgeiAqbceaebm6Z9u(4nsl0Na9GH(G(IppQqMoLmzx1unu9U9wwrGtZkWobm6pKWXn6BO6D7TSIaNMvGDcyuGar7Iag95EkF8gPf6tGEWqFqFIUNN9l5bk0FiHJB0NO7QsjOjqbceqdcy0N7P8XBKwOpb6bd9b9j6E1Awjp6Lhr3ZdOL80K3684MHY0QHBXQaRSMvYdOL8ayLcO)qch3O)ajtZQadHChOabcfHag95EkF8gPf6tGEWqFqFIUxTMvYJE5r098aAjpqL368kkpUzOmT8akpqhaZZMT8kLeeQqjJU3YkTnBwjY7DDJf15vm6pKWXn6l4MqHfuHoReP7bRcxMHOabIgaIag95EkF8gPf6pKWXn6hUmdvuNNf6tGEWqFqFXNhvitNsMSRAQHlZqf15zL368i6E1Awjp6Lhr3ZdOL8elV15vuECZqzA5buEuaaZZMT8kLeeQqjJU3YkTnBwjY7DDJf15vm6tOrESkgOmhgeiAqbcenAqaJ(djCCJ(eDxjAOJrFUNYhVrAHceiAedbm6Z9u(4nsl0Na9GH(G(Lscc1smyfviMu3yrn6pKWXn6l8O5TSYWqQChkWobm67DWqOe1a91GceiAafcy0N7P8XBKwO)qch3OF5BiGXsHcStaJ(eOhm0h0x85rfY0PKj7QMA5BiGXsHcStaJ(eAKhRIbkZHbbIguGc03eiGrGObbm6tgQHJB0N(MMWp0Na9GH(G(BCuHsgDVLvAB2SsK37A4eWElN368gs40XkUzlNn5TKNM8wNxr5j(8I5XDunmKBpOv5EkF8opB2YJGXVnwuxnmKBpOvHS14TjpGYdu5vm6pKWXn6dLm6ElR02SzLiV3Op3t5J3OsuGarmeWO)qch3OViDh(8wwTHJmUvuLAIo6Z9u(4nsluGabuiGrFUNYhVrAH(djCCJ(q34TSYi1kWobm6tGEWqFq)IYJGXVnwuxfCtyuybLGeKwfYwJ3M8akpXYZMT8i6EEaTKhfYZMT8gkMHEWvJixiuqSuV1XsgUcNgCEaLNy5vm6tOrESkgOmhgeiAqbceqhbm6Z9u(4nsl0Na9GH(G(LsccvOKr3BzL2MnRe59UUXI68wNh3muMwnClwfyL1SsEaLNM8wN3qcNowXnB5SjpGYtd6pKWXn6dLm6ElR02SzLiV3OabcfqaJ(CpLpEJ0c9jqpyOpOp3muMwnClwfyL1SsEaLNyvkK368kkVHIzOhC1iYfcfel1BDSKHRWPbNN95bQ8SzlVIYJGXVnwuxfP7WN3YQnCKXTIQut0Rq2A82KN95PbG5ToVyEChvr6o85TSAdhzCROk1e9k3t5J35vCE2SL3qcNowXnB5SjpGYttEfJ(djCCJ(cUjmkSGsqcsdfiqaqeWOp3t5J3iTqFc0dg6d6t098SFjpXYBDEfLxPKGqfkz09wwPTzZkrEVRBSOopB2YJBgktlpGYd0bW8kg9hs44g9fCtOWcQqNvI09GvHlZquGar7Iag95EkF8gPf6tGEWqFqFIUNN9l5bQ8wNh3muMwE2Nhfai6pKWXn6ZndLDk2Bzf)8vCikqGaAqaJ(CpLpEJ0c9hs44g9lFdbmwkuGDcy0Na9GH(G(IppQqMoLmzx1ulFdbmwkuGDc48wNxr5rW43glQRq34TSYi1kWobCfYwJ3M8akpXYZMT8i6EEaTKhOYR48wNxr5rW43glQRcUjmkSGsqcsRczRXBtEaLNy5zZwEeDppGwYd0ZZMT8gkMHEWvJixiuqSuV1XsgUY9u(4DEfN368kLeeQgrUqOGyPERJLmC1edbCE2NNyOpHg5XQyGYCyqGObfiqOieWO)qch3Opr3vIg6y0N7P8XBKwOabIgaIag95EkF8gPf6tGEWqFqFIUxTMvYJE5r098aAjpn5ToVHeoDSIB2YztEl5PjpB2YJO7vRzL8OxEeDppGwYtm0FiHJB0NO7QsjOjqbcenAqaJ(CpLpEJ0c9hs44g9dxMHkQZZc9jqpyOpOV4ZJkKPtjt2vn1WLzOI68SYBDEeDVAnRKh9YJO75b0sEIL368kkVsjbHkuYO7TSsBZMvI8Ex3yrDE2SLh3muMwEaLhfaW8kg9j0ipwfduMddcenOabIgXqaJ(CpLpEJ0c9jqpyOpOpvitNsMSRAQLVHaglfkWobCERZJO75buEAYBDELsccvJixiuqSuV1XsgUAIHaop7Ztm0FiHJB0x4rZBzLHHu5ouGDcy037GHqjQb6Rbfiq0akeWOp3t5J3iTqFc0dg6d6ZndLPvd3IvbwznRKhq5jwLc5Topcg)2yrDf6gVLvgPwb2jGRq2A82Khq5jwERZRusqOAe5cHcIL6TowYWvtmeW5TKNyO)qch3OVGBcJclOeKG0qbkq)nlmsVabmceniGr)HeoUr)rkWQjIHag95EkF8gPfkqGigcy0FiHJB03qLhOsF6TYeqhmJ(CpLpEJ0cfiqafcy0N7P8XBKwOpb6bd9b9J5XDunmKBpOv5EkF8oV15rW43glQRggYTh0Qq2A82KN95bQ8wNh3muMwnClwfyL1SsEaLNM8wNxPKGqfkz09wwPTzZkrEVRBSOg9hs44g9HsgDVLvAB2SsK3BuGab0raJ(CpLpEJ0c9jqpyOpOV4ZlMh3rDvHXB1QEGwtL7P8XB037GH0np0NIai6tLekDEEHo6dWkfq)HeoUr)alr0vybf4bAnOabcfqaJ(CpLpEJ0c9jqpyOpOFmpUJ6QcJ3Qv9aTMk3t5J3OV3bdPBEOpfbq0Nkju688cD0xd6pKWXn6hyjIUclOapqRbfiqaqeWOp3t5J3iTqFc0dg6d6xkjiunmKBpOvLOMNnB5vkjiunbgAP4bg6QP3kbhYvjQ5zZwEfLN4ZlMh3r1WqU9GwL7P8X78wNxa9gmhvQqmPoY(ZdAvipKiVIZZMT8kLeeQLpmE)KmrfYdjYZMT8IbkZrnClwfy1258SFjpaeGO)qch3OpvC44gfiq0UiGrFUNYhVrAH(eOhm0h0VusqOAyi3EqRkrf9hs44g9jZ7Pgs44w9CtG(p3eQESy03WqU9GgkqGaAqaJ(CpLpEJ0c9jqpyOpOFr5XndLPvd3IvbwznRKN95PjpB2YRO8I5XDunmKBpOv5EkF8oV15rW43glQRggYTh0Qq2A82KN95jwEfNxX5TopIUxTMvYJE5r098aAjpqH(djCCJ(cUjuybvOZkr6EWQWLzikqGqriGrFUNYhVrAH(djCCJ(HlZqf15zH(eOhm0h0VO84MHY0QHBXQaRSMvYZ(80KNnB5vuEX84oQggYTh0QCpLpEN368iy8BJf1vdd52dAviBnEBYZ(8elVIZR48wNhr3RwZk5rV8i6EEaTKNy5TopXNhvitNsMSRAQHlZqf15zH(eAKhRIbkZHbbIguGardaraJ(CpLpEJ0c9hs44g9jZ7Pgs44w9CtG(p3eQESy0NSrbcenAqaJ(CpLpEJ0c9jqpyOpOFr5nKWPJvCZwoBYZ(8a98wN3qXm0dUAe5cHcIL6TowYWv40GZZ(8avEfNNnB5nKWPJvCZwoBYZ(8Oa6pKWXn6tM3tnKWXT65Ma9FUju9yXOVjqbcenIHag95EkF8gPf6tGEWqFq)IYBiHthR4MTC2Khql5b65ToVHIzOhC1iYfcfel1BDSKHRWPbNN95bQ8kopB2YBiHthR4MTC2Khql5rb0FiHJB0NmVNAiHJB1Znb6)CtO6XIr)bZOafOa9PJHgh3iqedGAanae0igfv1qbXOi0x0aBVLnO)QbAxfq0(bzvbaYlpG158ClQyyKNagMha8MfgPxaaNhKP)LCiVZZGT48gPaBnbVZJOpTmBQzbTpV580aaYJ(tBKOsfddEN3qch35bapsbwnrmeWaW1Sqwq73Ikgg8opamVHeoUZ75MWuZcO)if6yi6)Dl6d9PcXc(JrFXL3Q59w08aZW80o4gCwqC5PhbvdaaqaL9qxQSsWwaAClP3eoUjWria04wealF4salfg6Tz6aKkel4p2a4Qd5vz8TbWvFvuAhCdwTAEVfnpWmSAClswqC59zQbBvYW80qzEIbqnGM8OxEAxaaOayERU2jlKfexE0N(0YSbaKfexE0lVvHTW0X78iJj8wopIotaNNaeBL3NkpW8aGm9oVFaDWCEfPp9(X788oyypVhT8kPLxOZ5n7nUlUMfexE0lp6tFAzENxmqzouUqEgADmRKxGZJqJ8yvmqzom5vumqzouUqEnoYZirLkgg8oVsA5n7nUlUMfexE0lp6tFAzENh9JmnHFQsjbb6xEboVvrYO7TCEfMnN3Q59oVaN32nt5JZJmnHFVjCCNhwiVqNZBvkSA5vkjiKNiDUZdYHeS9woVaN3h4AE5r)flLhz68Gm94EkFCEHUBYRKwEeDMa2B580E9u(4DE4oVqNZtWHMipUdiT88oVqNZJ(zc6xEdjCCN3ZnrnlKfexEGGd2aaYcIlp6LhW6CEVjytKNe19eCEqMkKnChM8M8SgTHH5bAxDTV8GSiOhCEcqSvEHoN33TKEt44M(GJqKxWJvEf14iplw8fxZczbXLN2BfMif8oVswad58iyRYjYRKL92uZd0sim1WKxJB6PpqlbPxEdjCCBYd3pA1SWqch3MkvitWwLtSi8gd4SWqch3MkvitWwLty3cGcy8olmKWXTPsfYeSv5e2Ta4ijBXDmHJ7SG4Y73dvJooYdo(oVsjbbENNjMWKxjlGHCEeSv5e5vYYEBYB6DEuHm9OIJWB58CtEBCZ1SWqch3MkvitWwLty3cGMEOA0XHYetyYcdjCCBQuHmbBvoHDlasfhoUZcdjCCBQuHmbBvoHDlas0DvPe0eu6clfj(yEChvdd52dAvUNYhVTzt8X84oQcUjuybvOZkr6EWQWLzyL7P8X7IZcdjCCBQuHmbBvoHDlas0DLOHoolKfexEAVvyIuW78y6yiT8c3IZl058gsGH55M8g6g)nLpUMfgs442SmsbwnrmeWzHHeoUn2TaOHkpqL(0BLjGoyolmKWXTXUfaHsgDVLvAB2SsK3BkDHLyEChvdd52dAvUNYhVxtW43glQRggYTh0Qq2A82ypOwZndLPvd3IvbwznRaKM1LsccvOKr3BzL2MnRe59UUXI6SG4YdySerppSqER6bAn5H78iy8BJf1uMNlK3QcJ35TQhO1KNBYJ7P8X78y6FP5LxGZtdabiau5HfYZAwXTKSYtNNxONfgs442y3cGbwIORWckWd0AO07GH0nVfkcGusLekDEEH(caRuGsxyr8X84oQRkmERw1d0AQCpLpEtP3bdPBElueaPKkju688c9fawPqwyiHJBJDlagyjIUclOapqRHsVdgs38wOiasjvsO055f6lAO0fwI5XDuxvy8wTQhO1u5EkF8MsVdgs38wOiasjvsO055f6lAYcIlVvhhoUZZfY7ZqU9GwEyyE)adTOmpT3adDkZB6DEaq7qoVbY5jrnpmmpAyP8giNhuQBVLZZWqU9GwEtVZBYZA8optmrEb0BWCKhviMyOmpmmpAyP8giNNuVzyEHoNhliWKipSqELpmE)KmbL5HH5fduMJ8c3IZlW5TDop3KNmKNGH5HH5X0)sZlVaNhacWSWqch3g7waKkoCCtPlSukjiunmKBpOvLOAZwPKGq1eyOLIhyORMEReCixLOAZwrIpMh3r1WqU9GwL7P8X71b0BWCuPcXK6i7ppOvH8qIITzRusqOw(W49tYevipKWMTyGYCud3IvbwTD2(faeGzHHeoUn2TaizEp1qch3QNBck7XIxmmKBpOrPlSukjiunmKBpOvLOMfgs442y3cGcUjuybvOZkr6EWQWLziLUWsrCZqzA1WTyvGvwZk2RXMTII5XDunmKBpOv5EkF8EnbJFBSOUAyi3EqRczRXBJ9IvCXRj6E1AwHEeDhOfqLfgs442y3cGHlZqf15zrjHg5XQyGYCyw0qPlSue3muMwnClwfyL1SI9ASzROyEChvdd52dAvUNYhVxtW43glQRggYTh0Qq2A82yVyfx8AIUxTMvOhr3bArS1INkKPtjt2vn1WLzOI68SYcdjCCBSBbqY8EQHeoUvp3eu2JfVq2zbXLh9nVxEHoN3h48gs44oVNBI8CH8cDgY5nqopqLhgM3JnM84MTC2Kfgs442y3cGK59udjCCREUjOShlEXeu6clfnKWPJvCZwoBSh0xpumd9GRgrUqOGyPERJLmCfony7bvX2SnKWPJvCZwoBSNczbXLh9nVxEHoNhOfR9YBiHJ78EUjYZfYl0ziN3a58SWqoVqF68avECZwoBYcdjCCBSBbqY8EQHeoUvp3eu2JfVmyMsxyPOHeoDSIB2YzdqlG(6HIzOhC1iYfcfel1BDSKHRWPbBpOk2MTHeoDSIB2YzdqluilKfexEGws442ubTyTxEUjpVdU38opbmmpjdNNip0ZdactcNOaT7TI(E8qhN3078isqi3XJwEnZBtEboVsopm1WTCkM3zHHeoUn1bZlI0D4ZBz1goY4wrvQj6zHHeoUn1bZ2Tai3mu2PyVLv8ZxXHu6clINkKPtjt2vn1WLzOI68Swt0D7x0SMBgktZEkaWSWqch3M6Gz7wauWnHrHfucsqAu6clCZqzA1WTyvGvwZkajwLczHHeoUn1bZ2TaiuYO7TSsBZMvI8EtPlSukjiuHsgDVLvAB2SsK376glQxZndLPvd3IvbwznRaKMSWqch3M6Gz7wae6gVLvgPwb2jGPKqJ8yvmqzomlAO0fwkkMh3rvKUdFElR2Wrg3kQsnrVY9u(49Acg)2yrDvKUdFElR2Wrg3kQsnrVczRXBJ9YKDXRjy8BJf1vb3egfwqjibPvHS14TbiqLfgs442uhmB3cGgQE3ElRiWPzfyNaMsxyr8uHmDkzYUQPAO6D7TSIaNMvGDc4SWqch3M6Gz7waKO7QsjOjO0fwi6U9lGklmKWXTPoy2UfahizAwfyiK7GsxyHO7vRzf6r0DGw0SMBgktRgUfRcSYAwbOfawPqwyiHJBtDWSDlak4MqHfuHoReP7bRcxMHu6cleDVAnRqpIUd0cOwxe3muMgqGoaAZwPKGqfkz09wwPTzZkrEVRBSOU4SWqch3M6Gz7wamCzgQOoplkj0ipwfduMdZIgkDHfXtfY0PKj7QMA4YmurDEwRj6E1AwHEeDhOfXwxe3muMgquaaTzRusqOcLm6ElR02SzLiV31nwuxCwyiHJBtDWSDlas0DLOHoolmKWXTPoy2UfafE08wwzyivUdfyNaMsxyPusqOwIbROcXK6glQP07GHqjQXIMSWqch3M6Gz7waS8neWyPqb2jGPKqJ8yvmqzomlAO0fwepvitNsMSRAQLVHaglfkWobCwiliU8Opm(TXIAtwyiHJBtLSx8MomywTIe3QqNvI09GvHlZWSWqch3MkzB3cGsgw5bBrzpw8YtYeqSKrjJFBUvuFswJmNfgs442ujB7waS8HXBLGeKwwyiHJBtLSTBbWsgAyiyVLZcIlp6pgopqlKmnNhWyiK7ipxipAyP8giNNLBmElN3e594Xe5Pjp6t3ZB6DEIWnaCKhzOMh3muMwEI8q378ayLc5zycU3MSWqch3MkzB3cGdKmnRcmeYDqPlSq09Q1Sc9i6oqlAwZndLPvd3IvbwznRa0caRuilmKWXTPs22Ta4ZL1dJsBsBzlUJSWqch3MkzB3cGcoKlFy8olmKWXTPs22Ta40e2eW5PiZ7Lfgs442ujB7wamWseDfwqT5j0P0fwIbkZrnClwfy12zGOOSWqch3MkzB3cGMadTu8adD10BLGdzkDHfcg)2yrD1eyOLIhyORMEReCixj6duMnlIzZwrem(TXI6QGBcJclOeKG0Qq2A82y)caUMO7aTaQ1em(TXI6k0nElRmsTcStaxHS14TX(fnfBZwmqzoQHBXQaR2oB)IgkKfgs442ujB7wa0WqU9GgLUWcbJFBSOUcDJ3YkJuRa7eWviBnEBSFrmB2IbkZrnClwfy12z7x0iwwiliU8(mKBpOLhvOJHEqllmKWXTPAyi3EqBb6gVLvgPwb2jGPKqJ8yvmqzomlAYcdjCCBQggYTh0SBbqb3egfwqjibPrPlSuuPKGqT8HX7NKjQsuxtfY0PKj7QMk0nElRmsTcStaVw8dfZqp4QrKlekiwQ36yjdx5EkF8UyB2kLeeQggYTh0Qq2A82yVgB2gs40XkUzlNnaPjlmKWXTPAyi3EqZUfanu9U9wwrGtZkWobmLUWI4Pcz6uYKDvt1q172BzfbonRa7eWRlAiHthR4MTC2a0cOSzROHeoDSIB2YzZIyRPcz6uYKDvtT8neWyPqb2jGlU4SWqch3MQHHC7bn7waS8neWyPqb2jGPKqJ8yvmqzomlAYczbXL33B5hNxmqzoYdW8OVhp0X5rf6yOh0YcdjCCBQMWUfaHsgDVLvAB2SsK3BkDHLnoQqjJU3YkTnBwjY7DnCcyVLxpKWPJvCZwoBw0SUiXhZJ7OAyi3EqRY9u(4TnBem(TXI6QHHC7bTkKTgVnabQIZcdjCCBQMWUfafP7WN3YQnCKXTIQut0ZcdjCCBQMWUfaHUXBzLrQvGDcykj0ipwfduMdZIgkDHLIiy8BJf1vb3egfwqjibPvHS14TbiXSzJO7aTqbB2gkMHEWvJixiuqSuV1XsgUcNgmqIvCwyiHJBt1e2TaiuYO7TSsBZMvI8EtPlSukjiuHsgDVLvAB2SsK376glQxZndLPvd3IvbwznRaKM1djC6yf3SLZgG0Kfgs442unHDlak4MWOWckbjinkDHfUzOmTA4wSkWkRzfGeRsH1fnumd9GRgrUqOGyPERJLmCfony7bLnBfrW43glQRI0D4ZBz1goY4wrvQj6viBnEBSxdaxhZJ7Oks3HpVLvB4iJBfvPMOx5EkF8UyB2gs40XkUzlNnaPP4SWqch3MQjSBbqb3ekSGk0zLiDpyv4YmKsxyHO72Vi26IkLeeQqjJU3YkTnBwjY7DDJf12SXndLPbeOdGfNfgs442unHDlaYndLDk2Bzf)8vCiLUWcr3TFbuR5MHY0SNcamlmKWXTPAc7waS8neWyPqb2jGPKqJ8yvmqzomlAO0fwepvitNsMSRAQLVHaglfkWob86Iiy8BJf1vOB8wwzKAfyNaUczRXBdqIzZgr3bAbufVUicg)2yrDvWnHrHfucsqAviBnEBasmB2i6oqlGUnBdfZqp4QrKlekiwQ36yjdx5EkF8U41LsccvJixiuqSuV1XsgUAIHa2EXYcdjCCBQMWUfaj6Us0qhNfgs442unHDlas0DvPe0eu6cleDVAnRqpIUd0IM1djC6yf3SLZMfn2Sr09Q1Sc9i6oqlILfgs442unHDlagUmdvuNNfLeAKhRIbkZHzrdLUWI4Pcz6uYKDvtnCzgQOopR1eDVAnRqpIUd0IyRlQusqOcLm6ElR02SzLiV31nwuBZg3muMgquaalolmKWXTPAc7wau4rZBzLHHu5ouGDcykDHfQqMoLmzx1ulFdbmwkuGDc41eDhinRlLeeQgrUqOGyPERJLmC1edbS9IrP3bdHsuJfnzHHeoUnvty3cGcUjmkSGsqcsJsxyHBgktRgUfRcSYAwbiXQuynbJFBSOUcDJ3YkJuRa7eWviBnEBasS1LsccvJixiuqSuV1XsgUAIHaErmuGceca]] )
end