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

local removeResource = ns.removeResource

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
        addTalent( 'blade_of_wrath', 202270 )
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
        addAura( 'consecration', 188370, 'duration', 8 )
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

        addAura( 'judgment', 197277, 'duration', 9, 'feign', function ()

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
        end )


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
                state.last_cons_internal = GetTime()
                state.expire_cons_internal = state.last_cons_internal + ( 9 * state.haste )
            
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

            buff.consecration = rawget( buff, 'consecration' ) or {}
            buff.consecration.name = consecration

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

            if buff_remaining < 2.5 then return t end

            local ticks_before = math.floor( buff_remaining / 2.5 )
            local ticks_after = math.floor( max( 0, ( buff_remaining - t ) / 2.5 ) )

            state.gain( ticks_before - ticks_after, 'holy_power' )

            return t
        end )

        addHook( 'spend', function( amt, resource )
            if state.buff.crusade.up and resource == 'holy_power' then
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
            return spec.retribution and not settings.strict_finishers and cooldown.judgment.remains > gcd * 2 and holy_power.current >= 5
        end )


        -- Gear Sets
        addGearSet( 'tier19', 138350, 138353, 138356, 138359, 138362, 138369 )
        addGearSet( 'class', 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )
        addGearSet( 'ashbringer', 120978 )
        addGearSet( 'whisper_of_the_nathrezim', 137020 )
        addGearSet( 'truthguard', 128866 )


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
            return state.settings.wake_of_ashes
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
                " Finishers is disabled, Judgment remains on cooldown for 2 GCDs, and your Holy Power is greater than or equal to 5.",
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
            id = 224668,
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
            return x * ( talent.divine_intervention.enabled and 0.5 or 1 )
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
			if buff.the_fires_of_justice.up then return x - 1 end
			return x
		end )

        modifyAbility( 'execution_sentence', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'execution_sentence', function ()
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
            known = function () return equipped.truthgaurd and ( toggle.wake_of_ashes or ( toggle.cooldowns and settings.wake_of_ashes_cooldown ) ) end
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


        addAbility( 'greater_blessing_of_might', {
            id = 203528,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            usable = function () return buff.greater_blessing_of_might.down end,
        } )

        addHandler( 'greater_blessing_of_might', function ()
            applyBuff( 'greater_blessing_of_might', 3600 )
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
            recharge = 12
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
            if spec.protection then
                gainChargeTime( 'shield_of_the_righteous', 2 )
                if talent.fist_of_justice.enabled then setCooldown( 'hammer_of_justice', max( 0, cooldown.hammer_of_justice.remains - 8 ) ) end
                if talent.judgment_of_light.enabled then applyDebuff( 'target', 'judgment_of_light', 30, 40 ) end
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


        addAbility( 'seal_of_light', {
            id = 202273,
            spend = 1,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            known = function () return talent.seal_of_light.enabled end
        } )

        modifyAbility( 'seal_of_light', 'spend', function( x )
            return x - ( buff.the_fires_of_justice.up and 1 or 0 )
        end )

        addHandler( 'seal_of_light', function ()
            applyBuff( 'seal_of_light', 20 + ( 20 * min( 4, holy_power.current ) ) )
            spend( min( 4, holy_power.current ), 'holy_power' )
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
            known = function () return equipped.ashbringer and ( toggle.wake_of_ashes or ( toggle.cooldowns and settings.wake_of_ashes_cooldown ) ) end
        } )

        modifyAbility( 'wake_of_ashes', 'spend', function( x ) 
            if artifact.ashes_to_ashes.enabled then return - 5 end
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

        addHandler( 'word_of_glory', function ()
            health.actual = min( health.max, health.actual + stat.spell_power * 8 )
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


    storeDefault( 'SimC Import: default', 'actionLists', 20161130.1, [[dqu(Jaqirr2eLYNqvHrruDkIYQOuPDrLHHuogrwMa9mc10uQY1OuX2uQ8nOKXrPQY5Ouv16qvrL5jkCpOW(qfDqOulev4HOQuMiQk5IeInIQIQgjQkvojH0krvr2PinuuvuAPOQ6PsMku0wff1xPuvATOQu1Ej9xOAWIshwvlMsEmftgLld2SG(Signs1PHSArvVwPQMnvDBKSBP(nIHtWXPuvSCfpxOPRY1vY2rv(oQ04rvrX5fW6PuL5Ru2VOYQKIPwI0VLhykhAL(uGwfIIVLlROucK54ZLlldc)L)0Qead69i79hI0Akw00IFWdFe00G0K2jjrBNtsRYmiHtlTW2Cishvm1ujftTePFlpWuo0Qmds406ijjEWH6dMzjCrTW2c5rxaTgWATpOLOndz(JmA1Kg0k9PaT4hSw7dAXp4HpcAAqAs7KWYrtSKEAAqftTePFlpWuo0Qmds406ijjEWziepJWTJ2Kl3Afg6S8ecZVINBjSTzTcdDppOtqDco35p6ULW2M1km0zMv8zGBjSTD)KaN7qua(rWziidm2JMmzAH9Ke1QFkadINHZ9hTW2c5rxaTeihI0AjAZqM)iJwnPbTsFkql(SKdrAT4h8WhbnninPDsy5OjwspnvSIPwI0VLhykhAvMbjCADKKep4meINr42rTW2c5rxaTOt8bW5o)rxlrBgY8hz0QjnOv6tbAX3r8bYL1(o)rxl(bp8rqtdstANewoAIL0tt3tXulr63YdmLdTkZGeoTossIhCgcXZiC7OwyBH8OlGwppOtqDco35p6AjAZqM)iJwnPbTsFkqlS5bDcQtYL1(o)rxl(bp8rqtdstANewoAIL0ttTJIPwI0VLhykhAL(uGwfDe4z5YscZLnZqNaFBaTW2c5rxaTI0rGNHtcX5bDc8Tb0s0MHm)rgTAsdAXp4HpcAAqAs7KWYrtSKEA6oftTePFlpWuo0Qmds406ijjEWziepJWTJ2KtN4dGlq4cJZSMb6JtmSJmTW2c5rxaTmZk(mqlrBgY8hz0QjnOv6tbAX3Mv8zGw8dE4JGMgKM0ojSC0elPNMILIPwI0VLhykhAvMbjCArN4dGlq4cJZSMb6JtmOz7quqgb1cBlKhDb0I7VpGtcX)iDiQLOndz(JmA1Kg0k9PaTSV)(qUSKWCzXoshIAXp4HpcAAqAs7KWYrtSKEAQ9tXulr63YdmLdTkZGeoTEZH4b4qduiiMbgITj3qiEgHB7YVyjuqFUbOEuhZiXWS7Eo7STXaRvyOl)ILqb95gG6rDKZedZU752HLmBYZ09EOpNzwXNboOFlpW22meINr42oZSIpdCdq9OoYzIHz3GY0cBlKhDb0c4ZaM1HinEe6dAdOLOndz(JmA1Kg0k9PaTeHpdywhI05YwqFqBaT4h8WhbnninPDsy5Ojwspn1(RyQLi9B5bMYHwLzqcNwhjjXdodH4zeUDulSTqE0fqllpHWWdxtaTeTziZFKrRM0GwPpfOfhEcHLllF(1eql(bp8rqtdstANewoAIL0ttLOPyQLi9B5bMYHwLzqcNwhjjXdodH4zeUDulSTqE0fqllyIWSpQt0s0MHm)rgTAsdAL(uGwCateM9rDIw8dE4JGMgKM0ojSC0elPNMkjPyQLi9B5bMYHwLzqcNwhjjXdodH4zeUD0MC6eFaCbcxyCM1mqFzyhzAHTfYJUaA9J5Ba)iZa9PLOndz(JmA1Kg0k9PaTWEmFd5YIjzgOpT4h8WhbnninPDsy5OjwspnvkOIPwI0VLhykhAvMbjCAjNbwRWqx(flHc6ZTe22YVyjuqF4eEWmigiZ2BoepahAGcbroXGH4HAapEKHc)(jbUOnRvyOJH4HAaxyncKi4wc2SwHHogIhQbCH1iqIGBaQh1Xmsmm7gulSTqE0fqlgIhQb84rgkTeTziZFKrRM0GwPpfOfFH4HAix26idLw8dE4JGMgKM0ojSC0elPNMkjwXulr63YdmLdTkZGeoTKZaRvyOl)ILqb95wcBB5xSekOpCcpygedKz7nhIhGdnqHGiNyWq8qnGhpYqHF)Kax0gDIpaUaHlmoZAgOpoXWo2SwHHogIhQbCH1iqIGBjOf2wip6cOfdXd1aE8idLwI2mK5pYOvtAqR0Nc0IVq8qnKlBDKHkxw5sY0IFWdFe00G0K2jHLJMyj90uP9um1sK(T8at5qRYmiHtl5mWAfg6YVyjuqFULW2w(flHc6dNWdMbXaz2EZH4b4qduiiYjgmepud4XJmu43pjWfTrN4dGlq4cJZSMb6JtmSJn5z6Ep0NZmR4Zah0VLhyBBgcXZiCBNzwXNbUbOEuh5mXWSRyzAHTfYJUaAXq8qnGhpYqPLOndz(JmA1Kg0k9PaT4lepud5YwhzOYLvEqzAXp4HpcAAqAs7KWYrtSKEAQKDum1sK(T8at5qRYmiHtl5mWAfg6YVyjuqFULW2w(flHc6dNWdMbXaz2SwHHogIhQbCH1iqIGBjyZAfg6yiEOgWfwJajcUbOEuhZiXWSBqBzcSplKGaWCCPJIcWGtcXp6aE)h9bShIslSTqE0fqR8R4Hm)eX5bDc8Tb0s0MHm)rgTAsdAL(uGw8Pv8qMF4JyUSzg6e4BdOf)Gh(iOPbPjTtclhnXs6PPs7um1sK(T8at5qRYmiHtl5mWAfg6YVyjuqFULW2w(flHc6dNWdMbXaz2Ot8bWfiCHXzwZa9Xjg2XM1km0Xq8qnGlSgbseClbBzcSplKGaWCCPJIcWGtcXp6aE)h9bShIslSTqE0fqR8R4Hm)eX5bDc8Tb0s0MHm)rgTAsdAL(uGw8Pv8qMF4JyUSzg6e4BdKlRCjzAXp4HpcAAqAs7KWYrtSKEAQewkMAjs)wEGPCOvzgKWPLCgyTcdD5xSekOp3syBl)ILqb9Ht4bZGyGmBwRWqhdXd1aUWAeirWTeSzTcdDmepud4cRrGeb3aupQJzKyy2nOwyBH8OlGwhqj4)jIZdggYCAjAZqM)iJwnPbTsFkqlmbkb)p8rmx2mdddzoT4h8WhbnninPDsy5OjwspnvY(PyQLi9B5bMYHwLzqcNwYzG1km0LFXsOG(ClHTT8lwcf0hoHhmdIbYSrN4dGlq4cJZSMb6JtmSJnRvyOJH4HAaxyncKi4wcAHTfYJUaADaLG)NiopyyiZPLOndz(JmA1Kg0k9PaTWeOe8)WhXCzZmmmK5YLvUKmT4h8WhbnninPDsy5OjwspnvY(RyQLi9B5bMYHwLzqcNwYzG1km0LFXsOG(ClHTT8lwcf0hoHhmdIbYSrN4dGlq4cJZSMb6JtmSJn5z6Ep0NZmR4Zah0VLhyBBgcXZiCBNzwXNbUbOEuh5mXWSRyzAHTfYJUaADaLG)NiopyyiZPLOndz(JmA1Kg0k9PaTWeOe8)WhXCzZmmmK5YLvEqzAXp4HpcAAqAs7KWYrtSKEAAqAkMAjs)wEGPCOvzgKWPLCgyTcdD5xSekOp3syBl)ILqb9Ht4bZGyGmB0j(a4ceUW4mRzG(4edX2EZH4b4qduiiYjgmepud4XJmu43pjWfTj3qiEgHB74(7d4Kq8pshIUbOEuhZiXWSBqB)COW3CoU)(aoje)J0HOd63YdSTnRvyOJlDuuagCsi(rhW7)OpG9quULGnRvyOJlDuuagCsi(rhW7)OpG9quUbOEuhZiXWKztEMU3d95mZk(mWb9B5b22MHq8mc32zMv8zGBaQh1rotmm7UNmTW2c5rxaTyiEOgWJhzO0s0MHm)rgTAsdAL(uGw8fIhQHCzRJmu5YkxSmT4h8WhbnninPDsy5OjwspnnOKIPwI0VLhykhAvMbjCAjNbwRWqx(flHc6ZTe22YVyjuqF4eEWmigiZgDIpaUaHlmoZAgOpoXqSnRvyOJH4HAaxyncKi4wc2meINr42oU)(aoje)J0HOBaQh1Xmsmm7g02phk8nNJ7VpGtcX)iDi6G(T8aZwMa7Zcjiamhx6OOam4Kq8JoG3)rFa7HO0cBlKhDb0k)kEiZprCEqNaFBaTeTziZFKrRM0GwPpfOfFAfpK5h(iMlBMHob(2a5YkpOmT4h8WhbnninPDsy5OjwspnnyqftTePFlpWuo0Qmds40sodSwHHU8lwcf0NBjSTLFXsOG(Wj8GzqmqMn6eFaCbcxyCM1mqFCIHyBYneINr42oU)(aoje)J0HOBaQh1Xmsmm7g02phk8nNJ7VpGtcX)iDi6G(T8aBBZAfg64shffGbNeIF0b8(p6dypeLBjyZAfg64shffGbNeIF0b8(p6dypeLBaQh1Xmsmmz2KNP79qFoZSIpdCq)wEGTTziepJWTDMzfFg4gG6rDKZedZU7jtlSTqE0fqRdOe8)eX5bddzoTeTziZFKrRM0GwPpfOfMaLG)h(iMlBMHHHmxUSYfltl(bp8rqtdstANewoAIL0ttdkwXulr63YdmLdTkZGeoTOt8bWfiCHXzwZa9HbTTn6eFaCbcxyCM1mqFyiztUHq8mc32z5FgGtcXZVIhYaUbOEuh5mXW22meINr42ogIhQbC6pffmUbOEuh5mXWKTTrN4dGlq4cJZSMb6dJG2KBiepJWTD2dEVZq)NeiIhoV5qK(9zGbn3o7STziepJWTDMzfFgm4XBq7dod9FsGiE48Mdr63Nbg0C7SJmTW2c5rxaT4(7d4Kq8pshIAjAZqM)iJwnPbTsFkql77VpKlljmxwSJ0HyUSYLKPf)Gh(iOPbPjTtclhnXs6PPb3tXulr63YdmLdTkZGeoTm0)jbIye0gDIpaUaHlmoZAgOVmWypTW2c5rxaTSh8ETeTziZFKrRM0GwPpfOfFp8ET4h8WhbnninPDsy5OjwspnnODum1sK(T8at5qRYmiHtld9FsGigbTrN4dGlq4cJZSMb6ldm2tlSTqE0fqlZSIpdg84nO9bTeTziZFKrRM0GwPpfOfFBwXNbtUS1nO9bT4h8WhbnninPDsy5Ojwspnn4oftTePFlpWuo0Qmds40IoXhaxGWfgNznd0xgyeCBtoDIpaUaHlmoZAgOVmWqSn5gcXZiCBN9G37m0)jbI4HZBoePFFgyi5eV32MHq8mc32zMv8zWGhVbTp4m0)jbI4HZBoePFFgyi5eVNmzAHTfYJUaAz5FgGtcXZVIhYaAjAZqM)iJwnPbTsFkqlo8pdYLLeMllFAfpKb0IFWdFe00G0K2jHLJMyj900GyPyQLi9B5bMYHwLzqcNw0j(a4ceUW4mRzG(YaJGBBYPt8bWfiCHXzwZa9LbgITj3qiEgHB7Sh8ENH(pjqepCEZHi97ZadjN4922meINr42oZSIpdg84nO9bNH(pjqepCEZHi97ZadjN49KjtlSTqE0fqlgIhQbC6pffmAjAZqM)iJwnPbTsFkql(cXd1qUS8DpffmAXp4HpcAAqAs7KWYrtSKEAAq7NIPwI0VLhykhAvMbjCArN4dGlq4cJZSMb6JtmeVTjxUHq8mc32zp49od9FsGiE48Mdr63NbgsUDyTTziepJWTDMzfFgm4XBq7dod9FsGiE48Mdr63NbgsUDyjZMCdH4zeUTJH4HAaN(trbJBaQh1rotmSTndH4zeUTZY)maNeINFfpKbCdq9OoYzIHjt22M879qFUKb(dg88lwcf0Nd63YdmB3pjW5OdV)O7emhN2HMmTW2c5rxaTYVyjuqFAjAZqM)iJwnPbTsFkql(0ILqb9Pf)Gh(iOPbPjTtclhnXs6PPbT)kMAjs)wEGPCOv6tbAX3iDemZFisRf2wip6cOLH0rWm)HiTwI2mK5pYOvtAql(bp8rqtdstANewoAIL0ttfttXulr63YdmLdTkZGeoTKZaRvyOl)ILqb95wcBB5xSekOpCcpygedKz7nhIhGdnqHGiNyWq8qnGhpYqHF)Kax0M1km0Xq8qnGlSgbseClbTW2c5rxaTyiEOgWJhzO0s0MHm)rgTAsdAL(uGw8fIhQHCzRJmu5YkFpzAXp4HpcAAqAs7KWYrtSKEAQyjftTePFlpWuo0Qmds40sodSwHHU8lwcf0NBjSTLFXsOG(Wj8GzqmqMT3CiEao0afcICIbdXd1aE8idf(9tcCrBwRWq3rhWdrdeXjH45xXdza3sWM8mDVh6ZzMv8zGd63YdSTndH4zeUTZmR4Za3aupQJCMyy2vSmTW2c5rxaTyiEOgWJhzO0s0MHm)rgTAsdAL(uGw8fIhQHCzRJmu5Yk3oY0IFWdFe00G0K2jHLJMyj90uXbvm1sK(T8at5qRYmiHtl5mWAfg6YVyjuqFULW2w(flHc6dNWdMbXaz2EZH4b4qduiiYjgmepud4XJmu43pjWfTjNoXhaxGWfgNznd0hNyS32MC5gcXZiCBN9G37m0)jbI4HZBoePFFgyi5eV32MHq8mc32zMv8zWGhVbTp4m0)jbI4HZBoePFFgyi5eVNmBYneINr42ogIhQbC6pffmUbOEuh5mXW22meINr42ol)ZaCsiE(v8qgWna1J6iNjgMmzYSjpt37H(CMzfFg4G(T8aBBZqiEgHB7mZk(mWna1J6iNjgMD3tMwyBH8OlGwmepud4XJmuAjAZqM)iJwnPbTsFkql(cXd1qUS1rgQCzLVtMw8dE4JGMgKM0ojSC0elPNMkwSIPwI0VLhykhAvMbjCAjNbwRWqx(flHc6ZTe22YVyjuqF4eEWmigiZM1km0Xq8qnGlSgbseClbBzcSplKGaWCCPJIcWGtcXp6aE)h9bShIslSTqE0fqR8R4Hm)eX5bDc8Tb0s0MHm)rgTAsdAL(uGw8Pv8qMF4JyUSzg6e4BdKlRCXY0IFWdFe00G0K2jHLJMyj90uX7PyQLi9B5bMYHwLzqcNwYzG1km0LFXsOG(ClHTT8lwcf0hoHhmdIbYSzTcdDmepud4cRrGeb3sqlSTqE0fqRdOe8)eX5bddzoTeTziZFKrRM0GwPpfOfMaLG)h(iMlBMHHHmxUSY3tMw8dE4JGMgKM0ojSC0elPNMk2okMAjs)wEGPCOvzgKWPLCgyTcdD5xSekOp3syBl)ILqb9Ht4bZGyGmBwRWq3rhWdrdeXjH45xXdza3sWM8mDVh6ZzMv8zGd63YdSTndH4zeUTZmR4Za3aupQJCMyy2vSmTW2c5rxaToGsW)teNhmmK50s0MHm)rgTAsdAL(uGwycuc(F4JyUSzgggYC5Yk3oY0IFWdFe00G0K2jHLJMyj90uX7um1sK(T8at5qRYmiHtl5mWAfg6YVyjuqFULW2w(flHc6dNWdMbXaz2KtN4dGlq4cJZSMb6Jtm2BBtUCdH4zeUTZEW7Dg6)Kar8W5nhI0VpdmKCI3BBZqiEgHB7mZk(myWJ3G2hCg6)Kar8W5nhI0VpdmKCI3tMn5gcXZiCBhdXd1ao9NIcg3aupQJCMyyBBgcXZiCBNL)zaojep)kEid4gG6rDKZedtMmz2KNP79qFoZSIpdCq)wEGTTziepJWTDMzfFg4gG6rDKZedZU7jtlSTqE0fqRdOe8)eX5bddzoTeTziZFKrRM0GwPpfOfMaLG)h(iMlBMHHHmxUSY3jtl(bp8rqtdstANewoAIL0ttfJLIPwI0VLhykhAvMbjCArN4dGlq4cJZSMb6ldm2tlSTqE0fql7bVxlrBgY8hz0QjnOv6tbAX3dVpxw5sY0IFWdFe00G0K2jHLJMyj90uX2pftTePFlpWuo0Qmds40IoXhaxGWfgNznd0xgySNwyBH8OlGwMzfFgm4XBq7dAjAZqM)iJwnPbTsFkql(2SIpdMCzRBq7d5YkxsMw8dE4JGMgKM0ojSC0elPNMk2(RyQLi9B5bMYHwLzqcNwYzG1km0LFXsOG(ClHTT8lwcf0hoHhmdIbYSrN4dGlq4cJZSMb6JtmeB7nhIhGdnqHGiNyWq8qnGhpYqHF)Kax0M8mDVh6ZzMv8zGd63YdSTndH4zeUTZmR4Za3aupQJCMyy21oY0cBlKhDb0IH4HAapEKHslrBgY8hz0QjnOv6tbAXxiEOgYLToYqLlRCSKPf)Gh(iOPbPjTtclhnXs6PP7rtXulr63YdmLdTkZGeoTKZaRvyOl)ILqb95wcBB5xSekOpCcpygedKzJoXhaxGWfgNznd0hNyi2M8mDVh6ZzMv8zGd63YdSTndH4zeUTZmR4Za3aupQJCMyy21oY0cBlKhDb06akb)prCEWWqMtlrBgY8hz0QjnOv6tbAHjqj4)HpI5YMzyyiZLlRCSKPf)Gh(iOPbPjTtclhnXs6PNw8fe(l)PCONQa]] )

    storeDefault( 'SimC Import: precombat', 'actionLists', 20161130.1, [[d4YGbaGEis7csTnOYSr5MivDBeTtPAVu7wv7xsnmu1VvmuiKbljdNuDqO0XeAHs0sjPwmjwUGhcH6PGhJW6GGMieyQiLjJktx0fjLUmX1Hi2mP4JsiFgjFhs8nsYHvA0qupxkNucopK0Pv5EsOwgu1FHINHuzhnndA)vHjCU0qFjfdWrI46QcK6tiryDLEqigsLnna6cXTSdPBEZ7UkEdQfMSnXD88rCXipo0rdar40tdgWsK38ntZ9OPzq7VkmHZLg6lPyOOGSPeQRkzsRDpvD1OPUI(Jc50awLJDjQgOcYMsaJctAT7PWmAWqEuiNgk8ChXMtWWpVyqTWKTjUJNpIlQcnpDrNUJ30mO9xfMW5sdar40td5qrXe0eZW4gu(MbSbQMHFjLIhghgu2GbSkh7sunOp5nVHcp3rS5em8Zlg6lPyartEZBqTWKTjUJNpIlQcnpDrNonGarZIew6sN2a]] )

    storeDefault( 'Protection ST', 'actionLists', 20161130.1, [[d4tChaGArIwpIISjsPyxizBuQ2hPeUmy2umFsj6tKsvpMQUns9teLQDsQ2RQDd1(LIrrjQHjIXrjuNxqgkPKAWIQHtkoiQ0POe5yiCoeLyHcQLsPSybwokpKsipLyzIINtYPvmvkPjtLPl5IIsVMusEMi11LsFdr8xPAZOITls6ZOQvrjW0qusZJuknskb9DevJwOXJOWjrKUfPu5AikL7jsyLikQdd53k9jU1lzXOad4E4lIgWpiZqMq1S4RB3(fXZgn1Ll2adGuW1ZKqyNijjnfXfBaYfY6qdxSCtUFxJBjhtPIdyC9LtVIqNn8Xc2wfLpIy8GQtJiJMCTRj3VRXTKJPuXbmU(YPxrOZg(ybBRIYhrmEq15Wq(AwmY0KBPMClOjh5RzXuQ4agxF50Ri0zdFSGTvrXaFeX4HlC91Sy1TEDIB9swmkWaUh(I4zJM6sn0qksUWLXRUGr0qkwJRtoIDHBWyMk0fnBnl(cPy34r1YUGxmCrhrdx06TMfFXgyaKcUEMec7eKqLKM411ZCRxYIrbgW9WxepB0uxQLN3audUagRvtPUydmasbxptcHDcsOsstCHuSB8OAzxWlgUWnymtf6cdcA1k4IoIgUydcA1k411tFRxYIrbgW9WxepB0uxcA5WHINHWUUN1QqoGr1QrBkKbWfLN1QqoGP6PS1Xtd4IcWOad40g)Ug3soMkLToEAaxu(iIXdkTL4InWaifC9mje2jiHkjnXfsXUXJQLDbVy4c3GXmvOlOubmpWuDvCaJ7IoIgUWnvaZdmTx1KlXbmUxxNSERxYIrbgW9WxepB0uxq(Asf6agOhqPfex4gmMPcDXVyf4zOAw8fsXUXJQLDbVy4IoIgUyrlwbEgQMf3KBzUK9Sw6InWaifC9mje2jiHkjnXRRt2U1lzXOad4E4lINnAQl(DnULCmLkoGX1xo9kcD2WhlyBvu(iIXdQu4314wYXuQ4agxF50Ri0zdFSGTvr5JigpO60iY4c3GXmvOlQ4agxF50Ri0zdFSGTvDHuSB8OAzxWlgUW1Lkc7b3dFrhrdxK4agxt(YPjVIqtUTHpwW2QUydmasbxptcHDcsOsstCXgGCHSo0Wfl3K7314wYXuQ4agxF50Ri0zdFSGTvr5JigpO60iYOjx7AY97ACl5ykvCaJRVC6ve6SHpwW2QO8reJhuDomKVMfJmn5wQj3cAYr(AwmLkoGX1xo9kcD2WhlyBvumWhrmE4I4zJMYAinWLAOHxx3(TEjlgfya3dFr8SrtD5InWaifC9mje2jiHkjnXfsXUXJQLDbVy4c3GXmvOlPS1Xtd46IoIgUqMBD80aUEDDsU1lzXOad4E4lINnAQloiOLdhQadOuGRhr00aJIb0ObR0wlwl1s)Ug3soMkWakf46rennWO8reJhuAbXfUmE1Ll2adGuW1ZKqyNGeQK0exif7gpQw2f8IHlCdgZuHUeyaLcC9iIMgyx0r0WLWgqPaxtUfIOPb2RRBX36LSyuGbCp8fXZgn1Ll2adGuW1ZKqyNGeQK0exif7gpQw2f8IHlCdgZuHU4xSc8munl(IoIgUyrlwbEgQMf)66KLB9swmkWaUh(I4zJM6YfBGbqk46zsiStqcvsAIlKIDJhvl7cEXWfUbJzQqxqPcyEGP6Q4ag3fDenCHBQaMhyAVQjxIdyCn5wMWsVUorYTEjlgfya3dFr8SrtD5InWaifC9mje2jiHkjnXfsXUXJQLDbVy4c3GXmvOlrennW6lNEfHoB4JfSTQl6iA4IfIOPbwt(YPjVIqtUTHpwW2QE96IoIgUO1STaFnlUjxS(6ha]] )

    storeDefault( 'Protection Defensives', 'actionLists', 20161130.1, [[d8cqcaGEPQ0Miq2LuLTPQmtPQA2eDBkYor0Ef7gv7hjJIIIHrv(TkdLagmsnCk5GsLoffvDmfwivLLsilwvSCQ8uOLrHEUetKIktvv1Kry6KUOuXLbxNqTzk12jq9zkyKuu6XsA0s5WOCsvjpJGoTsNNQQ)QOVPk1RLQIZi)b7WzpsGi(csYmbbfWDku194u0MdSbEzfmuckcKaRaH0O34B45jS3iiwDRLgmy3QUhVK)qoYFWoC2JeiIVGKmtqqSTGKGI(SPO1gqrlAn0u4exOOnZW8bXQBT0GkJ3NLBqqIlWS0wqseueibwbcPrVX34DppHJGV4eBLPNli)4qWUpRCv)blTfKeZZEQny6wdnfoXLGy1Tw6VFliyznvJgsJ5pyho7rceXxqsMjiOzzCck6ZMIwBafTaUtHQEUGIajWkqin6n(gV75jCe8fNyRm9Cb5hhc29zLR6pyJXjMN9uBW0YDku1ZfeRU1sdkUaZciTNnGjJgsH5pyho7rceXxqsMjiy)RHMsrF2u0AdOOfWDku1ZfueibwbcPrVX34DppHJGV4eBLPNli)4qWUpRCv)bLRHMop7P2GPL7uOQNliwDRLguCbMfqApBatgnAq0cQltU9LP7Xd53x0ea]] )

    storeDefault( 'Protection Cooldowns', 'actionLists', 20161130.1, [[dOsxbaGEjs7cQSnjmBkDBQKDkP9s2Tu7xLAyi8BLgQeXGvrdxfoOk5yu1crklfjTybwUqpKkvpfSmO0ZPIPkOjJOPl6IqXLrTzfX2vu9vQu(mf(osmAfLhRWjvKoSQonKZtrpdP6Bsu)fQA5vOam9hyzsrtq9DXckjUjps023NUVRLCP0ocOYw(DyvXs4l8ee0X5fah8a9wuPFI2w1IcbxJeTTJcv1Rqby6pWYKIMG67IfCnNBduBCF6w8ZzcOYw(DyvXs4l8LXrq3lyAtIgFUrb92SGRaKfLMc(5CBGAd8uIFotamIOJuqUggwg3yxl5sPDuQkwfkat)bwMu0euFxSamM895o5(m0mkGkB53HvflHVWxghbDVGPnjA85gf0BZcUcqwuAkGnz87e8PzuamIOJuGsLcGreDKcukb]] )


    storeDefault( 'Retribution AOE', 'displays', 20161130.1, [[dSZKeaGEIk7cuPTjsYmfjmBbhg4MkONdIBtvxdP0ojSxPDlQ9t6NIunmvPFl05vfnuKmykdNihKkDuKIJPKZHiLfQkSufyXIy5k6HG0trTme16avyIiOPQQAYiIPd1fvORsuv9mrkxxP2isLVruv2mcSDe6JIe9zqzAis(UiPgjIu9yvLrtugpsvNeu1TOItd5EevPlRYAbv0RjQI7Q)LPzF7Je1OlMXQXi5UkwKltrKsnh1(btyhUjLPMipy(unOajmkMvZDpbLlpVqzOJI)XbLLFiNAS0fc0faqK1KYSe4dLHvbTLPioQMJAeEea2bCFuMI4OAoQbn6ta4MuEiGEKF7v7h5Vks7TmCgJ(kw0wMIiLAoQr4rayhWQ5gKKbQyvMIiLAoQbn6ta4MuMIiLAoQr4rayhW9r5Nv4SinAltFfVLhCHda5QG87kvR1BQG7Q8aqg2Pguz3N8GYWkdsqbe(zzkIJQ5Og0OpbGvZnijduXQm1e5bZNQb)xmRgJK7QGuVLPisPMJAqJ(eawn3GKmqfRY83ejHldbLHfUYuehvZrncpca7awn3GKmqfRYmkdlCQ5O2qug53(ksRS7ghvZrTHa6r(TVI3YS0fc0faqKPg0yio7FzqfRYZkwLHvXQCsfRIlZs3hceqYbWOyUc57TS7ghvZrTHOmYV9vKwzA23(uJq08(WOyU8a4tjP)xMWJaWoG7JY0SV9rIAW)fZQXi5Uki1BzkIJQ5O2pyc7WQ5gKKbQyvEmdschj9rzkIuQ5O2pyc7WQ5gKKbQyvMrzyHtnh1gcOh53(kEl7M(OAoQneLr(TVI0k)dcxgRwkNXTufVLH)lMHOgllM6CfKQSB6JQ5O2qa9i)2xXBzQjYdMpvdkqcJI5YyWe2HHuMAI8G5t1OlMXQXi5UkwKltxmJl7orGGAcWCgtDzbWFLhC4jkzJrXSAUPpwgAu6PA)XYdo8eLSXOywn30hltrCunh1(btyhUjLPzF7ds)Ry1)YJzqs4iPpk7(HrXSAPabbxb5YcG)kZipu1G3lfNy4qnP59f9jaC5bx4aqUki)UODTGlzYRY83ejHlJr(tEFlUcY9V8ygKeos6JYUFyumRwkqqWvSkla(RmJ8qvdEVuCIHd1i5iaSd4YdUWbGCvq(Dr7AbxYKxfxCz3pmkMvdkqcJIzi9rzA23(uZnGGL9xgx(R4wa]] )

    storeDefault( 'Retribution Primary', 'displays', 20161130.1, [[dOZHeaGEKKDHeSnHKzssLzlQBQqDyvDBsTosQANeTxPDRO9t1pfcnmc(TGNjenuigmLHJuhubhLq5yaopjzHkjlfOAXc1Yf5HqQNIAzkKNJGjcjMkqMmK00H6IiQRIeYLv56k1grIonOndu2oc9rHGpJitti13jP0ijuLhReJMqgpsQtQK6wK4AKuCpcv8AKqTwcv13iuPlqbvwS9TpuDJYWe7gdP6QeyuzKeu)jvUrzyIDJHuDvcmQmscQ)Kk3q)0yyy62Wo9Lltreo3y6lNPm)ee14Yiej7MIBG(ePd34Yiej7MIBOCG97mURkJqKSBkUHoOJFCJlp(PgQ3A3ab1xLrkuw8dbDLaQPmVKG04YLriI4MIBOd64h34YierCtXnuoW(Dg3vLvvPYOOfktDLcLb)Y3t4QCKaquaacrrbGYITV952qgsAQVjU8s5Hno4MIBJFQH6TUsHYijO(tQCB9sy6gdP6QmAHYmCskFUP42y4eQ36kfkd(pjDUHw0TqXWjPYFmmdXQkpSGHHPBOFAmmmj0vLz6FbojvPAkJqeXnf3a9jshUXLz6lNPm)ee5g6qoKkOYFLaLJReOmPkbkNQeO4YOd0QCduOmskGVfmmmDdjb1FsvzeIiUP4gOpr6WUnKPf9vcuwS9Tp3qbMUfmmmld(6iiEGklF9vg8dNGXBmmmDdjb1FsvzX23(q1T1lHPBmKQRYOfktzyIlpKGF2n5Nsb1wM88JZhQDv5His2nf3g)ud1BDLcLxVeMeCJffu7SYOlperYUP42y4eQ36kJSmOpFtSBrif20vkuMHts5Znf3g)ud1BDLaLrsq9Nu5g6NgddZY4pr6WekJYb2VZ4UQmcrYUP4g6Go(XUnKPf9vcugHiz3uCd0NiDy3gY0I(kbkpSXb3uCBmCc1BDLcLriI4MIBOd64h72qMw0xjqzM(wGFgs1JHHzLIRqzX23(iuqvcuqLjp)48HAxvEybddt3uhKaUYrLLV(kZqnA3wRPdjS6DJoDlbD8Jld(LVNWv5ibGOaeeIKcaL5LeKgxgd1N4iuCLJkOYKNFC(qTRkpSGHHPBQdsaxjqz5RVYmuJ2T1A6qcRE3q9a73zCzWV89eUkhjaefGGqKuaO4IlJqKSBkUHYb2VZy3gY0I(kbkJqeXnf3q5a73zSBdzArFLaf3ca]] )

    storeDefault( 'Protection Primary', 'displays', 20161130.1, [[dCZ3eaGEIKDPqABqjZuvrZwk3uvLBRIDsyVu7wW(f9tfcdJO(nQgQknyjdNuoOcoQq4yQYHbwiu0srrTyfz5s1djINISmfQNlutuvPPQOMmuy6GUik5Qcr6YkDDOAJKeptvvBgfz7OWhvi6XKyAeP(ouQgPqeNgYOjPgpjPtQQWTivxdkLZlK(mk1AfIQxleL9ZZMIaFXxmYsfEaMfHKAT4n20TJoGE0SuHhGzriPwlEJnD7OdOhnljaniIhYAaVdmzksJ3SiTT1uPbIv7jtxgSYspRzqN9c9KPldwzPN13LjaEdAmnDzWkl9SKWptaONm9dOk6GFYAgDwl(lBkc8fFJ9SfppBIvam1wmmMMguGiEiRprXqlK2KaCwt3ohUkqepK13LPneJySXMyEBliETyS8dRNS8)rFMiLosdAYqlg7ztScGP2IHX00GceXdz9jkgAb2mjaN10TZHRceXdzjHZByWXEi2eZBBbXRfJLFy9KL)p6ZeP0rAqtgAXFpBIvam1wmmMMguGiEiRprXql(BsaoRPBNdxfiIhYIMnX82wq8AXy5hwpz5)J(mrkDKg0KHgA6Y4MLEwFxMa4nywdnn1alEMUmUzPNLe(zca9KPlJBw6z9DzcG3GgttrTqFS0YMu1cztmVTfeVwmw(H17jJ1OptrGV4Bwdne7WzdqtkMUmyLLEws4NjamRHMMAGfpt3o6a6rZ6dfEilcj1AH0YMUmUzPNLe(zcaZAOPPgyXZeP0rAqtMUmyLLEwFxMa4nywdnn1alEMICo)yXdBMKW1IM1m30TZHRceXdzD7OdOh1ePTTMknqS6SKWB8UNnbS4zQBXZeBlEMMS4zOjsBvqGgskaeXdwGfwMiuGDBZspRFOa6GFSq2ue4l(M1xuFvGiEWeZFmYiz20aoKNLEw)qb0b)yHSPiWx8fJS(qHhYIqsTwiTSPldwzPN1mOZEHzn00udS4zIvam1wmmMMgWH8S0Z6hqv0b)yHSPVlta8g0tMggbRS0Z6hkGo4hl(B62rhqpAwsaAqepycc6SxySjcfy32S0Z6hqv0b)yXZ0mOTbywJSZX1Sq20hk8qCwKAo2dwiTPHrWkl9S(bufDWpwiBsfEaAAOJaTSeGENJDtcWznD7C4Qar8qw3o6a6rnDzCZspRzqN9cZAOPPgyXZ0LXnl9SMbD2l0tMinGckW2cSzAqbI4HSKa0GiEi2yAIzqG9MLe1RsKHcSnbMqnemQH2a]] )


end
