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

    spec:RegisterPack( "Windwalker", 20180824.0931,
        [[d4us)bqiHspsi4scfk1MquFsOaJcrQtrQWReQmle0TekAxc(Lq0WqKCmqAzKQ6ziqtdeQRjeABiG8nqGmoHc5CcvX6ekO5POQ7js7dH6GKkIfsQYdbbnrHQuxuOQAJcvLpIaQgPqHsojcOWkvuEjPIQzIakDteqr7ee9tHQKHsQOSuqipvvnveXvfku8vHcvNfeO2ls)LWGv5WkTyf6XqMmOUmQntIptsJwvCAkRgeWRvWSf1TfXUL63qnCvPJtQiTCGNt00P66KY2riFxinEfvoVISEeG5tQ0(LmfkLe6hEDMcP(KcAmIuXi9H4aPIhccfIPFF6LP)3fnSQm93Bct)X4wdhDZdmG(F3PmEHPKq)sSgaX0)J7VYyyKrQA(J2yaHtIuAjA51nCJaRIhP0sqroMXJroQSXeMjkYxawXYSmsDgGHO1GLrQZGibbM4EqeJBnC0npWGG0sq0)OMLDcmA6i9dVotHuFsbngrQyK(qCGuXdbHskO0V8Lrui1Nafp0pmlr0pjpMSotwN)W1bZkRw2Rlg3A4OBEGb1Ti3WDDVlAOofmOo9w3ZCDkyqD6ecGby)juZQzeyAngu3cdb0KEc3USUOmGRlzH56ua4K68hUUVLOLx3WnecwfVoDIoJaBDzRhy46WDD(dx3laRyzUoFhd1SAge(STkdxNVav2fMsDiCdBUH7nlRZX1HMqzw4lqLDzDK2xGk7ctPotwxJ96KAVVyGZW6iuZQzq4Z2QmCDq4MZ1PtqUH76iWAsVoUDGXY6uWG60jXR4VUTHR7tsDoUoisRRtNGCd31rG1KEDsRrCD(dpv3c46s0CTnNNQJNdL1KgrCOMvZ0jWWmCDJlAiMAV1byeojHB41nClRtbdQJetLb1PZ2CsDrF4UUg7pwRwhNLCDrxzDagHts4gMHRlMXSo)XK1f1Y560KABopv3ixNovZqd5PycyImP5mCDRSoZRZK19cWJ7yEQUTos0z1LyszOMvZGiobtedxh3oyQofmOU4lpzTADFg8YTxNo3qd1rAfmOUKv6myQoalzxwxmJzDYhSwgUJbEDnZW1zUoc0F2KUKsc9lza3Mp9HikjuiHsjH(5EhZmmvp6FrUHB63nvgiE3Cc9JaMZaBP)yR7fWejurWbOb3uzG4DZj1rUUyR7fWejurWbObUzGQrawRk4SnNbQJCDCZa1P6sRJBgOofs25QJCDOhRU5RdADKRl26g1uucsgWT5tbTx6hnHYSWxGk7skKqPofs9PKq)CVJzgMQh9Vi3Wn9J2CwSi3WTiBsN(ZM0f9MW0pcM6uijiLe6N7DmZWu9OFeWCgyl9JW4mmoAhaM0AvHuRfdgAia4K1AzDZNwN(0)ICd30VKbCB(e1PqcXusOFU3Xmdt1J(raZzGT0)OMIsqYaUnFka4K1AzDZNwh0aPIi9Vi3Wn9RysxkWkcfnWe1Pqgrkj0p37yMHP6r)lYnCt)atATQqQ1Ibdnq)OjuMf(cuzxsHek1PqsGOKq)CVJzgMQh9Vi3Wn9pMx0awZfdgAG(raZzGT0FS19cyIeQi4a0WyErdynxmyOH6ixhcJZW4ODaysRvfsTwmyOHaGtwRL1rCAD6xh56qyCgghTdkM0LcSIqrdmfaCYATSoItRtF6hnHYSWxGk7skKqPofsiikj0p37yMHP6r)lYnCt)J5fnG1CXGHgOF0ekZcFbQSlPqcL6uN(LmGBZNe4xUzaLekKqPKq)CVJzgMQh9JaMZaBP)rnfLGKbCB(uaghTP)f5gUPFft6cSIWFyr0hZzHBQmG6ui1Nsc9Z9oMzyQE0)ICd30VBQmq8U5e6hbmNb2s)Xw3lGjsOIGdqdUPYaX7MtQJCDJAkkbjd428PamoAxh56qpwDZxhet)OjuMf(cuzxsHek1Pqsqkj0p37yMHP6r)iG5mWw6Futrjiza3MpfGXrB6FrUHB6hT5SyrUHBr2Ko9NnPl6nHPFem1PqcXusOFU3Xmdt1J(raZzGT0)OMIsymJXWznPhGXrB6FrUHB6hT5SyrUHBr2Ko9NnPl6nHPFjd428jQtHmIusO)f5gUPFjd428j6N7DmZWu9OofsceLe6N7DmZWu9O)f5gUPFGjTwvi1AXGHgOF0ekZcFbQSlPqcL6uiHGOKq)CVJzgMQh9JaMZaBP)xatKqfbhGgaM0AvHuRfdgAOoY19cyIeQi4G(bjd428j6FrUHB6xXKUuGvekAGjQtHmgrjH(5EhZmmvp6hbmNb2s)VaMiHkcoanamP1QcPwlgm0qDKR7fWejurWb9dJ5fnG1CXGHgO)f5gUPFft6sbwrOObMOofY4Hsc9Z9oMzyQE0)ICd30)yErdynxmyOb6hbmNb2s)Xw3lGjsOIGdqdJ5fnG1CXGHgQJCDimodJJ2bGjTwvi1AXGHgcaozTwwhXP1PFDKRdHXzyC0oOysxkWkcfnWuaWjR1Y6ioTo9PF0ekZcFbQSlPqcL6uiHskkj0p37yMHP6r)lYnCt)J5fnG1CXGHgOFeWCgyl9hBDVaMiHkcoanmMx0awZfdgAG(rtOml8fOYUKcjuQtD6xYaUnFIscfsOusOFU3Xmdt1J(xKB4M(DtLbI3nNq)iG5mWw6p26EbmrcveCaAWnvgiE3CsDKRl26EbmrcveCaAGBgOAeG1QcoBZzG6ixh3mqDQU064MbQtHKDU6ixh6XQB(6Gwh56ITUrnfLGKbCB(uq7L(rtOml8fOYUKcjuQtHuFkj0p37yMHP6r)lYnCt)OnNflYnClYM0P)SjDrVjm9JGPofscsjH(5EhZmmvp6hbmNb2s)(M52dan5J1QciWcZIOwdh4EhZmCDKRl26EbmrcveCaAaOjFSwvabwywe1A46ix3OMIsaOjFSwvabwywe1A4amoAt)lYnCt)an5J1QciWcZIOwdtDkKqmLe6N7DmZWu9OFeWCgyl9JW4mmoAhaM0AvHuRfdgAia4K1AzDZNwN(1rUoegNHXr7GIjDPaRiu0atbaNSwlRB(06Gy6FrUHB6xYaUnFI6uiJiLe6N7DmZWu9OFeWCgyl9)cyIeQi4a0aWKwRkKATyWqd1rUUxatKqfbh0piza3Mpr)lYnCt)kM0LcSIqrdmrDkKeikj0p37yMHP6r)iG5mWw6Futrjiza3MpfaCYATSU5tRdAGurK(xKB4M(vmPlfyfHIgyI6uiHGOKq)CVJzgMQh9Vi3Wn9dmP1QcPwlgm0a9JMqzw4lqLDjfsOuNczmIsc9Z9oMzyQE0pcyodSL(FbmrcveCaAymVObSMlgm0qDKR7fWejurWb9datATQqQ1Ibdnuh56qpwizNRUywh6XQJ460N(xKB4M(vmPlWkc)HfrFmNfUPYaQtHmEOKq)CVJzgMQh9Vi3Wn97MkdeVBoH(raZzGT0)lGjsOIGdqdJ5fnG1CXGHgQJCDVaMiHkcoOFaysRvfsTwmyOH6ixh6Xcj7C1fZ6qpwDexhu6hnHYSWxGk7skKqPofsOKIsc9Z9oMzyQE0)ICd30)yErdynxmyOb6hbmNb2s)Xw3lGjsOIGdqdJ5fnG1CXGHgQJCDimodJJ2bGjTwvi1AXGHgcaozTwwhXP1PFDKRdHXzyC0oOysxkWkcfnWuaWjR1Y6ioTo9PF0ekZcFbQSlPqcL6uiHcLsc9Z9oMzyQE0pcyodSL(xKBeXcU5eJL1rCADeSoY1fBDVaMiHkcoaniFTUTwvGaBZIbdnq)lYnCt)YxRBRvfiW2SyWqduNcju9PKq)CVJzgMQh9Vi3Wn9dmP1QcPwlgm0a9JMqzw4lqLDjfsOuNcjucsjH(5EhZmmvp6hbmNb2s)Xw3lGjsOIGdqdYxRBRvfiW2SyWqd0)ICd30V8162AvbcSnlgm0a1PqcfIPKq)CVJzgMQh9Vi3Wn9pMx0awZfdgAG(raZzGT0FS19cyIeQi4a0WyErdynxmyOb6hnHYSWxGk7skKqPo1PFPtjHcjukj0)ICd30V1eHhyXCACt)CVJzgMQh1PqQpLe6FrUHB63XAOhbwraZR)q)CVJzgMQh1Pqsqkj0p37yMHP6r)iG5mWw6p26g1uucshdse8c8hX2WcfdWbTx6FrUHB6x6yqIGxG)i2gwOyaM6uiHykj0p37yMHP6r)lYnCt)atATQqQ1Ibdnq)iG5mWw6FjagyohKrnfxaWAn8dwtYbU3Xmdxh56g1uucYOMIlayTg(bRj5G0x0qDP1Pp9JMqzw4lqLDjfsOuNczePKq)CVJzgMQh9JaMZaBP)rnfLaqt(yTQacSWSiQ1WbyC0UoY1fBDVaMiHkcoana0KpwRkGalmlIAnm9Vi3Wn9d0KpwRkGalmlIAnm1PqsGOKq)CVJzgMQh9JaMZaBP)yR7fWejurWbOb3uzG4DZj0)ICd30p3mq1iaRvfC2MZauNcjeeLe6N7DmZWu9O)f5gUP)X8IgWAUyWqd0pcyodSL(JTUxatKqfbhGggZlAaR5Ibdnuh56qpwizNRUywh6XQJ406Gwh56KSlgXTMm4gd0hQaIFr1rUUrnfLWiEq8cWOG2l9JMqzw4lqLDjfsOuNczmIsc9Z9oMzyQE0pcyodSL(jDDOhRU5tRt)60b9Vi3Wn9RysxGve(dlI(yolCtLbuNcz8qjH(5EhZmmvp6FrUHB63nvgiE3Cc9JaMZaBPF0Jv38P1rW6ixh3mqDk4wclCSizNRU5RtF6hnHYSWxGk7skKqPofsOKIsc9Z9oMzyQE0)ICd30VBQmq8U5e6hbmNb2s)OhlKSZvxmRd9y1rCAD6xh56g1uucsgWT5tbyC0UoY1HW4mmoAhumPlWkc)HfrFmNfUPYGaGtwRL1rCDCZa1PGBjSWXIKDo6hnHYSWxGk7skKqPofsOqPKq)lYnCt)rFmq2AvbmyvXT4vRrp0p37yMHP6rDkKq1Nsc9Z9oMzyQE0pcyodSL(rpwDeNwhbRJCDCZa1PGBjSWXIKDU6iUo9drSoY1TeadmNdYOMIlayTg(bRj5ay7H6MVo9P)f5gUPFft6sbwrOObMOofsOeKsc9Z9oMzyQE0)ICd30pWKwRkKATyWqd0pcyodSL(jDDKUo0JvhXP1rW6ixh3mqDQoItRdIjvD6OoD1To0JvhXP1fX60rDKRJ015BMBpiza3Mpf4EhZmCD6QBDimodJJ2bjd428PaGtwRL1rCADeO60rDKRl26wcGbMZbzutXfaSwd)G1KCG7DmZW0pAcLzHVav2LuiHsDkKqHykj0p37yMHP6r)iG5mWw6p268nZThKmGBZNcCVJzgUoY1r66wcGbMZbzutXfaSwd)G1KCaS9qDZxN(1PRU1HW4mmoAhI(yGS1QcyWQIBXRwJEcaozTww381bLG1Pd6FrUHB6xXKUuGvekAGjQtHeAePKq)CVJzgMQh9Vi3Wn9dmP1QcPwlgm0a9JaMZaBPFegNHXr7GKbCB(uaWjR1Y6ioTUiwNU6whPRl268nZThKmGBZNcCVJzgUoDuh56ITULayG5Cqg1uCbaR1Wpynjh4EhZmm9JMqzw4lqLDjfsOuNcjuceLe6N7DmZWu9O)f5gUP)X8IgWAUyWqd0pcyodSL(ryCgghTdkM0LcSIqrdmfaCYATSoIRt)6ixxS19cyIeQi4a0WyErdynxmyOH6ixh3mqDk4wclCSizNRoIRdADKRBjagyohKrnfxaWAn8dwtYbW2d1rCDqPF0ekZcFbQSlPqcL6uiHcbrjH(5EhZmmvp6FrUHB6FmVObSMlgm0a9JaMZaBP)rnfLGmQP4cawRHFWAsoi9fnu381PFDKRl26EbmrcveCaAymVObSMlgm0a9JMqzw4lqLDjfsOuNcj0yeLe6N7DmZWu9OFeWCgyl9Z6un79LHd(dl4KxgGbsbAFxK5yqDKRButrj4pSGtEzagifO9DrMJbbPVOH6ioToOXtDKRJBgOofClHfowKSZvhX1rq6FrUHB6hbw0q2AvbeyHzr2uF82AvQtHeA8qjH(5EhZmmvp6hbmNb2s)SovZEFz4G)Wco5LbyGuG23fzoguh56g1uuc(dl4KxgGbsbAFxK5yqq6lAOoItRdkexh56qyCgghTdsgWT5tbaNSwlRB(6GsW6ixNVzU9GKbCB(uG7DmZW1rUoUzG6uWTew4yrYoxDexhbP)f5gUPFeyrdzRvfqGfMfzt9XBRvPofs9jfLe6N7DmZWu9O)f5gUP)X8IgWAUyWqd0pcyodSL(JTUxatKqfbhGggZlAaR5Ibdnq)OjuMf(cuzxsHek1PqQpukj0)ICd30p6XerxIy6N7DmZWu9Oofs91Nsc9Z9oMzyQE0pcyodSL(5MbQtb3syHJfj7C1rCDqRJCD(M52dsgWT5tbU3Xmdt)lYnCt)OhtmQbKo1PqQpbPKq)CVJzgMQh9Vi3Wn97MkdeVBoH(raZzGT0FS19cyIeQi4a0GBQmq8U5K6ixxS19cyIeQi4a0a3mq1iaRvfC2MZa1rUosxh6Xcj7C1fZ6qpwDeNwN(1PRU1XnduNcULWchls25QB(6iyD6OoY1fBDJAkkbjd428PG2l9JMqzw4lqLDjfsOuNcP(qmLe6N7DmZWu9OFeWCgyl9JESqYoxDXSo0JvhXP1rW6ixh3mqDk4wclCSizNRoIRdADKRl268nZThKmGBZNcCVJzgM(xKB4M(rpMyudiDQtHu)isjH(5EhZmmvp6hbmNb2s)XwNKZmYnCxh56EbmrcveCaAWnvgiE3Cc9Vi3Wn97MkdeVBoH6uN(rWusOqcLsc9Vi3Wn9Bnr4bwmNg30p37yMHP6rDkK6tjH(5EhZmmvp6V3eM(ZAshG1KcvCgMBXBwlzvz6FrUHB6xtYcZ5eQtHKGusO)f5gUP)Xmgdlu0at0p37yMHP6rDkKqmLe6FrUHB6FKbsgmyTk9Z9oMzyQEuNczePKq)CVJzgMQh9JaMZaBPF0Jfs25QlM1HES6ioToO1rUoUzG6uWTew4yrYoxDeNwhPcrK(xKB4M(xaABw4yaGBN6uijqusO)f5gUP)SP(4sbeqdwnHBN(5EhZmmvpQtHecIsc9Vi3Wn9RyaEmJXW0p37yMHP6rDkKXikj0)ICd30)2iw6GnlqBot)CVJzgMQh1PqgpusO)f5gUPFhRHEeyfbmV(d9Z9oMzyQEuN60)lGr4KX1PKqHekLe6N7DmZWu9Oofs9PKq)CVJzgMQh1Pqsqkj0p37yMHP6rDkKqmLe6N7DmZWu9OofYisjH(xKB4M(FXUHB6N7DmZWu9OofsceLe6FrUHB6h9yIrnG0PFU3Xmdt1J6uiHGOKq)lYnCt)OhteDjIPFU3Xmdt1J6uN(LScLekKqPKq)CVJzgMQh9Vi3Wn97MkdeVBoH(raZzGT0FS19cyIeQi4a0GBQmq8U5K6ixxS19cyIeQi4a0a3mq1iaRvfC2MZa1rUoUzG6uDP1XnduNcj7C1rUo0Jv381bL(rtOml8fOYUKcjuQtHuFkj0p37yMHP6r)lYnCt)OnNflYnClYM0P)SjDrVjm9JGPofscsjH(5EhZmmvp6hbmNb2s)Xw3OMIsq6yqIGxG)i2gwOyaoO9s)lYnCt)shdse8c8hX2WcfdWuN60)IzkjuiHsjH(5EhZmmvp6FrUHB6hT5SyrUHBr2Ko9NnPl6nHPFem1PqQpLe6N7DmZWu9OFeWCgyl9hBDVaMiHkcoan4MkdeVBoPoY1HES6MpToO1rUosxhcJZW4ODaysRvfsTwmyOHaGtwRL1LwhPQtxDRJ015BMBpOysxGve(dlI(yolCtLbbU3Xmdxh56qyCgghTdkM0fyfH)WIOpMZc3uzqaWjR1Y6sRJu1PJ60v364MbQt1nFDrKu1Pd6FrUHB6NBgOAeG1QcoBZzaQtHKGusOFU3Xmdt1J(raZzGT0p6Xcj7C1fZ6qpwDeNwh06ixh3mqDk4wclCSizNRoItRJuHis)lYnCt)laTnlCmaWTtDkKqmLe6N7DmZWu9OFeWCgyl97BMBpiza3Mpf4EhZmCDKRl26yDQM9(YWbyG1dwRkEWGwGWeXG6ixhcJZW4ODqYaUnFka4K1AzDeNwxeRJCDCZa1PGBjSWXIKDU6iUo9P)f5gUPFft6sbwrOObMOofYisjH(5EhZmmvp6hbmNb2s)(M52dsgWT5tbU3Xmdxh56yDQM9(YWbyG1dwRkEWGwGWeXG6ixhPRdHXzyC0oiza3MpfaCYATSoItRdAeRtxDRdHXzyC0oiza3MpfaCYATSU5tRdIRth1rUoUzG6uWTew4yrYoxDexN(0)ICd30VIjDPaRiu0atuNcjbIsc9Z9oMzyQE0pcyodSL(JToFZC7bjd428Pa37yMHRJCDCZa1PGBjSWXIKDU6iUo9P)f5gUPFft6sbwrOObMOofsiikj0p37yMHP6r)iG5mWw6hHXzyC0oamP1QcPwlgm0qaWjR1Y6ioTocgIyDKRd9y1nFADrK(xKB4M(vmPlfyfHIgyI6uiJrusO)f5gUP)OpgiBTQagSQ4w8Q1Oh6N7DmZWu9OofY4Hsc9Z9oMzyQE0)ICd30pWKwRkKATyWqd0pcyodSL(ryCgghTdrFmq2AvbmyvXT4vRrpbaNSwlRJ406urW1rUUyR7fWejurWbObGjTwvi1AXGHgQJCDimodJJ2bft6sbwrOObMcaozTwwhX1PIGPF0ekZcFbQSlPqcL6uiHskkj0p37yMHP6r)iG5mWw6h9y1nFADeSoY1r66qyCgghTdatATQqQ1IbdneaCYATSoItRlI1PRU1HW4mmoAhI(yGS1QcyWQIBXRwJEcaozTwwhXP1fX60rDKRJBgOofClHfowKSZvhX1bL(xKB4M(rpMyudiDQtHekukj0)ICd30p6XeJAaPt)CVJzgMQh1PqcvFkj0p37yMHP6r)iG5mWw6N01Ti3iIfCZjglRJ406iyD6QBDKUUrnfLWiEq8cWOG2BDKRd9yHKDU6IzDOhRoItRJu1PJ60rDKRl26EbmrcveCaAq(ADBTQab2MfdgAOoY1jzxmIBnzWngOpube)IO)f5gUPF5R1T1QceyBwmyObQtHekbPKq)CVJzgMQh9JaMZaBP)f5grSGBoXyzDeNwhbRJCDXw3lGjsOIGdqdYxRBRvfiW2SyWqd0)ICd30V8162AvbcSnlgm0a1PqcfIPKq)CVJzgMQh9Vi3Wn9pMx0awZfdgAG(raZzGT0FS19cyIeQi4a0WyErdynxmyOH6ixh6Xcj7C1fZ6qpwDeNwh06ixNKDXiU1Kb3yG(qfq8lQoY1r66IToj7IrCRjdUXaOXJq)xuD6QBD(M52dsgWT5tbU3XmdxNoOF0ekZcFbQSlPqcL6uiHgrkj0p37yMHP6r)lYnCt)J5fnG1CXGHgOFeWCgyl9t66qpwDexh060v36g1uucJ4bXlaJcAV1PRU1r668nZTh4MbQgbyTQGZ2CgiW9oMz46ixhcJZW4ODGBgOAeG1QcoBZzGaGtwRL1nFDimodJJ2bft6sbwrOObMcaozTwwNoQth1rUosxhPRdHXzyC0oamP1QcPwlgm0qaWjR1Y6iUoO1rUosxxS15BMBpOysxGve(dlI(yolCtLbbU3XmdxNU6whcJZW4ODqXKUaRi8hwe9XCw4MkdcaozTwwhX1bToDuNU6wh6XQJ46G460rDKRJ01HW4mmoAhumPlfyfHIgyka4K1AzDexh060v36qpwDexN(1PJ60v36EbmrcveCaAWnvgiE3CsD6OoY1fBDVaMiHkcoanmMx0awZfdgAG(rtOml8fOYUKcjuQtHekbIsc9Z9oMzyQE0pcyodSL(zDQM9(YWb)HfCYldWaPaTVlYCmOoY1nQPOe8hwWjVmadKc0(UiZXGG0x0qDeNwh04PoY1XnduNcULWchls25QJ46ii9Vi3Wn9JalAiBTQacSWSiBQpEBTk1PqcfcIsc9Z9oMzyQE0pcyodSL(zDQM9(YWb)HfCYldWaPaTVlYCmOoY1nQPOe8hwWjVmadKc0(UiZXGG0x0qDeNwhuiUoY1HW4mmoAhKmGBZNcaozTww381bLG1rUoFZC7bjd428Pa37yMHRJCDCZa1PGBjSWXIKDU6iUocs)lYnCt)iWIgYwRkGalmlYM6J3wRsDkKqJrusOFU3Xmdt1J(xKB4M(hZlAaR5Ibdnq)iG5mWw6p26EbmrcveCaAymVObSMlgm0qDKRd9yHKDU6IzDOhRoItRdADKRtYUye3AYGBmqFOci(fvh56g1uucJ4bXlaJcAV0pAcLzHVav2LuiHsDkKqJhkj0p37yMHP6r)lYnCt)UPYaX7MtOFeWCgyl9hBDVaMiHkcoan4MkdeVBoPoY1fBDVaMiHkcoanWnduncWAvbNT5mqDKRJ01HESqYoxDXSo0JvhXP1PFD6QBDCZa1PGBjSWXIKDU6MVocwNoOF0ekZcFbQSlPqcL6ui1NuusOFU3Xmdt1J(xKB4M(DtLbI3nNq)iG5mWw6p26EbmrcveCaAWnvgiE3CsDKRl26EbmrcveCaAGBgOAeG1QcoBZzG6ixh3mqDk4wclCSizNRU5tRdADKRd9yHKDU6IzDOhRoItRtF6hnHYSWxGk7skKqPofs9HsjH(5EhZmmvp6hbmNb2s)OhRU5tRJG1rUosxhcJZW4ODaysRvfsTwmyOHaGtwRL1rCADrSoD1ToegNHXr7q0hdKTwvadwvClE1A0taWjR1Y6ioTUiwNoQJCDCZa1PGBjSWXIKDU6iUoO0)ICd30p6XerxIyQtHuF9PKq)lYnCt)OhteDjIPFU3Xmdt1J6ui1NGusOFU3Xmdt1J(raZzGT0FS1j5mJCd31rUUxatKqfbhGgCtLbI3nNq)lYnCt)UPYaX7MtOo1PFjd428jb(LBg8HikjuiHsjH(5EhZmmvp6hbmNb2s)JAkkbjd428PamoAt)lYnCt)kM0fyfH)WIOpMZc3uza1PqQpLe6N7DmZWu9O)f5gUPF3uzG4DZj0pcyodSL(h1uucsgWT5tbyC0UoY1HES6MVoiM(rtOml8fOYUKcjuQtHKGusOFU3Xmdt1J(raZzGT0)OMIsqYaUnFkaJJ20)ICd30pAZzXICd3ISjD6pBsx0Bct)iyQtHeIPKq)CVJzgMQh9JaMZaBP)rnfLWygJHZAspaJJ20)ICd30pAZzXICd3ISjD6pBsx0Bct)sgWT5tuNczePKq)lYnCt)sgWT5t0p37yMHP6rDkKeikj0p37yMHP6r)lYnCt)atATQqQ1Ibdnq)OjuMf(cuzxsHek1PqcbrjH(5EhZmmvp6hbmNb2s)JAkkbjd428PaGtwRL1nFDqP)f5gUPFft6sbwrOObMOofYyeLe6N7DmZWu9O)f5gUP)X8IgWAUyWqd0pcyodSL(JTUxatKqfbhGggZlAaR5Ibdnuh56qyCgghTdatATQqQ1IbdneaCYATSoItRt)6ixhcJZW4ODqXKUuGvekAGPaGtwRL1rCAD6t)OjuMf(cuzxsHek1PqgpusOFU3Xmdt1J(xKB4M(hZlAaR5Ibdnq)OjuMf(cuzxsHek1Po9dZkRw2PKqHekLe6FrUHB6F1CSyDFrd0p37yMHP6rDkK6tjH(xKB4M(LV8cepBdlKoWgy6N7DmZWu9OofscsjH(5EhZmmvp6hbmNb2s)XwNVzU9abogdl05lizdCVJzgM(T2zarBM(Jhsr)Vix8WB2FOFsfIi9Vi3Wn97yn0JaRigwqYsDkKqmLe6N7DmZWu9OFeWCgyl97BMBpOIXWIHfKSbU3Xmdxh56g1uucJzmgoRj9amoAxh56ClHRJ46Gs)w7mGOnt)XdPO)xKlE4n7p0p0aPO)f5gUPFhRHEeyfXWcswQtHmIusOFU3Xmdt1J(raZzGT0VVzU9GkgdlgwqYg4EhZmCDKR7fWejurWbObhRHEeyfbmV(tDKRButrjmMXy4SM0dAV0V1odiAZ0F8qk6)f5IhEZ(d9dnqk6FrUHB63XAOhbwrmSGKL6uijqusOFU3Xmdt1J(raZzGT0)OMIsqYaUnFkO9wNU6w3OMIsq6yqIGxG)i2gwOyaoO9wNU6whPRl268nZThKmGBZNcCVJzgUoY15aRhyp8cWOWQAzZNcaErED6OoD1TUrnfLWygJHZAspa4f51PRU15lqL9GBjSWXcyJRB(06iqKI(xKB4M(FXUHBQtHecIsc9Z9oMzyQE0pcyodSL(9fOYEWTew4ybSX1nFADXd9Vi3Wn97yn0JaRiG51FOofYyeLe6N7DmZWu9OFeWCgyl9t66iDD(M52dsgWT5tbU3Xmdxh56qyCgghTdsgWT5tbaNSwlRB(06ivD6OoD1TUrnfLGKbCB(uq7ToDuh56wcGbMZbzutXfaSwd)G1KCaS9qDexh06ixNBjCDexhbjf9Vi3Wn9J2CwSi3WTiBsN(ZM0f9MW0VKbCB(0hIOofY4Hsc9Z9oMzyQE0pcyodSL(jDDKUUyRBjagyohKrnfxaWAn8dwtYbU3Xmdxh568nZThKmGBZNcCVJzgUoY1HW4mmoAhKmGBZNcaozTww38P1rQ60rD6QBDJAkkbjd428PG2BD6OoY15wcxhX1rqsr)lYnCt)OnNflYnClYM0P)SjDrVjm9lza3MprDkKqjfLe6N7DmZWu9OFeWCgyl9t668nZThKmGBZNcCVJzgUoY1HW4mmoAhKmGBZNcaozTww38P1rQ60v36g1uucsgWT5tbT360rDKRZTeUU5RJGKQoY1TeadmNdYOMIlayTg(bRj5a37yMHP)f5gUPF0MZIf5gUfzt60F2KUO3eM(LmGBZNe4xUzWhIOofsOqPKq)CVJzgMQh9JaMZaBPFsxxS1TeadmNdYOMIlayTg(bRj5a37yMHRJCD(M52dsgWT5tbU3Xmdxh56qyCgghTdsgWT5tbaNSwlRB(06ivD6QBDJAkkbjd428PG2BD6OoY15wcx381rqsr)lYnCt)OnNflYnClYM0P)SjDrVjm9lza3MpjWVCZaQtHeQ(usOFU3Xmdt1J(raZzGT0FS15BMBpiza3Mpf4EhZmCDKRJ01nQPOeKogKi4f4pITHfkgGdAV1PRU1HW4mmoAhKogKi4f4pITHfkgGdONfOYY6sRt)60b9Vi3Wn9J2CwSi3WTiBsN(ZM0f9MW0VKvOofsOeKsc9Z9oMzyQE0pcyodSL(jDDXwNVzU9GKbCB(uG7DmZW1rUoegNHXr7GIjDPaRiu0atbaNSwlRB(06GQFDKRd9y1rCADeSoY1HW4mmoAhaM0AvHuRfdgAia4K1AzDZNwh060rD6QBD(cuzp4wclCSa246MpTo9JyD6QBDimodJJ2bhRHEeyfbmV(taWjR1Y6iUoOq1N(xKB4M(rBolwKB4wKnPt)zt6IEty6xYkuNcjuiMsc9Z9oMzyQE0pcyodSL(jDDXwNVzU9GKbCB(uG7DmZW1rUUyRJ1PA27ldhGbwpyTQ4bdAbctedQJCDimodJJ2bft6sbwrOObMcaozTww38P1rGQJCDOhRoItRJG1rUoegNHXr7aWKwRkKATyWqdbaNSwlRB(06GwNoQtxDRZxGk7b3syHJfWgx38P1bnI1PRU1HW4mmoAhCSg6rGveW86pbaNSwlRJ46Gcv)6ixhcJZW4ODq6yqIGxG)i2gwOyaoGEwGklRlToO0)ICd30pAZzXICd3ISjD6pBsx0Bct)swH6uiHgrkj0p37yMHP6r)iG5mWw6N01fBD(M52dsgWT5tbU3Xmdxh56qyCgghTdkM0LcSIqrdmfaCYATSU5tRdQ(1rUo0JvhXP1rW6ixhcJZW4ODaysRvfsTwmyOHaGtwRL1nFADqRth1PRU15lqL9GBjSWXcyJRB(060pI1PRU1HW4mmoAhCSg6rGveW86pbaNSwlRJ46Gcv)6ixhcJZW4ODq6yqIGxG)i2gwOyaoGEwGklRlToO0)ICd30pAZzXICd3ISjD6pBsx0Bct)swH6uiHsGOKq)CVJzgMQh9JaMZaBP)f5grSGBoXyzDexhbP)f5gUPFGwlwKB4wKnPt)zt6IEty6FXm1PqcfcIsc9Z9oMzyQE0pcyodSL(xKBeXcU5eJL1nFADeK(xKB4M(bATyrUHBr2Ko9NnPl6nHPFPtDQtD6NiginCtHuFsbngrQyK(KkanE0hIP)OlOTwvs)X46eicscmGKapgwxDK8W1zjVyGxNcguxmaMvwTShdQdW6undWW1jXjCDRMJtwNHRd9STkld1mcSwZ1bngwxmMwQ9(Ibodx3ICd31fdwnhlw3x0qmiuZQzeyK8Ibodxhusv3ICd31LnPld1m6F18hmG()wces)VaSILz6pc1f)ZXinNHRBKvWaUoeozC96gzvRLH60jie)6Y6AChZNfKOOLRBrUHBzD4opfQzlYnCldVagHtgxpvjVYHA2ICd3YWlGr4KX1JlnsfmgUMTi3WTm8cyeozC94sJC1ut42x3WDnlc1979v(G96aRbx3OMIcdxN0xxw3iRGbCDiCY461nYQwlRBB46EbCmFXUBTADMSoyCZHA2ICd3YWlGr4KX1JlnszVVYhSlK(6YA2ICd3YWlGr4KX1JlnYxSB4UMTi3WTm8cyeozC94sJe9yIrnG0RzlYnCldVagHtgxpU0irpMi6sexZQzrOU4FogP5mCDmrmyQo3s468hUUf5yqDMSULO1Y7yMd1Sf5gULPRMJfR7lAOMTi3WTmU0iLV8cepBdlKoWg4AweQJeSg6PoSsD68fKS1H76qyCgghTjSotPocCmgUoD(cs26mzDCVJzgUowNQT56CCDqjfPIXUoSsDj7CwIwsDp8M9NA2ICd3Y4sJ0XAOhbwrmSGKLqRDgq0MtJhsr4lYfp8M9NusfIiHMsAS(M52de4ymSqNVGKnW9oMzycT2zarBonEifHVix8WB2FsjviI1Sf5gULXLgPJ1qpcSIyybjlHw7mGOnNgpKIWxKlE4n7pPqdKIqtj13m3EqfJHfdlizdCVJzgM8OMIsymJXWznPhGXrBYULWedTMTi3WTmU0iDSg6rGvedlizj0ANbeT504Hue(ICXdVz)jfAGueAkP(M52dQymSyybjBG7DmZWKFbmrcveCaAWXAOhbwraZR)qEutrjmMXy4SM0dAV1SiuNod7gURZuQ7ZaUnFQomOUVJbjewx8Va)HW62gUU4ZaCDlGRt7TomOUjSwDlGRdO1T1Q1jza3Mpv32W1T1LSwxN0xVohy9a719cWijH1Hb1nH1QBbCDAnmdQZF46yffg51HvQBmJXWznPtyDyqD(cuzVo3s46CCDWgxNjRtfWRZG6WG6yDQ2MRZX1rGivnBrUHBzCPr(IDd3eAkPJAkkbjd428PG2RU6oQPOeKogKi4f4pITHfkgGdAV6QlPJ13m3EqYaUnFkW9oMzyYoW6b2dVamkSQw28PaGxKRdD1DutrjmMXy4SM0daErUU66lqL9GBjSWXcyJNpLarQA2ICd3Y4sJ0XAOhbwraZR)qOPK6lqL9GBjSWXcyJNpnEQzrOoiCZ568hUUpd428P6wKB4UUSj96mL6MWAXaaxNM0A16(mGBZNQBB46EwI46sWaUo)z768O46aBpiRdRu3pQP41bryTg(bRj56ibSMxZwKB4wgxAKOnNflYnClYM0jS3eovYaUnF6dreAkPKM0(M52dsgWT5tbU3XmdtgHXzyC0oiza3MpfaCYATC(usPdD1Dutrjiza3Mpf0E1b5LayG5Cqg1uCbaR1WpynjhaBpqmuYULWetqsvZIqDq4MZ15pCDFgWT5t1Ti3WDDzt61zk1nH1IbaUonP1Q19za3Mpv32W19za3MpvNjRBjAT8oM56ingu3ewlga46qAaa3EEQoRR7ZaUnFsh1Sf5gULXLgjAZzXICd3ISjDc7nHtLmGBZNi0usjnPJDjagyohKrnfxaWAn8dwtYbU3Xmdt23m3EqYaUnFkW9oMzyYimodJJ2bjd428PaGtwRLZNskDORUJAkkbjd428PG2Roi7wctmbjvnlc1bHBoxN)W19za3Mpvx86LBgu3ICd31LnPxNPu3ewlga460KwRw3NbCB(uDBdx3ZsexxcgW15pBxNhfxhy7bzDyL6(rnfVoicR1WpynjxhjG18A2ICd3Y4sJeT5SyrUHBr2KoH9MWPsgWT5tc8l3m4dreAkPK23m3EqYaUnFkW9oMzyYimodJJ2bjd428PaGtwRLZNskD1Dutrjiza3Mpf0E1bz3s45jiPiVeadmNdYOMIlayTg(bRj5a37yMHRzrOoiCZ568hUUpd428P6IxVCZG6wKB4UUSj96mL6MWAXaaxNM0A16(mGBZNQBB46(mGBZNQZK1TeTwEhZCDKgdQBcRfdaCDinaGBppvN119za3MpPJA2ICd3Y4sJeT5SyrUHBr2KoH9MWPsgWT5tc8l3mGqtjL0XUeadmNdYOMIlayTg(bRj5a37yMHj7BMBpiza3Mpf4EhZmmzegNHXr7GKbCB(uaWjR1Y5tjLU6oQPOeKmGBZNcAV6GSBj88eKu1SiuheU5CD(dx3p(JV6wKB4UUSj96mL6MWAXaaxNM0A16(XF8v32W1TaUoKgaWTNNQZ66(XF8vhgu3ZsexN(19J)4RoPVObznBrUHBzCPrI2CwSi3WTiBsNWEt4ujRqOPKgRVzU9GKbCB(uG7DmZWKj9OMIsq6yqIGxG)i2gwOyaoO9QRUimodJJ2bPJbjcEb(JyByHIb4a6zbQSmvFDuZIqDq4MZ15pCD)4p(QBrUH76YM0RZuQBcRfdaCDn2RttATADFgWT5t1TnCmSMfH6IzDXho(Qdbx38P1bv)AweQlM1bHpwDeNwhbRzrOUywhe9151HGRJ406GwZIqDXliQo)HRZxGk71f1Y56GnUUOM)yDD6hX6Kmc3WY6IxquDKGJ31zY6WDD(dxNVav2RzlYnClJlns0MZIf5gUfzt6e2BcNkzfcnLushRVzU9GKbCB(uG7DmZWKryCgghTdkM0LcSIqrdmfaCYATC(uO6tg9yeNsqYimodJJ2bGjTwvi1AXGHgcaozTwoFkuDORU(cuzp4wclCSa245t1pI6QlcJZW4ODWXAOhbwraZR)eaCYATKyOq1VMfH6GWnNRZF46(XF8v3ICd31LnPxNPu3ewlga460KwRw3NbCB(uDBdhdRzrOUywxmgP1Q1fVJXccRzrOUywx8HJV6qW1nFADeOAweQlM1bHpwDeNwhbRzrOUywhe9151HGRB(06GwZIqDXliQo)HRZxGk71f1Y56GnUUOM)yDDqJyDsgHByzDXliQosWX76mzD4Uo)HRZxGk71TnCDtyT6EwI46GwN0x0qDyL6(XF8vZwKB4wgxAKOnNflYnClYM0jS3eovYkeAkPKowFZC7bjd428Pa37yMHjhlRt1S3xgoadSEWAvXdg0ceMigqgHXzyC0oOysxkWkcfnWuaWjR1Y5tjqKrpgXPeKmcJZW4ODaysRvfsTwmyOHaGtwRLZNcvh6QRVav2dULWchlGnE(uOruxDryCgghTdowd9iWkcyE9NaGtwRLedfQ(KryCgghTdshdse8c8hX2WcfdWb0Zcuzzk0AweQl(NBrEEQo)HRtUjCDRSUxatKH1K1LTMjSUrnVUOM)u321TWWmCDOhgnux0h2FyqDtyT6EwI46GwN0x0qDyL6(XF8vZwKB4wgxAKOnNflYnClYM0jS3eovYkeAkPKowFZC7bjd428Pa37yMHjJW4mmoAhumPlfyfHIgyka4K1A58Pq1Nm6XioLGKryCgghTdatATQqQ1IbdneaCYATC(uO6qxD9fOYEWTew4ybSXZNQFe1vxegNHXr7GJ1qpcSIaMx)ja4K1AjXqHQpzegNHXr7G0XGebVa)rSnSqXaCa9SavwMcTMfH6GWnNRZF460j44VUf5gURlBsVotPo)HbCDlGRlbd468NTRJG1XnNySSMTi3WTmU0ibATyrUHBr2KoH9MWPlMj0usxKBeXcU5eJLetWAweQdc3CUo)HR7tsDlYnCxx2KEDMsD(dd46waxhbRddQlZszDCZjglRzlYnClJlnsGwlwKB4wKnPtyVjCQ0j0usxKBeXcU5eJLZNsWAwnlc1PtqUHBzqNGJ)6mzDw7CdZW1PGb1Pj56IA(tDXyXi3qcDcmSacZ8sex32W1H0aaU98uDnZWY6CCDJCD4x3smcGHRzlYnCldlMtrBolwKB4wKnPtyVjCkcUMTi3WTmSyoU0i5MbQgbyTQGZ2CgGqtjn2xatKqfbhGgCtLbI3nNqg9yZNcLmPryCgghTdatATQqQ1IbdneaCYATmLu6QlP9nZThumPlWkc)HfrFmNfUPYGa37yMHjJW4mmoAhumPlWkc)HfrFmNfUPYGaGtwRLPKsh6Ql3mqDA(iskDuZwKB4wgwmhxAKlaTnlCmaWTtOPKIESqYoxmrpgXPqjZnduNcULWchls25ioLuHiwZwKB4wgwmhxAKkM0LcSIqrdmrOPK6BMBpiza3Mpf4EhZmm5yzDQM9(YWbyG1dwRkEWGwGWeXaYimodJJ2bjd428PaGtwRLeNgrYCZa1PGBjSWXIKDoI1VMTi3WTmSyoU0ivmPlfyfHIgyIqtj13m3EqYaUnFkW9oMzyYSovZEFz4amW6bRvfpyqlqyIyazsJW4mmoAhKmGBZNcaozTwsCk0iQRUimodJJ2bjd428PaGtwRLZNcX6Gm3mqDk4wclCSizNJy9RzlYnCldlMJlnsft6sbwrOObMi0usJ13m3EqYaUnFkW9oMzyYCZa1PGBjSWXIKDoI1VMTi3WTmSyoU0ivmPlfyfHIgyIqtjfHXzyC0oamP1QcPwlgm0qaWjR1sItjyiIKrp28PrSMTi3WTmSyoU0iJ(yGS1QcyWQIBXRwJEQzlYnCldlMJlnsGjTwvi1AXGHgienHYSWxGk7YuOeAkPimodJJ2HOpgiBTQagSQ4w8Q1ONaGtwRLeNQIGjh7lGjsOIGdqdatATQqQ1IbdnqgHXzyC0oOysxkWkcfnWuaWjR1sIvrW1Sf5gULHfZXLgj6XeJAaPtOPKIES5tjizsJW4mmoAhaM0AvHuRfdgAia4K1AjXPruxDryCgghTdrFmq2AvbmyvXT4vRrpbaNSwljonI6Gm3mqDk4wclCSizNJyO1Sf5gULHfZXLgj6XeJAaPxZwKB4wgwmhxAKYxRBRvfiW2SyWqdeAkPKErUrel4MtmwsCkb1vxspQPOegXdIxagf0EjJESqYoxmrpgXPKsh6GCSVaMiHkcoaniFTUTwvGaBZIbdnqwYUye3AYGBmqFOci(fvZwKB4wgwmhxAKYxRBRvfiW2SyWqdeAkPlYnIyb3CIXsItji5yFbmrcveCaAq(ADBTQab2MfdgAOMTi3WTmSyoU0ihZlAaR5IbdnqiAcLzHVav2LPqj0usJ9fWejurWbOHX8IgWAUyWqdKrpwizNlMOhJ4uOKLSlgXTMm4gd0hQaIFrKjDSs2fJ4wtgCJbqJhH(ViD113m3EqYaUnFkW9oMzyDuZwKB4wgwmhxAKJ5fnG1CXGHgienHYSWxGk7YuOeAkPKg9yedvxDh1uucJ4bXlaJcAV6QlP9nZTh4MbQgbyTQGZ2CgiW9oMzyYimodJJ2bUzGQrawRk4SnNbcaozTwopcJZW4ODqXKUuGvekAGPaGtwRL6qhKjnPryCgghTdatATQqQ1IbdneaCYATKyOKjDS(M52dkM0fyfH)WIOpMZc3uzqG7DmZW6QlcJZW4ODqXKUaRi8hwe9XCw4MkdcaozTwsmuDORUOhJyiwhKjncJZW4ODqXKUuGvekAGPaGtwRLedvxDrpgX6RdD19fWejurWbOb3uzG4DZj6GCSVaMiHkcoanmMx0awZfdgAOMTi3WTmSyoU0irGfnKTwvabwywKn1hVTwLqtjL1PA27ldh8hwWjVmadKc0(UiZXaYJAkkb)HfCYldWaPaTVlYCmii9fnqCk04Hm3mqDk4wclCSizNJycwZwKB4wgwmhxAKiWIgYwRkGalmlYM6J3wRsOPKY6un79LHd(dl4KxgGbsbAFxK5ya5rnfLG)Wco5LbyGuG23fzogeK(IgiofketgHXzyC0oiza3MpfaCYATCEOeKSVzU9GKbCB(uG7DmZWK5MbQtb3syHJfj7CetWA2ICd3YWI54sJCmVObSMlgm0aHOjuMf(cuzxMcLqtjn2xatKqfbhGggZlAaR5Ibdnqg9yHKDUyIEmItHswYUye3AYGBmqFOci(frEutrjmIheVamkO9wZwKB4wgwmhxAKUPYaX7MtienHYSWxGk7YuOeAkPX(cyIeQi4a0GBQmq8U5eYX(cyIeQi4a0a3mq1iaRvfC2MZaKjn6Xcj7CXe9yeNQVU6YnduNcULWchls25MNG6OMTi3WTmSyoU0iDtLbI3nNqiAcLzHVav2LPqj0usJ9fWejurWbOb3uzG4DZjKJ9fWejurWbObUzGQrawRk4SnNbiZnduNcULWchls25Mpfkz0Jfs25Ij6Xiov)A2ICd3YWI54sJe9yIOlrmHMsk6XMpLGKjncJZW4ODaysRvfsTwmyOHaGtwRLeNgrD1fHXzyC0oe9XazRvfWGvf3IxTg9eaCYATK40iQdYCZa1PGBjSWXIKDoIHwZwKB4wgwmhxAKOhteDjIRzlYnCldlMJlns3uzG4DZjeAkPXk5mJCd3KFbmrcveCaAWnvgiE3CsnRMTi3WTmGGtTMi8alMtJBH)WIOpMZc3uzqnBrUHBzabhxAKAswyoNqyVjCAwt6aSMuOIZWClEZAjRkxZwKB4wgqWXLg5ygJHfkAGPA2ICd3YacoU0ihzGKbdwRwZIqDXyKCD6eaABUosWaa3EDMsDtyT6waxxIjLwRw361L5v61bToi8XQBB46II7yGxhAFRJBgOovxuZFSUosfIyDsgHByznBrUHBzabhxAKlaTnlCmaWTtOPKIESqYoxmrpgXPqjZnduNcULWchls25ioLuHiwZwKB4wgqWXLgz2uFCPacObRMWTxZwKB4wgqWXLgPIb4XmgdxZwKB4wgqWXLg52iw6GnlqBoxZwKB4wgqWXLgPJ1qpcSIaMx)PMvZwKB4wgKSsQBQmq8U5ecrtOml8fOYUmfkHMsASVaMiHkcoan4MkdeVBoHCSVaMiHkcoanWnduncWAvbNT5mazUzG6uk3mqDkKSZrg9yZdTMTi3WTmizL4sJeT5SyrUHBr2KoH9MWPi4A2ICd3YGKvIlnsPJbjcEb(JyByHIbycnL0yh1uucshdse8c8hX2WcfdWbT3AwnBrUHBzqYaUnFk1nvgiE3CcHOjuMf(cuzxMcLqtjn2xatKqfbhGgCtLbI3nNqo2xatKqfbhGg4MbQgbyTQGZ2CgGm3mqDkLBgOofs25iJES5Hso2rnfLGKbCB(uq7TMTi3WTmiza3MpfxAKOnNflYnClYM0jS3eofbxZIqDqYmSSohx3ixhGJcm35UofmOo9IpDsnBrUHBzqYaUnFkU0ibAYhRvfqGfMfrTgMqtj13m3EaOjFSwvabwywe1A4a37yMHjh7lGjsOIGdqdan5J1QciWcZIOwdtEutrja0KpwRkGalmlIAnCaghTRzlYnCldsgWT5tXLgPKbCB(eHMskcJZW4ODaysRvfsTwmyOHaGtwRLZNQpzegNHXr7GIjDPaRiu0atbaNSwlNpfIRzlYnCldsgWT5tXLgPIjDPaRiu0ateAkPVaMiHkcoanamP1QcPwlgm0a5xatKqfbh0piza3MpvZwKB4wgKmGBZNIlnsft6sbwrOObMi0ush1uucsgWT5tbaNSwlNpfAGurSMTi3WTmiza3MpfxAKatATQqQ1IbdnqiAcLzHVav2LPqRzlYnCldsgWT5tXLgPIjDbwr4pSi6J5SWnvgqOPK(cyIeQi4a0WyErdynxmyObYVaMiHkcoOFaysRvfsTwmyObYOhlKSZft0JrS(1Sf5gULbjd428P4sJ0nvgiE3CcHOjuMf(cuzxMcLqtj9fWejurWbOHX8IgWAUyWqdKFbmrcveCq)aWKwRkKATyWqdKrpwizNlMOhJyO1Sf5gULbjd428P4sJCmVObSMlgm0aHOjuMf(cuzxMcLqtjn2xatKqfbhGggZlAaR5IbdnqgHXzyC0oamP1QcPwlgm0qaWjR1sIt1NmcJZW4ODqXKUuGvekAGPaGtwRLeNQFnBrUHBzqYaUnFkU0iLVw3wRkqGTzXGHgi0usxKBeXcU5eJLeNsqYX(cyIeQi4a0G8162AvbcSnlgm0qnBrUHBzqYaUnFkU0ibM0AvHuRfdgAGq0ekZcFbQSltHwZwKB4wgKmGBZNIlns5R1T1QceyBwmyObcnL0yFbmrcveCaAq(ADBTQab2MfdgAOMTi3WTmiza3MpfxAKJ5fnG1CXGHgienHYSWxGk7YuOeAkPX(cyIeQi4a0WyErdynxmyOHAwnBrUHBzqYaUnF6drPUPYaX7MtienHYSWxGk7YuOeAkPX(cyIeQi4a0GBQmq8U5eYX(cyIeQi4a0a3mq1iaRvfC2MZaK5MbQtPCZa1PqYohz0JnpuYXoQPOeKmGBZNcAV1Sf5gULbjd428PpefxAKOnNflYnClYM0jS3eofbxZwKB4wgKmGBZN(quCPrkza3MprOPKIW4mmoAhaM0AvHuRfdgAia4K1A58P6xZwKB4wgKmGBZN(quCPrQysxkWkcfnWeHMs6OMIsqYaUnFka4K1A58PqdKkI1Sf5gULbjd428PpefxAKatATQqQ1IbdnqiAcLzHVav2LPqRzlYnCldsgWT5tFikU0ihZlAaR5IbdnqiAcLzHVav2LPqj0usJ9fWejurWbOHX8IgWAUyWqdKryCgghTdatATQqQ1IbdneaCYATK4u9jJW4mmoAhumPlfyfHIgyka4K1AjXP6xZwKB4wgKmGBZN(quCProMx0awZfdgAGq0ekZcFbQSltHwZQzlYnCldsgWT5tc8l3mivXKUaRi8hwe9XCw4Mkdi0ush1uucsgWT5tbyC0UMTi3WTmiza3MpjWVCZG4sJ0nvgiE3CcHOjuMf(cuzxMcLqtjn2xatKqfbhGgCtLbI3nNqEutrjiza3MpfGXrBYOhBEiUMTi3WTmiza3MpjWVCZG4sJeT5SyrUHBr2KoH9MWPiycnL0rnfLGKbCB(uaghTRzlYnCldsgWT5tc8l3miU0irBolwKB4wKnPtyVjCQKbCB(eHMs6OMIsymJXWznPhGXr7A2ICd3YGKbCB(Ka)YndIlnsjd428PA2ICd3YGKbCB(Ka)YndIlnsGjTwvi1AXGHgienHYSWxGk7YuO1Sf5gULbjd428jb(LBgexAKkM0LcSIqrdmrOPK(cyIeQi4a0aWKwRkKATyWqdKFbmrcveCq)GKbCB(unBrUHBzqYaUnFsGF5MbXLgPIjDPaRiu0ateAkPVaMiHkcoanamP1QcPwlgm0a5xatKqfbh0pmMx0awZfdgAOMTi3WTmiza3MpjWVCZG4sJCmVObSMlgm0aHOjuMf(cuzxMcLqtjn2xatKqfbhGggZlAaR5IbdnqgHXzyC0oamP1QcPwlgm0qaWjR1sIt1NmcJZW4ODqXKUuGvekAGPaGtwRLeNQFnBrUHBzqYaUnFsGF5MbXLg5yErdynxmyObcrtOml8fOYUmfkHMsASVaMiHkcoanmMx0awZfdgAOMvZwKB4wgKmGBZNe4xUzWhIsvmPlWkc)HfrFmNfUPYacnL0rnfLGKbCB(uaghTRzlYnCldsgWT5tc8l3m4drXLgPBQmq8U5ecrtOml8fOYUmfkHMs6OMIsqYaUnFkaJJ2Krp28qCnBrUHBzqYaUnFsGF5MbFikU0irBolwKB4wKnPtyVjCkcMqtjDutrjiza3MpfGXr7A2ICd3YGKbCB(Ka)Ynd(quCPrI2CwSi3WTiBsNWEt4ujd428jcnL0rnfLWygJHZAspaJJ21Sf5gULbjd428jb(LBg8HO4sJuYaUnFQMTi3WTmiza3MpjWVCZGpefxAKatATQqQ1IbdnqiAcLzHVav2LPqRzlYnCldsgWT5tc8l3m4drXLgPIjDPaRiu0ateAkPJAkkbjd428PaGtwRLZdTMTi3WTmiza3MpjWVCZGpefxAKJ5fnG1CXGHgienHYSWxGk7YuOeAkPX(cyIeQi4a0WyErdynxmyObYimodJJ2bGjTwvi1AXGHgcaozTwsCQ(KryCgghTdkM0LcSIqrdmfaCYATK4u9RzlYnCldsgWT5tc8l3m4drXLg5yErdynxmyObcrtOml8fOYUmfAnRMfH6I3SYQL96wKB4UUSj9A2ICd3YG0tTMi8alMtJBH)WIOpMZc3uzqnBrUHBzq6XLgPJ1qpcSIaMx)PMTi3WTmi94sJu6yqIGxG)i2gwOyaMqtjn2rnfLG0XGebVa)rSnSqXaCq7TMfH6IXi56GitATADFTUoDUHgQlQ5p1PFDsFrdY6Wk19HO6mL6233SH2XmxZwKB4wgKECPrcmP1QcPwlgm0aHOjuMf(cuzxMcLqtjDjagyohKrnfxaWAn8dwtYbU3XmdtEutrjiJAkUaG1A4hSMKdsFrdP6xZIqDqYmSSohx3ixhGJcm35UofmOo9IpDsnBrUHBzq6XLgjqt(yTQacSWSiQ1WeAkPJAkkbGM8XAvbeyHzruRHdW4On5yFbmrcveCaAaOjFSwvabwywe1A4A2ICd3YG0JlnsUzGQrawRk4SnNbi0usJ9fWejurWbOb3uzG4DZj1Siuhj6dToj71nIBnzDiCdBUH7nxZIqDq4k960lVObSMxNo3qd1zkXWAweQlM1PZamrgwtwhboegVRl6kRRXED6Lx0awZRtNBOHAweQlM1PxErdynVoDUHgITotw3s0A5DmZ1SiuxmRdcgRfdaCDn2RB96s25QdcFSA2ICd3YG0JlnYX8IgWAUyWqdeIMqzw4lqLDzkucnL0yFbmrcveCaAymVObSMlgm0az0Jfs25Ij6Xiofkzj7IrCRjdUXa9HkG4xe5rnfLWiEq8cWOG2Bnlc1bHR0Rl(WEmoj1zk1nH1QlQLZ1PUwxhbRddQlbd46GWhRMTi3WTmi94sJuXKUaRi8hwe9XCw4Mkdi0usjn6XMpvFDuZIqDq4k96iXuzqD6SnNuNPedRzrOUywNodWezynzDe4qy8UUORSUg71rIPYG60zBoPMfH6IzD6matKH1K1rGdHX76IUY6ASxx8h)1rAiJxKe)XW6amSwdVTx3iJwnjxhwPo)HRl(BgOovh6HrdewxZmSSohx3ixhGJcm35UofmOo9IpDIoQzrOUywhemwRUOwoxhAFRl(BgOov3iRGbCDnpNxhboegVRzrOUywhemwRUOwoxN6ADD6xhguxcgW1bHpwnBrUHBzq6XLgPBQmq8U5ecrtOml8fOYUmfkHMsk6XMpLGK5MbQtb3syHJfj7CZRFnBrUHBzq6XLgPBQmq8U5ecrtOml8fOYUmfkHMsk6Xcj7CXe9yeNQp5rnfLGKbCB(uaghTjJW4mmoAhumPlWkc)HfrFmNfUPYGaGtwRLeZnduNcULWchls25QzlYnCldspU0iJ(yGS1QcyWQIBXRwJEQzrOU4dhF1PjxvUUOM)u3pQP41bryTg(bRj5A2ICd3YG0Jlnsft6sbwrOObMi0usrpgXPeKm3mqDk4wclCSizNJy9drK8samWCoiJAkUaG1A4hSMKdGThMx)AweQdcxPxhezsRvR7R11PZn0qDMsmSMfH6IzDqWyT6waxNM0A16(XF8ryDBdx3ewRUNLiUocwhguxcgW1bHpwD6eiJ31bXKQomOUemGRJBgOovx8cIQlI1Hb1LGbCDq4JvZIqDXSoiySwDlGRttATADFgWT5tewhbQomOUemGRtYiCdlRdWjR11H768hUoegNHXr76Wk19za3MpryDBdx3ewRUNLiUocwhguxcgW1bHpwD6eiJ31bXKQomOUemGRJBgOovx8cIQlI1Hb1LGbCDq4JvxnBrUHBzq6XLgjWKwRkKATyWqdeIMqzw4lqLDzkucnLustA0JrCkbjZnduNiofIjLo0vx0JrCAe1bzs7BMBpiza3Mpf4EhZmSU6IW4mmoAhKmGBZNcaozTwsCkbshKJDjagyohKrnfxaWAn8dwtYbU3XmdxZIqDq4k96Ipt6Y6Wk1fFAGP6mLyynlc1fZ6GGXA1TaUonP1Q19J)4RMTi3WTmi94sJuXKUuGvekAGjcnL0y9nZThKmGBZNcCVJzgMmPxcGbMZbzutXfaSwd)G1KCaS9W86RRUimodJJ2HOpgiBTQagSQ4w8Q1ONaGtwRLZdLG6OMfH6GWv61brFDEDMsmSMfH6IzDqWyT6waxNM0A16(XF8vx8cIQBcRv3c460KwRw3NbCB(uDBdxxeRddQlbd46Kmc3WY6aCYADD4Uo)HRdHXzyC0UoSsDFgWT5t1Sf5gULbPhxAKatATQqQ1IbdnqiAcLzHVav2LPqj0usryCgghTdsgWT5tbaNSwljonI6QlPJ13m3EqYaUnFkW9oMzyDqo2LayG5Cqg1uCbaR1Wpynjh4EhZmCnlc1bHR0RtV8IgWAED6CdnuNPedRzrOUywNodWezynzDe4qy8UUORSUg71PhwNxZIqDXSoiySwDlGRRXEDRxxYoxDq4JvZwKB4wgKECProMx0awZfdgAGq0ekZcFbQSltHsOPKIW4mmoAhumPlfyfHIgyka4K1AjX6to2xatKqfbhGggZlAaR5IbdnqMBgOofClHfowKSZrmuYlbWaZ5GmQP4cawRHFWAsoa2EGyO1Siux8LNSwTUpdE52RtNBOH6uWG6swPZGP6aSKDznlc1Ti3WTmi94sJujpzTQqYGxUDXGHgi0usFbmrcveCaAymVObSMlgm0azUzG6uWTew4yrYohX6tg9yedLqRDga0E9uO1Sf5gULbPhxAKJ5fnG1CXGHgienHYSWxGk7YuOeAkPJAkkbzutXfaSwd)G1KCq6lAyE9jh7lGjsOIGdqdJ5fnG1CXGHgQzrOocSS6IMQtbdQJKhUU4p5LbyGSoiCFxK5yqnBrUHBzq6XLgjcSOHS1QciWcZISP(4T1QeAkPSovZEFz4G)Wco5LbyGuG23fzogqEutrj4pSGtEzagifO9DrMJbbPVObItHgpK5MbQtb3syHJfj7CetWA2ICd3YG0JlnseyrdzRvfqGfMfzt9XBRvj0uszDQM9(YWb)HfCYldWaPaTVlYCmG8OMIsWFybN8Yamqkq77ImhdcsFrdeNcfIjJW4mmoAhKmGBZNcaozTwopucs23m3EqYaUnFkW9oMzyYCZa1PGBjSWXIKDoIjynBrUHBzq6XLg5yErdynxmyObcrtOml8fOYUmfkHMsASVaMiHkcoanmMx0awZfdgAOMTi3WTmi94sJe9yIOlrCnlc1fJB5CDnZW1546g56aCuG5o31PGb1Px8PtQzrOoiuda42RdOL5yyDq4k96GWhRo90asVotjgwZIqDXSoiySwDplrCDeSomOUmlL1bHpwnlc1fZ6GOVoVotwN2BDwxxeRddQlbd46Kmc3WY6IxquDX4XBDwDMSoT36SUUiwhguxcgW1jzeUHL1SiuxmRdcgRvxulNRRXEDO9ToUzG6uDJScgW15pCDnpNxhboegVRzlYnCldspU0irpMyudiDcnLuUzG6uWTew4yrYohXqj7BMBpiza3Mpf4EhZmCnlc1bHR0RJetLb1PZ2CsDMsmSMfH6IzD6matKH1K1TJw28P6IUY6ASxhjMkdQtNT5K6WG6I)MbQgbyTADXF2MZa1SiuxmRdcgRvxulNRtDTUU1RlZR0Rt)6GWhJW6IxquDtyT6IA5CDO9ToUzG6uDrn)X66iyDsgHByzDKgY4fjXFmSoieRLHRdTsVos0z1XeXDDRxxeRdcFS6GaAsVohx3lGjIBVoUzG6uDO991AvcRZ668hgdM0rnBrUHBzq6XLgPBQmq8U5ecrtOml8fOYUmfkHMsASVaMiHkcoan4MkdeVBoHCSVaMiHkcoanWnduncWAvbNT5mazsJESqYoxmrpgXP6RRUCZa1PGBjSWXIKDU5jOoih7OMIsqYaUnFkO9wZwKB4wgKECPrIEmXOgq6eAkPOhlKSZft0JrCkbjZnduNcULWchls25igk5y9nZThKmGBZNcCVJzgUMTi3WTmi94sJ0nvgiE3CcHMsASsoZi3Wn5xatKqfbhGgCtLbI3nNqDQtP]] )
end