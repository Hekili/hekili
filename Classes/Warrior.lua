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

        setPotion( 'old_war' ) 
        -- Resources
        --addResource( "rage", nil, false )
        addResource( "rage", SPELL_POWER_RAGE, true )
        
        setRegenModel( {
            mainhandarms = {
                resource = 'rage',
                spec = 'arms',
                last = function ()
                    local swing = state.swings.mainhand
                    local t = state.query_time

                    return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
                end,
                interval = 'mainhand_speed',
                value = 3,
            },

            mainhandfury = {
                resource = 'rage',
                spec = 'fury',
                last = function ()
                    local swing = state.swings.mainhand
                    local t = state.query_time

                    return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
                end,
                interval = 'mainhand_speed',
                value = 3,
            },

            offhandfury = {
                resource = 'rage',
                spec = 'fury',
                last = function ()
                    local swing = state.swings.offhand
                    local t = state.query_time

                    return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
                end,
                interval = 'offhand_speed',
                value = 3
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
        addAura( "commanding_shout", 97463, "duration", 10 )
        addAura( "defensive_stance", 197690, "duration", 3600 )
        addAura( "die_by_the_sword", 118038, "duration", 8 )
        addAura( "dragon_roar", 118000, "duration", 8 )
        addAura( "enrage", 184362, "duration", 4 )
        addAura( "enraged_regeneration", 184364, "duration", 8 )
        addAura( "focused_rage", 207982, "duration", 30, "max_stack", 3 )
        addAura( "frenzy", 202539, "duration", 15, "max_stack", 3 )
        addAura( "frothing_berserker", 215571, "duration", 6 )
        addAura( "furious_charge", 202225, "duration", 5 )
        addAura( "hamstring", 1715, "duration", 15 )
        addAura( "intimidating_shout", 5246, "duration", 8 )
        addAura( "massacre", 206316, "duration", 10 )
        addAura( "mastery_colossal_might", 76838 )
        addAura( "mastery_unshackled_fury", 76856 )
        addAura( "meat_cleaver", 85739, "duration", 20 )
        addAura( "mortal_strike", 115804, "duration", 10 )
        addAura( "odyns_fury", 205546, "duration", 4 )
        addAura( "piercing_howl", 12323, "duration", 15 )
        addAura( "ravager", 152277 )
        addAura( "rend", 772, "duration", 8 )
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
            usable = function () return equipped.warswords_of_the_valarjar end,
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
            gcdType = "spell",
            cooldown = 60,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "battle_cry", "spend", function( x )
            if talent.reckless_abandon.enabled then return -100 end
            return x
        end )

        addHandler( "battle_cry", function ()
            applyBuff( "battle_cry" )
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
            if talent.outburst.enabled then applyBuff( "enrage", 4 ) end
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
        end )

        
        -- Charge
        --[[ Charge to an enemy, dealing 2,675 Physical damage, rooting it for 1 sec and then reducing its movement speed by 50% for 6 sec.    Generates 20 Rage. ]]

        addAbility( "charge", {
            id = 100,
            spend = -20,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 20,
            charges = 1,
            recharge = 20,
            min_range = 8,
            max_range = 25,
            usable = function () return target[ 'within'..25 ] and target[ 'outside'..8 ] end
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
            usable = function () return target.health_pct < 20 end,
        }, 5308 )

        modifyAbility( "execute", "id", function( x )
            if spec.fury then return 5308 end
            return x
        end )

        modifyAbility( "execute", "spend", function( x )            
            if spec.fury then return 25 end

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
                spend( min( addl_cost, rage.current ), "rage" ) 
                gain( ( action.execute.cost + addl_cost ) * 0.3, "rage" )
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
            gcdType = "spell",
            cooldown = 45,
            charges = 1,
            recharge = 45,
            min_range = 8,
            max_range = 40,
        } )

        modifyAbility( "heroic_leap", "cooldown", function( x )
            return x - ( talent.bounding_stride.enabled and 15 or 0 )
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
            return x * ( talent.dauntless.enabled and 0.9 or 1 ) 
        end )

        addHandler( "mortal_strike", function ()
            applyDebuff( "target", "mortal_strike" )
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
            -- proto
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
            -- Should we predict some rage gain?
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
        end )

    end
   

    storeDefault( [[SimC Arms: single]], 'actionLists', 20171203.130909, [[d4J7naGEubQnHkzxO02eKY(Oe6BOGhl0SPQ5RQQBQkDyr3wkNxsStOAVk7gX(j1prfKHbLghQG60s8xvXGjz4ushIsWPKKCmj15eKOfIQyPOOflvlhPhIkAvOcWYeuRdvaDzWurvnzQmDvUiQuFgf6zQkX1fyJOcKTsjAZqX2Pu(UQIVkiHPPQKMNQs9CkETQkJMs14fK0jfepL4Acs19qf6GOk9BiJssQx94pHBs29GB9j4zdMiLgNAfV0MHduRmfcJEyctWdPbgEyS1mGLHWHgB9eXkelPVWbNxbrgod1t4nEfeXm(dVE8NWnj7EWnEMirAX6nPhGbdBpVZdprAf2aRAfxALbUNoIeyyVcqdJ95RwJALf1kSt4Tx8LRYKUpDG5q02KqiUsmpeDcbrGjViNLjfpBWKj4zdMWJpDG5q02eMGhsdm8WyRzOg7eMGbfqJGz83nHt7q83lYg0aYT(KxKdpBWKDdp84pHBs29GB8mrI0I1BspadgwJ98oGcUhhGbigWW6qFit4Tx8LRYKiYJmMaZJPLg7tcH4kX8q0jeebM8ICwMu8SbtMGNnycNipYycmAL0sJ9jmbpKgy4HXwZqn2jmbdkGgbZ4VBcN2H4VxKnObKB9jVihE2Gj7g(xg)jCtYUhCJNjsKwSEtoeJm6b2KEfmz80kU0QQ1QQ1QQ1Ql9a5yXauBi6dcZtpVZdSaj7EWPvCPvoOhGbdBe5rgtG5X0sJDwk0YcXOvFRvmgDAvvA1))ALf0Ql9a5yXauBi6dcZtpVZdSaj7EWPvCPvvRvvRv9amyynhIap2HKESbw1Q))1Qic5DOpe2gIEP)XC0YpGLcTSqmA13CuRIiK3H(qyz0J6P)jIqEh6dHLcTSqmAvvAfxAvpadgwJ98oGcUhhGbigWW6qFiAvvAvvAvvt4Tx8LRYKpjTtH8hqNecXvI5HOtiicm5f5SmP4zdMmbpBWKqrs7ui)b0jmbpKgy4HXwZqn2jmbdkGgbZ4VBcN2H4VxKnObKB9jVihE2Gj7g(xh)jCtYUhCJNjsKwSEtSGw1dWGHTN35HNiTYJdsNVYtm9n2aRAfxAvpadgwmOyGbCp0KrG1Cz8Nw9Tw9fTIlTYcAveH8o0hcBe5rgtG5X0sJD2aRAfxAv1AfnzeyJbukqoTYICuRQ)cwT6)FTYb9amyyJipYycmpMwASZ6qFiA1))A1LEGCSjHrG(0ssYi0aYXcKS7bNwXLwfriVd9HW2Z78WtKwHLcTSqmA13CuR4WAvvt4Tx8LRYemOyGbCp0KrysiexjMhIoHGiWKxKZYKINnyYe8Sbt4GqXad40kMjJWeMGhsdm8WyRzOg7eMGbfqJGz83nHt7q83lYg0aYT(KxKdpBWKDdp0h)jCtYUhCJNjsKwSEtOqlleJw9nh1kgJoT6)FTIcTSqmA13AvORvCPvz8kicBpVZdprAfwGKDp40kU0Qic5DOpe2EENhEI0kSuOLfIrR(wRcRvCPvvRvreY7qFiSDF6aZHOnwk0YcXOvFRvH1Q))1klOvg4E6isGH9kanm2NVAnQvwuRWQvvnH3EXxUktOaXnjeIReZdrNqqeyYlYzzsXZgmzcE2GjmbIBctWdPbgEyS1muJDctWGcOrWm(7MWPDi(7fzdAa5wFYlYHNnyYUHhAJ)eUjz3dUXZejslwVjz8kicBpVZdprAfwGKDp40kU0Qic5DOpe2EENhEI0kSuOLfIrR(MJAfJrNwXLw5GEagmSrKhzmbMhtln2zPqlleJwzrTk0MWBV4lxLj00wYiqNecXvI5HOtiicm5f5SmP4zdMmbpBWeMPTKrGoHj4H0adpm2AgQXoHjyqb0iyg)Dt40oe)9ISbnGCRp5f5WZgmz3Wzy8NWnj7EWnEMirAX6nPhGbdR5qe4XoK0JnW6eE7fF5QmbcvigCWKqiUsmpeDcbrGjViNLjfpBWKj4zdMWDOcXGdMWe8qAGHhgBnd1yNWemOaAemJ)UjCAhI)Er2GgqU1N8IC4zdMSB4C4XFc3KS7b34zIePfR3KEagmS98op8ePvyDOpKj82l(YvzcYgqTI(a0jHqCLyEi6ecIatEroltkE2GjtWZgmHdzdOwrFa6eMGhsdm8WyRzOg7eMGbfqJGz83nHt7q83lYg0aYT(KxKdpBWKDdpuo(t4MKDp4gptKiTy9M0dWGH1ypVdOG7XbyaIbmSbw1Q))1QEagmSqOcXGRGia18yLcXIPGiSo0hYeE7fF5QmPHOx6FmhT8dMecXvI5HOtiicm5f5SmP4zdMmbpBWKxe9sVwjhT8dMWe8qAGHhgBnd1yNWemOaAemJ)UjCAhI)Er2GgqU1N8IC4zdMSB41yh)jCtYUhCJNjsKwSEtOqlleJw9nh1kxanVcIOvCaAfw2VmH3EXxUktOaXnjeIReZdrNqqeyYlYzzsXZgmzcE2GjmbItRQUUQjmbpKgy4HXwZqn2jmbdkGgbZ4VBcN2H4VxKnObKB9jVihE2Gj7gED94pHBs29GB8mrI0I1BsgVIn4biqRagTYIAvTw9)VwDPhihlgGAdrFqyE65DEGfiz3dUj82l(YvzYh7fQ)tH4MecXvI5HOtiicm5f5SmP4zdMmbpBWKqH9c1)PqCtycEinWWdJTMHAStycguancMXF3eoTdXFViBqdi36tEro8Sbt2n86WJ)eUjz3dUXZejslwVjz8k2GhGaTcy0koQv1AfxALf0Ql9a5yXauBi6dcZtpVZdSaj7EWPvCPvvRv0KrGngqPa50klYrTk0dRv))RvwqRU0dKJLcehlqYUhCA1))ALf0Ql9a5yPPTKrGYcKS7bNwv1eE7fF5QmX4Z2KqiUsmpeDcbrGjViNLjfpBWKj4zdMi(SnHj4H0adpm2AgQXoHjyqb0iyg)Dt40oe)9ISbnGCRp5f5WZgmz3WR)Y4pHBs29GB8mH3EXxUktq2aQv0hGojeIReZdrNqqeyYlYzzsXZgmzcE2GjCiBa1k6dq1QQRRActWdPbgEyS1muJDctWGcOrWm(7MWPDi(7fzdAa5wFYlYHNnyYUHx)1XFc3KS7b34zIePfR3elOvg4E6isGH9kanm2NVAnQvwuRWoH3EXxUkt6(0bMdrBtcH4kX8q0jeebM8ICwMu8SbtMGNnycp(0bMdrBAv11vnHj4H0adpm2AgQXoHjyqb0iyg)Dt40oe)9ISbnGCRp5f5WZgmz3UjsKwSEt2Tb]] )

    storeDefault( [[SimC Arms: default]], 'actionLists', 20171203.130909, [[da04naqiuLSiqWMevgfH4uesZcvPKDbQHPQCmqAzuupdvPQPjQIRrqABee(gb14evP6COkfwhi08ev19qvSpsjhev1cjL6HkvDrsrBevPOtQu0mji6MeyNKQFIQuzOIQuwkf5Punvr0wvkSxO)sHbR4WQSyu5Xcnzv5YiBwe(SQQrRu60K8AsHzl42kz3O8BGHtOworpNstxY1fLTls9Dq04fvjNxKSEuLsnFLk7xQrOys01KDCb6HCORFlcDxT23dF5YcXEEuIlluOBIc0zju38huH)e2SqadfDxmfvxqXBFLcWqDHHIo)yPamlMe1HIjrxt2XfOhQn685ubvLc942t(tOVj7PIxbKOZamcDbG3gNu)we6ORFlc99Bp5pHUjkqNLqDZFqfg6h6MilitgjlMel03VLIAiaKMweRqo0faE63Iqhlu3mMeDnzhxGEO2O7rPsCHEb()deSyqPamBp56rKEePhE1tDbIvWx6RojmXoUa96z3UE4YsKa(sF1jHZe3JO9KRhUSejG5UQcKruMcotCp565rCzjsahbbG1MznSRZUfotCp721tDYFQGl1ImkGXtr9Kpp9ywi6ru05ZPcQkf6IbLcWqFt2tfVcirNbye6caVnoP(Ti0rx)we65nqPam05l)TOZUfXdeaHNbKNecOBIc0zju38huHH(HUjYcYKrYIjXc99BPOgcaPPfXkKdDbGN(Ti0bHNbKNeluN3Jjrxt2XfOhQn6EuQexOxG))abhbGWdajZ2tUEePhUSejG5UQcKruMcotCp721tDYFQGl1ImkGXtr9Kpp9avi6ru05ZPcQkf6Cba4zKitMc9nzpv8kGeDgGrOla824K63IqhD9BrORDaaE9WBMjtHUjkqNLqDZFqfg6h6MilitgjlMel03VLIAiaKMweRqo0faE63Iqhluppys01KDCb6HAJUhLkXf6f4)pqWrai8aqYS9KRhr6HllrcyURQazeLPGZe3ZUD9uN8Nk4sTiJcy8uup5ZtpqH2JOOZNtfuvk05iPLKAOy)OVj7PIxbKOZamcDbG3gNu)we6ORFlcDTjPLKAOy)OBIc0zju38huHH(HUjYcYKrYIjXc99BPOgcaPPfXkKdDbGN(Ti0Xc1fkMeDnzhxGEO2O7rPsCHoxwIeWCxvbYiktz8O7fszeVWc(bGK1tUEK3pb)OeQOQ6rREYZxp56jcaHhasgm3vvGmIYuWsADkMThT65dD(CQGQsH(jJhJmkGusSc9nzpv8kGeDgGrOla824K63IqhD9BrOZxgpg1tsGusScDtuGolH6M)Gkm0p0nrwqMmswmjwOVFlf1qainTiwHCOla80VfHowOUqGjrxt2XfOhQn6EuQexOxG))abhbGWdajZ2tUEePNiaeEaizW)ba3fmIaq4bGKblP1Py2EYVNpyZcTNC9ispCzjsaZDvfiJOmfCM4E2TRhr65ILcWG5UQcKruMcMyhxGE9KRNiaeEaizWCxvbYiktblP1Py2EYVhOcThr7r0E2TRN6K)ubxQfzuaJNI6jFE6X8xpIIoFovqvPq)sF1jrFt2tfVcirNbye6caVnoP(Ti0rx)we68tF1jr3efOZsOU5pOcd9dDtKfKjJKftIf673srneastlIvih6cap9BrOJfQlmMeDnzhxGEO2O7rPsCHUi9isp1j)PcUulYOagpf1Jw80JWF9SBxpwQm4aSmlCPiP5pJ8io2Jw981JO9KRhr6rKEIaq4bGKb)haCxWicaHhasgSKwNIz7jFE65dwO9KRhXskTXF8bdfwEPVFs2JO9SBxp8QN6ceRGLx67NKWe74c0RNC9WREIaq4bGKb)haCxWicaHhasgSKwNIz7rRE(6jxp1j)Pc(rCzjsahbbG1MznSRZUfwsRtXS9Ofp9i0EY1Ji9WREIaq4bGKbZfUhzlGCblP1Py2E0QNVE2TRhE1JLkdoalZcxksA(ZipIJ9OvpF9iAp56rKE4vp1fiwblj2dMyhxGE9SBxppqblj2dwsRtXS9Ovp5Phr7r0EeTND76HllrcykVOywPamsAnelPOYQamyBDrn6HNEm3tUE4YsKa2U9QIK0Z4rjiMLSWzI7jxp8QNiaeEaizW)ba3fmIaq4bGKblP1Py2E0QNVEY1dV6XsLbhGLzHlfjn)zKhXXE0QNp05ZPcQkf6CxvbYiktH(MSNkEfqIodWi0faEBCs9BrOJU(Ti01(Qkq9SxMcDtuGolH6M)Gkm0p0nrwqMmswmjwOVFlf1qainTiwHCOla80VfHowOEEhtIUMSJlqpuB09OujUq)ILknzqmAPiBpAXtpM7jxp1fiwbBHKiXk2VHTKknilmXoUa9qNpNkOQuOlZygxSuaMrqzl03K9uXRas0zagHUaWBJtQFlcD01VfHUPmwp8JLcW6riv2cD(YFl6SBr8abxT23dF5YcXEIb6stqaDtuGolH6M)Gkm0p0nrwqMmswmjwOVFlf1qainTiwHCOla80VfHURw77HVCzHypXaDPjSqDEdmj6AYoUa9qTr3JsL4c9lwQ0KbXOLIS9Ofp9i0EY1dV6PUaXkylKejwX(nSLuPbzHj2XfOh685ubvLcDzgZ4ILcWmckBH(MSNkEfqIodWi0faEBCs9BrOJU(Ti0nLX6HFSuawpcPYw9icurrNV83Io7wepqWvR99WxUSqSh(8onHa6MOaDwc1n)bvyOFOBISGmzKSysSqF)wkQHaqAArSc5qxa4PFlcDxT23dF5YcXE4Z70eluh6hMeDnzhxGEO2O7rPsCHEDYFQG3sxO2clow9Kpp9y(RNC9CXsLMmigTuKTN87rOOZNtfuvk0LzmJlwkaZiOSf6BYEQ4vaj6maJqxa4TXj1VfHo663Iq3ugRh(Xsby9iKkB1JiMffD(YFl6SBr8abxT23dF5YcXEO8IIzfbbER6K)uzOsWtDYFQG3sxO2clow5ZJ5VCxSuPjdIrlfzZxOOBIc0zju38huHH(HUjYcYKrYIjXc99BPOgcaPPfXkKdDbGN(Ti0D1AFp8Llle7HYlkMvewOouOys01KDCb6HAJUhLkXf61j)PcElDHAlS4y1Jw9y(dD(CQGQsHUmJzCXsbygbLTqFt2tfVcirNbye6caVnoP(Ti0rx)we6MYy9WpwkaRhHuzREeH3lk68L)w0z3I4bcUATVh(YLfI9yvS)abb0nrb6SeQB(dQWq)q3ezbzYizXKyH((TuudbG00IyfYHUaWt)we6UATVh(YLfI9yvS)aHfwO7rPsCHowica]] )

    storeDefault( [[SimC Arms: precombat]], 'actionLists', 20171203.130909, [[d4ImbaGErODjkTnKQMnLUjuCBb7uk7LSBe7xKmmj53unuHudwumCO6Gs4yGSqrWsbvlgjlNIhkQ8uvldkToHIPkPMmqtxXfbfxg11fQARcv2UqPhd4ZiLVlQ6Wk9njA0cjNhu6KcrpxQonK7je(Ri1IerVgPYcs16Wqwkldkk92gy9Jc5sLPWe6XKkdUHb8a1o6WzlVDwnSvqLvLyPplK(Xza0ArjUdYjQvcPxamiN0vTAqQwhgYszzqLG(bmi8rFCA0SCwCFqoPRxqHSObwDCFqorpscicyh3OtCcRJXbJBnTnW66TnW6r7dYj6fgADDYg4is6wW05xtsD4SL3oRg2kOsOkD4C3J3aWDvRrpxumaDy8y5atgrPJXbBBG1Dly68RrJg9dyq4JUgj]] )

    storeDefault( [[SimC Arms: execute]], 'actionLists', 20171203.130909, [[d4ZDlaGEvjL2euyxi12uLs7dvKVbv8yQmBjMpLOBkPoSOBRsNxOANizVk7gL9t4NQscdtvzCQskonv9xvvdMOHJkDquHtbvXXufNtvsQfIQyPOQwSkwoIhcv1tjTmH06uLeDzWuPKMSGPl1frv6qOIINPkfxNsTrvjjBviSzO02HI(UK0xvLunnkHMNQu9zOspNIrlugpLGtke9AjX1qfv3tvIFd54OIsJcQsVNzDkVS8uGWotPYlmv9x8fsoixZRuiblao7gMYhkqAGrf97bNpCI(w6NPkxW5ZI)1MThXgfopt5W1EeZmRJ6zwNYllpfimEMQoINBp9yJfl9j7Ua)osCABUcjgcjEfsd0)heZ2q3EGe973ICDcjNeYpH0slfsGZA75Yfc0Dm4hxcK9VPrKR5hIdcjEMYXXx8D8PNsgatJi3PrYcEx2iYugIbtRrHiscvEHPtPYlmLNsgatJi3P8HcKgyur)EW55BkFWGSjoWmRRNIFmWvPgHjCbwVZ0AuGkVW01Jk6SoLxwEkqy8mvDep3E6XglwAtSSBGaH)aGfygWqhqvzcjgcjEfYJnwS0NS7c87iXPdOQmH0slfs8kKhBSyPblao72JyaX8ZLaoVXJy0MoDveYxeYOcjgcz6ApIrFYUlWVJeNgy5PabHedHeVcPdHkbuvg9j7Ua)osCAcCtpZiKVlKpcPLwkKhBSyPpz3f43rItBZviXJqIhHept544l(o(uhQGmgBZV5MMytJKf8USrKPmedMwJcrKeQ8ctNsLxyk(OcYySncPEttSP8HcKgyur)EW55BkFWGSjoWmRRNIFmWvPgHjCbwVZ0AuGkVW01J6nZ6uEz5PaHXZu1r8C7PncxClaDsAp201cjgcjEfshcvcOQm6lI0z530eFfGMa30Zmc57ViKoeQeqvz04wqNS87qOsavLrtGB6zgHedH8yJflTjw2nqGWFaWcmdyOdOQmHedH8yJflnybWz3EediMFUeW5nEeJ20PRIq(IqgviXZuoo(IVJpTAsoeiRaKPrYcEx2iYugIbtRrHiscvEHPtPYlm91tYHazfGmLpuG0aJk63dopFt5dgKnXbMzD9u8JbUk1imHlW6DMwJcu5fMUEuwCwNYllpfimEMQoINBpLK4c0baR35BH8DH8nC(uoo(IVJpflYzBGWpjXfMgjl4DzJitzigmTgfIiju5fMoLkVW0xfYzBGGqYpXfMYhkqAGrf97bNNVP8bdYM4aZSUEk(XaxLAeMWfy9otRrbQ8ctxpkoFwNYllpfimEMQoINBpLa30Zmc57cjNlKyiKPR9ig9j7Ua)4tItdS8uGGqIHqMU2Jy0NsgatJixAGLNceesmeshcvcOQm6t2Db(DK40e4MEMriFxiJkKyiK4viDiujGQYOpLmaMgrU0e4MEMriFxiJkKwAPqYzesd0)heZ2q3EGe973ICDcjNeYpHept544l(o(ucWctJKf8USrKPmedMwJcrKeQ8ctNsLxykFGfMYhkqAGrf97bNNVP8bdYM4aZSUEk(XaxLAeMWfy9otRrbQ8ctxpQ3oRt5LLNcegptvhXZTNMU2Jy0NS7c87iXPbwEkqqiXqiDiujGQYOpz3f43rIttGB6zgH89xesCDbHedHmahBSyPDOcYySn)MBAIrtGB6zgHKtc5BNYXXx8D8PKeZexGmnswW7YgrMYqmyAnkersOYlmDkvEHP8tmtCbYu(qbsdmQOFp488nLpyq2ehyM11tXpg4QuJWeUaR3zAnkqLxy66rHZSoLxwEkqy8mvDep3E6Xglw6QGh3yne(pLma0MoDveYxeY3mLJJV474tRgZtkv9SW0izbVlBezkdXGP1OqejHkVW0Pu5fM(6X8KsvplmLpuG0aJk63dopFt5dgKnXbMzD9u8JbUk1imHlW6DMwJcu5fMUEuVMzDkVS8uGW4zQ6iEU90JnwS0GfaND7rmGy(5saN34rmAtNUkc5lczuHedH8yJflTjw2nqGWFaWcmdyOT5oLJJV474tVisNLFtt8vGPrYcEx2iYugIbtRrHiscvEHPtPYlmTgr6SiKAt8vGP8HcKgyur)EW55BkFWGSjoWmRRNIFmWvPgHjCbwVZ0AuGkVW01J6vpRt5LLNcegptvhXZTNssCbANnHaSwiFxiT43uoo(IVJpfHjq4IQcKPrYcEx2iYugIbtRrHiscvEHPtPYlm9vGjq4IQcKP8HcKgyur)EW55BkFWGSjoWmRRNIFmWvPgHjCbwVZ0AuGkVW01J65BwNYllpfimEMQoINBp9yJflTjw2nqGWFaWcmdyOdOQmH0slfssIlq7SjeG1cjNEriT4NqAPLczNfG10H0M1fWyObwEkqqiXqijjUaTZMqawlKC6fH8nVDkhhFX3XNcwaC2nmnswW7YgrMYqmyAnkersOYlmDkvEHP8AbWz3Wu(qbsdmQOFp488nLpyq2ehyM11tXpg4QuJWeUaR3zAnkqLxy66r98mRt5LLNcegptvhXZTNMU2Jj8dm46bJqYjH8riXqi5mcPb6)dIzBOBpqI(9BrUoHKtc53uoo(IVJp9uYayAe5onswW7YgrMYqmyAnkersOYlmDkvEHP8uYayAe5kK49bpt5GGRzQN1aHyZTF5zkFOaPbgv0VhCE(MYhmiBIdmZ66P4hdCvQrycxG17mTgfOYlmD96PQJ452txVb]] )

    storeDefault( [[SimC Arms: AOE]], 'actionLists', 20171203.130909, [[d0dBlaGEOG0MKkSlLyBOqL9HcLVjvz2uA(OqUPK8ykUTuoSIDQu7vSBuTFq9tOGyykPXbfi3tsXPjzWGmCsPdkv6uskDmQQZbfOwikyPOulgQworpucwfuawMe65egLurtfLmzQmDGlcf9xu0ZGc56s0Njv1wjf2mvPTtQ8DPQ(kuOMguqnpsvADqb0RLunAO04jvrNKu0LvDnsv48ufpf54Oqv)gYXpScHjFWT3f8q7P9qKQvagQRSjWaHH6IHGzi23(r8SlU63BTxrg3IFis7nQXQWqhGcXZUNFOUgGcXfHv2(Hvim5dU9UWqiYivAbHai913(LrcuEhdagQdyOoHHgdqH4l42XDbajBlNp427GH6agQtyidczDO(8fC74UaGKTLsTWqmIrWqgeY6q95l42XDbajBlY3gfxadP3AGH034GHQfgQdyOXaui(c(aa2Z0i9SC(GBVdgQdyOoHHmiK1H6ZxWhaWEMgPNLsTWqmIrWqgeY6q95l4dayptJ0ZI8TrXfWq6Tgyi9noyOAHHQnuxCLvb8eQ)iXLFQFzin5oLzaizioI)qviNgJCpThk0EApegpsC5N6xgI9TFep7IR(98xdX(cuP0CryfqOcyVPEfs3BNdcEOkKBpThkGSlgwHWKp427cdHiJuPfecV0R3f8baSNPr6zPulmuhWqDcdjoGjoIxkwaQllUYedR1adXyWqRWqmIrWqNXxQ0Q9Ufa2ZuF5hatbajBcM3ZHHQnuxCLvb8ec3oUlaizlKMCNYmaKmehXFOkKtJrUN2dfApThIb74UaGKTqSV9J4zxC1VN)Ai2xGkLMlcRacva7n1Rq6E7CqWdvHC7P9qbKngfwHWKp427cdHiJuPfecV0R3ffNPxKKja7zwxzTlouFomuhWqGXEoyrXz6fjzcWEM1vw7Y5dU9UqDXvwfWtidYIeIsbtrBeydPj3PmdajdXr8hQc50yK7P9qH2t7HkGSiHOuadrTrGne7B)iE2fx975VgI9fOsP5IWkGqfWEt9kKU3ohe8qvi3EApuazJHdRqyYhC7DHHqKrQ0cc5oEPxVlgKfjeLcMI2iWU4q95WqDadngGs3zE(BQlGH0BnWq(RH6IRSkGNqgKfjeLcMI2iWgQa2BQxH0925GGhQc50yK7P9qH0K7uMbGKH4i(dTN2dvazrcrPagIAJalmuN(1gQRuFriJhJ9mbJu)de14hI9TFep7IR(98xdX(cuP0CryfqOcEm2ZAK6FGimeQc52t7HciB9iScHjFWT3fgcrgPsli0yakDN55VPUagIXQbgspc1fxzvapHm2p6Ein5oLzaizioI)qviNgJCpThk0EApub7hDpe7B)iE2fx975VgI9fOsP5IWkGqfWEt9kKU3ohe8qvi3EApuazZ4cRqyYhC7DHHqKrQ0ccngGs3zE(BQlGHySAGH0dyOoGHWl96DXy)O7lLAd1fxzvapH6JvjT9vCxin5oLzaizioI)qviNgJCpThk0EApegJvjT9vCxi23(r8SlU63ZFne7lqLsZfHvaHkG9M6viDVDoi4HQqU90EOaYUxyfct(GBVlmeImsLwqOXau6oZZFtDbmeJvdmuVqDXvwfWtO(yvsBFf3fstUtzgasgIJ4pufYPXi3t7HcTN2dHXyvsBFf3bd1PFTHyF7hXZU4QFp)1qSVavknxewbeQa2BQxH0925GGhQc52t7HciBmOWkeM8b3ExyiezKkTGq4LE9UiWoaWL3X0DVNlUyXH6Zd1fxzvapHmilsikfmfTrGnKMCNYmaKmehXFOkKtJrUN2dfApThQaYIeIsbme1gbwyOolwBi23(r8SlU63ZFne7lqLsZfHvaHkG9M6viDVDoi4HQqU90EOaYgdoScHjFWT3fgcrgPslieEPxVlcaIFMy)iblLAd1fxzvapHUEEtj4H0K7uMbGKH4i(dvHCAmY90EOq7P9qyQN3ucEi23(r8SlU63ZFne7lqLsZfHvaHkG9M6viDVDoi4HQqU90EOaY2FnScHjFWT3fgcrgPslieEPxVlcSdaC5DmD375Ilwk1cdXigbdHx617Y1ZBkbke)sbtTYBucfIV4q95H6IRSkGNqnKemwMcGuv)H0K7uMbGKH4i(dvHCAmY90EOq7P9qvijySWqeqQQ)qSV9J4zxC1VN)Ai2xGkLMlcRacva7n1Rq6E7CqWdvHC7P9qbKTVFyfct(GBVlmeImsLwqi5BJIlGH0BnWqUs5auiomegam06cgbd1bm0yakDN55VPUagsV1adHrH6IRSkGNqYZDHkG9M6viDVDoi4HQqong5EApuin5oLzaizioI)q7P9qSp3fQRuFriJhJ9mbJu)de14hI9TFep7IR(98xdX(cuP0CryfqOcEm2ZAK6FGimeQc52t7HciB)IHvim5dU9UWqOU4kRc4jKX(r3dPj3PmdajdXr8hQc50yK7P9qH2t7Hky)O7WqD6xBi23(r8SlU63ZFne7lqLsZfHvaHkG9M6viDVDoi4HQqU90EOaY2hJcRqyYhC7DHHqDXvwfWtO(yvsBFf3fstUtzgasgIJ4pufYPXi3t7HcTN2dHXyvsBFf3bd1zXAdX(2pINDXv)E(RHyFbQuAUiSciubS3uVcP7TZbbpufYTN2dfqaHiJuPfekGea]] )

    storeDefault( [[SimC Arms: cleave]], 'actionLists', 20171203.130909, [[d0txjaGErjPnjQKDbW2eLQ2NOu6BsfZwO5Ju1njLhlYTv0HLStf2l1UjSFuzuIk1WKQghGQ68kHtlLbJQgUOQdjkroLOIogP6CaQYcvswkqwSsTCuEOs0QeLeltQ06eLGNlyQiXKjz6GUOsQPjkvEMOuCDIAJIsuBfj1MbQTteFhPYxbu5ZakZtuHEnr6VIIrJugVOK6Kijxw11evW9eLqpf63ioiGS1nfJRf1oEL3gh18gX2CjhpqSzilWXNIVKCJGE8v4E0TxVtFNUzpaDJy(NAvSLvlyJi8OJUrGsWgremfp0nfJRf1oELxzeODl2GlmojmyfZeGSM0BKkHQLkiHzuqe3OgrrDXg18gnoQ5nQryWkYXJqwt6nc6XxH7r3E9o69gb9arMLEWum04sApjvJi5ZlGEBuJOg18gn0JUMIX1IAhVYRmIjwlp04wgmyabir8m0EXGaKZBeODl2Glm(S(jz4nsLq1sfKWmkiIBuJOOUyJAEJgh18gxN1pjdVrqp(kCp62R3rV3iOhiYS0dMIHgxs7jPAejFEb0BJAe1OM3OHEKnMIX1IAhVYRmIjwlp04wgmyabAfeE2vzuh8fHhaOi0j44Zfh)wgmya5zp1cptaYAsFaGIqNWiq7wSbxymrIKqqoKjmRanJujuTubjmJcI4g1ikQl2OM3OXrnVXLKijeKdC84Sc0mc6XxH7r3E9o69gb9arMLEWum04sApjvJi5ZlGEBuJOg18gn0JSZumUwu74vELrmXA5HgHeGbS4bumydCLGC85IJp3C8BzWGbeOvq4zxLrDWxeEaGIqNGJpNgbA3In4cJ0vSn7L0ZmsLq1sfKWmkiIBuJOOUyJAEJgh18gbUITzVKEMrqp(kCp62R3rV3iOhiYS0dMIHgxs7jPAejFEb0BJAe1OM3OHEKdMIX1IAhVYRmIjwlp0iRa2bKKzSlGC8zlhVEFphp90ZXVLbdgWUGW4ZKylYOEPIlYKQ4eGCEJaTBXgCHrWKKC4QmScy3ivcvlvqcZOGiUrnII6InQ5nACuZBmltsYHR44bva7gb94RW9OBVEh9EJGEGiZspykgACjTNKQrK85fqVnQruJAEJg6r2BkgxlQD8kVYiMyT8qJWkEbea4ZKqyziGZSlimEaxu74vC85IJp3C8QVLbdgqIejHGCitywbAaKZZXtp9C8ScyhG6GBPgKJph54ZHEo(CYXNlo(CZXNL44Hv8ciaWKKC4QmScyhWf1oEfhp90ZXVLbdgWUGW4ZKylYOEPIlYKQ4eGCEoE6PNJFldgmGu8LKdqophFonc0UfBWfgPJwJfPRjugPsOAPcsygfeXnQruuxSrnVrJJAEJahTglsxtOmc6XxH7r3E9o69gb9arMLEWum04sApjvJi5ZlGEBuJOg18gn0JoMIX1IAhVYRmIjwlp0i7ZQjcC85ywKJxjZkyJi44ZkC89aYgJaTBXgCHr2fkJujuTubjmJcI4g1ikQl2OM3OXrnVrqxOmc6XxH7r3E9o69gb9arMLEWum04sApjvJi5ZlGEBuJOg18gn0dGVPyCTO2XR8kJaTBXgCHXDSupajSPrQeQwQGeMrbrCJAef1fBuZB04OM34QyPEasytJGE8v4E0TxVJEVrqpqKzPhmfdnUK2ts1is(8cO3g1iQrnVrd9a4zkgxlQD8kVYiq7wSbxymfFj5gPsOAPcsygfeXnQruuxSrnVrJJAEJlJVKCJGE8v4E0TxVJEVrqpqKzPhmfdnUK2ts1is(8cO3g1iQrnVrd9qV3umUwu74vELrmXA5HgzfWoGKmJDbKJpB54ZUEoE6PNJFldgmGu8LKdqoVrG2TydUWiD0ASiDnHYivcvlvqcZOGiUrnII6InQ5nACuZBe4O1yr6AcfhFU1ZPrqp(kCp62R3rV3iOhiYS0dMIHgxs7jPAejFEb0BJAe1OM3OHEORBkgxlQD8kVYiq7wSbxymqJKKsxj5gPsOAPcsygfeXnQruuxSrnVrJJAEJinsskDLKBe0JVc3JU96D07nc6bIml9GPyOXL0EsQgrYNxa92OgrnQ5nAOh6DnfJRf1oELxzeODl2GlmgGe2mZMeHgPsOAPcsygfeXnQruuxSrnVrJJAEJiKWMC8RirOrqp(kCp62R3rV3iOhiYS0dMIHgxs7jPAejFEb0BJAe1OM3OHgAetSwEOrdTb]] )

    storeDefault( [[SimC Fury: three targets]], 'actionLists', 20171203.130909, [[dKJveaGEIQQnbkSls1Rvf2hKQA2cnFbLBkHBd0oLYEP2nI9dvJcsLHPQ8BcphKbdLHtKoieCkqrhJuohrLAHsKLQkTyPA5i9qiLNIAzcY6iQkhw0uHKjlPPRYfLO(MQOlRCDb2iKQSvIOntu2oOQZdH(krLmnbv9DqLttYJbmAvvJxqLtse(lO01iQO7ruLoerv8zi6zevyRzuMltYECv3n3sWzMvGOHJHEbueLpCS7NUHJDjf5oiZVlUeAUf6t7PMMMCRRzMLoavgvYFEkbXTNHmJaWPeeiJYnnJYCzs2JR6sMzaQs6zUhitMo0jid2)L0tpqQze6QO6q08c3acUzwcsvbKNGAMiiZCHOkzsBj4mBULGZC5WnGGBMFxCj0Cl0N2tTpZVdseqbgKr5ZmA)d4rHa(boY5U5crTLGZSp3czuMltYECvxYmdqvspZ9azY0bxEWcexc)O6bsXXGbog6WXqhowpqMm9rOjYPxfWrWXGboM8GJDzCKtxgvC)kcsy7Jcn6Jr1hj7XvXXGjowyHHJHoCmAIC6abu6ihog6lV4yAFF4yWah7Y4iNUmQ4(veKW2hfA0hJQps2JRIJbtCmyIJfwy4y9azY0btiOeGo9aPMrORIQdrZ0euAICMLGuva5jOMjcYmxiQsM0wcoZMBj4m)MGstKZ87IlHMBH(0EQ9z(DqIakWGmkFMr7FapkeWpWro3nxiQTeCM95MCyuMltYECvxYmdqvspZxgh50veYOWstKtFKShx1mcDvuDiAMMiveKW2Jc4mlbPQaYtqnteKzUquLmPTeCMn3sWz(nrQiiXXkffWz(DXLqZTqFAp1(m)oirafyqgLpZO9pGhfc4h4iN7Mle1wcoZ(Cl8gL5YKShx1LmJqxfvhIM7rHOE)kk0zwcsvbKNGAMiiZCHOkzsBj4mBULGZCPOquVFff6m)U4sO5wOpTNAFMFhKiGcmiJYNz0(hWJcb8dCKZDZfIAlbNzFUjNgL5YKShx1LmJqxfvhIMH7xrJWPivZsqQkG8euZebzMlevjtAlbNzZTeCMLRFfncNIun)U4sO5wOpTNAFMFhKiGcmiJYNz0(hWJcb8dCKZDZfIAlbNzF(mZauL0ZSpBa]] )

    storeDefault( [[SimC Fury: single target]], 'actionLists', 20171203.130909, [[d0JZiaGAkfA9kOSjkWUiX2iPK2hLsnBQmFfKBQqpNQUnKoSu7uf7vSBO2VKgfjv)Ls14iPu9nLsNxbgSedNKCqcXPOGogfDoskSqLILQQAXkz5e9qc0trTmk06iPuonPMkbnzfnDexuvPhdXZiPexxv2iLs2kHYMPKTtO6ZQuFLKImnfu18OuWHOuKVRQy0kvJNsrDscPldUgjf19uqLxta)gPHPsoMry4V4E5GzwHpnkeM1Ocwl26jhO2QfVgF7GAH0YBGe(hCq7HCmEzU100unumdZQaeD70dRjAkoNTgdlccrtX(imhZim8xCVCWmBcZisTks41ZYsX6zJAy2E7wp5aLNQAXGAz9SSuSE2OgMT3U1toqrcOTg7RfBOwmgwKL2PjdcVCu6KSRLEsyrXtnstOYWykgcpsNI1YtJcHdFAui8ghLoj7APNe(hCq7HCmEzU18k8p4Ppjc4JWqcl4oGiWivCafWKScpsNNgfchsogJWWFX9YbZSjmJi1QiHjTdWefljGh2afa3lhmRfdQf1RL1ZYsXsc4Hnqzs)GRLHgQwwpllfljGh2afjG2ASVwSHHRwmwlggwKL2PjdcB9KA6ZB37A)EyrXtnstOYWykgcpsNI1YtJcHdFAuiSTEsn95Rf21(9W)GdApKJXlZTMxH)bp9jraFegsyb3bebgPIdOaMKv4r680Oq4qYrTeHH)I7LdMztygrQvrcVEwwkaw23GYtvTyqTqAhGjkAmgK2L9nOa4E5GzyrwANMmiSSV14B7lh9tyrXtnstOYWykgcpsNI1YtJcHdFAui8FFRX31Ygh9t4FWbThYX4L5wZRW)GN(KiGpcdjSG7aIaJuXbuatYk8iDEAuiCi5m8ry4V4E5Gz2eMrKAvKWKwEdeLDODKDfviKAX21IrZAXGAr9Ar9Az9SSuaSSVbLj9dUwmOwSPAH0oatuSKuYUgFBFbspifaKkaUxoywlgwldnuTSEwwkOT33isq5PQwgAOAr23GcYtkbmPwS9WvlMxx1IHHfzPDAYGWYgvvFdHffp1inHkdJPyi8iDkwlpnkeo8PrHW)nQQ(gc)doO9qogVm3AEf(h80Neb8ryiHfChqeyKkoGcyswHhPZtJcHdjh1Ceg(lUxoyMnHzePwfj86zzP4jumyFhAjr5PQwmOwuVwuVwiTdWefngds7Y(guaCVCWSwmOwqOu3K(bRi7Bn(2(Yr)Oib0wJ91ITRfZAXWAzOHQL1ZYsbWY(guEQQfddlYs70KbHbBgqEeiSO4PgPjuzymfdHhPtXA5PrHWHpnke(Rndipce(hCq7HCmEzU18k8p4Ppjc4JWqcl4oGiWivCafWKScpsNNgfchsoQ1im8xCVCWmBclYs70KbHxokDs21spjSO4PgPjuzymfdHhPtXA5PrHWHpnkeEJJsNKDT0tQf1nnm8p4G2d5y8YCR5v4FWtFseWhHHewWDarGrQ4akGjzfEKopnkeoKC2gHH)I7LdMztygrQvrc7bI9ff)8keninvd7gvHul2UwUQfdQfBQwiTdWefngds7Y(guaCVCWmSilTttge26j10N3U31(9WIINAKMqLHXumeEKofRLNgfch(0OqyB9KA6ZxlSR971I6Mgg(hCq7HCmEzU18k8p4Ppjc4JWqcl4oGiWivCafWKScpsNNgfchsoQ9im8xCVCWmBclYs70KbHL9TgFBF5OFclkEQrAcvggtXq4r6uSwEAuiC4tJcH)7Bn(Uw24OFQf1nnm8p4G2d5y8YCR5v4FWtFseWhHHewWDarGrQ4akGjzfEKopnkeoKCuJim8xCVCWmBcZisTks41ZYs5JeqeqJVTVANt5PQwmOwwpllfal7Bq5PkSilTttge(ZUw6(OXZWIINAKMqLHXumeEKofRLNgfch(0Oqy10Uw6(OXZW)GdApKJXlZTMxH)bp9jraFegsyb3bebgPIdOaMKv4r680Oq4qYX8kcd)f3lhmZMWIS0onzqyRNutFE7Ex73dlkEQrAcvggtXq4r6uSwEAuiC4tJcHT1tQPpFTWU2VxlQB0WW)GdApKJXlZTMxH)bp9jraFegsyb3bebgPIdOaMKv4r680Oq4qcjmJi1QiHdjba]] )

    storeDefault( [[SimC Fury: default]], 'actionLists', 20171203.130909, [[dyKuxaqiQQOfHI0MiQmkQsofvPEfiq6wGaXUOIHbQogaltbEgiGPrvfUgrQyBePsFJizCePQohiswhrkZJQkDpqO9bc6GcPfse9qHYebbQUirvBefXibrQoPqyMGO6MaANO0pbrkdfeOSuIYtjnvQIRcIGTsvv7v1FvObJQdlAXa9ybtwsxgAZkOpdkJwO60uSAqe61OOMnLUTe7gXVLA4OWXbrz5i9CfnDLUovA7uv(ory8Gi68G06jsvMVq0(j8bCpxLNKGwSEWRSzbVQMsmbNjUuOstWR4W01UxLHwmN4zhahGuaaaas5a4QYadM0AKE5AAYzLAW1OH10K59Cwa3Zv5jjOfRxYRrbnwZc9AiEsHHxJGunHCB6vstWRa7Q)jLnl41RSzbVglEsHHxLHwmN4zhahGuaGFvgoBxAaN3Z3RXIJbMb2(Wcs2dEfyxzZcE97zhCpxLNKGwSEWRAGAySx3KcdxN2DNMkkDUgf0ynl0RuxYygwttgTM5Encs1eYTPxjnbVcSR(Nu2SGxVYMf8QmxIGhnSMMi4qUzUxJsHnVsYccrMQMsmbNjUuOstWlTpSGKLPxLHwmN4zhahGuaGFvgoBxAaN3Z3RXIJbMb2(Wcs2dEfyxzZcEvnLycotCPqLMGxAFybj73ZcbUNRYtsqlwp4vnqnm2RBsHHRt7UttfL(xJcASMf614iTnHrlMmUgbPAc520RKMGxb2v)tkBwWRxzZcEfshPTji4qoMmUkdTyoXZoaoaPaa)QmC2U0aoVNVxJfhdmdS9HfKSh8kWUYMf863Z6h3Zv5jjOfRxYRAGAySx3ggml6WOxttMcUCcUxcoO7WHoG5UwCmqH64YqWLtW9sWbDho0j9LBsDCzi4rgPG7Nc(MwKSoPVCtQdssqlwfCVfCVVgf0ynl0Rm610KRrqQMqUn9kPj4vGD1)KYMf86v2SGxHG1RPjxJsHnVsYccrM226OejLPxLHwmN4zhahGuaGFvgoBxAaN3Z3RXIJbMb2(Wcs2dEfyxzZcETT1rjs63ZkDUNRYtsqlwVKx1a1WyV6LGJqMRHbdS6eAIpKcdjbCShoomxCk4Yj4HUT1wcIdyURfhduOouSKgYuW9RGpqW9wWJmsb3pfCeYCnmyGvNqt8HuyijGJ9WXH5Itbxob3lb3pf8q32AlbXbm31IJbkuhkwsdzk4(fIcoa4cEKrk4HUT1wcIdyURfhduOouSKgYuW9RGpqW9(AuqJ1SqVwPjSMms7KEncs1eYTPxjnbVcSR(Nu2SGxVYMf8keCAcRjcUSoPxLHwmN4zhahGuaGFvgoBxAaN3Z3RXIJbMb2(Wcs2dEfyxzZcE97zLU3Zv5jjOfRxYRAGAySxdDBRTeehWCxlogOqDOyjnKPG7xb3peC5e8mSMM4aM7AXXafQdssqlwfC5e8nPWW1joM2nUdJWk4qOGpa(1OGgRzHELMfgjm8AeKQjKBtVsAcEfyx9pPSzbVELnl4vzzHrcdVkdTyoXZoaoaPaa)QmC2U0aoVNVxJfhdmdS9HfKSh8kWUYMf863Zk19CvEscAX6L8QgOgg7veYCnmyGvhMtPN0lTjKCCOlKObR5CCOlfQGlNGd6oCOZqxirdwZ54qxkuNAlb5AuqJ1SqVcA7UUXn05Encs1eYTPxjnbVcSR(Nu2SGxVYMf8QK2URBCdDUxLHwmN4zhahGuaGFvgoBxAaN3Z3RXIJbMb2(Wcs2dEfyxzZcE97zL(3Zv5jjOfRxYRAGAySxbDho0bm31IJbkuhkwsdzk4qOGlDf8iJuW9sWZWAAIdyURfhduOoijbTyvWLtWdDBRTeehWCxlogOqDOyjnKPG7xbhaCb3BbpYifCVe8nPWW1znfCC7XQbfC)k4Ej4HUT1wcIdyURfhduOouSKgYuWHGk4aGl4El4EFnkOXAwOxtF5M0RrqQMqUn9kPj4vGD1)KYMf86v2SGxJ6l3KEvgAXCINDaCasba(vz4SDPbCEpFVglogygy7dlizp4vGDLnl41VNfsDpxLNKGwSEjVQbQHXEfHmxddgy1XTast7yPBcmBA8Htbxob3lbp0TT2sqCaZDT4yGc1HIL0qMcoek4Wcvbxobp0TT2sqCaZDT4yGc1HIL0qMcUFf8bcEKrk4HUT1wcIdyURfhduOouSKgYuWHOGdxW9(AuqJ1SqV6waPPDS0nbMnn(W51iivti3MEL0e8kWU6FszZcE9kBwWRqcfqAAfCGDtGztJpCEnkf28kjlieDlG00ow6MaZMgF48Qm0I5ep7a4aKca8RYWz7sd48E(EnwCmWmW2hwqYEWRa7kBwWRFpla43Zv5jjOfRxYRAGAySxdDBRTeehy2gmTJHUT1wcIdflPHmfCik4WfC5e8nTizDOyGzloNJjysQnXbjjOfRcUCcUxcoczUggmWQJBbKM2Xs3ey204dNcUCcUxcodk6BShoCewO64waPPDS0nbMnn(WPGhzKcUxc(sneMX1j0TT2sqCOyjnKPGdHcoeqWLtWxQHWmUoHUT1wcIdflPHmfC)k4qk4cU3cU3cEKrk4(PGJqMRHbdS64waPPDS0nbMnn(WPG791OGgRzHEfm31IJbk0RrqQMqUn9kPj4vGD1)KYMf86v2SGxLm31IcEmk0RYqlMt8SdGdqkaWVkdNTlnGZ7571yXXaZaBFybj7bVcSRSzbV(9SaaCpxLNKGwSEjVQbQHXEn0TT2sqCGzBW0og62wBjiouSKgYuWHOGdxWLtW30IK1b0MvCUnT4GKe0Ivbxob3lbpdRXhoIeSyWPGdHc(ab37RrbnwZc9kyURfhduOxJGunHCB6vstWRa7Q)jLnl41RSzbVkzURff8yuOcUxa8(Qm0I5ep7a4aKca8RYWz7sd48E(EnwCmWmW2hwqYEWRa7kBwWRFplGb3Zv5jjOfRxYRAGAySxdDBRTeehy2gmTJHUT1wcIdflPHmfCik4WfC5eCq3HdDQ0ewtgPDsDCzi4Yj4Ej4HUT1wcIdOT76g3qNRdflPHmfCik4Wf8iJuWbDho0bj0eg6qXsAitbhcf8q32AlbXb02DDJBOZ1HIL0qMcU3xJcASMf6vWCxlogOqVgbPAc520RKMGxb2v)tkBwWRxzZcEvYCxlk4XOqfCVg49vzOfZjE2bWbifa4xLHZ2LgW5989AS4yGzGTpSGK9Gxb2v2SGx)EwaqG75Q8Ke0I1l5vnqnm2R(PGJqMRHbdS64waPPDS0nbMnn(WPGlNGd6oCOdyURfhduOoUmeC5eCq3HdDqcnHHoUmUgf0ynl0RUfqAAhlDtGztJpCEncs1eYTPxjnbVcSR(Nu2SGxVYMf8kKqbKMwbhy3ey204dNcUxa8(AukS5vswqi6waPPDS0nbMnn(W5vzOfZjE2bWbifa4xLHZ2LgW5989AS4yGzGTpSGK9Gxb2v2SGx)Ewa(X9CvEscAX6L8QgOgg7vq3HdDQ0ewtgPDsDCzi4rgPG7Nc(MwKSovAcRjJ0oPoijbTyvWLtWbDho0bm31IJbkuhxgxJcASMf6vqB3vWCJFncs1eYTPxjnbVcSR(Nu2SGxVYMf8QK2URG5g)Qm0I5ep7a4aKca8RYWz7sd48E(EnwCmWmW2hwqYEWRa7kBwWRFplaPZ9CvEscAX6L8QgOgg71THbZIoHUT1wcYuWLtW9sWbDho0bm31IJbkuhxgcU3xJcASMf6vqB31XHUuOxJGunHCB6vstWRa7Q)jLnl41RSzbVkPT7QGZexk0RYqlMt8SdGdqkaWVkdNTlnGZ7571yXXaZaBFybj7bVcSRSzbV(9SaKU3Zv5jjOfRxYRAGAySx3ggml6e62wBjitbxob3lbh0D4qhWCxlogOqDCzi4EFnkOXAwOxbr6ePmBiWUgbPAc520RKMGxb2v)tkBwWRxzZcEvsKorkZgcSRYqlMt8SdGdqkaWVkdNTlnGZ7571yXXaZaBFybj7bVcSRSzbV(9SaK6EUkpjbTy9sEvdudJ9knHHobxkfjRG7xbNMWqNscjfCiicUFa)AuqJ1SqVM0qsWXTPuKSxJGunHCB6vstWRa7Q)jLnl41RSzbVgLgsck4EAkfj7vzOfZjE2bWbifa4xLHZ2LgW5989AS4yGzGTpSGK9Gxb2v2SGx)Ewas)75Q8Ke0I1l5vnqnm2RGUdh6aM7AXXafQJldbxobFByWSOtOBBTLGmVgf0ynl0RuxYygwttgTM5Encs1eYTPxjnbVcSR(Nu2SGxVYMf8QmxIGhnSMMi4qUzUcUxa8(AukS5vswqiYu1uIj4mXLcvAcEOBBTLGmz6vzOfZjE2bWbifa4xLHZ2LgW5989AS4yGzGTpSGK9Gxb2v2SGxvtjMGZexkuPj4HUT1wcY87zbaPUNRYtsqlwVKx1a1WyVUjfgUoXX0UXDyewbhcf8bWfC5eCVe8mSgF4isWIbNcoefCiGGhzKcEgwJpCejyXGtbhIcUFi4EFnkOXAwOxdP1oMH10KrRzUxJGunHCB6vstWRa7Q)jLnl41RSzbVglTwbpAynnrWHCZCVgLcBELKfeImvnLycotCPqLMGVXPik4BsHH7KPxLHwmN4zhahGuaGFvgoBxAaN3Z3RXIJbMb2(Wcs2dEfyxzZcEvnLycotCPqLMGVXPik4BsHH787zha)EUkpjbTy9sEvdudJ9AgwJpCejyXGtbhcfC)4AuqJ1SqVgsRDmdRPjJwZCVgbPAc520RKMGxb2v)tkBwWRxzZcEnwATcE0WAAIGd5M5k4EbW7RrPWMxjzbHitvtjMGZexkuPj4rH0KNPxLHwmN4zhahGuaGFvgoBxAaN3Z3RXIJbMb2(Wcs2dEfyxzZcEvnLycotCPqLMGhfst(VNDaG75Q8Ke0I1l5vnqnm2RBsHHRtCmTBChgHvW9RGpa(1OGgRzHEL6sgZWAAYO1m3RrqQMqUn9kPj4vGD1)KYMf86v2SGxL5se8OH10ebhYnZvW9AG3xJsHnVsYccrMQMsmbNjUuOstWrijgCxKPxLHwmN4zhahGuaGFvgoBxAaN3Z3RXIJbMb2(Wcs2dEfyxzZcEvnLycotCPqLMGJqsm4U43ZoyW9CvEscAX6L8QgOgg71nPWW1joM2nUdJWk4qOGpa(1OGgRzHEL6sgZWAAYO1m3RrqQMqUn9kPj4vGD1)KYMf86v2SGxL5se8OH10ebhYnZvW9cc491OuyZRKSGqKPQPetWzIlfQ0e8PHaZIc(Muy4Y0RYqlMt8SdGdqkaWVkdNTlnGZ7571yXXaZaBFybj7bVcSRSzbVQMsmbNjUuOstWNgcmlk4BsHH73Vx1a1WyV(9ha]] )

    storeDefault( [[SimC Fury: precombat]], 'actionLists', 20171203.130909, [[d8ImbaGEru7sK8AHKzl4Mqv3wk7uQ2lz3iTFrXWaLFt1qfbdwuA4i6Ga6yu6CcvTqHklfuTyewofpucEQQhlP1jKAQamzGMUsxucDzuxxuzJIqBviSDHOpdL(Ue1Zb5WkgTiYYGkNuO05fPonK7ju8nO4VIQwKezzfa9I0HiWGIqVpnw)OwHmztmNjD0zYsA4Q3iMvhoh4bIvhhmlgR1gFkR(j5kAcOKNf5u1XGthyDrofsau3ka6fPdrGbvC6VAqKR(6yXg4uK(ICkKoqcuaTP1j9f5u9yPGO6SUrN6uwhVdgXy6tJ117tJ1tWxKt1bAWcPtNghtjpaMV8ykPdNd8aXQJdMfJfMoCgYZzQmKaOvVqsCnk8EKCJPRi0X7G9PX6EamF5XOvR(Rge5QRvc]] )

    storeDefault( [[SimC Fury: cooldowns]], 'actionLists', 20171203.130909, [[dauBlaqiuf1MGeFcIaJsjXPusAxKyyq4yuyzuKNHQitdIOCniI02GirFdIACqeX5GiP1brunpsQCpic1(iPkheLyHsQEikPlcjTruf6KKuUPKStL6NKuvwkK6PetfLAROk9viczVI)QKAWs5WuTyf9yqMSexw1MrrFwjgnkCAkTAsQQETKYSj1Tb1UH63igoj54qKWYr65kmDGRJkBhvLVJQQXJQGZtrTEicA(qKA)s1XiSJGk2N6xYmY2HFeXcZAVXJCuZi59geHOle(XJiOV((4zBcHbYgggivfJiIQdzDTfj0bwcoBKnfHfiGLGhHD2gHDeuX(u)sQhrGOwvGiaxFmqb2hdhIELJ9P(LEdLEBYXKPcSpgoe9kCQ6nu6TjhtMkht9LRqpSBXJEtD9MrewMwTfyoc1Hv5lpIA4IfYbeAemb)ivKcVoD7WpsKTd)iODyv(YJG(67JNTjegiBGic6piCuOpc7aIWkJdvRIW3HpgKzKksz7WpsazBkSJGk2N6xs9ice1Qceb40LduyCxdyOOcc0BQR3mHO3qP3MCmzQCm1xUc9WUfp6n11BgryzA1wG5itnHuamS0biIA4IfYbeAemb)ivKcVoD7WpsKTd)i11esbWWshGiOV((4zBcHbYgiIG(dchf6JWoGiSY4q1Qi8D4JbzgPIu2o8Jeq28uyhbvSp1VK6reiQvfiYrk4SQu9IsH6ClmaRjmxpiC6rVHsVbri6cHFSsH6ClmaRjmxpiC6Hc9WUfp6n11Bg9gk92KJjtf1p3YYPyNdOqpSBXJEtD9gpfHLPvBbMJCE4qCGhrnCXc5acncMGFKksHxNUD4hjY2HFeu5HdXbEe0xFF8SnHWazderq)bHJc9ryhqewzCOAve(o8XGmJurkBh(rciBKSWocQyFQFj1JiquRkqeazzrFfNcSmDiqVHsVTsVn5yYu5yQVCfov9gk9gWPlhOW4UgWqrfeO3uVEZeIEdLEBLEBLEdIq0fc)yfQVyXlRNAc)k0d7w8O3uVEdrVHsVbC9XaflgF6AQVCLJ9P(LEB1EdPr6EJN7nGRpgOyX4txt9LRCSp1V0BR2BRgHLPvBbMJqkMXJ1m5OMJOgUyHCaHgbtWpsfPWRt3o8Jez7WpI6RygJem6nEKJAoc6RVpE2MqyGSbIiO)GWrH(iSdicRmouTkcFh(yqMrQiLTd)ibKnsAyhbvSp1VK6ryzA1wG5iNhoeh4rudxSqoGqJGj4hPIu41PBh(rISD4hbvE4qCG3BRySAe0xFF8SnHWazderq)bHJc9ryhqewzCOAve(o8XGmJurkBh(rciBKYWocQyFQFj1JiquRkqeGRpgOyX4txt9LRCSp1V0BO0BtoMmvoM6lxHtvewMwTfyoc1xS4L1tnH)iQHlwihqOrWe8Jurk860Td)ir2o8JG2xS4LERUMWFe0xFF8SnHWazderq)bHJc9ryhqewzCOAve(o8XGmJurkBh(rciBKd7iOI9P(LupIarTQaraU(yGc9q10Fmw7thxiyLJ9P(LEdLEJN7nGRpgOWKsamS4L1ZthNw7uLJ9P(LEdPr6EBLEd46JbkmPeadlEz980XP1ov5yFQFP3qP3O(YvG4O0Jb9M6He3Bgiq0BRgHLPvBbMJqDyv(YJOgUyHCaHgbtWpsfPWRt3o8Jez7WpcAhwLV8EBfJvJG(67JNTjegiBGic6piCuOpc7aIWkJdvRIW3HpgKzKksz7WpsazJKe2rqf7t9lPEebIAvbIaC9XafchyYrhaLJ9P(LEdLEBYXKPYXuF5kfc)4EdLEBYXKPY0ba9xdrnRWPkcltR2cmhzE640ANUM6lpIA4IfYbeAemb)ivKcVoD7WpsKTd)i1pDCATt7n0(YJG(67JNTjegiBGic6piCuOpc7aIWkJdvRIW3HpgKzKksz7WpsazJud7iOI9P(LupIarTQarMCmzQCm1xUc9WUfp6n11Bg9gk9gp3BaxFmqHWbMC0bq5yFQFjcltR2cmhzQjKcGHLoarudxSqoGqJGj4hPIu41PBh(rISD4hPUMqkagw6a0BRySAe0xFF8SnHWazderq)bHJc9ryhqewzCOAve(o8XGmJurkBh(rciBdeHDeuX(u)sQhHLPvBbMJq9flEz9ut4pIA4IfYbeAemb)ivKcVoD7WpsKTd)iO9flEP3QRj83BRySAe0xFF8SnHWazderq)bHJc9ryhqewzCOAve(o8XGmJurkBh(rciBdJWocQyFQFj1JWY0QTaZrMAcPayyPdqe1WflKdi0iyc(rQifED62HFKiBh(rQRjKcGHLoa92kMwnc6RVpE2MqyGSbIiO)GWrH(iSdicRmouTkcFh(yqMrQiLTd)ibKTHPWocQyFQFj1JiquRkqKjhtMk8tpunlEz901Afov9gk92KJjtLJP(Yv4ufHLPvBbMJWpdlvZVfxIOgUyHCaHgbtWpsfPWRt3o8Jez7WpcsedlvZVfxIG(67JNTjegiBGic6piCuOpc7aIWkJdvRIW3HpgKzKksz7WpsazBWtHDeuX(u)sQhHLPvBbMJWKJAjCJ1dTpyernCXc5acncMGFKksHxNUD4hjY2HFeEKJAjCJEt0(Gre0xFF8SnHWazderq)bHJc9ryhqewzCOAve(o8XGmJurkBh(rciGice1QcejGe]] )

    storeDefault( [[SimC Fury: movement]], 'actionLists', 20171203.130909, [[b4vmErLxtvKBHjgBLrMxI51uofwBL51utLwBd5hygvNC5PJFG12B2vwBL5gDEnLuLXwzHnxzE5KmWeZnXetm54smEn1uWv2yPfgBPPxy0L2BU5Lt3iJxtf0y0L2BUnNxu5LtX4fvEnvrUfMySvgzEjMxtfKyPXwA0LNxtHwzY9wAJ9fBLfgCEnvsUrwAJfgDVjNxt52BUvMxt10BKzvyY5uyTvMxt51uofwBL51uivMCVL2y(bgtLfgCEnLuLXwzHnxzE5KmWeZnXaJxtjvzZ9wDYnwzZ5fvErNxtneALn2An9MDL1wzUrNxI51un9gzofwBL51uErNx051utnMCPbhDEnLx05Lx]] )

    storeDefault( [[SimC Fury: AOE]], 'actionLists', 20171203.130909, [[dStcfaGEHQ0MGQYUKsBtOI2hufZwuZNOYnfYTf55kzNs1EP2nH9dLFkufdtr(nQoSKVPadgsdxahuH6uqv1XiY5eQQfkOwkeTyLA5O8qvkpfzzc06iQsNxLQPcHjtQPRQlQGonjxgCDPyJcvQTsuSzOY2fkpwfFvLittLO(UG8mHkzEcvy0kQ)Qs4KeL(Sc5Aevv3JOkgfuLoerv51QK2sgHPHIANbT3M6vcmrQ0nm04UHDxEXqhhpdnHeYqTa3dojnqssk(TsMOaWrvzv8wVIlCFqqtJpVIlwgH7sgHPHIANbTdBIomvG30UbhUwqWQrqRMhsGHkNCyOSAe0EAymq8yOXbgA8NmnERYQ)UPDMZ1)SITEtYk0Qt9CMjbxaMI4AzkwVsGjt9kbMcN5C9pRyR3esid1cCp4K0aPjtiHfVHDGLr430Tz4CnIhdsG492uex3ReyYV7bnctdf1odAh2eDyQaVPDdoCTGGvJGwgKkLyHHIhm0GyO4ddToVkgCbiGKcwyO4bdvY04TkR(7M25sdRNZsMKvOvN65mtcUamfX1YuSELatM6vcmfoxAy9CwYesid1cCp4K0aPjtiHfVHDGLr430Tz4CnIhdsG492uex3ReyYV7XLryAOO2zq7WMOdtf4nTBWHRnb1FXjdvmG1Q5HeMgVvz1F3uOzflhsj0MKvOvN65mtcUamfX1YuSELatM6vcmDPzflhsj0MqczOwG7bNKginzcjS4nSdSmc)MUndNRr8yqceV3MI46ELat(D)YgHPHIANbTdBIomvG30UbhU2eu)fNmuXawBtamu8HHIxm0DdoCTGGvJGwnpKadfFyOYhg6xzq8T4y8FwjgDXgylGDfyTGO2zqJHkNCyO7gC4At1Avhg02eadvo5Wqz1iO90WyG4XqXJ8GHknnHHIFtJ3QS6VBIvPa1iWKScT6upNzsWfGPiUwMI1ReyYuVsGjKvkqncmHeYqTa3dojnqAYesyXByhyze(nDBgoxJ4XGeiEVnfX19kbM87U8BeMgkQDg0oSPXBvw93nTZCU(NvS1BswHwDQNZmj4cWuexltX6vcmzQxjWu4mNR)zfB9yO4vc)MqczOwG7bNKginzcjS4nSdSmc)MUndNRr8yqceV3MI46ELat(Dponctdf1odAh204TkR(7McnRy5qkH2KScT6upNzsWfGPiUwMI1ReyYuVsGPlnRy5qkHgdfVs43esid1cCp4K0aPjtiHfVHDGLr430Tz4CnIhdsG492uex3ReyYVFt0HPc8M8Bda]] )

    storeDefault( [[SimC Fury: execute]], 'actionLists', 20171203.130909, [[d4tWiaGAskwVkk2KkQ2LcTnsQu7JKs65KA2k18fP4Mc1JLQBRKdlzNszVu7MW(HYpjPkgMk8BuopQQtlyWqA4cXbHOoLc4yK4CQO0cvqlfclwLworpeI8uKLrswhjvY3urMkuzYkA6Q6IIKNrsjUm46IAJqvAROs2Si2oQOplKMhuftJKs57Iu6VOchIKkA0OkJxb6KOs9AOQUgjv19iPunosQsFIKkmkrQ2kgNPuI6UHPVMA1cmrHfsyO4nl5RUWqHbHE(btiGnuAWnvhkNuuuo7OIjkc0d1oCM6dmHBNuzc5(hycTX5MIXzkLOUBy6HMOUme5nDZjjJjz1eGzP5ijl5pMJGHEog6nNKmMKvtaMLMJKSK)OewvqOXqXdgQktiFd7WZ30DZyZNxqQFtClMHE9mPjbtaMIztUkzRwGjtTAbMgUzS5Zli1VjeWgkn4MQdLtkhMqaAww2bTX53es8Go(XmoHfiEFnfZMTAbM87MkJZukrD3W0dnrDziYBQKFiP6)OAYrJcsrL)rqu3nmXqphdnDmu1jg6nNKmQMC0OGuu5FmhbdnnPbd9MtsgvtoAuqkQ8pkHvfeAmu8GHQcdDam00Kgm0Bojzu)mbWbpOK)yoIjKVHD45Bcge65hmXTyg61ZKMembykMn5QKTAbMm1Qfyk1Gqp)GjeWgkn4MQdLtkhMqaAww2bTX53es8Go(XmoHfiEFnfZMTAbM87MAX4mLsu3nm9qtuxgI8M(AdIFmrcIZWFee1Ddtm0ZXqV5KKXejiod)rjSQGqJHIh1ogQktiFd7WZ3uswgyznh6DP5zIBXm0RNjnjycWumBYvjB1cmzQvlWeEZYalRXqPDP5zcbSHsdUP6q5KYHjeGMLLDqBC(nHepOJFmJtybI3xtXSzRwGj)UP2motPe1Ddtp0e1LHiVPoJTNS0kgV1)BGJUK)OewvqOXqXdgQ6Bc5ByhE(MGbHE(btClMHE9mPjbtaMIztUkzRwGjtTAbMsni0ZpGHMUYaMqaBO0GBQouoPCycbOzzzh0gNFtiXd64hZ4ewG491umB2QfyYVBQVXzkLOUBy6HMOUme5nDZjjJRsRRUegZrWqphd9MtsgbHSIcJsyvbHgdfpyOkMq(g2HNVjzTIurbtClMHE9mPjbtaMIztUkzRwGjtTAbMquRivuWecydLgCt1HYjLdtianll7G248BcjEqh)ygNWceVVMIzZwTat(DtDBCMsjQ7gMEOjKVHD45Bcge65hmXTyg61ZKMembykMn5QKTAbMm1Qfyk1Gqp)agA6QgWecydLgCt1HYjLdtianll7G248BcjEqh)ygNWceVVMIzZwTat(D7KXzkLOUBy6HMq(g2HNVP7MXMpVGu)M4wmd96zstcMamfZMCvYwTatMA1cmnCZyZNxqQFm00vgWecydLgCt1HYjLdtianll7G248BcjEqh)ygNWceVVMIzZwTat(Dt9ACMsjQ7gMEOjQldrEtA454Yez94haPYz5qvKogQAfd9WeY3Wo88nLKLbwwZHExAEM4wmd96zstcMamfZMCvYwTatMA1cmH3SmWYAmuAxAEyOPRmGjeWgkn4MQdLtkhMqaAww2bTX53es8Go(XmoHfiEFnfZMTAbM872znotPe1Ddtp0eY3Wo88njRObruoUBwAnXTyg61ZKMembykMn5QKTAbMm1QfycrfniIIHoCZsRjeWgkn4MQdLtkhMqaAww2bTX53es8Go(XmoHfiEFnfZMTAbM87MYHXzkLOUBy6HMOUme5n9SOr3Wyj)qs1Fm0ZXqthd9MtsgbHSIcJ5iyONJHkROWyplLG4XqXdgQYXbg6aMq(g2HNVj2KVqZrswY3e3IzOxptAsWeGPy2KRs2QfyYuRwGj1ZKVqDOXqXBwY3ecydLgCt1HYjLdtianll7G248BcjEqh)ygNWceVVMIzZwTat(DtrX4mLsu3nm9qtiFd7WZ3uswgyznh6DP5zIBXm0RNjnjycWumBYvjB1cmzQvlWeEZYalRXqPDP5HHMUQbmHa2qPb3uDOCs5WecqZYYoOno)MqIh0XpMXjSaX7RPy2SvlWKF)MOUme5n53g]] )


    storeDefault( [[Fury Primary]], 'displays', 20171203.130909, [[dWdTgaGEPOxIkYUGQcBtQs1mPcnBfEmsDtKu9Bi3wrDnPk2jL2Ry3eTFQOFcWWa04qf1ZPyOO0GPkgoIoOu6BqvvhtQCCuHfsvTuQGftOLtQhkfEQQLjv16GQstuQsMkuMmQ00v6IkYvrs5YGUoqBej2QuLYMjy7i4JuL8zOY0GQkFNknsKKEgscJgfJhQYjrOBHKOttY5rvhwYAHQIEnvPoDblNUixfssbj3V8dyoaQH5ir7uoDrUkKKcsUx1egBx)CDjXbBWaP9o(5IdvZMEnqUrmNhGGGbUnkYvHKMybMJhabbdCBuKRcjnXcmNdqiiKlrAK8QMWy7by(Ss2oflvKZbieeYTrrUkK0e)CEaccg4IvACW1elWCddY9UQLMPDk(5ggKBl4IIFUHb5Ex1sZ0cUO4NVLghCBL0miDUpammau3bIErvSC8aiiyGlN8nX2LZdqqWaxo5BILk7YnmixSsJdUM4N7TyRKMbPZXaW6arVOkwUsYvrxls3kPzq6Chi6fvXYPlYvHKTsAgKo3haggaQNFsiTQgQM1QqYyX)(5ggK7XIFohGqqyVuAi9QqYChi6fvXYLGZePrstS4xUHeogugLHPbAG0blVITlxm2UCCX2LRJTlBUHb52OixfsAIyoEaeemWTfuxXcmVa1fgpjmxeuqiFUWRfCrXcmxCOA20RbYTDmIyEnizQZGCzjmfBxEnizQgOzXAzjmfBxEVGcf4yJFEnClEdlb24NtqzuIQHA5X4jH5I50f5QqY2HcNmVXKfBYHCUkd5O4X4jH5vUUK4Gy8KW8sunulFEbQlQRKW4N7TifKCVQjm2U(51GKPWkno4YsGn2UCnCK3yYIn5qUHeogugLHjI51GKPWkno4Ysyk2UCoaHGqUeLCv01I0M4NBRzyofqnVtpSA1CP5Z3sJdUuqY9l)aMdGAyos0oLpRKTGlkwG5Elsbj3V8dyoaQH5ir7uoFSuz)(9KxdsMQD4w8gwcSX2LJxSaZj1Q5sZtbj3RAcJTRFoPgsJMfRTL1X8RMB40dfqnp(60dPgsJMfRnxrJK4teAo2UEYNl8ANIfyUIgjpzrRK4If)Y3sJdUSeMIyoPwnxAEI0i5vnHX2dWCddYLLaB8Z5aeccBhkCYzOCZPZXdGGGbUeLCv01I0MybMZdqqWaxIsUk6ArAtSaZ3sJdUuqYnNfZPNxsJtp2sRrU54bqqWaxSsJdUMybMByqUeLCv01I0M4NByqUTG6IOuafX8A4w8gwctXp3WGCzjmf)CddYTDk(50OzXAzjWgX8cuxTsAgKo3haggaQ74efS8cuxNeoge7vSaZ5aur7DVPmF5hW8kFwjpwSaZ3sJdUuqY9QMWy76NxG6IOuaHXtcZfbfeYPlYvHKuqYnNfZPNxsJtp2sRrU51GKPAGMfRLLaBSD5tYsCa5g)CJAMCaBbmfB)CEaccg42cQRybM7TifKCZzXC65L040JT0AKBEnizQ2HBXByjmfBx(wACWLLaBeZPrZI1YsykI5ggKlNG8IkjxLeNj(5oahWYaJTpWo8hyV3NZ4JoQOho3dNZNl8owSD51GKPodYLLaBSD5CacbHCPGK7vnHX21pxaj3CwmNEEjno9ylTg5MZbieeYLt(M4NZfkuGJTL1X8RMB40dfqnp(60dxOqbo28cuxutQ2CYrXd1zta]] )

    storeDefault( [[Fury AOE]], 'displays', 20171203.130909, [[dWdSgaGEfXlrQYUGQI2guvyMsrMTchwYnrQyCsH62kQNbvv2jL2Ry3eTFQOFkvnmv0VHSmfPHIkdMkmCeDqQYPj5yuvhhvXcvHLIQ0IrYYP4HsPEk4XOyDqvvtukKPcLjJQA6kDrPYvrQQlRQRRsBeH2kuvYMjy7iLpkf1NHkttkqFNknsKk9nPGgnknEOkNeb3skGRjL05j0Zj1AHQs9APeh)GfGPixfssejxyfhFGE6J1ebBxGTm4(LJgxOcykjUVn7Z0socWZ9VV3qHto)YnataXEbb9VTlYvHK6ypdGxVGG(32f5QqsDSNbinQ5YisGbjb1Kp2wpdmRKEDXIFb45(3NF7ICviPohbe7fe0)IvgC)QJ9mGMf5cUQLH1Rlub0SixV7IcvafdscKfJsIl2wdSLb3VEsgwKjWrpgwpD4LqZ0flaE9cc6FP3How)aI9cc6FP3Ho2gWpGMf5IvgC)QZrGwO8KmSitaSEoEj0mDXcOK8vm1ImEsgwKjaVeAMUybykYvHKEsgwKjWrpgwpDcaKpJQgQj1QqYyB40aAwKlGLJa8C)73iL5zwfsgGxcntxSaY7mbgKuhBdgqt(JbXrPzBJgitWcuX6hWeRFaCX6hGkw)Sb0Si32f5QqsDOcGxVGG(xVRPI9mqDnfMi5hG6kieyUWZ7UOypdqnutM08a56ngHkqnizlGf5YrRlw)a1GKTAJMPQLJwxS(bA0lu3XgQa1WTe1C04YraAkTIsnuRiMi5hGkatrUkK0BOWjd0UZI1XBa(kn5OeXej)ambmLe3Jjs(bkk1qTIbQRPOJs(5iqluerYfut(y9NgOgKSfwzW9lhnUy9dy(rG2DwSoEdOj)XG4O0SHkqnizlSYG7xoADX6hGN7FF(eK8vm1Im6CeWwZFaIxJOthE9Db2YG7xIi5cR44d0tFSMiy7cW)fQ7y94AkaOMB70bXRre)D6G)lu3XgOfkIi5cR44d0tFSMiy7ciGKBaomNoGsQD6WwgdYnqnizlVHBjQ5OXfRFaXyBa)gEgG0OMlJirKCb1Kpw)PbinpdAMQwpUMcaQ52oDq8AeXFNoinpdAMQ2a1GKTawKlhnUy9dmx451f7zanlYfCvldR3Dr5iWwgC)YrRlub0SixoAC5iaV)4l9h70t)gEIpM2y8Pp(1AJBTXb0Six69IukjFLeNohbyqZu1YrRlubykYvHKerYfut(y9NgOgKSL3WTe1C06I1pqluerYnahMthqj1oDylJb5gqZICji5RyQfz05iGyVGG(xVRPI9mqnClrnhTUCeqZIC96cvanlYLJwxocWGMPQLJgxOcuxt5jzyrMah9yy90PPoIybQbjB1gntvlhnUy9dWZvX0c(sPHvC8bOcmRKawSNb2YG7xIi5cQjFS(tduxtrqkGWej)auxbHamf5QqsIi5gGdZPdOKANoSLXGCduxtbK)yqOrXEgOtwuJNFocOvZKJ3RVl2Pb0SixVRPiifqHkaE9cc6FXkdUF1XEgyldUFjIKBaomNoGsQD6WwgdYnGyVGG(xcs(kMArgDSNbWRxqq)lbjFftTiJo2Zaud1KjnpqUHkap3)(8jWGKGAYhBRNbMl8aSy9dOyqs8ncnhRFRb45(3NprKCb1Kpw)PbWl2Za8C)7ZNEh6Ceywj9Ulk2Za11u0xQ2aKJs8nzta]] )

    storeDefault( [[Arms Primary]], 'displays', 20171203.130909, [[dWdTgaGEfLxIsQDjvqBdkfntPkMTcpgPUjkj)gYTPQUMuL2jL2Ry3e2pvYpbyyaACsf65KmuKmyQudhrhKu9nOu1XKIJJszHsPLIs1IjLLtXdLQ6PQwMIQ1bLktuQOMkqtgvz6kDrf5QOeUmORJWgrvTvOuYMrLTdv(OuP(mumnOu47uLrIs0ZKkYOrX4Hsoju1TKkWPj68uXHLSwOuQxlvYPjG50f5krc(iX(1zaZbWcWEWBNYPlYvIe8rI9YzWyBMNBkbgyFgiDxPnxBiNnR7bYlA5oa44uWTFrUsKqflWCSaWXPGB)ICLiHkwG5SrajG8WtJexodgBVaZ9Lc9Py7uoBeqciV(f5krcvAZDaWXPGlyzWaxvSaZvmiV7jxAg9P0MRyqE6elkT5kgK39KlnJoXIsB(wgmWvxqZGm5TaabbWk2X3nlbZXcahNcUSUvfBtUdaoofCzDRk2oOjxXG8aldg4QsBExA6cAgKjheaf747MLG5sbpjDTiJUGMbzYzhF3SemNUixjsOlOzqM8waGGayv(jH0YAiNvRejIf7BYvmiVdM2C2iGeWolnq6vIe5SJVBwcMli8XtJeQyXg5ks4yWFukM(ObYeW8k2MCTyBYXeBtUj2MS5kgKx)ICLiHkA5ybGJtbxDctflW8IWuGoKWCncoUC)clDIfflWCTHC2SUhip9XiA51GKPodYJc3uSn51GKP6J81QLc3uSn5DgYveJnT51WRCuu4OsBooPsQjhY1b0HeMRLtxKRej0hsmI8(twWj2Z5jvKJYb0HeMx5MsGbc6qcZln5qUo5fHPyLuatBExA8rI9YzWyBMNxdsMcSmyGlfoQyBYnWrE)jl4e75ks4yWFukMOLxdsMcSmyGlfUPyBYzJasa5HxWtsxlYOsBUT8H56gFLl3ugPFzCY3YGbU8rI9RZaMdGfG9G3oL7lf6elkwG5DPXhj2Vodyoawa2dE7uUtSDW8obmVgKmL(WRCuu4OITjhRybMtAK(LXHpsSxodgBZ8CsdKg5RvRovp5x633LBDJVc7C5M0aPr(A1MlPrcSnc5hBtV5(fw6tXcmxsJeNSOLcmX2B(wgmWLc3u0Yjns)Y4GNgjUCgm2EbMRyqEu4OsBoBeqcO(qIr4dfBoDowa44uWfVGNKUwKrflWChaCCk4IxWtsxlYOIfy(wgmWLpsS5uGUC)sOC52wgdYlhlaCCk4cwgmWvflWCfdYdVGNKUwKrL2CfdYtNWu4fCOOLxdVYrrHBkT5kgKhfUP0MRyqE6tPnNg5RvlfoQOLxeMsxqZGm5TaabbWQEM4dMxeM6KWXaFNJfyoBes6UWws1xNbmVY9LIdglW8TmyGlFKyVCgm2M55fHPWl4qGoKWCncoUC6ICLibFKyZPaD5(Lq5YTTmgKxEnizQ(iFTAPWrfBt(KO0gqEPnxj9jhqDatXop3bahNcU6eMkwG5DPXhj2CkqxUFjuUCBlJb5LxdsMsF4vokkCtX2KVLbdCPWrfTCAKVwTu4MIwUIb5XAOJMuWtkWOsBo7WbSuWyNdSb7bInN3XoSPt92XE7yUFH1bJTjVgKm1zqEu4OITjNncibKhFKyVCgm2M55CiXMtb6Y9lHYLBBzmiVC2iGeqESUvL2CEqUIyS6u9KFPFFxU1n(kSZLBEqUIyS5fHPyHqU5KJYbAYMaa]] )

    storeDefault( [[Arms AOE]], 'displays', 20171203.130909, [[dWtSgaGEa8susTlPaTnOu0mLsmBfEmsUjkj)gYTLkxtkPDsXEf7MW(Pc)urggGgNuOEordfvgmv0Wr0bjPVjf0XOshhLYcvulfLQfJulNspuk1tvTmaADqPQjkfYubAYKW0v6IsvxfLOld66iSrs0wHsjBgvTDOYhLI6ZqX0GsHVtvgjkHNbLkJgfJhk5Kqv3skGttQZtvDyjRfkL61sroUbmNQixnsOej2V(dy(elbBbVPpNQixnsOej2RbagJlG52sGb2Mbs1uMZPhAaaO5bYl05(t88s42UixnsiJbyowt88s42UixnsiJbyoBeqcOc8uiX1aaJPvG5DAHAFmyxoBeqcOI2f5QrczMZ9N45LWfSSyGRmgG5sgK390lfJAFOZLmipvIff6CjdY7E6LIrLyrzoFllg4QkOyq285jqWjwXo(Mzbyowt88s4Y6zzmU5(t88s4Y6zzmnGBUKb5bwwmWvM58MOvfumiBo4eh74BMfG5AHcnvTiRQGIbzZzhFZSamNQixnsOkOyq285jqWjwLFsiLUgAaQvJeX0q3CjdY7GzoNncibSrAlKA1iro74BMfG5cIo8uiHmgSrUKeogkhLKPnAGSbmVIXnNog3CmX4MBJXnBUKb51UixnsidDowt88s4QsyRyaMxe2c0NeMttWZN3vyPsSOyaMtp0aaqZdKN6ye68AqYuNb5XHRpg38AqYuTrD01YHRpg38gb5lIXM58A4v(soCCzohNwQP1d96d6tcZPZPkYvJeQdngrE7Edyp75k0sYr5d6tcZPYTLade0NeMx06HE9ZlcBXkTaM58MOvIe71aaJXfW8AqYuGLfdC5WXfJBUfoYB3Ba7zpxschdLJsYe68AqYuGLfdC5W1hJBoBeqcOc8cfAQArwzMZnvhmx12jD4uDQpFllg4Qej2V(dy(elbBbVPpVtlujwumaZBIwjsSF9hW8jwc2cEtFUFmnGBdbMxdsMsD4v(soCCX4MJvmacmN0Q7kRVsKyVgaymUaMtAHuOo6Av5Aj)6U2oCQA7KyVdNKwifQJU2CnfsGTrOUyCBnVRWsTpgG5AkK4KfLwGjMwZ3YIbUC46dDoPv3vwF8uiX1aaJPvG5sgKhhoUmNZgbKaQo0yeDqXMtLJ1epVeU4fk0u1ISYyaM7pXZlHlEHcnvTiRmgG5BzXaxLiXMZb6W5lH0HttzTiVCSM45LWfSSyGRmgG5sgKhEHcnvTiRmZ5sgKNkHTWl4rHoVgELVKdxFMZLmipoC9zoxYG8u7dDofQJUwoCCHoViSLQGIbzZNNabNyvl9kbZlcBDs4yGVrXamNncnvtylT8R)aMtN3PfhmgG5BzXaxLiXEnaWyCbmViSfEbpc0NeMttWZNtvKRgjuIeBohOdNVeshonL1I8YRbjt1g1rxlhoUyCZ7ff9aQiZ5sDh5aQo1hdG5(t88s4QsyRyaM3eTsKyZ5aD48Lq6WPPSwKxEnizk1Hx5l5W1hJB(wwmWLdhxOZPqD01YHRp05sgKhRH(0AHcTaJmZ5SdhWscJbqGUnei2eWg3GUyxRnU1gN3vyDWyCZRbjtDgKhhoUyCZzJasavOej2RbagJlG58iXMZb6W5lH0HttzTiVC2iGeqfSEwM5Cfq(IySQCTKFDxBhovTDsS3Htfq(IyS5fHTyPqV5KJYhAZMaa]] )



end
