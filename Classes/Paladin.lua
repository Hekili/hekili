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

local RegisterEvent = ns.RegisterEvent
local storeDefault = ns.storeDefault


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'PALADIN') then

    ns.initializeClassModule = function ()

        setClass( 'PALADIN' )
        Hekili.LowImpact = true

        -- addResource( SPELL_POWER_HEALTH )
        addResource( 'mana', true )
        addResource( 'holy_power', nil, true )

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

            end

        end )

        addHook( 'reset_postcast', function( x )
            state.last_consecration = state.last_cons_internal
            state.last_blessed_hammer = state.last_bh_internal
            state.last_shield_of_the_righteous = state.last_sotr_internal
            state.expire_consecration = state.expire_cons_internal

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
            if not state.equipped.liadrins_fury_unleashed then return t end

            local buff_remaining = 0

            if state.buff.crusade.up then buff_remaining = state.buff.crusade.remains
            elseif state.buff.avenging_wrath.up then buff_remaining = state.buff.avenging_wrath.remains end

            if buff_remaining < 4 then return t end

            local ticks_before = math.floor( buff_remaining / 4 )
            local ticks_after = math.floor( max( 0, ( buff_remaining - t ) / 4 ) )

            state.gain( ticks_before - ticks_after, 'holy_power' )

            return t
        end )

        addHook( 'spend', function( amt, resource )
            if state.buff.crusade.up and resource == 'holy_power' then
                if state.buff.crusade.stack < state.buff.crusade.max_stack then
                    state.stat.mod_haste_pct = state.stat.mod_haste_pct + ( ( state.buff.crusade.max_stack - state.buff.crusade.stack ) * 3.5 )
                end
                state.addStack( 'crusade', state.buff.crusade.remains, amt )
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


        addSetting( 'strict_finishers', false, {
            name = "Retribution: Strict Finishers",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will not recommend Holy Power spenders unless the Judgment debuff is on your target.\r\n\r\n" ..
                "This may have adverse effects in situations where you are target swapping.\r\n\r\n" ..
                "You may incorporate this into your custom action lists with the |cFFFFD100settings.strict_finishers|r flag.  It is also " ..
                "bundled into the |cFFFFD100judgment_override|r flag, which is |cFF00FF00true|r when all of the following is true:  Strict " ..
                "Finishers is disabled, Judgment remains on cooldown for 2 GCDs, and your Holy Power is greater than or equal to 5.",
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


        addAbility( 'aegis_of_light', {
            id = 204150,
            spend = 0,
            spend_type = 'mana',
            cast = 6,
            gcdType = 'spell',
            channeled = true,
            cooldown = 300,
            known = function () return talent.aegis_of_light.enabled end
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
            known = function () return not talent.crusade.enabled end,
            usable = function () return not talent.crusade.enabled and not buff.avenging_wrath.up end,
            toggle = 'cooldowns'
        } )

        addHandler( 'avenging_wrath', function ()
            applyBuff( 'avenging_wrath', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2.5 ) )
            if equipped.chain_of_thrayn then applyBuff( 'chain_of_thrayn', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2.5 ) ) end
        end )


        addAbility( 'bastion_of_light', {
            id = 204035,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            known = function () return talent.bastion_of_light.enabled end
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
            known = function() return not talent.divine_hammer.enabled end
        } )

        modifyAbility( 'blade_of_justice', 'cooldown', function( x )
            return x * haste
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
            known = function () return talent.blessed_hammer.enabled end
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
            known = function () return not talent.blessing_of_spellwarding.enabled end
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
            known = function() return talent.blinding_light.enabled end
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
            known = function () return talent.crusade.enabled end,
            usable = function () return not buff.crusade.up end,
            toggle = 'cooldowns'
        } )

        addHandler( 'crusade', function ()
            applyBuff( 'crusade', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2.5 ) )
            if equipped.chain_of_thrayn then applyBuff( 'chain_of_thrayn', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2.5 ) ) end
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
            known = function () return not talent.zeal.enabled end
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
            known = function () return talent.divine_hammer.enabled end
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
            known = function () return talent.execution_sentence.enabled end
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
            known = function () return talent.eye_for_an_eye.enabled end
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
            known = function () return not talent.blessed_hammer.enabled end
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
            known = function () return talent.hand_of_the_protector.enabled end
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
            known = function() return talent.holy_wrath.enabled end,
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
            end
        end )


        addAbility( 'justicars_vengeance', {
            id = 215661,
            spend = 5,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            known = function () return talent.justicars_vengeance.enabled end
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
            known = function () return talent.repentance.enabled end,
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
            known = function () return talent.seraphim.enabled end
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
            known = function () return equipped.ashbringer and ( toggle.wake_of_ashes or ( toggle.cooldowns and settings.wake_of_ashes_cooldown ) ) end,
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
            known = function () return talent.word_of_glory.enabled end
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
            known = function () return talent.zeal.enabled end
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


    storeDefault( [[Protection ST]], 'actionLists', 20170523.211251, [[d8J2haGAvaRhrs2eje7cL2Mi1(iHYPv1LHMnfZNeQ(ejfTmrY3uPCErPDsj7vA3iTFvYprKIHPi)gyCQanuskzWQOHtIoij5uuQ4yO4CKuXcfflLszXIy5GEijLAvKu4Xc9Csnrej1ufvtwW0P6IQu9AsQYZuHUUI62OYHvAZiQTRcAAuQQ)IWNrvZJKQAKKuPVtcgTcJNsvojI4wis11iH09qKyLisPNsmkkv6Y08kIsm(R5jvR)aATsNUcPgjVZgVzQyTCyf1ccCm6pGEDk5vSHgC1yTsnXCBsrtDKn1K9vh7FWk2WnKn)5Wk296mcaMaqbkRE8Ojqait4dKa(8dhbZA24yH8OMGBT31jPFDgbataOaLvpE0eiaKj8bsaF(HJGznBCSqEutqgUr)b01CDANRt146CJ(dOS6XJMabGmHpqc4ZpCemRzHyCSqESIQO)aQU51IP5vw3HnVEL70nXGHMPI1YHvulG)aAfvqEDf6YHKcWeiuyHvuL8M3ZwrjWFaTcj0WhxhaRqbuSIn0GRgRvQjM0m3yNoYurIWxPxXFoKuMQxRunVY6oS51Rir4R0R4aEEdY(uhHWzLUUI1YHvSHjZQhwXgAWvJ1k1etAMBSthzQqcn8X1bWkuafROk5nVNTcetMvpSYD6MyWqZuVwhBEL1DyZRxrIWxPxjzMmzwE4sder4SEdiKDwPI4RbPoBeoR3ac1ehyoWZHuNfPBIbdkseambGcu2dmh45qQZghlKh1QptfRLdRO6qKYJq1uFDkJhnHk2qdUASwPMysZCJD6itfsOHpUoawHcOyfvjV59Sv2drkpc1e6XJMqL70nXGHMPETSFZRSUdBE9kse(k9kB0)drcKICpQvmMkQsEZ7zRebungHR)aAfBObxnwRutmPzUXoDKPcj0WhxhaRqbuSI1YHvuBavJr46pGEDAxvKM72PYD6MyWqZuVwkAZRCNUjgm0mvKi8v6vIaGjauGYQhpAceaYe(ajGp)WrWSMnowipQjLiaycafOS6XJMabGmHpqc4ZpCemRzJJfYJAcU1EvuL8M3ZwrpE0eiaKj8bsaF(HJGzDfsOHpUoawHcOyfvHdxAedntfRLdRiJhnHRta5RtFGxN2E(HJGzDfBObxnwRutmPzUXoDKPInCdzZFoSIDVoJaGjauGYQhpAceaYe(ajGp)WrWSMnowipQj4w7DDs6xNraWeakqz1JhnbcazcFGeWNF4iywZghlKh1eKHB0FaDnxN256unUo3O)akRE8Ojqait4dKa(8dhbZAwighlKhRir4R0ZZQeR4phwzDh2861Rv6MxzDh286vKi8v6vQyTCyfs7CGNdPEfBObxnwRutmPzUXoDKPcj0WhxhaRqbuSIQK38E2khyoWZHuVYD6MyWqZuVw3AEL70nXGHMPIeHVsVsatMjtMnXGAngiglhhczHi3(uT6FqfxXJaGjauGYMyqTgdeJLJdHSXXc5rTIXuXA5WkzmOwJHRt1D54qyfvqEDLk2qdUASwPMysZCJD6itfsOHpUoawHcOyfvjV59SvsmOwJbIXYXHWkR7WMxVEToyZRSUdBE9kse(k9kvSwoSIAdOAmcx)b0k2qdUASwPMysZCJD6itfsOHpUoawHcOyfvjV59SvIaQgJW1FaTYD6MyWqZuVwQtZRSUdBE9kse(k9kvSwoSIQdrkpcvt91PmE0eUoTlJDQydn4QXALAIjnZn2PJmviHg(46ayfkGIvuL8M3ZwzpeP8iutOhpAcvUt3edgAM61IzQ5vw3HnVEfjcFLELkwlhwrDxooeEDciFD6d8602ZpCemRRydn4QXALAIjnZn2PJmviHg(46ayfkGIvuL8M3ZwzSCCiKaqMWhib85hocM1vUt3edgAM61Rir4R0RuVf]] )

    storeDefault( [[Protection Defensives]], 'actionLists', 20170523.211251, [[dmZycaGEjfTjvK2LuyBKsZusOztPBtQStKAVIDtX(jQrjjPHrv(TQgksyWeA4uPdkP6usICmv6CskSqPulLuSyK0Yj5PqltfEUetufXuPQMmrMoQlIe9msvxNaBMk2UKeFtk60k9zc6YGrkjv)vrJwHxljQtQI6WiUMKGZlL8yPAAsknojPCUXpinrheKc1ZqN33ilEc4aMYwfOe8eWHiWYPDqnGfifi0hE3MEv4qFJdVARrTvli6c9Ly3As49nHwR2G178(Ms8d9n(bP0qOAbP0oi2vRlhKjMkVgHNkOaZYybRuqAIoiiowWkjl(oYI8aKf1Schm8ckYIv9wPGAalqkqOp8UAVnB4P)gSo11UCRGLXcwP57m5bmvRWbdVGsWZgPTt4xf08giiHzv8dhe7Q1L9B5cblRUE4qFe)GeMvXpCqAIoiy1jgjzX3rwKhGSifQNHo)QGyxTUCqbfywaRZCaeBqnGfifi0hExT3Mn80FdE2iTDc)QGM3abRtDTl3k4GyKMVZKhW0v9m05xfKsdHQfKs7WHwF8dsywf)WbPj6GGvCfoyzX3rwKhGSifQNHo)QGyxTUCqbfywaRZCaeBqnGfifi0hExT3Mn80FdE2iTDc)QGM3abRtDTl3kODfo457m5bmDvpdD(vbP0qOAbP0oC4GyxTUCWWja]] )

    storeDefault( [[Protection Cooldowns]], 'actionLists', 20170523.211251, [[b4vmErLxtruzMfwDSrNxc51uofwBL51uqj3B0v2y0L2BU5hyd92BSr2B352CEnLuLXwzHnxzE5KmWeZnWuJmZ4ImWqto0GJxtnfCLnwAHXwA6fgDP9MBE5Kn241ubngDP9MBZ5fvErNxtn1yYLgC051uErNxEb]] )

    storeDefault( [[Protection Default]], 'actionLists', 20170523.211251, [[d8ItcaGEkuTlqPTrLYSbUjO42QWoLQ9k2TI9lLggv8BsdvPAWkPHJsDqQshJIohfklKQYsPQAXOKLRspKkvpfAzkXZP0eLctvPmzqMoXfrr9mQKUok0MPGTJcMgvIVJICAjFJQ4YiFwk6KGQoSQUgfsNhu5VQOXrH4XO6yMTG9)GcUFvH4sPt7AdYWZiqcISjE9GY4Vu6KUBUf0pbO3sPV4y6XXOlUc7IJlgZfJee53ITemOxUu6yZw6MzliZZZcqqXxW(Fqb3VQqCP0PDTbzGgBXazdI8BXwckAZMacwgT0jezGgBXazd6Na0BP0xCm9y6ee(bQ4VO3GJouqVSkqjWfK)aW5ZLsNtqzLGWOq9)GcUFvH4sPt7AdYan2IbYgj9LSfK55zbiO4ly)pOG7xviUu60U6UQaiLPXge53ITeu0MnbeSCvbqktJnOFcqVLsFXX0JPtq4hOI)IEdo6qb9YQaLaxq(daNpxkDobLvccJc1)dk4(vfIlLoTRURkaszASrs31SfK55zbiO4ly)pOG7xviUu60UIBbr(Tylbd6Na0BP0xCm9y6ee(bQ4VO3GJouqVSkqjWfK)aW5ZLsNtqzLGWOq9)GcUFvH4sPt7kUfjsWgKHNrGeFrsa]] )

    storeDefault( [[SimC Retribution: default]], 'actionLists', 20170523.211251, [[dyuTWaqikiTiLKeBIk1NKQunkLItPKAvkLAxQYWiKJHilJGEMsIPPuY1OGABkjX3iugNuL05uskwNuLsAEsv5EeO9rr5GuuTqQqpKkyIsvIlsf1gLQuQrQKK6KsvSski6Mkv7KKgQuLsSuQipvyQeQ2kf4RkjLwRsss7f1FLkdw0HvzXK4Xu1Kj1LbBwj(mfA0iQttPvlvvVMaMTIUTc7gQFdz4sXXLQuSCIEocthPRRQ2of57sjJxjP68sPwpfeMpvY(LmtIfNdNXNYe0SchQ3a4iSdhQ0jGkTkFQfH7TwPgwU)KYHtWeocGvfkIKyImSWvEK4i8sBdLdom3tTimbloRsIfNdNXNYe0SJCeEPTHYbfz04eEwmfKYFdLGdZvStlTnhsq5laWHdKbVa7itWaWuwHJDK2GtQEdGdouVbWHtGYxaGdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtzvHS4C4m(uMGMDKJWlTnuoOiJgNWRbrTimrLURCtLBQu5VS8uMiKE(jOVFtLUCvPYFz5DMaSrl2yxl5rj)(nv6YvLk)LLNx(jon8(nv6UsL)YYZl)eNgEsyCwmrL9vPqdxPlxvspPrG(O2b0rrDAluzFcw5wIQCDLR5WCf70sBZrdIAryo6bRT(JIKCGryGJDK2GtQEdGdouVbWrVfe1IWCyU0ibh4BacUQGM6UwNCvHdNGjCeaRkuejXijIdhidEb2rMGbGPSch7iT6naoqtDxRtYuwDfwCoCgFktqZoYr4L2gkhBQu5VS8ota2OfBSRL8OKF)MkD5QsL)YYZl)eNgE)MkxZH5k2PL2MJL7pPT78OpMcYbCeFjWrpyT1FuKKdmcdCSJ0gCs1BaCWH6nao6TV)K2UshqFmfKd4i(sGdZLgj4aFdqWL7pPT78OpMcYbCeFjWHtWeocGvfkIKyKeXHdKbVa7itWaWuwHJDKw9gahmLv3IfNdNXNYe0SJCeEPTHYbfz04eEEeAQrTWeCyUIDAPT5qzIq6ULVSnhoqg8cSJmbdatzfo2rAdoP6nao4q9gahooriDL92FzBoCcMWraSQqrKeJKio6bRT(JIKCGryGJDKw9gahmLvnmlohoJpLjOzh5i8sBdLdkYOXj88i0uJAHj4WCf70sBZHcijaPawSroCGm4fyhzcgaMYkCSJ0gCs1BaCWH6naoCeKeGual2ihobt4iawvOisIrseh9G1w)rrsoWimWXosREdGdMYQRclohoJpLjOzh5i8sBdLdYOz7Ugulq(8FPeW0k7RsdxP7k3uPYFz55LFItdVFtLUCvPYFz5DMaSrl2yxl5rj)(nv6YvLu7aQSVkfw5AomxXoT02CCs)HHokskbmLdhidEb2rMGbGPSch7iTbNu9gahCOEdGdZL(ddvkoskbmLdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtzvXyX5Wz8Pmbn7ihHxABOCqTdOY(QuihMRyNwABo6)RnoamLdhidEb2rMGbGPSch7iTbNu9gahCOEdGdd5xBCaykhobt4iawvOisIrseh9G1w)rrsoWimWXosREdGdMYQ9klohoJpLjOzh5i8sBdLdQDav2xLcR0DLBQe6nFBtdOFKwrmrB1Rv6YvLYZdpLjcP7G5sLR5WCf70sBZHY80qhAPR)pb16boCGm4fyhzcgaMYkCSJ0gCs1BaCWH6naoCCEAOs0sLgYpb16boCcMWraSQqrKeJKio6bRT(JIKCGryGJDKw9gahmLvxnS4C4m(uMGMDKJWlTnuoO2buzFvkSs3vUPsO38TnnG(rAfXeTvVwPlxvkpp8uMiKUdMlvUMdZvStlTnhARjlg6iFJbi5WbYGxGDKjyaykRWXosBWjvVbWbhQ3a4OxSMSyOYv9ngGKdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtzvsIyX5Wz8Pmbn7ihHxABOCqgnB31GAbYN)lLaMwzFcwjPkDxj1oGk7RsHCyUIDAPT5O1ja0Hw6ocYabhoqg8cSJmbdatzfo2rAdoP6nao4q9gahR2taOs0sLMtqgi4WjychbWQcfrsmsI4OhS26pksYbgHbo2rA1BaCWuwLejwCoCgFktqZoYr4L2gkhuKrJt45rOPg1ctWH5k2PL2MdYOz7UwYJsMdhidEb2rMGbGPSch7iTbNu9gahCOEdGJvnA2UYvR8OK5WjychbWQcfrsmsI4OhS26pksYbgHbo2rA1BaCWuwLKqwCoCgFktqZoYr4L2gkhuKrJt45rOPg1ctWH5k2PL2MJZeGnAXg7AjpkzoCGm4fyhzcgaMYkCSJ0gCs1BaCWH6naom3eGnAXgRC1kpkzoCcMWraSQqrKeJKio6bRT(JIKCGryGJDKw9gahmLvjTclohoJpLjOzh5yhPn4KQ3a4Gd1BaCeKTWuxjAPsdaSr4WEGdNGjCeaRkuejXijIdZvStlTnheKTWu3Hw6mbyJWH9ah9G1w)rrsoWimWHdKbVa7itWaWuwHJDKw9gahmLvjTflohoJpLjOzh5i8sBdLdkYOXj88i0uJAHjQ0DLBQKmA2URb1cKp)xkbmTsZeSsdxP7kn0kHEZ320a6hPvet0w9ALUCv5Mk3uj0B(2Mgq)iTIyI2QxR0LRkLNhEktes3bZLkxxP7kjJMT7AqTa5Z)LsatR0mbRuyLRRCnhMRyNwABo8YpXPboCGm4fyhzcgaMYkCSJ0gCs1BaCWH6naoCq(jonWHtWeocGvfkIKyKeXrpyT1FuKKdmcdCSJ0Q3a4GPSkjdZIZHZ4tzcA2rocV02q548uRjOdWWWcev2NGvUsLURCtLEeAQrTWV()AJdatFsyCwmrL9vPrVUYTRCRNHR0LRk1GYFz51)xBCay6tcJZIjQ0Skn61vUDLB9mCLRR0DLBQ0qRKEtatFE5N40WdWNYe0v6YvLEeAQrTWpV8tCA4jHXzXevAwLg96k3UsHvUMdZvStlTnhWQd(p1IWDeaMcypWHdKbVa7itWaWuwHJDK2GtQEdGdouVbWHZRo4)ulcxzaykG9ahobt4iawvOisIrseh9G1w)rrsoWimWXosREdGdMYQKwfwCoCgFktqZoYr4L2gkhAq5VS86)Rnoam99BQ0DLNNAnbDaggwGOsZeSsHv6UsL)YYtBnzXqxZx2GiG3VPs3vQ8xwEARjlg6A(Ygeb8KW4SyIk7RsJEDLBxPqomxXoT02COTMSyOJGIKdoCGm4fyhzcgaMYkCSJ0gCs1BaCWH6nao6fRjlgQmOi5GdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtzvsIXIZHZ4tzcA2rocV02q5qdk)LLx)FTXbGPVFtLUR88uRjOdWWWcevAMGvkSs3vsgnB31GAbYN)lLaMwPzcwPHR0DLk)LLN2AYIHUMVSbraVFdhMRyNwABo0wtwm0rqrYbhoqg8cSJmbdatzfo2rAdoP6nao4q9gah9I1KfdvguKCu5gsR5WjychbWQcfrsmsI4OhS26pksYbgHbo2rA1BaCWuwLuVYIZHZ4tzcA2rocV02q5qdk)LLx)FTXbGPVFtLUR88uRjOdWWWcevAMGvkSs3vsgnB31GAbYN)lLaMwPzcw5kv6UYnvQ8xwEE5N40W73uP7k3uPYFz55LFItdpc65fOY(QKKHR0LRkv(llpLjcPNFc673u56kD5QsL)YYBApT0Ij6w(Y2DF8eocYG(9BQCnhMRyNwABo0wtwm0rqrYbhoqg8cSJmbdatzfo2rAdoP6nao4q9gah9I1KfdvguKCu5gHR5WjychbWQcfrsmsI4OhS26pksYbgHbo2rA1BaCWuwL0QHfNdNXNYe0SJCeEPTHYHgu(llV()AJdatF)MkDx55PwtqhGHHfiQ0mbRuyLURKmA2URb1cKp)xkbmTsZeSsdxP7k3uPHwj9MaM(8YpXPHhGpLjOR0LRk9i0uJAHFE5N40WtcJZIjQ0Skn61vUDLRu5AomxXoT02COTMSyOJGIKdoCGm4fyhzcgaMYkCSJ0gCs1BaCWH6nao6fRjlgQmOi5OYnRSMdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtzvHIyX5Wz8Pmbn7ihHxABOCObL)YYR)V24aW03VPs3vQ8xwEARjlg6A(Ygeb8(nv6UsL)YYtBnzXqxZx2GiGNegNftuzFvA0RRC7kfYH5k2PL2MdkmAMNKOZei1wpLdhidEb2rMGbGPSch7iTbNu9gahCOEdGdXHrZ8K9orLgasT1t5WjychbWQcfrsmsI4OhS26pksYbgHbo2rA1BaCWuwvijwCoCgFktqZoYr4L2gkhAq5VS86)Rnoam99BQ0DLKrZ2DnOwG85)sjGPvAMGvA4kDxPYFz5PTMSyOR5lBqeW73WH5k2PL2MdkmAMNKOZei1wpLdhidEb2rMGbGPSch7iTbNu9gahCOEdGdXHrZ8K9orLgasT1tRCdP1C4emHJayvHIijgjrC0dwB9hfj5aJWah7iT6naoykRkuilohoJpLjOzh5i8sBdLdnO8xwE9)1ghaM((nv6UsYOz7Ugulq(8FPeW0kntWkxPs3vUPsL)YYZl)eNgE)MkDx5Mkv(llpV8tCA4rqpVav2xLKmCLUCvPYFz5Pmri98tqF)MkxxPlxvQ8xwEt7PLwmr3Yx2U7JNWrqg0VFtLR5WCf70sBZbfgnZts0zcKARNYHdKbVa7itWaWuwHJDK2GtQEdGdouVbWH4WOzEYENOsdaP26PvUr4AoCcMWraSQqrKeJKio6bRT(JIKCGryGJDKw9gahmLvfUclohoJpLjOzh5i8sBdLdnO8xwE9)1ghaM((nv6UsYOz7Ugulq(8FPeW0kntWknCLURCtLgAL0Bcy6Zl)eNgEa(uMGUsxUQ0JqtnQf(5LFItdpjmolMOsZQ0Oxx52vUsLRR0DLBQ0qRKEtatFWQd(p1IWDeaMcyp8a8PmbDLUCvPhHMAul8dwDW)PweUJaWua7HNegNftuPzvA0RRCnhMRyNwABoOWOzEsIotGuB9uoCGm4fyhzcgaMYkCSJ0gCs1BaCWH6naoehgnZt27evAai1wpTYnRSMdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtzvHBXIZHZ4tzcA2rocV02q5qdk)LLx)FTXbGPVFtLURKmA2URb1cKp)xkbmTsZeSYvQ0DLNNAnbDaggwGOsZeSsHv6UYnv6rOPg1c)ADcaDOLUJGmq8KW4SyIk7RsJEDLBxPWkDx5jP2LZtFTobGo0s3rqgiEa(uMGUsxUQu5VS8Ar2s0aYo0shLm0HpkzjyiSJ3VPs3vQ8xwETiBjAazhAPJsg6WhLSeme2XtcJZIjQSVkn61vUUs3vUPsdTs6nbm95LFItdpaFktqxPlxv6rOPg1c)8YpXPHNegNftuPzvA0RRC7k3QY1CyUIDAPT5qBnzXqhbfjhC4azWlWoYemamLv4yhPn4KQ3a4Gd1BaC0lwtwmuzqrYrLB2Anhobt4iawvOisIrseh9G1w)rrsoWimWXosREdGdMYQcnmlohoJpLjOzh5i8sBdLdnO8xwE9)1ghaM((nv6UsYOz7Ugulq(8FPeW0kntWkxPs3vUPspcn1Ow4xRtaOdT0DeKbINegNftuzFvA0RRC7kfwP7kpj1UCE6R1ja0Hw6ocYaXdWNYe0v6YvLk)LLxlYwIgq2Hw6OKHo8rjlbdHD8(nv6UsL)YYRfzlrdi7qlDuYqh(OKLGHWoEsyCwmrL9vPrVUY1v6UYnvAOvsVjGPpV8tCA4b4tzc6kD5Qspcn1Ow4Nx(jon8KW4SyIknRsJEDLBx5wvUMdZvStlTnhuy0mpjrNjqQTEkhoqg8cSJmbdatzfo2rAdoP6nao4q9gahIdJM5j7DIknaKARNw5MTwZHtWeocGvfkIKyKeXrpyT1FuKKdmcdCSJ0Q3a4GPSQWvHfNdNXNYe0SJCeEPTHYHgrFWQd(p1IWDeaMcyp8OwVawSXkDxPgrFWQd(p1IWDeaMcyp8KW4SyIk7RsJEDLBxPWkDxPgu(llV()AJdatFsyCwmrL9vPrVUYTRuihMRyNwABo6)RnoamLdhidEb2rMGbGPSch7iTbNu9gahCOEdGdd5xBCayALBiTMdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtzvHIXIZHZ4tzcA2rocV02q5ytLKrZ2DnOwG85)sjGPvkyLIQ0LRkjJMT7AqTa5Z)LsatRuWkjvP7k3uPhHMAul8tzEAOdT01)NGA9WtcJZIjQ0Skn61v6YvLEeAQrTWpT1KfdDKVXaKpjmolMOsZQ0Oxx56kD5QsYOz7Ugulq(8FPeW0kfSsHv6UYnv6rOPg1c)meWnFEYN0iq0Tipp1IW3SY(eSsrVvXWv6YvLEeAQrTWpV8tCAq2rqLwbGNN8jnceDlYZtTi8nRSpbRu0BvmCLRRCnhMRyNwABoADcaDOLUJGmqWHdKbVa7itWaWuwHJDK2GtQEdGdouVbWXQ9eaQeTuP5eKbIk3qAnhobt4iawvOisIrseh9G1w)rrsoWimWXosREdGdMYQc7vwCoCgFktqZoYr4L2gkhBQKmA2URb1cKp)xkbmTY(eSsHv6UscG2PGWFIh1csHI6e24RuWkjvPlxvsgnB31GAbYN)lLaMwzFcw5kv6UscG2PGWFIh1csHI6e24RuWkfv5AomxXoT02COmpn0Hw66)tqTEGdhidEb2rMGbGPSch7iTbNu9gahCOEdGdhNNgQeTuPH8tqTEOYnKwZHtWeocGvfkIKyKeXrpyT1FuKKdmcdCSJ0Q3a4GPSQWvdlohoJpLjOzh5i8sBdLJnvsgnB31GAbYN)lLaMwzFcwPWkDxjbq7uq4pXJAbPqrDcB8vkyLKQ0LRkjJMT7AqTa5Z)LsatRSpbRCLkDxjbq7uq4pXJAbPqrDcB8vkyLIQCnhMRyNwABo0wtwm0r(gdqYHdKbVa7itWaWuwHJDK2GtQEdGdouVbWrVynzXqLR6BmazLBiTMdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtz1veXIZHZ4tzcA2rocV02q5a6nFBtdOFKwrmrRIHR0DL0tAeOpYWnPKFnEALMjyLIz4kDxjz0SDxdQfiF(VucyAL9jyLBXH5k2PL2MdY3yaYo0sx)FcQ1dC4azWlWoYemamLv4yhPn4KQ3a4Gd1BaCSQVXaKvIwQ0q(jOwpWHtWeocGvfkIKyKeXrpyT1FuKKdmcdCSJ0Q3a4GPS6kKyX5Wz8Pmbn7ih7iTbNu9gahCOEdGdd5xBCayALBeUMdNGjCeaRkuejXijIdZvStlTnh9)1ghaMYrpyT1FuKKdmcdC4azWlWoYemamLv4yhPvVbWbtz1veYIZHZ4tzcA2rocV02q5Wt(KgbIkfSsHv6UYnvsa0ofe(t8OwqkuuNWgFLcwPOkDxjz0SDxdQfiF(VucyAL9jyLcR0LRk3ujz0SDxdQfiF(VucyAL9jyLBvP7k3uPhHMAul8tBnzXqh5Bma5tcJZIjQ0Skn61vUDLcR0LRk9i0uJAHFkZtdDOLU()euRhEsyCwmrLMvPrVUYTRuyLRR0DLEeAQrTWV()AJdatFsyCwmrLMvPrVUYTRuyLRRCDLUCv5MkjaANcc)jEulifkQtyJVsbRKuLURKmA2URb1cKp)xkbmTY(eSssv6YvLBQKmA2URb1cKp)xkbmTY(eSYTQ0DLBQ0JqtnQf(PTMSyOJ8ngG8jHXzXevAwLg96k3UsHv6YvLEeAQrTWpL5PHo0sx)FcQ1dpjmolMOsZQ0Oxx52vkSY1v6Uspcn1Ow4x)FTXbGPpjmolMOsZQ0Oxx52vkSY1vUMdZvStlTnhgc4MC4azWlWoYemamLv4yhPn4KQ3a4Gd1BaCSQc3KdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtz1vwHfNdNXNYe0SJCeEPTHYHN8jncevkyLcR0DLBQKaODki8N4rTGuOOoHn(kfSsrv6UsYOz7Ugulq(8FPeW0k7tWkfwPlxvUPsYOz7Ugulq(8FPeW0k7tWk3Qs3vUPspcn1Ow4N2AYIHoY3yaYNegNftuPzvA0RRC7kfwPlxv6rOPg1c)uMNg6qlD9)jOwp8KW4SyIknRsJEDLBxPWkxxP7k9i0uJAHF9)1ghaM(KW4SyIknRsJEDLBxPWkxx56kD5QYnvsa0ofe(t8OwqkuuNWgFLcwjPkDxjz0SDxdQfiF(VucyAL9jyLKQ0LRk3ujz0SDxdQfiF(VucyAL9jyLBvP7k3uPhHMAul8tBnzXqh5Bma5tcJZIjQ0Skn61vUDLcR0LRk9i0uJAHFkZtdDOLU()euRhEsyCwmrLMvPrVUYTRuyLRR0DLEeAQrTWV()AJdatFsyCwmrLMvPrVUYTRuyLRRCnhMRyNwABo8YpXPbzhbvAfa4WbYGxGDKjyaykRWXosBWjvVbWbhQ3a4Wb5N40GSYGkTcaC4emHJayvHIijgjrC0dwB9hfj5aJWah7iT6naoykRUYwS4C4m(uMGMDKJDK2GtQEdGdouVbWHdimb4Lh1IWC4emHJayvHIijgjrCyUIDAPT5WJWeGxEulcZrpyT1FuKKdmcdC4azWlWoYemamLv4yhPvVbWbtz1vmmlohoJpLjOzh5i8sBdLdnO8xwE9)1ghaM((nv6UYZtTMGoaddlquPzcwPWkDxPYFz5PTMSyOR5lBqeW73WH5k2PL2MdT1KfdDeuKCWHdKbVa7itWaWuwHJDK2GtQEdGdouVbWrVynzXqLbfjhvUXWR5WjychbWQcfrsmsI4OhS26pksYbgHbo2rA1BaCWuwDLvHfNdNXNYe0SJCeEPTHYHgu(llV()AJdatF)MkDx55PwtqhGHHfiQ0mbRuyLURu5VS8OKHUfRei6qlD9)jOwp8(nv6UYnvAOvsVjGPpV8tCA4b4tzc6kD5Qspcn1Ow4Nx(jon8KW4SyIknRsJEDLBx5kvUMdZvStlTnhARjlg6iOi5GdhidEb2rMGbGPSch7iTbNu9gahCOEdGJEXAYIHkdksoQCZQSMdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtz1veJfNdNXNYe0SJCeEPTHYHgu(llV()AJdatF)MkDx55PwtqhGHHfiQ0mbRuyLURKmA2URb1cKp)xkbmTsZeSYTQ0DLBQ0qRKEtatFE5N40WdWNYe0v6YvLEeAQrTWpV8tCA4jHXzXevAwLg96k3UYTQCnhMRyNwABo0wtwm0rqrYbhoqg8cSJmbdatzfo2rAdoP6nao4q9gah9I1KfdvguKCu5gXwZHtWeocGvfkIKyKeXrpyT1FuKKdmcdCSJ0Q3a4GPS6k9klohoJpLjOzh5i8sBdLdnO8xwE9)1ghaM((nv6UsL)YYtBnzXqxZx2GiG3VHdZvStlTnhuy0mpjrNjqQTEkhoqg8cSJmbdatzfo2rAdoP6nao4q9gahIdJM5j7DIknaKARNw5gdVMdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtz1vwnS4C4m(uMGMDKJWlTnuo0GYFz51)xBCay673uP7kv(llpkzOBXkbIo0sx)FcQ1dVFtLURCtLgAL0Bcy6Zl)eNgEa(uMGUsxUQ0JqtnQf(5LFItdpjmolMOsZQ0Oxx52vUsLR5WCf70sBZbfgnZts0zcKARNYHdKbVa7itWaWuwHJDK2GtQEdGdouVbWH4WOzEYENOsdaP26PvUzvwZHtWeocGvfkIKyKeXrpyT1FuKKdmcdCSJ0Q3a4GPS6wIyX5Wz8Pmbn7ihHxABOCObL)YYR)V24aW03VPs3vsgnB31GAbYN)lLaMwPzcw5wv6UYnvAOvsVjGPpV8tCA4b4tzc6kD5Qspcn1Ow4Nx(jon8KW4SyIknRsJEDLBx5wvUUs3vUPsdTs6nbm9bRo4)ulc3raykG9WdWNYe0v6YvLEeAQrTWpy1b)NAr4ocatbShEsyCwmrLMvPrVUYTRuyLR5WCf70sBZbfgnZts0zcKARNYHdKbVa7itWaWuwHJDK2GtQEdGdouVbWH4WOzEYENOsdaP26PvUrS1C4emHJayvHIijgjrC0dwB9hfj5aJWah7iT6naoykRUfjwCoCgFktqZoYr4L2gkhKrZ2DnOwG85)sjGPv2NGvUfhMRyNwABomeWn5WbYGxGDKjyaykRWXosBWjvVbWbhQ3a4yvfUzLBiTMdNGjCeaRkuejXijIJEWAR)Oijhyeg4yhPvVbWbtz1TeYIZHZ4tzcA2rocV02q5GmA2URb1cKp)xkbmTY(eSYT4WCf70sBZHx(joni7iOsRaahoqg8cSJmbdatzfo2rAdoP6nao4q9gahoi)eNgKvguPvaOYnKwZHtWeocGvfkIKyKeXrpyT1FuKKdmcdCSJ0Q3a4GPS6wRWIZHZ4tzcA2rocV02q5qdk)LLx)FTXbGPVFtLURKmA2URb1cKp)xkbmTsZeSYvQ0DLNNAnbDaggwGOsZeSsHv6UYnvAOvsVjGPpV8tCA4b4tzc6kD5Qspcn1Ow4Nx(jon8KW4SyIknRsJEDLBxPHRCnhMRyNwABo0wtwm0rqrYbhoqg8cSJmbdatzfo2rAdoP6nao4q9gah9I1KfdvguKCu5MEDnhobt4iawvOisIrseh9G1w)rrsoWimWXosREdGdMYQBTflohoJpLjOzh5i8sBdLdnO8xwE9)1ghaM((nv6UsYOz7Ugulq(8FPeW0kntWkxPs3vUPsdTs6nbm95LFItdpaFktqxPlxv6rOPg1c)8YpXPHNegNftuPzvA0RRC7knCLR5WCf70sBZbfgnZts0zcKARNYHdKbVa7itWaWuwHJDK2GtQEdGdouVbWH4WOzEYENOsdaP26PvUPxxZHtWeocGvfkIKyKeXrpyT1FuKKdmcdCSJ0Q3a4GPmLJOb82BAneh1IWSQyIykZ]] )

    storeDefault( [[SimC Retribution: precombat]], 'actionLists', 20170523.211251, [[b4vmErLxtvKBHjgBLrMxI51uofwBL51utLwBd5hysvgDYLMy1rxAV5Mo(bgCYv2yV1MyHrNxtjvzSvwyZvMxojdmXCdm1iZmUeJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5cCVrxAV52CEnvqILgBPrxEEnfCVrxAV5MxtLKBKL2yHr3BY51uU9MBL51un9gzwfMCofwBL51uEnLtH1wzEnfuVrxAV5MxtfKCNnNxt5wyTvwpI8gBK91DHjNiEnLuLXwzHnxzE5KmWeZnXaJxtneALn2An9MDL1wzUrNxI51un9gzofwBL51uVXgzFDxyY5fDErNxtnfCLnwAHXwA6fgDP9MBE50nW4fDE5f]] )


    storeDefault( [[Retribution Primary]], 'displays', 20170523.211251, [[d4ZpiaGEvLEPQc7sQq9ALQ6WsMjLIFdz2kzzuQUjIsNNuDBs60qTtk2Ry3e2VQ4NiYWOsJdrrUSkdfvnyvPHJuhuQ6OKsuhtkohPeSqP0sLkTyuz5e9qs0tbpgLwNubtuPknvKmzu00vCrvvxLuQEMsvCDe2OsLTskr2mvSDsXhLk6ZOW0uv03vkJKusFJukJMsgpIQtsc3sQqUgIc3Juc9CQATikQJtP0Pjubyl6bJe7qIbg91fGK2PSrH5pWusg3WRHpCbKLGXP06y3pTb4w4VF7CH2cxaDsoo(Buw0dgj8X4gGCsoo(Buw0dgj8X4gWwIJ4yQGfja83lMpDd4TqB9eYsHWbfUa2sCehtLf9GrcFAdOtYXXFdvjzCJpg3aAzIJ48HkMMqf4xuCRJzAd0ZoyK451gSFIXEatPEbaSQYN3U3iXCedgj6WZlT8yrQC1eO7TUYFXy3TrBUnUUbawjMEcmy1tl6Mjg7HkWVO4whZ0gONDWiXZRny)ettatPEbaSQYN3U3iXCedgj6WZlZZPiwtGU36k)fJD3gT5246MjtaVfAd2WdRv)FAd4TqB9edkTb8wOnydpSw9edkTbMsY4MEbRfsgOLeffjY2vrNALkGEmDK9pDdqEmUb8wOnQsY4gFAdSpxVG1cjdqrIVRIo1kvawKkxn8A(dxa2IEWirVG1cjd0sIIIezdOerR)8sHcWlrZXoyK45LxIvlPEaVfAdOsBaBjoIBVy5XoyKiqxfDQvQaccvfSiHpMpd4PV1A3Q8wkrlKmubQyAcWfttagX0eqgttMaEl0MYIEWiHpTbiNKJJ)MEczfJBGIqwu60xaochNa1I2Q6xBLUNxZFmnbulY7jgumUbiNKJJ)gfcMy2AqsFmUbQfTvbwOnEn)X0eOw0wLsKkxn8A(JPjWEpNIynPnatSNEv6u60xGkqT2kDpVg(0gqd2J5Wl8OtPtFb4cWw0dgj6xygIak)nu)DdylbMDFTe2dJ(6cuba6Jfxl83AWirmAZnGSemokD6lqXHx4rpqrilYIfxAdWTWF)25cT1VwHlW(C7qIbWFVyAShWtFR1Uv5TcxaEjwTK6pVkl6bJepV9eYkqGIqw9cwlKmqljkksK1M)DubK3kGYFd1F3atjzCZoKycWt98cLW)8AkPeTfOw0wfvjzCdVM)yAc8XPZHfmXcgpVWOVUyShWwIJ4yQqWeZwds6tBaMNtrSMEEBcayvLpVDVrI5igms0HNxMNtrSMaoiXeOxIR1ZRPKs0wGPKmUzhsmWOVUaK0oLnkm)biBrowLq95LcREXSh3aQyr)Fm7jaWkX0tGa1I2Q6xBLUNxdFmnbSL4iU(fMHq9eta2a0sSAj13HedG)EX0ypaT8yrQC10ZBtaaRQ85T7nsmhXGrIo88slpwKkxnbiNKJJ)MpA9X0eqTiV)pg3au16eZZBNsebDmnbMsY4gEn)HlG3cT9XPZHfmXcg(0gGxIvlP(ZRYIEWirGPKmUXhqNKJJ)MEczfJBavSONyqX4gGTOhmsSdjga)9IPXEGIqwa9Twk2BmUbQfTvbwOnEn8X0eWBH2uiyIzRbj9PnG3cTXRHpTbQ1wP7518N2aEl0gVM)0gWBH26)tBawKkxn8A4dxG952HetaEQNxOe(NxtjLOTa7ZTdjgy0xxasANYgfM)a6KCC838rRpMoQjGkwauX4gykjJB2HedG)EX0ypqTOTkQsY4gEn8X0eGTOhmsSdjMa8upVqj8pVMskrBbQfTvPePYvdVg(yAc8lkU1XmTb8yv611t6pg7bWcMy2AqYEbRfsgORIo1kvGU36k)fJD3gT5sg23thB39tTWNKPa0sSAj1vWIea(7fZNUbkczPq4GO0PVaCeoobulYbQyAcqojhh)nuLKXn(yCdGzrcGUyXcgXqgbwOTtYw(7JwF4cGzrcYmcPgtdzeWwIJ4yUdjga)9IPXEaDsoo(BuiyIzRbj9X4gWwIJ4y(rRpTbmL6fO7nsmhXGrINxEjwTK6bkczPDbEcqVk9tMjba]] )

    storeDefault( [[Retribution AOE]], 'displays', 20170523.211251, [[daeoiaqiuQQ2Ksu6wkrXUqjyyQQogPSmuvpdLutdLORPQW3iPOXHsv6CKuyDKu6EOeYbPQwOQ0djHjQevxujTrLWhvImssQCss0lrjzMub3eLk7KIFcKHsPokkvLLsf9uOPIIRssvBfLqTwuQI9kgSs1HLAXi5XOYKrvUSkBMk9zGA0KQtJ41QkA2s62uYUj8BqdhPoovOLt0ZLy6kUoGTts(UQy8Ouopvz9QkTFLYrlmb5A6HaflGIbhV6feK6zCqPzn40sW3yRYoubLTa8Pq)4(mVbDe4ao)kbSW6etqUGEGCDl3OOPhcuuI5piBGCDl3OOPhcuuI5piTKy1spLCqbs(EXWY)GweH)AmSoOJahWXtrtpeOOK3GEGCDl3W0sW3uI5pi7d4aUsyIrlmbxfnv94L3G(Cdbk22DGuMy4h00wxqKyPyB35nscfWqGc1UTtlpoOfvpbDE1Rlxm8)1(qtJf4ZxliYjj0tWHyDSO)mXWpmbxfnv94L3G(Cdbk22DGuMy0cAARlisSuST78gjHcyiqHA325DUnqDc68QxxUy4)R9HMglWNVwMmbl6Wh8HmC6(RHkiBGCDl3W0sW3uI5pyrh(GpKHt3hyG5n40sW34l40HYGVGyyaXoNkxsDmb9Izz0uJpcYwm)bl6WhMwc(MsEd(jLVGthkdYaY2PYLuhtqoOfvp2QwdvqUMEiqHVGthkd(cIHbe7cQas7TTZad68gjHcyiqX2UpO1GfD4dYK3GocCa3YjYJBiqrqNkxsDmbfawk5GIsmSmyH(Q1f1UORawHYWeSJrlOmgTGGJrlivmAzcw0HpkA6HafL8gKnqUULB8bKDm)bBazZ4rFbPaCDdA1S5dmWy(d2vA92V(0EfBvRXOfSR06nQdFSvTgJwWUsR3kGwu9yRAngTGM26c68gjHcyiqX2UpO1G8if6A7X4rFb5c21N2RyRYoVbvrkeksLmEmE0xqQGCn9qGc)kbSiOIvdZQZGocq4(Kftk44vVGubTicFGbgdRdkBb4JXJ(c2uKkz8c2aYMDeXL3Gi9Xr6k5BpeOig18p4NulGIbjFVy04h0dKRB5gLcEeUEGYsm)bTLeRw6TTROPhcuST7di7GbNwc(MfqXe0MzBhBrzB30sj8jO8QbvSAywDgSqF16IAx0dvWUsR3mTe8n2QwJrlydiBFbNoug8feddi25W6cMGocCahpLcEeUEGYsEdsvjF)Uuf(4xRHkyrh(4diBLcxyOcoTe8nlGIbhV6feK6zCqPzni7A2iwawB7meRlgw)hK352a1X32HGiXsX2UZBKekGHafQDBN352a1jiYjj0tWcraUEll7VbgyWUsR3(1N2RyRYogTGuvY3VlvHpHkiTKy1sVfqXGKVxmA8dslpoOfvp(2oeejwk22DEJKqbmeOqTB70YJdAr1tWIo8XhyGHkOvZM)Am)bz66jMT9LKqa6y(doTe8n2QwdvWIo8HvNhfrWJiaxYBqNx96Yfd)Fn18)d(SMf4)Zs1GLS3GSbY1TCdRElXOf0dKRB5gFazhZFqUMEiqXcOyqY3lgn(bDe4aoEk5GcK89IHL)bBazJ0xTQC5X8hSOdFuk4r46bkl5nyxP1Buh(yRYogTGD9P9k2QwZBWIo8XwLDEdw0Hp(RHkih0IQhBv2Hk4NulGIjOnZ2o2IY2UPLs4tqpqUULBy1BjMLrl4NulGIbhV6feK6zCqPznOfrGmXW6GtlbFZcOyqY3lgn(bl6WhBvR5nixtpeOybumbTz22Xwu22nTucFc2vA9wb0IQhBv2XOfCv0u1JxEdwiw01Zh0Am8dse8iC9aL(coDOmOtLlPoMGDLwVzAj4BSvzhJwqBjXQLEB7kA6HafbNwc(MsqRMnKjM)GnGSvkCHmE0xqkax3GeoOaPBoIaCmFe0fkMG(ssx32nTucFcYQZJIi4reG32XXREXWpiHdkypqOvmAFe0rGd44TakgK89IrJFq2a56wUrPGhHRhOSeZFqhboGJhREl5n4Yp3gOo5nydiB1litq6A7DYmj]] )

    storeDefault( [[Protection Primary]], 'displays', 20170523.211251, [[d0tBiaGEiYlHOSlrbBdjXmrP6WsMTc)wv3ejPLjL8nbs8AfvTts2l1Ur1(Hu)ejgMinobconIHIIbdjdhPoOu5Oce6yc6CcK0cLILIszXc1Yj6HsPEk4Xq55KAIqunvOAYeY0v6Iq4QIcDzvUobBurzRce1MfvBNq9rrP(mkzAkQ8DPQrkq5zIsgTigpsQtkGBjqQRjq15fYTvK1kqKJlkAhACdyf9sE(SNVWgnoduYio7buimSLK1TmIzCSbzXzDTtoS5DJH4bbjKYE89o2qeL8C9TTl6L8CTvPgOMsEU(22f9sEU2QudzkCcNOayphiiDwnxQbDY33jiRa883XgYu4eorTl6L8CTBmerjpxFlEjzDR2QudbrHt40g3QqJBabVIhNi3yOdBjphnk2j61Q5mOQPZaJ83dBjphnkKF5hxteFAdSDJR0NvTsdPsyAAwzi0aGjj0RbVw1Y4gqWR4XjYng6WwYZrJIDIETk4gu10zGr(7HTKNJgv7)hI(EU2aB34k9zvR0qQeMMMvgcnaysc9AWRvzzCdi4v84e5gdDyl55OrXorVwLLbvnDgyK)Eyl55Orb4gy7gxPpRALgsLW00SYqObatsOxdE9AqN89qpzXs6q4gd6KVVtyF3yqN89qpzXs6e23ng2sY62oowYln0qbhNcvzlq2bd3qKvbDR5snqTvPg0jFpEjzDR2ngMpUJJL8sd4uyylq2bd3a2pfxlJyeo2awrVKN3XXsEPHgk44uOQH2pDeAu4Vbg5Vh2sEoAumsYujJmOt(Ea3ngYu4eoKtKh2sEUb2cKDWWnWfMcG9CTvZzqtFJXSrPtA)JxACdLvHgITk0alRcniTk0RbDY33UOxYZ1UXa1uYZ132jilRsnucYcpI(melKNBOg0jv3OVI0mIryvOHPI6oH9Tk1a1uYZ13gGlIGv7l1wLAOg0jfK89mIryvOHAqNuT)P4AzeJWQqdi)YlHX6gdIiA6rfHhrFgkd1OVI0mIzCJbXenjMmiBeEe9zi2awrVKN3niS4gAJqHJGndzkqWMpit0WgnodLbG(Wi1GGuTKNBfvOIbzXzD4r0NHkMmiBKHsqwuLWp3yiEqqcPShFF3y4ydZhp75lqq6SkSLbn9ngZgLoXXgyKKPsgHgv7IEjphnQobzzWqjiRoowYln0qbhNcvzhXmCdYByOncfoc2mSLK1TZE(AGbhnkO4A0OuLu(9gQbDsHxsw3YigHvHgq2fft4IiCwOrbB04SQLHmfoHtuaUicwTVu7gdIU8sySDmSBGr(7HTKNJgfYV8sySgYF(AOtsQbAuQsk)EdBjzD7SNVWgnoduYio7buimq1IAYKWeAu4KPZQSsnmr4DiSkldaMKqVgmud6KQB0xrAgXmwfAitHt46gew8PJVgWmqljtLmA2ZxGG0zvyld0Yd7NIRTJHDRsnqnL8C9TiRrBvOHPI6oewLAaVghFrJkB5lqBvQHTKSULrmchBGTBCL(SQvAyqjn4TYkdTsNlOoxqWaJKmvYi0OAx0l55g2sY6wTHik556B7eKLvPgQbDsHxsw3YiMXQqdteENW(wLAOeKfqFJraKBvQHAqNuqY3ZiMXQqd6KVpaxebR2xQDJbDY3ZiMXngQrFfPzeJWng0jFpJyeUXGo577q4gdy)uCTmIzCSH5JN981adoAuqX1OrPkP87nmF8SNVWgnoduYio7buimerjpxFlYA0wf0HgMiCa3QudBjzD7SNVabPZQWwgWk6L88zpFbcsNvHTmGv0l55ZE(AGbhnkO4A0OuLu(9gQbDs1(NIRLrmJvHgqWR4XjYng0Kj6X1rbHvTmq4Iiy1(YoowYlnWwGSdgUbDY3JSlkMWfr4S0UXaTKmvYOayphiiDwnxQHsqwb45pEe9ziwip3WurnGBvObQPKNRVfVKSUvBvQbc2Zb6cJWzzvWnm((tIv6dznAhBGG98G0)twfgCdzkCcNOzpFbcsNvHTmerjpxFBaUicwTVuBvQHmfoHteYA0UXGQModmYFpSL8C0OyKKPsgzOeKvg5K1a9OIoPxB]] )


end
