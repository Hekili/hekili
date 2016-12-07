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


    storeDefault( 'SimC Import: default', 'actionLists', 20161130.1, [[dqu(Jaqirr2eLYNqvHrruDkIYQOuPDrLHHuogrwMa9mc10uQ4AuQyBkv9nOKXrPQY5Ouv16qvrL5jkCpOW(qfDqOulev4HOQuMiQk5IeInIQIQgjQkvojH0krvr2PinuuvuAPOQ6PsMku0wff1xPuvATOQu1Ej9xOAWIshwvlMsEmftgLld2SG(Signs1PHSArvVwPsZMQUns2Tu)gXWj44uQkwUINl00v56kz7OkFhvA8OQO48cy9uQY8vk7xuzvsXulr63YdmLdTsFkqRcrX3YLvukbYC85YLLbH)YFAXxq4V8NYHw8dE4JGMgKM0EjjX0CsAvMbjCAPf2Mdr6OIPMkPyQLi9B5bMYHwLzqcNwhjjXdouFWmlHlQf2wip6cO1awRDbTeTziZFKrRM0Gw8dE4JGMgKM0EjSC0elPv6tbAXpyT2f0ttdQyQLi9B5bMYHwLzqcNwhjjXdodH4zeUD0MC5wRWqNLNqy(v8ClHTnRvyO75bDcQtW5o)r3Te22SwHHoZSIpdClHTT7Ne4ChIcWpcodbzGXo0KjtlSNKOw9tbyq8mCU)Of2wip6cOLa5qKwlrBgY8hz0QjnOf)Gh(iOPbPjTxclhnXsAL(uGw8zjhI06PPIvm1sK(T8at5qRYmiHtRJKK4bNHq8mc3oQf2wip6cOfDIpao35p6AjAZqM)iJwnPbT4h8WhbnninP9sy5OjwsR0Nc0IVJ4dKlR9D(JUEA6okMAjs)wEGPCOvzgKWP1rss8GZqiEgHBh1cBlKhDb065bDcQtW5o)rxlrBgY8hz0QjnOf)Gh(iOPbPjTxclhnXsAL(uGwyZd6euNKlR9D(JUEAQDum1sK(T8at5qR0Nc0QOJaplxwsyUSzg6e4BdOf2wip6cOvKoc8mCsiopOtGVnGwI2mK5pYOvtAql(bp8rqtdstAVewoAIL0tt3RyQLi9B5bMYHwLzqcNwhjjXdodH4zeUD0MC6eFaCbcxyCM1mqFCIHDKPf2wip6cOLzwXNbAjAZqM)iJwnPbT4h8WhbnninP9sy5OjwsR0Nc0IVnR4Za90uSum1sK(T8at5qRYmiHtl6eFaCbcxyCM1mqFCIbnBhIcYiOwyBH8OlGwC)DbCsi(hPdrTeTziZFKrRM0Gw8dE4JGMgKM0EjSC0elPv6tbAzF)DHCzjH5YIDKoe1ttTFkMAjs)wEGPCOvzgKWP1BoepahAGcbXmWqSn5gcXZiCBx(flHc6Zna1J6ygjgMD3XzNTngyTcdD5xSekOp3aupQJCMyy2Dh3ESKztEMU3d95mZk(mWb9B5b22MHq8mc32zMv8zGBaQh1rotmm7guMwyBH8OlGwaFgWSoePXJqFqBaTeTziZFKrRM0Gw8dE4JGMgKM0EjSC0elPv6tbAjcFgWSoePZLTG(G2a6PP2FftTePFlpWuo0Qmds406ijjEWziepJWTJAHTfYJUaAz5jegE4AcOLOndz(JmA1Kg0IFWdFe00G0K2lHLJMyjTsFkqlo8eclxw(8RjGEAQenftTePFlpWuo0Qmds406ijjEWziepJWTJAHTfYJUaAzbteMDrDIwI2mK5pYOvtAql(bp8rqtdstAVewoAIL0k9PaT4aMim7I6e90ujjftTePFlpWuo0Qmds406ijjEWziepJWTJ2KtN4dGlq4cJZSMb6ld7itlSTqE0fqRFmFd4hzgOpTeTziZFKrRM0Gw8dE4JGMgKM0EjSC0elPv6tbAH9y(gYLftYmqF6PPsbvm1sK(T8at5qRYmiHtl5mWAfg6YVyjuqFULW2w(flHc6dNWdMbXaz2EZH4b4qduiiYjgmepud4XJmu43pjWfTzTcdDmepud4cRrGeb3sWM1km0Xq8qnGlSgbseCdq9OoMrIHz3GAHTfYJUaAXq8qnGhpYqPLOndz(JmA1Kg0IFWdFe00G0K2lHLJMyjTsFkql(cXd1qUS1rgk90ujXkMAjs)wEGPCOvzgKWPLCgyTcdD5xSekOp3syBl)ILqb9Ht4bZGyGmBV5q8aCObkee5edgIhQb84rgk87Ne4I2Ot8bWfiCHXzwZa9Xjg2XM1km0Xq8qnGlSgbseClbTW2c5rxaTyiEOgWJhzO0s0MHm)rgTAsdAXp4HpcAAqAs7LWYrtSKwPpfOfFH4HAix26idvUSYLKPNMkTJIPwI0VLhykhAvMbjCAjNbwRWqx(flHc6ZTe22YVyjuqF4eEWmigiZ2BoepahAGcbroXGH4HAapEKHc)(jbUOn6eFaCbcxyCM1mqFCIHDSjpt37H(CMzfFg4G(T8aBBZqiEgHB7mZk(mWna1J6iNjgMDfltlSTqE0fqlgIhQb84rgkTeTziZFKrRM0Gw8dE4JGMgKM0EjSC0elPv6tbAXxiEOgYLToYqLlR8GY0ttLSJIPwI0VLhykhAvMbjCAjNbwRWqx(flHc6ZTe22YVyjuqF4eEWmigiZM1km0Xq8qnGlSgbseClbBwRWqhdXd1aUWAeirWna1J6ygjgMDdAltG9zHeeaMJlDuuagCsi(rhW7)OpG9quAHTfYJUaALFfpK5NiopOtGVnGwI2mK5pYOvtAql(bp8rqtdstAVewoAIL0k9PaT4tR4Hm)WhXCzZm0jW3gqpnvAVIPwI0VLhykhAvMbjCAjNbwRWqx(flHc6ZTe22YVyjuqF4eEWmigiZgDIpaUaHlmoZAgOpoXWo2SwHHogIhQbCH1iqIGBjyltG9zHeeaMJlDuuagCsi(rhW7)OpG9quAHTfYJUaALFfpK5NiopOtGVnGwI2mK5pYOvtAql(bp8rqtdstAVewoAIL0k9PaT4tR4Hm)WhXCzZm0jW3gixw5sY0ttLWsXulr63YdmLdTkZGeoTKZaRvyOl)ILqb95wcBB5xSekOpCcpygedKzZAfg6yiEOgWfwJajcULGnRvyOJH4HAaxyncKi4gG6rDmJedZUb1cBlKhDb06akb)prCEWWqMtlrBgY8hz0QjnOf)Gh(iOPbPjTxclhnXsAL(uGwycuc(F4JyUSzgggYC6PPs2pftTePFlpWuo0Qmds40sodSwHHU8lwcf0NBjSTLFXsOG(Wj8GzqmqMn6eFaCbcxyCM1mqFCIHDSzTcdDmepud4cRrGeb3sqlSTqE0fqRdOe8)eX5bddzoTeTziZFKrRM0Gw8dE4JGMgKM0EjSC0elPv6tbAHjqj4)HpI5YMzyyiZLlRCjz6PPs2FftTePFlpWuo0Qmds40sodSwHHU8lwcf0NBjSTLFXsOG(Wj8GzqmqMn6eFaCbcxyCM1mqFCIHDSjpt37H(CMzfFg4G(T8aBBZqiEgHB7mZk(mWna1J6iNjgMDfltlSTqE0fqRdOe8)eX5bddzoTeTziZFKrRM0Gw8dE4JGMgKM0EjSC0elPv6tbAHjqj4)HpI5YMzyyiZLlR8GY0ttdstXulr63YdmLdTkZGeoTKZaRvyOl)ILqb95wcBB5xSekOpCcpygedKzJoXhaxGWfgNznd0hNyi22BoepahAGcbroXGH4HAapEKHc)(jbUOn5gcXZiCBh3FxaNeI)r6q0na1J6ygjgMDdA7Ndf(MZX93fWjH4FKoeDq)wEGTTzTcdDCPJIcWGtcXp6aE)h9bShIYTeSzTcdDCPJIcWGtcXp6aE)h9bShIYna1J6ygjgMmBYZ09EOpNzwXNboOFlpW22meINr42oZSIpdCdq9OoYzIHz3DKPf2wip6cOfdXd1aE8idLwI2mK5pYOvtAql(bp8rqtdstAVewoAIL0k9PaT4lepud5YwhzOYLvUyz6PPbLum1sK(T8at5qRYmiHtl5mWAfg6YVyjuqFULW2w(flHc6dNWdMbXaz2Ot8bWfiCHXzwZa9XjgITzTcdDmepud4cRrGeb3sWMHq8mc32X93fWjH4FKoeDdq9OoMrIHz3G2(5qHV5CC)DbCsi(hPdrh0VLhy2YeyFwibbG54shffGbNeIF0b8(p6dypeLwyBH8OlGw5xXdz(jIZd6e4BdOLOndz(JmA1Kg0IFWdFe00G0K2lHLJMyjTsFkql(0kEiZp8rmx2mdDc8TbYLvEqz6PPbdQyQLi9B5bMYHwLzqcNwYzG1km0LFXsOG(ClHTT8lwcf0hoHhmdIbYSrN4dGlq4cJZSMb6JtmeBtUHq8mc32X93fWjH4FKoeDdq9OoMrIHz3G2(5qHV5CC)DbCsi(hPdrh0VLhyBBwRWqhx6OOam4Kq8JoG3)rFa7HOClbBwRWqhx6OOam4Kq8JoG3)rFa7HOCdq9OoMrIHjZM8mDVh6ZzMv8zGd63YdSTndH4zeUTZmR4Za3aupQJCMyy2DhzAHTfYJUaADaLG)NiopyyiZPLOndz(JmA1Kg0IFWdFe00G0K2lHLJMyjTsFkqlmbkb)p8rmx2mdddzUCzLlwMEAAqXkMAjs)wEGPCOvzgKWPfDIpaUaHlmoZAgOpmOTTrN4dGlq4cJZSMb6ddjBYneINr42ol)ZaCsiE(v8qgWna1J6iNjg22MHq8mc32Xq8qnGt)POGXna1J6iNjgMSTn6eFaCbcxyCM1mqFye0MCdH4zeUTZEW7Dg6)Kar8W5nhI0VpdmO52BNTndH4zeUTZmR4ZGbpEdAxWzO)tceXdN3Cis)(mWGMBVDKPf2wip6cOf3FxaNeI)r6qulrBgY8hz0QjnOf)Gh(iOPbPjTxclhnXsAL(uGw23FxixwsyUSyhPdXCzLljtpnn4okMAjs)wEGPCOvzgKWPLH(pjqeJG2Ot8bWfiCHXzwZa9Lbg7Of2wip6cOL9G3RLOndz(JmA1Kg0IFWdFe00G0K2lHLJMyjTsFkql(E496PPbTJIPwI0VLhykhAvMbjCAzO)tceXiOn6eFaCbcxyCM1mqFzGXoAHTfYJUaAzMv8zWGhVbTlOLOndz(JmA1Kg0IFWdFe00G0K2lHLJMyjTsFkql(2SIpdMCzRBq7c6PPb3RyQLi9B5bMYHwLzqcNw0j(a4ceUW4mRzG(YaJGBBYPt8bWfiCHXzwZa9LbgITj3qiEgHB7Sh8ENH(pjqepCEZHi97ZadjN4D22meINr42oZSIpdg84nODbNH(pjqepCEZHi97ZadjN4DKjtlSTqE0fqll)ZaCsiE(v8qgqlrBgY8hz0QjnOf)Gh(iOPbPjTxclhnXsAL(uGwC4FgKlljmxw(0kEidONMgelftTePFlpWuo0Qmds40IoXhaxGWfgNznd0xgyeCBtoDIpaUaHlmoZAgOVmWqSn5gcXZiCBN9G37m0)jbI4HZBoePFFgyi5eVZ2MHq8mc32zMv8zWGhVbTl4m0)jbI4HZBoePFFgyi5eVJmzAHTfYJUaAXq8qnGt)POGrlrBgY8hz0QjnOf)Gh(iOPbPjTxclhnXsAL(uGw8fIhQHCz57Ekky0ttdA)um1sK(T8at5qRYmiHtl6eFaCbcxyCM1mqFCIH4Tn5YneINr42o7bV3zO)tceXdN3Cis)(mWqYThRTndH4zeUTZmR4ZGbpEdAxWzO)tceXdN3Cis)(mWqYThlz2KBiepJWTDmepud40FkkyCdq9OoYzIHTTziepJWTDw(Nb4Kq88R4HmGBaQh1rotmmzY22KFVh6ZLmWFWGNFXsOG(Cq)wEGz7(jbohD49hDNG540o0KPf2wip6cOv(flHc6tlrBgY8hz0QjnOf)Gh(iOPbPjTxclhnXsAL(uGw8PflHc6tpnnO9xXulr63YdmLdTsFkql(gPJGz(drATW2c5rxaTmKocM5peP1s0MHm)rgTAsdAXp4HpcAAqAs7LWYrtSKEAQyAkMAjs)wEGPCOvzgKWPLCgyTcdD5xSekOp3syBl)ILqb9Ht4bZGyGmBV5q8aCObkee5edgIhQb84rgk87Ne4I2SwHHogIhQbCH1iqIGBjOf2wip6cOfdXd1aE8idLwI2mK5pYOvtAql(bp8rqtdstAVewoAIL0k9PaT4lepud5YwhzOYLv(oY0ttflPyQLi9B5bMYHwLzqcNwYzG1km0LFXsOG(ClHTT8lwcf0hoHhmdIbYS9MdXdWHgOqqKtmyiEOgWJhzOWVFsGlAZAfg6o6aEiAGiojep)kEid4wc2KNP79qFoZSIpdCq)wEGTTziepJWTDMzfFg4gG6rDKZedZUILPf2wip6cOfdXd1aE8idLwI2mK5pYOvtAql(bp8rqtdstAVewoAIL0k9PaT4lepud5YwhzOYLvUDKPNMkoOIPwI0VLhykhAvMbjCAjNbwRWqx(flHc6ZTe22YVyjuqF4eEWmigiZ2BoepahAGcbroXGH4HAapEKHc)(jbUOn50j(a4ceUW4mRzG(4eJD22Kl3qiEgHB7Sh8ENH(pjqepCEZHi97ZadjN4D22meINr42oZSIpdg84nODbNH(pjqepCEZHi97ZadjN4DKztUHq8mc32Xq8qnGt)POGXna1J6iNjg22MHq8mc32z5FgGtcXZVIhYaUbOEuh5mXWKjtMn5z6Ep0NZmR4Zah0VLhyBBgcXZiCBNzwXNbUbOEuh5mXWS7oY0cBlKhDb0IH4HAapEKHslrBgY8hz0QjnOf)Gh(iOPbPjTxclhnXsAL(uGw8fIhQHCzRJmu5YkFVm90uXIvm1sK(T8at5qRYmiHtl5mWAfg6YVyjuqFULW2w(flHc6dNWdMbXaz2SwHHogIhQbCH1iqIGBjyltG9zHeeaMJlDuuagCsi(rhW7)OpG9quAHTfYJUaALFfpK5NiopOtGVnGwI2mK5pYOvtAql(bp8rqtdstAVewoAIL0k9PaT4tR4Hm)WhXCzZm0jW3gixw5ILPNMkEhftTePFlpWuo0Qmds40sodSwHHU8lwcf0NBjSTLFXsOG(Wj8GzqmqMnRvyOJH4HAaxyncKi4wcAHTfYJUaADaLG)NiopyyiZPLOndz(JmA1Kg0IFWdFe00G0K2lHLJMyjTsFkqlmbkb)p8rmx2mdddzUCzLVJm90uX2rXulr63YdmLdTkZGeoTKZaRvyOl)ILqb95wcBB5xSekOpCcpygedKzZAfg6o6aEiAGiojep)kEid4wc2KNP79qFoZSIpdCq)wEGTTziepJWTDMzfFg4gG6rDKZedZUILPf2wip6cO1buc(FI48GHHmNwI2mK5pYOvtAql(bp8rqtdstAVewoAIL0k9PaTWeOe8)WhXCzZmmmK5YLvUDKPNMkEVIPwI0VLhykhAvMbjCAjNbwRWqx(flHc6ZTe22YVyjuqF4eEWmigiZMC6eFaCbcxyCM1mqFCIXoBBYLBiepJWTD2dEVZq)NeiIhoV5qK(9zGHKt8oBBgcXZiCBNzwXNbdE8g0UGZq)NeiIhoV5qK(9zGHKt8oYSj3qiEgHB7yiEOgWP)uuW4gG6rDKZedBBZqiEgHB7S8pdWjH45xXdza3aupQJCMyyYKjZM8mDVh6ZzMv8zGd63YdSTndH4zeUTZmR4Za3aupQJCMyy2DhzAHTfYJUaADaLG)NiopyyiZPLOndz(JmA1Kg0IFWdFe00G0K2lHLJMyjTsFkqlmbkb)p8rmx2mdddzUCzLVxMEAQySum1sK(T8at5qRYmiHtl6eFaCbcxyCM1mqFzGXoAHTfYJUaAzp49AjAZqM)iJwnPbT4h8WhbnninP9sy5OjwsR0Nc0IVhEFUSYLKPNMk2(PyQLi9B5bMYHwLzqcNw0j(a4ceUW4mRzG(YaJD0cBlKhDb0YmR4ZGbpEdAxqlrBgY8hz0QjnOf)Gh(iOPbPjTxclhnXsAL(uGw8TzfFgm5Yw3G2fYLvUKm90uX2FftTePFlpWuo0Qmds40sodSwHHU8lwcf0NBjSTLFXsOG(Wj8GzqmqMn6eFaCbcxyCM1mqFCIHyBV5q8aCObkee5edgIhQb84rgk87Ne4I2KNP79qFoZSIpdCq)wEGTTziepJWTDMzfFg4gG6rDKZedZU2rMwyBH8OlGwmepud4XJmuAjAZqM)iJwnPbT4h8WhbnninP9sy5OjwsR0Nc0IVq8qnKlBDKHkxw5yjtpnDhAkMAjs)wEGPCOvzgKWPLCgyTcdD5xSekOp3syBl)ILqb9Ht4bZGyGmB0j(a4ceUW4mRzG(4edX2KNP79qFoZSIpdCq)wEGTTziepJWTDMzfFg4gG6rDKZedZU2rMwyBH8OlGwhqj4)jIZdggYCAjAZqM)iJwnPbT4h8WhbnninP9sy5OjwsR0Nc0ctGsW)dFeZLnZWWqMlxw5yjtp90Qead69i79hI0Akw00tva]] )

    storeDefault( 'SimC Import: precombat', 'actionLists', 20161130.1, [[d4YGbaGEiQ2fuzBKuZgLBscDBe2PuTxQDRQ9ljddv9BfdfcAWs0WLWbHuhtOfkPwkPYIrQLl4HquEk4XiADqeteczQqvtgvMUOlsIUmX1HaBMu8riuFgjFhsCyLEUugnK0YGsNKu15jbNwL7br6zKK)cfFJuAhnEdk)LMjCU2qFjedWrGSQs9eftirsvzrqihc6nnGirZIaw6Ad6eMSnXDS8r1XOkECrdaz4ksdgqtM38nJ39OXBq5V0mHZ1g6lHyaXbztjuvwZKw7EQQYrtvPIhfQPb00h7sfmqfKnLagAM0A3tHz0GH4OqnnO)5oYnNGHFEXGoHjBtChlFuDuloEvrNUJ14nO8xAMW5Adaz4ksd5qrXeCKZW4gu(Mb0bQMHFjeKomomOSbdOPp2LkyOyYBEd6FUJCZjy4NxmOtyY2e3XYhvh1IJxv0qFjediCYBENonafc5TSd5BEZ7UwEN2a]] )

    storeDefault( 'Protection ST', 'actionLists', 20161130.1, [[d8dFhaGArsTEePytKsPDHKTji7JusEmvDyiZMI5tkv9jsP4YGBJuNxqTts1Ev2nu7xu9tePYWKIXjsWPvzOKsLblLgoP4GOsNIsKJHW5iLGfsPAPuslwGLJYdPeQNsSmrQNtYerKQMkLYKPY0LCrrXRjLuptu66I4BiI)kvBgvSDejFgvTkkHmnsj08OeyKKs03runAHgVijNer5wuc6AIe6EIeTseP0Vv1OOe1Jy2MKbJcmGB2NiAa)HmhPbv3JNEOqtep70utMOJOHjAh7lWx3JZBfBtScgaPGPNUHiebr2gkIjwbKlSTJgMy58w))g3toMsfpW46pNEfHo74Jf8jkkFeX4bvNgLQ8wlmV1)VX9KJPuXdmU(ZPxrOZo(ybFIIYhrmEq15Wq(6EmYK3AP8wlkVf5R7XuQ4bgx)50Ri0zhFSGprrXaFeX4HjC919y1SnDIzBsgmkWaUzFI4zNMAsD0qkBMWLXRMGr0qkFJRtoInHBWzUk8enFDpEczy35r1ZMGFmmXkyaKcME6gIqeKq1KLyIoIgMODFDpE10tpBtYGrbgWn7tep70utQNN3auhUaglrtPMyfmasbtpDdricsOAYsmHmS78O6ztWpgMOJOHjwHGeTgMWn4mxfEcdcs0Ay10ZoBtYGrbgWn7tep70utcs4WHINHWUUNLOqoGrLOrBlKbWfLNLOqoGP6PoXXtd4IcWOad40w))g3toMk1joEAaxu(iIXdklGyIvWaifm90neHiiHQjlXeYWUZJQNnb)yyIoIgMWLuaMhyAJkVvIhyCt4gCMRcpbrkaZdmvxfpW4wnDT4Snjdgfya3Spr8Sttnb5RJuqhWa9bkTIyc3GZCv4j(hRapdv3JNqg2DEu9Sj4hdtScgaPGPNUHiebjunzjMOJOHjw8JvGNHQ7X5TwMlPlJLwn9uC2MKbJcmGB2NiE2PPM4)34EYXuQ4bgx)50Ri0zhFSGprr5JigpOsP)FJ7jhtPIhyC9NtVIqND8Xc(efLpIy8GQtJs1eUbN5QWtuXdmU(ZPxrOZo(ybFIAczy35r1ZMGFmmHRJuiShCZ(eDenmrIhyC5TpN82kc5Twp(ybFIAIvWaifm90neHiiHQjlXeRaYf22rdtSCER)FJ7jhtPIhyC9NtVIqND8Xc(efLpIy8GQtJsvERfM36)34EYXuQ4bgx)50Ri0zhFSGprr5JigpO6CyiFDpgzYBTuERfL3I819ykv8aJR)C6ve6SJpwWNOOyGpIy8WeXZonLTWAGj1rdRMEOzBsgmkWaUzFI4zNMAYeRGbqky6PBicrqcvtwIjKHDNhvpBc(XWeDenmH0M44PbCnHBWzUk8KuN44PbCTA6KmBtYGrbgWn7tep70utCqqchoubgqPaxpIOPbgfdOrhwzbPG2R9()nUNCmvGbukW1JiAAGr5JigpO0kIjCz8QjtScgaPGPNUHiebjunzjMqg2DEu9Sj4hdt0r0We7gqPaxERwIOPb2eUbN5QWtcmGsbUEertdSvtpfMTjzWOad4M9jINDAQjtScgaPGPNUHiebjunzjMqg2DEu9Sj4hdt0r0Wel(XkWZq194jCdoZvHN4FSc8muDpE101cZ2KmyuGbCZ(eXZon1KjwbdGuW0t3qeIGeQMSetid7opQE2e8JHj6iAycxsbyEGPnQ8wjEGXL3AzclnHBWzUk8eePampWuDv8aJB10jAMTjzWOad4M9jINDAQjtScgaPGPNUHiebjunzjMqg2DEu9Sj4hdt0r0WeTertdS82NtEBfH8wRhFSGprnHBWzUk8KiIMgy9NtVIqND8Xc(e1Qvti9ahuIPM9vB]] )

    storeDefault( 'Protection Defensives', 'actionLists', 20161130.1, [[d8YscaGEjK2ekk7sISnqzMsGMnr3gvzNiAVIDty)OYOKqmmj1Vbgki1GrPHtPoOK0PKaoMuTqk0sPGfdILtLNcTmkQNtvtuc1urHjJW0jDrjXZOixhuTzkz7sq(mQQrIIQlRA0s5XkCsuKdJ0Pv68su)vrFdK8AjOo9WiyfbfI8eXyqC4wBnyWIVffUuJXGgU8u)dP56oSE3uDPEq0(JLk3Is1ficjmybRo0fi8Hri7HrWkcke5jIXGKuEpi22lj4ybwCSA7CSgw(n9a4Eo2I0lqqC4wBnOsffEf8zgC)N(2EjrqdxEQ)H0CDhwhQs1M6bzsqSdQcCbfaXdwfYkxTCqFBVKycSMA7t3YVPha3hehU1wzu2(b9lVr0qAomcwrqHiprmgKKY7bzovqWXcS4y125yH2b0puGlOHlp1)qAUUdRdvPAt9Gmji2bvbUGcG4bXHBT1GW9F6V0A2ovgSkKvUA5GnQGycSMA7tBhq)qbUOH0uyeSIGcrEIymijL3dwWLFt5ybwCSA7CSq7a6hkWf0WLN6Finx3H1HQuTPEqMee7GQaxqbq8G4WT2Aq4(p9xAnBNkdwfYkxTCq5YVPtG1uBFA7a6hkWfnAqskVheAhq)qxGGJT4BDHFl09rta]] )

    storeDefault( 'Protection Cooldowns', 'actionLists', 20161130.1, [[b4vmErLxtvKBHjgBLrMxI51uofwBL51uqj3B0v2y0L2BU5hyd92BSr2B352CEnLuLXwzHnxzE5KmWeJnXadmZ41utnMCPbhDEnLxtf0y0L2BUnNxu5fDEn1uWv2yPfgBPPxy0L2BU5Lt2yJx05Lx]] )


    storeDefault( 'Retribution AOE', 'displays', 20161130.2, [[dSZVeaGEcyxOkzBOkLzksPzl0HbUPQIxlsKBt0Jvs7Kk7vA3kSFs)uKQHPQ63coVQOHIkdMYWrPdsvDucYXa5COkvluvYsvKwSiwUOEOI6PilJq9CuyIOkMkOmzvLMoKlQexvKqxwLRRuBKG60qTzvP2ok6JIK6ZGQPPk03fPyKIKyDQcgnHmEuvoPI4wuLRHQQ7jsWZiqRvKO(MijDHkSscTV99vnHddKAewGRoiXL4yYPMNAWaz4hQjL4Yyji)uTzalchgQ5VZGsLYxS08Id2Y0sPiJtnI9IrHJagIAsjoMlQ5Pgmqg(HAsjoMlQ5Pgp3BWoI6RsCmxuZtT5GmbGAsPpa(WYTunyy5vNG)LeAF7JrHvhuHvAzasI33(QK)kchgQLwmdujclNvBIKnKrpOgB(wdYeaQKdiVsewoR2ejBiJEqn28TgKjauPPx8amU6e)dXpeeVelgQeTMXSOsiS8sH)IQtCHvAzasI33(QK)kchgQLwmdujclNvBIKnKrpO237nyhrLCa5vIWYz1Mizdz0dQ99Ed2ruPPx8amU6e)dXpeeVelgQOIkrRzmlQed8aE8kXXKtnp1MdYeaQjL4yYPMNA8CVb7iQVk9SopiEN)s8v3FPPx8amU6e)dXBqqc(ZlOscTV9PMFedFiVbQ0Aj)nkOMNAFa8HLBzD)L4Yyji)uTjRHHAewGRUh)lr4b84PMNAFWdSClRtWstbd4NAZIU1ucpGxcKGJy0Zs(RiCyO2mGfHddg9vPuoeK1bXFjIfSIhWRJ)se7fJchbmeP2CigYfwjqDqLsQdQe86GkLRdQOsZb2NQbluA6HY4KnchgQ5N(sjI9wXGiwaachg1LQ)LeAF7tnEW5BfHdJstNK6ubwjhqELMEOmozJWHHA(PVusO9TVVQnznmuJWcC194FjHdduj)mgevZbY5qAkTmajX7BFvIlJLG8t1eomqQrybU6GexIlJLG8t1MbSiCyucbYWpeJs(PVOMNAFWdSClRtWs(PVOMNAFa8HLBzD)LMSggmuJefsZOUhlbdeVbsTuNdB26(lr4b84PMNAFa8HLBzD)L4yYPMNAWaz4hsn)iRiqDqL4yUOMNAWaz4hsn)iRiqDqL83OGAEQ9bpWYTSoblXXCrnp1MdYeasn)iRiqDqL4yYPMNAZbzcaPMFKveOoOsCm5uZtnEU3GDePMFKveOoOsCmxuZtnEU3GDePMFKveOoOs8CVb7iQVkQfa]] )

    storeDefault( 'Retribution Primary', 'displays', 20161130.2, [[dOZSeaGEIWUGsABqjMPGQMTOUPsQdRQBt4BcQyNu1EL2TI2pLFksQHru)MkpwHgkunysdhjhubhLi6yaDEbzHa0sruwSiwUqpeqpf1YaWZrWeHsnvOyYkjth0frkxvqjxwLRRuBer1PHSzLOTJiFuKWNrOPjs13fjzKckSorkJMinEKQoPs4wcCnrIUNGk9mKkRvqPETGIUGftzj33(wzk5Uj0ugjXvpiaLXJiXhdzk5Uj0ugjXvpiaLXJiXhdzkWNcICtth2XVC5WIWzktD5m55NG0MugNentdmfZhjEWMugNentdmf7B5VZWcyzCs0mnWuGorYdBs51p9iXwykgK4QNo5YsUV9rOyQhSyktB(j5BvbS8Wie5MMgEebyzgjaA6cbLlctZuQ4n6ejpSS)fxzgjaA6cbLlctZuQ4n6ejpSmzx(Ecx9aidIfqzz6WkyzEmIOGLHiXfUYfwpaftzAZpjFRkGLhgHi300WJialZibqtxiOCryAMU6w(7mSS)fxzgjaA6cbLlctZ0v3YFNHLj7Y3t4QhazqSaklthwblSWY4KWnnWuSVL)odnDitj9RhSmojCtdmfOtK8WMugNeUPbMI9T83zybSCO6daiD5Y0xVCzYU89eU6bqgelGG0jJvWYsUV9z6qgrCkUjS8y5Hn0zAGPRF6rITOE5Y4rK4JHmDXOBAkJK4QpD5Y4KWnnWuGorYdnDitj9RhSmpgruWYLXjrZ0atX(w(7m00HmL0VEWYHTZjQhmLLb6Oczkgxz8OdEJqKBAkEej(yOYm1LZKNFcsnfOl7Ift5VEWYX6bltSEWYj1dwyzM6grFgjXdrUz9HJCzgnjMptdmDnAIeBr9YLLCF7ZuSrXBeICZYKTifHbMYdBOZ0atxJMiXwuVCzj33(wz6Ir30ugjXvF6YLXjrZ0atX8rIh00HmL0VEWY0MFs(wvalJtIMPbMc0jsEOPdzkPF9GLX(w(7mSawEi10mnW01OjsSf1txz8is8XqMc8PGi3Sm8JepiHYmAsmFMgy66NEKylQhSmMpFtOPPi62u1lxEXOBsWuwQlvZ6tV8qQPzAGPRF6rITOE5YK7MWYdr0Nn1)XOlvL9V4kt2bJOKne5MMIhrIpgQmojCtdmfZhjEqthYus)6blJtc30atX8rIhSjLzQFenjwFklpmcrUPPaFkiYnjualt2pjEMcu6ngMOjXYFckJGHkSf]] )

    storeDefault( 'Protection Primary', 'displays', 20161130.2, [[dCtffaGEcv7sjX2ieZKqYSf1nHIUnGDsQ9kTBI2pv)uKsdJe)gXqvXGfgUioOsCusshdOddzHkflfjAXQulNspeP8uultP0ZPWevQAQQKjRuz6Q6IivxLqkxwX1HQnss8AcPAZqHTdL(OivDnrQmnLK(UsQgPif9ycgnj14juoPsk3IIonOZls(msATIu4ziHlyVkRk(Gp78qfI89GHIpvdUT8b7XdtpUqwQZ37Yhleazt5bnuYdjspwWTOYLfnJXdozYzvYid19UmNGeGsQvNUYhS09W0J9dgi883nLpyP7HPh0ia3OV3LXejgeahWJliWunfkLtdcbOAW0vMfSWKVC5d2JhMEqJaCJ(Ex(G94HPh7hmq45VBkNQAZTRQuwSQvkt5KhKXu9wfqrabPqzfWYuIKuhpOPEeeDOKAz0nmd)uLpyP7HPh0ia3O3JLCIAu1GLpypEy6XfYsDEpwYjQrvdwMHsQ5XdtpWekHa4avRu(G94HPh7hmq453JLCIAu1GLpyP7HPh7hmq453JLCIAu1GLvfFWhJEvnyVktxIUZZUUP8IWdjspef04lFSKFeEir6X(bJrAaXogL1iGP8Xs(r4HePh7hmgPbe7yuMYjpiJP6TkGIaQOqXkGLzblm5l3V6T9QmDj6op76MYlcpKi9quqJV8Xs(r4HePh0iK8oY6sJYAeWu(yj)i8qI0dAesEhzDPrzkN8GmMQ3QakcOIcfRawMfSWKVC)QPOxLPlr35zx3uEr4HePhIcA8LpwYpcpKi9GVkRrat5JL8JWdjsp4RYuo5bzmvVvbueqffkwbSmlyHjF5(9lZjJaeLHIJEirwTiIuMtMCwLmYqTh0izITxLrvdw2wnyzQvdw(UAW(LPrss5XfP8Xs(r4HePhhleaztv(G94HPh0ia3O3JLCIAu1GLvfFWhp2dTJWdjYYuUw6tZRYl4pXdtpWekHa4avRuwv8bF25XAcePhmu8P6vvkFWs3dtpUqwQZ7XsornQAWY0LO78SRBkVG)epm9atKyqaCGQvkVFWaHN)UP8sAP7HPhycLqaCGQPO8Xcbq2uEqdL8qIS8JSuN3OmdLuZJhMEGjsmiaoq1GLVq5r(EKElbpPALYRjqKgEWQjRlRE1YlPLUhMEGjsmiaoq1kLvHi)Ylwik7HgzTK1lRrat5JL8JWdjspowiaYMQ8Xcbq2uESMar6bdfFQEvLYhleazt5Hke57bdfFQgCB5dw6Ey6XfYsD(ExEr4HePh0qjpKin6MYQIp4JhlzivjWi)Yc9Bb]] )



end
