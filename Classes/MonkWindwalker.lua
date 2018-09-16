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

    spec:RegisterPack( "Windwalker", 20180915.2123,
        [[d0u92aqikk9iufUeffuBsj1NKGsJII0POiEffvZcr6waP2LK(LQsddi5yOOLbuEgq00qvuxdryBaH(gqqnoLe6CiIADiI08Ka3tj2NQIdIiIfIQ0dPOOjsrb5IabAJsqKpsrbgPeu0jbcYkLqVKIcntGaCtjiStGQFkbfgQscwQeu9uatfbUkqa9vjiTxO(ljdwLdRyXs0JrAYk1Lj2mk9zuz0uYPPA1kj61QQMTQCBk1UL63qgocDCjiQLd65KA6cxNcBhb9Duy8kjDEe16rvK5JQA)IgZetagypHGbhmqXCfbfjZKevWycgyKGeyGGmrbdqCO)dNGb6XwWafQ3BgZ7xGyaId5hA2ycWaAKbKkyaEKNvee1K0VF58WYOSsr2F1UTXBch1u4WgF1Un9B5dv(TKDa9wi8lriI1FI(7kaLcF8T(7ku4QcbQ)vfQ3BgZ7xGvTBtXaLg(laHACjgypHGbhmqXCfbfjZKevWyYKKXaAIcfdoyGijJb2IMIb4rEfQ3BgZ7xG5viq9FwKh5zfbrnj97xopSmkRuK9xTBB8MWrnfoSXxTBt)w(qLFlzhqVfc)seIy9NO)UcqPWhFR)UcfUQqG6FvH69MX8(fyv720SipYdqigIDPaZJjjinpWafZvmpqN3kssbjOYBfkezXSipYZmTMMt0K0SipYd05v4InIqzNhD0H3C5rTe6FESqKDEaeLbMxH5078acO)l5zQ107NSZZ7qG98EKZRKCEHLK3S3O2KAwKh5b68mtRP5KDEXa5Kq5S5Pj3XSAEbkpkz6tuXa5KqNNPXa5Kq5S51OipTbrIiyi78kjN3S3O2KAwKh5b68md56P8j78k8IfAE0PPY7nHJ6AwKh5b68mdqOTYmoq7jpq)jpoeAR(hO9uZI8ipqNhiKnXNylDi78M8ik92BU8miUNqYlq5vOfAEKKvaeqEH1e5Xy05rekekD4nxEtE8wyygZZ780EZ9eqhdKtI8m9jZ2BU8cuEpuZLhJXdTjvmWZ1HgtagGUXeGbNjMamWqdh1yaVje9lQvnKgdi9u(KnMxCGbhmmbyaPNYNSX8Ib6XwWapdDargAfh6TLwr8zypCcgyOHJAmWZqhqKHwXHEBPveFg2dNGdm4GetagyOHJAmq5dH2kwdizmG0t5t2yEXbgCEgtagyOHJAmqPa1c83BomG0t5t2yEXbgCsGjadi9u(KnMxmaf6Ha9bdqT8Q9SAEGopQLN3NL8yM368KwGCKRHBlQaPSNvZ7ZsEGQscmWqdh1yGbsNwubccLoWbgCqetagyOHJAmWZ5ScTALgBoBPdmG0t5t2yEXbgCqymbyGHgoQXaSoukFi0gdi9u(KnMxCGbFfXeGbgA4Ogdmnv0bCEk68EyaPNYNSX8Idm4KmMamG0t5t2yEXauOhc0hmqmqojQHBlQaP2UK3N8izmWqdh1yGazqTuiw1wMWchyWzckmbyaPNYNSX8IbOqpeOpyakc92igDvhiOTsgyyPMERyDOuPwdKt05TKhy5XNFEMMhfHEBeJUY66qRqSkwdi5kuShV15vWsEGyERZJA559zjpqM368Oi0BJy0vOR9MtPnA1Vt)RqXE8wNxbl5XmptYJp)8IbYjrnCBrfi12L8kyjpMKadm0WrngqhiOTsgyyPMERyDOGdm4mzIjadi9u(KnMxmaf6Ha9bdqrO3gXORqx7nNsB0QFN(xHI94ToVcwYdS84ZpVyGCsud3wubsTDjVcwYJjyyGHgoQXaAbkThKXboWaeHcfzxobMam4mXeGbKEkFYgZloWGdgMamG0t5t2yEXbgCqIjadi9u(KnMxCGbNNXeGbKEkFYgZloWGtcmbyGHgoQXaerHJAmG0t5t2yEXbgCqetagq6P8jBmVyak0db6dgW08mBEX8KoQAbkThKRspLpzNhF(5z28I5jDuzDDOqSQWsumS8quHZjWQ0t5t25zcgyOHJAma1YvLgqDGdm4GWycWadnCuJbOwUIXqOGbKEkFYgZloWbgqlqP9GmMam4mXeGbKEkFYgZlgyOHJAma01EZP0gT63P)yakz6tuXa5KqJbNjoWGdgMamG0t5t2yEXauOhc0hmGP5vAWYwlFi0(zOJQbX8wNhrOqOIJURmRqx7nNsB0QFN(N368mBEdpjqpKQMHZgkiYO3widTuLEkFYoptYJp)8knyzRAbkThKRqXE8wNxb5Xmp(8ZBOHtOOKwSDrN3N8yIbgA4OgdW66qRqSkwdizCGbhKycWaspLpzJ5fdqHEiqFWaMnpIqHqfhDxzw1e9U9MtrHtlQFN(N368mnVHgoHIsAX2fDEFwYdK5XNFEMM3qdNqrjTy7IoVL8alV15rekeQ4O7kZA5BO)iJq970)8mjptWadnCuJb0e9U9MtrHtlQFN(Jdm48mMamG0t5t2yEXadnCuJbkFd9hzeQFN(JbOKPprfdKtcngCM4ahyGTWogVatagCMycWadnCuJbgJaPMig6pgq6P8jBmV4adoyycWadnCuJb0eLbQSMER0b0)fmG0t5t2yEXbgCqIjadi9u(KnMxmaf6Ha9bdeZt6OQfO0EqUk9u(KDERZJIqVnIrx1cuApixHI94ToVcYdK5TopPfih5A42Ikqk7z18(KhZ8wNxPblBfAOT8MtTYzlkgEVRBeJgdm0WrngaAOT8MtTYzlkgEVXbgCEgtagq6P8jBmVyak0db6dgWS5fZt6OYHqB1)aTNQ0t5t2yaVdbs48WaKmOWaePHYsMxyHbavLeyGHgoQXabYGAPqSQ)bAp4adojWeGbKEkFYgZlgGc9qG(GbI5jDu5qOT6FG2tv6P8jBmG3HajCEyasguyaI0qzjZlSWamXadnCuJbcKb1sHyv)d0EWbgCqetagq6P8jBmVyak0db6dgO0GLTQfO0EqUAqmp(8ZR0GLTQde0wjdmSutVvSouQgeZJp)8mnpZMxmpPJQwGs7b5Q0t5t25ToVa69VevIqeToC(ZdYvOm0iptYJp)8knyzRLpeA)m0rfkdnYJp)8IbYjrnCBrfi12L8kyjpqeuyGHgoQXaerHJACGbhegtagq6P8jBmVyak0db6dgO0GLTQfO0EqUAqedm0WrngGoVNAOHJA1Z1bg456q1JTGb0cuApiJdm4RiMamG0t5t2yEXauOhc0hmGP5jTa5ixd3wubszpRMxb5Xmp(8ZZ08I5jDu1cuApixLEkFYoV15rrO3gXORAbkThKRqXE8wNxb5bwEMKNj5TopQLxTNvZd05rT88(SKhiXadnCuJbyDDOqSQWsumS8quHZjqCGbNKXeGbKEkFYgZlgyOHJAmq4CcurCE2yak0db6dgW08KwGCKRHBlQaPSNvZRG8yMhF(5zAEX8KoQAbkThKRspLpzN368Oi0BJy0vTaL2dYvOypERZRG8alptYZK8wNh1YR2ZQ5b68OwEEFwYdS8wNNzZJiuiuXr3vM1W5eOI48SXauY0NOIbYjHgdotCGbNjOWeGbKEkFYgZlgyOHJAmaDEp1qdh1QNRdmWZ1HQhBbdq34adotMycWaspLpzJ5fdqHEiqFWadnCcfL0ITl68kipqMhF(5zAEdnCcfL0ITl68wYdK5ToVHNeOhsvZWzdfez0BlKHwQWP)Z7tEGLNjyGHgoQXa059udnCuREUoWapxhQESfmGoWbgCMGHjadi9u(KnMxmaf6Ha9bdm0Wjuusl2UOZ7tEGmp(8ZZ08gA4ekkPfBx05TKhiZBDEdpjqpKQMHZgkiYO3widTuHt)Nxbl5bwEMGbgA4OgdqN3tn0WrT656ad8CDO6XwWadsWboWa6atagCMycWadnCuJbyy5WN3CQnC4qTIOrtTWaspLpzJ5fhyWbdtagq6P8jBmVyGHgoQXaqx7nNsB0QFN(JbOqpeOpyatZJIqVnIrxzDDOviwfRbKCfk2J368(Khy5XNFEulpVpl5rI84ZpVHNeOhsvZWzdfez0BlKHwQWP)Z7tEmZZemaLm9jQyGCsOXGZehyWbjMamG0t5t2yEXauOhc0hmqPblBfAOT8MtTYzlkgEVRBeJoV15jTa5ixd3wubszpRM3N8yM368gA4ekkPfBx059jpMyGHgoQXaqdTL3CQvoBrXW7noWGZZycWaspLpzJ5fdqHEiqFWaslqoY1WTfvGu2ZQ59jpWQKiV15zAEdpjqpKQMHZgkiYO3widTuHt)Nxb5bwE85NNP5rrO3gXORmSC4ZBo1goCOwr0OPwvOypERZRG8ycQ8wNxmpPJkdlh(8MtTHdhQvenAQvv6P8j78mjp(8ZBOHtOOKwSDrN3N8yMNjyGHgoQXaSUo0keRI1asghyWjbMamG0t5t2yEXauOhc0hma1YZRGL8alV15zAELgSSvOH2YBo1kNTOy49UUrm684ZppPfih58(KhpdI5zcgyOHJAmaRRdfIvfwIIHLhIkCobIdm4GiMamG0t5t2yEXauOhc0hma1YZRGL8azERZtAbYroVcYJeGcdm0WrngqAbY58K3Ck55R6qCGbhegtagq6P8jBmVyGHgoQXaLVH(Jmc1Vt)XauOhc0hmGzZJiuiuXr3vM1Y3q)rgH63P)5ToptZJIqVnIrxHU2BoL2Ov)o9Vcf7XBDEFYdS84ZppQLN3NL8azEMK368mnptZJIqVnIrxzDDOviwfRbKCfk2J368(Khy5XNFEulpVcYdK5zsE85Nh1YZ7ZsE8CE85NNP5n8Ka9qQAgoBOGiJEBHm0sfo9FEFwYdS8wN3qdNqrjTy7IoVL8yMNj5zsERZR0GLTQz4SHcIm6TfYqlvDm0)8kipWWauY0NOIbYjHgdotCGbFfXeGbgA4OgdqTCfJHqbdi9u(KnMxCGbNKXeGbKEkFYgZlgGc9qG(GbOwE1EwnpqNh1YZ7ZsEmZBDEdnCcfL0ITl68wYJzE85Nh1YR2ZQ5b68OwEEFwYdmmWqdh1yaQLRknG6ahyWzckmbyaPNYNSX8IbgA4OgdeoNaveNNngGc9qG(GbmBEeHcHko6UYSgoNaveNNDERZJA5v7z18aDEulpVpl5bwERZZ08knyzRqdTL3CQvoBrXW7DDJy05XNFEslqoY59jpsaI5zcgGsM(evmqoj0yWzIdm4mzIjadi9u(KnMxmWqdh1ya2hzV5uAbsu6q970Fmaf6Ha9bdqekeQ4O7kZA5BO)iJq970)8wNh1YZ7tEmZBDELgSSvndNnuqKrVTqgAPQJH(Nxb5bggW7qGqdIbgGjoWGZemmbyaPNYNSX8IbOqpeOpyaPfih5A42Ikqk7z18(KhyvsK368Oi0BJy0vOR9MtPnA1Vt)RqXE8wN3N8alV15vAWYw1mC2qbrg92czOLQog6FEl5bggyOHJAmaRRdTcXQynGKXboWadsWeGbNjMamWqdh1yagwo85nNAdhouRiA0ulmG0t5t2yEXbgCWWeGbKEkFYgZlgGc9qG(GbmBEeHcHko6UYSgoNaveNNDERZJA55vWsEmZBDEslqoY5vqEKauyGHgoQXaslqoNN8MtjpFvhIdm4Getagq6P8jBmVyak0db6dgqAbYrUgUTOcKYEwnVp5bwLeyGHgoQXaSUo0keRI1asghyW5zmbyaPNYNSX8IbOqpeOpyGsdw2k0qB5nNALZwum8Ex3igDERZtAbYrUgUTOcKYEwnVp5Xedm0WrngaAOT8MtTYzlkgEVXbgCsGjadi9u(KnMxmWqdh1yaOR9MtPnA1Vt)XauOhc0hmGP5fZt6OYWYHpV5uB4WHAfrJMAvLEkFYoV15rrO3gXORmSC4ZBo1goCOwr0OPwvOypERZRG84O78mjV15rrO3gXORSUo0keRI1asUcf7XBDEFYdKyakz6tuXa5KqJbNjoWGdIycWaspLpzJ5fdqHEiqFWaMnpIqHqfhDxzw1e9U9MtrHtlQFN(N368mnpQLN3N8alp(8ZJIqVnIrxzDDOviwfRbKCfk2J368(KhpNNjyGHgoQXaAIE3EZPOWPf1Vt)XbgCqymbyaPNYNSX8IbOqpeOpyaQLNxbl5bsmWqdh1yaQLRknG6ahyWxrmbyaPNYNSX8IbOqpeOpyaQLxTNvZd05rT88(SKhiZBDEMMN0cKJCEFYJNbX84ZpVsdw2k0qB5nNALZwum8Ex3igDEMGbgA4OgdW66qHyvHLOyy5HOcNtG4adojJjadi9u(KnMxmWqdh1yGW5eOI48SXauOhc0hmGzZJiuiuXr3vM1W5eOI48SZBDEulVApRMhOZJA559zjpWYBDEMMN0cKJCEFYJeGyE85NxPblBfAOT8MtTYzlkgEVRBeJoptWauY0NOIbYjHgdotCGbNjOWeGbgA4OgdqTCfJHqbdi9u(KnMxCGbNjtmbyaPNYNSX8IbgA4OgdW(i7nNslqIshQFN(JbOqpeOpyGsdw2Aj6xreIO1nIrJb8oei0GyGbyIdm4mbdtagq6P8jBmVyGHgoQXaLVH(Jmc1Vt)XauOhc0hmGzZJiuiuXr3vM1Y3q)rgH63P)yakz6tuXa5KqJbNjoWboWaekqTJAm4GbkMRiOizMKOcgO4zMyagdS9MtJbkussHdoie4MbK08YJaljp3Micg5XIG5vy3c7y8IcBEqPq2WHYopnYwYBmcK9eYopQ10CIUMfbb4TKhtsAEGaBTbrIiyi78gA4OoVc7yei1eXq)lS1SyweeYMicgYopqmVHgoQZ756qxZIyaIqeR)emapYRq9EZyE)cmVcbQ)ZI8ipRiiQjPF)Y5HLrzLIS)QDBJ3eoQPWHn(QDB63YhQ8Bj7a6Tq4xIqeR)e93vakf(4B93vOWvfcu)RkuV3mM3VaRA3MMf5rEacXqSlfyEmjbP5bgOyUI5b68wrskibvERqHilMf5rEMP10CIMKMf5rEGoVcxSrek78OJo8MlpQLq)ZJfISZdGOmW8kmNENhqa9FjptTME)KDEEhcSN3JCELKZlSK8M9g1MuZI8ipqNNzAnnNSZlgiNekNnpn5oMvZlq5rjtFIkgiNe68mngiNekNnVgf5PnisebdzNxj58M9g1MuZI8ipqNNzixpLpzNxHxSqZJonvEVjCuxZI8ipqNNzacTvMXbAp5b6p5XHqB1)aTNAwKh5b68aHSj(eBPdzN3KhrP3EZLNbX9esEbkVcTqZJKScGaYlSMipgJopIqHqPdV5YBYJ3cdZyEENN2BUNa6yGCsKNPpz2EZLxGY7HAU8ymEOnPMfZI8ipqWvfQri78kfweuYJISlNiVsHZBDnpscLkedDEnQbT1aTznE5n0WrTopu)ixZIdnCuRReHcfzxoXc7B0)zXHgoQ1vIqHISlNW8LVSi0olo0WrTUsekuKD5eMV8Dm4SLoMWrDwKh5b0drTfkYdo(oVsdwwzNNoMqNxPWIGsEuKD5e5vkCERZB6DEeHcOjIIWBU8CDEBul1S4qdh16krOqr2Lty(YxDpe1wOqPJj0zXHgoQ1vIqHISlNW8LVerHJ6S4qdh16krOqr2Lty(YxQLRknG6GuNDXuZgZt6OQfO0EqUk9u(KnF(MnMN0rL11HcXQclrXWYdrfoNaRspLpzBswCOHJADLiuOi7YjmF5l1YvmgcLSywKh5bcUQqnczNNqOajNx42sEHLK3qdempxN3q44VP8j1S4qdh16LXiqQjIH(NfhA4OwB(YxnrzGkRP3kDa9Fjlo0WrT28LVqdTL3CQvoBrXW7nPo7smpPJQwGs7b5Q0t5t2RPi0BJy0vTaL2dYvOypERlaKRLwGCKRHBlQaPSNv)WCDPblBfAOT8MtTYzlkgEVRBeJolYJ8iazqTYdXMNzCG2tEOopkc92ignP55S5zgGq78mJd0EYZ15j9u(KDEsHSX8Ylq5XeuGYmCEi28SNvDBd78SK5fwzXHgoQ1MV8nqgulfIv9pq7HuVdbs48wizqrkrAOSK5fwlGQscsD2fZgZt6OYHqB1)aTNQ0t5t2K6DiqcN3cjdksjsdLLmVWAbuvsKfhA4OwB(Y3azqTuiw1)aThs9oeiHZBHKbfPePHYsMxyTWKuNDjMN0rLdH2Q)bApvPNYNSj17qGeoVfsguKsKgklzEH1cZSipYBfqHJ68C28aeO0EqopempGabTjnpqWbgwKM3078kKCOK3aL8miMhcMhzKrEduYdA0T3C5PfO0EqoVP35n5zpENNoMiVa69Ve5reIOAsZdbZJmYiVbk5z0BbMxyj5jSScnYdXMx5dH2pdDqAEiyEXa5KiVWTL8cuEBxYZ15XbLjeyEiyEsHSX8Ylq5bIGklo0WrT28LVerHJAsD2Lsdw2QwGs7b5Qbr(8lnyzR6abTvYadl10BfRdLQbr(8n1SX8KoQAbkThKRspLpzVoGE)lrLierRdN)8GCfkdnmHp)sdw2A5dH2pdDuHYqd(8JbYjrnCBrfi12LcwarqLfhA4OwB(Yx68EQHgoQvpxhK2JTSOfO0EqMuNDP0GLTQfO0EqUAqmlo0WrT28LVSUouiwvyjkgwEiQW5eiPo7IPslqoY1WTfvGu2ZQfWKpFtJ5jDu1cuApixLEkFYEnfHEBeJUQfO0EqUcf7XBDbGzIjRPwE1Ewf0ul)ZciZIdnCuRnF5B4CcurCE2KsjtFIkgiNe6fMK6SlMkTa5ixd3wubszpRwat(8nnMN0rvlqP9GCv6P8j71ue6Trm6QwGs7b5kuShV1faMjMSMA5v7zvqtT8plGT2SeHcHko6UYSgoNaveNNDwCOHJAT5lFPZ7PgA4Ow9CDqAp2YcDNf5rEM58E5fwsEaeK3qdh159CDKNZMxyjqjVbk5bwEiyEprRZtAX2fDwCOHJAT5lFPZ7PgA4Ow9CDqAp2YIoi1zxgA4ekkPfBx0fas(8nDOHtOOKwSDrVaY1dpjqpKQMHZgkiYO3widTuHt))bmtYI8ipZCEV8cljpsccemVHgoQZ756ipNnVWsGsEduYdK5HG5zJGsEsl2UOZIdnCuRnF5lDEp1qdh1QNRds7XwwgKqQZUm0Wjuusl2UO)as(8nDOHtOOKwSDrVaY1dpjqpKQMHZgkiYO3widTuHt)xWcyMKfZI8ipscnCuRRKeeiyEUopVdP3YopwempdTKhdpSYRWuOHtvKK9wzMpziuYB6DEudiu64roVwKToVaLxPKhIy42opj7S4qdh166GKfgwo85nNAdhouRiA0uRS4qdh166GeZx(kTa5CEYBoL88vDiPo7IzjcfcvC0DLznCobQiop71ulVGfMRLwGCKlGeGklo0WrTUoiX8LVSUo0keRI1asMuNDrAbYrUgUTOcKYEw9dyvsKfhA4OwxhKy(YxOH2YBo1kNTOy49MuNDP0GLTcn0wEZPw5SffdV31nIrVwAbYrUgUTOcKYEw9dZS4qdh166GeZx(cDT3CkTrR(D6pPuY0NOIbYjHEHjPo7IPX8KoQmSC4ZBo1goCOwr0OPwvPNYNSxtrO3gXORmSC4ZBo1goCOwr0OPwvOypERlGJUnznfHEBeJUY66qRqSkwdi5kuShV1FazwCOHJADDqI5lF1e9U9MtrHtlQFN(tQZUywIqHqfhDxzw1e9U9MtrHtlQFN(V2uQL)bm(8Pi0BJy0vwxhAfIvXAajxHI94T(dpBswCOHJADDqI5lFPwUQ0aQdsD2fQLxWciZIdnCuRRdsmF5lRRdfIvfwIIHLhIkCobsQZUqT8Q9SkOPw(NfqU2uPfih5p8miYNFPblBfAOT8MtTYzlkgEVRBeJ2KS4qdh166GeZx(goNaveNNnPuY0NOIbYjHEHjPo7IzjcfcvC0DLznCobQiop71ulVApRcAQL)zbS1MkTa5i)HeGiF(LgSSvOH2YBo1kNTOy49UUrmAtYIdnCuRRdsmF5l1YvmgcLS4qdh166GeZx(Y(i7nNslqIshQFN(tQZUuAWYwlr)kIqeTUrmAs9oei0GySWmlo0WrTUoiX8LVLVH(Jmc1Vt)jLsM(evmqoj0lmj1zxmlrOqOIJURmRLVH(Jmc1Vt)ZIzrEKNzIqVnIrRZIdnCuRR09I3eI(f1QgsRclrXWYdrfoNaZIdnCuRR0T5lFn0IYdXM0ESLLNHoGidTId92sRi(mShojlo0WrTUs3MV8T8HqBfRbKCwCOHJADLUnF5BPa1c83BUSipYdeOwYJKaPtl5raccLoYZzZJmYiVbk5z7AT3C5nrEpz0rEmZZmT88MENhduxyJ8OdX8KwGCKZJHhwENhOQKipTqr9wNfhA4OwxPBZx(oq60IkqqO0bPo7c1YR2ZQGMA5FwyUwAbYrUgUTOcKYEw9ZcOQKilo0WrTUs3MV895CwHwTsJnNT0rwCOHJADLUnF5lRdLYhcTZIdnCuRR0T5lFNMk6aopfDEVS4qdh16kDB(Y3azqTuiw1wMWIuNDjgiNe1WTfvGuBx(qYzXHgoQ1v628LV6abTvYadl10BfRdfsD2fkc92igDvhiOTsgyyPMERyDOuPwdKt0lGXNVPue6Trm6kRRdTcXQynGKRqXE8wxWciUMA5Fwa5Akc92igDf6AV5uAJw970)kuShV1fSW0e(8JbYjrnCBrfi12LcwysIS4qdh16kDB(YxTaL2dYK6Slue6Trm6k01EZP0gT63P)vOypERlybm(8JbYjrnCBrfi12LcwycwwmlYJ8aeO0EqopIqhb9GCwCOHJADvlqP9G8c01EZP0gT63P)KsjtFIkgiNe6fMzXHgoQ1vTaL2dYMV8L11HwHyvSgqYK6SlMwAWYwlFi0(zOJQbX1eHcHko6UYScDT3CkTrR(D6)AZo8Ka9qQAgoBOGiJEBHm0sv6P8jBt4ZV0GLTQfO0EqUcf7XBDbm5ZFOHtOOKwSDr)HzwCOHJADvlqP9GS5lF1e9U9MtrHtlQFN(tQZUywIqHqfhDxzw1e9U9MtrHtlQFN(V20HgoHIsAX2f9NfqYNVPdnCcfL0ITl6fWwtekeQ4O7kZA5BO)iJq970Ftmjlo0WrTUQfO0Eq28LVLVH(Jmc1Vt)jLsM(evmqoj0lmZIzrEKhG3CpjVyGCsK338mZNmek5re6iOhKZI8iVHgoQ1vDSqNMkpvPbllP9yllqdTL3CQvoBrXW7nPo7YqdNqrjTy7IEH5AtnBmpPJQwGs7b5Q0t5t285trO3gXORAbkThKRqXE8w)bKMKfhA4Owx1H5lFzy5WN3CQnC4qTIOrtTYIdnCuRR6W8LVqx7nNsB0QFN(tkLm9jQyGCsOxysQZUykfHEBeJUY66qRqSkwdi5kuShV1FaJpFQL)zHe85p8Ka9qQAgoBOGiJEBHm0sfo9)hMMKfhA4Owx1H5lFHgAlV5uRC2IIH3BsD2Lsdw2k0qB5nNALZwum8Ex3ig9APfih5A42Ikqk7z1pmxp0Wjuusl2UO)Wmlo0WrTUQdZx(Y66qRqSkwdizsD2fPfih5A42Ikqk7z1pGvjXAthEsGEivndNnuqKrVTqgAPcN(VaW4Z3ukc92igDLHLdFEZP2WHd1kIgn1Qcf7XBDbmb16yEshvgwo85nNAdhouRiA0uRQ0t5t2MWN)qdNqrjTy7I(dttYIdnCuRR6W8LVSUouiwvyjkgwEiQW5eiPo7c1YlybS1MwAWYwHgAlV5uRC2IIH376gXO5ZxAbYr(dpdIMKfhA4Owx1H5lFLwGCop5nNsE(QoKuNDHA5fSaY1slqoYfqcqLf5rEfU8MvLDEMPLNhre65nxESiyEfsOcP80EtfsZZzZJmYiVnQlSrEwdHsEGmpZ0Yjnpl0B7nxE8wyygZZ15XH8oVaL3VieZJmYipwiYopcCobM3kmpBV5YJfbZZmT8AwCOHJADvhMV8T8n0FKrO(D6pPuY0NOIbYjHEHjPo7IzjcfcvC0DLzT8n0FKrO(D6)AtPi0BJy0vOR9MtPnA1Vt)RqXE8w)bm(8Pw(NfqAYAtnLIqVnIrxzDDOviwfRbKCfk2J36pGXNp1YlaKMWNp1Y)SWZ85B6Wtc0dPQz4SHcIm6TfYqlv40)FwaB9qdNqrjTy7IEHPjMSU0GLTQz4SHcIm6TfYqlvDm0)callo0WrTUQdZx(sTCfJHqjlo0WrTUQdZx(sTCvPbuhK6SlulVApRcAQL)zH56HgoHIsAX2f9ct(8PwE1Ewf0ul)ZcyzXHgoQ1vDy(Y3W5eOI48SjLsM(evmqoj0lmj1zxmlrOqOIJURmRHZjqfX5zVMA5v7zvqtT8plGT20sdw2k0qB5nNALZwum8Ex3ignF(slqoYFibiAswCOHJADvhMV8L9r2BoLwGeLou)o9NuNDHiuiuXr3vM1Y3q)rgH63P)RPw(hMRlnyzRAgoBOGiJEBHm0svhd9VaWi17qGqdIXcZS4qdh16QomF5lRRdTcXQynGKj1zxKwGCKRHBlQaPSNv)awLeRPi0BJy0vOR9MtPnA1Vt)RqXE8w)bS1LgSSvndNnuqKrVTqgAPQJH(Vaggymcleeda42MjoWbgd]] )
end