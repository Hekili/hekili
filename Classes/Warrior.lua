-- Warrior.lua
-- August 2014


local addon, ns = ...
local Hekili = _G[ addon ]

local state = ns.state

local addResource = ns.addResource
local addTalent = ns.addTalent
local addGlyph = ns.addGlyph

-- ...

local AbilityMods, AddHandler = Hekili.Utils.AbilityMods, Hekili.Utils.AddHandler

-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass("player")) == "WARRIOR") then

	Hekili.Class = "WARRIOR"

	-- AddResource( SPELL_POWER_HEALTH )
	AddResource( SPELL_POWER_RAGE )
	
	AddTalent( "anger_management"     , 152278 )
	AddTalent( "avatar"               , 107574 )
	AddTalent( "bladestorm"           , 46294 )
	AddTalent( "bloodbath"            , 12292 )
	AddTalent( "double_time"          , 103827 )
	AddTalent( "dragon_roar"          , 118000 )
	AddTalent( "enraged_regeneration" , 55694 )
	AddTalent( "furious_strikes"      , 169679 )
	AddTalent( "gladiators_resolve"   , 152276 )
	AddTalent( "heavy_repercussions"  , 169680 )
	AddTalent( "impending_victory"    , 103840 )
	AddTalent( "juggernaut"           , 103826 )
	AddTalent( "mass_spell_reflection", 114028 )
	AddTalent( "ravager"              , 152277 )
	AddTalent( "safeguard"            , 114029 )
	AddTalent( "second_wind"          , 29838 )
	AddTalent( "shockwave"            , 46968 )
	AddTalent( "siegebreaker"         , 176289 )
	AddTalent( "slam"                 , 1464 )
	AddTalent( "storm_bolt"           , 107570 )
	AddTalent( "sudden_death"         , 29725 )
	AddTalent( "taste_for_blood"      , 56636 )
	AddTalent( "unquenchable_thirst"  , 169683 )
	AddTalent( "unyielding_strikes"   , 169685 )
	AddTalent( "vigilance"            , 114030 )
	AddTalent( "warbringer"           , 103828 )

	-- Glyphs.
	AddGlyph( "blitz"              , 58377 )
	AddGlyph( "bloodcurdling_shout", 58096 )
	AddGlyph( "bloodthirst"        , 58367 )
	AddGlyph( "bloody_healing"     , 58369 )
	AddGlyph( "bull_rush"          , 94372 )
	AddGlyph( "burning_anger"      , 115946 )
	AddGlyph( "cleave"             , 159701 )
	AddGlyph( "colossus_smash"     , 89003 )
	AddGlyph( "crow_feast"         , 115943 )
	AddGlyph( "death_from_above"   , 63325 )
	AddGlyph( "die_by_the_sword"   , 58386 )
	AddGlyph( "enraged_speed"      , 58355 )
	AddGlyph( "flawless_defense"   , 159761 )
	AddGlyph( "gag_order"          , 58357 )
	AddGlyph( "gushing_wound"      , 58099 )
	AddGlyph( "hamstring"          , 58385 )
	AddGlyph( "heavy_repercussions", 58388 )
	AddGlyph( "heroic_leap"        , 159708 )
	AddGlyph( "hindering_strikes"  , 58366 )
	AddGlyph( "hold_the_line"      , 58364 )
	AddGlyph( "impaling_throws"    , 146970 )
	AddGlyph( "intimidation_shout" , 63327 )
	AddGlyph( "long_charge"        , 58097 )
	AddGlyph( "mighty_victory"     , 58104 )
	AddGlyph( "mocking_banner"     , 159738 )
	AddGlyph( "mortal_strike"      , 58368 )
	AddGlyph( "mystic_shout"       , 58095 )
	AddGlyph( "raging_blow"        , 159740 )
	AddGlyph( "raging_wind"        , 58370 )
	AddGlyph( "rallying_cry"       , 159754 )
	AddGlyph( "recklessness"       , 94374 )
	AddGlyph( "resonating_power"   , 58356 )
	AddGlyph( "rude_interruption"  , 58372 )
	AddGlyph( "shattering_throw"   , 159759 )
	AddGlyph( "shield_slam"        , 58375 )
	AddGlyph( "shield_wall"        , 63329 )
	AddGlyph( "spell_reflection"   , 63328 )
	AddGlyph( "sweeping_strikes"   , 58384 )
	AddGlyph( "blazing_trail"      , 123779 )
	AddGlyph( "drawn_sword"        , 159703 )
	AddGlyph( "executor"           , 146971 )
	AddGlyph( "raging_whirlwind"   , 146968 )
	AddGlyph( "subtle_defender"    , 146969 )
	AddGlyph( "watchful_eye"       , 146973 )
	AddGlyph( "weaponmaster"       , 146974 )
	AddGlyph( "thunder_strike"     , 68164 )
	AddGlyph( "unending_rage"      , 58098 )
	AddGlyph( "victorious_throw"   , 146965 )
	AddGlyph( "victory_rush"       , 58382 )
	AddGlyph( "wind_and_thunder"   , 63324 )
	
	-- Player Buffs / Debuffs
	AddAura( 'bloodbath'         , 12292 , 'duration', 12 )
	AddAura( 'bloodsurge'        , 46915 , 'duration', 15 )
	AddAura( 'colossus_smash'    , 167105, 'duration', 6 )
	AddAura( 'demoralizing_shout', 1160  , 'duration', 8 )
	AddAura( 'die_by_the_sword'  , 118038, 'duration', 8 )
	AddAura( 'enrage'            , 13046 , 'duration', 8 )
	AddAura( 'last_stand'        , 12975 , 'duration', 15 )
	AddAura( 'meat_cleaver'      , 85739 , 'duration', 10, 'max_stack', 3 )
	AddAura( 'mortal_strike'     , 12294 , 'duration', 10 )
	AddAura( 'piercing_howl'     , 12323 , 'duration', 15 )
	AddAura( 'raging_blow'       , 131116, 'duration', 12, 'max_stack', 2 )
	AddAura( 'rallying_cry'      , 96462 , 'duration', 10 )
	AddAura( 'recklessness'      , 1719  , 'duration', 10 )
	AddAura( 'rend'              , 772   , 'duration', 18 )
	AddAura( 'shield_barrier'    , 174926, 'duration', 6 )
	AddAura( 'shield_block'      , 132404, 'duration', 6 )
	AddAura( 'shield_wall'       , 871   , 'duration', 8 )
	AddAura( 'sudden_death'      , 52437 , 'duration', 10 )
	AddAura( 'sweeping_strikes'  , 12328 , 'duration', 10 )
	AddAura( 'thunder_clap'      , 6343  , 'duration', 6 )
	AddAura( 'ultimatum'         , 122510, 'duration', 10 )


	AddPerk( "empowered_execute"        , 157454 )
	AddPerk( "enhanced_rend"            , 174737 )
	AddPerk( "enhanced_sweeping_strikes", 157461 )
	AddPerk( "enhanced_whirlwind"       , 157473 )
	AddPerk( "improved_block"           , 157497 )
	AddPerk( "improved_defensive_stance", 157494 )
	AddPerk( "improved_die_by_the_sword", 157452 )
	AddPerk( "improved_heroic_leap"     , 157449 )
	AddPerk( "improved_heroic_throw"    , 157479 )
	AddPerk( "improved_recklessness"    , 176051 )
	
  
  -- Hook: runHandler
  ns.class.hooks.runHandler = function( key )

    local ability = ns.class.abilities[ key ]

  	if not ability.passive and state.nextMH < 0 then
      state.nextMH = state.now + state.offset - 0.01
      state.nextOH = state.now + state.offset + 0.99
    end
    
	end

	
	-- Abilities.
	AddAbility( 'avatar', 107574,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 180,
			passive = true
		} )
	AddAbility( 'battle_shout', 6673,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 0,
			passive = true
		} )
	AddAbility( 'battle_stance', 2457,
		{
			spend = 0,
			cast = 0
			gcdType = 'melee'
			cooldown = 1.5,
			passive = true
		} )
	AddAbility( 'berserker_rage', 18499,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 30,
			passive = true
		} )
	AddAbility( 'bladestorm', 46924,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 60
		} )
	AddAbility( 'bloodbath', 12292,
		{
			known = function( s ) return s.talent.bloodbath.enabled end,
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 60,
			passive = true
		} )
	AddAbility( 'bloodthirst', 23881,
		{
			known = function( s ) return s.spec.fury and IsSpellKnown( 78 ) end,
			spend = 0,
			gain = 10,
			cast = 0,
			gcdType = 'spell',
			cooldown = 4.5
		} )
	AddAbility( 'charge', 100,
		{
			spend = 0,
			gain = 20,
			cast = 0,
			gcdType = 'spell',
			cooldown = 20
		} )
	AddAbility( 'colossus_smash', 167105,
		{
			spend = 0,
			cast = 0
			gcdType = 'melee'
			cooldown = 20
		} )
	AddAbility( 'commanding_shout', 469,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 469,
			passive = true
		} )
	AddAbility( 'defensive_stance', 71,
		{
			spend = 0,
			cast = 0
			gcdType = 'melee'
			cooldown = 1.5,
			passive = true
		} )
	AddAbility( 'demoralizing_shout', 1160,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 60,
			passive = true
		} )
	AddAbility( 'devastate', 20243,
		{
			spend = 0,
			cast = 0
			gcdType = 'melee'
			cooldown = 0
		} )
	AddAbility( 'die_by_the_sword', 118038,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 120,
			passive = true
		} )
	AddAbility( 'dragon_roar', 118000,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 60
		} )
	AddAbility( 'execute', 163201,
		{
			spend = 30,
			cast = 0
			gcdType = 'melee'
			cooldown = 0,
			usable = function( s ) return s.buff.sudden_death.up or s.target.health_pct <= 20 ) end
		} )
	AddAbility( 'hamstring', 1715,
		{
			spend = 0,
			cast = 0
			gcdType = 'off'
			cooldown = 1
		} )
	AddAbility( 'heroic_leap', 6544,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 45,
			passive = true
		} )
	AddAbility( 'heroic_strike', 78,
		{
			spend = 30,
			cast = 0
			gcdType = 'off'
			cooldown = 1.5
		} )
	AddAbility( 'heroic_throw', 57755,
		{
			spend = 0,
			cast = 0
			gcdType = 'melee'
			cooldown = 6
		} )
	AddAbility( 'intervene', 3411,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 30,
			passive = true
		} )
	AddAbility( 'intimidating_shout', 5246,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 90,
			passive = true
		} )
	AddAbility( 'impending_victory', 103840,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 30
		} )
	AddAbility( 'last_stand', 12975,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 180,
			passive = true
		} )
	AddAbility( 'mocking_banner', 114192,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 180,
			passive = true
		} )
	AddAbility( 'mortal_strike', 12294,
		{
			known = function( s ) return s.spec.arms and IsSpellKnown( 78 ) end,
			spend = 20,
			cast = 0
			gcdType = 'melee'
			cooldown = 6
		} )
	AddAbility( 'piercing_howl', 12323,
		{
			spend = 10,
			cast = 0
			gcdType = 'spell'
			cooldown = 0,
			passive = true
		} )
	AddAbility( 'pummel', 6552,
		{
			spend = 0,
			cast = 0
			gcdType = 'off'
			cooldown = 15
		} )
	AddAbility( 'raging_blow', 85288,
		{
			spend = 10,
			cast = 0
			gcdType = 'melee'
			cooldown = 0,
			usable = function( s ) return s.buff.raging_blow.up end,
		} )
	AddAbility( 'rallying_cry', 97462,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 180,
			passive = true
		} )
	AddAbility( 'ravager', 152277,
		{
			spend = 0,
			cast = 0
			gcdType = 'melee'
			cooldown = 60,
			passive = true
		} )
	AddAbility( 'recklessness', 1719,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 180,
			passive = true
		} )
	AddAbility( 'rend', 772,
		{
			spend = 5,
			cast = 0
			gcdType = 'melee'
			cooldown = 0
		} )
	AddAbility( 'revenge', 6572,
		{
			spend = 0,
			cast = 0
			gcdType = 'melee'
			cooldown = 9
		} )
	AddAbility( 'shattering_throw', 64382,
		{
			spend = 0,
			cast = 1.5
			gcdType = 'spell'
			cooldown = 300
		} )
	AddAbility( 'shield_barrier', 174926,
		{
			spend = 20,
			cast = 0
			gcdType = 'spell'
			cooldown = 1.5,
			passive = true
		} )
	AddAbility( 'shield_block', 2565,
		{
			spend = 60,
			cast = 0
			gcdType = 'melee'
			cooldown = 12,
			passive = true
		} )
	AddAbility( 'shield_charge', 156321,
		{
			spend = 20,
			cast = 0
			gcdType = 'melee'
			cooldown = 15
		} )
	AddAbility( 'shield_slam', 23922,
		{
			spend = 0,
			cast = 0
			gcdType = 'melee'
			cooldown = 6
		} )
	AddAbility( 'shield_wall', 871,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 300,
			passive = true
		} )
	AddAbility( 'shockwave', 46968,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 40,
			passive = true
		} )
	AddAbility( 'siegebreaker', 176289,
		{
			spend = 0,
			cast = 0
			gcdType = 'melee'
			cooldown = 45
		} )
	AddAbility( 'spell_reflection', 23920,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 25,
			passive = true
		} )
	AddAbility( 'storm_bolt', 107570,
		{
			spend = 0,
			cast = 0
			gcdType = 'spell'
			cooldown = 30
		} )
	AddAbility( 'sweeping_strikes', 12328,
		{
			spend = 10,
			cast = 0
			gcdType = 'spell'
			cooldown = 10,
			passive = true
		} )
	AddAbility( 'taunt', 355,
		{
			spend = 0,
			cast = 0
			gcdType = 'melee'
			cooldown = 8,
			passive = true
		} )
	AddAbility( 'thunder_clap', 6343,
		{
			spend = 10,
			cast = 0
			gcdType = 'spell'
			cooldown = 6,
			passive = true
		} )
	AddAbility( 'victory_rush', 34428,
		{
			spend = 200,
			cast = 0
			gcdType = 'melee'
			cooldown = 0
		} )
	AddAbility( 'whirlwind', 1680,
		{
			spend = 20,
			cast = 0
			gcdType = 'melee'
			cooldown = 0
		} )
	AddAbility( 'wild_strike', 100130,
		{
			spend = 45,
			cast = 0
			gcdType = 'melee'
			cooldown = 0
		} )
	
	
	SetGCD( "battle_shout" )


	-- Gear Sets
	-- AddItemSet( "tier16_melee", 99347, 99340, 99341, 99342, 99343 )
	-- AddItemSet( "tier15_melee", 96689, 96690, 96691, 96692, 96693 )
	-- AddItemSet( "tier14_melee", 87138, 87137, 87136, 87135, 87134 )
	function Hekili:SetClassModifiers()
	
		for k,v in pairs( self.Abilities ) do
			for key, mod in pairs( v.mods ) do
				self.Abilities[ k ].mods[ key ] = nil
			end
		end
		
		local cd_death_from_above = "if glyph.heroic_leap.enabled then x = x - 15 end"
		local cd_unquenchable_thirst = "if talent.unquenchable_thirst.enabled then return 0 end"
		local cost_charge = "if glyph.bull_rush.enabled then return { SPELL_POWER_RAGE = -35 } end"
		local cost_execute = "x = max(10, min( rage.current, 40 ) )"
		local cost_sudden_death = "if buff.sudden_death.up then return 0 end"
		local cost_shockwave = "if active_enemies >= 3 then return 20 end"
		local cost_bloodsurge = "if buff.bloodsurge.up then return 0 end"
		
		AbilityMods( 'charge', 'cost', cost_charge )
		
		AbilityMods( 'heroic_leap', 'cooldown', cd_death_from_above )
		
		if self.Specialization == 71 then
			AbilityMods( 'execute', 'cost', cost_execute )
			
		elseif self.Specialization == 72 then
			AbilityElements( 'execute', 'id', 5308 )
			AbilityMods( 'execute', 'cost', cost_sudden_death )
			
			AbilityMods( 'bloodthirst', 'cooldown', cd_unquenchable_thirst )
			
			AbilityMods( 'wild_strike', 'cost', cost_bloodsurge )
			
		end
		
	end
	
	
	AddHandler( "avatar", function ()
		H:Buff( "avatar", 24 )
	end )
	
	
	AddHandler( 'battle_shout', function ()
		H:RemoveBuff( 'commanding_shout' ) -- need to confirm it's ours.
		H:Buff( 'battle_shout', 3600 )
	end )


	AddHandler( "battle_stance", function ()
		H:RemoveBuff( 'defensive_stance' )
		H:RemoveBuff( 'gladiator_stance' )
		H:Buff( "battle_stance", 3600 )
	end )

	
	AddHandler( "bloodthirst", function ()
		rage.current = min( rage.max, rage.current + 10 )
	end )

	AddHandler( "charge", function ()
		H:Debuff( "target", "charge", 1.5 )
		H:SetDistance( 0, 5 )
	end )
	
	
	AddHandler( "bloodbath", function ()
		H:Buff( "bloodbath", 12 )
	end )
	
	
	AddHandler( "charge", function ()
		H:SetDistance( 0, 5 )
	end )
	
	
	AddHandler( "heroic_leap", function ()
		if glyph.heroic_leap.enabled then H:Buff( 'heroic_leap', 3 ) end
		H:SetDistance( 0, 5 )
	end )
	
	
	AddHandler( "rend", function ()
		H:Debuff( 'target', "rend", 18 )
	end )
	
	
	AddHandler( "mortal_strike", function ()
		H:Debuff( 'target', 'mortal_strike', 10 )
	end )


	AddHandler( "colossus_smash", function ()
		H:Debuff( 'target', 'colossus_smash', 6 )
		H:RemoveBuff( 'defensive_stance' )
		H:Buff( 'battle_stance', 3600 )
	end )
	
	
	AddHandler( "storm_bolt", function ()
		H:Debuff( 'target', 'storm_bolt', 4 )
	end )
	
	
	AddHandler( "dragon_roar", function ()
		H:Debuff( 'target', 'dragon_roar', 0.5 )
	end )
	
	
	AddHandler( "recklessness", function ()
		H:Buff( "recklessness", glyph.recklessness.enabled and 15 or 10 )
		H:RemoveBuff( "defensive_stance" )
		H:Buff( "battle_stance", 3600 )
	end )
	
	
	AddHandler( "siegebreaker", function ()
		H:Debuff( 'target', 'siegebreaker', 1 )
	end )
	
	
	AddHandler( "slam", function ()
		if buff.slam.stack < 2 then
			H:AddStack( "slam", 2, 1 )
		end
	end )
	
	
	AddHandler( "whirlwind", function ()
		H:AddStack( "meat_cleaver", 10, 1 )
	end )
	
	AddHandler( "shockwave", function ()
		H:Debuff( 'target', 'shockwave', 4 )
	end )
	
	
	AddHandler( "pummel", function ()
		H:Interrupt( 'target' )
	end )
	
	
	AddHandler( 'raging_blow', function ()
		H:ConsumeStack( 'raging_blow' )
	end )
	
	
	AddHandler( 'execute', function ()
		H:ConsumeStack( 'sudden_death' )
	end )
	
	AddHandler( 'wild_strike', function ()
		H:ConsumeStack( 'bloodsurge' )
	end )
	
	setHook( "COMBAT_LOG_EVENT_UNFILTERED", function( ... )
	
    local subtype = select( 3, ... )
    local offhand = select( 22, ... )
    local multistrike = select( 23, ... )
    
    if subtype:sub(1, 5) == 'SWING' and not multistrike then
      local mainhandSpeed, offhandSpeed = UnitAttackSpeed( 'player' )
		
		if offhand == false or self.State.offhand_speed == 0 then
			state.lastMH = time
			state.nextMH = time + mainhandSpeed
			state.lastSwing = 'MH'
		else
			state.lastOH = time
			state.nextOH = time + offhandSpeed
			state.lastSwing = 'OH'
		end
		
	end )
  
end
