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
local addTalent = ns.addTalent
local addPerk = ns.addPerk
local addResource = ns.addResource
local addStance = ns.addStance

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
            return spec.retribution and ( debuff.judgment.up or ( not settings.strict_finishers and cooldown.judgment.remains > gcd * 2 and holy_power.current >= 5 ) )
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


    storeDefault( [[SimC Retribution: default]], 'actionLists', 20170328.1, [[dyKgPaqiiswKisztKuFsejJsK6uIKvPuLDbPHbKJPuwgeEMiQPbrCnkeBterFdqnokKCoLQcRJcPK5jcUhGSpc4GeOfscEij0eHi1fjrTrkKIgPsvrNKc1kvQQ6MuIDsrdLcPulLe5PunviQTkIWxfrQwlfsH9I6Vi1GvsDyOwmHEmPMmrxwAZe0NbQrdWPrSArOxRuz2cUTq7wXVv1WPuhNcPA5GEUOMUkxhjBxj(ofmELQkNNsA9kvLMpjz)kjZBmYSR8GfdvYkWUBxnbhi7l(i)WMadIDtCSS7KOIRwRupirK6i)y0A1AzfIPch7k1qX5YMiaTbmOKryuOBS7AiX(yNDb1h5NmJmBUXiZUYdwmujRa7M4yzxPksTRS7AiX(y)EWGdfLmxHqk7lZUIaQENLFPXohlYUsnuCUSjcqBaVbIDJhjrJVhY(8tzxqrsGCwzhwrQDLDlV0ehl78XMiyKzx5blgQKvGDxdj2h73dgCOO2)r(jRoDArkHcrfd)ldu5dLYwLkrkHcrXlDatgW0gG4dakLTkvIucfIQHuzSSOu2QfPekevdPYyzrHnIjtobegrLQddb3d9iXsFpTK0eacjGsLIDbfjbYzLD7)i)WUXJKOX3dzF(PSBIJLDJ2)r(HDbHGZSp4ybkP9bjTbmmPXUsnuCUSjcqBaVbIDfbu9ol)sJDowKDlV0ehl7jTpiPnGHjn(yZKzKzx5blgQKvGDtCSSRq4F5Q1gnPGwz31qI9X(9GbhkQ()G8nmz2veq17S8ln25yr2vQHIZLnraAd4nqSB8ijA89q2NFk7ckscKZk7IH)L0cPGwz3YlnXXYoFSjsyKzx5blgQKvGDtCSSRqH5c3rgWS7AiX(y)EWGdfv)Fq(gMm7kcO6Dw(Lg7CSi7k1qX5YMiaTb8gi2nEKen(Ei7ZpLDbfjbYzLDXcZfUJmGz3YlnXXYoFSPryKzx5blgQKvGDtCSSliuJNUAnYpe25y31qI9X(9GbhkQ()G8nmz1Pb8bR02VHcr1uqyNlbJOoTiLqHOAivgllkLTkvIucfIIx6aMmGPnaXhaukBvQosSjGivk2veq17S8ln25yr2vQHIZLnraAd4nqSB8ijA89q2NFk7ckscKZk7yOgpL(EiSZXULxAIJLD(yZKKrMDLhSyOswb2nXXY((tjbh7CS7AiX(y)iXMac2veq17S8ln25yr2vQHIZLnraAd4nqSB8ijA89q2NFk7ckscKZk7jsjbh7CSB5LM4yzNp2eygz2vEWIHkzfy3ehl7keWYUA9lC169NkFeDz31qI9X(rInbeQtxJofX2Us0TKbgesmkvQGyDrfd)lPBqyk2veq17S8ln25yr2vQHIZLnraAd4nqSB8ijA89q2NFk7ckscKZk7IbSS0Vq6ePYhrx2T8stCSSZhBAumYSR8GfdvYkWUjow2rAYcz6Q17tCmwi7UgsSp2psSjGqD6A0Pi22vIULmWGqIrPsfeRlQy4FjDdctXUIaQENLFPXohlYUsnuCUSjcqBaVbIDJhjrJVhY(8tzxqrsGCwzxswitPbGJXcz3YlnXXYoFS5(GrMDLhSyOswb2nXXYEshVRRw)cxTwWmGMz31qI9XoGpyL2(nuiQMcc7Cja0M6JeBciyxravVZYV0yNJfzxPgkox2ebOnG3aXUXJKOX3dzF(PSlOijqoRSBaVR0VqACgqZSB5LM4yzNp2CdeJm7kpyXqLScSBIJL995hSUADshIpaS7AiX(y)EWGdfv)Fq(gMm7kcO6Dw(Lg7CSi7k1qX5YMiaTb8gi2nEKen(Ei7ZpLDbfjbYzLDaFWkTbi(aWULxAIJLD(yZTngz2vEWIHkzfy3ehl7cU0bmzaVADshIpaS7AiX(y)EWGdfv)Fq(gMm7kcO6Dw(Lg7CSi7k1qX5YMiaTb8gi2nEKen(Ei7ZpLDbfjbYzLD8shWKbmTbi(aWULxAIJLD(yZnemYSR8GfdvYkWUjow2DaKgKRw)cxToj6aU4rx2vQHIZLnraAd4nqSlOijqoRSNbqAqs)cPx6aU4rx2nEKen(Ei7ZpLDfbu9ol)sJDowKDlV0ehl78XMBjZiZUYdwmujRa7M4yzxrivgll7UgsSp2Vhm4qr1)hKVHjRonGpyL2(nuiQMcc7CcaKruJu1OtrSTReDlzGbHeJsLQ0PRrNIyBxj6wYadcjgLkvqSUOIH)L0nimLAaFWkT9BOqunfe25eaiePsXUIaQENLFPXohlYUsnuCUSjcqBaVbIDJhjrJVhY(8tzxqrsGCwzxdPYyzz3YlnXXYoFS5gsyKzx5blgQKvGDtCSSR8(vn1r(z1AVZ1rx2DnKyFSJ1hzP0DAK0CcaLS606)dY3WGMiLeCSZHcBetMCcG1Y9qcQruPswrkHcrtKsco25qHnIjtwaWA5Eib1iPuNgPoCOZHQHuzSSODWIHkvPs)Fq(ggunKkJLff2iMmzbaRL7Hif7kcO6Dw(Lg7CSi7k1qX5YMiaTb8gi2nEKen(Ei7ZpLDbfjbYzL9UFvtDKFOZDUo6YULxAIJLD(yZnJWiZUYdwmujRa7M4yzhPjlKPRw73dJS7AiX(yprkj4yNJ(xkesKvnwFKLs3PrsZcaKKSqMsNVhgPpmeCVSArkHcrLKfYuABkO9NlkLTArkHcrLKfYuABkO9NlkSrmzYjawl3db7kcO6Dw(Lg7CSi7k1qX5YMiaTb8gi2nEKen(Ei7ZpLDbfjbYzLDjzHmLoFpmYULxAIJLD(yZTKKrMDLhSyOswb2nXXYostwitxT2VhgxTo9wk2DnKyFSNiLeCSZr)lfcjYQgRpYsP70iPzbasswitPZ3dJ0hgcUxwnGpyL2(nuiQMcc7CcaKrulsjuiQKSqMsBtbT)CrPSzxravVZYV0yNJfzxPgkox2ebOnG3aXUXJKOX3dzF(PSlOijqoRSljlKP057Hr2T8stCSSZhBUbmJm7kpyXqLScSBIJLDKMSqMUATFpmUADAePy31qI9XEIusWXoh9VuiKiRAS(ilLUtJKMfaijzHmLoFpmsFyi4Ez1a(GvA73qHOAkiSZjaqjRoTiLqHOAivgllkLT60IucfIQHuzSSO5dR3LWMruPsKsOquXW)Yav(qPStPsLiLqHObcwcjtMwif0kn1ekodOsuk7uSRiGQ3z5xASZXISRudfNlBIa0gWBGy34rs047HSp)u2fuKeiNv2LKfYu689Wi7wEPjow25Jn3mkgz2vEWIHkzfy3ehl7inzHmD1A)EyC160jNIDxdj2h7jsjbh7C0)sHqISQX6JSu6onsAwaGKKfYu689Wi9HHG7Lvd4dwPTFdfIQPGWoNaaze1PrQdh6COAivgllAhSyOsvQ0)hKVHbvdPYyzrHnIjtwaWA5EjNIDfbu9ol)sJDowKDLAO4CzteG2aEde7gpsIgFpK95NYUGIKa5SYUKSqMsNVhgz3YlnXXYoFS52(GrMDLhSyOswb2nXXYoYnAhWWKkVADsuOKOp2DnKyFSNiLeCSZr)lfcjYQwKsOqujzHmL2McA)5IszRwKsOqujzHmL2McA)5IcBetMCcG1Y9qWUIaQENLFPXohlYUsnuCUSjcqBaVbIDJhjrJVhY(8tzxqrsGCwz)A0oGHz6LcLe9XULxAIJLD(yteGyKzx5blgQKvGDtCSSJCJ2bmmPYRwNefkj6B160BPy31qI9XEIusWXoh9VuiKiRAaFWkT9BOqunfe25eaiJOwKsOqujzHmL2McA)5IszZUIaQENLFPXohlYUsnuCUSjcqBaVbIDJhjrJVhY(8tzxqrsGCwz)A0oGHz6LcLe9XULxAIJLD(yteBmYSR8GfdvYkWUjow2rUr7agMu5vRtIcLe9TADAePy31qI9XEIusWXoh9VuiKiRAaFWkT9BOqunfe25eaOKvNwKsOqunKkJLfLYwDArkHcr1qQmww08H17syZiQujsjuiQy4FzGkFOu2PuPsKsOq0ablHKjtlKcALMAcfNbujkLDk2veq17S8ln25yr2vQHIZLnraAd4nqSB8ijA89q2NFk7ckscKZk7xJ2bmmtVuOKOp2T8stCSSZhBIabJm7kpyXqLScSBIJLDKB0oGHjvE16KOqjrFRwNo5uS7AiX(yprkj4yNJ(xkesKvnGpyL2(nuiQMcc7CcaKruNgPoCOZHQHuzSSODWIHkvPs)Fq(ggunKkJLff2iMmzbaRL7LCk1PrQdh6COD)QM6i)qN7CD0fTdwmuPkv6)dY3WG29RAQJ8dDUZ1rxuyJyYKfaSwMIDfbu9ol)sJDowKDLAO4CzteG2aEde7gpsIgFpK95NYUGIKa5SY(1ODadZ0lfkj6JDlV0ehl78XMisMrMDLhSyOswb2nXXYostwitxT2VhgxTonssXURHe7J9ePKGJDo6FPqirw1a(GvA73qHOAkiSZjaqjRgRpYsP70iPzbasswitPZ3dJ0hgcUxwDA9)b5ByqnG3v6xinodOzuyJyYKtaSwUhc1y4reI1hQb8Us)cPXzanJ2blgQuLkrkHcrnaGKTlK(fsFak9GpaWUVKikLTArkHcrnaGKTlK(fsFak9GpaWUVKikSrmzYjawltPonsD4qNdvdPYyzr7GfdvQsL()G8nmOAivgllkSrmzYcawl3djPyxravVZYV0yNJfzxPgkox2ebOnG3aXUXJKOX3dzF(PSlOijqoRSljlKP057Hr2T8stCSSZhBIajmYSR8GfdvYkWUjow2rUr7agMu5vRtIcLe9TADAKKIDxdj2h7jsjbh7C0)sHqISQb8bR02VHcr1uqyNtaGswDA9)b5ByqnG3v6xinodOzuyJyYKtaSwUhc1y4reI1hQb8Us)cPXzanJ2blgQuLkrkHcrnaGKTlK(fsFak9GpaWUVKikLTArkHcrnaGKTlK(fsFak9GpaWUVKikSrmzYjawltPonsD4qNdvdPYyzr7GfdvQsL()G8nmOAivgllkSrmzYcawl3djPyxravVZYV0yNJfzxPgkox2ebOnG3aXUXJKOX3dzF(PSlOijqoRSFnAhWWm9sHsI(y3YlnXXYoFSjcJWiZUYdwmujRa7M4yzF)PKGJDUvRtVLIDxdj2h7Y)q7(vn1r(Ho356Ol6r07idy1Y)q7(vn1r(Ho356OlkSrmzYjawl3dHAzfPekenrkj4yNdf2iMm5eaRL7HGDfbu9ol)sJDowKDLAO4CzteG2aEde7gpsIgFpK95NYUGIKa5SYEIusWXoh7wEPjow25JnrKKmYSR8GfdvYkWUjow2t64DD16x4Q1cMb08Q1P3sXURHe7J90a(GvA73qHOAkiSZbeivQa8bR02VHcr1uqyNdOn1P1)hKVHbvmGLL(fsNiv(i6IcBetMSaG1svQ0)hKVHbvswitPbGJXcrHnIjtwaWAzkvQa8bR02VHcr1uqyNdieQtR)piFdd6(wCavdadb3mTqiwFKFWHeaceAsAevQ0)hKVHbvdPYyzH05ds2vunameCZ0cHy9r(bhsaiqOjPrsLIDfbu9ol)sJDowKDLAO4CzteG2aEde7gpsIgFpK95NYUGIKa5SYUb8Us)cPXzanZULxAIJLD(yteaZiZUYdwmujRa7M4yzxHaw2vRFHRwV)u5JO7Q1P3sXURHe7J90a(GvA73qHOAkiSZLaqiuN7rl(dvg9ifIaencBnqBQub4dwPTFdfIQPGWoxcaLS6CpAXFOYOhPqeGOryRbcuk2veq17S8ln25yr2vQHIZLnraAd4nqSB8ijA89q2NFk7ckscKZk7IbSS0Vq6ePYhrx2T8stCSSZhBIWOyKzx5blgQKvGDtCSSJ0KfY0vR3N4ySWvRtVLIDxdj2h7Pb8bR02VHcr1uqyNlbGqOo3Jw8hQm6rkebiAe2AG2uPcWhSsB)gkevtbHDUeakz15E0I)qLrpsHiarJWwdeOuSRiGQ3z5xASZXISRudfNlBIa0gWBGy34rs047HSp)u2fuKeiNv2LKfYuAa4ySq2T8stCSSZhBIyFWiZUYdwmujRa7M4yzFFIJXcxT(fUA9(tLpIUS7AiX(yVgDkITDLOBjdmOK0iQpmeCpuafhoaO26taGa2iQb8bR02VHcr1uqyNlbGqc7kcO6Dw(Lg7CSi7k1qX5YMiaTb8gi2nEKen(Ei7ZpLDbfjbYzLDa4ySq6xiDIu5JOl7wEPjow25JntgeJm7kpyXqLScSBIJL99Nsco25wTonIuSRudfNlBIa0gWBGyxqrsGCwzprkj4yNJDJhjrJVhY(8tzxravVZYV0yNJfz3YlnXXYoFSzYBmYSR8GfdvYkWUjow2nAuCGDxdj2h7Aayi4MbcH605E0I)qLrpsHiarJWwdei1a(GvA73qHOAkiSZLaqiuPknGpyL2(nuiQMcc7CjaesuNw)Fq(ggujzHmLgaoglef2iMmzbaRL7HqLk9)b5ByqfdyzPFH0jsLpIUOWgXKjlayTCpePuR)piFddAIusWXohkSrmzYcawl3drQuQuLo3Jw8hQm6rkebiAe2AG2ud4dwPTFdfIQPGWoxcaTPsvAaFWkT9BOqunfe25saiKOoT()G8nmOsYczknaCmwikSrmzYcawl3dHkv6)dY3WGkgWYs)cPtKkFeDrHnIjtwaWA5EisPw)Fq(gg0ePKGJDouyJyYKfaSwUhIuPyxravVZYV0yNJfzxPgkox2ebOnG3aXUXJKOX3dzF(PSlOijqoRSVVfhy3YlnXXYoFSzYiyKzx5blgQKvGDtCSSRiKkJLfUATFqYUYURHe7JDnameCZaHqD6CpAXFOYOhPqeGOryRbcKAaFWkT9BOqunfe25saieQuLgWhSsB)gkevtbHDUeacjQtR)piFddQKSqMsdahJfIcBetMSaG1Y9qOsL()G8nmOIbSS0Vq6ePYhrxuyJyYKfaSwUhIuQ1)hKVHbnrkj4yNdf2iMmzbaRL7HivkvQsN7rl(dvg9ifIaencBnqBQb8bR02VHcr1uqyNlbG2uPknGpyL2(nuiQMcc7CjaesuNw)Fq(ggujzHmLgaoglef2iMmzbaRL7HqLk9)b5ByqfdyzPFH0jsLpIUOWgXKjlayTCpePuR)piFddAIusWXohkSrmzYcawl3drQuSRiGQ3z5xASZXISRudfNlBIa0gWBGy34rs047HSp)u2fuKeiNv21qQmwwiD(GKDLDlV0ehl78XMjNmJm7kpyXqLScSBIJLDf)jxneFKFyxPgkox2ebOnG3aXUGIKa5SYU(NC1q8r(HDJhjrJVhY(8tzxravVZYV0yNJfz3YlnXXYoFSzYiHrMDLhSyOswb2nXXYostwitxT2VhgxToTrsXURHe7J9ePKGJDo6FPqirw1y9rwkDNgjnlaqsYczkD(EyK(WqW9YQfPekevswitPTPG2FUOu2SRiGQ3z5xASZXISRudfNlBIa0gWBGy34rs047HSp)u2fuKeiNv2LKfYu689Wi7wEPjow25Jnt2imYSR8GfdvYkWUjow2rAYcz6Q1(9W4Q1PtYuS7AiX(yprkj4yNJ(xkesKvnwFKLs3PrsZcaKKSqMsNVhgPpmeCVSArkHcrpaLwib2m9lKorQ8r0fLYwDAK6WHohQgsLXYI2blgQuLk9)b5Byq1qQmwwuyJyYKfaSwUxYPyxravVZYV0yNJfzxPgkox2ebOnG3aXUXJKOX3dzF(PSlOijqoRSljlKP057Hr2T8stCSSZhBMCsYiZUYdwmujRa7M4yzhPjlKPRw73dJRwNg4uS7AiX(yprkj4yNJ(xkesKvnwFKLs3PrsZcaKKSqMsNVhgPpmeCVSAaFWkT9BOqunfe25eaiKOonsD4qNdvdPYyzr7GfdvQsL()G8nmOAivgllkSrmzYcawl3djPyxravVZYV0yNJfzxPgkox2ebOnG3aXUXJKOX3dzF(PSlOijqoRSljlKP057Hr2T8stCSSZhBMmWmYSR8GfdvYkWUjow2rUr7agMu5vRtIcLe9TADAJKIDxdj2h7jsjbh7C0)sHqISQfPekevswitPTPG2FUOu2SRiGQ3z5xASZXISRudfNlBIa0gWBGy34rs047HSp)u2fuKeiNv2VgTdyyMEPqjrFSB5LM4yzNp2mzJIrMDLhSyOswb2nXXYoYnAhWWKkVADsuOKOVvRtNKPy31qI9XEIusWXoh9VuiKiRArkHcrpaLwib2m9lKorQ8r0fLYwDAK6WHohQgsLXYI2blgQuLk9)b5Byq1qQmwwuyJyYKfaSwUxYPyxravVZYV0yNJfzxPgkox2ebOnG3aXUXJKOX3dzF(PSlOijqoRSFnAhWWm9sHsI(y3YlnXXYoFSzY7dgz2vEWIHkzfy3ehl7i3ODadtQ8Q1jrHsI(wTonWPy31qI9XEIusWXoh9VuiKiRAaFWkT9BOqunfe25eaiKOonsD4qNdvdPYyzr7GfdvQsL()G8nmOAivgllkSrmzYcawl3djPuNgPoCOZH29RAQJ8dDUZ1rx0oyXqLQuP)piFddA3VQPoYp05oxhDrHnIjtwaWA5EisXUIaQENLFPXohlYUsnuCUSjcqBaVbIDJhjrJVhY(8tzxqrsGCwz)A0oGHz6LcLe9XULxAIJLD(ytKaIrMDLhSyOswb2nXXYUrJIdRwNElf7UgsSp2b8bR02VHcr1uqyNlbGqc7kcO6Dw(Lg7CSi7k1qX5YMiaTb8gi2nEKen(Ei7ZpLDbfjbYzL99T4a7wEPjow25JnrYgJm7kpyXqLScSBIJLDfHuzSSWvR9ds21vRtVLIDxdj2h7a(GvA73qHOAkiSZLaqiHDfbu9ol)sJDowKDLAO4CzteG2aEde7gpsIgFpK95NYUGIKa5SYUgsLXYcPZhKSRSB5LM4yzNp2ejiyKzx5blgQKvGDtCSSJ0KfY0vR97HXvRtBuPy31qI9XEIusWXoh9VuiKiRAaFWkT9BOqunfe25eaOKvJ1hzP0DAK0SaajjlKP057Hr6ddb3lRonsD4qNdvdPYyzr7GfdvQsL()G8nmOAivgllkSrmzYcawl3ZiPyxravVZYV0yNJfzxPgkox2ebOnG3aXUXJKOX3dzF(PSlOijqoRSljlKP057Hr2T8stCSSZhBIKKzKzx5blgQKvGDtCSSJCJ2bmmPYRwNefkj6B160gvk2DnKyFSNiLeCSZr)lfcjYQgWhSsB)gkevtbHDobakz1PrQdh6COAivgllAhSyOsvQ0)hKVHbvdPYyzrHnIjtwaWA5Egjf7kcO6Dw(Lg7CSi7k1qX5YMiaTb8gi2nEKen(Ei7ZpLDbfjbYzL9Rr7agMPxkus0h7wEPjow25Jp2r6ketfowb(yg]] )

    storeDefault( [[SimC Retribution: precombat]], 'actionLists', 20170328.1, [[b4vmErLxtvKBHjgBLrMxc51utbxzJLwySLMEHrxAV5MxoDdmEnLtH1wzEn1uP12q(bMuLrNCPjwD0L2BUPJFGbNCLn2BTjwy051usvgBLf2CL5LtYatm3aZmYGJlX41utnMCPbhDEnLxtf0y0L2BUnNxu5LtX4fvEnvrUfMySvgzEjKxtn1yYLgC051u092zNXwzUa3B0L2BUnNxtfKyPXwA0LNxtb3B0L2BU51uj5gzPnwy09MCEnLBV5wzEnLtH1wzEnfuVrxAV5MxtfKCNnNxt5wyTvwpI8gBK91DHjNiEnLuLXwzHnxzE5KmWeZnXaJxtneALn2An9MDL1wzUrNxI51un9gzofwBL51uI8gBK91DHjNiErNx051uevMzHvhB05LqErNxEb]] )

    storeDefault( [[Protection ST]], 'actionLists', 20170328.1, [[d8d4haGAfQA9Quv2eLOSluABIu7JsOoSsltHmBkMpLe(eLeDBu5BQuoVizNK0EL2ns7xfnkkPAyQW4uO0Pv1qPeYGvjdNeoij6uus5yq15OeWcPuTukLflILJ4HusQNs8yHEoPMiLanvfmzbtNQlQO8Akr1ZuuDDf5YGvrjsBgfTDvQ8zu1FHY0OeK5rjIrsjjFhfA0IA8ku5KOGBPqHRPsv19uPkRuHI(nKFsjOU4DOYm6MyGqTxrIKxHxPIfeyUtgV2ROUCqflIGCi6pIEEjdvSbgy1qvhDGF7y(OXYIxXgSHudphuX6NxreYeqmsz15hmbmetmpdyKNp7aAsZgZlHh0yC74oVgJZRiczcigPS68dMagIjMNbmYZNDanPzJ5LWdAmMKn6pIUMZlRDEzPNxB0FeLvNFWeWqmX8mGrE(SdOjnlbI5LWdvug9hr1DOQ4DOYm6MyGqTxXgyGvdvD0bEA8BShZXRirYRWR4phCVJkkj86k0LdUhYeWyCjvuM8M3tvrbYFeTcd0WhxhrQqruOI6YbvSiK)iAL1DshQxVQJ6qL1DshQxrIKxHxXr88gG9PoqitkCDf1LdQydsMSCOInWaRgQ6Od8043ypMJxHbA4JRJivOikurzYBEpvfcKmz5qLz0nXaHAVEvN3HkR7KouVIejVcVsYetMS8KLgWIKj9gac7KclZxdqD2izsVbGOXg)uGNdOolq3edeSSiczcigPSJFkWZbuNnMxcpOTe8kQlhur5DaLhiwP(8sYpycvSbgy1qvhDGNg)g7XC8kmqdFCDePcfrHkktEZ7PQS3buEGOX05hmHkZOBIbc1E9QAH6qL1DshQxrIKxHxzJ(FhGbuG7bTfJxXgyGvdvD0bEA8BShZXROm5nVNQser1qKS(JOvyGg(46isfkIcvuxoOIvJOAisw)r0ZlRR0cpZAvMr3edeQ96v9(7qLz0nXaHAVIejVcVseHmbeJuwD(btadXeZZag55ZoGM0SX8s4b99IiKjGyKYQZpycyiMyEgWipF2b0KMnMxcpOX42XvrzYBEpvfD(btadXeZZag55ZoGM0vyGg(46isfkIcvugUBPriu7vuxoOIKFWeoVqmpV8mCEz75ZoGM0vSbgy1qvhDGNg)g7XC8k2GnKA45Gkw)8kIqMaIrkRo)GjGHyI5zaJ88zhqtA2yEj8GgJBh351yCEfritaXiLvNFWeWqmX8mGrE(SdOjnBmVeEqJXKSr)r01CEzTZll98AJ(JOS68dMagIjMNbmYZNDanPzjqmVeEOIejVcFiLcOI)CqL1DshQxVQP7qL1DshQxrIKxHxPI6YbvgZPaphq9k2adSAOQJoWtJFJ9yoEfgOHpUoIuHIOqfLjV59uvg)uGNdOELz0nXaHAVEvV1HkZOBIbc1Ef1LdQy3aAneoVSQLJdivKi5v4vcqYetMSjgqRHawE54aclb42NQTKXAfwreHmbeJu2edO1qalVCCaHnMxcpOTy8kkj86kvSbgy1qvhDGNg)g7XC8kmqdFCDePcfrHkktEZ7PQKyaTgcy5LJdivw3jDOE9Qo2ouzDN0H6vKi5v4vQOUCqfRgr1qKS(JOvSbgy1qvhDGNg)g7XC8kmqdFCDePcfrHkktEZ7PQerunejR)iALz0nXaHAVEvTaDOY6oPd1RirYRWRurD5GkkVdO8aXk1Nxs(bt48Y64wRInWaRgQ6Od8043ypMJxHbA4JRJivOikurzYBEpvL9oGYdenMo)GjuzgDtmqO2Rxv8JouzDN0H6vKi5v4vQOUCqfRA54aY5fI55LNHZlBpF2b0KUInWaRgQ6Od8043ypMJxHbA4JRJivOikurzYBEpvL8YXbemetmpdyKNp7aAsxzgDtmqO2RxVIOaI)A(7B9hrRA601Bb]] )

    storeDefault( [[Protection Defensives]], 'actionLists', 20170328.1, [[datAcaGEQQQnPq1UKeBJOmtQkA2K6Bss7KG9k2nf7NqJIQkgMc(TQgQkvdMidNQCqjvNIQkDmfTqkXsPuTyvYYj5PqldjEUetuHYuPstgPMoQlQqEgLY1rsBMk2ovv5ZusxgmsQk5Xsz0s1HrCsvkVMQcNwPZlPCBIQXrvP(RkoZ4gCKHCPb6yji2uRhhm4yGdHQMJLG2bnqkqeOmmRoyJIVRmdIEqBj61)eEFteKjly9gVVPe3imJBWrgYLgOJLGytTECqMy8XASoo1cCk9f00bfiYHGyFbnTO07ikXDquY(ATZWtTik5NPFdw)A1lxlyPVGM(8ohUdh1ATZWtTe0oObsbIaLHPSz1kd2MbVzO3gHFvqZBGGeMvXnCqSPwp2TMheSSYBHJaL4gKWSkUHdkqKdb9fXqlk9oIsCheLUREgA8RcIn16XbPwGtb0oNoq0bTdAGuGiqzykBwTYGTzWBg6Tr4xf08giy9RvVCTGDIH(8ohUdhp1ZqJFvWrgYLgOJLWrWwCdsywf3WbfiYHG(CT2zrP3ruI7GO0D1ZqJFvqSPwpoi1cCkG250bIoODqdKcebkdtzZQvgSndEZqVnc)QGM3abRFT6LRfuVw785DoChoEQNHg)QGJmKlnqhlHdhuGihcEx9m049nIsJboGPS(dkHta]] )

    storeDefault( [[Protection Cooldowns]], 'actionLists', 20170328.1, [[b4vmErLxtvKBHjgBLrMxI51utnMCPbhDEnLxt5uyTvMxtbLCVrxzJrxAV5MFGn0BVXgzVDNBZ51usvgBLf2CL5LtYatm3aZmYGJlX41utbxzJLwySLMEHrxAV5MxozJnEnvqJrxAV52CErLx051uevMzHvhB05LqErNxEb]] )

    storeDefault( [[Protection Default]], 'actionLists', 20170328.1, [[d0IwcaGEQiTlfQTrf1Sv1nbv(gvLDQO9k2Tu7xjnmf8BsdvfnyLYWPchKQ0XOOfsblvHSyvy5GSiuQNc9yu9CknrQutvPAYQ00jUivvxg56OiBMcTDuuFMQ47OGLHsomWZOsCsuOBdkNwY5bv9xLyCur8qQKoMzpO)gC80ngc6Mmcy6Lyii6G4f4lNcKs7mD25GJONawktwdM(gCHLtgBge5qLdjyqVCP02M9mnZEq)n44PBmeCcGrbpHuH4sP96MBYi12IzYge5qLdjOOE880yMS0YLmsTTyMSbhrpbSuMSgm9zoeKX(wCGOqbBTPGEpQVe4dYb)Va4sP9YxwjiC6DcGrbzFcPcXLs71n3KrQTfZKLDKmzL9G(BWXt3yi4eaJcEcPcXLs71nxv9VkdTniYHkhsqr945PXCv)RYqBdoIEcyPmzny6ZCiiJ9T4arHc2Atb9EuFjWhKd(FbWLs7LVSsq407eaJcY(esfIlL2RBUQ6FvgAl7iz6s2d6VbhpDJHGtamk4jKkexkTx3W9GihQCibdoIEcyPmzny6ZCiiJ9T4arHc2Atb9EuFjWhKd(FbWLs7LVSsq407eaJcY(esfIlL2RB4o7ircobWOGNqQqCP0EDZnzeW0lrsa]] )


    storeDefault( [[Retribution Primary]], 'displays', 20170328.1, [[dWt9haGEvrVePODHIeVgfXmLaZwPomv3ePWLv52K0YKq7KI9k2nQ2Vs8tvvdJunouu48uYqjYGvsdhjhuQCuuu0XKOJlbTqPQLkfTyuA5eEij8uWJjQNlPjQkutfQMmkmDfxuv6QKs8mvHCDOSrPWPrSzk12jrFuvWNrQMgPK(UQYijLQVrkLrlLgpsPtskUfks11qrP7HIKwhkQwlks53qoLbpGStneeVbIpWyTVa)AbVanM3aJlOFJKsPWgq4C6NI2tMjPpqHyh21Tj05QhFcihW632UEJcNAiiEng9a0(BBxVrHtneeVgJEakbr1fwAKrCG88IrR6bQTOVomHRHBJcBGcXoSJHcNAiiEn9bS(TTR3G7c63uJrpaZe7WUAWJPm4bE5o7(yK(aDYdbXxwlGuNykgW4QxaGOQyzT5nccl2qqCMVSsjozKkRpbAE7ZRxmf1l1MEPUEaqwqOMadr9yQ6zIPyWd8YD29Xi9b6KhcIVSwaPoXugW4QxaGOQyzT5nccl2qqCMVSY4SDS9eO5TpVEXuuVuB6L66zYeG2FB76n4UG(n1y0dqKrCGYLjC6XWSbCmHRHBJWTOUaSy22bSIHPxuR6bOng9a08SyjCgeo9LvyS2xmfdWe2oUClsea)xQPMh0oEazKkRpskFdBazNAiiEhxUfjc0)JJ)tJaa1jt8n5PpeepgTPhO2I(a80hOqSd7EmrCYdbXd0uZdAhpahtvJmIxJrRbQu3E3y71wfOnse8aEmLbyJPma9ykdiIPmtGAl6tHtneeVM(a0(BBxVPdt4XOhWXeoUf1fGfZ2oGQtBh2GIrpGVPA9U9NBvLu(gtzaFt16ql6ts5BmLb8nvRRaPY6JKY3ykd84Z2X2t6d47p3QkPuk9busQewYMmw4wuxa2aYo1qq8UnHopGIxd(BZamivQTBHBrDbyeq4C6hUf1fWzjBYyfWXeoni8l9bmU6fO5nccl2qq8Lvjbr1fwbycBdeFaYZlMYIbuGOSwwXrbKeO5KhcIVSkjiQUWkGKGO6cRLvfo1qq8L1omHhiG1VTD9gnCgezFqIAm6be3oGIxd(BZavQBVBS9AByd4BQwh3f0Vrs5BmLbSr8jqNG47LvJleOVafIDyhdnCgezFqIA6dmUG(nDC5wKiq)po(pnAQ5bTJhGiJ4mnesnMsMnW4c630aXhyS2xGFTGxGgZBaA40suXuxwXjQxmpspqTf9H7c63utFaqwqOMab8nvR3T)CRQKsPykdui2HDm0iJ4a55fJw1dqjiQUWQbIpa55ftzXauItgPY6tNubbaIQIL1M3iiSydbXz(YkL4KrQS(eq1PfWJPmGQtB3Bm6bW99XNL1heimQykdmUG(nskFdBGAl6JMNflHZGWPxtFajbr1fwlRkCQHG4bgxq)MAacNbr2hKOJl3IebAQ5bTJhqLW7Wgum6bKDQHG4nq8bipVyklgW3uToUlOFJKsPykd4BQwhArFskLIPmqTf9PHZGi7dsutFGAl6R7n9b89NBvLu(M(a(MQ1vGuz9rsPumLbQTOpjLVPpGmsL1hjLsHnatyBG4taj8LvW51LvJleOVaw)221BOzFng9amHTbIpWyTVa)AbVanM3aQeoGhJEGXf0VPbIpa55ftzXa1w0NKsP0hq2PgcI3aXNas4lRGZRlRgxiqFbCmHdu3ER5XXOh4L7S7Jr6dujQu7R7)nMIbS(TTR30Hj8y0dq7VTD9gA2xJrpGkH39gZJcW4SDS90jvqaGOQyzT5nccl2qqCMVSY4SDS9eO5TpVEXuuVuB6pQiZGPugGDtE(8Hn6lSby3KNpFyJ(627WgO2I(6Wgu6d4ycVJl3Ieb6)XX)PrbVnWdui2HDmAG4dqEEXuwmW4c630aXNas4lRGZRlRgxiqFbke7Wog0SVM(a0(BBxVrdNbr2hKOgJEaht4AHtMauB36ezsaa]] )

    storeDefault( [[Retribution AOE]], 'displays', 20170328.1, [[d8J)haqyjRxj6LOG2fqWRrbUnfntsQEgqQzlvNNkUjHWPr8ncjDicr1oj1Ef7gv7xj9tvLHPknocj6CeIYqPKbRugosDqP4Oar1XOWXPszHQILsLSyuA5e9qsYtHEmbpNQMiqOPIKjJIMUIlQuDvskDzvUoGnQewgjSzk12jrFKkvFgOMgqKVRQAKKuSocPgTuA8OqNKqDlcjCnGK7risBIqeRfik)g0Xiubfk6Ha5lG8bhN(f8tTuQlwVhCkj4BSuAf2GYId(u1EcmipbDd4aUMobm384tqHGoF22(Buv0dbY9r)gKXpBB)nQk6Ha5(OFdsljML0rSaKJKLx0G0BqtcVzpAqh0nGd4yQQOhcK7ZtqNpBB)nuLe8n(OFdcYboGZhQOncvWDEX2pM5jyJWqG81n1j(jAfb1L5fejMQw3CDJKWcmeix0RB0YtaAYwtqxx)k)fTIxdqzyackuyeefKe6j4qmpr6BMOveQG78ITFmZtWgHHa5RBQt8t0gb1L5fejMQw3CDJKWcmeix0RBmp7cOpbDD9R8x0kEnaLHbiOqHrMmbz8Z22FdvjbFJp63GebihPlbchC0GkybilXCBiLd9fKfW2oOt0IcdrgOcYy0Vbz45Ws4mjCWRB440VOveKbSnCHwOmi1NLlXURgQGcqt2ASuUh2Gcf9qG8gUqlug85JI6tebvbPDw3OGbDDJKWcmeiFDR5BpOVf(Ju5jOBahWbIe5jmeipOlXURgQGCatXcqUpAqkON(69f9Y3Qc2HYqfSI2iOmAJGGJ2iiB0gzc6BH)Qk6Ha5(8eKXpBB)nnaYk63GfGSOCOVGSa22bnlgBagy0VbRoDB10)lhVLY9OncwD62cBH)wk3J2iy1PBlvqt2ASuUhTrqDzEbDDJKWcmeiFDR5Bpy1)lhVLsR8eujXtyjDY4q5qFbzdku0dbYB6eW8GQ21u7UcYK4P7LdLd9fuiOS4Gpkh6lyXs6KXjybilrq4xEccINDb0N8eKbSlG8bjlVOnue0KWBagy0GoOLKywsN1nvf9qG81TgazfmiJF22(BeZzseQbk9r)guE9GQ21u7Uc6PVEFrV8THny1PBlQsc(glL7rBeCkj4Bwa5tqlQ1nS4(1nDjLW)GUbCahtXCMeHAGsFEcoLe8nnCHwOm4Zhf1NiCj2D1qfKia5Gmi0mAdqfCkj4Bwa5doo9l4NAPuxSEpOikgjMaMRBueZlAq)g0gYNGnss1x30Luc)dIcsc9e0t4G7NirKxadmy1PBRM(F54TuAfTrqFl8NQKGVXNNG0sIzjDwa5dswErBOiiT8eGMS10yPEqKyQADZ1nsclWqGCrVUrlpbOjBnbnlgrQOFdAwm2Sh9BqQQF8zDZDjeGo63GtjbFJLY9Wg03c)z45Ws4mjCW(8e011VYFrR41quFbTcrjiyeS60TfvjbFJLsROncs4mjc1aLnCHwOmOlXURgQGcf9qG8fq(GKLx0gkc6gWbCmfla5iz5fni9gS60Tf2c)TuAfTrqFl8xmNjrOgO0NNG(w4FZEEcw9)YXBPCppbRoDBPcAYwJLsROnc6BH)wk3ZtqbOjBnwkTcBqgWUaYNGwuRByX9RB6skH)bD(ST93WWhF0Vbza7ciFWXPFb)ulL6I17bnjCKkAqhCkj4Bwa5dswErBOiOVf(BP0kpbfk6Ha5lG8jOf16gwC)6MUKs4FWcqwi917IbXOFdUZl2(Xmpb9et6(18ThTIGoF22(BAaKv0Vbz8Z22FddF8r)g03c)BagyydY8SlG(0yPEqKyQADZ1nsclWqGCrVUX8SlG(e0ssmlPZ6MQIEiqEWPKGVXhKTtwU09o8VP3dBq2oz5s37W)Wg03c)BaKLyUnmSblaz1WfAHYGpFuuFIq99fubDd4aoMlG8bjlVOnue05Z22FJyotIqnqPp63GUbCahtg(4ZtqK(eivNSSgcKhTO(gSaKLA5KjiDVCozMe]] )

    storeDefault( [[Protection Primary]], 'displays', 20170328.1, [[dSZiiaGEvsVer0UiL0RreMjbA2Q4MisoSKVjku)wv7KK9sTBuTFi5NqQHrQgNOqSmrLHIudgIgochuQCuvIQJjWXffTqPQLsalwilNOhkk9uWJHQNlYerKAQqzYiPPR4IQuxLuIlR01j0gfv9zKyZc12jOpQs40OmnefFhcJuuWZiLA0sPXJO6KKIBjkKUMkroVG2gIsRvLOCBPyhymd4fXWEE(NpWeEwdO1cMGAu3gMsszhAH0oYGS4u2STlojCVHmfxXT7WOWBw(ya3qi6440ozlIH98Kv6gihDCCANSfXWEEYkDdeswtjd1G)CGDDTIm6gsTpIorzPHh)oYqMIR4snBrmSNNCVHq0XXPDWkjLDswPB4YfxXnzmRcmMHBEfDwQU3qh(WEokKcYsJvKXGQAwd0YFw8H9Cuij9gV8et4MmiWE2kTwLtpGSb66AR1adaUKrmg8yvoJz4MxrNLQ7n0HpSNJcPGS0y1LmOQM1aT8NfFyphfYS)FO(i4jdcSNTsRv50diBGUU2AnWaGlzeJbpwPTXmCZROZs19g6Wh2ZrHuqwASsBdQQznql)zXh2ZrHeWmiWE2kTwLtpGSb66AR1adaUKrmg84Xa5OJJt7Gvsk7KSs3ad)5arHZ4uS6sgkrzPHh)yHeRHiX4ydHwLrZrgDdKBLUbsUHrmovgNckKWeEwRYzGerDC82xAadnTaAUidygW)MOAOfE7id4fXWEEhhV9Lg6rJHHMugaIfNvh21Ayp3kYswdP2hbG5EdzkUIlPzYfFyp3GaAUidyg4InAWFEYkYyirSNt(tLAZ(NxAmdLvbgISkWafRcmiTkWJHu7JiBrmSNNCVbYrhhN2PtuwwPBOeLfwiXAismo2qtrEN48wPBOoeTv3brfMOfEBvGH6q0wq7JGw4TvbgQdrBL9BIQHw4Tvbgi9gxINX9gQdIkmrlK29geYsSi2HnHyHeRHid4fXWEE3HrHBi7Tc7waduzjItfIfsSgOAqwCklwiXAOIyh2eAOeLfPy819guvZAGw(ZIpSNJcjTK1uYqdKik)ZhGDDTkiNHSprikKyVbA5pl(WEokK0swtjdnqlznLmefYSfXWEokKDIYYGHq0XXPD0WPYWR5LjR0ni3JHS3kSBbmKi2Zj)PsToYqDiAlSsszhAH3wfyi(5JHojRoOqQkP8ryitXvCPQHtLHxZltU3Wusk70XXBFPHE0yyOjLaAUidygy4p)Y(VXQGlzykjLDY)8bMWZAaTwWeuJ62aPkYznInOqIXAwR0w3qQ9rGvsk7KCVbaxYigdgQdrB1DquHjAH0wfyitXvCPQb)5a76Afz0nqiznLmm)ZhGDDTkiNbc5I)nr10rlOv6gAkYbmRcm0uK3DBLUbS6S8bfYlKViHv6gMsszhAH3oYGa7zR0Avo9Gmwx7CzeTgyGwYAkzikKzlIH9CdtjPStYaJtLHxZl744TV0GaAUidygQdrBHvsk7qlK2QadnmEN48wPBaVig2ZZ)8byxxRcYzOoeTf0(iOfsBvGHu7JqdNkdVMxMCVHu7JO729gQdIkmrl829gQdrBL9BIQHwiTvbgsTpcAH3U3a(3evdTqAhzGer5F(yGgdfsO4juivLu(imeIoooTdj7twPBGer5F(at4znGwlycQrDBOHXbmR0nmLKYo5F(aSRRvb5mKAFe0cPDVb8Iyypp)Zhd0yOqcfpHcPQKYhHHsuwaXEoAiTv6gU5v0zP6EdjwdXz7qFBvodHOJJt70jklR0nqo6440oKSpzLUHggV72kTnqDJlXZ0rlObA5pl(WEokKKEJlXZyi1(ii5ggX4uzCkj3Bi6WUE9IZJWrgIoSRxV48i6ohhzi1(i6eN39gkrz1XXBFPHE0yyOjLG35XmKP4kUuZ)8byxxRcYzykjLDY)8XangkKqXtOqQkP8ryitXvCPsY(K7nqo6440oA4uz418YKv6gkrzPfoBmqCQWv6Xg]] )


end
