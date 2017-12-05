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
                    local swing = state.swings.mainhand
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
            usable = function () return target.distance > 7 end
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
   

    storeDefault( [[SimC Arms: single]], 'actionLists', 20171203.205647, [[daKToaqiuqBIQIrjr6uqbRcfiTlu1WGshtclJQQNjr00iP01qLQ2gQu5BOqJdvk5COaQ1HceZdk09iPyFseoiQKfII8quutefO6IKqBefOCssQUPu1oHQFIkfwkk5PetLeTvQk9vuPu7v5VsLbtPdlAXa9yHMmvUSQndOptcgnj50s61qrZwWTLYUr8BidhL64OsrlhPNtQPd66uLTJk(oagpkaNxIA9OaY8bO9tXRykNGNTprQnMnwUOnndIXQRefcFIW(XAgQmqjSIidNXIjSE4P(d3p2cgl8JTK8fCNAvlwUBIePv2Wjt4kcRiIEkhEXuorrscgUBmnrI0kB4eqpGa5btim8UiTmVhBJ1hJTuJvFyhiI4P5H1t9JTtTSJgBjmwSglGaASNB6vzZ(oEOQ3Pa9jStdr0MU7LVXIHjCbwdvy5jGH0DnerBtuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWuiDxdr02ewp8u)H7hBbJfyNW6AKhnE9uo4eMv9iM9ioVDcCGt6ro8S9jdoC)t5efjjy4UX0ejsRSHta9acKxRkHWtVRZDGNOVM3HaGmHlWAOclpjIciT2t3PBPw1e1jUAmHi6ecI8j9iNVjfpBFYe8S9jmJciT2tBSsl1QMW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWHxYPCIIKemC3yAIePv2WjLASLASWmCcKh4PCq0oeWoWecdN)KemCNX6JX6oOhqG8ruaP1E6oDl1Q4PVLvI2yXOXQq0zSyWybeqJLHglmdNa5bEkheTdbSdmHWW5pjbd3zS(ySLASLASGEabYRHiY7u9Kc59yBSacOXgrOGdbaHVHOWm0PH0kMNN(wwjAJfJQXyJiuWHaGWRqabMHUicfCiai803YkrBSyWy9Xyb9acKxRkHWtVRZDGNOVM3HaGySyWyXWeUaRHkS8easki9jMNorDIRgtiIoHGiFspY5BsXZ2NmbpBFc3oPG0NyE6ewp8u)H7hBbJfyNW6AKhnE9uo4eMv9iM9ioVDcCGt6ro8S9jdoC1oLtuKKGH7gttKiTYgoHHglOhqG8GjegExKwUZ90fk3fZqJ3JTX6JXc6beipqu0tFxhnv48AygX0yXOXwsJ1hJLHgBeHcoeae(ikG0ApDNULAv8ESnwFm2snwAQW5JEu6jqJTeQXylkjwJfqanw3b9acKpIciT2t3PBPwfVdbaXybeqJfMHtG8jrHt7Ajjv4TtG8NKGH7mwFm2icfCiai8GjegExKwMN(wwjAJfJQXy5wglgMWfynuHLNaef9031rtf(e1jUAmHi6ecI8j9iNVjfpBFYe8S9jmyOON(oJLvQWNW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWHZ9t5efjjy4UX0ejsRSHtOVLvI2yXOAmwfIoJfqanw6BzLOnwmASCVX6JXgrOGdbaHhmHWW7I0Y803YkrBSy0y9BS(ySLASrek4qaq4bdP7AiI24PVLvI2yXOX63ybeqJLHgR(WoqeXtZdRN6hBNAzhn2sySynwmmHlWAOclpHEIBI6exnMqeDcbr(KEKZ3KINTpzcE2(ewN4MW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWHZDt5efjjy4UX0ejsRSHtIiuWHaGWdMqy4DrAzE6BzLOnwmQgJvHOZy9XyDh0diq(ikG0ApDNULAv803YkrBSLWy5UjCbwdvy5j0KtQWPtuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWk5KkC6ewp8u)H7hBbJfyNW6AKhnE9uo4eMv9iM9ioVDcCGt6ro8S9jdoCgNYjkssWWDJPjsKwzdNa6beiVgIiVt1tkK3J9eUaRHkS8KZaE0d(jQtC1ycr0jee5t6roFtkE2(Kj4z7tuKb8Oh8ty9Wt9hUFSfmwGDcRRrE041t5Gtyw1Jy2J482jWboPh5WZ2Nm4W5wt5efjjy4UX0ejsRSHta9acKhmHWW7I0Y8oeaKjCbwdvy5jioNYgbWPtuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWn4CkBeaNoH1dp1F4(XwWyb2jSUg5rJxpLdoHzvpIzpIZBNah4KEKdpBFYGdNbEkNOijbd3nMMirALnCcOhqG8AvjeE6DDUd8e918ESnwab0yb9acK)mGh9Gve5uDhB6JvDfr4Diait4cSgQWYtAikmdDAiTI5NOoXvJjerNqqKpPh58nP4z7tMGNTpPhrHzWyfiTI5NW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWHxGDkNOijbd3nMMirALnCc9TSs0glgvJX68OjSIigldQXILVKt4cSgQWYtON4MOoXvJjerNqqKpPh58nP4z7tMGNTpH1joJT0cmmH1dp1F4(XwWyb2jSUg5rJxpLdoHzvpIzpIZBNah4KEKdpBFYGdVOykNOijbd3nMMirALnCcmdNa5bEkheTdbSdmHWW5pjbd3zS(ySGEabYhdp5CEhcaIX6JXYqJ9CtVkB23XN0OQKdIO7u9Kt5ovjXnHlWAOclpjgEY5tuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWC4jNpH1dp1F4(XwWyb2jSUg5rJxpLdoHzvpIzpIZBNah4KEKdpBFYGdVW)uorrscgUBmnrI0kB4KmcRCE3jVvV2ylHXwySacOXcZWjqEGNYbr7qa7atimC(tsWWDt4cSgQWYtaqvLgaOsCtuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWTvvPbaQe3ewp8u)H7hBbJfyNW6AKhnE9uo4eMv9iM9ioVDcCGt6ro8S9jdo8IsoLtuKKGH7gttKiTYgojJWkN3DYB1Rnw1ySfgRpgldnwygobYd8uoiAhcyhycHHZFscgUZy9Xyl1yPPcNp6rPNan2sOgJL79BSacOXYqJfMHtG80tC8NKGH7mwab0yzOXcZWjqEAYjv4u(tsWWDglgMWfynuHLNOdzBI6exnMqeDcbr(KEKZ3KINTpzcE2(ejKTjSE4P(d3p2cglWoH11ipA86PCWjmR6rm7rCE7e4aN0JC4z7tgC4fQDkNOijbd3nMMWfynuHLNG4CkBeaNorDIRgtiIoHGiFspY5BsXZ2NmbpBFc3GZPSraCQXwAbgMW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWHxW9t5efjjy4UX0ejsRSHtyOXQpSder808W6P(X2Pw2rJTegl2jCbwdvy5jGH0DnerBtuN4QXeIOtiiYN0JC(Mu8S9jtWZ2NWuiDxdr0MXwAbgMW6HN6pC)ylySa7ewxJ8OXRNYbNWSQhXShX5TtGdCspYHNTpzWbNWGFGPxaoMgCda]] )

    storeDefault( [[SimC Arms: default]], 'actionLists', 20171203.205647, [[dCeFqaqikPSicKnraFsaHrjQ0PukmlkPI2fkgMu5ysvltu8mLIAAeOUMaQTrbX3OaJJcs6CkfrRJcQ5Puv3JGAFcIdsilKG8qLstuarxua2Osr4KIkwjfKYlPGuntbKUjfANu0pPKQmukPsTukXtPAQc0vPKkSvLQ8vkPs2l4VuQbRQdRyXq1JfzYk5YiBgk(mHA0cQttQvtjv1RPKmBHUTu2nQ(nKHdLworpNKPl56O02fv9DbPXRuKoVO06PGeZxPY(vzOhccU50iWDDB79IKnLHVFryg2ybUJLs6jQnuMsJ4GPb9GBHI0OiWmtxVb9z62mtVHiyb3ziG7jPgBbo4IsLgXvqqWShccEa8bpslqiWfHRJ6kl4PWJumbEo8LonfscohXjWnIw7nsZPrGdU50iW3gEKIjWTqrAueyMPR3G(oWTqkeRmrkiiuGVnmLSYikp1iEb4GBeTmNgbouGzgii4bWh8iTaHa3tsn2c8CV3A3xtK4fZKFQrYq8bpsR73T7ECwmyyM8tnsgwS3VX9cCpolgmm4tvrYojZYWI9EbUFr4SyWWKqrKsXQSvTrfMHf7972DFnsXuXu6gzxi7LMUFFHVpJHaUiCDuxzbhlQ0io4BdtjRmIYtnIxao4grR9gP50iWb3CAe4w3OsJ4GlskwboFAKWccfx2HosbbUfksJIaZmD9g03bUfsHyLjsbbHc8C4lDAkKeCoItGBeTmNgbokUSdDKqbMBgccEa8bpslqiW9KuJTahNfdgg8PQizNKzzyXE)UD3xJumvmLUr2fYEPP73x477neWfHRJ6kl44reAzJHvMf8C4lDAkKeCoItGBeT2BKMtJahCZPrGlueHw3VjyLzb3cfPrrGzMUEd67a3cPqSYePGGqb(2WuYkJO8uJ4fGdUr0YCAe4qbMcgccEa8bpslqiW9KuJTahNfdgg8PQizNKzzyXE)UD3xJumvmLUr2fYEPP73x4777bxeUoQRSGJtsfjTsZfdEo8LonfscohXjWnIw7nsZPrGdU50iWfIKksALMlgCluKgfbMz66nOVdClKcXktKcccf4BdtjRmIYtnIxao4grlZPrGdfygyii4bWh8iTaHa3tsn2cCCwmyyWNQIKDsM1ErZkM1onXgZcfk)EbUxoIjMfHrN019HCVG7UxG7tiuCHcLZGpvfj7KmlJKAJMRUpK77axeUoQRSGpY0Wj7cjLeVaph(sNMcjbNJ4e4grR9gP50iWb3CAe4IKPHt3hejLeVa3cfPrrGzMUEd67a3cPqSYePGGqb(2WuYkJO8uJ4fGdUr0YCAe4qbMgcee8a4dEKwGqG7jPgBbEcHIluOCgXre(eTtiuCHcLZiP2O5Q73)(oMmb(EbUp37XzXGHbFQks2jzwgwS3VB39jekUqHYzWNQIKDsMLrsTrZv3V)99b((nUF3U7RrkMkMs3i7czV0097l89z6axeUoQRSGp5NAKGNdFPttHKGZrCcCJO1EJ0CAe4GBoncCr5NAKGBHI0OiWmtxVb9DGBHuiwzIuqqOaFBykzLruEQr8cWb3iAzoncCOatdGGGhaFWJ0cecCZPrGBrZfFpcZ9BrX4GvP5IVFtWwSssbEo8LonfscohXjWfHRJ6kl4snxSncJDcfJdwLMl2gdBXkjf4wifIvMifeekWTqrAueyMPR3G(oW9KuJTahNfdgg8PQizNKzzyXEVa3ViCwmyysOisPyv2Q2OcZWI9EbU3A3JZIbdtrnS1uAeNHfluGPHkee8a4dEKwGqGBonc8aPCyfhUUhH5EhXgvGNdFPttHKGZrCcCr46OUYc(soSIdx2im2keBubUfsHyLjsbbHcCluKgfbMz66nOVdCpj1ylWZ9(CVhRKYBloTy6zAiznrBvj1wr3VB39jekUqHYzAiznrBvj1wrmsQnAU6(qe((nF)g3lW94SyWWGpvfj7KmlJKAJMRUpeHVFZ3lW9lcNfdgMekIukwLTQnQWmSyVFJZqdkWCtcbbpa(GhPfie4MtJa3qxhdew)HwepqOUxiwjxZfFV1Lwfg8C4lDAkKeCoItGlcxh1vwWTshT(dTiUYgNvY1CX2HQvHb3cPqSYePGGqbUfksJIaZmD9g03bUNKASf4lcNfdgMekIukwLTQnQWmSyHcm77GGGhaFWJ0cecCpj1ylWZ9(CVVgPyQykDJSlK9st3hIW3Bq3972DVIkBCeNvXuAsMPZwWyt3hY9D3VX9cCFU3N79jekUqHYzehr4t0oHqXfkuoJKAJMRUFFHVVJjW3lW9yLuEBXPftpJCYpIj59BC)UD3BT7Rjs8Iro5hXKKH4dEKw3lW9w7(ecfxOq5mIJi8jANqO4cfkNrsTrZv3hY9D3lW91iftfZIWzXGHjHIiLIvzRAJkmJKAJMRUpeHVpW3lW95EV1UpHqXfkuodECwKQqYgJKAJMRUpK77UF3U7T29kQSXrCwftPjzMoBbJnDFi33D)g3lW95EV1UVMiXlgjXxmeFWJ06(D7UFHkgjXxmsQnAU6(qUxW3VX9BC)g3VB394SyWWqBkLylnItsLnwjL0knIZOQjz19cFFM7f4ECwmyyuHNQijTSxegIRifdl27f4ERDFcHIluOCgXre(eTtiuCHcLZiP2O5Q7d5(U7f4ERDVIkBCeNvXuAsMPZwWyt3hY9DGlcxh1vwWXNQIKDsMf8C4lDAkKeCoItGBeT2BKMtJahCZPrGl0uvKUFRml4wOinkcmZ01BqFh4wifIvMifeekW3gMswzeLNAeVaCWnIwMtJahkWSVhccEa8bpslqiW9KuJTahNfdgg8PQizNKzzyXEVa3ViCwmyysOisPyv2Q2OcZWIfCr46OUYcoRIS1f1uGNdFPttHKGZrCcCJO1EJ0CAe4GBoncCRdfDFof1uGBHI0OiWmtxVb9DGBHuiwzIuqqOaFBykzLruEQr8cWb3iAzoncCOaZ(mqqWdGp4rAbcbUNKASf41iftftyAIvygSP6(9f((mD3lW9tQ05jBItnnPUF)7dm4IW1rDLfCjl3EsLgXTJAvb(2WuYkJO8uJ4fGdUr0AVrAoncCWnNgbUfw(9IsLgXVpq1QcCrsXkW5tJewqUUT9ErYMYW3tBkLylsqwN1iftLTgJW1iftftyAIvygSPAFHZ0jWKkDEYM4uttQ9dm4wOinkcmZ01BqFh4wifIvMifeekWZHV0PPqsW5iobUr0YCAe4UUT9ErYMYW3tBkLylckWSFZqqWdGp4rAbcbUNKASf4tQ05jBItnnPUpeHVxWGlcxh1vwWLSC7jvAe3oQvf4BdtjRmIYtnIxao4grR9gP50iWb3CAe4wy53lkvAe)(avRQ7ZTFdWfjfRaNpnsyb56227fjBkdFViRxaccCluKgfbMz66nOVdClKcXktKcccf45Wx60uij4CeNa3iAzoncCx32EViztz47fz9cakWSxWqqWdGp4rAbcbUNKASf4tQ05jBItnnPUpeHVpd4IW1rDLfCjl3EsLgXTJAvb(2WuYkJO8uJ4fGdUr0AVrAoncCWnNgbUfw(9IsLgXVpq1Q6(CZSb4IKIvGZNgjSGCDB79IKnLHVpfPjpjiWTqrAueyMPR3G(oWTqkeRmrkiiuGNdFPttHKGZrCcCJOL50iWDDB79IKnLHVpfPjpbfy2hyii4bWh8iTaHa3tsn2c8AKIPIjmnXkmd2uDFi3NPdCr46OUYcUKLBpPsJ42rTQaFBykzLruEQr8cWb3iAT3inNgbo4MtJa3cl)ErPsJ43hOAvDFUBEdWfjfRaNpnsyb56227fjBkdFVsZfhjbbUfksJIaZmD9g03bUfsHyLjsbbHc8C4lDAkKeCoItGBeTmNgbURBBVxKSPm89knxCKGckWdKeMHnwGqqbaa]] )

    storeDefault( [[SimC Arms: precombat]], 'actionLists', 20171203.205647, [[b4vmErLxt5uyTvMxtnvATnKFGfKCTnNo(bgCYv2yV1MyHrNxtnfCLnwAHXwA6fgDP9MBE50nX41usvgBLf2CL5LtYatm3eJmWmJlXydn0aJnEn1uJjxAWrNxt51ubngDP9MBZ5fvE5umErLxtvKBHjgBLrMxc51ubjwASLgD551uW9gDP9MBEnvsUrwAJfgDVjNxt52BUvMxt10BKzvyY5uyTvMxt51uofwBL51uq9gDP9MBEnvqYD2CEnLBH1wz9iYBSr2x3fMCI41usvgBLf2CL5LtYatm3edmEnLuLn3B1j3yLnNxu5fDEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxt9gBK91DHjNx05fDEnfrLzwy1XgDEjKx05Lx]] )

    storeDefault( [[SimC Arms: execute]], 'actionLists', 20171203.205647, [[d8dBlaWCuTELOWMqc7cfBJQK2hsKldEmvMTOMpPs3uP68Iu3wvoTq7eQ2R0UjSFs(PsuPHbfJtjk13qsEnvvdMOHJuDqKItHe1XukNtjQyHiPwkP0IvvlhXdjf9uklJQY6uIQAIkrrtLu1KfmDvUiPI)QKEgPqxhL2OsuLTsvQnlITdL8DLWxHsftdkL5js6Wk(msPrtvmEQsCsrIdbLkDnOu19uI8BihxjkzuKcUBvFn85b1S4ttLKgYJV8vsWlGJ9GAgDWfNCCzmxejkovB10czy4qX9HzJQnFy0iZMxXg2W41AMJePF1QrJ7IibV6l(w1xthX8ZqOuxZCKi9R2NnjH5p3LHvhjndlDLKcLudkjhU1psWYzUiq8HzfB0DkjLusmkPU6QKWYInsNoeyopWkTeyUv(Hip(kKguskxJMFmhV01(5ja8drE1sreIU5qKAcKaQTJcEpe85b1QHppOg15ja8drE10czy4qX9HzJQnm10cCelXb8QVxnn9ao)7iSGhiU(RTJc4ZdQ1R4(Q(A6iMFgcL6AMJePF1(SjjmCpZDabcRbibeCGZeqlekjfkPguYpBscZFUldRosAMaAHqj1vxLudk5NnjHb8c4yVisae(kDc4I8isWWVX5xjxsj9PKuOKAqjDiuoGwiy(ZDzy1rsZqG3efCLmvLCtj1vxL8ZMKW8N7YWQJKMHLUsszLKYkjLRrZpMJx6AougX5S8v(B4EQLIieDZHi1eibuBhf8Ei4ZdQvdFEqnnrzeNZYvs7nCp10czy4qX9HzJQnm10cCelXb8QVxnn9ao)7iSGhiU(RTJc4ZdQ1R4AS6RPJy(ziuQRzosK(vZHq5aAHG5Hi3Kx5hj6hyiWBIcUsM6skPdHYb0cbdTz0FYRoekhqleme4nrbxjPqj)SjjmCpZDabcRbibeCGZeqlekjfk5NnjHb8c4yVisae(kDc4I8isWWVX5xjxsj9vJMFmhV01wmKpbg)aPwkIq0nhIutGeqTDuW7HGppOwn85b1Wod5tGXpqQPfYWWHI7dZgvByQPf4iwId4vFVAA6bC(3rybpqC9xBhfWNhuRxXXw1xthX8ZqOuxZCKi9RgzOfycqs0fpLmvLuJyVssHs(ztsysqowoewjdTad)gNFLmvLuJ1O5hZXlDTeKJLdHvYqlulfri6MdrQjqcO2ok49qWNhuRg(8GAlpKJLdbLu7qlutlKHHdf3hMnQ2WutlWrSehWR(E100d48VJWcEG46V2okGppOwVIJ9vFnDeZpdHsDnZrI0VAe4nrbxjtvjXELKcL0Hq5aAHG5p3LHvhjndbEtuWvYuvsFkjfkPgushcLdOfcMFEca)qKhdbEtuWvYuvsFkPU6QKyxLKd36hjy5mxei(WSIn6oLKskjgLKY1O5hZXlDncic1sreIU5qKAcKaQTJcEpe85b1QHppOMwqeQPfYWWHI7dZgvByQPf4iwId4vFVAA6bC(3rybpqC9xBhfWNhuRxX9A1xthX8ZqOuxZCKi9RMdHYb0cbZFUldRosAgc8MOGRKPUKssRlOKuOKb4ZMKW4qzeNZYx5VH7HHaVjk4kjLusVwJMFmhV01idwdTaPwkIq0nhIutGeqTDuW7HGppOwn85b10oyn0cKAAHmmCO4(WSr1gMAAboIL4aE13RMMEaN)DewWdex)12rb85b16vCQQ(A6iMFgcL6AMJePF1(SjjmGxah7frcGWxPtaxKhrcg(no)k5skPpLKcL8ZMKWW9m3beiSgGeqWbodl9A08J54LU2drUjVYps0pulfri6MdrQjqcO2ok49qWNhuRg(8GA7iYnzL0os0putlKHHdf3hMnQ2WutlWrSehWR(E100d48VJWcEG46V2okGppOwVIVSR(A6iMFgcL6AMJePF1UjdIJjbiyHiROK1)CxgyaX8ZqqjPqj)SjjmlGiTEoiS(Ztay4348RKlPKAujPqjdWNnjHXHYioNLVYFd3ddlDLKcL8ZMKW8N7YWQJKMjGwiQrZpMJx6Al8ej5frrOwkIq0nhIutGeqTDuW7HGppOwn85b1WoEIK8IOiutlKHHdf3hMnQ2WutlWrSehWR(E100d48VJWcEG46V2okGppOwVIVCQ(A6iMFgcL6AMJePF1idTaJJLqaXPKPQKydtnA(XC8sxdHfqOJwaKAPicr3Cisnbsa12rbVhc(8GA1WNhuB5IfqOJwaKAAHmmCO4(WSr1gMAAboIL4aE13RMMEaN)DewWdex)12rb85b16v8nmvFnDeZpdHsDnZrI0VAF2KegUN5oGaH1aKacoWzcOfcLuxDvsYqlW4yjeqCkjLwsjXggLuxDvYBYG4ycdR4YaNZaI5NHGssHssgAbghlHaItjP0skPg9AnA(XC8sxd8c4ypOwkIq0nhIutGeqTDuW7HGppOwn85b10XlGJ9GAAHmmCO4(WSr1gMAAboIL4aE13RMMEaN)DewWdex)12rb85b16v8TTQVMoI5NHqPUM5ir6xnnOKJ7IybRGaErGRKusj3uskRKuOKyxLKd36hjy5mxei(WSIn6oLKskjMA08J54LU2ppbGFiYRMMEaN)DewWdex)12rbVhc(8GA1WNhuJ68ea(HipLudBuUgneA51IIdiew63sB10czy4qX9HzJQnm10cCelXb8QVxTueHOBoePMajGA7Oa(8GA96vBzcjdB(k19Aba]] )

    storeDefault( [[SimC Arms: AOE]], 'actionLists', 20171203.205647, [[d4t8laGEeIQnHq1UukBdHI9HqQBRWJP0SPy(ujCtj6Ws9nfv3JkPDQK9k2nQ2pk(jcrzykvJdHionPEoHbJudxcDqfXPqj1XOIZHqGfQOSue1IrYYj6HsWQqiOLjPSoec1eriKPIitMQMoOlIs8mQeDzvxxsETKQTIs1MjP2oj8DfPVIqY0qO08ij1Njj(ljA0iy8KK0jrPmkusUgjjopvQNcDieI0VbooHuWvpEqupkWqproeeXm0tiYyjiw8wDB0e5nud4zn3ji5BElEw12DM7uB3LBoedXsS7etq0k1fHbdoXc1aUiKYYjKcYcVPm3NzbrRuxegKvm0waW4bt5BuM2FbeihBvfzODHlyOTaGXdMY3OmT)ciqo2KF0AUGHw1UYqRI1ZqZAgAIZqZkgAlay8GP8nQgcnxPv6ERQidTlCbdTfamEWu(gvdHMR0kDVj)O1CbdTQDLHwfRNHM1bNqPnAO7GtBjL8D9ldYg3RTneidYb8hSe4zVLRE8Gbx94bjQwsjFx)YGKV5T4zvB3zUZEqYxaQK2lcPadwGWT1lbk(4CyOcwc8RE8GbMvTqkil8MYCFMfeTsDryqQk1Q3OAi0CLwP7TQIm0eNHMiLHg2MZHBYwrRYLBN3uM7doHsB0q3bPmT)ciqocYg3RTneidYb8hSe4zVLRE8Gbx94bNzA)fqGCeK8nVfpRA7oZD2ds(cqL0ErifyWceUTEjqXhNddvWsGF1JhmWSCzifKfEtzUpZcIwPUimiSnNd3KTIwLl3oVPm3ZqtCgAlay8GP8nQgcnxPv6Et(rR5cgAv7kdTkwpdnXzO9NQsT6nlWaeIkHsXOfe2KF0AUGHMOzOjMGtO0gn0DqzROv5YGSX9ABdbYGCa)blbE2B5QhpyWvpEqYTIwLlds(M3INvTDN5o7bjFbOsAViKcmybc3wVeO4JZHHkyjWV6XdgyweBifKfEtzUpZcIwPUimivLA1BAUs1aPsiHRSU2y28GPCgAIZqdBZ5WnnxPAGujKWvwxBmBN3uM7doHsB0q3bTadqiQekfJwqiiBCV22qGmihWFWsGN9wU6XdgC1JhSaWaeIkbdnoAbHGKV5T4zvB3zUZEqYxaQK2lcPadwGWT1lbk(4CyOcwc8RE8GbMLQesbzH3uM7ZSGOvQlcd6pvLA1BwGbievcLIrliS5bt5m0eNHUTqTIR88p0xWqRAxzOD2doHsB0q3bTadqiQekfJwqiybc3wVeO4JZHHkyjWZElx94bdYg3RTneidYb8hC1JhSaWaeIkbdnoAbbgAw5W6GtKQicADBnxjSLQCOWvNGKV5T4zvB3zUZEqYxaQK2lcPadwWT1CsTuLdfzwWsGF1JhmWSiMqkil8MYCFMfeTsDryW2c1kUYZ)qFbdnr7kdTQeCcL2OHUdAnVv8GSX9ABdbYGCa)blbE2B5QhpyWvpEWcM3kEqY38w8SQT7m3zpi5lavs7fHuGblq426LafFComublb(vpEWaZAEifKfEtzUpZcIwPUimyBHAfx55FOVGHMODLHwvyOjodnvLA1BwZBfFRQyWjuAJg6o4ucAPzQM7dYg3RTneidYb8hSe4zVLRE8Gbx94bjkcAPzQM7ds(M3INvTDN5o7bjFbOsAViKcmybc3wVeO4JZHHkyjWV6XdgywejHuqw4nL5(mliAL6IWGTfQvCLN)H(cgAI2vg65bNqPnAO7GtjOLMPAUpiBCV22qGmihWFWsGN9wU6XdgC1JhKOiOLMPAUNHMvoSoi5BElEw12DM7ShK8fGkP9IqkWGfiCB9sGIpohgQGLa)QhpyGzreesbzH3uM7ZSGOvQlcdsvPw9MGqdHxEVs)vFU4Inpykp4ekTrdDh0cmaHOsOumAbHGSX9ABdbYGCa)blbE2B5QhpyWvpEWcadqiQem04OfeyOzvnwhK8nVfpRA7oZD2ds(cqL0ErifyWceUTEjqXhNddvWsGF1JhmWSC2dPGSWBkZ9zwq0k1fHbPQuREtab8RKWBjCRQyWjuAJg6o4v1BRGpiBCV22qGmihWFWsGN9wU6XdgC1JhKfv92k4ds(M3INvTDN5o7bjFbOsAViKcmybc3wVeO4JZHHkyjWV6XdgywooHuqw4nL5(mliAL6IWGuvQvVji0q4L3R0F1NlUyRQidTlCbdnvLA1BxvVTcQb8lfklkVvl0a(MhmLhCcL2OHUdoasyBukGsD9hKnUxBBiqgKd4pyjWZElx94bdU6XdwcKW2WqJqPU(ds(M3INvTDN5o7bjFbOsAViKcmybc3wVeO4JZHHkyjWV6Xdgywo1cPGSWBkZ9zwq0k1fHbLF0AUGHw1UYq7RKnud4m0eHm07BUKHM4m0TfQvCLN)H(cgAv7kdTldoHsB0q3bLN7dwGWT1lbk(4CyOcwc8S3YvpEWGSX9ABdbYGCa)bx94bjFUp4ePkIGw3wZvcBPkhkC1ji5BElEw12DM7ShK8fGkP9IqkWGfCBnNulv5qrMfSe4x94bdmlhxgsbzH3uM7ZSGtO0gn0DqR5TIhKnUxBBiqgKd4pyjWZElx94bdU6XdwW8wXzOzLdRds(M3INvTDN5o7bjFbOsAViKcmybc3wVeO4JZHHkyjWV6XdgywoeBifKfEtzUpZcoHsB0q3bNsqlnt1CFq24ETTHazqoG)GLap7TC1Jhm4Qhpirrqlnt1CpdnRQX6GKV5T4zvB3zUZEqYxaQK2lcPadwGWT1lbk(4CyOcwc8RE8GbgyqIORURmWmlWea]] )

    storeDefault( [[SimC Arms: cleave]], 'actionLists', 20171203.205647, [[dSd2haGEuPuBIsKDHk2gLO2NusA2sCtk13KsDBfUSQDkv7LSBk2VI8yQmmL43qDEkPtlPbROgoQKdkQ8CuoMOCoevXcfvTuLQfJWYr6HIWQqLcltjzDiQQMiIQYuvktMQMoKlIioeIQ0Zqu56sXgrLI2kIYMfjBhv57sj(QusmnPKAEuc(RsQplIgnQQXJkvojI0tbxdvQ6EucDyHXHkL8ArQvM2e0JXfa1rIP5C0bJ8pn7kp4Dbax3vJsLBhOk2OE7mb7V8GD1xTK1oB1c54Kz5w36fllaC0kxibcY5qvSHPn1Z0Masmbr5ELxa4OvUqciAsLIdrGqLV2rTYPHRPzlnntENMrr5gehAWlsEkNBcIY9cYrulvKvbeLWFgcthci14RUaHPcmyZfyJ9Kf0EmUab9yCb5lH)meMoeS)Yd2vF1sw7Sfb7NHBOUZ0MqcsW)U02yEFCdsecSX(EmUaHuFL2eqIjik3R8cahTYfsakk3G4qdErYt5CtquUFA2stZomU4XTy4qeiu5RDuRCOFevdBA2cwCAoPZpnBPPz)jAsLIJdxWmwdBnBem(COFevdBAUvNMTSGCe1sfzvan4fjpvaPgF1fimvGbBUaBSNSG2JXfiOhJlyp4fjpvW(lpyx9vlzTZweSFgUH6otBcjib)7sBJ59XniriWg77X4cesDYPnbKycIY9kVaWrRCHe4prtQuCC4cMXAyRzJGXNJh3IrqoIAPISkWHlygRHTMncgFbj4FxABmVpUbjcb2ypzbThJlqaPgF1fimvGbBUGEmUGe4cMXAytZWiy8fKJMKjWz1v(AuqtEeZIzc2F5b7QVAjRD2IG9ZWnu3zAtibjS6kFlOjpIP8cSX(EmUaHuV1AtajMGOCVYlaC0kxibenPsXHXpqOtVFT)PUHDghpUfJGCe1sfzvqlbLG(i9Pci14RUaHPcmyZfyJ9Kf0EmUab9yCbTsqjOpsFQG9xEWU6RwYANTiy)mCd1DM2esqc(3L2gZ7JBqIqGn23JXfiK6CV2eqIjik3R8cahTYfsansEo(NQ6QOPzlmntoUFA2stZenPsXjf21WUFnnsEomu4spnBHPzYjihrTurwfKc7Ay3VMgjVasn(QlqyQad2Cb2ypzbThJlqqpgxa3e7Ay3pnVhjVG9xEWU6RwYANTiy)mCd1DM2esqc(3L2gZ7JBqIqGn23JXfiK6wwBciXeeL7vEbGJw5cjG(runSPzlyXPzFdnqvSzAMBmnVWHCcYrulvKvb0B8csW)U02yEFCdsecSXEYcApgxGasn(QlqyQad2Cb9yCb734fKJMKjWz1v(AuqtEeZIzc2F5b7QVAjRD2IG9ZWnu3zAtibjS6kFlOjpIP8cSX(EmUaHuVT2eqIjik3R8cYrulvKvbdmffL1meTM(ci14RUaHPcmyZfyJ9Kf0EmUab9yCb2ykkktZaIwtFb7V8GD1xTK1oBrW(z4gQ7mTjKGe8VlTnM3h3GeHaBSVhJlqi15wAtajMGOCVYlihrTurwfCU7Ug0fqQXxDbctfyWMlWg7jlO9yCbc6X4ciH7URbDb7V8GD1xTK1oBrW(z4gQ7mTjKGe8VlTnM3h3GeHaBSVhJlqi1jpAtajMGOCVYlihrTurwf4kp4DbKA8vxGWubgS5cSXEYcApgxGGEmUGeLh8UG9xEWU6RwYANTiy)mCd1DM2esqc(3L2gZ7JBqIqGn23JXfiK6zlAtajMGOCVYlihrTurwf0c)kT0s14fqQXxDbctfyWMlWg7jlO9yCbc6X4cAf(vAPLQXly)LhSR(QLS2zlc2pd3qDNPnHeKG)DPTX8(4gKieyJ99yCbcjKaY3tfnfKYlKe]] )

    storeDefault( [[SimC Fury: three targets]], 'actionLists', 20171203.205647, [[dOZweaGEsj1Maf2LG2gPu2hrvmBHMVeYnLOBdyNszVu7gX(HYOaLmmj53eEoixwzWq1Wjkheu1PafDmbESQAHsWsvLwmqlhPhcHEkQLrkwhPenrIQ0uHutwQMUkxeICEi4zKs11jvBucvBLOYMjsBNiCAs(kPK8zi57quhw0FbvgTQy8sOCsIOPbk11iLW9iQQ(MKYHiQkVws1oWOn3sGzMvaiIHxCDkcAjg(9q3WWVKIAhKzw2(QmQ068ucIB10y(DXLqZnnvb1c0uP9WaTbByxPnZ8NQKDMnd))uccKr7wGrBgjscgx3fmZFQs2zguxQ0qOtqgCplPxOUmZWdQIQdbZRy7RFZSKKU6NNGAMiiZCPOlxsBjWmBULaZmsfBF9BMFxCj0CttvqTGkZVdsOt)dYO9zgXN9RxkKyaJCg0CPO3sGz2NBAmAZirsW46UGz(tvYoZG6sLgcS8G7hxkXOH6YWWHbgoSWWHfgoOUuPHJqtulSlqMGHddmC5dd)Y4ixOuQ4EueuWbok0O1hnCKemUogomXWlQimCyHHttul8RtPJCy4YJ8JHhuvHHddm8lJJCHsPI7rrqbh4OqJwF0WrsW46y4WedhMy4fvegoOUuPHajeu(PluxMz4bvr1HGzAcilrnZss6QFEcQzIGmZLIUCjTLaZS5wcmZVjGSe1m)U4sO5MMQGAbvMFhKqN(hKr7ZmIp7xVuiXag5mO5srVLaZSp30UrBgjscgx3fmZFQs2z(Y4ixOIqgfoAIAHJKGX1ndpOkQoemttukck4aJcKnljPR(5jOMjcYmxk6YL0wcmZMBjWm)MOueuy4fIcKn)U4sO5MMQGAbvMFhKqN(hKr7ZmIp7xVuiXag5mO5srVLaZSp3GTrBgjscgx3fmdpOkQoemdgfI(9OOqNzjjD1ppb1mrqM5srxUK2sGz2ClbM5crHOFpkk0z(DXLqZnnvb1cQm)oiHo9piJ2NzeF2VEPqIbmYzqZLIElbMzFUPfgTzKijyCDxWm8GQO6qWmYpkAezfPBwssx9ZtqnteKzUu0LlPTeyMn3sGzwREu0iYks387IlHMBAQcQfuz(DqcD6FqgTpZi(SF9sHedyKZGMlf9wcmZ(8zwEN0upEUGpBa]] )

    storeDefault( [[SimC Fury: single target]], 'actionLists', 20171203.205647, [[d4dQjaGAbsTEfcBIcAxO02acTpfspxOztvZxPQBQuUns(gq5Yq7eWEL2TQ2pHrbunmvQXjqKZlGttPbt0WPIoifYPashtqNtGkluHAPivlwjlhvpKIYtjTmQK1jqutuGetLImzfnDqxKc1JvXZui66OyJabBLIQnRGTtfmpbk9vbsAAar9DLkhw0FPsnAvY4fO4KuH(ms5AarUNavDibcVMc8Be3WAQkqsHvvlLzcjiWWdeKfYO9P5rHeMCAiSQ6ep20BhrcTKVaG5QkD0JzelGR7qWcDDps2qqeKb5BqSQE4wNWQvn6aTKpwtfiSMQA8Nlpo74Q6HBDcRUyggyhycAloZO7bgEawgNcPHc5IzyGDGjOT4mJUhy4by5ivA)OqgScPRQgTSElmq1LNqMWllpcR64pTNes4vFYJv3itZtoqsHvRcKuy1XEczcVS8iSkD0JzelGR7qWcVRshJeg(bJ1uHvn7cpgSrCaPWh2v1nYeiPWQfwax1uvJ)C5XzhxvpCRtyvy6XhYoWXFebyXpxECkKgkKGlKlMHb2bo(Jia7KS7fY97fYfZWa7ah)reGLJuP9JczWg8cPlHe0QgTSElmq1bgULWeDh9z8QQJ)0EsiHx9jpwDJmnp5ajfwTkqsHvbbgULWefs1NXRQ0rpMrSaUUdbl8UkDmsy4hmwtfw1Sl8yWgXbKcFyxv3itGKcRwybgznv14pxEC2Xv1d36ewDXmmWIppPHSmofsdfsy6XhYA)h5U5jnKf)C5XzvJwwVfgOkpPzFAUxEYUQo(t7jHeE1N8y1nY08KdKuy1QajfwLEsZ(0eYXEYUQ0rpMrSaUUdbl8UkDmsy4hmwtfw1Sl8yWgXbKcFyxv3itGKcRwyba5AQQXFU84SJRQhU1jSkm50qi7fME4fRZduihviDfkKgkKGlK8KgYEy4C8Hc5ObVqgEFlK73lKbHqctp(q2bobEzFAUxipICdqol(5YJtHeuH0qHeCHeCHeCH8qi(jz3ZUsi0JUp8aSCKkTFuihvibjHC)EH8qi(jz3ZU8eYCLWlwosL2pkKJkKGKqcQqAOqgecjm94dzpj)tAil(5YJtHeuHC)EHeCHeCH8qi(jz3ZUsi0JUp8aSCKkTFuihvihPqUFVqEie)KS7zxEczUs4flhPs7hfYrfYrkKGkKgkKW0JpK9K8pPHS4NlpofsqfsqfY97fYfZWalvgJ5HJSmoRA0Y6TWav5jLZKgw1XFApjKWR(KhRUrMMNCGKcRwfiPWQ0tkNjnSkD0JzelGR7qWcVRshJeg(bJ1uHvn7cpgSrCaPWh2v1nYeiPWQfwaqQMQA8Nlpo74Q6HBDcRUyggyJqYJUVWKdzzCkKgkKGlKGlKW0JpK1(pYDZtAil(5YJtH0qH8qi(jz3ZYtA2NM7LNSJLJuP9Jc5OczOqcQqUFVqUyggyXNN0qwgNcjOvnAz9wyGQyWGhgiw1XFApjKWR(KhRUrMMNCGKcRwfiPWQghm4HbIvPJEmJybCDhcw4Dv6yKWWpySMkSQzx4XGnIdif(WUQUrMajfwTWcaI1uvJ)C5Xzhx1OL1BHbQU8eYeEz5ryvh)P9KqcV6tES6gzAEYbskSAvGKcRo2tit4LLhHcj4HGwLo6XmIfW1DiyH3vPJrcd)GXAQWQMDHhd2ioGu4d7Q6gzcKuy1clay1uvJ)C5XzhxvpCRty1icDViptKfArEyW52LZJqoQqElKgkKbHqctp(qw7)i3npPHS4NlpoRA0Y6TWavhy4wct0D0NXRQo(t7jHeE1N8y1nY08KdKuy1Qajfwfey4wctuivFgVesWdbTkD0JzelGR7qWcVRshJeg(bJ1uHvn7cpgSrCaPWh2v1nYeiPWQfwGGunv14pxEC2Xv1d36ewDXmmWUJJhdSpn3R07zzCkKgkKlMHbw85jnKLXzvJwwVfgO6Ull3VZ(ZQo(t7jHeE1N8y1nY08KdKuy1QajfwnOEz5(D2FwLo6XmIfW1DiyH3vPJrcd)GXAQWQMDHhd2ioGu4d7Q6gzcKuy1clqWvtvn(ZLhNDCvJwwVfgOkpPzFAUxEYUQo(t7jHeE1N8y1nY08KdKuy1QajfwLEsZ(0eYXEYoHe8qqRsh9ygXc46oeSW7Q0XiHHFWynvyvZUWJbBehqk8HDvDJmbskSAHfi8UMQA8Nlpo74QgTSElmq1bgULWeDh9z8QQJ)0EsiHx9jpwDJmnp5ajfwTkqsHvbbgULWefs1NXlHeCxGwLo6XmIfW1DiyH3vPJrcd)GXAQWQMDHhd2ioGu4d7Q6gzcKuy1clSAqbhsgpSJlSf]] )

    storeDefault( [[SimC Fury: default]], 'actionLists', 20171203.205647, [[du09BaqiqQSikf2er0OajNsLQBbsPyxiAyGQJbILjbptcvtJsrxdKI2giL8nkrJtcLCoqkSokLAEsi3tLO9rPKdQsAHefpuLYebPkDrbLnsjyKGukDsbvZucf3eH2jj(jivXqLqPAPuspLQPkixvcLYwvjSxO)krdwXHfTyGESqtwfxg1MjQ(mrA0uQonPwniLQxtuA2uCBjTBK(TQgoOCCkHSCcphW0L66K02fOVtegpiv15rW6PeQ5lG9R0ieme6kzLr311B7ybvbbBVZHLNQMgDhgh1PrBXzRFkQyzb0TYgobyuPaCiwcPa8ItcbAztBchAHUhfAyn6OFn26NcGHqfiyi0dJMGg(GYG(vqTr3eqpApfsz0dNE0XSFb60NYOt8pxKcLSYOJUswz0Vzpfsz0TYgobyuPaCiwcbo6wzGxvezame2OFZohLL4hKRmTrq0j(hLSYOJnQuadHEy0e0Whug09OqdRrVtHuUjpAGoPrEhBTd0e9RGAJUjGEmnMYm26NwA0an6Htp6y2VaD6tz0j(NlsHswz0rxjRm63sJzNRXw)0DkgnqJ(vHua0PzLV0gUUEBhlOkiy7DQFqUY02gOBLnCcWOsb4qSecC0TYaVQiYayiSr)MDoklXpixzAJGOt8pkzLr311B7ybvbbBVt9dYvM2yJkfhdHEy0e0Whug09OqdRrh9RGAJUjGUDw86yPHtyOho9OJz)c0PpLrN4FUifkzLrhDLSYOdTLfVoUtXWjm0TYgobyuPaCiwcbo6wzGxvezame2OFZohLL4hKRmTrq0j(hLSYOJnQytme6HrtqdFqzq3JcnSgDqv5YjbZUnCzuqGuf2osUdu7aQkxozgm7uqQcBNab2b62PtdtBYmy2PGKPjOHp7Ch9RGAJUjGoSV1pf9WPhDm7xGo9Pm6e)ZfPqjRm6ORKvg9I9V1pf9RcPaOtZkFPnEZPuIuyd0TYgobyuPaCiwcbo6wzGxvezame2OFZohLL4hKRmTrq0j(hLSYO)MtPePaBubAIHqpmAcA4dkd6EuOH1Od1oSfPQHbJpKXNgKfszAKlF5LYZMb2rYDI)BoVeusWSBdxgfeifCn1uGDkANc7CFNab2b62HTivnmy8Hm(0GSqktJC5lVuE2mWosUdu7aD7e)3CEjOKGz3gUmkiqk4AQPa7u0L7ab(obcSt8FZ5LGscMDB4YOGaPGRPMcStr7uyN77eiWoqTtNgM2KGM)pGzBNKPjOHp7i5oqTt8FZ5LGscA()aMTDsbxtnfyNI2bYobcSdOQC5KGM)pGzBNuf2o335o6xb1gDta9JiL(0sXNc0dNE0XSFb60NYOt8pxKcLSYOJUswz0HEfP0NUJ1pfOBLnCcWOsb4qSecC0TYaVQiYayiSr)MDoklXpixzAJGOt8pkzLrhBubAHHqpmAcA4dkd6EuOH1Oh)3CEjOKGz3gUmkiqk4AQPa7u0oq2rYDI)BoVeusqZ)hWSTtk4AQPa7u0oq2rYD6uiLBs7CAA7KWI9o2ANcWr)kO2OBcOlYkSukJE40JoM9lqN(ugDI)5IuOKvgD0vYkJU1SclLYOBLnCcWOsb4qSecC0TYaVQiYayiSr)MDoklXpixzAJGOt8pkzLrhBuXsme6HrtqdFqzq3JcnSg9onmTjLlyQftGKPjOHp7i5oqTdOQC5KYfm1Ijqc0zu2DkANIVtGa7aQkxoPCbtTycKcUMAkWofTtX3jqGDGAN4)MZlbLem72WLrbbsbxtnfyNI2bYosUdOQC5KYfm1Ijqk4AQPa7u0oqJDUVZD0VcQn6Ma6Yvf6xfOeWKa2rpC6rhZ(fOtFkJoX)CrkuYkJo6kzLr3cQc9RcSJBsa7OBLnCcWOsb4qSecC0TYaVQiYayiSr)MDoklXpixzAJGOt8pkzLrhBuPyHHqpmAcA4dkd6EuOH1OZwKQggm(qQwbfPPS(pvQj1bzGDKChO2j(V58sqjbZUnCzuqGuW1utb2Xw7inE2rYDI)BoVeusWSBdxgfeifCn1uGDkANc7eiWoX)nNxckjy2THlJccKcUMAkWoxUd8DUJ(vqTr3eqxTckstz9FQutQdYaOho9OJz)c0PpLrN4FUifkzLrhDLSYOxSvbfPzhI)tLAsDqga9RcPaOtZkFPAfuKMY6)uPMuhKbq3kB4eGrLcWHyje4OBLbEvrKbWqyJ(n7CuwIFqUY0gbrN4FuYkJo2Oc0adHEy0e0Whug09OqdRrNTivnmy8Hu20IT40Kq)s5Qq7A(KaLYvfe2rYDavLlNuUk0UMpjqPCvbbYZlbf9RGAJUjGoO5)tBxlaA0dNE0XSFb60NYOt8pxKcLSYOJUswz0LX8)PTRfan6wzdNamQuaoelHahDRmWRkImagcB0VzNJYs8dYvM2ii6e)Jswz0XgvGahdHEy0e0Whug09OqdRrhQDGAhqv5YjbZUnCzuqGuW1utb2Xw7an3jqGDI)BoVeusWSBdxgfeifCn1uGDkAhif25(osUtNcPCt26kx2F5rZ7yRDkwW35(obcSdu7a1oDkKYnzRRCz)LhnVtr7yt47CFhj3bQDavLlNem72WLrbbsbxtnfyhBTd0ANab2j(V58sqjbZUnCzuqGuW1utb2PODGuyNab2bQD6uiLBYwx5Y(lpAENI2Pa8DUVZ9DUJ(vqTr3eqpdMDkqpC6rhZ(fOtFkJoX)CrkuYkJo6kzLr)AWStb6wzdNamQuaoelHahDRmWRkImagcB0VzNJYs8dYvM2ii6e)Jswz0XgvGabdHEy0e0Whug09OqdRrp(V58sqjLAEW0ug)3CEjOKcUMAkWoxUd8DKCNonmTjfCuwddauMGj98usMMGg(SJK7aD70PHPnjO5)dy22jzAcA4ZosUdu7WwKQggm(qQwbfPPS(pvQj1bzGDKChO2bMGdw(YLxknEivRGI0uw)Nk1K6GmWobcSdu70cnvwUjJ)BoVeusbxtnfyhBTtX3rYDAHMkl3KX)nNxckPGRPMcStr7anGVZ9DUVtGa7aD7WwKQggm(qQwbfPPS(pvQj1bzGDUJ(vqTr3eqhm72WLrbb0dNE0XSFb60NYOt8pxKcLSYOJUswz0Lj72W7CtqaDRSHtagvkahILqGJUvg4vfrgadHn63SZrzj(b5ktBeeDI)rjRm6yJkqkGHqpmAcA4dkd6EuOH1Oh)3CEjOKsnpyAkJ)BoVeusbxtnfyNl3b(osUtNgM2KGM8Wa9lQKmnbn8zhj3bQDYyRdYLmLRAgyhBTdKDUJ(vqTr3eqhm72WLrbb0dNE0XSFb60NYOt8pxKcLSYOJUswz0Lj72W7CtqyhOGChDRSHtagvkahILqGJUvg4vfrgadHn63SZrzj(b5ktBeeDI)rjRm6yJkqkogc9WOjOHpOmO7rHgwJE8FZ5LGsk18GPPm(V58sqjfCn1uGDUCh47i5oGQYLtEeP0Nwk(uqQcBhj3bQDI)BoVeusqZ)N2Uwa0KcUMAkWoxUd8Dceyhqv5YjzQiLYKcUMAkWo2AN4)MZlbLe08)PTRfanPGRPMcSZD0VcQn6Ma6Gz3gUmkiGE40JoM9lqN(ugDI)5IuOKvgD0vYkJUmz3gENBcc7avH7OBLnCcWOsb4qSecC0TYaVQiYayiSr)MDoklXpixzAJGOt8pkzLrhBubInXqOhgnbn8bLbDpk0WA0HAN4)MZlbLuQ5bttz8FZ5LGsk4AQPa7C5oW3jqGDI)BoVeusPMhmnLX)nNxckPGRPMcStrxUdCsBUJK7atWblLgpKqifzfwkL35(osUdu7e)3CEjOKGM)pGzBNuW1utb25YDGVtGa7aQkxojO5)dy22jvHTtGa7aD70PHPnjO5)dy22jzAcA4ZobcSdu70Pqk3KTUYL9xE08ofTdKc7CFN77i5oqTdBrQAyW4dPAfuKMY6)uPMuhKb2rYDGAhycoy5lxEP04HuTckstz9FQutQdYa7eiWoqTtl0uz5Mm(V58sqjfCn1uGDS1ofFhj3PfAQSCtg)3CEjOKcUMAkWofTd0a(o335(obcSd0TdBrQAyW4dPAfuKMY6)uPMuhKb25o6xb1gDtaDWSBdxgfeqpC6rhZ(fOtFkJoX)CrkuYkJo6kzLrxMSBdVZnbHDGQ43r3kB4eGrLcWHyje4OBLbEvrKbWqyJ(n7CuwIFqUY0gbrN4FuYkJo2OceOjgc9WOjOHpOmORKvgDRAQ0DE57C7nMeMMkDhlO2Qcga9WPhDm7xGo9Pm6xb1gDtaDHMkT8LxgFJjHbOPslLR2QcgaDRmWRkImagcB0TYgobyuPaCiwcbo6EuOH1OdQkxojy2THlJccKQW2rYDavLlNKPIuktQcBhj3b62buvUCYMRW6S1pLufg2OceOfgc9WOjOHpOmO7rHgwJoOQC5KGz3gUmkiqQcBNab2bQD6uiLBYwx5Y(lpAENI2bIn35(obcSdu7e)3CEjOKGz3gUmkiqk4AQPa7u0of2rYDGj4GLsJhsiKISclLY7Ch9RGAJUjGoO5)dy22rpC6rhZ(fOtFkJoX)CrkuYkJo6kzLrxgZ)hWSTJUv2WjaJkfGdXsiWr3kd8QIidGHWg9B25OSe)GCLPncIoX)OKvgDSrfiwIHqpmAcA4dkd6EuOH1OdQkxojy2THlJccKQWq)kO2OBcOdA()ukxvqa9WPhDm7xGo9Pm6e)ZfPqjRm6ORKvgDzm)F2XcQccOBLnCcWOsb4qSecC0TYaVQiYayiSr)MDoklXpixzAJGOt8pkzLrhBubsXcdHEy0e0Whug09OqdRrhQDavLlNem72WLrbbsvy7i5oqTdOQC5KzWStbPkSDceyhOBNonmTjZGzNcsMMGg(SZ9DUVtGa7a1oGQYLtcMDB4YOGaPkSDKCNofs5MS1vUS)YJM3PODSj8DUJ(vqTr3eqhKfaSqwnvk6Htp6y2VaD6tz0j(NlsHswz0rxjRm6YWcawiRMkfDRSHtagvkahILqGJUvg4vfrgadHn63SZrzj(b5ktBeeDI)rjRm6yJkqGgyi0dJMGg(GYGUhfAyn6IuktgvfcM27u0oIuktwtO)oqB2XMWr)kO2OBcONIys5Y(fcM2Oho9OJz)c0PpLrN4FUifkzLrhDLSYOFvetkVtOxiyAJUv2WjaJkfGdXsiWr3kd8QIidGHWg9B25OSe)GCLPncIoX)OKvgDSrLcWXqOhgnbn8bLbDpk0WA0bvLlNem72WLrbbsvy7i5ozS1b5sMYvndSZL7ab9RGAJUjGUqLwMXw)0sJgOrpC6rhZ(fOtFkJoX)CrkuYkJo6kzLr3QkDNRXw)0DkgnqVduqUJ(vHua0PzLV0gUUEBhlOkiy7DI)BoVeuaBGUv2WjaJkfGdXsiWr3kd8QIidGHWg9B25OSe)GCLPncIoX)OKvgDxxVTJfufeS9oX)nNxcka2Osbiyi0dJMGg(GYGUhfAyn6DkKYnPDonTDsyXEhBTtb47i5oqTtgBDqUKPCvZa7C5ofFNab2jJToixYuUQzGDUChBUZD0VcQn6Ma6cvAzgB9tlnAGg9WPhDm7xGo9Pm6e)ZfPqjRm6ORKvgDRQ0DUgB9t3Py0a9oqv4o6xfsbqNMv(sB466TDSGQGGT3PTlyENofs5gWgOBLnCcWOsb4qSecC0TYaVQiYayiSr)MDoklXpixzAJGOt8pkzLr311B7ybvbbBVtBxW8oDkKYna2OsHcyi0dJMGg(GYGUhfAyn6zS1b5sMYvndSJT2XMOFfuB0nb0fQ0Ym26NwA0an6Htp6y2VaD6tz0j(NlsHswz0rxjRm6wvP7Cn26NUtXOb6DGQ43r)Qqka60SYxAdxxVTJfufeS9oxHEcZgOBLnCcWOsb4qSecC0TYaVQiYayiSr)MDoklXpixzAJGOt8pkzLr311B7ybvbbBVZvONWWgvkuCme6HrtqdFqzq3JcnSg9ofs5M0oNM2ojSyVtr7uao6xb1gDtaDHkTmJT(PLgnqJE40JoM9lqN(ugDI)5IuOKvgD0vYkJUvv6oxJT(P7umAGEhOS5D0VkKcGonR8L2W11B7ybvbbBVdd95OAZ2aDRSHtagvkahILqGJUvg4vfrgadHn63SZrzj(b5ktBeeDI)rjRm6UUEBhlOkiy7DyOphvBgBuPGnXqOhgnbn8bLbDpk0WA07uiLBs7CAA7KWI9o2ANcWr)kO2OBcOluPLzS1pT0ObA0dNE0XSFb60NYOt8pxKcLSYOJUswz0TQs35AS1pDNIrd07af08o6xfsbqNMv(sB466TDSGQGGT3bqtLA4D6uiLBBGUv2WjaJkfGdXsiWr3kd8QIidGHWg9B25OSe)GCLPncIoX)OKvgDxxVTJfufeS9oaAQudVtNcPCJn2Od9YYtvtJYGnIa]] )

    storeDefault( [[SimC Fury: precombat]], 'actionLists', 20171203.205647, [[b4vmErLxt5uyTvMxtnvATnKFGzuDYLNo(bgCYv2yV1MyHrNxtnfCLnwAHXwA6fgDP9MBE50nY41usvgBLf2CL5LtYatm3eJmWmJlXydn0aJnEn1uJjxAWrNxt51ubngDP9MBZ5fvE5umErLxtvKBHjgBLrMxc51ubjwASLgD551uW9gDP9MBEnvsUrwAJfgDVjNxt52BUvMxt10BKzvyY5uyTvMxt51uofwBL51uq9gDP9MBEnvqYD2CEnLBH1wz9iYBSr2x3fMCI41usvgBLf2CL5LtYatm3edmEnLuLn3B1j3yLnNxu5fDEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxt9gBK91DHjNx05fDEnfrLzwy1XgDEjKx05Lx]] )

    storeDefault( [[SimC Fury: cooldowns]], 'actionLists', 20171203.205647, [[dae4laqisH2eQQ(KsLKrjO6ukvSlsmmL4yKQLrsEgkuMgPGRHcvTnuQY3uQACkvkoNsLQwNsLsZdfs3dfI2hkvoikYcfKhIQYerHWfrPSruQQtII6MkLDQk)uPsQLQQ8uIPIsUQsLOTsk1xvQe2R0FfWGPYHfTyf9yinzfUmyZQQ(SsA0OkNMIxJcMnvDBi2nu)gPHtsTCepxOPRY1rLTtk57KIgpku58c06vQuz(ck7Nsx9YQYlrGkIbHpRJ95ib3TwhkL6hunXXkIAa1KEZUlpdf33Evv(apKrOpvl671vTWyk6SNg0Wc7vrqjg1xLkmHEgkoww9PxwvydNtpmAOkckXO(Qm5()vqYymrjGcNARJFRBY9)RaysUckeajn4O1XOwNEfMMgV5cwHKiQZvOcZ4HbnpkPcMIHkB0H2j5LiqLkVebQ8LiQZvOYh4Hmc9PArFV(sLpis5iOqSS6vHpEakdBuTaeaFDwzJoEjcuPxFQkRkSHZPhgnufbLyuFvUKScNcpi9hpf1ON1XOwNQfRJFRBY9)RaysUckeajn4O1XOwNEfMMgV5cwz6P0XXZqIxfMXddAEusfmfdv2OdTtYlrGkvEjcujKNshhpdjEv(apKrOpvl671xQ8brkhbfILvVk8XdqzyJQfGa4RZkB0XlrGk96JXkRkSHZPhgnufMMgV5cwbyCak3bvygpmO5rjvWumuzJo0ojVebQu5Liqf2yCak3bv(apKrOpvl671xQ8brkhbfILvVk8XdqzyJQfGa4RZkB0XlrGk96tdLvf2W50dJgQYlrGkmcsYTY7So6V1juoFScZ4HbnpkPcMIHkmnnEZfSYGKCR8Ua0)arkNpw5dIuockelREv(apKrOpvl671xQiOeJ6RYK7)xzM35HaOKGkeajn4O1XoRtL1XV1n5()vamjxbfcGKgC06yN1PY6436c36c36U0d4tzqYvkoaHMefaNtpmSo(TUj3)VYGKRuCacnjkeajn4O1XogP1Xyw3owxyHzDA06U0d4tzqYvkoaHMefaNtpmSUD61hJVSQWgoNEy0qvEjcuzxgbRJ5dqIvygpmO5rjvWumuHPPXBUGv4IqaZbiXkFqKYrqHyz1RYh4Hmc9PArFV(sfbLyuFv61h7vwvydNtpmAOkckXO(QCPhWNIbJbsasUckaoNEyyD8BDtU)FfatYvqHtDfMMgV5cwHKRg8AGPNQzfMXddAEusfmfdv2OdTtYlrGkvEjcu5lxn4vRlKNQzLpWdze6t1I(E9LkFqKYrqHyz1RcF8aug2OAbia(6SYgD8seOsV(2xwvydNtpmAOkckXO(QeU1rYvqbLJqa8zDSJrAD6llwh)w3LEaFk)e6XZGxdmbseimaefaNtpmSo(TonADr4cmPyUOYzaIk9aAqnQ1XoRBX62X6clmRlcxGjfZfvodquPhqdQrTo2zDlwxyHzDA06U0d4t5NqpEg8AGjqIaHbGOa4C6HrfMMgV5cwHKiQZvOcZ4HbnpkPcMIHkB0H2j5LiqLkVebQ8LiQZvW6cxFNkFGhYi0NQf996lv(GiLJGcXYQxf(4bOmSr1cqa81zLn64LiqLE9TBkRkSHZPhgnufbLyuFvMC))kaMKRGcNARJFRlCRdLs9dQMyfsUAWRbMEQMkeajn4O1XoRBX6clmRtJw3LEaFkgmgibi5kOa4C6HH1TtfMMgV5cwHocIJb(5ibRWmEyqZJsQGPyOYgDODsEjcuPYlrGk76rq8UkADSphjyLpWdze6t1I(E9LkFqKYrqHyz1RcF8aug2OAbia(6SYgD8seOsV(29Lvf2W50dJgQIGsmQVkx6b8Pq5UjhjEkaoNEyyD8BDtU)FfatYvqzq1eBD8BDtU)FLzENhcGscQWPUcttJ3CbRmbseimaKaKCfQWmEyqZJsQGPyOYgDODsEjcuPYlrGkHaseimaeR7lxHkFGhYi0NQf996lv(GiLJGcXYQxf(4bOmSr1cqa81zLn64LiqLE9PVuwvydNtpmAOkckXO(QeU1n5()vamjxbfcGKgC06yuRt364360O1DPhWNcL7MCK4Pa4C6HH1TJ1fwywNgTUl9a(umymqcqYvqbW50dJkmnnEZfSY0tPJJNHeVkmJhg08OKkykgQSrhANKxIavQ8seOsipLooEgs8SUW13PYh4Hmc9PArFV(sLpis5iOqSS6vHpEakdBuTaeaFDwzJoEjcuPxF66Lvf2W50dJgQIGsmQVktU)Ffnjakdg8AGz69kCQTo(TUj3)VcGj5kOWPUcttJ3CbROjpdXRPbpQWmEyqZJsQGPyOYgDODsEjcuPYlrGk7cEgIxtdEu5d8qgH(uTOVxFPYhePCeuiww9QWhpaLHnQwacGVoRSrhVebQ0RpDvLvf2W50dJgQcttJ3CbRqYvdEnW0t1ScZ4HbnpkPcMIHkB0H2j5LiqLkVebQ8LRg8Q1fYt106cxFNkFGhYi0NQf996lv(GiLJGcXYQxf(4bOmSr1cqa81zLn64LiqLE9PZyLvf2W50dJgQcttJ3CbRm9u644ziXRcZ4HbnpkPcMIHkB0H2j5LiqLkVebQeYtPJJNHepRlCv7u5d8qgH(uTOVxFPYhePCeuiww9QWhpaLHnQwacGVoRSrhVebQ0RpDnuwvydNtpmAOkmnnEZfSYphXq5IbI(mYRcZ4HbnpkPcMIHkB0H2j5LiqLkVebQW(CedLlADIpJ8Q8bEiJqFQw03RVu5dIuockelREv4JhGYWgvlabWxNv2OJxIav61RcJa(to)1q9Ab]] )

    storeDefault( [[SimC Fury: movement]], 'actionLists', 20171203.205647, [[b4vmErLxt5uyTvMxtnvATnKFGzuDYLNo(bwBVzxzTvMB051utbxzJLwySLMEHrxAV5MxoDJmEnLuLXwzHnxzE5KmWeZnXidmZ4sm2qdnWyJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEnvqILgBPrxEEnfALj3BPn2xSvwyW51uj5gzPnwy09MCEnLBV5wzEnvtVrMvHjNtH1wzEnLxt5uyTvMxtHuzY9wAJ5hymvwyW51usvgBLf2CL5LtYatm3edmEnLuLn3B1j3yLnNxu5fDEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxt5fDErNxtruzMfwDSrNxc5fDE5f]] )

    storeDefault( [[SimC Fury: AOE]], 'actionLists', 20171203.205647, [[dWdffaGEjf1Muu1UKKTreSpsvmBjMpr0nfX3ue3wupwP2Pc7LA3e2VQ8tjfzyc1Vr5WsDEOObRsdNO6qKQItjPQJrkNJuv1cjvwku1Ivvlhvpuf1trwgrzDKQutKuvAQqLjly6qUiu40KCzW1fPnkPqBLizZqPTlKEUs(QKsnnIqFxiEMKs(SIYOvH5jPGtsKAusQCnsvY9ivv(RIkVwf5GksBnJZ0OZGjsLp)U1ykht9(DNwtyyIKdBvxu1CJumHhtKzcpuGEbEilwBIMS4AvPjbjkXyjyI2CLCKjtt3iftSmop0motyi6FbcwNjAZvYrM(PyXwbcEpdQcSiI3vsjFxEpdQ2PCoiqVBn8U6FSPPFvrHW00VWyb0HIVqMKweu7gX4MembykHfKQ5JodMmn6mysxHXcOdfFHmHhkqVapKfRnrl2eEyXs5ByzCgz68bSpLWIczqG83uclm6myYipKzCMWq0)ceSot0MRKJm9tXITce8EguXHCReR3vpVRS3D(3TU3T3ivuyoqazfSEx98UAVB9MM(vffctt)shGfIXZMKweu7gX4MembykHfKQ5JodMmn6mysxPdWcX4zt4Hc0lWdzXAt0InHhwSu(gwgNrMoFa7tjSOqgei)nLWcJodMmYJAzCMWq0)ceSot0MRKJm9tXITkdnAUDb6OaVkWIimn9RkkeMMICO4LikrWK0IGA3ig3KGjatjSGunF0zWKPrNbt1(qXlruIGj8qb6f4HSyTjAXMWdlwkFdlJZitNpG9PewuidcK)MsyHrNbtg5Henotyi6FbcwNjAZvYrM(PyXwLHgn3UaDuGxLk)DN)DR7D)PyXwbcEpdQcSiI3D(3vFExuxabQclNHouIzZ9b(c4NaEfi6FbcVRKs(U)uSyRY9A1BouLk)DLuY3L3ZGQDkNdc07Qh97D1IJF36nn9RkkeMM4DwEpdmjTiO2nIXnjycWuclivZhDgmzA0zWe(olVNbMWdfOxGhYI1MOfBcpSyP8nSmoJmD(a2NsyrHmiq(BkHfgDgmzKh6LXzcdr)lqW6mn9RkkeMM(fglGou8fYK0IGA3ig3KGjatjSGunF0zWKPrNbt6kmwaDO4l07wNw9MWdfOxGhYI1MOfBcpSyP8nSmoJmD(a2NsyrHmiq(BkHfgDgmzKhsW4mHHO)fiyDMM(vffcttrou8seLiysArqTBeJBsWeGPewqQMp6myY0OZGPAFO4Likr4DRtREt4Hc0lWdzXAt0InHhwSu(gwgNrMoFa7tjSOqgei)nLWcJodMmYit6lGTtliRZiBa]] )

    storeDefault( [[SimC Fury: execute]], 'actionLists', 20171203.205647, [[d8dVhaGAuG1RIOnrIQDPsTnve2hjs52k65KA2kz(cfUPqUm4BsfNhLANszVu7MW(rv)KernmPQXrIGtl4Xk1GrLHlsoOQItPI0XiPZrIsluOAPQWIvLLt0dvr9uOLrcRJejMijs1uvjtwHPJ4IsLEnkPNrIIRlQnQQKTIIAZIy7OettOuZtOOpls9DHs8xuOdlz0QQgVQsDsuKdjusxJeHUhjs6tKiYVrAuOG2Q(YyRMGrmmpZZ9vwYwPWZbFd7mbmIPGDOwHtwKav4whfgpGfuAWnf9QDuv0Rm3QNi2XU)egXTmKIy04NnjqfAF5MQVm2vuVfmCCJ4wgsrm(Yjj3jzgeGrPzmjlzFNtXZPCEUxoj5ojZGamknJjzj7BjmRGqZZftEofg)8cRaHTX3IshK)GutmYKye2fHknkOcWyeDWCjB1emASvtWy8fLoi)bPMy8awqPb3u0R2rT34bOPz5g0(YeJN)HnRruwGjii(zmIoA1emAIBk8LXUI6TGHJBe3YqkIXsscj1MCZGC60GuuzYniQ3cg8CkNNJH8CXkp3lNKCZGC60GuuzYDofpxmIbp3lNKCZGC60GuuzYTeMvqO55IjpNcEUt55Irm45E5KKBnHkag)HssUZPm(5fwbcBJW3WotaJmjgHDrOsJcQamgrhmxYwnbJgB1em29ByNjGXdybLgCtrVAh1EJhGMMLBq7ltmE(h2SgrzbMGG4NXi6OvtWOjUPm(Yyxr9wWWXnIBzifXiPwGGCNibXjzFdI6TGbpNY55E5KK7ejioj7BjmRGqZZftLkpNcJFEHvGW2yswgOznJ6vP)nYKye2fHknkOcWyeDWCjB1emASvtW4xzzGM18C4Q0)gpGfuAWnf9QDu7nEaAAwUbTVmX45FyZAeLfyccIFgJOJwnbJM4wS9LXUI6TGHJBe3YqkIXxoj5EwADTLWDofpNY55E5KKBqiR0WTeMvqO55IjpNQXpVWkqyBuwZuvAWitIryxeQ0OGkaJr0bZLSvtWOXwnbJh1mvLgmEalO0GBk6v7O2B8a00SCdAFzIXZ)WM1iklWeee)mgrhTAcgnXnLOVm2vuVfmCCJFEHvGW2i8nSZeWitIryxeQ0OGkaJr0bZLSvtWOXwnbJD)g2zcWZXq1tnEalO0GBk6v7O2B8a00SCdAFzIXZ)WM1iklWeee)mgrhTAcgnXTt4lJDf1Bbdh34NxyfiSnshSfAgtYs2gzsmc7IqLgfubymIoyUKTAcgn2QjyujpylusAEUVYs2gpGfuAWnf9QDu7nEaAAwUbTVmX45FyZAeLfyccIFgJOJwnbJM4whFzSROEly44g)8cRaHTX3IshK)GutmYKye2fHknkOcWyeDWCjB1emASvtWy8fLoi)bPMWZXq1tnEalO0GBk6v7O2B8a00SCdAFzIXZ)WM1iklWeee)mgrhTAcgnXnLGVm2vuVfmCCJ4wgsrmQbcJpQiRVjbqQQSmQi1MNtPXZ1B8ZlSce2gtYYanRzuVk9VrMeJWUiuPrbvagJOdMlzRMGrJTAcg)kld0SMNdxL(NNJHQNA8awqPb3u0R2rT34bOPz5g0(YeJN)HnRruwGjii(zmIoA1emAIBkRVm2vuVfmCCJFEHvGW2OSshePz8TOXIrMeJWUiuPrbvagJOdMlzRMGrJTAcgpQ0brAEU4lASy8awqPb3u0R2rT34bOPz5g0(YeJN)HnRruwGjii(zmIoA1emAIBQ9(Yyxr9wWWXn(5fwbcBJjzzGM1mQxL(3itIryxeQ0OGkaJr0bZLSvtWOXwnbJFLLbAwZZHRs)ZZXqfNA8awqPb3u0R2rT34bOPz5g0(YeJN)HnRruwGjii(zmIoA1emAIjgv6qsLxeh3eBa]] )


    storeDefault( [[Fury Primary]], 'displays', 20171203.205647, [[dSdTgaGEPuVejPDHkQ2gaLzsvYSv4MijEmsDBPQdlzNuAVIDt0(PI(PIAya63qUguvnuuAWufdhrhuQCzqhtkooQWcPQwkvWIj0Yj1dLsEQQLbG1bq1ebiMkuMmQ00v6IkYvrf5zqvPRd0grITcqQntW2rOpsf6BqvXNHkFNknsKunnKugnkgpuLtIGBHkkNMKZJQEofRfGKxtvQttWYPlYvHKuqY9l)aMpZjmViyNYPlYvHKuqY9Q2WyBaixxsCWwmqAVJFU4q1UTJdKBeZ5NfemWTvrUkK0elWC8MfemWTvrUkK0elWCoaHGqUeOrYRAdJf)aZ7vYUPyX3CoaHGqUTkYvHKM4NZpliyGlwPXbxtSaZnmi37QwAMUP4NByqUDGlk(5kAK8KfTsIlwQLVLghC7K0miDU)mg2mvCGGJuhlhVzbbdCPQVj2MC8IfyUHb5IvACW1e)CVf7K0miDo2mRdeCK6y5kjxfDTiDNKMbPZDGGJuhlNUixfs2jPzq6C)zmSzQKFsiTQgQ21QqYyXhaYnmi3Jf)CoaHGqarPH0RcjZDGGJuhlxc2tGgjnXsTCdjCmOmkdtl0aPdwEfBtUo2MCCX2KlgBt2CddYTvrUkK0eXC8MfemWTduxXcmVa1fgpjmxeuqiVVWRdCrXcmxCOA32XbYTBmIyEnizQZGCzjofBtEnizQwOEXAzjofBtoGafkWXg)8A4w8gwISXpNOYOevd1YJXtcZfZPlYvHKDdfozERjl2Kd5CvgYrXJXtcZRCDjXbX4jH5LOAOw(8cuxurjHXp3Brki5EvBySnaKxdsMcR04Gllr2yBY1WrERjl2Kd5gs4yqzugMiMxdsMcR04GllXPyBY5aecc5sqYvrxlsBIFUT6H5ua18o9WQv9LMpFlno4sbj3V8dy(mNW8IGDkVxj7axuSaZ9wKcsUF5hW8zoH5fb7uUasU5Syo98sAC6XwAnYnVgKmv3WT4nSezJTjNpwodaaWFoPw1xAEki5EvBySnaKtQH0OEXA7y9k)Q(wo9qbuZd4o9qQH0OEXAZv0ijGcH6JTb)59fEDtXcmVVW7yX2KVLghCzjofXCsTQV08eOrYRAdJf)aZDaoGLbglaaBWNgaaIVCEdGrnQbeWY5aecc7gkCYEOCZPZXBwqWaxcsUk6ArAtSaZ5NfemWLGKRIUwK2elW8T04GlfKCZzXC65L040JT0AKBoEZccg4IvACW1elWCddYLGKRIUwK2e)CddYTduxeKcOiMxd3I3WsCk(5ggKllXP4NByqUDtXpNg1lwllr2iMxG6QtsZG05(ZyyZuXRjky5fOUojCmiaiXcmNdqfT3aAL5l)aMx59k5XIfy(wACWLcsUx1ggBda5fOUiifqy8KWCrqbHC6ICvijfKCZzXC65L040JT0AKBEnizQwOEXAzjYgBt(KSehqUXp3O6jhWU5PybiNFwqWa3oqDflWCVfPGKBolMtpVKgNESLwJCZRbjt1nClEdlXPyBY3sJdUSezJyonQxSwwItrm3WGCPkKxuj5QK4mXp3WGCzjYg)CddY9UQLMPdCrXpVgKm1zqUSezJTjNdqiiKlfKCVQnm2gaY5NfemWLQ(My5SMCoaHGqUu13e)CUqHcCSDSELFvFlNEOaQ5bCNE4cfkWXMxG6Its1MtokEOoBca]] )

    storeDefault( [[Fury AOE]], 'displays', 20171203.205647, [[dSdSgaGEPuVeQQ2LuG2MuaZukYSv4MiPCyj3wr9nPqTtkTxXUjA)uHFkvnma(nKNbvfdfvgmv0Wr0bPQ(mu5yuPJJQyHkYsrvAXi1YP4Hsjpv1JrX6aKAIsHmvOmzuvtxPlkvUkssxg01bAJiyRasSzc2oc9rPOonjttkOVtvgjsILbvz0O04buNejUfuv6AiP68e65KATas61aIJBWYzkYvHKeqY9R4aM3tvSMOy7Y3YGdUCe5cDUPK4GTyHmajt58acbH(dfo5muU5m5I9ccA42QixfsQJfqoW9ccA42QixfsQJfqoPrnxgrkmi5vTHXsDa5ZkPFxS4topGqqi)wf5QqsDMYf7fe0WfRm4GRowa5AwK39uldRFxOZ1SipFWff6CnlY7EQLH1hCrzkFldo46lzyrM8PEmSEQXlLMPcwoW9ccA4I)jDSU5ci5MZH5W5lP2HtBzmiVCnlYdRm4GRot5aH2xYWIm5y9C8sPzQGLRK8vm1Im(sgwKjNxkntfSCMICviPVKHfzYN6XW6Pw(jHmQAOAxRcjJTX4LRzrEhlt58acbHnszGmRcjZ5LsZublxcotHbj1X2WCnjCmimknBl0azcwEfRBoDSU54I1n3eRB2CnlYRvrUkKuh6CG7fe0W1h0uXciVanfMijmNguqiFUa2hCrXciNEOA3U5bYZFmcDEnizRZI84i2fRBEnizRwOz6A5i2fRBEJGcf4yZuEn8krnhrUmLtuPv0QHAfXejH505mf5Qqs)HcNmVvNfRJ3C(kn5OeXejH5m5MsIdIjscZlA1qTI5fOPOMscZuoqOjGK7vTHX6IxEnizlSYGdUCe5I1n3ah5T6SyD8MRjHJbHrPzdDEnizlSYGdUCe7I1nNhqiiKpfjFftTiJot52AgMta0i6WPFFx(wgCWLasUFfhW8EQI1efBxoFOqbowFUMYVAULdNeanIaTdN8Hcf4yZbcnbKC)koG59ufRjk2UCGJfqEnizl)HxjQ5iYfRBUyS4RBJbKtAuZLrKasUx1ggRlE5KgidAMUwFUMYVAULdNeanIaTdNKgidAMU28AqYwNf5XrKlw385cy)UybKpxaFSyDZ3YGdUCe7cDoVWbS0WyXdGBJDXda(0GUnqdBiGgixZI84iYLPCnlYd)qrALKVsItNPCg0mDTCe7cDotrUkKKasUx1ggRlE51GKT8hELOMJyxSU5aHMasU5CyoC(sQD40wgdYlxZI8Oi5RyQfz0zkxSxqqdxFqtflG8A4vIAoIDzkxZI887cDUMf5XrSlt5mOz6A5iYf68c0u(sgwKjFQhdRNAn1ralVgKSvl0mDTCe5I1nNhqfdqakk9xXbmNoFwjpwSaY3YGdUeqY9Q2WyDXlVanffPactKeMtdkiKZuKRcjjGKBohMdNVKAhoTLXG8YlqtDs4yqPrXciVtw0di)mLRvZKdOFFxS4LRzrE(GMIIuaf6CG7fe0WfRm4GRowa5BzWbxci5MZH5W5lP2HtBzmiVCXEbbnCPi5RyQfz0Xcih4EbbnCPi5RyQfz0XciNEOA3U5bYl058acbH8PWGKx1ggl1bKRyqYtwmkjUyPEUIbjbQi0CSUupNhqiiKpbKCVQnmwx8Yf7fe0Wf)t6yXx3CEaHGq(4FsNP8zL0hCrXciVanfvLQnNCuIqt2ea]] )

    storeDefault( [[Arms Primary]], 'displays', 20171203.205647, [[dSdTgaGEPQEjuQ2fGK2gukntPsMTc3eLKhJu3wkDyj7Ks7vSBc7Nk5NkQHbWVHCnucdfjdMk1Wr0bjvxg0XOQookLfkflfLQftklNIhkv5PQwgGADsfyIsfAQanzuLPR0fvKRIs0ZKkQRJWgrvTvPcAZOY2HkFuQuFgkMMur(ovzKOK6BasnAumEOKtcvDlOuCAIopv8CswlGeVgqC8dyoDrUsKGpsSFDgW8zwc2fE7uoDrUsKGpsSx2hgRpW5MsGb2JbsdK0KRnK9739a5fTCNzoofC7vKRejuXcihRzoofC7vKRejuXciNncibKhEAK4Y(WyzbG8wPqFk2oNZgbKaYRxrUsKqLMCNzoofCbldg4QIfqUIb5Dp5sZOpLMCfdYtNyrPjxsJeNSOLcmXYI8TmyGRUGMbzYBMbbNzf747M1G5ynZXPGl2BuX6NJvSaYvmipWYGbUQ0KdenDbndYKdotXo(UznyUuWtsxlYOlOzqMC2X3nRbZPlYvIe6cAgKjVzgeCMv5NeslRHSFTsKiwG2pxXG8oyAYzJasa7O0aPxjsKZo(UznyUGOfpnsOITt5ks4yWFukMEObYeW8kw)CtS(5yI1pxlw)S5kgKxVICLiHkA5ynZXPGRoHPIfqErykqhsyUgbhxEBHLoXIIfqU2q2VF3dKN(yeT8AqYuNb5rHBkw)8AqYu9qTA1sHBkw)8oc5kIXMM8A4vokkCuPjhNuj1Kd56a6qcZ1YPlYvIe6djgrEVjl4e758KkYr5a6qcZRCtjWabDiH5LMCixN8IWuSskGPjhiA8rI9Y(Wy9boVgKmfyzWaxkCuX6NBGJ8EtwWj2ZvKWXG)OumrlVgKmfyzWaxkCtX6NZgbKaYdVGNKUwKrLMCB1cZ1nTkxUPmY2Y4KVLbdC5Je7xNbmFMLGDH3oL3kf6elkwa5arJpsSFDgW8zwc2fE7uohsS5uGUC)sOC52wgdYlVgKmL(WRCuu4OI1p3jwSb4odiN0iBlJdFKyVSpmwFGZjnqAuRwT6uDLFzBpxU1nTQoWLBsdKg1QvBUKgjakiuBS(SiVTWsFkwa5Tfwhmw)8TmyGlfUPOLtAKTLXbpnsCzFySSaqo7WbSuWybgGpq7dmGodu9X2o1jayBoBeqcO(qIr0cfBoDowZCCk4IxWtsxlYOIfqUZmhNcU4f8K01ImQybKVLbdC5JeBofOl3VekxUTLXG8YXAMJtbxWYGbUQybKRyqE4f8K01ImQ0KRyqE6eMcVGdfT8A4vokkCtPjxXG8OWnLMCfdYtFkn50OwTAPWrfT8IWu6cAgKjVzgeCMvDnXhmVim1jHJb(oglGC2iK0aPdLQVodyEL3kfhmwa5BzWax(iXEzFyS(aNxeMcVGdb6qcZ1i44YPlYvIe8rInNc0L7xcLl32YyqE51GKP6HA1QLchvS(5tIsBa5LMCLSLCa1NNIf4CNzoofC1jmvSaYbIgFKyZPaD5(Lq5YTTmgKxEnizk9Hx5OOWnfRF(wgmWLchv0YPrTA1sHBkA5kgKh2HoAsbpPaJkn5kgKhfoQ0KRyqE3tU0m6elkn51GKPodYJchvS(5SrajG84Je7L9HX6dCUZmhNcUyVrfl24NZgbKaYd7nQ0KZdYveJvNQR8lB75YTUPv1bUCZdYveJnVimflfYnNCuoqt2ea]] )

    storeDefault( [[Arms AOE]], 'displays', 20171203.205647, [[dStSgaGEPuVeLWUKc02KcyMsrnBfUjkjpgj3wQCyj7KI9k2nH9tL8tfzya8BixdLOHIkdMk1Wr0bjPld6yuXXrPSqf1srPAXi1YP0dLsEQQLbOwhukMOuitfOjtctxPlkvDvus9mOu66iSrs0wbK0MrvBhQ8raXNHIPjfQVtvgjuQ(MuqJgfJhk5Kqv3cqQttQZtv9CIwlGeVwkYXjG5uf5QrcLiX(1FaZNynyZ4n95uf5QrcLiXEDBymoaNBlbgylgivtzoNEOB3gidKxOZ9N45LWTvrUAKqgdGCSM45LWTvrUAKqgdGC2iGeqf4PqIRBdJHLaY70c1(yW2C2iGeqfTkYvJeYmN7pXZlHlyzXaxzmaYLmiV7Pxkg1(qNlzqEQelk05AkK4KfLwGjgwMVLfdCvfumiB(8ei4eRyhpqWoyowt88s4YIzzmo5yfdWaYLmipWYIbUYmN3eTQGIbzZbN4yhpqWoyUwOqtvlYQkOyq2C2XdeSdMtvKRgjufumiB(8ei4eRYpjKsxdD7A1irmn0jxYG8oyMZzJasaBK2cPwnsKZoEGGDWCbrhEkKqgtJZLKWXq5OKmTqdKnG5vmo52yCYXeJtoDmozZLmiVwf5QrczOZXAINxcxvcBfdG8IWwG(KWCAcE(8UclvIffdGC6HUDBGmqEQJrOZRbjtDgKhhU(yCYRbjt1c1rxlhU(yCYBeKVigBMZRHx5l5WXL5CCAPMwp0RpOpjmNoNQixnsOo0ye5T6nG9SNRqljhLpOpjmNk3wcmqqFsyErRh61pViSfR0cyMZBIwjsSx3ggJdW51GKPallg4YHJlgNClCK3Q3a2ZEUKeogkhLKj051GKPallg4YHRpgNC2iGeqf4fk0u1ISYmNBQoyUQTt6YT6uF(wwmWvjsSF9hW8jwd2mEtFENwOsSOyaK3eTsKy)6pG5tSgSz8M(CEKyZ5aD5(Lq6YTPSwKxEnizk1Hx5l5WXfJtUFmaTtdbKtA1DL1xjsSx3ggJdW5KwifQJUwvUMZVURLl3Q2oj24YnPfsH6ORnxtHeafeQlghwM3vyP2hdG8UcRdgJt(wwmWLdxFOZjT6UY6JNcjUUnmgwciND4awsymadWPHoadaBBqNgOXngqdKZgbKaQo0yeDqXMtLJ1epVeU4fk0u1ISYyaK7pXZlHlEHcnvTiRmga5BzXaxLiXMZb6Y9lH0LBtzTiVCSM45LWfSSyGRmga5sgKhEHcnvTiRmZ5sgKNkHTWl4rHoVgELVKdxFMZLmipoC9zoxYG8u7dDofQJUwoCCHoViSLQGIbzZNNabNyvZ9kbZlcBDs4yGVrXaiNncnvtavT8R)aMtN3Pfhmga5BzXaxLiXEDBymoaNxe2cVGhb6tcZPj45ZPkYvJekrInNd0L7xcPl3MYArE51GKPAH6ORLdhxmo59IIEavK5CPUJCavN6Jb4C)jEEjCvjSvmaYBIwjsS5CGUC)siD52uwlYlVgKmL6WR8LC46JXjFllg4YHJl05uOo6A5W1h6CjdYJfqFATqHwGrM5CjdYJdhxMZLmiV7PxkgvIfL58AqYuNb5XHJlgNC2iGeqfkrI962WyCao3FINxcxwmlJbODYzJasavWIzzMZva5lIXQY1C(1DTC5w12jXgxUva5lIXMxe2I1c9MtokFOnBca]] )


end
