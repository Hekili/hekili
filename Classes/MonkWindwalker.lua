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

            recheck = function () return apl( energy.time_to_max, energy.time_to_max - 1, buff.serenity.remains, energy.time_to_max - 3 ) end,
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

        strict = true
    } )

    spec:RegisterPack( "Windwalker", 20180717.002559, 
        [[d4039bqiQOEeGQlPqjsBIk8jfkPrbj5uqs9kaLzreDlivTlQ6xkunmQiogrAzqcpdLktdsuxJksBdsf(gKinofkvNdseRtfsZtfQ7Pi7ds5GOuvTqQu9qQKAIQq4Iku0gHuPpsLKAKOufCsuQIwPk4LOuLMjkvHUPcLO2jvk)uHszOujjlvfIEkkMkr4QkuI4RkucNfsfTxk9xOgSKdR0IvupgvtgIlJSzv6ZeA0k40KwnkvLxdWSb62eSBP(nOHRIoUcfwUQEoftx01jQTdiFxHmEQeNhLSEQKy(Ou2VWwPwjSmiBsw3qHtKo2Dckvkk17eNGIXokqHLjzDswMZLdyfjltVcKLzSqBKrlia6TmNllq4IyLWYyGYpNSmdzEAo64JlQ5G8SNdfg3OcYGBQWM)7nh3Oc8XNbHZJpFx0Jqan(5dVkizgxcLEuiDCjqHu8yzydapwOnYOfea9EJkWTmZYkyYE22zldYMK1nu4ePJDNGsLIs9oXjsrPofLTmMtIBDdfOduILbHmClJedQjk1evoqrHq3vgmJASqBKrlia6JA5Pc7OoxoGOUWpk33mbPOUWpk2VRqpmh8XH4WyzTHFulc7t2KcuNMOgrpfLWIqrDFOqu5affJkidUPcBx)7nJI97QypgfO2aiKOGDu5af15dVkifvUZ(4qCG93rrUK)2eu2efFbbXlpvyJbvtg1O1e1tcqGieFCioehgly)hPBSNU5QpAurHoHYrTpfLiuBXOsyuZuug5)8vdHevoSzuSGYJ1NIseQTyujmkzdfL7GlhauoJI9QCarLJuofL2rTr9WrrzGcuQcKXhvuS)OaHPpQOCN4RSHIYDWLdakNrXEvoGOutuiQ58HNWpvyVjbYkkt(WwmkTJkPxWef8gfYkSIuuN0hfFq9rff75yviQt5m1wmQCqnrnA)wBXOgONIAM4RSHIIfuES(uuIqTfJkHr90j8ZO0mQ1e1g1SSyuBJef7zuRquIqTfJkHrXFwEldOAsJvclJHEQ1KfgEsn9wjSUj1kHLH6DgKqSUBzwEQW2YKQi94ZfuWYWFnPxxlJZrD(eqyroIxQpvr6XNlOquoIY5OoFciSihXl1tn9IQROTiMavx0pkhrrn9ISIAkkQPxKLxyDjkhrXh0OookPr5ikNJAw(E9g6PwtwE5ZOCefhcbrGJA)vnPbdV4R8ZY)KWQTjQJNIYjwMCFrkX61YGqZY3RxyFay4fNdeM)Bt(NewTn206gkSsyzOENbjeR7wg(Rj96Az4dQxyDjk0hfFqJcTPOKgLJOOMErw(ufiCcXcRlrH2uuoX7ulZYtf2wM95Bt4e(p1PnTUXoRewgQ3zqcX6ULH)AsVUwgoecIah1(RAsdgEXx5NL)jHvBtuOfLulZYtf2wg(ccIxEQWgdQM0YaQMe3Razz4i206gkBLWYq9odsiw3Tm8xt611YWHqqe4O2FvtAWWl(k)S8pjSABIcTOKAzwEQW2YyONAnzztRBo1kHLH6DgKqSUBzwEQW2Y8QrBrSrUXauoald)1KEDTmlpvGim1KGsMOook2fLJOMLVxVHEQ1KLx(0YK7lsjwVwgeAw(E9c7dadV4CGW8FBY)KWQTXMw3qhwjSmuVZGeI1Dld)1KEDTmZY3R3qp1AYYlFAzwEQW2YCvtIHxCoq4rdAs4ufP3Mw3qPwjSmuVZGeI1DlZYtf2wMzWLdakNyakhGLH)AsVUwgufLZrD(eqyroIxQFgC5aGYjgGYbefQJYruOkQZNaclYr8s9x1Ky4fNdeE0GMeovr6Jc1wMCFrkX61YGqZY3RxyFay4fNdeM)Bt(NewTn2062y3kHLH6DgKqSUBz4VM0RRLHdHGiWrT)vJ2IyJCJbOCa(NewTnrHwusJIn2IAw(E9g6PwtwEe4O2YS8uHTL5QM0GHx8v(zzz0oP)LptlJuBADdLyLWYq9odsiw3TmlpvyBzMbxoaOCIbOCawg(Rj96AzMLVxVHEQ1KLhboQJYru8bnQJNIcfr5ikoecIah1Ed9uRjl)tcR2MOoEkkNeLJOoFciSihXl1NQi94ZfuWYK7lsjwVwgeAw(E9c7dadV4CGW8FBY)KWQTXMw3K6eRewgQ3zqcX6ULz5PcBltQI0Jpxqbld)1KEDTmoh15taHf5iEP(ufPhFUGcr5ikNJ68jGWICeVup10lQUI2IycuDr)OCefFqJAkkPwMCFrkX61YGqZY3RxyFay4fNdeM)Bt(NewTn20Mwgd9uRjlRew3KALWYq9odsiw3TmlpvyBzsvKE85ckyz4VM0RRLX5OoFciSihXl1NQi94Zfuikhr5CuNpbewKJ4L6PMEr1v0wetGQl6hLJOOMErwrnff10lYYlSUeLJO4dAuhhL0OCeLZrnlFVEd9uRjlV8PLj3xKsSETmi0S896f2hagEX5aH5)2K)jHvBJnTUHcRewgQ3zqcX6ULz5PcBldFbbXlpvyJbvtAzavtI7vGSmCeBADJDwjSmlpvyBzm0tTMSSmuVZGeI1DBADdLTsyzOENbjeR7wMLNkSTmVA0weBKBmaLdWYWFnPxxlZYtfictnjOKjQJJIDwMCFrkX61YGqZY3RxyFay4fNdeM)Bt(NewTn206MtTsyzOENbjeR7wg(Rj96AzqvuOkkAmK1ZtcXJ8AdqBr8a8Bmhce9r5iQz571F(KXi)e(eQD6Fsy12e1XtrHIOCeLHs8mSLn(uPhfobJYN8OqlkNefQJYruOkkoecIah1(xnAlInYngGYb4Fsy12efArjnk2ylQLNkqeMAsqjtuOfL0OqDuO2YS8uHTL5QM0GHx8v(zzz0oP)LptlJuBADdDyLWYq9odsiw3Tm8xt611YGQOqvuohfngY65jH4rETbOTiEa(nMdbI(OyJTOMLVx)mieIakBsV8zuSXwuZY3R3qp1AYY)KWQTjQJJsAuOokhrHQO4qiicCu7F1OTi2i3yakhG)jHvBtuOfL0OyJTOwEQaryQjbLmrHwusJc1rHAlZYtf2wMRAsdgEXx5NLLr7K(x(mTmsTP1nuQvcld17miHyD3YWFnPxxlZYtfictnjOKjk0MIIDr5ikNJ68jGWICeVuV5u7wBrm)3MWauoalZYtf2wgZP2T2Iy(VnHbOCa2062y3kHLH6DgKqSUBzwEQW2YmdUCaq5edq5aSm8xt611YGQOCoQZNaclYr8s9ZGlhauoXauoGOqDuoIcvrD(eqyroIxQ)QMedV4CGWJg0KWPksFuSXwuNpbewKJ4L6VQjny4fFLFwrH6OCe1YtfictnjOKjQJJcfwMCFrkX61YGqZY3RxyFay4fNdeM)Bt(NewTn206gkXkHLH6DgKqSUBzwEQW2Y8QrBrSrUXauoald)1KEDTmlpvGim1KGsMOqBkk2zzY9fPeRxldcnlFVEH9bGHxCoqy(Vn5Fsy12ytRBsDIvcld17miHyD3YS8uHTLzgC5aGYjgGYbyz4VM0RRLX5OoFciSihXl1pdUCaq5edq5aSm5(IuI1RLbHMLVxVW(aWWlohim)3M8pjSABSPnTmM0kH1nPwjSmlpvyBz0giiac7Im1wgQ3zqcX6UnTUHcRewgQ3zqcX6ULH)AsVUwgNJAw(E9Me(cyA)CaVnc(Qp5LpTmlpvyBzmj8fW0(5aEBe8vFYMw3yNvcld17miHyD3YWFnPxxlZS896FzZG2Iy23Iq4rAJ4rGJ6OCeLZrD(eqyroIxQ)LndAlIzFlcHhPnILz5PcBlZlBg0weZ(wecpsBeBADdLTsyzOENbjeR7wg(Rj96AzCoQZNaclYr8s9Pksp(CbfSmlpvyBzOMEr1v0wetGQl6BtRBo1kHLH6DgKqSUBzwEQW2YmdUCaq5edq5aSm8xt611Y4CuNpbewKJ4L6NbxoaOCIbOCar5ik(G6fwxIc9rXh0OqBkkPr5ikdL4zylB8PspkKIr5tEuOfLtIYruZY3RFgcaF(qUx(0YK7lsjwVwgeAw(E9c7dadV4CGW8FBY)KWQTXMw3qhwjSmuVZGeI1DlZYtf2wMufPhFUGcwg(Rj96AzCoQZNaclYr8s9Pksp(CbfIYruoh15taHf5iEPEQPxuDfTfXeO6I(r5ikQPxKLpvbcNqSW6suhpfL0OCefFq9cRlrH(O4dAuOnffkIYruoh1S896n0tTMS8YNwMCFrkX61YGqZY3RxyFay4fNdeM)Bt(NewTn206gk1kHLH6DgKqSUBz4VM0RRLHpOEH1LOqFu8bnk0MIIDwMLNkSTmx1Ky4fNdeE0GMeovr6TP1TXUvclZYtf2wMrd6dQTig5xryJpLB(GLH6DgKqSUBtRBOeRewgQ3zqcX6ULz5PcBlZRgTfXg5gdq5aSm8xt611YGQOqvu8bnk0MIIDr5ikQPxKvuOnffk7KOqDuSXwu8bnk0MIYPrH6OCefQIkxqQtVHEQ1KLN6DgKqIIn2IIdHGiWrT3qp1AYY)KWQTjk0MIcDefQTm5(IuI1RLbHMLVxVW(aWWlohim)3M8pjSABSP1nPoXkHLH6DgKqSUBz4VM0RRLjxqQtVHEQ1KLN6DgKqIYruohfngY65jH4rETbOTiEa(nMdbI(OCefhcbrGJAVHEQ1KL)jHvBtuOnfLtJYruutVilFQceoHyH1LOqlkuyzwEQW2YCvtAWWl(k)SSP1nPsTsyzOENbjeR7wg(Rj96AzYfK60BONAnz5PENbjKOCefngY65jH4rETbOTiEa(nMdbI(OCefQIIdHGiWrT3qp1AYY)KWQTjk0MIsQtJIn2IIdHGiWrT3qp1AYY)KWQTjQJNIcLJc1r5ikQPxKLpvbcNqSW6suOffkSmlpvyBzUQjny4fFLFw206MuuyLWYq9odsiw3Tm8xt611Y4Cu5csD6n0tTMS8uVZGeILz5PcBlZvnPbdV4R8ZYMw3KYoRewgQ3zqcX6ULz5PcBlZRgTfXg5gdq5aSm8xt611YWHqqe4O2BONAnz5Fsy12efAtr50OyJTOqvuohvUGuNEd9uRjlp17miHefQTm5(IuI1RLbHMLVxVW(aWWlohim)3M8pjSABSP1nPOSvcld17miHyD3YS8uHTLzgC5aGYjgGYbyz4VM0RRLX5OoFciSihXl1pdUCaq5edq5aIYru8b1lSUef6JIpOrH2uusTm5(IuI1RLbHMLVxVW(aWWlohim)3M8pjSABSP1nPo1kHLH6DgKqSUBz4VM0RRLHgdz98Kq85aHjHt6HVbZ3ZLRj8JYruZY3RphimjCsp8ny(EUCnHV3KlhquOnfLuusuoIIA6fz5tvGWjelSUefArXolZYtf2wg(VCaGAlIzFlcHbvXHS1w0Mw3KIoSsyzOENbjeR7wg(Rj96AzOXqwppjeFoqys4KE4BW89C5Ac)OCe1S896ZbctcN0dFdMVNlxt47n5YbefAtrjfLJYruCieeboQ9g6Pwtw(NewTnrDCuszxuoIkxqQtVHEQ1KLN6DgKqIYruutVilFQceoHyH1LOqlk2zzwEQW2YW)LdauBrm7BrimOkoKT2I206MuuQvclZYtf2wMzWLdakNyakhGLH6DgKqSUBtRBsh7wjSmlpvyBz4dkE0cezzOENbjeR7206MuuIvcld17miHyD3YWFnPxxld10lYYNQaHtiwyDjk0IsAuoIkxqQtVHEQ1KLN6DgKqSmlpvyBz4dkEw(nPnTUHcNyLWYq9odsiw3TmlpvyBzsvKE85ckyz4VM0RRLX5OoFciSihXl1NQi94Zfuikhr5CuNpbewKJ4L6PMEr1v0wetGQl6hLJOqvu8b1lSUef6JIpOrH2uuOik2ylkQPxKLpvbcNqSW6suhhf7Ic1r5ikNJAw(E9g6PwtwE5tltUViLy9AzqOz571lSpam8IZbcZ)Tj)tcR2gBADdfsTsyzOENbjeR7wg(Rj96Az4dQxyDjk0hfFqJcTPOyxuoIIA6fz5tvGWjelSUefArjnkhr5Cu5csD6n0tTMS8uVZGeILz5PcBldFqXZYVjTPnTmg6IHNutVvcRBsTsyzOENbjeR7wMLNkSTmPksp(CbfSm8xt611Y4CuNpbewKJ4L6tvKE85ckeLJOCoQZNaclYr8s9utVO6kAlIjq1f9JYruutViROMIIA6fz5fwxIYru8bnQJJsAuoIIdHGiWrT)QM0GHx8v(z5Fsy12e1Xtr5eltUViLy9AzqOz571lSpam8IZbcZ)Tj)tcR2gBADdfwjSmuVZGeI1Dld)1KEDTmCieeboQ9x1Kgm8IVYpl)tcR2MOqlkPwMLNkSTm8feeV8uHngunPLbunjUxbYYWrSP1n2zLWYq9odsiw3TmlpvyBzE1OTi2i3yakhGLH)AsVUwMLNkqeMAsqjtuhhf7Sm5(IuI1RLbHMLVxVW(aWWlohim)3M8pjSABSP1nu2kHLH6DgKqSUBzwEQW2YmdUCaq5edq5aSm8xt611YGQOCoQZNaclYr8s9ZGlhauoXauoGOqTLj3xKsSETmi0S896f2hagEX5aH5)2K)jHvBJnTU5uRewgQ3zqcX6ULH)AsVUwgoecIah1(RAsdgEXx5NLhr(3uHDuOffhcbrGJA)RgTfXg5gdq5a8pjSABSmlpvyBzUQjny4fFLFw206g6WkHLH6DgKqSUBzwEQW2YKQi94ZfuWYWFnPxxlJZrD(eqyroIxQpvr6XNlOquoIY5OoFciSihXl1tn9IQROTiMavx0pkhrXh0OMIsQLj3xKsSETmi0S896f2hagEX5aH5)2K)jHvBJnTPLHJyLW6MuRewMLNkSTmAdeeaHDrMAld17miHyD3Mw3qHvclZYtf2wMzqiebFLFwwgQ3zqcX6UnTUXoRewMLNkSTmZ0BOhG2IwgQ3zqcX6UnTUHYwjSmuVZGeI1Dld)1KEDTm8b1lSUef6JIpOrH2uusJYruutVilFQceoHyH1LOqBkkN4DQLz5PcBlZ(8TjCc)N60Mw3CQvclZYtf2wgqvCiny2NmIOa1PLH6DgKqSUBtRBOdRewgQ3zqcX6ULz5PcBltcL5dy4fJqBoyz4VM0RRLHgdz98Kq8dkcc1yH1K0BWx4pRiiuJtOmFikhr5CuNpbewKJ4L6tOmFadVyeAZbltUViLy9AzqOz571Nqz(agEXi0Md(NewTn206gk1kHLH6DgKqSUBzwEQW2YKqz(agEXi0Mdwg(Rj96AzqvuOkQCbPo9g6PwtwEQ3zqcjkhrXHqqe4O2BONAnz5Fsy12e1XtrjnkuhLJO4qiicCu7VQjny4fFLFw(NewTnrD8uuOCuOokhrXHqqe4O2)QrBrSrUXauoa)tcR2MOookuAuoIY5OoFciSihXl1Nqz(agEXi0MdwMCFrkX61YGqZY3RpHY8bm8IrOnh8pjSABSP1TXUvcld17miHyD3YS8uHTLjHY8bm8IrOnhSm8xt611YGQOqvuohvUGuNEd9uRjlp17miHeLJO4qiicCu7nj8fW0(5aEBe8vFY)KWQTjQJNIsAuOok2ylk(GgfAtrHIOqDuoIIdHGiWrT)QM0GHx8v(z5Fsy12e1XtrHYr5ikoecIah1(xnAlInYngGYb4Fsy12e1XrHsJYruoh15taHf5iEP(ekZhWWlgH2CWYK7lsjwVwgeAw(E9juMpGHxmcT5G)jHvBJnTPL58jouyEtRew3KALWYq9odsiw3TP1nuyLWYq9odsiw3TP1n2zLWYq9odsiw3TP1nu2kHLH6DgKqSUBtRBo1kHLz5PcBlZjmvyBzOENbjeR7206g6WkHLz5PcBldFqXZYVjTmuVZGeI1DBADdLALWYS8uHTLHpO4rlqKLH6DgKqSUBtBAzwizLW6MuRewgQ3zqcX6ULz5PcBldFbbXlpvyJbvtAzavtI7vGSmCeBADdfwjSmuVZGeI1Dld)1KEDTmoh15taHf5iEP(ufPhFUGcr5ik(Gg1XtrjnkhrHQO4qiicCu7F1OTi2i3yakhG)jHvBtutr5KOyJTOqvu5csD6VQjXWlohi8ObnjCQI07PENbjKOCefhcbrGJA)vnjgEX5aHhnOjHtvKE)tcR2MOMIYjrH6OyJTOOMErwrDCuo1jrHAlZYtf2wgQPxuDfTfXeO6I(206g7SsyzOENbjeR7wg(Rj96Az4dQxyDjk0hfFqJcTPOKgLJOOMErw(ufiCcXcRlrH2uuoX7ulZYtf2wM95Bt4e(p1PnTUHYwjSmuVZGeI1Dld)1KEDTm5csD6n0tTMS8uVZGesuoIY5OOXqwppjepYRnaTfXdWVXCiq0hLJO4qiicCu7n0tTMS8pjSABIcTPOCAuoIIA6fz5tvGWjelSUefArHclZYtf2wMRAsdgEXx5NLnTU5uRewgQ3zqcX6ULH)AsVUwMCbPo9g6PwtwEQ3zqcjkhrrJHSEEsiEKxBaAlIhGFJ5qGOpkhrHQO4qiicCu7n0tTMS8pjSABIcTPOK60OyJTO4qiicCu7n0tTMS8pjSABI64POq5OqDuoIIA6fz5tvGWjelSUefArHclZYtf2wMRAsdgEXx5NLnTUHoSsyzOENbjeR7wg(Rj96AzCoQCbPo9g6PwtwEQ3zqcjkhrrn9IS8Pkq4eIfwxIcTOqHLz5PcBlZvnPbdV4R8ZYMw3qPwjSmuVZGeI1Dld)1KEDTmCieeboQ9VA0weBKBmaLdW)KWQTjk0MIIDENgLJO4dAuhpfLtTmlpvyBzUQjny4fFLFw2062y3kHLz5PcBlZOb9b1weJ8RiSXNYnFWYq9odsiw3TP1nuIvcld17miHyD3YWFnPxxldhcbrGJA)Ob9b1weJ8RiSXNYnFW)KWQTbTjroIdNpFciSihXl1)QrBrSrUXauoahCieeboQ9x1Kgm8IVYpl)tcR2g0e5iwMLNkSTmVA0weBKBmaLdWMw3K6eRewgQ3zqcX6ULH)AsVUwg(Gg1XtrXUOCefQIIdHGiWrT)vJ2IyJCJbOCa(NewTnrH2uuonk2ylkoecIah1(rd6dQTig5xryJpLB(G)jHvBtuOnfLtJc1r5ikQPxKLpvbcNqSW6suOfLulZYtf2wg(GINLFtAtRBsLALWYS8uHTLHpO4z53KwgQ3zqcX6UnTUjffwjSmuVZGeI1Dld)1KEDTmOkQLNkqeMAsqjtuOnff7IIn2IcvrnlFV(zia85d5E5ZOCefFq9cRlrH(O4dAuOnfLtIc1rH6OCeLZrD(eqyroIxQ3CQDRTiM)BtyakhquoIYqjEg2YgFQ0JcPyu(KhfAr5elZYtf2wgZP2T2Iy(VnHbOCa206Mu2zLWYq9odsiw3Tm8xt611YS8ubIWutckzIcTPOyxuoIY5OoFciSihXl1Bo1U1weZ)TjmaLdWYS8uHTLXCQDRTiM)BtyakhGnTUjfLTsyzOENbjeR7wMLNkSTmZGlhauoXauoald)1KEDTmoh15taHf5iEP(zWLdakNyakhquoIIpOEH1LOqFu8bnk0MIsAuoIYqjEg2YgFQ0JcPyu(KhfAr5KOCefQIY5OmuINHTSXNk9srjyuCYJcTOCsuSXwu5csD6n0tTMS8uVZGesuO2YK7lsjwVwgeAw(E9c7dadV4CGW8FBY)KWQTXMw3K6uRewgQ3zqcX6ULz5PcBlZm4YbaLtmaLdWYWFnPxxldQIIpOrHwusJIn2IAw(E9Zqa4ZhY9YNrXgBrHQOYfK60tn9IQROTiMavx03t9odsir5ikoecIah1EQPxuDfTfXeO6I((NewTnrDCuCieeboQ9x1Kgm8IVYpl)tcR2MOqDuOokhrHQOqvuCieeboQ9VA0weBKBmaLdW)KWQTjk0IsAuoIcvr5Cu5csD6VQjXWlohi8ObnjCQI07PENbjKOyJTO4qiicCu7VQjXWlohi8ObnjCQI07Fsy12efArjnkuhfBSffFqJcTOq5OqDuoIcvrXHqqe4O2FvtAWWl(k)S8pjSABIcTOKgfBSffFqJcTOqruOok2ylQZNaclYr8s9Pksp(CbfIc1r5ikNJ68jGWICeVu)m4YbaLtmaLdWYK7lsjwVwgeAw(E9c7dadV4CGW8FBY)KWQTXMw3KIoSsyzOENbjeR7wg(Rj96AzOXqwppjeFoqys4KE4BW89C5Ac)OCe1S896ZbctcN0dFdMVNlxt47n5YbefAtrjfLeLJOOMErw(ufiCcXcRlrHwuSZYS8uHTLH)lhaO2Iy23IqyqvCiBTfTP1nPOuRewgQ3zqcX6ULH)AsVUwgAmK1ZtcXNdeMeoPh(gmFpxUMWpkhrnlFV(CGWKWj9W3G575Y1e(EtUCarH2uusr5OCefhcbrGJAVHEQ1KL)jHvBtuhhLu2fLJOYfK60BONAnz5PENbjKOCef10lYYNQaHtiwyDjk0IIDwMLNkSTm8F5aa1weZ(wecdQIdzRTOnTUjDSBLWYq9odsiw3TmlpvyBzMbxoaOCIbOCawg(Rj96AzCoQZNaclYr8s9ZGlhauoXauoGOCefFq9cRlrH(O4dAuOnfL0OCeLHs8mSLn(uPhfsXO8jpk0IYjr5iQz571pdbGpFi3lFAzY9fPeRxldcnlFVEH9bGHxCoqy(Vn5Fsy12ytRBsrjwjSmuVZGeI1DlZYtf2wMufPhFUGcwg(Rj96AzCoQZNaclYr8s9Pksp(CbfIYruoh15taHf5iEPEQPxuDfTfXeO6I(r5ikuffFq9cRlrH(O4dAuOnffkIIn2IIA6fz5tvGWjelSUe1XrXUOqTLj3xKsSETmi0S896f2hagEX5aH5)2K)jHvBJnTUHcNyLWYq9odsiw3TmlpvyBzsvKE85ckyz4VM0RRLX5OoFciSihXl1NQi94Zfuikhr5CuNpbewKJ4L6PMEr1v0wetGQl6hLJOOMErw(ufiCcXcRlrD8uusJYru8b1lSUef6JIpOrH2uuOWYK7lsjwVwgeAw(E9c7dadV4CGW8FBY)KWQTXMw3qHuRewgQ3zqcX6ULH)AsVUwg(Gg1XtrXUOCefQIIdHGiWrT)vJ2IyJCJbOCa(NewTnrH2uuonk2ylkoecIah1(rd6dQTig5xryJpLB(G)jHvBtuOnfLtJc1r5ikQPxKLpvbcNqSW6suOfLulZYtf2wg(GIhTar206gkqHvclZYtf2wg(GIhTarwgQ3zqcX6UnTPLbHURmyALW6MuRewMLNkSTmRCcXBMlhGLH6DgKqSUBtRBOWkHLz5PcBlJ5K2hpSnc2KVcGSmuVZGeI1DBADJDwjSmuVZGeI1Dld)1KEDTmohvUGuNEriebdyFH1t9odsiwgTt6bAbTmOeNyzo5jEGwWCWY4eVtTmlpvyBzsOmFadVya7lS206gkBLWYODspqlOLbL4elZjpXd0cMdwgPENyzwEQW2YKqz(agEXa2xyTmuVZGeI1DBADZPwjSmuVZGeI1Dld)1KEDTmZY3R3qp1AYYlFgfBSf1S896nj8fW0(5aEBe8vFYlFgfBSffQIY5OYfK60BONAnz5PENbjKOCev(AdGs)5d5(vub1KLx(mkuhfBSf1S896NbHqeqzt6FA5zuSXwu5(Iu6tvGWjeJOuuhpff6WjwMLNkSTmNWuHTnTUHoSsyzOENbjeR7wg(Rj96AzY9fP0NQaHtigrPOoEkkuILz5PcBltcL5dy4fJqBoytRBOuRewgQ3zqcX6ULH)AsVUwgufvUGuNEd9uRjlp17miHeLJO4qiicCu7n0tTMS8pjSABI64POCsuOok2ylQz571BONAnz5LpTmlpvyBz4liiE5PcBmOAsldOAsCVcKLXqp1AYYMw3g7wjSmuVZGeI1Dld)1KEDTmohvUGuNEd9uRjlp17miHeLJOqvuZY3R3KWxat7Nd4TrWx9jV8zuSXwuCieeboQ9Me(cyA)CaVnc(Qp55d7lsMOMIcfrHAlZYtf2wg(ccIxEQWgdQM0YaQMe3Razzm01Mw3qjwjSmuVZGeI1Dld)1KEDTmOkkNJkxqQtVHEQ1KLN6DgKqIYruCieeboQ9x1Kgm8IVYpl)tcR2MOoEkkPOikhrXh0OqBkk2fLJO4qiicCu7F1OTi2i3yakhG)jHvBtuhpfL0OqDuSXwu5(Iu6tvGWjeJOuuhpffkCAuSXwuCieeboQ9juMpGHxmcT5G)jHvBtuOfLuPOWYS8uHTLHVGG4LNkSXGQjTmGQjX9kqwgdDTP1nPoXkHLH6DgKqSUBz4VM0RRLbvr5Cu5csD6n0tTMS8uVZGesuoIY5OOXqwppjepYRnaTfXdWVXCiq0hLJO4qiicCu7VQjny4fFLFw(NewTnrD8uuOJOCefFqJcTPOyxuoIIdHGiWrT)vJ2IyJCJbOCa(NewTnrD8uusJc1rXgBrL7lsPpvbcNqmIsrD8uusDAuSXwuCieeboQ9juMpGHxmcT5G)jHvBtuOfLuPOikhrXHqqe4O2Bs4lGP9Zb82i4R(KNpSVizIAkkPwMLNkSTm8feeV8uHngunPLbunjUxbYYyORnTUjvQvcld17miHyD3YWFnPxxlZYtfictnjOKjk0IIDwMLNkSTmVCJxEQWgdQM0YaQMe3RazzwiztRBsrHvcld17miHyD3YWFnPxxlZYtfictnjOKjQJNIIDwMLNkSTmVCJxEQWgdQM0YaQMe3RazzmPnTPLXqxRew3KALWYq9odsiw3TmlpvyBzsvKE85ckyz4VM0RRLX5OoFciSihXl1NQi94Zfuikhr5CuNpbewKJ4L6PMEr1v0wetGQl6hLJOOMErwrnff10lYYlSUeLJO4dAuhhLultUViLy9AzqOz571lSpam8IZbcZ)TjpcCuBtRBOWkHLH6DgKqSUBzwEQW2YWxqq8Ytf2yq1Kwgq1K4EfildhXMw3yNvcld17miHyD3YWFnPxxlJZrnlFVEtcFbmTFoG3gbF1N8YNwMLNkSTmMe(cyA)CaVnc(QpztRBOSvcld17miHyD3YWFnPxxlZYtfictnjOKjk0IIDwMLNkSTm8feeV8uHngunPLbunjUxbYYSqYMw3CQvcld17miHyD3YWFnPxxlZYtfictnjOKjQJNIIDwMLNkSTm8feeV8uHngunPLbunjUxbYYysBAtBAzaIEJcBRBOWjsh7obL6euIxkkXPwMr73AlASmwMZhEvqYYa8OgtxiUCsirntx4trXHcZBg1mjQTXhf7NZPZ0evdB0pSVWvgmQLNkSnrbBqw(4WYtf2g)5tCOW8MtxW1aioS8uHTXF(ehkmVjWMg)cHiXHLNkSn(ZN4qH5nb204RSOa15MkSJdapkMEpndWmQFvKOMLVxcjktUPjQz6cFkkouyEZOMjrTnrTnsuNpH(tyMAlgLAIcb2KpoS8uHTXF(ehkmVjWMg307PzaMytUPjoS8uHTXF(ehkmVjWMg)eMkSJdlpvyB8NpXHcZBcSPX5dkEw(nzCy5PcBJ)8jouyEtGnnoFqXJwGO4qCa4rnMUqC5KqIIaIEwrLQafvoqrT8e(rPMOwGwfCNbjFCy5PcBZ0kNq8M5YbehwEQW2aSPXnN0(4HTrWM8vauCa4rjbuMpef8gf7DFHnkyhfhcbrGJAjJsVr5QHqKOyV7lSrPMOOENbjKOOXqEbJkHrj1jozS0OG3OewxubzHOgOfmhIdlpvyBa204juMpGHxmG9fwj1oPhOfCcL4ejp5jEGwWCyYjENkPENCoxqQtVieIGbSVW6PENbjej1oPhOfCcL4ejp5jEGwWCyYjENghwEQW2aSPXtOmFadVya7lSsQDspql4ekXjsEYt8aTG5WKuVtIdapkxfmvyhLEJIHEQ1KvuWpkMe(csg1yUFoizuBJef6Qpf1(uuYNrb)OybLJAFkQxUBTfJYqp1AYkQTrIAJsy1oktUzu5RnakJ68HCJKrb)OybLJAFkk5gH(OYbkk6EjEgf8g1mieIakBsjJc(rL7lszuPkqrLWOqukk1eL4tBsFuWpkAmKxWOsyuOdNehwEQW2aSPXpHPcBj170S896n0tTMS8YNSX2S896nj8fW0(5aEBe8vFYlFYgBOY5CbPo9g6PwtwEQ3zqcXr(AdGs)5d5(vub1KL)PLNOMn2MLVx)mieIakBs)tlpzJTCFrk9Pkq4eIru64j0HtIdlpvyBa204juMpGHxmcT5GK6Dk3xKsFQceoHyeLoEcLehaEuUEbbJkhOOyONAnzf1Ytf2rbQMmk9gflO8y9POKnAlgfd9uRjRO2gjkg6PwtwrPMOwGwfCNbPOqf8JIfuES(uuC5)PobzfL2rXqp1AYc1XHLNkSnaBAC(ccIxEQWgdQMuYEfOjd9uRjlj17eQYfK60BONAnz5PENbjehCieeboQ9g6Pwtw(NewTnhp5euZgBZY3R3qp1AYYlFghaEuUEbbJkhOOygt0nQLNkSJcunzu6nkwq5X6trjB0wmkMXeDJABKO2NIIl)p1jiRO0okMXeDJc(rnSarrHIOygt0nktUCaM4WYtf2gGnnoFbbXlpvyJbvtkzVc0KHUsQ3jNZfK60BONAnz5PENbjehOAw(E9Me(cyA)CaVnc(Qp5LpzJnoecIah1EtcFbmTFoG3gbF1N88H9fjZekqDCa4r56femQCGIIzmr3OwEQWokq1KrP3OybLhRpfvdZOKnAlgfd9uRjRO2g5OXbGhf6JcDHOBuCKOoEkkPOioa8OqFuUEqJcTPOyxCa4rH(Oosg2BuCKOqBkkPXbGh1y7iJkhOOY9fPmQrkiyuikf1inh0oku40Omeh2iMOgBhzusapIOutuWoQCGIk3xKY4WYtf2gGnnoFbbXlpvyJbvtkzVc0KHUsQ3ju5CUGuNEd9uRjlp17miH4GdHGiWrT)QM0GHx8v(z5Fsy12C8Kuu4GpOOnXohCieeboQ9VA0weBKBmaLdW)KWQT54jPOMn2Y9fP0NQaHtigrPJNqHtzJnoecIah1(ekZhWWlgH2CW)KWQTbnPsrrCa4rnMUS8eKvu5afLzfOOwtuNpbKcLnrbQnjzuZYzuJ0CiQTJArqiKO4dehquJgOCG(OybLJAybIIsAuMC5aIcEJIzmr3Oqp6JQHrDc1oJkHrLdQX5Oqp6JI9abqbvFCa4rT8uHTbytJZxqq8Ytf2yq1Ks2RanzORK6DcvoNli1P3qp1AYYt9odsio4qiicCu7VQjny4fFLFw(NewTnhpjffo4dkAtSZbhcbrGJA)RgTfXg5gdq5a8pjSABoEskQzJTCFrk9Pkq4eIru64ju4u2yJdHGiWrTpHY8bm8IrOnh8pjSABqtQuu4GdHGiWrT3KWxat7Nd4TrWx9jpFyFrYmjnoa8OC9ccgvoqrXmMOBulpvyhfOAYO0BuSGYJ1NIs2OTyum0tTMSIABKJghaEuOpQXsmAlg1rWEW1XbGhf6JcDHOBuCKOoEkk0rCa4rH(OC9GgfAtrXU4aWJc9rDKmS3O4irD8uusJdapQX2rgvoqrL7lszuJuqWOqukQrAoODusDAugIdBetuJTJmkjGhruQjkyhvoqrL7lszuBJeflOCudlquusJYKlhquWBumJj6ghwEQW2aSPX5liiE5PcBmOAsj7vGMm0vs9oHkNZfK60BONAnz5PENbjehotJHSEEsiEKxBaAlIhGFJ5qGO3bhcbrGJA)vnPbdV4R8ZY)KWQT54j0Hd(GI2e7CWHqqe4O2)QrBrSrUXauoa)tcR2MJNKIA2yl3xKsFQceoHyeLoEsQtzJnoecIah1(ekZhWWlgH2CW)KWQTbnPsrHdoecIah1EtcFbmTFoG3gbF1N88H9fjZK04aWJY1liyu5aff7hoMrT8uHDuGQjJsVrLd0trTpfLa8POYHTJIDrrnjOKjoS8uHTbytJ)YnE5PcBmOAsj7vGMwijPENwEQaryQjbLmOXU4aWJY1liyu5affJerT8uHDuGQjJsVrLd0trTpff7Ic(rbsgtuutckzIdlpvyBa204VCJxEQWgdQMuYEfOjtkPENwEQaryQjbLmhpXU4qCa4rX(5PcBJN9dhZOutuANuJqirDHFuYgkQrAoef7bINkhZ(rqWUgKwGOO2gjkU8)uNGSIQjcXevcJAMIcEMQG6kesCy5PcBJFH0eFbbXlpvyJbvtkzVc0ehjoS8uHTXVqcytJtn9IQROTiMavx0xs9o585taHf5iEP(ufPhFUGco4d6XtsDGkoecIah1(xnAlInYngGYb4Fsy12m5e2ydv5csD6VQjXWlohi8ObnjCQI07PENbjehCieeboQ9x1Ky4fNdeE0GMeovr69pjSABMCcQzJnQPxK1Xo1jOooS8uHTXVqcytJVpFBcNW)PoLuVt8b1lSUGE(GI2KuhutVilFQceoHyH1f0MCI3PXHLNkSn(fsaBA8RAsdgEXx5NLK6DkxqQtVHEQ1KLN6DgKqC4mngY65jH4rETbOTiEa(nMdbIEhCieeboQ9g6Pwtw(NewTnOn5uhutVilFQceoHyH1f0qrCy5PcBJFHeWMg)QM0GHx8v(zjPENYfK60BONAnz5PENbjeh0yiRNNeIh51gG2I4b43yoei6DGkoecIah1Ed9uRjl)tcR2g0MK6u2yJdHGiWrT3qp1AYY)KWQT54jug1oOMErw(ufiCcXcRlOHI4WYtf2g)cjGnn(vnPbdV4R8Zss9o5CUGuNEd9uRjlp17miH4GA6fz5tvGWjelSUGgkIdlpvyB8lKa204x1Kgm8IVYplj17ehcbrGJA)RgTfXg5gdq5a8pjSABqBIDEN6GpOhp504WYtf2g)cjGnn(Ob9b1weJ8RiSXNYnFioS8uHTXVqcytJ)QrBrSrUXauoajZ9fPeR3joecIah1(rd6dQTig5xryJpLB(G)jHvBdAtICehoF(eqyroIxQ)vJ2IyJCJbOCao4qiicCu7VQjny4fFLFw(NewTnOjYrIdlpvyB8lKa2048bfpl)Mus9oXh0JNyNduXHqqe4O2)QrBrSrUXauoa)tcR2g0MCkBSXHqqe4O2pAqFqTfXi)kcB8PCZh8pjSABqBYPO2b10lYYNQaHtiwyDbnPXHLNkSn(fsaBAC(GINLFtghwEQW24xibSPXnNA3AlI5)2egGYbiPENq1YtfictnjOKbTj2XgBOAw(E9Zqa4ZhY9YNo4dQxyDb98bfTjNGAu7W5ZNaclYr8s9MtTBTfX8FBcdq5aCyOepdBzJpv6rHumkFYJdlpvyB8lKa204MtTBTfX8FBcdq5aKuVtlpvGim1KGsg0MyNdNpFciSihXl1Bo1U1weZ)TjmaLdioS8uHTXVqcytJpdUCaq5edq5aKm3xKsSENe0(Oi0S896f2hagEX5aH5)2K)jHvBJK6DY5ZNaclYr8s9ZGlhauoXauoah8b1lSUGE(GI2KuhgkXZWw24tLEuifJYNChOYzdL4zylB8PsVuucgfNC2ylxqQtVHEQ1KLN6DgKqqDCy5PcBJFHeWMgFgC5aGYjgGYbizUViLy9ojO9rrOz571lSpam8IZbcZ)Tj)tcR2gj17eQ4dkAszJTz571pdbGpFi3lFYgBOkxqQtp10lQUI2IycuDrFp17miH4GdHGiWrTNA6fvxrBrmbQUOV)jHvBZXCieeboQ9x1Kgm8IVYpl)tcR2guJAhOcvCieeboQ9VA0weBKBmaLdW)KWQTbnPoqLZ5csD6VQjXWlohi8ObnjCQI07PENbje2yJdHGiWrT)QMedV4CGWJg0KWPksV)jHvBdAsrnBSXhu0qzu7avCieeboQ9x1Kgm8IVYpl)tcR2g0KYgB8bfnuGA2y78jGWICeVuFQI0Jpxqbu7W5ZNaclYr8s9ZGlhauoXauoG4WYtf2g)cjGnno)xoaqTfXSVfHWGQ4q2AlkPENOXqwppjeFoqys4KE4BW89C5AcFhZY3RphimjCsp8ny(EUCnHV3KlhaAtsrjoOMErw(ufiCcXcRlOXU4WYtf2g)cjGnno)xoaqTfXSVfHWGQ4q2AlkPENOXqwppjeFoqys4KE4BW89C5AcFhZY3RphimjCsp8ny(EUCnHV3KlhaAtsrzhCieeboQ9g6Pwtw(NewTnhlLDoYfK60BONAnz5PENbjehutVilFQceoHyH1f0yxCy5PcBJFHeWMgFgC5aGYjgGYbizUViLy9ojO9rrOz571lSpam8IZbcZ)Tj)tcR2gj17KZNpbewKJ4L6NbxoaOCIbOCao4dQxyDb98bfTjPomuINHTSXNk9OqkgLp5oMLVx)mea(8HCV8zCy5PcBJFHeWMgpvr6XNlOGK5(IuI17KG2hfHMLVxVW(aWWlohim)3M8pjSABKuVtoF(eqyroIxQpvr6XNlOGdNpFciSihXl1tn9IQROTiMavx03bQ4dQxyDb98bfTjuWgButVilFQceoHyH1LJzhQJdlpvyB8lKa204Pksp(CbfKm3xKsSENe0(Oi0S896f2hagEX5aH5)2K)jHvBJK6DY5ZNaclYr8s9Pksp(CbfC485taHf5iEPEQPxuDfTfXeO6I(oOMErw(ufiCcXcRlhpj1bFq9cRlONpOOnHI4WYtf2g)cjGnnoFqXJwGij17eFqpEIDoqfhcbrGJA)RgTfXg5gdq5a8pjSABqBYPSXghcbrGJA)Ob9b1weJ8RiSXNYnFW)KWQTbTjNIAhutVilFQceoHyH1f0KghwEQW24xibSPX5dkE0cefhIdlpvyB8CKjTbccGWUitnohi8ObnjCQI0hhwEQW245iaBA8zqiebFLFwXHLNkSnEocWMgFMEd9a0wmoa8OglXqrX(F(2uusa)N6mk9gflOCu7trjOgJ2IrTzuG0AYOKgLRh0O2gjQrWESMrX3ZOOMErwrnsZbTJYjENgLH4WgXehwEQW245iaBA895Bt4e(p1PK6DIpOEH1f0Zhu0MK6GA6fz5tvGWjelSUG2Kt8onoS8uHTXZra204GQ4qAWSpzerbQZ4aWJY1RjJsc4refNfhuBXOYHhkloefkIk3xKstu69OXbGhf6JcDcLhRpfLSrBXOypmwgDLioa8OqFuOtO8h15taPqztuUAxFernAnr1WmkjGhrCy5PcBJNJaSPXtOmFadVyeAZbjZ9fPeR3jbTpkcnlFV(ekZhWWlgH2CW)KWQTrs9orJHSEEsi(bfbHASWAs6n4l8NveeQXjuMp4W5ZNaclYr8s9juMpGHxmcT5qCa4rjXafLH4Wgjk(AYOG3OsOmFadVyeAZHOYxffPNqIAMvu5affijsnY(SIIUxINrbVrnOiiuJfwtsVbFH)SIGqnoHY8HJghaEuOpk0juEScef1c(0IWkk(AYOYbkQR(MmkjGhrCa4rH(Oygt0nk1evUGuNesuBJe1ifemQzkQfOvb3zqkQz6cFkkwq5pQMCjJYvdcNxWOCnecIah1XbGhf6JcDcL)OoFcifkBIYv76JiQrRjQgMrjb8iIdapk0h1rscR2AlgfhcbrGJ6OGDuORAYOG3Oqx5NvuQjkq4i6Jc(rrJH8cgvcJcLJYqCyJyIdapk0h1rscR2AlgfhcbrGJ6OGDuhPA0wmkg5ok2RYbeLAIceoI(OYHTJcLgLH4WgXehwEQW245iaBA8ekZhWWlgH2CqYCFrkX6Dsq7JIqZY3RpHY8bm8IrOnh8pjSABKuVtOcv5csD6n0tTMS8uVZGeIdoecIah1Ed9uRjl)tcR2MJNKIAhCieeboQ9x1Kgm8IVYpl)tcR2MJNqzu7GdHGiWrT)vJ2IyJCJbOCa(NewTnhJsD485taHf5iEP(ekZhWWlgH2Cioa8OKyGIYqCyJefFnzuWBujuMpGHxmcT5qu5RII0tirnZkQCGIcKePgzFwrr3lXZOG3OgueeQXcRjP3GVWFwrqOgNqz(WrJdapk0hf6ekpwbIIAbFAryffFnzu5af1vFtgLeWJioa8OqFuhjjSARTyuCieeboQJc2rHUQjnrbVrHUYpROutuGWr0hf8JIgd5fmQegfkhLH4WgXef73TJikMXeDJsnrLli1jHe12irnsbbJAMIAbAvWDgKIAMUWNIIfu(JQjxYOC1GW5fmkxdHGiWrDuJTJmkwq5OgwGOOqruWpkb4tr56bnoa8OqFuOtO8h15taPqztuUAxFernAnr1WmkjGhrCa4rH(Oossy1wBXO4qiicCuhfSJ6ivJ2IrXi3rXEvoGOutuIpT5a9rLdBhfknkdXHnIjoS8uHTXZra204juMpGHxmcT5GK5(IuI17KG2hfHMLVxFcL5dy4fJqBo4Fsy12iPENqfQCoxqQtVHEQ1KLN6DgKqCWHqqe4O2Bs4lGP9Zb82i4R(K)jHvBZXtsrnBSXhu0MqbQDWHqqe4O2FvtAWWl(k)S8pjSABoEcLDWHqqe4O2)QrBrSrUXauoa)tcR2MJrPoC(8jGWICeVuFcL5dy4fJqBoehIdlpvyB8g6oLQi94ZfuqYCFrkX6DcHMLVxVW(aWWlohim)3M8iWrTK6DY5ZNaclYr8s9Pksp(CbfC485taHf5iEPEQPxuDfTfXeO6I(oOMErwtutVilVW6Id(GES04WYtf2gVHUaBAC(ccIxEQWgdQMuYEfOjosCy5PcBJ3qxGnnUjHVaM2phWBJGV6tsQ3jNNLVxVjHVaM2phWBJGV6tE5Z4WYtf2gVHUaBAC(ccIxEQWgdQMuYEfOPfssQ3PLNkqeMAsqjdASloS8uHTXBOlWMgNVGG4LNkSXGQjLSxbAYKsQ3PLNkqeMAsqjZXtSloehaEuUEnzusOI0hLRAbfIs7OYbkkdDXWtQPpoa8OqFu6nQCGI68jGuOSjQDwb1KvuJwtunmJkvr6XNlOqCa4rH(O0Bu5af15taPqztu7ScQjROgTMOAygf10lQUI2IycuDr)O2gjkwq5O2NIQHzuBgLW6Ikilef10lYkoa8OqFu6nkwq5OgwGOOCsu8bnoa8OqFuORAsdgEXx5NvuQjk49gLRHqqe4OooS8uHTXBOlgEsn9tPksp(CbfKm3xKsSENe0(Oi0S896f2hagEX5aH5)2K)jHvBJK6DY5ZNaclYr8s9Pksp(CbfC485taHf5iEPEQPxuDfTfXeO6I(oOMErwtutVilVW6Id(GESuhCieeboQ9x1Kgm8IVYpl)tcR2MJNCsCa4r56femQLNkSnEosu69OXbGhf6JcDvtgf8gf6k)SIAKccg1mf1c0QG7miffSJIfu(JQjxYOC1GW5fmkoecIah1XHLNkSnEdDXWtQPhytJZxqq8Ytf2yq1Ks2RanXrKuVtCieeboQ9x1Kgm8IVYpl)tcR2g0KghwEQW24n0fdpPMEGnn(RgTfXg5gdq5aKm3xKsSENe0(Oi0S896f2hagEX5aH5)2K)jHvBJK6DA5PceHPMeuYCm7IdapkjgutuGAtrPMOGYjYMesuBJe15dN3zqwrPnh(pXZO0oQZxHVMSIdlpvyB8g6IHNutpWMgFgC5aGYjgGYbizUViLy9ojO9rrOz571lSpam8IZbcZ)Tj)tcR2gj17eQC(8jGWICeVu)m4YbaLtmaLda1XbGhLRxtgf6QMmk4nk0v(zfLEpACa4rH(OKyGI6jHvBTfJIdHGiWrDuWoQxnAlInYngGYbeLAIce2I0hvoSDu5affFy7MaJcr(3uHDuWBuORAsdgEXx5NvCy5PcBJ3qxm8KA6b204x1Kgm8IVYplj17ehcbrGJA)vnPbdV4R8ZYJi)BQWgnoecIah1(xnAlInYngGYb4Fsy12ehwEQW24n0fdpPMEGnnEQI0JpxqbjZ9fPeR3jbTpkcnlFVEH9bGHxCoqy(Vn5Fsy12iPENC(8jGWICeVuFQI0JpxqbhoF(eqyroIxQNA6fvxrBrmbQUOVd(GojnoehwEQW24n0tTMSMsvKE85ckizUViLy9ojO9rrOz571lSpam8IZbcZ)Tj)tcR2gj17KZNpbewKJ4L6tvKE85ck4W5ZNaclYr8s9utVO6kAlIjq1f9Dqn9ISMOMErwEH1fh8b9yPoCEw(E9g6PwtwE5Z4WYtf2gVHEQ1KfWMgNVGG4LNkSXGQjLSxbAIJehwEQW24n0tTMSa204g6PwtwXHLNkSnEd9uRjlGnn(RgTfXg5gdq5aKm3xKsSENe0(Oi0S896f2hagEX5aH5)2K)jHvBJK6DA5PceHPMeuYCm7Idapk2JK4YzfLHvNRlrDHFusifLmUeOWjrHoo5XHLNkSnEd9uRjlGnn(vnPbdV4R8Zss9oHkurJHSEEsiEKxBaAlIhGFJ5qGO3XS896pFYyKFcFc1o9pjSABoEcfomuINHTSXNk9OWjyu(KJAhOIdHGiWrT)vJ2IyJCJbOCa(NewTnOjLn2wEQaryQjbLmOjf1OwsTt6F5ZCsACa4r561KrHUQjJcEJcDLFwrP3JghaEuOpkjgOOEsy1wBXO4qiicCuhfSJ6vJ2IyJCJbOCarPMOaHTi9rLdBhvoqrXh2UjWOqK)nvyhf8gf6QM0GHx8v(zfhwEQW24n0tTMSa204x1Kgm8IVYplj17eQqLZ0yiRNNeIh51gG2I4b43yoei6zJTz571pdcHiGYM0lFYgBZY3R3qp1AYY)KWQT5yPO2bQ4qiicCu7F1OTi2i3yakhG)jHvBdAszJTLNkqeMAsqjdAsrnQLu7K(x(mNKghwEQW24n0tTMSa204MtTBTfX8FBcdq5aKuVtlpvGim1KGsg0MyNdNpFciSihXl1Bo1U1weZ)TjmaLdioS8uHTXBONAnzbSPXNbxoaOCIbOCasM7lsjwVtcAFueAw(E9c7dadV4CGW8FBY)KWQTrs9oHkNpFciSihXl1pdUCaq5edq5aqTduD(eqyroIxQ)QMedV4CGWJg0KWPkspBSD(eqyroIxQ)QM0GHx8v(zHAhlpvGim1KGsMJrrCy5PcBJ3qp1AYcytJ)QrBrSrUXauoajZ9fPeR3jbTpkcnlFVEH9bGHxCoqy(Vn5Fsy12iPENwEQaryQjbLmOnXU4WYtf2gVHEQ1KfWMgFgC5aGYjgGYbizUViLy9ojO9rrOz571lSpam8IZbcZ)Tj)tcR2gj17KZNpbewKJ4L6NbxoaOCIbOCaXH4aWJI9Ztf2gpd9uRjl8y7KA6Jsnr5gmJcDszuSNcNGKa1jHefQCdDYEI64WYtf2gVHEQ1KfgEsn9tPksp(CbfKm3xKsSENe0(Oi0S896f2hagEX5aH5)2K)jHvBJK6DY5ZNaclYr8s9Pksp(CbfC485taHf5iEPEQPxuDfTfXeO6I(oOMErwtutVilVW6Id(GESuhoplFVEd9uRjlV8PdoecIah1(RAsdgEXx5NL)jHvBZXtojoS8uHTXBONAnzHHNutpWMgFF(2eoH)tDkPEN4dQxyDb98bfTjPoOMErw(ufiCcXcRlOn5eVtJdlpvyB8g6Pwtwy4j10dSPX5liiE5PcBmOAsj7vGM4isQ3joecIah1(RAsdgEXx5NL)jHvBdAsJdlpvyB8g6Pwtwy4j10dSPXn0tTMSKuVtCieeboQ9x1Kgm8IVYpl)tcR2g0KghwEQW24n0tTMSWWtQPhytJ)QrBrSrUXauoajZ9fPeR3jbTpkcnlFVEH9bGHxCoqy(Vn5Fsy12iPENwEQaryQjbLmhZohZY3R3qp1AYYlFghaEuUEnzuORAsdgEXx5Nvu6noa8OqFuhPA0wmkg5ok2RYbyI6jHvBTfJIdHGiWrDuQjkqylsFu5W2rjnkdXHnsCa4rH(Oyp7K(x(mJcDvtAWWl(k)SIAKMdrDKQrBXOyK7OyVkhqu6nkg6Pwtwr9KWQTjoS8uHTXBONAnzHHNutpWMg)QMedV4CGWJg0KWPksVK6DAw(E9g6PwtwE5Z4WYtf2gVHEQ1KfgEsn9aBA8zWLdakNyakhGK5(IuI17KG2hfHMLVxVW(aWWlohim)3M8pjSABKuVtOY5ZNaclYr8s9ZGlhauoXauoau7avNpbewKJ4L6VQjXWlohi8ObnjCQI0J64WYtf2gVHEQ1KfgEsn9aBA8RAsdgEXx5NLK6DIdHGiWrT)vJ2IyJCJbOCa(NewTnOjLn2MLVxVHEQ1KLhboQLu7K(x(mNKghwEQW24n0tTMSWWtQPhytJpdUCaq5edq5aKm3xKsSENe0(Oi0S896f2hagEX5aH5)2K)jHvBJK6DAw(E9g6PwtwEe4O2bFqpEcfo4qiicCu7n0tTMS8pjSABoEYjooFciSihXl1NQi94ZfuioS8uHTXBONAnzHHNutpWMgpvr6XNlOGK5(IuI17KG2hfHMLVxVW(aWWlohim)3M8pjSABKuVtoF(eqyroIxQpvr6XNlOGdNpFciSihXl1tn9IQROTiMavx03bFqNKghIdapQJGURmyg1Ytf2rbQMmoS8uHTXBYjTbccGWUitnohi8ObnjCQI0hhwEQW24njWMg3KWxat7Nd4TrWx9jj17KZZY3R3KWxat7Nd4TrWx9jV8zCa4r5griMOsyuZuupn61mPoQl8JYD0L9hhwEQW24njWMg)LndAlIzFlcHhPnIK6DAw(E9VSzqBrm7Bri8iTr8iWrTdNpFciSihXl1)YMbTfXSVfHWJ0gjoS8uHTXBsGnno10lQUI2IycuDrFj17KZNpbewKJ4L6tvKE85ckehaEusGcPrzOmQzylBIIdBenvyVGXbGhLRxtgL7GlhauoJI9QCarP3JghaEuOpkx1taPqztuUAxFernAnr1Wmk3bxoaOCgf7v5aIdapk0hL7GlhauoJI9QCaohLAIAbAvWDgKIdapk0hf6ekpwFkQgMrTzucRlr56bnoS8uHTXBsGnn(m4YbaLtmaLdqYCFrkX6Dsq7JIqZY3RxyFay4fNdeM)Bt(NewTnsQ3jNpFciSihXl1pdUCaq5edq5aCWhuVW6c65dkAtsDyOepdBzJpv6rHumkFYDmlFV(zia85d5E5Z4aWJY1RjJscvK(OCvlOqu69OXbGhf6JYv9eqku2eLR21hruJwtunmJscvK(OCvlOqCa4rH(OCvpbKcLnr5QD9re1O1evdZOgZXmku52ytIX8Or9eICJSDg1mXxzdff8gvoqrnMn9ISIIpqCasgvteIjQeg1mf1tJEntQJ6c)OChDz)Oooa8OqFuOtOCuJuqWO47zuJztViROMPl8POAYLmkxTRpI4aWJc9rHoHYrnsbbJsC1okuef8Jsa(uuUEqJdlpvyB8MeytJNQi94ZfuqYCFrkX6Dsq7JIqZY3RxyFay4fNdeM)Bt(NewTnsQ3jNpFciSihXl1NQi94ZfuWHZNpbewKJ4L6PMEr1v0wetGQl67GA6fz5tvGWjelSUC8Kuh8b1lSUGE(GI2ekC48S896n0tTMS8YNXbGhLRxtgf6cZXcjIsVrXckh1ifemkXv7OyxuWpkb4tr56bnoS8uHTXBsGnn(vnjgEX5aHhnOjHtvKEj17eFq9cRlONpOOnXU4WYtf2gVjb204Jg0huBrmYVIWgFk38H4aWJY1RjJ6ivJ2IrXi3rXEvoGO07rJdapk0hf6ekh1(uuYgTfJIzmrxjJABKOybLJAybIIIDrb)OeGpfLRh0Oy)UDerHYojk4hLa8POOMErwrn2oYOCAuWpkb4tr56bnoa8OqFuOtOCu7trjB0wmkg6Pwtwsgf6ik4hLa8POmeh2iMOEsy1okyhvoqrXHqqe4Ook4nkg6Pwtwsg12irXckh1Wceff7Ic(rjaFkkxpOrX(D7iIcLDsuWpkb4trrn9ISIASDKr50OGFucWNIY1dAuXHLNkSnEtcSPXF1OTi2i3yakhGK5(IuI17KG2hfHMLVxVW(aWWlohim)3M8pjSABKuVtOcv8bfTj25GA6fzH2ek7euZgB8bfTjNIAhOkxqQtVHEQ1KLN6DgKqyJnoecIah1Ed9uRjl)tcR2g0MqhOooa8OypsIlNvuCyJOPc7fmQl8J6iETbOTyuShGFhLRHarFCy5PcBJ3KaBA8RAsdgEXx5NLK6DkxqQtVHEQ1KLN6DgKqC4mngY65jH4rETbOTiEa(nMdbIEhCieeboQ9g6Pwtw(NewTnOn5uhutVilFQceoHyH1f0qrCa4rXEKexoRO4Wgrtf2lyux4h1r8AdqBXOypa)okxdbI(4WYtf2gVjb204x1Kgm8IVYplj17uUGuNEd9uRjlp17miH4Ggdz98Kq8iV2a0wepa)gZHarVduXHqqe4O2BONAnz5Fsy12G2KuNYgBCieeboQ9g6Pwtw(NewTnhpHYO2b10lYYNQaHtiwyDbnuehaEuUEnzuORAstuWBuOR8Zkk9E04aWJc9rHoHYrTpfLSrBXOygt0noS8uHTXBsGnn(vnPbdV4R8Zss9o5CUGuNEd9uRjlp17miHehaEuUEnzuhjd7nk9E04aWJc9rHoHYrTpfLSrBXOygt0nQX2rgflOCu7trjB0wmkg6PwtwrTnsuonk4hLa8POmeh2iMOEsy1okyhvoqrXHqqe4Ook4nkg6PwtwXHLNkSnEtcSPXF1OTi2i3yakhGK5(IuI17KG2hfHMLVxVW(aWWlohim)3M8pjSABKuVtCieeboQ9g6Pwtw(NewTnOn5u2ydvoNli1P3qp1AYYt9odsiOooa8OC9AYOChC5aGYzuSxLdik9E04aWJc9r5QEcifkBIYv76JiQrRjQgMr5oK9ghaEuOpk0juoQ9POAyg1MrjSUeLRh04WYtf2gVjb204ZGlhauoXauoajZ9fPeR3jbTpkcnlFVEH9bGHxCoqy(Vn5Fsy12iPENC(8jGWICeVu)m4YbaLtmaLdWbFq9cRlONpOOnjnoa8OypsIlNvux4hLeduuJPWj9W3eLR3ZLRj8JdlpvyB8MeytJZ)LdauBrm7BrimOkoKT2IsQ3jAmK1ZtcXNdeMeoPh(gmFpxUMW3XS896ZbctcN0dFdMVNlxt47n5YbG2KuuIdQPxKLpvbcNqSW6cASloS8uHTXBsGnno)xoaqTfXSVfHWGQ4q2AlkPENOXqwppjeFoqys4KE4BW89C5AcFhZY3RphimjCsp8ny(EUCnHV3KlhaAtsrzhCieeboQ9g6Pwtw(NewTnhlLDoYfK60BONAnz5PENbjehutVilFQceoHyH1f0yxCy5PcBJ3KaBA8zWLdakNyakhqCy5PcBJ3KaBAC(GIhTarXbGh1yHccgvtesujmQzkQNg9AMuh1f(r5o6Y(Jdapkxl)p1zuVmiD0OC9AYOC9GgL7YVjJsVhnoa8OqFuOtOCudlquuSlk4hfizmr56bnoa8OqFuhjd7nk1eL8zuAhLtJc(rjaFkkdXHnIjQX2rg1yXr4QIsnrjFgL2r50OGFucWNIYqCyJyIdapk0hf6ekh1ifemQgMrX3ZOOMErwrntx4trLduun5sgLR21hrCy5PcBJ3KaBAC(GINLFtkPENOMErw(ufiCcXcRlOj1rUGuNEd9uRjlp17miHehaEuUEnzusOI0hLRAbfIsVhnoa8OqFuUQNasHYMO2zfutwrnAnr1Wmkjur6JYvTGcrb)OgZMEr1v0wmQXeuDr)4aWJc9rHoHYrnsbbJsC1oQnJcKwtgfkIY1dQKrn2oYOybLJAKccgfFpJIA6fzf1inh0ok2fLH4WgXefQCBSjXyE0OCnugejk(AYOKWvffbe1rTzuonkxpOrX(KnzujmQZNaI6mkQPxKvu898uBrjJs7OYbc(SqDCy5PcBJ3KaBA8ufPhFUGcsM7lsjwVtcAFueAw(E9c7dadV4CGW8FBY)KWQTrs9o585taHf5iEP(ufPhFUGcoC(8jGWICeVup10lQUI2IycuDrFhOIpOEH1f0Zhu0MqbBSrn9IS8Pkq4eIfwxoMDO2HZZY3R3qp1AYYlFghwEQW24njWMgNpO4z53KsQ3j(G6fwxqpFqrBIDoOMErw(ufiCcXcRlOj1HZ5csD6n0tTMS8uVZGeILzLZb4BzyubxBtBATa]] )
end