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


    storeDefault( [[SimC Retribution: default]], 'actionLists', 20170402.125703, [[dyKgPaqiiswKisztKuFsejJsK6uIKvPuLDbPHbKJPuwgeEMiQPbrCnkeBterFdqnokKCoLQcRJcPK5jcUhGSpc4GeOfscEij0eHi1fjrTrkKIgPsvrNKc1kvQQ6MuIDsrdLcPulLe5PunviQTkIWxfrQwlfsH9I6Vi1GvsDyOwmHEmPMmrxwAZe0NbQrdWPrSArOxRuz2cUTq7wXVv1WPuhNcPA5GEUOMUkxhjBxj(ofmELQkNNsA9kvLMpjz)kjZBmYSR8GfdvYkWUBxnbhi7l(i)WMadIDKUcXuHJvGDLAO4CzteG2aguYimk0n2DnKyFSZUG6J8tMrMn3yKzx5blgQKvGDxdj2h73dgCOOK5keszFz2nXXYUsvKAxzxqrsGCwzhwrQDLDLAO4CzteG2aEde7kcO6Dw(Lg7CSi7gpsIgFpK95NYULxAIJLD(ytemYSR8GfdvYkWURHe7J97bdouu7)i)KvNoTiLqHOIH)LbQ8HszRsLiLqHO4LoGjdyAdq8baLYwLkrkHcr1qQmwwukB1IucfIQHuzSSOWgXKjNacJOs1HHG7HEKyPVNwsAcaHeqPsXUGIKa5SYU9FKFy34rs047HSp)u2nXXYUr7)i)WUGqWz2hCSaL0(GK2agM0yxPgkox2ebOnG3aXUIaQENLFPXohlYULxAIJL9K2hK0gWWKgFSzYmYSR8GfdvYkWURHe7J97bdouu9)b5ByYSBIJLDfc)lxT2Ojf0k7ckscKZk7IH)L0cPGwzxPgkox2ebOnG3aXUIaQENLFPXohlYUXJKOX3dzF(PSB5LM4yzNp2ejmYSR8GfdvYkWURHe7J97bdouu9)b5ByYSBIJLDfkmx4oYaMDbfjbYzLDXcZfUJmGzxPgkox2ebOnG3aXUIaQENLFPXohlYUXJKOX3dzF(PSB5LM4yzNp20imYSR8GfdvYkWURHe7J97bdouu9)b5ByYQtd4dwPTFdfIQPGWoxcgrDArkHcr1qQmwwukBvQePekefV0bmzatBaIpaOu2QuDKytarQuSBIJLDbHA80vRr(HWoh7ckscKZk7yOgpL(EiSZXUsnuCUSjcqBaVbIDfbu9ol)sJDowKDJhjrJVhY(8tz3YlnXXYoFSzsYiZUYdwmujRa7UgsSp2psSjGGDtCSSV)usWXoh7ckscKZk7jsjbh7CSRudfNlBIa0gWBGyxravVZYV0yNJfz34rs047HSp)u2T8stCSSZhBcmJm7kpyXqLScS7AiX(y)iXMac1PRrNIyBxj6wYadcjgLkvqSUOIH)L0nimf7M4yzxHaw2vRFHRwV)u5JOl7ckscKZk7IbSS0Vq6ePYhrx2vQHIZLnraAd4nqSRiGQ3z5xASZXISB8ijA89q2NFk7wEPjow25Jnnkgz2vEWIHkzfy31qI9X(rInbeQtxJofX2Us0TKbgesmkvQGyDrfd)lPBqyk2nXXYostwitxTEFIJXczxqrsGCwzxswitPbGJXczxPgkox2ebOnG3aXUIaQENLFPXohlYUXJKOX3dzF(PSB5LM4yzNp2CFWiZUYdwmujRa7UgsSp2b8bR02VHcr1uqyNlbG2uFKytab7M4yzpPJ31vRFHRwlygqZSlOijqoRSBaVR0VqACgqZSRudfNlBIa0gWBGyxravVZYV0yNJfz34rs047HSp)u2T8stCSSZhBUbIrMDLhSyOswb2DnKyFSFpyWHIQ)piFdtMDtCSSVp)G1vRt6q8bGDbfjbYzLDaFWkTbi(aWUsnuCUSjcqBaVbIDfbu9ol)sJDowKDJhjrJVhY(8tz3YlnXXYoFS52gJm7kpyXqLScS7AiX(y)EWGdfv)Fq(gMm7M4yzxWLoGjd4vRt6q8bGDbfjbYzLD8shWKbmTbi(aWUsnuCUSjcqBaVbIDfbu9ol)sJDowKDJhjrJVhY(8tz3YlnXXYoFS5gcgz2vEWIHkzfy3ehl7oasdYvRFHRwNeDax8Ol7ckscKZk7zaKgK0Vq6LoGlE0LDLAO4CzteG2aEde7gpsIgFpK95NYUIaQENLFPXohlYULxAIJLD(yZTKzKzx5blgQKvGDxdj2h73dgCOO6)dY3WKvNgWhSsB)gkevtbHDobaYiQrQA0Pi22vIULmWGqIrPsv601OtrSTReDlzGbHeJsLkiwxuXW)s6geMsnGpyL2(nuiQMcc7CcaeIuPy3ehl7kcPYyzzxqrsGCwzxdPYyzzxPgkox2ebOnG3aXUIaQENLFPXohlYUXJKOX3dzF(PSB5LM4yzNp2CdjmYSR8GfdvYkWURHe7JDS(ilLUtJKMtaOKvNw)Fq(gg0ePKGJDouyJyYKtaSwUhsqnIkvYksjuiAIusWXohkSrmzYcawl3djOgjL60i1HdDounKkJLfTdwmuPkv6)dY3WGQHuzSSOWgXKjlayTCpePy3ehl7kVFvtDKFwT27CD0LDbfjbYzL9UFvtDKFOZDUo6YUsnuCUSjcqBaVbIDfbu9ol)sJDowKDJhjrJVhY(8tz3YlnXXYoFS5MryKzx5blgQKvGDxdj2h7jsjbh7C0)sHqISQX6JSu6onsAwaGKKfYu689Wi9HHG7LvlsjuiQKSqMsBtbT)CrPSvlsjuiQKSqMsBtbT)CrHnIjtobWA5Eiy3ehl7inzHmD1A)EyKDbfjbYzLDjzHmLoFpmYUsnuCUSjcqBaVbIDfbu9ol)sJDowKDJhjrJVhY(8tz3YlnXXYoFS5wsYiZUYdwmujRa7UgsSp2tKsco25O)LcHezvJ1hzP0DAK0SaajjlKP057Hr6ddb3lRgWhSsB)gkevtbHDobaYiQfPekevswitPTPG2FUOu2SBIJLDKMSqMUATFpmUAD6TuSlOijqoRSljlKP057Hr2vQHIZLnraAd4nqSRiGQ3z5xASZXISB8ijA89q2NFk7wEPjow25Jn3aMrMDLhSyOswb2DnKyFSNiLeCSZr)lfcjYQgRpYsP70iPzbasswitPZ3dJ0hgcUxwnGpyL2(nuiQMcc7CcauYQtlsjuiQgsLXYIszRoTiLqHOAivgllA(W6DjSzevQePekevm8VmqLpuk7uQujsjuiAGGLqYKPfsbTstnHIZaQeLYof7M4yzhPjlKPRw73dJRwNgrk2fuKeiNv2LKfYu689Wi7k1qX5YMiaTb8gi2veq17S8ln25yr2nEKen(Ei7ZpLDlV0ehl78XMBgfJm7kpyXqLScS7AiX(yprkj4yNJ(xkesKvnwFKLs3PrsZcaKKSqMsNVhgPpmeCVSAaFWkT9BOqunfe25eaiJOonsD4qNdvdPYyzr7GfdvQsL()G8nmOAivgllkSrmzYcawl3l5uSBIJLDKMSqMUATFpmUAD6KtXUGIKa5SYUKSqMsNVhgzxPgkox2ebOnG3aXUIaQENLFPXohlYUXJKOX3dzF(PSB5LM4yzNp2CBFWiZUYdwmujRa7UgsSp2tKsco25O)LcHezvlsjuiQKSqMsBtbT)CrPSvlsjuiQKSqMsBtbT)CrHnIjtobWA5Eiy3ehl7i3ODadtQ8Q1jrHsI(yxqrsGCwz)A0oGHz6LcLe9XUsnuCUSjcqBaVbIDfbu9ol)sJDowKDJhjrJVhY(8tz3YlnXXYoFSjcqmYSR8GfdvYkWURHe7J9ePKGJDo6FPqirw1a(GvA73qHOAkiSZjaqgrTiLqHOsYczkTnf0(ZfLYMDtCSSJCJ2bmmPYRwNefkj6B160BPyxqrsGCwz)A0oGHz6LcLe9XUsnuCUSjcqBaVbIDfbu9ol)sJDowKDJhjrJVhY(8tz3YlnXXYoFSjIngz2vEWIHkzfy31qI9XEIusWXoh9VuiKiRAaFWkT9BOqunfe25eaOKvNwKsOqunKkJLfLYwDArkHcr1qQmww08H17syZiQujsjuiQy4FzGkFOu2PuPsKsOq0ablHKjtlKcALMAcfNbujkLDk2nXXYoYnAhWWKkVADsuOKOVvRtJif7ckscKZk7xJ2bmmtVuOKOp2vQHIZLnraAd4nqSRiGQ3z5xASZXISB8ijA89q2NFk7wEPjow25JnrGGrMDLhSyOswb2DnKyFSNiLeCSZr)lfcjYQgWhSsB)gkevtbHDobaYiQtJuho05q1qQmww0oyXqLQuP)piFddQgsLXYIcBetMSaG1Y9soL60i1HdDo0UFvtDKFOZDUo6I2blgQuLk9)b5Byq7(vn1r(Ho356OlkSrmzYcawltXUjow2rUr7agMu5vRtIcLe9TAD6KtXUGIKa5SY(1ODadZ0lfkj6JDLAO4CzteG2aEde7kcO6Dw(Lg7CSi7gpsIgFpK95NYULxAIJLD(ytejZiZUYdwmujRa7UgsSp2tKsco25O)LcHezvd4dwPTFdfIQPGWoNaaLSAS(ilLUtJKMfaijzHmLoFpmsFyi4Ez1P1)hKVHb1aExPFH04mGMrHnIjtobWA5EiuJHhriwFOgW7k9lKgNb0mAhSyOsvQePeke1aas2Uq6xi9bO0d(aa7(sIOu2QfPeke1aas2Uq6xi9bO0d(aa7(sIOWgXKjNayTmL60i1HdDounKkJLfTdwmuPkv6)dY3WGQHuzSSOWgXKjlayTCpKKIDtCSSJ0KfY0vR97HXvRtJKuSlOijqoRSljlKP057Hr2vQHIZLnraAd4nqSRiGQ3z5xASZXISB8ijA89q2NFk7wEPjow25JnrGegz2vEWIHkzfy31qI9XEIusWXoh9VuiKiRAaFWkT9BOqunfe25eaOKvNw)Fq(ggud4DL(fsJZaAgf2iMm5eaRL7HqngEeHy9HAaVR0VqACgqZODWIHkvPsKsOqudaiz7cPFH0hGsp4daS7ljIszRwKsOqudaiz7cPFH0hGsp4daS7ljIcBetMCcG1YuQtJuho05q1qQmww0oyXqLQuP)piFddQgsLXYIcBetMSaG1Y9qsk2nXXYoYnAhWWKkVADsuOKOVvRtJKuSlOijqoRSFnAhWWm9sHsI(yxPgkox2ebOnG3aXUIaQENLFPXohlYUXJKOX3dzF(PSB5LM4yzNp2eHryKzx5blgQKvGDxdj2h7Y)q7(vn1r(Ho356Ol6r07idy1Y)q7(vn1r(Ho356OlkSrmzYjawl3dHAzfPekenrkj4yNdf2iMm5eaRL7HGDtCSSV)usWXo3Q1P3sXUGIKa5SYEIusWXoh7k1qX5YMiaTb8gi2veq17S8ln25yr2nEKen(Ei7ZpLDlV0ehl78XMissgz2vEWIHkzfy31qI9XEAaFWkT9BOqunfe25acKkva(GvA73qHOAkiSZb0M606)dY3WGkgWYs)cPtKkFeDrHnIjtwaWAPkv6)dY3WGkjlKP0aWXyHOWgXKjlayTmLkva(GvA73qHOAkiSZbec1P1)hKVHbDFloGQbGHGBMwieRpYp4qcabcnjnIkv6)dY3WGQHuzSSq68bj7kQgagcUzAHqS(i)Gdjaei0K0iPsXUjow2t64DD16x4Q1cMb08Q1P3sXUGIKa5SYUb8Us)cPXzanZUsnuCUSjcqBaVbIDfbu9ol)sJDowKDJhjrJVhY(8tz3YlnXXYoFSjcGzKzx5blgQKvGDxdj2h7Pb8bR02VHcr1uqyNlbGqOo3Jw8hQm6rkebiAe2AG2uPcWhSsB)gkevtbHDUeakz15E0I)qLrpsHiarJWwdeOuSBIJLDfcyzxT(fUA9(tLpIURwNElf7ckscKZk7IbSS0Vq6ePYhrx2vQHIZLnraAd4nqSRiGQ3z5xASZXISB8ijA89q2NFk7wEPjow25JnryumYSR8GfdvYkWURHe7J90a(GvA73qHOAkiSZLaqiuN7rl(dvg9ifIaencBnqBQub4dwPTFdfIQPGWoxcaLS6CpAXFOYOhPqeGOryRbcuk2nXXYostwitxTEFIJXcxTo9wk2fuKeiNv2LKfYuAa4ySq2vQHIZLnraAd4nqSRiGQ3z5xASZXISB8ijA89q2NFk7wEPjow25JnrSpyKzx5blgQKvGDxdj2h71OtrSTReDlzGbLKgr9HHG7HcO4Wba1wFcaeWgrnGpyL2(nuiQMcc7Cjaesy3ehl77tCmw4Q1VWvR3FQ8r0LDbfjbYzLDa4ySq6xiDIu5JOl7k1qX5YMiaTb8gi2veq17S8ln25yr2nEKen(Ei7ZpLDlV0ehl78XMjdIrMDLhSyOswb2nXXY((tjbh7CRwNgrk2fuKeiNv2tKsco25yxPgkox2ebOnG3aXUXJKOX3dzF(PSRiGQ3z5xASZXISB5LM4yzNp2m5ngz2vEWIHkzfy31qI9XUgagcUzGqOoDUhT4puz0Juicq0iS1absnGpyL2(nuiQMcc7CjaecvQsd4dwPTFdfIQPGWoxcaHe1P1)hKVHbvswitPbGJXcrHnIjtwaWA5EiuPs)Fq(gguXaww6xiDIu5JOlkSrmzYcawl3drk16)dY3WGMiLeCSZHcBetMSaG1Y9qKkLkvPZ9Of)HkJEKcraIgHTgOn1a(GvA73qHOAkiSZLaqBQuLgWhSsB)gkevtbHDUeacjQtR)piFddQKSqMsdahJfIcBetMSaG1Y9qOsL()G8nmOIbSS0Vq6ePYhrxuyJyYKfaSwUhIuQ1)hKVHbnrkj4yNdf2iMmzbaRL7Hivk2nXXYUrJIdSlOijqoRSVVfhyxPgkox2ebOnG3aXUIaQENLFPXohlYUXJKOX3dzF(PSB5LM4yzNp2mzemYSR8GfdvYkWURHe7JDnameCZaHqD6CpAXFOYOhPqeGOryRbcKAaFWkT9BOqunfe25saieQuLgWhSsB)gkevtbHDUeacjQtR)piFddQKSqMsdahJfIcBetMSaG1Y9qOsL()G8nmOIbSS0Vq6ePYhrxuyJyYKfaSwUhIuQ1)hKVHbnrkj4yNdf2iMmzbaRL7HivkvQsN7rl(dvg9ifIaencBnqBQb8bR02VHcr1uqyNlbG2uPknGpyL2(nuiQMcc7CjaesuNw)Fq(ggujzHmLgaoglef2iMmzbaRL7HqLk9)b5ByqfdyzPFH0jsLpIUOWgXKjlayTCpePuR)piFddAIusWXohkSrmzYcawl3drQuSBIJLDfHuzSSWvR9ds2v2fuKeiNv21qQmwwiD(GKDLDLAO4CzteG2aEde7kcO6Dw(Lg7CSi7gpsIgFpK95NYULxAIJLD(yZKtMrMDLhSyOswb2nXXYUI)KRgIpYpSlOijqoRSR)jxneFKFyxPgkox2ebOnG3aXUXJKOX3dzF(PSRiGQ3z5xASZXISB5LM4yzNp2mzKWiZUYdwmujRa7UgsSp2tKsco25O)LcHezvJ1hzP0DAK0SaajjlKP057Hr6ddb3lRwKsOqujzHmL2McA)5IszZUjow2rAYcz6Q1(9W4Q1Pnsk2fuKeiNv2LKfYu689Wi7k1qX5YMiaTb8gi2veq17S8ln25yr2nEKen(Ei7ZpLDlV0ehl78XMjBegz2vEWIHkzfy31qI9XEIusWXoh9VuiKiRAS(ilLUtJKMfaijzHmLoFpmsFyi4Ez1IucfIEakTqcSz6xiDIu5JOlkLT60i1HdDounKkJLfTdwmuPkv6)dY3WGQHuzSSOWgXKjlayTCVKtXUjow2rAYcz6Q1(9W4Q1PtYuSlOijqoRSljlKP057Hr2vQHIZLnraAd4nqSRiGQ3z5xASZXISB8ijA89q2NFk7wEPjow25JntojzKzx5blgQKvGDxdj2h7jsjbh7C0)sHqISQX6JSu6onsAwaGKKfYu689Wi9HHG7Lvd4dwPTFdfIQPGWoNaaHe1PrQdh6COAivgllAhSyOsvQ0)hKVHbvdPYyzrHnIjtwaWA5Eijf7M4yzhPjlKPRw73dJRwNg4uSlOijqoRSljlKP057Hr2vQHIZLnraAd4nqSRiGQ3z5xASZXISB8ijA89q2NFk7wEPjow25Jntgygz2vEWIHkzfy31qI9XEIusWXoh9VuiKiRArkHcrLKfYuABkO9NlkLn7M4yzh5gTdyysLxTojkus03Q1Pnsk2fuKeiNv2VgTdyyMEPqjrFSRudfNlBIa0gWBGyxravVZYV0yNJfz34rs047HSp)u2T8stCSSZhBMSrXiZUYdwmujRa7UgsSp2tKsco25O)LcHezvlsjui6bO0cjWMPFH0jsLpIUOu2QtJuho05q1qQmww0oyXqLQuP)piFddQgsLXYIcBetMSaG1Y9sof7M4yzh5gTdyysLxTojkus03Q1PtYuSlOijqoRSFnAhWWm9sHsI(yxPgkox2ebOnG3aXUIaQENLFPXohlYUXJKOX3dzF(PSB5LM4yzNp2m59bJm7kpyXqLScS7AiX(yprkj4yNJ(xkesKvnGpyL2(nuiQMcc7CcaesuNgPoCOZHQHuzSSODWIHkvPs)Fq(ggunKkJLff2iMmzbaRL7HKuQtJuho05q7(vn1r(Ho356OlAhSyOsvQ0)hKVHbT7x1uh5h6CNRJUOWgXKjlayTCpePy3ehl7i3ODadtQ8Q1jrHsI(wTonWPyxqrsGCwz)A0oGHz6LcLe9XUsnuCUSjcqBaVbIDfbu9ol)sJDowKDJhjrJVhY(8tz3YlnXXYoFSjsaXiZUYdwmujRa7UgsSp2b8bR02VHcr1uqyNlbGqc7M4yz3OrXHvRtVLIDbfjbYzL99T4a7k1qX5YMiaTb8gi2veq17S8ln25yr2nEKen(Ei7ZpLDlV0ehl78XMizJrMDLhSyOswb2DnKyFSd4dwPTFdfIQPGWoxcaHe2nXXYUIqQmww4Q1(bj76Q1P3sXUGIKa5SYUgsLXYcPZhKSRSRudfNlBIa0gWBGyxravVZYV0yNJfz34rs047HSp)u2T8stCSSZhBIeemYSR8GfdvYkWURHe7J9ePKGJDo6FPqirw1a(GvA73qHOAkiSZjaqjRgRpYsP70iPzbasswitPZ3dJ0hgcUxwDAK6WHohQgsLXYI2blgQuLk9)b5Byq1qQmwwuyJyYKfaSwUNrsXUjow2rAYcz6Q1(9W4Q1PnQuSlOijqoRSljlKP057Hr2vQHIZLnraAd4nqSRiGQ3z5xASZXISB8ijA89q2NFk7wEPjow25JnrsYmYSR8GfdvYkWURHe7J9ePKGJDo6FPqirw1a(GvA73qHOAkiSZjaqjRonsD4qNdvdPYyzr7GfdvQsL()G8nmOAivgllkSrmzYcawl3ZiPy3ehl7i3ODadtQ8Q1jrHsI(wToTrLIDbfjbYzL9Rr7agMPxkus0h7k1qX5YMiaTb8gi2veq17S8ln25yr2nEKen(Ei7ZpLDlV0ehl78Xh7M4yz3jrfxTwPEqIi1r(XO1Q1Yketfo(yg]] )

    storeDefault( [[SimC Retribution: precombat]], 'actionLists', 20170402.125703, [[b4vmErLxtvKBHjgBLrMxc51utbxzJLwySLMEHrxAV5MxoDdmEnfrLzwy1XgDEjKxtjvzSvwyZvMxojdmXCdmZidoUeJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5cCVrxAV52CEnvqILgBPrxEEnfCVrxAV5MxtLKBKL2yHr3BY51uU9MBL51uofwBL51uq9gDP9MBEnvqYD2CEnLBH1wz9iYBSr2x3fMCI41usvgBLf2CL5LtYatm3edmEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxtjYBSr2x3fMCI4fDErNxt5uyTvMxtnvATnKFGjvz0jxAIvhDP9MB64hyWjxzJ9wBIfgDErNxEb]] )

    storeDefault( [[Protection ST]], 'actionLists', 20170402.125703, [[d8d4haGAfQA9Quv2eLOSluABIu7JsOoSsltHmBkMpLe(eLeDBu5BQuoVizNK0EL2ns7xfnkkPAyQW4uO0Pv1qPeYGvjdNeoij6uus5yq15OeWcPuTukLflILJ4HusQNs8yHEoPMiLanvfmzbtNQlQO8Akr1ZuuDDf5YGvrjsBgfTDvQ8zu1FHY0OeK5rjIrsjjFhfA0IA8ku5KOGBPqHRPsv19uPkRuHI(nKFsjOU4DOYm6MyGqTxrIKxHxPIfeyUtgV2ROUCqflIGCi6pIEEjdvSbgy1qvhDGF7y(OXYIxXgSHudphuX6NxreYeqmsz15hmbmetmpdyKNp7aAsZgZlHh0yC74oVgJZRiczcigPS68dMagIjMNbmYZNDanPzJ5LWdAmMKn6pIUMZlRDEzPNxB0FeLvNFWeWqmX8mGrE(SdOjnlbI5LWdvug9hr1DOQ4DOYm6MyGqTxzDN0H6vKi5v4v8NdU3rfLeEDf6Yb3dzcymUKk2adSAOQJoWtJFJ9yoEfgOHpUoIuHIOqf1LdQyri)r0kktEZ7PQOa5pIwVQJ6qL1DshQxrIKxHxXr88gG9PoqitkCDLz0nXaHAVInWaRgQ6Od8043ypMJxHbA4JRJivOikurzYBEpvfcKmz5qf1LdQydsMSCOEvN3HkR7KouVIejVcVsYetMS8KLgWIKj9gac7KclZxdqD2izsVbGOXg)uGNdOolq3edeSSiczcigPSJFkWZbuNnMxcpOTe8kZOBIbc1EfBGbwnu1rh4PXVXEmhVcd0WhxhrQqruOIYK38EQk7DaLhiAmD(btOI6YbvuEhq5bIvQpVK8dMq9QAH6qL1DshQxrIKxHxzJ(FhGbuG7bTfJxzgDtmqO2RydmWQHQo6apn(n2J54vyGg(46isfkIcvuxoOIvJOAisw)r0ZlRR0cpZAvuM8M3tvjIOAisw)r06v9(7qLz0nXaHAVIejVcVseHmbeJuwD(btadXeZZag55ZoGM0SX8s4b99IiKjGyKYQZpycyiMyEgWipF2b0KMnMxcpOX42XvrzYBEpvfD(btadXeZZag55ZoGM0vyGg(46isfkIcvugUBPriu7vuxoOIKFWeoVqmpV8mCEz75ZoGM0vSbgy1qvhDGNg)g7XC8k2GnKA45Gkw)8kIqMaIrkRo)GjGHyI5zaJ88zhqtA2yEj8GgJBh351yCEfritaXiLvNFWeWqmX8mGrE(SdOjnBmVeEqJXKSr)r01CEzTZll98AJ(JOS68dMagIjMNbmYZNDanPzjqmVeEOY6oPd1RirYRWhsPaQ4phuVQP7qL1DshQxrIKxHxPYm6MyGqTxXgyGvdvD0bEA8BShZXRWan8X1rKkuefQOm5nVNQY4Nc8Ca1ROUCqLXCkWZbuVEvV1HkZOBIbc1EL1DshQxrD5Gk2nGwdHZlRA54asfLeEDLk2adSAOQJoWtJFJ9yoEfgOHpUoIuHIOqfLjV59uvsmGwdbS8YXbKksK8k8kbizIjt2edO1qalVCCaHLaC7t1wYyTcRiIqMaIrkBIb0AiGLxooGWgZlHh0wmE9Qo2ouzDN0H6vKi5v4vQmJUjgiu7vSbgy1qvhDGNg)g7XC8kmqdFCDePcfrHkktEZ7PQerunejR)iAf1LdQy1iQgIK1FeTEvTaDOY6oPd1RirYRWRuzgDtmqO2RydmWQHQo6apn(n2J54vyGg(46isfkIcvuM8M3tvzVdO8arJPZpycvuxoOIY7akpqSs95LKFWeoVSoU1Qxv8JouzDN0H6vKi5v4vQmJUjgiu7vSbgy1qvhDGNg)g7XC8kmqdFCDePcfrHkktEZ7PQKxooGGHyI5zaJ88zhqt6kQlhuXQwooGCEHyEE5z48Y2ZNDanPRxVIOaI)A(7B9hrRA601Bb]] )

    storeDefault( [[Protection Defensives]], 'actionLists', 20170402.125703, [[datAcaGEQQQnPq1UuiBJOmtQkmBsDBkPDIu7vSBk2prgfvvAyk43igQkvdMqdNQCqjXPOQOJPIfsjwkr1IvjlNKNcTmK0ZLyIkuMkvAYemDuxus1Lbxhj2mvSDQQYNPuESugjvvCyvnAP6BskNuLY4OQKtR05LK(RIEgLQxtvPoN4gSU5V0GqSeeBQ1JdgK(TcbVRim04LyKehdCatz9huckh0WxGqtD4uBWovFn6ee9G2(61)pVetOLjlyLgVetjUH(e3G1n)LgeILG0Vvii2xqlijsCKe5oijkFT1zGqPij63JpdIn16Xb53471yBCkfyw6lOfc(mRIB4GvUw9Yvdw6lOfMeNj3HPAT1zGqPe8MryBptubnedeuoOHVaHM6Wr2P2Ob7NGytTESBvpiyzT2chAQXn4ZSkUHds)wHG(5ncsIehjrUdsI3vegAmrfSU5V0GqSeuoOHVaHM6Wr2P2Ob7NG3mcB7zIkOHyGGvUw9Yvd2FJWK4m5om9uegAmrfeBQ1JdsPaZcODMD41HdT94g8zwf3WbPFRqqFS26SKiXrsK7GK4DfHHgtubRB(lnielbLdA4lqOPoCKDQnAW(j4nJW2EMOcAigiyLRvVC1G61wNNeNj3HPNIWqJjQGytTECqkfywaTZSdVoC4GJbopfnhlHta]] )

    storeDefault( [[Protection Cooldowns]], 'actionLists', 20170402.125703, [[b4vmErLxtvKBHjgBLrMxI51utnMCPbhDEnLxtruzMfwDSrNxc51usvgBLf2CL5LtYatm3aZmYGJlX41utbxzJLwySLMEHrxAV5MxozJnEnvqJrxAV52CErLx051uofwBL51uqj3B0v2y0L2BU5hyd92BSr2B352CErNxEb]] )

    storeDefault( [[Protection Default]], 'actionLists', 20170402.125703, [[d0IwcaGEQiTlqLTrL0Sv1nbvDBvyNkAVIDl1(vkdtb)M0qbLbRunCQWbPQCmkAHuWsPQAXQOLdYIqPEk0Jr1ZP0ePkMQsAYQ00jUOc5YixhfzZuOTJI6ZuL(okyzOKdd8nQuNefACurCAjNxH6VkXZOs8qQOoMzn4OgC(0ngc6Hmcy6Lyi4eCqbHbPcXLs7TDpKratVe0p9eWszYAW09GlSCcCMbrou5qcg0hxkTTzntZSgCudoF6gdbNGdkimiviUuAVT7HmsTTyMSbrou5qckQxVpbhtwA5sgP2wmt2G(PNawktwdMUnhcYyFloquOGT2uqFN1xY4GCW)laUuAV8LvccVENGdkiByqQqCP0EB3dzKABXmzzhjtwzn4OgC(0ngcobhuqyqQqCP0EB3zv)RYqBdICOYHeuuVEFcoUQ)vzOTb9tpbSuMSgmDBoeKX(wCGOqbBTPG(oRVKXb5G)xaCP0E5lReeE9obhuq2WGuH4sP92UZQ(xLH2YosMUK1GJAW5t3yi4eCqbHbPcXLs7TDCniYHkhsWG(PNawktwdMUnhcYyFloquOGT2uqFN1xY4GCW)laUuAV8LvccVENGdkiByqQqCP0EBhxzhjsq0bXlWxofiL2z6QRrsa]] )


    storeDefault( [[Retribution Primary]], 'displays', 20170402.125703, [[d0JoiaGEvvEPsvTlvvjVwPkZKQIdlz2k55u5MQQQLPu52K05jv7KI9k2nQ2VQ4NiYWKIFd50qnuIAWQsdhPoOu1rvvL6yuLJtvPfkLwQuPfJslNWdjfpf8yuSosjnrvvXurYKjIPR4IQkxLQkEgvv66iSrPITsKI2mLA7KWhPQQpJOMgPeFxPmssP6BKsz0uY4jsojj6wePY1isv3JiLCzvwlrkmoIuQJxOcWu0dgX7G4dm6Rlaj)q5JsZxGPeKVrwHCydiko5tJ1XSxAd4lXrC9lmzU6XNamb0jzB7Urtrpye3fttaPizB7Urtrpye3fttaFjoItIsgehW)Uy0staNfARNquk52OWgWxIJ4KOPOhmI7sBaDs22UBOkb5BCX0e4VjoIZfQy8cvGpEXUojPnqpZGr8NxFWUjMDbmL6faWQAEE7EJaZsmyexRpV0IJbPYwtGU36k3fZUgpT1410eayey6jWGvpPvtMy2fQaF8IDDssBGEMbJ4pV(GDtmEbmL6faWQAEE7EJaZsmyexRpVso7Iynb6ERRCxm7A80wJxttMmbCwOnydpmw9FPnGZcT1tmO0gWzH2Gn8Wy1tmO0gykb5B65mwirGwsuuK(VRs)1ova9yKUDAPjGuX0eWzH2Okb5BCPnWES9CglKiafj5Uk9x7ubyqQS1iR4lSbyk6bJ49CglKiqljkks)hqdIw)5LcfqwGMJzWi(ZRSaRwc9aol0gqL2a(sCe3FWIJzWiEGUk9x7ub4eQkzqCxmAjGJ(wRoRYzPbTqIqfOIXlGigVaKJXlaBmEzc4SqBAk6bJ4U0gqks22UB6jevmnbkcrrPtFbyjSTdib7OxLoLo9fOcOws1tmOyAculARQFTv6ozfFX4fOw0wfyH2Kv8fJxGArBvAqQS1iR4lgVa)5SlI1K2asrY22DJsUemtniHlMMa1AR0DYkKtBafyhMfVWJoLo9fGnatrpyeVFHjZdO5Zq91nGVeyM9KMyhm6RlqfaOpgCTW)QbJ4XOTMaIIt(O0PVaflEHh9afHO(hZV0gykb5B6G4tazQNxO4UNxtjeOTa7X2bXha)7IXBxG9pDwmxcMt(5fg91fZUaYcSAj0FE1u0dgXFE7jevGafHO65mwirGwsuuK(3NVoube3kGMpd1x3ao6BT6SkNvydulARIQeKVrwXxmEbSr8jqVaxRNxtjeOTa(sCeNeLCjyMAqcxAdWUW)(5)cT1VwHna7c)7N)l0wydmLG8nDq8bg91fGKFO8rP5lW)Luyvc1NxkS6fJFBcilWQLq)5vtrpyepWucY34camcm9eiqTOTQ(1wP7KvihJxajNDrSMEzFcayvnpVDVrGzjgmIR1NxjNDrSMa0cSAj07G4dG)DX4TlaT4yqQS10l7taaRQ55T7ncmlXGrCT(8slogKkBnbuX8(Vy8Ba1sQ(VyAcqvRJppV(lqe0X4fykb5BKv8f2asrY22DZ(TUy8c09wx5Uy214PTg)UtA)xEb0jzB7UPNquX0eqfZ7jgumnbyk6bJ4Dq8bW)Uy82fOiefqFRLY)ettGArBvGfAtwHCmEbCwOnLCjyMAqcxAd4SqBYkKtBGATv6ozfFPnGZcTjR4lTbCwOT(V0gGbPYwJSc5Wgyp2oi(eqM65fkU751ucbAlWESDq8bg91fGKFO8rP5lGojBB3n736Ir68cOI5avmnbMsq(Moi(a4FxmE7culARIQeKVrwHCmEbyk6bJ4Dq8jGm1ZluC3ZRPec0wGArBvAqQS1iRqogVaF8IDDssBahwLED9K(IzxamxcMPgKONZyHeb6Q0FTtfWzH22)0zXCjyozxAdqlWQLqxjdId4FxmAPjqrikLCBeLo9fGLW2oGAjfqfJxaPizB7UHQeKVXfttamdId0fdMtogPpWcTDcMYD736cBamdIlnqi1y8K(a(sCeNKoi(a4FxmE7cOtY22DJsUemtniHlMMa(sCeNK9BDPnGPuVaDVrGzjgmI)8klWQLqpqrik)WXta6vPFImj]] )

    storeDefault( [[Retribution AOE]], 'displays', 20170402.125703, [[da0miaqicj1MiePBriv7skuddIogrTmsXZGqnnLOCncHVriLXriQohHewNui3JqIoOuAHkPhsOMOsuDrLYgvcFujYijL4KeXlrjmtPGBIs0oP4NqYqPKJsiklvk6PGPIKRskPTsiI1sij7vmyvXHLSyu8ycMmk1LvzZuPpdPgnP60iEneYSLQBtP2nQ(nudhPooPulNKNtvtxX1vvBNi9DvPXJs68uX6HG9RuDKdvaHIEiy(cmFGXPFbqPvQgKy2cmLc9nwsTctavXrFI1pbeL1aA)V)12jO52hFcieWbLRR)gXf9qWCFmidWkkxx)nIl6HG5(yqgGwrSlLJebmhiiCXSmKbSj82TyqCaT)3)ylUOhcM7ZAahuUU(BOkf6B8XGmGi7F)ZhQyKdvGnEX0p2znqRWqW89Ngi(jgnbmL9fai2I3FAEJIW8hcM3O9hA1jGTzQjqZRFL)Irdszril3ynAKdackc9eyi2NOezMy0eQaB8IPFSZAGwHHG57pnq8tmYbmL9fai2I3FAEJIW8hcM3O9h2NB97tGMx)k)fJgKYIqwUXA0iNjtaVo(fEjJGE7wwdWkkxx)nuLc9n(yqgWRJFHxYiO3(hCwdmLc9nTCbDSkWkkkkuSSPKL0cvaNyeDzrHicWAmidWIZHHWzt4O3FGXPFXOjaIyA5c6yvakuwnLSKwOciGTzQXs6wyciu0dbZB5c6yvGvuuuOyzaXyAN9hkCGM3Oim)HG57pTO2c41XVavwdO9)(3YjQtyiyEGMswslub4FBjcyUpMLfWtF9(IE51fJ7yvOcuXihGjg5aOJroGkg5mb864xXf9qWCFwdWkkxx)nTFvfdYa1xvuo0xaMVRBa7I12)GJbzGQtRxT93YXBjDlg5avNwVaD8RL0TyKduDA9sm2MPglPBXihWu2xGM3Oim)HG57pTO2cWM4P7LdLd9fqiq1FlhVLuRSgqkXtyiDY4q5qFbyciu0dbZB7e08aI3muBndO9NiGircXdJt)cuba6tGuDcc1qW8yenKbufh9r5qFbkgsNmobQVQyjHFznGnH3(hCmioaIywG5dqq4IrwtahuUU(BKWzteQbR8XGmGLIyxkN9hXf9qW89N2VQceykf6BwG5talQ9hO4(9htPu43aQRhq8MHARzap917l6LxpmbQoTErvk03yjDlg5a1xvTCbDSkWkkkkuSSHTfub0(F)JTeoBIqnyLpRb86432VQKWDXHjatNGacl1XVHjWuk03SaZhyC6xauALQbjMTaSSyLy)T3FOi2xmigzaMobbewQJFB79Weaeue6jGNWr3prQOU(doq1P1R2(B54TKAfJCGMx)k)fJgKYIgseRrK3y5a0kIDPCwG5dqq4IrwtaA1jGTzQP1QHaaXw8(tZBueM)qW8gT)qRobSntnbyFU1VpTwneai2I3FAEJIW8hcM3O9h2NB97ta7I12TyqgGQ6hF2FwsH)0XGmWuk03yjDlmb86432)GdtalfXUuo7pIl6HG5bMsH(gFawr566VHfR(yKd4GY11Ft7xvXGmGqrpemFbMpabHlgznb0(F)JTebmhiiCXSmKbQVQa6R3LS8yqgWRJFLWzteQbR8znq1P1lqh)Aj1kg5av)TC8ws3YAaVo(1sQvwd41XVTBHjGa2MPglPwHjaIywG5talQ9hO4(9htPu43aoOCD93WIvFmIUCaeXSaZhyC6xauALQbjMTa2eoqfdIdmLc9nlW8biiCXiRjGxh)AjDlRbek6HG5lW8jGf1(duC)(JPuk8BGQtRxIX2m1yj1kg5aB8IPFSZAapXMUFTO2IrtacNnrOgSQLlOJvbAkzjTqfO606fvPqFJLuRyKd41XVS4CyiC2eoAFwdyxScuXGmq9vLeUlMYH(cW8DDdqeWCGUeiC0XiIaED8lvPqFJpRbCX8jqRIu99htPu43aebmxuHX2XilIaA)V)XEbMpabHlgznbyfLRR)gjC2eHAWkFmidO9)(hBwS6ZAGLFU1Vpznq9vLw5KjaDVCovMe]] )

    storeDefault( [[Protection Primary]], 'displays', 20170402.125703, [[dWdAiaGEiLxQuv7IuL2gssZeLQzRKdl5MqQ8Bv9nsvOLjvSts2l1Ur1(HOFIedtKghPkQpJsgkkgmKmCK6GsPJsQICms54IkTqPyPOuwSiworpuu1tbpgkpxWeHu1uHQjtitxXfHWvjvLlRY1jyJsL2kPkyZIY2juFuPItJyAij(UszKKQQNjQy0c14rsDssLBPujUMsL68c52svRvPs61kvzRzCdyf9qEE3NpWeTodu0ho76uimmLK1nmIzCIbzXzD5JpS9CJHCfoHRDryX7p(yaZqeLSSWn5l6H88GvPgOMsww4M8f9qEEWQud5kCcNiDyphiODwrLudH4FRvqw64zVtmKRWjCIYx0d55b3yiIsww4g8sY6MGvPg0tcNWfmUvAg3acELSorUXql2qEosuStcJvuXGQ6pdmYFoSH8CKOq)LD8ar8fmW2TUkCw1jvJQAPP5OxndaMKqpg8yvhJBabVswNi3yOfBiphjk2jHXQDBqv9Nbg5ph2qEosu5)Fj634bdSDRRcNvDs1OQwAAo6vZaGjj0JbpwLJXnGGxjRtKBm0InKNJef7KWyvoguv)zGr(ZHnKNJefGBGTBDv4SQtQgv1stZrVAgamjHEm4XJHq8VbBKblUfHBmeI)TwH5DJHq8VbBKblUvyE3yykjRBA5yXV0qdfCCkOJnD7OFCdrwTlDOsQbQTk1qi(3WljRBcUXWEjTCS4xAaNcdB62r)4gW((KAyeJWjgWk6H88wow8ln0qbhNc6mK)PJqIc)nWi)5WgYZrIIrs6lzKHq8Vb4UXqUcNWHEI8WgYZnWMUD0pUbUqVoSNhSIkgc03A1DvH48)6Lg3qzLMbPvAgyzLMHeR08yie)B5l6H88GBmqnLSSWnTcYYQudLGSWJOpdjczzgerc0RkcpI(mug6lQBfM3Qud1IoUAxBvuGrmcR0mul64cI)ngXiSsZqTOJR8FFsnmIryLMb0FzLWACJbQPKLfUrhxebRMxgSk1qT2QOaJyg3yqmjqsilYeHhrFgsmGv0d55TlclUH8iu4iyZqUceS90dKamrRZqzaOpmsTiOvd55wrvQAqwCwhEe9zOsilYezOeKf6i8ZngMsY6MUpFmWGJefu8asuQsk)nd7L095dqq7SsRJH9VOecxeHZcjkyIwNvDmWij9LmcjQ8f9qEosuTcYYGHsqwTCS4xAOHcoof0XoIU4gK3YqEekCeSziqFRv3vfIDIHArhx4LK1nmIryLMHSNpgALKAHeLQKYFZqUcNWjshxebRMxgCJHKfbn02z9BTRLtmKSiOH2oRFZjgMsY6MUpFGjADgOOpC21PqyaDf1KEHEKOWj9Nv5KAGrs6lzesu5l6H8CdtjzDtWaGjj0Jbd1IoUAxBvuGrmJvAgeDzLWAAzy3aJ8NdBiphjk0FzLWAmqlj9LmQ7ZhGG2zLwhd0Yd77tQPLHDRsn0t4TiSkhd9f1TiSk1aETo(Ge1oYxG2QudtjzDdJyeoXa1uYYc3SFtWkndH4FB)lkHWfr4ScUXqeLSSWnTcYYQud1IoUWljRByeZyLMHEcVvyERsnucYcOV1sh6Tk1qTOJli(3yeZyLMHq8VPJlIGvZldUXqi(3yeZ4gd1ARIcmIr4gdH4FJrmc3yie)BTiCJbSVpPggXmoXWEjDF(yGbhjkO4bKOuLu(Bg2lP7ZhyIwNbk6dNDDkegIOKLfUz)MGv7IMHEchWTk1Wusw3095dqq7SsRJbSIEipV7ZhGG2zLwhdyf9qEE3NpgyWrIckEajkvjL)MHArhx5)(KAyeZyLMbe8kzDICJHaPNEDTuqyvhdeUicwnVSLJf)sdSPBh9JBGTBDv4SQtQMEmnNo6z9QzGws6lzKoSNde0oROsQHsqw64zpEe9zirilZqFrnGBLMbQPKLfUbVKSUjyvQbc2Zb6cJWzz1UnS(TtIvHB)MGtmqWE(U(FVvA72qUcNWjQ7ZhGG2zLwhdruYYc3OJlIGvZldwLAixHt4eTFtWnguv)zGr(ZHnKNJefJK0xYidLGS0hNmgOxv0j9yd]] )


end
