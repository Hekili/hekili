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
        addAura( 'ironskin_brew', 115308, 'duration', 6 )
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
            known = function () return equipped.fu_zan_the_wanderers_companion end,
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
            removeBuff( 'pressure_point' )

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
            known = function () return equipped.fists_of_the_heavens end,
            toggle = 'artifact'
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
            if talent.hit_combo.enabled then
                if prev_gcd.touch_of_death then removeBuff( 'hit_combo' )
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


    storeDefault( [[Brewmaster: Default]], 'actionLists', 20171113.171213, [[dWJrgaGEisAtKu2fP61Iu7tiLzd18HO4BIshMQBRupJsANKYEvTBP2Vi(jevdtunoisDEiPHcrKbludNahcIsNcIOogL60alKGwkeSyfworpes4POwMq8CkMiKOPsIMSsMUKlsjESGlJCDrXIueBtKSzsW2jHMgjv9xc9zi18Gi0iHi47KKrtsLXlKkNecToHKRjKQUNI0OGiXVbDqf13(kpBP9bMwx4zusk4zW1fEwZ30zHss12nfjJkjgLKcEgCDgbctUHUwKC7S5zJyv3o3AU6v)zoibcQZNNdfa2MR8A2x5zlTpW06cpZbjqqDUGOrJjDqxKuMrqzoppayqH6zJaYLIQZ7LOPKG00ze7fi4fuEUHnDwZ30zwa5YKyKG3RKyUKG00zeim5g6ArYTtzNvp36RRf5kpBP9bMwx4zoibcQZfenAmPhGq8cQQnjXQLeJusIhzuqb9bgcx4mMspJGKyKbzsIlxIMk9cSjXckUaesCAQ8KyK85zjAZ5230uiEjQYLNNhamOq9SaybG9ze7fi4fuEUHnDwZ30zKeSaW(mceMCdDTi52PSZQNB911SELNT0(atRpoZbjqqDU8onOrRwacXlOQwhiHTjnOfhssLEqDUenzMgGq8cQQ1bsyBsdAXHKuPhuNlrtgXThDQb6aCdA0IlF7OjrRMOLFEEaWGc1ZajSnPbT4qsQoJyVabVGYZnSPZA(MoJOe2M0GojwOKuDgbctUHUwKC7u2z1ZT(6AQ)kpBP9bMwFCMdsGG6CgdjUifO2auKmNNLOnNBFttNiusQ2UPizujXOKuGAdqrYm588aGbfQNdogl6HcaBrmWuNrSxGGxq55g20znFtNrjPa1gGIK5mceMCdDTi52PSZQNB911I(R8SL2hyADHN5GeiOoJSLJPU0hypKgMPedW9aQtTpW0snpuafjrQPnGmrZ(8SeT5C7BA6eHss12nfjJkjMlVxUCLepJCltoppayqH65GJXIEOaWwedm1ze7fi4fuEUHnDwZ30zU8E5Yvs8mYTCgbctUHUwKC7u2z1ZT(6APUYZwAFGP1fEMdsGG6C5yQl9b2dPHzkXaCpG6u7dmTuZdfqrsKAAdit0SpplrBo3(MMorOKuTDtrYOsIrbCpGjXZi3YKZZdaguOEo4ySOhkaSfXatDgXEbcEbLNBytN18nDgfW9aMepJClNrGWKBORfj3oLDw9CRVUw2R8SL2hyADHN5GeiOoJSLJPU0hypKgMPedW9aQtTpW0snpuafjrQPnGmtTpplrBo3(MMorOKuTDtrYOsI5Y7LlxjXSYjNNhamOq9CWXyrpuaylIbM6mI9ce8ckp3WMoR5B6mxEVC5kjMvEgbctUHUwKC7u2z1ZT(6Ai9vE2s7dmTUWZCqceuNlhtDPpWEinmtjgG7buNAFGPLAEOaksIutBazMAFEwI2CU9nnDIqjPA7MIKrLeJc4EatIzLtoJaHj3qxlsUDk7S65wpJyVabVGYZnSPZZdaguOEo4ySOhkaSfXatDwZ30zua3dysmR81RZSakaCmaP6fa2xlskK(1pa]] )

    storeDefault( [[Brewmaster: Defensives]], 'actionLists', 20171113.171213, [[dOJweaGEbK2ePsSlLSnsf7tGy2u6XK8nPuhwXoLI9cTBv2pfnkLQmmvXVbEMuYqfGAWuy4QQdsioLqvhtv68eSqq1sjulgHLl6HciEkvltO8CKmrbstLu1Kbz6eDrqXPLCzuxxq)ua0QeO2Sq2oPs14eaMMsv9zK67s1ijvs)frJMugVsLtckDlbuxtaY9eQCBLY6ivkVMqA8f1Jom3qyzieo6UkRVeD09pRQXwb6ilWHnX0jaqpOC0eALiC0fZwEOySj2ZB7N2XATEFA9S)(OlMhib91gJ(EMgkaWcb636hMvKqD0Kej3xkTjPzkYTzNPrGnnuaGfc0V1pmRiH6OjjsUVuAtsZuKr5OKf4gRPr8MgbBAOaaleOFRFywrc1rtsKCFLSsBsAgDruYcCuOES5f1Jom3qyzieo6nZgJoC7Oe10ia3zAap5o6Izlpum2e75vN32RNwOd7bvQrcs0pWXOlcrzlPa6e2rjkjyhjrYD0DvwFj6kaWcb636hMvKqD0Kej3xkTjPzQ4Eqj2ed1Jom3qyzieo6UkRVeD0BMng9aomRiH6OnnGNCh9UgFI5bsa9jucqxeIYwsb0)HzfjuhnjrYD0H9Gk1ibj6h4y0dK5llWHo6Izlpum2e75vN32RNwOeBAH6rhMBiSmechDxL1xIUcaSqG(T(HzfjuhnjrY9LsBsAMkofayHa9B9dZksOoAsIK7lL2K0mf52SdDrikBjfqVsWrjADKej3rh2dQuJeKOFGJr3vz9L6f(m6YAJrVz2y0HnbhLO1zAap5o6Izlpum2e75vN32RNwOlMhib91gJ(EMgkaWcb636hMvKqD0Kej3xkTjPzkYTzNPrGnnuaGfc0V1pmRiH6OjjsUVuAtsZuKr5OKf4gRPr8MgbBAOaaleOFRFywrc1rtsKCFLSsBsAg9UgFI5bsaDkvwFjkXM9r9OdZnewgcHJEZSXOdZUpBnn01j3qxmB5HIXMypV682E90cDrikBjfqN39zlP2KBOd7bvQrcs0pWXO7QS(s014Xwhnj1xJtEPaHNmiX9Ql7PXJvQTG4OsvYGehLCKRrkhLOKFqNZGBVcOG14Xwhnj1xJtEPaHNmE07A8jMhib0NqjaLOe9MzJrhEY9THsYPUzAeuoIpQs3zkuIi]] )

    storeDefault( [[Brewmaster: Combo ST]], 'actionLists', 20171113.171213, [[dOdUdaGAIGwpks2ekQSlb2grAFOOy2K8nIYVLyNGAVu7gv7hiJcLcdJqJdLk9yHgkkv1GbQHROoOG6uebogbhw0cvWsrHfdPLtQhIsfRcfPwgu65qmrukzQsYKbmDPUOGCBO6YixhK2ikL60kTzjvpdLmpuu1xrPOPHI47eHETc9zOy0ev)vroPKYljI6AeropiwjkkTouQYtvTfCLFiEIQiap4)zkUPAzQS3c3WyLYU(pQ3523NTO6juv7bFgKIseYWyffKjkdlRabrwImHj(mOeas1It((HJ9w4iUYWcUYpeprveGh8FuVZTFNkI3bOQmowG2tXcoAjG4jQIayUm2BHhmsyMqWte5bAkbGm1loX8yIamTqGK8HtCYFqLXXc0ge436DKabMnK8LaFgKIseYWyffKkilqKLFy0vTneFuvghlq7jKwVJKpdkbGuT4KVFnoWgZUO95fo5)OEN7kiZKpYIhDBySUYpeprveGh8HtCYxYegqGpEIi3NbPOeHmmwrbPcYcez5xJdSXSlAFEHt(pQ3523pm6Q2gI)iHzcbprK72WSCLFiEIQiap4dN4K)GkJJfOniWV17i5ZGuuIqggROGubzbIS8RXb2y2fTpVWj)h17C77hgDvBdXhvLXXc0EcP17i52WmXv(H4jQIa8G)J6DU99zqkkridJvuqQGSarw(14aBm7I2Nx4KFy0vTneFnue5lhZKeMa0KexoGpCIt(mGIiF5yabMztacey2C5aUnSKCLFiEIQiap4)OENBFacfA96bJeMje8erEa0zFgKIseYWyffKkilqKLFnoWgZUO95fo5hgDvBdXhvtzlFQuFQ(QjF4eN8h0u2YbbUuhey2E1KBdl1v(H4jQIa8GpCIt(vlgsdcm7NkCFgKIseYWyffKkilqKLFnoWgZUO95fo5)OENBFItAmqcIq1AI3mJOFy0vTne)EXq6P5uH72TpCIt(dAsI4jstA2dey2PGJwab(vUTb]] )

    storeDefault( [[Brewmaster: Combo AOE]], 'actionLists', 20171113.171213, [[dCtQdaGAIqTEcf9sIO2LISnOQ9rOWSj1TjQDkQ9sTBe7xr9tIaddj)wKHsOudwHgUqDqKYXi45qAHczPeYIHYYj5Hcqpv1YaY6iuLjse0ubQjdy6kDri6WsDzuxhuTrcv61c0MfuttaDAjFLiKpRGVte5XGmocvmAKQXlaoPG8mOY1iuvNNiTscL8ni8xqzlyW(ijnMMbCKFULz)iflj5gDzL4npgWKmwAEKMeG0xc5WnC96iFrSMBu2zquciOqac3KafoQad0)Xmu16sm7TseNbHxC8PbTvIGAWolyW(ijnMMbCKFULzFKbiwNakYW8OK5bFrSMBu2zquc4fqmrHZpebOG6nP8jjc7FivfV((0WkDTs95aeRtafzawqEWRZGmyFKKgtZaoYp3YSVK5H5Xl3O09fXAUrzNbrjGxaXefo)qeGcQ3KYNKiS)Huv867tdR01k1pipadvUrP71zCgSpssJPzah5NBz2pG0R5Xi4k01xeR5gLDgeLaEbetu48drakOEtkFsIW(hsvXRVpnSsxRuFi6fmm4k01RZbAW(ijnMMbCKFULz)if3l95Xu45rXTuSViwZnk7mikb8ciMOW5hIauq9Mu(KeH9pKQIxFagdE4Wtb5byOYnk9j4X(0WkDTs9XuCV0HLcdlCPyVol(gSpssJPzah5FivfV((Iyn3OSZGOeWlGyIcNFicqb1Bs5tse2NgwPRvQVcok9ImatIBagMKkcGFULzFrWrPxKH5rXQb45rjQiaEDgVb7JK0yAgWr(hsvXRpty1G0ji4kftwXGYxeR5gLDgeLaEbetu48drakOEtkFsIW(0WkDTs93AGvWIBTSFULzFW1aRMhf7wl71zegSpssJPzah5FivfV((Iyn3OSZGOeWlGyIcNFicqb1Bs5tse2NgwPRvQpMUHcMGVWqxvfK9ZTm7hPBOGj4784xvfK961)qQkE99Ad]] )

    storeDefault( [[Brewmaster: Standard ST]], 'actionLists', 20171113.171213, [[d0d9eaGAfbTEIO6LkIAxc12ik7tLOMnjZxrKNdPVHKUTqoSKDQI9sTBO2Vk1Oer0WiLXPsK)ksdvLqdgIgUahKu1PervhdPoNIalujTuI0Ir0Yj8qvcEkyziyDIO0efrQPcHjRW0v1fjQoTuxg11vuBuejpwP2mPY2jc(UkPVQi0Nf08er41kspdjgTsmEIqNueMgrKRjIIZJqRKikBsev(TO20gHb54IuXdVA4urSHvbFnQqFwKS3iHVWJsmUrcimK0SUAw9E1GuwXfk7dbnAQAujqjMwJIMKKKbyl6G3Gb97VZyuJWhAJWGCCrQ4HxnCQi2WK5WBKquHUyqkR4cL9HGgTmAQXAumKap6D9zHbCgZg0t2Q(jAykhMIgvOlgGTOdEd(9HGryqoUiv8WRgGTOdEddMCwNU4PCykAuHUephmPjnyYzD6Ird4DxQ0bRAjWcIXZbgKYkUqzFiOrlJMASgfdjWJExFwyaNXSHtfXgwfC9l3iZ6UrMuTGnONSv9t0aPGRFjnRlvxly)(qXimihxKkE4vdWw0bVbdszfxOSpe0OLrtnwJIHe4rVRplmGZy2WPIydRQApnp)3iHx0tzd6jBv)enqQQ9088NI(IEk73hjzegKJlsfp8Qbyl6G3WoNvJ8vCCWSO1rSXHPKc(A8EPeHmAsSZz1iFfhhmlADeBCykPGVgVxkriJMgvs0GEYw1prdFhYI0GsfzibE076Zcd4mMniLvCHY(qqJwgn1ynkgoveBarhYIBKxSur(9jzmcdYXfPIhE1aSfDWB4l80ghMCOFfgYI4kkpJ)lhmlADet)fbJUKvdd6jBv)enWsmqLhnomDkhAibE076Zcd4mMniLvCHY(qqJwgn1ynkgoveBqUedu5rJdVrozo0VpYmcdYXfPIhE1aSfDWBWGuwXfk7dbnAz0uJ1OyibE076Zcd4mMnCQi2G0z0LghEJuYQbFJCInEyqpzR6NObXm6sJdtNWAWPxB8WVpuncdYXfPIhE1aSfDWBWGEYw1prd7LoLCwG(gsGh9U(SWaoJzdszfxOSpe0OLrtnwJIHtfXgUWsFJCDwG((95sgHb54IuXdVAa2Io4nyqkR4cL9HGgTmAQXAumKap6D9zHbCgZgoveB4cl9nYjwsGnONSv9t0WEPtVwsG97ZeyegKJlsfp8Qbyl6G3GbPSIlu2hcA0YOPgRrXqc8O31NfgWzmB4urSbeDilUrEXsfDJmjPtEd6jBv)en8DilsdkvKF)gGaE3LQL867m2hcYUKFBa]] )

    storeDefault( [[Brewmaster: Standard AOE]], 'actionLists', 20171113.171213, [[dOJieaGAssA9Qq6LKKAxQuVwfmBIMpjfFduEmi7uu7LA3iTFvYprOQHrOFd0HLmussmyv0WjvhKGofjrDmeTncSqHAPKWIHYYf8qsQ8uLLbWZHQjIqXuHutwKPRQlcjpduDzuxhI2icvoTuBMuSDesRJKiFLKsttfQVJq8xa9zemAimEsQ6KKsJtfIRHqPZtIwjjb3wiJIKqBsJ2dfTWKCYXEdk06VNxUIyV4atKOc)5GkDDUVOPkKUofs8O8uWsUWzNbisctega43KIWfp(yVPZqDj7JwFdsDgGGJ4je6BqkUr7mPr7HIwyso5yVbfA93Ztiwl7xPhREDjyQPeaEGj4PLMAO6bdEuqk7PGLCHZodqKuajSBr4E5kI9qPEDjyQPeUovntWVZamApu0ctYjh7nOqR)EEkyjx4SZaejfqc7weUNwAQHQhm4rbPSxUIypvZeUoxuHJWtiwl7xP3bMaq8OchHFNHB0EOOfMKto2BqHw)9smgsnAUpWeaIhv4iUrQRg1KymKA0CJRZqDjbMyztuoO8gPUNcwYfo7marsbKWUfH7PLMAO6bdEuqk7jeRL9R0dlW1JaiOgGA6a7LRi2loW1J46euZ1jX1b2VZhB0EOOfMKto2BqHw)98uWsUWzNbiskGe2TiCpT0udvpyWJcszpHyTSFLEyYc6aiYhi(h6dSxUIyVyzbDae5FDUp0hy)otSgThkAHj5KJ9guO1FppfSKlC2zaIKciHDlc3tln1q1dg8OGu2tiwl7xPxajoIMsaOQwjgirAAYlxrSNcK4iAkHRtvOs81PABAYVZcmApu0ctYjh7nOqR)EEcXAz)k9Gq0aXqgWFpT0udvpyWJcszVCfXEQdrFDgJmG)Ekyjx4SZaejfqc7weUFNHz0EOOfMKto2BqHw)98uWsUWzNbiskGe2TiCpT0udvpyWJcszpHyTSFLEqiAGePik7LRi2tDi6Rt1weL978rmApu0ctYjh7nOqR)EEkyjx4SZaejfqc7weUNwAQHQhm4rbPSNqSw2VsVVjWbG6LmYlxrSh6MahUovLsgDDQIKQSF)EedRPqkFh73g]] )

    storeDefault( [[IV Brewmaster: ST]], 'actionLists', 20171113.171213, [[dCtfdaGAqH1dq6LsIAxGsVga7dGy2cDBrStG2lz3OSFrAyuQXbs0qLezWcA4GQdsv65u5yOQZbkAHGyPcSykSCeFdv6PQwMKADauMivHMkfnzKA6sDrjPNbsYLHUoLSraQ2kifBgvCEQkNwPVcsPPbs13LeoSIhlXOrsFgjojvv)fqxJQO7bsQvcsyBuf8BrT4LPo4KG6(HM0qieSIKX1ibWsdVPUhroJvSfe9amIJdfyTnpxByA7jS811CHom1FHSWBDDVLEZmNmfiVm1RYgJisli6Vqw4TUo4KG6vgPKg(KXrv3RXg32NoaifGUKXrvpaDzlsbDYuTEagXXHcS2MNlVTUFg9wMot0zzgQwG1YuVkBmIiTGO)czH366GtcQdjofaYwDA4BYcaQ71yJB7t3iofaYwnqxtwaq9a0LTif0jt16byehhkWABEU826(z0Bz6mrNLzOAbcvYuVkBmIiTGO)czH366GtcQdHGttnnmZjneWxcQ71yJB7t3GGttfyMdqolb1dqx2IuqNmvRhGrCCOaRT55YBR7NrVLPZeDwMHQfi0LPEv2yerAbr)fYcV1nS4WbwILJ6YOaegdncSILrdlb5qqh1XiI6GtcQhy5OUmkPHqXqJPHq7YO19ASXT9PtSCuxgfGWyOrGvSmA9a0LTif0jt16byehhkWABEU826(z0Bz6mrNLzOAb6Pm1RYgJisli6Vqw4ToYqcfFWwSieK1PHacuNg6bp1bNeu3CPGK0WknXeDVgBCBF69sbjaHpXe9a0LTif0jt16byehhkWABEU826(z0Bz6mrNLzOA16how2jUa60BMjWApaLQLa]] )

    storeDefault( [[IV Brewmaster: AOE]], 'actionLists', 20171113.171213, [[dSt6daGAkkA9iiEjLO2LevVwGSpkQmBr9ne62sYHb2PI2lz3OSFk1prq1WqvJdbP1rrHHsrkdwqdxbhKs68sKJHOZrrPfQqlLkwmvA5i9qeuEQQLjPEovnrks1uPWKb10L6IOsxtIYLHUUe2ifj2kfr2mcSDkI6zue8vkc9zq8DkH(li9yrgnQy8uICsbmnkbNwP7rrsRKIQ2Ma1VfArkd9jOc1dys2HJu0IvaFJuZWo0kHZv30rcaf5wJ6oygbEuZAEsI8MLVSYjRRjAbZQ)eDhADDRPEJmVm0Kug6Cza3mcRr9NO7qRRpbvOoxlnKJWldIDOLri6wD382L0rlnKJWldc0Gqi6oOpwqtOxgQ1DWmc8OM18Kej51dWG3eOJuDwKHQ1Swg6Cza3mcRr9NO7qRRpbvOULri2HVc45OB1DZBxspiecuFfWZr3b9XcAc9YqTUdMrGh1SMNKijVEag8MaDKQZImuTMMGm05YaUzewJ6pr3HwxFcQqDcJZAhowq9TUv3nVDj9eNfQBb136oOpwqtOxgQ1DWmc8OM18Kej51dWG3eOJuDwKHQ10cYqNld4MrynQ)eDhADqQxtgHch7YDPiO5ansaucwkAhAo7qs9jOc1hPiO5yhgjWo0uwkQB1DZBxs3LIGMd0ibqjyPOUd6Jf0e6LHADhmJapQznpjrsE9am4nb6ivNfzOAnltg6Cza3mcRr9NO7qRRpbvOUtHNZYGyhAEamAhAIldw3Q7M3UKoTWZzzqGAMayeQfxgSUd6Jf0e6LHADhmJapQznpjrsE9am4nb6ivNfzOAndwg6Cza3mcRr9NO7qRJmKcPu5PckfzTDO5mv7WGlZ286tqfQBSqqQDOPbYv6wD382L07fcsHoaYv6oOpwqtOxgQ1DWmc8OM18Kej51dWG3eOJuDwKHQ1KOm05YaUzewJ6pr3Hwx3bZiWJAwZtsKKxpadEtGos1zrgQpbvO(ygKckw02HVPBqOUd6Jf0e6LHA1Q1)aMwqEjeqVrMM1btOQLaa]] )

    storeDefault( [[IV Brewmaster: Combo]], 'actionLists', 20171113.171213, [[d0tRfaGALcA9KsLxQuODrrBtPK2Niz2cnFLI8CiFtjCBO6WQANcSxPDJY(j5VemmcnoLOQRPuudvjknyIgouCiLcCqLQoMioNsPAHuWsbPftQwoQEOsP8uQwgPyDkr0ejLstvjnzqnDvUOsLlJ8mLi11fLnQejBvjk2SiLTls13PqFLuQAAkLyEkr4Xu6ZIQrdLgpPuCsq0MiLCAfNhewPsu51c63a3KUwp4XP6qUmkPboze)rhXxsLCBaCDqDTLs7ZIxnuhkfPhrnqJyYcXTlUzZenAwSLTx3T8bZvV(E7nagQRniPR13XE9ibxd1DlFWC13aLedNsxi3cBMyQhFBii7eqhFcjLCtBsjTaqegyKzIjJpPbXWYf05Krtl2NNtiLCjusn1dECQ(gPCL0XFe2671N4CqupKYfq4pcBDOecKXTeQR9QdLI0JOgOrmzrIyDizWJ9paVodWOEnqtxRVJ96rcUgQ7w(G5Qxp4XP6gIVneKDkPF8jKQVxFIZbrD94BdbzNa64tivhkHazClH6AV6qPi9iQbAetwKiwhsg8y)dWRZamQxdw6UwFh71JeCnu3T8bZvhdNsxi3cBMyQhFBii7eqhFcP6bpovFDYjUsUSFeV(E9johe1VjN4cy(iEDOecKXTeQR9QdLI0JOgOrmzrIyDizWJ9paVodWOEnylDT(o2Rhj4AOUB5dMR(BVjDsGye(qiLmLsMOKAPKwaicdmYm1JVneKDcOJpHKjNW)HHuYukPOsQLsAbGimWiZmKYfq4pcRjNW)HHuYukPy9GhNQVtBWebWdlxj3iLxFV(eNdI6K2GjcGhwUqiLxhkHazClH6AV6qPi9iQbAetwKiwhsg8y)dWRZamQxd2CxRVJ96rcUgQ7w(G5Q)2BsNeigHpesjtPKjkPwkPfaIWaJmt94BdbzNa64tizYj8FyiLmLskQKAPKwaicdmYmdPCbe(JWAYj8FyiLmLskwp4XP6Bd7OKgY4OR(E9johe1Tyhb9mo6QdLqGmULqDTxDOuKEe1anIjlseRdjdES)b41zag1RbBTR13XE9ibxd1DlFWC1F7nPtcWGZmKYfq4pcRsMsjfvsTuslaeHbgzM6X3gcYob0XNqYKt4)WqkzkLuuj1sjTaqegyKzgs5ci8hH1Kt4)WqkzkLuSEWJt1nWP)WQKG0uYLA4u996tCoiQRZP)WkastiTHt1Hsiqg3sOU2RoukspIAGgXKfjI1HKbp2)a86maJ61GfDT(o2Rhj4AOUB5dMRUfaIWaJmt94BdbzNa64tizYj8FyiLmLskQKAPKwaicdmYmdPCbe(JWAYj8FyiLmLskwp4XP6qZqyhwUsUCpmPKA)WGRVxFIZbrDEgc7WYf2WhMemom46qjeiJBjux7vhkfPhrnqJyYIeX6qYGh7FaEDgGr96v3Xq25JJ293aynqZwx(ETa]] )

    storeDefault( [[IV Brewmaster: Defensives]], 'actionLists', 20171113.171213, [[dStHeaGEQkvBIQQAxaTnKQY(ukz2cwgj1VbDBPQdRYoLk7fA3QA)uAuivzyamoQkX5PIHsvrnykgoIoijYPuk1XuQohvvAHKKLcOftulxYPv8urpMWZLYePQIPIuMmrMoPUijQlJ6zuvORtL(MsXwPQu2SqTDQkyvcrRJQsAAcbFxjJePQ6ZimAQY4fsNePYTecDnQQY9iH(lsEnj4NuvKXDKgM(HJp3GgvHzsYI5cJVF6b(yNA6ZxWS76zmPZ3SgvfV6VMMlF1A8dhZFB8bUHjqoWxJXo1a23aWVa8h4UA1BIGFXeiFso0MEgt6zncimibxpiPBnXoZtqjx8cu4Dfb3O6VOwteTgbegKGRhK0TMyN5jOKlEbk8UIGBuX1j0d8VG1ST1eP1iGWGeC9GKU1e7mpbLCXlWIfExrWyQKqpWVH0WUDKgMk)NCGLqvyMIAi1ykGWGeC9GKU1e7mpbLCXlqH3veCZAu0Aayn(3AA6JGGlqsUe8RP6VOuEKwZwkAnQbGz31ZyQkCcfSgFkQ1OQ4fMkjpHr7GPC4ekqbJsjx8ctGCd6wcUH0qnMa5aFng7udyFZoamP7LgXPHfMp8zuJDQrAyQ8FYbwcvHzkQHuJjMDxpJPp7wtSZ8ewJQIxyQK8egTdMKU1e7mpbLCXlmbYnOBj4gsd1ycKd81yStnG9n7aWKUxAeNgwy(WNrn25Jinmv(p5alHQWmf1qQXuaHbj46bjDRj2zEck5IxGcVRi4M1OO1iGWGeC9GKU1e7mpbLCXlqH3veCJQ)II5YJFG8j5GztudPgt6EPrCAyH5dFgZURNXKUc(nfM3Auv8ctGCGVgJDQbSVzhaMa5g0TeCdPHAmvsEcJ2bZPGFtH5PKlEHjq(KCOn9mM0ZAeqyqcUEqs3AIDMNGsU4fOW7kcUr1FrTMiAncimibxpiPBnXoZtqjx8cu4Dfb3OIRtOh4FbRzBRjsRraHbj46bjDRj2zEck5IxGfl8UIGrn2fbKgMk)NCGLqvyMIAi1y6XxyEcQgPhxmOa6(ARzlfTMD)Bn0ZA84lO9aL44rmARzlfTMM(0GNwFcfOiHlUSMiTMnG(ZAI0A84lmpbvJ0JlguaDFT1SnMDxpJPYrj5G1q)x1JPsYty0oyYrj5aL3v9ycKBq3sWnKgQXeih4RXyNAa7B2bGjDV0ionSW8HpJAuJzkQHuJjQrea]] )

    storeDefault( [[IV Brewmaster: Default]], 'actionLists', 20171113.171213, [[d4tTfaGEvfPnrjAxIQTbs2Nur8BcNgXSjArQQ6MQQ48GuFtuSmsLDIu7vz3a7xk)KusdtLACQkuFMsAOQkIbRIHJehIuItPQGoMiDovLyHQKLkvzXGA5K8qvv6POESKwNuPjkvyQKIjRktx4IuQUQur1LHUoLYZqsTvvLAZKsTDKK)kIBlX0uvuFxuAKsfPxlv1OvvGdt1jjv9CkUMQs6EucRuQOCqqmkvfYlDAgZuWkXLKp1dIamADq9XJ7a12TjJDnUhkr3GJw3DAM7VC)18uD6Y85VmMRkcLy8yi1GiaMPz0PtZy7ahwIVDnMRkcLyCiSAvI5eqGkLnkHzmeyIKeqp2qbDvYh4GxIjuK(4y9GhP6Hqngia44EOeDdoAD3PqLMj)M6X0EbhZuqx1oDQdETdhksFCXO1nnJTdCyj(21yUQiuIXHWQvjMtreebW06SXquwnJbEbTqiFjzD1yiWejjGEmfrqeGX6bps1dHAmqaWX9qj6gC06UtHknt(n1JP9co(tebrawmAQNMX2boSeF7AmTxWXDGAJadHk0mMRkcLyC4G(eG12XY2XMbtEO2iWqOcnTJLTJwANpQDcxIGihw61(cBrsvuGf5iWHL4RDSSDOOqQsSwF5P5WsV2xylsmHI0hBNpCmeLvZyGxql(FPWSf3eOQB70bQncmeQqZ)XqGjssa94QlLjEnicqIKyIX6bps1dHAmqaWX9qj6gC06UtHknt(n1J)r8O9co(sHzlUjqv32PduBeyiuHMfJ(ZtZy7ahwIVDnMRkcLy8yAVGJ7Cd2o6dSygdbMijb0JTzWesGfZ4EOrytvrZ0SyCpuIUbhTU70mP3J1dEKQhc1yGaGlg9xNMX2boSeF7AmeyIKeqpU6szIxdIaKijMymxvekX4WLiiYHLETVWwKuffyrocCyj(gdrz1mg4f0I)xkmBXnbQ62o)kkWI2bIwT)FCpuIUbhTU7uOsZKFt9y9GhP6Hqngia4yAVGJ)vuGfJ)r8O9cow)3TZLcZwCtGQUTZVIcSyXOHAAgBh4Ws8TRXqGjssa94QlLjEnicqIKyIXCvrOeJ1s4see5WsV2xylsQIcSihboSeFTJLTJxdcvyccWcbnwKogIYQzmWlOf)Vuy2IBcu1TD4Wbpx9AhwZ)X9qj6gC06UtHknt(n1J1dEKQhc1yGaGJP9coMdh8C1RDynJ)r8O9cow)3TZLcZwCtGQUTdRzXOZmnJTdCyj(21yUQiuIXAjCjcICyPx7lSfjvrbwKJahwIV2XY2XRbHkmbbyHGM2PtAN0X0EbhZHdEU61oq0Q9XquwnJbEbT4)LcZwCtGQUTZVIcSODyn)h3dLOBWrR7ofQ0m53upwp4rQEiuJbcaogcmrscOhxDPmXRbrasKetm(hXJ2l4y9F3oxkmBXnbQ62oq0Q9flgt7fCS(VBNlfMT4MavDBNoqTDBYyXg]] )

    storeDefault( [[SimC Windwalker: default]], 'actionLists', 20171113.171213, [[dieKmaqirQArsrTjOsJIuLtrjmlsu0UqyyKKJPQSmOINrIutJeLUgjQ2gjs(MiLXrIcNtvfwNiY8iv19eH9rIOdkfwOuKhsQmrse6IQQ0ivvrCsvv5LQQintrQCtsQDsPgQQkklvQ0tPAQusBvvv9vru7L4ViAWkDyvwSQ4XIAYcDzuBwQ6ZKsJwv60GEnu1SP42qz3q(nWWjHJtIGLJ0ZfmDjxxkTDkrFNuCErY6vvr18Lk2VILpXQ4Ucodpd8NFfeGeBCuQFiU9HXI7qmDZMmef1Cg8mnPzJC)1AkX7Yg(cSyJJQV0(u9PI47hFQuPCX9mfQOex8g5ccqbXQy)jwf)x09y4O0K4EMcvuIxaTAnmbevmL2QOcZI7S6nBDuTCre5N2(EI8fkislrRIzTq8gpqdSsjEqbFuY3dfjdffINf)pueMVcqfhbqS4QbX)pQ9HXIlU9HXI7k4Jo7p5qXz9IcXZI3Ln8fyXghvFP9Ps8UCa0sZCqSkL46E5mE1alzmgvYJ4Qbr7dJfxkXghXQ4)IUhdhLMe3ZuOIs8x(m1lHICnR(ZQIq5I34bAGvkXlqB(Le0tI)OyN46E5mE1alzmgvYJ4QbX)pQ9HXIlU9HXIBf0MFNf0p7p9OyN4nOAdIdrftT8mj(HkLPICr(YNPEtOIq5I3Ln8fyXghvFP9Ps8UCa0sZCqSkL4)HIW8vaQ4iaIfxniAFyS4sj2kTyv8Fr3JHJstI7zkurjEb0Q1WekafeGcZI7S6n7tBFprGPmcwPiAvmBNoZ(023tekafJKpA9sEOizpKYeTkMTtNz1B20pBDggvebMYiyLIGr3JHJZI7SffIWZfHckitCAHgyLIOvXSwmBNoZ(023t8yaGOPnueTkMTtNzRJQLlIcIXKfGmc5z1pXSkLQzTq8gpqdSsjUcqbbiX)dfH5RauXraelUAq8)JAFyS4IBFyS4)mqbbiX7Yg(cSyJJQV0(ujExoaAPzoiwLsCDVCgVAGLmgJk5rC1GO9HXIlLyRSIvX)fDpgoknjUNPqfL4fqRwdtKbateObfMf3z1B26OA5IOGymzbiJqEw9tm7pM1cXB8anWkL4fOn)sc6jJ8vVI)hkcZxbOIJaiwC1G4)h1(WyXf3(WyXTcAZVZc6NvjYx9kEx2WxGfBCu9L2NkX7YbqlnZbXQuIR7LZ4vdSKXyujpIRgeTpmwCPeBLlwf)x09y4O0K4EMcvuIR3S1zyureykJGvkcgDpgoolUZMbateObreykJGvkckJDquyw9tmRQzTy2oDM9PTVNiWugbRueTkeVXd0aRuINpJH8YfeGinWqjUUxoJxnWsgJrL8iUAq8)JAFyS4IBFyS46oJz2g5ccqZMoyOeVbvBqC0HXjA2Hy6MnzikQ5m4zAsZgykJGvQMfVlB4lWInoQ(s7tL4D5aOLM5GyvkX)dfH5RauXraelUAq0(WyXDiMUztgIIAodEMM0SbMYiyLskXwPeRI)l6EmCuAsCptHkkXt)S1zyureykJGvkcgDpgoolUZQ3SpT99eHcqXi5JwVKhks2dPmrRIz70z2mayIaniIqbOyK8rRxYdfj7HuMi)EuTCy2eZIZSwiEJhObwPepFgd5LliarAGHsCDVCgVAGLmgJk5rC1G4)h1(WyXf3(WyX1DgZSnYfeGMnDWqnREFwiEdQ2G4OdJt0SdX0nBYquuZzWZ0KMnW9nlEx2WxGfBCu9L2NkX7YbqlnZbXQuI)hkcZxbOIJaiwC1GO9HXI7qmDZMmef1Cg8mnPzdCVuIDAIvX)fDpgoknjUNPqfL4PF26mmQicmLrWkfbJUhdhNf3zzLqluHcosePqeEisl5lGIiZalz6S4oREZMbateObrekkeptc6jRxMudefnaAKGYyhefMv)eZ(PmMf3zZaGjc0Gi6HHkqc6j7BPPiOm2brHz1pXSF4mlUZMFHe5wkLr1SkzIzv6zXD2mayIanickmarAjdTis8WmEckJDquyw9tm73SD6mBDuTCruqmMSaKripR(jMfhLpBNoZMbateObruG28ljONmYx9sqzSdIcZQKZ(9HZSwmlUZMbateObrekafJKpA9sEOizpKYe53JQLdZMy2pXB8anWkL45ZyiVCbbisdmuIR7LZ4vdSKXyujpIRge))O2hglU42hglUUZyMTrUGa0SPdgQz1dhleVbvBqC0HXjA2Hy6MnzikQ5m4zAsZg4(MfVlB4lWInoQ(s7tL4D5aOLM5GyvkX)dfH5RauXraelUAq0(WyXDiMUztgIIAodEMM0SbUxkXwziwf)x09y4O0K4EMcvuIN(zRZWOIiWugbRuem6EmCCwCNn9ZYkHwOcfCKisHi8qKwYxafrMbwY0zXDw9MndaMiqdIiuuiEMe0twVmPgikAa0ibLXoikmR(jM9tzNf3zZaGjc0Gi6HHkqc6j7BPPiOm2brHz1pXSk1S4oB(fsKBPugvZQKjMvPNf3zZaGjc0GiOWaePLm0IiXdZ4jOm2brHz1pXSFZ2PZS1r1YfrbXyYcqgH8S6Ny2pLpBNoZMbateObruG28ljONmYx9sqzSdIcZQKZ(9HZSwmlUZMbateObrekafJKpA9sEOizpKYe53JQLdZMy2pXB8anWkL45ZyiVCbbisdmuIR7LZ4vdSKXyujpIRge))O2hglU42hglUUZyMTrUGa0SPdgQz1tPTq8guTbXrhgNOzhIPB2KHOOMZGNPjnBG7Bw8USHVal24O6lTpvI3LdGwAMdIvPe)pueMVcqfhbqS4Qbr7dJf3Hy6MnzikQ5m4zAsZg4EPe7Fiwf)x09y4O0K4nEGgyLs88zmKxUGaePbgkX)dfH5RauXraelUAq8)JAFyS4IBFyS46oJz2g5ccqZMoyOMvpL1cXBq1gehDyCIMDiMUztgIIAodEMM0SU1MfVlB4lWInoQ(s7tL4D5aOLM5GyvkX19Yz8QbwYymQKhXvdI2hglUdX0nBYquuZzWZ0KM1TkLuIRe5(R1ustsjca]] )

    storeDefault( [[SimC Windwalker: precombat]], 'actionLists', 20171113.171213, [[ditrcaGEQOAxujTnQaZgWnPOBlQDsP9s2nQ2pvvddL(TsdLkKblqdhroOaogqNJQWcPGLQGfJILlYdrupv1YqW6OcAIurAQcAYGmDPUiOYLHUocTvqvBMkkBNc9AQsFLkvFMQOVtL4XcDyjJwH(gvLtckDAKUgvOopO45k6VuP8mQiwGku)KWiTaOoVA6YLLGd8q3wzu)0mz)bDNYHCPa8Ijh6piPeg3mt16diawtuwcSG(azbzDf0dqwwhR)yIsQ11deB6YNkuwqfQdhVyaqizq)XeLuR3RNEcGUsAB6YN6byOa0ggDsBtxUoSCiAS6nPZxoQBUqWxjBLrDDBLrDhTnD56diawtuwcSG(az1hW5smfXPcvRtEeJEnxJyg5Ty0nxiBLrD1YsqH6WXlgaesg0dWqbOnm6XrQBmetZwhwoenw9M05lh1nxi4RKTYOUUTYOo5rQ)GgiMMT(acG1eLLalOpqw9bCUetrCQq16KhXOxZ1iMrElgDZfYwzuxTSorH6WXlgaesg0dWqbOnm6XrQBUugrDy5q0y1BsNVCu3CHGVs2kJ662kJ6KhP(d6Eze1hqaSMOSeyb9bYQpGZLykItfQwN8ig9AUgXmYBXOBUq2kJ6QvR7u0zfrGwgulb]] )

    storeDefault( [[SimC Windwalker: sef]], 'actionLists', 20171113.171213, [[daKhfaqifjwKIsBsrXOue5ukcnlfrDlbPAxeyykXXiLLPO6zcsmnfbUgOkBtqkFJG6CkszDKQmpfbDpcv7trshKewiOYdvQMiPcxKqAJcs6KcIzQiv3uPStqgkPIAPKONImvfARKk9vsvTxP)QGbtXHfTyL0JPQjRkxgAZeIpdkJMKCAu9AbA2u52cTBu(nrdxqTCGNRQMUkxNKA7eKVtOmEqvDEbSEsfz)u6Q1Xsuy0ZthxNYJlzfAEOnTsqzelr84U1OpN9elDbrGEwZhfPKs0H5hl08fnH1w0weOnnTLf4vI8aE4Rujf(Jlz)owiTowsuwU6WxHRe5b8WxPPynHbOqdW8pbAcoomemeoDrRzgRbziawabE1aaYoRrCRbziawabXe(wZmwJxfxGxnaGSZAMqRrRKIvUJFbkDCyiyiC6IL2vH(GBsHWiYUUwAt(0nbqzelvke2J7ZtckXKmSeugXsJCyiWA050flPaa7xYhW7WHlbWW7lUwjLOdZpwO5lAcRTusj(LQbE83XEL2d4D4ycGH3VWvAt(GYiwQxHM3XsIYYvh(kCLipGh(k5vXfet4BnHU14vXf4vdai7SMPkU1OznZynidbWci44rC4KdXe(wZuf3AweaVskw5o(fOuc8jdhojaGSRuiSh3NNeuIjzyPn5t3eaLrSujOmILua8jdTMrjaGSRKs0H5hl08fnH1wkPe)s1ap(7yVs7QqFWnPqyezxxlTjFqzel1RqHshljklxD4RWvsXk3XVaL8PZnK(Jlzdo()kfc7X95jbLysgwAt(0nbqzelvckJyP905Sgf(JlzwZ05)RKcaSFjwgrXNL4XDRrFo7jw6cIa9SMDDmBjLOdZpwO5lAcRTusj(LQbE83XEL2vH(GBsHWiYUUwAt(GYiwI4XDRrFo7jw6cIa9SMDD0RqtqhljklxD4RWvI8aE4R0jHbZHc8sP7jfJ9TMzSMjzntXAwvlIic(NeehWeCQgs2BqeoafOoS1mXskw5o(fO0)KG4aMGt1qYEdIWbyPqypUppjOetYWsBYNUjakJyPsqzelrNeeNS1iAcovt2As2ZAcvoalPeDy(XcnFrtyTLskXVunWJ)o2R0Uk0hCtkegr211sBYhugXs9ke86yjrz5QdFfUskw5o(fOKpDUH0FCjBWX)xPqypUppjOetYWsBYNUjakJyPsqzelTNoN1OWFCjZAMo)FwZK0Myjfay)sSmIIplXJ7wJ(C2tS0feb6zn04SLuIom)yHMVOjS2sjL4xQg4XFh7vAxf6dUjfcJi76APn5dkJyjIh3Tg95SNyPlic0ZAOXE9kPduKuT7kC9Ab]] )

    storeDefault( [[SimC Windwalker: serenity]], 'actionLists', 20171113.171213, [[dqeXoaqisqlIeI2Ka1OevCkrP2LIAyOshdvTmq4zGOmnsOCnsizBKq4BKeJtuj6CIkL1jQunpfrDprj7Je4GIQwOI0dfftuujDrrOnscvNuGSsrLWlvemtquPBQkTtKAOGOQwkj6PetfvSvrWxveAVs)fjdMIddSyr6XKAYkCzOnlGplOrlIoTsRwrKxluZwvDBqTBv(nvgUQ44KqQLJYZPQPJ46cz7KuFNK04brfNhKwpiQY8br2pLU8Ltf5b1l4VqEaY6UsdHIi3QqdGXkYcNXAM4Edvb)yKL7wJhz4TeOvuIFe4XsdbxEv45YZDMp345Yvrvr0S9HuPsEnzDNVCknF5ujXdK(XrNwr0S9HurHwZddvtfQhZ8ZKnezupGpS1eS1GhYcHoRJym8iwtwwdEile6mmaYXAc2A0j3zDeJHhXAMS1WBnbBnk0AsJcey2Jm8wc05ONk5t3)sGwHSHiJ6b8HRKjjQJFDQry8inTYRBKaGrdGXkvc6gRgqCSkN7Wk0ayScNnezwdKp4dxjpl0xrdv)rkcGfIeFw8vuIFe4XsdbxEv45wrj6Drmn6lNsQKbQ(JCaSqK470kVUbnagRusPHOCQK4bs)4OtRKpD)lbAfn4)PaAY6oQ)6jvc6gRgqCSkN7WkVUrcagnagRuHgaJvYa(FRjVMSUZAGCxpPsEwOVYbGXSuKYcNXAM4Edvb)yKL7wtMCvrwrj(rGhlneC5vHNBfLO3fX0OVCkPsMKOo(1PgHXJ00kVUbnagRilCgRzI7nuf8JrwUBnzY1sknKvovs8aPFC0PvenBFiviUWWpoRDU)WP65RKpD)lbAfpYWBjqRe0nwnG4yvo3HvEDJeamAamwPcnagRiidVLaTIs8JapwAi4YRcp3kkrVlIPrF5usLmjrD8RtncJhPPvEDdAamwPKsRyLtLepq6hhDAfrZ2hsfGMSQrk8q4f9wZKTgiRs(09VeOvyRFVqkF0rfV64kzsI64xNAegpstR86gjay0aySsLGUXQbehRY5oScnagROC97fAns0znty1XvYZc9v0q1FKIayHiXNfFfL4hbES0qWLxfEUvuIExetJ(YPKkzGQ)ihalej(oTYRBqdGXkLuAfv5ujXdK(XrNwr0S9HuH4cd)4mGr2aanPs(09VeOv8e2gJuUauKKiLQ7n(o2Osq3y1aIJv5Chw51nsaWObWyLk0aySIqyBmAnUawdjjAntCVX3XgvuIFe4XsdbxEv45wrj6Drmn6lNsQKjjQJFDQry8inTYRBqdGXkLuAfr5ujXdK(XrNwr0S9HujhRrHwZddvtfQhZ8ZPFGo2frOIxDS1KT1eS1KJ18Wq1uH6Xm)SNW2yKYfGIKePuDVX3XgwdKGK18Wq1uH6Xm)CG1t8uUaubIyqTMSTMGTgGMSQrk8q4f9wZKTgiQKpD)lbAL0pqh7IiuXRoUsMKOo(1PgHXJ00kVUrcagnagRujOBSAaXXQCUdRqdGXkt)aDSlIynty1XvYZc9v0q1FKIayHiXNfFfL4hbES0qWLxfEUvuIExetJ(YPKkzGQ)ihalej(oTYRBqdGXkLuAvkNkjEG0po60kIMTpKk5yn5ynOIoAFEWX8GTx8EHujDSJs7uJmRjyRjnkqG5hg69rmK6XThzMHWG98wZKZYAGWAc2A8iHk1Dr(zYImi4sPypARrbwdxRjBRjyRjhRr7C)Ht1BMT(9cP8rhv8QJNzimypV1OaRH3AGeKSgGMSQrk8q4f9wJcSgERjBRj7k5t3)sGwjW6jEkxaQarmOvYKe1XVo1imEKMw51nsaWObWyLk0aySIIVEI3ACbSgfpIbTsEwOVYEeKXIEizXxrj(rGhlneC5vHNBfLO3fX0OVCkPsq3y1aIJv5Chw51nObWyLskDUSCQK4bs)4OtRiA2(qQKJ1KJ1OqRbv0r7ZdoMhS9I3lKkPJDuANAKznqcswtAuGaZPFNB8J8K5OhRbsqYAsJcey2Jm8wc0zgcd2ZBnt2A4TMSTMGTMCSgTZ9hovVz263lKYhDuXRoEMHWG98wJcSgERbsqYAaAYQgPWdHx0BnkWA4TMSTMSRKpD)lbALaRN4PCbOceXGwjtsuh)6uJW4rAALx3ibaJgaJvQqdGXkk(6jERXfWAu8iguRjh(SRKNf6RShbzSOhsw8vuIFe4XsdbxEv45wrj6Drmn6lNsQe0nwnG4yvo3HvEDdAamwPKsNBLtLepq6hhDAfrZ2hsfGMSQrk8q4f9wJcYYAGmRjyRrHwZddvtfQhZ8Z(N9U9cP0mWHuXRoUs(09VeOv8p7D7fsPzGdPIxDCLGUXQbehRY5oSYRBKaGrdGXkvObWyf5zVBVqRjddCO1mHvhxrj(rGhlneC5vHNBfLO3fX0OVCkPsMKOo(1PgHXJ00kVUbnagRusP55wovs8aPFC0PvenBFivuO18Wq1uH6Xm)mlYNCVqQjbgiLQ7nSMGTM0OabMzr(K7fsnjWaPuDVX8WP6znbBnPrbcm7rgElb6mdHb75TgfKL1OyvYNU)LaTclYNCVqQjbgiLQ7nQe0nwnG4yvo3HvEDJeamAamwPcnagROmYNCVqRjxagO1mX9gvuIFe4XsdbxEv45wrj6Drmn6lNsQKjjQJFDQry8inTYRBqdGXkLuAE(YPsIhi9JJoTIOz7dPcqtw1ifEi8IERrbzznqwL8P7FjqRWw)EHu(OJkE1XvYKe1XVo1imEKMw51nsaWObWyLkbDJvdiowLZDyfAamwr563l0AKOZAMWQJTMC4ZUsEwOVIgQ(Juealej(S4ROe)iWJLgcU8QWZTIs07IyA0xoLujdu9h5ayHiX3PvEDdAamwPKsZdr5ujXdK(XrNwr0S9HurHwZddvtfQhZ8ZSiFY9cPMeyGuQU3WAc2AsJceyMf5tUxi1KadKs19gZdNQN1eS1a0KvnsHhcVO3AuG1WxjF6(xc0kSiFY9cPMeyGuQU3Osq3y1aIJv5Chw51nsaWObWyLk0aySIYiFY9cTMCbyGwZe3Byn5WNDfL4hbES0qWLxfEUvuIExetJ(YPKkzsI64xNAegpstR86g0aySsjLMhYkNkjEG0po60kIMTpKkk0AEyOAQq9yMF2)S3TxiLMboKkE1XvYNU)LaTI)zVBVqkndCiv8QJRe0nwnG4yvo3HvEDJeamAamwPcnagRip7D7fAnzyGdTMjS6yRjh(SROe)iWJLgcU8QWZTIs07IyA0xoLujtsuh)6uJW4rAALx3GgaJvkP08kw5ujXdK(XrNwr0S9HurHwZddvtfQhZ8ZPFGo2frOIxDCL8P7FjqRK(b6yxeHkE1XvYKe1XVo1imEKMw51nsaWObWyLkbDJvdiowLZDyfAamwz6hOJDreRzcRo2AYHp7k5zH(kAO6psraSqK4ZIVIs8JapwAi4YRcp3kkrVlIPrF5usLmq1FKdGfIeFNw51nObWyLskPsUIbarFsNwsla]] )

    storeDefault( [[SimC Windwalker: ST]], 'actionLists', 20171113.171213, [[duKiAaqikLSieiztikJsaofLQULqGDrQggH6yuYYeLEMqQMgjrDnHu2gjb9nkvghcK6CcHADukLMhjrUhjP9HGoib1cjipuumrscCrb0gfc5KcjRKsPQxke0mPukUjb2jPmukLklvGEkvtLKARcrFLKq7f6VKyWkomOflOhtXKL0LrTzPuFwOgncDAvTAeO8APy2sCBPA3Q8BIgoHCCeOA5i9CrMoW1fvBxk57ukgpc48iY6rGy(iQ2VsJwOA01GDgD)7z2rf)RAdS0WuB7oUA0vbCByEbGcHEqUWWeJAzfBzNLylX6wrSLyXrdDxeBEy5jiqWlpulRkmIrxyd4LxcvJAwOA0d8GHfUIcHUWHF5bKq3alffOb8YtP8ja6rD13absk6N8y0fiRrcPAWoJo6AWoJEgyPSJWgWlVDSnFcGUW04e6hSZQsq5FpZoQ4FvBGLgMAB3jJkGGc9GCHHjg1Yk2YolXOhKtYCQHtOAeGEgISPrGSf35dGHOlqw1GDgD)7z2rf)RAdS0WuB7ozubia1YIQrpWdgw4kke6UH(IaOBi(6MCkLpWoQKQ7yTdz7eWogPSuL2C60p9xSsk)uAEtJoL7W)s7O6oI3HCY3jGDGuW3gAa6ja9ByfzBfarwXM)QfjTQZhmSW1DiBhJuwQsBo9eG(nSISTcGiRyZF1IKw1PCh(xAhv3r8o2Vd5KVdFmnMKUjNs5dSJkTt0eVJ9OlC4xEaj05JPXpb5VyfU8e4POh1vFdeiPOFYJrxGSgjKQb7m6ORb7m6bEmn(ji)fVtGLNapf9GCHHjg1Yk2YolXOhKtYCQHtOAeGEgISPrGSf35dGHOlqw1GDgDeGArhvJEGhmSWvui0Dd9fbq3q817qcSteSJH4RBYPu(a7qOQ7yTdz7WhtJjPd(oRaKkDib2Hqv3rSE0qx4WV8asOdPg4XkajLYha9OU6BGajf9tEm6cK1iHunyNrhDnyNrxyQbE8oQLukFa0dYfgMyulRyl7SeJEqojZPgoHQra6ziYMgbYwCNpagIUazvd2z0raQPYOA0d8GHfUIcHUBOVia62AhruULsSPQBPd(yMQicw67q2o8X0ys6GVZkaPshsGDujv3rSE02HSDmeF9oKa7eb7yi(6MCkLpWoeQ6ozrx4WV8asOd(yMQicw6ONHiBAeiBXD(ayi6cK1iHunyNrh9OU6BGajf9tEm6AWoJU6pMP7y7GLo6ctJtOBizkScasJzqsvl0dYfgMyulRyl7SeJEqojZPgoHQra6zizkSAinMbjui0fiRAWoJocqTOHQrpWdgw4kke6UH(IaOdKXXfwhsbFBObSdz7eWo2AhaSWhqpXu(EajD(GHfUUd5KVJrklvPnNEIP89as6uUd)lTdHQUJL4DShDHd)YdiHEcq)gwr2wbqKvS5VArsROh1vFdeiPOFYJrxGSgjKQb7m6ORb7m6oG(n8oY27aiY7OI)vlsAf9GCHHjg1Yk2YolXOhKtYCQHtOAeGEgISPrGSf35dGHOlqw1GDgDeGAQqun6bEWWcxrHq3n0xea9a2jGDmeFDtoLYhyhcvDNOVdz7WhtJjPBYPu(a7qOQ7OYI3X(DiN8DmeFDtoLYhyhcvDNOTJ97q2obSJT2bal8b0tmLVhqsNpyyHR7qo57yKYsvAZPNykFpGKoL7W)s7qOQ7Oc3XE0fo8lpGe60p9xSsk)uAEtd6ziYMgbYwCNpagIUaznsivd2z0rpQR(giqsr)KhJUgSZOh8t)fVJNF7eHVPbDHPXj0nKmfwbaPXmiPQf6b5cdtmQLvSLDwIrpiNK5udNq1ia9mKmfwnKgZGeke6cKvnyNrhbOMDOA0d8GHfUIcHUBOVia6ayHpGEIP89as68bdlCDhY2Xw7We88xKiUQxP)18xScrj9umYwmDhY2XiLLQ0MtpXu(EajDk3H)L2Hqv3jA7q2o8X0ys6GVZkaPshsGDiCNSOlC4xEaj0B)jqsr2wPDoLe6rD13absk6N8y0fiRrcPAWoJo6AWoJEe9jqAhz7DIOCkj0dYfgMyulRyl7SeJEqojZPgoHQra6ziYMgbYwCNpagIUazvd2z0raQrqJQrpWdgw4kke6UH(IaOdGf(a6jMY3diPZhmSW1DiBhMGN)IeXv9k9VM)IvikPNIr2IP7q2obSJrklvPnNEIP89as6uUd)lTdHQUJv02HCY3XiLLQ0MtpXu(EajDk3H)L2rLuDhvEh73HSD4JPXK0bFNvasLoKa7q4ozrx4WV8asO3(tGKISTs7Ckj0J6QVbcKu0p5XOlqwJes1GDgD01GDg9i6tG0oY27er5us7eGL9OhKlmmXOwwXw2zjg9GCsMtnCcvJa0ZqKnncKT4oFameDbYQgSZOJaulIr1Oh4bdlCffcD3qFra0T1oayHpGEIP89as68bdlCDhY2HpMgtsh8Dwbiv6qcSdH7KfDHd)YdiHE7pbskY2kTZPKqpQR(giqsr)KhJUaznsivd2z0rxd2z0JOpbs7iBVteLtjTtazTh9GCHHjg1Yk2YolXOhKtYCQHtOAeGEgISPrGSf35dGHOlqw1GDgDeGAwIr1Oh4bdlCffcD3qFra0T1oayHpGEIP89as68bdlCDhYjFhJuwQsBo9et57bK0PCh(xAhcvDNOHUWHF5bKqN(P)Ivs5NsZBAqpdr20iq2I78bWq0fiRrcPAWoJo6rD13absk6N8y01GDg9GF6V4D88BNi8nn7eGL9OlmnoHUHKPWkainMbjvTqpixyyIrTSITSZsm6b5KmNA4eQgbONHKPWQH0ygKqHqxGSQb7m6ia1SSq1Oh4bdlCffcDHd)YdiHUneFA5VyLkfglpfr5NHi6rD13absk6N8y0fiRrcPAWoJo6AWoJUks8PL)I3rfqHXYBhBx(ziIEqUWWeJAzfBzNLy0dYjzo1Wjuncqpdr20iq2I78bWq0fiRAWoJocqnRSOA0d8GHfUIcHUBOVia62AhruULsSPQBPhwGMgzoqP5nn7q2ogIVEhsGDIGDmeFDtoLYhyhcvDhRDiBNeducLxEsh8mnRLIklYSdH7iEhY2jGDS1ojgOekV8Ko4zQveRKvKzhc3r8oKt(oayHpGEIP89as68bdlCDhYjFNW82T1dLnkIOsJEUODShDHd)YdiHEybAAK5aLM30GEgISPrGSf35dGHOlqwJes1GDgD0J6QVbcKu0p5XORb7m6cvGMgzoyNi8nnOlmnoHUHKPWkainMbjvTqpixyyIrTSITSZsm6b5KmNA4eQgbONHKPWQH0ygKqHqxGSQb7m6ia1SIoQg9apyyHROqO7g6lcGEa7anGVfRWh3FoTdHQUt03HCY3jGDcZB3wpu2OiIkn65I2HSDmeF9oKa7eb7yi(6MCkLpWoeQ6oI3X(DSFhY2Xw7iIYTuInvDl9KO)U)Ivmu4XknVPzhY2jXaLq5LN0bptZAPOYIm7q4oIrx4WV8asONe939xSIHcpwP5nnOh1vFdeiPOFYJrxGSgjKQb7m6ORb7m6UO)U)I3jdfE8or4BAqpixyyIrTSITSZsm6b5KmNA4eQgbONHiBAeiBXD(ayi6cKvnyNrhbOMLkJQrpWdgw4kke6UH(IaOZe88xKiUQdiYkCxetL0KIbkcAEGKUdz7eM3UToGiRWDrmvstkgOiO5bsQEcann7qOQ7yfX7q2o8X0ys6GVZkaPshsGDiCNOJUWHF5bKq3qHMMYFXkemyLvkFmrW9xm6rD13absk6N8y0fiRrcPAWoJo6AWoJEgk00u(lEhBpSY7yB(yIG7Vy0dYfgMyulRyl7SeJEqojZPgoHQra6ziYMgbYwCNpagIUazvd2z0raQzfnun6bEWWcxrHq3n0xeaDMGN)IeXvDarwH7IyQKMumqrqZdK0DiBNW82T1bezfUlIPsAsXafbnpqs1taOPzhcvDhlvEhY2XiLLQ0MtpXu(EajDk3H)L2rL2Xk67q2oayHpGEIP89as68bdlCDhY2HpMgtsh8Dwbiv6qcSdH7eD0fo8lpGe6gk00u(lwHGbRSs5JjcU)IrpQR(giqsr)KhJUaznsivd2z0rxd2z0ZqHMMYFX7y7HvEhBZhteC)fVtaw2JEqUWWeJAzfBzNLy0dYjzo1Wjuncqpdr20iq2I78bWq0fiRAWoJocqnlviQg9apyyHROqO7g6lcGo0a(wScFC)50oeQ6orFhY2Xw7iIYTuInvDl9KO)U)Ivmu4XknVPbDHd)YdiHEs0F3FXkgk8yLM30GEux9nqGKI(jpgDbYAKqQgSZOJUgSZO7I(7(lENmu4X7eHVPzNaSSh9GCHHjg1Yk2YolXOhKtYCQHtOAeGEgISPrGSf35dGHOlqw1GDgDeGAw2HQrpWdgw4kke6UH(IaOBi(6Dib2jc2Xq81n5ukFGDiChRDiBhBTJik3sj2u1T0P5jI)fRqWGvwXM)QOlC4xEaj0P5jI)fRqWGvwXM)QOh1vFdeiPOFYJrxGSgjKQb7m6ORb7m6bZte)lEhBpSY7OI)vrpixyyIrTSITSZsm6b5KmNA4eQgbONHiBAeiBXD(ayi6cKvnyNrhbOMfbnQg9apyyHROqO7g6lcGEa7yi(6MCkLpWoeUJ1oKt(oH5TBRhkBuerLg9Cr7qo57eWoayHpGoFmn(ji)fRWLNapvNpyyHR7q2ogPSuL2C68X04NG8xScxEc8uDk3H)L2rL2XiLLQ0MtV9NajfzBL25us6uUd)lTJ97y)oKTta7eWogPSuL2C60p9xSsk)uAEtJoL7W)s7q4ow7q2obSJT2bsbFBObONa0VHvKTvaezfB(RwK0QoFWWcx3HCY3XiLLQ0MtpbOFdRiBRaiYk28xTiPvDk3H)L2HWDS2X(DiN8DmeFDtoLYhyhc3j7o2Vdz7eWogPSuL2C6T)eiPiBR0oNssNYD4FPDiChRDiN8DmeFDtoLYhyhc3j67y)oKt(oIOClLytv3sh8XmvreS03X(DiBhBTJik3sj2u1T0dlqtJmhO08Mg0fo8lpGe6HfOPrMduAEtd6ziYMgbYwCNpagIUaznsivd2z0rpQR(giqsr)KhJUgSZOlubAAK5GDIW30Staw2JUW04e6gsMcRaG0ygKu1c9GCHHjg1Yk2YolXOhKtYCQHtOAeGEgsMcRgsJzqcfcDbYQgSZOJauZkIr1Oh4bdlCffcD3qFra05JPXK0bFNvasLoKa7q4owOlC4xEaj0neFfBGTy0J6QVbcKu0p5XOlqwJes1GDgD01GDg9me)Durylg9GCHHjg1Yk2YolXOhKtYCQHtOAeGEgISPrGSf35dGHOlqw1GDgDeGAzfJQrpWdgw4kke6UH(IaOZhtJjPd(oRaKkDib2HWDSqx4WV8asOBi(kH50ea9OU6BGajf9tEm6cK1iHunyNrhDnyNrpdXFhHYPja6b5cdtmQLvSLDwIrpiNK5udNq1ia9meztJazlUZhadrxGSQb7m6ia1YAHQrpWdgw4kke6UH(IaOBRDer5wkXMQULo4JzQIiyPVdz7eWogIVEhsGDIGDmeFDtoLYhyhcvDNS7qo57WhtJjPd(oRaKkDib2rL2XAh7rx4WV8asOd(yMQicw6ONHiBAeiBXD(ayi6cK1iHunyNrh9OU6BGajf9tEm6AWoJU6pMP7y7GL(obyzp6ctJtOBizkScasJzqsvl0dYfgMyulRyl7SeJEqojZPgoHQra6zizkSAinMbjui0fiRAWoJocqTSzr1Oh4bdlCffcDHd)YdiHUH4RydSfJEux9nqGKI(jpgDbYAKqQgSZOJUgSZONH4VJkcBX7eGL9OhKlmmXOwwXw2zjg9GCsMtnCcvJa0ZqKnncKT4oFameDbYQgSZOJaulB0r1Oh4bdlCffcDHd)YdiHUH4ReMtta0J6QVbcKu0p5XOlqwJes1GDgD01GDg9me)DekNMa7eGL9OhKlmmXOwwXw2zjg9GCsMtnCcvJa0ZqKnncKT4oFameDbYQgSZOJaeGUBOVia6iar]] )

    storeDefault( [[SimC Windwalker: CD]], 'actionLists', 20171113.171213, [[dquTjaqieP2eQOrjaNscmlLs1TKGODrfddrDmHAzc0ZqKyAsq11ijSnej9nuPgNefoNeLwNeAEsu5EKK2NevDqqyHkfpevyIKeDrLK2OeKmsjiCsb0nbLDsILkrEkLPQuTvLeFvIIgReu6TsqQ7kbf7v1FrvdMOddSyQ0Jj1Kf5YqBgK(SsmAHCAQ61kPMTKUnc7gLFRy4KuhxPuSCKEUOMUuxxqBhvY3brJxPKZdQwVsP08re7NWp(73ujcfew7V5McGaVzEcoeYY0ZsqcQRrArHKdvERewrqgVsqYXChtoMStCzJjtwf3mn1RUVDdcD7hw(7xj(73wLbCRy6BUzAQxDFRNLLk6ONPMgiz5Bq46R(g(npJRznYVviYUfil51GEO3yddVbBsRaOkac82nfabElqgxZAuilSHiB7czhHczzg5Bui39li9wjSIGmELGKJ5oM8TsyEcPAm)9334ic1RHnCHeiRV7nytsbqG3EFLGF)2QmGBftFZntt9Q7BbiK6zQPbsMtgPiZ3WDOibWZYcz5fYyYcjjKiKUHqH6KrkY8nCNq1czbcjjKiKKwiBqfzTtgPiZ3WDqgWTIPBq46R(g(TSAu3iLFGY7InfahuVXreQxdB4cjqwF3BWM0kaQcGaVDtbqG3irdfkGuifvGijfcFJefJvrCCzjxSyXIflwSyCm5Ibj1YwSyXIflssuH2uJ6gPc5avi3GnfahulmKerc9ge0L8ngGavnRg1ns5hO8UytbWb1BLWkcY4vcsoM7yY3kH5jKQX83FFlqwYRb9qVXggEd2Kuae4T3xHu((Tvza3kM(MBMM6v336zzPIo6zQPbsw(geU(QVHFZTotIhAif(TazjVg0d9gBy4nytAfavbqG3UPaiWBBQZKeYcvif(Tsyfbz8kbjhZDm5BLW8es1y(7VVXreQxdB4cjqwF3BWMKcGaV9(kf(3VTkd4wX03CZ0uV6(wpllv0rptnnqYY3GW1x9n8BUinJ01E2YTazjVg0d9gBy4nytAfavbqG3UPaiWBBqAgPR9SLBLWkcY4vcsoM7yY3kH5jKQX83FFJJiuVg2WfsGS(U3GnjfabE79vuX3VTkd4wX03CZ0uV6(MoY7qa2silKcPoY7OdPuK1cz5vviJfsofsKH0f4oTNa57HNaSLqwEvfsYoQ4geU(QVHFdq1agY3dLIS(wGSKxd6HEJnm8gSjTcGQaiWB3uae4niOAadfY9HsrwFRewrqgVsqYXCht(wjmpHunM)(7BCeH61WgUqcK139gSjPaiWBVVcP(9BRYaUvm9n3Gb2YtesSdOlyNVf8MPPE19TEwwQOJEMAAGKLfsofYaesslKaA7Hc0TZcOI8UH0C7GmGBftcjNcjUnHE1QXKtKpLqgpbi3inZdDOU(ucz89eQJesofsslKQPix8l6KtStpH6i(bkFcbDKqwWniC9vFd)wpH6i(bkFcbD0noIq9AydxibY67Ed2Kwbqvae4TBbYsEnOh6n2WWBkac82(eQJeYbQqQse0r3GGUKVPHRRiFdOlyNvnE7eGT41W1vKVb0fSZQg8wjSIGmELGKJ5oM8TsyEcPAm)9334aUUI7a6c25V5gSjPaiWBVVc3F)2QmGBftFZntt9Q7B9SSurh9m10ajllKCkKbiKKwib02dfOBNfqf5DdP52bza3kMesofsslK42e6vRgtor(ucz8eGCJ0mp0H66tjKX3tOosil4geU(QVHFRNqDe)aLpHGo6wGSKxd6HEJnm8gSjTcGQaiWB3uae4T9juhjKduHuLiOJeYaIl4wjSIGmELGKJ5oM8TsyEcPAm)9334ic1RHnCHeiRV7nytsbqG3EFLY473wLbCRy6BUbdSLNiKyhqxWoFl4ntt9Q7B9SSurh9m10ajllKCkKbiKaA7Hc0TZcOI8UH0C7GmGBftcjNczaczaczdQiRDYifz(gUdYaUvmjKCkK6zQPbsMtgPiZ3WDOibWZYcz5uviJfYcessiri1rEhDiLISwilVQczqHSaHKtHmaHuptnnqYCYn1Vg5hO8DeYdPNLQdn5qrcGNLfYYjKLHqscjcPEMAAGK5a1N7m)aLhAifUdfjaEwwilNQczHlKfiKCkK6zQPbsMd1N9Sf(CiJFTxV2HIeapllKLti5wi5uijTqQMICXVOtoXo9eQJ4hO8je0rczb3GW1x9n8B9eQJ4hO8je0r34ic1RHnCHeiRV7nytAfavbqG3Ufil51GEO3yddVPaiWB7tOosihOcPkrqhjKbeSGBqqxY30W1vKVb0fSZQgVDcWw8A46kY3a6c2zvdERewrqgVsqYXCht(wjmpHunM)(7BCaxxXDaDb783Cd2Kuae4T3VVzQrThu9BlO9d7kbj1Y((ha]] )

    storeDefault( [[SimC Windwalker: serenity opener]], 'actionLists', 20171113.171213, [[diuSkaqisjArkkXMivAuKs5uKs1TOij7sidduogfwgOQNPOKMgsI6Aij12uukFJuX4uuKohfjwhPeMNIc3duzFuK6Gc0cvipKIAIKsYfPi2isICsb0ljLuZKIK6MGyNi1qvuQwkPQNsmvqARcWxrsyVs)vOgmLomWIf0JjzYQ4YqBgj(ScgTc1Pr8Afz2I62Q0Ur1Vrz4KILRQNtvtxPRlITRO67iPgpssoViTEffX8vuu7NkxJcTIjCqygpnSIObveqMmtalHXln8ZMPurRqkGK82rv0Jze4XsdpmdDmGzalYWumGbJQRiQNOzRujOAjmUVqlTrHwXeoimJNoQIOEIMTIw6SAECE8G6ezeTKb8J1aYxNvxNf54pKgPs(h5RZcNZIC8hsJUaQYz11zvJjrQK)r(6SZWznCwDDwT0zdtOqjYJpYjBAuIgNvxNvXy5dJAEefIF9XmkXus(0OhVac37SZaoNfwLGHKmztRSKb8J1aY3kMhJQjiS54f5BdRaHDca80GlwPsG8drbw2xHZ4yfAWfRaLmGVZo7G8TsWFWxrLQYy8c(bC9WzurpMrGhln8Wm0Xawf9ONL8k0xODRyovLrOGFaxFhvbc7qdUyLULg(cTIjCqygpDufr9enBf1ys0fqvoRPYzvJjrQK)r(6SMgoN1Wz11zro(dPrl5IXll(cOkN10W5SWIO6kbdjzYMwb8kahJx2)iFRei)quGL9v4mowbc7ea4PbxSsfAWfRe8vao6Sqz)J8TIEmJapwA4HzOJbSk6rpl5vOVq7wX8yunbHnhViFByfiSdn4Iv6w6zTqRycheMXthvruprZwrXy5dJAEefIF9XmkXus(0OhVac37SM2znQemKKjBAffiNJbQLW4XzIFRyEmQMGWMJxKVnSce2jaWtdUyLk0GlwXmiND2GQLW4oRPM43kb)bFfo4IWnlc5A2zPcc)qnipHVw4SM1QzPIEmJapwA4HzOJbSk6rpl5vOVq7wjq(HOal7RWzCSce2HgCXkc5A2zPcc)qnipHVw4SM1QULMkxOvmHdcZ4PJQiQNOzRSSHHmgPyS8Hrn37S66SAZzvmw(WOMhrH4xFmJsmLKpn6XlGW9oRPDwdNv7vcgsYKnTIhFKt20kbYpefyzFfoJJvGWobaEAWfRuHgCXkc(iNSPv0Jze4XsdpmdDmGvrp6zjVc9fA3kMhJQjiS54f5BdRaHDObxSs3st1fAft4GWmE6OkI6jA2ka1sMJXihVe07SZWzNvNvxNnmHcLip(iNSPrjAQemKKjBALN4j8HyFcpEIOMQyEmQMGWMJxKVnSce2jaWtdUyLkbYpefyzFfoJJvObxSIEINWhCwjH7SAnrnvj4p4ROsvzmEb)aUE4mQOhZiWJLgEyg6yaRIE0ZsEf6l0UvmNQYiuWpGRVJQaHDObxSs3spBfAft4GWmE6OkI6jA2klByiJrGFjuaQ1z11z1MZgMqHsKhFKt20OenoR2RemKKjBAf)(KjmMrjEhJXut4Nm7pvcKFikWY(kCghRaHDca80GlwPcn4IvK9jtOZYO4S7y0zPcc)Kz)PIEmJapwA4HzOJbSk6rpl5vOVq7wX8yunbHnhViFByfiSdn4Iv6wADk0kMWbHz80rve1t0Sv0MZQLoRMhNhpOorgrHzGAILSXte1KZQDNvxNvBoRMhNhpOorgr(9jtymJs8ogJPMWpz2FCwTxjyijt20kHzGAILSXte1ufZJr1ee2C8I8THvGWobaEAWfRujq(HOal7RWzCScn4IvgLbQjwY6SAnrnvj4p4ROsvzmEb)aUE4mQOhZiWJLgEyg6yaRIE0ZsEf6l0UvmNQYiuWpGRVJQaHDObxSs3sptl0kMWbHz80rve1t0Svumw(WOMh9epHpe7t4Xte1u0JxaH7Dwt7Sgo7mpZoBycfkrE8roztJomQ5vcgsYKnTcfIF9XmkXus(0kMhJQjiS54f5BdRaHDca80GlwPcn4IvOse)6DwgfNLkL8Pvc(d(ke(I)NOzHZOIEmJapwA4HzOJbSk6rpl5vOVq7wjq(HOal7RWzCSce2HgCXkDlTPuOvmHdcZ4PJQiQNOzReMqHsKhFKt20OdJAUZQRZQgtIuj)J81zNbCol8oRUoRIXYhg18ip(iNSPrpEbeU3zNbColmNvxNvZJZJhuNiJOLmGFSgq(wjyijt20kHzGAILSXte1ufZJr1ee2C8I8THvGWobaEAWfRujq(HOal7RWzCScn4IvgLbQjwY6SAnrn5SAZq7vc(d(kQuvgJxWpGRhoJk6Xmc8yPHhMHogWQOh9SKxH(cTBfZPQmcf8d467OkqyhAWfR0T0gWk0kMWbHz80rve1t0SvuJjrQK)r(6SW5SgvcgsYKnTYsgWpwdiFRyEmQMGWMJxKVnSce2jaWtdUyLkbYpefyzFfoJJvObxScuYa(o7SdYxNvBgAVsWFWxrLQYy8c(bC9WzurpMrGhln8Wm0Xawf9ONL8k0xODRyovLrOGFaxFhvbc7qdUyLUDRqdUyfHCn7SubHFOgKNWxlCwp(iNSPoltdYXVBl]] )


    storeDefault( [[Windwalker Primary]], 'displays', 20171113.171213, [[da0iiaqlck2fePAykYXKslJk5zeitJkvDnQuzBkQY3GizCeOY5iO06irCpcu6Gk0cvWdjKjQOQUOkSrfLpQOYijO6KeQxsaMjjQBsaTtk9tizOKYrjqXsjipfmvO6QKiTvcu1xHiwlePSxXGvPoSKftHhJstwLCzL2Su8zi1OPItJ0RHqZwQUnPA3O63igouoovklNONtvtxvxhfBNe(ofnEiQZtsRhc2Vk60g8aSf2tj8ze(dVAFdGsP4kl2Ee4lj691uOfJaYIJEf5SSiMHaUXSm7yNIMRV8paBavunn(9fvypLW9Xofazunn(9fvypLW9XofWnMLzVeZs4afHnw3pfW7qmhzKLyEdjgbCJzz2lrf2tjCFgcOIQPXVpEjrVVp2PacgMLz9bp22Gh4Gxg99kdbgzFkHFERm1)Xk4cyl9naq1fDEJek)YS6iUsLCEJjxwIUr9beA7B53yDn1oV2PjbfayLuSpWt1xb7u(yDf8ah8YOVxziWi7tj8ZBLP(pwKkGT03aavx05nsO8lZQJ4kvY5912um9pGqBFl)gRRP251onjO85d4DiMGj9zDgpYqaVdXCK5jziaLLWbSILYrhR7cumYsmVHGRITbmyAAcOgRW4YL7c0q4FGdKXKR3BwQb8oet8sIEFFgcGOXiN1HidGJstiXZjC8aSeDJ61uCeJaSf2tj8roRdrgyafookbgqebt98gNeaju(Lz1rCLN3JOoc4DiMaEgc4gZYSZNkx2Ns4bes8CchpaNrxmlH7J19b8yBVpRxEhrKorg8avSTbKX2gaDSTbmITnFaVdXuuH9uc3NHaiJQPXV)iJSIDkqXilCvSnGbttta9c5rMNe7uGQJ5uJDZs1RP4i22avhZPahIPMIJyBduDmNser3OEnfhX2gWw6BaKq5xMvhXvEERjP6LunGBmuwef8up8Q9nqfO6MLQxtHwgcOG6Pg0o9vXvX2agbylSNs4JDkAEarhw8dHcCr9y9sfxfBdubM)2um9pdbKfh9IRITbkdAN(QbkgzjqkFZqaaBzPvNIq9ucpwxZtydGOXmc)bkcBSTUcOIQPXVVy(fLTEI0h7uGQJ5u4Le9(Ak0ITnGrNIacZ1jMJ9Emci3Earhw8dHc4X2EFwV8oXiq1XCk8sIEFnfhX2gGYs4incrp2w3fWnMLzVeZVOS1tK(mea5yNc8Le9(JCwhImWakCCucuiXZjC8aFjrV)mc)HxTVbqPuCLfBpciWczQoJ(5novFJvqtb8oetWK(SoJmpjdbawjf7deO6yo1y3Su9Ak0ITnaMKQxsvXSeoqryJ19tbWKu9sQoJWFGIWgBRRayYLLOBu)OMYbaQUOZBKq5xMvhXvQKZBm5Ys0nQpGrNIacZ1jMXiGEH84rStbWR(Y)Z75KegSyNc8Le9(AkoIraVdXuaRQbLFr5O9ziGMKQxs1ZBrf2tj8aFjrVVpGEHmGhBBak)IYwproYzDiYacjEoHJhqts1lP65TOc7Pe(59iJSceGTWEkHpJWFGIWgBRRavhZPer0nQxtHwSTb8oetX8lkB9ePpdbQoMtboetnfAX2gO6MLQxtXrgc4DiMAkoYqaVdXC8idbyj6g1RPqlgbq0ygH)b0WpVHI7pVTLusmdOIQPXVVag8XkmTbq0ygH)WR23aOukUYIThb0PCap2PaFjrV)mc)bkcBSTUc4DiMAk0Yqa2c7Pe(mc)dOHFEdf3FEBlPKygOyKfGT9U45h7uGdEz03RmeWt1X67iQJyDfqfvtJF)rgzf7uaKr1043xad(yBdi023YVX6AQfPMqkxccPpjSUZvBGVKO3FgH)b0WpVHI7pVTLusmdCTnft)h1uoaq1fDEJek)YS6iUsLCEFTnft)dOt5JhXkOaiJQPXVpEjrVVp2PacyvnO8lkh95n8Q9nwxbkgznYzDiYadOWXrjqLpMHhWnMLzVMr4pqryJT1vaKr1043xm)IYwpr6JDkGBmlZEjGbFgcOt5Jmpj2PafJSukN(bW6L6kZNa]] )

    storeDefault( [[Windwalker AOE]], 'displays', 20171113.171213, [[da0diaqlsISlcqnmf5ysPLbrEgvrttrfxJKkBJa4BKuACKeY5ijQ1rsQ7rsqhublufEibnrfv6Ik0gvu(ivPgjjjNKqEjjvntQsUjb0oPYpHKHskhLKalLa9uWuHQRssXwjjuFvrvRLaK9kgSk1HLSys8yuAYq4YkTzQQpdPgnfDAKETkYSLQBtQ2nQ(nIHdLJtvy5e9CknDvDDuSDc13PW4HOoVuSEvu7xLCAdEa2c7Pe(mc)HVPVbqPgCVe5gd8Le9(AI1IsazXrVcnx2t5iGsNE(S3DIruc0GY33UVWc7PeUnUPaiJY33UVWc7PeUnUPaysQEjBeXs4a98g3CMcOt5dJX5zapywMfHWc7PeUnhbAq57B3hVKO33g3uavaZYS2GhxBWdmYlL(IihbgyFkHFD7f1(XPIc4k9naq1fEDppLJWO6NwPQVUXKllrxP(acU9TSBCin1kaTttEgayLuSpWt1xv4u(4qk4bg5LsFrKJadSpLWVU9IA)4uBaxPVbaQUWR75PCegv)0kv91nI1Vy6Fab3(w2noKMAfG2PjpZNpG1Kyag0N1CymhbSMeJbMNeLa6fYaECtb(sIE)boRjrg4afookbkOiVvfEGM4uPw1QUa(e(hyezm5ATgvtaRjXaVKO33MJaNug4SMezaCuAckYBvHhGLORuVM4XOeGTWEkHpWznjYahOWXrjWacjynx34KaZt5imQ(PvEDpGAmG1Kya45iGhmlZoxQCzFkHhqqrERk8aCgDrSeUnU5eWIT9(SEznfs6ezWduX1gqjU2aOJRnGmU28bSMedHf2tjCBocGmkFF7(dmYkUPafJSWBW2akm((b0lKhyEsCtbQoMzn0nQgRM4X4AduDmZcmjgAIhJRnq1XmlHeDL61epgxBaxPVbMNYryu9tR86Ea1yGQBunwnXA5iGyQLQq70VbVbBdOeGTWEkHp0PO5beo6WhfmGhmu2tQyQf(M(gOcGGAX6vdEd2gGnGS4Ox8gSnqPq70VjqXilbs5Bocm31Vy6FocCszgH)a98gxlsbAq57B3xehbLTEI0g3uanjvVKnx3clSNs4x3dmYkqaKr57B3xehbLTEI0g3ua52diC0Hpkyal227Z6L1mkbQoMzHxs07RjEmU2aih3uapywMfHiockB9ePnhbOSeUaIq0JRvDbSMedWG(SMdmpjhb(sIE)ze(dFtFdGsn4EjYngqGfYuDg9RBCQ(gNNtbqgLVVDF8sIEFBCtbawjf7dyPC09nq1XmRHUr1y1eRfxBapywMfHiwchON34MZuamjvVKnZi8hON34ArkaMCzj6k1pO5vaGQl86EEkhHr1pTsvFDJjxwIUs9bOSeoGvSuo64uxa9c5HX4McGx9L)x3EljmyXnf4lj691epgLacU9TSBCin1Q2j1IKNc4jvwDi1gqts1lzZ1TWc7PeEGVKO33gO6yMfEjrVVMyT4AdOt5dmpjopdWwypLWNr4pqpVX1IuaLo98zV7eJHEpkbqS(ft)h08kaq1fEDppLJWO6NwPQVUrS(ft)dynjgI4iOS1tK2CeO6yMLqIUs9AI1IRnq1nQgRM4XCeWAsmggJsaRjXqt8yocWs0vQxtSwucuDmZcmjgAI1IRnG1KyO(TrHYrq5OT5iWjLze(dFtFdGsn4EjYngqNYb848mWxs07pJWFGEEJRfPaNuMr4Fan8RBO42RBxjLeJaSf2tj8ze(hqd)6gkU962vsjXiqXilaB7DrZnUPaJ8sPViYralvhRVdOgJZZanO89T7pWiR4McynjgAI1YrGVKO3FgH)b0WVUHIBVUDLusmcGmkFF7(Q)WgxBGgu((29v)HnovQnGhmlZo0PO56l)dWgWAsmgyKLiUpjkbkgzjI7tWBW2akm((bkgznWznjYahOWXrjqVgNHhWdMLzrmJWFGEEJRfPauockB9e5aN1KidiOiVvfEapywMfH6pS5iaGTS0QtpxpLWJdjbqLdumYsnC6haRxnRmFca]] )

    storeDefault( [[Brewmaster Primary]], 'displays', 20171113.171213, [[d0ZGhaGEfvVKGyxis61kkntQIEmsnBf(nu3es01uu8neP6Ws2jP2Ry3KSFK0pvLgMImoiH8CkgkHgmIA4iCqPYrPevhtkDoejSqk1sPewSuSCuEOuvpfSmQsRdrIMiKKPcXKPKMUsxuvCvcsxwLRRQ2OuLTIiLntuBNaFKQWZGK6ZqQVtLgjLiBdsWOjY4reNejUfLOCAuDEQ42uvRfsOoob1PnibOlILJv9WQfwNXf4vOiEsr)eGUiwow1dRwGp)IU1BawPqF9Lo6zJDGMbF(Cpgy30eW5vw2CB)Iy5yLj6PaK8klBUTFrSCSYe9uacg3VyouOXkGp)IEMPa(Cv3t0OoGW)7Fw7xelhRmXoGZRSS5wKIH(wt0tbS8)9ptqIUnibEuvZ4Sg7aD0lhROs2tUzJUnGU8VaO6KR)ydyXnUYCr7DQffANMqDaGMXj2azZgWiHDbx(sl19e7agjSB3FXXoaNgRaIIMRqh9mb2IH(2ofTeMfW(fb5fLwqXdlHeWjAlZlkmfGKO96LuNjGrc7Ium03AIDGzB6u0sywaKxrlO4HLqcqJ9BQvuWtAcqxelhR6u0sywa7xeKxugaioAEn4ZRLJvr7ffqrbmsyxaj2be(F)dvC2rVCSkGfu8WsibuFFk0yLjAuhWqCJrVrzK6Jhywqcur3gOj62aOJUnal62Sbmsy3(fXYXktSdqYRSS52UpRIEkq9zfIdXfO5llhWViP7V4ONcudcPQB4wogrbpr3gOgesfiHDff8eDBGAqiv9X(n1kk4j62aO6KR)yJDGA4wogrbIXoGaUH3Wh81bXH4c0eGUiwow1n4Ovb6)OrESiGWFo9SKg3aRZ4cubSYneJYbXH4cubyLc9H4qCbQg(GVobQpRqjxDXoGU8Va2SZ1Vm7XOswKX9lMtGzB6HvlWNFr36najVYYMBPOSYPRfZmrpfqKX9lMdvY9lILJvuj39zvGaoVYYMBPOSYPRfZmrpfGDJa9F0ipweWqCJrVrzKstGAqivifd9TIcEIUnG1tU(JTt0ZauinQKTzNRFz2JrkPsgvNC9hBaH)3)SsrzLtxlMzIDaonwHIXy)OBNjq9zffLmgXH4c08LLdSfd9T9WQfwNXf4vOiEsr)eaLfjC)VpvYiC)lAupfWiHDbx(sl19xCSda0moXgiqniKQUHB5yefigDBaH)3)SsHgRa(8l6zMcqW4(fZPhwTaF(fDR3aeSJg73uBNONrpfGRSYPRfZ6u0sywalO4HLqc4xK09e9uaKACQLkzpy4pr0tb2IH(wrbpPjGiJ7xmhQK7xelhRcSfd9TMawCJRmx0ENAj9js3lQj1jsXmEBd4xKair3gOgesfsXqFROaXOBd4ZvD)fh9uGTyOVvuGyAc0m4ZN7Xa72ngPjGrc7srzLtxlMzIDGAqiv9X(n1kkqm62a1WTCmIcEIDaJe2T7j2bmsyxrbpXoan2VPwrbIPjGrc7kKZPHRSYvOnXoWSn9WQnGicvYqPmujRlgd7gGKxzzZTcX2eDBaFUcqIEkWwm032dRwGp)IU1BaJe2vuGySdqxelhR6HvBareQKHszOswxmg2nq9zfqCJbfuf9uGhv1moRXoGH7tmUU3NO9gOgesfiHDffigDBaNxzzZTDFwf9uGzB6HvlSoJlWRqr8KI(jajVYYMBrkg6BnrpfW5vw2CRqSnrBzTbe(F)RBWrR8p1gGoGrc729zffLmonbKXQnqhJxdQK1fJHDduFw1POLWSa2ViiVO0ZNEibe(F)ZApSAb(8l6wVb2IH(2Ey1gqeHkzOugQK1fJHDdi8)(NvHyBIDG(ychQKrWbSzNRFz2JrLC37tG6ZkHQ4BaIr5CSSja]] )

    storeDefault( [[Brewmaster AOE]], 'displays', 20171113.171213, [[d0tHhaGEfPxsqAxiP41QkmtQk9yKA2k8BOUPQIUgvv(gsQ6Ws2jL2Ry3eTFK4NQsdtvmoKK45KAOeAWiYWr4GuXrPQOoMu15qsklukwkjXIPOLJQhQiEkyzsPwhss1ersmviMmj10v6IkQRsvHlRY1H0gLs2kskTzkSDc8rQQ6zeuFwv13PsJKGyBiPYOjX4vv6KiQBrvronkNNQCBPYArsshNK0PpibOlILHLTWYfwVXf41hi(s2ohGUiwgw2clxGn9ITVDaEj)Vjkh9hPjG5GnDQ)dSBmd49AyOVDsrSmSuh7tGVVgg6BNueldl1X(eqv0d9utMglb20lw)Ec0XKoZXkCavrp0t9KIyzyPonb8Enm03Iu8)B1X(eWNrp0thKy7dsGzzzoo1PjGd9YWskK8LP3y7dyRUlavoJcDSbu5gxPVyB)0tD9ppchaO5mInq2Sb0kyxWLT0koZPjGwb76GU4ygGrJLarrZK)X6xGcLxKLgyepIlGjQHraVy9P2p(fWal3aoCwnOqYwCo2nGwb7Iu8)B1PjWhMosAfmpaYROkK9xiibOXDM1kkyoMbOlILHLosAfmpqZlcY7NbMGj8OqcbhOHFUDLEpofsoVZb0kyxajnbuf9qpQW4h9YWYaQq2FHGeqI2rMgl1XkCanXngTgLwzcEG5bjqfBFaES9b(JTpGzS9zdOvWUtkILHL60e47RHH(whuEf7tGcLxiEexatudJaD1xh0fh7tGAqOuod3Ytlkyo2(a1GqPafSROG5y7dudcLAcUZSwrbZX2hGkNrHo20eOgULNwuGyAciGPzMSbB9q8iUaMbOlILHLod2VmWKzlYSkbufLr)b1Y0W6nUava1mnXO8q8iUa0b4L8)q8iUaLjBWwVafkV(KjV0eOJjDqxCSch4dZwy5cSPxS9TdaehnRgSP1YWYyBtDuLa1GqPqk()TIceJTpG3RHH(wYs1m6AXCDSpb43iWKzlYSkb0e3y0AuALygOgekfsX)VvuWCS9buFgf6yDe9nazQLcPg(52v694uDkKOYzuOJnGQOh6PMSunJUwmxNMamASKQIXDX27xGU6lGe7tGT4)32clxy9gxGxFG4lz7CGpRVSo0okKqyDxSc)eqRGDbx2sR4GU40eaO5mInGMj)hxGAqOuod3Ytlkqm2(amPAgDTyUJKwbZdOcz)fcsacoRR4ETWYfytVy7BhGGF04oZADe9n2NaFJTDBQXVaD1xN5yFcGuJtUui5phJse7tGT4)3kkyoMbe5SUI7rH0KIyzyzGT4)3QdOYnUsFX2(PN6FO(2ctnpun)A3hGGZ6kUhzASeytVy97jGiN1vCpkKMueldlPqYbLxbcSf))wrbIXmGT6Uan8ZTR07XPqY5DoG5GnDQ)dSRZyeZaAfSlzPAgDTyUonbQbHsnb3zwROaXy7dud3Ytlkyonb0kyxN5ygqRGDffmNMa04oZAffigZaAfSRqpptMunt(RttGpmBHLBarekKGsQPqYwCo2nW3xdd9TcTrhBFGoMeqIv4aBX)VTfwUaB6fBF7aAfSROaX0eGUiwgw2cl3aIiuibLutHKT4CSBGcLxaXngKPsSpbMLL54uNMaAwhX4CENJv4a1GqPafSROaXy7d49AyOV1bLxX(e4dZwy5cR34c86deFjBNd891WqFlsX)Vvh7taVxdd9TcTrhRp1hqv0d9CgSFz3j3a0b0kyxhuErwAGJzGT4)36iPvW8anViiVFQcz)fcsGcLxosAfmpqZlcY7N(o3cjGQOh6PUfwUaB6fBF7aBX)VTfwUberOqckPMcjBX5y3aQIEONAH2OttGVVgg6BjlvZORfZ1X(eOq5LpKSnaXO8oE2ea]] )

    storeDefault( [[Brewmaster Defensives]], 'displays', 20171113.171213, [[d4JChaGEfYlje2fIKETuPoSKzsfCCcLzRORri1nvLQhJuFdrQEor7Ks7vSBuTFs4NQkdtbJtQeEMQugkfgmjA4iCqP0rrKOJjfNdrclKIwkHQftLwoPEOc1tblJkADQsQMOQetfstgjnDvUOQ4QesUSsxhInkvSvePSzc2UQQpsf6ZiQPPkP8DQYijeTnPsA0K04reNejULQKCAuopv1VHATsLOBlvDAcAa6I4yyEhm)GZFUb(efQduSpbUstEpJFJ4gqxCY7y1LU7ygqmKfzBNmY8(LFbOd4)jii3BCrCmmxg7qas(eeK7nUiogMlJDiGyilYsLcnMdSrBSofDGEgV9j23cigYISuhxehdZLXmG)NGGCp0stEpzSdbiLilYkdASnbnWdVCNl1ygOL(yyUcLoWKxSodyR(nWlRWYLS)vgq8DULCJ15qtxBggElaqRzexGC5civXEGh7OvBFIzaPk2Rf5WXmaJgZbIIMXjhROdui6IcxaJ6tSbCreec4h7RC21Hacy(fOvZQPcL2sRXEbKQyp0stEpzmd0TBlNwfRdG(ziofhfjAaACVBDg)pXnaDrCmmVLtRI1bm)qr)EpaqS0SAYgvhdZJ1zx7IasvShGgZaIHSi7lm9sFmmpG4uCuKOb4i9uOXCzSnbKe7C2zws1X4jwh0avSnb0X2eGCSnbCJTjxaPk2BCrCmmxgZaK8jii3RfrxXoeOq0fQpXgWfrqiqFrslYHJDiqnjuR2Px5ln(FITjqnjulqf7z8)eBtGAsOwJX9U1z8)eBtaB1Vbm1RxFjVvRq5lRWYLS)vgOMELV043iMb(zsMlBYoFuFInGBa6I4yyE7KrMhy8Jf9r8auzsIz5J6tSbOgqxCYlQpXgOCzt25hOq017m(gZaIHWO7M0ys48NBGkq3UDW8dyJ2yBgc8YkuiZlMbQjHAHwAY7z8BeBta)pbb5Eu4uz01H1YyhcO3zGXpw0hXdij25SZSKQXnqnjul0stEpJ)NyBcCLM8EDW8lGbQcLqXLkuAlTg7fqmKfzPsHtLrxhwlJzG(Iean2MamAmVlX4(yFBiWvAY71bZp48NBGprH6af7tG3lsy9i9kuIY63yFBiGuf7bESJwTf5WXmaqRzexGa1KqTANELV043i2MaxPjVxlNwfRdy(HI(9U4uCuKObi0S(s73bZpGnAJTXzac9sJ7DRR1WHyhc4ozJg54e7f3a9fjTpXoeaTMl)uO0rngHi2HaxPjVNX)tCdW4uz01H1TCAvSoG4uCuKObm0S(s7Rq54I4yyEaQRqHmVaeAwFP9PqJ5aB0g7RneWqZ6lTVcLJlIJH5ku2IORab6z8wKdh7qa6I4yyEhm)a2On2gNbCNSrJCCI9ANZ4gqQI9OWPYORdRLXma1vOqMxRHdbOqAkuAQxV(sER(1vO8Lvy5s2)kdutVYxA8)eZa1KqTgJ7DRZ43i2MasvSNX)tmdqJ7DRZ43iUbKQyprS(UmovgNSmMbKQyV2NygOB3oy(fWavHsO4sfkTLwJ9c0Z4aASdbUstEVoy(bSrBSnod0TBhm)GZFUb(efQduSpbOlIJH5DW8lGbQcLqXLkuAlTg7fOq0fqSZjLxIDiWdVCNl1ygqY6jMB73tSodutc1cuXEg)gX2eW)tqqUxlIUIDiGuf7z8BeZasvSxlIUOWfWXnG47Cl5gRZHgsFG0D(gPoqkeTZMaK8jii3teMYyBc4)jii3teMYyFvtas(eeK7HwAY7jJDiqHORwoTkwhW8df97DhE6GgqmKfzP2bZpGnAJTXzasI9vDHtsv0bedzrwQIWugZaK8jii3JcNkJUoSwg7qGcrxIIZUaeZYF15saa]] )



    ns.initializeClassModule = MonkInit

end
