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
    } )

    spec:RegisterPack( "Windwalker", 20180701.1500, 
        [[diuKSbqiKspcPiHnbrJsuPtjQ4vsbZIs4wsvPDr0VOuzyivCmiSmPqptQQMMuKUgsHTHueFdPs14qQuoNuv06KIyEsrDpQY(OQ6GifjAHuQ6HifP4Iifj1irkssNePiLwjsv3ePij2jLspfOPsP4RifPAVe(RkdMIdRyXsPhdAYaUmQnRQ(msgTOCAsRgPOETuz2QYTH0Uf(nIHlshxQkSCLEovMUKRlITlv57uvgpLOZtjTEKkz(IQ2pulqiSracmflSTr6GGUrh6oDqirqd60N0PPcWYAklathy3qXcWyqzbinDna8nVoEfGPJ1hzae2iaDKKfYcWSQsDnXo7O0klPvcjO25u0K3ukjG78l7Ckk0U2hP1U2)0xaUNDPl5Rp2zNnkVnIWoBAeXrtfs0D001aW3864v6uuOaSnrFfnTHOvacmflSTr6GGUrhAs)0rIGUrde0GUlaDPmuyBJ0K(uacWoOa0Mm1HnQdBQmgBa4)K8kSHMUga(MxhVyZalLeyt6a7WMpzXg7NQEm28jl2qtjDXlPYKy6X0ttBHn(gh20MOVcB(lbfBQmgBO7Y(L0aBav0K3ukjOPzNFHnPl5RpwIPhtpnnztqXUMGPhHeBWMXLnOtWU7VCqxwXgFJdBwo9nqgaBATInF1vh5FvgF(Y0IVsP4fBYTMhhvosm9y6BuInyZMe3alLe3tDf2OoSjXXayZNSyJRSBim2mWsjb28ux5WMwgojogBQm2k2mlJnOjvY8Ew7lBj8L40ESetpM((Lyd2qtjaadGnd2a3b290G6O5bGVNsLvHguyZxFpEXMbwkjWghbBQSPWgTWgF67HnTm2SmKGIYbadGn(Y4aBSssWgu15WMbBkLI3lDEOydzXgRKKfBGzk2aWWXQdBijf2q(ydKG2of2KUCpoknOWMsP49sNhk28xck20YAqHnldjOOCaWayt5tHm2Ob2myZs8jfGp1voHncW0LHe02Pe2iSfHWgbiht7Jbe2lkHTnkSraYX0(yaH9IsyB)cBeGCmTpgqyVOe22uHncqoM2hdiSxucBPHWgb4alLecWusPKqaYX0(yaH9IsylnryJaCGLscbimtV2K1vcqoM2hdiSxucBP7cBeGdSusiaHz65B6XcqoM2hdiSxuIsa64VWgHTie2ia5yAFmGWEbiC1IxDeG0InPl37OGaseYsP49sNhk2GeBOfBsxU3rbbKiKCWlLsxAqD8tTuxSbj2WbVuwXgpSHdEPSkrhlXgKydmtXMMXgecWbwkjeGLsX7LopubynlfxN(fGaCBY)lrNT7i)RY4dUtWsaIVqucBBuyJaKJP9Xac7fGWvlE1racZuj6yj20xSbMPyJFpSbb2GeB4GxkRYsr5Rih6yj243dBOJKgcWbwkjeGZcNGVISlhLOe22VWgbiht7Jbe2lahyPKqacN37gyPK4EQReGp1vxmOSaecikHTnvyJaKJP9Xac7fGWvlE1rasl20M8)sxrw0JNTYUjaUVUSmjvaoWsjHa0vKf94zRSBcG7RllkHT0qyJaKJP9Xac7fGdSusiaHZ7DdSusCp1vcq4QfV6iahyP94Jdgvzh24hB6xa(uxDXGYcWHWIsylnryJaKJP9Xac7fGdSusiaHZ7DdSusCp1vcq4QfV6iahyP94Jdgvzh20Sh20Va8PU6IbLfGUsuIsacbe2iSfHWgb4alLecqn6r64ZYeoeGCmTpgqyVOe22OWgb4alLecW2hHaC)K1QaKJP9Xac7fLW2(f2iahyPKqa2YRJ3onOeGCmTpgqyVOe22uHncqoM2hdiSxacxT4vhbimtLOJLytFXgyMIn(9WgeydsSHdEPSklfLVICOJLyJFpSHosAiahyPKqaolCc(kYUCuIsylne2iahyPKqa(uQSYD0CcafkhLaKJP9Xac7fLOeGoE5qlRhjLdEf2iSfHWgbiht7Jbe2laHRw8QJaKwSjD5EhfeqIqwkfVx68qXgKydTyt6Y9okiGeHKdEPu6sdQJFQL6IniXgo4LYk24HnCWlLvj6yj2GeBGzk20m2GaBqIn0InTj)V0XlhAzvMKIniXgiH8ai(c5xDL7i)7NSwLlJoA4WMM9Wg6iahyPKqawkfVx68qfG1SuCD6xaIQrta42K)xIoB3r(xLXhCNGLlJoA4eLW2gf2ia5yAFmGWEbiC1IxDeGWmvIowIn9fBGzk243dBqGniXgo4LYQSuu(kYHowIn(9Wg6iPHaCGLscb4SWj4Ri7YrjkHT9lSraYX0(yaH9cWbwkjeGW59UbwkjUN6kbiC1IxDeGqc5bq8fYV6k3r(3pzTkxgD0WHn(XgecWN6QlguwacbeLW2MkSraYX0(yaH9cq4QfV6iaHeYdG4lKF1vUJ8VFYAvUm6OHdB8JnieGdSusiaD8YHwwfLWwAiSraYX0(yaH9cq4QfV6iahyP94Jdgvzh20m20p2GeBAt(FPJxo0YQmjvaoWsjHaCvNguNljUof2jaRzP460VaevJMaWTj)VeD2UJ8VkJp4oblxgD0WjkHT0eHncqoM2hdiSxacxT4vhbyUydTyt6Y9okiGeHS9nWossDDkSdBYbBqIn5InPl37OGaseYV6QJ8VkJpFzAXxPu8In5iahyPKqa2(gyhjPUof2jaRzP460VaevJMaWTj)VeD2UJ8VkJp4oblxgD0WjkHT0DHncqoM2hdiSxaQrX7MKwcqecWbwkjeGF1vUJ8VFYAvacxT4vhbiKqEaeFHCvNguNljUof2jxgD0WHn(Xgeyt(8ytBY)lD8YHwwLaeFHOe2s3e2ia5yAFmGWEbiC1IxDeGTj)V0XlhAzvcq8fydsSbMPytZEytJydsSbsipaIVq64LdTSkxgD0WHnn7Hn0bBqInPl37OGaseYsP49sNhQaCGLscby7BGDKK66uyNaSMLIRt)cqunAca3M8)s0z7oY)Qm(G7eSCz0rdNOe22NcBeGCmTpgqyVaeUAXRocqAXM0L7DuqajczPu8EPZdfBqIn0InPl37OGaseso4LsPlnOo(PwQl2GeBGzk24HnieGdSusialLI3lDEOcWAwkUo9lar1OjaCBY)lrNT7i)RY4dUtWYLrhnCIsucWHWcBe2IqyJaKJP9Xac7fGdSusiaHZ7DdSusCp1vcWN6QlguwacbeLW2gf2ia5yAFmGWEbiC1IxDeG0InPl37OGaseYsP49sNhk2GeBGzk20Sh2GaBqIn5Inqc5bq8fYvDAqDUK46uyNCz0rdh24Hn0bBYNhBYfBQ5Xrj)QRoY)Qm(8LPfFLsXRKJP9XaydsSbsipaIVq(vxDK)vz85ltl(kLIx5YOJgoSXdBOd2Kd2Kpp2WbVuwXMMXgAqhSjhb4alLecqo4LsPlnOo(PwQROe22VWgbiht7Jbe2laHRw8QJaeMPs0XsSPVydmtXg)EydcSbj2WbVuwLLIYxro0XsSXVh2qhjneGdSusiaNfobFfzxokrjSTPcBeGCmTpgqyVaeUAXRocWAECushVCOLvjht7JbWgKydTyd3hjAAkdibwn60G6YiBCqspEXgKydKqEaeFH0XlhAzvUm6OHdB87Hn0aBqInCWlLvzPO8vKdDSeB8JnnkahyPKqa(vx5oY)(jRvrjSLgcBeGCmTpgqyVaeUAXRocWAECushVCOLvjht7JbWgKyd3hjAAkdibwn60G6YiBCqspEXgKytUydKqEaeFH0XlhAzvUm6OHdB87HniOb2Kpp2ajKhaXxiD8YHwwLlJoA4WMM9WMMIn5GniXgo4LYQSuu(kYHowIn(XMgfGdSusia)QRCh5F)K1QOe2ste2ia5yAFmGWEbiC1IxDeG0In184OKoE5qlRsoM2hdGniXgo4LYQSuu(kYHowIn(XMgfGdSusia)QRCh5F)K1QOe2s3f2ia5yAFmGWEbiC1IxDeGqc5bq8fYvDAqDUK46uyNCz0rdh243dB6xsdSbj2aZuSPzpSHgcWbwkjeGF1vUJ8VFYAvucBPBcBeGdSusia9LP7tdQdyhksCPjbmtaYX0(yaH9IsyBFkSraYX0(yaH9cq4QfV6iaHeYdG4lK(Y09Pb1bSdfjU0KaMjxgD0W53JccGK20L7Duqajc5QonOoxsCDkSdjKqEaeFH8RUYDK)9twRYLrhnC(PGacWbwkjeGR60G6CjX1PWorjSfbDe2ia5yAFmGWEbiC1IxDeGWmvIowIn9fBGzk24hBqGniXgAXM0L7Duqajc5M4Y0G6O5bGpFAaiahyPKqaUjUmnOoAEa4ZNgaIsylcecBeGCmTpgqyVaeUAXRocqyMInn7Hn9JniXMCXgiH8ai(c5QonOoxsCDkStUm6OHdB87Hn0aBYNhBGeYdG4lK(Y09Pb1bSdfjU0KaMjxgD0WHn(9WgAGn5GniXgo4LYQSuu(kYHowIn(XgecWbwkjeGWm9AtwxjkHTiAuyJaCGLscbimtV2K1vcqoM2hdiSxucBr0VWgbiht7Jbe2laHRw8QJamxSzGL2JpoyuLDyJFpSPFSjFESjxSPn5)LTKUlDjqzsk2GeBGzQeDSeB6l2aZuSXVh2qhSjhSjhSbj2ql2KUCVJcciriDPAeAqDWDc(6uyh2GeBCCDTKiXjlL3grCnnfIn(Xg6iahyPKqa6s1i0G6G7e81PWorjSfrtf2ia5yAFmGWEbiC1IxDeGdS0E8XbJQSdB87Hn9JniXgAXM0L7DuqajcPlvJqdQdUtWxNc7eGdSusiaDPAeAqDWDc(6uyNOe2IGgcBeGCmTpgqyVaeUAXRocqAXM0L7Duqajcz7BGDKK66uyh2GeBGzQeDSeB6l2aZuSXVh2GaBqInoUUwsK4KLYBJiUMMcXg)ydDWgKytUydTyJJRRLejozP8IOpVgtHyJFSHoyt(8ytnpokPJxo0YQKJP9XaytocWbwkjeGTVb2rsQRtHDcWAwkUo9lar1OjaCBY)lrNT7i)RY4dUtWYLrhnCIsylcAIWgbiht7Jbe2laHRw8QJamxSbMPyJFSbb2Kpp20M8)Yws3LUeOmjfBYNhBYfBQ5Xrj5GxkLU0G64NAPUsoM2hdGniXgiH8ai(cjh8sP0Lguh)ul1vUm6OHdBAgBGeYdG4lKF1vUJ8VFYAvUm6OHdBYbBYbBqIn5In5Inqc5bq8fYvDAqDUK46uyNCz0rdh24hBqGniXMCXgAXMAECuYV6QJ8VkJpFzAXxPu8k5yAFma2Kpp2ajKhaXxi)QRoY)Qm(8LPfFLsXRCz0rdh24hBqGn5Gn5ZJnWmfB8JnnfBYbBqIn5Inqc5bq8fYV6k3r(3pzTkxgD0WHn(Xgeyt(8ydmtXg)ytJytoyt(8yt6Y9okiGeHSukEV05HIn5GniXgAXM0L7Duqajcz7BGDKK66uyNaCGLscby7BGDKK66uyNaSMLIRt)cqunAca3M8)s0z7oY)Qm(G7eSCz0rdNOe2IGUlSraYX0(yaH9cq4QfV6ia5(irttzazLXhJMYlzDhCshOwKfBqInTj)VSY4Jrt5LSUdoPdulYkD1a7Wg)EydI(eBqInCWlLvzPO8vKdDSeB8Jn9lahyPKqac3b290G6O5bGVNsLvHguIsylc6MWgbiht7Jbe2laHRw8QJaK7JennLbKvgFmAkVK1DWjDGArwSbj20M8)YkJpgnLxY6o4KoqTiR0vdSdB87HniAk2GeBGeYdG4lKoE5qlRYLrhnCytZydI(XgKytnpokPJxo0YQKJP9XaydsSHdEPSklfLVICOJLyJFSPFb4alLecq4oWUNguhnpa89uQSk0GsucBr0NcBeGCmTpgqyVaeUAXRocqAXM0L7Duqajcz7BGDKK66uyh2GeBGzQeDSeB6l2aZuSXVh2GaBqInoUUwsK4KLYBJiUMMcXg)ydDWgKytBY)lBjDx6sGYKub4alLecW23a7ij11PWobynlfxN(fGOA0eaUn5)LOZ2DK)vz8b3jy5YOJgorjSTr6iSraYX0(yaH9cq4QfV6iaPfBsxU3rbbKiKLsX7LopuSbj2ql2KUCVJcciri5GxkLU0G64NAPUydsSjxSbMPs0XsSPVydmtXg)EytJyt(8ydh8szvwkkFf5qhlXMMXM(XMCeGdSusialLI3lDEOcWAwkUo9lar1OjaCBY)lrNT7i)RY4dUtWYLrhnCIsyBJie2ia5yAFmGWEbiC1IxDeG0InPl37OGaseYsP49sNhk2GeBOfBsxU3rbbKiKCWlLsxAqD8tTuxSbj2WbVuwLLIYxro0XsSPzpSbb2GeBGzQeDSeB6l2aZuSXVh20OaCGLscbyPu8EPZdvawZsX1PFbiQgnbGBt(Fj6SDh5FvgFWDcwUm6OHtucBBSrHncqoM2hdiSxacxT4vhbimtXMM9WM(XgKytUydKqEaeFHCvNguNljUof2jxgD0WHn(9WgAGn5ZJnqc5bq8fsFz6(0G6a2HIexAsaZKlJoA4Wg)EydnWMCWgKydh8szvwkkFf5qhlXg)ydcb4alLecqyME(MESOe22y)cBeGdSusiaHz65B6XcqoM2hdiSxucBBSPcBeGCmTpgqyVaeUAXRocqAXgh)yyPKaBqIn0InPl37OGaseYsP49sNhQaCGLscbyPu8EPZdvacN0sjHauucBBKgcBeGCmTpgqyVaeUAXRocqAXgh)yyPKaBqInPl37OGaseYsP49sNhQaCGLscbiChy3tdQJMha(EkvwfAqjaHtAPKqakkrjaD8YHwwf2iSfHWgbiht7Jbe2laHRw8QJaKwSjD5EhfeqIqwkfVx68qXgKydTyt6Y9okiGeHKdEPu6sdQJFQL6IniXgo4LYk24HnCWlLvj6yj2GeBGzk20m2GaBqIn0InTj)V0XlhAzvMKkahyPKqawkfVx68qfG1SuCD6xaIQrta42K)xIoB3r(xLXhCNGLlJoA4eLW2gf2ia5yAFmGWEb4alLecq48E3alLe3tDLa8PU6IbLfGqarjSTFHncWbwkjeGoE5qlRcqoM2hdiSxucBBQWgbiht7Jbe2laHRw8QJaCGL2JpoyuLDytZyt)cWbwkjeGR60G6CjX1PWobynlfxN(fGOA0eaUn5)LOZ2DK)vz8b3jy5YOJgorjSLgcBeGCmTpgqyVaeUAXRocWCXgAXM0L7Duqajcz7BGDKK66uyh2Kd2GeBYfBsxU3rbbKiKF1vh5FvgF(Y0IVsP4fBYNhBsxU3rbbKiKF1vUJ8VFYAfBYbBqIndS0E8XbJQSdBAgBAuaoWsjHaS9nWossDDkStawZsX1PFbiQgnbGBt(Fj6SDh5FvgFWDcwUm6OHtucBPjcBeGCmTpgqyVauJI3njTeGieGdSusia)QRCh5F)K1QaeUAXRocWCXMCXgUps00ugqcSA0Pb1Lr24GKE8IniXM2K)xMUSZLS8Ls0OKlJoA4WMM9WMgXgKyJJRRLejozP82iDUMMcXg)ydDWMCWgKytUydKqEaeFHCvNguNljUof2jxgD0WHn(Xgeyt(8yZalThFCWOk7Wg)ydcSjhSjhrjSLUlSraYX0(yaH9cqnkE3K0saIqaoWsjHa8RUYDK)9twRcq4QfV6iaZfBYfBOfB4(irttzajWQrNguxgzJds6Xl2Kpp20M8)Y2hHa8sCLmjfBYNhBAt(FPJxo0YQCz0rdh20m2GaBYbBqIn5Inqc5bq8fYvDAqDUK46uyNCz0rdh24hBqGn5ZJndS0E8XbJQSdB8JniWMCWMCeLWw6MWgbiht7Jbe2laHRw8QJaCGL2JpoyuLDyJFpSPFSbj2ql2KUCVJcciriDPAeAqDWDc(6uyNaCGLscbOlvJqdQdUtWxNc7eLW2(uyJaKJP9Xac7fGWvlE1rasl2KUCVJcciri3exMguhnpa85tdaSbj20M8)YnXLPb1rZdaF(0aqcq8fydsSPn5)LoE5qlRYLrhnCyJFpSPPcWbwkjeGBIltdQJMha(8PbGOe2IGocBeGCmTpgqyVaeUAXRocWbwAp(4Grv2Hn(9WM(fGdSusiax1Pb15sIRtHDcWAwkUo9lar1OjaCBY)lrNT7i)RY4dUtWYLrhnCIsylcecBeGCmTpgqyVaeUAXRocqAXM0L7Duqajc5M4Y0G6O5bGpFAaGniXM2K)xUjUmnOoAEa4ZNgasaIVaBqIndS0E8XbJQSdB8JnieGdSusia3exMguhnpa85tdarjSfrJcBeGCmTpgqyVaeUAXRocqAXM0L7DuqajcPlvJqdQdUtWxNc7eGdSusiaDPAeAqDWDc(6uyNOe2IOFHncqoM2hdiSxacxT4vhbiTyt6Y9okiGeHS9nWossDDkStaoWsjHaS9nWossDDkStawZsX1PFbiQgnbGBt(Fj6SDh5FvgFWDcwUm6OHtuIsa6kHncBriSraYX0(yaH9cWbwkjeGW59UbwkjUN6kb4tD1fdklaHaIsyBJcBeGCmTpgqyVaeUAXRocqAXM0L7DuqajczPu8EPZdfBqInWmfBA2dBqGniXMCXgiH8ai(c5QonOoxsCDkStUm6OHdB8Wg6Gn5ZJn5In184OKF1vh5FvgF(Y0IVsP4vYX0(yaSbj2ajKhaXxi)QRoY)Qm(8LPfFLsXRCz0rdh24Hn0bBYbBYNhB4GxkRytZydnOd2KJaCGLscbih8sP0Lguh)ul1vucB7xyJaKJP9Xac7fGWvlE1racZuj6yj20xSbMPyJFpSbb2GeB4GxkRYsr5Rih6yj243dBOJKgcWbwkjeGZcNGVISlhLOe22uHncqoM2hdiSxacxT4vhbiTyt6Y9okiGeHS9nWossDDkSdBqInWmvIowIn9fBGzk243dBqGniXghxxljsCYs5TrexttHyJFSHoydsSPn5)LTKUlDjqzsQaCGLscby7BGDKK66uyNaSMLIRt)cqunAca3M8)s0z7oY)Qm(G7eSCz0rdNOe2sdHncqoM2hdiSxacxT4vhbiTyt6Y9okiGeHSukEV05HIniXgAXM0L7Duqajcjh8sP0Lguh)ul1fBqInCWlLvzPO8vKdDSeBA2dBqGniXgyMkrhlXM(InWmfB87HnnkahyPKqawkfVx68qfG1SuCD6xaIQrta42K)xIoB3r(xLXhCNGLlJoA4eLWwAIWgbiht7Jbe2laHRw8QJaKwSPMhhL0XlhAzvYX0(yaSjFESbsipaIVq64LdTSkxgD0WHn(9Wge0raoWsjHa8RU6i)RY4ZxMw8vkfVIsylDxyJaCGLscbOVmDFAqDa7qrIlnjGzcqoM2hdiSxucBPBcBeGCmTpgqyVaeUAXRocWCXMCXgyMIn(9WM(XgKydh8szfB87HnnLoytoyt(8ydmtXg)EydnWMCWgKytUydTytnpokPJxo0YQKJP9Xayt(8ydKqEaeFH0XlhAzvUm6OHdB87Hn0eSjhb4alLecWvDAqDUK46uyNaSMLIRt)cqunAca3M8)s0z7oY)Qm(G7eSCz0rdNOe22NcBeGCmTpgqyVaeUAXRocWAECushVCOLvjht7JbWgKydTyd3hjAAkdibwn60G6YiBCqspEXgKydKqEaeFH0XlhAzvUm6OHdB87Hn0aBqInCWlLvzPO8vKdDSeB8JnnkahyPKqa(vx5oY)(jRvrjSfbDe2ia5yAFmGWEbiC1IxDeG184OKoE5qlRsoM2hdGniXgUps00ugqcSA0Pb1Lr24GKE8IniXMCXgiH8ai(cPJxo0YQCz0rdh243dBqqdSjFESbsipaIVq64LdTSkxgD0WHnn7HnnfBYbBqInCWlLvzPO8vKdDSeB8JnnkahyPKqa(vx5oY)(jRvrjSfbcHncqoM2hdiSxacxT4vhbiTytnpokPJxo0YQKJP9XaydsSHdEPSklfLVICOJLyJFSPrb4alLecWV6k3r(3pzTkkHTiAuyJaKJP9Xac7fGWvlE1racjKhaXxix1Pb15sIRtHDYLrhnCyJFpSPFjnWgKydmtXMM9WgAiahyPKqa(vx5oY)(jRvrjSfr)cBeGCmTpgqyVaeUAXRocqAXMAECushVCOLvjht7JbWM85XgiH8ai(cPJxo0YQCz0rdh243dBOHaCGLscb4QonOoxsCDkStawZsX1PFbiQgnbGBt(Fj6SDh5FvgFWDcwUm6OHtucBr0uHncqoM2hdiSxacxT4vhbiTyt6Y9okiGeHS9nWossDDkSdBqInWmvIowIn9fBGzk243dBqGniXghxxljsCYs5TrexttHyJFSHoydsSjxSHwSXX11sIeNSuEr0NxJPqSXp2qhSjFESPMhhL0XlhAzvYX0(yaSjhb4alLecW23a7ij11PWobynlfxN(fGOA0eaUn5)LOZ2DK)vz8b3jy5YOJgorjSfbne2ia5yAFmGWEbiC1IxDeG5IndS0E8XbJQSdB87Hn9Jn5ZJn5InTj)VSL0DPlbktsXgKydmtLOJLytFXgyMIn(9Wg6Gn5Gn5GniXgAXM0L7DuqajcPlvJqdQdUtWxNc7WgKyJJRRLejozP82iIRPPqSXp2qhb4alLecqxQgHguhCNGVof2jkHTiOjcBeGCmTpgqyVaeUAXRocqUps00ugqwz8XOP8sw3bN0bQfzXgKytBY)lRm(y0uEjR7Gt6a1ISsxnWoSXVh2GOpXgKydh8szvwkkFf5qhlXg)yt)cWbwkjeGWDGDpnOoAEa47PuzvObLOe2IGUlSraYX0(yaH9cq4QfV6ia5(irttzazLXhJMYlzDhCshOwKfBqInTj)VSY4Jrt5LSUdoPdulYkD1a7Wg)EydIMIniXgiH8ai(cPJxo0YQCz0rdh20m2GOFSbj2uZJJs64LdTSk5yAFma2GeB4GxkRYsr5Rih6yj24hB6xaoWsjHaeUdS7Pb1rZdaFpLkRcnOeLWwe0nHncqoM2hdiSxacxT4vhb4alThFCWOk7Wg)Eyt)ydsSHwSjD5EhfeqIq6s1i0G6G7e81PWob4alLecqxQgHguhCNGVof2jkHTi6tHncqoM2hdiSxacxT4vhbimtLOJLytFXgyMIn(XgeydsSHwSjD5EhfeqIqUjUmnOoAEa4ZNgacWbwkjeGBIltdQJMha(8PbGOe22iDe2ia5yAFmGWEbiC1IxDeG5InWmfB8JniWM85XM2K)x2s6U0LaLjPyt(8ytUytnpokjh8sP0Lguh)ul1vYX0(yaSbj2ajKhaXxi5GxkLU0G64NAPUYLrhnCytZydKqEaeFH8RUYDK)9twRYLrhnCytoytoydsSjxSjxSbsipaIVqUQtdQZLexNc7KlJoA4Wg)ydcSbj2Kl2ql2uZJJs(vxDK)vz85ltl(kLIxjht7JbWM85XgiH8ai(c5xD1r(xLXNVmT4RukELlJoA4Wg)ydcSjhSjFESbMPyJFSPPytoydsSjxSbsipaIVq(vx5oY)(jRv5YOJgoSXp2GaBYNhBGzk24hBAeBYbBYNhBsxU3rbbKiKLsX7LopuSjhSbj2ql2KUCVJcciriBFdSJKuxNc7eGdSusiaBFdSJKuxNc7eG1SuCD6xaIQrta42K)xIoB3r(xLXhCNGLlJoA4eLW2griSraYX0(yaH9cq4QfV6iaHzk20Sh20p2GeBYfBGeYdG4lKR60G6CjX1PWo5YOJgoSXVh2qdSjFESbsipaIVq6lt3NguhWouK4stcyMCz0rdh243dBOb2Kd2GeB4GxkRYsr5Rih6yj24hBqiahyPKqacZ0Z30JfLW2gBuyJaKJP9Xac7fGWvlE1racZuSPzpSPFSbj2Kl2ajKhaXxix1Pb15sIRtHDYLrhnCyJFpSHgyt(8ydKqEaeFH0xMUpnOoGDOiXLMeWm5YOJgoSXVh2qdSjhSbj2WbVuwLLIYxro0XsSXp2GqaoWsjHaeMPxBY6krjSTX(f2ia5yAFmGWEbiC1IxDeG0InPl37OGaseYsP49sNhk2GeBOfBsxU3rbbKiKCWlLsxAqD8tTuxSbj2Kl2aZuj6yj20xSbMPyJFpSPrSjFESHdEPSklfLVICOJLytZyt)ytocWbwkjeGLsX7LopubynlfxN(fGOA0eaUn5)LOZ2DK)vz8b3jy5YOJgorjSTXMkSraoWsjHaeMPNVPhla5yAFmGWErjSTrAiSraoWsjHaeMPxBY6kbiht7Jbe2lkHTnste2ia5yAFmGWEb4alLecWsP49sNhQaeUAXRocqAXgh)yyPKaBqIn0InPl37OGaseYsP49sNhQaeoPLscbOOe22iDxyJaKJP9Xac7fGdSusiaH7a7EAqD08aW3tPYQqdkbiC1IxDeG0Ino(XWsjb2GeBsxU3rbbKiKLsX7LopubiCslLecqrjkbia)NKxjSrylcHncWbwkjeGtsrUPQb2ja5yAFmGWErjSTrHncqoM2hdiSxacxT4vhbynlfxsaUn5)LWXvAqjxEGLaCGLscbOlLN9YMa4C1QDSOe22VWgbOgfV9MNaSpPJamfwxgpVktashjneGdSusialscm7i)RBw0raYX0(yaH9IsyBtf2ia5yAFmGWEbiC1IxDeGTj)V0XlhAzvMKIn5ZJnTj)V0vKf94zRSBcG7RlltsXM85XMCXgAXMAECushVCOLvjht7JbWgKytTA0XLmDjq5qPpTSktsXMCWM85XM2K)x2(ieGxIRKlpWcBYNhBQzP4swkkFf5augBA2dBOj0raoWsjHamLukjeLWwAiSraYX0(yaH9cq4QfV6iaRzP4swkkFf5augBA2dB6tb4alLecWIKaZoY)a4PYeLWwAIWgbiht7Jbe2lahyPKqacN37gyPK4EQReGWvlE1raMl2uZJJs64LdTSk5yAFma2GeBGeYdG4lKoE5qlRYLrhnCytZEydDWMCWM85XM2K)x64LdTSktsfGp1vxmOSa0XlhAzvucBP7cBeGCmTpgqyVaCGLscbiCEVBGLsI7PUsacxT4vhbiTytnpokPJxo0YQKJP9XaydsSjxSPn5)LUISOhpBLDtaCFDzzsk2Kpp2ajKhaXxiDfzrpE2k7Ma4(6Ysy2SuSdB8WMgXMCeGp1vxmOSa0XFrjSLUjSraYX0(yaH9cWbwkjeGW59UbwkjUN6kbiC1IxDeG0In184OKoE5qlRsoM2hdGniXgUps00ugqcSA0Pb1Lr24GKE8IniXMCXgiH8ai(c5xD1r(xLXNVmT4RukELlJoA4WMM9Wge0nSbj2ajKhaXxi)QRCh5F)K1QCz0rdh20Sh2GOrSbj2aZuSXVh20p2GeBGeYdG4lKR60G6CjX1PWo5YOJgoSPzpSbb2Kpp2uZsXLSuu(kYbOm20Sh20inWM85XgiH8ai(czrsGzh5Fa8uzYLrhnCyJFSbbIgXMCWgKydKqEaeFH0vKf94zRSBcG7RllHzZsXoSXdBqiaFQRUyqzbOJ)IsyBFkSraYX0(yaH9cWbwkjeGW59UbwkjUN6kbiC1IxDeG0In184OKoE5qlRsoM2hdGniXgAXgUps00ugqcSA0Pb1Lr24GKE8IniXMCXgiH8ai(c5xD1r(xLXNVmT4RukELlJoA4WMM9WgenfBqInqc5bq8fYV6k3r(3pzTkxgD0WHnn7Hn0eSbj2aZuSXVh20p2GeBGeYdG4lKR60G6CjX1PWo5YOJgoSPzpSbb2Kpp2uZsXLSuu(kYbOm20Sh2GGgyt(8ydKqEaeFHSijWSJ8paEQm5YOJgoSXp2GarJytoydsSbsipaIVq6kYIE8Sv2nbW91LLWSzPyh24HnieGp1vxmOSa0XFrjSfbDe2ia5yAFmGWEb4alLecq48E3alLe3tDLaeUAXRocWbwAp(4Grv2Hn(XM(fGp1vxmOSaCiSOe2IaHWgbiht7Jbe2lahyPKqacN37gyPK4EQReGWvlE1raoWs7XhhmQYoSPzpSPFb4tD1fdklaDLOeLOeG941PKqyBJ0bbDJo0K(PJSr60uAia9nBObLtakatxYxFSaKMcSHMAlzysXaytl)jlJnqcA7uytltPHtIn0ucHCA5WMGe9nBw0FYdBgyPKWHnK4zvIPFGLscNmDzibTDkV)BCDy6hyPKWjtxgsqBNQbp7(ecaM(bwkjCY0LHe02PAWZUjHcLJAkLey6PPaBaJj1LrkSzhfaBAt(FgaBC1uoSPL)KLXgibTDkSPLP0WHntaGnPl33usvAqHnQdBaiblX0pWsjHtMUmKG2ovdE25Ij1LrQZvt5W0pWsjHtMUmKG2ovdE2LskLey6hyPKWjtxgsqBNQbp7Gz61MSUct)alLeoz6YqcA7un4zhmtpFtpgtpMEAkWgAQTKHjfdGnCpETInLIYytLXyZalYInQdBMEJ(M2hlX0pWsjHZBskYnvnWom9dSus4AWZoxkp7LnbW5Qv7yl0VxnlfxsaUn5)LWXvAqjxEGfM(bwkjCn4zxrsGzh5FDZIowOrXBV551N0XIuyDz88Qmp6iPbM(bwkjCn4zxkPusyH(9At(FPJxo0YQmjnF(2K)x6kYIE8Sv2nbW91LLjP5ZNlT184OKoE5qlRsoM2hdGSwn64sMUeOCO0NwwLlpWkN85Bt(Fz7JqaEjUsU8aR85RzP4swkkFf5auUzpAcDW0pWsjHRbp7kscm7i)dGNkZc97vZsXLSuu(kYbOCZE9jM(bwkjCn4zhCEVBGLsI7PUYIyqzphVCOLvl0VxU184OKoE5qlRsoM2hdGesipaIVq64LdTSkxgD0W1ShDYjF(2K)x64LdTSktsX0pWsjHRbp7GZ7DdSusCp1vwedk754Vf63J2AECushVCOLvjht7JbqMBBY)lDfzrpE2k7Ma4(6YYK085HeYdG4lKUISOhpBLDtaCFDzjmBwk251yoy6hyPKW1GNDW59UbwkjUN6klIbL9C83c97rBnpokPJxo0YQKJP9Xai5(irttzajWQrNguxgzJds6XlYCHeYdG4lKF1vh5FvgF(Y0IVsP4vUm6OHRzpe0nKqc5bq8fYV6k3r(3pzTkxgD0W1ShIgrcZu)E9JesipaIVqUQtdQZLexNc7KlJoA4A2dr(81SuCjlfLVICak3SxJ0iFEiH8ai(czrsGzh5Fa8uzYLrhnC(rGOXCqcjKhaXxiDfzrpE2k7Ma4(6Ysy2SuSZdbM(bwkjCn4zhCEVBGLsI7PUYIyqzph)Tq)E0wZJJs64LdTSk5yAFmasA5(irttzajWQrNguxgzJds6XlYCHeYdG4lKF1vh5FvgF(Y0IVsP4vUm6OHRzpenfjKqEaeFH8RUYDK)9twRYLrhnCn7rtqcZu)E9JesipaIVqUQtdQZLexNc7KlJoA4A2dr(81SuCjlfLVICak3ShcAKppKqEaeFHSijWSJ8paEQm5YOJgo)iq0yoiHeYdG4lKUISOhpBLDtaCFDzjmBwk25Hat)alLeUg8SdoV3nWsjX9uxzrmOS3qyl0V3alThFCWOk783pM(bwkjCn4zhCEVBGLsI7PUYIyqzpxzH(9gyP94JdgvzxZE9JPht)alLeo5qyp48E3alLe3tDLfXGYEqam9dSus4KdHBWZoo4LsPlnOo(PwQRf63J20L7DuqajczPu8EPZdfjmtB2dbYCHeYdG4lKR60G6CjX1PWo5YOJgop6KpFU184OKF1vh5FvgF(Y0IVsP4vYX0(yaKqc5bq8fYV6QJ8VkJpFzAXxPu8kxgD0W5rNCYNNdEPS2mnOtoy6hyPKWjhc3GNDZcNGVISlhLf63dMPs0XY(cZu)EiqYbVuwLLIYxro0Xs)E0rsdm9dSus4KdHBWZUV6k3r(3pzTAH(9Q5XrjD8YHwwLCmTpgajTCFKOPPmGey1OtdQlJSXbj94fjKqEaeFH0XlhAzvUm6OHZVhnqYbVuwLLIYxro0Xs)nIPFGLscNCiCdE29vx5oY)(jRvl0VxnpokPJxo0YQKJP9Xai5(irttzajWQrNguxgzJds6XlYCHeYdG4lKoE5qlRYLrhnC(9qqJ85HeYdG4lKoE5qlRYLrhnCn710CqYbVuwLLIYxro0Xs)nIPFGLscNCiCdE29vx5oY)(jRvl0VhT184OKoE5qlRsoM2hdGKdEPSklfLVICOJL(Bet)alLeo5q4g8S7RUYDK)9twRwOFpiH8ai(c5QonOoxsCDkStUm6OHZVx)sAGeMPn7rdm9dSus4KdHBWZoFz6(0G6a2HIexAsaZW0pWsjHtoeUbp7w1Pb15sIRtHDwuZsX1PFpiH8ai(cPVmDFAqDa7qrIlnjGzYLrhnC(9OGaiPnD5EhfeqIqUQtdQZLexNc7qcjKhaXxi)QRCh5F)K1QCz0rdNFkiaM(bwkjCYHWn4z3M4Y0G6O5bGpFAayH(9GzQeDSSVWm1pcK0MUCVJcciri3exMguhnpa85tdam9dSus4KdHBWZoyMETjRRSq)EWmTzV(rMlKqEaeFHCvNguNljUof2jxgD0W53Jg5ZdjKhaXxi9LP7tdQdyhksCPjbmtUm6OHZVhnYbjh8szvwkkFf5qhl9Jat)alLeo5q4g8SdMPxBY6km9dSus4KdHBWZoxQgHguhCNGVof2zH(9YDGL2JpoyuLD(96pF(CBt(FzlP7sxcuMKIeMPs0XY(cZu)E0jNCqsB6Y9okiGeH0LQrOb1b3j4RtHDiDCDTKiXjlL3grCnnfIPFGLscNCiCdE25s1i0G6G7e81PWol0V3alThFCWOk7871psAtxU3rbbKiKUuncnOo4obFDkSdt)alLeo5q4g8SR9nWossDDkSZIAwkUo97HQrta42K)xIoB3r(xLXhCNGLlJoA4Sq)E0MUCVJcciriBFdSJKuxNc7qcZuj6yzFHzQFpeiDCDTKiXjlL3grCnnfImxADCDTKiXjlLxe951ykmF(AECushVCOLvjht7JbYbt)alLeo5q4g8SR9nWossDDkSZIAwkUo97HQrta42K)xIoB3r(xLXhCNGLlJoA4Sq)E5cZu)iYNVn5)LTKUlDjqzsA(85wZJJsYbVukDPb1Xp1sDLCmTpgajKqEaeFHKdEPu6sdQJFQL6kxgD0W1mKqEaeFH8RUYDK)9twRYLrhnC5KdYCZfsipaIVqUQtdQZLexNc7KlJoA48JazU0wZJJs(vxDK)vz85ltl(kLIxjht7JbYNhsipaIVq(vxDK)vz85ltl(kLIx5YOJgo)iYjFEyM6VP5GmxiH8ai(c5xDL7i)7NSwLlJoA48JiFEyM6VXCYNpD5EhfeqIqwkfVx68qZbjTPl37OGaseY23a7ij11PWom9dSus4KdHBWZo4oWUNguhnpa89uQSk0GYc97X9rIMMYaYkJpgnLxY6o4KoqTilY2K)xwz8XOP8sw3bN0bQfzLUAGD(9q0Ni5GxkRYsr5Rih6yP)(X0pWsjHtoeUbp7G7a7EAqD08aW3tPYQqdkl0Vh3hjAAkdiRm(y0uEjR7Gt6a1ISiBt(FzLXhJMYlzDhCshOwKv6Qb253drtrcjKhaXxiD8YHwwLlJoA4Agr)iR5XrjD8YHwwLCmTpgajh8szvwkkFf5qhl93pM(bwkjCYHWn4zx7BGDKK66uyNf1SuCD63dvJMaWTj)VeD2UJ8VkJp4oblxgD0WzH(9OnD5EhfeqIq2(gyhjPUof2HeMPs0XY(cZu)Eiq646AjrItwkVnI4AAkezBY)lBjDx6sGYKum9dSus4KdHBWZUsP49sNhQf1SuCD63dvJMaWTj)VeD2UJ8VkJp4oblxgD0WzH(9OnD5EhfeqIqwkfVx68qrsB6Y9okiGeHKdEPu6sdQJFQL6ImxyMkrhl7lmt971y(8CWlLvzPO8vKdDSS5(Zbt)alLeo5q4g8SRukEV05HArnlfxN(9q1OjaCBY)lrNT7i)RY4dUtWYLrhnCwOFpAtxU3rbbKiKLsX7LopuK0MUCVJcciri5GxkLU0G64NAPUi5GxkRYsr5Rih6yzZEiqcZuj6yzFHzQFVgX0pWsjHtoeUbp7Gz65B6XwOFpyM2Sx)iZfsipaIVqUQtdQZLexNc7KlJoA487rJ85HeYdG4lK(Y09Pb1bSdfjU0KaMjxgD0W53Jg5GKdEPSklfLVICOJL(rGPFGLscNCiCdE2bZ0Z30JX0pWsjHtoeUbp7kLI3lDEOwOFpAD8JHLscK0MUCVJccirilLI3lDEOy6hyPKWjhc3GNDWDGDpnOoAEa47PuzvObLf63Jwh)yyPKaz6Y9okiGeHSukEV05HIPht)alLeojeWtJEKo(SmHJRY4ZxMw8vkfVy6hyPKWjHan4zx7JqaUFYAft)alLeojeObp7A51XBNguy6hyPKWjHan4z3SWj4Ri7YrzH(9GzQeDSSVWm1VhcKCWlLvzPO8vKdDS0VhDK0at)alLeojeObp7Ekvw5oAobGcLJctpM(bwkjCsh)9kLI3lDEOwuZsX1PFpaUn5)LOZ2DK)vz8b3jyjaXxyH(9OnD5EhfeqIqwkfVx68qrsB6Y9okiGeHKdEPu6sdQJFQL6IKdEPS6XbVuwLOJLiHzAZiW0pWsjHt64FdE2nlCc(kYUCuwOFpyMkrhl7lmt97Hajh8szvwkkFf5qhl97rhjnW0pWsjHt64FdE2bN37gyPK4EQRSigu2dcGPFGLscN0X)g8SZvKf94zRSBcG7RlBH(9OTn5)LUISOhpBLDtaCFDzzskM(bwkjCsh)BWZo48E3alLe3tDLfXGYEdHTq)EdS0E8XbJQSZF)y6hyPKWjD8Vbp7GZ7DdSusCp1vwedk75kl0V3alThFCWOk7A2RFm9y6hyPKWjD8YHww9kLI3lDEOwuZsX1PFpunAca3M8)s0z7oY)Qm(G7eSCz0rdNf63J20L7DuqajczPu8EPZdfjTPl37OGaseso4LsPlnOo(PwQlso4LYQhh8szvIowIeMPnJajTTj)V0XlhAzvMKIPFGLscN0XlhAzTbp7GZ7DdSusCp1vwedk7bbW0pWsjHt64LdTS2GNDoE5qlRy6hyPKWjD8YHwwBWZUvDAqDUK46uyNf1SuCD63dvJMaWTj)VeD2UJ8VkJp4oblxgD0WzH(9gyP94JdgvzxZ9JPFGLscN0XlhAzTbp7AFdSJKuxNc7SOMLIRt)EOA0eaUn5)LOZ2DK)vz8b3jy5YOJgol0VxU0MUCVJcciriBFdSJKuxNc7YbzUPl37OGaseYV6QJ8VkJpFzAXxPu8MpF6Y9okiGeH8RUYDK)9twR5GCGL2JpoyuLDn3iM(bwkjCshVCOL1g8S7RUYDK)9twRwOFVCZL7JennLbKaRgDAqDzKnoiPhViBt(Fz6YoxYYxkrJsUm6OHRzVgr646AjrItwkVnsNRPPWCqMlKqEaeFHCvNguNljUof2jxgD0W5hr(8dS0E8XbJQSZpICYXcnkE3K0YdbM(bwkjCshVCOL1g8S7RUYDK)9twRwOFVCZLwUps00ugqcSA0Pb1Lr24GKE8MpFBY)lBFecWlXvYK085Bt(FPJxo0YQCz0rdxZiYbzUqc5bq8fYvDAqDUK46uyNCz0rdNFe5ZpWs7XhhmQYo)iYjhl0O4Dtslpey6hyPKWjD8YHwwBWZoxQgHguhCNGVof2zH(9gyP94JdgvzNFV(rsB6Y9okiGeH0LQrOb1b3j4RtHDy6hyPKWjD8YHwwBWZUnXLPb1rZdaF(0aWc97rB6Y9okiGeHCtCzAqD08aWNpnaq2M8)YnXLPb1rZdaF(0aqcq8fiBt(FPJxo0YQCz0rdNFVMIPFGLscN0XlhAzTbp7w1Pb15sIRtHDwuZsX1PFpunAca3M8)s0z7oY)Qm(G7eSCz0rdNf63BGL2JpoyuLD(96ht)alLeoPJxo0YAdE2TjUmnOoAEa4ZNgawOFpAtxU3rbbKiKBIltdQJMha(8PbaY2K)xUjUmnOoAEa4ZNgasaIVa5alThFCWOk78Jat)alLeoPJxo0YAdE25s1i0G6G7e81PWol0VhTPl37OGasesxQgHguhCNGVof2HPFGLscN0XlhAzTbp7AFdSJKuxNc7SOMLIRt)EOA0eaUn5)LOZ2DK)vz8b3jy5YOJgol0VhTPl37OGaseY23a7ij11PWom9y6hyPKWjD8YHwwpskh86vkfVx68qTOMLIRt)EOA0eaUn5)LOZ2DK)vz8b3jy5YOJgol0VhTPl37OGaseYsP49sNhksAtxU3rbbKiKCWlLsxAqD8tTuxKCWlLvpo4LYQeDSejmtBgbsABt(FPJxo0YQmjfjKqEaeFH8RUYDK)9twRYLrhnCn7rhm9dSus4KoE5qlRhjLdEBWZUzHtWxr2LJYc97bZuj6yzFHzQFpei5GxkRYsr5Rih6yPFp6iPbM(bwkjCshVCOL1JKYbVn4zhCEVBGLsI7PUYIyqzpiGf63dsipaIVq(vx5oY)(jRv5YOJgo)iW0pWsjHt64LdTSEKuo4Tbp7C8YHwwTq)Eqc5bq8fYV6k3r(3pzTkxgD0W5hbM(bwkjCshVCOL1JKYbVn4z3QonOoxsCDkSZIAwkUo97HQrta42K)xIoB3r(xLXhCNGLlJoA4Sq)EdS0E8XbJQSR5(r2M8)shVCOLvzskM(bwkjCshVCOL1JKYbVn4zx7BGDKK66uyNf1SuCD63dvJMaWTj)VeD2UJ8VkJp4oblxgD0WzH(9YL20L7Duqajcz7BGDKK66uyxoiZnD5EhfeqIq(vxDK)vz85ltl(kLI3CW0pWsjHt64LdTSEKuo4Tbp7(QRCh5F)K1Qf63dsipaIVqUQtdQZLexNc7KlJoA48JiF(2K)x64LdTSkbi(cl0O4Dtslpey6hyPKWjD8YHwwpskh82GNDTVb2rsQRtHDwuZsX1PFpunAca3M8)s0z7oY)Qm(G7eSCz0rdNf63Rn5)LoE5qlRsaIVajmtB2RrKqc5bq8fshVCOLv5YOJgUM9OdY0L7DuqajczPu8EPZdft)alLeoPJxo0Y6rs5G3g8SRukEV05HArnlfxN(9q1OjaCBY)lrNT7i)RY4dUtWYLrhnCwOFpAtxU3rbbKiKLsX7LopuK0MUCVJcciri5GxkLU0G64NAPUiHzQhcm9y6hyPKWjDLhCEVBGLsI7PUYIyqzpiaM(bwkjCsx1GNDCWlLsxAqD8tTuxl0VhTPl37OGaseYsP49sNhksyM2ShcK5cjKhaXxix1Pb15sIRtHDYLrhnCE0jF(CR5Xrj)QRoY)Qm(8LPfFLsXRKJP9XaiHeYdG4lKF1vh5FvgF(Y0IVsP4vUm6OHZJo5Kpph8szTzAqNCW0pWsjHt6Qg8SBw4e8vKD5OSq)EWmvIow2xyM63dbso4LYQSuu(kYHow63JosAGPFGLscN0vn4zx7BGDKK66uyNf1SuCD63dvJMaWTj)VeD2UJ8VkJp4oblxgD0WzH(9OnD5EhfeqIq2(gyhjPUof2HeMPs0XY(cZu)Eiq646AjrItwkVnI4AAkezBY)lBjDx6sGYKum9dSus4KUQbp7kLI3lDEOwuZsX1PFpunAca3M8)s0z7oY)Qm(G7eSCz0rdNf63J20L7DuqajczPu8EPZdfjTPl37OGaseso4LsPlnOo(PwQlso4LYQSuu(kYHow2ShcKWmvIow2xyM63Rrm9dSus4KUQbp7(QRoY)Qm(8LPfFLsXRf63J2AECushVCOLvjht7JbYNhsipaIVq64LdTSkxgD0W53dbDW0pWsjHt6Qg8SZxMUpnOoGDOiXLMeWmm9dSus4KUQbp7w1Pb15sIRtHDwuZsX1PFpunAca3M8)s0z7oY)Qm(G7eSCz0rdNf63l3CHzQFV(rYbVuw971u6Kt(8Wm1VhnYbzU0wZJJs64LdTSk5yAFmq(8qc5bq8fshVCOLv5YOJgo)E0KCW0pWsjHt6Qg8S7RUYDK)9twRwOFVAECushVCOLvjht7Jbqsl3hjAAkdibwn60G6YiBCqspErcjKhaXxiD8YHwwLlJoA487rdKCWlLvzPO8vKdDS0FJy6hyPKWjDvdE29vx5oY)(jRvl0VxnpokPJxo0YQKJP9Xai5(irttzajWQrNguxgzJds6XlYCHeYdG4lKoE5qlRYLrhnC(9qqJ85HeYdG4lKoE5qlRYLrhnCn710CqYbVuwLLIYxro0Xs)nIPFGLscN0vn4z3xDL7i)7NSwTq)E0wZJJs64LdTSk5yAFmaso4LYQSuu(kYHow6Vrm9dSus4KUQbp7(QRCh5F)K1Qf63dsipaIVqUQtdQZLexNc7KlJoA4871VKgiHzAZE0at)alLeoPRAWZUvDAqDUK46uyNf1SuCD63dvJMaWTj)VeD2UJ8VkJp4oblxgD0WzH(9OTMhhL0XlhAzvYX0(yG85HeYdG4lKoE5qlRYLrhnC(9ObM(bwkjCsx1GNDTVb2rsQRtHDwuZsX1PFpunAca3M8)s0z7oY)Qm(G7eSCz0rdNf63J20L7Duqajcz7BGDKK66uyhsyMkrhl7lmt97HaPJRRLejozP82iIRPPqK5sRJRRLejozP8IOpVgtH5ZxZJJs64LdTSk5yAFmqoy6hyPKWjDvdE25s1i0G6G7e81PWol0VxUdS0E8XbJQSZVx)5ZNBBY)lBjDx6sGYKuKWmvIow2xyM63Jo5KdsAtxU3rbbKiKUuncnOo4obFDkSdPJRRLejozP82iIRPPqm9dSus4KUQbp7G7a7EAqD08aW3tPYQqdkl0Vh3hjAAkdiRm(y0uEjR7Gt6a1ISiBt(FzLXhJMYlzDhCshOwKv6Qb253drFIKdEPSklfLVICOJL(7ht)alLeoPRAWZo4oWUNguhnpa89uQSk0GYc97X9rIMMYaYkJpgnLxY6o4KoqTilY2K)xwz8XOP8sw3bN0bQfzLUAGD(9q0uKqc5bq8fshVCOLv5YOJgUMr0pYAECushVCOLvjht7JbqYbVuwLLIYxro0Xs)9JPFGLscN0vn4zNlvJqdQdUtWxNc7Sq)EdS0E8XbJQSZVx)iPnD5EhfeqIq6s1i0G6G7e81PWom9dSus4KUQbp72exMguhnpa85tdal0VhmtLOJL9fMP(rGK20L7Duqajc5M4Y0G6O5bGpFAaGPFGLscN0vn4zx7BGDKK66uyNf1SuCD63dvJMaWTj)VeD2UJ8VkJp4oblxgD0WzH(9YfMP(rKpFBY)lBjDx6sGYK085ZTMhhLKdEPu6sdQJFQL6k5yAFmasiH8ai(cjh8sP0Lguh)ul1vUm6OHRziH8ai(c5xDL7i)7NSwLlJoA4YjhK5MlKqEaeFHCvNguNljUof2jxgD0W5hbYCPTMhhL8RU6i)RY4ZxMw8vkfVsoM2hdKppKqEaeFH8RU6i)RY4ZxMw8vkfVYLrhnC(rKt(8Wm1FtZbzUqc5bq8fYV6k3r(3pzTkxgD0W5hr(8Wm1FJ5KpF6Y9okiGeHSukEV05HMdsAtxU3rbbKiKTVb2rsQRtHDy6hyPKWjDvdE2bZ0Z30JTq)EWmTzV(rMlKqEaeFHCvNguNljUof2jxgD0W53Jg5ZdjKhaXxi9LP7tdQdyhksCPjbmtUm6OHZVhnYbjh8szvwkkFf5qhl9Jat)alLeoPRAWZoyMETjRRSq)EWmTzV(rMlKqEaeFHCvNguNljUof2jxgD0W53Jg5ZdjKhaXxi9LP7tdQdyhksCPjbmtUm6OHZVhnYbjh8szvwkkFf5qhl9Jat)alLeoPRAWZUsP49sNhQf1SuCD63dvJMaWTj)VeD2UJ8VkJp4oblxgD0WzH(9OnD5EhfeqIqwkfVx68qrsB6Y9okiGeHKdEPu6sdQJFQL6ImxyMkrhl7lmt971y(8CWlLvzPO8vKdDSS5(Zbt)alLeoPRAWZoyME(MEmM(bwkjCsx1GNDWm9AtwxHPFGLscN0vn4zxPu8EPZd1c97rRJFmSusGK20L7DuqajczPu8EPZdft)alLeoPRAWZo4oWUNguhnpa89uQSk0GYc97rRJFmSusGmD5EhfeqIqwkfVx68qfGtsLrwbinv5o9PIsucba]] )
end