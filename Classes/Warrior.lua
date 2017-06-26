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


local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent

local storeDefault = ns.storeDefault


local PTR = ns.PTR or false

if (select(2, UnitClass('player')) == 'WARRIOR') then

    ns.initializeClassModule = function ()
    
        setClass( "WARRIOR" )
        --setSpecialization( "affliction" )

        -- Resources
        addResource( "rage", nil, false )
        
        setRegenModel( {
            mainhand = {
                resource = 'rage',

                spec = 'arms',
                setting = 'forecast_swings',

                last = function ()
                    local swing = state.swings.mainhand
                    local t = state.query_time

                    return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
                end,

                interval = 'mainhand_speed',

                value = function( x )
                    --if state.buff.doom_winds.expires > x then return 15 end
                    return 15
                end,
            }
        } )
        --setSpecialization( "fury" )

        -- Resources
        addResource( "rage" )

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

        -- Auras
        addAura( "avatar", 107574 )
        addAura( "battle_cry", 1719 )
        addAura( "berserker_rage", 18499 )
        addAura( "bloodbath", 12292 )
        addAura( "dragon_roar", 118000 )
        addAura( "enrage", 184361 )
        addAura( "enraged_regeneration", 184364 )
        addAura( "mastery_unshackled_fury", 76856 )
        addAura( "titans_grip", 46917 )
        -- Auras Arms
        addAura( "defensive_stance", 197690 )
        addAura( "die_by_the_sword", 118038 )
        addAura( "focused_rage", 207982 )
        addAura( "mastery_colossal_might", 76838 )
        addAura( "ravager", 152277 )
        addAura( "tactician", 184783 )

        -- Abilities
        -- Garrison Ability
        --[[  ]]

        addAbility( "garrison_ability", {
            id = 161691,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "garrison_ability", function ()
            -- proto
        end )

        -- Odyns Fury
        --[[ Unleashes the fiery power Odyn bestowed the Warswords, dealing (270% + 270%) Fire damage and an additional (400% of Attack power) Fire damage over 4 sec to all enemies within 14 yards. ]]

        addAbility( "odyns_fury", {
            id = 205545,
            spend = 0,
            cast = 0,
            gcdType = "on",
            cooldown = 45,
            min_range = 0,
            max_range = 0,
            usable = function () return equipped.warswords_of_the_valarjar and ( toggle.artifact_ability or ( toggle.artifact_cooldown and toggle.cooldowns ) ) end,
        } )        

         -- Bladestorm
        --[[ Become an unstoppable storm of destructive force, striking all targets within 8 yards with both weapons for 67,964 Physical damage over 5.6 sec.    You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks. ]]

        addAbility( "bladestorm", {
            id = 46924,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "bladestorm",
            cooldown = 90,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "bladestorm", function ()
            -- proto
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
        } )

        addHandler( "avatar", function ()
            -- proto
        end )        
        
        -- Battle Cry
        --[[ Lets loose a battle cry, granting 100% increased critical strike chance for 5 sec. ]]

        addAbility( "battle_cry", {
            id = 1719,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 60,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "battle_cry", function ()
            -- proto
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
        } )

        addHandler( "berserker_rage", function ()
            -- proto
        end )

      -- Bladestorm
        --[[ Become an unstoppable storm of destructive force, striking all targets within 8 yards for 240,620 Physical damage over 5.4 sec.    You are immune to movement impairing and loss of control effects, but can use defensive abilities and can avoid attacks. ]]

        addAbility( "bladestorm", {
            id = 227847,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 90,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "bladestorm", function ()
            -- proto
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
            -- proto
        end )


        -- Bloodthirst
        --[[ Assault the target in a bloodthirsty craze, dealing 13,197 Physical damage and restoring 4% of your health.    Generates 10 Rage. ]]

        addAbility( "bloodthirst", {
            id = 23881,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 4.5,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "bloodthirst", function ()
            -- proto
        end )


        -- Charge
        --[[ Charge to an enemy, dealing 2,675 Physical damage, rooting it for 1 sec and then reducing its movement speed by 50% for 6 sec.    Generates 20 Rage. ]]

        addAbility( "charge", {
            id = 100,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 20,
            charges = 1,
            recharge = 20,
            min_range = 8,
            max_range = 25,
        } )

        addHandler( "charge", function ()
            -- proto
        end )

        -- Cleave
        --[[ Strikes all enemies in front of you with a sweeping attack for 13,137 Physical damage. For each target up to 5 hit, your next Whirlwind deals 20% more damage. ]]

        addAbility( "cleave", {
            id = 845,
            spend = 9,
            min_cost = 9,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 6,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "cleave", function ()
            -- proto
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
            -- proto
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
            -- proto
        end )

        -- Defensive Stance
        --[[ A defensive combat state that reduces all damage you take by 20%, and all damage you deal by 10%. Lasts until cancelled. ]]

        addAbility( "defensive_stance", {
            id = 197690,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "defensive_stance",
            cooldown = 10,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "defensive_stance", function ()
            -- proto
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
            -- proto
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
            -- proto
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
            -- proto
        end )


        -- Execute
        --[[ Attempt to finish off a wounded foe, causing 30,922 Physical damage. Only usable on enemies that have less than 20% health. ]]

        -- Execute
        --[[ Arms Attempts to finish off a foe, causing 29,484 Physical damage, and consuming up to 30 additional Rage to deal up to 88,453 additional damage. Only usable on enemies that have less than 20% health.    If your foe survives, 30% of the Rage spent is refunded. ]]

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
        }, 5308 )

        modifyAbility( "execute", "id", function( x )
            if spec.fury then return 5308 end
            return x
        end )

        modifyAbility( "execute", "spend", function( x )
            if spec.fury then return 25 end
            return x
        end )
        
        modifyAbility( "execute", "min_cost", function( x )
            if spec.fury then return 25 end
            return x
        end  )

        addHandler( "execute", function ()
            -- proto
        end )

        -- Focused Rage
        --[[ Focus your rage on your next Mortal Strike, increasing its damage by 30%, stacking up to 3 times. Unaffected by the global cooldown. ]]

        addAbility( "focused_rage", {
            id = 207982,
            spend = 20,
            min_cost = 20,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            talent = "focused_rage",
            cooldown = 1.5,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "focused_rage", function ()
            -- proto
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
            -- proto
        end )


         -- Hamstring
        --[[ Maims the enemy for 15,326 Physical damage, reducing movement speed by 50% for 15 sec. ]]

        addAbility( "hamstring", {
            id = 1715,
            spend = 9,
            min_cost = 9,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "hamstring", function ()
            -- proto
        end )

        -- Heroic Leap
        --[[ Leap through the air toward a target location, slamming down with destructive force to deal 2,385 Physical damage to all enemies within 8 yards. ]]

        addAbility( "heroic_leap", {
            id = 6544,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 45,
            charges = 1,
            recharge = 45,
            min_range = 8,
            max_range = 40,
        } )

        addHandler( "heroic_leap", function ()
            -- proto
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
            -- proto
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
            -- proto
        end )

        -- Mortal Strike
        --[[ A vicious strike that deals 64,077 Physical damage and reduces the effectiveness of healing on the target for 10 sec. ]]

        addAbility( "mortal_strike", {
            id = 12294,
            spend = 18,
            min_cost = 18,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 5.423,
            charges = 1,
            recharge = 5.423,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "mortal_strike", function ()
            -- proto
        end )

       -- Overpower
        --[[ Overpowers the enemy, causing 54,736 Physical damage. Cannot be blocked, dodged or parried, and has a 60% increased chance to critically strike.    Your other melee abilities have a chance to activate Overpower. ]]

        addAbility( "overpower", {
            id = 7384,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "overpower",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "overpower", function ()
            -- proto
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
            -- proto
        end )


        -- Pummel
        --[[ Pummels the target, interrupting spellcasting and preventing any spell in that school from being cast for 4 sec. ]]

        addAbility( "pummel", {
            id = 6552,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 15,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "pummel", function ()
            -- proto
        end )


        -- Raging Blow
        --[[ A mighty blow with both weapons that deals a total of 10,204 Physical damage. Only usable while Enraged.    Generates 5 Rage. ]]

        addAbility( "raging_blow", {
            id = 85288,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "raging_blow", function ()
            -- proto
        end )


        -- Rampage
        --[[ Enrages you and unleashes a series of 5 brutal strikes over 2 sec for a total of 24,668 Physical damage. ]]

        addAbility( "rampage", {
            id = 184367,
            spend = 85,
            min_cost = 85,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 1.5,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "rampage", function ()
            -- proto
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
            -- proto
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
            -- proto
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

        addHandler( "shockwave", function ()
            -- proto
        end )


        -- Slam
        --[[ Slams an opponent, causing 44,530 Physical damage. ]]

        addAbility( "slam", {
            id = 1464,
            spend = 18,
            min_cost = 18,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "slam", function ()
            -- proto
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
            -- proto
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

        addHandler( "taunt", function ()
            -- proto
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
        } )

        addHandler( "victory_rush", function ()
            -- proto
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
        } )

        addHandler( "warbreaker", function ()
            -- proto
        end )


        -- Arms Whirlwind
        --[[ Unleashes a whirlwind of steel, striking all enemies within 8 yards for 39,410 Physical damage. ]]

        

        -- Whirlwind
        --[[ Unleashes a whirlwind of steel, striking all enemies within 8 yards for 8,348 Physical damage.    Causes your next Bloodthirst or Rampage to strike up to 4 additional targets for 50% damage. ]]

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
            -- proto
        end )

    end
   

    storeDefault( [[Fury Universal]], 'actionLists', 20170623.193911, [[di00qaqiQuQnjumkbYPeqVIkfXTOsrAxuXWaYXKuldaptOutdGY1Osj2Mav(grX4OsH6CuPKMhkLUhazFcuoOGAHavpeOmrQuGlIs1gfk5KuPAMOu0nb0orXpPsHSuI0tjnvIQRsLcARcWEv9xjzWeoSOfdYJPQjlXLH2Sq1NjIrtLCAkTAQuuVguz2uCBLA3i(TIHJsooavlhPNRKPl11fY2fKVdQA8Ou48GY6fOQ5tuA)O6xF5xzNKqgSCORm5gVgRikmUWnKydH0vAUkfnyUWZaaOAzafC1X2P(Q6Pww91RH9TDiRl)m1x(v2jjKblh8RQNAz1xdIlqapYYIfwC8djesLGepwnXRINnU4Iy4c)mMYapXbk72GvEkmhkUtlzXfSLlaGlcKlKvwUWT5ceWJSSyHfh)qcHujiXJvt8Q4zJlUigUiiUWT5c)mMYapXbk72GvEkmhkUtlzXfSfqCrniUqwz5c)mMYapXbk72GvEkmhkUtlzXfSLlaGlc8AyiRX2WUwOPKHurNKE1DsX6ZEOxjdbVcCkbKuMCJxVYKB8QBanLmeUq6K0RsrdMl8maaQwMAqxLIRjI6X1L)(kyUqpCaNq4gj9HUcCkm5gV((maC5xzNKqgSCWVQEQLvF1pJPmWtCGYUnyLNcZHI70swCbB5caJlIHl6KkbBhxyAAxoS8nxemUaaqxddzn2g2vAUzLsWRUtkwF2d9kzi4vGtjGKYKB86vMCJxLMBwPe8Qu0G5cpdaGQLPg0vP4AIOECD5VVcMl0dhWjeUrsFORaNctUXRVptSV8RStsidwo4xvp1YQVIaEKLflS4axg8bFAs2OkEKB2ILCvfpIcJlIHlGIIh3jEKB2ILCvfpIcZPmWtUggYASnSRqMzkTllD1xDNuS(Sh6vYqWRaNsajLj341Rm5gVcUzMs7Ysx9vPObZfEgaavltnORsX1er946YFFfmxOhoGtiCJK(qxbofMCJxFFga7YVYojHmy5GFv9ulR(kuu84oqz3gSYtH5qXDAjlUiyCrWXfYklx4NXug4joqz3gSYtH5qXDAjlUGTCrniUqwz5IG4IoPsW2PTBSQNQIf5c2YfbXf(zmLbEIdu2TbR8uyouCNwYIlCt4IAqCrGCrGxddzn2g21mu2j9Q7KI1N9qVsgcEf4uciPm5gVELj341WHYoPxLIgmx4zaauTm1GUkfxte1JRl)9vWCHE4aoHWns6dDf4uyYnE99zClx(v2jjKblh8RQNAz1x9Zykd8ehjMbknv(zmLbEIdf3PLS4caXfG4Iy4IoniPDOOhodUwvjuskdXbjjKblCrmCrqCbc4rwwSWIt0gIMMQ9mejM0gcxCrmCrqCblkgQAIhVsIV4eTHOPPApdrIjTHWfxiRSCrqCrtTe4W2XpJPmWtCO4oTKfxemUi2CrmCrtTe4W2XpJPmWtCO4oTKfxWwUWTcIlcKlcKlKvwUWT5ceWJSSyHfNOnennv7zismPneU4IaVggYASnSRqz3gSYtHD1DsX6ZEOxjdbVcCkbKuMCJxVYKB8k4z3gKlaJc7Qu0G5cpdaGQLPg0vP4AIOECD5VVcMl0dhWjeUrsFORaNctUXRVptWD5xzNKqgSCWVQEQLvF1pJPmWtCKygO0u5NXug4jouCNwYIlaexaIlIHl60GK2bYKfC1dD7GKeYGfUigUiiUi9TnewHeCBXLdKjl4Qh6UA7IlcgxuZfbEnmK1yByxHYUnyLNc7Q7KI1N9qVsgcEf4uciPm5gVELj34vWZUnixagfgxeuDGxLIgmx4zaauTm1GUkfxte1JRl)9vWCHE4aoHWns6dDf4uyYnE99zK5YVYojHmy5GFv9ulR(QFgtzGN4iXmqPPYpJPmWtCO4oTKfxaiUaexedxaffpUtHMsgsfDsQtelUigUiiUWpJPmWtCGmZuAxw6QDO4oTKfxaiUaexiRSCbuu84oiHMsqhkUtlzXfbJl8Zykd8ehiZmL2LLUAhkUtlzXfbEnmK1yByxHYUnyLNc7Q7KI1N9qVsgcEf4uciPm5gVELj34vWZUnixagfgxeeabEvkAWCHNbaq1Yud6QuCnrupUU83xbZf6Hd4ec3iPp0vGtHj3413NXn(YVYojHmy5GFv9ulR(kuu84ofAkziv0jPorS4czLLlCBUOtdsANcnLmKk6KuhKKqgSWfXWfqrXJ7aLDBWkpfMteRRHHSgBd7kKzMcu2UU6oPy9zp0RKHGxboLasktUXRxzYnEfCZmfOSDDvkAWCHNbaq1Yud6QuCnrupUU83xbZf6Hd4ec3iPp0vGtHj3413NXTE5xzNKqgSCWVQEQLvFfkkEChOSBdw5PWCIyDnmK1yByxHmZuQIhrHD1DsX6ZEOxjdbVcCkbKuMCJxVYKB8k4MzkCrSIOWUkfnyUWZaaOAzQbDvkUMiQhxx(7RG5c9WbCcHBK0h6kWPWKB867Zud6YVYojHmy5GFv9ulR(kuu84oqz3gSYtH5eX6AyiRX2WUcH0fsHZsKC1DsX6ZEOxjdbVcCkbKuMCJxVYKB8k4iDHu4SejxLIgmx4zaauTm1GUkfxte1JRl)9vWCHE4aoHWns6dDf4uyYnE99zQRV8RStsidwo4xvp1YQVstjOJpIsrsZfSLlOPe0zNSbx4MYfagORHHSgBd7As9jbR6HsrsF1DsX6ZEOxjdbVcCkbKuMCJxVYKB8AyQpjixiFOuK0xLIgmx4zaauTm1GUkfxte1JRl)9vWCHE4aoHWns6dDf4uyYnE99zQb4YVYojHmy5GFv9ulR(kuu84oqz3gSYtH5eXIlIHlsFBdHvib3wCXfaIlQVggYASnSR0isv6B7qQm2vF1DsX6ZEOxjdbVcCkbKuMCJx9Zykd8K1vMCJxLgr4IW(2oeUGnTRMlcQoWRHPswxj5gbKFgtzGNSUkfnyUWZaaOAzQbDvkUMiQhxx(7RG5c9WbCcHBK0h6kWPWKB8ASIOW4cWMXug4jR3NPo2x(v2jjKblh8RQNAz1x7KkbBhxyAAxoS8nxemUaaqCrmCrqCr6BBiScj42IlUGlaexeBUqwz5I032qyfsWTfxCbG4caJlc8AyiRX2WU6tJPk9TDivg7QV6oPy9zp0RKHGxboLasktUXRTlkIvDsLG96ktUXRGLgdxe232HWfSPD1xdtLSUsYncO2ffXQoPsWEDvkAWCHNbaq1Yud6QuCnrupUU83xbZf6Hd4ec3iPp0vGtHj341yfrHXfGzWmeYfX(9zQbSl)k7KeYGLd(v1tTS6RPVTHWkKGBlU4cUiyCbGDnmK1yByx9PXuL(2oKkJD1xDNuS(Sh6vYqWRaNsajLj341CWRm5gVcwAmCryFBhcxWM2vZfbvh41WujRRKCJakh8Qu0G5cpdaGQLPg0vP4AIOECD5VVcMl0dhWjeUrsFORaNctUXRXkIcJlc7gX(7Zu7wU8RStsidwo4xvp1YQV2jvc2oUW00UCy5BUGTCbaGUggYASnSR0isv6B7qQm2vF1DsX6ZEOxjdbVcCkbKuMCJxr2a9rnELj34vPreUiSVTdHlyt7Q5IGaiWRHPswxj5gbeYgOpQXRsrdMl8maaQwMAqxLIRjI6X1L)(kyUqpCaNq4gj9HUcCkm5gVgRikmUGD2a9rn((m1b3LFLDsczWYb)Q6Pww91oPsW2XfMM2LdlFZfbJlaa01WqwJTHDLgrQsFBhsLXU6RUtkwF2d9kzi4vGtjGKYKB86YsKyWQoPsW(ktUXRsJiCryFBhcxWM2vZfbf7aVgMkzDLKBeqllrIbR6Kkb7RsrdMl8maaQwMAqxLIRjI6X1L)(kyUqpCaNq4gj9HUcCkm5gVgRikmUqTejg897Rkl0BtJn4Z2oKZidaV)b]] )

    storeDefault( [[Fury AOE]], 'actionLists', 20170623.193911, [[dOJffaGEPOQnbvXUeY2KQW(GQ0Sf18HQ6Mc1TfzNkSxQDty)q5NsrPHjL(nIVPiESkgmKgUaoOuvNsLKJruNtkkwOGAPqyXk1Yr6HeHNIAzc0ZvYHLmviAYKA6Q6IksNxLYLbxxQSrPiARerBgQSDPWPj5RQKY0KIKVliptQIETkvJwrnpvs1jjsgLuLUMuu5EsrQpRs8xIuhskcBzJ08urTZG2BZJkbMBYo6nm0(n7uZiGmulWJGTYtA7HCpJKnZhQkWB2C)ZRiILr6HSrAEQO2zq7WM5dvf4nV7WHlce06cePjHeyO4JpgkTUarNokfepg61XqBMwZ93QS6VzENje9pROR3SucT6upHAwqeG5yIwYIoQey28OsG5Wzcr)Zk66nJaYqTapc2kprU1mcyr6OhyzK(nlXmCUhtAajq8EBoMOhvcm73JGgP5PIANbTdBMpuvG38UdhUiqqRlqefsLsSWqXlgAqmu8GH2lgADEvdqAqajfSI25sdRNqtsNMXqXlgQmg6vM7Vvz1FZ8oxAy9eAYSucT6upHAwqeG5yIwYIoQey28OsG5W5sdRNqtMrazOwGhbBLNi3AgbSiD0dSms)MLygo3JjnGeiEVnht0JkbM97rpnsZtf1odAh2mFOQaV5DhoCrjOEPpzOAa0injKWC)TkR(BMdnRO5qkH2SucT6upHAwqeG5yIwYIoQey28OsG5RnRO5qkH2mcid1c8iyR8e5wZiGfPJEGLr63SeZW5EmPbKaX7T5yIEujWSFpAkJ08urTZG2HnZhQkWBE3HdxucQx6tgQganQlagkEWq7fdD3HdxeiO1fistcjWqXdgAtGH(vgeFeok5NvIlsVb6cO3bAeiQDg0yO4Jpg6UdhUOuTw1HcrDbWqXhFmuADbIoDukiEmu820yOYTTyOxzU)wLv)nZ0kfOUaMLsOvN6juZcIamht0sw0rLaZMhvcmJOsbQlGzeqgQf4rWw5jYTMralsh9alJ0VzjMHZ9ysdibI3BZXe9OsGz)E0CgP5PIANbTdBU)wLv)nZ7mHO)zfD9MLsOvN6juZcIamht0sw0rLaZMhvcmhoti6FwrxpgAVYxzgbKHAbEeSvEICRzeWI0rpWYi9BwIz4CpM0asG492CmrpQey2Vh9Winpvu7mODyZ93QS6Vzo0SIMdPeAZsj0Qt9eQzbraMJjAjl6OsGzZJkbMV2SIMdPeAm0ELVYmcid1c8iyR8e5wZiGfPJEGLr63SeZW5EmPbKaX7T5yIEujWSF)M5aWrvzvZxVIi8ysq)2]] )

    storeDefault( [[Fury Cooldowns]], 'actionLists', 20170623.193911, [[d8tqlaGAvvKwpjvXMiq7IeBtvL0(iPOdt1ZiGmBkMVQkXnLKVbjDBiopPQDQk7vSBe7xr)uvfQHPGXPQc50uAzKkdwfdNqDqcYPiP0XiLZrsvzHsQwkKAXs1Yr6Heupf1JvPNlLprsv1ujKjlX0v6IQQ6Zk0LbxNO2ijf2krYMjITtK67KK(kjvPPPQcmpcWRLu(lKy0QkJxvL6KKehsvf11uvrCpcO(nuhxvf0OiPYrlIc)N4Ddusp8ZrGWQHmv)8imgBkyvjTWObd4nipDdAOo8RAcKIwy(sTI3WHf6UwmPfr5PfrH)t8UbkPEy(sTI3WRBaYQG4TMFPGcq8UbkZJGZtxwIefeV18lfuKfppcopDzjsuac1hbfkG4wsBEeW8OfwOU1yx9HPoIyFecRcPyV(IPHjyceUcxKYPphbch(5iqy0oIyFecJgmG3G80nOHQ2qy0qdltVqlIYgw4p4wRclnGaKn9Wv4YZrGWzZtxef(pX7gOK6H5l1kEdVoDewLpWn7NI47opcyE0nmpcopDzjsuac1hbfkG4wsBEeW8OfwOU1yx9H7gmUSFwABdRcPyV(IPHjyceUcxKYPphbch(5iq46gmUSFwABdJgmG3G80nOHQ2qy0qdltVqlIYgw4p4wRclnGaKn9Wv4YZrGWzZtGIOW)jE3aLupmFPwXBy4hkBflgkkfQlp(TOGLGsdlBAZJGZZfJnfSQeLc1Lh)wuWsqPHLnnfkG4wsBEeW8OnpcopDzjsu(PYJJaL4YRcfqClPnpcyEeO5rW5zD6iSkFGB2pfX3DEeGapp6gclu3ASR(WWVHR8cHvHuSxFX0WembcxHls50NJaHd)Cei8)Fdx5fcJgmG3G80nOHQ2qy0qdltVqlIYgw4p4wRclnGaKn9Wv4YZrGWzZ7herH)t8UbkPEy(sTI3WDzjsuac1hbfzXZJGZZfJnfSQefQpAjJO0nyvvOaIBjT5rnNNH5rW5zD6iSkFGB2pfX3DEuZ5r3qyH6wJD1hgx0tAOirMQpSkKI96lMgMGjq4kCrkN(CeiC4NJaH)Xf9e1FBEudzQ(WObd4nipDdAOQnegn0WY0l0IOSHf(dU1QWsdiaztpCfU8CeiC28(jru4)eVBGsQhMVuR4n860ryv(a3SFkIV78iabEE0newOU1yx9HHFdx5fcRcPyV(IPHjyceUcxKYPphbch(5iq4))gUYlmpQttTHrdgWBqE6g0qvBimAOHLPxOfrzdl8hCRvHLgqaYME4kC55iq4S59Rru4)eVBGsQhMVuR4n86gGSkwcbOOq9rqbiE3aL5rW5PllrIcqO(iOiloSqDRXU6dt9rlzeLUbRAyvif71xmnmbtGWv4Iuo95iq4WphbcJ2hTKX5PUbRAy0Gb8gKNUbnu1gcJgAyz6fAru2Wc)b3AvyPbeGSPhUcxEoceoBEOgrH)t8UbkPEy(sTI3WRBaYQqHBnd0AO4DNuWefG4DduMhbNNFEEw3aKvrcfVFwYikDG2aAnGQaeVBGY88l)Y8OU5zDdqwfju8(zjJO0bAdO1aQcq8UbkZJGZd1hbLRmLcKDEutbEE0ggMh1gwOU1yx9HPoIyFecRcPyV(IPHjyceUcxKYPphbch(5iqy0oIyFeMh1PP2WObd4nipDdAOQnegn0WY0l0IOSHf(dU1QWsdiaztpCfU8CeiC28(rru4)eVBGsQhMVuR4n86gGSky5TltBRcq8UbkZJGZtxwIefGq9rqPGvLmpcopDzjsu6(UgaLlvVIS4Wc1Tg7QpChOnGwdOOq9riSkKI96lMgMGjq4kCrkN(CeiC4NJaHRd0gqRb05bTpcHrdgWBqE6g0qvBimAOHLPxOfrzdl8hCRvHLgqaYME4kC55iq4S5P(IOW)jE3aLupmFPwXB4USejkaH6JGcfqClPnpcyE0MhbNNFEEw3aKvblVDzABvaI3nqjSqDRXU6d3nyCz)S02gwfsXE9ftdtWeiCfUiLtFoceo8ZrGW1nyCz)S02opQttTHrdgWBqE6g0qvBimAOHLPxOfrzdl8hCRvHLgqaYME4kC55iq4S5PnerH)t8UbkPEyH6wJD1hM6JwYikDdw1WQqk2RVyAycMaHRWfPC6ZrGWHFocegTpAjJZtDdw15rDAQnmAWaEdYt3GgQAdHrdnSm9cTikByH)GBTkS0acq20dxHlphbcNnpnTik8FI3nqj1dlu3ASR(WDdgx2plTTHvHuSxFX0WembcxHls50NJaHd)CeiCDdgx2plTTZJ60P2WObd4nipDdAOQnegn0WY0l0IOSHf(dU1QWsdiaztpCfU8CeiC2800frH)t8UbkPEy(sTI3WDzjsuuLc3AwYikD3yuKfppcopDzjsuac1hbfzXHfQBn2vFyv)SuJQwsjSkKI96lMgMGjq4kCrkN(CeiC4NJaHvVFwQrvlPegnyaVb5PBqdvTHWOHgwMEHweLnSWFWTwfwAabiB6HRWLNJaHZMNMafrH)t8UbkPEyH6wJD1hwIm1ILBO0mE7lSkKI96lMgMGjq4kCrkN(CeiC4NJaHvdzQfl3Mh24TVWObd4nipDdAOQnegn0WY0l0IOSHf(dU1QWsdiaztpCfU8CeiC2SHzXW16gR6XxlMKhQ6YMaa]] )

    storeDefault( [[Fury Execute]], 'actionLists', 20170623.193911, [[d0dOiaGAusTEeqBcLKDPcBtus2hjsA2k18fL4Mc6BsLUTsUmyNszVu7MW(rLFsIugMu14irHhRW5rPgmQA4c4GiItHaDms6CKO0cLkwQkAXQ0Yj6HispfAzKWZj1PfAQi0Kv00v1ffOdl5zKOQRlYgjrSvuOnlQ2okXNffZdb10eLuFhb41iQ(lky0OOXlk1jruoejk6AKOY9irIrHG8jsKQFJ0w1enguu3nm91yRwGrLKKS54dMnmspy8e2qPb3u0R2TpRuv(dvJ4qgd8gnsY4JuH2eDt1enguu3nmDhJ4qgd8gVP88J8eRJWS0mKNKSpsb44zfh)nLNFKNyDeMLMH8KK9HewvuO54jmhVcJKCJ74Z24DtPZNzuQFJKjMXr9uPrbvagdPtglzRwGrJTAbg7SP05Zmk1VXtydLgCtrVAx1EJNGMMKdqBI(nsktyqEiLfybI3xJH0zRwGr)UPWenguu3nmDhJ4qgd8gl5hZRXFW6uMmGuuP)ae1DdtoEwXXtioELjh)nLNFW6uMmGuuP)ifGJplzHJ)MYZpyDktgqkQ0FiHvffAoEcZXRGJNGC8zjlC83uE(H(PcGbMqj)JuaJKCJ74Z2iKnmspyKmXmoQNknkOcWyiDYyjB1cmASvlWyWSHr6bJNWgkn4MIE1UQ9gpbnnjhG2e9BKuMWG8qklWceVVgdPZwTaJ(Dt5nrJbf1Ddt3XioKXaVXV2G4pYLGGazFaI6UHjhpR44VP88JCjiiq2hsyvrHMJNWkfoEfgj5g3XNTX8KmstAg07sZ0izIzCupvAuqfGXq6KXs2Qfy0yRwGrLKKrAsZXJ7sZ04jSHsdUPOxTRAVXtqttYbOnr)gjLjmipKYcSaX7RXq6SvlWOF3YAt0yqrD3W0DmIdzmWBCqP7jLaeh36)nWWqY(qcRkk0C8eMJx5msYnUJpBJq2Wi9GrYeZ4OEQ0OGkaJH0jJLSvlWOXwTaJbZggPh44jKkbnEcBO0GBk6v7Q2B8e00KCaAt0VrszcdYdPSalq8(AmKoB1cm63nLZenguu3nmDhJ4qgd8gVP88JvP11qchPaC8SIJ)MYZpaHSYahsyvrHMJNWC8Qgj5g3XNTrzTcuzaJKjMXr9uPrbvagdPtglzRwGrJTAbgpRvGkdy8e2qPb3u0R2vT34jOPj5a0MOFJKYegKhszbwG491yiD2Qfy0VBzLjAmOOUBy6ogj5g3XNTriByKEWizIzCupvAuqfGXq6KXs2Qfy0yRwGXGzdJ0dC8esbbnEcBO0GBk6v7Q2B8e00KCaAt0VrszcdYdPSalq8(AmKoB1cm63TUMOXGI6UHP7yKKBChF2gVBkD(mJs9BKmXmoQNknkOcWyiDYyjB1cmASvlWyNnLoFMrP(54jKkbnEcBO0GBk6v7Q2B8e00KCaAt0VrszcdYdPSalq8(AmKoB1cm63nLHjAmOOUBy6ogXHmg4nQHNHlvK0hFeKQkldkcm44vQC89gj5g3XNTX8KmstAg07sZ0izIzCupvAuqfGXq6KXs2Qfy0yRwGrLKKrAsZXJ7sZKJNqQe04jSHsdUPOxTRAVXtqttYbOnr)gjLjmipKYcSaX7RXq6SvlWOF3uwt0yqrD3W0DmsYnUJpBJYktuKHH7MsagjtmJJ6PsJcQamgsNmwYwTaJgB1cmEwzIImC8D2ucW4jSHsdUPOxTRAVXtqttYbOnr)gjLjmipKYcSaX7RXq6SvlWOF3u7nrJbf1Ddt3XioKXaVXBkp)aeYkdCKcWXZkoEzLbogjPeephpH54v77nsYnUJpBJ0jBHMH8KKTrYeZ4OEQ0OGkaJH0jJLSvlWOXwTaJkTjBHsxZXRKKKTXtydLgCtrVAx1EJNGMMKdqBI(nsktyqEiLfybI3xJH0zRwGr)UPQAIgdkQ7gMUJrsUXD8zBmpjJ0KMb9U0mnsMygh1tLgfubymKozSKTAbgn2QfyujjzKM0C84U0m54jKccA8e2qPb3u0R2vT34jOPj5a0MOFJKYegKhszbwG491yiD2Qfy0VFJyayeRDKaRpsfU1vHFB]] )

    storeDefault( [[Fury Single]], 'actionLists', 20170623.193911, [[dWZViaGAkLy9uQytui7IeBJcv2hLsnBQmFkvDtQQBdPVPuANQyVIDd1(vyuKu(lvPXrHIEmehwQblPHtsoib6uKuDmk5CukPfQuSuvvlwjlNOhsiEkQLrbpxIZtvmvcAYkA6iUOkvNMuxgCDvzJuQ0wju2mfTDcvpJcv9vkuyAuOuZJsr(UkLxtaJwPA8uk0jjK(SQY1Oqj3JsbhIsrnmvYVr6yfHHVJ7LdMzf(0Oqy7(KEgvwJ)Cq4FWbDbYXWL12lJZY4vScZisTks4WcIq0uCjcZXkcdFh3lhmZMWmIuRIeE9mnvmF2IgMDXR5t6r5PAunAuxpttfZNTOHzx8A(KEuKaARXLr1MgvdHfCPDAINWlhLoj7AzHewu8uJ0eQmmMIHW(0PyT80Oq4WNgfcVXrPtYUwwiH)bh0fihdxwBTUc)df6tIaLimKWISdic4tfhqbmjRW(05PrHWHKJHim8DCVCWmBcZisTksys7amrXucy74rbW9YbZr1OrvTrD9mnvmLa2oEuM0B4r1E7h11Z0uXucy74rrcOTgxgvBYggvdJQ6HfCPDAINWMpPM(kElUUShwu8uJ0eQmmMIHW(0PyT80Oq4WNgfcB3NutFLrLDDzp8p4GUa5y4YAR1v4FOqFseOeHHewKDaraFQ4akGjzf2NopnkeoKCm(im8DCVCWmBcZisTks41Z0ubWY(duEQgvJgvs7amrrJXG0RS)afa3lhmdl4s70epHL9Ng)5D5O3clkEQrAcvggtXqyF6uSwEAuiC4tJcH)7pn(Bu34O3c)doOlqogUS2ADf(hk0NebkryiHfzhqeWNkoGcyswH9PZtJcHdjhJDeg(oUxoyMnHzePwfjmPLFarzhAhzxrfczuT9OAWAunAuvBuvBuxpttfal7pqzsVHhvJgvBEujTdWeftjLSRXFExGSasbaPcG7LdMJQ6JQ92pQRNPPcAxknIeuEQgv7TFuL9hOG8KsatgvBBdJQ111OQEybxANM4jSSrv1FqyrXtnstOYWykgc7tNI1YtJcHdFAui8FJQQ)GW)Gd6cKJHlRTwxH)Hc9jrGsegsyr2beb8PIdOaMKvyF680Oq4qYXyfHHVJ7LdMztygrQvrcVEMMkfcfdE3HwsuEQgvJgv1gv1gvs7amrrJXG0RS)afa3lhmhvJgvek1nP3WkY(tJ)8UC0BksaT14YOA7r1AuvFuT3(rD9mnvaSS)aLNQrv9WcU0onXtyWgbKhbclkEQrAcvggtXqyF6uSwEAuiC4tJcHVBJaYJaH)bh0fihdxwBTUc)df6tIaLimKWISdic4tfhqbmjRW(05PrHWHKJXfHHVJ7LdMztybxANM4j8YrPtYUwwiHffp1inHkdJPyiSpDkwlpnkeo8PrHWBCu6KSRLfYOQML6H)bh0fihdxwBTUc)df6tIaLimKWISdic4tfhqbmjRW(05PrHWHKZ2im8DCVCWmBcZisTks4cq8UO4xrHObPLT61GkKr12J61OA0OAZJkPDaMOOXyq6v2FGcG7LdMHfCPDAINWMpPM(kElUUShwu8uJ0eQmmMIHW(0PyT80Oq4WNgfcB3NutFLrLDDzFuvZs9W)Gd6cKJHlRTwxH)Hc9jrGsegsyr2beb8PIdOaMKvyF680Oq4qYXygHHVJ7LdMztybxANM4jSS)04pVlh9wyrXtnstOYWykgc7tNI1YtJcHdFAui8F)PXFJ6gh92OQML6H)bh0fihdxwBTUc)df6tIaLimKWISdic4tfhqbmjRW(05PrHWHKJTgHHVJ7LdMztygrQvrcVEMMk3KaIaA8N3v7CkpvJQrJ66zAQayz)bkpvHfCPDAINW321s3nnEgwu8uJ0eQmmMIHW(0PyT80Oq4WNgfcBm21s3nnEg(hCqxGCmCzT16k8puOpjcuIWqclYoGiGpvCafWKSc7tNNgfchsowxry474E5Gz2ewWL2PjEcB(KA6R4T46YEyrXtnstOYWykgc7tNI1YtJcHdFAuiSDFsn9vgv21L9rvndQh(hCqxGCmCzT16k8puOpjcuIWqclYoGiGpvCafWKSc7tNNgfchsiHzvaIUDA70enfNZwdHKa]] )

    storeDefault( [[Fury Cleave 3]], 'actionLists', 20170623.193911, [[dGJseaGEIQQnPsQDrkBtOQ2hrfMTG5lu5Ms42QQDQI9sTBO2pknkqOHjL(nHbJIHtKoiO4uQKCmH8njQfkrwQk1ILQLJQhcsEkYYekphIlRmvizYsA6axuk6XQYZabxNuTrIQYwjI2mrz7sHZds9vIkzAevX3brNMKdlA0GQXluLtse(lO01iQs3JOIETkXNHuhIOsTJmktnXzpSQ7Mo5FMKpDo0Smqfw2ySmqW09clrMpXAJk3g)iiOfzIECLuGjtW8akbgXO8jYOm1eN9WQUKj6XvsbM66YKPHae4bl8LCGMUutW0vbfaAtlE7PdMjjWv1lbcUjSaptfIQKj)K)zY0j)ZuZ4TNoyMUxyjY8jwBu5Owt3drOZFdXOmWeuW37sHOX(ddC3uHOEY)mzGpXmktnXzpSQlzIECLuGPUUmzA)LayFHLngxtxklZ1SmqKLbISmDDzY0gMNONwvajML5Awg5MLbKHHbAY4caCfgnS9Xrg)Y4AdN9WQSmxXYexCSmqKLHNON2tNZhgWYihYjltuBllZ1SmGmmmqtgxaGRWOHTpoY4xgxB4ShwLL5kwMRyzIlowMUUmzA)ebjF8PPl1emDvqbG2ep)st0ZKe4Q6Lab3ewGNPcrvYKFY)mz6K)z6o)st0Z09clrMpXAJkh1A6EicD(BigLbMGc(Exken2FyG7Mke1t(Njd8bcgLPM4Shw1LmrpUskWeiddd0uy84WYt0tB4Shw1emDvqbG2eprRWOHTheqAscCv9sGGBclWZuHOkzYp5FMmDY)mDNOvy0SmLccinDVWsK5tS2OYrTMUhIqN)gIrzGjOGV3LcrJ9hg4UPcr9K)zYaFKhJYutC2dR6sMGPRcka0M6bHOcGR4iatsGRQxceCtybEMkevjt(j)ZKPt(NPsbHOcGR4iat3lSez(eRnQCuRP7Hi05VHyugyck47DPq0y)HbUBQqup5FMmWh51Om1eN9WQUKjy6QGcaTjiHR4biv4QjjWv1lbcUjSaptfIQKj)K)zY0j)ZKCbxXdqQWvt3lSez(eRnQCuRP7Hi05VHyugyck47DPq0y)HbUBQqup5FMmWatK09uzqj)jqjW(uoMb2a]] )

    storeDefault( [[Arms Universal]], 'actionLists', 20170623.193911, [[dqKJtaqiuQOnrk6tcvfJcQsNcQIzjuLyxOyykvhtjwMu4zkjyAkj01qPQTjufFdQQXjuv5CcvjnpQsUhPs7tjPdkuwikLhskCrsfBeLk4KcvEPqvQMPsI6MkLDIk)uOQ0qrPs1srv9uktLu1vrPcTvQs9vHQQ2RQ)kKbtYHLSyO8ybtwuxgSzsPpJsgnu50uz1kjYRLsnBrUTuTBe)gYWrvookvklhPNty6kUov12Pk(Uu04rPsoVuY6fQsz(kP2pr)LR)MoKclb5JDJR6WTy0UqQyhjopavuPB8Heuc4Cn2xWFpEwwrMLBwG64n3UflmoerC9NB56VPdPWsq(SDZcuhV5gELk2Punvcidt5PMIYaKclbzPA9APcZxRwMYtnfLXNNuHhPstPcZxRwgSAMeefOTy85jvAkvzaZxRwMakHecFrKOxcCm(8KQ1RLQPOSGHzCDiAqrzhivEPRu1iEUfdZLCtRB8qJdrUfhj7c1GO3iicCBdL9UOCvhUHs5OMf9MHd1CdLDADavC2UXvD4g7oACiYTyuwIBKQd6Is5OMf9gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoCdLYrnl6NZ146VPdPWsq(SDZcuhV5gMVwTmy1mjikqBX4ZtQwVwQMIYcgMX1HObfLDGu5LUs1s8ClgMl5Mw3WsiuosRpT1T4izxOge9gbrGBBOS3fLR6WTBCvhUXwcHYsf7GpT1n(qckbCUg7l4VSFJpiq(0aiU(p30aheAVH8aDGmh72gkZvD42NZTcx)nDifwcYNTBwG64n3W81QLbRMjbrbAlgFEs161s1uuwWWmUoenOOSdKkV0vQwwUfdZLCtRByava02ocRBXrYUqni6ncIa32qzVlkx1HB34QoCJnGkaABhH1n(qckbCUg7l4VSFJpiq(0aiU(p30aheAVH8aDGmh72gkZvD42NZTIx)nDifwcYNTBwG64n3W81QLbRMjbrbAROmu5uROqL6mzutIuPPurlwatg06cUrQwvQwXDPstPkGqPmQjHbRMjbrbAlgk0lhrivRkv73IH5sUP1TIgkcenikfiZT4izxOge9gbrGBBOS3fLR6WTBCvhUfJgkciv6rukqMB8Heuc4Cn2xWFz)gFqG8PbqC9FUPboi0Ed5b6azo2TnuMR6WTpNJ9x)nDifwcYNTBwG64n3ciukJAsyyLqyvkkGqPmQjHHc9YresLxs1otd2lvAkv4vQ4rbprSczMfMakHecFrKOxcCs161sfpk4jIviZSW0SOyuOAduPcpsLMsvaHszutcdwQYGyq0odf6LJiKkDLQDPA9APAkklyygxhIguu2bsLx6kvSxQ0uQMIYcggCqLgCm8cJuTQu1y)wmmxYnTUHvZKGOaT1T4izxOge9gbrGBBOS3fLR6WTBCvhUXwntcKknOTUXhsqjGZ1yFb)L9B8bbYNgaX1)5Mg4Gq7nKhOdK5y32qzUQd3(CU456VPdPWsq(SDZcuhV5waHszutcdRecRsrbekLrnjmuOxoIqQ8sQ2zAWEPstPcVsfELk2Punvcidt5PMIYaKclbzPA9APkGqPmQjHP8utrzOqVCeHuTQUs1YUuHhPstPcVsfMVwTmcC1mafYrzqlqeGGXNNuTETufqOug1KW0SOyuOAdugk0lhrivRkv4lvAkvbekLrnjmbucje(IirVe4yOqVCeHuTQuHVuTETufqOug1KWeqjKq4lIe9sGJHc9Yres1Qs1UuPPuLbmFTAzcOesi8frIEjWXqHE5icPAvPIvilv4rQWJuPPunfLfmm4Gkn4y4fgPYlDLQg7s161s1uuwWWmUoenOOSdKkV0vQy)TyyUKBADdRMjbrbARBXrYUqni6ncIa32qzVlkx1HB34QoCJTAMeivAqBjv4Dbp34djOeW5ASVG)Y(n(Ga5tdG46)CtdCqO9gYd0bYCSBBOmx1HBFoh(x)nDifwcYNTBwG64n3ciukJAsyyLqyvkkGqPmQjHHc9YresLxs1otd2lvAkv4vQW81QLbRMjbrbAlgFEs161svaHszutcdwntcIc0wmuOxoIqQ8sQwyVuHhPA9APAkklyygxhIguu2bsLx6kvn2VfdZLCtRBLNAk6T4izxOge9gbrGBBOS3fLR6WTBCvhUfZtnf9gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoC7Z5IFx)nDifwcYNTBwG64n3a2nFhpEqMPTlTsfKbIicZNsCewrnDcCsLMsvgW81QLjGsiHWxej6LahJpVBXWCj306wBxALkidereMpL4iSIA6e4Ufhj7c1GO3iicCBdL9UOCvhUDJR6WT4Dxk(SsfKbs8rivS5tjoclPk(7e4UfJYsCJuDq32U0kvqgiIimFkXryf10jWDJpKGsaNRX(c(l734dcKpnaIR)ZnnWbH2BipqhiZXUTHYCvhU95CXRx)nDifwcYNTBwG64n3YaMVwTmuGKzOqVCeHu5LuXkKLknLQPOSGHbhuPbhdVWivRQRu1y)wmmxYnTUrbs(wCKSludIEJGiWTnu27IYvD42nUQd34dK8n(qckbCUg7l4VSFJpiq(0aiU(p30aheAVH8aDGmh72gkZvD42NZTSF930HuyjiF2UzbQJ3CdZxRwgSAMeefOTIYqLtTIcvQZqHE5icPAvPkGqPmQjHrlk4lGCeTybmuOxoIqQ0uQWRuH5RvlJwuWxa5iAXcyetfAlvEjvRGuTETufqOug1KW0r0PsrIH6AdmuOxoIqQwvQ2Lk8ClgMl5Mw30Ic(cihrlwWT4izxOge9gbrGBBOS3fLR6WTBCvhUXoGc(cilv8lwWn(qckbCUg7l4VSFJpiq(0aiU(p30aheAVH8aDGmh72gkZvD42NZTSC930HuyjiF2UzbQJ3Cldy(A1YeqjKq4lIe9sGJHc9YresLxsfRq(wmmxYnTUfqjKq4lIe9sG7wCKSludIEJGiWTnu27IYvD42nUQd30aLqcHVqQSEjWDJpKGsaNRX(c(l734dcKpnaIR)ZnnWbH2BipqhiZXUTHYCvhU95ClnU(B6qkSeKpB3Sa1XBULbmFTAzcOesi8frIEjWXqHE5icPYlPIvilvRxlv4vQMkbKHzCtrCHOUJfUHbifwcYsLMsfMVwTmcC1mafYrzqlqeGGjJAsKk8ClgMl5Mw3AwumkuTb6T4izxOge9gbrGBBOS3fLR6WTBCvhUf)lkgfQ2a9gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoC7Z5wwHR)MoKclb5Z2TyyUKBADJwEkwa9wCKSludIEJGiWTnu27IYvD42nUQd34xEkwa9gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoC7Z5wwXR)MoKclb5Z2nlqD8MBy(A1YG8auEOMaLXN3TyyUKBADd5bO8qnb6T4izxOge9gbrGBBOS3fLR6WTBCvhUfF9auEOMa9gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoC7Z5wy)1FthsHLG8z7MfOoEZTkmopqeqGUdes1Q6kvnKknLQPsazyenbGNJWksmuxBqWaKclb5BXWCj306g1NevHXHirjNyUfhj7c1GO3iicCBdL9UOCvhUfsq5bUXvD4gFFIuflmoerQwzNyUfJYsCJuDq3qckpWn(qckbCUg7l4VSFJpiq(0aiU(p30aheAVH8aDGmh72gkZvD4wmAxivAKGYd85ClXZ1FthsHLG8z7MfOoEZTkmopqeqGUdesLuTQUsf7LknLk2PunvcidJOja8CewrIH6AdcgGuyjiFlgMl5Mw3O(KOkmoejk5eZT4izxOge9gbrGBBOS3fLR6WTcb34QoCJVprQIfghIivRStmsfExWZTyuwIBKQd6wi4gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoClgTlKQyXxD(CUf8V(B6qkSeKpB3Sa1XBUnfLfmm4Gkn4y4fgPYlDLQg7sLMsvfgNhiciq3bcPYlPI93IH5sUP1nQpjQcJdrIsoXClos2fQbrVrqe42gk7Dr5QoCdyxqWFGBCvhUX3NivXcJdrKQv2jgPcVnWZTyuwIBKQd6cSli4pq8YuuwWe50Q7uuwWWGdQ0GJHxy8s3g7AwHX5bIac0DGGPjohn10rYEX(B8Heuc4Cn2xWFz)gFqG8PbqC9FUPboi0Ed5b6azo2TnuMR6WTy0UqQ0HDbb)b(CUL431FthsHLG8z7MfOoEZTPOSGHbhuPbhdVWivRkvn2VfdZLCtRBuFsufghIeLCI5wCKSludIEJGiWTnu27IYvD4MWryLGBCvhUX3NivXcJdrKQv2jgPcVRaEUfJYsCJuDqxHJWkb34djOeW5ASVG)Y(n(Ga5tdG46)CtdCqO9gYd0bYCSBBOmx1HBXODHuzocRe85ZnJheCvYfVvJdroh(lF(b]] )

    storeDefault( [[Arms AOE]], 'actionLists', 20170623.193911, [[dWtsjaGEKQsBscYUuQ2MeG9HuvnBrnFKKUjP8yHUTchwQDkP9sTBu2pj9tfPQHjrJdPQ4BkQoVsPbtQgUs4qivjNsrshtqNtcOfQuSuqzXGSCu9qLKvHuLAzkkpNOtlYubvtMW0bUOe6VkIlR66cmnKeTvKkBgPSDs03vs9vKe(SeuZtcKNjbQxtcJgjgVIeNej1OuKY1uKk3dPkEk0VrCqLODOHBSiRHYxyiJ1ECJl5dPQ(YPVOryp)wExNvgoVSacPY9qJyKNwamACzeKimPH7AOHBSiRHYx4ngXipTaymsizbznBc)DeyCjukNaBnoiCqNNib8KIBKAMifBaHBKry3OgrqxZR94gnw7XnQr4GoRQJaEsXnc753Y76SYW5HLgHDjjGhV0WnW4kkpQqJO8JZagYOgru7XnAGRZmCJfznu(cVXig5PfaJqb0OTlbe2Nq5nhShSW4sOuob2A8t5XaWnsntKInGWnYiSBuJiOR51ECJgR94gloLhda3iSNFlVRZkdNhwAe2LKaE8sd3aJRO8OcnIYpodyiJAerTh3ObUwWgUXISgkFH3yeJ80cGXiHKfK1S9ijtKYa5e5OLu25F0jMuvNEu1lv1lKQouanA7sknaC(fteN2zYl3fK1mv9cPQdfqJ2(c(Jj5Nib8KIl3fK1mJlHs5eyRXijtKYa5e5OLumsntKInGWnYiSBuJiOR51ECJgR94gxrYePmqQQJJwsXiSNFlVRZkdNhwAe2LKaE8sd3aJRO8OcnIYpodyiJAerTh3ObUsLgUXISgkFH3yeJ80cGrOaA02LuAa48lMioTZKxUliRzgxcLYjWwJRBoe)TIZnsntKInGWnYiSBuJiOR51ECJgR94gPIMdXFR4CJWE(T8UoRmCEyPryxsc4XlnCdmUIYJk0ik)4mGHmQre1ECJg460z4glYAO8fEJrmYtlagbD(mWoTZvs4ti0Ma1aq(7N1q5lu1lKQ(0u1fhkGgT9ijtKYa5e5OLu2dwOQtvQQQZ7c)DXPLIjGQEbPQpDLQ6tvvVqQ6ttvNEPQd68zGDAKyG8Ij8UWF)SgkFHQovPQQouanA7qnaK)KiF7eXBrE7KyNh7blu1Pkvv1HcOrBpMFR87blu1NQXLqPCcS14AkjEEDIjmsntKInGWnYiSBuJiOR51ECJgR94gPckjEEDIjmc753Y76SYW5HLgHDjjGhV0WnW4kkpQqJO8JZagYOgru7XnAGRfGHBSiRHYx4ngXipTayuCOaA025Nj25F0jMuvVGOhvDraVbjctvNERQxUxWgxcLYjWwJ8ZegPMjsXgq4gze2nQre018ApUrJ1ECJWotye2ZVL31zLHZdlnc7ssapEPHBGXvuEuHgr5hNbmKrnIO2JB0axNB4glYAO8fEJXLqPCcS1iuUfxci8HrQzIuSbeUrgHDJAebDnV2JB0yTh34MClUeq4dJWE(T8UoRmCEyPryxsc4XlnCdmUIYJk0ik)4mGHmQre1ECJg4k9XWnwK1q5l8gJlHs5eyRXy(TYBKAMifBaHBKry3OgrqxZR94gnw7XnUk)w5nc753Y76SYW5HLgHDjjGhV0WnW4kkpQqJO8JZagYOgru7XnAGRfOHBSiRHYx4ngXipTayK3f(7Xao)mGQo9RQxGLgxcLYjWwJFkpgaUrQzIuSbeUrgHDJAebDnV2JB0yTh3yXP8ya4Q6tlCQgH98B5DDwz48WsJWUKeWJxA4gyCfLhvOru(XzadzuJiQ94gnW1Wsd3yrwdLVWBmIrEAbWiVl83JbC(zavD6NEu1PYsJlHs5eyRX1us886etyKAMifBaHBKry3OgrqxZR94gnw7Xnsfus886etOQpTWPAe2ZVL31zLHZdlnc7ssapEPHBGXvuEuHgr5hNbmKrnIO2JB0axddnCJfznu(cVX4sOuob2AusHevSUvEJuZePydiCJmc7g1ic6AETh3OXApUrKcjQyDR8gH98B5DDwz48WsJWUKeWJxA4gyCfLhvOru(XzadzuJiQ94gnW1WzgUXISgkFH3yCjukNaBnkbe(ycejdmsntKInGWnYiSBuJiOR51ECJgR94graHpu13qYaJWE(T8UoRmCEyPryxsc4XlnCdmUIYJk0ik)4mGHmQre1ECJgyGrCXJPoNOVniryUop0aBa]] )

    storeDefault( [[Arms Cleave]], 'actionLists', 20170623.193911, [[dWZqjaGErK0MqczxaSnruSprKA2cnFKQUjj9yrDBfDyj7uQ2l1Ur1(jLrHePHPGXjIeFtjCErYGjXWfPoOs0PqI4yKQZjIqlujzPaAXk1Yr5HkKvjIiltH65coTuMkqnzIMoOlQK6VIWLvDDcTrreSvKkBgiBNaFhj1xrc1NrIAEIO0Zqc41e0OrkJxevDsKKPHe01erL7jIOEk0Hqc0VrS1nyJR51oEP3g718gxYMbnLrXxcUrGp(kC3hpOVyiz0Pqa6gXmRLgA04YmSr4bd2DDd24AETJx6vgxUBXgmLXjHbRyIaK1eEJuXLTCbjmJCc)gvjs6kwVM3OXEnVrvcdwrnfeYAcVrGp(kC3hpOVqFWiWhiIS8dgSHghr7zHQebFEo0BJQezVM3OHUp2GnUMx74LELrmZAPHg3IGabiaj8NG2lgeGyAJl3TydMY4t(NfH3ivCzlxqcZiNWVrvIKUI1R5nASxZBCDY)Si8gb(4RWDF8G(c9bJaFGiYYpyWgACeTNfQse855qVnQsK9AEJg6ofWGnUMx74LELrmZAPHg3IGabiqRGWZUmH8Gop8aajHAUMcfPPSfbbcqA2ZTWteGSMWhaijuZnUC3InykJzsKecIHeHzfOzKkUSLliHzKt43OkrsxX618gn2R5noIejHGyqtbNvGMrGp(kC3hpOVqFWiWhiIS8dgSHghr7zHQebFEo0BJQezVM3OHUtHgSX18AhV0RmIzwln04weeiabAfeE2LjKh05HhaijuZnUC3InykJuxSn7LWZmsfx2YfKWmYj8BuLiPRy9AEJg718gP4ITzVeEMrGp(kC3hpOVqFWiWhiIS8dgSHghr7zHQebFEo0BJQezVM3OHUNCgSX18AhV0RmIzwln0iRO8bKfzSZHAkjTMI(WGMc90RPSfbbcWUGW4tKzPsiFjJPsKR4eGyAJl3TydMYiiswmCzcwr5BKkUSLliHzKt43OkrsxX618gn2R5nMeizXWLAkalkFJaF8v4UpEqFH(GrGpqez5hmydnoI2Zcvjc(8CO3gvjYEnVrdDpzmyJR51oEPxzeZSwAOryfphca0zciSeeqj2fegpGZRD8snfkstHs1uKFlcceGmjscbXqIWSc0aiMwtHE61uyfLpa5b1YnOMsYQPKCdAkuIMcfPPqPAkuqnfyfphcaejlgUmbRO8bCETJxQPqp9AkBrqGaSlim(ezwQeYxYyQe5kobiMwtHE61u2IGabihFj4aetRPqjgxUBXgmLrQP1yrQBCPrQ4YwUGeMroHFJQejDfRxZB0yVM3iftRXIu34sJaF8v4UpEqFH(GrGpqez5hmydnoI2Zcvjc(8CO3gvjYEnVrdDFHbBCnV2Xl9kJyM1sdnk)weeiaSpRgpOPKSjznfPiRGncxtjjPPmaGcyC5UfBWugzNlnsfx2YfKWmYj8BuLiPRy9AEJg718gbEU0iWhFfU7Jh0xOpye4derw(bd2qJJO9SqvIGpph6TrvISxZB0q3tkgSX18AhV0RmUC3InykJ7yjFasytJuXLTCbjmJCc)gvjs6kwVM3OXEnVXvXs(aKWMgb(4RWDF8G(c9bJaFGiYYpyWgACeTNfQse855qVnQsK9AEJg6Es0GnUMx74LELXL7wSbtzmhFj4gPIlB5csyg5e(nQsK0vSEnVrJ9AEJJIVeCJaF8v4UpEqFH(GrGpqez5hmydnoI2Zcvjc(8CO3gvjYEnVrdDxFWGnUMx74LELrmZAPHgzfLpGSiJDoutjP1uOWbnf6PxtzlcceGC8LGdqmTXL7wSbtzKAAnwK6gxAKkUSLliHzKt43OkrsxX618gn2R5nsX0ASi1nUutHs1PeJaF8v4UpEqFH(GrGpqez5hmydnoI2Zcvjc(8CO3gvjYEnVrdDxx3GnUMx74LELXL7wSbtzmqJKfsDj4gPIlB5csyg5e(nQsK0vSEnVrJ9AEJinswi1LGBe4JVc39Xd6l0hmc8bIil)GbBOXr0EwOkrWNNd92Okr2R5nAO76JnyJR51oEPxzC5UfBWugdqcBMytIqJuXLTCbjmJCc)gvjs6kwVM3OXEnVresytnLvKi0iWhFfU7Jh0xOpye4derw(bd2qJJO9SqvIGpph6TrvISxZB0qdnIPFUvXwsTGnc39f6gAd]] )

    storeDefault( [[Arms Execute]], 'actionLists', 20170623.193911, [[dWdtkaGELQO2efv7IuTnOuSpOunBiMpPu3ujEmvUnGddANqAVs7MO9l0OOadtj9BeFdk58uOblYWfvhek6uuqhtqNtPkYcHclLGwmqlhPhsGwfPe1YOipNKttvtLqMmLMUIlQu5VcCzvxhQEgPe2kPWMvkBxuAAeGVRuvFMaAEkvjVwumosjYOjuJNIYjjf9tLQqxtPk4EKs6POoKsvQJdLs3WkQ8ojee52cwgfc8YysbuX0oZUdFEzHh5q1lQP1qSwXMqbOhwMDuF(uUmMUXtKQkQOHvu5DsiiYTfJYSJ6ZNYG4BB6GWzqEGJAuhppMmpMaX320Vz3HpEI8uvqo9oVYtK6Qb6YetAnMmftARDmbIVTPFZUdF8e5PQGC6DELNi1vd0LjM0AmzQmMGEe)ySmaHoqKa1q9zEznLwVdoeAzjr(YleRgqkke4LlJcbE5fcDGiXepuFMxw4rou9IAAneRW1YcVIGtDxvrDklO47YSqYEGlNcwEHyrHaVCNIAQIkVtcbrUTyuMDuF(ugeFBtheodYdCuJ645XK5XKbXK6tairIR0h)PMwdeqUlMWEmTgtARDmDSf3NNFR(i(bcKE4eOgcfqfCJpMmSmMGEe)ySmic0E1qOaL1uA9o4qOLLe5lVqSAaPOqGxUmke4LXabAVAiuGYcpYHQxutRHyfUww4veCQ7QkQtzbfFxMfs2dC5uWYlelke4L7uuTOIkVtcbrUTyuMDuF(ugeFBtheodYdCuJb2dTigdCqeaD88Yyc6r8JXY3S7WNxwtP17GdHwwsKV8cXQbKIcbE5YOqGxENz3HpVSWJCO6f10AiwHRLfEfbN6UQI6uwqX3LzHK9axofS8cXIcbE5ofvavu5DsiiYTfJYSJ6ZNYG4BB6GWzqEGJAuhppMmpMmiMuFcajsCL(4p10AGaYDXe2JP1ysBTJPJT4(88B1hXpqG0dNa1qOaQGB8XKHLXe0J4hJLbrG2RgcfOSMsR3bhcTSKiF5fIvdiffc8YLrHaVmgiq7vdHcetgeAyzHh5q1lQP1qScxll8kco1Dvf1PSGIVlZcj7bUCky5fIffc8YDk6EOIkVtcbrUTyuMDuF(ugeFBtheodYdCuJ6wY(YyY8yceFBtNK90CY(NQJNxgtqpIFmwMK90CY(NwwtP17GdHwwsKV8cXQbKIcbE5YOqGxEpM90CY(Nww4rou9IAAneRW1YcVIGtDxvrDklO47YSqYEGlNcwEHyrHaVCNIInvu5DsiiYTfJYSJ6ZNYG4BB6kXWzo92a73UuDLULSVSmMGEe)ySSJGqukCvGcaQexwtP17GdHwwsKV8cXQbKIcbE5YOqGxwqccrPWvXedavIll8ihQErnTgIv4AzHxrWPURQOoLfu8DzwizpWLtblVqSOqGxUtrXQIkVtcbrUTyuMDuF(ugeFBtxjgoZP3gy)2LQR0XZJjZJjdIjkuGx3HtPxoXe21AmjG1ysBTJjq8TnD1qKpq8H0rhppMmSmMGEe)yS8n7o85L1uA9o4qOLLe5lVqSAaPOqGxUmke4L3z2D4ZJjdcnSSWJCO6f10AiwHRLfEfbN6UQI6uwqX3LzHK9axofS8cXIcbE5ofvlvrL3jHGi3wmkZoQpFkFSf3NNFRoK6edZsKQaXhM1yGyO0gtMhtuOaVUdNsVCIP9kMWM1ysBTJjdIPbIC5O7LbBeAWi(bz8ii6xcbrUnMmpMaX320vIHZC6Tb2VDP6kDlzFzmzyzmb9i(XyzacDGibQH6Z8YAkTEhCi0YsI8LxiwnGuuiWlxgfc8Yle6arIjEO(mpMmi0WYcpYHQxutRHyfUww4veCQ7QkQtzbfFxMfs2dC5uWYlelke4L7u09ufvENecICBXOm7O(8PS9G4BB60lT60da9svmTxAnMS4u44jYyslhtR6ArmzEmnqQa)OpEGhmKaR)Xe2JjTOmMGEe)ySm9sBznLwVdoeAzjr(YleRgqkke4LlJcbEzHxAll8ihQErnTgIv4AzHxrWPURQOoLfu8DzwizpWLtblVqSOqGxUtrdxROY7KqqKBlgLzh1NpLbX320vIHZC6Tb2VDP6kDlzFzzmb9i(Xy5B2D4ZlRP06DWHqlljYxEHy1asrHaVCzuiWlVZS7WNhtgyYWYcpYHQxutRHyfUww4veCQ7QkQtzbfFxMfs2dC5uWYlelke4L7u0WWkQ8ojee52Irz2r95tzdIjOB8zFWLhWFvmftypMcJjdJjZJP9oMuFcajsCL(4p10AGaYDXe2JP1Yyc6r8JXYGiq7vdHcuwtP17GdHwwsKV8cXQbKIcbE5YOqGxgdeO9QHqbIjdmzyzmPcuv2lNtP45Jwdll8ihQErnTgIv4AzHxrWPURQOoLfu8DzwizpWLtblVqSOqGxUtNYC(DEiIFpdhprwuSc70ca]] )

    storeDefault( [[Arms Single]], 'actionLists', 20170623.193911, [[d0ZnnaGEvvv1MOQyxK02ivr7Juv(guQzly(eIBkQ(mvLUTsoSIDcv7vA3iTFk9tcfzyQkJJqrDELsNwKbtLHtIoePQ6uqjDmr5CQQQyHeKLsGfRklhXdjuTkvvvAzuv9CI(Rs1ujHjtX0HCrcQNI6YGRtv2OQQQSvsHndfBNu5zQQkFLqHMgPk9DLI5PQkVwvLrtknEsv4KKIESqxJqb3JqPdsi9BvgfuIBwvuwy68cGPVY4ZcklkzjToor9naLfabyKqX9)LH9NEMPx1SYCKKuIkxw0ikDuzvu8SQOSW05fatfQmhjjLOYppmyuFdcfG9izRQNsRZhRtcO93r9KQOeq8)TRxLrRtFw3xzrFPqcTT8lmgqIoYQSMutkoOJuMEuOC(z0yi4ZckxgFwqzHcJbKOJSklacWiHI7)ld7SVYca55rIGSkkQS4AH4V8thSakQVY5NbFwq5IkU)QOSW05fatfQmhjjLOYX7cMBdv9niua2JKTQeynjQ06(tSwNVrJ15J1zGNhgmQXlCsPNCxUgPwvcSMevAD6Z60ZYI(sHeABzYOB8fiL1KAsXbDKY0JcLZpJgdbFwq5Y4Zckly0n(cKYcGamsO4()YWo7RSaqEEKiiRIIklUwi(l)0blGI6RC(zWNfuUOI)VQOSW05fatfQmhjjLOYppmyuLAheciGz3ayaQeKQMBdTSOVuiH2woEHtk9K7Y1i1wwtQjfh0rktpkuo)mAme8zbLlJplOS4x4KspP1XRrQTSaiaJekU)VmSZ(klaKNhjcYQOOYIRfI)YpDWcOO(kNFg8zbLlQ46TkklmDEbWuHkZrssjQmwSoSyDOjauKkgGO7i7hM93GqbqfOZlagRZhRZappmyuJx4Ksp5UCnsTQeynjQ06(Z68nASoSADIiI1PFRdnbGIuXaeDhz)WS)gekaQaDEbWyD(yDyX6WI198WGrvIokSRfgcs1tP1jIiwx8UG52qvxhbnHDjIK(bQeynjQ06(tSwx8UG52qv9nCVjShVlyUnuvcSMevADy168X6EEyWOk1oieqaZUbWaujivn3gQ1HvRdRLf9Lcj02YBgYJaZpGuwtQjfh0rktpkuo)mAme8zbLlJplOSyCipcm)aszbqagjuC)FzyN9vwaippseKvrrLfxle)LF6Gfqr9vo)m4ZckxuXfdvrzHPZlaMkuzosskrL1V198WGr9niua2JKT7gymHT7XjSu9uAD(yDppmyuXCrpjy2jJVGQenXFw3Fw3)SoFSo9BDX7cMBdvnEHtk9K7Y1i1Q6P068X6WI1rgFb1OhHauK1PpXADz)7Z6ereRZappmyuJx4Ksp5UCnsTQMBd16ereRdnbGIuhQVazFn0XxybuKkqNxamwNpwx8UG52qvFdcfG9izRkbwtIkTU)eR1jMToSww0xkKqBlJ5IEsWStgFHYAsnP4Gosz6rHY5NrJHGplOCz8zbL)Fx0tcgRtW4luwaeGrcf3)xg2zFLfaYZJebzvuuzX1cXF5NoybuuFLZpd(SGYfvC9SkklmDEbWuHkZrssjQmbwtIkTU)eR19zDIiI1rG1KOsR7pRtmyD(yDX7cMBdv9niua2JKTQeynjQ06(Z68BD(yDyX6I3fm3gQ6lmgqIoYsLaRjrLw3FwNFRterSo9BDsaT)oQNufLaI)VD9QmAD6Z6(SoSww0xkKqBltaQPSMutkoOJuMEuOC(z0yi4ZckxgFwqzba1uwaeGrcf3)xg2zFLfaYZJebzvuuzX1cXF5NoybuuFLZpd(SGYfvCSRIYctNxamvOYCKKuIk)8WGrvIokSRfgcs1tzzrFPqcTTmOhq0dbL1KAsXbDKY0JcLZpJgdbFwq5Y4ZcklSEarpeuwaeGrcf3)xg2zFLfaYZJebzvuuzX1cXF5NoybuuFLZpd(SGYfvCXCvuwy68cGPcvMJKKsu5NhgmQsTdcbeWSBamavcsvpLwNiIyDppmyub9aIEO0rbICxjbIjz6OQMBdTSOVuiH2wEDe0e2Lis6huwtQjfh0rktpkuo)mAme8zbLlJplOC(rqtW6yej9dklacWiHI7)ld7SVYca55rIGSkkQS4AH4V8thSakQVY5NbFwq5Ik()PkklmDEbWuHkZrssjQ8Zddg13Gqbyps2QAUn0YI(sHeAB5thquEBasznPMuCqhPm9Oq58ZOXqWNfuUm(SGYIjDar5TbiLfabyKqX9)LHD2xzbG88irqwffvwCTq8x(Pdwaf1x58ZGplOCrfp7RkklmDEbWuHkZrssjQmbwtIkTU)eR1z8idkDuR7)ADFQ)RSOVuiH2wMautznPMuCqhPm9Oq58ZOXqWNfuUm(SGYcaQX6WsgwllacWiHI7)ld7SVYca55rIGSkkQS4AH4V8thSakQVY5NbFwq5IkEwwvuwy68cGPcvMJKKsu5jIs6GDGcReiTo9zDzwNiIyDOjauKkgGO7i7hM93GqbqfOZlaMYI(sHeAB5nAtKWMe1uwtQjfh0rktpkuo)mAme8zbLlJplOSyuBIe2KOMYcGamsO4()YWo7RSaqEEKiiRIIklUwi(l)0blGI6RC(zWNfuUOIN5VkklmDEbWuHkZrssjQ8erjDWoqHvcKwN1jwRlZ68X60V1HMaqrQyaIUJSFy2FdcfavGoVaykl6lfsOTLLHzvwtQjfh0rktpkuo)mAme8zbLlJplOmhMvzbqagjuC)FzyN9vwaippseKvrrLfxle)LF6Gfqr9vo)m4ZckxuXZ(xvuwy68cGPcvw0xkKqBlF6aIYBdqkRj1KId6iLPhfkNFgngc(SGYLXNfuwmPdikVnaX6WsgwllacWiHI7)ld7SVYca55rIGSkkQS4AH4V8thSakQVY5NbFwq5IkEMERIYctNxamvOYCKKuIkRFRtcO93r9KQOeq8)TRxLrRtFw3xzrFPqcTT8lmgqIoYQSMutkoOJuMEuOC(z0yi4ZckxgFwqzHcJbKOJSSoSKH1YcGamsO4()YWo7RSaqEEKiiRIIklUwi(l)0blGI6RC(zWNfuUOIkZkHyAcP))GshT4yNvula]] )


    storeDefault( [[Fury Primary]], 'displays', 20170623.193911, [[dSZWgaGEPuVejPDHOsBJQkMPusZwHBsj4WsUTs51sr2jv2Ry3e2VI0pvIHbL(nKNjfAOOyWkIHJuhuQSmQkhJQCCKuluQAPuIwmrTCkEOsQNcEmQ8CsnrQQ0uryYustxLlQOUQuWLv11HQnIiBfrf2mr2Us1hLsCAsMMuuFNsnsKeFgkgnknEeLtIe3IsORHOQZJQohvvTwev03usoEHiaxrFkKGesCWXp(alnq0kf3CGRmy(JzNjYbmLaZVM95Ak9bOg)X)UHcJy7fxaUa8lss6)wx0Ncj0XHnazlss6)wx0Ncj0XHnaTrTvgEkCibOA)X1m2aBkr3CCngGA8h)TUUOpfsOtFa(fjj9FeLbZF64WgqZISbB1XX2nN(aAwKDh(HsFGTImGioVaxzW8xNGJfzc0VqqSyblP0cvicWhswK8(wTYpn6V3kSn6ZpKVXgJKfBEvaYIRXvKBZ(7V)n7B1k)jFZEb0SiBIYG5pD6d0KCNGJfzcqSWyjLwOcraLWQIRoKPtWXImbSKsluHiaxrFkKOtWXImb6xiiwSqaG(5u1q1Uofse3kFb0SiBGi9bOg)XF)Qmp3PqIawsPfQqeqGVrHdj0X1Can9pgKgLMDnAGmHiqfNxa548cGjoVaM48YfqZISxx0Ncj0roazlss6)6WnvCydu4MIGN(diJljfyRiRd)qXHnG8q1UDldKD3ye5a1GMTawKnZ(CCEbQbnBTgTjxhZ(CCEb87lv4JlYbQHDXRz2zsFGDLwjRgQJNGN(dihGROpfs0nuyebwp7iMTmGvLMEu8e80FGkGPeyEcE6pqjRgQJpqHBklOeF6d0KmjK4av7popFbQbnBrugm)XSZeNxaZpcSE2rmBzan9pgKgLMnYbQbnBrugm)XSphNxaQXF83kfHvfxDiJo9bC12hGeUHF6egJARm8bUYG5psiXbh)4dS0arRuCZb2uIo8dfh2anjtcjo44hFGLgiALIBoa14p(BLchsaQ2FC(wfOg0Sv3WU41m7mX5fGSfjj9FuTxhNxaAJARm8KqIduT)488fG28COn566yAnajCd)0jniu7VrxJakoKGCIqBX5r(aBfzDZXHnGesCbyiMobkHE6exzmi7axzW8hZ(CKdO4qcGU4ucmX5lGMfzZSZK(aYdv72Tmq2roazlss6)OiSQ4Qdz0XHna)IKK(pkcRkU6qgDCydCLbZFKqIladX0jqj0tN4kJbzhGSfjj9FeLbZF64WgqZISPiSQ4Qdz0PpGMfz3HBkkcjuKdud7IxZSpN(aAwKnZ(C6dOzr2DZPpahAtUoMDMihOWnvNGJfzc0VqqSyHwNjreOWnfq)Jbf)gh2auJR4AICO0WXp(avGnLaiIdBGRmy(JesCGQ9hNNVafUPOiKqe80FazCjPaCf9PqcsiXfGHy6eOe6PtCLXGSdudA2AnAtUoMDM48cmlk5XBn9b0Qn6X3TmhNVa8lss6)6WnvCyd0KmjK4cWqmDcuc90jUYyq2bQbnB1nSlEnZ(CCEb4k6tHeKqIduT)488fGdTjxhZ(CKdOzr2u95LvcRkbgD6dy5p(s)X5dR3kS(bR)KRxanlYgSvhhBh(HsFGAqZwalYMzNjoVauJ)4VvsiXbQ2FCE(cWVijP)JQ964SOxaQXF83kv71PpG1xQWhxhtRbiHB4NoPbHA)n6AeOWnvdc1fGEu8Vjxc]] )

    storeDefault( [[Fury AOE Display]], 'displays', 20170623.193911, [[dStMgaGEPuVePKDruLETuWmLcnBfUjsrpgvUneoSKDsXEf7MW(LI(PuzyqLFdmofrAOO0GLsgoIoiL8zi6yuvhhPQfkvTuIklgjlNkpur6PQwMIQNtYerQ0uH0KjktxPlsvUksfxg01HYgrOTQiQ2mr2oc(OIWPj10iQQVtPgjsPEMIOmAumEfLtcvDlKcCnIQ48OQVHuO1QiITHuqh)GMZvKRgiice7x(bmVJoOnI34LZvKRgiice71THX4pp3vcKWPmqUgsFo1q3U9edGDOY57KKuWDArUAGqfdU8zDssk4oTixnqOIbxo9yqmOm8CaX1THXmFsZrOfwEXmz50JbXGYMwKRgiuPpNVtssbx0YHeUQyWLRya23wVCmwEHkxXaSTWwqOYvma7BRxoglSfK(8TCiHRLGJb4Y77qr7OPC4NG2O58XGlNVtssbxA1RIHg4NRya2OLdjCvPpVbklbhdWLJ2Xkh(jOnAUwitZvlWzj4yaUC5WpbTrZ5kYvdewcogGlVVdfTJM5NeYPRHUDTAGigACEUIbyF00NtpgedsxTdYTAGixo8tqB0Cbgc8CaHkg5NRiHJbXrPyMcgaxqZRy8ZDX4NJmg)CQy8ZMRya2tlYvdeQqLpRtssbxlmxfdU8cZvO8KWCkmjPCe1mlSfedUCQHUD7jgaBRXiu51GKPodWMLGxm(51GKPMcqqvllbVy8ZPluQWgBOYRHDXRyjWM(CcALMsp0lpkpjmNkNRixnqyn0if5t9mOEYLltRihfpkpjmVYDLajeLNeMxu6HE5ZlmxrtTaM(8gOice71THX4ppVgKmfA5qcxwcSX4N7GJ8PEgup5YvKWXG4OumHkVgKmfA5qcxwcEX4NtpgedkdVqMMRwGtL(CtHaMteZX3SLvNxZw0vRihfF(woKWLiqSF5hW8o6G2iEJxUmOuHnwl2gZjI54B2YQZlVbkIaX(LFaZ7OdAJ4nE5ZIbxEnizkRHDXRyjWgJFUeqS5SOnB9sOA2YuohWoN0PruoEIaXEDBym(ZZjDqoacQATyBmNiMJVzlRoV8AqYuNbyZsGng)Ce1mlVyWLJOMD0y8Z3YHeUSe8cvUIbyZsGn95YbhWsbJzooFAehn0x(YRFUIbytlipLwitlqQsF(woKWLLaBOY5aiOQLLGxOYRbjtznSlEflbVy8ZBGIiqS5SOnB9sOA2YuohWoxXaSXlKP5Qf4uPpNVtssbxlmxfdU8Ayx8kwcEPpxXaST8cvUIbyZsWl95Caeu1YsGnu5fMRSeCmaxEFhkAhnB0JiAEnizQPaeu1YsGng)C6X0Cnm5A1x(bmNkhHwC0yWLVLdjCjce71THX4ppVWCfEHeaLNeMtHjjLZvKRgiiceBolAZwVeQMTmLZbSZlmxDs4yGNUXGl3tuudOS0NR0iihqRoVyMNRya2wyUcVqceQ8zDssk4IwoKWvfdU8TCiHlrGyZzrB26Lq1SLPCoGDoFNKKcU4fY0C1cCQyWLpRtssbx8czAUAbovm4YPhdIbTgAKceqXMZLt60ikhpEoG462WyKpUCnhqCYItlqgJ8KR5aIjbaqeJV8KtpgedkJiqSx3ggJ)88zDssk4sREvm(50JbXGYOvVk95i0clSfedU8cZv0rO3CYrXdDzta]] )

    storeDefault( [[Arms Primary]], 'displays', 20170623.193911, [[dWtYgaGEPkVebzxusPTjfzMsrnBfoSKBIu44iLUTI6zsv1oPQ9k2nH9Ri9tLYWGW4Kc6BsPmuumyLKHJOdsPonPogQ6Cus1cLklLsYIjQLtXdvs9uWJrLNtYeLcmvinzkX0v5IkXvLcDzvDDKSrKQTsjfTzISDLQpkvLpdrttkX3PsJeb1YueJgLgpcCse6wifDnPuDEQ43qTwkPWRLs6Wh0aCf5PXc6yXbNZ4dS1iAZe9lbUYG8pMDMihWucK)A2NR10fGwQN6ThAKI5xCb4c4SjjP(BDrEASqfpIaeSjjP(BDrEASqfpIaKg9CzCiYHfGU3hFlicmRf2lX3FaAPEQ3Y6I80yHkDbC2KKu)HwgK)PIhrafl2fC1hhR9s6cOyXU2uhoDbMlca045dCLb5F2cowSjq3gk6gnSIyFegnGtOtZ2BNFcFdBQnR3wlwhbFd7ps0SL2cqqO3oFti6VHn1Et9Z3s7T1pIirZwSEafl2fTmi)tLUaTkBl4yXMaOBmwrSpcJgqlSO5QdBSfCSytaRi2hHrdWvKNglSfCSytGUnu0nAeaiFoDn09QtJfX3gFafl2fqtxaAPEQVbAZZDASiGve7JWObeuZe5Wcv8tcOi)XG(OuSRXdSjObQ45dihpFaKXZhWepFUakwS76I80yHkYbiytss9NnLPIhrGIYuOoKFazkjPaZfb2uhoEebKh6E96BGDThJihOgKSfWIDz2xINpqnizR14z56y2xINpqdEPIACroqnClhfZot6cSRvAz9qFoOoKFa5aCf5PXc7HgPiW6fp6IvbSOvKJYb1H8dubmLa5J6q(bkz9qFobkktrdT4txGwLPJfhO79XZpjqnizl0YG8pMDM45dy(rG1lE0fRcOi)XG(OuSroqnizl0YG8pM9L45dql1t9wikSO5QdBuPlGVM)a2Mz10vmg9CzCcCLb5F0XIdoNXhyRr0Mj6xcmRf2uhoEebAvMowCW5m(aBnI2mr)saAPEQ3croSa09(4N0uGAqYw2d3YrXSZepFac2KKu)rOov88bin65Y4qhloq37JNFsasZZHNLRZMP5a2Mz10vnk07VrvJaAoSWAGXZXZ3EG5Ia7L4reqclUamOtxbLqnDLVmgSBGRmi)JzFjYb0CybqwCAbY4NeqXIDz2zsxa5HUxV(gy3ihGGnjj1Fefw0C1HnQ4reWztss9hrHfnxDyJkEebUYG8p6yXfGbD6kOeQPR8LXGDdqWMKK6p0YG8pv8icOyXUefw0C1HnQ0fqXIDTPmfrHeoYbQHB5Oy2xsxafl2LzFjDbuSyx7L0fGdplxhZotKduuMYwWXInb62qr3OrZl0rduuMci)XGydIhraAP0CTAn1k4CgFGkWSwaOXJiWvgK)rhloq37JNFsGIYuefsyuhYpGmLKuaUI80ybDS4cWGoDfuc10v(YyWUbQbjBTgplxhZot88bweL84TKUak9m54T3wIFsaNnjj1F2uMkEebAvMowCbyqNUckHA6kFzmy3a1GKTShULJIzFjE(aCf5PXc6yXb6EF88tcWHNLRJzFjYbuSyxc9oYAHfTaPkDbS6hFP(4NGGVnenX3I1YhqXIDbx9XXAtD40fOgKSfWIDz2zINpaTup1BHowCGU3hp)KaoBssQ)iuNkEAYhGwQN6TqOov6cy5LkQXzZ0CaBZSA6Qgf693OQrGIYunk0xaYr58MCj]] )

    storeDefault( [[Arms AOE]], 'displays', 20170623.193911, [[dSdRgaGEjXlrvXUqvPxlrzMsKMTc3ekvhwQVjryBivTtkTxXUjA)ks)usnmuLFd5zsunuuAWkkdhjhKGpdfhJqNdkflujwkQQwmclNkpur1tbpgvEojturKPQutMuz6QCrjCvKcxwvxhrBKu1wveLntkBhQ6JkcNMIPjr03PkJePOLjjnAumEOKtcvUfukDnKsNNQ62kP1QiQoosLJy2b4AQZGK6rYdo)XhOMg7sXzlcCTdZFS4zdraxlX8ZzEUYYsa6iFYxyyWixF5fGlGFTMM6V5n1zqsvS8cGvTMM6V5n1zqsvS8cq5mRTZhhhscMkFSLKxGvJuOi2Ydqh5t(6M3uNbjvzjGFTMM6VD7W8NkwEbumipWZCCmcfHiGIb5jqEOqeyTXc2Xkg4AhM)eKCmixGL69Ug78JBcAUd4hRiFPNE6PVkTytjONw6RsBaSIfBlNVLxE5vPveBOTCXQ0gqXG82TdZFQSeOmcbjhdYfyxZYpUjO5oGrQZW1hYji5yqUa8JBcAUdW1uNbjfKCmixGL69Ug7baQNZ0dtL(mizSLqmGIb5b7SeGoYN8NKX9CNbjdWpUjO5oGKCfhhsQITKbuu)yOF0kM5ObYLDGowXaeXkgatSIbCXkMlGIb5nVPodsQcraSQ10u)jq66y5fOjD92N6dqqQPfyTXsG8qXYlaXWuPYedKNWyeIa9GIPbgKhl(Iyfd0dkMEoALOpw8fXkgysVwtoUqeOhETVIfpBwcG3OmeMH583(uFaIaCn1zqsHHbJmW8c7UG)a6mkQr7V9P(aDaxlX8BFQpqtygMZpqt6ASBKFwcugHEK8atLpwXQb6bftVBhM)yXZgRya3pcmVWUl4pGI6hd9JwXeIa9GIP3TdZFS4lIvmaDKp5RdNuNHRpKtLLa2E9di4wvtNjuxe4AhM)0JKhC(Jpqnn2LIZwey1ifipuS8cugHEK8GZF8bQPXUuC2Ia0r(KVoCCijyQ8XwL(a9GIPfgETVIfpBSIbWQwtt9hFwuXkgGYzwBNVEK8atLpwXQbOCphALOpb2sdi4wvtNjuxeWWHKtocTgRiTbwBSekILxanK8cWUNodAPA6mB7CiVax7W8hl(IqeWWHKavZzKyIL2akgKhlE2SeGyyQuzIbYlebWQwtt9hoPodxFiNkwEb8R10u)HtQZW1hYPILxGRDy(tpsEby3tNbTunDMTDoKxaSQ10u)TBhM)uXYlGIb5HtQZW1hYPYsafdYtG014KAOqeOhETVIfFrwcOyqES4lYsafdYtOieb4qRe9XINnebAsxli5yqUal17Dn2lTq)oqt6AG6hdCtkwEbOJ0Wv2KzuW5p(aebwnsyhlVax7W8NEK8atLpwXQbAsxJtQH2(uFacsnTaCn1zqs9i5fGDpDg0s10z225qEb6bftphTs0hlE2yfduiBIXRllbuMvQXluxeB1a(1AAQ)eiDDS8cugHEK8cWUNodAPA6mB7CiVa9GIPfgETVIfFrSIb4AQZGK6rYdmv(yfRgGdTs0hl(IqeqXG84Z7tyK6msmQSeG)F8T6JTkpXsWJEXsYxXakgKh4zoogbYdLLa9GIPbgKhlE2yfdqh5t(60JKhyQ8XkwnGFTMM6p(SOIfBfdqh5t(64ZIklb09An54eylnGGBvnDMqDrGM010qAUauJ2)D5sa]] )

   
end
