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
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        potion = "potion_of_bursting_blood",
        
        package = "Windwalker",

        strict = false
    } )

    spec:RegisterPack( "Windwalker", 20180918.1245,
        [[dSu)WaqiIQ8iGsxcqPQnbqFsKs1OOu1POu5vevMfq6waf7sj)su1WauDmcSmG4ziPmnafxJGQTjQKVjQuACiPQZHKkRdqjZtKQ7jk7dj5GIkvlKG8qrk5IeuYgjQQYhfPuAKIukojrvvTskLxcOuMjrvf3uuPyNaYqjOWsjQkpvLMkaUkGsLVsqr7f0FjzWQ6WsTyr8yitwPUmQntOptKrtQonvRwKIxJuMTkUnPSBf)gQHJehNOQslhXZPy6cxNs2oq13jkJxuX5rQwpbLA(IK9lzOaiaW7Udgceiaxa1dCQta1VeacWiCGtn4nOtHHxknIwlXW70Am8km9zlRp0yc8sPPFW9gca8AWweedV6rqXaSYNxYdDRKfcRL34AwNoC8GiTyK34AO8jhCs(eXgmBg88uiyr)WM8cdclFTVn5fgYNk3GhAkHPpBz9HgtwgxdbVjw(jK)hyc8U7GHabcWfq9aN6eq9lbGamadWiC41qHrqGajxuh8UzdcEbB9ctF2Y6dnMuFUbp0kBGTE9iOyaw5Zl5HUvYcH1YBCnRthoEqKwmYBCnu(KdojFIydMndEEkeSOFytEaCMaci5baequx9wRhLWA07bXA8elJRHkBGT(ltjyTeMuVaQh06bb4cO(6bt9cabybc1xVWi3u2kBGT(0sVhj2aSkBGTEWuV8XAyW56Vu4MuFAtp76VbXPX1JWZoC8yQ3E9E2hExFc9679gp2TkBGTEWuV8XAyW56LpBcZ6r9G4ZPdhp1lsWA1FbOE7L5Nt9jmcRX131tHWI2TkBGTEWuV8XAyW56L)UaB1tyewtJNDhoEQ3Ez(5uFcJWAC9D9uiSODRYgyRhm1Nw69iX1hnrIdLlwFGRhrhDyv0ejomRYgyRhm1dGUBQp3fgYp1Brz3bxFV3e2yyt9HEh1FL5Ir9Yh2A26yldxVS2u)WerExVpbU(qNRxIGTM9cEpUjmqaGx0gcaeibqaG3gfoEGxFahtJv5yXd8YtNC4nuiyabceiaWlpDYH3qHG3P1y49yzcc2YOKWNnpkkhlTwIH3gfoEG3JLjiylJscF28OOCS0AjggqGOgea4TrHJh41YWkpynd8YtNC4nuiyabcyGaaVnkC8aVjhmEReTi0HxE6KdVHcbdiqchca82OWXd8MWedtO5Je8YtNC4nuiyabkxqaGxE6KdVHcbViIhmXB4fP7lToN6bt9iDVEQYQxq9awppmrI(kCnwfyLwNt9uLvpWxchEBu44bEBcQhwfycHNagqGYTqaG3gfoEG3JlPhgvAS2sA8eWlpDYH3qHGbeiQhca82OWXd8k6eo5GXB4LNo5WBOqWace1bbaEBu44bE7bXMG0hfQph4LNo5WBOqWacKaGdbaE5Pto8gke8IiEWeVH3OjsCScxJvbwTDUEQQN6G3gfoEG3aBH0vyr1M7qhgqGeiaca8YtNC4nui4fr8GjEdVim(SXYMLjWenf3Kqx1Zwj6eEH0BIeBQpREqQpvQ6TVEegF2yzZs0nHrHfvIwe6lcR1(yQp9S6Zv9awps3RNQS6Pw9awpcJpBSSzrCJpskJ1OO5iAlcR1(yQp9S6fuVD1Nkv9rtK4yfUgRcSA7C9PNvVaHdVnkC8aVMat0uCtcDvpBLOtyyabsaiqaGxE6KdVHcbViIhmXB4fHXNnw2SiUXhjLXAu0CeTfH1AFm1NEw9GuFQu1hnrIJv4ASkWQTZ1NEw9cabEBu44bEnmHhpOddyaVuimcRL0beaiqcGaaV80jhEdfcgqGabca8YtNC4nuiyabIAqaGxE6KdVHcbdiqadea4LNo5WBOqWacKWHaaVnkC8aVuWHJh4LNo5WBOqWacuUGaaV80jhEdfcErepyI3WR91lV6J(WtSmmHhpOV4Pto8U(uPQxE1h9HNyj6MqHfvHoRKP7bRcxIjlE6KdVR3o4TrHJh4fP7QelIjGbeOClea4TrHJh4fP7kzn4m8YtNC4nuiyad4TXmeaiqcGaaVnkC8aVY0DYXhj1M0s4rrXAq6WlpDYH3qHGbeiqGaaV80jhEdfcErepyI3WR8QNcHbxjH2lbRWLyIIsF0QhW6r6E9PNvVG6bSEEyIe96tVEHdC4TrHJh4LhMi5cBFKu8XZXjWace1GaaV80jhEdfcErepyI3WlpmrI(kCnwfyLwNt9uvpilHdVnkC8aVIUjmkSOs0IqhgqGagiaWlpDYH3qHGxeXdM4n8MyjkUiwgDFKuPP3SsMp71glBQhW65Hjs0xHRXQaR06CQNQ6faVnkC8aVelJUpsQ00BwjZNnmGajCiaWlpDYH3qHG3gfoEGxIB8rszSgfnhrdErepyI3WR91h9HNyjt3jhFKuBslHhffRbPV4Pto8UEaRhHXNnw2SKP7KJpsQnPLWJII1G0xewR9XuF61lH21Bx9awpcJpBSSzj6MWOWIkrlc9fH1AFm1tv9udEr0rhwfnrIddeibWacuUGaaV80jhEdfcErepyI3WR8QNcHbxjH2lbldfFgFKuispSIMJOvpG1BF9iDVEQQhK6tLQEegF2yzZs0nHrHfvIwe6lcR1(yQNQ6bM6TdEBu44bEnu8z8rsHi9WkAoIgmGaLBHaaV80jhEdfcErepyI3Wls3Rp9S6Pg82OWXd8I0DvIfXeWace1dbaE5Pto8gke8IiEWeVHxKUV06CQhm1J096PkREQvpG1BF98Wej61tv9atUQpvQ6tSefxelJUpsQ00BwjZN9AJLn1Bh82OWXd8k6MqHfvHoRKP7bRcxIjWace1bbaE5Pto8gke82OWXd8gUetuu6Jg8IiEWeVHx5vpfcdUscTxcwHlXefL(OvpG1J09LwNt9GPEKUxpvz1ds9awV91ZdtKOxpv1l8CvFQu1NyjkUiwgDFKuPP3SsMp71glBQ3o4frhDyv0ejomqGeadiqcaoea4TrHJh4fP7kzn4m8YtNC4nuiyabsGaiaWlpDYH3qHG3gfoEG3KtJOHTcfnhrdErepyI3WR8QNcHbxjH2lbRKtJOHTcfnhrdEr0rhwfnrIddeibWagWRHj84bDiaqGeabaE5Pto8gke82OWXd8sCJpskJ1OO5iAWlIo6WQOjsCyGajagqGabca8YtNC4nui4fr8GjEdV2xFILO4k5GX7JLjwwuQhW6PqyWvsO9sWI4gFKugRrrZr0QhW6Lx9TWMjEWlJmxmueS1S1XwgEXtNC4D92vFQu1NyjkUmmHhpOViSw7JP(0Rxq9PsvFJchCwXdR5SPEQQxa82OWXd8k6MWOWIkrlcDyabIAqaGxE6KdVHcbViIhmXB4vE1tHWGRKq7LGLHIpJpskePhwrZr0QhW6TV(gfo4SIhwZzt9uLvp1QpvQ6TV(gfo4SIhwZzt9z1ds9awpfcdUscTxcwjNgrdBfkAoIw92vVDWBJchpWRHIpJpskePhwrZr0GbeiGbca8YtNC4nui4TrHJh4n50iAyRqrZr0GxeD0HvrtK4WabsamGb8AciaqGeabaEBu44bELP7KJpsQnPLWJII1G0HxE6KdVHcbdiqGabaE5Pto8gke82OWXd8sCJpskJ1OO5iAWlIo6WQOjsCyGajagqGOgea4LNo5WBOqWlI4bt8gEtSefxelJUpsQ00BwjZN9AJLn1dy98Wej6RW1yvGvADo1tv9cQhW6Bu4GZkEynNn1tv9cG3gfoEGxILr3hjvA6nRK5ZggqGagiaWlpDYH3qHGxeXdM4n8YdtKOVcxJvbwP15upv1dYs4WBJchpWROBcJclQeTi0HbeiHdbaE5Pto8gke8IiEWeVHxKUxF6z1ds9awV91NyjkUiwgDFKuPP3SsMp71glBQpvQ65Hjs0RNQ6bMCvVDWBJchpWROBcfwuf6SsMUhSkCjMadiq5cca8YtNC4nui4fr8GjEdViDV(0ZQNA1dy98Wej61NE9ch4WBJchpWlpmrYf2(iP4JNJtGbeOClea4LNo5WBOqWBJchpWBYPr0WwHIMJObViIhmXB4vE1tHWGRKq7LGvYPr0WwHIMJOvpG1BF9im(SXYMfXn(iPmwJIMJOTiSw7JPEQQhK6tLQEKUxpvz1tT6TREaR3(6ry8zJLnlr3egfwujArOViSw7JPEQQhK6tLQEKUxpvz1dm1Nkv92xps3RpREqQhW6PqyWvsO9sWkCjMOO0hT6TRE7QhW6tSefxgzUyOiyRzRJTm8YenIw9PxpiWlIo6WQOjsCyGajagqGOEiaWBJchpWls3vYAWz4LNo5WBOqWace1bbaE5Pto8gke8IiEWeVHxKUV06CQhm1J096PkREb1dy9nkCWzfpSMZM6ZQxq9Psvps3xADo1dM6r6E9uLvpiWBJchpWls3vjwetadiqcaoea4LNo5WBOqWBJchpWB4smrrPpAWlI4bt8gELx9uim4kj0EjyfUetuu6Jw9awps3xADo1dM6r6E9uLvpi1dy92xFILO4Iyz09rsLMEZkz(SxBSSP(uPQNhMirVEQQx45QE7GxeD0HvrtK4WabsamGb8UzX26eqaGajaca82OWXd82wbw1r0iAWlpDYH3qHGbeiqGaaVnkC8aVgkCtu69SvMG40y4LNo5WBOqWace1GaaV80jhEdfcErepyI3WB0hEILHj84b9fpDYH31dy9im(SXYMLHj84b9fH1AFm1NE9uREaRNhMirFfUgRcSsRZPEQQxq9awFILO4Iyz09rsLMEZkz(SxBSSbEBu44bEjwgDFKuPP3SsMpByabcyGaaV80jhEdfcErepyI3WR8Qp6dpXscJ3kAnrRx80jhEdV(emb8(aVuhWHxkOqPZ9j0HxGVeo82OWXd8gylKUclQO1eTggqGeoea4LNo5WBOqWlI4bt8gEJ(WtSKW4TIwt06fpDYH3WRpbtaVpWl1bC4Lcku6CFcD4va82OWXd8gylKUclQO1eTggqGYfea4LNo5WBOqWlI4bt8gEtSefxgMWJh0xwuQpvQ6tSefxMat0uCtcDvpBLOt4LfL6tLQE7RxE1h9HNyzycpEqFXtNC4D9awFq8HghlkemA1s(Xd6lc3OOE7QpvQ6tSefxjhmEFSmXIWnkQpvQ6JMiXXkCnwfy1256tpR(CbC4TrHJh4LcoC8adiq5wiaWlpDYH3qHGxeXdM4n8MyjkUmmHhpOVSOaVnkC8aVO(CunkC8OoUjG3JBc10Am8AycpEqhgqGOEiaWlpDYH3qHGxeXdM4n8AF98Wej6RW1yvGvADo1NE9cQpvQ6TV(Op8eldt4Xd6lE6KdVRhW6ry8zJLnldt4Xd6lcR1(yQp96bPE7Q3U6bSEKUV06CQhm1J096PkREQbVnkC8aVIUjuyrvOZkz6EWQWLycmGarDqaGxE6KdVHcbVnkC8aVHlXefL(ObViIhmXB41(65Hjs0xHRXQaR06CQp96fuFQu1BF9rF4jwgMWJh0x80jhExpG1JW4ZglBwgMWJh0xewR9XuF61ds92vVD1dy9iDFP15upyQhP71tvw9GupG1lV6PqyWvsO9sWkCjMOO0hn4frhDyv0ejomqGeadiqcaoea4LNo5WBOqWBJchpWlQphvJchpQJBc494MqnTgdVOnmGajqaea4LNo5WBOqWlI4bt8gEBu4GZkEynNn1NE9udEBu44bEr95OAu44rDCtaVh3eQP1y41eWacKaqGaaV80jhEdfcErepyI3WBJchCwXdR5SPEQYQNAWBJchpWlQphvJchpQJBc494MqnTgdVnMHbmGb8cotmoEGabcWfq9aN6eKRfiudebWRSMm(izGxHzUlFaj)duAlWQ(6bqNR31OGjr9Iys9P9nl2wNiTxpHLFTCcVR3G146BRaR1bVRhP3JeBwLn5hF46faSQhy3ySOqbtcExFJchp1N2BRaR6iAeT0(QSv2K)1OGjbVRpx13OWXt9h3eMvzdEBRqhtG3RRLwWlfcw0pm8c26fM(SL1hAmP(CdEOv2aB96rqXaSYNxYdDRKfcRL34AwNoC8GiTyK34AO8jhCs(eXgmBg88uiyr)WM8a4mbeqYdaiGOU6TwpkH1O3dI14jwgxdv2aB9xMsWAjmPEbupO1dcWfq91dM6facWceQVEHrUPSv2aB9PLEpsSbyv2aB9GPE5J1WGZ1FPWnP(0ME21FdItJRhHND44XuV969Sp8U(e6137nESBv2aB9GPE5J1WGZ1lF2eM1J6bXNthoEQxKG1Q)cq92lZpN6tyewJRVRNcHfTBv2aB9GPE5J1WGZ1l)Db2QNWiSMgp7oC8uV9Y8ZP(egH14676Pqyr7wLnWwpyQpT07rIRpAIehkxS(axpIo6WQOjsCywLnWwpyQhaD3uFUlmKFQ3IYUdU(EVjSXWM6d9oQ)kZfJ6LpS1S1XwgUEzTP(HjI8UEFcC9HoxVebBn7vzRSb26fw5WiRG31NWIycxpcRL0r9jSKpMv95ocXuct9dEaJEt0eTo13OWXJPE8COVkBnkC8ywuimcRL0rM4Pn0kBnkC8ywuimcRL0HCz5fX4DzRrHJhZIcHryTKoKllFBjPXt0HJNYgyR)onfJooQN0(U(elrrExVj6WuFclIjC9iSwsh1NWs(yQVND9uimyOGJWhP6Dt9B8WRYwJchpMffcJWAjDixwEZ0um64qzIomLTgfoEmlkegH1s6qUS8uWHJNYwJchpMffcJWAjDixwEKURsSiMauxmZE5f9HNyzycpEqFXtNC4DQuYl6dpXs0nHclQcDwjt3dwfUetw80jhEBxzRrHJhZIcHryTKoKllps3vYAW5YwzdS1lSYHrwbVRNbNj0RpCnU(qNRVrbMuVBQVbV9tNC4vzRrHJhtwBfyvhrJOv2Au44XixwEdfUjk9E2ktqCACzRrHJhJCz5jwgDFKuPP3SsMpBqDXSOp8eldt4Xd6lE6KdVbeHXNnw2SmmHhpOViSw7JjDQbipmrI(kCnwfyLwNdvcamXsuCrSm6(iPstVzLmF2Rnw2u2aB9aGTq61JfRhyRjAD94PEegF2yzdO17I1N2IX76b2AIwxVBQNNo5W76z5xR(uFGRxaWboW(6XI1R154AwA1RZ9j0lBnkC8yKllFGTq6kSOIwt0Aq9jyc49jJ6aoOuqHsN7tONb8LWb1fZKx0hEILegVv0AIwV4Pto8guFcMaEFYOoGdkfuO05(e6zaFj8YwJchpg5YYhylKUclQO1eTguFcMaEFYOoGdkfuO05(e6zca1fZI(WtSKW4TIwt06fpDYH3G6tWeW7tg1bCqPGcLo3NqptqzdS1lmWHJN6DX6VmHhpOxpMu)nWenqRxy1Kqh067zxV8Nt46BcxVfL6XK6PJTQVjC9eRz8rQEdt4Xd613ZU(UET2N6nrh1heFOXr9uiyKb06XK6PJTQVjC9wZMj1h6C9SOiJI6XI1NCW49XYeGwpMuF0ejoQpCnU(ax)256Dt9seUdMupMupl)A1N6dC95c4LTgfoEmYLLNcoC8aQlMLyjkUmmHhpOVSOKkvILO4YeyIMIBsOR6zReDcVSOKkL9Yl6dpXYWeE8G(INo5WBadIp04yrHGrRwYpEqFr4gf2LkvILO4k5GX7JLjweUrrQurtK4yfUgRcSA7C6z5c4LTgfoEmYLLh1NJQrHJh1XnbOtRXzgMWJh0b1fZsSefxgMWJh0xwukBnkC8yKllVOBcfwuf6SsMUhSkCjMaQlMzppmrI(kCnwfyLwNt6csLY(Op8eldt4Xd6lE6KdVbeHXNnw2SmmHhpOViSw7JjDqSZoar6(sRZbmiDNQmQv2Au44Xixw(WLyIIsF0afrhDyv0ejomzca1fZSNhMirFfUgRcSsRZjDbPszF0hEILHj84b9fpDYH3aIW4ZglBwgMWJh0xewR9XKoi2zhGiDFP15agKUtvgiakpkegCLeAVeScxIjkk9rRS1OWXJrUS8O(CunkC8OoUjaDAnodTlBGT(0QpN6dDU(la13OWXt9h3e17I1h6mHRVjC9GupMu)HnM65H1C2u2Au44XixwEuFoQgfoEuh3eGoTgNzcqDXSgfo4SIhwZzt6uRSb26tR(CQp056ZDSWQ(gfoEQ)4MOExS(qNjC9nHRNA1Jj1RHjC98WAoBkBnkC8yKllpQphvJchpQJBcqNwJZAmdQlM1OWbNv8WAoBOkJALTYgyRp3rHJhZk3XcR6Dt9(e8S5D9Iys9wgUEzEOxFAdJchPY99wLwhUbNRVND9ilcHN4qV(H5TP(axFcxpMs4AUWM3LTgfoEmRgZzY0DYXhj1M0s4rrXAq6LTgfoEmRgZYLLNhMi5cBFKu8XZXjG6IzYJcHbxjH2lbRWLyIIsF0aeP7PNjaqEyIe90foWlBnkC8ywnMLllVOBcJclQeTi0b1fZ4Hjs0xHRXQaR06COcKLWlBnkC8ywnMLllpXYO7JKkn9MvY8zdQlMLyjkUiwgDFKuPP3SsMp71glBaKhMirFfUgRcSsRZHkbLTgfoEmRgZYLLN4gFKugRrrZr0afrhDyv0ejomzca1fZSp6dpXsMUto(iP2KwcpkkwdsFXtNC4nGim(SXYMLmDNC8rsTjTeEuuSgK(IWATpM0LqB7aeHXNnw2SeDtyuyrLOfH(IWATpgQOwzRrHJhZQXSCz5nu8z8rsHi9WkAoIgOUyM8OqyWvsO9sWYqXNXhjfI0dRO5iAaAps3PcKuPqy8zJLnlr3egfwujArOViSw7JHkGXUYwJchpMvJz5YYJ0DvIfXeG6IziDp9mQv2Au44XSAmlxwEr3ekSOk0zLmDpyv4smbuxmdP7lTohWG0DQYOgG2ZdtKOtfWKRuPsSefxelJUpsQ00BwjZN9AJLn2v2Au44XSAmlxw(WLyIIsF0afrhDyv0ejomzca1fZKhfcdUscTxcwHlXefL(Obis3xADoGbP7uLbcG2ZdtKOtLWZvQujwIIlILr3hjvA6nRK5ZETXYg7kBnkC8ywnMLllps3vYAW5YgyRVrHJhZQXSCz5fp09rszycfEcfnhrduxmlXsuCLGPPOqWO1glBa1NGjelkrMGYwJchpMvJz5YYNCAenSvOO5iAGIOJoSkAIehMmbG6IzYJcHbxjH2lbRKtJOHTcfnhrRSv2aB9PfgF2yzJPS1OWXJzH2z(aoMgRYXIhvOZkz6EWQWLyszRrHJhZcTLllVLHvEWAGoTgNDSmbbBzus4ZMhfLJLwlXLTgfoEml0wUS8wgw5bRzkBnkC8ywOTCz5toy8wjArOx2Au44XSqB5YYNWedtO5JuzdS1dSZW1N7eupC9aGjeEI6DX6PJTQVjC9AUX4Ju9Du)HBtuVG6tlDV(E21ldpP9OEutPEEyIe96L5HUp1d8LWR3Wi8SnLTgfoEml0wUS8nb1dRcmHWtaQlMH09LwNdyq6ovzcaKhMirFfUgRcSsRZHQmGVeEzRrHJhZcTLll)XL0dJknwBjnEIYwJchpMfAlxwErNWjhmEx2Au44XSqB5YY3dInbPpkuFoLTgfoEml0wUS8b2cPRWIQn3HoOUyw0ejowHRXQaR2otf1v2Au44XSqB5YYBcmrtXnj0v9SvIoHb1fZqy8zJLnltGjAkUjHUQNTs0j8cP3ej2KbsQu2JW4ZglBwIUjmkSOs0IqFryT2ht6z5cqKUtvg1aeHXNnw2SiUXhjLXAu0CeTfH1AFmPNjWUuPIMiXXkCnwfy1250Zei8YwJchpMfAlxwEdt4Xd6G6Izim(SXYMfXn(iPmwJIMJOTiSw7Jj9mqsLkAIehRW1yvGvBNtptaiLTYgyR)YeE8GE9uioM4b9YwJchpMLHj84b9mIB8rszSgfnhrdueD0HvrtK4WKjOS1OWXJzzycpEqxUS8IUjmkSOs0IqhuxmZ(elrXvYbJ3hltSSOaifcdUscTxcwe34JKYynkAoIgGYRf2mXdEzK5IHIGTMTo2YWlE6KdVTlvQelrXLHj84b9fH1AFmPlivQgfo4SIhwZzdvckBnkC8ywgMWJh0LllVHIpJpskePhwrZr0a1fZKhfcdUscTxcwgk(m(iPqKEyfnhrdq7Bu4GZkEynNnuLrTuPSVrHdoR4H1C2KbcGuim4kj0EjyLCAenSvOO5iA2zxzRrHJhZYWeE8GUCz5tonIg2ku0Cenqr0rhwfnrIdtMGYwzdS1F9r6W1hnrIJ6ZxFAD4gCUEkeht8GEzdS13OWXJzzImupi(OsSefbDAnoJyz09rsLMEZkz(Sb1fZAu4GZkEynNnzca0E5f9HNyzycpEqFXtNC4DQuim(SXYMLHj84b9fH1AFmurn7kBnkC8ywMqUS8Y0DYXhj1M0s4rrXAq6LTgfoEmltixwEIB8rszSgfnhrdueD0HvrtK4WKjOS1OWXJzzc5YYtSm6(iPstVzLmF2G6IzjwIIlILr3hjvA6nRK5ZETXYga5Hjs0xHRXQaR06COsaGnkCWzfpSMZgQeu2Au44XSmHCz5fDtyuyrLOfHoOUygpmrI(kCnwfyLwNdvGSeEzRrHJhZYeYLLx0nHclQcDwjt3dwfUeta1fZq6E6zGaO9jwIIlILr3hjvA6nRK5ZETXYMuP4Hjs0PcyYLDLTgfoEmltixwEEyIKlS9rsXhphNaQlMH090ZOgG8Wej6PlCGx2Au44XSmHCz5tonIg2ku0Cenqr0rhwfnrIdtMaqDXm5rHWGRKq7LGvYPr0WwHIMJObO9im(SXYMfXn(iPmwJIMJOTiSw7JHkqsLcP7uLrn7a0EegF2yzZs0nHrHfvIwe6lcR1(yOcKuPq6ovzatQu2J09mqaKcHbxjH2lbRWLyIIsF0SZoatSefxgzUyOiyRzRJTm8YenIw6Gu2Au44XSmHCz5r6Uswdox2Au44XSmHCz5r6UkXIycqDXmKUV06Cads3PktaGnkCWzfpSMZMmbPsH09LwNdyq6ovzGu2Au44XSmHCz5dxIjkk9rdueD0HvrtK4WKjauxmtEuim4kj0EjyfUetuu6JgGiDFP15agKUtvgiaAFILO4Iyz09rsLMEZkz(SxBSSjvkEyIeDQeEUSRSb26Bu44XSmHCz5fp09rszycfEcfnhrduxmJcHbxjH2lbRKtJOHTcfnhrdqKUtLaatSefxgzUyOiyRzRJTm8YenIw6GaQpbtiwuImbWagqia]] )
end