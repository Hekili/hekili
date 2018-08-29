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

                return app + floor( t - app )
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

    --[[ spec:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, _, spellID )
        if unit ~= "player" then return end
    
        local key = class.abilities[ spellID ] and class.abilities[ spellID ].key
        if not key then return end

        if combos[ key ] then actual_combo = key end
    end ) ]]


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
            end
        end
    end )


    spec:RegisterHook( "runHandler", function( key, noStart )
        if combos[ key ] then
            if last_combo == key then removeBuff( "hit_combo" )
            else addStack( "hit_combo", 10, 1 ) end

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

    spec:RegisterStateExpr( "gcd", function () return 1.0 end )


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

    spec:RegisterPack( "Windwalker", 20180829.1529,
        [[d0eXZaqiKu9iaOUeqsKnjQ8jGKQrrv4uuP6vufnluu3IQK2Li)cfzyiPCmuyzuL6zaOPjvrxdi12KQW3aamoQs05OsH1rvcmpQKUNuzFIQoiaKfsL4HuLqteij4IaGAJajP(iqsYibskDsQsqRuQQxsLIYmPsr1nbsk2ja9tGKOgkaqlLkfPNQstfiUkqsOVcaYEH8xunyvDyflwuEmIjlLltSzK6ZuXOjPttz1uP0RbQzRIBtvTBj)g0WrPoovkILd1Zj10fUoj2osY3rIXlvPZJswpqI5dO9R0igiqq32eccqVPgdVKAEP3UrIbO92n82nq3GfBbDzpeWJJGU14lOlaKvnkZbSGrx2dRdCAiqqxnubte0vnc2AVaMyYXcvLSeb6ZK28votyWIGh6GjT5tyk7aZykJE8AtOIj2yiTDentaGyXnDSMMjaq3uoOgybMdazvJYCal4K28jOBMIDcVWcLHUTjeeGEtngEj18sVDJedq7TBWWnqxnBHGa07E4gOBt0e0fevtVVP3puL9Bc9OCI9bGSQrzoGf8(djmyTp7HaEFAiEFxMioY(0q8(aiqrWWqnT93(GOA69n9(zJwA7dR9dvzFaiRAuMdybVpaca0nFFAm0F)R5RCMWGLxep0bZ7NPe7tXc191qFzFPzHE)aUV5ZgdPs2xOPnIjfH1(wTFOk7tGvi9g7dP3puL9NwdwPT)23R77fvNYrA7hd2rcUrVpbwnlmyP3pG7ROL9jSihHhd2rc9(Eed2rcUrVFbJ91kSzdXH0CpT996(Er1PCK2(K5C4djmyXpMo2xQaBIEFAiEFaeOYaW7tLoT)fK9d4(yLIpKWGf)y6yFPcSjAM3xBfr2hwhw7dlzFk25SFMSVwocjK2(t12pufw7pyzFFLqzohw7l9sokAJkjT996(Gky6j7iT9bvFyzLZ(xbZwQyF3mJaE)MISFa33hsL4lvK2(EDFqnqQK2(x2YG3hu7uT9Vb2al7hW9di79H073e6r5e7dGaaDZtO7X0Hgbc6sAiqqaYabc6oKWGf6AfvqWcVxfPqxPMSJ0qUGceGEJabDhsyWcDZoqyJtRGzHUsnzhPHCbfiabice0DiHbl0ntWAbd2kh0vQj7inKlOabyprGGUsnzhPHCbDjyleSnOlr1s(tV7719jQ2(572NX(52xkb7WkfMVWdi3F6D)8D7tTeOr3HegSq3btMs4beJLkqbcqqJabDhsyWcDpMJAO5UvP54lvGUsnzhPHCbfia7bce0DiHbl0L2Ws2bcBORut2rAixqbcqaaeiO7qcdwO7uerh45WjZ5GUsnzhPHCbfia9seiORut2rAixqxc2cbBd6gd2rIuy(cpG8Mj7NVBFVeDhsyWcDdOcrLdP5nzcvuGa0nqGGUsnzhPHCbDjyleSnOlbcpniLkPdi2Nldou5t140gwse1b7i6972379bcCFp2NaHNgKsLOnDO5qAoTcMvcl(Jv69DTB)ESFU9jQ2(572hG7NBFceEAqkvcBARC4ALId2iGtyXFSsVVRD7ZyF33hiW9Jb7irkmFHhqEZK9DTBFgGEFGa3NnwOI7qAjgPaQqu5qAEtMqfDhsyWcD1be7ZLbhQ8PACAdlOabidQHabDLAYosd5c6sWwiyBqxceEAqkvcBARC4ALId2iGtyXFSsVVRD73J9bcC)yWosKcZx4bK3mzFx72NH37de4(SXcvChslXifqfIkhsZBYeQO7qcdwORwWszbluGc0Lnwiq)SjqGGaKbce0vQj7inKlOabO3iqqxPMSJ0qUGceGaebc6k1KDKgYfuGaSNiqqxPMSJ0qUGceGGgbc6oKWGf6YgggSqxPMSJ0qUGceG9abc6k1KDKgYf0LGTqW2GUESp13pMJurslyPSGvsQj7iT9bcCFQVFmhPIeTPdoKMhQcNIQfcpmhbNKAYosBF3r3HegSqxIQXZuW6afiabaqGGUdjmyHUevJtzOsqxPMSJ0qUGcuGUduqGGaKbce0DiHbl0LIQHpw5WB4XbwC2kfrfDLAYosd5ckqa6nce0vQj7inKlOlbBHGTbDP((SXcvChslXifMJG5SNJ)(52NOA77A3(m2p3(sjyhw776(GMAO7qcdwORuc2XafRC4YX61WOabiarGGUdjmyHU0Mo0CinNwbZcDLAYosd5ckqa2teiORut2rAixqxc2cbBd6MPqtNWkAvRC4UDAcNIvTudsP2p3(sjyhwPW8fEa5(tV7NFFgO7qcdwOlwrRALd3Ttt4uSQHceGGgbc6k1KDKgYf0DiHbl0fBARC4ALId2iGrxc2cbBd66X(XCKksuun8XkhEdpoWIZwPiQjPMSJ02p3(ei80GuQefvdFSYH3WJdS4SvkIAcl(Jv69DDFhsBF33p3(ei80GuQeTPdnhsZPvWSsyXFSsVF(9bi6syrocpgSJeAeGmqbcWEGabDLAYosd5c6sWwiyBqxIQTVRD7dq0DiHbl0LOA8mfSoqbcqaaeiORut2rAixqxc2cbBd6s99zJfQ4oKwIrsZ2QYkhobpLWbBeW7NBFp2NaHNgKsLOnDO5qAoTcMvcl(Jv69ZVVdPTpqG7tuT9Z3TpO33D0DiHbl0vZ2QYkhobpLWbBeWOabOxIabDLAYosd5c6oKWGf6MDgcyOsWbBeWOlbBHGTbD9yFp2NaHNgKsLWM2khUwP4Gnc4ew8hR07NFFg7NBFp2N67hZrQirB6GdP5HQWPOAHWdZrWjPMSJ02hiW9jq4PbPujAthCinpufofvleEyocoHf)Xk9(53NX(UVpqG7tuT9ZVFp3399ZTVh7tGWtdsPs0Mo0CinNwbZkHf)Xk9(53NX(abUpr12p)(aCF33hiW9zJfQ4oKwIrkmhbZzph)9DF)C7t99zJfQ4oKwIrk7meWqLGd2iGrxclYr4XGDKqJaKbkqa6giqqxPMSJ0qUGUeSfc2g0LOAj)P3996(evB)8D7dW9ZTVh7lLGDyTF(97zp2hiW9ZuOPtyfTQvoC3onHtXQwQbPu77o6oKWGf6sB6GdP5HQWPOAHWdZrWOabidQHabDLAYosd5c6oKWGf6gMJG5SNJp6sWwiyBqxQVpBSqf3H0smsH5iyo754VFU9jQwYF6DFVUpr12pF3(EVFU99yFPeSdR9ZVpO7X(abUFMcnDcROvTYH72PjCkw1sniLAF3rxclYr4XGDKqJaKbkqaYGbce0DiHbl0LOACkdvc6k1KDKgYfuGc0vlyPSGfceeGmqGGUsnzhPHCbDhsyWcDXM2khUwP4Gncy0LWICeEmyhj0iazGceGEJabDLAYosd5c6sWwiyBqxp2ptHMoLDGW2rrhjf27NBF2yHkUdPLyKWM2khUwP4Gnc49ZTp13FafbBHK0um6GJHkvtfQOLKut2rA77((abUFMcnDslyPSGvcl(Jv69DDFg7de4(djmQeUuIVj69ZVpd0DiHbl0L20HMdP50kywOabiarGGUsnzhPHCbDjyleSnOl13NnwOI7qAjgjnBRkRC4e8uchSraVFU9hsyujCPeFt07NVB)EIUdjmyHUA2wvw5Wj4PeoyJagfia7jce0vQj7inKlO7qcdwOB2ziGHkbhSraJUewKJWJb7iHgbiduGc0vhiqqaYabc6k1KDKgYf0LGTqW2GUnyKWkAvRC4UDAcNIvTuyeWw5SFU9hsyujCPeFt073TpJ9ZTVh7t99J5ivK0cwklyLKAYosBFGa3NaHNgKsL0cwklyLWI)yLE)87dW9DhDhsyWcDXkAvRC4UDAcNIvnuGa0BeiO7qcdwOlfvdFSYH3WJdS4SvkIk6k1KDKgYfuGaeGiqqxPMSJ0qUGUdjmyHUytBLdxRuCWgbm6sWwiyBqxceEAqkvI20HMdP50kywjS4pwP3p)(EVpqG7tuT9Z3TpO3hiW9hqrWwijnfJo4yOs1uHkAjHNc8(533B0LWICeEmyhj0iazGceG9ebc6k1KDKgYf0LGTqW2GUzk00jSIw1khUBNMWPyvl1GuQ9ZTVuc2HvkmFHhqU)07(53NX(52FiHrLWLs8nrVF(9zGUdjmyHUyfTQvoC3onHtXQgkqacAeiORut2rAixqxc2cbBd66X(dOiylKKMIrhCmuPAQqfTKWtbEFx3hG7de4(ESpbcpniLkrr1WhRC4n84aloBLIOMWI)yLEFx3Nba3p3(XCKksuun8XkhEdpoWIZwPiQjPMSJ02399bcC)HegvcxkX3e9(53NX(UJUdjmyHU0Mo0CinNwbZcfia7bce0vQj7inKlO7qcdwOlTPdoKMhQcNIQfcpmhbJUeSfc2g0LOA77A3(EVFU99y)mfA6ewrRALd3Ttt4uSQLAqk1(abUVuc2H1(53VN9yF3rxclYr4XGDKqJaKbkqacaGabDLAYosd5c6sWwiyBqxIQTVRD7dW9ZTVuc2H1(UUpOPg6oKWGf6kLGDmqXkhUCSEnmkqa6LiqqxPMSJ0qUGUdjmyHUzNHagQeCWgbm6sWwiyBqxQVpBSqf3H0smszNHagQeCWgb8(523J9jq4PbPujSPTYHRvkoyJaoHf)Xk9(53379bcCFIQTF(U9b4(UVFU99yFceEAqkvI20HMdP50kywjS4pwP3p)(EVpqG7tuT9Z3TFp3hiW9hqrWwijnfJo4yOs1uHkAjj1KDK2(UVFU9ZuOPtAkgDWXqLQPcv0sshdb8(UUV3OlHf5i8yWosOraYafiaDdeiO7qcdwOlr14ugQe0vQj7inKlOabidQHabDLAYosd5c6sWwiyBqxIQL8NE33R7tuT9Z3TpJ9ZT)qcJkHlL4BIE)U9zSpqG7tuTK)07(EDFIQTF(U99gDhsyWcDjQgptbRduGaKbdeiORut2rAixq3HegSq3WCemN9C8rxc2cbBd66X(uFF2yHkUdPLyKcZrWC2ZXFFGa3N67hZrQiPAbNa9ZGjPMSJ02399ZTpr1s(tV7719jQ2(572379ZTVh7NPqtNWkAvRC4UDAcNIvTudsP2hiW9LsWoS2p)(GUh77o6syrocpgSJeAeGmqbcqgEJabDLAYosd5c6oKWGf6sFyzLdxly2sfCWgbm6sWwiyBqx2yHkUdPLyKYodbmuj4Gnc49ZTpr12p)(m2p3(zk00jnfJo4yOs1uHkAjPJHaEFx33B01QqWyf2b6YafiazaqeiORut2rAixqxc2cbBd6sGWtdsPsytBLdxRuCWgbCcl(Jv69ZVV3jqVFU9ZuOPtAkgDWXqLQPcv0sshdb8(53NAO7qcdwOlTPdnhsZPvWSqbkq3MqpkNabccqgiqq3HegSq3rjG8jIHagDLAYosd5ckqa6nce0DiHbl0vZwgmxDQgxhydSGUsnzhPHCbfiabice0vQj7inKlOlbBHGTbDZuOPtAblLfSskSr3HegSqxYCo8HegS4hthO7X0bVgFbD1cwklyHceG9ebc6k1KDKgYf0LGTqW2GUXCKksAblLfSssnzhPTFU9jq4PbPujTGLYcwjS4pwP3319b4(52xkb7WkfMVWdi3F6D)87Zy)C7NPqtNWkAvRC4UDAcNIvTudsPq3HegSqxSIw1khUBNMWPyvdfiabnce0vQj7inKlOlbBHGTbDP((XCKksoqyJdEW(tsQj7iT9ZTVQmNqnXMe77A3(GMAORvHGPAoORBqn0Lnj4QYCcv0LAjqJUdjmyHUbuHOYH0CWd2FqbcWEGabDLAYosd5c6sWwiyBq3yosfjhiSXbpy)jj1KDKg6AviyQMd66gudDztcUQmNqfDzGUdjmyHUbuHOYH0CWd2FqbcqaaeiORut2rAixqxc2cbBd6MPqtN0cwklyLuyVpqG7NPqtN0be7ZLbhQ8PACAdljf27de4(ESp13pMJurslyPSGvsQj7iT9ZTFGTcSej2yijno2XcwjSmKyF33hiW9ZuOPtzhiSDu0rcldj2hiW9Jb7irkmFHhqEZK9DTB)Eqn0DiHbl0LnmmyHceGEjce0vQj7inKlOlbBHGTbD9yFPeSdRuy(cpGC)P39DDFg7de4(ESFmhPIKwWszbRKut2rA7NBFceEAqkvslyPSGvcl(Jv69DDFg77((UVFU9jQwYF6DFVUpr12pF3(aeDhsyWcDPnDWH08qv4uuTq4H5iyuGa0nqGGUsnzhPHCbDjyleSnORh7lLGDyLcZx4bK7p9UVR7ZyFGa33J9J5ivK0cwklyLKAYosB)C7tGWtdsPsAblLfSsyXFSsVVR7ZyF33399ZTpr1s(tV7719jQ2(5723B0DiHbl0nmhbZzphFuGaKb1qGGUsnzhPHCbDhsyWcDjZ5WhsyWIFmDGUhth8A8f0L0qbcqgmqGGUsnzhPHCbDjyleSnORh7pKWOs4sj(MO331975(52FafbBHK0um6GJHkvtfQOLeEkW776(aCF33hiW9hsyujCPeFt0776(GgDhsyWcDXkfFiHbl(X0b6EmDWRXxqxDGceGm8gbc6k1KDKgYf0LGTqW2GUES)qcJkHlL4BIE)8D73Z9ZT)akc2cjPPy0bhdvQMkurlj8uG3319b4(UVpqG7pKWOs4sj(MO3pF3(GgDhsyWcDXkfFiHbl(X0b6EmDWRXxq3bkOafOaDPsWAdwia9MAm8sQ5LEd6K3m6jd0LYGlRC0OlaeaYnfqVqabv5fS)(GOk7B(SH4yFAiEFq9MqpkNauFFS4MOyyPTVg6l7pkb0FcPTprDkhrN2(U5wj7ZWlyFqflTcB2qCiT9hsyWAFq9rjG8jIHagupT93(EH(SH4qA73J9hsyWA)JPdDA7JUJsOcXO7189IOlBmK2oc6cG3haUxHOesB)mHgIL9jq)Sj2ptCSsN2haric7qVFblVQoyFALZ(djmyP3hwhwPT)qcdw6eBSqG(zt0rFgn4T)qcdw6eBSqG(zt4zht0qyB7pKWGLoXgleOF2eE2X0O44lvmHbRTpaE)BnS1QWyF8yT9ZuOPL2(6yc9(zcnel7tG(ztSFM4yLE)PA7ZglELnmcRC23073GLK2(djmyPtSXcb6NnHNDmPRHTwfgCDmHE7pKWGLoXgleOF2eE2XeByyWA7pKWGLoXgleOF2eE2Xer14zkyDWSr35b1J5ivK0cwklyLKAYosdiqQhZrQirB6GdP5HQWPOAHWdZrWjPMSJ0CF7pKWGLoXgleOF2eE2Xer14ugQKT)(BFa8(aW9keLqA7lujyw7hMVSFOk7pKaI3307pun2zYosA7pKWGLUBuciFIyiG3(djmyP9SJjnBzWC1PACDGnWY2FiHblTNDmrMZHpKWGf)y6G5A8LoTGLYcwmB0Dzk00jTGLYcwjf2B)HegS0E2XewrRALd3Ttt4uSQXSr3fZrQiPfSuwWkj1KDKwoceEAqkvslyPSGvcl(JvAxbyoPeSdRuy(cpGC)P38mYLPqtNWkAvRC4UDAcNIvTudsP2(a49bbQqu3hsVVB2G9N9H1(ei80GukM33O3hufe223nBW(Z(MEFPMSJ02xCtuMZ(bCFguJAGkTpKEF)PxZxXFFvzoH62FiHblTNDmfqfIkhsZbpy)HzRcbt1C6CdQXmBsWvL5eQDulbAMn6oQhZrQi5aHno4b7pjPMSJ0YPkZjutSjHRDGMAB)HegS0E2XuaviQCinh8G9hMTkemvZPZnOgZSjbxvMtO2XGzJUlMJurYbcBCWd2FssnzhPT9bW7dacddw7B07FfSuwWAFiE)BaX(mVpa8GdvM3FQ2(GQnSS)GL9vyVpeVplOY(dw2hRuLvo7RfSuwWA)PA7p77pwTVoMy)aBfyj2Nngs0mVpeVplOY(dw2xPAcE)qv2xOPfsSpKE)Sde2ok6G59H49Jb7iX(H5l7hW9BMSVP33blti49H49f3eL5SFa3VhuB7pKWGL2ZoMydddwmB0Dzk00jTGLYcwjf2abMPqtN0be7ZLbhQ8PACAdljf2ab6b1J5ivK0cwklyLKAYoslxGTcSej2yijno2XcwjSmKWDGaZuOPtzhiSDu0rcldjacmgSJePW8fEa5ntCTRhuB7pKWGL2ZoMOnDWH08qv4uuTq4H5iyMn6opKsWoSsH5l8aY9NEDLbqGEeZrQiPfSuwWkj1KDKwoceEAqkvslyPSGvcl(JvAxz4U75iQwYF61RevlFha3(djmyP9SJPWCemN9C8z2O78qkb7WkfMVWdi3F61vgab6rmhPIKwWszbRKut2rA5iq4PbPujTGLYcwjS4pwPDLH7UNJOAj)PxVsuT8DEV9hsyWs7zhtK5C4djmyXpMoyUgFPJ02(djmyP9SJjSsXhsyWIFmDWCn(sNoy2O78yiHrLWLs8nr7ApZnGIGTqsAkgDWXqLQPcv0scpfyxbO7aboKWOs4sj(MODf0B)HegS0E2XewP4djmyXpMoyUgFPBGcZgDNhdjmQeUuIVj68D9m3akc2cjPPy0bhdvQMkurlj8uGDfGUde4qcJkHlL4BIoFhO3(7V9bW77fHWtdsP0B)HegS0jsRZkQGGfEVksXdvHtr1cHhMJG3(djmyPtKMNDmLDGWgNwbZA7pKWGLorAE2XuMG1cgSvoB)HegS0jsZZoMgmzkHhqmwQGzJUJOAj)PxVsuT8DmYjLGDyLcZx4bK7p9MVJAjqV9hsyWsNinp7y6yoQHM7wLMJVuX2FiHblDI08SJjAdlzhiST9hsyWsNinp7yAkIOd8C4K5C2(djmyPtKMNDmfqfIkhsZBYeQmB0DXGDKifMVWdiVzs(oVC7pKWGLorAE2XKoGyFUm4qLpvJtByHzJUJaHNgKsL0be7ZLbhQ8PACAdljI6GDeDN3ab6bbcpniLkrB6qZH0CAfmRew8hR0U21JCevlFhaZrGWtdsPsytBLdxRuCWgbCcl(JvAx7y4oqGXGDKifMVWdiVzIRDmanqGSXcvChslXifqfIkhsZBYeQB)HegS0jsZZoM0cwklyXSr3rGWtdsPsytBLdxRuCWgbCcl(JvAx76bqGXGDKifMVWdiVzIRDm8giq2yHkUdPLyKcOcrLdP5nzc1T)(BFa8(xblLfS2Nn2GylyT9hsyWsN0cwkly1HnTvoCTsXbBeWmtyrocpgSJe6ogB)HegS0jTGLYcwE2XeTPdnhsZPvWSy2O78itHMoLDGW2rrhjf25yJfQ4oKwIrcBARC4ALId2iGZr9bueSfsstXOdogQunvOIwssnzhP5oqGzk00jTGLYcwjS4pwPDLbqGdjmQeUuIVj68m2(djmyPtAblLfS8SJjnBRkRC4e8uchSraZSr3rD2yHkUdPLyK0STQSYHtWtjCWgbCUHegvcxkX3eD(UEU9hsyWsN0cwkly5zhtzNHagQeCWgbmZewKJWJb7iHUJX2F)TpaE)Rvohz)yWosSpt7toYqLSpBSbXwWA7pKWGLoPJoSIw1khUBNMWPyvJzJURbJewrRALd3Ttt4uSQLcJa2kNCdjmQeUuIVj6og58G6XCKksAblLfSssnzhPbeibcpniLkPfSuwWkHf)XkDEa6(2FiHblDshE2XefvdFSYH3WJdS4SvkI62FiHblDshE2Xe20w5W1kfhSraZmHf5i8yWosO7yWSr3rGWtdsPs0Mo0CinNwbZkHf)XkDEVbcKOA57anqGdOiylKKMIrhCmuPAQqfTKWtboV3B)HegS0jD4zhtyfTQvoC3onHtXQgZgDxMcnDcROvTYH72PjCkw1sniLkNuc2HvkmFHhqU)0BEg5gsyujCPeFt05zS9hsyWsN0HNDmrB6qZH0CAfmlMn6opgqrWwijnfJo4yOs1uHkAjHNcSRaeiqpiq4PbPujkQg(yLdVHhhyXzRue1ew8hR0UYaG5I5ivKOOA4Jvo8gECGfNTsrutsnzhP5oqGdjmQeUuIVj68mCF7pKWGLoPdp7yI20bhsZdvHtr1cHhMJGzMWICeEmyhj0Dmy2O7iQMRDENZJmfA6ewrRALd3Ttt4uSQLAqkfqGsjyhw57zpCF7pKWGLoPdp7yskb7yGIvoC5y9AyMn6oIQ5AhaZjLGDy5kOP22FiHblDshE2Xu2ziGHkbhSraZmHf5i8yWosO7yWSr3rD2yHkUdPLyKYodbmuj4Gnc4CEqGWtdsPsytBLdxRuCWgbCcl(Jv68Edeir1Y3bq3Z5bbcpniLkrB6qZH0CAfmRew8hR059giqIQLVRNaboGIGTqsAkgDWXqLQPcv0ssQj7in3ZLPqtN0um6GJHkvtfQOLKogcyx9E7pKWGLoPdp7yIOACkdvY2FiHblDshE2Xer14zkyDWSr3ruTK)0RxjQw(og5gsyujCPeFt0DmacKOAj)PxVsuT8DEV9hsyWsN0HNDmfMJG5SNJpZewKJWJb7iHUJbZgDNhuNnwOI7qAjgPWCemN9C8bcK6XCKksQwWjq)mysQj7in3ZruTK)0RxjQw(oVZ5rMcnDcROvTYH72PjCkw1sniLciqPeSdR8GUhUV9hsyWsN0HNDmrFyzLdxly2sfCWgbmZgDhBSqf3H0smszNHagQeCWgbCoIQLNrUmfA6KMIrhCmuPAQqfTK0Xqa7Q3mBviySc7OJX2FiHblDshE2XeTPdnhsZPvWSy2O7iq4PbPujSPTYHRvkoyJaoHf)XkDEVtGoxMcnDstXOdogQunvOIws6yiGZtTT)(BFa8(aisyWsNaqqa49n9(wfs1K2(0q8(kAzFkwOUpOwHegHdGAnUx8idvY(t12NOGXsfhw7xI007hW9ZK9HSdZ3afPT9hsyWsNgO0rr1WhRC4n84aloBLIOU9hsyWsNgO4zhtsjyhduSYHlhRxdZSr3rD2yHkUdPLyKcZrWC2ZXphr1CTJroPeSdlxbn12(djmyPtdu8SJjAthAoKMtRGzT9hsyWsNgO4zhtyfTQvoC3onHtXQgZgDxMcnDcROvTYH72PjCkw1sniLkNuc2HvkmFHhqU)0BEgB)HegS0PbkE2Xe20w5W1kfhSraZmHf5i8yWosO7yWSr35rmhPIefvdFSYH3WJdS4SvkIAsQj7iTCei80GuQefvdFSYH3WJdS4SvkIAcl(JvAxDin3ZrGWtdsPs0Mo0CinNwbZkHf)XkDEaU9hsyWsNgO4zhtevJNPG1bZgDhr1CTdGB)HegS0PbkE2XKMTvLvoCcEkHd2iGz2O7OoBSqf3H0smsA2wvw5Wj4PeoyJaoNhei80GuQeTPdnhsZPvWSsyXFSsN3H0acKOA57aT7B)HegS0PbkE2Xu2ziGHkbhSraZmHf5i8yWosO7yWSr35Hhei80GuQe20w5W1kfhSraNWI)yLopJCEq9yosfjAthCinpufofvleEyocoj1KDKgqGei80GuQeTPdoKMhQcNIQfcpmhbNWI)yLopd3bcKOA57P758GaHNgKsLOnDO5qAoTcMvcl(Jv68macKOA5bO7abYgluXDiTeJuyocMZEo(UNJ6SXcvChslXiLDgcyOsWbBeWB)HegS0PbkE2XeTPdoKMhQcNIQfcpmhbZSr3ruTK)0RxjQw(oaMZdPeSdR89ShabMPqtNWkAvRC4UDAcNIvTudsPCF7pKWGLonqXZoMcZrWC2ZXNzclYr4XGDKq3XGzJUJ6SXcvChslXifMJG5SNJFoIQL8NE9kr1Y35DopKsWoSYd6EaeyMcnDcROvTYH72PjCkw1sniLY9T)qcdw60afp7yIOACkdvckqbcb]] )
end