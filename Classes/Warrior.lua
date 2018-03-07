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

local setRegenModel = ns.setRegenModel

local addSetting = ns.addSetting
local addToggle = ns.addToggle

local registerCustomVariable = ns.registerCustomVariable
local registerInterrupt = ns.registerInterrupt

local removeResource = ns.removeResource

local setArtifact = ns.setArtifact
local setClass = ns.setClass
local setPotion = ns.setPotion
local setRole = ns.setRole
local setTalentLegendary = ns.setTalentLegendary


local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent

local storeDefault = ns.storeDefault


local PTR = ns.PTR or false

if (select(2, UnitClass('player')) == 'WARRIOR') then

    ns.initializeClassModule = function ()
    
        setClass( "WARRIOR" )

        setPotion( 'old_war' ) 
        -- Resources
        --addResource( "rage", nil, false )
        addResource( "rage", SPELL_POWER_RAGE, true )


        -- According to SimC 7.3.5:
        -- Base Rage Generation = 1.75
        -- Arms Rage Multiplier = 4.286
        -- Fury Rage Multiplier = 0.80

        local base_rage_gen, arms_rage_mult, fury_rage_mult = 1.75, 4.286, 0.80
        local offhand_mod = 0.80
        

        setRegenModel( {
            mainhand_arms = {
                resource = 'rage',
                spec = 'arms',
                setting = 'forecast_fury',
                

                last = function ()
                    local swing = state.combat == 0 and state.now or state.swings.mainhand
                    local t = state.query_time

                    return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
                end,

                interval = 'mainhand_speed',

                value = function ()
                    return base_rage_gen * arms_rage_mult * state.swings.mainhand_speed
                end,
            },


            mainhand_fury = {
                resource = 'rage',
                spec = 'fury',
                setting = 'forecast_fury',

                last = function ()
                    local swing = state.swings.mainhand
                    local t = state.query_time

                    return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
                end,

                interval = 'mainhand_speed',

                stop = function () return state.time == 0 end,
                
                value = function ()
                    return base_rage_gen * fury_rage_mult * state.swings.mainhand_speed
                end,
            },

            offhand_fury = {
                resource = 'rage',
                spec = 'fury',
                setting = 'forecast_fury',

                last = function ()
                    local swing = state.swings.offhand
                    local t = state.query_time

                    return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
                end,

                interval = 'offhand_speed',

                stop = function () return state.time == 0 end,
                
                value = function ()
                    return base_rage_gen * fury_rage_mult * state.swings.mainhand_speed * offhand_mod * ( state.talent.endless_rage.enabled and 1.3 or 1 )
                end,
            }
        } )
        
 -- Talents
 
         --[[ Anger Management: Every 20 Rage you spend reduces the remaining cooldown on Battle Cry and Bladestorm by 1 sec. ]]
        addTalent( "anger_management", 152278 ) -- 21204
        
        --[[ Avatar: Transform into a colossus for 20 sec, causing you to deal 20% increased damage and removing all roots and snares. ]]
        addTalent( "avatar", 107574 ) -- 19138

        --[[ Bladestorm: Become an unstoppable storm of destructive force, striking all targets within 8 yards with both weapons for 67,964 Physical damage over 5.6 sec.    You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks. ]]
        addTalent( "bladestorm", 46924 ) -- 22405

        --[[ Bloodbath: For 10 sec, your melee attacks and abilities cause the target to bleed for 40% additional damage over 6 sec. ]]
        addTalent( "bloodbath", 12292 ) -- 22395

        --[[ Bounding Stride: Reduces the cooldown on Heroic Leap by 15 sec, and Heroic Leap now also increases your run speed by 70% for 3 sec. ]]
        addTalent( "bounding_stride", 202163 ) -- 22627

        --[[ Carnage: Reduces the cost of Rampage by 15 Rage. ]]
        addTalent( "carnage", 202922 ) -- 19140

        --[[ Dauntless: Your abilities cost 10% less Rage. ]]
        addTalent( "dauntless", 202297 ) -- 22624

        --[[ Deadly Calm: Battle Cry also reduces the Rage cost of your abilities by 75% for the duration. ]]
        addTalent( "deadly_calm", 227266 ) -- 22394

        --[[ Defensive Stance: A defensive combat state that reduces all damage you take by 20%, and all damage you deal by 10%. Lasts until cancelled. ]]
        addTalent( "defensive_stance", 197690 ) -- 22628

        --[[ Double Time: Increases the maximum number of charges on Charge by 1, and reduces its cooldown by 3 sec. ]]
        addTalent( "double_time", 103827 ) -- 22409

        --[[ Dragon Roar: Roar explosively, dealing 6,498 damage to all enemies within 8 yards and increasing all damage you deal by 16% for 6 sec. Dragon Roar ignores all armor and always critically strikes. ]]
        addTalent( "dragon_roar", 118000 ) -- 16037

        --[[ Endless Rage: Your auto attack generates 30% additional Rage. ]]
        addTalent( "endless_rage", 202296 ) -- 22633

        --[[ Fervor of Battle: Whirlwind deals 80% increased damage to your primary target.  ]]
        addTalent( "fervor_of_battle", 202316 ) -- 22383
        
        --[[ Focused Rage: Focus your rage on your next Mortal Strike, increasing its damage by 30%, stacking up to 3 times. Unaffected by the global cooldown. ]]
        addTalent( "focused_rage", 207982 ) -- 22399

        --[[ Frenzy: Furious Slash increases your Haste by 5% for 10 sec, stacking up to 3 times. ]]
        addTalent( "frenzy", 206313 ) -- 22544

        --[[ Fresh Meat: Bloodthirst has a 60% increased critical strike chance against targets above 80% health. ]]
        addTalent( "fresh_meat", 215568 ) -- 22491

        --[[ Frothing Berserker: When you reach 100 Rage, your damage is increased by 15% and your movement speed by 30% for 6 sec. ]]
        addTalent( "frothing_berserker", 215571 ) -- 22391

        --[[ Furious Charge: Charge also increases the healing from your next Bloodthirst by 300%. ]]
        addTalent( "furious_charge", 202224 ) -- 22635

        --[[ In For The Kill: Colossus Smash grants you 10% Haste for 8 sec. ]]
        addTalent( "in_for_the_kill", 248621 ) -- 22397

        --[[ Inner Rage: Raging Blow no longer requires Enrage and deals 150% increased damage, but has a 4.5 sec cooldown. ]]
        addTalent( "inner_rage", 215573 ) -- 22400

        --[[ Massacre: Execute critical strikes reduce the Rage cost of your next Rampage by 100%. ]]
        addTalent( "massacre", 206315 ) -- 22384
        
        --[[ Mortal Combo: Mortal Strike now has a maximum of 2 charges. ]]
        addTalent( "mortal_combo", 202593 ) -- 22393

        --[[ Opportunity Strikes: Your melee abilities have up to a 60% chance, based on the target's missing health, to trigger an extra attack that deals 23,354 Physical damage and generates 5 Rage. ]]
        addTalent( "opportunity_strikes", 203179 ) -- 22407
      
        --[[ Outburst: Berserker Rage now causes Enrage, and its cooldown is reduced by 15 sec. ]]
        addTalent( "outburst", 206320 ) -- 22381

        --[[ Overpower: Overpowers the enemy, causing 54,736 Physical damage. Cannot be blocked, dodged or parried, and has a 60% increased chance to critically strike.    Your other melee abilities have a chance to activate Overpower. ]]
        addTalent( "overpower", 7384 ) -- 22360

        --[[ Ravager: Throws a whirling weapon at the target location that inflicts 260,141 damage to all enemies within 8 yards over 6.3 sec.     Generates 7 Rage each time it deals damage. ]]
        addTalent( "ravager", 152277 ) -- 21667

        --[[ Rend: Wounds the target, causing 21,894 Physical damage instantly and an additional 110,116 Bleed damage over 8 sec. ]]
        addTalent( "rend", 772 ) -- 22489

        --[[ Reckless Abandon: Battle Cry lasts 2 sec longer and generates 100 Rage. ]]
        addTalent( "reckless_abandon", 202751 ) -- 22402

        --[[ Second Wind: Restores 6% health every 1 sec when you have not taken damage for 5 sec. ]]
        addTalent( "second_wind", 29838 ) -- 15757        
        
        --[[ Shockwave: Sends a wave of force in a frontal cone, causing 1,905 damage and stunning all enemies within 10 yards for 3 sec.  Cooldown reduced by 20 sec if it strikes at least 3 targets. ]]
        addTalent( "shockwave", 46968 ) -- 22374

        --[[ Storm Bolt: Hurls your weapon at an enemy, causing 4,011 Physical damage and stunning for 4 sec. ]]
        addTalent( "storm_bolt", 107570 ) -- 22372

        --[[ Sweeping Strikes: Mortal Strike and Execute hit 2 additional nearby targets. ]]
        addTalent( "sweeping_strikes", 202161 ) -- 22371

        --[[ Titanic Might: Increases the duration of Colossus Smash by 8 sec, and reduces its cooldown by 8 sec. ]]
        addTalent( "titanic_might", 202612 ) -- 22800

        --[[ Trauma: Slam, Whirlwind, and Execute now cause the target to bleed for 20% additional damage over 6 sec. Multiple uses accumulate increased damage. ]]
        addTalent( "trauma", 215538 ) -- 22380
        
        --[[ War Machine: Killing a target grants you 30% Haste and 30% movement speed for 15 sec. ]]
        addTalent( "war_machine", 215556 ) -- 22632

        --[[ Warpaint: You now take only 15% increased damage from Enrage. ]]
        addTalent( "warpaint", 208154 ) -- 22382

        --[[ Wrecking Ball: Your attacks have a chance to make your next Whirlwind deal 250% increased damage. ]]
        addTalent( "wrecking_ball", 215569 ) -- 22379


        -- Traits
        addTrait( "battle_scars", 200857 )
        addTrait( "bloodcraze", 200859 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "death_and_glory", 238148 )
        addTrait( "deathdealer", 200846 )
        addTrait( "focus_in_chaos", 200871 )
        addTrait( "fury_of_the_valarjar", 241269 )
        addTrait( "helyas_wrath", 200870 )
        addTrait( "juggernaut", 200875 )
        addTrait( "oathblood", 238112 )
        addTrait( "odyns_champion", 200872 )
        addTrait( "odyns_fury", 205545 )
        addTrait( "pulse_of_battle", 238076 )
        addTrait( "rage_of_the_valarjar", 200845 )
        addTrait( "raging_berserker", 200861 )
        addTrait( "sense_death", 200863 )
        addTrait( "thirst_for_battle", 200847 )
        addTrait( "titanic_power", 214938 )
        addTrait( "uncontrolled_rage", 200856 )
        addTrait( "unrivaled_strength", 200860 )
        addTrait( "unstoppable", 200853 )
        addTrait( "wild_slashes", 216273 )
        addTrait( "wrath_and_fury", 200849 )

         -- Traits Arms
        addTrait( "arms_of_the_valarjar", 241264 )
        addTrait( "colossus_smash", 208086 )
        addTrait( "corrupted_blood_of_zakajz", 209566 )
        addTrait( "crushing_blows", 209472 )
        addTrait( "deathblow", 209481 )
        addTrait( "defensive_measures", 209559 )
        addTrait( "executioners_precision", 238147 )
        addTrait( "exploit_the_weakness", 209494 )
        addTrait( "focus_in_battle", 209554 )
        addTrait( "many_will_fall", 216274 )
        addTrait( "one_against_many", 209462 )
        addTrait( "precise_strikes", 248579 )
        addTrait( "shattered_defenses", 248580 )
        addTrait( "soul_of_the_slaughter", 238111 )
        addTrait( "storm_of_swords", 238075 )
        addTrait( "tactical_advance", 209483 )
        addTrait( "thoradins_might", 209480 )
        addTrait( "touch_of_zakajz", 209541 )
        addTrait( "unbreakable_steel", 214937 )
        addTrait( "unending_rage", 209459 )
        addTrait( "void_cleave", 209573 )
        addTrait( "warbreaker", 209577 )
        addTrait( "will_of_the_first_king", 209548 )

        -- Shared/Fury Auras
        addAura( "avatar", 107574, "duration", 20 )
        addAura( "battle_cry", 1719, "duration", 5 )

            modifyAura( "battle_cry", "duration", function( x )
                return x + ( talent.reckless_abandon.enabled and 2 or 0 )
            end )

        addAura( "berserker_rage", 18499, "duration", 18499 )
        addAura( "bladestorm", 46924, "duration", 6, "incapacitate", true ) -- Fury.

            modifyAura( "bladestorm", "duration", function( x )
                return x * haste
            end )
            modifyAura( "bladestorm", "id", function( x )
                return spec.arms and 227847 or 46924
            end )
            class.auras[ 227847 ] = class.auras[ 46924 ]

        addAura( "bloodbath", 12292, "duration", 10 )
        addAura( "bounding_stride", 202164, "duration", 3 )
        addAura( "cleave", 188923, "duration", 6, "max_stack", 5 )
        addAura( "colossus_smash", 208086, "duration", 8 )
        addAura( "corrupted_blood_of_zakajz", 209567, "duration", 5 )
        addAura( "commanding_shout", 97463, "duration", 10 )
        addAura( "defensive_stance", 197690, "duration", 3600 )
        addAura( "die_by_the_sword", 118038, "duration", 8 )
        addAura( "dragon_roar", 118000, "duration", 8 )
        addAura( "enrage", 184362, "duration", 4 )
        addAura( "enraged_regeneration", 184364, "duration", 8 )
        addAura( "executioners_precision", 242188, "duration", 30, "max_stack", 2 )
        addAura( "focused_rage", 207982, "duration", 30, "max_stack", 3 )
        addAura( "frenzy", 202539, "duration", 15, "max_stack", 3 )
        addAura( "frothing_berserker", 215571, "duration", 6 )
        addAura( "furious_charge", 202225, "duration", 5 )
        addAura( "hamstring", 1715, "duration", 15 )
        addAura( "in_for_the_kill", 248622, "duration", 8 )
        addAura( "intimidating_shout", 5246, "duration", 8 )
        addAura( "massacre", 206316, "duration", 10 )
        addAura( "mastery_colossal_might", 76838 )
        addAura( "mastery_unshackled_fury", 76856 )
        addAura( "meat_cleaver", 85739, "duration", 20 )
        addAura( "mortal_strike", 115804, "duration", 10 )
        addAura( "odyns_fury", 205546, "duration", 4 )
        addAura( "overpower", 60503, "duration", 12 )
        addAura( "piercing_howl", 12323, "duration", 15 )
        addAura( "ravager", 152277 )
        addAura( "rend", 772, "duration", 8 )
        addAura( "sense_death", 200979, "duration", 12 )
        addAura( "shattered_defenses", 209706, "duration", 10 )
        addAura( "shockwave", 46968, "duration", 3 )
        addAura( "storm_bolt", 107570, "duration", 4 )
        addAura( "tactician", 184783 )
        addAura( "taste_for_blood", 206333, "duration", 8, "max_stack", 6 )
        addAura( "titans_grip", 46917 )
        addAura( "victory_rush", 32216, "duration", 20 )
        addAura( "war_machine", 215557, "duration", 15 )
        addAura( "wrecking_ball", 215570, "duration", 10 )


        ns.addHook( "gain", function( amount, resource )
            if state.spec.fury and state.talent.frothing_berserker.enabled then
                if state.rage.current == 100 then state.applyBuff( "frothing_berserker" ) end
            end
        end )


        addGearSet( "stromkar_the_warbreaker", 128910 )
        setArtifact( "stromkar_the_warbreaker" )

        addGearSet( "warswords_of_the_valarjar", 128908 )
        setArtifact( "warswords_of_the_valarjar" )

        
        addGearSet( 'tier20', 147187, 147188, 147189, 147190, 147191, 147192 )
            addAura( "raging_thirst", 242300, "duration", 8 ) -- fury 2pc.
            addAura( "bloody_rage", 242952, "duration", 10, "max_stack", 10 ) -- fury 4pc.
            -- arms 2pc: CDR to bladestorm/ravager from colossus smash.
            -- arms 4pc: 2 auto-MS to nearby enemies when you ravager/bladestorm, not modeled.

        addGearSet( 'tier21', 152178, 152179, 152180, 152181, 152182, 152183 )
            addAura( "war_veteran", 253382, "duration", 8 ) -- arms 2pc.
            addAura( "weighted_blade", 253383, "duration", 1, "max_stack", 3 ) -- arms 4pc.
            addAura( "slaughter", 253384, "duration", 4 ) -- fury 2pc dot.
            addAura( "outrage", 253385, "duration", 8 ) -- fury 4pc.

        addGearSet( "ceannar_charger", 137088 )
        addGearSet( "timeless_stratagem", 143728 )
        addGearSet( "kazzalax_fujiedas_fury", 137053 )
            addAura( "fujiedas_fury", 207776, "duration", 10, "max_stack", 4 )
        addGearSet( "mannoroths_bloodletting_manacles", 137107 ) -- NYI.
        addGearSet( "najentuss_vertebrae", 137087 )
        addGearSet( "valarjar_berserkers", 151824 )
        addGearSet( "ayalas_stone_heart", 137052 )
            addAura( "stone_heart", 225947, "duration", 10 )
        addGearSet( "the_great_storms_eye", 151823 )
            addAura( "tornados_eye", 248142, "duration", 6, "max_stack", 6 )
        addGearSet( "archavons_heavy_hand", 137060 )
        addGearSet( "weight_of_the_earth", 137077 ) -- NYI.

        
        addGearSet( "soul_of_the_battlelord", 151650 )
        setTalentLegendary( 'soul_of_the_battlelord', 'arms', 'deadly_calm' )
        setTalentLegendary( 'soul_of_the_battlelord', 'fury', 'massacre' )
        

        addSetting( 'forecast_fury', true, {
            name = "Forecast Fury Generation",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will anticipate Fury gains from your auto-attacks.",
            width = "full"
        } )


        -- Abilities

        -- Odyns Fury
        --[[ Unleashes the fiery power Odyn bestowed the Warswords, dealing (270% + 270%) Fire damage and an additional (400% of Attack power) Fire damage over 4 sec to all enemies within 14 yards. ]]

        addAbility( "odyns_fury", {
            id = 205545,
            spend = 0,
            cast = 0,
            gcdType = "melee",
            cooldown = 45,
            min_range = 0,
            max_range = 0,
            equipped = 'warswords_of_the_valarjar',
            toggle = 'artifact'
        } )

        addHandler( "odyns_fury", function ()
            applyDebuff( "target", "odyns_fury" )
            active_dot.odyns_fury = active_enemies
        end )


        -- Avatar
        --[[ Transform into a colossus for 20 sec, causing you to deal 20% increased damage and removing all roots and snares. ]]

        addAbility( "avatar", {
            id = 107574,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "avatar",
            cooldown = 90,
            min_range = 0,
            max_range = 0,
            toggle = 'cooldowns'
        } )

        addHandler( "avatar", function ()
            applyBuff( "avatar" )
        end )        
        
        
        -- Battle Cry
        --[[ Lets loose a battle cry, granting 100% increased critical strike chance for 5 sec. ]]

        addAbility( "battle_cry", {
            id = 1719,
            spend = 0,
            spend_type = "rage",
            cast = 0,
            gcdType = "off",
            cooldown = 60,
            min_range = 0,
            max_range = 0,
            recheck = function () return cooldown.global_cooldown.remains - 0.4, cooldown.global_cooldown.remains end,
        } )

        modifyAbility( "battle_cry", "spend", function( x )
            if talent.reckless_abandon.enabled then return -100 end
            return x
        end )

        addHandler( "battle_cry", function ()
            applyBuff( "battle_cry" )
            if artifact.corrupted_blood_of_zakajz.enabled then applyBuff( "corrupted_blood_of_zakajz" ) end
            if set_bonus.tier21 > 3 then applyBuff( "outrage" ) end
        end )


        -- Berserker Rage
        --[[ Go berserk, removing and granting immunity to Fear, Sap, and Incapacitate effects for 6 sec.    Also Enrages you for 4 sec. ]]

        addAbility( "berserker_rage", {
            id = 18499,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 60,
            min_range = 0,
            max_range = 0,
            toggle = 'cooldowns'
        } )

        modifyAbility( "berserker_rage", "cooldown", function( x )
            return x - ( talent.outburst.enabled and 15 or 0 )
        end )

        addHandler( "berserker_rage", function ()
            applyBuff( "berserker_rage" )
            if talent.outburst.enabled then 
                applyBuff( "enrage", 4 ) 
                if equipped.ceannar_charger then gain( 8, "rage" ) end
            end
        end )


        -- Bladestorm
        --[[ Become an unstoppable storm of destructive force, striking all targets within 8 yards with both weapons for 67,964 Physical damage over 5.6 sec.    You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks. ]]

        addAbility( "bladestorm", {
            id = 46924,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 90,
            min_range = 0,
            max_range = 0,
            talent = nil,
            notalent = "ravager",
            toggle = 'cooldowns'
        }, 227847 )

        modifyAbility( "bladestorm", "id", function( x )
            return spec.arms and 227847 or x
        end )

        modifyAbility( "bladestorm", "talent", function( x )
            if spec.fury then return "bladestorm" end
            return x
        end )

        modifyAbility( "bladestorm", "cast", function( x )
            return x * haste
        end )

        addHandler( "bladestorm", function ()
            applyBuff( "bladestorm", 6 )
            setCooldown( "global_cooldown", 6 * haste )
            if equipped.the_great_storms_eye then addStack( "tornados_eye", 6, 1 ) end
        end )


        -- Bloodbath
        --[[ For 10 sec, your melee attacks and abilities cause the target to bleed for 40% additional damage over 6 sec. ]]

        addAbility( "bloodbath", {
            id = 12292,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "bloodbath",
            cooldown = 30,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "bloodbath", function ()
            applyBuff( "bloodbath" )
        end )


        -- Bloodthirst
        --[[ Assault the target in a bloodthirsty craze, dealing 13,197 Physical damage and restoring 4% of your health.    Generates 10 Rage. ]]

        addAbility( "bloodthirst", {
            id = 23881,
            spend = -10,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 4.5,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "bloodthirst", "cooldown", function( x )
            return x * haste
        end )

        addHandler( "bloodthirst", function ()
            if stat.crit + 15 * buff.taste_for_blood.stack >= 100 then
                removeBuff( "taste_for_blood" )
            end
            removeBuff( "meat_cleaver" )
            if equipped.kazzalax_fujiedas_fury then addStack( "fujiedas_fury", 10, 1 ) end
            removeBuff( "bloody_rage" )
        end )

        
        -- Charge
        --[[ Charge to an enemy, dealing 2,675 Physical damage, rooting it for 1 sec and then reducing its movement speed by 50% for 6 sec.    Generates 20 Rage. ]]

        addAbility( "charge", {
            id = 100,
            spend = -20,
            spend_type = "rage",
            cast = 0,
            gcdType = "off",
            cooldown = 20,
            charges = 1,
            recharge = 20,
            min_range = 8,
            max_range = 25,
            passive = true,
            usable = function () return not ( prev_off_gcd.charge or prev_off_gcd.heroic_leap ) and target.maxR <= 25 and target.minR >= 7 end
        } )

        modifyAbility( "charge", "charges", function( x )
            return x + ( talent.double_time.enabled and 1 or 0 )
        end )

        modifyAbility( 'charge', 'cooldown', function( x )
            return x - ( talent.double_time.enabled and 3 or 0 )
        end )

        addHandler( 'charge', function()
            gain( 20, 'rage' )
            if talent.furious_charge.enabled then applyBuff( "furious_charge" ) end
            setDistance( 5 )
        end )

        -- Cleave
        --[[ Strikes all enemies in front of you with a sweeping attack for 13,137 Physical damage. For each target up to 5 hit, your next Whirlwind deals 20% more damage. ]]

        addAbility( "cleave", {
            id = 845,
            spend = 9,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 6,
            min_range = 0,
            max_range = 0,
            spec = "arms"
        } )

        addHandler( "cleave", function ()
            applyBuff( "cleave", 6, active_enemies )
        end )

        
        -- Colossus Smash
        --[[ Smashes the enemy's armor, dealing 42,079 Physical damage, and increasing damage you deal to them by 44% for 8 sec. ]]

        addAbility( "colossus_smash", {
            id = 167105,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 20,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "colossus_smash", function ()
            applyDebuff( "target", "colossus_smash", 8 )
            if artifact.shattered_defenses.enabled then applyBuff( "shattered_defenses" ) end
            if talent.in_for_the_kill.enabled then
                applyBuff( "in_for_the_kill" )
                stat.haste = state.haste + 0.1
            end
            if set_bonus.tier21 > 1 then applyBuff( "war_veteran" ) end
            if set_bonus.tier20 > 1 then
                if talent.ravager.enabled then setCooldown( "ravager", max( 0, cooldown.ravager.remains - 2 ) )
                else setCooldown( "bladestorm", max( 0, cooldown.bladestorm.remains - 3 ) ) end
            end
        end )        

        -- Commanding Shout
        --[[ Lets loose a commanding shout, granting all party or raid members within 30 yards 15% increased maximum health for 10 sec. After this effect expires, the health is lost. ]]

        addAbility( "commanding_shout", {
            id = 97462,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "commanding_shout", function ()
            applyBuff( "commanding_shout" )
        end )


        -- Defensive Stance
        --[[ A defensive combat state that reduces all damage you take by 20%, and all damage you deal by 10%. Lasts until cancelled. ]]

        addAbility( "defensive_stance", {
            id = 197690,
            spend = 0,
            cast = 0,
            gcdType = "off",
            talent = "defensive_stance",
            cooldown = 6,
            min_range = 0,
            max_range = 0,
        }, 212520 )

        modifyAbility( "defensive_stance", "id", function( x )
            if buff.defensive_stance.up then return 212520 end
            return x
        end )

        addHandler( "defensive_stance", function ()
            if buff.defensive_stance.up then removeBuff( "defensive_stance" )
            else applyBuff( "defensive_stance" ) end
        end )
        

         -- Die by the Sword
        --[[ Increases your parry chance by 100% and reduces all damage you take by 30% for 8 sec. ]]

        addAbility( "die_by_the_sword", {
            id = 118038,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "die_by_the_sword", function ()
            applyBuff( "die_by_the_sword" )
        end )

        
        -- Dragon Roar
        --[[ Roar explosively, dealing 6,498 damage to all enemies within 8 yards and increasing all damage you deal by 16% for 6 sec. Dragon Roar ignores all armor and always critically strikes. ]]

        addAbility( "dragon_roar", {
            id = 118000,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "dragon_roar",
            cooldown = 25,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "dragon_roar", function ()
            applyBuff( "dragon_roar" )
        end )


        -- Enraged Regeneration
        --[[ Reduces damage taken by 30%, and Bloodthirst restores an additional 20% health. Usable while stunned. Lasts 8 sec. ]]

        addAbility( "enraged_regeneration", {
            id = 184364,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 120,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "enraged_regeneration", function ()
            applyBuff( "enraged_regeneration" )
        end )


        -- Execute
        --[[ Attempt to finish off a wounded foe, causing 30,922 Physical damage. Only usable on enemies that have less than 20% health. ]]
        --[[ Arms: Attempts to finish off a foe, causing 29,484 Physical damage, and consuming up to 30 additional Rage to deal up to 88,453 additional damage. Only usable on enemies that have less than 20% health.    If your foe survives, 30% of the Rage spent is refunded. ]]

        addAbility( "execute", {
            id = 163201,
            spend = 10,
            min_cost = 10,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            usable = function () return buff.stone_heart.up or target.health_pct < 20 end,
        }, 5308 )

        modifyAbility( "execute", "id", function( x )
            if spec.fury then return 5308 end
            return x
        end )

        modifyAbility( "execute", "spend", function( x )            
            if spec.fury then
                if buff.sense_death.up then return 0 end
                if buff.stone_heart.up then return 0 end
                return 25
            end

            if talent.dauntless.enabled then x = x * 0.9 end
            if talent.deadly_calm.enabled and buff.battle_cry.up then x = x * 0.25 end
            return x
        end )
        
        modifyAbility( "execute", "min_cost", function( x )
            if spec.fury then return 25 end
            return x
        end  )

        addHandler( "execute", function ()
            if spec.arms then
                local addl_cost = 10 * ( talent.dauntless.enabled and 0.9 or 1 ) * ( talent.deadly_calm.enabled and buff.battle_cry.up and 0.25 or 1 )
                if buff.stone_heart.down then                
                    spend( min( addl_cost, rage.current ), "rage" ) 
                end
                removeBuff( "stone_heart" )
                if artifact.executioners_precision.enabled then addStack( "executioners_precision", 30, 1 ) end
                removeBuff( "shattered_defenses" )
                gain( ( action.execute.cost + addl_cost ) * 0.3, "rage" )
            elseif spec.fury then
                if buff.stone_heart.up then removeBuff( "stone_heart" )
                else removeBuff( "sense_death" ) end
            end
        end )


        -- Focused Rage
        --[[ Focus your rage on your next Mortal Strike, increasing its damage by 30%, stacking up to 3 times. Unaffected by the global cooldown. ]]

        addAbility( "focused_rage", {
            id = 207982,
            spend = 20,
            min_cost = 20,
            spend_type = "rage",
            cast = 0,
            gcdType = "off",
            talent = "focused_rage",
            cooldown = 1.5,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "focused_rage", function ()
            addStack( "focused_rage", 30, 1 )
        end )
        

        -- Furious Slash
        --[[ Aggressively strike with your off-hand weapon for 3,520 Physical damage. Increases your Bloodthirst critical strike chance by 15% until it next deals a critical strike, stacking up to 6 times. ]]

        addAbility( "furious_slash", {
            id = 100130,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "furious_slash", function ()
            addStack( "taste_for_blood", 8, 1 )
            addStack( "frenzy", 15, 1 )
        end )


         -- Hamstring
        --[[ Maims the enemy for 15,326 Physical damage, reducing movement speed by 50% for 15 sec. ]]

        addAbility( "hamstring", {
            id = 1715,
            spend = 10,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "hamstring", "spend", function( x )
            if talent.dauntless.enabled then return x * 0.9 end
            return x
        end )

        addHandler( "hamstring", function ()
            applyDebuff( "target", "hamstring", 15 )
        end )


        -- Heroic Leap
        --[[ Leap through the air toward a target location, slamming down with destructive force to deal 2,385 Physical damage to all enemies within 8 yards. ]]

        addAbility( "heroic_leap", {
            id = 6544,
            spend = 0,
            cast = 0,
            gcdType = "off",
            cooldown = 45,
            charges = 1,
            recharge = 45,
            min_range = 8,
            max_range = 40,
            passive = true,
            usable = function () return not ( target.minR < 7 or target.maxR > 40 ) and not ( prev_gcd.heroic_leap or prev_gcd.charge ) end
        } )

        modifyAbility( "heroic_leap", "cooldown", function( x )
            return x - ( talent.bounding_stride.enabled and 15 or 0 )
        end )

        modifyAbility( "heroic_leap", "charges", function( x )
            return equipped.timeless_stratagem and 3 or x
        end )

        addHandler( "heroic_leap", function ()
            -- This *would* reset CD on Taunt for Prot.
            setDistance( 5 )
            applyBuff( "bounding_stride" )
        end )


        -- Heroic Throw
        --[[ Throws your weapon at the enemy, causing 2,519 Physical damage. Generates high threat. ]]

        addAbility( "heroic_throw", {
            id = 57755,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 6,
            min_range = 8,
            max_range = 30,
        } )

        addHandler( "heroic_throw", function ()
            -- Generates high threat.
        end )


        -- Intimidating Shout
        --[[ Causes the targeted enemy to cower in fear, and up to 5 additional enemies within 8 yards to flee. Targets are disoriented for 8 sec. ]]

        addAbility( "intimidating_shout", {
            id = 5246,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 90,
            min_range = 0,
            max_range = 8,
        } )

        addHandler( "intimidating_shout", function ()
            applyDebuff( "target", "intimidating_shout" )
            active_dot.intimidating_shout = min( 6, active_enemies )
        end )


        -- Mortal Strike
        --[[ A vicious strike that deals 64,077 Physical damage and reduces the effectiveness of healing on the target for 10 sec. ]]

        addAbility( "mortal_strike", {
            id = 12294,
            spend = 20,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 6,
            charges = 1,
            recharge = 6,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "mortal_strike", "spend", function( x )
            x = x * ( talent.dauntless.enabled and 0.9 or 1 ) 
            if equipped.archavons_heavy_hand then x = x - 8 end
            return x
        end )

        addHandler( "mortal_strike", function ()
            applyDebuff( "target", "mortal_strike" )
            removeBuff( "shattered_defenses" )
            if set_bonus.tier21 > 3 then addStack( "weighted_blade", 12, 1 ) end
        end )


       -- Overpower
        --[[ Overpowers the enemy, causing 54,736 Physical damage. Cannot be blocked, dodged or parried, and has a 60% increased chance to critically strike.    Your other melee abilities have a chance to activate Overpower. ]]

        addAbility( "overpower", {
            id = 7384,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "overpower",
            buff = "overpower",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "overpower", function ()
            removeBuff( "overpower" )
        end )


        -- Piercing Howl
        --[[ Snares all enemies within 15 yards, reducing their movement speed by 50% for 15 sec. ]]

        addAbility( "piercing_howl", {
            id = 12323,
            spend = 10,
            min_cost = 10,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "piercing_howl", function ()
            applyDebuff( "target", "piercing_howl" )
            active_dot.piercing_howl = active_enemies
        end )


        -- Pummel
        --[[ Pummels the target, interrupting spellcasting and preventing any spell in that school from being cast for 4 sec. ]]

        addAbility( "pummel", {
            id = 6552,
            spend = 0,
            cast = 0,
            gcdType = "off",
            cooldown = 15,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "pummel", function ()
            interrupt()
        end )


        -- Raging Blow
        --[[ A mighty blow with both weapons that deals a total of 10,204 Physical damage. Only usable while Enraged.    Generates 5 Rage. ]]

        addAbility( "raging_blow", {
            id = 85288,
            spend = -5,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            buff = nil,
        } )

        modifyAbility( "raging_blow", "buff", function( x )
            if not talent.inner_rage.enabled then return "enrage" end
            return x
        end )

        modifyAbility( "raging_blow", "cooldown", function( x )
            if talent.inner_rage.enabled then return 4.5 * haste end
            return x
        end )

        addHandler( "raging_blow", function ()
            removeBuff( "raging_thirst" )
            if set_bonus.tier21 > 3 then addStack( "bloody_rage", 10, 1 ) end
        end )


        -- Rampage
        --[[ Enrages you and unleashes a series of 5 brutal strikes over 2 sec for a total of 24,668 Physical damage. ]]

        addAbility( "rampage", {
            id = 184367,
            spend = 85,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 1.5,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "rampage", "spend", function( x )
            if buff.massacre.up then return 0 end            
            return x - ( talent.carnage.enabled and 15 or 0 )
        end )

        addHandler( 'rampage', function ()
            removeBuff( "massacre" )
            applyBuff( 'enrage', 4 )
            removeBuff( "meat_cleaver" )
            if set_bonus.tier21 > 1 then applyDebuff( "target", "slaughter" ) end
        end )
        

        -- Ravager
        --[[ Throws a whirling weapon at the target location that inflicts 260,141 damage to all enemies within 8 yards over 6.3 sec.     Generates 7 Rage each time it deals damage. ]]

        addAbility( "ravager", {
            id = 152277,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "ravager",
            cooldown = 60,
            min_range = 0,
            max_range = 40,
        } )

        addHandler( "ravager", function ()
            if equipped.the_great_storms_eye then addStack( "tornados_eye", 6, 1 ) end
        end )
        

        -- Rend
        --[[ Wounds the target, causing 21,894 Physical damage instantly and an additional 110,116 Bleed damage over 8 sec. ]]

        addAbility( "rend", {
            id = 772,
            spend = 30,
            min_cost = 30,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            talent = "rend",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "rend", function ()
            applyDebuff( "target", "rend" )
        end )
        

        -- Shockwave
        --[[ Sends a wave of force in a frontal cone, causing 5,230 damage and stunning all enemies within 10 yards for 3 sec. Cooldown reduced by 20 sec if it strikes at least 3 targets. ]]

        addAbility( "shockwave", {
            id = 46968,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "shockwave",
            cooldown = 40,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "shockwave", "cooldown", function( x )
            if active_enemies > 2 then return x - 20 end
            return x
        end )

        addHandler( "shockwave", function ()
            applyDebuff( "target", "shockwave" )
            active_dot.shockwave = active_enemies
        end )


        -- Slam
        --[[ Slams an opponent, causing 44,530 Physical damage. ]]

        addAbility( "slam", {
            id = 1464,
            spend = 20,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "slam", "spend", function( x )
            if talent.dauntless.enabled then return x * 0.9 end
            return x
        end )

        addHandler( "slam", function ()
            removeBuff( "weighted_blade" )
        end )
        
        
        -- Storm Bolt
        --[[ Hurls your weapon at an enemy, causing 4,011 Physical damage and stunning for 4 sec. ]]

        addAbility( "storm_bolt", {
            id = 107570,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "storm_bolt",
            cooldown = 30,
            min_range = 0,
            max_range = 20,
        } )

        addHandler( "storm_bolt", function ()
            applyDebuff( "target", "storm_bolt" )
        end )


        -- Taunt
        --[[ Taunts the target to attack you, and increases threat that you generate against the target for 3 sec. ]]

        addAbility( "taunt", {
            id = 355,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 8,
            min_range = 0,
            max_range = 30,
        } )

        addAura( "taunt", 355, "duration", 3 )

        addHandler( "taunt", function ()
            applyDebuff( "target", "taunt" )
        end )


        -- Victory Rush
        --[[ Strikes the target, causing 22,022 damage and healing you for 30% of your maximum health.    Only usable within 20 sec after you kill an enemy that yields experience or honor. ]]

        addAbility( "victory_rush", {
            id = 34428,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            nospec = "fury",
            buff = "victory_rush"
        } )

        addHandler( "victory_rush", function ()
            removeBuff( "victory_rush" )
        end )


        -- Warbreaker
        --[[ Stomp the ground, causing a ring of corrupted spikes to erupt upwards, dealing 44,424 Shadow damage and applying the Colossus Smash effect to all nearby enemies. ]]

        addAbility( "warbreaker", {
            id = 209577,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 60,
            min_range = 0,
            max_range = 100,
            toggle = 'artifact',
            equipped = 'stromkar_the_warbreaker',
            trait = 'warbreaker'
        } )

        addHandler( "warbreaker", function ()
            applyDebuff( "target", "colossus_smash" )
            active_dot.colossus_smash = active_enemies
        end )


        -- Whirlwind
        --[[ Unleashes a whirlwind of steel, striking all enemies within 8 yards for 8,348 Physical damage.    Causes your next Bloodthirst or Rampage to strike up to 4 additional targets for 50% damage. ]]
        --[[ Arms: Unleashes a whirlwind of steel, striking all enemies within 8 yards for 39,410 Physical damage. ]]

        addAbility( "whirlwind", {
            id = 1680,
            spend = 30,
            min_cost = 30,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        }, 190411 )

        modifyAbility( "whirlwind", "id", function( x )
            if spec.fury then return 190411 end
            return x
        end )

        modifyAbility( "whirlwind", "spend", function( x )
            if spec.fury then return 0 end
            return x
        end )
        
        addHandler( "whirlwind", function ()
            if spec.fury then applyBuff( "meat_cleaver" ) end
            removeBuff( "wrecking_ball" )
            removeBuff( "weighted_blade" )
        end )

    end
   

    storeDefault( [[SimC Arms: single]], 'actionLists', 20171203.205647, [[daKToaqiuqBIQIrjr6uqbRcfiTlu1WGshtclJQQNjr00iP01qLQ2gQu5BOqJdvk5COaQ1HceZdk09iPyFseoiQKfII8quutefO6IKqBefOCssQUPu1oHQFIkfwkk5PetLeTvQk9vuPu7v5VsLbtPdlAXa9yHMmvUSQndOptcgnj50s61qrZwWTLYUr8BidhL64OsrlhPNtQPd66uLTJk(oagpkaNxIA9OaY8bO9tXRykNGNTprQnMnwUOnndIXQRefcFIW(XAgQmqjSIidNXIjSE4P(d3p2cgl8JTK8fCNAvlwUBIePv2Wjt4kcRiIEkhEXuorrscgUBmnrI0kB4eqpGa5btim8UiTmVhBJ1hJTuJvFyhiI4P5H1t9JTtTSJgBjmwSglGaASNB6vzZ(oEOQ3Pa9jStdr0MU7LVXIHjCbwdvy5jGH0DnerBtuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWuiDxdr02ewp8u)H7hBbJfyNW6AKhnE9uo4eMv9iM9ioVDcCGt6ro8S9jdoC)t5efjjy4UX0ejsRSHta9acKxRkHWtVRZDGNOVM3HaGmHlWAOclpjIciT2t3PBPw1e1jUAmHi6ecI8j9iNVjfpBFYe8S9jmJciT2tBSsl1QMW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWHxYPCIIKemC3yAIePv2WjLASLASWmCcKh4PCq0oeWoWecdN)KemCNX6JX6oOhqG8ruaP1E6oDl1Q4PVLvI2yXOXQq0zSyWybeqJLHglmdNa5bEkheTdbSdmHWW5pjbd3zS(ySLASLASGEabYRHiY7u9Kc59yBSacOXgrOGdbaHVHOWm0PH0kMNN(wwjAJfJQXyJiuWHaGWRqabMHUicfCiai803YkrBSyWy9Xyb9acKxRkHWtVRZDGNOVM3HaGySyWyXWeUaRHkS8easki9jMNorDIRgtiIoHGiFspY5BsXZ2NmbpBFc3oPG0NyE6ewp8u)H7hBbJfyNW6AKhnE9uo4eMv9iM9ioVDcCGt6ro8S9jdoC1oLtuKKGH7gttKiTYgoHHglOhqG8GjegExKwUZ90fk3fZqJ3JTX6JXc6beipqu0tFxhnv48AygX0yXOXwsJ1hJLHgBeHcoeae(ikG0ApDNULAv8ESnwFm2snwAQW5JEu6jqJTeQXylkjwJfqanw3b9acKpIciT2t3PBPwfVdbaXybeqJfMHtG8jrHt7Ajjv4TtG8NKGH7mwFm2icfCiai8GjegExKwMN(wwjAJfJQXy5wglgMWfynuHLNaef9031rtf(e1jUAmHi6ecI8j9iNVjfpBFYe8S9jmyOON(oJLvQWNW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWHZ9t5efjjy4UX0ejsRSHtOVLvI2yXOAmwfIoJfqanw6BzLOnwmASCVX6JXgrOGdbaHhmHWW7I0Y803YkrBSy0y9BS(ySLASrek4qaq4bdP7AiI24PVLvI2yXOX63ybeqJLHgR(WoqeXtZdRN6hBNAzhn2sySynwmmHlWAOclpHEIBI6exnMqeDcbr(KEKZ3KINTpzcE2(ewN4MW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWHZDt5efjjy4UX0ejsRSHtIiuWHaGWdMqy4DrAzE6BzLOnwmQgJvHOZy9XyDh0diq(ikG0ApDNULAv803YkrBSLWy5UjCbwdvy5j0KtQWPtuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWk5KkC6ewp8u)H7hBbJfyNW6AKhnE9uo4eMv9iM9ioVDcCGt6ro8S9jdoCgNYjkssWWDJPjsKwzdNa6beiVgIiVt1tkK3J9eUaRHkS8KZaE0d(jQtC1ycr0jee5t6roFtkE2(Kj4z7tuKb8Oh8ty9Wt9hUFSfmwGDcRRrE041t5Gtyw1Jy2J482jWboPh5WZ2Nm4W5wt5efjjy4UX0ejsRSHta9acKhmHWW7I0Y8oeaKjCbwdvy5jioNYgbWPtuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWn4CkBeaNoH1dp1F4(XwWyb2jSUg5rJxpLdoHzvpIzpIZBNah4KEKdpBFYGdNbEkNOijbd3nMMirALnCcOhqG8AvjeE6DDUd8e918ESnwab0yb9acK)mGh9Gve5uDhB6JvDfr4Diait4cSgQWYtAikmdDAiTI5NOoXvJjerNqqKpPh58nP4z7tMGNTpPhrHzWyfiTI5NW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWHxGDkNOijbd3nMMirALnCc9TSs0glgvJX68OjSIigldQXILVKt4cSgQWYtON4MOoXvJjerNqqKpPh58nP4z7tMGNTpH1joJT0cmmH1dp1F4(XwWyb2jSUg5rJxpLdoHzvpIzpIZBNah4KEKdpBFYGdVOykNOijbd3nMMirALnCcmdNa5bEkheTdbSdmHWW5pjbd3zS(ySGEabYhdp5CEhcaIX6JXYqJ9CtVkB23XN0OQKdIO7u9Kt5ovjXnHlWAOclpjgEY5tuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWC4jNpH1dp1F4(XwWyb2jSUg5rJxpLdoHzvpIzpIZBNah4KEKdpBFYGdVW)uorrscgUBmnrI0kB4KmcRCE3jVvV2ylHXwySacOXcZWjqEGNYbr7qa7atimC(tsWWDt4cSgQWYtaqvLgaOsCtuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWTvvPbaQe3ewp8u)H7hBbJfyNW6AKhnE9uo4eMv9iM9ioVDcCGt6ro8S9jdo8IsoLtuKKGH7gttKiTYgojJWkN3DYB1Rnw1ySfgRpgldnwygobYd8uoiAhcyhycHHZFscgUZy9Xyl1yPPcNp6rPNan2sOgJL79BSacOXYqJfMHtG80tC8NKGH7mwab0yzOXcZWjqEAYjv4u(tsWWDglgMWfynuHLNOdzBI6exnMqeDcbr(KEKZ3KINTpzcE2(ejKTjSE4P(d3p2cglWoH11ipA86PCWjmR6rm7rCE7e4aN0JC4z7tgC4fQDkNOijbd3nMMWfynuHLNG4CkBeaNorDIRgtiIoHGiFspY5BsXZ2NmbpBFc3GZPSraCQXwAbgMW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWHxW9t5efjjy4UX0ejsRSHtyOXQpSder808W6P(X2Pw2rJTegl2jCbwdvy5jGH0DnerBtuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWuiDxdr0MXwAbgMW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWbNWGFGPxaoMgCda]] )

    storeDefault( [[SimC Arms: default]], 'actionLists', 20171203.205647, [[dCeFqaqikPSicKnraFsaHrjQ0PukmlkPI2fkgMu5ysvltu8mLIAAeOUMaQTrbX3OaJJcs6CkfrRJcQ5Puv3JGAFcIdsilKG8qLstuarxua2Osr4KIkwjfKYlPGuntbKUjfANu0pPKQmukPsTukXtPAQc0vPKkSvLQ8vkPs2l4VuQbRQdRyXq1JfzYk5YiBgk(mHA0cQttQvtjv1RPKmBHUTu2nQ(nKHdLworpNKPl56O02fv9DbPXRuKoVO06PGeZxPY(vzOhccU50iWDDB79IKnLHVFryg2ybUJLs6jQnuMsJ4GPb9GBHI0OiWmtxVb9z62mtVHiyb3ziG7jPgBbo4IsLgXvqqWShccEa8bpslqiWfHRJ6kl4PWJumbEo8LonfscohXjWnIw7nsZPrGdU50iW3gEKIjWTqrAueyMPR3G(oWTqkeRmrkiiuGVnmLSYikp1iEb4GBeTmNgbouGzgii4bWh8iTaHa3tsn2c8CV3A3xtK4fZKFQrYq8bpsR73T7ECwmyyM8tnsgwS3VX9cCpolgmm4tvrYojZYWI9EbUFr4SyWWKqrKsXQSvTrfMHf7972DFnsXuXu6gzxi7LMUFFHVpJHaUiCDuxzbhlQ0io4BdtjRmIYtnIxao4grR9gP50iWb3CAe4w3OsJ4GlskwboFAKWccfx2HosbbUfksJIaZmD9g03bUfsHyLjsbbHc8C4lDAkKeCoItGBeTmNgbokUSdDKqbMBgccEa8bpslqiW9KuJTahNfdgg8PQizNKzzyXE)UD3xJumvmLUr2fYEPP73x477neWfHRJ6kl44reAzJHvMf8C4lDAkKeCoItGBeT2BKMtJahCZPrGlueHw3VjyLzb3cfPrrGzMUEd67a3cPqSYePGGqb(2WuYkJO8uJ4fGdUr0YCAe4qbMcgccEa8bpslqiW9KuJTahNfdgg8PQizNKzzyXE)UD3xJumvmLUr2fYEPP73x4777bxeUoQRSGJtsfjTsZfdEo8LonfscohXjWnIw7nsZPrGdU50iWfIKksALMlgCluKgfbMz66nOVdClKcXktKcccf4BdtjRmIYtnIxao4grlZPrGdfygyii4bWh8iTaHa3tsn2cCCwmyyWNQIKDsM1ErZkM1onXgZcfk)EbUxoIjMfHrN019HCVG7UxG7tiuCHcLZGpvfj7KmlJKAJMRUpK77axeUoQRSGpY0Wj7cjLeVaph(sNMcjbNJ4e4grR9gP50iWb3CAe4IKPHt3hejLeVa3cfPrrGzMUEd67a3cPqSYePGGqb(2WuYkJO8uJ4fGdUr0YCAe4qbMgcee8a4dEKwGqG7jPgBbEcHIluOCgXre(eTtiuCHcLZiP2O5Q73)(oMmb(EbUp37XzXGHbFQks2jzwgwS3VB39jekUqHYzWNQIKDsMLrsTrZv3V)99b((nUF3U7RrkMkMs3i7czV0097l89z6axeUoQRSGp5NAKGNdFPttHKGZrCcCJO1EJ0CAe4GBoncCr5NAKGBHI0OiWmtxVb9DGBHuiwzIuqqOaFBykzLruEQr8cWb3iAzoncCOatdGGGhaFWJ0cecCZPrGBrZfFpcZ9BrX4GvP5IVFtWwSssbEo8LonfscohXjWfHRJ6kl4snxSncJDcfJdwLMl2gdBXkjf4wifIvMifeekWTqrAueyMPR3G(oW9KuJTahNfdgg8PQizNKzzyXEVa3ViCwmyysOisPyv2Q2OcZWI9EbU3A3JZIbdtrnS1uAeNHfluGPHkee8a4dEKwGqGBonc8aPCyfhUUhH5EhXgvGNdFPttHKGZrCcCr46OUYc(soSIdx2im2keBubUfsHyLjsbbHcCluKgfbMz66nOVdCpj1ylWZ9(CVhRKYBloTy6zAiznrBvj1wr3VB39jekUqHYzAiznrBvj1wrmsQnAU6(qe((nF)g3lW94SyWWGpvfj7KmlJKAJMRUpeHVFZ3lW9lcNfdgMekIukwLTQnQWmSyVFJZqdkWCtcbbpa(GhPfie4MtJa3qxhdew)HwepqOUxiwjxZfFV1Lwfg8C4lDAkKeCoItGlcxh1vwWTshT(dTiUYgNvY1CX2HQvHb3cPqSYePGGqbUfksJIaZmD9g03bUNKASf4lcNfdgMekIukwLTQnQWmSyHcm77GGGhaFWJ0cecCpj1ylWZ9(CVVgPyQykDJSlK9st3hIW3Bq3972DVIkBCeNvXuAsMPZwWyt3hY9D3VX9cCFU3N79jekUqHYzehr4t0oHqXfkuoJKAJMRUFFHVVJjW3lW9yLuEBXPftpJCYpIj59BC)UD3BT7Rjs8Iro5hXKKH4dEKw3lW9w7(ecfxOq5mIJi8jANqO4cfkNrsTrZv3hY9D3lW91iftfZIWzXGHjHIiLIvzRAJkmJKAJMRUpeHVpW3lW95EV1UpHqXfkuodECwKQqYgJKAJMRUpK77UF3U7T29kQSXrCwftPjzMoBbJnDFi33D)g3lW95EV1UVMiXlgjXxmeFWJ06(D7UFHkgjXxmsQnAU6(qUxW3VX9BC)g3VB394SyWWqBkLylnItsLnwjL0knIZOQjz19cFFM7f4ECwmyyuHNQijTSxegIRifdl27f4ERDFcHIluOCgXre(eTtiuCHcLZiP2O5Q7d5(U7f4ERDVIkBCeNvXuAsMPZwWyt3hY9DGlcxh1vwWXNQIKDsMf8C4lDAkKeCoItGBeT2BKMtJahCZPrGl0uvKUFRml4wOinkcmZ01BqFh4wifIvMifeekW3gMswzeLNAeVaCWnIwMtJahkWSVhccEa8bpslqiW9KuJTahNfdgg8PQizNKzzyXEVa3ViCwmyysOisPyv2Q2OcZWIfCr46OUYcoRIS1f1uGNdFPttHKGZrCcCJO1EJ0CAe4GBoncCRdfDFof1uGBHI0OiWmtxVb9DGBHuiwzIuqqOaFBykzLruEQr8cWb3iAzoncCOaZ(mqqWdGp4rAbcbUNKASf41iftftyAIvygSP6(9f((mD3lW9tQ05jBItnnPUF)7dm4IW1rDLfCjl3EsLgXTJAvb(2WuYkJO8uJ4fGdUr0AVrAoncCWnNgbUfw(9IsLgXVpq1QcCrsXkW5tJewqUUT9ErYMYW3tBkLylsqwN1iftLTgJW1iftftyAIvygSPAFHZ0jWKkDEYM4uttQ9dm4wOinkcmZ01BqFh4wifIvMifeekWZHV0PPqsW5iobUr0YCAe4UUT9ErYMYW3tBkLylckWSFZqqWdGp4rAbcbUNKASf4tQ05jBItnnPUpeHVxWGlcxh1vwWLSC7jvAe3oQvf4BdtjRmIYtnIxao4grR9gP50iWb3CAe4wy53lkvAe)(avRQ7ZTFdWfjfRaNpnsyb56227fjBkdFViRxaccCluKgfbMz66nOVdClKcXktKcccf45Wx60uij4CeNa3iAzoncCx32EViztz47fz9cakWSxWqqWdGp4rAbcbUNKASf4tQ05jBItnnPUpeHVpd4IW1rDLfCjl3EsLgXTJAvb(2WuYkJO8uJ4fGdUr0AVrAoncCWnNgbUfw(9IsLgXVpq1Q6(CZSb4IKIvGZNgjSGCDB79IKnLHVpfPjpjiWTqrAueyMPR3G(oWTqkeRmrkiiuGNdFPttHKGZrCcCJOL50iWDDB79IKnLHVpfPjpbfy2hyii4bWh8iTaHa3tsn2c8AKIPIjmnXkmd2uDFi3NPdCr46OUYcUKLBpPsJ42rTQaFBykzLruEQr8cWb3iAT3inNgbo4MtJa3cl)ErPsJ43hOAvDFUBEdWfjfRaNpnsyb56227fjBkdFVsZfhjbbUfksJIaZmD9g03bUfsHyLjsbbHc8C4lDAkKeCoItGBeTmNgbURBBVxKSPm89knxCKGckWdKeMHnwGqqbaa]] )

    storeDefault( [[SimC Arms: precombat]], 'actionLists', 20171203.205647, [[b4vmErLxt5uyTvMxtnvATnKFGfKCTnNo(bgCYv2yV1MyHrNxtnfCLnwAHXwA6fgDP9MBE50nX41usvgBLf2CL5LtYatm3eJmWmJlXydn0aJnEn1uJjxAWrNxt51ubngDP9MBZ5fvE5umErLxtvKBHjgBLrMxc51ubjwASLgD551uW9gDP9MBEnvsUrwAJfgDVjNxt52BUvMxt10BKzvyY5uyTvMxt51uofwBL51uq9gDP9MBEnvqYD2CEnLBH1wz9iYBSr2x3fMCI41usvgBLf2CL5LtYatm3edmEnLuLn3B1j3yLnNxu5fDEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxt9gBK91DHjNx05fDEnfrLzwy1XgDEjKx05Lx]] )

    storeDefault( [[SimC Arms: execute]], 'actionLists', 20171203.205647, [[d8dBlaWCuTELOWMqc7cfBJQK2hsKldEmvMTOMpPs3uP68Iu3wvoTq7eQ2R0UjSFs(PsuPHbfJtjk13qsEnvvdMOHJuDqKItHe1XukNtjQyHiPwkP0IvvlhXdjf9uklJQY6uIQAIkrrtLu1KfmDvUiPI)QKEgPqxhL2OsuLTsvQnlITdL8DLWxHsftdkL5js6Wk(msPrtvmEQsCsrIdbLkDnOu19uI8BihxjkzuKcUBvFn85b1S4ttLKgYJV8vsWlGJ9GAgDWfNCCzmxejkovB10czy4qX9HzJQnFy0iZMxXg2W41AMJePF1QrJ7IibV6l(w1xthX8ZqOuxZCKi9R2NnjH5p3LHvhjndlDLKcLudkjhU1psWYzUiq8HzfB0DkjLusmkPU6QKWYInsNoeyopWkTeyUv(Hip(kKguskxJMFmhV01(5ja8drE1sreIU5qKAcKaQTJcEpe85b1QHppOg15ja8drE10czy4qX9HzJQnm10cCelXb8QVxnn9ao)7iSGhiU(RTJc4ZdQ1R4(Q(A6iMFgcL6AMJePF1(SjjmCpZDabcRbibeCGZeqlekjfkPguYpBscZFUldRosAMaAHqj1vxLudk5NnjHb8c4yVisae(kDc4I8isWWVX5xjxsj9PKuOKAqjDiuoGwiy(ZDzy1rsZqG3efCLmvLCtj1vxL8ZMKW8N7YWQJKMHLUsszLKYkjLRrZpMJx6AougX5S8v(B4EQLIieDZHi1eibuBhf8Ei4ZdQvdFEqnnrzeNZYvs7nCp10czy4qX9HzJQnm10cCelXb8QVxnn9ao)7iSGhiU(RTJc4ZdQ1R4AS6RPJy(ziuQRzosK(vZHq5aAHG5Hi3Kx5hj6hyiWBIcUsM6skPdHYb0cbdTz0FYRoekhqleme4nrbxjPqj)SjjmCpZDabcRbibeCGZeqlekjfk5NnjHb8c4yVisae(kDc4I8isWWVX5xjxsj9vJMFmhV01wmKpbg)aPwkIq0nhIutGeqTDuW7HGppOwn85b1Wod5tGXpqQPfYWWHI7dZgvByQPf4iwId4vFVAA6bC(3rybpqC9xBhfWNhuRxXXw1xthX8ZqOuxZCKi9RgzOfycqs0fpLmvLuJyVssHs(ztsysqowoewjdTad)gNFLmvLuJ1O5hZXlDTeKJLdHvYqlulfri6MdrQjqcO2ok49qWNhuRg(8GAlpKJLdbLu7qlutlKHHdf3hMnQ2WutlWrSehWR(E100d48VJWcEG46V2okGppOwVIJ9vFnDeZpdHsDnZrI0VAe4nrbxjtvjXELKcL0Hq5aAHG5p3LHvhjndbEtuWvYuvsFkjfkPgushcLdOfcMFEca)qKhdbEtuWvYuvsFkPU6QKyxLKd36hjy5mxei(WSIn6oLKskjgLKY1O5hZXlDncic1sreIU5qKAcKaQTJcEpe85b1QHppOMwqeQPfYWWHI7dZgvByQPf4iwId4vFVAA6bC(3rybpqC9xBhfWNhuRxX9A1xthX8ZqOuxZCKi9RMdHYb0cbZFUldRosAgc8MOGRKPUKssRlOKuOKb4ZMKW4qzeNZYx5VH7HHaVjk4kjLusVwJMFmhV01idwdTaPwkIq0nhIutGeqTDuW7HGppOwn85b10oyn0cKAAHmmCO4(WSr1gMAAboIL4aE13RMMEaN)DewWdex)12rb85b16vCQQ(A6iMFgcL6AMJePF1(SjjmGxah7frcGWxPtaxKhrcg(no)k5skPpLKcL8ZMKWW9m3beiSgGeqWbodl9A08J54LU2drUjVYps0pulfri6MdrQjqcO2ok49qWNhuRg(8GA7iYnzL0os0putlKHHdf3hMnQ2WutlWrSehWR(E100d48VJWcEG46V2okGppOwVIVSR(A6iMFgcL6AMJePF1UjdIJjbiyHiROK1)CxgyaX8ZqqjPqj)SjjmlGiTEoiS(Ztay4348RKlPKAujPqjdWNnjHXHYioNLVYFd3ddlDLKcL8ZMKW8N7YWQJKMjGwiQrZpMJx6Al8ej5frrOwkIq0nhIutGeqTDuW7HGppOwn85b1WoEIK8IOiutlKHHdf3hMnQ2WutlWrSehWR(E100d48VJWcEG46V2okGppOwVIVCQ(A6iMFgcL6AMJePF1idTaJJLqaXPKPQKydtnA(XC8sxdHfqOJwaKAPicr3Cisnbsa12rbVhc(8GA1WNhuB5IfqOJwaKAAHmmCO4(WSr1gMAAboIL4aE13RMMEaN)DewWdex)12rb85b16v8nmvFnDeZpdHsDnZrI0VAF2KegUN5oGaH1aKacoWzcOfcLuxDvsYqlW4yjeqCkjLwsjXggLuxDvYBYG4ycdR4YaNZaI5NHGssHssgAbghlHaItjP0skPg9AnA(XC8sxd8c4ypOwkIq0nhIutGeqTDuW7HGppOwn85b10XlGJ9GAAHmmCO4(WSr1gMAAboIL4aE13RMMEaN)DewWdex)12rb85b16v8TTQVMoI5NHqPUM5ir6xnnOKJ7IybRGaErGRKusj3uskRKuOKyxLKd36hjy5mxei(WSIn6oLKskjMA08J54LU2ppbGFiYRMMEaN)DewWdex)12rbVhc(8GA1WNhuJ68ea(HipLudBuUgneA51IIdiew63sB10czy4qX9HzJQnm10cCelXb8QVxTueHOBoePMajGA7Oa(8GA96vBzcjdB(k19Aba]] )

    storeDefault( [[SimC Arms: AOE]], 'actionLists', 20171203.205647, [[d4t8laGEeIQnHq1UukBdHI9HqQBRWJP0SPy(ujCtj6Ws9nfv3JkPDQK9k2nQ2pk(jcrzykvJdHionPEoHbJudxcDqfXPqj1XOIZHqGfQOSue1IrYYj6HsWQqiOLjPSoec1eriKPIitMQMoOlIs8mQeDzvxxsETKQTIs1MjP2oj8DfPVIqY0qO08ij1Njj(ljA0iy8KK0jrPmkusUgjjopvQNcDieI0VbooHuWvpEqupkWqproeeXm0tiYyjiw8wDB0e5nud4zn3ji5BElEw12DM7uB3LBoedXsS7etq0k1fHbdoXc1aUiKYYjKcYcVPm3NzbrRuxegKvm0waW4bt5BuM2FbeihBvfzODHlyOTaGXdMY3OmT)ciqo2KF0AUGHw1UYqRI1ZqZAgAIZqZkgAlay8GP8nQgcnxPv6ERQidTlCbdTfamEWu(gvdHMR0kDVj)O1CbdTQDLHwfRNHM1bNqPnAO7GtBjL8D9ldYg3RTneidYb8hSe4zVLRE8Gbx94bjQwsjFx)YGKV5T4zvB3zUZEqYxaQK2lcPadwGWT1lbk(4CyOcwc8RE8GbMvTqkil8MYCFMfeTsDryqQk1Q3OAi0CLwP7TQIm0eNHMiLHg2MZHBYwrRYLBN3uM7doHsB0q3bPmT)ciqocYg3RTneidYb8hSe4zVLRE8Gbx94bNzA)fqGCeK8nVfpRA7oZD2ds(cqL0ErifyWceUTEjqXhNddvWsGF1JhmWSCzifKfEtzUpZcIwPUimiSnNd3KTIwLl3oVPm3ZqtCgAlay8GP8nQgcnxPv6Et(rR5cgAv7kdTkwpdnXzO9NQsT6nlWaeIkHsXOfe2KF0AUGHMOzOjMGtO0gn0DqzROv5YGSX9ABdbYGCa)blbE2B5QhpyWvpEqYTIwLlds(M3INvTDN5o7bjFbOsAViKcmybc3wVeO4JZHHkyjWV6XdgyweBifKfEtzUpZcIwPUimivLA1BAUs1aPsiHRSU2y28GPCgAIZqdBZ5WnnxPAGujKWvwxBmBN3uM7doHsB0q3bTadqiQekfJwqiiBCV22qGmihWFWsGN9wU6XdgC1JhSaWaeIkbdnoAbHGKV5T4zvB3zUZEqYxaQK2lcPadwGWT1lbk(4CyOcwc8RE8GbMLQesbzH3uM7ZSGOvQlcd6pvLA1BwGbievcLIrliS5bt5m0eNHUTqTIR88p0xWqRAxzOD2doHsB0q3bTadqiQekfJwqiybc3wVeO4JZHHkyjWZElx94bdYg3RTneidYb8hC1JhSaWaeIkbdnoAbbgAw5W6GtKQicADBnxjSLQCOWvNGKV5T4zvB3zUZEqYxaQK2lcPadwWT1CsTuLdfzwWsGF1JhmWSiMqkil8MYCFMfeTsDryW2c1kUYZ)qFbdnr7kdTQeCcL2OHUdAnVv8GSX9ABdbYGCa)blbE2B5QhpyWvpEWcM3kEqY38w8SQT7m3zpi5lavs7fHuGblq426LafFComublb(vpEWaZAEifKfEtzUpZcIwPUimyBHAfx55FOVGHMODLHwvyOjodnvLA1BwZBfFRQyWjuAJg6o4ucAPzQM7dYg3RTneidYb8hSe4zVLRE8Gbx94bjkcAPzQM7ds(M3INvTDN5o7bjFbOsAViKcmybc3wVeO4JZHHkyjWV6XdgywejHuqw4nL5(mliAL6IWGTfQvCLN)H(cgAI2vg65bNqPnAO7GtjOLMPAUpiBCV22qGmihWFWsGN9wU6XdgC1JhKOiOLMPAUNHMvoSoi5BElEw12DM7ShK8fGkP9IqkWGfiCB9sGIpohgQGLa)QhpyGzreesbzH3uM7ZSGOvQlcdsvPw9MGqdHxEVs)vFU4Inpykp4ekTrdDh0cmaHOsOumAbHGSX9ABdbYGCa)blbE2B5QhpyWvpEWcadqiQem04OfeyOzvnwhK8nVfpRA7oZD2ds(cqL0ErifyWceUTEjqXhNddvWsGF1JhmWSC2dPGSWBkZ9zwq0k1fHbPQuREtab8RKWBjCRQyWjuAJg6o4v1BRGpiBCV22qGmihWFWsGN9wU6XdgC1JhKfv92k4ds(M3INvTDN5o7bjFbOsAViKcmybc3wVeO4JZHHkyjWV6XdgywooHuqw4nL5(mliAL6IWGuvQvVji0q4L3R0F1NlUyRQidTlCbdnvLA1BxvVTcQb8lfklkVvl0a(MhmLhCcL2OHUdoasyBukGsD9hKnUxBBiqgKd4pyjWZElx94bdU6XdwcKW2WqJqPU(ds(M3INvTDN5o7bjFbOsAViKcmybc3wVeO4JZHHkyjWV6Xdgywo1cPGSWBkZ9zwq0k1fHbLF0AUGHw1UYq7RKnud4m0eHm07BUKHM4m0TfQvCLN)H(cgAv7kdTldoHsB0q3bLN7dwGWT1lbk(4CyOcwc8S3YvpEWGSX9ABdbYGCa)bx94bjFUp4ePkIGw3wZvcBPkhkC1ji5BElEw12DM7ShK8fGkP9IqkWGfCBnNulv5qrMfSe4x94bdmlhxgsbzH3uM7ZSGtO0gn0DqR5TIhKnUxBBiqgKd4pyjWZElx94bdU6XdwW8wXzOzLdRds(M3INvTDN5o7bjFbOsAViKcmybc3wVeO4JZHHkyjWV6XdgywoeBifKfEtzUpZcoHsB0q3bNsqlnt1CFq24ETTHazqoG)GLap7TC1Jhm4Qhpirrqlnt1CpdnRQX6GKV5T4zvB3zUZEqYxaQK2lcPadwGWT1lbk(4CyOcwc8RE8GbgyqIORURmWmlWea]] )

    storeDefault( [[SimC Arms: cleave]], 'actionLists', 20171203.205647, [[dSd2haGEuPuBIsKDHk2gLO2NusA2sCtk13KsDBfUSQDkv7LSBk2VI8yQmmL43qDEkPtlPbROgoQKdkQ8CuoMOCoevXcfvTuLQfJWYr6HIWQqLcltjzDiQQMiIQYuvktMQMoKlIioeIQ0Zqu56sXgrLI2kIYMfjBhv57sj(QusmnPKAEuc(RsQplIgnQQXJkvojI0tbxdvQ6EucDyHXHkL8ArQvM2e0JXfa1rIP5C0bJ8pn7kp4Dbax3vJsLBhOk2OE7mb7V8GD1xTK1oB1c54Kz5w36fllaC0kxibcY5qvSHPn1Z0Masmbr5ELxa4OvUqciAsLIdrGqLV2rTYPHRPzlnntENMrr5gehAWlsEkNBcIY9cYrulvKvbeLWFgcthci14RUaHPcmyZfyJ9Kf0EmUab9yCb5lH)meMoeS)Yd2vF1sw7Sfb7NHBOUZ0MqcsW)U02yEFCdsecSX(EmUaHuFL2eqIjik3R8cahTYfsakk3G4qdErYt5CtquUFA2stZomU4XTy4qeiu5RDuRCOFevdBA2cwCAoPZpnBPPz)jAsLIJdxWmwdBnBem(COFevdBAUvNMTSGCe1sfzvan4fjpvaPgF1fimvGbBUaBSNSG2JXfiOhJlyp4fjpvW(lpyx9vlzTZweSFgUH6otBcjib)7sBJ59XniriWg77X4cesDYPnbKycIY9kVaWrRCHe4prtQuCC4cMXAyRzJGXNJh3IrqoIAPISkWHlygRHTMncgFbj4FxABmVpUbjcb2ypzbThJlqaPgF1fimvGbBUGEmUGe4cMXAytZWiy8fKJMKjWz1v(AuqtEeZIzc2F5b7QVAjRD2IG9ZWnu3zAtibjS6kFlOjpIP8cSX(EmUaHuV1AtajMGOCVYlaC0kxibenPsXHXpqOtVFT)PUHDghpUfJGCe1sfzvqlbLG(i9Pci14RUaHPcmyZfyJ9Kf0EmUab9yCbTsqjOpsFQG9xEWU6RwYANTiy)mCd1DM2esqc(3L2gZ7JBqIqGn23JXfiK6CV2eqIjik3R8cahTYfsansEo(NQ6QOPzlmntoUFA2stZenPsXjf21WUFnnsEomu4spnBHPzYjihrTurwfKc7Ay3VMgjVasn(QlqyQad2Cb2ypzbThJlqqpgxa3e7Ay3pnVhjVG9xEWU6RwYANTiy)mCd1DM2esqc(3L2gZ7JBqIqGn23JXfiK6wwBciXeeL7vEbGJw5cjG(runSPzlyXPzFdnqvSzAMBmnVWHCcYrulvKvb0B8csW)U02yEFCdsecSXEYcApgxGasn(QlqyQad2Cb9yCb734fKJMKjWz1v(AuqtEeZIzc2F5b7QVAjRD2IG9ZWnu3zAtibjS6kFlOjpIP8cSX(EmUaHuVT2eqIjik3R8cYrulvKvbdmffL1meTM(ci14RUaHPcmyZfyJ9Kf0EmUab9yCb2ykkktZaIwtFb7V8GD1xTK1oBrW(z4gQ7mTjKGe8VlTnM3h3GeHaBSVhJlqi15wAtajMGOCVYlihrTurwfCU7Ug0fqQXxDbctfyWMlWg7jlO9yCbc6X4ciH7URbDb7V8GD1xTK1oBrW(z4gQ7mTjKGe8VlTnM3h3GeHaBSVhJlqi1jpAtajMGOCVYlihrTurwf4kp4DbKA8vxGWubgS5cSXEYcApgxGGEmUGeLh8UG9xEWU6RwYANTiy)mCd1DM2esqc(3L2gZ7JBqIqGn23JXfiK6zlAtajMGOCVYlihrTurwf0c)kT0s14fqQXxDbctfyWMlWg7jlO9yCbc6X4cAf(vAPLQXly)LhSR(QLS2zlc2pd3qDNPnHeKG)DPTX8(4gKieyJ99yCbcjKaY3tfnfKYlKe]] )

    storeDefault( [[SimC Fury: three targets]], 'actionLists', 20171203.205647, [[dOZweaGEsj1Maf2LG2gPu2hrvmBHMVeYnLOBdyNszVu7gX(HYOaLmmj53eEoixwzWq1Wjkheu1PafDmbESQAHsWsvLwmqlhPhcHEkQLrkwhPenrIQ0uHutwQMUkxeICEi4zKs11jvBucvBLOYMjsBNiCAs(kPK8zi57quhw0FbvgTQy8sOCsIOPbk11iLW9iQQ(MKYHiQkVws1oWOn3sGzMvaiIHxCDkcAjg(9q3WWVKIAhKzw2(QmQ068ucIB10y(DXLqZnnvb1c0uP9WaTbByxPnZ8NQKDMnd))uccKr7wGrBgjscgx3fmZFQs2zguxQ0qOtqgCplPxOUmZWdQIQdbZRy7RFZSKKU6NNGAMiiZCPOlxsBjWmBULaZmsfBF9BMFxCj0CttvqTGkZVdsOt)dYO9zgXN9RxkKyaJCg0CPO3sGz2NBAmAZirsW46UGz(tvYoZG6sLgcS8G7hxkXOH6YWWHbgoSWWHfgoOUuPHJqtulSlqMGHddmC5dd)Y4ixOuQ4EueuWbok0O1hnCKemUogomXWlQimCyHHttul8RtPJCy4YJ8JHhuvHHddm8lJJCHsPI7rrqbh4OqJwF0WrsW46y4WedhMy4fvegoOUuPHajeu(PluxMz4bvr1HGzAcilrnZss6QFEcQzIGmZLIUCjTLaZS5wcmZVjGSe1m)U4sO5MMQGAbvMFhKqN(hKr7ZmIp7xVuiXag5mO5srVLaZSp30UrBgjscgx3fmZFQs2z(Y4ixOIqgfoAIAHJKGX1ndpOkQoemttukck4aJcKnljPR(5jOMjcYmxk6YL0wcmZMBjWm)MOueuy4fIcKn)U4sO5MMQGAbvMFhKqN(hKr7ZmIp7xVuiXag5mO5srVLaZSp3GTrBgjscgx3fmdpOkQoemdgfI(9OOqNzjjD1ppb1mrqM5srxUK2sGz2ClbM5crHOFpkk0z(DXLqZnnvb1cQm)oiHo9piJ2NzeF2VEPqIbmYzqZLIElbMzFUPfgTzKijyCDxWm8GQO6qWmYpkAezfPBwssx9ZtqnteKzUu0LlPTeyMn3sGzwREu0iYks387IlHMBAQcQfuz(DqcD6FqgTpZi(SF9sHedyKZGMlf9wcmZ(8zwEN0upEUGpBa]] )

    storeDefault( [[SimC Fury: single target]], 'actionLists', 20171203.205647, [[d4dQjaGAbsTEfcBIcAxO02acTpfspxOztvZxPQBQuUns(gq5Yq7eWEL2TQ2pHrbunmvQXjqKZlGttPbt0WPIoifYPashtqNtGkluHAPivlwjlhvpKIYtjTmQK1jqutuGetLImzfnDqxKc1JvXZui66OyJabBLIQnRGTtfmpbk9vbsAAar9DLkhw0FPsnAvY4fO4KuH(ms5AarUNavDibcVMc8Be3WAQkqsHvvlLzcjiWWdeKfYO9P5rHeMCAiSQ6ep20BhrcTKVaG5QkD0JzelGR7qWcDDps2qqeKb5BqSQE4wNWQvn6aTKpwtfiSMQA8Nlpo74Q6HBDcRUyggyhycAloZO7bgEawgNcPHc5IzyGDGjOT4mJUhy4by5ivA)OqgScPRQgTSElmq1LNqMWllpcR64pTNes4vFYJv3itZtoqsHvRcKuy1XEczcVS8iSkD0JzelGR7qWcVRshJeg(bJ1uHvn7cpgSrCaPWh2v1nYeiPWQfwax1uvJ)C5XzhxvpCRtyvy6XhYoWXFebyXpxECkKgkKGlKlMHb2bo(Jia7KS7fY97fYfZWa7ah)reGLJuP9JczWg8cPlHe0QgTSElmq1bgULWeDh9z8QQJ)0EsiHx9jpwDJmnp5ajfwTkqsHvbbgULWefs1NXRQ0rpMrSaUUdbl8UkDmsy4hmwtfw1Sl8yWgXbKcFyxv3itGKcRwybgznv14pxEC2Xv1d36ewDXmmWIppPHSmofsdfsy6XhYA)h5U5jnKf)C5XzvJwwVfgOkpPzFAUxEYUQo(t7jHeE1N8y1nY08KdKuy1QajfwLEsZ(0eYXEYUQ0rpMrSaUUdbl8UkDmsy4hmwtfw1Sl8yWgXbKcFyxv3itGKcRwyba5AQQXFU84SJRQhU1jSkm50qi7fME4fRZduihviDfkKgkKGlK8KgYEy4C8Hc5ObVqgEFlK73lKbHqctp(q2bobEzFAUxipICdqol(5YJtHeuH0qHeCHeCHeCH8qi(jz3ZUsi0JUp8aSCKkTFuihvibjHC)EH8qi(jz3ZU8eYCLWlwosL2pkKJkKGKqcQqAOqgecjm94dzpj)tAil(5YJtHeuHC)EHeCHeCH8qi(jz3ZUsi0JUp8aSCKkTFuihvihPqUFVqEie)KS7zxEczUs4flhPs7hfYrfYrkKGkKgkKW0JpK9K8pPHS4NlpofsqfsqfY97fYfZWalvgJ5HJSmoRA0Y6TWav5jLZKgw1XFApjKWR(KhRUrMMNCGKcRwfiPWQ0tkNjnSkD0JzelGR7qWcVRshJeg(bJ1uHvn7cpgSrCaPWh2v1nYeiPWQfwaqQMQA8Nlpo74Q6HBDcRUyggyJqYJUVWKdzzCkKgkKGlKGlKW0JpK1(pYDZtAil(5YJtH0qH8qi(jz3ZYtA2NM7LNSJLJuP9Jc5OczOqcQqUFVqUyggyXNN0qwgNcjOvnAz9wyGQyWGhgiw1XFApjKWR(KhRUrMMNCGKcRwfiPWQghm4HbIvPJEmJybCDhcw4Dv6yKWWpySMkSQzx4XGnIdif(WUQUrMajfwTWcaI1uvJ)C5Xzhx1OL1BHbQU8eYeEz5ryvh)P9KqcV6tES6gzAEYbskSAvGKcRo2tit4LLhHcj4HGwLo6XmIfW1DiyH3vPJrcd)GXAQWQMDHhd2ioGu4d7Q6gzcKuy1clay1uvJ)C5XzhxvpCRty1icDViptKfArEyW52LZJqoQqElKgkKbHqctp(qw7)i3npPHS4NlpoRA0Y6TWavhy4wct0D0NXRQo(t7jHeE1N8y1nY08KdKuy1Qajfwfey4wctuivFgVesWdbTkD0JzelGR7qWcVRshJeg(bJ1uHvn7cpgSrCaPWh2v1nYeiPWQfwGGunv14pxEC2Xv1d36ewDXmmWUJJhdSpn3R07zzCkKgkKlMHbw85jnKLXzvJwwVfgO6Ull3VZ(ZQo(t7jHeE1N8y1nY08KdKuy1QajfwnOEz5(D2FwLo6XmIfW1DiyH3vPJrcd)GXAQWQMDHhd2ioGu4d7Q6gzcKuy1clqWvtvn(ZLhNDCvJwwVfgOkpPzFAUxEYUQo(t7jHeE1N8y1nY08KdKuy1QajfwLEsZ(0eYXEYoHe8qqRsh9ygXc46oeSW7Q0XiHHFWynvyvZUWJbBehqk8HDvDJmbskSAHfi8UMQA8Nlpo74QgTSElmq1bgULWeDh9z8QQJ)0EsiHx9jpwDJmnp5ajfwTkqsHvbbgULWefs1NXlHeCxGwLo6XmIfW1DiyH3vPJrcd)GXAQWQMDHhd2ioGu4d7Q6gzcKuy1clSAqbhsgpSJlSf]] )

    storeDefault( [[SimC Fury: default]], 'actionLists', 20180306.225054, [[due1BaqiLk1IOuyterJcKCkLQUfivODHOHbQogiwMe8mjunnjuUgLIABGuvFJK04uQeoNsL06OuY8KqUhiL9rPuhuPyHefpuP0ebPsDrbLnssyKGubNuq1mPuKBIq7Ke)eKkAOkvIAPKupLQPkixvPsKTQuXEH(RenyvoSOfd0JfAYk5YO2mr1NjsJMs1Pj1QbPsEnrPztXTL0Ur63kgocoojrwoHNdy6sDDkz7c03jcJhKQCEqz9Ke18fW(v1ieme6kzLr311T)PclbmB93ILNwMgDNah1PrRYzRhkQOAb0vZgobyuPaCiQcPa8ItwaUnd9lMQO7rHMqJo6BITEOayiubcgc9WOjOHxOmOVbuB0nm0J2tHug9WPlDm7rGoDOm6eN1oPqjRm6ORKvg9T2tHugD1SHtagvkahIQqGJUAgySergadHn6BTZrzjob5ktBeeDIZsjRm6yJkfWqOhgnbn8cLbDpk0eA07uiLBYLgOtAK)Z2)zZOVbuB0nm0JPXuMXwp0sJgOrpC6shZEeOthkJoXzTtkuYkJo6kzLrFBAm)Tj26H(NnPbA03iKcGonRm0SHRRB)tfwcy26V6eKRmTTb6QzdNamQuaoevHahD1mWyjImagcB03ANJYsCcYvM2ii6eNLswz0DDD7FQWsaZw)vNGCLPn2OsXXqOhgnbn8cLbDpk0eA0rFdO2OByOBNfJowA4Ka6Htx6y2JaD6qz0joRDsHswz0rxjRm6qhyXOJ)ztCsaD1SHtagvkahIQqGJUAgySergadHn6BTZrzjob5ktBeeDIZsjRm6yJkfddHEy0e0Wlug09OqtOrh0sUCsWSBdxgfWiTi8NK)b1FGwYLtMbZofKwe(lqG)29FDAyAtMbZofKmnbn86V9OVbuB0nm0jmTEOOhoDPJzpc0PdLrN4S2jfkzLrhDLSYOVlpTEOOVrifaDAwzOzJXSkLif2aD1SHtagvkahIQqGJUAgySergadHn6BTZrzjob5ktBeeDIZsjRm6JzvkrkWgvSzme6HrtqdVqzq3JcnHgDO(Jvjlnbc8Imo0GSqktJC5iVuE2mWFs(xCgZAKGscMDB4YOagPGRPMc8xr)v4V9)fiWF7(pwLS0eiWlY4qdYcPmnYLJ8s5zZa)j5Fq93U)loJznsqjbZUnCzuaJuW1utb(RiO9he4)fiWFXzmRrckjy2THlJcyKcUMAkWFf9xH)2)xGa)b1FDAyAtcAMzbMTDsMMGgE9NK)b1FXzmRrckjOzMfy22jfCn1uG)k6pi)fiWFGwYLtcAMzbMTDslc)T)V9OVbuB0nm0xIu6qlftkqpC6shZEeOthkJoXzTtkuYkJo6kzLrh6wKsh6FQNuGUA2WjaJkfGdrviWrxndmwIidGHWg9T25OSeNGCLPncIoXzPKvgDSrfOpgc9WOjOHxOmO7rHMqJECgZAKGscMDB4YOagPGRPMc8xr)b5pj)loJznsqjbnZSaZ2oPGRPMc8xr)b5pj)RtHuUjTZPPTtsi2)z7)kah9nGAJUHHUiResPm6Htx6y2JaD6qz0joRDsHswz0rxjRm6QZkHukJUA2WjaJkfGdrviWrxndmwIidGHWg9T25OSeNGCLPncIoXzPKvgDSrfvXqOhgnbn8cLbDpk0eA070W0MuUGPQmmsMMGgE9NK)b1FGwYLtkxWuvggjqNrz)RO)k(Fbc8hOLC5KYfmvLHrk4AQPa)v0Ff)Vab(dQ)IZywJeusWSBdxgfWifCn1uG)k6pi)j5FGwYLtkxWuvggPGRPMc8xr)TR)T)V9OVbuB0nm0LBj0JfqjGjbSJE40LoM9iqNougDIZANuOKvgD0vYkJUkSe6Xc4p3Ka2rxnB4eGrLcWHOke4ORMbglrKbWqyJ(w7CuwItqUY0gbrN4SuYkJo2OYUadHEy0e0Wlug09OqtOrNvjlnbc8I0QckstzDgQutQdYa)j5Fq9xCgZAKGscMDB4YOagPGRPMc8NT)tAC9NK)fNXSgjOKGz3gUmkGrk4AQPa)v0Ff(lqG)IZywJeusWSBdxgfWifCn1uG)G2FW)Bp6Ba1gDddDRkOinL1zOsnPoidGE40LoM9iqNougDIZANuOKvgD0vYkJ(UufuKM)iodvQj1bza03iKcGonRm0SQGI0uwNHk1K6Gma6QzdNamQuaoevHahD1mWyjImagcB03ANJYsCcYvM2ii2OYUIHqpmAcA4fkd6EuOj0OZQKLMabErkBQYQCAsOxPClOlnVsGs5wcy)j5FGwYLtk3c6sZReOuULag5AKGI(gqTr3Wqh0mZQTRfan6Htx6y2JaD6qz0joRDsHswz0rxjRm6YyMz121cGgD1SHtagvkahIQqGJUAgySergadHn6BTZrzjob5ktBeeDIZsjRm6yJkqGJHqpmAcA4fkd6EuOj0Od1Fq9hOLC5KGz3gUmkGrk4AQPa)z7)S5)ce4V4mM1ibLem72WLrbmsbxtnf4VI(dsH)2)NK)1Pqk3KTUYL9uU08F2(VDb8)2)xGa)b1Fq9xNcPCt26kx2t5sZ)v0Ffd(F7)tY)G6pql5YjbZUnCzuaJuW1utb(Z2)b9)lqG)IZywJeusWSBdxgfWifCn1uG)k6pif(lqG)G6Vofs5MS1vUSNYLM)RO)ka)V9)T)V9OVbuB0nm0ZGzNc0dNU0XShb60HYOtCw7KcLSYOJUswz03em7uGUA2WjaJkfGdrviWrxndmwIidGHWg9T25OSeNGCLPncIoXzPKvgDSrfiqWqOhgnbn8cLbDpk0eA0JZywJeusPMbmnLXzmRrckPGRPMc8h0(d(Fs(xNgM2KcokRHbaktWKUgkjttqdV(tY)29FDAyAtcAMzbMTDsMMGgE9NK)b1FSkzPjqGxKwvqrAkRZqLAsDqg4pj)dQ)ii4GLJC5LsJlsRkOinL1zOsnPoid8xGa)b1FTqtLLBY4mM1ibLuW1utb(Z2)v8)K8VwOPYYnzCgZAKGsk4AQPa)v0F7k8)2)3()ce4VD)hRswAce4fPvfuKMY6muPMuhKb(Bp6Ba1gDddDWSBdxgfWqpC6shZEeOthkJoXzTtkuYkJo6kzLrxMSBd)3wbm0vZgobyuPaCiQcbo6QzGXsezame2OV1ohLL4eKRmTrq0jolLSYOJnQaPagc9WOjOHxOmO7rHMqJECgZAKGsk1mGPPmoJznsqjfCn1uG)G2FW)tY)60W0Me0KlgOhrLKPjOHx)j5Fq9xgBDqUKPCvZa)z7)G83E03aQn6gg6Gz3gUmkGHE40LoM9iqNougDIZANuOKvgD0vYkJUmz3g(VTcy)bfK9ORMnCcWOsb4qufcC0vZaJLiYayiSrFRDoklXjixzAJGOtCwkzLrhBubsXXqOhgnbn8cLbDpk0eA0JZywJeusPMbmnLXzmRrckPGRPMc8h0(d(Fs(hOLC5KlrkDOLIjfKwe(tY)G6V4mM1ibLe0mZQTRfanPGRPMc8h0(d(Fbc8hOLC5KmvKszsbxtnf4pB)xCgZAKGscAMz121cGMuW1utb(Bp6Ba1gDddDWSBdxgfWqpC6shZEeOthkJoXzTtkuYkJo6kzLrxMSBd)3wbS)GQWE0vZgobyuPaCiQcbo6QzGXsezame2OV1ohLL4eKRmTrq0jolLSYOJnQaPyyi0dJMGgEHYGUhfAcn6q9xCgZAKGsk1mGPPmoJznsqjfCn1uG)G2FW)lqG)IZywJeusPMbmnLXzmRrckPGRPMc8xrq7p4Kf7pj)JGGdwknUiHqkYkHuk)3()K8pO(loJznsqjbnZSaZ2oPGRPMc8h0(d(Fbc8hOLC5KGMzwGzBN0IWFbc83U)RtdtBsqZmlWSTtY0e0WR)ce4pO(RtHuUjBDLl7PCP5)k6pif(B)F7)tY)G6pwLS0eiWlsRkOinL1zOsnPoid8NK)b1FeeCWYrU8sPXfPvfuKMY6muPMuhKb(lqG)G6VwOPYYnzCgZAKGsk4AQPa)z7)k(Fs(xl0uz5MmoJznsqjfCn1uG)k6VDf(F7)B)Fbc83U)Jvjlnbc8I0QckstzDgQutQdYa)Th9nGAJUHHoy2THlJcyOhoDPJzpc0PdLrN4S2jfkzLrhDLSYOlt2TH)BRa2Fqv89ORMnCcWOsb4qufcC0vZaJLiYayiSrFRDoklXjixzAJGOtCwkzLrhBubInJHqpmAcA4fkd6EuOj0OdAjxojy2THlJcyKwe(tY)aTKlNKPIuktAr4pj)B3)bAjxozZvcD26HsAraD1mWyjImagcB03aQn6gg6cnvA5iVmogtsaqtLwk3QTema6Htx6y2JaD6qz0vZgobyuPaCiQcbo6kzLrxTMk9Vr(FBhJjjOPs)tfwTLGbWgvGa9XqOhgnbn8cLbDpk0eA0bTKlNem72WLrbmslc)fiWFq9xNcPCt26kx2t5sZ)v0Fqk2F7)lqG)G6V4mM1ibLem72WLrbmsbxtnf4VI(RWFs(hbbhSuACrcHuKvcPu(V9OVbuB0nm0bnZSaZ2o6Htx6y2JaD6qz0joRDsHswz0rxjRm6YyMzbMTD0vZgobyuPaCiQcbo6QzGXsezame2OV1ohLL4eKRmTrq0jolLSYOJnQarvme6HrtqdVqzq3JcnHgDql5YjbZUnCzuaJ0Ia6Ba1gDddDqZmRs5wcyOhoDPJzpc0PdLrN4S2jfkzLrhDLSYOlJzM1FQWsadD1SHtagvkahIQqGJUAgySergadHn6BTZrzjob5ktBeeDIZsjRm6yJkq2fyi0dJMGgEHYGUhfAcn6q9hOLC5KGz3gUmkGrAr4pj)dQ)aTKlNmdMDkiTi8xGa)T7)60W0MmdMDkizAcA41F7)B)Fbc8hu)bAjxojy2THlJcyKwe(tY)6uiLBYwx5YEkxA(VI(RyW)Bp6Ba1gDddDqwaWcz1uPOhoDPJzpc0PdLrN4S2jfkzLrhDLSYOldlayHSAQu0vZgobyuPaCiQcbo6QzGXsezame2OV1ohLL4eKRmTrq0jolLSYOJnQazxXqOhgnbn8cLbDpk0eA0fPuMmAjemT)RO)ePuMSMqV)Go(xXGJ(gqTr3WqpfXKYL9iemTrpC6shZEeOthkJoXzTtkuYkJo6kzLrFJiMu(VqJqW0gD1SHtagvkahIQqGJUAgySergadHn6BTZrzjob5ktBeeDIZsjRm6yJkfGJHqpmAcA4fkd6EuOj0OdAjxojy2THlJcyKweqFdO2OByOhtJPmJTEOLgnqJE40LoM9iqNougDIZANuOKvgD0vYkJUAl6FBITEO)ztAG(pOGSh9ncPaOtZkdnB4662)uHLaMT(loJznsqbSb6QzdNamQuaoevHahD1mWyjImagcB03ANJYsCcYvM2ii6eNLswz0DDD7FQWsaZw)fNXSgjOayJkfGGHqpmAcA4fkd6EuOj0O3Pqk3K25002jje7)S9FfG)NK)b1FzS1b5sMYvnd8h0(R4)fiWFzS1b5sMYvnd8h0(Ry)Th9nGAJUHHUWIwMXwp0sJgOrpC6shZEeOthkJoXzTtkuYkJo6kzLrxTf9VnXwp0)Sjnq)huf2J(gHua0PzLHMnCDD7FQWsaZw)12fm)xNcPCdyd0vZgobyuPaCiQcbo6QzGXsezame2OV1ohLL4eKRmTrq0jolLSYO7662)uHLaMT(RTly(Vofs5gaBuPqbme6HrtqdVqzq3JcnHg9m26GCjt5QMb(Z2)vm03aQn6gg6clAzgB9qlnAGg9WPlDm7rGoDOm6eN1oPqjRm6ORKvgD1w0)2eB9q)ZM0a9Fqv89OVrifaDAwzOzdxx3(NkSeWS1FBGodZgORMnCcWOsb4qufcC0vZaJLiYayiSrFRDoklXjixzAJGOtCwkzLr311T)PclbmB93gOZWWgvkuCme6HrtqdVqzq3JcnHg9ofs5M0oNM2ojHy)xr)vao6Ba1gDddDHfTmJTEOLgnqJE40LoM9iqNougDIZANuOKvgD0vYkJUAl6FBITEO)ztAG(pOk2E03iKcGonRm0SHRRB)tfwcy26pg6XrRMTb6QzdNamQuaoevHahD1mWyjImagcB03ANJYsCcYvM2ii6eNLswz0DDD7FQWsaZw)XqpoA1m2OsHIHHqpmAcA4fkd6EuOj0O3Pqk3K25002jje7)S9FfGJ(gqTr3WqxyrlZyRhAPrd0OhoDPJzpc0PdLrN4S2jfkzLrhDLSYOR2I(3MyRh6F2KgO)dkBEp6BesbqNMvgA2W11T)PclbmB9hGMk1W)1Pqk32aD1SHtagvkahIQqGJUAgySergadHn6BTZrzjob5ktBeeDIZsjRm6UUU9pvyjGzR)a0uPg(Vofs5gBSrh6MLNwMgLbBeb]] )

    storeDefault( [[SimC Fury: precombat]], 'actionLists', 20171203.205647, [[b4vmErLxt5uyTvMxtnvATnKFGzuDYLNo(bgCYv2yV1MyHrNxtnfCLnwAHXwA6fgDP9MBE50nY41usvgBLf2CL5LtYatm3eJmWmJlXydn0aJnEn1uJjxAWrNxt51ubngDP9MBZ5fvE5umErLxtvKBHjgBLrMxc51ubjwASLgD551uW9gDP9MBEnvsUrwAJfgDVjNxt52BUvMxt10BKzvyY5uyTvMxt51uofwBL51uq9gDP9MBEnvqYD2CEnLBH1wz9iYBSr2x3fMCI41usvgBLf2CL5LtYatm3edmEnLuLn3B1j3yLnNxu5fDEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxt9gBK91DHjNx05fDEnfrLzwy1XgDEjKx05Lx]] )

    storeDefault( [[SimC Fury: cooldowns]], 'actionLists', 20171203.205647, [[dae4laqisH2eQQ(KsLKrjO6ukvSlsmmL4yKQLrsEgkuMgPGRHcvTnuQY3uQACkvkoNsLQwNsLsZdfs3dfI2hkvoikYcfKhIQYerHWfrPSruQQtII6MkLDQk)uPsQLQQ8uIPIsUQsLOTsk1xvQe2R0FfWGPYHfTyf9yinzfUmyZQQ(SsA0OkNMIxJcMnvDBi2nu)gPHtsTCepxOPRY1rLTtk57KIgpku58c06vQuz(ck7Nsx9YQYlrGkIbHpRJ95ib3TwhkL6hunXXkIAa1KEZUlpdf33Evv(apKrOpvl671vTWyk6SNg0Wc7vrqjg1xLkmHEgkoww9PxwvydNtpmAOkckXO(Qm5()vqYymrjGcNARJFRBY9)RaysUckeajn4O1XOwNEfMMgV5cwHKiQZvOcZ4HbnpkPcMIHkB0H2j5LiqLkVebQ8LiQZvOYh4Hmc9PArFV(sLpis5iOqSS6vHpEakdBuTaeaFDwzJoEjcuPxFQkRkSHZPhgnufbLyuFvUKScNcpi9hpf1ON1XOwNQfRJFRBY9)RaysUckeajn4O1XOwNEfMMgV5cwz6P0XXZqIxfMXddAEusfmfdv2OdTtYlrGkvEjcujKNshhpdjEv(apKrOpvl671xQ8brkhbfILvVk8XdqzyJQfGa4RZkB0XlrGk96JXkRkSHZPhgnufMMgV5cwbyCak3bvygpmO5rjvWumuzJo0ojVebQu5Liqf2yCak3bv(apKrOpvl671xQ8brkhbfILvVk8XdqzyJQfGa4RZkB0XlrGk96tdLvf2W50dJgQYlrGkmcsYTY7So6V1juoFScZ4HbnpkPcMIHkmnnEZfSYGKCR8Ua0)arkNpw5dIuockelREv(apKrOpvl671xQiOeJ6RYK7)xzM35HaOKGkeajn4O1XoRtL1XV1n5()vamjxbfcGKgC06yN1PY6436c36c36U0d4tzqYvkoaHMefaNtpmSo(TUj3)VYGKRuCacnjkeajn4O1XogP1Xyw3owxyHzDA06U0d4tzqYvkoaHMefaNtpmSUD61hJVSQWgoNEy0qvEjcuzxgbRJ5dqIvygpmO5rjvWumuHPPXBUGv4IqaZbiXkFqKYrqHyz1RYh4Hmc9PArFV(sfbLyuFv61h7vwvydNtpmAOkckXO(QCPhWNIbJbsasUckaoNEyyD8BDtU)FfatYvqHtDfMMgV5cwHKRg8AGPNQzfMXddAEusfmfdv2OdTtYlrGkvEjcu5lxn4vRlKNQzLpWdze6t1I(E9LkFqKYrqHyz1RcF8aug2OAbia(6SYgD8seOsV(2xwvydNtpmAOkckXO(QeU1rYvqbLJqa8zDSJrAD6llwh)w3LEaFk)e6XZGxdmbseimaefaNtpmSo(TonADr4cmPyUOYzaIk9aAqnQ1XoRBX62X6clmRlcxGjfZfvodquPhqdQrTo2zDlwxyHzDA06U0d4t5NqpEg8AGjqIaHbGOa4C6HrfMMgV5cwHKiQZvOcZ4HbnpkPcMIHkB0H2j5LiqLkVebQ8LiQZvW6cxFNkFGhYi0NQf996lv(GiLJGcXYQxf(4bOmSr1cqa81zLn64LiqLE9TBkRkSHZPhgnufbLyuFvMC))kaMKRGcNARJFRlCRdLs9dQMyfsUAWRbMEQMkeajn4O1XoRBX6clmRtJw3LEaFkgmgibi5kOa4C6HH1TtfMMgV5cwHocIJb(5ibRWmEyqZJsQGPyOYgDODsEjcuPYlrGk76rq8UkADSphjyLpWdze6t1I(E9LkFqKYrqHyz1RcF8aug2OAbia(6SYgD8seOsV(29Lvf2W50dJgQIGsmQVkx6b8Pq5UjhjEkaoNEyyD8BDtU)FfatYvqzq1eBD8BDtU)FLzENhcGscQWPUcttJ3CbRmbseimaKaKCfQWmEyqZJsQGPyOYgDODsEjcuPYlrGkHaseimaeR7lxHkFGhYi0NQf996lv(GiLJGcXYQxf(4bOmSr1cqa81zLn64LiqLE9PVuwvydNtpmAOkckXO(QeU1n5()vamjxbfcGKgC06yuRt364360O1DPhWNcL7MCK4Pa4C6HH1TJ1fwywNgTUl9a(umymqcqYvqbW50dJkmnnEZfSY0tPJJNHeVkmJhg08OKkykgQSrhANKxIavQ8seOsipLooEgs8SUW13PYh4Hmc9PArFV(sLpis5iOqSS6vHpEakdBuTaeaFDwzJoEjcuPxF66Lvf2W50dJgQIGsmQVktU)Ffnjakdg8AGz69kCQTo(TUj3)VcGj5kOWPUcttJ3CbROjpdXRPbpQWmEyqZJsQGPyOYgDODsEjcuPYlrGk7cEgIxtdEu5d8qgH(uTOVxFPYhePCeuiww9QWhpaLHnQwacGVoRSrhVebQ0RpDvLvf2W50dJgQcttJ3CbRqYvdEnW0t1ScZ4HbnpkPcMIHkB0H2j5LiqLkVebQ8LRg8Q1fYt106cxFNkFGhYi0NQf996lv(GiLJGcXYQxf(4bOmSr1cqa81zLn64LiqLE9PZyLvf2W50dJgQcttJ3CbRm9u644ziXRcZ4HbnpkPcMIHkB0H2j5LiqLkVebQeYtPJJNHepRlCv7u5d8qgH(uTOVxFPYhePCeuiww9QWhpaLHnQwacGVoRSrhVebQ0RpDnuwvydNtpmAOkmnnEZfSYphXq5IbI(mYRcZ4HbnpkPcMIHkB0H2j5LiqLkVebQW(CedLlADIpJ8Q8bEiJqFQw03RVu5dIuockelREv4JhGYWgvlabWxNv2OJxIav61RcJa(to)1q9Ab]] )

    storeDefault( [[SimC Fury: movement]], 'actionLists', 20171203.205647, [[b4vmErLxt5uyTvMxtnvATnKFGzuDYLNo(bwBVzxzTvMB051utbxzJLwySLMEHrxAV5MxoDJmEnLuLXwzHnxzE5KmWeZnXidmZ4sm2qdnWyJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEnvqILgBPrxEEnfALj3BPn2xSvwyW51uj5gzPnwy09MCEnLBV5wzEnvtVrMvHjNtH1wzEnLxt5uyTvMxtHuzY9wAJ5hymvwyW51usvgBLf2CL5LtYatm3edmEnLuLn3B1j3yLnNxu5fDEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxt5fDErNxtruzMfwDSrNxc5fDE5f]] )

    storeDefault( [[SimC Fury: AOE]], 'actionLists', 20171203.205647, [[dWdffaGEjf1Muu1UKKTreSpsvmBjMpr0nfX3ue3wupwP2Pc7LA3e2VQ8tjfzyc1Vr5WsDEOObRsdNO6qKQItjPQJrkNJuv1cjvwku1Ivvlhvpuf1trwgrzDKQutKuvAQqLjly6qUiu40KCzW1fPnkPqBLizZqPTlKEUs(QKsnnIqFxiEMKs(SIYOvH5jPGtsKAusQCnsvY9ivv(RIkVwf5GksBnJZ0OZGjsLp)U1ykht9(DNwtyyIKdBvxu1CJumHhtKzcpuGEbEilwBIMS4AvPjbjkXyjyI2CLCKjtt3iftSmop0motyi6FbcwNjAZvYrM(PyXwbcEpdQcSiI3vsjFxEpdQ2PCoiqVBn8U6FSPPFvrHW00VWyb0HIVqMKweu7gX4MembykHfKQ5JodMmn6mysxHXcOdfFHmHhkqVapKfRnrl2eEyXs5ByzCgz68bSpLWIczqG83uclm6myYipKzCMWq0)ceSot0MRKJm9tXITce8EguXHCReR3vpVRS3D(3TU3T3ivuyoqazfSEx98UAVB9MM(vffctt)shGfIXZMKweu7gX4MembykHfKQ5JodMmn6mysxPdWcX4zt4Hc0lWdzXAt0InHhwSu(gwgNrMoFa7tjSOqgei)nLWcJodMmYJAzCMWq0)ceSot0MRKJm9tXITkdnAUDb6OaVkWIimn9RkkeMMICO4LikrWK0IGA3ig3KGjatjSGunF0zWKPrNbt1(qXlruIGj8qb6f4HSyTjAXMWdlwkFdlJZitNpG9PewuidcK)MsyHrNbtg5Henotyi6FbcwNjAZvYrM(PyXwLHgn3UaDuGxLk)DN)DR7D)PyXwbcEpdQcSiI3D(3vFExuxabQclNHouIzZ9b(c4NaEfi6FbcVRKs(U)uSyRY9A1BouLk)DLuY3L3ZGQDkNdc07Qh97D1IJF36nn9RkkeMM4DwEpdmjTiO2nIXnjycWuclivZhDgmzA0zWe(olVNbMWdfOxGhYI1MOfBcpSyP8nSmoJmD(a2NsyrHmiq(BkHfgDgmzKh6LXzcdr)lqW6mn9RkkeMM(fglGou8fYK0IGA3ig3KGjatjSGunF0zWKPrNbt6kmwaDO4l07wNw9MWdfOxGhYI1MOfBcpSyP8nSmoJmD(a2NsyrHmiq(BkHfgDgmzKhsW4mHHO)fiyDMM(vffcttrou8seLiysArqTBeJBsWeGPewqQMp6myY0OZGPAFO4Likr4DRtREt4Hc0lWdzXAt0InHhwSu(gwgNrMoFa7tjSOqgei)nLWcJodMmYit6lGTtliRZiBa]] )

    storeDefault( [[SimC Fury: execute]], 'actionLists', 20171203.205647, [[d8dVhaGAuG1RIOnrIQDPsTnve2hjs52k65KA2kz(cfUPqUm4BsfNhLANszVu7MW(rv)KernmPQXrIGtl4Xk1GrLHlsoOQItPI0XiPZrIsluOAPQWIvLLt0dvr9uOLrcRJejMijs1uvjtwHPJ4IsLEnkPNrIIRlQnQQKTIIAZIy7OettOuZtOOpls9DHs8xuOdlz0QQgVQsDsuKdjusxJeHUhjs6tKiYVrAuOG2Q(YyRMGrmmpZZ9vwYwPWZbFd7mbmIPGDOwHtwKav4whfgpGfuAWnf9QDuv0Rm3QNi2XU)egXTmKIy04NnjqfAF5MQVm2vuVfmCCJ4wgsrm(Yjj3jzgeGrPzmjlzFNtXZPCEUxoj5ojZGamknJjzj7BjmRGqZZftEofg)8cRaHTX3IshK)GutmYKye2fHknkOcWyeDWCjB1emASvtWy8fLoi)bPMy8awqPb3u0R2rT34bOPz5g0(YeJN)HnRruwGjii(zmIoA1emAIBk8LXUI6TGHJBe3YqkIXsscj1MCZGC60GuuzYniQ3cg8CkNNJH8CXkp3lNKCZGC60GuuzYDofpxmIbp3lNKCZGC60GuuzYTeMvqO55IjpNcEUt55Irm45E5KKBnHkag)HssUZPm(5fwbcBJW3WotaJmjgHDrOsJcQamgrhmxYwnbJgB1em29ByNjGXdybLgCtrVAh1EJhGMMLBq7ltmE(h2SgrzbMGG4NXi6OvtWOjUPm(Yyxr9wWWXnIBzifXiPwGGCNibXjzFdI6TGbpNY55E5KK7ejioj7BjmRGqZZftLkpNcJFEHvGW2yswgOznJ6vP)nYKye2fHknkOcWyeDWCjB1emASvtW4xzzGM18C4Q0)gpGfuAWnf9QDu7nEaAAwUbTVmX45FyZAeLfyccIFgJOJwnbJM4wS9LXUI6TGHJBe3YqkIXxoj5EwADTLWDofpNY55E5KKBqiR0WTeMvqO55IjpNQXpVWkqyBuwZuvAWitIryxeQ0OGkaJr0bZLSvtWOXwnbJh1mvLgmEalO0GBk6v7O2B8a00SCdAFzIXZ)WM1iklWeee)mgrhTAcgnXnLOVm2vuVfmCCJFEHvGW2i8nSZeWitIryxeQ0OGkaJr0bZLSvtWOXwnbJD)g2zcWZXq1tnEalO0GBk6v7O2B8a00SCdAFzIXZ)WM1iklWeee)mgrhTAcgnXTt4lJDf1Bbdh34NxyfiSnshSfAgtYs2gzsmc7IqLgfubymIoyUKTAcgn2QjyujpylusAEUVYs2gpGfuAWnf9QDu7nEaAAwUbTVmX45FyZAeLfyccIFgJOJwnbJM4whFzSROEly44g)8cRaHTX3IshK)GutmYKye2fHknkOcWyeDWCjB1emASvtWy8fLoi)bPMWZXq1tnEalO0GBk6v7O2B8a00SCdAFzIXZ)WM1iklWeee)mgrhTAcgnXnLGVm2vuVfmCCJ4wgsrmQbcJpQiRVjbqQQSmQi1MNtPXZ1B8ZlSce2gtYYanRzuVk9VrMeJWUiuPrbvagJOdMlzRMGrJTAcg)kld0SMNdxL(NNJHQNA8awqPb3u0R2rT34bOPz5g0(YeJN)HnRruwGjii(zmIoA1emAIBkRVm2vuVfmCCJFEHvGW2OSshePz8TOXIrMeJWUiuPrbvagJOdMlzRMGrJTAcgpQ0brAEU4lASy8awqPb3u0R2rT34bOPz5g0(YeJN)HnRruwGjii(zmIoA1emAIBQ9(Yyxr9wWWXn(5fwbcBJjzzGM1mQxL(3itIryxeQ0OGkaJr0bZLSvtWOXwnbJFLLbAwZZHRs)ZZXqfNA8awqPb3u0R2rT34bOPz5g0(YeJN)HnRruwGjii(zmIoA1emAIjgv6qsLxeh3eBa]] )


    storeDefault( [[Fury Primary]], 'displays', 20180208.182201, [[d4dliaGELQEjss7IiP2gsI6XOyMerFdjHzRKRrf6MeP8AaPBRIEoL2jf7vSBc7Nk5NQWWKQghrcxwXqjQbtvmCu5GsXNrQoMs54kvwOuzPeHftvTCsEivQNcTmQO1rKOjciMkctwLmDvDrvQRIKQNrKQRd0grITIKiBgvTDKYhPk5RuLIPHKY3LsJKkySuLsJgLgpG6KaClQs1Pj15r0HLSwIK8BqNTqeKP4EnuqbkE8jxtWdQtijaZDqMI71qbfO4r9(jMnNbvLG(4MDyaA6c6V07371c2g)GKh8825DxCVgkSX0he4dEE78UlUxdf2y6dUdCaNlamqbQ3pX4yFqllSTbuvae8W4hCh4aoxUlUxdf20feys3qbTr9Zv6csEWZBNNOu0N3gtFqllSfB1pdBZD6cAzHTnGpmDbplGrIy2c(LI(8ncgwOky3bbXH0KaGxoqeKmgV70PJbbogVlfodsEWZBNhiZQiJPpiWh8825bYSkYy6dAzHTeLI(820feO(ncgwOkiXHSea8YbIGxZQiPafpQ3pXS5miNsFwksamqHdJMo7hJJ9b1Ilnt9qvJGHfQckbaVCGi4Pw0a(Wy6dYuCVgkAemSqvWUdcIdPf8AwfjfO4dkt4YdwcRlpMsPGTbrUHrxl9(61qrmuHZGwwylsKUG7ahWbiA1W8AOiOea8YbIGcWtamqHngQfKtPplfjagOWB0xpBmo2huZafixXOf0JHAbTCZArzvww3WfufIGvmBb9Jzli9y2cQIzlFqllS1DX9AOWg)GaFWZBNVbuvX0hSavfbj3e0hKNpipu8bLjC5blH1LhtPuW2GxZQiPafp(KRj4b1jKeG5o4zbCd4dJPpO)sVFVxlyBZAf)G1IJTqwyRmT7y2cwlo2Yn80VEzA3XSfeidFbU(0fe4dEE78aexAM6HkBm9bRvBrALPjNUG00wTVEPFscsUjOFqMI71qrZstxe09TH4wIGxAl3Qiji5MGvWcuvae8qcsUjOpipFqvjOpeKCtWYxV0pzWcuvstlM0fCh4aoncgwOkOea8YbIGa1Ncu8OE)eZMZG7ahW5cadu4WOPZ(X4yFWAXXweLI(8Y0KJzlOAwbDFBiULiOLf2cKzvKbjU9wIGwUzTOSklB8dwlo2IOu0NxM2DmBb3boGZfaXLMPEOYMUGa1Ncu84tUMGhuNqsaM7GuDgUgl3W8suVgMUGM6Ccsbur6YJSsFwkYGFPOppfO4XNCnbpOoHKam3bVg(cC9nYsge1NUD5HcOIukD55A4lW1hCh4ao4tUMGsaWlhicsEWZBNNQD2y8(wWAXXwnR2I0kttoMTGaFWZBNNQD2y2cYP0NLIKcu8OE)eZMZGCQHbE6xFJSKbr9PBxEOaQiLsxE4udd80V(G1IJTCdp9RxMMCmBbplGBUJPpOLf2IT6NHTb8HPl4xk6Zlt7o(bTSWwzAYPlOeZAk7eJZ(nQyZzV0LAN9osLPgve0YcBP6q6RfxAbDB6cYap9RxM2D8d(LI(8Y0KJFWAXXwnR2I0kt7oMTGa1Ncu8bLjC5blH1LhtPuW2GwwylaXLMPEOYMUGKh8825Bavvm9bRvBrALPDNUGwwyBZD6cAzHTY0Utxqg4PF9Y0KJFWcuvncgwOky3bbXH0K8McrWAXXwilSvMMCmBb3bQzakvsBXNCnbRGNAbsetFWVu0NNcu8OE)eZMZG7ahWPrWWcvh8825JHAbzkUxdfuGIpOmHlpyjSU8ykLc2gSavfYnRfaGetFWBr5VMR0f0Qp5wtZXDmodkzzF3qbTrz1qrmo73KI(TnQj1spiWh8825jkf95TX0h8lf95PafFqzcxEWsyD5XukfSn4oWbCAwA6IZr8bzcYP0NLIeaduG69tmo2hK8GN3opaXLMPEOYgtFWtTO5ogPhuQGWt3qbTr9Zv6cQzGcPccpJr69b3boGZffO4r9(jMnNb3boGZfagOWB0xpBmo2hCh4aoxuTZMUGxZQiBemSqvqIdzjVPqeSavf1f6pi3Qihv(ea]] )

    storeDefault( [[Fury AOE]], 'displays', 20180208.182201, [[d4dkiaGELQEjQs2fQQyBijQdlzMOQCBvQzRKNHQQUjLcpgP(gLIonP2jf7vSBc7Ns1pvkdtQACsfXZPYqPKbtvmCu5GuvFgfoMuCCLkluLSuKulMOwojpKQ0tHwMuP1HQknraXuryYQOPRQlQcxfjPlR46aTrKyRijYMjY2rrFKsPVIQuMMur9DP0iLkmwPI0OrPXdOoja3cjHRHQ48i61asRfvP63GonHiiDX9AOGcu84tUMGBuLGpaMJGFPymVftRihuvcgJx2HgO5k4oWbC8xAgI7r8bPdsUjj5M3BX9AOWftFqG3KKCZ7T4Enu4IPpiNsFxksa0qbQ3pXWtFWBTW)ig(hCh4aoNElUxdfUCfeysVqbZr9ZzUcsUjj5MNOumM3ftFqhlSfB1pnR)rKd6yHT(GpmYbVlGrIyAcwGQcGqcsqYnbLbLKcsgdv0ytEckbfFqlc7EWs4S7XukfSni5MKKBEGmRImM(GaVjj5MhiZQiJPpOJf2sukgZ7YvqGk7lOzHQGeBwudW2oicEoRIKcu8OE)ett3GCk9DPibqdfDmAgSFm80hulo101dv(cAwOki1aSTdIGNJubUEFl(cI6BV29qburYV29Cosf46dsxCVgk8f0SqvWRncInBe8CwfjfO4dAry3dwcNDpMsPGTbrUHwxl9(61qrm2SBqhlSfjYvWDGd4aeTAOFnueKAa22brqb4naAOWftNdYP03LIeanuWB6ZNngE6d6yHTyR(Pz9bFyUc64M1IYQCSEHlOkebRyAcQIPjiJyAckhtt(GowyR3I71qHlYbbEtsYnVpOQIPpi5MKKBEFqvftFWDGd4CcGgk4n95Zgdp9bpNvrsbkE8jxtWnQsWhaZrW7cyFWhgtFq5LE)EBxWw)1kYbRfhBHSWwlMhX0eSwCSLx4TC9wmpIPjiqgPcC95kiWXqfDs3G1QTiDwmTYvqMANwwV0pjbj3euoiDX9AOWFPzic69WqCqDWtTJBvKeKCtq6GNZQi9f0SqvqInl(oOqeuvcgdbj3eSK1l9tgSavLn0Ijxb3boGJVGMfQcsnaB7GiiqLPafpQ3pX00n4oWbCobqdfDmAgSFm80hSwCSfrPymVftRyAcQMvqVhgIdQd6yHTazwfzqIJoLiOJBwlkRYXg5G1IJTikfJ5TyEettWDGd4CcqCQPRhQC5kiqLPafp(KRj4gvj4dG5iiVMHZ3Xn0p11RH5kOPUNGuavK294VDe8lfJ5Pafp(KRj4gvj4dG5iiWBssU551LlMMG7ahWbFY1eKAa22brqnnuGCfTwWigEcwlo2YF1wKolMwX0eCh4aoNaOHcuVFIHN(GCk9DPiPafpQ3pX00niNAOH3Y17BXxquF71UhkGks(1Uho1qdVLRpybQkKBwlaajM(G3fW(hX0h0XcBTyALRGFPymVfZJihK6znLBIPBFJnB62ZF(PBppu5oBZGowylVgszT4uly4Yvq5LE)EBxW2ihe4njj38aeNA66Hkxm9bj3KKCZdqCQPRhQCX0h8lfJ5PafFqlc7EWs4S7XukfSniWBssU5jkfJ5DX0h0XcBbio101dvUCf0XcB9bvfaHemYbRvBr6SyEKRGowyRfZJCf0XcB9pICqA4TC9wmTICWcuv(cAwOk41gbXMn47GcrqnnuW7q4Dm8Vp4oqnnqPsAh(KRjOCWBTajIPp4xkgZtbkEuVFIPPBWDGd44lOzHQnjj38XWtq6I71qbfO4dAry3dwcNDpMsPGTbRfhB5fElxVftRyAcEik51CMRGo9n3A83oIPBq(k37fkyokNgkIPBFtN0300z(H)bj3KKCZZRlxmurtq6I71qbfO4r9(jMMUbV1cFWhgtFqGktbk(Gwe29GLWz3JPukyBWVumM3xqZcvbV2ii2Sb1aSTdIG1IJT8xTfPZI5rmnb5Di82luWCu)CMRG1IJTqwyRftRyAcUdCaNtkqXJ69tmnDdsdVLR3I5rKdUdCaNtED5YvWcuveKCtqzqjPGfOQOQq)b5wf5OYNa]] )

    storeDefault( [[Arms Primary]], 'displays', 20180208.182201, [[d4dliaGEvOxIizxePyBic5XizMOuDBP0Sv01isUPcHxds8nfsEof7Ks7vSBc7NQ4NQOHPGXPqKlR0qjQbtvA4OYbPsFgLCmP44QGfkvwkkLftvTCsEiv0tHwMc16isPjcsAQGAYQutxvxuLCvePEgIORJWgjITIiuBgvTDe1hPc(krQAAkK67svJKk0yviQrJuJhK6KG4wiconPopkoSK1sKk)g40e4Guf3RbcjaXJpZCdEsAy2HyVcsvCVgiKaepQpUX2moOQeSwN0lfusxq)P(4rhMG(4hK5KN3SVZI71aHj2HGqFYZB23zX9AGWe7qWdelXEdHciq9XnwPgcAOb9UeQcIGhe)GhiwI92zX9AGWKUGqZ4eiiVQFVtxqMtEEZ(WLI1(MyhcAOb9yV(PODVsxqdnO3L4bPlyBbnchBtWVuS23vqrdub7oHHphbBqCWr4GmXscJj5qqOJLegPXbzo55n7d1DwmXoee6tEEZ(qDNftSdbn0GE4sXAFt6ccfFxbfnqfe(uMnio4iCW7DwmsaIh1h3yBghKtPBlfdekGWXvZI(JvQHGAXTMQEGYvqrdubzdIdochSvlCjEqSdbPkUxdeUckAGky3jm85icEVZIrcq8bLH94flHXJxBPuG(Gi3sPRP(y9AGi2r1e0qd6r40f8aXsSqvRwQxdebzdIdochuq0cHcimXo6GCkDBPyGqbesV((PJvQHGAkGa5kkTGvSsf0WTZPKzzODcMavGdwX2e0p2MGSITjOk2M8bn0GENf3Rbct8dc9jpVzFxcvf7qWIqvWmCBqFcE(G8aXhug2JxSegpETLsb6dEVZIrcq84Zm3GNKgMDi2RGTf0Uepi2HG(t9XJomb9UZz8dwto6cPb9YKVITjyn5OlNGw)6LjFfBtqOU8fX8txqOp55n7drCRPQhOmXoeSM9fJrMSC6cswB0(6P(zGz42G(bPkUxdeUtnlrqNxw4l2cERnCZIbMHBdwblcvbrWdGz42G(e88bvLG1cZWTblF9u)mblcvncTytxWdelX6kOObQGSbXbhHdcfFjaXJ6JBSnJdEGyj2BiuaHJRMf9hRudbRjhDbxkw7ltwo2MGQDg05Lf(ITGgAqpu3zXee(AKHdA425uYSm0Xpyn5Ol4sXAFzYxX2e8aXsS3qe3AQ6bkt6ccfFjaXJpZCdEsAy2HyVcsQD5CnCl1Zw9Aq6cAR2nORQ14XRSs3wkMGFPyTVeG4XNzUbpjnm7qSxbVx(Iy(UYShe1To941v1AKwpEVx(Iy(bpqSel(mZniBqCWr4GmN88M9jvNjwsOjyn5Ol3zFXyKjlhBtqOp55n7tQotSnb5u62sXibiEuFCJTzCqo1sbA9R3vM9GOU1PhVUQwJ06XlNAPaT(1hSMC0LtqRF9YKLJTjyBbT7vSdbn0GESx)u0UepiDb)sXAFzYxXpOHg0ltwoDbzBNBz2yhp0mQMXdKuAgpifjA0JkOHg0tQLXxlU1cwM0fKc06xVm5R4h8lfR9Ljlh)G1KJUCN9fJrM8vSnbHIVeG4dkd7XlwcJhV2sPa9bn0GEiIBnv9aLjDbzo55n77sOQyhcwZ(IXit(kDbn0GE3R0f0qd6LjFLUGuGw)6Ljlh)GfHQCfu0avWUty4ZrW(Le4G1KJUqAqVmz5yBcEGqtbfsS2GpZCdwbB1ceo2HGFPyTVeG4r9Xn2MXbpqSeRRGIgOo55n7hRubPkUxdesaIpOmShVyjmE8AlLc0hSiufYTZjeOg7qWlr5p370f0OB5MR75vSJdYEzENab5vz0arSJhAgPHMMrlnKmi0N88M9HlfR9nXoe8lfR9LaeFqzypEXsy841wkfOp4bILyDNAwI2v8bPcYP0TLIbcfqG6JBSsneK5KN3SpeXTMQEGYe7qWwTW9kwsgu6aGwNab5v97D6cQPacPdaAJLKdbpqSe7TeG4r9Xn2MXbpqSe7nekGq613pDSsne8aXsS3KQZKUG37SyCfu0avq4tz2VKahSiufPf6pi3Sywv(e]] )

    storeDefault( [[Arms AOE]], 'displays', 20180208.182201, [[d4dkiaGEjPxIIYUqrLTjjspgrZKizCePy2k6AOi3KivVwfLBRqpNu7Kk7vSBc7NQYpLudtb)g4YknuIAWuvnCu5GuQpJchtchxfzHQulfjAXuYYj5HuLEk0YajRJiLMOkQMkOMSkz6Q6IQWvrc9mQcUocBKi2ksq2mQA7iPpkj8vuu10qc8DjAKufnwKGA0i14bPojiULKOonfNhLoSuRvseFJQqNIahKS5EdqibiE8zNBWAkclfe3rqYM7naHeG4rt1nUcOcQAbJ1l9sEwUdAnnvRwXeugRGS1886992CVbi0Xnee6AEE9(EBU3ae64gcEIyj2liKabAQUXX0qqnnO0Mq1qe8Gyf8eXsSxEBU3ae6CheAwVab1v97vUdYwZZR3hUvm2xh3qqnnOelnpjT9rScQPbL2epiwbhBOr44kc(TIX(2csAGk4DnmCT0PesfEchKnUkx4rMccDCvwAGkiBnpVE)Z3zZg3qqOR5517F(oB24gcQPbLWTIX(6Ch8mlBbjnqfeUwMsiv4jCWRD2SsaIhnv34kGkiNYm2kwiKaHNRHb9hhtdbnIldz)aLTGKgOcsjKk8eo4Oryt8G4gcs2CVbiSfK0avW7Ay4APh8ANnReG4dkd7Zp2cTp)UwPaLbrUL00tt1(narCESiOMguIW5o4jILyp3OwY3aebPesfEchuqmcHei0Xrbb5uMXwXcHeiyEZ1thhtdbnKabY1KgbJ4ykOMBNtjZwt7fmbQahSJRiOvCfbzexrqvCf5dQPbLEBU3ae6yfe6AEE9(2eQoUHGnHQHz52Gwe88b5bIpOmSp)yl0(87ALcug8ANnReG4XNDUbRPiSuqChbhBOTjEqCdbTMMQvRyckTNZyfSNC0nsdkLPEexrWEYr3EbJw9lt9iUIGNV8nX8ZDqOR5517drCzi7hO0XneSNLnRwMQCUds1OnwMP5zHz52GwbjBU3ae2tddrqVho4dkdEz0CZMfMLBdsgSjunebpaMLBdArWZhu1cglml3gSTmtZZgSjuT0nIn3bprSeRTGKgOcsjKk8eo4zwsaIhnv34kGk4jILyVGqceEUgg0FCmneSNC0nCRySVmv54kcQ2zqVho4dkdQPbLNVZMni8bfgoOMBNtjZwthRG9KJUHBfJ9LPEexrWtelXEbrCzi7hO05o4zwsaIhF25gSMIWsbXDeKz7YzR5wYNY(nGCh01JBqB1O2NF76JGFRySVeG4XNDUbRPiSuqChbVw(My(2YsfenJE953wnQLwF(Vw(My(bprSel(SZniLqQWt4GS18869z2ToUkxeSNC0T9SSz1YuLJRii018869z2ToUIGCkZyRyLaepAQUXvavqo1scgT63wwQGOz0Rp)2QrT06ZpNAjbJw9hSNC0TxWOv)YuLJRi4ydT9rCdb10GsS08K02epi3b)wXyFzQhXkOMguktvo3bPCNBR34GAOWJfqn4bMdQbMQukWJb10GsMTSwgXLrWqN7GKGrR(LPEeRGFRySVmv5yfSNC0T9SSz1YupIRi4zwsaIpOmSp)yl0(87ALcugutdkHiUmK9du6ChKTMNxVVnHQJBiyplBwTm1JChutdkTpIvqnnOuM6rUdscgT6xMQCSc2eQ2wqsdubVRHHRLUuhsGd2to6gPbLYuLJRi4jcd5zuiJgF25g0k4OrGWXne8BfJ9LaepAQUXvavWtelXAliPbQAEE9(XXuqYM7naHeG4dkd7Zp2cTp)UwPaLbBcvJC7Cc584gcEiAR5EL7GAZi3CTRpIdQGs163lqqDvAdqehudfsZqrbfWCEii018869HBfJ91Xne8BfJ9LaeFqzyF(XwO9531kfOm4jILyTNggIXv8bjdYPmJTIfcjqGMQBCmneKTMNxVpeXLHSFGsh3qWrJW(iopeSsaGrVab1v97vUdAibIkbagJZddbprSe7LeG4rt1nUcOcEIyj2liKabZBUE64yAi4jILyVy2To3bV2zZAliPbQGW1YsDiboytOAkkmFqUzZUQ8ja]] )


end
