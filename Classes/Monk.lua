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

            if set_bonus.tier20_2pc > 4 then applyBuff( 'pressure_point', 5 + action.fists_of_fury.cast ) end
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

    storeDefault( [[IV Brewmaster: ST]], 'actionLists', 20170723.103044, [[dudedaGAqrRxsLEPKQSlqPTbkSpjv1Sf62I0obSxYUrz)cAyuv)wudvsfdwedhjoiv0XqvlejTubwmsTCeFdv6PQwMKSoGQ6XsmvkmzqMUuxKk5ZGQNbuQRtv2iqfBfOkBMI68uPoTsFfOOPbuPVtrACafETKYOrfpNsNKk8xGCnkc3dOKvsr0HvCzOfVm0DXg6icjADGjf1DaEHjujOPPJTrc4hMCd9amIJffqLppxFUvvWYRFkyzN4w3P3mtavWam0Dw6nZSYqa8Yq3fBOJiKOQdmPOE9q4HjpDSC0DWG2Y0zIolZqDN0BCB361q4GSPJLJEaAZEKcALHA9amIJffqLppxEF9xilLwxTaQKHUl2qhrirvhysrDQXPul71HjVjBnu3bdAltNj6Smd1DsVXTDRthNsTSxdY2KTgQhG2ShPGwzOwpaJ4yrbu5ZZL3x)fYsP1vlaWwg6UydDeHevDGjf1PsWP5eMKnhMaolb1DWG2Y0zIolZqDN0BCB360eCAoGYMbzEjOEaAZEKcALHA9amIJffqLppxEF9xilLwxTaaxzO7In0resu1bMuupWZYzzWdtm5aHHjG5YG0DWG2Y0zIolZqDN0BCB36eplNLbhemhieKPldspaTzpsbTYqTEagXXIcOYNNlVV(lKLsRt7z2mSeplNLbhemhieKPldcwcAMGwodDevlatidDxSHoIqIQoWKI6glCKeMuNjMQ7GbTLPZeDwMH6oP342U17fosarzIP6bOn7rkOvgQ1dWiowuav(8C591FHSuADKHe4UHT4riiRdtQpyfMadtOwT(lKLsRRwca]] )

    storeDefault( [[IV Brewmaster: AOE]], 'actionLists', 20170723.103044, [[dKd5daGAkIA9OQWlPizxcL2gOI9rrPzlYTLIDQI9s2nk7Nk9tuvvdJk(TGhlQHIQQmyHmCPQdsjDyGJHONbQKfQsTuk1IrLLJ0dPi0tvwMu55u15fQMkfMmitxYfrOtRQldDDP0grvfBLIGndQA7Gk14qvjFfvLAAOQsFNIuVwO4VGYOrvgpfvojL4ZQKRrrv3JIiRKII1HQI(gcwKYqJidWLqiXPDanOMftWn6MIMUb4lKYNUrw5FIA2ycbEuNohscoe66ILuB9y(bPNpa1hy60bh(sZAU(aZldDiLHgrgGlHq6w7aAqnIMRpfGE2LBKPWlnlmOpdQavJfyOMvUp9vCn0C9Pa0ZUGfdEPzJ(qlnJEzOsZgtiWJ605qsG0rBz63xAQ0PtgAezaUecPBTdOb1mfE5gTgGNNMfg0NbvGQXcmuZk3N(kUwm4fmFdWZtZg9HwAg9YqLMnMqGh1PZHKaPJ2Y0VV0uPdCjdnImaxcH0T2b0GAMiV3n6UL6lnlmOpdQavJfyOMvUp9vCTmVhgxl1xA2Op0sZOxgQ0SXec8OoDoKeiD0wM(9LMkD4xzOrKb4siKU1oGgu7MIGINBuaE3i(5POMfg0NbvGQXcmuZk3N(kUghfbfpyb4Hb)trnB0hAPz0ldvA2ycbEuNohscKoAlt)(sdKRhUryqHkwokckEWcWdd(NIUrM1nIuLoMxgAezaUecPBTdOb1SB98E2LBKzaqOBeF)minlmOpdQavJfyOMvUp9vCnARN3ZUGzYaieMPFgKMn6dT0m6LHknBmHapQtNdjbshTLPFFPPsh4idnImaxcH0T2b0GAg)fsDJ4pqQrZcd6ZGkq1ybgQzL7tFfxR(lKcRhKA0SrFOLMrVmuPzJje4rD6Cijq6OTm97lnKH0R4XMBPuKvUrM1KCJGJ5DnJkDiidnImaxcH0T2Y0VV00SXec8OoDoKeiD0SWG(mOcunwGHA2Op0sZOxgQ0oGgu7obYXeAl3Ov0pguLkTLPFFPPsca]] )

    storeDefault( [[IV Brewmaster: Combo]], 'actionLists', 20170723.103044, [[dSdQfaGAqGwVseEjiODrrBdeY(euZwO5dc13efpMs7Kc7vA3i2pjhwLHrQ(nWHabmuLi1GjA4qXbbPEoKJjItRyHcYsbLftWYr6HGiEkvlJuSoLOyCIsXuvstwPMUQUOs4ZIQNjkLUUiTrLOQTQejBge12fL8DsPVQerttjQmprPQ)sOxlWOHsJhePtcQCzuxtjkDEqYkfLkBcu1THQBsxRVGCcrExH6ghoxhULsjdrzT4h6z6YOKqcaxauhgh5dX1qJEsg9mA0yMu3XW25IZsC)ai1qdeLn1H2(dGG6Ans6A9fKtiY7gQUXHZ1HqoxjD8dHToCK9yVhqRtaeUo0ctCEOQhW5Ii8dHTomgbsPwg11(1HXr(qCn0ONKjrVUBPdMVoeqjXq5SeZTBZetH4zdaPVi6PtaRKqmeRKwaiUbAjMysPdKHAi5IcuwRPf7rZzKsM9kPM(1qtxRVGCcrE3q1noCUEO4zdaPVs6pDc46Wr2J9EaTobq46qlmX5HQUq8SbG0xe90jGRdJrGuQLrDTFDyCKpexdn6jzs0R7w6G5R3VgzBxRVGCcrE3q1noCU(6KZuLCPViED4i7XEpGwNaiCDOfM48qv)NCMkI5I41HXiqk1YOU2VomoYhIRHg9Kmj61DlDW81Xq5SeZTBZetH4zdaPVi6Pta3VglxxRVGCcrE3q1noCU(cifteShsUscHCED4i7XEpGwNaiCDOfM48qvNHumrWEi5IbCEDymcKsTmQR9RdJJ8H4AOrpjtIED3shmF9Z(twSity8HrkzyLmrjHxjTaqCd0smfINnaK(IONobSjLXVHGuYWkPUscVsAbG4gOLygW5Ii8dH1KY43qqkzyLuVFnw2UwFb5eI8UHQBC4CDib7OKHsPOVoCK9yVhqRtaeUo0ctCEOQBXoIcPu0xhgJaPulJ6A)6W4iFiUgA0tYKOx3T0bZx)S)KflYegFyKsgwjtus4vslae3aTetH4zdaPVi6PtaBsz8BiiLmSsQRKWRKwaiUbAjMbCUic)qynPm(neKsgwj17xdiQR1xqoHiVBO6ghoxpeLVhRscGSsU8dLRdhzp27b06eaHRdTWeNhQ6cu(ESIailc5HY1HXiqk1YOU2VomoYhIRHg9Kmj61DlDW81p7pzXIBWBgW5Ii8dHvjdRK6kj8kPfaIBGwIPq8SbG0xe90jGnPm(neKsgwj1vs4vslae3aTeZaoxeHFiSMug)gcsjdRK69RrMUwFb5eI8UHQBC4CDyPiSdjxjZUBZk5soKDD4i7XEpGwNaiCDOfM48qvNMIWoKCri4TzrTdzxhgJaPulJ6A)6W4iFiUgA0tYKOx3T0bZx3caXnqlXuiE2aq6lIE6eWMug)gcsjdRK6kj8kPfaIBGwIzaNlIWpewtkJFdbPKHvs9(9R7w6G5R3Vf]] )

    storeDefault( [[IV Brewmaster: Defensives]], 'actionLists', 20170723.103044, [[dOdGeaGEQkPnjvKDbyBivL9HuLzl43G(MuPht0oLI9cTBvTFknkvkggqghvL4WknusLQbtXWr0bjvCkvkDmvY5PslKu1sbQftWYLCAfRsQWYiLEUqtKuPmvKYKj00j5IQu9mQkQlJ66uLFIuvTvQkYMLsBNuj9AsHpJKPrvbFxfJuQOUTu1OPIXtv1jrQClQk11ivI7rkADuvONk6VimEH0W8(VcbwefWmL1qQWeZKKLZggFDvd8XgT0NVGjyoWBKXgTGU6cQRwTaxycMxrxAtpJ5nwJecdIWZdq6vtR78uecfFaKoBrXrI(1V14BRrcHbr45bi9QP1DEkcHIpasNTO4irBTs1a)nyn3AnDynsimicppaPxnTUZtriu8bOyPZwumM6ivd8JinS5cPH59FfcSiQhZMTNXuFyLAyn0VFRrFXhmP7fh5QGfMp8zm1rycJYftHWk1Ga6NqO4dMG5i0RKCePHkmbZbEJm2Of0v3lqyMYAivykHWGi88aKE106opfHqXhaPZwuC0A00AaznDYAIQLIIlasUK8Ri6x)eoKwd900A0ccvyJwKgM3)viWIOEmB2EgtD3RMw35PSg9fFWKUxCKRcwy(WNXuhHjmkxmj9QP1DEkcHIpycMJqVsYrKgQWemh4nYyJwqxDVaHzkRHuHjQWgFgPH59FfcSiQhZuwdPctjegeHNhG0RMw35Piek(aiD2IIJwJMwJecdIWZdq6vtR78uecfFaKoBrXrI(1pMhh(bZROlMrznKkmP7fh5QGfMp8zmB2Egt6k4h1yERrFXhmbZbEJm2Of0v3lqycMJqVsYrKgQWemVIU0MEgZBSgjegeHNhG0RMw35Piek(aiD2IIJe9RFRX3wJecdIWZdq6vtR78uecfFaKoBrXrI2ALQb(BWAU1A6WAKqyqeEEasVAADNNIqO4dqXsNTOym1rycJYfZPGFuJ5jek(GkSXhqAyE)xHalI6XSz7zmV7NKdwtN3Qht6EXrUkyH5dFgtDeMWOCXK9tYbcNT6XemhHELKJinuHjyoWBKXgTGU6EbcZuwdPcthEdZtrejD4IbKqVxzn0ttR5QtwZnwJdVbLdGi3oYrzn0ttRjQwfWQuRudcs4HlRPdRPlGUynDyno8gMNIis6WfdiHEVYAUfvOcZMTNXKoFYA0x8PFJkU8rRr34w(JJUYruHi]] )

    storeDefault( [[IV Brewmaster: Default]], 'actionLists', 20170723.103044, [[d0d3faGEvvrBsu0UevBdvyFQQiRtfmBIomv3uu4qQQk3wIZJk1orv7vz3a7xk)evudtv8BuonHHQQkmyPA4QkheuDkvvuhteFtf1cvLwQk0Ibz5K8qurEkYJL0ZPyIIsMkPyYQ00fUiL4QQQexg66uslJs1wfLAZKk2oQKNbkMMQQQptQ67ukJuvL04uvLgTQk41QiNKuArGsxtvLY9ivALQQqJsvLQ)ksVKPzKfGdjX7EhX7fCK2SB9xfAR4MavhA9SqDCRYye9HvHlf)Phcgy8254VJoIs0n44T)KC(5)p2ZtG55VjJOQs8fJgbVgcgWmnJpzAgzb4qs8U3ruvj(IrbtVEjMlabQuw)cZi4qcPi4EK5dDv6p4GBQjuIt4iTGRO6btncWa4iEVGJOp0vT(V6GBRtHsCchDeLOBWXB)jHJKZ5pWSy82NMrwaoKeV7D0ruIUbhV9NeosoN)aZiQQeFXOGPxVeZ)yHGbmTFCeCLEZiGxqDzYBQnxncoKqkcUh9Xcbdmsl4kQEWuJamaoI3l4O)GfcgyugSlVxWrFkMKb0J30pMnuTy8WmnJSaCijE37iQQeFXOWbNea9TEMTUvdMErDqGrWfAA9mB9)16)ERhUebroK0RNywJ0kRaXYrGdjXBRNzR)PqUs1xV5j5qsVEIznsnHsCcB9FEeVxWrzH6GaJGl0mcUsVzeWlOUW(QqBf3eO6qRNfQdcmcUqdSJGdjKIG7rvxkt9AiyGuPWeJ0cUIQhm1iadGJoIs0n44T)KWrY58hygLb7Y7fCK2SB9xfAR4MavhA9SqDqGrWfAwm()pnJSaCijE37iEVGJ(fd26AdSygPfCfvpyQragahbhsifb3JSAWurGfZOJOHzvvrZ0Sy0ruIUbhV9NKZjpJOQs8fJwm(FBAgzb4qs8U3rhrj6gC82Fs4i5C(dmJOQs8fJcxIGihs61tmRrALvGy5iWHK4DeCLEZiGxqDH9vH2kUjq1HwNtSceR1HZzlWocoKqkcUhvDPm1RHGbsLctmsl4kQEWuJamaoI3l4ioXkqSrzWU8EbhPn7w)vH2kUjq1HwNtSceBX45yAgzb4qs8U3rhrj6gC82Fs4i5C(dmJOQs8fJ(x4see5qsVEIznsRScelhboKeVTEMTUxdbxykcWIan6MmcUsVzeWlOUW(QqBf3eO6qRtHdUU626Kgyhbhsifb3JQUuM61qWaPsHjgPfCfvpyQragahX7fCefo46QBRtAgLb7Y7fCK2SB9xfAR4MavhADsZIXFEAgzb4qs8U3r8EbhrHdUU626W5SLruvj(IrHlrqKdj96jM1iTYkqSCe4qs826z26EneCHPialc006)uRNmcUsVzeWlOUW(QqBf3eO6qRZjwbI16KgyhDeLOBWXB)jHJKZ5pWmsl4kQEWuJamaocoKqkcUhvDPm1RHGbsLctmkd2L3l4iTz36Vk0wXnbQo06W5SLflgLfQJBvgdAXg]] )

    storeDefault( [[SimC Windwalker: default]], 'actionLists', 20170723.095209, [[di0FmaqirQArscBckAuuuDkkkZIeq2fcdJcDmOYYufEgjuttKkxtcX2iH4BIughjqDosqTokvnpru3te2hjihucwOKOhsrMijKCrjuJKesDsOGxscOMPes3KeTtkzOKa0svf9uHPsPSvOqFvezVe)frdwXHvzXs0Jf1KPQlJAZQsFMcgnu60GEnu1Sj1Tvv7gYVbgoj54Kaz5i9CQmDPUUKA7uQ8DsQZlswpjaMVK0(vAbNytIIrxPM9sLsyDFwIa(nTtsqKx9PXZu73XZVxTULiuXz4PHkaxdbiX6HIOWs8K185yX6HrCPzSipumXdJPtXPtXsezkuvlHefYneGCInXcNytIIrxPM9sLsezkuvlrdmyqZequZuATQ2TdM7y(o9rnWnHNlRFFjYNRHide1Q2Xmjkuc1WoLeov8rjXEipPRPq8Seya5H5RbujqaelHsGhJh16(SesyDFwIqfF0Du0hYVt0uiEwINSMphlwpmIlnCgL4j7a10m7eBslHjSCgVsGD8NrTukHsG36(SeslwpeBsum6k1SxkLOqjud7us0G6mwsWlj(J(pjWaYdZxdOsGaiwcLapgpQ19zjKW6(Se2a1zS7aE3rb(O)tIcudojGOMP2D6ekSrfiv5MelF6gBcJefrINSMphlwpmIlnCgL4j7a10m7eBslHjSCgVsGD8NrTukHsG36(SeslwkwSjrXORuZEPsjImfQQLObgmOzcvGgcqUDWChZ3PS(9LWXugb7ue1Q2PA1DkRFFjCnG(j5J2yjpKN8fszIAv7uT6oMVt63PpnJAchtzeStrWORuZ(DWCNMcr45MqffKjodqnStruRAhZ2PA1DkRFFjk1aGxx7AIAv7uT6o9rnWnrd)mzdi9qENKtSJIyChZKOqjud7usOc0qascmG8W81aQeiaILqjWJXJADFwcjSUplHciOHaKepznFowSEyexA4mkXt2bQPz2j2Kwcty5mELa74pJAPucLaV19zjKwSsNytIIrxPM9sLsezkuvlrdmyqZezaq7bQrUDWChZ3PpQbUjA4NjBaPhY7KCIDu4DmtIcLqnStjrdQZyjbVKE(ASsGbKhMVgqLabqSekbEmEuR7ZsiH19zjSbQZy3b8UJIIVgRepznFowSEyexA4mkXt2bQPz2j2Kwcty5mELa74pJAPucLaV19zjKwSkIytIIrxPM9sLsezkuvlH570NMrnHJPmc2Piy0vQz)oyUtga0EGAeHJPmc2PiO8)Gi3ojNyhJ7y2ovRUtz97lHJPmc2PiQvjrHsOg2PKiFAn5LBiarQHUwcmG8W81aQeiaILqjWJXJADFwcjSUplHPtR3PqUHa0off6Ajkqn4KaDForfb8BANKGiV6tJNP2VJJPmc2PQqINSMphlwpmIlnCgL4j7a10m7eBslHjSCgVsGD8NrTukHsG36(Seb8BANKGiV6tJNP2VJJPmc2PKwSueXMefJUsn7LkLiYuOQwI0VtFAg1eoMYiyNIGrxPM97G5oMVtz97lHRb0pjF0gl5H8KVqktuRANQv3jdaApqnIW1a6NKpAJL8qEYxiLjYypQb2TtIDESJzsuOeQHDkjYNwtE5gcqKAORLadipmFnGkbcGyjuc8y8Ow3NLqcR7Zsy606DkKBiaTtrHUEhZXzMefOgCsGUpNOIa(nTtsqKx9PXZu73XXVviXtwZNJfRhgXLgoJs8KDGAAMDInPLWewoJxjWo(ZOwkLqjWBDFwIa(nTtsqKx9PXZu73XXVslwPj2KOy0vQzVuPerMcv1sK(D6tZOMWXugb7uem6k1SFhm3Hvq1qvQypHNcr4HidKybuezgyht3bZDmFNmaO9a1icxtH4zsWlzJLjvdrEnG6jO8)Gi3ojNyhCk4DWCNmaO9a1iIxORDKGxY3AAkck)piYTtYj2b3JDWCNmwirUMszuVJcLyhfVdM7KbaThOgrqHoiYaPRgrIhMXtq5)brUDsoXo42PA1D6JAGBIg(zYgq6H8ojNyNhfzNQv3jdaApqnIOb1zSKGxspFnwck)piYTJcTdoCp2XSDWCNmaO9a1icxdOFs(OnwYd5jFHuMiJ9Ogy3oj2bNefkHAyNsI8P1KxUHaePg6AjWaYdZxdOsGaiwcLapgpQ19zjKW6(SeMoTENc5gcq7uuOR3X8hMjrbQbNeO7ZjQiGFt7Kee5vFA8m1(DC8Bfs8K185yX6HrCPHZOepzhOMMzNytAjmHLZ4vcSJ)mQLsjuc8w3NLiGFt7Kee5vFA8m1(DC8R0ILcwSjrXORuZEPsjImfQQLi970NMrnHJPmc2Piy0vQz)oyUt63Hvq1qvQypHNcr4HidKybuezgyht3bZDmFNmaO9a1icxtH4zsWlzJLjvdrEnG6jO8)Gi3ojNyhCPBhm3jdaApqnI4f6Ahj4L8TMMIGY)dIC7KCIDuKDWCNmwirUMszuVJcLyhfVdM7KbaThOgrqHoiYaPRgrIhMXtq5)brUDsoXo42PA1D6JAGBIg(zYgq6H8ojNyhCfzNQv3jdaApqnIOb1zSKGxspFnwck)piYTJcTdoCp2XSDWCNmaO9a1icxdOFs(OnwYd5jFHuMiJ9Ogy3oj2bNefkHAyNsI8P1KxUHaePg6AjWaYdZxdOsGaiwcLapgpQ19zjKW6(SeMoTENc5gcq7uuOR3XCfBMefOgCsGUpNOIa(nTtsqKx9PXZu73XXVviXtwZNJfRhgXLgoJs8KDGAAMDInPLWewoJxjWo(ZOwkLqjWBDFwIa(nTtsqKx9PXZu73XXVslwkSytIIrxPM9sLsuOeQHDkjYNwtE5gcqKAORLadipmFnGkbcGyjuc8y8Ow3NLqcR7Zsy606DkKBiaTtrHUEhZtNzsuGAWjb6(CIkc430ojbrE1NgptTFNWwfs8K185yX6HrCPHZOepzhOMMzNytAjmHLZ4vcSJ)mQLsjuc8w3NLiGFt7Kee5vFA8m1(DcBslTekk(9Q1TuP0Ia]] )

    storeDefault( [[SimC Windwalker: precombat]], 'actionLists', 20170723.095209, [[dmducaGEQKAxuf2gQkMTOUjfUTu2jL2lz3OSFQkdJI(nWqrvLbtv1WrOdkGJrfNJkrlerwQsAXOYYLQhIGNQ6XISouvAIujzQc1Kbz6kUOG6Yqxhr9AbzRGQ2mvcBhv5Ws(kvP(mvkFNQOLjKNPegnOCAKoPs03eORHQQopOYZvQPrvYFPs1YrX6HzfxgHejDB1q9tBe853BkdYZkhc781NFIDmbAC1OFIyIwzQRRHcyYgXhxQVIzS2OSrMobn5F0cpIm9AHxl0FQtjo66bsdfW2kwwhfRhMvCzesK0FQtjo6dWn3YOhebdfW26b4Oz6aNorWqbm9LmiAQgqxNbyOUbac(QBRgQRBRgQZpWqbm9vmJ1gLnY0jOJP(kUbK7jCRyn6eGHPqgaEydzJ40naq2QH6AKnsX6HzfxgHej9aC0mDGtpbJ6oh5(E0xYGOPAaDDgGH6gai4RUTAOUUTAOobyuF(jrUVh9vmJ1gLnY0jOJP(kUbK7jCRyn6eGHPqgaEydzJ40naq2QH6AKDHI1dZkUmcjs6b4Oz6aNEcg1DplEO(sgenvdORZamu3aabF1Tvd11Tvd1jaJ6ZV3fpuFfZyTrzJmDc6yQVIBa5Ec3kwJobyykKbGh2q2ioDdaKTAOUgn6UcDrropIKgj]] )

    storeDefault( [[SimC Windwalker: sef]], 'actionLists', 20170723.095209, [[daukfaqiLqwKskBsjQrPGQtPeywkbDlfuSlcAyG0Xe0YeONPezAeOUgHW2usvFJi6Cki16OKAEkO09ic7tjvoirAHkjpuvAIeixKa2OcsojLsZuju3uvStqnufeTuIYtrMQISvkjFLsXEL(RIAWK6WIwSc9yQAYk1LH2mHYNbXOPeNgvVMs1SPYTfA3O8BsgUcSCGNRQMUkxNOA7esFNq14jeDEbSEfe2pf3Wovsawo6WDxvcoJyjIhFnAB4ST4PZocS2O)OyLObONNo(qKhxXkCW1p0LKHom)yHdcnusOIi4scdcvWlj4LkrEaFWvQKu)XvSFNkCyNkjalhD4URkrEaFWvArg9aak6me)wyOWJdbbZdsx0Ox2OrgcGeqOxoaGSZOLWOrgcGeqymfPrVSr7TWf6Ldai7m6H1OdljDK74xGshhccMhKUyPxlO3(JsumISRJLEuBRsaCgXsLSLT5(8uGsmfdlbNrS0ehccm6HmDXssbq(L8b8oC(sae8(sewsg6W8Jfoi0qjdHwsg(vYbE83PELEd4D4ucGG3VRk9O2Wzel1RWb7ujby5Od3DvjYd4dUsElCHXuKg9Wy0ElCHE5aaYoJEDsy0Hg9YgnYqaKacpEeNp1CmfPrVojmAOcfrjPJCh)cukb(KHZNcaq2vYw2M7ZtbkXumS0JABvcGZiwQeCgXssb(KHg9Kcaq2vsg6W8Jfoi0qjdHwsg(vYbE83PELETGE7pkrXiYUow6rTHZiwQxHxQtLeGLJoC3vLKoYD8lqjF6CZP)4k2SJ)Vs2Y2CFEkqjMIHLEuBRsaCgXsLGZiw6nDoJwQ)4kMrVy()kjfa5xILruI1iE81OTHZ2INo7iWAJ(vqRvsg6W8Jfoi0qjdHwsg(vYbE83PELETGE7pkrXiYUow6rTHZiwI4XxJ2goBlE6SJaRn6xb1RWcUtLeGLJoC3vLipGp4kDkiqCOqVs52kXzFJEzJE4g9Im6r5IjMW)PaXzmbNL5KTNfJdqHYhy0lOK0rUJFbk9pfioJj4SmNS9SyCawYw2M7ZtbkXumS0JABvcGZiwQeCgXs0PaXfA0cKGZYcn6KTn6HIdWsYqhMFSWbHgkzi0sYWVsoWJ)o1R0Rf0B)rjkgr21XspQnCgXs9kSi6ujby5Od3DvjPJCh)cuYNo3C6pUIn74)RKTSn3NNcuIPyyPh12QeaNrSuj4mILEtNZOL6pUIz0lM)pJE4HlOKuaKFjwgrjwJ4XxJ2goBlE6SJaRnAAATsYqhMFSWbHgkzi0sYWVsoWJ)o1R0Rf0B)rjkgr21XspQnCgXsep(A02WzBXtNDeyTrtt96vsqOyPC31v9Aba]] )

    storeDefault( [[SimC Windwalker: serenity]], 'actionLists', 20170723.095209, [[dq0SoaqisblIuOSjHkJsOQtjkSlvXWqLogPAzIspJuKPbIY1efPTrkeFtGmoquvNJuOADIIyEII6EcQ2hPOoOcSqf0dfkteeIlkqTrbbNuqALGOsVuq0mbHu3uvANO0qbrvwQaEkXurfBvq5RGqTxP)IIbtPddSyr8ysMSIUm0Mfv(SqgTOQtR0QjfsVgvnBv1Tb1Uv53umCf64ccTCKEovnDexxK2oP03bbJhesopiTEquX8br2pvU6LtLGpqYhNDyfwamwrw4yoleV3ecGppsZeN1Ju8wc0kYiQwWFHCaK1CLnRgrJxja(rGhlBwU6bXntZQPNSCHmnbzAQIOO7iPsLbkYAoF5uw9YPsWhi5JZoSIOO7iPIgC2rkQLjsnF0FiBeszgbFyNnoNfpKgb9rLsP4rC2WDw8qAe0hyaeLZgNZQYVpQukfpIZMzNv3zJZz1GZMKMl3JhP4TeOpPJvgKS)LaTczJqkZi4dxjwEuX)A0IW4rAsLxZmmaLfaJvQe6nxfGyOvoZHvybWyfoBesDwipWhUYaAKVIcQ6Jmeancj(W1Rea)iWJLnlx9G05wja6nPuf6lNsQedQ6JCa0iK47WkVMjlagRuszZwovc(ajFC2HvgKS)LaTIc8)mafznhZF9KkHEZvbigALZCyLxZmmaLfaJvQWcGXkXa)VZoqrwZ5Sq0RNuzanYx5aWy4AmzHJ5Sq8Etia(8intC2yqenwLa4hbESSz5QhKo3kbqVjLQqF5usLy5rf)RrlcJhPjvEntwamwrw4yoleV3ecGppsZeNngePKYQPYPsWhi5JZoSIOO7iPcXef9XhLX8NgiC(kds2)sGwXJu8wc0kHEZvbigALZCyLxZmmaLfaJvQWcGXkcsXBjqRea)iWJLnlx9G05wja6nPuf6lNsQelpQ4FnAry8inPYRzYcGXkLuwiRCQe8bs(4SdRik6osQKKMl3JhP4TeOpuegSN3zZC4oRUZgNZQmM)0aH7HU(9Iy8Phd)Q4FOimypVZQ5WDwUpzZuNnoNfdX0DCeNpt6E87fXK3qpgLrlsD24Cwn4SJuultKA(O)4h372lIrrbhYWVk(kds2)sGwXpU3TxeJIcoKHFv8vc9MRcqm0kN5WkVMzyaklagRuHfaJvKX9U9IC2yuWHoBixfFLa4hbESSz5QhKo3kbqVjLQqF5usLy5rf)RrlcJhPjvEntwamwPKYMPLtLGpqYhNDyfrr3rsfGISArg8q4f9oBMDwnvzqY(xc0k01VxeJp9y4xfFLy5rf)RrlcJhPjvEnZWauwamwPsO3CvaIHw5mhwHfaJvcS(9ICwj9C2qUk(kdOr(kkOQpYqa0iK4dxVsa8Japw2SC1dsNBLaO3KsvOVCkPsmOQpYbqJqIVdR8AMSaySsjLvJuovc(ajFC2HvgKS)LaTINqxEKXKJHKhzGWEZVHoRe6nxfGyOvoZHvEnZWauwamwPclagRie6YJoRjNZsYJoleV38BOZkbWpc8yzZYvpiDUvcGEtkvH(YPKkXYJk(xJwegpstQ8AMSaySsjLnOYPsWhi5JZoSIOO7iPs8oRgC2rkQLjsnF0Fs(afVjLWWVkENndNnoNnENDKIAzIuZh9hpHU8iJjhdjpYaH9MFdD6Sqcso7if1YePMp6p5wpXZyYXKlLc1zZWzJZzbkYQfzWdHx07Sz2zZwzqY(xc0kjFGI3Ksy4xfFLy5rf)RrlcJhPjvEnZWauwamwPsO3CvaIHw5mhwHfaJvg(bkEtkXzd5Q4RmGg5ROGQ(idbqJqIpC9kbWpc8yzZYvpiDUvcGEtkvH(YPKkXGQ(ihancj(oSYRzYcGXkLuwi)YPsWhi5JZoSIOO7iPs8oB8olgIP74ioFM0943lIjVHEmkJwK6SX5SjP5Y9msrVpLImJM9ipuegSN3zZC4oBwNnoN1JeMeZL6FilsZYLbYgvoRMDwUoBgoBCoB8oRYy(tdeUh663lIXNEm8RI)HIWG98oRMDwDNfsqYzbkYQfzWdHx07SA2z1D2mC2mQmiz)lbALCRN4zm5yYLsHwj0BUkaXqRCMdR8AMHbOSaySsfwamwjewpX7SMCoBiKsHwzanYxzpcsPPJKW1Rea)iWJLnlx9G05wja6nPuf6lNsQelpQ4FnAry8inPYRzYcGXkLuwnE5uj4dK8Xzhwru0DKujENnENvdolgIP74ioFM0943lIjVHEmkJwK6SqcsoBsAUCpjFJz(t9KN0rNfsqYztsZL7XJu8wc0hkcd2Z7Sz2z1D2mC24C24DwLX8NgiCp01VxeJp9y4xf)dfHb75Dwn7S6olKGKZcuKvlYGhcVO3z1SZQ7Sz4SzuzqY(xc0k5wpXZyYXKlLcTsO3CvaIHw5mhw51mddqzbWyLkSaySsiSEI3zn5C2qiLc1zJxpJkdOr(k7rqknDKeUELa4hbESSz5QhKo3kbqVjLQqF5usLy5rf)RrlcJhPjvEntwamwPKYQZTCQe8bs(4SdRik6osQauKvlYGhcVO3z1C4oRMC24Cwn4SJuultKA(O)4h372lIrrbhYWVk(kds2)sGwXpU3TxeJIcoKHFv8vc9MRcqm0kN5WkVMzyaklagRuHfaJvKX9U9IC2yuWHoBixfVZgVEgvcGFe4XYMLREq6CRea9MuQc9LtjvILhv8VgTimEKMu51mzbWyLskRUE5uj4dK8Xzhwru0DKubOiRwKbpeErVZQ5WDwnvzqY(xc0k01VxeJp9y4xfFLy5rf)RrlcJhPjvEnZWauwamwPsO3CvaIHw5mhwHfaJvcS(9ICwj9C2qUkENnE9mQmGg5ROGQ(idbqJqIpC9kbWpc8yzZYvpiDUvcGEtkvH(YPKkXGQ(ihancj(oSYRzYcGXkLuw9SLtLGpqYhNDyfrr3rsfn4SJuultKA(O)4h372lIrrbhYWVk(kds2)sGwXpU3TxeJIcoKHFv8vc9MRcqm0kN5WkVMzyaklagRuHfaJvKX9U9IC2yuWHoBixfVZgF2mQea)iWJLnlx9G05wja6nPuf6lNsQelpQ4FnAry8inPYRzYcGXkLuwDnvovc(ajFC2HvefDhjv0GZosrTmrQ5J(tYhO4nPeg(vXxzqY(xc0kjFGI3Ksy4xfFLy5rf)RrlcJhPjvEnZWauwamwPsO3CvaIHw5mhwHfaJvg(bkEtkXzd5Q4D241ZOYaAKVIcQ6Jmeancj(W1Rea)iWJLnlx9G05wja6nPuf6lNsQedQ6JCa0iK47WkVMjlagRusz1HSYPsWhi5JZoSIOO7iPIgC2rkQLjsnF0FOP(87fXOrbtKbc7nRmiz)lbAfAQp)ErmAuWezGWEZkHEZvbigALZCyLxZmmaLfaJvQWcGXkbs953lYzHCbt0zH49MvcGFe4XYMLREq6CRea9MuQc9LtjvILhv8VgTimEKMu51mzbWyLskPcebZbs)KoSKw]] )

    storeDefault( [[SimC Windwalker: ST]], 'actionLists', 20170723.095209, [[duKmxaqiQQ0IKeL2eb1OeIoLKWTKuk7Iunmc1XeyzsspJQkMgevUMKiBtsj(gvjJtsuCoikADuLsMhevDpQc7JGCqc0cjGhkKMOKs6IufTrQsLtkewjvPuVusuntQsr3es2jjnuQsHLsv5PuMkPyRuv1xHO0Ev(ljgmIddSyb9yQmzrDzuBgI8zHA0svNwvRgIcVgsnBjUTu2Tk)MOHtkDCjLQLd1Zfz6GUUuz7sQ(oH04LuCEiSEQsvZNqSFKEbtZmppqyHZlCwTYib6kWjWmvqJNzFlkLGS)LffuqZyVfLyAM5JlmiXtTQ4aVexPQ(rVQyKZpiNFMzAz3dkV3dGV8MA1Abzotqh8LxAAMAW0mZZdew48eyMGHF5HiM5aLIcWbF5Pu(eCwex(DaOep7KhpdLm7paRcA8SzQGgplkOuOebDWxEuI38tWzcIJtZoqJ9OYAFlkLGS)LffuqZyVfLeTwRSZ8XfgK4PwvCGxbIN5JtYoSJttZGZI2Zo0OK15gFWfodLmRcA8m7BrPeK9VSOGcAg7TOKO16GtT60mZZdew48eyM5WVw4mx)R76Wy(GucY7bLeqjctjrsjoPSKLIE64p9xSsQ7uq)o06yUb(lrjEqjIPereHsIKsay4JeWb1tq8JMvKiPa7zfr)lxK4SoFGWcNPeHPeNuwYsrp9ee)OzfjskWEwr0)YfjoRJ5g4VeL4bLiMsQGserekHpghJq31HX8bPeKNsQKykPIzcg(LhIygFmo(9()Iv4YxZJNfXLFhakXZo5XZqjZ(dWQGgpBMkOXZ88yC879)ftjEw(AE8mFCHbjEQvfh4vG4z(4KSd7400m4SO9SdnkzDUXhCHZqjZQGgpBWP6NPzMNhiSW5jWmZHFTWzU(xVbQHsQnkX1)6UomMpiLiKhusaLimLWhJJrOd)gRaLknqnuIqEqjI1R0mbd)YdrmdGDGJvGsmMp4SiU87aqjE2jpEgkz2Fawf04zZubnEMGyh4ykrJeJ5doZhxyqINAvXbEfiEMpoj7WoonndolAp7qJswNB8bx4muYSkOXZgCQi30mZZdew48eyM5WVw4m)sjAXCDLyxwpqh(XmwrlO0OeHPe(yCmcD43yfOuPbQHsqEpOeX6vIseMsC9VEdudLuBuIR)1DDymFqkripOKQZem8lpeXm4hZyfTGsBw0E2HgLSo34dUWzOKz)byvqJNnlIl)oauINDYJNPcA8mnFmJPeVbO0MjioonZHWvyfiahZWKhbZ8XfgK4PwvCGxbIN5JtYoSJttZGZIIWvynaCmdttGzOKzvqJNn4uR00mZZdew48eyM5WVw4m)sjqqHpOEIX89qe68bclCMserekXjLLSu0tpXy(EicDm3a)LOeH8GsceptWWV8qeZsq8JMvKiPa7zfr)lxK48SiU87aqjE2jpEgkz2Fawf04zZubnEMbXpAMsKirjWEMsq2)YfjopZhxyqINAvXbEfiEMpoj7WoonndolAp7qJswNB8bx4muYSkOXZgCQ1Y0mZZdew48eyM5WVw4SiPKiPex)R76Wy(GuIqEqj(HseMs4JXXi0DDymFqkripOeKtmLubLiIiuIR)1DDymFqkripOKkrjvqjctjrsj(LsGGcFq9eJ57Hi05dew4mLiIiuItklzPONEIX89qe6yUb(lrjc5bLulusfZem8lpeXm8N(lwj1DkOFh6zr7zhAuY6CJp4cNHsM9hGvbnE2SiU87aqjE2jpEMkOXZ89P)IPeR7OKk)DONjioonZHWvyfiahZWKhbZ8XfgK4PwvCGxbIN5JtYoSJttZGZIIWvynaCmdttGzOKzvqJNn4u9AAM55bclCEcmZC4xlCgeu4dQNymFpeHoFGWcNPeHPe)sjCT39A1Yz9m(p0)fR0lXNItwNXuIWuItklzPONEIX89qe6yUb(lrjc5bLujkrykHpghJqh(nwbkvAGAOeHOKQZem8lpeXmK(emPirsbPomIzrC53bGs8StE8muYS)aSkOXZMPcA8mV7tWeLirIs8UomIz(4cds8uRkoWRaXZ8Xjzh2XPPzWzr7zhAuY6CJp4cNHsMvbnE2GtTYmnZ88aHfopbMzo8Rfodck8b1tmMVhIqNpqyHZuIWucx7DVwTCwpJ)d9FXk9s8P4K1zmLimLejL4KYswk6PNymFpeHoMBG)suIqEqjbvIserekXjLLSu0tpXy(EicDm3a)LOeK3dkb5OKkOeHPe(yCmcD43yfOuPbQHseIsQotWWV8qeZq6tWKIejfK6WiMfXLFhakXZo5XZqjZ(dWQGgpBMkOXZ8UpbtuIejkX76WiOKidQyMpUWGep1QId8kq8mFCs2HDCAAgCw0E2HgLSo34dUWzOKzvqJNn4urMtZmppqyHZtGzMd)AHZ8lLabf(G6jgZ3drOZhiSWzkrykHpghJqh(nwbkvAGAOeHOKQZem8lpeXmK(emPirsbPomIzrC53bGs8StE8muYS)aSkOXZMPcA8mV7tWeLirIs8UomckjYQvmZhxyqINAvXbEfiEMpoj7WoonndolAp7qJswNB8bx4muYSkOXZgCQbINMzEEGWcNNaZmh(1cN5xkbck8b1tmMVhIqNpqyHZuIiIqjoPSKLIE6jgZ3drOJ5g4VeLiKhusLMjy4xEiIz4p9xSsQ7uq)o0ZI2Zo0OK15gFWfodLm7paRcA8SzrC53bGs8StE8mvqJN57t)ftjw3rjv(7qtjrguXmbXXPzoeUcRab4ygM8iyMpUWGep1QId8kq8mFCs2HDCAAgCwueUcRbGJzyAcmdLmRcA8SbNAqW0mZZdew48eyMGHF5HiMjA)Jl)fRKXGy5POT7C9ZI4YVdaL4zN84zOKz)byvqJNntf04ziB)Jl)ftj1kgelpkXB0DU(z(4cds8uRkoWRaXZ8Xjzh2XPPzWzr7zhAuY6CJp4cNHsMvbnE2GtnO60mZZdew48eyM5WVw4mU27ETA5SoSNv4MwglXjfhqlW9qjMseMsc7qcjDypRWnTmwItkoGwG7HsSEccCOPeH8GscqMuIWucFmogHo8BScuQ0a1qjcrj(zMGHF5HiM5Wah6YFXkidqMvkFCp8(lEwex(DaOep7KhpdLm7paRcA8SzQGgplkg4qx(lMs82GmtjEZpUhE)fpZhxyqINAvXbEfiEMpoj7WoonndolAp7qJswNB8bx4muYSkOXZgCQb(zAM55bclCEcmZC4xlCgx7DVwTCwh2ZkCtlJL4KIdOf4EOetjctjHDiHKoSNv4MwglXjfhqlW9qjwpbbo0uIqEqjbihLimL4KYswk6PNymFpeHoMBG)sucYtjb(HseMsGGcFq9eJ57Hi05dew4mLimLWhJJrOd)gRaLknqnuIquIFMjy4xEiIzomWHU8xScYaKzLYh3dV)INfXLFhakXZo5XZqjZ(dWQGgpBMkOXZIIbo0L)IPeVniZuI38J7H3FXusKbvmZhxyqINAvXbEfiEMpoj7WoonndolAp7qJswNB8bx4muYSkOXZgCQbi30mZZdew48eyM5WVw4mGd(1zf(42ZjkripOe)qjctj(Ls0I56kXUSEGEs7F3FXkom4yf0Vd9mbd)YdrmlP9V7VyfhgCSc63HEwex(DaOep7KhpdLm7paRcA8SzQGgpZ0(39xmLefdoMsQ83HEMpUWGep1QId8kq8mFCs2HDCAAgCw0E2HgLSo34dUWzOKzvqJNn4udQ00mZZdew48eyM5WVw4mx)R3a1qj1gL46FDxhgZhKseIscOeHPe)sjAXCDLyxwpqh3L6)lwbzaYSIO)LNjy4xEiIz4Uu)FXkidqMve9V8SiU87aqjE2jpEgkz2Fawf04zZubnEMVUu)FXuI3gKzkbz)lpZhxyqINAvXbEfiEMpoj7WoonndolAp7qJswNB8bx4muYSkOXZgCQb1Y0mZZdew48eyM5WVw4SiPex)R76Wy(GuIqusaLiIiusyhsiPhkrROflD6DAPereHsIKsGGcFqD(yC879)fRWLVMhRZhiSWzkrykXjLLSu0tNpgh)E)FXkC5R5X6yUb(lrjipL4KYswk6PJ0NGjfjski1HrOJ5g4VeLubLubLimLejLejL4KYswk6PJ)0FXkPUtb97qRJ5g4VeLieLeqjctjrsj(Lsay4JeWb1tq8JMvKiPa7zfr)lxK4SoFGWcNPereHsCszjlf90tq8JMvKiPa7zfr)lxK4SoMBG)suIqusaLubLiIiuIR)1DDymFqkrikPkLubLimLejL4KYswk6PJ0NGjfjski1HrOJ5g4VeLieLeqjIicL46FDxhgZhKseIs8dLubLiIiuIwmxxj2L1d0HFmJv0cknkPckrykXVuIwmxxj2L1d0dlahAzhub97qptWWV8qeZclahAzhub97qplAp7qJswNB8bx4muYS)aSkOXZMfXLFhakXZo5XZubnEMafGdTSdsjv(7qptqCCAMdHRWkqaoMHjpcM5JlmiXtTQ4aVcepZhNKDyhNMMbNffHRWAa4ygMMaZqjZQGgpBWPg410mZZdew48eyM5WVw4m(yCmcD43yfOuPbQHseIscMjy4xEiIzU(xruqDEwex(DaOep7KhpdLm7paRcA8SzQGgplA)tjilOopZhxyqINAvXbEfiEMpoj7WoonndolAp7qJswNB8bx4muYSkOXZgCQbvMPzMNhiSW5jWmZHFTWz8X4ye6WVXkqPsdudLieLemtWWV8qeZC9VsyhobNfXLFhakXZo5XZqjZ(dWQGgpBMkOXZI2)uIaD4eCMpUWGep1QId8kq8mFCs2HDCAAgCw0E2HgLSo34dUWzOKzvqJNn4udqMtZmppqyHZtGzMd)AHZ8lLOfZ1vIDz9aD4hZyfTGsJseMsIKsC9VEdudLuBuIR)1DDymFqkripOKQuIiIqj8X4ye6WVXkqPsdudLG8usaLuXmbd)Ydrmd(XmwrlO0MfTNDOrjRZn(GlCgkz2Fawf04zZI4YVdaL4zN84zQGgptZhZykXBaknkjYGkMjioonZHWvyfiahZWKhbZ8XfgK4PwvCGxbIN5JtYoSJttZGZIIWvynaCmdttGzOKzvqJNn4uRkEAM55bclCEcmtWWV8qeZC9VIOG68SiU87aqjE2jpEgkz2Fawf04zZubnEw0(NsqwqDMsImOIz(4cds8uRkoWRaXZ8Xjzh2XPPzWzr7zhAuY6CJp4cNHsMvbnE2GtTAW0mZZdew48eyMGHF5HiM56FLWoCcolIl)oauINDYJNHsM9hGvbnE2mvqJNfT)Peb6WjiLezqfZ8XfgK4PwvCGxbIN5JtYoSJttZGZI2Zo0OK15gFWfodLmRcA8SbhCM5WVw4Sb3a]] )

    storeDefault( [[SimC Windwalker: CD]], 'actionLists', 20170723.095209, [[daKzkaqifkBcOAueLofrQzPaPBjOQSlsmmb5yiPLjsEMcrttHuxtHW2uG4BckJJOQCobvvRtqvmpIQCpII9Pa1bbsleiEirYefu5IkGnkOkDsfQUjrStbwQc6PunvKYwfP8vIQk7f6VO0GbDyPwmj9ykMSOUSQnRO(maJwronLEnqz2cDBuSBc)wPHJuDCfswoQEoPMUKRlITtu57irJxKQZdO1tuv18rc7hXivKg6diA14ZiiOh0mhD3Yifbk)SImLDeSZdpeOuHd9W95ojwiiOp8X36JbPcrnSqJi1ivsfA0JC0JeD3WT0l0rhutzxHgPHburAOpGOvJpJGGUB4w6f6YsGMDJ5LsHI(8lSfqf(zARqtGdMaPgIaPGccunzEwrF(f2cOscDcuAcKckiWXiWQJxuk6ZVWwavUOvJpJoOQ2OTaIUM(n15S7mR6lEdSJOpUiBnDTC0fR4OlzZP18GM5OJEqZC0D63uNtG7mbcYlEdSJOdkhGgDrZCz00VPoNDNzvFXBGDe9Hp(wFmiviQHrne6dVEt4MRrAyHUut3aMKvUZCrHQOlzZbnZrhlmifsd9beTA8zee0Dd3sVqxwcunzEwrF(f2cOscDceCcCmc8JkXsN(ZkA63uNZUZSQV4nWosGstGuqbbklb(rLyPt)zfn9BQZz3zw1x8gyhjqWjqzjWYYCcuEe4iiqkOGan7gZlLcf95xylGk8Z0wHMaLNmeO8rGstGstGuqbbogbwD8IsrF(f2cOYfTA8z0bv1gTfq0LZ2r2DM18w)41A2At3k0OpUiBnDTC0fR4OlzZP18GM5OJEqZC0tZ2rcCNjqPERF8AnbsBt3k0OdkhGgDrZCzKZ2r2DM18w)41A2At3k0Op8X36JbPcrnmQHqF41Bc3Cnsdl0LA6gWKSYDMlkufDjBoOzo6yHbJePH(aIwn(mcc6UHBPxOxlaaXRy2nMxkfA0bv1gTfq0vJ7MzNt4arFCr2A6A5OlwXrxYMtR5bnZrh9GM5OdsC3mbgEt4arF4JV1hdsfIAyudH(WR3eU5AKgwOl10nGjzL7mxuOk6s2CqZC0Xcdgnsd9beTA8zee0Dd3sVqVwaaIxXSBmVuk0OdQQnAlGOREU(CWScaOpUiBnDTC0fR4OlzZP18GM5OJEqZC0b5C95GzfaqF4JV1hdsfIAyudH(WR3eU5AKgwOl10nGjzL7mxuOk6s2CqZC0Xcdgbsd9beTA8zee0Dd3sVq3mzvy60jWWhbAMSkMeo)IIahSmeivceCc8IZbauPSmNTwwMoDcCWYqGHugb6GQAJ2ci6n30IZwlNFrH(4IS101YrxSIJUKnNwZdAMJo6bnZrhuUPfNaPTC(ff6dF8T(yqQqudJAi0hE9MWnxJ0WcDPMUbmjRCN5IcvrxYMdAMJowyWGG0qFarRgFgbbDjD6wMegAnhWln6Pq3nCl9c9AbaiEfZUX8sPqtGGtGYsGJrGnVSZTPua0XZQMW1LYfTA8zceCc8JkXsN(Zkt2C(cwMwxNRzNxUQnNVGT2eZebcobogbsNF5ybyYkuvQnXmXUZS531ebkn6GQAJ2ci61MyMy3z287AcDPMUbmjRCN5IcvrxYMtR5bnZrh9XfzRPRLJUyfh9GM5OtBtmte4otGH7DnHoOCaA0nanXZwnhWlTmuhuMoDwdqt8SvZb8sltk0h(4B9XGuHOgg1qOp86nHBUgPHf6sb0epTMd4LgbbDjBoOzo6yHbHH0qFarRgFgbbD3WT0l0RfaG4vm7gZlLcnbcobklbogb28Yo3MsbqhpRAcxxkx0QXNjqWjWXiWpQelD6pRmzZ5lyzADDUMDE5Q2C(c2AtmteO0OdQQnAlGOxBIzIDNzZVRj0hxKTMUwo6IvC0LS50AEqZC0rpOzo602eZebUZey4ExteOSuLg9Hp(wFmiviQHrne6dVEt4MRrAyHUut3aMKvUZCrHQOlzZbnZrhlmq(qAOpGOvJpJGGUKoDltcdTMd4Lg9uO7gULEHETaaeVIz3yEPuOjqWjqzjWMx252uka64zvt46s5Iwn(mbcobklbklbwD8IsrF(f2cOYfTA8zceCc0SBmVuku0NFHTaQWptBfAcuEYqGujqPjqkOGantwftcNFrrGdwgcmfbknbcobklbA2nMxkfk6IBb7S7mBnDwkTICC5zf(zARqtGYJaLpcKckiqZUX8sPqz2Qln7oZoNWbQWptBfAcuEYqGJMaLMabNan7gZlLcfUvBfay1jcwWSgWu4NPTcnbkpcmmceCcCmcKo)YXcWKvOQuBIzIDNzZVRjcuA0bv1gTfq0RnXmXUZS531e6snDdysw5oZffQIUKnNwZdAMJo6JlYwtxlhDXko6bnZrN2MyMiWDMad37AIaLnL0OdkhGgDdqt8SvZb8sld1bLPtN1a0epB1CaV0YKc9Hp(wFmiviQHrne6dVEt4MRrAyHUuanXtR5aEPrqqxYMdAMJowyHUt)gBhTY)USRadsniHFSqea]] )


    storeDefault( [[Windwalker Primary]], 'displays', 20170723.095210, [[da0iiaqlsLyxqrQHjvoMuAzsrpdkQPrQKUgPQABKQY3ivKXrQOohPczDKk19ivqhuQAHkYdjKjcfXfvHnQO8rfvgjPkojb9scWmLcUjb0oP0pHOHsshLubwkb6PGPcvxLuL2kPc1xvu1AHIK9kgSk1HLSyk8yuAYQKlR0MPsFgknAQ40i9Aiy2kCBsz3O63igoKoUuOLt0ZPQPRQRJITtO(ofnEOW5jX6Hq7xfDAdEa2c9Pe(mc)HxzSbqQx8geApc8Le7(QIvJrazXXUICwweYuGgzwMTFqXY1w(hGnGcsxx)(Ik0Ns4(y7cGbsxx)(Ik0Ns4(y7cGkPALurilHdue3y1FxankV)iwmhOrMLzVevOpLW9zkGcsxx)(4Le7((y7cOdywM1h8yBdEGdEzm2RmfON9Pe(5Ddu)hRohWwABaGQj68EEk)YSgiSsDFEJkxwIMr9beChB53yB21QV2UomhayLu0pWt1wDyx(yBg8ah8YySxzkqp7tj8Z7gO(pwDkGT02aavt0598u(LznqyL6(8(ADlMXhqWDSLFJTzxR(A76WC(8b8oetWK(So9hzkagiDD97JxsS77JTlG3HycM0N1PN5jzkWxsS73ZzDiYatiXXrkqbfoNEWdOeRU0uFDbWi2UacyvmO8lkh75n8kJn2MbqWONZ6qKbWrQkOW50dEawIMr9QIpIra2c9PeEpN1HidmHehhPadiIGQCEJtcmpLFzwdew55DpYJaEhIjGNPanYSmlMqLl7tj8ackCo9GhGZOjKLW9XQRb8O7ymBuEhrKbrg8avSTbKX2gaBSTbmITnFaVdXuuH(uc3NPayG011VFpJSITlqXilCf0nGbJRBaTcJEMNeBxGAG6u9dZsXRk(i22a1a1PahIPQ4JyBduduNserZOEvXhX2gWwABG5P8lZAGWkpVvLuTsQeOrgklc6yQhELXgOcudZsXRkwntbet9ud6G(k4kOBaJaSf6tj8(bflpGOdl(HGbUOE0rPGRGUbQayY6wmJptbKfh7IRGUbkd6G(kbkgzjqkFZuaaDzP1GIy9ucp2M6thfabJze(due3yBBgqbPRRFFH8lkB9ePp2Ua1a1PWlj29vfRgBBaJbfreNBqm7hJyeqUJaIoS4hcgWJUJXSr5DIrGAG6u4Le7(QIpITnaLLWXueIwST6pqJmlZEjKFrzRNi9zkGlH)boWavUEVzPeOyKLqUlbxbDdyW46g4lj29Nr4p8kJnas9I3Gq7rabwyq1y0oVXPABSyUlaLLWb0ILYXgR(daSsk6hiqnqDQ(HzP4vfRgBBGgzwM9silHdue3y1FxaujvRKkZi8hOiUX22maQCzjAg13R2qaGQj68EEk)YSgiSsDFEJkxwIMr9bmguerCUbXmgb0km6pITlaEnw(FEpNKWGgBxGVKy3xv8rmci4o2YVX2SRvN601UMy6wm3PZTb8oetbSkgu(fLJ1NPaAfgaESTbO8lkB9ezpN1HidiOW50dEavjvRKkN3Ik0Ns4N39mYkqa2c9Pe(mc)bkIBSTnduduNserZOEvXQX2gW7qmfYVOS1tK(mfOgOof4qmvfRgBBGAywkEvXhzkG3Hy2FKPaEhIPQ4JmfGLOzuVQy1yeabJze(hqf)8gkU)82wsjXmGcsxx)(cyYhRU0gabJze(dVYydGuV4ni0EeqJYb8y7c8Le7(Zi8hOiUX22mG3HyQkwntbyl0Ns4Zi8pGk(5nuC)5TTKsIzGIrwa6ogcXKy7cCWlJXELPaEQg6y7rEeBZakiDD973ZiRy7cGbsxx)(cyYhBBavjvRKkN3Ik0Ns4b(sIDFFGVKy3FgH)buXpVHI7pVTLusmdCTUfZ47vBiaq1eDEppLFzwdewPUpVVw3Iz8b8oeZEgzjK7sIraVdXSN5jzkG3HyIxsS77ZuGIrw9CwhImWesCCKcSHJz4bAKzz2Rze(due3yBBgadKUU(9fYVOS1tK(y7c0iZYSxcyYNPaAuEpZtITlqXil9YPFa0rPSY8ja]] )

    storeDefault( [[Windwalker AOE]], 'displays', 20170723.095210, [[da0diaqlssSlir1WKQoMuAzQipJQstJKKUgbyBuvPVrsKXrsuNJKqwhjPUhjbDqPYcvHhsqtesKlQiBur5Juv1ijP4KeQxsvfZKKQBsaTtQ8tiAOKYrjjWsjqpfmvO6QKuARKeQVcjSwirzVIbdHdlzXK4XO0KvPUSsBMQ8zi1OPOtJ0RvunBfUnPA3O63igouoovflNONtPPRQRJITtiFNcJhs68sX6vrTFvYPn4bylSNs4Zi8h(MXgaPAXvxSBkWxs07RjslkbKfh9k0CzNNJa(WSmB3GIMRV8paBGgKEE29fwypLWTX1havKEE29fwypLWTX1hWhMLzVfZs4a98gNa6dynjgDmYsm3JeLa(WSm7TWc7PeUnhbAq65z3hVKO33gxFavaZYS2GhxBWdmXlLXENJaDSpLWVqOo1(XPYbCL(gaO6cVqGck)2OgZxPQVqGjxwIUs9beChBz34o13632(EFdaSsk2h4P6RkSpFCNcEGjEPm27CeOJ9Pe(fc1P2povkGR03aavx4fcuq53g1y(kv9fI71RygFab3Xw2nUt9T(TTV3385dynjgGb9zn7MYraur65z3hVKO33gxFaRjXamOpRzhZtYrGIrwI5Ee8gSnGcJNxGM4uLt9ciGhH)bMqftUwRr1eWAsmWlj69T5iWCLooRjrgahPMGI9xn4byj6k1RjAkkbylSNs4DCwtImWbsCCKcmaGTS0AqpxpLWJ7KFvrbSMedaphb8HzzwuIkx2Ns4beuS)QbpaNrxmlHBJtvdyX2Xy2OSMcjdIm4bQ4AdOexBa0X1gqgxB(awtIHWc7PeUnhbqfPNND)ogzfxFGIrw4nyBafgpVa6fQDmpjU(a1aZS6ggvJvt0uCTbQbMzbMednrtX1gOgyMLqIUs9AIMIRnGR03aOGYVnQX8vEHOd5uGAyunwnrA5iGiQLQqh0VbVbBdOeGTWEkH3nOO5beo5WNemGpmu25QyQf(MXgOcCtTyJQbVbBdWgqwC0lEd2gOuOd63eOyKLaP8nhbqP1RygFocmxzgH)a98gx7Pani98S7lMFtzRNiTX1hqts1lzZfcHf2tj8leDmYkqaur65z3xm)MYwprAJRpGChbeo5WNemGfBhJzJYAgLa1aZSWlj691enfxBauJRpGpmlZElMFtzRNiT5iaLLWrzeIECTciGEHkGhxFGVKO3FgH)W3m2aivlU6IDtbeyHkvNr)cbovFJZ3(awtIrhZtIsaGvsX(awkh9ydudmZQByunwnrAX1gats1lzJywchON34eqFamjvVKnZi8hON34ApfatUSeDL670upaq1fEHafu(TrnMVsvFHatUSeDL6dqzjCaRyPC0XjGa6fQDtX1haVgl)Vq4VKWGfxFGVKO3xt0uucOjP6LS5cHWc7PeEGVKO33gqWDSLDJ7uFRk1RQ9Nq5T(2RYTbQbMzHxs07RjslU2a6uEhZtIZ3aSf2tj8ze(d0ZBCTNcOmONp7)Gy0ngrjW96vmJVtt9aavx4fcuq53g1y(kv9fI71RygFaRjXqm)MYwprAZrGAGzwcj6k1RjslU2a1WOASAIMYraRjXOBkkbSMednrt5ialrxPEnrArjqnWmlWKyOjslU2awtIHF2gfk)MYrBZrG5kZi8h(MXgaPAXvxSBkGoLd4X5BGVKO3FgH)a98gx7PaZvMr4Fan8leqXTxiCLusmcWwypLWNr4Fan8leqXTxiCLusmcumYcW2XqmkfxFGjEPm27CeWs1XgBhYP48nqdspp7(DmYkU(awtIHMiTCe4lj69Nr4Fan8leqXTxiCLusmcGkspp7((5WgxBGgKEE299ZHnovPnGYGE(S)dIrucOt5DtX5BGVKO3VJZAsKboqIJJuGck2F1GhOyKvhN1KidCGehhPavFAgEaFywM9EgH)a98gx7Pau(nLTEISJZAsKbeuS)QbpGpmlZE7NdBociKG1CHaNeafu(TrnMVYleDiNcumYsTC6haBunRmFca]] )

    storeDefault( [[Brewmaster Primary]], 'displays', 20170723.095210, [[d0ZGhaGEvHxsqSlej9AvrMjvLEmsnBf9BOUjKuxds4BQIkpNIDsQ9k2nj7hj9tvPHPGXHivBtvugkHgmsmCeoOu5Ois0XOshNsyHuXsjOwSuSCuEOuvpfSmPkRJsunrijtfIjtjnDLUOcDvcsxwLRRQ2ivvBfrkBMO2ob(ivfFgsnnvrvFNQmskrEgKOrtKXJiojI6wuIYPr15PuhwYArKWTLsh3GeGUiwow5hRwyTNxGxHI4lz9ya6Iy5yLFSAb(JlA3EbyLc91x6OFkobS4F)RBYrRAp1gGoG9RSS52(fXYXkt0dbi5vw2CB)Iy5yLj6Haw8V)zLmnwb8hx0OyiGrc719zfzLmonbS4F)ZA)Iy5yLjobSFLLn3Ium03AIEiaP8F)ZeKODdsGrv1mpRXjqh9YXkQu8LB2ODdOR2laQo56p3acFZRmx09gCFM7Wakda0moXgiB2agjSh4XxAPUX4eWiH96(loobmsypWJV0sD)fhNa1NvKvYyeBIlqZxwoGD0wwVNneqgR2aDmEnPsrxmg2lGrc7Hum03AItGNA6u0sywaKxrHj7JLqcqJBBQvuWyAcqxelhR6u0sywaNxeKxuhOpMWMkfeCah251wM9yuP09ogWiH9aK4eWI)9puXzh9YXQact2hlHeq9BjtJvMOrzadXnN(NLrQpEIzbjqfTBGMODdGoA3aSODZgWiH96xelhRmXjajVYYMB7(Sk6Ha1Nvi2exGMVSCG2IKU)IJEiqnjKQUPxzBefmgTBGAsivGe2tuWy0UbQjHu1h32uROGXODdGQtU(ZnobQPxzBefigNac4gEdFYxBeBIlqta6Iy5yv3KJwfO)Ogzu4aw850prACdS2ZlqfWk3qmlBeBIlqfGvk0hInXfOA4t(AhO(Sc1C1fNa6Q9c4WoV2YShJkfrgVTy2bEQXpwTa)XfTBVaK8klBULSYkNUwmZe9qargVTy2uP0ViwowrLs3Nvbcy)klBULSYkNUwmZe9qa2nd0FuJmkCGTyOV1pwTberOsbkLHkfDXyyVa1KqQqkg6BffmgTBaRNC9NBNOVbitAuP4WoV2YShZYPsbvNC9NBal(3)SswzLtxlMzItaonwrkW42ODrrGTyOVTtrlHzbCErqErTWK9Xsib2IH(w)y1cR98c8kueFjRhdG6IeE7VLkfeE7fnkhcWPXkGOO5k0rJIaanJtSbcutcPQB6v2grbIr7gGGXBlMnzASc4pUOrXqacgVTy2(XQf4pUOD7fGGD042MA7e9n6HaCLvoDTywNIwcZcimzFSesG2IKUXOhcGuZtTuP4dd)jIEiWwm03kkymnbe(MxzUO7n4(Cdp)qps1fLdKUBargVTy2uP0Viwowfylg6BnbAlsaKODdutcPcPyOVvuGy0UbA5QU)IJEiWwm03kkqmnbAM8hp8zI96MZ0eWiH9iRSYPRfZmXjqnjKQ(42MAffigTBGA6v2grbJXjGrc71ngNagjSNOGX4eGg32uROaX0eWiH9eYz3Wvw5k0M4e4Pg)y1gqeHkfOugQu0fJH9cqYRSS5wH4yI2nqlxbirpeylg6B9JvlWFCr72lGrc7jkqmobOlILJv(XQnGicvkqPmuPOlgd7fO(SciU5KmQIEiWOQAMN14eWWBjMx37y09cutcPcKWEIceJ2nG9RSS52UpRIEiWtn(XQfw75f4vOi(swpgGKxzzZTifd9TMOhcy)klBUvioMOTm3ant(Jh(mXEPjqlx1ngnkdqs096rQOiq9zvNIwcZc48IG8IAFh9JeWI)9pR(XQf4pUOD7fWqCZP)zzKstal(3)SkehtCcaehnVM8h1YXQO79mspq9zLqv8naXSSpw2e]] )

    storeDefault( [[Brewmaster AOE]], 'displays', 20170723.095210, [[d0tHhaGEvHxsqSlKu61QkmtQk9yKA2k8BOUjsIRjvPBlvEoP2jL2Ry3eTFe5NQsdtrnoKuSnKuzOeAWiQHJWbPshfjP6ysPJtsAHsXsjjwmfTCu9qPQEkyzQIwhvf1evv0uHyYKutxPlQixLQcxwLRdPnsv1wrsvBMcBNaFuQIpRQAAijX3PkJKG0ZiOgnjgVQsNejUfvf50OCEQ4Wswlss6BijLtBqcqxeldl9JLlSoJlWRpq8LIDkaDrSmS0pwUa7XfB7Za8s(F9vo6pstavrp0ZDW(LDNCdqhW51WqFB)IyzyPo25aFFnm032ViwgwQJDoGQOh6PMcnwcShxS9ohqRG9Cr5ffPboMbuf9qp19lILHL60eW51WqFlsX)Vvh7CaQo6HE6GeBBqcmjlZXPonbCPxgwsISVm9gBBaB1Db(8mk0XgqLBCL(I95Cl11oplCaGMZi2azZgqRG9ap2sR4oLMaAfSNl6IJzaTc2d8ylTIl6IttGT4)36kPvW8anViiVurfk9iuKaoX6tpN7nGbwUbC5SAqIST4CSxaTc2dP4)3QttGpmDL0kyEaKxrvO0JqrcqJ7mRvuWumdqxeldlDL0kyEGMxeKxQeOpMWHezeCGg(51v694Ki7(ofqRG9aK0eqv0d9(KXp6LHLbuHspcfjGeTJcnwQJv4aAIBm8pkTsF8aZdsGk22a8yBd8hBBaZyBZgqRG96xeldl1PjW3xdd9TUO8k25afkVqCiUaMOggb6QVUOlo25a1GqPChELJwuWuSTbQbHsbkyprbtX2gOgekvFCNzTIcMITnWNNrHo20eOgELJwuGyAciGPzMSbBDqCiUaMbOlILHLUd2Vmq)jlYKkbufLr)b1Z0W6mUava1mnXOCqCiUa0b4L8)qCiUaLjBWwNafkVOctEPjqht6IU4yfoWhM(XYfypUyBFgaioAwnypQLHLX(K6OMa1GqPqk()TIceJTnGZRHH(wks1m6AXCDSZb43iq)jlYKkb2I)FRFSCdiIqImusnjY2IZXEbQbHsHu8)BffmfBBa1NrHowxrFdqH6jrUHFEDLEpUptI8NNrHo2aQIEONAks1m6AXCDAcWOXsQkg3fBBVby0yjqu0m5FS9gyl()T(XYfwNXf41hi(sXofGk1xwhAhjYiSUlwHNd0vFbKyNda0CgXgqZK)Jlqniuk3Hx5OffigBBaMunJUwm3vsRG5buHspcfjabN1vCh)y5cShxSTpdqWpACNzTUI(g7CGVX(8j12BGU6R7uSZbqQXjxsK7HJrjIDoWw8)BffmfZaQCJR0xSpNBPAZuL5NuBRWZutBaroRR4oKi3Viwgwgyl()T6aeCwxXDOqJLa7XfBVZbe5SUI7qIC)IyzyjjYUO8kqGT4)3kkqmMbSv3fOHFEDLEpojYUVtbmhShp6zG9ChJygqRG9OivZORfZ1PjqniuQ(4oZAffigBBGA4voArbtPjGwb75ofZaAfSNOGP0eGg3zwROaXygqRG9eY5yYKQzYFDAc8HPFSCdiIqImusnjY2IZXEb((AyOVvin6yBd0XKasSchyl()T(XYfypUyBFgqRG9efiMMa0fXYWs)y5gqeHezOKAsKTfNJ9cuO8ciUXGYNXohyswMJtDAcOzDeJZ9DkwHdudcLcuWEIceJTnGZRHH(wxuEf7CGpm9JLlSoJlWRpq8LIDkW3xdd9Tif))wDSZbCEnm03kKgDS(uBaZb7XJEgyVygOJjDNIv4afkVOinWioexatudJafkVCL0kyEGMxeKxQ47KFKaQIEONA)y5cShxSTpdOjUXW)O0kXmGQOh6Pwin60e47RHH(wks1m6AXCDSZbkuE5djBdqmkNJNnba]] )

    storeDefault( [[Brewmaster Defensives]], 'displays', 20170723.095210, [[d0JChaGEfYlPKYUqK0RvqntQGdlz2k6Xi1nvLY1uq62svxwPDsXEf7gv7Nq9tvLHjL(nuJtvsgkjnykXWr4GsLJIirhJQCCcPfsPwkLKftLwoPEOc1tbltbwNQKYevLyQqAYiPPRYfvfxLq0ZuLQRdXgPI2kIu2mbBxv1hPc9ze10qKQVtvnscHTrjvJMeJhrCsK4wkionkNxkEorRfrcFtvs1XlObOlIJH5oX8dUM5g4tKOoqX8e4kn59u)vJBaDXjVJvw6HJDa3jB0ihNy)4gO5tqqU34I4yyUmM2aK8jii3BCrCmmxgtBarrwKLkfAmhyJ2ygm0a9mE3tmVhquKfzPoUiogMlJDGMpbb5EOLM8EYyAdqkrwKvg0y8cAGhE5oxQXoqh9XWCXwCGjVygeWu9BGxwHLlz)RmGv7Cl5gZGwpR712(EaGwZiUa5YfqQG9bF2rR09e7aK8jii3dT0K3tgtBaPc2h8zhTshYHJDGcrxu4cy0gInGlIGqGMygYaR3gGKygYRgqQdnGub7JwAY7jJDGHD740kyDa0pvRO4OiqdqJ7DRt9)jUbOlIJH5DCAfSoG9hk63BbaILMvt2O6yyEmdS(RcivW(aASdikYISVW0l9XW8awrXrrGgGJ0tHgZLX4fqsSZPZzjvgJNyDqduX4fqhJxaYX4fWngVCbKky)XfXXWCzSdqYNGGCVoeDftBGcrxOneBaxebHa9fjDihoM2a1KqP6M(vJu9)jgVa1KqPafSV6)tmEbQjHsng37wN6)tmEbmv)gWwV(9L8wTylVSclxY(xzGA6xns1F1yh4NjzUSj7AqBi2aUbOlIJH5DtgzEGXpg0hRcqLjjMvdAdXgGAaDXjVOneBGYLnzxtGcrxVX4BSdikcJEysJjHRzUbQad76eZpGnAJXRnWlRqHmVyhOMekfAPjVN6VAmEbA(eeK7rHtLrxhwlJPnGENbg)yqFSkGKyNtNZsQe3a1KqPqln59u)FIXlWvAY75eZVaQOITafxk2IP0ASFarrwKLkfovgDDyTm2b6lsa0y8cWOXCsbg3hZ7TbUstEpNy(bxZCd8jsuhOyEc8wrcRhPxSfuw)gZ7Tby0yoqu0mo5ygAaGwZiUabQjHs1n9RgP6VAmEbUstEVooTcwhW(df97nRO4OiqdqOz9LUXjMFaB0gJ3Gae6Lg37wxNQdX0gquKfz7MmY8(LFbOd0xK09etBa0AU8tSfh1yeIyAdCLM8EQ)pXnaJtLrxhw3XPvW6awrXrrGgWQDULCJzqR3R3s6TdivV3BFLxacnRV0nuOXCGnAJH0BdOQz9LUrSLXfXXWCXw6q0vGa9mEhYHJPnaDrCmm3jMFaB0gJ3GaUt2OrooX(DZzCdivW(u4uz01H1YyhG6kuiZRt1HauinXwS1RFFjVv)AIT8YkSCj7FLbQPF1iv)FIDGAsOuJX9U1P(RgJxaPc2x9)j2bOX9U1P(Rg3asfSV12gxgNkJtwg7asfSF3tSdmSRtm)cOIk2cuCPylMsRX(b6zCanM2axPjVNtm)a2OngVbbg21jMFW1m3aFIe1bkMNa0fXXWCNy(fqfvSfO4sXwmLwJ9dui6ci25KYlX0g4HxUZLASdiz9eZT77jMbbQjHsbkyF1F1y8c08jii3RdrxX0gqQG9v)vJDaPc2Vdrxu4c44gqvZ6lDJylJlIJH5bOUcfY8cqYNGGCpRzlJXlqZNGGCpRzlJziEbKky)oKdh7afIU640kyDa7pu0V3C4XjAarrwKLQtm)a2OngVbbeW8lqNMvtXwmLwJ9dikYISuTMTm2bi5tqqUhfovgDDyTmM2afIUejNDbiMvZQZLa]] )



    ns.initializeClassModule = MonkInit

end
