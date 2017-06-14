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
        if PTR then addAura( 'avengers_protection', 242265, 'duration', 10 ) end
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

        if PTR then
            addGearSet( "soul_of_the_highlord", 151644 )
            addGearSet( "pillars_of_inmost_light", 151812 )
            addGearSet( "scarlet_inquisitors_expurgation", 151813 )
                addAura( "scarlet_inquisitors_expurgation", 248289, "duration", 3600, "max_stack", 30 )
        end

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
            if PTR and set_bonus.tier20_4pc == 1 then applyDebuff( 'target', 'avengers_protection', 10 ) end
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
            if equipped.liadrins_fury_unleashed then gain( 1, 'holy_power' ) end
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
            talent = 'divine_hammer',
            known = function () return talent.divine_hammer.enabled end,
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
                if PTR and set_bonus.tier20_4pc == 1 then applyBuff( 'sacred_judgment', 8 ) end
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


    storeDefault( [[Protection ST]], 'actionLists', 20170613.122258, [[d8J2haGArsTEvkvBIsu2fkTnrX(OeXTrLtRQztX8PKWNOePdR03uuoVi1ojP9kTBK2Vk6Nuc0WuHXrjjpwOHsjudwLmCs0bjHtrjvhduNJsqTqrPLsPSyrSCepKsIEkXYOu9CsnrkbzQIQjly6uDrvQEnLqUm01vKNPOAvusQnJI2UkfFgv9xqMMkLY8OKIrsjQ(ok0Ovy8IKCsuWTOKsxtKO7PsjRKsa)gyuIeUWnVIejVsVsfrjg)183(6pGw1mzQOUCyflMaCm6pGEEj5vSHgC1yvTFap7iL2NZAhg2EkHRyd3q68NdRKIZRiaycagPS6XJMaeGjKpqiYZpCemPzJJLWJAiUnvNxw75veambaJuw94rtacWeYhie55hocM0SXXs4rnetYg9hqxZ5L1pVS6ZRn6pGYQhpAcqaMq(aHip)WrWKMLGXXs4XkkI(dO6Mxv4MxzDN086vUt3edgA2kQlhwXIb(dOvuq41vOlhElGjaX4sQOi5nVNUIsG)aAfgOHpUoGuHcOyfBObxnwv7hWzGNXEmhUIejVsVI)C4ToQxv7nVYD6MyWqZwrD5Wk2WKjlcRirYR0R4aEEdY(uhjKjLUUIn0GRgRQ9d4mWZypMdxHbA4JRdivOakwrrYBEpDfcMmzryL1DsZRxVQZBEL70nXGHMTI6YHvuCds5rILQpVKXJMqfjsELELKjMmz5jlnafjt6nGe2jLwMVgK6SrYKEdirdL6PaphsDwKUjgmyzraWeamszt9uGNdPoBCSeEuBnWvSHgC1yvTFaNbEg7XC4kmqdFCDaPcfqXkksEZ7PRS3GuEKOH0JhnHkR7KMxVEvVTMx5oDtmyOzRirYR0RSr)VbHqkY9O2sGROi5nVNUseq1yKS(dOvSHgC1yvTFaNbEg7XC4kmqdFCDaPcfqXkQlhwXkbungjR)a65vkuybVB9kR7KMxVEvtzZRCNUjgm0SvKi5v6vIaGjayKYQhpAcqaMq(aHip)WrWKMnowcpQVveambaJuw94rtacWeYhie55hocM0SXXs4rne3MQkksEZ7PROhpAcqaMq(aHip)WrWKUcd0WhxhqQqbuSIIWnlnIHMTI6YHvKXJMW5fG55LpWZlBp)WrWKUIn0GRgRQ9d4mWZypMdxXgUH05phwjfNxraWeamsz1JhnbiatiFGqKNF4iysZghlHh1qCBQoVS2ZRiaycagPS6XJMaeGjKpqiYZpCemPzJJLWJAiMKn6pGUMZlRFEz1NxB0FaLvpE0eGamH8bcrE(HJGjnlbJJLWJvKi5v65PvIv8NdRSUtAE96vntZRCNUjgm0SvuxoSIfykWZHuVIejVsVsfBObxnwv7hWzGNXEmhUcd0WhxhqQqbuSIIK38E6kPEkWZHuVY6oP51Rx1znVYD6MyWqZwrIKxPxjGjtmzYMyqTgdqJLJdjSeKBFQ2ASkRWkIaGjayKYMyqTgdqJLJdjSXXs4rTLaxrD5WkznOwJHZllF54qsffeEDLk2qdUASQ2pGZapJ9yoCfgOHpUoGuHcOyffjV590vsmOwJbOXYXHKkR7KMxVEvTQMx5oDtmyOzROUCyfReq1yKS(dOvKi5v6vQydn4QXQA)aod8m2J5WvyGg(46asfkGIvuK8M3txjcOAmsw)b0kR7KMxVEvTWnVYD6MyWqZwrD5WkkUbP8iXs1NxY4rt48kfWwVIejVsVsfBObxnwv7hWzGNXEmhUcd0WhxhqQqbuSIIK38E6k7niLhjAi94rtOY6oP51Rxv4JMx5oDtmyOzROUCyflF54qY5fG55LpWZlBp)WrWKUIejVsVsfBObxnwv7hWzGNXEmhUcd0WhxhqQqbuSIIK38E6kJLJdjqaMq(aHip)WrWKUY6oP51RxVIfczUtgVzR3c]] )

    storeDefault( [[Protection Defensives]], 'actionLists', 20170613.122258, [[daZycaGEQk1MOIyxsITruMjvKMnLUnr1orQ9k2nf7NqJIQIgMu63QAOQugmrgov6GskNIQchtHfQsSusXIrslNKNcTmP45smrQQmvQYKjy6OUOkPNrkDDKyZKQTtvjFMk8njPrsfvNwPrlvxgCsvQomIRrvvNxs1FvXJv0RPIYzeVG0e5qWBQNHjVVruYpqhmL1xqjOFGoHILZLGAalqkqOBAhvB9VrBLMXOX)rq0fMlXU(MW7BcTmzbRn59nL4f6r8csywfVWbXPAD5GmX4S14WjukWP0xWkeKMihcI9fScIsVUOe3brjnRJodpLIOKph(iOgWcKce6M2HSr1kTAhbRrDTlxpyPVGv486hUdh16OZWtPe8UryNe(vbnVbcE1qOAbHCjiovRl7v3fcww5ZWHUjEbVAiuTGqUeeNQ1LdsPaNcy1pDGydstKdbDoXiik96IsCheLUPEgM8RcQbSaPaHUPDiBuTsR2rW7gHDs4xf08giynQRD56b7eJW51pChoUQNHj)QGeMvXlC4qRnEbVAiuTGqUeeNQ1LdsPaNcy1pDGydstKdbD66OZIsVUOe3brPBQNHj)QGAalqkqOBAhYgvR0QDe8UryNe(vbnVbcwJ6AxUEq76OZNx)WD44QEgM8RcsywfVWHdheNQ1Ldgoba]] )

    storeDefault( [[Protection Cooldowns]], 'actionLists', 20170613.122258, [[b4vmErLxtruzMfwDSrNxc51uofwBL51uqj3B0v2y0L2BU5hyd92BSr2B352CEnLuLXwzHnxzE5KmWeZnWuJmZ4ImXeJm1eJxtnfCLnwAHXwA6fgDP9MBE5Kn241ubngDP9MBZ5fvErNxtn1yYLgC051uErNxEb]] )

    storeDefault( [[Protection Default]], 'actionLists', 20170613.122258, [[dWItcaGEvkTlqX2OGMTQUjO0TLs7uQ2Ry3k2VsAysXVjnuLQbRedNICqj0Xq0cLKwQKyXi0YvXdPO6Pqlts9CknrjyQQKjdY0jUic6zQuCDqvBMcTDkWNLiFhbonvFtI6KGkxg11OOCEvQomWFvkpgPdzUc2bTCW9JkmvCDwxkWgbW)sq0etDW73cexN0n0WGv4Nbwo96gYYnMvFdm1KK1MrgePh3KemyrQ46yZv6K5kiHdG4ZqPAWoOLdUFuHPIRZ6sb2ipw3a2gePh3Keu0sLEgg4T8geBKhRBaBdwHFgy50RBilt2eeUbYParpbhD4Gfj6Vl3dsb)VbOIRZ27wjiSkuh0Yb3pQWuX1zDPaBKhRBaBJKEDUcs4ai(muQgSdA5G7hvyQ46SUyUQpKsWydI0JBsckAPspddv1hsjySbRWpdSC61nKLjBcc3a5uGONGJoCWIe93L7bPG)3auX1z7DReewfQdA5G7hvyQ46SUyUQpKsWyJK(n5kiHdG4ZqPAWoOLdUFuHPIRZ6cEfePh3Kemyf(zGLtVUHSmztq4giNce9eC0HdwKO)UCpif8)gGkUoBVBLGWQqDqlhC)OctfxN1f8ksKGfyJa4FjvJKa]] )

    storeDefault( [[SimC Retribution: opener]], 'actionLists', 20170613.122258, [[dGdMfaGAGQSEsuSlsLTbuYSfmFqQBkKBRu7uI9sTBe7xunma9BPEUipwsdwjgos1bfkhwXXeLJduPfsQAPGYIrYYr1dbHNcTmLK1rIstKevnvaMmHPJYfbrFgKCzvxNu2ijQSvqvBMKA7kPonrFfOOMgqH(ojYibk4BcvJgP8xGCsqLNbuX1akY5jjReOuVMeoeqvTZmaJqsgQWfMYyz23ik3qKVa7mUKsJjBIYMV00p5CJWE4t6UScywCGGvg4OlZis)v5eKkZWKnXL4angRYKnjzaUKzagHKmuHlSEJyLlPZmYAOGkCD1UdIwjsYymkzqYuzKk0TaKAnUkJWreY6WAUrstUXOwa)WlZ(gnwM9nQp0TiFr504Qmc7HpP7YkGzXZaAe2tTgV(KbyMriO9QIOE93NWmLXOwuM9nAMlRmaJqsgQWfwVrSYL0zgznuqfUUA3brRejzmgLmizQmsDE6CfscugHJiK1H1CJKMCJrTa(HxM9nASm7Bu)5PZvijqze2dFs3LvaZINb0iSNAnE9jdWmJqq7vfr96VpHzkJrTOm7B0mxahdWiKKHkCH1BmgLmizQmo86qoiwZ5NWmchriRdR5gjn5gJAb8dVm7B0yz23ymEDipFbqZ5NWmc7HpP7YkGzXZaAe2tTgV(KbyMriO9QIOE93NWmLXOwuM9nAMlGrdWiKKHkCH1BmgLmizQmcEAcO2NWmchriRdR5gjn5gJAb8dVm7B0yz23iyRjGAFcZiSh(KUlRaMfpdOryp1A86tgGzgHG2RkI61FFcZugJArz23OzUaMmaJqsgQWfwVrSYL0zgp4QjPt)cDb5i4sscKAnUkqAKWNeTlYxGg68f(uVoQq3cqpOoFbAOZxa)8LA3brRerNsJIdQvdAs0EsNgDJXOKbjtLrQWioOwniWtlXK1BeoIqwhwZnsAYng1c4hEz23OXYSVr9Hr88LwD(cyRLyY6nc7HpP7YkGzXZaAe2tTgV(KbyMriO9QIOE93NWmLXOwuM9nAMlGLbyesYqfUW6nIvUKoZ4bxnjD6xOlihbxssGuRXvbsJe(KODr(c0qNVWN61rf6wa6b15lqdD(c4NVu7oiALi6uAuCqTAqtI2t60OBmgLmizQmkKRLKdI2S3NBeoIqwhwZnsAYng1c4hEz23OXYSVrLxUwsE(cyy27Znc7HpP7YkGzXZaAe2tTgV(KbyMriO9QIOE93NWmLXOwuM9nAMlXnaJqsgQWfwVXyuYGKPYOsJIdQvdAs0EYiCeHSoSMBK0KBmQfWp8YSVrJLzFJG5rXZxA15lXs0EYiSh(KUlRaMfpdOryp1A86tgGzgHG2RkI61FFcZugJArz23OzMzeRCjDMrZSb]] )

    storeDefault( [[SimC Retribution: default]], 'actionLists', 20170613.122258, [[dCZCeaGAjLSEufztOkQDrk2gPuAMqGztY8HOUju52sStuSxLDdSFknkufggk1VfgmvgUQ0brjNcc6yQulusyPKQfdLLtXdvfpLyzssRtL0urvnzv10fDrsjpxfxg56OY3GuTvjfBgcz7OkDyqNhsAAsk18iLIVRs8yQA0qKxlP6KsIEgPuDAPUheQpdj(lu1IGuE3J)eTaqmf9h2egyHMiD5X60P00yCzhGRw3NqeKtLt0jfbp0yQY(gD2A7T21CprEjFdvnpbZoaJbD2ty5ZoaNXFm3J)eTaqmf9xfteVPFZjzGckkstdsYy4EZZewyTQtuNyimU60Kkb)2dZWmbeaAcU4xd0Wal0KjmWcnrNW4Qtt0jfbp0yQY(g9B2t0PtWz80z8xo5bjYxhxWlviqoSj4IpdSqtwoMQJ)eTaqmf9xfteVPFZjzxiRtBSUQwhpBD8W68rO(XfGMAX9rPqGud3R1HmYwNpc1pUa0GPGFcFGi81I7KTN0W9ADiJS15Jq9Jlan)M3gq4rcwkKrd3R1HmYwNpc1pUa0CbwNWhicp8GeD0W9ADiCclSw1jQt8qLcp0NDaWR6to5bjYxhxWlviqoSj4IFnqddSqtMWal0KhOszDS8zhaRdb9jNWYGYzcawieJM0LhRtNstJXLDaUADXlbidAt0jfbp0yQY(g9B2t0PtWz80z8xoPsWV9WmmtabGMGl(mWcnr6YJ1PtPPX4YoaxTU4LaKz5y0(4prlaetr)vXewyTQtuN4HkfEOp7aGx1NCsLGF7HzyMacanbx8RbAyGfAYegyHM8avkRJLp7ayDiOpP1XJBeoHLbLZeaSqignPlpwNoLMgJl7aC168rO(XfWbTj6KIGhAmvzFJ(n7j60j4mE6m(lN8Ge5RJl4Lkeih2eCXNbwOjsxESoDknngx2b4Q15Jq9JlGZYXu7XFIwaiMI(RIjSWAvNOoXdvk8qF2baVQp5Kkb)2dZWmbeaAcU4xd0Wal0KjmWcn5bQuwhlF2bW6qqFsRJhvr4ewguotaWcHy0KU8yD6uAAmUSdWvR710HPturBIoPi4Hgtv23OFZEIoDcoJNoJ)Yjpir(64cEPcbYHnbx8zGfAI0LhRtNstJXLDaUADVMomDI6YLteVPFZjl3aa]] )

    storeDefault( [[SimC Retribution: precombat]], 'actionLists', 20170613.122258, [[d8sobaGErL2LeSnKkZwKBIq3wHDkv7LSBO2VOQHrj)MQHkkAWsOHJKdIuogiluuYsLslgslNIhkr9uvltISorftvkMmOMUWfrGlJ66sQ2QOuBxu45q8yf9ze13LuoSsNNsXOPu1RrQ6Kuk9me0PbUhLklss6VsIVHili1OtaErtmSq177G1pyuoFXwoma06bWX5KViLHN(aDd9woXlcREjlisw0brybi9tXtWMa5UbWXQtYsN2maogrnQdPgDcWlAIHvw6FAauHE4KjN4cuEaCmIonuqce2Ot5bWX6LTNN0t0ZGhmoeQorho7103bRR33bRNPhahRtZqgrhVd2UQEcUsT1uvVLt8IWQxYcIeKLElJ41ntgrnk0TfddMB4gDSJzDIoCFhSUNGRuBnkuO)Pbqf6kKa]] )

    storeDefault( [[SimC Retribution: cooldowns]], 'actionLists', 20170613.122258, [[d0ZPgaGEqvQnPuPDPqBJiW(ic6XIA2KA(Qc3ujDyvUnH(Msv7uvTxPDJ0(fzukvmmq63uDpLidfufnyHgUs5GcQtPe1XuLooOQAHGOLsswmrTCepeu5POwMsyDcs1PPyQe0KP00bUir0Zv0Zic56KyJGQKTss1MfOTRk6Zk4ReHAAccFxaJuqkZtqYObLldDssklcuvUMGOZtK(lboeOk8Aq4(wHLLKEYA0w5Y)telZgr4srviGyKvagNg6Py2DT1dqNLvHA8My)lG(UhQe8krJVL5nmBoTbEFaJt7Fp0YHZaJtNvy)VvyzjPNSgTfYYCMy2aLb(WGgh3CGXPZuC3uCNuCNuuwjyWrzT7wTYemQSLIpEKIYkbdoEpr6GHoiia5aWgv2sXhpsrzLGbhZeL5zXrLTuC3uuwjyWXmrzEwCKGINHotXqLIlczk(4rkcoYacgbgruaWfynykgQLsXqanfxofxUCyzJ2aKwEZbgNwgoyygIv)jkIuqLlV6w1pY)eXYL)NiwgE6aJtlhMmmltprCj4Z1wbboc8vwfQXBI9Va67(xOLvHtxHKXzfwqz1Owt(aoPm1Py5v3(prSSRTccCKc6Frfwws6jRrBHSmNjMnqzGpmOXXS7ARhGolhw2OnaPLL1UBfeuHiTSAuRjFaNuM6uS8QBv)i)telx(FIyzi1UBtr4LcrAzvOgVj2)cOV7FHwwfoDfsgNvybLHdgMHy1FIIifu5YRU9FIy5c6xIQWYsspznAlKL5mXSbkd8HbnoMDxB9a0z5WYgTbiTSmsMibcdDOSAuRjFaNuM6uS8QBv)i)telx(FIyzirYejqyOdLvHA8My)lG(U)fAzv40vizCwHfugoyygIv)jkIuqLlV62)jILlO)quHLLKEYA0wilZzIzdugMRLkyZdGKXScHGuqkgQLsXquoSSrBaslFK8rrbaNqqkOSAuRjFaNuM6uS8QBv)i)telx(FIy5WK8rXuuOtiifuwfQXBI9Va67(xOLvHtxHKXzfwqz4GHziw9NOisbvU8QB)NiwUG(dzfwws6jRrBHSmNjMnqzGpmOXXS7ARhGolhw2OnaPLH5APccqoaSYQrTM8bCszQtXYRUv9J8prSC5)jILdnxlnfLyYbGvwfQXBI9Va67(xOLvHtxHKXzfwqz4GHziw9NOisbvU8QB)NiwUG(LGkSSK0twJ2czzotmBGYaFyqJJz31wpaDwoSSrBaslFpr6GHoiia5aWkRg1AYhWjLPoflV6w1pY)eXYL)Niwo8tKoyOdPOetoaSYQqnEtS)fqF3)cTSkC6kKmoRWckdhmmdXQ)efrkOYLxD7)eXYf0)(kSSK0twJ2czzotmBGYaFyqJJz31wpaDMI7MI7KIWCTubBEaKmMvieKcsrjCPumKP4UPi8ifr4xXSTH2rT5SedDkiOcrQafQgVjm0MIpEKI7KI7KIi8Ry22q7O2CwIHofeuHivGcvJ3egAtXhpsrYLXrzT7wbOoykUCkUBkcZ1sfS5bqYywHqqkifLWLsXfP4YP4YLdlB0gG0YzIY8Syz1Owt(aoPm1Py5v3Q(r(NiwU8)eXYWruMNflRc14nX(xa9D)l0YQWPRqY4SclOmCWWmeR(tuePGkxE1T)telxqbL5mXSbkxqla]] )

    storeDefault( [[SimC Retribution: priority]], 'actionLists', 20170613.122258, [[duKpPaqirvYMefFcvfgfLKtrjAvuszwIQO6wOkq7IKggLYXaQLjsEgLunnuf5AaOTHQI(gLW4evrohQIQ1jQIsZdvLUhaSprvDqrkluuXdfHMOOkCrrQgjQcOtkQ0krvuUjQyNKYsfLEQWuPuTvuL(QOkkwlQcWEH(lPAWioSulMepMktMIlRSza9zr0OrLonHvlcEnqA2Q42sA3e9BugUeooQcA5Q65u10bDDvA7s03bOXlQsDEGy9Ok08rv1(rAemAhJ0LTYzgubdTUomcrnrkj7GVq5cfmzEwkP4fSxabbJS7S2pulLnWwyJpbBDvWyefZj6JGhBOGjrnlSHrAoOGj9ODudmAhJ0LTYzgmhmc3lkGy0oOOC6tUQyEkHVaGsSoLKHsSIsCm2XWauQMW1KSoju9xTfspLWxkjPZqjwJs4jvasj8ZpLyMYfiq1eUMK1jHQ)QTq6PK8PKKodLynkHNubiLyjgPPiociiyS8EUluWK6(jHt6gg5kncxdzpgsMCyWHz4TFTUomWqRRdJ0Z75UqbtsjXKWjDdJS7S2pulLnWwa2ggzNNDF38ODeIrICNduoSYvNeIkyWHz066WaHOwk0ogPlBLZmyoyeUxuaXODqr50NCvX8us(aGssrj8ZpLyfLOCbcu176)mOUqYdVcVaYEV(Y7I7NSHcMu1dBhOus(aGssXZPKmuIvuIYfiq1UCYKczsDa)gYv9wqj8ZpLyfLOCbcu19xFBM6TGsYqjkxGavD)13MP6HTdukjFaqjGbiLyjLWp)uIvuIJXoggGsv3F9TzQ)QTq6PK8PeWaKsYqj5fLOCbcu19xFBM6TGsSKs4NFkXXyhddqPAxozsHmPoGFd5Q(R2cPNsYNsadqkXskXsmstrCeqqWOSFrRCggjYDoq5WkxDsiQGbhMH3(166WW41DTh2kNHHwxhgbK9Js4Tp3HrAFspgYUoay86U2dBLZYZl7ZDaODqr50NCvX85dGu8ZVvkxGav9U(pdQlK8WRWlGS3RV8U4(jBOGjv9W2bA(aifppJvkxGav7YjtkKj1b8Bix1Bb)8BLYfiqv3F9TzQ3ImkxGavD)13MP6HTd08bayaAj)8BLJXoggGsv3F9TzQ)QTq6ZhmaZKxkxGavD)13MPElSKF(Dm2XWauQ2LtMuitQd43qUQ)QTq6ZhmaT0smYUZA)qTu2aBbyByKDE29DZJ2rig5kncxdzpgsMCyWHz066WaHOM1r7yKUSvoZG5Gr4ErbeJ8IsG9zsOQ7V(2m1jBLZmuc)8tjog7yyakvD)13MP(R2cPNsYNss6muI1OeRJrAkIJaccgL9lALZWirUZbkhw5Qtcrfm4Wm82VwxhgU)6BZWqRRdJaY(rj82N7OeRaBjgP9j9yi76aG7V(2S88Y(ChaYlyFMeQ6(RVntDYw5md)87ySJHbOu19xFBM6VAlK(8t6mwZ6yKDN1(HAPSb2cW2Wi78S77MhTJqmYvAeUgYEmKm5WGdZO11HbcrnEcTJr6Yw5mdMdgH7ffqms4AswNeQZk3)cZOKmusz)Iw5mvJx31EyRCgLKHsuUabQAeLc50lUFbZp1BbLKHsuUabQAeLc50lUFbZp1F1wi9ucFPKKodLynkjfgPPiociiyyeLc509q2xXixPr4Ai7XqYKddomdV9R11HbgADDyKhIsHCusazFfJS7S2pulLnWwa2ggzNNDF38ODeIrICNduoSYvNeIkyWHz066WaHOgar7yKUSvoZG5Gr4ErbeJeUMK1jH6SY9VWmkjdLu2VOvot141DTh2kNrjzOeUSdi6fma3R6U)pjKsYhaucaPKmuIYfiqvJOuiNEX9ly(PElWinfXrabbdJOuiNUhY(kg5kncxdzpgsMCyWHz4TFTUomWqRRdJ8qukKJsci7RuIvGTeJS7S2pulLnWwa2ggzNNDF38ODeIrICNduoSYvNeIkyWHz066WaHOgFI2XiDzRCMbZbJW9IcigjCnjRtc1zL7FHzusgkPDqr50NCvX8us(aGssrjzOeUSdi6fma3R6U)pjKsYhauI1PKmuIvuIYfiqv3F9TzQ3ckjdLOCbcu19xFBMQh2oqPe(sjGbiLWp)uIYfiq1JOnVq61bEFq0VYZAp3zuVfuILyKMI4iGGGHrukKt3dzFfJCLgHRHShdjtom4Wm82VwxhgyO11HrEikfYrjbK9vkXQuwIr2Dw7hQLYgylaBdJSZZUVBE0ocXirUZbkhw5Qtcrfm4WmADDyGquZc0ogPlBLZmyoyeUxuaXiHRjzDsOoRC)lmJsYqjL9lALZunEDx7HTYzusgkHl7aIEbdW9QU7)tcPK8baLaqkjdLu2VOvot19xFBggPPiociiyyeLc509q2xXixPr4Ai7XqYKddomdV9R11HbgADDyKhIsHCusazFLsSY6wIr2Dw7hQLYgylaBdJSZZUVBE0ocXirUZbkhw5Qtcrfm4WmADDyGqulpH2XiDzRCMbZbJW9IcigjCnjRtc1zL7FHzusgkr5ceOQrukKtV4(fm)uVfusgkr5ceOQrukKtV4(fm)u)vBH0tj8Lss6muI1OKuusgkjVOKXdVIIIzubKRWxSxNbuhYD6YgY9hpkQyKMI4iGGGrcxpu463RxozY1s3WixPr4Ai7XqYKddomdV9R11HbgADDyWZUEOW1pF4PeENm5APByKDN1(HAPSb2cW2Wi78S77MhTJqmsK7CGYHvU6KqubdomJwxhgie145ODmsx2kNzWCWiCVOaIrcxtY6KqDw5(xygLKHs4YoGOxWaCVQ7()KqkjFaqjaKsYqjkxGavnIsHC6f3VG5N6TGsYqj5fLmE4vuumJkGCf(I96mG6qUtx2qU)4rrfJ0uehbeems46Hcx)E9YjtUw6gg5kncxdzpgsMCyWHz4TFTUomWqRRddE21dfU(5dpLW7KjxlDJsScSLyKDN1(HAPSb2cW2Wi78S77MhTJqmsK7CGYHvU6KqubdomJwxhgie1aBdTJr6Yw5mdMdgH7ffqms4AswNeQZk3)cZOKmuIYfiqvJOuiNEX9ly(PElOKmuIYfiqvJOuiNEX9ly(P(R2cPNs4lLK0zOeRrjPWinfXrabbd4QfN(96L7ncheJCLgHRHShdjtom4Wm82VwxhgyO11HH9vlo9ZhEkH39gHdIr2Dw7hQLYgylaBdJSZZUVBE0ocXirUZbkhw5Qtcrfm4WmADDyGqudmy0ogPlBLZmyoyeUxuaXiHRjzDsOoRC)lmJsYqjCzhq0lyaUx1D)FsiLKpaOeasjzOeLlqGQgrPqo9I7xW8t9wGrAkIJaccgWvlo971l3Beoig5kncxdzpgsMCyWHz4TFTUomWqRRdd7RwC6Np8ucV7nchKsScSLyKDN1(HAPSb2cW2Wi78S77MhTJqmsK7CGYHvU6KqubdomJwxhgie1aNcTJr6Yw5mdMdgH7ffqms4AswNeQZk3)cZOKmucx2be9cgG7vD3)Nesj5dakX6usgkXkkr5ceOQ7V(2m1BbLKHsuUabQ6(RVnt1dBhOucFPeWaKs4NFkr5ceO6r0Mxi96aVpi6x5zTN7mQ3ckXsmstrCeqqWaUAXPFVE5EJWbXixPr4Ai7XqYKddomdV9R11HbgADDyyF1It)8HNs4DVr4GuIvPSeJS7S2pulLnWwa2ggzNNDF38ODeIrICNduoSYvNeIkyWHz066WaHOgyRJ2XiDzRCMbZbJW9IcigjCnjRtc1zL7FHzusgkHl7aIEbdW9QU7)tcPK8baLaqkjdLu2VOvot19xFBggPPiociiyaxT40VxVCVr4GyKR0iCnK9yizYHbhMH3(166WadTUomSVAXPF(Wtj8U3iCqkXkRBjgz3zTFOwkBGTaSnmYop7(U5r7ieJe5ohOCyLRojevWGdZO11HbcrnW8eAhJ0LTYzgmhmc3lkGyKW1KSojuNvU)fMrjzOKY(fTYzQgVUR9Ww5mkjdL0puaSDqvaBqNodOE75oV6KTYzgkjdL4ySJHbOufWg0PZaQ3EUZR(R2cPNs4lLK0zOeRrjPOKmusz)Iw5mv3F9TzyKMI4iGGGHrukKt3dzFfJCLgHRHShdjtom4Wm82VwxhgyO11HrEikfYrjbK9vkXkEYsmYUZA)qTu2aBbyByKDE29DZJ2rigjYDoq5WkxDsiQGbhMrRRddeIAGbiAhJ0LTYzgmhmc3lkGyKW1KSojuNvU)fMrjzOKY(fTYzQgVUR9Ww5mkjdLOCbcufqUcFXEDgqDi3PlBi3F8OOQElOKmuIYfiqva5k8f71za1HCNUSHC)XJIQ6VAlKEkHVussNHsSgLawfGusgkPSFrRCMQ7V(2mmstrCeqqWWikfYP7HSVIrUsJW1q2JHKjhgCygE7xRRddm066WipeLc5OKaY(kLyfaTeJS7S2pulLnWwa2ggzNNDF38ODeIrICNduoSYvNeIkyWHz066WaHOgy(eTJr6Yw5mdMdgH7ffqmSIsgp8kkkMrfqUcFXEDgqDi3PlBi3F8OOsj8ZpLKW1KSojuNvU)fMrjwsjzOK(HcGTdQcyd60za1Bp35vNSvoZqjzOehJDmmaLQa2GoDgq92ZDE1F1wi9ucFPKKodLynkjfLKHsk7x0kNP6(RVndJ0uehbeemGRwC63RxU3iCqmYvAeUgYEmKm5WGdZWB)ADDyGHwxhg2xT40pF4PeE3BeoiLyfpzjgz3zTFOwkBGTaSnmYop7(U5r7ieJe5ohOCyLRojevWGdZO11HbcrnWwG2XiDzRCMbZbJW9IcigjCnjRtc1zL7FHzusgkr5ceOkGCf(I96mG6qUtx2qU)4rrv9wqjzOeLlqGQaYv4l2RZaQd5oDzd5(Jhfv1F1wi9ucFPKKodLynkbSkaPKmusz)Iw5mv3F9TzyKMI4iGGGbC1It)E9Y9gHdIrUsJW1q2JHKjhgCygE7xRRddm066WW(QfN(5dpLW7EJWbPeRaOLyKDN1(HAPSb2cW2Wi78S77MhTJqmsK7CGYHvU6KqubdomJwxhgie1aNNq7yKUSvoZG5Gr4ErbedddQU8EUluWK6(jHt6Mku4avitsjzOeddQU8EUluWK6(jHt6M6VAlKEkHVussNHsSgLKIsYqjMPCbcunHRjzDsO6VAlKEkHVussNHsSgLKcJ0uehbeems4AswNeIrUsJW1q2JHKjhgCygE7xRRddm066WGNDnjRtcXi7oR9d1szdSfGTHr25z33npAhHyKi35aLdRC1jHOcgCygTUomqiQbMNJ2XiDzRCMbZbJW9Icigwrjog7yyakvvoTz6mG6jC9qHBQ)QTq6PK8PKKodLynkjfLWp)uIJXoggGsvJOuiNo3Uw3R(R2cPNsYNss6muI1OKuuILyKMI4iGGGHJj9Z9nuWKyKR0iCnK9yizYHbhMH3(166WadTUomsKj9Z9nuWKyKDN1(HAPSb2cW2Wi78S77MhTJqmsK7CGYHvU6KqubdomJwxhgie1szdTJr6Yw5mdMdgH7ffqmSIs4YoGOxWaCVQ7()KqkHVaGsSrj8ZpLWLDarVGb4Ev39)jHucaOeWusgkXkkXXyhddqPQYPntNbupHRhkCt9xTfspLKpLK0zOe(5NsCm2XWauQAeLc505216E1F1wi9us(ussNHsSKs4NFkHl7aIEbdW9QU7)tcPeaqjPOKmuIvuIvuIJXoggGsvEC9r1XT)KZRd8BhuWK9Hs4laOeBQ8jaPe(5NsCm2XWauQ6(RVn719Wxa6uDC7p586a)2bfmzFOe(cakXMkFcqkXskXskXsmstrCeqqWaWg0PZaQ3EUZJrUsJW1q2JHKjhgCygE7xRRddm066Wiptd6Oegqkjnp35Xi7oR9d1szdSfGTHr25z33npAhHyKi35aLdRC1jHOcgCygTUomqiQLcmAhJ0LTYzgmhmc3lkGyWLDarVGb4Ev39)jHucFbaLyDkHhKs8dQRWKxVkuSpLn9ufomstrCeqqWq50MPZaQNW1dfUHrUsJW1q2JHKjhgCygE7xRRddm066WiNtBgLWasj8SRhkCdJS7S2pulLnWwa2ggzNNDF38ODeIrICNduoSYvNeIkyWHz066WaHOwQuODmsx2kNzWCWiCVOaIbx2be9cgG7vD3)Nesj8fauI1PeEqkXpOUctE9QqX(u20tv4WinfXrabbdJOuiNo3Uw3JrUsJW1q2JHKjhgCygE7xRRddm066WipeLc5OeEGDTUhJS7S2pulLnWwa2ggzNNDF38ODeIrICNduoSYvNeIkyWHz066WaHOwkRJ2XiDzRCMbZbJW9IcigJhEfffZOMW1dfUPNS5XrjzOey)jhuL76dKRAHdsj5dakXcasjzOeUSdi6fma3R6U)pjKs4laOeEcJ0uehbeem4216EDgq9eUEOWnmYvAeUgYEmKm5WGdZWB)ADDyGHwxhg8a7ADpLWasj8SRhkCdJS7S2pulLnWwa2ggzNNDF38ODeIrICNduoSYvNeIkyWHz066WaHOwkEcTJr6Yw5mdMdgPPiociiyKW1KSojeJCLgHRHShdjtom4Wm82VwxhgyO11Hbp7AswNesjwb2smYUZA)qTu2aBbyByKDE29DZJ2rigjYDoq5WkxDsiQGbhMrRRddeIAPaiAhJ0LTYzgmhmc3lkGy4ySJHbOuLhxFuDC7p586a)2bfmzFOK8baLawLpbiLKHs4YoGOxWaCVQ7()KqkHVaGs4jkjdLyfL4ySJHbOuv50MPZaQNW1dfUP(R2cPNsYNss6muI1OKuuc)8tjog7yyakvnIsHC6C7ADV6VAlKEkjFkjPZqjwJssrjwsjzOeZuUabQMW1KSoju9xTfspLKpLK0zWinfXrabbdEC9bJCLgHRHShdjtom4Wm82VwxhgyO11HbpG1hmYUZA)qTu2aBbyByKDE29DZJ2rigjYDoq5WkxDsiQGbhMrRRddeIAP4t0ogPlBLZmyoyeUxuaXWXyhddqPQ7V(2Sx3dFbOt1XT)KZRd8BhuWK9HsYhaucyv(eGucpiLa7ZKqvi3Pdu8ZRZaQNW1dfUPk0NSvoZqjwJsSPMcGusgkHl7aIEbdW9QU7)tcPe(cakHNOKmuIvuIJXoggGsvLtBModOEcxpu4M6VAlKEkjFkjPZqjwJssrj8ZpL4ySJHbOu1ikfYPZTR19Q)QTq6PK8PKKodLynkjfLyjLKHsmt5ceOAcxtY6Kq1F1wi9us(ussNbJ0uehbeemC)13M96E4laDyKR0iCnK9yizYHbhMH3(166WadTUoms8V(2SNsc4laDyKDN1(HAPSb2cW2Wi78S77MhTJqmsK7CGYHvU6KqubdomJwxhgie1szbAhJ0LTYzgmhmstrCeqqWWXK(5(gkysmYvAeUgYEmKm5WGdZWB)ADDyGHwxhgjYK(5(gkyskXkWwIr2Dw7hQLYgylaBdJSZZUVBE0ocXirUZbkhw5Qtcrfm4WmADDyGqulvEcTJr6Yw5mdMdgH7ffqms4AswNeQZk3)cZOKmusz)Iw5mvJx31EyRCgLKHsuUabQAeLc50lUFbZp1BbgPPiociiyyeLc509q2xXixPr4Ai7XqYKddomdV9R11HbgADDyKhIsHCusazFLsSIpTeJS7S2pulLnWwa2ggzNNDF38ODeIrICNduoSYvNeIkyWHz066WaHOwkEoAhJ0LTYzgmhmc3lkGyKW1KSojuNvU)fMrjzOKY(fTYzQgVUR9Ww5mkjdLOCbcufYD6af)86mG6jC9qHBQ3ckjdLu2VOvot19xFBggPPiociiyyeLc509q2xXixPr4Ai7XqYKddomdV9R11HbgADDyKhIsHCusazFLsSYclXi7oR9d1szdSfGTHr25z33npAhHyKi35aLdRC1jHOcgCygTUomqiQzDBODmsx2kNzWCWiCVOaIrcxtY6KqDw5(xygLKHsk7x0kNPA86U2dBLZOKmusz)Iw5mv3F9TzyKMI4iGGGHrukKt3dzFfJCLgHRHShdjtom4Wm82VwxhgyO11HrEikfYrjbK9vkXQ8KLyKDN1(HAPSb2cW2Wi78S77MhTJqmsK7CGYHvU6KqubdomJwxhgie1Soy0ogPlBLZmyoyeUxuaXiHRjzDsOoRC)lmJsYqjkxGavnIsHC6f3VG5N6TGsYqj5fLmE4vuumJkGCf(I96mG6qUtx2qU)4rrfJ0uehbeems46Hcx)E9YjtUw6gg5kncxdzpgsMCyWHz4TFTUomWqRRddE21dfU(5dpLW7KjxlDJsSkLLyKDN1(HAPSb2cW2Wi78S77MhTJqmsK7CGYHvU6KqubdomJwxhgie1SEk0ogPlBLZmyoyeUxuaXiHRjzDsOoRC)lmJsYqjkxGavnIsHC6f3VG5N6TaJ0uehbeemGRwC63RxU3iCqmYvAeUgYEmKm5WGdZWB)ADDyGHwxhg2xT40pF4PeE3BeoiLyfFAjgz3zTFOwkBGTaSnmYop7(U5r7ieJe5ohOCyLRojevWGdZO11HbcrnRBD0ogPlBLZmyoyeUxuaXiHRjzDsOoRC)lmJsYqjkxGavHCNoqXpVodOEcxpu4M6TGsYqjL9lALZuD)13MHrAkIJaccgWvlo971l3Beoig5kncxdzpgsMCyWHz4TFTUomWqRRdd7RwC6Np8ucV7nchKsSYclXi7oR9d1szdSfGTHr25z33npAhHyKi35aLdRC1jHOcgCygTUomqiQzDEcTJr6Yw5mdMdgH7ffqms4AswNeQZk3)cZOKmusz)Iw5mv3F9TzusgkXkkjVOeyFMeQU8EUluWK6(jHt6M6KTYzgkHF(PehJDmmaLQlVN7cfmPUFs4KUP(R2cPNsYNss6muI1OKuuILyKMI4iGGGbC1It)E9Y9gHdIrUsJW1q2JHKjhgCygE7xRRddm066WW(QfN(5dpLW7EJWbPeRYtwIr2Dw7hQLYgylaBdJSZZUVBE0ocXirUZbkhw5Qtcrfm4WmADDyGquZ6aeTJr6Yw5mdMdgH7ffqm4YoGOxWaCVQ7()KqkHVaGs4jmstrCeqqWGhxFWixPr4Ai7XqYKddomdV9R11HbgADDyWdy9HsScSLyKDN1(HAPSb2cW2Wi78S77MhTJqmsK7CGYHvU6KqubdomJwxhgie1SoFI2XiDzRCMbZbJW9IcigCzhq0lyaUx1D)FsiLWxaqj8egPPiociiy4(RVn719Wxa6WixPr4Ai7XqYKddomdV9R11HbgADDyK4F9TzpLeWxa6OeRaBjgz3zTFOwkBGTaSnmYop7(U5r7ieJe5ohOCyLRojevWGdZO11HbcrigH7ffqmqiIa]] )


    storeDefault( [[Retribution Primary]], 'displays', 20170613.122258, [[dWZpiaGEvvEPQQSlPc1RvQQzsrmBLCyj3uvvDzvUnjTmkQDsP9k2nH9Rk(jImmP43qopPAOe1GvLgosDqPQJsKsogfoofPfkLwQsLfJslhvpKeEk4XOyDePAIkvXurYKjIPR4IQkxLuINPuLUocBuQ0wjsP2mvA7KOpkv0PHAAsf8DLYijLQVrkLrtfJNi5KKIBjvixJus3Jif9ze1AjsHNtvhJqfGPOhms0fjgy0xxasAHYen2VatXjFJSs5WgGxcYNcNJz)0gWuIJ46xyYc1tmbycOtY11FJIIEWiHp2MasrY11FJIIEWiHp2MaMsCeNenmibG)DX2HMaEh0wpbV0iCrHnGPehXjrrrpyKWN2a6KCD93qvCY34JTjG0I4ioFOI1iub(ef76KK2a9mdgjEEnb7NynhWwQxaaRQ45D3nCmlXGrcP)8sZpgKkBnb2DRR8xSMBm0wJrttaGHJPNadw9KMnzI1COc8jk21jjTb6zgms88Ac2pXAeWwQxaaRQ45D3nCmlXGrcP)8k5ClI1ey3TUYFXAUXqBngnnzYeW7G2Gn8W40)L2aEh0wpXGsBaVdAd2WdJtpXGsBGP4KVPxW4G4bAjrrr6)DA6u7ub0JTJm3HMasfBtaVdAJQ4KVXN2a7Z2lyCq8auKK3PPtTtfGbPYwJSYVWgGPOhms0lyCq8aTKOOi9FafiA9NxkuazoAoMbJepVYCSAX1d4DqBavAdykXrC7bZpMbJeb2PPtTtfqqOQHbj8X2HaE6BT6UkVJc0cXdvGkwJaSXAeGCSgb4XAKjG3bTPOOhms4tBaPi566VPNGxX2eOi4fLo9fGLW1nGuKCD93OribZudI7JTjGAjvpXGITjqTODQ(1wP7Lv(fRrGAr7uGdAtw5xSgbQfTtPaPYwJSYVyncSNZTiwtAdyl1lWUB4ywIbJepVYCSAX1duRTs3lRuoTbuI9yw8cp6u60xa2amf9GrI(fMSiGIpl13UasWE6vPtPtFbQaa9XGRf(xnyKiwT1eGxcYhLo9fOyXl8OhOi41)yXL2a6KCD93OribZudI7JTjW(SDrIbW)Uynmhyko5B6IetazQNxOe(NxBX5OTaYCSAX1FEvu0dgjEE7j4vGaygKqAGqQXAO1a8BfqXNL6Bxap9TwDxL3jSbQfTtrvCY3iR8lwJa)D6SyHeSG8Zlm6RlwZbmL4iojAesWm1G4(0gaZGeaDXGfKJvRbKIKRR)gQIt(gFSnbMIt(MUiXaJ(6cqsluMOX(f4)skSkH6Zlfw9IDVnbulPaQyncamCm9eiqTODQ(1wP7LvkhRrGIGxAeUikD6lalHRBaAowT46DrIbW)UynmhGMFmiv2A6LnjaGvv88U7goMLyWiH0FEP5hdsLTMa0CSAX11WGea(3fBhAcOws1)fBtaQADI55TtoIGowJatXjFJSYVWgqMJvlU(ZRIIEWirGP4KVXhy3TUYFXAUXqBnA18E7yZggM1QraSqcMPgeVxW4G4b2PPtTtfqfl6jguSnbyk6bJeDrIbW)UynmhOw0oLcKkBnYkLJ1iqTODkWbTjRuowJaEh0MgHemtniUpTbQfTtrvCY3iRuowJa1AR09Yk)sBaVdAR)lTb8oOnzLFPnadsLTgzLYHnW(SDrIjGm1Zluc)ZRT4C0waDsUU(B(R1hBhzeyF2UiXaJ(6cqsluMOX(fqflaQyBcmfN8nDrIbW)UynmhW7G2KvkN2amf9GrIUiXeqM65fkH)51wCoAlqrWlG(wln7j2MaFIIDDssBapwLED9K(I1CaDsUU(B6j4vSnb8oOT)oDwSqcwq2N2asrY11FZFT(yncWUW)(15cTf2aQyr)xS7nGlsmb654A98AlohTfqY5weRPx2KaawvXZ7UB4ywIbJes)5vY5weRjWcTDCMYF)16dBGIGx9cghepqljkks)BYxxQaMsCeNKUiXa4FxSgMdWUW)(15cT1VwHnGPehXj5VwFAdykbMzFPn2dJ(6cubkcEPfbEcqVk9JNjb]] )

    storeDefault( [[Retribution AOE]], 'displays', 20170613.122258, [[d8doiaqyjRxvPxIs0UuvWRvv0TPuZuk4zOQy2s15PIBIs40i(Msu8yuzNuSxXUjSFLQFcKHPQ63GoeQQOHsjdwPmCK6GsPJIQs1XiY5qvjwOQ0sLIwmswojpKO6PqldL65u1evvOPIIjJQmDfxuvCvuv1Lv56a2OsyRkrPntL2or5Jkr(mqnnLO67kPrskP1rkXOjvJhL0jjf3cvv6AsHUhQQWMqvjTwuvkhNuQJuycYv0dbkwafdoo9lii(Z0GgZtWPuGVXsMvOcQkb4tU(X9zEdQnWbCTDcyH9jMGCbDa566VrErpeOWhZFqwb566VrErpeOWhZFqAfXUuoA4GcK89Iz5)bTjI2Ny4tqTboGJN8IEiqHpVbDa566VHPuGVXhZFq(oWbC(WeJuyc(ikQ(XlVbB5gcuSV1aXpXWoOPSVGiXw((wZBuekGHafAzFJwDCqBQAc286x5Vyy)l1OK0hyZwkiYPi0tWHyF8J)mXWombFefv)4L3GTCdbk23AG4NyKcAk7lisSLVV18gfHcyiqHw234DUfqFc286x5Vyy)l1OK0hyZwktMGED4kUsgo92NqfKvqUU(Bykf4B8X8h0RdxXvYWP3cmW8gCkf4BAfC6qvWxqmmGyrtnlPvMGoXWVs8LgdYAm)b96WvMsb(gFEd(jvRGthQcYaYQPML0ktqoOnvnwYEcvqUIEiqrRGthQc(cIHbelckhs7SVXad28gfHcyiqX(wlONGED4kYK3GAdCa3hjQJBiqrWMAwsRmbfa2A4GcFmlpON(69f9YRlh2HQWeSIrkOkgPGGJrkivmszc61HRYl6Haf(8gKvqUU(BAbuvm)blavX4qFbPaCDdAxS2cmWy(dwDA9QTVwoElzpXifS606fQdxTK9eJuWQtRxYH2u1yj7jgPGMY(c28gfHcyiqX(wlONGAdq4(CzjECC6xqQGvFTC8wYSYBqzepHI0jJdJd9fKkixrpeOOTtalck)XW80mipINUxomo0xqUGF8ClG(K3GQsa(yCOVGffPtgNGfGQybrC5nisFCKQt(wdbkIzz(d(j1cOyqY3lgj2bzfKRR)gncEeUAGkFm)bTue7s5SVjVOhcuSV1cOQGb90xVVOxE9qfuD9GYFmmpndoLc8nlGIjOfZ(gwc)(MPuk4AWQtRxmLc8nwYEIrkiHdk4BqODmsnguBGd44PrWJWvdu5ZBqwEouebpIa8(goo9lg2bDHIjyRIu99ntPuW1GtPaFZcOyWXPFbbXFMg0yEcYIIvInG9(gdX(IHp)bjCqbsxCeb4yAmiYPi0tqpraUF8v(zbmWGvNwVA7RLJ3sMvmsblavPr4czCOVGuaUUbPve7s5SakgK89IrIDqA1XbTPQP1QHGiXw((wZBuekGHafAzFJwDCqBQAcAxSImX8h0UyT9jM)Gmv)eZ(2skiaDm)bNsb(glzpHkyZRFL)IH9V0Y83iB(8b2ssSBukOLIyxkN9n5f9qGIGtPaFJpy1P1lMsb(glzwXifKi4r4QbQAfC6qvWMAwsRmb5k6HaflGIbjFVyKyhuBGd44PHdkqY3lML)hS606LCOnvnwYSIrkOxhUQrWJWvdu5ZBWQtRxOoC1sMvmsbR(A54TK9K3GED4QLSN8g0RdxBFcvqoOnvnwYScvWpPwaftqlM9nSe(9ntPuW1GoGCD93WYxFm8RuWpPwafdoo9lii(Z0GgZtqBIazIHpbNsb(MfqXGKVxmsSd61HRwYSYBqUIEiqXcOycAXSVHLWVVzkLcUgSaufsF9UMpgZFWhrr1pE5nONyt3VwqpXWoOdixx)nTaQkM)GScY11FdlF9Xif0Rdxz55qre8icW(8g0RdxBbgyOcs1jF)UuhUgQGED4AlGQ0iCHHkiVZTa6tRvdbrIT89TM3Oiuadbk0Y(gVZTa6tqQo573L6W12Epublav1k40HQGVGyyaXIgEwWeuBGd44TakgK89IrIDqhqUU(B0i4r4QbQ8X8huBGd44XYxFEdAteTadmg(eSauf)fKjiDVCovMea]] )

    storeDefault( [[Protection Primary]], 'displays', 20170613.122258, [[dStBiaGEiLxQuv7IKKTHsLzssmBLCtivDyjFdLQ41kvzNKAVu7gv7hs(jsmmr53QAzcvdffdgIgosDqP0rrPkDmsCCHslukwksQflslNOhkv8uWJHYZfmrivMkunzcz6kUieUQsLCzvUobBuQ0wvQu2SOA7eQpQuXZekMgsIVRugjjPonIrlIXJs5KKu3cLQ6AijDEH8zuYAvQuDBPQTIXnGv0d55DF(at06mqzx4QOwJWWusw3WiMXPgKfN11j5W2ZngIv4eU2fHfV)4JbmdruYZd30POhYZdwNzGnk55HB6u0d55bRZmeRWjCIuJ9CGG2znvYmes(TwbzPMN)o1qScNWjQtrpKNhCJHik55HBWljRBcwNzG9kCcxW4wRyCdi4v66e5gdTyd55OqQcjmwtfd6Q)mWi)5WgYZrHeDx(XdeXxWa136QWzD8mf2PKLfJQumaysc9yWJ1XnUbe8kDDICJHwSH8CuivHegRPQbD1FgyK)Cyd55Oq25)LOFJhmq9TUkCwhptHDkzzXOkfdaMKqpg8yDmg3acELUorUXql2qEokKQqcJ1Xyqx9Nbg5ph2qEokKaUbQV1vHZ64zkStjllgvPyaWKe6XGhpgcj)gSrgSKweUXqi53AfM3ngcj)gSrgSKwH5DJHPKSUPLJL8sdnuWXPGEQvVJQXnezn7hNkzgyZ6mdHKFdVKSUj4gd7L2YXsEPbCkmuREhvJBa77tRHrmcNAaROhYZB5yjV0qdfCCkO3qNNocfs83aJ8NdBiphfsgjPVKrgcj)gG7gdXkCch6iYdBip3a1Q3r14g4c9QXEEWAQyiqFRv3vfs68RxACdL1kgsTwXalRvmiTwXJHqYV1POhYZdUXaBuYZd30kilRZmucYcpI(mKkKNBGnk55HBuZfrWQ5LbRZm0xS1kmV1zgQfDs1U2QOaJyewRyOw0jfK8BmIryTIHArNuD((0AyeJWAfdO7YlH14gd6Q)mWi)5WgYZrHKrs6lzKHATvrbgXmUXGysGKswKjcpI(mKAaROhYZBxewCdDqOXrqTbrKa9QIWJOpdLbG(Wi1IGwnKNBn7yNbzXzD4r0NHkLSitKHsqwONWp3yiIsEE4g1CreSAEzW6md7L295dqq7SwjUHPKSUP7Zhdm4OqcfpGcPUKYFZaJK0xYiui7u0d55Oq2kildgiypF3)V3AfQAqEldDqOXrqTHa9TwDxviXPgQfDsHxsw3WigH1kg2)IsjCreoluiHjADwh3qScNWjsnxebRMxgCJbc2Zb6cJWzznvnWgL88Wn4LK1nbRZmmLK1nDF(at06mqzx4QOwJWa6l2i9c9OqIt6pRJjZqFXgGBTIbatsOhdgQfDs1U2QOaJygRvmucYsnp)XJOpdPc55gOLK(sg195dqq7SwjUbA5H99P10YOI1zgOLK(sgPg75abTZAQKzOVyRfH1zgWR1Xhui3r(c0wNzykjRByeJWPgyKK(sgHczNIEip3Wusw3emes(T9VOucxeHZk4gdeUicwnVSLJL8sduREhvJBOw0jfEjzDdJygRvm0t4TcZBDMHArNuD((0AyeZyTIHArNuqYVXiMXAfdHKFtnxebRMxgCJbSIEipV7ZhGG2zTsCd1ARIcmIr4gdHKFRfHBmes(ngXiCJbSVpTggXmo1WEPDF(yGbhfsO4bui1Lu(BgIOKNhUz)MG1SVIH9s7(8bMO1zGYUWvrTgHHEchWToZWusw3095dqq7SwjUHqYVXiMXngWk6H88UpFmWGJcju8akK6sk)ndLGSa6BTuJoRZmGGxPRtKBmei90RRLccRJBiIsEE4MwbzzDMbQV1vHZ64zkSNmQgpgvfxrjovvmWgL88Wn73eSwXq6IGgA7S(nNAONWBryDmgYF(yOvsQfkK6sk)ndIU8synTmQyGr(ZHnKNJcj6U8syngw)2jXQWTFtWPgkbz1YXsEPHgk44uqVki6IBiwHt4e195dqq7SwjUH0fbn02z9BTRLtneRWjCI2Vj4gdXkqW2B3ibyIwNHYqjiRDXjJb6vfDsp2a]] )


end
