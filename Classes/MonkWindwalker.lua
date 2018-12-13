-- MonkWindwalker.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'MONK' then
    local spec = Hekili:NewSpecialization( 269 )

    spec:RegisterResource( Enum.PowerType.Energy, {
        rushing_jade_wind = not PTR and {
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
        } or nil,

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
        exit_strategy = {
            id = 289324,
            duration = 2,
            max_stack = 1
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
        rushing_jade_wind = PTR and {
            id = 116847,
            duration = function () return 9 * haste end,
            max_stack = 1,
            dot = "buff",
        } or {
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
        dance_of_chiji = {
            id = 286587,
            duration = 15,
            max_stack = 1
        },

        fury_of_xuen = {
            id = 287062,
            duration = 20,
            max_stack = 67,
        },

        fury_of_xuen_haste = {
            id = 287063,
            duration = 8,
            max_stack = 1,
        },

        iron_fists = not PTR and {
            id = 272806,
            duration = 10,
            max_stack = 1,
        } or nil,

        swift_roundhouse = not PTR and {
            id = 278710,
            duration = 12,
            max_stack = 2,
        } or nil,

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
                
                Hekili:ForceUpdate( "WW_MISSED" )
            
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
                if azerite.fury_of_xuen.enabled then addStack( "fury_of_xuen", nil, 1 ) end
                
                if not PTR and azerite.meridian_strikes.enabled and cooldown.touch_of_death.remains > 0 then
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

                if not PTR and azerite.swift_roundhouse.enabled then
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
                if not PTR and azerite.iron_fists.enabled and active_enemies > 3 then applyBuff( "iron_fists" ) end
                if PTR and buff.fury_of_xuen.stack >= 50 then
                    applyBuff( "fury_of_xuen_haste" )
                    summonPet( "xuen", 8 )
                    removeBuff( "fury_of_xuen" )
                end
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
                if not PTR then removeBuff( "swift_roundhouse" ) end

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
                if azerite.exit_strategy.enabled then applyBuff( "exit_strategy" ) end
            end,
        },
        

        rushing_jade_wind = PTR and {
            id = 116847,
            cast = 0,
            cooldown = function ()
                local x = 6 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            hasteCD = true,
            gcd = "spell",
            
            spend = 1,
            spendType = "chi",
            
            talent = "rushing_jade_wind",

            startsCombat = false,
            texture = 606549,
            
            handler = function ()
                applyBuff( "rushing_jade_wind" )
            end,
        } or {
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
            
            spend = function () return buff.dance_of_chiji.up and 0 or 2 end,
            spendType = "chi",
            
            startsCombat = true,
            texture = 606543,
            
            handler = function ()
                removeBuff( "dance_of_chiji" )
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

    spec:RegisterPack( "Windwalker", 20181212.2313, [[dW0XVaqissEecXLKuvWMqGpHqsJIK4uKqVIemle0TaQSlL8ljLHHOQJHildH6zuPAAKKY1OsX2quPVjPIACsQsNtsLSoQuQ5rL09KK9rL4GsQIfIO8qjvQjkPQOlkPISres5JKKknsssfNKKu1kjPEPKQsZusvHUPKk0ovfgkcPAPiQ4PaMQQORkPQQVIqI9c5VKAWQCyPwSeEmOjRQUmQntWNj0OPQonLvtLsEnqMTsDBQy3k(nudxv64sQQSCKEortx46uLTdu(Ue14bQ68KO1lPcMVez)Igrc9eb87GrpiM8KQxsetI4fXUtYDYtmciu(YiG3gcQfzeW0omcGOyZVCVbXueWBRCJ7p6jcqI9Oqgb4hXR0TRvt0cFVIfe7utAoE7om8aPTqutAoWAfBCrTcHgCFgSAVuSGTzznIoLjN2(YAeDYrxhXdinrXMF5EdIPlP5arafE2ou9dQab87GrpiM8KQxsetI4fXUtIyvZnia5ldrpiMCRleGV9)8GkqaFwcraejpIIn)Y9getZRoIhqPAIKNFeVs3Uwnrl89kwqStnP54T7WWdK2crnP5aRvSXf1keAW9zWQ9sXc2ML1i6uMCA7lRr0jhDDepG0efB(L7niMUKMdmvtK8Qpzi7uW08irmH5rm5jvV5bU8i2D3MeXP6unrYRU97rKLUDQMi5bU8ih2bdgNhWl308uD65NhqqnqCEq88ddpY8uXVN)M)5vOmV()XJIRunrYdC5roSdgmopIgq9npkdXoo887WWtEQu2278kyi2HZRZ7LYckUs1ejpWLxD73JiNx0uro0MqEbopOs4M1rtf5qUs1ejpWLh5WoyW484HPIkZd2V5b9ziO8eW08iAMmK5HfYJO5rvMNksZjVVjiWuEGCEMmVHf3MOvSzcZRWlY7D3kZ7BccmLhiNNjZtAIJjyWEcfxPAIKh4YRE(F(Nx9xY5P6d2rMNkb1gqCijmpoGlfxiGTjdj6jca(rprpiHEIaAyy4bbydyyqSg8E8Ga4Pl28hrgkqpig9ebWtxS5pImeW0omcy7jdk2tQfX7pp63TNtlYiGgggEqaBpzqXEsTiE)5r)U9CArgfOhUJEIaAyy4bb4jzTfSJebWtxS5pImuGEOAONiGgggEqafBm(Rf8Okra80fB(JidfOhUb9eb0WWWdcOGPsMcYgreapDXM)iYqb6b5IEIa4Pl28hrgcasTGPwJaG(2YPbFEGlpOVLNlv5rkpcYJhMkQCfMdRdS2PbFEUuLh5xUbb0WWWdcOPWEyDGPuEcuGEuNrpranmm8Ga2MOFi1UL3x0HNabWtxS5pImuGEuVONiGgggEqacgLl2y8hbWtxS5pImuGEuxONiGgggEqa9azzq7Tg27ncGNUyZFezOa9Ge5rpra80fB(JidbaPwWuRrartf5yfMdRdS(BCEUKxDHaAyy4bbeypOVglO)Ch(Oa9Gej0teapDXM)iYqaqQfm1AeaeJ3FC5zjdm1rZnn81981cgLxq)MkYY8QYJ48kvkpvYdIX7pU8Semzi1ybTGhv5IYoTnY8CTkpYnpcYd6B55svEUNhb5bX49hxEwutAJOw6nAqge0IYoTnY8CTkps5PyELkLx0urowH5W6aR)gNNRv5rYniGgggEqaYatD0CtdFDpFTGrzuGEqIy0teapDXM)iYqaqQfm1AeaeJ3FC5zrnPnIAP3Obzqqlk702iZZ1Q8ioVsLYlAQihRWCyDG1FJZZ1Q8irmcOHHHheGKP8yHsuGceWlLHyNIoqprpiHEIa4Pl28hrgkqpig9ebWtxS5pImuGE4o6jcGNUyZFezOa9q1qpra80fB(JidfOhUb9eb0WWWdc4fhgEqa80fB(JidfOhKl6jcGNUyZFeziai1cMAncqL8uvErV5jwsMYJfkx80fB(NxPs5PQ8IEZtSemzOXc6WN1L9TG1HjY0fpDXM)5PicOHHHhea030fEuzGc0J6m6jcOHHHhea030LBWyeapDXM)iYqbkqanMrprpiHEIa4Pl28hrgcOHHHhea1K2iQLEJgKbbHaGulyQ1iavYl6npXQSVr32iQ)0wep6xVb6V4Pl28ppcYdIX7pU8Sk7B0TnI6pTfXJ(1BG(lk702iZZ18CtEkMhb5bX49hxEwcMmKASGwWJQCrzN2gzEUKN7iaOs4M1rtf5qIEqcfOheJEIaAyy4bbu23OBBe1FAlIh9R3a9ra80fB(JidfOhUJEIa4Pl28hrgcasTGPwJauvEVugmTi8ViTctKP63E7Khb5b9T8CTkps5rqE8WurL55AEUH8iGgggEqa8WurRoyJOM3g4nkkqpun0teqdddpiabtgsnwql4rvIa4Pl28hrgkqpCd6jcGNUyZFeziai1cMAncOWtqyr9K(2iQDR(Z6Y28xFC5bb0WWWdcG6j9Tru7w9N1LT5Jc0dYf9ebWtxS5pImeaKAbtTgbOQ8EPmyAr4FrAjFTzSrudP9WAqgeuEeKNk5PsEQKh03YZL8CpVsLYdIX7pU8Semzi1ybTGhv5IYoTnY8CjpYnpfZJG8ujpOVLNlv55M8kvkpigV)4YZsWKHuJf0cEuLlk702iZZL8iopfZtX8kvkpEyQOYvyoSoWANg855AvEUNNIiGgggEqaYxBgBe1qApSgKbbHc0J6m6jcGNUyZFeziai1cMAnca6B55AvEUJaAyy4bba9nDHhvgOa9OErpra80fB(JidbaPwWuRraqFB50GppWLh03YZLQ8Chb0WWWdcqWKHglOdFwx23cwhMitrb6rDHEIa4Pl28hrgcOHHHheqyImv)2BheaKAbtTgba9TLtd(8axEqFlpxQYJ48iipvYtv5f9MNy5BHgIDkWlE6In)ZRuP8uvEVugmTi8ViTctKP63E7KNIiaOs4M1rtf5qIEqcfOhKip6jcOHHHhea030LBWyeapDXM)iYqb6bjsONiaE6In)rKHaAyy4bbuSBiiSxObzqqiai1cMAncqv59szW0IW)I0Qy3qqyVqdYGGYJG8ujVcpbHvbgK(LIHlV38kvkpvYl6npXY3cne7uGx80fB(Nhb59szW0IW)I0kmrMQF7TtEeKh03YZ18uT8umpfraqLWnRJMkYHe9Gekqbc4ZcT3oqprpiHEIaAyy4bb0Ebw3r0qqiaE6In)rKHc0dIrpranmm8GaKVCt1(981YGAGyeapDXM)iYqb6H7ONiaBcMcwVra1f5raVWq7Z9o8raKF5geqdddpiGa7b91ybnOM60iaE6In)rKHc0dvd9ebWtxS5pImeaKAbtTgbu4jiSKmLhluU8EZRuP8k8eewYatD0CtdFDpFTGr5L3BELkLNk5PQ8IEZtSKmLhluU4Pl28ppcYlO2aIJ1lfdxTOTTq5IYnmYtX8kvkVcpbHvXgJ)BpzSOCdJ8kvkVOPICScZH1bw)nopxRYJCjpcOHHHheWlom8Gc0d3GEIa4Pl28hrgcasTGPwJak8eewsMYJfkxEViGgggEqaWEV1nmm8O3MmqaBtg6PDyeGKP8yHsuGEqUONiaE6In)rKHaGulyQ1iavYJhMkQCfMdRdS2PbFEUMhP8kvkpvYl6npXsYuESq5INUyZ)8iipigV)4YZsYuESq5IYoTnY8CnpIZtX8umpcYd6BlNg85bU8G(wEUuLN7iGgggEqacMm0ybD4Z6Y(wW6WezkkqpQZONiaE6In)rKHaAyy4bbeMit1V92bbaPwWuRraQKhpmvu5kmhwhyTtd(8Cnps5vQuEQKx0BEILKP8yHYfpDXM)5rqEqmE)XLNLKP8yHYfLDABK55AEeNNI5PyEeKh03won4ZdC5b9T8CPkpIZJG8uvEVugmTi8ViTctKP63E7GaGkHBwhnvKdj6bjuGEuVONiaE6In)rKHaAyy4bba79w3WWWJEBYabSnzON2HraWpkqpQl0teapDXM)iYqaqQfm1AeqdddmwZd7ySmpxZZDeqdddpiayV36gggE0BtgiGTjd90omcqgOa9Ge5rpra80fB(JidbaPwWuRranmmWynpSJXY8CPkp3ranmm8GaG9ERByy4rVnzGa2Mm0t7WiGgZOafiazGEIEqc9eb0WWWdcOSVr32iQ)0wep6xVb6Ja4Pl28hrgkqpig9ebWtxS5pImeqdddpiaQjTrul9gnidccbaPwWuRraqFlpxQYZniaOs4M1rtf5qIEqcfOhUJEIaAyy4bbiyYqQXcAbpQseapDXM)iYqb6HQHEIa4Pl28hrgcOHHHhea1K2iQLEJgKbbHaGkHBwhnvKdj6bjuGE4g0teapDXM)iYqaqQfm1AeGQY7LYGPfH)fPL81MXgrnK2dRbzqq5rqEfEccRFpqwJf0qFZTSL3lcOHHHheG81MXgrnK2dRbzqqOa9GCrpra80fB(JidbaPwWuRrafEcclQN03grTB1Fwx2M)6Jlp5rqEnmmWynpSJXY8CjpsiGgggEqaupPVnIA3Q)SUSnFuGEuNrpra80fB(JidbaPwWuRraqFlpxRYJyeqdddpiabtgASGo8zDzFlyDyImffOh1l6jcGNUyZFeziai1cMAnca6B55AvEUNhb5XdtfvMNR55gYJaAyy4bbWdtfT6GnIAEBG3OOa9OUqpra80fB(Jidb0WWWdcOy3qqyVqdYGGqaqQfm1AeGQY7LYGPfH)fPvXUHGWEHgKbbLhb5PsEqmE)XLNf1K2iQLEJgKbbTOStBJmpxYZ98kvkpOVLNlv55EEkMhb5PsEqmE)XLNLGjdPglOf8Okxu2PTrMNl5PA5vQuEqFlpxQYt1YRuP8ujpOVLxvEeNhb59szW0IW)I0kmrMQF7TtEkMNI5rqEfEcclzzti0uS389XEsEjJgckpxZJyeaujCZ6OPICirpiHc0dsKh9eb0WWWdca6B6YnymcGNUyZFezOa9Gej0teapDXM)iYqaqQfm1Aea03won4ZdC5b9T8CPkps5rqEnmmWynpSJXY8QYJuELkLh03won4ZdC5b9T8CPkpIranmm8GaG(MUWJkduGEqIy0teapDXM)iYqanmm8GactKP63E7GaGulyQ1iavL3lLbtlc)lsRWezQ(T3o5rqEqFB50GppWLh03YZLQ8igbavc3SoAQihs0dsOafiajt5XcLONOhKqpra80fB(Jidb0WWWdcGAsBe1sVrdYGGqaqQfm1AeqdddmwZd7ySmpxZZ98kvkVxkdMwe(xKwYxBgBe1qApSgKbbHaGkHBwhnvKdj6bjuGEqm6jcGNUyZFeziai1cMAncqL8k8eewfBm(V9KXY7npcY7LYGPfH)fPf1K2iQLEJgKbbLNI5vQuEfEccljt5XcLlk702iZZ18iLxPs5PsEnmmWynpSJXY8Cjps5rqEnmmWynpSJXY8Cnp3KNIiGgggEqacMmKASGwWJQefOhUJEIa4Pl28hrgcasTGPwJauvEVugmTi8ViTKV2m2iQH0EynidckpcYtL8AyyGXAEyhJL55svEUNxPs5PsEnmmWynpSJXY8QYJ48iiVxkdMwe(xKwf7gcc7fAqgeuEkMNIiGgggEqaYxBgBe1qApSgKbbHc0dvd9ebWtxS5pImeqdddpiGIDdbH9cnidccbavc3SoAQihs0dsOafOabagtLgEqpiM8KQxsKNy3xetYDs1L7iGYnDSruIaik1d58q1)q11TZlVN(CEMZlMg5jGP5ru)Sq7TdIAEuU(5zu(NNe7W51Eb2Pd(Nh0VhrwUs11hTHZJKBNx9FKEVVyAW)8Ayy4jpIA7fyDhrdbruxP6unrPEiNhQ(hQUUDE590NZZCEX0ipbmnpIQmiQ5r56NNr5FEsSdNx7fyNo4FEq)Eez5kv)0NZtaV34Y2iMx7rBzELzkNNNK)5ztEHpNxdddp5TnzKxHxKxzMY5n4ipbS38ZZM8cFoV()XtE)o6IwYUDQopWLNSSjeAk2B((ypjNQt1QENxmn4FEKBEnmm8K32KHCLQraVuSGTzearYJOyZVCVbX08QJ4buQMi55hXR0TRvt0cFVIfe7utAoE7om8aPTqutAoWAfBCrTcHgCFgSAVuSGTzznIoLjN2(YAeDYrxhXdinrXMF5EdIPlP5at1ejV6tgYofmnpsetyEetEs1BEGlpID3TjrCQovtK8QB)EezPBNQjsEGlpYHDWGX5b8YnnpvNE(5beudeNhep)WWJmpv875V5FEfkZR)F8O4kvtK8axEKd7GbJZJObuFZJYqSJdp)om8KNkLT9oVcgID4868EPSGIRunrYdC5v3(9iY5fnvKdTjKxGZdQeUzD0uroKRunrYdC5roSdgmopEyQOY8G9BEqFgckpbmnpIMjdzEyH8iAEuL5PI0CY7BccmLhiNNjZByXTjAfBMW8k8I8E3TY8(MGat5bY5zY8KM4ycgSNqXvQMi5bU8QN)N)5v)LCEQ(GDK5PsqTbehscZJd4sXvQovtK8QtGNHEb)ZRGfWuopi2POJ8kyrBKR8QhiKFdzEdEaNFtDe8251WWWJmp8SvUs1nmm8ixVugIDk6Osy3sqP6gggEKRxkdXofDOqvnbm(NQByy4rUEPme7u0Hcv1AprhEIom8KQjsEat)k9XrE02(5v4jiW)8KrhY8kybmLZdIDk6iVcw0gzE98Z7LYG7fhHnI5zY8(4HxP6gggEKRxkdXofDOqvn50VsFCOLrhYuDdddpY1lLHyNIouOQ2lom8KQByy4rUEPme7u0Hcv1G(MUWJkdcnHkvuv0BEILKP8yHYfpDXM)LkPQO38elbtgASGo8zDzFlyDyImDXtxS5VIP6gggEKRxkdXofDOqvnOVPl3GXP6unrYRobEg6f8ppgmMQmVWC48cFoVggyAEMmVgS22DXMxP6gggEKvTxG1DeneuQUHHHhPcv1KVCt1(981YGAG4unrY7j2d6NhwiV6BtD68WtEqmE)XLhcZZeYt1fJ)5vFBQtNNjZJNUyZ)846NxVZlW5rI8KV(qEyH8CAWBoEo55Z9o8t1nmm8ivOQwG9G(ASGgutDAcTjyky9UQUipHVWq7Z9o8Ri)YnPAIKhrhhgEYZeYdGP8yHY8W08acm1HW8Qtnn8jmVE(5r0mkNxt588EZdtZtj2lVMY5r9MXgX8KmLhluMxp)868CABYtgDKxqTbeh59sXqjH5HP5Pe7Lxt588MptZl858ybbgg5HfYRyJX)TNmimpmnVOPICKxyoCEboVVX5zY8ePChmnpmnpU(5178cCEKl5t1nmm8ivOQ2lom8qOjuv4jiSKmLhluU8ElvQWtqyjdm1rZnn81981cgLxEVLkPIQIEZtSKmLhluU4Pl28NGGAdiowVumC1I22cLlk3WqXsLk8eewfBm(V9KXIYnmkvkAQihRWCyDG1FJDTICjFQUHHHhPcv1G9ERByy4rVnzq40oCLKP8yHscnHQcpbHLKP8yHYL3BQUHHHhPcv1emzOXc6WN1L9TG1HjYucnHkv4HPIkxH5W6aRDAW7kPsLuj6npXsYuESq5INUyZFcGy8(Jlpljt5XcLlk702iDLyfvKaOVTCAWdoOV5sL7P6gggEKkuvlmrMQF7TdHqLWnRJMkYHSIeHMqLk8WurLRWCyDG1on4DLuPsQe9MNyjzkpwOCXtxS5pbqmE)XLNLKP8yHYfLDABKUsSIksa03won4bh03CPIycu1lLbtlc)lsRWezQ(T3oP6gggEKkuvd27TUHHHh92KbHt7WvWFQMi5v39ENx4Z5b8mVgggEYBBYiptiVWNPCEnLZJ48W082SuMhpSJXYuDdddpsfQQb79w3WWWJEBYGWPD4kzqOju1WWaJ18WoglD19unrYRU79oVWNZREW1P8Ayy4jVTjJ8mH8cFMY51uop3ZdtZZbt584HDmwMQByy4rQqvnyV36gggE0BtgeoTdx1yMqtOQHHbgR5HDmw6sL7P6unrYREGHHh5QEW1P8mzE2e885FEcyAEEsoVYw4NNQddddQRN)xx3BUbJZRNFEqpkLNyRmVH5VmVaNxbNh(nmhRoW)uDdddpYvJ5kQjTrul9gnidcIqOs4M1rtf5qwrIqtOsLO38eRY(gDBJO(tBr8OF9gO)INUyZFcGy8(JlpRY(gDBJO(tBr8OF9gO)IYoTnsxDJIeaX49hxEwcMmKASGwWJQCrzN2gPlUNQByy4rUAmRqvTY(gDBJO(tBr8OF9gOFQUHHHh5QXScv14HPIwDWgrnVnWBucnHkv9szW0IW)I0kmrMQF7TdbqFZ1kseWdtfv6QBiFQUHHHh5QXScv1emzi1ybTGhvzQUHHHh5QXScv1OEsFBe1Uv)zDzB(eAcvfEcclQN03grTB1Fwx2M)6JlpP6gggEKRgZkuvt(AZyJOgs7H1GmiicnHkv9szW0IW)I0s(AZyJOgs7H1GmiicurfvG(MlUxQeeJ3FC5zjyYqQXcAbpQYfLDABKUqUksGkqFZLk3uQeeJ3FC5zjyYqQXcAbpQYfLDABKUqSIkwQepmvu5kmhwhyTtdExRCxXuDdddpYvJzfQQb9nDHhvgeAcvqFZ1k3t1nmm8ixnMvOQMGjdnwqh(SUSVfSomrMsOjub9TLtdEWb9nxQCpv3WWWJC1ywHQAHjYu9BVDieQeUzD0uroKvKi0eQG(2YPbp4G(MlvetGkQk6npXY3cne7uGx80fB(xQKQEPmyAr4FrAfMit1V92rXuDdddpYvJzfQQb9nD5gmovtK8Ayy4rUAmRqvnHTsBe1sM(YtObzqqeAcvfEccRcmi9lfdxFC5HqBcMs9EJksP6gggEKRgZkuvRy3qqyVqdYGGieQeUzD0uroKvKi0eQu1lLbtlc)lsRIDdbH9cnidcIavk8eewfyq6xkgU8ElvsLO38elFl0qStbEXtxS5pbVugmTi8ViTctKP63E7qa03Cv1uuXuDQMi5v3y8(JlpYuDdddpYf8xzdyyqSg8E8OdFwx23cwhMitt1nmm8ixWVcv18KS2c2HWPD4QTNmOypPweV)8OF3EoTiNQByy4rUGFfQQ5jzTfSJmv3WWWJCb)kuvRyJXFTGhvzQUHHHh5c(vOQwbtLmfKnIPAIKx9xY5vpuypCEpXukprEMqEkXE51uophtkTrmVoYBZTmYJuE1TVLxp)8kJhIAKhSFZJhMkQmVYw4BtEKF5M8KmepFzQUHHHh5c(vOQwtH9W6atP8eeAcvqFB50GhCqFZLkseWdtfvUcZH1bw70G3LkYVCtQUHHHh5c(vOQ22e9dP2T8(Io8eP6gggEKl4xHQAcgLl2y8pv3WWWJCb)kuvRhildAV1WEVt1nmm8ixWVcv1cSh0xJf0FUdFcnHQOPICScZH1bw)n2L6kv3WWWJCb)kuvtgyQJMBA4R75RfmktOjubX49hxEwYatD0CtdFDpFTGr5f0VPISSI4sLubIX7pU8Semzi1ybTGhv5IYoTnsxRixcG(MlvUtaeJ3FC5zrnPnIAP3Obzqqlk702iDTIKILkfnvKJvyoSoW6VXUwrYnP6gggEKl4xHQAsMYJfkj0eQGy8(JlplQjTrul9gnidcArzN2gPRvexQu0urowH5W6aR)g7AfjIt1PAIKhat5XcL59snm1cLP6gggEKljt5XcLvutAJOw6nAqgeeHqLWnRJMkYHSIeHMqvdddmwZd7yS0v3lv6LYGPfH)fPL81MXgrnK2dRbzqqP6gggEKljt5XcLkuvtWKHuJf0cEuLeAcvQu4jiSk2y8F7jJL3lbVugmTi8ViTOM0grT0B0GmiiflvQWtqyjzkpwOCrzN2gPRKkvsLgggySMh2XyPlKiOHHbgR5HDmw6QBumv3WWWJCjzkpwOuHQAYxBgBe1qApSgKbbrOjuPQxkdMwe(xKwYxBgBe1qApSgKbbrGknmmWynpSJXsxQCVujvAyyGXAEyhJLvetWlLbtlc)lsRIDdbH9cnidcsrft1nmm8ixsMYJfkvOQwXUHGWEHgKbbriujCZ6OPICiRiLQt1nmm8ixYOQSVr32iQ)0wep6xVb6NQByy4rUKHcv1OM0grT0B0GmiicHkHBwhnvKdzfjcnHkOV5sLBs1nmm8ixYqHQAcMmKASGwWJQmv3WWWJCjdfQQrnPnIAP3Obzqqecvc3SoAQihYksP6gggEKlzOqvn5RnJnIAiThwdYGGi0eQu1lLbtlc)lsl5RnJnIAiThwdYGGiOWtqy97bYASGg6BULT8Et1nmm8ixYqHQAupPVnIA3Q)SUSnFcnHQcpbHf1t6BJO2T6pRlBZF9XLhcAyyGXAEyhJLUqkv3WWWJCjdfQQjyYqJf0HpRl7BbRdtKPeAcvqFZ1kIt1nmm8ixYqHQA8WurRoyJOM3g4nkHMqf03CTYDc4HPIkD1nKpv3WWWJCjdfQQvSBiiSxObzqqecvc3SoAQihYkseAcvQ6LYGPfH)fPvXUHGWEHgKbbrGkqmE)XLNf1K2iQLEJgKbbTOStBJ0f3lvc6BUu5UIeOceJ3FC5zjyYqQXcAbpQYfLDABKUOALkb9nxQuTsLub6BvetWlLbtlc)lsRWezQ(T3okQibfEcclzzti0uS389XEsEjJgcYvIt1nmm8ixYqHQAqFtxUbJt1nmm8ixYqHQAqFtx4rLbHMqf03won4bh03CPIebnmmWynpSJXYksLkb9TLtdEWb9nxQiov3WWWJCjdfQQfMit1V92HqOs4M1rtf5qwrIqtOsvVugmTi8ViTctKP63E7qa03won4bh03CPI4unrYRHHHh5sgkuvtyR0grTKPV8eAqgeeHMq1lLbtlc)lsRIDdbH9cnidcIaOV5I7eu4jiSKLnHqtXEZ3h7j5LmAiixjMqBcMs9EJksiG2l8XueaG5u3Oafiea]] )
end