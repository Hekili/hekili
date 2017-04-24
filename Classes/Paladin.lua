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
        addResource( 'holy_power' )

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
        addAura( 'whisper_of_the_nathrezim', 207633 )
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
        addGearSet( 'class', 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )
        addGearSet( 'ashbringer', 120978 )
        addGearSet( 'truthguard', 128866 )
        addGearSet( 'whisper_of_the_nathrezim', 137020 )


        setArtifact( 'ashbringer' )
        setArtifact( 'truthguard' )


        addHook( 'specializationChanged', function ()
            setPotion( 'old_war' )
            setRole( 'attack' )
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


    storeDefault( [[SimC Retribution: default]], 'actionLists', 20170423.220102, [[dyKePaqiifTiiLiBIK6tIO0OePoLizvkvSliggqoMszza1ZerMMsLUgjkBtev(gGACKOY5ervTorueZteCpazFeWbjqlKe6HKGjcPuxKczJqkrnsiLWjPqTsiL0nPe7KIgQikslLe5PunvivBLev9vruL1kIIAVO(lsnyLuhgQftOhtQjt0LL2mb9ziz0aCAeRwe61kvnBb3wODR43QA4uQJlIclh0Zf10v56iz7kX3PGXdPqNNsA9qky(KK9RKmVXOZoAxHyQWXkYUjow2DsuHvRvQhKisDKFsMSATScXuHJDLAO4CztWG2ag0UGaJSbwzadkj2DnKyFSZUG6J8tMrNn3y0z3OblgQKvKDtCSSRufP2x2DnKyFSFpkuHIqMRqiL9Lz34rs047HSp)u2fuKeiNv2HvKAFzxbavV3YV0yNJfzxPgkox2emOnG3aXULxAIJLD(ytWm6SB0GfdvYkYURHe7J97rHkue7)i)KvNoTiLqHiIH)LbQ8HqzRsLiLqHi4LoOidkAdq8baHYwLkrkHcr0qQmwwekB1IucfIOHuzSSiWgXKjNayLPs1HHO6HCKyPVNwsAcaTlOuPyxqrsGCwz3(pYpSB8ijA89q2NFk7M4yzpz6FKFyxqiQm7dowGql9bjTbmeTe7k1qX5YMGbTb8gi2vaq17T8ln25yr2T8stCSS)bjTbmKp2mjgD2nAWIHkzfz3ehl7kg(xUAnAzkOv2DnKyFSFpkuHIO)piFdtMDJhjrJVhY(8tzxqrsGCwzxm8VKwif0k7kaO69w(Lg7CSi7k1qX5YMGbTb8gi2T8stCSSZhBUlJo7gnyXqLSISBIJLDflmx4EYGIDxdj2h73JcvOi6)dY3WKz34rs047HSp)u2fuKeiNv2flmx4EYGIDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25JnvgJo7gnyXqLSISBIJLDbHA80vRr)HWoh7UgsSp2VhfQqr0)hKVHjRonGpyL2(nuiIMcc7CjOm1PfPekerdPYyzrOSvPsKsOqe8shuKbfTbi(aGqzRs1rInbWPsXUXJKOX3dzF(PSlOijqoRSJHA8u67HWoh7kaO69w(Lg7CSi7k1qX5YMGbTb8gi2T8stCSSZhBMCm6SB0GfdvYkYUjow2rRusuXoh7UgsSp2psSjaMDJhjrJVhY(8tzxqrsGCwzprkjQyNJDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25JnbMrNDJgSyOswr2nXXYUIbSSRw)cxTgTsLpIUS7AiX(y)iXMay1PBYGIyBxjYwsadAxLtLkiwxeXW)s6geMIDJhjrJVhY(8tzxqrsGCwzxmGLL(fsNiv(i6YUcaQEVLFPXohlYUsnuCUSjyqBaVbIDlV0ehl78XMkhJo7gnyXqLSISBIJLD0MSqMUAnAboglKDxdj2h7hj2eaRoDtgueB7kr2scyq7QCQubX6Iig(xs3GWuSB8ijA89q2NFk7ckscKZk7sYczknaCmwi7kaO69w(Lg7CSi7k1qX5YMGbTb8gi2T8stCSSZhBM8z0z3OblgQKvKDtCSSN8W77Q1VWvRfmdOz2DnKyFSd4dwPTFdfIOPGWoxcaTP(iXMay2nEKen(Ei7ZpLDbfjbYzLDd49L(fsJZaAMDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25Jn3aXOZUrdwmujRi7M4yzhT4dwxTo5bXha2DnKyFSFpkuHIO)piFdtMDJhjrJVhY(8tzxqrsGCwzhWhSsBaIpaSRaGQ3B5xASZXISRudfNlBcg0gWBGy3YlnXXYoFS52gJo7gnyXqLSISBIJLDbx6GImOwTo5bXha2DnKyFSFpkuHIO)piFdtMDJhjrJVhY(8tzxqrsGCwzhV0bfzqrBaIpaSRaGQ3B5xASZXISRudfNlBcg0gWBGy3YlnXXYoFS5gygD2nAWIHkzfz3ehl7oasdYvRFHRwR8Dqv8Ol7k1qX5YMGbTb8gi2fuKeiNv2ZainiPFH0lDqv8Ol7gpsIgFpK95NYUcaQEVLFPXohlYULxAIJLD(yZTKy0z3OblgQKvKDtCSSRaKkJLLDxdj2h73JcvOi6)dY3WKvNgWhSsB)gkertbHDobaszQrZMmOi22vISLeWG2v5uPkD6MmOi22vISLeWG2v5uPcI1frm8VKUbHPud4dwPTFdfIOPGWoNaabovk2nEKen(Ei7ZpLDbfjbYzLDnKkJLLDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25Jn32LrNDJgSyOswr2nXXYUrOXQPoYpRw7DUo6YURHe7JDS(ilLUtJKMtaOKuNw)Fq(ggKePKOIDoeyJyYKtaLwUZUiktLkzfPekejrkjQyNdb2iMmzbqPL7SlIYsPonAE4qNdrdPYyzr6GfdvQsL()G8nmiAivgllcSrmzYcGsl3bCk2nEKen(Ei7ZpLDbfjbYzL9IgRM6i)qN7CD0LDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25Jn3ugJo7gnyXqLSISBIJLD0MSqMUATFpmYURHe7J9ePKOIDo6FPqirw1y9rwkDNgjnlaqsYczkD(EyK(Wqu9YQfPekerswitPTPG2FUiu2QfPekerswitPTPG2FUiWgXKjNakTChWSB8ijA89q2NFk7ckscKZk7sYczkD(EyKDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25Jn3sogD2nAWIHkzfz3ehl7OnzHmD1A)EyC160BPy31qI9XEIusuXoh9VuiKiRAS(ilLUtJKMfaijzHmLoFpmsFyiQEz1a(GvA73qHiAkiSZjaqktTiLqHisYczkTnf0(ZfHYMDJhjrJVhY(8tzxqrsGCwzxswitPZ3dJSRaGQ3B5xASZXISRudfNlBcg0gWBGy3YlnXXYoFS5gWm6SB0GfdvYkYUjow2rBYcz6Q1(9W4Q1PbNIDxdj2h7jsjrf7C0)sHqISQX6JSu6onsAwaGKKfYu689Wi9HHO6Lvd4dwPTFdfIOPGWoNaaLK60IucfIOHuzSSiu2QtlsjuiIgsLXYIKpSEFcBktLkrkHcred)ldu5dHYoLkvIucfIeiyjKmzAHuqR0utO4mGkrOStXUXJKOX3dzF(PSlOijqoRSljlKP057Hr2vaq17T8ln25yr2vQHIZLnbdAd4nqSB5LM4yzNp2Ct5y0z3OblgQKvKDtCSSJ2KfY0vR97HXvRtNuk2DnKyFSNiLevSZr)lfcjYQgRpYsP70iPzbasswitPZ3dJ0hgIQxwnGpyL2(nuiIMcc7CcaKYuNgnpCOZHOHuzSSiDWIHkvPs)Fq(ggenKkJLfb2iMmzbqPL7Kuk2nEKen(Ei7ZpLDbfjbYzLDjzHmLoFpmYUcaQEVLFPXohlYUsnuCUSjyqBaVbIDlV0ehl78XMBjFgD2nAWIHkzfz3ehl7O3ODadt28Q1kFHsI(y31qI9XEIusuXoh9VuiKiRArkHcrKKfYuABkO9NlcLTArkHcrKKfYuABkO9NlcSrmzYjGsl3bm7gpsIgFpK95NYUGIKa5SY(1ODadZ0lfkj6JDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25JnbdIrNDJgSyOswr2nXXYo6nAhWWKnVATYxOKOVvRtVLIDxdj2h7jsjrf7C0)sHqISQb8bR02VHcr0uqyNtaGuMArkHcrKKfYuABkO9NlcLn7gpsIgFpK95NYUGIKa5SY(1ODadZ0lfkj6JDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25JnbVXOZUrdwmujRi7M4yzh9gTdyyYMxTw5lus03Q1PbNIDxdj2h7jsjrf7C0)sHqISQb8bR02VHcr0uqyNtaGssDArkHcr0qQmwwekB1PfPekerdPYyzrYhwVpHnLPsLiLqHiIH)LbQ8HqzNsLkrkHcrceSesMmTqkOvAQjuCgqLiu2Py34rs047HSp)u2fuKeiNv2VgTdyyMEPqjrFSRaGQ3B5xASZXISRudfNlBcg0gWBGy3YlnXXYoFSjyWm6SB0GfdvYkYUjow2rVr7agMS5vRv(cLe9TAD6KsXURHe7J9ePKOIDo6FPqirw1a(GvA73qHiAkiSZjaqktDA08WHohIgsLXYI0blgQuLk9)b5Byq0qQmwweyJyYKfaLwUtsPuNgnpCOZHu0y1uh5h6CNRJUiDWIHkvPs)Fq(ggKIgRM6i)qN7CD0fb2iMmzbqPLPy34rs047HSp)u2fuKeiNv2VgTdyyMEPqjrFSRaGQ3B5xASZXISRudfNlBcg0gWBGy3YlnXXYoFSj4Ky0z3OblgQKvKDtCSSJ2KfY0vR97HXvRtVBk2DnKyFSNiLevSZr)lfcjYQgWhSsB)gkertbHDobakj1y9rwkDNgjnlaqsYczkD(EyK(Wqu9YQtR)piFddIb8(s)cPXzanJaBetMCcO0YDaRgdpIqS(qmG3x6xinodOzKoyXqLQujsjuiIbaKSDH0Vq6dqPh8baw0ajIqzRwKsOqedaiz7cPFH0hGsp4daSObseb2iMm5eqPLPuNgnpCOZHOHuzSSiDWIHkvPs)Fq(ggenKkJLfb2iMmzbqPL7SBk2nEKen(Ei7ZpLDbfjbYzLDjzHmLoFpmYUcaQEVLFPXohlYUsnuCUSjyqBaVbIDlV0ehl78XMG3LrNDJgSyOswr2nXXYo6nAhWWKnVATYxOKOVvRtVBk2DnKyFSNiLevSZr)lfcjYQgWhSsB)gkertbHDobakj1P1)hKVHbXaEFPFH04mGMrGnIjtobuA5oGvJHhriwFigW7l9lKgNb0mshSyOsvQePekeXaas2Uq6xi9bO0d(aalAGerOSvlsjuiIbaKSDH0Vq6dqPh8baw0ajIaBetMCcO0YuQtJMho05q0qQmwwKoyXqLQuP)piFddIgsLXYIaBetMSaO0YD2nf7gpsIgFpK95NYUGIKa5SY(1ODadZ0lfkj6JDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25JnbRmgD2nAWIHkzfz3ehl7OvkjQyNB160BPy31qI9XU8pKIgRM6i)qN7CD0f5i69KbLA5Fifnwn1r(Ho356OlcSrmzYjGsl3bSAzfPekejrkjQyNdb2iMm5eqPL7aMDJhjrJVhY(8tzxqrsGCwzprkjQyNJDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25JnbNCm6SB0GfdvYkYUjow2tE49D16x4Q1cMb08Q1P3sXURHe7J90a(GvA73qHiAkiSZbeivQa8bR02VHcr0uqyNdOn1P1)hKVHbrmGLL(fsNiv(i6IaBetMSaO0svQ0)hKVHbrswitPbGJXcrGnIjtwauAzkvQa8bR02VHcr0uqyNdiWQtR)piFddcAO4aIgagIQzAHqS(i)GdjaeiKKtzQuP)piFddIgsLXYcPZhKSViAayiQMPfcX6J8doKaqGqsoLLkf7gpsIgFpK95NYUGIKa5SYUb8(s)cPXzanZUcaQEVLFPXohlYUsnuCUSjyqBaVbIDlV0ehl78XMGbMrNDJgSyOswr2nXXYUIbSSRw)cxTgTsLpIURwNElf7UgsSp2td4dwPTFdfIOPGWoxcabwDUhT4puzKJuiyq0GT1aTPsfGpyL2(nuiIMcc7CjausQZ9Of)HkJCKcbdIgSTgiqPy34rs047HSp)u2fuKeiNv2fdyzPFH0jsLpIUSRaGQ3B5xASZXISRudfNlBcg0gWBGy3YlnXXYoFSjyLJrNDJgSyOswr2nXXYoAtwitxTgTahJfUAD6TuS7AiX(ypnGpyL2(nuiIMcc7Cjaey15E0I)qLrosHGbrd2wd0Mkva(GvA73qHiAkiSZLaqjPo3Jw8hQmYrkemiAW2AGaLIDJhjrJVhY(8tzxqrsGCwzxswitPbGJXczxbavV3YV0yNJfzxPgkox2emOnG3aXULxAIJLD(ytWjFgD2nAWIHkzfz3ehl7Of4ySWvRFHRwJwPYhrx2DnKyFS3KbfX2UsKTKaguYPm1hgIQhcGIdhaeB9jaqaRm1a(GvA73qHiAkiSZLaq7YUXJKOX3dzF(PSlOijqoRSdahJfs)cPtKkFeDzxbavV3YV0yNJfzxPgkox2emOnG3aXULxAIJLD(yZKaXOZUrdwmujRi7M4yzhTsjrf7CRwNgCk2vQHIZLnbdAd4nqSlOijqoRSNiLevSZXUXJKOX3dzF(PSRaGQ3B5xASZXISB5LM4yzNp2mPngD2nAWIHkzfz3ehl7jZfhy31qI9XUgagIQzGaRoDUhT4puzKJuiyq0GT1absnGpyL2(nuiIMcc7CjaeyvQsd4dwPTFdfIOPGWoxcaTR606)dY3WGijlKP0aWXyHiWgXKjlakTChWQuP)piFddIyall9lKorQ8r0fb2iMmzbqPL7aoLA9)b5ByqsKsIk25qGnIjtwauA5oGtLsLQ05E0I)qLrosHGbrd2wd0MAaFWkT9BOqenfe25saOnvQsd4dwPTFdfIOPGWoxcaTR606)dY3WGijlKP0aWXyHiWgXKjlakTChWQuP)piFddIyall9lKorQ8r0fb2iMmzbqPL7aoLA9)b5ByqsKsIk25qGnIjtwauA5oGtLIDJhjrJVhY(8tzxqrsGCwzhnuCGDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25JntcmJo7gnyXqLSISBIJLDfGuzSSWvR9ds2x2DnKyFSRbGHOAgiWQtN7rl(dvg5ifcgenyBnqGud4dwPTFdfIOPGWoxcabwLQ0a(GvA73qHiAkiSZLaq7QoT()G8nmisYczknaCmwicSrmzYcGsl3bSkv6)dY3WGigWYs)cPtKkFeDrGnIjtwauA5oGtPw)Fq(ggKePKOIDoeyJyYKfaLwUd4uPuPkDUhT4puzKJuiyq0GT1aTPgWhSsB)gkertbHDUeaAtLQ0a(GvA73qHiAkiSZLaq7QoT()G8nmisYczknaCmwicSrmzYcGsl3bSkv6)dY3WGigWYs)cPtKkFeDrGnIjtwauA5oGtPw)Fq(ggKePKOIDoeyJyYKfaLwUd4uPy34rs047HSp)u2fuKeiNv21qQmwwiD(GK9LDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25JntkjgD2nAWIHkzfz3ehl7k8tUAi(i)WUsnuCUSjyqBaVbIDbfjbYzLD9p5QH4J8d7gpsIgFpK95NYUcaQEVLFPXohlYULxAIJLD(yZK2LrNDJgSyOswr2nXXYoAtwitxT2VhgxToTYsXURHe7J9ePKOIDo6FPqirw1y9rwkDNgjnlaqsYczkD(EyK(Wqu9YQfPekerswitPTPG2FUiu2SB8ijA89q2NFk7ckscKZk7sYczkD(EyKDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25Jntszm6SB0GfdvYkYUjow2rBYcz6Q1(9W4Q1PtUuS7AiX(yprkjQyNJ(xkesKvnwFKLs3PrsZcaKKSqMsNVhgPpmevVSArkHcroaLwib2m9lKorQ8r0fHYwDA08WHohIgsLXYI0blgQuLk9)b5Byq0qQmwweyJyYKfaLwUtsPy34rs047HSp)u2fuKeiNv2LKfYu689Wi7kaO69w(Lg7CSi7k1qX5YMGbTb8gi2T8stCSSZhBMuYXOZUrdwmujRi7M4yzhTjlKPRw73dJRwNg4uS7AiX(yprkjQyNJ(xkesKvnwFKLs3PrsZcaKKSqMsNVhgPpmevVSAaFWkT9BOqenfe25eaODvNgnpCOZHOHuzSSiDWIHkvPs)Fq(ggenKkJLfb2iMmzbqPL7SBk2nEKen(Ei7ZpLDbfjbYzLDjzHmLoFpmYUcaQEVLFPXohlYUsnuCUSjyqBaVbIDlV0ehl78XMjbmJo7gnyXqLSISBIJLD0B0oGHjBE1ALVqjrFRwNwzPy31qI9XEIusuXoh9VuiKiRArkHcrKKfYuABkO9NlcLn7gpsIgFpK95NYUGIKa5SY(1ODadZ0lfkj6JDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25Jnts5y0z3OblgQKvKDtCSSJEJ2bmmzZRwR8fkj6B160jxk2DnKyFSNiLevSZr)lfcjYQwKsOqKdqPfsGnt)cPtKkFeDrOSvNgnpCOZHOHuzSSiDWIHkvPs)Fq(ggenKkJLfb2iMmzbqPL7Kuk2nEKen(Ei7ZpLDbfjbYzL9Rr7agMPxkus0h7kaO69w(Lg7CSi7k1qX5YMGbTb8gi2T8stCSSZhBMuYNrNDJgSyOswr2nXXYo6nAhWWKnVATYxOKOVvRtdCk2DnKyFSNiLevSZr)lfcjYQgWhSsB)gkertbHDobaAx1PrZdh6CiAivgllshSyOsvQ0)hKVHbrdPYyzrGnIjtwauA5o7MsDA08WHohsrJvtDKFOZDUo6I0blgQuLk9)b5ByqkASAQJ8dDUZ1rxeyJyYKfaLwUd4uSB8ijA89q2NFk7ckscKZk7xJ2bmmtVuOKOp2vaq17T8ln25yr2vQHIZLnbdAd4nqSB5LM4yzNp2Cxqm6SB0GfdvYkYUjow2tMloSAD6TuS7AiX(yhWhSsB)gkertbHDUeaAx2nEKen(Ei7ZpLDbfjbYzLD0qXb2vaq17T8ln25yr2vQHIZLnbdAd4nqSB5LM4yzNp2C3ngD2nAWIHkzfz3ehl7kaPYyzHRw7hKSVRwNElf7UgsSp2b8bR02VHcr0uqyNlbG2LDJhjrJVhY(8tzxqrsGCwzxdPYyzH05ds2x2vaq17T8ln25yr2vQHIZLnbdAd4nqSB5LM4yzNp2CxWm6SB0GfdvYkYUjow2rBYcz6Q1(9W4Q1PvUuS7AiX(yprkjQyNJ(xkesKvnGpyL2(nuiIMcc7CcausQX6JSu6onsAwaGKKfYu689Wi9HHO6LvNgnpCOZHOHuzSSiDWIHkvPs)Fq(ggenKkJLfb2iMmzbqPL7OSuSB8ijA89q2NFk7ckscKZk7sYczkD(EyKDfau9El)sJDowKDLAO4CztWG2aEde7wEPjow25Jn3njgD2nAWIHkzfz3ehl7O3ODadt28Q1kFHsI(wToTYLIDxdj2h7jsjrf7C0)sHqISQb8bR02VHcr0uqyNtaGssDA08WHohIgsLXYI0blgQuLk9)b5Byq0qQmwweyJyYKfaLwUJYsXUXJKOX3dzF(PSlOijqoRSFnAhWWm9sHsI(yxbavV3YV0yNJfzxPgkox2emOnG3aXULxAIJLD(4JD3UAcoqqd4J8dBcmi(yg]] )

    storeDefault( [[SimC Retribution: precombat]], 'actionLists', 20170423.220102, [[b4vmErLxtruzMfwDSrNxc51uofwBL51utLwBd5hysvgDYLMy1rxAV5Mo(bgCYv2yV1MyHrNxtjvzSvwyZvMxojdmXCdm0aJmUeJm1CdmZ41utnMCPbhDEnLxtf0y0L2BUnNxu5LtX4fvEnvrUfMySvgzEjKxtn1yYLgC051u092zNXwzUa3B0L2BUnNxtfKyPXwA0LNxtb3B0L2BU51uj5gzPnwy09MCEnLBV5wzEnLtH1wzEnfuVrxAV5MxtfKCNnNxt5wyTvwpI8gBK91DHjNiEnLuLXwzHnxzE5KmWeZnXaJxtneALn2An9MDL1wzUrNxI51un9gzofwBL51uVXgzFDxyY5fDErNxtnfCLnwAHXwA6fgDP9MBE50nW4fDE5f]] )

    storeDefault( [[Protection ST]], 'actionLists', 20170423.220102, [[d8J2haGArsTErIAtuczxO02uu2hLqTmkvNwvZMI5tjOprjsJsKW3ePoVOyNK0EL2ns7xf9tkbAykY4OeLNPOAOus0GvjdNeoij6uus1Xa15uPuTqrPLsPSyrSCepKskEkXJf65KAIucyQIQjly6uDrvQEnLK6YqxxfoSsRsKiBgfTDvkUnQ8zu10OKsZJssgjLO67OqJwHXlsYjrb3IscxJse3tLswPkLYFb53ax4MxXcGm3dJ3SvKi5v4vQOUCyfRKaCm6pGEEj5vSHgC1yvTpbNEYANSZcB3sspnVInCdzYFoSskoVIaGjayKYQhpAcqaMq(aHip)WrWHMnowcpQH42uDEzfNxraWeamsz1JhnbiatiFGqKNF4i4qZghlHh1qmjB0FaDnNxw)8kLoV2O)akRE8Ojabyc5deI88dhbhAwcghlHhROm6pGQBEvHBEL70nXGHMTI6YHvSsG)aAfjsEfEf)5WBnvrjHxxHUC4TaMaeJlPIYK38EMkka(dOvyGg(46asfkGIvSHgC1yvTpbpdon70C4kR7KMxVEvT38kR7KMxVIejVcVId45ni7tDKqou46kQlhwXgMCy1yfBObxnwv7tWZGtZonhUcd0WhxhqQqbuSIYK38EMkem5WQXk3PBIbdnB9QoV5vw3jnVEfjsEfELKdMmz5jlnafjh6nGe2dfwKVgK6SrYHEdirdL6JaphsDwKUjgmyrraWeamszt9rGNdPoBCSeEuBvWvuxoSIYBqkpsSu95LmE0eQydn4QXQAFcEgCA2P5WvyGg(46asfkGIvuM8M3ZuzVbP8irdPhpAcvUt3edgA26v1ABEL1DsZRxrIKxHxzJ(FdcHuK7rTfdxrzYBEptLiGQXiz9hqRydn4QXQAFcEgCA2P5WvyGg(46asfkGIvuxoSI1aOAmsw)b0ZRuO0cE36vUt3edgA26v1sAEL70nXGHMTIejVcVseambaJuw94rtacWeYhie55hoco0SXXs4r9TIaGjayKYQhpAcqaMq(aHip)WrWHMnowcpQH42uvrzYBEptf94rtacWeYhie55hoco0vyGg(46asfkGIvugUzPrm0SvuxoSImE0eoVampV8bEEz75hoco0vSHgC1yvTpbpdon70C4k2WnKj)5WkP48kcaMaGrkRE8Ojabyc5deI88dhbhA24yj8OgIBt15LvCEfbataWiLvpE0eGamH8bcrE(HJGdnBCSeEudXKSr)b01CEz9ZRu68AJ(dOS6XJMaeGjKpqiYZpCeCOzjyCSeESIejVcppJcSI)CyL1DsZRxVQZAEL1DsZRxrIKxHxPI6YHvUTJaphs9k2qdUASQ2NGNbNMDAoCfgOHpUoGuHcOyfLjV59mvs9rGNdPEL70nXGHMTEvt38k3PBIbdnBfjsEfELaMCWKjBIb1AmanwooKWsqU9PARYYSqlmcaMaGrkBIb1AmanwooKWghlHh1wmCf1LdRK1GAngoVS8LJdjvus41vQydn4QXQAFcEgCA2P5WvyGg(46asfkGIvuM8M3ZujXGAngGglhhsQSUtAE96v1YAEL1DsZRxrIKxHxPI6YHvSgavJrY6pGwXgAWvJv1(e8m40StZHRWan8X1bKkuafROm5nVNPseq1yKS(dOvUt3edgA26v92BEL1DsZRxrIKxHxPI6YHvuEds5rILQpVKXJMW5vkGTEfBObxnwv7tWZGtZonhUcd0WhxhqQqbuSIYK38EMk7niLhjAi94rtOYD6MyWqZwVQWtnVY6oP51RirYRWRurD5Wkw(YXHKZlaZZlFGNx2E(HJGdDfBObxnwv7tWZGtZonhUcd0WhxhqQqbuSIYK38EMkJLJdjqaMq(aHip)WrWHUYD6MyWqZwVEfrbg)18P86pGw1zZQ3c]] )

    storeDefault( [[Protection Defensives]], 'actionLists', 20170423.220102, [[deZycaGEjfTjjr2LcABeLzkjy2u52ev7eP2Ry3uA)eAuskmmk8BvnuvkdMidNQCqjvNssshtfluHSusLfJKwojpfAzQKNlXeLuAQuvtMGPJ6IQu9msvxhj2mfTDjP8nsX0Ke1PvAKssCzWOLYNjLoPc1HrCnjHoVc8xf9AjP6Xs15e)G0e5qWBQNHoVVvuQwWeSLTAqjyTGjHIJZOG6ahqkqOVmoAmQSX1WZvf1yOpi6b9L42As49THwMSG178(2s8d9j(bVBjuDGqgfe7Q1JdYeB1xR2krPaZsBbNqqAICii2wWjik9MIsCdeL0TABm8ukIs14u1G6ahqkqOVmoYoAgAO)eSo11T8GGL2coH5Bo5gmvR2gdpLsWXwHTt4xf0(wiiHzv8dhe7Q1J9h4bblR8E4qFf)GeMvXpCqAICiyviwbrP3uuIBGO0n1ZqNFvqSRwpoiLcmlGZC2aIlOoWbKce6lJJSJMHg6pbhBf2oHFvq7BHG1PUULheSrScZ3CYny6PEg68RcE3sO6aHmkCO1h)GeMvXpCqAICiyfwTnwu6nfL4gikDt9m05xfe7Q1JdsPaZc4mNnG4cQdCaPaH(Y4i7OzOH(tWXwHTt4xf0(wiyDQRB5bbDR2gpFZj3GPN6zOZVk4DlHQdeYOWHdID16XbdNa]] )

    storeDefault( [[Protection Cooldowns]], 'actionLists', 20170423.220102, [[b4vmErLxtruzMfwDSrNxc51uofwBL51uqj3B0v2y0L2BU5hyd92BSr2B352CEnLuLXwzHnxzE5KmWeZnWqdmY4smYuZnWmJxtnfCLnwAHXwA6fgDP9MBE5Kn241ubngDP9MBZ5fvErNxtn1yYLgC051uErNxEb]] )

    storeDefault( [[Protection Default]], 'actionLists', 20170423.220102, [[d0ItcaGEuLAxGITrP0SbUPkv3wj2Pc7vSBP2VsAyu0Vjnuf1GvkdNcoivXXOKfsvzPuvTyuPLRIhQsXtHwMk55uzIuLMQImzqMoXfrvCzKRJkAZuOTdQAAQu67OcNwY3qv9yuojO0ZOuCnuLCEqL)Qu9zkvhwvhRmfC8luW5JketkTx38sgFobsq0aXQhu8(Ls7mS12G(ja9okJltl(M3AEbJ1fV4BAtqKDkdsWGEysPTltzyLPG80pxabfFbh)cfC(OcXKs71nVKrQDf8KliYoLbjOO2Tdiy40r7qKrQDf8KlOFcqVJY4Y0IVLzqyBOI9IEc2Atb9WTaLaxq2da7ptkT3bLtcExHg)cfC(OcXKs71nVKrQDf8Klsgxzkip9ZfqqXxWXVqbNpQqmP0ED7gvbqkhTliYoLbjOO2TdiyyQcGuoAxq)eGEhLXLPfFlZGW2qf7f9eS1Mc6HBbkbUGSha2FMuAVdkNe8Ucn(fk48rfIjL2RB3Okas5ODrYWMmfKN(5ciO4l44xOGZhviMuAVUHtbr2Pmibd6Na07OmUmT4Bzge2gQyVONGT2uqpClqjWfK9aW(ZKs7Dq5KG3vOXVqbNpQqmP0EDdNIejOxY4ZjqIVija]] )



    storeDefault( [[Retribution Primary]], 'displays', 20170402.125703, [[d0JoiaGEvvEPsvTlvvjVwPkZKQIdlz2k55u5MQQQLPu52K05jv7KI9k2nQ2VQ4NiYWKIFd50qnuIAWQsdhPoOu1rvvL6yuLJtvPfkLwQuPfJslNWdjfpf8yuSosjnrvvXurYKjIPR4IQkxLQkEgvv66iSrPITsKI2mLA7KWhPQQpJOMgPeFxPmssP6BKsz0uY4jsojj6wePY1isv3JiLCzvwlrkmoIuQJxOcWu0dgX7G4dm6Rlaj)q5JsZxGPeKVrwHCydiko5tJ1XSxAd4lXrC9lmzU6XNamb0jzB7Urtrpye3fttaPizB7Urtrpye3fttaFjoItIsgehW)Uy0staNfARNquk52OWgWxIJ4KOPOhmI7sBaDs22UBOkb5BCX0e4VjoIZfQy8cvGpEXUojPnqpZGr8NxFWUjMDbmL6faWQAEE7EJaZsmyexRpV0IJbPYwtGU36k3fZUgpT1410eayey6jWGvpPvtMy2fQaF8IDDssBGEMbJ4pV(GDtmEbmL6faWQAEE7EJaZsmyexRpVso7Iynb6ERRCxm7A80wJxttMmbCwOnydpmw9FPnGZcT1tmO0gWzH2Gn8Wy1tmO0gykb5B65mwirGwsuuK(VRs)1ova9yKUDAPjGuX0eWzH2Okb5BCPnWES9CglKiafj5Uk9x7ubyqQS1iR4lSbyk6bJ49CglKiqljkks)hqdIw)5LcfqwGMJzWi(ZRSaRwc9aol0gqL2a(sCe3FWIJzWiEGUk9x7ub4eQkzqCxmAjGJ(wRoRYzPbTqIqfOIXlGigVaKJXlaBmEzc4SqBAk6bJ4U0gqks22UB6jevmnbkcrrPtFbyjSTdib7OxLoLo9fOcOws1tmOyAculARQFTv6ozfFX4fOw0wfyH2Kv8fJxGArBvAqQS1iR4lgVa)5SlI1K2asrY22DJsUemtniHlMMa1AR0DYkKtBafyhMfVWJoLo9fGnatrpyeVFHjZdO5Zq91nGVeyM9KMyhm6RlqfaOpgCTW)QbJ4XOTMaIIt(O0PVaflEHh9afHO(hZV0gykb5B6G4tazQNxO4UNxtjeOTa7X2bXha)7IXBxG9pDwmxcMt(5fg91fZUaYcSAj0FE1u0dgXFE7jevGafHO65mwirGwsuuK(3NVoube3kGMpd1x3ao6BT6SkNvydulARIQeKVrwXxmEbSr8jqVaxRNxtjeOTa(sCeNeLCjyMAqcxAdWUW)(5)cT1VwHna7c)7N)l0wydmLG8nDq8bg91fGKFO8rP5lW)Luyvc1NxkS6fJFBcilWQLq)5vtrpyepWucY34camcm9eiqTOTQ(1wP7KvihJxajNDrSMEzFcayvnpVDVrGzjgmIR1NxjNDrSMa0cSAj07G4dG)DX4TlaT4yqQS10l7taaRQ55T7ncmlXGrCT(8slogKkBnbuX8(Vy8Ba1sQ(VyAcqvRJppV(lqe0X4fykb5BKv8f2asrY22DZ(TUy8c09wx5Uy214PTg)UtA)xEb0jzB7UPNquX0eqfZ7jgumnbyk6bJ4Dq8bW)Uy82fOiefqFRLY)ettGArBvGfAtwHCmEbCwOnLCjyMAqcxAd4SqBYkKtBGATv6ozfFPnGZcTjR4lTbCwOT(V0gGbPYwJSc5Wgyp2oi(eqM65fkU751ucbAlWESDq8bg91fGKFO8rP5lGojBB3n736Ir68cOI5avmnbMsq(Moi(a4FxmE7culARIQeKVrwHCmEbyk6bJ4Dq8jGm1ZluC3ZRPec0wGArBvAqQS1iRqogVaF8IDDssBahwLED9K(IzxamxcMPgKONZyHeb6Q0FTtfWzH22)0zXCjyozxAdqlWQLqxjdId4FxmAPjqrikLCBeLo9fGLW2oGAjfqfJxaPizB7UHQeKVXfttamdId0fdMtogPpWcTDcMYD736cBamdIlnqi1y8K(a(sCeNKoi(a4FxmE7cOtY22DJsUemtniHlMMa(sCeNK9BDPnGPuVaDVrGzjgmI)8klWQLqpqrik)WXta6vPFImj]] )

    storeDefault( [[Retribution AOE]], 'displays', 20170402.125703, [[da0miaqicj1MiePBriv7skuddIogrTmsXZGqnnLOCncHVriLXriQohHewNui3JqIoOuAHkPhsOMOsuDrLYgvcFujYijL4KeXlrjmtPGBIs0oP4NqYqPKJsiklvk6PGPIKRskPTsiI1sij7vmyvXHLSyu8ycMmk1LvzZuPpdPgnP60iEneYSLQBtP2nQ(nudhPooPulNKNtvtxX1vvBNi9DvPXJs68uX6HG9RuDKdvaHIEiy(cmFGXPFbqPvQgKy2cmLc9nwsTctavXrFI1pbeL1aA)V)12jO52hFcieWbLRR)gXf9qWCFmidWkkxx)nIl6HG5(yqgGwrSlLJebmhiiCXSmKbSj82TyqCaT)3)ylUOhcM7ZAahuUU(BOkf6B8XGmGi7F)ZhQyKdvGnEX0p2znqRWqW89Ngi(jgnbmL9fai2I3FAEJIW8hcM3O9hA1jGTzQjqZRFL)Irdszril3ynAKdackc9eyi2NOezMy0eQaB8IPFSZAGwHHG57pnq8tmYbmL9fai2I3FAEJIW8hcM3O9h2NB97tGMx)k)fJgKYIqwUXA0iNjtaVo(fEjJGE7wwdWkkxx)nuLc9n(yqgWRJFHxYiO3(hCwdmLc9nTCbDSkWkkkkuSSPKL0cvaNyeDzrHicWAmidWIZHHWzt4O3FGXPFXOjaIyA5c6yvakuwnLSKwOciGTzQXs6wyciu0dbZB5c6yvGvuuuOyzaXyAN9hkCGM3Oim)HG57pTO2c41XVavwdO9)(3YjQtyiyEGMswslub4FBjcyUpMLfWtF9(IE51fJ7yvOcuXihGjg5aOJroGkg5mb864xXf9qWCFwdWkkxx)nTFvfdYa1xvuo0xaMVRBa7I12)GJbzGQtRxT93YXBjDlg5avNwVaD8RL0TyKduDA9sm2MPglPBXihWu2xGM3Oim)HG57pTO2cWM4P7LdLd9fqiq1FlhVLuRSgqkXtyiDY4q5qFbyciu0dbZB7e08aI3muBndO9NiGircXdJt)cuba6tGuDcc1qW8yenKbufh9r5qFbkgsNmobQVQyjHFznGnH3(hCmioaIywG5dqq4IrwtahuUU(BKWzteQbR8XGmGLIyxkN9hXf9qW89N2VQceykf6BwG5talQ9hO4(9htPu43aQRhq8MHARzap917l6LxpmbQoTErvk03yjDlg5a1xvTCbDSkWkkkkuSSHTfub0(F)JTeoBIqnyLpRb86432VQKWDXHjatNGacl1XVHjWuk03SaZhyC6xauALQbjMTaSSyLy)T3FOi2xmigzaMobbewQJFB79Weaeue6jGNWr3prQOU(doq1P1R2(B54TKAfJCGMx)k)fJgKYIgseRrK3y5a0kIDPCwG5dqq4IrwtaA1jGTzQP1QHaaXw8(tZBueM)qW8gT)qRobSntnbyFU1VpTwneai2I3FAEJIW8hcM3O9h2NB97ta7I12TyqgGQ6hF2FwsH)0XGmWuk03yjDlmb86432)GdtalfXUuo7pIl6HG5bMsH(gFawr566VHfR(yKd4GY11Ft7xvXGmGqrpemFbMpabHlgznb0(F)JTebmhiiCXSmKbQVQa6R3LS8yqgWRJFLWzteQbR8znq1P1lqh)Aj1kg5av)TC8ws3YAaVo(1sQvwd41XVTBHjGa2MPglPwHjaIywG5talQ9hO4(9htPu43aoOCD93WIvFmIUCaeXSaZhyC6xauALQbjMTa2eoqfdIdmLc9nlW8biiCXiRjGxh)AjDlRbek6HG5lW8jGf1(duC)(JPuk8BGQtRxIX2m1yj1kg5aB8IPFSZAapXMUFTO2IrtacNnrOgSQLlOJvbAkzjTqfO606fvPqFJLuRyKd41XVS4CyiC2eoAFwdyxScuXGmq9vLeUlMYH(cW8DDdqeWCGUeiC0XiIaED8lvPqFJpRbCX8jqRIu99htPu43aebmxuHX2XilIaA)V)XEbMpabHlgznbyfLRR)gjC2eHAWkFmidO9)(hBwS6ZAGLFU1Vpznq9vLw5KjaDVCovMe]] )

    storeDefault( [[Protection Primary]], 'displays', 20170402.125703, [[dWdAiaGEiLxQuv7IuL2gssZeLQzRKdl5MqQ8Bv9nsvOLjvSts2l1Ur1(HOFIedtKghPkQpJsgkkgmKmCK6GsPJsQICms54IkTqPyPOuwSiworpuu1tbpgkpxWeHu1uHQjtitxXfHWvjvLlRY1jyJsL2kPkyZIY2juFuPItJyAij(UszKKQQNjQy0c14rsDssLBPujUMsL68c52svRvPs61kvzRzCdyf9qEE3NpWeTodu0ho76uimmLK1nmIzCIbzXzD5JpS9CJHCfoHRDryX7p(yaZqeLSSWn5l6H88GvPgOMsww4M8f9qEEWQud5kCcNiDyphiODwrLudH4FRvqw64zVtmKRWjCIYx0d55b3yiIsww4g8sY6MGvPg0tcNWfmUvAg3acELSorUXql2qEosuStcJvuXGQ6pdmYFoSH8CKOq)LD8ar8fmW2TUkCw1jvJQAPP5OxndaMKqpg8yvhJBabVswNi3yOfBiphjk2jHXQDBqv9Nbg5ph2qEosu5)Fj634bdSDRRcNvDs1OQwAAo6vZaGjj0JbpwLJXnGGxjRtKBm0InKNJef7KWyvoguv)zGr(ZHnKNJefGBGTBDv4SQtQgv1stZrVAgamjHEm4XJHq8VbBKblUfHBmeI)TwH5DJHq8VbBKblUvyE3yykjRBA5yXV0qdfCCkOJnD7OFCdrwTlDOsQbQTk1qi(3WljRBcUXWEjTCS4xAaNcdB62r)4gW((KAyeJWjgWk6H88wow8ln0qbhNc6mK)PJqIc)nWi)5WgYZrIIrs6lzKHq8Vb4UXqUcNWHEI8WgYZnWMUD0pUbUqVoSNhSIkgc03A1DvH48)6Lg3qzLMbPvAgyzLMHeR08yie)B5l6H88GBmqnLSSWnTcYYQudLGSWJOpdjczzgerc0RkcpI(mug6lQBfM3Qud1IoUAxBvuGrmcR0mul64cI)ngXiSsZqTOJR8FFsnmIryLMb0FzLWACJbQPKLfUrhxebRMxgSk1qT2QOaJyg3yqmjqsilYeHhrFgsmGv0d55TlclUH8iu4iyZqUceS90dKamrRZqzaOpmsTiOvd55wrvQAqwCwhEe9zOsilYezOeKf6i8ZngMsY6MUpFmWGJefu8asuQsk)nd7L095dqq7SsRJH9VOecxeHZcjkyIwNvDmWij9LmcjQ8f9qEosuTcYYGHsqwTCS4xAOHcoof0XoIU4gK3YqEekCeSziqFRv3vfIDIHArhx4LK1nmIryLMHSNpgALKAHeLQKYFZqUcNWjshxebRMxgCJHKfbn02z9BTRLtmKSiOH2oRFZjgMsY6MUpFGjADgOOpC21PqyaDf1KEHEKOWj9Nv5KAGrs6lzesu5l6H8CdtjzDtWaGjj0Jbd1IoUAxBvuGrmJvAgeDzLWAAzy3aJ8NdBiphjk0FzLWAmqlj9LmQ7ZhGG2zLwhd0Yd77tQPLHDRsn0t4TiSkhd9f1TiSk1aETo(Ge1oYxG2QudtjzDdJyeoXa1uYYc3SFtWkndH4FB)lkHWfr4ScUXqeLSSWnTcYYQud1IoUWljRByeZyLMHEcVvyERsnucYcOV1sh6Tk1qTOJli(3yeZyLMHq8VPJlIGvZldUXqi(3yeZ4gd1ARIcmIr4gdH4FJrmc3yie)BTiCJbSVpPggXmoXWEjDF(yGbhjkO4bKOuLu(Bg2lP7ZhyIwNbk6dNDDkegIOKLfUz)MGv7IMHEchWTk1Wusw3095dqq7SsRJbSIEipV7ZhGG2zLwhdyf9qEE3NpgyWrIckEajkvjL)MHArhx5)(KAyeZyLMbe8kzDICJHaPNEDTuqyvhdeUicwnVSLJf)sdSPBh9JBGTBDv4SQtQMEmnNo6z9QzGws6lzKoSNde0oROsQHsqw64zpEe9zirilZqFrnGBLMbQPKLfUbVKSUjyvQbc2Zb6cJWzz1UnS(TtIvHB)MGtmqWE(U(FVvA72qUcNWjQ7ZhGG2zLwhdruYYc3OJlIGvZldwLAixHt4eTFtWnguv)zGr(ZHnKNJefJK0xYidLGS0hNmgOxv0j9yd]] )


end
