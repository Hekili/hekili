-- Paladin.lua
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

local addGearSet = ns.addGearSet
local addGlyph = ns.addGlyph
local addMetaFunction = ns.addMetaFunction
local addResource = ns.addResource
local addStance = ns.addStance
local addTalent = ns.addTalent
local addTrait = ns.addTrait

local addSetting = ns.addSetting
local addToggle = ns.addToggle
local addMetaFunction = ns.addMetaFunction

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
local storeDefault = ns.storeDefault


local PTR = ns.PTR or false


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'PALADIN') then

    ns.initializeClassModule = function ()

        setClass( 'PALADIN' )

        -- addResource( SPELL_POWER_HEALTH )
        addResource( 'mana', SPELL_POWER_MANA )
        addResource( 'holy_power', SPELL_POWER_HOLY_POWER, true )

        setRegenModel( {
            liadrins_fury_crusade = {
                resource = 'holy_power',

                spec = 'retribution',
                equip = 'liadrins_fury_unleashed',
                aura = 'crusade',

                last = function ()
                    local app = state.buff.crusade.applied
                    local t = state.query_time

                    return app + ( floor( ( t - app ) / 4 ) * 4 )
                end,

                interval = 4,
                value = 1
            },

            liadrins_fury_aw = {
                resource = 'holy_power',

                spec = 'retribution',
                equip = 'liadrins_fury_unleashed',
                aura = 'avenging_wrath',

                last = function ()
                    local app = state.buff.avenging_wrath.applied
                    local t = state.query_time

                    return app + ( floor( ( t - app ) / 4 ) * 4 )
                end,

                interval = 4,
                value = 1
            }
        } )         

        addTalent( 'final_verdict', 198038 )
        addTalent( 'execution_sentence', 213757 )
        addTalent( 'consecration', 205228 )

        addTalent( 'the_fires_of_justice', 203316 )
        addTalent( 'zeal', 217020 )
        addTalent( 'greater_judgment', 218178 )

        addTalent( 'fist_of_justice', 198054 )
        addTalent( 'repentance', 20066 )
        addTalent( 'blinding_light', 115750 )

        addTalent( 'virtues_blade', 202271 )
        addTalent( 'blade_of_wrath', 231832 )
        addTalent( 'divine_hammer', 198034 )

        addTalent( 'justicars_vengeance', 215661 )
        addTalent( 'eye_for_an_eye', 205191 )
        addTalent( 'word_of_glory', 210191 )

        addTalent( 'divine_intervention', 213313 )
        addTalent( 'cavalier', 230332 )
        addTalent( 'seal_of_light', 202273 )

        addTalent( 'divine_purpose', 223817 )
        addTalent( 'crusade', 224668 )
        addTalent( 'holy_wrath', 210220 )

        addTalent( 'holy_shield', 152261 )
        addTalent( 'blessed_hammer', 204019 )
        addTalent( 'consecrated_hammer', 203785 )

        addTalent( 'first_avenger', 203776 )
        addTalent( 'bastion_of_light', 204035 )
        addTalent( 'crusaders_judgment', 204023 )

        addTalent( 'blessing_of_spellwarding', 204018 )
        addTalent( 'retribution_aura', 203797 )
        
        addTalent( 'hand_of_the_protector', 213652 )
        addTalent( 'knight_templar', 204139 )
        addTalent( 'final_stand', 204077 )

        addTalent( 'aegis_of_light', 204150 )
        addTalent( 'judgment_of_light', 183778 )
        addTalent( 'consecrated_ground', 204054 )

        addTalent( 'righteous_protector', 204074 )
        addTalent( 'seraphim', 152262 )
        addTalent( 'last_defender', 203791 )


        -- Artifact Traits
        -- Retribution
        addTrait( "ashbringers_light", 207604 )
        addTrait( "ashes_to_ashes", 179546 )
        addTrait( "blade_of_light", 214081 )
        addTrait( "blessing_of_the_ashbringer", 238098 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "deflection", 184778 )
        addTrait( "deliver_the_justice", 186927 )
        addTrait( "divine_tempest", 186773 )
        addTrait( "echo_of_the_highlord", 186788 )
        addTrait( "embrace_the_light", 186934 )
        addTrait( "endless_resolve", 185086 )
        addTrait( "ferocity_of_the_silver_hand", 241147 )
        addTrait( "healing_storm", 193058 )
        addTrait( "highlords_judgment", 186941 )
        addTrait( "judge_unworthy", 238134 )
        addTrait( "might_of_the_templar", 185368 )
        addTrait( "protector_of_the_ashen_blade", 186944 )
        addTrait( "righteous_blade", 184843 )
        addTrait( "righteous_verdict", 238062 )
        addTrait( "sharpened_edge", 184759 )
        addTrait( "unbreakable_will", 182234 )
        addTrait( "wake_of_ashes", 205273 )
        addTrait( "wrath_of_the_ashbringer", 186945 )

        -- Protection
        addTrait( "bastion_of_truth", 209216 )
        addTrait( "blessed_stalwart", 238133 )
        addTrait( "bulwark_of_order", 209389 )
        addTrait( "bulwark_of_the_silver_hand", 241146 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "consecration_in_flame", 209218 )
        addTrait( "defender_of_truth", 238097 )
        addTrait( "eye_of_tyr", 209202 )
        addTrait( "faiths_armor", 209225 )
        addTrait( "forbearant_faithful", 209376 )
        addTrait( "hammer_time", 209229 )
        addTrait( "holy_aegis", 238061 )
        addTrait( "light_of_the_titans", 209539 )
        addTrait( "painful_truths", 209341 )
        addTrait( "resolve_of_truth", 209224 )
        addTrait( "righteous_crusader", 209226 )
        addTrait( "sacrifice_of_the_just", 209285 )
        addTrait( "scatter_the_shadows", 209223 )
        addTrait( "stern_judgment", 209217 )
        addTrait( "truthguards_light", 221841 )
        addTrait( "tyrs_enforcer", 209474 )
        addTrait( "unflinching_defense", 209220 )
        addTrait( "unrelenting_light", 214924 )


        -- Player Buffs.
        addAura( 'aegis_of_light', 204150, 'duration', 6 )
        addAura( 'ardent_defender', 31850, 'duration', 8 )
        addAura( 'avengers_protection', 242265, 'duration', 10 )
        addAura( 'avenging_wrath', 31884 )
        addAura( 'blade_of_wrath', 202270 )        
        addAura( 'blessed_hammer', 204019, 'duration', 2 )
        addAura( 'blessed_stalwart', 242869, 'duration', 10 )
        addAura( 'blessing_of_freedom', 1044, 'duration', 8 )
        addAura( 'blessing_of_protection', 1022, 'duration', 10 )
        addAura( 'blessing_of_sacrifice', 6940, 'duration', 12 )
        addAura( 'blessing_of_spellwarding', 204018, 'duration', 10 )
        addAura( 'blessing_of_the_ashbringer', 242981, 'duration', 3600 )
        addAura( 'blinding_light', 115750, 'duration', 6 )
        -- addAura( 'consecration', 188370, 'duration', 8 )
        addAura( 'crusade', 224668, 'max_stack', 15 )
        addAura( 'divine_hammer', 198137 )
        addAura( 'divine_purpose', 223819 )
        addAura( 'divine_shield', 642, 'duration', 8 )
        addAura( 'divine_steed', 221883, 'duration', 3 )
        addAura( 'defender_of_truth', 240059, 'duration', 10 )
        addAura( 'execution_sentence', 213757, 'duration', 7 )
        addAura( 'eye_for_an_eye', 205191, 'duration', 10 )
        addAura( 'eye_of_tyr', 209202, 'duration', 9 )
        addAura( 'forbearance', 25771, 'duration', 30 )
        addAura( 'grand_crusader', 85043, 'duration', 10 )
        addAura( 'greater_blessing_of_kings', 203538, 'duration', 3600 )
        addAura( 'greater_blessing_of_might', 203528, 'duration', 3600 )
        addAura( 'greater_blessing_of_wisdom', 203539, 'duration', 3600 )
        addAura( 'hammer_of_justice', 853, 'duration', 6 )
        addAura( 'hand_of_hindrance', 183218, 'duration', 10 )
        addAura( 'hand_of_reckoning', 62124, 'duration', 3 )
        addAura( 'judgment_of_light', 183778, 'duration', 30, 'max_stack', 40 )
        addAura( 'light_of_the_titans', 209539, 'duration', 15 )
        addAura( 'repentance', 62124, 'duration', 60 )
        addAura( 'righteous_verdict', 238996, 'duration', 15 )
        addAura( 'sacred_judgment', 246973, 'duration', 8 )
        addAura( 'seal_of_light', 202273, 'duration', 20 )
        addAura( 'seraphim', 152262, 'duration', 30 )
        addAura( 'shield_of_the_righteous', 132403, 'duration', 4.5 )
        addAura( 'shield_of_vengeance', 184662, 'duration', 15 )
        addAura( 'the_fires_of_justice', 209785 )
        addAura( 'wake_of_ashes', 205273, 'duration', 6 )
        addAura( 'zeal', 217020, 'max_stack', 3 )



        -- Fake Buffs.

        local judgment = GetSpellInfo( 197277 )

        addAura( 'judgment', 197277, 'duration', 8 ) --[[, 'feign', function ()

            local name, _, _, count, _, duration, expires, caster, _, _, id, _, _, _, _, timeMod = UnitDebuff( 'target', judgment, nil, 'PLAYER' )

            if not name then
                if player.lastcast == 'judgment' and state.now - player.casttime <= state.gcd then
                    debuff.judgment.name = judgment
                    debuff.judgment.count = 1
                    debuff.judgment.expires = player.casttime + 9
                    debuff.judgment.applied = player.casttime
                    debuff.judgment.caster = 'player'
                else
                    debuff.judgment.name = judgment
                    debuff.judgment.count = 0
                    debuff.judgment.expires = 0
                    debuff.judgment.applied = 0
                    debuff.judgment.caster = 'none'
                end
                return

            end

            debuff.judgment.name = name
            debuff.judgment.count = 1
            debuff.judgment.expires = expires
            debuff.judgment.applied = expires - duration
            debuff.judgment.caster = caster
        end ) ]]


        registerCustomVariable( 'last_consecration', 0 )
        registerCustomVariable( 'last_cons_internal', 0 )        
        
        registerCustomVariable( 'expire_consecration', 0 )
        registerCustomVariable( 'expire_cons_internal', 0 )

        registerCustomVariable( 'last_divine_storm', 0 )
        registerCustomVariable( 'last_divine_storm_internal', 0 )

        registerCustomVariable( 'last_blessed_hammer', 0 )
        registerCustomVariable( 'last_bh_internal', 0 )

        registerCustomVariable( 'last_shield_of_the_righteous', 0 )
        registerCustomVariable( 'last_sotr_internal', 0 )


        RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )

            if unit ~= 'player' then return end

            if spell == class.abilities.consecration.name then
                local start, duration = GetSpellCooldown( 26573 )
                state.last_cons_internal = start
                state.expire_cons_internal = start + max( duration, 9 * state.haste )
            
            elseif spell == class.abilities.shield_of_the_righteous.name then
                state.last_sotr_internal = GetTime()

            elseif spell == class.abilities.blessed_hammer.name then
                state.last_bh_internal = GetTime()

            elseif spell == class.abilities.divine_storm.name then
                state.last_divine_storm_internal = GetTime()

            end

        end )

        addHook( 'reset_postcast', function( x )
            state.last_consecration = state.last_cons_internal
            state.last_blessed_hammer = state.last_bh_internal
            state.last_shield_of_the_righteous = state.last_sotr_internal
            state.expire_consecration = state.expire_cons_internal
            state.last_divine_storm = state.last_divine_storm_internal

            return x
        end )


        local consecration = GetSpellInfo( 188370 )

        addAura( 'consecration', 188370, 'name', consecration, 'duration', 9, 'feign', function ()

            if spec.protection then
                local up = UnitBuff( 'player', consecration, nil, 'PLAYER' ) and now + offset < expire_consecration
                buff.consecration.count = up and 1 or 0
                buff.consecration.expires = state.expire_consecration
                buff.consecration.applied = state.last_consecration
                buff.consecration.caster = 'player'
            else
                buff.consecration.count = 0
                buff.consecration.expires = 0
                buff.consecration.applied = 0
                buff.consecration.caster = 'unknown'
            end

        end )


        -- Special handler for Liadrin's Fury Unleashed legendary ring.
        -- This will cause the addon to predict HoPo gains during Crusader/AW uptime if you have the ring.
        -- LegionFix:  Will want to enable Forbearant Faithful through advance, as well.
        addHook( 'advance', function( t )
            -- NYI: scarlet_inquisitors_expurgation
        end )


        --[[
            if not state.equipped.liadrins_fury_unleashed then return t end

            local buff_remaining = 0

            if state.buff.crusade.up then buff_remaining = state.buff.crusade.remains
            elseif state.buff.avenging_wrath.up then buff_remaining = state.buff.avenging_wrath.remains end

            if buff_remaining < 4 then return t end

            local ticks_before = math.floor( buff_remaining / 4 )
            local ticks_after = math.floor( max( 0, ( buff_remaining - t ) / 4 ) )

            state.gain( ticks_before - ticks_after, 'holy_power' )

            return t
        end ) ]]

        addHook( 'spend', function( amt, resource )
            if resource == 'holy_power' then
                if state.buff.crusade.up then
                    if state.buff.crusade.stack < state.buff.crusade.max_stack then
                        state.stat.mod_haste_pct = state.stat.mod_haste_pct + ( ( state.buff.crusade.max_stack - state.buff.crusade.stack ) * 3.5 )
                    end
                    state.addStack( 'crusade', state.buff.crusade.remains, amt )
                end

                if amt > 0 and state.artifact.righteous_verdict.rank > 0 then
                    state.applyBuff( 'righteous_verdict', 15 )
                end
            end
        end )

        --[[ LegionFix:  Set up HoPo for prediction over time (for Liadrin's Fury Unleashed).
        ns.addResourceMetaFunction( 'current', function( t )
            if t.resource ~= 'holy_power' then return 'nofunc' end
        end ) ]]


        addMetaFunction( 'state', 'divine_storm_targets', function()
            if settings.ds_targets == 'a' then
                return spec.retribution and ( ( artifact.divine_tempest.enabled or artifact.righteous_blade.rank >= 2 ) and 2 or 3 ) or 0
            end
            return state.settings.ds_targets == 'c' and 3 or 2
        end )

        addMetaFunction( 'state', 'judgment_override', function()
            if settings.use_latency then
                return spec.retribution and ( debuff.judgment.remains > latency * 2 or ( not settings.strict_finishers and cooldown.judgment.remains > gcd * 2 and holy_power.current >= 4 ) )
            end
            return spec.retribution and ( debuff.judgment.up or ( not settings.strict_finishers and cooldown.judgment.remains > gcd * 2 and holy_power.current >= 4 ) )
        end )


        -- Gear Sets
        addGearSet( 'tier19', 138350, 138353, 138356, 138359, 138362, 138369 )
        addGearSet( 'tier20', 147160, 147162, 147158, 147157, 147159, 147161 )
        addGearSet( 'class', 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )
        
        addGearSet( 'ashbringer', 120978 )
        setArtifact( 'ashbringer' )

        addGearSet( 'truthguard', 128866 )
        setArtifact( 'truthguard' )

        addGearSet( 'whisper_of_the_nathrezim', 137020 )
            addAura( 'whisper_of_the_nathrezim', 207633 )
        addGearSet( 'justice_gaze', 137065 )
        addGearSet( 'ashes_to_dust', 51745 )    
            addAura( 'ashes_to_dust', 236106, 'duration', 6 )
        addGearSet( 'aegisjalmur_the_armguards_of_awe', 140846 )
        addGearSet( 'chain_of_thrayn', 137086 )
            addAura( 'chain_of_thrayn', 236328 )
        addGearSet( 'liadrins_fury_unleashed', 137048 )
            addAura( 'liadrins_fury_unleashed', 208410 )

        addGearSet( "soul_of_the_highlord", 151644 )
        addGearSet( "pillars_of_inmost_light", 151812 )
        addGearSet( "scarlet_inquisitors_expurgation", 151813 )
            addAura( "scarlet_inquisitors_expurgation", 248289, "duration", 3600, "max_stack", 30 )

        setTalentLegendary( 'soul_of_the_highlord', 'retribution',  'divine_purpose' )
        setTalentLegendary( 'soul_of_the_highlord', 'protection', 'holy_shield' )
        setTalentLegendary( 'soul_of_the_highlord', 'holy', 'divine_purpose' )

        addHook( 'specializationChanged', function ()
            setPotion( 'old_war' )
            setRole( state.spec.protection and 'tank' or 'attack' )
        end )


        -- Class/Spec Settings
        addToggle( 'wake_of_ashes', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'wake_of_ashes_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for your artifact ability will be overriden and your artifact ability may be recommended.",
            width = "full"
        } )


        -- Using these to abstract the 'Wake of Ashes' options so the same keybinds/toggles work in Protection spec.
        addMetaFunction( 'toggle', 'artifact_ability', function()
            return state.toggle.wake_of_ashes
        end )

        addMetaFunction( 'settings', 'artifact_cooldown', function()
            return state.settings.wake_of_ashes_cooldown
        end )


        addToggle( 'use_defensives', true, "Protection: Use Defensives",
            "Set a keybinding to toggle your defensive abilities on/off in your priority lists." )

        addSetting( 'use_latency', true, {
            name = "Retribution: Account for Latency",
            type = "toggle",
            desc = "When checked, the |cFFFFD100judgment_override|r flag will consider your latency when making recommendations for Holy Power finishers.\r\n\r\n" ..
                "If you have 50ms latency, the addon will verify that Judgment will be up for 100ms (latency x 2) before recommending that you spend a finisher.  " ..
                "This may help you to avoid using a Holy Power finisher immediately after the Judgment debuff falls off your target.",
            width = "full"
        } )

        addSetting( 'strict_finishers', false, {
            name = "Retribution: Strict Finishers",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will not recommend Holy Power spenders unless the Judgment debuff is on your target.\r\n\r\n" ..
                "This may have adverse effects in situations where you are target swapping.\r\n\r\n" ..
                "You may incorporate this into your custom action lists with the |cFFFFD100settings.strict_finishers|r flag.  It is also " ..
                "bundled into the |cFFFFD100judgment_override|r flag, which is |cFF00FF00true|r when all of the following is true:  Strict " ..
                "Finishers is disabled, Judgment remains on cooldown for 2 GCDs, and your Holy Power is greater than or equal to 4.",
            width = "full"
        } )

        addSetting( 'maximum_wake_power', 1, {
            name = "Retribution: Maximum Wake of Ashes Power",
            type = "range",
            min = 0,
            max = 5,
            step = 1,
            desc = "Specify the amount of Holy Power that the Wake of Ashes ability can waste.  For instance, if this is set to |cFFFFD1001|r, " ..
                "the addon will not recommend Ashes to Ashes when you have more than 1 Holy Power (if you have the Ashes to Ashes artifact trait), " ..
                "because you would end up overcapping Holy Power by more than 1 point.\r\n\r\n",
            width = "full"
        } )

        addSetting( 'ds_targets', 'a', {
            name = "Retribution:  Divine Storm Targets",
            type = "select",
            desc = "If set to |cFF00FF00auto|r, the addon will recommend Divine Storm (vs. Templar's Verdict) based on your artifact traits.\r\n\r\n" ..
                "If set to 2 or 3, the artifact will recommend Divine Storm with the specified number of targets.  If using a manual setting, using " ..
                "Divine Storm on 2 targets is recommended if you have the Righteous Blade and Divine Tempest artifact traits.",
            values = {
                a = 'Automatic',
                b = '2',
                c = '3'
            },
            width = 'full'
        } )

        addSetting( 'shield_damage', 20, {
            name = "Retribution: Shield of Vengeance Damage Threshold",
            type = "range",
            desc = "The Shield of Vengeance ability is only recommended if/when you are taking damage.  Specify how much damage, as a percentage " ..
                "of your maximum health, that you must take in the preceding 3 seconds before Shield of Vengeance can be recommended.\r\n\r\n" ..
                "If set to 100, Shield of Vengeance will never be recommended.\r\n" ..
                "If set to 0, Shield of Vengeance will always be available.\r\n",
            width = "full",
            min = 0,
            max = 100,
            step = 1,
            width = 'full'
        } )

        addSetting( 'health_threshold', 40, {
            name = "Protection: Light of the Protector Threshold",
            type = "range",
            min = 1,
            max = 100,
            step = 1,
            desc = "Specify the amount of health, as a percentage of maximum health, that you must fall below before Light (or Hand) of the Protector can be recommended.\n\n" ..
                "This is expressed as |cFFFFD100settings.health_threshold|r in your action lists.  You can use |cFFFFD100use_self_heal|r as shorthand to see if your character is below the health percentage.\n\n" ..
                "Remember, tanking is complex and you may want to use your defensive abilities proactively to manage mechanics that the addon cannot see.",                
            width = "full"
        } )

        addMetaFunction( 'state', 'use_self_heal', function ()
            return spec.protection and health.current <= health.max * ( settings.health_threshold / 100 )
        end )


        addSetting( 'shield_threshold', 5, {
            name = "Protection: Shield of the Righteous Threshold",
            type = "range",
            min = 0,
            max = 500,
            step = 1,
            desc = "Specify the amount of damage, as a percentage of your maximum health, that must be taken over the past 5 seconds before Shield of the Righteous is recommended by the default action lists.  " ..
                "Note that the default action list will recommend Shield of the Righteous at 3 stacks, regardless of this setting, to prevent wasted cooldown recovery from Judgment.\n\n" ..
                "This is expressed as |cFFFFD100settings.shield_threshold|r in your action lists.  You can use |cFFFFD100use_shield|r as shorthand to see if your character has taken the requisite damage.\n\n" ..
                "Remember, tanking is complex and you may want to use your defensive abilities proactively to manage mechanics that the addon cannot see.",                
            width = "full"
        } )

        addMetaFunction( 'state', 'use_shield', function ()
            return spec.protection and incoming_damage_5s >= health.max * ( settings.shield_threshold / 100 )
        end )




        addAbility( 'aegis_of_light', {
            id = 204150,
            spend = 0,
            spend_type = 'mana',
            cast = 6,
            gcdType = 'spell',
            channeled = true,
            cooldown = 300,
            talent = 'aegis_of_light'
        } )


        addAbility( 'ardent_defender', {
            id = 31850,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 120
        } )

        modifyAbility( 'ardent_defender', 'cooldown', function( x )
            return x - ( 10 * artifact.unflinching_defense.rank )
        end )

        addHandler( 'ardent_defender', function ()
            applyBuff( 'ardent_defender', 8 )
        end )


        addAbility( 'avengers_shield', {
            id = 31935,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 15
        } )

        modifyAbility( 'avengers_shield', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'avengers_shield', function ()
            interrupt()
            if set_bonus.tier20_4pc > 0 then applyDebuff( 'target', 'avengers_protection', 10 ) end
        end )


        addAbility( 'avenging_wrath', {
            id = 31884,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            charges = 1,
            recharge = 120,
            notalent = 'crusade',
            usable = function () return not buff.avenging_wrath.up end,
            toggle = 'cooldowns'
        } )

        addHandler( 'avenging_wrath', function ()
            applyBuff( 'avenging_wrath', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2.5 ) )
            if equipped.chain_of_thrayn then applyBuff( 'chain_of_thrayn', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2 ) ) end
            if equipped.liadrins_fury_unleashed then gain( 1, 'holy_power' ) end
        end )


        addAbility( 'bastion_of_light', {
            id = 204035,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            talent = 'bastion_of_light',
        } )

        addHandler( 'bastion_of_light', function ()
            gainCharges( 'shield_of_the_righteous', 3 )
        end )


        addAbility( 'blade_of_justice', {
            id = 184575,
            spend = -2,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 10.5,
            notalent = 'divine_hammer',
            bind = 'divine_hammer'
        } )

        modifyAbility( 'blade_of_justice', 'cooldown', function( x )
            return x * haste
        end )

        modifyAbility( 'blade_of_justice', 'spend', function( x )
            return set_bonus.tier20_2pc == 1 and ( x - 1 ) or x
        end )

        addHandler( 'blade_of_justice', function ()
            removeBuff( 'righteous_verdict' )
        end )

        
        addAbility( 'blessed_hammer', {
            id = 204019,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'melee',
            cooldown = 4.5,
            charges = 3,
            recharge = 4.5,
            ready = function () return max( 0, last_blessed_hammer + ( gcd * 2 ) - query_time ) end,
            talent = 'blessed_hammer'
        } )

        modifyAbility( 'blessed_hammer', 'cooldown', function( x )
            return x * haste
        end )

        modifyAbility( 'blessed_hammer', 'recharge', function( x )
            return x * haste
        end )

        addHandler( 'blessed_hammer', function ()
            applyDebuff( 'target', 'blessed_hammer', 2 )
            last_blessed_hammer = now + offset
        end )


        addAbility( 'blessing_of_freedom', {
            id = 1044,
            spend = 0.15,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 25
        } )

        addHandler( 'blessing_of_freedom', function ()
            applyBuff( 'blessing_of_freedom', 8 )
        end )


        addAbility( 'blessing_of_protection', {
            id = 1022,
            spend = 0.15,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 300,
            talent = 'blessing_of_spellwarding'
        } )

        modifyAbility( 'blessing_of_protection', 'cooldown', function( x )
            return x * ( 1 - ( artifact.protector_of_the_ashen_blade.rank * 0.1 ) )
        end )

        addHandler( 'blessing_of_protection', function ()
            applyBuff( 'blessing_of_protection', 10 )
            applyDebuff( 'player', 'forbearance', 30 - ( artifact.endless_resolve.rank * 10 ) )
        end )


        addAbility( 'blessing_of_sacrifice', {
            id = 1022,
            spend = 0.075,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 150
        } )

        modifyAbility( 'blessing_of_sacrifice', 'cooldown', function( x )
            if spec.protection then
                return x - ( artifact.sacrifice_of_the_just.enabled and 60 or 0 )
            end
            return x * ( 1 - ( artifact.protector_of_the_ashen_blade.rank * 0.1 ) )
        end )

        addHandler( 'blessing_of_sacrifice', function ()
            applyBuff( 'blessing_of_sacrifice', 12 )
            applyDebuff( 'player', 'forbearance', 30 - ( artifact.endless_resolve.rank * 10 ) )
        end )


        --[[ removed in 7.1
        
        addAbility( 'blade_of_wrath', {
            id = 202270,
            spend = -2,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 10.5,
            known = function () return talent.blade_of_wrath.enabled end,
        } )

        modifyAbility( 'blade_of_wrath', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'blade_of_wrath', function ()
            applyDebuff( 'target', 'blade_of_wrath', 6 * haste )
        end ) ]]


        addAbility( 'blinding_light', {
            id = 115750,
            spend = 0.08,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 90,
            talent = 'blinding_light'
        } )

        addHandler( 'blinding_light', function ()
            applyDebuff( 'target', 'blinding_light', 6 )
            active_dot.blinding_light = active_enemies
        end )


        addAbility( 'cleanse_toxins', {
            id = 213644,
            spend = 0.105,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 8,
        } )


        addAbility( 'consecration', {
            id = 26573,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 12,
            known = function () return spec.protection or talent.consecration.enabled end,
        } )

        class.abilities[ 205228 ] = class.abilities.consecration

        modifyAbility( 'consecration', 'id', function( x )
            return spec.retribution and 205228 or x
        end )

        modifyAbility( 'consecration', 'cooldown', function( x )
            if spec.protection then return 9 * haste end
            return x * haste
        end )

        addHandler( 'consecration', function ()
            if spec.protection then
                last_consecration = now + offset
                expire_consecration = now + offset + ( artifact.consecration_in_flame.rank + ( 9 * haste ) )
                applyBuff( 'consecration', artifact.consecration_in_flame.rank + ( 9 * haste ) )
            end
        end )


        addAbility( 'crusade', {
            id = 231895,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            charges = 1,
            recharge = 120,
            talent = 'crusade',
            usable = function () return not buff.crusade.up end,
            toggle = 'cooldowns'
        } )

        addHandler( 'crusade', function ()
            applyBuff( 'crusade', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2.5 ) )
            if equipped.chain_of_thrayn then applyBuff( 'chain_of_thrayn', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2.5 ) ) end
            if equipped.liadrins_fury_unleashed then gain( 1, 'holy_power' ) end
        end )


        addAbility( 'crusader_strike', {
            id = 35395,
            spend = -1,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 4.5,
            charges = 2,
            recharge = 4.5,
            notalent = 'zeal'
        } )

        modifyAbility( 'crusader_strike', 'cooldown', function( x )
            if talent.the_fires_of_justice.enabled then x = x - 1 end
            return x * haste
        end )

        modifyAbility( 'crusader_strike', 'recharge', function( x )
            if talent.the_fires_of_justice.enabled then x = x - 1 end
            return x * haste
        end )


        addAbility( 'divine_hammer', {
            id = 198034,
            spend = -2,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 12,
            talent = 'divine_hammer',
            talent = 'divine_hammer',
            bind = 'blade_of_justice'
        } )

        addHandler( 'divine_hammer', function ()
            applyBuff( 'divine_hammer', 12 )
            removeBuff( 'righteous_verdict' )
        end )


        addAbility( 'divine_shield', {
            id = 642,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 300, 
            usable = function () return not debuff.forbearance.up end
        } )

        modifyAbility( 'divine_shield', 'cooldown', function( x )
            return x * ( talent.divine_intervention.enabled and 0.8 or 1 )
        end )

        addHandler( 'divine_shield', function ()
            applyBuff( 'divine_shield', 8 )
            applyDebuff( 'player', 'forbearance', 30 - ( artifact.endless_resolve.rank * 10 ) )
        end )


        addAbility( 'divine_steed', {
            id = 190784,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 45,
            charges = 1,
            recharge = 45
        } )

        modifyAbility( 'divine_steed', 'cooldown', function( x )
            return x * ( talent.knight_templar.enabled and 0.5 or 1 )
        end )

        modifyAbility( 'divine_steed', 'recharge', function( x )
            return x * ( talent.knight_templar.enabled and 0.5 or 1 )
        end )

        modifyAbility( 'divine_steed', 'charges', function( x )
            return x + ( talent.cavalier.enabled and 1 or 0 )
        end )


        addAbility( 'divine_storm', {
            id = 53385,
            spend = 3,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
        } )

        modifyAbility( 'divine_storm', 'spend', function( x )
            if buff.divine_purpose.up then return 0
            elseif buff.the_fires_of_justice.up then return x - 1 end
            return x
        end )

        addHandler( 'divine_storm', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            elseif buff.the_fires_of_justice.up then removeBuff( 'the_fires_of_justice' ) end
            if equipped.whisper_of_the_nathrezim then applyBuff( 'whisper_of_the_nathrezim', 4 ) end
            if talent.fist_of_justice.enabled then setCooldown( 'hammer_of_justice', max( 0, cooldown.hammer_of_justice.remains - 8 ) ) end
        end )


        addAbility( 'execution_sentence', {
            id = 213757,
            spend = 3,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 20,
            talent = 'execution_sentence'
        } )

		modifyAbility( 'execution_sentence', 'spend', function( x )
            if buff.divine_purpose.up then return 0
            elseif buff.the_fires_of_justice.up then return x - 1 end
			return x
		end )

        modifyAbility( 'execution_sentence', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'execution_sentence', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            elseif buff.the_fires_of_justice.up then removeBuff( 'the_fires_of_justice' ) end
            applyDebuff( 'target', 'execution_sentence', 7 * haste ) 
            if talent.fist_of_justice.enabled then setCooldown( 'hammer_of_justice', max( 0, cooldown.hammer_of_justice.remains - 8 ) ) end
        end )


        addAbility( 'eye_for_an_eye', {
            id = 205191,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 60,
            talent = 'eye_for_an_eye'
        } )

        addHandler( 'eye_for_an_eye', function ()
            applyBuff( 'eye_for_an_eye', 10 )
        end )


        addAbility( 'eye_of_tyr', {
            id = 209202,
            spend = 0,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 60,
            known = function () return equipped.truthguard and ( toggle.artifact_ability or ( toggle.cooldowns and settings.artifact_cooldown ) ) end
        } )

        modifyAbility( 'eye_of_tyr', 'cooldown', function( x )
            return equipped.pillars_of_inmost_light and ( x * 0.75 ) or x
        end )

        addHandler( 'eye_of_tyr', function ()
            applyDebuff( 'target', 'eye_of_tyr', 9 )
        end )


        addAbility( 'flash_of_light', {
            id = 19750,
            spend = 0.22,
            spend_type = 'mana',
            cast = 1.5,
            gcdType = 'spell',
            cooldown = 0,
        } )

        modifyAbility( 'flash_of_light', 'cast', function( x )
            return x * haste
        end )

        addHandler( 'flash_of_light', function ()
            health.actual = min( health.max, health.actual + ( stat.spell_power * 4.5 * ( 1 + ( artifact.embrace_the_light.rank * 0.15 ) ) ) )
        end )


        addAbility( 'greater_blessing_of_kings', {
            id = 203538,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            usable = function () return buff.greater_blessing_of_kings.down end,
        } )

        addHandler( 'greater_blessing_of_kings', function ()
            applyBuff( 'greater_blessing_of_kings', 3600 )
            applyBuff( 'blessing_of_the_ashbringer', 3600 )
        end )


        addAbility( 'greater_blessing_of_wisdom', {
            id = 203539,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            usable = function () return buff.greater_blessing_of_wisdom.down end,
        } )

        addHandler( 'greater_blessing_of_wisdom', function ()
            applyBuff( 'greater_blessing_of_wisdom', 3600 )
            applyBuff( 'blessing_of_the_ashbringer', 3600 )
        end )


        addAbility( 'guardian_of_ancient_kings', {
            id = 86659,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 300
        } )

        addHandler( 'guardian_of_ancient_kings', function ()
            applyBuff( 'guardian_of_ancient_kings', 8 )
        end )


        addAbility( 'hammer_of_justice', {
            id = 853,
            spend = 0.035,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 60
        } )

        modifyAbility( 'hammer_of_justice', 'cooldown', function( x )
            if equipped.justice_gaze and target.health.percent > 75 then
                return x * 0.25
            end
            return x
        end )

        addHandler( 'hammer_of_justice', function ()
            applyDebuff( 'target', 'hammer_of_justice', 6 )
            if equipped.justice_gaze and target.health.percent > 75 then
                gain( 1, 'holy_power' )
            end
        end )


        addAbility( 'hammer_of_the_righteous', {
            id = 53595,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'melee',
            cooldown = 4.5,
            charges = 2,
            recharge = 4.5,
            notalent = 'blessed_hammer'
        } )

        modifyAbility( 'hammer_of_the_righteous', 'cooldown', function( x )
            return x * haste * ( talent.consecrated_hammer.enabled and 0 or 1 )
        end )


        addAbility( 'hand_of_hindrance', {
            id = 183218,
            spend = 0.105,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 30
        } )

        addHandler( 'hand_of_hindrance', function ()
            applyDebuff( 'target', 'hand_of_hindrance', 10 )
        end )


        addAbility( 'hand_of_reckoning', {
            id = 62124,
            spend = 0.035,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 8,
        } )

        addHandler( 'hand_of_reckoning', function ()
            applyDebuff( 'target', 'hand_of_reckoning', 3 )
        end )


        addAbility( 'hand_of_the_protector', {
            id = 213652,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 10,
            talent = 'hand_of_the_protector'
        } )

        modifyAbility( 'hand_of_the_protector', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'hand_of_the_protector', function ()
            health.actual = health.actual * 1.33 * ( ( buff.consecration.up or talent.consecrated_hammer.enabled ) and 1.2 or 1 )

            if artifact.light_of_the_titans.enabled then
                applyBuff( 'light_of_the_titans', 15 )
            end
        end )


        addAbility( 'holy_wrath', {
            id = 210220,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 180,
            talent = 'holy_wrath',
            toggle = 'cooldowns'
        } )


        addAbility( 'judgment', {
            id = 20271,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 12,
            charges = 1,
            recharge = 12,
            velocity = 30,
            range = 62124,
        } )

        modifyAbility( 'judgment', 'cooldown', function( x )
            if spec.protection then return 6 * haste end
            return x * haste
        end )

        modifyAbility( 'judgment', 'charges', function( x )
            return x + ( talent.crusaders_judgment.enabled and 1 or 0 )
        end )

        modifyAbility( 'judgment', 'recharge', function( x )
            if spec.protection then return 6 * haste end
            return x * haste
        end )

        addHandler( 'judgment', function ()
            if talent.judgment_of_light.enabled then applyDebuff( 'target', 'judgment_of_light', 30, 40 ) end
            if spec.protection then
                gainChargeTime( 'shield_of_the_righteous', 2 )
                if talent.fist_of_justice.enabled then setCooldown( 'hammer_of_justice', max( 0, cooldown.hammer_of_justice.remains - 8 ) ) end
            else
                applyDebuff( 'target', 'judgment', 8 )
                if talent.greater_judgment.enabled then active_dot.judgment = max( active_enemies, active_dot.judgment + 2 ) end
                if set_bonus.tier20_4pc > 0 then applyBuff( 'sacred_judgment', 8 ) end
            end
        end )


        addAbility( 'justicars_vengeance', {
            id = 215661,
            spend = 5,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            talent = 'justicars_vengeance'
        } )

        modifyAbility( 'justicars_vengeance', 'spend', function( x )
            if buff.divine_purpose.up then return 0
			elseif buff.the_fires_of_justice.up then return x - 1 end
            return x
        end )

        addHandler( 'justicars_vengeance', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            elseif buff.the_fires_of_justice.up then removeBuff( 'the_fires_of_justice' ) end
            if spec.retribution and talent.fist_of_justice.enabled then setCooldown( 'hammer_of_justice', max( 0, cooldown.hammer_of_justice.remains - 8 ) ) end
        end )


        addAbility( 'lay_on_hands', {
            id = 633,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 600,
            usable = function () return debuff.forbearance.down end,
        } )

        addHandler( 'lay_on_hands', function ()
            health.actual = health.max
            applyDebuff( 'player', 'forbearance', 30 - ( artifact.endless_resolve.rank * 10 ) )
        end )


        addAbility( 'light_of_the_protector', {
            id = 184092,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 15,
            known = function () return spec.protection and not talent.hand_of_the_protector.enabled end
        } )

        modifyAbility( 'light_of_the_protector', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'light_of_the_protector', function ()
            health.actual = health.actual * 1.33 * ( ( buff.consecration.up or talent.consecrated_hammer.enabled ) and 1.2 or 1 )

            if artifact.light_of_the_titans.enabled then
                applyBuff( 'light_of_the_titans', 15 )
            end
        end )


        addAbility( 'rebuke', {
            id = 96231,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 15,
            usable = function () return target.casting end,
            toggle = 'interrupts'
        } )

        addHandler( 'rebuke', function ()
            interrupt()
        end )

        registerInterrupt( 'rebuke' )


        addAbility( 'repentance', {
            id = 20066,
            spend = 0.10,
            spend_type = 'mana',
            cast = 1.5,
            gcdType = 'spell',
            cooldown = 15,
            talent = 'repentance'
        } )

        modifyAbility( 'repentance', 'cast', function( x )
            return x * haste
        end )

        addHandler( 'repentance', function ()
            interrupt()
            applyDebuff( 'target', 'repentance', 60 )
        end )


        addAbility( 'seraphim', {
            id = 152262,
            spend = 1,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'off',
            cooldown = 45,
            talent = 'seraphim'
        } )

        modifyAbility( 'seraphim', 'spend', function( x )
            return spec.protection and 0 or x
        end )

        modifyAbility( 'seraphim', 'spend_type', function( x )
            return spec.protection and 'mana' or x
        end )

        addHandler( 'seraphim', function ()
            if spec.retribution then
                applyBuff( 'seraphim', 15 + ( holy_power.current > 0 and 15 or 0 ) )
                if holy_power.current >= 1 then spend( 1, 'holy_power' ) end
            elseif spec.protection then
                applyBuff( 'seraphim', 8 * min( 2, cooldown.shield_of_the_righteous.charges_fractional ) )

                if cooldown.shield_of_the_righteous.charges >= 2 then
                    spendCharges( 'shield_of_the_righteous', 2 )
                else
                    cooldown.shield_of_the_righteous.charge = 0
                    cooldown.shield_of_the_righteous.duration = class.abilities.shield_of_the_righteous.recharge
                    cooldown.shield_of_the_righteous.expires = now + offset + cooldown.shield_of_the_righteous.duration
                    cooldown.shield_of_the_righteous.recharge_began = now + offset
                    cooldown.shield_of_the_righteous.next_charge = cooldown.shield_of_the_righteous.expires
                    cooldown.shield_of_the_righteous.recharge = cooldown.shield_of_the_righteous.duration
                end
            end
        end )


        addAbility( 'shield_of_the_righteous', {
            id = 53600,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 16,
            charges = 3,
            recharge = 16,
            ready = function () return max( 0, last_shield_of_the_righteous + 1 - ( now + offset ) ) end
        } )

        modifyAbility( 'shield_of_the_righteous', 'cooldown', function( x )
            return x * haste 
        end )

        modifyAbility( 'shield_of_the_righteous', 'recharge', function( x )
            return x * haste
        end )

        addHandler( 'shield_of_the_righteous', function ()
            last_shield_of_the_righteous = now + offset
            applyBuff( 'shield_of_the_righteous', buff.shield_of_the_righteous.remains + 4.5 )
            removeBuff( 'blessed_stalwart' )

            if talent.righteous_protector.enabled then
                if talent.hand_of_the_protector.enabled then setCooldown( 'hand_of_the_protector', max( 0, cooldown.hand_of_the_protector.remains - 3 ) )
                else setCooldown( 'light_of_the_protector', max( 0, cooldown.light_of_the_protector.remains - 3 ) ) end
                setCooldown( 'avenging_wrath', max( 0, cooldown.avenging_wrath.remains - 3 ) )
            end
        end )


        addAbility( 'shield_of_vengeance', {
            id = 184662,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 120,
            usable = function () return settings.shield_damage == 0 or incoming_damage_3s > ( health.max * settings.shield_damage / 100 ) end,
        } )

        modifyAbility( 'shield_of_vengeance', 'cooldown', function( x )
            return x - ( 10 * artifact.deflection.rank )
        end )

        addHandler( 'shield_of_vengeance', function ()
            applyBuff( 'shield_of_vengeance', 15 )
        end )


        addAbility( 'templars_verdict', {
            id = 85256,
            spend = 3,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
        } )

        modifyAbility( 'templars_verdict', 'spend', function( x )
            if buff.divine_purpose.up then return 0
            elseif buff.the_fires_of_justice.up then return x - 1 end
            return x
        end )

        addHandler( 'templars_verdict', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            elseif buff.the_fires_of_justice.up then removeBuff( 'the_fires_of_justice' ) end
            if equipped.whisper_of_the_nathrezim then applyBuff( 'whisper_of_the_nathrezim', 4 ) end
            if spec.retribution and talent.fist_of_justice.enabled then setCooldown( 'hammer_of_justice', max( 0, cooldown.hammer_of_justice.remains - 8 ) ) end
        end )


        addAbility( 'wake_of_ashes', {
            id = 205273,
            spend = 0,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 30,
            known = function () return equipped.ashbringer and ( toggle.artifact_ability or ( toggle.cooldowns and settings.artifact_cooldown ) ) end,
            usable = function () return not artifact.ashes_to_ashes.enabled or holy_power.current <= settings.maximum_wake_power end
        } )

        modifyAbility( 'wake_of_ashes', 'spend', function( x ) 
            if artifact.ashes_to_ashes.enabled then return -5 end
            return x
        end )

        addHandler( 'wake_of_ashes', function ()
            if target.is_undead or target.is_demon then applyDebuff( 'target', 'wake_of_ashes', 6 ) end
            if equipped.ashes_to_dust then
                applyDebuff( 'target', 'ashes_to_dust', 6 )
                active_dot.ashes_to_dust = active_enemies
            end
        end )


        addAbility( 'word_of_glory', {
            id = 210191,
            spend = 3,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 60,
            charges = 2,
            recharge = 60,
            talent = 'word_of_glory'
        } )

        modifyAbility( 'word_of_glory', 'spend', function( x )
            if buff.divine_purpose.up then return 0
            elseif buff.the_fires_of_justice.up then return x - 1 end
            return x
        end )


        addHandler( 'word_of_glory', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            elseif buff.the_fires_of_justice.up then removeBuff( 'the_fires_of_justice' ) end
            health.actual = min( health.max, health.actual + ( 1.33 * stat.spell_power * 8 ) )
        end )


        addAbility( 'zeal', {
            id = 217020,
            spend = -1,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 4.5,
            charges = 2,
            recharge = 4.5,
            talent = 'zeal'
        } )

        modifyAbility( 'zeal', 'cooldown', function( x )
            return x * haste
        end )

        modifyAbility( 'zeal', 'recharge', function( x )
            return x * haste
        end )

        addHandler( 'zeal', function ()
            addStack( 'zeal', 12, 1 )
        end )

    end


    storeDefault( [[Protection ST]], 'actionLists', 20170727.205954, [[dWtfgaGAIkTEIQQnHKk7Ik2gfzFiP0SP08rsYNqs4Buu3gvTtuzVIDJy)sYOqsvdtknovQOtRQHIKudMQA4iXbrkNsLQ6yQ4CQujlKkzPeLftHLJYdvPk9uWYqQEUetuLk1uLIjlvtN0fvjDzONrL66k09iQYRjQWMvj2Uc0Hv67kGptvMNkvXirs0FLuJMiJxLkCsvktdjfxJOIoVcALevLhROFt4CstaGco)1(Y)QVGeotMcat2trdeqgAXTGHJE7XCRz60DoYj1CChGB5XauntO4uFbPYhAcqBQVGust4oPjWQklnrdCLSgwShxbGj7POb0NhLxBaAmVsaYYJYty71dSSa0mE7RddqrOVGe4gP)ZvfSaebbdidT4wWWrV9y6y2P19ja3YJbOAH(cs0WrpnbUswdl2JRaClpgqgAmkhyayYEkAav45zrNNOiJnsrlbKHwCly4O3EmDm706(e4gP)ZvfSaebbdqZ4TVomadngLdmWQklnrJgo3PjWvYAyXECfGB5Xa0gejEiJkkv(G0J2EayYEkAGcQ1gcYyXrFKrVTMoLzLp1w5FQ8PkQQYN6R8ngVCXXJTKE9Knw2oYCgPu5tDv(6ArI6mzJLTJSsTCh7E8irDqYAyXELp1v5pfcBxmaXrUJDpEKOotPL5HLk)7PY)u5F)aYqlUfmC0BpMoMDADFcCJ0)5QcwaIGGbOz82xhgyhejEiRuxKE02dSQYst0OHJAstGRK1WI94ka3YJbKVXUhps0aWK9u0abKHwCly4O3EmDm706(e4gP)ZvfSaebbdqZ4TVomGCh7E8irdSQYst0OHtottGRK1WI94ka3YJbUxbPGt2QVGeaMSNIgiGm0IBbdh92JPJzNw3Na3i9FUQGfGiiyaAgV91HbMcsbNSvFbjWQklnrJgotPjWvYAyXECfGB5XaUSyPG9kFQC55rwayYEkAGPqy7IbiogwSuWET0YZJmNP0Y8Wc1EcqJ5vceqgAXTGHJE7X0XStR7tGBK(pxvWcqeemanJ3(6WagwSuWET0YZJSaRQS0enA4mNMaRQS0ena3YJbOYLNhzv(Ilv(Qew5l79KuumwcqZ4TVomG0YZJSAXLAvcRzVNKIIXsazOf3cgo6ThthZoTUpbUr6)CvblarqWaWK9u0abUswdl2JROH7ottGRK1WI94kamzpfnWuiSDXaeNI0J2ET4sTkH1S3tsrXyXzkTmpSiVPqy7IbiofPhT9AXLAvcRzVNKIIXIZuAzEyPMFVJa0mE7RdduKE02RfxQvjSM9EskkglbUr6)CvblarqWa06dUKj2JRaClpgaKE02R8fxQ8vjSYx27jPOySeqgAXTGHJE7X0XStR7tayYEkAZqkya95XaRQS0enA4UR0e4kznSypUcWT8yaAdIepKrfLkFq6rBVYN6p3pamzpfnqazOf3cgo6ThthZoTUpbUr6)CvblarqWa0mE7RddSdIepKvQlspA7bwvzPjA0ObUB8YoA14kAc]] )

    storeDefault( [[Protection Defensives]], 'actionLists', 20170727.205954, [[deJzcaGEjH2evLSljvBJOmtQkmBkDBIQDsO9k2nf7xvgLKGHPGFdmuvkdwvnCQ0bLKofvv6ykAHkKLsQSycA5K8uKLPsEUetus0uPktMith1fvP6zKQUob2mvSDQQY3iftJQsDALgjvvCzOrlvFMu6Kkuhg01OQOZlP8xv8AQQQhlLZmEHeHYXq3uagB8cmVFLOdAkR)WsOkrhOalNrH0HwewWiEnm1mO56Q(0N(EQpe5ITfA3kc5fyIOmzHQ24fykXlIZ4fcYSkEHdrn16YHyOX)Rr777R3xqbpL(IwPqIq5yiQVOv69boVp3X3x3QTZiqq59RW0VHQkCTlxluPVOv6aCoChpQvBNrGGsiDOfHfmIxdtztn1h0pdn2iTniduHmadg6Ubk0IszuiQPwx2RMlgQSYBHJ4v8cD3afArPmke1uRlhsqbpf06C6i0gsekhd5hOr69boVp3X3)McWyJbQq6qlclyeVgMYMAQpOFgASrABqgOczagmuvHRD5AH6qJ0b4C4oECvagBmqfcYSkEHdhr9Xl0DduOfLYOqutTUCibf8uqRZPJqBirOCmKpwTD(9boVp3X3)McWyJbQq6qlclyeVgMYMAQpOFgASrABqgOczagmuvHRD5AHSR2oFaohUJhxfGXgduHGmRIx4WHdrn16YHcNaa]] )

    storeDefault( [[Protection Cooldowns]], 'actionLists', 20170727.205954, [[d4Y1baGEIQAxef2gPWSf62sPDkv7fTBq7Ncnmk53egkrPgmPYWf4Ga1XaSqsvlLQAXsXYj5Hev5PklJk9CrMirjtLitMkMUKlsPCzORtrTzkvBNuQVsu00iQ03jfDAvDyvgnf8nGCsb1ZiLCnIkopv5XI6VcYNPitakXjl0(zowupx)ArozRefMRxanQtEcr0rOjmX5Jr8si7UwaGSa56kda5ixaT4waM)l(Y)Qxazxdn4aNRxatuIDakXzdEnr0H65ww9bfhxyOZNVsO4GciYbU5JF5XLq1fy4B58XKWSkJjkXIZhJ4Lq2DTaabyX1VwKBO6cm8TSy3LsC2GxteDOEULvFqXXfg685RekoOaICGB(4xECOhgsypu5P48XKWSkJjkXIZhJ4Lq2DTaabyX1VwKZMhAuNWUrDsEkwSRfL4SbVMi6q9ClR(GIJZhtcZQmMOeloWnF8lpUtBeA6HMcPP6kdCHHoF(kHIdkGiNpgXlHS7AbacWIRFTihyTrOPhAYOozQUYalwClR(GIJfja]] )

    storeDefault( [[Protection Default]], 'actionLists', 20170727.205954, [[d4cWcaGEPiTluKTPu0SH6Mer3wuTtPAVu7wX(vHHjk)wyOOWGvrdNiDqr0XqPfkfwkr1IvjlxjpukQNcwMk1ZjmrLQMQuAYqA6KUie5QsrCzKRlcBwKSDuutdIY3jcNwY3ikpgvNuK6zkfUgevNxP0FHWNvQCyvTzDRH(NtgyScL4AfZX5Ek1NaRgaPeVEC10xRyCFZnniNW0li3VZyLLj7(MjwKJm2nma8vjvnyijxRyeU1Dw3AaP5VWeQByO)5KbgRqjUwXCCUNsrJOyMega(QKQg0y3omXucbHaLsrJOyMegKty6fK73zSYyZmKEql(RXYWedzi5vHlDRb(JXiEUwXGaxc1GKbA)ZjdmwHsCTI54CpLIgrXmjS6(TBnG08xyc1nm0)CYaJvOexRyooBocmAiXima8vjvnOXUDyIjEey0qIryqoHPxqUFNXkJnZq6bT4VgldtmKHKxfU0Tg4pgJ45AfdcCjudsgO9pNmWyfkX1kMJZMJaJgsmcRUVHBnG08xyc1nma8vjvnyi9Gw8xJLHjgYqYRcx6wdjeeIsPCHb5KisS4KWTwniNW0li3VZyLXMzO)5KHMiOJZ0kLlS6oYCRbKM)ctOUHH(NtgyScL4AfZXj0Aa4RsQAWGCctVGC)oJvgBMH0dAXFnwgMyidjVkCPBnWFmgXZ1kge4sOgKmq7FozGXkuIRvmhNqRvRg2tP(ey1nSAd]] )

    storeDefault( [[SimC Retribution: opener]], 'actionLists', 20171010.193328, [[dOdXfaGAqjTEqPAxKW2KGyFsq1Sf18bHBku3gWovyVu7gP9lOtt0WKOFl1Hv6VkYGfYWbvhuc9nuvhdOoUIQAHc0sbPfJslNWdbfpfAzOspxKjckLPcKjtQPJ4IOGlR6zkQORtsBurf2kkYMjrBxr5Xs6RsqzAkQY3rrnsji9zq0OrfRtrLCsuOdjbCnjqNxaReuIZPOs9AuLnydY4ybUrucatye0teswvISPZvyud)0lmcBx5QMjoOrOp)nDp4wcMFjFU8vWTSGZDbNNrSkKWjgnwSsKnnzqEa2GmYaDzZx7GgXQqcNyK0qcz(kQDN1nZ0KXISYSKeWiBUB9KsvraJms1Y6sAHrAtVX4wZ0kglWnACSa3yWC36WO5qveWi0N)MUhClbZhCPrOp1QI6tgKjgHHZR8I7zh4uIzng36XcCJM4bxdYid0LnFTdAeRcjCIrsdjK5RO2Dw3mttglYkZssaJSxKUGNKcPrgPAzDjTWiTP3yCRzAfJf4gnowGBm4fPl4jPqAe6ZFt3dULG5dU0i0NAvr9jdYeJWW5vEX9SdCkXSgJB9ybUrt8yoniJmqx281oOrSkKWjglqyu6Kj2MQMuqKxWTCIl8AyuHhgvASiRmljbmUI6s)ePfItjgzKQL1L0cJ0MEJXTMPvmwGB04ybUXII6sFyeOwioLye6ZFt3dULG5dU0i0NAvr9jdYeJWW5vEX9SdCkXSgJB9ybUrt8yEgKrgOlB(Ah0yrwzwscyewv1qcCkXiJuTSUKwyK20BmU1mTIXcCJghlWnclQAiboLye6ZFt3dULG5dU0i0NAvr9jdYeJWW5vEX9SdCkXSgJB9ybUrt8OGgKrgOlB(Ah0iwfs4eJF(Qs4WVwrwUAHKMMuQkcmPsZFtCUomccicJeB9kyZDRNEwzyeeqegvGWOA3zDZmvbZlVp1kN2eNNuOc3yrwzwscyKnV6p1kNGv1erwVrgPAzDjTWiTP3yCRzAfJf4gnowGBmyE1pmQvggblQjISEJqF(B6EWTemFWLgH(uRkQpzqMyegoVYlUNDGtjM1yCRhlWnAIhfIbzKb6YMV2bnIvHeoX4NVQeo8RvKLRwiPPjLQIatQ083eNRdJGaIWiXwVc2C36PNvggbbeHrfimQ2Dw3mtvW8Y7tTYPnX5jfQWnwKvMLKag1Yzs6N4SaaxyKrQwwxslmsB6ng3AMwXybUrJJf4gHn5mj9Hrf6caCHrOp)nDp4wcMp4sJqFQvf1NmitmcdNx5f3ZoWPeZAmU1Jf4gnXd(gKrgOlB(Ah0yrwzwscyK5L3NALtBIZtgzKQL1L0cJ0MEJXTMPvmwGB04ybUXcB59WOwzyuXeNNmc95VP7b3sW8bxAe6tTQO(KbzIry48kV4E2boLywJXTESa3OjMyeH)QCZsyFjYM6b)stSb]] )

    storeDefault( [[SimC Retribution: default]], 'actionLists', 20171010.193328, [[dyt)daGEcuTlcsVwr1mvenBIUjqUTe7ef7vSBq7xLgfbvdtf(TsdgWWPsDqG6uKcoMk6CeiwibSucTyuA5K8qQQNcTmuXZL0ePsQPIknzu10PCrsjNwQlJCDQ4WQARKkTzsH2oPIVrQ68KsnnckFNkj)vr6XkmAQeRJQ0jjf9zQIRrqCpfH5rGYIuuEgbsNZWniZxOGyx8VaIKPAwhRxO3lapPX3rAbDnPX3rArGGIKK(kfgohN6p0ZrVq5CiebricliouTBlyqWdRxynCdZz4gul4Zkj(iqqCOA3wqB94rscTHgPuoUTAqWSTSnTdQiwN5uqnH894TvfeUqkiOLx3xX8fkyqMVqbfjwN5uqrssFLcdNJt9NhbfP66OgunCJf03fAmh0QdviOf2GGwEMVqbJfgoHBqTGpRK4JabXHQDBbTUqxab7cWjiy2w2M2bhVuo9hwVWPYUAb9DHgZbT6qfcAHniOLx3xX8fkyqMVqb9FP8caEy9cVat2vliyLNAq4xOjMHDX)cisMQzDSEHEVaRBcsQzbfjj9vkmCoo1FEeuKQRJAq1WnwqnH894TvfeUqkiOLN5luqSl(xarYunRJ1l07fyDtqsflmcA4gul4Zkj(iqqWSTSnTdoEPC6pSEHtLD1cQjKVhVTQGWfsbbT86(kMVqbdY8fkO)lLxaWdRx4fyYUAxaHFQHGGvEQbHFHMyg2f)lGizQM1X6f69cm2vYVUcwNfuKK0xPWW54u)5rqrQUoQbvd3yb9DHgZbT6qfcAHniOLN5luqSl(xarYunRJ1l07fySRKFDfSglmclCdQf8zLeFeiiy2w2M2bhVuo9hwVWPYUAb1eY3J3wvq4cPGGwEDFfZxOGbz(cf0)LYla4H1l8cmzxTlGW5OHGGvEQbHFHMyg2f)lGizQM1X6f69c4HGK6TvvNfuKK0xPWW54u)5rqrQUoQbvd3yb9DHgZbT6qfcAHniOLN5luqSl(xarYunRJ1l07fWdbj1BRQglwq0nn6x2c(B9cdJ(Jyja]] )

    storeDefault( [[SimC Retribution: precombat]], 'actionLists', 20171010.193328, [[b4vmErLxt5uyTvMxtnvATnKFGjvz0jxAIvhDP9MB64hyWjxzJ9wBIfgDEnfrLzwy1XgDEjKxtjvzSvwyZvMxojdmXCdm3iZnUidm1Ktn041utnMCPbhDEnLxtf0y0L2BUnNxu5LtX4fvEnvrUfMySvgzEjKxtn1yYLgC051u092zNXwzUa3B0L2BUnNxtfKyPXwA0LNxtb3B0L2BU51udHwzJTwtVzxzTvMB05LyEnvtVrMvHjNtH1wzEnLxt5uyTvMxtb1B0L2BU51ubj3zZ51uUfwBL1JiVXgzFDxyYjIxtjvzSvwyZvMxojdmXCtmW41usv2CVvNCJv2CErLx051uj5gzPnwy09MCEnLBV5wzEnvtVrMtH1wzEn1BSr2x3fMCErNx051utbxzJLwySLMEHrxAV5MxoDdmErNxEb]] )

    storeDefault( [[SimC Retribution: cooldowns]], 'actionLists', 20171010.193328, [[dmKDjaGiPiSjvHgfvkNIkQvrLQAxuQHHihtvAzIKNHOQPHOIRrfX2OIu9nG04OsL6CiQ06KcZtksDpvb7tkQdQkAHaXdjetKkvYfPsSrQufJukIojvs3uv1orLHsfPSuQWtjnvc1wjK(QuK8wQur3LkvP9Q8xanykoSklMGhtvtwWLH2Su6ZIy0aCAHwnvK41ikZwu3gHDJ0VLmCvLJtfjTCuEUunDqxhvTDrQVtjopL06PsfMpqTFIEVt8uUJaNQrcrKghiKff4HXI2qA8vLdLfAFQ(H(4LJUJdgl64aL0uhygVooUuKEbLe5s61(L8Pi9sotvpl(bNo9PhglAFIh37ep1f6jKXWazQ6zXp4u3Kgb(2wBpJVFb0M)tAEuAe4BBT9m((fq7o88Kjnn)G086ePbmyPXxvouwO2EgF)cOndjUiTlnnlnj(G04(stkPXzPbmyPXnPrGVT1(sJ0KinbOf2bbyZ)jnGbln(QYHYc1(sJ0KinbOf2bbyZqIls7stZstIpinUV0KsACE6tHyocToT)HEiYawTafqi7SE5PIaa9K9xPrcKcNW0)ki6X4ocC6uUJaNc232EKN8obrWnzeIenEDY7l5sQrJgnA0OrJgnA0OrJgGb4o1p0drM0uTsdiiKDwVS7fmaWSPpzj9P0JaFO)HEiYawTafqi7SE5PoWmEDCCPi9c6lPPoWEXZ8yFIhCQR0q0FWInLwuC6Ff4ocC6GJl1ep1f6jKXWazQ6zXp4uyLKKr7VcglAxAEuACtACtAe4BBTfYvfY8DOn)N0agS0iW32AFPrAsKMa0c7GaS5)KgWGLgb(2wBpJVFb0M)tAEuAe4BBT9m((fqBgsCrAxAAAPjLtKgWGLg4XsqOnmsGaHfWqeLMM(bPHCijnolnop9PqmhHwN(vWyrNkca0t2FLgjqkCct)RGOhJ7iWPt5ocCQtRGXIo9jlPpLEe4dnrLdaTCSMyQdmJxhhxksVG(sAQdSx8mp2N4bN6kne9hSytPffN(xbUJaNw5aqlhBWXr(jEQl0tiJHbYu1ZIFWPWkjjJ2(QYHYcTp9PqmhHwNkKRkaSLNzDQR0q0FWInLwuC6Ffe9yChboDk3rGtbjxvqACp8mRtDGz8644sr6f0xstDG9IN5X(ep4uraGEY(R0ibsHty6Ff4ocC6GJJCM4PUqpHmggitvpl(bNcRKKmA7Rkhkl0(0NcXCeADQaY6iJSinzQR0q0FWInLwuC6Ffe9yChboDk3rGtbbzDKrwKMm1bMXRJJlfPxqFjn1b2lEMh7t8Gtfba6j7VsJeifoHP)vG7iWPdooNmXtDHEczmmqMQEw8do1nPrGVT12Z47xaT5)KgWGLgb(2w7lnstI0eGwyheGn)N04S08O0aOYwb(vwqMTNNXqkuAEqAsjnpknUjn(QYHYc1wiFbey1c0PW3HrpAZqIls7stZstIpinGbln(QYHYc1oethPiqahbbYSziXfPDPPzPjXhKgNN(uiMJqRtpM)OiqyXyifo1vAi6pyXMslko9VcIEmUJaNoL7iWPpz(JIsJ4IXqkCQdmJxhhxksVG(sAQdSx8mp2N4bNkca0t2FLgjqkCct)Ra3rGthCCo9jEQl0tiJHbYu1ZIFWPWkjjJ2(QYHYcTp9PqmhHwNcOYwbAHDqatDLgI(dwSP0IIt)RGOhJ7iWPt5ocCAtwzRsttXoiGPoWmEDCCPi9c6lPPoWEXZ8yFIhCQiaqpz)vAKaPWjm9VcChboDWXb6ep1f6jKXWaz6tHyocToTdiI5aWQfyAKMGh1JtDLgI(dwSP0IIt)RGOhJ7iWPt5ocCQciI5G0uTsJOinbpQhN6aZ41XXLI0lOVKM6a7fpZJ9jEWPIaa9K9xPrcKcNW0)kWDe40bhN7EIN6c9eYyyGmv9S4hCkSssYOTVQCOSq7tFkeZrO1PxAKMePjaTWoiGPUsdr)bl2uArXP)vq0JXDe40PChbo9zAKMePjsttXoiGPoWmEDCCPi9c6lPPoWEXZ8yFIhCQiaqpz)vAKaPWjm9VcChboDWXrUt8uxONqgddKPQNf)GtHvssgT9vLdLfAxAEuACtAauzRa)kliZ2ZZyifknn)G0qEPbmyPXnPXnPbDQ8XVpmyNJxGfPDGT8mRa5Pz86aWG0agS0WopAlKRkaeZTsJZsZJsdGkBf4xzbz2EEgdPqPP5hKMusJZsJZtFkeZrO1PEgF)c4uxPHO)GfBkTO40)ki6X4ocC6uUJaNkcJVFbCQdmJxhhxksVG(sAQdSx8mp2N4bNkca0t2FLgjqkCct)Ra3rGthCWPUlS94ZWbYGBa]] )

    storeDefault( [[SimC Retribution: priority]], 'actionLists', 20171010.193328, [[duuwNaqiauTjjXNqvHrrj6uucRIQOMfas6wai1UivdJs6yaAzuLEMKetdaCnvqBJQi(gQQghvrY5aqzDufP08qvP7PcSpjPoivvwivv9qQctevfDrrjJKQivNuuQvkjPUjQyNK0sffpvyQuQ2kQsFLQifRfaj2l0FjXGr6WsTys5XuzYuCzLnRI(mvLrJkDAcRMsXRbOzd0TLy3e9BedxuDCaelxvpxKPd66Q02LuFhvX4LKKZRcTEaO5tP0(rzeiAhd1UmmcrXdgnZGVq7cfePNwgn)fKxapIrKpNObfaydfejQYVvmYmW1PHQETcKFRamVw1b6jh69WQGr4Eroedm8ZbfezcTJQar7yKLS1aNb9hJW9ICigTdkQNYKRiwIr57bmAvy0kmQLmQJqaneEK62Cn(ktc1)vAHmXO8Lr95mmQNzuaq)qg1wBzuZ0UNN62Cn(ktc1)vAHmXOvZO(Cgg1ZmkaOFiJAbg(PjafWJySQAUluqKkPjHt6ggzlncxdjpgsICyWHy4TF1UmmWqTldJSQQ5UqbrYOXKWjDdJmdCDAOQxRa5hOvmYSe5(ULq7iedp4ohGCi1Rmje1WGdXO2LHbcrvVODmYs2AGZG(Jr4EroeJ2bf1tzYvelXOvFaJ6LrT1wg1sgv7EEQNC9doOIqcqUIKas(KYQQ877RHcIupbBhGmA1hWOEbymAfg1sgv7EEQ31t6ti9PWZ3qU63Cg1wBzulzuT75PU7VP2m9BoJwHr1UNN6U)MAZ0tW2biJw9bmkWdzulyuBTLrTKrDecOHWJu393uBM(VslKjgTAgf4HmAfgfGZOA3ZtD3FtTz63Cg1cg1wBzuhHaAi8i176j9jK(u45Bix9FLwitmA1mkWdzulyulWWpnbOaEeJ6(fTg4WWdUZbihs9ktcrnm4qm82VAxggMKIRtWwdCyO2LHraj)yuEBW7WWV3xcdzx2bMKIRtWwdCauRBW7oODqr9uMCfXsvFGxBT1sT75PEY1p4Gkcja5ksci5tkRQYVVVgkis9eSDaw9bEbyvSu7EEQ31t6ti9PWZ3qU63CBT1sT75PU7VP2m9BEfT75PU7VP2m9eSDaw9bap0cBT1shHaAi8i1D)n1MP)R0czQAGhwbGRDpp1D)n1MPFZTWwBDecOHWJuVRN0Nq6tHNVHC1)vAHmvnWdTWcmYmW1PHQETcKFGwXiZsK77wcTJqmYwAeUgsEmKe5WGdXO2LHbcr1QG2XilzRbod6pgH7f5qmS5A8vMeQqQ3)cZy0kmAD)IwdC6MKIRtWwdCmAfgv7EEQBe1c5uYVFojn9BoJwHr1UNN6grTqoL87Ntst)xPfYeJYxg1NZWOEMr9IHFAcqb8iggrTqoLeK8fmYwAeUgsEmKe5WGdXWB)QDzyGHAxgg8POwihJgqYxWiZaxNgQ61kq(bAfJmlrUVBj0ocXWdUZbihs9ktcrnm4qmQDzyGqufaq7yKLS1aNb9hJW9ICig2Cn(ktcvi17FHzmAfgTUFrRboDtsX1jyRbogTcJYLaEujNWZED39)jHmA1hWOhYOvyuT75PUrulKtj)(5K00V5y4NMauapIHrulKtjbjFbJSLgHRHKhdjrom4qm82VAxggyO2LHbFkQfYXObK8fg1sGwGrMbUonu1RvG8d0kgzwICF3sODeIHhCNdqoK6vMeIAyWHyu7YWaHO6HODmYs2AGZG(Jr4EroedBUgFLjHkK69VWmgTcJ2oOOEktUIyjgT6dyuVmAfgLlb8OsoHN96U7)tcz0QpGrRcJwHrTKr1UNN6U)MAZ0V5mAfgv7EEQ7(BQntpbBhGmkFzuGhYO2AlJQDpp1bfT5fYKY59pQCLGRtCNr)MZOwGHFAcqb8iggrTqoLeK8fmYwAeUgsEmKe5WGdXWB)QDzyGHAxgg8POwihJgqYxyul9Abgzg460qvVwbYpqRyKzjY9DlH2rigEWDoa5qQxzsiQHbhIrTlddeIQEcAhJSKTg4mO)yeUxKdXWMRXxzsOcPE)lmJrRWO19lAnWPBskUobBnWXOvyuUeWJk5eE2R7U)pjKrR(ag9qm8ttakGhXWiQfYPKGKVGr2sJW1qYJHKihgCigE7xTlddmu7YWGpf1c5y0as(cJAzvSaJmdCDAOQxRa5hOvmYSe5(ULq7iedp4ohGCi1Rmje1WGdXO2LHbcrv(r7yKLS1aNb9hJW9ICig2Cn(ktcvi17FHzmAfgv7EEQBe1c5uYVFojn9BoJwHr1UNN6grTqoL87Ntst)xPfYeJYxg1NZWOEMr9YOvyuaoJoaYvKNpJopCfP89kKtfi3PiBi3FaOOGHFAcqb8ig2CtqHR)Ks9K(wlDdJSLgHRHKhdjrom4qm82VAxggyO2LHrvFtqHRF(iXO8oPV1s3WiZaxNgQ61kq(bAfJmlrUVBj0ocXWdUZbihs9ktcrnm4qmQDzyGqu1tH2XilzRbod6pgH7f5qmS5A8vMeQqQ3)cZy0kmkxc4rLCcp71D3)NeYOvFaJEiJwHr1UNN6grTqoL87Ntst)MZOvyuaoJoaYvKNpJopCfP89kKtfi3PiBi3FaOOGHFAcqb8ig2CtqHR)Ks9K(wlDdJSLgHRHKhdjrom4qm82VAxggyO2LHrvFtqHRF(iXO8oPV1s3yulbAbgzg460qvVwbYpqRyKzjY9DlH2rigEWDoa5qQxzsiQHbhIrTlddeIQam0ogzjBnWzq)XiCVihIHnxJVYKqfs9(xygJwHr1UNN6grTqoL87Ntst)MZOvyuT75PUrulKtj)(5K00)vAHmXO8Lr95mmQNzuVy4NMauapIbCLCW(tk17ncheJSLgHRHKhdjrom4qm82VAxggyO2LHH9vYb7NpsmkV7ncheJmdCDAOQxRa5hOvmYSe5(ULq7iedp4ohGCi1Rmje1WGdXO2LHbcrvGwr7yKLS1aNb9hJW9ICig2Cn(ktcvi17FHzmAfgLlb8OsoHN96U7)tcz0QpGrpKrRWOA3ZtDJOwiNs(9ZjPPFZXWpnbOaEed4k5G9NuQ3BeoigzlncxdjpgsICyWHy4TF1UmmWqTldd7RKd2pFKyuE3BeoiJAjqlWiZaxNgQ61kq(bAfJmlrUVBj0ocXWdUZbihs9ktcrnm4qmQDzyGqufiq0ogzjBnWzq)XiCVihIHnxJVYKqfs9(xygJwHr5sapQKt4zVU7()KqgT6dy0QWOvyulzuT75PU7VP2m9BoJwHr1UNN6U)MAZ0tW2biJYxgf4HmQT2YOA3ZtDqrBEHmPCE)Jkxj46e3z0V5mQfy4NMauapIbCLCW(tk17ncheJSLgHRHKhdjrom4qm82VAxggyO2LHH9vYb7NpsmkV7nchKrT0RfyKzGRtdv9Afi)aTIrMLi33TeAhHy4b35aKdPELjHOggCig1UmmqiQc0lAhJSKTg4mO)yeUxKdXWMRXxzsOcPE)lmJrRWOCjGhvYj8Sx3D)FsiJw9bm6Hy4NMauapIbCLCW(tk17ncheJSLgHRHKhdjrom4qm82VAxggyO2LHH9vYb7NpsmkV7nchKrTSkwGrMbUonu1RvG8d0kgzwICF3sODeIHhCNdqoK6vMeIAyWHyu7YWaHOkWQG2XilzRbod6pgH7f5qmS5A8vMeQqQ3)cZy0kmAD)IwdC6MKIRtWwdCmAfgTFO4SDqLwtakGhz0kmA)qXz7G680aofYPsN4UK(KTg4mmAfg1riGgcpsDEAaNc5uPtCxs)xPfYeJYxg1NZWOEMr9IHFAcqb8iggrTqoLeK8fmYwAeUgsEmKe5WGdXWB)QDzyGHAxgg8POwihJgqYxyulbalWiZaxNgQ61kq(bAfJmlrUVBj0ocXWdUZbihs9ktcrnm4qmQDzyGqufiaG2XilzRbod6pgH7f5qmS5A8vMeQqQ3)cZy0kmAD)IwdC6MKIRtWwdCmAfgv7EEQZdxrkFVc5ubYDkYgY9hakk63CgTcJQDpp15HRiLVxHCQa5ofzd5(daff9FLwitmkFzuFodJ6zgfO(Hy4NMauapIHrulKtjbjFbJSLgHRHKhdjrom4qm82VAxggyO2LHbFkQfYXObK8fg1YdTaJmdCDAOQxRa5hOvmYSe5(ULq7iedp4ohGCi1Rmje1WGdXO2LHbcrvGhI2XilzRbod6pgH7f5qmSKrha5kYZNrNhUIu(EfYPcK7uKnK7pauuyuBTLrT5A8vMeQqQ3)cZyuly0kmA)qXz7GkTMauapYOvy0(HIZ2b15PbCkKtLoXDj9jBnWzy0kmQJqaneEK680aofYPsN4UK(VslKjgLVmQpNHr9mJ6fd)0eGc4rmGRKd2FsPEVr4GyKT0iCnK8yijYHbhIH3(v7YWad1UmmSVsoy)8rIr5DVr4GmQLaGfyKzGRtdv9Afi)aTIrMLi33TeAhHy4b35aKdPELjHOggCig1UmmqiQc0tq7yKLS1aNb9hJW9ICig2Cn(ktcvi17FHzmAfgv7EEQZdxrkFVc5ubYDkYgY9hakk63CgTcJQDpp15HRiLVxHCQa5ofzd5(daff9FLwitmkFzuFodJ6zgfO(Hy4NMauapIbCLCW(tk17ncheJSLgHRHKhdjrom4qm82VAxggyO2LHH9vYb7NpsmkV7nchKrT8qlWiZaxNgQ61kq(bAfJmlrUVBj0ocXWdUZbihs9ktcrnm4qmQDzyGqufi)ODmYs2AGZG(Jr4EroeddbQVQAUluqKkPjHt6Mou4aui9XOvyudbQVQAUluqKkPjHt6M(VslKjgLVmQpNHr9mJ6LrRWOMPDpp1T5A8vMeQ)R0czIr5lJ6ZzyupZOEXWpnbOaEedBUgFLjHyKT0iCnK8yijYHbhIH3(v7YWad1UmmQ6RXxzsigzg460qvVwbYpqRyKzjY9DlH2rigEWDoa5qQxzsiQHbhIrTlddeIQa9uODmYs2AGZG(Jr4EroedlzuhHaAi8i11aBZuiNk2CtqHB6)kTqMy0QzuFodJ6zg1lJARTmQJqaneEK6grTqofUDPSx)xPfYeJwnJ6ZzyupZOEzulWWpnbOaEedhrMM7BOGiXiBPr4Ai5XqsKddoedV9R2LHbgQDzy4brMM7BOGiXiZaxNgQ61kq(bAfJmlrUVBj0ocXWdUZbihs9ktcrnm4qmQDzyGqufiadTJrwYwdCg0Fmc3lYHyyjJYLaEujNWZED39)jHmkFpGrTYO2AlJYLaEujNWZED39)jHm6bmkqgTcJAjJ6ieqdHhPUgyBMc5uXMBckCt)xPfYeJwnJ6ZzyuBTLrDecOHWJu3iQfYPWTlL96)kTqMy0QzuFodJAbJARTmkxc4rLCcp71D3)NeYOhWOEz0kmQLmQLmQJqaneEK6a4AqDh3(9TKY53oOGiBqgLVhWOw19KdzuBTLrDecOHWJu393uB2RKGVaWP742VVLuo)2bfezdYO89ag1QUNCiJAbJAbJAbg(PjafWJyWtd4uiNkDI7syKT0iCnK8yijYHbhIH3(v7YWad1Umm800aogLCYO(L4Uegzg460qvVwbYpqRyKzjY9DlH2rigEWDoa5qQxzsiQHbhIrTlddeIQETI2XilzRbod6pgH7f5qm4sapQKt4zVU7()KqgLVhWOvHrbOz00GkAe5nPdf79AvbaYDy4NMauapIHgyBMc5uXMBckCdJSLgHRHKhdjrom4qm82VAxggyO2LHH)GTzmk5KrR6BckCdJmdCDAOQxRa5hOvmYSe5(ULq7iedp4ohGCi1Rmje1WGdXO2LHbcrvVar7yKLS1aNb9hJW9ICigCjGhvYj8Sx3D)FsiJY3dy0QWOa0mAAqfnI8M0HI9ETQaa5om8ttakGhXWiQfYPWTlL9yKT0iCnK8yijYHbhIH3(v7YWad1Umm4trTqog1tVlL9yKzGRtdv9Afi)aTIrMLi33TeAhHy4b35aKdPELjHOggCig1UmmqiQ61lAhJSKTg4mO)y4NMauapIHnxJVYKqmYwAeUgsEmKe5WGdXWB)QDzyGHAxggv914RmjKrTeOfyKzGRtdv9Afi)aTIrMLi33TeAhHy4b35aKdPELjHOggCig1UmmqiQ6TkODmYs2AGZG(Jr4EroedhHaAi8i1bW1G6oU97BjLZVDqbr2GmA1hWOa19Kdz0kmkxc4rLCcp71D3)NeYO89agfay0kmQLmQJqaneEK6AGTzkKtfBUjOWn9FLwitmA1mQpNHr9mJ6LrT1wg1riGgcpsDJOwiNc3Uu2R)R0czIrRMr95mmQNzuVmQfmAfg1mT75PUnxJVYKq9FLwitmA1mQpNbd)0eGc4rmaW1GyKT0iCnK8yijYHbhIH3(v7YWad1UmmaOSgeJmdCDAOQxRa5hOvmYSe5(ULq7iedp4ohGCi1Rmje1WGdXO2LHbcrvVaaAhJSKTg4mO)yeUxKdXWriGgcpsD3FtTzVsc(caNUJB)(ws58BhuqKniJw9bmkqDp5qgfGMrHn4KqDi3PCk(LuiNk2CtqHB6cLjBnWzyupZOw19EiJwHr5sapQKt4zVU7()KqgLVhWOaaJwHrTKrDecOHWJuxdSntHCQyZnbfUP)R0czIrRMr95mmQNzuVmQT2YOocb0q4rQBe1c5u42LYE9FLwitmA1mQpNHr9mJ6LrTGrRWOMPDpp1T5A8vMeQ)R0czIrRMr95my4NMauapIH7VP2SxjbFbGdJSLgHRHKhdjrom4qm82VAxggyO2LHHh)n1M9mAaFbGdJmdCDAOQxRa5hOvmYSe5(ULq7iedp4ohGCi1Rmje1WGdXO2LHbcrvVhI2XilzRbod6pg(PjafWJy4iY0CFdfejgzlncxdjpgsICyWHy4TF1UmmWqTlddpiY0CFdfejJAjqlWiZaxNgQ61kq(bAfJmlrUVBj0ocXWdUZbihs9ktcrnm4qmQDzyGqu1RNG2XilzRbod6pgH7f5qmS5A8vMeQqQ3)cZy0kmAD)IwdC6MKIRtWwdCmAfgv7EEQBe1c5uYVFojn9Bog(PjafWJyye1c5usqYxWiBPr4Ai5XqsKddoedV9R2LHbgQDzyWNIAHCmAajFHrT0tSaJmdCDAOQxRa5hOvmYSe5(ULq7iedp4ohGCi1Rmje1WGdXO2LHbcrvV8J2XilzRbod6pgH7f5qmS5A8vMeQqQ3)cZy0kmAD)IwdC6MKIRtWwdCmAfgv7EEQd5oLtXVKc5uXMBckCt)MJHFAcqb8iggrTqoLeK8fmYwAeUgsEmKe5WGdXWB)QDzyGHAxgg8POwihJgqYxyul53cmYmW1PHQETcKFGwXiZsK77wcTJqm8G7CaYHuVYKquddoeJAxggiev96Pq7yKLS1aNb9hJW9ICig2Cn(ktcvi17FHzmAfgTUFrRboDtsX1jyRbom8ttakGhXWiQfYPKGKVGr2sJW1qYJHKihgCigE7xTlddmu7YWGpf1c5y0as(cJAPNYcmYmW1PHQETcKFGwXiZsK77wcTJqm8G7CaYHuVYKquddoeJAxggiev9cWq7yKLS1aNb9hJW9ICig2Cn(ktcvi17FHzmAfgv7EEQBe1c5uYVFojn9BoJwHrb4m6aixrE(m68WvKY3RqovGCNISHC)bGIcg(PjafWJyyZnbfU(tk1t6BT0nmYwAeUgsEmKe5WGdXWB)QDzyGHAxggv9nbfU(5JeJY7K(wlDJrT0RfyKzGRtdv9Afi)aTIrMLi33TeAhHy4b35aKdPELjHOggCig1UmmqiQwfRODmYs2AGZG(Jr4EroedBUgFLjHkK69VWmgTcJQDpp1nIAHCk53pNKM(nhd)0eGc4rmGRKd2FsPEVr4GyKT0iCnK8yijYHbhIH3(v7YWad1UmmSVsoy)8rIr5DVr4GmQLEIfyKzGRtdv9Afi)aTIrMLi33TeAhHy4b35aKdPELjHOggCig1UmmqiQwfGODmYs2AGZG(Jr4EroedBUgFLjHkK69VWmgTcJQDpp1HCNYP4xsHCQyZnbfUPFZXWpnbOaEed4k5G9NuQ3BeoigzlncxdjpgsICyWHy4TF1UmmWqTldd7RKd2pFKyuE3BeoiJAj)wGrMbUonu1RvG8d0kgzwICF3sODeIHhCNdqoK6vMeIAyWHyu7YWaHOAv8I2XilzRbod6pgH7f5qmS5A8vMeQqQ3)cZy0kmQLmkaNrHn4Kq9vvZDHcIujnjCs30NS1aNHrT1wg1riGgcps9vvZDHcIujnjCs30)vAHmXOvZO(Cgg1ZmQxg1cm8ttakGhXaUsoy)jL69gHdIr2sJW1qYJHKihgCigE7xTlddmu7YWW(k5G9ZhjgL39gHdYOw6PSaJmdCDAOQxRa5hOvmYSe5(ULq7iedp4ohGCi1Rmje1WGdXO2LHbcr1Quf0ogzjBnWzq)XiCVihIXaixrE(m62CtqHBk(AaCmAfgf2VVb15UgeYvp3bz0QpGr5)qgTcJYLaEujNWZED39)jHmkFpGrbam8ttakGhXGBxk7viNk2CtqHByKT0iCnK8yijYHbhIH3(v7YWad1Umm807szpJsoz0Q(MGc3WiZaxNgQ61kq(bAfJmlrUVBj0ocXWdUZbihs9ktcrnm4qmQDzyGquTkaaAhJSKTg4mO)yeUxKdXGlb8OsoHN96U7)tczu(EaJcay4NMauapIbaUgeJSLgHRHKhdjrom4qm82VAxggyO2LHbaL1GmQLaTaJmdCDAOQxRa5hOvmYSe5(ULq7iedp4ohGCi1Rmje1WGdXO2LHbcr1QCiAhJSKTg4mO)yeUxKdXGlb8OsoHN96U7)tczu(EaJcay4NMauapIH7VP2SxjbFbGdJSLgHRHKhdjrom4qm82VAxggyO2LHHh)n1M9mAaFbGJrTeOfyKzGRtdv9Afi)aTIrMLi33TeAhHy4b35aKdPELjHOggCig1UmmqicXGp3zFbHO)iera]] )

    storeDefault( [[SimC Retribution: finishers]], 'actionLists', 20171010.193328, [[d4J(gaGAsvwpKuTjiXUOQ2gPQQ9HsQNly2qmFuQUjK6Xu52I6Guf2jj2RQDR0(rmkfKHrs9BuDpiP0PHAWinCr6qKQYPesDmf1XvqvluOyPuLwmPSCcpKQONszzkW6GKIjIsstLuzYenDGlss8xf6YsxhfpJuvzROeBwrA7I4WG(SqmnHeZdLeFhsYQqPy0kIXJsPtku5BKKUMqsNxO0kvqLpPGYRfQ6pFD3uzHAivETBkWCVz4SNeQ3ceyngaMVOgcDkEXHjveU5Tifg6vgOEw1z1ZQ9NVzP1HHiyuhcW89kQQ(MhoaMVHR7kZx3nvwOgsLpMBMtGtb3GoaoPJDBg3aHYkOwcv)iuui0HiuhNJi5OA91Jrgj3f4lAgI3aHYkeAeNKqzdHgf)brLqzNDcvwnMPt91Jrgj3f4lAgI3aHYAcnItsOSHqJI)GOsOrFZdnmcge7TY26yay(og6c666T4wj2bbCXTLV9gAUKfOqbM7TBkWCVPcBRJbG5lHADbDD9M3IuyOxzG6zvNvFZBdCgHRHR7GBEoPU4rZtAUl4A3qZLkWCVDWvgCD3uzHAiv(yUzobofCtpgzKCxWipPcbwwcffcnbkWqnK6ldJoyaa1qkHIcHQXmDQVeNG3oMYis5H6ZKEZdnmcge7njobVDma4I8T4wj2bbCXTLV9gAUKfOqbM7TBkWCVXQ4e8wc1aCr(M3IuyOxzG6zvNvFZBdCgHRHR7GBEoPU4rZtAUl4A3qZLkWCVDWv0VR7MkludPYhZnZjWPGB6XiJK7cg5jviWYsOOqOjqbgQHuFzy0bdaOgsjuui0Hiu9rOaisxGVtWeGY63fQHujHYo7eQJZrKCuT(obtakRVOziEdekRj0iojHYgcDaHg9np0WiyqS3K4e82XaGlY3IBLyheWf3w(2BO5swGcfyU3UPaZ9gRItWBjudWfzcDO5OV5Tifg6vgOEw1z1382aNr4A46o4MNtQlE08KM7cU2n0CPcm3BhCLOCD3uzHAiv(yUzobofCtpgzKCxWipPcbwwcffcvJz6uFjobVDmLrKYd1NjLqrHq1hH2HNbNMwPpQMGdPvmYNocM0XfcMikQJZ38qdJGbXEtpMaa7GIWys3ifUUElUvIDqaxCB5BVHMlzbkuG5E7Mcm3BdhtaGDqXWceklDJu466nVfPWqVYa1ZQoR(M3g4mcxdx3b38CsDXJMN0CxW1UHMlvG5E7GRe1R7MkludPYhZnZjWPGB6XiJK7cg5jviWYsOOqOAmtN6lXj4TJPmIuEO(mP38qdJGbXEd0CkcuegtQqIDGBXTsSdc4IBlF7n0CjlqHcm3B3uG5EtxZPiqXWceklviXoWnVfPWqVYa1ZQoR(M3g4mcxdx3b38CsDXJMN0CxW1UHMlvG5E7GRO)x3nvwOgsLpMBMtGtb30Jrgj3fmYtQqGLLqrHqhIq1hHcGiDb(obtakRFxOgsLek7StOoohrYr167embOS(IMH4nqOSMqJ4KekBi0beA0ekke6qeQ(iuaePlWVSTogaMVJHUGUU63fQHujHYo7eQJZrKCuT(LT1XaW8Dm0f01vFrZq8giuwtOrCscn6BEOHrWGyVbAofbkcJjviXoWT4wj2bbCXTLV9gAUKfOqbM7TBkWCVPR5ueOyybcLLkKyhGqhAo6BElsHHELbQNvDw9nVnWzeUgUUdU55K6IhnpP5UGRDdnxQaZ92bhCZCcCk42b)a]] )

    storeDefault( [[SimC Retribution: generators]], 'actionLists', 20171010.193328, [[du0JwaqiQkPfPkrBcjAuivDkKkRsuKzPkbAxOYWqkhtPSmQKNrvPmnsL6AIQABKkPVrvX4uLGohPsyDIIAEQs6EKk2hsYbrsTqrHhkrnrvjKlkk1ijvIoPOkRKQs1mvLQCtuLDsvwkvQNkmvrLTkk5RQsaRvvc1Ej(lvmyPoSklMuEmLMSixgAZs4ZKQgTQ40OSAvP8ALQMTKUTs2nIFdA4OQoUQuvlNKNtX0bUUQA7kv(Uez8uvIZJewVQuz(uvTFflBsojYMCAvmjAs4DluIGTkpTBeOyAFadsY806rcQoauzKWnwXZGINlAB(SrBJg3MebF0YUk7DhGbjINp0KGAlGbjgjN4Tj5KiBYPvXKKHeHvX4dK4Sa2o0bj4IHMPPsNPDnTF)tt)0A)IcoJ9uve4WiV)NzyaOY4G(c)Vs)byqcNbC29ttLot7sxmnLtt)0A)IcUBhs0Zi6DkPoWd3N)0(9pn9tR9lk4SQV5si3N)0uoT2VOGZQ(MlHCgWz3pnv6m9w(tt30(9pn9tBHWAcwIWzvFZLqofUogXmnvtVL)0uoTVoT2VOGZQ(MlHCF(tt30(9pTfcRjyjc3Tdj6ze9oLuh4HtHRJrmtt10B5pnDttNeuRXQmafsS7uStRIsu(bT75b3HlKaenj4btzDkVBHsKmo2ZaoTkkH3TqjcauHtN1v)OeuR0BKGCluNKXXEgWPvXxWDx9J6CwaBh6GeCXqdv64YVF61(ffCg7PQiWHrE)pZWaqLXb9f(FL(dWGeod4S7Pshx6ckPx7xuWD7qIEgrVtj1bE4(897NETFrbNv9nxc5(8Pu7xuWzvFZLqod4S7PsNT8PZVF6Tqynblr4SQV5siNcxhJyOAlFk9vTFrbNv9nxc5(8PZVFlewtWseUBhs0Zi6DkPoWdNcxhJyOAlF6Otc3yfpdkEUOT5ZgnjCJg4xzrJKtasKhjXShaQKGajOe8GjVBHsiaXZLKtISjNwftsgsewfJpqc6Nw7xuWzvFZLqUp)PPCATFrbNv9nxc5mGZUF6xNEl)P97FATFrbxLDjfJyCk(kkC(KkEMhmX95pnDt73)00p9PaSIZc4oZdACaqNZ8GgoKCAvmnnLtFkaR4SaNtJvzakMMYPTqynblr4kD7rhyHZzEqdNcxhJyM(1P1BttNPPDnnDsqTgRYauiH9QvNZcyqItLzasu(bT75b3HlKaenj4btzDkVBHsiH3TqjkF160uBbmiz63JzasqTsVrcYTqDEzWwLN2ncumTpGbjzE6cgHzEqL5Ls4gR4zqXZfTnF2OjHB0a)klAKCcqI8ijM9aqLeeibLGhm5DluIGTkpTBeOyAFadsY80fmcZ8GkJaepFtYjr2KtRIjjdjcRIXhib4QibWH(cA)agK4yqcajwKdjNwfttt500pTfcRjyjc3B)K(fsaCkCDmIz6xNwVnnDMMw3CUYFA)(NoHA)IcU3(j9lKa4u46yeZ0unTEBA6mnTU5CL)00nnLtBHWAcwIWH(cA)agK4yqcajwK7ZFA)(Nw7xuWv6Hz4JkhyHd4bDih4rHVJT4(8NMYP1(ffCLEyg(OYbw4aEqhYbEu47ylofUogXm9RtR3MMottVXLVeuRXQmafsyVA15SagK4uzgGeLFq7EEWD4cjartcEWuwNY7wOes4DluIYxTon1wadsM(9ygW00VrNeuR0BKGCluNxgSv5PDJaft7dyqsMNUGryMhuzEPeUXkEgu8CrBZNnAs4gnWVYIgjNaKipsIzpaujbbsqj4btE3cLiyRYt7gbkM2hWGKmpDbJWmpOYiaXt3sojYMCAvmjziryvm(ajsqah6lO9dyqIJbjaKyroaZUNr0pnLtNGao0xq7hWGehdsaiXICkCDmIz6xNwVnnDMM210uoDc1(ffCV9t6xibWPW1XiMPFDA9200zAAxsqTgRYauiXB)K(fsasKhjXShaQKGajOe8GPSoL3TqjKW7wOe((pPFHeGeUXkEgu8CrBZNnAs4gnWVYIgjNaKO8dA3ZdUdxibiAsWdM8UfkHaeV8LCsKn50QysYqIWQy8bs8aRu4WhwcvC2VsHeW0VQZ0UMMYPPFAdcC0GKVHdWqLlAoU4BNMQPPnTF)tBqGJgK8nCagQCrZr38Ttt100MMojOwJvzakKqREj0bw4823aywuI8ijM9aqLeeibLGhmL1P8UfkHeE3cLiJ6LWPHft77FdGzrjCJv8mO45I2MpB0KWnAGFLfnsobir5h0UNhChUqcq0KGhm5DlucbiE6QKtISjNwftsgsewfJpqIhyLch(WsOIZ(vkKaM(vDM210uon9tBqGJgK8nCagQCrZXfF70unnTP97FAdcC0GKVHdWqLlAo6MVDAQMM200jb1ASkdqHej2ogbDEU1cvsKhjXShaQKGajOe8GPSoL3TqjKW7wOeVi2ogbNwxERfQKWnwXZGINlAB(Srtc3Ob(vw0i5eGeLFq7EEWD4cjartcEWK3TqjeG45JKtISjNwftsgsewfJpqc6N(bwPWHpSeQ4SFLcjGPFvNPPnTF)t)aRu4WhwcvC2VsHeW06m920uon9tBHWAcwIWPvVe6alCE7BamlYPW1XiMPPAA9200(9pTfcRjyjcxITJrqNNBTqfNcxhJyMMQP1Bttt30(9p9dSsHdFyjuXz)kfsatRZ0UMMYPPFA6N2cH1eSeH7D4v5SpNspACkuNfWGKRo9R6mnnoDn)P97FAlewtWseoR6BUeQCmafBpYzFoLE04uOolGbjxD6x1zAAC6A(tt300nnDsqTgRYauirPBp6alCoZdAKipsIzpaujbbsqj4btzDkVBHsiH3TqjEbU940WIPP28GgjCJv8mO45I2MpB0KWnAGFLfnsobir5h0UNhChUqcq0KGhm5DlucbiEVqjNeztoTkMKmKiSkgFGepWkfo8HLqfN9Ruibm9R6mTVnnLt7RtBqGJgK8nCagQCrZr38Ttt100KGAnwLbOqcT6LqhyHZBFdGzrjYJKy2davsqGeucEWuwNY7wOes4DluImQxcNgwmTV)naMfNM(n6KWnwXZGINlAB(Srtc3Ob(vw0i5eGeLFq7EEWD4cjartcEWK3TqjeG4PlKCsKn50QysYqIWQy8bs8aRu4WhwcvC2VsHeW0VQZ0(20uoTVoTbboAqY3WbyOYfnhDZ3onvtttcQ1yvgGcjsSDmc68CRfQKipsIzpaujbbsqj4btzDkVBHsiH3TqjErSDmcoTU8wlunn9B0jHBSINbfpx028zJMeUrd8RSOrYjajk)G298G7WfsaIMe8GjVBHsiaXBJMKtISjNwftsgsqTgRYauiXB)K(fsasKhjXShaQKGajOe8GPSoL3TqjKW7wOe((pPFHeW00VrNeUXkEgu8CrBZNnAs4gnWVYIgjNaKO8dA3ZdUdxibiAsWdM8UfkHaeVTnjNeztoTkMKmKiSkgFGeA)IcUeBhJGo8)k(qdY95lb1ASkdqHe2RwDolGbjovMbir5h0UNhChUqcq0KGhmL1P8UfkHeE3cLO8vRttTfWGKPFpMbmn9UOtcQv6nsqUfQZld2Q80UrGIP9bmijZtxWimZdQmVuc3yfpdkEUOT5ZgnjCJg4xzrJKtasKhjXShaQKGajOe8GjVBHseSv5PDJaft7dyqsMNUGryMhuzeG4T5sYjr2KtRIjjdjcRIXhiHfcRjyjc37WRYzFoLE04uOolGbjxDAQ0z6noDn)PPC6hyLch(WsOIZ(vkKaM(vDMw3tt500pTfcRjyjcNw9sOdSW5TVbWSiNcxhJyMMQP1BttNPPDnTF)tBHWAcwIWLy7ye055wluXPW1XiMPPAA9200zAAxtt30uoDc1(ffCV9t6xibWPW1XiMPPAA92KeuRXQmafs8o8QsKhjXShaQKGajOe8GPSoL3TqjKW7wOeVy8Qs4gR4zqXZfTnF2OjHB0a)klAKCcqIYpODpp4oCHeGOjbpyY7wOecq828njNeztoTkMKmKiSkgFGewiSMGLiCw13Cju5yak2EKZ(Ck9OXPqDwadsU60uPZ0BC6A(tt50pWkfo8HLqfN9Ruibm9R6mTUNMYPPFAlewtWseoT6LqhyHZBFdGzrofUogXmnvtR3MMott7AA)(N2cH1eSeHlX2XiOZZTwOItHRJrmtt106TPPZ00UMMUPPC6eQ9lk4E7N0VqcGtHRJrmtt106TPPPCA6NgCvKa40RWdGkN3(j9lKa4qYPvX00(9pTVoTbboAqY3WbyOYfnhDZ3onvttBAkNgCvKa4apOtbtHghyHZBFdGzroKCAvmnnDsqTgRYauiHv9nxcvogGIThLipsIzpaujbbsqj4btzDkVBHsiH3TqjkR(MlHQPdGIThLWnwXZGINlAB(Srtc3Ob(vw0i5eGeLFq7EEWD4cjartcEWK3TqjeG4TPBjNeztoTkMKmKGAnwLbOqclKyqR6amirI8ijM9aqLeeibLGhmL1P8UfkHeE3cLOmKyqR6amirc3yfpdkEUOT5ZgnjCJg4xzrJKtasu(bT75b3HlKaenj4btE3cLqaI3w(sojYMCAvmjziryvm(ajW3)Z4ZhtCV9naMfD0FVdNMYPbNspc4EWRcE44BbttLot7t(tt50pWkfo8HLqfN9Ruibm9R6mTULGAnwLbOqINBTqLdSW5TVbWSOe5rsm7bGkjiqckbpykRt5Dlucj8UfkHU8wlunnSyAF)BamlkHBSINbfpx028zJMeUrd8RSOrYjajk)G298G7WfsaIMe8GjVBHsiaXBtxLCsKn50QysYqcQ1yvgGcjSxT6CwadsCQmdqI8ijM9aqLeeibLGhmL1P8UfkHeE3cLO8vRttTfWGKPFpMbmn9(gDsqTsVrcYTqDEzWwLN2ncumTpGbjzE6cgHzEqL5Ls4gR4zqXZfTnF2OjHB0a)klAKCcqIYpODpp4oCHeGOjbpyY7wOebBvEA3iqX0(agKK5PlyeM5bvgbiEB(i5KiBYPvXKKHeuRXQmafs8o8QsKhjXShaQKGajOe8GPSoL3TqjKW7wOeVy8Qtt)gDs4gR4zqXZfTnF2OjHB0a)klAKCcqIYpODpp4oCHeGOjbpyY7wOecq82EHsojYMCAvmjzib1ASkdqHew13Cju5yak2EuI8ijM9aqLeeibLGhmL1P8UfkHeE3cLOS6BUeQMoak2ECA63Otc3yfpdkEUOT5ZgnjCJg4xzrJKtasu(bT75b3HlKaenj4btE3cLqacqIWQy8bsiara]] )


    storeDefault( [[Retribution Primary]], 'displays', 20170625.203942, [[d4ZpiaGEvvEPQQSlvvv2gkP0HLmtkHXPQQQzRKLrjDtusopP62K0PHANuSxXUjSFvXprKHjf)gYLvzOOQbRknCK6GsvhfLu1XOuhNs0cLslvQ0IrLLt0djrpf8yuSosPAIkvXurYKrPMUIlQQCvPcEMsv66iSrLkBvQqTzQ02jfFuQOpJOMgPeFxPmssj9nsPmAQy8OeNKeULuHCnvvL7HskEovTwusLxRuvh7qfGPOhmsSdjgy0xxasDGYcfMVatjjFdVg(WfqwcYNsNJz)0gGBH)9RZfAlCb0j566VrzrpyKWhttawi566VrzrpyKWhttaljoIJTcgKaW)Uy0staVdARNqwkeUOWfWsIJ4yRSOhms4tBaDsUU(BOkj5B8X0eG1tCeNpuXyhQaFIIBDStBGEMbJepVwG9tmwdyk1laGvv(829gjMJyWiH2FEPLhdsLRMaDV1v(lgRn2ARXUPjaWiX0tGbRESMMmXynub(ef36yN2a9mdgjEETa7NySdyk1laGvv(829gjMJyWiH2FEzFUfXAc09wx5VyS2yRTg7MMmzc4DqBWgEyC6)sBawi566VHQKKVXhttamdsa0fdwqoM)fykj5B6fmoizGwsuuKyvxfDQvQa6X0rw1staxKyc0lX1651usjAlG3bTrvsY34tBG956fmoizaks8Dv0PwPcWGu5QHxZx4cWu0dgj6fmoizGwsuuKyvaLiA9NxkuaEjAoMbJepV8sSAj1d4DqBavAdyjXrC7blpMbJeb6QOtTsfqqOQGbj8XOLaE6BT2TkVJs0cjdvGkg7aCXyhGCm2bKXyNjG3bTPSOhms4tBawi566VPNqwX0eOiKfLo9fGJW1nWEo3IynPnGAXspXGIPjalKCD93OqWgZuds6JPjqTODkWbTXR5lg7a1I2PuIu5QHxZxm2bmL6fO7nsmhXGrINxEjwTK6bQfTt1V2kDpVMVySduRTs3ZRHpTb0G9yo8cp6u60xaUamf9GrI(fMSiGYpd1x3aSXE6vPtPtFbQaa9XGRf(xnyKigT1eqwcYhLo9fO4Wl8OhOiKfRWIlTb0j566VrHGnMPgK0httG952HedG)DXyBnWusY3SdjMa8upVqj8pVMskrBb4Ly1sQ)8QSOhms882tiRabWmibRdHuJX(FbK3kGYpd1x3aE6BT2TkVt4culANIQKKVHxZxm2b(705Wc2yb5Nxy0xxmwdyjXrCSviyJzQbj9PnG3bTbB4HXPNyqPnG3bT1tmO0gykj5B2Hedm6RlaPoqzHcZxawvSGvjuFEPWQxm7TjqrilfcxeLo9fGJW1naWiX0tGa1I2P6xBLUNxdFm2bulwaQySdqlXQLuFhsma(3fJT1a0YJbPYvtpVfbaSQYN3U3iXCedgj0(ZlT8yqQC1eGwIvlPUcgKaW)Uy0sta1IL(VyAcqvRtmpVDkre0Xyhykj5B418fUaEh02FNohwWgli7tBaEjwTK6pVkl6bJebMss(gFaSGnMPgKSxW4GKb6QOtTsfqfl6jgumnbyk6bJe7qIbW)UySTgOw0oLsKkxn8A4JXoqTODkWbTXRHpg7aEh0McbBmtniPpTbQfTtrvsY3WRHpg7a1AR098A(sBaVdAR)lTb8oOnEnFPnadsLRgEn8HlW(C7qIjap1Zluc)ZRPKs0waDsUU(B(R1hthzhyFUDiXaJ(6cqQduwOW8fqflaQyAcmLK8n7qIbW)UySTgW7G241WN2amf9GrIDiXeGN65fkH)51usjAlqrilG(wlf7jMMaFIIBDStBapwLED9K(IXAaDsUU(B6jKvmnb6ERR8xmwBS1wdR1EV)NTvRw)3)hGfsUU(B(R1hJDavSO)lM9gWsIJ46xyYc1tmbycWsmnbyFUfXA65TiaGvv(829gjMJyWiH2FEzFUfXAcSqBNKP83FT(WfOiKvVGXbjd0sIIIeRS4BhvaljoIJ9oKya8VlgBRb4w4F)6CH26xRWfWsIJ4y)xRpTbSKaZSFhJ9WOVUavGIqwDqGNa0Rs)Kzsa]] )

    storeDefault( [[Retribution AOE]], 'displays', 20170625.203942, [[deeoiaqiuvL2KuO6wsHYUuIQHPQ6yezzOkpdLOPPeLRPQW2qjuFdvv14qvL6COeY6Kc5EOQkoOuAHQspKOAIOeCrL0gvcFujYijL0jjfVeLuZKuQBIsYoP4NazOKQJIQkAPsrpfAQO4QKsSvuvH1IQkzVIbRuDyjlgjpgvMmk1LvzZuXNbQrtPonIxRQOzlv3Ms2nHFdA4i1XLcwojpNQMUIRdy7eLVRkgpQkNNkTEvL2Vs5ifMGCf9qGIfqXGJB)ccslmARXSgCkf4B0LPhQGQsa(KBFCFM3GuDY3Vl1HpHkOlihh)nYl6Haf(y(dYhihh)nYl6Haf(y(dsRiwLYvdhuGKVxml7pO3g(0cOknchyOc2aWbCSLx0dbk85nOlihh)nmLc8n(y(dYpboGZhMyKctWvrr1p25nyl3qGITDTj(jgEbnL1fejwY32BEJIqbmeOOrB70QJdArvtWMx)k)fdVFPpKKwopEsbrofHEcoeRJ)8NjgEHj4QOO6h78gSLBiqX2U2e)eJuqtzDbrIL8T9M3OiuadbkA02o7ZPa6tWMx)k)fdVFPpKKwopEszYe0BdFWhYWz3UgQG8bYXXFdtPaFJpM)GeoOaPloIaCmFeCkf4BAfC2qvWxqmmGyvtnlPvMGUX0ysSOpc6aftWwfP6B7MsPGpbz95sreSjcWB7442Vy4f8tQwbNnufKbKEtnlPvMGCqlQA0LTgQGCf9qGIwbNnuf8feddiwfuoK2DBNbgS5nkcfWqGIT9wqRb92WhKjVbBa4aowGOoUHafbBQzjTYeuayPHdk8XSSGE6R3x0lVTCyhQctWkgPGQyKccogPGuXiLjO3g(iVOhcu4ZBq(a544VPfqvX8hSaufJl9fKcWXjOvXxlWaJ5py1PTR2(t561LTgJuWQtBxOn8rx2AmsbRoTDjhArvJUS1yKcAkRlyZBuekGHafB7TGwd2aaH7t(bXJJB)csfS6pLRxxMEEdkJ4juKozCzCPVGub5k6HafTDcyrq5RgM1Mbzt809YLXL(cYfKfoNcOp5nOQeGpgx6lyrr6KXnybOkwrexEdI0hhP6KV1qGIy4))GFsTakgK89IrIxq(a544VrJGnHRgOYhZFqDfXQuUB7Yl6HafB7TaQkyqp917l6L3oubvxpO8vdZAZGtPaFZcOycQZSTJLWVTBkLc(eS602ftPaFJUS1yKcs4Gc(feAfJ0hbBa4ao2AeSjC1av(8g0BdFykf4B85niFX8hCkf4BwafdoU9liiTWOTgZAqwv8rSaS22ziwxmS8pO3g(GpKHZUfyG5niYPi0tqpraUFno)TagyWQtBxT9NY1RltpgPGfGQ0iCGmU0xqkahNG0kIvPCxafds(EXiXliT64Gwu10QRDqKyjFBV5nkcfWqGIgTTtRooOfvnbTk(qMy(dAv81UgZFqMQFIzBFjfeGoM)GtPaFJUS1qf0BdFy95sreSjcW(8gS51VYFXW7xI))zXsSC5s84X7d(DWQtBxmLc8n6Y0JrkirWMWvdu1k4SHQGn1SKwzcYv0dbkwafds(EXiXlydahWXwdhuGKVxml7py1PTl5qlQA0LPhJuqVn8rJGnHRgOYN3GvN2UqB4JUm9yKcw9NY1RlBnVb92WhDzR5nO3g(0UgQGCqlQA0LPhQGFsTakMG6mB7yj8B7MsPGpbDb544VH1V(yAmPGFsTakgCC7xqqAHrBnM1GwebYedldoLc8nlGIbjFVyK4f0BdF0LPN3GCf9qGIfqXeuNzBhlHFB3ukf8jybOkK(6DnSqm)bxffv)yN3GEIfD)AbTgdVGUGCC830cOQy(dYhihh)nS(1hJuqDfXQuUB7Yl6HafbNsb(gFqVn8PfyGHkydahW12jGfwNycYf0IiAxJHLbzFofqFA11oisSKVT38gfHcyiqrJ22zFofqFcs1jF)Uuh(027HkybOQwbNnuf8feddiwP96cMGnaCah7fqXGKVxms8c6cYXXFJgbBcxnqLpM)GnaCahBw)6ZBqlIOfyGXWYGfGQ0IGmbP7L7PYKa]] )

    storeDefault( [[Protection Primary]], 'displays', 20170625.203942, [[dWtBiaGEiYlvQYUivLTPuvZeLQzRKdl5Mij(TQ(gPk0YeQ2jj7LA3OA)qQFIedtugNuH6ZOKHIIbdjdhPoOu6OKQOogPCCHIfkflfLYIfPLt0dLk9uWJHYZfmrKKMkunzcz6kUieUkPkDzvUobBuPYwjvr2SOA7eQpkv0PrmniQ(UszKsf8mHsJweJhj1jjvULuHCnsv15fYTLQwlPk41qu2Ag3awrpKNV75dmrRZaf9IZUofcdtjzDdJygNAqwCwx3KddzUXq6IGesDU(nNAiIsEE4MUf9qEEWQmdutjppCt3IEippyvMHyeoHtKoSNdeKoRqEMHqYV1kilD883PgIr4eorDl6H88GBmerjppCdEjzDtWQmd6zHt4cg3knJBabVsxNi3yOfBiphnk2jHXkKBqv9Nbg5ph2qEoAuu9YpEGi(cgy7wxfoRINPTVwwwS6tZaGjj0Jbpwf34gqWR01jYngAXgYZrJIDsySs)guv)zGr(ZHnKNJgv3)xI(nEWaB36QWzv8mT91YYIvFAgamjHEm4XQynUbe8kDDICJHwSH8C0OyNegRI1GQ6pdmYFoSH8C0OaCdSDRRcNvXZ02xlllw9PzaWKe6XGhpgcj)gSrgSKweUXa1uYZd3Gxsw3eSkZab75aDHr4SSs)gMsY6MwowYln0qbhNcvytxNDa3qKvDuCKNzi)5JHwjPwOrPkP83mes(n8sY6MGBmGS0wowYlnGtHHnDD2bCdyFFAnmIr4udyf9qEElhl5LgAOGJtHkg6(0rOrH)gyK)Cyd55OrXij9LmYqi53aC3yigHt4OkrEyd55gytxNDa3axOxh2ZdwHCdb6BT2TQqs3F9sJBOSsZqQvAgyzLMbPvAEmes(TUf9qEEWngOMsEE4MwbzzvMHsqw4r0NHuH8Cdu9YlH14gd9f1TcZBvMbQPKNhUrhxebRMxgSkZqTOtki53yeJWknd1IoP6(9P1WigHvAguv)zGr(ZHnKNJgfJK0xYid1IoPAxBvuGrmcR0muRTkkWiMXngetcKuYImr4r0NHudyf9qEE7IWIBOlcfoc2miIeOxveEe9zOma0hgPweKQH8CR2FFdYIZ6WJOpdvkzrMidLGSOcHFUXqeL88Wn64Iiy18YGvzgqw6UNpabPZkT4gMsY6MDpFmWGJgfu8aAuQsk)ndmssFjJqJQBrpKNJgvRGSmyGG9C9W)9wPPFdYBzOlcfoc2meOV1A3Qcjo1qTOtk8sY6ggXiSsZWExukHlIWzHgfmrRZQ4gIr4eor64Iiy18YGBmes(nyJmyjTcZ7gdHKFRvyE3yykjRB298bMO1zGIEXzxNcHbQuut6f6rJcN0FwfBMHsqw645pEe9zivip3aGjj0Jbd1IoPAxBvuGrmJvAg6lQbCR0mqlj9LmA3ZhGG0zLwCd0Yd77tRPLHDRYmqlj9Lmsh2ZbcsNvipZqFrDlcRYmGxRJpOr1P8fOTkZWusw3WigHtnW2TUkCwfpttpMTVwS6tlE846VJnWij9LmcnQUf9qEUHPKSUjyGWfrWQ5LTCSKxAGnDD2bCd1IoPWljRByeZyLMHEcVvyERYmul6KQ73NwdJygR0mul6Kcs(ngXmwPziK8B64Iiy18YGBmGv0d557E(aeKoR0IBOwBvuGrmc3yiK8BTiCJHqYVXigHBmG99P1WiMXPgqw6UNpgyWrJckEankvjL)MHik55HB2RjyvhPzazP7E(at06mqrV4SRtHWqpHd4wLzykjRB298biiDwPf3qi53yeZ4gdyf9qE(UNpgyWrJckEankvjL)MHsqwa9Tw6OQvzgqWR01jYngcKE611sbHvXnerjppCtRGSSkZqi5327IsjCreoRGBmqnL88Wn71eSsZqpH3IWQyneJWjCTlclE)XhdygO2QmdIU8synTmSBGr(ZHnKNJgfvV8syngw)2jXQWTxtWPgkbz1YXsEPHgk44uOc7i2HBigHt4eT75dqq6SslUH0fbjK6C9BTRLtneJWjCI2Rj4gdXiqWqMEIeGjADgkdLGS0lNmgOxv0j9yd]] )


end
