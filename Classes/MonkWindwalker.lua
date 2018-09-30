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

    spec:RegisterPack( "Windwalker", 20180930.1327,
        [[dOueYaqicKhHO4sQKkPnjQ6tQKkvJcr1PiGxrQYSuP6wiuTlj(LkXWuj5ye0YeP6zKsnnvs5AikTnrf(gbknorf15qOyDIuW8iv19eL9behuKISqsjpuurUOif1gfPq9rvsLyKIuiNuLufRuK8svsvDtvsf7einucuSucu9uatfHCvvsLYxrOK9c6VenyvDyLwmv1JHmzvCzuBMeFMqJMQCAkRwKsVgbZws3MK2TIFJ0WbQJRsQslhQNtLPlCDrSDvkFNuz8IkDEez9iuQ5tk2VudfcjccC2GHGM(vcZ5RigTVQiu70fSxlhqGGeygcaErewrgcmRkdbiw2C0TvcmgcaEjvP7bseeWrtWigc4fbyxA4Yfrl8s8liQ6fNPMu3WOdcVkXfNPIU4xP(x8vwIF4BxaJPkwLDxemywWx74UiyeC51HoeKelBo62kbgxCMkcc4Ny146zG(qGZgme00VsyoFfXO9vfHANUGvBIbc4aZiiOPNdIbc4zNdpqFiWHDiiaz6NyzZr3wjW4(Vo0HqNIm97fbyxA4Yfrl8s8liQ6fNPMu3WOdcVkXfNPIU4xP(x8vwIF4BxaJPkwLDxemywWx74UiyeC51HoeKelBo62kbgxCMkQtrM(byWbR6Z4(1(Q79N(vcZ5(jE)ctdAFvNQtrM(ZjVDezxAOtrM(jE)coRsVX9daMxC)Pr7C6hiWgbUFeDoHrhx)K7TZPYN(9j1)Eo0rGsNIm9t8(fCwLEJ7xWtrS6hTdIR1nm60VcMQ2par9tUoRw73NruvU)TFWywrGsNIm9t8(fCwLEJ7png463pMruvvEoBy0PFY1z1A)(mIQY9V9dgZkcu6uKPFI3Fo5TJi3FSyroKMs)bTFejuLLXIf5WvGavZfoirqa0bseeuHqIGalkm6abS5gLalZnHhiapRFLpqTGbe00Hebb4z9R8bQfeywvgcutCbMM4KI06Hhj4AI6kYqGffgDGa1exGPjoPiTE4rcUMOUImmGGQnKiiWIcJoqa)kLEKkjysqaEw)kFGAbdiOxdseeyrHrhiGpJDmMGnIqaEw)kFGAbdiOKfseeGN1VYhOwqae2cgBlea5zf1n3(jE)ipRFqY6xy)57NhglsQeMkldQuDZTFqY6)QczHalkm6abwmAhwgumMNagqqZbKiiWIcJoqGQj6fozAtoIQ8eqaEw)kFGAbdiOcwirqGffgDGakgM9Ru6bcWZ6x5dulyabnNHebbwuy0bcSdIDbERs0wRqaEw)kFGAbdiOedKiiapRFLpqTGaiSfm2wiqSyrokHPYYGkpg3pi9tmqGffgDGabnb5jPkYdVHhmGGk8kirqaEw)kFGAbbqylySTqaeLwpuDtXfuSQKxC4j35ivmmxqElwKD9N1F69Rrt)K3pIsRhQUPOyUWjPksLemPcMvxBC9RFw)5O)89J8S(bjRFT7pF)ikTEO6Mc2C2ikDjJKGHiuWS6AJRF9Z6xy)c0Vgn9hlwKJsyQSmOYJX9RFw)cjleyrHrhiGlOyvjV4WtUZrQyyggqqfkeseeGN1VYhOwqae2cgBlearP1dv3uWMZgrPlzKemeHcMvxBC9RFw)P3Vgn9hlwKJsyQSmOYJX9RFw)cthcSOWOdeWXyESGemGbeamMruv)nGebbviKiiapRFLpqTGbe00Hebb4z9R8bQfmGGQnKiiapRFLpqTGbe0RbjccWZ6x5dulyabLSqIGalkm6abatdJoqaEw)kFGAbdiO5aseeGN1VYhOwqae2cgBleG8(fu)Xw5jkogZJfKk8S(v(0Vgn9lO(JTYtuumxiPkYWJL68SGLHjY4cpRFLp9laeyrHrhiaYZK(jyxadiOcwirqGffgDGaiptQBVXqaEw)kFGAbdyabwkdjccQqirqGffgDGa68mC1gr5bVI0rcozqEqaEw)kFGAbdiOPdjccWZ6x5duliacBbJTfciO(bJ5Bsr0PiSeMiJLG3QA)57h5z9RFw)c7pF)8Wyrs9RF)K9kiWIcJoqaEySOrSTruYvlxdddiOAdjccWZ6x5duliacBbJTfcWdJfjvctLLbvQU52pi9RneyrHrhiGI5cNKQivsWKGbe0RbjccWZ6x5duliacBbJTfc4NOOuWjopBeLPDpSuNnNYHQB6pF)8WyrsLWuzzqLQBU9ds)cHalkm6abWjopBeLPDpSuNnhyabLSqIGa8S(v(a1ccSOWOdeaBoBeLUKrsWqeGaiSfm2wia59hBLNOOZZWvBeLh8kshj4Kb5v4z9R8P)89JO06HQBk68mC1gr5bVI0rcozqEfmRU246x)(jB)c0F((ruA9q1nffZfojvrQKGjvWS6AJRFq6xBiaIeQYYyXIC4GGkegqqZbKiiapRFLpqTGaiSfm2wiGG6hmMVjfrNIWIdSnJnIseEhwsWqe6pF)K3p59tE)ipRFq6x7(1OPFeLwpuDtrXCHtsvKkjysfmRU246hK(Zr)c0F((jVFKN1piz9t2(1OPFeLwpuDtrXCHtsvKkjysfmRU246hK(tVFb6xG(1OPFEySiPsyQSmOs1n3(1pRFT7xaiWIcJoqahyBgBeLi8oSKGHiadiOcwirqaEw)kFGAbbqylySTqaKN1V(z9RneyrHrhiaYZK(jyxadiO5mKiiapRFLpqTGaiSfm2wiaYZkQBU9t8(rEw)GK1V29NVFY7NhglsQFq6)A5OFnA63prrPGtCE2ikt7EyPoBoLdv30VaqGffgDGakMlKufz4XsDEwWYWezmmGGsmqIGa8S(v(a1ccSOWOdeimrglbVvviacBbJTfcG8SI6MB)eVFKN1piz9NE)57N8(5HXIK6hK(jBo6xJM(9tuuk4eNNnIY0UhwQZMt5q1n9lq)57N8(fu)Xw5jkEwiruvFAHN1VYN(1OPFb1pymFtkIofHLWezSe8wv7xaiaIeQYYyXIC4GGkegqqfEfKiiWIcJoqaKNj1T3yiapRFLpqTGbeuHcHebb4z9R8bQfeyrHrhiGFDreOjHKGHiabqylySTqab1pymFtkIofHf)6IiqtcjbdrO)89tE)(jkkfFkbjymfvsa3Vgn9tE)Xw5jkEwiruvFAHN1VYN(Z3pymFtkIofHLWezSe8wv7pF)ipRF97)A9lq)cabqKqvwglwKdheuHWagqGdRSj1aseeuHqIGalkm6abCG5fl925iDb2iWqaEw)kFGAbdiOPdjccWZ6x5duliacBbJTfceBLNO4ympwqQWZ6x5t)57hrP1dv3uCmMhlivWS6AJRF97x7(Z3ppmwKujmvwguP6MB)G0VW(Z3VFIIsbN48SruM29WsD2CkhQUbcSOWOdeaN48SruM29WsD2CGbeuTHebb4z9R8bQfeaHTGX2cbeu)Xw5jkIu6rsyXQBHN1VYhiGnbJVTviaXCfeamkKE8wdpiWvfYcbwuy0bce0eKNKQijSy1fgqqVgKiiapRFLpqTGaiSfm2wiqSvEIIiLEKewS6w4z9R8bcytW4BBfcqmxbbaJcPhV1WdciecSOWOdeiOjipjvrsyXQlmGGswirqaEw)kFGAbbqylySTqa)efLIJX8ybPsc4(1OPF)efLIlOyvjV4WtUZrQyyUKaUFnA6N8(fu)Xw5jkogZJfKk8S(v(0F((dSne4OagtrLv0QwqQG5ff9lq)A00VFIIsXVsPNAIlkyErr)A00FSyrokHPYYGkpg3V(z9NJRGalkm6abatdJoWacAoGebb4z9R8bQfeaHTGX2cb8tuukogZJfKkjGHalkm6abqBTkxuy0rwnxabQMlKZQYqahJ5XcsWacQGfseeGN1VYhOwqae2cgBleG8(5HXIKkHPYYGkv3C7x)(f2Vgn9tE)Xw5jkogZJfKk8S(v(0F((ruA9q1nfhJ5XcsfmRU246x)(tVFb6xG(Z3pYZkQBU9t8(rEw)GK1V2qGffgDGakMlKufz4XsDEwWYWezmmGGMZqIGa8S(v(a1ccSOWOdeimrglbVvviacBbJTfcqE)8WyrsLWuzzqLQBU9RF)c7xJM(jV)yR8efhJ5XcsfEw)kF6pF)ikTEO6MIJX8ybPcMvxBC9RF)P3Va9lq)57h5zf1n3(jE)ipRFqY6p9(Z3VG6hmMVjfrNIWsyImwcERQqaejuLLXIf5WbbvimGGsmqIGa8S(v(a1ccSOWOdeaT1QCrHrhz1CbeOAUqoRkdbqhyabv4vqIGa8S(v(a1ccGWwWyBHalkSBSKhw1yx)63V2qGffgDGaOTwLlkm6iRMlGavZfYzvziGlGbeuHcHebb4z9R8bQfeaHTGX2cbwuy3yjpSQXU(bjRFTHalkm6abqBTkxuy0rwnxabQMlKZQYqGLYWagqaxajccQqirqGffgDGa68mC1gr5bVI0rcozqEqaEw)kFGAbdiOPdjccWZ6x5duliWIcJoqaS5Sru6sgjbdracGWwWyBHaipRFqY6NSqaejuLLXIf5WbbvimGGQnKiiapRFLpqTGaiSfm2wiapmwKujmvwguP6MB)G0V2qGffgDGakMlCsQIujbtcgqqVgKiiapRFLpqTGalkm6abWMZgrPlzKemebiaIeQYYyXIC4GGkegqqjlKiiapRFLpqTGaiSfm2wiGFIIsbN48SruM29WsD2CkhQUP)89ZdJfjvctLLbvQU52pi9lS)89VOWUXsEyvJD9ds)cHalkm6abWjopBeLPDpSuNnhyabnhqIGa8S(v(a1ccGWwWyBHaipRF9Z6p9(Z3p597NOOuWjopBeLPDpSuNnNYHQB6xJM(5HXIK6hK(Vwo6xaiWIcJoqafZfsQIm8yPoplyzyImggqqfSqIGa8S(v(a1ccGWwWyBHaipRF9Z6x7(Z3ppmwKu)63pzVccSOWOdeGhglAeBBeLC1Y1WWacAodjccWZ6x5duliWIcJoqa)6IiqtcjbdracGWwWyBHacQFWy(MueDkcl(1frGMescgIq)57N8(ruA9q1nfS5Sru6sgjbdrOGz11gx)G0V29Rrt)ipRFqY6x7(fO)89tE)ikTEO6MII5cNKQivsWKkywDTX1pi9FT(1OPFKN1piz9FT(1OPFY7h5z9N1F69NVFWy(MueDkclHjYyj4TQ2Va9lq)573prrP40zkHettMJhnXXfxSic9RF)PdbqKqvwglwKdheuHWackXajccSOWOdea5zsD7ngcWZ6x5dulyabv4vqIGa8S(v(a1ccGWwWyBHaipROU52pX7h5z9dsw)c7pF)lkSBSKhw1yx)z9lSFnA6h5zf1n3(jE)ipRFqY6pDiWIcJoqaKNj9tWUagqqfkeseeGN1VYhOwqGffgDGaHjYyj4TQcbqylySTqab1pymFtkIofHLWezSe8wv7pF)ipROU52pX7h5z9dsw)P3F((jVF)efLcoX5zJOmT7HL6S5uouDt)A00ppmwKu)G0pzZr)cabqKqvwglwKdheuHWagqahJ5XcsqIGGkeseeGN1VYhOwqGffgDGayZzJO0LmscgIaeaHTGX2cbwuy3yjpSQXU(1VFT7xJM(bJ5Bsr0PiS4aBZyJOeH3HLemebiaIeQYYyXIC4GGkegqqthseeGN1VYhOwqae2cgBleG8(9tuuk(vk9utCrjbC)57hmMVjfrNIWc2C2ikDjJKGHi0F((fu)lXMXwWfNotjKyAYC8OjoUWZ6x5t)c0Vgn97NOOuCmMhlivWS6AJRF97xy)A00p59VOWUXsEyvJD9ds)c7pF)lkSBSKhw1yx)63pz7xaiWIcJoqafZfojvrQKGjbdiOAdjccWZ6x5duliacBbJTfciO(bJ5Bsr0PiS4aBZyJOeH3HLemeH(Z3p59VOWUXsEyvJD9dsw)A3Vgn9tE)lkSBSKhw1yx)z9NE)57hmMVjfrNIWIFDreOjHKGHi0Va9laeyrHrhiGdSnJnIseEhwsWqeGbe0RbjccWZ6x5duliWIcJoqa)6IiqtcjbdracGiHQSmwSihoiOcHbmGbe4gJDgDGGM(vcZ5RigH5Cry6xJSqaDlESr0bbUEubtXbF6ph9VOWOt)vZfUsNccagtvSkdbit)elBo62kbg3)1Hoe6uKPFVia7sdxUiAHxIFbrvV4m1K6ggDq4vjU4mv0f)k1)IVYs8dF7cymvXQS7IGbZc(Ah3fbJGlVo0HGKyzZr3wjW4IZurDkY0padoyvFg3V2xDV)0Vsyo3pX7xyAq7R6uDkY0Fo5TJi7sdDkY0pX7xWzv6nUFaW8I7pnANt)ab2iW9JOZjm646NCVDov(0VpP(3ZHocu6uKPFI3VGZQ0BC)cEkIv)ODqCTUHrN(vWu1(biQFY1z1A)(mIQY9V9dgZkcu6uKPFI3VGZQ0BC)PXax)(XmIQQYZzdJo9tUoRw73NruvU)TFWywrGsNIm9t8(ZjVDe5(JflYH0u6pO9JiHQSmwSihUsNQtrM(tZ5YOKGp97Zkum3pIQ6Vr)(SOnUs)PjeIbhU(h6qCVfRQKu7FrHrhx)0PsQ0Pwuy0XvaJzev1FJmL66i0Pwuy0XvaJzev1Fd9YUOqPNo1IcJoUcymJOQ(BOx2LnruLNydJoDkY0pWSGDE0OF8AN(9tuu4t)Uydx)(ScfZ9JOQ(B0VplAJR)Do9dgZehmncBe73C9FOdx6ulkm64kGXmIQ6VHEzxCZc25rdPl2W1Pwuy0XvaJzev1Fd9YUaMggD6ulkm64kGXmIQ6VHEzxqEM0pb7I7Msg5ck2kprXXyESGuHN1VYhnAeuSvEIII5cjvrgESuNNfSmmrgx4z9R8rGo1IcJoUcymJOQ(BOx2fKNj1T34ovNIm9NMZLrjbF6NVXys9hMk3F4X9VOGI73C9V3wRU(vU0Pwuy0XL5aZlw6TZr6cSrG7ulkm640l7coX5zJOmT7HL6S5C3uYITYtuCmMhliv4z9R8jpIsRhQUP4ympwqQGz11gN(ANNhglsQeMkldQuDZfeH59tuuk4eNNnIY0UhwQZMt5q1nDkY0pr0eKx)uL(V(lwD7No9JO06HQBU3VP0)1fk90)1FXQB)MRFEw)kF6NVEt2A)bTFHxD111(Pk9RU5AQjQ97XBn86ulkm640l7sqtqEsQIKWIv372em(2wZiMRUdgfspERHx2vfYE3uYeuSvEIIiLEKewS6w4z9R85UnbJVT1mI5Q7GrH0J3A4LDvHSDQffgDC6LDjOjipjvrsyXQ7DBcgFBRzeZv3bJcPhV1Wlt4Dtjl2kprrKspsclwDl8S(v(C3MGX32AgXC1DWOq6XBn8Ye2Pit)cgAy0PFtPFagZJfK6NI7hiOy179NMxC4DV)Do9NgByU)fZ9NaUFkUFs0K(xm3pozgBe73XyESGu)7C6F7xDTPFxSr)b2gcC0pymf5U3pf3pjAs)lM7pzomU)WJ7Nvuyu0pvPF)kLEQjU4E)uC)XIf5O)Wu5(dA)hJ73C9lI5nyC)uC)81BYw7pO9NJR6ulkm640l7cyAy05UPK5NOOuCmMhlivsaRrJFIIsXfuSQKxC4j35ivmmxsaRrd5ck2kprXXyESGuHN1VYN8b2gcCuaJPOYkAvlivW8Icb0OXprrP4xP0tnXffmVOqJMyXICuctLLbvEmw)SCCvNArHrhNEzxqBTkxuy0rwnxCFwvoZXyESG0DtjZprrP4ympwqQKaUtTOWOJtVSlkMlKufz4XsDEwWYWez8DtjJCEySiPsyQSmOs1nx9fQrd5Xw5jkogZJfKk8S(v(KhrP1dv3uCmMhlivWS6AJt)0fqG8ipROU5sCKNbsM2DQffgDC6LDjmrglbVv17isOklJflYHlt4DtjJCEySiPsyQSmOs1nx9fQrd5Xw5jkogZJfKk8S(v(KhrP1dv3uCmMhlivWS6AJt)0fqG8ipROU5sCKNbsw65feymFtkIofHLWezSe8wv7ulkm640l7cARv5IcJoYQ5I7ZQYzOtNIm9NtBT2F4X9dqu)lkm60F1Cr)Ms)HhJ5(xm3F69tX9xzNRFEyvJDDQffgDC6LDbT1QCrHrhz1CX9zv5mxC3uYwuy3yjpSQXo91UtrM(ZPTw7p84(tt00C)lkm60F1Cr)Ms)HhJ5(xm3V29tX9RsXC)8WQg76ulkm640l7cARv5IcJoYQ5I7ZQYzlLVBkzlkSBSKhw1yhizA3P6uKP)0ekm64kPjAAUFZ1Vnbph(0Vcf3FIJ7xNfE9NgXOWqY005iZPkV34(350pkbJ5jQK6Fy(46pO97Z9tbhMQrS5tNArHrhxzPCMopdxTruEWRiDKGtgKxNArHrhxzPSEzx4HXIgX2grjxTCn8DtjtqGX8nPi6uewctKXsWBvnpYZ0ptyEEySij9j7vDQffgDCLLY6LDrXCHtsvKkjys3nLmEySiPsyQSmOs1nxq0UtTOWOJRSuwVSl4eNNnIY0UhwQZMZDtjZprrPGtCE2ikt7EyPoBoLdv3KNhglsQeMkldQuDZfeHDQffgDCLLY6LDbBoBeLUKrsWqeUJiHQSmwSihUmH3nLmYJTYtu05z4QnIYdEfPJeCYG8k8S(v(KhrP1dv3u05z4QnIYdEfPJeCYG8kywDTXPpzfipIsRhQUPOyUWjPksLemPcMvxBCGODNArHrhxzPSEzxCGTzSruIW7WscgIWDtjtqGX8nPi6uewCGTzSruIW7WscgIqEYjNCKNbI2A0GO06HQBkkMlCsQIujbtQGz11ghi5qG8KJ8mqYiRgnikTEO6MII5cNKQivsWKkywDTXbs6ciGgn8WyrsLWuzzqLQBU6NPTaDQffgDCLLY6LDb5zs)eSlUBkzipt)mT7ulkm64klL1l7II5cjvrgESuNNfSmmrgF3uYqEwrDZL4ipdKmTZtopmwKeixlhA04NOOuWjopBeLPDpSuNnNYHQBeOtTOWOJRSuwVSlHjYyj4TQEhrcvzzSyroCzcVBkzipROU5sCKNbsw65jNhglsceYMdnA8tuuk4eNNnIY0UhwQZMt5q1ncKNCbfBLNO4zHerv9PfEw)kF0OrqGX8nPi6uewctKXsWBvvGo1IcJoUYsz9YUG8mPU9g3Pit)lkm64klL1l7IsLKnIshJbZtijyic3nLm)efLIpLGemMIkhQU5UnbJXjGJmHDQffgDCLLY6LDXVUic0KqsWqeUJiHQSmwSihUmH3nLmbbgZ3KIOtryXVUic0KqsWqeYtUFIIsXNsqcgtrLeWA0qESvEIINfsev1Nw4z9R8jpymFtkIofHLWezSe8wvZJ8m9VMac0P6uKP)CIsRhQUX1Pwuy0XvqNmBUrjWYCt4rgESuNNfSmmrg3Pwuy0Xvqh9YUK4yPfS69zv5SAIlW0eNuKwp8ibxtuxrUtTOWOJRGo6LDXVsPhPscMuNArHrhxbD0l7IpJDmMGnIDkY0)1nh3FAcJ2H7NikgZt0VP0pjAs)lM7x1CoBe7FJ(R86I(f2Fo5z9VZPFD056E0pAb3ppmwKu)6SWZM(VQq2(DmIohxNArHrhxbD0l7YIr7WYGIX8e3nLmKNvu3CjoYZajtyEEySiPsyQSmOs1nxqYUQq2o1IcJoUc6Ox2LQj6fozAtoIQ8eDQffgDCf0rVSlkgM9Ru6PtTOWOJRGo6LDzhe7c8wLOTw7ulkm64kOJEzxcAcYtsvKhEdV7MswSyrokHPYYGkpgdcX0Pwuy0Xvqh9YU4ckwvYlo8K7CKkgMVBkzikTEO6MIlOyvjV4WtUZrQyyUG8wSi7YsxJgYruA9q1nffZfojvrQKGjvWS6AJt)SCKh5zGKPDEeLwpuDtbBoBeLUKrsWqekywDTXPFMqb0OjwSihLWuzzqLhJ1ptiz7ulkm64kOJEzxCmMhliD3uYquA9q1nfS5Sru6sgjbdrOGz11gN(zPRrtSyrokHPYYGkpgRFMW07uDkY0paJ5Xcs9dgBuSfK6ulkm64kogZJfKYWMZgrPlzKemeH7isOklJflYHlt4DtjBrHDJL8WQg70xBnAaJ5Bsr0PiS4aBZyJOeH3HLemeHo1IcJoUIJX8ybj9YUOyUWjPksLemP7Msg5(jkkf)kLEQjUOKaopymFtkIofHfS5Sru6sgjbdriVGwInJTGloDMsiX0K54rtCCHN1VYhb0OXprrP4ympwqQGz11gN(c1OH8ff2nwYdRASdeH5xuy3yjpSQXo9jRaDQffgDCfhJ5Xcs6LDXb2MXgrjcVdljyic3nLmbbgZ3KIOtryXb2MXgrjcVdljyic5jFrHDJL8WQg7ajtBnAiFrHDJL8WQg7YsppymFtkIofHf)6Iiqtcjbdrqab6ulkm64kogZJfK0l7IFDreOjHKGHiChrcvzzSyroCzc7uDkY0pGnIvU)yXIC0)L(ZPkV34(bJnk2csDkY0)IcJoUIlYq7G4Q0prr5(SQCgoX5zJOmT7HL6S5C3uYwuy3yjpSQXUmH5jxqXw5jkogZJfKk8S(v(OrdIsRhQUP4ympwqQGz11ghiAlqNArHrhxXf6LDrNNHR2ikp4vKosWjdYRtTOWOJR4c9YUGnNnIsxYijyic3rKqvwglwKdxMW7MsgYZajJSDQffgDCfxOx2ffZfojvrQKGjD3uY4HXIKkHPYYGkv3Cbr7o1IcJoUIl0l7c2C2ikDjJKGHiChrcvzzSyroCzc7ulkm64kUqVSl4eNNnIY0UhwQZMZDtjZprrPGtCE2ikt7EyPoBoLdv3KNhglsQeMkldQuDZfeH5xuy3yjpSQXoqe2Pwuy0XvCHEzxumxiPkYWJL68SGLHjY47MsgYZ0pl98K7NOOuWjopBeLPDpSuNnNYHQB0OHhglscKRLdb6ulkm64kUqVSl8WyrJyBJOKRwUg(UPKH8m9Z0oppmwKK(K9Qo1IcJoUIl0l7IFDreOjHKGHiChrcvzzSyroCzcVBkzccmMVjfrNIWIFDreOjHKGHiKNCeLwpuDtbBoBeLUKrsWqekywDTXbI2A0G8mqY0wG8KJO06HQBkkMlCsQIujbtQGz11ghixtJgKNbs210OHCKNLLEEWy(MueDkclHjYyj4TQkGa59tuukoDMsiX0K54rtCCXflIG(P3Pwuy0XvCHEzxqEMu3EJ7ulkm64kUqVSlipt6NGDXDtjd5zf1nxIJ8mqYeMFrHDJL8WQg7YeQrdYZkQBUeh5zGKLENArHrhxXf6LDjmrglbVv17isOklJflYHlt4DtjtqGX8nPi6uewctKXsWBvnpYZkQBUeh5zGKLEEY9tuuk4eNNnIY0UhwQZMt5q1nA0WdJfjbczZHaDkY0)IcJoUIl0l7IsLKnIshJbZtijyic3nLmWy(MueDkcl(1frGMescgIqEKNbI259tuukoDMsiX0K54rtCCXflIG(PF3MGX4eWrMqiWMeEumeaWuZjyadiea]] )
end