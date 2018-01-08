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
            goremaws_bite = {
                resource = 'energy',

                spec = 'subtlety',
                aura = 'goremaws_bite',

                last = function ()
                    return state.buff.goremaws_bite.applied + floor( state.query_time - state.buff.goremaws_bite.applied )
                end,

                interval = 1,
                value = 5,
            },

            master_of_shadows = {
                resource = 'energy',

                spec = 'subtlety',
                aura = 'master_of_shadows',

                last = function ()
                    return state.query_time - ( ( state.query_time - state.buff.master_of_shadows.applied ) % 0.5 )
                end,

                interval = 0.5,
                value = 4
            },
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
            local function shadow_focus( x )
                if buff.stealth.up or buff.shadow_deance.up then
                    return x * 0.75
                end
                return x
            end

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
        addAura( "embrace_of_darkness", 197603, "duration", 10 )
        addAura( "evasion", 5277, "duration", 10 )
        addAura( "feeding_frenzy", 242705, "duration", 30, "max_stack", 3 )
        addAura( "feint", 1966, "duration", 5 )
        addAura( "finality_eviscerate", 197496, "duration", 30 )
        addAura( "finality_nightblade", 197498, "duration", 30 )
        addAura( "fleet_footed", 31209 )
        addAura( "goremaws_bite", 220901, "duration", 6 )
        addAura( "marked_for_death", 137619, "duration", 60 )
        addAura( "master_of_subtlety", 31665, "duration", 5 )
        addAura( "mastery_executioner", 76808 )
        addAura( "nightblade", 195452, "duration", 15 )
            class.auras[ 197395 ] = class.auras.nightblade
            modifyAura( "nightblade", "duration", function( x )
                return x + ( talent.deeper_stratagem.enabled and 3 or 0 )
            end )

        addAura( "relentless_strikes", 58423 )
        addAura( "sap", 6770, "duration", 60 )
        addAura( "shadow_blades", 121471, "duration", 15 )
            modifyAura( "shadow_blades", "duration", function( x )
                return x + ( artifact.soul_shadows.rank * 3.334 )
            end )

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
                    end

                    local now = GetTime()

                    if now > last_shadow_techniques + 3 then
                        swings_since_sht = swings_since_sht + 1
                    end

                    if offhand then last_mh = GetTime()
                    else last_mh = GetTime() end
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
                local mh_next = ( state.swings.mainhand > state.now - 3 ) and ( state.swings.mainhand + mh_speed ) or state.now + ( mh_speed * 0.5 )

                local oh_speed = state.swings.offhand_speed               
                local oh_next = ( state.swings.offhand > state.now - 3 ) and ( state.swings.offhand + oh_speed ) or state.now

                table.wipe( sht )

                sht[1] = mh_next + ( 1 * mh_speed )
                sht[2] = mh_next + ( 2 * mh_speed )
                sht[3] = mh_next + ( 3 * mh_speed )
                sht[4] = mh_next + ( 4 * mh_speed )
                sht[5] = oh_next + ( 1 * oh_speed )
                sht[6] = oh_next + ( 2 * oh_speed )
                sht[7] = oh_next + ( 3 * oh_speed )
                sht[8] = oh_next + ( 4 * oh_speed )


                local i = 1

                while( sht[i] ) do
                    if sht[i] < last_shadow_techniques + 3 then
                        table.remove( sht, i )
                    else
                        i = i + 1
                    end
                end

                if #sht > 0 and n - swings_since_sht < #sht then
                    table.sort( sht )
                    return max( 0, sht[ n - swings_since_sht ] - state.query_time )
                else
                    return 3600
                end
            end
        } )


        addMetaFunction( "state", "bleeds", function ()
            return ( debuff.garrote.up and 1 or 0 ) + ( debuff.rupture.up and 1 or 0 )
        end )

        addMetaFunction( "state", "cp_max_spend", function ()
            return talent.deeper_stratagem.enabled and 6 or 5
        end )

        addMetaFunction( "state", "finality", function ()
            return debuff.nightblade.pmultiplier > 1
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
                    state.applyBuff( "master_of_subtlety", 1 )
                    state.buff.master_of_subtlety.applied = true_stealth_change
                    state.buff.master_of_subtlety.duration = 5
                    state.buff.master_of_subtlety.expires = true_stealth_change + 5
                end
            end

            state.debuff.nightblade.pmultiplier = nil
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
                        if amt > 0 then
                            state.gain( 6 * amt, "energy" )
                        end

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


        local function calculate_multiplier( spellID )
            if spellID == class.abilities.nightblade.id and UnitBuff( "player", class.auras.finality_nightblade.name, nil, "PLAYER" ) then return 2 end
            return 1
        end


        RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
            if sourceGUID == state.GUID then
                if subtype == "SPELL_AURA_APPLIED" then
                    if spellID == class.auras.nightblade.id and ( subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' ) then
                        ns.saveDebuffModifier( spellID, UnitBuff( "player", class.auras.finality_nightblade.name, nil, "PLAYER" ) and 2 or 1 )
                        ns.trackDebuff( spellID, destGUID, GetTime(), true )
                    end
                end
            end
        end )  


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

        modifyAbility( "backstab", "spend", shadow_focus )

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

        modifyAbility( "cheap_shot", "spend", shadow_focus )

        addHandler( "cheap_shot", function ()
            gain( 2 + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
        end )


        -- Cloak of Shadows
        --[[ Provides a moment of magic immunity, instantly removing all harmful spell effects. The cloak lingers, causing you to resist harmful spells for 5 sec. ]]

        addAbility( "cloak_of_shadows", {
            id = 31224,
            spend = 0,
            cast = 0,
            gcdType = "off",
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
            gcdType = "off",
            cooldown = 30,
            min_range = 0,
            max_range = 0,
            passive = true,
        } )

        modifyAbility( "crimson_vial", "spend", shadow_focus )

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

        modifyAbility( "death_from_above", "spend", function( x )            
            if buff.feeding_frenzy.up then return 0 end
            return shadow_focus( x )
        end )

        addHandler( "death_from_above", function ()            
            local cost = min( 5 + ( talent.deeper_stratagem.enabled and 1 or 0 ), combo_points.current )
            spend( cost, "combo_points" )
            removeStack( "feeding_frenzy" )
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

        modifyAbility( "distract", "spend", shadow_focus )

        addHandler( "distract", function ()
            -- proto
        end )


        -- Evasion
        --[[ Increases your dodge chance by 100% for 10 sec. ]]

        addAbility( "evasion", {
            id = 5277,
            spend = 0,
            cast = 0,
            gcdType = "off",
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
            if buff.feeding_frenzy.up then
                return 0
            end

            return shadow_focus( x )
        end )

        addHandler( "eviscerate", function ()
            local cost = min( 5 + ( talent.deeper_stratagem.enabled and 1 or 0 ), combo_points.current )
            spend( cost, "combo_points" )
            gainChargeTime( "shadow_dance", cost * ( 1.5 + ( talent.enveloping_shadows.enabled and 1 or 0 ) ) )
            if artifact.finality.enabled then
                if buff.finality_eviscerate.up then removeBuff( "finality_eviscerate" )
                else removeBuff( "finality_eviscerate" ) end
            end
            removeStack( "feeding_frenzy" )
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

        modifyAbility( "feint", "spend", shadow_focus )

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

        modifyAbility( "gloomblade", "spend", shadow_focus )

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
            if artifact.feeding_frenzy.enabled then applyBuff( "feeding_frenzy", 30, 3 ) end
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

        modifyAbility( "kidney_shot", "spend", function( x )
            if buff.feeding_frenzy.up then return 0 end
            return shadow_focus( x )
        end )        

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
            gcdType = "off",
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

        modifyAbility( "nightblade", "spend", function( x )
            if buff.feeding_frenzy.up then return 0 end
            return shadow_focus( x )
        end )

        addHandler( "nightblade", function ()
            local cost = min( 5 + ( talent.deeper_stratagem.enabled and 1 or 0 ), combo_points.current )
            spend( cost, "combo_points" )

            gainChargeTime( "shadow_dance", cost * ( 1.5 + ( talent.enveloping_shadows.enabled and 1 or 0 ) ) )

            applyDebuff( "target", "nightblade", 6 + ( cost * 2 ) )

            if artifact.finality.enabled then
                if buff.finality_nightblade.up then
                    debuff.nightblade.pmultiplier = 2
                    removeBuff( "finality_nightblade" )
                else
                    debuff.nightblade.pmultiplier = 1
                    applyBuff( "finality_nightblade" )
                end
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

        modifyAbility( "sap", "spend", shadow_focus )

        addHandler( "sap", function ()
            applyDebuff( "target", "sap" )
        end )


        -- Shadow Blades
        --[[ Draws upon surrounding shadows to empower your weapons, causing auto attacks to deal Shadow damage and abilities that generate combo points to generate 1 additional combo point. Lasts 15 sec. ]]

        addAbility( "shadow_blades", {
            id = 121471,
            spend = 0,
            cast = 0,
            gcdType = "off",
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
            if artifact.embrace_of_darkness.enabled then applyBuff( "embrace_of_darkness" ) end
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

        modifyAbility( "shadowstrike", "spend", shadow_focus )

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

        modifyAbility( "shuriken_storm", "spend", shadow_focus )

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

        modifyAbility( "shuriken_toss", "spend", shadow_focus )

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
            cooldown = 60,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "sprint", "cooldown", function( x )
            if artifact.flickering_shadows.enabled then return x - 10 end
            return x
        end )

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

            if artifact.embrace_of_darkness.enabled then applyBuff( "embrace_of_darkness" ) end
        end )


        -- Symbols of Death
        --[[ Invoke ancient symbols of power, generating 40 Energy and increasing your damage done by 15% for 10 sec. ]]

        addAbility( "symbols_of_death", {
            id = 212283,
            spend = -40,
            spend_type = "energy",
            cast = 0,
            gcdType = "off",
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

        modifyAbility( "vanish", "cooldown", function( x )
            if artifact.flickering_shadows.enabled then return x - 30 end
            return x
        end )

        addHandler( "vanish", function ()
            applyBuff( "vanish" )
            applyBuff( "stealth" )
            if artifact.embrace_of_darkness.enabled then applyBuff( "embrace_of_darkness" ) end
            emu_stealth_change = query_time
        end )

    end


    storeDefault( [[SimC Subtlety: stealthed]], 'actionLists', 20171225.003612, [[d8JEhaWyvSEcuAtcYBjOyBeOyFuvmtcchgy2kmFiCtQQUlbjFtQsVwqTtjAVi7MO9tzueYWuP(nuNxL0PbnysdxQCqc4ueQJjKZrqQfkjzPQswmKwUIwevL8urltsSocKjsGktvQQjlLPR0fvf8kPkUmQRtvEMKuBvvOnlW2HOMgbr)vO(meP5rqPJtq1ZPYOLuFxv0jHiUfbQ6AuvQ7Pk1dvjUTQAxsykI6t5dsa6GBekLzhFGGbuWcwiwsLvemruk44aG3yPQO8fpyGJPYk3r9gvPIqwujkkQIqtzEMWULskf4SqS0r9PYiQpLpibOdUrvrzEMWULsuVGGc3YGXwx41rPaOWbCVsPRg0WpD7egMPejYg8aw8KsjwYu6h3EemlbFMsklbFMYSg0WpD7egMP8fpyGJPYk3r9gDt5l2H9Mh2r9PLYl18jSFmY8NLlHsPFCRe8zkPLkRq9P8bjaDWnQkkZZe2TuEWFuCChgkxxXXBoz5AQpVn13M2JPImvKPlyWYTOXChpJD7eSaKY)cwcqhCZ0qMI6feuGmqcD1fEDMk20qMgzkceMEBQytdzQitbNfImhZs(dzNP(820QnThtfzklCpyxh3kC1Gg(zSdSxNU4NGrytdzAKPiqy6TPInfbctfz6hi3bh38MGfILMkSVnnQOAtdz6hi3bh38MGfILM6ZBtVlQ2uXMkMsbqHd4ELYdymIbNfILXdOBPejYg8aw8KsjwYu6h3EemlbFMsklbFMseNGG77ZjiqyUagdtf4SqS0uHa6wHcXKsbMi1rPe853(kH)lMMEO7G3RcY0aOe6Q9fLV4bdCmvw5oQ3OBkFXoS38WoQpTuEPMpH9JrM)SCjuk9JBLGptzc)xmn9q3bVxfKPbqj0vtlvwn1NYhKa0b3OQOmpty3sjQxqqHRg0Wp)8Ov0WpLMgYurMkY0d(JIJ7Wq56kACa8axt95TPvmThtfzklCpyxh3kGshePsiighepbiZYA8OTMgY0itrGW0BtfBAitbNfImhZs(dzNP(820QnThtfzklCpyxh3kC1Gg(zSdSxNU4NGrytdzAKPiqy6TPInvSPiqyQitp4pkoUddLRROXbWdCn1N3MgzAitr9cck2AoUnzqBGNnxCJpmClCl4e2uFEBAfH2uXMkMsbqHd4ELsxT3egMLXUfp)uIezdEalEsPelzk9JBpcMLGptjLLGptzw7nHHzPP5INFkFXdg4yQSYDuVr3u(IDyV5HDuFAP8snFc7hJm)z5sOu6h3kbFMsAPsHK6t5dsa6GBuvuMNjSBP8G)O44omuUUIJ3CYY1uFEBQVnThtfzQitxWGLBrJ5oEg72jybiL)fSeGo4MPHmf1liOazGe6Ql86mvSPHmnYueim92uXMgY0d(JIJ7Wq56kACa8axtfwtR20EmvKPOEbbfUAqd)mgDaASRWRZ0qMgzkceMEBQytf8MkYuw4EWUoUv8bYDWX4G4TMJ)a3YZyGZbCoO00qMgzkceMEBQykfafoG7vkpGXigCwiwgpGULsKiBWdyXtkLyjtPFC7rWSe8zkPSe8zkrCccUVpNGaH5cymmvGZcXstfcOBfkettffjMsbMi1rPe853(kH)lMMEO7G3RcY0aOe6Q9fLV4bdCmvw5oQ3OBkFXoS38WoQpTuEPMpH9JrM)SCjuk9JBLGptzc)xmn9q3bVxfKPbqj0vtlv6BQpLpibOdUrvrPaOWbCVsPRg0WpD7egMPejYg8aw8KsjwYu6h3EemlbFMsklbFMYSg0WpD7egMnvuKykFXdg4yQSYDuVr3u(IDyV5HDuFAP8snFc7hJm)z5sOu6h3kbFMsAPLYsWNPmH)lMMEO7G3RcYu3YGXwZnAjc]] )

    storeDefault( [[SimC Subtlety: stealth CDs]], 'actionLists', 20171225.003612, [[dmeXhaqiiKnjvmkvQofeSksKEfjkZIesDlsOQDbvdtkoMu1YGupJevtJeCnsOyBKqPVPuX5irO1rcrZtQuUhe1(GihuuvluuLhkLyIIk6IsLSrsOYjHqDtsYofLHkvQwQsvpvXuvjTvLk9wsiCxseSxu)fWGP6WswmuESkMmPUmYMf0NLsA0cCArETOsZwj3gODt43QA4KuhNerlxONt00bDDLY2vj(UuQXlQW5vPSEsiz(qY(Pm3Zx5PlrHTinJXZOMoPALuufm9codTITNNCsH12cY5XZEArLK4m0n970JgTc4O777rRe5zoXKAip8K)bMEHKVYz98vE6suylsZ5XZCIj1qEqK5xQyQWweUwgaOdlZ7yoyjGlcqVfly6fMJS5nM3X8Z)l93wGldk93gqxIdHFcQyRKeimwhy6f1Y8Uz(LkMkSfHld0aHX6atVOwMRmZVB(DZjLClPwnPXblbCraFiamGaaljKIaLuwszsyEhZHjqY8UzUYBmhbZ7yEV5OqzEJ5iyUsnVbx5M3X87MJiZjLClPwnPXblbCraFiamGaaljKIaLuwszsyokuMJTfgIlVbI9ljWhcOPcgGVP2Ce4jFS0kbVXZLsKKb8GyHoDk4h5r8cIhvVE3kMvGep8KvGep7wIKmGN90IkjXzOB63PVHN9K83IhsYxzipTeqNCv9xiqsazmEu96ScK4HHCgA(kpDjkSfP584zoXKAipNGk2kjbcJ1bMErTmhjKn)sftf2IWLbAGWyDGPxulZrHYCyfBLG4WeibaFaDImVBMF(FP)2cC5nqSFjb(qanvWa8ibwjHKN8XsRe8gpYGs)Tb0L4q8GyHoDk4h5r8cIhvVE3kMvGep8KvGeptqP)2MNZsCiE2tlQKeNHUPFN(gE2tYFlEijFLH80saDYv1FHajbKX4r1RZkqIhgYzkNVYtxIcBrAopEYhlTsWB8O()fqKK)w8q8GyHoDk4h5r8cINwcOtUQ(leijGmgp7j5VfpKKVYqEu96DRywbs8Wt3)FP4(ygLdiNhpzfiXdQtyytZ5egQi6()lZ3tYFlEiLaQip5hBvYt4hbeuoGi3ROPCaJfqb(BciYk0WZEArLK4m0n9703WZe8Tv96uyIIsgJNU))QRCaJfNPqdpQEDwbs8Wqotb(kpDjkSfP584zoXKAipKGITEd)SfJKaAosiBUcnM3XCsqXwVHRPW0jbnhjKnVVXCLz(LkMkSfHlLTbIu4MqZt(yPvcEJhzqP)2G0sZdIf60PGFKhXliEu96DRywbs8Wtwbs8mbL(Bdslnp7PfvsIZq30VtFdp7j5VfpKKVYqEAjGo5Q6VqGKaYy8O61zfiXdd5mfdFLNUef2I0CE8mNysnKhez(LkMkSfHRLba6WY8oMFEqShq9NeqjUMctNe0CKq2C0MRmZVBoSwKaIl3WGumCRvcNef2I0M3X8EZrHY8gZrWCLAoAZ7y(DZX2cdXL3aX(Le4db0ubdWJeyLesZrczZ7XrBokuMF(FP)2cC5nqSFjb(qanvWa8ibwjH0CKq28E0MRmZVB(DZH1IeqCDfZfqgu6VnojkSfPnVJ5sccG9Injomrr0nakO(yosM3yocM3X8EZrHY8gZrWCLAUYnxXB(DZVBoImhwlsaX1vmxazqP)24KOWwK28oMljia2l2K4Wefr3aOG6J5izEJ5iyEhZ7nhfkZBmhbZvQ5kyokuMdwc4Ia0BXcMEH5izEJ5iyEhZVBEDGPleajiWejnhjKnxbZrHYCezo2wyiomGactrje4dbGbeGMkn(MAZrGN8XsRe8gpYGs)Tb0L4q8GyHoDk4h5r8cIhvVE3kMvGep8KvGeptqP)2MNZsCiZV3Jap7PfvsIZq30VtFdp7j5VfpKKVYqEAjGo5Q6VqGKaYy8O61zfiXddzipzfiXZKaBX8zddUi4nfP5sivlyG5TKtjdzga]] )

    storeDefault( [[SimC Subtlety: default]], 'actionLists', 20171225.003612, [[dqeuxaqikbTiur2evXOuL6uQIwfGi9kavZcOKUfGiAxOQHrvDmawMQWZKQOPrjPRHkQTbi8nkPghLa5CucyDasZtQc3di2hQGdkv1cbkEOuYebkXfbuojQqVKsGAMaL6MuL2PuzPaPNkAQQk2QuLElLq3LsI9s6VqAWkDyjlgKhl0KPYLr2meFwvPrlfNMWRPenBIUnO2nu)gLHJkDCarTCbpNIPRY1PuBxk13bQoVQK1dicZxv1(vScq)OjWWfKKCkKMjxkkkPairDcgw7Eaea0eSqiLT8uWOjOKKkdPDp8bynGhpSk)daaa8WcOzgdcUNMA2pEcg2OF0oa6hnbgUGKKtbJMzmi4EAEv4lD8ocYgbHpwMtG)YBZvtqjdZoejJ(rpn7djKI7LMwkIwQjhXorSowqtmdtAckjPYqA3dFawdWxZUcM00cweTupT7H(rtGHlij5uWOzgdcUNMxf(shVJGSrq4JL5e4V82C1euYWSdrYOF0tZ(qcP4EPzfIfMqpwiq4ttoIDIyDSGMygM0eussLH0Uh(aSgGVMDfmPz)qSW0SFyHaHp90UEQF0ey4cssofmAMXGG7PjbKTfC5soEtt5yGJAQ7vWGcEjTCwpZ(EwGywGpRXaoAGqSXougcIHUzFo7))S(A2hsif3lnBxbrbjjn5i2jI1XcAIzystVmxVvORGjnngWrdeIn2PzxbtA(hrq89JreelMhlqZ2BjTjR8h0SF4RrtCbtGymGJgieBSdS2UK2eieq2wWLl54nnLJboQPUxbdk4L0spVbcGBmGJgieBSdLHGyO75)VVMGssQmK29WhG1a81euYWSdrYOF0tZwnu0sVS2emHpfstVmxxbtAQN2zv9JMadxqsYPGrZmgeCpnFplqW5zb(SVN9kjHp(2IVSapHlij5M1ZS9KZZ()pR)SpNf4Z(E2RKe(4HlZrbugcQPPCmWn8eUGKKBwpZcWF2))z9N95SaF22vquqsI3yahnqi2y3Sp1SpKqkUxA2UcIcssAYrSteRJf0eZWKMEzUERqxbtAAoQKxd61eitdt60SRGjn)Jii((XicIfZJfOz7TK2Kv(dZ(gWtn7h(A0exWeiMJk51GEnbY0WKoWA7sAtG8gi4mWFFLKWhFBXxwGNWfKKCE6jN))9Fc83xjj8XdxMJcOmeutt5yGB4jCbjjNha())(pbE7kikijXBmGJgieBS7PMGssQmK29WhG1a81euYWSdrYOF0tZwnu0sVS2emHpfstVmxxbtAQN2Xz9JMadxqsYPGrZmgeCpnbWB9doplWN99Sxjj8Xt42KKXvG)IAAkhdCdpHlij5M1ZS(8w)GZZ()pR)Sp1SpKqkUxA2UcIcssAYrSteRJf0eZWKMEzUERqxbtAAACOiHkEcgUKA2vWKM)reeF)yebXI5Xc0S9wsBYk)HzF)4PM9dFnAIlycetJdfjuXtWWLeS2UK2eia4T(bNb(7RKe(4jCBsY4kWFrnnLJbUHNWfKKCE85T(bN))9FQjOKKkdPDp8bynaFnbLmm7qKm6h90SvdfT0lRnbt4tH00lZ1vWKM6PDaH(rtGHlij5uWOzgdcUNMxjj8X7O6Aqrcmy0cI1M4jCbjj3SEM9kjHpExfSe10uog48eUGKKBwpZwXt0MqjmbliZS9ywRQzFiHuCV0SDfefKK0KJyNiwhlOjMHjn9YC9wHUcM00zAqDiLMDfmP5FebX3pgrqSyESanBVL0MSYFy2398PM9dFnAIlyceNPb1HuG12L0Ma5kjHpEhvxdksGbJwqS2epHlij58CLKWhVRcwIAAkhdCEcxqsY5PINOnHsycwqMEyvnbLKuziT7HpaRb4RjOKHzhIKr)ONMTAOOLEzTjycFkKMEzUUcM0upTZA9JMadxqsYPGrZmgeCpnVss4J3vblrnnLJbopHlij5M1ZSVN1cN1CujVgYXxs5S))ZczJGWBSHokGy)L4T5o7Zz9mlKnccVJQRbfjWGrliwBI3M7SEMfYgbH3r11GIeyWOfeRnXhi4sGnZ2dqM1NhaN1SpKqkUxAAAkhdCuxHJKMCe7eX6ybnXmmPPxMR3k0vWKMA2vWKMzt5yGplyPWrstqjjvgs7E4dWAa(Ackzy2Hiz0p6PzRgkAPxwBcMWNcPPxMRRGjn1t7SG0pAcmCbjjNcgn7djKI7LMXskrR4jyyuPWCAYrSteRJf0eZWKMEzUERqxbtAQzxbtA(hrq89Jreel2QKYz7hpbdplylmNv(dA2p81OjUGjq4ukGBnBAdDs6Eb0zBbwmCstqjjvgs7E4dWAa(Ackzy2Hiz0p6PzRgkAPxwBcMWNcPPxMRRGjntbCRztBOts3lGoBlWIrpTZcOF0ey4cssofmAMXGG7PP5OsEnKJVKsn7djKI7LMbBmAfpbdJkfMttoIDIyDSGMygM00lZ1Bf6kystn7kysZ)icIVFmIGyrqTXZ2pEcgEwWwyoR8h0SF4RrtCbtGWPua3A20g6K09cOZAoQKxd54KMGssQmK29WhG1a81euYWSdrYOF0tZwnu0sVS2emHpfstVmxxbtAMc4wZM2qNKUxaDwZrL8AiNEAhaF9JMadxqsYPGrZmgeCpnVk8Lo(tatOhd1jOz5WSaXSEMnqWLaBMThZ(n6M1ZSrgmedLltGpdF0oei8nlhazwRolqYzFp7jGPz7XSa8N1ZSaM9)Fw)zFolq6Sp0SpKqkUxAIfFBoiz5in5i2jI1XcAIzystVmxVvORGjn1SRGjn7eFBoiz5inbLKuziT7HpaRb4RjOKHzhIKr)ONMTAOOLEzTjycFkKMEzUUcM0upTdaa9JMadxqsYPGrZmgeCpnVss4J3vblrnnLJbopHlij5M1ZSrgmedLltGpdVJqerXnlhaz2hZc8zFplKnccVPPCmWrHKLJm82CN1ZSaM9)Fw)zFoRNzFpRJD8yX3MdswoIpqWLaBMLdZA1zb(SVN9kjHpEJn0rbe7VeVaLWfKKCZ6zwaZ()pR)SpN9)F2iJjDmWX8MMYXah1v4iXhBQWxYGIeQ4jy4solhazwa8wGz9m77zTWzjGSTGlxYX7iSOKOme0RHqBkjYxrHpZS))ZEcyAwomla)zFo7tn7djKI7LMXskrR4jyyuPWCAYrSteRJf0eZWKMEzUERqxbtAQzxbtA(hrq89Jreel2QKYz7hpbdplylmNv(dZ(gWtn7h(A0exWeiCkfWTMnTHojDVa6SMJk51mBjnCstqjjvgs7E4dWAa(Ackzy2Hiz0p6PzRgkAPxwBcMWNcPPxMRRGjntbCRztBOts3lGoR5OsEnZwsJEAhGh6hnbgUGKKtbJMzmi4EAAHZELKWhVRcwIAAkhdCEcxqsYnRNzFpBKbdXq5Ye4ZW7ieruCZYbqM9XSaF23ZczJGWBAkhdCuiz5idVn3z9mlGz))N1F2NZ()pBKXKog4yEtt5yGJ6kCK4Jnv4lzqrcv8emCjNLdGmlaElWSaF23ZELKWhpHBtsgxb(lQPPCmWn8cucxqsYnRNzbm7))S(Z(C2NA2hsif3lnJLuIwXtWWOsH50KJyNiwhlOjMHjn9YC9wHUcM0uZUcM08pIG47hJiiwSvjLZ2pEcgEwWwyoR8hM99JNA2p81OjUGjq4ukGBnBAdDs6Eb0znhvYRz2sA4KMGssQmK29WhG1a81euYWSdrYOF0tZwnu0sVS2emHpfstVmxxbtAMc4wZM2qNKUxaDwZrL8AMTKg90oa9u)OjWWfKKCky0mJbb3tZidgIHYLjWNHpAhce(MLdGmlNNf4Z2ZzbsN99SVNfYgbH)AiuerWCOme0RHqDu54T5oRNzVss4JVWNik4wNGH5jCbjj3SpN1ZSaM9)Fw)zFolWN99SVN9kjHpEhrCPaQ5c1vFjyEcxqsYnRNzTWzHSrq4nnLJbokKSCKH3M7SEM99SWf(KeQZouNGHNfKz9N9)FwdDOqmSTH)eu4HpQv5gNLdZ6p7Zz9m77zTWzHSrq4Vgcfremhkdb9AiuhvoEBUZ()pB7kikijX7mnOoKA2NZ(CwpZcy2))z9N95S))Z(E2idgIHYLjWNHpAhce(MLdGmRvN1ZSrgmedLltGpdVJqerXnBpaz2hZ6z2kEI2ekHjybzMLdGmBpN1ZSv8eTjuctWcYmBpazwRo7Zz))N99SqmJzwpZEv4lD8NaMqpgQtq9aeaZ6z2idgIHYLjWNHpAhce(MLdGmBpN9PM9HesX9sZyjLOv8emmQuyon5i2jI1XcAIzystVmxVvORGjn1SRGjn)Jii((XicIfBvs5S9JNGHNfSfMZk)HzF3ZNA2p81OjUGjq4ukGBnBAdDs6Eb0zreyHPHtAckjPYqA3dFawdWxtqjdZoejJ(rpnB1qrl9YAtWe(uin9YCDfmPzkGBnBAdDs6Eb0zreyHPrpTdGv1pAcmCbjjNcgnZyqW90eYgbH)AiuerWCOme0RHqDu54deCjWMz5WSaM1ZSrgmedLltGpdF0oei8nlhaz2EoRNzR4jAtOeMGfKz2Em7Jz9mRfolKnccVPPCmWr)sMZoqgEBUA2hsif3lnJLuIwXtWWOsH50KJyNiwhlOjMHjn9YC9wHUcM0uZUcM08pIG47hJiiwSvjLZ2pEcgEwWwyoR8hM9TvFQz)WxJM4cMaHtPaU1SPn0jP7fqNfrGfMgoPjOKKkdPDp8bynaFnbLmm7qKm6h90SvdfT0lRnbt4tH00lZ1vWKMPaU1SPn0jP7fqNfrGfMg90oaCw)OjWWfKKCky0mJbb3tZ2vquqsI3zAqDi1SEMLaY2cUCjh)1qOiIG5qziOxdH6OYnRNzDSJhl(2CqYYr8bcUeyZS9aKzFpBKXKog4yEZlyiM0GYqqDuDn8bcUeyZSaFwa(Z(CwpZgzmPJboM38cgIjnOmeuhvxdFGGlb2mBpaz2hZ6z2idgIHYLjWNHpAhce(MLdGm7dn7djKI7LMXskrR4jyyuPWCAYrSteRJf0eZWKMEzUERqxbtAQzxbtA(hrq89Jreel2QKYz7hpbdplylmNv(dZ(MZp1SF4RrtCbtGWPua3A20g6K09cOZIiWctdN0eussLH0Uh(aSgGVMGsgMDisg9JEA2QHIw6L1MGj8PqA6L56kysZua3A20g6K09cOZIiWctJEAhaGq)OjWWfKKCky0mJbb3ttn7djKI7LMXskrR4jyyuPWCAYrSteRJf0eZWKMEzUERqxbtAQz2Wa3lZjqeuWOqA2vWKM)reeF)yebXITkPC2(XtWWZc2cZzL)WSVbINA2p81OjUGjq4ukGBnBAdDs6Eb0zHSfshN0eussLH0Uh(aSgGVMGsgMDisg9JEA2QHIw6L1MGj8PqA6L56kysZua3A20g6K09cOZczlKo90tZUcM0mfWTMnTHojDVa6SocPSLNEQca]] )

    storeDefault( [[SimC Subtlety: precombat]], 'actionLists', 20171225.003612, [[dWt1gaGEiL0MGQAxQKTjk1JHy2KA(s0nHK7cvPVPcDyHDII9QSBc7xQgLOYWqLFJ0XHQWqHuKblPHtLCqvWPevDmQQZbPelKkyPIIfJOLtYdrv5PuwguzDqkQjcvrtLkAYImDvDrQqVsLQNHQuxxfDEOWwHuTzuA7qPtlLzbPWNrv8DQu)LQCBegTeETkLtkk5TOk5Aqr3dvvtdsPUm45e98NZzokcsnKg5mZfG0cDdTgFJkgdUS9NHNaBCQ)5WSmGgcjmgCC(h9XHdTVW577JdTmZqunx)Szhq(gviNZX4pNZCueKAinhMziQMRFgGhNnxUG0LSisu3EY4Xqj9Ch6B9k(9AUEn7E9EVkLU9ua7Pi5rzzLW3R571YYELB2bYMU9ymdBOAbPgMLLi1qINQMjOcygkAc9qXeeWmP0TNcypfPzmbbmReHLLJdbHLLx2tvqVIEOpb8wQMDqXJCMiia(Ls3EkG9uKqdSH(e4hWJZMlxq6swejQBpz8yOKEUd9n8ZL9DP0TNcypfjpklRe(8LLCZYaAiKWyWX5F0NBwgqspviGCo3pJVca5gkkwGae)iNHIMyccy2(XGBoN5Oii1qAomZqunx)SC9A2y2R371C96hAq8xyB8qvxnpqeKAi1R43R8gZETSSx5618969EnxV(Hge)friFq5rz9KfrI6wE18arqQHuVIFV6Z1RLL9kxVMVxV3Rydvli1WLu62tbSNIuVMF2bYMU9ymdBOAbPgMLLi1qINQMjOcygkAc9qXeeWm5dH(l8(cfilO60mMGaMvIWYYXHGWYYl7PkOxrp0NaElv9Ao)8ZoO4roteea)Yhc9x49fkqwq1j0aBOpb(ZLnM3Z9Hge)f2gpu1ficsnKWN3ywwYL)EUp0G4Vic5dkpkRNSisu3YlqeKAiHVpxzjx(7ydvli1WLu62tbSNIu(zzanesym448p6ZnldiPNkeqoN7NXxbGCdfflqaIFKZqrtmbbmB)y49CoZrrqQH0CyMHOAU(z(xhXHzVEVxZ1RFObXFbcSGM6Qj4XtwejQB5vZdebPgs9k(9k31rCy2RLL9kxVMF2bYMU9ymdBOAbPgMLLi1qINQMjOcygkAc9qXeeWmzrYJvfiFJkc9mMGaMvIWYYXHGWYYl7PkOxrp0NaElv9AoC5NDqXJCMiia(LfjpwvG8nQi0Ob2qFc87FDehM3Z9Hge)fiWcAQRMGhpzrKOULxGii1qcFURJ4WSSKl)SmGgcjmgCC(h95MLbK0tfciNZ9Z4RaqUHIIfiaXpYzOOjMGaMTFmO9CoZrrqQH0Cy2bYMU9ymt(qO)IzzjsnK4PQzcQaMHIMqpumbbmBgtqaZShc9xmldOHqcJbhN)rFUzzaj9uHaY5C)m(kaKBOOybcq8JCgkAIjiGz7hdMZ5mhfbPgsZHzhiB62JXmIqDdsESuLxcIVywwIudjEQAMGkGzOOj0dftqaZMXeeWmuH6gK6vwQQxXti(Izhu8iN5sbiucY453FwgqdHegdoo)J(CZYas6PcbKZ5(z8vai3qrXceG4h5mu0etqaZ2pMSNZzokcsnKMdZoq20ThJzUOFJkMLLi1qINQMjOcygkAc9qXeeWSzmbbmReHLLJdbHLLxOj63Oc8wQMLb0qiHXGJZ)Op3SmGKEQqa5CUFgFfaYnuuSabi(rodfnXeeWS97NXeeWmRrWxVANKVgEmqZ9QlfGqjiJF)g]] )

    storeDefault( [[SimC Subtlety: stealth als]], 'actionLists', 20171225.003612, [[de02haqiIsTiiPnPsyuqkNIiSkvK8kIO4werPDPQmmv4yQulJO6zQimnQu6AQi12iIkFtfLZrevTovvMNkIUhKQ9rLIdsLSqvu9qbMOQQUOkrNes0mbsDtbzNs0sbINszQQK2krK3cKCxiH9I8xjzWsDyLwmv8yctgWLjTzH8zj0OfQtd1RPs1SbDBi2nv9BugUeCCIsSCv55OA6IUUKA7efFxqDEGA9eL08js7xX0nDLSl9RdubihYScQaVqSSUjM5Ps5sUBY(RrBnmPZjdefQlxPs5h3NDlxUB)KFFFlxYtMjE4cjzK5sKyMNtxPYB6kzx6xhOcqNtMjE4cjzQxFfb)bOryboN(KOpTm7dVoq9JN6cZ4Qm(P8ygeyAj70Yp90NAA0MgTPL90cgdcWc7)kYEkYgMx5Gt9RUW0xmTSN2Pok6lsvaSVyv0t9Yk4V6ctlX0xm990sLo9X0sm9ftJ20YEAvwQXfkOaF84fGfUIVj4hVk8cDFAPsNwWyqawy)hpEbyHRawVq)eX7ROYRIERiXm)cN2nOpTm7dVoq9Jhduf9wrIz(foTuPtRE9ve8hGgHf4CA3G(03htlbzUCWqCcMmXcHvRiXmFfeZtYqPhal2K9iZZ8kzHyasAFLlIsgzLlIsMuru0XHqefbQGfcN2LiXm)0GgZtui9rMRxroz(frrhvdJemTv7Kqnb)BAEQlmJNo4phvYarH6YvQu(X9z3hKbIYz1pHYPRuswqSkCpetgfr9j5qwigq5IOKzyKGPTANeQj4FtZtDHz80b)5usLYPRKDPFDGkaDozM4HlKKHS(eQva1VnXm)0UzA5FNGmxoyiobtMyHWQvKyMVcI5jzO0dGfBYEK5zELSqmajTVYfrjJSYfrjtQik64qiIIavWcHt7sKyMFAqJ5jkK(MgTBjiZ1RiNm)IOOJQHrcM2QDsOMG)nnp1fMXth8NJkzGOqD5kvk)4(S7dYar5S6Nq50vkjliwfUhIjJIO(KCiledOCruYmmsW0wTtc1e8VP5PUWmE6G)CkPYtqxj7s)6ava6CYmXdxijBfjwgTs9kcw5t7g0N2TK5YbdXjyYelewTIeZ8vqmpjdLEaSyt2JmpZRKfIbiP9vUikzKvUikzsfrrhhcrueOcwiCAxIeZ8tdAmprH030OjxcYC9kYjZVik6OAyKGPTANeQj4FtZtDHz80b)5OsgikuxUsLYpUp7(GmquoR(juoDLsYcIvH7HyYOiQpjhYcXakxeLmdJemTv7Kqnb)BAEQlmJNo4pNsQ0T0vYU0VoqfGoNmt8WfsYqBAbJbbyH9F84fGfgrHaF1fM(IPL90cgdcWc7)Kz9yE8xDHPVyAbJbbyH9F84fGfUcy9c9teVVIkF6tI(03tlbzUCWqCcMmXcHvRiXmFfeZtYqPhal2K9iZZ8kzHyasAFLlIsgzLlIsMuru0XHqefbQGfcN2LiXm)0GgZtui9nnANqcYC9kYjZVik6OAyKGPTANeQj4FtZtDHz80b)5OsgikuxUsLYpUp7(GmquoR(juoDLsYcIvH7HyYOiQpjhYcXakxeLmdJemTv7Kqnb)BAEQlmJNo4pNsQ800vYU0VoqfGoNmt8WfsYY9vuZVeJOvjRcaRtFYPVLp9PMwWyqawy)hpEbyHRawVq)eX7ROYRIERiXm)cN(utJ203tlzMgTPvzPgxOGc8XJxaw4k(MGF8QWl09PVy6JVtpTuPtFmTetlbzUCWqCcMmXcHvRiXmFfeZtYqPhal2K9iZZ8kzHyasAFLlIsgzLlIsMuru0XHqefbQGfcN2LiXm)0GgZtui9nnAUvcYC9kYjZVik6OAyKGPTANeQj4FtZtDHz80b)5OsgikuxUsLYpUp7(GmquoR(juoDLsYcIvH7HyYOiQpjhYcXakxeLmdJemTv7Kqnb)BAEQlmJNo4pNskjRCruYmmsW0wTtc1e8VP5PUWmE6fYPKi]] )

    storeDefault( [[SimC Subtlety: CDs]], 'actionLists', 20171225.003612, [[dC00raqiIsTjrQprufAuGKtbsTkIO6vermlIQi3sKODHuddihtkwgq1ZakzAer6AeLSnGs9nIkJJOQ4CsvvSoIQOMNuk3de2NuIdksAHefpukPjkvvUOuQ2irvPpsufCsGIvks4MiPDsvgkrv1sLQ8ujtvQyRsv5Tevj3LOk1Er9xenyHdRyXi8yatMWLH2Si(SuPrtvDAsEnry2QYTvv7Mu)wLHtKoUuvvlNkpxutxPRdkBhe9DKOXteLZJewVuvLMpOA)uMB4oC1UEiEOGj4QKIaQ5P6VZQon7boy3Wv)WKb2Bzz4Qh(WjJSh4GAKRbCWLuAWBAAaV)Wvb4usxU4kvGvD6m3H9A4oC1UEiEOGLHRcWPKUCraljHM4DN4blV0WKAbC4waLfexoBrAl2X1fx6v9rY9ifk0I2GWcWgKfqBbC4waLfeWssOHC0QSpnmPwK2cOSGawscD2FehLKeVrGzAysTaoClaU7jok10z)rCuss8gbMPD4Fu6SfTbHfGfilG2cO5kvc1tTuWL0BvNMlWOfkGzphx6tJCr9e9noV5JCXL38rUGdKKaceaqsI8s(VvDA5nChx9WhozK9ahuJCnG4QhMpyoamZD4LRw9rajOEqIFuVmbxupH38rU4L9aN7Wv76H4HcwgUkaNs6YvEX5T(OG2DDHHCLkH6Pwk4I4DNGmbMJcUaJwOaM9CCPpnYf1t0348MpYfxEZh5sM3DclKVWCuWvp8HtgzpWb1ixdiU6H5dMdaZChE5QvFeqcQhK4h1ltWf1t4nFKlEzpWI7Wv76H4HcwgUkaNs6YvEX5T(OG2DDHHCLkH6Pwk4IaDz0jHs3LlWOfkGzphx6tJCr9e9noV5JCXL38rUKbDz0jHs3LRE4dNmYEGdQrUgqC1dZhmhaM5o8YvR(iGeupiXpQxMGlQNWB(ix8YEsk3HR21dXdfSmCvaoL0LR8IZB9rbT76cdTiTfOgDDPGwGjka1ArlwihiUsLq9ulfCnoGrJK75COE5cmAHcy2ZXL(0ixuprFJZB(ixC5nFKRuDaJgTOZ5COE5Qh(WjJSh4GAKRbex9W8bZbGzUdVC1Qpcib1ds8J6Lj4I6j8MpYfVSNS4oC1UEiEOGLHRcWPKUCjBl25H6LwGZ6tM4Up5qCqI0OEiEOGRujup1sbxzk(e3ltEjKcCwFUaJwOaM9CCPpnYf1t0348MpYfxEZh5QO4tCVSfxIf9dN1NRE4dNmYEGdQrUgqC1dZhmhaM5o8YvR(iGeupiXpQxMGlQNWB(ix8YEGn3HR21dXdfSmCvaoL0LlOSyNhQxAboRpzI7(KdXbjsJ6H4HclsBbWDpXrPMwGZ6tM4Up5qCqI0o8pkD2I2GWIglsBHLcOSqClTw11FjEJaPD4Fu6SfTaHfa39ehLAAboRpzI7(KdXbjs7W)O0zlKelallGd3IDCDXLEvFKCpsHcTiLwiULwR66VeVrG0o8pkD2I2GWcW2cOTiTfwkGYIv9rlAbclallGd3ImUKeNgwMEvOdCqKsQualAXcqwahUfy)dtjvkkOxFKmr5Yl5LqU(iPahHfqBb0wahUfwk2X1fx6v9rY9ifk0IuAHd)JsNTOniSObexPsOEQLcUYu8jUxM8sif4S(CbgTqbm754sFAKlQNOVX5nFKlU8MpYvrXN4EzlUel6hoRVfq1anx9WhozK9ahuJCnG4QhMpyoamZD4LRw9rajOEqIFuVmbxupH38rU4L9KJ7Wv76H4HcwgUkaNs6Y1oUU4sVQpsUhPqHw0Mfa3N4iLEk9MPfyIcqTCLkH6Pwk46pojqbzY5if4S(CbgTqbm754sFAKlQNOVX5nFKlU8MpYf1XjbkSi5Cw0pCwFUk)JsQNqLOqxMj4Qh(WjJSh4GAKRbex9W8bZbGzUdVC1Qpcib1ds8J6Lj4I6j8MpYfVSN8H7Wv76H4HcwgUkaNs6YLSTiV48wFuqpVNfPTa4(ehP0tP3mTatuaQ1IwGWcaPK)rYiZsrTGRujup1sbx)XjbkitohPaN1NlWOfkGzphx6tJCr9e9noV5JCXL38rUOoojqHfjNZI(HZ6BbunqZvp8HtgzpWb1ixdiU6H5dMdaZChE5QvFeqcQhK4h1ltWf1t4nFKlEzV(d3HR21dXdfSmCvaoL0LlOSyvF0IwSObKfPTa4(ehP0tP3mTatuaQ1IwGWcWTqsSaklYloV1hf0Z7zrAlASaoClazb0wKslGYcS)HPKkff0)rVpK8sixFK8p5fDKtop5SsBrAlASaoClazb0waTfWHBHLcOSyvF0I2SObKfPTaklKTf78q9s)hNeOGm5CKcCwFAupepuybC4waCFIJu6P0BMwGjka1ArlqybyzbC4wiULwR66VeVrG0RcqcLURfqBb0CLkH6Pwk4k7pIJssI3iWmxGrluaZEoU0Ng5I6j6BCEZh5IlV5JCv(J4O0czEJaZC1dF4Kr2dCqnY1aIREy(G5aWm3HxUA1hbKG6bj(r9YeCr9eEZh5Ix2Rbe3HR21dXdfSmCvaoL0LlzBrEX5T(OGEEplsBHLcG7EIJsnD2FehLKIrdG0a(JRlMjtCdWQo98SOniSaYXPgIhsN9fKjUbyvNEEwK2clfqzbuwaCFIJu6P0BMwGjka1ArlqyHKArkTaklw1hTOnlAazrAlASaoClazb0wi5waUfPTWsHfwyHfOgDDPGwGjka1ArlwilqwijwaLf78q9sdPQ75Or9q8qHfPTOXc4WTaKfqBHKBb4YYIuAbuwSQpArlqyrdilsBrJfWHBbilG2cj3Igzzb0wahUfwkGYcG7tCKspLEZ0cmrbOwlAbclASiTf746Il9Q(i5EKcfArBwiFSaAlGMRujup1sbxDph(hkZKeQf5cmAHcy2ZXL(0ixuprFJZB(ixC5nFKl5HZH)Hs5XSfYOwKRE4dNmYEGdQrUgqC1dZhmhaM5o8YvR(iGeupiXpQxMGlQNWB(ix8YEnnChUAxpepuWYWvb4usxU4kvc1tTuWL07EKomFWCaixT6Jasq9Ge)OEzcUaJwOaM9CCPpnYvpmFWCayM7WlxuprFJZB(ixCj)39KVNZdLSLLHlV5JCbhijbeiaGKe5L8F3ZIEy(G5aq5nChxP66M5k5CKAuYwiAKNqjBDd58py6fczjRuc1opuV0z)rCusMCaWY0OEiEOiDdC4GGwYBaXvp8HtgzpWb1ixdiUk)JsQNqLOqxMLHl5)Ux7s26g2dexupH38rU4L9AaN7Wv76H4HcwgUkaNs6YfQrxxkObG5COETOfiSqwYYIuAbuwSZd1lD2FehLKjhaSmTIe1dXdfwK2IglGd3cqwaTfsUfnGSiTfqoo1q8qAr2NuKmwK2cOSq2wG9pmLuPOG(p69HKxc56JK)jVOJCY5jNvAlGd3ccyjj0zk(e3ltEjKcCwFAysTaAlsBbWDpXrPMo7pIJssXObqAa)X1fZKjUbyvNEEw0gewa54udXdPZ(cYe3aSQtpplsBHSTGawscD2FehLKIrdG0WKArAlKTfeWssOZloV1NgMulsBXF07djfWCZQoTfqybilsBbuwiULwR66VeVrG0o8pkD2IwGWcG7EIJsnTaN1NmXDFYH4GePD4Fu6SfsIfGTfPTq2waLfeWssOxFKmr5Yl5LqU(iPahbTd)JsNTOflASiTfa3N4iLEk9MPbG5COETOfiSqwwaTfWHBXoUU4sVQpsUhPqHwKsle3sRvD9xI3iqAh(hLoBrBqybyBb0wK2cG7EIJsnTaN1NmXDFYH4GePD4Fu6SfTbHfnwahUf746Il9Q(i5EKcfArBqyHCCLkH6Pwk4cYrRY(CbgTqbm754sFAKlQNOVX5nFKlU8MpYvFJwL95Qh(WjJSh4GAKRbex9W8bZbGzUdVC1Qpcib1ds8J6Lj4I6j8MpYfVSxdyXD4QD9q8qbldxfGtjD5s2wqaljHo7pIJssXObqAysTiTf746Il9Q(i5EKcfArBqyHKAHKybuwSZd1lDggXIUeyDrAfjQhIhkSiTfnwahUfGSaAUsLq9ulfCL9hXrjPy0aixGrluaZEoU0Ng5I6j6BCEZh5IlV5JCv(J4O0I(nAaKRE4dNmYEGdQrUgqC1dZhmhaM5o8YvR(iGeupiXpQxMGlQNWB(ix8YlxEZh5Qu)wTOGrSpCPqE2Iw7xMxMb]] )

    storeDefault( [[SimC Subtlety: finish]], 'actionLists', 20171225.003612, [[dWJfjaGErr0MOq7cKTPQI2NQQmBPA(I0nvL8yu5BQQQdlzNkQ9kSBsTFKrrrggLYVj5qQIUNIWGHgoLQdkk1POOoMQY5uvblur0srvzXkSCP8qufwLQk1YerRtvfAIII0uvLAYu10v5Iks9krjEMOiCDr1PrzRIsAZGA7IW0uK8DuL(SQW8qv1TvQ)QKrtjVwu4KOk6wQQKRjkQZtbxM45u5PahFX7amTUgDXhJaaSlCSQZYK1Xu6yo5p)cqMkWvE)IjdaFsxkNeZjT99)xYKtbL877l5peaaxJz)cqaYM7ykTlEhZFX7amTUgDXhtgaaxJz)cGjcFs4vDrFq(QLXYzvEfVqIUgDXtyAkHpjCKddd5SkVI3LV0CcuUDcntOrcVQ9qoOJTL1PwEMq4ViSj7IPDe(hH)KqJeAIWDPVUS85T6yknHtqOncttjSj7IPDeY)eeUl91LLpVvhtPj0mHgj0eHMiSjWnXzvJUqOrcnr4tcHz6QZodeMMs4ihggcMPRo7mS0Shw3OxEbk3oHPPeMOASA0fiVZA5HlcntOzcttjSj7IPDeYpHhJlJ1X2cH)MWKeAMqJeAIWI7yjKLOLntCeYpHtrOrcFsyIQXQrxG8oRLhUimnLWNeoYHHHCg2dv3TuWlVuNfuUDcnhGShSo7mean7H1n6Lxcap1EgxDQwa0kTeGxkFwR2CTLaeG5AlbyM9W6g9YlbGpPlLtI5K2(()Zwa4tCQ8gN4I3XfaEyjCz8sLq2I(IraEP8Z1wcqCXCY4DaMwxJU4JjdaGRXSFbWeHpj8QUOpiVuN1cUP2RAOsiqIUgDXtyAkHo5wdLo3bDmP99dRK25i8pcTrOzcnsOjcFs4vDrFq(QLXYzvEfVqIUgDXtyAkHpjCKddd5SkVI3LV0CcuUDcntOrcVQ9qoOJTL1PwEMq4ViSj7IPDe(hHFjj0iH7sFDz5ZB1XuAcNGqBeAKqteAIWMa3eNvn6cHgj0eHpjeMPRo7mqyAkHJCyyiyMU6SZWsZEyDJE5fOC7eMMsyIQXQrxG8oRLhUi0mHMjmnLWMSlM2ri)eEmUmwhBle(BctsOzcnsOjclUJLqwIw2mXri)eofHgj8jHjQgRgDbY7SwE4IW0ucFs4ihggYzypuD3sbV8sDwq52j0CaYEW6SZqa0Shw3OxEja8Ws4Y4LkHSf9fJa8s5ZA1MRTeGaWtTNXvNQfaTslbyU2saMzpSUrV8cHM(mhGSBpCbGZaxxwx1EiNBIVaWN0LYjXCsBF))zla8jovEJtCX74capmW1L3v7HCUyYa8s5NRTeG4I5mr8oatRRrx8XKbaW1y2Va0KDX0oc5NqoLQ7v8QHCg2dv3TuWlVuNfut2ft7imle(zJqJeYPuDVIxnKZWEO6ULcE5L6SGAYUyAhH8pbHzMWSqOjcnriNApul7kM(CqC5TMOpcNGWFsOzcns4hHPPeAJqZeAKWRApKd6yBzDQLNje(lcBYUyAhH)riNs19kE1qod7HQ7wk4LxQZcQj7IPDeMfcZCaYEW6SZqa0Shw3OxEja8u7zC1PAbqR0saEP8zTAZ1wcqaMRTeGz2dRB0lVqOPKMdaWsX7lLNbZKMlgbGpPlLtI5K2(()Zwa4tCQ8gN4I3XfaEyjCz8sLq2I(IraEP8Z1wcqCX8uX7amTUgDXhtgG5AlbitL6SieUP2eM9qLqcaGRXSFb4jHx1f9b5RwglNv5v8cj6A0fpHPPeAIWNeoYHHHCwLxX7YxAobk3oHPPewChlHSeTSzIJW)MGWPi0mHgj0eHJCyyiNH9q1Dlf8Yl1zbLBNW0uc5uQUxXRgYzypuD3sbV8sDwqnzxmTJW)MGWpBeMfcDYTgkDUd6yslPT1u25i83eMzcntOrch5WWqNLSGzn3TuWRZswEP8qnzxmTJq(j8JqJeAIWrommemtxD2zyjjyooPvNaLBNW0uclUJLqwIw2mXri)eofHMdq2dwNDgcGxQZAb3u7vnujKaWtTNXvNQfaTslbGpPlLtI5K2(()Zwa4tCQ8gN4I3XfxmN54DaMwxJU4Jjdq2dwNDgcGKG54KwDsa4P2Z4Qt1cGwPLa8s5ZA1MRTeGamxBjatNG54KwDsa4t6s5KyoPTV))Sfa(eNkVXjU4DCbGhwcxgVujKTOVyeGxk)CTLaexCbyU2saaSnpieKpUUCg(rcHzAMZkUia]] )

    storeDefault( [[SimC Subtlety: build]], 'actionLists', 20171225.003612, [[d4dAeaGEQKQnHKKDrW2qk2hss9ycDyfZwK5RuKBsuDxQkUTOEUQStk1EH2TG9lzueLHjK(nkNNiNMIbl1WvvCqQkDkkPJjuNJkjTqKulvPAXiSCu9qLcpL0YqI1rLetKkrMQQQjRKPRYfPk8kQe1ZukQRJuTiHyRQk1MrkTDQQ(ivszAuj0NPeFhjXBPs1FPIrJOXtLYjvvYTOk11Ok6Euj4BuLCzWRvkngJ)O6ryisWcjqvf5MphQOQFarZKmU(CgwaTPqtmQ2tgqvn5nQwPtCj4KCLQjOBslu3HempaTPen2RykuCrbkXXXuCvu3Hzj9BYaQqa4wKCV6iNjdohZjs1ccvlRAiaClsc5XTQ9UAzv7F4MHibcVdM0r6CKC4rYsRQz8QPXZQTwT1Q9bvFfpdl8WF0og)r1JWqKGfsnQQi385qDepJFWbcq2aVQPAxOAkv7YvlRAc60sRWrco0A4VZHrRZrcolywc0)unvvDC1BAtvhTAROsfsiSdZsc1Ni385q9RWYiohJJAGfauLZwFpC7jdOIQVeMK5Kq9rsNB2cbN3X4zuTNmGQssNB2cHQ1JXZOUdpgDUi8WF8qDhsW8a0Ms0yVIJI6omlPFtgqfca3IK7vh5mzW5yorQwqOAzvdbGBrsipUvT3vlRA)d3mejq4DWKosNJKdpswAvnJxnnEwT1QTwTpOUbjiUvoZpKHWHeOkNTSNmGkEOnf8hvpcdrcwi1OsfsiSdZsc1Ni385q9RWYiohJJAGfauLZwFpC7jdOIQVeMK5Kq1sIXYePzbOApzavxlXyzI0Sau3HhJoxeE4pEOUdjyEaAtjASxXrrDhML0VjdOcbGBrY9QJCMm4CmNivliuTSQHaWTijKh3Q27QLvT)HBgIei8oyshPZrYHhjlTQMXRMgpR2A1wR2hu3Gee3kN5hYq4qcuLZw2tgqfp0EZ4pQEegIeSqQrLkKqyhMLeQprU5ZH6xHLrCogh1alaOkNT(E42tgqfvFjmjZjHkXiU9DdbQ2tgqL6rC77gcu3HhJoxeE4pEOUdjyEaAtjASxXrrDhML0VjdOcbGBrY9QJCMm4CmNivliuTSQHaWTijKh3Q27QLvT)HBgIei8oyshPZrYHhjlTQMXRMgpR2A1wR2hu3Gee3kN5hYq4qcuLZw2tgqfp8q1LaAh6PdPgpeb]] )

    storeDefault( [[IV Subtlety: Single-Target]], 'actionLists', 20171225.003612, [[d4ZejaGEbuAtkL2fPABqcTpbvpMQoSuZMkZxc(KasDiir9nLI7juANKYEvTBO2pWOeG)QOgNaIonQUmYGbnCfCqLkNIe1XiPZPqjlucTui1IvYYj62c5PuwgjSobeMOGstfIMSKMUOlQu1RGe8mfkUoeEoHTkGQnliBxO4JkuQPbjYNfQMhjsFxH8AfQgTImEbKCsiPBjGIRrI48c0kfummj63O8vpYB7X9Yr1VUzEjFiVDlSuOgHlFXBOjh1c6Akkv3OQqbkPRqvvvXyDZgipVD8aBNCg(Akqr1B78jNHfh51upYB7X9Yr1x8M5L8H8MiP2LtuvVDoaClagaaM8icaJfalbWcfaqplAXMhyCCk09iKscNaOsbqLaGOaagaaMTJWPEJtUNp0jNH1jCVCufa3cGkaWcfaWsauzau5B7wChpdEtm1v2irk5Jt3qtoQf01uuQUrT8gQ4k33jtEdZW0n0KGHq6jXr(8Mwhr3SPUYgjsjFC651uCK32J7LJQV4nZl5d5TkTqekKoMhFkxUUs6v2imawOaacctaaOKcjjXuVCeaUnBzCk1tEenNS5kNaWWbqjf1CSaa3cGEw0InpW44uO7riLeobWWJfavcaIcayaay2ocN6vIgi5SiLDsXPiDc3lhvbWTaOkawOaawcGkdGkFdnjyiKEsCKpVTBXD8m4nmp(uUCDLUHkUY9DYK3WmmDdn5OwqxtrP6g1YBADeDtJhFkxUUspV2yoYB7X9Yr1x8M5L8H82n0KGHq6jXr(82Uf3XZG3etDLnAE56kjUHkUY9DYK3WmmDdn5OwqxtrP6g1YBADeDZM6kBeaw01vs88AO0rEBpUxoQ(I3mVKpK38tTmojaWybqfayHcGWeaaMTJWPoHJHCSboo(SyQRSrcDc3lhvbWTaOFQLXjXCiz7tod3oamCauHUsaqLbWcfaHjaaeLbWSDeo1jCmKJnWXXNftDLnsOt4E5OkaUfa9tTmojMdjBFYz42bGHdGQ6O4gau5BOjbdH0tIJ85TDlUJNbVjM6kB0CTXE6gQ4k33jtEdZW0n0KJAbDnfLQBulVP1r0nBQRSrayyBSNEEnLCK32J7LJQV4nZl5d5TaaqctY4b1RuiUNNay4aikvcGBbWfIqH0ftDLnAU2ypPJyaavgaluaeMfIqH0RuNtZHKSO5EXIH0rmCB3I74zWBIGrlMtmZcnxPoNUHMCulORPOuDJA5nuXvUVtM8gMHPBOjbdH0tIJ85nToIUzbJwmNaazHaWWsDo98AO4rEBpUxoQ(I3mVKpK38SOfBEGXXPq3JqkjCcGknwaCma4waeLbqrsTlNOQE7Ca4waS9jNH1ftDLnsKs(4KUK6AWB7wChpdElMgZft3qtoQf01uuQUrT8gQ4k33jtEdZW0n0KGHq6jXr(8Mwhr3c8gZftpV2MJ82ECVCu9fVzEjFiV5zrl28aJJtHUhHus4eavASa4yUTBXD8m4nXuxzJePKpoDdn5OwqxtrP6g1YBOIRCFNm5nmdt3qtcgcPNeh5ZBADeDZM6kBKiL8XjamavLFETa5rEBpUxoQ(I3mVKpK3qzauKu7YjQQ3ohaUfa9SOfBEGXXPq3JqkjCcGknwaCma4waKWKmEqDpcPKWjaQuaujL32T4oEg8wCMKI6rI5fpPBOjh1c6Akkv3OwEdvCL77KjVHzy6gAsWqi9K4iFEtRJOBJntsr9OaTaalYt651gRJ82ECVCu9fVP1r0TWsDobGHKSiaC3IfdDZ8s(qEZZIwS5bghNcDpcPKWjagESaOFyoQduZIbcxVHMCulORPOuDJA5nuXvUVtM8gMHPBOjbdH0tIJ85TDlUJNbVvPoNMdjzrZ9Ifd98AQLh5T94E5O6lEtRJOB7JHl8KSt6M5L8H8MNfTyZdmoof6EesjHtam8ybqLaGOaagaaMTJWPELObsolszNDCksNW9YrvaClaQcGfkaGLaOY3qtoQf01uuQUrT8gQ4k33jtEdZW0n0KGHq6jXr(82Uf3XZG3Oy4cpj7KEEnv1J82ECVCu9fVP1r0TITFCr2RBMxYhYBEw0InpW44uOxPqCppbWWbWYBOjh1c6Akkv3OwEdvCL77KjVHzy6gAsWqi9K4iFEB3I74zWBR2pUi71ZN306i6gQboaAiwPJYGbca0444okWGSLXP85p]] )

    storeDefault( [[IV Subtlety: AOE]], 'actionLists', 20171225.003612, [[d4JUkaGEPkrBsc2LG2gbK9rk8yQ6WkMTqZhf6tsvc)gvFdeUNuf7Kk2RQDJy)k9tsPI)kW4iLkDAKoePuAWadxQCquWPiLCms15KQKwOuvlfLAXGA5KCzONszze06iLQAIsvQPIsMSuMUOlcIEfbupJkvxxIgfPOTcskBMkz7eOpcsQMgPu8zuuZdK47GuVMkLrlPgpPuLtII8CIUgb48sOvcsYWKKBtOV(zDdsYahX2HVzEfTlVDR3ORPmMV)n2yehjEhHv6qOluO2ekuxxxyVEZ6qpDI0E5Kuo5ocfi9Bm4tkNipR7OFw3GKmWrS9(3mVI2L3KjoXSgBHtmUGclqZf45IW8GooLKYqFPsHKCbqzbcybc8c0Cb5ersgoKK6PDts5KqKmWrSTGclq4cyKXfuTaTwqHfm(KkigGeuKIYfaLf4Uw3yJrCK4DewPdHE1nMinQFsU6gHtWBSrjVu5r5z98MZiI3S6PXHwMkQB4Z7i8SUbjzGJy79VzEfTlV1q4sxUcjuMRt440WWghAYcyKXfSqLMlqHUuOSEGJ4ckKJIzmdtQigK8GgfxGglqHIdLixqHf45IW8GooLKYqFPsHKCbA0ZceWce4fO5cYjIKmSHyhQcKPAsKzumejdCeBlOWc0xaJmUGQfO1c06gtKg1pjxDJWj4ngGPrAw8gHYCDchNgEJnk5LkpkpRN3yJrCK4DewPdHE1nNreV5qzUoHJtdFEh3pRBqsg4i2E)BMxr7YBJpPcIbibfPOCbqzbc4gtKg1pjxDJWj4ngGPrAw8MSEACOdGJtdL3yJsEPYJYZ65n2yehjEhHv6qOxDZzeXBw904qVG(XPHYN3rBoRBqsg4i2E)BMxr7YB(6rXmkxqplq4cyKXfQ0Cb5ersgIebXiVJsyoqwpno0YqKmWrSTGclWxpkMrzGl14tkNmXfOXcegkGfO1cyKXfQ0CbA7cYjIKmejcIrEhLWCGSEACOLHizGJyBbfwGVEumJYaxQXNuozIlqJfOhkqqSaTUXePr9tYv3iCcEJbyAKMfVjRNgh6G2q84n2OKxQ8O8SEEJngXrI3ryLoe6v3Cgr8Mvpno0lO3dXJpVJaoRBqsg4i2E)BMxr7YBWLUCfkRNgh6G2q8yyz3ckSapxeMh0XPKug2qxupnxGglOAbfwW4tQGyasqrkkxGg9Sa3VXePr9tYv3iCcEJbyAKMfVjRlvu3qsGm5kXBSrjVu5r5z98gBmIJeVJWkDi0RU5mI4nRUurDdjlWsUs85DeOZ6gKKboIT3)M5v0U8MMlajOI5IHn0f1tZfOXc0MQfuybWLUCfkRNgh6G2q8yyz3c0AbmY4cvWLUCf2WjRdCP4IbdmxqmSS7gtKg1pjxDJWj4ngGPrAw8MSOimpkd4UcA4K13yJsEPYJYZ65n2yehjEhHv6qOxDZzeXBwrryEuUaURf0BCY6N3bIZ6gKKboIT3)M5v0U8MNlcZd64uskd9LkfsYfaLEwG7lOWc02fitCIzn2cNyCbfwW4tkNekRNghAzQOUHHkCAfVXePr9tYv3iCcEJbyAKMfVj4qOY6BSrjVu5r5z98gBmIJeVJWkDi0RU5mI4nO2qOY6N3r7Ew3GKmWrS9(3mVI2L38CryEqhNsszOVuPqsUaO0ZcCFbfwW4tQGyasqrkkxauwG73yI0O(j5QBeobVXamnsZI3K1tJdTmvu3WBSrjVu5r5z98gBmIJeVJWkDi0RU5mI4nREACOLPI6gUan1165D61Z6gKKboIT3)M5v0U8MNlcZd64uskdBOlQNMlqJfuTGcly8jvqmajOifLlqJEwG73yI0O(j5QBeobVXamnsZI3K1LkQBijqMCL4n2OKxQ8O8SEEJngXrI3ryLoe6v3Cgr8MvxQOUHKfyjxjUan1165D0RoRBqsg4i2E)BMxr7YBA7cKjoXSgBHtmUGclWZfH5bDCkjLH(sLcj5cGsplW9fuybibvmxm0xQuijxauwGaQUXePr9tYv3iCcEJbyAKMfVXmxHId0YayAI3yJsEPYJYZ65n2yehjEhHv6qOxDZzeXBqDUcfhO7fYf0NM4Z7ORFw3GKmWrS9(3mVI2L38CryEqhNsszOVuPqsUan6zb(UaXr7fi7qs7gtKg1pjxDJWj4n2yehjEhHv6qOxDJnk5LkpkpRN3Cgr8wVXjRxGlfxCbmaZfeVXamnsZI3A4K1bUuCXGbMli(8o6cpRBqsg4i2E)BMxr7YBEUimpOJtjPm0xQuijxGg9SabSabEbAUGCIijdBi2HQazQMCygfdrYahX2ckSa9fWiJlOAbADJjsJ6NKRUr4e8gdW0inlEdfKk9OAs8gBuYlvEuEwpVXgJ4iX7iSshc9QBoJiEdsbPspQMeFEhD3pRBqsg4i2E)BMxr7YBEUimpOJtjPmSHUOEAUanwq1nMinQFsU6gHtWBmatJ0S4nzDPI6gscKjxjEJnk5LkpkpRN3yJrCK4DewPdHE1nNreVz1LkQBizbwYvIlqtHA985nNreVXeuBbwjCgXSO2FbmODG85p]] )

    storeDefault( [[IV Subtlety: Default]], 'actionLists', 20171225.003612, [[dqt6daGEKO6LsqTljW2qPyFOuA2cDtffFtcTta7LA3G2Va)KKWWKKFlYGf0WrjhebhdOZHeLfkrwQKAXOy5O6PQwMc9CrnrjQMkjMmIMoXfrkxg66kYJj1wvuAZiHTlb5WsDBfmnuQCEKQtR0ZqI0Ojj9zsQtIKUfsexJKO7Hsv)fHwNeLxROAdAfFAWMjIKMX)A(Ys89lhPONIIl5xJrSZObgRalcooYUcgbbbhPm)Zc1BhxkVLnbnWiBa9jOLnbZwXaGwXNgSzIiPl5d0dO)fSJIQ(xZxwIVpbMnUcD)SGDuu1VgZPjUgZwXIFngXoJgyScSiyLpvi5QBjX9HjiAXaJwXNgSzIiPl5d0dOFHx9C)R5llXxAUAukq3zzHQ9jWSXvO7pF1Z9RXCAIRXSvS4xJrSZObgRalcw5tfsU6wsCFycIwmaLAfFAWMjIKUKpqpG(e46gIbHkjohHI)18LL4lnxnkfO7SSq1(ey24k09BUUHirjX5iu8RXCAIRXSvS4xJrSZObgRalcw5tfsU6wsCFycIwma7SIpnyZersxYhOhq)zA(CKmiKIepiSCSfv9VMVSeFDAGjrKvAHsUasKIvVsqiBzFqOk9jWSXvO7p085ijrksCIKylQ6xJ50exJzRyXVgJyNrdmwbweSYNkKC1TK4(WeeTyavAfFAWMjIKUK)18LL43AzleseH4WI5Gq2hec6d0dO)xO6igeQ0C1O4tfsU6wsCFycI(1ye7mAGXkWIGv(1yonX1y2kw8jWSXvO7ZNGeBTSjiX4Mf)zsKa9a6tD2GWpXiruOxwq4xO6isjknxnkwmaBSIpnyZersxY)A(Ys8BTSfcjIqCyXCqiBdcb9b6b0NGkO5tfsU6wsCFycI(1ye7mAGXkWIGv(1yonX1y2kw8jWSXvO7ZNGeBTSjiX4Mf)zsKa9a6tD2GWpXiruOxwqibvqZIfFGEa9PoBq4NyKik0lliSCKIEkkwSb]] )


    storeDefault( [[Subtlety Primary]], 'displays', 20171225.003612, [[dWtWgaGEPuVerLDbcvVgemtQQA2s1JrYnrf64OI(gII6AiQANuAVIDt0(PQ8tf1WGk)gYZj1qrXGPidhHdQGTHOGJrOZrbQfkflLcAXi1YPYdLsEQQLrrToeLAIGqMkuMmQ00v6Ik0vrfCzGRdQnsH2kiu2mQA7qvFKQkFgKMgIs(ovzKuapdrHgnknEq0jrKBrbYPj58eCyjRfrrUTICedwovrSkK0isUFf6G8zoG5pj7yovrSkK0isUx1geRO5CxjHcAXcOGqAYP7Q2T9RJ8cDUWmpVgSTkIvHK6yXLd5mpVgSTkIvHK6yXLZjmagWLefsEvBqSKhx(KsomglzmNtyamGBRIyviPon5cZ88AWIvoOGvhlUCnlY7EQLIDymn5AwK3a8IstUMf5Dp1sXoaVO0KVLdkyhKuSixEZmg2mhnKKFgalxiwdYSiUCEKCZzW8z6Lu7ZKTCoKxUMf5HvoOGvNMCiqpiPyrUCSzgdj5NbWYvsUkQArUbjflYLBij)mawovrSkKCqsXIC5nZyyZCm)eakv1vTRvHKXAMmiMRzrEhln5CcdGbqKYbOwfsMBij)mawUeEIefsQJLSY1eGE3yV0STqDKly5vSI50XkMdnwXCxSIzZ1SiVwfXQqsDOZHCMNxd2byxflU8c2vyceGCAyE(8PcYb4fflUC6UQDB)6iVHEp05vNGTolYJb)ySI5vNGTAHMORLb)ySI5qeGVG7BAYRUxjOzWZKMC8kTIw1vRaMabiNoNQiwfso0vqL5TgTyJgMZvPj6LaMabiVYDLekatGaKx0QUAfYlyxXrLeKMCiqBej3RAdIv0CE1jylSYbfSm4zIvm3b65TgTyJgMRja9UXEPzdDE1jylSYbfSm4hJvmNtyamGljjxfvTiNon52AcKFy6TdwbFMyCQPYjKVLdkynIK7xHoiFMdy(tYoMpPKdWlkwC5qG2isUFf6G8zoG5pj7yoKZ88AWsUgDSI5vNGTg6ELGMbptSI5qglUCcNAQCcgrY9Q2GyfnNt4auOj6Ahy8p)QPw(mDy6TdwbY2NjchGcnrxBUIcjjti0uSIKpFQGCymwC5kkK8efLscnwYNVLdkyzWpg6CcNAQCcKOqYRAdIL84Yne0bLgeRzCIKzrZMjliUzrrrZgCoNWayWqxbvobKBovoKZ88AWssYvrvlYPJfxUWmpVgSKKCvu1IC6yXLVLdkynIKBodMptVKAFMSLZH8YHCMNxdwSYbfS6yXLRzrEKKCvu1IC60KRzrEdWUIKKhf68Q7vcAg8JPjxZI8yWpMMCnlYBymn5uOj6AzWZe68c2vdskwKlVzgdBMJ(pAelVGD1ja9ojikwC5CcROGaetP)k0b5v(KsESyXLVLdkynIK7vTbXkAoVGDfjjpctGaKtdZZNtveRcjnIKBodMptVKAFMSLZH8YRobB1cnrxldEMyfZhLfDhWnn5A1erhmmpgR5CHzEEnyhGDvS4YHaTrKCZzW8z6Lu7ZKTCoKxE1jyRHUxjOzWpgRy(woOGLbptOZPqt01YGFm05AwKh5ac0kjxLeQon5AwKhdEM0KpvqESyfZRobBDwKhdEMyfZ5egad4Aej3RAdIv0CUWmpVgSKRrhRbjMZjmagWLCn60KZfWxW9DGX)8RMA5Z0HP3oyfiBFM4c4l4(MxWUIds1Mt0lbGlBc]] )


end

