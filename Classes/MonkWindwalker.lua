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

    spec:RegisterPack( "Windwalker", 20180820.1924, 
        [[d40SPbqiKspcc6siqLAtivFcPOmkiuNcc5vQkmlb4wiGDjLFjenmHqhdswMujpdHyAQkQRHuyBQksFdbkJdPO6CsLkRtvrmpiW9KQ2hKYbLkvTqbYdfqMOuP4IifzJiK8res1irGkojcujRuQ4LiKYmfqf3uavYorO(PaQAOiqSuHGEkIMkc6QcOs9veOQZIaP9sYFjmyrhwLfRu9yOMSQCzuBMu(msgTqDAQwTqGxdrZwj3wq7wXVbnCLYXfqz5apNOPl56KQTRQ03fsJxG68QQwVuP08HuTFkRqPiur(UIve3verrZJinVRi2q1DD95UqPiR)nwrUDyKhfRiNlKvKe8(8IElKmqrUD)l49ueQiLqDaMvKXvTj)KiJKYRy99ggggP0d1xx5WbdoTksPhIJCFb3JCx7iWJ)g5gaQ5lwgjbbWr45pzKeKiue4coife8(8IElKmOj9qSICx3xfbxJAxr(UIve3verrZJinVRi2qrZPbbJgDPiLBmwrCxFA3PiFSeRijm2Lw6slRy2YhRD6RYscEFErVfsgy5HlhowUDyKwQbbwg0v1ITudcSS77wgaR4M1X6e4YhiWY7fb6YkKNsAzugWwgEp2snam0YkMTK0d1xx5WjqGtRSS7jibowU8bj)SeowwXSLBaOMVylRBVzDSobk(gk(zzDakUeUMLy488YHZTKwwqlX)4flQdqXL0sexhGIlHRzPlTCGLLs9TniO4hIAwhRtGIVHIFwgOBTSS7XLdhldCCzzjpfWzPLAqGLDFGNMS8MNLKeAzbTmc1hl7EC5WXYahxwwk9bZwwX8VLhGTmuV0V163soy8sx6F5M1X609Vh)SC)WijG(MLagddd55DLdhPLAqGLe6umWscYTcTmAmpwoWk2hkl5LKTm6jTeWyyyipp(zjbiGLvSlTmQVwwQl1V163YD2Yat3Xix)eaWFDPx8ZYtAPxw6sl3aW9BF9B5zjHeeldDPSPixUSKkcvK4NIqfXOueQipC5Wrr6ZxisweSopksEU9f)ubPkfXDPiurYZTV4Nkif5CHSICPllauxkOGRhpITLE4rXkYdxoCuK6sw4fhQkfXerrOI8WLdhf5(ccFcnDWVIKNBFXpvqQsr8NveQipC5WrrUZajdq6dLIKNBFXpvqQsrmnueQi552x8tfKIed8Ib(PiXXEl8c2scyjo2TeTElrzjDl5Hbu)TYdzrbfHxWwIwVLrSrdf5HlhokYdGVHffea4PuLI4pvrOI8WLdhf5YPIlPic0FuH8uksEU9f)ubPkfXemfHkYdxoCuKAoG3xq4trYZTV4NkivPiMMRiurE4YHJI8gmllWTe4BTuK8C7l(PcsvkI7ofHksEU9f)ubPipC5WrrwqDCSaQjE8vXksmWlg4NIKdmDFBJFTy)94reEYIbsHgeS7VhpIcQJJTKUL0A5gG)kOWVgQwb1XXcOM4XxfRiX)4flQdqXLurmkvPigveveQi552x8tfKI8WLdhfzb1XXcOM4XxfRiXaVyGFkseBjITSUfpvtYaE86VXZTV4NL0TedHRhm60KmGhV(Bao88rAjc6TeLLiYs6wIHW1dgDAAUSKcOMqth83aC45J0se0B5NTerws3smeUEWOtd4sFOes9rG0XiBao88rAjcSKGzjDlP1Yna)vqHFnuTcQJJfqnXJVkwrI)XlwuhGIlPIyuQsrmkukcvK8C7l(PcsrE4YHJISG64ybut84RIvKyGxmWpfjITeXwsRL1T4PAsgWJx)nEU9f)SKULyiC9GrNMSGGqbFGkwCZtO5aUb4WZhPLiO3suwIilrhDlXXULO1BzxwIilPBjgcxpy0PP5YskGAcnDWFdWHNpslrqVLF2s6wIHW1dgDAax6dLqQpcKogzdWHNpslrGLemlPBjTwUb4Vck8RHQvqDCSaQjE8vXks8pEXI6auCjveJsvQsr(yTtFvkcveJsrOI8WLdhf5PxqXv1HrQi552x8tfKQue3LIqf5Hlhoks5gFar8npHSaoswrYZTV4NkivPiMikcvK8C7l(PcsrIbEXa)uK0AzDlEQgrhcFcI2bcVgp3(IFksFkg89wkYUlIkYnCjI5BvXkYi2OHI8WLdhfzb1XXcOMa5bcpvPi(ZkcvK(um47TuKDxevKB4seZ3QIvKOArurE4YHJISG64ybutG8aHNIKNBFXpvqQsrmnueQi552x8tfKIed8Ib(Pi3110AsgWJx)n9nlrhDl3110AYcccf8bQyXnpHMd4M(MLOJULi2sATSUfpvtYaE86VXZTV4NL0TSa(GKR2gaIBhLV86Vb4dxwIilrhDl3110A7li8T0LvdWhUSeD0TSoafxTYdzrbfpNTeb9w(PrurE4YHJICdwoCuLI4pvrOIKNBFXpvqksmWlg4NISoafxTYdzrbfpNTeb9w2DkYdxoCuKfuhhlGAIhFvSQuetWueQi552x8tfKIed8Ib(PirSL1T4PAsgWJx)nEU9f)SKULyiC9GrNMKb841FdWHNpslrqVLr0sezj6OB5UUMwtYaE86VPVPipC5WrrIV1sC4YHJy5YsrUCzjMlKvKsgWJx)QsrmnxrOIKNBFXpvqksmWlg4NIKwlRBXt1KmGhV(B8C7l(zjDlrSL76AAnzbbHc(avS4MNqZbCtFZs0r3smeUEWOttwqqOGpqflU5j0Ca3WXhGILw2BzxwIif5Hlhoks8TwIdxoCelxwkYLllXCHSIuYAQsrC3PiurYZTV4Nkifjg4fd8trIylP1Y6w8unjd4XR)gp3(IFws3smeUEWOttZLLua1eA6G)gGdpFKwIGElr1LL0Teh7wIwVLeXs6wIHW1dgDAax6dLqQpcKogzdWHNpslrqVLOSerwIo6wwhGIRw5HSOGINZwIGEl7IgwIo6wIHW1dgDAfuhhlGAIhFvCdWHNpslrZsuO6srE4YHJIeFRL4WLdhXYLLIC5YsmxiRiLSMQueJkIkcvK8C7l(PcsrIbEXa)uKi2sATSUfpvtYaE86VXZTV4NL0TKwl5at3324x7b8bPpuIyiyey4xgyjDlXq46bJonnxwsbutOPd(Bao88rAjc6T8tTKUL4y3s06TKiws3smeUEWOtd4sFOes9rG0XiBao88rAjc6TeLLiYs0r3Y6auC1kpKffu8C2se0BjkAyj6OBjgcxpy0PvqDCSaQjE8vXnahE(iTenlrHQllPBjgcxpy0PjliiuWhOIf38eAoGB44dqXsl7TeLI8WLdhfj(wlXHlhoILllf5YLLyUqwrkznvPigfkfHksEU9f)ubPiXaVyGFkseBjTww3INQjzapE93452x8Zs6wIHW1dgDAAUSKcOMqth83aC45J0se0BjQUSKUL4y3s06TKiws3smeUEWOtd4sFOes9rG0XiBao88rAjc6TeLLiYs0r3Y6auC1kpKffu8C2se0Bzx0Ws0r3smeUEWOtRG64ybut84RIBao88rAjAwIcvxws3smeUEWOttwqqOGpqflU5j0Ca3WXhGILw2Bjkf5Hlhoks8TwIdxoCelxwkYLllXCHSIuYAQsrmQUueQi552x8tfKIed8Ib(PipC5FzbpCOZslrZsIOipC5Wrrc0hXHlhoILllf5YLLyUqwrEqwvkIrrefHksEU9f)ubPiXaVyGFkYdx(xwWdh6S0se0BjruKhUC4Oib6J4WLdhXYLLIC5YsmxiRiLLQuLICdWyy4(vkcveJsrOIKNBFXpvqQsrCxkcvK8C7l(PcsvkIjIIqfjp3(IFQGuLI4pRiurYZTV4NkivPiMgkcvKhUC4Oi3GLdhfjp3(IFQGuLI4pvrOI8WLdhfjo2f76azPi552x8tfKQuetWueQipC5WrrIJDr07lRi552x8tfKQuLIuYaE86xrOIyukcvK8C7l(PcsrIbEXa)uK76AAT9fe(w6YQPVzjDlP1YDDnTMKb841FtFtrE4YHJIuZLLaQjQywen2lwuofduLI4UueQi552x8tfKI8WLdhfz5umqSDRqfjg4fd8trsRLBa(RGc)AOALtXaX2TcTKUL0A5gG)kOWVgQgpmGY7wFOe8Yd2bws3sEya1VL9wYddO(BHxWws3sCSBjcSeLL0TKwl3110AsgWJx)n9nfj(hVyrDakUKkIrPkfXerrOIKNBFXpvqkYdxoCuK4BTehUC4iwUSuKlxwI5czfj(PkfXFwrOIKNBFXpvqksmWlg4NISUfpvdOlJ9Hseb3Jfr951452x8Zs6wsRLBa(RGc)AOAaDzSpuIi4ESiQpplPB5UUMwdOlJ9Hseb3Jfr951EWOJI8WLdhfjqxg7dLicUhlI6ZtvkIPHIqf5Hlhoksjd4XRFfjp3(IFQGuLI4pvrOIKNBFXpvqkYdxoCuKax6dLqQpcKogPIe)JxSOoafxsfXOuLIycMIqfjp3(IFQGuKyGxmWpf5gG)kOWVgQgWL(qjK6JaPJrAjDl3a8xbf(16QjzapE9RipC5WrrQ5YskGAcnDWVQuetZveQi552x8tfKI8WLdhfjWL(qjK6JaPJrQiX)4flQdqXLurmkvPiU7ueQi552x8tfKI8WLdhf5(6WiH6LaPJrQiXaVyGFksATCdWFfu4xdvBFDyKq9sG0XiTKULyiC9GrNgWL(qjK6JaPJr2aC45J0s06TSllPBjgcxpy0PP5YskGAcnDWFdWHNpslrR3YUuK4F8If1bO4sQigLQueJkIkcvK8C7l(PcsrE4YHJIuZLLua1eA6GFfjg4fd8trIylrSL0Ajhy6(2g)ApGpi9HsedbJad)YalrhDl3110A7li8T0LvtFZs0r3YDDnTMKb841FdWHNpslrGLOSerws3seBjgcxpy0PbCPpucP(iq6yKnahE(iTenlrzj6OB5Hl)ll4HdDwAjAwIYsezjIuK(umaOVvksuQsrmkukcvK8C7l(PcsrIbEXa)uKhU8VSGho0zPLO1BjrSKUL0A5gG)kOWVgQMCZNXhkbgCdlq6yKkYdxoCuKYnFgFOeyWnSaPJrQkfXO6srOIKNBFXpvqkYdxoCuKax6dLqQpcKogPIed8Ib(PipC5FzbpCOZslrR3sIOiX)4flQdqXLurmkvPigfrueQi552x8tfKIed8Ib(PiP1Yna)vqHFnun5MpJpucm4gwG0XivKhUC4OiLB(m(qjWGBybshJuvkIr9zfHksEU9f)ubPipC5WrrUVomsOEjq6yKksmWlg4NIKwl3a8xbf(1q12xhgjuVeiDmsfj(hVyrDakUKkIrPkvPiLSMIqfXOueQi552x8tfKI8WLdhfz5umqSDRqfjg4fd8trsRLBa(RGc)AOALtXaX2TcTKUL0A5gG)kOWVgQgpmGY7wFOe8Yd2bws3sEya1VL9wYddO(BHxWws3sCSBjcSeLIe)JxSOoafxsfXOuLI4UueQi552x8tfKI8WLdhfj(wlXHlhoILllf5YLLyUqwrIFQsrmrueQi552x8tfKIed8Ib(PiP1YDDnTMSGGqbFGkwCZtO5aUPVPipC5WrrkliiuWhOIf38eAoGvLQuKYsrOIyukcvKhUC4Oi95lejlcwNhfjp3(IFQGuLI4UueQi552x8tfKIed8Ib(PiP1YDDnTMSGGqbFGkwCZtO5aUPVPipC5WrrkliiuWhOIf38eAoGvLIyIOiurYZTV4Nkifjg4fd8trURRP1a6YyFOerW9yruFEThm6yjDlP1Yna)vqHFnunGUm2hkreCpwe1NNI8WLdhfjqxg7dLicUhlI6ZtvkI)SIqfjp3(IFQGuKyGxmWpfjTwUb4Vck8RHQvofdeB3kurE4YHJIKhgq5DRpucE5b7avPiMgkcvK8C7l(PcsrE4YHJICFDyKq9sG0XivKyGxmWpfjTwUb4Vck8RHQTVomsOEjq6yKws3sCS3cVGTKawIJDlrR3suws3sjxID4OlBLZGUqj(8g2s6wURRP12HifBaiUPVPiX)4flQdqXLurmkvPi(tveQi552x8tfKI8WLdhfz5umqSDRqfjg4fd8trsRLBa(RGc)AOALtXaX2TcTKUL0A5gG)kOWVgQgpmGY7wFOe8Yd2bws3sEya1FR8qwuqr4fSLiO3suws3sCS3cVGTKawIJDlrR3YUSKUL0A5UUMwtYaE86VPVPiX)4flQdqXLurmkvPiMGPiurYZTV4Nkifjg4fd8trIJ9w4fSLeWsCSBjA9wsef5HlhoksnxwcOMOIzr0yVyr5umqvkIP5kcvKhUC4OiJg7GLpuIh4OGJytFWXksEU9f)ubPkfXDNIqfjp3(IFQGuKhUC4OibU0hkHuFeiDmsfjg4fd8trIylrSL4y3s06TKiws3sEya1VLO1B5NJOLiYs0r3sCSBjA9wsdlrKL0TeXww3INQjzapE93452x8Zs0r3smeUEWOttYaE86Vb4WZhPLO1B5NAjIuK4F8If1bO4sQigLQueJkIkcvK8C7l(PcsrIbEXa)uK1T4PAsgWJx)nEU9f)SKUL0Ajhy6(2g)ApGpi9HsedbJad)YalPBjgcxpy0PjzapE93aC45J0s06TKgws3sEya1FR8qwuqr4fSLOzzxkYdxoCuKAUSKcOMqth8RkfXOqPiurYZTV4Nkifjg4fd8trw3INQjzapE93452x8Zs6wYbMUVTXV2d4dsFOeXqWiWWVmWs6wIylXq46bJonjd4XR)gGdpFKwIwVLOOHLOJULyiC9GrNMKb841FdWHNpslrqVLF2sezjDl5Hbu)TYdzrbfHxWwIMLDPipC5WrrQ5YskGAcnDWVQueJQlfHksEU9f)ubPiXaVyGFksATSUfpvtYaE86VXZTV4NI8WLdhfPMllPaQj00b)QsrmkIOiurYZTV4Nkif5HlhoksGl9Hsi1hbshJurIbEXa)uKyiC9GrNMKb841FdWHNpslrR3sAyj6OBjITKwlRBXt1KmGhV(B8C7l(zjIuK4F8If1bO4sQigLQueJ6ZkcvK8C7l(PcsrE4YHJICFDyKq9sG0XivKyGxmWpfjTwUb4Vck8RHQTVomsOEjq6yKws3sCS3cVGTKawIJDlrR3suks8pEXI6auCjveJsvkIrrdfHksEU9f)ubPiXaVyGFksoW09Tn(1QywWHBmacKc8TDyVGalPB5UUMwRIzbhUXaiqkW32H9ccAY6WiTeTElr1Dws3sEya1FR8qwuqr4fSLOzjruKhUC4OiXGdJC5dLicUhlwovCn(qPkfXO(ufHksEU9f)ubPiXaVyGFksoW09Tn(1QywWHBmacKc8TDyVGalPB5UUMwRIzbhUXaiqkW32H9ccAY6WiTeTElr9zlPBjgcxpy0PjzapE93aC45J0seyjkIyjDlRBXt1KmGhV(B8C7l(zjDl5Hbu)TYdzrbfHxWwIMLerrE4YHJIedomYLpuIi4ESy5uX14dLQueJIGPiurYZTV4Nkifjg4fd8trsRLBa(RGc)AOA7RdJeQxcKogPI8WLdhf5(6WiH6LaPJrQkfXOO5kcvKhUC4OiXXUi69LvK8C7l(PcsvkIr1DkcvK8C7l(PcsrIbEXa)uK8WaQ)w5HSOGIWlylrZsuws3Y6w8unjd4XR)gp3(IFkYdxoCuK4yxSRdKLQue3veveQi552x8tfKI8WLdhfz5umqSDRqfjg4fd8trsRLBa(RGc)AOALtXaX2TcTKUL0A5gG)kOWVgQgpmGY7wFOe8Yd2bws3seBjo2BHxWwsalXXULO1BzxwIo6wYddO(BLhYIckcVGTebwselrKL0TKwl3110AsgWJx)n9nfj(hVyrDakUKkIrPkfXDHsrOIKNBFXpvqksmWlg4NIeh7TWlyljGL4y3s06TKiws3sEya1FR8qwuqr4fSLOzjklPBjTww3INQjzapE93452x8trE4YHJIeh7IDDGSuLI4U6srOIKNBFXpvqksmWlg4NICdWFfu4xdvRCkgi2UvOL0TKwlL8IXLdhf5HlhokYYPyGy7wHQsvkYdYkcveJsrOIKNBFXpvqkYdxoCuK4BTehUC4iwUSuKlxwI5czfj(PkfXDPiurYZTV4Nkifjg4fd8trsRLBa(RGc)AOALtXaX2TcTKUL4y3se0BjklPBjITedHRhm60aU0hkHuFeiDmYgGdpFKw2BzeTeD0TeXww3INQP5Ysa1evmlIg7flkNIbnEU9f)SKULyiC9GrNMMllbutuXSiASxSOCkg0aC45J0YElJOLiYs0r3sEya1VLiWsAerlrKI8WLdhfjpmGY7wFOe8Yd2bQsrmrueQi552x8tfKIed8Ib(PiXXEl8c2scyjo2TeTElrzjDl5Hbu)TYdzrbfHxWwIwVLrSrdf5HlhokYdGVHffea4PuLI4pRiurYZTV4Nkifjg4fd8trw3INQjzapE93452x8Zs6wsRLCGP7BB8R9a(G0hkrmemcm8ldSKULyiC9GrNMKb841FdWHNpslrR3sAyjDl5Hbu)TYdzrbfHxWwIMLDPipC5WrrQ5YskGAcnDWVQuetdfHksEU9f)ubPiXaVyGFkY6w8unjd4XR)gp3(IFws3soW09Tn(1EaFq6dLigcgbg(Lbws3seBjgcxpy0PjzapE93aC45J0s06TefnSeD0TedHRhm60KmGhV(Bao88rAjc6T8ZwIilPBjpmG6VvEilkOi8c2s0SSlf5HlhoksnxwsbutOPd(vLI4pvrOIKNBFXpvqksmWlg4NIKwlRBXt1KmGhV(B8C7l(zjDl5Hbu)TYdzrbfHxWwIMLDPipC5WrrQ5YskGAcnDWVQuetWueQi552x8tfKIed8Ib(PiXq46bJonGl9Hsi1hbshJSb4WZhPLO1BjrA0Ws6wIJDlrqVL0qrE4YHJIuZLLua1eA6GFvPiMMRiurE4YHJImASdw(qjEGJcoIn9bhRi552x8tfKQue3DkcvK8C7l(PcsrIbEXa)uKyiC9GrNw0yhS8Hs8ahfCeB6doUb4WZhPLO1Bjf(zjDlP1Yna)vqHFnunGl9Hsi1hbshJ0s6wIHW1dgDAAUSKcOMqth83aC45J0s0SKc)uKhUC4OibU0hkHuFeiDmsvPigveveQi552x8tfKIed8Ib(PiXXULiO3sIyjDlrSLyiC9GrNgWL(qjK6JaPJr2aC45J0s06TKgwIo6wIHW1dgDArJDWYhkXdCuWrSPp44gGdpFKwIwVL0WsezjDl5Hbu)TYdzrbfHxWwIMLOuKhUC4OiXXUyxhilvPigfkfHkYdxoCuK4yxSRdKLIKNBFXpvqQsrmQUueQi552x8tfKIed8Ib(PirSLhU8VSGho0zPLO1BjrSeD0TeXwURRP12HifBaiUPVzjDlXXEl8c2scyjo2TeTElJOLiYsezjDlP1Yna)vqHFnun5MpJpucm4gwG0XiTKULsUe7Wrx2kNbDHs85nSI8WLdhfPCZNXhkbgCdlq6yKQsrmkIOiurYZTV4Nkifjg4fd8trE4Y)YcE4qNLwIwVLeXs6wsRLBa(RGc)AOAYnFgFOeyWnSaPJrQipC5Wrrk38z8HsGb3WcKogPQueJ6ZkcvK8C7l(PcsrE4YHJICFDyKq9sG0XivKyGxmWpfjTwUb4Vck8RHQTVomsOEjq6yKws3sCS3cVGTKawIJDlrR3suws3sjxID4OlBLZGUqj(8g2s6wIylP1sjxID4OlBLZauDNORnSLOJUL1T4PAsgWJx)nEU9f)Serks8pEXI6auCjveJsvkIrrdfHksEU9f)ubPipC5WrrUVomsOEjq6yKksmWlg4NIeXwIJDlrZsuwIo6wURRP12HifBaiUPVzj6OBjITSUfpvJhgq5DRpucE5b7Ggp3(IFws3smeUEWOtJhgq5DRpucE5b7GgGdpFKwIalXq46bJonnxwsbutOPd(Bao88rAjISerws3seBjITedHRhm60aU0hkHuFeiDmYgGdpFKwIMLOSKULi2sATSUfpvtZLLaQjQywen2lwuofdA8C7l(zj6OBjgcxpy0PP5Ysa1evmlIg7flkNIbnahE(iTenlrzjISeD0Teh7wIMLF2sezjDlrSLyiC9GrNMMllPaQj00b)nahE(iTenlrzj6OBjo2Tenl7Ysezj6OB5gG)kOWVgQw5umqSDRqlrKL0TKwl3a8xbf(1q12xhgjuVeiDmsfj(hVyrDakUKkIrPkfXO(ufHksEU9f)ubPiXaVyGFksoW09Tn(1QywWHBmacKc8TDyVGalPB5UUMwRIzbhUXaiqkW32H9ccAY6WiTeTElr1Dws3sEya1FR8qwuqr4fSLOzjruKhUC4OiXGdJC5dLicUhlwovCn(qPkfXOiykcvK8C7l(PcsrIbEXa)uKCGP7BB8RvXSGd3yaeif4B7WEbbws3YDDnTwfZcoCJbqGuGVTd7fe0K1HrAjA9wI6Zws3smeUEWOttYaE86Vb4WZhPLiWsueXs6ww3INQjzapE93452x8Zs6wYddO(BLhYIckcVGTenljII8WLdhfjgCyKlFOerW9yXYPIRXhkvPigfnxrOIKNBFXpvqkYdxoCuK7RdJeQxcKogPIed8Ib(PiP1Yna)vqHFnuT91Hrc1lbshJ0s6wIJ9w4fSLeWsCSBjA9wIYs6wk5sSdhDzRCg0fkXN3Wws3YDDnT2oePydaXn9nfj(hVyrDakUKkIrPkfXO6ofHksEU9f)ubPipC5WrrwofdeB3kurIbEXa)uK0A5gG)kOWVgQw5umqSDRqlPBjTwUb4Vck8RHQXddO8U1hkbV8GDGL0TeXwIJ9w4fSLeWsCSBjA9w2LLOJUL8WaQ)w5HSOGIWlylrGLeXsePiX)4flQdqXLurmkvPiURiQiurYZTV4Nkif5HlhokYYPyGy7wHksmWlg4NIKwl3a8xbf(1q1kNIbITBfAjDlP1Yna)vqHFnunEyaL3T(qj4LhSdSKUL8WaQ)w5HSOGIWlylrqVLOSKUL4yVfEbBjbSeh7wIwVLDPiX)4flQdqXLurmkvPiUlukcvK8C7l(PcsrIbEXa)uK4y3se0BjrSKULi2smeUEWOtd4sFOes9rG0XiBao88rAjA9wsdlrhDlXq46bJoTOXoy5dL4bok4i20hCCdWHNpslrR3sAyjISKUL8WaQ)w5HSOGIWlylrZsukYdxoCuK4yxe9(YQsrCxDPiurE4YHJIeh7IO3xwrYZTV4NkivPiUlIOiurYZTV4Nkifjg4fd8trUb4Vck8RHQvofdeB3k0s6wsRLsEX4YHJI8WLdhfz5umqSDRqvPkvPi)YaPdhfXDfru08isZrrJgkcgkAOiJEGXhkPIKGV7JqIj4IyI(NyPLegZw6HBqqzPgeyjn7XAN(QOzwc4at3b8ZsjmKT80ly4v8ZsC8nuSSzDcC8HTe1NyzG7rQVTbbf)S8WLdhlPzNEbfxvhgjnRzDSoeCfUbbf)SKGz5HlhowUCzjBwhf5gaQ5lwrIqlPPGzSEXpl3zniGTedd3VYYDMYhzZYUhJ5TsA5ahceFGqn9LLhUC4iTeoR)M15WLdhzBdWyy4(v9ARtI06C4YHJSTbymmC)Qp6JudcFwNdxoCKTnaJHH7x9rFKNovip1voCSoi0sY52KXWYsW5pl31104NLY6kPL7SgeWwIHH7xz5ot5J0YBEwUbycSbRYhklDPLp4WnRZHlhoY2gGXWW9R(Ops5CBYyyjK1vsRZHlhoY2gGXWW9R(OpYny5WX6C4YHJSTbymmC)Qp6Jeh7IDDGSSohUC4iBBagdd3V6J(iXXUi69LTowheAjnfmJ1l(zj)Lb)wwEiBzfZwE4ccS0LwEFpFD7lUzDoC5Wr2F6fuCvDyKwNdxoCKF0hPCJpGi(MNqwahjBDqOLec1XXwc1SKODGWZs4yjgcxpy0jalDnlj6q4ZsI2bcplDPL8C7l(zjhy63YYcAjQigrcUTeQzz4fShQhAzmFRk26C4YHJ8J(ilOoowa1eipq4fGpfd(ER(UlIbSHlrmFRkUpInAeGR1tBDlEQgrhcFcI2bcVgp3(IFb4tXGV3QV7IyaB4seZ3QI7JyJgwNdxoCKF0hzb1XXcOMa5bcVa8PyW3B13DrmGnCjI5BvX9OAr06GqljiWYHJLUMLKmGhV(TecSKSGGWaSKMoqfhGL38SKOCaB5byl13SecS8hQB5bylb6Z4dLLsgWJx)wEZZYZYWZhlL1vwwaFqYLLBaiwgGLqGL)qDlpaBP(8yGLvmBjRPX4YsOML7li8T0LvawcbwwhGIlllpKTSGw(C2sxAjfGVIbwcbwYbM(TSSGw(Pr06C4YHJ8J(i3GLdNaCT(DDnTMKb841FtFdD03110AYcccf8bQyXnpHMd4M(g6OJyARBXt1KmGhV(B8C7l(rVa(GKR2gaIBhLV86Vb4dxicD03110A7li8T0LvdWhUqh96auC1kpKffu8Cgb9FAeTohUC4i)OpYcQJJfqnXJVkoaxRVoafxTYdzrbfpNrqF3zDqOLb6wllRy2ssgWJx)wE4YHJLlxww6Aw(d1Pza2sDPpuwsYaE863YBEwsYaE863sxA59981TVylrmey5puNMbylX6aap163sFSKKb841pISohUC4i)Ops8TwIdxoCelxwbmxi3lzapE9hGR1J46w8unjd4XR)gp3(IF0Xq46bJonjd4XR)gGdpFKiOpIicD03110AsgWJx)n9nRdcTmq3AzzfZwssteLLhUC4y5YLLLUML)qDAgGTux6dLLK0erz5nplpaBjwha4Pw)w6JLK0erzjeyz89LTSlljPjIYszDyKsRZHlhoYp6JeFRL4WLdhXYLvaZfY9swlaxRN26w8unjd4XR)gp3(IF0r8UUMwtwqqOGpqflU5j0Ca303qhDmeUEWOttwqqOGpqflU5j0Ca3WXhGIL9DHiRdcTmq3AzzfZwssteLLhUC4y5YLLLUML)qDAgGTCGLL6sFOSKKb841VL38(eRdcTKawsuqIYs8Zse0BjQUSoi0scyzGIDlrR3sIyDqOLeWYiKKOzj(zjA9wIY6Gqld8rOLvmBzDakUSmQVww(C2YOEf7JLDrdlLmgopPLb(i0scHDJLU0s4yzfZwwhGIlRZHlhoYp6JeFRL4WLdhXYLvaZfY9swlaxRhX0w3INQjzapE93452x8Jogcxpy0PP5YskGAcnDWFdWHNpse0JQl64yhTEIqhdHRhm60aU0hkHuFeiDmYgGdpFKiOhfIqh96auC1kpKffu8Cgb9Drd0rhdHRhm60kOoowa1ep(Q4gGdpFKOHcvxwheAzGU1YYkMTKKMiklpC5WXYLlllDnl)H60maBPU0hkljzapE9B5nVpX6GqljGLbUL(qzz3qWjqwheAjbSKOGeLL4NLiO3Yp16GqljGLbk2TeTEljI1bHwsalJqsIML4NLiO3suwheAzGpcTSIzlRdqXLLr91YYNZwg1RyFSefnSuYy48Kwg4Jqlje2nw6slHJLvmBzDakUS8MNL)qDlJVVSLOSuwhgPLqnljPjIY6C4YHJ8J(iX3AjoC5WrSCzfWCHCVK1cW16rmT1T4PAsgWJx)nEU9f)Otlhy6(2g)ApGpi9HsedbJad)Ya6yiC9GrNMMllPaQj00b)nahE(irq)Nshh7O1te6yiC9GrNgWL(qjK6JaPJr2aC45Jeb9Oqe6OxhGIRw5HSOGINZiOhfnqhDmeUEWOtRG64ybut84RIBao88rIgkuDrhdHRhm60Kfeek4duXIBEcnhWnC8bOyzpkRdcTKMc(W163YkMTuEHSLN0Yna)1H6slx(Wby5UEzzuVIT8glV3JFwIJzmslJgZvmdS8hQBz89LTeLLY6WiTeQzjjnruwNdxoCKF0hj(wlXHlhoILlRaMlK7LSwaUwpIPTUfpvtYaE86VXZTV4hDmeUEWOttZLLua1eA6G)gGdpFKiOhvx0XXoA9eHogcxpy0PbCPpucP(iq6yKnahE(irqpkeHo61bO4QvEilkO45mc67IgOJogcxpy0PvqDCSaQjE8vXnahE(irdfQUOJHW1dgDAYcccf8bQyXnpHMd4go(auSShL1bHwgOBTSSIzl7Einz5HlhowUCzzPRzzfZa2YdWwgcbSLv8nwsel5HdDwADoC5Wr(rFKa9rC4YHJy5YkG5c5(dYb4A9hU8VSGho0zjAeX6Gqld0TwwwXSLKeA5HlhowUCzzPRzzfZa2YdWwselHalxSuAjpCOZsRZHlhoYp6JeOpIdxoCelxwbmxi3lRaCT(dx(xwWdh6Seb9eX6yDqOLDpUC4iBDpKMS0Lw6tXZJFwQbbwQlzlJ6vSLeCyC5yr3)EIaT47lB5nplX6aap163YH5N0YcA5oBjCR8qVB5N15WLdhz7GCp(wlXHlhoILlRaMlK7XpRZHlhoY2b5p6JKhgq5DRpucE5b7GaCTEA3a8xbf(1q1kNIbITBfshh7iOhfDeJHW1dgDAax6dLqQpcKogzdWHNpY(iIo6iUUfpvtZLLaQjQywen2lwuofdA8C7l(rhdHRhm600CzjGAIkMfrJ9IfLtXGgGdpFK9rerOJopmG6hb0iIiY6C4YHJSDq(J(ipa(gwuqaGNkaxRhh7TWlycGJD06rrNhgq93kpKffueEbJwFeB0W6C4YHJSDq(J(i1CzjfqnHMo4paxRVUfpvtYaE86VXZTV4hDA5at3324x7b8bPpuIyiyey4xgqhdHRhm60KmGhV(Bao88rIwpnOZddO(BLhYIckcVGrRlRZHlhoY2b5p6JuZLLua1eA6G)aCT(6w8unjd4XR)gp3(IF05at3324x7b8bPpuIyiyey4xgqhXyiC9GrNMKb841FdWHNps06rrd0rhdHRhm60KmGhV(Bao88rIG(pJi68WaQ)w5HSOGIWly06Y6C4YHJSDq(J(i1CzjfqnHMo4paxRN26w8unjd4XR)gp3(IF05Hbu)TYdzrbfHxWO1L15WLdhz7G8h9rQ5YskGAcnDWFaUwpgcxpy0PbCPpucP(iq6yKnahE(irRNinAqhh7iONgwNdxoCKTdYF0hz0yhS8Hs8ahfCeB6do26C4YHJSDq(J(ibU0hkHuFeiDmYaCTEmeUEWOtlASdw(qjEGJcoIn9bh3aC45JeTEk8JoTBa(RGc)AOAax6dLqQpcKogjDmeUEWOttZLLua1eA6G)gGdpFKOrHFwNdxoCKTdYF0hjo2f76azfGR1JJDe0te6igdHRhm60aU0hkHuFeiDmYgGdpFKO1td0rhdHRhm60Ig7GLpuIh4OGJytFWXnahE(irRNgiIopmG6VvEilkOi8cgnuwNdxoCKTdYF0hjo2f76azzDoC5Wr2oi)rFKYnFgFOeyWnSaPJrgGR1J4dx(xwWdh6SeTEIGo6iExxtRTdrk2aqCtFJoo2BHxWeah7O1hreHi60Ub4Vck8RHQj38z8HsGb3WcKogjDjxID4OlBLZGUqj(8g26C4YHJSDq(J(iLB(m(qjWGBybshJmaxR)WL)Lf8WHolrRNi0PDdWFfu4xdvtU5Z4dLadUHfiDmsRZHlhoY2b5p6JCFDyKq9sG0Xida)JxSOoafxYEub4A90Ub4Vck8RHQTVomsOEjq6yK0XXEl8cMa4yhTEu0LCj2HJUSvod6cL4ZBy6iMwjxID4OlBLZauDNORnm6Ox3INQjzapE93452x8drwNdxoCKTdYF0h5(6WiH6LaPJrga(hVyrDakUK9OcW16rmo2rdf6OVRRP12HifBaiUPVHo6iUUfpvJhgq5DRpucE5b7Ggp3(IF0Xq46bJonEyaL3T(qj4LhSdAao88rIameUEWOttZLLua1eA6G)gGdpFKicr0rmIXq46bJonGl9Hsi1hbshJSb4WZhjAOOJyARBXt10CzjGAIkMfrJ9IfLtXGgp3(IFOJogcxpy0PP5Ysa1evmlIg7flkNIbnahE(irdfIqhDCSJ2NreDeJHW1dgDAAUSKcOMqth83aC45JenuOJoo2rRleHo6Ba(RGc)AOALtXaX2TcreDA3a8xbf(1q12xhgjuVeiDmsRZHlhoY2b5p6JedomYLpuIi4ESy5uX14dvaUwphy6(2g)Avml4Wngabsb(2oSxqa9DDnTwfZcoCJbqGuGVTd7fe0K1HrIwpQUJopmG6VvEilkOi8cgnIyDoC5Wr2oi)rFKyWHrU8Hseb3JflNkUgFOcW165at3324xRIzbhUXaiqkW32H9ccOVRRP1QywWHBmacKc8TDyVGGMSoms06r9z6yiC9GrNMKb841FdWHNpseGIi0RBXt1KmGhV(B8C7l(rNhgq93kpKffueEbJgrSohUC4iBhK)OpY91Hrc1lbshJma8pEXI6auCj7rfGR1t7gG)kOWVgQ2(6WiH6LaPJrshh7TWlycGJD06rrxYLyho6Yw5mOluIpVHPVRRP12HifBaiUPVzDoC5Wr2oi)rFKLtXaX2Tcda)JxSOoafxYEub4A90Ub4Vck8RHQvofdeB3kKoTBa(RGc)AOA8WakVB9HsWlpyhqhX4yVfEbtaCSJwFxOJopmG6VvEilkOi8cgbebrwNdxoCKTdYF0hz5umqSDRWaW)4flQdqXLShvaUwpTBa(RGc)AOALtXaX2TcPt7gG)kOWVgQgpmGY7wFOe8Yd2b05Hbu)TYdzrbfHxWiOhfDCS3cVGjao2rRVlRZHlhoY2b5p6Jeh7IO3xoaxRhh7iONi0rmgcxpy0PbCPpucP(iq6yKnahE(irRNgOJogcxpy0Pfn2blFOepWrbhXM(GJBao88rIwpnqeDEya1FR8qwuqr4fmAOSohUC4iBhK)OpsCSlIEFzRZHlhoY2b5p6JSCkgi2UvyaUw)gG)kOWVgQw5umqSDRq60k5fJlhowhRZHlhoYg(17ZxisweSopIkMfrJ9IfLtXaRZHlhoYg(9rFK6sw4fhgWCHC)sxwaOUuqbxpEeBl9WJITohUC4iB43h9rUVGWNqth8BDoC5Wr2WVp6JCNbsgG0hkRdcTmWTKTS7b4Byljeca8uw6Aw(d1T8aSLHUu6dLLxz5IpzzjklduSB5nplJchAwzj(2SKhgq9BzuVI9XYi2OHLsgdNN06C4YHJSHFF0h5bW3WIcca8ub4A94yVfEbtaCSJwpk68WaQ)w5HSOGIWly06JyJgwNdxoCKn87J(ixovCjfrG(JkKNY6C4YHJSHFF0hPMd49fe(SohUC4iB43h9rEdMLf4wc8TwwheAzGozzjHWUXs8pE5dLLvmaQtfBzxwwhGIlPLU2NyDqOLeWsckuNMbyl1L(qzjbNaxefHwheAjbSKGc1bwUb4VouxAjrpqDJLrpPLdSSKqy3yDoC5Wr2WVp6JSG64ybut84RIda)JxSOoafxYEub4A9CGP7BB8Rf7VhpIWtwmqk0GGD)94ruqDCmDA3a8xbf(1q1kOoowa1ep(QyRdcTKWy2sjJHZZs8jllHAwwqDCSaQjE8vXwwaNIIb8ZY9FlRy2YftXZ7a)wYAAmUSeQzzS)E8icpzXaPqdc293Jhrb1XXFI1bHwsaljOqDA2x2YBb479Bj(KLLvmBPMdKLLec7gRdcTKawssteLLU0Y6w8u8ZYBEwg1xll3zlVVNVU9fB5oRbbSL)qDGLdhCzjrFb3VLLbccxpy0X6GqljGLeuOoWYna)1H6slj6bQBSm6jTCGLLec7gRdcTKawgHC45JpuwIHW1dgDSeowsuUSSeQzjrPd(T0LwUGrzGLqGLCGPFlllOLF2sjJHZtADqOLeWYiKdpF8HYsmeUEWOJLWXYi0L(qzjP(yjrZXiT0LwUGrzGLv8nwsWSuYy48KwNdxoCKn87J(ilOoowa1ep(Q4aW)4flQdqXLShvaUwpIrCDlEQMKb841FJNBFXp6yiC9GrNMKb841FdWHNpse0Jcr0Xq46bJonnxwsbutOPd(Bao88rIG(pJi6yiC9GrNgWL(qjK6JaPJr2aC45Jebem60Ub4Vck8RHQvqDCSaQjE8vXwheAjHXSLsgdNNL4twwc1SSG64ybut84RITSaoffd4NL7)wwXSLlMIN3b(TK10yCzjuZYy)94reEYIbsHgeS7VhpIcQJJ)eRdcTKawsqH60SVSL3cW373s8jllRy2snhillje2nwheAjbSmc5WZhFOSedHRhm6yjCSKOCzjTeQzjrPd(T0LwUGrzGLqGLCGPFlllOLF2sjJHZtAz3tC3yjjnruw6slRBXtXplV5zzuFTSCNT8(E(62xSL7SgeWw(d1bwoCWLLe9fC)wwgiiC9Grhld8rOL)qDlJVVSLDzjeyzieWwgOy36GqljGLeuOoWYna)1H6slj6bQBSm6jTCGLLec7gRdcTKawgHC45JpuwIHW1dgDSeowgHU0hklj1hljAogPLU0skaFvmdSSIVXscMLsgdNN06C4YHJSHFF0hzb1XXcOM4Xxfha(hVyrDakUK9OcW16rmIPTUfpvtYaE86VXZTV4hDmeUEWOttwqqOGpqflU5j0Ca3aC45Jeb9Oqe6OJJD067cr0Xq46bJonnxwsbutOPd(Bao88rIG(pthdHRhm60aU0hkHuFeiDmYgGdpFKiGGrN2na)vqHFnuTcQJJfqnXJVk26yDoC5Wr2KSwF5umqSDRWaW)4flQdqXLShvaUwpTBa(RGc)AOALtXaX2TcPt7gG)kOWVgQgpmGY7wFOe8Yd2b05Hbu)98WaQ)w4fmDCSJauwNdxoCKnjR9rFK4BTehUC4iwUScyUqUh)SohUC4iBsw7J(iLfeek4duXIBEcnhWb4A90URRP1Kfeek4duXIBEcnhWn9nRJ15WLdhztYaE86VxZLLaQjQywen2lwuofdcW163110A7li8T0LvtFJoT76AAnjd4XR)M(M15WLdhztYaE86)J(ilNIbITBfga(hVyrDakUK9OcW16PDdWFfu4xdvRCkgi2UviDA3a8xbf(1q14HbuE36dLGxEWoGopmG6VNhgq93cVGPJJDeGIoT76AAnjd4XR)M(M15WLdhztYaE86)J(iX3AjoC5WrSCzfWCHCp(zDqOLeZ8tAzbTCNTeWrbEv8yPgeyzqev3BDoC5Wr2KmGhV()OpsGUm2hkreCpwe1NxaUwFDlEQgqxg7dLicUhlI6ZRXZTV4hDA3a8xbf(1q1a6YyFOerW9yruFE03110AaDzSpuIi4ESiQpV2dgDSohUC4iBsgWJx)F0hPKb841V15WLdhztYaE86)J(ibU0hkHuFeiDmYaW)4flQdqXLShL15WLdhztYaE86)J(i1CzjfqnHMo4paxRFdWFfu4xdvd4sFOes9rG0XiPVb4Vck8R1vtYaE8636C4YHJSjzapE9)rFKax6dLqQpcKogza4F8If1bO4s2JY6C4YHJSjzapE9)rFK7RdJeQxcKogza4F8If1bO4s2JkaxRN2na)vqHFnuT91Hrc1lbshJKogcxpy0PbCPpucP(iq6yKnahE(irRVl6yiC9GrNMMllPaQj00b)nahE(irRVlRdcTmqNSSKOCzzjuZsIsh8BPR9jwheAjbSKWy2sahE(4dLLyiC9GrhlHJLax6dLqQpcKogPLU0YfCOyGLv8nwwXSL44BgEz5thCLdhlHAwsuUSKcOMqth8BDoC5Wr2KmGhV()OpsnxwsbutOPd(dW16rmIPLdmDFBJFThWhK(qjIHGrGHFza6OVRRP12xq4BPlRM(g6OVRRP1KmGhV(Bao88rIauiIoIXq46bJonGl9Hsi1hbshJSb4WZhjAOqh9dx(xwWdh6Senuicrb4tXaG(w1JY6C4YHJSjzapE9)rFKYnFgFOeyWnSaPJrgGR1F4Y)YcE4qNLO1te60Ub4Vck8RHQj38z8HsGb3WcKogP15WLdhztYaE86)J(ibU0hkHuFeiDmYaW)4flQdqXLShvaUw)Hl)ll4HdDwIwprSohUC4iBsgWJx)F0hPCZNXhkbgCdlq6yKb4A90Ub4Vck8RHQj38z8HsGb3WcKogP15WLdhztYaE86)J(i3xhgjuVeiDmYaW)4flQdqXLShvaUwpTBa(RGc)AOA7RdJeQxcKogP1X6Gql7gw70xLLhUC4y5YLL15WLdhztw9(8fIKfbRZJOIzr0yVyr5umW6C4YHJSjRp6JuwqqOGpqflU5j0CahGR1t7UUMwtwqqOGpqflU5j0Ca303Soi0sIz(jTSGwUZwc4OaVkESudcSmiIQ7TohUC4iBY6J(ib6YyFOerW9yruFEb4A976AAnGUm2hkreCpwe1Nx7bJo0PDdWFfu4xdvdOlJ9Hseb3Jfr95zDoC5Wr2K1h9rYddO8U1hkbV8GDqaUwpTBa(RGc)AOALtXaX2TcToi0sc7cLLsUSCho6slXW55LdNBzDqOLb6KLLbTomsOEzjrZXiT01(eRdcTKawsqa8xhQlTKOhOUXYON0Ybwwg06WiH6LLenhJ06GqljGLbTomsOEzjrZXiP1sxA59981TVyRdcTKawsqH60maB5allVYYWlylduSBDoC5Wr2K1h9rUVomsOEjq6yKbG)XlwuhGIlzpQaCTEA3a8xbf(1q12xhgjuVeiDms64yVfEbtaCSJwpk6sUe7Wrx2kNbDHs85nm9DDnT2oePydaXn9nRdcTmqNSSKqNIbwsqUvOLU2NyDqOLeWsccG)6qDPLe9a1nwg9KwoWYscDkgyjb5wHwheAjbSKGa4VouxAjrpqDJLrpPLdSSKMOjlrmXbEcPPpXsa)0N3nLL7m(0LSLqnlRy2sAAya1VL4ygJmalhMFsllOL7SLaokWRIhl1GaldIO6EezDqOLeWscku3YO(Azj(2SKMggq9B5oRbbSLdhCzjrpqDJ1bHwsaljOqDlJ6RLLuNpw2LLqGLHqaBzGIDRZHlhoYMS(OpYYPyGy7wHbG)XlwuhGIlzpQaCTEA3a8xbf(1q1kNIbITBfsN2na)vqHFnunEyaL3T(qj4LhSdOZddO(BLhYIckcVGrqpk64yVfEbtaCSJwFx0PDxxtRjzapE9303Soi0YaDYYsIcwe8eAPRz5pu3YO(Azj15JLeXsiWYqiGTmqXU15WLdhztwF0hPMllbutuXSiASxSOCkgeGR1JJ9w4fmbWXoA9eX6C4YHJSjRp6JmASdw(qjEGJcoIn9bhBDqOLb6KLLrOl9HYss9XsIMJrAPR9jwheAjbSKGc1T8aSL6sFOSKKMiQaS8MNL)qDlJVVSLeXsiWYqiGTmqXULDpXDJLFoIwcbwgcbSL8WaQFld8rOL0WsiWYqiGTmqXU1bHwsaljOqDlpaBPU0hkljzapE9hGLFQLqGLHqaBPKXW5jTeWHNpwchlRy2smeUEWOJLqnljzapE9hGL38S8hQBz89LTKiwcbwgcbSLbk2TS7jUBS8Zr0siWYqiGTKhgq9BzGpcTKgwcbwgcbSLbk2T06C4YHJSjRp6Je4sFOes9rG0Xida)JxSOoafxYEub4A9igX4yhTEIqNhgq9Jw)NJiIqhDCSJwpnqeDex3INQjzapE93452x8dD0Xq46bJonjd4XR)gGdpFKO1)PiY6GqldCyQd)BjgopVC4Cll1Gal7gGpi9HYscoqWyzGGFzG15WLdhztwF0hPMllPaQj00b)b4A91T4PAsgWJx)nEU9f)Otlhy6(2g)ApGpi9HsedbJad)Ya6yiC9GrNMKb841FdWHNps06PbDEya1FR8qwuqr4fmADzDqOLbom1H)TedNNxoCULLAqGLDdWhK(qzjbhiySmqWVmW6C4YHJSjRp6JuZLLua1eA6G)aCT(6w8unjd4XR)gp3(IF05at3324x7b8bPpuIyiyey4xgqhXyiC9GrNMKb841FdWHNps06rrd0rhdHRhm60KmGhV(Bao88rIG(pJi68WaQ)w5HSOGIWly06Y6Gqld0jlljkxwslHAwsu6GFlDTpX6GqljGLeuOULhGTux6dLLK0erzDoC5Wr2K1h9rQ5YskGAcnDWFaUwpT1T4PAsgWJx)nEU9f)Soi0YaDYYYiKKOzPR9jwheAjbSKGc1T8aSL6sFOSKKMikld8rOL)qDlpaBPU0hkljzapE9B5nplPHLqGLHqaBPKXW5jTeWHNpwchlRy2smeUEWOJLqnljzapE9BDoC5Wr2K1h9rcCPpucP(iq6yKbG)XlwuhGIlzpQaCTEmeUEWOttYaE86Vb4WZhjA90aD0rmT1T4PAsgWJx)nEU9f)qK1bHwgOtwwg06WiH6LLenhJ0sx7tSoi0scyjbbWFDOU0sIEG6glJEslhyzzqqIM1bHwsaljOqDlpaB5allVYYWlylduSBDoC5Wr2K1h9rUVomsOEjq6yKbG)XlwuhGIlzpQaCTEA3a8xbf(1q12xhgjuVeiDms64yVfEbtaCSJwpkRdcTmWHPo8VLAqGLegZwstHBmacKwgOB7WEbbwNdxoCKnz9rFKyWHrU8Hseb3JflNkUgFOcW165at3324xRIzbhUXaiqkW32H9ccOVRRP1QywWHBmacKc8TDyVGGMSoms06r1D05Hbu)TYdzrbfHxWOreRZHlhoYMS(Opsm4Wix(qjIG7XILtfxJpub4A9CGP7BB8RvXSGd3yaeif4B7WEbb03110Avml4Wngabsb(2oSxqqtwhgjA9O(mDmeUEWOttYaE86Vb4WZhjcqre61T4PAsgWJx)nEU9f)OZddO(BLhYIckcVGrJiwNdxoCKnz9rFK7RdJeQxcKogzaUwpTBa(RGc)AOA7RdJeQxcKogP15WLdhztwF0hjo2frVVS1bHwsW7RLLdZpllOL7SLaokWRIhl1GaldIO6ERdcTmq6aapLLa9f)jwgOtwwgOy3YG0bYYsx7tSoi0scyjbfQBz89LTKiwcbwUyP0Yaf7wheAjbSmcjjAw6sl13S0hlPHLqGLHqaBPKXW5jTmWhHwsW3neelDPL6Bw6JL0WsiWYqiGTuYy48KwheAjbSKGc1TmQVwwoWYs8TzjpmG63YDwdcylRy2YHdUSKOhOUX6C4YHJSjRp6Jeh7IDDGScW165Hbu)TYdzrbfHxWOHIEDlEQMKb841FJNBFXpRdcTmqNSSKqNIbwsqUvOLU2NyDqOLeWsccG)6qDPL3UV863YON0YbwwsOtXalji3k0siWsAAyaL3T(qzjnT8GDG1bHwsaljOqDlJ6RLLuNpwELLl(KLLDzzGI9aSmWhHw(d1TmQVwwIVnl5Hbu)wg1RyFSKiwkzmCEslrmXbEcPPpXYab1xplXNSSKqcIL8xES8klPHLbk2Tmc0LLLf0Yna)LNYsEya1VL4BBZhQaS0hlRygc(rK15WLdhztwF0hz5umqSDRWaW)4flQdqXLShvaUwpTBa(RGc)AOALtXaX2TcPt7gG)kOWVgQgpmGY7wFOe8Yd2b0rmo2BHxWeah7O13f6OZddO(BLhYIckcVGrarqeDA3110AsgWJx)n9nRZHlhoYMS(OpsCSl21bYkaxRhh7TWlycGJD06jcDEya1FR8qwuqr4fmAOOtBDlEQMKb841FJNBFXpRZHlhoYMS(OpYYPyGy7wHb4A9Ba(RGc)AOALtXaX2TcPtRKxmUC4Oip9kgcuKKEyGuLQuka]] )
end