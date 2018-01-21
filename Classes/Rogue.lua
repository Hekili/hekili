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

            tier20_4pc = {
                resource = 'energy',

                spec = 'subtlety',
                aura = 'symbols_of_death',

                last = function ()
                    return state.buff.symbols_of_death.applied + floor( state.query_time - state.buff.symbols_of_death.applied )
                end,

                interval = 1,
                value = function () return state.set_bonus.tier20_4pc > 0 and 2 or 0 end
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
        addAura( "nightblade", 195452, "duration", 18, "tick_time", 2 )
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

        addAura( "shadow_gestures", 257945, "duration", 15 )  -- t21 4pc
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

                        if amt > 0 and state.set_bonus.tier21_2pc > 0 then
                            if state.cooldown.symbols_of_death.remains > 0 then
                                state.cooldown.symbols_of_death.expires = state.cooldown.symbols_of_death.expires - ( 0.2 * amt )
                            end
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

        -- Tier Sets
        addGearSet( "tier21", 152163, 152165, 152161, 152160, 152162, 152164 )
        addGearSet( "tier20", 147172, 147174, 147170, 147169, 147171, 147173 )
        addGearSet( "tier19", 138332, 138338, 138371, 138326, 138329, 138335 )


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
            recheck = function () return buff.shadow_dance.remains, buff.the_first_of_the_dead.remains - 1 end,
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
            if state.set_bonus.tier21_4pc > 0 then
                if state.buff.shadow_gestures.up then
                    state.removeBuff( "shadow_gestures" )
                    state.gain( cost, "combo_points" )
                end
            end 
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
                else applyBuff( "finality_eviscerate" ) end
            end
            removeStack( "feeding_frenzy" )
            removeBuff( "shuriken_combo" )
            if state.set_bonus.tier21_4pc > 0 then
                if state.buff.shadow_gestures.up then
                    state.removeBuff( "shadow_gestures" )
                    state.gain( cost, "combo_points" )
                end
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
            equipped = 'fangs_of_the_devourer',

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
            usable = function () return target.casting end,
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
            recheck = function () return buff.shadow_dance.remains, buff.nightblade.remains - mantle_duration, buff.nightblade.remains - ( buff.nightblade.duration * 0.3 ), buff.nightblade.remains - ( buff.nightblade.tick_time * 2 ), buff.symbols_of_death.remains end,
        } )

        modifyAbility( "nightblade", "spend", function( x )
            if buff.feeding_frenzy.up then return 0 end
            return shadow_focus( x )
        end )

        addHandler( "nightblade", function ()
            local cost = min( 5 + ( talent.deeper_stratagem.enabled and 1 or 0 ), combo_points.current )
            spend( cost, "combo_points" )

            gainChargeTime( "shadow_dance", cost * ( 1.5 + ( talent.enveloping_shadows.enabled and 1 or 0 ) ) )

            applyDebuff( "target", "nightblade", 6 + ( cost * ( set_bonus.tier19_2pc > 0 and 4 or 2 ) ) )

            if artifact.finality.enabled then
                if buff.finality_nightblade.up then
                    debuff.nightblade.pmultiplier = 2
                    removeBuff( "finality_nightblade" )
                else
                    debuff.nightblade.pmultiplier = 1
                    applyBuff( "finality_nightblade" )
                end
            end

            if state.set_bonus.tier21_4pc > 0 then
                if state.buff.shadow_gestures.up then
                    state.removeBuff( "shadow_gestures" )
                    state.gain( cost, "combo_points" )
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
            recheck = function () return buff.shadow_dance.remains, target.time_to_die - ( talent.subterfuge.enabled and 5 or 4 ) end,

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
            recheck = function () return cooldown.death_from_above.remains - 1 end,
        } )

        modifyAbility( "symbols_of_death", function( x )
            return set_bonus.tier20_4pc > 0 and ( x - 5 ) or x
        end )

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


    storeDefault( [[SimC Subtlety: stealthed]], 'actionLists', 20180108.000534, [[d8JEhaWyLSEQkvBsq2LqTncI2hvfZKGWHbMTcZhc3KQQ7sqQVjjADQcTtjSxKDt0(jnkczysLFd15vKonObtz4svheI6ueQJjrNJavwOIOLQk1IH0YvQfrq5PIwMK0ZPYejqPPQOAYsz6QCrvbVsr4YOUov5HkkBfIyZcSDc4ZqKEMKW0iqX8OQu(RqETGA0sQVRk5Kei3IavDnQk5EQIElbj3wvDCcQMkP5u(GeGo4gHsz2Zliya9DWbXsQOQqwszb4ZuMW)m1sp0BW30hvZDmyC1CJY38GboMkQ2vwzz1Q(kURRcHSSkL5Ad7pkPe51bXshnNkkP5u(GeGo4gnjL5Ad7pkr9ccIDhdgxDSxpLiJchWBkLUAqd)YDByyMsbjBWf4WBkLyjtPFCdjGDb4Zuszb4ZuM1Gg(L72WWmLV5bdCmvuTRSYYokFZoS3EXoAoDuoRMxH9JfG)S8iuk9JBfGptjDurvAoLpibOdUrtszU2W(JYf(JIJ6Xq55IxE7nlp185PA(sTjutKAIu7adwEXnM75DK72GdGu(hZsa6GBQfsnuVGGybasORo2RxnXQfsTs1qGqTo1eRwi1ePgyDqb4iwYFi7uZNNQvHAtOMi1yH7b775wSRg0WVICGB62f9cmcRwi1kvdbc16utSAiqOMi1(a5n4OM3gCqSunF7PALXvOwi1(a5n4OM3gCqSunFEQwxCfQjwnXuImkCaVPuUaJreyDqSmAaDhLcs2GlWH3ukXsMs)4gsa7cWNPKYcWNPeXkiORBTcceQzGXqnKxhelvtiGUtOrSPe5nsDukbF(PWs4FMAPh6n4B6JQfaLqxTWO8npyGJPIQDLvw2r5B2H92l2rZPJYz18kSFSa8NLhHsPFCRa8zkt4FMAPh6n4B6JQfaLqxnDurf0CkFqcqhCJMKYCTH9hLOEbbXUAqd)6ZJwCd)sQwi1ePMi1w4pkoQhdLNlUXbWf8uZNNQvvTjutKASW9G99ClgkDqKkHGiCq0gialRXJ2Pwi1kvdbc16utSAHudSoOaCel5pKDQ5Zt1QqTjutKASW9G99Cl2vdA4xroWnD7IEbgHvlKALQHaHADQjwnXQHaHAIuBH)O4OEmuEU4ghaxWtnFEQwPAHud1lii(Q5O2MbTbE3CrnEXWl2DGvy185PAvfCQjwnXuImkCaVPu6Q92WWSmYD49NsbjBWf4WBkLyjtPFCdjGDb4Zuszb4ZuM1EByywQwE49NY38GboMkQ2vwzzhLVzh2BVyhnNokNvZRW(XcWFwEekL(XTcWNPKoQqWqZP8bjaDWnAskZ1g2FuUWFuCupgkpx8YBVz5PMppvZxQnHAIutKAhyWYlUXCpVJC3gCaKY)ywcqhCtTqQH6feelaqcD1XE9QjwTqQvQgceQ1PMy1cP2c)rXr9yO8CXnoaUGNA(MAvO2eQjsnuVGGyxnOHFfHoan2f71Rwi1kvdbc16utSAcE1ePglCpyFp3I)a5n4iCq0vZrFG74DeW5aohuQwi1kvdbc16utmLiJchWBkLlWyebwhelJgq3rPGKn4cC4nLsSKP0pUHeWUa8zkPSa8zkrScc66wRGaHAgymud51bXs1ecO7eAeB1evkMsK3i1rPe85NclH)zQLEO3GVPpQwaucD1cJY38GboMkQ2vwzzhLVzh2BVyhnNokNvZRW(XcWFwEekL(XTcWNPmH)zQLEO3GVPpQwaucD10rf(IMt5dsa6GB0KuImkCaVPu6Qbn8l3THHzkfKSbxGdVPuILmL(XnKa2fGptjLfGptzwdA4xUBddZQjQumLV5bdCmvuTRSYYokFZoS3EXoAoDuoRMxH9JfG)S8iuk9JBfGptjD0rPGLdaEJJMKoIa]] )

    storeDefault( [[SimC Subtlety: stealth CDs]], 'actionLists', 20180108.000534, [[diK5haqivQAtcQrPQQtPQYQir6vKiMfuQ0TGsf7cQgMqoMszzKWZGsAAcORPevBtjk(MkvwNsuAEkv09uvSpvLoOuslukLhQezIKO6Isj2iuk1jHsCtbANsXqvQWsvQ6PkMQkXwvQ0BHsj3fkf2lQ)QkdMQdlzXq6XQyYK6YiBwO(SamAs60I8APunBP62qSBc)gy4cYXHsvlxupNOPd66kPTRs67kHXtIY5vPSEOu08HI9tzEJVWtlIcTtAgLNjeDsvpHnlyci4gflZgpnfcXZKqwY8zff2j4TL1CjKQou18LuUKN9uNkjXnkI2UBtHILJhfH1LztbpZjNcb5HNwpWeqi5lCZgFHNwefAN0CB8mNCkeKN7n)ALtfANW1s1NoUmpS5iLa2PNEnxWeqy(hZJmpS5haORble4s1sdw80L4q4h1khajFX56atar1nFNMFTYPcTt4sv9loxhyciQU5kX8)M)3Cc7xtHcrACKsa70de)GQ0dPKqk)kPSKYKW8WMdtiK570CSgz(pZdB(M5yWyEK5)mxPMhHJvZdB(FZV3Cc7xtHcrACKsa70de)GQ0dPKqk)kPSKYKWCmymhDnogxEdbf0Lpq8ttfufFnK5)4Pv0upbVXZ1sKKQ8GfHoDkiiZJaiiEcc07w5McH4HNMcH4z3sKKQ8SN6ujjUrr02DBr8SNKG18HK8fgYZsQ0P9GGRecjGmkpbb6McH4HHCJc(cpTik0oP524zo5uiipAaexKcqfI2lnHNjKkjKM)9J5l38WMFuRCaK8fNRdmbev38VFm)ALtfANWLQ6xCUoWequDZXGXCyLdGG4Wec9GGNorMVtZpaqxdwiWL3qqbD5de)0ubvXZesLesEAfn1tWB8ivlnyXtxIdXdwe60PGGmpcGG4jiqVBLBkeIhEAkeINrT0GfMR8sCiE2tDQKe3OiA7UTiE2tsWA(qs(cd5zjv60EqWvcHeqgLNGaDtHq8WqUbR8fEAruODsZTXtROPEcEJNqaq)LjjynFiEWIqNofeK5raeeplPsN2dcUsiKaYO8SdaO3IYG5IBcmINGa9UvUPqiE4zhaqhBdYnKYGCB80uiepyoXXrrNtCm2Ahaq389KeSMpe2atMNwZbi5jgKFcszWpByxszWC9keWQa(jWiE2tDQKe3OiA7UTiE2tsWA(qs(cd5zublcc0P4eLLmkpbb6McH4HHCtG8fEAruODsZTXZCYPqqEibLd4g(znNjb08VFmpWiZdBojOCa3W1uC6KGM)9J5BrMReZVw5uH2jCPCXltXRcnpTIM6j4nEKQLgSaH6AEWIqNofeK5raeepbb6DRCtHq8WttHq8mQLgSaH6AE2tDQKe3OiA7UTiE2tsWA(qs(cd5zjv60EqWvcHeqgLNGaDtHq8WqUz58fEAruODsZTXZCYPqqEU38RvovODcxlvF64Y8WMFaiOGxiqsaL4AkoDsqZ)(XCfMReZ)BoS6KaIlxrHuoEnacNefAN0Mh28nZXGX8iZ)zUsnxH5Hn)V5ORXX4YBiOGU8bIFAQGQ4zcPscP5F)y(gUcZXGX8da01GfcC5neuqx(aXpnvqv8mHujH08VFmFtH5kX8)M)3Cy1jbexx52Fs1sdwGtIcTtAZdBUKGpuGyvIdtuwr0lWqhZ)AEK5)mpS5BMJbJ5rM)ZCLAownh7y(FZ)B(9MdRojG46k3(tQwAWcCsuODsBEyZLe8HceRsCyIYkIEbg6y(xZJm)N5HnFZCmympY8FMRuZd0CmymhPeWo90R5cMacZ)AEK5)mpS5)nVoW0v6rccjrsZ)(X8anhdgZV3C014yCOk9Itzj8bIFqv6PPsJVgY8F80kAQNG34rQwAWINUehIhSi0PtbbzEeabXtqGE3k3uiep80uiepJAPblmx5L4qM)F7hp7PovsIBueTD3wep7jjynFijFHH8SKkDApi4kHqciJYtqGUPqiEyid5r5uCT2HCBmKza]] )

    storeDefault( [[SimC Subtlety: default]], 'actionLists', 20180108.000535, [[dqusxaqikjSisqBIkmkvjNsv0QKuk9kGIzbus3ssPODrsdJkDmGSmvHNjPW0Ku01iHABsk5BusnokjQohLezDaO5rjP7bq7JeYbLuTqvfEOe1ebkXfbGtsc8skjkZeOu3KkANsYsbKNkAQQkTvvf9wkHUlLG9s8xinyLoSulgKhl0KPQlJSzi(mq1OLWPr1RPenBsDBqTBu(nudNeDCjLQLl45umDvUoLA7sKVdOoVQuRxsPW8vvTFflGKVscawdPjVajzQKI8wZRn6JJzs1JAbsYQgMKm5WLNnTHonDVb4SEcPT1NKarAQnKu9WfK1GE8qXQUU1OwGEizgdCLNKswpECmZiFLkqYxjbaRH0Kx(qYmg4kpjLSQHjjTY4rlLSoexZV3sAjpAPKargSDisg5RCscePP2qs1dxqwdYvsfW88yF4GKmmJKtQEiFLeaSgstE5djZyGR8K86a40P6jiBee1yBoodCvBLsw1WKK1dXMrZ(fhce7KSoexZV3s2HyZi0dhce7KeiYGTdrYiFLtsGin1gsQE4cYAqUsQaMNh7dhKKHzKCsvnKVscawdPjV8HKzmWvEss1UnxPsYRAkApgyutFVdguGBTLZ6y2xZwRzbZSgdWObcXM5rXiig6M95S))Z6kzDiUMFVLSuh4nKMKubmpp2hoijdZijDI9F2HQgMK0yagnqi2mVKvnmj5FebX1ngrqSyE4an7NT2MSWFqY6bWnsYAycqJby0aHyZ8G1sT2MaKQDBUsLKx1u0EmWOM(EhmOa3AlD8QwGXyagnqi2mpkgbXq3Z)FxjbI0uBiP6HliRb5kjqKbBhIKr(kNKLlOOLoXLiyIDcKKoX(QgMKuoPQMYxjbaRH0Kx(qYmg4kpjFnBTu8SGz2xZETMyNAjo44GkXAin5N1XS1qXZ()pR7SpNfmZ(A2R1e7uHBZrbumcQPO9yGnQeRH0KFwhZcYD2))zDN95SGz2sDG3qAs1yagnqi2m)SpLSoexZV3swQd8gstsQaMNh7dhKKHzKKoX(p7qvdtsAoQ1xb6veitbw7LSQHjj)JiiUUXicIfZdhOz)S12Kf(dZ(c0tjRha3ijRHjanh16Ra9kcKPaR9G1sT2Ma8vTumyEDTMyNAjo44GkXAin5Dudf))7(emVUwtStfUnhfqXiOMI2Jb2OsSgstEhGC))DFcMsDG3qAs1yagnqi2m)tjbI0uBiP6HliRb5kjqKbBhIKr(kNKLlOOLoXLiyIDcKKoX(QgMKuoPsXYxjbaRH0Kx(qYmg4kpjbPA9dfplyM91SxRj2PsSsKgRKZah1u0EmWgvI1qAYpRJzDvT(HIN9)Fw3zFkzDiUMFVLSuh4nKMKubmpp2hoijdZijDI9F2HQgMK0u4rrcD84ywRLSQHjj)JiiUUXicIfZdhOz)S12Kf(dZ(6XtjRha3ijRHjanfEuKqhpoM1AWAPwBtacs16hkgmVUwtStLyLinwjNboQPO9yGnQeRH0K3HRQ1pu8)V7tjbI0uBiP6HliRb5kjqKbBhIKr(kNKLlOOLoXLiyIDcKKoX(QgMKuoPQwYxjbaRH0Kx(qYmg4kpjVwtSt1t9vGIeWWOneUePsSgst(zDm71AIDQ(oyjQPO9yGvjwdPj)SoMTJhVeHsmcMtMzT6S1uY6qCn)ElzPoWBinjPcyEESpCqsgMrs6e7)SdvnmjP3uG6rAjRAysY)icIRBmIGyX8WbA2pBTnzH)WSVQXtjRha3ijRHja9Mcupsdwl1ABcWR1e7u9uFfOibmmAdHlrQeRH0K3X1AIDQ(oyjQPO9yGvjwdPjVJoE8sekXiyozSAnLeistTHKQhUGSgKRKargSDisg5RCswUGIw6exIGj2jqs6e7RAyss5KkRLVscawdPjV8HKzmWvEsETMyNQVdwIAkApgyvI1qAYpRJzFnRvmR5OwFfKxT16z))NfYgbr1ydDuaXgCs1w5SpN1XSq2iiQEQVcuKaggTHWLivBLZ6ywiBeevp1xbksadJ2q4sKAGGBoZmRvbCwxvqkwY6qCn)ElPPO9yGr9nlssQaMNh7dhKKHzKKoX(p7qvdtskzvdtsMfThd8SGLMfjjbI0uBiP6HliRb5kjqKbBhIKr(kNKLlOOLoXLiyIDcKKoX(QgMKuoPYkx(kjaynKM8YhswhIR53BjJTwJ2XJJzOAU5Kubmpp2hoijdZijDI9F2HQgMKuYQgMK8pIG46gJiiwSCR1ZwpECmBwWMBol8hKSEaCJKSgMauHjhU8SPn0PP7naNTmyXOqjbI0uBiP6HliRb5kjqKbBhIKr(kNKLlOOLoXLiyIDcKKoX(QgMKm5WLNnTHonDVb4SLblg5KkRK8vsaWAin5LpKmJbUYtsZrT(kiVAR1swhIR53Bjd2m0oECmdvZnNKkG55X(WbjzygjPtS)Zou1WKKsw1WKK)reex3yebXIazZMTE84y2SGn3Cw4piz9a4gjznmbOctoC5ztBOtt3BaoR5OwFfKxHscePP2qs1dxqwdYvsGid2oejJ8vojlxqrlDIlrWe7eijDI9vnmjzYHlpBAdDA6EdWznh16RG8YjvGCLVscawdPjV8HKzmWvEsEDaC6upomHEyupNMvrZwRzDmBGGBoZmRvNf8OFwhZgXWqyuLyo7mQr7qGy3SkcWzR5S1MZ(A2JdtZA1zb5oRJzbn7))SUZ(C2A7SpKSoexZV3sY4GxCq62tsQaMNh7dhKKHzKKoX(p7qvdtskzvdtswXbV4G0TNKeiYGTdrYiFLtsGin1gsQE4cYAqUsMfyGDI9CeofmYhswUGIw6exIGj2jqs6e7RAyss5KkqGKVscawdPjV8HKzmWvEsETMyNQVdwIAkApgyvI1qAYpRJzJyyimQsmNDgvpHWJ8Bwfb4SpMfmZ(AwiBeevtr7XaJcPBpzuTvoRJzbn7))SUZ(CwhZ(Awp(uzCWloiD7j1ab3CMzwfnBnNfmZ(A2R1e7un2qhfqSbNu5OeRH0KFwhZcA2))zDN95S))ZgXyThdmt1u0EmWO(Mfj1yrhaNmOiHoECmR1ZQiaNfKQvAwhZ(AwRywQ2T5kvsEvpX4TgfJGEfeArRraN3SZm7))ShhMMvrZcYD2NZ(uY6qCn)ElzS1A0oECmdvZnNKkG55X(WbjzygjPtS)Zou1WKKsw1WKK)reex3yebXILBTE26XJJzZc2CZzH)WSVa9uY6bWnsYAycqfMC4YZM2qNMU3aCwZrT(kMT1gfkjqKMAdjvpCbznixjbImy7qKmYx5KSCbfT0jUebtStGK0j2x1WKKjhU8SPn0PP7naN1CuRVIzBTroPc0d5RKaG1qAYlFizgdCLNKwXSxRj2P67GLOMI2JbwLynKM8Z6y2xZgXWqyuLyo7mQEcHh53SkcWzFmlyM91Sq2iiQMI2Jbgfs3EYOARCwhZcA2))zDN95S))ZgXyThdmt1u0EmWO(Mfj1yrhaNmOiHoECmR1ZQiaNfKQvAwWm7RzVwtStLyLinwjNboQPO9yGnQCuI1qAYpRJzbn7))SUZ(C2NswhIR53BjJTwJ2XJJzOAU5Kubmpp2hoijdZijDI9F2HQgMKuYQgMK8pIG46gJiiwSCR1ZwpECmBwWMBol8hM91JNswpaUrswdtaQWKdxE20g6009gGZAoQ1xXST2OqjbI0uBiP6HliRb5kjqKbBhIKr(kNKLlOOLoXLiyIDcKKoX(QgMKm5WLNnTHonDVb4SMJA9vmBRnYjvGQH8vsaWAin5LpKmJbUYtYiggcJQeZzNrnAhce7MvraoRINfmZwJzRTZ(A2xZczJGOEfekcpyoumc6vqOEQ9Q2kN1XSxRj2P2SJh5k7JJzQeRH0KF2NZ6ywqZ()pR7SpNfmZ(A2xZETMyNQNiLua1CH(AWjyvI1qAYpRJzTIzHSrqunfThdmkKU9Kr1w5SoM91SWn70eQ3o0hhZMfWzDN9)FwdDOqyMTr94u4HlAnvgNvrZ6o7ZzDm7RzTIzHSrquVccfHhmhkgb9kiup1EvBLZ()pBPoWBinP6nfOEKE2NZ(CwhZcA2))zDN95S))Z(A2iggcJQeZzNrnAhce7MvraoBnN1XSrmmegvjMZoJQNq4r(nRvbC2hZ6y2oE8sekXiyozMvraoBnM1XSD84LiuIrWCYmRvbC2Ao7Zz))N91SqyJzwhZEDaC6upomHEyupNSkGGM1XSrmmegvjMZoJA0oei2nRIaC2Am7tjRdX187TKXwRr74XXmun3CsQaMNh7dhKKHzKKoX(p7qvdtskzvdts(hrqCDJreelwU16zRhpoMnlyZnNf(dZ(QgpLSEaCJKSgMauHjhU8SPn0PP7naNfHZ4McfkjqKMAdjvpCbznixjbImy7qKmYx5KSCbfT0jUebtStGK0j2x1WKKjhU8SPn0PP7naNfHZ4Mc5Kkq1u(kjaynKM8YhsMXax5jjKncI6vqOi8G5qXiOxbH6P2Rgi4MZmZQOzbnRJzJyyimQsmNDg1ODiqSBwfb4S1ywhZ2XJxIqjgbZjZSwD2hZ6ywRywiBeevtr7XaJcozo7azuTvkzDiUMFVLm2AnAhpoMHQ5MtsfW88yF4GKmmJK0j2)zhQAyssjRAysY)icIRBmIGyXYTwpB94XXSzbBU5SWFy2x18PK1dGBKK1WeGkm5WLNnTHonDVb4SiCg3uOqjbI0uBiP6HliRb5kjqKbBhIKr(kNKLlOOLoXLiyIDcKKoX(QgMKm5WLNnTHonDVb4SiCg3uiNubsXYxjbaRH0Kx(qYmg4kpjl1bEdPjvVPa1J0Z6ywQ2T5kvsE1RGqr4bZHIrqVcc1tTFwhZ6XNkJdEXbPBpPgi4MZmZAvaN91Srmw7XaZunVHHWAdkgb1t9vOgi4MZmZcMzb5o7ZzDmBeJ1EmWmvZByiS2GIrq9uFfQbcU5mZSwfWzFmRJzJyyimQsmNDg1ODiqSBwfb4SpKSoexZV3sgBTgTJhhZq1CZjPcyEESpCqsgMrs6e7)SdvnmjPKvnmj5FebX1ngrqSy5wRNTE84y2SGn3Cw4pm7lf)uY6bWnsYAycqfMC4YZM2qNMU3aCweoJBkuOKarAQnKu9WfK1GCLeiYGTdrYiFLtYYfu0sN4semXobssNyFvdtsMC4YZM2qNMU3aCweoJBkKtQavl5RKaG1qAYlFizgdCLNKswhIR53BjJTwJ2XJJzOAU5Kubmpp2hoijdZijDI9F2HQgMKusGid2oejJ8vojRAysY)icIRBmIGyXYTwpB94XXSzbBU5SWFy2x16PK1dGBKK1WeGkm5WLNnTHonDVb4Sq2CTxHscePP2qs1dxqwdYvYSadStSNJWPGrGKSCbfT0jUebtStGK0j2x1WKKjhU8SPn0PP7naNfYMR9YjNKGfcPT1N8HCIa]] )

    storeDefault( [[SimC Subtlety: precombat]], 'actionLists', 20180108.000535, [[dSt1gaGEOuQnHQyxQKTHQYSj18LOBcPUlkIBJWJHyNO0Ev2nH9lLrjknmO63iDyHHcLcdwsdNk5GQGtjkoMO64qPQfsfAPuvTyeTCsEiQQEkLLHcRdkLmrOuzQurtwKPRQlsvXRGexgCDv0ZjARqsBgv2ouCEOKzHQutdkf9DQuNwQ(Mk0OLWZqr6Kuv6VuLRPs19OcETkLpJI6TOk5LpNZ8reKAinYzMlaPh6o2o(ovmwg8LpJniGzwNG)w1ojFn8yHTAvxkaHsqg)m)Ggcjmwg45hZzW4(foot5lNXmdr1D9ZMDa57uHCohB(CoZhrqQH0CCMHO6U(za2F2D5csxYIirD7jJhlL0ZDOV1Q80QzBv(AvuAvP0TNc4ofjpkhNe(wntRww2Q4Zoq219hRzycvpi1WmFfPos8u1mbvaZqttOgk2GaMjLU9ua3PinJniGzLiCC44iiCC8YEQcAvud9jWKs1SdkMLZebb4Gu62tbCNIeVXe6tWba7p7UCbPlzrKOU9KXJLs65o034jlFOiLU9ua3Pi5r54KWNPSeFMFqdHegld88J54Z8ds6PcbKZ5(z8xai3qtXaeG4h5m00eBqaZ2pwgZ5mFebPgsZXzgIQ76NLTv57ERIsRMTv)qdI)ctNzQ6Q7bIGudPwLNwLP3B1YYwfVvZ0QO0QzB1p0G4Vic5dkpkNNSisu3YRUhicsnKAvEA1C8wTSSvXB1mTkkTkMq1dsnCjLU9ua3Pi1QzMDGSR7pwZWeQEqQHz(ksDK4PQzcQaMHMMqnuSbbmt(qO)cVVqbYcQonJniGzLiCC44iiCC8YEQcAvud9jWKsvRMnpZSdkMLZebb4G8Hq)fEFHcKfuDI3yc9j4qw(UJs2p0G4VW0zMQUarqQHepm9EzjEguY(Hge)friFq5r58KfrI6wEbIGudjEYXllXZGcMq1dsnCjLU9ua3PiLzMFqdHegld88J54Z8ds6PcbKZ5(z8xai3qtXaeG4h5m00eBqaZ2pwMoNZ8reKAinhNziQURFw(1rg3BvuA1ST6hAq8xGadOPU6cM9KfrI6wE19arqQHuRYtRIFDKX9wTSSvXB1mZoq219hRzycvpi1WmFfPos8u1mbvaZqttOgk2GaMjlsECQa57urONXgeWSseooCCeeooEzpvbTkQH(eysPQvZYiZSdkMLZebb4GSi5XPcKVtfHM3yc9j4q(1rg3rj7hAq8xGadOPU6cM9KfrI6wEbIGudjEWVoY4EzjEMz(bnesySmWZpMJpZpiPNkeqoN7NXFbGCdnfdqaIFKZqttSbbmB)yXMZ5mFebPgsZXzhi76(J1m5dH(lM5Ri1rINQMjOcygAAc1qXgeWSzSbbmZEi0FXm)Ggcjmwg45hZXN5hK0tfciNZ9Z4VaqUHMIbiaXpYzOPj2GaMTFS3NZz(icsnKMJZoq219hRzeH6gK84OkVeeFXmFfPos8u1mbvaZqttOgk2GaMnJniGzOd1ni1QCuvRIDq8fZoOywoZLcqOeKX7q(m)Ggcjmwg45hZXN5hK0tfciNZ9Z4VaqUHMIbiaXpYzOPj2GaMTFS8nNZ8reKAinhNDGSR7pwZCr)ovmZxrQJepvntqfWm00eQHIniGzZydcywjchhoocchhVWg0VtfmPunZpOHqcJLbE(XC8z(bj9uHaY5C)m(laKBOPyacq8JCgAAIniGz73pd7aU4u)ZX9Ba]] )

    storeDefault( [[SimC Subtlety: stealth als]], 'actionLists', 20180108.000535, [[da02haqibWIicBsLWOGuDkiLvjHQxreLUfruSlvQHjPogGwMe8mbKPjHY1ik12ikPVPczDa08eqDpiP9jaDqIQfQs0dPsteiUOkuNKiYmbsDtb1oLOLcGNszQQK2kKWBbsUlKO9I8xjzWsDyLwmv8yctwvDzsBwiFwfmAH60q9AjKzd62qSBQ63OmCb64er1YvLNJQPl66QOTtu8Db58a16jkX8js7xXeq6kzh7xhO(jhYSGQaVqSSSjM5PYcYkqYkxeLmdJ4oTD6Kqnbd408uxygp9c5KbGc1LRuzHAGhbSqbzFxxhizfybYmXdhmjJm5IeZ8C6kvcKUs2X(1bQF6sYmXdhmjt967a47VgHf4C6aJ60YSp86a1BEQlmJRY4NYJzW)0sMPli7Pl(0Opn6thGPfmg8Zc5VpWEkYgIx5Gt9(m40xmDaM25mk6os1p2FOk6PEzb89zWPrB6lMg40sLoD90On9ftJ(0byAvYpXbdQ)BE8(zHQ4Bc(XRcTWIMwQ0Pfmg8Zc5V5X7NfQ6VEHElI33bLxf9wrIz(foDarDAz2hEDG6np(xf9wrIz(foTuPtRE9Da89xJWcCoDarDAG1tJgzYDWqCcMmXcHvRiXmFfeZtYKK)JfBYEK5zELSWSpk2x5IOKrw5IOKjvefvxlerrGYDHWPLlsmZpnOX8eLsFKj)DGtMFruuLWWiUtBNojutWaonp1fMXt7ccxcYaqH6YvQSqnWJawtgakND(ekNUsjzUXQOOWmzue1NKdzHz)YfrjZWiUtBNojutWaonp1fMXt7ccNsQSaDLSJ9Rdu)0LKzIhoysgY6tOw9pFBIz(Pd40fUdezYDWqCcMmXcHvRiXmFfeZtYKK)JfBYEK5zELSWSpk2x5IOKrw5IOKjvefvxlerrGYDHWPLlsmZpnOX8eLsFtJoq0it(7aNm)IOOkHHrCN2oDsOMGbCAEQlmJN2feUeKbGc1LRuzHAGhbSMmauo78juoDLsYCJvrrHzYOiQpjhYcZ(LlIsMHrCN2oDsOMGbCAEQlmJN2feoLuzGORKDSFDG6NUKmt8WbtYwrILrRuVIGv(0be1PlgzYDWqCcMmXcHvRiXmFfeZtYKK)JfBYEK5zELSWSpk2x5IOKrw5IOKjvefvxlerrGYDHWPLlsmZpnOX8eLsFtJEb0it(7aNm)IOOkHHrCN2oDsOMGbCAEQlmJN2feUeKbGc1LRuzHAGhbSMmauo78juoDLsYCJvrrHzYOiQpjhYcZ(LlIsMHrCN2oDsOMGbCAEQlmJN2feoLuzXORKDSFDG6NUKmt8WbtYqFAbJb)Sq(BE8(zHqu4)(m40xmDaMwWyWplK)wM1J5X3NbN(IPfmg8Zc5V5X7NfQ6VEHElI33bLpDGrDAGtJgzYDWqCcMmXcHvRiXmFfeZtYKK)JfBYEK5zELSWSpk2x5IOKrw5IOKjvefvxlerrGYDHWPLlsmZpnOX8eLsFtJEGqJm5VdCY8lIIQeggXDA70jHAcgWP5PUWmEAxq4sqgakuxUsLfQbEeWAYaq5SZNq50vkjZnwfffMjJIO(KCilm7xUikzggXDA70jHAcgWP5PUWmEAxq4usLYMUs2X(1bQF6sYmXdhmjl33bnVtmIwLSQpwNoWtdSW0fFAbJb)Sq(BE8(zHQ(RxO3I49Dq5vrVvKyMFHtx8PrFAGtlzNg9Pvj)ehmO(V5X7NfQIVj4hVk0clA6lMU(w2tlv601tJ20OrMChmeNGjtSqy1ksmZxbX8Kmj5)yXMShzEMxjlm7JI9vUikzKvUikzsfrr11crueOCxiCA5IeZ8tdAmprP030Oxm0it(7aNm)IOOkHHrCN2oDsOMGbCAEQlmJN2feUeKbGc1LRuzHAGhbSMmauo78juoDLsYCJvrrHzYOiQpjhYcZ(LlIsMHrCN2oDsOMGbCAEQlmJN2feoLusgiA0Ect6skjc]] )

    storeDefault( [[SimC Subtlety: CDs]], 'actionLists', 20180108.000535, [[dC0Xraqiss2Ki1NijfgfO4uGOvPaQxrcPzrsk6wka7cPgMI6yk0YaLEgGKPPaY1iHABks8nskJJKkCossjRJKuQ5PGCpa1(ejoOiPfss8qfutursxubAJKurFeqQCsaXkjPQBIK2jLmusQ0sbONkzQkITQi1BjjvUljPQ9I6ViAWchwQfJWJbAYeUm0MfXNbWOPuNMOxtcMTQCBv1Uj1Vvz4KOJdiLLtXZf10v66G02bHVJenEsiopsy9asvZhuTFQMh5jCnOUjEOGj4QuIGY(jb67vEA2c2PmYLv)rUk5FypkOe7dxkuT9y4PM5cq8HDgzlyNhvBewyvm98mqnLry5QansLlxCLk4kpDMNWwJ8eUgu3epuWQWvbAKkxUiGMKqt8Ut8GMxAOk9aoCpGXdIlN9iThBBaax6v(rY9ifs0JHa2JPm7bKEahUhW4bb0KeAiATmBtdvPhP9agpiGMKqNTBXrjjXRfyMgQspGd3dW7EIJsnD2UfhLKeVwGzAd(BPo7Xqa7bqn7bKEajxPsiFYLcUuER80CbeTqc27z4sFAKlQNy62y1FKlUS6pYfCWKK5zqWKevN6ER80QE4gUaeFyNr2c25r1gN5cqmFqnGyMNWlxdBJGkq9Ga)OEzcUOEcR(JCXlBblpHRb1nXdfSkCvGgPYLR8I9BTrbT5aakYvQeYNCPGlI3DcYeOgk4ciAHeS3ZWL(0ixupX0TXQ)ixCz1FKlvE3j8qDc1qbxaIpSZiBb78OAJZCbiMpOgqmZt4LRHTrqfOEqGFuVmbxupHv)rU4LTakEcxdQBIhkyv4QansLlx5f73AJcAZbauKRujKp5sbxeOjJgfKAa4ciAHeS3ZWL(0ixupX0TXQ)ixCz1FKlvqtgnki1aWfG4d7mYwWopQ24mxaI5dQbeZ8eE5AyBeubQhe4h1ltWf1ty1FKlEzRbINW1G6M4HcwfUkqJu5YvEX(T2OG2Caaf9iThOgnaqbTatKGY1Ju8qTzUsLq(KlfC1gWwJK7zmOE5ciAHeS3ZWL(0ixupX0TXQ)ixCz1FKRunGTg9yYzmOE5cq8HDgzlyNhvBCMlaX8b1aIzEcVCnSncQa1dc8J6Lj4I6jS6pYfVSLI5jCnOUjEOGvHRc0ivUCPkp2(H6LwG9AtMyUpztCqG0OUjEOGRujKp5sbxzk(e3ltEjKcSxBUaIwib79mCPpnYf1tmDBS6pYfxw9h5QO4tCVShxIhtf71MlaXh2zKTGDEuTXzUaeZhudiM5j8Y1W2iOcupiWpQxMGlQNWQ)ix8YwtHNW1G6M4HcwfUkqJu5YfmES9d1lTa71MmXCFYM4GaPrDt8qHhP9a8UN4OutlWETjtm3NSjoiqAd(BPo7Xqa7XOhP9WvpmEiULwlbWEjETaPn4VL6ShPaShG39ehLAAb2RnzI5(KnXbbsBWFl1zpuupakpGd3JTnaGl9k)i5EKcj6Xa8qClTwcG9s8AbsBWFl1zpgcypMIhq6rApC1dJhR8JEKcWEauEahUhzCjjon0m9krdSZKdKsqpsXJzpGd3deObvQujkOxBKmrAYl5LqU2iPaBHhq6bKEahUhU632aaU0R8JK7rkKOhdWdd(BPo7Xqa7X4mxPsiFYLcUYu8jUxM8sifyV2CbeTqc27z4sFAKlQNy62y1FKlUS6pYvrXN4EzpUepMk2RThWmcjxaIpSZiBb78OAJZCbiMpOgqmZt4LRHTrqfOEqGFuVmbxupHv)rU4LTuJNW1G6M4HcwfUkqJu5Y12gaWLELFKCpsHe9yipaVpXrQ8K6ntlWejOC5kvc5tUuW1VnkGcYKZqkWET5ciAHeS3ZWL(0ixupX0TXQ)ixCz1FKlQTrbu4rYz8yQyV2CbiMpOgqmZt4LlaXh2zKTGDEuTXzUk7JsQNqMirtMj4AyBeubQhe4h1ltWf1ty1FKlEzl1bpHRb1nXdfSkCvGgPYLlv5rEX(T2OGUFpps7b49josLNuVzAbMibLRhPaShGkj)TIqMvIAbxPsiFYLcU(TrbuqMCgsb2RnxarlKG9EgU0Ng5I6jMUnw9h5IlR(JCrTnkGcpsoJhtf712dygHKlaXh2zKTGDEuTXzUaeZhudiM5j8Y1W2iOcupiWpQxMGlQNWQ)ix8YwQw8eUgu3epuWQWvbAKkxUGXJv(rpsXJXzps7b49josLNuVzAbMibLRhPaShW6HI6bmEKxSFRnkO73ZJ0Em6bC4Em7bKEmapGXdeObvQujkO)TEFi5LqU2i5VZlAi7CUZzP2J0Em6bC4Em7bKEaPhWH7HREy8yLF0JH8yC2J0EaJhQYJTFOEP)TrbuqMCgsb2RnnQBIhk8aoCpaVpXrQ8K6ntlWejOC9ifG9aO8aoCpe3sRLayVeVwG0ReubPgapG0di5kvc5tUuWv2UfhLKeVwGzUaIwib79mCPpnYf1tmDBS6pYfxw9h5QSBXrPhQ8AbM5cq8HDgzlyNhvBCMlaX8b1aIzEcVCnSncQa1dc8J6Lj4I6jS6pYfVS14mpHRb1nXdfSkCvGgPYLlv5rEX(T2OGUFpps7HREW7EIJsnD2UfhLKIwdI0G2TbamtMyAWvE6(5Xqa7beTr2epKoBlitmn4kpD)8iThU6HXdy8a8(ehPYtQ3mTatKGY1Jua2JbYJb4bmESYp6XqEmo7rApG1d4W9y2di9iThU69Wdp8a1ObakOfyIeuUEKIhkE2df1dy8y7hQxAiKaCgAu3epu4rApg9aoCpM9aspgypGvXEmapGXJv(rpsbypgN9iThJk2d4W9y2di9aspGd3dx9W4b49josLNuVzAbMibLRhPaShJEK2JTnaGl9k)i5EKcj6XqEOo8aspGKRujKp5sbxaCg83uMjjKlYfq0cjyVNHl9PrUOEIPBJv)rU4YQ)ixaDNb)nLQgzpurUixaIpSZiBb78OAJZCbiMpOgqmZt4LRHTrqfOEqGFuVmbxupHv)rU4LTgh5jCnOUjEOGvHRc0ivUCXvQeYNCPGlL39iny(GAarUg2gbvG6bb(r9YeCbeTqc27z4sFAKl19U3GkYAA2AMlQNy62y1FKlUu37EQZZyHkYYQWLv)rUGdMKmpdcMKO6u37EEaiMpOgqu1d3WvQgaYCLCgsnQilWJQMOISMMS)hu9cSIv8aGz7hQx6SDlokjtoqOzAu3epuKEeo8zih4XzUaeFyNr2c25r1gN5cqmFqnGyMNWlxL9rj1titKOjZQWf1ty1FKlEzRry5jCnOUjEOGvHRc0ivUCHA0aaf0GqnguVEKcWEOyf7Xa8agp2(H6LoB3IJsYKdeAMwsI6M4Hcps7XOhWH7XShq6Xa7X4ShP9aI2iBIhslY2KIK2J0EaJhQYdeObvQujkO)TEFi5LqU2i5VZlAi7CUZzP2d4W9GaAscDMIpX9YKxcPa71MgQspG0J0EaE3tCuQPZ2T4OKu0AqKg0UnaGzYetdUYt3ppgcypGOnYM4H0zBbzIPbx5P7NhP9qvEqanjHoB3IJssrRbrAOk9iThQYdcOjj05f73AtdvPhP94369HKcOMELN2dG9y2J0EaJhIBP1saSxIxlqAd(BPo7rka7b4DpXrPMwG9AtMyUpztCqG0g83sD2df1JP4rApuLhW4bb0Ke61gjtKM8sEjKRnskWwqBWFl1zpsXJrps7b49josLNuVzAqOgdQxpsbypuShq6bC4ESTbaCPx5hj3JuirpgGhIBP1saSxIxlqAd(BPo7Xqa7Xu8asps7b4DpXrPMwG9AtMyUpztCqG0g83sD2JHa2JrpGd3JTnaGl9k)i5EKcj6Xqa7HACLkH8jxk4cIwlZ2CbeTqc27z4sFAKlQNy62y1FKlUS6pY10TwMT5cq8HDgzlyNhvBCMlaX8b1aIzEcVCnSncQa1dc8J6Lj4I6jS6pYfVS1iqXt4AqDt8qbRcxfOrQC5svEqanjHoB3IJssrRbrAOk9iThBBaax6v(rY9ifs0JHa2JbYdf1dy8y7hQx6muIfnjqbaPLKOUjEOWJ0Em6bC4Em7bKCLkH8jxk4kB3IJssrRbrUaIwib79mCPpnYf1tmDBS6pYfxw9h5QSBXrPhtT1GixaIpSZiBb78OAJZCbiMpOgqmZt4LRHTrqfOEqGFuVmbxupHv)rU4LxUMkM0qFlRcVmd]] )

    storeDefault( [[SimC Subtlety: finish]], 'actionLists', 20180108.000535, [[dWJfjaGEuvL2eLYUazBIsSpvLmBPA(I0nvLCyj3wPwMOyNkQ9kSBsTFOrrrnmk43KSofr15Pqdgz4IOdkk1POihtv15qvvSqfjlfvLfRWYLYdvvQvPQqpgvEovMiQQQPQk1KPQPRYfvK6vkICzIRlQonkBvusBguBxe(SQW3rvAAQkAEuQ8mfr5qQIgnL8AkvDsufDlvfCnuv5Ekc)vjFdvHNcC8hVdW06A0fFmcaiPWXQoJ)whtPJ5mz5paZ1wcaGT)gjq(46YzCYrcMPzoRaWN0LYjXCgd)84ptg(bzWWKLL)mbaW1yjVaeGS5oMs7I3X8F8oatRRrx8XubaW1yjVaygPNiDvx0hKVA2VCwLxXlKORrx8iLMI0tKg5WWqoRYR4D5lnNaLNejtizdPRApKd6yBzDQLNji9bKAYUyAhsFHuwqYgsMrAx6RllFERoMsJ0eizaP0uKAYUyAhs2nbs7sFDz5ZB1XuAKmHKnKmJKzKAcCtCw1OlizdjZi9ejyMU6SZisPPinYHHHGz6QZoJln7H1n6LxGYtIuAksjQgRgDbY7SwE4cjtizcP0uKAYUyAhs2H0X4SFDSTG0hrkdsMqYgsMrQ4owczjAzZehs2H0NizdPNiLOASA0fiVZA5HlKstr6jsJCyyiNX9q1Dlf8Yl1zbLNejtbi7bRZoJbqZEyDJE5LaWtTNXvNQfaTslb4LYN1QnxBjabyU2saMzpSUrV8sa4t6s5KyoJHFE8Bia8jovEJtCX74cW3wcN9VujKTOVyeGxk)CTLaexmNjEhGP11Ol(yQaa4ASKxamJ0tKUQl6dYl1zTGBQ9QgQecKORrx8iLMIKtU1qPZDqhtA)8NvMKCi9fsgqYes2qYmspr6QUOpiF1SF5SkVIxirxJU4rknfPNinYHHHCwLxX7YxAobkpjsMqYgsx1Eih0X2Y6ulptq6di1KDX0oK(cP)mizdPDPVUS85T6yknstGKbKSHKzKmJutGBIZQgDbjBizgPNibZ0vNDgrknfPrommemtxD2zCPzpSUrV8cuEsKstrkr1y1OlqEN1YdxizcjtiLMIut2ft7qYoKogN9RJTfK(iszqYes2qYmsf3XsilrlBM4qYoK(ejBi9ePevJvJUa5DwlpCHuAksprAKddd5mUhQUBPGxEPolO8KizkazpyD2zmaA2dRB0lVeGVTeo7FPsiBrFXiaVu(SwT5Albia8u7zC1PAbqR0saMRTeGz2dRB0lVGK5Ftbi72dxa4mY1L1vThY5M4pa8jDPCsmNXWpp(nea(eNkVXjU4DCb4BJCD5D1EiNlMkaVu(5AlbiUyEYI3byADn6IpMkaaUgl5fGMSlM2HKDiXPuDVIxnKZ4EO6ULcE5L6SGAYUyAhstcPFdizdjoLQ7v8QHCg3dv3TuWlVuNfut2ft7qYUjqIFinjKmJKzK4u7HALuX0NdIlV1e9H0eiLfKmHKnK(rknfjdizcjBiDv7HCqhBlRtT8mbPpGut2ft7q6lK4uQUxXRgYzCpuD3sbV8sDwqnzxmTdPjHe)cq2dwNDgdGM9W6g9YlbGNApJRovlaALwcWlLpRvBU2sacWCTLamZEyDJE5fKmNXua4tCQ8gN4I3Xfa(KUuojMZy4Nh)gcaWsX7lLNbZKMlgb4BlHZ(xQeYw0xmcWlLFU2saIlM)mEhGP11Ol(yQamxBja8VuNfsWn1gPShQesa4tCQ8gN4I3XfGShSo7mgaVuN1cUP2RAOsibGNApJRovlaALwcaFsxkNeZzm8ZJFdbaW1yjVa8ePR6I(G8vZ(LZQ8kEHeDn6IhP0uKmJ0tKg5WWqoRYR4D5lnNaLNeP0uKkUJLqwIw2mXH0xtG0NizcjBizgPrommKZ4EO6ULcE5L6SGYtIuAksCkv3R4vd5mUhQUBPGxEPolOMSlM2H0xtG0VbKMeso5wdLo3bDmPLXW6ZKCi9rK4hsMqYgsJCyyOZswWSM7wk41zjlVuEOMSlM2HKDi9JKnKmJ0ihggcMPRo7mUKemhN0QtGYtIuAksf3XsilrlBM4qYoK(ejtXfZ8lEhGP11Ol(yQaK9G1zNXaijyooPvNeaEQ9mU6uTaOvAjaVu(SwT5AlbiaZ1wcW0jyooPvNea(KUuojMZy4Nh)gcaFItL34ex8oUa8TLWz)lvczl6lgb4LYpxBjaXfxa4FbUY7xmvCra]] )

    storeDefault( [[SimC Subtlety: build]], 'actionLists', 20180108.000535, [[d0ZFfaGEvjQnjve7IiBdrAFQsQdR0SLY8vLKBkuUlvKBRONlyNuP9cTBQA)IgfvyyuKFt4Xe15PWGLmCPshui5uushtv1Pr1crelvvSyuSCKEOQuEkPLrjwNur1evLGPQQmzfMUkxui6zOeUm46iQVrf1wrjAZOK2UuvFuvc9zuQPjvu(UuH)sPwKq1Ory8cHtQkv3si11OOCpvjYkLksVLIQxlvz8h)qns)Y0GbYG6laSUKBhscQQmL39qfv3DcOQ85BzPKzUgCgDEwmK5TbQpqd2aGUwm978VflMjzYeli93cQpWom(4tavWdu2gMNv8Jpb7tyhpljPSCKf4bkBdP5grwrNLJS6Vu(Y0aPWbB7iSpckeieTrwcAwKAwwwZYAwoHAuYhx4d4h6(JFOgPFzAWajbvvMY7EOUYhVpydEyYHqwV(LYYrwmKzLvPJaSzLtdNTGv7JaShWoKi3nRojlwK1REvwwYYkQDqa(hyhgOgKP8UhQV7hC59euu9cpGAum8g)mqnqqMY7bE7WjOtuJjgSCPU7eqf13ia5EXe9Hj4pKbv3DcOQeKP8EGpl9e0jQkHOJyIbNvoqdijO(anyda6AX0VZ)Mq9bccYuziGF4H6dSdJp(eqf8aLTH5zf)4tW(e2XZssklhzbEGY2qAUrKv0z5iR(lLVmnqkCW2oc7JGcbcrBKLGMfPMLL1SSMLtOgtmC3jGkEORf8d1i9ltdgijOQYuE3d1BPSHtAWd36LHSEDw)MYof1Oy4n(zGAGGmL3d82Nieq9D)GlVNGIQx4buD3jGQsqMY7b(S(eHaQpqd2aGUwm978VjuFGDy8XNaQGhOSnmpR4hFc2NWoEwssz5ilWdu2gsZnISIolhz1FP8LPbsHd22ryFeuiqiAJSe0Si1SSSML1SCc1hiiitLHa(HhQDqa(hyhgOgKP8UhEOllWpuJ0VmnyGKGAheG)b2HbQbzkV7H67(bxEpbfvVWdOgtmy5sD3jGkQrXWB8Zav2nHyY02bGQ7obuFXMqmzA7aq9ncqUxmrFyc(dzq9bAWga01IPFN)nH6deeKPYqa)Wd1hyhgF8jGk4bkBdZZk(XNG9jSJNLKuwoYc8aLTH0CJiROZYrw9xkFzAGu4GTDe2hbfceI2ilbnlsnllRzznlNqnMy4Utav8q3od)qns)Y0GbscQDqa(hyhgOgKP8UhQV7hC59euu9cpGAmXGLl1DNaQOgfdVXpduzw5EHBzq1DNaQKSY9c3YG6BeGCVyI(We8hYG6d0GnaORft)o)Bc1hiiitLHa(HhQpWom(4tavWdu2gMNv8Jpb7tyhpljPSCKf4bkBdP5grwrNLJS6Vu(Y0aPWbB7iSpckeieTrwcAwKAwwwZYAwoHAmXWDNaQ4HhQAxqMVn(lVhx4rxlK(JhIa]] )


    storeDefault( [[Subtlety Primary]], 'displays', 20180108.000535, [[dSJ2gaGEf4LOkAxGq12GQsZKQQMTuDtufoSKVbIIxdc2jL2Ry3eTFc6NkYWaPFd5zGOAOOyWey4iCqP0NHkhJuDCuLwOuSusrlgjlNkpKQYtv9yuzDKczIGqMkuMmQQPR0fvORsk4YaxhuBKuARGqzZeA7iQpsvLttY0arPVtvgjuvTmf0OrQXdv5KiYTGQIRbICEu65uSwsH62kQJEWY5kIvHKArY9lBhKpPbm)jzhZ3YHdSmKzcvURK4a(ObCqin5uD1Gb(1rEHkNDsu0awFfXQqstSqZXBsu0awFfXQqstSqZ5fgad4tIdjVAaiwibnFwjBhJfYZ5fgad47RiwfsAsto7KOObSyLdhynXcn3qJ8UNA5OBhttUHg51cVO0Kpx4DSy1Z3YHdSTsoAKlVzcdBIhAsYp8JLZgl(muhAUisU5mycf8sAekWwohYl3qJ8WkhoWAstoeOALC0ixo2eJMK8d)y5kjFfxTixRKJg5Y1KKF4hlNRiwfs2k5OrU8MjmSjEK7drWkuagk)WuBhSScf0onMBOrEhln58cdGbqKYb4wfsMRjj)WpwUeEMehsAIfYMBia9U2EzO9H6ixWYRy1ZPIvphxS65Uy1ZMBOrE(kIvHKMqLJ3KOObSTWUkwO5fSRWyja5uWII5ZfETWlkwO5uD1Gb(1rET9EOYRobDDAKhd5Xy1ZRobD5dntvld5Xy1ZHiGyb330KxDVI1WqMjn5KvgfLQRwwmwcqovoxrSkKSTRWjZ9nAXg1mNVYq0lwmwcqEL7kjoaglbiVOuD1YMxWUIhkjin5qGslsUxnaeR(W8QtqxyLdhyziZeREUd0Z9nAXg1m3qa6DT9YqhQ8QtqxyLdhyzipgREoVWayaFss(kUArotAYpbGtvD1GAvizSdXx98zLSfErXcnFlhoWQfj3VSDq(KgW8NKDmNpqSG7BlJ)5xn7tOGdtTDWYQrcfWhiwW9nhVjrrdy5zJjw9C2jrrdy5zJjw8rpV6e0vB3RynmKzIvpxXHKAmcnhRoKYjCQ5YXQfj3RgaIvFyoHdWHMPQTLX)8RM9juWHP2oyz1iHciCao0mvT5koK8efNsIlwiLpx41ogl0CcNAUCSK4qYRgaIfsqZ3YHdSmKhdvoVWayqBxHtodKBoxUMGoOmGyhcvhYOpCiKG4qHc54R(WC8MefnGLKKVIRwKZel0C2jrrdyjj5R4Qf5mXcnFlhoWQfj3CgmHcEjncfylNd5LJ3KOObSyLdhynXcn3qJ8AHDfjPiku5gAKhjjFfxTiNjn5StIIgW2c7QyHMxDVI1WqEmn5gAKhd5X0KBOrETJPjNdntvldzMqLxWU6eGENeefl08c2vTsoAKlVzcdBIh(pQflVGDfjPicJLaKtblkMpRKhlwO5B5WbwTi5E1aqS6dZ5fwXbbiMY8LTdYRCUIyviPwKCZzWek4L0iuGTCoKxE1jOlFOzQAziZeRE(OSO6a(Pj3OMj6G2PXyhMdbkTi5MZGjuWlPrOaB5CiV8QtqxTDVI1WqEmw9CUIyviPwKCVAaiw9H5COzQAzipgQCdnYJNawkLKVsIZKMCdnYJHmtAYXlwO5gAK39ulhDl8IstE1jORtJ8yiZeREoVWayaFTi5E1aqS6dZHaLwKC)Y2b5tAaZFs2XCEHbWa(8SXKMCBndYpm12blRqbmo1C5yZlyxPbPAZj6flWLnb]] )

    storeDefault( [[Subtlety AOE]], 'displays', 20180108.000535, [[dSJ1gaGEjQxIsyxGi12ifYmLiMTKUjkrhwQVbIKxlrANuAVIDt0(jWpvOHbs)gYZar1qrvdgLA4i6GuPLbchJuDCuslurwkvWIb1YPQhsf9uvpgPwhcfteeXuHQjtqtxPlQGRIq1LbUou2iP0wbrXMj02rsFKk0Pj5Zi47syKKcMgiknAumEeYjrIBHqPRrk68OYZPyTKc1Tvuh9GNt3KRcj1IK7xUkiFK44LqXoKVTNay5PYh4CFljaCYaOlnt5SIbWaUvfb5mqU505CJIIgW6SjxfsAIfAorJIIgW6SjxfsAIfAoPxn3Eok0i5vLbXQj08zL0DiwipNvmagqOZMCviPjt5CJIIgWI3EcG1el0CddQ4fQLMXDiW5gguHl2IcC(Ct0XJvpFBpbW6kPzq(8PrC8rw6afh1aEorJIIgWYIjtS65CJIIgWYIjtSeREUHbvG3EcG1KP8sHDL0miFo(iVduCud45kPqfDViVRKMb5ZDGIJAapNUjxfs6kPzq(8PrC8rwM7erYjGnok)yWBfSCcy7ooKByqfhpt5SIbWaqIYdOxfsM7afh1aEUeBMcnsAIfYMBib1Q2AByCIQiFWZ7y1Z9XQNtiw9C4y1ZMByqfoBYvHKMaNt0OOObSUy(owO5nMVX5ib5WyII5ZnrUylkwO5Wvv5YowrfU1AGZ7kjtFgubp1Hy1Z7kjt7end3lp1Hy1ZHeGyJv3aN31IMZWtLpt5uvgfSQQwoCosqoCoDtUkK0TQiiZDoyXhCixOYqwBoCosqoDUVLea4CKG8gwvvlxEJ5BwQKGmLxkSwKCVQmiwDiY7kjtJ3EcGLNkFS65Eqn35GfFWHCdjOw1wBdtGZ7kjtJ3EcGLN6qS65SIbWacPifQO7f5nzk)KaAvxvL7vHKXcHgPNB7zq(XG3ky5eW2DCiFBpbWQfj3VCvq(iXXlHIDixiqSXQRlFj5xn7ua7JbVvWYrmcylei2y1nVuyTi5(LRcYhjoEjuSd5CXsS6AQzExjzA3ArZz4PYhREExjz6ZGk4PYhREoPxn3EoTi5EvzqS6qKt6b0Oz4ED5lj)QzNcyFm4TcwoIraBspGgnd3BUHbv8c1sZ4ITOmLp3e5oel0CIIfA(2EcGLN6qGZnmOcEQ8zk3bqf0gqSqavhsPdbeAcPHcfY1iDiYnmOcwa4GvsHkjbtMYPrZW9YtDiW50n5QqsTi5EvzqS6qK3vsM2Tw0CgEQdXQNxkSwKCZ5XfW(T0iGTT9EurUHbvqrkur3lYBYuo3OOObSUy(owO5DTO5m8uhYuUHbv4oe4CddQGN6qMYPrZW9YtLpW5DLKPDIMH7LNkFS65nMVDL0miF(0io(illzqlEoRyk6sHmkZxUkihoFwjpESqZ32taSArY9QYGy1HiVX8nfPicNJeKdJjkMt3KRcj1IKBopUa2VLgbSTT3JkYBmFFsqTsbsIfA(GSHRaHzk3OMjRa3XHyHi3WGkCX8nfPikW5enkkAalE7jawtSqZ32taSArYnNhxa73sJa2227rf5CJIIgWsrkur3lYBIfAorJIIgWsrkur3lYBIfAoCvvUSJvurGZzfdGbesHgjVQmiwnHMROrYt20kjHy1mxrJKAmcnhRUM5SIbWac1IK7vLbXQdrUisU584cy)wAeW22EpQiNvmagqilMmzkFwjDXwuSqZBmFtCPAZjRnhWNnba]] )


end

