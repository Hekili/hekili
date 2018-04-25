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
local registerItem = ns.registerItem

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
        addResource( 'mana', Enum.PowerType.Mana )
        addResource( 'holy_power', Enum.PowerType.HolyPower, true )

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

        addTalent( 'blade_of_wrath', 22592 )
        addTalent( 'blinding_light', 21811 )
        addTalent( 'cavalier', 22595 )
        addTalent( 'consecration', 22182 )
        addTalent( 'crusade', 22215 )
        addTalent( 'divine_judgment', 22375 )
        addTalent( 'divine_purpose', 22591 )     --[[ (223817) Your Holy Power spending abilities have a 20% chance to make your next Holy Power spending ability free. ]]
        addTalent( 'execution_sentence', 22175 )
        addTalent( 'eye_for_an_eye', 22186 )
        addTalent( 'fires_of_justice', 22319 )
        addTalent( 'fist_of_justice', 22896 )
        addTalent( 'hammer_of_wrath', 22593 )
        addTalent( 'inquisition', 22634 )
        addTalent( 'justicars_vengeance', 22483 )
        addTalent( 'repentance', 22180 )
        addTalent( 'righteous_verdict', 22557 )
        addTalent( 'selfless_healer', 23167 )
        addTalent( 'unbreakable_spirit', 22185 )
        addTalent( 'wake_of_ashes', 22183 )
        addTalent( 'word_of_glory', 23086 )
        addTalent( 'zeal', 22590 )


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
        -- addAura( 'blessing_of_the_ashbringer', 242981, 'duration', 3600 )
        addAura( 'blinding_light', 115750, 'duration', 6 )
        -- addAura( 'consecration', 188370, 'duration', 8 )
        addAura( 'crusade', 231895, 'max_stack', 15 )
        addAura( 'divine_hammer', 198137 )
        addAura( 'divine_judgment', 271581, 'duration', 15, 'max_stack', 15 )
        addAura( 'divine_protection', 498, 'duration', 8 )
        addAura( 'divine_purpose', 223819 )
        addAura( 'divine_shield', 642, 'duration', 8 )
        addAura( 'divine_steed', 221883, 'duration', 3 )
        addAura( 'defender_of_truth', 240059, 'duration', 10 )
        addAura( 'execution_sentence', 267799, 'duration', 7 )
        addAura( 'eye_for_an_eye', 205191, 'duration', 10 )
        addAura( 'eye_of_tyr', 209202, 'duration', 9 )
        addAura( 'forbearance', 25771, 'duration', 30 )
        addAura( 'grand_crusader', 85043, 'duration', 10 )
        addAura( 'greater_blessing_of_kings', 203538, 'duration', 3600 )
        addAura( 'greater_blessing_of_might', 203528, 'duration', 3600 )
        addAura( 'greater_blessing_of_wisdom', 203539, 'duration', 3600 )
        addAura( 'guardian_of_ancient_kings', 86659, 'duration', 8 )
        addAura( 'hammer_of_justice', 853, 'duration', 6 )
        addAura( 'hand_of_hindrance', 183218, 'duration', 10 )
        addAura( 'hand_of_reckoning', 62124, 'duration', 3 )
        addAura( 'inquisition', 84963, 'duration', 45 )
        addAura( 'light_of_the_titans', 209539, 'duration', 15 )
        addAura( 'repentance', 62124, 'duration', 60 )
        --[[ When any party or raid member within 40 yds dies, you gain 20% increased damage done and 30% reduced damage taken for 10 sec. ]]
        addAura( 'retribution', 183435, 'duration', 10 )
        addAura( 'righteous_verdict', 238996, 'duration', 6 )
        addAura( 'seal_of_light', 202273, 'duration', 20 )
        addAura( 'seraphim', 152262, 'duration', 30 )
        addAura( 'shield_of_the_righteous', 132403, 'duration', 4.5 )
        addAura( 'shield_of_vengeance', 184662, 'duration', 15 )
        addAura( 'fires_of_justice', 209785, 'duration', 15 )
        addAura( 'wake_of_ashes', 205273, '255937', 6 )
        addAura( 'zeal', 269571, 'duration', 20, 'max_stack', 3 )



        -- Fake Buffs.

        local judgment = GetSpellInfo( 197277 )
        addAura( 'judgment', 197277, 'duration', 8 )

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
                local up = UnitBuff( 'player', consecration, nil, 'PLAYER' ) and query_time < expire_consecration
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


        addHook( 'spend', function( amt, resource )
            if resource == 'holy_power' then
                if state.buff.crusade.up then
                    if state.buff.crusade.stack < state.buff.crusade.max_stack then
                        state.stat.mod_haste_pct = state.stat.mod_haste_pct + ( ( state.buff.crusade.max_stack - state.buff.crusade.stack ) * 3.5 )
                    end
                    state.addStack( 'crusade', state.buff.crusade.remains, amt )
                end

                if state.spec.retribution and state.talent.fist_of_justice.enabled then
                    state.setCooldown( 'hammer_of_justice', max( 0, state.cooldown.hammer_of_justice.remains - 2 ) )
                end
            end
        end )

        --[[ LegionFix:  Set up HoPo for prediction over time (for Liadrin's Fury Unleashed).
        ns.addResourceMetaFunction( 'current', function( t )
            if t.resource ~= 'holy_power' then return 'nofunc' end
        end ) ]]


        -- Gear Sets
        addGearSet( 'tier19', 138350, 138353, 138356, 138359, 138362, 138369 )
        addGearSet( 'tier20', 147160, 147162, 147158, 147157, 147159, 147161 )
            addAura( 'sacred_judgment', 246973, 'duration', 8 )

        addGearSet( 'tier21', 152151, 152153, 152149, 152148, 152150, 152152 )
            addAura( 'hidden_retribution_t21_4p', 253806, 'duration', 15 )

        addGearSet( 'class', 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )
        
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

        addHook( 'specializationChanged', function ()
            setPotion( 'old_war' )
            setRole( state.spec.protection and 'tank' or 'attack' )
        end )


        addToggle( 'use_defensives', true, "Protection: Use Defensives",
            "Set a keybinding to toggle your defensive abilities on/off in your priority lists." )

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


        --[[ Reduces all damage you take by 2,575% for 8 sec. While Ardent Defender is active, the next attack that would otherwise kill you will instead bring you to 12% of your maximum health. ]]
        addAbility( 'ardent_defender', {
            id = 31850,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 120
        } )

        addHandler( 'ardent_defender', function ()
            applyBuff( 'ardent_defender', 8 )
        end )


        --[[ (231665) Avenger's Shield interrupts and silences the main target for 3 sec if it is not a player. ]]
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


        --[[ Increases the damage, healing, and critical chance of your abilities by 20% for 20 sec.  ]]
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
            applyBuff( 'avenging_wrath', 20 )
            if equipped.chain_of_thrayn then applyBuff( 'chain_of_thrayn', 20 ) end
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
            return set_bonus.tier20_4pc == 1 and ( x - 1 ) or x
        end )

        addHandler( 'blade_of_justice', function ()
            removeBuff( 'sacred_judgment' )
            if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, 1 ) end
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

        addHandler( 'blessing_of_protection', function ()
            applyBuff( 'blessing_of_protection', 10 )
            applyDebuff( 'player', 'forbearance', 30 )
        end )


        addAbility( 'blessing_of_sacrifice', {
            id = 1022,
            spend = 0.075,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 150
        } )

        addHandler( 'blessing_of_sacrifice', function ()
            applyBuff( 'blessing_of_sacrifice', 12 )
            applyDebuff( 'player', 'forbearance', 30 )
        end )


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

        --[[ Consecrates the land beneath you, causing 8,406 Holy damage over 7.7 sec to enemies who enter the area. ]]
        addAbility( 'consecration', {
            id = 26573,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 20,
            known = function () return spec.protection or talent.consecration.enabled end,
        }, 205228 )

        class.abilities[ 205228 ] = class.abilities.consecration

        modifyAbility( 'consecration', 'id', function( x )
            return spec.retribution and 205228 or x
        end )

        modifyAbility( 'consecration', 'spend', function( x )
            if spec.retribution then return -1 end
            return x
        end )

        modifyAbility( 'consecration', 'cooldown', function( x )
            if spec.protection then return 9 * haste end
            return x * haste
        end )

        addHandler( 'consecration', function ()
            if spec.protection then
                last_consecration = now + offset
                expire_consecration = now + offset
                applyBuff( 'consecration', 9 * haste )
            end
        end )


        --[[ Increases your damage done and Haste by 3% for 25 sec.; ; Each Holy Power spent during Crusade increases damage done and Haste by an additional 3%.; ; Maximum 10 stacks. ]]
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
            applyBuff( 'crusade' )
            if equipped.chain_of_thrayn then applyBuff( 'chain_of_thrayn' ) end
            if equipped.liadrins_fury_unleashed then gain( 1, 'holy_power' ) end
        end )


        addAbility( 'crusader_strike', {
            id = 35395,
            spend = -1,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 4.5,
            charges = 2, -- Technically, 2nd charge comes at level 26 from 231667.
            recharge = 4.5,
        } )

        modifyAbility( 'crusader_strike', 'cooldown', function( x )
            if talent.fires_of_justice.enabled then x = x - 1 end
            return x * haste
        end )

        modifyAbility( 'crusader_strike', 'recharge', function( x )
            if talent.fires_of_justice.enabled then x = x - 1 end
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
            removeBuff( 'sacred_judgment' )
        end )

        
        --[[ Reduces all damage you take by 20% for 8 sec. ]]
        addAbility( 'divine_protection', { 
            id = 498, 
            spend = 0.035,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 60,
            nospec = 'retribution',
        } )

        addHandler( 'divine_protection', function ()
            applyBuff( 'divine_protection' )
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
            if talent.unbreakable_spirit.enabled then x = x * 0.7 end
            return x
        end )

        addHandler( 'divine_shield', function ()
            applyBuff( 'divine_shield', 8 )
            applyDebuff( 'player', 'forbearance', 30 )
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

        --[[ (230332) Divine Steed now has 2 charges. ]]
        modifyAbility( 'divine_steed', 'charges', function( x )
            return x + ( talent.cavalier.enabled and 1 or 0 )
        end )


        --[[ Unleashes a whirl of divine energy, dealing 869 Holy damage to all nearby enemies. ]]
        addAbility( 'divine_storm', {
            id = 53385,
            spend = 3,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
        } )

        modifyAbility( 'divine_storm', 'spend', function( x )
            if buff.divine_purpose.up then return 0 end
            if buff.fires_of_justice.up then x = x - 1 end
            if buff.hidden_retribution_t21_4p.up then x = x - 1 end
            return x
        end )

        addHandler( 'divine_storm', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            else
                removeBuff( 'fires_of_justice' )
                removeBuff( 'hidden_retribution_t21_4p' )
            end
            if equipped.whisper_of_the_nathrezim then applyBuff( 'whisper_of_the_nathrezim', 4 ) end
            if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, active_enemies ) end
        end )


        addAbility( 'execution_sentence', {
            id = 267798,
            spend = 3,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 30,
            talent = 'execution_sentence'
        } )

		modifyAbility( 'execution_sentence', 'spend', function( x )
            if buff.divine_purpose.up then return 0 end
            if buff.fires_of_justice.up then x = x - 1 end
            if buff.hidden_retribution_t21_4p.up then x = x - 1 end            
			return x
		end )

        addHandler( 'execution_sentence', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            else
                removeBuff( 'fires_of_justice' )
                removeBuff( 'hidden_retribution_t21_4p' )
            end
            applyDebuff( 'target', 'execution_sentence', 7 * haste ) 
        end )


        --[[ Reduces Physical damage you take by 35%, and instantly counterattacks any enemy that strikes you in melee combat for 419 Physical damage. Lasts 10 sec. ]]
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
            known = function () return equipped.truthguard end,
            toggle = 'artifact'
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
            health.actual = min( health.max, health.actual + ( stat.spell_power * 4.5 ) )
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


        --[[ Consumes up to 3 Holy Power to increase your damage done and Haste by 8%.; ; Lasts 15 sec per Holy Power consumed. ]]
        addAbility( 'inquisition', { 
            id = 84963, 
            spend = 0,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            talent = 'inquisition',
            usable = function () return holy_power.current > 0 end,
        } )

        addHandler( 'inquisition', function ()
            local hopo = min( 3, holy_power.current )
            spend( hopo, 'holy_power' )
            applyBuff( 'inquisition', 15 * hopo )
        end )

        --[[ (20271) Judges the target, dealing 1,778 Holy damage, and causing them to take 25% increased damage taken from your next Holy Power spender.; ; Generates 1 Holy Power. ]]
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

        --[[ (20271) Judges the target, dealing 1,778 Holy damage, and causing them to take 25% increased damage taken from your next Holy Power spender.; ; Generates 1 Holy Power. ]]
        --[[ (231657) Judgment reduces the remaining cooldown of Shield of the Righteous by 2 sec, or 4 sec on a critical strike. ]]
        --[[ (269569) Judgment grants you Zeal, causing your next 3 auto attacks to attack 50% faster and deal an additional 158 Holy damage. ]]        
        addHandler( 'judgment', function ()
            if spec.protection then
                gainChargeTime( 'shield_of_the_righteous', 2 )
            else
                applyDebuff( 'target', 'judgment', 8 )
                if talent.zeal.enabled then applyBuff( 'zeal', 20, 3 ) end
                if set_bonus.tier20_2pc > 0 then applyBuff( 'sacred_judgment' ) end
                if set_bonus.tier21_4pc > 0 then applyBuff( 'hidden_retribution_t21_4p', 15 ) end
                if talent.sacred_judgment.enabled then applyBuff( 'sacred_judgment' ) end
            end
        end )


        --[[ A weapon strike that deals 1,580 Holy damage and restores health equal to the damage done.; ; Deals 50% additional damage and healing when used against a stunned target. ]]
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
            if buff.divine_purpose.up then return 0 end
			if buff.fires_of_justice.up then x = x - 1 end
            if buff.hidden_retribution_t21_4p.up then x = x - 1 end            
            return x
        end )

        addHandler( 'justicars_vengeance', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            else
                removeBuff( 'fires_of_justice' )
                removeBuff( 'hidden_retribution_t21_4p' )
            end
            if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, 1 ) end
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
            applyDebuff( 'player', 'forbearance', 30 )
        end )


        --[[ Calls down the Light to heal you for 2,497, increased by up to 200% based on your missing health. ]]
        addAbility( 'light_of_the_protector', {
            id = 184092,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 15,
            spec = 'protection',
            notalent = 'hand_of_the_protector',
        } )

        modifyAbility( 'light_of_the_protector', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'light_of_the_protector', function ()
            health.actual = health.actual * 1.33 * ( ( buff.consecration.up or talent.consecrated_hammer.enabled ) and 1.2 or 1 )
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


        --[[ Forces an enemy target to meditate, incapacitating them for 1 min.; ; Usable against Humanoids, Demons, Undead, Dragonkin, and Giants. ]]
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
            if buff.divine_purpose.up then return 0 end
            if buff.fires_of_justice.up then x = x - 1 end
            if buff.hidden_retribution_t21_4p.up then x = x - 1 end
            return x
        end )

        addHandler( 'templars_verdict', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )                
            else
                removeBuff( 'fires_of_justice' )
                removeBuff( 'hidden_retribution_t21_4p' )
            end
            if talent.righteous_verdict.enabled then applyBuff( 'righteous_verdict' ) end
            if equipped.whisper_of_the_nathrezim then applyBuff( 'whisper_of_the_nathrezim', 4 ) end
            if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, 1 ) end
        end )

        --[[ Lash out at your enemies, dealing 2,212 Radiant damage to all enemies within 12 yd in front of you and reducing their movement speed by 50% for 5 sec.; ; Demon and Undead enemies are also stunned for 5 sec.; ; Generates 5 Holy Power. ]]
        addAbility( 'wake_of_ashes', { 
            id = 255937,
            spend = -5,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 30,
            talent = 'wake_of_ashes',
        } )

        addHandler( 'wake_of_ashes', function ()
            if target.is_undead or target.is_demon then applyDebuff( 'target', 'wake_of_ashes', 6 ) end
            if equipped.ashes_to_dust then
                applyDebuff( 'target', 'ashes_to_dust', 6 )
                active_dot.ashes_to_dust = active_enemies
            end
            if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, active_enemies ) end
        end )


        --[[ Heals the 3 most injured friendly targets within 30 yards for 4,994. ]]
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
            if buff.divine_purpose.up then return 0 end
            if buff.fires_of_justice.up then x = x - 1 end
            if buff.hidden_retribution_t21_4p.up then x = x - 1 end
            return x
        end )

        addHandler( 'word_of_glory', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            else
                removeBuff( 'fires_of_justice' )
                removeBuff( 'hidden_retribution_t21_4p' )
            end
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


        addAbility( 'hammer_of_wrath', {
            id = 24275,
            spend = -1,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 6,
            talent = 'hammer_of_wrath',
            usable = function () return target.health_pct < 20 or buff.avenging_wrath.up or buff.crusade.up end,
        } )

        modifyAbility( 'hammer_of_wrath', 'cooldown', function( x )
            return x * haste
        end )


    end


    storeDefault( [[Protection ST]], 'actionLists', 20170727.205954, [[dWtfgaGAIkTEIQQnHKk7Ik2gfzFiP0SP08rsYNqs4Buu3gvTtuzVIDJy)sYOqsvdtknovQOtRQHIKudMQA4iXbrkNsLQ6yQ4CQujlKkzPeLftHLJYdvPk9uWYqQEUetuLk1uLIjlvtN0fvjDzONrL66k09iQYRjQWMvj2Uc0Hv67kGptvMNkvXirs0FLuJMiJxLkCsvktdjfxJOIoVcALevLhROFt4CstaGco)1(Y)QVGeotMcat2trdeqgAXTGHJE7XCRz60DoYj1CChGB5XauntO4uFbPYhAcqBQVGust4oPjWQklnrdCLSgwShxbGj7POb0NhLxBaAmVsaYYJYty71dSSa0mE7RddqrOVGe4gP)ZvfSaebbdidT4wWWrV9y6y2P19ja3YJbOAH(cs0WrpnbUswdl2JRaClpgqgAmkhyayYEkAav45zrNNOiJnsrlbKHwCly4O3EmDm706(e4gP)ZvfSaebbdqZ4TVomadngLdmWQklnrJgo3PjWvYAyXECfGB5Xa0gejEiJkkv(G0J2EayYEkAGcQ1gcYyXrFKrVTMoLzLp1w5FQ8PkQQYN6R8ngVCXXJTKE9Knw2oYCgPu5tDv(6ArI6mzJLTJSsTCh7E8irDqYAyXELp1v5pfcBxmaXrUJDpEKOotPL5HLk)7PY)u5F)aYqlUfmC0BpMoMDADFcCJ0)5QcwaIGGbOz82xhgyhejEiRuxKE02dSQYst0OHJAstGRK1WI94ka3YJbKVXUhps0aWK9u0abKHwCly4O3EmDm706(e4gP)ZvfSaebbdqZ4TVomGCh7E8irdSQYst0OHtottGRK1WI94ka3YJbUxbPGt2QVGeaMSNIgiGm0IBbdh92JPJzNw3Na3i9FUQGfGiiyaAgV91HbMcsbNSvFbjWQklnrJgotPjWvYAyXECfGB5XaUSyPG9kFQC55rwayYEkAGPqy7IbiogwSuWET0YZJmNP0Y8Wc1EcqJ5vceqgAXTGHJE7X0XStR7tGBK(pxvWcqeemanJ3(6WagwSuWET0YZJSaRQS0enA4mNMaRQS0ena3YJbOYLNhzv(Ilv(Qew5l79KuumwcqZ4TVomG0YZJSAXLAvcRzVNKIIXsazOf3cgo6ThthZoTUpbUr6)CvblarqWaWK9u0abUswdl2JROH7ottGRK1WI94kamzpfnWuiSDXaeNI0J2ET4sTkH1S3tsrXyXzkTmpSiVPqy7IbiofPhT9AXLAvcRzVNKIIXIZuAzEyPMFVJa0mE7RdduKE02RfxQvjSM9EskkglbUr6)CvblarqWa06dUKj2JRaClpgaKE02R8fxQ8vjSYx27jPOySeqgAXTGHJE7X0XStR7tayYEkAZqkya95XaRQS0enA4UR0e4kznSypUcWT8yaAdIepKrfLkFq6rBVYN6p3pamzpfnqazOf3cgo6ThthZoTUpbUr6)CvblarqWa0mE7RddSdIepKvQlspA7bwvzPjA0ObUB8YoA14kAc]] )

    storeDefault( [[Protection Defensives]], 'actionLists', 20170727.205954, [[deJzcaGEjH2evLSljvBJOmtQkmBkDBIQDsO9k2nf7xvgLKGHPGFdmuvkdwvnCQ0bLKofvv6ykAHkKLsQSycA5K8uKLPsEUetus0uPktMith1fvP6zKQUob2mvSDQQY3iftJQsDALgjvvCzOrlvFMu6Kkuhg01OQOZlP8xv8AQQQhlLZmEHeHYXq3uagB8cmVFLOdAkR)WsOkrhOalNrH0HwewWiEnm1mO56Q(0N(EQpe5ITfA3kc5fyIOmzHQ24fykXlIZ4fcYSkEHdrn16YHyOX)Rr777R3xqbpL(IwPqIq5yiQVOv69boVp3X3x3QTZiqq59RW0VHQkCTlxluPVOv6aCoChpQvBNrGGsiDOfHfmIxdtztn1h0pdn2iTniduHmadg6Ubk0IszuiQPwx2RMlgQSYBHJ4v8cD3afArPmke1uRlhsqbpf06C6i0gsekhd5hOr69boVp3X3)McWyJbQq6qlclyeVgMYMAQpOFgASrABqgOczagmuvHRD5AH6qJ0b4C4oECvagBmqfcYSkEHdhr9Xl0DduOfLYOqutTUCibf8uqRZPJqBirOCmKpwTD(9boVp3X3)McWyJbQq6qlclyeVgMYMAQpOFgASrABqgOczagmuvHRD5AHSR2oFaohUJhxfGXgduHGmRIx4WHdrn16YHcNaa]] )

    storeDefault( [[Protection Cooldowns]], 'actionLists', 20170727.205954, [[d4Y1baGEIQAxef2gPWSf62sPDkv7fTBq7Ncnmk53egkrPgmPYWf4Ga1XaSqsvlLQAXsXYj5Hev5PklJk9CrMirjtLitMkMUKlsPCzORtrTzkvBNuQVsu00iQ03jfDAvDyvgnf8nGCsb1ZiLCnIkopv5XI6VcYNPitakXjl0(zowupx)ArozRefMRxanQtEcr0rOjmX5Jr8si7UwaGSa56kda5ixaT4waM)l(Y)Qxazxdn4aNRxatuIDakXzdEnr0H65ww9bfhxyOZNVsO4GciYbU5JF5XLq1fy4B58XKWSkJjkXIZhJ4Lq2DTaabyX1VwKBO6cm8TSy3LsC2GxteDOEULvFqXXfg685RekoOaICGB(4xECOhgsypu5P48XKWSkJjkXIZhJ4Lq2DTaabyX1VwKZMhAuNWUrDsEkwSRfL4SbVMi6q9ClR(GIJZhtcZQmMOeloWnF8lpUtBeA6HMcPP6kdCHHoF(kHIdkGiNpgXlHS7AbacWIRFTihyTrOPhAYOozQUYalwClR(GIJfja]] )

    storeDefault( [[Protection Default]], 'actionLists', 20170727.205954, [[d4cWcaGEPiTluKTPu0SH6Mer3wuTtPAVu7wX(vHHjk)wyOOWGvrdNiDqr0XqPfkfwkr1IvjlxjpukQNcwMk1ZjmrLQMQuAYqA6KUie5QsrCzKRlcBwKSDuutdIY3jcNwY3ikpgvNuK6zkfUgevNxP0FHWNvQCyvTzDRH(NtgyScL4AfZX5Ek1NaRgaPeVEC10xRyCFZnniNW0li3VZyLLj7(MjwKJm2nma8vjvnyijxRyeU1Dw3AaP5VWeQByO)5KbgRqjUwXCCUNsrJOyMega(QKQg0y3omXucbHaLsrJOyMegKty6fK73zSYyZmKEql(RXYWedzi5vHlDRb(JXiEUwXGaxc1GKbA)ZjdmwHsCTI54CpLIgrXmjS6(TBnG08xyc1nm0)CYaJvOexRyooBocmAiXima8vjvnOXUDyIjEey0qIryqoHPxqUFNXkJnZq6bT4VgldtmKHKxfU0Tg4pgJ45AfdcCjudsgO9pNmWyfkX1kMJZMJaJgsmcRUVHBnG08xyc1nma8vjvnyi9Gw8xJLHjgYqYRcx6wdjeeIsPCHb5KisS4KWTwniNW0li3VZyLXMzO)5KHMiOJZ0kLlS6oYCRbKM)ctOUHH(NtgyScL4AfZXj0Aa4RsQAWGCctVGC)oJvgBMH0dAXFnwgMyidjVkCPBnWFmgXZ1kge4sOgKmq7FozGXkuIRvmhNqRvRg2tP(ey1nSAd]] )

    storeDefault( [[SimC Retribution: opener]], 'actionLists', 20180425.191508, [[diJQcaGAfK1dvPDPO8AOQMTuDtHCBOStrTxYUrA)uYWeQFR0GPudxehuGoMGwOIyPqLfJslhXdvu9uWYqvwNcWufPjlLPl5Ikuphfxw11POttvBva2mufBhvY3uittb0Nvq9DurZdvyCciJgv1HHCsuP(lf6AksNNcwPc0JPYZeqTcvQGXueB)nXkiJWUaWJn3Yg3lIN1S8lDaw2BYPNia37hXCL5fhgO4bYB6SqbqYDEu3Jxu5xQYJIfe0v(LYOuLdvQGXueB)nnra4i(Ksa)TBWyYY5jZCMeYPLLnhw2tfeK139LbbiIdrVXAjKtlbCtBEhQwIa6sVGOTfaIKryxGGmc7ccsCi6TStxc50saU3pI5kZloCuySaCNznjUZOuvcMZ)o8JwUo2PLyfeTTmc7cuPmpLkymfX2FtteaoIpPeWF7gmMSCEYmNjHCAzzZHL9ubbz9DFzqaBh1UXfpghYKP8UlGBAZ7q1seqx6feTTaqKmc7ceKryxWKoQDl7fpw2dAYuE3fG79JyUY8Idhfgla3zwtI7mkvLG58Vd)OLRJDAjwbrBlJWUavkhyLkymfX2FtteaoIpPeWF7gmMSCEYmNjHCAzzZHL9ubbz9DFzqWqMTHXoTeWnT5DOAjcOl9cI2waisgHDbcYiSlyqZ2WyNwcW9(rmxzEXHJcJfG7mRjXDgLQsWC(3HF0Y1XoTeRGOTLryxGkvcahXNucujb]] )

    storeDefault( [[SimC Retribution: default]], 'actionLists', 20180425.191508, [[dGZbeaGEkHAxqr51kfZekYSPy(kLUPs1DPcDBQANGSxXUHSFv1OOe1WiXVvzWQYWHQCqO0POK4ysPNlvlKsPLsslgulNupKk9uKLrOwhv0PvmvczYemDjxeQyCuc8mkbDDP48uQARubBwj2oLIPrjPht0NHQ67uI8xLuhgy0uQ8nOsNKsQ5bfvxJsi3tjXBvs6YOweu40grHWbbGnSqGdbb8CiA8U)Nkx6bUPMd58)e4fqJPcPYgg05ajwP1cuSQylcZAdr4XYbyglguZHceUkHWkR5q9ikqTruiCqaydleBdHfEmtzFind3SHdznsyKG60HqhIdTFcoa0qaphkeeWZHuz4MnCiv2WGohiXkT42QesL7xJwY9ikvix7y5M9Zg2ZOkWH2pbiGNdLkqIJOq4GaWgwi2gIK6bVkunE()W8)tCiSWJzk7djbgZAGSMdT2m9kKRDSCZ(zd7zuf4q7NGdaneWZHcbb8COTYLfffPCzzvxGX8FyL1CO)dttVCCRoewn(9qiGNxbdA8U)Nkx6bUPMd58)o8yeRXiKkByqNdKyLwCBvcPY9Rrl5EeLkK1iHrcQthcDio0(jab8CiA8U)Nkx6bUPMd58)o8yeRtfilmIcHdcaByHyBiSWJzk7djbgZAGSMdT2m9kK1iHrcQthcDio0(j4aqdb8COqqaphARCzrrrkxww1fym)hwznh6)W00lh3Q)pl3ALqy143dHaEEfmOX7(FQCPh4MAoKZ)tENr4SeQJriv2WGohiXkT42QesL7xJwY9ikvix7y5M9Zg2ZOkWH2pbiGNdrJ39)u5spWn1CiN)N8oJWzjupvGSAefchea2WcX2qyHhZu2hscmM1aznhATz6viRrcJeuNoe6qCO9tWbGgc45qHGaEo0w5YIIIuUSSQlWy(pSYAo0)HPPxoUv)FwwSvcHvJFpec45vWGgV7)PYLEGBQ5qo)p8zeRb1P7yesLnmOZbsSslUTkHu5(1OLCpIsfY1owUz)SH9mQcCO9tac45q04D)pvU0dCtnhY5)HpJynOoDpvQqKup4vHsLa]] )

    storeDefault( [[SimC Retribution: generators]], 'actionLists', 20180425.191508, [[dqKknaqiGuSikQAtKunkfItPqAvaiZcaf7IuggGogbTmkYZOOIPrIORrIsBdaL(gfLXbKQohaQADKuAEKuCpaAFaWbvOwOqYdfkxuuYijr6KIsTsGuAMuuPBsGDsQwkj5PunvHQTkK6RajVLef3LeH9c9xr1GbDyPwmHEmLMSKUmQnlWNffJwqNMOvtIQxdeZwKBRODJ0VvA4cXXbsLLRQNlX0v56uy7kOVtcNxbwpaQmFGA)igfIXrplAlM4kkIUEpz0D5mgbQIVxkACYLQwcmdt5VV9lORItCxyu3eqHGEGkPjLvti6Ee2k7KeGRp5srDZaI(y7jxAbJJ6cX4ONfTftCfJcD3(Yih6JqGGgc86etpTWEo5pFdYv89fQX0wmXvcemyc86pdFAHCNUqTi2JabaGeOjGeO6e4ieOOrqGwpKPzK0m5k((c1QRckbcgmbkAeeOzFJsxzT6QGsGJsGJI(yrzsEdqFy)YwmXOhlKTGiyhYtMEOi6c2A09R3tgDLUGcD9EYOd2geaeO1geOm(TptGr3jdwja)Op(ZuqN2tgqLUGcGzyNmyahb0CDIPNwypN8NVb5k((c1yAlM4kyWx)z4tlK70fQfXEaaqtavFerJGaTEitZiPzYv89fQvxfuWGfncc0SVrPRSwDvqhDu0vXjUlmQBcOqZeceDvCznElxW44HE20Q023(OtxkJUGTQ3tgD8qDtyC0ZI2IjUIrHUBFzKd9WnnipYQGFnRX)m9iqaaibQSeiyWe41jMEAskOZqwKNCPAmTftCLavNafncc0KuqNHSip5s1QRck6JfLj5naDBNs5T9Klnpjlh6Xczlic2H8KPhkIUGTgD)69KrhD9EYOd2geaeO1geOmX6uIahBp5sjqZvwoLa8J(4ptbDApzanVlNXiqv89srJtUu1sGbsQSeYFX8ORItCxyu3eqHMjei6Q4YA8wUGXXd9SPvPTV9rNUugDbBvVNm6UCgJavX3lfno5svlbgiPYsi)f8qDZbJJEw0wmXvmk0hlktYBa6H9CYF(gKR47le9SPvPTV9rNUugDbBn6(17jJo669KrxP9CYpbUbeiO((crxfN4UWOUjGcntiq0vXL14TCbJJh6Xczlic2H8KPhkIUGTQ3tgD8qDLeJJEw0wmXvmk0D7lJCOpcbgUPb5rwf8Rzn(NPhbQgajqGeiyWey4MgKhzvWVM14FMEeiGeOqcuDc0UBQUkOAIPUY5BqUYnkN0YAppBjTqGaGaZyRe4OOpwuMK3a0v0GW5BqExc5c6ztRsBF7JoDPm6c2A09R3tgD017jJoOAqycCdiWXLqUGUkoXDHrDtafAMqGORIlRXB5cghp0JfYwqeSd5jtpueDbBvVNm64H6klgh9SOTyIRyuO72xg5qpCtdYJSk4xZA8ptpcunasGMiqWGjWWnnipYQGFnRX)m9iqajqZHavNahHaT7MQRcQwypN8NVb5k((c1EE2sAHababMXwjqaIanrGGbtGd7x2IjwtPlOiWrrFSOmjVbOlM6kNVb5k3OCslJE20Q023(OtxkJUGTgD)69KrhD9EYOhvQRmbUbeiO1OCslJUkoXDHrDtafAMqGORIlRXB5cghp0JfYwqeSd5jtpueDbBvVNm64H6aSyC0ZI2IjUIrHUBFzKd9WnnipYQGFnRX)m9iq1aibAIabdMad30G8iRc(1Sg)Z0JavdGeOssGQtG2Dt1vbvtm1voFdYvUr5Kww75zlPfceaeygBLabic0ebQoboSFzlMynLUGc9XIYK8gGUYnQzMm9qpBAvA7BF0PlLrxWwJUF9EYOJUEpz0bTg1mtMEORItCxyu3eqHMjei6Q4YA8wUGXXd9yHSfeb7qEY0dfrxWw17jJoEOUzyC0ZI2IjUIrHUBFzKd9Rtm90c75K)8nixX3xOgtBXexjq1jWriWR)m8PfYD6c1IypcunasGMasGGbtGIgbbA9qMMrsZKR47luZicbcgmbkAeeOzFJsxznJie4OOpwuMK3a0TDkL32tU08KSCOhlKTGiyhYtMEOi6c2A09R3tgD017jJoyBqaqGwBqGYeRtjcCS9KlLanxz5ucWpboIWrrF8NPGoTNmGM3LZyeOk(EPOXjxQAjWajvwc5VyE0vXjUlmQBcOqZeceDvCznElxW44HE20Q023(OtxkJUGTQ3tgDxoJrGQ47LIgNCPQLadKuzjK)cEOoOhJJEw0wmXvmk0D7lJCOB3nvxfun7Bu6k)5L7LGWA2W(ZWL8GVTNCPDIabaGeOjcuDcCy)YwmXAkDbf6JfLj5naD7Bu6k)5L7LGWONnTkT9Tp60LYOlyRr3VEpz0rxVNm6XEJsx5Na97LGWORItCxyu3eqHMjei6Q4YA8wUGXXd9yHSfeb7qEY0dfrxWw17jJoEOoapgh9SOTyIRyuO72xg5qpCtdYJSk4xZA8ptpcunasGMiqWGjWWnnipYQGFnRX)m9iq1aibAoeO6eOD3uDvq1etDLZ3GCLBuoPL1EE2sAHababMXwjqaIanrGQtGd7x2IjwtPlOiqWGjWWnnipYQGFnRX)m9iqajqLKavNaT7MQRcQMyQRC(gKRCJYjTS2ZZwsleiaiWm2kbcqeOjcuDc0UBQUkOAk3OMzY0t75zlPfceaeygBLabic0ebQoboSFzlMynLUGc9XIYK8gGUDPf2(9jxk6ztRsBF7JoDPm6c2A09R3tgD017jJESLwy73NCPORItCxyu3eqHMjei6Q4YA8wUGXXd9yHSfeb7qEY0dfrxWw17jJoEOUqGyC0ZI2IjUIrH(yrzsEdq32PuEBp5sZtYYHE20Q023(OtxkJUGTgD)69KrhD9EYOd2geaeO1geOmX6uIahBp5sjqZvwoLa8tGJyAu0h)zkOt7jdO5D5mgbQIVxkACYLQwcmqsLLq(lMhDvCI7cJ6Mak0mHarxfxwJ3YfmoEOhlKTGiyhYtMEOi6c2QEpz0D5mgbQIVxkACYLQwcmqsLLq(l4H6cfIXrplAlM4kgf6JfLj5naD7Bu6k)5L7LGWONnTkT9Tp60LYOlyRr3VEpz0rxVNm6XEJsx5Na97LGWe4ichfDvCI7cJ6Mak0mHarxfxwJ3YfmoEOhlKTGiyhYtMEOi6c2QEpz0Xdp0D7lJCOJhI]] )

    storeDefault( [[SimC Retribution: finishers]], 'actionLists', 20180425.191508, [[diuCjaqiOeBIsPprsIrjs5uQQyvIinlHq1Ui0WiOJrGLjsEgusttekxteX2ecPVrjACIqADcHyEKK6EIuTpHKdsjSqrupuemrrO6IukoPqQvsssDtuyNKyPcvpLQPsPARqPERieDxriSxWFrrdgPdlzXO0JjAYcUSYMjP(mjXOvv1PHSAssYRfIMTOUTQSBP(nQgouCCHGLtQNtX0v56q12vv(oLuJxvLopLK1lekZxOSFedca7GBtxS5fawWvQ3a3rVei0470iw8dX7icHQg1iZ)PnGhF5vMbkPekirfMyPsIOaWDmtIQmkIvhI3GILcb3c5H4TbSdkca7GBtxS5fGKb3LAeMd8sEOVXC9EOzi0OsNqXk4wWIYOZkW)knQyZd8e(pzKm4F7T(awWzWdyxAL6nWdgMYYCfBEGRuVbEmPA1cfkLQvNi9JRhHIDLXxIiMgCl0QyaVR3spyyklZvS5fX)Qm(sVKh6BmxVhAMOshRGhF5vMbkPekWsbcbp(mCCTCgWoCGhDhqY64AWBEpWzWdk1BGdhOKcSdUnDXMxasgCxQryoWzXvRwe1rahzqhI3IbU1nHglgHYIRwTiQJaoYGoeVf17vO2qOQMqtcHAlH(NNTIjgU1tlkX161hHgv6ekwj0yXiuwC1QfrDeWrg0H4TOEVc1gcv1eAkHeQTeQKZZbU1Ty9TwfuRctR119xuVxHAdHQAcnjeQTe6FE2kMy4wpTOexRxFeAuPtOyfClyrz0zf4Ooc4id6q8g8O7aswhxdEZ7bodEa7sRuVbo4k1BGhDhbCKbDiEdE8LxzgOKsOalfie84ZWX1Yza7WbEc)Nmsg8V9wFal4m4bL6nWHduWkyhCB6InVaKm4UuJWCGxYd9nMR3dndHQ60juSsO2sOPrOyHqVkV(eLACtfM46InVaHglgHk58CGBDlk14Mkmr9EfQneAueQkYaHMucnfH(d4wWIYOZkW3VtIFiEZ0S(wlh4r3bKSoUg8M3dCg8a2LwPEdCWvQ3a3MFNe)q8Mq913A5ap(YRmdusjuGLcecE8z44A5mGD4apH)tgjd(3ERpGfCg8Gs9g4WbkjgyhCB6InVaKm4UuJWCG)vAuXMNyWWuwMRyZJqTLqzXvRwmG(q9yIbxJHBMiogWTGfLrNvGhqFOEmnhx)ap6oGK1X1G38EGZGhWU0k1BGdUs9g4jo6d1Jq9JRFGhF5vMbkPekWsbcbp(mCCTCgWoCGNW)jJKb)BV1hWcodEqPEdC4aLKa2b3MUyZlajdUl1imh4FLgvS5jgmmLL5k28iuBj00iuSqOxLxFIsnUPctCDXMxGqJfJqLCEoWTUfLACtfMOEVc1gcnkcvfzGqtkHMIq)bClyrz0zf4b0hQhtZX1pWJUdizDCn4nVh4m4bSlTs9g4GRuVbEIJ(q9iu)46hHMMGFap(YRmdusjuGLcecE8z44A5mGD4apH)tgjd(3ERpGfCg8Gs9g4WbkruWo420fBEbizWDPgH5aNfxTAXa6d1JjgCngUzI4yiuBjuSqOxLxFIAKk)VXXnm)MoGKN46InVa4wWIYOZkWvv4MdjlTH53Avw1YbE0DajRJRbV59aNbpGDPvQ3ahCL6nWv14MdjlTQyiuSxRYQwoWJV8kZaLucfyPaHGhFgoUwodyhoWt4)KrYG)T36dybNbpOuVboCGILGDWTPl28cqYG7sncZbolUA1Ib0hQhtm4AmCZeXXqO2sOPrOyHqVkV(e3VtIFiEZ0S(wlN46InVaHglgHk58CGBDlUFNe)q8MPz9Twor9EfQneAueQkYaH(d4wWIYOZkWV9WKlTH530bK8ap6oGK1X1G38EGZGhWU0k1BGdUs9g423dtU0QIHqXE6asEGhF5vMbkPekWsbcbp(mCCTCgWoCGNW)jJKb)BV1hWcodEqPEdC4aLefSdUnDXMxasgCxQryoWtJqXcHEvE9jk14MkmX1fBEbcnwmcvY55a36wuQXnvyI69kuBi0OiuvKbcnPeAkc9hc1wcnncfle6v51N4(Ds8dXBMM13A5exxS5fi0yXiuwC1QfLACtfMiogc1wcLfxTArPg3uHjAUsgjHQAcvGqcnwmcvY55a36wC)oj(H4ntZ6BTCI69kuBi0OiuvKbcnPeAkc9hWTGfLrNvGF7HjxAdZVPdi5bE0DajRJRbV59aNbpGDPvQ3ahCL6nWTVhMCPvfdHI90bK8i00e8d4XxELzGskHcSuGqWJpdhxlNbSdh4j8FYizW)2B9bSGZGhuQ3aho4a3LAeMdC4aaa]] )

    storeDefault( [[SimC Retribution: cooldowns]], 'actionLists', 20180425.191508, [[d4JhfaGEjvvBsQQSlk61uG9jvvDAs9yknBLmFuv3ekURKQ0TrXHHStOAVIDRy)u1OqjmmPY4KuH7jvLHkPsnyjgov6qsv4uOeDme54sv0cPqTuuLfJKLtYdHs9uILjPSojvXLbtfPAYsz6QCruspxPEMKQY1ryrsvQTIszZsY2PctJc6RsQKpJk9DOK5HOQ)IugnQy8svYjPqERKk6AiQCEeLVHs1bPI(TQoKc9iSoiQf0cveCeder0my7l8GtPPio9p1JVy)F1ESMDeEWcqBi416ivhDgwJCMKIiUGvJw66hD6Fco7DrCAp9p7qp4Kc9iSoiQf0IXreRs7EryHVqruvzsT(VTi2NjHRVWNVVqruvzICadx9WLgwk0XXKW1x4Z3xOiQQmTkInQbMeU(s)8fkIQktRIyJAGPcyq6z7lK3xQroFHpFF5qkUWzEAgG290AAWxiFF(IHD(clJ4KsV0hzrC)t)teS5awdW8oagyUqfbZ3ydPWrmqKi4igicFBvvxN1wvvN19F6FQx(QiovC3rged0xVDv)6hUqJM7JfO6DeEWcqBi416iXoPUi8G9tOSWo0ZfXOPPTO7vrMFGiy(goIbI4Q(1pCHgn3hlqLl41c9iSoiQf0IXreRs7Er48lYO5(ybktlHsbZ5lKVpFXqFPF(cl8LE4lhAbZzc9cSeN(hAByoySGjmiQf08f(89Lgqruvzc9cSeN(hAByoySGjHRVWYioP0l9rweKYIgG29kfmxeJMM2IUxfz(bIG5BSHu4igiseCedeXPYIgWxO)kfmxeEWcqBi416iXoPUi8G9tOSWo0ZfbBoG1amVdGbMlurW8nCedejxWRVqpcRdIAbTyCeNu6L(ilYMJgwnAFfnhWWfqJfIy000w09QiZpqemFJnKchXarIGJyGichnSA(Yx5lSbdxanwicpybOne8ADKyNuxeEW(juwyh65IGnhWAaM3bWaZfQiy(goIbIKl4gg6ryDqulOfJJiwL29IWcFHIOQYup9KqV1N(htcxFHpFFPh(YHwWCM6PNe6T(0)ycdIAbnFHLrCsPx6JSiihWWvpCPHLcDCIy000w09QiZpqemFJnKchXarIGJyGioDadx9W1xQlf64eHhSa0gcETosStQlcpy)eklSd9CrWMdynaZ7ayG5cvemFdhXarYfCYf6ryDqulOfJJiwL29IW5xKrZ9XcuMwcLcMZx6FF(IHrCsPx6JSiwfXg1GignnTfDVkY8debZ3ydPWrmqKi4igic2kInQbr4blaTHGxRJe7K6IWd2pHYc7qpxeS5awdW8oagyUqfbZ3WrmqKC5IiwL29IKlba]] )

    storeDefault( [[SimC Protection: max survival]], 'actionLists', 20180208.175100, [[dCt8caGAOeTErr2fuqBdkvZekWSL4MuY3eL2jvTxYUrSFkyyc63qgkuugmQy4iHoiQQLHuDmk14GsAHiLLkPwmuTCuEOOQNcESIEUctekutvGjlY0v6IIkFcksxw11LKncfXwrI2mukBhv6ZuORHemnOqEMOWHL62cnAuLXdLWjrsEnf1PPY5PiRuuuRdkQ(lsQLTceKJ04LNeUam(yRRkROjaMmhfxbcQF594Ytp0gRH0dPagAJvkKrgzfau8txxCzQxhIip2XUa(Z1HidfiVTceKJ04LNenb8XDf3AsaEbHsuJTkMjbursUzViMacICbwOeLnZ3XlqGVJxaTccLmWbtQyMeu)Y7XLNEODw7qb1FGQyZpuGwb559Pzle3hpzfUaluY3XlqR80vGGCKgV8KOjGpUR4wtcWpBCMzhXOaQij3SxetabrUaluIYM574fiW3XlG2zJZm7igfu)Y7XLNEODw7qb1FGQyZpuGwb559Pzle3hpzfUaluY3XlqR8zOab5inE5jrtaFCxXTMe0Szto1lIXozfqfj5M9IyciiYfyHsu2mFhVab(oEb8zZMCdCcqm2jRG6xEpU80dTZAhkO(dufB(Hc0kipVpnBH4(4jRWfyHs(oEbALhJuGGCKgV8KOjGpUR4wtckoJ82b1yzvYy8KvavKKB2lIjGGixGfkrzZ8D8ce474fGboJ8wmDyGtMRsgJNScQF594Ytp0oRDOG6pqvS5hkqRG88(0SfI7JNScxGfk574fOvRaFhVaWfZBGdMXq7NRdrWCdCInwyGZOIX1XTlALa]] )

    storeDefault( [[SimC Protection: default]], 'actionLists', 20180208.175100, [[dWZseaGAQGA9usyxusY2KentjbZwW8Pc1nfv3Lsk(Mc1YqvTtr2lz3i2VQQXrfYWOu)wLNl0qvvYGrIHJK6GOsNNk6yuPRPQOfIQSuvXIrQLtXIKe6PqpMQwNQsnrkj1ufLjROPl1fLuDvkPYLbxxvAJusPTIkSzfY2rf9mvf(ScAAub6VijhwPBlXOLKETcCsjLprjvDAuUhvaRKsIEiL4Tubz5QmH1jlDaMIwOvdJ23qlEcrVHrDlu4deGnckX321r28T)0QCD0NF8XyHi1GNTbMvSn7ikvzLc56B2rIktjxLjSozPdWu8eYLMfyTtH0H7Mun614uynYK53(mcjhbeMFtowtAlGqHPTac5fUB(tXAFnof(abyJGs8TDh7Al8bI3RXdrLPwOLQGFq(XjuaslAH53mTfqOAL4RmH1jlDaMINqU0SaRDkKgmrWmGrgkSgzY8BFgHKJacZVjhRjTfqOW0waH8atemdyKHcFGaSrqj(2UJDTf(aX714HOYul0svWpi)4ekaPfTW8BM2ciuTsFOmH1jlDaMINqU0SaRDkCn(Lau1NXaKwynYK53(mcjhbeMFtowtAlGqHPTac5A8lb(PKDgdqAHpqa2iOeFB3XU2cFG49A8quzQfAPk4hKFCcfG0Iwy(ntBbeQwjhuzcRtw6amfpHCPzbw7uyGnSAhPYHFNdlaPfwJmz(TpJqYraH53KJ1K2ciuyAlGWkWgwTT(4pfR8DoSaKw4deGnckX32DSRTWhiEVgpevMAHwQc(b5hNqbiTOfMFZ0waHQv6tLjSozPdWu8eM2ci06IWpLAnuIcFG49A8quzQfYLMfyTtHVrGkwdLOWAKjZV9zesoci8bcWgbL4B7o21wi6nmQBHQvQsLjSozPdWu8eYLMfyTtH(neOA9n7iufyXwynYK53(mcjhbeMFtowtAlGqHPTacDSF0iBBVF0ihYYgc)u46B2r(PubwSTghBeY1mmkKSfWbQiYkw(P8L5AW3SJ89pfQnxxrHpqa2iOeFB3XU2cFG49A8quzQfAPk4hKFCcfG0Iwy(ntBbeISILFkFzUg8n7iF)tHAZ1QvlmTfqiYkw(P8L5AW3SJ89pLjmAFdTAja]] )

    storeDefault( [[SimC Protection: precombat]], 'actionLists', 20180208.175100, [[dWZNdaGEcLAteQSlq12ikSpcfnBPmFq5MeYDPs5BKOwgvYor0Ef7wL9d0OiQAyu0VLmoIIgkrLbdy4eCqQOtrsCmPQtJ0cjrwkfAXez5KAruv9uupMsRdeYebHAQKutwvnDLUijPZtvPldDDPI)sbBLkvBMQSDqYZarZJqHptf(orPBRkhwXOLkDicLCsQkEni11iu19ibpKe65i8wqWPpQdR6nsn8hPWqm6nDABukmB1uHnCyJydhcmKUm7LPPltXdVxMIhsivomlGw60OI9S06cPmKryN2LwhruhY(OoSQ3i1WFukmB1uHnSybcStdVfobQhHU0hC8gPg(d7uI2ORVHfQLwxyFUp1oBPdF1HHfvF3hn58WWHjNhggM1ZZ00A98GGC1sRZny6Wo1oicFZdvWFNtcVp9CyqOwAD(dBeB4qGH0LzVY9MHnIevhTfjI6SHvSlAHwubf(WBJuyr1NCEy4oNeEF65WGqT06YgsxrDyvVrQH)Ouy2QPcBy5bb0vdHp7owObbGbdeyNgElCcupcDPp44nsn8dcOciG4abg7sHcnGh(OibiGyacazyNs0gD9nSqT06c7Z9P2zlD4RomSO67(OjNhgom58WWWSEEMMwRNheKRwADUbtdciFVkHDQDqe(MhQG)Q9ni7O9h2i2WHadPlZEL7ndBejQoAlse1zdRyx0cTOck8H3gPWIQp58WWv7Bq2rNnKqg1Hv9gPg(JsHzRMkSHLheqxne(S7yHgeagmqGDA4TWjq9i0L(GJ3i1WpiGkGaIdeySlfk0aE4JIeGaIPcGaqg2PeTrxFdlulTUW(CFQD2sh(QddlQ(UpAY5HHdtopmmmRNNPP165bb5QLwNBW0GaY7sLWo1oicFZdvWVGUA15a)gekzrT)WgXgoeyiDz2RCVzyJir1rBrIOoByf7IwOfvqHp82ifwu9jNhgwqxT6CGFdcLSOoB2WKZddZ0NIGaYPRfTlToiceqqJ26jnB2ea]] )

    storeDefault( [[SimC Protection: prot]], 'actionLists', 20180208.175100, [[dKuvRaqiuuweufAtqv9juuHrju5ucrRIuvSlOmmL4yOWYefptuktdfvDnsLSnsvvFJuLXHIkDorPI1jkvkZdQsDpOkQ9bvjhefzHuuEOqyIKkvDrkQ(OOuPAKqvKtkkzLOOIEPOujMjPsLBcv2jjnusvLLkuEkvtviTvHQ(QOufVvuQQ7cvb2l4VKyWeDyjlgHhRutwWLvTzu6ZkPrJOtJQvdvb9AsfZwQUTu2nKFJ0WPWXfLQ0YP0Zfz6kUoPSDrLVtQugpPQ05fvTErPsA(uK9tyGbefCZrfr)bGaCD)zlT(aMbUVTCJbCWJ9(R0b1mlmyUlzw0fgdMRUYw20dC34BE15zxRHtrGQ(R)GZ0E4uucIcQmGOGBoQi6paMbUVTCJbCMjKt1pAWs3wgK8g2rfr)bHeFHmoHS2dNIWsK83dkuwLH8kw(k5CQwcBtw21Nes8siZiKrkK4lKmtiJtidNqJLf75VcLvzYBX0mes8fscnwwS6R8KcLvPZxjhmndHeFHKqJLfRSHJgLWzpkClMMHqIVqsOXYITQv2aVqkuwLcT5hnk6WrRjmndHeFHKqJLflWZXrxjrYFpGPziK4lKeASSyg0HtryAgczKGZebVZN8GNi5VhuOSkd5vS8vY5uTe4zHc8Dnul4ik6GJJgIVSQv7GdUA1o4oj)9GqszfYH8czm(k5CQwc8yV)kDqnZcd9ySaESNOA29tquyapcYV1bhn3Bhnab44Ob1QDWHbuZarb3Cur0FamdCFB5gd4mtiNQF0GLUTmi5nSJkI(dcj(c5u9JgmIknCksHYQ05RKd2rfr)bHeFHS2dNIWsK83dkuwLH8kw(k5CQwcBtw21Nes8wizaote8oFYdorLgofPqzv68vYb8Sqb(UgQfCefDWXrdXxw1QDWbxTAhCZQ0WPiHKYkK6o(k5aES3FLoOMzHHEmwap2tun7(jikmGhb536GJM7TJgGaCC0GA1o4WaQzdIcU5OIO)ayg4(2YngW1sxj9oRc5Ro4mrW78jp4D(k5OqzvgYRyyPZ3d1cEwOaFxd1coIIo44OH4lRA1o4GRwTdUUJVsocjLvihYlK6NLoFpul4XE)v6GAMfg6Xyb8ypr1S7NGOWaEeKFRdoAU3oAacWXrdQv7GddOY8quWnhve9haZa33wUXaUw6kP3zviF1bNjcENp5bNSqbfkRYqEfdlD(EOwWZcf47AOwWru0bhhneFzvR2bhC1QDWXtfkiKuwHCiVqQFw689qTGh79xPdQzwyOhJfWJ9evZUFcIcd4rq(To4O5E7ObiahhnOwTdomGQUGOGBoQi6paMbUVTCJb84esoAtBC0QsOA16vySSSS0scjElKKV6djwR0xHuFesgyz0LqgPqIVqs(QpKyg7riXBHux6siXxiNQF0Gz5RKZPAjfdlD(EOwSJkI(dGZebVZN8G35RKJcLvziVIHLoFpul4zHc8Dnul4ik6GJJgIVSQv7GdUA1o46o(k5iKuwHCiVqQFw689qTczCmIe8yV)kDqnZcd9ySaESNOA29tquyapcYV1bhn3Bhnab44Ob1QDWHbu1Fik4MJkI(dGzG7Bl3yapoHKJ20ghTQeQwTEfgzBzzPLes8wijF1hsSwPVcP(iKmW0FHmsHeFHK8vFiXm2JqI3cPU0f4mrW78jp4D(k5OqzvgYRyyPZ3d1cEwOaFxd1coIIo44OH4lRA1o4GRwTdUUJVsocjLvihYlK6NLoFpuRqgxMibp27VshuZSWqpglGh7jQMD)eefgWJG8BDWrZ92rdqaooAqTAhCyav9GOGBoQi6paMbUVTCJb84esoAtBC0QsOA16v0)LLLwsiXBHK8vFiXAL(kK6JqUGPNqgPqIVqs(QpKyg7riXBHu)1LqIVqov)ObZYxjNt1skgw689qTyhve9haNjcENp5bNSqbfkRYqEfdlD(EOwWZcf47AOwWru0bhhneFzvR2bhC1QDWXtfkiKuwHCiVqQFw689qTczCmIe8yV)kDqnZcd9ySaESNOA29tquyapcYV1bhn3Bhnab44Ob1QDWHbuzUquWnhve9haZa33wUXaECcjhTPnoAvjuTA9kzNLLLwsiXBHK8vFiXAL(kK6JqYalJqgPqIVqs(QpKyg7riXBHux6cCMi4D(KhCYcfuOSkd5vmS057HAbpluGVRHAbhrrhCC0q8LvTAhCWvR2bhpvOGqszfYH8cP(zPZ3d1kKXLjsWJ9(R0b1mlm0JXc4XEIQz3pbrHb8ii)whC0CVD0aeGJJguR2bhgqn7arb3Cur0FamdCFB5gd4mtiNQF0GLUTmi5nSJkI(dcj(c5u9JgmDq8vYrzEZOxwSJkI(dcj(cjhTPnoAvjuTA9kz01YsljK4Lqs(QpKyTsFfs9rixWyEHeFHKzczCcz4eASSyp)vOSktElMMHqAYKqsOXYIvFLNuOSkD(k5GPziKMmjKeASSyLnC0Oeo7rHBX0mestMescnwwSvTYg4fsHYQuOn)OrrhoAnHPziKMmjKeASSybEoo6kjs(7bmndH0KjHKqJLfZGoCkctZqiJeCMi4D(Kh8aphhDL08hapluGVRHAbhrrhCC0q8LvTAhCWvR2bx3ZZXrxi95paES3FLoOMzHHEmwap2tun7(jikmGhb536GJM7TJgGaCC0GA1o4WaQmwGOGBoQi6paMbUVTCJbCMjKt1pAWs3wgK8g2rfr)bHeFHKJ20ghTQeQwTELm6AzPLes8sijF1hsSwPVcP(iKlymVqIVqYmHmoHmCcnwwSN)kuwLjVftZqinzsij0yzXQVYtkuwLoFLCW0mestMescnwwSYgoAucN9OWTyAgcPjtcjHgll2Qwzd8cPqzvk0MF0OOdhTMW0mestMescnwwSaphhDLej)9aMMHqAYKqsOXYIzqhofHPziKrcote8oFYd(ZFfkRYK3cEwOaFxd1coIIo44OH4lRA1o4GRwTdU55VqszfYO5TGh79xPdQzwyOhJfWJ9evZUFcIcd4rq(To4O5E7ObiahhnOwTdomGkdgquWnhve9haZa33wUXaUw6kHZEuIN7jHeFHmoHKzc5u9JgS0TLbjVHDur0FqiXxi5OnTXrRkHQvRxjJUwwAjHeVesYx9HeRv6RqQpc5cgZlK4lKmtiJtidNqJLf75VcLvzYBX0mestMescnwwS6R8KcLvPZxjhmndH0KjHKqJLfRSHJgLWzpkClMMHqAYKqsOXYITQv2aVqkuwLcT5hnk6WrRjmndH0KjHKqJLflWZXrxjrYFpGPziKMmjKeASSyg0HtryAgczKczKGZebVZN8GxFLNuOSkD(k5aEwOaFxd1coIIo44OH4lRA1o4GRwTdotFLNeskRqQ74RKd4XE)v6GAMfg6Xyb8ypr1S7NGOWaEeKFRdoAU3oAacWXrdQv7GddOYidefCZrfr)bWmW9TLBmGRLUs4ShL45EsiXxiJtizMqov)OblDBzqYByhve9hes8fsoAtBC0QsOA16vYORLLwsiXlHK8vFiXAL(kK6JqUGX8cj(cjZeY4eYWj0yzXE(RqzvM8wmndH0KjHKqJLfR(kpPqzv68vYbtZqinzsij0yzXkB4OrjC2Jc3IPziKMmjKeASSyRALnWlKcLvPqB(rJIoC0ActZqinzsij0yzXc8CC0vsK83dyAgcPjtcjHgllMbD4ueMMHqgPqgj4mrW78jp4RALnWlKcLvPqB(rJIoC0Ac8Sqb(UgQfCefDWXrdXxw1QDWbxTAh8S7ALnWlKqszfsMqB(rJqMDHJwtGh79xPdQzwyOhJfWJ9evZUFcIcd4rq(To4O5E7ObiahhnOwTdomGkJSbrb3Cur0FamdCFB5gd4APReo7rjEUNes8fY4esMjKt1pAWs3wgK8g2rfr)bHeFHCQ(rdglhvDL0uOa2rfr)bHeFHKJ20ghTQeQwTELm6AzPLes8sijF1hsSwPVcP(iKlymVqIVqYmHmoHmCcnwwSN)kuwLjVftZqinzsij0yzXQVYtkuwLoFLCW0mestMescnwwSYgoAucN9OWTyAgcPjtcjHgll2Qwzd8cPqzvk0MF0OOdhTMW0mestMescnwwSaphhDLej)9aMMHqAYKqsOXYIzqhofHPziKrkKrcote8oFYdEGNJJUsIK)Ea8Sqb(UgQfCefDWXrdXxw1QDWbxTAhCDpphhDH0j5Vhap27VshuZSWqpglGh7jQMD)eefgWJG8BDWrZ92rdqaooAqTAhCyavgmpefCZrfr)bWmW9TLBmGRLUs4ShL45EsiXxiJtizMqov)OblDBzqYByhve9hes8fsoAtBC0QsOA16vYORLLwsiXlHK8vFiXAL(kK6JqUGX8cj(cjZeY4eYWj0yzXE(RqzvM8wmndH0KjHKqJLfR(kpPqzv68vYbtZqinzsij0yzXkB4OrjC2Jc3IPziKMmjKeASSyRALnWlKcLvPqB(rJIoC0ActZqinzsij0yzXc8CC0vsK83dyAgcPjtcjHgllMbD4ueMMHqgPqgj4mrW78jp4LnC0Oeo7rHBbpluGVRHAbhrrhCC0q8LvTAhCWvR2bNjB4Ori19N9OWTGh79xPdQzwyOhJfWJ9evZUFcIcd4rq(To4O5E7ObiahhnOwTdomGkdDbrb3Cur0FamdCFB5gd4APRKENvH8vxiXxizMqov)OblDBzqYByhve9hes8fsYx9HeZypcjElKm0f4mrW78jp49kVcfPqwOqc8Sqb(UgQfCefDWXrdXxw1QDWbxTAhCDxLxiPiHepvOqc8yV)kDqnZcd9ySaESNOA29tquyapcYV1bhn3Bhnab44Ob1QDWHbuzO)quWnhve9haZa33wUXaoHgllwL7OvoAvr3S1qIPziK4lKt1pAWs3wgK8g2rfr)bHeFHS2dp3vo6n(tcjElKzdCMi4D(KhCd6WPiWZcf47AOwWru0bhhneFzvR2bhC1QDWnTzzxw2Bw2SV(rhofHhyYcot21e4OQD8mEK2dk6wzXJGh79xPdQzwyOhJfWJ9evZUFcIcd4rq(To4O5E7ObiahhnOwTdoThu0TYcdOYqpik4MJkI(dGzG7Bl3yaNqJLfRYD0khTQOB2AiX0mes8fYP6hnyPBldsEd7OIO)GqIVqw7HN7kh9g)jHeVWZcz2aNjcENp5b3GoCkc8Sqb(UgQfCefDWXrdXxw1QDWbxTAhCtBw2LL9MLn7RF0Htr4bMSczCmIeCMSRjWrv74z8OHL2PO1humO62T4rWJ9(R0b1mlm0JXc4XEIQz3pbrHb8ii)whC0CVD0aeGJJguR2b3Ws7u06dkguD7wyavgmxik4MJkI(dGzG7Bl3yaNzc5u9JgS0TLbjVHDur0FaCMi4D(KhCd6WPiWZcf47AOwWru0bhhneFzvR2bhC1QDWnTzzxw2Bw2SV(rhofHhyYkKXLjsWzYUMahvTJNXJAiIJcC0QIbD4ueEe8yV)kDqnZcd9ySaESNOA29tquyapcYV1bhn3Bhnab44Ob1QDW1qehf4Ovfd6WPiyavgzhik4MJkI(dGzG7Bl3yaNJ20ghTQeQwTELm6AzPLes8sijF1hsSwPVcP(iKlymVqIVqYmHmoHmCcnwwSN)kuwLjVftZqinzsij0yzXQVYtkuwLoFLCW0mestMescnwwSYgoAucN9OWTyAgcPjtcjHgll2Qwzd8cPqzvk0MF0OOdhTMW0mestMescnwwSaphhDLej)9aMMHqAYKqsOXYIzqhofHPziKrkKMmjKtzx)Gn82vgQsGFHeVXZczgDbote8oFYdUbD4ue4zHc8Dnul4ik6GJJgIVSQv7GdUA1o4M2SSll7nlB2x)OdNIWdmzfY4YwKGZKDnboQAhpJhd26i(wjn2Jwhs8i4XE)v6GAMfg6Xyb8ypr1S7NGOWaEeKFRdoAU3oAacWXrdQv7GhS1r8TsAShToKWaQzwGOGBoQi6paMbUVTCJbCMjKt1pAWs3wgK8g2rfr)bWzIG35tEWRChTYrRk6MTgsWZcf47AOwWru0bhhneFzvR2bhC1QDWzk3rRC0QqM9yRHe8yV)kDqnZcd9ySaESNOA29tquyapcYV1bhn3Bhnab44Ob1QDWHbuZWaIcU5OIO)ayg4(2YngWzMqov)OblDBzqYByhve9haNjcENp5bhpulS2oAapluGVRHAbhrrhCC0q8LvTAhCWvR2bN5ulS2oAap27VshuZSWqpglGh7jQMD)eefgWJG8BDWrZ92rdqaooAqTAhCya1mzGOGBoQi6paMbUVTCJbCMjKt1pAWs3wgK8g2rfr)bHeFHCQ(rd22QLQWTjf8qTWA7Ob7OIO)GqIVqsOXYITAluqzB1sv4wmndWzIG35tEWRChTEBsjrYFpaEwOaFxd1coIIo44OH4lRA1o4GRwTdot5oA9wMJKq6K83dGh79xPdQzwyOhJfWJ9evZUFcIcd4rq(To4O5E7ObiahhnOwTdomGAMSbrb3Cur0FamdCFB5gd4mtiNQF0GLUTmi5nSJkI(dGZebVZN8Gt0Fk9Gcz1A3cEwOaFxd1coIIo44OH4lRA1o4GRwTdUz9NspiK4PQ1Uf8yV)kDqnZcd9ySaESNOA29tquyapcYV1bhn3Bhnab44Ob1QDWHbuZW8quWnhve9haZa33wUXaoZeYP6hnyPBldsEd7OIO)a4mrW78jp4vUJwVnPKi5VhapluGVRHAbhrrhCC0q8LvTAhCWvR2bNPChTElZrsiDs(7bHmogrcES3FLoOMzHHEmwap2tun7(jikmGhb536GJM7TJgGaCC0GA1o4WaQz0fefCZrfr)bWmW9TLBmGZmHCQ(rdw62YGK3WoQi6paote8oFYd(MIsFBRHtrGNfkW31qTGJOOdooAi(YQwTdo4Qv7GhbfL(2wdNIap27VshuZSWqpglGh7jQMD)eefgWJG8BDWrZ92rdqaooAqTAhCya1m6pefCZrfr)bWmW9TLBmGZmHCQ(rdw62YGK3WoQi6paote8oFYdoz1A3QqzvgYRy5RKZPAjWZcf47AOwWru0bhhneFzvR2bhC1QDWXtvRDRqszfYH8czm(k5CQwc8yV)kDqnZcd9ySaESNOA29tquyapcYV1bhn3Bhnab44Ob1QDWHbuZOhefCZrfr)bWmW9TLBmGpv)OblDBzqYByhve9hes8fYApCkclrYFpOqzvgYRy5RKZPAjSnzzxFsiXl8SqMbCMi4D(Kh80TLbjVbEwOaFxd1coIIo44OH4lRA1o4GRwTdUFBzqYBGh79xPdQzwyOhJfWJ9evZUFcIcd4rq(To4O5E7ObiahhnOwTdomGAgMlefCZrfr)bWmW9TLBmGpv)OblDBzqYByhve9hes8fY4escnwwS0TLbjVHPziKMmjKBkThO6gclDBzqYBy23kokjK4TqY8czKGZebVZN8Gx5oALJwv0nBnKGNfkW31qTGJOOdooAi(YQwTdo4Qv7GZuUJw5OvHm7XwdPqghJibp27VshuZSWqpglGh7jQMD)eefgWJG8BDWrZ92rdqaooAqTAhCya1mzhik4MJkI(dGzG7Bl3yaxlDLWzpkXZ9KqIVqov)OblDBzqYByhve9hes8fscnwwS0TLbjVHPzaote8oFYdEzdhnkHZEu4wWZcf47AOwWru0bhhneFzvR2bhC1QDWzYgoAesD)zpkCRqghJibp27VshuZSWqpglGh7jQMD)eefgWJG8BDWrZ92rdqaooAqTAhCya1STarb3Cur0FamdCFB5gd4t1pAWs3wgK8g2rfr)bHeFHmoHCtP9av3qyBkk9TTgofHzFR4OKqIx4zHCbJHqIVqgNqw7Htryjs(7bfkRYqEflFLCovlHTjl76tcjEjKzW0LqIVqUP0EGQBiS0TLbjVHzFR4OKqIxcz2eYifstMeY4escnwwS0TLbjVHPziKrkKrcote8oFYdEIK)EqHYQmKxXYxjNt1sGNfkW31qTGJOOdooAi(YQwTdo4Qv7G7K83dcjLvihYlKX4RKZPAjHmogrcES3FLoOMzHHEmwap2tun7(jikmGhb536GJM7TJgGaCC0GA1o4WaQzJbefCZrfr)bWmW9TLBmGpv)OblDBzqYByhve9hes8fYN9QXnmEaZG37LnPqzv4OgnnkD(k5iK4lKeASSyPBldsEdtZaCMi4D(Kh8N)kuwLjVf8Sqb(UgQfCefDWXrdXxw1QDWbxTAhCZZFHKYkKrZBfY4yej4XE)v6GAMfg6Xyb8ypr1S7NGOWaEeKFRdoAU3oAacWXrdQv7GddOMTmquWnhve9haZa33wUXa(u9JgS0TLbjVHDur0FaCMi4D(Kh8k3rR3MusK83dGNfkW31qTGJOOdooAi(YQwTdo4Qv7GZuUJwVL5ijKoj)9GqgxMibp27VshuZSWqpglGh7jQMD)eefgWJG8BDWrZ92rdqaooAqTAhCya1SLnik4MJkI(dGzG7Bl3yaFQ(rdw62YGK3WoQi6piK4lKXjK1E45UYrVXFsiXBHmJqAYKqM(OqqrAjSHFBMfLmgBHeVeYfHmsWzIG35tEWXd1cRTJgWZcf47AOwWru0bhhneFzvR2bhC1QDWzo1cRTJgHmogrcES3FLoOMzHHEmwap2tun7(jikmGhb536GJM7TJgGaCC0GA1o4WaQzJ5HOGBoQi6paMbUVTCJb8P6hnyPBldsEd7OIO)GqIVqgNqsOXYILUTmi5nm7BfhLes8si1FH0KjHKqJLflDBzqYBybQUHeYibNjcENp5bFtrPVT1WPiWZcf47AOwWru0bhhneFzvR2bhC1QDWJGIsFBRHtrczCmIe8yV)kDqnZcd9ySaESNOA29tquyapcYV1bhn3Bhnab44Ob1QDWHbuZMUGOGBoQi6paMbUVTCJb8P6hnyPBldsEd7OIO)a4mrW78jp44HAH12rd4zHc8Dnul4ik6GJJgIVSQv7GdUA1o4mNAH12rJqgxMibp27VshuZSWqpglGh7jQMD)eefgWJG8BDWrZ92rdqaooAqTAhCya1SP)quWnhve9haZa33wUXa(u9JgS0TLbjVHDur0FaCMi4D(Kh8nfL(2wdNIapluGVRHAbhrrhCC0q8LvTAhCWvR2bpckk9TTgofjKXLjsWJ9(R0b1mlm0JXc4XEIQz3pbrHb8ii)whC0CVD0aeGJJguR2bhgqnB6brb3Cur0FamdCFB5gd4t1pAWs3wgK8g2rfr)bHeFHKzc5ZE14ggpGzW79YMuOSkCuJMgLoFLCaNjcENp5b)5VcLvzYBbpluGVRHAbhrrhCC0q8LvTAhCWvR2b388xiPScz08wHmUmrcES3FLoOMzHHEmwap2tun7(jikmGhb536GJM7TJgGaCC0GA1o4WaQzJ5crb3Cur0FamdCFB5gd4t1pAWs3wgK8g2rfr)bWzIG35tEWj6pLEqHSATBbpluGVRHAbhrrhCC0q8LvTAhCWvR2b3S(tPhes8u1A3kKXXisWJ9(R0b1mlm0JXc4XEIQz3pbrHb8ii)whC0CVD0aeGJJguR2bhgqnBzhik4MJkI(dGzG7Bl3yaFQ(rdw62YGK3WoQi6paote8oFYdoz1A3QqzvgYRy5RKZPAjWZcf47AOwWru0bhhneFzvR2bhC1QDWXtvRDRqszfYH8czm(k5CQwsiJJrKGh79xPdQzwyOhJfWJ9evZUFcIcd4rq(To4O5E7ObiahhnOwTdomWaUA1o4oVfHqQFw689WPOSBcPHLoWaaa]] )

    storeDefault( [[SimC Protection: max dps]], 'actionLists', 20180208.175100, [[dCd7caGAOOA9IQ0UevvBdkvZuuvMTKUjL8nrXoPQ9s2nI9tbdtq)gYqHIyWOsdhj1brvTmKQJrPghuIfIuwQcwmuTCuEOOYtbpwrpxIjcf0ufyYcnDLUOO0NGI0LvDDfAJqHSvKWMHsz7ijFMcDnOKMguGNHk6WsDBrgnQY4HIYjrIEnf1PPY5PiRuufRdku)fvyzRabzjnE9rHladp26X6kAcGjZr9kqWWRVlxE6H2yjKEiwZVnwWkNCMraq9NUU6YBVoerESJDb8NRdrkkqEBfiilPXRpkAc4J7QU1Ka8kcf5aBJmtcOKeDZErmbee5cSqrkAMVtxGaFNUaAvekAGlgnYmjy413Llp9q7m2HcgEbnYMVOaTcYX7tZwiQE6Kv4cSqrFNUaTYtxbcYsA86JIMa(4UQBnja)SYzMDeJcOKeDZErmbee5cSqrkAMVtxGaFNUaANvoZSJyuWWRVlxE6H2zSdfm8cAKnFrbAfKJ3NMTqu90jRWfyHI(oDbALNtfiilPXRpkAc4J7QU1KGMnBY5yrm2jRakjr3SxetabrUaluKIM570fiW3PlGpB2KBGBaIXozfm867YLNEODg7qbdVGgzZxuGwb549PzlevpDYkCbwOOVtxGw5XafiilPXRpkAc4J7QU1KGQZiVTWbMpgnMozfqjj6M9IyciiYfyHIu0mFNUab(oDb5ZzK3IPfdCZZy0y6KvWWRVlxE6H2zSdfm8cAKnFrbAfKJ3NMTqu90jRWfyHI(oDbA1kW3PlaCPCg4Ijm0(56qem2a3uJzg4gPUOvc]] )


    storeDefault( [[Retribution Primary]], 'displays', 20180425.191508, [[da00jaqlsq2ffv1WiPJrjlts5ziKMgffxJkX2ibvFtsLgNKkADauDpkQshuPSqQQhsrMijWfbXgPs9rQKgPKQojk5LaKzscDtkQSts9tqzOuLJcqPLcGNcnveDvkkTvkQIVkPcJLeuwlaf7vmyeCyflMkEmkMSs1LLAZuQpJsnAkCAKEncXSvYTLKDt0Vv1WrvhhKSCcpxIPRY1bA7KOVdOXJqDEuz9Gu7huDSczqMH)OV09lp84wDqyMLurwAibzg(J(s3V8qk0D0w1ckgj72KrZqK4h0zrHgAxxpW4eKdMTDPptd)rFzjA1GedZ2U0NPH)OVSeTAqOaBWENfZlrk0D0UOgKY8s)xS3I4hSIk3Genrdcfyd27Mg(J(Ys8dsmNPxQSfxVh)GfJhi5iy3xj(b5GzBx6JCeS7ReTAqalyd2LqgTvidcrooREp(b3yo6lHtqrA5IUwq9u1brALj4eaOpb1b8OVeWHtGx0mFLZCbbOx9u6ORPAvxvlv1GiJGYFbpAvBEvZfDTqgeICCw9E8dUXC0xcNGI0YfTvq9u1brALj4eaOpb1b8OVeWHtyVThW1feGE1tPJUMQvDvTuvZLlyX4bIaPhJXgK4hSy8a3aVp(bPmVe5hgQKD0UeCafdlP9tYX3bDaTTdcfyd27aYVe)GdOyi547GoG22b5IwHQvZLG2V8cUjOZcob9iepWGCWSTl9PGEnCrRgKyy22L(uqVgUOvdcOMZHk3Ps2WjGh3QJUwqI4SjzmErqsyEaWY16jdYbZ2U0hG8lrRqwbHcSb7DwmVSoO7Nr0UOgCw8gdA8a9u6fTvW1dSfmtPbKFjob5f0QrWXI5L13u2gx0UOgKyy22L(aKFjARGa0REkD01uTQRvnllZ3sHBgIwZmbn98CWjq(b9e)1mh9LWj4jOvJGlivUtzM7fBsgJxeeawUwpzqIJwHQtIgKz4p6l3KmgViOpmssyMliVGwncowmVePq3r7IAqKVzOZIc9C0xgDDvdwmEGiz8dcfyd2kGkAMJ(YGaWY16jdkbRyX8Ys0MjOsAH6qx0JJKJVd6eekWgS3wu2YQwEbzcw471Y9AkgM(1lczWjARGorBfKD0wbfrBLlyX4bAA4p6llXpiG6MFRW3mhaZr)4hCVThW1T5PyqKwzcoba6tqDap6lbC4e2B7bCDblgpWnqXWsA)XjONGwnco4emn8h9LWjSbkMGbRgI3aVpA1GedZ2U0hl5oLzUxuIwn4S4ng04b6Pes0wbNfVXy6RCMZtjKOTcQG2Eaxx8dolEJX0x5mNNsVOTcolGdxXtPx8dseh3V8c6rcNaoYcCc6riEGbzg(J(YTfLTmOjiAsiaeCNw4xdhjhFhCcY8voZ5PesCckgj7MKJVdoo0f94coGIXCuzh)Gqb2G9MKX4fbbGLR1tgKioUF5HuO7OTQf8gb7(C)YlOhjCc4ilWjOhH4bgCw8gd5iy3NNsVOTcYbZ2U0hl5oLzUxuIwnOOxbnbrtcbGGf(ETCVMIrCcolEJHCeS7ZtjKOTcU3RHZ9lp84wDqyMLurwAibjIJ7xE4XT6GWmlPIS0qccfyd27SK7uM5Erj(bVrWUppLEXj4nc295(LhECRoimZsQilnKGMBiMwbwbNajTQJMOQbHcSbB84wDqay5A9KbrgbL)cgCw8gZ2c4Wv8u6fTvWzXBmBlGdxXtjKOTcYlOvJGZ9lpKcDhTvTG8IM5RCMBZtXOvd6jOvJGdobtd)rFzWBeS7ReSAiEds0QbjNvlp4eCv8G8rBf8gb7(8ucjoblgpqpLqIFWIXdeqnNdvUtLSlXpiuGugIyEOf84wDWjyX4bQGEnCbjHOWidszEP)l2BHPF9IqgCI2kOt0QbzhTAqr0Q5cU3RHZ9lpKcDhTLzcwmEGEk9IFWIXdKLCNYm3lkXp4EVgo3V8cUjOZcob9iepWGZc4Wv8ucj(b5GzBx6BdumrRgSy8a3Ge)GmFLZCEk9ItqIHzBx6BdumrRgCVxd3MKX4fbjH5Pie3KbhqXSjzmErqFyKKWmNIqCtgSIkrYOvdEJGDFUF5HuO7OTQfekWgS3KmgVaMTDPVODjiZWF0x6(Lxqps4eWrwGtqpcXdm4akgKVxlwkiA1GqKJZQ3JFWcTIF1BWGeDTGkoLZ0lv2Ic9Lrxt1QovTSmJ5t0GedZ2U0h5iy3xjA1Gqb2G9olMxwFtzBCr7IAWIXdebspgJnW7JFWkQCd8(OvdwneJKrBf8gb7(2KmgViOpmssyMdawUwpzqaZ)vMEPYwC9E8dszEjG5)QOjQAqOaBWE39lpKcDhTvTG6PQdcqFcQd4rFjCcEcA1i4cYlOvJGJfZlRd6(zeTlQbDwuOH211dCBTItWbumMvsVG8RHRf5sa]] )

    storeDefault( [[Retribution AOE]], 'displays', 20180425.191508, [[diKSjaqiQQqBsPu1Tav0UukLHrfhJOwgL0ZOQQPrK4AeP2gLkvFduHXPuQSoQQO7rPsCqQYcvQEiLYebv5IQsBKQYhPu1ivk5KiQxcQQzIs6MejTts9tvLHkjhLsLYsvkEk0ur4QuQyRuvbFLQkzSuQKwlvvQ9kgmrCyflMIEmkMSQ4YsTzQ0NrKrtHtJ0RbvA2k52sQDt43adhvooOy5K8CjMUkxhKTtj(UQQXJsCEu16bL2pk1roebzgUJce(aIdp(vh8ZoeSsw)gKz4okq4dioKcBhTS1GQrqQTz0mWn7bnxuyH1(f4pMb5)CDl9zB4okquI2jilFUUL(SnChfikr7eKtrRhfpzgGaPW2rlTtWIb43dsnKfUGygegOgQFSnChfikzpil82aclT66NShKYae7a1tRYEq(px3sFeJIuFLODcA3GAOUeIOLdrWxXyU6NSh0J5OabBjSslx0wdQN6oisRTXwYM(uutOJce(jBjCQMbuBoxWn9QNshTvhzPLL3MvRYbrgfL7cE062U4KlARHi4Rymx9t2d6XCuGGTewPLlA5G6PUdI0ABSLSPpf1e6OaHFYwYt7oqRl4ME1tPJ2QJS0YYBZQv5C5cwma)4p9ym8EJzqw(CDl9rmks9vI2jiLbiqUHHkifT0bVrrQppbJbqfC)JG4tQBiB)webRPcpOdeT)bHbQH6h4VxYEq(OHtz4WjOlqCb9u0zXwIEukWFq(px3sFWRxdF0obz5Z1T0h861WhTtq438MuXdvqITe84xD0wdcxtpbJbqfK4RAdz73IiyXa8tmks9vYEqyGAO(Hmdq4x0NZiAPDccV2DGwx2doloJbna)vwQIwoiNIwpkEYmaXwnLKXfT0obHRPpG4cwrWwcoIcBj6rPa)b30REkD0wDKHdzRYYBt2Ulf)TkLG8FUUL(G)EjA4uoiv8qzMdO8emgavWnKTFlIGWa1q9dzgGaPW2rlTtqMH7OaHNGXaOcU)rq8j1Gp0c3A4j456GmbTb44zlHaeCtFkQj0rbc2s8(Edwma)ir2dcdud1WJQAMJceb3q2(TickGQjZaeLOLsWbsne8CDqtix3GS856w6d(7LOLdw461Y3Akg2alGkebNOLdAgTCqsrlhufTCUGfdWVTH7Oarj7bHF3CEfUM52mhfK9GpT7aToVkwJ2jimqnu7TOKe1T4cYeK)Z1T0hzXdLzoGQeTtW6HfpOdeTtqw(CDl9rw8qzMdOkr7eCwCgdAa(RS8gTCWzXzm2a1MZvz5nA5G6PUdUPpf1e6OabBjEFVbRu06rXZwITH7OabBjEqQjyWz9p8LklvzpOfAHAsx0JNGNRdAgKz4okq4TOKebT9QjE3eegikdC9d0cE8RoOzWzXzm2a1MZvzPkA5GQrqQj456GJjDrp(GdKAKkv0zpimqnu7jymaQGBiB)webHRPpG4qkSD0YwdoloJXB9p8LklVrlhCwCgdXOi1xLLQOLdoqQXtWyaub3)ii(KkRV(icQ6vqBVAI3nbVrrQpFaXfSIGTeCef2s0Jsb(doloJHyuK6RYYB0YbHRPpG4WJF1b)SdbRK1VbHbQH6hYIhkZCavj7bz5Z1T0NhKAI2jyXa8d)M3KkEOcsLSh8gfP(8behE8Ro4NDiyLS(nOuhwO1q1SLqqR7O93jimqnuJh)QdUHS9BreezuuUlyHkiT6T3poqhi4S4mgV1)WxQSufTCWcxVw(wtXiMb5u06rX7dioKcBhTS1GCQMbuBoNxfRr7eCGudzHlGGNRdAc56gSEyX7nANGeZQfhBj2RaqCr7e8gfP(QS8gZGp9A49behsHTJwwkbRu06rXZwITH7OarWBuK6ReSya(9EJzWBuK6RYsvmd(0RH3tWyaubj(Qy91hrqgqT5CvwEJzWNEn8(aIdp(vh8ZoeSsw)gSya(jlEOmZbuLShKYae7a1tRSbwavicorlh0mANGKI2jOkANCbN1)WxQS8M9GfdWFLLQShSya(RS8M9GmGAZ5QSufZGp9A49bexqpfDwSLOhLc8hSya(HxVg(GeV2vIG8FUUL(8Gut0obRPcKiA)dEJIuF(aIdPW2rlBnimqnu7jymaQpx3sFrlDqMH7OaHpG4cwrWwcoIcBj6rPa)bhi1GC9ArgEr7e8vmMR(j7bl0AUv799gT1GSoLZgqyPvfkqeTvh5TZrwwkBZ)GWa1q9dzgGyRMsY4IwANG1uH3B0(hSya(XF6Xy4bDGShSya(9GoqmdwpSGer7eKLOHZTZ)G(nauBdiS0QRFYEqkdq43aqD0(7eegOgQF8behsHTJw2AqZffwyTFb(9wRygKtrRhfpzgGWVOpNr0s7ee5Ag6SOWohfiIgoCcoqQXoc6fKBn8Tkxc]] )

    storeDefault( [[Protection Primary]], 'displays', 20180205.185337, [[da0bkaqlsuSlsunmk5yuvlJs1ZiLAAKixdqY2au(MuuyCsrLZjffToPO0bLkluL8qkLjcO6IazJsHpkfzKaItIu9sqfZeP0njL0oP4Ni0qjPJsIswkc8uOPIORskXwjrP(kGuglGuTwPOQ9kgmqDyflwQ6XGmzaUSKntv(mjmAs1Pr51GknBvCBP0Ur1Vv1Wj44GQworpNktxPRJKTtk(Uk14rkopHwpcA)GYXpKbHgHL98gpFXv8ubjQfsAPBafChPIAv1OM(GYHROSPxqWnxb7pmcjSPZFN(GIe98C1ABew2ZDXyfeEQIQaqh65aPyk03yuYki8ufvbGo0ZrgHvmkzf0P)3DuYHo37tFq4PkQcGTryzp3LRG0iA75Ak5waYvqrIEEUAjhPIADXyfuzrvuLlKX4hYGG4t)PaKRGDql75WatlZTXOuqZ0wbvL)wql75Wad8YR4oMMYfKG6uJRIXULpW8TS0w5(brijtydMng7Hmii(0Fka5kyh0YEomW0YCBmavqZ0wbvL)wql75WaB7)dG)M7csqDQXvXy3Yhy(wwARC)GiKKjSbZgJ2Hmii(0Fka5kyh0YEomW0YCBmAh0mTvqv5Vf0YEomWizqcQtnUkg7w(aZ3YsBL7heHKmHny2SbD6)nEZwi9oq5kOt)V7O2pxbBhAqYy8dUJurTDCi9xg8IijjrTsa9MaczqAi655QTJsoXyfKb9CuyGyCfXaubfJrzSRKvqVNVb7KS5adSzKY)oOirppxTaVoJymwbPHONNRwGxNrmgRGWPe7zCamUcyGXv8uXypiC774q6VmijrvcO3eqidcpvrvaGZLlxbHNQOka0HEoqJby1JrjRG0q0ZZvl5ivuRlgRGqFB)SQAaL(Gcsw7ifPd9CGumf6BmkzfKb98M))2y02k45Vlj04k4C5sFWHso05EpPOqfSNYZliJdGbn7l74q6Vmib0BciKbfKS2rksh65iJWkgLSccncl75DCi9xg8IijjrTgeqDgXgpFdQscdmoChmWMrk)7GOqbXMdJWzzppgGbSGo9)gjZvq4PkQc4mzbTSNhKa6nbeYGCQw6qp3fJsbT9cIWat(bvL)wql75WaRkzTJumOtOoNgNXPB7pVmKbNy8d2hJFqfX4hugJF2GIe98C1sNdGbn7lDXyf0P)32gHL9CxUccNQe6Ccf0sWSSpxbhk5qkkub7P88c60)BYrQOwxUccpvrvDhMcEBX3GqbBhA6O2pgRG9hgHe205V7oN0hCoc6dQ)3QAafJFW5iOp2(2(zv1akg)GaV8gQZMRGqJWYEEJNViJWkgF7bNZ9i6u1OMRGAyowp7WwrsrHkyFqOryzpV7WuWdAdKHeebbbWCcNrKuuOcobPHONNRw6CamOzFPlgRGaQZi2XH0FzqsIQ0cQbzWHsoALXRCfeEQIQ64q6Vmib0BciKbHBFJNViJWkgF7bNJG(y7B7NvvJAm(bvLS2rkcdSTryzphg4ok5em4osf1245BqvsyGXH7Gb2ms5Fh0P)3aVoJyqsqaDYGoH6CACgNE6dohb9HCKkQvvdOy8dcO8gQZ2PsBqK1Adgyv5Vf0YEEZcdmGYBOoBq4PkQcaDoag0SV0LRG0eJYaSMlOirppxTW5YfJY4hChPIAB88fxXtfKOwiPLUbuqTo0WAPAHbMK1wXOTvq4PkQcxXtfKa6nbeYGiKKjSbdohb9P7CpIovnQX4heU9nE(IR4PcsulK0s3akOGK1osXgpFrgHvm(2dkilOVTF2ovAdISwBWaRk)TGw2ZBwyGfKf032pBq42345BqvsyGXH7Gb2ms5FhSDOPdumwbjNtXxyGBs(ucXyfChPIAv1ak9bvLS2rkcdSTryzpp4osf16c60)B4uI9moagxHlxbfj655QTJsoXyf0P)3DGYvW5iOpKJurTQAuJXpOSobTbYqcIGGo9)wvJAUc60)B6CamOzFPlxbNJG(G6)TQg1y8doN7r0PQbuUc2Y4Du7hJvqN(FRQbuUcc9T9ZQQrn9bjOo14QySB53mSaMDGs52T0UzQK9G0q0ZZvlCUCX4hSLX7afJ2bBzCKmgRG7ivuBJNViJWkgF7bHNQOQooK(lj655QngGki0iSSN345BqvsyGXH7Gb2ms5FhCOKdkuNdDGhJvqq8P)uaYvqhRv4uDebfJ9G0oU12Z1ush75Xy3YV5S89vs5AhKgIEEUATncl75UySckhUIIuuOco9SdBfd60)B8MTq6Du7NRGWtXGGRYM5Wv8ubNGaQZi245lYiSIX3EqZ0wbvL)wql75WaRkzTJumyZ)FRTNRPKBbixbbuNrSXZxCfpvqIAHKw6gqbHNQOkanE(ImcRy8ThCoc6t35EeDQAafJFqbjRDKI0HEoqJby1JrjRGdLC64q6Vm4frssIALwqnidouYrlC2gu4mILmBc]] )


end
