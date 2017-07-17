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
        setTalentLegendary( 'soul_of_the_highlord', 'protection',   'divine_purpose' )

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
            if equipped.chain_of_thrayn then applyBuff( 'chain_of_thrayn', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2.5 ) ) end
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
            cooldown = 30,
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


    storeDefault( [[Protection ST]], 'actionLists', 20170625.203942, [[d0dLgaGArHwpHK2ebIDjOTjG9riy2cnFcK(ebu)gvFtkCBuStuAVu7wv7xuzuecnmjmorbptu1qjanyrPHJOoiICkcihwPZra0cfOLsOwmrwospKqINcTmc65Imreu1uLOjlPPt6IsLUhHuxgCDe6AeI6XkSzPITlk6ZsPVJGmneuAEeOAKeI8xPQrtuJhbvojc8AcuoTkNxkALiO4NeaoMI2txAejdJBJNOU6XFZgiGrCqpYQrJIHiSjWSclMnkcmZhofkuOiNbJSldyuaPCfg6X)CzXsJKg6X)Kln70Lg7(RueQoOXvvQlTAKDzaJcixp(BKeTnz8xgq08yTNql1ijPlEAtJK56XFJe81BSkNA85pyumeHnbMvyXmWSryr(PrCqpYQr9yarxy1ScDPXvvQlTAeh0JSAu5TTri8EfOuIK1Kr2LbmkgKikyGrXqe2eywHfZaZgHf5Ngj4R3yvo14ZFWijPlEAtJuqIOGbg7(RueQoOvZM3LgxvPU0QrCqpYQrjID6e2s3V2pOetBfOHejli6gHxdhuIPTc0uFgjwBzGxdHFLIqvqgCESYj0hMrI1wg41WH8sBHKGpnYUmGrszcFlqf4uUSO8bXQrXqe2eywHfZaZgHf5Ngj4R3yvo14ZFWijPlEAtJBMW3c0uFs(Gy1y3FLIq1bTAwcRlnUQsDPvJ4GEKvJ7qVmHE4bMdsIW0ijPlEAtJd(NGbD1J)gfdrytGzfwmdmBewKFAKGVEJv5uJp)bJSldyuu4Fcg0vp(NlRissa0vGm29xPiuDqRMvKDPXvvQlTAeh0JSACW5XkNqFys(GyTN3PxLHE61kRaNykCiV0wij6bNhRCc9Hj5dI1EENEvg6PxRScCIPWH8sBHupZs4mss6IN20ys(GyTN3PxLHE61kRaNyYibF9gRYPgF(dgjvZC)buDqJSldyeLpiwZLL3jxwvgYLv81kRaNyYOyicBcmRWIzGzJWI8tJ4GEK1YMKbJ6Xag7(RueQoOvZgWLgxvPU0QrCqpYQrJSldyKWqS2YaVAumeHnbMvyXmWSryr(Prc(6nwLtn(8hmss6IN20ygjwBzGxn29xPiuDqRMTHln29xPiuDqJ4GEKvJvqIyNoHsriLGAV8YWa0qkWS3Ne8miOc6GZJvoH(qPiKsqTxEzyaA4qEPTqseMgzxgWyWiKsqnxwrAzyaQrs02KrJIHiSjWSclMbMnclYpnsWxVXQCQXN)Grssx80MgLIqkb1E5LHbOgxvPU0QvZMbxACvL6sRgXb9iRgnYUmGrrH)jyqx94VrXqe2eywHfZaZgHf5Ngj4R3yvo14ZFWijPlEAtJd(NGbD1J)g7(RueQoOvZkaDPXvvQlTAeh0JSA0i7YagjLj8TavGt5YIYheR5YkItbYOyicBcmRWIzGzJWI8tJe81BSkNA85pyKK0fpTPXnt4BbAQpjFqSAS7VsrO6Gwn7SWLgxvPU0QrCqpYQrJSldyuKwggGMllVtUSQmKlR4RvwboXKrXqe2eywHfZaZgHf5Ngj4R3yvo14ZFWijPlEAtJYlddq75D6vzONETYkWjMm29xPiuDqRwns4HolXO6GwTb]] )

    storeDefault( [[Protection Defensives]], 'actionLists', 20170625.203942, [[deZycaGEQQ0MOIyxsITHKMjvuMnf3MG2jsTxXUP0(jQrrvrdtk9BvnuvsdMidNkDqjLtrvfhtrluLyPKslgjwojpfAzsXZLyIuv1uPktMqth1fvP6zKIRtGntQ2ovL8njPptfoTsJKQsDzWOv41uv4KQuomIRrfPZlP6VQyCur1JLQZmEbPjcHGxvpdDEFRSK)GoylRVGsq)bDIadNlb1cgGuGq30oR2sDQPYSPPXPopi6c9Lyw)s49THMk1G168(2s8c9mEbVBjumGyUee7Q1LdYeRpwRdNiOaNYybJyqAIqiiowWikl96Ys8aKL0Uogm8ckYs(C6NGAbdqkqOBANuNvR0QzgSgL1SC9GLXcgXZRF4bCuRJbdVGsWBwXTt4xf0(wiiHzv8che7Q1L9Q7cblRWE4q3eVGeMvXlCqAIqiOVjwrzPxxwIhGS0v1ZqNFvqSRwxoOGcCkGr)maIjOwWaKce6M2j1z1kTAMbVzf3oHFvq7BHG1OSMLRhCqSINx)Wd44QEg68RcE3sOyaXCjCO1eVGeMvXlCqAIqiOZwhdww61LL4bilDv9m05xfe7Q1LdkOaNcy0pdGycQfmaPaHUPDsDwTsRMzWBwXTt4xf0(wiynkRz56bnRJbFE9dpGJR6zOZVk4DlHIbeZLWHdID16YbdNa]] )

    storeDefault( [[Protection Cooldowns]], 'actionLists', 20170625.203942, [[b4vmErLxtruzMfwDSrNxc51uofwBL51uqj3B0v2y0L2BU5hyd92BSr2B352CEnLuLXwzHnxzE5KmWeZnWytmZ4smYiJm1GJxtnfCLnwAHXwA6fgDP9MBE5Kn241ubngDP9MBZ5fvErNxtn1yYLgC051uErNxEb]] )

    storeDefault( [[Protection Default]], 'actionLists', 20170625.203942, [[d0ItcaGEkkTlvQ2gO0SbUjO42sPDkv7vSBf7xPAysXVjnuL0GvIHtroOe1XOWcLilvsAXOKLRIhsr1tHwMK65uAIsOPQsMmitN4IOOEMkfxhfSzuQTJI8zjX3rHonvFtcUmYjbvDyvDnvkDEqL)QughffpgvhJCfS)TuW1JkexCD2xksSFgasq0eX9h4M9fxN0Hf2Gvja9wk96gJcnWACZDJ666BntqKFCtsWGL5IRJnxPBKRGmpplabLsb7FlfC9OcXfxN9LIeBASotKniYpUjjOOvQaO7myPniInnwNjYgSkbO3sPx3yuWOji8dKZFrpbhDOGLz5axGli)bGTNlUoBa3kbHrH6FlfC9OcXfxN9LIeBASotKns615kiZZZcqqPuW(3sbxpQqCX1zFXCvbqkJJniYpUjjOOvQaO7CvbqkJJnyvcqVLsVUXOGrtq4hiN)IEco6qblZYbUaxq(daBpxCD2aUvccJc1)wk46rfIlUo7lMRkaszCSrs)MCfK55zbiOuky)BPGRhviU46SVGxbr(XnjbdwLa0BP0RBmky0ee(bY5VONGJouWYSCGlWfK)aW2ZfxNnGBLGWOq9VLcUEuH4IRZ(cEfjsWIe7NbGKsrsaa]] )

    storeDefault( [[SimC Retribution: opener]], 'actionLists', 20170717.174531, [[dKtNfaGAGQA9afSlsLTbuLzl08bPUPG(MOyNsSxQDJy)kXTvQHPK(TuNMOLHQAWIQHJkDiqG1buKJbOZbuslualfuwmkTCcpeK8uOhlPNlYebHmvGmzsMosxeu1ZaQ4YQUoPSrGsSvuOnJQSDrPdR4Raf10ab9DuWibk0Fby0OOpdIojOYRrfxdOuNNu1kbQ0bfOJdc1gObzSm7BeLBOwYHDQqYQrLnbmTK3Cp5cJi3xLtucggQSjUKz1iSh)KUl8xbMzf84d264VcoGviKVrSkKCPgngSsLnjzqUa0GmcpzyJx5agXQqYLAK2qcz86QDhvndKKXGSYOKQ3iBSBfaEAc9gHJOK1H2cJKMCJHTIXruM9nASm7BmqSB1soyrtO3iSh)KUl8xbMb4Qryp1AI6tgKPgHI5RCc7SFFc1SgdBvz23OPUW3GmcpzyJx5agXQqYLAK2qcz86QDhvndKKXGSYOKQ3i7fPl4ijqAeoIswhAlmsAYng2kghrz23OXYSVXaxKUGJKaPryp(jDx4VcmdWvJWEQ1e1NmitncfZx5e2z)(eQzng2QYSVrtDbCmiJWtg24voGXGSYOKQ34iQd5aOTqCc1iCeLSo0wyK0KBmSvmoIYSVrJLzFJbf1H8LCqTqCc1iSh)KUl8xbMb4Qryp1AI6tgKPgHI5RCc7SFFc1SgdBvz23OPUaHgKr4jdB8khWyqwzus1Be81uqUpHAeoIswhAlmsAYng2kghrz23OXYSVrWvtb5(eQryp(jDx4VcmdWvJWEQ1e1NmitncfZx5e2z)(eQzng2QYSVrtDbSniJWtg24voGrSkKCPgpeRj5Y9kDr5OesscapnHEaAK4NeZRwYHg6LCXuVo2y3kapYBjhAOxYHGL8A3rvZarhddNdO5bysmFsNgxJbzLrjvVr24OoGMhaWxlrL1BeoIswhAlmsAYng2kghrz23OXYSVXaXr9L8M3so4QLOY6nc7XpP7c)vGzaUAe2tTMO(KbzQrOy(kNWo73NqnRXWwvM9nAQlGNbzeEYWgVYbmIvHKl14HynjxUxPlkhLqssa4Pj0dqJe)KyE1so0qVKlM61Xg7wb4rEl5qd9soeSKx7oQAgi6yy4CanpatI5t604AmiRmkP6nQKzLKdG5S3xyeoIswhAlmsAYng2kghrz23OXYSVrisMvs(soyC27lmc7XpP7c)vGzaUAe2tTMO(KbzQrOy(kNWo73NqnRXWwvM9nAQlzmiJWtg24voGXGSYOKQ3iddNdO5bysmFYiCeLSo0wyK0KBmSvmoIYSVrJLzFJG5HZxYBEl5btmFYiSh)KUl8xbMb4Qryp1AI6tgKPgHI5RCc7SFFc1SgdBvz23OPMAeIoVrlsDatTb]] )

    storeDefault( [[SimC Retribution: default]], 'actionLists', 20170717.174531, [[dCt(daGEsrAxKIABKcmtPkMnj3uf(Muv7eK9k2nI9RsJIusdtf9BLUnvnyvz4ivheuofPuDmvLZrkIfcQAPeAXiz5e9qPYtHESuEUctKuqtfPmzcMoLlsL40sUmQRtfhgyRKQAZKkSDsLoVIY8ifY0iL47KkADuPETIy0uj9zqLtsQYZiLY1ifQ7jvPLPQ6Vkslsr15l0ccb8CqS8D3NiBYIYXQL4((eyDaCuwqKo3kGQ0uGvljq9pdkYkgm4a9F(1)ud(1yn)FQnnrl)bXMSOBbdcRz1sgHwG(cTGUqaukwiWheBYIUf0w4GtXAUiglLo0TrqyuLQSzbLmLZeoOEeHQbSvgKSeo4XkOpqcb8CWGqaphuKPCMWbfzfdgCG(p)6)DguKhRJSXJqlwWox52KJvx2ZelubpwbiGNdglq)Hwqxiakfle4dInzr3cALNVpn6((dcJQuLnlydOutbnRwYuvnSGDUYTjhRUSNjwOcESc6dKqaphmieWZb7ak19bRz1sUVEQHfeMeUrqcWZ9ohlF39jYMSOCSAjUVVLoty58GISIbdoq)NF9)odkYJ1r24rOflOEeHQbSvgKSeo4Xkab8CqS8D3NiBYIYXQL4((w6mHLXcK2cTGUqaukwiWhegvPkBwWgqPMcAwTKPQAyb1JiunGTYGKLWbpwb9bsiGNdgec45GDaL6(G1SAj3xp1WUpT(P9GWKWncsaEU35y57Upr2KfLJvlX9912vjS6KmMhuKvmyWb6)8R)3zqrESoYgpcTyb7CLBtowDzptSqf8yfGaEoiw(U7tKnzr5y1sCFFTDvcRojJybslHwqxiakfle4dcJQuLnlydOutbnRwYuvnSG6reQgWwzqYs4GhRG(ajeWZbdcb8CWoGsDFWAwTK7RNAy3Nw)1Eqys4gbjap37CS8D3NiBYIYXQL4((OlRvw2S5bfzfdgCG(p)6)DguKhRJSXJqlwWox52KJvx2ZelubpwbiGNdILV7(eztwuowTe33hDzTYYMflwqnK1bWrzb(yj]] )

    storeDefault( [[SimC Retribution: precombat]], 'actionLists', 20170717.174531, [[b4vmErLxt5uyTvMxtnvATnKFGjvz0jxAIvhDP9MB64hyWjxzJ9wBIfgDEn1uWv2yPfgBPPxy0L2BU5Lt3aJxtjvzSvwyZvMxojdmXCdm2itnUidmZKdnY41utnMCPbhDEnLxtf0y0L2BUnNxu5LtX4fvEnvrUfMySvgzEjKxtn1yYLgC051u092zNXwzUa3B0L2BUnNxtfKyPXwA0LNxtb3B0L2BU51udHwzJTwtVzxzTvMB05LyEnvtVrMvHjNtH1wzEnLxt5uyTvMxtb1B0L2BU51ubj3zZ51uUfwBL1JiVXgzFDxyYjIxtjvzSvwyZvMxojdmXCtmW41usv2CVvNCJv2CErLx051uj5gzPnwy09MCEnLBV5wzEnvtVrMtH1wzEn1BSr2x3fMCErNx051uevMzHvhB05LqErNxEb]] )

    storeDefault( [[SimC Retribution: cooldowns]], 'actionLists', 20170717.174531, [[dauSiaGisvYMirzuIQ6uIkTksv0UePHbkhdLSmsLNHsftJuvDnrf2gPk13aHXrQcohPQyDKOkZtur3tuL9HsvhuPYcbrpeLYejrvDrsrBKevmssuPtskCtLYovvdfLk1sjHNsmvuLTsI8vsvP9k9xvXGP4WQSyu5XuzYu1LH2mO6ZIYObPtl0RvQA2cUnk2nIFRy4QshNufA5i9CLmDGRtsBxe9DsPZJQA9OujZxe2pLUSkVk)JbRirg2SgfiGg5ubXHO8Sg3mb)OLSQiVOlEHi76aXH0peWQOad4TW(1bJfeW0BD5ivhm2rF0VUkIJgFbvQSZbIdzvE9ZQ8QOj54cOVqwrC04lOs(wdNkC4PoQ668yQ6R1OmRHtfo8uhvDDEmDbo3ERH95znSYH1KiH14Mj4hTKuhvDDEmLImxKSSg2BnzoV1ONwJoRjxRjrcRjFRHtfo80ljsYIKShT0danv91AsKWACZe8Jws6Lejzrs2Jw6bGMsrMlswwd7TMmN3A0tRrN1KBLDCXqeWVY6fDaK(mWF4qa94FHkSbfD73MKidsaLRY24v6O)JbRu5FmyL1l6ai9zG)WHa6X)cv2rZwvihdM36fDaK(mWF4qa94FHkkWaElSFDWybblyvuGRrL6Wv5vqfni(O7adTcziyLTX)pgSsb9RR8QOj54cOVqwrC04lOcyYYcy67aIdzznkZAY3AY3A4uHdpLlmJpOUaPQVwtIewdNkC4PxsKKfjzpAPhaAQ6R1KiH1WPchEQJQUopMQ(AnkZA4uHdp1rvxNhtPiZfjlRjNwJUCynjsynGJMHGuqKbFaZJpIwtoZZA0pmRjxRj3k74IHiGFL3behsf2GIU9BtsKbjGYvzB8kD0)XGvQ8pgSc7EaXHuzhnBvHCmyE61e8pApQEvrbgWBH9RdgliybRIcCnQuhUkVcQObXhDhyOvidbRSn()XGvMG)r7rlOF2P8QOj54cOVqwrC04lOcyYYcyQBMGF0swv2Xfdra)kCHz8pWvP8RObXhDhyOvidbRSnELo6)yWkv(hdwbYWmERr5Os5xrbgWBH9RdgliybRIcCnQuhUkVcQWgu0TFBsImibuUkBJ)FmyLc6x)Lxfnjhxa9fYkIJgFbvatwwatDZe8JwYQYoUyic4xHdPlKUpsYQObXhDhyOvidbRSnELo6)yWkv(hdwbsKUq6(ijRIcmG3c7xhmwqWcwff4AuPoCvEfuHnOOB)2KezqcOCv2g))yWkf0FokVkAsoUa6lKvehn(cQaDc8FEhTin1PsPibyn5mpRr)v2Xfdra)kh1De8bmuksav0G4JUdm0kKHGv2gVsh9FmyLk)JbRSJ6ocAn8gkfjGkkWaElSFDWybblyvuGRrL6Wv5vqf2GIU9BtsKbjGYvzB8)JbRuq)6D5vrtYXfqFHSI4OXxqfWKLfWu3mb)OLSQSJlgIa(vGob(pAPhaAfni(O7adTcziyLTXR0r)hdwPY)yWkk3jW3A0x6bGwrbgWBH9RdgliybRIcCnQuhUkVcQWgu0TFBsImibuUkBJ)FmyLc6hIYRIMKJlG(czLDCXqeWVYcAed(Nb(tsKKHhXHv0G4JUdm0kKHGv2gVsh9FmyLk)JbRiqJyWBndCRrjKKHhXHvuGb8wy)6GXccwWQOaxJk1HRYRGkSbfD73MKidsaLRY24)hdwPG(1dLxfnjhxa9fYkIJgFbvatwwatDZe8JwYQYoUyic4x5sIKSij7rl9aqRObXhDhyOvidbRSnELo6)yWkv(hdwzxsKKfjzwJ(spa0kkWaElSFDWybblyvuGRrL6Wv5vqf2GIU9BtsKbjGYvzB8)JbRuq)6t5vrtYXfqFHSI4OXxqfWKLfWu3mb)OLSSgLzn5BnqNa)N3rlstDQuksawd7ZZAyhRjrcRjFRjFRb1JQX3x0NgINNgjRh4Qu(pQKaElOO3AsKWAONdt5cZ4FWaCRjxRrzwd0jW)5D0I0uNkLIeG1W(8SgDwtUwtUv2Xfdra)koQ668yfni(O7adTcziyLTXR0r)hdwPY)yWkSrvxNhROad4TW(1bJfeSGvrbUgvQdxLxbvydk62VnjrgKakxLTX)pgSsbfur5JWp1aOqwql]] )

    storeDefault( [[SimC Retribution: priority]], 'actionLists', 20170717.174531, [[duuCNaqiPsLnjr9jIkmksLofPIvrLQMfvQu6wsLsTlvzyukhdkwgvYZKimnPICnPs2gvQ4BevnoQujNtQu16KkL08iQ09KkSpjshuKYcfP6HuPmrIk6IsiJuQuItkHALsLIBcv2jPSuj4PctLs1wHQ6RuPsXAPsLQ9c(lvmyehwLftKhtvtMIlRSzr8zrYOHsNMKvtQQxdvz2QQBlPDt43OA4uYXLiYYr55IA6qUUu2or57svgVerDEPQwVurnFsv2psdya7qOD1brOQUrjfgIPKAifx0TsjwmfNPq9HiSMxDFvNpKIlan5TbrH93LhO5Ygg5T5oU665Ywj6(o5cIWZuwiiGinpsXfzWoOHbSdrrIt6pdKoeHNPSqqCEKs2CMyv1YuIC7GskbLuMs0Ls8C(3W7jE63mPQtGESvpLitjYLss5nuI7PKo96Is0tpkXmPwsYt)MjvDc0JT6PezkPukjL3qjUNs60Rlkrhists9vO(qSsE(gsXfo5jqt4heflmk)H4mieCXGah3G)X0U6GacTRoikQKNVHuCbLetGMWpikS)U8anx2WipgBquyzEJ5xgSdiiCd784HJlB1jqGee44gTRoiaeO5cSdrrIt6pdKoeHNPSqqCEKs2CMyv1YusPDqjUOe90Js0LsKAjjVS)y)HCuIsQPYkeNLDwjB1yPoKIlEz05XJskTdkXv3tjLPeDPePwsY7KnrkLiLtp2HW(AwuIE6rj6sjsTKKNN1YNzVMfLuMsKAjjppRLpZEz05XJskTdkbtxuIouIE6rj6sjEo)B49eppRLpZESvpLitjLsjy6IsktjDhLi1ssEEwlFM9AwuIouIE6rjEo)B49eVt2ePuIuo9yhc7JT6PezkPukbtxuIouIoqKMK6Rq9Hq2XuN0Fq4g25Xdhx2QtGajiWXn4FmTRoimzh)LrN0FqOD1brG4Srj4F)2GinwQmeIRUomzh)LrN0FUBLD)2648iLS5mXQQLlTdx6PNUsTKKx2FS)qokrj1uzfIZYoRKTASuhsXfVm684vAhU6(Y6k1ssENSjsPePC6Xoe2xZsp90vQLK88Sw(m71Skl1ssEEwlFM9YOZJxPDGPlD0tpD9C(3W7jEEwlFM9yREkrUumDvU7KAjjppRLpZEnlD0tppN)n8EI3jBIukrkNESdH9Xw9uICPy6shDGOW(7Yd0CzdJ8ySbrHL5nMFzWoGGOyHr5peNbHGlge44gTRoiaeOvcWoefjoP)mq6qeEMYcbHzsTKKN(ntQ6eOxZIsktjYoM6K(7zYo(lJoP)OKYuIulj5zuYuI5y1yw88EnlkPmLi1ssEgLmLyownMfpVhB1tjYuICPKuEdL4EkXfePjP(kuFimkzkXCYioRcrXcJYFiodcbxmiWXn4FmTRoiGq7Qdc5ujtjgLeioRcrH93LhO5Ygg5XydIclZBm)YGDabHByNhpCCzRobcKGah3OD1bbGaTob2HOiXj9NbshIWZuwiimtQLK80VzsvNa9Awuszkr2XuN0Fpt2XFz0j9hLuMsWY)9DS49g75Bm2eikP0oOKUOKYuIulj5zuYuI5y1yw88Enlists9vO(qyuYuI5KrCwfIIfgL)qCgecUyqGJBW)yAxDqaH2vheYPsMsmkjqCwLs0fJoquy)D5bAUSHrEm2GOWY8gZVmyhqq4g25Xdhx2QtGajiWXnAxDqaiqRlWoefjoP)mq6qeEMYcbHzsTKKN(ntQ6eOxZIsktjNhPKnNjwvTmLuAhuIlkPmLGL)77yX7n2Z3ySjqusPDqjLGsktj6sjsTKKNN1YNzVMfLuMsKAjjppRLpZEz05XJsKlLGPlkrp9OePwsY7RodtjYojnwFNM4VlJDMxZIs0bI0KuFfQpegLmLyozeNvHOyHr5peNbHGlge44g8pM2vheqOD1bHCQKPeJsceNvPeDDPdef2FxEGMlByKhJnikSmVX8ld2beeUHDE8WXLT6eiqccCCJ2vheac0ChWoefjoP)mq6qeEMYcbHzsTKKN(ntQ6eOxZIsktjYoM6K(7zYo(lJoP)OKYucw(VVJfV3ypFJXMarjL2bL0fePjP(kuFimkzkXCYioRcrXcJYFiodcbxmiWXn4FmTRoiGq7Qdc5ujtjgLeioRsj6wcDGOW(7Yd0CzdJ8ySbrHL5nMFzWoGGWnSZJhoUSvNabsqGJB0U6GaqGM8GDiksCs)zG0Hi8mLfccZKAjjp9BMu1jqVMfLuMsKAjjpJsMsmhRgZIN3RzrjLPePwsYZOKPeZXQXS459yREkrMsKlLKYBOe3tjUOKYus3rjRKAklRzE9WQYwJ5WtCqyNJ4qyzRZQkePjP(kuFi0VLrk)XYoYMi1oHFquSWO8hIZGqWfdcCCd(ht7Qdci0U6GOBAzKYFm5itj4prQDc)GOW(7Yd0CzdJ8ySbrHL5nMFzWoGGWnSZJhoUSvNabsqGJB0U6GaqGM7cSdrrIt6pdKoeHNPSqqyMulj5PFZKQob61SOKYucw(VVJfV3ypFJXMarjL2bL0fLuMsKAjjpJsMsmhRgZIN3RzrjLPKUJswj1uwwZ86HvLTgZHN4GWohXHWYwNvvists9vO(qOFlJu(JLDKnrQDc)GOyHr5peNbHGlge44g8pM2vheqOD1br30YiL)yYrMsWFIu7e(rj6IrhikS)U8anx2WipgBquyzEJ5xgSdiiCd784HJlB1jqGee44gTRoiaeO19GDiksCs)zG0Hi8mLfccZKAjjp9BMu1jqVMfLuMsKAjjpJsMsmhRgZIN3RzrjLPePwsYZOKPeZXQXS459yREkrMsKlLKYBOe3tjUGinj1xH6dbAvR)XYoYgZO8iikwyu(dXzqi4IbboUb)JPD1bbeAxDqyFvR)XKJmLG)ygLhbrH93LhO5Ygg5XydIclZBm)YGDabHByNhpCCzRobcKGah3OD1bbGanm2a7quK4K(ZaPdr4zkleeMj1ssE63mPQtGEnlkPmLGL)77yX7n2Z3ySjqusPDqjDrjLPePwsYZOKPeZXQXS459AwqKMK6Rq9HaTQ1)yzhzJzuEeeflmk)H4mieCXGah3G)X0U6GacTRoiSVQ1)yYrMsWFmJYJOeDXOdef2FxEGMlByKhJnikSmVX8ld2beeUHDE8WXLT6eiqccCCJ2vheac0WGbSdrrIt6pdKoeHNPSqqyMulj5PFZKQob61SOKYucw(VVJfV3ypFJXMarjL2bLuckPmLOlLi1ssEEwlFM9AwuszkrQLK88Sw(m7LrNhpkrUucMUOe90JsKAjjVV6mmLi7K0y9DAI)Um2zEnlkrhists9vO(qGw16FSSJSXmkpcIIfgL)qCgecUyqGJBW)yAxDqaH2vhe2x16Fm5itj4pMr5ruIUU0bIc7VlpqZLnmYJXgefwM3y(Lb7acc3WopE44YwDceibboUr7QdcabAyCb2HOiXj9NbshIWZuwiimtQLK80VzsvNa9Awuszkbl)33XI3BSNVXytGOKs7Gs6cI0KuFfQpeOvT(hl7iBmJYJGOyHr5peNbHGlge44g8pM2vheqOD1bH9vT(htoYuc(JzuEeLOBj0bIc7VlpqZLnmYJXgefwM3y(Lb7acc3WopE44YwDceibboUr7QdcabAykbyhIIeN0FgiDicptzHGqxkzLutzznZRhwv2AmhEIdc7CehclBDwvPe90JsmtQLK80VzsvNa9AwuIouszkr2XuN0Fpt2XFz0j9hLuMsogsLCE0R3H3C4joxg7YVjoP)muszkXZ5FdVN417WBo8eNlJD5hB1tjYuICPKuEdL4EkXfePjP(kuFimkzkXCYioRcrXcJYFiodcbxmiWXn4FmTRoiGq7Qdc5ujtjgLeioRsj62jDGOW(7Yd0CzdJ8ySbrHL5nMFzWoGGWnSZJhoUSvNabsqGJB0U6GaqGgMob2HOiXj9NbshIWZuwiimtQLK80VzsvNa9Awuszkr2XuN0Fpt2XFz0j9hLuMsKAjjVEyvzRXC4joiSZrCiSS1zv91SOKYuIulj51dRkBnMdpXbHDoIdHLToRQp2QNsKPe5sjP8gkX9ucMxxqKMK6Rq9HWOKPeZjJ4Skeflmk)H4mieCXGah3G)X0U6GacTRoiKtLmLyusG4SkLOBx6arH93LhO5Ygg5XydIclZBm)YGDabHByNhpCCzRobcKGah3OD1bbGanmDb2HOiXj9NbshIWZuwii0Lswj1uwwZ86HvLTgZHN4GWohXHWYwNvvkrp9OeZKAjjp9BMu1jqVMfLOdLuMsogsLCE0R3H3C4joxg7YVjoP)muszkXZ5FdVN417WBo8eNlJD5hB1tjYuICPKuEdL4EkXfePjP(kuFiqRA9pw2r2ygLhbrXcJYFiodcbxmiWXn4FmTRoiGq7Qdc7RA9pMCKPe8hZO8ikr3oPdef2FxEGMlByKhJnikSmVX8ld2beeUHDE8WXLT6eiqccCCJ2vheac0W4oGDiksCs)zG0Hi8mLfccZKAjjp9BMu1jqVMfLuMsKAjjVEyvzRXC4joiSZrCiSS1zv91SOKYuIulj51dRkBnMdpXbHDoIdHLToRQp2QNsKPe5sjP8gkX9ucMxxqKMK6Rq9HaTQ1)yzhzJzuEeeflmk)H4mieCXGah3G)X0U6GacTRoiSVQ1)yYrMsWFmJYJOeD7shikS)U8anx2WipgBquyzEJ5xgSdiiCd784HJlB1jqGee44gTRoiaeOHrEWoefjoP)mq6qeEMYcbHHJERKNVHuCHtEc0e(9qkpEkrkkPmLy4O3k55Bifx4KNanHFp2QNsKPe5sjP8gkX9uIlkPmLyMulj5PFZKQob6Xw9uImLixkjL3qjUNsCbrAsQVc1hc9BMu1jqquSWO8hIZGqWfdcCCd(ht7Qdci0U6GOBAMu1jqquy)D5bAUSHrEm2GOWY8gZVmyhqq4g25Xdhx2QtGajiWXnAxDqaiqdJ7cSdrrIt6pdKoeHNPSqqOlL458VH3t8K(Nzo8eh9BzKYVhB1tjYusPuskVHsCpL4Is0tpkXZ5FdVN4zuYuI5G9Q1XESvpLitjLsjP8gkX9uIlkrhists9vO(q45I88SdP4cikwyu(dXzqi4IbboUb)JPD1bbeAxDq4gxKNNDifxarH93LhO5Ygg5XydIclZBm)YGDabHByNhpCCzRobcKGah3OD1bbGanmDpyhIIeN0FgiDicptzHGqxkbl)33XI3BSNVXytGOe52bLyJs0tpkbl)33XI3BSNVXytGOKoOemuszkrxkXZ5FdVN4j9pZC4jo63YiLFp2QNsKPKsPKuEdLONEuINZ)gEpXZOKPeZb7vRJ9yREkrMskLss5nuIouIE6rjy5)(ow8EJ98ngBceL0bL4Isktj6sj6sjEo)B49eVoV7)8ypwQLDsyNhP4I7tjYTdkX2ZD6Is0tpkXZ5FdVN45zT8zgZjJyk82ZJ9yPw2jHDEKIlUpLi3oOeBp3Plkrhkrhkrhists9vO(q07WBo8eNlJDzikwyu(dXzqi4IbboUb)JPD1bbeAxDq4U5WBucpHsslJDzikS)U8anx2WipgBquyzEJ5xgSdiiCd784HJlB1jqGee44gTRoiaeO5YgyhIIeN0FgiDicptzHGal)33XI3BSNVXytGOe52bLuckPBtj5HCK4Iw(HuJ5YMtNS8qKMK6Rq9Hq6FM5WtC0VLrk)GOyHr5peNbHGlge44g8pM2vheqOD1br6)ZmkHNqjDtlJu(brH93LhO5Ygg5XydIclZBm)YGDabHByNhpCCzRobcKGah3OD1bbGanxya7quK4K(ZaPdr4zkleey5)(ow8EJ98ngBceLi3oOKsqjDBkjpKJex0YpKAmx2C6KLhI0KuFfQpegLmLyoyVADmikwyu(dXzqi4IbboUb)JPD1bbeAxDqiNkzkXOKULRwhdIc7VlpqZLnmYJXgefwM3y(Lb7acc3WopE44YwDceibboUr7QdcabAUCb2HOiXj9NbshI0KuFfQpe63mPQtGGOyHr5peNbHGlge44g8pM2vheqOD1br30mPQtGOeDXOdef2FxEGMlByKhJnikSmVX8ld2beeUHDE8WXLT6eiqccCCJ2vheac0CvcWoefjoP)mq6qeEMYcbHNZ)gEpXRZ7(pp2JLAzNe25rkU4(usPDqjyEUtxuszkbl)33XI3BSNVXytGOe52bL0jkPmLOlL458VH3t8K(Nzo8eh9BzKYVhB1tjYusPuskVHsCpL4Is0tpkXZ5FdVN4zuYuI5G9Q1XESvpLitjLsjP8gkX9uIlkrhkPmLyMulj5PFZKQob6Xw9uImLukLKYBGinj1xH6drN39HOyHr5peNbHGlge44g8pM2vheqOD1bH7(Upef2FxEGMlByKhJnikSmVX8ld2beeUHDE8WXLT6eiqccCCJ2vheac0C1jWoefjoP)mq6qeEMYcbHNZ)gEpXZZA5ZmMtgXu4TNh7XsTStc78ifxCFkP0oOemp3PlkPBtjO7pb6HWoNefBzhEIJ(Tms53t5mXj9NHsCpLy75QlkPmLGL)77yX7n2Z3ySjquIC7Gs6eLuMs0Ls8C(3W7jEs)ZmhEIJ(Tms53JT6PezkPukjL3qjUNsCrj6PhL458VH3t8mkzkXCWE16yp2QNsKPKsPKuEdL4EkXfLOdLuMsmtQLK80VzsvNa9yREkrMskLss5nqKMK6Rq9HWZA5ZmMtgXu4nikwyu(dXzqi4IbboUb)JPD1bbeAxDq4gRLpZyusGyk8gef2FxEGMlByKhJnikSmVX8ld2beeUHDE8WXLT6eiqccCCJ2vheac0C1fyhIIeN0FgiDists9vO(q45I88SdP4cikwyu(dXzqi4IbboUb)JPD1bbeAxDq4gxKNNDifxqj6IrhikS)U8anx2WipgBquyzEJ5xgSdiiCd784HJlB1jqGee44gTRoiaeO5YDa7quK4K(ZaPdr4zkleeMj1ssE63mPQtGEnlkPmLi7yQt6VNj74Vm6K(JsktjsTKKNrjtjMJvJzXZ71SGinj1xH6dHrjtjMtgXzvikwyu(dXzqi4IbboUb)JPD1bbeAxDqiNkzkXOKaXzvkrx3rhikS)U8anx2WipgBquyzEJ5xgSdiiCd784HJlB1jqGee44gTRoiaeO5sEWoefjoP)mq6qeEMYcbHzsTKKN(ntQ6eOxZIsktjYoM6K(7zYo(lJoP)OKYuIulj5HWoNefBzhEIJ(Tms53RzbrAsQVc1hcJsMsmNmIZQquSWO8hIZGqWfdcCCd(ht7Qdci0U6GqovYuIrjbIZQuIUYRdef2FxEGMlByKhJnikSmVX8ld2beeUHDE8WXLT6eiqccCCJ2vheac0C5Ua7quK4K(ZaPdr4zkleeMj1ssE63mPQtGEnlkPmLi7yQt6VNj74Vm6K(dI0KuFfQpegLmLyozeNvHOyHr5peNbHGlge44g8pM2vheqOD1bHCQKPeJsceNvPeDDx6arH93LhO5Ygg5XydIclZBm)YGDabHByNhpCCzRobcKGah3OD1bbGanxDpyhIIeN0FgiDicptzHGWmPwsYt)MjvDc0RzrjLPePwsYZOKPeZXQXS459AwuszkP7OKvsnLL1mVEyvzRXC4joiSZrCiSS1zvfI0KuFfQpe63YiL)yzhztKANWpikwyu(dXzqi4IbboUb)JPD1bbeAxDq0nTms5pMCKPe8Ni1oHFuIUU0bIc7VlpqZLnmYJXgefwM3y(Lb7acc3WopE44YwDceibboUr7QdcabALWgyhIIeN0FgiDicptzHGWmPwsYt)MjvDc0RzrjLPePwsYZOKPeZXQXS459AwqKMK6Rq9HaTQ1)yzhzJzuEeeflmk)H4mieCXGah3G)X0U6GacTRoiSVQ1)yYrMsWFmJYJOeDDhDGOW(7Yd0CzdJ8ySbrHL5nMFzWoGGWnSZJhoUSvNabsqGJB0U6GaqGwjWa2HOiXj9NbshIWZuwiimtQLK80VzsvNa9AwuszkrQLK8qyNtIITSdpXr)wgP871SGinj1xH6dbAvR)XYoYgZO8iikwyu(dXzqi4IbboUb)JPD1bbeAxDqyFvR)XKJmLG)ygLhrj6kVoquy)D5bAUSHrEm2GOWY8gZVmyhqq4g25Xdhx2QtGajiWXnAxDqaiqReUa7quK4K(ZaPdr4zkleeMj1ssE63mPQtGEnlkPmLOlL0Duc6(tGERKNVHuCHtEc0e(9M4K(Zqj6PhL458VH3t8wjpFdP4cN8eOj87Xw9uImLukLKYBOe3tjUOeDGinj1xH6dbAvR)XYoYgZO8iikwyu(dXzqi4IbboUb)JPD1bbeAxDqyFvR)XKJmLG)ygLhrj66U0bIc7VlpqZLnmYJXgefwM3y(Lb7acc3WopE44YwDceibboUr7QdcabALOeGDiksCs)zG0Hi8mLfcIvsnLL1mp9BzKYpNuxNhLuMsqhl1qpS7(iSplpIskTdkr(UOKYucw(VVJfV3ypFJXMarjYTdkPtqKMK6Rq9Ha7vRJ5WtC0VLrk)GOyHr5peNbHGlge44g8pM2vheqOD1br3YvRJrj8ekPBAzKYpikS)U8anx2WipgBquyzEJ5xgSdiiCd784HJlB1jqGee44gTRoiaeOvIob2HOiXj9NbshIWZuwiiWY)9DS49g75Bm2eikrUDqjDcI0KuFfQpeDE3hIIfgL)qCgecUyqGJBW)yAxDqaH2vheU77(uIUy0bIc7VlpqZLnmYJXgefwM3y(Lb7acc3WopE44YwDceibboUr7QdcabALOlWoefjoP)mq6qeEMYcbbw(VVJfV3ypFJXMarjYTdkPtqKMK6Rq9HWZA5ZmMtgXu4nikwyu(dXzqi4IbboUb)JPD1bbeAxDq4gRLpZyusGyk8gLOlgDGOW(7Yd0CzdJ8ySbrHL5nMFzWoGGWnSZJhoUSvNabsqGJB0U6Gaqacc5Cjx7JG0beaa]] )


    storeDefault( [[Retribution Primary]], 'displays', 20170625.203942, [[d4ZpiaGEvvEPQQSlvvv2gkP0HLmtkHXPQQQzRKLrjDtusopP62K0PHANuSxXUjSFvXprKHjf)gYLvzOOQbRknCK6GsvhfLu1XOuhNs0cLslvQ0IrLLt0djrpf8yuSosPAIkvXurYKrPMUIlQQCvPcEMsv66iSrLkBvQqTzQ02jfFuQOpJOMgPeFxPmssj9nsPmAQy8OeNKeULuHCnvvL7HskEovTwusLxRuvh7qfGPOhmsSdjgy0xxasDGYcfMVatjjFdVg(WfqwcYNsNJz)0gGBH)9RZfAlCb0j566VrzrpyKWhttawi566VrzrpyKWhttaljoIJTcgKaW)Uy0staVdARNqwkeUOWfWsIJ4yRSOhms4tBaDsUU(BOkj5B8X0eG1tCeNpuXyhQaFIIBDStBGEMbJepVwG9tmwdyk1laGvv(829gjMJyWiH2FEPLhdsLRMaDV1v(lgRn2ARXUPjaWiX0tGbRESMMmXynub(ef36yN2a9mdgjEETa7NySdyk1laGvv(829gjMJyWiH2FEzFUfXAc09wx5VyS2yRTg7MMmzc4DqBWgEyC6)sBawi566VHQKKVXhttamdsa0fdwqoM)fykj5B6fmoizGwsuuKyvxfDQvQa6X0rw1staxKyc0lX1651usjAlG3bTrvsY34tBG956fmoizaks8Dv0PwPcWGu5QHxZx4cWu0dgj6fmoizGwsuuKyvaLiA9NxkuaEjAoMbJepV8sSAj1d4DqBavAdyjXrC7blpMbJeb6QOtTsfqqOQGbj8XOLaE6BT2TkVJs0cjdvGkg7aCXyhGCm2bKXyNjG3bTPSOhms4tBawi566VPNqwX0eOiKfLo9fGJW1nWEo3IynPnGAXspXGIPjalKCD93OqWgZuds6JPjqTODkWbTXR5lg7a1I2PuIu5QHxZxm2bmL6fO7nsmhXGrINxEjwTK6bQfTt1V2kDpVMVySduRTs3ZRHpTb0G9yo8cp6u60xaUamf9GrI(fMSiGYpd1x3aSXE6vPtPtFbQaa9XGRf(xnyKigT1eqwcYhLo9fO4Wl8OhOiKfRWIlTb0j566VrHGnMPgK0httG952HedG)DXyBnWusY3SdjMa8upVqj8pVMskrBb4Ly1sQ)8QSOhms882tiRabWmibRdHuJX(FbK3kGYpd1x3aE6BT2TkVt4culANIQKKVHxZxm2b(705Wc2yb5Nxy0xxmwdyjXrCSviyJzQbj9PnG3bTbB4HXPNyqPnG3bT1tmO0gykj5B2Hedm6RlaPoqzHcZxawvSGvjuFEPWQxm7TjqrilfcxeLo9fGJW1naWiX0tGa1I2P6xBLUNxdFm2bulwaQySdqlXQLuFhsma(3fJT1a0YJbPYvtpVfbaSQYN3U3iXCedgj0(ZlT8yqQC1eGwIvlPUcgKaW)Uy0sta1IL(VyAcqvRtmpVDkre0Xyhykj5B418fUaEh02FNohwWgli7tBaEjwTK6pVkl6bJebMss(gFaSGnMPgKSxW4GKb6QOtTsfqfl6jgumnbyk6bJe7qIbW)UySTgOw0oLsKkxn8A4JXoqTODkWbTXRHpg7aEh0McbBmtniPpTbQfTtrvsY3WRHpg7a1AR098A(sBaVdAR)lTb8oOnEnFPnadsLRgEn8HlW(C7qIjap1Zluc)ZRPKs0waDsUU(B(R1hthzhyFUDiXaJ(6cqQduwOW8fqflaQyAcmLK8n7qIbW)UySTgW7G241WN2amf9GrIDiXeGN65fkH)51usjAlqrilG(wlf7jMMaFIIBDStBapwLED9K(IXAaDsUU(B6jKvmnb6ERR8xmwBS1wdR1EV)NTvRw)3)hGfsUU(B(R1hJDavSO)lM9gWsIJ46xyYc1tmbycWsmnbyFUfXA65TiaGvv(829gjMJyWiH2FEzFUfXAcSqBNKP83FT(WfOiKvVGXbjd0sIIIeRS4BhvaljoIJ9oKya8VlgBRb4w4F)6CH26xRWfWsIJ4y)xRpTbSKaZSFhJ9WOVUavGIqwDqGNa0Rs)Kzsa]] )

    storeDefault( [[Retribution AOE]], 'displays', 20170625.203942, [[deeoiaqiuvL2KuO6wsHYUuIQHPQ6yezzOkpdLOPPeLRPQW2qjuFdvv14qvL6COeY6Kc5EOQkoOuAHQspKOAIOeCrL0gvcFujYijL0jjfVeLuZKuQBIsYoP4NazOKQJIQkAPsrpfAQO4QKsSvuvH1IQkzVIbRuDyjlgjpgvMmk1LvzZuXNbQrtPonIxRQOzlv3Ms2nHFdA4i1XLcwojpNQMUIRdy7eLVRkgpQkNNkTEvL2Vs5ifMGCf9qGIfqXGJB)ccslmARXSgCkf4B0LPhQGQsa(KBFCFM3GuDY3Vl1HpHkOlihh)nYl6Haf(y(dYhihh)nYl6Haf(y(dsRiwLYvdhuGKVxml7pO3g(0cOknchyOc2aWbCSLx0dbk85nOlihh)nmLc8n(y(dYpboGZhMyKctWvrr1p25nyl3qGITDTj(jgEbnL1fejwY32BEJIqbmeOOrB70QJdArvtWMx)k)fdVFPpKKwopEsbrofHEcoeRJ)8NjgEHj4QOO6h78gSLBiqX2U2e)eJuqtzDbrIL8T9M3OiuadbkA02o7ZPa6tWMx)k)fdVFPpKKwopEszYe0BdFWhYWz3UgQG8bYXXFdtPaFJpM)GeoOaPloIaCmFeCkf4BAfC2qvWxqmmGyvtnlPvMGUX0ysSOpc6aftWwfP6B7MsPGpbz95sreSjcWB7442Vy4f8tQwbNnufKbKEtnlPvMGCqlQA0LTgQGCf9qGIwbNnuf8feddiwfuoK2DBNbgS5nkcfWqGIT9wqRb92WhKjVbBa4aowGOoUHafbBQzjTYeuayPHdk8XSSGE6R3x0lVTCyhQctWkgPGQyKccogPGuXiLjO3g(iVOhcu4ZBq(a544VPfqvX8hSaufJl9fKcWXjOvXxlWaJ5py1PTR2(t561LTgJuWQtBxOn8rx2AmsbRoTDjhArvJUS1yKcAkRlyZBuekGHafB7TGwd2aaH7t(bXJJB)csfS6pLRxxMEEdkJ4juKozCzCPVGub5k6HafTDcyrq5RgM1Mbzt809YLXL(cYfKfoNcOp5nOQeGpgx6lyrr6KXnybOkwrexEdI0hhP6KV1qGIy4))GFsTakgK89IrIxq(a544VrJGnHRgOYhZFqDfXQuUB7Yl6HafB7TaQkyqp917l6L3oubvxpO8vdZAZGtPaFZcOycQZSTJLWVTBkLc(eS602ftPaFJUS1yKcs4Gc(feAfJ0hbBa4ao2AeSjC1av(8g0BdFykf4B85niFX8hCkf4BwafdoU9liiTWOTgZAqwv8rSaS22ziwxmS8pO3g(GpKHZUfyG5niYPi0tqpraUFno)TagyWQtBxT9NY1RltpgPGfGQ0iCGmU0xqkahNG0kIvPCxafds(EXiXliT64Gwu10QRDqKyjFBV5nkcfWqGIgTTtRooOfvnbTk(qMy(dAv81UgZFqMQFIzBFjfeGoM)GtPaFJUS1qf0BdFy95sreSjcW(8gS51VYFXW7xI))zXsSC5s84X7d(DWQtBxmLc8n6Y0JrkirWMWvdu1k4SHQGn1SKwzcYv0dbkwafds(EXiXlydahWXwdhuGKVxml7py1PTl5qlQA0LPhJuqVn8rJGnHRgOYN3GvN2UqB4JUm9yKcw9NY1RlBnVb92WhDzR5nO3g(0UgQGCqlQA0LPhQGFsTakMG6mB7yj8B7MsPGpbDb544VH1V(yAmPGFsTakgCC7xqqAHrBnM1GwebYedldoLc8nlGIbjFVyK4f0BdF0LPN3GCf9qGIfqXeuNzBhlHFB3ukf8jybOkK(6DnSqm)bxffv)yN3GEIfD)AbTgdVGUGCC830cOQy(dYhihh)nS(1hJuqDfXQuUB7Yl6HafbNsb(gFqVn8PfyGHkydahW12jGfwNycYf0IiAxJHLbzFofqFA11oisSKVT38gfHcyiqrJ22zFofqFcs1jF)Uuh(027HkybOQwbNnuf8feddiwP96cMGnaCah7fqXGKVxms8c6cYXXFJgbBcxnqLpM)GnaCahBw)6ZBqlIOfyGXWYGfGQ0IGmbP7L7PYKa]] )

    storeDefault( [[Protection Primary]], 'displays', 20170625.203942, [[dWtBiaGEiYlvQYUivLTPuvZeLQzRKdl5Mij(TQ(gPk0YeQ2jj7LA3OA)qQFIedtugNuH6ZOKHIIbdjdhPoOu6OKQOogPCCHIfkflfLYIfPLt0dLk9uWJHYZfmrKKMkunzcz6kUieUkPkDzvUobBuPYwjvr2SOA7eQpkv0PrmniQ(UszKsf8mHsJweJhj1jjvULuHCnsv15fYTLQwlPk41qu2Ag3awrpKNV75dmrRZaf9IZUofcdtjzDdJygNAqwCwx3KddzUXq6IGesDU(nNAiIsEE4MUf9qEEWQmdutjppCt3IEippyvMHyeoHtKoSNdeKoRqEMHqYV1kilD883PgIr4eorDl6H88GBmerjppCdEjzDtWQmd6zHt4cg3knJBabVsxNi3yOfBiphnk2jHXkKBqv9Nbg5ph2qEoAuu9YpEGi(cgy7wxfoRINPTVwwwS6tZaGjj0Jbpwf34gqWR01jYngAXgYZrJIDsySs)guv)zGr(ZHnKNJgv3)xI(nEWaB36QWzv8mT91YYIvFAgamjHEm4XQynUbe8kDDICJHwSH8C0OyNegRI1GQ6pdmYFoSH8C0OaCdSDRRcNvXZ02xlllw9PzaWKe6XGhpgcj)gSrgSKweUXa1uYZd3Gxsw3eSkZab75aDHr4SSs)gMsY6MwowYln0qbhNcvytxNDa3qKvDuCKNzi)5JHwjPwOrPkP83mes(n8sY6MGBmGS0wowYlnGtHHnDD2bCdyFFAnmIr4udyf9qEElhl5LgAOGJtHkg6(0rOrH)gyK)Cyd55OrXij9LmYqi53aC3yigHt4OkrEyd55gytxNDa3axOxh2ZdwHCdb6BT2TQqs3F9sJBOSsZqQvAgyzLMbPvAEmes(TUf9qEEWngOMsEE4MwbzzvMHsqw4r0NHuH8Cdu9YlH14gd9f1TcZBvMbQPKNhUrhxebRMxgSkZqTOtki53yeJWknd1IoP6(9P1WigHvAguv)zGr(ZHnKNJgfJK0xYid1IoPAxBvuGrmcR0muRTkkWiMXngetcKuYImr4r0NHudyf9qEE7IWIBOlcfoc2miIeOxveEe9zOma0hgPweKQH8CR2FFdYIZ6WJOpdvkzrMidLGSOcHFUXqeL88Wn64Iiy18YGvzgqw6UNpabPZkT4gMsY6MDpFmWGJgfu8aAuQsk)ndmssFjJqJQBrpKNJgvRGSmyGG9C9W)9wPPFdYBzOlcfoc2meOV1A3Qcjo1qTOtk8sY6ggXiSsZWExukHlIWzHgfmrRZQ4gIr4eor64Iiy18YGBmes(nyJmyjTcZ7gdHKFRvyE3yykjRB298bMO1zGIEXzxNcHbQuut6f6rJcN0FwfBMHsqw645pEe9zivip3aGjj0Jbd1IoPAxBvuGrmJvAg6lQbCR0mqlj9LmA3ZhGG0zLwCd0Yd77tRPLHDRYmqlj9Lmsh2ZbcsNvipZqFrDlcRYmGxRJpOr1P8fOTkZWusw3WigHtnW2TUkCwfpttpMTVwS6tlE846VJnWij9LmcnQUf9qEUHPKSUjyGWfrWQ5LTCSKxAGnDD2bCd1IoPWljRByeZyLMHEcVvyERYmul6KQ73NwdJygR0mul6Kcs(ngXmwPziK8B64Iiy18YGBmGv0d557E(aeKoR0IBOwBvuGrmc3yiK8BTiCJHqYVXigHBmG99P1WiMXPgqw6UNpgyWrJckEankvjL)MHik55HB2RjyvhPzazP7E(at06mqrV4SRtHWqpHd4wLzykjRB298biiDwPf3qi53yeZ4gdyf9qE(UNpgyWrJckEankvjL)MHsqwa9Tw6OQvzgqWR01jYngcKE611sbHvXnerjppCtRGSSkZqi5327IsjCreoRGBmqnL88Wn71eSsZqpH3IWQyneJWjCTlclE)XhdygO2QmdIU8synTmSBGr(ZHnKNJgfvV8syngw)2jXQWTxtWPgkbz1YXsEPHgk44uOc7i2HBigHt4eT75dqq6SslUH0fbjK6C9BTRLtneJWjCI2Rj4gdXiqWqMEIeGjADgkdLGS0lNmgOxv0j9yd]] )


end
