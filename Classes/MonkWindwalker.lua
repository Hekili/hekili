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

    spec:RegisterPack( "Windwalker", 20180825.2141,
        [[d4uG9bqirIhjvkxIeOk2ePYNePQ0Oir6uKQ4vIKMfGClrQSlQ8lQcdJeXXqklJuvpdGmnPs11ivPTbqX3ePQACufPohvr16OkkMNuj3te7dPQdscIfsI6HKGAIauQlscKnsvK8rsGYijbQQtksvHvkv8sQIsZKeOYnjbQs7eq9tQIOgkjiTusapvLMksLRksvrFLQiYzbOK9I4VOmyOoSIflQEmOjd0Lj2ms(mjnAv40uwTiv51IYSLYTPQ2TKFdz4svhNQiSCv9CunDHRtkBhaFNQ04fPCEv06bOA(Kq7xPj0i0rUGtieG1xj080kXtRVED6tR7kHM(KBC2lKB)aZgvHCRXxixpjRa9oTm5j3(5SHgqcDKlhP9qHCpION7z8Wdvlo0YDqKVhCZxRnHHk4puHhCZh6rEdL7ro1Koqbap6FeL1eUhk0xuGXa5EOqvaMcErvgZtYkqVtltEh38HKBUM1I0hfjNCbNqiaRVsO5PvINwF960Nw3vIsamKlVxGeG1hW45KlOWHKlDhgFXgFXXHSyqHA0AXI9KSc070YKFXdmmuT4(bMTyk0VyLNiAYIPq)IviaU8O4WTD2o0Dy8fB8fNpCbCXOAXXHSypjRa9oTm5xScrHQGBXupYFXxZxRnHHkf(hQaOfNRfl2RfhlMJ8LflGwWxCGwS53)iaKfluug0KcEUyRwCCilgIQqslwmIAXXHS4beevUTZ2jDlwHpMsvaxCmVQemJAXqubAHHk(Id0I14YIHNWMWI5vLGVyLgZRkbZOwCHIfZ167rFiG6XTDs3IV9nlw8vb5PwmaC3IVYlLfNlMRbpwCCmXIPeVYVyTsJp5nzXdmmuXxSxR1wCUSyiQ4gO8c4ITAXYapwCdH6xmIAXXHS4beevUTt6wScFmLQaUy40ASbggQynJhlwQ4nHVyk0VyfINScAXaWDl(s3Id0IFTInWWqfRz8yXsfVjCGwm3kOSyu1oxmQKf71ATfNllMlnbgc4INcCXXHCU45Lf7RfAtRDUyjnytJBaiUTt6wSci(iaeWft1oTsLXLVxQGLzWSfRXhvzXuOFX(dpK)CXVWLyXkTqXIfkkbggaYITAXXHSyiQcjTyXiQfhhYIhqquPh32jDlwHackGlMotv(fRqNM)IFbI89LcCcdvl27HulUqlgfhYV4xGiFFPaNWq1I9o8fZ1GqHZP0AoYTz8GtOJC5YlLfNxfGqhbyAe6ixPM8MasuMChyyOICdtvEw)08jx4BH82qUPS4(xaGPcbD0CHPkpRFA(lw3ItzX9Vaatfc6O5KsEvdWTsLjnln7xSUflL8QNlozXsjV6PZFsBX6wm8WwCxlM2I1T4uwCUgfLJlVuwC606jx4jSjSyEvj4eGPrccW6tOJCLAYBcirzYDGHHkYfoTgBGHHkwZ4b52mEWQXxixiijiadicDKRutEtajktUW3c5THCHiude5TCVXTsLX1kwMbZCV4pwXxCxjlwFYDGHHkYLlVuwCsccWDNqh5k1K3eqIYKl8TqEBi3CnkkhxEPS409I)yfFXDLSyAoLOxYDGHHkYLY4bNHOyuA)jjiaRxcDKRutEtajktUdmmurUVXTsLX1kwMbZix4jSjSyEvj4eGPrccWagcDKRutEtajktUdmmurU5TbMH0cwMbZix4BH82qUPS4(xaGPcbD0C5TbMH0cwMbZwSUfdrOgiYB5EJBLkJRvSmdM5EXFSIVy6twS(lw3IHiude5TCugp4mefJs7pDV4pwXxm9jlwFYfEcBclMxvcobyAKGaC6Nqh5k1K3eqIYK7addvKBEBGziTGLzWmYfEcBclMxvcobyAKGeKlxEPS4KH6LsEcDeGPrOJCLAYBcirzYf(wiVnKBUgfLJlVuwC6arElYDGHHkYLY4bdrXIdH59WcHfMQ8KGaS(e6ixPM8MasuMChyyOICdtvEw)08jx4BH82qUPS4(xaGPcbD0CHPkpRFA(lw3IZ1OOCC5LYIthiYBTyDlgEylURf3DYfEcBclMxvcobyAKGamGi0rUsn5nbKOm5cFlK3gYnxJIYXLxkloDGiVf5oWWqf5cNwJnWWqfRz8GCBgpy14lKleKeeG7oHoYvQjVjGeLjx4BH82qU5AuuU8gcb204Hde5Ti3bggQix40ASbggQynJhKBZ4bRgFHC5YlLfNKGaSEj0rUdmmurUC5LYItYvQjVjGeLjbbyadHoYvQjVjGeLj3bggQi334wPY4AflZGzKl8e2ewmVQeCcW0ibb40pHoYvQjVjGeLjx4BH82qU9Vaatfc6O5EJBLkJRvSmdMTyDlU)fayQqqN(oU8szXj5oWWqf5sz8GZqumkT)KeeG90e6ixPM8MasuMCHVfYBd52)camviOJM7nUvQmUwXYmy2I1T4(xaGPcbD67YBdmdPfSmdMrUdmmurUugp4mefJs7pjbbypNqh5k1K3eqIYK7addvKBEBGziTGLzWmYf(wiVnKBklU)fayQqqhnxEBGziTGLzWSfRBXqeQbI8wU34wPY4AflZGzUx8hR4lM(KfR)I1Tyic1arElhLXdodrXO0(t3l(Jv8ftFYI1NCHNWMWI5vLGtaMgjiattje6ixPM8MasuMChyyOICZBdmdPfSmdMrUW3c5THCtzX9Vaatfc6O5YBdmdPfSmdMrUWtytyX8QsWjatJeKGC5YlLfNe6iatJqh5k1K3eqIYK7addvKByQYZ6NMp5cFlK3gYnLf3)camviOJMlmv5z9tZFX6wCklU)fayQqqhnNuYRAaUvQmPzPz)I1TyPKx9CXjlwk5vpD(tAlw3IHh2I7AX0wSUfNYIZ1OOCC5LYItNwp5cpHnHfZRkbNamnsqawFcDKRutEtajktUdmmurUWP1ydmmuXAgpi3MXdwn(c5cbjbbyarOJCLAYBcirzYf(wiVnKBmnPc3RXpSsLLEdOW8AfOtQjVjGlw3ItzX9Vaatfc6O5En(HvQS0BafMxRaxSUfNRrr5En(HvQS0BafMxRaDGiVf5oWWqf5(A8dRuzP3akmVwbsccWDNqh5k1K3eqIYKl8TqEBixic1arEl3BCRuzCTILzWm3l(Jv8f3vYI1FX6wmeHAGiVLJY4bNHOyuA)P7f)Xk(I7kzXDNChyyOIC5YlLfNKGaSEj0rUsn5nbKOm5cFlK3gYT)fayQqqhn3BCRuzCTILzWSfRBX9Vaatfc603XLxkloj3bggQixkJhCgIIrP9NKGamGHqh5k1K3eqIYKl8TqEBi3CnkkhxEPS409I)yfFXDLSyAoLOxYDGHHkYLY4bNHOyuA)jjiaN(j0rUsn5nbKOm5oWWqf5(g3kvgxRyzgmJCHNWMWI5vLGtaMgjia7Pj0rUsn5nbKOm5cFlK3gYT)fayQqqhnxEBGziTGLzWSfRBX9Vaatfc6039g3kvgxRyzgmBX6wm8WC(tAloDlgEylM(fRp5oWWqf5sz8GHOyXHW8EyHWctvEsqa2Zj0rUsn5nbKOm5oWWqf5gMQ8S(P5tUW3c5THC7FbaMke0rZL3gygslyzgmBX6wC)laWuHGo9DVXTsLX1kwMbZwSUfdpmN)K2It3IHh2IPFX0ix4jSjSyEvj4eGPrccW0ucHoYvQjVjGeLj3bggQi382aZqAblZGzKl8TqEBi3uwC)laWuHGoAU82aZqAblZGzlw3IHiude5TCVXTsLX1kwMbZCV4pwXxm9jlw)fRBXqeQbI8wokJhCgIIrP9NUx8hR4lM(KfRp5cpHnHfZRkbNamnsqaMgncDKRutEtajktUW3c5THChyyaimPeFt4lM(KfdOfRBXPS4(xaGPcbD0C8ERkRuzWFkHLzWmYDGHHkYL3BvzLkd(tjSmdMrccW00Nqh5k1K3eqIYK7addvK7BCRuzCTILzWmYfEcBclMxvcobyAKGamnarOJCLAYBcirzYf(wiVnKBklU)fayQqqhnhV3QYkvg8NsyzgmJChyyOIC59wvwPYG)uclZGzKGamTUtOJCLAYBcirzYDGHHkYnVnWmKwWYmyg5cFlK3gYnLf3)camviOJMlVnWmKwWYmyg5cpHnHfZRkbNamnsqcYLhe6iatJqh5oWWqf5AfaOmHLMMuKRutEtajktccW6tOJChyyOICdKg8GHOyGYehKRutEtajktccWaIqh5k1K3eqIYKl8TqEBi3uwCUgfLJhO3NjZhhSPazu2loTEYDGHHkYLhO3NjZhhSPazu2lKGaC3j0rUsn5nbKOm5oWWqf5(g3kvgxRyzgmJCHVfYBd5oaU8wioUxJkypsRapqACXj1K3eWfRBX5AuuoUxJkypsRapqACXXJbMT4KfRp5cpHnHfZRkbNamnsqawVe6ixPM8MasuMCHVfYBd5MRrr5En(HvQS0BafMxRaDGiV1I1T4uwC)laWuHGoAUxJFyLkl9gqH51kqYDGHHkY914hwPYsVbuyETcKeeGbme6ixPM8MasuMCHVfYBd5MYI7FbaMke0rZfMQ8S(P5tUdmmurUsjVQb4wPYKMLM9KGaC6Nqh5k1K3eqIYK7addvKBEBGziTGLzWmYf(wiVnKBklU)fayQqqhnxEBGziTGLzWSfRBXWdZ5pPT40Ty4HTy6twmTfRBXCjy5OsJ7ctE9PX6EpCX6wCUgfLlhLX6Fe0P1tUWtytyX8QsWjatJeeG90e6ixPM8MasuMCHVfYBd5Q0fdpSf3vYI1FX6HChyyOICPmEWquS4qyEpSqyHPkpjia75e6ixPM8MasuMChyyOICdtvEw)08jx4BH82qUPS4(xaGPcbD0CHPkpRFA(lw3IHh2I7kzXaAX6wSuYRE6cZxybI5pPT4UwS(Kl8e2ewmVQeCcW0ibbyAkHqh5k1K3eqIYK7addvKByQYZ6NMp5cFlK3gYnLf3)camviOJMlmv5z9tZFX6wm8WC(tAloDlgEylM(KfR)I1T4CnkkhxEPS40bI8wlw3IHiude5TCugpyikwCimVhwiSWuL39I)yfFX0VyPKx90fMVWceZFsJCHNWMWI5vLGtaMgjiatJgHoYDGHHkY17H9nRuzG)OIkwVwbpixPM8MasuMeeGPPpHoYvQjVjGeLjx4BH82qUWdBX0NSyaTyDlwk5vpDH5lSaX8N0wm9lwFNExSUfpaU8wioUxJkypsRapqACX9tLT4UwmGi3bggQixkJhCgIIrP9NKGamnarOJCLAYBcirzYDGHHkY9nUvQmUwXYmyg5cFlK3gYvPlwPlgEylM(KfdOfRBXsjV65IPpzXDxjlwplwrfxm8Wwm9jlwVlwplw3Iv6IJPjv44YlLfNoPM8MaUyfvCXqeQbI8woU8szXP7f)Xk(IPpzXaMfRNfRBXPS4bWL3cXX9Aub7rAf4bsJloPM8MasUWtytyX8QsWjatJeeGP1DcDKRutEtajktUW3c5THCtzXX0KkCC5LYItNutEtaxSUfR0fpaU8wioUxJkypsRapqACX9tLT4UwmGwSIkUyic1arElN3d7BwPYa)rfvSETcE4EXFSIV4UwmnaTy9qUdmmurUugp4mefJs7pjbbyA6Lqh5k1K3eqIYK7addvK7BCRuzCTILzWmYf(wiVnKleHAGiVLJlVuwC6EXFSIVy6twSExSIkUyLU4uwCmnPchxEPS40j1K3eWfRNfRBXPS4bWL3cXX9Aub7rAf4bsJloPM8MasUWtytyX8QsWjatJeeGPbyi0rUsn5nbKOm5oWWqf5M3gygslyzgmJCHVfYBd5crOgiYB5OmEWzikgL2F6EXFSIVy6xS(lw3ItzX9Vaatfc6O5YBdmdPfSmdMTyDlwk5vpDH5lSaX8N0wm9lM2I1T4bWL3cXX9Aub7rAf4bsJlUFQSft)I1NCHNWMWI5vLGtaMgjiatl9tOJCLAYBcirzYDGHHkYnVnWmKwWYmyg5cFlK3gYnxJIYX9Aub7rAf4bsJloEmWSf31I1FX6wCklU)fayQqqhnxEBGziTGLzWmYfEcBclMxvcobyAKGamnpnHoYvQjVjGeLjx4BH82qUINqZ67fqxCimXVxE0ZzWPFGwG(fRBX5AuuU4qyIFV8ONZGt)aTa9oEmWSftFYIP55lw3ILsE1txy(clqm)jTft)Ibe5oWWqf5c)bM1SsLLEdOWAM6ruwPsccW08CcDKRutEtajktUW3c5THCfpHM13lGU4qyIFV8ONZGt)aTa9lw3IZ1OOCXHWe)E5rpNbN(bAb6D8yGzlM(KftR7lw3IHiude5TCC5LYIt3l(Jv8f31IPbOfRBXX0KkCC5LYItNutEtaxSUflL8QNUW8fwGy(tAlM(fdiYDGHHkYf(dmRzLkl9gqH1m1JOSsLeeG1xje6ixPM8MasuMChyyOICZBdmdPfSmdMrUW3c5THCtzX9Vaatfc6O5YBdmdPfSmdMrUWtytyX8QsWjatJeeG1NgHoYDGHHkYfEymVdac5k1K3eqIYKGaS(6tOJCLAYBcirzYf(wiVnKRuYRE6cZxybI5pPTy6xmTfRBXX0KkCC5LYItNutEtaj3bggQix4HXY1EEqccW6dicDKRutEtajktUdmmurUHPkpRFA(Kl8TqEBi3uwC)laWuHGoAUWuLN1pn)fRBXPS4(xaGPcbD0CsjVQb4wPYKMLM9lw3Iv6IHhMZFsBXPBXWdBX0NSy9xSIkUyPKx90fMVWceZFsBXDTyaTy9SyDloLfNRrr54YlLfNoTEYfEcBclMxvcobyAKGaS(DNqh5k1K3eqIYKl8TqEBix4H58N0wC6wm8Wwm9jlgqlw3ILsE1txy(clqm)jTft)IPTyDloLfhttQWXLxkloDsn5nbKChyyOICHhglx75bjiaRVEj0rUsn5nbKOm5cFlK3gYnLfZLMaddvK7addvKByQYZ6NMpjib5Yfkgf6Zi0raMgHoYvQjVjGeLjxaMMMqUkDX5AuuoEGEFMmFCWMcKrzV406xSIkUyic1arElhpqVptMpoytbYOSxCWJ5vf(ItwS(lwpK7addvKlaZBtEtixaMNvJVqUCHIrJeeG1Nqh5k1K3eqIYKlatttixLUyic1arElhLXdodrXO0(t3l(Jv8f3vYIPP)I1Ty4HTy6twmGwSUfdrOgiYB5EJBLkJRvSmdM5EXFSIV4UswmTfRNfROIloMxvcxy(clqmqtwCxjlwF9UyfvCXGsUgfLlqAWdgIIbktC406j3bggQixaM3M8MqUampRgFHC5cftFsqagqe6ixPM8MasuMCbyAAc5Q0fNYIfpHM13lGoW3QmRuzhOVyqeaYVyDlgIqnqK3Yrz8GZqumkT)09I)yfFXDLSyaZI1Ty4HTy6twmGwSUfdrOgiYB5EJBLkJRvSmdM5EXFSIV4UswmTfRNfROIloMxvcxy(clqmqtwCxjlMMExSIkUyqjxJIYfin4bdrXaLjoCA9lw3IHiude5TC8a9(mz(4GnfiJYEXbpMxv4lozX0i3bggQixaM3M8MqUampRgFHC5cfdqKGaC3j0rUsn5nbKOm5cW00eYvPlgIqnqK3Yrz8GZqumkT)09I)yfFXDLSyA6VyDlgEylM(KfdOfRBXqeQbI8wU34wPY4AflZGzUx8hR4lURKftBX6zXkQ4IJ5vLWfMVWced0Kf3vYI1xVlwrfxmOKRrr5cKg8GHOyGYehoT(fRBXqeQbI8woEGEFMmFCWMcKrzV4GhZRk8fNSyAK7addvKlaZBtEtixaMNvJVqUCHI1DsqawVe6ixPM8MasuMCHVfYBd5YfkgTfROIlMlum9xSIkUyUqXa0IvuXfZfkw3j3bggQix40ASbggQynJhKBZ4bRgFHC5cfjiadyi0rUsn5nbKOm5cFlK3gYDGHbGWKs8nHVy6xmGi3bggQi3xRydmmuXAgpi3MXdwn(c5oiHeeGt)e6ixPM8MasuMCHVfYBd5oWWaqysj(MWxCxjlgqK7addvK7RvSbggQynJhKBZ4bRgFHC5bjib5YLxklozuOpJqhbyAe6ixPM8MasuMCHVfYBd5Q0fdrOgiYB54YlLfNUx8hR4lURKfRKfROIloxJIYXLxkloDA9lwplw3IhaxEleh3RrfShPvGhinU4KAYBc4I1T4W8Lft)IbKsi3bggQix40ASbggQynJhKBZ4bRgFHC5YlLfNxfGeeG1Nqh5k1K3eqIYKl8TqEBixLUyLU4uw8a4YBH44EnQG9iTc8aPXfNutEtaxSUfdrOgiYB54YlLfNUx8hR4lURKfRKfRNfROIloxJIYXLxkloDA9lwplw3IdZxwm9lgqkHChyyOICHtRXgyyOI1mEqUnJhSA8fYLlVuwCsccWaIqh5k1K3eqIYKl8TqEBixLUyic1arElhxEPS409I)yfFXDLSyLSyfvCX5AuuoU8szXPtRFX6zX6wCy(YI7AXasjlw3IhaxEleh3RrfShPvGhinU4KAYBci5oWWqf5cNwJnWWqfRz8GCBgpy14lKlxEPS4KH6Ls(RcqccWDNqh5k1K3eqIYKl8TqEBixLU4uw8a4YBH44EnQG9iTc8aPXfNutEtaxSUfdrOgiYB54YlLfNUx8hR4lURKfRKfROIloxJIYXLxkloDA9lwplw3IdZxwCxlgqkHChyyOICHtRXgyyOI1mEqUnJhSA8fYLlVuwCYq9sjpjiaRxcDKRutEtajktUW3c5THChyyaimPeFt4lM(fdiYDGHHkY91k2addvSMXdYTz8GvJVqUdsibbyadHoYvQjVjGeLjx4BH82qUdmmaeMuIVj8f3vYIbe5oWWqf5(AfBGHHkwZ4b52mEWQXxixEqcsqUGc1O1ccDeGPrOJChyyOIChTaXMigyg5k1K3eqIYKGaS(e6i3bggQixEVmp7ykqgpEltixPM8MasuMeeGbeHoYvQjVjGeLjx4BH82qUPS4yAsfofmecK5zN3FCsn5nbKCTkKhGPrUEUsi3EyWoKPfhKRsC6LChyyOICdKg8GHOyzZ7pKGaC3j0rUsn5nbKOm5cFlK3gYnMMuHtfHazzZ7poPM8MaUyDloxJIYL3qiWMgpCGiV1I1T4W8Lft)IPrUwfYdW0ixpxjKBpmyhY0IdYLMtjK7addvKBG0GhmeflBE)HeeG1lHoYvQjVjGeLjx4BH82qUX0KkCQieilBE)Xj1K3eWfRBX9Vaatfc6O5cKg8GHOyGYehlw3IZ1OOC5necSPXdNwp5AvipatJC9CLqU9WGDitloixAoLqUdmmurUbsdEWquSS59hsqagWqOJCLAYBcirzYf(wiVnKBUgfLJlVuwC606xSIkU4CnkkhpqVptMpoytbYOSxCA9lwrfxSsxCkloMMuHJlVuwC6KAYBc4I1T44Tktcx)JGUr1AwC6EzGXI1ZIvuXfNRrr5YBieytJhUxgySyfvCXX8Qs4cZxybIbAYI7kzXagLqUdmmurU9OWqfjiaN(j0rUsn5nbKOm5cFlK3gYnMxvcxy(clqmqtwCxjl2Zj3bggQi3aPbpyikgOmXbjia7Pj0rUsn5nbKOm5cFlK3gYnLfhttQWXLxkloDsn5nbKChyyOICFTInWWqfRz8GCBgpy14lKlxOyuOpJeeG9CcDKRutEtajktUW3c5THCJPjv44YlLfNoPM8MasUdmmurUVwXgyyOI1mEqUnJhSA8fYLlVuwCYOqFgjib52)ce5NpbHocW0i0rUsn5nbKOmjiaRpHoYvQjVjGeLjbbyarOJCLAYBcirzsqaU7e6ixPM8MasuMeeG1lHoYDGHHkYThfgQixPM8MasuMeeGbme6i3bggQix4HXY1EEqUsn5nbKOmjiaN(j0rUdmmurUWdJ5DaqixPM8MasuMeKGC5cfHocW0i0rUsn5nbKOm5oWWqf5gMQ8S(P5tUW3c5THCtzX9Vaatfc6O5ctvEw)08xSUfNYI7FbaMke0rZjL8QgGBLktAwA2VyDlwk5vpxCYILsE1tN)K2I1Ty4HT4UwmnYfEcBclMxvcobyAKGaS(e6ixPM8MasuMChyyOICHtRXgyyOI1mEqUnJhSA8fYfcsccWaIqh5k1K3eqIYKl8TqEBi3uwCUgfLJhO3NjZhhSPazu2loTEYDGHHkYLhO3NjZhhSPazu2lKGeK7GecDeGPrOJCLAYBcirzYDGHHkYfoTgBGHHkwZ4b52mEWQXxixiijiaRpHoYvQjVjGeLjx4BH82qUPS4(xaGPcbD0CHPkpRFA(lw3IHh2I7kzX0wSUfR0fdrOgiYB5EJBLkJRvSmdM5EXFSIV4KfRKfROIlwPloMMuHJY4bdrXIdH59WcHfMQ8oPM8MaUyDlgIqnqK3Yrz8GHOyXHW8EyHWctvE3l(Jv8fNSyLSy9SyfvCXsjV65I7AX6vjlwpK7addvKRuYRAaUvQmPzPzpjiadicDKRutEtajktUW3c5THCHhMZFsBXPBXWdBX0NSyAlw3ILsE1txy(clqm)jTftFYIvItVK7addvK78WPewG(xQGeeG7oHoYvQjVjGeLjx4BH82qUX0KkCC5LYItNutEtaxSUfNYIfpHM13lGoW3QmRuzhOVyqeaYVyDlgIqnqK3YXLxkloDV4pwXxm9jlwVlw3ILsE1txy(clqm)jTft)I1NChyyOICPmEWzikgL2FsccW6Lqh5k1K3eqIYKl8TqEBi3yAsfoU8szXPtQjVjGlw3IfpHM13lGoW3QmRuzhOVyqeaYVyDlwPlgIqnqK3YXLxkloDV4pwXxm9jlMMExSIkUyic1arElhxEPS409I)yfFXDLS4UVy9SyDlwk5vpDH5lSaX8N0wm9lwFYDGHHkYLY4bNHOyuA)jjiadyi0rUsn5nbKOm5cFlK3gYnLfhttQWXLxkloDsn5nbCX6wSuYRE6cZxybI5pPTy6xS(K7addvKlLXdodrXO0(tsqao9tOJCLAYBcirzYf(wiVnKleHAGiVL7nUvQmUwXYmyM7f)Xk(IPpzXaYP3fRBXWdBXDLSy9sUdmmurUugp4mefJs7pjbbypnHoYDGHHkY17H9nRuzG)OIkwVwbpixPM8MasuMeeG9CcDKRutEtajktUdmmurUVXTsLX1kwMbZix4BH82qUkDXX0KkCEpSVzLkd8hvuX61k4HtQjVjGlw3IHiude5TCEpSVzLkd8hvuX61k4H7f)Xk(I7AXQqWfRNfRBXPS4(xaGPcbD0CVXTsLX1kwMbZwSUfdrOgiYB5OmEWzikgL2F6EXFSIVy6xSkeKCHNWMWI5vLGtaMgjiattje6ixPM8MasuMCHVfYBd5cpSf3vYIb0I1TyLUyic1arEl3BCRuzCTILzWm3l(Jv8ftFYI17IvuXfdrOgiYB58EyFZkvg4pQOI1RvWd3l(Jv8ftFYI17I1ZI1TyPKx90fMVWceZFsBX0VyAK7addvKl8Wy5AppibbyA0i0rUdmmurUWdJLR98GCLAYBcirzsqaMM(e6ixPM8MasuMCHVfYBd5Q0fpWWaqysj(MWxm9jlgqlwrfxSsxCUgfLlhLX6Fe0P1VyDlgEyo)jTfNUfdpSftFYIvYI1ZI1ZI1T4uwC)laWuHGoAoEVvLvQm4pLWYmy2I1TyUeSCuPXDHjV(0yDVhsUdmmurU8ERkRuzWFkHLzWmsqaMgGi0rUsn5nbKOm5cFlK3gYDGHbGWKs8nHVy6twmGwSUfNYI7FbaMke0rZX7TQSsLb)PewMbZwSUfdrOgiYB5OmEWzikgL2F6EXFSIVy6xSkeKChyyOIC59wvwPYG)uclZGzKGamTUtOJCLAYBcirzYDGHHkYnVnWmKwWYmyg5cFlK3gYnLf3)camviOJMlVnWmKwWYmy2I1Ty4H58N0wC6wm8Wwm9jlM2I1TyUeSCuPXDHjV(0yDVhUyDlwPloLfZLGLJknUlm5P55m97HlwrfxCmnPchxEPS40j1K3eWfRhYfEcBclMxvcobyAKGamn9sOJCLAYBcirzYDGHHkYnVnWmKwWYmyg5cFlK3gYvPlgEylM(ftBXkQ4IZ1OOC5Omw)JGoT(fROIlwPloMMuHtk5vna3kvM0S0S3j1K3eWfRBXqeQbI8woPKx1aCRuzsZsZE3l(Jv8f31IHiude5TCugp4mefJs7pDV4pwXxSEwSEwSUfR0fR0fdrOgiYB5EJBLkJRvSmdM5EXFSIVy6xmTfRBXkDXPS4yAsfokJhmefloeM3dlewyQY7KAYBc4IvuXfdrOgiYB5OmEWquS4qyEpSqyHPkV7f)Xk(IPFX0wSEwSIkUy4HTy6xC3xSEwSUfR0fdrOgiYB5OmEWzikgL2F6EXFSIVy6xmTfROIlgEylM(fR)I1ZIvuXf3)camviOJMlmv5z9tZFX6zX6wCklU)fayQqqhnxEBGziTGLzWmYfEcBclMxvcobyAKGamnadHoYvQjVjGeLjx4BH82qUINqZ67fqxCimXVxE0ZzWPFGwG(fRBX5AuuU4qyIFV8ONZGt)aTa9oEmWSftFYIP55lw3ILsE1txy(clqm)jTft)Ibe5oWWqf5c)bM1SsLLEdOWAM6ruwPsccW0s)e6ixPM8MasuMCHVfYBd5kEcnRVxaDXHWe)E5rpNbN(bAb6xSUfNRrr5IdHj(9YJEodo9d0c074XaZwm9jlMw3xSUfdrOgiYB54YlLfNUx8hR4lURftdqlw3IJPjv44YlLfNoPM8MaUyDlwk5vpDH5lSaX8N0wm9lgqK7addvKl8hywZkvw6nGcRzQhrzLkjiatZttOJCLAYBcirzYDGHHkYnVnWmKwWYmyg5cFlK3gYnLf3)camviOJMlVnWmKwWYmy2I1Ty4H58N0wC6wm8Wwm9jlM2I1TyUeSCuPXDHjV(0yDVhUyDloxJIYLJYy9pc606jx4jSjSyEvj4eGPrccW08CcDKRutEtajktUdmmurUHPkpRFA(Kl8TqEBi3uwC)laWuHGoAUWuLN1pn)fRBXPS4(xaGPcbD0CsjVQb4wPYKMLM9lw3Iv6IHhMZFsBXPBXWdBX0NSy9xSIkUyPKx90fMVWceZFsBXDTyaTy9qUWtytyX8QsWjatJeeG1xje6ixPM8MasuMChyyOICdtvEw)08jx4BH82qUPS4(xaGPcbD0CHPkpRFA(lw3ItzX9Vaatfc6O5KsEvdWTsLjnln7xSUflL8QNUW8fwGy(tAlURKftBX6wm8WC(tAloDlgEylM(KfRp5cpHnHfZRkbNamnsqawFAe6ixPM8MasuMCHVfYBd5cpSf3vYIb0I1TyLUyic1arEl3BCRuzCTILzWm3l(Jv8ftFYI17IvuXfdrOgiYB58EyFZkvg4pQOI1RvWd3l(Jv8ftFYI17I1ZI1TyPKx90fMVWceZFsBX0VyAK7addvKl8WyEhaesqawF9j0rUdmmurUWdJ5DaqixPM8MasuMeeG1hqe6ixPM8MasuMCHVfYBd5MYI5stGHHkYDGHHkYnmv5z9tZNeKGC5YlLfNmuVuYFvacDeGPrOJCLAYBcirzYf(wiVnKBUgfLJlVuwC6arElYDGHHkYLY4bdrXIdH59WcHfMQ8KGaS(e6ixPM8MasuMChyyOICdtvEw)08jx4BH82qU5AuuoU8szXPde5TwSUfdpSf31I7o5cpHnHfZRkbNamnsqagqe6ixPM8MasuMCHVfYBd5MRrr54YlLfNoqK3IChyyOICHtRXgyyOI1mEqUnJhSA8fYfcsccWDNqh5k1K3eqIYKl8TqEBi3CnkkxEdHaBA8WbI8wK7addvKlCAn2addvSMXdYTz8GvJVqUC5LYItsqawVe6i3bggQixU8szXj5k1K3eqIYKGamGHqh5k1K3eqIYK7addvK7BCRuzCTILzWmYfEcBclMxvcobyAKGaC6Nqh5k1K3eqIYKl8TqEBi3CnkkhxEPS409I)yfFXDTyAK7addvKlLXdodrXO0(tsqa2ttOJCLAYBcirzYDGHHkYnVnWmKwWYmyg5cFlK3gYnLf3)camviOJMlVnWmKwWYmy2I1Tyic1arEl3BCRuzCTILzWm3l(Jv8ftFYI1FX6wmeHAGiVLJY4bNHOyuA)P7f)Xk(IPpzX6tUWtytyX8QsWjatJeeG9CcDKRutEtajktUdmmurU5TbMH0cwMbZix4jSjSyEvj4eGPrcsqUqqcDeGPrOJChyyOICTcauMWsttkYvQjVjGeLjbby9j0rUsn5nbKOm5wJVqUnnE8inotf1aLI1308hvHChyyOIC14cZcXNeeGbeHoYDGHHkYnVHqGmkT)KCLAYBcirzsqaU7e6i3bggQi3C55YNzLk5k1K3eqIYKGaSEj0rUsn5nbKOm5cFlK3gYfEyo)jTfNUfdpSftFYIPTyDlwk5vpDH5lSaX8N0wm9jlwjo9sUdmmurUZdNsyb6FPcsqagWqOJChyyOICBM6rWzPNgOQVub5k1K3eqIYKGaC6Nqh5oWWqf5szVK3qiqYvQjVjGeLjbbypnHoYDGHHkYDkOWJFAm40AKRutEtajktccWEoHoYDGHHkYnqAWdgIIbktCqUsn5nbKOmjibjixaKNBOIaS(kHMNwjEA91RJMNRVNtUENVSsLtUEskefa40haRG5zw8IP7qwS53J(yXuOFXPVGc1O1I03f)INqZEbCXCKVS4rlq(tiGlgEmLQWDBhfCwjlMMNzXPplUwFp6dbCXdmmuT403rlqSjIbML(62oBN0h(9OpeWftt)fpWWq1IBgp4UTd5oAXb6j3R5RWKB)JOSMqUDBXkO0eOwiGloxOqVSyiYpFIfNlQwXDlwHaHsFWxCHQ0DmVpLwBXdmmuXxmQANUTZaddvCx)lqKF(ejuTHNTDgyyOI76FbI8ZNi1epOqiWTZaddvCx)lqKF(ePM4XOP6lvmHHQTt3w8TME(bkw8pg4IZ1OOeWfZJj4loxOqVSyiYpFIfNlQwXx8uGlU)L01JIWk1fB8fdIkXTDgyyOI76FbI8ZNi1ep410ZpqbJhtW3odmmuXD9Var(5tKAIh9OWq12zGHHkUR)fiYpFIut8aEySCTNhBNbggQ4U(xGi)8jsnXd4HX8oaiBNTZ2PBlwbLMa1cbCXcaYFU4W8LfhhYIhyG(fB8fpamwBYBIB7mWWqfpz0ceBIyGzBNbggQ4PM4bVxMNDmfiJhVLjBNUTy6qAWJfJOwSNDE)zXOAXqeQbI8waTyJAXkyie4I9SZ7pl24lwQjVjGlw8eAtBXbAX0uIsuWZIrul2FsZ818x8HmT4y7mWWqfp1epcKg8GHOyzZ7pazvipatlXZvcq9WGDitlosuItVazujPettQWPGHqGmp78(JtQjVjGazvipatlXZvcq9WGDitlosuItVBNbggQ4PM4rG0GhmeflBE)biRc5byAjEUsaQhgSdzAXrcnNsaYOsIPjv4uriqw28(JtQjVjG6Y1OOC5necSPXdhiYBPlmFHEABNbggQ4PM4rG0GhmeflBE)biRc5byAjEUsaQhgSdzAXrcnNsaYOsIPjv4uriqw28(JtQjVjG66FbaMke0rZfin4bdrXaLjo0LRrr5YBieytJhoT(Tt3wScffgQwSrT4R8szX5Ir)IVb69bAXkO5JdGw8uGl2tzVS45LfR1Vy0V4tK2INxw8RvLvQlMlVuwCU4Pax8Sy)XQfZJjwC8wLjXI7FeKd0Ir)IprAlEEzXAfO8looKfluucmwmIAX5necSPXdGwm6xCmVQelomFzXbAXGMSyJVy1xMq(fJ(flEcTPT4aTyaJs2odmmuXtnXJEuyOciJkjxJIYXLxkloDA9kQyUgfLJhO3NjZhhSPazu2loTEfvuPPettQWXLxkloDsn5nbux8wLjHR)rq3OAnloDVmWqpkQyUgfLlVHqGnnE4EzGHIkgZRkHlmFHfigOjDLayuY2zGHHkEQjEein4bdrXaLjoaYOsI5vLWfMVWced0KUs88TZaddv8ut841k2addvSMXdGQXxs4cfJc9zazujPettQWXLxkloDsn5nbC7mWWqfp1epETInWWqfRz8aOA8LeU8szXjJc9zazujX0KkCC5LYItNutEta3oBNTZ2PBl(gO3hOfRGMpoaAXtbUypL9YIvikufCC32PBlwbeamUaUyjnJhwPUyk0NzL6Id0IFbudklEabr1Irai)HmGUTZaddvChxOyuOplbG5TjVjavJVKWfkgnGayAAsIsZ1OOC8a9(mz(4GnfiJYEXP1ROIqeQbI8woEGEFMmFCWMcKrzV4GhZRk8e91Z2zGHHkUJlumk0NLAIhamVn5nbOA8LeUqX0hiaMMMKOuic1arElhLXdodrXO0(t3l(Jv8UsOPVo4HrFcG0brOgiYB5EJBLkJRvSmdM5EXFSI3vcn9OOIX8Qs4cZxybIbAsxj6RxfveuY1OOCbsdEWqumqzIdNw)2zGHHkUJlumk0NLAIhamVn5nbOA8LeUqXaeqamnnjrPPiEcnRVxaDGVvzwPYoqFXGiaKxheHAGiVLJY4bNHOyuA)P7f)XkExjagDWdJ(eaPdIqnqK3Y9g3kvgxRyzgmZ9I)yfVReA6rrfJ5vLWfMVWced0KUsOPxfveuY1OOCbsdEWqumqzIdNwVoic1arElhpqVptMpoytbYOSxCWJ5vfEcTTZaddvChxOyuOpl1epayEBYBcq14ljCHI1DGayAAsIsHiude5TCugp4mefJs7pDV4pwX7kHM(6Ghg9jasheHAGiVL7nUvQmUwXYmyM7f)XkExj00JIkgZRkHlmFHfigOjDLOVEvurqjxJIYfin4bdrXaLjoCA96Giude5TC8a9(mz(4GnfiJYEXbpMxv4j02odmmuXDCHIrH(Sut8aoTgBGHHkwZ4bq14ljCHciJkHlumAkQixOy6ROICHIbifvKluSUVDgyyOI74cfJc9zPM4XRvSbggQynJhavJVKmibiJkzGHbGWKs8nHtpG2odmmuXDCHIrH(Sut841k2addvSMXdGQXxs4bqgvYaddaHjL4BcVReaTD2oBNbggQ4oUqLeMQ8S(P5de8e2ewmVQe8eAazujP0)camviOJMlmv5z9tZxxk9Vaatfc6O5KsEvdWTsLjnln71jL8QNjsjV6PZFsth8W6I22zGHHkUJluPM4bCAn2addvSMXdGQXxsGGBNbggQ4oUqLAIh8a9(mz(4GnfiJYEbiJkjLCnkkhpqVptMpoytbYOSxCA9BNTZ2PBl(kVuwCUyfIcvbh3TD62IvabaJlGlwsZ4HvQlMc9zwPU4aT4xa1GYIhqquTyeaYFidOB7mWWqf3XLxklozuOplboTgBGHHkwZ4bq14ljC5LYIZRcaKrLOuic1arElhxEPS409I)yfVReLOOI5AuuoU8szXPtRxp6gaxEleh3RrfShPvGhinU4KAYBcOUW8f6bKs2odmmuXDC5LYItgf6ZsnXd40ASbggQynJhavJVKWLxklobYOsuQstzaC5TqCCVgvWEKwbEG04ItQjVjG6Giude5TCC5LYIt3l(Jv8UsuIEuuXCnkkhxEPS40P1RhDH5l0diLSDgyyOI74YlLfNmk0NLAIhWP1ydmmuXAgpaQgFjHlVuwCYq9sj)vbaYOsukeHAGiVLJlVuwC6EXFSI3vIsuuXCnkkhxEPS40P1RhDH5lDbiLOBaC5TqCCVgvWEKwbEG04ItQjVjGBNbggQ4oU8szXjJc9zPM4bCAn2addvSMXdGQXxs4YlLfNmuVuYdKrLO0ugaxEleh3RrfShPvGhinU4KAYBcOoic1arElhxEPS409I)yfVReLOOI5AuuoU8szXPtRxp6cZx6cqkz7mWWqf3XLxklozuOpl1epETInWWqfRz8aOA8LKbjazujdmmaeMuIVjC6b02zGHHkUJlVuwCYOqFwQjE8AfBGHHkwZ4bq14lj8aiJkzGHbGWKs8nH3vcG2oBNTZaddvChxEPS4mjmv5z9tZhi4jSjSyEvj4j0aYOssP)fayQqqhnxyQYZ6NMVUu6FbaMke0rZjL8QgGBLktAwA2Rtk5vptKsE1tN)KMo4H1fnDPKRrr54YlLfNoT(TZaddvChxEPS4m1epGtRXgyyOI1mEaun(sceC70TfdSiG8fhOfNll(fVVfHulMc9lwzpLcz7mWWqf3XLxklotnXJxJFyLkl9gqH51kqGmQKyAsfUxJFyLkl9gqH51kqNutEta1Ls)laWuHGoAUxJFyLkl9gqH51kqD5AuuUxJFyLkl9gqH51kqhiYBTDgyyOI74YlLfNPM4bxEPS4eiJkbIqnqK3Y9g3kvgxRyzgmZ9I)yfVRe91brOgiYB5OmEWzikgL2F6EXFSI3vs33odmmuXDC5LYIZut8GY4bNHOyuA)jqgvs)laWuHGoAU34wPY4AflZGz66FbaMke0PVJlVuwCUDgyyOI74YlLfNPM4bLXdodrXO0(tGmQKCnkkhxEPS409I)yfVReAoLO3TZaddvChxEPS4m1epEJBLkJRvSmdMbe8e2ewmVQe8eABNbggQ4oU8szXzQjEqz8GHOyXHW8EyHWctvEGmQK(xaGPcbD0C5TbMH0cwMbZ01)camviOtF3BCRuzCTILzWmDWdZ5pPLo4HrV(BNbggQ4oU8szXzQjEeMQ8S(P5de8e2ewmVQe8eAazuj9Vaatfc6O5YBdmdPfSmdMPR)fayQqqN(U34wPY4AflZGz6GhMZFslDWdJEABNbggQ4oU8szXzQjEK3gygslyzgmdi4jSjSyEvj4j0aYOssP)fayQqqhnxEBGziTGLzWmDqeQbI8wU34wPY4AflZGzUx8hR40NOVoic1arElhLXdodrXO0(t3l(JvC6t0F7mWWqf3XLxklotnXdEVvLvQm4pLWYmygqgvYaddaHjL4BcN(eaPlL(xaGPcbD0C8ERkRuzWFkHLzWSTZaddvChxEPS4m1epEJBLkJRvSmdMbe8e2ewmVQe8eABNbggQ4oU8szXzQjEW7TQSsLb)PewMbZaYOssP)fayQqqhnhV3QYkvg8NsyzgmB7mWWqf3XLxklotnXJ82aZqAblZGzabpHnHfZRkbpHgqgvsk9Vaatfc6O5YBdmdPfSmdMTD2oBNbggQ4oU8szX5vbsctvEw)08bcEcBclMxvcEcnGmQKu6FbaMke0rZfMQ8S(P5RlL(xaGPcbD0CsjVQb4wPYKMLM96KsE1ZePKx905pPPdEyDrtxk5AuuoU8szXPtRF7mWWqf3XLxkloVkqQjEaNwJnWWqfRz8aOA8Lei42zGHHkUJlVuwCEvGut8GlVuwCcKrLarOgiYB5EJBLkJRvSmdM5EXFSI3vI(BNbggQ4oU8szX5vbsnXdkJhCgIIrP9Nazuj5AuuoU8szXP7f)XkExj0CkrVBNbggQ4oU8szX5vbsnXJ34wPY4AflZGzabpHnHfZRkbpH22zGHHkUJlVuwCEvGut8iVnWmKwWYmygqWtytyX8QsWtObKrLKs)laWuHGoAU82aZqAblZGz6Giude5TCVXTsLX1kwMbZCV4pwXPprFDqeQbI8wokJhCgIIrP9NUx8hR40NO)2zGHHkUJlVuwCEvGut8iVnWmKwWYmygqWtytyX8QsWtOTD2oBNbggQ4oU8szXjd1lL8jugpyikwCimVhwiSWuLhiJkjxJIYXLxkloDGiV12zGHHkUJlVuwCYq9sjFQjEeMQ8S(P5de8e2ewmVQe8eAazujP0)camviOJMlmv5z9tZxxUgfLJlVuwC6arElDWdRRUVDgyyOI74YlLfNmuVuYNAIhWP1ydmmuXAgpaQgFjbccKrLKRrr54YlLfNoqK3A7mWWqf3XLxklozOEPKp1epGtRXgyyOI1mEaun(scxEPS4eiJkjxJIYL3qiWMgpCGiV12zGHHkUJlVuwCYq9sjFQjEWLxklo3odmmuXDC5LYItgQxk5tnXJ34wPY4AflZGzabpHnHfZRkbpH22zGHHkUJlVuwCYq9sjFQjEqz8GZqumkT)eiJkP)fayQqqhn3BCRuzCTILzWmD9Vaatfc603XLxklo3odmmuXDC5LYItgQxk5tnXdkJhCgIIrP9Nazuj9Vaatfc6O5EJBLkJRvSmdMPR)fayQqqN(U82aZqAblZGzBNbggQ4oU8szXjd1lL8PM4rEBGziTGLzWmGGNWMWI5vLGNqdiJkjL(xaGPcbD0C5TbMH0cwMbZ0brOgiYB5EJBLkJRvSmdM5EXFSItFI(6Giude5TCugp4mefJs7pDV4pwXPpr)TZaddvChxEPS4KH6Ls(ut8iVnWmKwWYmygqWtytyX8QsWtObKrLKs)laWuHGoAU82aZqAblZGzBNTZ2zGHHkUJlVuwCYq9sj)vbsOmEWquS4qyEpSqyHPkpqgvsUgfLJlVuwC6arERTZaddvChxEPS4KH6Ls(RcKAIhHPkpRFA(abpHnHfZRkbpHgqgvsUgfLJlVuwC6arElDWdRRUVDgyyOI74YlLfNmuVuYFvGut8aoTgBGHHkwZ4bq14ljqqGmQKCnkkhxEPS40bI8wBNbggQ4oU8szXjd1lL8xfi1epGtRXgyyOI1mEaun(scxEPS4eiJkjxJIYL3qiWMgpCGiV12zGHHkUJlVuwCYq9sj)vbsnXdU8szX52zGHHkUJlVuwCYq9sj)vbsnXJ34wPY4AflZGzabpHnHfZRkbpH22zGHHkUJlVuwCYq9sj)vbsnXdkJhCgIIrP9Nazuj5AuuoU8szXP7f)XkEx02odmmuXDC5LYItgQxk5VkqQjEK3gygslyzgmdi4jSjSyEvj4j0aYOssP)fayQqqhnxEBGziTGLzWmDqeQbI8wU34wPY4AflZGzUx8hR40NOVoic1arElhLXdodrXO0(t3l(JvC6t0F7mWWqf3XLxklozOEPK)QaPM4rEBGziTGLzWmGGNWMWI5vLGNqB7SD2odmmuXDqWeRaaLjS00KIfhcZ7Hfclmv53odmmuXDqWut8qJlmleFGQXxsAA84rACMkQbkfRVP5pQY2zGHHkUdcMAIh5necKrP9NBNbggQ4oiyQjEKlpx(mRu3oDBXPp5YIvipCkzX0H(xQyXg1IprAlEEzX(gNBL6INyXnz4XIPTyf(Ww8uGl2lQsFJfdN(flL8QNl2RfhwTyL407I5cevG8TZaddvChem1epMhoLWc0)sfazujWdZ5pPLo4HrFcnDsjV6PlmFHfiM)Kg9jkXP3TZaddvChem1epAM6rWzPNgOQVuX2zGHHkUdcMAIhu2l5necC7mWWqf3bbtnXJPGcp(PXGtRTDgyyOI7GGPM4rG0GhmefduM4y7SD2oDBXa2c1O1IfpWWq1IBgp2odmmuXD8iXkaqzclnnPyXHW8EyHWctv(TZaddvChpsnXJaPbpyikgOmXX2zGHHkUJhPM4bpqVptMpoytbYOSxaYOssjxJIYXd07ZK5Jd2uGmk7fNw)2PBlo9jxwScyCRux8vRwSN1Gzl2Rfhlw)fZJbMXxmIAXxfyXg1IN((MbN8MSDgyyOI74rQjE8g3kvgxRyzgmdi4jSjSyEvj4j0aYOsgaxEleh3RrfShPvGhinU4KAYBcOUCnkkh3RrfShPvGhinU44XaZs0F70TfdSiG8fhOfNll(fVVfHulMc9lwzpLcz7mWWqf3XJut8414hwPYsVbuyETceiJkjxJIY9A8dRuzP3akmVwb6arElDP0)camviOJM714hwPYsVbuyETcC7mWWqf3XJut8qk5vna3kvM0S0ShiJkjL(xaGPcbD0CHPkpRFA(BNUTy60N2I5sS4CuPXxmevGwyOAABNUTyfE4XIvUnWmKwSypRbZwSr5z2oDBXPBXk0xaWqA8fRGPWa2l27WxCHIfRCBGziTyXEwdMTD62It3IvUnWmKwSypRbZszXgFXdaJ1M8MSD62It3IbSqAPVVS4cflEIf7pPTyf(W2odmmuXD8i1epYBdmdPfSmdMbe8e2ewmVQe8eAazujP0)camviOJMlVnWmKwWYmyMo4H58N0sh8WOpHMoUeSCuPXDHjV(0yDVhQlxJIYLJYy9pc6063oDBXk8WJf7PqHNeDl2Ow8jsBXETwBXQJvlgqlg9l2h9YIv4dB7mWWqf3XJut8GY4bdrXIdH59WcHfMQ8azujkfEyDLOVE2oDBXk8WJftNPk)IvOtZFXgLNz70TfNUfRqFbadPXxScMcdyVyVdFXfkwmDMQ8lwHon)Tt3wC6wSc9famKgFXkykmG9I9o8fxOyXkif0IvkWEY0PG8ml(fqTcCQyX5cC04YIrulooKfRGk5vpxm8qGzaT4seq(Id0IZLf)I33IqQftH(fRSNsHONTt3wC6wmGfsBXETwBXWPFXkOsE1ZfNluOxwCjPflwbtHbS3oDBXPBXawiTf71ATfRowTy9xm6xSp6LfRWh22zGHHkUJhPM4ryQYZ6NMpqWtytyX8QsWtObKrLKs)laWuHGoAUWuLN1pnFDWdRReaPtk5vpDH5lSaX8N06s)TZaddvChpsnXJWuLN1pnFGGNWMWI5vLGNqdiJkjL(xaGPcbD0CHPkpRFA(6GhMZFslDWdJ(e91LRrr54YlLfNoqK3sheHAGiVLJY4bdrXIdH59WcHfMQ8Ux8hR40lL8QNUW8fwGy(tABNbggQ4oEKAIhEpSVzLkd8hvuX61k4X2PBl2tH8ulwJpQYI9AXXIVEnQyXkasRapqACz7mWWqf3XJut8GY4bNHOyuA)jqgvc8WOpbq6KsE1txy(clqm)jn613PxDdGlVfIJ71Oc2J0kWdKgxC)uzDbOTt3wScp8yXkGXTsDXxTAXEwdMTyJYZSD62It3IbSqAlEEzXACRux8vb5PaAXtbU4tK2IpgaKfdOfJ(f7JEzXk8HTyfcWa2lU7kzXOFX(OxwSuYREUypzfyX6DXOFX(OxwScFyBNUT40TyalK2INxwSg3k1fFLxklobAXaMfJ(f7JEzXCbIkq(IFXFSAXOAXXHSyic1arERfJOw8vEPS4eOfpf4IprAl(yaqwmGwm6xSp6LfRWh2IviadyV4URKfJ(f7JEzXsjV65I9KvGfR3fJ(f7JEzXk8HT4TZaddvChpsnXJ34wPY4AflZGzabpHnHfZRkbpHgqgvIsvk8WOpbq6KsE1t6t6Us0JIkcpm6t0RE0P0yAsfoU8szXPtQjVjGkQieHAGiVLJlVuwC6EXFSItFcGrp6szaC5TqCCVgvWEKwbEG04ItQjVjGBNUTyfE4XI9ugp4lgrTypL2FUyJYZSD62It3IbSqAlEEzXACRux8vb5P2odmmuXD8i1epOmEWzikgL2FcKrLKsmnPchxEPS40j1K3eqDkDaC5TqCCVgvWEKwbEG04I7NkRlaPOIqeQbI8woVh23SsLb(JkQy9Af8W9I)yfVlAaspBNUTyfE4XIvGRNDXgLNz70TfNUfdyH0w88YI14wPU4RcYtTypzfyXNiTfpVSynUvQl(kVuwCU4PaxSExm6xSp6LfZfiQa5l(f)XQfJQfhhYIHiude5TwmIAXx5LYIZTZaddvChpsnXJ34wPY4AflZGzabpHnHfZRkbpHgqgvceHAGiVLJlVuwC6EXFSItFIEvurLMsmnPchxEPS40j1K3eq9OlLbWL3cXX9Aub7rAf4bsJloPM8MaUD62Iv4Hhlw52aZqAXI9SgmBXgLNz70TfNUfRqFbadPXxScMcdyVyVdFXfkwSYip72PBloDlgWcPT45LfxOyXtSy)jTfRWh22zGHHkUJhPM4rEBGziTGLzWmGGNWMWI5vLGNqdiJkbIqnqK3Yrz8GZqumkT)09I)yfNE91Ls)laWuHGoAU82aZqAblZGz6KsE1txy(clqm)jn6PPBaC5TqCCVgvWEKwbEG04I7NkJE93oDBXEQ2PvQl(kFVuXI9SgmBXuOFX(dpK)CXVWLGVD62IhyyOI74rQjEq1oTsLXLVxQGLzWmGmQK(xaGPcbD0C5TbMH0cwMbZ0jL8QNUW8fwGy(tA0RVo4HrpnGSkK)16JeABNbggQ4oEKAIh5TbMH0cwMbZacEcBclMxvcEcnGmQKCnkkh3RrfShPvGhinU44XaZ6sFDP0)camviOJMlVnWmKwWYmy22PBlwbNOoWZftH(ft3HSyfKFV8ONVyfE6hOfOF7mWWqf3XJut8a(dmRzLkl9gqH1m1JOSsfiJkr8eAwFVa6IdHj(9YJEodo9d0c0RlxJIYfhct87Lh9CgC6hOfO3XJbMrFcnpxNuYRE6cZxybI5pPrpG2odmmuXD8i1epG)aZAwPYsVbuynt9ikRubYOsepHM13lGU4qyIFV8ONZGt)aTa96Y1OOCXHWe)E5rpNbN(bAb6D8yGz0NqR76Giude5TCC5LYIt3l(Jv8UObiDX0KkCC5LYItNutEta1jL8QNUW8fwGy(tA0dOTZaddvChpsnXJ82aZqAblZGzabpHnHfZRkbpHgqgvsk9Vaatfc6O5YBdmdPfSmdMTDgyyOI74rQjEapmM3baz70Tf7jzT2IlraxCGwCUS4x8(wesTyk0VyL9ukKTt3wScR9VuXIFTM4zwScp8yXk8HTyL1EESyJYZSD62It3IbSqAl(yaqwmGwm6xCt48fRWh22PBloDlwbUE2fB8fR1VyRwSExm6xSp6LfZfiQa5l2twbwSNeGTcDXgFXA9l2QfR3fJ(f7JEzXCbIkq(2PBloDlgWcPTyVwRT4cflgo9lwk5vpxCUqHEzXXHS4sslwScMcdyVDgyyOI74rQjEapmwU2ZdGmQePKx90fMVWceZFsJEA6IPjv44YlLfNoPM8MaUD62Iv4HhlMotv(fRqNM)InkpZ2PBloDlwH(cagsJV4j3AwCUyVdFXfkwmDMQ8lwHon)fJ(fRGk5vna3k1fRGAwA2VD62It3IbSqAl2R1AlwDSAXtS4Mm8yX6Vyf(WaAXEYkWIprAl2R1Algo9lwk5vpxSxloSAXaAXCbIkq(IvkWEY0PG8mlwHrAnWfdhESy6uOlwaqQfpXI17Iv4dBXPNgpwCGwC)laivSyPKx9CXWPV3kvGwSvlooe0FQNTZaddvChpsnXJWuLN1pnFGGNWMWI5vLGNqdiJkjL(xaGPcbD0CHPkpRFA(6sP)fayQqqhnNuYRAaUvQmPzPzVoLcpmN)Kw6Ghg9j6ROIsjV6PlmFHfiM)Kwxasp6sjxJIYXLxkloDA9BNbggQ4oEKAIhWdJLR98aiJkbEyo)jT0bpm6taKoPKx90fMVWceZFsJEA6sjMMuHJlVuwC6KAYBc42zGHHkUJhPM4ryQYZ6NMpqgvskCPjWWq12z7SD62IviWWqf3PqqkOfB8fBvifOaUyk0VynUSyVwCSyf8fyyqMcbeKPWnzaqw8uGlgQ9Vur7CXLiG8fhOfNllg1hMVb4c42zGHHkUBqscCAn2addvSMXdGQXxsGGBNbggQ4UbjPM4HuYRAaUvQmPzPzpqgvsk9Vaatfc6O5ctvEw)081bpSUsOPtPqeQbI8wU34wPY4AflZGzUx8hR4jkrrfvAmnPchLXdgIIfhcZ7Hfclmv5Dsn5nbuheHAGiVLJY4bdrXIdH59WcHfMQ8Ux8hR4jkrpkQOuYRE2LEvIE2odmmuXDdssnXJ5HtjSa9Vubqgvc8WC(tAPdEy0NqtNuYRE6cZxybI5pPrFIsC6D7mWWqf3nij1epOmEWzikgL2FcKrLettQWXLxkloDsn5nbuxkINqZ67fqh4BvMvQSd0xmica51brOgiYB54YlLfNUx8hR40NOxDsjV6PlmFHfiM)Kg96VDgyyOI7gKKAIhugp4mefJs7pbYOsIPjv44YlLfNoPM8MaQt8eAwFVa6aFRYSsLDG(IbraiVoLcrOgiYB54YlLfNUx8hR40NqtVkQieHAGiVLJlVuwC6EXFSI3vs31JoPKx90fMVWceZFsJE93odmmuXDdssnXdkJhCgIIrP9NazujPettQWXLxkloDsn5nbuNuYRE6cZxybI5pPrV(BNbggQ4UbjPM4bLXdodrXO0(tGmQeic1arEl3BCRuzCTILzWm3l(JvC6taKtV6Ghwxj6D7mWWqf3nij1ep8EyFZkvg4pQOI1RvWJTZaddvC3GKut84nUvQmUwXYmygqWtytyX8QsWtObKrLO0yAsfoVh23SsLb(JkQy9Af8Wj1K3eqDqeQbI8woVh23SsLb(JkQy9Af8W9I)yfVlviOE0Ls)laWuHGoAU34wPY4AflZGz6Giude5TCugp4mefJs7pDV4pwXPxfcUDgyyOI7gKKAIhWdJLR98aiJkbEyDLaiDkfIqnqK3Y9g3kvgxRyzgmZ9I)yfN(e9QOIqeQbI8woVh23SsLb(JkQy9Af8W9I)yfN(e9QhDsjV6PlmFHfiM)Kg902odmmuXDdssnXd4HXY1EESDgyyOI7gKKAIh8ERkRuzWFkHLzWmGmQeLoWWaqysj(MWPpbqkQOsZ1OOC5Omw)JGoTEDWdZ5pPLo4HrFIs0JE0Ls)laWuHGoAoEVvLvQm4pLWYmyMoUeSCuPXDHjV(0yDVhUDgyyOI7gKKAIh8ERkRuzWFkHLzWmGmQKbggactkX3eo9jasxk9Vaatfc6O549wvwPYG)uclZGz6Giude5TCugp4mefJs7pDV4pwXPxfcUDgyyOI7gKKAIh5TbMH0cwMbZacEcBclMxvcEcnGmQKu6FbaMke0rZL3gygslyzgmth8WC(tAPdEy0NqthxcwoQ04UWKxFASU3d1P0u4sWYrLg3fM808CM(9qfvmMMuHJlVuwC6KAYBcOE2odmmuXDdssnXJ82aZqAblZGzabpHnHfZRkbpHgqgvIsHhg90uuXCnkkxokJ1)iOtRxrfvAmnPcNuYRAaUvQmPzPzVtQjVjG6Giude5TCsjVQb4wPYKMLM9Ux8hR4DbrOgiYB5OmEWzikgL2F6EXFSIRh9OtPkfIqnqK3Y9g3kvgxRyzgmZ9I)yfNEA6uAkX0KkCugpyikwCimVhwiSWuL3j1K3eqfveIqnqK3Yrz8GHOyXHW8EyHWctvE3l(JvC6PPhfveEy03D9OtPqeQbI8wokJhCgIIrP9NUx8hR40ttrfHhg96RhfvS)fayQqqhnxyQYZ6NMVE0Ls)laWuHGoAU82aZqAblZGzBNbggQ4UbjPM4b8hywZkvw6nGcRzQhrzLkqgvI4j0S(Eb0fhct87Lh9CgC6hOfOxxUgfLloeM43lp65m40pqlqVJhdmJ(eAEUoPKx90fMVWceZFsJEaTDgyyOI7gKKAIhWFGznRuzP3akSMPEeLvQazujINqZ67fqxCimXVxE0ZzWPFGwGED5AuuU4qyIFV8ONZGt)aTa9oEmWm6tO1DDqeQbI8woU8szXP7f)XkEx0aKUyAsfoU8szXPtQjVjG6KsE1txy(clqm)jn6b02zGHHkUBqsQjEK3gygslyzgmdi4jSjSyEvj4j0aYOssP)fayQqqhnxEBGziTGLzWmDWdZ5pPLo4HrFcnDCjy5OsJ7ctE9PX6EpuxUgfLlhLX6Fe0P1VDgyyOI7gKKAIhHPkpRFA(abpHnHfZRkbpHgqgvsk9Vaatfc6O5ctvEw)081Ls)laWuHGoAoPKx1aCRuzsZsZEDkfEyo)jT0bpm6t0xrfLsE1txy(clqm)jTUaKE2odmmuXDdssnXJWuLN1pnFGGNWMWI5vLGNqdiJkjL(xaGPcbD0CHPkpRFA(6sP)fayQqqhnNuYRAaUvQmPzPzVoPKx90fMVWceZFsRReA6GhMZFslDWdJ(e93odmmuXDdssnXd4HX8oaiazujWdRReaPtPqeQbI8wU34wPY4AflZGzUx8hR40NOxfveIqnqK3Y59W(MvQmWFurfRxRGhUx8hR40NOx9Otk5vpDH5lSaX8N0ON22zGHHkUBqsQjEapmM3baz7mWWqf3nij1epctvEw)08bYOssHlnbggQibjiea]] )
end