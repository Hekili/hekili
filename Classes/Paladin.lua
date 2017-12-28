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
        addResource( 'mana', SPELL_POWER_MANA )
        addResource( 'holy_power', SPELL_POWER_HOLY_POWER, true )

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
        addAura( 'avengers_protection', 242265, 'duration', 10 )
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
        addAura( 'crusade', 231895, 'max_stack', 15 )
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
            addAura( 'sacred_judgment', 246973, 'duration', 8 )

        addGearSet( 'tier21', 152151, 152153, 152149, 152148, 152150, 152152 )
            addAura( 'hidden_retribution_t21_4p', 253806, 'duration', 15 )

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

        addGearSet( "soul_of_the_highlord", 151644 )
        addGearSet( "pillars_of_inmost_light", 151812 )
        addGearSet( "scarlet_inquisitors_expurgation", 151813 )
            addAura( "scarlet_inquisitors_expurgation", 248289, "duration", 3600, "max_stack", 30 )

        setTalentLegendary( 'soul_of_the_highlord', 'retribution',  'divine_purpose' )
        setTalentLegendary( 'soul_of_the_highlord', 'protection', 'holy_shield' )
        setTalentLegendary( 'soul_of_the_highlord', 'holy', 'divine_purpose' )

        addHook( 'specializationChanged', function ()
            setPotion( 'old_war' )
            setRole( state.spec.protection and 'tank' or 'attack' )
        end )


        -- Class/Spec Settings
        --[[ addToggle( 'wake_of_ashes', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'wake_of_ashes_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for your artifact ability will be overriden and your artifact ability may be recommended.",
            width = "full"
        } )


        -- Using these to abstract the 'Wake of Ashes' options so the same keybinds/toggles work in Protection spec.
        addMetaFunction( 'toggle', 'artifact_ability', function()
            return state.toggle.wake_of_ashes and not Hekili.DB.profile.blacklist.wake_of_ashes
        end )

        addMetaFunction( 'settings', 'artifact_cooldown', function()
            return state.settings.wake_of_ashes_cooldown
        end ) ]]


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
            talent = 'aegis_of_light'
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
            if set_bonus.tier20_4pc > 0 then applyDebuff( 'target', 'avengers_protection', 10 ) end
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
            notalent = 'crusade',
            usable = function () return not buff.avenging_wrath.up end,
            toggle = 'cooldowns'
        } )

        addHandler( 'avenging_wrath', function ()
            applyBuff( 'avenging_wrath', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2.5 ) )
            if equipped.chain_of_thrayn then applyBuff( 'chain_of_thrayn', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2 ) ) end
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
            removeBuff( 'righteous_verdict' )
            removeBuff( 'sacred_judgment' )
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
            talent = 'crusade',
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
            notalent = 'zeal'
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
            talent = 'divine_hammer',
            bind = 'blade_of_justice'
        } )

        addHandler( 'divine_hammer', function ()
            applyBuff( 'divine_hammer', 12 )
            removeBuff( 'righteous_verdict' )
            removeBuff( 'sacred_judgment' )
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
            if buff.divine_purpose.up then return 0 end
            if buff.the_fires_of_justice.up then x = x - 1 end
            if buff.t21_4pc_sacred_judgment.up then x = x - 1 end
            return x
        end )

        addHandler( 'divine_storm', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            else
                removeBuff( 'the_fires_of_justice' )
                removeBuff( 't21_4pc_sacred_judgment' )
            end
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
            talent = 'execution_sentence'
        } )

		modifyAbility( 'execution_sentence', 'spend', function( x )
            if buff.divine_purpose.up then return 0 end
            if buff.the_fires_of_justice.up then x = x - 1 end
            if buff.t21_4pc_sacred_judgment.up then x = x - 1 end            
			return x
		end )

        modifyAbility( 'execution_sentence', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'execution_sentence', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            else
                removeBuff( 'the_fires_of_justice' )
                removeBuff( 't21_4pc_sacred_judgment' )
            end
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
            talent = 'holy_wrath',
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
                if set_bonus.tier20_2pc > 0 then applyBuff( 'sacred_judgment' ) end
                if set_bonus.tier21_4pc > 0 then applyBuff( 'hidden_retribution_t21_4p', 15 ) end
                if talent.sacred_judgment.enabled then applyBuff( 'sacred_judgment' ) end
            end
        end )


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
			if buff.the_fires_of_justice.up then x = x - 1 end
            if buff.t21_4pc_sacred_judgment.up then x = x - 1 end            
            return x
        end )

        addHandler( 'justicars_vengeance', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            else
                removeBuff( 'the_fires_of_justice' )
                removeBuff( 't21_4pc_sacred_judgment' )
            end
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
            if buff.divine_purpose.up then return 0 end
            if buff.the_fires_of_justice.up then x = x - 1 end
            if buff.t21_4pc_sacred_judgment.up then x = x - 1 end
            return x
        end )

        addHandler( 'templars_verdict', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            else
                removeBuff( 'the_fires_of_justice' )
                removeBuff( 't21_4pc_sacred_judgment' )
            end
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
            equipped = 'ashbringer',
            usable = function () return artifact.ashes_to_ashes.enabled and holy_power.current <= settings.maximum_wake_power end,
            toggle = 'artifact'
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
            talent = 'word_of_glory'
        } )

        modifyAbility( 'word_of_glory', 'spend', function( x )
            if buff.divine_purpose.up then return 0 end
            if buff.the_fires_of_justice.up then x = x - 1 end
            if buff.t21_4pc_sacred_judgment.up then x = x - 1 end
            return x
        end )


        addHandler( 'word_of_glory', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            else
                removeBuff( 'the_fires_of_justice' )
                removeBuff( 't21_4pc_sacred_judgment' )
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

    end


    storeDefault( [[Protection ST]], 'actionLists', 20170727.205954, [[dWtfgaGAIkTEIQQnHKk7Ik2gfzFiP0SP08rsYNqs4Buu3gvTtuzVIDJy)sYOqsvdtknovQOtRQHIKudMQA4iXbrkNsLQ6yQ4CQujlKkzPeLftHLJYdvPk9uWYqQEUetuLk1uLIjlvtN0fvjDzONrL66k09iQYRjQWMvj2Uc0Hv67kGptvMNkvXirs0FLuJMiJxLkCsvktdjfxJOIoVcALevLhROFt4CstaGco)1(Y)QVGeotMcat2trdeqgAXTGHJE7XCRz60DoYj1CChGB5XauntO4uFbPYhAcqBQVGust4oPjWQklnrdCLSgwShxbGj7POb0NhLxBaAmVsaYYJYty71dSSa0mE7RddqrOVGe4gP)ZvfSaebbdidT4wWWrV9y6y2P19ja3YJbOAH(cs0WrpnbUswdl2JRaClpgqgAmkhyayYEkAav45zrNNOiJnsrlbKHwCly4O3EmDm706(e4gP)ZvfSaebbdqZ4TVomadngLdmWQklnrJgo3PjWvYAyXECfGB5Xa0gejEiJkkv(G0J2EayYEkAGcQ1gcYyXrFKrVTMoLzLp1w5FQ8PkQQYN6R8ngVCXXJTKE9Knw2oYCgPu5tDv(6ArI6mzJLTJSsTCh7E8irDqYAyXELp1v5pfcBxmaXrUJDpEKOotPL5HLk)7PY)u5F)aYqlUfmC0BpMoMDADFcCJ0)5QcwaIGGbOz82xhgyhejEiRuxKE02dSQYst0OHJAstGRK1WI94ka3YJbKVXUhps0aWK9u0abKHwCly4O3EmDm706(e4gP)ZvfSaebbdqZ4TVomGCh7E8irdSQYst0OHtottGRK1WI94ka3YJbUxbPGt2QVGeaMSNIgiGm0IBbdh92JPJzNw3Na3i9FUQGfGiiyaAgV91HbMcsbNSvFbjWQklnrJgotPjWvYAyXECfGB5XaUSyPG9kFQC55rwayYEkAGPqy7IbiogwSuWET0YZJmNP0Y8Wc1EcqJ5vceqgAXTGHJE7X0XStR7tGBK(pxvWcqeemanJ3(6WagwSuWET0YZJSaRQS0enA4mNMaRQS0ena3YJbOYLNhzv(Ilv(Qew5l79KuumwcqZ4TVomG0YZJSAXLAvcRzVNKIIXsazOf3cgo6ThthZoTUpbUr6)CvblarqWaWK9u0abUswdl2JROH7ottGRK1WI94kamzpfnWuiSDXaeNI0J2ET4sTkH1S3tsrXyXzkTmpSiVPqy7IbiofPhT9AXLAvcRzVNKIIXIZuAzEyPMFVJa0mE7RdduKE02RfxQvjSM9EskkglbUr6)CvblarqWa06dUKj2JRaClpgaKE02R8fxQ8vjSYx27jPOySeqgAXTGHJE7X0XStR7tayYEkAZqkya95XaRQS0enA4UR0e4kznSypUcWT8yaAdIepKrfLkFq6rBVYN6p3pamzpfnqazOf3cgo6ThthZoTUpbUr6)CvblarqWa0mE7RddSdIepKvQlspA7bwvzPjA0ObUB8YoA14kAc]] )

    storeDefault( [[Protection Defensives]], 'actionLists', 20170727.205954, [[deJzcaGEjH2evLSljvBJOmtQkmBkDBIQDsO9k2nf7xvgLKGHPGFdmuvkdwvnCQ0bLKofvv6ykAHkKLsQSycA5K8uKLPsEUetus0uPktMith1fvP6zKQUob2mvSDQQY3iftJQsDALgjvvCzOrlvFMu6Kkuhg01OQOZlP8xv8AQQQhlLZmEHeHYXq3uagB8cmVFLOdAkR)WsOkrhOalNrH0HwewWiEnm1mO56Q(0N(EQpe5ITfA3kc5fyIOmzHQ24fykXlIZ4fcYSkEHdrn16YHyOX)Rr777R3xqbpL(IwPqIq5yiQVOv69boVp3X3x3QTZiqq59RW0VHQkCTlxluPVOv6aCoChpQvBNrGGsiDOfHfmIxdtztn1h0pdn2iTniduHmadg6Ubk0IszuiQPwx2RMlgQSYBHJ4v8cD3afArPmke1uRlhsqbpf06C6i0gsekhd5hOr69boVp3X3)McWyJbQq6qlclyeVgMYMAQpOFgASrABqgOczagmuvHRD5AH6qJ0b4C4oECvagBmqfcYSkEHdhr9Xl0DduOfLYOqutTUCibf8uqRZPJqBirOCmKpwTD(9boVp3X3)McWyJbQq6qlclyeVgMYMAQpOFgASrABqgOczagmuvHRD5AHSR2oFaohUJhxfGXgduHGmRIx4WHdrn16YHcNaa]] )

    storeDefault( [[Protection Cooldowns]], 'actionLists', 20170727.205954, [[d4Y1baGEIQAxef2gPWSf62sPDkv7fTBq7Ncnmk53egkrPgmPYWf4Ga1XaSqsvlLQAXsXYj5Hev5PklJk9CrMirjtLitMkMUKlsPCzORtrTzkvBNuQVsu00iQ03jfDAvDyvgnf8nGCsb1ZiLCnIkopv5XI6VcYNPitakXjl0(zowupx)ArozRefMRxanQtEcr0rOjmX5Jr8si7UwaGSa56kda5ixaT4waM)l(Y)Qxazxdn4aNRxatuIDakXzdEnr0H65ww9bfhxyOZNVsO4GciYbU5JF5XLq1fy4B58XKWSkJjkXIZhJ4Lq2DTaabyX1VwKBO6cm8TSy3LsC2GxteDOEULvFqXXfg685RekoOaICGB(4xECOhgsypu5P48XKWSkJjkXIZhJ4Lq2DTaabyX1VwKZMhAuNWUrDsEkwSRfL4SbVMi6q9ClR(GIJZhtcZQmMOeloWnF8lpUtBeA6HMcPP6kdCHHoF(kHIdkGiNpgXlHS7AbacWIRFTihyTrOPhAYOozQUYalwClR(GIJfja]] )

    storeDefault( [[Protection Default]], 'actionLists', 20170727.205954, [[d4cWcaGEPiTluKTPu0SH6Mer3wuTtPAVu7wX(vHHjk)wyOOWGvrdNiDqr0XqPfkfwkr1IvjlxjpukQNcwMk1ZjmrLQMQuAYqA6KUie5QsrCzKRlcBwKSDuutdIY3jcNwY3ikpgvNuK6zkfUgevNxP0FHWNvQCyvTzDRH(NtgyScL4AfZX5Ek1NaRgaPeVEC10xRyCFZnniNW0li3VZyLLj7(MjwKJm2nma8vjvnyijxRyeU1Dw3AaP5VWeQByO)5KbgRqjUwXCCUNsrJOyMega(QKQg0y3omXucbHaLsrJOyMegKty6fK73zSYyZmKEql(RXYWedzi5vHlDRb(JXiEUwXGaxc1GKbA)ZjdmwHsCTI54CpLIgrXmjS6(TBnG08xyc1nm0)CYaJvOexRyooBocmAiXima8vjvnOXUDyIjEey0qIryqoHPxqUFNXkJnZq6bT4VgldtmKHKxfU0Tg4pgJ45AfdcCjudsgO9pNmWyfkX1kMJZMJaJgsmcRUVHBnG08xyc1nma8vjvnyi9Gw8xJLHjgYqYRcx6wdjeeIsPCHb5KisS4KWTwniNW0li3VZyLXMzO)5KHMiOJZ0kLlS6oYCRbKM)ctOUHH(NtgyScL4AfZXj0Aa4RsQAWGCctVGC)oJvgBMH0dAXFnwgMyidjVkCPBnWFmgXZ1kge4sOgKmq7FozGXkuIRvmhNqRvRg2tP(ey1nSAd]] )

    storeDefault( [[SimC Retribution: opener]], 'actionLists', 20171211.164324, [[dOdKfaGALQ06vG0UeL2MsL0(uGy2smFq4Mc13eWoL0EP2nI9lKNlYWuOFdCyPoeOOblOHJkoOO44kvLJrsNtPkwijAPG0IrYYj8qq0tHwgQ06uQituPQAQkLjtQPJYfbLonrxw11rvBuPcTvqLntcBxb9yL8vfOmnLkX3vaJuPcEMsf1Ork)vuDsqvFgu4Akq15fOvQuPEns1Tv0w1BgR98gr5eYOqONjKu8mjGStrHaoNCHX9FfnFHzLgH(Y70DL7OAavvU7jRAavv19yexcjhMrJzwmjGK8MRQEZiSKMQCTvAmdLSizbnsvaaDUcErqJWt0YvZacJea5gJbA4ArTN3OXApVrLfaqhfUJ8IGgH(Y70DL7OAa1rJqFcWlwp5nZmcjTVOhdg(5jmtzmgOR98gnZvUEZiSKMQCTvAmdLSizbnsDr6c6scmmcprlxndimsaKBmgOHRf1EEJgR98gvEr6c6scmmc9L3P7k3r1aQJgH(eGxSEYBMzesAFrpgm8ZtyMYymqx75nAMR7S3mclPPkxBLgXLqYHzeMrHPZYPae(uwM8cUJ5C5SIchKOWrJzOKfjlOXwSAYZzaH4eMr4jA5QzaHrcGCJXanCTO2ZB0yTN3ygXQjpkCdieNWmc9L3P7k3r1aQJgH(eGxSEYBMzesAFrpgm8ZtyMYymqx75nAMR7I3mclPPkxBLgZqjlswqJ7LxdJ5jmJWt0YvZacJea5gJbA4ArTN3OXApVXDZRHX8eMrOV8oDx5oQgqD0i0Na8I1tEZmJqs7l6XGHFEcZugJb6ApVrZCDW9Mryjnv5AR0iUesomJFF8soCUoBr2AHKKYvWlcMZtkVt0UokeciIcf96zPkaGo)ffrHqaruimJcxaqrdgGKDGM(ZbkY7eTNYYZXygkzrYcAKQ06NduKVx(etUUr4jA5QzaHrcGCJXanCTO2ZB0yTN3OYsRFuiqru4U5tm56gH(Y70DL7OAa1rJqFcWlwp5nZmcjTVOhdg(5jmtzmgOR98gnZ1D1BgHL0uLRTsJ4si5Wm(9Xl5W56SfzRfsskxbViyopP8or76OqiGiku0RNLQaa68xuefcberHWmkCbafnyas2bA6phOiVt0EklphJzOKfjlOrTCOK8CA9CEHr4jA5QzaHrcGCJXanCTO2ZB0yTN34(LdLKhfUd9CEHrOV8oDx5oQgqD0i0Na8I1tEZmJqs7l6XGHFEcZugJb6ApVrZCnG3mclPPkxBLgZqjlswqJd00FoqrENO9Kr4jA5QzaHrcGCJXanCTO2ZB0yTN34G10FuiqruyMeTNmc9L3P7k3r1aQJgH(eGxSEYBMzesAFrpgm8ZtyMYymqx75nAMzgroFj7ICqBMeqCnWOz2a]] )

    storeDefault( [[SimC Retribution: default]], 'actionLists', 20171211.164324, [[dyJ4daGEcsTluI8AfXmjPA2eDta(MIYobAVIDdA)Q0OiOAye43knyvmCuQoiGofjOJrrNJGOfIsAPeAXOy5K6Hs4PipwH1jrMikrnvuPjJQMovxKe1TP0LHUofEUK2kjXMjb2ojLdRQZtc9zukFNGYPL6zsunAsKLHkojjP)QO6AeeUhkH5rqY0KOSifPJz4gc8TyiQTf3Ji66MXW7fw6E4rf8gspeXoo6x2c979cd4mbHerj(vmGCeyoZ0KJqYsCkVSYeIYdrdDZUhkeWH3lSgUb0mCdPm8zKiFyneqMw2UIH0iJXemKQq(E8(QdbxigcWYRYRbFlgke4BXqIiJXemKikXVIbKJaZzMccjI11qpWA4gpuHs4ycGvn0IqpmHaS8GVfdfpGCc3qkdFgjYhwdrdDZUhYBlEpc19WjeqMw2UIHgVuo)hEVW5YU6HufY3J3xDi4cXqawEvEn4BXqHaFlgQ4LY7b4W7fEpQ3vpeqnB1qW3ISyk12I7reDDZy49clDpl7ie1tdjIs8Rya5iWCMPGqIyDn0dSgUXdvOeoMayvdTi0dtialp4BXquBlUhr01nJH3lS09SSJquhpGLhUHug(msKpSgcitlBxXqJxkN)dVx4Czx9qQc57X7RoeCHyialVkVg8TyOqGVfdv8s59aC49cVh17QFpc3uHHaQzRgc(wKftP2wCpIORBgdVxyP7zSRKFfgSonKikXVIbKJaZzMccjI11qpWA4gpuHs4ycGvn0IqpmHaS8GVfdrTT4Eerx3mgEVWs3Zyxj)kmynEallCdPm8zKiFyneqMw2UIHgVuo)hEVW5YU6HufY3J3xDi4cXqawEvEn4BXqHaFlgQ4LY7b4W7fEpQ3v)EeohfgcOMTAi4BrwmLABX9iIUUzm8EHLUh2qiQFF11PHerj(vmGCeyoZuqirSUg6bwd34HkuchtaSQHwe6HjeGLh8TyiQTf3Ji66MXW7fw6EydHO(9vxJhpelJk4nKEynEc]] )

    storeDefault( [[SimC Retribution: precombat]], 'actionLists', 20171211.164324, [[b4vmErLxt5uyTvMxtnvATnKFGjvz0jxAIvhDP9MB64hyWjxzJ9wBIfgDEnfrLzwy1XgDEjKxtjvzSvwyZvMxojdmXCtmXitoUeZnXetm541utnMCPbhDEnLxtf0y0L2BUnNxu5LtX4fvEnvrUfMySvgzEjKxtfKyPXwA0LNxtb3B0L2BU51uj5gzPnwy09MCEnLBV5wzEnvtVrMvHjNtH1wzEnLxt5uyTvMxtb1B0L2BU51ubj3zZ51uUfwBL1JiVXgzFDxyYjIxtjvzSvwyZvMxojdmXCtmW41usv2CVvNCJv2CErLx051udHwzJTwtVzxzTvMB05LyEnvtVrMtH1wzEn1BSr2x3fMCErNx051utbxzJLwySLMEHrxAV5MxoDdmErNxEb]] )

    storeDefault( [[SimC Retribution: cooldowns]], 'actionLists', 20171211.164324, [[dC0(paqiPq1IOKeBIsvFskKAusjDkPeRsrvTlqggP4ysvltk6zkQ00KcLRHiABusGVHOmokjIZPOcRJscAEkQY9qe2hPIdIiTqevpKuPjkfsUOuWgvurJKsIYjPuzLsHOxsjr1nHk7KOgkLeYsPuEkvtLu1vLcHTsj1xPKuTxv)vrgmKdlzXi8yrMSGlJAZe5ZsLrdkNwOvtjH61kkZwHBdLDJ0VvA4qvhNssA5eEoftNKRlQTtk9DkX4PKuoVuQ1tjrA(GQ9d87V(7YfgF3Jy6cq2yLisKvXLAfcqPDhH1c1CVrXsvEOo53TXdUm8LBQPNS((MZbupz999ZXDpjI4v3VtAsfxQ56VC)1FVbArm4Wj)UNer8Q7SvnhXJNdqLbgBMu7uiBuaK9auyvqwQz80knvgySbsWyvKAaO5bqDPaanFaQjabhoa1karKLKGsISPcmugpazparKLKGsISPcmKGXQi1aqZdG6sbaA(autacoCaIiljbvAzAxK2nzrukyqz8aK9aerwscQ0Y0UiTBYIOuWGemwfPgaAEauxkaqZhGAcqTCNuI4iQAFxAfDSuKPbZKuriIPsTI72rdXuPwXD6s5742G1LqUW473Llm((CUIowkY0qJ2aqZzriIPsTI724bxg(Yn10twVM72yZMfj2C9xDxxyCAgUvlJXu1jUJBdYfgF)Ql386V3aTigC4KF3tIiE19wbiISKeuPLPDrA3KfrPGbLXdqWHdqezjjOKiBQadLXdq2dqezjjOKiBQadzuvAgaPdjaOEscqWHdqPDhH1cfkjYMkWqcgRIudabq6aqn1aq2dqnoarKLKGsISPcmugpa1YDsjIJOQ99GOYDWutR0KzZdZD7OHyQuR4oDP8DCBW6sixy897YfgFVrjQChmfaTsaKV5H5UnEWLHVCtn9K1R5Un2SzrInx)v31fgNMHB1YymvDI742GCHX3V6YZ96V3aTigC4KF3tIiE19wbiISKeuPLPDrA3KfrPGbLXdqWHdqezjjOKiBQadLXdq2dqezjjOKiBQadzuvAMoKONKaeC4auA3ryTqHsISPcmKGXQi1aq6aqKeGShGACaIiljbLeztfyOmEaQfqJ8oPeXru1(owSdMAALMMjwt2C3oAiMk1kUtxkFh3gSUeYfgF)UCHX3Xf7GPaOvcGSYfRjBUBJhCz4l3utpz9AUBJnBwKyZ1F1DDHXPz4wTmgtvN4oUnixy89RUCJD93BGwedoCYV7jreV6ERaerwsckjYMkWqz8aK9aerwsckjYMkWqgvLMbq6qcaQNKaeC4auA3ryTqHsISPcmKGXQi1aq6aqDPaanFaQja1cabhoa1karKLKGkTmTls7MSikfmOmEacoCakT7iSwOqLwM2fPDtweLcgKGXQi1aq6aqDPaanFaQja1cOrENuI4iQAF3GNtkwmTsteSsuTRXD7OHyQuR4oDP8DCBW6sixy897YfgF3XZjflaOvcGiNvIQDnUBJhCz4l3utpz9AUBJnBwKyZ1F1DDHXPz4wTmgtvN4oUnixy89RUmjV(7nqlIbho539KiIxDNiljbvAzAxK2nzrukyqz8aeC4aerwsckjYMkWqz8aK9aerwsckjYMkWqgvLMbq6qcaQNKaeC4auRauA3ryTqHkTmTls7MSikfmibJvrQbG0bGQKkUuOmgHOgty7s7gvulBGs7ocRfkabhoaL2DewluOKiBQadjySksnaKoauLuXLcLXie1ycBxA3OIAzduA3ryTqbOwUtkrCevTVNXie1ycBxA3OIAzZD7OHyQuR4oDP8DCBW6sixy897YfgFVrGriQbaHBxA3OIAzZDB8GldF5MA6jRxZDBSzZIeBU(RURlmond3QLXyQ6e3XTb5cJVF1LTcU(7nqlIbho53Llm(U1XAaqReaPlxgEWgdaPFTArQ5UD0qmvQvCNUu(oPeXru1(U2ynMwPPexgEWgZKATArQ5Un2SzrInx)v3TXdUm8LBQPNSEn39KiIxDVvaIiljbvAzAxK2nzrukyqz8aeC4aerwsckjYMkWqz8aK9aerwsckjYMkWqgvLMbq6qcaQNKaulaeC4auRauA3ryTqHsISPcmKGXQi1aq6aqZvdazpa14aerwsckjYMkWqz8aeC4auA3ryTqHkTmTls7MSikfmibJvrQbG0bGMRgaQLRUmzx)9gOfXGdN87Ksehrv77zdpfvmM5UD0qmvQvCNUu(oUnyDjKlm((D5cJV3immazNIXm3TXdUm8LBQPNSEn3TXMnlsS56V6UUW40mCRwgJPQtCh3gKlm((vx2k56V3aTigC4KF3tIiE19wbiISKeeXy3WiBuqz8aeC4aerwscQ0Y0UiTBYIOuWGY4bi4WbiISKeusKnvGHY4bi7biISKeusKnvGHemwfPgaAEautscqWHdqQs0XkiveJNu7uiYa08iba1yAaOwUtkrCevTVJFvXLE3oAiMk1kUtxkFh3gSUeYfgF)UCHX3TIwvCP3jv0zUtlmMewLDeMSucRYDB8GldF5MA6jRxZDBSzZIeBU(RURlmond3QLXyQ6e3XTb5cJVVJWKLsC1LNJR)Ed0IyWHt(DsjIJOQ9DIXUHjPSO9D7OHyQuR4oDP8DCBW6sixy897YfgFN8XUbaAoZI23TXdUm8LBQPNSEn3TXMnlsS56V6UUW40mCRwgJPQtCh3gKlm((vxUxZ1FVbArm4Wj)oPeXru1(oblmSywK2D3oAiMk1kUtxkFh3gSUeYfgF)UCHX3jNfgwmls7UBJhCz4l3utpz9AUBJnBwKyZ1F1DDHXPz4wTmgtvN4oUnixy89RUCF)1FVbArm4Wj)UNer8Q7TcqezjjOKiBQadLXdqWHdqezjjOslt7I0UjlIsbdkJhGAbGShGGTJ2t4xlSakLfcMQaisaqnbi7bOwbO0UJWAHcrmQapTstwXzJkMyibJvrQbG0bG6sbacoCakT7iSwOqHO2iLNGvyySasWyvKAaiDaOUuaGA5oPeXru1(EjsfLNuRqWu1D7OHyQuR4oDP8DCBW6sixy897YfgFNurQOmaPFfcMQUBJhCz4l3utpz9AUBJnBwKyZ1F1DDHXPz4wTmgtvN4oUnixy89RUCFZR)Ed0IyWHt(DsjIJOQ9Dy7O9KfrPGD3oAiMk1kUtxkFh3gSUeYfgF)UCHX3TY2rBaYQlkfS724bxg(Yn10twVM72yZMfj2C9xDxxyCAgUvlJXu1jUJBdYfgF)Ql3p3R)Ed0IyWHt(DsjIJOQ9DdSipctR0KwM2XfnX3TJgIPsTI70LY3XTbRlHCHX3Vlxy8DhwKhbaALaiRzAhx0eF3gp4YWxUPMEY61C3gB2SiXMR)Q76cJtZWTAzmMQoXDCBqUW47xD5(g76V3aTigC4KFNuI4iQAFV0Y0UiTBYIOuWUBhnetLAf3PlLVJBdwxc5cJVFxUW47KQLPDrAhaz1fLc2DB8GldF5MA6jRxZDBSzZIeBU(RURlmond3QLXyQ6e3XTb5cJVF1L7j51FVbArm4Wj)UNer8Q7W2r7j8RfwaLYcbtvaKoKaGMlabhoa1ka1kaXw1CepEoanIvqePMjPSO9uMo4YaJdaeC4aKOsmeXy3WepKaOwai7biy7O9e(1clGszHGPkashsaqnbOwUtkrCevTVNeztf472rdXuPwXD6s5742G1LqUW473Llm(UUISPc8DB8GldF5MA6jRxZDBSzZIeBU(RURlmond3QLXyQ6e3XTb5cJVF1v3D8CkwJOvAPIl9YKP5QFa]] )

    storeDefault( [[SimC Retribution: finishers]], 'actionLists', 20171211.164324, [[d8JchaGAssRhrP2eK0UOQ2gIc2hjHNl4WGMneZNKQBIiFds52I6EkQu7Ke7v1Ub2pkJseAyuL(nQonu)vrgmsdxKoeIQoLiQJPqhxiLwiPklLQyXKYYj8qHKNszzcL1POsMOqftLuzYenDLUijLhtLllDDeEgII2kKQnROSDfCqsv9DfvnnfvmpHuSksI(SqmAiX4ru5KcvDoeLCnHuDErKvIOqFsOsVwe8hVUBQbGAivETBkWCVz4CumQNUcSgXI5G5IrNHb4akveUfNodsGSxVBEksHHELyEhrBCmgz5pI244izDZCcC6E7M(UfZbHR7kJx3n1aqnKkVE3mNaNU3GUfp0PcAg3aJgnZnJsMmkQmAImQJZrK85b(QsiJKly9fndXGaJgnmAeNKrvjJoh)yrNrvxDgvwnIzZ8vLqgjxW6lAgIbbgvfmAeNKrvjJoh)yrNrt(M(Aye8M0TsU6iwmhmfkylW1BXdKyhC5IBaoO3iXLOdfkWCVDtbM7n1ixDelMdyuRGTaxV5Pifg6vI5DeTrV380aNq4A46(ElkuQlbs8HMlyV2nsCPcm3BFVsSR7MAaOgsLxVBMtGt3BQsiJKlyN4dviWYYOOYOdqbgQHuFzyYbdludPmkQmQgXSz(s8ag0PucrkpuFI0B6RHrWBs3K4bmOtHLlY3IhiXo4Yf3aCqVrIlrhkuG5E7Mcm3BXbpGbLrTLlY38uKcd9kX8oI2O3BEAGtiCnCDFVffk1Laj(qZfSx7gjUubM7TVxHmVUBQbGAivE9UzoboDVPkHmsUGDIpuHallJIkJoafyOgs9LHjhmSqnKYOOYOjYOKNrxisbRVtqeGY6xaudPsgvD1zuhNJi5Zd8DcIauwFrZqmiWOQGrJ4KmQkz0ymAY30xdJG3KUjXdyqNclxKVfpqIDWLlUb4GEJexIouOaZ92nfyU3IdEadkJAlxKz0eht(MNIuyOxjM3r0g9EZtdCcHRHR77TOqPUeiXhAUG9A3iXLkWCV99kZ56UPgaQHu517M5e409MQeYi5c2j(qfcSSmkQmQgXSz(s8ag0PucrkpuFIugfvgL8mAJwcCAAL(ZJcoKwXeF20IsNaWffrjBC(M(Aye8M0nvjcl2bfHPHcIuiW1BXdKyhC5IBaoO3iXLOdfkWCVDtbM7nYiryXoOiUbgf9cIuiW1BEksHHELyEhrB07npnWjeUgUUV3IcL6sGeFO5c2RDJexQaZ923Re9R7MAaOgsLxVBMtGt3BQsiJKlyN4dviWYYOOYOAeZM5lXdyqNsjeP8q9jsVPVggbVjDBBofbkctdviXU9w8aj2bxU4gGd6nsCj6qHcm3B3uG5EtxZPiqrCdmk6viXU9MNIuyOxjM3r0g9EZtdCcHRHR77TOqPUeiXhAUG9A3iXLkWCV99kKHR7MAaOgsLxVBMtGt3BQsiJKlyN4dviWYYOOYOjYOKNrxisbRVtqeGY6xaudPsgvD1zuhNJi5Zd8DcIauwFrZqmiWOQGrJ4KmQkz0ymAYmkQmAImk5z0fIuW6xYvhXI5GPqbBbU6xaudPsgvD1zuhNJi5Zd8l5QJyXCWuOGTax9fndXGaJQcgnItYOjFtFnmcEt622CkcueMgQqID7T4bsSdUCXnah0BK4s0HcfyU3UPaZ9MUMtrGI4gyu0RqIDlJM4yY38uKcd9kX8oI2O3BEAGtiCnCDFVffk1Laj(qZfSx7gjUubM7TVFVzP1HHiyYgUyo4kO597p]] )

    storeDefault( [[SimC Retribution: generators]], 'actionLists', 20171211.164324, [[du0FyaqifvSiuHAtkkJcKCkq0QevPzjQIyxGAyOkhtblJQ4zKQsttfPRPiABKQQ(MOW4qfW5evH1POsZtfX9ivzFGuhevLfkk6HGWejvvCrfHrsQQ0jvu1krfzMOc0nPq7KQAPuLEQutvrARIQ6RIQiTwrvu7L4VKYGLCyLwmf9yQmzrUm0MvOptQmAv40OSAur9ArLzRs3wv2ns)gXWrLooQGwojpNsth46QQTRI67IsJNuvCEuvTEuHmFky)cldYuPNGUMxmjMs7Vpu6M9GikViqXm)agHo3O0HuuTaIYkT(bh3)fizkTx8IRffFp8gYyyWtEapKXWWqEiD7umUaPLMphGrOwzQ4pitLEc6AEXKKP0TtX4cKEDa2zudP4JH2OGwVO8eLbdrfCcQOm)JJWw3QUiqJr5WpZYaeLvd1hUFLUfWiuylyD5IcA9IYtEe1SOcofvurffurbvuih(zC5Ij41EGwnarl9TGOMfvIaGZU5qnYO2ApqlmG5YXO6IAwubNIkQOIkQOIkkOIcWEyuqh1aVOmyiQebaNDZHAKrT1EGwyf(wg1g1jrPZLIcYOcofvurffKrzWqWPOIkQOGkQ5efYHFgxUycEThOvdq0sFliQzrfCkQOIkQOIkQOGkkZ)4i8EgP6yuDAzvl4a(ZnkdgIcQOm)JJWo13Uje(ZnQzrz(hhHDQVDtiSfSUCrbTErnmzuqgLbdrbvuoc5MizPWo13UjewHVLrTrbDudtg1SOMtuM)XryN6B3ec)5gfKrzWquoc5MizPW7zKQJr1PLvTGdyf(wg1gf0rnmzWPOIkQOIkQOIcYOcofvurffKrbzWjidofCsA(mzxgGFPpVk2AErPNNMyUfqustjuuAJKu(RYFFO0jRMBTG18Is7Vpu6gquyu5V3pknFkDwPP7d1lz1CRfSMxmp58E)OERdWoJAifFm0cTEEmyakZ)4iS1TQlc0yuo8ZSmarz1q9H7xPBbmcf2cwxoO1ZtEmdkKd)mUCXe8WPNQVtYbMbvIaGZU5qnYO2ApqlmG5YXO6Mbype6bEgmKia4SBouJmQT2d0cRW3YO2t05sqcPbdqz(hhHTUvDrGgJYHFMLbikRgQpC)kDlGrOWwW6YbTEEYJzqz(hhH3ZivhJQtlRAbhWFUgmy(hhHDQVDti8N7mZ)4iSt9TBcHTG1LdA9gM0GbhHCtKSuyN6B3ecRW3YOwOhMC2Cm)JJWo13Uje(ZfsdgCeYnrYsH3ZivhJQtlRAbhWk8TmQf6HjnyaQ5SoaJqHDQVDtimsxZlMMnN1byek8EgP6yuDAzvl4agPR5ftqc5S5GC4NXLlMGho9u9DsoaKs7fV4ArX3dVHmg4jTx0s(khALPcqAioqxoJKZ4dPaXuAJKK)(qPfG47rMk9e018IjjtPBNIXfinurz(hhHDQVDti8NBuZIY8poc7uF7MqylyD5I6KOgMmkdgIY8pocFzBsXOwTXVIFTp9IR9atWFUrbzugmefurTkaBCDa41EGwnarBThOfgPR5ftrnlkhHCtKSu4SBouJmQT2d0cRW3YO2OojkDUuu5nkprbP08zYUma)s727vBDagHQDzwG0Zttm3cikPPekkTrsk)v5VpuAP93hkne79gfFoaJqJIdYSaP5tPZknDFOECCZEqeLxeOyMFaJqNBuJmkZEGklhlTx8IRffFp8gYyGN0Erl5RCOvMkaPH4aD5msoJpKcetPnss(7dLUzpiIYlcumZpGrOZnQrgLzpqLvaIV(ktLEc6AEXKKP0TtX4cKgSxKcGr9bDFaJq1SifGuhcJ018IPOMffur5iKBIKLcZ5Fs3dPayf(wg1g1jrPZLIkVrDkSNjJYGHOsO5FCeMZ)KUhsbWk8TmQnkOJsNlfvEJ6uyptgfKrnlkhHCtKSuyuFq3hWiunlsbi1HWFUrzWquM)Xr4ShmlxuPrg1ahOgDbhkKJyp4p3OMfL5FCeo7bZYfvAKrnWbQrxWHc5i2dwHVLrTrDsu6CPOYBudWtknFMSldWV0U9E1whGrOAxMfi980eZTaIsAkHIsBKKYFv(7dLwA)9HsdXEVrXNdWi0O4GmlikOgGuA(u6Sst3hQhh3Sher5fbkM5hWi05g1iJYShOYYXs7fV4ArX3dVHmg4jTx0s(khALPcqAioqxoJKZ4dPaXuAJKK)(qPB2dIO8IafZ8dye6CJAKrz2duzfG4FQmv6jOR5ftsMs3ofJlq6ebaJ6d6(agHQzrkaPoegWC5yuDrnlQebaJ6d6(agHQzrkaPoewHVLrTrDsu6CPOYBuEIAwuj08pocZ5Fs3dPayf(wg1g1jrPZLIkVr5jkdgIYIantc9BHbmu5zq7uUUOGokEsZNj7Ya8lnN)jDpKcKEEAI5warjnLqrPnss5Vk)9HslT)(qP50pP7HuG0EXlUwu89WBiJbEs7fTKVYHwzQaKgId0LZi5m(qkqmL2ij5VpuAbi(tktLEc6AEXKKP0TtX4cK(GC5xJljlQGDFLcPGOorVO8e1SOGkklc0mj0VfgWqLhEAE46Ic6O4fLbdrzrGMjH(TWagQ8Wt7uUUOGokErbP08zYUma)sBE3eQrg1483cyou65PjMBbeL0ucfL2ijL)Q83hkT0(7dLoZ7MWOiJrXPVfWCO0EXlUwu89WBiJbEs7fTKVYHwzQaKgId0LZi5m(qkqmL2ij5VpuAbi(6Vmv6jOR5ftsMs3ofJlq6dYLFnUKSOc29vkKcI6e9IYtuZIcQOSiqZKq)wyadvE4P5HRlkOJIxugmeLfbAMe63cdyOYdpTt56Ic6O4ffKsZNj7Ya8lDIDMrrTJ99qL0Zttm3cikPPekkTrsk)v5VpuAP93hkT(HDMrXO0V77HkP9IxCTO47H3qgd8K2lAjFLdTYubinehOlNrYz8HuGykTrsYFFO0cq8ZqMk9e018IjjtPBNIXfinurDqU8RXLKfvWUVsHuquNOxu8IYGHOoix(14sYIky3xPqkik9IAiQzrbvuoc5MizPWM3nHAKrno)TaMdHv4BzuBuqhLoxkkdgIYri3ejlfoXoZOO2X(EOcwHVLrTrbDu6CPOGmkdgI6GC5xJljlQGDFLcPGO0lkprnlkOIcQOCeYnrYsH5iCVWUJvPdTAJQ1bye6EJ6e9IIhS(pzugmeLJqUjswkSt9TBcvAwGILdHDhRshA1gvRdWi09g1j6ffpy9FYOGmkiJcsP5ZKDza(Lo7Md1iJAR9aTsppnXClGOKMsOO0gjP8xL)(qPL2FFO05PBomkYyu8zpqR0EXlUwu89WBiJbEs7fTKVYHwzQaKgId0LZi5m(qkqmL2ij5VpuAbi(CazQ0tqxZlMKmLUDkgxG0hKl)ACjzrfS7Ruife1j6fL(g1SOMtuweOzsOFlmGHkp80oLRlkOJIN08zYUma)sBE3eQrg1483cyou65PjMBbeL0ucfL2ijL)Q83hkT0(7dLoZ7MWOiJrXPVfWCyuqnaP0EXlUwu89WBiJbEs7fTKVYHwzQaKgId0LZi5m(qkqmL2ij5VpuAbi(5Hmv6jOR5ftsMs3ofJlq6dYLFnUKSOc29vkKcI6e9IsFJAwuZjklc0mj0VfgWqLhEANY1ff0rXtA(mzxgGFPtSZmkQDSVhQKEEAI5warjnLqrPnss5Vk)9HslT)(qP1pSZmkgL(DFpuffudqkTx8IRffFp8gYyGN0Erl5RCOvMkaPH4aD5msoJpKcetPnss(7dLwaI)apzQ0tqxZlMKmLMpt2Lb4xAo)t6Eifi980eZTaIsAkHIsBKKYFv(7dLwA)9HsZPFs3dPGOGAasP9IxCTO47H3qgd8K2lAjFLdTYubinehOlNrYz8HuGykTrsYFFO0cq8hgKPspbDnVysYu62PyCbsB(hhHtSZmkQX9R4sSi8NR08zYUma)s727vBDagHQDzwG0Zttm3cikPPekkTrsk)v5VpuAP93hkne79gfFoaJqJIdYSGOGYdKsZNsNvA6(q944M9GikViqXm)agHo3OgzuM9avwowAV4fxlk(E4nKXapP9IwYx5qRmvasdXb6YzKCgFifiMsBKK83hkDZEqeLxeOyMFaJqNBuJmkZEGkRae)bpYuPNGUMxmjzkD7umUaPDeYnrYsH5iCVWUJvPdTAJQ1bye6EJcA9IAaw)NmQzrDqU8RXLKfvWUVsHuquNOxuNg1SOGkkhHCtKSuyZ7MqnYOgN)waZHWk8TmQnkOJsNlfvEJYtugmeLJqUjswkCIDMrrTJ99qfScFlJAJc6O05srL3O8efKrnlQeA(hhH58pP7HuaScFlJAJc6O05ssZNj7Ya8lnhH7v65PjMBbeL0ucfL2ijL)Q83hkT0(7dLopJ7vAV4fxlk(E4nKXapP9IwYx5qRmvasdXb6YzKCgFifiMsBKK83hkTae)b9vMk9e018IjjtPBNIXfiTJqUjswkSt9TBcvAwGILdHDhRshA1gvRdWi09gf06f1aS(pzuZI6GC5xJljlQGDFLcPGOorVOonQzrbvuoc5MizPWM3nHAKrno)TaMdHv4BzuBuqhLoxkQ8gLNOmyikhHCtKSu4e7mJIAh77Hkyf(wg1gf0rPZLIkVr5jkiJAwuj08pocZ5Fs3dPayf(wg1gf0rPZLIAwuqffyVifaRtHlavAC(N09qkagPR5ftrzWquZjklc0mj0VfgWqLhEANY1ff0rXlQzrb2lsbWGduBKPqRgzuJZFlG5qyKUMxmffKsZNj7Ya8lTt9TBcvAwGILdLEEAI5warjnLqrPnss5Vk)9HslT)(qPHq9TBcvr1aflhkTx8IRffFp8gYyGN0Erl5RCOvMkaPH4aD5msoJpKcetPnss(7dLwaI)WPYuPNGUMxmjzknFMSldWV0oc1Io1cyeQ0Zttm3cikPPekkTrsk)v5VpuAP93hkneeQfDQfWiuP9IxCTO47H3qgd8K2lAjFLdTYubinehOlNrYz8HuGykTrsYFFO0cq8hMuMk9e018IjjtPBNIXfinYHFgxUycMZFlG5qnDlhHrnlkWQ0Ha4dCVGdyUoquqRxuzmzuZI6GC5xJljlQGDFLcPGOorVOovA(mzxgGFPp23dvAKrno)TaMdLEEAI5warjnLqrPnss5Vk)9HslT)(qP1V77HQOiJrXPVfWCO0EXlUwu89WBiJbEs7fTKVYHwzQaKgId0LZi5m(qkqmL2ij5VpuAbi(d6Vmv6jOR5ftsMsZNj7Ya8lTBVxT1byeQ2LzbsppnXClGOKMsOO0gjP8xL)(qPL2FFO0qS3Bu85amcnkoiZcIck9fsP5tPZknDFOECCZEqeLxeOyMFaJqNBuJmkZEGklhlTx8IRffFp8gYyGN0Erl5RCOvMkaPH4aD5msoJpKcetPnss(7dLUzpiIYlcumZpGrOZnQrgLzpqLvaI)qgYuPNGUMxmjzknFMSldWV0CeUxPNNMyUfqustjuuAJKu(RYFFO0s7Vpu68mU3OGAasP9IxCTO47H3qgd8K2lAjFLdTYubinehOlNrYz8HuGykTrsYFFO0cq8h4aYuPNGUMxmjzknFMSldWV0o13UjuPzbkwou65PjMBbeL0ucfL2ijL)Q83hkT0(7dLgc13UjufvduSCyuqnaP0EXlUwu89WBiJbEs7fTKVYHwzQaKgId0LZi5m(qkqmL2ij5VpuAbiaPBUOJTxghTagHk(zWtaIa]] )


    storeDefault( [[Retribution Primary]], 'displays', 20171211.164324, [[d4ZpiaGEvLEPQc7sQqTnusLdlzMusETsvnBLSmsYnrj58KQBtkNgQDsXEf7MW(vf)ergMu8BixwLHIQgSQ0WrQdkvDukb6yuvNdLuSqP0sLkTyuz5e9qs0tbpgfRJsutuPknvKmzuQPR4IQQUQubptPkUocBuPYwPeWMPkBNK6Jsf9ze10Oe03vkJKsOVrjYOPuJhL4KKWTKkKRPQO7HsQ65uzTOKshNsQJFOcWu0dgj2Hedm6RlaPoqzLcZFGPKKVHxnF4cilb5tP9XSFAdWTWF)25cTfUa6K88C3OSOhms4IPjalK88C3OSOhms4IPjG1ehXXwbdsa4VxmF2eWzJ26jKLcHhkCbSM4io2kl6bJeU0gqNKNN7gQss(gxmnbSGehX5cvm(HkWVO4wh70gONzWiXZRvy3eJQaMs7caynLpVDVrI5igmsy5NxA5XG04Qjq3BDL7IrvJVLA8BAcamsm9eyWAhRVjtmQcvGFrXTo2PnqpZGrINxRWUjg)aMs7caynLpVDVrI5igmsy5Nx2NxrSMaDV1vUlgvn(wQXVPjtMaoB0gSHhg7()0gGfsEEUBOkj5BCX0eaZGeaDXGfKJ5ZatjjFtVGXgjd0sIIIeR6QOtlsfqpMosLQpd4HetGEjUwpVMskrBbC2OnQss(gxAdSpxVGXgjdqrIVRIoTivagKgxn8Q)dxaMIEWirVGXgjd0sIIIeRcOerR)8sHcWlrZXmyK45LxI1kPEaNnAdOsBaRjoIBVy5XmyKiqxfDArQaccnfmiHlglmGJ(wRDRYzReTqYqfOIXpGmg)aKJXpaxm(zc4SrBkl6bJeU0gGfsEEUB6jKvmnbkczrPtFb4i88cS3ZRiwtAdOvS0tmOyAculA7QFTv6oE1)X4hOw02fyJ24v)hJFGArBxkrAC1WR(pg)aMs7c09gjMJyWiXZlVeRvs9awtGz23cGDWOVUavGATv6oE18PnGASdZHx4rNsN(cWfGPOhms0VWKfbu(BO(7gGn2rVkDkD6lqfaOpgCTWFRbJeXyPMaYsq(O0PVafhEHh9afHSyfwCPna3c)9BNl0w)AfUa7ZTdjga)9IXxvah9Tw7wLZoCb4LyTsQ)8QSOhms882tiRabkcz1lySrYaTKOOiXkR(3rfqERak)nu)DdmLK8n7qIjap1Zluc3ZRPKs0wGArBxuLK8n8Q)JXpWhNohwWgli)8cJ(6IrvaRjoIJTcbBmtniPlTbyFEfXA65TkaG1u(829gjMJyWiHLFEzFEfXAcWsmnbMss(MDiXaJ(6cqQduwPW8hGvflyncTNxkS2fZEAcynXrC9lmzH2jMambagjMEceOw02v)AR0D8Q5JXpGgw0)hZEcqlXALuFhsma(7fJVQa0YJbPXvtpVvbaSMYN3U3iXCedgjS8ZlT8yqAC1eGfsEEUB(O1fJFaTIL()yAcqvRtmpVDkre0X4hykj5B4v)hUaoB02hNohwWgli7sBaEjwRK6pVkl6bJebMss(gxaDsEEUB6jKvmnb0WIEIbfttaMIEWiXoKya83lgFvbkczb03APyVX0eOw02fyJ24vZhJFaNnAtHGnMPgK0L2aoB0gVA(0gOwBLUJx9FAd4SrB8Q)tBaNnAR)pTbyqAC1WRMpCb2NBhsmb4PEEHs4EEnLuI2cSp3oKyGrFDbi1bkRuy(dOtYZZDZhTUy6i)aAybqfttGPKKVzhsma(7fJVQa1I2UOkj5B4vZhJFaMIEWiXoKycWt98cLW98AkPeTfOw02LsKgxn8Q5JXpWVO4wh70gWH1OxxpP)yufalyJzQbj7fm2izGUk60Iub6ERRCxmQA8TudRt1NDSQM9WASqvbOLyTsQRGbja83lMpBcOvSauX4hOiKLcHhIsN(cWr45fWzJ26jguAd4SrBWgEyS7jguAdSqBNKPC3hTUWfaZGeSweslg)pdynXrCS3HedG)EX4RkGojpp3nkeSXm1GKUyAcynXrCS)O1L2aSqYZZDJcbBmtniPlMMafHS6GapbOxL(jZKa]] )

    storeDefault( [[Retribution AOE]], 'displays', 20171211.164324, [[daeoiaqiuvP2eQkXTqvv2LQkAyQshJuwgk1ZqvX0qvvDnPcBdvv03uvHZHQkSoskUhQkPdkLwOQYdjHjkfQlkvTrPsFuQOrssPtsIEjkrZuk4MOe2jf)eidLsDuuvklvk6PqtffxvkKTIQkzTOQuTxXGvQoSKfJKhJktgv5YQSzQ4Za1OjvNgXRvvPzRKBtj7MWVbnCK64KuTCIEovnDfxhW2jjFxvmEusNNkTEvvTFLYrlmb5k6HafDHIbh31feuJyAqPPp4usW3yRYoubLLa8Pq)4(nFbPwK))7CbFcvqxqoo(Buu0dbk8X8gKvqoo(Buu0dbk8X8gKwsSkPRsoOaj)Vy64nOxh(0cilLchyOcQoWbC8uu0dbk85lOlihh)nmLe8n(yEdY3aoGZhMy0ctWErrToE5lyl3qGIT9gi(jg2bnL1fejwk22BEJKqbmeOqnB70YJdArvtWM36k)fd7xTo00(jB2AbrojHEcoeRJV(Mjg2HjyVOOwhV8fSLBiqX2Ede)eJwqtzDbrILIT9M3ijuadbkuZ2oVZPawtWM36k)fd7xTo00(jB2AzYe0RdFWhYWP32hQGScYXXFdtjbFJpM3GeoOaPloIaCmDeCkj4BAfC6qzWpqmmGyrtLDQwMGUXWFA)4nOdumbBLKATTBkPe(eKLNlfrWJiaVTJJ76IHDWFPAfC6qzqgq2nv2PAzcYbTOQXwvFOcYv0dbkAfC6qzWpqmmGyrqfqA3TDgyWM3ijuadbk22Bb1h0RdFqM8fuDGd4AmrECdbkc2uzNQLjOaWsjhu4JH)d6PV1Q7Q86kGlOmmbRy0csfJwqWXOfugJwMGED4JIIEiqHpFbzfKJJ)MwazfZBWcqwmU0xqkahNGwfRTadmM3G1IwVAxpLR3wvFmAbRfTEH6WhBv9XOfSw06LcOfvn2Q6JrlOPSUGnVrsOagcuST3cQpipINEvUmU0xqUG16PC92QSZxqvepHISiJlJl9fKkixrpeOODralcQO3W03mO6aeUF5xepoURlivqlIOfyGXWNGYsa(yCPVGffzrg3GfGSybrC5lisFCKAr(xdbkI5hVb)LQlumi5)fJg7GUGCC83OuWJWvdu6J5nOTKyvs3TDff9qGIT9wazfm4usW30fkMG2mB7yj8B7MskHpbL3kOIEdtFZGE6BT6UkVEOcwlA9IPKGVXwvFmAblaz1k40HYGFGyyaXIg67YeuDGd44PuWJWvdu6ZxqQf5))oxWN21kub5DofWAATBiisSuST38gjHcyiqHA225DofWAcoLe8nDHIbh31feuJyAqPPpilkwjwawB7meRlg(8g0IiA7JHpbrojHEc6jcWRJVWVlGbgSw06v76PC92QSJrlO6ahW1UiGfwNycYfKwsSkPBxOyqY)lgn2bPLhh0IQMw7gcIelfB7nVrsOagcuOMTDA5XbTOQjOxh(0cmWqf0QyTTpM3Gm16eZ2ENsiaDmVbNsc(gBv9HkOxh(WYZLIi4reG95lyZBDL)IH9R2pE5NS74NSF5d)G)zhKvqoo(By5NpgTGUGCC830ciRyEdYv0dbk6cfds(FXOXoO6ahWXtjhuGK)xmD8gSaKfsFRLYghZBqVo8rPGhHRgO0NVG1IwVqD4JTk7y0cwRNY1BRQpFb96WhBv25lOxh(yRQpFb5Gwu1yRYoub)LQlumbTz22Xs432nLucFc6cYXXFdl)8XWFAb)LQlum44UUGGAetdkn9bTicKjg(eCkj4B6cfds(FXOXoOxh(02hQGCf9qGIUqXe0MzBhlHFB3usj8jyTO1lfqlQASvzhJwWErrToE5lONyrVUwq9XWoirWJWvdu2k40HYGnv2PAzcwlA9IPKGVXwLDmAbTLeRs6UTROOhcueCkj4B8bTkwrMyEdwaYsPWbY4sFbPaCCc61Hp4dz40Bbgy(cYAmVb96WhMsc(gF(cs4Gc(oeAfJwhbvh4aoEDHIbj)Vy0yhKvqoo(Buk4r4Qbk9X8guDGd44XYpF(c24ZPawt(cwaYQrcYeKEvUNmtca]] )

    storeDefault( [[Protection Primary]], 'displays', 20170625.203942, [[dWtBiaGEiYlvQYUivLTPuvZeLQzRKdl5Mij(TQ(gPk0YeQ2jj7LA3OA)qQFIedtugNuH6ZOKHIIbdjdhPoOu6OKQOogPCCHIfkflfLYIfPLt0dLk9uWJHYZfmrKKMkunzcz6kUieUkPkDzvUobBuPYwjvr2SOA7eQpkv0PrmniQ(UszKsf8mHsJweJhj1jjvULuHCnsv15fYTLQwlPk41qu2Ag3awrpKNV75dmrRZaf9IZUofcdtjzDdJygNAqwCwx3KddzUXq6IGesDU(nNAiIsEE4MUf9qEEWQmdutjppCt3IEippyvMHyeoHtKoSNdeKoRqEMHqYV1kilD883PgIr4eorDl6H88GBmerjppCdEjzDtWQmd6zHt4cg3knJBabVsxNi3yOfBiphnk2jHXkKBqv9Nbg5ph2qEoAuu9YpEGi(cgy7wxfoRINPTVwwwS6tZaGjj0Jbpwf34gqWR01jYngAXgYZrJIDsySs)guv)zGr(ZHnKNJgv3)xI(nEWaB36QWzv8mT91YYIvFAgamjHEm4XQynUbe8kDDICJHwSH8C0OyNegRI1GQ6pdmYFoSH8C0OaCdSDRRcNvXZ02xlllw9PzaWKe6XGhpgcj)gSrgSKweUXa1uYZd3Gxsw3eSkZab75aDHr4SSs)gMsY6MwowYln0qbhNcvytxNDa3qKvDuCKNzi)5JHwjPwOrPkP83mes(n8sY6MGBmGS0wowYlnGtHHnDD2bCdyFFAnmIr4udyf9qEElhl5LgAOGJtHkg6(0rOrH)gyK)Cyd55OrXij9LmYqi53aC3yigHt4OkrEyd55gytxNDa3axOxh2ZdwHCdb6BT2TQqs3F9sJBOSsZqQvAgyzLMbPvAEmes(TUf9qEEWngOMsEE4MwbzzvMHsqw4r0NHuH8Cdu9YlH14gd9f1TcZBvMbQPKNhUrhxebRMxgSkZqTOtki53yeJWknd1IoP6(9P1WigHvAguv)zGr(ZHnKNJgfJK0xYid1IoPAxBvuGrmcR0muRTkkWiMXngetcKuYImr4r0NHudyf9qEE7IWIBOlcfoc2miIeOxveEe9zOma0hgPweKQH8CR2FFdYIZ6WJOpdvkzrMidLGSOcHFUXqeL88Wn64Iiy18YGvzgqw6UNpabPZkT4gMsY6MDpFmWGJgfu8aAuQsk)ndmssFjJqJQBrpKNJgvRGSmyGG9C9W)9wPPFdYBzOlcfoc2meOV1A3Qcjo1qTOtk8sY6ggXiSsZWExukHlIWzHgfmrRZQ4gIr4eor64Iiy18YGBmes(nyJmyjTcZ7gdHKFRvyE3yykjRB298bMO1zGIEXzxNcHbQuut6f6rJcN0FwfBMHsqw645pEe9zivip3aGjj0Jbd1IoPAxBvuGrmJvAg6lQbCR0mqlj9LmA3ZhGG0zLwCd0Yd77tRPLHDRYmqlj9Lmsh2ZbcsNvipZqFrDlcRYmGxRJpOr1P8fOTkZWusw3WigHtnW2TUkCwfpttpMTVwS6tlE846VJnWij9LmcnQUf9qEUHPKSUjyGWfrWQ5LTCSKxAGnDD2bCd1IoPWljRByeZyLMHEcVvyERYmul6KQ73NwdJygR0mul6Kcs(ngXmwPziK8B64Iiy18YGBmGv0d557E(aeKoR0IBOwBvuGrmc3yiK8BTiCJHqYVXigHBmG99P1WiMXPgqw6UNpgyWrJckEankvjL)MHik55HB2RjyvhPzazP7E(at06mqrV4SRtHWqpHd4wLzykjRB298biiDwPf3qi53yeZ4gdyf9qE(UNpgyWrJckEankvjL)MHsqwa9Tw6OQvzgqWR01jYngcKE611sbHvXnerjppCtRGSSkZqi5327IsjCreoRGBmqnL88Wn71eSsZqpH3IWQyneJWjCTlclE)XhdygO2QmdIU8synTmSBGr(ZHnKNJgfvV8syngw)2jXQWTxtWPgkbz1YXsEPHgk44uOc7i2HBigHt4eT75dqq6SslUH0fbjK6C9BTRLtneJWjCI2Rj4gdXiqWqMEIeGjADgkdLGS0lNmgOxv0j9yd]] )


end
