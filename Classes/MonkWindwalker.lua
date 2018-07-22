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
                return x < 4
            end,

            interval = 1,
            value = -4,
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


    combos = {
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
    }

    local actual_combo, virtual_combo

    spec:RegisterStateExpr( "last_combo", function () return virtual_combo or actual_combo end )

    spec:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, _, spellID )
        if unit ~= "player" then return end
    
        local key = class.abilities[ spellID ] and class.abilities[ spellID ].key
        if not key then return end

        if combos[ key ] then actual_combo = key end
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


    -- Recheck wrappers are apparently a thing we do now to account for time-sensitive APL criteria...
    local apl = setfenv( function( ... ) return cooldown.serenity.remains, cooldown.storm_earth_and_fire.full_recharge_time, cooldown.storm_earth_and_fire.remains, cooldown.fists_of_fury.remains - 12, cooldown.fists_of_fury.remains - 6, cooldown.rising_sun_kick.remains - 1, ... end, state )


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

            recheck = function () return apl( cooldown.energizing_elixir.remains - cooldown.fists_of_fury.remains ) end,
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
            
            recheck = apl,
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

            recheck = apl,
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

            recheck = function () return apl( cooldown.serenity.remains - 13 ) end,
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
            
            usable = function () return apl( cooldown.rising_sun_kick.remains, cooldown.fist_of_the_white_tiger.remains ) end,
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
            
            recheck = function () return apl( buff.pressure_point.remains - 2, buff.serenity.remains - 1, apl( cooldown.serenity.remains - 4 ) ) end,
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
            
            recheck = apl,
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

            recheck = function () return apl( energy.time_to_40 ) end,
            handler = function ()
                applyDebuff( 'target', 'mark_of_the_crane' )
                removeBuff( 'pressure_point' )
            end,
        },
        

        roll = {
            id = 109132,
            cast = 0,
            charges = function () return talent.celerity.enabled and 2 or 1 end,
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
                local x = 6 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            gcd = "spell",
            
            spend = function ()
                if buff.rushing_jade_wind.up then return 0 end
                return 4
            end,
            spendPerSec = function ()
                if buff.rushing_jade_wind.up then return 0 end
                return 4
            end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 606549,

            talent = "rushing_jade_wind",
            nobuff = "rushing_jade_wind",
            
            cycle = "mark_of_the_crane",

            recheck = apl,
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
            
            recheck = apl,
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
            
            recheck = apl,
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
            
            recheck = apl,
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

            recheck = function () return apl( energy.time_to_max, energy.time_to_max - 1, energy.time_to_max - 3, buff.serenity.remains ) end,
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

            recheck = function () return apl( cooldown.serenity.remains - 1, cooldown.storm_earth_and_fire.remains - 1, cooldown.fists_of_fury.remains - 4, cooldown.rising_sun_kick.remains - 7 ) end,
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
            recheck = apl,
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

    spec:RegisterPack( "Windwalker", 20180722.1314, 
        [[dWeNJbqic4rkvvjBcH(KsvvzuIiNse1ReHMfc6weOSls9lQOggbYXevltuYZuQY0eLQRrfY2uQk9nLQIXjkLCorPyDkvvH5jcUhvzFsvoivOOfsf5HIsPmrrPuLlsfkHnsfk0hPcLOtQuvvTscYlPcLYmPcLQBQuvfTte4NkvvPgQOuQQLsfkPNc0ujOUQOuQ0xPcfCwrPuXEr6VGgmrhwXIvkpwvtgWLrTzc9zenAPYPPSALQkVwjnBPCBQ0UL8BOgUiDCQq1Yv55KmDHRtvTDLkFxumEQGZReRNavZxQQ9dzAovykiWemLGSeuE2sq7twzPZ3lp77rbJLuMcMo)6qYuWACzkOJbRaYmTv(OGPZsdpauHPGkS)9mfSlIu1(dNDM0Io)n9JDDwzU(TjmC93igoRm335TgEZ5nXrWa4DoNEyrRXkNf24lRCNfoRC4(tCTcDmyfqMPTYNwzUpfCZ3AX(Fr3OGatWucYsq5zlbTpzLLoFpbTp7LffuLYpLGS23SHccWQNckCNPqstHKrhJKaS443cK0XGvazM2kFi58HHlKmD(vKueFiPttengjfXhs6yk48HJonsiKqogCmDSsW(pbowU)ajrYSDW(i5CmssITIejdmsUXiPY)sptXaiz0nbsUG93)ogjjXwrIKbgj9vms6uB(vSFGKo2SFfjJm2ZiPvi5GKhodsQWUCyUSsJKiPJjs2WHgjrsN4F8vms6uB(vSFGKo2SFfjnfscyQ0dNIVWW1eCBbjvXHlsK0kKm4ZvHKyrKeyChsgjt5dj)otJKi5()(NlsM6hHvKiz0zkKmZCLvKizhFmsUX)4RyKCb7V)DmssITIejdmsECk(cK0cKCui5GKB(Ki5uai5(psoUijj2ksKmWi5FlAKqiHqcT)0k8HKdW(5RcxUcfsMHpgjDhagjfpSlsgDmscAU(TjmCLTDJyGKoMz77yhjBwTYaijUqYOJrY0dlAngjJztJecju2w3uKmasgZrYb0erYhxawy4AAkKmWi5V8nggZrYHcjtkMJKdOjIKMcjlCGKk)0u8fmqYAKqiHCSYU4Dmasc4N2SFcBhJKoM7VDSajNcajbfgjNpmCHKntfi5pTMcjfpSlscYhxwSGKZhgUqYMPcnsiKqzBDtrYaiz220AiPJ5hgUqsh7MkqsUIZyfskIpK0XC)TJfi5uaijOWizGrshR(fs6y(HHlK0XUPcKuz1Ziz0Xli5Cms66h(tRTGKSdFZxz7ynsiKqz7wpUaSWW10qsNAZVI9dK0XM9RiPlgWengajdms(D8VIKognvOqsSis6y0)w2)uiz2w2Ei5uai57Fhxbs(DgHizGrYzh2aqsaUnlwrIKogXog1uWMPcfvykOIpUSybIt5IpQWucYPctb5A2Ama1jk4FwWNnuqbqY0J3bjFaDUoms(GPtZfjjIKcGKPhVds(a6Cnx8rAcUvKqUzoyhssej5IpYfK0dj5IpYfT74assej)odjtajZrsIiPai5MVOOwXhxwSO9trsIi5JXnaCMslAQqbXIqr)BrFS7yLcjtWdjfefC(WWffmms(GPtZLc(lFJHXCKCOOeKtdkbzrfMcY1S1yaQtuW)SGpBOGFNPDhhqsbdj)odj75HK5ijrKKl(ix0H5YWadDhhqYEEiPG0oIcoFy4Ico3pfdd8DCf0GsWEuHPGCnBngG6efC(WWff8NwdoFy4c2mvqb)Zc(SHc(yCdaNP0IMkuqSiu0)w0h7owPqYEizofSzQawJltbFaAqji7uHPGCnBngG6ef8pl4Zgk4JXnaCMslAQqbXIqr)BrFS7yLcj7HK5uW5ddxuqfFCzXcnOe4iQWuqUMTgdqDIc(Nf8zdfC(W2XqUyxJvizci5EijrKCZxuuR4Jllw0(PuW5ddxuWZuwrcv(fC1(vk4V8nggZrYHIsqonOeSVuHPGCnBngG6ef8pl4Zgk4MVOOwXhxwSO9tPGZhgUOGIMkGyry0XWmDwWWWi5Jguc2hQWuqUMTgdqDIc(Nf8zdfmjKuaKm94DqYhqNR3AZVI9d4Q9RizYijrKmjKm94DqYhqNRfnvaXIWOJHz6SGHHrYhsMmfC(WWffCRn)k2pGR2Vsb)LVXWyosouucYPbLGSfvykOvbFNFAqbZPGCnBngG6efC(WWffu0uHcIfHI(3cf8pl4Zgk4JXnaCMsFMYksOYVGR2VQp2DSsHK9qYCKSFFKCZxuuR4Jllw0a4mfnOeKnuHPGCnBngG6ef8pl4Zgk4MVOOwXhxwSObWzkKKis(DgsMGhsMfssejFmUbGZuAfFCzXI(y3XkfsMGhskiKKisME8oi5dOZ1HrYhmDAUuW5ddxuWT28Ry)aUA)kf8x(gdJ5i5qrjiNgucYfevykixZwJbOorb)Zc(SHckasME8oi5dOZ1HrYhmDAUijrKuaKm94DqYhqNR5IpstWTIeYnZb7qsIi53ziPhsMtbNpmCrbdJKpy60CPG)Y3yymhjhkkb50GguqfFCzXcvykb5uHPGCnBngG6ef8pl4ZgkOaiz6X7GKpGoxhgjFW0P5IKersbqY0J3bjFaDUMl(inb3ksi3mhSdjjIKCXh5cs6HKCXh5I2DCajjIKFNHKjGK5ijrKuaKCZxuuR4Jllw0(PuW5ddxuWWi5dMonxk4V8nggZrYHIsqonOeKfvykixZwJbOorbNpmCrb)P1GZhgUGntfuWMPcynUmf8bObLG9OctbNpmCrbv8XLfluqUMTgdqDIgucYovykixZwJbOorb)Zc(SHcoFy7yixSRXkKmbKCpk48HHlk4zkRiHk)cUA)kf8x(gdJ5i5qrjiNgucCevykOvbFNFAqbZPGCnBngG6efC(WWffu0uHcIfHI(3cf8pl4Zgkysizsij74(wAkdOboRwTIe2HVc(4D8HKerYnFrrD6XkL)XWuSvH(y3XkfsMGhsMfssejvCa3WLVshgFzjiy2tFKShskiKmzKKisMes(yCdaNP0NPSIeQ8l4Q9R6JDhRuizpKmhj73hjNpSDmKl21yfs2djZrYKrYKPbLG9Lkmf0QGVZpnOG5uqUMTgdqDIcoFy4IckAQqbXIqr)BHc(Nf8zdfmjKmjKuaKKDCFlnLb0aNvRwrc7WxbF8o(qY(9rYnFrr9wdJbA(Qq7NIK97JKB(IIAfFCzXI(y3XkfsMasMJKjJKerYKqYhJBa4mL(mLvKqLFbxTFvFS7yLcj7HK5iz)(i58HTJHCXUgRqYEizosMmsMmnOeSpuHPGCnBngG6ef8pl4Zgk48HTJHCXUgRqYEEi5EijrKuaKm94DqYhqNRvPwvwrc)BkgUA)kfC(WWffuLAvzfj8VPy4Q9R0Gsq2IkmfKRzRXauNOG)zbF2qbtcjfajtpEhK8b056T28Ry)aUA)ksMmssejtcjtpEhK8b05ArtfqSim6yyMolyyyK8HK97JKPhVds(a6CTOPcfelcf9VfKmzKKisoFy7yixSRXkKmbKmlk48HHlk4wB(vSFaxTFLc(lFJHXCKCOOeKtdkbzdvykixZwJbOorb)Zc(SHcoFy7yixSRXkKSNhsUhfC(WWff8mLvKqLFbxTFLc(lFJHXCKCOOeKtdkb5cIkmfKRzRXauNOG)zbF2qbfajtpEhK8b056T28Ry)aUA)kfC(WWffCRn)k2pGR2Vsb)LVXWyosouucYPbnOGQGkmLGCQWuW5ddxuqR2HxzOd(Crb5A2Ama1jAqjilQWuqUMTgdqDIc(Nf8zdfuaKCZxuuRc85c55Io4uaqr7yTFkfC(WWffuf4ZfYZfDWPaGI2X0GsWEuHPGCnBngG6ef8pl4Zgk4MVOO(8vDwrc3VbGHzScqdGZuijrKuaKm94DqYhqNRpFvNvKW9BayygRaOGZhgUOGNVQZks4(nammJva0Gsq2Pctb5A2Ama1jk4FwWNnuqbqY0J3bjFaDUoms(GPtZLcoFy4IcYfFKMGBfjKBMd2rdkboIkmfKRzRXauNOG)zbF2qbfajtpEhK8b056T28Ry)aUA)kssej)ot7ooGKcgs(Dgs2ZdjZrsIiPId4gU8v6W4lRCy2tFKShskiKKisU5lkQ3WRW0d)A)uk48HHlk4wB(vSFaxTFLc(lFJHXCKCOOeKtdkb7lvykixZwJbOorb)Zc(SHckasME8oi5dOZ1HrYhmDAUijrKuaKm94DqYhqNR5IpstWTIeYnZb7qsIijx8rUOdZLHbg6ooGKj4HK5ijrK87mT74askyi53zizppKmlKKiskasU5lkQv8XLflA)uk48HHlkyyK8btNMlf8x(gdJ5i5qrjiNguc2hQWuqUMTgdqDIc(Nf8zdf87mT74askyi53zizppKCpk48HHlkOOPciwegDmmtNfmmms(ObLGSfvyk48HHlkyMo7AwrcbUHexWu)67OGCnBngG6enOeKnuHPGCnBngG6ef8pl4Zgkysizsi53zizppKCpKKisYfFKlizppKm7ccjtgj73hj)odj75HKocjtgjjIKjHKX04k0k(4YIfnxZwJbqsIi5JXnaCMsR4Jllw0h7owPqYEEi5(IKjtbNpmCrbptzfju5xWv7xPG)Y3yymhjhkkb50GsqUGOctb5A2Ama1jk4FwWNnuWyACfAfFCzXIMRzRXaijrKuaKKDCFlnLb0aNvRwrc7WxbF8o(qsIi5JXnaCMsR4Jllw0h7owPqYEEiPJqsIijx8rUOdZLHbg6ooGK9qYSOGZhgUOGIMkuqSiu0)wObLG8CQWuqUMTgdqDIc(Nf8zdfmMgxHwXhxwSO5A2Amassejzh33stzanWz1QvKWo8vWhVJpKKisMes(yCdaNP0k(4YIf9XUJvkKSNhsM7iKSFFK8X4gaotPv8XLfl6JDhRuizcEiz2rYKrsIijx8rUOdZLHbg6ooGK9qYSOGZhgUOGIMkuqSiu0)wObLG8SOctb5A2Ama1jk4FwWNnuqbqYyACfAfFCzXIMRzRXauW5ddxuqrtfkiwek6Fl0Gsq(EuHPGCnBngG6ef8pl4Zgk4JXnaCMsR4Jllw0h7owPqYEEiPJqY(9rYKqsbqYyACfAfFCzXIMRzRXaizYuW5ddxuWZuwrcv(fC1(vk4V8nggZrYHIsqonOeKNDQWuqUMTgdqDIc(Nf8zdfuaKm94DqYhqNR3AZVI9d4Q9RijrK87mT74askyi53zizppKmNcoFy4IcU1MFf7hWv7xPG)Y3yymhjhkkb50GsqUJOctb5A2Ama1jk4FwWNnuq2X9T0ugqhDmKDt5dFk4pPZBb(qsIi5MVOOo6yi7MYh(uWFsN3c8PvX8RizppKmpBqsIijx8rUOdZLHbg6ooGK9qY9OGZhgUOG)n)AZks4(namSzKDrzfjnOeKVVuHPGCnBngG6ef8pl4Zgki74(wAkdOJogYUP8Hpf8N05TaFijrKCZxuuhDmKDt5dFk4pPZBb(0Qy(vKSNhsMNDKKis(yCdaNP0k(4YIf9XUJvkKmbKmFpKKisgtJRqR4Jllw0CnBngajjIKCXh5IomxggyO74as2dj3JcoFy4Ic(38RnRiH73aWWMr2fLvK0Gsq((qfMcY1S1yaQtuW)SGpBOGFNHK9qY9qY(9rsU4JCrhMlddm0rccjtajtcjFmUbGZuArtfkiwek6Fl6JDhRuiPGHKKpasMmfC(WWffCRn)k2pGR2Vsdkb5zlQWuW5ddxuWVZGzMDmfKRzRXauNObLG8SHkmfKRzRXauNOG)zbF2qb5IpYfDyUmmWq3XbKShsMJKerYyACfAfFCzXIMRzRXauW5ddxuWVZGB(NkObLGSeevykixZwJbOorb)Zc(SHckasME8oi5dOZ1HrYhmDAUijrKuaKm94DqYhqNR5IpstWTIeYnZb7qsIizsi53zA3XbKuWqYVZqYEEizwiz)(ijx8rUOdZLHbg6ooGKjGK7HKjJKersbqYnFrrTIpUSyr7NsbNpmCrbdJKpy60CPG)Y3yymhjhkkb50Gsqw5uHPGCnBngG6ef8pl4Zgk43zA3XbKuWqYVZqYEEi5EijrKKl(ix0H5YWadDhhqYEizossejfajJPXvOv8XLflAUMTgdqbNpmCrb)odU5FQGg0GcQyrioLl(OctjiNkmfKRzRXauNOG)zbF2qbfajtpEhK8b056Wi5dMonxKKiskasME8oi5dOZ1CXhPj4wrc5M5GDijrKKl(ixqspKKl(ix0UJdijrK87mKmbKmhjjIKpg3aWzkTOPcfelcf9Vf9XUJvkKmbpKuquW5ddxuWWi5dMonxk4V8nggZrYHIsqonOeKfvykixZwJbOorbNpmCrb)P1GZhgUGntfuW)SGpBOGpg3aWzkTOPcfelcf9Vf9XUJvkKShsMtbBMkG14YuWhGguc2JkmfKRzRXauNOG)zbF2qbNpSDmKl21yfsMasUhfC(WWff8mLvKqLFbxTFLc(lFJHXCKCOOeKtdkbzNkmfKRzRXauNOG)zbF2qbtcjfajtpEhK8b056T28Ry)aUA)ksMmfC(WWffCRn)k2pGR2Vsb)LVXWyosouucYPbLahrfMcY1S1yaQtuW)SGpBOGpg3aWzkTOPcfelcf9VfnG)nHHlKShs(yCdaNP0NPSIeQ8l4Q9R6JDhRuuW5ddxuqrtfkiwek6Fl0GsW(sfMcY1S1yaQtuW)SGpBOGcGKPhVds(a6CDyK8btNMlssejfajtpEhK8b05AU4J0eCRiHCZCWoKKis(Dgs6HK5uW5ddxuWWi5dMonxk4V8nggZrYHIsqonObf8bOctjiNkmfC(WWff0QD4vg6GpxuqUMTgdqDIgucYIkmfC(WWffCRHXaqr)BHcY1S1yaQt0GsWEuHPGZhgUOGB8P4B1kskixZwJbOordkbzNkmfKRzRXauNOG)zbF2qb)ot7ooGKcgs(Dgs2ZdjZrsIijx8rUOdZLHbg6ooGK98qsbPDefC(WWffCUFkgg474kObLahrfMcoFy4Ic2mYUqb3pFasxUckixZwJbOordkb7lvykixZwJbOorb)Zc(SHcYoUVLMYa6odaGlO7Oc(uqr8TzaaCbdS)3HKersbqY0J3bjFaDUoW(Fhelcb4j6OGZhgUOGb2)7Gyriaprhf8x(gdJ5i5qrjiNguc2hQWuqUMTgdqDIc(Nf8zdfmjKmjKmMgxHwXhxwSO5A2AmassejFmUbGZuAfFCzXI(y3XkfsMGhsMJKjJKerYhJBa4mLw0uHcIfHI(3I(y3XkfsMGhsMDKmzKKis(yCdaNP0NPSIeQ8l4Q9R6JDhRuizci5(GKersbqY0J3bjFaDUoW(Fhelcb4j6OGZhgUOGb2)7Gyriaprhf8x(gdJ5i5qrjiNgucYwuHPGCnBngG6ef8pl4ZgkysizsiPaizmnUcTIpUSyrZ1S1yaKKis(yCdaNP0QaFUqEUOdofau0owFS7yLcjtWdjZrYKrY(9rYVZqYEEizwizYijrK8X4gaotPfnvOGyrOO)TOp2DSsHKj4HKzhjjIKpg3aWzk9zkRiHk)cUA)Q(y3XkfsMasUpijrKuaKm94DqYhqNRdS)3bXIqaEIok48HHlkyG9)oiwecWt0rb)LVXWyosouucYPbnOGPh)y3TjOctjiNkmfKRzRXauNObLGSOctb5A2Ama1jAqjypQWuqUMTgdqDIgucYovykixZwJbOordkboIkmfC(WWffmfhgUOGCnBngG6enOeSVuHPGZhgUOGFNb38pvqb5A2Ama1jAqjyFOctbNpmCrb)odMz2XuqUMTgdqDIg0GcoyMkmLGCQWuqUMTgdqDIcoFy4Ic(tRbNpmCbBMkOGntfWACzk4dqdkbzrfMcY1S1yaQtuW)SGpBOGcGKPhVds(a6CDyK8btNMlssej)odjtWdjZrsIizsi5JXnaCMsFMYksOYVGR2VQp2DSsHKEiPGqY(9rYKqYyACfArtfqSim6yyMolyyyK8P5A2AmassejFmUbGZuArtfqSim6yyMolyyyK8Pp2DSsHKEiPGqYKrY(9rsU4JCbjtajDKGqYKPGZhgUOGCXhPj4wrc5M5GD0GsWEuHPGCnBngG6ef8pl4Zgk43zA3XbKuWqYVZqYEEizossej5IpYfDyUmmWq3XbKSNhskiTJOGZhgUOGZ9tXWaFhxbnOeKDQWuqUMTgdqDIc(Nf8zdfmMgxHwXhxwSO5A2Amassejfajzh33stzanWz1QvKWo8vWhVJpKKis(yCdaNP0k(4YIf9XUJvkKSNhs6iKKisYfFKl6WCzyGHUJdizpKmlk48HHlkOOPcfelcf9VfAqjWruHPGCnBngG6ef8pl4ZgkymnUcTIpUSyrZ1S1yaKKisYoUVLMYaAGZQvRiHD4RGpEhFijrKmjK8X4gaotPv8XLfl6JDhRuizppKm3riz)(i5JXnaCMsR4Jllw0h7owPqYe8qYSJKjJKersU4JCrhMlddm0DCaj7HKzrbNpmCrbfnvOGyrOO)Tqdkb7lvykixZwJbOorb)Zc(SHckasgtJRqR4Jllw0CnBngajjIKCXh5IomxggyO74as2djZIcoFy4IckAQqbXIqr)BHguc2hQWuqUMTgdqDIc(Nf8zdf8X4gaotPptzfju5xWv7x1h7owPqYEEi5EAhHKerYVZqYe8qshrbNpmCrbfnvOGyrOO)TqdkbzlQWuW5ddxuWmD21SIecCdjUGP(13rb5A2Ama1jAqjiBOctb5A2Ama1jk4FwWNnuWhJBa4mLotNDnRiHa3qIlyQF9D6JDhRuizppKK8bqsIiPaiz6X7GKpGoxFMYksOYVGR2VIKerYhJBa4mLw0uHcIfHI(3I(y3Xkfs2djjFak48HHlk4zkRiHk)cUA)knOeKliQWuqUMTgdqDIc(Nf8zdf87mKmbpKCpKKisMes(yCdaNP0NPSIeQ8l4Q9R6JDhRuizppK0riz)(i5JXnaCMsNPZUMvKqGBiXfm1V(o9XUJvkKSNhs6iKmzKKisYfFKl6WCzyGHUJdizpKmNcoFy4Ic(DgCZ)ubnOeKNtfMcoFy4Ic(DgCZ)ubfKRzRXauNObLG8SOctb5A2Ama1jk4FwWNnuWKqY5dBhd5IDnwHK98qY9qY(9rYKqYnFrr9gEfME4x7NIKerYVZ0UJdiPGHKFNHK98qsbHKjJKjJKersbqY0J3bjFaDUwLAvzfj8VPy4Q9RijrKuXbCdx(kDy8Lvom7Pps2djfefC(WWffuLAvzfj8VPy4Q9R0Gsq(EuHPGCnBngG6ef8pl4Zgk48HTJHCXUgRqYEEi5EijrKuaKm94DqYhqNRvPwvwrc)BkgUA)kfC(WWffuLAvzfj8VPy4Q9R0GsqE2Pctb5A2Ama1jk4FwWNnuqbqY0J3bjFaDUERn)k2pGR2VIKerYVZ0UJdiPGHKFNHK98qYCKKisQ4aUHlFLom(YkhM90hj7HKccjjIKjHKcGKkoGB4YxPdJV8SbMv6JK9qsbHK97JKX04k0k(4YIfnxZwJbqYKPGZhgUOGBT5xX(bC1(vk4V8nggZrYHIsqonOeK7iQWuqUMTgdqDIc(Nf8zdfmjK87mKShsMJK97JKB(II6n8km9WV2pfj73hjtcjJPXvO5IpstWTIeYnZb70CnBngajjIKpg3aWzknx8rAcUvKqUzoyN(y3XkfsMas(yCdaNP0IMkuqSiu0)w0h7owPqYKrYKrsIizsizsi5JXnaCMsFMYksOYVGR2VQp2DSsHK9qYCKKisMeskasgtJRqlAQaIfHrhdZ0zbddJKpnxZwJbqY(9rYhJBa4mLw0ubelcJogMPZcgggjF6JDhRuizpKmhjtgj73hj)odj7HKzhjtgjjIKjHKpg3aWzkTOPcfelcf9Vf9XUJvkKShsMJK97JKFNHK9qYSqYKrY(9rY0J3bjFaDUoms(GPtZfjtgjjIKcGKPhVds(a6C9wB(vSFaxTFLcoFy4IcU1MFf7hWv7xPG)Y3yymhjhkkb50Gsq((sfMcY1S1yaQtuW)SGpBOGSJ7BPPmGo6yi7MYh(uWFsN3c8HKerYnFrrD0Xq2nLp8PG)KoVf4tRI5xrYEEizE2GKersU4JCrhMlddm0DCaj7HK7rbNpmCrb)B(1MvKW9BayyZi7IYksAqjiFFOctb5A2Ama1jk4FwWNnuq2X9T0ugqhDmKDt5dFk4pPZBb(qsIi5MVOOo6yi7MYh(uWFsN3c8PvX8RizppKmp7ijrK8X4gaotPv8XLfl6JDhRuizciz(EijrKmMgxHwXhxwSO5A2Amassej5IpYfDyUmmWq3XbKShsUhfC(WWff8V5xBwrc3VbGHnJSlkRiPbLG8SfvykixZwJbOorb)Zc(SHckasME8oi5dOZ1BT5xX(bC1(vKKis(DM2DCajfmK87mKSNhsMJKersfhWnC5R0HXxw5WSN(izpKuqijrKCZxuuVHxHPh(1(PuW5ddxuWT28Ry)aUA)kf8x(gdJ5i5qrjiNgucYZgQWuqUMTgdqDIc(Nf8zdfuaKm94DqYhqNRdJKpy60CrsIiPaiz6X7GKpGoxZfFKMGBfjKBMd2HKerYKqYVZ0UJdiPGHKFNHK98qYSqY(9rsU4JCrhMlddm0DCajtaj3djtMcoFy4IcggjFW0P5sb)LVXWyosouucYPbLGSeevykixZwJbOorb)Zc(SHckasME8oi5dOZ1HrYhmDAUijrKuaKm94DqYhqNR5IpstWTIeYnZb7qsIijx8rUOdZLHbg6ooGKj4HK5ijrK87mT74askyi53zizppKmlk48HHlkyyK8btNMlf8x(gdJ5i5qrjiNgucYkNkmfKRzRXauNOG)zbF2qb)odjtWdj3djjIKjHKpg3aWzk9zkRiHk)cUA)Q(y3Xkfs2ZdjDes2Vps(yCdaNP0z6SRzfje4gsCbt9RVtFS7yLcj75HKocjtgjjIKCXh5IomxggyO74as2djZPGZhgUOGFNbZm7yAqjiRSOctbNpmCrb)odMz2XuqUMTgdqDIg0GcQyrQWucYPctb5A2Ama1jk4FwWNnuqbqY0J3bjFaDUoms(GPtZfjjIKcGKPhVds(a6Cnx8rAcUvKqUzoyhssej5IpYfK0dj5IpYfT74assej)odjtajZPGZhgUOGHrYhmDAUuWyosoGMifeG38ff1UZTcXIWOJH)nfRbWzkAqjilQWuqUMTgdqDIcoFy4Ic(tRbNpmCbBMkOGntfWACzk4dqdkb7rfMcY1S1yaQtuW)SGpBOGcGKB(IIAvGpxipx0bNcakAhR9tPGZhgUOGQaFUqEUOdofau0oMg0GccWIJFlOctjiNkmfC(WWffC8dmCIy(vkixZwJbOordkbzrfMcoFy4IcQs55GDtbavXzRmfKRzRXauNObLG9Octb5A2Ama1jk4FwWNnuqbqYyACfAsmgaUoN7O5A2Amaf0QGVDtJcMncIcM(bSJNw0rbfK2ruW5ddxuWa7)DqSiCDo3HgucYovykOvbF7MgfmBeefm9dyhpTOJcMRfefC(WWffmW(FhelcxNZDOGCnBngG6enOe4iQWuqUMTgdqDIc(Nf8zdfCZxuuR4Jllw0(Piz)(i5MVOOwf4ZfYZfDWPaGI2XA)uKSFFKmjKuaKmMgxHwXhxwSO5A2AmassejJZQvo0Ph(1dP1Syr7NIKjJK97JKB(II6Tggd08vH(45dKSFFKmMJKdDyUmmWqaJrYe8qY9vquW5ddxuWuCy4Iguc2xQWuqUMTgdqDIc(Nf8zdfmMJKdDyUmmWqaJrYe8qYSHcoFy4Icgy)VdIfHa8eD0GsW(qfMcY1S1yaQtuW5ddxuWFAn48HHlyZubf8pl4ZgkysizmnUcTIpUSyrZ1S1yaKKis(yCdaNP0k(4YIf9XUJvkKmbpKuqizYiz)(i5MVOOwXhxwSO9tPGntfWACzkOIpUSyHgucYwuHPGCnBngG6efC(WWff8NwdoFy4c2mvqb)Zc(SHckasgtJRqR4Jllw0CnBngajjIKjHKB(IIAvGpxipx0bNcakAhR9trY(9rYhJBa4mLwf4ZfYZfDWPaGI2X6VBoswHKEizwizYuWMPcynUmfuXI0Gsq2qfMcY1S1yaQtuW5ddxuWFAn48HHlyZubf8pl4ZgkysiPaizmnUcTIpUSyrZ1S1yaKKis(yCdaNP0IMkuqSiu0)w0h7owPqYe8qY8SqsIi53zizppKCpKKis(yCdaNP0NPSIeQ8l4Q9R6JDhRuizcEizosMms2VpsgZrYHomxggyiGXizcEizwocj73hjFmUbGZu6a7)DqSieGNOtFS7yLcj7HK55zrbBMkG14Yuqflsdkb5cIkmfKRzRXauNOGZhgUOG)0AW5ddxWMPck4FwWNnuWKqsbqYyACfAfFCzXIMRzRXaijrKuaKKDCFlnLb0aNvRwrc7WxbF8o(qsIi5JXnaCMslAQqbXIqr)BrFS7yLcjtWdj3xKKis(Dgs2Zdj3djjIKpg3aWzk9zkRiHk)cUA)Q(y3XkfsMGhsMJKjJK97JKXCKCOdZLHbgcymsMGhsM7iKSFFK8X4gaotPdS)3bXIqaEIo9XUJvkKShsMNNfssejFmUbGZuAvGpxipx0bNcakAhR)U5izfs6HK5uWMPcynUmfuXI0GsqEovykixZwJbOorbNpmCrb)P1GZhgUGntfuW)SGpBOGjHKcGKX04k0k(4YIfnxZwJbqsIi5JXnaCMslAQqbXIqr)BrFS7yLcjtWdjZZcjjIKFNHK98qY9qsIi5JXnaCMsFMYksOYVGR2VQp2DSsHKj4HK5izYiz)(izmhjh6WCzyGHagJKj4HKz5iKSFFK8X4gaotPdS)3bXIqaEIo9XUJvkKShsMNNfssejFmUbGZuAvGpxipx0bNcakAhR)U5izfs6HK5uWMPcynUmfuXI0GsqEwuHPGCnBngG6efC(WWff88l48HHlyZubf8pl4Zgk48HTJHCXUgRqYEi5EuWMPcynUmfCWmnOeKVhvykixZwJbOorbNpmCrbp)coFy4c2mvqb)Zc(SHcoFy7yixSRXkKmbpKCpkyZubSgxMcQcAqdAqb3XNYWfLGSeuE2sq7t((OfKGYYrokBOGzMRSIurbPGJF0HpkiO5MTrbtpSO1yk48HHlLo94h7UnHNyBuRiHMpmCP0Ph)y3Tjs0Zzrmgaj08HHlLo94h7UnrIEop(KUCfty4cj08HHlLo94h7UnrIEoRQjv1HdOkMqHeA(WWLsNE8JD3MirpNtXHHlKqZhgUu60JFS72ej6583zWn)tfiHMpmCP0Ph)y3Tjs0Z5VZGzMDmsiKqZhgUuEJFGHteZVIeA(WWLkrpNvP8CWUPaGQ4Svgj08HHlvIEohy)VdIfHRZ5oeAvW3UP5LncIW0pGD80IopbPDeHMONaX04k0KymaCDo3rZ1S1yacTk4B308Ygbry6hWoEArNNG0ocj08HHlvIEohy)VdIfHRZ5oeAvW3UP5LncIW0pGD80IoVCTGqcnFy4sLONZP4WWfHMO3MVOOwXhxwSO9t73FZxuuRc85c55Io4uaqr7yTFA)(jjqmnUcTIpUSyrZ1S1yaIXz1kh60d)6H0AwSOpE(i5(938ff1BnmgO5Rc9XZh97hZrYHomxggyiGXj4TVccj08HHlvIEohy)VdIfHa8eDeAIEXCKCOdZLHbgcyCcEzdsO5ddxQe9C(NwdoFy4c2mvqynUSNIpUSyHqt0lPyACfAfFCzXIMRzRXaeFmUbGZuAfFCzXI(y3XkvcEck5(938ff1k(4YIfTFksO5ddxQe9C(NwdoFy4c2mvqynUSNIfj0e9eiMgxHwXhxwSO5A2AmaXK28ff1QaFUqEUOdofau0ow7N2V)JXnaCMsRc85c55Io4uaqr7y93nhjR8YkzKqZhgUuj658pTgC(WWfSzQGWACzpflsOj6LKaX04k0k(4YIfnxZwJbi(yCdaNP0IMkuqSiu0)w0h7owPsWlplIFN1ZBpIpg3aWzk9zkRiHk)cUA)Q(y3XkvcE5j3VFmhjh6WCzyGHagNGxwoQF)hJBa4mLoW(Fhelcb4j60h7owP6LNNfsO5ddxQe9C(NwdoFy4c2mvqynUSNIfj0e9ssGyACfAfFCzXIMRzRXaefGDCFlnLb0aNvRwrc7WxbF8o(i(yCdaNP0IMkuqSiu0)w0h7owPsWBFj(DwpV9i(yCdaNP0NPSIeQ8l4Q9R6JDhRuj4LNC)(XCKCOdZLHbgcyCcE5oQF)hJBa4mLoW(Fhelcb4j60h7owP6LNNfXhJBa4mLwf4ZfYZfDWPaGI2X6VBosw5LJeA(WWLkrpN)P1GZhgUGntfewJl7PyrcnrVKeiMgxHwXhxwSO5A2AmaXhJBa4mLw0uHcIfHI(3I(y3XkvcE5zr87SEE7r8X4gaotPptzfju5xWv7x1h7owPsWlp5(9J5i5qhMlddmeW4e8YYr97)yCdaNP0b2)7GyriaprN(y3XkvV88Si(yCdaNP0QaFUqEUOdofau0ow)DZrYkVCKqZhgUuj6585xW5ddxWMPccRXL9gmtOj6nFy7yixSRXQE7HeA(WWLkrpNp)coFy4c2mvqynUSNki0e9MpSDmKl21yvcE7Hecj08HHlLEWS3pTgC(WWfSzQGWACzVhaj08HHlLEWCIEoZfFKMGBfjKBMd2rOj6jq6X7GKpGoxhgjFW0P5s87Se8YjM0JXnaCMsFMYksOYVGR2VQp2DSs5jO(9tkMgxHw0ubelcJogMPZcgggjFAUMTgdq8X4gaotPfnvaXIWOJHz6SGHHrYN(y3XkLNGsUFFU4JCjbhjOKrcnFy4sPhmNONZZ9tXWaFhxbHMO33zA3Xbb77SEE5e5IpYfDyUmmWq3XHEEcs7iKqZhgUu6bZj65SOPcfelcf9VfcnrVyACfAfFCzXIMRzRXaefGDCFlnLb0aNvRwrc7WxbF8o(i(yCdaNP0k(4YIf9XUJvQEEoIix8rUOdZLHbg6oo0llKqZhgUu6bZj65SOPcfelcf9VfcnrVyACfAfFCzXIMRzRXaezh33stzanWz1QvKWo8vWhVJpIj9yCdaNP0k(4YIf9XUJvQEE5oQF)hJBa4mLwXhxwSOp2DSsLGx2tMix8rUOdZLHbg6oo0llKqZhgUu6bZj65SOPcfelcf9VfcnrpbIPXvOv8XLflAUMTgdqKl(ix0H5YWadDhh6LfsO5ddxk9G5e9Cw0uHcIfHI(3cHMO3JXnaCMsFMYksOYVGR2VQp2DSs1ZBpTJi(DwcEocj08HHlLEWCIEoNPZUMvKqGBiXfm1V(oKqZhgUu6bZj658zkRiHk)cUA)kHXCKCanrVhJBa4mLotNDnRiHa3qIlyQF9D6JDhRu98iFaIcKE8oi5dOZ1NPSIeQ8l4Q9ReFmUbGZuArtfkiwek6Fl6JDhRu9iFaKqZhgUu6bZj6583zWn)tfeAIEFNLG3Eet6X4gaotPptzfju5xWv7x1h7owP655O(9FmUbGZu6mD21SIecCdjUGP(13Pp2DSs1ZZrjtKl(ix0H5YWadDhh6LJeA(WWLspyorpN)odU5FQaj08HHlLEWCIEoRsTQSIe(3umC1(vcnrVKMpSDmKl21yvpV963pPnFrr9gEfME4x7Ns87mT74GG9DwppbLCYefi94DqYhqNRvPwvwrc)BkgUA)krfhWnC5R0HXxw5WSN(iHMpmCP0dMt0ZzvQvLvKW)MIHR2VsOj6nFy7yixSRXQEE7ruG0J3bjFaDUwLAvzfj8VPy4Q9RiHMpmCP0dMt0Z5T28Ry)aUA)kH)Y3yymhjhkVCcnrpbspEhK8b056T28Ry)aUA)kXVZ0UJdc23z98YjQ4aUHlFLom(YkhM90NyscO4aUHlFLom(YZgywPF)(X04k0k(4YIfnxZwJbsgj08HHlLEWCIEoV1MFf7hWv7xj8x(gdJ5i5q5LtOj6L03z9Y73FZxuuVHxHPh(1(P97NumnUcnx8rAcUvKqUzoyNMRzRXaeFmUbGZuAU4J0eCRiHCZCWo9XUJvQeEmUbGZuArtfkiwek6Fl6JDhRujNmXKs6X4gaotPptzfju5xWv7x1h7owP6LtmjbIPXvOfnvaXIWOJHz6SGHHrYNMRzRXa97)yCdaNP0IMkGyry0XWmDwWWWi5tFS7yLQxEY97)DwVSNmXKEmUbGZuArtfkiwek6Fl6JDhRu9Y73)7SEzLC)(PhVds(a6CDyK8btNMBYefi94DqYhqNR3AZVI9d4Q9RiHMpmCP0dMt0Z5)MFTzfjC)gag2mYUOSIKqt0JDCFlnLb0rhdz3u(WNc(t68wGpIB(II6OJHSBkF4tb)jDElWNwfZV2ZlpBiYfFKl6WCzyGHUJd92dj08HHlLEWCIEo)38RnRiH73aWWMr2fLvKeAIESJ7BPPmGo6yi7MYh(uWFsN3c8rCZxuuhDmKDt5dFk4pPZBb(0Qy(1EE5zN4JXnaCMsR4Jllw0h7owPsiFpIX04k0k(4YIfnxZwJbiYfFKl6WCzyGHUJd92dj08HHlLEWCIEoV1MFf7hWv7xj8x(gdJ5i5q5LtOj6jq6X7GKpGoxV1MFf7hWv7xj(DM2DCqW(oRNxorfhWnC5R0HXxw5WSN(e38ff1B4vy6HFTFksO5ddxk9G5e9Coms(GPtZLWF5BmmMJKdLxoHMONaPhVds(a6CDyK8btNMlrbspEhK8b05AU4J0eCRiHCZCWoIj9DM2DCqW(oRNxw97ZfFKl6WCzyGHUJdjSxYiHMpmCP0dMt0Z5Wi5dMonxc)LVXWyosouE5eAIEcKE8oi5dOZ1HrYhmDAUefi94DqYhqNR5IpstWTIeYnZb7iYfFKl6WCzyGHUJdj4Lt87mT74GG9DwpVSqcnFy4sPhmNONZFNbZm7ycnrVVZsWBpIj9yCdaNP0NPSIeQ8l4Q9R6JDhRu98Cu)(pg3aWzkDMo7AwrcbUHexWu)670h7owP655OKjYfFKl6WCzyGHUJd9YrcnFy4sPhmNONZFNbZm7yKqiHMpmCP0pGNv7WRm0bFUGrhdZ0zbddJKpKqZhgUu6hirpN3Aymau0)wqcnFy4sPFGe9CEJpfFRwrIeA(WWLs)aj658C)ummW3XvqOj69DM2DCqW(oRNxorU4JCrhMlddm0DCONNG0ocj08HHlL(bs0Z5Mr2fk4(5dq6YvGeA(WWLs)aj65CG9)oiwecWt0r4V8nggZrYHYlNqt0JDCFlnLb0Dgaaxq3rf8PGI4BZaa4cgy)VJOaPhVds(a6CDG9)oiwecWt0HeA(WWLs)aj65CG9)oiwecWt0r4V8nggZrYHYlNqt0lPKIPXvOv8XLflAUMTgdq8X4gaotPv8XLfl6JDhRuj4LNmXhJBa4mLw0uHcIfHI(3I(y3XkvcEzpzIpg3aWzk9zkRiHk)cUA)Q(y3Xkvc7drbspEhK8b056a7)DqSieGNOdj08HHlL(bs0Z5a7)DqSieGNOJWF5BmmMJKdLxoHMOxsjjqmnUcTIpUSyrZ1S1yaIpg3aWzkTkWNlKNl6GtbafTJ1h7owPsWlp5(9)oRNxwjt8X4gaotPfnvOGyrOO)TOp2DSsLGx2j(yCdaNP0NPSIeQ8l4Q9R6JDhRujSpefi94DqYhqNRdS)3bXIqaEIoKqiHMpmCP0kw0lms(GPtZLWyosoGMOhaV5lkQDNBfIfHrhd)BkwdGZueAIEcKE8oi5dOZ1HrYhmDAUefi94DqYhqNR5IpstWTIeYnZb7iYfFKlECXh5I2DCG43zjKJeA(WWLsRyXe9C(NwdoFy4c2mvqynUS3dGeA(WWLsRyXe9Cwf4ZfYZfDWPaGI2XeAIEcS5lkQvb(CH8CrhCkaOODS2pfj0(lKC(WWLsRyXe9C(NwdoFy4c2mvqynUS3GzcnrV5dBhd5IDnw1BpKq7VqY5ddxkTIft0Z5FAn48HHlyZubH14YEQGqt0B(W2XqUyxJvj4ThsiKqZhgUuAflcXPCXNxyK8btNMlH)Y3yymhjhkVCcnrpbspEhK8b056Wi5dMonxIcKE8oi5dOZ1CXhPj4wrc5M5GDe5IpYfpU4JCr7ooq87SeYj(yCdaNP0IMkuqSiu0)w0h7owPsWtqiHMpmCP0kweIt5IVe9C(NwdoFy4c2mvqynUS3dqOj69yCdaNP0IMkuqSiu0)w0h7owP6LJeA(WWLsRyrioLl(s0Z5Zuwrcv(fC1(vc)LVXWyosouE5eAIEZh2ogYf7ASkH9qcnFy4sPvSieNYfFj658wB(vSFaxTFLWF5BmmMJKdLxoHMOxscKE8oi5dOZ1BT5xX(bC1(1KrcnFy4sPvSieNYfFj65SOPcfelcf9VfcnrVhJBa4mLw0uHcIfHI(3IgW)MWWvVhJBa4mL(mLvKqLFbxTFvFS7yLcj08HHlLwXIqCkx8LONZHrYhmDAUe(lFJHXCKCO8Yj0e9ei94DqYhqNRdJKpy60Cjkq6X7GKpGoxZfFKMGBfjKBMd2r87mVCKqiHMpmCP0k(4YIfVWi5dMonxc)LVXWyosouE5eAIEcKE8oi5dOZ1HrYhmDAUefi94DqYhqNR5IpstWTIeYnZb7iYfFKlECXh5I2DCG43zjKtuGnFrrTIpUSyr7NIeA(WWLsR4Jllws0Z5FAn48HHlyZubH14YEpasO5ddxkTIpUSyjrpNv8XLfliHMpmCP0k(4YILe9C(mLvKqLFbxTFLWF5BmmMJKdLxoHMO38HTJHCXUgRsypKqZhgUuAfFCzXsIEolAQqbXIqr)BHqt0lPKyh33stzanWz1QvKWo8vWhVJpIB(II60Jvk)JHPyRc9XUJvQe8YIOId4gU8v6W4llbbZE6NmXKEmUbGZu6Zuwrcv(fC1(v9XUJvQE597pFy7yixSRXQE5jNmHwf8D(PHxosO5ddxkTIpUSyjrpNfnvOGyrOO)TqOj6LuscWoUVLMYaAGZQvRiHD4RGpEhF97V5lkQ3AymqZxfA)0(938ff1k(4YIf9XUJvQeYtMyspg3aWzk9zkRiHk)cUA)Q(y3XkvV8(9NpSDmKl21yvV8KtMqRc(o)0Wlhj08HHlLwXhxwSKONZQuRkRiH)nfdxTFLqt0B(W2XqUyxJv982JOaPhVds(a6CTk1QYks4FtXWv7xrcnFy4sPv8XLflj658wB(vSFaxTFLWF5BmmMJKdLxoHMOxscKE8oi5dOZ1BT5xX(bC1(1KjMu6X7GKpGoxlAQaIfHrhdZ0zbddJKV(9tpEhK8b05Artfkiwek6FljtC(W2XqUyxJvjKfsO5ddxkTIpUSyjrpNptzfju5xWv7xj8x(gdJ5i5q5LtOj6nFy7yixSRXQEE7HeA(WWLsR4Jllws0Z5T28Ry)aUA)kH)Y3yymhjhkVCcnrpbspEhK8b056T28Ry)aUA)ksiKqZhgUuAfFCzXceNYfFEHrYhmDAUe(lFJHXCKCO8Yj0e9ei94DqYhqNRdJKpy60Cjkq6X7GKpGoxZfFKMGBfjKBMd2rKl(ix84IpYfT74aXVZsiNOaB(IIAfFCzXI2pL4JXnaCMslAQqbXIqr)BrFS7yLkbpbHeA(WWLsR4JllwG4uU4lrpNN7NIHb(oUccnrVVZ0UJdc23z98YjYfFKl6WCzyGHUJd98eK2riHMpmCP0k(4YIfioLl(s0Z5FAn48HHlyZubH14YEpaHMO3JXnaCMslAQqbXIqr)BrFS7yLQxosO5ddxkTIpUSybIt5IVe9CwXhxwSqOj69yCdaNP0IMkuqSiu0)w0h7owP6LJeA(WWLsR4JllwG4uU4lrpNptzfju5xWv7xj8x(gdJ5i5q5LtOj6nFy7yixSRXQe2J4MVOOwXhxwSO9trcnFy4sPv8XLflqCkx8LONZIMkGyry0XWmDwWWWi5Jqt0BZxuuR4Jllw0(PiHMpmCP0k(4YIfioLl(s0Z5T28Ry)aUA)kH)Y3yymhjhkVCcnrVKei94DqYhqNR3AZVI9d4Q9RjtmP0J3bjFaDUw0ubelcJogMPZcgggjFjJeA(WWLsR4JllwG4uU4lrpNfnvOGyrOO)TqOj69yCdaNP0NPSIeQ8l4Q9R6JDhRu9Y73FZxuuR4Jllw0a4mfHwf8D(PHxosO5ddxkTIpUSybIt5IVe9CERn)k2pGR2Vs4V8nggZrYHYlNqt0BZxuuR4Jllw0a4mfXVZsWllIpg3aWzkTIpUSyrFS7yLkbpbrm94DqYhqNRdJKpy60CrcnFy4sPv8XLflqCkx8LONZHrYhmDAUe(lFJHXCKCO8Yj0e9ei94DqYhqNRdJKpy60Cjkq6X7GKpGoxZfFKMGBfjKBMd2r87mVCKqiHMpmCP0QWZQD4vg6GpxWOJHz6SGHHrYhsO5ddxkTks0ZzvGpxipx0bNcakAhtOj6jWMVOOwf4ZfYZfDWPaGI2XA)uKqZhgUuAvKONZNVQZks4(nammJvaeAIEB(II6Zx1zfjC)gagMXkanaotruG0J3bjFaDU(8vDwrc3VbGHzScaj08HHlLwfj65mx8rAcUvKqUzoyhHMONaPhVds(a6CDyK8btNMlsO5ddxkTks0Z5T28Ry)aUA)kH)Y3yymhjhkVCcnrpbspEhK8b056T28Ry)aUA)kXVZ0UJdc23z98YjQ4aUHlFLom(YkhM90N4MVOOEdVctp8R9trcnFy4sPvrIEohgjFW0P5s4V8nggZrYHYlNqt0tG0J3bjFaDUoms(GPtZLOaPhVds(a6Cnx8rAcUvKqUzoyhrU4JCrhMlddm0DCibVCIFNPDhheSVZ65Lfrb28ff1k(4YIfTFksO5ddxkTks0ZzrtfqSim6yyMolyyyK8rOj69DM2DCqW(oRN3EiHMpmCP0QirpNZ0zxZksiWnK4cM6xFhsO5ddxkTks0Z5Zuwrcv(fC1(vc)LVXWyosouE5eAIEjL03z982Jix8rU0Zl7ck5(9)oRNNJsMysX04k0k(4YIfnxZwJbi(yCdaNP0k(4YIf9XUJvQEE7BYiHMpmCP0QirpNfnvOGyrOO)TqOj6ftJRqR4Jllw0CnBngGOaSJ7BPPmGg4SA1ksyh(k4J3XhXhJBa4mLwXhxwSOp2DSs1ZZre5IpYfDyUmmWq3XHEzHeA(WWLsRIe9Cw0uHcIfHI(3cHMOxmnUcTIpUSyrZ1S1yaISJ7BPPmGg4SA1ksyh(k4J3XhXKEmUbGZuAfFCzXI(y3XkvpVCh1V)JXnaCMsR4Jllw0h7owPsWl7jtKl(ix0H5YWadDhh6LfsO5ddxkTks0Zzrtfkiwek6FleAIEcetJRqR4Jllw0CnBngaj08HHlLwfj658zkRiHk)cUA)kH)Y3yymhjhkVCcnrVhJBa4mLwXhxwSOp2DSs1ZZr97NKaX04k0k(4YIfnxZwJbsgj08HHlLwfj658wB(vSFaxTFLWF5BmmMJKdLxoHMONaPhVds(a6C9wB(vSFaxTFL43zA3Xbb77SEE5iHMpmCP0QirpN)B(1MvKW9BayyZi7IYkscnrp2X9T0ugqhDmKDt5dFk4pPZBb(iU5lkQJogYUP8Hpf8N05TaFAvm)ApV8SHix8rUOdZLHbg6oo0BpKqZhgUuAvKONZ)n)AZks4(namSzKDrzfjHMOh74(wAkdOJogYUP8Hpf8N05TaFe38ff1rhdz3u(WNc(t68wGpTkMFTNxE2j(yCdaNP0k(4YIf9XUJvQeY3JymnUcTIpUSyrZ1S1yaICXh5IomxggyO74qV9qcnFy4sPvrIEoV1MFf7hWv7xj0e9(oR3E97ZfFKl6WCzyGHosqjK0JXnaCMslAQqbXIqr)BrFS7yLsWiFGKrcnFy4sPvrIEo)DgmZSJrcnFy4sPvrIEo)DgCZ)ubHMOhx8rUOdZLHbg6oo0lNymnUcTIpUSyrZ1S1yaKqZhgUuAvKONZHrYhmDAUe(lFJHXCKCO8Yj0e9ei94DqYhqNRdJKpy60Cjkq6X7GKpGoxZfFKMGBfjKBMd2rmPVZ0UJdc23z98YQFFU4JCrhMlddm0DCiH9sMOaB(IIAfFCzXI2pfj08HHlLwfj6583zWn)tfeAIEFNPDhheSVZ65ThrU4JCrhMlddm0DCOxorbIPXvOv8XLflAUMTgdqdAqPa]] )
end