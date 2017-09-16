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


    storeDefault( [[Brewmaster: Default]], 'actionLists', 20170723.103044, [[dWtrgaGEisAtKq7IuTnj0(iPYSHA(qKAzuOFd6BsQomv7Ku2RQDl1(fYpHegMKmosQ68qsdfIGbludNahurDkiI6yu0PbwibTuiyXkSCIEievpf1JfSojWeHenvs0KvY0fDrk4ZqQlJCDjQNtPBRuBMKY2jbpts51sKPbrX8KGYiHiY3jjJwcY4HiXjHq)LqxtcQUNI0IuehcIsJcIqFZR8SH2hyADHNrjPMxgNx4zwafaogGu9ea7RzSO6pJaHj3sxZyLz9kKPYOUzTk1BEMdsGG8855qcGT9kVM5vE2q7dmTUWZCqceKNtiA0ysh0jjLLfK2ZZdagKOE2kGCPyH8EjAtjOeDgXEbcEcLNBytNrGWKBPRzSYSOzD9QAN18nDMfqUmkgj59kkMtjOe98AgVYZgAFGP1fEMdsGG8CcrJgt6bieVGQABuSIrXiXO4rz1utFGHWfUSn1llikgPr6O40LOPupbBsmHIlavytlwffJKpplrBp3(MMcXlrvU888aGbjQNfataSpJyVabpHYZnSPZiqyYT01mwzw0SUEvTZA(MoJeGja2pVwTR8SH2hyA9XzoibcYZP3LanAfdqiEbv16ajSTLaT4qsQ0dfYLOj70aeIxqvToqcBBjqloKKk9qHCjAYkUDKIIGoa3GgT4Y3oAsSMvDvNNhamir9mqcBBjqloKKQZi2lqWtO8CdB6mceMClDnJvMfnRRxv7SMVPZikHTTeOJIfkjvpVgYCLNn0(atRpoZbjqqEUSLexKAuBbkq2ZZs02ZTVPPtekjvB3MKSGOyusQrTfOazNCEEaWGe1ZbhJf9qcGTigyZZi2lqWtO8CdB6mceMClDnJvMfnRRxv7SMVPZOKuJAlqbY(8Af(vE2q7dmTUWZCqceKNr20XuN6dShkblNIb4Ea1P2hyAPOhsGcKi10gqw1zEEwI2EU9nnDIqjPA72KKfefZP3lxUIINrHHjNNhamir9CWXyrpKaylIb28mI9ce8ekp3WMoJaHj3sxZyLzrZ66v1oR5B6mNEVC5kkEgfgEETIx5zdTpW06cpZbjqqEoDm1P(a7HsWYPyaUhqDQ9bMwk6HeOajsnTbKvDMNNLOTNBFttNiusQ2UnjzbrXihUhWO4zuyyY55badsuphCmw0dja2IyGnpJyVabpHYZnSPZiqyYT01mwzw0SUEvTZA(MoJC4EaJINrHHNxR(vE2q7dmTUWZCqceKNr20XuN6dShkblNIb4Ea1P2hyAPOhsGcKi10gq2PMNNLOTNBFttNiusQ2UnjzbrXC69YLROyw5KZZdagKOEo4ySOhsaSfXaBEgXEbcEcLNBytNrGWKBPRzSYSOzD9QAN18nDMtVxUCffZkFEn1FLNn0(atRl8mhKab550XuN6dShkblNIb4Ea1P2hyAPOhsGcKi10gq2PMNNLOTNBFttNiusQ2UnjzbrXihUhWOyw5KZiqyYT01mwzw0SUEvTZi2lqWtO8CdB6SMVPZihUhWOyw555badsuphCmw0dja2IyGnF(8SMVPZcLKQTBtswqumkj18Y485p]] )

    storeDefault( [[Brewmaster: Defensives]], 'actionLists', 20170723.103044, [[dOtweaGEbO2KqvTlL8Asf7ta1SP0ZrYTvkhwXoLI9cTBv2pfgLsvnmvX4eiwMqzOcGgmfnCv1bjeNsPkhtkDEcwiOAPeQfJOLl5HcapLQht06ivktuG0ujvnzqMojxuvQtl6YOUUqwLa1ZafBwqBNuP63atta5Zi8DPAKcq(lsnAsz8kvojO0TeQY1ivs3tOYpjvITri9nvjJTOE0FFdPLHq4O3mBm6WlUVnukU0ndZGYH8rL6otHUlR8Rqh9GYHtKvHWrxmB5HIXMypTVEc0tSvlmpbPfDX8ajOp3y033Wucawiq)w)OkdfYJGMS4(sQnfbtrVn7mmJNHPeaSqG(T(rvgkKhbnzX9LuBkcMIoSgPkb3ynm3ZWmydtjayHa9B9JQmuipcAYI7RILAtrWOlIuLGJc1JnTOE0FFdPLHq4O3mBm6WTJuhdtDzNHj8I7OlMT8qXytSNwrBFTEGbDypOuokqH(bogDxw5xHUeaSqG(T(rvgkKhbnzX9LuBkcMkUh0fHmTPsaDs7i1HgSJMS4oQWMyOE0FFdPLHq4OlMT8qXytSNwrBFTEGbDxw5xHo6Dn(eZdKa6tKcGUiKPnvcO)JQmuipcAYI7Od7bLYrbk0pWXOhaZxLGdD0BMng9amQYqH8immHxChvydmOE0FFdPLHq4O7Yk)k0LaGfc0V1pQYqH8iOjlUVKAtrWuXjbaleOFRFuLHc5rqtwCFj1MIGPO3MDOlczAtLa6zbokDYJMS4o6WEqPCuGc9dCm6USYVsVWNrxLBm6nZgJoSf4O0jpdt4f3rxmB5HIXMypTI2(A9ad6I5bsqFUXOVVHPeaSqG(T(rvgkKhbnzX9LuBkcMIEB2zygpdtjayHa9B9JQmuipcAYI7lP2uemfDynsvcUXAyUNHzWgMsaWcb636hvzOqEe0Kf3xfl1MIGrVRXNyEGeqNsw5xHkSjqOE0FFdPLHq4O3mBm6V39zRHzan1g6Izlpum2e7Pv02xRhyqxeY0Mkb05DF2sRn1g6WEqPCuGc9dCm6USYVcDnES5rqt914Ixsq0PcCCTXFFnESkTfehMYuf44OuJAnk1i1H(d6Cf8RLUgSgp28iOP(ACXlji6u7HExJpX8ajG(ePaOcvO7FwMJnd4rLGdBIjAqqfIa]] )

    storeDefault( [[Brewmaster: Combo ST]], 'actionLists', 20170723.103044, [[dOZTdaGAcPA9Oi6Lek2LaBJiTpuuz2K62q1JLyNGAVu7gv7hOgfHqdJGFl0HfnucjgmigUcDqb1Pie5yO0QqrYcvulfkTyiwojpKqupv1YqH1riLjsiPPkjtgW0L6IcYRvKNrexhK2iHGtR0MLu9nIQVtO0xrrXNHI5HIuphs)vbJMOSjuu1jLuMgkcxJqvNhiRefLUmY4iuzZ6k)q8ertaE2hoXj)zfjw8eTjLObgIihXrIGH8k)psLn1ltM9g5gMHuX5lQu9eQU9SpwstjkzygcSYfycbgbSseehRpwkbavT4KVF4sVroQRmmRR8dXtenb4zF4eN8N1zzkcTbd5TANiWqerXCrY)f1o2(DQjEhGOZYueApuI4iXaINiAcG5ZsVrEWeHzafprLfOOea0qV4etJPaWuSbI3Vghylzhv(8iN8XsAkrjdZqGvkR8abj(yPeau1It((Hrw92G8r0zzkcThqB1or(VO2XUc0i5JU4f3gMHR8dXtenb4zF4eN8fdHbmKJNOY8XsAkrjdZqGvkR8abj(14aBj7OYNh5KFyKvVni)jcZakEIkZ)f1o2(UnSex5hINiAcWZ(Wjo5pRZYueAdgYB1or(yjnLOKHziWkLvEGGe)ACGTKDu5ZJCYpmYQ3gKpIoltrO9aAR2jY)f1o2(Unmt4k)q8ertaE2)f1o2((yjnLOKHziWkLvEGGe)ACGTKDu5ZJCYhoXjFSqrLTCmGHWSjabgcZSCa)WiREBq(kOOYwoMbrpbObXUCa3gw8UYpepr0eGN9FrTJTpaHaTE9GjcZakEIkla6OpwstjkzygcSszLhiiXVghylzhv(8iN8HtCYFwrzldmKyDWqeHvr(Hrw92G8ruu2YgI1hQVkYTHL6k)q8ertaE2hoXj)QfdPadrusnUpwstjkzygcSszLhiiXVghylzhv(8iN8dJS6Tb53lgsnmMAC)xu7y7tCsHbuqbQsr8M5eC72)f1o2(UTb]] )

    storeDefault( [[Brewmaster: Combo AOE]], 'actionLists', 20170723.103044, [[dCdQdaGAIGwVaQxka2LIABeY(iuy2KCBIANISxQDd1(bYpjuYWq0Vf1qjuLbRqdxOoibDmKSocfTqHSueAXqA5K6Her9uvpgKNdXejuvtfunzatxPlcuhwQlJ66GYgjc8AbzZcQPjaDAjFLqP(Sc(orKNrGXreA0iLXlGCsb6BivxJqLoprALeQyzkYFrWMYW9bJBufd4i)ulZ(rAwsYnYYAXe0OKZYOzqJcflW(hsxXRVprwXnc70ejfDYasontjGuIu(pMHQwvbU3kJDAsKe9fcTvgJy4orz4(GXnQIbCKFQLzFWbkwLbk8aOXaWd(ezf3iSttKuIOOptkWpigOG6nR9Xzm7leTu1k1NduSkdu4bcH4b)dPR413RttgUpyCJQyah5NAz2pa8aOXl3i08jYkUryNMiPerrFMuGFqmqb1Bw7JZy2xiAPQvQFiEGaICJqZ)q6kE996Kad3hmUrvmGJ8tTm7lzAfOXiyAK1NiR4gHDAIKsef9zsb(bXafuVzTpoJzFHOLQwP(q0kcOW0iR)H0v8671PaA4(GXnQIbCKFQLz)in3lnqJ5WGgLGsZ(ezf3iSttKuIOOptkWpigOG6nR9Xzm7leTu1k1hvZ9sJqomHWLM9pKUIxFagfw4WZH4bciYncTzyXEDsCnCFW4gvXaoY)q6kE99jYkUryNMiPerrFMuGFqmqb1Bw7JZy2p1YSpryi0k8aOrXPbyqJIDHb8fIwQAL6RHHqRWdeKWgGjiPcd41jrgUpyCJQyah5FiDfV(mM1dsNHGP1mEfdsFISIBe2Pjskru0Njf4heduq9M1(4mM9tTm7dVgynOrXRvY(crlvTs93AG1eIBLSxNOB4(GXnQIbCK)H0v867tKvCJWonrsjII(mPa)GyGcQ3S2hNXSFQLz)ivdfkdBbn(vxHyFHOLQwP(OQgkug2saz1vi2RxFXNd3WuRJ8Ad]] )

    storeDefault( [[Brewmaster: Standard ST]], 'actionLists', 20170723.103044, [[d0Z8eaGAfbTEKs5LkISlHABeP9PsuZMK5RsW6eryCifDBHCyj7uf7LA3qTFimkrenms53I6VI0qveAWq0Wf4GKQoLiQ6yi5CkcSqf1sjklgrlNWdve1tbpwPEoKMOiknvvQjRW0v1fjvoTuxg11vsBueP(gs1MjQ2osHVRs6RQe6ZcAEIOyzi4zeXOvIXJuYjfHPPsKRHuQopcTsrKSjru51ksBkFBqhUiv8WZgoveBywWxJk0NfjbcKWx4rjgiqc3gGaE3LQPT67m2hcsPPbzSIlu2hcAu01UKgHykjA0KYaSfDWBWG(93zmQV9HY3g0Hlsfp8SHtfXgMehIajevOlgKXkUqzFiOrjLIESMedjWJExFwyaNXSbyl6G3Gb9KTQFIgMYHPOrf6IFFi4Bd6WfPIhE2aSfDWByWKRYLhpLdtrJk0L41GlCHbtUkxEmAaV7sLoyvtdwqmEnWGmwXfk7dbnkPu0J1KyibE076Zcd4mMnONSv9t0aPGRFjnlpvElydNkInml46xqGmlhbYKUfSFFK4Bd6WfPIhE2aSfDWBWGmwXfk7dbnkPu0J1KyibE076Zcd4mMnONSv9t0aPQ2tZRFk6l6PSHtfXgMv1EAE9rGeErpL97ZL8TbD4IuXdpBa2Io4nSZz1iFfhhSkA5eBCykPGVgVxkriJMm7CwnYxXXbRIwoXghMsk4RX7LseYOPrfTmONSv9t0W3HSinOurgsGh9U(SWaoJzdNkInC3HSabYjwQidYyfxOSpe0OKsrpwtIFFODFBqhUiv8WZgGTOdEdFHN24WKd9RWqwexr5v8F5GvrlNy6Viy0LSAyqpzR6NObMwbQ8OXHPt5qdjWJExFwyaNXSHtfXg0rRavE04qeiNehAqgR4cL9HGgLuk6XAs87JuFBqhUiv8WZgGTOdEdgKXkUqzFiOrjLIESMedjWJExFwyaNXSb9KTQFIgeROlnomDcRbNETXddNkIniBfDPXHiqMu1GrG8InE43h6(2GoCrQ4HNnaBrh8gmONSv9t0WEPtjxfOVHe4rVRplmGZy2WPIydtEPrGCEvG(gKXkUqzFiOrjLIESMe)(qtFBqhUiv8WZgGTOdEdgKXkUqzFiOrjLIESMedjWJExFwyaNXSb9KTQFIg2lD61IgSHtfXgM8sJa5flAW(9zc8TbD4IuXdpBa2Io4nyqgR4cL9HGgLuk6XAsmKap6D9zHbCgZg0t2Q(jA47qwKguQidNkInC3HSabYjwQieitsQK3VFdjllVwvVN9Bd]] )

    storeDefault( [[Brewmaster: Standard AOE]], 'actionLists', 20170723.103044, [[dOtieaGAssA9iP0ljPyxQuBJaZMO5tsQVrqpgKDkQ9sTBe7xL8tsIAye63aDyjdLKidwfnCs1brkNIKehdsRJKqluOwkjSyOA5cEijvEQYYa45qzIQqAQiXKfz6Q6Iq4Va6YOUoOAJiP40sTzsPTJKyCQq9vsknnvi(ossFgIETky0GY4jPQtskEgs11ij48KOvIKk3wiJcjvTrnfpeKcxYjh7nOqR)EEhL1wWLVJ9uWsUWyNbiIku8iIaUrPlEmQ30zOUKn1wFdsCgGGJ9Ob9nibZuCg1u8qqkCjNCS3GcT(75rdVL9R0JvVUem1eKapWi90qsnu9GbpciH9Yve7Hq96sWutqEDQggPNcwYfg7marubOcVfP73zaMIhcsHl5KJ9guO1FppfSKlm2zaIOcqfEls3tdj1q1dg8iGe2JgEl7xP3bgjqSOcdMxUIyp1WiVoxuHbZVZ0nfpeKcxYjh7nOqR)EjghUwT3hyKaXIkmy3W1vTQtmoCTAVX0zOUKatSSPchuEdx3tbl5cJDgGiQauH3I090qsnu9GbpciH9Yve7fh46HDDcQ96KA6a7rdVL9R0dpW1ddiOwGA7a735JykEiifUKto2BqHw)98uWsUWyNbiIkav4TiDpnKudvpyWJasyVCfXEXYc6ai8)6CFOpWE0WBz)k9WLf0bq4pqSp0hy)oRcMIhcsHl5KJ9guO1FppfSKlm2zaIOcqfEls3tdj1q1dg8iGe2lxrSNc4yWAcYRtQRs81PABsYJgEl7xPxaogSMGeOQwjgivBsYVZcmfpeKcxYjh7nOqR)EE0WBz)k9GG1aXHhWEpnKudvpyWJasypfSKlm2zaIOcqfEls3lxrSN6G1xNXWdyVFNfAkEiifUKto2BqHw)98uWsUWyNbiIkav4TiDpnKudvpyWJasyVCfXEQdwFDQ2IkShn8w2VspiynqQwuH978XMIhcsHl5KJ9guO1FppfSKlm2zaIOcqfEls3tdj1q1dg8iGe2lxrShLgjhUovPsgDDs9OQIhn8w2VsVVrYbG6LmYVFVCfXEXbMQrf2Zbv86CFrsviDDstLr43g]] )

    storeDefault( [[IV Brewmaster: ST]], 'actionLists', 20170905.122749, [[dytfdaGAqH1lPsVusf7cuABGuTpqcZwOBlIDc0Ej7gL9lOHrj)wIHkjYGfPHdQoivLJrHNtLfcOLkWIPOLJyCGK8uvldG1bsPjcsXurvtgPMUuxus5XI6zufDDk1gbj1wLuvBgvCEQQoTsFvsvMgvHVlj8nuPxljnAK4WkojvPpJKUgOO7bs0kLe1LH(liwgIxhCsqDV1pmfibRizCnsG2W0ZRF4yEN4w3P3ctGaGouPhGrCCOabyzW1IlapH1WYtlp8q)zYcV119L7TWCIxGgIxVgBmJiTaQ)mzH366Ez0BE6crNvyOUpZnUTF9QiviUKXrrpaDfBsgDIxTEagXXHceGLbxdlDWjb1Rdsnm9jJJIAbcq861yJzePfq9Njl8wx3lJEZtxi6Scd19zUXT9RBgNC1IDdX1KTkQhGUInjJoXRwpaJ44qbcWYGRHLo4KG6aJtUAXUdtFt2QOAb6P41RXgZislG6ptw4TUUxg9MNUq0zfgQ7ZCJB7x3KGttbsHdeolb1dqxXMKrN4vRhGrCCOabyzW1WshCsqDGeCAkHPfoHPq9sq1c0dXRxJnMrKwa1FMSWBDtBoCGLy7OSmQqGXqJqQyz0Wsqoe0rzmJOUxg9MNUq0zfgQ7ZCJB7xNy7OSmQqGXqJqQyz06bORytYOt8Q1dWioouGaSm4AyPdojOEGTJYYOgMw5HgdtR3YOvlqykE9ASXmI0cO(ZKfERJmKq1pSzBcbzDykuaLHPqhM6Ez0BE6crNvyOUpZnUTF9EPIeiWNyIEa6k2Km6eVA9amIJdfialdUgw6GtcQZVursyALMyIA16qdYzSJTaQwca]] )

    storeDefault( [[IV Brewmaster: AOE]], 'actionLists', 20170905.122749, [[dOt6daGAkkA9ue6LuuAxQuzBsLAFucnBrUTu6Wa7uf7LSBu2pv6NuK0Wqv)wOhlQHsrQgSGgUu1bPKEovDmeDEbAHQKLsPwmvSCKEOuHEQYYaX6uPktKIitLctgHPl5IOItRQldDDPyJueSvkIAZQu2ofP8nq1xPiX0Kk57uu5ZG0ZKkA0OsJxQGtkGxtj6Auu19OOWkPe8xqzCQuvlszODaTOwat2n8IIMRf4lKEp3qRMkhT1J5hKEteuFKPdKUVVMnMqGh1bcpjCE4q68os(o57QlTLPFFPPznxFK5LHoKYqJdd4KqcDPTm97lnTamIpdQivJfzOMvNp9vqnSd9PiXZGcZseQMn6Jn0m6LHknBmHapQdeEs4K8AhqlQXPd9PiXZG6gAweQkDGidnomGtcj0L2Y0VV00cWi(mOIunwKHAwD(0xb1SeHcZ3c8C1SrFSHMrVmuPzJje4rDGWtcNKx7aArnZIqDdxlWZvLoDkdnomGtcj0L2Y0VV00cWi(mOIunwKHAwD(0xb1YCFyonuFPzJ(ydnJEzOsZgtiWJ6aHNeojV2b0IADK77gE1q9LkD6sgACyaNesOlTLPFFPbY1BAimIyDNdfbfxyXBWU9u0n0IUHKAbyeFgurQglYqnRoF6RGAoueuCHfVb72trnB0hBOz0ldvA2ycbEuhi8KWj51oGwu7IIGIRBy8MBOj8uuLoMxgACyaNesOlTLPFFPPfGr8zqfPASid1S68PVcQrB8CFguyMjGaHzUNrOzJ(ydnJEzOsZgtiWJ6aHNeojV2b0IA2nEUpdQBOfaeOBOP8mcv60Tm04WaojKqxAlt)(sdzifAW7YnukYk3qlAgUHDBExlOfGr8zqfPASid1S68PVcQvpuKcRhKA1SrFSHMrVmuPzJje4rDGWtcNKx7aArnJhksDdnDqQvLoWLHghgWjHe6sBz63xAA2ycbEuhi8KWj51cWi(mOIunwKHA2Op2qZOxgQ0oGwu7kbYwgBk3Wv03suLkntcVbAsLUujb]] )

    storeDefault( [[IV Brewmaster: Combo]], 'actionLists', 20170905.122749, [[dWtRfaGALc16vIKxcQIDrrBtPi7tKmBHMVsrDyvUnu9Ci7uG9kTBu2prhcuvnmc(nWYOqdvjknysgouCqLsNwXXeX3uclKcwkOSys1Yr1dbvPNs1JP06uIktuPatvjnzqMUQUOsvJtjIEgPixxu2OsbTvLOyZIuTDrkFNu6RkrQPrkQ5PuiFwu9xcnAO04bvLtQu5YixtjQ68GkRujcBIu41c6M016bhovF3Yivg4Kw8d9eF5Kk4fGRdQ7yi7CXzPUFaSgyCtlzDyuKoe1aJcjlewyutMjcAsqZAUUB5dMVE9T2FamuxBqsxRVND6rcQgQ7w(G5Rd)sfgoLMyUfYmXupE2qq2lIE(ess1M3SuzbGieqlZetgFshUHLlQZjTMwShpNqs1gjvgRVJbn27b86maJQVvFIZdx9qkxeHFiS1Hriqg3sOU2VomkshIAGrHKfjc1doCQo8q5sLJFiS9BGXUwFp70Jeunu3T8bZxV(og0yVhWRZamQ(w9jopC11JNneK9IONpHuDyecKXTeQR9RdJI0HOgyuizrIq9GdNQBiE2qq2lv(ZNqQFd0uxRVND6rcQgQ7w(G5RJHtPjMBHmtm1JNneK9IONpHu9DmOXEpGxNbyu9T6tCE4Q)toXfXCr86WieiJBjux7xhgfPdrnWOqYIeH6bhovFDYjUuTSxeVFd0CxRVND6rcQgQ7w(G5RF2FsJejgHpesQsjvjsLgsLfaIqaTmt94zdbzVi65tizYj8ByiPkLujivAivwaicb0YmdPCre(HWAYj8ByiPkLujuFhdAS3d41zagvFR(eNhU6e8HjcGgwUyiLxhgHazClH6A)6WOiDiQbgfswKiup4WP67Hpmra0WYLk4HY73GLVR13Zo9ibvd1DlFW81p7pPrIeJWhcjvPKQePsdPYcariGwMPE8SHGSxe98jKm5e(nmKuLsQeKknKklaeHaAzMHuUic)qyn5e(nmKuLsQeQVJbn27b86maJQVvFIZdxDl2rupJJ(6WieiJBjux7xhgfPdrnWOqYIeH6bhovhEXosLHmo673Gn1167zNEKGQH6ULpy(6N9N0iriWBgs5Ii8dHvQsjvcsLgsLfaIqaTmt94zdbzVi65tizYj8ByiPkLujivAivwaicb0YmdPCre(HWAYj8ByiPkLujuFhdAS3d41zagvFR(eNhU66C6ESIG0ftF4uDyecKXTeQR9RdJI0HOgyuizrIq9GdNQBGt3JvQaPlvB4WP(nyrxRVND6rcQgQ7w(G5RBbGieqlZupE2qq2lIE(esMCc)ggsQsjvcsLgsLfaIqaTmZqkxeHFiSMCc)ggsQsjvc13XGg79aEDgGr13QpX5HRopdHDy5IB8brIAhguDyecKXTeQR9RdJI0HOgyuizrIq9GdNQdldHDy5s1sCqKuT0ddQF)6BaL(Lf)AOFla]] )

    storeDefault( [[IV Brewmaster: Defensives]], 'actionLists', 20170905.122749, [[dOtHeaGEQQOnrvv2fqBJQc2hGy2cwgPQBlv9Bq7uQSxKDRQ9tXOeQAykX4OQKoSkdLQsmyknCO6GKIofG0Xa48uPfsQSuiAXe1YLCAfpv0Jj8CPmrQQQPcHjtKPtYfjLSkHkxg11PIVPKSvQQWMfY2PQqptjL1rvPAAkP67k1iPQiFgsJMQmEHYjbu3IQkDnQkL7rk8xO8AsP(jvf1eacbL(NJoNGI0rzIZI5cJFEQb(uNEFWxPS76zkb2pmwDfV7VMIlF3y9phXFB8rUrjsoWxJPo9lawTSs)AGawwBz91PejFsUiMEMY4nwbegKG7he3PMi35rXKlEdk8UcLBy9xmJ1VgRacdsW9dI7utK78OyYfVbfExHYnSO6eQb(xWybQXgNXkGWGeC)G4o1e5opkMCXBWIfExHYuQPqnWVriOoaeck16p5alr6Omf1GROuaHbj4(bXDQjYDEum5I3GcVRq5MXQHXUyS(ZyBQdfLlqCUe8RW6VyyE4glq0Wy1VqjWV0iofSO8HptPMYtyuUukhoH2yWyyYfVPej3GoLGBecsrjsoWxJPo9lawbyHYURNPux4eABS(CmJvxXBsrD6jeuQ1FYbwI0rzkQbxrjLa)sJ4uWIYh(mLAkpHr5sjUtnrUZJIjx8MsKCd6ucUriifLi5aFnM60VayfGfk7UEMsFXPMi35rnwDfVjf1TgHGsT(toWsKoktrn4kkfqyqcUFqCNAICNhftU4nOW7kuUzSAyScimib3piUtnrUZJIjx8gu4Dfk3W6VyuU94hjFsUu2e1GROe4xAeNcwu(WNPS76zkbUGFt75nwDfVPejh4RXuN(faRaSqjsUbDkb3ieKIsK8j5Iy6zkJ3yfqyqcUFqCNAICNhftU4nOW7kuUH1FXmw)AScimib3piUtnrUZJIjx8gu4Dfk3WIQtOg4FbJfOgBCgRacdsW9dI7utK78OyYfVblw4DfktPMYtyuUuof8BAppMCXBsrDRtiOuR)KdSePJYuudUIsp(cZJI1W94IbfqNxzSardJfG)m24nwp(ckpqjoAeJYybIggBtDkWtPoH2y4WnxgBCg7kqFZyJZy94lmpkwd3JlguaDELXcukb(LgXPGfLp8zk1uEcJYLsogohW8UQNsKCd6ucUriifLi5aFnM60VayfGfk7UEMsTIHZbJ1NUQNuKIYuudUIssrea]] )

    storeDefault( [[IV Brewmaster: Default]], 'actionLists', 20170905.122749, [[d0tTfaGEkiAtuuTlr12aj7Jcs)MWSj6XsCtvQ6quiDBjDEqQDIu7vz3a7xk)KcQHPsgNkvQtJyOuqyWQy4iXbbXPuPIoMi9nkvluvSuPklgulNKhQkXtrTmkP1jv1eLkmvK0Kvvtx4IIsxvQO6YqxNsCyQ2QQK2mfLTtbEMuPPrH4ZukFxumsPI0Zj1OvPcVwLYjPilsvQRjvuUhfQvkveJsLk5VI4LoQJzkyH4sIH0dIamARqD3JP9ko20RTZJcZuDDGQ(TthOzUfzmUhkrxJJ26vQ9l7w7MNE19YigzmxuekX4Xqkbra0J6Oth1XzboSe)7zmxuekX4qyZMeZjGavkluc9yiWejjGESMc6QK7Wb)eDOi3WXMaFsXdHAmqaWX0EfhZuqx1oDQd(TdhkYnCCpuIUghT1RuOsTNF1DXOToQJZcCyj(3ZyUOiuIXHWMnjMtreebq36KXqu20JbEfnwi)jzC1yiWejjGEmfrqeGXMaFsXdHAmqaWX0EfhBiebrag3dLORXrB9kfQu75xDxm6UJ64SahwI)9mMlkcLyC4GBeGT2X82XIgt(Oziqtma1TJ5TJrBN7QDcxIGihw6LBclrsruHf5iWHL4VDmVDOOqdsSv(5P5WsVCtyjs0HICdBN7CmTxXXDGMHanXaupgIYMEmWROXVFuyMQRdu1VD6andbAIbO(9yiWejjGECXLYeVeebirs0XytGpP4Hqngia44EOeDnoARxPqLAp)Q747fFAVIJFuyMQRdu1VD6andbAIbOEXOnYOoolWHL4FpJ5IIqjgp2e4tkEiuJbcaogcmrscOhBrJjKaR6X9qTWIQG6rDX4EOeDnoARxP2tVgt7vCCNRX2XuGv9Ir3zJ64SahwI)9mUhkrxJJ26vkuP2ZV6oMlkcLyC4see5WsVCtyjskIkSihboSe)JHOSPhd8kA87hfMP66av9BNxevyr7aXWzFpgcmrscOhxCPmXlbrasKeDm2e4tkEiuJbcaoM2R44xevyX47fFAVIJn9A78OWmvxhOQF78IOclwmAOg1XzboSe)7zCpuIUghT1RuOsTNF1DmxuekXyJgUebroS0l3ewIKIOclYrGdlXF7yE74LGyaMGaSsqTXPJHOSPhd8kA87hfMP66av9BhoCW3v)2HP(EmeyIKeqpU4szIxcIaKij6ySjWNu8qOgdeaCmTxXXC4GVR(TdtD89IpTxXXMETDEuyMQRdu1VDyQlgT9rDCwGdlX)Egt7vCmho47QF7aXWzhZffHsm2OHlrqKdl9YnHLiPiQWICe4Ws83oM3oEjigGjiaReu3ogA7KogIYMEmWROXVFuyMQRdu1VDEruHfTdt994EOeDnoARxPqLAp)Q7ytGpP4Hqngia4yiWejjGECXLYeVeebirs0X47fFAVIJn9A78OWmvxhOQF7aXWzxSyChOzUfzSNfBa]] )
    
    storeDefault( [[SimC Windwalker: default]], 'actionLists', 20170905.135901, [[diK8oaqiaklsrPnrv1OiPCkuQMfkLQ2fkggj5yqLLPO6zaunnuk5AKu12iPIVPOyCufQZjvjRtQI5rr6EsvTpQcoiawia5HuutKQqCrukgjkLkNeOYlrPumtPk1nPq7KknuukLwkq5PctLQ0wbQ6RufTxI)sIbl5WQSyf5XkmzPCzKndOptfgnu1Pv1RrjZMu3gk7g0VHmCGCCsQ0Yr1ZP00v66sLTtr8Dk48urRNQqA(uv2VOfCIxjcq04p97rV9rqXDU60ljCpmsI4XmNLNpSz40SiEpz1iGxNELamstNLe35QWnJQEPs9m4a854ylpwIyWFqResaWyFe0kEfxCIxjyd8M0utaKeXG)GwjwKdhAI5HlX5DGwBw(ZsTS2J7GwMgn1beiZ4S7dDW0bkl2LaGPx)RtjSGOJRG)Gnf7YFwKeGd2(XTiUeqeKKWiQb(J7EyKes4EyKebi64zX2DWwwXYFwKeGrA6SK4oxfUzWPscWilQJpiR4vwjmJNgSmImHWi4ktsye1Cpmsczf35Ixjyd8M0utaKeXG)GwjWtNEXZaASzzAwQyuVeam96FDkXI6g4vqavyDCStcWbB)4wexcicssye1a)XDpmscjCpmscVOUb(SqaZIT54yNeaWDyL4HlXn5097Lk2EqJvbpD6fFFvmQxcWinDwsCNRc3m4ujbyKf1XhKv8kReMXtdwgrMqyeCLjjmIAUhgjHSIlGlELGnWBstnbqsed(dALyroCOjgqO9rqBw(ZsTSM6acKXsCc(RtMoqz5ZxwtDabYyxehtHo(Ix5GnfGpNy6aLLpFzPwwaww7Pj4Yyjob)1jdbVjn1YYFwl)HSOLbehnyohV(xNmDGYI9S85lRPoGazM0iut3zxMoqz5Zxw7XDqlZ(yKYIuApLLP9ZsDuLf7saW0R)1PeGq7JGsaoy7h3I4sarqscJOg4pU7HrsiH7HrsW2I2hbLamstNLe35QWndovsagzrD8bzfVYkHz80GLrKjegbxzscJOM7HrsiR4YwIxjyd8M0utaKeXG)GwjwKdhAIzGq6gYa0ML)SulR94oOLzFmszrkTNYY0(z1RSyxcaME9VoLyrDd8kiGkn6w8saoy7h3I4sarqscJOg4pU7HrsiH7Hrs4f1nWNfcywEe6w8sagPPZsI7Cv4MbNkjaJSOo(GSIxzLWmEAWYiYecJGRmjHruZ9WijKvCvV4vc2aVjn1eajrm4pOvc1YsTS2ttWLXsCc(RtgcEtAQLL)SgiKUHmazSeNG)6KHty3dTzzA)SuLf7z5ZxwtDabYyjob)1jthOSypl)zn1beiZKgHA6o7Y0bkl)zDJ9nHuiiH9KnltZAEw(ZYsRYec2zz2N4ZvPWwGgz5HSuLL)SS0QmHGDwM9joUEPmh0ilpKLQS8NfPUDpiquJPXFiRh6qbpIdvgitiEw(ZsTSi1T7bbIAmSU12HSk0q)GSuw(8Lf)geZKgHAkKgyw(8L1EAcUmGqgiUID5plYYqWBstTSyxcaME9VoLyCATYn2hbv0VDLaCW2pUfXLaIGKegrnWFC3dJKqc3dJKW8P1zbWyFemRE)2vca4oSsapmQ)SXJzolpFyZWPzr8EYYsCc(RZSqGiiXNvcWinDwsCNRc3m4ujbyKf1XhKv8kReMXtdwgrMqyeCLjjmIAUhgjr8yMZYZh2mCAweVNSSeNG)6mleicsCzfx1r8kbBG3KMAcGKig8h0kHAzTNMGlJL4e8xNme8M0ull)znqiDdzaYyjob)1jdNWUhAZY0(zPkl2ZYNVSulRPoGazSeNG)6KPduw(ZAFmklpK1CvzXUeam96FDkX40ALBSpcQOF7kb4GTFClIlbebjjmIAG)4UhgjHeUhgjH5tRZcGX(iyw9(TBwQHJDjaG7Wkb8WO(ZgpM5S88HndNMfX7jllXj4VoNvcWinDwsCNRc3m4ujbyKf1XhKv8kReMXtdwgrMqyeCLjjmIAUhgjr8yMZYZh2mCAweVNSSeNG)6uwXDgXReSbEtAQjasIyWFqReaww7Pj4Yyjob)1jdbVjn1YYFwQL1uhqGm2fXXuOJV4voytb4ZjMoqz5Zxwdes3qgGm2fXXuOJV4voytb4ZjMb(J7GSz1pR5zXUeam96FDkX40ALBSpcQOF7kb4GTFClIlbebjjmIAG)4UhgjHeUhgjH5tRZcGX(iyw9(TBwQnNDjaG7Wkb8WO(ZgpM5S88HndNMfX7jllbCwjaJ00zjXDUkCZGtLeGrwuhFqwXRSsygpnyzezcHrWvMKWiQ5EyKeXJzolpFyZWPzr8EYYsaLvC9yXReSbEtAQjasIyWFqReaww7Pj4Yyjob)1jdbVjn1YYFwK629GarnMg)HSEOdf8iouzGmH4z5pl1YAGq6gYaKXU8NfPGaQS4jfdpSPr8gdNWUhAZY0(zHZJZYFwdes3qgGmaF7Avqava2XDYWjS7H2SmTFw4MNL)Sg4FMrhNtWnlp0plapl)znqiDdzaYWF7dDOy7GkS(blgoHDp0MLP9Zcxw(8L1ECh0YSpgPSiL2tzzA)SMR(S85lRbcPBidqMf1nWRGaQ0OBXZWjS7H2S8qw4Wnpl2ZYFwdes3qgGm2fXXuOJV4voytb4ZjMb(J7GSz1plCsaW0R)1PeJtRvUX(iOI(TReGd2(XTiUeqeKKWiQb(J7EyKes4EyKeMpTolag7JGz173UzPgGZUeaWDyLaEyu)zJhZCwE(WMHtZI49KLLaoReGrA6SK4oxfUzWPscWilQJpiR4vwjmJNgSmImHWi4ktsye1CpmsI4XmNLNpSz40SiEpzzjGYkU9s8kbBG3KMAcGKig8h0kbGL1EAcUmwItWFDYqWBstTS8NfGLfPUDpiquJPXFiRh6qbpIdvgitiEw(ZsTSgiKUHmazSl)zrkiGklEsXWdBAeVXWjS7H2SmTFw4yRS8N1aH0nKbidW3UwfeqfGDCNmCc7EOnlt7NL6KL)Sg4FMrhNtWnlp0plapl)znqiDdzaYWF7dDOy7GkS(blgoHDp0MLP9Zcxw(8L1ECh0YSpgPSiL2tzzA)SWP(S85lRbcPBidqMf1nWRGaQ0OBXZWjS7H2S8qw4Wnpl2ZYFwdes3qgGm2fXXuOJV4voytb4ZjMb(J7GSz1plCsaW0R)1PeJtRvUX(iOI(TReGd2(XTiUeqeKKWiQb(J7EyKes4EyKeMpTolag7JGz173UzPgBXUeaWDyLaEyu)zJhZCwE(WMHtZI49KLLaoReGrA6SK4oxfUzWPscWilQJpiR4vwjmJNgSmImHWi4ktsye1CpmsI4XmNLNpSz40SiEpzzjGYkU4ujELGnWBstnbqsaW0R)1PeJtRvUX(iOI(TReGd2(XTiUeqeKKWiQb(J7EyKes4EyKeMpTolag7JGz173UzPM6zxca4oSsapmQ)SXJzolpFyZWPzr8EYk8oReGrA6SK4oxfUzWPscWilQJpiR4vwjmJNgSmImHWi4ktsye1CpmsI4XmNLNpSz40SiEpzfELvwj8ieWRtVcGKvea]] )

    storeDefault( [[SimC Windwalker: precombat]], 'actionLists', 20170905.135901, [[dqtrcaGEQKAxufTnfuZwPUjfDBr2jL2lz3OA)uvnmQ43adLcPbtvz4iLdkGJHsNJQKfsblvHwmkwUOEis8uvltrwhvIMifIPkOjdY0L6IGsVwGUm01rspwOTcQSzQe2os1HL8vQsnnku9DQu9zQcNgXOvuFtbojO4zuPCnkuopOQNRK)QGmoQKSyvO(PHrsTjUUAcGl70WEPBReQFsIIFFEt4qUx7Gy2L(9rlJrqIPA9rCJ1cLDYHDGJxogZtw3MynUR0FmtO166bInbWxkuwwfQdlVy2iKmO)yMqR1BGhESrpPbAcGV0dWq2KgEDAGMa46WWHiXQbzDoGJ6Mai4QSTsOUUTsOUrbnbW1hXnwlu2jh2bSo6J4cqnhXLcvRtzgJbnb0XeYBXOBcGSvc1vl7Kc1HLxmBesg0dWq2KgE94mzigQ5vRddhIeRgK15aoQBcGGRY2kH662kH6uMj(9zGAE16J4gRfk7Kd7awh9rCbOMJ4sHQ1PmJXGMa6yc5Ty0nbq2kH6QL1nfQdlVy2iKmOhGHSjn86XzYqUx0rDy4qKy1GSohWrDtaeCv2wjux3wjuNYmXVpVl6O(iUXAHYo5WoG1rFexaQ5iUuOADkZymOjGoMqElgDtaKTsOUA16gbDrrD3YGAja]] )

    storeDefault( [[SimC Windwalker: sef]], 'actionLists', 20170905.135901, [[deKofaqivqTivu2eLIrHO0PqumlvqULka7cGHHGJrvTmr0ZuHyAQOY1OKyBQa6BejJtfiNtfsRJsQ5rjPUhr0(uHQdsuwic5HQKjIq5IiQ2iLKCskLMPkuUPk1obAOQa1sPepf1ufvBLsLVsPQ9k9xrzWuCyflwKEmvMSQ6YqBwf5ZaA0evNMWRPkMTGBl0Ur63KmCQslh0ZvLPR01rKTte(orQXJq15fH1RIQ2pPU(nVm7fDIjio)ScfTGjpWJwgCIyzweV0g7f0V0tWdcTwBE4PYwWaopSGjj4lfHJsWka8pss)ZDqLzhu4DlxwMBfk6R5f0V5LjNoPb8xIkZoOW7w(WAdz1MusNobqUyZCQyQcajVAJnAJxikrgq3hGpGvaeHzENquBiJ2yJ2GuecmbahjiePR2iP2GuecmbG4qCTXgTXjxaWrccr6QnwT24xwwQii2eLxbqeM5DcXYxYrNNBLeyePBtlFR(2nqWjILlBl9lCZQGLPkkwgCIy5CbqeQnh8eILLbb(k7s4cy2oqG4(K0VSfmGZdlysc(s5tOSf8PibD4R5DlFLWfW8bce3xjQ8T6dorSC3cMS5LjNoPb8xIkZoOW7w2jxaioexBoaTXjxaWrccr6QnhxsTXxBSrBqkcbMaWkIy2QYIdX1MJlP2qaGvkllveeBIYd0numBvqis3Y2s)c3SkyzQIILVvF7gi4eXYLbNiwwg0nuuBYvqis3YwWaopSGjj4lLpHYwWNIe0HVM3T8LC055wjbgr620Y3Qp4eXYDl4rAEzYPtAa)LOYYsfbXMOSBcHSXTcfnliEBzBPFHBwfSmvrXY3QVDdeCIy5YGtelFnHG2iZTcfvBoM4TLLbb(ktNik5zSiEPn2lOFPNGheAT2CrSZkBbd48WcMKGVu(ekBbFksqh(AE3YxYrNNBLeyePBtlFR(GtelZI4L2yVG(LEcEqO1AZfX6wWZ18YKtN0a(lrLzhu4DlVkGadiaNsf(kPPpTXgTHSAZH1MusNob4Tkymdh4kpBO)StcicGKxTHmLLLkcInr53QGXmCGR8SH(ZojGyzBPFHBwfSmvrXY3QVDdeCIy5YGtelZRcgpK2q(ax5hsBg6xBSkbelBbd48WcMKGVu(ekBbFksqh(AE3YxYrNNBLeyePBtlFR(Gtel3TGwP5LjNoPb8xIkllveeBIYUjeYg3ku0SG4TLTL(fUzvWYufflFR(2nqWjILldorS81ecAJm3kuuT5yI3QnK1NmLLbb(ktNik5zSiEPn2lOFPNGheAT2W5Nv2cgW5HfmjbFP8ju2c(uKGo818ULVKJop3kjWis3Mw(w9bNiwMfXlTXEb9l9e8GqR1goVB3YedpnKcBjQBla]] )

    storeDefault( [[SimC Windwalker: serenity]], 'actionLists', 20170905.135901, [[dq0BpaqiqvTibsSjvuJcu6uGk7sKggj1XOsltf6zssmnqbxtGO2Mar(MGY4eiPZjjK1jjuZduO7jjAFGQCqvWcvrEOOQjkjOlkOAJscCsrfRuGuEPKuMPaH6MQu7KqdvGqwQaEkLPsqBvuPVkjP9Q8xGgmuhgXIPIhtvtwIlJAZQKplkJMKCAPwTKu9ArmBqUnGDRQFtQHlPoUaPA5e9CHMoKRtITliFxGA8ce05jW6fiW8bfTFKEUt4mRM9nbQdciOw)t8yqQIMjsa4zwdKNIRA)LGjqjSSIP4il5VrcMfGHysKN4r1UHPUIuhKtDRYrxyiOoZ8YUgnB2bpQ1FCcNO7eol8N4aXLDAM5LDnAg8PyyPyhLRRuvnc0RbC0Pk1u8zkUwYHaZ8Lu3uuNXsWAceafdhfFMI5NLzcs9ksj)ikUskMFwMjifGeesXNPyVQo1RiL8JOyyKIDP4Zum8PyhLRR0il5VrcsvQNDWPHAKGzOoJLG1eiGz5vX(KBDigGF0CMDRl5sKIeaE2SC(s7jiTC2RFEMibGNjSZyjfherGaMDqMfN5f4HyqerMXOyLUZcWqmjYt8OA3WCvplah1ksphNWHMLxGhIfsKzmkUtZU1frcapBOjECcNf(tCG4Yon7Gtd1ibZ8eiiqIh16heQJOz58L2tqA5Sx)8SBDjxIuKaWZMjsa4z5jqqu8bpQ1pfhe3r0SdYS4SNaWvguSgipfx1(lbtGsyzftX5RWGYSametI8epQ2nmx1ZcWrTI0ZXjCOz5vX(KBDigGF0CMDRlIeaEM1a5P4Q2FjycuclRykoFfo0eRYeol8N4aXLDAM5LDnAgsNLbXPETgQOd(JZo40qnsWSil5VrcMLZxApbPLZE9ZZU1LCjsrcapBMibGNzSK)gjywagIjrEIhv7gMR6zb4Owr654eo0S8QyFYToedWpAoZU1frcapBOjcdt4SWFIdex2PzMx21OzepQdXG8ZanhPyyKIRYSdonuJemt2X(ZaJkpys7tMLxf7tU1Hya(rZz2TUKlrksa4zZY5lTNG0YzV(5zIeaEwGo2FgfBkpfxT2Nm7GmloZlWdXGiImJrXkDNfGHysKN4r1UH5QEwaoQvKEooHdnlVapelKiZyuCNMDRlIeaE2qtmipHZc)joqCzNMDWPHAKGzrKStyq9fisfdgC)fiTSmlNV0EcslN96NNDRl5sKIeaE2mrcapZqYoHPy9ffJuXuCv7VaPLLzbyiMe5jEuTByUQNfGJAfPNJt4qZYRI9j36qma)O5m7wxeja8SHMyqAcNf(tCG4YonZ8YUgndwkg(umSuSJY1vQQgb61ao6uLAk(mfxl5qGz(sQBQdeXNOvqGjTpHIHJIHJIptXWsX1soeyMVK6MgrYoHb1xGivmyW9xG0YcfdtysX1soeyMVK6ME1rueuFbEPifqXWrXNPyIh1Hyq(zGMJummsXhNDWPHAKGzoqeFIwbbM0(Kz5vX(KBDigGF0CMDRl5sKIeaE2SC(s7jiTC2RFEMibGNDcI4t0kikUATpz2bzwCMxGhIbrezgJIv6oladXKipXJQDdZv9SaCuRi9CCchAwEbEiwirMXO4on7wxeja8SHMyyt4SWFIdex2PzMx21OzWsXWsXCqxPRR5sAr2Fs)zGQ0Yh0RdXsk(mf7OCDLwl5yurYG16(rPsgG0FKIHXkP4Ju8zkoYiqh9RetrnlpQgegQ9um8Oy1umCu8zkgwk2R1qfDWFQSJ9NbgvEWK2NKkzas)rkgEuSlfdtysXepQdXG8ZanhPy4rXUumCumCZo40qnsWSRoIIG6lWlfPGz58L2tqA5Sx)8SBDjxIuKaWZMjsa4zvqhrrkwFrXvGIuWSdYS4S(rSuQuJQ0DwagIjrEIhv7gMR6zb4Owr654eo0S8QyFYToedWpAoZU1frcapBOjguNWzH)ehiUStZmVSRrZGLIHLIHpfZbDLUUMlPfz)j9NbQslFqVoelPyyctk2r56k1bsRlqkruQsnfdtysXokxxPrwYFJeKkzas)rkggPyxkgok(mfdlf71AOIo4pv2X(ZaJkpys7tsLmaP)ifdpk2LIHjmPyIh1Hyq(zGMJum8OyxkgokgUzhCAOgjy2vhrrq9f4LIuWSC(s7jiTC2RFE2TUKlrksa4zZeja8SkOJOifRVO4kqrkGIH1fUzhKzXz9JyPuPgvP7SametI8epQ2nmx1ZcWrTI0ZXjCOz5vX(KBDigGF0CMDRlIeaE2qtSIMWzH)ehiUStZmVSRrZiEuhIb5NbAosXWRskUku8zkg(umSuSJY1vQQgb61ao6uLAk(mfxl5qGz(sQBASU)V)mqVK8mys7tOy4MDWPHAKGzX6()(Za9sYZGjTpzwoFP9eKwo71pp7wxYLifja8SzIeaEMv3)3FgfNxsEMIRw7tMfGHysKN4r1UH5QEwaoQvKEooHdnlVk2NCRdXa8JMZSBDrKaWZgAIUQNWzH)ehiUStZmVSRrZGpfdlf7OCDLQQrGEnGJovPMIptX1soeyMVK6MkvIQ6pdS6KcdgC)fkgok(mf7OCDLkvIQ6pdS6KcdgC)L0Io4NIptXokxxPrwYFJeKkzas)rkgEvsXWWSdonuJemtQev1Fgy1jfgm4(lZY5lTNG0YzV(5z36sUePibGNntKaWZcOev1Fgfh0ifMIRA)LzbyiMe5jEuTByUQNfGJAfPNJt4qZYRI9j36qma)O5m7wxeja8SHMOR7eol8N4aXLDAM5LDnAgXJ6qmi)mqZrkgEvsXvz2bNgQrcMj7y)zGrLhmP9jZYRI9j36qma)O5m7wxYLifja8Sz58L2tqA5Sx)8mrcaplqh7pJInLNIRw7tOyyDHB2bzwCMxGhIbrezgJIv6oladXKipXJQDdZv9SaCuRi9CCchAwEbEiwirMXO4on7wxeja8SHMO7XjCw4pXbIl70mZl7A0m4tXWsXokxxPQAeOxd4OtvQP4ZuCTKdbM5lPUPsLOQ(ZaRoPWGb3FHIHJIptXokxxPsLOQ(ZaRoPWGb3FjTOd(P4ZumXJ6qmi)mqZrkgEuS7SdonuJemtQev1Fgy1jfgm4(lZY5lTNG0YzV(5z36sUePibGNntKaWZcOev1Fgfh0ifMIRA)fkgwx4MfGHysKN4r1UH5QEwaoQvKEooHdnlVk2NCRdXa8JMZSBDrKaWZgAIUvzcNf(tCG4YonZ8YUgnd(umSuSJY1vQQgb61ao6uLAk(mfxl5qGz(sQBASU)V)mqVK8mys7tOy4MDWPHAKGzX6()(Za9sYZGjTpzwoFP9eKwo71pp7wxYLifja8SzIeaEMv3)3FgfNxsEMIRw7tOyyDHBwagIjrEIhv7gMR6zb4Owr654eo0S8QyFYToedWpAoZU1frcapBOj6cdt4SWFIdex2PzMx21OzWNIHLIDuUUsv1iqVgWrNQutXNP4AjhcmZxsDtDGi(eTccmP9jumCZo40qnsWmhiIprRGatAFYS8QyFYToedWpAoZU1LCjsrcapBwoFP9eKwo71pptKaWZobr8jAfefxT2NqXW6c3SdYS4mVapedIiYmgfR0DwagIjrEIhv7gMR6zb4Owr654eo0S8c8qSqImJrXDA2TUisa4zdn0SkKVikqODAOna]] )

    storeDefault( [[SimC Windwalker: ST]], 'actionLists', 20170905.135901, [[dueZAaqikPSirrPnPGgfrQtrKClHe2frnmsXXeyzkWZefzAKs01aPY2iLqFtqmokPQoNqsTokPsZJusDpsP2hbCqIOfsGEOO0ejLGlkiTrHKCsHuRuuu8sHentkPIBsq7KunukPklviEkvtLsSvrHVskj7f6VeAWsomIftPEmftwPUmQnlO(SOA0G40QSAqQYRvOzROBRKDRQFtYWbLJdsvTCKEUith46c12bjFNsY4bPCEq16ffvZNiSFPgdqlORtwm6(TY2LwD)2kYCKPw3UClORf4WK4jafe9i8Kjjg1hOjienrTgOtoitdc0sRp6om2CK5L5eWPEuFGwmQrxsd4uFcTG6bOf0d9j2tEJcIUK238aWr3qMtrIbCQxCEja6r)7Zqakk6V6z0fQ2zqO6KfJo66KfJEwYC2LKgWP(USoxcGUK08e6pzXANz9BLTlT6(TvK5itTUDLvlKzrpcpzsIr9bAccjqd6r4KkMA4eAbbONfcBgfQGIx8dqB0fQ26KfJUFRSDPv3VTImhzQ1TRSAbeG6dqlOh6tSN8gfeD3qpya0nqoztmLYpOlTw7Uc6Ayxs3LrPMBLvVm9s3NlMIFXXZmkt5f5(uxA3LMUKqIUKUlcfCHjgGCcqVrwufweaHfT6(9ur3Y8tSN8URHDzuQ5wz1lNa0BKfvHfbqyrRUFpv0TmLxK7tDPDxA6sQUKqIU4NP5WLnXuk)GU06UGonDjf6sAFZdahD(zA(L53NlYZdAhf9O)9ziaff9x9m6cv7miuDYIrhDDYIrp0NP5xMFFExHopODu0JWtMKyuFGMGqc0GEeoPIPgoHwqa6zHWMrHkO4f)a0gDHQTozXOJauptOf0d9j2tEJcIUBOhma6giN8IaTUIIUmqoztmLYpOlb0URGUg2f)mnhUm4wSiqjUiqRlb0UlnYqh6sAFZdahDc1qEweOOu(bOh9VpdbOOO)QNrxOANbHQtwm6ORtwm6ssnKN7YIIs5hGEeEYKeJ6d0eesGg0JWjvm1Wj0ccqple2mkubfV4hG2OluT1jlgDeG6AjAb9qFI9K3OGO7g6bdGU16s6USJdhwgYbenQLTsogwxd7cgLHsm3SLdKbxotfHrMRUKQRHDXptZHldUflcuIlc06sR1UlnYqxxd7Ya5KxeO1vu0LbYjBIPu(bDjG2DnaDjTV5bGJo4YzQimYCHEwiSzuOckEXpaTrxOANbHQtwm6Oh9VpdbOOO)QNrxNSy0TC5mTlRhzUqxsAEcDdCZKfbeAodsAhGEeEYKeJ6d0eesGg0JWjvm1Wj0ccqplCZKTqO5miHcIUq1wNSy0raQdDOf0d9j2tEJcIUBOhma6wRlazYpqoXu(paCz(j2tE3Les0LrPMBLvVCIP8Fa4YuErUp1LaA3vGg0L0(Mhao6ja9gzrvyraew0Q73tfDJE0)(meGII(REgDHQDgeQozXOJUozXO7a6nYDPc3fac3LwD)EQOB0JWtMKyuFGMGqc0GEeoPIPgoHwqa6zHWMrHkO4f)a0gDHQTozXOJauxlIwqp0Nyp5nki6UHEWaOlDxs3LbYjBIPu(bDjG2DLPUg2f)mnhUSjMs5h0LaA3LwQPlP6scj6Ya5KnXuk)GUeq7UGUUKQRHDjDxwRlazYpqoXu(paCz(j2tE3Les0LrPMBLvVCIP8Fa4YuErUp1LaA3LwSlPqxs7BEa4OtV095IP4xC8mJONfcBgfQGIx8dqB0fQ2zqO6KfJo6r)7Zqakk6V6z01jlg9ix6(8U84VRO8mJOljnpHUbUzYIacnNbjTdqpcpzsIr9bAccjqd6r4KkMA4eAbbONfUzYwi0CgKqbrxOARtwm6ia1dbTGEOpXEYBuq0Dd9GbqhqM8dKtmL)daxMFI9K3DnSlR1fd9JpyW4T8ME)495Iqu0x0OGIPDnSlJsn3kRE5et5)aWLP8ICFQlb0UlORRHDXptZHldUflcuIlc06sGUgGUK238aWrp8LajrvyXWXu4Oh9VpdbOOO)QNrxOANbHQtwm6ORtwm6r1LaPUuH7kQIPWrpcpzsIr9bAccjqd6r4KkMA4eAbbONfcBgfQGIx8dqB0fQ26KfJocqDRpAb9qFI9K3OGO7g6bdGoGm5hiNyk)haUm)e7jV7Ayxm0p(GbJ3YB69J3NlcrrFrJckM21WUKUlJsn3kRE5et5)aWLP8ICFQlb0URaORljKOlJsn3kRE5et5)aWLP8ICFQlTw7U0YUKQRHDXptZHldUflcuIlc06sGUgGUK238aWrp8LajrvyXWXu4Oh9VpdbOOO)QNrxOANbHQtwm6ORtwm6r1LaPUuH7kQIPW7s6aPqpcpzsIr9bAccjqd6r4KkMA4eAbbONfcBgfQGIx8dqB0fQ26KfJocq9OgTGEOpXEYBuq0Dd9Gbq3ADbit(bYjMY)bGlZpXEY7Ug2f)mnhUm4wSiqjUiqRlb6Aa6sAFZdah9WxcKevHfdhtHJE0)(meGII(REgDHQDgeQozXOJUozXOhvxcK6sfUROkMcVlPhif6r4jtsmQpqtqibAqpcNuXudNqlia9SqyZOqfu8IFaAJUq1wNSy0raQhObTGEOpXEYBuq0Dd9Gbq3ADbit(bYjMY)bGlZpXEY7UKqIUmk1CRS6LtmL)daxMYlY9PUeq7UGo0L0(Mhao60lDFUyk(fhpZi6zHWMrHkO4f)a0gDHQDgeQozXOJE0)(meGII(REgDDYIrpYLUpVlp(7kkpZyxshif6ssZtOBGBMSiGqZzqs7a0JWtMKyuFGMGqc0GEeoPIPgoHwqa6zHBMSfcnNbjuq0fQ26KfJocq9Ga0c6H(e7jVrbrxs7BEa4OBfKJoVpxCtj5Qxew8BGGE0)(meGII(REgDHQDgeQozXOJUozXORvqo68(8U0cusU67Y6f)giOhHNmjXO(anbHeOb9iCsftnCcTGa0ZcHnJcvqXl(bOn6cvBDYIrhbOEWa0c6H(e7jVrbr3n0dgaDR1L0DzhhoSmKdiAulBLCmSUg2fmkdLyUzlhiBpjMrvmqC8mJDjvxd7Ya5KxeO1vu0LbYjBIPu(bDjG2Df01WUsmq0w9XjzWX0bbIAjmtxc0LMUg2L0DzTUsmq0w9XjzWX0GOwCamtxc0LMUKqIUaKj)a5et5)aWL5Nyp5Dxsirx2XHdlBRgfHrvg5yyDjf6sAFZdahD7jXmQIbIJNze9SqyZOqfu8IFaAJUq1odcvNSy0rp6FFgcqrr)vpJUozXOl4KygvXGUIYZmIUK08e6g4Mjlci0CgK0oa9i8Kjjg1hOjiKanOhHtQyQHtOfeGEw4MjBHqZzqcfeDHQTozXOJaupitOf0d9j2tEJcIUBOhma6s3fXaoOyr(51XPUeq7UYuxsirxs3LDC4WY2QrryuLrogwxd7Ya5KxeO1vu0LbYjBIPu(bDjG2DPPlP6sQUg2L16s6USJdhwgYbenQLTsogwxd7cgLHsm3SLdKtWU)Vpx0qjploEMXUKQRHDLyGOT6JtYGJPdce1syMUeOlnOlP9npaC0tWU)Vpx0qjploEMr0J(3NHauu0F1ZOluTZGq1jlgD01jlgDh29)95DLLsEURO8mJOhHNmjXO(anbHeOb9iCsftnCcTGa0ZcHnJcvqXl(bOn6cvBDYIrhbOEGwIwqp0Nyp5nki6UHEWaOZq)4dgmEldGWI8cgtv0KOHaJyoGI21WUSJdhwgaHf5fmMQOjrdbgXCafvobiMXUeq7UcI6Ug2f)mnhUm4wSiqjUiqRlb6ktOlP9npaC0nuIzCEFUi0JSzX5Ldb83NJE0)(meGII(REgDHQDgeQozXOJUozXONLsmJZ7Z7kZq2CxwNlhc4Vph9i8Kjjg1hOjiKanOhHtQyQHtOfeGEwiSzuOckEXpaTrxOARtwm6ia1dGo0c6H(e7jVrbr3n0dgaDg6hFWGXBzaewKxWyQIMeneyeZbu0Ug2LDC4WYaiSiVGXufnjAiWiMdOOYjaXm2LaA3vGw21WUmk1CRS6LtmL)daxMYlY9PU06UcYuxd7cqM8dKtmL)daxMFI9K3DnSl(zAoCzWTyrGsCrGwxc0vMqxs7BEa4OBOeZ48(CrOhzZIZlhc4Vph9O)9ziaff9x9m6cv7miuDYIrhDDYIrplLygN3N3vMHS5USoxoeWFFExshif6r4jtsmQpqtqibAqpcNuXudNqlia9SqyZOqfu8IFaAJUq1wNSy0raQhOfrlOh6tSN8gfeD3qpya0jgWbflYpVoo1LaA3vM6AyxwRlP7YooCyzihq0Ow2k5yyDnSlyugkXCZwoqob7()(CrdL8S44zg7sk0L0(Mhao6jy3)3NlAOKNfhpZi6r)7Zqakk6V6z0fQ2zqO6KfJo66KfJUd7()(8UYsjp3vuEMXUKoqk0JWtMKyuFGMGqc0GEeoPIPgoHwqa6zHWMrHkO4f)a0gDHQTozXOJaupie0c6H(e7jVrbr3n0dgaDdKtErGwxrrxgiNSjMs5h0LaDf01WUSwxs3LDC4WYqoGOrTSvYXW6AyxWOmuI5MTCGmnob5(CrOhzZIwD)UlPqxs7BEa4OtJtqUpxe6r2SOv3Vrp6FFgcqrr)vpJUq1odcvNSy0rxNSy0JeNGCFExzgYM7sRUFJEeEYKeJ6d0eesGg0JWjvm1Wj0ccqple2mkubfV4hG2OluT1jlgDeG6bwF0c6H(e7jVrbr3n0dgaDP7Ya5KnXuk)GUeORGUKqIUSJdhw2wnkcJQmYXW6scj6s6UaKj)az(zA(L53NlYZdAhvMFI9K3DnSlJsn3kREz(zA(L53NlYZdAhvMYlY9PU06Umk1CRS6LdFjqsufwmCmfUmLxK7tDjvxs11WUKUlP7YOuZTYQxMEP7ZftXV44zgLP8ICFQlb6kORHDjDxwRlcfCHjgGCcqVrwufweaHfT6(9ur3Y8tSN8UljKOlJsn3kRE5eGEJSOkSiaclA197PIULP8ICFQlb6kOlP6scj6Ya5KnXuk)GUeORbDjvxd7s6Umk1CRS6LdFjqsufwmCmfUmLxK7tDjqxbDjHeDzGCYMykLFqxc0vM6sQUKqIUGrzOeZnB5azWLZuryK5QlP6AyxwRlP7YooCyzihq0Ow2k5yyDnSlyugkXCZwoq2EsmJQyG44zg7sk0L0(Mhao62tIzufdehpZi6zHWMrHkO4f)a0gDHQDgeQozXOJE0)(meGII(REgDDYIrxWjXmQIbDfLNzSlPdKcDjP5j0nWntweqO5miPDa6r4jtsmQpqtqibAqpcNuXudNqlia9SWnt2cHMZGeki6cvBDYIrhbOEquJwqp0Nyp5nki6UHEWaOZptZHldUflcuIlc06sGUcqxs7BEa4OBGCIwrGIrp6FFgcqrr)vpJUq1odcvNSy0rxNSy0Zc56sRiqXOhHNmjXO(anbHeOb9iCsftnCcTGa0ZcHnJcvqXl(bOn6cvBDYIrhbO(anOf0d9j2tEJcIUBOhma68Z0C4YGBXIaL4IaTUeORa0L0(Mhao6giNODmnbqp6FFgcqrr)vpJUq1odcvNSy0rxNSy0Zc56sWyAcGEeEYKeJ6d0eesGg0JWjvm1Wj0ccqple2mkubfV4hG2OluT1jlgDeG6dcqlOh6tSN8gfeD3qpya0Twxs3LDC4WYqoGOrTSvYXW6AyxWOmuI5MTCGm4YzQimYC1LuDnSlP7Ya5KxeO1vu0LbYjBIPu(bDjG2DnOljKOl(zAoCzWTyrGsCrGwxADxbDjf6sAFZdahDWLZuryK5c9SqyZOqfu8IFaAJUq1odcvNSy0rp6FFgcqrr)vpJUozXOB5YzAxwpYC1L0bsHUK08e6g4Mjlci0CgK0oa9i8Kjjg1hOjiKanOhHtQyQHtOfeGEw4MjBHqZzqcfeDHQTozXOJauFWa0c6H(e7jVrbrxs7BEa4OBGCIwrGIrp6FFgcqrr)vpJUq1odcvNSy0rxNSy0Zc56sRiqXDjDGuOhHNmjXO(anbHeOb9iCsftnCcTGa0ZcHnJcvqXl(bOn6cvBDYIrhbO(GmHwqp0Nyp5nki6sAFZdahDdKt0oMMaOh9VpdbOOO)QNrxOANbHQtwm6ORtwm6zHCDjymnb6s6aPqpcpzsIr9bAccjqd6r4KkMA4eAbbONfcBgfQGIx8dqB0fQ26KfJocqa6UHEWaOJaeb]] )

    storeDefault( [[SimC Windwalker: CD]], 'actionLists', 20170905.135901, [[dq0VlaqieKnrOmksvDksvMfcQULsO0UiLHrsoMewMi8msLAAiOCncsBdb4BKkghcKZrQK1PkMhbX9iuTpeqheHSqeXdjOMOsixuPInQeQmsLkPtQeCtcStkzPkrpvyQiQTkI8vLkvJvju1BvQe3vPszVq)LedgPdRYIPupMktwsxgSzL0NvkJwIonfVwPQzlQBRQ2nr)wXWjKJJa1Yr1ZPQPl11fPTJi9DeQXlI68QsRxjumFsQ9JYybsgJfbRxAUrsWW6(agH5lmJU7gzL4lVh4pmQWlcJLqgopGwjuvOJkDPsOAf6orbHrqyeoUruJbge5AZi9iz0QajJXoYZodvKemch3iQXONTTmO5MjxhILEmiY2Kn9lggjPZEqj5uqIXcYQXD9WXqosadbtnPJBDFadmSUpGXcssN9aJU4tbjHZODjWO7EPPbgLSzd4ySeYW5b0kHQcDkuHXsWpPCh4rYyJHWLGBVGHu4dYgTXqWuTUpGb2OvcKmg7ip7mursWiCCJOgd9zu3m56qSuZdCqA6xno8pJ0ZOeiJwOIrvRMrTtxx18ahKM(vlveJQhJQwnJsigTVmiBnpWbPPF1a5zNHkgezBYM(fdViW1axzwvSHMFVxgJfKvJ76HJHCKagcMAsh36(agyyDFad1U11t36wOaOExnn8FkeArHUu98888888uuO6jbbORNNNNNh1L7sicCnWz0zLrjbA(9E5DtDPAogeX38yiVpiUxe4AGRmRk2qZV3lJXsidNhqReQk0Pqfglb)KYDGhjJngcxcU9cgsHpiB0gdbt16(agyJw6gjJXoYZodvKemch3iQXqFg1oDDvZdCqA6xTurmQymkHyuGGtnIebvnViW1axzwvSHMFVxMr1JrvRMr1Nrbco1iseu18IaxdCLzvXgA(9EzgvmgvFgTnFGrfcJkugvTAg1ntUoel18ahKM(vJd)Zi9mQqeNrjigvpgvpgvTAgLqmAFzq2AEGdst)QbYZodvgvTAgTp(g0AT5dk9OunaJkeXzu3m56qSuZdCqA6xno8pJ0Jbr2MSPFXGuZLvMvfhCEidEVspjBKEmwqwnURhogYrcyiyQjDCR7dyGH19bmu7wxpDRBHcG6D10W)PGW0rvrXZZZZZZZtrHQNeeGUEEEEEEuxUljzUmJoRmQWW5Hm49mk5jzJ0VBQlvZXGi(Mhd59bXj1CzLzvXbNhYG3R0tYgPhJLqgopGwjuvOtHkmwc(jL7apsgBmeUeC7fmKcFq2OngcMQ19bmWgTimKmg7ip7mursWiCCJOgJE22YGMBMCDiw6XGiBt20VyyNNPQSMYFXybz14UE4yihjGHGPM0XTUpGbgw3hWGK8mvgDXLYFXyjKHZdOvcvf6uOcJLGFs5oWJKXgdHlb3EbdPWhKnAJHGPADFadSrlHIKXyh5zNHkscgHJBe1y0Z2wg0CZKRdXspgezBYM(fdBG7b(EJCdJfKvJ76HJHCKagcMAsh36(agyyDFadsaUh47nYnmwcz48aALqvHofQWyj4NuUd8izSXq4sWTxWqk8bzJ2yiyQw3hWaB0IaqYySJ8SZqfjbJWXnIAmCLgT)LmJUyzuxPrZLY5GSzucuCgTGrfJrbjW3E1AZhu6r5FjZOeO4mQknHIbr2MSPFX44Utck9W5GSXybz14UE4yihjGHGPM0XTUpGbgw3hWGiU7KaJsE4Cq2ySeYW5b0kHQcDkuHXsWpPCh4rYyJHWLGBVGHu4dYgTXqWuTUpGb2OLoizm2rE2zOIKGHGlzZp9t(4Bq7XibgHJBe1y0Z2wg0CZKRdXspJkgJQpJsig94Tz9CT22Lbf7uUV1a5zNHkJkgJceCQrKiOQvAQvqQ8pFdCVY6WTn1kiv6j1vYOIXOeIrfXbsv2CvTcTEsDLkZQsfUUKr1ddISnzt)IrpPUsLzvPcxxIHWLGBVGHu4dYgTXqWut64w3hWaJfKvJ76HJHCKagw3hWG8K6kz0zLrxeCDjgeX38y4EDzqPp(g0EXli8)LSI71LbL(4Bq7fpbglHmCEaTsOQqNcvySe8tk3bEKm2yi8RldKp(g0EKememvR7dyGnArqizm2rE2zOIKGr44grng9STLbn3m56qS0ZOIXO6ZOeIrpEBwpxRTDzqXoL7BnqE2zOYOIXOeIrbco1iseu1kn1kiv(NVbUxzD42MAfKk9K6kzu9WGiBt20Vy0tQRuzwvQW1LySGSACxpCmKJeWqWut64w3hWadR7dyqEsDLm6SYOlcUUKr1Vqpmwcz48aALqvHofQWyj4NuUd8izSXq4sWTxWqk8bzJ2yiyQw3hWaB0sxizm2rE2zOIKGHGlzZp9t(4Bq7XibgHJBe1y0Z2wg0CZKRdXspJkgJQpJE82SEUwB7YGIDk33AG8SZqLrfJr1Nr1Nr7ldYwZdCqA6xnqE2zOYOIXOUzY1HyPMh4G00VAC4FgPNrfI4mAbJQhJQwnJ6knAUuohKnJsGIZOjyu9yuXyu9zu3m56qSuZ3CZEqzwv6sqHyJSMhEvJd)Zi9mQqyucIrvRMrDZKRdXsTvJV9kZQYAk)vJd)Zi9mQqeNrjmgvpgvmg1ntUoel14gVrUP4tLk7nU9AC4FgPNrfcJQdJkgJsigvehivzZv1k06j1vQmRkv46sgvpmiY2Kn9lg9K6kvMvLkCDjgcxcU9cgsHpiB0gdbtnPJBDFadmwqwnURhogYrcyyDFadYtQRKrNvgDrW1LmQ(j0ddI4BEmCVUmO0hFdAV4fe()swX96YGsF8nO9INaJLqgopGwjuvOtHkmwc(jL7apsgBme(1LbYhFdApscgcMQ19bmWgBmcrGZCzZI5AZirReeGUWgra]] )

    storeDefault( [[SimC Windwalker: serenity opener]], 'actionLists', 20170905.135901, [[diuUiaqivjArIaTjsIrrI0Pij5wKKs7sGHrchtqltvQNPOOPjcPRPOuBteW3irnorO6CIqzDQsyEQsY9iPSpsehuKAHkQEivPjQkPUijvBueItkI6LIGAMKKk3uvzNO0qjjvTuQINsmvuyRIiFvrH9k9xQ0GP4Wqwmv8ysnzv6YiBwu(SQy0IKtd61kYSv42Qy3O63qnCu0YbEUqtxPRtvTDvv(UQQgVIsoVOA9KKI5lcY(P0nSmQOoh5mOBDQWIoufbE8AnZaYV)rJjc8cRjsaId3CRbZK4eOIWK0q0aQAqleZl77eiXQ4HgeksL9TIqLvKykMDq4mFhMOjEfrdGm3kvsRxiMhlJYgwgvuNJCg0TZRiAaK5w5LwJsTgh)SSGuW1vJpo4aFMwJkwdta9Z9rFdcdw4dbCzIghRrvwJkwdXjWtEG2hai(AnQzneNap5bh0SSgvSgDkyG2hai(AnVYAcTgvSMxAno(zzbrcqC4Mh4Z0AuXA0y84I)ZdYGXn6IZCZ8b5ba6GG8O18k1Sgfvs7ahWnVYcFiGlt04uXBksp9H)rhIV1PYh(MecWIouLkjZVqnAXGkCmNQWIoufgWhcynQE04ujn4jwrNRhK7Iap0gvlSIhAqOiv23kcvourfpue7d0uSm6wXBUEqmqGhAJDELp8LfDOkDl77YOI6CKZGUDEfrdGm3k6uWGdAwwJQ1A0PGbAFaG4R1Oe1SMqRrfRH4e4jpyHhYDXUh0SSgLOM1Oiy2vs7ahWnVccOrCYDXaaX3kjZVqnAXGkCmNQ8HVjHaSOdvPcl6qvsd0ioznmWaaX3kEObHIuzFRiu5qfv8qrSpqtXYOBfVPi90h(hDi(wNkF4ll6qv6w2zwgvuNJCg0TZRiAaK5wrJXJl(ppidg3OloZnZhKhaOdcYJwJsSMWkPDGd4MxrJgdxKEHyU7ag3kjZVqnAXGkCmNQ8HVjHaSOdvPcl6qv8IgdRjTEHyU1O6GXTsAWtSchDi1sqbE8AnZaYV)rJjc8cRX7RtWkEObHIuzFRiu5qfv8qrSpqtXYOBfVPi90h(hDi(wNkF4ll6qve4XR1mdi)(hnMiWlSgVVUBzt0YOI6CKZGUDEfrdGm3kl(5zqbAmECX)5rRrfRrPwJgJhx8FEqgmUrxCMBMpipaqheKhTgLynHwJQQK2boGBELibioCZRKm)c1OfdQWXCQYh(MecWIouLkSOdvriaXHBEfp0GqrQSVveQCOIkEOi2hOPyz0TI3uKE6d)JoeFRtLp8LfDOkDl7SlJkQZrod625venaYCRG0l8h5sC6aPO18kRzMwJkwJJFwwqKaehU5b(mRK2boGBEfamc5pUrFU7eupvXBksp9H)rhIV1PYh(MecWIouLkjZVqnAXGkCmNQWIoufpWiK)ynIp3AsyOEQsAWtSIoxpi3fbEOnQwyfp0GqrQSVveQCOIkEOi2hOPyz0TI3C9GyGap0g78kF4ll6qv6w2eOmQOoh5mOBNxr0aiZTIJFwwqKaehU5b(mRK2boGBEL4cGtKloZDtrU)H87adUvsMFHA0Ibv4yov5dFtcbyrhQsfw0HQilaorwdoZA2uK1mdi)oWGBfp0GqrQSVveQCOIkEOi2hOPyz0TI3uKE6d)JoeFRtLp8LfDOkDlRYLrf15iNbD78kIgazUvuQ18sRrPwJJFwwqk46QXhhCGptRrfRHjG(5(OVbHbodKEc7VUtq9K1OkRrvwJkwJsTgMa6N7J(gegexaCICXzUBkY9pKFhyW1AuvL0oWbCZR4mq6jS)6ob1tv8MI0tF4F0H4BDQ8HVjHaSOdvPsY8luJwmOchZPkSOdvz(aPNW(R1KWq9uL0GNyfDUEqUlc8qBuTWkEObHIuzFRiu5qfv8qrSpqtXYOBfV56bXabEOn25v(Wxw0HQ0TSjEzurDoYzq3oVIObqMBfngpU4)8aamc5pUrFU7eupfaOdcYJwJsSMqRjHsiRXXpllisaId38Gl(pVsAh4aU5vYGXn6IZCZ8b5vsMFHA0Ibv4yov5dFtcbyrhQsfw0HQKiW4gTgCM1Ki(G8kPbpXkq(saGpZvTWkEObHIuzFRiu5qfv8qrSpqtXYOBfVPi90h(hDi(wNkF4ll6qv62TYRPmK)y78UTa]] )
    

    storeDefault( [[Windwalker Primary]], 'displays', 20170723.095210, [[da0iiaqlsLyxqrQHjvoMuAzsrpdkQPrQKUgPQABKQY3ivKXrQOohPczDKk19ivqhuQAHkYdjKjcfXfvHnQO8rfvgjPkojb9scWmLcUjb0oP0pHOHsshLubwkb6PGPcvxLuL2kPc1xvu1AHIK9kgSk1HLSyk8yuAYQKlR0MPsFgknAQ40i9Aiy2kCBsz3O63igoKoUuOLt0ZPQPRQRJITtO(ofnEOW5jX6Hq7xfDAdEa2c9Pe(mc)HxzSbqQx8geApc8Le7(QIvJrazXXUICwweYuGgzwMTFqXY1w(hGnGcsxx)(Ik0Ns4(y7cGbsxx)(Ik0Ns4(y7cGkPALurilHdue3y1FxankV)iwmhOrMLzVevOpLW9zkGcsxx)(4Le7((y7cOdywM1h8yBdEGdEzm2RmfON9Pe(5Ddu)hRohWwABaGQj68EEk)YSgiSsDFEJkxwIMr9beChB53yB21QV2UomhayLu0pWt1wDyx(yBg8ah8YySxzkqp7tj8Z7gO(pwDkGT02aavt0598u(LznqyL6(8(ADlMXhqWDSLFJTzxR(A76WC(8b8oetWK(So9hzkagiDD97JxsS77JTlG3HycM0N1PN5jzkWxsS73ZzDiYatiXXrkqbfoNEWdOeRU0uFDbWi2UacyvmO8lkh75n8kJn2MbqWONZ6qKbWrQkOW50dEawIMr9QIpIra2c9PeEpN1HidmHehhPadiIGQCEJtcmpLFzwdew55DpYJaEhIjGNPanYSmlMqLl7tj8ackCo9GhGZOjKLW9XQRb8O7ymBuEhrKbrg8avSTbKX2gaBSTbmITnFaVdXuuH(uc3NPayG011VFpJSITlqXilCf0nGbJRBaTcJEMNeBxGAG6u9dZsXRk(i22a1a1PahIPQ4JyBduduNserZOEvXhX2gWwABG5P8lZAGWkpVvLuTsQeOrgklc6yQhELXgOcudZsXRkwntbet9ud6G(k4kOBaJaSf6tj8(bflpGOdl(HGbUOE0rPGRGUbQayY6wmJptbKfh7IRGUbkd6G(kbkgzjqkFZuaaDzP1GIy9ucp2M6thfabJze(due3yBBgqbPRRFFH8lkB9ePp2Ua1a1PWlj29vfRgBBaJbfreNBqm7hJyeqUJaIoS4hcgWJUJXSr5DIrGAG6u4Le7(QIpITnaLLWXueIwST6pqJmlZEjKFrzRNi9zkGlH)boWavUEVzPeOyKLqUlbxbDdyW46g4lj29Nr4p8kJnas9I3Gq7rabwyq1y0oVXPABSyUlaLLWb0ILYXgR(daSsk6hiqnqDQ(HzP4vfRgBBGgzwM9silHdue3y1FxaujvRKkZi8hOiUX22maQCzjAg13R2qaGQj68EEk)YSgiSsDFEJkxwIMr9bmguerCUbXmgb0km6pITlaEnw(FEpNKWGgBxGVKy3xv8rmci4o2YVX2SRvN601UMy6wm3PZTb8oetbSkgu(fLJ1NPaAfgaESTbO8lkB9ezpN1HidiOW50dEavjvRKkN3Ik0Ns4N39mYkqa2c9Pe(mc)bkIBSTnduduNserZOEvXQX2gW7qmfYVOS1tK(mfOgOof4qmvfRgBBGAywkEvXhzkG3Hy2FKPaEhIPQ4JmfGLOzuVQy1yeabJze(hqf)8gkU)82wsjXmGcsxx)(cyYhRU0gabJze(dVYydGuV4ni0EeqJYb8y7c8Le7(Zi8hOiUX22mG3HyQkwntbyl0Ns4Zi8pGk(5nuC)5TTKsIzGIrwa6ogcXKy7cCWlJXELPaEQg6y7rEeBZakiDD973ZiRy7cGbsxx)(cyYhBBavjvRKkN3Ik0Ns4b(sIDFFGVKy3FgH)buXpVHI7pVTLusmdCTUfZ47vBiaq1eDEppLFzwdewPUpVVw3Iz8b8oeZEgzjK7sIraVdXSN5jzkG3HyIxsS77ZuGIrw9CwhImWesCCKcSHJz4bAKzz2Rze(due3yBBgadKUU(9fYVOS1tK(y7c0iZYSxcyYNPaAuEpZtITlqXil9YPFa0rPSY8ja]] )

    storeDefault( [[Windwalker AOE]], 'displays', 20170723.095210, [[da0diaqlssSlir1WKQoMuAzQipJQstJKKUgbyBuvPVrsKXrsuNJKqwhjPUhjbDqPYcvHhsqtesKlQiBur5Juv1ijP4KeQxsvfZKKQBsaTtQ8tiAOKYrjjWsjqpfmvO6QKuARKeQVcjSwirzVIbdHdlzXK4XO0KvPUSsBMQ8zi1OPOtJ0RvunBfUnPA3O63igouoovflNONtPPRQRJITtiFNcJhs68sX6vrTFvYPn4bylSNs4Zi8h(MXgaPAXvxSBkWxs07RjslkbKfh9k0CzNNJa(WSmB3GIMRV8paBGgKEE29fwypLWTX1havKEE29fwypLWTX1hWhMLzVfZs4a98gNa6dynjgDmYsm3JeLa(WSm7TWc7PeUnhbAq65z3hVKO33gxFavaZYS2GhxBWdmXlLXENJaDSpLWVqOo1(XPYbCL(gaO6cVqGck)2OgZxPQVqGjxwIUs9beChBz34o13632(EFdaSsk2h4P6RkSpFCNcEGjEPm27CeOJ9Pe(fc1P2povkGR03aavx4fcuq53g1y(kv9fI71RygFab3Xw2nUt9T(TTV3385dynjgGb9zn7MYraur65z3hVKO33gxFaRjXamOpRzhZtYrGIrwI5Ee8gSnGcJNxGM4uLt9ciGhH)bMqftUwRr1eWAsmWlj69T5iWCLooRjrgahPMGI9xn4byj6k1RjAkkbylSNs4DCwtImWbsCCKcmaGTS0AqpxpLWJ7KFvrbSMedaphb8HzzwuIkx2Ns4beuS)QbpaNrxmlHBJtvdyX2Xy2OSMcjdIm4bQ4AdOexBa0X1gqgxB(awtIHWc7PeUnhbqfPNND)ogzfxFGIrw4nyBafgpVa6fQDmpjU(a1aZS6ggvJvt0uCTbQbMzbMednrtX1gOgyMLqIUs9AIMIRnGR03aOGYVnQX8vEHOd5uGAyunwnrA5iGiQLQqh0VbVbBdOeGTWEkH3nOO5beo5WNemGpmu25QyQf(MXgOcCtTyJQbVbBdWgqwC0lEd2gOuOd63eOyKLaP8nhbqP1RygFocmxzgH)a98gx7Pani98S7lMFtzRNiTX1hqts1lzZfcHf2tj8leDmYkqaur65z3xm)MYwprAJRpGChbeo5WNemGfBhJzJYAgLa1aZSWlj691enfxBauJRpGpmlZElMFtzRNiT5iaLLWrzeIECTciGEHkGhxFGVKO3FgH)W3m2aivlU6IDtbeyHkvNr)cbovFJZ3(awtIrhZtIsaGvsX(awkh9ydudmZQByunwnrAX1gats1lzJywchON34eqFamjvVKnZi8hON34ApfatUSeDL670upaq1fEHafu(TrnMVsvFHatUSeDL6dqzjCaRyPC0XjGa6fQDtX1haVgl)Vq4VKWGfxFGVKO3xt0uucOjP6LS5cHWc7PeEGVKO33gqWDSLDJ7uFRk1RQ9Nq5T(2RYTbQbMzHxs07RjslU2a6uEhZtIZ3aSf2tj8ze(d0ZBCTNcOmONp7)Gy0ngrjW96vmJVtt9aavx4fcuq53g1y(kv9fI71RygFaRjXqm)MYwprAZrGAGzwcj6k1RjslU2a1WOASAIMYraRjXOBkkbSMednrt5ialrxPEnrArjqnWmlWKyOjslU2awtIHF2gfk)MYrBZrG5kZi8h(MXgaPAXvxSBkGoLd4X5BGVKO3FgH)a98gx7PaZvMr4Fan8leqXTxiCLusmcWwypLWNr4Fan8leqXTxiCLusmcumYcW2XqmkfxFGjEPm27CeWs1XgBhYP48nqdspp7(DmYkU(awtIHMiTCe4lj69Nr4Fan8leqXTxiCLusmcGkspp7((5WgxBGgKEE299ZHnovPnGYGE(S)dIrucOt5DtX5BGVKO3VJZAsKboqIJJuGck2F1GhOyKvhN1KidCGehhPavFAgEaFywM9EgH)a98gx7Pau(nLTEISJZAsKbeuS)QbpGpmlZE7NdBociKG1CHaNeafu(TrnMVYleDiNcumYsTC6haBunRmFca]] )

    storeDefault( [[Brewmaster Primary]], 'displays', 20170723.095210, [[d0ZGhaGEvHxsqSlej9AvrMjvLEmsnBf9BOUjKuxds4BQIkpNIDsQ9k2nj7hj9tvPHPGXHivBtvugkHgmsmCeoOu5Ois0XOshNsyHuXsjOwSuSCuEOuvpfSmPkRJsunrijtfIjtjnDLUOcDvcsxwLRRQ2ivvBfrkBMO2ob(ivfFgsnnvrvFNQmskrEgKOrtKXJiojI6wuIYPr15PuhwYArKWTLsh3GeGUiwow5hRwyTNxGxHI4lz9ya6Iy5yLFSAb(JlA3EbyLc91x6OFkobS4F)RBYrRAp1gGoG9RSS52(fXYXkt0dbi5vw2CB)Iy5yLj6Haw8V)zLmnwb8hx0OyiGrc719zfzLmonbS4F)ZA)Iy5yLjobSFLLn3Ium03AIEiaP8F)ZeKODdsGrv1mpRXjqh9YXkQu8LB2ODdOR2laQo56p3acFZRmx09gCFM7Wakda0moXgiB2agjSh4XxAPUX4eWiH96(loobmsypWJV0sD)fhNa1NvKvYyeBIlqZxwoGD0wwVNneqgR2aDmEnPsrxmg2lGrc7Hum03AItGNA6u0sywaKxrHj7JLqcqJBBQvuWyAcqxelhR6u0sywaNxeKxuhOpMWMkfeCah251wM9yuP09ogWiH9aK4eWI)9puXzh9YXQact2hlHeq9BjtJvMOrzadXnN(NLrQpEIzbjqfTBGMODdGoA3aSODZgWiH96xelhRmXjajVYYMB7(Sk6Ha1Nvi2exGMVSCG2IKU)IJEiqnjKQUPxzBefmgTBGAsivGe2tuWy0UbQjHu1h32uROGXODdGQtU(ZnobQPxzBefigNac4gEdFYxBeBIlqta6Iy5yv3KJwfO)Ogzu4aw850prACdS2ZlqfWk3qmlBeBIlqfGvk0hInXfOA4t(AhO(Sc1C1fNa6Q9c4WoV2YShJkfrgVTy2bEQXpwTa)XfTBVaK8klBULSYkNUwmZe9qargVTy2uP0ViwowrLs3Nvbcy)klBULSYkNUwmZe9qa2nd0FuJmkCGTyOV1pwTberOsbkLHkfDXyyVa1KqQqkg6BffmgTBaRNC9NBNOVbitAuP4WoV2YShZYPsbvNC9NBal(3)SswzLtxlMzItaonwrkW42ODrrGTyOVTtrlHzbCErqErTWK9Xsib2IH(w)y1cR98c8kueFjRhdG6IeE7VLkfeE7fnkhcWPXkGOO5k0rJIaanJtSbcutcPQB6v2grbIr7gGGXBlMnzASc4pUOrXqacgVTy2(XQf4pUOD7fGGD042MA7e9n6HaCLvoDTywNIwcZcimzFSesG2IKUXOhcGuZtTuP4dd)jIEiWwm03kkymnbe(MxzUO7n4(Cdp)qps1fLdKUBargVTy2uP0Viwowfylg6BnbAlsaKODdutcPcPyOVvuGy0UbA5QU)IJEiWwm03kkqmnbAM8hp8zI96MZ0eWiH9iRSYPRfZmXjqnjKQ(42MAffigTBGA6v2grbJXjGrc71ngNagjSNOGX4eGg32uROaX0eWiH9eYz3Wvw5k0M4e4Pg)y1gqeHkfOugQu0fJH9cqYRSS5wH4yI2nqlxbirpeylg6B9JvlWFCr72lGrc7jkqmobOlILJv(XQnGicvkqPmuPOlgd7fO(SciU5KmQIEiWOQAMN14eWWBjMx37y09cutcPcKWEIceJ2nG9RSS52UpRIEiWtn(XQfw75f4vOi(swpgGKxzzZTifd9TMOhcy)klBUvioMOTm3ant(Jh(mXEPjqlx1ngnkdqs096rQOiq9zvNIwcZc48IG8IAFh9JeWI)9pR(XQf4pUOD7fWqCZP)zzKstal(3)SkehtCcaehnVM8h1YXQO79mspq9zLqv8naXSSpw2e]] )

    storeDefault( [[Brewmaster AOE]], 'displays', 20170723.095210, [[d0tHhaGEvHxsqSlKu61QkmtQk9yKA2k8BOUjsIRjvPBlvEoP2jL2Ry3eTFe5NQsdtrnoKuSnKuzOeAWiQHJWbPshfjP6ysPJtsAHsXsjjwmfTCu9qPQEkyzQIwhvf1evv0uHyYKutxPlQixLQcxwLRdPnsv1wrsvBMcBNaFuQIpRQAAijX3PkJKG0ZiOgnjgVQsNejUfvf50OCEQ4Wswlss6BijLtBqcqxeldl9JLlSoJlWRpq8LIDkaDrSmS0pwUa7XfB7Za8s(F9vo6pstavrp0ZDW(LDNCdqhW51WqFB)IyzyPo25aFFnm032ViwgwQJDoGQOh6PMcnwcShxS9ohqRG9Cr5ffPboMbuf9qp19lILHL60eW51WqFlsX)Vvh7CaQo6HE6GeBBqcmjlZXPonbCPxgwsISVm9gBBaB1Db(8mk0XgqLBCL(I95Cl11oplCaGMZi2azZgqRG9ap2sR4oLMaAfSNl6IJzaTc2d8ylTIl6IttGT4)36kPvW8anViiVurfk9iuKaoX6tpN7nGbwUbC5SAqIST4CSxaTc2dP4)3QttGpmDL0kyEaKxrvO0JqrcqJ7mRvuWumdqxeldlDL0kyEGMxeKxQeOpMWHezeCGg(51v694Ki7(ofqRG9aK0eqv0d9(KXp6LHLbuHspcfjGeTJcnwQJv4aAIBm8pkTsF8aZdsGk22a8yBd8hBBaZyBZgqRG96xeldl1PjW3xdd9TUO8k25afkVqCiUaMOggb6QVUOlo25a1GqPChELJwuWuSTbQbHsbkyprbtX2gOgekvFCNzTIcMITnWNNrHo20eOgELJwuGyAciGPzMSbBDqCiUaMbOlILHLUd2Vmq)jlYKkbufLr)b1Z0W6mUava1mnXOCqCiUa0b4L8)qCiUaLjBWwNafkVOctEPjqht6IU4yfoWhM(XYfypUyBFgaioAwnypQLHLX(K6OMa1GqPqk()TIceJTnGZRHH(wks1m6AXCDSZb43iq)jlYKkb2I)FRFSCdiIqImusnjY2IZXEbQbHsHu8)BffmfBBa1NrHowxrFdqH6jrUHFEDLEpUptI8NNrHo2aQIEONAks1m6AXCDAcWOXsQkg3fBBVby0yjqu0m5FS9gyl()T(XYfwNXf41hi(sXofGk1xwhAhjYiSUlwHNd0vFbKyNda0CgXgqZK)Jlqniuk3Hx5OffigBBaMunJUwm3vsRG5buHspcfjabN1vCh)y5cShxSTpdqWpACNzTUI(g7CGVX(8j12BGU6R7uSZbqQXjxsK7HJrjIDoWw8)BffmfZaQCJR0xSpNBPAZuL5NuBRWZutBaroRR4oKi3Viwgwgyl()T6aeCwxXDOqJLa7XfBVZbe5SUI7qIC)IyzyjjYUO8kqGT4)3kkqmMbSv3fOHFEDLEpojYUVtbmhShp6zG9ChJygqRG9OivZORfZ1PjqniuQ(4oZAffigBBGA4voArbtPjGwb75ofZaAfSNOGP0eGg3zwROaXygqRG9eY5yYKQzYFDAc8HPFSCdiIqImusnjY2IZXEb((AyOVvin6yBd0XKasSchyl()T(XYfypUyBFgqRG9efiMMa0fXYWs)y5gqeHezOKAsKTfNJ9cuO8ciUXGYNXohyswMJtDAcOzDeJZ9DkwHdudcLcuWEIceJTnGZRHH(wxuEf7CGpm9JLlSoJlWRpq8LIDkW3xdd9Tif))wDSZbCEnm03kKgDS(uBaZb7XJEgyVygOJjDNIv4afkVOinWioexatudJafkVCL0kyEGMxeKxQ47KFKaQIEONA)y5cShxSTpdOjUXW)O0kXmGQOh6Pwin60e47RHH(wks1m6AXCDSZbkuE5djBdqmkNJNnba]] )

    storeDefault( [[Brewmaster Defensives]], 'displays', 20170723.095210, [[d0JChaGEfYlPKYUqK0RvqntQGdlz2k6Xi1nvLY1uq62svxwPDsXEf7gv7Nq9tvLHjL(nuJtvsgkjnykXWr4GsLJIirhJQCCcPfsPwkLKftLwoPEOc1tbltbwNQKYevLyQqAYiPPRYfvfxLq0ZuLQRdXgPI2kIu2mbBxv1hPc9ze10qKQVtvnscHTrjvJMeJhrCsK4wkionkNxkEorRfrcFtvs1XlObOlIJH5oX8dUM5g4tKOoqX8e4kn59u)vJBaDXjVJvw6HJDa3jB0ihNy)4gO5tqqU34I4yyUmM2aK8jii3BCrCmmxgtBarrwKLkfAmhyJ2ygm0a9mE3tmVhquKfzPoUiogMlJDGMpbb5EOLM8EYyAdqkrwKvg0y8cAGhE5oxQXoqh9XWCXwCGjVygeWu9BGxwHLlz)RmGv7Cl5gZGwpR712(EaGwZiUa5YfqQG9bF2rR09e7aK8jii3dT0K3tgtBaPc2h8zhTshYHJDGcrxu4cy0gInGlIGqGMygYaR3gGKygYRgqQdnGub7JwAY7jJDGHD740kyDa0pvRO4OiqdqJ7DRt9)jUbOlIJH5DCAfSoG9hk63BbaILMvt2O6yyEmdS(RcivW(aASdikYISVW0l9XW8awrXrrGgGJ0tHgZLX4fqsSZPZzjvgJNyDqduX4fqhJxaYX4fWngVCbKky)XfXXWCzSdqYNGGCVoeDftBGcrxOneBaxebHa9fjDihoM2a1KqP6M(vJu9)jgVa1KqPafSV6)tmEbQjHsng37wN6)tmEbmv)gWwV(9L8wTylVSclxY(xzGA6xns1F1yh4NjzUSj7AqBi2aUbOlIJH5DtgzEGXpg0hRcqLjjMvdAdXgGAaDXjVOneBGYLnzxtGcrxVX4BSdikcJEysJjHRzUbQad76eZpGnAJXRnWlRqHmVyhOMekfAPjVN6VAmEbA(eeK7rHtLrxhwlJPnGENbg)yqFSkGKyNtNZsQe3a1KqPqln59u)FIXlWvAY75eZVaQOITafxk2IP0ASFarrwKLkfovgDDyTm2b6lsa0y8cWOXCsbg3hZ7TbUstEpNy(bxZCd8jsuhOyEc8wrcRhPxSfuw)gZ7Tby0yoqu0mo5ygAaGwZiUabQjHs1n9RgP6VAmEbUstEVooTcwhW(df97nRO4OiqdqOz9LUXjMFaB0gJ3Gae6Lg37wxNQdX0gquKfz7MmY8(LFbOd0xK09etBa0AU8tSfh1yeIyAdCLM8EQ)pXnaJtLrxhw3XPvW6awrXrrGgWQDULCJzqR3R3s6TdivV3BFLxacnRV0nuOXCGnAJH0BdOQz9LUrSLXfXXWCXw6q0vGa9mEhYHJPnaDrCmm3jMFaB0gJ3GaUt2OrooX(DZzCdivW(u4uz01H1YyhG6kuiZRt1HauinXwS1RFFjVv)AIT8YkSCj7FLbQPF1iv)FIDGAsOuJX9U1P(RgJxaPc2x9)j2bOX9U1P(Rg3asfSV12gxgNkJtwg7asfSF3tSdmSRtm)cOIk2cuCPylMsRX(b6zCanM2axPjVNtm)a2OngVbbg21jMFW1m3aFIe1bkMNa0fXXWCNy(fqfvSfO4sXwmLwJ9dui6ci25KYlX0g4HxUZLASdiz9eZT77jMbbQjHsbkyF1F1y8c08jii3RdrxX0gqQG9v)vJDaPc2Vdrxu4c44gqvZ6lDJylJlIJH5bOUcfY8cqYNGGCpRzlJXlqZNGGCpRzlJziEbKky)oKdh7afIU640kyDa7pu0V3C4XjAarrwKLQtm)a2OngVbbeW8lqNMvtXwmLwJ9dikYISuTMTm2bi5tqqUhfovgDDyTmM2afIUejNDbiMvZQZLa]] )



    ns.initializeClassModule = MonkInit

end
