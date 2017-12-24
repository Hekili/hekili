-- Rogue.lua
-- December 2017

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
local addTrait = ns.addTrait
local addResource = ns.addResource
local addStance = ns.addStance

local addSetting = ns.addSetting
local addToggle = ns.addToggle

local registerCustomVariable = ns.registerCustomVariable
local registerInterrupt = ns.registerInterrupt

local removeResource = ns.removeResource

local setArtifact = ns.setArtifact
local setClass = ns.setClass
local setPotion = ns.setPotion
local setRegenModel = ns.setRegenModel
local setRole = ns.setRole
local setTalentLegendary = ns.setTalentLegendary

local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent

local storeDefault = ns.storeDefault

local PTR = ns.PTR or false


local tinsert, tsort = table.insert, table.sort


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'ROGUE') then

    ns.initializeClassModule = function ()
        setClass( "ROGUE" )

        setPotion( "prolonged_power" )

        -- Resources
        addResource( "energy", SPELL_POWER_ENERGY )
        addResource( "combo_points", SPELL_POWER_COMBO_POINTS, true )

        setRole( state.spec.guardian and "tank" or "attack" )

        addHook( 'specializationChanged', function ()
            setPotion( 'prolonged_power' )
            setRole( "tank" or "attack" )
        end )


        setRegenModel( {
            ashamanes_energy = {
                resource = 'energy',

                spec = 'subtlety',
                aura = 'goremaws_bite',

                last = function ()
                    return state.buff.goremaws_bite.applied + floor( state.query_time - state.buff.goremaws_bite.applied )
                end,

                interval = 1,
                value = 5,
            }
        } )


        -- Talents
        --[[ Alacrity: Your finishing moves have a 20% chance per combo point to grant 2% Haste for 20 sec, stacking up to 10 times. ]]
        addTalent( "alacrity", 193539 ) -- 19249

        --[[ Anticipation: You may have a maximum of 10 combo points. Finishers still consume a maximum of 5 combo points. ]]
        addTalent( "anticipation", 114015 ) -- 19240

        --[[ Cheat Death: Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 85% reduced damage. Cannot trigger more often than once per 6 min. ]]
        addTalent( "cheat_death", 31230 ) -- 22123

        --[[ Dark Shadow: While Shadow Dance is active, all damage you deal is increased by 30%. ]]
        addTalent( "dark_shadow", 245687 ) -- 22335

        --[[ Death from Above: Finishing move that empowers your weapons with shadow energy and performs a devastating two-part attack.     You whirl around, dealing up to 29,459 damage to all enemies within 8 yds, then leap into the air and Eviscerate your target on the way back down, with such force that it has a 50% stronger effect. ]]
        addTalent( "death_from_above", 152150 ) -- 21188

        --[[ Deeper Stratagem: You may have a maximum of 6 combo points, your finishing moves consume up to 6 combo points, and your finishing moves deal 5% increased damage. ]]
        addTalent( "deeper_stratagem", 193531 ) -- 19239

        --[[ Elusiveness: Feint also reduces all damage you take from non-area-of-effect attacks by 30% for 5 sec. ]]
        addTalent( "elusiveness", 79008 ) -- 22122

        --[[ Enveloping Shadows: Deepening Shadows reduces the remaining cooldown of Shadow Dance by an additional 1.0 sec per combo point spent.    Shadow Dance gains 1 additional charge. ]]
        addTalent( "enveloping_shadows", 238104 ) -- 22336

        --[[ Gloomblade: Punctures your target with your shadow-infused blade for 16,221 Shadow damage, bypassing armor.    Awards 1 combo point. ]]
        addTalent( "gloomblade", 200758 ) -- 19235

        --[[ Marked for Death: Marks the target, instantly generating 6 combo points. Cooldown reset if the target dies within 1 min. ]]
        addTalent( "marked_for_death", 137619 ) -- 22133

        --[[ Master of Shadows: Gain 25 Energy over 3 sec when you enter Stealth or activate Shadow Dance. ]]
        addTalent( "master_of_shadows", 196976 ) -- 22132

        --[[ Master of Subtlety: Attacks made while stealthed and for 5 seconds after breaking stealth cause an additional 10% damage. ]]
        addTalent( "master_of_subtlety", 31223 ) -- 19233

        --[[ Nightstalker: While Stealth or Shadow Dance is active, you move 20% faster and your abilities deal 12% more damage. ]]
        addTalent( "nightstalker", 14062 ) -- 22331

        --[[ Prey on the Weak: Enemies disabled with your Blind, Kidney Shot, Cheap Shot, or Sap take 10% increased damage from all sources. ]]
        addTalent( "prey_on_the_weak", 131511 ) -- 22114

        --[[ Shadow Focus: Abilities cost 25% less Energy while Stealth or Shadow Dance is active. ]]
        addTalent( "shadow_focus", 108209 ) -- 22333

        --[[ Soothing Darkness: You heal 3% of your maximum life every 1 sec while Stealth or Shadow Dance is active. ]]
        addTalent( "soothing_darkness", 200759 ) -- 22128

        --[[ Strike from the Shadows: Shadowstrike also stuns your target for 2 sec. Players are Dazed for 5 sec instead. ]]
        addTalent( "strike_from_the_shadows", 196951 ) -- 22334

        --[[ Subterfuge: Your abilities requiring Stealth can still be used for 3 sec after Stealth breaks.    Also increases the duration of Shadow Dance by 1 sec. ]]
        addTalent( "subterfuge", 108208 ) -- 22332

        --[[ Tangled Shadow: Nightblade now decreases the target's movement speed by an additional 20%. ]]
        addTalent( "tangled_shadow", 200778 ) -- 22131

        --[[ Vigor: Increases your maximum Energy by 50 and your Energy regeneration by 10%. ]]
        addTalent( "vigor", 14983 ) -- 19241

        --[[ Weaponmaster: Your abilities have a 6% chance to hit the target twice each time they deal damage. ]]
        addTalent( "weaponmaster", 193537 ) -- 19234


        -- Traits
        addTrait( "akaaris_soul", 209835 )
        addTrait( "catlike_reflexes", 197241 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "demons_kiss", 197233 )
        addTrait( "embrace_of_darkness", 197604 )
        addTrait( "energetic_stabbing", 197239 )
        addTrait( "feeding_frenzy", 238140 )
        addTrait( "finality", 197406 )
        addTrait( "flickering_shadows", 197256 )
        addTrait( "fortunes_bite", 197369 )
        addTrait( "ghost_armor", 197244 )
        addTrait( "goremaws_bite", 209782 )
        addTrait( "gutripper", 197234 )
        addTrait( "legionblade", 214930 )
        addTrait( "precision_strike", 197235 )
        addTrait( "second_shuriken", 197610 )
        addTrait( "shadow_fangs", 221856 )
        addTrait( "shadow_nova", 209781 )
        addTrait( "shadows_of_the_uncrowned", 241154 )
        addTrait( "shadows_whisper", 242707 )
        addTrait( "soul_shadows", 197386 )
        addTrait( "the_quiet_knife", 197231 )
        addTrait( "weak_point", 238068 )


        -- Auras
        addAura( "alacrity", 193538, "duration", 20, "max_stack", 10 )
        addAura( "cloak_of_shadows", 31224 )
        addAura( "crimson_vial", 185311, "duration", 6 )
        addAura( "deepening_shadows", 185314 )
        addAura( "evasion", 5277, "duration", 10 )
        addAura( "feint", 1966, "duration", 5 )
        addAura( "finality_eviscerate", 197496, "duration", 30 )
        addAura( "finality_nightblade", 197498, "duration", 30 )
        addAura( "fleet_footed", 31209 )
        addAura( "goremaws_bite", 220901, "duration", 6 )
        addAura( "marked_for_death", 137619, "duration", 60 )
        addAura( "mastery_executioner", 76808 )
        addAura( "nightblade", 195452, "duration", 15 )
            class.auras[ 197395 ] = class.auras.nightblade
            modifyAura( "nightblade", "duration", function( x )
                return x + ( talent.deeper_stratagem.enabled and 3 or 0 )
            end )

        addAura( "relentless_strikes", 58423 )
        addAura( "sap", 6770, "duration", 60 )
        addAura( "shadow_blades", 121471, "duration", 15 )
        addAura( "shadow_dance", 185422, "duration", 4 )
            modifyAura( "shadow_dance", "duration", function( x )
                return x + ( talent.subterfuge.enabled and 1 or 0 )
            end )

        addAura( "shadow_techniques", 196912 )
        addAura( "shadowstep", 36554, "duration", 2 )
        addAura( "shroud_of_concealment", 114018, "duration", 15 )
        addAura( "shuriken_combo", 245639 )
        addAura( "stealth", 1784, "duration", 3600 )
            class.auras[ 115191 ] = class.auras.stealth
            modifyAura( "stealth", "id", function( x )
                return talent.subterfuge.enabled and 115191 or x
            end )

        addAura( "subterfuge", 115192, "duration", 3 )
        addAura( "symbols_of_death", 212283, "duration", 10 )
        addAura( "tricks_of_the_trade", 57934 )
        addAura( "vanish", 11327, "duration", 3 )


        local true_stealth_change = 0
        local emu_stealth_change = 0

        RegisterEvent( "UPDATE_STEALTH", function ()
            true_stealth_change = GetTime()
        end )

        state.stealthed = setmetatable( {}, {
            __index = function( t, k )
                
                if k == "rogue" then
                    return state.buff.stealth.up or state.buff.vanish.up or state.buff.shadow_dance.up or state.buff.subterfuge.up

                elseif k == "mantle" then
                    return state.buff.stealth.up or state.buff.vanish.up

                elseif k == "all" then
                    return state.buff.stealth.up or state.buff.vanish.up or state.buff.shadow_dance.up or state.buff.subterfuge.up or state.buff.shadowmeld.up

                end

                return false
            end
        } )


        local last_mh = 0
        local last_oh = 0
        local last_shadow_techniques = 0
        local swings_since_sht = 0

        RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
            if sourceGUID == state.GUID then
                if subtype == "SPELL_ENERGIZE" and spellID == 196911 then
                    last_shadow_techniques = GetTime()
                    swings_since_sht = 0
                end

                if subtype:sub( 1, 5 ) == 'SWING' and not multistrike then
                    if subtype == 'SWING_MISSED' then
                        offhand = spellName
                    else
                        swings_since_sht = swings_since_sht + 1
                    end
                end
            end
        end )

        local sht = {}

        state.time_to_sht = setmetatable( {}, {
            __index = function( t, k )
                local n = tonumber( k )
                n = n - ( n % 1 )

                if not n or n > 5 then return 3600 end

                if n <= swings_since_sht then return 0 end

                local mh_speed = state.swings.mainhand_speed
                
                local time_since_mh = state.query_time - last_mh
                local mh_next = state.swings.mainhand + mh_speed

                local oh_speed = state.swings.offhand_speed
                
                local time_since_oh = state.query_time - last_oh
                local oh_next = state.swings.offhand + oh_speed

                table.wipe( sht )

                sht[1] = mh_next + ( 1 * mh_speed )
                sht[2] = mh_next + ( 2 * mh_speed )
                sht[3] = mh_next + ( 3 * mh_speed )
                sht[4] = oh_next + ( 1 * oh_speed )
                sht[5] = oh_next + ( 2 * oh_speed )
                sht[6] = oh_next + ( 3 * oh_speed )

                table.sort( sht )

                return max( 0, sht[ n - swings_since_sht ] - state.query_time )
            end
        } )


        addMetaFunction( "state", "bleeds", function ()
            return ( debuff.garrote.up and 1 or 0 ) + ( debuff.rupture.up and 1 or 0 )
        end )

        addMetaFunction( "state", "cp_max_spend", function ()
            return talent.deeper_stratagem.enabled and 6 or 5
        end )

        addMetaFunction( "state", "finality", function ()
            return false
        end )


        addHook( "reset_precast", function ()
            if state.buff.vanish.up then state.applyBuff( "stealth", 3600 ) end

            emu_stealth_change = 0
            if state.talent.master_of_subtlety.enabled and not state.stealthed.rogue then
                if state.now - true_stealth_change < 5 then
                    applyBuff( "master_of_subtlety", state.now - true_stealth_change )
                end
            end
        end )


        addHook( "runHandler", function( ability )
            if not class.abilities[ ability ] or not class.abilities[ ability ].passive then
                if state.buff.stealth.up then
                    state.removeBuff( "stealth" )
                    state.setCooldown( "stealth", 2 )

                    if state.talent.master_of_subtlety.enabled then
                        state.applyBuff( "master_of_subtlety", 5 )
                    end

                    if state.equipped.mantle_of_the_master_assassin then
                        state.applyBuff( "master_assassins_initiative", 5 )
                    end

                    if state.talent.subterfuge.enabled then
                        state.applyBuff( "subterfuge" )
                    end

                    emu_stealth_change = state.query_time
                end
                
                if state.buff.vanish.up then
                    state.removeBuff( "vanish" )
                    state.setCooldown( "stealth", 2 )

                    if state.talent.master_of_subtlety.enabled then
                        state.applyBuff( "master_of_subtlety", 5 )
                    end

                    if state.equipped.mantle_of_the_master_assassin then
                        state.applyBuff( "master_assassins_initiative", 5 )
                    end

                    if state.talent.subterfuge.enabled then
                        state.applyBuff( "subterfuge" )
                    end

                    emu_stealth_change = state.query_time
                end
                
                if state.buff.shadowmeld.up then
                    state.removeBuff( "shadowmeld" )

                    if state.talent.master_of_subtlety.enabled then
                        state.applyBuff( "master_of_subtlety", 5 )
                    end

                    if state.talent.subterfuge.enabled then
                        state.applyBuff( "subterfuge" )
                    end

                    emu_stealth_change = state.query_time
                end

            end
        end )


        -- Legendaries
        addGearSet( "cinidaria_the_symbiote", 133976 )

        addGearSet( "denial_of_the_halfgiants", 137100 )

            local function comboSpender( amt, resource )
                if state.spec.subtlety and resource == "combo_points" and amt > 0 and state.equipped.denial_of_the_halfgiants then
                    if state.buff.shadow_blades.up then
                        state.buff.shadow_blades.expires = state.buff.shadow_blades.expires + 0.2 * amt
                    end
                end

                if state.talent.alacrity.enabled and amt >= 5 then
                    state.addStack( "alacrity", 20, 1 )
                end
            end

            addHook( 'spend', comboSpender )
            addHook( 'spendResources', comboSpender )

        addGearSet( "insignia_of_ravenholdt", 137049 )
        addGearSet( "mantle_of_the_master_assassin", 144236 )
            addAura( "master_assassins_initiative", 235027, "duration", 3600 )

            addMetaFunction( "state", "mantle_duration", function( x )
                if state.stealthed.mantle then return state.global_cooldown.remains + state.buff.master_assassins_initiative.duration
                elseif state.buff.master_assassins_initiative.up then return state.buff.master_assassins_initiative.remains end
                return 0
            end )


        addGearSet( "shadow_satyrs_walk", 137032 )
            addMetaFunction( "state", "ssw_refund_offset", function( x )
                return target.distance
            end )

        addGearSet( "soul_of_the_shadowblade", 150936 )
        addGearSet( "the_dreadlords_deceit", 137021 )
            addAura( "the_dreadlords_deceit", 228224, "duration", 3600, "max_stack", 20 )
            class.auras[ 208693 ] = class.auras.the_dreadlords_deceit
            modifyAbility( "the_dreadlords_deceit", "id", function( x )
                if spec.subtlety then return 228224 end
                return 208693
            end )

        addGearSet( "the_first_of_the_dead", 151818 )
            addAura( "the_first_of_the_dead", 248210, "duration", 2 )

        addGearSet( "will_of_valeera", 137069 )
            addAura( "will_of_valeera", 208403, "duration", 5 )

        setTalentLegendary( "soul_of_the_shadowblade", "assassination", "vigor" )
        setTalentLegendary( "soul_of_the_shadowblade", "outlaw", "vigor" )
        setTalentLegendary( "soul_of_the_shadowblade", "subtlety", "vigor" )

        addGearSet( "fangs_of_the_devourer", 128476 )
        setArtifact( "fangs_of_the_devourer" )


        -- Abilities

        -- Backstab
        addAbility( "backstab", {
            id = 53,
            spend = 35,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 8,            
            notalent = "gloomblade",
        } )

        modifyAbility( "backstab", "spend", function( x )
            if talent.shadow_focus.enabled and stealth.rogue then
                return x * 0.75
            end
            return x
        end )

        addHandler( "backstab", function ()
            gain( 1 + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
            if buff.the_first_of_the_dead.up then gain( 4, "combo_points" ) end
        end )


        -- Blind
        --[[ Blinds the target, causing it to wander disoriented for 1 min. Damage will interrupt the effect. Limit 1. ]]

        addAbility( "blind", {
            id = 2094,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 120,
            min_range = 0,
            max_range = 15,
            passive = true,
        } )

        addHandler( "blind", function ()
            -- proto
        end )


        -- Cheap Shot
        --[[ Stuns the target for 4 sec.    Awards 2 combo points. ]]

        addAbility( "cheap_shot", {
            id = 1833,
            spend = 40,
            min_cost = 40,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            usable = function () return stealth.rogue end,
        } )

        modifyAbility( "cheap_shot", "spend", function( x )
            if talent.shadow_focus.enabled and stealth.rogue then
                return x * 0.75
            end
            return x
        end )

        addHandler( "cheap_shot", function ()
            gain( 2 + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
        end )


        -- Cloak of Shadows
        --[[ Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for 5 sec. ]]

        addAbility( "cloak_of_shadows", {
            id = 31224,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 90,
            min_range = 0,
            max_range = 0,
            passive = true,
        } )

        addHandler( "cloak_of_shadows", function ()
            -- proto
        end )


        -- Crimson Vial
        --[[ Drink an alchemical concoction that heals you for 30% of your maximum health over 6 sec. ]]

        addAbility( "crimson_vial", {
            id = 185311,
            spend = 30,
            min_cost = 30,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            min_range = 0,
            max_range = 0,
            passive = true,
        } )

        modifyAbility( "crimson_vial", "spend", function( x )
            if talent.shadow_focus.enabled and stealth.rogue then
                return x * 0.75
            end
            return x
        end )

        addHandler( "crimson_vial", function ()
            applyBuff( "crimson_vial", 6 )
        end )


        -- Distract
        --[[ Throws a distraction, attracting the attention of all nearby monsters for 10 seconds. Usable while stealthed. ]]

        addAbility( "distract", {
            id = 1725,
            spend = 30,
            min_cost = 30,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            min_range = 0,
            max_range = 30,
            passive = true,
        } )

        addHandler( "distract", function ()
            -- proto
        end )


        -- Evasion
        --[[ Increases your dodge chance by 100% for 10 sec. ]]

        addAbility( "evasion", {
            id = 5277,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 120,
            min_range = 0,
            max_range = 0,
            passive = true,
        } )

        addHandler( "evasion", function ()
            applyBuff( "evasion" )
        end )


        -- Eviscerate
        --[[ Finishing move that disembowels the target, causing damage per combo point.     1 point  : 9,854 damage     2 points: 19,708 damage     3 points: 29,562 damage     4 points: 39,416 damage     5 points: 49,270 damage     6 points: 59,124 damage ]]

        addAbility( "eviscerate", {
            id = 196819,
            spend = 35,
            min_cost = 35,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            usable = function () return combo_points.current > 0 end,
        } )

        modifyAbility( "eviscerate", "spend", function( x )
            if talent.shadow_focus.enabled and stealth.rogue then
                return x * 0.75
            end
            return x
        end )

        addHandler( "eviscerate", function ()
            local cost = min( 5 + ( talent.deeper_stratagem.enabled and 1 or 0 ), combo_points.current )
            spend( cost, "combo_points" )
            gainChargeTime( "shadow_dance", cost * 1.5 )
            if artifact.finality.enabled then
                if buff.finality_eviscerate.up then removeBuff( "finality_eviscerate" )
                else removeBuff( "finality_eviscerate" ) end
            end
        end )


        -- Feint
        --[[ Performs an evasive maneuver, reducing damage taken from area-of-effect attacks by 50% for 5 sec. ]]

        addAbility( "feint", {
            id = 1966,
            spend = 35,
            min_cost = 35,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            passive = true,
        } )

        modifyAbility( "feint", "spend", function( x )
            if talent.shadow_focus.enabled and stealth.rogue then
                return x * 0.75
            end
            return x
        end )

        addHandler( "feint", function ()
            applyBuff( "feint" )
            if equipped.will_of_valeera then applyBuff( "will_of_valeera" ) end
        end )


        -- Gloomblade
        --[[ Punctures your target with your shadow-infused blade for 16,221 Shadow damage, bypassing armor.    Awards 1 combo point. ]]

        addAbility( "gloomblade", {
            id = 200758,
            spend = 35,
            min_cost = 35,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            talent = "gloomblade",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "gloomblade", "spend", function( x )
            if talent.shadow_focus.enabled and stealth.rogue then
                return x * 0.75
            end
            return x
        end )

        addHandler( "gloomblade", function ()
            gain( 1 + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
        end )


        -- Goremaw's Bite
        --[[ Lashes out at the target, inflicting 60,775 Shadow damage and reducing movement speed by 60% for 8 sec. Grants 30 Energy over 6 sec.    Awards 3 combo points. ]]

        addAbility( "goremaws_bite", {
            id = 209782,
            spend = -3,
            spend_type = "combo_points",
            cast = 0,
            gcdType = "spell",
            cooldown = 60,
            min_range = 0,
            max_range = 0,
            toggle = 'artifact',
            equipped = 'fangs_of_the_devourer1'
        } )

        addHandler( "goremaws_bite", function ()
            applyBuff( "goremaws_bite" )
        end )


        -- Kick
        --[[ A quick kick that interrupts spellcasting and prevents any spell in that school from being cast for 5 sec. ]]

        addAbility( "kick", {
            id = 1766,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 15,
            min_range = 0,
            max_range = 0,
            toggle = "interrupts",
        } )

        addHandler( "kick", function ()
            interrupt()
        end )


        -- Kidney Shot
        --[[ Finishing move that stuns the target. Lasts longer per combo point:     1 point  : 2 seconds     2 points: 3 seconds     3 points: 4 seconds     4 points: 5 seconds     5 points: 6 seconds     6 points: 7 seconds ]]

        addAbility( "kidney_shot", {
            id = 408,
            spend = 25,
            min_cost = 25,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 20,
            min_range = 0,
            max_range = 0,
            usable = function () return stealthed.all and combo_points.current > 0 end,
        } )

        addHandler( "kidney_shot", function ()
            local cost = min( 5 + ( talent.deeper_stratagem.enabled and 1 or 0 ), combo_points.current )
            spend( cost, "combo_points" )
            gainChargeTime( "shadow_dance", cost * 1.5 )
        end )


        -- Marked for Death
        --[[ Marks the target, instantly generating 5 combo points. Cooldown reset if the target dies within 1 min. ]]

        addAbility( "marked_for_death", {
            id = 137619,
            spend = -5,
            spend_type = "combo_points",
            cast = 0,
            gcdType = "spell",
            talent = "marked_for_death",
            cooldown = 60,
            min_range = 0,
            max_range = 30,
            passive = true,
        } )

        modifyAbility( "marked_for_death", function( x )
            return x - ( talent.deeper_stratagem.enabled and 1 or 0 )
        end )

        addHandler( "marked_for_death", function ()
            applyDebuff( "target", "marked_for_death" )
        end )


        -- Nightblade
        --[[ Finishing move that infects the target with shadowy energy, dealing Shadow damage over time and causing attacks against the target to reduce movement speed by 50% for 8 sec. Lasts longer per combo point.     1 point  : 24,108 over 8 sec     2 points: 30,135 over 10 sec     3 points: 36,162 over 12 sec     4 points: 42,189 over 14 sec     5 points: 48,216 over 16 sec     6 points: 54,243 over 18 sec    You deal 15% increased damage to enemies afflicted by your Nightblade. ]]

        addAbility( "nightblade", {
            id = 195452,
            spend = 25,
            min_cost = 25,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            aura = 'nightblade',
            usable = function () return combo_points.current > 0 end,
        } )

        addHandler( "nightblade", function ()
            local cost = min( 5 + ( talent.deeper_stratagem.enabled and 1 or 0 ), combo_points.current )
            spend( cost, "combo_points" )
            gainChargeTime( "shadow_dance", cost * 1.5 )
            if artifact.finality.enabled then
                if buff.finality_nightblade.up then removeBuff( "finality_nightblade" )
                else applyBuff( "finality_nightblade" ) end
            end
        end )


        -- Pick Lock
        --[[ Allows opening of locked chests and doors that require a skill level of up to 500. ]]

        addAbility( "pick_lock", {
            id = 1804,
            spend = 0,
            cast = 1.5,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 5,
        } )

        addHandler( "pick_lock", function ()
            -- proto
        end )


        -- Pick Pocket
        --[[ Pick the target's pocket. ]]

        addAbility( "pick_pocket", {
            id = 921,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 0.5,
            min_range = 0,
            max_range = 10,
            passive = true,
            usable = function () return stealthed.all end,
        } )

        addHandler( "pick_pocket", function ()
            -- proto
        end )


        -- Sap
        --[[ Incapacitates a target not in combat for 1 min. Only works on Humanoids, Beasts, Demons, and Dragonkin. Damage will revive the target. Limit 1. ]]

        addAbility( "sap", {
            id = 6770,
            spend = 35,
            min_cost = 35,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 10,
            passive = true,
        } )

        addHandler( "sap", function ()
            applyDebuff( "target", "sap" )
        end )


        -- Shadow Blades
        --[[ Draws upon surrounding shadows to empower your weapons, causing auto attacks to deal Shadow damage and abilities that generate combo points to generate 1 additional combo point. Lasts 15 sec. ]]

        addAbility( "shadow_blades", {
            id = 121471,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
            passive = true,
            toggle = "cooldowns",
        } )

        addHandler( "shadow_blades", function ()
            applyBuff( "shadow_blades" )
        end )


        -- Shadow Dance
        --[[ Allows use of all Stealth abilities and grants all the combat benefits of Stealth for 4 sec. Effect not broken from taking damage or attacking. Abilities cost 25% less while active.  ]]

        addAbility( "shadow_dance", {
            id = 185313,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 60,
            charges = 2,
            recharge = 60,
            min_range = 0,
            max_range = 0,
            nobuff = "stealth",
            ready = function () return buff.shadow_dance.remains end,
        } )

        modifyAbility( "shadow_dance", "charges", function( x )
            return x + ( talent.enveloping_shadows.enabled and 1 or 0 ) 
        end )

        addHandler( "shadow_dance", function ()
            applyBuff( "shadow_dance", 4 )
        end )


        -- Shadowstep
        --[[ Step through the shadows to appear behind your target and gain 70% increased movement speed for 2 sec. ]]

        addAbility( "shadowstep", {
            id = 36554,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            charges = 2,
            recharge = 30,
            min_range = 0,
            max_range = 25,
        } )

        addHandler( "shadowstep", function ()
            applyBuff( "shadowstep" )
            setDistance( 5 )
        end )


        -- Shadowstrike
        --[[ Strike the target, dealing 23,914 Physical damage.    While Stealth is active, you strike through the shadows and appear behind your target up to 25 yds away, dealing 25% additional damage.    Awards 2 combo points. ]]

        addAbility( "shadowstrike", {
            id = 185438,
            spend = 40,
            min_cost = 40,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            usable = function () return stealthed.all or buff.shadow_dance.up end
        } )

        addHandler( "shadowstrike", function ()
             gain( 2 + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
             if buff.the_first_of_the_dead.up then gain( 3, "combo_points" ) end
             if equipped.shadow_satyrs_walk then gain( 3 + ( target.distance / 3 ), "energy" ) end
        end )


        -- Shroud of Concealment
        --[[ Extend a cloak that wraps party and raid members within 20 yards in shadows, providing stealth for 15 sec. ]]

        addAbility( "shroud_of_concealment", {
            id = 114018,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 360,
            min_range = 0,
            max_range = 0,
            passive = true,
            usable = function () return stealthed.rogue end,
        } )

        addHandler( "shroud_of_concealment", function ()
            applyBuff( "shroud_of_concealment" )
        end )


        -- Shuriken Storm
        --[[ Sprays shurikens at all targets within 10 yards, dealing 5,496 Physical damage.    Damage increased by 100% while Stealth or Shadow Dance is active.    Awards 1 combo point per target hit. ]]

        addAbility( "shuriken_storm", {
            id = 197835,
            spend = 35,
            min_cost = 35,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "shuriken_storm", function ()
            gain( active_enemies, "combo_points" )
        end )


        -- Shuriken Toss
        --[[ Throws a shuriken at an enemy target for 5,495 Physical damage.    Awards 1 combo point. ]]

        addAbility( "shuriken_toss", {
            id = 114014,
            spend = 40,
            min_cost = 40,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 30,
        } )

        addHandler( "shuriken_toss", function ()
            gain( 1 + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
        end )


        -- Sprint
        --[[ Increases your movement speed by 70% for 8 sec. Usable while stealthed.    Allows you to run over water. ]]

        addAbility( "sprint", {
            id = 2983,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 120,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "sprint", function ()
            applyBuff( "sprint", 8 )
        end )


        -- Stealth
        --[[ Conceals you in the shadows until cancelled, allowing you to stalk enemies without being seen.  Abilities cost 25% less while stealthed.  ]]

        addAbility( "stealth", {
            id = 1784,
            spend = 0,
            cast = 0,
            gcdType = "off",
            cooldown = 2,
            min_range = 0,
            max_range = 0,
            usable = function () return ( time == 0 or boss ) and not stealthed.all end,
            passive = true,
        } )

        addHandler( "stealth", function ()
            applyBuff( "stealth" )
            emu_stealth_change = query_time
        end )


        -- Symbols of Death
        --[[ Invoke ancient symbols of power, generating 40 Energy and increasing your damage done by 15% for 10 sec. ]]

        addAbility( "symbols_of_death", {
            id = 212283,
            spend = -40,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            charges = 1,
            recharge = 30,
            min_range = 0,
            max_range = 0,
            passive = true,
        } )

        addHandler( "symbols_of_death", function ()
            applyBuff( "symbols_of_death" )
            if equipped.the_first_of_the_dead then applyBuff( "the_first_of_the_dead" ) end
        end )


        -- Tricks of the Trade
        --[[ Redirects all threat you cause to the targeted party or raid member, beginning with your next damaging attack within the next 30 sec and lasting 6 sec. ]]

        addAbility( "tricks_of_the_trade", {
            id = 57934,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            min_range = 0,
            max_range = 100,
            passive = true,
        } )

        addHandler( "tricks_of_the_trade", function ()
            -- proto
        end )


        -- Vanish
        --[[ Allows you to vanish from sight, entering stealth while in combat. For the first 3 sec after vanishing, damage and harmful effects received will not break stealth. Also breaks movement impairing effects. ]]

        addAbility( "vanish", {
            id = 1856,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 120,
            min_range = 0,
            max_range = 0,
            passive = true,
            usable = function () return boss end,
        } )

        addHandler( "vanish", function ()
            applyBuff( "vanish" )
            applyBuff( "stealth" )
            emu_stealth_change = query_time
        end )

    end


    storeDefault( [[SimC Subtlety: stealthed]], 'actionLists', 20171223.230208, [[d4JBhaGEcuAtuv2Lq2MesTpcQzsGQNtLzRW8vLUjvv3vcj3wv9nvs2PqTxKDt0(Pmkc1WuP(nupwfNxLyWKgUu5GquNIqoMeDovsvleIyPQIwmKwUIEOuvpv0YKuwhbYPbnvPktwktxPlkPYRKqDzuxxGNjPQTcHSzbTDc4ZqK(lvzAQKkZJGWBjiAreKgTK8DvHtcH6weO4AQKY9GGddCCjeVwcMkPEuwNeGo4gHszm4ZuMWFFtZa0DW7fbzQBzWyR4gLp5bdCmfx7U8QYA1QfvszEMWULskr(SqS0r9O4sQhL1jbOdUriHY8mHDlLObHHrULbJTkkOJsKrHd4EHsxfOHF42jSatjILn4bS4jLsSKP0pUHiWmg8zkPmg8zkZkqd)WTtybMYN8GboMIRDxEv5nLpzhoyEyh1Jwk7xXNc(XcWFwUekL(XTyWNPKwkUg1JY6Ka0b3iKqzEMWULYd(JI96Wq56IobZjlxtfgbtVMPfBQytfB6cgSCJAm3Xtp3oblaP8pc6Xsa6GBM6Zu0GWWibasORkkOZurM6Z0stFFn92urM6ZuXMcolua2JL8hYotfgbtR30InvSPCrcGDDClYvbA4hEoWEz68Eagfm1NPLM((A6TPIm991uXM(bYDWETGjyHyPPcbcMwgvVP(m9dK7G9AbtWcXstfgbtVJQ3urMkIsKrHd4EHYdym8aNfILEdOBPeXYg8aw8KsjwYu6h3qeygd(mLugd(mLVNWW77Zjmui7dgdtr(SqS0ubh62I6DsjYtK6Ouc(mccnH)(MMbO7G3lcY0qOe6QekLp5bdCmfx7U8QYBkFYoCW8WoQhTu2VIpf8JfG)SCjuk9JBXGptzc)9nndq3bVxeKPHqj0vrlfxp1JY6Ka0b3iKqzEMWULs0GWWixfOHF85rlQHFin1NPInvSPh8hf71HHY1f14q4bUMkmcMwZ0InvSPCrcGDDClckDqKkHapCO3eialRWJ2AQptln9910BtfzQptbNfka7Xs(dzNPcJGP1BAXMk2uUibWUoUf5Qan8dphyVmDEpaJcM6Z0stFFn92urMkY03xtfB6b)rXEDyOCDrnoeEGRPcJGPLM6Zu0GWWOTI9Atg0g4zZ514dd3i3cofmvyemT21BQitfrjYOWbCVqPRkyclWsp3INFkrSSbpGfpPuILmL(XnebMXGptjLXGptzwfmHfyPP5INFkFYdg4ykU2D5vL3u(KD4G5HDupAPSFfFk4hla)z5sOu6h3IbFMsAP4RJ6rzDsa6GBesOmpty3s5b)rXEDyOCDrNG5KLRPcJGPxZ0InvSPInDbdwUrnM74PNBNGfGu(hb9yjaDWnt9zkAqyyKaaj0vff0zQit9zAPPVVMEBQit9z6b)rXEDyOCDrnoeEGRPcHP1BAXMk2u0GWWixfOHF4Hoan2ff0zQptln9910BtfzQGXuXMYfja21XTOpqUd2dh6TvS3h4wE6bCoGZbLM6Z0stFFn92uruImkCa3luEaJHh4SqS0BaDlLiw2GhWINukXsMs)4gIaZyWNPKYyWNP89egEFFoHHczFWyykYNfILMk4q3wuVttfxkIsKNi1rPe8zeeAc)9nndq3bVxeKPHqj0vjukFYdg4ykU2D5vL3u(KD4G5HDupAPSFfFk4hla)z5sOu6h3IbFMYe(7BAgGUdEViitdHsORIwk(AupkRtcqhCJqcLiJchW9cLUkqd)WTtybMselBWdyXtkLyjtPFCdrGzm4Zuszm4ZuMvGg(HBNWcSPIlfr5tEWahtX1UlVQ8MYNSdhmpSJ6rlL9R4tb)yb4plxcLs)4wm4ZuslTuMD8bcgqblyHyjfxROlPLia]] )

    storeDefault( [[SimC Subtlety: stealth CDs]], 'actionLists', 20171223.230208, [[di0PhaqiiuBskzuQuDkiyvKi9kseZIei3IeK2funmr1Xuslds9msOMgjQRrcuBJeu(MsH1rcO5PeP7brTpiYbLcTqLIEOuWeLsvxukYgjbXjHqUjj1of0qvIyPkLEQIPQuzRkr9wsq1DLsL2lQ)QkdMQdlzXq5XQyYK6YiBwu(SuuJwGtl0RLsz2s1Tvv7MWVbgoj54sPILlYZjA6GUUkz7Qu(Usy8KqoVsvRNeG5dj7NY8kVJNMefwN0mgpH1N4zI)gmFUWGDcUxbAUesvhgyEdTxYZwQtLK4q05RBSIgnA8vEMtkQcYdpnEGrGqY74WvEhpnjkSoP5n5zoPOkipi28BvkwyDcxldE6SY8wM)lbStp9vQGrGWCKnp38wMFaGUgSqGldknyXtxIdHFcQuZK8LLQdmcev38LA(TkflSoHld0VSuDGrGO6MReZVB(DZP25kQsfPX)La2Phi7bdO3VKqk9kPSKYOW8wMdJFY8LAUIZnhbZBz(Q5OqzEU5iyUsnphxXM3Y87MJyZP25kQsfPX)La2Phi7bdO3VKqk9kPSKYOWCuOmh7kldxU)Jb6Yhi7PPcgGFPYCe4PrSypc3ZZTseLb8GiHoEkiiXJaiiEud0lxPW6t8Wty9jEwUerzapBPovsIdrNVUXAopBjj4kDijVJH80qaDAtn4g9jbKX4rnqhwFIhgYHO5D80KOW6KM3KN5KIQG8CcQuZK8LLQdmcev3CKq28BvkwyDcxgOFzP6aJar1nhfkZHvQzcIdJF6bbpDKmFPMFaGUgSqGl3)XaD5dK90ubdWt0VIcjpnIf7r4EEKbLgS4PlXH4brcD8uqqIhbqq8OgOxUsH1N4HNW6t8mbLgSW82xIdXZwQtLK4q05RBSMZZwscUshsY7yipneqN2udUrFsazmEud0H1N4HHCOI5D80KOW6KM3KNgXI9iCppQaG(lrsWv6q8GiHoEkiiXJaiiEAiGoTPgCJ(KaYy8OgOxUsH1N4HNLaaDfcifskcYBYty9jEqDYYYZpNSmf(saGU5Bjj4kDO2fvINgtnl5jdKEcsrqKxvqKIGP6vFWLaISY58SeaO3KIGPIdvoNNTKeCLoKK3XqE2sDQKehIoFDJ1CEud0H1N4HHCOY8oEAsuyDsZBYZCsrvqEibLAEp(5kLib0CKq2CLZnVL5KGsnVhxtzXteAosiB(AU5kX8BvkwyDcxkx8su2LqZtJyXEeUNhzqPbl(uxZdIe64PGGepcGG4rnqVCLcRpXdpH1N4zcknyXN6AE2sDQKehIoFDJ1CE2ssWv6qsEhd5PHa60MAWn6tciJXJAGoS(epmKdvW8oEAsuyDsZBYZCsrvqEqS53QuSW6eUwg80zL5Tm)a(yGNkquaL4AklEIqZrczZrBUsm)U5WQtciU8cdsPSRMj84JefwN0M3Y8vZrHY8CZrWCLAoAZBz(DZXUYYWL7)yGU8bYEAQGb4j6xrH0CKq28vC0MJcL5haORble4Y9Fmqx(azpnvWa8e9ROqAosiB(kAZvI53n)U5WQtciUUsT9KbLgSap(irH1jT5TmxsWhgqCjXHrkHo)PSQJ5izEU5iyElZxnhfkZZnhbZvQ5k2CfQ53n)U5i2Cy1jbexxP2EYGsdwGtIcRtAZBzUKGpmG4sIdJucD(tzvhZrY8CZrW8wMVAokuMNBocMRuZv2CuOm)xcyNE6RubJaH5izEU5iyElZVBEDGXB0Je0pssZrczZv2CuOmhXMJDLLHddOxwmjHpq2dgqpnvA8lvMJapnIf7r4EEKbLgS4PlXH4brcD8uqqIhbqq8OgOxUsH1N4HNW6t8mbLgSW82xIdz(9ve4zl1PssCi681nwZ5zljbxPdj5DmKNgcOtBQb3OpjGmgpQb6W6t8WqgYZOIoXQhvafmceCiAf2kdzga]] )

    storeDefault( [[SimC Subtlety: default]], 'actionLists', 20171223.230208, [[dmukwaqickwea1MOKgLsPtPkSkcq8kvvmlac3IGszxeAyc6yGyzQsEgvPAAuLY1iiTncGVPuyCeG05iOK1PQsZJGQ7PQQ9bioOQOfsa9qbmrcqDraPtsGmtas3KQyNkvlfK8uPMki1wvk6TeOUlbXEj9xinyjhwXIb6XcnzQCzKndXNbuJMQ60O61uLmBIUnO2nk)gQHtjooarlxjpNIPRY1PuBxG(oaoVQuRNGs18vv2VOvik0Adu2akjNcQ9(atA3C4az12GNKU3)MLJqgB5PnuKKgdP7VcHSbKxVEjcr7oU4woT1(z84yMrHw3HOqRnqzdOKCQa1UJlULtBcqAZTyHCIg)XHba1m37LbfGr6vwwZABwcqw)KLXaa6IqSzoumcIHUSEK13xwHA)eKl53BTdol(akjTfeZXJZHxAZWmsBpy3MZAFGjTngaqxeInZP9(atA)frqcdJreeb3hErzT5iTjH8T0(5cyJ2SbM(BmaGUieBMdqeCK20FcqAZTyHCIg)XHba1m37LbfGr6L1TcWpgdaOlcXM5qXiig6E89fQnuKKgdP7VcHSbKqTHImy7vKmk06PDaFk6LhCqcMyNcQThSBFGjT1t3FPqRnqzdOKCQa1UJlULt7TzjacnRFYABw3ij2jgKdmEjsSbusUSSML3fAwFFzfM1JS(jRTzDJKyNi8yoAHIrqn(JddGrKydOKCzznliHz99LvywpY6NScol(akjrJba0fHyZCz9q7NGCj)ERDWzXhqjPTGyoECo8sBgMrA7b72Cw7dmPT5OrE(ON)Im(yPt79bM0(lIGeggJiicUp8IYAZrAtc5BL1wip0(5cyJ2SbM(BoAKNp65ViJpw6aebhPn9FRai0F2EJKyNyqoW4LiXgqj5S6DH(9f(4NT3ij2jcpMJwOyeuJ)4Wayej2akjNviHFFHp(j4S4dOKengaqxeInZ9qBOijngs3FfczdiHAdfzW2RizuO1t7a(u0lp4GemXofuBpy3(atARNU7DfATbkBaLKtfO2DCXTCAdrCJxcnRFYABw3ij2jsSGKeBHZag14pomagrInGsYLL1Scf34LqZ67lRWSEO9tqUKFV1o4S4dOK0wqmhpohEPndZiT9GDBoR9bM0247qrwt84y2i1EFGjT)IiiHHXicIG7dVOS2CK2Kq(wzT91dTFUa2OnBGP)gFhkYAIhhZgjGi4iTP)qe34Lq)z7nsIDIelijXw4mGrn(JddGrKydOKCwdf34Lq)(cFOnuKKgdP7VcHSbKqTHImy7vKmk06PDaFk6LhCqcMyNcQThSBFGjT1t39McT2aLnGsYPcu7oU4woTVrsSt0rZ5JISWWOdioijsSbusUSSM1nsIDIUz5fQXFCyaej2akjxwwZAIhpiHsmcMtMSeEwEt7NGCj)ERDWzXhqjPTGyoECo8sBgMrA7b72Cw7dmPTZ4J6qgT3hys7VicsyymIGi4(WlkRnhPnjKVvwB9(dTFUa2OnBGP)oJpQdzaebhPn9)gjXorhnNpkYcdJoG4GKiXgqj5SEJKyNOBwEHA8hhgarInGsYzDIhpiHsmcMtgH7nTHIK0yiD)viKnGeQnuKbBVIKrHwpTd4trV8GdsWe7uqT9GD7dmPTE6UqvO1gOSbusovGA3Xf3YP9nsIDIUz5fQXFCyaej2akjxwwZABwctwMJg55toXrkZ67llqBeerJn4rleBGjrBlz9ilRzbAJGi6O58rrwyy0behKeTTKL1SaTrqeD0C(Oilmm6aIdsIlcE4mtwc)FwHIqeQ2pb5s(9wBJ)4WaG6gwK0wqmhpohEPndZiT9GDBoR9bM0w79bM0U9hhgGSeWdlsAdfjPXq6(RqiBajuBOid2EfjJcTEAhWNIE5bhKGj2PGA7b72hysB90DbqHwBGYgqj5ubQ9tqUKFV1oosj6epoMHk5MtBbXC84C4L2mmJ02d2T5S2hysBT3hys7VicsyymIGi4aJuM1Z4XXSSauU5eY3s7NlGnAZgy6pGBoCGSABWts37FZkGa2ayTHIK0yiD)viKnGeQnuKbBVIKrHwpTd4trV8GdsWe7uqT9GD7dmPDZHdKvBdEs6E)BwbeWg909nuO1gOSbusovGA3Xf3YPT5OrE(KtCKsTFcYL87T2lBg6epoMHk5MtBbXC84C4L2mmJ02d2T5S2hysBT3hys7VicsyymIGiyOSzz9mECmllaLBoH8T0(5cyJ2SbM(d4MdhiR2g8K09(3SmhnYZNCawBOijngs3FfczdiHAdfzW2RizuO1t7a(u0lp4GemXofuBpy3(atA3C4az12GNKU3)ML5OrE(KtpDxavHwBGYgqj5ubQDhxClN23SaMoXJdtOhg1XPSaswcqwwZArWdNzYs4zbC0LL1SIyyqmQfmNDgXO9ArSllG8plVLLWwwBZ64WuwcpliHzznliz99LvywpYsajRxA)eKl53BTzCG9pq54iTfeZXJZHxAZWmsBpy3MZAFGjT1EFGjT35a7FGYXrAdfjPXq6(RqiBajuBOid2EfjJcTEAhWNIE5bhKGj2PGA7b72hysB90DHLcT2aLnGsYPcu7oU4woTVrsSt0nlVqn(JddGiXgqj5YYAwrmmig1cMZoJOJq4r(Lfq(N1RS(jRTzbAJGiA8hhgauq54iJOTLSSMfKS((YkmRhzznRTz5WNiJdS)bkhhjUi4HZmzbKS8ww)K12SUrsSt0ydE0cXgysKJsSbusUSSMfKS((YkmRhz99LveJLomamrJ)4WaG6gwKeJ(ZcyYGISM4XXSrMfq(NferHvwwZABwctweG0MBXc5eDeJpsumc65tO(Jeby(WotwFFzDCyklGKfKWSEK1dTFcYL87T2XrkrN4XXmuj3CAliMJhNdV0MHzK2EWUnN1(atAR9(atA)frqcdJreebhyKYSEgpoMLfGYnNq(wzTfYdTFUa2OnBGP)aU5WbYQTbpjDV)nlZrJ88ZAKgaRnuKKgdP7VcHSbKqTHImy7vKmk06PDaFk6LhCqcMyNcQThSBFGjTBoCGSABWts37FZYC0ip)SgPrpDhsOcT2aLnGsYPcu7oU4woTfMSUrsSt0nlVqn(JddGiXgqj5YYAwBZkIHbXOwWC2zeDecpYVSaY)SEL1pzTnlqBeerJ)4WaGckhhzeTTKL1SGK13xwHz9iRVVSIyS0HbGjA8hhgau3WIKy0FwatguK1epoMnYSaY)SGikSY6NS2M1nsIDIelijXw4mGrn(JddGrKJsSbusUSSMfKS((YkmRhz9q7NGCj)ERDCKs0jECmdvYnN2cI54X5WlTzygPThSBZzTpWK2AVpWK2FreKWWyebrWbgPmRNXJJzzbOCZjKVvwBF9q7NlGnAZgy6pGBoCGSABWts37FZYC0ip)SgPbWAdfjPXq6(RqiBajuBOid2EfjJcTEAhWNIE5bhKGj2PGA7b72hys7MdhiR2g8K09(3SmhnYZpRrA0t3HarHwBGYgqj5ubQDhxClN2rmmig1cMZoJy0ETi2Lfq(NLqZ6NS8EwcizTnRTzbAJGiE(ekcFzoumc65tOoACI2wYYAw3ij2joSJh5wMJJzIeBaLKlRhzznliz99LvywpY6NS2M12SUrsSt0rKfAHAU1CdWeSiXgqj5YYAwctwG2iiIg)XHbafuooYiABjlRzTnl4HDsc1zVMJJzz9pRWS((YYqhkiMzBepoTEfI6nlXSaswHz9ilRzTnlHjlqBeeXZNqr4lZHIrqpFc1rJt02swFFzfCw8busIoJpQdzY6rwpYYAwqY67lRWSEK13xwBZkIHbXOwWC2zeJ2RfXUSaY)S8wwwZkIHbXOwWC2zeDecpYVSe()SELL1SM4XdsOeJG5KjlG8plVNL1SM4XdsOeJG5KjlH)plVL1JS((YABwGyJjlRzDZcy6epomHEyuhNe(FizznRiggeJAbZzNrmAVwe7Yci)ZY7z9q7NGCj)ERDCKs0jECmdvYnN2cI54X5WlTzygPThSBZzTpWK2AVpWK2FreKWWyebrWbgPmRNXJJzzbOCZjKVvwB9(dTFUa2OnBGP)aU5WbYQTbpjDV)nleoJB8bS2qrsAmKU)keYgqc1gkYGTxrYOqRN2b8POxEWbjyIDkO2EWU9bM0U5WbYQTbpjDV)nleoJB81t3H8sHwBGYgqj5ubQDhxClN2G2iiINpHIWxMdfJGE(eQJgN4IGhoZKfqYcswwZkIHbXOwWC2zeJ2RfXUSaY)S8EwwZAIhpiHsmcMtMSeEwVYYAwctwG2iiIg)XHbafyYC2lYiABr7NGCj)ERDCKs0jECmdvYnN2cI54X5WlTzygPThSBZzTpWK2AVpWK2FreKWWyebrWbgPmRNXJJzzbOCZjKVvwB92dTFUa2OnBGP)aU5WbYQTbpjDV)nleoJB8bS2qrsAmKU)keYgqc1gkYGTxrYOqRN2b8POxEWbjyIDkO2EWU9bM0U5WbYQTbpjDV)nleoJB81t3H4DfATbkBaLKtfO2DCXTCAhCw8busIoJpQdzYYAweG0MBXc5epFcfHVmhkgb98juhnUSSMLdFImoW(hOCCK4IGhoZKLW)N12SIyS0HbGjAEddILgumcQJMZxCrWdNzY6NSGeM1JSSMveJLomamrZByqS0GIrqD0C(IlcE4mtwc)FwVYYAwrmmig1cMZoJy0ETi2Lfq(N1lTFcYL87T2XrkrN4XXmuj3CAliMJhNdV0MHzK2EWUnN1(atAR9(atA)frqcdJreebhyKYSEgpoMLfGYnNq(wzTvOp0(5cyJ2SbM(d4MdhiR2g8K09(3Sq4mUXhWAdfjPXq6(RqiBajuBOid2EfjJcTEAhWNIE5bhKGj2PGA7b72hys7MdhiR2g8K09(3Sq4mUXxpDhI3uO1gOSbusovGA3Xf3YPT2pb5s(9w74iLOt84ygQKBoTfeZXJZHxAZWmsBpy3MZAFGjT1U9Xa4b74iCAzuqT3hys7VicsyymIGi4aJuM1Z4XXSSauU5eY3kRTcWdTFUa2OnBGP)aU5WbYQTbpjDV)nlqBU0byTHIK0yiD)viKnGeQnuKbBVIKrHwpTd4trV8GdsWe7uqT9GD7dmPDZHdKvBdEs6E)BwG2CPtp90UTqr(i5c7ZXXmD)Laarpvba]] )

    storeDefault( [[SimC Subtlety: precombat]], 'actionLists', 20171223.230208, [[dStXgaGEOuQnHOAxQOxRsz2KA(s0nHK7su42i8Cc7eL2RYUr1(LQrjknmu8BKEmedLOOgSKgov0bvHoLO4yIQJtuKfkszPuPwmuTCsEirPNszziY6GsHjcLIMkvYKPQPRQlsu1RuP6zIeDDvYHf2kuYMjY2HIZdPAwIeMguk57uHtlLVPcgTe2MiPtks1FfX1GuUhrL3cLQpJOCzWlFUMjppW1GF4ZydcyM1iKTxTl8xdp6yJE1PcqOe4XpZnOHqaJLet(HCsKiDMpZqunN)Szhr(gLlMRXMpxZKNh4AWV0MziQMZFgitxnNob)POi8uhjI4rxjsCe6B9k59A2En1E9EVkeosuG0f3NqLKeW3Rz61YYELz2r8MU9OpdtOAbUgMLo33qINQMXPCygkQhRqXgeWmHWrIcKU4(zSbbmRersIHbbrsc72tvqVIvOVazuQMDurMygpia5echjkq6I7tbMqFbYbY0vZPtWFkkcp1rIiE0vIehH(g5zt9Uq4irbsxCFcvssaFMYsMzUbnecySKyYpKZmZniOxkeqmx7NjBbGCdffdqa8F4Zqr9SbbmB)yjnxZKNh4AWV0MziQMZFw2Env06179A2E9dnW)tmnYOQZwcWdCn47vY71uIwVww2Rm9AME9EVMTx)qd8)KiepOsOsjIIWtDioBjapW1GVxjVxZz61YYELPxZ0R37vmHQf4A4uiCKOaPlUVxZm7iEt3E0NHjuTaxdZsN7BiXtvZ4uomdf1JvOydcyM4Hq)fjFHcefuTFgBqaZkrKKyyqqKKWU9uf0Ryf6lqgLQEnBEMzhvKjMXdcqoXdH(ls(cfikOAFkWe6lqUSPI29SFOb(FIPrgvDc8axdEYtjALLmzUN9dnW)tIq8GkHkLikcp1H4e4bUg8KNZuwYK5oMq1cCnCkeosuG0f3NzMBqdHagljM8d5mZCdc6LcbeZ1(zYwai3qrXaea)h(muupBqaZ2p2uoxZKNh4AWV0MziQMZFw(5bsO1R371S96hAG)NahdOPoBCYsefHN6qC2saEGRbFVsEVYCEGeA9AzzVY0RzMDeVPBp6ZWeQwGRHzPZ9nK4PQzCkhMHI6XkuSbbmtu4tKubY3O8qpJniGzLissmmiissy3EQc6vSc9fiJsvVMLuMzhvKjMXdcqorHprsfiFJYdDkWe6lqU8ZdKq7E2p0a)pbogqtD24KLikcp1H4e4bUg8KZCEGeALLmzM5g0qiGXsIj)qoZm3GGEPqaXCTFMSfaYnuumabW)Hpdf1ZgeWS9JfBnxZKNh4AWV0MDeVPBp6Zepe6Vyw6CFdjEQAgNYHzOOEScfBqaZMXgeWm7Hq)fZCdAieWyjXKFiNzMBqqVuiGyU2pt2ca5gkkgGa4)WNHI6zdcy2(XI2CntEEGRb)sB2r8MU9OpJiu3aFIevL4H4lMLo33qINQMXPCygkQhRqXgeWSzSbbmdvOUb(EvIQ6vSjeFXSJkYeZCQaekbE8YLpZnOHqaJLet(HCMzUbb9sHaI5A)mzlaKBOOyacG)dFgkQNniGz7hBQZ1m55bUg8lTzhXB62J(mN0Vr5ZsN7BiXtvZ4uomdf1JvOydcy2m2GaMvIijXWGGijHDzM(nkxgLQzUbnecySKyYpKZmZniOxkeqmx7NjBbGCdffdqa8F4Zqr9SbbmB)(zMtaPf6g2o(gLpwsPMVFda]] )

    storeDefault( [[SimC Subtlety: stealth als]], 'actionLists', 20171223.230208, [[dau0haqiIsTiivBsvkJcs6uqkRIOKxreLUfruSlvXWuuhdGLjiptfuttfKRPc02uiQVPczDaQ5Pc4EqI9Pq4GevluvQEivAIeHlQc1jHOmtiIBkGDQGLcipLYuvLSvisVfIQ7sezVi)vrgSKdR0IPIhtyYQQltAZc1NvOgTqonuVwH0SbDBG2nv9BugUaDCfISCv65OA6IUUkA7efFxqDEiSEIOA(eP9l1ea6fzh7xhO(jhYgwqLmdd62LD6KqnraCx8uxyg11c5KbKc1LR0qOzahbiuOqpaiZexCWKmYKlsmZZPx0aa6fzh7xhO(P3jZexCWKm1R3XiE(AmwGZUoakDjZEXRduF4PUWmAkJUkpIb)Djz6k0b7swDHAxO2LS7sWyWplS)zm7QGBy(Kdo1NZGD9wxYUlNZ44Nyv)y)4P4R6LCepNb7cTUERlaDjvAxZDHwxV1fQDj7U0r6ehmO(F4r7NfEIVjIlFk8chTlPs7sWyWplS)HhTFw4P)6f6JiAVJv(u8DfjM5xyxJaLUKzV41bQp8O)u8DfjM5xyxsL2L617yepFnglWzxJaLUam3fAKj3bdXjcYeleoTIeZ8tqmpjdz(pwSj7sMN5vYcW(iDVdlOsgzdlOsMurC88SqehJC3fc7sUiXmFxibZtjj9sM87yoz(furbDdd62LD6KqnraCx8uxyg1LReC0jdifQlxPHqZaocWmzaPC25vOC6fLK5gPIrdWKrbvFsoKfG9hwqLmdd62LD6KqnraCx8uxyg1LReCkPHq0lYo2Voq9tVtMjU4GjzGRpH60)8UjM57AeDf65WKj3bdXjcYeleoTIeZ8tqmpjdz(pwSj7sMN5vYcW(iDVdlOsgzdlOsMurC88SqehJC3fc7sUiXmFxibZtjj92fQaqJm53XCY8lOIc6gg0Tl70jHAIa4U4PUWmQlxj4OtgqkuxUsdHMbCeGzYas5SZRq50lkjZnsfJgGjJcQ(KCila7pSGkzgg0Tl70jHAIa4U4PUWmQlxj4usdhMEr2X(1bQF6DYmXfhmjBfjwgDs9kiw5Dncu66qKj3bdXjcYeleoTIeZ8tqmpjdz(pwSj7sMN5vYcW(iDVdlOsgzdlOsMurC88SqehJC3fc7sUiXmFxibZtjj92fQHqJm53XCY8lOIc6gg0Tl70jHAIa4U4PUWmQlxj4OtgqkuxUsdHMbCeGzYas5SZRq50lkjZnsfJgGjJcQ(KCila7pSGkzgg0Tl70jHAIa4U4PUWmQlxj4usdhIEr2X(1bQF6DYmXfhmjd1Uemg8Zc7F4r7NfguH)NZGD9wxYUlbJb)SW(hzwpMh9CgSR36sWyWplS)HhTFw4P)6f6JiAVJvExhaLUa0fAKj3bdXjcYeleoTIeZ8tqmpjdz(pwSj7sMN5vYcW(iDVdlOsgzdlOsMurC88SqehJC3fc7sUiXmFxibZtjj92fQhgnYKFhZjZVGkkOByq3UStNeQjcG7IN6cZOUCLGJozaPqD5kneAgWraMjdiLZoVcLtVOKm3ivmAaMmkO6tYHSaS)WcQKzyq3UStNeQjcG7IN6cZOUCLGtjnCq6fzh7xhO(P3jZexCWKSCVJ18jXG6uYM(yTRd0fGqDjRUemg8Zc7F4r7NfE6VEH(iI27yLpfFxrIz(f2LS6c1Ua0LKTlu7shPtCWG6)HhTFw4j(MiU8PWlC0UERlaDjvAxZDHwxYQR5Nd2fAKj3bdXjcYeleoTIeZ8tqmpjdz(pwSj7sMN5vYcW(iDVdlOsgzdlOsMurC88SqehJC3fc7sUiXmFxibZtjj92fQhcnYKFhZjZVGkkOByq3UStNeQjcG7IN6cZOUCLGJozaPqD5kneAgWraMjdiLZoVcLtVOKm3ivmAaMmkO6tYHSaS)WcQKzyq3UStNeQjcG7IN6cZOUCLGtjLKzbvbEHyjFtmZtdHgzausea]] )

    storeDefault( [[SimC Subtlety: CDs]], 'actionLists', 20171223.230208, [[dyuGraqikr2Ki6tifQgfiCkGQvrcXRqkYSiHKUfLuTlKmmf1XuWYaLEgqktJskDnsO2gsbFJsY4OeLohjKQ1rcPmpfk3deTprWbfHwiLWdviMiqQUOcPnsjQ8rsiXjbsUjs1ojPHsjflvr6PsMQIyRku9wkrXDPevTxu)frdMQdl1Ir4XaMmHldTzr6ZaXOPuNMuVMemBv52QQDt0Vvz4KOJJuilNINlQPR01bPTdu(osPXJuuNhuSEKcL5dQ2VW8apHRrLnXdfmbxQ9h5Q0)rcVGsSpCHrrl8ra9mxtXh2zKvHDEWQbyHfwQbUkaJw5YfxjcS6tM5jS6apHRrLnXdfSfCvagTYLlcOPPueV7epO5LcQYWHdpCicN4Y5Wtg(2gqWLA1FKCpsHgdFmidNgMdh8WHdpCicNaAAkfyTuNTPGQm8KHdr4eqttPY2T4OLK41cmtbvz4WHhoWDpXrRKkB3IJwsIxlWmLb)TwMdFmidh0Mdh8WbNRej0p9cdxkVvFsUaLuOb69mCjpjYf9tmEBu7pYfxQ9h5coqA68maqAQLXAUvFslpCdxtXh2zKvHDEWQHzUMI5dQbaZ8eE5AeBeqb6hy4hLltWf9tO2FKlEzvy5jCnQSjEOGTGRcWOvUCLxSFRnkOmhiqrUsKq)0lmCr8UtqMc1adxGsk0a9EgUKNe5I(jgVnQ9h5Il1(JCzX7or4woOgy4Ak(WoJSkSZdwnmZ1umFqnayMNWlxJyJakq)ad)OCzcUOFc1(JCXlRcA8eUgv2epuWwWvby0kxUYl2V1gfuMdeOixjsOF6fgUiqtgnkOLGWfOKcnqVNHl5jrUOFIXBJA)rU4sT)ixwGMmAuqlbHRP4d7mYQWopy1WmxtX8b1aGzEcVCnIncOa9dm8JYLj4I(ju7pYfVSQ1Yt4Auzt8qbBbxfGrRC5kVy)wBuqzoqGIHNmCuIgqGHsGPAa9gEcHB1mxjsOF6fgUAdqlrY9mguUCbkPqd07z4sEsKl6Ny82O2FKlUu7pYvIgGwIHp5mguUCnfFyNrwf25bRgM5AkMpOgamZt4LRrSrafOFGHFuUmbx0pHA)rU4LvvmpHRrLnXdfSfCvagTYLllf(2puUucSxBYuZ9jBIdmKcLnXdfCLiH(Pxy4kdZN4EzYlLuG9AZfOKcnqVNHl5jrUOFIXBJA)rU4sT)ixfmFI7Ld)sdh0XET5Ak(WoJSkSZdwnmZ1umFqnayMNWlxJyJakq)ad)OCzcUOFc1(JCXlRsd8eUgv2epuWwWvby0kxUGi8TFOCPeyV2KPM7t2ehyifkBIhkcpz4a39ehTskb2RnzQ5(KnXbgszWFRL5WhdYWhcpz4qeU4wkPge7L41cKYG)wlZHNaKHdC3tC0kPeyV2KPM7t2ehyiLb)TwMdNMch0cho8W32acUuR(JK7rk0y4wpCXTusni2lXRfiLb)TwMdFmidNgch8WtgoeHV6pgEcqgoOfoC4HNXLK4KqZuRgnWotATkbcpHWNdho8WrAeuTsLOGATrYuTjVKxk5AJKcSfHdE4GhoC4HVTbeCPw9hj3JuOXWTE4g83Azo8XGm8HzUsKq)0lmCLH5tCVm5LskWET5cusHgO3ZWL8Kix0pX4TrT)ixCP2FKRcMpX9YHFPHd6yV2HdXa4CnfFyNrwf25bRgM5AkMpOgamZt4LRrSrafOFGHFuUmbx0pHA)rU4LvTINW1OYM4Hc2cUkaJw5Y12gqWLA1FKCpsHgdFSWbUpXrQ80YntjWunGE5krc9tVWW1VnkGcY0ZqkWET5cusHgO3ZWL8Kix0pX4TrT)ixCP2FKl6TrbueE6zch0XET5Ak(WoJSkSZdwnmZ1umFqnayMNWlxJyJakq)ad)OCzcUOFc1(JCXlRAz5jCnQSjEOGTGRcWOvUCzPWZl2V1gfu97fEYWbUpXrQ80YntjWunGEdpbidhqj5VPzYSsuk4krc9tVWW1VnkGcY0ZqkWET5cusHgO3ZWL8Kix0pX4TrT)ixCP2FKl6TrbueE6zch0XETdhIbW5Ak(WoJSkSZdwnmZ1umFqnayMNWlxJyJakq)ad)OCzcUOFc1(JCXlRQOZt4Auzt8qbBbxfGrRC5cIWx9hdpHWhMdpz4a3N4ivEA5MPeyQgqVHNaKHdB40u4qeEEX(T2OGQFVWtg(q4WHh(C4GhU1dhIWrAeuTsLOG63Y9HKxk5AJK)oVOHSZ5oN1YWtg(q4WHh(C4Gho4HdhE4qe(Q)y4Jf(WC4jdhIWTu4B)q5s9BJcOGm9mKcSxBku2epueoC4HdCFIJu5PLBMsGPAa9gEcqgoOfoC4HlULsQbXEjETaPwnGcAjiHdE4GZvIe6NEHHRSDloAjjETaZCbkPqd07z4sEsKl6Ny82O2FKlUu7pYvz3IJ2WT41cmZ1u8HDgzvyNhSAyMRPy(GAaWmpHxUgXgbuG(bg(r5YeCr)eQ9h5IxwDyMNW1OYM4Hc2cUkaJw5YLLcpVy)wBuq1Vx4jdh4UN4OvsLTBXrlPOLaifGDBabZKPMgy1NSFHpgKHdwB0nXdPY2cYutdS6t2VWtgoeHdr4a3N4ivEA5MPeyQgqVHNaKHBTHB9WHi8v)XWhl8H5Wtg(q4WHh(C4GhUIeoSHNmCuIgqGHsGPAa9gEcHR45WPPWHi8TFOCPatdYzO0KOSjEOi8KHpeoC4Hpho4HRiHdRId36Hdr4R(JHNaKHpmhEYWhcho8WNdh8WvKWhuC4GhoC4Hdr4a3N4ivEA5MPeyQgqVHNaKHpeEYW32acUuR(JK7rk0y4JfULnCWdhCUsKq)0lmCbYzWFtBMKqVixGsk0a9EgUKNe5I(jgVnQ9h5Il1(JCPOCg830sJNd3c9ICnfFyNrwf25bRgM5AkMpOgamZt4LRrSrafOFGHFuUmbx0pHA)rU4Lvhg4jCnQSjEOGTGRej0p9cdxkV7rAW8b1aGCbkPqd07z4sEsKRrSrafOFGHFuUmbx0pX4TrT)ixCzn39SCNrfP5LTGl1(JCbhinDEgain1Yyn39cFkMpOga0Yd3WvIgqYCLEgsjsZlKdkQinVMMS)hu5cPIvS1Hy7hkxQSDloAjtpaOzku2epuKCao8zWvKHzUSM7EJsZRPz1zUMI5dQbaZ8eE5Ak(WoJSkSZdwnmZf9tO2FKlEz1by5jCnQSjEOGTGRcWOvUCHs0acmuaqnguUHNaKHRyfhU1dhIW3(HYLkB3IJwY0daAMstIYM4HIWtg(q4WHh(C4GhUIe(WC4jdhS2OBIhsjY2KI0o8KHdr4wkCKgbvRujkO(TCFi5LsU2i5VZlAi7CUZzTmC4WdNaAAkvgMpX9YKxkPa71McQYWbp8KHdC3tC0kPY2T4OLu0saKcWUnGGzYutdS6t2VWhdYWbRn6M4HuzBbzQPbw9j7x4jd3sHtannLkB3IJwsrlbqkOkdpz4wkCcOPPu5f73Atbvz4jd)3Y9HKcOME1NmCidFo8KHdr4IBPKAqSxIxlqkd(BTmhEcqgoWDpXrRKsG9AtMAUpztCGHug83AzoCAkCAi8KHBPWHiCcOPPuRnsMQn5L8sjxBKuGTGYG)wlZHNq4dHNmCG7tCKkpTCZuaqnguUHNaKHR4WbpC4WdFBdi4sT6psUhPqJHB9Wf3sj1GyVeVwGug83Azo8XGmCAiCWdpz4a39ehTskb2RnzQ5(KnXbgszWFRL5WhdYWhcho8W32acUuR(JK7rk0y4Jbz4wXvIe6NEHHlWAPoBZfOKcnqVNHl5jrUOFIXBJA)rU4sT)ixJ3sD2MRP4d7mYQWopy1WmxtX8b1aGzEcVCnIncOa9dm8JYLj4I(ju7pYfVS6aOXt4Auzt8qbBbxfGrRC5YsHtannLkB3IJwsrlbqkOkdpz4BBabxQv)rY9ifAm8XGmCRnCAkCicF7hkxQmuIfnPqbbP0KOSjEOi8KHpeoC4Hpho4CLiH(Pxy4kB3IJwsrlbqUaLuOb69mCjpjYf9tmEBu7pYfxQ9h5QSBXrB4GElbqUMIpSZiRc78GvdZCnfZhudaM5j8Y1i2iGc0pWWpkxMGl6NqT)ix8YlxLseq3pnnwV6tYQWsdd8Yma]] )

    storeDefault( [[SimC Subtlety: finish]], 'actionLists', 20171223.230208, [[dSJohaGEGs1Mij7IqVMczFKGMTOMVu6MkKBRKNl0oLI9s1UjA)iJIKAyuu)MupMGdlzWqdxK6Gkuofj6ya5CaLYcvOAPavlwrlxQEOc0tv1YOiRdOKopfmvLIjtPPRYfvq9kru9mGsCDLQtdARKqTzbTDrYNfHVtHAAkaZte5Va(gqXOfyBIOCssi3sb01ib6Ekixg1QibCiLs7G8n(pSSMz26t)BQf7)dxds4VpVmFgaRegcLWyG)GZzUIS3yYmiWaYKjtIG8)f6W0N)(pMWb1YOVXBa5B8FyznZS1h3)xOdtF(RMWTeEvMLNOT6gbedkR2yrwwZmBjSTLWTeo3ddfJbLvBmGTKcS4EAcvsOkcVQNGpXdUyGtdyHmHdKWoVkOmsOcjmzeQIq1eUk5Lza7EVoOws4qeAMW2wc78QGYiHjneHRsEzgWU3RdQLeQKqveQMq1e25WohdQzMjufHQjClHHqzLHNbcBBjCUhgkgcLvgEgaKWeb3mxwwCpnHTTeMQ6WAMzrBmaWgweQKqLe22syNxfugjmjcpOGrahCXeQaeAIqLeQIq1ewchmfdWsEb5iHjr4aiufHBjmv1H1mZI2yaGnSiSTLWTeo3ddfJgwtDocOdbSCDbI7PjuP)JnHz4zWFjmrWnZLL9xrsluOoD3FPwY(psBvC1BQf7V)n1I9VbMi4M5YY(doN5kYEJjZGadiZ(doh17Dbo6B8Z)bdybJgPtXlwE(0)rABtTy)9ZBm5B8FyznZS1h3)xOdtF(RMWTeEvMLNOLRlaiSRxa1uNIfzznZSLW2wcJ8bm1Y9O4b5oiWgGP0ceQqcntOscvrOAc3s4vzwEI2QBeqmOSAJfzznZSLW2wc3s4CpmumguwTXa2skWI7PjujHQi8QEc(ep4IbonGfYeoqc78QGYiHkKqqMiufHRsEzgWU3RdQLeoeHMjufHQjunHDoSZXGAMzcvrOAc3syiuwz4zGW2wcN7HHIHqzLHNbajmrWnZLLf3ttyBlHPQoSMzw0gdaSHfHkjujHTTe25vbLrctIWdkyeWbxmHkaHMiujHQiunHLWbtXaSKxqosyseoacvr4wctvDynZSOngaydlcBBjClHZ9WqXOH1uNJa6qalxxG4EAcv6)ytygEg8xcteCZCzz)hmGfmAKofVy55t)hPTkU6n1I93FfjTqH60D)LAj7FtTy)BGjcUzUSmHQbP0)X6jI(lyqiZax1tWxCiq(doN5kYEJjZGadiZ(doh17Dbo6B8Z)bniK5nvpbFrFC)hPTn1I93pVbS4B8FyznZS1h3)xOdtF(35vbLrctIqbToB1glfJgwtDocOdbSCDbIDEvqzKWKtiiZeQIqbToB1glfJgwtDocOdbSCDbIDEvqzKWKgIqfKWKtOAcvtOGEn1aP1q5fff27DwEeoeHjJqLeQIqqe22sOzcvsOkcVQNGpXdUyGtdyHmHdKWoVkOmsOcjuqRZwTXsXOH1uNJa6qalxxGyNxfugjm5eQG(p2eMHNb)LWeb3mxw2FfjTqH60D)LAj7)iTvXvVPwS)(3ul2)gyIGBMlltOAtk9hCoZvK9gtMbbgqM9hCoQ37cC034N)dgWcgnsNIxS88P)J02MAX(7N3maFJ)dlRzMT(4(p2eMHNb)5uWOa3RJ9xrsluOoD3FPwY(psBvC1BQf7V)n1I9F4uWOa3RJ9hCoZvK9gtMbbgqM9hCoQ37cC034N)dgWcgnsNIxS88P)J02MAX(7NF()PzbyLHG96GAP3ykzG8ZDa]] )

    storeDefault( [[SimC Subtlety: build]], 'actionLists', 20171223.230208, [[dSdweaGEQiAtQQQ2fQABOs2NQQYSLQ5tfPBsb3LkvFJkLDsP2l0UfSFjJIkmmQQ(nkpMqhwPblA4sjhKQItrHoMQ0BPQ0cPIAPQIfJWYrArsHNsAzOI1rfHZtWuvvMSctxLlsvQxHkvEgQu11PiNMOTQQkBMQOTlf9ruP0LbFMI67QQ41sPUTqJgrJNkPtQQs3IQKRrL4EOsXdPk8Cf9xkz8f)q17Ws0HbsGQ2ceLBx6K7jzb0MdxVOQIuzRdvuFGoStaT54)1TxoC4W)I6dSdHpzeqfca1SGVv24KrW6ywnQKNVshvcbGAwGpUUwPxv6OYMlvUeDGFEW2psRJKctswFujJwjxUuPXknwP7O6J4jzHj(H2V4hQEhwIomqNrvfPYwhQR4jBcwqaIsyw5)4Mk5uj3vPJkjm5PN8hjy5PKoplMNwhjynGDWBQvL)VY3kDQtR0FLgr9hsi8a7qa1Piv26q93WqkUhJIAGfaunWg)Tu7ncOIQpeYU8eqDsAIkBdbR5XOruT3iGQsAIkBdHk1JrJO(atMjQimXp8q9b6Wob0MJ)x3E9J6dSdHpzeqfca1SGVv24KrW6ywnQKNVshvcbGAwGpUUwPxv6OYMlvUeDGFEW2psRJKctswFujJwjxUuPXknwP7O6bji22aRjeHWHeOAGnS3iGkEOnh8dvVdlrhgOZO(djeEGDiG6uKkBDO(Byif3JrrnWcaQgyJ)wQ9gbur1hczxEcOAUZyrI(oauT3iGk32zSirFhaQpWKzIkct8dpuFGoStaT54)1Tx)O(a7q4tgbuHaqnl4BLnozeSoMvJk55R0rLqaOMf4JRRv6vLoQS5sLlrh4NhS9J06iPWKK1hvYOvYLlvASsJv6oQEqcITnWAcriCibQgyd7ncOIhAZ94hQEhwIomqNr9hsi8a7qa1Piv26q93WqkUhJIAGfaunWg)Tu7ncOIQpeYU8eqLyfBpVLav7ncO68k2EElbQpWKzIkct8dpuFGoStaT54)1Tx)O(a7q4tgbuHaqnl4BLnozeSoMvJk55R0rLqaOMf4JRRv6vLoQS5sLlrh4NhS9J06iPWKK1hvYOvYLlvASsJv6oQEqcITnWAcriCibQgyd7ncOIhEOAVravvg9Os1eX1HtWjQKWKSpWdra]] )


    storeDefault( [[Subtlety Primary]], 'displays', 20171223.230208, [[dSdVgaGEf4LifTlqiEniyMuvA2s1nrkCyjFdeQEoP2jv2Ry3e2pf5NkQHbv(nKNHOOHIkdMIA4iCqP0NbPJrHJJuAHsXsjkTyKSCk9qQQEQQhJsRdrPMirrtfktgPA6kDrf5QefUmW1b1gjQ2kiK2mQA7iYhPQ40Kmnef67uLrIOQLPGgnkgpi6Kqv3crjxdrLZtKTbcL1IOGBRqhJGLZweRcjKJe7xPoiFwgy(I3nLVLfky5iXfQCBjGc8ZayHqAYPfgadA7kOIrGyZzZLM551G1FrSkKqhhUCiN551G1FrSkKqhhUCcRASSs4zrIRgaIJC4YhvI2P4iZCAHbWa6(lIvHe60KlnZZRblwzHcwDC4Y1miV7PwwM2P0KRzqETWlkn5JfKhloJ8TSqbBRGLbzZBMXWMPHS49H8y5sXrwdnWLdzC4Y1mipSYcfS60KdbQwbldYMJnZjlEFipwUsqxXwlY2kyzq2CzX7d5XYzlIvHeTcwgKnVzgdBMg5NaWQQUAqTkKiUHqmJCndY7yPjNwyamqMklGDvirUS49H8y5c4r8SiHooYyUMa07Y7LMXpQJSblVIZiNkoJCOXzKBJZiBUMb55ViwfsOdvoKZ88AW2cBR4WLxW2ctIaKtbZZNpwq2cVO4WLt1vdg4th5127HkV6em1zqECKMIZiV6emLF0ivTCKMIZixMa(cUVHkV6ELKMJexAYjP0kkvxTsyseGCQC2IyvirBxbvK7FYHnjBoDLMOxsyseGC652safGjraYlkvxTs5fSTOHsastoeOKJe7vdaXzmmV6emfwzHcwosCXzKBb9C)toSjzZ1eGExEV0mHkV6emfwzHcwostXzKtlmagqhVGUITwKvNMCxncYpm12bRKjZCw1yzLY3YcfSYrI9RuhKpldmFX7MYhvIw4ffhUCiqjhj2VsDq(SmW8fVBkNwyamGoEwK4QbG4ihU8QtWuTDVssZrIloJCiN551GLMn64mYjSQXYkjhj2RgaIZyyoHfWIgPQTLZ38Rg9BY8HP2oyLiBtMjSaw0ivT5kwKGmGqJXzqU8XcY2P4WLZJeBohMjZVeAtMDL1I8Y3YcfSCKMcvUIfjorXQeqJJC5Yc6GsdYhIZaIBmCizcrmYP6Qbd8PJ8cvoKZ88AWIxqxXwlYQJdxU0mpVgS4f0vS1IS64WLVLfkyLJeBohMjZVeAtMDL1I8YHCMNxdwSYcfS64WLRzqE4f0vS1IS60KRzqETW2cVGhfQ8Q7vsAostPjxZG84inLMCndYRDkn5SOrQA5iXfQ8c2wTcwgKnVzgdBMg(ojhlVGT1ja9oEzghUCAHvSqaIQ0FL6G8kFujowC4Y3YcfSYrI9QbG4mgMxW2cVGhHjraYPG55ZzlIvHeYrInNdZK5xcTjZUYArE5vNGP8JgPQLJexCg5tIIQdONMCTAKOdANNIByU0mpVgSTW2koC5qGsosS5CyMm)sOnz2vwlYlV6emvB3RK0CKMIZiNTiwfsihj2RgaIZyyolAKQwostHkxZG8OjqIsjOReq1PjxZG84iXLMCndY7EQLLPfErPjV6em1zqECK4IZiNwyamGUCKyVAaioJH5sZ88AWsZgDCKLroTWayaDA2OttoDaFb33woFZVA0VjZhMA7GvISnzMoGVG7BEbBlziuBorVKa2Sja]] )


end

