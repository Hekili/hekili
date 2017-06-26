-- Monk.lua
-- October 2016

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local addHook = ns.addHook

local addAbility = ns.addAbility
local modifyAbility = ns.modifyAbility
local addHandler = ns.addHandler

local addAura = ns.addAura
local modifyAura = ns.modifyAura

local addCastExclusion = ns.addCastExclusion
local addGearSet = ns.addGearSet
local addGlyph = ns.addGlyph
local addMetaFunction = ns.addMetaFunction
local addTalent =  ns.addTalent
local addTrait = ns.addTrait
local addResource = ns.addResource
local addStance = ns.addStance

local addSetting = ns.addSetting
local addToggle = ns.addToggle

local registerCustomVariable = ns.registerCustomVariable
local registerInterrupt = ns.registerInterrupt

local removeResource = ns.removeResource

local setArtifact = ns.setArtifact
local setClass = ns.setClass
local setPotion = ns.setPotion
local setRole = ns.setRole
local setRegenModel = ns.setRegenModel
local setTalentLegendary = ns.setTalentLegendary

local RegisterEvent = ns.RegisterEvent

local retireDefaults = ns.retireDefaults
local storeDefault = ns.storeDefault


local PTR = ns.PTR


if select( 2, UnitClass( 'player' ) ) == 'MONK' then

    local function MonkInit()

        Hekili:Print("Initializing Monk Class Module.")

        setClass( 'MONK' )

        addResource( 'energy', SPELL_POWER_ENERGY )
        addResource( 'chi', SPELL_POWER_CHI, true )

        addTalent( 'ascension', 115396 )
        addTalent( 'black_ox_brew', 115399 )
        addTalent( 'blackout_combo', 196736 )
        addTalent( 'celerity', 115173 )
        addTalent( 'chi_burst', 123986 )
        addTalent( 'chi_orbit', 196743 )
        addTalent( 'chi_torpedo', 115008 )
        addTalent( 'chi_wave', 115098 )
        addTalent( 'dampen_harm', 122278 )
        addTalent( 'elusive_dance', 196738 )
        addTalent( 'energizing_elixir', 115288 )
        addTalent( 'eye_of_the_tiger', 196607 )
        addTalent( 'gift_of_the_mists', 196719 )
        addTalent( 'healing_elixir', 122281 )
        addTalent( 'high_tolerance', 196737 )
        addTalent( 'hit_combo', 196740 )
        addTalent( 'invoke_niuzao', 132578 )
        addTalent( 'invoke_xuen', 123904 )
        addTalent( 'leg_sweep', 119381 )
        addTalent( 'light_brewing', 196721 )
        addTalent( 'mystic_vitality', 237076 )
        addTalent( 'power_strikes', 121817 )
        addTalent( 'ring_of_peace', 116844 )
        addTalent( 'rushing_jade_wind', 116847 )
        addTalent( 'serenity', 152173 )
        addTalent( 'special_delivery', 196730 )
        addTalent( 'summon_black_ox_statue', 115315 )
        addTalent( 'whirling_dragon_punch', 152175 )
        addTalent( 'mystic_vitality', 237076 )


        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "crosswinds", 195650 )
        addTrait( "dark_skies", 195265 )
        addTrait( "death_art", 195266 )
        addTrait( "ferocity_of_the_broken_temple", 241136 )
        addTrait( "fists_of_the_wind", 195291 )
        addTrait( "gale_burst", 195399 )
        addTrait( "good_karma", 195295 )
        addTrait( "healing_winds", 195380 )
        addTrait( "inner_peace", 195243 )
        addTrait( "light_on_your_feet", 195244 )
        addTrait( "master_of_combinations", 238095 )
        addTrait( "power_of_a_thousand_cranes", 195269 )
        addTrait( "rising_winds", 195263 )
        addTrait( "spiritual_focus", 195298 )
        addTrait( "split_personality", 238059 )
        addTrait( "strength_of_xuen", 195267 )
        addTrait( "strike_of_the_windlord", 205320 )
        addTrait( "thunderfist", 238131 )
        addTrait( "tiger_claws", 218607 )
        addTrait( "tornado_kicks", 196082 )
        addTrait( "transfer_the_power", 195300 )
        addTrait( "windborne_blows", 214922 )


        addTrait( "brewstache", 214372 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "dark_side_of_the_moon", 227689 )
        addTrait( "dragonfire_brew", 213183 )
        addTrait( "draught_of_darkness", 238057 )
        addTrait( "endurance_of_the_broken_temple", 241131 )
        addTrait( "exploding_keg", 214326 )
        addTrait( "face_palm", 213116 )
        addTrait( "fortification", 213340 )
        addTrait( "full_keg", 214428 )
        addTrait( "gifted_student", 213136 )
        addTrait( "healthy_appetite", 213133 )
        addTrait( "hot_blooded", 227685 )
        addTrait( "obsidian_fists", 213051 )
        addTrait( "obstinate_determination", 216424 )
        addTrait( "overflow", 213180 )
        addTrait( "potent_kick", 213047 )
        addTrait( "quick_sip", 238129 )
        addTrait( "smashed", 213050 )
        addTrait( "staggering_around", 213055 )
        addTrait( "stave_off", 238093 )
        addTrait( "swift_as_a_coursing_river", 213161 )
        addTrait( "wanderers_hardiness", 214920 )


        -- Buffs/Debuffs
        addAura( 'blackout_combo', 228563, 'duration', 15 )
        addAura( 'bok_proc', 116768, 'duration', 15 )
        addAura( 'breath_of_fire', 115181, 'duration', 8 )
        addAura( 'brewstache', 214373, 'duration', 4.5 )
        addAura( 'chi_torpedo', 115008, 'duration', 10, 'max_stack', 2 )
        addAura( 'dampen_harm', 122278, 'duration', 10 )
        addAura( 'diffuse_magic', 122783, 'duration', 6 )
        addAura( 'elusive_brawler', 195630, 'duration', 10, 'max_stack', 10 )
        addAura( 'eye_of_the_tiger', 196608, 'duration', 8 )
        addAura( 'fists_of_fury', 113656, 'duration', 4 )
        addAura( 'fortification', 213341, 'duration', 21 )
        addAura( 'fortifying_brew', 115203, 'duration', 15 )
        addAura( 'gale_burst', 195399, 'duration', 8 )
        addAura( 'healing_winds', 195380, 'duration', 6 )
        addAura( 'hidden_masters_forbidden_touch', 213112, 'duration', 3 )
        addAura( 'hit_combo', 196741, 'max_stack', 6, 'duration', 10 )
        addAura( 'ironskin_brew', 115308, 'duration', 6 )
        addAura( 'keg_smash', 121253, 'duration', 15 )
        addAura( 'leg_sweep', 119381, 'duration', 5 )
        addAura( 'mark_of_the_crane', 228287, 'duration', 15 )
        addAura( 'master_of_combinations', 238095, 'duration', 6 )
        addAura( 'paralysis', 115078, 'duration', 15 )
        addAura( 'power_strikes', 129914 )
        addAura( 'provoke', 115546, 'duration', 8 )
        addAura( 'ring_of_peace', 116844, 'duration', 8 )
        addAura( 'rising_sun_kick', 107428, 'duration', 10 )
        addAura( 'rushing_jade_wind', 116847, 'duration', 6 )
        addAura( 'serenity', 152173, 'duration', 8 )
        addAura( 'special_delivery', 196734, 'duration', 15 )
        addAura( 'storm_earth_and_fire', 137639, 'duration', 15 )
        addAura( 'strike_of_the_windlord', 205320, 'duration', 6 )
        addAura( 'swift_as_a_coursing_river', 213177, 'duration', 15, 'max_stack', 5 )
        addAura( 'the_emperors_capacitor', 235054, 'duration', 30, 'max_stack', 20 )
        addAura( 'the_wind_blows', 248101, 'duration', 3600 )
        addAura( 'thunderfist', 242387, 'duration', 30, 'max_stack', 99 )        
        addAura( 'tigers_lust', 116841, 'duration', 6 )
        addAura( 'touch_of_death', 115080, 'duration', 8 )
        addAura( 'touch_of_karma', 122470, 'duration', 10 )
        addAura( 'touch_of_karma_debuff', 125174, 'duration', 10 )
        addAura( 'transfer_the_power', 195321, 'duration', 30, 'max_stack', 10 )

        addAura( 'light_stagger', 124275, 'duration', 10, 'unit', 'player' )
        addAura( 'moderate_stagger', 124274, 'duration', 10, 'unit', 'player' )
        addAura( 'heavy_stagger', 124273, 'duration', 10, 'unit', 'player' )

        addHook( 'reset_postcast', function( x )
            for k,v in pairs( state.stagger ) do
                state.stagger[k] = nil
            end
            return x
        end )


        -- Fake Buffs.
        -- None at this time.


        -- Gear Sets
        addGearSet( 'tier19', 138325, 138328, 138331, 138334, 138337, 138367 )
        addGearSet( 'tier20', 147154, 147156, 147152, 147151, 147153, 147155 )
        addGearSet( 'class', 139731, 139732, 139733, 139734, 139735, 139736, 139737, 139738 )
        
        addGearSet( 'fists_of_the_heavens', 128940 )
        setArtifact( 'fists_of_the_heavens' )

        addGearSet( 'fu_zan_the_wanderers_companion', 128938 )
        setArtifact( 'fu_zan_the_wanderers_companion' )

        addGearSet( 'cenedril_reflector_of_hatred', 137019 )
        addGearSet( 'cinidaria_the_symbiote', 133976 )
        addGearSet( 'drinking_horn_cover', 137097 )
        addGearSet( 'firestone_walkers', 137027 )
        addGearSet( 'fundamental_observation', 137063 )
        addGearSet( 'gai_plins_soothing_sash', 137079 )
        addGearSet( 'hidden_masters_forbidden_touch', 137057 )
        addGearSet( 'jewel_of_the_lost_abbey', 137044 )
        addGearSet( 'katsuos_eclipse', 137029 )
        addGearSet( 'march_of_the_legion', 137220 )
        addGearSet( 'prydaz_xavarics_magnum_opus', 132444 )
        addGearSet( 'salsalabims_lost_tunic', 137016 )
        addGearSet( 'sephuzs_secret', 132452 )
        addGearSet( 'the_emperors_capacitor', 144239 )

        addGearSet( 'soul_of_the_grandmaster', 151643 )
        addGearSet( 'stormstouts_last_gasp', 151788 )
        addGearSet( 'the_wind_blows', 151811 )

        setTalentLegendary( 'soul_of_the_grandmaster', 'brewmaster', 'mystic_vitality' )
        setTalentLegendary( 'soul_of_the_grandmaster', 'windwalker', 'chi_orbit' )


        addHook( 'specializationChanged', function ()
            setPotion( 'prolonged_power' )
            setRole( state.spec.brewmaster and 'tank' or 'attack' )
        end )


        addHook( 'reset_precast', function ()
            if state.spec.windwalker and state.talent.hit_combo.enabled and state.prev_gcd.tiger_palm and state.chi.current == 0 then
                -- We won't proc Hit Combo from Tiger Palm, but we don't have anything else to hit.
                state.prev.last = 'none'
                state.prev_gcd.last = 'none'
            end
            rawset( state.healing_sphere, 'count', nil )
            state.stagger.amount = nil
            state.spinning_crane_kick.count = nil
            state.healing_sphere.count = nil
        end )


        addHook( 'spend', function( amt, resource )
            if state.equipped.drinking_horn_cover and resource == 'chi' and state.buff.storm_earth_and_fire.up then
                state.buff.storm_earth_and_fire.expires = state.buff.storm_earth_and_fire.expires + 1
            end

            if state.equipped.the_emperors_capacitor and resource == 'chi' then
                state.addStack( 'the_emperors_capacitor', 30, 1 )
            end
        end )


        state.spinning_crane_kick = setmetatable( {}, {
            __index = function( t, k, v )
                if k == 'count' then
                    t[ k ] = max( GetSpellCount( state.action.spinning_crane_kick.id ), state.active_dot.mark_of_the_crane )
                    return t[ k ]
                end
            end } )

        state.healing_sphere = setmetatable( {}, {
            __index = function( t, k, v )
                if k == 'count' then
                    t[ k ] = GetSpellCount( state.action.expel_harm.id )
                    return t[ k ]
                end
            end } )


        local staggered_damage = {}
        local total_staggered = 0

        local myGUID = UnitGUID( 'player' )

        RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, arg1, _, _, _, arg5, _, _, arg8, _, _, arg11 )

            if destGUID == myGUID and subtype == 'SPELL_ABSORBED' then

                local now = GetTime()

                if arg1 == myGUID and arg5 == 115069 then -- This was melee damage that was absorbed.

                    table.insert( staggered_damage, 1, {
                        t = now,
                        d = arg8,
                        s = 6603 -- auto attack
                    } )
                    total_staggered = total_staggered + arg8

                elseif arg8 == 115069 then

                    table.insert( staggered_damage, 1, {
                        t = now,
                        d = arg11,
                        s = arg1
                    } )
                    total_staggered = total_staggered + arg11

                end
            end

        end )

        local function stagger_in_last( t )

            local now = GetTime()

            for i = #staggered_damage, 1, -1 do
                if staggered_damage[i].t + 10 < now then
                    total_staggered = max( 0, total_staggered - staggered_damage[i].d )
                    table.remove( staggered_damage, i )
                else
                    break
                end
            end

            t = min( 10, t )

            if t == 10 then return total_staggered end

            local sum = 0

            for i = 1, #staggered_damage do
                if staggered_damage[i].t > now + t then
                    break
                end
                sum = sum + staggered_damage[i]
            end

            return sum

        end

        local function avg_stagger_ps_in_last( t )

            t = max( 1, min( 10, t ) )

            return stagger_in_last( t ) / t

        end


        state.stagger = setmetatable( {}, {
            __index = function( t, k, v )
                local stagger = state.debuff.heavy_stagger.up and state.debuff.heavy_stagger or nil
                stagger = stagger or ( state.debuff.moderate_stagger.up and state.debuff.moderate_stagger ) or nil
                stagger = stagger or ( state.debuff.light_stagger.up and state.debuff.light_stagger ) or nil

                if not stagger then
                    if k == 'up' then return false
                    elseif k == 'down' then return true
                    else return 0 end
                end

                if k == 'tick' then
                    return state.stagger.amount / state.stagger.ticks_remain

                elseif k == 'ticks_remain' then
                    return math.floor( stagger.remains / 0.5 )

                elseif k == 'amount' then
                    t[k] = UnitStagger( 'player' )
                    return t[k]

                elseif k == 'incoming_per_second' then
                    return avg_stagger_ps_in_last( 10 )

                elseif k == 'time_to_death' then
                    return math.ceil( health.current / stagger.v1 )

                elseif k == 'percent_max_hp' then
                    return ( 100 * state.stagger.amount / state.health.max )

                elseif k == 'percent_remains' then
                    return total_staggered > 0 and ( 100 * state.stagger.amount / stagger_in_last( 10 ) ) or 0

                elseif k == 'total' then
                    return total_staggered

                elseif k == 'dump' then
                    DevTools_Dump( staggered_damage )

                end

                return nil

            end } )


        addToggle( 'strike_of_the_windlord', true, 'Artifact Ability',
            'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'strike_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for your artifact ability will be overridden and your artifact ability will be shown regardless of its toggle above.",
            width = "full"
        } )

        addToggle( 'use_defensives', true, "Brewmaster: Use Defensives",
            "Set a keybinding to toggle your defensive abilities on/off in your priority lists." )

        addSetting( 'elixir_energy', 20, {
            name = "Windwalker: Energizing Elixir Energy Deficit",
            type = "range",
            min = 0,
            max = 100,
            step = 1,
            desc = "Specify the amount of |cFFFF0000missing|r energy that must be missing before Energizing Elixir will be used.  The default is |cFFFFD10020|r.  If set to zero, Energizing Elixir " ..
                "can be used regardless of how much energy you have.",
            width = "full"
        } )


        addSetting( 'purify_light', 60, {
            name = "Brewmaster: Light Stagger Purify Threshold",
            type = "range",
            min = 0,
            max = 100,
            step = 1,
            desc = "Specify the amount of damage, as a percentage of damage Staggered in the previous 10 seconds, that must be Staggered before Purifying Brew can be recommended by the addon.  " ..
                "This setting applies when your current level of Stagger is Light.\n\n" ..
                "If set to 0, Purifying Brew can be recommended regardless of your Stagger damage, based solely on the criteria of your action lists.\r\n\r\n" ..
                "Remember, tanking is complex and you may want to use your defensive abilities proactively to manage mechanics that the addon cannot see.",
            width = "full"
        } )

        addSetting( 'purify_moderate', 60, {
            name = "Brewmaster: Moderate Stagger Purify Threshold",
            type = "range",
            min = 0,
            max = 100,
            step = 1,
            desc = "Specify the amount of damage, as a percentage of damage Staggered in the previous 10 seconds, that must be Staggered before Purifying Brew can be recommended by the addon.  " ..
                "This setting applies when your current level of Stagger is Moderate.\n\n" ..
                "If set to 0, Purifying Brew can be recommended regardless of your Stagger damage, based solely on the criteria of your action lists.\r\n\r\n" ..
                "Remember, tanking is complex and you may want to use your defensive abilities proactively to manage mechanics that the addon cannot see.",
            width = "full"
        } )

        addSetting( 'purify_heavy', 40, {
            name = "Brewmaster: Heavy Stagger Purify Threshold",
            type = "range",
            min = 0,
            max = 100,
            step = 1,
            desc = "Specify the amount of damage, as a percentage of damage Staggered in the previous 10 seconds, that must be Staggered before Purifying Brew can be recommended by the addon.  " ..
                "This setting applies when your current level of Stagger is Heavy.\n\n" ..
                "If set to 0, Purifying Brew can be recommended regardless of your Stagger damage, based solely on the criteria of your action lists.\r\n\r\n" ..
                "Remember, tanking is complex and you may want to use your defensive abilities proactively to manage mechanics that the addon cannot see.",
            width = "full"
        } )

        addSetting( 'purify_extreme', 20, {
            name = "Brewmaster: Extreme Stagger Purify Threshold",
            type = "range",
            min = 0,
            max = 100,
            step = 1,
            desc = "Specify the amount of damage, as a percentage of damage Staggered in the previous 10 seconds, that must be Staggered before Purifying Brew can be recommended by the addon.  " ..
                "This setting applies when your current level of Stagger is Heavy and you have Staggered more than twice your maximum health in the past 10 seconds.\n\n" ..
                "If set to 0, Purifying Brew can be recommended regardless of your Stagger damage, based solely on the criteria of your action lists.\r\n\r\n" ..
                "Remember, tanking is complex and you may want to use your defensive abilities proactively to manage mechanics that the addon cannot see.",
            width = "full"
        } )

        addSetting( 'tp_energy', 65, {
            name = "Brewmaster: Tiger Palm Energy",
            type = "range",
            min = 25,
            max = 100,
            step = 1,
            desc = "Use this setting to specify the minimum Energy required before Tiger Palm is recommended.\r\n\r\n" ..
                "Using this setting, rather than adding an |cFFFFD100energy.current>=X|r condition is recommended, as this will allow the addon's engine to predict how long before Tiger Palm is ready with X energy.\r\n\r\n" ..
                "This setting applies only to Brewmaster Monks.",
            width = "full",
        } )


        -- Using these to abstract the 'Strike of the Windlord' options so the same keybinds/toggles work in Brewmaster spec.
        addMetaFunction( 'toggle', 'artifact_ability', function()
            return state.toggle.strike_of_the_windlord
        end )

        addMetaFunction( 'settings', 'artifact_cooldown', function()
            return state.settings.strike_cooldown
        end )

        addMetaFunction( 'state', 'gcd', function()
            return 1.0
        end )

        addMetaFunction( 'state', 'use_defensives', function()
            if not state.spec.brewmaster then return false end
            return state.toggle.use_defensives
        end )

        addMetaFunction( 'state', 'ee_maximum', function()
            return state.energy.max * ( 100 - state.settings.elixir_energy ) / 100
        end )


        -- Abilities.
        addAbility( 'black_ox_brew', {
            id = 115399,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 90,
            known = function() return spec.brewmaster and talent.black_ox_brew.enabled end,
        } )

        addHandler( 'black_ox_brew', function ()
            gain( energy.max, 'energy' )
            gainCharges( 'ironskin_brew', class.abilities.ironskin_brew.charges )
            gainCharges( 'purifying_brew', class.abilities.purifying_brew.charges )
        end )

        addAbility( 'blackout_kick', {
            id = 100784,
            spend = 1,
            spend_type = 'chi',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
            cycle = 'mark_of_the_crane'
        } )

        modifyAbility( 'blackout_kick', 'spend', function( x )
            if buff.serenity.up then return 0
            elseif buff.bok_proc.up then return 0 end
            return x
        end )

        addHandler( 'blackout_kick', function ()
            if buff.bok_proc.up and buff.serenity.down then
                removeBuff( 'bok_proc' )
            end

            applyDebuff( 'target', 'mark_of_the_crane', 15 )
            
            if talent.dizzying_kicks.enbled then
                applyDebuff( 'target', 'dizzying_kicks', 3 )
            end

            if talent.hit_combo.enabled then
                if prev_gcd.blackout_kick then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
        end )


        addAbility( 'blackout_strike', {
            id = 205523,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'melee',
            cooldown = '3',
            known = function () return spec.brewmaster end
        } )

        modifyAbility( 'blackout_strike', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'blackout_strike', function ()
            if talent.blackout_combo.enabled then
                applyBuff( 'blackout_combo', 15 )
                addStack( 'elusive_brawler', 10, 1 )
            end
        end )


        addAbility( 'breath_of_fire', {
            id = 115181,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'melee',
            cooldown = 15,
            cycle = 'breath_of_fire'
        } )

        modifyAbility( 'breath_of_fire', 'cooldown', function( x )
            if buff.blackout_combo.up then
                return x - 3
            end
            return x
        end )

        addHandler( 'breath_of_fire', function ()
            if debuff.keg_smash.up then applyDebuff( 'target', 'breath_of_fire', 8 ) end
            if equipped.firestone_walkers then setCooldown( 'fortifying_brew', max( 0, cooldown.fortifying_brew.remains - ( min( 6, active_enemies * 2 ) ) ) ) end
            addStack( 'elusive_brawler', 10, active_enemies )
            removeBuff( 'blackout_combo' )
        end )


        addAbility( 'chi_burst', {
            id = 123986,
            spend = 0,
            spend_type = 'energy',
            cast = 1,
            gcdType = 'spell',
            cooldown = 30,
            known = function () return talent.chi_burst.enabled end
        } )

        modifyAbility( 'chi_burst', 'cast', function( x )
            return x * haste
        end )

        addHandler( 'chi_burst', function ()
            if talent.hit_combo.enabled then
                if prev_gcd.chi_burst then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
        end )

        addCastExclusion( 123986 )


        addAbility( 'chi_wave', {
            id = 115098,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'spell',
            cooldown = 15,
            known = function () return talent.chi_wave.enabled end
        } )

        addHandler( 'chi_wave', function ()
            if talent.hit_combo.enabled then
                if prev_gcd.chi_wave then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
        end )

        addCastExclusion( 115098 )


        addAbility( 'crackling_jade_lightning', {
            id = 117952,
            spend = 20,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            channeled = true,
            break_channel = true,
        } )

        addHandler( 'crackling_jade_lightning', function ()
            removeBuff( 'the_emperors_capacitor' )
            if talent.hit_combo.enabled then
                if prev_gcd.crackling_jade_lightning then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
        end )


        addAbility( 'dampen_harm', {
            id = 122278,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            known = function () return talent.dampen_harm.enabled end
        } )

        addHandler( 'dampen_harm', function ()
            applyBuff( 'dampen_harm', 10 )
        end )

        
        addAbility( 'diffuse_magic', {
            id = 122783,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 90,
            known = function () return spec.windwalker or talent.diffuse_magic.enabled end,
        } )

        addHandler( 'diffuse_magic', function ()
            applyBuff( 'diffuse_magic', 6 )
        end )


        addAbility( 'effuse', {
            id = 116694,
            spend = 30,
            spend_type = 'energy',
            cast = 1.5,
            gcdType = 'spell',
            cooldown = 0,
            velocity = 60
        } )


        addAbility( 'energizing_elixir', {
            id = 115288,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 60,
            known = function () return talent.energizing_elixir.enabled end,
            usable = function () return energy.current < ee_maximum end,
        } )

        addHandler( 'energizing_elixir', function ()
            gain( energy.max, 'energy' )
            gain( chi.max, 'chi' )
        end )

        addCastExclusion( 'energizing_elixir' )


        addAbility( 'expel_harm', {
            id = 115072,
            spend = 15,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            usable = function () return healing_sphere.count > 0 end
        } )

        addHandler( 'expel_harm', function ()
            if spec.brewmaster and set_bonus.tier20_4pc == 1 then stagger.amount = stagger.amount * ( 1 - ( 0.05 * healing_sphere.count ) ) end
            healing_sphere.count = 0
        end )


        addAbility( 'exploding_keg', {
            id = 214326,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'spell',
            cooldown = 75,
            known = function () return equipped.fu_zan_the_wanderers_companion and ( toggle.artifact_ability or ( toggle.cooldowns and settings.artifact_cooldown ) ) end,
        } )


        addAbility( 'fists_of_fury', {
            id = 113656,
            spend = 3,
            spend_type = 'chi',
            cast = 4,
            channeled = true,
            gcdType = 'spell',
            cooldown = 24,
        } )

        modifyAbility( 'fists_of_fury', 'cast', function( x )
            return x * haste
        end )

        modifyAbility( 'fists_of_fury', 'spend', function( x )
            if buff.serenity.up then return 0
            elseif equipped.katsuos_eclipse then return max( 0, x - 1 ) end
            return x
        end )

        modifyAbility( 'fists_of_fury', 'cooldown', function( x )
            if buff.serenity.up then
                x = max( 0, x - ( buff.serenity.remains / 2 ) )
            end
            return x * haste
        end )

        -- By having the ability's handler set the global cooldown to 4 seconds (reduced by haste),
        -- the addon's next prediction will wait until the global cooldown ends.
        -- We should watch this for unintended consequences.
        addHandler( 'fists_of_fury', function ()
            -- applyBuff( 'fists_of_fury', 4 * haste ) -- now set as channeled, watch this.
            if talent.hit_combo.enabled then
                if prev_gcd.fists_of_fury then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
            -- NYI: T20 buff after Fists of Fury to increase RSK crit.
        end )


        addAbility( 'fortifying_brew', {
            id = 115203,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 420,
        } )

        addHandler( 'fortifying_brew', function ()
            applyBuff( 'fortifying_brew', 15 )
            if artifact.fortification.enabled then applyBuff( 'fortification', 21 ) end
            if artifact.swift_as_a_coursing_river.enabled then addStack( 'swift_as_a_coursing_river', 15, 1 ) end
            health.max = health.max * 1.2
            health.actual = health.actual * 1.2
        end )


        addAbility( 'healing_elixir', {
            id = 122281,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 30,
            charges = 2,
            recharge = 30,
            talent = 'healing_elixir'
        } )

        addHandler( 'healing_elixir', function ()
            gain( 0.15 * health.max, 'health' )
        end )


        addAbility( 'ironskin_brew', {
            id = 115308,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 21,
            charges = 3,
            recharge = 21,
        } )

        modifyAbility( 'ironskin_brew', 'cooldown', function( x )
            return x * haste
        end )

        modifyAbility( 'ironskin_brew', 'recharge', function( x )
            return x * haste
        end )

        modifyAbility( 'ironskin_brew', 'charges', function( x )
            return x + ( talent.light_brewing.enabled and 1 or 0 )
        end )

        addHandler( 'ironskin_brew', function ()
            applyBuff( 'ironskin_brew', buff.ironskin_brew.remains + 6 + ( artifact.potent_kick.rank * 0.5 ) )
            spendCharges( 'purifying_brew', 1 )
            
            if set_bonus.tier20_2pc == 1 then healing_sphere.count = healing_sphere.count + 1 end

            if artifact.quick_sip.enabled then
                stagger.amount = stagger.amount * 0.95
                stagger.tick = stagger.tick * 0.95
            end
            if artifact.brewstache.enabled then applyBuff( 'brewstache', 4.5 ) end
            if artifact.swift_as_a_coursing_river.enabled then addStack( 'swift_as_a_coursing_river', 15, 1 ) end
            removeBuff( 'blackout_combo' )
        end )


        addAbility( 'invoke_xuen', {
            id = 123904,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'spell',
            cooldown = 180,
            known = function() return talent.invoke_xuen.enabled end,
            toggle = 'cooldowns'
        } )

        addHandler( 'invoke_xuen', function ()
            summonPet( 'xuen', 45 )
        end )


        addAbility( 'keg_smash', {
            id = 121253,
            spend = 40,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'melee',
            cooldown = 8,
            charges = 1,
            recharge = 8,
            cycle = 'keg_smash',
            velocity = 30
        } )

        modifyAbility( 'keg_smash', 'cooldown', function( x )
            return x * haste
        end )

        modifyAbility( 'keg_smash', 'charges', function( x )
            if equipped.stormstouts_last_gasp then
                return x + 1
            end
            return x
        end )

        addHandler( 'keg_smash', function ()
            applyDebuff( 'target', 'keg_smash', 15 )
            active_dot.keg_smash = min( active_enemies, active_dot.keg_smash + 7 )
            gainChargeTime( 'ironskin_brew', 4 + ( buff.blackout_combo.up and 2 or 0 ) )
            gainChargeTime( 'purifying_brew', 4 + ( buff.blackout_combo.up and 2 or 0 ) )
            cooldown.fortifying_brew.expires = max( state.time, cooldown.fortifying_brew.expires - 4 + ( buff.blackout_combo.up and 2 or 0 ) )
            if equipped.salsalabims_lost_tunic then setCooldown( 'breath_of_fire', 0 ) end
            removeBuff( 'blackout_combo' )
        end )


        addAbility( 'leg_sweep', {
            id = 119381,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'melee',
            cooldown = 45,
            known = function () return talent.leg_sweep.enabled end,
        } )

        addHandler( 'leg_sweep', function ()
            applyDebuff( 'target', 'leg_sweep', 5 )
            active_dot.leg_sweep = min( active_enemies )
            interrupt()
        end )


        addAbility( 'paralysis', {
            id = 115078,
            spend = 20,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'spell',
            cooldown = 15,
        } )

        addHandler( 'paralysis', function ()
            applyDebuff( 'target', 'paralysis', 60 )
        end )


        addAbility( 'provoke', {
            id = 115546,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 8,
        } )

        addHandler( 'provoke', function ()
            applyDebuff( 'target', 'provoke', 8 )
        end )


        addAbility( 'purifying_brew', {
            id = 119582,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 21,
            charges = 3,
            recharge = 21,
            usable = function ()
                if stagger.percent_max_hp > 30 and stagger.percent_max_hp <= 60 and stagger.percent_remains > settings.purify_light then return true -- Light
                elseif stagger.percent_max_hp > 60 and stagger.percent_max_hp <= 100 and stagger.percent_remains > settings.purify_moderate then return true -- Moderate
                elseif stagger.percent_max_hp > 100 and stagger.percent_max_hp <= 200 and stagger.percent_remains > settings.purify_heavy then return true -- Heavy
                elseif stagger.percent_max_hp > 200 and stagger.percent_remains > settings.purify_extreme then return true end -- Extreme
                return false
            end
        } )

        modifyAbility( 'purifying_brew', 'cooldown', function( x )
            return x * haste
        end )

        modifyAbility( 'purifying_brew', 'recharge', function( x )
            return x * haste
        end )

        modifyAbility( 'purifying_brew', 'charges', function( x )
            return x + ( talent.light_brewing.enabled and 1 or 0 )
        end )

        addHandler( 'purifying_brew', function ()
            spendCharges( 'ironskin_brew', 1 )
            if set_bonus.tier20_2pc == 1 then healing_sphere.count = healing_sphere.count + 1 end

            if buff.blackout_combo.up then
                addStack( 'elusive_brawler', 10, 1 )
                removeBuff( 'blackout_combo' )
            end
            if artifact.brewstache.enabled then applyBuff( 'brewstache', 4.5 ) end
            if artifact.swift_as_a_coursing_river.enabled then addStack( 'swift_as_a_coursing_river', 15, 1 ) end
            if artifact.quick_sip.enabled then
                applyBuff( 'ironskin_brew', buff.ironskin_brew.remains + 1 )
            end

            local reduction = 0.4
            reduction = reduction + ( artifact.staggering_around.rank / 100 )
            reduction = reduction * ( talent.elusive_dance.enabled and 1.2 or 1 )

            stagger.amount = stagger.amount * ( 1 - reduction )
            stagger.tick = stagger.tick * ( 1 - reduction )
            if equipped.gai_plins_soothing_sash then gain( stagger.amount * 0.25, 'health' ) end -- LegionFix: Purify doesn't always purify 50% stagger, resolve this later.
        end )


        addAbility( 'ring_of_peace', {
            id = 116844,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'spell',
            cooldown = 45,
            known = function () return talent.ring_of_peace.enabled end,
        } )


        addAbility( 'rising_sun_kick', {
            id = 107428,
            spend = 2,
            spend_type = 'chi',
            cast = 0,
            gcdType = 'melee',
            cooldown = 10,
            cycle = 'mark_of_the_crane'
        } )

        modifyAbility( 'rising_sun_kick', 'cooldown', function( x )
            if buff.serenity.up then
                x = max( 0, x - ( buff.serenity.remains / 2 ) )
            end
            return x * haste
        end )

        modifyAbility( 'rising_sun_kick', 'spend', function( x )
            if buff.serenity.up then return 0 end
            return x
        end )

        addHandler( 'rising_sun_kick', function ()
            applyDebuff( 'target', 'mark_of_the_crane', 15 )

            if talent.hit_combo.enabled then
                if prev_gcd.rising_sun_kick then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
        end )


        addAbility( 'roll', {
            id = 109132,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'melee',
            cooldown = 20,
            charges = 2,
            recharge = 20,
            known = function () return not talent.chi_torpedo.enabled end
        } )

        modifyAbility( 'roll', 'charges', function( x )
            return x + ( talent.celerity.enabled and 1 or 0 )
        end )

        modifyAbility( 'roll', 'cooldown', function( x )
            return x - ( talent.celerity.enabled and 5 or 0 )
        end )

        modifyAbility( 'roll', 'recharge', function( x )
            return x - ( talent.celerity.enabled and 5 or 0 )
        end )


        addAbility( 'rushing_jade_wind', {
            id = 116847,
            spend = 1,
            spend_type = 'chi',
            cast = 0,
            gcdType = 'spell',
            cooldown = 6,
            talent = 'rushing_jade_wind',
            cycle = 'mark_of_the_crane'
        } )

        modifyAbility( 'rushing_jade_wind', 'cooldown', function( x )
            if buff.serenity.up then
                x = max( 0, x - ( buff.serenity.remains / 2 ) )
            end
            return x * haste
        end )

        modifyAbility( 'rushing_jade_wind', 'spend', function( x )
            if buff.serenity.up or spec.brewmaster then return 0 end
            return x
        end )

        addHandler( 'rushing_jade_wind', function ()
            if spec.brewmaster then
                applyBuff( 'rushing_jade_wind', 6 * 1.5 * haste )
            elseif spec.windwalker then
                applyBuff( 'rushing_jade_wind', 6 * haste )
                active_dot.mark_of_the_crane = min( active_enemies, active_dot.mark_of_the_crane + 2 )
                applyDebuff( 'target', 'mark_of_the_crane', 15 )
            end

            if talent.hit_combo.enabled then
                if prev_gcd.rushing_jade_wind then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
        end )


        addAbility( 'serenity', {
            id = 152173,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 90,
            known = function () return talent.serenity.enabled end,
            toggle = 'cooldowns'
        } )

        local sp_cdr = { 5, 10, 15, 20, 24, 28, 31, 34 }

        modifyAbility( 'serenity', 'cooldown', function( x )
            if artifact.split_personality.enabled then
                return x - sp_cdr[ artifact.split_personality.rank ]
            end

            return x
        end )

        addHandler( 'serenity', function ()
            applyBuff( 'serenity', 8 )
            setCooldown( 'strike_of_the_windlord', cooldown.strike_of_the_windlord.remains - ( max( 8, cooldown.strike_of_the_windlord.remains / 2 ) ) )
            setCooldown( 'fists_of_fury', cooldown.fists_of_fury.remains - ( max( 8, cooldown.fists_of_fury.remains / 2 ) ) )
            setCooldown( 'rising_sun_kick', cooldown.rising_sun_kick.remains - ( max( 8, cooldown.rising_sun_kick.remains / 2 ) ) )
            setCooldown( 'rushing_jade_wind', cooldown.rushing_jade_wind.remains - ( max( 8, cooldown.rushing_jade_wind.remains / 2 ) ) )            
        end )

        addCastExclusion( 'serenity' )


        addAbility( 'spear_hand_strike', {
            id = 116705,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 15,
            usable = function () return target.casting end,
            toggle = 'interrupts'
        } )

        addHandler( 'spear_hand_strike', function ()
            interrupt()
        end )

        registerInterrupt( 'spear_hand_strike' )


        addAbility( 'spinning_crane_kick', {
            id = 101546,
            spend = 3,
            spend_type = 'chi',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
        } )

        modifyAbility( 'spinning_crane_kick', 'spend', function( x )
            if buff.serenity.up then return 0 end
            return x
        end )

        addHandler( 'spinning_crane_kick', function ()
            if talent.hit_combo.enabled then
                if prev_gcd.spinning_crane_kick then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
        end )


        addAbility( 'storm_earth_and_fire', {
            id = 137639,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 90,
            charges = 2,
            recharge = 90,
            known = function () return not talent.serenity.enabled end,
            usable = function () return not buff.storm_earth_and_fire.up end,
            toggle = 'cooldowns'
        } )

        modifyAbility( 'storm_earth_and_fire', 'cooldown', function( x )
            if artifact.split_personality.enabled then
                return x - sp_cdr[ artifact.split_personality.rank ]
            end

            return x
        end )

        modifyAbility( 'storm_earth_and_fire', 'recharge', function( x )
            if artifact.split_personality.enabled then
                return x - sp_cdr[ artifact.split_personality.rank ]
            end

            return x
        end )

        addHandler( 'storm_earth_and_fire', function ()
            applyBuff( 'storm_earth_and_fire', 15 )
        end )

        addCastExclusion( 'storm_earth_and_fire' )


        addAbility( 'strike_of_the_windlord', {
            id = 205320,
            spend = 2,
            spend_type = 'chi',
            cast = 0,
            gcdType = 'melee',
            cooldown = 40,
            known = function () return equipped.fists_of_the_heavens and ( toggle.strike_of_the_windlord or ( toggle.cooldowns and settings.strike_cooldown ) ) end,
        } )

        modifyAbility( 'strike_of_the_windlord', 'cooldown', function( x )
            x = equipped.the_wind_blows and ( x * 0.8 ) or x
            x = buff.serenity.up and max( 0, x - ( buff.serenity.remains / 2 ) ) or x
            return x
        end )

        modifyAbility( 'strike_of_the_windlord', 'spend', function( x )
            if buff.serenity.up then return 0 end
            return x
        end )

        addHandler( 'strike_of_the_windlord', function ()
            applyDebuff( 'target', 'strike_of_the_windlord', 6 )
            active_dot.strike_of_the_windlord = active_enemies
            if artifact.thunderfist.enabled then
                applyBuff( 'thunderfist', 30, active_enemies )
            end
            if equipped.the_wind_blows then
                applyBuff( 'the_wind_blows', 3600 )
            end
            if talent.hit_combo.enabled then
                if prev_gcd.strike_of_the_windlord then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
        end )


        addAbility( 'summon_black_ox_statue', {
            id = 115315,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'spell',
            cooldown = 10,
            known = function () return talent.summon_black_ox_statue.enabled end,
        } )

        addHandler( 'summon_black_ox_statue', function ()
            summonTotem( 'black_ox_statue', 'statue', 900 )
        end )


        addAbility( 'tiger_palm', {
            id = 100780,
            spend = 50,
            spend_type = 'energy',
            ready = 50,
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
            cycle = 'mark_of_the_crane'
        } )

        modifyAbility( 'tiger_palm', 'ready', function( x )
            if spec.brewmaster then return settings.tp_energy end
            return 50
        end )

        modifyAbility( 'tiger_palm', 'spend', function( x )
            if spec.brewmaster then return 25 end
            return x
        end )

        addHandler( 'tiger_palm', function ()
            if talent.eye_of_the_tiger.enabled then
                applyDebuff( 'target', 'eye_of_the_tiger', 8 )
                applyBuff( 'eye_of_the_tiger', 8 )
            end

            if spec.windwalker then
                applyDebuff( 'target', 'mark_of_the_crane', 15 )

                if talent.hit_combo.enabled then
                    if prev_gcd.tiger_palm then removeBuff( 'hit_combo' )
                    else addStack( 'hit_combo', 10, 1 ) end
                end

                gain( buff.power_strikes.up and 3 or 2, 'chi' )
            end

            if spec.brewmaster then
                gainChargeTime( 'ironskin_brew', 1 )
                gainChargeTime( 'purifying_brew', 1 )
                cooldown.fortifying_brew.expires = max( state.time, cooldown.fortifying_brew.expires - 1 )
                removeBuff( 'blackout_combo' )
            end

        end )


        addAbility( 'tigers_lust', {
            id = 116841,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'spell',
            cooldown = 30,
            talent = 'tigers_lust'
        } )

        addHandler( 'tigers_lust', function ()
            applyBuff( 'tigers_lust', 6 )
        end )


        addAbility( 'touch_of_death', {
            id = 115080,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'spell',
            cooldown = 120,
            toggle = 'cooldowns',
            cycle = 'touch_of_death'
        } )

        modifyAbility( 'touch_of_death', 'cooldown', function( x )
            if equipped.hidden_masters_forbidden_touch and cooldown.touch_of_death.remains == 0 and buff.hidden_masters_forbidden_touch.down then
                return 0
            end
            return x
        end )

        addHandler( 'touch_of_death', function ()
            if equipped.hidden_masters_forbidden_touch and buff.hidden_masters_forbidden_touch.down then
                applyBuff( 'hidden_masters_forbidden_touch', 5 )
            end
            applyDebuff( 'target', 'touch_of_death', 8 )
        end )


        addAbility( 'touch_of_karma', {
            id = 122470,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 90,
        } )

        addHandler( 'touch_of_karma', function ()
            applyBuff( 'touch_of_karma', 10 )
            applyDebuff( 'target', 'touch_of_karma', 10 )
        end )


        addAbility( 'whirling_dragon_punch', {
            id = 152175,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'melee',
            cooldown = 24,
            known = function () return talent.whirling_dragon_punch.enabled end,
            usable = function () return cooldown.fists_of_fury.remains > 0 and cooldown.rising_sun_kick.remains > 0 end
        } )

        addHandler( 'whirling_dragon_punch', function ()
            if talent.hit_combo.enabled then
                if prev_gcd.whirling_dragon_punch then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
        end )


        addAbility( 'zen_meditation', {
            id = 115176,
            spend = 0,
            spend_type = 'energy',
            cast = 8,
            gcdType = 'spell',
            channeled = true,
            cooldown = 300
        } )


        addAbility( 'effuse', {
            id = 116694,
            spend = 30,
            spend_type = 'energy',
            cast = 1.5,
            gcdType = 'spell',
            cooldown = 0,
        } )

        modifyAbility( 'effuse', 'cast', function( x )
            return x * haste
        end )

        addCastExclusion( 'effuse' )

    end


    storeDefault( [[Brewmaster: Default]], 'actionLists', 20170402.130810, [[d0ZngaGEis1Mir2fPABcv7Je0VbnBOMpKO1jeESGBd48qs7Ku2RQDlz)a1pjbgMcgheLoTsdfIugmegoboOcDkiI6yuQZbrOfsqlfiwSuTCIEiKWtrTmkPNtXeHOAQKutwrtx0fPeFtk6YixxO8APWZesBMeA7KO(mK6VeAAqempisAKcr57KKrlez8qe5KaPdt11eIQ7jLSiPuhcIIrbrIV9vF2s5DmnVWZSakSoEr6EUW6AwJJSN1Ca6SqjPcWnjjJamcKtk6XW5zqim5g6AwhSBoe1ksu3(mhKRG885XqUWYC1xZ(QpBP8oMMx4zoixb55eIgnM03kjPmMG0CESV4nr9Sra5sXi51u0KYTbDg0AUbpHYZfSOZGqyYn01Soyh3UP(q0ZAoaDMfqUemIiZRjyeCk3g0ZRz9QpBP8oMMx4zoixb55eIgnM0dqiEcvvgLqkOeL9ykQOEhdHtCmtQhtakrz6s0uQNlajMqX5si1wXhqYNhLOnNlhGAbXtrvU88yFXBI6zbWCH1zqR5g8ekpxWIodcHj3qxZ6GDC7M6drpR5a0zKgmxy98ArV6ZwkVJP57N5GCfKNtVASfALcqiEcvv6RewMgBj2LKk9qKCjAY0kaH4juvPVsyzASLyxsQ0drYLOjJiGJKuARaeyl0IthWrtIrnkC48yFXBI65vcltJTe7ss1zqR5g8ekpxWIodcHj3qxZ6GDC7M6drpR5a0zqLWY0ylWiekjvpVgs4QpBP8oMMVFMdYvqEoMHeNKIuzwLjZ5rjAZ5YbOwTfkjvaUjjzeGrGCsrQmRYKP95X(I3e1ZbhJf9qUWseVM8mO1CdEcLNlyrNbHWKBORzDWoUDt9HON1Ca6mYjfPYSktMNxlYV6ZwkVJP5fEMdYvqEgzshtvQ3XEObmwkgGaDOovEhttL8qUktIuralzuO95rjAZ5YbOwTfkjvaUjjzeGrWPxtxobJyubwAFESV4nr9CWXyrpKlSeXRjpdAn3GNq55cw0zqim5g6AwhSJB3uFi6znhGoZPxtxobJyubwEET4x9zlL3X08cpZb5kipNoMQuVJ9qdySumab6qDQ8oMMk5HCvMePIawYOq7ZJs0MZLdqTAlusQaCtsYiaJafqGoemIrfyP95X(I3e1ZbhJf9qUWseVM8mO1CdEcLNlyrNbHWKBORzDWoUDt9HON1Ca6mkGaDiyeJkWYZR18QpBP8oMMx4zoixb5zKjDmvPEh7HgWyPyac0H6u5DmnvYd5QmjsfbSKPL95rjAZ5YbOwTfkjvaUjjzeGrWPxtxobJGv3(8yFXBI65GJXIEixyjIxtEg0AUbpHYZfSOZGqyYn01Soyh3UP(q0ZAoaDMtVMUCcgbR(51q2R(SLY7yAEHN5GCfKNthtvQ3XEObmwkgGaDOovEhttL8qUktIuralzAzFEuI2CUCaQvBHssfGBssgbyeOac0HGrWQBFgectUHUM1b742n1hIEg0AUbpHYZfSOZAoaDgfqGoemcw95X(I3e1ZbhJf9qUWseVM85ZZiNu0JHZl85pa]] )

    storeDefault( [[Brewmaster: Defensives]], 'actionLists', 20170402.130810, [[dStveaGEbK2esLSlL8AcX(eiMnLEochwXTLsltOStPyVGDRY(PWOqQyyqPXrQeNNGHkazWu0WvLdsQ4ucvDmLQZja1crklLqTyOA5IEiPs6Pu9yIwNaIjkqAQKQMSQA6KCrOWPL8mLsxxiBJq6NKkvBwqBxa0QeQ8zKmnsLY3LQrka8xenAsz8kfNePQBjG6AivQ7jq9nOOlJ63qg2b9GJXn4w(d0aVzAzWPLCVDiuCgigMbLd5JOcqMaCxM1tbo4bLdNiRcObUy2YdbdnXWUJj2TXc41o4I55lOVAzWPJHPeHSFu)wVOScfQJIep5(sQnjftq2oBmmdSHPeHSFu)wVOScfQJIep5(sQnjftqgMJuvOBSgMXBygNHPeHSFu)wVOScfQJIep5(kzP2Kum46ivf6ia9qZoOhCmUb3YFGg4ntldon7ifXWu33yysl5o4Izlpem0ed7UO7yUWUfC6VFjhfkb)qhdUlZ6PaxIq2pQFRxuwHc1rrINCFj1MKIjcgl46Gx2sjaoUDKIqI2qINChuqtmqp4yCdUL)anWfZwEiyOjg2Dr3XCHDl4UmRNcCW115Pk0bo4Dn(eZZxa8jsHaN(7xYrHsWp0XGRdEzlLa4VOScfQJIep5o4ntldEafLvOqDugM0sUdkOzlOhCmUb3YFGg4UmRNcCjcz)O(TErzfkuhfjEY9LuBskMiyjcz)O(TErzfkuhfjEY9LuBskMGSD2aUo4LTucGxj6iePos8K7Gt)9l5Oqj4h6yWDzwpLEHhdUQAzWBMwgC6t0risDgM0sUdUy2YdbdnXWUl6oMlSBbxmpFb9vldoDmmLiK9J636fLvOqDuK4j3xsTjPycY2zJHzGnmLiK9J636fLvOqDuK4j3xsTjPycYWCKQcDJ1WmEdZ4mmLiK9J636fLvOqDuK4j3xjl1MKIbVRXNyE(cGtiZ6Paf0OBGEWX4gCl)bAG3mTm4yS5XwdZayYwW7A8jMNVa4tKcbUy2YdbdnXWUl6oMlSBbN(7xYrHsWp0XG7YSEkW14XwhfjXtJtEjrrNkibVtx0rJhRsB95WswQGemHAuRrPgPiKpuNZ4WCr3XPXJToksINgN8sIIov8GRdEzlLa48MhBj1MSfuGcC)XYASvGoQcDqtmr1fqba]] )

    storeDefault( [[Brewmaster: Combo ST]], 'actionLists', 20170402.130810, [[dSZSdaGAcIwpQe9scs7sGxRO2hQeMnjpwOBdvhw0oHyVu7gL9dsJcvkggPACOsYLrgkbudgedxHoOG6ueiDmu15iqSqfzPqXIb1Yj6HOsQNQAzOI1rGYejimvjzYaMUuxuqwfQu1ZifxhiBKaYPvAZskFJu67eu(kQuAAeOAEeGEoK(RcgnHSjuPYjLu9zO01iO68a1kja2gH63sS5DLFiwcRiap5JK4K)KKegEI2KuWGcHRl4WfOqEL)hP4MQLlZElmJWrmx5leuTeKQ9Kpgsrjkzeo68A11Wrqc49Xqja4QfN89dh7TWqDLr4DLFiwcRiap5JK4K)KkJZfqnuiVL7mbfc3i0lO(pk3X2VtfX6ayvgNlG6HybhUeqSewraCxg7TWcMjSdO4jQOajLaGh6fNeqSraUNpq4(yOeaC1It((HHx12G9HvzCUaQhqB5ot(1zaBm7I0NvyKpgsrjkzeo68I51gORX)r5o2vGhjF0fp62iCCLFiwcRiap5JK4KVqjSqHC8evKpgsrjkzeo68I51gORXVodyJzxK(ScJ8ddVQTb7ptyhqXtur(pk3X23Tr04k)qSewraEYhjXj)jvgNlGAOqEl3zYhdPOeLmchDEX8Ad014xNbSXSlsFwHr(HHx12G9HvzCUaQhqB5ot(pk3X23TreCx5hILWkcWt(pk3X23hdPOeLmchDEX8Ad014xNbSXSlsFwHr(ijo5JbeQOLHfkebibiOq42Lb4hgEvBd2xccv0YWoiKjaniSLb42ic3v(HyjSIa8K)JYDS9biyq1QfmtyhqXturbGg9XqkkrjJWrNxmV2aDn(1zaBm7I0NvyKpsIt(tskBrqHuQbfIaTsYpm8Q2gSpSKYw0qP2qTvsUnIyx5hILWkcWt(ijo5xTyjjuicCQW9XqkkrjJWrNxmV2aDn(1zaBm7I0NvyKFy4vTny)EXsYHXuH7)OChBFIrsSGdIGKsI1CHUB3(pk3X23Tn]] )

    storeDefault( [[Brewmaster: Combo AOE]], 'actionLists', 20170402.130810, [[dGdPdaGAIqTEccVKiQDPqBdH2NqjZMKVHi7uu7LA3qTFf1pjizye63ImucIgSImCHCqK4YOogsDocQSqbTucSyiTCs9qHcpv1YaYZHyIeu1ubQjdy6kDre8yqEgI66GYgjO0HLAZcvFwbNwYxjcmnck(Uqr3MO(lOA0iPXte5Kc0RfW1ic68ePvkuQXrqQ1reYM2G9jGBufd4q)dPRO13x454nm16qFbSIBe2zqI0Kejds4gP9FedvTQeIERe2zqefAFkqBLWigSZ0gSpbCJQyah6NBz2NGKIujGcpmpjzEWxaR4gHDgKinrAsJIK9dIbkOEtAFCcZ(uqlvTs9zjfPsafEaEaEW)q6kA996mid2NaUrvmGd9ZTm7lzEyE6YncvFbSIBe2zqI0ePjnks2pigOG6nP9Xjm7tbTu1k1papahrUrO6FiDfT(EDMSb7ta3OkgWH(5wM9Jb1AEkeMgz9fWkUryNbjstKM0Oiz)GyGcQ3K2hNWSpf0svRuFiQfCuyAK1)q6kA996SWyW(eWnQIbCOFULz)qn3l15Pu85jHT0SVawXnc7mirAI0Kgfj7heduq9M0(4eM9PGwQAL6JQ5EPcpfhE8sZ(hsxrRpaJclE8Xa8aCe5gH6iSiVolHgSpbCJQyah6FiDfT((cyf3iSZGePjstAuKSFqmqb1Bs7Jty2p3YSVayiul8W8uSBaEEsckmGpf0svRuFnmeQfEaUe3am8ywyaVot0G9jGBufd4q)dPRO1NXSEq6iemTMXBSe9fWkUryNbjstKM0Oiz)GyGcQ3K2hNWSFULzFW1aRNNeYwj7tbTu1k1FRbwdpQvYEDMKb7ta3OkgWH(hsxrRVVawXnc7mirAI0Kgfj7heduq9M0(4eM9ZTm7hQAOajy780xDfG9PGwQAL6JQAOajylCKvxbyVE9ZTm7hQ5yk3ilRLO5PyKKrtZtuekcETb]] )

    storeDefault( [[Brewmaster: Standard ST]], 'actionLists', 20170402.130810, [[d0Z7eaGAru16jvIxQi0UeQTrK2NkrnBsMVIGFlQhRIVru9CiTtLAVu7gQ9dHrjIkdtGXPsKNHunuvcgSk1WjLdsQ6uIi1XqY5uj0cvslLOSyeTCcpurupfSmeADKkvtuejtfIMSctxvxKioTuxg11vInkIOBlOnJu2oPI(UkPVQiY0ivkZteL(Ri9AfPrROgpPcNue(SqUMicNhbRKujDyjBsefBkJ0GeCrQ4HxnaA8PlvRl13zS3eLEjdjftRwuVxniJvCHYEtmGsEaDIxmMYaCeT2BWG(Z3zmQr6nLrAqcUiv8WRg2viByICeIBiSqNniJvCHYEtmGskL84a6gsGh9P(SWaoJzdWr0AVbd6jBv)emmLJsrdl0z)Et0inibxKkE4vdWr0AVHbtUqJw8uokfnSqNJx0MWegm5cnAXOA8Plv6GvTozbH4fndYyfxOS3edOKsjpoGUHe4rFQplmGZy2GEYw1pbdKcU(50mTuATGnSRq2WQGRFgXDMgI7KSfSFVPBKgKGlsfp8Qb4iAT3GbzSIlu2BIbusPKhhq3qc8Op1NfgWzmBqpzR6NGbsvDMMx(u0x0tzd7kKnSQQZ08YJ4gErpL97TUzKgKGlsfp8Qb4iAT3WjNvJ8vCS2IOPrOXrPKc(A8zUermAYEYz1iFfhRTiAAeACukPGVgFMlreJMgw6WGEYw1pbdFhXIuTsfAibE0N6Zcd4mMnSRq2aYoIfiUVqPcniJvCHYEtmGskL84a6(9ojmsdsWfPIhE1aCeT2B4l80ghLmOFffXI4kmVG)lRTiAAes)zbJoNvdd6jBv)emW6qtLhnokDkhzibE0N6Zcd4mMnSRq2GeDOPYJghH4EICKbzSIlu2BIbusPKhhq3V3snsdsWfPIhE1aCeT2BWGmwXfk7nXakPuYJdOBibE0N6Zcd4mMnONSv9tWGybDUXrPjFn40RnEyyxHSbzlOZnocXTUwdgX9KA8WV3YnsdsWfPIhE1aCeT2BWGEYw1pbdN5oLCrG(gsGh9P(SWaoJzd7kKnm55gX96Ia9niJvCHYEtmGskL84a6(9(sgPbj4IuXdVAaoIw7nyqgR4cL9MyaLuk5Xb0nKap6t9zHbCgZg0t2Q(jy4m3PxlDYg2viByYZnI7jv6K979fnsdsWfPIhE1aCeT2BWGmwXfk7nXakPuYJdOBibE0N6Zcd4mMnONSv9tWW3rSivRuHg2viBazhXce3xOuHiUtoQK2VFd7kKnSk4RHf6ZcDhXn8fEuIbIBaPFBa]] )

    storeDefault( [[Brewmaster: Standard AOE]], 'actionLists', 20170402.130810, [[dStheaGAssA9Qq6LKuzxQOTrqZMO5tsQ1riQVrGdlzNIAVu7gX(vPgfHidJeJJKs3widLKqdwLmCs1brkNIKihdjNJKOwOqTuOQfdPLl4HQq8uLLbWZHYejjXuHOjlY0v1fHkpdP6YOUoOSrcPCAP2mPy7Qq9yq(kjftJqQ(oHWRvb)fqJgunEsQ6KKsFgcxJKGZtOwjHK(nq)KqInLr6HJuOso5ypvH1uWKVJ9Yve7fhyrevyphe57R9fjvH09fnrbNhEwYfg7mafkbk0bOYNuEtNH6s2hT(gK4maHQ1Jg03GemJ0zkJ0dhPqLCYXEdk06VNhn0w2Vypw96sWutqa8aJWtlj1q1dg8iGe2lxrSho1RlbtnbX9L6yeE4zjxySZauOesj4uHUFNbyKE4ifQKto2BqHw)98WZsUWyNbOqjKsWPcDpTKudvpyWJasypAOTSFXEhyeaXIkm4E5kI9uhJ4(ArfgC)ot3i9WrkujNCS3GcT(7LyuyA0CEGraelQWGFctx1QoXOW0O5etNH6scmXY(yoi(eMUhEwYfg7mafkHucovO7PLKAO6bdEeqc7LRi2loW1d)(cuZ9LO1b2JgAl7xShAGRhoqqna10b2VZIUr6HJuOso5yVbfA93Zdpl5cJDgGcLqkbNk090ssnu9GbpciH9Yve7fllOdGW(7R9H(a7rdTL9l2dvwqhaH9aX(qFG97SkyKE4ifQKto2BqHw)98WZsUWyNbOqjKsWPcDpTKudvpyWJasyVCfXE4HHbVjiUVe1kX3xQPjjpAOTSFXEbyyWBccGQALyGIOjj)ol0i9WrkujNCS3GcT(75rdTL9l2dcEdefwa790ssnu9GbpciH9WZsUWyNbOqjKsWPcDVCfXEhbEFFfdlG9(DwGr6HJuOso5yVbfA93Zdpl5cJDgGcLqkbNk090ssnu9GbpciH9Yve7De499LAQJzpAOTSFXEqWBGIOoM97SAnspCKcvYjh7nOqR)EE4zjxySZauOesj4uHUNwsQHQhm4rajSxUIypKncoCFPILm6(sKOujpAOTSFXEFJGda1lzKF)Edk06VNFBa]] )

    storeDefault( [[SimC Windwalker: default]], 'actionLists', 20170523.204343, [[dqemmaqirKwKiQnPk1OOqofjPzjeQ2fu9lecAyuKJbfltO6zKennHqUMqW2qi5BuknoeI6CiKADcrZJc19OuTpscoOiSqHKhsrnreICrrLgjcboPQeVeHqMPiIBsc7KsgkcHAPIkEkvtfHARQs6RcP2lXFr0Gv5WswSO8yPAYcUmQnRk(mfmAr60aVgbZMu3wvTBq)gYWjrhNKqwospxktxX1HsBNsX3jPgVqOCEHY6jjuZxu1(vAbJqS45cRmnhKOe3Q(S4o4BEVObWG6stGPrUxGFkS6rCIe)uy1JeL45WAUASyf3egBnfH4QepUjvQYiyR4ENcuoIlEI(aqWMqSyHriw8CHvMMdsuI7Dkq5i(GmyqZ4a4WukwLtBV37z0EtrnWdEGZW(8G3R2aGgWXQCpvfprgqdMyI3uYfLmTGbY2qbeyXnNYDckq2WFgosM4kqHxlQv9zXf3Q(S4UsUO7reuWWE(qbeyXZH1C1yXkUjm2IXK4VadGEniQ4qeKfxbkyvFwCzeR4cXINlSY0CqIsCVtbkhXt5spP4DSukdhJnkLl9KI)RigryCvfprgqdMyIpiS9us0djHI(lXFbga9AquXHiilUcu41IAvFwCXTQploXiS909qp7rev0FjEcQHM4a4WuBkTDI2uexzFit5spP2nHhbXZH1C1yXkUjm2IXK4EksTcua8ayAtYe3Ck3jOazd)z4izIRafSQplUmILkfIfpxyLP5GeL4ENcuoIpidg0mUs0aqW2EV3ZO9YW(8G3ykdbtmCSk3lF(9YW(8G3ge9tYfDsjlyG8bqzCSk3lF(9mAVKU3uAgo4nMYqWedNHvMMd79EVHcGe4bxjf1XldanyIHJv5EQUx(87LH95bptJqbn22GJv5E5ZV3uud8GpGptoiYaG3Zy77ruM2tvXtKb0GjM4krdabf3Ck3jOazd)z4izIRafETOw1NfxCR6ZIteJgackEoSMRglwXnHXwmMe)fya0RbrfhIGS4kqbR6ZIlJyfrcXINlSY0CqIsCVtbkhXhKbdAgVJq6asnST379mAVPOg4bFaFMCqKbaVNX23JO3tvXtKb0GjM4dcBpLe9qg4Asf3Ck3jOazd)z4izIRafETOw1NfxCR6ZItmcBpDp0ZEejUMuXZH1C1yXkUjm2IXK4VadGEniQ4qeKfxbkyvFwCzeRiielEUWktZbjkX9ofOCe3O9MsZWbVXugcMy4mSY0CyV371riDaPgI3ykdbtmCk)laSTNX23Z0EQUx(87LH95bVXugcMy4yvkEImGgmXeVxAnz1hacsQbTr8xGbqVgevCicYIRafETOw1NfxCR6ZIBU069s0hacUxsaTr8eudnXH1NTNSd(M3lAamOU0eyAK71ykdbtSKfphwZvJfR4MWylgtIBoL7euGSH)mCKmXvGcw1Nf3bFZ7fnaguxAcmnY9AmLHGjMmIfrjelEUWktZbjkX9ofOCepP7nLMHdEJPmemXWzyLP5WEV3ZO9YW(8G3ge9tYfDsjlyG8bqzCSk3lF(96iKoGudXBdI(j5IoPKfmq(aOmEpTOg42E23l(EQkEImGgmXeVxAnz1hacsQbTr8xGbqVgevCicYIRafETOw1NfxCR6ZIBU069s0hacUxsaTzpJWOQ4jOgAIdRpBpzh8nVx0ayqDPjW0i3RXpjlEoSMRglwXnHXwmMe3Ck3jOazd)z4izIRafSQplUd(M3lAamOU0eyAK714hzelBfIfpxyLP5GeL4ENcuoIN09MsZWbVXugcMy4mSY0CyV37XQiSaLk5aEGcGeaqdKPikKSJSHP79EpJ2RJq6asneVnuabMe9qoPmPAamOr0aoL)fa22Zy77HHiV3796iKoGudXFaTPrIEiFWsJHt5FbGT9m2(EyIV3796Pa8owkLHZEQG99u5EV3RJq6asneNcAaObYgwijbqNaoL)fa22Zy77HzV853BkQbEWhWNjhezaW7zS99IhH9YNFVocPdi1q8bHTNsIEidCnP4u(xayBpvypmyIVNQ79EVocPdi1q82GOFsUOtkzbdKpakJ3tlQbUTN99WiEImGgmXeVxAnz1hacsQbTr8xGbqVgevCicYIRafETOw1NfxCR6ZIBU069s0hacUxsaTzpJIRQ4jOgAIdRpBpzh8nVx0ayqDPjW0i3RXpjlEoSMRglwXnHXwmMe3Ck3jOazd)z4izIRafSQplUd(M3lAamOU0eyAK714hzelISqS45cRmnhKOe37uGYr8KU3uAgo4nMYqWedNHvMMd79EVKUhRIWcuQKd4bkasaanqMIOqYoYgMU379mAVocPdi1q82qbeys0d5KYKQbWGgrd4u(xayBpJTVhMiAV371riDaPgI)aAtJe9q(GLgdNY)caB7zS99iQ9EVxpfG3XsPmC2tfSVNk379EDeshqQH4uqdanq2Wcjja6eWP8VaW2EgBFpm7Lp)EtrnWd(a(m5GidaEpJTVhMiSx(871riDaPgIpiS9us0dzGRjfNY)caB7Pc7Hbt89uDV371riDaPgI3ge9tYfDsjlyG8bqz8EArnWT9SVhgXtKb0GjM49sRjR(aqqsnOnI)cma61GOIdrqwCfOWRf1Q(S4IBvFwCZLwVxI(aqW9scOn7zKkvv8eudnXH1NTNSd(M3lAamOU0eyAK714NKfphwZvJfR4MWylgtIBoL7euGSH)mCKmXvGcw1Nf3bFZ7fnaguxAcmnY9A8JmIfrlelEUWktZbjkXtKb0GjM49sRjR(aqqsnOnI)cma61GOIdrqwCfOWRf1Q(S4IBvFwCZLwVxI(aqW9scOn7zuePQ4jOgAIdRpBpzh8nVx0ayqDPjW0i3ZjozXZH1C1yXkUjm2IXK4Mt5obfiB4pdhjtCfOGv9zXDW38ErdGb1LMatJCpNyzKrCxj3bLgOIRbGGIvCIIOLrea]] )

    storeDefault( [[SimC Windwalker: precombat]], 'actionLists', 20170523.204343, [[diZicaGEkvAxubVMQQzlXnPKBl0oPyVKDd1(Psnmu53QAOukmyQKHdKdsvCmu15OuQfIclLQYIbz5G6Ha1tvESuTojPMiLkMkk1KLY0v5IuLUmY1bKTcO2mLs2ok5WI(kvOptf57ssEUaltqJws9nu0jbWPHCnQOopa9mjXFPu12Ou0IxS18ItOc1edntgjTHIGD7YreUvvw8tWv72fiyQ)rO80SdzReOYjgA(OcLbKmHC8m5CoSIdHCvQ4mtT1HrGonnp9d94aXwgEXwZloHkutm0whgb60U3jNkKdG(d94anpqOc6aud0FOhRbUM6(TEwuKWNG0S(gWjSjJKMMjJKMn(d9ynFuHYasMqoEM8CAaGBOEEpSg(XKM13mzK00jtOyR5fNqfQjgAwFd4e2KrstZKrsdCnYTlgabhCAEGqf0bOwVgzpeqWbNMpQqzajtihptEonW1u3V1ZIIe(eKga4gQN3dRHFmPz9ntgjnDYurS18ItOc1ednRVbCcBYiPPzYiPbUg52LJjlsZdeQGoa161i7RkzrA(OcLbKmHC8m550axtD)wplks4tqAaGBOEEpSg(XKM13mzK00PtBGOokli7Mh6XYeAtBRtc]] )

    storeDefault( [[SimC Windwalker: sef]], 'actionLists', 20170523.204343, [[daK3eaqifrwKIInPizuIu1PueAwkcULifTliAyq4yIyzKkptrQPrLQCnfL2Mif(MQW5ePuRJkL5rLkDpiP9PiQdsilur1dvktes0fvfTrQuXjjLmtrQCtLQDQQgkvQQLcP8uKPsqBLuQVsOAVs)vHgmrhwyXk4XIAYk5YO2mHYNvLgnP40q9AQKztPBtv7g43umCrYYb9CQy6QCDcy7qQ(obA8qcNNu16fPK9tYnPcl9eedwE15L(HNlry)MskogSemSUyOBkPdlwjuYIfcyVoVeASLdhUFDisEGywDtJuhIPNE2hLOmeN6kvsu(WgGtf2Fsfw6jigS8QZlrzio1vAskzkiJ(4BEHmb5HFz4yQW6vYPusgWWx9iZcaHm4usuvsgWWx9i9bkuYPuYSgmYSaqidoL0DvYKsIgWw8PV0HFz4yQW6lPfyHZXzGLagaxA3S0oG)WZLk9dpxsi(LHkP7hwFjrWxNsz9zlpEb8LphutkHgB5WH7xhIKhjikTPpBzHb8LpNoV0Mgo7A3Go7zW1Hs7M1p8CPE9RRcl9eedwE15LOmeN6kL1Gr6duOKPPsM1GrMfaczWPKtgvLmrjNsjzadF1J8WEE8mJ(afk5KrvjrGC2sIgWw8PVuaZbGhpdeYGR0Mgo7A3Go7zW1Hs7ML2b8hEUuPF45sIG5aWkPqdeYGReASLdhUFDisEKGOKwGfohNbwcyaCPDZ6hEUuV(NUcl9eedwE15LenGT4tFPCyTJr(WgWOf7CL0cSW54mWsadGlTBwAhWF45sL(HNlTfwRskkFydqjth25kjc(6uceEg1ziSFtjfhdwcgwxm0nLCdLZucn2YHd3VoejpsquAtdNDTBqN9m46qPDZ6hEUeH9BkP4yWsWW6IHUPKBOSx)Uxfw6jigS8QZlrzio1v6mVVwgz2ySlJGahLCkLm9k5KuYbbetmKoNb6h5aEAgdWAummKrkqkLCILenGT4tFjNZa9JCapnJbynkggYL20Wzx7g0zpdUouA3S0oG)WZLk9dpxIod0pbL8zapntqjdWsjDhmKlHgB5WH7xhIKhjikPfyHZXzGLagaxA3S(HNl1R)zRWspbXGLxDEjrdyl(0xkhw7yKpSbmAXoxjTalCoodSeWa4s7ML2b8hEUuPF45sBH1QKIYh2auY0HDoLm9jtSKi4Rtjq4zuNHW(nLuCmyjyyDXq3uss4mLqJTC4W9RdrYJeeL20Wzx7g0zpdUouA3S(HNlry)MskogSemSUyOBkjjSxVsukoJdloTIdBa9Rlns7ETa]] )

    storeDefault( [[SimC Windwalker: serenity]], 'actionLists', 20170523.204343, [[dq04jaqiqulsOcBIkrJIcvNIcLDHQmmuXXiXYurEgiY0OscxtfvTnHk5BGkJJkj15eQO1rHW8qLO7PIY(urLdkKwivQhsGjIkHlIk1gfQuNKGSske1lPqAMujr3uf2jqdLcrwki8uKPkeBLG6RujSxP)sObtvhwvlMIEmPMSixgAZGQ(mvmAHYPvSAQKQxtsZwu3gWUv63uA4G0XPssworpxLMokxhv12PGVlu14PskopOSEQKsZhvs7xWvPrkX9(Mzmv3LaFaSenaccExmBk(pRIsJi4VOe3HbRexGW)8ZS6Ueeyg)lwWtCuGJZ5pbjEN4ajiDE4krA5aLvQuunBS7TrkOsJuI79nZyQUlrA5aLvcYbpujAq0rN4PWJnoOue6NbcExg84Ishy808LsCzb)zbpUO0bgpG31e8Um41XgEA(sjUSGNldELG3LbpKdEt(WdpVlkXDyW4XhAPOMtEyWkXghukc9ZaLeAtJ(zwzP1UyPdBs4xc(ayPsGpawkY4GYG3i9zGsrLo3sAy6mkYEPdYUNPuccmJ)fl4jokWPWPKay6mg5Loi7w3Leed1QhwdiaUSAw6WMaFaSuzf8uJuI79nZyQUlf1CYddwj9NZIVMn2vmpxwjH20OFMvwATlw6WMe(LGpawQe4dGLe85CWhvZg7g8UY5Ykfv6ClTpaEwCqdGGG3fZMI)ZQO0icEbCrCuccmJ)fl4jokWPWPKGyOw9WAabWLvZsh2e4dGLObqqW7IztX)zvuAebVaUOSccPgPe37BMXuDxI0YbkReZ64KrEARnNSXV3srnN8WGv6IsChgSscIHA1dRbeaxwnlDytc)sWhalvc8bWsekXDyWkbbMX)If8ehf4u4usOnn6NzLLw7ILoSjWhalvwbDfnsjU33mJP6UePLduwPxZgdOiUiWG3GNldEivkQ5KhgSsY5oRJ4L)kQoA1scTPr)mRS0AxS0Hnj8lbFaSujWhalbXCN1j4j(BWB0rRwkQ05wsdtNrr2lDq29mLsqGz8VybpXrbofoLeatNXiV0bz36UKGyOw9WAabWLvZsh2e4dGLkRGNVrkX9(Mzmv3LoSjHFj4dGLkb(ayjIjhvm4TWh8SyyW7IztzRmvkQ5KhgSsxMCurrl8ISyOy8ZMYwzQeeyg)lwWtCuGtHtjbXqT6H1acGlRMLeAtJ(zwzP1UyPdBc8bWsLvW4QrkX9(Mzmv3LiTCGYkz8G34bpKdE0vXFGcft8sYzvN1rmMvUIARbug8CLRbVjF4HNNz2Atz(xgp(qdEUY1G3Kp8WZ7IsChgmEse4N9g8CzWRe8gl4DzWB8GxBT5Kn(LNCUZ6iE5VIQJwLNeb(zVb)5cELGNRCn4FnBmGI4IadEd(Zf8kbVXcEJvkQ5KhgSsWpx2v0cVi88LWkjigQvpSgqaCz1S0Hnj8lbFaSujWhalf3ZLDdEl8bFCZxcReeyg)lwWtCuGtHtjH20OFMvwATlw6WMaFaSuzfeUgPe37BMXuDxI0YbkR0RzJbuexeyWBWFUZcEif8Um4HCWdvIgeD0jEk8UqNDN1rul)ffvhTAPOMtEyWkDHo7oRJOw(lkQoA1scIHA1dRbeaxwnlDytc)sWhalvc8bWse0z3zDcEbYFXG3OJwTeeyg)lwWtCuGtHtjH20OFMvwATlw6WMaFaSuzf0v3iL4EFZmMQ7sKwoqzLEnBmGI4IadEd(ZDwWdPsrnN8WGvso3zDeV8xr1rRwsOnn6NzLLw7ILoSjHFj4dGLkb(ayjiM7SobpXFdEJoA1G34kgRuuPZTKgMoJISx6GS7zkLGaZ4FXcEIJcCkCkjaMoJrEPdYU1DjbXqT6H1acGlRMLoSjWhalvwbJZgPe37BMXuDxI0YbkReKdEOs0GOJoXtH3f6S7SoIA5VOO6Ovlf1CYddwPl0z3zDe1YFrr1rRwsqmuREynGa4YQzPdBs4xc(ayPsGpawIGo7oRtWlq(lg8gD0QbVXvmwjiWm(xSGN4OaNcNscTPr)mRS0AxS0Hnb(ayPYkOcNgPe37BMXuDxI0YbkReKdEOs0GOJoXtHNz(1Qw(mr1rRwkQ5KhgSsM5xRA5ZevhTAjH20OFMvwATlw6WMe(LGpawQe4dGLCNFTQLpl4n6Ovlfv6ClPHPZOi7Loi7EMsjiWm(xSGN4OaNcNscGPZyKx6GSBDxsqmuREynGa4YQzPdBc8bWsLvqfLgPe37BMXuDxI0YbkReKdEOs0GOJoXtHNK)n2SoIU(NqX4NnvkQ5KhgSss(3yZ6i66FcfJF2ujbXqT6H1acGlRMLoSjHFj4dGLkb(ayji4FJnRtWBK)eg8Uy2ujiWm(xSGN4OaNcNscTPr)mRS0AxS0Hnb(ayPYkRebf1ZNhx7Zg7wWtXvCwwl]] )

    storeDefault( [[SimC Windwalker: ST]], 'actionLists', 20170523.204343, [[duucvaqisblsQcSjcPrrH6ucHBjvH2fPAyeLJrrltQQNrk00KQKUgfsBJqK(gPOXjvbDoPkvRJquMhfc3JOY(qsoiGAHavpuinrPkLlsk1gLQeNuiALec1ljeYmjeXnbYojYqjevlLuYtPAQaYwfk(kHG9c9xKAWQ6WkTybEmLMSixg1MbkFwqJwQCAfRwQI8AaMTOUTu2TKFtYWjuhxQIA5iEobth01PGTlu9DIQgVqPZJeRNcrZhj1(vz0ebcDTRniZjma9EJbBnKHi4O7wYigIo6AXzEfyuQVmtnLz0(AuVVmnQrJQj6Uy2oBEmYfoQcL6ls7D0b2chvjGaHsMiqORDTbzoHGJoWbtEGuq3U5m9AHJQOZJae9iR0yxOIGEPkgDqQumlrABm6OlTng9OBoFpWw4OQ7fjJaeDGjHcOxBJLRh4tl69IWuj53maMiYUpAV1dqxloZRaJs9LzQPPm0J2XwaGuX5gxqmaDqQK02y09Pf9EryQK8Bgatez3hT3qik1hbcDTRniZjeC0Dlzedr32n6wdecxW7nc5U38ErV347TkvoPKV0jJWuH0cgkAaJfGoHB7uc3l39YUNAQV347xcCaBTqDbizaW0kWOHDmT8tLYkssNRniZP7f9ERsLtk5lDbizaW0kWOHDmT8tLYkssNWTDkH7L7Ez3hX9ut99CXKqk6wdecxW7nI7nQS7JaDGdM8aPGoxmjCmYPcP58e7qqpAhBbasfNBCbXa0bPsXSePTXOJU02y01Uys4yKtfEV25j2HGUwCMxbgL6lZuttzOhzLg7cve0lvXOdsLK2gJocrjnIaHU21gK5eco6ULmIHOB7g92g799492Ur3AGq4cEpvYDV59IEpxmjKIoCAmnur32yVNk5UxMUrrh4GjpqkOVe7wmnuriCbrpAhBbasfNBCbXa0bPsXSePTXOJU02y0bMy3IVhifHWfeDT4mVcmk1xMPMMYqpYkn2fQiOxQIrhKkjTngDeIs9kce6AxBqMti4O7wYigIUgUxmHJthAt6M6WjKj0I3C7ErVNlMesrhonMgQOBBS3BeYDVmDJEVO3B7g92g799492Ur3AGq4cEpvYDFF0boyYdKc6WjKj0I3Cd9iR0yxOIGEPkgDqQumlrABm6OlTngDGMqMCViFZn0bMekGULInZ0WLeYqb5mrxloZRaJs9LzQPPm0JsXMzGwsidfqWrpAhBbasfNBCbXa0bPssBJrhHOKrrGqx7AdYCcbhD3sgXq01W9WnZfuxGjCnqk6CTbzoDp1uFVvPYjL8LUat4AGu0jCBNs4EQK7EtzOdCWKhif0fGKbatRaJg2X0YpvkRij0J2XwaGuX5gxqmaDqQumlrABm6OlTngDhsga89kWUh2X3lctLYkscDT4mVcmk1xMPMMYqpYkn2fQiOxQIrhKkjTngDeIsIuei01U2GmNqWr3TKrmeDJV347TDJU1aHWf8EQK7EnEVO3ZftcPOBnqiCbVNk5UVxLDFe3tn13B7gDRbcHl49uj39g9(iUx07n(EnCpCZCb1fycxdKIoxBqMt3tn13BvQCsjFPlWeUgifDc32PeUNk5U3O3hb6ahm5bsbDYimviTGHIgWybGEKvASlurqVufJoivkMLiTngD0L2gJUwJWuH37gQ7frJfa6atcfq3sXMzA4sczOGCMORfN5vGrP(Ym10ug6rPyZmqljKHci4OhTJTaaPIZnUGya6GujPTXOJqustei01U2GmNqWr3TKrmeD4M5cQlWeUgifDU2GmNUx071W9CpByelMt6jYuaMkKUtrkARkotUx07TkvoPKV0fycxdKIoHB7uc3tLC3B07f9EUysifD40yAOIUTXEpv33hDGdM8aPGoyJauGwbgnygiuqpAhBbasfNBCbXa0bPsXSePTXOJU02y07LrakCVcS77fdekORfN5vGrP(Ym10ug6rwPXUqfb9svm6GujPTXOJquQhIaHU21gK5eco6ULmIHORH7n(E4M5cQlWeUgifDU2GmNUx071W9CpByelMt6jYuaMkKUtrkARkotUpI7f9EUysifD40yAOIUTXEpv33hDGdM8aPGoyJauGwbgnygiuqpAhBbasfNBCbXa0bPsXSePTXOJU02y07LrakCVcS77fdek3BSzeORfN5vGrP(Ym10ug6rwPXUqfb9svm6GujPTXOJquQ3rGqx7AdYCcbhD3sgXq01W9WnZfuxGjCnqk6CTbzoDp1uFVvPYjL8LUat4AGu0jCBNs4EQK7EJIoWbtEGuqNmctfslyOObmwaOhzLg7cve0lvXOdsLIzjsBJrhDPTXOR1imv49UH6Er0ybCVXMrGoWKqb0TuSzMgUKqgkiNj6AXzEfyuQVmtnnLHEuk2md0sczOaco6r7ylaqQ4CJligGoivsABm6ieLmLHaHU21gK5eco6GuPywI02y0rxABm6Iq3qYtfEFVr2qvDVi3qz7qh4GjpqkOlF3qYtfsNiBOQOfBOSDORfN5vGrP(Ym10ug6r7ylaqQ4CJligGEKvASlurqVufJoivsABm6ieLmnrGqx7AdYCcbhD3sgXq05E2WiwmN0HDmn3eZefrG2UIx7avK7f9(adGbMoSJP5MyMOic02v8AhOIOlaxlG7PsU7n797f9EUysifD40yAOIUTXEpv3Rr0boyYdKc6wYAbKNkKUN2etNNWoynvi6r7ylaqQ4CJligGoivkMLiTngD0L2gJEuYAbKNk8Er8M47fjtyhSMkeDT4mVcmk1xMPMMYqpYkn2fQiOxQIrhKkjTngDeIsM9rGqx7AdYCcbhD3sgXq05E2WiwmN0HDmn3eZefrG2UIx7avK7f9(adGbMoSJP5MyMOic02v8AhOIOlaxlG7PsU7n717f9ERsLtk5lDbMW1aPOt42oLW9gX9MA8ErVhUzUG6cmHRbsrNRniZP7f9EUysifD40yAOIUTXEpv3Rr0boyYdKc6wYAbKNkKUN2etNNWoynvi6r7ylaqQ4CJligGoivkMLiTngD0L2gJEuYAbKNk8Er8M47fjtyhSMk8EJnJaDT4mVcmk1xMPMMYqpYkn2fQiOxQIrhKkjTngDeIsMAebcDTRniZjeC0Dlzedr347xlCIZ0CXTHfUNk5UxJ3tn13liEQAQqAlzlMgWybOBvgk49uj39A8(iUx071W9IjCC6qBs3uxq8u1uH0wYwmnGXcaDGdM8aPGUG4PQPcPTKTyAaJfa6r7ylaqQ4CJligGoivkMLiTngD0L2gJUlEQAQW7Js2IVxenwaORfN5vGrP(Ym10ug6rwPXUqfb9svm6GujPTXOJquYSxrGqx7AdYCcbhD3sgXq0TDJEBJ9(E8EB3OBnqiCbVNQ7nVx071W9IjCC6qBs3uNyqOBQq6EAtmT8tLqh4GjpqkOtmi0nviDpTjMw(PsOhTJTaaPIZnUGya6GuPywI02y0rxABm6AzqOBQW7fXBIVxeMkHUwCMxbgL6lZuttzOhzLg7cve0lvXOdsLK2gJocrjtJIaHU21gK5eco6ULmIHOB892Ur3AGq4cEpv3BEp1uFFGbWatpqbGwmrz1ni(EQP(EJVhUzUG6CXKWXiNkKMZtSdrNRniZP7f9ERsLtk5lDUys4yKtfsZ5j2HOt42oLW9gX9wLkNuYx6GncqbAfy0GzGqrNWTDkH7J4(iUx07n(EJV3Qu5Ks(sNmctfslyOObmwa6eUTtjCpv3BEVO3B89A4(LahWwluxasgamTcmAyhtl)uPSIK05AdYC6EQP(ERsLtk5lDbizaW0kWOHDmT8tLYkssNWTDkH7P6EZ7J4EQP(EB3OBnqiCbVNQ77FFe3l69gFVvPYjL8LoyJauGwbgnygiu0jCBNs4EQU38EQP(EB3OBnqiCbVNQ7149rCp1uFVychNo0M0n1HtitOfV529rCVO3RH7ft440H2KUPEqETaugG0agla0boyYdKc6b51cqzasdySaqpYkn2fQiOxQIrhKkfZsK2gJo6sBJrh88AbOmaVxenwaOdmjuaDlfBMPHljKHcYzIUwCMxbgL6lZuttzOhLInZaTKqgkGGJE0o2caKko34cIbOdsLK2gJocrjtrkce6AxBqMti4O7wYigIoxmjKIoCAmnur32yVNQ7nrh4GjpqkOB7gA534m6r7ylaqQ4CJligGoivkMLiTngD0L2gJE0U5EryJZORfN5vGrP(Ym10ug6rwPXUqfb9svm6GujPTXOJquYutei01U2GmNqWr3TKrmeDUysifD40yAOIUTXEpv3BIoWbtEGuq32n0bgicq0J2XwaGuX5gxqmaDqQumlrABm6OlTng9ODZ9GBGiarxloZRaJs9LzQPPm0JSsJDHkc6LQy0bPssBJrhHOKzpebcDTRniZjeC0Dlzedrxd3lMWXPdTjDtD4eYeAXBUDVO3B892UrVTXEFpEVTB0TgieUG3tLC33)EQP(EUysifD40yAOIUTXEVrCV59rGoWbtEGuqhoHmHw8MBOhzLg7cve0lvXOdsLIzjsBJrhDPTXOd0eYK7f5BUDVXMrGoWKqb0TuSzMgUKqgkiNj6AXzEfyuQVmtnnLHEuk2md0sczOaco6r7ylaqQ4CJligGoivsABm6ieLm7Dei01U2GmNqWrhKkfZsK2gJo6sBJrpA3CViSX57n2mc0boyYdKc62UHw(noJUwCMxbgL6lZuttzOhTJTaaPIZnUGya6rwPXUqfb9svm6GujPTXOJquQVmei01U2GmNqWrhKkfZsK2gJo6sBJrpA3Cp4gicW7n2mc0boyYdKc62UHoWaraIUwCMxbgL6lZuttzOhTJTaaPIZnUGya6rwPXUqfb9svm6GujPTXOJqeIU02y09Pf9EryQK8Bgatez37aHqeb]] )

    storeDefault( [[SimC Windwalker: CD]], 'actionLists', 20170523.204343, [[deufkaqiLK2KsQrju5ukbZcrvUfIQYUiQHrbhtvAzuPEgIkttjexdbyBkHQVHGgNsOCoLqADiGAEkjCpkK9ju4GQqluf8qeYerGUivInIOQ6KuOUPQyNezPuj9ustvi2QqPVIaYyfks7f8xv1Gr5Wswmf9yrnzbxgAZQOptPgnLCAQ61krZwKBRs7gPFl1WfshxOOwoHNRutxX1PITJq9DeLXlu15rK1lueZxjr7hvdVqeqDHwMjmahavQUiOQ)seNrG80azvAjkiWCgreeunkM9vYhtQX3uqY9IVOG6kMWAJGKBdVeAGaCtoz3gih5iacbvZcF0buqpMhFt3qeq6fIaQl0YmHb4aOAw4JoGoTTDcLZDNcnz0nOhn9j)qcupL4Ej(J3bPGsKfMx(0eJxKoGjOpDi2sivxeuqLQlcQXuI7LiNftDqk5XzJfYzeil)GCweVnka1vmH1gbj3gEj81aOgtd(CnTauAtrqF6GuDrqHbKCdra1fAzMWaCaunl8rhqN22oHY5UtHMm6g0JM(KFibQzQ7W)0rqcuISW8YNMy8I0bmb9PdXwcP6IGcQuDrqpK6oWzKFhbjqDftyTrqYTHxcFnaQX0GpxtlaL2ue0NoivxeuyajYbra1fAzMWaCaunl8rhqN22oHY5UtHMm6g0JM(KFibQjk2OyPNAdkrwyE5ttmEr6aMG(0HylHuDrqbvQUiOhqXgfl9uBqDftyTrqYTHxcFnaQX0GpxtlaL2ue0NoivxeuyaPfbIaQl0YmHb4aOAw4JoGMT8Y3kEoJ8XzzlVC2riq6WzXWio7LZwZziff2KKh)f)t)Vv8CwmmIZmitaGE00N8djqlrUO4FAHaPdOezH5LpnX4fPdyc6thITes1fbfuP6IGEuKlkYzrAHaPdOUIjS2ii52WlHVga1yAWNRPfGsBkc6thKQlckmGebara1fAzMWaCa0NkE)15gPe24Sb1nOAw4JoGoTTDcLZDNcnz0nNTMZIJZwLZkX4pR8iBxj8B6i2JmslZeg4S1CggZo(OrXGSLpeq6)w7bf7)zlm9Has)t7KT4S1C2QCwubs83ohKFLN2jB97ZFaRXIZwa0JM(KFib60ozRFF(dynwGAmn4Z10cqPnfb9PdXwcP6IGcQuDrqJ0ozloRp5mcI1yb6rH9g0mPCc)tjSXzB0l5DR4)zs5e(NsyJZ2i3G6kMWAJGKBdVe(AauIiLtyKsyJZgoakrwyE5ttmEr6aMG(0bP6IGcdiT4qeqDHwMjmahavZcF0b0PTTtOCU7uOjJU5S1CwCC2QCwjg)zLhz7kHFthXEKrAzMWaNTMZwLZWy2XhnkgKT8Has)3ApOy)pBHPpeq6FANSfNTaOhn9j)qc0PDYw)(8hWASaLilmV8PjgViDatqF6qSLqQUiOGkvxe0iTt2IZ6toJGynwCwCVlaQRycRncsUn8s4RbqnMg85AAbO0MIG(0bP6IGcdiriebuxOLzcdWbqFQ49xNBKsyJZgu3GQzHp6a6022juo3Dk0Kr3C2AolooReJ)SYJSDLWVPJypYiTmtyGZwZzXXzXXztLq6iVrbs9djzKwMjmWzR5SC3PqtgvEJcK6hsYc8wE6MZwHrC2lNTaNTYvYzzlVC2riq6WzXWioZnNTaNTMZIJZYDNcnzu59i8lXFF(hl8tMNgsTiilWB5PBoBfC2IXzRCLCwU7uOjJkF63Z(3N)thbjzbElpDZzRWioBr4Sf4S1CwU7uOjJkl8Bp1(VDO)L(8szbElpDZzRGZiKZwZzRYzrfiXF7Cq(vEANS1Vp)bSgloBbqpA6t(HeOt7KT(95pG1ybQX0GpxtlaL2ue0NoeBjKQlckOs1fbns7KT4S(KZiiwJfNfN7fa9OWEdAMuoH)Pe24Sn6L8Uv8)mPCc)tjSXzBKBqDftyTrqYTHxcFnakrKYjmsjSXzdhaLilmV8PjgViDatqF6GuDrqHbKwmicOUqlZegGdGQzHp6a6ujKoYBuGu)qsgPLzcdC2AoBvoZ058uEJcK6hsYor5S1CgsrHnj5XFX)0)BfpNfdoJCGE00N8djqdIYX2A(95F3oPnOgtd(CnTauAtrqF6qSLqQUiOGkvxeuckkhBRHZ6totBN0g0Jc7nO06IgfeLJT187Z)UDsBqDftyTrqYTHxcFnakrwyE5ttmEr6aMG(0bP6IGcdiTOqeqDHwMjmahavZcF0b0v5SPsiDK3OaP(HKmslZeg4S1C2QCMPZ5P8EAX9JLyS(fn8p9cu2jkNTMZqkkSjjp(l(N(FR45SyWzKd0JM(KFibAquo2wZVp)72jTb1yAWNRPfGsBkc6thITes1fbfuP6IGsqr5yBnCwFYzA7K2CwCVla6rH9guADrJcIYX2A(95F3oPnOUIjS2ii52WlHVgaLilmV8PjgViDatqF6GuDrqHbgqjiEwoPboada]] )


    storeDefault( [[Windwalker Primary]], 'displays', 20170402.130810, [[da0hiaqlsLyxqrQHPihtkTmPONbf10Kc11ivsBtkKVrQiJJuHCosf16ivQ7rQGoOcTqf8qczIqrCrvyJkkFurLrsQItsqVKamtsvDtcODsPFcrdLKokPcSuc0tbtfQUkPkTvsfQVQOQ1cfj7vmyvQdlzXu4XO0KvjxwPntL(muA0uXPr61qWSLQBtk7gv)gXWH0XLcworpNQMUQUok2oH67u04HcNNeRhcTFv0Pn4byl0Ns4Zi8hEL(gaPEX1xO9iWxsS7RkwngbKfh7kYzzridbAGzz2XoflxB5Fa2akiDD97lQqFkH7JDkagiDD97lQqFkH7JDkaQKQvsfHSeoqrCJTXtb0O8XJyXCGgywM9suH(uc3NHakiDD97JxsS77JDkGoGzzwFWJTn4bo4LrFVYqGr2Ns4N36t9FS6Oa2sBdaunrN3Zt5xMvhHvQ7ZBu5Ys0mQpGGBFl)gBZP2g1onH5aaRKI(bEQ2QdNYhBZGh4Gxg99kdbgzFkHFERp1)XQtbSL2gaOAIoVNNYVmRocRu3N3xRBX0)acU9T8BSnNABu70eMZNpG3HycM0N1z8idbWaPRRFF8sIDFFStb8oetWK(SoJmpjdb(sID)roRdrgyajoosbkOW50dEaLy1LMnAkagXofqaRIbLFr5ypVHxPVX2macgJCwhImaosvbfoNEWdWs0mQxv8rmcWwOpLWh5SoezGbK44ifyareuLZBCsG5P8lZQJWkpVhrEeW7qmb8meObMLzXeQCzFkHhqqHZPh8aCgnHSeUp2ghWJU9(SE5Der6ezWduX2gqgBBaSX2gWi228b8oetrf6tjCFgcGbsxx)(JmYk2PafJSWvq3agmUUb0kmgzEsStbQoQtn2nlfVQ4JyBduDuNcCiMQIpITnq1rDkrenJ6vfFeBBaBPTbMNYVmRocR88wvs1kPsGlQhTxk4kOBGkq1nlfVQy1meqm1tnOD6RGRGUbmcWwOpLWh7uS8aIoS4hcgObgklc6yQhEL(gOcaOllT6ueRNs4X2Sr6CazXXU4kOBGYG2PVsGIrwcKY3meqJYhzEsStbqWygH)afXn22MbWaPRRFFH8lkB9ePp2Pavh1PWlj29vfRgBBaVdXeVKy33NHaYThq0Hf)qWaE0T3N1lVtmcuDuNcVKy3xv8rSTbkgznYzDiYadiXXrkq9pMHhObMLzVeYVOS1tK(meW7qmhzEsgc4DiMJmYsi3LeJaFjXU)mc)HxPVbqQxC9fApciWcdQgJ25novBJfZtbm6uerCUoXCS3JraGvsr)abQoQtn2nlfVQy1yBd4DiMcyvmO8lkhRpdbqLuTsQmJWFGI4gBBZaOYLLOzu)OQ(baQMOZ75P8lZQJWk195nQCzjAg1h4ADlM(pQQFaGQj68EEk)YS6iSsDFEFTUft)dOvymEe7ua8QV8)8EojHbn2PaFjXUVQ4Jye4lj29Nr4Fav8ZBO4(ZBBjLeZaQsQwjvoVfvOpLWd8Le7((ayG011VVag8X2gqbPRRF)rgzf7uavjvRKkN3Ik0Ns4N3JmYkqa2c9Pe(mc)bkIBSTndumYcq3ExiMe7uaVdXui)IYwpr6ZqGQJ6uGdXuvSASTbQUzP4vfFKHaEhIPQy1meW7qmhpYqawIMr9QIvJraemMr4Fav8ZBO4(ZBBjLeZakiDD97lGbFS6sBaemMr4p8k9nas9IRVq7rankhWJDkWxsS7pJWFGI4gBBZaEhIPQ4JmeGTqFkHpJW)aQ4N3qX9N32skjMbQoQtjIOzuVQy1yBdCWlJ(ELHaEQgAFhrEeBZau(fLTEICKZ6qKbeu4C6bpGwHbGhBBab3(w(n2MtT60eMBQZy62agDkIioxNygJanWSm7LqwchOiUX24PauwchqlwkhBS6AGIrwc5UeCf0nGbJRBaxc)dCGbQC9EZsjaLLWXueIwST6AGgywM9AgH)afXn22Mbuq6663xi)IYwpr6JDkqdmlZEjGbFgcGjRBX0)meOyKLE50paAVuwz(e]] )

    storeDefault( [[Windwalker AOE]], 'displays', 20170402.130810, [[dauhiaqlve2fQsyykYXuOLPs6zirtdj01urABQO6BKIACkO4CQiADKcDpuLKdkLwOk8qIyIkO6IkQnQaFubzKKcojQQxskYmjL6Mib7KQ(jKAOKQJIQKAPOkEkyQq1vrvQTQGsFvfL1IQeTxXGHOdlzXe1JrLjdHlR0MPKpJKgnL60O8AvIzlv3Mc7MWVrmCOCCsjlNKNtLPRQRJuBNi9DkA8qsNxkwpKy)QuNXGhGRWEgrmGiE4B6Ba08gxB((5aFPOUVUu9ihqvcQRe7L7socOf9sVTDgvHXk(aCbAqBz52xsH9mIWf)uaurBz52xsH9mIWf)uaTOx6fbFoIayOSXtXPaoBIzlTQ4lSiroGw0l9IqsH9mIWLJanOTSC7JxkQ77IFkaVMEPxxWJFm4bMfLCFrKJaTCpJiUrQnZ9Xpmb8LXgaygsUrEgtGWS6xwLgVrIPwoIHC9b4z7B524VonE(40eLbaofd7d8mJLxnLp(RbpWSOK7lICeOL7zeXnsTzUpEnhWxgBaGzi5g5zmbcZQFzvA8gjI1QO7FaE2(wUn(RtJNponrz(8bC2etWK9C2TZ5iaQOTSC7JxkQ77IFkGZMycMSNZUL(j5iWxkQ73k4SjQahOXXrtbE4pKgWd0KbNqZNEofpNYH5KxpLYt1805tX6eu80aweXhygvm16CMvtaNnXeVuu33LJaxKBfC2evaC068WFinGhGJyixVU05ihGRWEgr0k4SjQahOXXrtHaa2YXQodL6zer8xp)KbC2etaphb0IEP3HZul3ZiIa8WFinGhqqBWNJiCXtXaoST3h0lNTesNOcEGk(XaYXpgGA8JbuXpMpGZMykPWEgr4YraurBz52VLwvXpfOOvfEd2gqM2YkGrHAl9tIFkq1XSR2Uz140Loh)yGQJzxGnXux6C8JbQoMDjHyixVU054hd4lJnWzmbcZQFzv3iBrphO6MvJtxQEociL5yYSo7BWBW2aYb4kSNreTDgvrajZE8zEcOfnJ7YWYCW303avaemhwVAWBW2aCbuLG6I3GTbkzwN9nbkAvrbMyZrajeSMBK4KaNXeimR(LvDJSf9CGlYdiIhyOSXpEnqdAll3(8fiyC1tuU4NcORygLQ5gPKc7zeXnYwAvfiaQXpfqT9asM94Z8eWHT9(GE5SJCGQJzx4LI6(6sNJFmatGGXvpr1k4SjQa8WFinGhql6LErWxGGXvpr5YrGIwvTcoBIkWbACC0uq75b4bmyI254PmWxkQ7pGiE4B6Ba08gxB((5auOqLzqBCJeNzSXt5ua5odfugQtmJCaGtXW(aoMGAFduDm7QTBwnoDP6XpgOOvfFHfbVbBditBzfatXmkvZaI4bgkB8JxdGPwoIHC9T6AhaygsUrEgtGWS6xwLgVrIPwoIHC9bAqBz52xthU4pXyaJc1254NcGx9v83ihsrOXIFkWxkQ7RlDoYbqfTLLBFnD4IFmGUIzuQMBKskSNreb(srDFxGVuu3Far8b0XVrcLWDJ0xkfXmGZMyQlvphbAqBz52VLwvXpfqUZqbLH6eZ2EpYbqSwfD)B11oaWmKCJ8mMaHz1VSknEJeXAv09pGZMyYxGGXvpr5YrGIwva2278hE8tbQUz140LoNJaoBIPU05CeWztmBNJCaoIHC96s1JCGlYdiIpGo(nsOeUBK(sPiMbC2etnTnYmbcMGQlhbUipGiE4B6Ba08gxB((5agmbGhpLb(srD)beXdmu24hVgO6y2fytm1LQh)yaUc7zeXaI4dOJFJekH7gPVukIzGQJzxsigY1Rlvp(XaZIsUViYrahZaRVTONJNYaCf2ZiIbeXdmu24hVgWGjAPFs8ugO6y2fEPOUVUu94hdWZ23YTXFDAuZtuE9K8IXamoIaWkoMGA8NgatXmkvdFoIayOSXtXPaoBIzl9tICaJcvap(PamoIGxsigXpEAaTOx6fXaI4bgkB8JxdGkAll3(8fiyC1tuU4NcOf9sVi00Hlhbg(Av09phbkAvXBb7dG1RMvLpba]] )

    storeDefault( [[Brewmaster Primary]], 'displays', 20170402.130810, [[d4dJhaGEf0lru1Uuvv51Qs5XOYmLQ43qnBfnnPQYnvLQdl5BiQ0PjStQSxXUjz)iv)uvzyk04if65umuu1GrIHJWbLshfrfDmk15uvvSqkzPKIwSuSCuEOc8uWYuLSovvvnrvvzQqAYKktxPlQkUkPGlRY1HyJKQ2kIkSzISDK0hLQY2KQ0NrKVtvnssP8meLrtuJxvLtIuULuv11iLQZtvUTuzTQQkDCsjh7GgGRiwbwPhRwy9MxGpnG2dn3taUIyfyLESAbXWlo7xbyLI0nq(4Elwb0c5qU2PGKQ7uBaUaEFssMBhueRaRmXng43NKK52bfXkWktCJb0c5qoD04Wkqm8IRFJbmYy)wewrtjHttaTqoKt3GIyfyLjwb8(KKm3Iwms3AIBma5e5qotqJZoObEuvZ80fRaTCRaROtPhHzJZoGR6Ua)DsfYCdO5nVYCX9A0Ux7XrYcaCmbXgiB2agzSp4lwo52NyfWiJ9BrwCScyKX(GVy5KBrwCScuiSIMscJ6rCbAqKKc4fx)F17yajSAd0Ye1KofxXyy)agzSpAXiDRjwbERPvXjJzbq)41KwFAdnahURPwEQpPjaxrScSQvXjJzbS(qr)EpWamHhDkO4awSZVRm7XOtP97jGrg7dOXkGwihY9NGDCRaRcOjT(0gAafshnoSYehzbme3CQFwg5b4jMf0avC2bAIZoaP4SdWIZoBaJm2FqrScSYeRa)(KKm32IWQ4gduiSc1J4c0GijfOR(1IS44gdutc5QD6xEgEQpXzhOMeYfiJ95P(eNDGAsixdWDn1Yt9jo7a)DsfYCJvGA6xEgEQ8XkavHr0iMI1d1J4c0eGRiwbw1ofKubg84qF0mGwicU3ihcdSEZlqfqNWqmlpupIlqfGvkshQhXfOAetX6fOqy17c1fRaaXXjQPyyTcSkUx9QXaV1OhRwqm8IZ(vGFFssMBPP0j4QfZmXngGNj6kMhDkdkIvGv0P0IWQab(f99sgzKzRrYv72V0yVJ92lzrQ)9tJby3mWGhh6JMbme3CQFwg50eOMeYfAXiDlp1N4SdSfJ0T6XQnapkDkqPm0P4kgd7hqlKd50rtPtWvlMzIvGcHvTkozmlG1hk63798OhnqNq1(ehzb2Ir6w9y1cR38c8Pb0EO5Ec8E9t0H0rNcQO7IJSXantXWH9nX(PjaWXeeBGa1KqUAN(LNHNkFC2b0DsfYCB57jGf787kZES)NoL)oPczUbiyIUI5PhRwqm8IZ(vac2XH7AQTLVN4gd49jjzUL8wM46VDGU6x7tCJbqR5Pw6u6JHriIBmWwms3Yt9jnb(9jjzUfTyKU1e3yanV5vMlUxJ2K7izV(N)ZoWBn6XQfwV5f4tdO9qZ9eW7tsYCBlcRIBmqnjKlqg7ZtLpo7aBXiDlpv(0eOzkgoSVj2VDottaJm2NMsNGRwmZeRafcRaIBoP9xCJbQPF5z4P(eRagzSpp1NyfWiJ9BFIvaoCxtT8u5ttaJm2NNkFSc8wJESAdWJsNcukdDkUIXW(b(9jjzUL8wM4Sd0juaACJb2Ir6w9y1cIHxC2VcyKX(K)8AekDcfjtScWveRaR0JvBaEu6uGszOtXvmg2pqnjKRb4UMA5PYhNDGhv1mpDXkGr0rmV2VN4EfOtOArwCCJbQjHCHwms3YtLpo7aD1pano7a8mrxX8OtzqrScSkWwms3Aciu6eC1IzTkozmlGM06tBObiyIUI5rJdRaXWlU(ngqWHvarXjuKIt7b2Ir62wfNmMfW6df97DnP1N2qdi4WQ)fJ7IZw7b0c5qoD6XQfedV4SFfW7tsYClnLobxTyMjUXaAHCiNoYBzIvax1DbSyNFxz2JrNcpt0vmVafcR0GsSbiML3XYMa]] )

    storeDefault( [[Brewmaster AOE]], 'displays', 20170402.130810, [[d4dOhaGEfQxsPIDHesVwPIhJuZus43iMTIMMsLUje4Ws9nuQCAuTtQSxXUj1(rr)uPmmL04GGEofdLKgmsA4q1bLWrrcvhJQCokvYcLulLOyXuYYj8qfYtbltPQ1HeIjIemvinzkLPRYfvIRIsPlRQRdLnsuTvKqzZez7OKpsPQTHe9zi67uvJeLINjjnAsmEi0jrHBHsvxts05LOBRG1sPsDCIshVGgGUXporlNOp4kNFGn2Iwbd3sa6g)4eTCI(a(4poV9beTg5ps5P3j1bKf7X(IjhPE41xa6aLBssM)g14hNOnXTgaXnjjZFJA8Jt0M4wdil2J92yqt0aF8h3URbmke)cmrZqlrIvazXES32Og)4eTj1bk3KKm)H2cK)zIBnafh7XEtqJZlObw0T18TL6af0hNOzsTcU5IZlGRh(au4LAS5fqMF(T5JB)QhLERRvda0co(fixUagfIp4ZpALILuhWOq8lWosScyui(Gp)OvkWosQdCTa5FfAAfIiq9gk6gcKHH9SbnqzKZE2vjL7szveAx7RSALSBLY1iX(DRmGerFbke8EYKQRfcIFaJcXhTfi)ZK6a7yvOPviIaOBQYWWE2GgGMmy1NkRLyfGUXporxOPviIa1BOOBiiWicEjtQOKa1I3FOn3lysTyBjGrH4dOPoGSyp2tbU4Pporhqgg2Zg0aASbg0eTjUQbm4)CkF2gLrKjre0aDCEbeX5fazCEbSIZlxaJcXFuJFCI2K6aiUjjz(Rat0XTgOXenAj(hWctskWqJyb2rIBnqpXv6IPFxAuzTeNxGEIR0GcXxL1sCEb6jUspImy1NkRL48cqHxQXMxQd0t)U0OYsn1byXnCl(KFLOL4FaRa0n(Xj6IjhPoWOfh6ImbKfJtVdfJBGRC(b6a24g8zxIwI)bOdiAnYhTe)d0w8j)kd0yIgbC9N6aiUjjz(JH2gNUpIWe3AGDSKt0hWh)X5TpaG)08EYh3hNOJBpLimqpXvA0wG8pvwQX5fOXendTebTe)dyHjjfq8ZaJwCOlYeWG)ZP8zBuIvGEIR0OTa5FQSwIZlW1cK)jNOVaQOmPcT2WKQRfcIFazXES3gdTnoDFeHj1bAmrxOPviIa1BOOBiOIf5Obg46IL4Qg4AbY)Kt0hCLZpWgBrRGHBjacAe5dydmPIYh(4QUgWAYhp2(jXpwbaAbh)cy4AKZpqpXv6IPFxAuzPgNxaBVuJnVc1kculE)H2CVGIWKkfEPgBEbWf8HwukNOpGp(JZBFaCXttgS6RqTI4wduUjjz(Zo1M4yVxGHgXIL4wdG2ZxFmPAVGGHh3AGRfi)tL1sScG4MKK5p0wG8ptCRbK5NFB(42V6XU1Q7TlkQxGDSKt0hCLZpWgBrRGHBjq5MKK5Vcmrh3AGEIR0GcXxLLACEbC9WhOw8(dT5EbtQfBlbSM8XJTFs8lMZyfWOq8zOTXP7JimPoqJjAa)NtguiU1a90VlnQSwsDaJcXxL1sQdyui(flXkanzWQpvwQXkGrH4RYsn1b2XsorFburzsfATHjvxlee)aiUjjz(Zo1M48cmW1aACvdCTa5FYj6d4J)482hWOq8TZxAX124AKMuhGUXporlNOVaQOmPcT2WKQRfcIFGEIR0Jidw9PYsnoVal62A(2sDadFaF(fBlXvnW1cK)PYsnwbuf8HwuYK6Og)4entQfyIoqaCbFOfLmOjAGp(JB31aQc(qlkzsDuJFCIoW1cK)zcGyKtz1Qv9qi7Q0BpcPCLskRgj2VlcdW12409refAAfIiGmmSNnObgAeb04wdWPjAaVP5AKXvzaonrB3eYqCEvgqwSh7TjNOpGp(JZBFGYnjjZFm02409reM4wdil2J92StTj1bg46cSJex1anMOzRMFbWND5lYLa]] )

    storeDefault( [[Brewmaster Defensives]], 'displays', 20170402.130810, [[d4ZEhaGEfQxIQs7svu51sP6WsMPuIJtbMTIUgkKBQQspNOBRGlR0oP0Ef7MW(Pq)uvzysLFd14ufLHssdMIA4i6GsvhffuDmQY5uvXcPILsbTyQ0Yj1dvfEkyzkK1HcIjQkYuHyYOktxLlQkDvuv5zsPCDiTrkYwrbLnJkBhbFukPpJqttvu13PQgjkuBdvvnAsmEvvDsu0TqvXPr68sXJrP1IcsFdf44fKaSf5rXctyXbxZCd8XpKwyAFdCLM4EQeuJBaDjiUpuw22Jta3jD84wNy)4gO5JJtU3JI8OyHm2Ua))44K79OipkwiJTlGbOl6YJjlwa0XBSJyuGbQO)n22cya6IU8EuKhflKXjqZhhNCpKstCpzSDby4Ol6kdsSEbjWROCNlV4eON9OyHrZTqLxSJcyRHnWtl3kKucRmGH7Cl5g7Oop(7111waGvtjVa5YfqQG9bF6XQ0)gNa))44K7HuAI7jJTlGub7d(0JvPh9WXjqHQlMcomsd5gWfLJlqtS8ze)7c8pM4ZZyWp8V7N2yeJ(PJbp7hpgeo(88miGub7JuAI7jJtG2D7fSkyDaKpvdz2kJrcWIhCRtLWBCdWwKhfl6fSkyDaNpeKVFdaKllTM0X1rXIyhX)NfqQG9bK4eWa0fDFIQx2JIfbmKzRmgjGaDGjlwiJ1lGKCNttZsQ8apX6GeOI1lGowVaeJ1lGBSE5civW(pkYJIfY4e4)hhNCVEuDfBxGcvxinKBaxuoUad1)E0dhBxGAsQu9t)QrQs4nwVa1KuPafSVkH3y9cutsL6bEWTovcVX6fWwdBah96puYB1gn)0YTcjLWkdut)QrQsqnobiqLux6KEninKBa3aSf5rXI(jLOiWJxlYRHb4rLKZQbPHCdWlGUeexKgYnq5sN0RjqHQRFPInobmaLY2odJkHRzUbQaT7AcloGoEJ1RlW)poo5Emf8OS1H1Yy7cutsLcP0e3tLGASEbA(44K7XuWJYwhwlJTlGENbE8ArEnmGKCNttZsQe3a1KuPqknX9uj8gRxaoS4c0RP10OzBP1y)agGUOlpMcEu26WAzCcmu)bKy9cuO6QxWQG1bC(qq((TLxtibUstCptyXbxZCd8XpKwyAFd8B9NoGoy0mcDyJTTUasfSFp6HJtaGvtjVabQjPs1p9RgPkb1y9cOQPdLUXO5hf5rXIa8wUcDEbi10Hs3ycloGoEJ1Buas9YIhCRRxTLy7c08XXj3JVoYy5JxGH6F)BSDbqQ5koJMBvJrjJTlWvAI7Ps4nUb()XXj3JVoYy9cy4o3sUXoQZJbDTn6NNZlGub73JQlMcoCCdivW(QeuJtGMpoo5E9O6k2Ua1KuPafSVkb1y9c4oPJh36e73pNXnGub7ZuWJYwhwlJtaElxHoVE1wc4Ox)HsERMHy08tl3kKucRmqn9RgPkH34eOq1fqUZjZNITlGub7Rs4nobyXdU1PsqnUbKkyF(UnUubpQGOmobA31ewCW1m3aF8dPfM23aT7AclUaQigndLqA0ST0ASFGbQaqITlWvAI7zcloGoEJ1BuaPc2V)nobylYJIfMWIlGkIrZqjKgnBlTg7hOMKk1d8GBDQeuJ1lWROCNlV4eqshiNB)3BSJcWwKhflmHfhqhVX6nkWav0JE4y7cOQPdLUXO5hf5rXcJM7r1vGaKA6qPByYIfaD8gBBDbOcEu26W6EbRcwhWqMTYyKagGUOB)KsumSIlaBGR0e3RxWQG1bC(qq((1qMTYyKauwSailwQGySmkaLflyOy8qST1fWa0fD5zcloGoEJ1BuGR0e3ZewCburmAgkH0OzBP1y)agGUOlp(6iJtGNwUcDEXjqHQl(jOxaYz1S6Cja]] )


    ns.initializeClassModule = MonkInit

end
