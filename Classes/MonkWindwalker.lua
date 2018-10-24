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
    

    --[[ spec:RegisterHook( "IsUsable", function( spell )
        if talent.hit_combo.enabled and buff.hit_combo.up and last_combo == spell then return false end
    end ) ]]


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
        cycle = true,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        potion = "potion_of_bursting_blood",
        
        package = "Windwalker",

        strict = false
    } )

    spec:RegisterPack( "Windwalker", 20181023.2131930, [[dSuQYaqicQEeusxsufQ2KOYNuPeXOiiNcQQxru1SuP6wqj2Lu(LkXWuP4yeyzKQ8mQknnOkCnOkTnrv6BuvOgNkLY5OQG1rvHmpsvDprzFqPoOOkyHevEOOk6IQucBKGI(OkLinsrviNuLsfRKQQxQsPQBsqj7ei(PkLOgQkL0sHQONcyQaPRkQcLVsqH9c5VKmyvDyLwSiEmOjRIlJAZe6Zez0uLttz1uv0RHIzlv3Mu2TIFJ0WbQJRsPslhXZPY0fUUiTDvsFNuz8IQ68qL1tqPMprz)sgjabkc4SbJarVBeCBcUrpFB6jW3Be4lciWbMraGxiMvIraZQXiaHHnhDBhdtqaGxCD6EqGIaC0ucKraEra25JUCrYcV0KgKQDXzAP9nm6ajRyCXzAWljDAYLeXflh(6fWeQO1z3LBLW45Ah3LBfpvcl6GrjmS5OB7yysZzAqeqsQ1JBNbLGaoBWiq07gb3MGB0Z3MEc89gb6HaCGzice9YRpGa8SZHhucc4WoicaR1lmS5OB7yys9cl6GP8J169IaSZhD5IKfEPjniv7IZ0s7By0bswX4IZ0Gxs60KljIlwo81lGjurRZUl3kHXZ1oUl3kEQew0bJsyyZr32XWKMZ0GLFSw)TmmOjmPE989E96DJGBRESuVa98rcWB93QWQ8x(XA95P3osSZhv(XA9yPE8K1Ox56baZlP(8ODo1deeddxpKoNWOJREH82505t9j4QFph6GFR8J16Xs94jRrVY1JN(fg1d3bY9(ggDQxKq1Qha06fsN171NWqQgx)wpyclIFR8J16Xs94jRrVY1lmbU91tyivtJNZggDQxiDwVxFcdPAC9B9GjSi(TYpwRhl1NNE7iX1hlrIdLjwFqRhId2zvSejoCTYpwRhl1JNSg9kxppmrcx9WfC9qpgIPErkPEHP5cx9uX6fMPeC1lKZ0Q)yIImHhixV5QFyPUjzjD(E9jPr9G7lU6pMOit4bY1BU6DM0yIgCNa)gcOBUWHafbapiqrGiabkcyHHrheGnxPyyv(P8Ga4zt68bjhkqGOhcueapBsNpi5qaZQXiGEQli0uNsI2p8Oa3t1wjgbSWWOdcON6ccn1PKO9dpkW9uTvIrbceFrGIawyy0bbK0P0JsmLGdbWZM05dsouGabpqGIawyy0bbKWehtWyJecGNnPZhKCOabcErGIa4zt68bjhcasSGj2IaGEwtBZVESup0ZQh7S6fuFU65Hjs4AHPXQGQ028Rh7S6VPHxeWcdJoiGLa3HvbLq4jqbcK8IafbSWWOdcOBsEHt5Z0JKgpbcGNnPZhKCOabIpgbkcyHHrheGOr4KoLEqa8SjD(GKdfiqUneOiGfggDqa7azxq2UcU9ocGNnPZhKCOabIpGafbWZM05dsoeaKybtSfbelrIJwyASkOQJX1JD9(acyHHrheqqtHEkQO6WB4HceicUbbkcGNnPZhKCiaiXcMylcasP9dv30CbLOP4LeEQDokrJWnO3sKyx9z1Rx9YKvVq1dP0(HQBAIMlCkQOsmLGRryT1gx96NvFERpx9qpRESZQ336ZvpKs7hQUPrmNnskx6OWyqmncRT24Qx)S6fup(1ltw9XsK4OfMgRcQ6yC96NvVa8Iawyy0bb4ckrtXlj8u7CuIgHrbcebcqGIa4zt68bjhcasSGj2IaGuA)q1nnI5Srs5shfgdIPryT1gx96NvVE1ltw9XsK4OfMgRcQ6yC96NvVa9qalmm6GaCmHhlWHcuGaatyivlzdeOiqeGafbWZM05dsouGarpeOiaE2KoFqYHcei(IafbWZM05dsouGabpqGIa4zt68bjhkqGGxeOiGfggDqaGPHrheapBsNpi5qbcK8IafbWZM05dsoeaKybtSfbiu9cV(y78enht4XcCnE2KoFQxMS6fE9X25jAIMluurv4XkDEwWQWKysJNnPZN6XhbSWWOdca6zQKuIlqbceFmcueWcdJoiaONP0TxzeapBsNpi5qbkqaoMWJf4qGIaracueapBsNpi5qalmm6GaiMZgjLlDuymigeaKybtSfbSWWUYkEynJD1RF9(wVmz1dMWxvsWttqZb2MXgjfKSdRWyqmiaioyNvXsK4WHarakqGOhcueapBsNpi5qaqIfmXweGq1NKkk2s6u6PN6Iwk46ZvpycFvjbpnbnI5Srs5shfgdIP(C1l86xHntSGBoDMyOi0054rtDCJNnPZN6XVEzYQpjvuS5ycpwGRryT1gx96xVG6LjREHQFHHDLv8WAg7Qh76fuFU6xyyxzfpSMXU61VE8wp(iGfggDqaIMlCkQOsmLGdfiq8fbkcGNnPZhKCiaiXcMylcq41dMWxvsWttqZb2MXgjfKSdRWyqm1NREHQFHHDLv8WAg7Qh7S69TEzYQxO6xyyxzfpSMXU6ZQxV6ZvpycFvjbpnbTK(cXqtdfgdIPE8RhFeWcdJoiahyBgBKuqYoScJbXGcei4bcueapBsNpi5qalmm6Gas6lednnuymigeaehSZQyjsC4qGiafOabCyXnThiqrGiabkcyHHrheGdmVeL3ohLligggbWZM05dsouGarpeOiaE2KoFqYHaGelyITiGy78enht4XcCnE2KoFQpx9qkTFO6MMJj8ybUgH1wBC1RF9(wFU65Hjs4AHPXQGQ028Rh76fuFU6tsffBKuNNnskFUhwPZMt7q1niGfggDqaKuNNnskFUhwPZMdkqG4lcueapBsNpi5qaqIfmXweGWRp2oprtIspkmlrBB8SjD(GaSjyY1TJa8HBqaGHHYJ3E4HaUPHxeWcdJoiGGMc9uurfMLOTOabcEGafbWZM05dsoeaKybtSfbeBNNOjrPhfMLOTnE2KoFqa2em562ra(WniaWWq5XBp8qacqalmm6GacAk0trfvywI2Icei4fbkcGNnPZhKCiaiXcMylcijvuS5ycpwGRLcUEzYQpjvuS5ckrtXlj8u7CuIgHBPGRxMS6fQEHxFSDEIMJj8ybUgpBsNp1NR(GydgoAGjuyBLSUf4AeEHr94xVmz1NKkk2s6u6PN6IgHxyuVmz1hlrIJwyASkOQJX1RFw959geWcdJoiaW0WOdkqGKxeOiaE2KoFqYHaGelyITiGKurXMJj8ybUwkyeWcdJoia427QfggDuDZfiGU5c1SAmcWXeESahkqG4JrGIa4zt68bjhcasSGj2IaeQEEyIeUwyASkOkTn)61VEb1ltw9cvFSDEIMJj8ybUgpBsNp1NREiL2puDtZXeESaxJWARnU61VE9Qh)6XV(C1d9SM2MF9yPEONvp2z17lcyHHrheGO5cfvufESsNNfSkmjMGcei3gcueapBsNpi5qalmm6GactIjkWBxdbajwWeBracvppmrcxlmnwfuL2MF96xVG6LjREHQp2oprZXeESaxJNnPZN6ZvpKs7hQUP5ycpwGRryT1gx96xVE1JF94xFU6HEwtBZVESup0ZQh7S61R(C1l86bt4Rkj4PjOfMetuG3UgcaId2zvSejoCiqeGcei(acueapBsNpi5qalmm6GaGBVRwyy0r1nxGa6MluZQXia4bfiqeCdcueapBsNpi5qaqIfmXweWcd7kR4H1m2vV(17lcyHHrheaC7D1cdJoQU5ceq3CHAwngb4cuGarGaeOiaE2KoFqYHaGelyITiGfg2vwXdRzSRESZQ3xeWcdJoia427QfggDuDZfiGU5c1SAmcyPmkqbcWfiqrGiabkcyHHrheGopJ0TrsDiReDuGthOhcGNnPZhKCOabIEiqra8SjD(GKdbSWWOdcGyoBKuU0rHXGyqaqIfmXwea0ZQh7S6XlcaId2zvSejoCiqeGcei(IafbSWWOdcq0CHtrfvIPeCiaE2KoFqYHcei4bcueapBsNpi5qalmm6GaiMZgjLlDuymigeaehSZQyjsC4qGiafiqWlcueapBsNpi5qaqIfmXweqsQOyJK68Srs5Z9WkD2CAhQUP(C1ZdtKW1ctJvbvPT5xp21lO(C1VWWUYkEynJD1JD9cqalmm6GaiPopBKu(CpSsNnhuGajViqra8SjD(GKdbajwWeBraqpRE9ZQxV6ZvVq1NKkk2iPopBKu(CpSsNnN2HQBQxMS65Hjs4Qh76XJ8wp(iGfggDqaIMluurv4XkDEwWQWKyckqG4JrGIa4zt68bjhcasSGj2IaGEw96NvVV1NREEyIeU61VE8EdcyHHrheapmrYe22iP4ULVrqbcKBdbkcGNnPZhKCiGfggDqaj9fIHMgkmgedcasSGj2IaeE9Gj8vLe80e0s6lednnuymiM6ZvVq1dP0(HQBAeZzJKYLokmgetJWARnU6XUEFRxMS6HEw9yNvVV1JF95QxO6HuA)q1nnrZfofvujMsW1iS2AJRESRhpQxMS6HEw9yNvpEuVmz1lu9qpR(S61R(C1dMWxvsWttqlmjMOaVDT6XVE8Rpx9jPIInNotmueA6C8OPoU5IfIPE9RxpeaehSZQyjsC4qGiafiq8beOiGfggDqaqptPBVYiaE2KoFqYHceicUbbkcGNnPZhKCiaiXcMylca6znTn)6Xs9qpRESZQxq95QFHHDLv8WAg7QpREb1ltw9qpRPT5xpwQh6z1JDw96Hawyy0bba9mvskXfOabIabiqra8SjD(GKdbSWWOdcimjMOaVDneaKybtSfbi86bt4Rkj4PjOfMetuG3Uw95Qh6znTn)6Xs9qpRESZQxV6ZvVq1NKkk2iPopBKu(CpSsNnN2HQBQxMS65Hjs4Qh76XBERhFeaehSZQyjsC4qGiafOabSugbkcebiqralmm6Ga05zKUnsQdzLOJcC6a9qa8SjD(GKdfiq0dbkcGNnPZhKCiaiXcMylcq41dMWxvsWttqlmjMOaVDT6Zvp0ZQx)S6fuFU65Hjs4Qx)6X7niGfggDqa8WejtyBJKI7w(gbfiq8fbkcyHHrheGO5cNIkQetj4qa8SjD(GKdfiqWdeOiaE2KoFqYHaGelyITiGKurXgj15zJKYN7Hv6S50ouDt95QNhMiHRfMgRcQsBZVESRxacyHHrheaj15zJKYN7Hv6S5Gcei4fbkcGNnPZhKCiGfggDqaeZzJKYLokmgedcasSGj2IaeQ(y78enDEgPBJK6qwj6OaNoqVgpBsNp1NREiL2puDttNNr62iPoKvIokWPd0RryT1gx96xpERh)6ZvpKs7hQUPjAUWPOIkXucUgH1wBC1JD9(IaG4GDwflrIdhcebOabsErGIa4zt68bjhcasSGj2IaeE9Gj8vLe80e0CGTzSrsbj7Wkmget95QxO6fQEHQh6z1JD9(wVmz1dP0(HQBAIMlCkQOsmLGRryT1gx9yxFERh)6ZvVq1d9S6XoRE8wVmz1dP0(HQBAIMlCkQOsmLGRryT1gx9yxVE1JF94xVmz1ZdtKW1ctJvbvPT5xV(z17B94Jawyy0bb4aBZyJKcs2HvymiguGaXhJafbWZM05dsoeaKybtSfba9S61pREFralmm6GaGEMkjL4cuGa52qGIa4zt68bjhcasSGj2IaGEwtBZVESup0ZQh7S69T(C1lu98WejC1JD94rERxMS6tsffBKuNNnskFUhwPZMt7q1n1JpcyHHrheGO5cfvufESsNNfSkmjMGcei(acueapBsNpi5qalmm6GactIjkWBxdbajwWeBraqpRPT5xpwQh6z1JDw96vFU6fQEEyIeU6XUE8M36LjR(KurXgj15zJKYN7Hv6S50ouDt94xFU6fQEHxFSDEIMNfkivlH24zt68PEzYQx41dMWxvsWttqlmjMOaVDT6XhbaXb7SkwIehoeicqbceb3GafbSWWOdca6zkD7vgbWZM05dsouGarGaeOiaE2KoFqYHawyy0bbK0xigAAOWyqmiaiXcMylcq41dMWxvsWttqlPVqm00qHXGyQpx9cvFsQOylHIrbMqHTuW1ltw9cvFSDEIMNfkivlH24zt68P(C1dMWxvsWttqlmjMOaVDT6Zvp0ZQx)6XJ6XVE8raqCWoRILiXHdbIauGcuGaUYeNrhei6DJGB7gFW3BAc8vpFmcq3sgBKCiGBhnWusWN6ZB9lmm6uF3CHRv(raGjurRZiaSwVWWMJUTJHj1lSOdMYpwR3lcWoF0Llsw4LM0GuTlotlTVHrhizfJlotdEjPttUKiUy5WxVaMqfTo7UCRegpx74UCR4PsyrhmkHHnhDBhdtAotdw(XA93YWGMWK61Z371R3ncUT6Xs9c0ZhjaV1FRcRYF5hR1NNE7iXoFu5hR1JL6XtwJELRhamVK6ZJ25upqqmmC9q6CcJoU6fYBNtNp1NGR(9COd(TYpwRhl1JNSg9kxpE6xyupChi37By0PErcvREaqRxiDwVxFcdPAC9B9GjSi(TYpwRhl1JNSg9kxVWe42xpHHunnEoBy0PEH0z9E9jmKQX1V1dMWI43k)yTESuFE6TJexFSejouMy9bTEioyNvXsK4W1k)yTESupEYA0RC98WejC1dxW1d9yiM6fPK6fMMlC1tfRxyMsWvVqotR(JjkYeEGC9MR(HL6MKL0571NKg1dUV4Q)yIImHhixV5Q3zsJjAWDc8BL)YpwR)wKpdtd(uFclsjC9qQwYg1NWs24A1NhGqgC4QFOdw8wIMyAV(fggDC1tNoUw5FHHrhxdmHHuTKnYe7Rdt5FHHrhxdmHHuTKnKp7IiLEk)lmm64AGjmKQLSH8zx2ujnEInm6u(XA9aZc25rJ6jRDQpjvuKp17InC1NWIucxpKQLSr9jSKnU635upycJfW0iSrQEZv)HoCR8VWWOJRbMWqQwYgYNDXnlyNhnuUydx5FHHrhxdmHHuTKnKp7cyAy0P8VWWOJRbMWqQwYgYNDb6zQKuIlUBIzcj8y78enht4XcCnE2KoFKjt4X25jAIMluurv4XkDEwWQWKysJNnPZh8l)lmm64AGjmKQLSH8zxGEMs3ELl)LFSw)TiFgMg8PE(ktWvFyAC9Hhx)cdkPEZv)EDT(M05w5FHHrhxMdmVeL3ohLliggU8VWWOJt(SlKuNNnskFUhwPZMZDtml2oprZXeESaxJNnPZNCqkTFO6MMJj8ybUgH1wBC67BoEyIeUwyASkOkTnFSfKljvuSrsDE2iP85EyLoBoTdv3u(XA9GstHE1tfR)2VeTTE6upKs7hQU5E9My93sP0t93(LOT1BU65zt68PE(2nD71h06fCZn5XRNkwV2MVPLQvVhV9WR8VWWOJt(Slbnf6POIkmlrBVBtWKRBpZhU5oyyO84ThEz30W7Dtmt4X25jAsu6rHzjABJNnPZN72em562Z8HBUdggkpE7Hx2nn8w(xyy0XjF2LGMc9uurfMLOT3TjyY1TN5d3ChmmuE82dVmb3nXSy78enjk9OWSeTTXZM05ZDBcMCD7z(Wn3bddLhV9Wltq5hR1FR0WOt9My9amHhlWvpLupqqjA3R)wSKW7E97CQxyAeU(LW1NcUEkPEC006xcxpjDgBKQ3XeESax97CQFRxBTPExSr9bXgmCupycf6UxpLupoAA9lHRpDomP(WJRNffzyupvS(KoLE6PU4E9us9XsK4O(W046dA9hJR3C1lr4nys9us98TB62RpO1N3Bk)lmm64Kp7cyAy05UjMLKkk2CmHhlW1sbltwsQOyZfuIMIxs4P25Oenc3sbltMqcp2oprZXeESaxJNnPZNCbXgmC0atOW2kzDlW1i8cd8LjljvuSL0P0tp1fncVWqMSyjsC0ctJvbvDmw)S8Et5FHHrhN8zxGBVRwyy0r1nxCFwnoZXeESa3DtmljvuS5ycpwGRLcU8VWWOJt(SlIMluurv4XkDEwWQWKyYDtmtiEyIeUwyASkOkTnF9fitMqX25jAoMWJf4A8SjD(KdsP9dv30CmHhlW1iS2AJtF9Wh)CqpRPT5JfONHDMVL)fggDCYNDjmjMOaVDT7qCWoRILiXHltWDtmtiEyIeUwyASkOkTnF9fitMqX25jAoMWJf4A8SjD(KdsP9dv30CmHhlW1iS2AJtF9Wh)CqpRPT5JfONHDME5eoycFvjbpnbTWKyIc821k)lmm64Kp7cC7D1cdJoQU5I7ZQXzWt5hR1NNBVxF4X1daA9lmm6uF3Cr9My9Hht46xcxVE1tj13zNREEynJDL)fggDCYNDbU9UAHHrhv3CX9z14mxC3eZwyyxzfpSMXo99T8J16ZZT3Rp846Zd0Br9lmm6uF3Cr9My9Hht46xcxVV1tj1RrjC98WAg7k)lmm64Kp7cC7D1cdJoQU5I7ZQXzlLVBIzlmSRSIhwZyh2z(w(l)yT(8amm64A5b6TOEZvVnbph(uViLuFQJRxNfE1NhXWWGQ8W5OYZoVx5635upmLq4j64QFy(4QpO1NW1tbhMMjS5t5FHHrhxBPCMopJ0TrsDiReDuGthOx5FHHrhxBPS8zx4HjsMW2gjf3T8nYDtmt4Gj8vLe80e0ctIjkWBxlh0Z0ptqoEyIeo9X7nL)fggDCTLYYNDr0CHtrfvIPeCL)fggDCTLYYNDHK68Srs5Z9WkD2CUBIzjPIInsQZZgjLp3dR0zZPDO6MC8WejCTW0yvqvAB(ylO8VWWOJRTuw(SleZzJKYLokmgeZDioyNvXsK4WLj4UjMjuSDEIMopJ0TrsDiReDuGthOxJNnPZNCqkTFO6MMopJ0TrsDiReDuGthOxJWARno9Xl(5GuA)q1nnrZfofvujMsW1iS2AJdBFl)lmm64AlLLp7IdSnJnskizhwHXGyUBIzchmHVQKGNMGMdSnJnskizhwHXGyYjKqcb9mS9vMmiL2puDtt0CHtrfvIPeCncRT24WoV4NtiONHDgELjdsP9dv30enx4uurLykbxJWARnoS1dF8LjJhMiHRfMgRcQsBZx)mFXV8VWWOJRTuw(SlqptLKsCXDtmd6z6N5B5FHHrhxBPS8zxenxOOIQWJv68SGvHjXK7Myg0ZAAB(yb6zyN5BoH4Hjs4WgpYRmzjPIInsQZZgjLp3dR0zZPDO6g8l)lmm64AlLLp7sysmrbE7A3H4GDwflrIdxMG7Myg0ZAAB(yb6zyNPxoH4Hjs4WgV5vMSKurXgj15zJKYN7Hv6S50ouDd(5es4X25jAEwOGuTeAJNnPZhzYeoycFvjbpnbTWKyIc821WV8VWWOJRTuw(SlqptPBVYLFSw)cdJoU2sz5ZUi2XzJKYXeW8ekmgeZDtmljvuSLqXOatOW2HQBUBtWesk4itq5FHHrhxBPS8zxs6lednnuymiM7qCWoRILiXHltWDtmt4Gj8vLe80e0s6lednnuymiMCcLKkk2sOyuGjuylfSmzcfBNNO5zHcs1sOnE2KoFYbMWxvsWttqlmjMOaVDTCqptF8aF8l)LFSwFEsP9dv34k)lmm64AWtMnxPyyv(P8OcpwPZZcwfMetk)lmm64AWJ8zxsDSYcw7(SACwp1feAQtjr7hEuG7PARex(xyy0X1Gh5ZUK0P0JsmLGR8VWWOJRbpYNDjHjoMGXgPYpwRppMJRppqG7W1dkLq4jQ3eRhhnT(LW1RzoNns1Vr9DEDr9cQpp9S635uVo6CljQhUGRNhMiHREDw4zt930WB9ogsNJR8VWWOJRbpYNDzjWDyvqjeEI7Myg0ZAAB(yb6zyNjihpmrcxlmnwfuL2Mp2z30WB5FHHrhxdEKp7s3K8cNYNPhjnEIY)cdJoUg8iF2frJWjDk9u(xyy0X1Gh5ZUSdKDbz7k427L)fggDCn4r(Slbnf6POIQdVH3DtmlwIehTW0yvqvhJX2hk)lmm64AWJ8zxCbLOP4LeEQDokrJW3nXmiL2puDtZfuIMIxs4P25Oenc3GElrIDz6jtMqqkTFO6MMO5cNIkQetj4AewBTXPFwEZb9mSZ8nhKs7hQUPrmNnskx6OWyqmncRT240pta(YKflrIJwyASkOQJX6NjaVL)fggDCn4r(SloMWJf4UBIzqkTFO6MgXC2iPCPJcJbX0iS2AJt)m9KjlwIehTW0yvqvhJ1ptGEL)YpwRhGj8ybU6btmkXcCL)fggDCnht4XcCzeZzJKYLokmgeZDioyNvXsK4WLj4UjMTWWUYkEynJD67RmzGj8vLe80e0CGTzSrsbj7Wkmget5FHHrhxZXeESaN8zxenx4uurLykb3DtmtOKurXwsNsp9ux0sbNdmHVQKGNMGgXC2iPCPJcJbXKt4RWMjwWnNotmueA6C8OPoUXZM05d(YKLKkk2CmHhlW1iS2AJtFbYKj0cd7kR4H1m2HTGClmSRSIhwZyN(4f)Y)cdJoUMJj8ybo5ZU4aBZyJKcs2HvymiM7MyMWbt4Rkj4PjO5aBZyJKcs2HvymiMCcTWWUYkEynJDyN5RmzcTWWUYkEynJDz6LdmHVQKGNMGwsFHyOPHcJbXGp(L)fggDCnht4XcCYNDjPVqm00qHXGyUdXb7SkwIehUmbL)YpwRhWgPoxFSejoQ)s95zN3RC9GjgLybUYpwRFHHrhxZfzWDGCxLKkkEFwnoJK68Srs5Z9WkD2CUBIzlmSRSIhwZyxMGCcj8y78enht4XcCnE2KoFKjdsP9dv30CmHhlW1iS2AJdBFXV8VWWOJR5c5ZUOZZiDBKuhYkrhf40b6v(xyy0X1CH8zxiMZgjLlDuymiM7qCWoRILiXHltWDtmd6zyNH3Y)cdJoUMlKp7IO5cNIkQetj4k)lmm64AUq(SleZzJKYLokmgeZDioyNvXsK4WLjO8VWWOJR5c5ZUqsDE2iP85EyLoBo3nXSKurXgj15zJKYN7Hv6S50ouDtoEyIeUwyASkOkTnFSfKBHHDLv8WAg7Wwq5FHHrhxZfYNDr0CHIkQcpwPZZcwfMetUBIzqpt)m9YjusQOyJK68Srs5Z9WkD2CAhQUrMmEyIeoSXJ8IF5FHHrhxZfYNDHhMizcBBKuC3Y3i3nXmONPFMV54Hjs40hV3u(xyy0X1CH8zxs6lednnuymiM7qCWoRILiXHltWDtmt4Gj8vLe80e0s6lednnuymiMCcbP0(HQBAeZzJKYLokmgetJWARnoS9vMmONHDMV4NtiiL2puDtt0CHtrfvIPeCncRT24WgpKjd6zyNHhYKje0ZY0lhycFvjbpnbTWKyIc821Wh)CjPIInNotmueA6C8OPoU5IfIrF9k)lmm64AUq(SlqptPBVYL)fggDCnxiF2fONPssjU4UjMb9SM2MpwGEg2zcYTWWUYkEynJDzcKjd6znTnFSa9mSZ0R8VWWOJR5c5ZUeMetuG3U2DioyNvXsK4WLj4UjMjCWe(QscEAcAHjXef4TRLd6znTnFSa9mSZ0lNqjPIInsQZZgjLp3dR0zZPDO6gzY4Hjs4WgV5f)YpwRFHHrhxZfYNDrSJZgjLJjG5juymiM7MygycFvjbpnbTK(cXqtdfgdIjh0ZW23CjPIInNotmueA6C8OPoU5IfIrF9UBtWesk4itacytdpkbbayA5jkqbcb]] )
end