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

    storeDefault( [[SimC Windwalker: default]], 'actionLists', 20170829.184158, [[diK8oaqiquweiytIIrrs5uKOMfjs0UGQHrsogjSmfLNbIQPrIuxJKQ2gjv8nQunoqO4CuKSoQuMhvI7jkTpksDqfvlee5HuutKejDrseJKejCsqvEjiuzMGqUjfStQYqbHQwkOYtfMkvLTcQQVsL0Ej(lknyPoSklwrESctwKlJSzq6ZuHrJcNwvVgfnBsDBOSBGFdz4GYXjPslhvpNstxPRlQ2ofX3PqNNkA9GqP5tv1(LSOq8jraJg)PFi2BFeq8MPoMscVdJKiEmZv76dsgpntI7w1jc6LRxjGJ00zjXBMkfURY9zqoUktP(zQmLeXG)WwjKy(yFeWk(epfIpjuc4M0usGKeXG)WwjwKdhAc)blX55WwB1zQwTQ3J7Gw8enLdfk(4S7dCGNdRALLy(0R)1Pewy0XzzCGeRD5ptsc4bs)4wexcacqsyaLG)X9omscj8omsIagD8QvkoqQ6y5ptsc4inDws8MPsH7kujbCKfLZhKv8jReMzqdMgqMqyeyLjjmGsEhgjHSI3mXNekbCtAkjqsIyWFyRemOtVmWHn2QDPAv4QxI5tV(xNsSO8bdweuwMhh7KWmdAW0aYecJaRmjHbuc(h37WijKW7Wij8HYhmQgbTAiUJJDsmN7WkXdwIBYPZAkvkLWglld60lJSQWvVeWrA6SK4ntLc3vOsc4ilkNpiR4twjGhi9JBrCjaiajHbuY7WijKv8GCXNekbCtAkjqsIyWFyRelYHdnHddTpcyRot1Qv9uouO4wItGFDINdRA)(REkhkuC7I4yS0XxgShiXc95eEoSQ97VA1QgYQEpnbwClXjWVoXjWnPPu1zQE5pGjT4W4Ob(541)6ephw1kxTF)vpLdfk(KgHs6C7INdRA)(REpUdAX3hJyxeB6PQDjB1QJQQvwI5tV(xNsadTpcib8aPFClIlbabijmGsW)4EhgjHeEhgjbepAFeqc4inDws8MPsH7kujbCKfLZhKv8jReMzqdMgqMqyeyLjjmGsEhgjHSINsl(KqjGBstjbssed(dBLyroCOj8bcPtiJaB1zQwTQ3J7Gw89Xi2fXMEQAxYwTPQwzjMp96FDkXIYhmyrqzt0TmKaEG0pUfXLaGaKegqj4FCVdJKqcVdJKWhkFWOAe0QvQ0TmKaostNLeVzQu4Ucvsahzr58bzfFYkHzg0GPbKjegbwzscdOK3HrsiR4PEXNekbCtAkjqsIyWFyReQvTAvVNMalUL4e4xN4e4M0uQ6mvpqiDczeGBjob(1joNWUhyR2LSvRQALR2V)QNYHcf3sCc8Rt8CyvRC1zQEkhku8jncL052fphw1zQ(g7BcXsac7jB1Uu9SQZuTLw2jei3IVpXNPIvPHnQ20vRQ6mvBPLDcbYT47tCfMIDgSr1MUAvvNPAsDZFyWOeEI)aMpWbldehWoqMq8QZuTAvtQB(ddgLWzERnhzzPH(HzPQ97VA(ni8jncLyjn0Q97V690eyXHHmsCw7YFMKfNa3KMsvRSeZNE9VoLyCAn7n2hby1VDLWmdAW0aYecJaRmjHbuc(h37WijKW7WijmFAD1Zh7JavdrVDLyo3HvcWHrzHq8yMR21hKmEAMe3TQTeNa)6SAemcqCiibCKMoljEZuPWDfQKaoYIY5dYk(Kvc4bs)4wexcacqsyaL8omsI4XmxTRpiz80mjUBvBjob(1z1iyeG4YkEQJ4tcLaUjnLeijrm4pSvc1QEpnbwClXjWVoXjWnPPu1zQEGq6eYia3sCc8RtCoHDpWwTlzRwv1kxTF)vRw1t5qHIBjob(1jEoSQZu9(yu1MU6zQQwzjMp96FDkX40A2BSpcWQF7kHzg0GPbKjegbwzscdOe8pU3HrsiH3Hrsy(06QNp2hbQgIE7wTAkuwI5ChwjahgLfcXJzUAxFqY4PzsC3Q2sCc8RtiibCKMoljEZuPWDfQKaoYIY5dYk(Kvc4bs)4wexcacqsyaL8omsI4XmxTRpiz80mjUBvBjob(1PSIN7Ipjuc4M0usGKeXG)WwjGSQ3ttGf3sCc8RtCcCtAkvDMQvR6PCOqXTlIJXshFzWEGel0Nt45WQ2V)QhiKoHmcWTlIJXshFzWEGel0Nt4dgh3bzRoB1ZQwzjMp96FDkX40A2BSpcWQF7kHzg0GPbKjegbwzscdOe8pU3HrsiH3Hrsy(06QNp2hbQgIE7wTAZuwI5ChwjahgLfcXJzUAxFqY4PzsC3Q2sqHGeWrA6SK4ntLc3vOsc4ilkNpiR4twjGhi9JBrCjaiajHbuY7WijIhZC1U(GKXtZK4UvTLGkR4bXi(KqjGBstjbssed(dBLaYQEpnbwClXjWVoXjWnPPu1zQMu38hgmkHN4pG5dCWYaXbSdKjeV6mvRw1desNqgb42L)mjweu2LbXA8bjnINW5e29aB1UKTAfqmvNP6bcPtiJaCOVDTSiOSqZ5oX5e29aB1UKTAfZQot1dgp(iNZjWwTPZwnKxDMQhiKoHmcW5V9boyT5awM)GjoNWUhyR2LSvROA)(REpUdAX3hJyxeB6PQDjB1ZuF1(9x9aH0jKra(IYhmyrqzt0TmW5e29aB1MUAfkMvTYvNP6bcPtiJaC7I4yS0XxgShiXc95e(GXXDq2QZwTcjMp96FDkX40A2BSpcWQF7kHzg0GPbKjegbwzscdOe8pU3HrsiH3Hrsy(06QNp2hbQgIE7wTAqUYsmN7Wkb4WOSqiEmZv76dsgpntI7w1wckeKaostNLeVzQu4Ucvsahzr58bzfFYkb8aPFClIlbabijmGsEhgjr8yMR21hKmEAMe3TQTeuzfptj(KqjGBstjbssed(dBLaYQEpnbwClXjWVoXjWnPPu1zQgYQMu38hgmkHN4pG5dCWYaXbSdKjeV6mvRw1desNqgb42L)mjweu2LbXA8bjnINW5e29aB1UKTAfkD1zQEGq6eYiah6Bxllckl0CUtCoHDpWwTlzRwDQot1dgp(iNZjWwTPZwnKxDMQhiKoHmcW5V9boyT5awM)GjoNWUhyR2LSvROA)(REpUdAX3hJyxeB6PQDjB1kuF1(9x9aH0jKra(IYhmyrqzt0TmW5e29aB1MUAfkMvTYvNP6bcPtiJaC7I4yS0XxgShiXc95e(GXXDq2QZwTcjMp96FDkX40A2BSpcWQF7kHzg0GPbKjegbwzscdOe8pU3HrsiH3Hrsy(06QNp2hbQgIE7wTAkTYsmN7Wkb4WOSqiEmZv76dsgpntI7w1wckeKaostNLeVzQu4Ucvsahzr58bzfFYkb8aPFClIlbabijmGsEhgjr8yMR21hKmEAMe3TQTeuzfpfQeFsOeWnPPKajjMp96FDkX40A2BSpcWQF7kb8aPFClIlbabijmGsW)4EhgjHeEhgjH5tRRE(yFeOAi6TB1QPELLyo3HvcWHrzHq8yMR21hKmEAMe3TQdFqqc4inDws8MPsH7kujbCKfLZhKv8jReMzqdMgqMqyeyLjjmGsEhgjr8yMR21hKmEAMe3TQdFYkRekvc6LRxbsYkc]] )

    storeDefault( [[SimC Windwalker: precombat]], 'actionLists', 20170829.184158, [[ditrcaGEQuAxuPABaLMnGBsr3wu7Ks7LSBuTFbmmk8BLgkvIgSanCKYbPQ6yuX5aQwikzPI0IrXYLYdrINQAzIyDujmrQumvbnzqMUIlckDzORJK2kOYMPsQTJs9AQkFLQWNPk13Pk6XcDyjJgiFdP6KGQonIRrLKZdkEgvjpxQ(lqXYrH6NggjfaXT1qwUSjGfCDBLr9tYuce0dchYZcWh2CrGG0AyCZm1ONIay1rztmCOBqpXl3na3vjgGR)yJqB019hhYY7kuwhfQdlVyaqiXs)XgH2OpR3EdGUtBhYY76(ziaKbgDA7qwUo8CisSMTPZxoQBUqWvnBLrDDBLrDxUdz56PiawDu2edh6og6PyFP2IyxHA0PacJ(mx2yg5Jy0nxiBLrDnYMOqDy5fdacjw6(ziaKbg9iicyyO26Jo8CisSMTPZxoQBUqWvnBLrDDBLrDkGibcYIARp6PiawDu2edh6og6PyFP2IyxHA0PacJ(mx2yg5Jy0nxiBLrDnY6Lc1HLxmaiKyP7NHaqgy0JGiGXZInQdphIeRzB68LJ6MleCvZwzux3wzuNcisGGEuSr9ueaRokBIHdDhd9uSVuBrSRqn6uaHrFMlBmJ8rm6MlKTYOUgn6UbDDrfyelnsa]] )

    storeDefault( [[SimC Windwalker: sef]], 'actionLists', 20170829.184158, [[daKhfaqiffTifvTjfvgLIcNsbLzPGQBPGKDrGHPIoMGwMaEMIsMMccxJGY2uq03arNJGQ1rjzEki19iK2NIsDqsyHGWdvPMijkxKq1gjrvNKsPzsq4MQKDcQHsq0sjjpfzQkYwPK6Ruk2R0FvObtQdlAXQWJPQjRkxgAZKiFgKgnL40O61c0SPYTfA3O8BIgUcSCGNRQMUsxNKA7eIVtOmEcsNNs16jrL9tXnStLObONNoUYLlxYkCGHu4LGZiwI4XBJ2go7jw6cIaRm6pQujvOdZpw4aNHqEczGzj4u4clWPWlrEaFWwQKc)YLSFNkCyNkjolpC4RquI8a(GT0mn6bauKrO(NGqblhkcghKUOrpNrJmea1UaVAaazRrlQrJmea1UGykuJEoJ2BHlWRgaq2A0dTrhwsXb3Xx7LwouemoiDXs3wqFWlPiyezBpkDjFwNa4mILkzl7X95kbLysgwcoJyPjouey0cz6ILuaG(l5T7D44MaO4(fnSKk0H5hlCGZqidplPc)s1ap(7u3s329oCkbqX9xikDjFWzel1TWb6ujXz5HdFfIsKhWhSL8w4cIPqn6HYO9w4c8QbaKTg9Sf1Odn65mAKHaO2fS8ioUYXykuJE2IA0NcewjfhChFTxkb(KHJReaq2wYw2J7ZvckXKmS0L8zDcGZiwQeCgXska(KHg9Keaq2wsf6W8JfoWziKHNLuHFPAGh)DQBPBlOp4LuemISThLUKp4mIL6w4z1PsIZYdh(keLuCWD81EjF6CJPF5s2OJ)3s2YECFUsqjMKHLUKpRtaCgXsLGZiw6oDoJwHF5sMrle8)wsba6VelJOOZt84TrBdN9elDbrGvg9TYMVKk0H5hlCGZqidplPc)s1ap(7u3s3wqFWlPiyezBpkDjFWzelr84TrBdN9elDbrGvg9TY6w4HOtLeNLho8vikrEaFWwALqH6qbEP09KIX(g9Cg9mm6zA0hQvsjb)vcIJycwlJj7nQehGcupWOhwjfhChFTx6VsqCetWAzmzVrL4aSKTSh3NReuIjzyPl5Z6eaNrSuj4mILOvcId3OfpbRLHB0j7z0kphGLuHom)yHdCgcz4zjv4xQg4XFN6w62c6dEjfbJiB7rPl5doJyPUfwyDQK4S8WHVcrjfhChFTxYNo3y6xUKn64)TKTSh3NReuIjzyPl5Z6eaNrSuj4mILUtNZOv4xUKz0cb)Vg9mchwjfaO)sSmIIopXJ3gTnC2tS0febwz0008LuHom)yHdCgcz4zjv4xQg4XFN6w62c6dEjfbJiB7rPl5doJyjIhVnAB4SNyPlicSYOPPUDlPmuPuTBleDBb]] )

    storeDefault( [[SimC Windwalker: serenity]], 'actionLists', 20170829.184158, [[dq0Qoaqiujwejb2KqYOevCkrP2LIAyOkhJeltr6zIQyAKe5AKeQTjkr(gQuJtuI6CIsyDIsY8ar5EIkTpujDqfXcbHhkkMOOK6IcP2ijrDsHsRKKGEPOkntquv3uvANi1qbrLwkQQNsmvuXwfk(QOQSxP)IKbtQddSyr6XumzfUm0MfIplIrluDALwTOQ61cA2QQBdQDRYVPYWvfhNKqwokpNQMoIRlW2jP(ojPXdIkopiTEquL5dISFkDvkNkYdAwWFH8aK1DLEAwklQqdGXkYcNXQZ3Edvb)qKLvwThz4TeOv4JFe4XspLNc384EAEM5LfQ4P8YIkIHTpKkvMyiR78LtPvkNkrFG0pokevedBFiv4Iv)Wq1ujMXSYmztqg1d4dB1rz14HSeOZMagdpIvNRvJhYsGoddGCS6OSAt8D2eWy4rSAiZQvS6OSAUy1PbrIm7rgElb6CWtLjP7FjqRq2eKr9a(WvYehnHVo1imEKMw51nIbWObWyLkXEJ1aiowLZDyfAamwHZMGmRgYf8HRmHL4RyGA(ifbWsqIpxLk8Xpc8yPNYtHBfEv4JExaZG(YPKkzGA(ihalbj(crLx3GgaJvkP0tlNkrFG0pokevMKU)LaTIb8)uadzDh1F9KkXEJ1aiowLZDyLx3igaJgaJvQqdGXkza)VvpXqw3z1q(RNuzclXx5aWyUQazHZy15BVHQGFiYYkRotwRcQWh)iWJLEkpfUv4vHp6Dbmd6lNsQKjoAcFDQry8inTYRBqdGXkYcNXQZ3Edvb)qKLvwDMSUKsNNYPs0hi9JJcrfXW2hsfIlj5JZgN7pCQE(kts3)sGwXJm8wc0kXEJ1aiowLZDyLx3igaJgaJvQqdGXkcYWBjqRWh)iWJLEkpfUv4vHp6Dbmd6lNsQKjoAcFDQry8inTYRBqdGXkLuAvQCQe9bs)4OqurmS9HubyiRAKcpeErVvdzwDEQmjD)lbAf263lHYhCuHRjSsM4Oj81PgHXJ00kVUrmagnagRuj2BSgaXXQCUdRqdGXk8x)EjwTeCwDExtyLjSeFfduZhPiawcs85QuHp(rGhl9uEkCRWRcF07cyg0xoLujduZh5ayjiXxiQ86g0aySsjLwfxovI(aPFCuiQmjD)lbAfpHTHiLlcfjosP6EJVJnQe7nwdG4yvo3HvEDJyamAamwPcnagRie2gIwTlIvtIJwD(2B8DSrf(4hbES0t5PWTcVk8rVlGzqF5usLmXrt4RtncJhPPvEDdAamwPKsNLkNkrFG0pokevedBFivYXQ5Iv)Wq1ujMXSYC6hycDbeQW1eA1zB1rz15y1pmunvIzmRm7jSnePCrOiXrkv3B8DSHvdjiz1pmunvIzmRmhz9epLlcvKaguRoBRokRgyiRAKcpeErVvdzw90kts3)sGwj9dmHUacv4AcRKjoAcFDQry8inTYRBedGrdGXkvI9gRbqCSkN7Wk0aySceFGj0fqS68UMWktyj(kgOMpsraSeK4ZvPcF8Japw6P8u4wHxf(O3fWmOVCkPsgOMpYbWsqIVqu51nObWyLskn3LtLOpq6hhfIkIHTpKk5y15y1OkkyFEWX8GTx4EjuXDSJY4uJmRokRonisK5hg69bmK6XThzMHWG98wnKLRvp1QJYQ9iHk1Db(zYISP8OuPhJvZvRMNvNTvhLvNJvBCU)WP6nZw)Eju(GJkCnHZmegSN3Q5QvRy1qcswnWqw1ifEi8IERMRwTIvNTvNDLjP7FjqRez9epLlcvKag0kzIJMWxNAegpstR86gXay0aySsfAamwrLxpXB1UiwTkhWGwzclXxzpcYybpKCvQWh)iWJLEkpfUv4vHp6Dbmd6lNsQe7nwdG4yvo3HvEDdAamwPKsNLlNkrFG0pokevedBFivYXQZXQ5IvJQOG95bhZd2EH7Lqf3XokJtnYSAibjRonisK50VZn(bEYCWJvdjiz1PbrIm7rgElb6mdHb75TAiZQvS6ST6OS6CSAJZ9hovVz263lHYhCuHRjCMHWG98wnxTAfRgsqYQbgYQgPWdHx0B1C1QvS6ST6SRmjD)lbALiRN4PCrOIeWGwjtC0e(6uJW4rAALx3igaJgaJvQqdGXkQ86jER2fXQv5aguRohLSRmHL4RShbzSGhsUkv4JFe4XspLNc3k8QWh9UaMb9LtjvI9gRbqCSkN7WkVUbnagRusPZIYPs0hi9JJcrfXW2hsfGHSQrk8q4f9wnxZ1QZJvhLvZfR(HHQPsmJzLz)ZE3Ejugg4qQW1ewzs6(xc0k(N9U9sOmmWHuHRjSsS3ynaIJv5Chw51nIbWObWyLk0aySI8S3TxIvNHbo0QZ7AcRWh)iWJLEkpfUv4vHp6Dbmd6lNsQKjoAcFDQry8inTYRBqdGXkLuAfELtLOpq6hhfIkIHTpKkCXQFyOAQeZywzMf4JVxcv(bdKs19gwDuwDAqKiZSaF89sOYpyGuQU3yE4u9S6OS60GirM9idVLaDMHWG98wnxZ1QvPkts3)sGwHf4JVxcv(bdKs19gvI9gRbqCSkN7WkVUrmagnagRuHgaJv4h4JVxIvRcbd0QZ3EJk8Xpc8yPNYtHBfEv4JExaZG(YPKkzIJMWxNAegpstR86g0aySsjLwrPCQe9bs)4OqurmS9HubyiRAKcpeErVvZ1CT68uzs6(xc0kS1VxcLp4OcxtyLmXrt4RtncJhPPvEDJyamAamwPsS3ynaIJv5ChwHgaJv4V(9sSAj4S68UMqRohLSRmHL4RyGA(ifbWsqIpxLk8Xpc8yPNYtHBfEv4JExaZG(YPKkzGA(ihalbj(crLx3GgaJvkP0ktlNkrFG0pokevedBFiv4Iv)Wq1ujMXSYmlWhFVeQ8dgiLQ7nS6OS60GirMzb(47LqLFWaPuDVX8WP6z1rz1adzvJu4HWl6TAUA1kvMKU)LaTclWhFVeQ8dgiLQ7nQe7nwdG4yvo3HvEDJyamAamwPcnagRWpWhFVeRwfcgOvNV9gwDokzxHp(rGhl9uEkCRWRcF07cyg0xoLujtC0e(6uJW4rAALx3GgaJvkP0k5PCQe9bs)4OqurmS9HuHlw9ddvtLygZkZ(N9U9sOmmWHuHRjSYK09VeOv8p7D7LqzyGdPcxtyLyVXAaehRY5oSYRBedGrdGXkvObWyf5zVBVeRoddCOvN31eA15OKDf(4hbES0t5PWTcVk8rVlGzqF5usLmXrt4RtncJhPPvEDdAamwPKsROsLtLOpq6hhfIkIHTpKkCXQFyOAQeZywzo9dmHUacv4AcRmjD)lbAL0pWe6ciuHRjSsM4Oj81PgHXJ00kVUrmagnagRuj2BSgaXXQCUdRqdGXkq8bMqxaXQZ7AcT6CuYUYewIVIbQ5Juealbj(CvQWh)iWJLEkpfUv4vHp6Dbmd6lNsQKbQ5JCaSeK4levEDdAamwPKsQK1yeqWNuikPfa]] )

    storeDefault( [[SimC Windwalker: ST]], 'actionLists', 20170829.184158, [[duecAaqikblskvYMiiJsaDkkPULqq7Iunmc1XOultO8mHuMgLqUMqQ2grb9nkjJtkvQZruK1rjunpII6EeL2hc6GeulKa9qHQjsuGlkaBuiuNuizLcb6LcHmtkHYnru7KugQqalvGEkvtLOARcrFLOq7f8xImyvomulwqpMIjlPlJAZiWNfLrJqNwvRwkv51sXSL42s1Uv8BsgoHCCPuvlhPNlY0HCDr12Ls(oLOXlLY5rK1lLkMpbSFLgSb5GRH7m4(3JVNm(t1sCPHPw89C5GldycW5feii4b5cJtmOftSTvITkw00fltrpMyzcCxeBEC5Bhm6vdOftgktGlSb9QjbYbnBqo4bm4Wcxbbbx4WV8isGBWLIe2GE1iv(ec8OM6BWiff8rnm4Kv1iXunCNbhCnCNbpoUu2tyd6vZEwSpHaxyAwc8b3zzBx(3JVNm(t1sCPHPw89IldAxGhKlmoXGwmX2wzlg8GCsLtnCcKdiWJtKnnKvT4opiieCYQQgUZG7Fp(EY4pvlXLgMAX3lUmaqGwmqo4bm4Wcxbbb3n0xecCdXx3KtP8G2tMLDp79eAVa3ZOuLQYYrN(PFYKs5JuZBA0PCh)tApz3t8EciWEbUhMIEcWgKEcr)gwsrGeIilz5p1IIw15bhw46EcTNrPkvLLJEcr)gwsrGeIilz5p1IIw1PCh)tApz3t8EwVNacShpmnJKUjNs5bTNmVx0fVN1GlC4xEejW5HPzF78tMex(2Ek4rn13Grkk4JAyWjRQrIPA4odo4A4odEadtZ(25NS9cO8T9uWdYfgNyqlMyBRSfdEqoPYPgobYbe4XjYMgYQwCNheecozvvd3zWbeOfnqo4bm4Wcxbbb3n0xecCdXxVJBBViCpdXx3KtP8G2Jqz3ZEpH2JhMMrsh9DwcPK6422Jqz3tSE0bx4WV8isGJPg8WsifLYdc8OM6BWiff8rnm4Kv1iXunCNbhCnCNbxyQbp8EYvukpiWdYfgNyqlMyBRSfdEqoPYPgobYbe4XjYMgYQwCNheecozvvd3zWbeOzrGCWdyWHfUcccUBOVie4wypruULuMPQBRJ(mMkjcx67j0E8W0ms6OVZsiLuh32EYSS7jwp67j0EgIVEh32Er4EgIVUjNs5bThHYUxmWfo8lpIe4OpJPsIWLo4XjYMgYQwCNheecozvnsmvd3zWbpQP(gmsrbFuddUgUZGl)Zy6EraCPdUW0Se4gsMclHW0mgLK1g8GCHXjg0Ij22kBXGhKtQCQHtGCabECsMclhtZyuceeCYQQgUZGdiql6GCWdyWHfUcccUBOVie4wypeUWdspXuEEejDEWHfUUNacSNrPkvLLJEIP88is6uUJ)jThHYUNTyWfo8lpIe4je9ByjfbsiISKL)ulkAf8OM6BWiff8rnm4Kv1iXunCNbhCnCNb3r0VH3trWEiI8EY4p1IIwbpixyCIbTyITTYwm4b5KkNA4eihqGhNiBAiRAXDEqqi4KvvnCNbhqGMmeKdEadoSWvqqWDd9fHapW9cCpdXx3KtP8G2Jqz3lA7j0E8W0ms6MCkLh0Eek7EwK49SEpbeypdXx3KtP8G2Jqz3l67z9EcTxG7zH9q4cpi9et55rK05bhw46EciWEgLQuvwo6jMYZJiPt5o(N0Eek7EYW9SgCHd)YJibo9t)KjLYhPM30aECISPHSQf35bbHGtwvJet1WDgCWJAQVbJuuWh1WGRH7m4b)0pz755ZEr0BAaxyAwcCdjtHLqyAgJsYAdEqUW4edAXeBBLTyWdYjvo1WjqoGapojtHLJPzmkbccozvvd3zWbeOzfih8agCyHRGGG7g6lcbocx4bPNykppIKop4Wcx3tO9SWEC7N)IeXv9k9NMFYKiQOJKr1IP7j0EgLQuvwo6jMYZJiPt5o(N0Eek7ErFpH2JhMMrsh9DwcPK6422JW9IbUWHF5rKaNGpHsskcKiiNsc8OM6BWiff8rnm4Kv1iXunCNbhCnCNbpI)ekTNIG9I4CkjWdYfgNyqlMyBRSfdEqoPYPgobYbe4XjYMgYQwCNheecozvvd3zWbeO1Ub5GhWGdlCfeeC3qFriWr4cpi9et55rK05bhw46EcTh3(5VirCvVs)P5NmjIk6izuTy6EcTxG7zuQsvz5ONykppIKoL74Fs7rOS7zh99eqG9mkvPQSC0tmLNhrsNYD8pP9Kzz3ZI2Z69eApEyAgjD03zjKsQJBBpc3lg4ch(LhrcCc(ekjPiqIGCkjWJAQVbJuuWh1WGtwvJet1WDgCW1WDg8i(tO0Ekc2lIZPK2lqBRbpixyCIbTyITTYwm4b5KkNA4eihqGhNiBAiRAXDEqqi4KvvnCNbhqGMmbYbpGbhw4kii4UH(IqGBH9q4cpi9et55rK05bhw46EcThpmnJKo67Sesj1XTThH7fdCHd)YJibobFcLKueirqoLe4rn13Grkk4JAyWjRQrIPA4odo4A4odEe)juApfb7fX5us7fymRbpixyCIbTyITTYwm4b5KkNA4eihqGhNiBAiRAXDEqqi4KvvnCNbhqGMTyqo4bm4Wcxbbb3n0xecClShcx4bPNykppIKop4Wcx3tab2ZOuLQYYrpXuEEejDk3X)K2Jqz3l6GlC4xEejWPF6NmPu(i18MgWJtKnnKvT4opiieCYQAKyQgUZGdEut9nyKIc(OggCnCNbp4N(jBppF2lIEtZEbABn4ctZsGBizkSectZyuswBWdYfgNyqlMyBRSfdEqoPYPgobYbe4XjzkSCmnJrjqqWjRQA4odoGanBBqo4bm4Wcxbbbx4WV8isGBjXNw(jtQsXzQrsu(yicEut9nyKIc(OggCYQAKyQgUZGdUgUZGlJeFA5NS9KbuCMA2lcKpgIGhKlmoXGwmX2wzlg8GCsLtnCcKdiWJtKnnKvT4opiieCYQQgUZGdiqZogih8agCyHRGGG7g6lcbUf2teLBjLzQ626HfSPrLJKAEtZEcTNH4R3XTTxeUNH4RBYPuEq7rOS7zVNq7LyKuOAYt6ONPXSLSirM9iCpX7j0EbUNf2lXiPq1KN0rptTLjPyIm7r4EI3tab2dHl8G0tmLNhrsNhCyHR7jGa7fMtab6HQgjruLrpx0EwdUWHF5rKapSGnnQCKuZBAapor20qw1I78GGqWjRQrIPA4odo4rn13Grkk4JAyW1WDgCblytJkhTxe9MgWfMMLa3qYuyjeMMXOKS2GhKlmoXGwmX2wzlg8GCsLtnCcKdiWJtYuy5yAgJsGGGtwv1WDgCabA2rdKdEadoSWvqqWDd9fHapW9Wg03IL4H7pN2Jqz3lA7jGa7f4EH5eqGEOQrsevz0ZfTNq7zi(6DCB7fH7zi(6MCkLh0Eek7EI3Z69SEpH2Zc7jIYTKYmvDB9KOFMFYKmu8WsnVPzpH2lXiPq1KN0rptJzlzrIm7r4EIbx4WV8isGNe9Z8tMKHIhwQ5nnGh1uFdgPOGpQHbNSQgjMQH7m4GRH7m4UOFMFY2lofp8Er0BAapixyCIbTyITTYwm4b5KkNA4eihqGhNiBAiRAXDEqqi4KvvnCNbhqGMTfbYbpGbhw4kii4UH(IqGZTF(lsex1rezjUlIPkAsYGfHnpsr3tO9cZjGaDerwI7IyQIMKmyryZJuu9ecBA2Jqz3ZwM2tO94HPzK0rFNLqkPoUT9iCVObUWHF5rKa3qXMMYpzsThUYsLpJiA(jd8OM6BWiff8rnm4Kv1iXunCNbhCnCNbpofBAk)KTxeex59SyFgr08tg4b5cJtmOftSTv2IbpiNu5udNa5ac84eztdzvlUZdccbNSQQH7m4ac0SJoih8agCyHRGGG7g6lcbo3(5VirCvhrKL4UiMQOjjdwe28ifDpH2lmNac0rezjUlIPkAsYGfHnpsr1tiSPzpcLDpBlApH2ZOuLQYYrpXuEEejDk3X)K2tM3ZoA7j0EiCHhKEIP88is68GdlCDpH2JhMMrsh9DwcPK6422JW9Ig4ch(LhrcCdfBAk)Kj1E4klv(mIO5NmWJAQVbJuuWh1WGtwvJet1WDgCW1WDg84uSPP8t2ErqCL3ZI9zerZpz7fOT1GhKlmoXGwmX2wzlg8GCsLtnCcKdiWJtKnnKvT4opiieCYQQgUZGdiqZwgcYbpGbhw4kii4UH(IqGJnOVflXd3FoThHYUx02tO9SWEIOClPmtv3wpj6N5NmjdfpSuZBAax4WV8isGNe9Z8tMKHIhwQ5nnGh1uFdgPOGpQHbNSQgjMQH7m4GRH7m4UOFMFY2lofp8Er0BA2lqBRbpixyCIbTyITTYwm4b5KkNA4eihqGhNiBAiRAXDEqqi4KvvnCNbhqGMTvGCWdyWHfUcccUBOVie4gIVEh32Er4EgIVUjNs5bThH7zVNq7zH9er5wszMQUTonpr8NmP2dxzjl)PcUWHF5rKaNMNi(tMu7HRSKL)ubpQP(gmsrbFuddozvnsmvd3zWbxd3zWdMNi(t2ErqCL3tg)PcEqUW4edAXeBBLTyWdYjvo1WjqoGapor20qw1I78GGqWjRQA4odoGan72nih8agCyHRGGG7g6lcbEG7zi(6MCkLh0EeUN9EciWEH5eqGEOQrsevz0ZfTNacSxG7HWfEq68W0SVD(jtIlFBpvNhCyHR7j0EgLQuvwo68W0SVD(jtIlFBpvNYD8pP9K59mkvPQSC0j4tOKKIajcYPK0PCh)tApR3Z69eAVa3lW9mkvPQSC0PF6NmPu(i18MgDk3X)K2JW9S3tO9cCplShMIEcWgKEcr)gwsrGeIilz5p1IIw15bhw46EciWEgLQuvwo6je9ByjfbsiISKL)ulkAvNYD8pP9iCp79SEpbeypdXx3KtP8G2JW9ITN17j0EbUNrPkvLLJobFcLKueirqoLKoL74Fs7r4E27jGa7zi(6MCkLh0EeUx02Z69eqG9er5wszMQUTo6ZyQKiCPVN17j0EwypruULuMPQBRhwWMgvosQ5nnGlC4xEejWdlytJkhj18MgWJtKnnKvT4opiieCYQAKyQgUZGdEut9nyKIc(OggCnCNbxWc20OYr7frVPzVaTTgCHPzjWnKmfwcHPzmkjRn4b5cJtmOftSTv2IbpiNu5udNa5ac84KmfwoMMXOeii4KvvnCNbhqGMTmbYbpGbhw4kii4UH(IqGZdtZiPJ(olHusDCB7r4E2GlC4xEejWneFjlXTyWJAQVbJuuWh1WGtwvJet1WDgCW1WDg84e)9KrClg8GCHXjg0Ij22kBXGhKtQCQHtGCabECISPHSQf35bbHGtwv1WDgCabAXedYbpGbhw4kii4UH(IqGZdtZiPJ(olHusDCB7r4E2GlC4xEejWneFPWCAcbEut9nyKIc(OggCYQAKyQgUZGdUgUZGhN4VNG50ec8GCHXjg0Ij22kBXGhKtQCQHtGCabECISPHSQf35bbHGtwv1WDgCabAXSb5GhWGdlCfeeC3qFriWTWEIOClPmtv3wh9zmvseU03tO9cCpdXxVJBBViCpdXx3KtP8G2Jqz3l2EciWE8W0ms6OVZsiLuh32EY8E27zn4ch(LhrcC0NXujr4sh84eztdzvlUZdccbNSQgjMQH7m4Gh1uFdgPOGpQHbxd3zWL)zmDViaU03lqBRbxyAwcCdjtHLqyAgJsYAdEqUW4edAXeBBLTyWdYjvo1WjqoGapojtHLJPzmkbccozvvd3zWbeOflgih8agCyHRGGGlC4xEejWneFjlXTyWJAQVbJuuWh1WGtwvJet1WDgCW1WDg84e)9KrClEVaTTg8GCHXjg0Ij22kBXGhKtQCQHtGCabECISPHSQf35bbHGtwv1WDgCabAXIgih8agCyHRGGGlC4xEejWneFPWCAcbEut9nyKIc(OggCYQAKyQgUZGdUgUZGhN4VNG50eAVaTTg8GCHXjg0Ij22kBXGhKtQCQHtGCabECISPHSQf35bbHGtwv1WDgCabiWDd9fHahqaa]] )

    storeDefault( [[SimC Windwalker: CD]], 'actionLists', 20170829.184158, [[dq0VlaqieOnHQ0Oiv1PivzwKkXTucL2fPmmuvhtsTmr4zKk10ivsxdvsBdb4BOkghIkDoevTovX8qL4EKk2hIkoicAHiupevQjQeYfvQyJkHQgPsL0jfrDtuXoPKLQe9uHPIiBve5RkvQgRsOYBvQe3vPszVq)LedgPdRYIPupMktwIld2Ss6ZkLrljNMIxRu1Sf1Tvv7MOFRy4KKJJaA5eEovnDPUUiTDeLVJqgVsW5vLwVsOy(Ku7hLXAKeglcwV0CJeJH19bmcZNBgD3nYcrxEpiEyuUxeglHmCEaTsWVMh(8Kq3A8jpxtWN8yeoHrvJbge6AZi9ij0QgjHXoYZodfKymcNWOQXONTTmO5MjxgIKEmi02Kn9lggjzZEqzHuqIrYYIXD9iWqosadotjPtyDFadmSUpGrYsYM9aJU4sbPUWODfWO7ELPbgLKzdeySeYW5b0kb)AEQ5JXsWpPch4rsyJb3vGBpNHm4dYgTXGZuSUpGb2OvcKeg7ip7muqIXiCcJQgd9zu3m5YqKuZdcqA6xnb8pJ0ZOKdJwZNrvRMrTtxx18GaKM(vlvfJQhJQwnJsqgTVmiBnpiaPPF1a5zNHcgeABYM(fdVkW1GqzwvSHwCVxgdURa3EodzWhKnAJbNPK0jSUpGbgw3hWqTBD90TU5kaQ3vtd)NAUwxtE(pppppppp118FsqaK)55555rD1UeQaxdcgDwzuIHwCVxE3uxPwGbHInpgY7d64vbUgekZQIn0I79YySeYW5b0kb)AEQ5JXsWpPch4rsyJrYYIXD9iWqosadotX6(agyJw6gjHXoYZodfKymcNWOQXqFg1oDDvZdcqA6xTuvmkVmkbzuGatnQubfnVkW1GqzwvSHwCVxMr1JrvRMr1Nrbcm1Osfu08QaxdcLzvXgAX9EzgLxgvFgTnFGr5cJYvgvTAg1ntUmej18GaKM(vta)Zi9mkx0HrjxgvpgvpgvTAgLGmAFzq2AEqast)QbYZodfgvTAgTpXg0AT5dk9OumaJYfDyu3m5YqKuZdcqA6xnb8pJ0JbH2MSPFXGmZLvMvfhCEidEVsplyKEm4UcC75mKbFq2OngCMssNW6(agyyDFad1U11t36MRaOExnn8FQ1vE4xx)8888888uxZ)jbbq(NNNNNh1v7ssMlZOZkJYnCEidEpJsAwWi97M6k1cmiuS5XqEFqhYmxwzwvCW5Hm49k9SGr6XyjKHZdOvc(18uZhJLGFsfoWJKWgJKLfJ76rGHCKagCMI19bmWgT0vKeg7ip7muqIXiCcJQgJE22YGMBMCzis6XGqBt20VyyNNPOSMkEXizzX4UEeyihjGbNPK0jSUpGbgw3hWG48mfgDXNkEXyjKHZdOvc(18uZhJLGFsfoWJKWgdURa3EodzWhKnAJbNPyDFadSrlUIKWyh5zNHcsmgHtyu1y0Z2wg0CZKldrspgeABYM(fdBq4bXEJCdJKLfJ76rGHCKagCMssNW6(agyyDFadIbHhe7nYnmwcz48aALGFnp18Xyj4NuHd8ijSXG7kWTNZqg8bzJ2yWzkw3hWaB0IaqsySJ8SZqbjgJWjmQAmCvgT)TaJUyzuxLrZLkeGSzuYrhgTMr5Lrbji2E1AZhu6r5FlWOKJomkFnUIbH2MSPFX4eUtck9ieGSXizzX4UEeyihjGbNPK0jSUpGbgw3hWGqH7KaJsAecq2ySeYW5b0kb)AEQ5JXsWpPch4rsyJb3vGBpNHm4dYgTXGZuSUpGb2Ofpijm2rE2zOGeJbNBbZp9t6eBq7XibgHtyu1y0Z2wg0CZKldrspJYlJQpJsqg9eTz9CT22Lbf7uHV1a5zNHcJYlJceyQrLkOOvzkfqQ8pFdcVY6iSnLciv6j1vXO8YOeKrvjaYu2CfTATEsDvkZQsbUUIr1ddcTnzt)IrpPUkLzvPaxxHb3vGBpNHm4dYgTXGZus6ew3hWaJKLfJ76rGHCKagw3hWG0K6Qy0zLrxeCDfgek28y4EDzqPpXg0EDQ1L)TGI71LbL(eBq71jbglHmCEaTsWVMNA(ySe8tQWbEKe2yW9RldKoXg0EKym4mfR7dyGnArUijm2rE2zOGeJr4egvng9STLbn3m5YqK0ZO8YO6ZOeKrprBwpxRTDzqXov4BnqE2zOWO8YOeKrbcm1Osfu0QmLciv(NVbHxzDe2MsbKk9K6Qyu9WGqBt20Vy0tQRszwvkW1vyKSSyCxpcmKJeWGZus6ew3hWadR7dyqAsDvm6SYOlcUUIr1Vwpmwcz48aALGFnp18Xyj4NuHd8ijSXG7kWTNZqg8bzJ2yWzkw3hWaB0I8ijm2rE2zOGeJbNBbZp9t6eBq7XibgHtyu1y0Z2wg0CZKldrspJYlJQpJEI2SEUwB7YGIDQW3AG8SZqHr5Lr1Nr1Nr7ldYwZdcqA6xnqE2zOWO8YOUzYLHiPMheG00VAc4FgPNr5IomAnJQhJQwnJ6QmAUuHaKnJso6WOjyu9yuEzu9zu3m5YqKuZ3cZEqzwv6kqHiJSKhrrta)Zi9mkxyuYLrvRMrDZKldrsTvJV9kZQYAQ4vta)Zi9mkx0Hr1vgvpgLxg1ntUmej1egVrUP4tLk7nU9Ac4FgPNr5cJYdJYlJsqgvLaitzZv0Q16j1vPmRkf46kgvpmi02Kn9lg9K6QuMvLcCDfgCxbU9CgYGpiB0gdotjPtyDFadmswwmURhbgYrcyyDFadstQRIrNvgDrW1vmQ(j0ddcfBEmCVUmO0NydAVo16Y)wqX96YGsFInO96KaJLqgopGwj4xZtnFmwc(jv4apscBm4(1LbsNydApsmgCMI19bmWgBmcvGZCzZI5AZirReea5Xgr]] )

    storeDefault( [[SimC Windwalker: serenity opener]], 'actionLists', 20170829.184158, [[diuCiaqivKArKuLnjaJsfrNsbQBPaPDjuddv1Xe0Yuf9mkvX0qvsUgLQ02OuP(gjY4iPQoNceRtfjZdvjUhjQ9HQuhuGwOQWdPuMiLk5IKu2iLk6KcOxsPcZKKk6MQs7evgkjvyPKKNsmvvvBvb8vkv1EL(lLmyQCyqlwipMutwrxgzZQkFwfgTc60qETcnBrDBvA3q9BugojSCGNtX0v66Iy7QO(oQIXRIW5fP1JQKA(KuP9tv3W(xrnmmktZgvHdEPkc6AZ7Spcp5bMhjWP8odbimAt9oMcctGkQOmbnu5EYpuj(Q)ZbjoSIOG0iygXRHlIHl3t7EqQeuVig20)Yf2)kQHHrzA2hvenaPyRCAVtbGoBDONXHXl6GawkG5R3fG3rycCKgRtaacVENYEhHjWrA8fEcVlaVtpefRtaacVEhV4DHExaE3P9UOKVVydbimAtJtu4Db4DAglpz8GJ)qM1yX(S(saPXa6cryJ3Xlk7D8RemcLrBALfDqalfW8TITHKE8LDMUeEBuLx2CaiGdEPkvceprA4YavWmmvHdEPk)Odc4DQdy(wji4WurNQZK1cbh0AuoSIkktqdvUN8dvkKFfvKHLa0KP)DRylvNPFi4GwtFu5Ln5GxQs3Y9S)vuddJY0SpQiAasXwrpefFHNW7guVtpefRtaacVEhVv27c9Ua8octGJ04fDjRLzDHNW74TYEh)y7TsWiugTPvGanetwldai8wjq8ePHldubZWuLx2CaiGdEPkv4GxQsqGgIjV7NbaeEROIYe0qL7j)qLc5xrfzyjanz6F3k2gs6Xx2z6s4TrvEzto4LQ0TC2t)ROgggLPzFur0aKITIMXYtgp44pKznwSpRVeqAmGUqe24D827cRemcLrBAfnmNTG6fXWwzKzRyBiPhFzNPlH3gv5Lnhac4GxQsfo4LQydMZExq9IyyVtDImBLGGdtfm8skREc6AZ7Spcp5bMhjWP8oB2L6vrfLjOHk3t(HkfYVIkYWsaAY0)UvceprA4YavWmmv5Ln5GxQIGU28o7JWtEG5rcCkVZMD1TC8Q(xrnmmktZ(OIObifBLLDCKPynJLNmEWgVlaV7KENMXYtgp44pKznwSpRVeqAmGUqe24D827c9UbxjyekJ20kgcqy0Mwjq8ePHldubZWuLx2CaiGdEPkv4GxQIqacJ20kQOmbnu5EYpuPq(vurgwcqtM(3TITHKE8LDMUeEBuLx2KdEPkDlN92)kQHHrzA2hvenaPyRa1l6mzry6IiJ3XlEN94Db4DrjFFXgcqy0MgNOOsWiugTPvaidcFyzsWwJi9yfBdj94l7mDj82OkVS5aqah8svQeiEI0WLbQGzyQch8svuHmi8H3jjyVZoq6XkbbhMk6uDMSwi4GwJYHvurzcAOY9KFOsH8ROImSeGMm9VBfBP6m9dbh0A6JkVSjh8sv6wo7U)vuddJY0SpQiAasXwjk57l2qacJ204efvcgHYOnTIzbOrYI9zTdjlEq4zMbMvceprA4YavWmmv5Lnhac4GxQsfo4LQilansEh7Z72HK3zFeEMzGzfvuMGgQCp5hQui)kQidlbOjt)7wX2qsp(YotxcVnQYlBYbVuLULtP(xrnmmktZ(OIObifBLt6DN27uaOZwh6zCyCugQhzjR1isp6Dd27cW7oP3PaqNTo0Z4WyZcqJKf7ZAhsw8GWZmdm9UbxjyekJ20krzOEKLSwJi9yfBdj94l7mDj82OkVS5aqah8svQeiEI0WLbQGzyQch8svEKH6rwY6D2bspwji4WurNQZK1cbh0AuoSIkktqdvUN8dvkKFfvKHLa0KP)DRylvNPFi4GwtFu5Ln5GxQs3YP(9VIAyyuMM9rfrdqk2kAglpz8GJbidcFyzsWwJi9ymGUqe24D827c9o1vD9UOKVVydbimAtJNmEWvcgHYOnTYhYSgl2N1xciTITHKE8LDMUeEBuLx2CaiGdEPkv4GxQIDImRX7yFENDMasReeCyQGWlbajkwLdROIYe0qL7j)qLc5xrfzyjanz6F3kbINinCzGkygMQ8YMCWlvPB3kIgGuSv62ca]] )


    storeDefault( [[Windwalker Primary]], 'displays', 20170723.095210, [[da0iiaqlsLyxqrQHjvoMuAzsrpdkQPrQKUgPQABKQY3ivKXrQOohPczDKk19ivqhuQAHkYdjKjcfXfvHnQO8rfvgjPkojb9scWmLcUjb0oP0pHOHsshLubwkb6PGPcvxLuL2kPc1xvu1AHIK9kgSk1HLSyk8yuAYQKlR0MPsFgknAQ40i9Aiy2kCBsz3O63igoKoUuOLt0ZPQPRQRJITtO(ofnEOW5jX6Hq7xfDAdEa2c9Pe(mc)HxzSbqQx8geApc8Le7(QIvJrazXXUICwweYuGgzwMTFqXY1w(hGnGcsxx)(Ik0Ns4(y7cGbsxx)(Ik0Ns4(y7cGkPALurilHdue3y1FxankV)iwmhOrMLzVevOpLW9zkGcsxx)(4Le7((y7cOdywM1h8yBdEGdEzm2RmfON9Pe(5Ddu)hRohWwABaGQj68EEk)YSgiSsDFEJkxwIMr9beChB53yB21QV2UomhayLu0pWt1wDyx(yBg8ah8YySxzkqp7tj8Z7gO(pwDkGT02aavt0598u(LznqyL6(8(ADlMXhqWDSLFJTzxR(A76WC(8b8oetWK(So9hzkagiDD97JxsS77JTlG3HycM0N1PN5jzkWxsS73ZzDiYatiXXrkqbfoNEWdOeRU0uFDbWi2UacyvmO8lkh75n8kJn2MbqWONZ6qKbWrQkOW50dEawIMr9QIpIra2c9PeEpN1HidmHehhPadiIGQCEJtcmpLFzwdew55DpYJaEhIjGNPanYSmlMqLl7tj8ackCo9GhGZOjKLW9XQRb8O7ymBuEhrKbrg8avSTbKX2gaBSTbmITnFaVdXuuH(uc3NPayG011VFpJSITlqXilCf0nGbJRBaTcJEMNeBxGAG6u9dZsXRk(i22a1a1PahIPQ4JyBduduNserZOEvXhX2gWwABG5P8lZAGWkpVvLuTsQeOrgklc6yQhELXgOcudZsXRkwntbet9ud6G(k4kOBaJaSf6tj8(bflpGOdl(HGbUOE0rPGRGUbQayY6wmJptbKfh7IRGUbkd6G(kbkgzjqkFZuaaDzP1GIy9ucp2M6thfabJze(due3yBBgqbPRRFFH8lkB9ePp2Ua1a1PWlj29vfRgBBaJbfreNBqm7hJyeqUJaIoS4hcgWJUJXSr5DIrGAG6u4Le7(QIpITnaLLWXueIwST6pqJmlZEjKFrzRNi9zkGlH)boWavUEVzPeOyKLqUlbxbDdyW46g4lj29Nr4p8kJnas9I3Gq7rabwyq1y0oVXPABSyUlaLLWb0ILYXgR(daSsk6hiqnqDQ(HzP4vfRgBBGgzwM9silHdue3y1FxaujvRKkZi8hOiUX22maQCzjAg13R2qaGQj68EEk)YSgiSsDFEJkxwIMr9bmguerCUbXmgb0km6pITlaEnw(FEpNKWGgBxGVKy3xv8rmci4o2YVX2SRvN601UMy6wm3PZTb8oetbSkgu(fLJ1NPaAfgaESTbO8lkB9ezpN1HidiOW50dEavjvRKkN3Ik0Ns4N39mYkqa2c9Pe(mc)bkIBSTnduduNserZOEvXQX2gW7qmfYVOS1tK(mfOgOof4qmvfRgBBGAywkEvXhzkG3Hy2FKPaEhIPQ4JmfGLOzuVQy1yeabJze(hqf)8gkU)82wsjXmGcsxx)(cyYhRU0gabJze(dVYydGuV4ni0EeqJYb8y7c8Le7(Zi8hOiUX22mG3HyQkwntbyl0Ns4Zi8pGk(5nuC)5TTKsIzGIrwa6ogcXKy7cCWlJXELPaEQg6y7rEeBZakiDD973ZiRy7cGbsxx)(cyYhBBavjvRKkN3Ik0Ns4b(sIDFFGVKy3FgH)buXpVHI7pVTLusmdCTUfZ47vBiaq1eDEppLFzwdewPUpVVw3Iz8b8oeZEgzjK7sIraVdXSN5jzkG3HyIxsS77ZuGIrw9CwhImWesCCKcSHJz4bAKzz2Rze(due3yBBgadKUU(9fYVOS1tK(y7c0iZYSxcyYNPaAuEpZtITlqXil9YPFa0rPSY8ja]] )

    storeDefault( [[Windwalker AOE]], 'displays', 20170723.095210, [[da0diaqlssSlir1WKQoMuAzQipJQstJKKUgbyBuvPVrsKXrsuNJKqwhjPUhjbDqPYcvHhsqtesKlQiBur5Juv1ijP4KeQxsvfZKKQBsaTtQ8tiAOKYrjjWsjqpfmvO6QKuARKeQVcjSwirzVIbdHdlzXK4XO0KvPUSsBMQ8zi1OPOtJ0RvunBfUnPA3O63igouoovflNONtPPRQRJITtiFNcJhs68sX6vrTFvYPn4bylSNs4Zi8h(MXgaPAXvxSBkWxs07RjslkbKfh9k0CzNNJa(WSmB3GIMRV8paBGgKEE29fwypLWTX1havKEE29fwypLWTX1hWhMLzVfZs4a98gNa6dynjgDmYsm3JeLa(WSm7TWc7PeUnhbAq65z3hVKO33gxFavaZYS2GhxBWdmXlLXENJaDSpLWVqOo1(XPYbCL(gaO6cVqGck)2OgZxPQVqGjxwIUs9beChBz34o13632(EFdaSsk2h4P6RkSpFCNcEGjEPm27CeOJ9Pe(fc1P2povkGR03aavx4fcuq53g1y(kv9fI71RygFab3Xw2nUt9T(TTV3385dynjgGb9zn7MYraur65z3hVKO33gxFaRjXamOpRzhZtYrGIrwI5Ee8gSnGcJNxGM4uLt9ciGhH)bMqftUwRr1eWAsmWlj69T5iWCLooRjrgahPMGI9xn4byj6k1RjAkkbylSNs4DCwtImWbsCCKcmaGTS0AqpxpLWJ7KFvrbSMedaphb8HzzwuIkx2Ns4beuS)QbpaNrxmlHBJtvdyX2Xy2OSMcjdIm4bQ4AdOexBa0X1gqgxB(awtIHWc7PeUnhbqfPNND)ogzfxFGIrw4nyBafgpVa6fQDmpjU(a1aZS6ggvJvt0uCTbQbMzbMednrtX1gOgyMLqIUs9AIMIRnGR03aOGYVnQX8vEHOd5uGAyunwnrA5iGiQLQqh0VbVbBdOeGTWEkH3nOO5beo5WNemGpmu25QyQf(MXgOcCtTyJQbVbBdWgqwC0lEd2gOuOd63eOyKLaP8nhbqP1RygFocmxzgH)a98gx7Pani98S7lMFtzRNiTX1hqts1lzZfcHf2tj8leDmYkqaur65z3xm)MYwprAJRpGChbeo5WNemGfBhJzJYAgLa1aZSWlj691enfxBauJRpGpmlZElMFtzRNiT5iaLLWrzeIECTciGEHkGhxFGVKO3FgH)W3m2aivlU6IDtbeyHkvNr)cbovFJZ3(awtIrhZtIsaGvsX(awkh9ydudmZQByunwnrAX1gats1lzJywchON34eqFamjvVKnZi8hON34ApfatUSeDL670upaq1fEHafu(TrnMVsvFHatUSeDL6dqzjCaRyPC0XjGa6fQDtX1haVgl)Vq4VKWGfxFGVKO3xt0uucOjP6LS5cHWc7PeEGVKO33gqWDSLDJ7uFRk1RQ9Nq5T(2RYTbQbMzHxs07RjslU2a6uEhZtIZ3aSf2tj8ze(d0ZBCTNcOmONp7)Gy0ngrjW96vmJVtt9aavx4fcuq53g1y(kv9fI71RygFaRjXqm)MYwprAZrGAGzwcj6k1RjslU2a1WOASAIMYraRjXOBkkbSMednrt5ialrxPEnrArjqnWmlWKyOjslU2awtIHF2gfk)MYrBZrG5kZi8h(MXgaPAXvxSBkGoLd4X5BGVKO3FgH)a98gx7PaZvMr4Fan8leqXTxiCLusmcWwypLWNr4Fan8leqXTxiCLusmcumYcW2XqmkfxFGjEPm27CeWs1XgBhYP48nqdspp7(DmYkU(awtIHMiTCe4lj69Nr4Fan8leqXTxiCLusmcGkspp7((5WgxBGgKEE299ZHnovPnGYGE(S)dIrucOt5DtX5BGVKO3VJZAsKboqIJJuGck2F1GhOyKvhN1KidCGehhPavFAgEaFywM9EgH)a98gx7Pau(nLTEISJZAsKbeuS)QbpGpmlZE7NdBociKG1CHaNeafu(TrnMVYleDiNcumYsTC6haBunRmFca]] )

    storeDefault( [[Brewmaster Primary]], 'displays', 20170723.095210, [[d0ZGhaGEvHxsqSlej9AvrMjvLEmsnBf9BOUjKuxds4BQIkpNIDsQ9k2nj7hj9tvPHPGXHivBtvugkHgmsmCeoOu5Ois0XOshNsyHuXsjOwSuSCuEOuvpfSmPkRJsunrijtfIjtjnDLUOcDvcsxwLRRQ2ivvBfrkBMO2ob(ivfFgsnnvrvFNQmskrEgKOrtKXJiojI6wuIYPr15PuhwYArKWTLsh3GeGUiwow5hRwyTNxGxHI4lz9ya6Iy5yLFSAb(JlA3EbyLc91x6OFkobS4F)RBYrRAp1gGoG9RSS52(fXYXkt0dbi5vw2CB)Iy5yLj6Haw8V)zLmnwb8hx0OyiGrc719zfzLmonbS4F)ZA)Iy5yLjobSFLLn3Ium03AIEiaP8F)ZeKODdsGrv1mpRXjqh9YXkQu8LB2ODdOR2laQo56p3acFZRmx09gCFM7Wakda0moXgiB2agjSh4XxAPUX4eWiH96(loobmsypWJV0sD)fhNa1NvKvYyeBIlqZxwoGD0wwVNneqgR2aDmEnPsrxmg2lGrc7Hum03AItGNA6u0sywaKxrHj7JLqcqJBBQvuWyAcqxelhR6u0sywaNxeKxuhOpMWMkfeCah251wM9yuP09ogWiH9aK4eWI)9puXzh9YXQact2hlHeq9BjtJvMOrzadXnN(NLrQpEIzbjqfTBGMODdGoA3aSODZgWiH96xelhRmXjajVYYMB7(Sk6Ha1Nvi2exGMVSCG2IKU)IJEiqnjKQUPxzBefmgTBGAsivGe2tuWy0UbQjHu1h32uROGXODdGQtU(ZnobQPxzBefigNac4gEdFYxBeBIlqta6Iy5yv3KJwfO)Ogzu4aw850prACdS2ZlqfWk3qmlBeBIlqfGvk0hInXfOA4t(AhO(Sc1C1fNa6Q9c4WoV2YShJkfrgVTy2bEQXpwTa)XfTBVaK8klBULSYkNUwmZe9qargVTy2uP0ViwowrLs3Nvbcy)klBULSYkNUwmZe9qa2nd0FuJmkCGTyOV1pwTberOsbkLHkfDXyyVa1KqQqkg6BffmgTBaRNC9NBNOVbitAuP4WoV2YShZYPsbvNC9NBal(3)SswzLtxlMzItaonwrkW42ODrrGTyOVTtrlHzbCErqErTWK9Xsib2IH(w)y1cR98c8kueFjRhdG6IeE7VLkfeE7fnkhcWPXkGOO5k0rJIaanJtSbcutcPQB6v2grbIr7gGGXBlMnzASc4pUOrXqacgVTy2(XQf4pUOD7fGGD042MA7e9n6HaCLvoDTywNIwcZcimzFSesG2IKUXOhcGuZtTuP4dd)jIEiWwm03kkymnbe(MxzUO7n4(Cdp)qps1fLdKUBargVTy2uP0Viwowfylg6BnbAlsaKODdutcPcPyOVvuGy0UbA5QU)IJEiWwm03kkqmnbAM8hp8zI96MZ0eWiH9iRSYPRfZmXjqnjKQ(42MAffigTBGA6v2grbJXjGrc71ngNagjSNOGX4eGg32uROaX0eWiH9eYz3Wvw5k0M4e4Pg)y1gqeHkfOugQu0fJH9cqYRSS5wH4yI2nqlxbirpeylg6B9JvlWFCr72lGrc7jkqmobOlILJv(XQnGicvkqPmuPOlgd7fO(SciU5KmQIEiWOQAMN14eWWBjMx37y09cutcPcKWEIceJ2nG9RSS52UpRIEiWtn(XQfw75f4vOi(swpgGKxzzZTifd9TMOhcy)klBUvioMOTm3ant(Jh(mXEPjqlx1ngnkdqs096rQOiq9zvNIwcZc48IG8IAFh9JeWI)9pR(XQf4pUOD7fWqCZP)zzKstal(3)SkehtCcaehnVM8h1YXQO79mspq9zLqv8naXSSpw2e]] )

    storeDefault( [[Brewmaster AOE]], 'displays', 20170723.095210, [[d0tHhaGEvHxsqSlKu61QkmtQk9yKA2k8BOUjsIRjvPBlvEoP2jL2Ry3eTFe5NQsdtrnoKuSnKuzOeAWiQHJWbPshfjP6ysPJtsAHsXsjjwmfTCu9qPQEkyzQIwhvf1evv0uHyYKutxPlQixLQcxwLRdPnsv1wrsvBMcBNaFuQIpRQAAijX3PkJKG0ZiOgnjgVQsNejUfvf50OCEQ4Wswlss6BijLtBqcqxeldl9JLlSoJlWRpq8LIDkaDrSmS0pwUa7XfB7Za8s(F9vo6pstavrp0ZDW(LDNCdqhW51WqFB)IyzyPo25aFFnm032ViwgwQJDoGQOh6PMcnwcShxS9ohqRG9Cr5ffPboMbuf9qp19lILHL60eW51WqFlsX)Vvh7CaQo6HE6GeBBqcmjlZXPonbCPxgwsISVm9gBBaB1Db(8mk0XgqLBCL(I95Cl11oplCaGMZi2azZgqRG9ap2sR4oLMaAfSNl6IJzaTc2d8ylTIl6IttGT4)36kPvW8anViiVurfk9iuKaoX6tpN7nGbwUbC5SAqIST4CSxaTc2dP4)3QttGpmDL0kyEaKxrvO0JqrcqJ7mRvuWumdqxeldlDL0kyEGMxeKxQeOpMWHezeCGg(51v694Ki7(ofqRG9aK0eqv0d9(KXp6LHLbuHspcfjGeTJcnwQJv4aAIBm8pkTsF8aZdsGk22a8yBd8hBBaZyBZgqRG96xeldl1PjW3xdd9TUO8k25afkVqCiUaMOggb6QVUOlo25a1GqPChELJwuWuSTbQbHsbkyprbtX2gOgekvFCNzTIcMITnWNNrHo20eOgELJwuGyAciGPzMSbBDqCiUaMbOlILHLUd2Vmq)jlYKkbufLr)b1Z0W6mUava1mnXOCqCiUa0b4L8)qCiUaLjBWwNafkVOctEPjqht6IU4yfoWhM(XYfypUyBFgaioAwnypQLHLX(K6OMa1GqPqk()TIceJTnGZRHH(wks1m6AXCDSZb43iq)jlYKkb2I)FRFSCdiIqImusnjY2IZXEbQbHsHu8)BffmfBBa1NrHowxrFdqH6jrUHFEDLEpUptI8NNrHo2aQIEONAks1m6AXCDAcWOXsQkg3fBBVby0yjqu0m5FS9gyl()T(XYfwNXf41hi(sXofGk1xwhAhjYiSUlwHNd0vFbKyNda0CgXgqZK)Jlqniuk3Hx5OffigBBaMunJUwm3vsRG5buHspcfjabN1vCh)y5cShxSTpdqWpACNzTUI(g7CGVX(8j12BGU6R7uSZbqQXjxsK7HJrjIDoWw8)BffmfZaQCJR0xSpNBPAZuL5NuBRWZutBaroRR4oKi3Viwgwgyl()T6aeCwxXDOqJLa7XfBVZbe5SUI7qIC)IyzyjjYUO8kqGT4)3kkqmMbSv3fOHFEDLEpojYUVtbmhShp6zG9ChJygqRG9OivZORfZ1PjqniuQ(4oZAffigBBGA4voArbtPjGwb75ofZaAfSNOGP0eGg3zwROaXygqRG9eY5yYKQzYFDAc8HPFSCdiIqImusnjY2IZXEb((AyOVvin6yBd0XKasSchyl()T(XYfypUyBFgqRG9efiMMa0fXYWs)y5gqeHezOKAsKTfNJ9cuO8ciUXGYNXohyswMJtDAcOzDeJZ9DkwHdudcLcuWEIceJTnGZRHH(wxuEf7CGpm9JLlSoJlWRpq8LIDkW3xdd9Tif))wDSZbCEnm03kKgDS(uBaZb7XJEgyVygOJjDNIv4afkVOinWioexatudJafkVCL0kyEGMxeKxQ47KFKaQIEONA)y5cShxSTpdOjUXW)O0kXmGQOh6Pwin60e47RHH(wks1m6AXCDSZbkuE5djBdqmkNJNnba]] )

    storeDefault( [[Brewmaster Defensives]], 'displays', 20170723.095210, [[d0JChaGEfYlPKYUqK0RvqntQGdlz2k6Xi1nvLY1uq62svxwPDsXEf7gv7Nq9tvLHjL(nuJtvsgkjnykXWr4GsLJIirhJQCCcPfsPwkLKftLwoPEOc1tbltbwNQKYevLyQqAYiPPRYfvfxLq0ZuLQRdXgPI2kIu2mbBxv1hPc9ze10qKQVtvnscHTrjvJMeJhrCsK4wkionkNxkEorRfrcFtvs1XlObOlIJH5oX8dUM5g4tKOoqX8e4kn59u)vJBaDXjVJvw6HJDa3jB0ihNy)4gO5tqqU34I4yyUmM2aK8jii3BCrCmmxgtBarrwKLkfAmhyJ2ygm0a9mE3tmVhquKfzPoUiogMlJDGMpbb5EOLM8EYyAdqkrwKvg0y8cAGhE5oxQXoqh9XWCXwCGjVygeWu9BGxwHLlz)RmGv7Cl5gZGwpR712(EaGwZiUa5YfqQG9bF2rR09e7aK8jii3dT0K3tgtBaPc2h8zhTshYHJDGcrxu4cy0gInGlIGqGMygYaR3gGKygYRgqQdnGub7JwAY7jJDGHD740kyDa0pvRO4OiqdqJ7DRt9)jUbOlIJH5DCAfSoG9hk63BbaILMvt2O6yyEmdS(RcivW(aASdikYISVW0l9XW8awrXrrGgGJ0tHgZLX4fqsSZPZzjvgJNyDqduX4fqhJxaYX4fWngVCbKky)XfXXWCzSdqYNGGCVoeDftBGcrxOneBaxebHa9fjDihoM2a1KqP6M(vJu9)jgVa1KqPafSV6)tmEbQjHsng37wN6)tmEbmv)gWwV(9L8wTylVSclxY(xzGA6xns1F1yh4NjzUSj7AqBi2aUbOlIJH5DtgzEGXpg0hRcqLjjMvdAdXgGAaDXjVOneBGYLnzxtGcrxVX4BSdikcJEysJjHRzUbQad76eZpGnAJXRnWlRqHmVyhOMekfAPjVN6VAmEbA(eeK7rHtLrxhwlJPnGENbg)yqFSkGKyNtNZsQe3a1KqPqln59u)FIXlWvAY75eZVaQOITafxk2IP0ASFarrwKLkfovgDDyTm2b6lsa0y8cWOXCsbg3hZ7TbUstEpNy(bxZCd8jsuhOyEc8wrcRhPxSfuw)gZ7Tby0yoqu0mo5ygAaGwZiUabQjHs1n9RgP6VAmEbUstEVooTcwhW(df97nRO4OiqdqOz9LUXjMFaB0gJ3Gae6Lg37wxNQdX0gquKfz7MmY8(LFbOd0xK09etBa0AU8tSfh1yeIyAdCLM8EQ)pXnaJtLrxhw3XPvW6awrXrrGgWQDULCJzqR3R3s6TdivV3BFLxacnRV0nuOXCGnAJH0BdOQz9LUrSLXfXXWCXw6q0vGa9mEhYHJPnaDrCmm3jMFaB0gJ3GaUt2OrooX(DZzCdivW(u4uz01H1YyhG6kuiZRt1HauinXwS1RFFjVv)AIT8YkSCj7FLbQPF1iv)FIDGAsOuJX9U1P(RgJxaPc2x9)j2bOX9U1P(Rg3asfSV12gxgNkJtwg7asfSF3tSdmSRtm)cOIk2cuCPylMsRX(b6zCanM2axPjVNtm)a2OngVbbg21jMFW1m3aFIe1bkMNa0fXXWCNy(fqfvSfO4sXwmLwJ9dui6ci25KYlX0g4HxUZLASdiz9eZT77jMbbQjHsbkyF1F1y8c08jii3RdrxX0gqQG9v)vJDaPc2Vdrxu4c44gqvZ6lDJylJlIJH5bOUcfY8cqYNGGCpRzlJXlqZNGGCpRzlJziEbKky)oKdh7afIU640kyDa7pu0V3C4XjAarrwKLQtm)a2OngVbbeW8lqNMvtXwmLwJ9dikYISuTMTm2bi5tqqUhfovgDDyTmM2afIUejNDbiMvZQZLa]] )



    ns.initializeClassModule = MonkInit

end
