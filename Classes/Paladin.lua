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


    storeDefault( [[SimC Retribution: default]], 'actionLists', 20170313.1, [[dy0uNaqiqOwKqbTjkXNek0OevoLOQvHQODbQHHsogfzzeYZijMgi4AusSnkj13arJdf6CcfvRdvbvZJsQ7HQ0(iuoikvleLYdrvzIOk0fjuTrufugPqr6KKKwPqbUjj1ojXqrvqAPOQ6PunvuWwPKKVkuuwlQcI9I8xkmyrPddSyu5XKAYeDzPndsFgfnAfCAOwTqPxlunBb3wKDR0Vvz4c54cfXYH8CfnDvDDc2Uc9DkQXJQaNNs16bHmFkL9lkMmrmqU4lGlujXg58yHcecpXg5Eu1yqadrGhFlPajlY5VHcMLueXYeKSuXKkWMi31iC0to5SRF8TtIbsXeXa5IVaUqLeBK7Aeo6j)pMmdfgVFriHOFsUcivY5VCcXl583qbZskIyzcswmso7C4a(TtoQCcXl5QUsSg8hI892soFdvhx9n2u3N4ix9jvaPso9KIiIbYfFbCHkj2i31iC0t(FmzgkC094BNwYLJtakuyUWDYGW8HfISzJtakuyWyxM4LPHze4hGfISzJtakuynsycKfwiYcNauOWAKWeilmQjaENwlYk2S9aeZ(WpovJ)mK4AnVqGv(8KZohoGF7KhDp(wYvDLyn4pe57TLCfqQKZd9E8TKZoI5K8fKkVXWlinmdqXqY5VHcMLueXYeKSyKC(gQoU6BSPUpXrU6tQasL8y4fKgMbOyi9KIkedKl(c4cvsSrURr4ON8)yYmuy9Db5zENKRasLC2c3jZKLhMaYo583qbZskIyzcswmso7C4a(Ttox4oPbubKDYvDLyn4pe57TLC(gQoU6BSPUpXrU6tQasLC6jfiqmqU4lGlujXg5UgHJEY)JjZqH13fKN5DsUcivYzROzrXXltY5VHcMLueXYeKSyKC25Wb8BNCUIMffhVmjx1vI1G)qKV3wY5BO64QVXM6(eh5QpPcivYPNuScXa5IVaUqLeBK7Aeo6j)pMmdfwFxqEM3PLCdxWUr0zUiyTac19T2kwYXjafkSgjmbYclezZgNauOWGXUmXltdZiWpalezZ2Jt1Ar5ZtUcivYzhPbBZKLHdH6(KZFdfmlPiILjizXi5SZHd43o5aKgS14peQ7tUQReRb)HiFVTKZ3q1XvFJn19joYvFsfqQKtpPy1edKl(c4cvsSrURr4ON8hNQ1IixbKk5XabjZu3NC(BOGzjfrSmbjlgjNDoCa)2jpwbjZu3NCvxjwd(dr(EBjNVHQJR(gBQ7tCKR(KkGujNEsbsIbYfFbCHkj2i31iC0t(Jt1ArwY1yIaokQsytQajliWOnBiGUWCH7Kgnanp5kGujNTaq2mzpOzYgdeMpwxY5VHcMLueXYeKSyKC25Wb8BNCUaqwJdQrScZhRl5QUsSg8hI892soFdvhx9n2u3N4ix9jvaPso9KcJedKl(c4cvsSrURr4ON8hNQ1ISKRXebCuuLWMubswqGrB2qaDH5c3jnAaAEYvaPsopIhXBZKnMcsPIiN)gkywsreltqYIrYzNdhWVDYL4r8wJbqkve5QUsSg8hI892soFdvhx9n2u3N4ix9jvaPso9KsmNyGCXxaxOsInYDnch9KpCb7grN5IG1ciu33AEnz5XPATiYvaPsEmdeVzYEqZKL95qNKZFdfmlPiILjizXi5SZHd43o5MbXRXb1amh6KCvxjwd(dr(EBjNVHQJR(gBQ7tCKR(KkGujNEsXelIbYfFbCHkj2i31iC0t(FmzgkS(UG8mVtYvaPsEm9c2ZKnMHa)a583qbZskIyzcswmso7C4a(Tt(WfSBygb(bYvDLyn4pe57TLC(gQoU6BSPUpXrU6tQasLC6jftMigix8fWfQKyJCxJWrp5)XKzOW67cYZ8ojxbKk5Sp2LjEzMjBmdb(bY5VHcMLueXYeKSyKC25Wb8BNCWyxM4LPHze4hix1vI1G)qKV3wY5BO64QVXM6(eh5QpPcivYPNumjIyGCXxaxOsInYvaPsUpGBqMj7bntwRQlZcwDjNDoCa)2jFoGBqACqng7YSGvxY5VHcMLueXYeKSyKCvxjwd(dr(EBjNVHQJR(gBQ7tCKR(KkGujNEsXKkedKl(c4cvsSrURr4ON8)yYmuy9Db5zENwKLtaku4yfKmtDFyHil5gUGDJOZCrWAbeQ7lgVwXce3yIaokQsytQajliWOnB5Y1yIaokQsytQajliWOnBiGUWCH7KgnanVLhNQ1ISz7XPkMildxWUr0zUiyTac19fJxiKpp5kGujNpKWeil583qbZskIyzcswmso7C4a(TtUgjmbYsUQReRb)HiFVTKZ3q1XvFJn19joYvFsfqQKtpPyccedKl(c4cvsSrURr4ONCG(XJ1OBt4oTMxvSKtFxqEMx4yfKmtDFyuta8oTMPwYtiaB1wXMnz5eGcfowbjZu3hg1eaVtXyQL8ecWwTvYBjhe)Gq3hwJeMazH7c4cvAZM(UG8mVWAKWeilmQjaENIXul5PO8KRasLCX5bvl84BZK17(D1LC(BOGzjfrSmbjlgjNDoCa)2jV8GQfE8TgZUFxDjx1vI1G)qKV3wY5BO64QVXM6(eh5QpPcivYPNumzfIbYfFbCHkj2i31iC0tEScsMPUVXnweclRfG(XJ1OBt4ofJxrw4eGcfwIhXBnIeqr3SWcrw4eGcfwIhXBnIeqr3SWOMa4DAntTKNIixbKk58iEeVntw)puIC(BOGzjfrSmbjlgjNDoCa)2jxIhXBnM)HsKR6kXAWFiY3Bl58nuDC13ytDFIJC1NubKk50tkMSAIbYfFbCHkj2i31iC0tEScsMPUVXnweclRfG(XJ1OBt4ofJxrwgUGDJOZCrWAbeQ7lgVwXcNauOWs8iERrKak6MfwiICfqQKZJ4r82mz9)qPmzZzkp583qbZskIyzcswmso7C4a(TtUepI3Am)dLix1vI1G)qKV3wY5BO64QVXM6(eh5QpPcivYPNumbjXa5IVaUqLeBK7Aeo6jpwbjZu334glcHL1cq)4XA0TjCNIXRildxWUr0zUiyTac19fJxvSWjafkSgjmbYclezjhNauOWAKWeil88b64wBYk2SXjafkmx4ozqy(Wcr5jxbKk58iEeVntw)pukt2CIYto)nuWSKIiwMGKfJKZohoGF7KlXJ4TgZ)qjYvDLyn4pe57TLC(gQoU6BSPUpXrU6tQasLC6jftmsmqU4lGlujXg5UgHJEYJvqYm19nUXIqyzTa0pESgDBc3Py8kYYWfSBeDMlcwlGqDFX41kwYbXpi09H1iHjqw4UaUqL2SPVlipZlSgjmbYcJAcG3Pym1sEQsEYvaPsopIhXBZK1)dLYKnNk5jN)gkywsreltqYIrYzNdhWVDYL4r8wJ5FOe5QUsSg8hI892soFdvhx9n2u3N4ix9jvaPso9KIPyoXa5IVaUqLeBK7Aeo6jpwbjZu334glcHL1cNauOWs8iERrKak6MfwiYcNauOWs8iERrKak6Mfg1eaVtRzQL8ue5kGujNHMIcaumoZK1QksI1p583qbZskIyzcswmso7C4a(Tt(3uuaGMgJfjX6NCvxjwd(dr(EBjNVHQJR(gBQ7tCKR(KkGujNEsrelIbYfFbCHkj2i31iC0tEScsMPUVXnweclRLHly3i6mxeSwaH6(IXRvSWjafkSepI3AejGIUzHfIixbKk5m0uuaGIXzMSwvrsS(ZKnNP8KZFdfmlPiILjizXi5SZHd43o5FtrbaAAmwKeRFYvDLyn4pe57TLC(gQoU6BSPUpXrU6tQasLC6jfrMigix8fWfQKyJCxJWrp5XkizM6(g3yriSSwgUGDJOZCrWAbeQ7lgVQyHtakuynsycKfwiYsoobOqH1iHjqw45d0XT2KvSzJtakuyUWDYGW8HfIYtUcivYzOPOaafJZmzTQIKy9NjBor5jN)gkywsreltqYIrYzNdhWVDY)MIca00ySijw)KR6kXAWFiY3Bl58nuDC13ytDFIJC1NubKk50tkIermqU4lGlujXg5UgHJEYJvqYm19nUXIqyzTmCb7grN5IG1ciu3xmETILCq8dcDFynsycKfUlGluPnB67cYZ8cRrctGSWOMa4DkgtTKNQK3soi(bHUpC5bvl84BnMD)U6c3fWfQ0Mn9Db5zEHlpOAHhFRXS73vxyuta8ofJPwMNCfqQKZqtrbakgNzYAvfjX6pt2CQKNC(BOGzjfrSmbjlgjNDoCa)2j)BkkaqtJXIKy9tUQReRb)HiFVTKZ3q1XvFJn19joYvFsfqQKtpPisfIbYfFbCHkj2i31iC0tEScsMPUVXnweclRLHly3i6mxeSwaH6(IXRkwa6hpwJUnH7umEfzjN(UG8mVWMbXRXb1amh6eg1eaVtRzQL8uKfa6Xqb6h2miEnoOgG5qNWDbCHkTzJtakuyZd4zurghuJFOgl4hqfIWjyHilCcqHcBEapJkY4GA8d1yb)aQqeobJAcG3P1m1Y8wYbXpi09H1iHjqw4UaUqL2SPVlipZlSgjmbYcJAcG3Pym1sEcH8KRasLCEepI3MjR)hkLjBoiKNC(BOGzjfrSmbjlgjNDoCa)2jxIhXBnM)HsKR6kXAWFiY3Bl58nuDC13ytDFIJC1NubKk50tkIGaXa5IVaUqLeBK7Aeo6jpwbjZu334glcHL1YWfSBeDMlcwlGqDFX4vfl503fKN5f2miEnoOgG5qNWOMa4DAntTKNISaqpgkq)WMbXRXb1amh6eUlGluPnBCcqHcBEapJkY4GA8d1yb)aQqeoblezHtakuyZd4zurghuJFOgl4hqfIWjyuta8oTMPwM3soi(bHUpSgjmbYc3fWfQ0Mn9Db5zEH1iHjqwyuta8ofJPwYtiKNCfqQKZqtrbakgNzYAvfjX6pt2Cqip583qbZskIyzcswmso7C4a(Tt(3uuaGMgJfjX6NCvxjwd(dr(EBjNVHQJR(gBQ7tCKR(KkGujNEsrKvigix8fWfQKyJCxJWrp5Y7HlpOAHhFRXS73vx4hRJJxMwK3dxEq1cp(wJz3VRUWOMa4DAntTKNISilNauOWXkizM6(WOMa4DAntTKNIixbKk5XabjZu3pt2CMYto)nuWSKIiwMGKfJKZohoGF7KhRGKzQ7tUQReRb)HiFVTKZ3q1XvFJn19joYvFsfqQKtpPiYQjgix8fWfQKyJCxJWrp5dxWUr0zUiyTac195LLnBdxWUr0zUiyTac1951KLC67cYZ8cZfaYACqnIvy(yDHrnbW7umMAPnB67cYZ8clXJ4TgdGuQiyuta8ofJPwM3MTHly3i6mxeSwaH6(8kYso9Db5zEHHOccW6baIzNgqra9JVfeSMxwWwTvSztFxqEMxynsycKfzmFeoEH1daeZonGIa6hFliynVSGTARKNCfqQKhZaXBMSh0mzzFo0zMS5mLNC(BOGzjfrSmbjlgjNDoCa)2j3miEnoOgG5qNKR6kXAWFiY3Bl58nuDC13ytDFIJC1NubKk50tkIGKyGCXxaxOsInYDnch9KpCb7grN5IG1ciu33AEvXcNauOWMhWZOImoOg)qnwWpGkeHtWcrw4eGcf28aEgvKXb14hQXc(buHiCcg1eaVtXyQLw4eGcf28aEgvKXb14hQXc(buHiCcg1eaVtRzQL8uflXkizM6(g3yriSSwKLtaku4yfKmtDFyuta8ofJPwYtrKRasLCEepI3MjBmfKsfLjBot5jN)gkywsreltqYIrYzNdhWVDYL4r8wJbqkve5QUsSg8hI892soFdvhx9n2u3N4ix9jvaPso9KIigjgix8fWfQKyJCxJWrp5dxWUr0zUiyTac19TMxvixbKk5SfaYMj7bnt2yGW8X6MjBot5jN)gkywsreltqYIrYzNdhWVDY5caznoOgXkmFSUKR6kXAWFiY3Bl58nuDC13ytDFIJC1NubKk50tkII5edKl(c4cvsSrURr4ONC9aaXStEfzz4c2nIoZfbRfqOUV18cbYvaPsopKccKZFdfmlPiILjizXi5SZHd43o5qubbYvDLyn4pe57TLC(gQoU6BSPUpXrU6tQasLC6jfvyrmqU4lGlujXg5UgHJEY1daeZo5vKLHly3i6mxeSwaH6(wZleixbKk58HeMazrzY6pchVKZFdfmlPiILjizXi5SZHd43o5AKWeilYy(iC8sUQReRb)HiFVTKZ3q1XvFJn19joYvFsfqQKtpPOIjIbYfFbCHkj2i31iC0t(WfSBeDMlcwlGqDFR5vKnB5gUGDJOZCrWAbeQ7BnVQyjN(UG8mVWqubby9aaXStdOiG(X3ccwZRjyvGGnB67cYZ8cRrctGSiJ5JWXlSEaGy2Pbueq)4BbbR51eSkqiFEYvaPsopIhXBZKnMcsPIYKnNO8KZFdfmlPiILjizXi5SZHd43o5s8iERXaiLkICvxjwd(dr(EBjNVHQJR(gBQ7tCKR(KkGujNEsrfredKl(c4cvsSrUcivYJbcsMPUFMS5eLNC25Wb8BN8yfKmtDFY5VHcMLueXYeKSyKCvxjwd(dr(EBjNVHQJR(gBQ7tCKR(KkGujNEsrfvigix8fWfQKyJCfqQKZ3TZQrGhFl5SZHd43o56BNvJap(wY5VHcMLueXYeKSyKCvxjwd(dr(EBjNVHQJR(gBQ7tCKR(KkGujNEsrfiqmqU4lGlujXg5UgHJEYJvqYm19nUXIqyzTa0pESgDBc3Py8kYcNauOWs8iERrKak6MfwiICfqQKZJ4r82mz9)qPmzZzL8KZFdfmlPiILjizXi5SZHd43o5s8iERX8puICvxjwd(dr(EBjNVHQJR(gBQ7tCKR(KkGujNEsrfRqmqU4lGlujXg5UgHJEYJvqYm19nUXIqyzTa0pESgDBc3Py8kYcNauOW)qnGIrDACqnIvy(yDHfISKdIFqO7dRrctGSWDbCHkTztFxqEMxynsycKfg1eaVtXyQL8uL8KRasLCEepI3MjR)hkLjBoRop583qbZskIyzcswmso7C4a(TtUepI3Am)dLix1vI1G)qKV3wY5BO64QVXM6(eh5QpPcivYPNuuXQjgix8fWfQKyJCxJWrp5XkizM6(g3yriSSwa6hpwJUnH7umEfzj3WfSBeDMlcwlGqDFX4fc2SLlN(UG8mVWqubby9aaXStdOiG(X3ccwZRjyvGGnB67cYZ8cRrctGSiJ5JWXlSEaGy2Pbueq)4BbbR51eSkqiVLC67cYZ8clXJ4TgdGuQiyuta8ofJPwAZM(UG8mVWCbGSghuJyfMpwxyuta8ofJPwMpFEl5G4he6(WAKWeilCxaxOsB203fKN5fwJeMazHrnbW7umMAjpHqEYvaPsopIhXBZK1)dLYKnhK5jN)gkywsreltqYIrYzNdhWVDYL4r8wJ5FOe5QUsSg8hI892soFdvhx9n2u3N4ix9jvaPso9KIkqsmqU4lGlujXg5UgHJEYJvqYm19nUXIqyzTWjafkSepI3AejGIUzHfIixbKk5m0uuaGIXzMSwvrsS(ZKnNvYto)nuWSKIiwMGKfJKZohoGF7K)nffaOPXyrsS(jx1vI1G)qKV3wY5BO64QVXM6(eh5QpPcivYPNuuHrIbYfFbCHkj2i31iC0tEScsMPUVXnweclRfobOqH)HAafJ604GAeRW8X6clezjhe)Gq3hwJeMazH7c4cvAZM(UG8mVWAKWeilmQjaENIXul5Pk5jxbKk5m0uuaGIXzMSwvrsS(ZKnNvNNC(BOGzjfrSmbjlgjNDoCa)2j)BkkaqtJXIKy9tUQReRb)HiFVTKZ3q1XvFJn19joYvFsfqQKtpPOsmNyGCXxaxOsInYDnch9KhRGKzQ7BCJfHWYAj3WfSBeDMlcwlGqDFX4fc2SLlN(UG8mVWqubby9aaXStdOiG(X3ccwZRjyvGGnB67cYZ8cRrctGSiJ5JWXlSEaGy2Pbueq)4BbbR51eSkqiVLC67cYZ8clXJ4TgdGuQiyuta8ofJPwAZM(UG8mVWCbGSghuJyfMpwxyuta8ofJPwMpFEl5G4he6(WAKWeilCxaxOsB203fKN5fwJeMazHrnbW7umMAjpHqEl5G4he6(WLhuTWJV1y297QlCxaxOsB203fKN5fU8GQfE8TgZUFxDHrnbW7umMAjpfLNCfqQKZqtrbakgNzYAvfjX6pt2CqMNC(BOGzjfrSmbjlgjNDoCa)2j)BkkaqtJXIKy9tUQReRb)HiFVTKZ3q1XvFJn19joYvFsfqQKtpPabwedKl(c4cvsSrURr4ON8Hly3i6mxeSwaH6(wZleixbKk58qkiKjBot5jN)gkywsreltqYIrYzNdhWVDYHOccKR6kXAWFiY3Bl58nuDC13ytDFIJC1NubKk50tkqWeXa5IVaUqLeBK7Aeo6jF4c2nIoZfbRfqOUV18cbYvaPsoFiHjqwuMS(JWXBMS5mLNC(BOGzjfrSmbjlgjNDoCa)2jxJeMazrgZhHJxYvDLyn4pe57TLC(gQoU6BSPUpXrU6tQasLC6jfiiIyGCXxaxOsInYDnch9KhRGKzQ7BCJfHWYAz4c2nIoZfbRfqOUVy8QIfG(XJ1OBt4ofJxrwYbXpi09H1iHjqw4UaUqL2SPVlipZlSgjmbYcJAcG3Pym1sEAL8KRasLCEepI3MjR)hkLjBogZto)nuWSKIiwMGKfJKZohoGF7KlXJ4TgZ)qjYvDLyn4pe57TLC(gQoU6BSPUpXrU6tQasLC6jfiOcXa5IVaUqLeBK7Aeo6jpwbjZu334glcHL1YWfSBeDMlcwlGqDFX4vfl5G4he6(WAKWeilCxaxOsB203fKN5fwJeMazHrnbW7umMAjpTsEYvaPsodnffaOyCMjRvvKeR)mzZXyEY5VHcMLueXYeKSyKC25Wb8BN8VPOaannglsI1p5QUsSg8hI892soFdvhx9n2u3N4ix9jvaPso90tUcivYDCIVmz5VpcZj84B5HNjRSqbcHNEIa]] )

    storeDefault( [[SimC Retribution: precombat]], 'actionLists', 20170313.1, [[b4vmErLxtvKBHjgBLrMxc51uevMzHvhB05LqEn1uWv2yPfgBPPxy0L2BU5Lt3aJxtjvzSvwyZvMxojdmXCdmZeZmUeJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5cCVrxAV52CEnvqILgBPrxEEnfCVrxAV5MxtLKBKL2yHr3BY51uU9MBL51uofwBL51uq9gDP9MBEnvqYD2CEnLBH1wz9iYBSr2x3fMCI41usvgBLf2CL5LtYatm3adoEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxtjYBSr2x3fMCI4fDErNxt5uyTvMxtnvATnKFGjvz0jxAIvhDP9MB64hyWjxzJ9wBIfgDErNxEb]] )

    storeDefault( [[Protection ST]], 'actionLists', 20170313.1, [[d8d4haGAfQSEvQInrjr7cL2MizFusQdR0YuuMnfZNsiFIsughLi9nvkNxKANK0EL2ns7xf9tvQkdtL8BGtRQHsjHbRcdNeDqs4uus5yG6CucyHuQwkLYIfXYr8qkjzvuI4Xc9CsnrvQQMQcMSGPt1fvu9AkbDzORRi)fKNsSzu02vPYNrvptHmnkbAEkuyKuc13rHgTOgVcLojk4wuIQRPsv6Eku1kvOOBJkJIsQUWDOYC6MyWqTxrIKxPxPY9Jm3jJx7vuxoSIvqaog9hqppKHk2qdUASQZUGVDncEelCfB4gsp8CyfRFEebataWiLvNF0eGamH8mcrE(SJGjnBmVeEudXTJ98WYppIaGjayKYQZpAcqaMqEgHipF2rWKMnMxcpQHys2O)a6AopS25HLCESr)buwD(rtacWeYZie55ZocM0SemMxcpwrr0Fav3HQc3HkZPBIbd1EfBObxnw1zxWPGVXEncUIejVsVI)C44VQOGWRRqxoC8ataIXLurrYBEpDfLa)b0kmqdFCDaPcfqXkQlhwXka(dOvw3jDOE9QoRdvw3jDOEfjsELEfhWZBq2N6iHmP01vuxoSInmzYcXk2qdUASQZUGtbFJ9AeCfgOHpUoGuHcOyffjV590viyYKfIvMt3edgQ96vDuhQSUt6q9ksK8k9kjtmzYYtwAaksM0BajStkTsFni1zJKj9gqIgACtbEoK6SiDtmyWkJaGjayKYoUPaphsD2yEj8OEmGROUCyff3HuEKyz6Zdj)OjuXgAWvJvD2fCk4BSxJGRWan8X1bKkuafROi5nVNUYEhs5rIgsNF0eQmNUjgmu71RQfSdvw3jDOEfjsELELn6)DiesrUh1wnCfBObxnw1zxWPGVXEncUIIK38E6kravJrY6pGwHbA4JRdivOakwrD5WkwfGQXiz9hqppSUI7BU1QmNUjgmu71R692HkZPBIbd1EfjsELELiaycagPS68JMaeGjKNriYZNDemPzJ5LWJ6XhbataWiLvNF0eGamH8mcrE(SJGjnBmVeEudXTJTIIK38E6k68JMaeGjKNriYZNDemPRWan8X1bKkuafROiC3sJyO2ROUCyfj)OjCEayEE4z88W2ZNDemPRydn4QXQo7cof8n2RrWvSHBi9WZHvS(5reambaJuwD(rtacWeYZie55ZocM0SX8s4rne3o2Zdl)8icaMaGrkRo)Ojabyc5zeI88zhbtA2yEj8OgIjzJ(dOR58WANhwY5Xg9hqz15hnbiatipJqKNp7iysZsWyEj8yfjsEL(qALyf)5WkR7KouVEvt1HkR7KouVIejVsVsf1LdRmMtbEoK6vSHgC1yvNDbNc(g71i4kmqdFCDaPcfqXkksEZ7PRmUPaphs9kZPBIbd1E9QERdvMt3edgQ9kQlhwXUb1AmCEyXlhhsQirYR0ReWKjMmztmOwJbO8YXHewcYTpvpgwQfzrraWeamsztmOwJbO8YXHe2yEj8O2QHROGWRRuXgAWvJvD2fCk4BSxJGRWan8X1bKkuafROi5nVNUsIb1AmaLxooKuzDN0H61RQL2HkR7KouVIejVsVsf1LdRyvaQgJK1FaTIn0GRgR6Sl4uW3yVgbxHbA4JRdivOakwrrYBEpDLiGQXiz9hqRmNUjgmu71RQfOdvw3jDOEfjsELELkQlhwrXDiLhjwM(8qYpAcNhwh2AvSHgC1yvNDbNc(g71i4kmqdFCDaPcfqXkksEZ7PRS3HuEKOH05hnHkZPBIbd1E9QcF1HkR7KouVIejVsVsf1LdRyXlhhsopampp8mEEy75ZocM0vSHgC1yvNDbNc(g71i4kmqdFCDaPcfqXkksEZ7PRKxooKabyc5zeI88zhbt6kZPBIbd1E96veLy8xZFpR)aAvtLQEla]] )

    storeDefault( [[Protection Defensives]], 'actionLists', 20170313.1, [[d8sAcaGEQQ0MiOAxsITruMjbLztQBtuTtKSxXUjz)ezuuvXWuWVrmucYGj0WPshus1POQuhtrlKsSukvlwLSCkEk0YOKEUetKQQMkvzYi10rDrjPldUUk1MPITtvHptPmsQk5Xsz0s1Hv1jvO(Mc50kDEjLxtvrpJa)vfNz8cwv9xAGowcs9YHGczim04LOKe9hCavz9bucInZ6YbdAh0WxGqzDyoAqWuqLzq0fA7Rx)(8suHsMSG1B8suL4fQz8cwv9xAGowcInZ6Yb5x5Zvzt43f4u6lOPds9YHGyFbnTKiXrsK7GKO91wNbYDrs0ptFhS(1QxUwWsFbn9H4C4oCmRTodK7sq7Gg(cekRdtzZrvgemdowrVTNjMGkIcc(mBIx4GyZSUSxnxiyzL3chkRXl4ZSjEHds9YHG(6v0sIehjrUdsIczim0yIji2mRlh8UaNcODoD41bTdA4lqOSomLnhvzqWm4yf92EMycQikiy9RvVCTG9xrFiohUdhxdHHgtmbRQ(lnqhlHdLG4f8z2eVWbPE5qqHT26SKiXrsK7GKOqgcdnMycInZ6YbVlWPaANthEDq7Gg(cekRdtzZrvgemdowrVTNjMGkIccw)A1lxlOET15dX5WD44Aim0yIjyv1FPb6yjC4G(do)TMJLWja]] )

    storeDefault( [[Protection Cooldowns]], 'actionLists', 20170313.1, [[b4vmErLxtvKBHjgBLrMxI51uevMzHvhB05LqEn1uJjxAWrNxt51usvgBLf2CL5LtYatm3aZmXmJlX41utbxzJLwySLMEHrxAV5MxozJnEnvqJrxAV52CErLx051uofwBL51uqj3B0v2y0L2BU5hyd92BSr2B352CErNxEb]] )


    storeDefault( [[Retribution Primary]], 'displays', 20170313.1, [[dOZ(eaGEcQxkQIDjQqVwurMPOsnBfUje1Tf6WG2jP2R0UjA)u9trvAye63K8mvOgkkgmLHlkhuL6OcOJHsxtuvwOkYsjWIrvlxKhcHNISmvuphQmrOOPcPMSanDGlcLUQOI6YkDDfTrcY5rfBgkSDOQpkQQ(mKmnvGVdrAKIkXJvjJgvA8cWjvHClbDAvDprfSoiI1kQK(MkOlBrxkW5o3GUjKscCJEH3QzpxIbpJBHUHgMqTGYxIj9ryIJBiGzGxjD7EMGLkL2rjey1OXkOuoJBDJY2XqObeh3YxIYGxVev15RedESUf6gMlgW5a0tLyWJ1Tq3qOI8qq5lHmmGpoJUH(JB1hlwkxvQy1S5ReDL(mqPsm4zCl0neQipeu(sm4zCl0nmxmGZbONkXP6WZhiwkGQfljyhle3w9zr2dfpM94CKTKaOe16gcU7vo9suLG8)4bCkXGNXTq3WCXaoha3UhzCHvZwIbpw3cDdHkYdbUDpY4cRMTedEg3cDdnmHAbUDpY4cRMTe9suJ1Tq3q(LFCgRwSedESUf6gMlgW5a429iJlSA2sbo35IRORMTOlHvc5hBWEQ09f4vs3Y9JduI(ic3eSG0ZpbVsIe3Ys7LkYdbL0W4wI(ic3eSG0ZpbVsIe3Ys7LkYdbLeSJfIBR(Si7HISIILOR0Nbkb(4MdIfu95IUewjKFSb7Ps3xGxjDl3poqj6JiCtWcsp)e8kjsCl4IbCoaL0W4wI(ic3eSG0ZpbVsIe3cUyaNdqjb7yH42QplYEOiROybfucHkJJBOvLyskWEbEL0nM0hHjoLyWZ4wOBiurEiWT7rgxy1SLUNaLBHUH8l)4mwTyjkBhdHgqCCDdHAOsfDjy1SL4RMTeQQzlLQMTGsu2E9WXlme8kz1hkwIbpw3cDdnmHAbUDpY4cRMTuGZDUUH5N2lWRKLeCu(Zf0LUNaLBHUHmmGpoJvlwkW5o3GUD0Ls6g9cVvFGyjmxmGZbONkHvc5hBWEQet6JWeh3qaZaVswcatOwaUs0lrnw3cDdzyaFCgRMT0DEX6wOBi)YpoJvFCj0WXkbUL)KAMvnBPJUusCUrCvivw9bLUZlw3cDdzyaFCgRwSet6JWeh3o6sjDJEH3QpqSet6JWeh3esjbUrVWB1SNljKsckDNE4WnnmLuiTKgg3scwq65NGxjDJj9ryItjg8yDl0n0WeQfu(sexfsDlplh(xg8LOW1tLcCUZ1T7XJsgxjO0vP7lWRKUHaMbELexpvkplh(xg8LOCJaCgB1NlOfa]] )

    storeDefault( [[Retribution AOE]], 'displays', 20170313.1, [[d0dbfaGEsWlvuyxQk1RvKOzQOOddz2ISjfP4MaLNHu8nfLCEs0oj1EL2nr7NYpvu1WGIFl40QmucgmvdxihuOokj0XGQZPiLwOQILIilgjlxvEiapf1YiKNJGjIqnvO0Kveth0fb0vvKuxwPRRWgrkTovLSzGQTJO(OIs9zGmnesFhHyKksYJvvnAKQXtO6KkQCls6Aek3trQ6qksL1QiHBlQlEXwwXXo2jMtBqcnNpf2QXfvwGSG5QMJf9aTWsvw4Dz0tP5aqrWlinpE8qLl)2uzaa1ybsQ8utynNJ2uI2eIa9svwGmqZvnhl6bAHLQSazGMRAoXl4Orc2pLfid0CvZbeYuiyPkdgs8lpYMJ9YB10GP8uec5QXfRSazbZvnN4fC0ibnpofrhvnEzbYcMRAoGqMcblvzbYcMRAoXl4Orc2pLvwTk(0kwzXRgt5zSkPo5KtcYCgQmTvlQSIJDSMhNoqY8kHL)ltAtlIWwTim4Zcdn408nEzbYanx1CaHmfcAECkIoQA8YcVlJEknFU)G0C(uyRMOyklqwWCvZbeYuiO5XPi6OQXlh)dVG0CaOi4fKe6NYKqsqR5aOV)t5jbvgrDPdQSmtpqeZNXQK6Ktojic9tzfh7yjuSvJxSLbkruPDs)uo(hEbP5Z8ialZxgG5Kw47OgWli)Y8O3(hYuiyznkVL5ldWCsl8Dud4fKFzE0B)dzkeSmPnTicB1IWGlgo(3IeHxM)FxeSm8Y70JPWQfvSLbkruPDs)uo(hEbP5Z8ialZxgG5Kw47OgWli)Y8jl4OrcwwJYBz(YamN0cFh1aEb5xMpzbhnsWYK20IiSvlcdUy44FlseEHfwwJYBzsl8Dud4fKMhppWYC0Ms0MqeOBoGqk8k2YOQXl)QgVmOQXltvnEHLbeIuAo2qzsl8Dud4fKMhppWY0gKWYXVdLmxJEVarkR4yhR5eFV9hEbzzsZn7PcBzoc9Fsqvlwzfh7yNy(C)bP58PWwnrXuMJ2)dLofqWliREwykduIOs7K(PSW7YONsZPniHMZNcB14Ikl8Um6P0CaOi4fKLHOhOfsOC88anx1CWo5Lh5QPPC88anx1CWqIF5rUAmLN7pijyotpqez1eTmwuALqZN9lmIQgtz(KGsR5QMdgs8lpYvJPC8agmx1CWqIF5rUAmLfid0CvZXIEGwO5XPi6OQXlt8coAKG9tzbYcMRAow0d0cnpofrhvnEz(KGsR5QMd2jV8ixnnL5)3fblt4KGs70mDObmuwGmqZvnN4fC0ibnpofrhvnE54bmyUQ5GDYlpYvttHT]] )

    storeDefault( [[Protection Primary]], 'displays', 20170313.1, [[dKttfaGEkQEPskTlqjBJI0mjqMTOUjOYTbzNKAVs7MO9l8tLuzyu43iDyidvLgmvdNsDqLYrjrogu9mqXcPKwkOQfRuTCrEic9uultj55K0evrnvvyYuIPdCrO4QGs1LvCDeTrkkpMqBMa2ou6JkPQVrGY0ur8DsuJujfoTQgnjmEkItQI0TuIRbkLZtqFgbRvjf9AcuDX7rzLihYXs4MrLGW538PA8vLVPhcLegUzujiC(nFQgFv5B6HqjHHtezdEQm8nYeQC50KlteJ(ad8LHD1jC2EYzZYivfDV8flMWxc)aLimGUx(Ift4lHFEearMb1A5lwmHVeork0oc09YWHm5HiHc)4HMQHXOSsKd5O2JQX7rzms0EESuRL3ebpvgUGEvq5BIcgrWtLHFEeyKQp2rTSgbnLVjkyebpvg(5rGrQ(yh1YWp5bPovVYa3uCddyGfEzwm92GYfu9QEugJeTNhl1A5nrWtLHlOxfu(MOGre8uz4eP0SfQYs1YAe0u(MOGre8uz4eP0SfQYs1YWp5bPovVYa3uCddyGfEzwm92GYfunm9OmgjAppwQ1YBIGNkdxqVkO8nrbJi4PYW5JYAe0u(MOGre8uz48rz4N8GuNQxzGBkUHbmWcVmlMEBq5ckO8f7n8LWppcGiZGW3Y2kqvJx(I9g(s4ePq7iq3lZkOkh(AhH7V0YljOwRLfw9YQtmkBs1gLHFYdsDQELbUGzadomWcVm8ijHjCIkgrb)LekJ2)8dewMftVnOC5lwmHVeork0oce(w2wbQA8YxS3Wxc)aLimGW3Y2kqvJx(I9g(s4ePq7iq4BzBfOQXlFXIj8LWppcGiZGW3Y2kqvJxEnPuOQXHTYS9i(O8Boc8uz1MAAz(LeYt4lHd3lFisOQnkVrcOHVeoCV8HiHQ2OmBp5SzzKQIWjsZ0upkJQgV8E14LjunE5u14fuMi1wy4h0Y3efmIGNkd)MEiusy5lwmHVe(bkryaHVLTvGQgVSsKd5e(5pnIGNkld)PRFnokVrcOHVeoCitEisOQnkRe5qowc)urQmC(nFQ(eJYNhbqKzqTwgJeTNhl1A5B6HqjHHtezdEQSmaLima1Y8ljKNWxchoKjpeju14L3whMWxchUx(qKqvdt5duEKGWxFIsAxTr5tfPs1WzfuLLvFs5T1Hj8LWHdzYdrcvTr5l2B4lHFGsegq3lFtpekjm8tfPYW538P6tmkBgvckVLEuoCnkLOkxwJGMY3efmIGNkd)MEiusy51oc3FPLxsiCgimpvVQmBJeFjHQHTYxS3Wxc)8iaImdQ1YBIGNkdNiYg8uPATwwjYHCcFl)eKqJeuwSGwa]] )


end
