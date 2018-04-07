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
local addBuffMetaFunction = ns.addBuffMetaFunction
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
local UnregisterEvent = ns.UnregisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent
local UnregisterUnitEvent = ns.UnregisterUnitEvent

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
        addAura( 'ironskin_brew', 215479, 'duration', 6 )
        addAura( 'keg_smash', 121253, 'duration', 15 )
        addAura( 'leg_sweep', 119381, 'duration', 5 )
        addAura( 'mark_of_the_crane', 228287, 'duration', 15 )
        addAura( 'master_of_combinations', 238095, 'duration', 6 )
        addAura( 'paralysis', 115078, 'duration', 15 )
        addAura( 'power_strikes', 129914 )
        addAura( 'pressure_point', 247255, 'duration', 5 )
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
        addGearSet( 'tier21', 152145, 152147, 152143, 152142, 152144, 152146 )
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

        
        -- Be more thorough about what generates Hit Combo stacks and what doesn't.

        local hc_gen = {}

        hc_gen.blackout_kick = true
        hc_gen.chi_burst = true
        hc_gen.chi_wave = true
        hc_gen.crackling_jade_lightning = true
        hc_gen.fists_of_fury = true
        hc_gen.flying_serpent_kick = true
        hc_gen.rising_sun_kick = true
        hc_gen.spinning_crane_kick = true
        hc_gen.strike_of_the_windlord = true
        hc_gen.tiger_palm = true
        hc_gen.touch_of_death = true
        hc_gen.whirling_dragon_punch = true

        local actual_combo, virtual_combo = nil, nil

        -- actual_combo is the last combo ability that you actually used.
        -- virtual_combo is for abilities that we pretend to cast as a recommendation.

        addMetaFunction( 'state', 'last_combo', function ()
            return virtual_combo or actual_combo
        end )


        -- may need to revisit -- if you cast tiger palm and miss, it should probably not count against you...
        RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, _, spellID )
            if unit ~= 'player' then return end

            local key = class.abilities[ spellID ] and class.abilities[ spellID ].key
            if not key then return end

            if hc_gen[ key ] then
                actual_combo = key 
            end
        end )


        addHook( 'runHandler', function( key, no_start )
            if hc_gen[ key ] then
                virtual_combo = key 
            end
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
            
            virtual_combo = nil
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

        local function trackBrewmasterDamage( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, arg1, _, _, _, arg5, _, _, arg8, _, _, arg11 )
            
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

        end

        addHook( 'specializationChanged', function ()
            setPotion( 'prolonged_power' )
            setRole( state.spec.brewmaster and 'tank' or 'attack' )
            if state.spec.brewmaster then
                RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", trackBrewmasterDamage )
            else
                UnregisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", trackBrewmasterDamage )
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

        local bt = BrewmasterTools

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
                    if bt then
                        return state.stagger.amount / 20
                    end
                    return state.stagger.amount / state.stagger.ticks_remain

                elseif k == 'ticks_remain' then
                    return math.floor( stagger.remains / 0.5 )

                elseif k == 'amount' then
                    if bt then
                        t.amount = bt.GetNormalStagger()
                    else
                        t.amount = UnitStagger( 'player' )
                    end
                    return t.amount

                elseif k == 'incoming_per_second' then
                    return avg_stagger_ps_in_last( 10 )

                elseif k == 'time_to_death' then
                    return math.ceil( state.health.current / ( state.stagger.tick * 2 ) )

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


        --[[ addToggle( 'strike_of_the_windlord', true, 'Artifact Ability',
            'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'strike_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for your artifact ability will be overridden and your artifact ability will be shown regardless of its toggle above.",
            width = "full"
        } ) ]]

        addToggle( 'use_defensives', true, "Brewmaster: Use Defensives",
            "Set a keybinding to toggle your defensive abilities on/off in your priority lists." )

        addSetting( 'elixir_energy', 20, {
            name = "Windwalker: Energizing Elixir Energy Deficit",
            type = "range",
            min = 0,
            max = 100,
            step = 1,
            desc = "Specify the amount of |cFFFF0000missing|r energy that must be missing before Energizing Elixir will be used.  The default is |cFFFFD10020|r.  If set to zero, Energizing Elixir " ..
                "can be used regardless of how much energy you have (as long as action list criteria are met).",
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
        --[[ addMetaFunction( 'toggle', 'artifact_ability', function()
            return state.toggle.strike_of_the_windlord
        end )

        addMetaFunction( 'settings', 'artifact_cooldown', function()
            return state.settings.strike_cooldown
        end ) ]]

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
            spec = 'brewmaster',
            talent = 'black_ox_brew'
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
            cycle = 'mark_of_the_crane',
            usable = function () return last_combo ~= 'blackout_kick' or not talent.hit_combo.enabled end,
            recheck = function ()
                return buff.serenity.remains, cooldown.serenity.remains, cooldown.energizing_elixir.remains - cooldown.fists_of_fury.remains
            end
        } )

        modifyAbility( 'blackout_kick', 'spend', function( x )
            if buff.serenity.up then return 0
            elseif buff.bok_proc.up then return 0 end
            return x
        end )

        addHandler( 'blackout_kick', function ()
            if buff.bok_proc.up and buff.serenity.down then
                removeBuff( 'bok_proc' )
                if set_bonus.tier21_4pc > 0 then gain( 1, 'chi' ) end
            end

            applyDebuff( 'target', 'mark_of_the_crane', 15 )
            
            if talent.dizzying_kicks.enbled then
                applyDebuff( 'target', 'dizzying_kicks', 3 )
            end

            if talent.hit_combo.enabled then
                if last_combo == 'blackout_kick' then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end

            if equipped.the_emperors_capacitor then addStack( 'the_emperors_capacitor', 3600, 1 ) end
        end )


        addAbility( 'blackout_strike', {
            id = 205523,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'melee',
            cooldown = '3',
            spec = 'brewmaster'
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
            addStack( 'elusive_brawler', 10, active_enemies * ( set_bonus.tier21_2pc > 0 and 2 or 1 ) )
            removeBuff( 'blackout_combo' )
        end )


        addAbility( 'chi_burst', {
            id = 123986,
            spend = 0,
            spend_type = 'energy',
            cast = 1,
            gcdType = 'spell',
            cooldown = 30,
            talent = 'chi_burst',
            usable = function () return last_combo ~= 'chi_burst' or not talent.hit_combo.enabled end,
        } )

        modifyAbility( 'chi_burst', 'cast', function( x )
            return x * haste
        end )

        addHandler( 'chi_burst', function ()
            if talent.hit_combo.enabled then
                if last_combo == 'chi_burst' then removeBuff( 'hit_combo' )
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
            talent = 'chi_wave',
            usable = function () return last_combo ~= 'chi_wave' or not talent.hit_combo.enabled end,
        } )

        addHandler( 'chi_wave', function ()
            if talent.hit_combo.enabled then
                if last_combo == 'chi_wave' then removeBuff( 'hit_combo' )
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
            recheck = function ()
                return cooldown.serenity.remains - 13
            end,
            usable = function () return last_combo ~= 'crackling_jade_lightning' or not talent.hit_combo.enabled end,
        } )

        addHandler( 'crackling_jade_lightning', function ()
            removeBuff( 'the_emperors_capacitor' )
            if talent.hit_combo.enabled then
                if last_combo == 'crackling_jade_lightning' then removeBuff( 'hit_combo' )
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
            talent = 'dampen_harm'
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
            talent = 'energizing_elixir',
            recheck = function () return cooldown.rising_sun_kick.remains, cooldown.strike_of_the_windlord.remains end,
            usable = function () return energy.current + ( energy.regen * cooldown.global_cooldown.remains ) < ee_maximum end,
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
            equipped= 'fu_zan_the_wanderers_companion',
            toggle = 'artifact'
        } )


        addAbility( 'fists_of_fury', {
            id = 113656,
            spend = 3,
            spend_type = 'chi',
            cast = 4,
            channeled = true,
            gcdType = 'spell',
            cooldown = 24,
            recharge = function ()                
                return buff.pressure_point.remains - 2, buff.serenity.remains - 1, cooldown.serenity.remains - 4, cooldown.serenity.remains - 4
            end,
            usable = function () return last_combo ~= 'fists_of_fury' or not talent.hit_combo.enabled end,
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

            if set_bonus.tier20_4pc == 1 then applyBuff( 'pressure_point', 5 + action.fists_of_fury.cast ) end
            return x * haste
        end )

        -- By having the ability's handler set the global cooldown to 4 seconds (reduced by haste),
        -- the addon's next prediction will wait until the global cooldown ends.
        -- We should watch this for unintended consequences.
        addHandler( 'fists_of_fury', function ()
            -- applyBuff( 'fists_of_fury', 4 * haste ) -- now set as channeled, watch this.
            if talent.hit_combo.enabled then
                if last_combo == 'fists_of_fury' then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
            if equipped.the_emperors_capacitor then addStack( 'the_emperors_capacitor', 3600, 1 ) end
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
        class.abilities.brews = class.abilities.ironskin_brew

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
            talent = 'invoke_xuen',
            toggle = 'cooldowns'
        } )
        class.abilities.invoke_xuen_the_white_tiger = class.abilities.invoke_xuen

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
            talent = 'leg_sweep'
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
            talent = 'ring_of_peace'
        } )


        addAbility( 'rising_sun_kick', {
            id = 107428,
            spend = 2,
            spend_type = 'chi',
            cast = 0,
            gcdType = 'melee',
            cooldown = 10,
            cycle = 'mark_of_the_crane',
            usable = function () return last_combo ~= 'rising_sun_kick' or not talent.hit_combo.enabled end,
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
            removeBuff( 'pressure_point' )

            if talent.hit_combo.enabled then
                if last_combo == 'rising_sun_kick' then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
            if equipped.the_emperors_capacitor then addStack( 'the_emperors_capacitor', 3600, 1 ) end
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
            notalent = 'chi_torpedo'
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
            cycle = 'mark_of_the_crane',
            usable = function () return last_combo ~= 'rushing_jade_wind' or not talent.hit_combo.enabled end,
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
                if last_combo == 'rushing_jade_wind' then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end

            if equipped.the_emperors_capacitor then addStack( 'the_emperors_capacitor', 3600, 1 ) end
        end )


        addAbility( 'serenity', {
            id = 152173,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'off',
            cooldown = 90,
            talent = 'serenity',
            toggle = 'cooldowns',
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
            usable = function () return last_combo ~= 'spinning_crane_kick' or not talent.hit_combo.enabled end,
        } )

        modifyAbility( 'spinning_crane_kick', 'spend', function( x )
            if buff.serenity.up then return 0 end
            return x
        end )

        addHandler( 'spinning_crane_kick', function ()
            if talent.hit_combo.enabled then
                if last_combo == 'spinning_crane_kick' then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
            if equipped.the_emperors_capacitor then addStack( 'the_emperors_capacitor', 3600, 1 ) end
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
            notalent = 'serenity',
            ready = function () return buff.storm_earth_and_fire.remains end,
            toggle = 'cooldowns',
            texture = 136038,
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
            equipped = 'fists_of_the_heavens',
            toggle = 'artifact',
            usable = function () return last_combo ~= 'strike_of_the_windlord' or not talent.hit_combo.enabled end,
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
                if last_combo == 'strike_of_the_windlord' then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
            end
            if equipped.the_emperors_capacitor then addStack( 'the_emperors_capacitor', 3600, 1 ) end
        end )


        addAbility( 'summon_black_ox_statue', {
            id = 115315,
            spend = 0,
            spend_type = 'energy',
            cast = 0,
            gcdType = 'spell',
            cooldown = 10,
            talent = 'summon_black_ox_statue',
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
            cycle = 'mark_of_the_crane',
            recheck = function ()
                return buff.serenity.remains, cooldown.fists_of_fury.remains, buff.hit_combo.remains, energy.time_to_max - 3
            end,
            usable = function () return last_combo ~= 'tiger_palm' or not talent.hit_combo.enabled or ( chi.current == 0 and buff.hit_combo.down ) end,
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
                    if last_combo == 'tiger_palm' then removeBuff( 'hit_combo' )
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
            cycle = 'touch_of_death',
            recheck = function ()
                return cooldown.serenity.remains - 1, cooldown.strike_of_the_windlord.remains - 8, cooldown.fists_of_fury.remains - 4, cooldown.rising_sun_kick.remains - 7
            end,
            usable = function () return last_combo ~= 'touch_of_death' or not talent.hit_combo.enabled end,
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
            if talent.hit_combo.enabled then
                if last_combo == 'touch_of_death' then removeBuff( 'hit_combo' )
                else addStack( 'hit_combo', 10, 1 ) end
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
            talent = 'whirling_dragon_punch',
            usable = function () return last_combo ~= 'blackout_kick' or not talent.hit_combo.enabled end,
            usable = function () return ( last_combo ~= 'whirling_dragon_punch' or not talent.hit_combo.enabled ) and cooldown.fists_of_fury.remains > 0 and cooldown.rising_sun_kick.remains > 0 end,
        } )

        addHandler( 'whirling_dragon_punch', function ()
            if talent.hit_combo.enabled then
                if last_combo == 'whirling_dragon_punch' then removeBuff( 'hit_combo' )
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


        function class.abilities.draught_of_souls.elem.recheck()
            return buff.serenity.remains, buff.storm_earth_and_fire.remains
        end
        setfenv( class.abilities.draught_of_souls.elem.recheck, state )

        function class.abilities.forgefiends_fabricator.elem.recheck()
            return buff.serenity.remains - 1
        end
        setfenv( class.abilities.forgefiends_fabricator.elem.recheck, state )

        -- Implant this for the Unbridled Fury trinket.
        function class.abilities.unbridled_fury.elem.recheck()
            return cooldown.strike_of_the_windlord.remains - 14, cooldown.fists_of_fury.remains - 15, cooldown.rising_sun_kick.remains - 7, buff.serenity.remains
        end
        setfenv( class.abilities.unbridled_fury.elem.recheck, state )

        function class.abilities.vial_of_ceaseless_toxins.elem.recheck()
            return cooldown.serenity.remains - 8, target.time_to_die - cooldown.serenity.remains
        end
        setfenv( class.abilities.vial_of_ceaseless_toxins.elem.recheck, state )

    end


    storeDefault( [[SimC Brewmaster: default]], 'actionLists', 20180128.151850, [[dGehsaqisQO2ejLrPGCkfuRsbQxPa4wibSlQyyk0XOQwMIYZiHyAKq6AiH2gsG(gOQXPa05iPsTosQqZJKe3tb0(ij1brkwivQhIenrsQsxeP0grcYijPcojjyLKKuEjsqDtfzNG8tsQIHssvTuKQNsmvK0wjj(kjvYBjPICxssI9k9xL0GP0HvzXk1Jf1Kf5YqBwj(mqgnqDAsTAssQEnOmBa3wODJ43QA4GklhLNly6O66uLTRO67KOXtc15PswpjjP5Raz)uC9l1k0sUnaM6Uc0fXkIosPX6MHkJxGJm1rJnHlNhaVIahM1hGwv946NuOzuWbScDeaVawOzJ(d4O)mFNzkIIQOJWxrYmnC8kvOjZ1pjuQfYVuRql52ayQURizMgoEfVaUMWfKe0ZXGXQMXQj5pQjGwtx8aHR(uCCmgmwvBSGXdGd2jEk2yhSXo6mZyvZy3EllolpJRxCPjGw3muPt6vsQqZwdO5UQKUiCizf8XIvuGK05J)SkKNGvM(Kkhd6IyLkqxeROEViCiXyvhowScDeaVawOzJ(W7pwHogEpwgdLA5vOemMHn9ZXis4Dxz6tqxeRuEHMvQvOLCBamv3vKmtdhVIxaxt4csc65yWyvZy1K8h1eqRPlEGWvFkoogdgRQnwW4bWb7epfBSd2yhD8nw1m2Hm2T3YIt6IWHKvWhl6KELeJDqdYy3Elloj9YIxaxJhiD2j9kjg7WvOzRb0CxvwEgxV4staTUzOYkkqs68XFwfYtWktFsLJbDrSsfOlIvOqpJRxCPjGmw3muzf6iaEbSqZg9H3FScDm8ESmgk1YRqjymdB6NJrKW7UY0NGUiwP8cPiLAfAj3gat1DfA2Aan3vf4EU(jvuGK05J)SkKNGvM(Kkhd6IyLkqxeRmO8YY4yoVSOoP(px)evLbXQqhbWlGfA2Op8(JvOJH3JLXqPwEfkbJzyt)CmIeE3vM(e0fXkLxifTuRql52ayQURqZwdO5UQSb(pTU4XCvrbssNp(ZQqEcwz6tQCmOlIvQaDrSIBG)tglfYJ5QcDeaVawOzJ(W7pwHogEpwgdLA5vOemMHn9ZXis4Dxz6tqxeRuEHOyPwHwYTbWuDxHMTgqZDvzJSaYGPjGQOajPZh)zvipbRm9jvog0fXkvGUiwXnYcidMMaQcDeaVawOzJ(W7pwHogEpwgdLA5vOemMHn9ZXis4Dxz6tqxeRuEHOGLAfAj3gat1DfA2Aan3vfuXWb8jnb0kmeuffijD(4pRc5jyLPpPYXGUiwPc0fXk0Qy4a(KMaYyPWiOk0ra8cyHMn6dV)yf6y49yzmuQLxHsWyg20phJiH3DLPpbDrSs5fc(sTcTKBdGP6UIKzA44v8c4AcxqsqphdgRAg7qgBGFGaHmhW4n3LXoObzSdzSb(bceYCIFczhhnw1m28)aPxjXzZqLbNm4JbcdRlSlZ1p5amwvpqJn)pq6vsC2muzWjEkEnd(yGWGXsbm2rhkASQzSBVLfhn7jbyAY6MHkDyy80KGXQ6bASBVLfhn7jbyAY6MHkDsESJRFIXoyJDMdfn2Hn2HRqZwdO5UQaNhtV4staTUzOYkkqs68XFwfYtWktFsLJbDrSsfOlIvuFpMEXLMaYyDZqLvOJa4fWcnB0hE)Xk0XW7XYyOulVcLGXmSPFogrcV7ktFc6IyLYl0awQvOLCBamv3vKmtdhVIxaxt4csc65yWyvZyhYy3ElloBGld794R5pUFN0RKySQzS5)bsVsIZMHkdozWhdegwxyxMRFYbySQEGgB(FG0RK4SzOYGt8u8Ag8XaHbJLcySJo(glfWyhYy9n2bWy3ElloA2tcW0K1ndv6WW4PjbJvvgOXU9wwC0SNeGPjRBgQ0j5XoU(jg7Gn2rhkASdBSQzSBVLfhn7jbyAY6MHkDyy80KGXQkd0y3ElloA2tcW0K1ndv6K8yhx)eJDWg7mJD4k0S1aAURkA2tcW0K1ndvwrbssNp(ZQqEcwz6tQCmOlIvQaDrSIcSNeGPjgRBgQScDeaVawOzJ(W7pwHogEpwgdLA5vOemMHn9ZXis4Dxz6tqxeRuEHu3LAfAj3gat1DfjZ0WXROj5pQjGwtx8aHR(uCCmgmwvBSJgRAgBGFGaHmhW4n3LXQMXM)hi9kjoBgQm4KbFmqyyDHDzU(jhGXQkd0yhDGNIvOzRb0Cxv2axg26R41ndvwrbssNp(ZQqEcwz6tQCmOlIvQaDrSIBGldZyvpk2yDZqLvOJa4fWcnB0hE)Xk0XW7XYyOulVcLGXmSPFogrcV7ktFc6IyLYlK)yPwHwYTbWuDxrYmnC8kdzSibzGC5K9ymKWn2bWyhYyrcYa5YHHGqIXoyJn)pq6vsCGHGwdXla2HHXttcg7Wg7WgRQySk6OXQMXU9wwC2axg27XxZFC)oPxjXyvZyZ)dKELehyiO1q8cGD8GRcnBnGM7QYg4YWwFfVUzOYkkqs68XFwfYtWktFsLJbDrSsfOlIvCdCzygR6rXgRBgQ0yhYF4k0ra8cyHMn6dV)yf6y49yzmuQLxHsWyg20phJiH3DLPpbDrSs5fY3VuRql52ayQURizMgoEfKGmqUCYEmgs4gRQySkIFfA2Aan3vLJLpcUYFgdj8kkqs68XFwfYtWktFsLJbDrSsfOlIvOHLpcASuFgdj8k0ra8cyHMn6dV)yf6y49yzmuQLxHsWyg20phJiH3DLPpbDrSs5fYFwPwHwYTbWuDxrYmnC8kxMRNJRibJAmySQEGgRIuHMTgqZDvbgcAneVa4kkqs68XFwfYtWktFsLJbDrSsfOlIvOWiiJvIxaCf6iaEbSqZg9H3FScDm8ESmgk1YRqjymdB6NJrKW7UY0NGUiwP8c5RiLAfAj3gat1DfjZ0WXRS9wwC2axg27XxZFC)oEWvHMTgqZDvHRbHSv4oGyffijD(4pRc5jyLPpPYXGUiwPc0fXku1GqMXQ(hqScDeaVawOzJ(W7pwHogEpwgdLA5vOemMHn9ZXis4Dxz6tqxeRuEH8v0sTcTKBdGP6UcnBnGM7Qcme0AiEbWvuGK05J)SkKNGvM(Kkhd6IyLkqxeRqHrqgReVayJDi)HRqhbWlGfA2Op8(JvOJH3JLXqPwEfkbJzyt)CmIeE3vM(e0fXkLxiFkwQvOLCBamv3vOzRb0Cxv2axg27XxdCMggwrbssNp(ZQqEcwz6tQCmOlIvQaDrSIBGld794gRWzAyyf6iaEbSqZg9H3FScDm8ESmgk1YRqjymdB6NJrKW7UY0NGUiwP8c5tbl1k0sUnaMQ7ksMPHJxz7TS4SbUmS3JVM)4(DsVsIXQMXoKXU9wwC2a)Na8cCN0RKySdAqg7qg72BzXzd8FcWlWD8GZyvZytp3zZWJdE9xwx0mCn9ChgUWWa4BdGg7Wg7WvOzRb0Cxv2m84Gx)L1fndROajPZh)zvipbRm9jvog0fXkvGUiwXndpoyJ9xmwkKMHvOJa4fWcnB0hE)Xk0XW7XYyOulVcLGXmSPFogrcV7ktFc6IyLYlKp8LAfAj3gat1DfA2Aan3vfMxaSMaAvv)s4QsnjvrbssNp(ZQqEcwz6tQCmOlIvQaDrScDVaynbKXQQDj0yvxAsQcDeaVawOzJ(W7pwHogEpwgdLA5vOemMHn9ZXis4Dxz6tqxeRuEH8hWsTcTKBdGP6UcnBnGM7QsgSED7Xc8kkqs68XFwfYtWktFsLJbDrSsfOlIvOeS2yD7Xc8k0ra8cyHMn6dV)yf6y49yzmuQLxHsWyg20phJiH3DLPpbDrSs5fYxDxQvOLCBamv3vOzRb0CxvYG1RkV5yffijD(4pRc5jyLPpPYXGUiwPc0fXkucwBSQRBowHocGxal0SrF49hRqhdVhlJHsT8kucgZWM(5yej8URm9jOlIvkVqZgl1k0sUnaMQ7ksMPHJxrD2y5has4oBGld794R5pUFhKCBamzSQzS5)bsVsIdme0AiEbWommEAsWyvTXckNmw1m2HmwKGmqUCYEmgs4g7aySdzSibzGC5WqqiXyhSXoKXM)hi9kjoWqqRH4fa7WW4PjbJDamwq5KXoSXoSXoSXQ6bASuKIvOzRb0Cxv4AqiBfUdiwrbssNp(ZQqEcwz6tQCmOlIvQaDrScvniKzSQ)ben2H8hUcDeaVawOzJ(W7pwHogEpwgdLA5vOemMHn9ZXis4Dxz6tqxeRuE5vuV4Y5bWR7YBb]] )

    storeDefault( [[SimC Brewmaster: precombat]], 'actionLists', 20180128.151850, [[dqJrcaGEQQ0UqG2gskZgW8fi3KQCxQkCBPStQSxYUPy)cLHHIFdAOuvQbledxqoOq6yi1crKLkvTyGwUOEiI6PQwMi9CfMivvmvrmzfnDLUOq1LHUosSoKuTve0MrP2ok5Xu6RuvY0qaFxaoSK3svrJwQmob0jrOEgvvDAuDEeY3eu)vG61ijlALOh3uGa4uG6UQH6N3ihlcPmgqRglMPESiHYOf2aRv)HqlVa4(Two0ixk1cuVhbWAGYLYqhidDknbt9NaeGjS(TzEOvxpQD5qZqjYrRe94MceaNIKEuqoaFjspeC5qJoXMj3wlmRBGgu3dojSYUQH66UQH6bzzZMHXAzZ2N(gUCOXhbL17raSgOCPm0HPz07XbKs2IdLOvNChAPYdYcBOzfOUhC6QgQRvUuLOh3uGa4uK0JcYb4lr62oEWGuYJvNyZKBRfM1nqdQ7bNewzx1qDDx1qDYD8yrirjpw9EeaRbkxkdDyAg9ECaPKT4qjA1j3HwQ8GSWgAwbQ7bNUQH6ALZFLOh3uGa4uK0JcYb4lr62oEWbuSqDIntUTwyw3anOUhCsyLDvd11Dvd1j3XJfXxfluVhbWAGYLYqhMMrVhhqkzlouIwDYDOLkpilSHMvG6EWPRAOUwT6(bzxuawrsRe]] )

    storeDefault( [[Brewmaster: Default]], 'actionLists', 20171113.173222, [[dWJrgaGEiIAteL2ff2MezFKs1SHA(qQYVb9ybFtiDyQ2jPAVQ2Tu7xc)esLHPeJdIKZdPmujPQbludNahujDkicDmICAGfsqlfcTyfwojpeIYtrTmHyDssMievtLOAYkA6IUif5zuuxg56suVwsCBLAZefBNuYNHK)sOPbrW8KKIrkjL(oPy0Ksz8qQQtcbpNsxtsQCpjvlss5qqKAuqe5lD5Nn1(atZl8mlGcahdqYEcG91JucPoJCsgVmoVWZisyYT01JSifvssYSHuuPisMpZbfqqE(8AibW2E5xx6YpBQ9bMMx4zoOacYZjefkmza6KuQYcs751bads0oBfqUsuBEpfTPcuHoJqpbbpHQZnSPZ6(MoZcixvexTEplI5ubQqNrKWKBPRhzrQKuuJfZpVEKl)SP2hyAEHN5GciipNquOWKracXtOM2welBrmsQiEuwgzmgyiCIlBtJYckIrp0RioDfkknsWMetO4eqvt9slfXiXZRku2ZTVP6q8uuJRoVoayqI2zbWea7Zi0tqWtO6CdB6SUVPZvpmbW(mIeMClD9ilsLKIASy(51nF5Nn1(atZpoZbfqqEo9UcOrjBacXtOM2aOGTTcOfhksJrqBUcfzRhGq8eQPnakyBRaAXHI0ye0MRqrwXTJ(Yc6aCdAuItF7OirZwTVCEDaWGeTZafSTvaT4qrAoJqpbbpHQZnSPZ6(MoJGc22kGUiwOI0CgrctULUEKfPssrnwm)86iHl)SP2hyA(XzoOacYZLTK4KKHAlqlYEEvHYEU9nvVMqfPz72KuvveJCsgQTaTiBTZRdagKODo4ySOhsaSfXaBEgHEccEcvNBytN19nDg5KmuBbAr2ZisyYT01JSivskQXI5NxV6U8ZMAFGP5fEMdkGG8msNoM60yG9qfy5uma3dOb1(attz9qc0IePM2aYQDPZRku2ZTVP61eQinB3MKQQIyo9E6Qzr8k6mv786aGbjANdogl6HeaBrmWMNrONGGNq15g20zDFtN507PRMfXROZ0zejm5w66rwKkjf1yX8ZRx6YpBQ9bMMx4zoOacYZPJPongypubwofdW9aAqTpW0uwpKaTirQPnGSAx68QcL9C7BQEnHksZ2TjPQQigzW9aweVIot1oVoayqI25GJXIEibWwedS5ze6ji4juDUHnDw330zKb3dyr8k6mDgrctULUEKfPssrnwm)86rV8ZMAFGP5fEMdkGG8msNoM60yG9qfy5uma3dOb1(attz9qc0IePM2aYwx68QcL9C7BQEnHksZ2TjPQQiMtVNUAweZYRDEDaWGeTZbhJf9qcGTigyZZi0tqWtO6CdB6SUVPZC690vZIyw(zejm5w66rwKkjf1yX8ZRJux(ztTpW08cpZbfqqEoDm1PXa7HkWYPyaUhqdQ9bMMY6HeOfjsnTbKTU05vfk7523u9AcvKMTBtsvvrmYG7bSiMLx7mIeMClD9ilsLKIASy(mc9ee8eQo3WMoVoayqI25GJXIEibWwedS5zDFtNrgCpGfXS8NppR7B6SqfPz72KuvveJCsgVmoF(d]] )

    storeDefault( [[Brewmaster: Defensives]], 'actionLists', 20171113.173222, [[dOJweaGEkf1MiGAxk12ivSpOaZwWVHCBL06GcANI0Eb7wL9trJck0WiKXrQepMOHsPGbtjdxvoib1PiahJcNhPwiuAPeQfJKLl5Huk0tPAzIWZryIukzQKQMSQA6KCrOOtl1ZuIUUqEnbAvuQAZc12PuKVjI(mIMgPs13f1ijG8xOA0KY4vcNKGClkL6AKkP7rPYpjvkxg1Hvmya6bhZBOc8hWcU)yzpH2MhvJoinHo6c4PZkdo2IZRdHIlm00YwCmFeTnXeGBloEIckal4I5apemKMqKrsddJLBJKgjmwcUyE(067vgCmAAjrOWhLV9lQ6y6(iXPkoVLAtrYe4RZctlBBAjrOWhLV9lQ6y6(iXPkoVLAtrYe4X1ivn6MGPLamTS30sIqHpkF7xu1X09rItvCExSuBksgCHLQgDeGEi1a0doM3qf4pGf80zLbhByKcAAPBlmTWwCgCXCGhcgstiYqhJKBrlbxO73YrHkWp0XGlmvhAfn4uHrkioAbovXzWDz1pf4sek8r5B)IQoMUpsCQIZBP2uKmHDIafKMa0doM3qf4pGfCxw9tbo4PZkdUnevDmDFKMwylodUnopvJoWbxyQo0kAWFrvht3hjovXzWf6(TCuOc8dDm4I5apemKMqKHogj3IwcEwJpX88PbFIuiqbPlb9GJ5nub(dyb3Lv)uGlrOWhLV9lQ6y6(iXPkoVLAtrYe2jrOWhLV9lQ6y6(iXPkoVLAtrYe4RZcWfMQdTIg8UqhHG9HtvCgCHUFlhfQa)qhdUlR(P0t)yWv9kdE6SYGluHocb7Z0cBXzWfZbEiyinHidDmsUfTeCX88P13Rm4y00sIqHpkF7xu1X09rItvCEl1MIKjWxNfMw220sIqHpkF7xu1X09rItvCEl1MIKjWJRrQA0nbtlbyAzVPLeHcFu(2VOQJP7JeNQ48UyP2uKm4zn(eZZNgCcz1pfOGuDh0doM3qf4pGf80zLbhZfpoyAjqtTcUyoWdbdPjezOJrYTOLGlmvhAfn48IhhW1MAfCHUFlhfQa)qhdUlR(PaxJNqFK4epnU4TefDkmWodbgJA8euA7ph3YwHb2rOg1EuQrki(dL5Y(KBD1EnEc9rIt804I3su0Pea4zn(eZZNg8jsHafOa3Lv)uGdkaaa]] )

    storeDefault( [[Brewmaster: Combo ST]], 'actionLists', 20171113.173222, [[dOdUdaGAcQA9eaBIuQ2fP61kY(ianBsUncRJaQDcP9sTBK2VQ0Oiqmmbnocihw0qji1GvPgUcoOaDkckoMQ6BeYcvulfrwmuworpKGkpf8yHEoetKGstvsMSkMUuxuaBJuCzuxxLSrcIoTsBws1ZquFgQ8vcunncs(oPu(RcnpcKgnHAveeoPKYljL4AKs68QIvsGYYGQ(Te7VRmeGMyk(4zdquUdTbdOjbBywYAJirAwkWV3cxHaR8EdvgewUEEPApBGeR4eHnk(WVO))tw)l6J)t2ajoppvlbBWqWyVfkIRm63vgcqtmfF8Sbik3H2qNkM26yQmovU6XyHaROZ0etXhTNXElu9jg3icrIiwxY55zSxcwqXfpcXxxRgqtc2WSkJtLR(9gA5oXV3cIwaHXqqSvT9JbmvgNkx9isl3j2ajwXjcBu8HFnFr6HKnuJE2y2fPbAHYgiX55PAjydgGOCh6QNb2aYseDBu8UYqaAIP4JNnGMeSbTW4EVbIerSbsSIte2O4d)A(I0djBOg9SXSlsd0cLnar5o0gmeeBvB)yyIXnIqKiIDBuYUYqaAIP4JNnGMeSHzvgNkx97n0YDInqIvCIWgfF4xZxKEizd1ONnMDrAGwOSbik3H2GHGyRA7hdyQmovU6rKwUtSBJkuUYqaAIP4JNnar5o0gmqIvCIWgfF4xZxKEizd1ONnMDrAGwOSHGyRA7hdYleXlf3OWNhEuBl9yanjydKUqeVuCV3cwE43BbFPh3gvRUYqaAIP4JNnar5o0gom2v966tmUreIerS(1GbsSIte2O4d)A(I0djBOg9SXSlsd0cLneeBvB)yatYzlESuFS(kzdOjbBywYzl(9Uu)9wixj72OACLHa0etXhpBanjydvlow(El0PIWajwXjcBu8HFnFr6HKnuJE2y2fPbAHYgGOChAdmLL4E0JxsjtBbm0qqSvT9JHEXXYXHur42TbyGJBQwbi7TqnkEncKBBa]] )

    storeDefault( [[Brewmaster: Combo AOE]], 'actionLists', 20171113.173222, [[dCtQdaGAcHwVIKEjHu7ceVwa7trkZMu3MO2Pi7LA3i2pa)KGWWiYVf1qjO0GvudxqhePCmfwNIuTqHSuKQfdLLtYdjK8uvpguphQMibvMksmzGMUsxesDyPUmQRdrBKGQghbjBwr8zH60s(kbPMgbfFNq0ZaPVbHrJKgVIeNuG(lKCncbNNqTscIwgG2gb2dtXhnPX0mOJ8pSQcxF)ulZ(rkwKYn(YQPdywuzzSmGzAcbAF6SMBC2jGsdeJXakKbIbWbu)hYWvRRP2BLjobuGq5tdERmb3uCAyk(OjnMMbDKFQLzF0tjuNblsmGzrZX(0zn34StaLgcgiGib1pibSG7nR8jzc7FyvfU((0WkDTI95PeQZGfjgvao2RtanfF0KgtZGoYp1YSVO5yaZxUXP6tN1CJZobuAiyGaIeu)GeWcU3SYNKjS)Hvv467tdR01k2pahJcxUXP61jOMIpAsJPzqh5NAz2xuulaZriv4RpDwZno7eqPHGbcisq9dsal4EZkFsMW(hwvHRVpnSsxRyFyQfkmKk81RtcJP4JM0yAg0r(PwM9JuCVubmNNayw4lf7tN1CJZobuAiyGaIeu)GeWcU3SYNKjS)Hvv46dYyiNmbsaogfUCJtfcYqFAyLUwX(ykUxQOYtqnPuSxNebtXhnPX0mOJ8pSQcxFF6SMBC2jGsdbdeqKG6hKawW9Mv(KmH9PHv6Af7RqItTiXOeXgKrjYIa6NAz2NosCQfjgWSq2GmGzHUiGEDsGP4JM0yAg0r(hwvHRptyvSyiWivkMSttYNoR5gNDcO0qWabejO(bjGfCVzLpjtyFAyLUwX(BfZkuHTw2p1YSpLkMvaMf2wl71jeMIpAsJPzqh5FyvfU((0zn34StaLgcgiGib1pibSG7nR8jzc7tdR01k2ht3WbYixu4RQcW(PwM9J0nCGmYfW8xvfG961x44jns96iV2]] )

    storeDefault( [[Brewmaster: Standard ST]], 'actionLists', 20171113.173222, [[d0d9eaGAru16fuPxQiQDjuBJiTpbLA2KmFfH(TOESkUnP6VI0ovQ9sTBe7hcJsePgMqgNkHUmQHQsWGHOHtkhuqoLGQCmiDoreTqL0sjklgjlNWdve5PGLbvwNiQmrruAQQutwHPRQlsuDAPEgs11vuBuqv9nKYMjITlO47QK(QIGPjOI5jIIxRi9COmALy8QeDsr4ZcCnreopu1kfuYHLSjrKSr9Tb5KIsXdVAa04txQoCRVZeVXj9Ig2LoByvWx1lSNfjhcKWxKrjgiqc3gKXkUWyVXfHsdffLEmknuCO0nahrR9gme68DMG5BVr9Tb5KIsXdVAyx6SHjZbiqc6f2IbzSIlm2BCrOsrPfhr3qcYOp1NfgizcBievR6hVHPCqkMEHTyaoIw7n43BC(2GCsrP4HxnahrR9ggm1SejXt5Gum9cBjEwBItCWuZsKeJPXNUuPdw1HHf4JN1miJvCHXEJlcvkkT4i6gsqg9P(SWajtyd7sNnSk46xqGmlbbYWVfSHquTQF8gOeC9lPzjPsAb73B6(2GCsrP4HxnahrR9gmiJvCHXEJlcvkkT4i6gsqg9P(SWajtyd7sNnSQQZ088Jaj8IEkBievR6hVbkvDMMN)uSx0tz)Eho(2GCsrP4HxnahrR9go5SAKVsI1MfTe8njiLsWxJplLiGXsMtoRg5RKyTzrlbFtcsPe814ZsjcySu96sdHOAv)4n8Dals1kLUHeKrFQplmqYe2GmwXfg7nUiuPO0IJOByx6SH7oGfiqEHsP737KW3gKtkkfp8Qb4iAT3WxKPnjiPW(kiGfXLEEM8HT2SOLGp9xem2swnmeIQv9J3aFPMkpAsq6uoWqcYOp1NfgizcBqgR4cJ9gxeQuuAXr0nSlD2G8l1u5rtcqGCYCGFVL6BdYjfLIhE1aCeT2BWGmwXfg7nUiuPO0IJOBibz0N6ZcdKmHnSlD2GSzSLMeGazyvdgbYj0KHHquTQF8geZylnjin5RbNETjd)EtZ3gKtkkfp8Qb4iAT3GHquTQF8golDk1Sa7nKGm6t9zHbsMWgKXkUWyVXfHkfLwCeDd7sNnmPLgbY1zb2737l6BdYjfLIhE1aCeT2BWGmwXfg7nUiuPO0IJOBibz0N6ZcdKmHnSlD2WKwAeiNqfg2qiQw1pEdNLo9Afg2V3jPVniNuukE4vdWr0AVbdYyfxyS34IqLIsloIUHeKrFQplmqYe2WU0zd3DalqG8cLshbYKgn8meIQv9J3W3bSivRu6(9Bizzj1S69QFBa]] )

    storeDefault( [[Brewmaster: Standard AOE]], 'actionLists', 20171113.173222, [[dOJieaGAQe16POWlPsv7srTnk0SP08PsX3GKlJANIAVKDJ0(vOFsrPggv8BqoSKHsrLgSImCQQdIOofvcDmL8yqTqHAPuWIry5cEivs9uvltP65q1ePOIPcPMSith4IqXRvGNbrxhkTrkQYPLAZuL2UcY4OsYxPsLPrrrFxb1TfYFvkJgcJNkLojvXNrKRrrjNNISsQeSokQQrrLiRLqRJHwewoPyDZH9wyTafRF4q7d01nWwUWzL3DwOwRfY5fQ1(cP(9z4USTzuGgIQ8UrxPtgg0quCHw5LqRJHwewoPy9dhAFGUozI22at6SB9TqPMsABats3dn1WfakOtHOSUb2YfoR8UZY4c1Sds9CfX6yCRVfk1usJtUNjjGY7cTogAry5KI1pCO9b66gylx4SY7olJluZoi19qtnCbGc6uikRNRiw39mPXPhv4i0jt02gysFatAdpQWriGYifADm0IWYjfRF4q7d0tmbwVENhWK2WJkCeZy9DJBsmbwVENX9z4USBj22dXbtZy91nWwUWzL3DwgxOMDqQ7HMA4caf0PquwNmrBBGjDIaxaeBqE382bwpxrSECGlaIXjiVJtMxhybu2mfADm0IWYjfRF4q7d01nWwUWzL3DwgxOMDqQ7HMA4caf0PquwNmrBBGjDcBbpaclydhe6bSEUIy9yBbpaclyC6GqpGfqzZsO1XqlclNuS(HdTpqx3aB5cNvE3zzCHA2bPUhAQHlauqNcrzDYeTTbM0dyXr0usBUCL4THBAspxrSUbS4iAkPXjxOs84K7AAsaLnk06yOfHLtkw)WH2hORtMOTnWKomIEJaBahO7HMA4caf0PquwpxrSURr0JtXyd4aDdSLlCw5DNLXfQzhKcOmkHwhdTiSCsX6ho0(aDDdSLlCw5DNLXfQzhK6EOPgUaqbDkeL1jt02gyshgrVnCneRNRiw31i6Xj3vdXcOSReADm0IWYjfRF4q7d01nWwUWzL3DwgxOMDqQ7HMA4caf0PquwNmrBBGjDqtIdB(LnspxrSo6MehgNm3Ygno5slxuab0ZveRhh4HJkCahm)XPdkAQcPXjYMngbKa]] )

    storeDefault( [[IV Brewmaster: ST]], 'actionLists', 20171113.173222, [[dytfdaGAqvTEqrEjOGDHk51sI9bk0SfCBrANGSxYUrz)c1WeX4af1qbLQblKHJKoivPJPKVHQSqLYsPQwmfwoIld9uvlts9CknrqjnvkAYi10L6IsspwINrL01PIncQOTcQKnJQ68ufNg4RGk1NrfFNkXHv8xLQrJeRduHtsLAAGs5AOs5EOs1kbLyBGQ8BrTwYuhAsrD3WvC0gbDjDSnsGJ4OBQdRi)Xj0At3hd4yrbvNS4Twlx5AXBvVCv)fcGARR7T0GmZktbTKPEv2yeqATPdnPOomGCIJE6yPO)cbqT119AacG2JEfKZUnDSu0DZObLPZeDwMH6(yahlkO6KfVvIUpAZoKcALPA1cQwM6vzJraP1Mo0KI6BHPuj70XrVjGkO(lea1wx3RbiaAp6gHPuj7072MaQG6Uz0GY0zIolZqDFmGJffuDYI3kr3hTzhsbTYuTAb5Qm1RYgJasRnDOjf13i40uIJY8JJGtab1FHaO266Enabq7r3GGttzpZFNpGG6Uz0GY0zIolZqDFmGJffuDYI3kr3hTzhsbTYuTAbbBYuVkBmciT20HMuu33XsbW4ehbldnghb3agT(lea1w3WHpFUiowkagND4p04UlagnxeKpbTugJaQ71aeaThDIJLcGXzh(dnU7cGrR7MrdktNj6Smd19Xaowuq1jlEReDF0MDif0kt1Qfe3KPEv2yeqATPdnPOUjGdsIJG9jKQ)cbqT1rgs44HRIdHGSoocg5ECe84MUxdqa0E0BahKStDcP6Uz0GY0zIolZqDFmGJffuDYI3kr3hTzhsbTYuTA16NkwataattdYmbvdpywTea]] )

    storeDefault( [[IV Brewmaster: AOE]], 'actionLists', 20171113.173222, [[dOt6daGAkOA9iQ4LueTlPIEnfP9rH0Sf1TLshg0ov0Ej7gL9tf)KcIHjW4quY3qKHsbYGf0Wb4Guuxg6ykCEQuluQAPuYIPulhPhsbQNQAza65u1ePaAQOQjJW0LCruPtR0ZKkCDPyJua2kfK2SuPTJOspwKVIOktdrv9DkeRdrP(lqnAuX4Pq5KujFgixJIW9OGYkPq12qu8BHwdXRpHTOUld1jSNIgPf6lKs2oHMneU6gi2f2Kl1RBHze6rnbgmingJo6CqAaC0H(t0fqPRBovBK5fVMdXRZLbTZiH61NWwuNRXaKJeldKtOjrq6prxaLUUz7nVLBD0yaYrILbcSPiiDxmInbRivNfzOUfMrOh1eyWG0iq3c9XgAc9IxLknbkEDUmODgjuV(e2I6Meb5e(wONJ(t0fqPRB2EZB5w3ueeyFl0Zr3fJytWks1zrgQBHze6rnbgminc0TqFSHMqV4vPsZoeVoxg0oJeQxFcBrDdMZ6e23q9L(t0fqPRB2EZB5wpXzbB3q9LUlgXMGvKQZImu3cZi0JAcmyqAeOBH(ydnHEXRsLMKV415YG2zKq96tylQ3tryXXjm21j0awkQ)eDbu6WuTKlcMiwDAtryXbCSl4UlfDcnQt4q3S9M3YTUnfHfhWXUG7Uuu3fJytWks1zrgQBHze6rnbgminc0TqFSHMqV4vPsttiEDUmODgjuV(e2I6wnEoldKtOXHeOti5Tmc9NOlGsx3S9M3YToTXZzzGaB4qceSrwgHUlgXMGvKQZImu3cZi0JAcmyqAeOBH(ydnHEXRsLMKr86Czq7msOE9jSf15xqi1j0GG5w9NOlGshzifK7otnukYkNqJAyoHKXeogx3S9M3YTETGqkyaWCRUlgXMGvKQZImu3cZi0JAcmyqAeOBH(ydnHEXRsLMKeVoxg0oJeQx)j6cO01TWmc9OMadgKgb6UyeBcwrQolYq9jSf17ZWKPXMYj8fDnf1TqFSHMqV4vPsL(bGPfMxYbwBKPjqYqwQKa]] )

    storeDefault( [[IV Brewmaster: Combo]], 'actionLists', 20171113.173222, [[dWtRfaGAvf06vfHxQQq7II2gOk2Niz2cnFvf5WQCBO65q2jLSxPDJY(j6qQcXWOuJtvu1MivmuvrQbtYWHIdQQ0PvCmcESGfsblfuwmPSCu9qvf1tPAzuO1PkkMOQcmvvPjdY0v6IQQ6ZIQlJCDrzJQIKTQkuTzvbBNuPVtQ6RQcPPPkIMNQOY3eP(lHgnuA8GQ0jbvEgOQUMQO05vvzLQcLxlIFdCf6BDRdNQd3Jlvg4KE8dTe)zKQpdW1a1)a6HllU1qDyuKoevlJ2cPfeeGVPqAbJcWVUh4dMTE9VHDamuFRLqFR)NDArcQgQBD4u9ps5sLJFiS19aFWS1FePcdN0vmpazkyQfVqciBfrlFsiP6tFsQcaqecONzIjJpp8By5IACsVza7XZjKu9CsLX6F1M4S)QNq5Ii8dHToCmOjClGxNbyuDyuKoevlJ2cPfSRdJqGmEGq9TB3AzSV1)ZoTibvd1ToCQUH4fsazRu5lFsO6EGpy261)QnXz)vxlEHeq2kIw(Kq1HJbnHBb86maJQdJI0HOAz0wiTGDDyecKXdeQVD7wl4336)zNwKGQH6whov)DYjUu90xeVUh4dMTogoPRyEaYuWulEHeq2kIw(Kq1)QnXz)vFNCIlI5I41HJbnHBb86maJQdJI0HOAz0wiTGDDyecKXdeQVD7wRNSV1)ZoTibvd1ToCQ(F4fteanSCP6JuEDpWhmB9lSJUKiXi8HqsvkPsqQ0rQcaqecONzQfVqciBfrlFsitoHFddjvPKkBPshPkaariGEMzcLlIWpewtoHFddjvPKk76F1M4S)QtWlMiaAy5IjuED4yqt4waVodWO6WOiDiQwgTfslyxhgHaz8aH6B3U16z7B9)Stlsq1qDRdNQ)zSJuziJJ26EGpy26xyhDjrIr4dHKQusLGuPJufaGieqpZulEHeq2kIw(KqMCc)ggsQsjv2sLosvaaIqa9mZekxeHFiSMCc)ggsQsjv21)QnXz)vpGDe1Y4OToCmOjClGxNbyuDyuKoevlJ2cPfSRdJqGmEGq9TB3Abp9T(F2PfjOAOU1Ht1nWPBXkvGhKQNA4uDpWhmB9lSJUKieyntOCre(HWkvPKkBPshPkaariGEMPw8cjGSveT8jHm5e(nmKuLsQSLkDKQaaeHa6zMjuUic)qyn5e(nmKuLsQSR)vBIZ(RUgNUfRi4bXhgovhog0eUfWRZamQomkshIQLrBH0c21HriqgpqO(2TBTs336)zNwKGQH6whovhwgc7WYLQh7GiP6rhguDpWhmB9aaeHa6zMAXlKaYwr0YNeYKt43WqsvkPYwQ0rQcaqecONzMq5Ii8dH1Kt43WqsvkPYU(xTjo7V68me2HLl(HhejQFyq1HJbnHBb86maJQdJI0HOAz0wiTGDDyecKXdeQVD72TUJHcZfNN42bWQLr45572ca]] )

    storeDefault( [[IV Brewmaster: Defensives]], 'actionLists', 20171113.173222, [[dOtHeaGEHOAtcj2fGTHuk7tPsZwWYivDBLYVbTtPQ9cTBvTFkgLsvnmKQXjeXHvzOcHAWuA4i5GKcNsPkhJkDEQYcjvwkqwmrwUKtR4PIEmHNlLjkK0ubQjtutNKlskAvcPUmQRtv9nPsBvikBwO2UqGNHuYNr00ec57kzKcr6VimAQy8sfNeP4wkv4AiLQ7rk51KsToHG(Psfn6IGXmQC85huOomtkwmxyI8tnWh71tBrcM93gJjnrMXQR4121uCfHgBu5y(BteWnmbXb(Am2RNUBxxxxAb421vVlTWeeFYEGNngZ9nwbegKHRhGYVMyV5jjKkEbiCUIKBeBxhJDhgRacdYW1dq5xtS38KesfVaeoxrYnI46eQb(xWy3ZyJ2yfqyqgUEak)AI9MNKqQ4fqXcNRizm1qOg43qWyVlcgtn)tkWYOom7VngtDHtOTXUZogRUIxyMIAOuykGWGmC9au(1e7npjHuXlaHZvKCZy1YyPBSrXyBQJKKlakUe8Ri2Uoeoug7UAzS6PJPgstyuEykfoH2eWoesfVWKMxEeNcwy(WNXeeh4RXyVE6UDDPJjiUb9lb3qWOcvyVEemMA(NuGLrDy2FBmMrSFnXEZtAS6kEHzkQHsHjMAinHr5HjLFnXEZtsiv8ctAE5rCkyH5dFgtqCGVgJ96P721LoMG4g0VeCdbJkuH90cbJPM)jfyzuhMPOgkfMcimidxpaLFnXEZtsiv8cq4Cfj3mwTmwbegKHRhGYVMyV5jjKkEbiCUIKBeBxhmxo8dIpzpmBIAOuysZlpItblmF4Zy2FBmM0uWVP98gRUIxycId81ySxpD3UU0Xee3G(LGBiyuHPgstyuEyof8BAppHuXlmbXNSh4zJXCFJvaHbz46bO8Rj2BEscPIxacNRi5gX21Xy3HXkGWGmC9au(1e7npjHuXlaHZvKCJiUoHAG)fm29m2OnwbegKHRhGYVMyV5jjKkEbuSW5ksgvyFeHGXuZ)KcSmQdZ(BJXuZouCWyJ0R2Wmf1qPW0HVW8KenkhUyab0)vg7UAzSUrXy33yD4lOCaK54rmkJDxTm2M6uaNsDcTjOGlUm2On2Ua0UXgTX6WxyEsIgLdxmGa6)kJDpm1qAcJYdtUdfhiCUAdtAE5rCkyH5dFgtqCGVgJ96P721LoMG4g0VeCdbJkuHkmtrnukmrfI]] )

    storeDefault( [[IV Brewmaster: Default]], 'actionLists', 20171113.173222, [[d0tTfaGEvQuBsKyxIQTbk2Nkf63eMnrxg6MQu1Iuv62s68Gs7eP2RYUb2Vu(jjjddjgNkv0PrmuvQKbRIHdQoOQQtPsP6yK4WuTqvYsLkTyqwoPEOQcpf1YOuwNuvtuK0urstwvMUWffLUQkL4zsvUoL0ZPyRQkAZKuTDsIxlv8zkvttLs67IuJuLI8xrmAvkLhlXjPehIKuxtLI6EKuwPkf8nrXOuPcpLrDmdhlexsUBpicWOTbZDoovuD3Qm214UOeDdoABuuYOOO0lxjJInLEJ5IMapgp(VeebWmQJwzuhNf4qs8TRXCrtGhJdHD7smNacuRTcpmJ)Hissa7ydC01j3MdEjMqt6GJTaEKIhc9yGaGJ7Is0n4OTrrbgLm5u6nM2R4ygo6625MCWRD4qt6GlgTTrDCwGdjX3UgZfnbEmoe2TlXC4IGiaM2nm(xB3mg4vunH8LK21J)Hissa7y4IGiaJTaEKIhc9yGaGJ7Is0n4OTrrbgLm5u6nM2R447seebyXO7nQJZcCij(21yAVIJtfvhbgIkOzmx0e4X4WbDia7TtkTJvdM8q1rGHOcAANuAhv3o3r7eUebroK0lDewJKIOcjYrGdjXx7Ks7axJQKyV8YvYHKEPJWAKycnPd2o3(4FTDZyGxr1(EPX0v3eOUF7KkQocmevqZ3X)qejjGDCXLYeVeebirsmXylGhP4Hqpgia44UOeDdoABuuGrjtoLEJVx8O9ko(sJPRUjqD)2jvuDeyiQGMfJ(wh1XzboKeF7AmTxXX3IbBhlbwnJ5IMapgp(hIijbSJTAWesGvZylGhP4Hqpgia44UOeDdoABuuYOqzCx0iSQlOzuxSy038OoolWHK4BxJ)Hissa74IlLjEjicqIKyIXCrtGhJdxIGihs6LocRrsruHe5iWHK4B8V2UzmWROAFV0y6QBcu3VD(quHeTZVQY(DCxuIUbhTnkkWOKjNsVXwapsXdHEmqaWX0Efh)HOcjgFV4r7vCSLpBNlnMU6Ma19BNpeviXIrdZOoolWHK4BxJ)Hissa74IlLjEjicqIKyIXCrtGhJvD4see5qsV0rynskIkKihboKeFTtkTJxcIkyccWkbnQPm(xB3mg4vuTVxAmD1nbQ73oC4GNRFTdt974UOeDdoABuuGrjtoLEJTaEKIhc9yGaGJP9koMdh8C9RDyQJVx8O9ko2YNTZLgtxDtG6(TdtDXOZmQJZcCij(21yUOjWJXQoCjcICiPx6iSgjfrfsKJahsIV2jL2XlbrfmbbyLGM25gBhLX0EfhZHdEU(1o)Qk74FTDZyGxr1(EPX0v3eOUF78HOcjAhM63XDrj6gC02OOaJsMCk9gBb8ifpe6Xabah)drKKa2Xfxkt8sqeGejXeJVx8O9ko2YNTZLgtxDtG6(TZVQYUyXyAVIJT8z7CPX0v3eOUF7KkQUBvgl2aa]] )

    storeDefault( [[SimC Windwalker: default]], 'actionLists', 20180107.133322, [[dq0HnaqisvArQi2es0Our6uQOAwibPDrIHPsoMk1YekptfOPPcW1qcSnKq9nHuJJufDovqTojH5jbUNq1(ivHdkPSqjOhsjnrKqCrvugPkG6KQq9svazMQGCtsLDsPgksqTujvpLQPsj2QkKVkj6TcjDxHe7f1FrQbRQdR0ILOhtXKf5YeBMu(SK0OvWPb9AsYSfCBfTBO(nKHtsDCKqA5iEUOMUuxxH2oPQ(UqCEj06rcI5JK2pW8nBHDxTyGBasHSneHz7yu8Hz3ENc7oCAf8vcXPiBqLqQa8jrBhdn71LGSzHTJDDh9DSy6PsSyh8WXUz3neO6MD2RzAicNzlS9nBH9ZWBzqsCHS7gcuDZo71kHbyxK9SAzj0dlorNBcuLW(X4e0SnIWogHf21HshTe7DkSZU9of2D1Ysa)bEXjW7nbQsyVUeKnlSDSR7OVVyVUKrJeJKzlCZU1bXOshsFzk4MlzxhkzVtHDUz7ySf2pdVLbjXfYUBiq1n7dYg6bf1Mg8fa(lfkG9ALWaSlYEJgnd0inAvlzUSFmobnBJiSJryHDDO0rlXENc7SBVtHDlOrZa4rAG)aTK5YEns1m7qCle93q8dFrHQ200dYg6H4xkua71LGSzHTJDDh99f71LmAKyKmBHB2Toigv6q6ltb3Cj76qj7DkSZnBFq2c7NH3YGK4cz3neO6M9YrnnLSqemSlQmQg8uPc(YrnnLCJitAzj9a9It0AqIOmQg8uPc(tbVEbFVbb3kzHiyyxurWBzqsGNsW3eiwL0kQjiJYwfgGDrLr1G)CWtLk4lh10ukdiukmMBLr1GNkvW3lPQ0knCk0nIobfWxqCWtXxSxRegGDr2vJAicZ(X4e0SnIWogHf21HshTe7DkSZU9of2PA00UUmgnTOsHrneHJcvc71LGSzHTJDDh99f71LmAKyKmBHB2Toigv6q6ltb3Cj76qj7DkSZnBFaSf2pdVLbjXfYUBiq1n79sQkTsdNcDJOtqb8feh8hM9ALWaSlYEJgnd0in6KS9a7hJtqZ2ic7yewyxhkD0sS3PWo727uy3cA0maEKg4PiY2dSxxcYMf2o21D03xSxxYOrIrYSfUz36GyuPdPVmfCZLSRdLS3PWo3SnfWwy)m8wgKexi7UHav3SFk47ni4wjlebd7IkcEldsc8ucEdcfsOiyLSqemSlQqK5cXzWxqCWFb(ZbpvQGVCuttjlebd7IkJQzVwjma7ISB2qGEnneHPdWCZ(X4e0SnIWogHf21HshTe7DkSZU9of2PA00UUmgnTOADdbWxZ0qeg8hcM7OqLWEns1m74DkXpXHtRGVsiofzdQesfGplebd7INWEDjiBwy7yx3rFFXEDjJgjgjZw4MDRdIrLoK(YuWnxYUouYENc7oCAf8vcXPiBqLqQa8zHiyyxKB2MIzlSFgEldsIlKD3qGQB21l47ni4wjlebd7IkcEldsc8uc(tbF5OMMsUrKjTSKEGEXjAnirugvdEQubVbHcjueSsUrKjTSKEGEXjAnirumdlPQKbFCWhd8NZETsya2fz3SHa9AAicthG5M9JXjOzBeHDmclSRdLoAj27uyND7DkSt1OPDDzmAAr16gcGVMPHim4pem3rHkb8NEFo71ivZSJ3Pe)ehoTc(kH4uKnOsiva(SODc71LGSzHTJDDh99f71LmAKyKmBHB2Toigv6q6ltb3Cj76qj7DkS7WPvWxjeNISbvcPcWNfnUz7OzlSFgEldsIlKD3qGQB21l47ni4wjlebd7IkcEldsc8ucEHIocvRwskjceRcIRspGiyAdsFHaEkb)PG3GqHekcwj3eOkHgPr3dcDeiofqKKcrMleNbFbXb)TEcEkbVbHcjueSIgm3zAKgT2iPOcrMleNbFbXb)DmWtj4ndqfZiHi4g86rCWFqWtj4niuiHIGviWmexLopIPvbnQuiYCH4m4lio4VbpvQGVxsvPvA4uOBeDckGVG4GpgfaEQubVbHcjueSsJgnd0in6KS9GcrMleNbVEa(77yG)CWtj4niuiHIGvYnImPLL0d0lorRbjIIzyjvLm4Jd(B2RvcdWUi7MneOxtdry6am3SFmobnBJiSJryHDDO0rlXENc7SBVtHDQgnTRlJrtlQw3qa81mneHb)HG5okujG)0yNZEns1m74DkXpXHtRGVsiofzdQesfGplANWEDjiBwy7yx3rFFXEDjJgjgjZw4MDRdIrLoK(YuWnxYUouYENc7oCAf8vcXPiBqLqQa8zrJB2wpzlSFgEldsIlKD3qGQB21l47ni4wjlebd7IkcEldsc8ucE9cEHIocvRwskjceRcIRspGiyAdsFHaEkb)PG3GqHekcwj3eOkHgPr3dcDeiofqKKcrMleNbFbXb)9baEkbVbHcjueSIgm3zAKgT2iPOcrMleNbFbXbpfdEkbVzaQygjeb3GxpId(dcEkbVbHcjueScbMH4Q05rmTkOrLcrMleNbFbXb)n4Psf89sQkTsdNcDJOtqb8feh83ua4Psf8gekKqrWknA0mqJ0OtY2dkezUqCg86b4VVJb(ZbpLG3GqHekcwj3iYKwwspqV4eTgKikMHLuvYGpo4VzVwjma7ISB2qGEnneHPdWCZ(X4e0SnIWogHf21HshTe7DkSZU9of2PA00UUmgnTOADdbWxZ0qeg8hcM7OqLa(tp45SxJunZoENs8tC40k4ReItr2GkHub4ZI2jSxxcYMf2o21D03xSxxYOrIrYSfUz36GyuPdPVmfCZLSRdLS3PWUdNwbFLqCkYgujKkaFw04MTpmBH9ZWBzqsCHSxRegGDr2nBiqVMgIW0byUz)yCcA2gryhJWc76qPJwI9of2z3ENc7unAAxxgJMwuTUHa4RzAicd(dbZDuOsa)PhW5SxJunZoENs8tC40k4ReItr2GkHub4DlNWEDjiBwy7yx3rFFXEDjJgjgjZw4MDRdIrLoK(YuWnxYUouYENc7oCAf8vcXPiBqLqQa8UfUz77l2c7NH3YGK4cz3neO6MDZauXmsicUbFCWFbEkbVAIOpDvts5wPHvfcT6nmbpLG)uWRxW3BqWTYaSPnOzjsrWBzqsGNkvWRxWxoQPPmaBAdAwIugvd(ZzVwjma7IS3WQcHw9gMSFmobnBJiSJryHDDO0rlXENc7SBVtHDlWQcb8u4nmzVUeKnlSDSR7OVVyVUKrJeJKzlCZU1bXOshsFzk4MlzxhkzVtHDU5MDkIOTJHMlKBMba]] )

    storeDefault( [[SimC Windwalker: precombat]], 'actionLists', 20180107.133322, [[dqZocaGEbs7ciABOImBvA(cIBsj3vaCBrTtQSxYUPy)cPHrP(nOHkGmyHYWfQoOqCmKCobvlev1sLklgPwUuEicEQYYq06eqnrbOPkstwftxvxeOCzORJqBfiTzuPTJQ8Ar4RaHhtvFxq5WsghQOgTu1ZeOojQW3erNgLZdu9wbINd4VcslkLQT4ONvxwqRNbnYrYPW1Cvg1gltiAmqWmNWQBcSf4OXI3qpmtxVwhEXcaLJ0MkjfjjNbjjzWHtsPnFJf)10I4Fg0aOu5OuQgyMI(IhXxlcn7YEW1IdFg0OXH5W81dBAgOb1SGhqRMRYOMMRYOwiEUCTT9EUCdsGGpdAcqinTo8IfakhPnvskBToeasS5raLQxJqp6tyb5Hz08IwZcECvg10lhPs1aZu0x8i(ArOzx2dUMVNfknXgWRXH5W81dBAgOb1SGhqRMRYOMMRYOgHEw0y8j2aETo8IfakhPnvskBToeasS5raLQxJqp6tyb5Hz08IwZcECvg10lxWkvdmtrFXJ4RfHMDzp4A(EwOHv8qnomhMVEytZanOMf8aA1Cvg10Cvg1i0ZIgdefpuRdVybGYrAtLKYwRdbGeBEeqP61i0J(ewqEygnVO1SGhxLrn961ciYTiEFXxVea]] )

    storeDefault( [[SimC Windwalker: sef]], 'actionLists', 20180107.133322, [[dquvfaqiLs1IuQYMuPYOOkYPqk1SukXTukODPsgMk6yIyzivptPKMMsr6AkvQTPuiFJQW4ukIZPuH1rvL5rvuDpIQ2NsLCqs0cjkEiinrvQ6IeL2OsbojvvntLk6MGyNGAOufLLsv5POMQkSvbPVkiERsPCxLIAVs)LKgmfhwXIfPhtPjRKldTzb(mvPrtKonHxtcZwu3wODJ43KA4cQLd8CKmDvDDIy7ev(osX4rk58QuwVsHA(kv1(PYnPhL5WOvmzXgpVqtkm9nAhLHNiwMfrOoticYIMjRab(5muyqzFyghkSW0pt8iHo9n5Io9TUd6jLzlqe(lxwP9fAcvpkCspkllzsZ4QYuMTar4VSNCMT7mHbOCQETRRKRx4fbQHNC0zUZzqcc8E7YkbaqY7mY7mibbEVDfhA5m35mwPIlReaajVZ45otIZqBN5oNXtoZctLeeCfhGcvDG6lfvTGHGxlnneNH2LvMkYI)w5x4fbQHNCSS)KLWoVguMOjyzi6vOdaEIy5YWtelFi8IaNXZMCSSsGxQY)a8IVQiq(fMkji4koafQ6a1xkQAbdbVwAAiL9HzCOWct)mXJKZY(qkTeGfP6r)YqLIwfq0YHrK8nTme9cEIy5(fMEpkllzsZ4QYuMTar4VSvQ4ko0Yz2qNXkvCzLaai5DMDjVZK4m35mibbEVD9IiQ(A14qlNzxY7mNx7USYurw83kpa7qq1xdai5l7pzjSZRbLjAcwgIEf6aGNiwUm8eXYkb2HGoZHgaqYx2hMXHclm9Zepsol7dP0sawKQh9ldvkAvarlhgrY30Yq0l4jIL7x4T2JYYsM0mUQmLvMkYI)wz7KZQJ9fAIAwq9L9NSe251GYenbldrVcDaWtelxgEIy59TbbNNwBqW2Go5SZO0(cnXz2PG638(GYkbEPktMik)ESic1zcrqw0mzfiWpNb697v2hMXHclm9Zepsol7dP0sawKQh9ldvkAvarlhgrY30Yq0l4jILzreQZeIGSOzYkqGFod077x4nThLLLmPzCvzkZwGi8xE7otQKGGlQxdIQ4aEPQdzPgia4LKWLvMkYI)wzQxdIQ4aEPQdzPgiayz)jlHDEnOmrtWYq0Rqha8eXYLHNiwMFniUfNr2b8s3IZmKLZSbcaw2hMXHclm9Zepsol7dP0sawKQh9ldvkAvarlhgrY30Yq0l4jIL7x4D3JYYsM0mUQmLvMkYI)wz7KZQJ9fAIAwq9L9NSe251GYenbldrVcDaWtelxgEIy59TbbNNwBqW2Go5SZO0(cnXz2PG638(aNXtj0USsGxQYKjIYVhlIqDMqeKfntwbc8Zz4J9k7dZ4qHfM(zIhjNL9HuAjals1J(LHkfTkGOLdJi5BAzi6f8eXYSic1zcrqw0mzfiWpNHp63V89yWij)vM(Ta]] )

    storeDefault( [[SimC Windwalker: serenity]], 'actionLists', 20180107.133322, [[dy0NoaqiujTiuPKnjqgLOItjQ0Uufddv5yKyzIQEMIqttucxtrj12qLk(MamouPsNtrjwNOKmpfL6EIsTpujoOI0cvu9qrXefLuxuGAJOsvNuOyLOsPEPIiZurj5MQs7erdfvkyPOQEkXurfBvO0xve8wuPOUlQuK9k9xegmfhgyXI4XKAYkCzOnts(SinAHQtR0Qve1RfYSvv3gu7wLFtLHdIJlkrwokpNQMosxxqBNK67cOXlkrDEqA9OsHMVII9tPRs5urGG6f8xUraDDxjZZDMLkKaySISWzSMjS3iqWpczzL14rgElfAf(4hbESK55PeGs(8C3N85N4SKxPIOzleALkt101D(YPKkLtLGpqYhhDEfrZwi0kC1AGWq1eP6XJYdDtrgbeWh2AcYAWdzPqF0HmgEuRjBRbpKLc9bgKLTMGSgD89rhYy4rTMzBnkwtqwdxTMKqvQE8idVLc9jesLPj7FPqRq3uKrab8HRKjoQJEDQry8OnPYRBelGrcGXkvI5gRgqDSkN7WkKayScNnfzwd3a4dxzkl1xrdv)rckGLIuF2kv4JFe4XsMNNsak8QWh9UqMg9LtPvYav)roawks9DELx3GeaJvkTK5lNkbFGKpo68ktt2)sHwrd(FcGMUUJ4VEALyUXQbuhRY5oSYRBelGrcGXkvibWyLz0QuXJNwRsf3CgW)Bnt101DwZSA9uUPzyvMYs9voamMn3sw4mwZe2Bei4hHSSYAYK1CRk8Xpc8yjZZtjafEv4JExitJ(YP0kzIJ6OxNAegpAtQ86gKaySISWzSMjS3iqWpczzL1KjRlTKtSCQe8bs(4OZRmnz)lfAfpYWBPqReZnwnG6yvo3HvEDJybmsamwPcjagRiidVLcTcF8JapwY88ucqHxf(O3fY0OVCkTsM4Oo61PgHXJ2KkVUbjagRuAjZIYPsWhi5JJoVIOzleAfGMUQrc8q4f9wZSTMjwzAY(xk0kS1VxkHp8iIwDuLmXrD0RtncJhTjvEDJybmsamwPsm3y1aQJv5ChwHeaJv4V(9sTgj8SMjT6OktzP(kAO6psqbSuK6ZwPcF8JapwY88ucqHxf(O3fY0OVCkTsgO6pYbWsrQVZR86gKaySsPLCwxovc(ajFC05vMMS)LcTINY2iKWPIGghjcCVX3XgvI5gRgqDSkN7WkVUrSagjagRuHeaJvekBJqRXPYAOXrRzc7n(o2OcF8JapwY88ucqHxf(O3fY0OVCkTsM4Oo61PgHXJ2KkVUbjagRuAj5oLtLGpqYhhDEfrZwi0k5ynC1AGWq1eP6XJYtYhOJCHuIOvhzn5Anbzn5ynqyOAIu94r5XtzBes4urqJJebU347ydRzMzSgimunrQE8O8OA9upHtfHQqguRjxRjiRbOPRAKapeErV1mBRjFLPj7FPqRK8b6ixiLiA1rvYeh1rVo1imE0Mu51nIfWibWyLkXCJvdOowLZDyfsamwz(hOJCHuRzsRoQYuwQVIgQ(JeualfP(SvQWh)iWJLmppLau4vHp6DHmn6lNsRKbQ(JCaSuK678kVUbjagRuAjdOCQe8bs(4OZRiA2cHwjhRjhRbZsHlei44zW2lAVuI4o2rODQrM1eK1KeQs1deg69HmKaIBp6ddHb75TMzNT1K3AcYA8iLiXDH(h6IS88iYciARHlwdpRjxRjiRjhRr7C)HlW7HT(9sj8Hhr0QJEyimypV1WfRrXAMzgRbOPRAKapeErV1WfRrXAY1AYTY0K9VuOvuTEQNWPIqvidALyUXQbuhRY5oSYRBelGrcGXkvibWyfUF9uV14uznCFidALPSuFL9OiJfcHMTsf(4hbESK55PeGcVk8rVlKPrF5uALmXrD0RtncJhTjvEDdsamwP0sYDlNkbFGKpo68kIMTqOvYXAYXA4Q1GzPWfceC8my7fTxkrCh7i0o1iZAMzgRjjuLQNKVZn(HE6tieRzMzSMKqvQE8idVLc9HHWG98wZSTgfRjxRjiRjhRr7C)HlW7HT(9sj8Hhr0QJEyimypV1WfRrXAMzgRbOPRAKapeErV1WfRrXAY1AYTY0K9VuOvuTEQNWPIqvidALyUXQbuhRY5oSYRBelGrcGXkvibWyfUF9uV14uznCFidQ1KJsUvMYs9v2JImwieA2kv4JFe4XsMNNsak8QWh9UqMg9LtPvYeh1rVo1imE0Mu51nibWyLsl5Suovc(ajFC05venBHqRa00vnsGhcVO3A4s2wZeTMGSgUAnqyOAIu94r5XdzVBVucndCir0QJQmnz)lfAfpK9U9sj0mWHerRoQsm3y1aQJv5Chw51nIfWibWyLkKaySIazVBVuRjddCO1mPvhvHp(rGhlzEEkbOWRcF07czA0xoLwjtCuh96uJW4rBsLx3GeaJvkTKk8kNkbFGKpo68kIMTqOv4Q1aHHQjs1JhLhwOp(EPetgmqIa3BynbznjHQu9Wc9X3lLyYGbse4EJNHlWZAcYAscvP6XJm8wk0hgcd2ZBnCjBRjlQmnz)lfAfwOp(EPetgmqIa3BujMBSAa1XQCUdR86gXcyKaySsfsamwHFOp(EPwd3gmqRzc7nQWh)iWJLmppLau4vHp6DHmn6lNsRKjoQJEDQry8OnPYRBqcGXkLwsfLYPsWhi5JJoVIOzleAfGMUQrc8q4f9wdxY2AMyLPj7FPqRWw)EPe(WJiA1rvYeh1rVo1imE0Mu51nIfWibWyLkXCJvdOowLZDyfsamwH)63l1AKWZAM0QJSMCuYTYuwQVIgQ(JeualfP(SvQWh)iWJLmppLau4vHp6DHmn6lNsRKbQ(JCaSuK678kVUbjagRuAjvYxovc(ajFC05venBHqRWvRbcdvtKQhpkpSqF89sjMmyGebU3WAcYAscvP6Hf6JVxkXKbdKiW9gpdxGN1eK1a00vnsGhcVO3A4I1OuzAY(xk0kSqF89sjMmyGebU3Osm3y1aQJv5Chw51nIfWibWyLkKaySc)qF89sTgUnyGwZe2Byn5OKBf(4hbESK55PeGcVk8rVlKPrF5uALmXrD0RtncJhTjvEDdsamwP0sQmXYPsWhi5JJoVIOzleAfUAnqyOAIu94r5XdzVBVucndCir0QJQmnz)lfAfpK9U9sj0mWHerRoQsm3y1aQJv5Chw51nIfWibWyLkKaySIazVBVuRjddCO1mPvhzn5OKBf(4hbESK55PeGcVk8rVlKPrF5uALmXrD0RtncJhTjvEDdsamwP0sQKfLtLGpqYhhDEfrZwi0kC1AGWq1eP6XJYtYhOJCHuIOvhvzAY(xk0kjFGoYfsjIwDuLmXrD0RtncJhTjvEDJybmsamwPsm3y1aQJv5ChwHeaJvM)b6ixi1AM0QJSMCuYTYuwQVIgQ(JeualfP(SvQWh)iWJLmppLau4vHp6DHmn6lNsRKbQ(JCaSuK678kVUbjagRuAPvYAufi8t78sBb]] )

    storeDefault( [[SimC Windwalker: ST]], 'actionLists', 20180107.133322, [[dC0zDaqiIuTiIusBsP0OeGtrj1TeKyxe1WOGJrPwMG6zusmnjkDnkjTnkuLVjGgNGu5CsuyDcsX8isX9as7dioirYcbkpuu1ePqrxuqSrku5KIkTskuvVuqsZuqkDtIyNu0qfKQwQa9uQMkLyRIk(kfk9wIuIUlrkH9c9xcnyPomslwipMutwjxg1MLiFwOgTs1Pv1QPqHxlHzlPBdy3Q8BsgobDCIuQLd65ImDexxu2UsX3PqgVevNNaRxIIMpq1(vmAJwq3KcWO7pq(Pn2)wgrRfmm0mTBbDJjxIMvjiyOhKRmnXOzyd2bAhoCOtoCyRugHTr3fY6Nw)YKsE1HMHnELb6sPjV6sOf00gTGEihnQYlem0Lk6Rpra6AATks1KxDI1prqp3B9Akrbr)uhJUe1khk0KcWOJUjfGrhCDPsgmO1LkjTmpTwNwkn5v30H2prKwaoeDPGXj0pkadQ0Q)a5N2y)BzeTwWWqZ05nMsROhKRmnXOzyd2bABa9GCsLb1CcTGe0ZVZ6cjQnmaFemcDjQLjfGr3FG8tBS)TmIwlyyOz68gtKGMHrlOhYrJQ8cbdDxdFHe0L(0cH8gXy9s2wM8XmuuiTcm92P17VSodc5JmT0a602tVD6aMwRu1LYOtg(P)IftzNyXRlKHma9V00GoTHPbh8PdyAkK8LOAICIa)cwuvsKSZIg93QQGlz(OrvEn92P1kvDPm6Kte4xWIQsIKDw0O)wvfCjdza6FPPbDAdtB90Gd(08XWybY6miKpY0sZ0w1W0wJUurF9jcqNpgg)L5FXIC9l)HON7TEnLOGOFQJrxIALdfAsby0r3KcWOhYXW4Vm)lE6qQF5pe9GCLPjgndBWoqBdOhKtQmOMtOfKGE(DwxirTHb4JGrOlrTmPam6ibnTcAb9qoAuLxiyO7A4lKGUE)LbOLpDOmTE)L1zqiFKPbb0PTNE708XWybYKhGfjkraA5tdcOtBq2QOlv0xFIa0Pqn9yrIcc5JGEU361uIcI(PogDjQvouOjfGrhDtkaJUuqn94PTOGq(iOhKRmnXOzyd2bABa9GCsLb1CcTGe0ZVZ6cjQnmaFemcDjQLjfGrhjOzzrlOhYrJQ8cbdDxdFHe0L(0cH8gXy9s2woQs1fQmIyXRlME7069xgGw(0HY069xwNbH8rMgeqN2E6TtNyIyK6YsYKNHHTflRq90GmTHP3oDuwPsYrQcrHqLwoti6sf91Nia9OkvxOYiIfVUa987SUqIAddWhbJqxIALdfAsby0rp3B9Akrbr)uhJUjfGrhSkvxOYithQVUaDPGXj01c0vwKqHXmjbQn6b5kttmAg2GDG2gqpiNuzqnNqlib98c0v2cfgZKecg6sultkaJosqtRIwqpKJgv5fcg6Ug(cjOl9Pfc5nIX6LSTm5JzOOqAfy6Ttl9Pfc5nIX6LSTmFmm(lZ)If56x(dNE708XWybYKhGfjkraA5tlnGoT90BNwV)Ya0YNouMwV)Y6miKpY0Ga60HrxQOV(ebOt(ygkkKwbqp)oRlKO2Wa8rWi0LOw5qHMuagD0Z9wVMsuq0p1XOBsby0T8XmC6qpTcGUuW4e6Ab6klsOWyMKa1g9GCLPjgndBWoqBdOhKtQmOMtOfKGEEb6kBHcJzscbdDjQLjfGrhjOPXdTGEihnQYlem0Dn8fsqx6ttOv(iYjgY3teiZhnQYRPbh8P1kvDPm6KtmKVNiqgYa0)stdcOtBBaDPI(6teGEIa)cwuvsKSZIg93QQGl0Z9wVMsuq0p1XOlrTYHcnPam6OBsby0Dc8l4PvLMMSZtBS)TQk4c9GCLPjgndBWoqBdOhKtQmOMtOfKGE(DwxirTHb4JGrOlrTmPam6ibndeTGEihnQYlem0Dn8fsqpGPdyA9(lRZGq(itdcOtBLP3onFmmwGSodc5JmniGoDznmT1tdo4tR3FzDgeYhzAqaDARoT1tVD6aMw6ttOv(iYjgY3teiZhnQYRPbh8P1kvDPm6KtmKVNiqgYa0)stdcOtB8M2A0Lk6Rpra6Wp9xSyk7elEDb653zDHe1ggGpcgHUe1khk0KcWOJEU361uIcI(PogDtkaJEWp9x80E2nDO(6c0LcgNqxlqxzrcfgZKeO2OhKRmnXOzyd2bABa9GCsLb1CcTGe0ZlqxzluymtsiyOlrTmPam6ibndDOf0d5OrvEHGHURHVqc6eALpICIH89ebY8rJQ8A6Ttl9PzPD2luiVKxW)k(lwCxbprTAddNE70ALQUugDYjgY3teidza6FPPbb0PT60BNMpgglqM8aSirjcqlFAqMom6sf91Nia9sFIKevLelLbfGEU361uIcI(PogDjQvouOjfGrhDtkaJUX9jsAAvPPnUmOa0dYvMMy0mSb7aTnGEqoPYGAoHwqc653zDHe1ggGpcgHUe1YKcWOJe0SmqlOhYrJQ8cbdDxdFHe0j0kFe5ed57jcK5Jgv510BNML2zVqH8sEb)R4VyXDf8e1QnmC6TthW0ALQUugDYjgY3teidza6FPPbb0PTT60Gd(0ALQUugDYjgY3teidza6FPPLgqNUStB90BNMpgglqM8aSirjcqlFAqMom6sf91Nia9sFIKevLelLbfGEU361uIcI(PogDjQvouOjfGrhDtkaJUX9jsAAvPPnUmOGPdW2A0dYvMMy0mSb7aTnGEqoPYGAoHwqc653zDHe1ggGpcgHUe1YKcWOJe002aAb9qoAuLxiyO7A4lKGU0NMqR8rKtmKVNiqMpAuLxtVDA(yySazYdWIeLiaT8Pbz6WOlv0xFIa0l9jssuvsSugua65ERxtjki6N6y0LOw5qHMuagD0nPam6g3NiPPvLM24YGcMoGWwJEqUY0eJMHnyhOTb0dYjvguZj0csqp)oRlKO2Wa8rWi0LOwMuagDKGM22Of0d5OrvEHGHURHVqc6ALQUugDYWp9xSyk7elEDHmKbO)LMgeqN2kYwD6TtR3FzDgeYhzAPb0PTk6sf91Nia9sFIKevLelLbfGEU361uIcI(PogDjQvouOjfGrhDtkaJUX9jsAAvPPnUmOGPdWkwJEqUY0eJMHnyhOTb0dYjvguZj0csqp)oRlKO2Wa8rWi0LOwMuagDKGM2HrlOhYrJQ8cbdDxdFHe0L(0eALpICIH89ebY8rJQ8AAWbFATsvxkJo5ed57jcKHma9V00Ga60wfDPI(6teGo8t)flMYoXIxxGE(DwxirTHb4JGrOlrTYHcnPam6ON7TEnLOGOFQJr3KcWOh8t)fpTNDthQVUy6aSTgDPGXj01c0vwKqHXmjbQn6b5kttmAg2GDG2gqpiNuzqnNqlib98c0v2cfgZKecg6sultkaJosqtBRGwqpKJgv5fcg6sf91NiaDJ2Fy9VyXfKgRorHzNEh9CV1RPefe9tDm6suRCOqtkaJo6MuagDJD)H1)IN2ycPXQB6qF2P3rpixzAIrZWgSd02a6b5KkdQ5eAbjONFN1fsuBya(iye6sultkaJosqt7YIwqpKJgv5fcg6Ug(cjOl9Pfc5nIX6LSTCuLQluzeXIxxm92P17VmaT8PdLP17VSodc5JmniGoT90BNoXeXi1LLKjpddBlwwH6PbzAdtVD6aMw6tNyIyK6YsYKNH2LHyyH6PbzAdtdo4ttOv(iYjgY3teiZhnQYRPTgDPI(6teGEuLQluzeXIxxGE(DwxirTHb4JGrOlrTYHcnPam6ON7TEnLOGOFQJr3KcWOdwLQluzKPd1xxmDa2wJUuW4e6Ab6klsOWyMKa1g9GCLPjgndBWoqBdOhKtQmOMtOfKGEEb6kBHcJzscbdDjQLjfGrhjOPTvrlOhYrJQ8cbdDxdFHe0dyAQM8Byr(yGNttdcOtBLPbh8Pdy6OSsLKJufIcHkTCMWP3oTE)LbOLpDOmTE)L1zqiFKPbb0PnmT1tB90BNw6tleYBeJ1lzB5KW)U)If1q6XIfVUy6TtNyIyK6YsYKNHHTflRq90GmTb0Lk6Rpra6jH)D)flQH0JflEDb65ERxtjki6N6y0LOw5qHMuagD0nPam6UW)U)INopKE80H6RlqpixzAIrZWgSd02a6b5KkdQ5eAbjONFN1fsuBya(iye6sultkaJosqtBJhAb9qoAuLxiyO7A4lKGolTZEHc5LmzNfzaHmubtIAQqQ(jk40BNokRujzYolYaczOcMe1uHu9tuq5eHQlMgeqN2UmME708XWybYKhGfjkraA5tdY0wbDPI(6teGUgs1f1)Ifng0flw)4DY9xm65ERxtjki6N6y0LOw5qHMuagD0nPam65HuDr9V4Pn(0fpDO9J3j3FXOhKRmnXOzyd2bABa9GCsLb1CcTGe0ZVZ6cjQnmaFemcDjQLjfGrhjOPDGOf0d5OrvEHGHURHVqc6S0o7fkKxYKDwKbeYqfmjQPcP6NOGtVD6OSsLKj7SidiKHkysutfs1prbLteQUyAqaDA7Yo92P1kvDPm6KtmKVNiqgYa0)stlntBBLP3onHw5JiNyiFprGmF0OkVME708XWybYKhGfjkraA5tdY0wbDPI(6teGUgs1f1)Ifng0flw)4DY9xm65ERxtjki6N6y0LOw5qHMuagD0nPam65HuDr9V4Pn(0fpDO9J3j3FXthGT1OhKRmnXOzyd2bABa9GCsLb1CcTGe0ZVZ6cjQnmaFemcDjQLjfGrhjOPDOdTGEihnQYlem0Dn8fsqNQj)gwKpg4500Ga60wz6Ttl9Pfc5nIX6LSTCs4F3FXIAi9yXIxxGUurF9jcqpj8V7VyrnKESyXRlqp3B9Akrbr)uhJUe1khk0KcWOJUjfGr3f(39x805H0JNouFDX0byBn6b5kttmAg2GDG2gqpiNuzqnNqlib987SUqIAddWhbJqxIAzsby0rcAAxgOf0d5OrvEHGHURHVqc669xgGw(0HY069xwNbH8rMgKPTNE70sFAHqEJySEjBldZs7)flAmOlw0O)wOlv0xFIa0HzP9)Ifng0flA0Fl0Z9wVMsuq0p1XOlrTYHcnPam6OBsby0dML2)lEAJpDXtBS)TqpixzAIrZWgSd02a6b5KkdQ5eAbjONFN1fsuBya(iye6sultkaJosqZWgqlOhYrJQ8cbdDxdFHe0dyA9(lRZGq(itdY02tdo4thLvQKCKQquiuPLZeon4GpDattOv(iY8XW4Vm)lwKRF5puMpAuLxtVDATsvxkJoz(yy8xM)flY1V8hkdza6FPPLMP1kvDPm6Kl9jssuvsSuguGmKbO)LM26PTE6TthW0bmTwPQlLrNm8t)flMYoXIxxidza6FPPbzA7P3oDatl9PPqYxIQjYjc8lyrvjrYolA0FRQcUK5Jgv510Gd(0ALQUugDYjc8lyrvjrYolA0FRQcUKHma9V00GmT90wpn4GpTE)L1zqiFKPbz6YoT1tVD6aMwRu1LYOtU0NijrvjXszqbYqgG(xAAqM2EAWbFA9(lRZGq(itdY0HN26Pbh8Pfc5nIX6LSTm5JzOOqAfyARNE70sFAHqEJySEjBlhvP6cvgrS41fOlv0xFIa0JQuDHkJiw86c0ZVZ6cjQnmaFemcDjQvouOjfGrh9CV1RPefe9tDm6MuagDWQuDHkJmDO(6IPdiS1OlfmoHUwGUYIekmMjjqTrpixzAIrZWgSd02a6b5KkdQ5eAbjONxGUYwOWyMKqWqxIAzsby0rcAg2gTGEihnQYlem0Dn8fsqxV)Y6miKpY0sdOtBLP3oDatRvQ6sz0jd)0FXIPStS41fYqgG(xAAqaDARon4GpTwPQlLrNSr7pS(xS4csJvNOWStVldza6FPPbb0PT60wp92P5JHXcKjpalsuIa0YNgKPTrxQOV(ebOR3FrJOBy0Z9wVMsuq0p1XOlrTYHcnPam6OBsby0ZV)tBS0nm6b5kttmAg2GDG2gqpiNuzqnNqlib987SUqIAddWhbJqxIAzsby0rcAgomAb9qoAuLxiyO7A4lKGUE)L1zqiFKPLgqN2ktVD6aMwRu1LYOtg(P)IftzNyXRlKHma9V00Ga60wDAWbFATsvxkJozJ2Fy9VyXfKgRorHzNExgYa0)stdcOtB1PTE6TtZhdJfitEawKOebOLpnitBJUurF9jcqxV)IrzWeb9CV1RPefe9tDm6suRCOqtkaJo6Muag987)0GLbte0dYvMMy0mSb7aTnGEqoPYGAoHwqc653zDHe1ggGpcgHUe1YKcWOJe0mSvqlOhYrJQ8cbdDxdFHe0L(0cH8gXy9s2wM8XmuuiTcm92PdyA9(ldqlF6qzA9(lRZGq(itdcOthEAWbFA(yySazYdWIeLiaT8PLMPTY0wJUurF9jcqN8XmuuiTcGE(DwxirTHb4JGrOlrTYHcnPam6ON7TEnLOGOFQJr3KcWOB5Jz40HEAfy6aSTgDPGXj01c0vwKqHXmjbQn6b5kttmAg2GDG2gqpiNuzqnNqlib98c0v2cfgZKecg6sultkaJosqZWLfTGEihnQYlem0Lk6Rpra669x0i6gg9CV1RPefe9tDm6suRCOqtkaJo6Muag987)0glDdpDa2wJEqUY0eJMHnyhOTb0dYjvguZj0csqp)oRlKO2Wa8rWi0LOwMuagDKGMHTkAb9qoAuLxiyOlv0xFIa017Vyugmrqp3B9Akrbr)uhJUe1khk0KcWOJUjfGrp)(pnyzWez6aSTg9GCLPjgndBWoqBdOhKtQmOMtOfKGE(DwxirTHb4JGrOlrTmPam6ibjO7A4lKGosqea]] )

    storeDefault( [[SimC Windwalker: CD]], 'actionLists', 20180107.133322, [[dKentaqirvTjb4tujrnkuqNcb1SqqYTeLa7IunmsPJjPwMOYZqryAIsQRHIOTjkjFdLQXrLuohvsyDIsqZdf4Euj2NOkoicSquupeLYerqCrb0gPssJKkPItsLQvkQs1nrODIQ(jvsKLkkEkLPIsUkcsTvQu(QOkLXsLuL3sLuP7sLuv7v1Fr0GjCyPwmQ8yrMSqxgSzb9zsXOHOttYQfLqVgcMTe3gs7gQFR0WfOJlQswospNQMUIRtfBhf67IsnEuKoVKSErjA(qO9t0V(SUriqy7uMZ8n(gfUzku2KI8MchZUlia0SqPGnc5wgOaThoFoT1SxNlNRPNlht4kYvFZsuvW52ncsJAX(Z681N1TaXnxbIN5BeWPkQP6McZ4IaqYuhaFZDCuL6zP3WlgUrCJU1u(gfUDJVrHBUJzCraKcxphatOKIbjif5nKQbKcwkna9wgOaThoFoT1SxR9wgWVo0e4pRp3ydjKqG4YiGc45C3iUr(gfU9585oRBbIBUcepZ3iGtvut1nUYUrYqhA1n3XrvQNLEdVy4gXn6wt5Bu42n(gfUXCz3Ou4Qo0QBzGc0E4850wZET2Bza)6qtG)S(CJnKqcbIlJakGNZDJ4g5Bu42NZZeN1TaXnxbIN5BeWPkQP6ghq9afbfwZn3XrvQNLEdVy4gXn6wt5Bu42n(gfUXmq9afbfwZTmqbApC(CARzVw7TmGFDOjWFwFUXgsiHaXLrafWZ5UrCJ8nkC7Z5Z6Z6wG4MRaXZ8nlrvbNBjKkD0MPsrwGuKqQ0toukGhPipUif1srasbGbQMk9rHcKZsI2mvkYJlsHwDM8gbCQIAQU10uJbYzPuap3ChhvPEw6n8IHBe3OBnLVrHB34Bu4gb0uJbPG1sPaEULbkq7HZNtBn71AVLb8Rdnb(Z6Zn2qcjeiUmcOaEo3nIBKVrHBFoptEw3ce3CfiEMVrSzQc1bLvt1aJ)wUBwIQco3YxkA6Oc70ORPlajNd1p6aU5kqukcqkG8Yrfmie1rQIratI2(bOEYWLYPIratoRtcPueGuKVueKcmsQjf1R1N1jHKCdjJqpiVraNQOMQBZ6KqsUHKrOhK3ydjKqG4YiGc45C3iUr3AkFJc3U5ooQs9S0B4fd34Bu4gR1jHuk2qPGqGEqEJaQg)TuvQaKtt1aJ3LAcfAZuYuvQaKtt1aJ3LC3YafO9W5ZPTM9AT3Ya(1HMa)z95gBvPcWQPAGXFMVrCJ8nkC7Z5ZQZ6wG4MRaXZ8nlrvbNB5lfnDuHDA010fGKZH6hDa3Cfikfbif5lfqE5OcgeI6ivXiGjrB)aupz4s5uXiGjN1jH8gbCQIAQUnRtcj5gsgHEqEZDCuL6zP3WlgUrCJU1u(gfUDJVrHBSwNesPydLccb6bPuWWAcFlduG2dNpN2A2R1Eld4xhAc8N1NBSHesiqCzeqb8CUBe3iFJc3(CE2pRBbIBUcepZ3i2mvH6GYQPAGXFl3nlrvbNBnDuHDA010fGKZH6hDa3CfikfbifmukyOumDbWJUhOawnv6aU5kqukcqks7wIB2yDpqbSAQ0PaARWEPGbUif1sbHLceruksiv6jhkfWJuKhxKICsbHLIaKcgkfPDlXnBSUFOkeaYnKCqcKzRWXYsJ6uaTvyVuWaPW1Kceruks7wIB2y9qLF8KBizOdTsNcOTc7Lcg4IuK1sbHLIaKI0UL4MnwNQ8kSgsVdMebvcbDkG2kSxkyGuWUueGuKVueKcmsQjf1R1N1jHKCdjJqpiVraNQOMQBZ6KqsUHKrOhK3ydjKqG4YiGc45C3iUr3AkFJc3U5ooQs9S0B4fd34Bu4gR1jHuk2qPGqGEqkfmmhHVravJ)wQkvaYPPAGX7snHcTzkzQkvaYPPAGX7sUBzGc0E4850wZET2Bza)6qtG)S(CJTQuby1unW4pZ3iUr(gfU958U2zDlqCZvG4z(MLOQGZTPlaE09afWQPshWnxbIsrasr(sbNtyOUhOawnv6obLIaKcadunv6JcfiNLeTzQuKhPGjUraNQOMQBrA7Ob5qUHK(1P4V5ooQs9S0B4fd3iUr3AkFJc3UX3OWncH2oAqosXgkf26u83YafO9W5ZPTM9AT3Ya(1HMa)z95gBiHecexgbuapN7gXnY3OWTpN3vCw3ce3CfiEMVzjQk4ClFPy6cGhDpqbSAQ0bCZvGOueGuKVuW5egQ7NLIscnDqs24izOIc6obLIaKcadunv6JcfiNLeTzQuKhPGjUraNQOMQBrA7Ob5qUHK(1P4V5ooQs9S0B4fd3iUr3AkFJc3UX3OWncH2oAqosXgkf26u8sbdRj8TmqbApC(CARzVw7TmGFDOjWFwFUXgsiHaXLrafWZ5UrCJ8nkC7Z5R1Ew3ce3CfiEMVzjQk4CJZjmu3duaRMkDkG2kSxkyGuulfiIOuWqPiFPy6cGhDpqbSAQ0bCZvGOueGueboNWq9zDsij3qYi0dsDNGsbHVraNQOMQBHlvdeQaC0tg2CuvQNLEZDCuL6zP3WlgUrCJU1u(gfUDJVrHBU6s1aHkahDL9sHR2CuvQNLElduG2dNpN2A2R1Eld4xhAc8N1NBSHesiqCzeqb8CUBe3iFJc3(C(66Z6wG4MRaXZ8nlrvbNB5lfnDuHDA010fGKZH6hDa3CfiEJaovrnv3CWCuvSarYqhA1n3XrvQNLEdVy4gXn6wt5Bu42n(gfUrOXCuvSarPWvDOv3iGQXFd3OGloyoQkwGizOdT6wgOaThoFoT1SxR9wgWVo0e4pRp3ydjKqG4YiGc45C3iUr(gfU95815oRBbIBUcepZ3SevfCUXqPiFPOPJkStJUFOkeaYnKCqcKzRWXYsJ6aU5kqukcqks7wIB2yD)qviaKBi5GeiZwHJLLg1PaARWEPGbsrDwlfbifPDlXnBSEOYpEYnKm0HwPtb0wH9sbdCrkQzsPiaPiTBjUzJ1PkVcRH07GjrqLqqNcOTc7LcgifSlfewkqerPGZjmu3duaRMkDNG3iGtvut1nhmhvflqKm0HwDZDCuL6zP3WlgUrCJU1u(gfUDJVrHBeAmhvflqukCvhALuWWAcFJaQg)nCJcU4G5OQybIKHo0QBzGc0E4850wZET2Bza)6qtG)S(CJnKqcbIlJakGNZDJ4g5Bu42NZxZeN1TaXnxbIN5BwIQco3YxkMUa4r3duaRMkDa3CfikfiIOuK2Te3SX6EGcy1uPtb0wH9sbdKIAxtkqerPiTBjUzJ19afWQPsNcOTc7LI8ifmPwPareLIPPAGrFuOa5SKrfifmWfPGj0EJaovrnv3qUum5gsYyxw6n3XrvQNLEdVy4gXn6wt5Bu42n(gfU56SuSuSHsHBDzP3iGQXFd3OGlixkMCdjzSll9wgOaThoFoT1SxR9wgWVo0e4pRp3ydjKqG4YiGc45C3iUr(gfU9581z9zDlqCZvG4z(MLOQGZnoNWq90I1aDrH1qQzxD)0jeKI84IuKv3iGtvut1TrHRi3nlHIcRHuHjBYSytV5ooQs9S0B4fd3iUr3AkFJc3UX3OWnwkCLu4kTzjuuynsHclfTuK3B6ncOA83Wnk4YOWvK7MLqrH1qQWKnzwSP3YafO9W5ZPTM9AT3Ya(1HMa)z95gBiHecexgbuapN7gXnY3OWTpNVMjpRBbIBUcepZ3SevfCUXqPGZjmu3duaRMkDNGsrasr(sbKxoQGbHOUpiKgGsUHKCWq7QUifewkqerPGHsbKxoQGbHOUpiKgGsUHKCWq7QUifbifmukgfkifmqkysPareLI0UL4Mnw3duaRMkDkG2kSxkyGlsHRjfewkiSuGiIsr(sX0fap6EGcy1uPd4MRarPareLIPPAGrFuOa5SKrfifmWfPiTBjUzJ19afWQPsNcOTc7VraNQOMQBmQ6c5gsMG2dfW7jNLPkS)M74Ok1ZsVHxmCJ4gDRP8nkC7gFJc3Ct1fPydLc2G2dfW7Lcwltvy)ncOA83Wnk4cJQUqUHKjO9qb8EYzzQc7VLbkq7HZNtBn71AVLb8Rdnb(Z6Zn2qcjeiUmcOaEo3nIBKVrHBFoFDwDw3ce3CfiEMVzjQk4CJHsrA3sCZgR7bkGvtLofqBf2lf5rkQ1kfiIOuW5egQ7bkGvtLUtqPGWsbIikf5lftxa8O7bkGvtLoGBUceVraNQOMQB(GqAak5gsYbdTR6Yn3XrvQNLEdVy4gXn6wt5Bu42n(gfUzbH0auPydLcMHH2vD5gbun(B4gfCXhesdqj3qsoyODvxULbkq7HZNtBn71AVLb8Rdnb(Z6Zn2qcjeiUmcOaEo3nIBKVrHBFoFn7N1TaXnxbIN5BeWPkQP6MJhivdG6V5ooQs9S0B4fd3iUr3AkFJc3UX3OWnetHHA1MsHHUUeApifUpaQ31hr6TmqbApC(CARzVw7TmGFDOjWFwFUXgsiHaXLrafWZ5UrCJ8nkC7ZNBwqiP6Ikl7rT4ZNlRCfF(b]] )

    storeDefault( [[SimC Windwalker: serenity opener]], 'actionLists', 20180107.133322, [[dqKIkaqisfzrIQKnrr1Oub6uQaUfPIYUOQggsCmkSmrYZqsvttuf11evP2MOQQVrkzCIQsNJuHwhPcMhff3djzFuu6GurluK6HuKjIKsxKuPnkQkojvWlrsXmjvuDtvLDIudvuvzPKQEkQPQQARuH(QkiVvuf6UIQG9k9xQYGfCyqlMk9ysMSkDzOnRI(SIA0IkNgXRvKzRWTvLDt43enCsXYbEoLMUsxxeBxf67KsnEKu58IY6fvrMVkO2VqxJ(xwxb0DG36wMg(WYm5zkgoerC1goMqGoedweGcYMfdsnOabLznOIahK8eCjsrPtL)6yz94aHwS0POyOLrQu5RFQuuVoMYOmRaenB5YovlrkS9V0g9VSUcO7aVnDzwbiA2Y6umObGh9MvxFd)LmJapnWXlgmpgqbcMZ8vjaak2yGQyafiyoZ)bPUyW8yqLJ4RsaauSXGzIbJyW8yqNIb3KZtFlcqbzZ8t0edMhdkPCCLAl8pj216jp9otaz(a8bjcBmygQIbkLD6sgKnR8sMrGNg44v2uoun9jpIpuS1T8N86ieqdFy5YoiUefCLGYcPaltdFy5FYmcIH8doELDcMTLvzQb6TqWmUwQmkRhhi0ILoffdTmOuwpALjafA7F3YMYud8hcMX120L)KxA4dl3T0P6FzDfq3bEB6YScq0SLv5i(pi1fd6SyqLJ4RsaauSXGzPkgmIbZJbuGG5m)L8qVv69GuxmywQIbk(5DzNUKbzZkdbkOa9wjaGITSdIlrbxjOSqkWYFYRJqan8HLltdFyzNafuGXWVeaqXwwpoqOflDkkgAzqPSE0ktak02)ULnLdvtFYJ4dfBDl)jV0WhwUBPP((xwxb0DG3MUmRaenBzLuoUsTf(Ne7A9KNENjGmFa(GeHngmBmyu2Plzq2SYk4y4bvlrk8ge7w2bXLOGReuwify5p51riGg(WYLPHpS8HvNNuOOuNN5rtWXigCQwIued6CIDZdhgu2jy2wwaFiv5ftEMIHdrexTHJjeOdXGjQnVkRhhi0ILoffdTmOuwpALjafA7F3YMYHQPp5r8HITUL)KxA4dlZKNPy4qeXvB4ycb6qmyIA7w68C)lRRa6oWBtxMvaIMTSskhxP2c)tIDTEYtVZeqMpaFqIWgdMngmk70LmiBwzlcqbzZk7G4suWvcklKcS8N86ieqdFy5Y0WhwMrakiBwz94aHwS0POyOLbLY6rRmbOqB)7w2uoun9jpIpuS1T8N8sdFy5ULoV7FzDfq3bEB6YScq0SLHQLCe9qb(iOngmtmq9XG5XGBY5PVfbOGSz(jAk70LmiBwzaXseZE2eH3ernv2uoun9jpIpuS1T8N86ieqdFy5YoiUefCLGYcPaltdFyz9elrmhdCIigOgIAQStWSTSktnqVfcMX1sLrz94aHwS0POyOLbLY6rRmbOqB)7w2uMAG)qWmU2MU8N8sdFy5ULo)7FzDfq3bEB6YScq0SLDtop9TiafKnZprtzNUKbzZkBxazc9KNEBo0tBI4oKGBzhexIcUsqzHuGL)KxhHaA4dlxMg(WY8citymipJHnhgdhIiUdj4wwpoqOflDkkgAzqPSE0ktak02)ULnLdvtFYJ4dfBDl)jV0WhwUBP1Q)L1vaDh4TPlZkarZw(GXGofdAa4rVz113W3DavtYK1BIOMIHdedMhdhmg0aWJEZQRVHVDbKj0tE6T5qpTjI7qcUXWbk70LmiBwz3bunjtwVjIAQSPCOA6tEeFOyRB5p51riGg(WYLDqCjk4kbLfsbwMg(WYPhq1KmzJbQHOMk7emBlRYud0BHGzCTuzuwpoqOflDkkgAzqPSE0ktak02)ULnLPg4pemJRTPl)jV0WhwUBPZ3(xwxb0DG3MUmRaenBzLuoUsTf(aILiM9SjcVjIAYhGpiryJbZgdgXWHpCm4MCE6BrakiBM)vQTOStxYGSzLpj216jp9otazLDqCjk4kbLfsbw(tEDecOHpSCzA4dlNpe7AJb5zmKpjGSYobZ2YeXIaqIMLkJY6XbcTyPtrXqldkL1JwzcqH2(3TSPCOA6tEeFOyRB5p5Lg(WYDlTo2)Y6kGUd820LzfGOzl7MCE6BrakiBM)vQTigmpgu5i(QeaafBmygQIHuXG5XGskhxP2cFlcqbzZ8b4dse2yWmufduIbZJbna8O3S66B4VKze4PboELD6sgKnRS7aQMKjR3ernv2uoun9jpIpuS1T8N86ieqdFy5YoiUefCLGYcPaltdFy50dOAsMSXa1qutXWbnoqzNGzBzvMAGElemJRLkJY6XbcTyPtrXqldkL1JwzcqH2(3TSPm1a)HGzCTnD5p5Lg(WYDlTbL(xwxb0DG3MUmRaenBzvoIVkbaqXgdufdgLD6sgKnR8sMrGNg44v2uoun9jpIpuS1T8N86ieqdFy5YoiUefCLGYcPaltdFy5FYmcIH8doEXWbnoqzNGzBzvMAGElemJRLkJY6XbcTyPtrXqldkL1JwzcqH2(3TSPm1a)HGzCTnD5p5Lg(WYD7wMAXtyYyB6UTa]] )


    storeDefault( [[Windwalker Primary]], 'displays', 20171113.171213, [[da0iiaqlck2fePAykYXKslJk5zeitJkvDnQuzBkQY3GizCeOY5iO06irCpcu6Gk0cvWdjKjQOQUOkSrfLpQOYijO6KeQxsaMjjQBsaTtk9tizOKYrjqXsjipfmvO6QKiTvcu1xHiwlePSxXGvPoSKftHhJstwLCzL2Su8zi1OPItJ0RHqZwQUnPA3O63igouoovklNONtvtxvxhfBNe(ofnEiQZtsRhc2Vk60g8aSf2tj8ze(dVAFdGsP4kl2Ee4lj691uOfJaYIJEf5SSiMHaUXSm7yNIMRV8paBavunn(9fvypLW9Xofazunn(9fvypLW9XofWnMLzVeZs4afHnw3pfW7qmhzKLyEdjgbCJzz2lrf2tjCFgcOIQPXVpEjrVVp2PacgMLz9bp22Gh4Gxg99kdbgzFkHFERm1)Xk4cyl9naq1fDEJek)YS6iUsLCEJjxwIUr9beA7B53yDn1oV2PjbfayLuSpWt1xb7u(yDf8ah8YOVxziWi7tj8ZBLP(pwKkGT03aavx05nsO8lZQJ4kvY5912um9pGqBFl)gRRP251onjO85d4DiMGj9zDgpYqaVdXCK5jziaLLWbSILYrhR7cumYsmVHGRITbmyAAcOgRW4YL7c0q4FGdKXKR3BwQb8oet8sIEFFgcGOXiN1HidGJstiXZjC8aSeDJ61uCeJaSf2tj8roRdrgyafookbgqebt98gNeaju(Lz1rCLN3JOoc4DiMaEgc4gZYSZNkx2Ns4bes8CchpaNrxmlH7J19b8yBVpRxEhrKorg8avSTbKX2gaDSTbmITnFaVdXuuH9uc3NHaiJQPXV)iJSIDkqXilCvSnGbttta9c5rMNe7uGQJ5uJDZs1RP4i22avhZPahIPMIJyBduDmNser3OEnfhX2gWw6BaKq5xMvhXvEERjP6LunGBmuwef8up8Q9nqfO6MLQxtHwgcOG6Pg0o9vXvX2agbylSNs4JDkAEarhw8dHcCr9y9sfxfBdubM)2um9pdbKfh9IRITbkdAN(QbkgzjqkFZqaaBzPvNIq9ucpwxZtydGOXmc)bkcBSTUcOIQPXVVy(fLTEI0h7uGQJ5u4Le9(Ak0ITnGrNIacZ1jMJ9Emci3Earhw8dHc4X2EFwV8oXiq1XCk8sIEFnfhX2gGYs4incrp2w3fWnMLzVeZVOS1tK(mea5yNc8Le9(JCwhImWakCCucuiXZjC8aFjrV)mc)HxTVbqPuCLfBpciWczQoJ(5novFJvqtb8oetWK(SoJmpjdbawjf7deO6yo1y3Su9Ak0ITnaMKQxsvXSeoqryJ19tbWKu9sQoJWFGIWgBRRayYLLOBu)OMYbaQUOZBKq5xMvhXvQKZBm5Ys0nQpGrNIacZ1jMXiGEH84rStbWR(Y)Z75KegSyNc8Le9(AkoIraVdXuaRQbLFr5O9ziGMKQxs1ZBrf2tj8aFjrVVpGEHmGhBBak)IYwproYzDiYacjEoHJhqts1lP65TOc7Pe(59iJSceGTWEkHpJWFGIWgBRRavhZPer0nQxtHwSTb8oetX8lkB9ePpdbQoMtboetnfAX2gO6MLQxtXrgc4DiMAkoYqaVdXC8idbyj6g1RPqlgbq0ygH)b0WpVHI7pVTLusmdOIQPXVVag8XkmTbq0ygH)WR23aOukUYIThb0PCap2PaFjrV)mc)bkcBSTUc4DiMAk0Yqa2c7Pe(mc)dOHFEdf3FEBlPKygOyKfGT9U45h7uGdEz03RmeWt1X67iQJyDfqfvtJF)rgzf7uaKr1043xad(yBdi023YVX6AQfPMqkxccPpjSUZvBGVKO3FgH)b0WpVHI7pVTLusmdCTnft)h1uoaq1fDEJek)YS6iUsLCEFTnft)dOt5JhXkOaiJQPXVpEjrVVp2PacyvnO8lkh95n8Q9nwxbkgznYzDiYadOWXrjqLpMHhWnMLzVMr4pqryJT1vaKr1043xm)IYwpr6JDkGBmlZEjGbFgcOt5Jmpj2PafJSukN(bW6L6kZNa]] )

    storeDefault( [[Windwalker AOE]], 'displays', 20171113.171213, [[da0diaqlsISlcqnmf5ysPLbrEgvrttrfxJKkBJa4BKuACKeY5ijQ1rsQ7rsqhublufEibnrfv6Ik0gvu(ivPgjjjNKqEjjvntQsUjb0oPYpHKHskhLKalLa9uWuHQRssXwjjuFvrvRLaK9kgSk1HLSys8yuAYq4YkTzQQpdPgnfDAKETkYSLQBtQ2nQ(nIHdLJtvy5e9CknDvDDuSDc13PW4HOoVuSEvu7xLCAdEa2c7Pe(mc)HVPVbqPgCVe5gd8Le9(AI1IsazXrVcnx2t5iGsNE(S3DIruc0GY33UVWc7PeUnUPaiJY33UVWc7PeUnUPaysQEjBeXs4a98g3CMcOt5dJX5zapywMfHWc7PeUnhbAq57B3hVKO33g3uavaZYS2GhxBWdmYlL(IihbgyFkHFD7f1(XPIc4k9naq1fEDppLJWO6NwPQVUXKllrxP(acU9TSBCin1kaTttEgayLuSpWt1xv4u(4qk4bg5LsFrKJadSpLWVU9IA)4uBaxPVbaQUWR75PCegv)0kv91nI1Vy6Fab3(w2noKMAfG2PjpZNpG1Kyag0N1CymhbSMeJbMNeLa6fYaECtb(sIE)boRjrg4afookbkOiVvfEGM4uPw1QUa(e(hyezm5ATgvtaRjXaVKO33MJaNug4SMezaCuAckYBvHhGLORuVM4XOeGTWEkHpWznjYahOWXrjWacjynx34KaZt5imQ(PvEDpGAmG1Kya45iGhmlZoxQCzFkHhqqrERk8aCgDrSeUnU5eWIT9(SEznfs6ezWduX1gqjU2aOJRnGmU28bSMedHf2tjCBocGmkFF7(dmYkUPafJSWBW2akm((b0lKhyEsCtbQoMzn0nQgRM4X4AduDmZcmjgAIhJRnq1XmlHeDL61epgxBaxPVbMNYryu9tR86Ea1yGQBunwnXA5iGyQLQq70VbVbBdOeGTWEkHp0PO5beo6WhfmGhmu2tQyQf(M(gOcGGAX6vdEd2gGnGS4Ox8gSnqPq70VjqXilbs5Bocm31Vy6FocCszgH)a98gxlsbAq57B3xehbLTEI0g3uanjvVKnx3clSNs4x3dmYkqaKr57B3xehbLTEI0g3ua52diC0Hpkyal227Z6L1mkbQoMzHxs07RjEmU2aih3uapywMfHiockB9ePnhbOSeUaIq0JRvDbSMedWG(SMdmpjhb(sIE)ze(dFtFdGsn4EjYngqGfYuDg9RBCQ(gNNtbqgLVVDF8sIEFBCtbawjf7dyPC09nq1XmRHUr1y1eRfxBapywMfHiwchON34MZuamjvVKnZi8hON34ArkaMCzj6k1pO5vaGQl86EEkhHr1pTsvFDJjxwIUs9bOSeoGvSuo64uxa9c5HX4McGx9L)x3EljmyXnf4lj691epgLacU9TSBCin1Q2j1IKNc4jvwDi1gqts1lzZ1TWc7PeEGVKO33gO6yMfEjrVVMyT4AdOt5dmpjopdWwypLWNr4pqpVX1IuaLo98zV7eJHEpkbqS(ft)h08kaq1fEDppLJWO6NwPQVUrS(ft)dynjgI4iOS1tK2CeO6yMLqIUs9AI1IRnq1nQgRM4XCeWAsmggJsaRjXqt8yocWs0vQxtSwucuDmZcmjgAI1IRnG1KyO(TrHYrq5OT5iWjLze(dFtFdGsn4EjYngqNYb848mWxs07pJWFGEEJRfPaNuMr4Fan8RBO42RBxjLeJaSf2tj8ze(hqd)6gkU962vsjXiqXilaB7DrZnUPaJ8sPViYralvhRVdOgJZZanO89T7pWiR4McynjgAI1YrGVKO3FgH)b0WVUHIBVUDLusmcGmkFF7(Q)WgxBGgu((29v)HnovQnGhmlZo0PO56l)dWgWAsmgyKLiUpjkbkgzjI7tWBW2akm((bkgznWznjYahOWXrjqVgNHhWdMLzrmJWFGEEJRfPauockB9e5aN1KidiOiVvfEapywMfH6pS5iaGTS0QtpxpLWJdjbqLdumYsnC6haRxnRmFca]] )

    storeDefault( [[Brewmaster Primary]], 'displays', 20180121.234407, [[d4JWiaGEq4LQkzxuu41Qk1Jr0mLs62KYSvLRjLYnrI65u5BuuXLvStkTxXUjz)e4NiyyQW4Ksv(msAOuvdMGgoOoOuCuKi1XiQJRISqkSuvflwQA5O8qkYtHwgiADuuQjsrvtfPMmcnDLUiiDvPu5zekxxL2OkQTkLQAZuLTtiFKq1xPOstdjs(UuzKsj2gffnAImEKWjvvDlKionQopP6WswlfL8BGJCOdswWlhOodulU6VjiH2r36VfAqYcE5a1zGAroetSYqgKvkQJjPH87yeS)XHacXFGU0huNGNNBwtf8YbkxShbpDN7q8NeOAz4uL2yB7iimJRvm9FsGc5qmX22rqnUQbASIf80DUdrtf8YbkxmcsHUjGs0W2HymcQtWZZnlDXOoRl2JGu67ChxOJvo0bHQQ(3qmgbBixoqjqyRC3gRCqBPnbn)4v33g8Z8MYnXc5HSzkFCiwqKKXH3GzZg0jb6Wo(sk1angbDsGUM7cIrqojqHWfjxrn22cUfJ6SnksjalObbAAcu(ZV4Tqhupwkbs5JGEa1gSHXRNaH2IXaDbDsGo6IrDwxmc(DFJIucWcstW)ZV4Tqh80DUdXFsGYC5exPyB7iOdEEVZVYjzc8aSqhSIvoyFSYbPgRCqwSYzdcZ4Aft)NeOAz4uL2yB7iOtc01Cz1VYdK(GNUZDi(LHlgbjbA916lcA6dYve5K1cynksjal4NFXBHoOjaSUaH0GGgSPtRC7WeiSHa0GKf8YbQgfPeGf0GannbkhSUSQrrkbybniqttGYTc9mDqeEi51JdrTCGkwinZ2lOtc0H0Xi4P7ChZZzd5YbQGF(fVf6GQR2pjq5IvSGojqh2XxsPM7cIrqkILsetSG6e88CZ(RiYjRfWCXEe0jb6mvWlhOCXi4xZa34GhY9tTCqmcwxwrRdpb7VEEbPGGNNB2FfrozTaMl2JGMF8Q7BJrqTIIM7cI9iy9GLQMxxP78fbnw5G1dwQqjqNViOXkhSEWsLjGwFT(IGgRCqBPnbnytNw52HjqOpJRvm9Ge5o4xPtRdpbRG1RR0D(I8JrqrChVN)4RoTo8eSpizbVCGQ5XPQcAcQLg6NGNUCYVBFUdx93eScE6o3H4pjq9Pwoiw5GSsrDO1HNGvp)Xx9G1LvuMRMye80DUtJIucWc(5x8wOd(D)zGAroetSYqg80DUtZJtvPnQnizqFgxRy6ceAQGxoqjqyZLvbdUfJ6SNbQnOpTaHyPCceAlgd0fKnVGMGAPH(jOdEEVZVYjL(G1dwQOlg1z9fbnw5GuqWZZnlDXOoRl2JGNUZDi(RiYjRfWCXiimJRvm9FsG6tTCqSYb)U)mqT4Q)MGeAhDR)wOb3IrD2Za1IR(BcsOD0T(BHgKYffCTRMaH0CTjwXocE6o3bx93e8ZV4TqhejzC4nyW6blvnVUs35lYpw5G1Lvi88E)Mp2JGWmUwX0pdulYHyIvgYGWSHeO1xBJFRbrUMjbcnytNw52Hz2cecZgsGwFTbRhSuHsGoFr(XkhuROObAShbPR3OwbcfNbUWXEeClg1z9fbn9b1j455MT5YQypc6Z4AftxGqtf8YbQGBXOoRl4N5nLBIfYdzZrwwwmZq2CKHuwSG1dwQOlg1z9f5hRCqnUQ5UGypcUfJ6S(I8tFW(hhcie)b6AEV0h0jb6(ve5K1cyUyeKccEEUz)YWfRCW61v6oFrqJrqNeORbAmc6KaD(IGgJGKaT(A9f5N(GF3FgO2G(0ceILYjqOTymqxqNeO7RrVNRiYvuDXiOtc05lYpgb14kKo2JGBXOo7zGAroetSYqg80DUtJIucWi455Mn22cswWlhOoduBqFAbcXs5ei0wmgOly9GLktaT(A9f5hRCqOQQ)neJrqhxd(nneGglKbBTCRjGs0WCCGkwipKBVdzzkLziwqki455M1ubVCGYf7rWt35oe)jbkKdXeBBhb1kkq6yLdwxw9R8a06WtW(RNxqDcEEUz)YWflLiheMX1kM(xZa34GhYngbnlaqZeqjAy7qmgb5KaLzbaAXk2rWt35oepdulYHyIvgYGuqWZZnBZLvXEeeMX1kM(pjqzUCIRuSTDeK44v33243AqKRzsGqd20PvUDyMTaHehV6(2G1LvTtX3GWVsFyzta]] )

    storeDefault( [[Brewmaster AOE]], 'displays', 20180121.234407, [[d4dXiaGEa1lbe7Iuv8AaPhJOzkj52KYSvLRra3ejvpNsFtsGlRyNuzVIDt0(jOFIGHPIghPQQpJedvIgmHA4aDqQQJIKsDms64QqluclvvPftrlhLhsQ8uOLrGwhPQYeLKYurQjJqtxPlQQ6Qsc9mvfxxL2OkyRiPKntv2oH8rsv(QKGMMKu13LuJus02ivLgnjgpsYjb4wiP40O68u4WsTwjPYVbDudDqYgC5q5bOCX14nbjur6Qa4(ds2GlhkpaLlYbEItvWGSwsz0PmKanfbnFCGbwVhSoMbni45zNvxdUCO0g3zWJ35oebqcLvoCkkBCcCg84DUdraKqjYbEItGZGACP)FCFcE8o3HOUgC5qPnfbPYqhukAy7qmfbni45zNLUzuM1g3zqQ9DUJn0XPg6G)Y28netrqFYLdLcfxf3UXPg01AtWQnE99Tb)oVPTtCcEQQVQNNFcIKmo4gmB2GwfynwZxsf))yg0QaR9VlmMbTkWASMVKk(3fMIG9L1aKEqAdWjO51ZlOrCuJQace0dk3G(mE)ek21mgSoOvbwt3mkZAtrqGA6ljvGSG0ek)cqVkPdE8o3HiasOSc5exL4e4mive88SZcqsKt2lKzJ7miiJR1mdaKqzLdNIYgNaNbbzCTMzaGekroWtCcCg84DUdrGuytrqRcS2)YAaspymdsc1m7Tu0Fmdsfbpp7S(xwh3zqYgC5qPVKubYcwqGMMa1d2xw7ljvGSGfeOPjq9Q(pqhuhe0qOyAyWc2uR12Dycf7t4pOvbwJ0Pi4X7CNQXzd5YHYGFbOxL0bLxnaKqPnUpb5Kqjc2KCjL4eiixsKt2lK5ljvGSGFbOxL0bTGZ7D41wfDWhKf6GDCQbzXPgKsCQbnJtnBqRcSwxdUCO0MIGazgqFl4qUF7LdtrW(YAAdWjO51ZlicoK8(XbUxougNG6R(hSAJxFFBkcQ1u5FxyCNb7hOs7)QBdBPO)4ud2pqLgvG1LI(Jtny)avADqnZElf9hNAqnU0)UW4(eKi3c(AdAdWjizW(v3g2srLPiOiULBYF81G2aCcAgKSbxou6)4uKb197O))g84LtcuQf3IRXBcAg84DUdraKq53E5W4udYAjLH2aCc2M8hFnc2xwtDUCsrWJ35o(ssfil4xa6vjDqGAEakxKd8eNQGbpEN74)4uKAJCdsgSFGknDZOmBPOY4udUnJYShGYnyjTqXylTcf7AgdwhKnVG6(D0)FdAbN37WRTkXmy)avA6Mrz2sr)XPgKkcEE2zPBgLzTXDg84DUdrasICYEHmBkccY4AnZaaju(Txomo1Ga18auU4A8MGeQiDvaC)b3Mrz2dq5IRXBcsOI0vbW9hK6nvCTRMqX0CTjUpNbpEN7GRXBc(fGEvshejzCWnOLlP8MG9duP9F1THTuuzCQb7lRrW59auT4odcY4AnZ4auUih4jovbdcYgsOMzV(Lvfe5A6ekUGn1ATDhM(jumiBiHAM9gSFGknQaRlfvgNAqTMk))4ods3VrUcfRhdEbJ7m42mkZwk6pMbni45zN1)Y64odwY4AnZqOyDn4YHYGBZOmRn435nTDItWt1kqvv9J(OwbQcQ(jyjJR1mdHI11Glhkfk2)Y6Gb3Mrz2srLXmOR1MGfSPwRT7Wek2NWFqZhhyG17bR9FVyg0QaRbijYj7fYSPiive88SZcKcBCQb7xDBylf9NIGwfyT)FmdAvG1LI(trqsOMzVLIkJzqGAEak3GL0cfJT0kuSRzmyDqRcSgiJHjxsKlPytrqRcSUuuzkcQXLiDCFcUnJYShGYf5apXPkyWJ35o(ssfiJGNND24eiizdUCO8auUblPfkgBPvOyxZyW6G9duP1b1m7TuuzCQb)LT5BiMIGwUg4B8j8h3NGv12vhukAywougNGNQ6)PQA1RpFcsfbpp7S6AWLdL24odQ1uH0XDgCBgLz9LKkqwWcc00eO(xa6vjDqdcEE2zbsHnoQrnivXrnF(eeKX1AMbqMb03coKBkcwDqOMoOu0W2HykcYjHYQdc1I7ZzWJ35oepaLlYbEItvWGehV((w)YQcICnDcfxWMAT2Udt)ekM44133geKX1AMbasOSc5exL4e4mObbpp7SaKe5K9cz24od2xwxrjFdc(AJHLnba]] )

    storeDefault( [[Brewmaster Defensives]], 'displays', 20180121.234407, [[d4JPiaGEa1lbO2fvc9AefhwXmPs62sYSvvxdq6MuapNuFtjOll1oP0Ef7MW(Pk9tKYWOQghIs(ms1qLWGPkgochuIokIs1XqvhxjAHuXsbWIvslNOhkP8uOLrHwhIszIaKPIktgitxLlcuxLkrpJkvxxv2OKQTsbYMjPTJiFKc6RuGAAaIVRugjvkBtj0OjX4ruDsLQBPe40OCEk6XizTuj43Go8Hli1qCmOOouC4z(7G0CjNR7wWbVrsVVcsfznOCe07AknfzItWLV(1LFgDrvlUGubnPPQQ7R2qCmOqhRFqYPPQQ7R2qCmOqhRFWLV(1G2PGcKbChRrGgSIjkbhR7bx(6xdQ2qCmOqhNGKBwdki1YRbfNGM0uv19Xns69PJ1piz)1VwhUy5dxqWIz93GItWsQJbfE94ktFXAmODQ6GaQvBHMrQ1bbO)9O7yn6ZViVVV7brkjJ4cMlxqTcCd3yhLsj44euRa3kFhmobzuqbsmumb9ybAWBK07RuqPaLbDOXXrZaaSBOBCbnJDbg59dAstvv3hGD0XUa(GAf4g3iP3NoobjZAPGsbkdYrRaGDdDJl4Yx)Aq7uqHbZaDkXAeObjKSQrAUtbfU1m6kxSaXpi50uv19v(KtS(bjKSQrAUtbfid4owG4hC5RFnia7OJtqky16CfKaN1GAI()R)hTsn4hkdxWjw(GYy5dspw(GRXYNli1qCmOOuqPaLbDOXXrZabjp1xaqjlG4VO)IU77(I8l03OXOUaGSyqKOPyZNb8CmOiwJlswb1kWnKlobx(6xdiMSPogueeGDdDJlO4vTtbf6y5dop5ukOuGYGo044OzaxbxNliiMM4pMCMeDqqbnPPQQ7BxaIrnhuQJ1pOwbUvBioguOJtqa3nrPMOPoaMJbJtW5jhotIo46tvnOkuCblLS571JDKs4wqYPPQQ7BxaIrnhuQJ1py1qE57GX6hC(ekt5FBm1fKahlFW5tOmOcCRGe4y5doFcLPgSADUcsGJLpODQ6GoYERA0xl96bqTAl0msToi50uv19Xns69PJ1p483gtDbPI4eKetZwzF2zYzs0bxdsnehdkk)m6IG1aB5adqWLpgfzmiMgpZFhCcU81Vg0ofuaWCmyS8bLJGEZzs0bNv2NDMbNNCmat0Xj4Yx)6sbLcugeGDdDJlizwRdfhYaUJL3p48jugUrsVVcsfXYhSqYQgPPxp1gIJbfE9u(KtWGaQvN3)Itqz)dwdSLdmabVrsVV6qXfSGZRhCeAVESJuc3coFcLHBK07RGe4y5dsonvvDFa2rhlFWLV(1G2fGyuZbL64eKqYQgP5ofuaWCmyS8b1kWTYNC2fQWSg8gj9(QdfhEM)oinxY56UfCqdmKZQEvE9WXQ6yD3p4Yx)A8m)Dqa2n0nUGiLKrCbdoFcLP8VnM6csfXYhKjaXOMdklfukqzqa2n0nUGesw1inRdfhYaUJL3yqcztbRwNRSW1y9dop5Ge9)VdOy9dwnKxcow)GCZVfNxpgkHpIy9dEJKEFfKaN1Ga0)E0DSg95xippV7Ui)c5nY7EWcjRAKME9uBiogueeuRoV)fuRa3kiveNGZNqzqf4wbPIy5dwXeLVdgRFqQH4yqrDO4qgWDS8gdU(zadSHF4w5)N1GAf42UaeJAoOuhNGGA159VYcxdUBqE94i7TQrFTKS51dGA1wOzKADW5VnM6csGJtqTcCRGe44euRa3kbhNGuWQ15kivK1GAf4gGBZvMaetqxhNGKzTouCbl486bhH2Rh7iLWTGKzTouC4z(7G0CjNR7wWbRycKlw)G3iP3xDO4qgWDS8gdU81VUuqPaL0uv19flqdsnehdkQdfxWcoVEWrO96XosjCl48juMAWQ15kivelFqWIz93GItqnRI43L0ahRXGUo6RguqQLAgueRrFEYYNNhiUO7bx)mGb2WpClRbx(6xdANckCRz0vUync0GAI()R)hTswdQvGB4g7OukFhmobNNC2fQqotIo46tvniHKvnsta3nrPMOPU4e0fGWQAqbPwEnO4eKrbfUaewf7I(bx(6xdQouCid4owEJbRgYrUy5dsizvJ0CNckmygOtjwG4h0KMQQUVYNCI1p48KJlfSliXFmBzUe]] )


    ns.initializeClassModule = MonkInit

end
