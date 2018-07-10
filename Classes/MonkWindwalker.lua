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


    local chiSpent = 0

    spec:RegisterHook( "spend", function( amt, resource )
        if state.talent.spiritual_focus.enabled then
            chiSpent = chiSpent + amt           
            state.cooldown.storm_earth_and_fire.expires = max( 0, state.cooldown.storm_earth_and_fire.expires - floor( chiSpent / 2 ) )
            chiSpent = chiSpent % 2
        end

        if state.level < 116 then
            if state.equipped.the_emperors_capacitor and resource == 'chi' then
                state.addStack( "the_emperors_capacitor", 30, 1 )
            end
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        chiSpent = 0
        if state.prev_gcd[1].tiger_palm and ( class.abilities.tiger_palm.lastCast == 0 or state.combat == 0 or class.abilities.tiger_palm.lastCast < state.combat ) then
            state.prev_gcd.override = "none"
            state.prev.override = "none"
        end
        state.spinning_crane_kick.count = nil
        virtual_combo = nil
    end )
    

    spec:RegisterHook( "IsUsable", function( spell )
        if state.talent.hit_combo.enabled and state.buff.hit_combo.up then
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

        strict = true
    } )

    spec:RegisterPack( "Windwalker", 20180709.195000, 
        [[di0JSbqiKspcPiHnbrJsuPtjQ4vsbZIs4wsvPDr0VOuzyivCmiSmPiptQQMMuvCnKcBdPi(gsLY4qQuDoPqADsHAEsrDpQY(OQ6GifjAHuQ6HifP4Iifj1irkssNePiLwjsv3ePij2jLspfOPsP4RifPAVe(RkdMIdRyXsPhdAYaUmQnRQ(msgTOCAsRgPOETuz2QYTH0Uf(nIHlshxkelxPNtLPl56Iy7sv(ovLXtj68usRhPsMVOQ9d1cecBeGatXcBBIoiO70HUrNgvIOr7dDNg0nbyznLfGPdSBOybymOSaKMUga(MxhVcW0X6JmacBeGosYczbywvPUgBNDuALL0kHeu7CkAYBkLeWD(LDoffAx7J0Ax7F6la3ZU0L81h7SZgL3MqyNnnH4OPcj6oA6Aa4BED8kDkkua2MOVIM2q0kabMIf22eDqq3PdnPF6irq3PbcAq3eGUugkSTjAsJkabyhuaAtM6Wg1HnvgJna8FsEf2qtxdaFZRJxSzGLscSjDGDyZNSyJ9tvpgB(KfBOPKU4Luzsm9y6PPTWgFJdBAt0xHn)LGInvgJn0nz)sAGnGkAYBkLe00SZVWM0L81hlX0JPNMMSjOyxJX0JqInyZ4Yg0jy39xoOlRyJVXHnlN(gidGnTwXMV6QJ8VkJpFzAXxPu8In5wZJJkhjMEm9njXgSztIBGLsI7PUcBuh2K4yaS5twSXv2negBgyPKaBEQRCytldNehJnvgBfBMLXg0KkzEpR9LTe(sCApwIPhtF)sSbBOPeaGbWMbBG7a7EAqD08aW3tPYQqdkS5RVhVyZalLeyJJGnv2uyJwyJp99WMwgBwgsqr5aGbWgFzCGnwjjydQ6CyZGnLsX7LopuSHSyJvsYInWmfBay4y1HnKKcBiFSbsqBNcBsxUhhLguytPu8EPZdfB(lbfBAznOWMLHeuuoayaSP8PqgB0aBgSzj(KcWN6kNWgbOJxo0Y6rs5GxHncBriSraYX0(yaH9cq4QfV6iaPfBsxU3rbbKiKLsX7LopuSbj2ql2KUCVJcciri5GxkLU0G64NAPUydsSHdEPSInEydh8szvIowIniXgyMInnJniWgKydTytBY)lD8YHwwLjPydsSbsipaIVq(vx5oY)(jRv5YOJgoSPzpSHocWbwkjeGLsX7LopubynlfxN(fGOA0yaUn5)LOZ2DK)vz8b3jy5YOJgorjSTjHncqoM2hdiSxacxT4vhbimtLOJLytFXgyMIn(9WgeydsSHdEPSklfLVICOJLyJFpSHosAiahyPKqaolCc(kYUCuIsyB)cBeGCmTpgqyVaCGLscbiCEVBGLsI7PUsacxT4vhbiKqEaeFH8RUYDK)9twRYLrhnCyJFSbHa8PU6IbLfGqarjSTpcBeGCmTpgqyVaeUAXRocqiH8ai(c5xDL7i)7NSwLlJoA4Wg)ydcb4alLecqhVCOLvrjSLgcBeGCmTpgqyVaeUAXRocWbwAp(4Grv2HnnJn9JniXM2K)x64LdTSktsfGdSusiax1Pb15sIRtHDcWAwkUo9lar1OXaCBY)lrNT7i)RY4dUtWYLrhnCIsylnryJaKJP9Xac7fGWvlE1raMl2ql2KUCVJcciriBFdSJKuxNc7WMCWgKytUyt6Y9okiGeH8RU6i)RY4ZxMw8vkfVytocWbwkjeGTVb2rsQRtHDcWAwkUo9lar1OXaCBY)lrNT7i)RY4dUtWYLrhnCIsylDtyJauJI3njTeGieGCmTpgqyVaeUAXRocqiH8ai(c5QonOoxsCDkStUm6OHdB8JniWM85XM2K)x64LdTSkbi(cb4alLecWV6k3r(3pzTkkHT0DHncqoM2hdiSxacxT4vhbyBY)lD8YHwwLaeFb2GeBGzk20Sh20e2GeBGeYdG4lKoE5qlRYLrhnCytZEydDWgKyt6Y9okiGeHSukEV05HkahyPKqa2(gyhjPUof2jaRzP460VaevJgdWTj)VeD2UJ8VkJp4oblxgD0WjkHTnQWgbiht7Jbe2laHRw8QJaKwSjD5EhfeqIqwkfVx68qXgKydTyt6Y9okiGeHKdEPu6sdQJFQL6IniXgyMInEydcb4alLecWsP49sNhQaSMLIRt)cqunAma3M8)s0z7oY)Qm(G7eSCz0rdNOeLa0XFHncBriSraYX0(yaH9cq4QfV6iaPfBsxU3rbbKiKLsX7LopuSbj2ql2KUCVJcciri5GxkLU0G64NAPUydsSHdEPSInEydh8szvIowIniXgyMInnJnieGdSusialLI3lDEOcWAwkUo9lab42K)xIoB3r(xLXhCNGLaeFHOe22KWgbiht7Jbe2laHRw8QJaeMPs0XsSPVydmtXg)EydcSbj2WbVuwLLIYxro0XsSXVh2qhjneGdSusiaNfobFfzxokrjSTFHncqoM2hdiSxaoWsjHaeoV3nWsjX9uxjaFQRUyqzbiequcB7JWgbiht7Jbe2laHRw8QJaKwSPn5)LUISOhpBLDtaCFDzzsQaCGLscbORil6XZwz3ea3xxwucBPHWgbiht7Jbe2lahyPKqacN37gyPK4EQReGWvlE1raoWs7XhhmQYoSXp20Va8PU6IbLfGdHfLWwAIWgbiht7Jbe2lahyPKqacN37gyPK4EQReGWvlE1raoWs7XhhmQYoSPzpSPFb4tD1fdklaDLOeLaeG)tYRe2iSfHWgb4alLecWjPi3u1a7eGCmTpgqyVOe22KWgbiht7Jbe2laHRw8QJaSMLIlja3M8)s44knOKlpWsaoWsjHa0LYZEztaCUA1owucB7xyJauJI3EZta2O0raMcRlJNxLjaPJKgcWbwkjeGfjbMDK)1nl6ia5yAFmGWErjSTpcBeGCmTpgqyVaeUAXRocW2K)x64LdTSktsXM85XM2K)x6kYIE8Sv2nbW91LLjPyt(8ytUydTytnpokPJxo0YQKJP9XaydsSPwn64sMUeOCO0NwwLjPytoyt(8ytBY)lBFecWlXvYLhyHn5ZJn1SuCjlfLVICakJnn7Hn0e6iahyPKqaMskLeIsylne2ia5yAFmGWEbiC1IxDeG1SuCjlfLVICakJnn7HnnQaCGLscbyrsGzh5Fa8uzIsylnryJaKJP9Xac7fGdSusiaHZ7DdSusCp1vcq4QfV6iaZfBQ5XrjD8YHwwLCmTpgaBqInqc5bq8fshVCOLv5YOJgoSPzpSHoytoyt(8ytBY)lD8YHwwLjPcWN6Qlguwa64LdTSkkHT0nHncqoM2hdiSxaoWsjHaeoV3nWsjX9uxjaHRw8QJaKwSPMhhL0XlhAzvYX0(yaSbj2Kl20M8)sxrw0JNTYUjaUVUSmjfBYNhBGeYdG4lKUISOhpBLDtaCFDzjmBwk2HnEyttytocWN6Qlguwa64VOe2s3f2ia5yAFmGWEb4alLecq48E3alLe3tDLaeUAXRocqAXMAECushVCOLvjht7JbWgKyd3ijAAkdibwn60G6YiBCqspEXgKytUydKqEaeFH8RU6i)RY4ZxMw8vkfVYLrhnCytZEydc6o2GeBGeYdG4lKF1vUJ8VFYAvUm6OHdBA2dBq0e2GeBGzk243dB6hBqInqc5bq8fYvDAqDUK46uyNCz0rdh20Sh2GaBYNhBQzP4swkkFf5augBA2dBAIgyt(8ydKqEaeFHSijWSJ8paEQm5YOJgoSXp2GartytoydsSbsipaIVq6kYIE8Sv2nbW91LLWSzPyh24HnieGp1vxmOSa0XFrjSTrf2ia5yAFmGWEb4alLecq48E3alLe3tDLaeUAXRocqAXMAECushVCOLvjht7JbWgKydTyd3ijAAkdibwn60G6YiBCqspEXgKytUydKqEaeFH8RU6i)RY4ZxMw8vkfVYLrhnCytZEydI(GniXgiH8ai(c5xDL7i)7NSwLlJoA4WMM9WgAc2GeBGzk243dB6hBqInqc5bq8fYvDAqDUK46uyNCz0rdh20Sh2GaBYNhBQzP4swkkFf5augBA2dBqqdSjFESbsipaIVqwKey2r(hapvMCz0rdh24hBqGOjSjhSbj2ajKhaXxiDfzrpE2k7Ma4(6Ysy2SuSdB8WgecWN6Qlguwa64VOe2IGocBeGCmTpgqyVaCGLscbiCEVBGLsI7PUsacxT4vhb4alThFCWOk7Wg)yt)cWN6QlguwaoewucBrGqyJaKJP9Xac7fGdSusiaHZ7DdSusCp1vcq4QfV6iahyP94Jdgvzh20Sh20Va8PU6IbLfGUsuIsaMUmKG2oLWgHTie2ia5yAFmGWErjSTjHncqoM2hdiSxucB7xyJaKJP9Xac7fLW2(iSraYX0(yaH9Isylne2iahyPKqaMskLecqoM2hdiSxucBPjcBeGdSusiaHz61MSUsaYX0(yaH9IsylDtyJaCGLscbimtpFtpwaYX0(yaH9IsucWHWcBe2IqyJaKJP9Xac7fGdSusiaHZ7DdSusCp1vcWN6QlguwacbeLW2Me2ia5yAFmGWEbiC1IxDeG0InPl37OGaseYsP49sNhk2GeBGzk20Sh2GaBqIn5Inqc5bq8fYvDAqDUK46uyNCz0rdh24Hn0bBYNhBYfBQ5Xrj)QRoY)Qm(8LPfFLsXRKJP9XaydsSbsipaIVq(vxDK)vz85ltl(kLIx5YOJgoSXdBOd2Kd2Kpp2WbVuwXMMXgAqhSjhb4alLecqo4LsPlnOo(PwQROe22VWgbiht7Jbe2laHRw8QJaeMPs0XsSPVydmtXg)EydcSbj2WbVuwLLIYxro0XsSXVh2qhjneGdSusiaNfobFfzxokrjSTpcBeGCmTpgqyVaeUAXRocWAECushVCOLvjht7JbWgKydTyd3ijAAkdibwn60G6YiBCqspEXgKydKqEaeFH0XlhAzvUm6OHdB87Hn0aBqInCWlLvzPO8vKdDSeB8JnnjahyPKqa(vx5oY)(jRvrjSLgcBeGCmTpgqyVaeUAXRocWAECushVCOLvjht7JbWgKyd3ijAAkdibwn60G6YiBCqspEXgKytUydKqEaeFH0XlhAzvUm6OHdB87HniOb2Kpp2ajKhaXxiD8YHwwLlJoA4WMM9WM(Gn5GniXgo4LYQSuu(kYHowIn(XMMeGdSusia)QRCh5F)K1QOe2ste2ia5yAFmGWEbiC1IxDeG0In184OKoE5qlRsoM2hdGniXgo4LYQSuu(kYHowIn(XMMeGdSusia)QRCh5F)K1QOe2s3e2ia5yAFmGWEbiC1IxDeGqc5bq8fYvDAqDUK46uyNCz0rdh243dB6xsdSbj2aZuSPzpSHgcWbwkjeGF1vUJ8VFYAvucBP7cBeGdSusia9LP7tdQdyhksCPjbmtaYX0(yaH9IsyBJkSraYX0(yaH9cq4QfV6iaHeYdG4lK(Y09Pb1bSdfjU0KaMjxgD0W53JccGK20L7Duqajc5QonOoxsCDkSdjKqEaeFH8RUYDK)9twRYLrhnC(PGacWbwkjeGR60G6CjX1PWorjSfbDe2ia5yAFmGWEbiC1IxDeGWmvIowIn9fBGzk24hBqGniXgAXM0L7Duqajc5M4Y0G6O5bGpFAaiahyPKqaUjUmnOoAEa4ZNgaIsylcecBeGCmTpgqyVaeUAXRocqyMInn7Hn9JniXMCXgiH8ai(c5QonOoxsCDkStUm6OHdB87Hn0aBYNhBGeYdG4lK(Y09Pb1bSdfjU0KaMjxgD0WHn(9WgAGn5GniXgo4LYQSuu(kYHowIn(XgecWbwkjeGWm9AtwxjkHTiAsyJaCGLscbimtV2K1vcqoM2hdiSxucBr0VWgbiht7Jbe2laHRw8QJamxSzGL2JpoyuLDyJFpSPFSjFESjxSPn5)LTKUlDjqzsk2GeBGzQeDSeB6l2aZuSXVh2qhSjhSjhSbj2ql2KUCVJcciriDPAeAqDWDc(6uyh2GeBCCDTKiXjlL3MqC9jfIn(Xg6iahyPKqa6s1i0G6G7e81PWorjSfrFe2ia5yAFmGWEbiC1IxDeGdS0E8XbJQSdB87Hn9JniXgAXM0L7DuqajcPlvJqdQdUtWxNc7eGdSusiaDPAeAqDWDc(6uyNOe2IGgcBeGCmTpgqyVaeUAXRocqAXM0L7Duqajcz7BGDKK66uyh2GeBGzQeDSeB6l2aZuSXVh2GaBqInoUUwsK4KLYBtiU(KcXg)ydDWgKytUydTyJJRRLejozP8IOrVMsHyJFSHoyt(8ytnpokPJxo0YQKJP9XaytocWbwkjeGTVb2rsQRtHDcWAwkUo9lar1OXaCBY)lrNT7i)RY4dUtWYLrhnCIsylcAIWgbiht7Jbe2laHRw8QJamxSbMPyJFSbb2Kpp20M8)Yws3LUeOmjfBYNhBYfBQ5Xrj5GxkLU0G64NAPUsoM2hdGniXgiH8ai(cjh8sP0Lguh)ul1vUm6OHdBAgBGeYdG4lKF1vUJ8VFYAvUm6OHdBYbBYbBqIn5In5Inqc5bq8fYvDAqDUK46uyNCz0rdh24hBqGniXMCXgAXMAECuYV6QJ8VkJpFzAXxPu8k5yAFma2Kpp2ajKhaXxi)QRoY)Qm(8LPfFLsXRCz0rdh24hBqGn5Gn5ZJnWmfB8Jn9bBYbBqIn5Inqc5bq8fYV6k3r(3pzTkxgD0WHn(Xgeyt(8ydmtXg)yttytoyt(8yt6Y9okiGeHSukEV05HIn5GniXgAXM0L7Duqajcz7BGDKK66uyNaCGLscby7BGDKK66uyNaSMLIRt)cqunAma3M8)s0z7oY)Qm(G7eSCz0rdNOe2IGUjSraYX0(yaH9cq4QfV6ia5gjrttzazLXhJMYlzDhCshOwKfBqInTj)VSY4Jrt5LSUdoPdulYkD1a7Wg)EydIgfBqInCWlLvzPO8vKdDSeB8Jn9lahyPKqac3b290G6O5bGVNsLvHguIsylc6UWgbiht7Jbe2laHRw8QJaKBKennLbKvgFmAkVK1DWjDGArwSbj20M8)YkJpgnLxY6o4KoqTiR0vdSdB87Hni6d2GeBGeYdG4lKoE5qlRYLrhnCytZydI(XgKytnpokPJxo0YQKJP9XaydsSHdEPSklfLVICOJLyJFSPFb4alLecq4oWUNguhnpa89uQSk0GsucBr0OcBeGCmTpgqyVaeUAXRocqAXM0L7Duqajcz7BGDKK66uyh2GeBGzQeDSeB6l2aZuSXVh2GaBqInoUUwsK4KLYBtiU(KcXg)ydDWgKytBY)lBjDx6sGYKub4alLecW23a7ij11PWobynlfxN(fGOA0yaUn5)LOZ2DK)vz8b3jy5YOJgorjSTj6iSraYX0(yaH9cq4QfV6iaPfBsxU3rbbKiKLsX7LopuSbj2ql2KUCVJcciri5GxkLU0G64NAPUydsSjxSbMPs0XsSPVydmtXg)Eyttyt(8ydh8szvwkkFf5qhlXMMXM(XMCeGdSusialLI3lDEOcWAwkUo9lar1OXaCBY)lrNT7i)RY4dUtWYLrhnCIsyBtie2ia5yAFmGWEbiC1IxDeG0InPl37OGaseYsP49sNhk2GeBOfBsxU3rbbKiKCWlLsxAqD8tTuxSbj2WbVuwLLIYxro0XsSPzpSbb2GeBGzQeDSeB6l2aZuSXVh20KaCGLscbyPu8EPZdvawZsX1PFbiQgngGBt(Fj6SDh5FvgFWDcwUm6OHtucBBQjHncqoM2hdiSxacxT4vhbimtXMM9WM(XgKytUydKqEaeFHCvNguNljUof2jxgD0WHn(9WgAGn5ZJnqc5bq8fsFz6(0G6a2HIexAsaZKlJoA4Wg)EydnWMCWgKydh8szvwkkFf5qhlXg)ydcb4alLecqyME(MESOe22u)cBeGdSusiaHz65B6XcqoM2hdiSxucBBQpcBeGWjTusiafGdSusialLI3lDEOcq4QfV6iaPfBC8JHLscSbj2ql2KUCVJccirilLI3lDEOcqoM2hdiSxucBBIgcBeGWjTusiafGdSusiaH7a7EAqD08aW3tPYQqdkbiC1IxDeG0Ino(XWsjb2GeBsxU3rbbKiKLsX7Lopubiht7Jbe2lkrjaD8YHwwf2iSfHWgbiht7Jbe2laHRw8QJaKwSjD5EhfeqIqwkfVx68qXgKydTyt6Y9okiGeHKdEPu6sdQJFQL6IniXgo4LYk24HnCWlLvj6yj2GeBGzk20m2GaBqIn0InTj)V0XlhAzvMKkahyPKqawkfVx68qfG1SuCD6xaIQrJb42K)xIoB3r(xLXhCNGLlJoA4eLW2Me2ia5yAFmGWEb4alLecq48E3alLe3tDLa8PU6IbLfGqarjSTFHncWbwkjeGoE5qlRcqoM2hdiSxucB7JWgbiht7Jbe2laHRw8QJaCGL2JpoyuLDytZyt)cWbwkjeGR60G6CjX1PWobynlfxN(fGOA0yaUn5)LOZ2DK)vz8b3jy5YOJgorjSLgcBeGCmTpgqyVaeUAXRocWCXgAXM0L7Duqajcz7BGDKK66uyh2Kd2GeBYfBsxU3rbbKiKF1vh5FvgF(Y0IVsP4fBYNhBsxU3rbbKiKF1vUJ8VFYAfBYbBqIndS0E8XbJQSdBAgBAsaoWsjHaS9nWossDDkStawZsX1PFbiQgngGBt(Fj6SDh5FvgFWDcwUm6OHtucBPjcBeGAu8UjPLaeHaKJP9Xac7fGWvlE1raMl2Kl2WnsIMMYasGvJonOUmYghK0JxSbj20M8)Y0LDUKLVuIgLCz0rdh20Sh20e2GeBCCDTKiXjlL3MOZ1Nui24hBOd2Kd2GeBYfBGeYdG4lKR60G6CjX1PWo5YOJgoSXp2GaBYNhBgyP94Jdgvzh24hBqGn5Gn5iahyPKqa(vx5oY)(jRvrjSLUjSraQrX7MKwcqecqoM2hdiSxacxT4vhbyUytUydTyd3ijAAkdibwn60G6YiBCqspEXM85XM2K)x2(ieGxIRKjPyt(8ytBY)lD8YHwwLlJoA4WMMXgeytoydsSjxSbsipaIVqUQtdQZLexNc7KlJoA4Wg)ydcSjFESzGL2JpoyuLDyJFSbb2Kd2KJaCGLscb4xDL7i)7NSwfLWw6UWgbiht7Jbe2laHRw8QJaCGL2JpoyuLDyJFpSPFSbj2ql2KUCVJcciriDPAeAqDWDc(6uyNaCGLscbOlvJqdQdUtWxNc7eLW2gvyJaKJP9Xac7fGWvlE1rasl2KUCVJcciri3exMguhnpa85tdaSbj20M8)YnXLPb1rZdaF(0aqcq8fydsSPn5)LoE5qlRYLrhnCyJFpSPpcWbwkjeGBIltdQJMha(8PbGOe2IGocBeGCmTpgqyVaeUAXRocWbwAp(4Grv2Hn(9WM(fGdSusiax1Pb15sIRtHDcWAwkUo9lar1OXaCBY)lrNT7i)RY4dUtWYLrhnCIsylcecBeGCmTpgqyVaeUAXRocqAXM0L7Duqajc5M4Y0G6O5bGpFAaGniXM2K)xUjUmnOoAEa4ZNgasaIVaBqIndS0E8XbJQSdB8JnieGdSusia3exMguhnpa85tdarjSfrtcBeGCmTpgqyVaeUAXRocqAXM0L7DuqajcPlvJqdQdUtWxNc7eGdSusiaDPAeAqDWDc(6uyNOe2IOFHncqoM2hdiSxacxT4vhbiTyt6Y9okiGeHS9nWossDDkStaoWsjHaS9nWossDDkStawZsX1PFbiQgngGBt(Fj6SDh5FvgFWDcwUm6OHtuIsa6kHncBriSraYX0(yaH9cWbwkjeGW59UbwkjUN6kb4tD1fdklaHaIsyBtcBeGCmTpgqyVaeUAXRocqAXM0L7DuqajczPu8EPZdfBqInWmfBA2dBqGniXMCXgiH8ai(c5QonOoxsCDkStUm6OHdB8Wg6Gn5ZJn5In184OKF1vh5FvgF(Y0IVsP4vYX0(yaSbj2ajKhaXxi)QRoY)Qm(8LPfFLsXRCz0rdh24Hn0bBYbBYNhB4GxkRytZydnOd2KJaCGLscbih8sP0Lguh)ul1vucB7xyJaKJP9Xac7fGWvlE1racZuj6yj20xSbMPyJFpSbb2GeB4GxkRYsr5Rih6yj243dBOJKgcWbwkjeGZcNGVISlhLOe22hHncqoM2hdiSxacxT4vhbiTyt6Y9okiGeHS9nWossDDkSdBqInWmvIowIn9fBGzk243dBqGniXghxxljsCYs5TjexFsHyJFSHoydsSPn5)LTKUlDjqzsQaCGLscby7BGDKK66uyNaSMLIRt)cqunAma3M8)s0z7oY)Qm(G7eSCz0rdNOe2sdHncqoM2hdiSxacxT4vhbiTyt6Y9okiGeHSukEV05HIniXgAXM0L7Duqajcjh8sP0Lguh)ul1fBqInCWlLvzPO8vKdDSeBA2dBqGniXgyMkrhlXM(InWmfB87HnnjahyPKqawkfVx68qfG1SuCD6xaIQrJb42K)xIoB3r(xLXhCNGLlJoA4eLWwAIWgbiht7Jbe2laHRw8QJaKwSPMhhL0XlhAzvYX0(yaSjFESbsipaIVq64LdTSkxgD0WHn(9Wge0raoWsjHa8RU6i)RY4ZxMw8vkfVIsylDtyJaCGLscbOVmDFAqDa7qrIlnjGzcqoM2hdiSxucBP7cBeGCmTpgqyVaeUAXRocWCXMCXgyMIn(9WM(XgKydh8szfB87Hn9Hoytoyt(8ydmtXg)EydnWMCWgKytUydTytnpokPJxo0YQKJP9Xayt(8ydKqEaeFH0XlhAzvUm6OHdB87Hn0eSjhb4alLecWvDAqDUK46uyNaSMLIRt)cqunAma3M8)s0z7oY)Qm(G7eSCz0rdNOe22OcBeGCmTpgqyVaeUAXRocWAECushVCOLvjht7JbWgKydTyd3ijAAkdibwn60G6YiBCqspEXgKydKqEaeFH0XlhAzvUm6OHdB87Hn0aBqInCWlLvzPO8vKdDSeB8JnnjahyPKqa(vx5oY)(jRvrjSfbDe2ia5yAFmGWEbiC1IxDeG184OKoE5qlRsoM2hdGniXgUrs00ugqcSA0Pb1Lr24GKE8IniXMCXgiH8ai(cPJxo0YQCz0rdh243dBqqdSjFESbsipaIVq64LdTSkxgD0WHnn7Hn9bBYbBqInCWlLvzPO8vKdDSeB8JnnjahyPKqa(vx5oY)(jRvrjSfbcHncqoM2hdiSxacxT4vhbiTytnpokPJxo0YQKJP9XaydsSHdEPSklfLVICOJLyJFSPjb4alLecWV6k3r(3pzTkkHTiAsyJaKJP9Xac7fGWvlE1racjKhaXxix1Pb15sIRtHDYLrhnCyJFpSPFjnWgKydmtXMM9WgAiahyPKqa(vx5oY)(jRvrjSfr)cBeGCmTpgqyVaeUAXRocqAXMAECushVCOLvjht7JbWM85XgiH8ai(cPJxo0YQCz0rdh243dBOHaCGLscb4QonOoxsCDkStawZsX1PFbiQgngGBt(Fj6SDh5FvgFWDcwUm6OHtucBr0hHncqoM2hdiSxacxT4vhbiTyt6Y9okiGeHS9nWossDDkSdBqInWmvIowIn9fBGzk243dBqGniXghxxljsCYs5TjexFsHyJFSHoydsSjxSHwSXX11sIeNSuEr0OxtPqSXp2qhSjFESPMhhL0XlhAzvYX0(yaSjhb4alLecW23a7ij11PWobynlfxN(fGOA0yaUn5)LOZ2DK)vz8b3jy5YOJgorjSfbne2ia5yAFmGWEbiC1IxDeG5IndS0E8XbJQSdB87Hn9Jn5ZJn5InTj)VSL0DPlbktsXgKydmtLOJLytFXgyMIn(9Wg6Gn5Gn5GniXgAXM0L7DuqajcPlvJqdQdUtWxNc7WgKyJJRRLejozP82eIRpPqSXp2qhb4alLecqxQgHguhCNGVof2jkHTiOjcBeGCmTpgqyVaeUAXRocqUrs00ugqwz8XOP8sw3bN0bQfzXgKytBY)lRm(y0uEjR7Gt6a1ISsxnWoSXVh2GOrXgKydh8szvwkkFf5qhlXg)yt)cWbwkjeGWDGDpnOoAEa47PuzvObLOe2IGUjSraYX0(yaH9cq4QfV6ia5gjrttzazLXhJMYlzDhCshOwKfBqInTj)VSY4Jrt5LSUdoPdulYkD1a7Wg)EydI(GniXgiH8ai(cPJxo0YQCz0rdh20m2GOFSbj2uZJJs64LdTSk5yAFma2GeB4GxkRYsr5Rih6yj24hB6xaoWsjHaeUdS7Pb1rZdaFpLkRcnOeLWwe0DHncqoM2hdiSxacxT4vhb4alThFCWOk7Wg)Eyt)ydsSHwSjD5EhfeqIq6s1i0G6G7e81PWob4alLecqxQgHguhCNGVof2jkHTiAuHncqoM2hdiSxacxT4vhbimtLOJLytFXgyMIn(XgeydsSHwSjD5EhfeqIqUjUmnOoAEa4ZNgacWbwkjeGBIltdQJMha(8PbGOe22eDe2ia5yAFmGWEbiC1IxDeG5InWmfB8JniWM85XM2K)x2s6U0LaLjPyt(8ytUytnpokjh8sP0Lguh)ul1vYX0(yaSbj2ajKhaXxi5GxkLU0G64NAPUYLrhnCytZydKqEaeFH8RUYDK)9twRYLrhnCytoytoydsSjxSjxSbsipaIVqUQtdQZLexNc7KlJoA4Wg)ydcSbj2Kl2ql2uZJJs(vxDK)vz85ltl(kLIxjht7JbWM85XgiH8ai(c5xD1r(xLXNVmT4RukELlJoA4Wg)ydcSjhSjFESbMPyJFSPpytoydsSjxSbsipaIVq(vx5oY)(jRv5YOJgoSXp2GaBYNhBGzk24hBAcBYbBYNhBsxU3rbbKiKLsX7LopuSjhSbj2ql2KUCVJcciriBFdSJKuxNc7eGdSusiaBFdSJKuxNc7eG1SuCD6xaIQrJb42K)xIoB3r(xLXhCNGLlJoA4eLW2MqiSraYX0(yaH9cq4QfV6iaHzk20Sh20p2GeBYfBGeYdG4lKR60G6CjX1PWo5YOJgoSXVh2qdSjFESbsipaIVq6lt3NguhWouK4stcyMCz0rdh243dBOb2Kd2GeB4GxkRYsr5Rih6yj24hBqiahyPKqacZ0Z30JfLW2MAsyJaKJP9Xac7fGWvlE1racZuSPzpSPFSbj2Kl2ajKhaXxix1Pb15sIRtHDYLrhnCyJFpSHgyt(8ydKqEaeFH0xMUpnOoGDOiXLMeWm5YOJgoSXVh2qdSjhSbj2WbVuwLLIYxro0XsSXp2GqaoWsjHaeMPxBY6krjSTP(f2ia5yAFmGWEbiC1IxDeG0InPl37OGaseYsP49sNhk2GeBOfBsxU3rbbKiKCWlLsxAqD8tTuxSbj2Kl2aZuj6yj20xSbMPyJFpSPjSjFESHdEPSklfLVICOJLytZyt)ytocWbwkjeGLsX7LopubynlfxN(fGOA0yaUn5)LOZ2DK)vz8b3jy5YOJgorjSTP(iSraoWsjHaeMPNVPhla5yAFmGWErjSTjAiSraoWsjHaeMPxBY6kbiht7Jbe2lkHTnrte2iaHtAPKqakaHRw8QJaKwSXXpgwkjWgKydTyt6Y9okiGeHSukEV05HkahyPKqawkfVx68qfGCmTpgqyVOe22eDtyJaeoPLscbOaeUAXRocqAXgh)yyPKaBqInPl37OGaseYsP49sNhQaCGLscbiChy3tdQJMha(EkvwfAqja5yAFmGWErjkbieqyJWwecBeGdSusia1OhPJplt4qaYX0(yaH9IsyBtcBeGdSusiaBFecW9twRcqoM2hdiSxucB7xyJaCGLscbylVoE70GsaYX0(yaH9IsyBFe2ia5yAFmGWEbiC1IxDeGWmvIowIn9fBGzk243dBqGniXgo4LYQSuu(kYHowIn(9Wg6iPHaCGLscb4SWj4Ri7YrjkHT0qyJaCGLscb4tPYk3rZjauOCucqoM2hdiSxuIsucWE86usiSTj6GGUth6gDqirqdbOVzdnOCcqby6s(6JfG0uGn0uBjdtkgaBA5pzzSbsqBNcBAzknCsSHMsiKtlh2eKOVzZI(tEyZalLeoSHepRsm9dSus4KPldjOTt59FJRdt)alLeoz6YqcA7un4z3NqaW0pWsjHtMUmKG2ovdE2njuOCutPKatpnfydymPUmsHn7OaytBY)ZayJRMYHnT8NSm2ajOTtHnTmLgoSzcaSjD5(MsQsdkSrDydajyjM(bwkjCY0LHe02PAWZoxmPUmsDUAkhM(bwkjCY0LHe02PAWZUusPKat)alLeoz6YqcA7un4zhmtV2K1vy6hyPKWjtxgsqBNQbp7Gz65B6Xy6X0ttb2qtTLmmPyaSH7XRvSPuugBQmgBgyrwSrDyZ0B030(yjM(bwkjCEtsrUPQb2HPFGLscxdE25s5zVSjaoxTAhBH(9QzP4scWTj)VeoUsdk5YdSW0pWsjHRbp7kscm7i)RBw0XcnkE7npVgLowKcRlJNxL5rhjnW0pWsjHRbp7sjLscl0VxBY)lD8YHwwLjP5Z3M8)sxrw0JNTYUjaUVUSmjnF(CPTMhhL0XlhAzvYX0(yaK1QrhxY0LaLdL(0YQC5bw5KpFBY)lBFecWlXvYLhyLpFnlfxYsr5RihGYn7rtOdM(bwkjCn4zxrsGzh5Fa8uzwOFVAwkUKLIYxroaLB2RrX0pWsjHRbp7GZ7DdSusCp1vwedk754LdTSAH(9YTMhhL0XlhAzvYX0(yaKqc5bq8fshVCOLv5YOJgUM9Oto5Z3M8)shVCOLvzskM(bwkjCn4zhCEVBGLsI7PUYIyqzph)Tq)E0wZJJs64LdTSk5yAFmaYCBt(FPRil6XZwz3ea3xxwMKMppKqEaeFH0vKf94zRSBcG7RllHzZsXoVMYbt)alLeUg8SdoV3nWsjX9uxzrmOSNJ)wOFpAR5XrjD8YHwwLCmTpgaj3ijAAkdibwn60G6YiBCqspErMlKqEaeFH8RU6i)RY4ZxMw8vkfVYLrhnCn7HGUJesipaIVq(vx5oY)(jRv5YOJgUM9q0esyM63RFKqc5bq8fYvDAqDUK46uyNCz0rdxZEiYNVMLIlzPO8vKdq5M9AIg5ZdjKhaXxilscm7i)dGNktUm6OHZpcenLdsiH8ai(cPRil6XZwz3ea3xxwcZMLIDEiW0pWsjHRbp7GZ7DdSusCp1vwedk754Vf63J2AECushVCOLvjht7Jbqsl3ijAAkdibwn60G6YiBCqspErMlKqEaeFH8RU6i)RY4ZxMw8vkfVYLrhnCn7HOpiHeYdG4lKF1vUJ8VFYAvUm6OHRzpAcsyM63RFKqc5bq8fYvDAqDUK46uyNCz0rdxZEiYNVMLIlzPO8vKdq5M9qqJ85HeYdG4lKfjbMDK)bWtLjxgD0W5hbIMYbjKqEaeFH0vKf94zRSBcG7RllHzZsXopey6hyPKW1GNDW59UbwkjUN6klIbL9gcBH(9gyP94JdgvzN)(X0pWsjHRbp7GZ7DdSusCp1vwedk75kl0V3alThFCWOk7A2RFm9y6hyPKWjhc7bN37gyPK4EQRSigu2dcGPFGLscNCiCdE2XbVukDPb1Xp1sDTq)E0MUCVJccirilLI3lDEOiHzAZEiqMlKqEaeFHCvNguNljUof2jxgD0W5rN85ZTMhhL8RU6i)RY4ZxMw8vkfVsoM2hdGesipaIVq(vxDK)vz85ltl(kLIx5YOJgop6Kt(8CWlL1MPbDYbt)alLeo5q4g8SBw4e8vKD5OSq)EWmvIow2xyM63dbso4LYQSuu(kYHow63JosAGPFGLscNCiCdE29vx5oY)(jRvl0VxnpokPJxo0YQKJP9XaiPLBKennLbKaRgDAqDzKnoiPhViHeYdG4lKoE5qlRYLrhnC(9Obso4LYQSuu(kYHow6Vjm9dSus4KdHBWZUV6k3r(3pzTAH(9Q5XrjD8YHwwLCmTpgaj3ijAAkdibwn60G6YiBCqspErMlKqEaeFH0XlhAzvUm6OHZVhcAKppKqEaeFH0XlhAzvUm6OHRzV(Kdso4LYQSuu(kYHow6Vjm9dSus4KdHBWZUV6k3r(3pzTAH(9OTMhhL0XlhAzvYX0(yaKCWlLvzPO8vKdDS0Fty6hyPKWjhc3GNDF1vUJ8VFYA1c97bjKhaXxix1Pb15sIRtHDYLrhnC(96xsdKWmTzpAGPFGLscNCiCdE25lt3NguhWouK4stcygM(bwkjCYHWn4z3QonOoxsCDkSZIAwkUo97bjKhaXxi9LP7tdQdyhksCPjbmtUm6OHZVhfeajTPl37OGaseYvDAqDUK46uyhsiH8ai(c5xDL7i)7NSwLlJoA48tbbW0pWsjHtoeUbp72exMguhnpa85tdal0VhmtLOJL9fMP(rGK20L7Duqajc5M4Y0G6O5bGpFAaGPFGLscNCiCdE2bZ0RnzDLf63dMPn71pYCHeYdG4lKR60G6CjX1PWo5YOJgo)E0iFEiH8ai(cPVmDFAqDa7qrIlnjGzYLrhnC(9Oroi5GxkRYsr5Rih6yPFey6hyPKWjhc3GNDWm9AtwxHPFGLscNCiCdE25s1i0G6G7e81PWol0VxUdS0E8XbJQSZVx)5ZNBBY)lBjDx6sGYKuKWmvIow2xyM63Jo5KdsAtxU3rbbKiKUuncnOo4obFDkSdPJRRLejozP82eIRpPqm9dSus4KdHBWZoxQgHguhCNGVof2zH(9gyP94JdgvzNFV(rsB6Y9okiGeH0LQrOb1b3j4RtHDy6hyPKWjhc3GNDTVb2rsQRtHDwuZsX1PFpunAma3M8)s0z7oY)Qm(G7eSCz0rdNf63J20L7Duqajcz7BGDKK66uyhsyMkrhl7lmt97HaPJRRLejozP82eIRpPqK5sRJRRLejozP8IOrVMsH5ZxZJJs64LdTSk5yAFmqoy6hyPKWjhc3GNDTVb2rsQRtHDwuZsX1PFpunAma3M8)s0z7oY)Qm(G7eSCz0rdNf63lxyM6hr(8Tj)VSL0DPlbktsZNp3AECuso4LsPlnOo(PwQRKJP9XaiHeYdG4lKCWlLsxAqD8tTux5YOJgUMHeYdG4lKF1vUJ8VFYAvUm6OHlNCqMBUqc5bq8fYvDAqDUK46uyNCz0rdNFeiZL2AECuYV6QJ8VkJpFzAXxPu8k5yAFmq(8qc5bq8fYV6QJ8VkJpFzAXxPu8kxgD0W5hro5ZdZu)9jhK5cjKhaXxi)QRCh5F)K1QCz0rdNFe5ZdZu)nLt(8Pl37OGaseYsP49sNhAoiPnD5EhfeqIq2(gyhjPUof2HPFGLscNCiCdE2b3b290G6O5bGVNsLvHguwOFpUrs00ugqwz8XOP8sw3bN0bQfzr2M8)YkJpgnLxY6o4KoqTiR0vdSZVhIgfjh8szvwkkFf5qhl93pM(bwkjCYHWn4zhChy3tdQJMha(EkvwfAqzH(94gjrttzazLXhJMYlzDhCshOwKfzBY)lRm(y0uEjR7Gt6a1ISsxnWo)Ei6dsiH8ai(cPJxo0YQCz0rdxZi6hznpokPJxo0YQKJP9Xai5GxkRYsr5Rih6yP)(X0pWsjHtoeUbp7AFdSJKuxNc7SOMLIRt)EOA0yaUn5)LOZ2DK)vz8b3jy5YOJgol0VhTPl37OGaseY23a7ij11PWoKWmvIow2xyM63dbshxxljsCYs5TjexFsHiBt(FzlP7sxcuMKIPFGLscNCiCdE2vkfVx68qTOMLIRt)EOA0yaUn5)LOZ2DK)vz8b3jy5YOJgol0VhTPl37OGaseYsP49sNhksAtxU3rbbKiKCWlLsxAqD8tTuxK5cZuj6yzFHzQFVMYNNdEPSklfLVICOJLn3Foy6hyPKWjhc3GNDLsX7LopulQzP460VhQgngGBt(Fj6SDh5FvgFWDcwUm6OHZc97rB6Y9okiGeHSukEV05HIK20L7Duqajcjh8sP0Lguh)ul1fjh8szvwkkFf5qhlB2dbsyMkrhl7lmt971eM(bwkjCYHWn4zhmtpFtp2c97bZ0M96hzUqc5bq8fYvDAqDUK46uyNCz0rdNFpAKppKqEaeFH0xMUpnOoGDOiXLMeWm5YOJgo)E0ihKCWlLvzPO8vKdDS0pcm9dSus4KdHBWZoyME(MEmM(bwkjCYHWn4zxPu8EPZd1c97rRJFmSusGK20L7DuqajczPu8EPZdft)alLeo5q4g8SdUdS7Pb1rZdaFpLkRcnOSq)E064hdlLeitxU3rbbKiKLsX7Lopum9y6hyPKWjHaEA0J0XNLjCCvgF(Y0IVsP4ft)alLeojeObp7AFecW9twRy6hyPKWjHan4zxlVoE70Gct)alLeojeObp7MfobFfzxokl0VhmtLOJL9fMP(9qGKdEPSklfLVICOJL(9OJKgy6hyPKWjHan4z3tPYk3rZjauOCuy6X0pWsjHt64VxPu8EPZd1IAwkUo97bWTj)VeD2UJ8VkJp4oblbi(cl0VhTPl37OGaseYsP49sNhksAtxU3rbbKiKCWlLsxAqD8tTuxKCWlLvpo4LYQeDSejmtBgbM(bwkjCsh)BWZUzHtWxr2LJYc97bZuj6yzFHzQFpei5GxkRYsr5Rih6yPFp6iPbM(bwkjCsh)BWZo48E3alLe3tDLfXGYEqam9dSus4Ko(3GNDUISOhpBLDtaCFDzl0VhTTj)V0vKf94zRSBcG7RlltsX0pWsjHt64FdE2bN37gyPK4EQRSigu2BiSf63BGL2JpoyuLD(7ht)alLeoPJ)n4zhCEVBGLsI7PUYIyqzpxzH(9gyP94JdgvzxZE9JPht)alLeoPJxo0YQxPu8EPZd1IAwkUo97HQrJb42K)xIoB3r(xLXhCNGLlJoA4Sq)E0MUCVJccirilLI3lDEOiPnD5EhfeqIqYbVukDPb1Xp1sDrYbVuw94GxkRs0XsKWmTzeiPTn5)LoE5qlRYKum9dSus4KoE5qlRn4zhCEVBGLsI7PUYIyqzpiaM(bwkjCshVCOL1g8SZXlhAzft)alLeoPJxo0YAdE2TQtdQZLexNc7SOMLIRt)EOA0yaUn5)LOZ2DK)vz8b3jy5YOJgol0V3alThFCWOk7AUFm9dSus4KoE5qlRn4zx7BGDKK66uyNf1SuCD63dvJgdWTj)VeD2UJ8VkJp4oblxgD0WzH(9YL20L7Duqajcz7BGDKK66uyxoiZnD5EhfeqIq(vxDK)vz85ltl(kLI385txU3rbbKiKF1vUJ8VFYAnhKdS0E8XbJQSR5MW0pWsjHt64LdTS2GNDF1vUJ8VFYA1c97LBUCJKOPPmGey1OtdQlJSXbj94fzBY)ltx25sw(sjAuYLrhnCn71eshxxljsCYs5Tj6C9jfMdYCHeYdG4lKR60G6CjX1PWo5YOJgo)iYNFGL2JpoyuLD(rKtowOrX7MKwEiW0pWsjHt64LdTS2GNDF1vUJ8VFYA1c97LBU0YnsIMMYasGvJonOUmYghK0J385Bt(Fz7JqaEjUsMKMpFBY)lD8YHwwLlJoA4AgroiZfsipaIVqUQtdQZLexNc7KlJoA48JiF(bwAp(4Grv25hro5yHgfVBsA5Hat)alLeoPJxo0YAdE25s1i0G6G7e81PWol0V3alThFCWOk7871psAtxU3rbbKiKUuncnOo4obFDkSdt)alLeoPJxo0YAdE2TjUmnOoAEa4ZNgawOFpAtxU3rbbKiKBIltdQJMha(8PbaY2K)xUjUmnOoAEa4ZNgasaIVazBY)lD8YHwwLlJoA4871hm9dSus4KoE5qlRn4z3QonOoxsCDkSZIAwkUo97HQrJb42K)xIoB3r(xLXhCNGLlJoA4Sq)EdS0E8XbJQSZVx)y6hyPKWjD8YHwwBWZUnXLPb1rZdaF(0aWc97rB6Y9okiGeHCtCzAqD08aWNpnaq2M8)YnXLPb1rZdaF(0aqcq8fihyP94JdgvzNFey6hyPKWjD8YHwwBWZoxQgHguhCNGVof2zH(9OnD5EhfeqIq6s1i0G6G7e81PWom9dSus4KoE5qlRn4zx7BGDKK66uyNf1SuCD63dvJgdWTj)VeD2UJ8VkJp4oblxgD0WzH(9OnD5EhfeqIq2(gyhjPUof2HPht)alLeoPJxo0Y6rs5GxVsP49sNhQf1SuCD63dvJgdWTj)VeD2UJ8VkJp4oblxgD0WzH(9OnD5EhfeqIqwkfVx68qrsB6Y9okiGeHKdEPu6sdQJFQL6IKdEPS6XbVuwLOJLiHzAZiqsBBY)lD8YHwwLjPiHeYdG4lKF1vUJ8VFYAvUm6OHRzp6GPFGLscN0XlhAz9iPCWBdE2nlCc(kYUCuwOFpyMkrhl7lmt97Hajh8szvwkkFf5qhl97rhjnW0pWsjHt64LdTSEKuo4Tbp7GZ7DdSusCp1vwedk7bbSq)Eqc5bq8fYV6k3r(3pzTkxgD0W5hbM(bwkjCshVCOL1JKYbVn4zNJxo0YQf63dsipaIVq(vx5oY)(jRv5YOJgo)iW0pWsjHt64LdTSEKuo4Tbp7w1Pb15sIRtHDwuZsX1PFpunAma3M8)s0z7oY)Qm(G7eSCz0rdNf63BGL2JpoyuLDn3pY2K)x64LdTSktsX0pWsjHt64LdTSEKuo4Tbp7AFdSJKuxNc7SOMLIRt)EOA0yaUn5)LOZ2DK)vz8b3jy5YOJgol0VxU0MUCVJcciriBFdSJKuxNc7YbzUPl37OGaseYV6QJ8VkJpFzAXxPu8MdM(bwkjCshVCOL1JKYbVn4z3xDL7i)7NSwTq)Eqc5bq8fYvDAqDUK46uyNCz0rdNFe5Z3M8)shVCOLvjaXxyHgfVBsA5Hat)alLeoPJxo0Y6rs5G3g8SR9nWossDDkSZIAwkUo97HQrJb42K)xIoB3r(xLXhCNGLlJoA4Sq)ETj)V0XlhAzvcq8fiHzAZEnHesipaIVq64LdTSkxgD0W1ShDqMUCVJccirilLI3lDEOy6hyPKWjD8YHwwpskh82GNDLsX7LopulQzP460VhQgngGBt(Fj6SDh5FvgFWDcwUm6OHZc97rB6Y9okiGeHSukEV05HIK20L7Duqajcjh8sP0Lguh)ul1fjmt9qGPht)alLeoPR8GZ7DdSusCp1vwedk7bbW0pWsjHt6Qg8SJdEPu6sdQJFQL6AH(9OnD5EhfeqIqwkfVx68qrcZ0M9qGmxiH8ai(c5QonOoxsCDkStUm6OHZJo5ZNBnpok5xD1r(xLXNVmT4RukELCmTpgajKqEaeFH8RU6i)RY4ZxMw8vkfVYLrhnCE0jN855GxkRntd6KdM(bwkjCsx1GNDZcNGVISlhLf63dMPs0XY(cZu)EiqYbVuwLLIYxro0Xs)E0rsdm9dSus4KUQbp7AFdSJKuxNc7SOMLIRt)EOA0yaUn5)LOZ2DK)vz8b3jy5YOJgol0VhTPl37OGaseY23a7ij11PWoKWmvIow2xyM63dbshxxljsCYs5TjexFsHiBt(FzlP7sxcuMKIPFGLscN0vn4zxPu8EPZd1IAwkUo97HQrJb42K)xIoB3r(xLXhCNGLlJoA4Sq)E0MUCVJccirilLI3lDEOiPnD5EhfeqIqYbVukDPb1Xp1sDrYbVuwLLIYxro0XYM9qGeMPs0XY(cZu)EnHPFGLscN0vn4z3xD1r(xLXNVmT4RukETq)E0wZJJs64LdTSk5yAFmq(8qc5bq8fshVCOLv5YOJgo)EiOdM(bwkjCsx1GND(Y09Pb1bSdfjU0KaMHPFGLscN0vn4z3QonOoxsCDkSZIAwkUo97HQrJb42K)xIoB3r(xLXhCNGLlJoA4Sq)E5Mlmt971pso4LYQFV(qNCYNhMP(9OroiZL2AECushVCOLvjht7JbYNhsipaIVq64LdTSkxgD0W53JMKdM(bwkjCsx1GNDF1vUJ8VFYA1c97vZJJs64LdTSk5yAFmasA5gjrttzajWQrNguxgzJds6XlsiH8ai(cPJxo0YQCz0rdNFpAGKdEPSklfLVICOJL(Bct)alLeoPRAWZUV6k3r(3pzTAH(9Q5XrjD8YHwwLCmTpgaj3ijAAkdibwn60G6YiBCqspErMlKqEaeFH0XlhAzvUm6OHZVhcAKppKqEaeFH0XlhAzvUm6OHRzV(Kdso4LYQSuu(kYHow6Vjm9dSus4KUQbp7(QRCh5F)K1Qf63J2AECushVCOLvjht7JbqYbVuwLLIYxro0Xs)nHPFGLscN0vn4z3xDL7i)7NSwTq)Eqc5bq8fYvDAqDUK46uyNCz0rdNFV(L0ajmtB2Jgy6hyPKWjDvdE2TQtdQZLexNc7SOMLIRt)EOA0yaUn5)LOZ2DK)vz8b3jy5YOJgol0VhT184OKoE5qlRsoM2hdKppKqEaeFH0XlhAzvUm6OHZVhnW0pWsjHt6Qg8SR9nWossDDkSZIAwkUo97HQrJb42K)xIoB3r(xLXhCNGLlJoA4Sq)E0MUCVJcciriBFdSJKuxNc7qcZuj6yzFHzQFpeiDCDTKiXjlL3MqC9jfImxADCDTKiXjlLxen61ukmF(AECushVCOLvjht7JbYbt)alLeoPRAWZoxQgHguhCNGVof2zH(9YDGL2JpoyuLD(96pF(CBt(FzlP7sxcuMKIeMPs0XY(cZu)E0jNCqsB6Y9okiGeH0LQrOb1b3j4RtHDiDCDTKiXjlL3MqC9jfIPFGLscN0vn4zhChy3tdQJMha(EkvwfAqzH(94gjrttzazLXhJMYlzDhCshOwKfzBY)lRm(y0uEjR7Gt6a1ISsxnWo)EiAuKCWlLvzPO8vKdDS0F)y6hyPKWjDvdE2b3b290G6O5bGVNsLvHguwOFpUrs00ugqwz8XOP8sw3bN0bQfzr2M8)YkJpgnLxY6o4KoqTiR0vdSZVhI(GesipaIVq64LdTSkxgD0W1mI(rwZJJs64LdTSk5yAFmaso4LYQSuu(kYHow6VFm9dSus4KUQbp7CPAeAqDWDc(6uyNf63BGL2JpoyuLD(96hjTPl37OGasesxQgHguhCNGVof2HPFGLscN0vn4z3M4Y0G6O5bGpFAayH(9GzQeDSSVWm1pcK0MUCVJcciri3exMguhnpa85tdam9dSus4KUQbp7AFdSJKuxNc7SOMLIRt)EOA0yaUn5)LOZ2DK)vz8b3jy5YOJgol0VxUWm1pI85Bt(FzlP7sxcuMKMpFU184OKCWlLsxAqD8tTuxjht7JbqcjKhaXxi5GxkLU0G64NAPUYLrhnCndjKhaXxi)QRCh5F)K1QCz0rdxo5Gm3CHeYdG4lKR60G6CjX1PWo5YOJgo)iqMlT184OKF1vh5FvgF(Y0IVsP4vYX0(yG85HeYdG4lKF1vh5FvgF(Y0IVsP4vUm6OHZpICYNhMP(7toiZfsipaIVq(vx5oY)(jRv5YOJgo)iYNhMP(BkN85txU3rbbKiKLsX7Lop0CqsB6Y9okiGeHS9nWossDDkSdt)alLeoPRAWZoyME(MESf63dMPn71pYCHeYdG4lKR60G6CjX1PWo5YOJgo)E0iFEiH8ai(cPVmDFAqDa7qrIlnjGzYLrhnC(9Oroi5GxkRYsr5Rih6yPFey6hyPKWjDvdE2bZ0RnzDLf63dMPn71pYCHeYdG4lKR60G6CjX1PWo5YOJgo)E0iFEiH8ai(cPVmDFAqDa7qrIlnjGzYLrhnC(9Oroi5GxkRYsr5Rih6yPFey6hyPKWjDvdE2vkfVx68qTOMLIRt)EOA0yaUn5)LOZ2DK)vz8b3jy5YOJgol0VhTPl37OGaseYsP49sNhksAtxU3rbbKiKCWlLsxAqD8tTuxK5cZuj6yzFHzQFVMYNNdEPSklfLVICOJLn3Foy6hyPKWjDvdE2bZ0Z30JX0pWsjHt6Qg8SdMPxBY6km9dSus4KUQbp7kLI3lDEOwOFpAD8JHLscK0MUCVJccirilLI3lDEOy6hyPKWjDvdE2b3b290G6O5bGVNsLvHguwOFpAD8JHLscKPl37OGaseYsP49sNhQaCsQmYkaPPk3PpvuIsia]] )
end