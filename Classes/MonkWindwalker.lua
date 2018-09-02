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

                if state.buff.rushing_jade_wind.last_tick and state.buff.rushing_jade_wind.last_tick > state.buff.rushing_jade_wind.applied then app = state.buff.rushing_jade_wind.last_tick end

                return app + ( floor( ( t - app ) / ( 0.75 * state.haste ) ) * ( 0.75 * state.haste ) )
            end,

            stop = function( x )
                return x < 3
            end,

            interval = function () return 0.75 * state.haste end,
            value = -3,
        },

        crackling_jade_lightning = {
            aura = 'crackling_jade_lightning',
            debuff = true,

            last = function ()
                local app = state.buff.crackling_jade_lightning.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x )
                return x < class.abilities.crackling_jade_lightning.spendPerSec
            end,

            interval = function () return state.haste end,
            value = function () return class.abilities.crackling_jade_lightning.spendPerSec end,
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

        -- Azerite Powers
        iron_fists = {
            id = 272806,
            duration = 10,
            max_stack = 1,
        },

        swift_roundhouse = {
            id = 278710,
            duration = 12,
            max_stack = 2,
        },

        sunrise_technique = {
            id = 273298,
            duration = 15,
            max_stack = 1
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


    -- If a Tiger Palm missed, pretend we never cast it.
    -- Use RegisterEvent since we're looking outside the state table.
    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event )
        local _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()
        
        if sourceGUID == state.GUID then
            local ability = class.abilities[ spellID ] and class.abilities[ spellID ].key
            if not ability then return end

            if ability == "tiger_palm" and subtype == "SPELL_MISSED" and not state.talent.hit_combo.enabled then
                if ns.castsAll[1] == "tiger_palm" then ns.castsAll[1] = "none" end
                if ns.castsAll[2] == "tiger_palm" then ns.castsAll[2] = "none" end
                if ns.castsOn[1] == "tiger_palm" then ns.castsOn[1] = "none" end
                actual_combo = "none"
                
                Hekili:ForceUpdate()
            
            elseif subtype == "SPELL_CAST_SUCCESS" and state.combos[ ability ] then
                prev_combo = actual_combo
                actual_combo = ability
            
            elseif subtype == "SPELL_DAMAGE" and spellID == 148187 then
                -- track the last tick.
                state.buff.rushing_jade_wind.last_tick = GetTime()

            end
        end
    end )


    spec:RegisterHook( "runHandler", function( key, noStart )
        if combos[ key ] then
            if last_combo == key then removeBuff( "hit_combo" )
            else
                if talent.hit_combo.enabled then addStack( "hit_combo", 10, 1 ) end
                
                if azerite.meridian_strikes.enabled and cooldown.touch_of_death.remains > 0 then
                    cooldown.touch_of_death.expires = cooldown.touch_of_death.expires - 0.25
                end
            end
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

        if buff.rushing_jade_wind.up then setCooldown( "rushing_jade_wind", 0 ) end

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

    -- spec:RegisterStateExpr( "gcd", function () return 1.0 end )


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

                if azerite.swift_roundhouse.enabled then
                    addStack( "swift_roundhouse", nil, 1 )
                end
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
            breakable = true,
            cooldown = 0,
            gcd = "spell",
            
            spend = 20,
            spendPerSec = 20,
            spendType = "energy",
            
            startsCombat = true,
            texture = 606542,

            handler = function ()
                applyDebuff( "target", "crackling_jade_lightning" )
                removeBuff( "the_emperors_capacitor" )   
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
                if azerite.iron_fists.enabled and active_enemies > 3 then applyBuff( "iron_fists" ) end
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
                removeBuff( "swift_roundhouse" )

                if azerite.sunrise_technique.enabled then applyDebuff( "target", "sunrise_technique" ) end
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
                    setCooldown( "rushing_jade_wind", action.rushing_jade_wind.cooldown - ( query_time - buff.rushing_jade_wind.applied ) )
                    removeBuff( "rushing_jade_wind" )
                end
            end,

            copy = 148187
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
            nobuff = "storm_earth_and_fire",

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

            buff = function () return prev_gcd[1].tiger_palm and buff.hit_combo.up and "hit_combo" or nil end,

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

    spec:RegisterPack( "Windwalker", 20180901.2241,
        [[d00M3aqicLwesk6riHUKscsBsvXNusjgLeYPKq9kkjZcj6wQQyxs6xQknmLuDmsLLrO6zibttvL6AiPABQQKVPKaJtjL6CekSoLu08OK6EkX(uv1brsHfsQQhsOOlsQIAJkPK(OsIyKkjeNujb1kLGxQKqntLes3KufzNaPHQKclLufEkGPcexvjbXxvsuNvjrQ9c1FPyWQCyflwIEmIjRuxg1Mj4Zez0KYPPA1KQ0RbQzRk3MsTBP(nKHJuDCLejlh0Zjz6cxNO2osY3jKXRK05rkRhjLMpLy)IgRddcgypbJbv811T2RlgRRRkU4)whfOogiOrNXa0hc4rIXa9yZyGv27TO5bMHya6dThA2yqWakKmKWyakMNwe0vR53VsEOjxwji7Vk3w(nHJAcCeIVk3M8T8Hk)wkm)SzQ(shIe8hR(UgqwpgFR(Ug6HrpHAWMv27TO5bMHvLBtWaLY(lwHBCjgypbJbv811T2RlgRRRkU4)wNUFJbu0zcguX)LyGb2SIGbOyERS3BrZdmdZtpHAWzbkMNwe0vR53VsEOjxwji7Vk3w(nHJAcCeIVk3M8T8Hk)wkm)SzQ(shIe8hR(UgqwpgFR(Ug6HrpHAWMv27TO5bMHvLBtYcumpaMEW2LmmpDuMN4RRBTZ7N8wbRjfwpV1qpLfYcumpXuBAjwTMzbkM3p5PhSnIkENhzuH3s5r0yc48eGi78aOZdmVvKP35beqhmNxrAtVF8opVdg2Z7rlVsA5fACEZEJ6IRzbkM3p5jMAtlX78IbkXHXfYtrRJz18cuEeAKhBIbkXHkVIIbkXHXfYRrrEkz60rWG35vslVzVrDX1SafZ7N80d2grfVZJBgkr7hYqppIgtaRYtabZBT6QqLhsiV1QmKwEENNYBPh)tmqjoQzbkM3p5jMAtlX78OMKPj8ZukliqnZlq5PhYknVLYRWS58wzV35fO82UAkFCEKPj87nHJ68qc5fACE6rHvoVszbH8ePXDEqoKHT3s5fO8aaPMxER0i58itNhK)H7P8X5fAUkVsA5r0ycyVLYtp3t5J35H68cnopbhQI84oG0YZ78cnopQPkOM5nKWrDEpxf1SqwGI5bkky1AMfOyE)KhiACEVjyvKNm99eCEqMoKvChQ8M8Sh9IG5rnwJv08GSiOhCEcqKDEHgNhGBl)MWrTychHiVGh78kQrrE2SylUIbEUkuyqWaKngemO6WGGbgs4Ogd4nviWSzvzUXaCpLpEJ1hhyqfhdcgG7P8XBS(yGESzmWtwfqKSYiHEBUn0FY2JeJbgs4Ogd8KvbejRmsO3MBd9NS9iX4adkfWGGbgs4Ogdu(qOTrqgsddW9u(4nwFCGb93yqWadjCuJbkzOIHG9wcdW9u(4nwFCGbL6yqWaCpLpEJ1hdqGEWqFWaenVApRM3p5r088(VKNU8(Kh3muIwnCB2eiJ9SAE)xYB9k1XadjCuJbgizA2eiiK7ahyq)fgemWqch1yGNlPfkJEL3s2ChyaUNYhVX6JdmORamiyGHeoQXacoKlFi0gdW9u(4nwFCGbDTXGGbgs4OgdmnHvbCEgY8EyaUNYhVX6JdmOIbgema3t5J3y9XaeOhm0hmqmqjoQHBZMaz2oN3)8edmWqch1yGajt0mibZMNqdhyq1Togema3t5J3y9XaeOhm0hmabHEBKOUQce02Wdm0mtVncoKReTbkXQ8wYt88SyjVIYJGqVnsuxfCvOmibJGmKwfY2J3Q8SEjVFL3N8iAEE)xYJc59jpcc92irDf6kVLmk52a2jGRq2E8wLN1l5PlVIZZIL8IbkXrnCB2eiZ258SEjpDuhdmKWrngqfiOTHhyOzMEBeCiJdmO60HbbdW9u(4nwFmab6bd9bdqqO3gjQRqx5TKrj3gWobCfY2J3Q8SEjpXZZIL8IbkXrnCB2eiZ258SEjpDIJbgs4OgdOyi3Eqdh4adqhYeKD5eyqWGQddcgG7P8XBS(4adQ4yqWaCpLpEJ1hhyqPagema3t5J3y9Xbg0FJbbdW9u(4nwFCGbL6yqWadjCuJbOJch1yaUNYhVX6JdmO)cdcgG7P8XBS(yac0dg6dgOO8eBEX84oQkgYTh0QCpLpENNfl5j28I5XDufCvyqcMqJnI08GnHlXWk3t5J35vmgyiHJAmarZnLYqvGdmORamiyGHeoQXaen3iAOIXaCpLpEJ1hh4adOyi3EqddcguDyqWaCpLpEJ1hdmKWrnga6kVLmk52a2jGXaeAKhBIbkXHcdQoCGbvCmiyaUNYhVX6JbiqpyOpyGIYRuwqOw(qO9twfvz659jp6qMkJezx1vHUYBjJsUnGDc48(KNyZBOwg6bxvICHWarY9wdjR4k3t5J35vCEwSKxPSGqvXqU9GwfY2J3Q8SopD5zXsEdjCQyd3STZQ8(NNomWqch1yabxfkdsWiidPHdmOuadcgG7P8XBS(yac0dg6dgqS5rhYuzKi7QUQIU3T3sgcCA2a2jGZ7tEfL3qcNk2WnB7SkV)l5rH8SyjVIYBiHtfB4MTDwL3sEIN3N8OdzQmsKDvxT8neWi5Wa2jGZR48kgdmKWrngqr372BjdbonBa7eW4ad6VXGGb4EkF8gRpgyiHJAmq5BiGrYHbStaJbi0ip2eduIdfguD4ahyGnlmYVadcguDyqWadjCuJbg5azMigcyma3t5J3y9XbguXXGGbgs4OgdOOZd0On92OcOdMXaCpLpEJ1hhyqPagema3t5J3y9XaeOhm0hmqmpUJQIHC7bTk3t5J359jpcc92irDvXqU9GwfY2J3Q8SopkK3N84MHs0QHBZMazSNvZ7FE6Y7tELYccvOSsZBjJENnBe59UUrIAmWqch1yaOSsZBjJENnBe59ghyq)ngema3t5J3y9XaeOhm0hmGyZlMh3rDLGqBZkEG2tL7P8XBmG3bdPAEyaXyDmaDsy045fAyG1RuhdmKWrngiqYendsWaEG2doWGsDmiyaUNYhVX6JbiqpyOpyGyECh1vccTnR4bApvUNYhVXaEhmKQ5HbeJ1Xa0jHrJNxOHb0Hbgs4OgdeizIMbjyapq7bhyq)fgema3t5J3y9XaeOhm0hmqPSGqvXqU9GwvMEEwSKxPSGqvfiOTHhyOzMEBeCixLPNNfl5vuEInVyEChvfd52dAvUNYhVZ7tEb0BWCuPdrK6i5ppOvH8qI8koplwYRuwqOw(qO9twfvipKiplwYlgOeh1WTztGmBNZZ6L8(16yGHeoQXa0rHJACGbDfGbbdW9u(4nwFmab6bd9bdukliuvmKBpOvLPJbgs4OgdqM3ZmKWrT55Qad8Cvy6XMXakgYTh0Wbg01gdcgG7P8XBS(yac0dg6dgOO84MHs0QHBZMazSNvZZ680LNfl5vuEX84oQkgYTh0QCpLpEN3N8ii0BJe1vfd52dAviBpERYZ68epVIZR48(KhrZR2ZQ59tEenpV)l5rbmWqch1yabxfgKGj0yJinpyt4smehyqfdmiyaUNYhVX6Jbgs4OgdeUedn0NNngGa9GH(GbkkpUzOeTA42Sjqg7z18SopD5zXsEfLxmpUJQIHC7bTk3t5J359jpcc92irDvXqU9GwfY2J3Q8SopXZR48koVp5r08Q9SAE)KhrZZ7)sEIN3N8eBE0HmvgjYUQRgUedn0NNngGqJ8ytmqjouyq1HdmO6whdcgG7P8XBS(yGHeoQXaK59mdjCuBEUkWapxfMESzmazJdmO60HbbdW9u(4nwFmab6bd9bduuEdjCQyd3STZQ8SoVFN3N8gQLHEWvLiximqKCV1qYkUcNgCEwNhfYR48SyjVHeovSHB22zvEwNh1XadjCuJbiZ7zgs4O28CvGbEUkm9yZyavGdmO6ehdcgG7P8XBS(yac0dg6dgOO8gs4uXgUzBNv59FjVFN3N8gQLHEWvLiximqKCV1qYkUcNgCEwNhfYR48SyjVHeovSHB22zvE)xYJ6yGHeoQXaK59mdjCuBEUkWapxfMESzmWGyCGdmGkWGGbvhgema3t5J34smab6bd9bdSrrfkR08wYO3zZgrEVRHta7TuEFYBiHtfB4MTDwL3sE6Y7tEfLNyZlMh3rvXqU9GwL7P8X78Syjpcc92irDvXqU9GwfY2J3Q8(NhfYRymWqch1yaOSsZBjJENnBe59ghyqfhdcgyiHJAmGinh(8wYSHJeQn0LBIggG7P8XBS(4adkfWGGb4EkF8gRpgyiHJAma0vElzuYTbStaJbiqpyOpyGIYJGqVnsuxfCvOmibJGmKwfY2J3Q8(NN45zXsEenpV)l5r98SyjVHAzOhCvjYfcdej3BnKSIRWPbN3)8epVIXaeAKhBIbkXHcdQoCGb93yqWaCpLpEJ1hdqGEWqFWaLYccvOSsZBjJENnBe59UUrI68(Kh3muIwnCB2eiJ9SAE)ZtxEFYBiHtfB4MTDwL3)80Hbgs4OgdaLvAElz07SzJiV34adk1XGGb4EkF8gRpgGa9GH(GbkkVHAzOhCvjYfcdej3BnKSIRWPbNN15rH8SyjVIYJGqVnsuxfP5WN3sMnCKqTHUCt0Qq2E8wLN15PB98(KxmpUJQinh(8wYSHJeQn0LBIwL7P8X78koplwYBiHtfB4MTDwL3)80LxXyGHeoQXacUkugKGrqgsdhyq)fgema3t5J3y9XaeOhm0hmarZZZ6L8epVp5vuELYccvOSsZBjJENnBe59UUrI68SyjpUzOeT8(N3V)vEfJbgs4Ogdi4QWGemHgBeP5bBcxIH4ad6kadcgG7P8XBS(yac0dg6dgGO55z9sEuiVp5XndLOLN15r91XadjCuJb4MHso16TKHF(QoehyqxBmiyaUNYhVX6Jbgs4Ogdu(gcyKCya7eWyac0dg6dgqS5rhYuzKi7QUA5BiGrYHbStaN3N8kkpcc92irDf6kVLmk52a2jGRq2E8wL3)8epplwYJO559FjpkKxX59jVIYJGqVnsuxfCvOmibJGmKwfY2J3Q8(NN45zXsEenpV)l5978SyjVHAzOhCvjYfcdej3BnKSIRCpLpENxX59jVszbHQsKlegisU3AizfxvXqaNN15jogGqJ8ytmqjouyq1HdmOIbgemWqch1yaIMBenuXyaUNYhVX6JdmO6whdcgG7P8XBS(yac0dg6dgGO5v7z18(jpIMN3)L80L3N8gs4uXgUzBNv5TKNU8SyjpIMxTNvZ7N8iAEE)xYtCmWqch1yaIMBkLHQahyq1PddcgG7P8XBS(yGHeoQXaHlXqd95zJbiqpyOpyaXMhDitLrISR6QHlXqd95zN3N8iAE1EwnVFYJO559FjpXZ7tEfLxPSGqfkR08wYO3zZgrEVRBKOoplwYJBgkrlV)5r9FLxXyacnYJnXaL4qHbvhoWGQtCmiyaUNYhVX6JbiqpyOpyacc92irDf6kVLmk52a2jGRq2E8wL3)8epVp5vkliuvICHWarY9wdjR4Qkgc48wYtCmWqch1yabxfkdsWiidPHdCGbgeJbbdQomiyGHeoQXaI0C4ZBjZgosO2qxUjAyaUNYhVX6JdmOIJbbdW9u(4nwFmab6bd9bdi28OdzQmsKDvxnCjgAOpp78(KhrZZZ6L80L3N84MHs0YZ68O(6yGHeoQXaCZqjNA9wYWpFvhIdmOuadcgG7P8XBS(yac0dg6dgGBgkrRgUnBcKXEwnV)5jEL6yGHeoQXacUkugKGrqgsdhyq)ngema3t5J3y9XaeOhm0hmqPSGqfkR08wYO3zZgrEVRBKOoVp5XndLOvd3MnbYypRM3)80Hbgs4OgdaLvAElz07SzJiV34adk1XGGb4EkF8gRpgyiHJAma0vElzuYTbStaJbiqpyOpyGIYlMh3rvKMdFElz2Wrc1g6YnrRY9u(4DEFYJGqVnsuxfP5WN3sMnCKqTHUCt0Qq2E8wLN15jr25vCEFYJGqVnsuxfCvOmibJGmKwfY2J3Q8(NhfWaeAKhBIbkXHcdQoCGb9xyqWaCpLpEJ1hdqGEWqFWaInp6qMkJezx1vv09U9wYqGtZgWobmgyiHJAmGIU3T3sgcCA2a2jGXbg0vagema3t5J3y9XaeOhm0hmarZZZ6L8OagyiHJAmarZnLYqvGdmORngema3t5J3y9XaeOhm0hmarZR2ZQ59tEenpV)l5PlVp5XndLOvd3MnbYypRM3)L8wVsDmWqch1yGbsMMnbcc5oWbguXadcgG7P8XBS(yac0dg6dgGO5v7z18(jpIMN3)L8OqEFYRO84MHs0Y7FE)(x5zXsELYccvOSsZBjJENnBe59UUrI68kgdmKWrngqWvHbjycn2isZd2eUedXbguDRJbbdW9u(4nwFmWqch1yGWLyOH(8SXaeOhm0hmGyZJoKPYir2vD1WLyOH(8SZ7tEenVApRM3p5r088(VKN459jVIYJBgkrlV)5r9FLNfl5vkliuHYknVLm6D2SrK376gjQZRymaHg5XMyGsCOWGQdhyq1PddcgyiHJAmarZnIgQyma3t5J3y9XbguDIJbbdW9u(4nwFmWqch1yGY3qaJKddyNagdqGEWqFWaInp6qMkJezx1vlFdbmsomGDcymaHg5XMyGsCOWGQdh4ahyaQyOYrnguXxx3AVUySUUQ4Il(AJbenW2BjfgyLPg6bORWGUswZ8Ydenop3Mocg5jGG5Tw2SWi)I1sEqELs2H8opfYMZBKdK9e8opI20sSQMfwr9MZt3AM3kKwjtNocg8oVHeoQZBTmYbYmrmeWRLAwilScBthbdEN3VYBiHJ68EUku1SagGoej4pgdqX8wzV3IMhygMNEc1GZcumpTiORwZVFL8qtUSsq2FvUT8Bch1e4ieFvUn5B5dv(Tuy(zZu9Loej4pw9DnGSEm(w9Dn0dJEc1GnRS3BrZdmdRk3MKfOyEam9GTlzyE6OmpXxx3AN3p5TcwtkSEERHEklKfOyEIP20sSAnZcumVFYtpyBev8opYOcVLYJOXeW5jar25bqNhyERitVZdiGoyoVI0ME)4DEEhmSN3JwEL0Yl048M9g1fxZcumVFYtm1MwI35fduIdJlKNIwhZQ5fO8i0ip2eduIdvEffduIdJlKxJI8uY0PJGbVZRKwEZEJ6IRzbkM3p5PhSnIkENh3muI2pKHEEenMawLNacM3A1vHkpKqERvziT88opL3sp(NyGsCuZcumVFYtm1MwI35rnjtt4NPuwqGAMxGYtpKvAElLxHzZ5TYEVZlq5TD1u(48itt43Bch15HeYl0480JcRCELYcc5jsJ78GCidBVLYlq5basnV8wPrY5rMopi)d3t5JZl0CvEL0YJOXeWElLNEUNYhVZd15fACEcouf5XDaPLN35fACEutvqnZBiHJ68EUkQzHSafZduuWQ1mlqX8(jpq048EtWQipz67j48GmDiR4ou5n5zp6fbZJASgRO5bzrqp48eGi78cnopa3w(nHJAXeocrEbp25vuJI8SzXwCnlKfOyE65vzICW78kzbeKZJGSlNiVswYBvnpQbHW0dvEnQ)rBG2cYV8gs4OwLhQF0QzHHeoQvv6qMGSlNyr4nkWzHHeoQvv6qMGSlNWQLVci0olmKWrTQshYeKD5ewT8DKLS5oMWrDwGI5b0dDLgkYdo(oVszbbENNkMqLxjlGGCEeKD5e5vYsERYB6DE0H8p0rr4TuEUkVnQ5AwyiHJAvLoKji7YjSA5RQh6knuyuXeQSWqch1QkDitq2Lty1Yx6OWrDwyiHJAvLoKji7YjSA5lrZnLYqvqPlSuKyJ5XDuvmKBpOv5EkF82IfXgZJ7Ok4QWGemHgBeP5bBcxIHvUNYhVlolmKWrTQshYeKD5ewT8LO5grdvCwilqX80ZRYe5G35XuXqA5fUnNxOX5nKabZZv5nun(BkFCnlmKWrTAzKdKzIyiGZcdjCuRSA5RIopqJ20BJkGoyolmKWrTYQLVqzLM3sg9oB2iY7nLUWsmpUJQIHC7bTk3t5J3Fii0BJe1vfd52dAviBpERSMcF4MHs0QHBZMazSNv)R7tPSGqfkR08wYO3zZgrEVRBKOolqX8abjt0YdjK3kEG2tEOopcc92irnL55c5TsqODER4bAp55Q84EkF8opELsEE5fO80T(6RqZdjKN9SQBlBNNgpVqllmKWrTYQLVbsMOzqcgWd0EO07GHunVfXyDkPtcJgpVqBz9k1P0fweBmpUJ6kbH2Mv8aTNk3t5J3u6DWqQM3IySoL0jHrJNxOTSEL6zHHeoQvwT8nqYendsWaEG2dLEhmKQ5TigRtjDsy045fAl6O0fwI5XDuxji02SIhO9u5EkF8MsVdgs18weJ1PKojmA88cTfDzbkM3AGch155c5bWqU9GwEiyEabcAtzE65bgAuM3078wRoKZBGCEY0ZdbZJgsoVbY5bL72BP8umKBpOL3078M8ShVZtftKxa9gmh5rhIikkZdbZJgsoVbY5j3BgMxOX5XccmjYdjKx5dH2pzvqzEiyEXaL4iVWT58cuEBNZZv5jb5jyyEiyE8kL88Ylq59R1ZcdjCuRSA5lDu4OMsxyPuwqOQyi3EqRkt3ILszbHQkqqBdpWqZm92i4qUkt3ILIeBmpUJQIHC7bTk3t5J3FcO3G5OshIi1rYFEqRc5HefBXsPSGqT8Hq7NSkQqEiHflXaL4OgUnBcKz7S1l)A9SWqch1kRw(sM3ZmKWrT55QGYES5ffd52dAu6clLYccvfd52dAvz6zHHeoQvwT8vWvHbjycn2isZd2eUedP0fwkIBgkrRgUnBcKXEw1ADwSuumpUJQIHC7bTk3t5J3Fii0BJe1vfd52dAviBpERSw8Il(drZR2ZQ)q08)luilmKWrTYQLVHlXqd95ztjHg5XMyGsCOw0rPlSue3muIwnCB2eiJ9SQ16SyPOyEChvfd52dAvUNYhV)qqO3gjQRkgYTh0Qq2E8wzT4fx8hIMxTNv)HO5)xe)JyPdzQmsKDvxnCjgAOpp7SWqch1kRw(sM3ZmKWrT55QGYES5fYolqX8eZ59Yl048aajVHeoQZ75QipxiVqJHCEdKZJc5HG59yLkpUzBNvzHHeoQvwT8LmVNziHJAZZvbL9yZlQGsxyPOHeovSHB22zL1)(ZqTm0dUQe5cHbIK7TgswXv40GTMcfBXYqcNk2WnB7SYAQNfOyEI58E5fACEudKEoVHeoQZ75QipxiVqJHCEdKZZgb58cTPZJc5XnB7SklmKWrTYQLVK59mdjCuBEUkOShBEzqmLUWsrdjCQyd3STZQ)l)(ZqTm0dUQe5cHbIK7TgswXv40GTMcfBXYqcNk2WnB7S6)c1ZczbkMh1GeoQvvQbspNNRYZ7G7nVZtabZtwX5jYdT8wrys4ed1yVnI5JhQ48MENhrgc5oE0YRzERYlq5vY5HOhUTtT8olmKWrTQoiErKMdFElz2Wrc1g6YnrllmKWrTQoi2QLVCZqjNA9wYWpFvhsPlSiw6qMkJezx1vdxIHg6ZZ(drZTEr3hUzOenRP(6zHHeoQv1bXwT8vWvHYGemcYqAu6clCZqjA1WTztGm2ZQ)fVs9SWqch1Q6GyRw(cLvAElz07SzJiV3u6clLYccvOSsZBjJENnBe59UUrI6pCZqjA1WTztGm2ZQ)1Lfgs4OwvheB1YxOR8wYOKBdyNaMscnYJnXaL4qTOJsxyPOyEChvrAo85TKzdhjuBOl3eTk3t5J3Fii0BJe1vrAo85TKzdhjuBOl3eTkKThVvwlr2f)HGqVnsuxfCvOmibJGmKwfY2J3Q)uilmKWrTQoi2QLVk6E3ElziWPzdyNaMsxyrS0HmvgjYUQRQO7D7TKHaNMnGDc4SWqch1Q6GyRw(s0CtPmufu6clen36fkKfgs4OwvheB1Y3bsMMnbcc5oO0fwiAE1Ew9hIM)Fr3hUzOeTA42Sjqg7z1)lRxPEwyiHJAvDqSvlFfCvyqcMqJnI08GnHlXqkDHfIMxTNv)HO5)xOWNI4MHs0()7FzXsPSGqfkR08wYO3zZgrEVRBKOU4SWqch1Q6GyRw(gUedn0NNnLeAKhBIbkXHArhLUWIyPdzQmsKDvxnCjgAOpp7penVApR(drZ)Vi(NI4MHs0(t9FzXsPSGqfkR08wYO3zZgrEVRBKOU4SWqch1Q6GyRw(s0CJOHkolqX8gs4OwvheB1YxHhnVLmkgsN7Wa2jGP0fwkLfeQLiWg6qePUrIAk9oyiuMESOllmKWrTQoi2QLVLVHagjhgWobmLeAKhBIbkXHArhLUWIyPdzQmsKDvxT8neWi5Wa2jGZczbkMNyIqVnsuRYcdjCuRQK9I3uHaZMvL52eASrKMhSjCjgMfgs4OwvjBRw(kRyJhSnL9yZlpzvarYkJe6T52q)jBpsCwyiHJAvLSTA5B5dH2gbziTSWqch1QkzB1Y3sgQyiyVLYcumVvikopQbKmnNhiiiK7ipxipAi58giNNTRuElL3e594rf5PlpXuZZB6DEIq9AjYJm0ZJBgkrlprEO5DERxPEEkMG6TklmKWrTQs2wT8DGKPztGGqUdkDHfIMxTNv)HO5)x09HBgkrRgUnBcKXEw9)Y6vQNfgs4OwvjBRw((CjTqz0R8wYM7ilmKWrTQs2wT8vWHC5dH2zHHeoQvvY2QLVttyvaNNHmVxwyiHJAvLSTA5BGKjAgKGzZtOrPlSeduIJA42SjqMTZ)fJSWqch1QkzB1YxvGG2gEGHMz6TrWHmLUWcbHEBKOUQce02Wdm0mtVncoKReTbkXQfXTyPicc92irDvWvHYGemcYqAviBpERSE5xFiA()fk8HGqVnsuxHUYBjJsUnGDc4kKThVvwVORylwIbkXrnCB2eiZ2zRx0r9SWqch1QkzB1Yxfd52dAu6clee6TrI6k0vElzuYTbStaxHS94TY6fXTyjgOeh1WTztGmBNTErN4zHSafZdGHC7bT8OdDe0dAzHHeoQvvfd52dAlqx5TKrj3gWobmLeAKhBIbkXHArxwyiHJAvvXqU9GMvlFfCvOmibJGmKgLUWsrLYcc1YhcTFYQOkt)dDitLrISR6Qqx5TKrj3gWob8hXould9GRkrUqyGi5ERHKvCL7P8X7ITyPuwqOQyi3EqRcz7XBL16SyziHtfB4MTDw9xxwyiHJAvvXqU9GMvlFv09U9wYqGtZgWobmLUWIyPdzQmsKDvxvr372BjdbonBa7eWFkAiHtfB4MTDw9FHcwSu0qcNk2WnB7SAr8p0HmvgjYUQRw(gcyKCya7eWfxCwyiHJAvvXqU9GMvlFlFdbmsomGDcykj0ip2eduId1IUSqwGI5b4T0JZlgOeh59npX8XdvCE0Hoc6bTSWqch1QQkSA5luwP5TKrVZMnI8EtPlSSrrfkR08wYO3zZgrEVRHta7T0NHeovSHB22z1IUpfj2yEChvfd52dAvUNYhVTyHGqVnsuxvmKBpOvHS94T6pfkolmKWrTQQcRw(ksZHpVLmB4iHAdD5MOLfgs4OwvvHvlFHUYBjJsUnGDcykj0ip2eduId1IokDHLIii0BJe1vbxfkdsWiidPvHS94T6V4wSq08)lu3ILHAzOhCvjYfcdej3BnKSIRWPb)x8IZcdjCuRQQWQLVqzLM3sg9oB2iY7nLUWsPSGqfkR08wYO3zZgrEVRBKO(d3muIwnCB2eiJ9S6FDFgs4uXgUzBNv)1Lfgs4OwvvHvlFfCvOmibJGmKgLUWsrd1Yqp4QsKlegisU3AizfxHtd2AkyXsree6TrI6Qinh(8wYSHJeQn0LBIwfY2J3kR1T(NyEChvrAo85TKzdhjuBOl3eTk3t5J3fBXYqcNk2WnB7S6VUIZcdjCuRQQWQLVcUkmibtOXgrAEWMWLyiLUWcrZTEr8pfvkliuHYknVLm6D2SrK376gjQTyHBgkr7)V)vXzHHeoQvvvy1YxUzOKtTElz4NVQdP0fwiAU1lu4d3muIM1uF9SWqch1QQkSA5B5BiGrYHbStatjHg5XMyGsCOw0rPlSiw6qMkJezx1vlFdbmsomGDc4pfrqO3gjQRqx5TKrj3gWobCfY2J3Q)IBXcrZ)VqHI)uebHEBKOUk4QqzqcgbziTkKThVv)f3IfIM)F53wSmuld9GRkrUqyGi5ERHKvCL7P8X7I)ukliuvICHWarY9wdjR4QkgcyRfplmKWrTQQcRw(s0CJOHkolmKWrTQQcRw(s0CtPmufu6clenVApR(drZ)VO7ZqcNk2WnB7SArNflenVApR(drZ)ViEwyiHJAvvfwT8nCjgAOppBkj0ip2eduId1IokDHfXshYuzKi7QUA4sm0qFE2FiAE1Ew9hIM)Fr8pfvkliuHYknVLm6D2SrK376gjQTyHBgkr7p1)vXzbkM3qch1QQkSA5RWJM3sgfdPZDya7eWu6cl0HmvgjYUQRw(gcyKCya7eWFiA(FDFkLfeQkrUqyGi5ERHKvCvfdbS1ItP3bdHY0JfDzHHeoQvvvy1YxbxfkdsWiidPrPlSqqO3gjQRqx5TKrj3gWobCfY2J3Q)I)PuwqOQe5cHbIK7TgswXvvmeWlIJbg5qdbXaaUTyIdCGX]] )
end