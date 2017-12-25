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
        addAura( "death_from_above", 152150, "duration", 1 )
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
        addAura( "shuriken_combo", 245650, "duration", 15, "max_stack", 5 )

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

        addMetaFunction( 'state', 'gcd', function()
            return 1.0
        end )
        -- We don't want to auto-advance to the next GCD because we have to use some off-GCD abilities while in DfA.
        class.NoGCD = true

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
                if resource == 'combo_points' then
                    if state.spec.subtlety then
                        if amt > 0 and state.equipped.denial_of_the_halfgiants then
                            if state.buff.shadow_blades.up then
                                state.buff.shadow_blades.expires = state.buff.shadow_blades.expires + 0.2 * amt
                            end
                        end

                        if state.talent.alacrity.enabled and amt >= 5 then
                            state.addStack( "alacrity", 20, 1 )
                        end
                    end
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


        addSetting( 'shadow_dance_energy', 90, {
            name = "Shadow Dance: Energy",
            type = "range",
            desc = "Set the amount of energy that is required before Shadow Dance will be recommended.",
            min = 0,
            max = 100,
            step = 1,
            width = "full"
        } )


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


        -- Death from Above
        --[[ Finishing move that empowers your weapons with shadow energy and performs a devastating two-part attack.     You whirl around, dealing up to 96,125 damage to all enemies within 8 yds, then leap into the air and Eviscerate your target on the way back down, with such force that it has a 50% stronger effect. ]]

        addAbility( "death_from_above", {
            id = 152150,
            spend = 25,
            min_cost = 25,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            talent = "death_from_above",
            cooldown = 20,
            min_range = 0,
            max_range = 15,
            usable = function () return combo_points.current > 0 end,            
        } )

        addHandler( "death_from_above", function ()
            local cost = min( 5 + ( talent.deeper_stratagem.enabled and 1 or 0 ), combo_points.current )
            spend( cost, "combo_points" )
            gainChargeTime( "shadow_dance", cost * ( 1.5 + ( talent.enveloping_shadows.enabled and 1 or 0 ) ) )
            applyBuff( "death_from_above" )
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
            gainChargeTime( "shadow_dance", cost * ( 1.5 + ( talent.enveloping_shadows.enabled and 1 or 0 ) ) )
            if artifact.finality.enabled then
                if buff.finality_eviscerate.up then removeBuff( "finality_eviscerate" )
                else removeBuff( "finality_eviscerate" ) end
            end
            removeBuff( "shuriken_combo" )
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
            equipped = 'fangs_of_the_devourer'
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
            gainChargeTime( "shadow_dance", cost * ( 1.5 + ( talent.enveloping_shadows.enabled and 1 or 0 ) ) )
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
            gain( 5 + ( talent.deeper_stratagem.enabled and 1 or 0 ), "combo_points" )
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

            gainChargeTime( "shadow_dance", cost * ( 1.5 + ( talent.enveloping_shadows.enabled and 1 or 0 ) ) )

            if artifact.finality.enabled then
                if buff.finality_nightblade.up then removeBuff( "finality_nightblade" )
                else applyBuff( "finality_nightblade" ) end
            end

            applyDebuff( "target", "nightblade", 6 + ( cost * 2 ) )
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
            ready = function ()
                return max( energy[ "time_to_" .. ( settings.shadow_dance_energy or 100 ) ], buff.shadow_dance.remains )
            end,
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
            if active_enemies > 1 then
                addStack( "shuriken_combo", 15, active_enemies - 1 )
            end
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
            known = 1784,
            spend = 0,
            cast = 0,
            gcdType = "off",
            cooldown = 2,
            min_range = 0,
            max_range = 0,
            usable = function () return ( time == 0 ) and not stealthed.all end,
            passive = true,
        }, 115191 )

        modifyAbility( "stealth", "id", function( x )
            if talent.subterfuge.enabled then return 115191 end
            return x
        end )

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


    storeDefault( [[SimC Subtlety: stealthed]], 'actionLists', 20171224.211129, [[d4JBhaGEcuAtuvTlHSnvsv7JGAMeO65uz2kA(Qs3KQYDji62QQVjPYofQ9ISBI2pPrridtL63qDyGZlvzWugUu5GeWPiuhtIoNesTqcKLcblgslxflscXtfTmjL1brCAqtvQQjlLPR0fvj5vsOUmQRlWZKu1wHq2SG2oe1NHq9AjyAeOyEsi5Tee(lvz0sY3vfDsis3sLu5AQKY9ufEScpuL44eKMkP(uELeGo5gHszm4ZuMW)f1Ya0DYBpKOMBzWCR4gLiWtg4ykU2DzDL1QvlQKYSJhqWekyblelP4AxFjLcmwiw6O(uCj1NYRKa0j3ibrzooWULs0GWWi3YG5wff0rPaOWjC7rPRc0WpD7bwGPePYgCaw8HsjwYu6d3qe4ed(mLugd(mLzfOHF62dSatjc8KboMIRDxwx5nLiWoCWzWoQpTuEPIhf8HrM)SCjuk9HBXGptjTuCnQpLxjbOtUrcIYCCGDlLd8hf71HHY1fncohwUQj8d1UMAfRMi1eP2cMSCJAm3Xhp3EalaX8pc6Xsa6KBQ5xn0GWWiKbsORkkOtnXQ5xTs1EFv7wnXQ5xnrQbglez2JL8hYo1e(HA1RwXQjsnwObWUoUf5Qan8tphy7DCEpbZcQ5xTs1EFv7wnXQ9(QMi1(a5ozVwWbSqSuTI6HALr1RMF1(a5ozVwWbSqSunHFO2Du9QjwnXukakCc3EuoaZPhySqS0BcDlLiv2GdWIpukXsMsF4gIaNyWNPKYyWNP8DegEFpgHHcXfWCQMaJfILQj4q3kKVhkf4GyhLsWNFuKe(VOwgGUtE7He1cHsORQiuIapzGJP4A3L1vEtjcSdhCgSJ6tlLxQ4rbFyK5plxcLsF4wm4ZuMW)f1Ya0DYBpKOwiucDv0sX1t9P8kjaDYnsquMJdSBPenimmYvbA4NFE2IA4Ns18RMi1eP2a)rXEDyOCDrnoeoGRAc)qTAQvSAIuJfAaSRJBrqPdIyje4Hd9oaKzzfE2w18RwPAVVQDRMy18RgySqKzpwYFi7ut4hQvVAfRMi1yHga764wKRc0Wp9CGT3X59emlOMF1kv79vTB1eRMy1EFvtKAd8hf71HHY1f14q4aUQj8d1kvZVAObHHrBf71omOnXNMZRXdgUrUfmkOMWpuRwrRMy1etPaOWjC7rPRk4alWsp3IpFkrQSbhGfFOuILmL(WneboXGptjLXGptzwfCGfyPA5IpFkrGNmWXuCT7Y6kVPeb2Hdod2r9PLYlv8OGpmY8NLlHsPpClg8zkPLIfmuFkVscqNCJeeL54a7wkh4pk2RddLRlAeCoSCvt4hQDn1kwnrQjsTfmz5g1yUJpEU9awaI5Fe0JLa0j3uZVAObHHridKqxvuqNAIvZVALQ9(Q2TAIvZVAd8hf71HHY1f14q4aUQvuQvVAfRMi1qdcdJCvGg(Ph6e0yxuqNA(vRuT3x1UvtSAxNAIuJfAaSRJBrFGCNSho0BRyVpWT8Xd4CaNdkvZVALQ9(Q2TAIPuau4eU9OCaMtpWyHyP3e6wkrQSbhGfFOuILmL(WneboXGptjLXGpt57im8(EmcdfIlG5unbglelvtWHUviFpQjQumLcCqSJsj4Zpksc)xuldq3jV9qIAHqj0vvekrGNmWXuCT7Y6kVPeb2Hdod2r9PLYlv8OGpmY8NLlHsPpClg8zkt4)IAza6o5ThsulekHUkAP4Rr9P8kjaDYnsqukakCc3Eu6Qan8t3EGfykrQSbhGfFOuILmL(WneboXGptjLXGptzwbA4NU9alWQjQumLiWtg4ykU2DzDL3uIa7WbNb7O(0s5LkEuWhgz(ZYLqP0hUfd(mL0slL54a7wkPLia]] )

    storeDefault( [[SimC Subtlety: stealth CDs]], 'actionLists', 20171224.211129, [[dieUhaqiiuBsk1OuP6uqWQir6vKiMfjqUfjiTlOAyIQJPKwgu6zKqnnsuxJeO2gjO8nLcRJeqZtjs3dIAFqKdkfAHkf9qPGjQeQlkfzJKG4Kqi3KKStkAOkrSuLspvXuvQSvLOEljO6UkH0Er9xvzWchwYIH0JvXKj1Lr2SO8zPOgnfonLETsWSLQBRQ2nHFdmCsQJReILlYZjA6GUUkz7Qu(UuY4jHCELQwpjaZhk2pvZR8oEAsuODsZO8ywFINX(BWJ5cf2j4EfOhsivDOHhnSyjpBPovsInXMVUXkwSyXx5zuthB1TkGcAbc2eRcBLNgpqlqi5DS5kVJNMefAN08M8mNKvnKhe7XTkzl0oHRLgpDw5rBp(La2PN(kvqlq4bYEK7rBpoaqxdAjWLgLg06PlXHWpgvQzs(Ys1bAbIQ7Xs94wLSfANWLg6xwQoqlquDpuIh394Uh0ICzvRM04)sa70dK9Gg07xsiLELuwsPv4rBpG2p5Xs9qX5EGGhT9y1dmy8i3de8qPEKJRypA7XDpqSh0ICzvRM04)sa70dK9Gg07xsiLELuwsPv4bgmEGELLHl3)rbD5dK90ubnWVu7bc80iQTBH755wjSsdEqKqBpfeK4raeepQa6LRKz9jE4XS(eplxcR0GNTuNkjXMyZx3ynNNTKeCLoKK3XqEAWGolOcCJ(KaYO8OcOnRpXddztS8oEAsuODsZBYZCsw1qEogvQzs(Ys1bAbIQ7bsi7XTkzl0oHln0VSuDGwGO6EGbJhWk1mbXH2p9GGN2sESupoaqxdAjWL7)OGU8bYEAQGg4j6xwHKNgrTDlCppsJsdA90L4q8GiH2EkiiXJaiiEub0lxjZ6t8WJz9jEgJsdA5XIlXH4zl1PssSj281nwZ5zljbxPdj5DmKNgmOZcQa3OpjGmkpQaAZ6t8Wq2uX8oEAsuODsZBYtJO2UfUNh1aq)Lij4kDiEqKqBpfeK4raeepnyqNfubUrFsazuE2sDQKeBInFDJ1CEub0lxjZ6t8WZsaGUcbKmjfb5n5XS(epyozz55NtwMcFjaq3JTKeCLo0IIjXtJPML8KbspbPiiYRkisrWu9Qp4sarw5CEwca0BsrWuXMkNZZyaAPcOTzwkjzuE2ssWv6qsEhd5rfqBwFIhgYMkZ74PjrH2jnVjpZjzvd5HeuQ594NRuIeqpqczpuo3J2Eqck18ECnLzpwOhiHShR5EOepUvjBH2jCPS1lrzxcnpnIA7w4EEKgLg06tDnpisOTNccs8iacIhva9YvYS(ep8ywFINXO0GwFQR5zl1PssSj281nwZ5zljbxPdj5DmKNgmOZcQa3OpjGmkpQaAZ6t8Wq2ubZ74PjrH2jnVjpZjzvd5bXECRs2cTt4APXtNvE02Jd4JcEQbwbuIRPm7Xc9ajK9aRhkXJ7EaRojG4YluiLYUAMWTpsuODs7rBpw9adgpY9abpuQhy9OTh39a9kldxU)Jc6Yhi7PPcAGNOFzfspqczpwXX6bgmECaGUg0sGl3)rbD5dK90ubnWt0VScPhiHShRy9qjEC3J7EaRojG46kTWtAuAqlC7JefAN0E02djbFOaXLehAPe28NYQpEGKh5EGGhT9y1dmy8i3de8qPEOypuOEC3J7EGypGvNeqCDLw4jnknOfojk0oP9OThsc(qbIljo0sjS5pLvF8ajpY9abpA7XQhyW4rUhi4Hs9qzpWGXJFjGD6PVsf0ceEGKh5EGGhT94Uh1bAVrpsqFlj9ajK9qzpWGXde7b6vwgo0GEz2Ke(azpOb90uPXVu7bc80iQTBH75rAuAqRNUehIhej02tbbjEeabXJkGE5kzwFIhEmRpXZyuAqlpwCjoKh3xrGNTuNkjXMyZx3ynNNTKeCLoKK3XqEAWGolOcCJ(KaYO8OcOnRpXddzipZjzvd5HHmd]] )

    storeDefault( [[SimC Subtlety: default]], 'actionLists', 20171224.211129, [[dqeqxaqikjSiGkBIQyuQcNsv0QaG0RaiZIaj3caI2fHggv1XaYYuL6zsv00KQW1iqTnaW3OKACaq4Cei16aqZJss3dq2hb4GsvTqcOhkLmrkjYfbOojqvVKsIYmjqCtQs7uQSua1tfnvvfBvQsVLsWDPeAVK(lKgSshwYIb5XcnzQCzKndXNvvA0sXPr1RPenBIUnO2nu)gLHtqhhaQLl45umDvUoLA7sP(oq58QswpLevZxv1(vScs)OjGXfKKCkKMDfmPzYHBnBAdDs6EbWzDeszlpnbMKuziT7TpiRb9(9BrqAMcPiVKCR864mS29gaaPz)4XzyJ(r7aPF0eW4cssovGAMXax4P5vHV0j6iiBeeXyzoo(ROTqn7kystRmE0sn7dXL87LMwYJwQj4XoESowqtmdtAcmjPYqA3BFqwdYxtGjdZoejJ(rp90U36hnbmUGKKtfOMzmWfEAEv4lDIocYgbrmwMJJ)kAluZUcM0SFiwyA2pSqGWNM9H4s(9sZkelmHESqGWNMGh74X6ybnXmmPjWKKkdPDV9bzniFnbMmm7qKm6h90t76P(rtaJlij5ubQzgdCHNMea2Mlui5ennLJbgQPUxbdkyL0Yz9m7JzbGzb0SgdyObcXg7qziig6M95S))Z6RzFiUKFV0SDf4fKK0e8yhpwhlOjMHjn9YC9wHUcM00yadnqi2yNMDfmP5FebX3pgrqSqESanBVL0MS4FqZ(HVgnXfmbKXagAGqSXobv7sAtarayBUqHKt00uogyOM6EfmOGvsl98aaaKXagAGqSXougcIHUN))(AcmjPYqA3BFqwdYxtGjdZoejJ(rpnB1qrl9YAtWe(uin9YCDfmPPEAxp0pAcyCbjjNkqnZyGl808XSaGGNfqZ(y2RKe(eBZ)YcIeUGKKBwpZ2tbp7))S(Z(Cwan7JzVss4teUmhfqziOMMYXaZis4cssUz9mli)z))N1F2NZcOzBxbEbjjrJbm0aHyJDZ(uZ(qCj)EPz7kWlijPj4XoESowqtmdtA6L56TcDfmPP5OsEnOxtGmnmPtZUcM08pIG47hJiiwipwGMT3sAtw8pm7dqp1SF4RrtCbtazoQKxd61eitdt6euTlPnb0daqWa6XvscFIT5FzbrcxqsY5PNc()3)jGECLKWNiCzokGYqqnnLJbMrKWfKKCEa5))7)eqTRaVGKKOXagAGqSXUNAcmjPYqA3BFqwdYxtGjdZoejJ(rpnB1qrl9YAtWe(uin9YCDfmPPEANG1pAcyCbjjNkqnZyGl80eKO1Vf8SaA2hZELKWNiHBtsMqo(lQPPCmWmIeUGKKBwpZ6lA9Bbp7))S(Z(uZ(qCj)EPz7kWlijPj4XoESowqtmdtA6L56TcDfmPPPXHIeQ4Xz4sQzxbtA(hrq89JreelKhlqZ2BjTjl(hM9X7NA2p81OjUGjGmnouKqfpodxsbv7sAtabs063cgqpUss4tKWTjjtih)f10uogygrcxqsY5Xx063c()3)PMatsQmK292hK1G81eyYWSdrYOF0tZwnu0sVS2emHpfstVmxxbtAQN2ba6hnbmUGKKtfOMzmWfEAELKWNOJQRbfjWGrliwBsKWfKKCZ6z2RKe(eDvWsutt5yGjs4cssUz9mBfpEBcLWemNmZA1z7HM9H4s(9sZ2vGxqsstWJD8yDSGMygM00lZ1Bf6kystNPb1HuA2vWKM)reeF)yebXc5Xc0S9wsBYI)HzF0ZNA2p81OjUGjGCMguhsjOAxsBcORKe(eDuDnOibgmAbXAtIeUGKKZZvscFIUkyjQPPCmWejCbjjNNkE82ekHjyozSAp0eyssLH0U3(GSgKVMatgMDisg9JEA2QHIw6L1MGj8PqA6L56kyst90oR1pAcyCbjjNkqnZyGl808kjHprxfSe10uogyIeUGKKBwpZ(ywRywZrL8AiNyjLZ()plKncIOXg6OaI9xs0w4SpN1ZSq2iiIoQUguKadgTGyTjrBHZ6zwiBeerhvxdksGbJwqS2KyGGlo2mRvbAwFrqcwZ(qCj)EPPPPCmWqDfosAcESJhRJf0eZWKMEzUERqxbtAQzxbtAMnLJb2SwPchjnbMKuziT7TpiRb5RjWKHzhIKr)ONMTAOOLEzTjycFkKMEzUUcM0upTdaH(rtaJlij5ubQzFiUKFV0mwsjAfpodJk5MttWJD8yDSGMygM00lZ1Bf6kystn7kysZ)icIVFmIGyHwLuoB)4Xz4zfeU5S4FqZ(HVgnXfmbe4soCRztBOts3laoBlRKbCAcmjPYqA3BFqwdYxtGjdZoejJ(rpnB1qrl9YAtWe(uin9YCDfmPzYHBnBAdDs6EbWzBzLm6PDcA9JMagxqsYPcuZmg4cpnnhvYRHCILuQzFiUKFV0myJrR4Xzyuj3CAcESJhRJf0eZWKMEzUERqxbtAQzxbtA(hrq89JreelaSnE2(XJZWZkiCZzX)GM9dFnAIlyciWLC4wZM2qNKUxaCwZrL8Aih40eyssLH0U3(GSgKVMatgMDisg9JEA2QHIw6L1MGj8PqA6L56kysZKd3A20g6K09cGZAoQKxd50t7a5RF0eW4cssovGAMXax4P5vHV0jECyc9yOoonRaMfaM1ZSbcU4yZSwD2Vr3SEMnYGHyOczC8zeJ2HaHVzfaqZ2Jzbqo7JzpomnRvNfK)SEMf0S))Z6p7ZzbqN9TM9H4s(9stm)BZbjlhPj4XoESowqtmdtA6L56TcDfmPPMDfmPzh)BZbjlhPjWKKkdPDV9bzniFnbMmm7qKm6h90SvdfT0lRnbt4tH00lZ1vWKM6PDGaPF0eW4cssovGAMXax4P5vscFIUkyjQPPCmWejCbjj3SEMnYGHyOczC8zeDecpYVzfaqZ(Ewan7JzHSrqennLJbgkKSCKr0w4SEMf0S))Z6p7Zz9m7JzDSteZ)2CqYYrIbcU4yZScy2EmlGM9XSxjj8jASHokGy)Le5OeUGKKBwpZcA2))z9N95S))ZgzmPJbgw00uogyOUchjXytf(sguKqfpodxYzfaqZcsuqpRNzFmRvmlbGT5cfsorhH5LeLHGEneAtjr(Yl8zM9)F2JdtZkGzb5p7ZzFQzFiUKFV0mwsjAfpodJk5MttWJD8yDSGMygM00lZ1Bf6kystn7kysZ)icIVFmIGyHwLuoB)4Xz4zfeU5S4Fy2hGEQz)WxJM4cMacCjhU1SPn0jP7faN1CujVMzlPbCAcmjPYqA3BFqwdYxtGjdZoejJ(rpnB1qrl9YAtWe(uin9YCDfmPzYHBnBAdDs6EbWznhvYRz2sA0t7a9w)OjGXfKKCQa1mJbUWttRy2RKe(eDvWsutt5yGjs4cssUz9m7JzJmyigQqghFgrhHWJ8Bwba0SVNfqZ(ywiBeertt5yGHcjlhzeTfoRNzbn7))S(Z(C2))zJmM0XadlAAkhdmuxHJKySPcFjdksOIhNHl5ScaOzbjkONfqZ(y2RKe(ejCBsYeYXFrnnLJbMrKJs4cssUz9mlOz))N1F2NZ(uZ(qCj)EPzSKs0kECggvYnNMGh74X6ybnXmmPPxMR3k0vWKMA2vWKM)reeF)yebXcTkPC2(XJZWZkiCZzX)WSpE)uZ(HVgnXfmbe4soCRztBOts3laoR5OsEnZwsd40eyssLH0U3(GSgKVMatgMDisg9JEA2QHIw6L1MGj8PqA6L56kysZKd3A20g6K09cGZAoQKxZSL0ON2bQN6hnbmUGKKtfOMzmWfEAgzWqmuHmo(mIr7qGW3ScaOzf8SaA2Eola6SpM9XSq2iiIxdHIWdMdLHGEneQJkNOTWz9m7vscFIf(4rUW64mSiHlij5M95SEMf0S))Z6p7Zzb0SpM9XSxjj8j6isifqnxOU6lbls4cssUz9mRvmlKncIOPPCmWqHKLJmI2cN1ZSpMfUWNKqD2H64m8SanR)S))ZAOdfIHTnIhNcV9r7HW4Scyw)zFoRNzFmRvmlKncI41qOi8G5qziOxdH6OYjAlC2))zBxbEbjjrNPb1HuZ(C2NZ6zwqZ()pR)SpN9)F2hZgzWqmuHmo(mIr7qGW3ScaOz7XSEMnYGHyOczC8zeDecpYVzTkqZ(EwpZwXJ3MqjmbZjZScaOz75SEMTIhVnHsycMtMzTkqZ2JzFo7))SpMfIzmZ6z2RcFPt84We6XqDCYQabAwpZgzWqmuHmo(mIr7qGW3ScaOz75Sp1SpexYVxAglPeTIhNHrLCZPj4XoESowqtmdtA6L56TcDfmPPMDfmP5FebX3pgrqSqRskNTF84m8Scc3Cw8pm7JE(uZ(HVgnXfmbe4soCRztBOts3laolchZnnGttGjjvgs7E7dYAq(Acmzy2Hiz0p6PzRgkAPxwBcMWNcPPxMRRGjntoCRztBOts3laolchZnn6PDG6H(rtaJlij5ubQzgdCHNMq2iiIxdHIWdMdLHGEneQJkNyGGlo2mRaMf0SEMnYGHyOczC8zeJ2HaHVzfaqZ2Zz9mBfpEBcLWemNmZA1zFpRNzTIzHSrqennLJbg6xYC2bYiAluZ(qCj)EPzSKs0kECggvYnNMGh74X6ybnXmmPPxMR3k0vWKMA2vWKM)reeF)yebXcTkPC2(XJZWZkiCZzX)WSp6Xtn7h(A0exWeqGl5WTMnTHojDVa4SiCm30aonbMKuziT7TpiRb5RjWKHzhIKr)ONMTAOOLEzTjycFkKMEzUUcM0m5WTMnTHojDVa4SiCm30ON2bsW6hnbmUGKKtfOMzmWfEA2Uc8cssIotdQdPM1ZSea2Mlui5eVgcfHhmhkdb9AiuhvUz9mRJDIy(3MdswosmqWfhBM1Qan7JzJmM0XadlAEbdXKgugcQJQRrmqWfhBMfqZcYF2NZ6z2iJjDmWWIMxWqmPbLHG6O6AedeCXXMzTkqZ(EwpZgzWqmuHmo(mIr7qGW3ScaOzFRzFiUKFV0mwsjAfpodJk5MttWJD8yDSGMygM00lZ1Bf6kystn7kysZ)icIVFmIGyHwLuoB)4Xz4zfeU5S4Fy2hc(PM9dFnAIlyciWLC4wZM2qNKUxaCweoMBAaNMatsQmK292hK1G81eyYWSdrYOF0tZwnu0sVS2emHpfstVmxxbtAMC4wZM2qNKUxaCweoMBA0t7aba6hnbmUGKKtfOMzmWfEAQzFiUKFV0mwsjAfpodJk5MttWJD8yDSGMygM00lZ1Bf6kystnbMmm7qKm6h90SRGjn)Jii((XicIfAvs5S9JhNHNvq4MZI)HzFaap1SF4RrtCbtabUKd3A20g6K09cGZczZLoWPjWKKkdPDV9bzniFnZggyEzoocNcgfsZwnu0sVS2emHpfstVmxxbtAMC4wZM2qNKUxaCwiBU0PNEAMXax4PPEQc]] )

    storeDefault( [[SimC Subtlety: precombat]], 'actionLists', 20171224.211129, [[dStXgaGEOuQnHOAxQOTjsA2KA(s0nHK7su42i8Cc7eL2RYUr1(LQrjknmu8BKEmedLOOgSKgov0bvHoLO4yIQJtuKfkszPuPwmuTCsEirPNszziY6GsHjcLIMkvYKPQPRQlsu1RuP6zIeDDvYHf2kuYMjY2HIZdPAwIeMguk57uHtlLVPcgTeETkLtks1FfX1GuUhrL3cLQpJOCzWlFUMjppW1GF4ZydcyM1iKTxTl8xdp6yJE1PcqOe4XpZnOHqaJLet(HCsKiDMpZCciTq3W2X3O8Xsk18zhr(gLlMRXMpxZKNh4AWV0MziQMZFgitxnNob)POi8uhjI4rxjsCe6B9k59A2En1E9EVkeosuG0f3NqLKeW3Rz61YYELz2r8MU9OpdtOAbUgMLo33qINQMXPCygkQhRqXgeWmHWrIcKU4(zSbbmRersIHbbrsc72tvqVIvOVazuQMDurMygpia5echjkq6I7tbMqFbYbY0vZPtWFkkcp1rIiE0vIehH(g5zt9Uq4irbsxCFcvssaFMYsMzUbnecySKyYpKZmZniOxkeqmx7NjBbGCdffdqa8F4Zqr9SbbmB)yjnxZKNh4AWV0MziQMZFw2Env06179A2E9dnW)tmnYOQZwcWdCn47vY71uIwVww2Rm9AME9EVMTx)qd8)KiepOsOsjIIWtDioBjapW1GVxjVxZz61YYELPxZ0R37vmHQf4A4uiCKOaPlUVxZm7iEt3E0NHjuTaxdZsN7BiXtvZ4uomdf1JvOydcyM4Hq)fjFHcefuTFgBqaZkrKKyyqqKKWU9uf0Ryf6lqgLQEnBEMzhvKjMXdcqoXdH(ls(cfikOAFkWe6lqUSPI29SFOb(FIPrgvDc8axdEYtjALLmzUN9dnW)tIq8GkHkLikcp1H4e4bUg8KNZuwYK5oMq1cCnCkeosuG0f3NzMBqdHagljM8d5mZCdc6LcbeZ1(zYwai3qrXaea)h(muupBqaZ2p2uoxZKNh4AWV0MziQMZFw(5bsO1R371S96hAG)NahdOPoBCYsefHN6qC2saEGRbFVsEVYCEGeA9AzzVY0RzMDeVPBp6ZWeQwGRHzPZ9nK4PQzCkhMHI6XkuSbbmtu4tKubY3O8qpJniGzLissmmiissy3EQc6vSc9fiJsvVMLuMzhvKjMXdcqorHprsfiFJYdDkWe6lqU8ZdKq7E2p0a)pbogqtD24KLikcp1H4e4bUg8KZCEGeALLmzM5g0qiGXsIj)qoZm3GGEPqaXCTFMSfaYnuumabW)Hpdf1ZgeWS9JfBnxZKNh4AWV0MDeVPBp6Zepe6Vyw6CFdjEQAgNYHzOOEScfBqaZMXgeWm7Hq)fZCdAieWyjXKFiNzMBqqVuiGyU2pt2ca5gkkgGa4)WNHI6zdcy2(XI2CntEEGRb)sB2r8MU9OpJiu3aFIevL4H4lMLo33qINQMXPCygkQhRqXgeWSzSbbmdvOUb(EvIQ6vSjeFXSJkYeZCQaekbE8YLpZnOHqaJLet(HCMzUbb9sHaI5A)mzlaKBOOyacG)dFgkQNniGz7hBQZ1m55bUg8lTzhXB62J(mN0Vr5ZsN7BiXtvZ4uomdf1JvOydcy2m2GaMvIijXWGGijHDzM(nkxgLQzUbnecySKyYpKZmZniOxkeqmx7NjBbGCdffdqa8F4Zqr9SbbmB)(zgIQ58NTFda]] )

    storeDefault( [[SimC Subtlety: stealth als]], 'actionLists', 20171224.211129, [[dau0haqiIsTiivBsvkJcs6uqkRIOKxreLUfruSlvXWuuhdGLjiptfuttfKRPc02uiQVPczDaQ5Pc4EqI9Pq4GevluvQEivAIeHlQc1jHOmtiIBkGDQGLcipLYuvLSvisVfIQ7sezVi)vrgSKdR0IPIhtyYQQltAZc1NvOgTqonuVwH0SbDBG2nv9BugUaDCfISCv65OA6IUUkA7efFxqDEiSEIOA(eP9l1ea6fzh7xhO(jhYgwqLmdd62LD6KqnraCx8uxyg11c5KbKc1LR0qOzahbiuOqpaiZcQc8cXs(MyMNgcnYaitUiXmpNErdaOxKDSFDG6NENmtCXbtYuVEhJ45RXybo76aO0Lm7fVoq9HN6cZOPm6Q8ig83LKPRqhSlz1fQDHAxYUlbJb)SW(NXSRcUH5to4uFod21BDj7UCoJJFIv9J9JNIVQxYr8CgSl066TUa0LuPDn3fAD9wxO2LS7shPtCWG6)HhTFw4j(MiU8PWlC0UKkTlbJb)SW(hE0(zHN(RxOpIO9ow5tX3vKyMFHDncu6sM9IxhO(WJ(tX3vKyMFHDjvAxQxVJr881ySaNDncu6cWCxOrMChmeNiitSq40ksmZpbX8KmK5)yXMSlzEMxjla7J09oSGkzKnSGkzsfXXZZcrCmYDxiSl5IeZ8DHempLK0lzYVJ5K5xqff0nmOBx2Ptc1ebWDXtDHzuxUsWrNmGuOUCLgcnd4iaZKbKYzNxHYPxusMBKkgnatgfu9j5qwa2FybvYmmOBx2Ptc1ebWDXtDHzuxUsWPKgcrVi7y)6a1p9ozM4IdMKbU(eQt)Z7MyMVRr0vONdtMChmeNiitSq40ksmZpbX8KmK5)yXMSlzEMxjla7J09oSGkzKnSGkzsfXXZZcrCmYDxiSl5IeZ8DHempLK0BxOcanYKFhZjZVGkkOByq3UStNeQjcG7IN6cZOUCLGJozaPqD5kneAgWraMjdiLZoVcLtVOKm3ivmAaMmkO6tYHSaS)WcQKzyq3UStNeQjcG7IN6cZOUCLGtjnCy6fzh7xhO(P3jZexCWKSvKyz0j1RGyL31iqPRdrMChmeNiitSq40ksmZpbX8KmK5)yXMSlzEMxjla7J09oSGkzKnSGkzsfXXZZcrCmYDxiSl5IeZ8DHempLK0BxOgcnYKFhZjZVGkkOByq3UStNeQjcG7IN6cZOUCLGJozaPqD5kneAgWraMjdiLZoVcLtVOKm3ivmAaMmkO6tYHSaS)WcQKzyq3UStNeQjcG7IN6cZOUCLGtjnCi6fzh7xhO(P3jZexCWKmu7sWyWplS)HhTFwyqf(Fod21BDj7Uemg8Zc7FKz9yE0ZzWUERlbJb)SW(hE0(zHN(RxOpIO9ow5DDau6cqxOrMChmeNiitSq40ksmZpbX8KmK5)yXMSlzEMxjla7J09oSGkzKnSGkzsfXXZZcrCmYDxiSl5IeZ8DHempLK0BxOEy0it(DmNm)cQOGUHbD7YoDsOMiaUlEQlmJ6Yvco6KbKc1LR0qOzahbyMmGuo78kuo9IsYCJuXObyYOGQpjhYcW(dlOsMHbD7YoDsOMiaUlEQlmJ6YvcoL0WbPxKDSFDG6NENmtCXbtYY9owZNedQtjB6J1Uoqxac1LS6sWyWplS)HhTFw4P)6f6JiAVJv(u8DfjM5xyxYQlu7cqxs2UqTlDKoXbdQ)hE0(zHN4BI4YNcVWr76TUa0LuPDn3fADjRUMFoyxOrMChmeNiitSq40ksmZpbX8KmK5)yXMSlzEMxjla7J09oSGkzKnSGkzsfXXZZcrCmYDxiSl5IeZ8DHempLK0BxOEi0it(DmNm)cQOGUHbD7YoDsOMiaUlEQlmJ6Yvco6KbKc1LR0qOzahbyMmGuo78kuo9IsYCJuXObyYOGQpjhYcW(dlOsMHbD7YoDsOMiaUlEQlmJ6YvcoLusMjU4Gjzusea]] )

    storeDefault( [[SimC Subtlety: CDs]], 'actionLists', 20171224.211129, [[dCeVraqiIsTjrQprevmkq0PaHvreXRiIYSiIkDlfQSlKAya5ykyzGINPqvtJOQ6AeLSnKG(grLXruLCoIOkRJiQQ5Pq6EaL9jsCqrslKO4HkuMisixuHyJevP(isOYjvu1krcCtK0ofYqjQklvr5PsMQIyRkQ8wIQWDjQI2lQ)IObt1HLAXi8yatMWLH2Si(SI0OfQttYRjcZwvUTQA3K63QmCI0XrcLLl45IA6kDDqA7avFhjA8er68GsRhju18bv7NY8apHRr0nXdfmbxr9h5Qu)XmVGsSpCHvY38XOOmxZWh2zKJGb0GCdWadm0dCvsrav)uu89QonhbdfoWvQaR60zEchnWt4AeDt8qbldxfqqjD5IaAscnX7oXdAEPHk1C4WnhsZjUC280MVDykU0R6JK7rkuO5JcM5uiiZHWC4WnhsZjGMKqdERv5yAOsnpT5qAob0Ke6CClokjjETaZ0qLAoC4MdC3tCuQPZXT4OKK41cmthWFR0zZhfmZhpiZHWCi4kvc1tTWYL0BvNMR51cfqVxGl9PrUOEI56qu)rU4kQ)ixWbssabcaijrEiF3QoT8eEGRz4d7mYrWaAqUbqCndZh0aaM5j8Y1yXiGeupWXpQxMGlQNiQ)ix8YrWWt4AeDt8qbldxfqqjD5kVy)2yuqhUPqrUsLq9ulSCr8UtqManalxZRfkGEVax6tJCr9eZ1HO(JCXvu)rUK5DNWC5n0aSCndFyNrocgqdYnaIRzy(GgaWmpHxUglgbKG6bo(r9YeCr9er9h5IxoA88eUgr3epuWYWvbeusxUYl2Vngf0HBkuKRujup1clxeyiJbju6PCnVwOa69cCPpnYf1tmxhI6pYfxr9h5sgmKXGek9uUMHpSZihbdOb5gaX1mmFqdayMNWlxJfJasq9ah)OEzcUOEIO(JCXlhj)8eUgr3epuWYWvbeusxUYl2Vngf0HBku080MJAmmfwAbMOauR5PyUCG4kvc1tTWYvhaAnsUxiG6LR51cfqVxGl9PrUOEI56qu)rU4kQ)ixPgaAnA(Kleq9Y1m8HDg5iyani3aiUMH5dAaaZ8eE5ASyeqcQh44h1ltWf1te1FKlE5izXt4AeDt8qbldxfqqjD5s2MV9d1lTa7nMmjCFYM4ahPrDt8qbxPsOEQfwUYW(jUxM8sifyVXCnVwOa69cCPpnYf1tmxhI6pYfxr9h5QG9tCVS5xI5ue2BmxZWh2zKJGb0GCdG4AgMpObamZt4LRXIrajOEGJFuVmbxupru)rU4LJOqEcxJOBIhkyz4QackPlxqA(2puV0cS3yYKW9jBIdCKg1nXdfMN2CG7EIJsnTa7nMmjCFYM4ahPd4Vv6S5JcM5dMN2CinxClTwnnEjETaPd4Vv6S5PaM5a39ehLAAb2Bmzs4(KnXboshWFR0zZLmZhV5WHB(2HP4sVQpsUhPqHMpoZf3sRvtJxIxlq6a(BLoB(OGzofAoeMN2CinFvF08uaZ8XBoC4MNXLK40qZ0RcdWaIu(LcyEkMdYC4WnhPyqvsLIc6ngjtuH8sEjKBmskWwyoeMdH5WHB(2HP4sVQpsUhPqHMpoZd4Vv6S5JcM5dG4kvc1tTWYvg2pX9YKxcPa7nMR51cfqVxGl9PrUOEI56qu)rU4kQ)ixfSFI7Ln)smNIWEJnhYbi4Ag(WoJCemGgKBaexZW8bnaGzEcVCnwmcib1dC8J6Lj4I6jI6pYfVCKC8eUgr3epuWYWvbeusxU2omfx6v9rY9ifk08rnh4(ehP0tP3mTatuaQLRujup1clx)oibkitUaPa7nMR51cfqVxGl9PrUOEI56qu)rU4kQ)ixu7GeOW8KlyofH9gZ1m8HDg5iyani3aiUMH5dAaaZ8eE5ASyeqcQh44h1ltWf1te1FKlE5i5fpHRr0nXdfSmCvabL0LlzBEEX(TXOGUFpZtBoW9josPNsVzAbMOauR5PaM5asj)TKsMLIAbxPsOEQfwU(DqcuqMCbsb2BmxZRfkGEVax6tJCr9eZ1HO(JCXvu)rUO2bjqH5jxWCkc7n2CihGGRz4d7mYrWaAqUbqCndZh0aaM5j8Y1yXiGeupWXpQxMGlQNiQ)ix8YrsE8eUgr3epuWYWvbeusxUG08v9rZtX8bqMN2CG7tCKspLEZ0cmrbOwZtbmZHXCjZCinpVy)2yuq3VN5PnFWC4WnhK5qy(4mhsZrkguLuPOG(369HKxc5gJK)oVyGSZ5oNvAZtB(G5WHBoiZHWCimhoCZH08v9rZh18bqMN2Cinx2MV9d1l9VdsGcYKlqkWEJPrDt8qH5WHBoW9josPNsVzAbMOauR5PaM5J3C4WnxClTwnnEjETaPxfGek9uZHWCi4kvc1tTWYvoUfhLKeVwGzUMxlua9EbU0Ng5I6jMRdr9h5IRO(JCvXT4O0CzETaZCndFyNrocgqdYnaIRzy(GgaWmpHxUglgbKG6bo(r9YeCr9er9h5IxoAaepHRr0nXdfSmCvabL0LlzBEEX(TXOGUFpZtBUrba39ehLA6CClokjfTgaPbI7WumtMeAGvD6(z(OGzo4Dq1epKohlitcnWQoD)mpT5gfaP5gfyU5MBoKMdCFIJu6P0BMwGjka1AEkGzU8B(4mhsZx1hnFuZhazEAZhmhoCZbzoeMljMdJ5Pn3OaZn3CZrngMclTatuaQ18umxwGmxYmhsZ3(H6LgC10lqJ6M4HcZtB(G5WHBoiZHWCjXCyKL5JZCinFvF08uaZ8bqMN28bZHd3CqMdH5sI5dYYCimhoCZnkWCZn3Cinh4(ehP0tP3mTatuaQ18uaZ8bZtB(2HP4sVQpsUhPqHMpQ5YlZHWOai4kvc1tTWY10lG)MYmjHArUMxlua9EbU0Ng5I6jMRdr9h5IRO(JCrXDb83uk5Knxg1ICndFyNrocgqdYnaIRzy(GgaWmpHxUglgbKG6bo(r9YeCr9er9h5IxoAyGNW1i6M4HcwgUkGGs6YfxPsOEQfwUKE3JmG5dAaa5ASyeqcQh44h1ltW18AHcO3lWL(0ixZWh2zKJGb0GCdG4I6jMRdr9h5Il57UN8(crOKUSmCf1FKl4ajjGabaKKipKV7EMpdZh0aakpHh4k1W0mxjxGuJs6c2GKlkPBOj7)bvVGjlznoi3(H6Loh3IJsYKdaAMg1nXdfPhGdheesYaiUKV7EJiPBO5iqCvXhLupHkrHHmldxZW8bnaGzEcVCr9er9h5IxoAagEcxJOBIhkyz4QackPlxOgdtHLgaAiG618uaZCzjlZhN5qA(2puV054wCusMCaqZ0ksu3epuyEAZhmhoCZbzoeMljMpaY80MdEhunXdPf5ysrsBEAZH0CzBosXGQKkff0)wVpK8si3yK835fdKDo35SsBoC4MtanjHod7N4EzYlHuG9gtdvQ5qyEAZbU7jok1054wCuskAnasde3HPyMmj0aR609Z8rbZCW7GQjEiDowqMeAGvD6(zEAZLT5eqtsOZXT4OKu0AaKgQuZtBUSnNaAscDEX(TX0qLAEAZ)TEFiPaAOx1PnhmZbzEAZH0CXT0A104L41cKoG)wPZMNcyMdC3tCuQPfyVXKjH7t2eh4iDa)TsNnxYmNcnpT5Y2CinNaAsc9gJKjQqEjVeYngjfylOd4Vv6S5Py(G5Pnh4(ehP0tP3mna0qa1R5PaM5YYCimhoCZ3omfx6v9rY9ifk08XzU4wATAA8s8AbshWFR0zZhfmZPqZHW80MdC3tCuQPfyVXKjH7t2eh4iDa)TsNnFuWmFWC4WnF7WuCPx1hj3JuOqZhfmZLJRujup1clxG3AvoMR51cfqVxGl9PrUOEI56qu)rU4kQ)ixZ1AvoMRz4d7mYrWaAqUbqCndZh0aaM5j8Y1yXiGeupWXpQxMGlQNiQ)ix8YrdJNNW1i6M4HcwgUkGGs6YLSnNaAscDoUfhLKIwdG0qLAEAZ3omfx6v9rY9ifk08rbZC53CjZCinF7hQx6muIfdjqNI0ksu3epuyEAZhmhoCZbzoeCLkH6Pwy5kh3IJssrRbqUMxlua9EbU0Ng5I6jMRdr9h5IRO(JCvXT4O0CkQ1aixZWh2zKJGb0GCdG4AgMpObamZt4LRXIrajOEGJFuVmbxupru)rU4LxUkGGs6YfVmd]] )

    storeDefault( [[SimC Subtlety: finish]], 'actionLists', 20171224.211129, [[dWt9iaGEffPnrH2fiBJOe7tvsZwkZxKUPQspNk3wPEmr2PISxHDtY(rgff1WOu9BsDyjNNOAWqdNs5qQIoff5yQQohrjzHQkSuIIfRWYLQhQkLvPkHLjkwhrj1evuetvvyYu10v5Ikk9kruEMII66IQttyRkkSzqTDr4ZkQ(ofyAQs18erEnf0FvYOPKVPQOtsuQBPkrxtev3tuQlJ6PahuuYXF8iaZQQrJ9Xiat1MdaqSFJqq(4A8jxwtiSqjCwbqgUXLJJPm2))8ptMmq)bayJLevtmtRtOvXugz5pazjDcTYfpIP)4raMvvJg7JpcaqQlSDbWmHpj8QgRoiF1nC5SkV2aiwvJg7jmnLWNeoYHHHCwLxBWYxkjgk3gHMi0iHx1NZh0j2860lVGj8Le25DjuocFLqzHqJeAMWDPUgV8596eAfHztODcttjSZ7sOCeMu2eUl114LpVxNqRi0eHgj0mHMjSZWD2zvJgtOrcnt4tcHfQQjo5eMMs4ihggcwOQM4KVuI5w3OvEgk3gHPPeMO6IA0yiVZA5HlcnrOjcttjSZ7sOCeMeHNqYW1j2mHVGWmeAIqJeAMWs6ej4fR4TGDeMeHVtOrcFsyIQlQrJH8oRLhUimnLWNeoYHHHCY3dDZT0WlpxNfuUncnfGSgIM4KhaLyU1nALNdGSvEHuD6EauAfhGVA)mQ(uT5aeGPAZbysm36gTYZbqgUXLJJPm2))83EaKHD68Ue7IhXfG3Syjd)QtWBwDXiaF1(PAZbiUykt8iaZQQrJ9Xhbai1f2UayMWNeEvJvhKNRZAb317vn0jyiwvJg7jmnLqhFRHwL7Gob3)LvRm2Ki8vcTtOjcnsOzcFs4vnwDq(QB4YzvETbqSQgn2tyAkHpjCKddd5SkV2GLVusmuUncnrOrcVQpNpOtS51PxEbt4ljSZ7sOCe(kH)zi0iH7sDnE5Z71j0kcZMq7eAKqZeAMWod3zNvnAmHgj0mHpjewOQM4KtyAkHJCyyiyHQAIt(sjMBDJw5zOCBeMMsyIQlQrJH8oRLhUi0eHMimnLWoVlHYryseEcjdxNyZe(ccZqOjcnsOzclPtKGxSI3c2ryse(oHgj8jHjQUOgngY7SwE4IW0ucFs4ihggYjFp0n3sdV8CDwq52i0uaYAiAItEauI5w3OvEoaVzXsg(vNG3S6Ira(Q9ZO6t1MdqaKTYlKQt3dGsR4amvBoatI5w3OvEMqZ)Mcqw95UaijxQXRR6Z5ZL9FaKHBC54ykJ9)p)ThazyNoVlXU4rCb4n5sn(r1NZNl(iaF1(PAZbiUyAMJhbywvnASp(iaaPUW2fGoVlHYrysekP1nV2afKt(EOBULgE556SG68UekhHjJWF7eAKqjTU51gOGCY3dDZT0WlpxNfuN3Lq5imPSjm5eMmcntOzcL07HEztluNdskV3z1ry2ekleAIqJe(tyAkH2j0eHgj8Q(C(GoXMxNE5fmHVKWoVlHYr4RekP1nV2afKt(EOBULgE556SG68UekhHjJWKhGSgIM4KhaLyU1nALNdGSvEHuD6EauAfhGVA)mQ(uT5aeGPAZbysm36gTYZeAoJPaid34YXXug7)F(BpaYWoDExIDXJ4cWBwSKHF1j4nRUyeGVA)uT5aexm9E8iaZQQrJ9XhbyQ2CaMjCDwec31BcZAOtWbq2kVqQoDpakTIdqwdrtCYdGNRZAb317vn0j4aid705Dj2fpIlaYWnUCCmLX()N)2daqQlSDb4jHx1y1b5RUHlNv51gaXQA0ypHPPeAMWNeoYHHHCwLxBWYxkjgk3gHPPewsNibVyfVfSJWxZMW3j0eHgj0mHJCyyiN89q3Cln8YZ1zbLBJW0ucL06MxBGcYjFp0n3sdV8CDwqDExcLJWxZMWF7eMmcD8TgAvUd6eCpJ9172Ki8feMCcnrOrch5WWqNfVGfD3T0WRZIxEU8qDExcLJWKi8NqJeAMWrommeSqvnXjFXjeojUxhdLBJW0uclPtKGxSI3c2ryse(oHMIlMsE8iaZQQrJ9XhbiRHOjo5bGtiCsCVooaYw5fs1P7bqPvCa(Q9ZO6t1MdqaMQnhGztiCsCVooaYWnUCCmLX()N)2dGmStN3Lyx8iUa8Mflz4xDcEZQlgb4R2pvBoaXfxaasDHTlaXfba]] )

    storeDefault( [[SimC Subtlety: build]], 'actionLists', 20171224.211129, [[dSdweaGEQiAtQQQ2fQABOs2NQQYSLQ5tfPBsb3LkvFJkLDsP2l0UfSFjJIkmmQQ(nkpMqhwPblA4sjhKQItrHoMQ0BPQ0cPIAPQIfJWYrArsHNsAzOI1rfHZtWuvvMSctxLlsvQxHkvEgQu11PiNMOTQQkBMQOTlf9ruP0LbFMI67QQ41sPUTqJgrJNkPtQQs3IQKRrL4EOsXdPk8Cf9xkz8f)q17Ws0HbsGQksLTourvBbIYTlDY9KSaAZHRxuFGoStaT54)1TxoC4W)I6dSdHpzeqfca1SGVv24KrW6ywnQKNVshvcbGAwGpUUwPxv6OYMlvUeDGFEW2psRJKctswFujJwjxUuPXknwP7O6J4jzHj(H2V4hQEhwIomqNrvfPYwhQR4jBcwqaIsyw5)4Mk5uj3vPJkjm5PN8hjy5PKoplMNwhjynGDWBQvL)VY3kDQtR0FLgr9hsi8a7qa1Piv26q93WqkUhJIAGfaunWg)Tu7ncOIQpeYU8eqDsAIkBdbR5XOruT3iGQsAIkBdHk1JrJO6bji22aRjeHWHeO(aDyNaAZX)RBV(r9b2HWNmcOcbGAwW3kBCYiyDmRgvYZxPJkHaqnlWhxxR0RkDuzZLkxIoWppy7hP1rsHjjRpQKrRKlxQ0yLgR0DuFGjZeveM4hEOAGnS3iGkEOnh8dvVdlrhgOZO(djeEGDiG6uKkBDO(Byif3JrrnWcaQgyJ)wQ9gbur1hczxEcOAUZyrI(oauT3iGk32zSirFhaQEqcITnWAcriCibQpqh2jG2C8)62RFuFGDi8jJaQqaOMf8TYgNmcwhZQrL88v6OsiauZc8X11k9Qshv2CPYLOd8Zd2(rADKuysY6Jkz0k5YLknwPXkDh1hyYmrfHj(HhQgyd7ncOIhAZ94hQEhwIomqNr9hsi8a7qa1Piv26q93WqkUhJIAGfaunWg)Tu7ncOIQpeYU8eqLyfBpVLav7ncO68k2EElbQEqcITnWAcriCibQpqh2jG2C8)62RFuFGDi8jJaQqaOMf8TYgNmcwhZQrL88v6OsiauZc8X11k9Qshv2CPYLOd8Zd2(rADKuysY6Jkz0k5YLknwPXkDh1hyYmrfHj(HhQgyd7ncOIhEOAVravvg9Os1eX1HtWjQKWKSpWdra]] )

    storeDefault( [[IV Subtlety: Single-Target]], 'actionLists', 20171224.211129, [[d4ZajaGEbuAtkv2fLSnka7ti1Zj8zHQztL5lu(KasoKsr(MI05fODsr7v1UHA)aJIcAys0Vr50O6Yidg0WvWbvkDkb4yuQZjGIfQiwkKAXkz5eDyPEkPLrHwNactesOPcrtwstx0fvQ6vqcEMqW1HWFvuBvavBwc2UqYhPaY8OannLI67sOhtvJJcOgTcnEbK6Kqs3sarxds09eIwPqOxRu42c6BFKx3J7LJQFD1SdPROg4aOIyLokdgiaqLJJ7OajYwgNYROjh1c6MglTNAB04MTSVQEjFiVEDRp5mS4iVP9rEDpUxoQ(jxvVKpKxfj1UCKQwTZbG7aqdbWKhsayKayjaglga6zHl28aJJtHLhHus4eaniaIsaefaqdbWSDeoTACY98Ho5mSfH7LJQa4oa0iaglgawcGbaGbC1SdPR6yxzffPKVbDfn5Owq30yP9u7YROIRCFNm5vmdtxrtcgcPNeh5ZRBxChpdEvm2vwrrk5BqpVPXJ86ECVCu9tUQEjFiVwPfIcfSW84J5Y1vYQYkIbWyXaqqeneaLubjjg7LJaWDzlJtPvYdP5Knx5eagnakPWMJfa4oa0ZcxS5bghNclpcPKWjagDKaikbquaaneaZ2r40Qs0ajNfPStkofAr4E5OkaUdaTbWyXaWsamaamGRMDiD1KhFmxUUsx3U4oEg8kMhFmxUUsxrfx5(ozYRygMUIMCulOBAS0EQD5v0KGHq6jXr(85nJWrEDpUxoQ(jxvVKpKxVA2H0vDSRSIa4exxjX1TlUJNbVkg7kR48Y1vsCfvCL77KjVIzy6kAYrTGUPXs7P2LxrtcgcPNeh5ZN3CZh5194E5O6NCv9s(qE1p2Y4KaaJeancGXIbIOHay2ocNweokYXg444ZIXUYkkSiCVCufa3bG(XwgNeZfKTp5mC7aWObqJwOeadaaJfderdbWnbGz7iCAr4OihBGJJplg7kROWIW9YrvaCha6hBzCsmxq2(KZWTdaJgaTTmGPayaxn7q6Qo2vwraefBSNUUDXD8m4vXyxzfNRn2txrfx5(ozYRygMUIMCulOBAS0EQD5v0KGHq6jXr(85nr5rEDpUxoQ(jxvVKpKxneajmjJh0Qsf4EEcGrdGBUea3bGlefkyjg7kR4CTXEYcXaagaaglgiIlefkyvPohNlizHZ9IffzHy4Qzhsx1GHlMtaGScaiksDoEfn5Owq30yP9u7YROIRCFNm5vmdtxrtcgcPNeh5ZRBxChpdEvemCXCIzwH5k154ZBAah5194E5O6NCv9s(qE1ZcxS5bghNclpcPKWjaAWibWiaG7aWnbGIKAxosvR25aWDay7todBjg7kROiL8nilj11Gxn7q6AG3yUy8kAYrTGUPXs7P2Lxrfx5(ozYRygMUIMemespjoYNx3U4oEg8AunMlgFEZPh5194E5O6NCv9s(qE1ZcxS5bghNclpcPKWjaAWibWiC1SdPR6yxzffPKVbbGgAhWv0KJAbDtJL2tTlVIkUY9DYKxXmmDfnjyiKEsCKpVUDXD8m4vXyxzffPKVb98Mg4J86ECVCu9tUQEjFiVUjauKu7YrQA1ohaUda9SWfBEGXXPWYJqkjCcGgmsamca4oaKWKmEqlpcPKWjaAqaeLLxn7q6QbIjPWUyGsaGt4jDfn5Owq30yP9u7YROIRCFNm5vmdtxrtcgcPNeh5ZRBxChpdEnotsHDrX8IN0ZBgyoYR7X9Yr1p5QzhsxrrQZraSGKfcGBxSOOROjh1c6MglTNAxED7I74zWRvQZX5csw4CVyrrxrfx5(ozYRygMUIMemespjoYNxvVKpKx9SWfBEGXXPWYJqkjCcGrhja6hMd7a9SyGW1N30U8iVUh3lhv)KRMDiDDFuCHNKDsxrtoQf0nnwAp1U862f3XZGxPO4cpj7KUIkUY9DYKxXmmDfnjyiKEsCKpVQEjFiV6zHl28aJJtHLhHus4eaJosaeLaikaGgcGz7iCAvjAGKZIu2zhNcTiCVCufa3bG2aySyayjagWZBABFKx3J7LJQFYvZoKUoP9BiYEDfn5Owq30yP9u7YRBxChpdED1(nezVUIkUY9DYKxXmmDfnjyiKEsCKpVQEjFiV6zHl28aJJtHvLkW98eaJgalF(8QoqEE74b2o5m8nnAa2p)b]] )

    storeDefault( [[IV Subtlety: AOE]], 'actionLists', 20171224.211129, [[d4JQkaGEPkrBscTlQQTjOW(isEoHhtLzl08rr(KGs5WkDBI68sWojv7v1UrSFfJIuYWKOXjOOonsFdegmWWLKdreXPisDmQY5KQewikyPOulgulNKNjO6PuwgPyDckXejIQPIsMSuMUOlkv1RiIYLHUUuzAerARsvsBwq2or4JckY8ar(mkQVds(Ra)uqjnAj14fuQojk0bbPUgiQ7jvXkLQu)gvVMuQV3zDRpzHJy7W30xz8gJ96aSo4mIzHWYaGoS2)gBmIRaVUMspi80Ors99UzofTkVDdAxs5eXzDDVZ6wFYchX2z4M5u0Q8MiXnM1yZFJXbuCaAnahxgMhuXPKu476ukKKdasdaYdqYgGwdi3iss)LKuhTAtkN4JKfoITbuCaAgatmnGYbi9akoG1LujWaKGYuumainGWL(gBmIRaVUMspi8kVXiPrDBYv3iCcEtFLXBw924qjsfvB8gBuW7uouCwpFEDnN1T(KfoITZWnZPOv5Tgc3fkKpHYCDch3g634qrgatmnGP3AnafgsHI6foIdOyUkMX0pPYyqYdAuCasnafkVuIyafhGJldZdQ4usk8DDkfsYbivpdaYdqYgGwdi3iss)gIvOkqKQnrMrzFKSWrSnGIdWBamX0akhG0dq6B6RmEtNYCDch3gEdAyAKMfUrOmxNWXTH3yJcENYHIZ65n2yexbEDnLEq4vEJrsJ62KRUr4e851d)SU1NSWrSDgUzofTkVTUKkbgGeuMIIbaPba5B6RmEZQ3ghQbWqCBO4g0W0inlCtuVnoubWXTHIBSrbVt5qXz98gBmIRaVUMspi8kVXiPrDBYv3iCc(86s6zDRpzHJy7mCZCkAvEZvVkMrXa6zaAgatmn9wRbKBejPpsKaJ8kkH5ar924qj8rYchX2akoax9QygfbHuRlPCYghGudqJpKhG0dGjMMER1aKKbKBejPpsKaJ8kkH5ar924qj8rYchX2akoax9QygfbHuRlPCYghGudWZpmGyasFtFLXBw924qnajFjo8g0W0inlCtuVnoubTL4WBSrbVt5qXz98gBmIRaVUMspi8kVXiPrDBYv3iCc(86q(SU1NSWrSDgUzofTkVb3fkKVOEBCOcAlXH(DvdO4aCCzyEqfNssHFddrD0CasnGYbuCaRlPsGbibLPOyas1Zac)M(kJ3S6ofvBKmal5k5BqdtJ0SWnrDNIQnscejxjFJnk4DkhkoRN3yJrCf411u6bHx5ngjnQBtU6gHtWNxpmoRB9jlCeBNHBMtrRYBAnaKGkMl43WquhnhGudqslhqXba3fkKVOEBCOcAlXH(Dvdq6bWettVH7cfYVHBwhesXLdwyUeOFx1n9vgVzfKH5rXa4HgGKJBwFdAyAKMfUjkidZJIaEOGgUz9n2OG3PCO4SEEJngXvGxxtPheEL3yK0OUn5QBeobFEDioRB9jlCeBNHBMtrRYBoUmmpOItjPW31PuijhaK6zaHpGIdqsgGiXnM1yZFJXbuCaRlPCIVOEBCOePIQn6RWTv4M(kJ361Lqf13GgMgPzHBsSeQO(gBuW7uouCwpVXgJ4kWRRP0dcVYBmsAu3MC1ncNGpVEy(SU1NSWrSDgUzofTkV54YW8GkoLKcFxNsHKCaqQNbe(akoG1LujWaKGYuumainGWVPVY4nREBCOePIQnoaT8K(g0W0inlCtuVnouIur1gVXgf8oLdfN1ZBSXiUc86Ak9GWR8gJKg1TjxDJWj4ZR3loRB9jlCeBNHBMtrRYBoUmmpOItjPWVHHOoAoaPgq5akoG1LujWaKGYuumaP6zaHFtFLXBwDNIQnsgGLCL8a0Yt6BqdtJ0SWnrDNIQnscejxjFJnk4DkhkoRN3yJrCf411u6bHx5ngjnQBtU6gHtWNx3R8SU1NSWrSDgUzofTkVjjdqK4gZAS5VX4akoahxgMhuXPKu476ukKKdas9mGWhqXbGeuXCbFxNsHKCaqAaqU8M(kJ3ctCfkVqf2edGbAI3GgMgPzHBmZvO8cLiaMM4n2OG3PCO4SEEJngXvGxxtPheEL3yK0OUn5QBeobFEDpVZ6wFYchX2z4M5u0Q8MJldZdQ4usk8DDkfsYbivpdWvfiVH9arfsA3yJrCf411u6bHx5nOHPrAw4wd3SoiKIlhSWCjWBSrbVt5qXz98M(kJ3KCCZ6besXLha0WCjWBmsAu3MC1ncNGpVUNMZ6wFYchX2z4M5u0Q8MJldZdQ4usk8DDkfsYbivpdaYdqYgGwdi3iss)gIvOkqKQnxMrzFKSWrSnGIdWBamX0akhG030xz8wFjOchQ2eVbnmnsZc3qjOchQ2eVXgf8oLdfN1ZBSXiUc86Ak9GWR8gJKg1TjxDJWj4ZR7f(zDRpzHJy7mCZCkAvEZXLH5bvCkjf(nme1rZbi1akVPVY4nRUtr1gjdWsUsEaAPr6BqdtJ0SWnrDNIQnscejxjFJnk4DkhkoRN3yJrCf411u6bHx5ngjnQBtU6gHtWNpVzvOJUrAVCtkNCDnHH3ZFa]] )

    storeDefault( [[IV Subtlety: Default]], 'actionLists', 20171224.211129, [[dmt2daGEeQ6LiuSljWRri7JuOzl0nLGUTeTtfTxQDdz)c8tsbdts(TidwqdhP6Gi4yq1cvqlvsTyuSCu9uvldkwNcyIKImvuAYiA6exejDzW1vONlQTQaTzsL2oPu9nj0HLAAKsCEK40k9meknAsfFMu1jrk3cHkxJus3Juu)fk9ys2gPu24M1NkQzIaPz8NDj4tBWGWpYirqOmqqOMaD7XO4xdrOZGNyQWlIJbJwka3)k(sx89jOKnHYM1tCZ6tf1mrG0d9NDj4Fb6OOJFnKtJCfKnRfFcmBCfk(zb6OOJpne5QAjX9rje4xdrOZGNyQWlIx5FfFPl(w8eJz9PIAMiq6H(ZUe8jMvrKFnKtJCfKnRfFcmBCfk(eTkI8PHixvljUpkHa)AicDg8etfEr8k)R4lDXxAUEqkq1zzr6T4jXAwFQOMjcKEO)SlbFcCvJGGq2eNdiXVgYPrUcYM1IpbMnUcf)MRAeGvsCoGeFAiYv1sI7JsiWVgIqNbpXuHxeVY)k(sx8LMRhKcuDwwKElEQfZ6tf1mrG0d9NDj4xyZjcidc1nXdc1e0Io(1qonYvq2Sw8jWSXvO4x2CIasS6M4yjHw0XNgICvTK4(Oec8RHi0zWtmv4fXR8VIV0fFvQKjHLEArsUasq3vTsqOg1CqOwT4PwnRpvuZebsp0F2LG)xK(ieeY2C9G4FfFPl(TswTdybeuUqoiuZbH4(1qe6m4jMk8I4v(ey24ku85JiSTs2ecBCZIFnKtJCfKnRfFAiYv1sI7JsiWVWe5SlbFAdge(rgjccLbcc)I0hbIJT56bXINAZS(urntei9q)zxc(e0av)R4lDXVvYQDalGGYfYbHAmie3VgIqNbpXuHxeVYNaZgxHIpFeHTvYMqyJBw8RHCAKRGSzT4tdrUQwsCFucb(fMiNDj4tBWGWpYirqOmqqibnq1If)thuBhxIVLnH8eJ2WTyd]] )


    storeDefault( [[Subtlety Primary]], 'displays', 20171224.211129, [[dSdVgaGEf4LOc2fiuEniyMuvA2s1nru1JrQVHOqhwYoPyVIDty)uk)urnmq63qUgIkdffdMs1Wr4GsPTbcvhJsooQOfkflLO0IrYYPYdPQ6PQwMcADik1ejkAQqzYOstxPlQixLOWLbUoO2ir1wruWMrvBhQ6Juv8zOY0aH47uLrIk0Zqu0OrPXdIojICleLCAsoprEoPwliKUTcDScwoDrSkKqosSFL6G8zzG5ljZuoDrSkKqosSxnaeJ1WCxjWb8ZcOHqAYP6Qbd8PJ8cvU0mpVgS(lIvHe6yGMd5mpVgS(lIvHe6yGMZjmagWLensC1aqmKdA(Os0ofdzMZjmagW1FrSkKqNMCPzEEnyXkhoWQJbAUMf5Dp1sZ2oLMCnlYRfErPjxZI8UNAPzBHxuAY3YHdSTcAwKlVzgdBM8YsYhoILlfdzn0cAU0mpVgSCOrhdzzLRzrEyLdhy1PjhcuTcAwKlhBMrws(WrSCLGRIUwKRvqZIC5YsYhoILtxeRcjAf0SixEZmg2m5ZpbGwvD1GAvirmdH4w5AwK3XstoNWayGmvoa9QqICzj5dhXYfWJKOrcDmqKCnbO3L3lnRFuh5cwEfJvUlgRCCXyLtfJv2CnlYZFrSkKqhQCiN551GTf2vXanVGDfMebiNcMNpFSGSfErXanNQRgmWNoYRT3dvE1jyRZI8yWpfJvE1jyl)OrQAzWpfJvUmb8fCFdvE19kjndEM0KJxPvuQUALWKia5u50fXQqI2UcNi3)KbBs2CUknrVKWKia5vURe4ayseG8Is1vRuEb7kYReG0Kdbk5iXE1aqmwdZRobBHvoCGLbptmw5oqp3)KbBs2CnbO3L3lnBOYRobBHvoCGLb)umw5CcdGbCjj4QORf50Pj3uJG8dtTDWkzZoJtnwoP8TC4aRCKy)k1b5ZYaZxsMPCUa(cUVTm(MF1OFB2pm12bRezBZoxaFb33Ciqjhj2VsDq(SmW8LKzkhYyGMxDc2QT7vsAg8mXyLZJeBodMn7VeAB2nLZH8YjCQXYjjhj2RgaIXAyoHdqJgPQTLX38Rg9BZ(HP2oyLiBB2jCaA0ivT5vNGTolYJbptmw5JfKTtXanFSG8yXyLVLdhyzWpfQCzbDqPbXmeQfz0A4qYeIzLRzrEm4zstUMf5XbGeLsWvjWPtt(woCGLbptOYPrJu1YGFku5vNGTA7ELKMb)umw5qGsosS5my2S)sOTz3uohYlxZI8ij4QORf50PjxAMNxd2wyxfd08Q7vsAg8tPjxZI8ANstUMf5XGFkn50OrQAzWZeQ8c2vTcAwKlVzgdBM8(ojhlV6eSLF0ivTm4zIXkNtyfneidk9xPoiVYhvIJfd08TC4aRCKyVAaigRH5fSRij4ryseGCkyE(C6IyviHCKyZzWSz)LqBZUPCoKxEb7Qta6DsYmgO5tIIQd4MMCTAKOdANNIzyUMf51c7kscEuOYHCMNxdwSYHdS6yGMVLdhyLJeBodMn7VeAB2nLZH8YLM551GLKGRIUwKthd0CiN551GLKGRIUwKthd0CoHbWG2UcNyei2C6CcNASCsKOrIRgaIHCqZv0iXjkALaxmKlxrJequeAmglYLZjmagWvosSxnaeJ1WCiN551GLdn6ySY5egad4YHgDAYhvIw4ffd08c2vYqO2CIEjbCzta]] )


end

