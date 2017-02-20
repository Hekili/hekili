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
        addAura( 'blessing_of_freedom', 1044, 'duration', 8 )
        addAura( 'blessing_of_protection', 1022, 'duration', 10 )
        addAura( 'blessing_of_sacrifice', 6940, 'duration', 12 )
        addAura( 'blessing_of_spellwarding', 204018, 'duration', 10 )
        addAura( 'blinding_light', 115750, 'duration', 6 )
        -- addAura( 'consecration', 188370, 'duration', 8 )
        addAura( 'crusade', 224668, 'max_stack', 15 )
        addAura( 'divine_hammer', 198137 )
        addAura( 'divine_purpose', 223819 )
        addAura( 'divine_shield', 642, 'duration', 8 )
        addAura( 'divine_steed', 221883, 'duration', 3 )
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
                return x * 0.75
            end
            return x
        end )

        addHandler( 'hammer_of_justice', function ()
            applyDebuff( 'target', 'hammer_of_justice', 6 )
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

    storeDefault( [[SimC Retribution: default]], 'actionLists', 20170201.1, [[dyeqNaqiqOwKqbTjkLpjuOrjQCkrvRcvr7cuddfDmkYYiKNrHAAcLUgLGTrjuFdenoqQZjuuToufunpkr3dvP9rOCquQwikLhIQYervOlsOAJOkOmsHI0jPqwPqbUjfStsmuufKwkQQEkvtfKSvkH8vHIYArvqSxK)ssdwu6WalgvEmPMmrxwAZOWNrjJwbNgQvdcETq1SfCBr2Ts)wLHlKJluelhYZv00v11jy7k03POgpQcCEkvRheY8PK2VOyYebf5IVaUqLeBK7rvJbbmebE8TKcKmjNhldGq4j2iN)gkywsrettqY0KjMWMi31iC0to5SRF8TtcksXebf5IVaUqLeBKRasLC(lNq8sURr4ON8)yXkuy8(fHeI(j58nuDCd3ytDFIJC(BOGzjfrmnbjtOj3OvI1G)qKV3wYzNdhWVDYrLtiEj3WjvaPso9KIickYfFbCHkj2i31iC0t(FSyfkC094BN2YLJtGbdyUWDYGW8HfISALtGbdyWyxw4LLQze4hGfISALtGbdynsycKfwiYgNadgWAKWeilmQjaENwkYcwT(aeR(Wpov1)uL4AjVXYmFEYzNdhWVDYJUhFl5gTsSg8hI892sUcivY5HEp(wYzhXAs(csL3y4fKQMbOyi583qbZskIyAcsMqtoFdvh3Wn2u3N4i3WjvaPsEm8csvZaumKEsXyckYfFbCHkj2ixbKk5SfUtMjlpmbKDYDnch9K)hlwHcRVlipZ7KC(gQoUHBSPUpXro)nuWSKIiMMGKj0KB0kXAWFiY3Bl5SZHd43o5CH7KQmeq2j3WjvaPso9KsSeuKl(c4cvsSrUcivYzROzrXXllYDnch9K)hlwHcRVlipZ7KC(gQoUHBSPUpXro)nuWSKIiMMGKj0KB0kXAWFiY3Bl5SZHd43o5CfnlkoEzrUHtQasLC6jflqqrU4lGlujXg5kGujNDKgSntwOoeQ7tURr4ON8)yXkuy9Db5zEN2YnCb7QrN5IG1ciu33slylhNadgWAKWeilSqKvRCcmyadg7YcVSunJa)aSqKvRpovlfLpp58nuDCd3ytDFIJC(BOGzjfrmnbjtOj3OvI1G)qKV3wYzNdhWVDYbinyR6Fiu3NCdNubKk50tkwmbf5IVaUqLeBKRasL8yGGKvQ7tURr4ON8hNQLIiNVHQJB4gBQ7tCKZFdfmlPiIPjizcn5gTsSg8hI892so7C4a(TtoeeKSsDFYnCsfqQKtpPajbf5IVaUqLeBKRasLC2cazZK9yKjBmqy(yDj31iC0t(Jt1sr2Y1yIaokQsytgdjZyH2QveqxyUWDs1gyKNC(gQoUHBSPUpXro)nuWSKIiMMGKj0KB0kXAWFiY3Bl5SZHd43o5CbGSQhdviimFSUKB4KkGujNEsbAckYfFbCHkj2ixbKk58iEeVnt2ykiLkICxJWrp5povlfzlxJjc4OOkHnzmKmJfARwraDH5c3jvBGrEY5BO64gUXM6(eh583qbZskIyAcsMqtUrReRb)HiFVTKZohoGF7KlXJ4TQdGuQiYnCsfqQKtpPeZjOix8fWfQKyJCfqQKhZaXBMShJmzzFo0j5UgHJEYhUGD1OZCrWAbeQ7BjVMS94uTue58nuDCd3ytDFIJC(BOGzjfrmnbjtOj3OvI1G)qKV3wYzNdhWVDYndIx1JHkyo0j5goPcivYPNumXKGICXxaxOsInYvaPsEm9c2ZKnMHa)a5UgHJEY)JfRqH13fKN5DsoFdvh3Wn2u3N4iN)gkywsrettqYeAYnALyn4pe57TLC25Wb8BN8Hlyx1mc8dKB4KkGujNEsXKjckYfFbCHkj2ixbKk5Sp2LfEzLjBmdb(bYDnch9K)hlwHcRVlipZ7KC(gQoUHBSPUpXro)nuWSKIiMMGKj0KB0kXAWFiY3Bl5SZHd43o5GXUSWllvZiWpqUHtQasLC6jftIiOix8fWfQKyJCfqQK7d4gKzYEmYK1I6YQGvxY5VHcMLueX0eKmHMC25Wb8BN85aUbP6XqDSlRcwDj3OvI1G)qKV3wY5BO64gUXM6(eh5goPcivYPNumzmbf5IVaUqLeBKRasLC(qctGSK7Aeo6j)pwScfwFxqEM3PTCdxWUA0zUiyTac19fJxlydIBmrahfvjSjJHKzSqB1AUCnMiGJIQe2KXqYmwOTAfb0fMlCNuTbg5T94uTuKvRpovXezB4c2vJoZfbRfqOUVy8gB(8KZ3q1XnCJn19joY5VHcMLueX0eKmHMCJwjwd(dr(EBjNDoCa)2jxJeMazj3WjvaPso9KIPyjOix8fWfQKyJCfqQKlopOAHhFBMSE3VRUK7Aeo6jhOF8yv72eUtl51yB503fKN5fgccswPUpmQjaENwYsl5zSWwSfSAvwobgmGHGGKvQ7dJAcG3PyS0sEglSfBH82YbXpi09H1iHjqw4UaUqLwTQVlipZlSgjmbYcJAcG3PyS0sEkkp58nuDCd3ytDFIJC(BOGzjfrmnbjtOj3OvI1G)qKV3wYzNdhWVDYlpOAHhFR6S73vxYnCsfqQKtpPyYceuKl(c4cvsSrUcivY5r8iEBMS(FOe5UgHJEYHGGKvQ7REJfHWYAdOF8yv72eUtX4vKnobgmGL4r8w1ibu0nlSqKnobgmGL4r8w1ibu0nlmQjaENwYsl5PiY5BO64gUXM6(eh583qbZskIyAcsMqtUrReRb)HiFVTKZohoGF7KlXJ4TQZ)qjYnCsfqQKtpPyYIjOix8fWfQKyJCfqQKZJ4r82mz9)qPmzZzkp5UgHJEYHGGKvQ7REJfHWYAdOF8yv72eUtX4vKTHlyxn6mxeSwaH6(IXRfSXjWGbSepI3QgjGIUzHfIiNVHQJB4gBQ7tCKZFdfmlPiIPjizcn5gTsSg8hI892so7C4a(TtUepI3Qo)dLi3WjvaPso9KIjijOix8fWfQKyJCfqQKZJ4r82mz9)qPmzZjkp5UgHJEYHGGKvQ7REJfHWYAdOF8yv72eUtX4vKTHlyxn6mxeSwaH6(IXRX24eyWawJeMazHfISLJtGbdynsycKfE(aDClnzbRw5eyWaMlCNmimFyHO8KZ3q1XnCJn19joY5VHcMLueX0eKmHMCJwjwd(dr(EBjNDoCa)2jxIhXBvN)HsKB4KkGujNEsXe0euKl(c4cvsSrUcivY5r8iEBMS(FOuMS5mop5UgHJEYHGGKvQ7REJfHWYAdOF8yv72eUtX4vKTHlyxn6mxeSwaH6(IXRfSLdIFqO7dRrctGSWDbCHkTAvFxqEMxynsycKfg1eaVtXyPL8048KZ3q1XnCJn19joY5VHcMLueX0eKmHMCJwjwd(dr(EBjNDoCa)2jxIhXBvN)HsKB4KkGujNEsXumNGICXxaxOsInYvaPsounffaOyCMjRfvKeRFYDnch9KdbbjRu3x9glcHL1gNadgWs8iERAKak6MfwiYgNadgWs8iERAKak6Mfg1eaVtlzPL8ue58nuDCd3ytDFIJC(BOGzjfrmnbjtOj3OvI1G)qKV3wYzNdhWVDY)MIca0uDSijw)KB4KkGujNEsretckYfFbCHkj2ixbKk5q1uuaGIXzMSwursS(ZKnNP8K7Aeo6jhccswPUV6nweclRTHlyxn6mxeSwaH6(IXRfSXjWGbSepI3QgjGIUzHfIiNVHQJB4gBQ7tCKZFdfmlPiIPjizcn5gTsSg8hI892so7C4a(Tt(3uuaGMQJfjX6NCdNubKk50tkImrqrU4lGlujXg5kGujhQMIcaumoZK1IksI1FMS5eLNCxJWrp5qqqYk19vVXIqyzTnCb7QrN5IG1ciu3xmEn2gNadgWAKWeilSqKTCCcmyaRrctGSWZhOJBPjly1kNadgWCH7KbH5dleLNC(gQoUHBSPUpXro)nuWSKIiMMGKj0KB0kXAWFiY3Bl5SZHd43o5FtrbaAQowKeRFYnCsfqQKtpPisebf5IVaUqLeBKRasLCOAkkaqX4mtwlQijw)zYMZ48K7Aeo6jhccswPUV6nweclRTHlyxn6mxeSwaH6(IXRfSLdIFqO7dRrctGSWDbCHkTAvFxqEMxynsycKfg1eaVtXyPL80482YbXpi09HlpOAHhFR6S73vx4UaUqLwTQVlipZlC5bvl84BvND)U6cJAcG3PyS0Y8KZ3q1XnCJn19joY5VHcMLueX0eKmHMCJwjwd(dr(EBjNDoCa)2j)Bkkaqt1XIKy9tUHtQasLC6jfrgtqrU4lGlujXg5kGujNhXJ4TzY6)HszYMl28K7Aeo6jhccswPUV6nweclRTHlyxn6mxeSwaH6(IXRX2a6hpw1UnH7umEfzlN(UG8mVWMbXR6Xqfmh6eg1eaVtlzPL8uKna6Xma6h2miEvpgQG5qNWDbCHkTALtGbdyZd4zurQhd1FOQl4hqfIWjyHiBCcmyaBEapJks9yO(dvDb)aQqeobJAcG3PLS0Y82YbXpi09H1iHjqw4UaUqLwTQVlipZlSgjmbYcJAcG3PyS0sEgBEY5BO64gUXM6(eh583qbZskIyAcsMqtUrReRb)HiFVTKZohoGF7KlXJ4TQZ)qjYnCsfqQKtpPikwckYfFbCHkj2ixbKk5q1uuaGIXzMSwursS(ZKnxS5j31iC0toeeKSsDF1BSiewwBdxWUA0zUiyTac19fJxJTLtFxqEMxyZG4v9yOcMdDcJAcG3PLS0sEkYga9yga9dBgeVQhdvWCOt4UaUqLwTYjWGbS5b8mQi1JH6pu1f8dOcr4eSqKnobgmGnpGNrfPEmu)HQUGFavicNGrnbW70swAzEB5G4he6(WAKWeilCxaxOsRw13fKN5fwJeMazHrnbW7umwAjpJnp58nuDCd3ytDFIJC(BOGzjfrmnbjtOj3OvI1G)qKV3wYzNdhWVDY)MIca0uDSijw)KB4KkGujNEsrKfiOix8fWfQKyJCfqQKhdeKSsD)mzZzkp5UgHJEYL3dxEq1cp(w1z3VRUWpwhhVSSjVhU8GQfE8TQZUFxDHrnbW70swAjpfztwobgmGHGGKvQ7dJAcG3PLS0sEkIC(gQoUHBSPUpXro)nuWSKIiMMGKj0KB0kXAWFiY3Bl5SZHd43o5qqqYk19j3WjvaPso9KIilMGICXxaxOsInYvaPsEmdeVzYEmYKL95qNzYMZuEYDnch9KpCb7QrN5IG1ciu3NxMwToCb7QrN5IG1ciu3Nxt2YPVlipZlmxaiR6XqfccZhRlmQjaENIXslTAvFxqEMxyjEeVvDaKsfbJAcG3PyS0Y8wToCb7QrN5IG1ciu3Nxr2YPVlipZlmevqawpaqS6uLbcOF8TGGL8Ye2ITGvR67cYZ8cRrctGSi15JWXlSEaGy1Pkdeq)4Bbbl5LjSfBH8KZ3q1XnCJn19joY5VHcMLueX0eKmHMCJwjwd(dr(EBjNDoCa)2j3miEvpgQG5qNKB4KkGujNEsreKeuKl(c4cvsSrUcivY5r8iEBMSXuqkvuMS5mLNCxJWrp5dxWUA0zUiyTac19TKxJTXjWGbS5b8mQi1JH6pu1f8dOcr4eSqKnobgmGnpGNrfPEmu)HQUGFavicNGrnbW7umwAPnobgmGnpGNrfPEmu)HQUGFavicNGrnbW70swAjpn2geeKSsDF1BSiewwBYYjWGbmeeKSsDFyuta8ofJLwYtrKZ3q1XnCJn19joY5VHcMLueX0eKmHMCJwjwd(dr(EBjNDoCa)2jxIhXBvhaPurKB4KkGujNEsre0euKl(c4cvsSrUcivYzlaKnt2JrMSXaH5J1nt2CMYtURr4ON8Hlyxn6mxeSwaH6(wYRXKZ3q1XnCJn19joY5VHcMLueX0eKmHMCJwjwd(dr(EBjNDoCa)2jNlaKv9yOcbH5J1LCdNubKk50tkII5euKl(c4cvsSrUcivY5HuqGCxJWrp56baIvN8kY2WfSRgDMlcwlGqDFl5nwY5BO64gUXM6(eh583qbZskIyAcsMqtUrReRb)HiFVTKZohoGF7Kdrfei3WjvaPso9KIXmjOix8fWfQKyJCfqQKZhsycKfLjR)iC8sURr4ONC9aaXQtEfzB4c2vJoZfbRfqOUVL8gl58nuDCd3ytDFIJC(BOGzjfrmnbjtOj3OvI1G)qKV3wYzNdhWVDY1iHjqwK68r44LCdNubKk50tkgBIGICXxaxOsInYvaPsopIhXBZKnMcsPIYKnNO8K7Aeo6jF4c2vJoZfbRfqOUVL8kYQ1CdxWUA0zUiyTac19TKxJTLtFxqEMxyiQGaSEaGy1Pkdeq)4Bbbl51eSXXA1Q(UG8mVWAKWeilsD(iC8cRhaiwDQYab0p(wqWsEnbBCS5ZtoFdvh3Wn2u3N4iN)gkywsrettqYeAYnALyn4pe57TLC25Wb8BNCjEeVvDaKsfrUHtQasLC6jfJfrqrU4lGlujXg5kGujpgiizL6(zYMtuEY5VHcMLueX0eKmHMC25Wb8BNCiiizL6(KB0kXAWFiY3Bl58nuDCd3ytDFIJCdNubKk50tkgBmbf5IVaUqLeBKRasLC(UDwnc84BjN)gkywsrettqYeAYzNdhWVDY13oRgbE8TKB0kXAWFiY3Bl58nuDCd3ytDFIJCdNubKk50tkghlbf5IVaUqLeBKRasLCEepI3MjR)hkLjBolKNCxJWrp5qqqYk19vVXIqyzTb0pESQDBc3Py8kYgNadgWs8iERAKak6MfwiIC(gQoUHBSPUpXro)nuWSKIiMMGKj0KB0kXAWFiY3Bl5SZHd43o5s8iER68puICdNubKk50tkgBbckYfFbCHkj2ixbKk58iEeVntw)pukt2CwCEYDnch9KdbbjRu3x9glcHL1gq)4XQ2TjCNIXRiBCcmya)dvLbg1P6XqfccZhRlSqKTCq8dcDFynsycKfUlGluPvR67cYZ8cRrctGSWOMa4DkglTKNgNNC(gQoUHBSPUpXro)nuWSKIiMMGKj0KB0kXAWFiY3Bl5SZHd43o5s8iER68puICdNubKk50tkgBXeuKl(c4cvsSrUcivY5r8iEBMS(FOuMS5Gmp5UgHJEYHGGKvQ7REJfHWYAdOF8yv72eUtX4vKTCdxWUA0zUiyTac19fJ3yTAnxo9Db5zEHHOccW6baIvNQmqa9JVfeSKxtWghRvR67cYZ8cRrctGSi15JWXlSEaGy1Pkdeq)4Bbbl51eSXXM3wo9Db5zEHL4r8w1bqkvemQjaENIXslTAvFxqEMxyUaqw1JHkeeMpwxyuta8ofJLwMpFEB5G4he6(WAKWeilCxaxOsRw13fKN5fwJeMazHrnbW7umwAjpJnp58nuDCd3ytDFIJC(BOGzjfrmnbjtOj3OvI1G)qKV3wYzNdhWVDYL4r8w15FOe5goPcivYPNumgsckYfFbCHkj2ixbKk5q1uuaGIXzMSwursS(ZKnNfYtURr4ONCiiizL6(Q3yriSS24eyWawIhXBvJeqr3SWcrKZ3q1XnCJn19joY5VHcMLueX0eKmHMCJwjwd(dr(EBjNDoCa)2j)Bkkaqt1XIKy9tUHtQasLC6jfJHMGICXxaxOsInYvaPsounffaOyCMjRfvKeR)mzZzX5j31iC0toeeKSsDF1BSiewwBCcmya)dvLbg1P6XqfccZhRlSqKTCq8dcDFynsycKfUlGluPvR67cYZ8cRrctGSWOMa4DkglTKNgNNC(gQoUHBSPUpXro)nuWSKIiMMGKj0KB0kXAWFiY3Bl5SZHd43o5FtrbaAQowKeRFYnCsfqQKtpPyCmNGICXxaxOsInYvaPsounffaOyCMjRfvKeR)mzZbzEYDnch9KdbbjRu3x9glcHL1wUHlyxn6mxeSwaH6(IXBSwTMlN(UG8mVWqubby9aaXQtvgiG(X3ccwYRjyJJ1Qv9Db5zEH1iHjqwK68r44fwpaqS6uLbcOF8TGGL8Ac24yZBlN(UG8mVWs8iER6aiLkcg1eaVtXyPLwTQVlipZlmxaiR6XqfccZhRlmQjaENIXslZNpVTCq8dcDFynsycKfUlGluPvR67cYZ8cRrctGSWOMa4DkglTKNXM3woi(bHUpC5bvl84BvND)U6c3fWfQ0Qv9Db5zEHlpOAHhFR6S73vxyuta8ofJLwYtr5jNVHQJB4gBQ7tCKZFdfmlPiIPjizcn5gTsSg8hI892so7C4a(Tt(3uuaGMQJfjX6NCdNubKk50tkXYKGICXxaxOsInYvaPsopKcczYMZuEYDnch9KpCb7QrN5IG1ciu33sEJLC(gQoUHBSPUpXro)nuWSKIiMMGKj0KB0kXAWFiY3Bl5SZHd43o5qubbYnCsfqQKtpPeRjckYfFbCHkj2ixbKk58HeMazrzY6pchVzYMZuEYDnch9KpCb7QrN5IG1ciu33sEJLC(gQoUHBSPUpXro)nuWSKIiMMGKj0KB0kXAWFiY3Bl5SZHd43o5AKWeilsD(iC8sUHtQasLC6jLyfrqrU4lGlujXg5kGujNhXJ4TzY6)HszYMd68K7Aeo6jhccswPUV6nweclRTHlyxn6mxeSwaH6(IXRX2a6hpw1UnH7umEfzlhe)Gq3hwJeMazH7c4cvA1Q(UG8mVWAKWeilmQjaENIXsl5PfYtoFdvh3Wn2u3N4iN)gkywsrettqYeAYnALyn4pe57TLC25Wb8BNCjEeVvD(hkrUHtQasLC6jLynMGICXxaxOsInYvaPsounffaOyCMjRfvKeR)mzZbDEYDnch9KdbbjRu3x9glcHL12WfSRgDMlcwlGqDFX41yB5G4he6(WAKWeilCxaxOsRw13fKN5fwJeMazHrnbW7umwAjpTqEY5BO64gUXM6(eh583qbZskIyAcsMqtUrReRb)HiFVTKZohoGF7K)nffaOP6yrsS(j3WjvaPso90tUcivYDCIVmz5VpcZj84B5HNjRSmacHNEIa]] )

    storeDefault( [[SimC Retribution: precombat]], 'actionLists', 20170201.1, [[b4vmErLxtvKBHjgBLrMxc51utbxzJLwySLMEHrxAV5MxoDdmEnfrLzwy1XgDEjKxtjvzSvwyZvMxojdmXCdmXedmUeJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5cCVrxAV52CEnvqILgBPrxEEnfCVrxAV5MxtLKBKL2yHr3BY51uU9MBL51uofwBL51uq9gDP9MBEnvqYD2CEnLBH1wz9iYBSr2x3fMCI41usvgBLf2CL5LtYatm3adoEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxtjYBSr2x3fMCI4fDErNxt5uyTvMxtnvATnKFGjvz0jxAIvhDP9MB64hyWjxzJ9wBIfgDErNxEb]] )

    storeDefault( [[Protection ST]], 'actionLists', 20170110.1, [[d8d4haGAfrTEvQInrjj7cL2MizFuIQdR0YuuMnfZNsiFIsuUm0TrLZlsTtsAVs7gP9Rs(PkvLHPIghLiDAvnukrmyvy4KOdscNIsQogOohLawiLQLsPSyrSCepurGNs8yHEoPMOkvvtvbtwW0P6IksVMss9mfvxxH(liFtLYMrrBxLkFgvTkkjAAuc08OeQrsjOVJcnArnEfrojk4wus4AQuLUNIqRurq)gyuus5c3HktPBIbd1EfjsELELk3pYChnETxrD5Wkwcb4y0Fa96qgQydn4QXQo7eofm88tw4k2WnKE45Wkw76icaMaGrkRo)Ojabyc5zeI88zhbJA2yEj8OgIBN01HvCDebataWiLvNF0eGamH8mcrE(SJGrnBmVeEudXKSr)b01CDy9RdR86yJ(dOS68JMaeGjKNriYZNDemQzjymVeESIIO)aQUdvfUdvMs3edgQ9kR7KouVIejVsVI)C4epROGWRRqxoCIataIXLuXgAWvJvD2jCk4BSNZHRWan8X1bKkuafROUCyflb4pGwrrYBEpDfLa)b06vDwhQmLUjgmu7vuxoSInmz0QXkR7KouVIn0GRgR6St4uW3ypNdxHbA4JRdivOakwrrYBEpDfcMmA1yfjsELEfhWZBq2N6iHmQ011R68ouzkDtmyO2ROUCyff3HuEKyz6Rdj)OjuzDN0H6vSHgC1yvNDcNc(g75C4kmqdFCDaPcfqXkksEZ7PRS3HuEKOH05hnHksK8k9kjJmzYYtwAaksg1BajSJkTkFni1zJKr9gqIgAYJbEoK6SiDtmyWQIaGjayKYo5XaphsD2yEj8O2IHRxvlyhQmLUjgmu7vKi5v6v2O)3Hqif5EuB5Wvw3jDOEfBObxnw1zNWPGVXEohUcd0WhxhqQqbuSI6YHvMaavJrY6pGEDynf33uRxrrYBEpDLiGQXiz9hqRx17TdvMs3edgQ9ksK8k9kraWeamsz15hnbiatipJqKNp7iyuZgZlHh1tmcaMaGrkRo)Ojabyc5zeI88zhbJA2yEj8OgIBNuffjV590v05hnbiatipJqKNp7iyuxHbA4JRdivOakwrr4ULgXqTxrD5Wks(rt46aW86WZ41HTNp7iyuxXgAWvJvD2jCk4BSNZHRyd3q6HNdRyTRJiaycagPS68JMaeGjKNriYZNDemQzJ5LWJAiUDsxhwX1reambaJuwD(rtacWeYZie55Zocg1SX8s4rnetYg9hqxZ1H1VoSYRJn6pGYQZpAcqaMqEgHipF2rWOMLGX8s4XkR7KouVIejVsFiTsSI)Cy9QMQdvMs3edgQ9kQlhwzchd8Ci1RSUt6q9k2qdUASQZoHtbFJ9CoCfgOHpUoGuHcOyffjV590vM8yGNdPEfjsELEL6v9whQmLUjgmu7vw3jDOEf1LdRy3GAngUoSWLJdjvuq41vQydn4QXQo7eof8n2Z5WvyGg(46asfkGIvuK8M3txjXGAngGYlhhsQirYR0ReWKrMmztmOwJbO8YXHewcYTpvBXwQfzrraWeamsztmOwJbO8YXHe2yEj8O2YHRxvlTdvMs3edgQ9kQlhwzcaungjR)aAL1DshQxXgAWvJvD2jCk4BSNZHRWan8X1bKkuafROi5nVNUseq1yKS(dOvKi5v6vQxvlqhQmLUjgmu7vuxoSII7qkpsSm91HKF0eUoSgS1RSUt6q9k2qdUASQZoHtbFJ9CoCfgOHpUoGuHcOyffjV590v27qkps0q68JMqfjsELEL6vf(SdvMs3edgQ9kQlhwXcxooKCDayED4z86W2ZNDemQRSUt6q9k2qdUASQZoHtbFJ9CoCfgOHpUoGuHcOyffjV590vYlhhsGamH8mcrE(SJGrDfjsELEL61RikX4VM)Ew)b0QMkv9wa]] )

    storeDefault( [[Protection Defensives]], 'actionLists', 20170110.1, [[d8sAcaGEQQ0MiOAxsITrGzsvrZMu3MOStKSxXUPy)ezuuvXWuKFJyOeKbtOHtLoOKYPOQKJjLfsjTukXIvulNKNcTmIQNlXePQQPsvMmsnDuxus1LbxxLAZuX2jO8zkLrsvHhlvJwHdRQtQs6zuQoTsNxs6VQ41uvQVPsCAXlyDZpRb6yni2vRlhmi1ldckKIWqNxIrs0FWbmLvyqjOfqdFbcL8PMGwZ(uLwq0f67Rx)(8smHsGGG168smL4fQw8cw38ZAGowd(mRIx4GyxTUCq(n(En2e(DboLXcA6GuVmiiowqtljsCKe5bijAzTnyGCxKe9tZxbRnV6LRgSmwqtFiohEah1ABWa5Ue8QHE7ptubnede0cOHVaHs(utq7sLj7TGyxTUSxvxiyzL1dhk5XlyDZpRb6yni2vRlh8UaNcODod41bFMvXlCqlGg(cek5tnbTlvMS3cE1qV9NjQGgIbcwBE1lxn44n0hIZHhWXvryOZevqQxge0hVHwsK4ijYdqsuifHHotuHdL94fSU5N1aDSge7Q1LdExGtb0oNb86GpZQ4foOfqdFbcL8PMG2Lkt2BbVAO3(ZevqdXabRnV6LRguV2g8H4C4bCCveg6mrfK6Lbb95ABWsIehjrEasIcPim0zIkC4G(do)TMJ1Wja]] )

    storeDefault( [[Protection Cooldowns]], 'actionLists', 20170110.1, [[b4vmErLxtvKBHjgBLrMxI51utnMCPbhDEnLxtruzMfwDSrNxc51usvgBLf2CL5LtYatm2etmZaJlX41utbxzJLwySLMEHrxAV5MxozJnEnvqJrxAV52CErLx051uofwBL51uqj3B0v2y0L2BU5hyd92BSr2B352CErNxEb]] )


    storeDefault( [[Retribution Primary]], 'displays', 20170110.1, [[dOd0eaGErHDPsQ2gkkZuLuMTc3ecomWTfCzL2jP2R0Ufz)u(POsnmc9BsESkAOqzWunCI6GQWrjGJHsNxuAHqOLIkwmQA5c9qvQNISmvINdvnruKPcjtgIA6GUiK6QII0ZqLCDfTrc0Pv1MHiBhQ8rrf(mkmnrv(UOIgPOO8Auuz0e04rL6KIQ6we5AIk5EOOQVjkI1kkQwNkjx2IQKaZDUiBUGQe0C6ZyRM9sjS4haXSMlOkbnN(m2QzVucl(bqmR53az4RsMFmJGsLI7O0nAnk0CkLP4xZj5DmeCaWlS8LWWH2CjZrbImwy5lHHdT5sMZ0IeyoGfXsy4qBUK53Qapaw(sia4(dZG5O(WwnxILeyUZfFrvnBrvcDcWpwKlILooHVkz(1E8Ws0hUnNZcJp)e(Q0vMlh3tvGhalPbHTe9HBZ5SW4ZpHVkDL5YX9uf4bWsC2XcWVvFrKLzSIICvIoJVmSe8dlZlwy1xkQsOta(XICrS0Xj8vjZV2JhwI(WT5Cwy85NWxLUYCKxKaZbSKge2s0hUnNZcJp)e(Q0vMJ8IeyoGL4SJfGFR(IilZyff5QWclHHdZCjZzArcmhqZpgYcbvZwcdhM5sMFRc8ay5lHHdZCjZzArcmhWIyPSvlDjpXsCxTyjo7yb43QViYYmwwUeV(Lscm35A(X4zKcBcw6S0XeQmxYCeaC)HzOAXsyXpaIznp)tvYC6ZyRopXsy4WmxY8BvGhan)yileunBjoGeJ18BH7jZ9jgLa8)4HzlDCcFvY8BGm8vj8fXsKm48tmQoxLWWHzUK5OarglS8Li5DmeCaWl08B1qflQsGQzlXxnBjgvZwkwnBHLi598bJpda8vPQZeXsy4WmxYCuGiJfA(XqwiOA2scm35AotFCpHVkvIt(5iZqvsdcBjolm(8t4RsMJf)aiMTKaZDUiBE(NQK50NXwDEILeuLGLoIpyyUgeJQCwcDcWpwKlILoYnAZLmhba3FygQwSu(NQeEZjHQCMQoVsh5gT5sMJWN(WmunxLqbgBcAEoIQPC1ILOpXySMlzocaU)WmunBjS4haXSMFdKHVkvccImwi(smTibMdyrSego0Mlz(TkWdGMFmKfcQMTego0MlzokqKXcn)yileunBPJjuzUK5i8PpmdvlwI(eJXAUK5i8Ppmdvlw6wjN1CuQsyrfCpHVkzow8dGy2szUsfQMnxLWWH2CjZzArcmhqZpgYcbvZwIoJVmSuHT]] )

    storeDefault( [[Retribution AOE]], 'displays', 20170110.1, [[dSZ0eaGEcXUuHABcLyMcvA2I6WqUji13ekPBlYJvP2jv2R0UfSFs)ufYWaLFtvNhegksgmLHtuhuihLq6yq5Ccv0cbrlfHwmsTCf9qv0trTme16ubMiuPPcQMmuX0bUOk5Qeq9mcQRRWgfkoTQ2miz7iYhfQQpdvnncW3fQYijGCzLgnHA8eOtQc6we5AeK7jukphbRvOu9AHkCXk8YIo2XIJAX4da14xKTomYLPirPMKAWrt8lO0LPMFcnHqTtKm49b1Igtu5YZnx(8Yb)IyzbMWQglV5CmzebXLUmfPl1KudoAIFbLUmfPl1Kud3fk0idkKLPiDPMKAN(encu6YqJe8tJKAW)0wNWWkl6yhlHcVoScV8varNxCkKLJUbVpOwCFcGY8NovJ4cMp9a8(WbQjp3BFIgbk7qPTm)Pt1iUG5tpaVpCGAYZ92NOrGYe38IiS1rggMqyyhtMmwz(E(YGYGpTXgScQJCHx(kGOZlofYYr3G3hulUpbqz(tNQrCbZNEaEF4a1WzHcnYGYouAlZF6unIly(0dW7dhOgoluOrguM4MxeHToYWWecd7yYKXkOGY898LbLj8b85Tmfjk1Ku70NOrGsxMIeLAsQH7cfAKbfYYquNewCkuzbRdwzIBEre26iddlwWWeg2XKll6yhRAr5hFiTbq57YrdGxnj1Ggj4NgP6GvMA(j0ec1o82huJFr26eaSY8hWNx1Kud6p8PrQoHltrIsnj1WDHcnYa1IYYIr1HvMI0LAsQH7cfAKbQfLLfJQdRmfjk1Ku70NOra1IYYIr1HvMI0LAsQD6t0iGArzzXO6WkZYBohtgrqSAN(SFw4Lr1HvEwhwz81HvMUoSckF6LHqn4(YexW8PhG3hul6ORYrdGxnj1G(dFAKQt4YIo2XQgU)CVbVpuM4HXxGGxg3fk0idkKLfDSJfh1o82huJFr26eaSYuKUutsn4Oj(fOwuwwmQoSYxbeDEXPqwMIeLAsQbhnXVa1IYYIr1HvM)a(8QMKAqJe8tJuDWkhD0LAsQb9h(0ivNWLHJYBaOw8N(HCDWkF4TpqqnwSpEH6eq5OJUutsnOrc(PrQoyLPMFcnHqTtKm49HYa0e)ciuMA(j0ec1IXhaQXViBDyKlhJpakhnFuwnhAo9XRSdL2YexW8PhG3hul6ORYS8E)O8lcc8(qDXkSYSm6(d4RtOYXU3NQdtOYr3G3hu7ejdEFGqHSmrua)Q2P49oo(a(Yi6p)aikOf]] )

    storeDefault( [[Protection Primary]], 'displays', 20170110.1, [[dCJifaGEcv7sPKTriMjHKzlQBcKUnGDsQ9kTBI2VWpvkYWiXVrmuvmyQgUioOs6OKKoguDyiluL0sbIfRsTCk9qKYtrTmrYZPWevQAQkXKvjMUQUiu6Qes5YkUos2ijXZakBgOA7qXhvk01ukQPPuX3vk1ivkWJjy0KuJNq5Kkv6wu0PbDErQpJuTwLc61es1fVlLvLAOMlHRcr(HZqXNQXtv(G5eUz4lil957D5JfcGSPdNgk5Hez4Ruwu5Y2jxMgw9cwqklAgt4CYKZQKrgQ7DzobjaL0REZLpyWgUz47hWru5VxlFWGnCZWPraUrFVldksmiafq4lqGPAWukVHecq14BUmlyHjF5YhmNWndNgb4g99U8bZjCZW3pGJOYFVwoD1MP2rPSyvRugKjpiJP6uk4IGJdMYwPkdcssFcNM6rq0Hs6Lr3Wm8tx(GbB4MHtJaCJ(WxZjQrvJx(G5eUz4lil95dFnNOgvnEzgkPNNWndhuOecqbuTszvPgQj81mKUeyKFzHYRcpKidNgk5HePrVw(GbB4MHVGS0NV3LpwiaYMoCviYpCgk(unEQYCYKZQKrgQdNgjtSDPmQA8Y3vJxME14LTvJ3Vmnss6WxiLpwYpcpKid)yHaiB6Yhleazth(Ucez4mu8P6DukRk1qnHVhAhHhsKLbz3nUblL1iGP8Xs(r4Hez4hleaztxwvQHAUe(Ucez4mu8P6DukRcr(LxTquoCnYAjBxgReDNNl9A51nHnCZWbfjgeGcOALY7kqKgHZQjBlRENYRBcB4MHdkucbOaQgSYlO8i)W3OLqLuTszgkPNNWndhuKyqakGQXlFSqaKnD40qjpKil)il95nkVFahrL)ET8k1tc3mCqrIbbOaQwP8bd2WndFbzPpF4R5e1OQXlVs9KWndhuOecqbuTs5dMt4MHtJaCJ(WxZjQrvJxMtgbikdfh9qISArePSQud1y0LQX7szSs0DEU0RLxfEirgUOGgF5JL8JWdjYW3pGpsdiMXOSgbmLpwYpcpKidF)a(inGygJYGm5bzmvNsbxeCffW2cVmlyHjF5(vNQlLXkr355sVwEv4Hez4IcA8LpwYpcpKidNgHKVq2wAuwJaMYhl5hHhsKHtJqYxiBlnkdYKhKXuDkfCrWvuaBl8YSGfM8L7xnyDPmwj6opx61YRcpKidxuqJV8Xs(r4Hez48szncykFSKFeEirgoVugKjpiJP6uk4IGROa2w4Lzblm5l3VF5dgSHBg((bCev(dFnNOgvnE5dMt4MHVFahrL)WxZjQrvJ3Vfa]] )

end
