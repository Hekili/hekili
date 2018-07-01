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
            if last_combo == key then state.removeBuff( "hit_combo" )
            else state.addStack( "hit_combo", 10, 1 ) end

            virtual_combo = key
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        if state.prev_gcd[1].tiger_palm and ( class.abilities.tiger_palm.lastCast == 0 or state.combat == 0 or class.abilities.tiger_palm.lastCast < state.combat ) then
            state.prev_gcd.override = "none"
            state.prev.override = "none"
        end
        state.spinning_crane_kick.count = nil
        virtual_combo = nil
    end )
    
    spec:RegisterHook( "spend", function( amt, resource )
        if state.talent.spiritual_focus.enabled then
            if state.buff.storm_earth_and_fire.up then state.buff.storm_earth_and_fire.expires = state.buff.storm_earth_and_fire.expires + 1 end
            if state.buff.serenity.up then state.buff.serenity.expires = state.buff.serenity.expires + 1 end
        end

        if state.level < 116 then
            if state.equipped.the_emperors_capacitor and resource == 'chi' then
                state.addStack( "the_emperors_capacitor", 30, 1 )
            end
        end
    end )

    spec:RegisterHook( "IsUsable", function( spell )
        if state.talent.hit_combo.enabled then
            if spell == 'tiger_palm' then
                local lc = class.abilities[ spell ].lastCast or 0                
                if ( state.combat == 0 or lc >= state.combat ) and last_combo == spell then return false end
            elseif last_combo == spell then return false end
        end
    end )


    spec:RegisterStateTable( "spinning_crane_kick", setmetatable( { onReset = function( self ) self.count = nil end },
        { __index = function( t, k )
                if k == 'count' then
                    t[ k ] = max( GetSpellCount( state.action.spinning_crane_kick.id ), state.active_dot.mark_of_the_crane )
                    return t[ k ]
                end
        end } ) )

    spec:RegisterStateExpr( "gcd", function () return 1.0 end )


    -- Abilities
    spec:RegisterAbilities( {
        blackout_kick = {
            id = 100784,
            cast = 0,
            cooldown = 3,
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
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 608938,

            talent = "energizing_elixir",
            
            usable = function () return energy.current < 0.5 * energy.max and chi.deficit >= 2 end,
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
            
            recheck = function () return buff.storm_earth_and_fires.remains end,
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

            usable = false,
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
    } )

    spec:RegisterPack( "Windwalker", 20180630.2045, 
        [[diuKSbqiKspcPGWMGOrjQ0Pev8kPGzrjClPQ0Ui6xuQmmKkogewMuONjvvttksxdPOTjvf9nKkvJdPs5CifyDsrmpPOUhvzFuvDqKcIwiLQEisbfxePGuJePGKojsbLwjsv3ePGe7KsPNc0uPu8vKcQ2lH)QYGP4WkwSu6XGMmGlJAZQQpJKrlkNM0Qrk0RLkZwvUnK2TWVrmCr64svHLR0ZPY0LCDrSDPkFNQY4PeDEkP1JujZxu1(HAbcHncqGPyHTnshe0n60N9thzJ0PP9z)0nbyznLfGPdSBOybymOSaKgUga(MxhVcW0X6JmacBeGosYczbywvPUMyNDuALL0kHeu7CkAYBkLeWD(LDoffAx7J0Ax7F6la3ZU0L81h7SZgL3gryNnnI4OHcj6oA4Aa4BED8kDkkua2MOVIg2q0kabMIf22iDqq3OtF2pDKiOB0ebnP7cqxkdf22yFsdeGaSdkaTjtDyJ6WMkJXga(pjVcBOHRbGV51Xl2mWsjb2KoWoS5twSX(PQhJnFYIn0qsx8sQmjMEm90WwyJVXHnTj6RWM)sqXMkJXg6USFjnXgqfn5nLscAy25xyt6s(6JLy6X0tdt2euSRjy6riXgSzCzd6eS7(lh0LvSX34WMLtFdKbWMwRyZxD1r(xLXNVmT4RukEXMCR5XrLJetpM(gLyd2SjXnWsjX9uxHnQdBsCma28jl24k7gcJndSusGnp1voSPLHtIJXMkJTInZYydAsLmVN1(YwcFjoThlX0JPVFj2Gn0qcaWayZGnWDGDpnOoACa47PuzvObf2813JxSzGLscSXrWMkBkSrlSXN(EytlJnldjOOCaWayJVmoWgRKeSbvDoSzWMsP49sNhk2qwSXkjzXgyMInamCS6WgssHnKp2ajOTtHnPl3JJsdkSPukEV05HIn)LGInTSguyZYqckkhama2u(uiJnAGnd2SeFsb4tDLtyJaeG)tYRe2iSfHWgb4alLecWjPi3u1a7eGCmTpgqyVOe22OWgbiht7Jbe2laHRw8QJaSMLIlja3M8)s44knOKlpWsaoWsjHa0LYZEztaCUA1owucB7xyJauJI3EZtasdOJamfwxgpVktashjnfGdSusialscm7i)RBw0raYX0(yaH9IsyBtf2ia5yAFmGWEbiC1IxDeGTj)V0XlhAzvMKIn5ZJnTj)V0vKf94zRSBcG7RlltsXM85XMCXgAXMAECushVCOLvjht7JbWgKytTA0XLmDjq5qPpTSktsXMCWM85XM2K)x2(ieGxIRKlpWcBYNhBQzP4swkkFf5augBA2dB6t6iahyPKqaMskLeIsylnf2ia5yAFmGWEbiC1IxDeG1SuCjlfLVICakJnn7Hn0ab4alLecWIKaZoY)a4PYeLW2(uyJaKJP9Xac7fGWvlE1raMl2uZJJs64LdTSk5yAFma2GeBGeYdG4lKoE5qlRYLrhnCytZEydDWMCWM85XM2K)x64LdTSktsfGdSusiaHZ7DdSusCp1vcWN6Qlguwa64LdTSkkHT0DHncqoM2hdiSxacxT4vhbiTytnpokPJxo0YQKJP9XaydsSjxSPn5)LUISOhpBLDtaCFDzzsk2Kpp2ajKhaXxiDfzrpE2k7Ma4(6Ysy2SuSdB8WMgXMCeGdSusiaHZ7DdSusCp1vcWN6Qlguwa64VOe2s3e2ia5yAFmGWEbiC1IxDeG0In184OKoE5qlRsoM2hdGniXgUps00ugqcSA0Pb1Lr24GKE8IniXMCXgiH8ai(c5xD1r(xLXNVmT4RukELlJoA4WMM9Wge0nSbj2ajKhaXxi)QRCh5F)K1QCz0rdh20Sh2GOrSbj2aZuSXVh20p2GeBGeYdG4lKR60G6CjX1PWo5YOJgoSPzpSbb2Kpp2uZsXLSuu(kYbOm20Sh20inXM85XgiH8ai(czrsGzh5Fa8uzYLrhnCyJFSbbIgXMCWgKydKqEaeFH0vKf94zRSBcG7RllHzZsXoSXdBqiahyPKqacN37gyPK4EQReGp1vxmOSa0XFrjSLgiSraYX0(yaH9cq4QfV6iaPfBQ5XrjD8YHwwLCmTpgaBqIn0InCFKOPPmGey1OtdQlJSXbj94fBqIn5Inqc5bq8fYV6QJ8VkJpFzAXxPu8kxgD0WHnn7HniAk2GeBGeYdG4lKF1vUJ8VFYAvUm6OHdBA2dB6tSbj2aZuSXVh20p2GeBGeYdG4lKR60G6CjX1PWo5YOJgoSPzpSbb2Kpp2uZsXLSuu(kYbOm20Sh2GGMyt(8ydKqEaeFHSijWSJ8paEQm5YOJgoSXp2GarJytoydsSbsipaIVq6kYIE8Sv2nbW91LLWSzPyh24HnieGdSusiaHZ7DdSusCp1vcWN6Qlguwa64VOe2IGocBeGCmTpgqyVaeUAXRocWbwAp(4Grv2Hn(XM(fGdSusiaHZ7DdSusCp1vcWN6QlguwaoewucBrGqyJaKJP9Xac7fGWvlE1raoWs7XhhmQYoSPzpSPFb4alLecq48E3alLe3tDLa8PU6IbLfGUsuIsaoewyJWwecBeGCmTpgqyVaCGLscbiCEVBGLsI7PUsa(uxDXGYcqiGOe22OWgbiht7Jbe2laHRw8QJaKwSjD5EhfeqIqwkfVx68qXgKydmtXMM9WgeydsSjxSbsipaIVqUQtdQZLexNc7KlJoA4WgpSHoyt(8ytUytnpok5xD1r(xLXNVmT4RukELCmTpgaBqInqc5bq8fYV6QJ8VkJpFzAXxPu8kxgD0WHnEydDWMCWM85Xgo4LYk20m2qt6Gn5iahyPKqaYbVukDPb1Xp1sDfLW2(f2ia5yAFmGWEbiC1IxDeGWmvIowIn9fBGzk243dBqGniXgo4LYQSuu(kYHowIn(9Wg6iPPaCGLscb4SWj4Ri7YrjkHTnvyJaKJP9Xac7fGWvlE1rawZJJs64LdTSk5yAFma2GeBOfB4(irttzajWQrNguxgzJds6Xl2GeBGeYdG4lKoE5qlRYLrhnCyJFpSHMydsSHdEPSklfLVICOJLyJFSPrb4alLecWV6k3r(3pzTkkHT0uyJaKJP9Xac7fGWvlE1rawZJJs64LdTSk5yAFma2GeB4(irttzajWQrNguxgzJds6Xl2GeBYfBGeYdG4lKoE5qlRYLrhnCyJFpSbbnXM85XgiH8ai(cPJxo0YQCz0rdh20Sh20uSjhSbj2WbVuwLLIYxro0XsSXp20OaCGLscb4xDL7i)7NSwfLW2(uyJaKJP9Xac7fGWvlE1rasl2uZJJs64LdTSk5yAFma2GeB4GxkRYsr5Rih6yj24hBAuaoWsjHa8RUYDK)9twRIsylDxyJaKJP9Xac7fGWvlE1racjKhaXxix1Pb15sIRtHDYLrhnCyJFpSPFjnXgKydmtXMM9WgAkahyPKqa(vx5oY)(jRvrjSLUjSraoWsjHa0xMUpnOoGDOiXLMeWmbiht7Jbe2lkHT0aHncqoM2hdiSxacxT4vhbiKqEaeFH0xMUpnOoGDOiXLMeWm5YOJgo)EuqaK0MUCVJccirix1Pb15sIRtHDiHeYdG4lKF1vUJ8VFYAvUm6OHZpfeqaoWsjHaCvNguNljUof2jkHTiOJWgbiht7Jbe2laHRw8QJaeMPs0XsSPVydmtXg)ydcSbj2ql2KUCVJcciri3exMguhnoa85tdab4alLecWnXLPb1rJdaF(0aqucBrGqyJaKJP9Xac7fGWvlE1racZuSPzpSPFSbj2Kl2ajKhaXxix1Pb15sIRtHDYLrhnCyJFpSHMyt(8ydKqEaeFH0xMUpnOoGDOiXLMeWm5YOJgoSXVh2qtSjhSbj2WbVuwLLIYxro0XsSXp2GqaoWsjHaeMPxBY6krjSfrJcBeGdSusiaHz61MSUsaYX0(yaH9IsylI(f2ia5yAFmGWEbiC1IxDeG5IndS0E8XbJQSdB87Hn9Jn5ZJn5InTj)VSL0DPlbktsXgKydmtLOJLytFXgyMIn(9Wg6Gn5Gn5GniXgAXM0L7DuqajcPlvJqdQdUtWxNc7WgKyJJRRLejozP82iIRPPqSXp2qhb4alLecqxQgHguhCNGVof2jkHTiAQWgbiht7Jbe2laHRw8QJaCGL2JpoyuLDyJFpSPFSbj2ql2KUCVJcciriDPAeAqDWDc(6uyNaCGLscbOlvJqdQdUtWxNc7eLWwe0uyJaKJP9Xac7fGdSusiaBFdSJKuxNc7eGWvlE1rasl2KUCVJcciriBFdSJKuxNc7WgKydmtLOJLytFXgyMIn(9WgeydsSXX11sIeNSuEBeX10ui24hBOd2GeBYfBOfBCCDTKiXjlLxe0GRXui24hBOd2Kpp2uZJJs64LdTSk5yAFma2KJaSMLIRt)cqunAca3M8)s0z7oY)Qm(G7eSCz0rdNOe2IOpf2ia5yAFmGWEb4alLecW23a7ij11PWobiC1IxDeG5InWmfB8JniWM85XM2K)x2s6U0LaLjPyt(8ytUytnpokjh8sP0Lguh)ul1vYX0(yaSbj2ajKhaXxi5GxkLU0G64NAPUYLrhnCytZydKqEaeFH8RUYDK)9twRYLrhnCytoytoydsSjxSjxSbsipaIVqUQtdQZLexNc7KlJoA4Wg)ydcSbj2Kl2ql2uZJJs(vxDK)vz85ltl(kLIxjht7JbWM85XgiH8ai(c5xD1r(xLXNVmT4RukELlJoA4Wg)ydcSjhSjFESbMPyJFSPPytoydsSjxSbsipaIVq(vx5oY)(jRv5YOJgoSXp2GaBYNhBGzk24hBAeBYbBYNhBsxU3rbbKiKLsX7LopuSjhSbj2ql2KUCVJcciriBFdSJKuxNc7eG1SuCD6xaIQrta42K)xIoB3r(xLXhCNGLlJoA4eLWwe0DHncqoM2hdiSxacxT4vhbi3hjAAkdiRm(y0uEjR7Gt6a1ISydsSPn5)LvgFmAkVK1DWjDGArwPRgyh243dBqqdWgKydh8szvwkkFf5qhlXg)yt)cWbwkjeGWDGDpnOoACa47PuzvObLOe2IGUjSraYX0(yaH9cq4QfV6ia5(irttzazLXhJMYlzDhCshOwKfBqInTj)VSY4Jrt5LSUdoPdulYkD1a7Wg)EydIMIniXgiH8ai(cPJxo0YQCz0rdh20m2GOFSbj2uZJJs64LdTSk5yAFma2GeB4GxkRYsr5Rih6yj24hB6xaoWsjHaeUdS7Pb1rJdaFpLkRcnOeLWwe0aHncqoM2hdiSxaoWsjHaS9nWossDDkStacxT4vhbiTyt6Y9okiGeHS9nWossDDkSdBqInWmvIowIn9fBGzk243dBqGniXghxxljsCYs5TrexttHyJFSHoydsSPn5)LTKUlDjqzsQaSMLIRt)cqunAca3M8)s0z7oY)Qm(G7eSCz0rdNOe22iDe2ia5yAFmGWEb4alLecWsP49sNhQaeUAXRocqAXM0L7DuqajczPu8EPZdfBqIn0InPl37OGaseso4LsPlnOo(PwQl2GeBYfBGzQeDSeB6l2aZuSXVh20i2Kpp2WbVuwLLIYxro0XsSPzSPFSjhbynlfxN(fGOA0eaUn5)LOZ2DK)vz8b3jy5YOJgorjSTrecBeGCmTpgqyVaCGLscbyPu8EPZdvacxT4vhbiTyt6Y9okiGeHSukEV05HIniXgAXM0L7Duqajcjh8sP0Lguh)ul1fBqInCWlLvzPO8vKdDSeBA2dBqGniXgyMkrhlXM(InWmfB87HnnkaRzP460VaevJMaWTj)VeD2UJ8VkJp4oblxgD0WjkHTn2OWgbiht7Jbe2laHRw8QJaeMPytZEyt)ydsSjxSbsipaIVqUQtdQZLexNc7KlJoA4Wg)EydnXM85XgiH8ai(cPVmDFAqDa7qrIlnjGzYLrhnCyJFpSHMytoydsSHdEPSklfLVICOJLyJFSbHaCGLscbimtpFtpwucBBSFHncWbwkjeGWm98n9ybiht7Jbe2lkHTn2uHncqoM2hdiSxacN0sjHauacxT4vhbiTyJJFmSusGniXgAXM0L7DuqajczPu8EPZdvaoWsjHaSukEV05HkkHTnstHncqoM2hdiSxacN0sjHauacxT4vhbiTyJJFmSusGniXM0L7DuqajczPu8EPZdvaoWsjHaeUdS7Pb1rJdaFpLkRcnOeLOeGqaHncBriSraoWsjHauJEKo(SmHdbiht7Jbe2lkHTnkSraoWsjHaS9ria3pzTka5yAFmGWErjSTFHncWbwkjeGT864Ttdkbiht7Jbe2lkHTnvyJaKJP9Xac7fGWvlE1racZuj6yj20xSbMPyJFpSbb2GeB4GxkRYsr5Rih6yj243dBOJKMcWbwkjeGZcNGVISlhLOe2stHncWbwkjeGpLkRChnMaqHYrja5yAFmGWErjkby6YqcA7ucBe2IqyJaKJP9Xac7fLW2gf2ia5yAFmGWErjSTFHncqoM2hdiSxucBBQWgbiht7Jbe2lkHT0uyJaCGLscbykPusia5yAFmGWErjSTpf2iahyPKqacZ0RnzDLaKJP9Xac7fLWw6UWgb4alLecqyME(MESaKJP9Xac7fLOeGo(lSrylcHncqoM2hdiSxaoWsjHaSukEV05HkaHRw8QJaKwSjD5EhfeqIqwkfVx68qXgKydTyt6Y9okiGeHKdEPu6sdQJFQL6IniXgo4LYk24HnCWlLvj6yj2GeBGzk20m2GqawZsX1PFbia3M8)s0z7oY)Qm(G7eSeG4leLW2gf2ia5yAFmGWEbiC1IxDeGWmvIowIn9fBGzk243dBqGniXgo4LYQSuu(kYHowIn(9Wg6iPPaCGLscb4SWj4Ri7YrjkHT9lSraYX0(yaH9cWbwkjeGW59UbwkjUN6kb4tD1fdklaHaIsyBtf2ia5yAFmGWEbiC1IxDeG0InTj)V0vKf94zRSBcG7RlltsfGdSusiaDfzrpE2k7Ma4(6YIsylnf2ia5yAFmGWEbiC1IxDeGdS0E8XbJQSdB8Jn9lahyPKqacN37gyPK4EQReGp1vxmOSaCiSOe22NcBeGCmTpgqyVaeUAXRocWbwAp(4Grv2Hnn7Hn9lahyPKqacN37gyPK4EQReGp1vxmOSa0vIsucqhVCOLvHncBriSraYX0(yaH9cWbwkjeGLsX7LopubiC1IxDeG0InPl37OGaseYsP49sNhk2GeBOfBsxU3rbbKiKCWlLsxAqD8tTuxSbj2WbVuwXgpSHdEPSkrhlXgKydmtXMMXgeydsSHwSPn5)LoE5qlRYKubynlfxN(fGOA0eaUn5)LOZ2DK)vz8b3jy5YOJgorjSTrHncqoM2hdiSxaoWsjHaeoV3nWsjX9uxjaFQRUyqzbiequcB7xyJaCGLscbOJxo0YQaKJP9Xac7fLW2MkSraYX0(yaH9cWbwkjeGR60G6CjX1PWobiC1IxDeGdS0E8XbJQSdBAgB6xawZsX1PFbiQgnbGBt(Fj6SDh5FvgFWDcwUm6OHtucBPPWgbiht7Jbe2lahyPKqa2(gyhjPUof2jaHRw8QJamxSHwSjD5EhfeqIq2(gyhjPUof2Hn5GniXMCXM0L7Duqajc5xD1r(xLXNVmT4RukEXM85XM0L7Duqajc5xDL7i)7NSwXMCWgKyZalThFCWOk7WMMXMgfG1SuCD6xaIQrta42K)xIoB3r(xLXhCNGLlJoA4eLW2(uyJaKJP9Xac7fGWvlE1raMl2Kl2W9rIMMYasGvJonOUmYghK0JxSbj20M8)Y0LDUKLVuIgLCz0rdh20Sh20i2GeBCCDTKiXjlL3gPZ10ui24hBOd2Kd2GeBYfBGeYdG4lKR60G6CjX1PWo5YOJgoSXp2GaBYNhBgyP94Jdgvzh24hBqGn5Gn5iahyPKqa(vx5oY)(jRvbOgfVBsAjarikHT0DHncqoM2hdiSxacxT4vhbyUytUydTyd3hjAAkdibwn60G6YiBCqspEXM85XM2K)x2(ieGxIRKjPyt(8ytBY)lD8YHwwLlJoA4WMMXgeytoydsSjxSbsipaIVqUQtdQZLexNc7KlJoA4Wg)ydcSjFESzGL2JpoyuLDyJFSbb2Kd2KJaCGLscb4xDL7i)7NSwfGAu8UjPLaeHOe2s3e2ia5yAFmGWEbiC1IxDeGdS0E8XbJQSdB87Hn9JniXgAXM0L7DuqajcPlvJqdQdUtWxNc7eGdSusiaDPAeAqDWDc(6uyNOe2sde2ia5yAFmGWEbiC1IxDeG0InPl37OGaseYnXLPb1rJdaF(0aaBqInTj)VCtCzAqD04aWNpnaKaeFb2GeBAt(FPJxo0YQCz0rdh243dBAQaCGLscb4M4Y0G6OXbGpFAaikHTiOJWgbiht7Jbe2lahyPKqaUQtdQZLexNc7eGWvlE1raoWs7XhhmQYoSXVh20VaSMLIRt)cqunAca3M8)s0z7oY)Qm(G7eSCz0rdNOe2IaHWgbiht7Jbe2laHRw8QJaKwSjD5EhfeqIqUjUmnOoACa4ZNgaydsSPn5)LBIltdQJgha(8PbGeG4lWgKyZalThFCWOk7Wg)ydcb4alLecWnXLPb1rJdaF(0aqucBr0OWgbiht7Jbe2laHRw8QJaKwSjD5EhfeqIq6s1i0G6G7e81PWob4alLecqxQgHguhCNGVof2jkHTi6xyJaKJP9Xac7fGdSusiaBFdSJKuxNc7eGWvlE1rasl2KUCVJcciriBFdSJKuxNc7eG1SuCD6xaIQrta42K)xIoB3r(xLXhCNGLlJoA4eLOeGUsyJWwecBeGCmTpgqyVaCGLscbiCEVBGLsI7PUsa(uxDXGYcqiGOe22OWgbiht7Jbe2laHRw8QJaKwSjD5EhfeqIqwkfVx68qXgKydmtXMM9WgeydsSjxSbsipaIVqUQtdQZLexNc7KlJoA4WgpSHoyt(8ytUytnpok5xD1r(xLXNVmT4RukELCmTpgaBqInqc5bq8fYV6QJ8VkJpFzAXxPu8kxgD0WHnEydDWMCWM85Xgo4LYk20m2qt6Gn5iahyPKqaYbVukDPb1Xp1sDfLW2(f2ia5yAFmGWEbiC1IxDeGWmvIowIn9fBGzk243dBqGniXgo4LYQSuu(kYHowIn(9Wg6iPPaCGLscb4SWj4Ri7YrjkHTnvyJaKJP9Xac7fGdSusiaBFdSJKuxNc7eGWvlE1rasl2KUCVJcciriBFdSJKuxNc7WgKydmtLOJLytFXgyMIn(9WgeydsSXX11sIeNSuEBeX10ui24hBOd2GeBAt(FzlP7sxcuMKkaRzP460VaevJMaWTj)VeD2UJ8VkJp4oblxgD0WjkHT0uyJaKJP9Xac7fGdSusialLI3lDEOcq4QfV6iaPfBsxU3rbbKiKLsX7LopuSbj2ql2KUCVJcciri5GxkLU0G64NAPUydsSHdEPSklfLVICOJLytZEydcSbj2aZuj6yj20xSbMPyJFpSPrbynlfxN(fGOA0eaUn5)LOZ2DK)vz8b3jy5YOJgorjSTpf2ia5yAFmGWEbiC1IxDeG0In184OKoE5qlRsoM2hdGn5ZJnqc5bq8fshVCOLv5YOJgoSXVh2GGocWbwkjeGF1vh5FvgF(Y0IVsP4vucBP7cBeGdSusia9LP7tdQdyhksCPjbmtaYX0(yaH9IsylDtyJaKJP9Xac7fGdSusiax1Pb15sIRtHDcq4QfV6iaZfBYfBGzk243dB6hBqInCWlLvSXVh20u6Gn5Gn5ZJnWmfB87Hn0eBYbBqIn5In0In184OKoE5qlRsoM2hdGn5ZJnqc5bq8fshVCOLv5YOJgoSXVh20NytocWAwkUo9lar1OjaCBY)lrNT7i)RY4dUtWYLrhnCIsylnqyJaKJP9Xac7fGWvlE1rawZJJs64LdTSk5yAFma2GeBOfB4(irttzajWQrNguxgzJds6Xl2GeBGeYdG4lKoE5qlRYLrhnCyJFpSHMydsSHdEPSklfLVICOJLyJFSPrb4alLecWV6k3r(3pzTkkHTiOJWgbiht7Jbe2laHRw8QJaSMhhL0XlhAzvYX0(yaSbj2W9rIMMYasGvJonOUmYghK0JxSbj2Kl2ajKhaXxiD8YHwwLlJoA4Wg)EydcAIn5ZJnqc5bq8fshVCOLv5YOJgoSPzpSPPytoydsSHdEPSklfLVICOJLyJFSPrb4alLecWV6k3r(3pzTkkHTiqiSraYX0(yaH9cq4QfV6iaPfBQ5XrjD8YHwwLCmTpgaBqInCWlLvzPO8vKdDSeB8JnnkahyPKqa(vx5oY)(jRvrjSfrJcBeGCmTpgqyVaeUAXRocqiH8ai(c5QonOoxsCDkStUm6OHdB87Hn9lPj2GeBGzk20Sh2qtb4alLecWV6k3r(3pzTkkHTi6xyJaKJP9Xac7fGdSusiax1Pb15sIRtHDcq4QfV6iaPfBQ5XrjD8YHwwLCmTpgaBYNhBGeYdG4lKoE5qlRYLrhnCyJFpSHMcWAwkUo9lar1OjaCBY)lrNT7i)RY4dUtWYLrhnCIsylIMkSraYX0(yaH9cWbwkjeGTVb2rsQRtHDcq4QfV6iaPfBsxU3rbbKiKTVb2rsQRtHDydsSbMPs0XsSPVydmtXg)EydcSbj2446AjrItwkVnI4AAkeB8Jn0bBqIn5In0InoUUwsK4KLYlcAW1ykeB8Jn0bBYNhBQ5XrjD8YHwwLCmTpgaBYrawZsX1PFbiQgnbGBt(Fj6SDh5FvgFWDcwUm6OHtucBrqtHncqoM2hdiSxacxT4vhbyUyZalThFCWOk7Wg)Eyt)yt(8ytUytBY)lBjDx6sGYKuSbj2aZuj6yj20xSbMPyJFpSHoytoytoydsSHwSjD5EhfeqIq6s1i0G6G7e81PWoSbj2446AjrItwkVnI4AAkeB8Jn0raoWsjHa0LQrOb1b3j4RtHDIsylI(uyJaKJP9Xac7fGWvlE1raY9rIMMYaYkJpgnLxY6o4KoqTil2GeBAt(FzLXhJMYlzDhCshOwKv6Qb2Hn(9Wge0aSbj2WbVuwLLIYxro0XsSXp20VaCGLscbiChy3tdQJgha(EkvwfAqjkHTiO7cBeGCmTpgqyVaeUAXRocqUps00ugqwz8XOP8sw3bN0bQfzXgKytBY)lRm(y0uEjR7Gt6a1ISsxnWoSXVh2GOPydsSbsipaIVq64LdTSkxgD0WHnnJni6hBqIn184OKoE5qlRsoM2hdGniXgo4LYQSuu(kYHowIn(XM(fGdSusiaH7a7EAqD04aW3tPYQqdkrjSfbDtyJaKJP9Xac7fGWvlE1raoWs7XhhmQYoSXVh20p2GeBOfBsxU3rbbKiKUuncnOo4obFDkStaoWsjHa0LQrOb1b3j4RtHDIsylcAGWgbiht7Jbe2laHRw8QJaeMPs0XsSPVydmtXg)ydcSbj2ql2KUCVJcciri3exMguhnoa85tdab4alLecWnXLPb1rJdaF(0aqucBBKocBeGCmTpgqyVaCGLscby7BGDKK66uyNaeUAXRocWCXgyMIn(Xgeyt(8ytBY)lBjDx6sGYKuSjFESjxSPMhhLKdEPu6sdQJFQL6k5yAFma2GeBGeYdG4lKCWlLsxAqD8tTux5YOJgoSPzSbsipaIVq(vx5oY)(jRv5YOJgoSjhSjhSbj2Kl2Kl2ajKhaXxix1Pb15sIRtHDYLrhnCyJFSbb2GeBYfBOfBQ5Xrj)QRoY)Qm(8LPfFLsXRKJP9Xayt(8ydKqEaeFH8RU6i)RY4ZxMw8vkfVYLrhnCyJFSbb2Kd2Kpp2aZuSXp20uSjhSbj2Kl2ajKhaXxi)QRCh5F)K1QCz0rdh24hBqGn5ZJnWmfB8JnnIn5Gn5ZJnPl37OGaseYsP49sNhk2Kd2GeBOfBsxU3rbbKiKTVb2rsQRtHDcWAwkUo9lar1OjaCBY)lrNT7i)RY4dUtWYLrhnCIsyBJie2ia5yAFmGWEbiC1IxDeGWmfBA2dB6hBqIn5Inqc5bq8fYvDAqDUK46uyNCz0rdh243dBOj2Kpp2ajKhaXxi9LP7tdQdyhksCPjbmtUm6OHdB87Hn0eBYbBqInCWlLvzPO8vKdDSeB8JnieGdSusiaHz65B6XIsyBJnkSraYX0(yaH9cq4QfV6iaHzk20Sh20p2GeBYfBGeYdG4lKR60G6CjX1PWo5YOJgoSXVh2qtSjFESbsipaIVq6lt3NguhWouK4stcyMCz0rdh243dBOj2Kd2GeB4GxkRYsr5Rih6yj24hBqiahyPKqacZ0RnzDLOe22y)cBeGCmTpgqyVaCGLscbyPu8EPZdvacxT4vhbiTyt6Y9okiGeHSukEV05HIniXgAXM0L7Duqajcjh8sP0Lguh)ul1fBqIn5InWmvIowIn9fBGzk243dBAeBYNhB4GxkRYsr5Rih6yj20m20p2KJaSMLIRt)cqunAca3M8)s0z7oY)Qm(G7eSCz0rdNOe22ytf2iahyPKqacZ0Z30JfGCmTpgqyVOe22inf2iahyPKqacZ0RnzDLaKJP9Xac7fLW2g7tHncqoM2hdiSxacN0sjHauaoWsjHaSukEV05HkaHRw8QJaKwSXXpgwkjWgKydTyt6Y9okiGeHSukEV05HkkHTns3f2ia5yAFmGWEbiCslLecqb4alLecq4oWUNguhnoa89uQSk0GsacxT4vhbiTyJJFmSusGniXM0L7DuqajczPu8EPZdvuIsa64LdTSEKuo4vyJWwecBeGCmTpgqyVaCGLscbyPu8EPZdvacxT4vhbiTyt6Y9okiGeHSukEV05HIniXgAXM0L7Duqajcjh8sP0Lguh)ul1fBqInCWlLvSXdB4GxkRs0XsSbj2aZuSPzSbb2GeBOfBAt(FPJxo0YQmjfBqInqc5bq8fYV6k3r(3pzTkxgD0WHnn7Hn0rawZsX1PFbiQgnbGBt(Fj6SDh5FvgFWDcwUm6OHtucBBuyJaKJP9Xac7fGWvlE1racZuj6yj20xSbMPyJFpSbb2GeB4GxkRYsr5Rih6yj243dBOJKMcWbwkjeGZcNGVISlhLOe22VWgbiht7Jbe2laHRw8QJaesipaIVq(vx5oY)(jRv5YOJgoSXp2GqaoWsjHaeoV3nWsjX9uxjaFQRUyqzbiequcBBQWgbiht7Jbe2laHRw8QJaesipaIVq(vx5oY)(jRv5YOJgoSXp2GqaoWsjHa0XlhAzvucBPPWgbiht7Jbe2lahyPKqaUQtdQZLexNc7eGWvlE1raoWs7XhhmQYoSPzSPFSbj20M8)shVCOLvzsQaSMLIRt)cqunAca3M8)s0z7oY)Qm(G7eSCz0rdNOe22NcBeGCmTpgqyVaCGLscby7BGDKK66uyNaeUAXRocWCXgAXM0L7Duqajcz7BGDKK66uyh2Kd2GeBYfBsxU3rbbKiKF1vh5FvgF(Y0IVsP4fBYrawZsX1PFbiQgnbGBt(Fj6SDh5FvgFWDcwUm6OHtucBP7cBeGCmTpgqyVaeUAXRocqiH8ai(c5QonOoxsCDkStUm6OHdB8JniWM85XM2K)x64LdTSkbi(cb4alLecWV6k3r(3pzTka1O4DtslbicrjSLUjSraYX0(yaH9cWbwkjeGTVb2rsQRtHDcq4QfV6iaBt(FPJxo0YQeG4lWgKydmtXMM9WMgXgKydKqEaeFH0XlhAzvUm6OHdBA2dBOd2GeBsxU3rbbKiKLsX7LopubynlfxN(fGOA0eaUn5)LOZ2DK)vz8b3jy5YOJgorjSLgiSraYX0(yaH9cWbwkjeGLsX7LopubiC1IxDeG0InPl37OGaseYsP49sNhk2GeBOfBsxU3rbbKiKCWlLsxAqD8tTuxSbj2aZuSXdBqiaRzP460VaevJMaWTj)VeD2UJ8VkJp4oblxgD0WjkrjkbypEDkje22iDqq3OtF2pDKiOBnLMcqFZgAq5eGcWjPYiRaKgQCN(uby6s(6JfG0qGn0qBjdtkgaBA5pzzSbsqBNcBAzknCsSHgsiKtlh2eKOVzZI(tEyZalLeoSHepRsm9dSus4KPldjOTt59FJRdt)alLeoz6YqcA7un4z3NqaW0pWsjHtMUmKG2ovdE2njuOCutPKatpneydymPUmsHn7OaytBY)ZayJRMYHnT8NSm2ajOTtHnTmLgoSzcaSjD5(MsQsdkSrDydajyjM(bwkjCY0LHe02PAWZoxmPUmsDUAkhM(bwkjCY0LHe02PAWZUusPKat)alLeoz6YqcA7un4zhmtV2K1vy6hyPKWjtxgsqBNQbp7Gz65B6Xy6X0tdb2qdTLmmPyaSH7XRvSPuugBQmgBgyrwSrDyZ0B030(yjM(bwkjCEtsrUPQb2HPFGLscxdE25s5zVSjaoxTAhBH(9QzP4scWTj)VeoUsdk5YdSW0pWsjHRbp7kscm7i)RBw0XcnkE7nppAaDSifwxgpVkZJosAIPFGLscxdE2LskLewOFV2K)x64LdTSktsZNVn5)LUISOhpBLDtaCFDzzsA(85sBnpokPJxo0YQKJP9XaiRvJoUKPlbkhk9PLv5YdSYjF(2K)x2(ieGxIRKlpWkF(AwkUKLIYxroaLB2RpPdM(bwkjCn4zxrsGzh5Fa8uzwOFVAwkUKLIYxroaLB2JgGPFGLscxdE2bN37gyPK4EQRSigu2ZXlhAz1c97LBnpokPJxo0YQKJP9XaiHeYdG4lKoE5qlRYLrhnCn7rNCYNVn5)LoE5qlRYKum9dSus4AWZo48E3alLe3tDLfXGYEo(BH(9OTMhhL0XlhAzvYX0(yaK52M8)sxrw0JNTYUjaUVUSmjnFEiH8ai(cPRil6XZwz3ea3xxwcZMLIDEnMdM(bwkjCn4zhCEVBGLsI7PUYIyqzph)Tq)E0wZJJs64LdTSk5yAFmasUps00ugqcSA0Pb1Lr24GKE8ImxiH8ai(c5xD1r(xLXNVmT4RukELlJoA4A2dbDdjKqEaeFH8RUYDK)9twRYLrhnCn7HOrKWm1Vx)iHeYdG4lKR60G6CjX1PWo5YOJgUM9qKpFnlfxYsr5RihGYn71inZNhsipaIVqwKey2r(hapvMCz0rdNFeiAmhKqc5bq8fsxrw0JNTYUjaUVUSeMnlf78qGPFGLscxdE2bN37gyPK4EQRSigu2ZXFl0VhT184OKoE5qlRsoM2hdGKwUps00ugqcSA0Pb1Lr24GKE8ImxiH8ai(c5xD1r(xLXNVmT4RukELlJoA4A2drtrcjKhaXxi)QRCh5F)K1QCz0rdxZE9jsyM63RFKqc5bq8fYvDAqDUK46uyNCz0rdxZEiYNVMLIlzPO8vKdq5M9qqZ85HeYdG4lKfjbMDK)bWtLjxgD0W5hbIgZbjKqEaeFH0vKf94zRSBcG7RllHzZsXopey6hyPKW1GNDW59UbwkjUN6klIbL9gcBH(9gyP94JdgvzN)(X0pWsjHRbp7GZ7DdSusCp1vwedk75kl0V3alThFCWOk7A2RFm9y6hyPKWjhc7bN37gyPK4EQRSigu2dcGPFGLscNCiCdE2XbVukDPb1Xp1sDTq)E0MUCVJccirilLI3lDEOiHzAZEiqMlKqEaeFHCvNguNljUof2jxgD0W5rN85ZTMhhL8RU6i)RY4ZxMw8vkfVsoM2hdGesipaIVq(vxDK)vz85ltl(kLIx5YOJgop6Kt(8CWlL1MPjDYbt)alLeo5q4g8SBw4e8vKD5OSq)EWmvIow2xyM63dbso4LYQSuu(kYHow63JosAIPFGLscNCiCdE29vx5oY)(jRvl0VxnpokPJxo0YQKJP9XaiPL7JennLbKaRgDAqDzKnoiPhViHeYdG4lKoE5qlRYLrhnC(9Ojso4LYQSuu(kYHow6Vrm9dSus4KdHBWZUV6k3r(3pzTAH(9Q5XrjD8YHwwLCmTpgaj3hjAAkdibwn60G6YiBCqspErMlKqEaeFH0XlhAzvUm6OHZVhcAMppKqEaeFH0XlhAzvUm6OHRzVMMdso4LYQSuu(kYHow6Vrm9dSus4KdHBWZUV6k3r(3pzTAH(9OTMhhL0XlhAzvYX0(yaKCWlLvzPO8vKdDS0FJy6hyPKWjhc3GNDF1vUJ8VFYA1c97bjKhaXxix1Pb15sIRtHDYLrhnC(96xstKWmTzpAIPFGLscNCiCdE25lt3NguhWouK4stcygM(bwkjCYHWn4z3QonOoxsCDkSZIAwkUo97bjKhaXxi9LP7tdQdyhksCPjbmtUm6OHZVhfeajTPl37OGaseYvDAqDUK46uyhsiH8ai(c5xDL7i)7NSwLlJoA48tbbW0pWsjHtoeUbp72exMguhnoa85tdal0VhmtLOJL9fMP(rGK20L7Duqajc5M4Y0G6OXbGpFAaGPFGLscNCiCdE2bZ0RnzDLf63dMPn71pYCHeYdG4lKR60G6CjX1PWo5YOJgo)E0mFEiH8ai(cPVmDFAqDa7qrIlnjGzYLrhnC(9Ozoi5GxkRYsr5Rih6yPFey6hyPKWjhc3GNDWm9AtwxHPFGLscNCiCdE25s1i0G6G7e81PWol0VxUdS0E8XbJQSZVx)5ZNBBY)lBjDx6sGYKuKWmvIow2xyM63Jo5KdsAtxU3rbbKiKUuncnOo4obFDkSdPJRRLejozP82iIRPPqm9dSus4KdHBWZoxQgHguhCNGVof2zH(9gyP94JdgvzNFV(rsB6Y9okiGeH0LQrOb1b3j4RtHDy6hyPKWjhc3GNDTVb2rsQRtHDwuZsX1PFpunAca3M8)s0z7oY)Qm(G7eSCz0rdNf63J20L7Duqajcz7BGDKK66uyhsyMkrhl7lmt97HaPJRRLejozP82iIRPPqK5sRJRRLejozP8IGgCnMcZNVMhhL0XlhAzvYX0(yGCW0pWsjHtoeUbp7AFdSJKuxNc7SOMLIRt)EOA0eaUn5)LOZ2DK)vz8b3jy5YOJgol0VxUWm1pI85Bt(FzlP7sxcuMKMpFU184OKCWlLsxAqD8tTuxjht7JbqcjKhaXxi5GxkLU0G64NAPUYLrhnCndjKhaXxi)QRCh5F)K1QCz0rdxo5Gm3CHeYdG4lKR60G6CjX1PWo5YOJgo)iqMlT184OKF1vh5FvgF(Y0IVsP4vYX0(yG85HeYdG4lKF1vh5FvgF(Y0IVsP4vUm6OHZpICYNhMP(BAoiZfsipaIVq(vx5oY)(jRv5YOJgo)iYNhMP(BmN85txU3rbbKiKLsX7Lop0CqsB6Y9okiGeHS9nWossDDkSdt)alLeo5q4g8SdUdS7Pb1rJdaFpLkRcnOSq)ECFKOPPmGSY4Jrt5LSUdoPdulYISn5)LvgFmAkVK1DWjDGArwPRgyNFpe0aKCWlLvzPO8vKdDS0F)y6hyPKWjhc3GNDWDGDpnOoACa47PuzvObLf63J7JennLbKvgFmAkVK1DWjDGArwKTj)VSY4Jrt5LSUdoPdulYkD1a787HOPiHeYdG4lKoE5qlRYLrhnCnJOFK184OKoE5qlRsoM2hdGKdEPSklfLVICOJL(7ht)alLeo5q4g8SR9nWossDDkSZIAwkUo97HQrta42K)xIoB3r(xLXhCNGLlJoA4Sq)E0MUCVJcciriBFdSJKuxNc7qcZuj6yzFHzQFpeiDCDTKiXjlL3grCnnfISn5)LTKUlDjqzskM(bwkjCYHWn4zxPu8EPZd1IAwkUo97HQrta42K)xIoB3r(xLXhCNGLlJoA4Sq)E0MUCVJccirilLI3lDEOiPnD5EhfeqIqYbVukDPb1Xp1sDrMlmtLOJL9fMP(9AmFEo4LYQSuu(kYHow2C)5GPFGLscNCiCdE2vkfVx68qTOMLIRt)EOA0eaUn5)LOZ2DK)vz8b3jy5YOJgol0VhTPl37OGaseYsP49sNhksAtxU3rbbKiKCWlLsxAqD8tTuxKCWlLvzPO8vKdDSSzpeiHzQeDSSVWm1VxJy6hyPKWjhc3GNDWm98n9yl0VhmtB2RFK5cjKhaXxix1Pb15sIRtHDYLrhnC(9Oz(8qc5bq8fsFz6(0G6a2HIexAsaZKlJoA487rZCqYbVuwLLIYxro0Xs)iW0pWsjHtoeUbp7Gz65B6Xy6hyPKWjhc3GNDLsX7Lopul0VhTo(XWsjbsAtxU3rbbKiKLsX7Lopum9dSus4KdHBWZo4oWUNguhnoa89uQSk0GYc97rRJFmSusGmD5EhfeqIqwkfVx68qX0JPFGLscNec4PrpshFwMWXvz85ltl(kLIxm9dSus4KqGg8SR9ria3pzTIPFGLscNec0GNDT864Ttdkm9dSus4KqGg8SBw4e8vKD5OSq)EWmvIow2xyM63dbso4LYQSuu(kYHow63JosAIPFGLscNec0GNDpLkRChnMaqHYrHPht)alLeoPJ)ELsX7LopulQzP460Vha3M8)s0z7oY)Qm(G7eSeG4lSq)E0MUCVJccirilLI3lDEOiPnD5EhfeqIqYbVukDPb1Xp1sDrYbVuw94GxkRs0XsKWmTzey6hyPKWjD8Vbp7MfobFfzxokl0VhmtLOJL9fMP(9qGKdEPSklfLVICOJL(9OJKMy6hyPKWjD8Vbp7GZ7DdSusCp1vwedk7bbW0pWsjHt64FdE25kYIE8Sv2nbW91LTq)E02M8)sxrw0JNTYUjaUVUSmjft)alLeoPJ)n4zhCEVBGLsI7PUYIyqzVHWwOFVbwAp(4Grv25VFm9dSus4Ko(3GNDW59UbwkjUN6klIbL9CLf63BGL2JpoyuLDn71pMEm9dSus4KoE5qlRELsX7LopulQzP460VhQgnbGBt(Fj6SDh5FvgFWDcwUm6OHZc97rB6Y9okiGeHSukEV05HIK20L7Duqajcjh8sP0Lguh)ul1fjh8sz1JdEPSkrhlrcZ0MrGK22K)x64LdTSktsX0pWsjHt64LdTS2GNDW59UbwkjUN6klIbL9Gay6hyPKWjD8YHwwBWZohVCOLvm9dSus4KoE5qlRn4z3QonOoxsCDkSZIAwkUo97HQrta42K)xIoB3r(xLXhCNGLlJoA4Sq)EdS0E8XbJQSR5(X0pWsjHt64LdTS2GNDTVb2rsQRtHDwuZsX1PFpunAca3M8)s0z7oY)Qm(G7eSCz0rdNf63lxAtxU3rbbKiKTVb2rsQRtHD5Gm30L7Duqajc5xD1r(xLXNVmT4RukEZNpD5EhfeqIq(vx5oY)(jR1CqoWs7XhhmQYUMBet)alLeoPJxo0YAdE29vx5oY)(jRvl0VxU5Y9rIMMYasGvJonOUmYghK0JxKTj)VmDzNlz5lLOrjxgD0W1SxJiDCDTKiXjlL3gPZ10uyoiZfsipaIVqUQtdQZLexNc7KlJoA48JiF(bwAp(4Grv25hro5yHgfVBsA5Hat)alLeoPJxo0YAdE29vx5oY)(jRvl0VxU5sl3hjAAkdibwn60G6YiBCqspEZNVn5)LTpcb4L4kzsA(8Tj)V0XlhAzvUm6OHRze5GmxiH8ai(c5QonOoxsCDkStUm6OHZpI85hyP94JdgvzNFe5KJfAu8UjPLhcm9dSus4KoE5qlRn4zNlvJqdQdUtWxNc7Sq)EdS0E8XbJQSZVx)iPnD5EhfeqIq6s1i0G6G7e81PWom9dSus4KoE5qlRn4z3M4Y0G6OXbGpFAayH(9OnD5EhfeqIqUjUmnOoACa4ZNgaiBt(F5M4Y0G6OXbGpFAaibi(cKTj)V0XlhAzvUm6OHZVxtX0pWsjHt64LdTS2GNDR60G6CjX1PWolQzP460VhQgnbGBt(Fj6SDh5FvgFWDcwUm6OHZc97nWs7XhhmQYo)E9JPFGLscN0XlhAzTbp72exMguhnoa85tdal0VhTPl37OGaseYnXLPb1rJdaF(0aazBY)l3exMguhnoa85tdajaXxGCGL2JpoyuLD(rGPFGLscN0XlhAzTbp7CPAeAqDWDc(6uyNf63J20L7DuqajcPlvJqdQdUtWxNc7W0pWsjHt64LdTS2GNDTVb2rsQRtHDwuZsX1PFpunAca3M8)s0z7oY)Qm(G7eSCz0rdNf63J20L7Duqajcz7BGDKK66uyhMEm9dSus4KoE5qlRhjLdE9kLI3lDEOwuZsX1PFpunAca3M8)s0z7oY)Qm(G7eSCz0rdNf63J20L7DuqajczPu8EPZdfjTPl37OGaseso4LsPlnOo(PwQlso4LYQhh8szvIowIeMPnJajTTj)V0XlhAzvMKIesipaIVq(vx5oY)(jRv5YOJgUM9OdM(bwkjCshVCOL1JKYbVn4z3SWj4Ri7YrzH(9GzQeDSSVWm1VhcKCWlLvzPO8vKdDS0VhDK0et)alLeoPJxo0Y6rs5G3g8SdoV3nWsjX9uxzrmOSheWc97bjKhaXxi)QRCh5F)K1QCz0rdNFey6hyPKWjD8YHwwpskh82GNDoE5qlRwOFpiH8ai(c5xDL7i)7NSwLlJoA48Jat)alLeoPJxo0Y6rs5G3g8SBvNguNljUof2zrnlfxN(9q1OjaCBY)lrNT7i)RY4dUtWYLrhnCwOFVbwAp(4Grv21C)iBt(FPJxo0YQmjft)alLeoPJxo0Y6rs5G3g8SR9nWossDDkSZIAwkUo97HQrta42K)xIoB3r(xLXhCNGLlJoA4Sq)E5sB6Y9okiGeHS9nWossDDkSlhK5MUCVJcciri)QRoY)Qm(8LPfFLsXBoy6hyPKWjD8YHwwpskh82GNDF1vUJ8VFYA1c97bjKhaXxix1Pb15sIRtHDYLrhnC(rKpFBY)lD8YHwwLaeFHfAu8UjPLhcm9dSus4KoE5qlRhjLdEBWZU23a7ij11PWolQzP460VhQgnbGBt(Fj6SDh5FvgFWDcwUm6OHZc971M8)shVCOLvjaXxGeMPn71isiH8ai(cPJxo0YQCz0rdxZE0bz6Y9okiGeHSukEV05HIPFGLscN0XlhAz9iPCWBdE2vkfVx68qTOMLIRt)EOA0eaUn5)LOZ2DK)vz8b3jy5YOJgol0VhTPl37OGaseYsP49sNhksAtxU3rbbKiKCWlLsxAqD8tTuxKWm1dbMEm9dSus4KUYdoV3nWsjX9uxzrmOSheat)alLeoPRAWZoo4LsPlnOo(PwQRf63J20L7DuqajczPu8EPZdfjmtB2dbYCHeYdG4lKR60G6CjX1PWo5YOJgop6KpFU184OKF1vh5FvgF(Y0IVsP4vYX0(yaKqc5bq8fYV6QJ8VkJpFzAXxPu8kxgD0W5rNCYNNdEPS2mnPtoy6hyPKWjDvdE2nlCc(kYUCuwOFpyMkrhl7lmt97Hajh8szvwkkFf5qhl97rhjnX0pWsjHt6Qg8SR9nWossDDkSZIAwkUo97HQrta42K)xIoB3r(xLXhCNGLlJoA4Sq)E0MUCVJcciriBFdSJKuxNc7qcZuj6yzFHzQFpeiDCDTKiXjlL3grCnnfISn5)LTKUlDjqzskM(bwkjCsx1GNDLsX7LopulQzP460VhQgnbGBt(Fj6SDh5FvgFWDcwUm6OHZc97rB6Y9okiGeHSukEV05HIK20L7Duqajcjh8sP0Lguh)ul1fjh8szvwkkFf5qhlB2dbsyMkrhl7lmt971iM(bwkjCsx1GNDF1vh5FvgF(Y0IVsP41c97rBnpokPJxo0YQKJP9Xa5ZdjKhaXxiD8YHwwLlJoA487HGoy6hyPKWjDvdE25lt3NguhWouK4stcygM(bwkjCsx1GNDR60G6CjX1PWolQzP460VhQgnbGBt(Fj6SDh5FvgFWDcwUm6OHZc97LBUWm1Vx)i5GxkR(9AkDYjFEyM63JM5GmxAR5XrjD8YHwwLCmTpgiFEiH8ai(cPJxo0YQCz0rdNFV(mhm9dSus4KUQbp7(QRCh5F)K1Qf63RMhhL0XlhAzvYX0(yaK0Y9rIMMYasGvJonOUmYghK0JxKqc5bq8fshVCOLv5YOJgo)E0ejh8szvwkkFf5qhl93iM(bwkjCsx1GNDF1vUJ8VFYA1c97vZJJs64LdTSk5yAFmasUps00ugqcSA0Pb1Lr24GKE8ImxiH8ai(cPJxo0YQCz0rdNFpe0mFEiH8ai(cPJxo0YQCz0rdxZEnnhKCWlLvzPO8vKdDS0FJy6hyPKWjDvdE29vx5oY)(jRvl0VhT184OKoE5qlRsoM2hdGKdEPSklfLVICOJL(Bet)alLeoPRAWZUV6k3r(3pzTAH(9GeYdG4lKR60G6CjX1PWo5YOJgo)E9lPjsyM2ShnX0pWsjHt6Qg8SBvNguNljUof2zrnlfxN(9q1OjaCBY)lrNT7i)RY4dUtWYLrhnCwOFpAR5XrjD8YHwwLCmTpgiFEiH8ai(cPJxo0YQCz0rdNFpAIPFGLscN0vn4zx7BGDKK66uyNf1SuCD63dvJMaWTj)VeD2UJ8VkJp4oblxgD0WzH(9OnD5EhfeqIq2(gyhjPUof2HeMPs0XY(cZu)Eiq646AjrItwkVnI4AAkezU0646AjrItwkViObxJPW85R5XrjD8YHwwLCmTpgihm9dSus4KUQbp7CPAeAqDWDc(6uyNf63l3bwAp(4Grv253R)85ZTn5)LTKUlDjqzsksyMkrhl7lmt97rNCYbjTPl37OGasesxQgHguhCNGVof2H0X11sIeNSuEBeX10uiM(bwkjCsx1GNDWDGDpnOoACa47PuzvObLf63J7JennLbKvgFmAkVK1DWjDGArwKTj)VSY4Jrt5LSUdoPdulYkD1a787HGgGKdEPSklfLVICOJL(7ht)alLeoPRAWZo4oWUNguhnoa89uQSk0GYc97X9rIMMYaYkJpgnLxY6o4KoqTilY2K)xwz8XOP8sw3bN0bQfzLUAGD(9q0uKqc5bq8fshVCOLv5YOJgUMr0pYAECushVCOLvjht7JbqYbVuwLLIYxro0Xs)9JPFGLscN0vn4zNlvJqdQdUtWxNc7Sq)EdS0E8XbJQSZVx)iPnD5EhfeqIq6s1i0G6G7e81PWom9dSus4KUQbp72exMguhnoa85tdal0VhmtLOJL9fMP(rGK20L7Duqajc5M4Y0G6OXbGpFAaGPFGLscN0vn4zx7BGDKK66uyNf1SuCD63dvJMaWTj)VeD2UJ8VkJp4oblxgD0WzH(9YfMP(rKpFBY)lBjDx6sGYK085ZTMhhLKdEPu6sdQJFQL6k5yAFmasiH8ai(cjh8sP0Lguh)ul1vUm6OHRziH8ai(c5xDL7i)7NSwLlJoA4YjhK5MlKqEaeFHCvNguNljUof2jxgD0W5hbYCPTMhhL8RU6i)RY4ZxMw8vkfVsoM2hdKppKqEaeFH8RU6i)RY4ZxMw8vkfVYLrhnC(rKt(8Wm1FtZbzUqc5bq8fYV6k3r(3pzTkxgD0W5hr(8Wm1FJ5KpF6Y9okiGeHSukEV05HMdsAtxU3rbbKiKTVb2rsQRtHDy6hyPKWjDvdE2bZ0Z30JTq)EWmTzV(rMlKqEaeFHCvNguNljUof2jxgD0W53JM5ZdjKhaXxi9LP7tdQdyhksCPjbmtUm6OHZVhnZbjh8szvwkkFf5qhl9Jat)alLeoPRAWZoyMETjRRSq)EWmTzV(rMlKqEaeFHCvNguNljUof2jxgD0W53JM5ZdjKhaXxi9LP7tdQdyhksCPjbmtUm6OHZVhnZbjh8szvwkkFf5qhl9Jat)alLeoPRAWZUsP49sNhQf1SuCD63dvJMaWTj)VeD2UJ8VkJp4oblxgD0WzH(9OnD5EhfeqIqwkfVx68qrsB6Y9okiGeHKdEPu6sdQJFQL6ImxyMkrhl7lmt971y(8CWlLvzPO8vKdDSS5(Zbt)alLeoPRAWZoyME(MEmM(bwkjCsx1GNDWm9AtwxHPFGLscN0vn4zxPu8EPZd1c97rRJFmSusGK20L7DuqajczPu8EPZdft)alLeoPRAWZo4oWUNguhnoa89uQSk0GYc97rRJFmSusGmD5EhfeqIqwkfVx68qfLOec]] )
end