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
            addAura( 't21_4pc_sacred_judgment', 253806, 'duration', 15 )

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
            return set_bonus.tier20_2pc == 1 and ( x - 1 ) or x
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
                if set_bonus.tier20_4pc > 0 then applyBuff( 'sacred_judgment' ) end
                if set_bonus.tier21_4pc > 0 then applyBuff( 't21_4pc_sacred_judgment', 15 ) end
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
            known = function () return equipped.ashbringer end,
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

    storeDefault( [[SimC Retribution: opener]], 'actionLists', 20171123.190542, [[dOdKfaGALQY6fsYUefBtiX(uQGzlP5dIUPqDBPANszVu7gX(f45Immj8BGdR4BIsdwqdhP6GIkxw1XiPJRuLwOqSuqAXiz5eEii8uOLrcRtPsmrLQQPQuMmPMokxeu60e9mLkvxhvTrLkYwbv2mQ02fv9yL8vHKAAkvOVlKAKkvkJtPsA0iL)krNeu1NbfUMsf15jrRuPkoeOOxJk2QEZyB63ik7qeec9mHKINjbKDjieq)KlmU)ZD4RmhXi0x)KUBkkuZQQQgLmQrrrH6UAexcjDMrJ5wmjGK8MBQEZiSKHQETJymhLSkzknsvbaDjxEHsJWt0Y1WacJea5gJbA4grB63OX20VXivaqheUt8cLgH(6N0DtrHAw1cJqFcWlwp5nZmcbTV4edY)(jmtzmgOBt)gnZnfEZiSKHQETJymhLSkzknsDr6coscmmcprlxddimsaKBmgOHBeTPFJgBt)gJCr6coscmmc91pP7MIc1SQfgH(eGxSEYBMzecAFXjgK)9tyMYymq3M(nAMB7U3mclzOQx7igXLqsNzeMbHPZkPae(ugM8cffLkOVcc3HGWcJ5OKvjtPXrSgYlzaH4eMr4jA5AyaHrcGCJXanCJOn9B0yB63yoXAipiCdieNWmc91pP7MIc1SQfgH(eGxSEYBMzecAFXjgK)9tyMYymq3M(nAMB7O3mclzOQx7igZrjRsMsJ7JxdJ(jmJWt0Y1WacJea5gJbA4grB63OX20VX9WRHr)eMrOV(jD3uuOMvTWi0Na8I1tEZmJqq7loXG8VFcZugJb620VrZCBN9Mryjdv9AhXiUes6mJFV8s60VotvoAHKKk5YluwYtQFs0UoiesidcfZ6zOQaGU8vUbHqczqimdcxaqvdIMKj6HZlbClNeTNYWt3yokzvYuAKQo6xc4wUp(etUUr4jA5AyaHrcGCJXanCJOn9B0yB63yK6OFqiGBq4E4tm56gH(6N0DtrHAw1cJqFcWlwp5nZmcbTV4edY)(jmtzmgOBt)gnZTO4nJWsgQ61oIrCjK0zg)E5L0PFDMQC0cjjvYLxOSKNu)KODDqiKqgekM1ZqvbaD5RCdcHeYGqygeUaGQgenjt0dNxc4wojApLHNUXCuYQKP0OwMxsEjTP3VWi8eTCnmGWibqUXyGgUr0M(nASn9BC)Y8sYdc3TP3VWi0x)KUBkkuZQwye6taEX6jVzMriO9fNyq(3pHzkJXaDB63OzUL1BgHLmu1RDeJ5OKvjtPXOhoVeWTCs0EYi8eTCnmGWibqUXyGgUr0M(nASn9BmQhopieWnimxI2tgH(6N0DtrHAw1cJqFcWlwp5nZmcbTV4edY)(jmtzmgOBt)gnZmJi9VKtvgvdtciULTWmBa]] )

    storeDefault( [[SimC Retribution: default]], 'actionLists', 20171123.190542, [[dyJ4daGEuPQDPq02iintGKztYnvu3Ms7eWEf7g0(vPrrqzyOWVvAWQy4OiheOofbvhJqpxslevYsjYIrPLtQhQGNcTmcSok0ebszQOIjJQMovxKOYHv1LrUof9nfXwjk2ScHTtboprvZdvQmnuP03jiESeJdivJMO0RvKojf0FbItl19ui9zuulsH6zOsXrmCcc8wki22H7rICDZA69cnEp80iEtLhe0Or8MkpCfuIu0xPaiGH4errrHosrHkGHiOhel6MjpyqWfVxynCcGy4euo4ZQi(WvqWSTQD5dQjwZPuqdH8D59vheUqk48YlZRbElfmiWBPGseR5ukOePOVsbqadXjImckr11uxOA4ep4GSuz68AazjOh2GZlpWBPGXdGGWjOCWNvr8HRGyr3m5b92s3d3DpcccMTvTlFWYRuG8fVxiiQU6bneY3L3xDq4cPGZlVmVg4TuWGaVLco8k19aU49cVhq1vpiynZ1GW3sJogB7W9irUUzn9EHgVNLjcs6XbLif9vkacyiorKrqjQUM6cvdN4bhKLktNxdilb9WgCE5bElfeB7W9irUUzn9EHgVNLjcs64bGBcNGYbFwfXhUccMTvTlFWYRuG8fVxiiQU6bneY3L3xDq4cPGZlVmVg4TuWGaVLco8k19aU49cVhq1v)EeMOWdcwZCni8T0OJX2oCpsKRBwtVxOX7PSRIFfcSooOePOVsbqadXjImckr11uxOA4ep4GSuz68AazjOh2GZlpWBPGyBhUhjY1nRP3l049u2vXVcbwJhaUnCckh8zveF4kiy2w1U8blVsbYx8EHGO6Qh0qiFxEF1bHlKcoV8Y8AG3sbdc8wk4WRu3d4I3l8Eavx97ryceEqWAMRbHVLgDm22H7rICDZA69cnEpmtqs)(QRJdkrk6RuaeWqCIiJGsuDn1fQgoXdoilvMoVgqwc6Hn48Yd8wki22H7rICDZA69cnEpmtqs)(QRXJhezIk9RAU)9EHbycJ4ja]] )

    storeDefault( [[SimC Retribution: precombat]], 'actionLists', 20171123.190542, [[b4vmErLxt5uyTvMxtnvATnKFGjvz0jxAIvhDP9MB64hyWjxzJ9wBIfgDEnfrLzwy1XgDEjKxtjvzSvwyZvMxojdmXCtmXeJnUeJnYatm441utnMCPbhDEnLxtf0y0L2BUnNxu5LtX4fvEnvrUfMySvgzEjKxtfKyPXwA0LNxtb3B0L2BU51uj5gzPnwy09MCEnLBV5wzEnvtVrMvHjNtH1wzEnLxt5uyTvMxtb1B0L2BU51ubj3zZ51uUfwBL1JiVXgzFDxyYjIxtjvzSvwyZvMxojdmXCtmW41usv2CVvNCJv2CErLx051udHwzJTwtVzxzTvMB05LyEnvtVrMtH1wzEn1BSr2x3fMCErNx051utbxzJLwySLMEHrxAV5MxoDdmErNxEb]] )

    storeDefault( [[SimC Retribution: cooldowns]], 'actionLists', 20171123.190542, [[du0LpaqivelIujztKK(KksYOOGoffyvQi1UuPHHQCmizzuONrQunnvK4Asf12KkI(gPIXrQeCoPIW6ivcnpuv4EOQ0(iv5GKelevvpKuvtKuP4Isf2OurAKOQO6Kuu9suve3uvStsmuvKulvcEkvtLICvsLuBLIYxjvkTxWFLQgSIdlAXq8ybtMsxgzZKYNLOrRcNwOvJQI0RvrnBv1TrLDJYVHA4qQJtQeTCcpxstNORlLTts9Dj05LkTEuvuMVQ0(vAafycCLKJa3JC6VtbskIinzeZ0f3jGXFlUiRcUUH0Y2xc8dEb6tzLafJ8qPdkug19lVoHrJgncUher0sWbxLGmIzvWeOGcmbEhSe5twGFW9GiIwcoPlBr0Oj7nRhuTxI7TTQChv3XIL3I5zQhR1N1dQEfexgz1D4JDkd2Do9og359Dhd3XWDqAAA3GOvtlDBO3r1DqAAA3GOvtlDBO3Hp2Pmy3507yCN33DqAAA3unXkJSY(IIuECBO3r1DqAAA3unXkJSY(IIuECBO3Hp2Pmy3507yChd259Dhd35KDYGmIz3unXkJSY(IIuECjwI8j7oQUZj7KbzeZUbrRMw6sSe5t2DmyhdaxfK4pk7cUgwusArIzR9AjIigsjwaU5mBmKsSaCgMrG)GTMLcLKJahCLKJaVtXIsslsm7PQUtNMiIyiLyb4fOpLvcumYdLoO4bEbQIBIavbtGeC9pOW5hSAIJysab8hSvj5iWbjOyembEhSe5twGFW9GiIwcUH7G000UPAIvgzL9ffP842qVZ77oinnTBq0QPLUn07O6oinnTBq0QPLUvzgoVJE8DhuDEN33Dcy83IlYUbrRMw6kiUmYQ7O3o82rVDmYBhv35KDqAAA3GOvtlDBO3XGDEF3XWDozNmiJy2nvtSYiRSVOiLhxILiFYUJQ7CYozqgXSBq0QPLUelr(KDhdaxfK4pk7cUvKTYdzpwRVIB)k4MZSXqkXcWzygb(d2AwkusocCWvsocCDJiBLhYDWA7442VcEb6tzLafJ8qPdkEGxGQ4MiqvWeibx)dkC(bRM4iMeqa)bBvsocCqck6oyc8oyjYNSa)G7breTeCd3bPPPDt1eRmYk7lks5XTHEN33DqAAA3GOvtlDBO3r1DqAAA3GOvtlDRYmCEh947oO68oVV7eW4VfxKDdIwnT0vqCzKv3rVD4TJE7yK3oQUZj7G000UbrRMw62qVJb78(UJH7CYozqgXSBQMyLrwzFrrkpUelr(KDhv35KDYGmIz3GOvtlDjwI8j7ogaUkiXFu2fCUy5HShR1FwGRTk4MZSXqkXcWzygb(d2AwkusocCWvsoc8Ny5HChS2o8jcCTvbVa9PSsGIrEO0bfpWlqvCteOkycKGR)bfo)GvtCetciG)GTkjhboibLtbmbEhSe5twGFW9GiIwcUH7G000UbrRMw62qVJQ7G000UbrRMw6wLz48o6X3Dq15DEF3jGXFlUi7geTAAPRG4YiRUJE7WBh92Pmy3507yChd259Dhd3bPPPDt1eRmYk7lks5XTHEN33Dcy83IlYUPAIvgzL9ffP84kiUmYQ7O3o82rVDkd2Do9og3XGDEF3XWDozNmiJy2nvtSYiRSVOiLhxILiFYUJQ7CYozqgXSBq0QPLUelr(KDhdaxfK4pk7cEfnfKKOhR1Jqsr2n)GBoZgdPelaNHze4pyRzPqj5iWbxj5iWD0uqsIDWA7Wpjfz38dEb6tzLafJ8qPdkEGxGQ4MiqvWeibx)dkC(bRM4iMeqa)bBvsocCqckDgmbEhSe5twGFW9GiIwcostt7MQjwzKv2xuKYJBd9oVV7G000UbrRMw62qVJQ7G000UbrRMw6wLz48o6X3Dq15DEF3XWDozNmiJy2nvtSYiRSVOiLhxILiFYUJQ7CYozqgXSBq0QPLUelr(KDhdaxfK4pk7cEJdrK)EomMv(ZOAQcU5mBmKsSaCgMrG)GTMLcLKJahCLKJaxxZHiY)opymR8Nr1uf8c0NYkbkg5Hshu8aVavXnrGQGjqcU(hu48dwnXrmjGa(d2QKCe4Geu6KGjW7GLiFYc8dUkiXFu2f8wL6JsIRcU5mBmKsSaCgMrG)GTMLcLKJahCLKJaxxxPDmxsCvWlqFkReOyKhkDqXd8cuf3ebQcMaj46FqHZpy1ehXKac4pyRsYrGdsqrhWe4DWsKpzb(b3dIiAj4gUdstt7I8Xy7VvL3g6DEF3bPPPDt1eRmYk7lks5XTHEN33DqAAA3GOvtlDBO3r1DqAAA3GOvtlDfexgz1D4JDm25DEF3rMIssELroQxI7TrAh(GV7Ck82XaWvbj(JYUGJglJyg4MZSXqkXcWzygb(d2AwkusocCWvsoc8tnwgXmWvruwbNLCeF1v4VTVyk0vGxG(uwjqXipu6GIh4fOkUjcufmbsW1)GcNFWQjoIjbeWFWwLKJah)T9ftbibfDbWe4DWsKpzb(bxfK4pk7coYhJT9AnrxWnNzJHuIfGZWmc8hS1SuOKCe4GRKCe48)Xy7oDAt0f8c0NYkbkg5Hshu8aVavXnrGQGjqcU(hu48dwnXrmjGa(d2QKCe4Geu6eGjW7GLiFYc8dUkiXFu2fCesujX5iReCZz2yiLyb4mmJa)bBnlfkjhbo4kjhbo)KOsIZrwj4fOpLvcumYdLoO4bEbQIBIavbtGeC9pOW5hSAIJysab8hSvj5iWbjOGIhyc8oyjYNSa)G7breTeCd3bPPPDdIwnT0THEN33DqAAA3unXkJSY(IIuECBO3XGDuDNd8VBpACrsCdnHGyYD47og3r1DmCNag)T4ISlYpTupwRNpTvLXaDfexgz1D0BNYGDN33Dcy83IlYU2O6iJ6psoosCfexgz1D0BNYGDhdaxfK4pk7cEkcjJ6LyHGysWnNzJHuIfGZWmc8hS1SuOKCe4GRKCe4QicjJ2XewiiMe8c0NYkbkg5Hshu8aVavXnrGQGjqcU(hu48dwnXrmjGa(d2QKCe4GeuqHcmbEhSe5twGFWvbj(JYUGFG)D7lks5b4MZSXqkXcWzygb(d2AwkusocCWvsocC(C8V7o6wrkpaVa9PSsGIrEO0bfpWlqvCteOkycKGR)bfo)GvtCetciG)GTkjhboibfugbtG3blr(Kf4hCvqI)OSl41Ji9T9yTE1eRKswGa3CMngsjwaodZiWFWwZsHsYrGdUsYrG7hr6B3bRTJzeRKswGaVa9PSsGIrEO0bfpWlqvCteOkycKGR)bfo)GvtCetciG)GTkjhboibfu6oyc8oyjYNSa)GRcs8hLDbpvtSYiRSVOiLhGBoZgdPelaNHze4pyRzPqj5iWbxj5iWvrnXkJSYD0TIuEaEb6tzLafJ8qPdkEGxGQ4MiqvWeibx)dkC(bRM4iMeqa)bBvsocCqckOofWe4DWsKpzb(b3dIiAj4h4F3E04IK4gAcbXK7OhF3r3359Dhd3XWDiDzlIgnzV)yAfrwTxRj623yFkRhKDN33DezGUiFm22tFTDmyhv35a)72JgxKe3qtiiMCh947og3XaWvbj(JYUGheTAAjWnNzJHuIfGZWmc8hS1SuOKCe4GRKCe46lA10sGxG(uwjqXipu6GIh4fOkUjcufmbsW1)GcNFWQjoIjbeWFWwLKJahKGeChnfI5pYNLYiMbk6WdKaa]] )

    storeDefault( [[SimC Retribution: finishers]], 'actionLists', 20171123.190542, [[d8dshaGAsPwpkvAtqk7IuTnHQSpuQAzcLdR0SHy(Iu3eL8jHu9nsr3dsvzNK0Eb7wL9JyuIOggL04GuLonu3wHbJ0WfvhsK4uIKoMI64qQQwOqYsPuTysSCIEiLINs1JPyDcP0efQyQuIjJQPRQlsk5VkYZqPIRJIdsP0wrPSziX2fLNlyvKc(Sq8DivMMqvnpHumAiPXtk0jfHUS01eQ05frwjKQ43eETiyygSaUw3QGuoOaECkkldYdrbUNxdErWS7(yXbQAAfC7fPBOGAmRZAopphp954fZ6m6fC3iX5p4GBR5XIlawa1zWc4ADRcs5quG7gjo)bFnpoRt96a3aHgnOpcLDiu0i0KjuJqGWfO701MHhz071LDS4lqOrdHgXWjunqOXxpwCj00PjuEvyqbfDTz4rg9EDzhl(cek7j0igoHQbcn(6XIlHMk42QGrWFsGxnwdZJf3uO33ZuWt84yZ(cj4N4k4SeC2wP6ok4GRUJcUwASgMhloc1799mfC7fPBOGAmRZAoBfC7niyKMgalWdUnOwtcSezD07bfWzj4Q7OGdpOgdSaUw3QGuoef4UrIZFW1MHhz07NezvkX8sOOrOzReVkivNhMmB4xfKsOOrOkmOGIohNHVoLZiZfHQZKdUTkye8Ne4CCg(6u4fYb4jECSzFHe8tCfCwcoBRuDhfCWv3rbpo4m8vc1FHCaU9I0nuqnM1znNTcU9gemstdGf4b3guRjbwISo69Gc4SeC1DuWHhuzhWc4ADRcs5quG7gjo)bxBgEKrVFsKvPeZlHIgHMTs8QGuDEyYSHFvqkHIgHMmHMcH(lsVx3izclV69wfKYj00Pj0ui018yXPBKmHLx9ERcs5eA60eQriq4c0D6gjty5vx2XIVaHYEcnIHtOAGqJrOPcUTkye8Ne4CCg(6u4fYb4jECSzFHe8tCfCwcoBRuDhfCWv3rbpo4m8vc1FHCqOjpNk42ls3qb1ywN1C2k42BqWinnawGhCBqTMeyjY6O3dkGZsWv3rbhEqn(GfW16wfKYHOa3nsC(dU2m8iJE)KiRsjMxcfncvHbfu054m81PCgzUiuDMCcfncnfcTOFgCEE56OdvCiVYjbktpQD62hvzzx8aCBvWi4pjW1Mj8yZkdtz9I09mf8epo2SVqc(jUcolbNTvQUJco4Q7OGJEycp2SYOhiu26fP7zk42ls3qb1ywN1C2k42BqWinnawGhCBqTMeyjY6O3dkGZsWv3rbhEqnUGfW16wfKYHOa3nsC(dU2m8iJE)KiRsjMxcfncvHbfu054m81PCgzUiuDMCWTvbJG)Ka)7ihzLHPSk5yZdEIhhB2xib)exbNLGZ2kv3rbhC1DuWT0roYkJEGqzRso28GBViDdfuJzDwZzRGBVbbJ00aybEWTb1AsGLiRJEpOaolbxDhfC4b14bwaxRBvqkhIcC3iX5p4AZWJm69tISkLyEju0i0Kj0ui0Fr696gjty5vV3QGuoHMonHMcHUMhloDJKjS8Q3BvqkNqtNMqncbcxGUt3izclV6Yow8fiu2tOrmCcvdeAmcnvcfncnzcnfc9xKEVE1ynmpwCtHEFpt17TkiLtOPttOgHaHlq3PxnwdZJf3uO33ZuDzhl(cek7j0igoHMk42QGrWFsG)DKJSYWuwLCS5bpXJJn7lKGFIRGZsWzBLQ7OGdU6ok4w6ihzLrpqOSvjhBEcn55ub3Er6gkOgZ6SMZwb3EdcgPPbWc8GBdQ1Kalrwh9EqbCwcU6ok4Wdp4Q7OG74HneQ9(sScZJfx0sOOGpCa1kdWdaa]] )

    storeDefault( [[SimC Retribution: generators]], 'actionLists', 20171123.190542, [[duKvzaqijrweOkTjfYOqfofQOvjPkZcuiSlqggQYXuKLjepdvLmnqrxtHQTbQIVjjmojr5CsIQ1bkyEkQ6EOQAFGshKiAHsQ8qqLjIQs5IkQmsuvQoPkIvQI0mbfQBsrTtHAPcPNk1uvu2QcLVckeTwqH0Ej9xIAWIoSslMcpwWKL4YiBwbFMinAv40OSAuv8AjLzRs3wvTBi)gQHJkDCjv1Yj8CknDGRRkBxf13LKgpOQ68eH1dQkZNISFQwN0zAphAnUurn0MVrd77c060U5sb2EzW3cyyKgxbpTJsxATKghH3uftttWd0e8eH3uLPDhemUaT1wYaGHrwDMgpPZ0Eo0ACPIwN2DqW4c0Eda2zsMq0NrwpHLFpJ4PjtE6NYHNgVHbiByfxciZq1)XSmawyLj4N7tiDbmmcYc2qnpHLFpJu5EoYt)up90tp5WtQ(pgxUubAThKvgGLlplWZrE6N6PNE6PNE6PNC4zbdGQU1iz8G8ApileGfQXqs9CKNa2N8ewpN45PjtEwWaOQBnsgpiV2dYcjO)YqwpN3tPHINC6PFQNE6PNC6PjtE6N6PNE6jhEA8ggGSHvCjGmdv)hZYayHvMGFUpH0fWWiilyd18ew(9msL75ip9t90tp90tp90to80p1tp90tp90tp90tp9KdpRKNBaWWiOG4z3cbrO14sfph5zL8CdaggbTNjKugsQCvXcoGi0ACPINC6PjtE6N6PNE6PNE6PNE6PNEA8ggG2ZeskdjvUQybhqpUEAYKN(PE6PNE6PNE6PNE6PNgVHbOG4z3cb9465ipnEddqbXZUfcYc2qnpHLFpNg3ttM80p1tp90tp90tp90tp9mGX3cUkckiE2Tqqc6VmK1ty9CACph5zL804nmafep7wiOhxp9t90tp90tp90to90Kjp9t90tp9mGX3cUkcAptiPmKu5QIfCajO)YqwpH1ZPX9Ktph5NwjpP6)yC5sfO1EqwzawU8Sap5uBjnyxgqcTpVc2ACjTpbvyHfGfAJWisBZ4YyRiE)K2fRCyTG14sAhVFs7gGfKNJT3hPTKcPwTr7N4VyLdRfSgxcgX59(i(3aGDMKje9zKfw(JyYehgVHbiByfxciZq1)XSmawyLj4N7tiDbmmcYc2qny5psLpIdQ(pgxUubAcMWKVgVYgXrbdGQU1iz8G8ApileGfQXqshbyFc2jEMmvWaOQBnsgpiV2dYcjO)Yq25LgkCYPjtCy8ggGSHvCjGmdv)hZYayHvMGFUpH0fWWiilyd1GL)iv(iomEddq7zcjLHKkxvSGdOhxtMmEddqbXZUfc6XDKXByakiE2TqqwWgQbl)tJBYuaJVfCveuq8SBHGe0FzilStJpQsgVHbOG4z3cb94YPjtbm(wWvrq7zcjLHKkxvSGdib9xgYc704MmXrL2aGHrqbXZUfcIqRXLkJQ0gammcAptiPmKu5QIfCarO14sfo5CuLO6)yC5sfOjyct(A8kJtTJsxATKghH3uft80okzXprGS6mfOnChuOMz8z6tiGAOTzCjE)K2kqJJOZ0Eo0ACPIwN2DqW4c0MdpnEddqbXZUfc6X1ZrEA8ggGcINDleKfSHAEoVNtJ7PjtEA8ggGUSTiyiR8WtiH8dDP1EqfOhxp50ttM8KdpxbGnSba0ApiRmalV2dYcrO14sfph5zaJVfCveu1TgjJhKx7bzHe0FziRNZ7P0qXZ65zep5uBjnyxgqcTd79kVbadJKVmlq7tqfwybyH2imI02mUm2kI3pPT2X7N0gU9E9uYaGHrEcJzwG2skKA1gTFIF4TzF48mkbemJhGHrWGNdmeZEqcl8QDu6sRL04i8MQyIN2rjl(jcKvNPaTH7Gc1mJptFcbudTnJlX7N0UzF48mkbemJhGHrWGNdmeZEqcRc0y(sNP9CO14sfToT7GGXfOnyVecarWpfEaggjBjeGqbcIqRXLkEoYto8mGX3cUkcIpVI0pHaqc6VmK1Z59uAO4z98eMqrg3ttM8SqgVHbi(8ks)ecajO)YqwpH1tPHIN1ZtycfzCp50ZrEgW4BbxfbrWpfEaggjBjeGqbc6X1ttM804nmav9Gz5scz8Gm4GKrl4qqWh7d9465ipnEddqvpywUKqgpidoiz0coee8X(qc6VmK1Z59uAO4z98CcACTL0GDzaj0oS3R8gamms(YSaTpbvyHfGfAJWisBZ4YyRiE)K2AhVFsB4271tjdagg5jmMzbEYXeNAlPqQvB0(j(H3M9HZZOeqWmEaggbdEoWqm7bjSWR2rPlTwsJJWBQIjEAhLS4NiqwDMc0gUdkuZm(m9jeqn02mUeVFs7M9HZZOeqWmEaggbdEoWqm7bjSkqJHPot75qRXLkADA3bbJlq7cgarWpfEaggjBjeGqbccWc1yiPEoYZcgarWpfEaggjBjeGqbcsq)LHSEoVNsdfpRNNr8CKNfY4nmaXNxr6Nqaib9xgY658Eknu8SEEgXttM80sazdm6zHamsezsgMCdEcRN80wsd2LbKqB(8ks)ecO9jOclSaSqBegrABgxgBfX7N0w749tAF6Ri9tiG2rPlTwsJJWBQIjEAhLS4NiqwDMc0gUdkuZm(m9jeqn02mUeVFsBfOXJRZ0Eo0ACPIwN2DqW4c0(aFLqMlUkjGcpHGqapNNFpJ45ip5WtlbKnWONfcWireEYr4g8ewp55PjtEAjGSbg9SqagjIWtgMCdEcRN88KtTL0GDzaj024UfsgpiZNNfWcK2NGkSWcWcTryePTzCzSveVFsBTJ3pPDD3TqEIh880NfWcK2rPlTwsJJWBQIjEAhLS4NiqwDMc0gUdkuZm(m9jeqn02mUeVFsBfOXWJot75qRXLkADA3bbJlq7d8vczU4QKak8eccb8CE(9mINJ8KdpTeq2aJEwiaJer4jhHBWty9KNNMm5PLaYgy0ZcbyKicpzyYn4jSEYZto1wsd2LbKq7c7mdrYh7)tcTpbvyHfGfAJWisBZ4YyRiE)K2AhVFsB(g7mdrEY33)NeAhLU0AjnocVPkM4PDuYIFIaz1zkqB4oOqnZ4Z0Nqa1qBZ4s8(jTvGgxHot75qRXLkADA3bbJlqBo88aFLqMlUkjGcpHGqapNNFp55PjtEEGVsiZfxLeqHNqqiGN875KNJ8Kdpdy8TGRIGmUBHKXdY85zbSabjO)YqwpH1tPHINMm5zaJVfCveuHDMHi5J9)jbKG(ldz9ewpLgkEYPNMm55b(kHmxCvsafEcbHaEYVNr8CKNC4jhEgW4BbxfbbF0EHchRqkzLheBaWWO965887jpi4zCpnzYZagFl4QiOG4z3cjKTabRgbfowHuYkpi2aGHr71Z553tEqWZ4EYPNC6jNAlPb7YasOD1TgjJhKx7bz1(euHfwawOncJiTnJlJTI49tARD8(jTHrU1ipXdEkP9GSAhLU0AjnocVPkM4PDuYIFIaz1zkqB4oOqnZ4Z0Nqa1qBZ4s8(jTvGgxz6mTNdTgxQO1PDhemUaTpWxjK5IRscOWtiieWZ553t(YZrEwjpTeq2aJEwiaJer4jdtUbpH1tEAlPb7YasOTXDlKmEqMpplGfiTpbvyHfGfAJWisBZ4YyRiE)K2AhVFs76UBH8ep45PplGfip5yItTJsxATKghH3uft80okzXprGS6mfOnChuOMz8z6tiGAOTzCjE)K2kqJRCDM2ZHwJlv060UdcgxG2h4ReYCXvjbu4jeec45887jF55ipRKNwciBGrpleGrIi8KHj3GNW6jpTL0GDzaj0UWoZqK8X()Kq7tqfwybyH2imI02mUm2kI3pPT2X7N0MVXoZqKN899)jHNCmXP2rPlTwsJJWBQIjEAhLS4NiqwDMc0gUdkuZm(m9jeqn02mUeVFsBfOXt80zAphAnUurRtBjnyxgqcT5ZRi9tiG2NGkSWcWcTryePTzCzSveVFsBTJ3pP9PVI0pHaEYXeNAhLU0AjnocVPkM4PDuYIFIaz1zkqB4oOqnZ4Z0Nqa1qBZ4s8(jTvGgpnPZ0Eo0ACPIwN2DqW4c024nmavyNzisM7tWfBjOhxTL0GDzaj0oS3R8gamms(YSaTpbvyHfGfAJWisBZ4YyRiE)K2AhVFsB4271tjdagg5jmMzbEYreo1wsHuR2O9t8dVn7dNNrjGGz8ammcg8CGHy2dsyHxTJsxATKghH3uft80okzXprGS6mfOnChuOMz8z6tiGAOTzCjE)K2n7dNNrjGGz8ammcg8CGHy2dsyvGgpfrNP9CO14sfToT7GGXfODaJVfCvee8r7fkCScPKvEqSbadJ2RNWYVNtqWZ4EoYZd8vczU4QKak8eccb8CE(9eMEoYto8mGX3cUkcY4UfsgpiZNNfWceKG(ldz9ewpLgkEwppJ4PjtEgW4BbxfbvyNzis(y)FsajO)YqwpH1tPHIN1ZZiEYPNJ8SqgVHbi(8ks)ecajO)YqwpH1tPHI2sAWUmGeAdF0E1(euHfwawOncJiTnJlJTI49tARD8(jTHrP9QDu6sRL04i8MQyIN2rjl(jcKvNPaTH7Gc1mJptFcbudTnJlX7N0wbA8eFPZ0Eo0ACPIwN2DqW4c0oGX3cUkckiE2TqczlqWQrqHJviLSYdInayy0E9ew(9CccEg3ZrEEGVsiZfxLeqHNqqiGNZZVNW0ZrEYHNbm(wWvrqg3TqY4bz(8SawGGe0FziRNW6P0qXZ65zepnzYZagFl4QiOc7mdrYh7)tcib9xgY6jSEknu8SEEgXto9CKNfY4nmaXNxr6Nqaib9xgY6jSEknu8CKNC4jyVecajvqlGeY85vK(jeaIqRXLkEAYKNvYtlbKnWONfcWireEYWKBWty9KNNJ8eSxcbGahK8atqwz8GmFEwalqqeAnUuXto1wsd2LbKq7G4z3cjKTabRgP9jOclSaSqBegrABgxgBfX7N0w749tAdN4z3cj8Sbcwns7O0LwlPXr4nvXepTJsw8teiRotbAd3bfQzgFM(ecOgABgxI3pPTc04jyQZ0Eo0ACPIwN2sAWUmGeAhWilfelGHrAFcQWclal0gHrK2MXLXwr8(jT1oE)K2WHrwkiwadJ0okDP1sACeEtvmXt7OKf)ebYQZuG2WDqHAMXNPpHaQH2MXL49tARanEACDM2ZHwJlv060UdcgxG2u9FmUCPceFEwalqYsx4J8CKNGviLaqh0EbhqCdapHLFpRyCph55b(kHmxCvsafEcbHaEop)EctTL0GDzaj0(y)FsiJhK5ZZcybs7tqfwybyH2imI02mUm2kI3pPT2X7N0MVV)pj8ep45PplGfiTJsxATKghH3uft80okzXprGS6mfOnChuOMz8z6tiGAOTzCjE)K2kqJNGhDM2ZHwJlv060wsd2LbKq7WEVYBaWWi5lZc0(euHfwawOncJiTnJlJTI49tARD8(jTHBVxpLmayyKNWyMf4jh8fNAlPqQvB0(j(H3M9HZZOeqWmEaggbdEoWqm7bjSWR2rPlTwsJJWBQIjEAhLS4NiqwDMc0gUdkuZm(m9jeqn02mUeVFs7M9HZZOeqWmEaggbdEoWqm7bjSkqJNQqNP9CO14sfToTL0GDzaj0g(O9Q9jOclSaSqBegrABgxgBfX7N0w749tAdJs71toM4u7O0LwlPXr4nvXepTJsw8teiRotbAd3bfQzgFM(ecOgABgxI3pPTc04PktNP9CO14sfToTL0GDzaj0oiE2TqczlqWQrAFcQWclal0gHrK2MXLXwr8(jT1oE)K2WjE2TqcpBGGvJ8KJjo1okDP1sACeEtvmXt7OKf)ebYQZuG2WDqHAMXNPpHaQH2MXL49tARafOD8(jTB2hopJsabZ4byyem4PucrIfGfwfOk]] )


    storeDefault( [[Retribution Primary]], 'displays', 20170625.203942, [[d4ZpiaGEvvEPQQSlvvv2gkP0HLmtkHXPQQQzRKLrjDtusopP62K0PHANuSxXUjSFvXprKHjf)gYLvzOOQbRknCK6GsvhfLu1XOuhNs0cLslvQ0IrLLt0djrpf8yuSosPAIkvXurYKrPMUIlQQCvPcEMsv66iSrLkBvQqTzQ02jfFuQOpJOMgPeFxPmssj9nsPmAQy8OeNKeULuHCnvvL7HskEovTwusLxRuvh7qfGPOhmsSdjgy0xxasDGYcfMVatjjFdVg(WfqwcYNsNJz)0gGBH)9RZfAlCb0j566VrzrpyKWhttawi566VrzrpyKWhttaljoIJTcgKaW)Uy0staVdARNqwkeUOWfWsIJ4yRSOhms4tBaDsUU(BOkj5B8X0eG1tCeNpuXyhQaFIIBDStBGEMbJepVwG9tmwdyk1laGvv(829gjMJyWiH2FEPLhdsLRMaDV1v(lgRn2ARXUPjaWiX0tGbRESMMmXynub(ef36yN2a9mdgjEETa7NySdyk1laGvv(829gjMJyWiH2FEzFUfXAc09wx5VyS2yRTg7MMmzc4DqBWgEyC6)sBawi566VHQKKVXhttamdsa0fdwqoM)fykj5B6fmoizGwsuuKyvxfDQvQa6X0rw1staxKyc0lX1651usjAlG3bTrvsY34tBG956fmoizaks8Dv0PwPcWGu5QHxZx4cWu0dgj6fmoizGwsuuKyvaLiA9NxkuaEjAoMbJepV8sSAj1d4DqBavAdyjXrC7blpMbJeb6QOtTsfqqOQGbj8XOLaE6BT2TkVJs0cjdvGkg7aCXyhGCm2bKXyNjG3bTPSOhms4tBawi566VPNqwX0eOiKfLo9fGJW1nWEo3IynPnGAXspXGIPjalKCD93OqWgZuds6JPjqTODkWbTXR5lg7a1I2PuIu5QHxZxm2bmL6fO7nsmhXGrINxEjwTK6bQfTt1V2kDpVMVySduRTs3ZRHpTb0G9yo8cp6u60xaUamf9GrI(fMSiGYpd1x3aSXE6vPtPtFbQaa9XGRf(xnyKigT1eqwcYhLo9fO4Wl8OhOiKfRWIlTb0j566VrHGnMPgK0httG952HedG)DXyBnWusY3SdjMa8upVqj8pVMskrBb4Ly1sQ)8QSOhms882tiRabWmibRdHuJX(FbK3kGYpd1x3aE6BT2TkVt4culANIQKKVHxZxm2b(705Wc2yb5Nxy0xxmwdyjXrCSviyJzQbj9PnG3bTbB4HXPNyqPnG3bT1tmO0gykj5B2Hedm6RlaPoqzHcZxawvSGvjuFEPWQxm7TjqrilfcxeLo9fGJW1naWiX0tGa1I2P6xBLUNxdFm2bulwaQySdqlXQLuFhsma(3fJT1a0YJbPYvtpVfbaSQYN3U3iXCedgj0(ZlT8yqQC1eGwIvlPUcgKaW)Uy0sta1IL(VyAcqvRtmpVDkre0Xyhykj5B418fUaEh02FNohwWgli7tBaEjwTK6pVkl6bJebMss(gFaSGnMPgKSxW4GKb6QOtTsfqfl6jgumnbyk6bJe7qIbW)UySTgOw0oLsKkxn8A4JXoqTODkWbTXRHpg7aEh0McbBmtniPpTbQfTtrvsY3WRHpg7a1AR098A(sBaVdAR)lTb8oOnEnFPnadsLRgEn8HlW(C7qIjap1Zluc)ZRPKs0waDsUU(B(R1hthzhyFUDiXaJ(6cqQduwOW8fqflaQyAcmLK8n7qIbW)UySTgW7G241WN2amf9GrIDiXeGN65fkH)51usjAlqrilG(wlf7jMMaFIIBDStBapwLED9K(IXAaDsUU(B6jKvmnb6ERR8xmwBS1wdR1EV)NTvRw)3)hGfsUU(B(R1hJDavSO)lM9gWsIJ46xyYc1tmbycWsmnbyFUfXA65TiaGvv(829gjMJyWiH2FEzFUfXAcSqBNKP83FT(WfOiKvVGXbjd0sIIIeRS4BhvaljoIJ9oKya8VlgBRb4w4F)6CH26xRWfWsIJ4y)xRpTbSKaZSFhJ9WOVUavGIqwDqGNa0Rs)Kzsa]] )

    storeDefault( [[Retribution AOE]], 'displays', 20170625.203942, [[deeoiaqiuvL2KuO6wsHYUuIQHPQ6yezzOkpdLOPPeLRPQW2qjuFdvv14qvL6COeY6Kc5EOQkoOuAHQspKOAIOeCrL0gvcFujYijL0jjfVeLuZKuQBIsYoP4NazOKQJIQkAPsrpfAQO4QKsSvuvH1IQkzVIbRuDyjlgjpgvMmk1LvzZuXNbQrtPonIxRQOzlv3Ms2nHFdA4i1XLcwojpNQMUIRdy7eLVRkgpQkNNkTEvL2Vs5ifMGCf9qGIfqXGJB)ccslmARXSgCkf4B0LPhQGQsa(KBFCFM3GuDY3Vl1HpHkOlihh)nYl6Haf(y(dYhihh)nYl6Haf(y(dsRiwLYvdhuGKVxml7pO3g(0cOknchyOc2aWbCSLx0dbk85nOlihh)nmLc8n(y(dYpboGZhMyKctWvrr1p25nyl3qGITDTj(jgEbnL1fejwY32BEJIqbmeOOrB70QJdArvtWMx)k)fdVFPpKKwopEsbrofHEcoeRJ)8NjgEHj4QOO6h78gSLBiqX2U2e)eJuqtzDbrIL8T9M3OiuadbkA02o7ZPa6tWMx)k)fdVFPpKKwopEszYe0BdFWhYWz3UgQG8bYXXFdtPaFJpM)GeoOaPloIaCmFeCkf4BAfC2qvWxqmmGyvtnlPvMGUX0ysSOpc6aftWwfP6B7MsPGpbz95sreSjcWB7442Vy4f8tQwbNnufKbKEtnlPvMGCqlQA0LTgQGCf9qGIwbNnuf8feddiwfuoK2DBNbgS5nkcfWqGIT9wqRb92WhKjVbBa4aowGOoUHafbBQzjTYeuayPHdk8XSSGE6R3x0lVTCyhQctWkgPGQyKccogPGuXiLjO3g(iVOhcu4ZBq(a544VPfqvX8hSaufJl9fKcWXjOvXxlWaJ5py1PTR2(t561LTgJuWQtBxOn8rx2AmsbRoTDjhArvJUS1yKcAkRlyZBuekGHafB7TGwd2aaH7t(bXJJB)csfS6pLRxxMEEdkJ4juKozCzCPVGub5k6HafTDcyrq5RgM1Mbzt809YLXL(cYfKfoNcOp5nOQeGpgx6lyrr6KXnybOkwrexEdI0hhP6KV1qGIy4))GFsTakgK89IrIxq(a544VrJGnHRgOYhZFqDfXQuUB7Yl6HafB7TaQkyqp917l6L3oubvxpO8vdZAZGtPaFZcOycQZSTJLWVTBkLc(eS602ftPaFJUS1yKcs4Gc(feAfJ0hbBa4ao2AeSjC1av(8g0BdFykf4B85niFX8hCkf4BwafdoU9liiTWOTgZAqwv8rSaS22ziwxmS8pO3g(GpKHZUfyG5niYPi0tqpraUFno)TagyWQtBxT9NY1RltpgPGfGQ0iCGmU0xqkahNG0kIvPCxafds(EXiXliT64Gwu10QRDqKyjFBV5nkcfWqGIgTTtRooOfvnbTk(qMy(dAv81UgZFqMQFIzBFjfeGoM)GtPaFJUS1qf0BdFy95sreSjcW(8gS51VYFXW7xI))zXsSC5s84X7d(DWQtBxmLc8n6Y0JrkirWMWvdu1k4SHQGn1SKwzcYv0dbkwafds(EXiXlydahWXwdhuGKVxml7py1PTl5qlQA0LPhJuqVn8rJGnHRgOYN3GvN2UqB4JUm9yKcw9NY1RlBnVb92WhDzR5nO3g(0UgQGCqlQA0LPhQGFsTakMG6mB7yj8B7MsPGpbDb544VH1V(yAmPGFsTakgCC7xqqAHrBnM1GwebYedldoLc8nlGIbjFVyK4f0BdF0LPN3GCf9qGIfqXeuNzBhlHFB3ukf8jybOkK(6DnSqm)bxffv)yN3GEIfD)AbTgdVGUGCC830cOQy(dYhihh)nS(1hJuqDfXQuUB7Yl6HafbNsb(gFqVn8PfyGHkydahW12jGfwNycYf0IiAxJHLbzFofqFA11oisSKVT38gfHcyiqrJ22zFofqFcs1jF)Uuh(027HkybOQwbNnuf8feddiwP96cMGnaCah7fqXGKVxms8c6cYXXFJgbBcxnqLpM)GnaCahBw)6ZBqlIOfyGXWYGfGQ0IGmbP7L7PYKa]] )

    storeDefault( [[Protection Primary]], 'displays', 20170625.203942, [[dWtBiaGEiYlvQYUivLTPuvZeLQzRKdl5Mij(TQ(gPk0YeQ2jj7LA3OA)qQFIedtugNuH6ZOKHIIbdjdhPoOu6OKQOogPCCHIfkflfLYIfPLt0dLk9uWJHYZfmrKKMkunzcz6kUieUkPkDzvUobBuPYwjvr2SOA7eQpkv0PrmniQ(UszKsf8mHsJweJhj1jjvULuHCnsv15fYTLQwlPk41qu2Ag3awrpKNV75dmrRZaf9IZUofcdtjzDdJygNAqwCwx3KddzUXq6IGesDU(nNAiIsEE4MUf9qEEWQmdutjppCt3IEippyvMHyeoHtKoSNdeKoRqEMHqYV1kilD883PgIr4eorDl6H88GBmerjppCdEjzDtWQmd6zHt4cg3knJBabVsxNi3yOfBiphnk2jHXkKBqv9Nbg5ph2qEoAuu9YpEGi(cgy7wxfoRINPTVwwwS6tZaGjj0Jbpwf34gqWR01jYngAXgYZrJIDsySs)guv)zGr(ZHnKNJgv3)xI(nEWaB36QWzv8mT91YYIvFAgamjHEm4XQynUbe8kDDICJHwSH8C0OyNegRI1GQ6pdmYFoSH8C0OaCdSDRRcNvXZ02xlllw9PzaWKe6XGhpgcj)gSrgSKweUXa1uYZd3Gxsw3eSkZab75aDHr4SSs)gMsY6MwowYln0qbhNcvytxNDa3qKvDuCKNzi)5JHwjPwOrPkP83mes(n8sY6MGBmGS0wowYlnGtHHnDD2bCdyFFAnmIr4udyf9qEElhl5LgAOGJtHkg6(0rOrH)gyK)Cyd55OrXij9LmYqi53aC3yigHt4OkrEyd55gytxNDa3axOxh2ZdwHCdb6BT2TQqs3F9sJBOSsZqQvAgyzLMbPvAEmes(TUf9qEEWngOMsEE4MwbzzvMHsqw4r0NHuH8Cdu9YlH14gd9f1TcZBvMbQPKNhUrhxebRMxgSkZqTOtki53yeJWknd1IoP6(9P1WigHvAguv)zGr(ZHnKNJgfJK0xYid1IoPAxBvuGrmcR0muRTkkWiMXngetcKuYImr4r0NHudyf9qEE7IWIBOlcfoc2miIeOxveEe9zOma0hgPweKQH8CR2FFdYIZ6WJOpdvkzrMidLGSOcHFUXqeL88Wn64Iiy18YGvzgqw6UNpabPZkT4gMsY6MDpFmWGJgfu8aAuQsk)ndmssFjJqJQBrpKNJgvRGSmyGG9C9W)9wPPFdYBzOlcfoc2meOV1A3Qcjo1qTOtk8sY6ggXiSsZWExukHlIWzHgfmrRZQ4gIr4eor64Iiy18YGBmes(nyJmyjTcZ7gdHKFRvyE3yykjRB298bMO1zGIEXzxNcHbQuut6f6rJcN0FwfBMHsqw645pEe9zivip3aGjj0Jbd1IoPAxBvuGrmJvAg6lQbCR0mqlj9LmA3ZhGG0zLwCd0Yd77tRPLHDRYmqlj9Lmsh2ZbcsNvipZqFrDlcRYmGxRJpOr1P8fOTkZWusw3WigHtnW2TUkCwfpttpMTVwS6tlE846VJnWij9LmcnQUf9qEUHPKSUjyGWfrWQ5LTCSKxAGnDD2bCd1IoPWljRByeZyLMHEcVvyERYmul6KQ73NwdJygR0mul6Kcs(ngXmwPziK8B64Iiy18YGBmGv0d557E(aeKoR0IBOwBvuGrmc3yiK8BTiCJHqYVXigHBmG99P1WiMXPgqw6UNpgyWrJckEankvjL)MHik55HB2RjyvhPzazP7E(at06mqrV4SRtHWqpHd4wLzykjRB298biiDwPf3qi53yeZ4gdyf9qE(UNpgyWrJckEankvjL)MHsqwa9Tw6OQvzgqWR01jYngcKE611sbHvXnerjppCtRGSSkZqi5327IsjCreoRGBmqnL88Wn71eSsZqpH3IWQyneJWjCTlclE)XhdygO2QmdIU8synTmSBGr(ZHnKNJgfvV8syngw)2jXQWTxtWPgkbz1YXsEPHgk44uOc7i2HBigHt4eT75dqq6SslUH0fbjK6C9BTRLtneJWjCI2Rj4gdXiqWqMEIeGjADgkdLGS0lNmgOxv0j9yd]] )


end
