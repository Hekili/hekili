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
   
    storeDefault( [[Fury Universal]], 'actionLists', 20170628.135858, [[di00qaqiQuQnjumkbYPeqVIkfXTOsrAxuXWaXXKuldaptOutdGY1Osj2Mav(grX4OsH6CuPKMhkLUhazFcuoOGAHGupeKmrQuGlIs1gfk5KuPAMOu0nb0orXpPsHSuI0tjnvIQRsLcARcWEv9xjzWeoSOfd0JPQjlXLH2Sq1NjIrtLCAkTAQuuVguz2uCBLA3i(TIHJsooavlhPNRKPl11fY2fKVdQA8Ou48GY6fOQ5tuA)O6xF5xzNKGgSCWRm5gVgRikmUWnKydH0vAUkfnyUWZaaKAzGeC1X2P(Q6Pww91RH9TDiRl)m1x(v2jjOblh6RQNAz1xdIlqapYYIfwC8djesLGepwnXRINnU4Iy4c)mMYapXbm72GvEkmhkUtlzXfSLlaGlcKlKvwUWT5ceWJSSyHfh)qcHujiXJvt8Q4zJlUigUiiUWT5c)mMYapXbm72GvEkmhkUtlzXfSfqCrneUqwz5c)mMYapXbm72GvEkmhkUtlzXfSLlaGlc8AyqRX2WUwOPKHurNKE1DsX6ZEOxjdbVcCkbKuMCJxVYKB8QBanLmeUq6K0RsrdMl8maaPwMAixLIRjI6X1L)(kuUqpCaNq4gj9bVcCkm5gV((maC5xzNKGgSCOVQEQLvF1pJPmWtCaZUnyLNcZHI70swCbB5caJlIHl6KkbBhxyAAxoS8nxemUaaixddAn2g2vAUzLsWRUtkwF2d9kzi4vGtjGKYKB86vMCJxLMBwPe8Qu0G5cpdaqQLPgYvP4AIOECD5VVcLl0dhWjeUrsFWRaNctUXRVptSV8RStsqdwo0xvp1YQVIaEKLflS4axg8bFAs2OkEKB2ILCvfpIcJlIHlaJIh3jEKB2ILCvfpIcZPmWtUgg0ASnSRGMzkTllD1xDNuS(Sh6vYqWRaNsajLj341Rm5gVcTzMs7Ysx9vPObZfEgaGultnKRsX1er946YFFfkxOhoGtiCJK(GxbofMCJxFFga7YVYojbny5Gxvp1YQVcgfpUdy2TbR8uyouCNwYIlcgxeCCHSYYf(zmLbEIdy2TbR8uyouCNwYIlylxudHlKvwUiiUOtQeSDA7gR6PQyrUGTCrqCHFgtzGN4aMDBWkpfMdf3PLS4c3eUOgcxeixe41WGwJTHDndLDsV6oPy9zp0RKHGxboLasktUXRxzYnEnCOSt6vPObZfEgaGultnKRsX1er946YFFfkxOhoGtiCJK(GxbofMCJxFFg3YLFLDscAWYH(Q6Pww9v)mMYapXrIzattLFgtzGN4qXDAjlUaqCbeUigUOtdsAhk6HZGRvvcMKYqCqscAWcxedxeexGaEKLflS4eTbPPPApdrIjTHWfxedxeexWIIHQM4XRK4lorBqAAQ2ZqKysBiCXfYklxeex0ulboSD8Zykd8ehkUtlzXfbJlInxedx0ulboSD8Zykd8ehkUtlzXfSLlCRq4Ia5Ia5czLLlCBUab8illwyXjAdstt1EgIetAdHlUiWRHbTgBd7ky2TbR8uyxDNuS(Sh6vYqWRaNsajLj341Rm5gVcD2Tb5cOOWUkfnyUWZaaKAzQHCvkUMiQhxx(7Rq5c9WbCcHBK0h8kWPWKB867ZeCx(v2jjOblh6RQNAz1x9Zykd8ehjMbmnv(zmLbEIdf3PLS4caXfq4Iy4IoniPDanzbx9q3oijbnyHlIHlcIlsFBdHvib3wC5aAYcU6HUR2U4IGXf1CrGxddAn2g2vWSBdw5PWU6oPy9zp0RKHGxboLasktUXRxzYnEf6SBdYfqrHXfbvh4vPObZfEgaGultnKRsX1er946YFFfkxOhoGtiCJK(GxbofMCJxFFgzU8RStsqdwo0xvp1YQV6NXug4josmdyAQ8Zykd8ehkUtlzXfaIlGWfXWfGrXJ7uOPKHurNK6eXIlIHlcIl8Zykd8ehqZmL2LLUAhkUtlzXfaIlGWfYklxagfpUdsOPe0HI70swCrW4c)mMYapXb0mtPDzPR2HI70swCrGxddAn2g2vWSBdw5PWU6oPy9zp0RKHGxboLasktUXRxzYnEf6SBdYfqrHXfbbqGxLIgmx4zaasTm1qUkfxte1JRl)9vOCHE4aoHWns6dEf4uyYnE99zCJV8RStsqdwo0xvp1YQVcgfpUtHMsgsfDsQtelUqwz5c3Ml60GK2PqtjdPIoj1bjjOblCrmCbyu84oGz3gSYtH5eX6AyqRX2WUcAMPaMTRRUtkwF2d9kzi4vGtjGKYKB86vMCJxH2mtbmBxxLIgmx4zaasTm1qUkfxte1JRl)9vOCHE4aoHWns6dEf4uyYnE99zCRx(v2jjOblh6RQNAz1xbJIh3bm72GvEkmNiwxddAn2g2vqZmLQ4ruyxDNuS(Sh6vYqWRaNsajLj341Rm5gVcTzMcxeRikSRsrdMl8maaPwMAixLIRjI6X1L)(kuUqpCaNq4gj9bVcCkm5gV((m1qU8RStsqdwo0xvp1YQVcgfpUdy2TbR8uyorSUgg0ASnSRGiDHu4SejxDNuS(Sh6vYqWRaNsajLj341Rm5gVcnsxifolrYvPObZfEgaGultnKRsX1er946YFFfkxOhoGtiCJK(GxbofMCJxFFM66l)k7Ke0GLd9v1tTS6R0uc64JOuK0CbB5cAkbD2jBWfUPCbGb5AyqRX2WUMuFsWQEOuK0xDNuS(Sh6vYqWRaNsajLj341Rm5gVgM6tcYfYhkfj9vPObZfEgaGultnKRsX1er946YFFfkxOhoGtiCJK(GxbofMCJxFFMAaU8RStsqdwo0xvp1YQVcgfpUdy2TbR8uyorS4Iy4I032qyfsWTfxCbG4I6RHbTgBd7knIuL(2oKkJD1xDNuS(Sh6vYqWRaNsajLj34v)mMYapzDLj34vPreUiSVTdHlyt7Q5IGQd8AyQK1vsUra5NXug4jRRsrdMl8maaPwMAixLIRjI6X1L)(kuUqpCaNq4gj9bVcCkm5gVgRikmUaQzmLbEY69zQJ9LFLDscAWYH(Q6Pww91oPsW2XfMM2LdlFZfbJlaacxedxeexK(2gcRqcUT4Il4caXfXMlKvwUi9TnewHeCBXfxaiUaW4IaVgg0ASnSR(0yQsFBhsLXU6RUtkwF2d9kzi4vGtjGKYKB8A7IIyvNujyVUYKB8kuPXWfH9TDiCbBAx91WujRRKCJaQDrrSQtQeSxxLIgmx4zaasTm1qUkfxte1JRl)9vOCHE4aoHWns6dEf4uyYnEnwruyCbugmdHCrSFFMAa7YVYojbny5qFv9ulR(A6BBiScj42IlUGlcgxayxddAn2g2vFAmvPVTdPYyx9v3jfRp7HELme8kWPeqszYnEnh8ktUXRqLgdxe232HWfSPD1Crq1bEnmvY6kj3iGYbVkfnyUWZaaKAzQHCvkUMiQhxx(7Rq5c9WbCcHBK0h8kWPWKB8ASIOW4IWUrS)(m1ULl)k7Ke0GLd9v1tTS6RDsLGTJlmnTlhw(MlylxaaKRHbTgBd7knIuL(2oKkJD1xDNuS(Sh6vYqWRaNsajLj34vKnqFuJxzYnEvAeHlc7B7q4c20UAUiiac8AyQK1vsUraHSb6JA8Qu0G5cpdaqQLPgYvP4AIOECD5VVcLl0dhWjeUrsFWRaNctUXRXkIcJlyNnqFuJVptDWD5xzNKGgSCOVQEQLvFTtQeSDCHPPD5WY3CrW4caGCnmO1yByxPrKQ032HuzSR(Q7KI1N9qVsgcEf4uciPm5gVUSejgSQtQeSVYKB8Q0icxe232HWfSPD1CrqXoWRHPswxj5gb0YsKyWQoPsW(Qu0G5cpdaqQLPgYvP4AIOECD5VVcLl0dhWjeUrsFWRaNctUXRXkIcJlulrIbF)(QYc920yd(STd5mYaW7Fa]] )

    storeDefault( [[Fury AOE]], 'actionLists', 20170628.135858, [[dOJffaGEPOQnbvXUeY2KQW(GQ0Sf18HQ6Mc1TfzNkSxQDty)q5NsrPHjL(nIVPiESkgmKgUaoOuvNsLKJruNtkkwOGAPqyXk1Yr6HeHNIAzc0ZvYHLmviAYKA6Q6IksNxLYLbxxQSrPiARerBgQSDPWPj5RQKY0KIKVliptQIETkvJwrnpvs1jjsgLuLUMuu5EsrQpRs8xIuhskcBzJ08urTZG2BZJkbMBYo6nm0(n7uZiGmulWJGTYtA7HCpJKnZhQkWB2C)ZRiILr6HSrAEQO2zq7WM5dvf4nV7WHlce06cePjHeyO4JpgkTUarNokfepg61XqBMwZ93QS6VzENje9pROR3SucT6upHAwqeG5yIwYIoQey28OsG5Wzcr)Zk66nJaYqTapc2kprU1mcyr6OhyzK(nlXmCUhtAajq8EBoMOhvcm73JGgP5PIANbTdBMpuvG38UdhUiqqRlqefsLsSWqXlgAqmu8GH2lgADEvdqAqajfSI25sdRNqtsNMXqXlgQmg6vM7Vvz1FZ8oxAy9eAYSucT6upHAwqeG5yIwYIoQey28OsG5W5sdRNqtMrazOwGhbBLNi3AgbSiD0dSms)MLygo3JjnGeiEVnht0JkbM97rpnsZtf1odAh2mFOQaV5DhoCrjOEPpzOAa0injKWC)TkR(BMdnRO5qkH2SucT6upHAwqeG5yIwYIoQey28OsG5RnRO5qkH2mcid1c8iyR8e5wZiGfPJEGLr63SeZW5EmPbKaX7T5yIEujWSFpAkJ08urTZG2HnZhQkWBE3HdxucQx6tgQganQlagkEWq7fdD3HdxeiO1fistcjWqXdgAtGH(vgeFeok5NvIlsVb6cO3bAeiQDg0yO4Jpg6UdhUOuTw1HcrDbWqXhFmuADbIoDukiEmu820yOYTTyOxzU)wLv)nZ0kfOUaMLsOvN6juZcIamht0sw0rLaZMhvcmJOsbQlGzeqgQf4rWw5jYTMralsh9alJ0VzjMHZ9ysdibI3BZXe9OsGz)E0CgP5PIANbTdBU)wLv)nZ7mHO)zfD9MLsOvN6juZcIamht0sw0rLaZMhvcmhoti6FwrxpgAVYxzgbKHAbEeSvEICRzeWI0rpWYi9BwIz4CpM0asG492CmrpQey2Vh9Winpvu7mODyZ93QS6Vzo0SIMdPeAZsj0Qt9eQzbraMJjAjl6OsGzZJkbMV2SIMdPeAm0ELVYmcid1c8iyR8e5wZiGfPJEGLr63SeZW5EmPbKaX7T5yIEujWSF)M5aWrvzvZxVIi8ysq)2]] )

    storeDefault( [[Fury Cooldowns]], 'actionLists', 20170628.135858, [[d8JTlaGAiH06HeWMGI2fQSnirAFKI6Wu9mijnBknFssCtf6BqHBdX5vuTtv1Ef7gL9lLFcjedtPACqI40uSmsPblPHdvDqsOtbj1XivNdsIfQOSuO0IvYYr8qsINs8yv55s8jibzQKOjlvtxLlcP6ZkYLbxhvTrssARKu2muz7KGVtk8vibAAqc18Gu61kWFvqJwPmEirDssQoejPCnss19if53iDCib1OGuC0JYiOZ8Lf6zf57iqevLNmVvvHsTDQgSseSGf8cKV2DDm2rP6OkNEe5rm4Viru8DgkReL5RhLrqN5ll0ZSiYJyWFro3cSJdXlf)raoG5ll0BvmB1fpoCCiEP4pcWXJVvXSvx84WXbmIpbCeaXnSsRI2wvpIIlJ1CZJqCe8(eerDw388JsIWOmiYiTRMt(ocejY3rGiyDe8(eeblybVa5RDxhd99iyHcLN8GsuMlIkBWBWivbabyxwrgP9VJarYLV2Omc6mFzHEMfrEed(lY5Kj442a3EBC4FxRI2wv7ERIzRU4XHJdyeFc4iaIByLwfTTQEefxgR5MhzzP0(TziLlI6SU55hLeHrzqKrAxnN8DeisKVJarMzP0(TziLlcwWcEbYx7Uog67rWcfkp5bLOmxev2G3GrQcacWUSIms7FhbIKlFunkJGoZxwONzrKhXG)IaOW8g84HoxN48tB3qkUHfkVT0Qy2Qpk12PAW46eNFA7gsXnSq5TfocG4gwPvrBRQ3Qy2QlEC44qr5NMacZ5pocG4gwPvrBRIQTkMT65Kj442a3EBC4FxRIwn1QA3JO4Yyn38iakdp(dIOoRBE(rjryugezK2vZjFhbIe57iqe0rz4XFqeSGf8cKV2DDm03JGfkuEYdkrzUiQSbVbJufaeGDzfzK2)ocejx(O4Omc6mFzHEMfrEed(lYIhhooGr8jGJhFRIzR(OuBNQbJJ4tg20WLLQbhbqCdR0QAUv3BvmB1ZjtWXTbU924W)UwvZTQ29ikUmwZnpcTpNvgIJNmpI6SU55hLeHrzqKrAxnN8DeisKVJarqr6ZzOqLwvv5jZJGfSGxG81URJH(EeSqHYtEqjkZfrLn4nyKQaGaSlRiJ0(3rGi5Yx1JYiOZ8Lf6zwe5rm4ViNtMGJBdC7TXH)DTkA1uRQDpIIlJ1CZJaOm84piI6SU55hLeHrzqKrAxnN8DeisKVJarqhLHh)bTkA0rDeSGf8cKV2DDm03JGfkuEYdkrzUiQSbVbJufaeGDzfzK2)ocejx(O0Omc6mFzHEMfrEed(lY5wGDCggdidj(eWbmFzHERIzRU4XHJdyeFc44XhrXLXAU5ri(KHnnCzPAerDw388JsIWOmiYiTRMt(ocejY3rGiy9jdBQvNzPAeblybVa5RDxhd99iyHcLN8GsuMlIkBWBWivbabyxwrgP9VJarYLpgrze0z(Yc9mlI8ig8xe0CUfyhhbEdSqPm0xoRtzCaZxwO3Qy2QQwREUfyhhoc92mSPHlGuaYaGWbmFzHoQBvvrvAv00QNBb2XHJqVndBA4cifGmaiCaZxwO3Qy2QeFc4E8ecWUwvZAQvrfuHdvAvu3QQIQ0QOPvx84WXHJqVndBA4cifGmaiCeaXnSsRQzn1QOyovVvBvmBvIpbCpEcbyxRQzn1QOevVvrDefxgR5MhH4i49jiI6SU55hLeHrzqKrAxnN8DeisKVJarW6i49jOvrJoQJGfSGxG81URJH(EeSqHYtEqjkZfrLn4nyKQaGaSlRiJ0(3rGi5YhLeLrqN5ll0ZSiYJyWFro3cSJJYFlEs54aMVSqVvXSvx84WXbmIpbCDQgSwfZwDXJdh3YVZcdFK5C84JO4Yyn38ilGuaYaGmK4tqe1zDZZpkjcJYGiJ0UAo57iqKiFhbImdifGmaiTkwFcIGfSGxG81URJH(EeSqHYtEqjkZfrLn4nyKQaGaSlRiJ0(3rGi5YhvIYiOZ8Lf6zwe5rm4VilEC44agXNaocG4gwPvrBRQ3Qy2QQwREUfyhhL)w8KYXbmFzHEefxgR5MhzzP0(TziLlI6SU55hLeHrzqKrAxnN8DeisKVJarMzP0(TziLRvrJoQJGfSGxG81URJH(EeSqHYtEqjkZfrLn4nyKQaGaSlRiJ0(3rGi5YxFpkJGoZxwONzruCzSMBEeIpzytdxwQgruN1np)OKimkdIms7Q5KVJarI8DeicwFYWMA1zwQgTkA0rDeSGf8cKV2DDm03JGfkuEYdkrzUiQSbVbJufaeGDzfzK2)ocejx(66rze0z(Yc9mlIIlJ1CZJSSuA)2mKYfrDw388JsIWOmiYiTRMt(ocejY3rGiZSuA)2mKY1QOrlQJGfSGxG81URJH(EeSqHYtEqjkZfrLn4nyKQaGaSlRiJ0(3rGi5YxxBugbDMVSqpZIipIb)fzXJdhNge4nWWMgUCRLJhFRIzRU4XHJdyeFc44XhrXLXAU5r0yZqSAyy9iQZ6MNFusegLbrgPD1CY3rGir(ocebfCZqSAyy9iybl4fiFT76yOVhbluO8KhuIYCruzdEdgPkaia7YkYiT)DeisU81r1Omc6mFzHEMfrEed(lIQHNakmC61505WXtmu(YWI1lBruCzSMBEeC8edLVmSy9Ywe1zDZZpkjcJYGiJ0UAo57iqKiFhbIOQ8edLV0QI1lBrWcwWlq(A31XqFpcwOq5jpOeL5IOYg8gmsvaqa2LvKrA)7iqKC5Ii4HNXTgua)muw(yOnxca]] )

    storeDefault( [[Fury Execute]], 'actionLists', 20170628.135858, [[d0JyjaGAuvA9qvytufTlszBuLu7JQqz2Qy(uLQBsv9nvs3wvDzWovyVIDtY(v0pPkunmOyCufspwIZtKgSsgoQYbHQ6uOQ4yKQZrvIwOkLLcvwSQSCuEirXtrwgu65uCAknvuXKvQPd5IskhwQNrvsUov2ivbBLiAZsY2vP6ZevZJO00OkeFhQIEnQQ(RKQrJknEvcNKiCiQs5AQeDpQsOrbvPprvc(nHJE4eQMQFhyNxOr)HqEWXKox1UakoeechCG2azGfJ(vmETUxPPhIkmlpuOq4xqwHYeozOhoHQP63b25wiQWS8qHEUQkTkhFTWUn1RCmPAoEZLNZ1ZvvPv54Rf2TPELJjvJb)2QmZLSZf2q4)ShlsAO3ri2iUwMbfsc12wAKGfsjuqiFXwYMn6pek0O)qOBhHyJ4AzguiCWbAdKbwm6x1XechyeowbmHtqHKHlu43xCh(GcLxiFXE0FiuqzGnCcvt1VdSZTquHz5Hc1mKTQlin(6KlhyQ2H0av)oWEU8CUW7C5T565QQ04RtUCGPAhsZXBU8U3NRNRQsJVo5YbMQDing8BRYmxYoxyNl(mxE37Z1ZvvPzqcfuNl0mKMJxi8F2JfjneCbuCiiKeQTT0iblKsOGq(ITKnB0FiuOr)Hq1UakoeechCG2azGfJ(vDmHWbgHJvat4euiz4cf(9f3HpOq5fYxSh9hcfugEv4eQMQFhyNBHOcZYdfc1hqH0QyGcpKQbQ(DG9C55C9CvvAvmqHhs1yWVTkZCjRxCUWoxEoxEJhdUxxEzRPRv5ywHZu3CAd3q4)ShlsAOkhZkCM6MtB4gsc12wAKGfsjuqiFXwYMn6pek0O)qip4ywHZmx0PnCdHdoqBGmWIr)QoMq4aJWXkGjCckKmCHc)(I7WhuO8c5l2J(dHckdps4eQMQFhyNBHOcZYdfQieNTapvAVgHoq9ctQgd(TvzMlzNRldH)ZESiPHGlGIdbHKqTTLgjyHucfeYxSLSzJ(dHcn6peQ2fqXHG5cV68jeo4aTbYalg9R6ycHdmchRaMWjOqYWfk87lUdFqHYlKVyp6pekOmUmCcvt1VdSZTquHz5Hc9CvvA)2y6cd0C8MlpNRNRQsduSwoOXGFBvM5s25spe(p7XIKgI1FETCiKeQTT0iblKsOGq(ITKnB0FiuOr)Hq46pVwoechCG2azGfJ(vDmHWbgHJvat4euiz4cf(9f3HpOq5fYxSh9hcfugED4eQMQFhyNBHW)zpwK0qWfqXHGqsO22sJeSqkHcc5l2s2Sr)HqHg9hcv7cO4qWCHxS8jeo4aTbYalg9R6ycHdmchRaMWjOqYWfk87lUdFqHYlKVyp6pekOmUgoHQP63b25wiQWS8qHyTCqR4ymqHMlzNlSxgc)N9yrsd9ocXgX1YmOqsO22sJeSqkHcc5l2s2Sr)HqHg9hcD7ieBexlZGMl8QZNq4Gd0gidSy0VQJjeoWiCScycNGcjdxOWVV4o8bfkVq(I9O)qOGYWJgoHQP63b25wiQWS8qHmaQ(tOCgnKfy6EzDS8kZLhBUWmxEoxSwoOvCmgOqZLSZf2ldH)ZESiPHQCmRWzQBoTHBijuBBPrcwiLqbH8fBjB2O)qOqJ(dH8GJzfoZCrN2WDUWRoFcHdoqBGmWIr)QoMq4aJWXkGjCckKmCHc)(I7WhuO8c5l2J(dHckdVmCcvt1VdSZTquHz5HcXA5GwXXyGcnxYoxyVme(p7XIKgI1YTk51FhbEgsc12wAKGfsjuqiFXwYMn6pek0O)qiCTCRs(CD7iWZq4Gd0gidSy0VQJjeoWiCScycNGcjdxOWVV4o8bfkVq(I9O)qOGYqht4eQMQFhyNBHOcZYdf65QQ0afRLdAoEZLNZfRLdAfhJbk0Cj7CH9Y5YZ5YBpxvL2RrOduVWKQ54fc)N9yrsdj2svM6voM0qsO22sJeSqkHcc5l2s2Sr)HqHg9hc5X3svEbZC5bhtAiCWbAdKbwm6x1XechyeowbmHtqHKHlu43xCh(GcLxiFXE0FiuqzORhoHQP63b25wiQWS8qH8gpgCVU8YwtxRYXScNPU50gUZLNZfRLdAfhJbk0Cj7CH9Yq4)ShlsAOkhZkCM6MtB4gsc12wAKGfsjuqiFXwYMn6pek0O)qip4ywHZmx0PnCNl8ILpHWbhOnqgyXOFvhtiCGr4yfWeobfsgUqHFFXD4dkuEH8f7r)HqbfuiIhuS9XIhnYkuzCfBqja]] )

    storeDefault( [[Fury Single]], 'actionLists', 20170628.135858, [[dWJzjaGAkPY6fr1Mir2fu2gLuAFqLA2cnFsr3uuUns9nvQ2PQAVs7gX(fmksj)LK8Bu9yv5WkgmvnCK4GKOofLOJrPohPGfksTuK0IvQLd5HKs9uILjcpNkNxKmvsQjRKPJYfHQCAkUm46QyJIiTvkHntQ2UkLNrjfFfQennrenpOs47qv9AOIrlQgpLu1jPK8zvY1GkP7jIYHifACIimms4Ax1vWJm7iS6UYFOHkj9Gsf8IHCfHkuHimoO)ekSVRWATTgm7kYdzOWQur5hZWjUQUF7QUcEKzhHvtxrEidfwL9rxht)yDgynov6hukSdLGxPGFF01X0pwNbwJtL(bLcdb0JH4cECrWNOIYBt0Wsvzh58fl3GCSkwrwM3W4OkeobQKXxwmO)qdvQ8hAOs6iNVy5gKJvHkeHXb9NqH9DBfvOco(b9axvxwfTZHhoz8BanqyDxjJV(dnuPS(tu1vWJm7iSA6kYdzOWQWMiqyy6iGK8uyaz2ryf8kf8Af87JUoMocijpf2IJpj41uZGFF01X0raj5PWqa9yiUGhxKSGprWBzWRuWRrki4MQR3cZgt)Gm8JtLloU8kkVnrdlvf9dYWpovU44YRyfzzEdJJQq4eOsgFzXG(dnuPYFOHkj9Gm8Jl4L44YRqfIW4G(tOW(UTIkubh)GEGRQlRI25WdNm(nGgiSURKXx)HgQuw)wtvxbpYSJWQPRipKHcRY(ORJbe0CbyhkbVsbpBIaHHzieaPcnxagqMDewvuEBIgwQkO5YqUuTJC8RyfzzEdJJQq4eOsgFzXG(dnuPYFOHkuNld5k4th54xHkeHXb9NqH9DBfvOco(b9axvxwfTZHhoz8BanqyDxjJV(dnuPS(tYQUcEKzhHvtxrEidfwf2GUagwomrwogLhl4XDWNWo4vk41k41k43hDDmGGMlaBXXNe8kf8Am4zteimmDeNLBixQ2aYbiCaegqMDewbVLbVMAg87JUog94CZdbyhkbVMAg8O5cWEheciSGh3jl41GgW0qWRPMbVwO5cWEheciSGh3jl4tcCn4vk43hDDmDeNLBixQ2aYbiCaegcOhdXf84ozbFsIHRwAzfL3MOHLQcAOPmxqfRilZByCufcNavY4llg0FOHkv(dnuH6qtzUGkuHimoO)ekSVBROcvWXpOh4Q6YQODo8WjJFdObcR7kz81FOHkL1pUw1vWJm7iSA6kYdzOWQSp66yogNaQYHbXWoucELcETcETcE2ebcdZqiasfAUamGm7iScELc(hNhxC8jyO5YqUuTJC8Xqa9yiUGh3bVDWBzWRPMb)(ORJbe0CbyhkbVLvuEBIgwQkG1dVddQyfzzEdJJQq4eOsgFzXG(dnuPYFOHk4z9W7WGkuHimoO)ekSVBROcvWXpOh4Q6YQODo8WjJFdObcR7kz81FOHkL1V1w1vWJm7iSA6kkVnrdlvLDKZxSCdYXQyfzzEdJJQq4eOsgFzXG(dnuPYFOHkPJC(ILBqowWRLTLvOcryCq)juyF3wrfQGJFqpWv1Lvr7C4Htg)gqdew3vY4R)qdvkR)7vDf8iZocRMUI8qgkSkoGPAZjhhgZaiBnOkbLxWJ7GxrWRuWRXGNnrGWWmecGuHMladiZocRGxPGxJuqWnvxVfMnM(bz4hNkxCC5vuEBIgwQk6hKHFCQCXXLxXkYY8gghvHWjqLm(YIb9hAOsL)qdvs6bz4hxWlXXLh8AzBzfQqegh0Fcf23TvuHk44h0dCvDzv0ohE4KXVb0aH1DLm(6p0qLY6pjQ6k4rMDewnDfL3MOHLQcAUmKlv7ih)kwrwM3W4OkeobQKXxwmO)qdvQ8hAOc15YqUc(0ro(bVw2wwHkeHXb9NqH9DBfvOco(b9axvxwfTZHhoz8BanqyDxjJV(dnuPS(1qvxbpYSJWQPRipKHcRY(ORJHpcE4yixQ2tmIDOe8kf87JUogqqZfGDOur5TjAyPQGFUbfX3qwvSISmVHXrviCcujJVSyq)HgQu5p0qfCzUbfX3qwvOcryCq)juyF3wrfQGJFqpWv1Lvr7C4Htg)gqdew3vY4R)qdvkRFBfvDf8iZocRMUI8qgkSkAKccUP66TWSX0pid)4u5IJlVIYBt0Wsvr)Gm8JtLloU8kwrwM3W4OkeobQKXxwmO)qdvQ8hAOsspid)4cEjoU8GxRewwHkeHXb9NqH9DBfvOco(b9axvxwfTZHhoz8BanqyDxjJV(dnuPSYQiuGNzIMKpmdN0)9eL1c]] )

    storeDefault( [[Fury Cleave 3]], 'actionLists', 20170628.135858, [[dOJMeaGEsQQnjOAxKyBKuX(uQQzlQ5JiDtP0TryNkzVu7gP9lYOeuggkzCKuPVPqDzvdwOHtsoik0PeKoMcoNsvwOczPa1ILQLd1drbpLyzsHNdPhdyQOOjROPd6IkLopIQNHsX1fyJOuYwjPSziSDLIttQVssvMMGW3ruoSK)Quz0az8cIojkvVwk6Aic3dr0NHOdHsP(nQ2dMPLT0QN)0DlRI4wyRam5Pid5xBEkYglGF(f69QbRHXSuNb2OmyraWAvqlwyeaQ5uuZ0RbZ0YwA1ZF6rweaSwf0spabcfuiN(DGEHHkbQSWyxN1qYT8qEGa4TWoDQbkihBHYP3slFQwHxfXTyzve3Y2qEGa4Ta(5xO3RgSggpWYc4JYdWah1mn0cdGoqZw(MtCk0DlT85QiUfd9QHzAzlT65p9ilcawRcAPhGaHcXl4oG8RnhReOkfdpfdlfdlf7biqOCkUqELjNmAkgEkY2PiSYNcvqG5qqAkYD9JrpU5XkNw98NPyOPiPKMIHLI4c5vacW4tHP4(Kmf3BpL9sXWtryLpfQGaZHG0uK76hJECZJvoT65ptXqtXqtrsjnf7biqOquOOfa(kbQsrsjnfdlf7biqOGaZHG0uK76hJECZJvWNO0u0uCFsMIHqHePykgEkIlKxbiaJpfMI7tYuuDjrkgQfg76SgsUfCrOQqElStNAGcYXwOC6T0YNQv4vrClwwfXTaUiuviVfWp)c9E1G1W4bwwaFuEag4OMPHwya0bA2Y3CItHUBPLpxfXTyOxSXmTSLw98NEKfbaRvbTaR8PqfnLE8oCH8kNw98NwySRZAi5wWfsnf5UEMtMf2Ptnqb5yluo9wA5t1k8QiUflRI4waxi1uKP4OmNmlGF(f69QbRHXdSSa(O8amWrntdTWaOd0SLV5eNcD3slFUkIBXqVcHzAzlT65p9ilm21znKCl9mNpHG0yuOf2Ptnqb5yluo9wA5t1k8QiUflRI4wgL58jeKgJcTa(5xO3RgSggpWYc4JYdWah1mn0cdGoqZw(MtCk0DlT85QiUfd9IeMPLT0QN)0JSWyxN1qYTqginotMMoTWoDQbkihBHYP3slFQwHxfXTyzve3I6bsJZKPPtlGF(f69QbRHXdSSa(O8amWrntdTWaOd0SLV5eNcD3slFUkIBXqdTiQoGUYA1VGAo1RXnm0g]] )

    storeDefault( [[Arms Universal]], 'actionLists', 20170628.135858, [[dqKJtaqiuQOnrk6tcvfJcQsNcQIzjuLyxOyykvhtjwMu4zkjyAkj01qPQTjufFdQQXjuv5CcvjnpQsUhPs7tjPdkuwikLhskCrsfBeLk4KcvEPqvQMPsI6MkLDIk)uOQ0qrPs1srv9uktLu1vrPcTvQs9vHQQ2RQ)kKbtYHLSyO8ybtwuxgSzsPpJsgnu50uz1kjYRLsnBrUTuTBe)gYWrvookvklhPNty6kUov12Pk(Uu04rPsoVuY6fQsz(kP2pr)LR)MoKclb5JDJR6WTy0UqQyhjopavuPB8Heuc4Cn2xWFpEwwrMLBwG64n3UflmoerC9NB56VPdPWsq(SDZcuhV5gELk2Punvcidt5PMIYaKclbzPA9APcZxRwMYtnfLXNNuHhPstPcZxRwgSAMeefOTy85jvAkvzaZxRwMakHecFrKOxcCm(8KQ1RLQPOSGHzCDiAqrzhivEPRu1iEUfdZLCtRB8qJdrUfhj7c1GO3iicCBdL9UOCvhUHs5OMf9MHd1CdLDADavC2UXvD4g7oACiYTyuwIBKQd6Is5OMf9gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoCdLYrnl6NZ146VPdPWsq(SDZcuhV5gMVwTmy1mjikqBX4ZtQwVwQMIYcgMX1HObfLDGu5LUs1s8ClgMl5Mw3WsiuosRpT1T4izxOge9gbrGBBOS3fLR6WTBCvhUXwcHYsf7GpT1n(qckbCUg7l4VSFJpiq(0aiU(p30aheAVH8aDGmh72gkZvD42NZTcx)nDifwcYNTBwG64n3W81QLbRMjbrbAlgFEs161s1uuwWWmUoenOOSdKkV0vQwwUfdZLCtRByava02ocRBXrYUqni6ncIa32qzVlkx1HB34QoCJnGkaABhH1n(qckbCUg7l4VSFJpiq(0aiU(p30aheAVH8aDGmh72gkZvD42NZTIx)nDifwcYNTBwG64n3W81QLbRMjbrbAROmu5uROqL6mzutIuPPurlwatg06cUrQwvQwXDPstPkGqPmQjHbRMjbrbAlgk0lhrivRkv73IH5sUP1TIgkcenikfiZT4izxOge9gbrGBBOS3fLR6WTBCvhUfJgkciv6rukqMB8Heuc4Cn2xWFz)gFqG8PbqC9FUPboi0Ed5b6azo2TnuMR6WTpNJ9x)nDifwcYNTBwG64n3ciukJAsyyLqyvkkGqPmQjHHc9YresLxs1otd2lvAkv4vQ4rbprSczMfMakHecFrKOxcCs161sfpk4jIviZSW0SOyuOAduPcpsLMsvaHszutcdwQYGyq0odf6LJiKkDLQDPA9APAkklyygxhIguu2bsLx6kvSxQ0uQMIYcggCqLgCm8cJuTQu1y)wmmxYnTUHvZKGOaT1T4izxOge9gbrGBBOS3fLR6WTBCvhUXwntcKknOTUXhsqjGZ1yFb)L9B8bbYNgaX1)5Mg4Gq7nKhOdK5y32qzUQd3(CU456VPdPWsq(SDZcuhV5waHszutcdRecRsrbekLrnjmuOxoIqQ8sQ2zAWEPstPcVsfELk2Punvcidt5PMIYaKclbzPA9APkGqPmQjHP8utrzOqVCeHuTQUs1YUuHhPstPcVsfMVwTmcC1mafYrzqlqeGGXNNuTETufqOug1KW0SOyuOAdugk0lhrivRkv4lvAkvbekLrnjmbucje(IirVe4yOqVCeHuTQuHVuTETufqOug1KWeqjKq4lIe9sGJHc9Yres1Qs1UuPPuLbmFTAzcOesi8frIEjWXqHE5icPAvPIvilv4rQWJuPPunfLfmm4Gkn4y4fgPYlDLQg7s161s1uuwWWmUoenOOSdKkV0vQy)TyyUKBADdRMjbrbARBXrYUqni6ncIa32qzVlkx1HB34QoCJTAMeivAqBjv4Dbp34djOeW5ASVG)Y(n(Ga5tdG46)CtdCqO9gYd0bYCSBBOmx1HBFoh(x)nDifwcYNTBwG64n3ciukJAsyyLqyvkkGqPmQjHHc9YresLxs1otd2lvAkv4vQW81QLbRMjbrbAlgFEs161svaHszutcdwntcIc0wmuOxoIqQ8sQwyVuHhPA9APAkklyygxhIguu2bsLx6kvn2VfdZLCtRBLNAk6T4izxOge9gbrGBBOS3fLR6WTBCvhUfZtnf9gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoC7Z5IFx)nDifwcYNTBwG64n3a2nFhpEqMPTlTsfKbIicZNsCewrnDcCsLMsvgW81QLjGsiHWxej6LahJpVBXWCj306wBxALkidereMpL4iSIA6e4Ufhj7c1GO3iicCBdL9UOCvhUDJR6WT4Dxk(SsfKbs8rivS5tjoclPk(7e4UfJYsCJuDq32U0kvqgiIimFkXryf10jWDJpKGsaNRX(c(l734dcKpnaIR)ZnnWbH2BipqhiZXUTHYCvhU95CXRx)nDifwcYNTBwG64n3YaMVwTmuGKzOqVCeHu5LuXkKLknLQPOSGHbhuPbhdVWivRQRu1y)wmmxYnTUrbs(wCKSludIEJGiWTnu27IYvD42nUQd34dK8n(qckbCUg7l4VSFJpiq(0aiU(p30aheAVH8aDGmh72gkZvD42NZTSF930HuyjiF2UzbQJ3CdZxRwgSAMeefOTIYqLtTIcvQZqHE5icPAvPkGqPmQjHrlk4lGCeTybmuOxoIqQ0uQWRuH5RvlJwuWxa5iAXcyetfAlvEjvRGuTETufqOug1KW0r0PsrIH6AdmuOxoIqQwvQ2Lk8ClgMl5Mw30Ic(cihrlwWT4izxOge9gbrGBBOS3fLR6WTBCvhUXoGc(cilv8lwWn(qckbCUg7l4VSFJpiq(0aiU(p30aheAVH8aDGmh72gkZvD42NZTSC930HuyjiF2UzbQJ3Cldy(A1YeqjKq4lIe9sGJHc9YresLxsfRq(wmmxYnTUfqjKq4lIe9sG7wCKSludIEJGiWTnu27IYvD42nUQd30aLqcHVqQSEjWDJpKGsaNRX(c(l734dcKpnaIR)ZnnWbH2BipqhiZXUTHYCvhU95ClnU(B6qkSeKpB3Sa1XBULbmFTAzcOesi8frIEjWXqHE5icPYlPIvilvRxlv4vQMkbKHzCtrCHOUJfUHbifwcYsLMsfMVwTmcC1mafYrzqlqeGGjJAsKk8ClgMl5Mw3AwumkuTb6T4izxOge9gbrGBBOS3fLR6WTBCvhUf)lkgfQ2a9gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoC7Z5wwHR)MoKclb5Z2TyyUKBADJwEkwa9wCKSludIEJGiWTnu27IYvD42nUQd34xEkwa9gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoC7Z5wwXR)MoKclb5Z2nlqD8MBy(A1YG8auEOMaLXN3TyyUKBADd5bO8qnb6T4izxOge9gbrGBBOS3fLR6WTBCvhUfF9auEOMa9gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoC7Z5wy)1FthsHLG8z7MfOoEZTkmopqeqGUdes1Q6kvnKknLQPsazyenbGNJWksmuxBqWaKclb5BXWCj306g1NevHXHirjNyUfhj7c1GO3iicCBdL9UOCvhUfsq5bUXvD4gFFIuflmoerQwzNyUfJYsCJuDq3qckpWn(qckbCUg7l4VSFJpiq(0aiU(p30aheAVH8aDGmh72gkZvD4wmAxivAKGYd85ClXZ1FthsHLG8z7MfOoEZTkmopqeqGUdesLuTQUsf7LknLk2PunvcidJOja8CewrIH6AdcgGuyjiFlgMl5Mw3O(KOkmoejk5eZT4izxOge9gbrGBBOS3fLR6WTcb34QoCJVprQIfghIivRStmsfExWZTyuwIBKQd6wi4gFibLaoxJ9f8x2VXheiFAaex)NBAGdcT3qEGoqMJDBdL5QoClgTlKQyXxD(CUf8V(B6qkSeKpB3Sa1XBUnfLfmm4Gkn4y4fgPYlDLQg7sLMsvfgNhiciq3bcPYlPI93IH5sUP1nQpjQcJdrIsoXClos2fQbrVrqe42gk7Dr5QoCdyxqWFGBCvhUX3NivXcJdrKQv2jgPcVnWZTyuwIBKQd6cSli4pq8YuuwWe50Q7uuwWWGdQ0GJHxy8s3g7AwHX5bIac0DGGPjohn10rYEX(B8Heuc4Cn2xWFz)gFqG8PbqC9FUPboi0Ed5b6azo2TnuMR6WTy0UqQ0HDbb)b(CUL431FthsHLG8z7MfOoEZTPOSGHbhuPbhdVWivRkvn2VfdZLCtRBuFsufghIeLCI5wCKSludIEJGiWTnu27IYvD4MWryLGBCvhUX3NivXcJdrKQv2jgPcVRaEUfJYsCJuDqxHJWkb34djOeW5ASVG)Y(n(Ga5tdG46)CtdCqO9gYd0bYCSBBOmx1HBXODHuzocRe85ZnJheCvYfVvJdroh(lF(b]] )

    storeDefault( [[Arms AOE]], 'actionLists', 20170628.135858, [[dWtsjaGEKQsBscYUuQ2MeG9HuvnBrnFKKUjP8yHUTchwQDkP9sTBu2pj9tfPQHjrJdPQ4BkQoVsPbtQgUs4qivjNsrshtqNtcOfQuSuqzXGSCu9qLKvHuLAzkkpNOtlYubvtMW0bUOe6VkIlR66cmnKeTvKkBgPSDs03vs9vKe(SeuZtcKNjbQxtcJgjgVIeNej1OuKY1uKk3dPkEk0VrCqLODOHBSiRHYxyiJ1ECJl5dPQ(YPVOryp)wExNvgoVSacPY9qJyKNwamACzeKimPH7AOHBSiRHYx4ngXipTaymsizbznBc)DeyCjukNaBnoiCqNNib8KIBKAMifBaHBKry3OgrqxZR94gnw7XnQr4GoRQJaEsXnc753Y76SYW5HLgHDjjGhV0WnW4kkpQqJO8JZagYOgru7XnAGRZmCJfznu(cVXig5PfaJqb0OTlbe2Nq5nhShSW4sOuob2A8t5XaWnsntKInGWnYiSBuJiOR51ECJgR94gloLhda3iSNFlVRZkdNhwAe2LKaE8sd3aJRO8OcnIYpodyiJAerTh3ObUwWgUXISgkFH3yeJ80cGXiHKfK1S9ijtKYa5e5OLu25F0jMuvNEu1lv1lKQouanA7sknaC(fteN2zYl3fK1mv9cPQdfqJ2(c(Jj5Nib8KIl3fK1mJlHs5eyRXijtKYa5e5OLumsntKInGWnYiSBuJiOR51ECJgR94gxrYePmqQQJJwsXiSNFlVRZkdNhwAe2LKaE8sd3aJRO8OcnIYpodyiJAerTh3ObUsLgUXISgkFH3yeJ80cGrOaA02LuAa48lMioTZKxUliRzgxcLYjWwJRBoe)TIZnsntKInGWnYiSBuJiOR51ECJgR94gPIMdXFR4CJWE(T8UoRmCEyPryxsc4XlnCdmUIYJk0ik)4mGHmQre1ECJg460z4glYAO8fEJrmYtlagbD(mWoTZvs4ti0Ma1aq(7N1q5lu1lKQ(0u1fhkGgT9ijtKYa5e5OLu2dwOQtvQQQZ7c)DXPLIjGQEbPQpDLQ6tvvVqQ6ttvNEPQd68zGDAKyG8Ij8UWF)SgkFHQovPQQouanA7qnaK)KiF7eXBrE7KyNh7blu1Pkvv1HcOrBpMFR87blu1NQXLqPCcS14AkjEEDIjmsntKInGWnYiSBuJiOR51ECJgR94gPckjEEDIjmc753Y76SYW5HLgHDjjGhV0WnW4kkpQqJO8JZagYOgru7XnAGRfGHBSiRHYx4ngXipTayuCOaA025Nj25F0jMuvVGOhvDraVbjctvNERQxUxWgxcLYjWwJ8ZegPMjsXgq4gze2nQre018ApUrJ1ECJWotye2ZVL31zLHZdlnc7ssapEPHBGXvuEuHgr5hNbmKrnIO2JB0axNB4glYAO8fEJXLqPCcS1iuUfxci8HrQzIuSbeUrgHDJAebDnV2JB0yTh34MClUeq4dJWE(T8UoRmCEyPryxsc4XlnCdmUIYJk0ik)4mGHmQre1ECJg4k9XWnwK1q5l8gJlHs5eyRXy(TYBKAMifBaHBKry3OgrqxZR94gnw7XnUk)w5nc753Y76SYW5HLgHDjjGhV0WnW4kkpQqJO8JZagYOgru7XnAGRfOHBSiRHYx4ngXipTayK3f(7Xao)mGQo9RQxGLgxcLYjWwJFkpgaUrQzIuSbeUrgHDJAebDnV2JB0yTh3yXP8ya4Q6tlCQgH98B5DDwz48WsJWUKeWJxA4gyCfLhvOru(XzadzuJiQ94gnW1Wsd3yrwdLVWBmIrEAbWiVl83JbC(zavD6NEu1PYsJlHs5eyRX1us886etyKAMifBaHBKry3OgrqxZR94gnw7Xnsfus886etOQpTWPAe2ZVL31zLHZdlnc7ssapEPHBGXvuEuHgr5hNbmKrnIO2JB0axddnCJfznu(cVX4sOuob2AusHevSUvEJuZePydiCJmc7g1ic6AETh3OXApUrKcjQyDR8gH98B5DDwz48WsJWUKeWJxA4gyCfLhvOru(XzadzuJiQ94gnW1WzgUXISgkFH3yCjukNaBnkbe(ycejdmsntKInGWnYiSBuJiOR51ECJgR94graHpu13qYaJWE(T8UoRmCEyPryxsc4XlnCdmUIYJk0ik)4mGHmQre1ECJgyGrCXJPoNOVniryUop0aBa]] )

    storeDefault( [[Arms Cleave]], 'actionLists', 20170628.135858, [[dWZqjaGErK0MqczxaSnruSprKA2cnFKQUjj9yrDBfDyj7uQ2l1Ur1(jLrHePHPGXjIeFtjCErYGjXWfPoOs0PqI4yKQZjIqlujzPaAXk1Yr5HkKvjIiltH65coTuMkqnzIMoOlQK6VIWLvDDcTrreSvKkBgiBNaFhj1xrc1NrIAEIO0Zqc41e0OrkJxevDsKKPHe01erL7jIOEk0Hqc0VrS1nyJR51oEP3g718gxYMbnLrXxcUrGp(kC3hpOVyiz0Pqa6gXmRLgA04YmSr4bd2DDd24AETJx6vgxUBXgmLXjHbRyIaK1eEJuXLTCbjmJCc)gvjs6kwVM3OXEnVrvcdwrnfeYAcVrGp(kC3hpOVqFWiWhiIS8dgSHghr7zHQebFEo0BJQezVM3OHUp2GnUMx74LELrmZAPHg3IGabiaj8NG2lgeGyAJl3TydMY4t(NfH3ivCzlxqcZiNWVrvIKUI1R5nASxZBCDY)Si8gb(4RWDF8G(c9bJaFGiYYpyWgACeTNfQse855qVnQsK9AEJg6ofWGnUMx74LELrmZAPHg3IGabiqRGWZUmH8Gop8aajHAUMcfPPSfbbcqA2ZTWteGSMWhaijuZnUC3InykJzsKecIHeHzfOzKkUSLliHzKt43OkrsxX618gn2R5noIejHGyqtbNvGMrGp(kC3hpOVqFWiWhiIS8dgSHghr7zHQebFEo0BJQezVM3OHUtHgSX18AhV0RmIzwln04weeiabAfeE2LjKh05HhaijuZnUC3InykJuxSn7LWZmsfx2YfKWmYj8BuLiPRy9AEJg718gP4ITzVeEMrGp(kC3hpOVqFWiWhiIS8dgSHghr7zHQebFEo0BJQezVM3OHUNCgSX18AhV0RmIzwln0iRO8bKfzSZHAkjTMI(WGMc90RPSfbbcWUGW4tKzPsiFjJPsKR4eGyAJl3TydMYiiswmCzcwr5BKkUSLliHzKt43OkrsxX618gn2R5nMeizXWLAkalkFJaF8v4UpEqFH(GrGpqez5hmydnoI2Zcvjc(8CO3gvjYEnVrdDpzmyJR51oEPxzeZSwAOryfphca0zciSeeqj2fegpGZRD8snfkstHs1uKFlcceGmjscbXqIWSc0aiMwtHE61uyfLpa5b1YnOMsYQPKCdAkuIMcfPPqPAkuqnfyfphcaejlgUmbRO8bCETJxQPqp9AkBrqGaSlim(ezwQeYxYyQe5kobiMwtHE61u2IGabihFj4aetRPqjgxUBXgmLrQP1yrQBCPrQ4YwUGeMroHFJQejDfRxZB0yVM3iftRXIu34sJaF8v4UpEqFH(GrGpqez5hmydnoI2Zcvjc(8CO3gvjYEnVrdDFHbBCnV2Xl9kJyM1sdnk)weeiaSpRgpOPKSjznfPiRGncxtjjPPmaGcyC5UfBWugzNlnsfx2YfKWmYj8BuLiPRy9AEJg718gbEU0iWhFfU7Jh0xOpye4derw(bd2qJJO9SqvIGpph6TrvISxZB0q3tkgSX18AhV0RmUC3InykJ7yjFasytJuXLTCbjmJCc)gvjs6kwVM3OXEnVXvXs(aKWMgb(4RWDF8G(c9bJaFGiYYpyWgACeTNfQse855qVnQsK9AEJg6Es0GnUMx74LELXL7wSbtzmhFj4gPIlB5csyg5e(nQsK0vSEnVrJ9AEJJIVeCJaF8v4UpEqFH(GrGpqez5hmydnoI2Zcvjc(8CO3gvjYEnVrdDxFWGnUMx74LELrmZAPHgzfLpGSiJDoutjP1uOWbnf6PxtzlcceGC8LGdqmTXL7wSbtzKAAnwK6gxAKkUSLliHzKt43OkrsxX618gn2R5nsX0ASi1nUutHs1PeJaF8v4UpEqFH(GrGpqez5hmydnoI2Zcvjc(8CO3gvjYEnVrdDxx3GnUMx74LELXL7wSbtzmqJKfsDj4gPIlB5csyg5e(nQsK0vSEnVrJ9AEJinswi1LGBe4JVc39Xd6l0hmc8bIil)GbBOXr0EwOkrWNNd92Okr2R5nAO76JnyJR51oEPxzC5UfBWugdqcBMytIqJuXLTCbjmJCc)gvjs6kwVM3OXEnVresytnLvKi0iWhFfU7Jh0xOpye4derw(bd2qJJO9SqvIGpph6TrvISxZB0qdnIPFUvXwsTGnc39f6gAd]] )

    storeDefault( [[Arms Execute]], 'actionLists', 20170628.135858, [[dWJtkaGELQO2efv7IuTnOuSpOunBiMpf0nvIhtLBd4WG2jK2R0UjA)cnksrdtj9BeFdk58uOblYWfvhek6uKchtqNtPkYcHclLGwmqlhPhsGwffqTmkYZj50u1ujKjtPPR4Ikv(Raxw11HQNrbyRKs2Ssz7IstJa8DLQ6ZeqZtPk51IIXrbKrtOgpfLtsk1pvQcDnLQG7rb6POoKsvQJdLs3WkQ8ojee52cwgfc8YysbuX0oZUdFEzHh5q1lQP1qSwXMqbOhwMDuF(uUmMUXtKQkQOHvu5DsiiYTfJYSJ6ZNYAcIVTPdcNb5boQrD88yY8yceFBt)MDh(4jYtvb5078kprQRgOltmzWyYKgXKHggtG4BB63S7WhprEQkiNENx5jsD1aDzIjdgtMkJjOhXpgldqOdejqnuFMxwBP17GdHwwsKV8cXQfKIcbE5YOqGxEHqhismXd1N5LfEKdvVOMwdXkCTSWRi4u3vvuNYck(UmlKSh4YPGLxiwuiWl3POMQOY7KqqKBlgLzh1NpLbX320bHZG8ah1OoEEmzEmPzmP(easK4k9XFQP1abK7IjShtRXKHggthBX9553QpIFGaPhobQHqbub34JjnkJjOhXpgldIaTxnekqzTLwVdoeAzjr(YleRwqkke4LlJcbEzmqG2RgcfOSWJCO6f10AiwHRLfEfbN6UQI6uwqX3LzHK9axofS8cXIcbE5of1aQOY7KqqKBlgLzh1NpLbX320bHZG8ah1yG9qlIXahebqhpVmMGEe)yS8n7o85L1wA9o4qOLLe5lVqSAbPOqGxUmke4L3z2D4Zll8ihQErnTgIv4AzHxrWPURQOoLfu8DzwizpWLtblVqSOqGxUtrfqfvENecICBXOm7O(8Pmi(2MoiCgKh4Og1XZJjZJjnJj1NaqIexPp(tnTgiGCxmH9yAnMm0Wy6ylUpp)w9r8dei9WjqnekGk4gFmPrzmb9i(XyzqeO9QHqbkRT06DWHqlljYxEHy1csrHaVCzuiWlJbc0E1qOaXKMHAuw4rou9IAAneRW1YcVIGtDxvrDklO47YSqYEGlNcwEHyrHaVCNIUhQOY7KqqKBlgLzh1NpLbX320bHZG8ah1OULSVmMmpMaX320jzpnNS)P645LXe0J4hJLjzpnNS)PL1wA9o4qOLLe5lVqSAbPOqGxUmke4L3JzpnNS)PLfEKdvVOMwdXkCTSWRi4u3vvuNYck(UmlKSh4YPGLxiwuiWl3POytfvENecICBXOm7O(8Pmi(2MUsmCMtVnW(TlvxPBj7llJjOhXpgl7iieLcxfOaGkXL1wA9o4qOLLe5lVqSAbPOqGxUmke4LfKGqukCvmXaqL4YcpYHQxutRHyfUww4veCQ7QkQtzbfFxMfs2dC5uWYlelke4L7uuSQOY7KqqKBlgLzh1NpLbX320vIHZC6Tb2VDP6kD88yY8ysZyIcf41D4u6LtmHDdgtcynMm0WyceFBtxne5deFiD0XZJjnkJjOhXpglFZUdFEzTLwVdoeAzjr(YleRwqkke4LlJcbE5DMDh(8ysZqnkl8ihQErnTgIv4AzHxrWPURQOoLfu8DzwizpWLtblVqSOqGxUtrnqvu5DsiiYTfJYSJ6ZNYhBX9553QdPoXWSePkq8HzngigkTXK5XefkWR7WP0lNyAVIjSznMm0WysZyAGixo6EzWgHgmIFqgpcI(LqqKBJjZJjq8TnDLy4mNEBG9BxQUs3s2xgtAugtqpIFmwgGqhisGAO(mVS2sR3bhcTSKiF5fIvliffc8YLrHaV8cHoqKyIhQpZJjnd1OSWJCO6f10AiwHRLfEfbN6UQI6uwqX3LzHK9axofS8cXIcbE5ofDpvrL3jHGi3wmkZoQpFkBpi(2Mo9sRo9aqVuft7LbJjlofoEImMmWX0QUbetMhtdKkWp6Jh4bdjW6FmH9yYakJjOhXpgltV0wwBP17GdHwwsKV8cXQfKIcbE5YOqGxw4L2YcpYHQxutRHyfUww4veCQ7QkQtzbfFxMfs2dC5uWYlelke4L7u0W1kQ8ojee52Irz2r95tzq8TnDLy4mNEBG9BxQUs3s2xwgtqpIFmw(MDh(8YAlTEhCi0YsI8LxiwTGuuiWlxgfc8Y7m7o85XKMM0OSWJCO6f10AiwHRLfEfbN6UQI6uwqX3LzHK9axofS8cXIcbE5ofnmSIkVtcbrUTyuMDuF(uwZyc6gF2hC5b8xftXe2JPWysJyY8yAVJj1NaqIexPp(tnTgiGCxmH9yATmMGEe)ySmic0E1qOaL1wA9o4qOLLe5lVqSAbPOqGxUmke4LXabAVAiuGysttAugtQavL9Y5ukE(yWWYcpYHQxutRHyfUww4veCQ7QkQtzbfFxMfs2dC5uWYlelke4L70PmNFNhI43ZWXtKffRWoTa]] )

    storeDefault( [[Arms Single]], 'actionLists', 20170628.135858, [[d0dsnaGEOOQ2evL2fPSnsv0(ivLVbLA2cMpb5MIQptvXTvYHvStOAVs7gP9tPFsijdtLACesQZRu60ImyQmCs0HivvNckXXeLZbfvSqcvlLalwflhXdjuwfuuPLrv1Zj6VkvtLeMmfthYfjOEkQldUovzJqrv2kjXMvjBNu5zqr5Res00ivPVRumpOiVgkmAsQXtQcNKK0Jf6Aes4EesDqcXVv1OGs6MvfLfMoNay6Pm(SGYIqwsRJtuFcqzbqagjuC)3zyFRNz6vlRmhjjLOYLfjIspvwffpRkklmDobWuXlZrssjQ8X76s7miua2JKTAEkToFTojG2pp1tQHsaX)9UEvgTo9zD3Lf5Kcj02YNWyaj6jRYQsnP4GEsz6tHY5VrLHGplOCz8zbLfpmgqIEYQSaiaJekU)7mSZUllaKVhjcYQOOYIPgIyK)6Gfqr9uo)n4ZckxuX9xfLfMoNayQ4L5ijPevo(FW8BOANbHcWEKSvJaRjrLwhMeT15t0yD(ADg44DDPf)WlLEYD5AKQ1iWAsuP1PpRtpllYjfsOTLjJUXhGuwvQjfh0tktFkuo)nQme8zbLlJplOSGr34dqklacWiHI7)od7S7Yca57rIGSkkQSyQHig5VoybuupLZFd(SGYfvCmRkklmDobWuXlZrssjQ8X76stQEqiGaMDdCbuji1m)gAzroPqcTTC8dVu6j3LRrQUSQutkoONuM(uOC(Buzi4ZckxgFwqzX(WlLEsRJxJuDzbqagjuC)3zyNDxwaiFpseKvrrLftneXi)1blGI6PC(BWNfuUOIR3QOSW05eatfVmhjjLOYy16WQ1HMaqrAxar3t2)R9ZGqbqdOZjagRZxRZahVRlT4hEP0tUlxJuTgbwtIkTomzD(enwhwSoHeY60V1HMaqrAxar3t2)R9ZGqbqdOZjagRZxRdRwhwTUJ31LMe9uyxnmeKMNsRtiHSU4)bZVHQTEcAc7sejHbOrG1KOsRdtI26I)hm)gQMpH)mH94)bZVHQrG1KOsRdlwNVw3X76stQEqiGaMDdCbuji1m)gQ1HfRdlLf5Kcj02YBgYHadgaPSQutkoONuM(uOC(Buzi4ZckxgFwqzr5qoeyWaiLfabyKqX9FNHD2DzbG89irqwffvwm1qeJ8xhSakQNY5VbFwq5IkUOOkklmDobWuXlZrssjQS(TUJ31L2zqOaShjB3nWycB3JtyP5P06816oExxAxF0tcMDY4dOjrtedRdtwhMzD(AD636I)hm)gQw8dVu6j3LRrQwZtP15R1HvRJm(aArpcbOiRtFI26YWSBRtiHSodC8UU0IF4Lsp5UCns1AMFd16esiRdnbGI0gQpazFn0XhybuKgqNtamwNVwx8)G53q1odcfG9izRgbwtIkTomjARtuBDyPSiNuiH2w(6JEsWStgFGYQsnP4GEsz6tHY5VrLHGplOCz8zbLX8(ONemwNGXhOSaiaJekU)7mSZUllaKVhjcYQOOYIPgIyK)6Gfqr9uo)n4ZckxuX1ZQOSW05eatfVmhjjLOYeynjQ06WKOTUBRtiHSocSMevADyY6efwNVwx8)G53q1odcfG9izRgbwtIkTomzD(ToFToSADX)dMFdv7egdirpzPrG1KOsRdtwNFRtiHSo9BDsaTFEQNudLaI)7D9QmAD6Z6UToSuwKtkKqBltaQPSQutkoONuM(uOC(Buzi4ZckxgFwqzba1uwaeGrcf3)Dg2z3LfaY3JebzvuuzXudrmYFDWcOOEkN)g8zbLlQ4yxfLfMoNayQ4L5ijPev(4DDPjrpf2vddbP5PSSiNuiH2wg0di6HGYQsnP4GEsz6tHY5VrLHGplOCz8zbLfwpGOhcklacWiHI7)od7S7Yca57rIGSkkQSyQHig5VoybuupLZFd(SGYfvCrDvuwy6CcGPIxMJKKsu5J31LMu9Gqabm7g4cOsqQ5P06esiR74DDPb6be9qPNce5UscetY0t1m)gAzroPqcTT86jOjSlrKegqzvPMuCqpPm9Pq583OYqWNfuUm(SGY5pbnbRJrKegqzbG89irqwffvwaeGrcf3)Dg2z3Lz1)M83KUsar2tzXudrmYFDWcOOEkN)g8zbLlQ4yovrzHPZjaMkEzosskrLpExxANbHcWEKSvZ8BOLf5Kcj02YVoGO83aKYQsnP4GEsz6tHY5VrLHGplOCz8zbLfv6aIYFdqklacWiHI7)od7S7Yca57rIGSkkQSyQHig5VoybuupLZFd(SGYfv8S7QOSW05eatfVmhjjLOYeynjQ06WKOToJhzqPNADyUw3TgMvwKtkKqBltaQPSQutkoONuM(uOC(Buzi4ZckxgFwqzba1yDyndlLfabyKqX9FNHD2DzbG89irqwffvwm1qeJ8xhSakQNY5VbFwq5IkEwwvuwy6CcGPIxMJKKsu5jIs6GDGcReiTo9zDzwNqczDOjauK2fq09K9)A)miua0a6CcGPSiNuiH2wEJ6ejSjrnLvLAsXb9KY0NcLZFJkdbFwq5Y4ZcklkvNiHnjQPSaiaJekU)7mSZUllaKVhjcYQOOYIPgIyK)6Gfqr9uo)n4ZckxuXZ8xfLfMoNayQ4L5ijPevEIOKoyhOWkbsRZ6eT1LzD(AD636qtaOiTlGO7j7)1(zqOaOb05eatzroPqcTTSmmRYQsnP4GEsz6tHY5VrLHGplOCz8zbL5WSklacWiHI7)od7S7Yca57rIGSkkQSyQHig5VoybuupLZFd(SGYfv8mmRkklmDobWuXllYjfsOTLFDar5VbiLvLAsXb9KY0NcLZFJkdbFwq5Y4ZcklQ0beL)gGyDyndlLfabyKqX9FNHD2DzbG89irqwffvwm1qeJ8xhSakQNY5VbFwq5IkEMERIYctNtam9uMJKKsuz9BDsaTFEQNudLaI)7D9QmAD6Z6UllYjfsOTLpHXas0twLvLAsXb9KY0NcLZFJkdbFwq5Y4ZcklEymGe9KL1H1mSuwaeGrcf3)Dg2z3LfaY3JebzvuuzXudrmYFDWcOOEkN)g8zbLlQOYSsiMMqcZFqPNwCSZkQf]] )


    storeDefault( [[Fury Primary]], 'displays', 20170628.135858, [[dWdYgaGEPkVerv7IOs61sbZukYSv4WsUjIk)gQBRu9mKe7KQ2Ry3e2VI0pvIHPughLQ6XOQHIsdwrmCK6GsPttYXOsNJOIfkvwkrvlMswoPEOsYtblJO8CkMiLknvinzkLPRYfvuxvQkxwvxhHncHTsuj2mQSDi6Jsr9zezAsH(ovmsKK2gLQmAumEeLtIe3Isfxtj15jY3KQQ1suPoosQJBqdWx0NclqGfhCsJpWsFOnrXph4knP)yrYgRa6sq6xX88nKUaut8eF7qrsS)IlaFaPfooZFRk6tHfM43cq2chN5Vvf9PWct8BbO1Q9slrHhlavVp(g3cSReTZXtLaut8eVTvf9PWct6ciTWXz(dT0K(Ze)wadd2bCuhpt7C6cyyWoTehoDb2lYa04DdCLM0FTcEgSoq3ck6c5KNsZufnGuq0)6n7jZ(2FD)uPr31nkBD4SZA3aKfeRTNm5STMkuron2O9xlB9w4StJYjGHb7GwAs)zsxGgSAf8myDa0fw5P0mvrdOe2u81H1TcEgSoG8uAMQOb4l6tHfTcEgSoq3ck6c5ca0pVQgQE1PWI47xwadd2bqtxaQjEI3Uk9ZFkSiG8uAMQObee7u4Xct8YcyO)XaXOmmRWdSoObQ4DdyfVBasX7gqhVBUaggSZQI(uyHjwbiBHJZ8xlHUIFlqrOluj6pGfbhxG9ISwIdh)waRHQxVMhyN2XiwbQbntbmyhwKZX7gOg0m1k8UvDSiNJ3nGDFUIyCXkqnCkjdls20faPYOSud1jHkr)bScWx0NclAhksIaRM9OZYhWMYqpkjuj6pqfqxcspQe9hOSud1jfOi0f5uIpDbAWcbwCGQ3hVRSa1GMPqlnP)yrYgVBa9pcSA2JolFad9pgigLHjwbQbntHwAs)XICoE3aut8eVnkcBk(6WAt6c4R9paccT00jSA1EPLcCLM0FiWIdoPXhyPp0MO4NdSReTeho(TanyHalo4KgFGL(qBIIFoa1epXBJcpwaQEF8Y6pqnOzQ2HtjzyrYgVBaYw44m)r(ot8UbO1Q9slHaloq17J3vwaA9ZJ3TQRLTPaii0stN0NqH81MAeqXJfYngVhV76a7fzTZXVfGdlUaSOtNaLWmDIV0AStGR0K(Jf5CScO4XcGU4vcsXllG8)4lZhVSn3(3S3MCKRUbSgQE9AEGDIvaYw44m)rrytXxhwBIFlG0chN5pkcBk(6WAt8BbUst6peyXfGfD6eOeMPt8LwJDcq2chN5p0st6pt8BbmmyhkcBk(6WAt6cyyWoTe6IIGdhRa1WPKmSiNtxadd2Hf5C6cyyWoTZPlapE3QowKSXkqrORwbpdwhOBbfDHCnnJanqrOlG(hdk2n(TautO4BqUOmWjn(avGDLaqJFlWvAs)Haloq17J3vwGIqxueCyuj6pGfbhxa(I(uybcS4cWIoDcucZ0j(sRXobQbntTcVBvhls24DdmlkRXBlDbmQD6X3UmhVSaslCCM)Aj0v8BbAWcbwCbyrNobkHz6eFP1yNa1GMPAhoLKHf5C8Ub4l6tHfiWIdu9(4DLfGhVBvhlY5yfWWGDi)lzPe2ucsM0fWWGDyrYMUaggSd4OoEMwIdNUa1GMPagSdls24DdqnXt82qGfhO69X7klG0chN5pY3zI3oUbOM4jEBKVZKUa2EUIyCTSnfabHwA6K(ekKV2uJafHU6tOUa0Js615sa]] )

    storeDefault( [[Fury AOE Display]], 'displays', 20170628.135858, [[dStMgaGEPuVePKDruLETuWmLcnBfUjsrpgvUneoSKDsXEf7MW(LI(PuzyqLFdmofrAOO0GLsgoIoiL8zi6yuvhhPQfkvTuIklgjlNkpur6PQwMIQNtYerQ0uH0KjktxPlsvUksfxg01HYgrOTQiQ2mr2oc(OIWPj10iQQVtPgjsPEMIOmAumEfLtcvDlKcCnIQ48OQVHuO1QiITHuqh)GMZvKRgiice7x(bmVJoOnI34LZvKRgiice71THX4pp3vcKWPmqUgsFo1q3U9edGDOY57KKuWDArUAGqfdU8zDssk4oTixnqOIbxo9yqmOm8CaX1THXmFsZrOfwEXmz50JbXGYMwKRgiuPpNVtssbx0YHeUQyWLRya23wVCmwEHkxXaSTWwqOYvma7BRxoglSfK(8TCiHRLGJb4Y77qr7OPC4NG2O58XGlNVtssbxA1RIHg4NRya2OLdjCvPpVbklbhdWLJ2Xkh(jOnAUwitZvlWzj4yaUC5WpbTrZ5kYvdewcogGlVVdfTJM5NeYPRHUDTAGigACEUIbyF00NtpgedsxTdYTAGixo8tqB0Cbgc8CaHkg5NRiHJbXrPyMcgaxqZRy8ZDX4NJmg)CQy8ZMRya2tlYvdeQqLpRtssbxlmxfdU8cZvO8KWCkmjPCe1mlSfedUCQHUD7jgaBRXiu51GKPodWMLGxm(51GKPMcqqvllbVy8ZPluQWgBOYRHDXRyjWM(CcALMsp0lpkpjmNkNRixnqyn0if5t9mOEYLltRihfpkpjmVYDLajeLNeMxu6HE5ZlmxrtTaM(8gOice71THX4ppVgKmfA5qcxwcSX4N7GJ8PEgup5YvKWXG4OumHkVgKmfA5qcxwcEX4NtpgedkdVqMMRwGtL(CtHaMteZX3SLvNxZw0vRihfF(woKWLiqSF5hW8o6G2iEJxUmOuHnwl2gZjI54B2YQZlVbkIaX(LFaZ7OdAJ4nE5ZIbxEnizkRHDXRyjWgJFUeqS5SOnB9sOA2YuohWoN0PruoEIaXEDBym(ZZjDqoacQATyBmNiMJVzlRoV8AqYuNbyZsGng)Ce1mlVyWLJOMD0y8Z3YHeUSe8cvUCWbSuWyMJZNgXrd9LV86NRya2SeytFUIbytlipLwitlqQsF(woKWLLaBOY5aiOQLLGxOYRbjtznSlEflbVy8ZBGIiqS5SOnB9sOA2YuohWoxXaSXlKP5Qf4uPpNVtssbxlmxfdU8Ayx8kwcEPpxXaST8cvUIbyZsWl95Caeu1YsGnu5fMRSeCmaxEFhkAhnB0JiAEnizQPaeu1YsGng)C6X0Cnm5A1x(bmNkhHwC0yWLVLdjCjce71THX4ppVWCfEHeaLNeMtHjjLZvKRgiiceBolAZwVeQMTmLZbSZlmxDs4yGNUXGl3tuudOS0NR0iihqRoVyMNRya2wyUcVqceQ8zDssk4IwoKWvfdU8TCiHlrGyZzrB26Lq1SLPCoGDoFNKKcU4fY0C1cCQyWLpRtssbx8czAUAbovm4YPhdIbTgAKceqXMZLt60ikhpEoG462WyKpUCnhqCYItlqgJ8KR5aIjbaqeJV8KtpgedkJiqSx3ggJ)88zDssk4sREvm(50JbXGYOvVk95i0clSfedU8cZv0rO3CYrXdDzta]] )

    storeDefault( [[Arms Primary]], 'displays', 20170628.135858, [[dWtYgaGEPkVebzxusPTjfzMsrnBfoSKBIu44iLUTI6zsv1oPQ9k2nH9Ri9tLYWGW4Kc6BsPmuumyLKHJOdsPonPogQ6Cus1cLklLsYIjQLtXdvs9uWJrLNtYeLcmvinzkX0v5IkXvLcDzvDDKSrKQTsjfTzISDLQpkvLpdrttkX3PsJeb1YueJgLgpcCse6wifDnPuDEQ43qTwkPWRLs6Wh0aCf5PXc6yXbNZ4dS1iAZe9lbUYG8pMDMihWucK)A2NR10fGwQN6ThAKI5xCb4c4SjjP(BDrEASqfpIaeSjjP(BDrEASqfpIaKg9CzCiYHfGU3hFlicmRf2lX3FaAPEQ3Y6I80yHkDbC2KKu)HwgK)PIhrafl2fC1hhR9s6cOyXU2uhoDbMlca045dCLb5F2cowSjq3gk6gnSIyFegnGtOtZ2BNFcFdBQnR3wlwhbFd7ps0SL2cqqO3oFti6VHn1Et9Z3s7T1pIirZwSEafl2fTmi)tLUaTkBl4yXMaOBmwrSpcJgqlSO5QdBSfCSytaRi2hHrdWvKNglSfCSytGUnu0nAeaiFoDn09QtJfX3gFafl2fqtxaAPEQVbAZZDASiGve7JWObeuZe5Wcv8tcOi)XG(OuSRXdSjObQ45dihpFaKXZhWepFUakwS76I80yHkYbiytss9NnLPIhrGIYuOoKFazkjPaZfb2uhoEebKh6E96BGDThJihOgKSfWIDz2xINpqnizR14z56y2xINpqdEPIACroqnClhfZot6cSRvAz9qFoOoKFa5aCf5PXc7HgPiW6fp6IvbSOvKJYb1H8dubmLa5J6q(bkz9qFobkktrdT4txGwLPJfhO79XZpjqnizl0YG8pMDM45dy(rG1lE0fRcOi)XG(OuSroqnizl0YG8pM9L45dql1t9wikSO5QdBuPlGVM)a2Mz10vmg9CzCcCLb5F0XIdoNXhyRr0Mj6xcmRf2uhoEebAvMowCW5m(aBnI2mr)saAPEQ3croSa09(4N0uGAqYw2d3YrXSZepFac2KKu)rOov88bin65Y4qhloq37JNFsasZZHNLRZMP5a2Mz10vnk07VrvJaAoSWAGXZXZ3EG5Ia7L4reqclUamOtxbLqnDLVmgSBGRmi)JzFjYb0CybqwCAbY4NeWQF8L6JFcc(2q0eFlwlFa5HUxV(gy3ihGGnjj1Fefw0C1HnQ4reWztss9hrHfnxDyJkEebUYG8p6yXfGbD6kOeQPR8LXGDdqWMKK6p0YG8pv8icOyXUefw0C1HnQ0fqXIDTPmfrHeoYbQHB5Oy2xsxafl2LzFjDbuSyx7L0fGdplxhZotKduuMYwWXInb62qr3OrZl0rduuMci)XGydIhraAP0CTAn1k4CgFGkWSwaOXJiWvgK)rhloq37JNFsGIYuefsyuhYpGmLKuaUI80ybDS4cWGoDfuc10v(YyWUbQbjBTgplxhZot88bweL84TKUak9m54T3wIFsaNnjj1F2uMkEebAvMowCbyqNUckHA6kFzmy3a1GKTShULJIzFjE(aCf5PXc6yXb6EF88tcWHNLRJzFjYbuSyxc9oYAHfTaPkDbuSyxMDM0fqXIDbx9XXAtD40fOgKSfWIDz2zINpaTup1BHowCGU3hp)KaoBssQ)iuNkEAYhGwQN6TqOov6cy5LkQXzZ0CaBZSA6Qgf693OQrGIYunk0xaYr58MCj]] )

    storeDefault( [[Arms AOE]], 'displays', 20170628.135858, [[dSdRgaGEjXlrvXUqvPxlrzMsKMTc3ekvhwQVjryBivTtkTxXUjA)ks)usnmuLFd5zsunuuAWkkdhjhKGpdfhJqNdkflujwkQQwmclNkpur1tbpgvEojturKPQutMuz6QCrjCvKcxwvxhrBKu1wveLntkBhQ6JkcNMIPjr03PkJePOLjjnAumEOKtcvUfukDnKsNNQ62kP1QiQoosLJy2b4AQZGK6rYdo)XhOMg7sXzlcCTdZFS4zdraxlX8ZzEUYYsa6iFYxyyWixF5fGlGFTMM6V5n1zqsvS8cGvTMM6V5n1zqsvS8cq5mRTZhhhscMkFSLKxGvJuOi2Ydqh5t(6M3uNbjvzjGFTMM6VD7W8NkwEbumipWZCCmcfHiGIb5jqEOqeyTXc2Xkg4AhM)eKCmixGL69Ug78JBcAUd4hRiFPNE6PVkTytjONw6RsBaSIfBlNVLxE5vPveBOTCXQ0gqXG82TdZFQSeOmcbjhdYfyxZYpUjO5oGrQZW1hYji5yqUa8JBcAUdW1uNbjfKCmixGL69Ug7baQNZ0dtL(mizSLqmGIb5b7SeGoYN8NKX9CNbjdWpUjO5oGKCfhhsQITKbuu)yOF0kM5ObYLDGowXaeXkgatSIbCXkMlGIb5nVPodsQcraSQ10u)jq66y5fOjD92N6dqqQPfyTXsG8qXYlaXWuPYedKNWyeIa9GIPbgKhl(Iyfd0dkMEoALOpw8fXkgysVwtoUqeOhETVIfpBwcG3OmeMH583(uFaIaCn1zqsHHbJmW8c7UG)a6mkQr7V9P(aDaxlX8BFQpqtygMZpqt6ASBKFwcugHEK8atLpwXQb6bftVBhM)yXZgRya3pcmVWUl4pGI6hd9JwXeIa9GIP3TdZFS4lIvmaDKp5RdNuNHRpKtLLa2E9di4wvtNjuxe4AhM)0JKhC(Jpqnn2LIZwey1ifipuS8cugHEK8GZF8bQPXUuC2Ia0r(KVoCCijyQ8XwL(a9GIPfgETVIfpBSIbWQwtt9hFwuXkgGYzwBNVEK8atLpwXQbOCphALOpb2sdi4wvtNjuxeWWHKtocTgRiTbwBSekILxanK8cWUNodAPA6mB7CiVax7W8hl(IqeWWHKavZzKyIL2a8)JVvFSv5jwcE0lws(kgGyyQuzIbYlebWQwtt9hoPodxFiNkwEb8R10u)HtQZW1hYPILxGRDy(tpsEby3tNbTunDMTDoKxaSQ10u)TBhM)uXYlGIb5HtQZW1hYPYsafdYtG014KAOqeOhETVIfFrwcOyqES4lYsafdYtOieb4qRe9XINnebAsxli5yqUal17Dn2lTq)oqt6AG6hdCtkwEbOJ0Wv2KzuW5p(aebwnsyhlVax7W8NEK8atLpwXQbAsxJtQH2(uFacsnTaCn1zqs9i5fGDpDg0s10z225qEb6bftphTs0hlE2yfduiBIXRllbuMvQXluxeB1a(1AAQ)eiDDS8cugHEK8cWUNodAPA6mB7CiVa9GIPfgETVIfFrSIb4AQZGK6rYdmv(yfRgGdTs0hl(IqeqXG84Z7tyK6msmQSeqXG8yXZMLakgKh4zoogbYdLLa9GIPbgKhlE2yfdqh5t(60JKhyQ8XkwnGFTMM6p(SOIfBfdqh5t(64ZIklb09An54eylnGGBvnDMqDrGM010qAUauJ2)D5sa]] )


end
