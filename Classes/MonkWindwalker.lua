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

    spec:RegisterPack( "Windwalker", 20180815.1715, 
        [[d40MQbqisfpcc6siKqTjKQprQumkirNcsYRufmlKIBbj1UKYVesnmHKogKAzsL8miHPPkKRHuY2qi4BQcvJJuPY5KkvwNQqzEqG7jvTpi0bLkvTqsvEiPsMOqIUisPSreI(icPmsesWjjvkvRuQ4LiK0mrir3KuPu2jc1pjvQAOiKQLkvk9uenve0vriH8vsLsolcH2lj)LWGLCyvwSs1JHAYQQlJAZKYNrYOfQtt1Qfs41q0SvYTf0Uv8BqdxPCCKs1YbEortx01fy7QI(UqmEsvDEvP1lvkMpcSFkRqRiur(VKve3vurR7IQUdnTAOFC0pIwkY8DJvKBhg5rXkY5czfPULp)i3cjduKB37cEFfHksjmaGzfzCMBYhl6OP8moyVHHHrl9WG1LoCWGtlJw6H4O3xW9O31ou)5NrVbGA(ILrtOZGUqhnHDHwOBdoif6w(8JClKmOj9qSICpWxPU9rTRi)xYkI7kQO1Drv3HMwn0po6UqR7uKYngRiUlIq3Pi)SeRijm2Lw5sRYy2QpRDbR0kDlF(rUfsgy1HthowTDyKwPbbwP3L5ITsdcSQ77ggaZ4M1X6OBZhiWQ7hfbYmKNuAvegWwfEF2knam0QmMTI0ddwx6WrxGtlTQ7j6eLwT8bj)TcowLXSvBaOMVyRYBVzDSo6k(gk(BvEakofUMvy4890HZTKwLqRWV4flYdqXP0kuMhGItHRzLlTAGPvYGTnii5pQAwhRJUIVHI)wPRBTSQ7XPdhRikDzAfpjWzPvAqGvDVUN2S6MVvKeAvcTQBdgR6EC6WXkIsxMwj9bZwLX8RvhGTkmidU161kwF8kq6p5M1X609)p)TA)WirDWMvagddd55FPdhPvAqGve6umWkI(TcTksmpwnWm2hkR4LKTkYjTcWyyyipF(BfQrTvzSlTkIVwwfidU161QD2kApWXixVOgWpDPN83QtALNw5sR2aW9BF9A1zfHeDRcDPSPixUmLkcvK4VIqfXOveQipC6Wrr6ZtiswOFapksEU9f)v6PsfXDPiurE40HJICFbHFHwa4vrYZTV4VspvQigfkcvKhoD4Oi3zGKbi9HsrYZTV4VspvQi(rkcvK8C7l(R0trIbEYa)uK4yVfE6BfQTch7wHyVvOTIUv8WaQ3w6HSiHIWtFRqS3QO2OLI8WPdhf5bW3WIeca8KQurmTueQipC6WrrUCQ4ukIIGpvipPIKNBFXFLEQurmrqrOI8WPdhfPMd49fe(vK8C7l(R0tLkIFCfHkYdNoCuK3GzzcULaFRLIKNBFXFLEQurSUtrOIKNBFXFLEksmWtg4NIKP9aFBJ)Ty))5reEYKbsHgeS7)ppIegGJTIUv6y1gGFkOW)g6wcdWXcOM4ZxgRipC6WrrMWaCSaQj(8LXks8lEXI8auCkveJwLkI7ofHksEU9f)v6PiXapzGFksuAfkTkVfpztYaE88TXZTV4Vv0TcdHRpmY0KmGhpFBao88rAfc6TcTvOYk6wHHW1hgzAAUmLcOMqla82aC45J0ke0B1JScvwr3kmeU(Witd4sFOeYGrG0XiBao88rAfcS6XTIUv6y1gGFkOW)g6wcdWXcOM4ZxgRipC6WrrMWaCSaQj(8LXks8lEXI8auCkveJwLkIrhvfHksEU9f)v6PiXapzGFksuAfkTshRYBXt2KmGhpFB8C7l(BfDRWq46dJmnzcbHc(azS4MVqZbCdWHNpsRqqVvOTcvwrabwHJDRqS3QUScvwr3kmeU(WittZLPua1eAbG3gGdpFKwHGEREKv0TcdHRpmY0aU0hkHmyeiDmYgGdpFKwHaRECROBLowTb4Nck8VHULWaCSaQj(8LXkYdNoCuKjmahlGAIpFzSIe)IxSipafNsfXOvPkvKFw7cwPIqfXOveQipC6WrrEbjuCzEyKksEU9f)v6PsfXDPiurE40HJIuUXhqeFZxitGJKvK8C7l(R0tLkIrHIqfjp3(I)k9uKyGNmWpfPowL3INSr0GWVGOEGWRXZTV4VI0NKbpVLIS7IQICdNIy(wzSImQnAPipC6WrrMWaCSaQjqEGWtLkIFKIqfPpjdEElfz3fvf5gofX8TYyfj6wuvKhoD4Oityaowa1eipq4Pi552x8xPNkvetlfHksEU9f)v6PiXapzGFkY9anTMKb845BlyZkciWQ9anTMmHGqbFGmwCZxO5aUfSzfbeyfkTshRYBXt2KmGhpFB8C7l(BfDRsGpi5STbG42r5lpFBa(WPvOYkciWQ9anT2(cc)Raz2a8HtRiGaRYdqXzl9qwKqX3zRqqVveHOQipC6WrrUbthoQurmrqrOIKNBFXFLEksmWtg4NImpafNT0dzrcfFNTcb9w1DkYdNoCuKjmahlGAIpFzSkve)4kcvK8C7l(R0trE40HJIeFRL4WPdhXYLPIed8Kb(PirPv5T4jBsgWJNVnEU9f)TIUvyiC9HrMMKb845BdWHNpsRqqVvr1kuzfbey1EGMwtYaE88TfSPixUmfZfYksjd4XZxvQiw3PiurYZTV4Vspf5Hthoks8TwIdNoCelxMksmWtg4NIuhRYBXt2KmGhpFB8C7l(BfDRqPv7bAAnzcbHc(azS4MVqZbClyZkciWkmeU(WittMqqOGpqglU5l0Ca3WXhGILw1BvxwHkf5YLPyUqwrkznvQiU7ueQi552x8xPNI8WPdhfj(wlXHthoILltfjg4jd8trIsR0XQ8w8Knjd4XZ3gp3(I)wr3kmeU(WittZLPua1eAbG3gGdpFKwHGERq3Lv0Tch7wHyVvOWk6wHHW1hgzAax6dLqgmcKogzdWHNpsRqqVvOTcvwrabwLhGIZw6HSiHIVZwHGER6IwwrabwHHW1hgzAjmahlGAIpFzCdWHNpsRq0k0O7srUCzkMlKvKswtLkIrhvfHksEU9f)v6PipC6WrrIV1sC40HJy5YurIbEYa)uKO0kDSkVfpztYaE88TXZTV4Vv0TshRyApW324F7d8bPpuIyiyey4tgyfDRWq46dJmnnxMsbutOfaEBao88rAfc6TIiyfDRWXUvi2BfkSIUvyiC9HrMgWL(qjKbJaPJr2aC45J0ke0BfARqLveqGv5bO4SLEilsO47SviO3k00YkciWkmeU(WitlHb4ybut85lJBao88rAfIwHgDxwr3kmeU(WittMqqOGpqglU5l0Ca3WXhGILw1BfAf5YLPyUqwrkznvQignAfHksEU9f)v6PipC6WrrIV1sC40HJy5YurIbEYa)uKO0kDSkVfpztYaE88TXZTV4Vv0TcdHRpmY00CzkfqnHwa4Tb4WZhPviO3k0DzfDRWXUvi2BfkSIUvyiC9HrMgWL(qjKbJaPJr2aC45J0ke0BfARqLveqGv5bO4SLEilsO47SviO3QUOLveqGvyiC9HrMwcdWXcOM4Zxg3aC45J0keTcn6USIUvyiC9HrMMmHGqbFGmwCZxO5aUHJpaflTQ3k0kYLltXCHSIuYAQurm6UueQi552x8xPNI8WPdhfjiyehoD4iwUmvKyGNmWpf5Ht)jl4HdDwAfIwHcf5YLPyUqwrEqwLkIrJcfHksEU9f)v6PipC6WrrccgXHthoILltfjg4jd8trE40FYcE4qNLwHGERqHIC5YumxiRiLPkvPICdWyy4(LkcveJwrOIKNBFXFLEQurCxkcvK8C7l(R0tLkIrHIqfjp3(I)k9uPI4hPiurYZTV4VspvQiMwkcvKhoD4Oi3GPdhfjp3(I)k9uPIyIGIqf5HthoksCSl2daYurYZTV4VspvQi(XveQipC6WrrIJDrK7jRi552x8xPNkvPIuYaE88vrOIy0kcvK8C7l(R0trIbEYa)uK7bAAT9fe(xbYSfSzfDR0XQ9anTMKb845BlytrE40HJIuZLPaQjYywej2twKofduPI4UueQi552x8xPNIed8Kb(Pi1XQna)uqH)n0T0PyGy7wHwr3kDSAdWpfu4FdDJhgq5DJpucE567aROBfpmG61QER4HbuVTWtFROBfo2TcbwH2k6wPJv7bAAnjd4XZ3wWMI8WPdhfz6umqSDRqfj(fVyrEakoLkIrRsfXOqrOIKNBFXFLEkYdNoCuK4BTehoD4iwUmvKlxMI5czfj(RsfXpsrOIKNBFXFLEksmWtg4NImVfpzdeiJ9Hsef3Nfr853452x83k6wPJvBa(PGc)BOBGazSpuIO4(SiIpFROB1EGMwdeiJ9Hsef3Nfr853(WiJI8WPdhfjiqg7dLikUplI4ZxLkIPLIqf5Hthoksjd4XZxfjp3(I)k9uPIyIGIqfjp3(I)k9uKhoD4OibU0hkHmyeiDmsfj(fVyrEakoLkIrRsfXpUIqfjp3(I)k9uKyGNmWpf5gGFkOW)g6gWL(qjKbJaPJrAfDR2a8tbf(36QjzapE(QipC6WrrQ5YukGAcTaWRkveR7ueQi552x8xPNI8WPdhfjWL(qjKbJaPJrQiXV4flYdqXPurmAvQiU7ueQi552x8xPNIed8Kb(Pi1XQna)uqH)n0T91HrcdsbshJ0k6wHHW1hgzAax6dLqgmcKogzdWHNpsRqS3QUSIUvyiC9HrMMMltPaQj0caVnahE(iTcXER6srE40HJICFDyKWGuG0XivK4x8If5bO4uQigTkveJoQkcvK(KmaeSLks0ksEU9f)v6PipC6WrrQ5YukGAcTaWRIed8Kb(PirPvO0kDSIP9aFBJ)TpWhK(qjIHGrGHpzGveqGv7bAAT9fe(xbYSfSzfbey1EGMwtYaE88Tb4WZhPviWk0wHkROBfkTcdHRpmY0aU0hkHmyeiDmYgGdpFKwHOvOTIacS6WP)Kf8WHolTcrRqBfQScvQurmA0kcvK8C7l(R0trIbEYa)uKho9NSGho0zPvi2BfkSIUv6y1gGFkOW)g6MCZNXhkbgCdlq6yKkYdNoCuKYnFgFOeyWnSaPJrQsfXO7srOIKNBFXFLEksmWtg4NI8WP)Kf8WHolTcXERqHI8WPdhfjWL(qjKbJaPJrQiXV4flYdqXPurmAvQignkueQi552x8xPNIed8Kb(Pi1XQna)uqH)n0n5MpJpucm4gwG0XivKhoD4OiLB(m(qjWGBybshJuLkIr)ifHksEU9f)v6PiXapzGFksDSAdWpfu4FdDBFDyKWGuG0XivKhoD4Oi3xhgjmifiDmsfj(fVyrEakoLkIrRsvQiLSMIqfXOveQi552x8xPNIed8Kb(Pi1XQna)uqH)n0T0PyGy7wHwr3kDSAdWpfu4FdDJhgq5DJpucE567aROBfpmG61QER4HbuVTWtFROBfo2TcbwHwrE40HJImDkgi2UvOImpafNcxtr(59anTw4bqkGAImMfyWnC7dJmQurCxkcvK8C7l(R0trE40HJIeFRL4WPdhXYLPIC5YumxiRiXFvQigfkcvK8C7l(R0trIbEYa)uK6y1EGMwtMqqOGpqglU5l0Ca3c2uKhoD4OiLjeek4dKXIB(cnhWQur8JueQi552x8xPNI8WPdhfj(wlXHthoILltfjg4jd8trE40FYcE4qNLwHOvOqrUCzkMlKvKhKvPIyAPiurYZTV4Vspf5Hthoks8TwIdNoCelxMksmWtg4NI8WP)Kf8WHolTcb9wHcf5YLPyUqwrktvQsfPmveQigTIqf5HthoksFEcrYc9d4rrYZTV4VspvQiUlfHksEU9f)v6PiXapzGFksDSApqtRjtiiuWhiJf38fAoGBbBkYdNoCuKYeccf8bYyXnFHMdyvQigfkcvK8C7l(R0trIbEYa)uK7bAAnqGm2hkruCFweXNF7dJmwr3kDSAdWpfu4FdDdeiJ9Hsef3Nfr85RipC6WrrccKX(qjII7ZIi(8vPI4hPiurYZTV4Vspfjg4jd8trQJvBa(PGc)BOBPtXaX2TcvKhoD4Oi5HbuE34dLGxU(oqLkIPLIqfjp3(I)k9uKyGNmWpfPowTb4Nck8VHUTVomsyqkq6yKwr3kCS3cp9Tc1wHJDRqS3k0wr3kjNID4eiBPZGUqlE0g2k6wThOP12HifBaiUfSPipC6WrrUVomsyqkq6yKks8lEXI8auCkveJwLkIjckcvK8C7l(R0trIbEYa)uK6y1gGFkOW)g6w6umqSDRqROBLowTb4Nck8VHUXddO8UXhkbVC9DGv0TIhgq92spKfjueE6Bfc6TcTv0Tch7TWtFRqTv4y3ke7TQlROBLowThOP1KmGhpFBbBkYdNoCuKPtXaX2TcvK4x8If5bO4uQigTkve)4kcvK8C7l(R0trIbEYa)uK4yVfE6BfQTch7wHyVvOqrE40HJIuZLPaQjYywej2twKofduPIyDNIqf5HthokYiXoy5dL4dok4i2cgCSIKNBFXFLEQurC3PiurYZTV4Vspfjg4jd8trIsRqPv4y3ke7Tcfwr3kEya1Rvi2B1JIQvOYkciWkCSBfI9wrlRqLv0TcLwL3INSjzapE(2452x83kciWkmeU(WittYaE88Tb4WZhPvi2BfrWkuPipC6WrrcCPpuczWiq6yKks8lEXI8auCkveJwLkIrhvfHksEU9f)v6PiXapzGFkY8w8Knjd4XZ3gp3(I)wr3kDSIP9aFBJ)TpWhK(qjIHGrGHpzGv0TcdHRpmY0KmGhpFBao88rAfI9wrlROBfpmG6TLEilsOi803keTQlf5HthoksnxMsbutOfaEvPIy0OveQi552x8xPNIed8Kb(PiZBXt2KmGhpFB8C7l(BfDRyApW324F7d8bPpuIyiyey4tgyfDRqPvyiC9HrMMKb845BdWHNpsRqS3k00YkciWkmeU(WittYaE88Tb4WZhPviO3QhzfQSIUv8WaQ3w6HSiHIWtFRq0QUuKhoD4Oi1CzkfqnHwa4vLkIr3LIqfjp3(I)k9uKyGNmWpfPowL3INSjzapE(2452x8xrE40HJIuZLPua1eAbGxvQignkueQi552x8xPNIed8Kb(PiXq46dJmnjd4XZ3gGdpFKwHyVv0YkciWkuALowL3INSjzapE(2452x83kuPipC6WrrcCPpuczWiq6yKks8lEXI8auCkveJwLkIr)ifHksEU9f)v6PiXapzGFksDSAdWpfu4FdDBFDyKWGuG0XiTIUv4yVfE6BfQTch7wHyVvOvKhoD4Oi3xhgjmifiDmsfj(fVyrEakoLkIrRsfXOPLIqfjp3(I)k9uKyGNmWpfjt7b(2g)Bzml4Wngabsb(2oSNqGv0TApqtRLXSGd3yaeif4B7WEcbnzEyKwHyVvO7oROBfpmG6TLEilsOi803keTcfkYdNoCuKyWHrU8Hsef3NflNkohFOuPIy0ebfHksEU9f)v6PiXapzGFksM2d8Tn(3YywWHBmacKc8TDypHaROB1EGMwlJzbhUXaiqkW32H9ecAY8WiTcXERq)iROBfgcxFyKPjzapE(2aC45J0keyfAuyfDRYBXt2KmGhpFB8C7l(BfDR4HbuVT0dzrcfHN(wHOvOqrE40HJIedomYLpuIO4(Sy5uX54dLkveJ(XveQi552x8xPNIed8Kb(Pi1XQna)uqH)n0T91HrcdsbshJurE40HJICFDyKWGuG0XivPIy06ofHkYdNoCuK4yxe5EYksEU9f)v6PsfXO7ofHksEU9f)v6PiXapzGFksEya1Bl9qwKqr4PVviAfAROBvElEYMKb845BJNBFXFf5HthoksCSl2daYuLkI7kQkcvK8C7l(R0trIbEYa)uK6y1gGFkOW)g6w6umqSDRqROBLowTb4Nck8VHUXddO8UXhkbVC9DGv0TcLwHJ9w4PVvO2kCSBfI9w1LveqGv8WaQ3w6HSiHIWtFRqGvOWkuzfDR0XQ9anTMKb845BlytrE40HJImDkgi2UvOIe)IxSipafNsfXOvPI4UqRiurYZTV4Vspfjg4jd8trIJ9w4PVvO2kCSBfI9wHcROBfpmG6TLEilsOi803keTcTv0TshRYBXt2KmGhpFB8C7l(RipC6WrrIJDXEaqMQurCxDPiurYZTV4Vspfjg4jd8trUb4Nck8VHULofdeB3k0k6wPJvsEX40HJI8WPdhfz6umqSDRqvQsf5bzfHkIrRiurYZTV4Vspf5Hthoks8TwIdNoCelxMkYLltXCHSIe)vPI4UueQi552x8xPNIed8Kb(Pi1XQna)uqH)n0T0PyGy7wHwr3kCSBfc6TcTv0TcLwHHW1hgzAax6dLqgmcKogzdWHNpsR6TkQwrabwHsRYBXt20CzkGAImMfrI9KfPtXGgp3(I)wr3kmeU(WittZLPaQjYywej2twKofdAao88rAvVvr1kuzfbeyfpmG61keyfTIQvOsrE40HJIKhgq5DJpucE567avQigfkcvK8C7l(R0trIbEYa)uK4yVfE6BfQTch7wHyVvOTIUv8WaQ3w6HSiHIWtFRqS3QO2OLI8WPdhf5bW3WIeca8KQur8JueQi552x8xPNIed8Kb(PiZBXt2KmGhpFB8C7l(BfDR0XkM2d8Tn(3(aFq6dLigcgbg(Kbwr3kmeU(WittYaE88Tb4WZhPvi2BfTSIUv8WaQ3w6HSiHIWtFRq0QUuKhoD4Oi1CzkfqnHwa4vLkIPLIqfjp3(I)k9uKyGNmWpfzElEYMKb845BJNBFXFROBft7b(2g)BFGpi9HsedbJadFYaROBfkTcdHRpmY0KmGhpFBao88rAfI9wHMwwrabwHHW1hgzAsgWJNVnahE(iTcb9w9iRqLv0TIhgq92spKfjueE6BfIw1LI8WPdhfPMltPaQj0caVQurmrqrOIKNBFXFLEksmWtg4NIuhRYBXt2KmGhpFB8C7l(BfDR4HbuVT0dzrcfHN(wHOvDPipC6WrrQ5YukGAcTaWRkve)4kcvK8C7l(R0trIbEYa)uKyiC9HrMgWL(qjKbJaPJr2aC45J0ke7TcfnAzfDRWXUviO3kAPipC6WrrQ5YukGAcTaWRkveR7ueQipC6Wrrgj2blFOeFWrbhXwWGJvK8C7l(R0tLkI7ofHksEU9f)v6PiXapzGFksmeU(WitlsSdw(qj(GJcoITGbh3aC45J0ke7TIc)TIUv6y1gGFkOW)g6gWL(qjKbJaPJrAfDRWq46dJmnnxMsbutOfaEBao88rAfIwrH)kYdNoCuKax6dLqgmcKogPkveJoQkcvK8C7l(R0trIbEYa)uK4y3ke0BfkSIUvO0kmeU(Witd4sFOeYGrG0XiBao88rAfI9wrlRiGaRWq46dJmTiXoy5dL4dok4i2cgCCdWHNpsRqS3kAzfQSIUv8WaQ3w6HSiHIWtFRq0k0kYdNoCuK4yxShaKPkveJgTIqf5HthoksCSl2daYurYZTV4VspvQigDxkcvK8C7l(R0trIbEYa)uKO0QdN(twWdh6S0ke7TcfwrabwHsR2d00A7qKInae3c2SIUv4yVfE6BfQTch7wHyVvr1kuzfQSIUv6y1gGFkOW)g6MCZNXhkbgCdlq6yKwr3kjNID4eiBPZGUqlE0gwrE40HJIuU5Z4dLadUHfiDmsvQignkueQi552x8xPNIed8Kb(PipC6pzbpCOZsRqS3kuyfDR0XQna)uqH)n0n5MpJpucm4gwG0XivKhoD4OiLB(m(qjWGBybshJuLkIr)ifHksEU9f)v6PiXapzGFksDSAdWpfu4FdDBFDyKWGuG0XiTIUv4yVfE6BfQTch7wHyVvOTIUvsof7Wjq2sNbDHw8OnSv0TcLwPJvsof7Wjq2sNbO7orxByRiGaRYBXt2KmGhpFB8C7l(BfQuKhoD4Oi3xhgjmifiDmsfj(fVyrEakoLkIrRsfXOPLIqfjp3(I)k9uKyGNmWpfjkTch7wHOvOTIacSApqtRTdrk2aqClyZkciWkuAvElEYgpmGY7gFOe8Y13bnEU9f)TIUvyiC9HrMgpmGY7gFOe8Y13bnahE(iTcbwHHW1hgzAAUmLcOMqla82aC45J0kuzfQSIUvO0kuAfgcxFyKPbCPpuczWiq6yKnahE(iTcrRqBfDRqPv6yvElEYMMltbutKXSisSNSiDkg0452x83kciWkmeU(WittZLPaQjYywej2twKofdAao88rAfIwH2kuzfbeyfo2TcrREKvOYk6wHsRWq46dJmnnxMsbutOfaEBao88rAfIwH2kciWkCSBfIw1LvOYkciWQna)uqH)n0T0PyGy7wHwHkROBLowTb4Nck8VHUTVomsyqkq6yKkYdNoCuK7RdJegKcKogPIe)IxSipafNsfXOvPIy0ebfHksEU9f)v6PiXapzGFksM2d8Tn(3YywWHBmacKc8TDypHaROB1EGMwlJzbhUXaiqkW32H9ecAY8WiTcXERq3Dwr3kEya1Bl9qwKqr4PVviAfkuKhoD4OiXGdJC5dLikUplwovCo(qPsfXOFCfHksEU9f)v6PiXapzGFksM2d8Tn(3YywWHBmacKc8TDypHaROB1EGMwlJzbhUXaiqkW32H9ecAY8WiTcXERq)iROBfgcxFyKPjzapE(2aC45J0keyfAuyfDRYBXt2KmGhpFB8C7l(BfDR4HbuVT0dzrcfHN(wHOvOqrE40HJIedomYLpuIO4(Sy5uX54dLkveJw3PiurYZTV4Vspfjg4jd8trQJvBa(PGc)BOB7RdJegKcKogPv0Tch7TWtFRqTv4y3ke7TcTv0TsYPyhobYw6mOl0IhTHTIUv7bAATDisXgaIBbBkYdNoCuK7RdJegKcKogPIe)IxSipafNsfXOvPIy0DNIqfjp3(I)k9uKyGNmWpfPowTb4Nck8VHULofdeB3k0k6wPJvBa(PGc)BOB8WakVB8HsWlxFhyfDRqPv4yVfE6BfQTch7wHyVvDzfbeyfpmG6TLEilsOi803keyfkScvkYdNoCuKPtXaX2TcvK4x8If5bO4uQigTkve3vuveQi552x8xPNIed8Kb(Pi1XQna)uqH)n0T0PyGy7wHwr3kDSAdWpfu4FdDJhgq5DJpucE567aROBfpmG6TLEilsOi803ke0BfAROBfo2BHN(wHARWXUvi2BvxkYdNoCuKPtXaX2TcvK4x8If5bO4uQigTkve3fAfHksEU9f)v6PiXapzGFksCSBfc6Tcfwr3kuAfgcxFyKPbCPpuczWiq6yKnahE(iTcXEROLveqGvyiC9HrMwKyhS8Hs8bhfCeBbdoUb4WZhPvi2BfTScvwr3kEya1Bl9qwKqr4PVviAfAf5HthoksCSlICpzvQiURUueQipC6WrrIJDrK7jRi552x8xPNkve3fkueQi552x8xPNIed8Kb(Pi3a8tbf(3q3sNIbITBfAfDR0XkjVyC6WrrE40HJImDkgi2UvOkvPkvKpzG0HJI4UIkADxuF8U6QHgfOFKImYbgFOKksDRUVBjw3oXeThZkRimMTYd3GG0kniWkDZN1UGvQBScW0EGd4VvsyiB1fKWWl5Vv44BOyzZ6qu6dBf6hZkIIgzW2geK83QdNoCSs3CbjuCzEyK6MM1X6OBpCdcs(B1JB1HthowTCzkBwhf5gaQ5lwrIqROn9zCqYFR2zniGTcdd3V0QDMYhzZQUhJ5TuA1ahuhFGqTGLvhoD4iTcoR3M15WPdhzBdWyy4(L9ARtI06C40HJSTbymmC)Yh6Jwdc)wNdNoCKTnaJHH7x(qF0xavip5LoCSoi0kY52KXW0kW5FR2d004VvY8sPv7SgeWwHHH7xA1ot5J0QB(wTbyuVbZ0hkRCPvF4WnRZHthoY2gGXWW9lFOpA5CBYyykK5LsRZHthoY2gGXWW9lFOp6ny6WX6C40HJSTbymmC)Yh6Jgh7I9aGmTohoD4iBBagdd3V8H(OXXUiY9KTowheAfTPpJds(Bf)KbVwLEiBvgZwD4ecSYLwDppFD7lUzDoC6Wr2FbjuCzEyKwNdNoCKp0hTCJpGi(MVqMahjBDqOvecdWXwb1SIOEGWZk4yfgcxFyKHgRCnRiAq43kI6bcpRCPv8C7l(Bft7b3YQeAf6OgvIITcQzv4PVhgeAvmFRm26C40HJ8H(Otyaowa1eipq4rJpjdEER(UlQ0SHtrmFRmUpQnArJR1RtElEYgrdc)cI6bcVgp3(I)04tYGN3QV7IknB4ueZ3kJ7JAJwwNdNoCKp0hDcdWXcOMa5bcpA8jzWZB13DrLMnCkI5BLX9OBr16GqRi6W0HJvUMvKmGhpFTccSImHGqASI2oqgtJv38TIiDaB1byRc2SccS6fgy1byRabZ4dLvsgWJNVwDZ3QZQWZhRK5LwLaFqYPvBaiwsJvqGvVWaRoaBvW8zGvzmBfRPX40kOMv7li8VcKjnwbbwLhGItRspKTkHw9D2kxAffGVKbwbbwX0EWTSkHwreIQ15WPdh5d9rVbtho04A97bAAnjd4XZ3wWgbeShOP1Kjeek4dKXIB(cnhWTGnciaL6K3INSjzapE(2452x8NEc8bjNTnae3okF55BdWhorfbeShOP12xq4FfiZgGpCsab5bO4SLEilsO47mc6jcr16C40HJ8H(Otyaowa1eF(YyACT(8auC2spKfju8Dgb9DN1bHwPRBTSkJzRizapE(A1HthowTCzALRz1lmq3ayRcK(qzfjd4XZxRU5Bfjd4XZxRCPv3ZZx3(ITcLqGvVWaDdGTchaa8KRxR8XksgWJNVOY6C40HJ8H(OX3AjoC6WrSCzsZCHCVKb845lnUwpkZBXt2KmGhpFB8C7l(thdHRpmY0KmGhpFBao88rIG(OIkciypqtRjzapE(2c2Soi0kDDRLvzmBfjTrKwD40HJvlxMw5Aw9cd0na2QaPpuwrsBePv38T6aSv4aaGNC9ALpwrsBePvqGvX3t2QUSIK2isRK5HrkTohoD4iFOpA8TwIdNoCelxM0mxi3lznACTEDYBXt2KmGhpFB8C7l(thL7bAAnzcbHc(azS4MVqZbClyJacWq46dJmnzcbHc(azS4MVqZbCdhFakw23fQSoi0kDDRLvzmBfjTrKwD40HJvlxMw5Aw9cd0na2QbMwfi9HYksgWJNVwDZ)XSoi0kuBfrcjsRWFRqqVvO7Y6GqRqTv6k2TcXERqH1bHwHAR6wsIQv4Vvi2BfARdcTs33TwLXSv5bO40Qi(Az13zRI4zSpw1fTSsYy48LwP77wRiegLw5sRGJvzmBvEakoTohoD4iFOpA8TwIdNoCelxM0mxi3lznACTEuQtElEYMKb845BJNBFXF6yiC9HrMMMltPaQj0caVnahE(irqp6UOJJDe7rbDmeU(Witd4sFOeYGrG0XiBao88rIGE0OIacYdqXzl9qwKqX3ze03fTiGameU(WitlHb4ybut85lJBao88rIiA0DzDqOv66wlRYy2ksAJiT6WPdhRwUmTY1S6fgOBaSvbsFOSIKb845Rv38FmRdcTc1wruK0hkRIsIc6Y6GqRqTvejKiTc)Tcb9wreSoi0kuBLUIDRqS3kuyDqOvO2QULKOAf(Bfc6TcT1bHwP77wRYy2Q8auCAveFTS67Svr8m2hRqtlRKmgoFPv6(U1kcHrPvU0k4yvgZwLhGItRU5B1lmWQ47jBfARK5HrAfuZksAJiTohoD4iFOpA8TwIdNoCelxM0mxi3lznACTEuQtElEYMKb845BJNBFXF66W0EGVTX)2h4dsFOeXqWiWWNmGogcxFyKPP5YukGAcTaWBdWHNpse0teOJJDe7rbDmeU(Witd4sFOeYGrG0XiBao88rIGE0OIacYdqXzl9qwKqX3ze0JMweqagcxFyKPLWaCSaQj(8LXnahE(iren6UOJHW1hgzAYeccf8bYyXnFHMd4go(auSShT1bHwrB6F4C9AvgZwjVq2QtA1gGF6WaPvlFyASApiTkINXwDJv3)ZFRWXmgPvrI5mMbw9cdSk(EYwH2kzEyKwb1SIK2isRZHthoYh6JgFRL4WPdhXYLjnZfY9swJgxRhL6K3INSjzapE(2452x8NogcxFyKPP5YukGAcTaWBdWHNpse0JUl64yhXEuqhdHRpmY0aU0hkHmyeiDmYgGdpFKiOhnQiGG8auC2spKfju8Dgb9DrlciadHRpmY0syaowa1eF(Y4gGdpFKiIgDx0Xq46dJmnzcbHc(azS4MVqZbCdhFakw2J26GqR01TwwLXSvDpK2S6WPdhRwUmTY1SkJzaB1byRcHa2Qm(gRqHv8WHolTohoD4iFOpAqWioC6WrSCzsZCHC)bzACT(dN(twWdh6SeruyDqOv66wlRYy2kscT6WPdhRwUmTY1SkJzaB1byRqHvqGvlwkTIho0zP15WPdh5d9rdcgXHthoILltAMlK7LjnUw)Ht)jl4HdDwIGEuyDSoi0QUhNoCKTUhsBw5sR8j55ZFR0GaRcKSvr8m2kIcmoDSO7)FHUw89KT6MVv4aaGNC9A1W8xAvcTANTcULEO3n836C40HJSDqUhFRL4WPdhXYLjnZfY94V15WPdhz7G8d9rZddO8UXhkbVC9DanUwVoBa(PGc)BOBPtXaX2TcPJJDe0JMokXq46dJmnGl9HsidgbshJSb4WZhzFujGauM3INSP5Yua1ezmlIe7jlsNIbnEU9f)PJHW1hgzAAUmfqnrgZIiXEYI0PyqdWHNpY(OIkciGhgq9IaAfvuzDoC6Wr2oi)qF0haFdlsiaWtsJR1JJ9w4PpQXXoI9OPZddOEBPhYIekcp9rSpQnAzDoC6Wr2oi)qF0AUmLcOMqla8sJR1N3INSjzapE(2452x8NUomTh4BB8V9b(G0hkrmemcm8jdOJHW1hgzAsgWJNVnahE(irSNw05HbuVT0dzrcfHN(i2L15WPdhz7G8d9rR5YukGAcTaWlnUwFElEYMKb845BJNBFXF6mTh4BB8V9b(G0hkrmemcm8jdOJsmeU(WittYaE88Tb4WZhjI9OPfbeGHW1hgzAsgWJNVnahE(irq)JqfDEya1Bl9qwKqr4PpIDzDoC6Wr2oi)qF0AUmLcOMqla8sJR1RtElEYMKb845BJNBFXF68WaQ3w6HSiHIWtFe7Y6C40HJSDq(H(O1CzkfqnHwa4LgxRhdHRpmY0aU0hkHmyeiDmYgGdpFKi2JIgTOJJDe0tlRZHthoY2b5h6JosSdw(qj(GJcoITGbhBDoC6Wr2oi)qF0ax6dLqgmcKogjnUwpgcxFyKPfj2blFOeFWrbhXwWGJBao88rIypf(txNna)uqH)n0nGl9HsidgbshJKogcxFyKPP5YukGAcTaWBdWHNpsePWFRZHthoY2b5h6Jgh7I9aGmPX16XXoc6rbDuIHW1hgzAax6dLqgmcKogzdWHNpse7PfbeGHW1hgzArIDWYhkXhCuWrSfm44gGdpFKi2tlurNhgq92spKfjueE6JiARZHthoY2b5h6Jgh7I9aGmTohoD4iBhKFOpA5MpJpucm4gwG0XiPX16r5Ht)jl4HdDwIypkiGauUhOP12HifBaiUfSrhh7TWtFuJJDe7JkQqfDD2a8tbf(3q3KB(m(qjWGBybshJKUKtXoCcKT0zqxOfpAdBDoC6Wr2oi)qF0YnFgFOeyWnSaPJrsJR1F40FYcE4qNLi2Jc66Sb4Nck8VHUj38z8HsGb3WcKogP15WPdhz7G8d9rVVomsyqkq6yK0GFXlwKhGItzpAACTED2a8tbf(3q32xhgjmifiDms64yVfE6JACSJypA6sof7Wjq2sNbDHw8OnmDuQJKtXoCcKT0za6Ut01gMacYBXt2KmGhpFB8C7l(JkRZHthoY2b5h6JEFDyKWGuG0XiPb)IxSipafNYE004A9Oeh7iIMac2d00A7qKInae3c2iGauM3INSXddO8UXhkbVC9DqJNBFXF6yiC9HrMgpmGY7gFOe8Y13bnahE(iragcxFyKPP5YukGAcTaWBdWHNpsuHk6OeLyiC9HrMgWL(qjKbJaPJr2aC45Jer00rPo5T4jBAUmfqnrgZIiXEYI0PyqJNBFXFciadHRpmY00CzkGAImMfrI9KfPtXGgGdpFKiIgveqao2r8rOIokXq46dJmnnxMsbutOfaEBao88rIiAciah7i2fQiGGna)uqH)n0T0PyGy7wHOIUoBa(PGc)BOB7RdJegKcKogP15WPdhz7G8d9rJbhg5YhkruCFwSCQ4C8HIgxRNP9aFBJ)TmMfC4gdGaPaFBh2tiG(EGMwlJzbhUXaiqkW32H9ecAY8WirShD3rNhgq92spKfjueE6JikSohoD4iBhKFOpAm4Wix(qjII7ZILtfNJpu04A9mTh4BB8VLXSGd3yaeif4B7WEcb03d00Azml4Wngabsb(2oSNqqtMhgjI9OFeDmeU(WittYaE88Tb4WZhjcqJc65T4jBsgWJNVnEU9f)PZddOEBPhYIekcp9refwNdNoCKTdYp0h9(6WiHbPaPJrsd(fVyrEakoL9OPX161zdWpfu4FdDBFDyKWGuG0XiPJJ9w4PpQXXoI9OPl5uSdNazlDg0fAXJ2W03d00A7qKInae3c2SohoD4iBhKFOp60PyGy7wH0GFXlwKhGItzpAACTED2a8tbf(3q3sNIbITBfsxNna)uqH)n0nEyaL3n(qj4LRVdOJsCS3cp9rno2rSVlciGhgq92spKfjueE6JauGkRZHthoY2b5h6JoDkgi2Uvin4x8If5bO4u2JMgxRxNna)uqH)n0T0PyGy7wH01zdWpfu4FdDJhgq5DJpucE567a68WaQ3w6HSiHIWtFe0JMoo2BHN(Ogh7i23L15WPdhz7G8d9rJJDrK7jtJR1JJDe0Jc6OedHRpmY0aU0hkHmyeiDmYgGdpFKi2tlciadHRpmY0Ie7GLpuIp4OGJylyWXnahE(irSNwOIopmG6TLEilsOi80hr0wNdNoCKTdYp0hno2frUNS15WPdhz7G8d9rNofdeB3kKgxRFdWpfu4FdDlDkgi2UviDDK8IXPdhRJ15WPdhzd)795jejl0pGhrgZIiXEYI0PyG15WPdhzd)FOp69fe(fAbGxRZHthoYg()qF07mqYaK(qzDqOvefjzR6Ea(g2kcHaapPvUMvVWaRoaBvOlL(qz1LwT4tMwH2kDf7wDZ3QiWr3KwHVnR4HbuVwfXZyFSkQnAzLKXW5lTohoD4iB4)d9rFa8nSiHaapjnUwpo2BHN(Ogh7i2JMopmG6TLEilsOi80hX(O2OL15WPdhzd)FOp6LtfNsrue8Pc5jTohoD4iB4)d9rR5aEFbHFRZHthoYg()qF03GzzcULaFRL1bHwPRtMwrimkTc)Ix(qzvgdGbuXw1Lv5bO4uALR9ywheAfQTIicd0na2QaPpuwruq3grsO1bHwHARiIWaGvBa(PddKwr00vuAvKtA1atRiegLwNdNoCKn8)H(Otyaowa1eF(YyAWV4flYdqXPShnnUwpt7b(2g)BX()ZJi8KjdKcniy3)FEejmahtxNna)uqH)n0TegGJfqnXNVm26GqRimMTsYy48TcFY0kOMvjmahlGAIpFzSvjWPOya)TA)1QmMTAXu88pWRvSMgJtRGAwf7)ppIWtMmqk0GGD))5rKWaC8JzDqOvO2kIimq38KT6wa((VwHpzAvgZwP5azAfHWO06GqRqTvK0grALlTkVfpj)T6MVvr81YQD2Q755RBFXwTZAqaB1lmay1W6Nwr0wW9BzLUGW1hgzSoi0kuBfregaSAdWpDyG0kIMUIsRICsRgyAfHWO06GqRqTvDlhE(4dLvyiC9HrgRGJvePltRGAwrKbGxRCPvlyegyfeyft7b3YQeA1JSsYy48LwheAfQTQB5WZhFOScdHRpmYyfCSQBDPpuwrgmwruDmsRCPvlyegyvgFJvpUvsgdNV06C40HJSH)p0hDcdWXcOM4Zxgtd(fVyrEakoL9OPX16rjkZBXt2KmGhpFB8C7l(thdHRpmY0KmGhpFBao88rIGE0OIogcxFyKPP5YukGAcTaWBdWHNpse0)iurhdHRpmY0aU0hkHmyeiDmYgGdpFKi4XPRZgGFkOW)g6wcdWXcOM4ZxgBDqOvegZwjzmC(wHpzAfuZQegGJfqnXNVm2Qe4uumG)wT)AvgZwTykE(h41kwtJXPvqnRI9)Nhr4jtgifAqWU))8isyao(XSoi0kuBfregOBEYwDlaF)xRWNmTkJzR0CGmTIqyuADqOvO2QULdpF8HYkmeU(WiJvWXkI0LP0kOMveza41kxA1cgHbwbbwX0EWTSkHw9iRKmgoFPvDpXrPvK0grALlTkVfpj)T6MVvr81YQD2Q755RBFXwTZAqaB1lmay1W6Nwr0wW9BzLUGW1hgzSs33Tw9cdSk(EYw1LvqGvHqaBLUIDRdcTc1wreHbaR2a8thgiTIOPRO0QiN0QbMwrimkToi0kuBv3YHNp(qzfgcxFyKXk4yv36sFOSImySIO6yKw5sROa8LXmWQm(gRECRKmgoFP15WPdhzd)FOp6egGJfqnXNVmMg8lEXI8auCk7rtJR1JsuQtElEYMKb845BJNBFXF6yiC9HrMMmHGqbFGmwCZxO5aUb4WZhjc6rJkciah7i23fQOJHW1hgzAAUmLcOMqla82aC45Jeb9pIogcxFyKPbCPpuczWiq6yKnahE(irWJtxNna)uqH)n0TegGJfqnXNVm26yDoC6Wr2KSwF6umqSDRqAYdqXPW16)8EGMwl8aifqnrgZcm4gU9HrgACTED2a8tbf(3q3sNIbITBfsxNna)uqH)n0nEyaL3n(qj4LRVdOZddOE75HbuVTWtF64yhbOTohoD4iBsw7H(OX3AjoC6WrSCzsZCHCp(BDoC6Wr2KS2d9rltiiuWhiJf38fAoGPX161zpqtRjtiiuWhiJf38fAoGBbBwNdNoCKnjR9qF04BTehoD4iwUmPzUqU)GmnUw)Ht)jl4HdDwIikSohoD4iBsw7H(OX3AjoC6WrSCzsZCHCVmPX16pC6pzbpCOZse0JcRJ15WPdhztYaE88TxZLPaQjYywej2twKofdOX163d00A7li8VcKzlyJUo7bAAnjd4XZ3wWM15WPdhztYaE889H(OtNIbITBfsd(fVyrEakoL9OPX161zdWpfu4FdDlDkgi2UviDD2a8tbf(3q34HbuE34dLGxU(oGopmG6TNhgq92cp9PJJDeGMUo7bAAnjd4XZ3wWM15WPdhztYaE889H(OX3AjoC6WrSCzsZCHCp(BDqOveZ8xAvcTANTcWraEM8yLgeyLEez3BDoC6Wr2KmGhpFFOpAqGm2hkruCFweXNpnUwFElEYgiqg7dLikUplI4ZVXZTV4pDD2a8tbf(3q3abYyFOerX9zreF(03d00AGazSpuIO4(SiIp)2hgzSohoD4iBsgWJNVp0hTKb845R15WPdhztYaE889H(ObU0hkHmyeiDmsAWV4flYdqXPShT15WPdhztYaE889H(O1CzkfqnHwa4LgxRFdWpfu4FdDd4sFOeYGrG0XiPVb4Nck8V1vtYaE8816C40HJSjzapE((qF0ax6dLqgmcKogjn4x8If5bO4u2J26C40HJSjzapE((qF07RdJegKcKogjn4x8If5bO4u2JMgxRxNna)uqH)n0T91HrcdsbshJKogcxFyKPbCPpuczWiq6yKnahE(irSVl6yiC9HrMMMltPaQj0caVnahE(irSVlRdcTsxNmTIiDzAfuZkIma8ALR9ywheAfQTIWy2kahE(4dLvyiC9HrgRGJvax6dLqgmcKogPvU0QfCOyGvz8nwLXSv44BgEz1paCPdhRGAwrKUmLcOMqla8ADoC6Wr2KmGhpFFOpAnxMsbutOfaEPX16rjk1HP9aFBJ)TpWhK(qjIHGrGHpzabeShOP12xq4FfiZwWgbeShOP1KmGhpFBao88rIa0OIokXq46dJmnGl9HsidgbshJSb4WZhjIOjGGdN(twWdh6Ser0Ocv04tYaqWw2J26C40HJSjzapE((qF0YnFgFOeyWnSaPJrsJR1F40FYcE4qNLi2Jc66Sb4Nck8VHUj38z8HsGb3WcKogP15WPdhztYaE889H(ObU0hkHmyeiDmsAWV4flYdqXPShnnUw)Ht)jl4HdDwIypkSohoD4iBsgWJNVp0hTCZNXhkbgCdlq6yK04A96Sb4Nck8VHUj38z8HsGb3WcKogP15WPdhztYaE889H(O3xhgjmifiDmsAWV4flYdqXPShnnUwVoBa(PGc)BOB7RdJegKcKogP1X6GqRIsw7cwPvhoD4y1YLP15WPdhztM9(8eIKf6hWJiJzrKypzr6umW6C40HJSjZh6JwMqqOGpqglU5l0CatJR1RZEGMwtMqqOGpqglU5l0Ca3c2Soi0kIz(lTkHwTZwb4iaptESsdcSspIS7TohoD4iBY8H(ObbYyFOerX9zreF(04A97bAAnqGm2hkruCFweXNF7dJm01zdWpfu4FdDdeiJ9Hsef3Nfr85BDoC6Wr2K5d9rZddO8UXhkbVC9DanUwVoBa(PGc)BOBPtXaX2TcToi0kc7cTvsoTAhobsRWW57PdNBzDqOv66KPv6TomsyqAfr1XiTY1EmRdcTc1wr0b8thgiTIOPRO0QiN0QbMwP36WiHbPvevhJ06GqRqTv6TomsyqAfr1Xi1XkxA19881TVyRdcTc1wreHb6gaB1atRU0QWtFR0vSBDoC6Wr2K5d9rVVomsyqkq6yK0GFXlwKhGItzpAACTED2a8tbf(3q32xhgjmifiDms64yVfE6JACSJypA6sof7Wjq2sNbDHw8Onm99anT2oePydaXTGnRdcTsxNmTIqNIbwr0VvOvU2JzDqOvO2kIoGF6WaPvenDfLwf5KwnW0kcDkgyfr)wHwheAfQTIOd4NomqAfrtxrPvroPvdmTI2OnRqjX6EcPThZka)dM)nPv7m(cKSvqnRYy2kABya1Rv4ygJKgRgM)sRsOv7SvaocWZKhR0GaR0Ji7EuzDqOvO2kIimWQi(Azf(2SI2ggq9A1oRbbSvdRFAfrtxrP1bHwHARiIWaRI4RLvuNpw1LvqGvHqaBLUIDRZHthoYMmFOp60PyGy7wH0GFXlwKhGItzpAACTED2a8tbf(3q3sNIbITBfsxNna)uqH)n0nEyaL3n(qj4LRVdOZddOEBPhYIekcp9rqpA64yVfE6JACSJyFx01zpqtRjzapE(2c2Soi0kDDY0kIeM6weALRz1lmWQi(Azf15JvOWkiWQqiGTsxXU15WPdhztMp0hTMltbutKXSisSNSiDkgqJR1JJ9w4PpQXXoI9OW6C40HJSjZh6JosSdw(qj(GJcoITGbhBDqOv66KPvDRl9HYkYGXkIQJrALR9ywheAfQTIicdS6aSvbsFOSIK2isAS6MVvVWaRIVNSvOWkiWQqiGTsxXUvDpXrPvpkQwbbwfcbSv8WaQxR09DRv0YkiWQqiGTsxXU1bHwHARiIWaRoaBvG0hkRizapE(sJvebRGaRcHa2kjJHZxAfGdpFScowLXSvyiC9HrgRGAwrYaE88LgRU5B1lmWQ47jBfkSccSkecyR0vSBv3tCuA1JIQvqGvHqaBfpmG61kDF3AfTSccSkecyR0vSBL15WPdhztMp0hnWL(qjKbJaPJrsd(fVyrEakoL9OPX16rjkXXoI9OGopmG6fX(hfvurab4yhXEAHk6OmVfpztYaE88TXZTV4pbeGHW1hgzAsgWJNVnahE(irSNiGkRdcTIOKPo8Rvy4890HZTSsdcSkkb(G0hkRikabJv6c(KbwNdNoCKnz(qF0AUmLcOMqla8sJR1N3INSjzapE(2452x8NUomTh4BB8V9b(G0hkrmemcm8jdOJHW1hgzAsgWJNVnahE(irSNw05HbuVT0dzrcfHN(i2L1bHwruYuh(1kmC(E6W5wwPbbwfLaFq6dLvefGGXkDbFYaRZHthoYMmFOpAnxMsbutOfaEPX16ZBXt2KmGhpFB8C7l(tNP9aFBJ)TpWhK(qjIHGrGHpzaDuIHW1hgzAsgWJNVnahE(irShnTiGameU(WittYaE88Tb4WZhjc6FeQOZddOEBPhYIekcp9rSlRdcTsxNmTIiDzkTcQzfrgaETY1EmRdcTc1wreHbwDa2QaPpuwrsBeP15WPdhztMp0hTMltPaQj0caV04A96K3INSjzapE(2452x836GqR01jtR6wsIQvU2JzDqOvO2kIimWQdWwfi9HYksAJiTs33Tw9cdS6aSvbsFOSIKb845Rv38TIwwbbwfcbSvsgdNV0kahE(yfCSkJzRWq46dJmwb1SIKb845R15WPdhztMp0hnWL(qjKbJaPJrsd(fVyrEakoL9OPX16Xq46dJmnjd4XZ3gGdpFKi2tlciaL6K3INSjzapE(2452x8hvwheALUozALERdJegKwruDmsRCThZ6GqRqTveDa)0HbsRiA6kkTkYjTAGPv6bjQwheAfQTIicdS6aSvdmT6sRcp9TsxXU15WPdhztMp0h9(6WiHbPaPJrsd(fVyrEakoL9OPX161zdWpfu4FdDBFDyKWGuG0XiPJJ9w4PpQXXoI9OToi0kIsM6WVwPbbwrymBfTfUXaiqALUUTd7jeyDoC6Wr2K5d9rJbhg5YhkruCFwSCQ4C8HIgxRNP9aFBJ)TmMfC4gdGaPaFBh2tiG(EGMwlJzbhUXaiqkW32H9ecAY8WirShD3rNhgq92spKfjueE6JikSohoD4iBY8H(OXGdJC5dLikUplwovCo(qrJR1Z0EGVTX)wgZcoCJbqGuGVTd7jeqFpqtRLXSGd3yaeif4B7WEcbnzEyKi2J(r0Xq46dJmnjd4XZ3gGdpFKiankON3INSjzapE(2452x8NopmG6TLEilsOi80hruyDoC6Wr2K5d9rVVomsyqkq6yK04A96Sb4Nck8VHUTVomsyqkq6yKwNdNoCKnz(qF04yxe5EYwheALULVwwnm)TkHwTZwb4iaptESsdcSspIS7Toi0kDfaa8Kwbcw8JzLUozALUIDR0laitRCThZ6GqRqTveryGvX3t2kuyfey1ILsR0vSBDqOvO2QULKOALlTkyZkFSIwwbbwfcbSvsgdNV0kDF3ALUvus0TYLwfSzLpwrlRGaRcHa2kjJHZxADqOvO2kIimWQi(Az1atRW3Mv8WaQxR2zniGTkJzRgw)0kIMUIsRZHthoYMmFOpACSl2daYKgxRNhgq92spKfjueE6JiA65T4jBsgWJNVnEU9f)Toi0kDDY0kcDkgyfr)wHw5ApM1bHwHARi6a(PddKwD7(YZxRICsRgyAfHofdSIOFRqRGaROTHbuE34dLv02Y13bwheAfQTIicdSkIVwwrD(y1LwT4tMw1Lv6k2PXkDF3A1lmWQi(Azf(2SIhgq9AvepJ9XkuyLKXW5lTcLeR7jK2EmR0fmy9TcFY0kcj6wXp5XQlTIwwPRy3QOiqMwLqR2a8tEsR4HbuVwHVTnFOOXkFSkJzi4fvwNdNoCKnz(qF0PtXaX2TcPb)IxSipafNYE004A96Sb4Nck8VHULofdeB3kKUoBa(PGc)BOB8WakVB8HsWlxFhqhL4yVfE6JACSJyFxeqapmG6TLEilsOi80hbOav01zpqtRjzapE(2c2SohoD4iBY8H(OXXUypaitACTECS3cp9rno2rShf05HbuVT0dzrcfHN(iIMUo5T4jBsgWJNVnEU9f)TohoD4iBY8H(OtNIbITBfsJR1Vb4Nck8VHULofdeB3kKUosEX40HJI8cYyiqrs6H6sLQuPa]] )
end