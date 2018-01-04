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
            talent = 'chi_burst'
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
            talent = 'chi_wave'
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
            recheck = function ()
                return cooldown.serenity.remains - 13
            end,
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
                return buff.pressure_point.remains - 2, buff.serenity.remains - 1, cooldown.serenity.remains - 15, cooldown.serenity.remains - 5, cooldown.serenity.remains - 4
            end,
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
                return buff.serenity.remains, cooldown.fists_of_fury.remains
            end,
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
            cycle = 'touch_of_death',
            recheck = function ()
                return cooldown.serenity.remains - 1, cooldown.strike_of_the_windlord.remains - 8, cooldown.fists_of_fury.remains - 4, cooldown.rising_sun_kick.remains - 7
            end,
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
            talent = 'whirling_dragon_punch',
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


        function class.abilities.draught_of_souls.elem.recharge()
            return buff.serenity.remains, buff.storm_earth_and_fire.remains
        end

        function class.abilities.forgefiends_fabricator.elem.recharge()
            return buff.serenity.remains - 1
        end

        -- Implant this for the Unbridled Fury trinket.
        function class.abilities.unbridled_fury.elem.recharge()
            return cooldown.strike_of_the_windlord.remains - 14, cooldown.fists_of_fury.remains - 15, cooldown.rising_sun_kick.remains - 7, buff.serenity.remains
        end

        function class.abilities.vial_of_ceaseless_toxins.elem.recharge()
            return cooldown.serenity.remains - 8, target.time_to_die - cooldown.serenity.remains
        end

    end


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

    storeDefault( [[SimC Windwalker: default]], 'actionLists', 20171228.223921, [[dqKunaqifHwKIKnrcgLkvDkvknlvkIDHKHPGJPswMe5zKkyAKk01iv02iHQVrvQXrcrNtLcRtIQ5jbUhvv7JekhusSqjkpKkAIKqYfvensvkkNurQxQsr1mveCtQWoPsdLeclvs6PctLu1wvPYxLGElvjUlvjTxu)fPgSQoSslws9ykMSOUmXMjLptvz0kQtd8As0SP0TvXUH8BOgoj1XjHulhXZfz6sDDfA7Kk9DQIZlHwVkfP5ts2pO5lwphHAXawl4MUnaJy3sk(n4WDpchb44e(fcqzpRvPqkh(zrBhTnhvfRSjHDlnC59vPHBqvQKowAqNCegcqDZbhvmnaJsSE29I1ZXKOT2kzUmocdbOU5OxIpPPYs9OMgLztna5JAunhvQbwqxKJKAzj0ZlktNAcqPWX0OmWSnMWbcJeoCGZ3Te39iCWH7Eeoc1YsG)nBrz4hnbOu4OQyLnjSBPHlVVg4OQKWJeJKy9CZHZzXO0bwx5iOMR5Wbo7UhHdUz3sSEoMeT1wjZLXryia1nhZYA7zk1Mg(fa)bkDYrLAGf0f5OXJMzASgTYLCwoMgLbMTXeoqyKWHdC(UL4UhHdoC3JWHE8Ozg(yn4FZxYz5OcXxIdaQfIUR1)ngUjQnn9SS2E2)aLo5OQyLnjSBPHlVVg4OQKWJeJKy9CZHZzXO0bwx5iOMR5Wbo7UhHdUzxDG1ZXKOT2kzUmocdbOU5OEutJkjebb6IuJQHVkvWVEutJk1yYHwwsptVOmTgGiuJQHVkvW)E4pr43Rvqnvsicc0fPe0wBLm8va(nbGuknLAc2qT(awqxKAun8Vf(Qub)6rnnQAlgNTJPMAun8vPc(9s8jnvdocDJPZab(f4h(k(ahvQbwqxKd14gGrCmnkdmBJjCGWiHdh48DlXDpchC4UhHdvgnTHbJrtZlkcCdWiVQIWrvXkBsy3sdxEFnWrvjHhjgjX65MdNZIrPdSUYrqnxZHdC2DpchCZU6iRNJjrBTvYCzCegcqDZrVeFst1GJq3y6mqGFb(H)n4OsnWc6IC04rZmnwJolBpZX0OmWSnMWbcJeoCGZ3Te39iCWH7Eeo0JhnZWhRbFfLS9mhvfRSjHDlnC591ahvLeEKyKeRNBoColgLoW6khb1CnhoWz39iCWn7QtwphtI2ARK5Y4imeG6MJ7HFVwb1ujHiiqxKsqBTvYWxb4BWyBg7brLeIGaDrkICwakb)c8d)b4Fl8vPc(1JAAujHiiqxKAunhvQbwqxKdZAT0RPbyeTfKAoMgLbMTXeoqyKWHdC(UL4UhHdoC3JWHkJM2WGXOP5fNR1c)kMgGrWFcGu7vveoQq8L4aThX)ub44e(fcqzpRvPqkh(jHiiqxCkoQkwztc7wA4Y7RboQkj8iXijwp3C4CwmkDG1vocQ5AoCGZU7r4iahNWVqak7zTkfs5Wpjebb6ICZUkoRNJjrBTvYCzCegcqDZXeHFVwb1ujHiiqxKsqBTvYWxb4Fp8Rh10OsnMCOLL0Z0lktRbic1OA4Rsf8nySnJ9GOsnMCOLL0Z0lktRbicLzEj(Ke89d)sW)woQudSGUihM1APxtdWiAli1CmnkdmBJjCGWiHdh48DlXDpchC4UhHdvgnTHbJrtZloxRf(vmnaJG)eaP2RQiW)(RB5OcXxId0Ee)tfGJt4xiaL9SwLcPC4NeTP4OQyLnjSBPHlVVg4OQKWJeJKy9CZHZzXO0bwx5iOMR5Wbo7UhHJaCCc)cbOSN1QuiLd)KOXn76nRNJjrBTvYCzCegcqDZXeHFVwb1ujHiiqxKsqBTvYWxb4lk6rGA1sMktaiLaKp6zmbrBW6ke4Ra8Vh(gm2MXEquPMauk0yn6EwO9aqzlMKPiYzbOe8lWp8VuKWxb4BWyBg7brPbsDIgRrRnsksrKZcqj4xGF4Fvc(kaFZmGYmsicQHVI5h(6a8va(gm2MXEqueqcG8rNgr0kbgLue5Sauc(f4h(xWxLk43lXN0un4i0nMode4xGF4xsNWxLk4BWyBg7br14rZmnwJolBptrKZcqj4RyW)6Qe8Vf(kaFdgBZypiQuJjhAzj9m9IY0AaIqzMxIpjbF)W)IJk1alOlYHzTw610amI2csnhtJYaZ2ychims4WboF3sC3JWbhU7r4qLrtByWy008IZ1AHFftdWi4pbqQ9Qkc8VV0TCuH4lXbApI)PcWXj8leGYEwRsHuo8tI2uCuvSYMe2T0WL3xdCuvs4rIrsSEU5W5Syu6aRRCeuZ1C4aND3JWraooHFHau2ZAvkKYHFs04MDvKSEoMeT1wjZLXryia1nhte(9AfutLeIGaDrkbT1wjdFfG)eHVOOhbQvlzQmbGucq(ONXeeTbRRqGVcW)E4BWyBg7brLAcqPqJ1O7zH2daLTysMIiNfGsWVa)W)shHVcW3GX2m2dIsdK6enwJwBKuKIiNfGsWVa)WxXHVcW3mdOmJeIGA4Ry(HVoaFfGVbJTzShefbKaiF0PreTsGrjfrolaLGFb(H)f8vPc(9s8jnvdocDJPZab(f4h(x6e(QubFdgBZypiQgpAMPXA0zz7zkICwakbFfd(xxLG)TWxb4BWyBg7brLAm5qllPNPxuMwdqekZ8s8jj47h(xCuPgybDromR1sVMgGr0wqQ5yAugy2gt4aHrchoW57wI7Eeo4WDpchQmAAddgJMMxCUwl8RyAagb)jasTxvrG)96WTCuH4lXbApI)PcWXj8leGYEwRsHuo8tI2uCuvSYMe2T0WL3xdCuvs4rIrsSEU5W5Syu6aRRCeuZ1C4aND3JWraooHFHau2ZAvkKYHFs04MDVbRNJjrBTvYCzCuPgybDromR1sVMgGr0wqQ5yAugy2gt4aHrchoW57wI7Eeo4WDpchQmAAddgJMMxCUwl8RyAagb)jasTxvrG)964TCuH4lXbApI)PcWXj8leGYEwRsHuo8d9tXrvXkBsy3sdxEFnWrvjHhjgjX65MdNZIrPdSUYrqnxZHdC2Dpchb44e(fcqzpRvPqkh(HEUz3RbwphtI2ARK5Y4imeG6MJETcQPMbnTbFQXucARTsg(kaFZmGYmsicQHVF4paFfGVAIOlTptM6IQb(ecT61E4OQKWJeJKy9CZrLAGf0f5Ob(ecT61E4yAugy2gt4aHrchvfRSjHDlnC591ahU7r4qpWNqGVIyThU5MdfLOTJ2MlJBMb]] )

    storeDefault( [[SimC Windwalker: precombat]], 'actionLists', 20171228.223921, [[duZocaGEbQ2fkjBdiA2aMVG4MuQ7IsQBlLDsv7LSBk2VqzyO43GgQaXGfQgUqCqH0XqvNtqAHOILkvwmIwUOEicEQYYOK1jaMOaQPkstwLMUQUiq1LHUoc9AryRaPnJkTDuQhtLVkOAAcu(UGYHL8CvmAPQtJ0jrj(Mi6AcKopq5Tcq)fi8mbKfVs1we0rlaAWRNcnYBbYq18vd1gTriw8WPMByfqcmhGyXJKrhSrwVwhcG1bL3IHpjVftOSYYkywmbvBUmnYRPf19uO5Ou55vQg4MIeaVIJwuska9btlc8PqJglMl1vpmRzGguZgEbTY(QHAA(QHAH44YLHX54YnGbb(uOH1HK16qaSoO8wm8j5z06WdKy2HhLQxJqp6sydzJn08IuZgE9vd10lVLs1a3uKa4vC0IssbOpyAUEkiijMpVglMl1vpmRzGguZgEbTY(QHAA(QHAe6PXIZHy(8ADiawhuElg(K8mAD4bsm7WJs1RrOhDjSHSXgAErQzdV(QHA6LpqkvdCtrcGxXrlkjfG(GP56PGiSInQXI5sD1dZAgOb1SHxqRSVAOMMVAOgHEAS4HxSrToeaRdkVfdFsEgTo8ajMD4rP61i0JUe2q2ydnVi1SHxF1qn961cmYTic8IJEja]] )

    storeDefault( [[SimC Windwalker: sef]], 'actionLists', 20171228.223921, [[dm0hfaqirPArkPSjcIrrG0POuLMLOKUfLQyxePHjshtelJiEgLQY0eLY1iqTnIQQVrqDoLewhPQMhLQQ7ri2NssDqIYcjGhQunrcsxKqAJIs0jjvzMkj5MaStqnurjSusXtrMQsSvkHVsj6Tkj6Uei2R0FfvdwWHvSyLYJjzYaDzOndOptOgnPYPr1RPKMnvUnvTBu(nfdxuSCv9CqMUkxNuA7ev(oLkJNOkNNsz9evL5RKQ9l0nPlLOmOIpoU8nh3WkSe5FfLGhpwI4(9yWsod0UXzfF9JbieyjnOdhiSWssteors6kKkrs2KKk4sK65zUsLKPoUHb1LcN0LsIYMnhcwbkrQNN5kL9yiZJYLlwbknr6XfJFEMX5JbHedidFX2KQ0(pYUyqKyaz4l2Mu)iVyqiXGshxQs7)i7Ib7pgskjBJ74NTshxm(5zgNV0UouzfGro0JSRBLayaTyE4XJLkPhdKRMZ8LyggwcE8yPfUy8JHSyC(sYEXqLu2uom)MxmEqIKusd6WbclSK0eHtslPbHmAFfc1LEL2TPC4Y8IXdQcucGbeE8yPEfwsxkjkB2CiyfOePEEMRKshxQFKxmypXGshxQs7)i7IHvlsmKedcjgqg(ITj94Em)m5(rEXWQfjgsLk4sY24o(zR08QHH5N5FKDL0JbYvZz(smddlbWaAX8WJhlvcE8yjzVAyymSy(hzxjnOdhiSWssteojTKgeYO9viux6vAxhQScWih6r21TsamGWJhl1RW2xxkjkB2CiyfOKSnUJF2kPgNlFuh3WYDCORKEmqUAoZxIzyyjagqlMhE8yPsWJhlTUciW0uLciWvUpoxmitDCdlgwfh6eK1)sYEXqLyJhfznI73Jbl5mq7gNv81pg2f6AL0GoCGWcljnr4K0sAqiJ2xHqDPxPDDOYkaJCOhzx3kbWacpESeX97XGLCgODJZk(6hd7cTxHZwxkjkB2CiyfOePEEMRu2JHnTabkf6mVphN)0LpmWCG8hLQntjzBCh)Svc6mVphN)0LpmWCG8hlPhdKRMZ8LyggwcGb0I5HhpwQe84Xs0zEFwJbrN)0L1yyyGXqwYFSKg0HdewyjPjcNKwsdcz0(keQl9kTRdvwbyKd9i76wjagq4XJL6vyb3LsIYMnhcwbkjBJ74NTsQX5Yh1XnSChh6kPhdKRMZ8LyggwcGb0I5HhpwQe84XsRRacmnvPacCL7JZfdYuh3WIHvXHobz9pge0e7TKSxmuj24rrwJ4(9yWsod0UXzfF9JbAzTsAqhoqyHLKMiCsAjniKr7RqOU0R0UouzfGro0JSRBLayaHhpwI4(9yWsod0UXzfF9JbAPxVscfboADxfOxla]] )

    storeDefault( [[SimC Windwalker: serenity]], 'actionLists', 20171228.223921, [[dy0NoaqiufTiuLkBsOyuIkoLOs7svmmuXXiXYev9mfv10qvW1qvk2gQsPVjaJdvH05eLuRtusMNIQCprP2hQsoOI0cvuEOOyIkQKlkqTrrjCsbYkrvQ6LkcntfvQUPQ0or0qfLOwkj5PetfvARcL(QIkElQcv3fvHyVs)fHbtXHbwSiEmPMScxgAZOQ(SinAHQtR0Qve8AbnBv1Tb1Uv53uz4G44IsKLJYZPQPJ01fY2jP(UaA8OkuopiTEfvkZxr0(P0vPCRiqq9c(7Cdqx3vY882SUcjagRilCgRzo7nce8drwwznEKH3sHwrf(rGhlzEokbOKNtw)KpppKNdVPIOzleALkt101D(YTKkLBLGpqYhhDwfrZwi0k80AGWq1eP6XJYdDtrgbeWh2AIXAWdzPqF0rmgEuRjBRbpKLc9bgWJznXyn647JoIXWJAnZZAuSMySgEAnjr85)4rgElf6teKktt2)sHwHUPiJac4dxjtCuh(6uJW4rBsLx3iwaJeaJvQe0nwnG6yvo3HvibWyfUBkYSMSm4dxzkl1xrdv)rckGLIuF2kvuHFe4XsMNJsakCQOc9UiMg9LBPvYav)rUawks9DwLx3GeaJvkTK5l3kbFGKpo6Sktt2)sHwrd(FcGMUUJ4VEALGUXQbuhRY5oSYRBelGrcGXkvibWyLj185ZHJwZNppEgW)Bnt101DwZCF9uEKjzvMYs9voamMnVtw4mwZC2Bei4hISSYAYmx8UkQWpc8yjZZrjafovuHExetJ(YT0kzIJ6WxNAegpAtQ86gKaySISWzSM5S3iqWpezzL1KzUkTKZVCRe8bs(4OZQmnz)lfAfpYWBPqRe0nwnG6yvo3HvEDJybmsamwPcjagRiidVLcTIk8JapwY8CucqHtfvO3fX0OVClTsM4Oo81PgHXJ2KkVUbjagRuAj5HYTsWhi5JJoRIOzleAfGMUQrc8q4f9wZ8SM5xzAY(xk0kS1VxkHp6icxDyLmXrD4RtncJhTjvEDJybmsamwPsq3y1aQJv5ChwHeaJvuT(9sTgj6SMjU6WktzP(kAO6psqbSuK6ZwPIk8JapwY8CucqHtfvO3fX0OVClTsgO6pYfWsrQVZQ86gKaySsPLK3uUvc(ajFC0zvMMS)LcTINY2qKWXNGghjcCVX3Xgvc6gRgqDSkN7WkVUrSagjagRuHeaJvekBdrRXX3AOXrRzo7n(o2OIk8JapwY8CucqHtfvO3fX0OVClTsM4Oo81PgHXJ2KkVUbjagRuAj5TLBLGpqYhhDwfrZwi0k5yn80AGWq1eP6XJYtYhOdDruIWvhAn5AnXyn5ynqyOAIu94r5XtzBis44tqJJebU347ydRzYjTgimunrQE8O8WF9upHJpb)iguRjxRjgRbOPRAKapeErV1mpRjFLPj7FPqRK8b6qxeLiC1HvYeh1HVo1imE0Mu51nIfWibWyLkbDJvdOowLZDyfsamwz2hOdDruRzIRoSYuwQVIgQ(JeualfP(SvQOc)iWJLmphLau4urf6Drmn6l3sRKbQ(JCbSuK67SkVUbjagRuAjdOCRe8bs(4OZQiA2cHwjhRjhRbZsrlei44zW2lCVuI4o2rODQrM1eJ1KeXN)deg69rmKaIBp6ddHb75TM5LT1K3AIXA8iLiXDr(h6IS8Ci4biARHxwdhRjxRjgRjhRr7C)HlW7HT(9sj8rhr4QdFyimypV1WlRrXAMCsRbOPRAKapeErV1WlRrXAY1AYTY0K9VuOv4VEQNWXNGFedALGUXQbuhRY5oSYRBelGrcGXkvibWyLSy9uV144BnzredALPSuFL9OiJfbHMTsfv4hbESK55OeGcNkQqVlIPrF5wALmXrD4RtncJhTjvEDdsamwP0sYJwUvc(ajFC0zvenBHqRKJ1KJ1WtRbZsrlei44zW2lCVuI4o2rODQrM1m5KwtseF(pjFNB8J80NiiwZKtAnjr85)4rgElf6ddHb75TM5znkwtUwtmwtowJ25(dxG3dB97Ls4JoIWvh(WqyWEERHxwJI1m5Kwdqtx1ibEi8IERHxwJI1KR1KBLPj7FPqRWF9upHJpb)ig0kbDJvdOowLZDyLx3iwaJeaJvQqcGXkzX6PERXX3AYIiguRjhLCRmLL6RShfzSii0SvQOc)iWJLmphLau4urf6Drmn6l3sRKjoQdFDQry8OnPYRBqcGXkLwYSUCRe8bs(4OZQiA2cHwbOPRAKapeErV1WRSTM5BnXyn80AGWq1eP6XJYJhYE3EPeAg4qIWvhwzAY(xk0kEi7D7LsOzGdjcxDyLGUXQbuhRY5oSYRBelGrcGXkvibWyfbYE3EPwtgg4qRzIRoSIk8JapwY8CucqHtfvO3fX0OVClTsM4Oo81PgHXJ2KkVUbjagRuAjv4uUvc(ajFC0zvenBHqRWtRbcdvtKQhpkpSiF89sjMayGebU3WAIXAsI4Z)Hf5JVxkXeadKiW9gpdxGN1eJ1KeXN)Jhz4TuOpmegSN3A4v2wdpuzAY(xk0kSiF89sjMayGebU3Osq3y1aQJv5Chw51nIfWibWyLkKaySIQiF89sTgEpyGwZC2Burf(rGhlzEokbOWPIk07IyA0xULwjtCuh(6uJW4rBsLx3GeaJvkTKkkLBLGpqYhhDwfrZwi0kanDvJe4HWl6TgELT1m)ktt2)sHwHT(9sj8rhr4QdRKjoQdFDQry8OnPYRBelGrcGXkvc6gRgqDSkN7WkKaySIQ1VxQ1irN1mXvhAn5OKBLPSuFfnu9hjOawks9zRurf(rGhlzEokbOWPIk07IyA0xULwjdu9h5cyPi13zvEDdsamwP0sQKVCRe8bs(4OZQiA2cHwHNwdegQMivpEuEyr(47LsmbWajcCVH1eJ1KeXN)dlYhFVuIjagirG7nEgUapRjgRbOPRAKapeErV1WlRrPY0K9VuOvyr(47LsmbWajcCVrLGUXQbuhRY5oSYRBelGrcGXkvibWyfvr(47LAn8EWaTM5S3WAYrj3kQWpc8yjZZrjafovuHExetJ(YT0kzIJ6WxNAegpAtQ86gKaySsPLuz(LBLGpqYhhDwfrZwi0k80AGWq1eP6XJYJhYE3EPeAg4qIWvhwzAY(xk0kEi7D7LsOzGdjcxDyLGUXQbuhRY5oSYRBelGrcGXkvibWyfbYE3EPwtgg4qRzIRo0AYrj3kQWpc8yjZZrjafovuHExetJ(YT0kzIJ6WxNAegpAtQ86gKaySsPLuHhk3kbFGKpo6SkIMTqOv4P1aHHQjs1JhLNKpqh6IOeHRoSY0K9VuOvs(aDOlIseU6WkzIJ6WxNAegpAtQ86gXcyKaySsLGUXQbuhRY5oScjagRm7d0HUiQ1mXvhAn5OKBLPSuFfnu9hjOawks9zRurf(rGhlzEokbOWPIk07IyA0xULwjdu9h5cyPi13zvEDdsamwP0sRmxiFq0N2zL2c]] )

    storeDefault( [[SimC Windwalker: ST]], 'actionLists', 20171228.223921, [[dCerBaqikblIOeAtiOrjaNsaDlkHAxu0WiuhJsTmH4ziGMgcuxdbY2ikv(gLKXrucoNqsToHezEcjCpII9HioibzHispuuAIeLuxKsQnkKKtkkSsIsvVKsiZuirDtcStkmueawQa9uQMkr1wfs9vIs5TiaQ7Iai7f8xImyfhgQflOhtQjlLlJAZsKpluJgHonKvtuIETeMTKUTuTBv9BsgoHCCIsYYr65ImDvUUOA7suFNs04ffDEe16raA(eu7xPbBqo4g4odUJ6z3r2qFZsCTGPrPDC5GlR5s486bKcEqUY4edgreBBLDeXrTzKieCeXee4UiwJWvebeFi1dgrKDrn4cPpK6tGCWWgKdU1poSYnGuWfkevrhzW14AvcRpK6LQO0bEgFdPXNIc(REgCbQw0yQbUZGdUbUZGlSUujXI16sLiaNfxR7iK(qQFNOmkDeGeMcUq04e4pUZYil6OE2DKn03SexlyAuANSYAzrWdYvgNyWiIyBRSfdEqoPYPAobYHd8SezDHavzUZ)bHGlq1mWDgCh1ZUJSH(ML4AbtJs7KvwdhyebKdU1poSYnGuWDnfj6axtezQZPu(VDIcz2XEhc3jGD0kvTPS8nPOe6JLs5Vubsxys5og9PDKzhX7iSW7eWoy6HkH1Nz6OOcwsvs6iYswI(wvrBM8JdRCBhc3rRu1MYY3mDuublPkjDezjlrFRQOntk3XOpTJm7iENa3ryH3HFMgt2uNtP8F7ef7qqI3jqWfkevrhzW5NPXici6JL4kktef8m(gsJpff8x9m4cuTOXudCNbhCdCNb36NPXici6J3X6kktef8GCLXjgmIi22kBXGhKtQCQMtGC4aplrwxiqvM78Fqi4cundCNbhoWGab5GB9JdRCdifCxtrIoW1erMDCM7yX7OjIm15uk)3oKiZo27q4o8Z0yYMhQZsNsQJZChsKzhXMee4cfIQOJm4yQg)S0POu(pWZ4Bin(uuWF1ZGlq1IgtnWDgCWnWDgCHOA8Z7ixrP8FGhKRmoXGreX2wzlg8GCsLt1CcKdh4zjY6cbQYCN)dcbxGQzG7m4WbgemihCRFCyLBaPG7Aks0bUf2reLllfRBM2MHvSUqLFsfiDXoeUJMiYSJZChlEhnrKPoNs5)2Hez2XEhc3jXNuO6ZtMhIPrSLiyr6DizhX7q4oH5LkzgQkKervAZCrGluiQIoYGhwX6cv(jvG0fGNLiRleOkZD(pieCbQw0yQbUZGdEgFdPXNIc(REgCdCNbN0kwxOYVDSiKUaCHOXjW1K1vw6W0y(sYydEqUY4edgreBBLTyWdYjvovZjqoCGNLSUYYX0y(saPGlq1mWDgC4adccKdU1poSYnGuWDnfj6a3c7iIYLLI1ntBZdfZujr4AFhc3HFMgt28qDw6usDCM7efYSJytcAhc3rtez2XzUJfVJMiYuNtP8F7qIm7ebCHcrv0rg8dfZujr4Ah8SezDHavzUZ)bHGlq1IgtnWDgCWZ4Bin(uuWF1ZGBG7m4YrXmDhcaCTdUq04e4AY6klDyAmFjzSbpixzCIbJiITTYwm4b5KkNQ5eihoWZswxz5yAmFjGuWfOAg4odoCGHSdKdU1poSYnGuWDnfj6a3c7C4k)NzIP8JoYM8JdRCBhHfEhTsvBklFZet5hDKnPChJ(0oKiZo2IbxOqufDKbpDuublPkjDezjlrFRQOnWZ4Bin(uuWF1ZGlq1IgtnWDgCWnWDgC)OOcEhvPDoI8oYg6BvfTbEqUY4edgreBBLTyWdYjvovZjqoCGNLiRleOkZD(pieCbQMbUZGdhyyfihCRFCyLBaPG7Aks0bEa7eWoAIitDoLY)TdjYSdbUdH7WptJjBQZPu(VDirMDiyX7e4ocl8oAIitDoLY)TdjYSdbTtG7q4obSJf25Wv(pZet5hDKn5hhw52ocl8oALQ2uw(MjMYp6iBs5og9PDirMDKD7ei4cfIQOJm4uuc9XsP8xQaPlaplrwxiqvM78Fqi4cuTOXudCNbh8m(gsJpff8x9m4g4odEquc9X745)owesxaUq04e4AY6klDyAmFjzSbpixzCIbJiITTYwm4b5KkNQ5eihoWZswxz5yAmFjGuWfOAg4odoCGHSaihCRFCyLBaPG7Aks0b(HR8FMjMYp6iBYpoSYTDiChlSdlRYrIeXnZgf9fOpwIOI(sAvzMUdH7OvQAtz5BMyk)OJSjL7y0N2Hez2HG2HWD4NPXKnpuNLoLuhN5oKSteWfkevrhzWlHsxssvsQuoLm4z8nKgFkk4V6zWfOArJPg4odo4g4odEuHsxAhvPDIQCkzWdYvgNyWiIyBRSfdEqoPYPAobYHd8SezDHavzUZ)bHGlq1mWDgC4aJOgKdU1poSYnGuWDnfj6a)Wv(pZet5hDKn5hhw52oeUdlRYrIeXnZgf9fOpwIOI(sAvzMUdH7eWoALQ2uw(MjMYp6iBs5og9PDirMDSjODew4D0kvTPS8ntmLF0r2KYDm6t7efYSdbVtG7q4o8Z0yYMhQZsNsQJZChs2jc4cfIQOJm4LqPljPkjvkNsg8m(gsJpff8x9m4cuTOXudCNbhCdCNbpQqPlTJQ0orvoL8obyhi4b5kJtmyerSTv2IbpiNu5unNa5WbEwISUqGQm35)GqWfOAg4odoCGHTyqo4w)4Wk3asb31uKOdClSZHR8FMjMYp6iBYpoSYTDiCh(zAmzZd1zPtj1XzUdj7ebCHcrv0rg8sO0LKuLKkLtjdEgFdPXNIc(REgCbQw0yQbUZGdUbUZGhvO0L2rvANOkNsENaIei4b5kJtmyerSTv2IbpiNu5unNa5WbEwISUqGQm35)GqWfOAg4odoCGHTnihCRFCyLBaPG7Aks0bUf25Wv(pZet5hDKn5hhw52ocl8oALQ2uw(MjMYp6iBs5og9PDirMDiiWfkevrhzWPOe6JLs5VubsxaEwISUqGQm35)GqWfOArJPg4odo4z8nKgFkk4V6zWnWDg8GOe6J3XZ)DSiKUyNaSdeCHOXjW1K1vw6W0y(sYydEqUY4edgreBBLTyWdYjvovZjqoCGNLSUYYX0y(saPGlq1mWDgC4ad7iGCWT(XHvUbKcUqHOk6idULer0k6JLAuCS6LeL)AIGNX3qA8POG)QNbxGQfnMAG7m4GBG7m4YgreTI(4DK1uCS63Hai)1ebpixzCIbJiITTYwm4b5KkNQ5eihoWZsK1fcuL5o)hecUavZa3zWHdmSjqqo4w)4Wk3asb31uKOdClSJikxwkw3mTndRyDHk)Kkq6IDiChnrKzhN5ow8oAIitDoLY)TdjYSJ9oeUtIpPq1NNmpetJylrWI07qYoI3HWDcyhlStIpPq1NNmpetTJAPiI07qYoI3ryH35Wv(pZet5hDKn5hhw52obcUqHOk6idEyfRlu5NubsxaEwISUqGQm35)GqWfOArJPg4odo4z8nKgFkk4V6zWnWDgCsRyDHk)2XIq6IDcWoqWfIgNaxtwxzPdtJ5ljJn4b5kJtmyerSTv2IbpiNu5unNa5WbEwY6klhtJ5lbKcUavZa3zWHdmSjyqo4w)4Wk3asb31uKOd8a2bRpuzwIFUJ40oKiZoe4ocl8obStyEPsMHQcjruL2mx0oeUJMiYSJZChlEhnrKPoNs5)2Hez2r8obUtG7q4owyhruUSuSUzABMeH(h9XsAk(zPcKUyhc3jXNuO6ZtMhIPrSLiyr6DizhXGluiQIoYGNeH(h9XsAk(zPcKUa8m(gsJpff8x9m4cuTOXudCNbhCdCNb3fH(h9X7KLIFEhlcPlapixzCIbJiITTYwm4b5KkNQ5eihoWZsK1fcuL5o)hecUavZa3zWHdmSjiqo4w)4Wk3asb31uKOdCwwLJejIBMhrwI7IyQIMK0yryn6u0DiCNW8sLmpISe3fXufnjPXIWA0POMPdRl2Hez2XoQ3HWD4NPXKnpuNLoLuhN5oKSdbcUqHOk6idUMI1fv0hljlXnwQIIjEp6JbpJVH04trb)vpdUavlAm1a3zWb3a3zWZsX6Ik6J3r2JB8orzumX7rFm4b5kJtmyerSTv2IbpiNu5unNa5WbEwISUqGQm35)GqWfOAg4odoCGHTSdKdU1poSYnGuWDnfj6aNLv5irI4M5rKL4UiMQOjjnwewJofDhc3jmVujZJilXDrmvrtsASiSgDkQz6W6IDirMDSj4DiChTsvBklFZet5hDKnPChJ(0orXo2e4oeUZHR8FMjMYp6iBYpoSYTDiCh(zAmzZd1zPtj1XzUdj7qGGluiQIoYGRPyDrf9XsYsCJLQOyI3J(yWZ4Bin(uuWF1ZGlq1IgtnWDgCWnWDg8SuSUOI(4DK94gVtugft8E0hVta2bcEqUY4edgreBBLTyWdYjvovZjqoCGNLiRleOkZD(pieCbQMbUZGdhyyBfihCRFCyLBaPG7Aks0bowFOYSe)ChXPDirMDiWDiChlSJikxwkw3mTntIq)J(yjnf)SubsxaUqHOk6idEse6F0hlPP4NLkq6cWZ4Bin(uuWF1ZGlq1IgtnWDgCWnWDgCxe6F0hVtwk(5DSiKUyNaSde8GCLXjgmIi22kBXGhKtQCQMtGC4aplrwxiqvM78Fqi4cundCNbhoWWwwaKdU1poSYnGuWDnfj6axtez2XzUJfVJMiYuNtP8F7qYo27q4owyhruUSuSUzABsZterFSKSe3yjlrFdCHcrv0rgCAEIi6JLKL4glzj6BGNX3qA8POG)QNbxGQfnMAG7m4GBG7m4bZterF8oYECJ3r2qFd8GCLXjgmIi22kBXGhKtQCQMtGC4aplrwxiqvM78Fqi4cundCNbhoWWoQb5GB9JdRCdifCxtrIoWdyhnrKPoNs5)2HKDS3ryH3jmVujZqvHKiQsBMlAhHfENa25Wv(pt(zAmIaI(yjUIYern5hhw52oeUJwPQnLLVj)mngrarFSexrzIOMuUJrFANOyhTsvBklFZsO0LKuLKkLtjBs5og9PDcCNa3HWDcyNa2rRu1MYY3KIsOpwkL)sfiDHjL7y0N2HKDS3HWDcyhlSdMEOsy9zMokQGLuLKoISKLOVvv0Mj)4Wk32ryH3rRu1MYY3mDuublPkjDezjlrFRQOntk3XOpTdj7yVtG7iSW7OjIm15uk)3oKStKDcChc3jGD0kvTPS8nlHsxssvsQuoLSjL7y0N2HKDS3ryH3rtezQZPu(VDizhcCNa3ryH3reLllfRBM2MhkMPsIW1(obUdH7yHDer5YsX6MPTzyfRlu5NubsxaUqHOk6idEyfRlu5NubsxaEwISUqGQm35)GqWfOArJPg4odo4z8nKgFkk4V6zWnWDgCsRyDHk)2XIq6IDcisGGlenobUMSUYshMgZxsgBWdYvgNyWiIyBRSfdEqoPYPAobYHd8SK1vwoMgZxcifCbQMbUZGdhyermihCRFCyLBaPG7Aks0bo)mnMS5H6S0PK64m3HKDSbxOqufDKbxtejzjUmdEgFdPXNIc(REgCbQw0yQbUZGdUbUZGNLiAhzdxMbpixzCIbJiITTYwm4b5KkNQ5eihoWZsK1fcuL5o)hecUavZa3zWHdmIydYb36hhw5gqk4UMIeDGZptJjBEOolDkPooZDizhBWfkevrhzW1ersH500bEgFdPXNIc(REgCbQw0yQbUZGdUbUZGNLiAhsZPPd8GCLXjgmIi22kBXGhKtQCQMtGC4aplrwxiqvM78Fqi4cundCNbhoWiseqo4w)4Wk3asb31uKOdClSJikxwkw3mTnpumtLeHR9DiCNa2rtez2XzUJfVJMiYuNtP8F7qIm7ezhHfEh(zAmzZd1zPtj1XzUtuSJ9obcUqHOk6id(HIzQKiCTdEwISUqGQm35)GqWfOArJPg4odo4z8nKgFkk4V6zWnWDgC5OyMUdbaU23ja7abxiACcCnzDLLomnMVKm2GhKRmoXGreX2wzlg8GCsLt1CcKdh4zjRRSCmnMVeqk4cundCNbhoWicbcYb36hhw5gqk4cfIQOJm4AIijlXLzWZ4Bin(uuWF1ZGlq1IgtnWDgCWnWDg8Ser7iB4Y8obyhi4b5kJtmyerSTv2IbpiNu5unNa5WbEwISUqGQm35)GqWfOAg4odoCGrecgKdU1poSYnGuWfkevrhzW1ersH500bEgFdPXNIc(REgCbQw0yQbUZGdUbUZGNLiAhsZPPBNaSde8GCLXjgmIi22kBXGhKtQCQMtGC4aplrwxiqvM78Fqi4cundCNbho4a31uKOdC4aa]] )

    storeDefault( [[SimC Windwalker: CD]], 'actionLists', 20171228.223921, [[dKentaqijP2Ka8juHQgfkOtbrAwOcXTeLa7IunmuvhtsTmjXZOsstJkPCnicBtuI(gQuJtssohQqzDIsqZdf4Euj2NKeheIAHOIEiQKjcr0ffqBKkjgjvsfNKkvRuss1nrODsk)evOYsffpLYurrxfviTvQu(QKKYyPsQYBPsQ0DPsQQ9Q6ViAWeoSulgLESitwOld2SG(mQYOrWPjz1IsOxdbZwIBdPDd1VvA4c0XfLKLJ0ZPQPR46uX2rH(UOuJhvW5fvRxusnFi0(j6xFM3qsiSDkZ58MwJc3mfkxsrvtHJz3feaAwOuWfsElduG2dxRc)AURRWNJPxPIRvHpsCZsuvW52nKtJAX(Z8A1N5TaXnBbINZBiZQkQj)McZ4IaqYbhaFZDCuL6zP3WlgUrCJU1uTgfUDtRrHBUJzCraKcxphaZrKIHaifvncQbKcMkEa9wgOaThUwf(1CxZ)wgWVo0e4pZp34IaKqG4YiGc45S3iUrTgfU95AvoZBbIB2cepN3qMvvut(n2YUrYqhA(n3XrvQNLEdVy4gXn6wt1Au42nTgfUXzz3Ou4ko08BzGc0E4Av4xZDn)Bza)6qtG)m)CJlcqcbIlJakGNZEJ4g1Au42NR5QN5TaXnBbINZBiZQkQj)glq9afbfM3n3XrvQNLEdVy4gXn6wt1Au42nTgfUXjq9afbfM3TmqbApCTk8R5UM)TmGFDOjWFMFUXfbiHaXLrafWZzVrCJAnkC7Z1CTZ8wG4MTaXZ5nlrvbNBjckD0MdsrwGuKiO0toukGhPOkUif1srasbGbkVC9rHcKZsI2CqkQIlsbFDK4gYSQIAYV10uJbYzPuap3ChhvPEw6n8IHBe3OBnvRrHB30Au4gY0uJbPG5sPaEULbkq7HRvHFn318VLb8Rdnb(Z8ZnUiajeiUmcOaEo7nIBuRrHBFUgsCM3ce3SfiEoVrS5Gc1bLzt5bJ)wLBwIQco3QwkA6Oc70OZRlajRd1p6aUzlqukcqkGSYrfmie1jOIratI2(bOEYWLYQIratoRtIGueGuuTueKcmsYlf1R1N1jrGCdjJqpeUHmRQOM8BZ6KiqUHKrOhc34IaKqG4YiGc45S3iUr3AQwJc3U5ooQs9S0B4fd30Au4gZ1jrqk2qPajHEiCdzkp)TuEQaKtt5bJ3LAocAZbYuEQaKtt5bJ3Lk3YafO9W1QWVM7A(3Ya(1HMa)z(5gx5PcWSP8GXFoVrCJAnkC7Z1YYZ8wG4MTaXZ5nlrvbNBvlfnDuHDA051fGK1H6hDa3Sfikfbifvlfqw5OcgeI6euXiGjrB)aupz4szvXiGjN1jr4gYSQIAYVnRtIa5gsgHEiCZDCuL6zP3WlgUrCJU1uTgfUDtRrHBmxNebPydLcKe6HGuWWAKElduG2dxRc)AUR5Fld4xhAc8N5NBCrasiqCzeqb8C2Be3OwJc3(CnUpZBbIB2cepN3i2CqH6GYSP8GXFRYnlrvbNBnDuHDA051fGK1H6hDa3SfikfbifmukyOumDbWJUhOawn56aUzlqukcqks7wIB2yDpqbSAY1PaARWEPGbUif1sbsLcerukseu6jhkfWJuufxKIksbsLIaKcgkfPDlXnBSUFOkeaYnKCiaKzRWXYsJ6uaTvyVuWaPOQKceruks7wIB2y9qLF8KBizOdnxNcOTc7Lcg4Iu4AsbsLIaKI0UL4MnwNQ8kmpsVdMebvcbDkG2kSxkyGuWTueGuuTueKcmsYlf1R1N1jrGCdjJqpeUHmRQOM8BZ6KiqUHKrOhc34IaKqG4YiGc45S3iUr3AQwJc3U5ooQs9S0B4fd30Au4gZ1jrqk2qPajHEiifmScsVHmLN)wkpvaYPP8GX7snhbT5azkpvaYPP8GX7sLBzGc0E4Av4xZDn)Bza)6qtG)m)CJR8uby2uEW4pN3iUrTgfU95Av1zElqCZwG458MLOQGZTPlaE09afWQjxhWnBbIsrasr1sbRtyOUhOawn56obLIaKcaduE56JcfiNLeT5GuufPWvVHmRQOM8BrA7WJWqUHK(1P4V5ooQs9S0B4fd3iUr3AQwJc3UP1OWnKK2o8imsXgkf26u83YafO9W1QWVM7A(3Ya(1HMa)z(5gxeGecexgbuapN9gXnQ1OWTpxJJDM3ce3SfiEoVzjQk4CRAPy6cGhDpqbSAY1bCZwGOueGuuTuW6egQ7NLIscnDiq24izOIc6obLIaKcaduE56JcfiNLeT5GuufPWvVHmRQOM8BrA7WJWqUHK(1P4V5ooQs9S0B4fd3iUr3AQwJc3UP1OWnKK2o8imsXgkf26u8sbdRr6TmqbApCTk8R5UM)TmGFDOjWFMFUXfbiHaXLrafWZzVrCJAnkC7Z1Q5FM3ce3SfiEoVzjQk4CJ1jmu3duaRMCDkG2kSxkyGuulfiIOuWqPOAPy6cGhDpqbSAY1bCZwGOueGuebwNWq9zDsei3qYi0dbDNGsbsVHmRQOM8BHlLheQaC0tg2SuvQNLEZDCuL6zP3WlgUrCJU1uTgfUDtRrHBUYs5bHkah549sHR0SuvQNLElduG2dxRc)AUR5Fld4xhAc8N5NBCrasiqCzeqb8C2Be3OwJc3(CT66Z8wG4MTaXZ5nlrvbNBvlfnDuHDA051fGK1H6hDa3SfiEdzwvrn53CWSuvSarYqhA(n3XrvQNLEdVy4gXn6wt1Au42nTgfUXrXSuvSarPWvCO53qMYZFd3OGloywQkwGizOdn)wgOaThUwf(1CxZ)wgWVo0e4pZp34IaKqG4YiGc45S3iUrTgfU95A1voZBbIB2cepN3SevfCUXqPOAPOPJkStJUFOkeaYnKCiaKzRWXYsJ6aUzlqukcqks7wIB2yD)qviaKBi5qaiZwHJLLg1PaARWEPGbsrTRjfbifPDlXnBSEOYpEYnKm0HMRtb0wH9sbdCrkQrcPiaPiTBjUzJ1PkVcZJ07GjrqLqqNcOTc7LcgifClfivkqerPG1jmu3duaRMCDNG3qMvvut(nhmlvflqKm0HMFZDCuL6zP3WlgUrCJU1uTgfUDtRrHBCumlvflqukCfhAUuWWAKEdzkp)nCJcU4GzPQybIKHo08BzGc0E4Av4xZDn)Bza)6qtG)m)CJlcqcbIlJakGNZEJ4g1Au42NRv7QN5TaXnBbINZBwIQco3QwkMUa4r3duaRMCDa3SfikfiIOuK2Te3SX6EGcy1KRtb0wH9sbdKI6QskqerPiTBjUzJ19afWQjxNcOTc7LIQifibFPareLIPP8GrFuOa5SKrfifmWfPWv5Fdzwvrn53iSum5gsYyxw6n3XrvQNLEdVy4gXn6wt1Au42nTgfU56SuSuSHsHBDzP3qMYZFd3OGlewkMCdjzSll9wgOaThUwf(1CxZ)wgWVo0e4pZp34IaKqG4YiGc45S3iUrTgfU95A1U2zElqCZwG458MLOQGZnwNWq90I5bDrH5rYBxD)0jeKIQ4IuKL3qMvvut(TrHZj3nRHIcZJuHjBYSytV5ooQs9S0B4fd3iUr3AQwJc3UP1OWnMkCUuWXTznuuyEsHclfTuu1B6nKP883Wnk4YOW5K7M1qrH5rQWKnzwSP3YafO9W1QWVM7A(3Ya(1HMa)z(5gxeGecexgbuapN9gXnQ1OWTpxRgjoZBbIB2cepN3SevfCUXqPG1jmu3duaRMCDNGsrasr1sbKvoQGbHOUpiKgGsUHKSWq78UifivkqerPGHsbKvoQGbHOUpiKgGsUHKSWq78UifbifmukgfkifmqkqcPareLI0UL4Mnw3duaRMCDkG2kSxkyGlsrvjfivkqQuGiIsr1sX0fap6EGcy1KRd4MTarPareLIPP8GrFuOa5SKrfifmWfPiTBjUzJ19afWQjxNcOTc7VHmRQOM8BmQ6c5gsMG2dfW7jNLdkS)M74Ok1ZsVHxmCJ4gDRPAnkC7MwJc3Ct1fPydLcUG2dfW7LcMlhuy)nKP883Wnk4cJQUqUHKjO9qb8EYz5Gc7VLbkq7HRvHFn318VLb8Rdnb(Z8ZnUiajeiUmcOaEo7nIBuRrHBFUwDwEM3ce3SfiEoVzjQk4CJHsrA3sCZgR7bkGvtUofqBf2lfvrkQ5lfiIOuW6egQ7bkGvtUUtqPaPsbIikfvlftxa8O7bkGvtUoGB2ceVHmRQOM8B(GqAak5gsYcdTZ7Yn3XrvQNLEdVy4gXn6wt1Au42nTgfUzbH0auPydLcoHH25D5gYuE(B4gfCXhesdqj3qswyODExULbkq7HRvHFn318VLb8Rdnb(Z8ZnUiajeiUmcOaEo7nIBuRrHBFUwn3N5TaXnBbINZBiZQkQj)MJhivdG6V5ooQs9S0B4fd3iUr3AQwJc3UP1OWnetHH85NsHHUUCupifUpaQ31hr6TmqbApCTk8R5UM)TmGFDOjWFMFUXfbiHaXLrafWZzVrCJAnkC7ZNBwqiP6IkR7rT4Rvjl5yF(b]] )

    storeDefault( [[SimC Windwalker: serenity opener]], 'actionLists', 20171228.223921, [[dqKIkaqiKuSifkztuunkvaNsfOBPqb7IQAyiXXOWYuiptHQAAkuLRHKQ2McL6BKsgNcf15ivK1rQG5rrX9qs2hfLoiv0cvGhsrMisQCrsL2OcvCsQGxsQqZKur5MQk7ePgQcvAPKQEkQPQQARuH(QkiVvHcDxsfv7v6VuLbl4WGwmv6XKmzv6YqBwf9zf1OvqNgXRvKzlQBRk7MWVjA4KILd8CknDLUUi2Uk03jLA8iP05fP1RqrMVkO2VqxJ(xwxb0nJ36wM1GkcmtgtWLifLE0yRtLPo8eMK3oOSEmJqlw6rum0YyefDYF0OXBefQVmRaenB5YovlrkS9V0g9VSUcOBgVDqzwbiA2YutmObGh9MvxFd)LmJapnW8lgmpgqbcMt9vjaak2yGQyafiyo1)bP2yW8yqnK4RsaauSXGzIbJyW8yGAIb3KZtFlcqbzt9t0edMhdkPmFLAl8pj216jp9otaP(a8bjcBmygQIbkLD6sYKnT8sMrGNgy(v20qun9jpIpuS1T8N86ieqdFy5YoiUefCLGYcPaltdFy5FYmcIHXfMFLDcMTLvPQm6TqWmUwQmkRhZi0ILEefdTmOuwpALjafA7F3YMsvz8hcMX12bL)KxA4dl3T0J6FzDfq3mE7GYScq0SLvdj(pi1gdJHyqnK4RsaauSXGzPkgmIbZJbuGG5u)L8qVv69GuBmywQIbk(uFzNUKmztldbkOa9wjaGITSdIlrbxjOSqkWYFYRJqan8HLltdFyzNafuGXWVeaqXwwpMrOfl9ikgAzqPSE0ktak02)ULnnevtFYJ4dfBDl)jV0WhwUBPh)(xwxb0nJ3oOmRaenBzLuMVsTf(Ne7A9KNENjGuFa(GeHngmBmyu2Pljt20Ykyo7bvlrk8Ye7w2bXLOGReuwify5p51riGg(WYLPHpS8HvNNuOOuNNJrtWCogCQwIued6mID15hgu2jy2wwaFivJftEMIHdrexTH5jeOdXGjQBSkRhZi0ILEefdTmOuwpALjafA7F3YMgIQPp5r8HITUL)KxA4dlZKNPy4qeXvByEcb6qmyI66w6XR)L1vaDZ4TdkZkarZwwjL5RuBH)jXUwp5P3zci1hGpiryJbZgdgLD6sYKnTSfbOGSPLDqCjk4kbLfsbw(tEDecOHpSCzA4dlZiafKnTSEmJqlw6rum0YGsz9OvMauOT)DlBAiQM(KhXhk26w(tEPHpSC3st99VSUcOBgVDqzwbiA2Yq1soIEOaFe0gdMjgg)yW8yWn5803Iauq2u)enLD6sYKnTmGyjIzpBIWBIOMkBAiQM(KhXhk26w(tEDecOHpSCzhexIcUsqzHuGLPHpSSEILiMJbored6irnv2jy2wwLQYO3cbZ4APYOSEmJqlw6rum0YGsz9OvMauOT)DlBkvLXFiygxBhu(tEPHpSC3sp29VSUcOBgVDqzwbiA2YUjNN(weGcYM6NOPStxsMSPLTlGmHEYtVDi6PnrCZsWTSdIlrbxjOSqkWYFYRJqan8HLltdFyzEbKjmgKNXWoeJHdre3SeClRhZi0ILEefdTmOuwpALjafA7F3YMgIQPp5r8HITUL)KxA4dl3T0A1)Y6kGUz82bLzfGOzlFGyGAIbna8O3S66B47MHQjzY6nrutXWbJbZJHdedAa4rVz113W3UaYe6jp92HON2eXnlb3y4GLD6sYKnTSBgQMKjR3ernv20qun9jpIpuS1T8N86ieqdFy5YoiUefCLGYcPaltdFy5bzOAsMSXGosutLDcMTLvPQm6TqWmUwQmkRhZi0ILEefdTmOuwpALjafA7F3YMsvz8hcMX12bL)KxA4dl3T0J5(xwxb0nJ3oOmRaenBzLuMVsTf(aILiM9SjcVjIAYhGpiryJbZgdgXWHpCm4MCE6BrakiBQ)vQTOStxsMSPLpj216jp9otaPLDqCjk4kbLfsbw(tEDecOHpSCzA4dlpoe7AJb5zmmojG0YobZ2YeXIaqIMLkJY6XmcTyPhrXqldkL1JwzcqH2(3TSPHOA6tEeFOyRB5p5Lg(WYDlTo1)Y6kGUz82bLzfGOzl7MCE6BrakiBQ)vQTigmpgudj(QeaafBmygQIHrXG5XGskZxP2cFlcqbzt9b4dse2yWmufduIbZJbna8O3S66B4VKze4PbMFLD6sYKnTSBgQMKjR3ernv20qun9jpIpuS1T8N86ieqdFy5YoiUefCLGYcPaltdFy5bzOAsMSXGosutXWbmoyzNGzBzvQkJElemJRLkJY6XmcTyPhrXqldkL1JwzcqH2(3TSPuvg)HGzCTDq5p5Lg(WYDlTbL(xwxb0nJ3oOmRaenBz1qIVkbaqXgdufdgLD6sYKnT8sMrGNgy(v20qun9jpIpuS1T8N86ieqdFy5YoiUefCLGYcPaltdFy5FYmcIHXfMFXWbmoyzNGzBzvQkJElemJRLkJY6XmcTyPhrXqldkL1JwzcqH2(3TSPuvg)HGzCTDq5p5Lg(WYD7wMg(WYm5zkgoerC1gMNqGoedweGcYMgdsnOabDBb]] )


    storeDefault( [[Windwalker Primary]], 'displays', 20171113.171213, [[da0iiaqlck2fePAykYXKslJk5zeitJkvDnQuzBkQY3GizCeOY5iO06irCpcu6Gk0cvWdjKjQOQUOkSrfLpQOYijO6KeQxsaMjjQBsaTtk9tizOKYrjqXsjipfmvO6QKiTvcu1xHiwlePSxXGvPoSKftHhJstwLCzL2Su8zi1OPItJ0RHqZwQUnPA3O63igouoovklNONtvtxvxhfBNe(ofnEiQZtsRhc2Vk60g8aSf2tj8ze(dVAFdGsP4kl2Ee4lj691uOfJaYIJEf5SSiMHaUXSm7yNIMRV8paBavunn(9fvypLW9Xofazunn(9fvypLW9XofWnMLzVeZs4afHnw3pfW7qmhzKLyEdjgbCJzz2lrf2tjCFgcOIQPXVpEjrVVp2PacgMLz9bp22Gh4Gxg99kdbgzFkHFERm1)Xk4cyl9naq1fDEJek)YS6iUsLCEJjxwIUr9beA7B53yDn1oV2PjbfayLuSpWt1xb7u(yDf8ah8YOVxziWi7tj8ZBLP(pwKkGT03aavx05nsO8lZQJ4kvY5912um9pGqBFl)gRRP251onjO85d4DiMGj9zDgpYqaVdXCK5jziaLLWbSILYrhR7cumYsmVHGRITbmyAAcOgRW4YL7c0q4FGdKXKR3BwQb8oet8sIEFFgcGOXiN1HidGJstiXZjC8aSeDJ61uCeJaSf2tj8roRdrgyafookbgqebt98gNeaju(Lz1rCLN3JOoc4DiMaEgc4gZYSZNkx2Ns4bes8CchpaNrxmlH7J19b8yBVpRxEhrKorg8avSTbKX2gaDSTbmITnFaVdXuuH9uc3NHaiJQPXV)iJSIDkqXilCvSnGbttta9c5rMNe7uGQJ5uJDZs1RP4i22avhZPahIPMIJyBduDmNser3OEnfhX2gWw6BaKq5xMvhXvEERjP6LunGBmuwef8up8Q9nqfO6MLQxtHwgcOG6Pg0o9vXvX2agbylSNs4JDkAEarhw8dHcCr9y9sfxfBdubM)2um9pdbKfh9IRITbkdAN(QbkgzjqkFZqaaBzPvNIq9ucpwxZtydGOXmc)bkcBSTUcOIQPXVVy(fLTEI0h7uGQJ5u4Le9(Ak0ITnGrNIacZ1jMJ9Emci3Earhw8dHc4X2EFwV8oXiq1XCk8sIEFnfhX2gGYs4incrp2w3fWnMLzVeZVOS1tK(mea5yNc8Le9(JCwhImWakCCucuiXZjC8aFjrV)mc)HxTVbqPuCLfBpciWczQoJ(5novFJvqtb8oetWK(SoJmpjdbawjf7deO6yo1y3Su9Ak0ITnaMKQxsvXSeoqryJ19tbWKu9sQoJWFGIWgBRRayYLLOBu)OMYbaQUOZBKq5xMvhXvQKZBm5Ys0nQpGrNIacZ1jMXiGEH84rStbWR(Y)Z75KegSyNc8Le9(AkoIraVdXuaRQbLFr5O9ziGMKQxs1ZBrf2tj8aFjrVVpGEHmGhBBak)IYwproYzDiYacjEoHJhqts1lP65TOc7Pe(59iJSceGTWEkHpJWFGIWgBRRavhZPer0nQxtHwSTb8oetX8lkB9ePpdbQoMtboetnfAX2gO6MLQxtXrgc4DiMAkoYqaVdXC8idbyj6g1RPqlgbq0ygH)b0WpVHI7pVTLusmdOIQPXVVag8XkmTbq0ygH)WR23aOukUYIThb0PCap2PaFjrV)mc)bkcBSTUc4DiMAk0Yqa2c7Pe(mc)dOHFEdf3FEBlPKygOyKfGT9U45h7uGdEz03RmeWt1X67iQJyDfqfvtJF)rgzf7uaKr1043xad(yBdi023YVX6AQfPMqkxccPpjSUZvBGVKO3FgH)b0WpVHI7pVTLusmdCTnft)h1uoaq1fDEJek)YS6iUsLCEFTnft)dOt5JhXkOaiJQPXVpEjrVVp2PacyvnO8lkh95n8Q9nwxbkgznYzDiYadOWXrjqLpMHhWnMLzVMr4pqryJT1vaKr1043xm)IYwpr6JDkGBmlZEjGbFgcOt5Jmpj2PafJSukN(bW6L6kZNa]] )

    storeDefault( [[Windwalker AOE]], 'displays', 20171113.171213, [[da0diaqlsISlcqnmf5ysPLbrEgvrttrfxJKkBJa4BKuACKeY5ijQ1rsQ7rsqhublufEibnrfv6Ik0gvu(ivPgjjjNKqEjjvntQsUjb0oPYpHKHskhLKalLa9uWuHQRssXwjjuFvrvRLaK9kgSk1HLSys8yuAYq4YkTzQQpdPgnfDAKETkYSLQBtQ2nQ(nIHdLJtvy5e9CknDvDDuSDc13PW4HOoVuSEvu7xLCAdEa2c7Pe(mc)HVPVbqPgCVe5gd8Le9(AI1IsazXrVcnx2t5iGsNE(S3DIruc0GY33UVWc7PeUnUPaiJY33UVWc7PeUnUPaysQEjBeXs4a98g3CMcOt5dJX5zapywMfHWc7PeUnhbAq57B3hVKO33g3uavaZYS2GhxBWdmYlL(IihbgyFkHFD7f1(XPIc4k9naq1fEDppLJWO6NwPQVUXKllrxP(acU9TSBCin1kaTttEgayLuSpWt1xv4u(4qk4bg5LsFrKJadSpLWVU9IA)4uBaxPVbaQUWR75PCegv)0kv91nI1Vy6Fab3(w2noKMAfG2PjpZNpG1Kyag0N1CymhbSMeJbMNeLa6fYaECtb(sIE)boRjrg4afookbkOiVvfEGM4uPw1QUa(e(hyezm5ATgvtaRjXaVKO33MJaNug4SMezaCuAckYBvHhGLORuVM4XOeGTWEkHpWznjYahOWXrjWacjynx34KaZt5imQ(PvEDpGAmG1Kya45iGhmlZoxQCzFkHhqqrERk8aCgDrSeUnU5eWIT9(SEznfs6ezWduX1gqjU2aOJRnGmU28bSMedHf2tjCBocGmkFF7(dmYkUPafJSWBW2akm((b0lKhyEsCtbQoMzn0nQgRM4X4AduDmZcmjgAIhJRnq1XmlHeDL61epgxBaxPVbMNYryu9tR86Ea1yGQBunwnXA5iGyQLQq70VbVbBdOeGTWEkHp0PO5beo6WhfmGhmu2tQyQf(M(gOcGGAX6vdEd2gGnGS4Ox8gSnqPq70VjqXilbs5Bocm31Vy6FocCszgH)a98gxlsbAq57B3xehbLTEI0g3uanjvVKnx3clSNs4x3dmYkqaKr57B3xehbLTEI0g3ua52diC0Hpkyal227Z6L1mkbQoMzHxs07RjEmU2aih3uapywMfHiockB9ePnhbOSeUaIq0JRvDbSMedWG(SMdmpjhb(sIE)ze(dFtFdGsn4EjYngqGfYuDg9RBCQ(gNNtbqgLVVDF8sIEFBCtbawjf7dyPC09nq1XmRHUr1y1eRfxBapywMfHiwchON34MZuamjvVKnZi8hON34ArkaMCzj6k1pO5vaGQl86EEkhHr1pTsvFDJjxwIUs9bOSeoGvSuo64uxa9c5HX4McGx9L)x3EljmyXnf4lj691epgLacU9TSBCin1Q2j1IKNc4jvwDi1gqts1lzZ1TWc7PeEGVKO33gO6yMfEjrVVMyT4AdOt5dmpjopdWwypLWNr4pqpVX1IuaLo98zV7eJHEpkbqS(ft)h08kaq1fEDppLJWO6NwPQVUrS(ft)dynjgI4iOS1tK2CeO6yMLqIUs9AI1IRnq1nQgRM4XCeWAsmggJsaRjXqt8yocWs0vQxtSwucuDmZcmjgAI1IRnG1KyO(TrHYrq5OT5iWjLze(dFtFdGsn4EjYngqNYb848mWxs07pJWFGEEJRfPaNuMr4Fan8RBO42RBxjLeJaSf2tj8ze(hqd)6gkU962vsjXiqXilaB7DrZnUPaJ8sPViYralvhRVdOgJZZanO89T7pWiR4McynjgAI1YrGVKO3FgH)b0WVUHIBVUDLusmcGmkFF7(Q)WgxBGgu((29v)HnovQnGhmlZo0PO56l)dWgWAsmgyKLiUpjkbkgzjI7tWBW2akm((bkgznWznjYahOWXrjqVgNHhWdMLzrmJWFGEEJRfPauockB9e5aN1KidiOiVvfEapywMfH6pS5iaGTS0QtpxpLWJdjbqLdumYsnC6haRxnRmFca]] )

    storeDefault( [[Brewmaster Primary]], 'displays', 20171113.171213, [[d0ZGhaGEfvVKGyxis61kkntQIEmsnBf(nu3es01uu8neP6Ws2jP2Ry3KSFK0pvLgMImoiH8CkgkHgmIA4iCqPYrPevhtkDoejSqk1sPewSuSCuEOuvpfSmQsRdrIMiKKPcXKPKMUsxuvCvcsxwLRRQ2OuLTIiLntuBNaFKQWZGK6ZqQVtLgjLiBdsWOjY4reNejUfLOCAuDEQ42uvRfsOoob1PnibOlILJv9WQfwNXf4vOiEsr)eGUiwow1dRwGp)IU1BawPqF9Lo6zJDGMbF(Cpgy30eW5vw2CB)Iy5yLj6PaK8klBUTFrSCSYe9uacg3VyouOXkGp)IEMPa(Cv3t0OoGW)7Fw7xelhRmXoGZRSS5wKIH(wt0tbS8)9ptqIUnibEuvZ4Sg7aD0lhROs2tUzJUnGU8VaO6KR)ydyXnUYCr7DQffANMqDaGMXj2azZgWiHDbx(sl19e7agjSB3FXXoaNgRaIIMRqh9mb2IH(2ofTeMfW(fb5fLwqXdlHeWjAlZlkmfGKO96LuNjGrc7Ium03AIDGzB6u0sywaKxrlO4HLqcqJ9BQvuWtAcqxelhR6u0sywa7xeKxugaioAEn4ZRLJvr7ffqrbmsyxaj2be(F)dvC2rVCSkGfu8WsibuFFk0yLjAuhWqCJrVrzK6Jhywqcur3gOj62aOJUnal62Sbmsy3(fXYXktSdqYRSS52UpRIEkq9zfIdXfO5llhWViP7V4ONcudcPQB4wogrbpr3gOgesfiHDff8eDBGAqiv9X(n1kk4j62aO6KR)yJDGA4wogrbIXoGaUH3Wh81bXH4c0eGUiwow1n4Ovb6)OrESiGWFo9SKg3aRZ4cubSYneJYbXH4cubyLc9H4qCbQg(GVobQpRqjxDXoGU8Va2SZ1Vm7XOswKX9lMtGzB6HvlWNFr36najVYYMBPOSYPRfZmrpfqKX9lMdvY9lILJvuj39zvGaoVYYMBPOSYPRfZmrpfGDJa9F0ipweWqCJrVrzKstGAqivifd9TIcEIUnG1tU(JTt0ZauinQKTzNRFz2JrkPsgvNC9hBaH)3)SsrzLtxlMzIDaonwHIXy)OBNjq9zffLmgXH4c08LLdSfd9T9WQfwNXf4vOiEsr)eaLfjC)VpvYiC)lAupfWiHDbx(sl19xCSda0moXgiqniKQUHB5yefigDBaH)3)SsHgRa(8l6zMcqW4(fZPhwTaF(fDR3aeSJg73uBNONrpfGRSYPRfZ6u0sywalO4HLqc4xK09e9uaKACQLkzpy4pr0tb2IH(wrbpPjGiJ7xmhQK7xelhRcSfd9TMawCJRmx0ENAj9js3lQj1jsXmEBd4xKair3gOgesfsXqFROaXOBd4ZvD)fh9uGTyOVvuGyAc0m4ZN7Xa72ngPjGrc7srzLtxlMzIDGAqiv9X(n1kkqm62a1WTCmIcEIDaJe2T7j2bmsyxrbpXoan2VPwrbIPjGrc7kKZPHRSYvOnXoWSn9WQnGicvYqPmujRlgd7gGKxzzZTcX2eDBaFUcqIEkWwm032dRwGp)IU1BaJe2vuGySdqxelhR6HvBareQKHszOswxmg2nq9zfqCJbfuf9uGhv1moRXoGH7tmUU3NO9gOgesfiHDffigDBaNxzzZTDFwf9uGzB6HvlSoJlWRqr8KI(jajVYYMBrkg6BnrpfW5vw2CRqSnrBzTbe(F)RBWrR8p1gGoGrc729zffLmonbKXQnqhJxdQK1fJHDduFw1POLWSa2ViiVO0ZNEibe(F)ZApSAb(8l6wVb2IH(2Ey1gqeHkzOugQK1fJHDdi8)(NvHyBIDG(ychQKrWbSzNRFz2JrLC37tG6ZkHQ4BaIr5CSSja]] )

    storeDefault( [[Brewmaster AOE]], 'displays', 20171113.171213, [[d0tHhaGEfPxsqAxiP41QkmtQk9yKA2k8BOUPQIUgvv(gsQ6Ws2jL2Ry3eTFK4NQsdtvmoKK45KAOeAWiYWr4GuXrPQOoMu15qsklukwkjXIPOLJQhQiEkyzsPwhss1ersmviMmj10v6IkQRsvHlRY1H0gLs2kskTzkSDc8rQQ6zeuFwv13PsJKGyBiPYOjX4vv6KiQBrvronkNNQCBPYArsshNK0PpibOlILHLTWYfwVXf41hi(s2ohGUiwgw2clxGn9ITVDaEj)Vjkh9hPjG5GnDQ)dSBmd49AyOVDsrSmSuh7tGVVgg6BNueldl1X(eqv0d9utMglb20lw)Ec0XKoZXkCavrp0t9KIyzyPonb8Enm03Iu8)B1X(eWNrp0thKy7dsGzzzoo1PjGd9YWskK8LP3y7dyRUlavoJcDSbu5gxPVyB)0tD9ppchaO5mInq2Sb0kyxWLT0koZPjGwb76GU4ygGrJLarrZK)X6xGcLxKLgyepIlGjQHraVy9P2p(fWal3aoCwnOqYwCo2nGwb7Iu8)B1PjWhMosAfmpaYROkK9xiibOXDM1kkyoMbOlILHLosAfmpqZlcY7NbMGj8OqcbhOHFUDLEpofsoVZb0kyxajnbuf9qpQW4h9YWYaQq2FHGeqI2rMgl1XkCanXngTgLwzcEG5bjqfBFaES9b(JTpGzS9zdOvWUtkILHL60e47RHH(whuEf7tGcLxiEexatudJaD1xh0fh7tGAqOuod3Ytlkyo2(a1GqPafSROG5y7dudcLAcUZSwrbZX2hGkNrHo20eOgULNwuGyAciGPzMSbB9q8iUaMbOlILHLod2VmWKzlYSkbufLr)b1Y0W6nUava1mnXO8q8iUa0b4L8)q8iUaLjBWwVafkV(KjV0eOJjDqxCSch4dZwy5cSPxS9TdaehnRgSP1YWYyBtDuLa1GqPqk()TIceJTpG3RHH(wYs1m6AXCDSpb43iWKzlYSkb0e3y0AuALygOgekfsX)VvuWCS9buFgf6yDe9nazQLcPg(52v694uDkKOYzuOJnGQOh6PMSunJUwmxNMamASKQIXDX27xGU6lGe7tGT4)32clxy9gxGxFG4lz7CGpRVSo0okKqyDxSc)eqRGDbx2sR4GU40eaO5mInGMj)hxGAqOuod3Ytlkqm2(amPAgDTyUJKwbZdOcz)fcsacoRR4ETWYfytVy7BhGGF04oZADe9n2NaFJTDBQXVaD1xN5yFcGuJtUui5phJse7tGT4)3kkyoMbe5SUI7rH0KIyzyzGT4)3QdOYnUsFX2(PN6FO(2ctnpun)A3hGGZ6kUhzASeytVy97jGiN1vCpkKMueldlPqYbLxbcSf))wrbIXmGT6Uan8ZTR07XPqY5DoG5GnDQ)dSRZyeZaAfSlzPAgDTyUonbQbHsnb3zwROaXy7dud3Ytlkyonb0kyxN5ygqRGDffmNMa04oZAffigZaAfSRqpptMunt(RttGpmBHLBarekKGsQPqYwCo2nW3xdd9TcTrhBFGoMeqIv4aBX)VTfwUaB6fBF7aAfSROaX0eGUiwgw2cl3aIiuibLutHKT4CSBGcLxaXngKPsSpbMLL54uNMaAwhX4CENJv4a1GqPafSROaXy7d49AyOV1bLxX(e4dZwy5cR34c86deFjBNd891WqFlsX)Vvh7taVxdd9TcTrhRp1hqv0d9CgSFz3j3a0b0kyxhuErwAGJzGT4)36iPvW8anViiVFQcz)fcsGcLxosAfmpqZlcY7N(o3cjGQOh6PUfwUaB6fBF7aBX)VTfwUberOqckPMcjBX5y3aQIEONAH2OttGVVgg6BjlvZORfZ1X(eOq5LpKSnaXO8oE2ea]] )

    storeDefault( [[Brewmaster Defensives]], 'displays', 20171113.171213, [[d4JChaGEfYlje2fIKETuPoSKzsfCCcLzRORri1nvLQhJuFdrQEor7Ks7vSBuTFs4NQkdtbJtQeEMQugkfgmjA4iCqP0rrKOJjfNdrclKIwkHQftLwoPEOc1tblJkADQsQMOQetfstgjnDvUOQ4QesUSsxhInkvSvePSzc2UQQpsf6ZiQPPkP8DQYijeTnPsA0K04reNejULQKCAuopv1VHATsLOBlvDAcAa6I4yyEhm)GZFUb(efQduSpbUstEpJFJ4gqxCY7y1LU7ygqmKfzBNmY8(LFbOd4)jii3BCrCmmxg7qas(eeK7nUiogMlJDiGyilYsLcnMdSrBSofDGEgV9j23cigYISuhxehdZLXmG)NGGCp0stEpzSdbiLilYkdASnbnWdVCNl1ygOL(yyUcLoWKxSodyR(nWlRWYLS)vgq8DULCJ15qtxBggElaqRzexGC5civXEGh7OvBFIzaPk2Rf5WXmaJgZbIIMXjhROdui6IcxaJ6tSbCreec4h7RC21Hacy(fOvZQPcL2sRXEbKQyp0stEpzmd0TBlNwfRdG(ziofhfjAaACVBDg)pXnaDrCmmVLtRI1bm)qr)EpaqS0SAYgvhdZJ1zx7IasvShGgZaIHSi7lm9sFmmpG4uCuKOb4i9uOXCzSnbKe7C2zws1X4jwh0avSnb0X2eGCSnbCJTjxaPk2BCrCmmxgZaK8jii3RfrxXoeOq0fQpXgWfrqiqFrslYHJDiqnjuR2Px5ln(FITjqnjulqf7z8)eBtGAsOwJX9U1z8)eBtaB1Vbm1RxFjVvRq5lRWYLS)vgOMELV043iMb(zsMlBYoFuFInGBa6I4yyE7KrMhy8Jf9r8auzsIz5J6tSbOgqxCYlQpXgOCzt25hOq017m(gZaIHWO7M0ys48NBGkq3UDW8dyJ2yBgc8YkuiZlMbQjHAHwAY7z8BeBta)pbb5Eu4uz01H1YyhcO3zGXpw0hXdij25SZSKQXnqnjul0stEpJ)NyBcCLM8EDW8lGbQcLqXLkuAlTg7fqmKfzPsHtLrxhwlJzG(Iean2MamAmVlX4(yFBiWvAY71bZp48NBGprH6af7tG3lsy9i9kuIY63yFBiGuf7bESJwTf5WXmaqRzexGa1KqTANELV043i2MaxPjVxlNwfRdy(HI(9U4uCuKObi0S(s73bZpGnAJTXzac9sJ7DRR1WHyhc4ozJg54e7f3a9fjTpXoeaTMl)uO0rngHi2HaxPjVNX)tCdW4uz01H1TCAvSoG4uCuKObm0S(s7Rq54I4yyEaQRqHmVaeAwFP9PqJ5aB0g7RneWqZ6lTVcLJlIJH5ku2IORab6z8wKdh7qa6I4yyEhm)a2On2gNbCNSrJCCI9ANZ4gqQI9OWPYORdRLXma1vOqMxRHdbOqAkuAQxV(sER(1vO8Lvy5s2)kdutVYxA8)eZa1KqTgJ7DRZ43i2MasvSNX)tmdqJ7DRZ43iUbKQyprS(UmovgNSmMbKQyV2NygOB3oy(fWavHsO4sfkTLwJ9c0Z4aASdbUstEVoy(bSrBSnod0TBhm)GZFUb(efQduSpbOlIJH5DW8lGbQcLqXLkuAlTg7fOq0fqSZjLxIDiWdVCNl1ygqY6jMB73tSodutc1cuXEg)gX2eW)tqqUxlIUIDiGuf7z8BeZasvSxlIUOWfWXnG47Cl5gRZHgsFG0D(gPoqkeTZMaK8jii3teMYyBc4)jii3teMYyFvtas(eeK7HwAY7jJDiqHORwoTkwhW8df97DhE6GgqmKfzP2bZpGnAJTXzasI9vDHtsv0bedzrwQIWugZaK8jii3JcNkJUoSwg7qGcrxIIZUaeZYF15saa]] )


    ns.initializeClassModule = MonkInit

end
