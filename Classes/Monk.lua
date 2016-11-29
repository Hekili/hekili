-- Monk.lua
-- August 2014

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local addHook = ns.addHook
local callHook = ns.callHook

local addAbility = ns.addAbility
local modifyAbility = ns.modifyAbility
local addHandler = ns.addHandler

local addAura = ns.addAura
local modifyAura = ns.modifyAura

local addGlyph = ns.addGlyph
local addTalent = ns.addTalent
local addPerk = ns.addPerk
local addResource = ns.addResource
local addStance = ns.addStance
local addGearSet = ns.addGearSet
local addToggle = ns.addToggle
local addSetting = ns.addSetting

local removeResource = ns.removeResource

local setClass = ns.setClass
local setPotion = ns.setPotion
local setRole = ns.setRole

local storeDefault = ns.storeDefault


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'MONK') then

  ns.initializeClassModule = function ()

    setClass( 'MONK' )

    addTalent( 'ascension', 115396 )
    addTalent( 'breath_of_the_serpent', 157535 )
    addTalent( 'celerity', 115173 )
    addTalent( 'charging_ox_wave', 119392 )
    addTalent( 'chi_brew', 115399 )
    addTalent( 'chi_burst', 123986 )
    addTalent( 'chi_explosion', 152174 ) -- WW
    -- addTalent( 'chi_explosion', 157676 ) -- BM
    -- addTalent( 'chi_explosion', 157675 ) -- MW
    addTalent( 'chi_torpedo', 115008 )
    addTalent( 'chi_wave', 115098 )
    addTalent( 'dampen_harm', 122278 )
    addTalent( 'diffuse_magic', 122783 )
    addTalent( 'healing_elixirs', 122280 )
    addTalent( 'hurricane_strike', 152175 )
    addTalent( 'invoke_xuen', 123904 )
    addTalent( 'leg_sweep', 119381 )
    addTalent( 'momentum', 115174 )
    addTalent( 'pool_of_mists', 173841 )
    addTalent( 'power_strikes', 121817 )
    addTalent( 'ring_of_peace', 116844 )
    addTalent( 'rushing_jade_wind', 116847 )
    addTalent( 'serenity', 152173 )
    addTalent( 'soul_dance', 157533 )
    addTalent( 'tigers_lust', 116841 )
    addTalent( 'zen_sphere', 124081 )

    -- Glyphs.
    addGlyph( 'breath_of_fire', 123394 )
    addGlyph( 'crackling_tiger_lightning', 125931 )
    addGlyph( 'detox', 146954 )
    addGlyph( 'detoxing', 171926 )
    addGlyph( 'expel_harm', 159487 )
    addGlyph( 'fighting_pose', 125872 )
    addGlyph( 'fists_of_fury', 125671 )
    addGlyph( 'flying_fists', 173182 )
    addGlyph( 'flying_serpent_kick', 123403 )
    addGlyph( 'fortifying_brew', 124997 )
    addGlyph( 'fortuitous_spheres', 146953 )
    addGlyph( 'freedom_roll', 159534 )
    addGlyph( 'guard', 123401 )
    addGlyph( 'honor', 125732 )
    addGlyph( 'jab', 125660 )
    addGlyph( 'keg_smash', 159495 )
    addGlyph( 'leer_of_the_ox', 125967 )
    addGlyph( 'life_cocoon', 124989 )
    addGlyph( 'mana_tea', 123763 )
    addGlyph( 'nimble_brew', 146952 )
    addGlyph( 'paralysis', 125755 )
    addGlyph( 'rapid_rolling', 146951 )
    addGlyph( 'renewed_tea', 159496 )
    addGlyph( 'renewing_mist', 123334 )
    addGlyph( 'rising_tiger_kick', 125151 )
    addGlyph( 'soothing_mist', 159536 )
    addGlyph( 'spirit_roll',  125154 )
    addGlyph( 'surging_mist', 120483 )
    addGlyph( 'targeted_expulsion', 146950 )
    addGlyph( 'floating_butterfly', 159490 )
    addGlyph( 'flying_serpent', 159492 )
    addGlyph( 'touch_of_death', 123391 )
    addGlyph( 'touch_of_karma', 125678 )
    addGlyph( 'transcendence', 123023 )
    addGlyph( 'victory_roll',  159497 )
    addGlyph( 'water_roll', 125901 )
    addGlyph( 'zen_flight', 125893 )
    addGlyph( 'zen_focus', 159545 )
    addGlyph( 'zen_meditation', 120477 )

    -- Player Buffs.
    addAura( 'cranes_zeal', 127722, 'duration', 20 )
    addAura( 'fortifying_brew', 115203 )
    addAura( 'shuffle', 115307 )
    addAura( 'breath_of_fire', 123725 )
    addAura( 'chi_explosion', 157680 )
    addAura( 'combo_breaker_bok', 116768 )
    addAura( 'combo_breaker_ce', 159407 )
    addAura( 'combo_breaker_tp', 118864 )
    addAura( 'dampen_harm', 122278 )
    addAura( 'death_note', 121125 )
    addAura( 'diffuse_magic', 122783 )
    addAura( 'elusive_brew_activated', 115308, 'fullscan', true )
    addAura( 'elusive_brew_stacks', 128939, 'max_stack', 15, 'fullscan', true )
    addAura( 'energizing_brew', 115288 )
    addAura( 'guard', 115295 )
    addAura( 'heavy_stagger', 124273, 'unit', 'player' )
    addAura( 'keg_smash', 121253 )
    addAura( 'legacy_of_the_emperor', 115921, 'duration', 3600 )
    addAura( 'legacy_of_the_white_tiger', 116781, 'duration', 3600 )
    addAura( 'light_stagger', 124275, 'duration', 10, 'unit', 'player' )
    addAura( 'mana_tea_stacks', 115867, 'duration', 120, 'max_stack', 15 )
    addAura( 'mana_tea_activated', 115294 )
    addAura( 'power_strikes', 129914 )
    addAura( 'moderate_stagger', 124274, 'duration', 10, 'unit', 'player' )
    addAura( 'rising_sun_kick', 130320 )
    addAura( 'rushing_jade_wind', 116847 )
    addAura( 'serenity', 152173 )
    addAura( 'soothing_mist', 115175 )
    addAura( 'spinning_crane_kick', 101546 )
    addAura( 'stagger', 124255 )
    addAura( 'storm_earth_and_fire', 137639 )
    addAura( 'storm_earth_and_fire_target', 138130 )
    addAura( 'tiger_palm', 100787 )
    addAura( 'tiger_power', 125359 )
    addAura( 'tigereye_brew', 125195, 'fullscan', true )
    addAura( 'tigereye_brew_use', 116740, 'fullscan', true )
    addAura( 'tigers_lust', 116841, 'duration', 6 )
    addAura( 'vital_mists', 118674, 'duration', 30, 'max_stack', 5 )
    addAura( 'zen_sphere', 124081, 'friendly', true )
    addAura( 'dizzying_haze', 116330 )

    -- Perks.
    addPerk( 'empowered_chi', 157411 )
    addPerk( 'empowered_spinning_crane_kick', 157415 )
    addPerk( 'enhanced_roll', 157361 )
    addPerk( 'enhanced_transcendence', 157366 )
    addPerk( 'improved_breath_of_fire', 157362 )
    addPerk( 'improved_guard', 157363 )
    addPerk( 'improved_life_cocoon', 157401 )
    addPerk( 'improved_renewing_mist', 157398 )

    -- Stances.
    -- Need to confirm the right IDs based on spec.
    addStance( 'fierce_tiger', 103985 )
    addStance( 'sturdy_ox', 115069 )
    addStance( 'wise_serpent', 115070 )
    addStance( 'spirited_crane', 154436 )

    -- Gear Sets
    addGearSet( 'tier17', 115555, 115556, 115557, 115558, 115559 )
    addGearSet( 'tier18', 124247, 124256, 124262, 124268, 124273 )
    addGearSet( 't18_class_trinket', 124517 )

    -- State Modifications
    state.stagger = setmetatable( {}, {
      __index = function(t, k)
        if k == 'heavy' then return state.debuff.heavy_stagger.up
        elseif k == 'moderate' then return state.debuff.moderate_stagger.up or state.debuff.heavy_stagger.up
        elseif k == 'light' then return state.debuff.light_stagger.up or state.debuff.moderate_stagger.up or state.debuff.heavy_stagger.up
        elseif k == 'amount' then
          if state.debuff.heavy_stagger.up then return state.debuff.heavy_stagger.v2
          elseif state.debuff.moderate_stagger.up then return state.debuff.moderate_stagger.v2
          elseif state.debuff.light_stagger.up then return state.debuff.light_stagger.v2
          else return 0 end
        elseif k == 'pct' or k == 'percent' then
          if state.debuff.heavy_stagger.up then return ( state.debuff.heavy_stagger.v2 / state.health.max * 100 )
          elseif state.debuff.moderate_stagger.up then return ( state.debuff.moderate_stagger.v2 / state.health.max * 100 )
          elseif state.debuff.light_stagger.up then return ( state.debuff.light_stagger.v2 / state.health.max * 100 )
          else return 0 end
        elseif k == 'tick' then
          if state.debuff.heavy_stagger.up then return state.debuff.heavy_stagger.v1
          elseif state.debuff.moderate_stagger.up then return state.debuff.moderate_stagger.v1
          elseif state.debuff.light_stagger.up then return state.debuff.light_stagger.v1
          else return 0 end
        end

        ns.Error( "stagger." .. k .. ": unknown key." )
      end
    } )


    addHook( 'specializationChanged', function ()

        addResource( 'chi' )
        removeResource( 'energy' )
        removeResource( 'mana' )

        if state.spec.mistweaver then
          setPotion( 'draenic_intellect' )
          state.gcd = nil
          addResource( 'mana', true )
          setRole( 'heal' )
        else
          setPotion( state.spec.brewmaster and 'draenic_armor' or 'draenic_agility' )
          setRole( state.spec.brewmaster and 'tank' or 'attack' )
          state.gcd = 1.0
          addResource( 'energy', true )
        end
    end )


    addToggle( 'mitigation', false, "Mitigation", "Toggling this keybinding will enable or disable mitigation abilities (|cFFFFD100toggle.mitigation|r) in the default action lists.\n\n|cFFFF0000WARNING|r: Mitigation abilities are best used |cFFFFD100proactively|r, using your knowledge of class abilities, planned strategies, and fight mechanics.  When recommending mitigation abilities, this addon bases its decision on current and recent combat conditions and is therefore |cFFFFD100reactive|r." )
    addToggle( 'storm', false, "Storm, Earth, and Fire", "Toggling this keybinding will enable or disable the Storm, Earth, and Fire ability (|cFFFFD100toggle.storm|r) in the default action lists." )
    addToggle( 'optimize_dps', true, "Fistweaver DPS", "When |cFFFFD100toggle.optimize_dps|r is set to true, the Fistweaver rotation will prioritize damage output over healing throughput.  When false, the addon will prioritize healing output (especially with regard to Chi Explosion)." )

    addSetting( 'mitigate_eb', 5, {
      name = "Mitigation: Elusive Brew",
      type = "range",
      desc = "For Elusive Brew to be recommended as a damage mitigation ability, the addon will require that you have received at least this much damage (as a percentage of maximum health) in the past 3 seconds.  The value can be used in action criteria as |cFFFFD100settings.mitigate_eb|r.",
      min = 0,
      max = 500,
      step = 1,
    } )
    
    addSetting( 'mitigate_fb', 50, {
      name = "Mitigation: Fortifying Brew",
      type = "range",
      desc = "For Purifying Brew to be recommended as a damage mitigation cooldown, the addon will require that you have received at least this much damage (as a percentage of maximum health) in the past 3 seconds.  The value can be used in action criteria as |cFFFFD100settings.mitigate_fb|r.  This setting is used by Brewmaster Monks only, to allow the Fortifying Brew/Touch of Death combo as used by Windwalkers.",
      min = 0,
      max = 500,
      step = 1,
    } )

    addSetting( 'mitigate_pb', 10, {
      name = "Mitigation: Purifying Brew",
      type = "range",
      desc = "For Purifying Brew to be recommended as a damage mitigation ability, the addon will require that you have received at least this much damage (as a percentage of maximum health) in the past 3 seconds.  The value can be used in action criteria as |cFFFFD100settings.mitigate_pb|r.",
      min = 0,
      max = 500,
      step = 1
    } )
    
    addSetting( 'mitigate_guard', 10, {
      name = "Mitigation: Guard",
      type = "range",
      desc = "For Guard to be recommended as a damage mitigation ability, the addon will require that you have received at least this much damage (as a percentage of maximum health) in the past 3 seconds.  The value can be used in action criteria as |cFFFFD100settings.mitigate_guard|r.",
      min = 0,
      max = 500,
      step = 1
    } )

    addSetting( 'mitigate_75', 20, {
      name = "Mitigation: Tier 75",
      type = "range",
      desc = "For your Tier 75 ability to be recommended as a damage mitigation cooldown, the addon will require that you have received at least this much damage (as a percentage of maximum health) in the past 3 seconds.  The value can be used in action criteria as |cFFFFD100settings.mitigate_75|r.",
      min = 0,
      max = 500,
      step = 1
    } )


    addHook( 'reset_postcast', function ( delay )
      if state.buff.spinning_crane_kick.up then
        return max( delay, state.buff.spinning_crane_kick.remains )
      end

      return delay
    end )


    -- Abilities
    addAbility( 'blackout_kick',
      {
        id = 100784,
        known = function () return not talent.chi_explosion.enabled end,
        spend = function ()
          if buff.combo_breaker_bok.up then return 0, 'chi' end
          return 2, 'chi'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0,
        usable = function()
          if stance.wise_serpent then return false end
          return true
        end,
      } )

    addHandler( 'blackout_kick', function ()
      if spec.brewmaster then applyBuff( 'shuffle', 6 )
      elseif spec.mistweaver then
        addStack( 'vital_mists', 30, 2 )
        applyBuff( 'cranes_zeal', 20 )
      end
      if buff.serenity.up and not buff.combo_breaker_bok.up then gain( 2, 'chi' ) end
      removeBuff( 'combo_breaker_bok' )
    end )


    addAbility( 'crackling_jade_lightning',
      {
        id = 117952,
        spend = function()
          if stance.spirited_crane then return 0.213, 'mana' end
          return 0, 'energy'
        end,
        cast = 4, -- need a 'channel' version.
        gcdType = 'spell',
        cooldown = 0,
        usable = function() return not stance.wise_serpent end
      } )

    addHandler( 'crackling_jade_lightning', function ()
      if spec.mistweaver then gain( 1, 'chi' ) end -- need to fix up for channeling.
      if buff.power_strikes.up then
        gain( 1, 'chi' )
        removeBuff( 'power_strikes' )
      end
    end )


    addAbility( 'expel_harm',
      {
        id = 115072,
        spend = function()
          if spec.mistweaver then
            return 0.02, 'mana'
          end
          return 40, 'energy'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 15,
        passive = true,
        usable = function() return health.current < health.max and not stance.wise_serpent end
      } )

    modifyAbility( 'expel_harm', 'cooldown', function( x )
      if set_bonus.tier18_2pc>0 and spec.brewmaster and stance.sturdy_ox and health.pct < 50 then return 0
      elseif stance.sturdy_ox and health.pct < 35 then return 0 end
      return x
    end )

    addHandler( 'expel_harm', function ()
      gain( spec.windwalker and 2 or 1, 'chi' )
      if buff.power_strikes.up then
        gain( 1, 'chi' )
        removeBuff( 'power_strikes' )
      end
      if set_bonus.tier18_2pc>0 and spec.brewmaster and cooldown.guard.remains > 0 then
        setCooldown( 'guard', max(0, cooldown.guard.remains - 5) )
      end
    end )


    addAbility( 'fortifying_brew',
      {
        id = 115203,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 180,
        gcdType = 'off',
        passive = true,
        usable = function () return spec.windwalker or ( toggle.mitigation and incoming_damage_3s / health.max >= settings.mitigate_fb / 100 ) end
      } )

    addHandler( 'fortifying_brew', function ()
      local health_gain = health.max * 0.2
      applyBuff( 'fortifying_brew', 15 )
      health.actual = health.actual + health_gain
      health.max = health.max + health_gain
    end )


    addAbility( 'jab',
      {
        id = 100780,
        spend = function()
          if stance.spirited_crane then return 0.035, 'mana'
          elseif stance.fierce_tiger then return 45, 'energy' end
          return 40, 'energy'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0
      } )

    addHandler( 'jab', function ()
      gain( spec.windwalker and 2 or 1, 'chi' )
      if buff.power_strikes.up then
        gain( 1, 'chi' )
        removeBuff( 'power_strikes' )
      end
    end )


    addAbility( 'spear_hand_strike',
      {
        id = 116705,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 15,
        toggle = 'interrupts',
        usable = function () return target.casting end
      } )

    addHandler( 'spear_hand_strike', function ()
      interrupt()
    end )


    addAbility( 'spinning_crane_kick',
      {
        id = 101546,
        spend = function()
          if stance.spirited_crane then
            return 0.08, 'mana'
          end
          return 40, 'energy'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0
      } )

    addHandler( 'spinning_crane_kick', function ()
      applyBuff( 'spinning_crane_kick', ( perk.empowered_spinning_crane_kick.enabled and 1.125 or 2.25 ) * haste )
      setCooldown( class.gcd, ( perk.empowered_spinning_crane_kick.enabled and 1.125 or 2.25 ) * haste )
      if min_targets >= 3 or my_enemies >= 3 then
        gain( 1, 'chi' )
        if buff.power_strikes.up then
          gain( 1, 'chi' )
          removeBuff( 'power_strikes' )
        end
      end
    end )


    addAbility( 'fierce_tiger',
      {
        id = 103985,
        spend = 0,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0
      } )

    addHandler( 'fierce_tiger', function ()
      setStance( 'fierce_tiger' )
    end )


    addAbility( 'surging_mist',
      {
        id = 116694,
        spend = function()
          if spec.mistweaver then return 0.047, 'mana' end
          return 30, 'energy'
        end,
        cast = 1.5,
        gcdType = 'spell',
        passive = true,
        cooldown = 0
      } )

    modifyAbility( 'surging_mist', 'cast', function ( x )
      if buff.vital_mists.up then x = ( x - ( x * ( 0.2 * buff.vital_mists.stack ) ) ) end
      return x * haste
    end )

    addHandler( 'surging_mist', function ()
      if spec.mistweaver then gain( 1, 'chi' ) end
      removeBuff( 'vital_mists' )
    end )


    addAbility( 'tiger_palm',
      {
        id = 100787,
        spend = function()
          if spec.brewmaster or buff.combo_breaker_tp.up then
            return 0, 'chi'
          end
          return 1, 'chi'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0,
        usable = function()
          if stance.wise_serpent then
            return false
          end
          return true
        end
      } )

    addHandler( 'tiger_palm', function ()
      if buff.serenity.up and not buff.combo_breaker_tp.up then gain( 1, 'chi' ) end
      if spec.brewmaster then applyBuff( 'tiger_palm', 20 )
      else
        applyBuff( 'tiger_power', 20 )
        addStack( 'vital_mists', 30, 1 )
      end
      removeBuff( 'combo_breaker_tp' )
    end )


    addAbility( 'touch_of_death',
      {
        id = 115080,
        spend = 3,
        spend_type = 'chi',
        cast = 0,
        gcdType = 'melee',
        cooldown = 90,
        usable = function() return buff.death_note.up end
      } )

    addHandler( 'touch_of_death', function ()
      if buff.serenity.up then gain( 3, 'chi' ) end
    end )

    modifyAbility( 'touch_of_death', 'spend', function ( x )
      if glyph.touch_of_death.enabled then return 0 end
      return x
    end )

    modifyAbility( 'touch_of_death', 'cooldown', function ( x )
      if glyph.touch_of_death.enabled then return x + 120 end
      return x
    end )


    addAbility( 'breath_of_fire',
      {
        id = 115181,
        spend = 2,
        spend_type, 'chi',
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      } )

    addHandler( 'breath_of_fire', function ()
      if perk.improved_breath_of_fire.enabled or debuff.dizzying_haze.up or debuff.keg_smash.up then
        applyDebuff( 'target', 'breath_of_fire', 8 )
      end
      if buff.serenity.up then gain( 2, 'chi' ) end
    end )


    addAbility( 'detonate_chi',
      {
        id = 115460,
        spend = 0.03,
        spend_type = 'mana',
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 10
      } )


    addAbility( 'disable',
      {
        id = 116095,
        spend = function()
          if stance.fierce_tiger then
            return 15, 'energy'
          end
          return 0.007, 'energy'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0
      } )

    addHandler( 'disable', function ()
      if debuff.disable.up then
      -- apply disable root
      else
        applyDebuff( 'target', 'disable', 8 )
      end
    end )


    addAbility( 'dizzying_haze',
      {
        id = 115180,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      } )

    addHandler( 'dizzying_haze', function ()
      applyDebuff( 'target', 'dizzying_haze', 15 )
    end )


    addAbility( 'elusive_brew',
      {
        id = 115308,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 6,
        toggle = 'mitigation',
        passive = true,
        usable = function () return buff.elusive_brew_stacks.up and incoming_damage_3s>0 end
      } )

    addHandler( 'elusive_brew', function ()
      applyBuff( 'elusive_brew_activated', buff.elusive_brew_stacks.stack )
      removeBuff( 'elusive_brew_stacks' )
    end )


    addAbility( 'energizing_brew',
      {
        id = 115288,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        passive = true,
        cooldown = 60
      } )

    addHandler( 'energizing_brew', function ()
      applyBuff( 'energizing_brew', 6 )
    end )


    addAbility( 'enveloping_mist',
      {
        id = 124682,
        spend = 3,
        spend_type = 'chi',
        usable = function() return stance.wise_serpent end,
        cast = 2,
        passive = true,
        cooldown = 0
      } )

    addHandler( 'enveloping_mist', function ()
      if buff.serenity.up then gain( 3, 'chi' ) end
    end )


    addAbility( 'fists_of_fury',
      {
        id = 113656,
        spend = 3,
        spend_type = 'chi',
        cast = 4,
        gcdType = 'spell',
        cooldown = 25
      } )

    modifyAbility( 'fists_of_fury', 'cast', function ( x )
      return x * haste
    end )

    addHandler( 'fists_of_fury', function ()
      if buff.serenity.up then gain( 3, 'chi' ) end
      if set_bonus.tier17_2pc then addStack( 'tigereye_brew', 1, 120 ) end
    end )


    addAbility( 'flying_serpent_kick',
      {
        id = 101545,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 25
      } )

    addHandler( 'flying_serpent_kick', function ()
      if target.within8 then applyDebuff( 'target', 'flying_serpent_kick', 4 ) end
    end )


    addAbility( 'guard',
      {
        id = 115295,
        spend = 2,
        spend_type = 'chi',
        cast = 0,
        gcdType = 'off',
        cooldown = 30,
        charges = 1,
        recharge = 30,
        toggle = 'mitigation',
        passive = true,
        usable = function () return incoming_damage_3s / health.max >= settings.mitigate_guard / 100 end,
      } )

    modifyAbility( 'guard', 'cooldown', function ( x )
      -- if cooldown.guard.charges > 1 then return 1 end
      return x
    end )

    modifyAbility( 'guard', 'charges', function ( x )
      if perk.improved_guard.enabled then return 2 end
      return x
    end )

    addHandler( 'guard', function ()
      applyBuff( 'guard', 30 )
      if buff.serenity.up then gain( 2, 'chi' ) end
    end )


    addAbility( 'keg_smash',
      {
        id = 121253,
        spend = 40,
        spend_type = 'energy',
        cast = 0,
        gcdType = 'melee',
        cooldown = 8
      } )

    addHandler( 'keg_smash', function ()
      applyDebuff( 'target', 'keg_smash', 15 )
      gain( 2, 'chi' )
    end )


    addAbility( 'legacy_of_the_emperor',
      {
        id = 115921,
        spend = function()
          if spec.mistweaver then return 0.01, 'mana' end
          return 20, 'energy'
        end,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0,
        passive = true
      } )

    addHandler( 'legacy_of_the_emperor', function ()
      applyBuff( 'legacy_of_the_emperor', 3600 )
      applyBuff( 'str_agi_int', 3600 )
    end )


    addAbility( 'legacy_of_the_white_tiger',
      {
        id = 116781,
        spend = 20,
        spend_type = 'energy',
        cast = 0,
        gcdType = 'spell',
        cooldown = 0,
        passive = true
      } )

    addHandler( 'legacy_of_the_white_tiger', function ()
      applyBuff( 'legacy_of_the_white_tiger', 3600 )
      applyBuff( 'str_agi_int', 3600 )
      applyBuff( 'critical_strike', 3600 )
    end )


    addAbility( 'life_cocoon',
      {
        id = 116849,
        spend = 0.024,
        spend_type = 'mana',
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 120
      } )

    addHandler( 'life_cocoon', function ()
      applyBuff( 'life_cocoon', 12 )
    end )

    modifyAbility( 'life_cocoon', 'cooldown', function ( x )
      if perk.improved_life_cocoon.enabled then return x - 20 end
      return x
    end )


    addAbility( 'mana_tea',
      {
        id = 115294,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 0
      } )

    modifyAbility( 'mana_tea', 'cast', function ( x )
      return buff.mana_tea.stack * 0.5
    end )

    addHandler( 'mana_tea', function ()
      removeBuff( 'mana_tea_stacks' )
    end )


    addAbility( 'purifying_brew',
      {
        id = 119582,
        spend = 1,
        spend_type = 'chi',
        cast = 0,
        gcdType = 'off',
        cooldown = 1,
        usable = function() return stagger.light and incoming_damage_3s / health.max >= settings.mitigate_pb / 100 end,
        toggle = 'mitigation'
      } )

    addHandler( 'purifying_brew', function ()
      if buff.serenity.up then gain( 1, 'chi' ) end
      if set_bonus.tier17_4pc and stagger.moderate then addStack( 'elusive_brew_stacks', 30, 1 ) end
      removeDebuff( 'player', 'stagger' )
      removeDebuff( 'player', 'light_stagger' )
      removeDebuff( 'player', 'moderate_stagger' )
      removeDebuff( 'player', 'heavy_stagger' )
    end )


    addAbility( 'renewing_mist',
      {
        id = 115151,
        spend = 0.04,
        spend_type = 'mana',
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 8
      } )

    addHandler( 'renewing_mist', function ()
      applyBuff( 'renewing_mist', 18 )
      gain( 1, 'chi' )
    end )


    addAbility( 'revival',
      {
        id = 115310,
        spend = 0.044,
        spend_type = 'mana',
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 180
      } )


    addAbility( 'rising_sun_kick',
      {
        id = 107428,
        spend = 2,
        spend_type = 'chi',
        cast = 0,
        gcdType = 'melee',
        cooldown = 8,
        charges = 1,
        recharge = 8
      } )

    modifyAbility( 'rising_sun_kick', 'charges', function ( x )
      if talent.pool_of_mists.enabled then return 3 end
      return nil
    end )

    addHandler( 'rising_sun_kick', function ()
      if buff.serenity.up then gain( 2, 'chi' ) end
      if spec.mistweaver then addStack( 'vital_mists', 30, 2 ) end
      applyDebuff( 'target', 'rising_sun_kick', 15 )
    end )


    addAbility( 'soothing_mist',
      {
        id = 115175,
        spend = 0,
        cast = 8,
        gcdType = 'spell',
        passive = true,
        cooldown = 1
      } )

    addHandler( 'soothing_mist', function ()
      applyBuff( 'soothing_mist', 8 )
    end )


    addAbility( 'spirited_crane',
      {
        id = 154436,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 0
      } )

    addHandler( 'spirited_crane', function ()
      setStance( 'spirited_crane' )
    end )


    addAbility( 'sturdy_ox',
      {
        id = 115069,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 0
      } )

    addHandler( 'sturdy_ox', function ()
      setStance( 'sturdy_ox' )
    end )


    addAbility( 'wise_serpent',
      {
        id = 115070,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 0
      } )

    addHandler( 'wise_serpent', function ()
      setStance( 'wise_serpent' )
    end )


    addAbility( 'storm_earth_and_fire',
      {
        id = 137639,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 1,
        toggle = 'storm',
        usable = function() return toggle.storm or debuff.storm_earth_and_fire_target.up end
      } )

    addHandler( 'storm_earth_and_fire', function ( list, action )
      local args = getModifiers( list, action )

      if buff.storm_earth_and_fire.stack == 2 and not debuff.storm_earth_and_fire_target.up then
        removeBuff( 'storm_earth_and_fire' )
        removeDebuff( 'target', 'storm_earth_and_fire_target' )
      elseif buff.storm_earth_and_fire.up and debuff.storm_earth_and_fire_target.up then
        removeStack( 'storm_earth_and_fire', 1 )
        removeDebuff( 'target', 'storm_earth_and_fire_target' )
      else
        addStack( 'storm_earth_and_fire', 3600, 1 )
        applyDebuff( 'target', 'storm_earth_and_fire_target', 3600 )
      end
    end )


    addAbility( 'summon_black_ox_statue',
      {
        id = 115315,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 10
      } )

    addHandler( 'summon_black_ox_statue', function ()
      summonTotem( 'summon_black_ox_statue', 600 )
    end )


    addAbility( 'summon_jade_serpent_statue',
      {
        id = 115315,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 10
      } )

    addHandler( 'summon_jade_serpent_statue', function ()
      summonTotem( 'summon_jade_serpent_statue', 600 )
    end )


    addAbility( 'thunder_focus_tea',
      {
        id = 116680,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 45
      } )

    addHandler( 'thunder_focus_tea', function ()
      applyBuff( 'thunder_focus_tea', 20 )
    end )


    addAbility( 'tigereye_brew',
      {
        id = 116740,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        passive = true,
        cooldown = 5
      } )

    addHandler( 'tigereye_brew', function ()
      applyBuff( 'tigereye_brew_use', 15 )
      removeStack( 'tigereye_brew', min( 10, buff.tigereye_brew.stack ) )
    end )


    addAbility( 'touch_of_karma',
      {
        id = 122470,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 90
      } )

    addHandler( 'touch_of_karma', function ()
      applyBuff( 'touch_of_karma', 10 )
      applyDebuff( 'target', 'touch_of_karma', 10 )
    end )


    addAbility( 'uplift',
      {
        id = 116670,
        spend = 2,
        spend_type = 'chi',
        cast = 1.5,
        gcdType = 'spell',
        passive = true,
        cooldown = 0
      } )

    addHandler( 'uplift', function ()
      if buff.serenity.up then gain( 2, 'chi' ) end
    end )


    addAbility( 'zen_meditation',
      {
        id = 115176,
        spend = 0,
        cast = 8,
        gcdType = 'spell',
        passive = true,
        cooldown = 180
      } )


    addAbility( 'breath_of_the_serpent',
      {
        id = 157535,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        passive = true,
        cooldown = 90
      } )


    addAbility( 'charging_ox_wave',
      {
        id = 119392,
        known = function() return talent.charging_ox_wave.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 30
      } )

    addHandler( 'charging_ox_wave', function ()
      applyDebuff( 'target', 'charging_ox_wave', 3 )
    end )


    addAbility( 'chi_brew',
      {
        id = 115399,
        known = function() return talent.chi_brew.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 60,
        charges = 2,
        passive = true,
        recharge = 60
      } )

    modifyAbility( 'chi_brew', 'cooldown', function ( x )
      -- if cooldown.chi_brew.charges > 1 then return 0 end
      return x
    end )


    addHandler( 'chi_brew', function ()
      gain( 2, 'chi' )
      if spec.windwalker then
        addStack( 'tigereye_brew', 120, 2 )
      elseif spec.brewmaster then
        addStack( 'elusive_brew_stacks', 30, 5 )
      elseif spec.mistweaver then
        addStack( 'mana_tea_stacks', 120, 1 )
      end
    end )


    addAbility( 'chi_burst',
      {
        id = 123986,
        known = function() return talent.chi_burst.enabled end,
        spend = 0,
        cast = 1,
        gcdType = 'spell',
        cooldown = 30
      } )


    addAbility( 'chi_explosion',
      {
        id = 157676,
        known = function() return talent.chi_explosion.enabled end,
        spend = function()
          if buff.combo_breaker_ce.up then return 0, 'chi' end
          return 1, 'chi'
        end,
        cast = 0,
        gcdType = 'melee',
        cooldown = 0
      }, 157675, 152174 )

    addHandler( 'chi_explosion', function ()
      local faux_chi = min( 4, chi.current )
      if spec.brewmaster then
        if faux_chi >= 2 then applyBuff( 'shuffle', 2 + 2 * min(4, chi.current ) ) end
        if faux_chi >= 3 then
          if set_bonus.tier17_4pc and stagger.moderate then addStack( 'elusive_brew_stacks', 30, 1 ) end
          removeDebuff( 'player', 'stagger' )
          removeDebuff( 'player', 'light_stagger' )
          removeDebuff( 'player', 'moderate_stagger' )
          removeDebuff( 'player', 'heavy_stagger' )
        end
      elseif spec.windwalker then
        if faux_chi >= 2 then applyDebuff( 'target', 'chi_explosion', 6 ) end
        if faux_chi >= 3 then addStack( 'tigereye_brew', 120, 1 ) end
      elseif spec.mistweaver then
        if faux_chi >= 1 then applyBuff( 'chi_explosion', 6 ) end
        if faux_chi >= 2 then applyBuff( 'cranes_zeal', 20 ) end
        addStack( 'vital_mists', 30, faux_chi )
      end
      -- If we had more than one chi going into this, spend up to 3 more.
      if buff.combo_breaker_ce.up then
        faux_chi = max( 0, chi.current - 2 )
      else
        faux_chi = faux_chi - 1
      end
      if faux_chi > 0 then
        spend( min( 3, faux_chi ), 'chi' )
      end
      removeBuff( 'combo_breaker_ce' )
    end )


    addAbility( 'chi_torpedo',
      {
        id = 115008,
        known = function() return talent.chi_torpedo.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'melee',
        cooldown = 20,
        charges = 2,
        recharge = 20
      } )


    addAbility( 'chi_wave',
      {
        id = 115098,
        known = function() return talent.chi_wave.enabled end,
        -- spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 15
      } )


    addAbility( 'dampen_harm',
      {
        id = 122278,
        known = function() return talent.dampen_harm.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 90,
        toggle = 'mitigation',
        passive = true,
        usable = function () return incoming_damage_3s / health.max >= settings.mitigate_75 / 100 end,
      } )

    addHandler( 'dampen_harm', function ()
      applyBuff( 'dampen_harm', 15 )
    end )


    addAbility( 'diffuse_magic',
      {
        id = 122783,
        known = function() return talent.diffuse_magic.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 90,
        toggle = 'mitigation',
        passive = true,
        usable = function () return incoming_damage_3s / health.max >= settings.mitigate_75 / 100 end,
      } )

    addHandler( 'diffuse_magic', function ()
      applyBuff( 'diffuse_magic', 6 )
    end )


    addAbility( 'hurricane_strike',
      {
        id = 152175,
        spend = 3,
        spend_type = 'chi',
        cast = 2,
        gcdType = 'melee',
        cooldown = 45
      } )


    addAbility( 'invoke_xuen',
      {
        id = 123904,
        known = function() return talent.invoke_xuen.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 180,
        toggle = 'cooldowns'
      } )

    addHandler( 'invoke_xuen', function ()
      summonPet( 'invoke_xuen', 45 )
    end )


    addAbility( 'leg_sweep',
      {
        id = 119381,
        known = function() return talent.leg_sweep.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'melee',
        cooldown = 45
      } )

    addHandler( 'leg_sweep', function ()
      applyDebuff( 'target', 'leg_sweep', 5 )
    end )


    addAbility( 'ring_of_peace',
      {
        id = 116844,
        known = function() return talent.ring_of_peace.enabled end,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 45
      } )

    addHandler( 'ring_of_peace', function ()
      applyBuff( 'ring_of_peace', 8 )
    end )


    addAbility( 'rushing_jade_wind',
      {
        id = 116847,
        known = function() return talent.rushing_jade_wind.enabled end,
        spend = function()
          if stance.spirited_crane or stance.wise_serpent then
            return 0.125, 'mana'
          end
          return 40, 'energy'
        end,
        cast = 0,
        gcdType = 'spell',
        cooldown = 6
      } )

    addHandler( 'rushing_jade_wind', function ()
      if min_targets >= 3 or my_enemies >= 3 then
        gain( 1, 'chi' )
        if buff.power_strikes.up then
          gain( 1, 'chi' )
          removeBuff( 'power_strikes' )
        end
      end
      applyBuff( 'rushing_jade_wind', 6 )
    end )

    modifyAbility( 'rushing_jade_wind', 'cooldown', function ( x )
      return x * haste
    end )


    addAbility( 'serenity',
      {
        id = 152173,
        known = function() return talent.serenity.enabled end,
        spend = 0,
        cast = 0,
        cooldown = 90,
        gcdType = 'spell',
        passive = true,
        toggle = 'cooldowns'
      } )

    addHandler( 'serenity', function ()
      -- 6.2 -- applyBuff( 'serenity', spec.brewmaster and 5 or 10 )
      applyBuff( 'serenity', 10 )
    end )


    addAbility( 'tigers_lust',
      {
        id = 116841,
        spend = 0,
        cast = 0,
        cooldown = 30,
        passive = true,
        gcdType = 'spell'
      } )

    addHandler( 'tigers_lust', function ()
      applyBuff( 'tigers_lust', 6 )
    end )


    addAbility( 'zen_sphere',
      {
        id = 124081,
        known = function() return talent.zen_sphere.enabled end,
        spend = 0,
        cast = 0,
        cooldown = 10,
        passive = true,
        gcdType = 'spell'
      } )

    addHandler( 'zen_sphere', function ()
      applyBuff( 'zen_sphere', 16 )
    end )


    addAbility( 'energizing_brew',
      {
        id = 115288,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        passive = true,
        cooldown = 60
      } )

    addHandler( 'energizing_brew', function ()
      applyBuff( 'energizing_brew', 6 )
    end )

    -- Pick an instant cast ability for checking the GCD.
    storeDefault( 'BM: Precombat', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SScript^S^SDefault^B^SRelease^N20150914.1^SSpecialization^N268^SActions^T^N1^T^SEnabled^B^SScript^Stoggle.cooldowns^SArgs^Sname=draenic_armor^SAbility^Spotion^SIndicator^Snone^SRelease^N201506.221^SName^SPotion^t^N2^T^SEnabled^B^SScript^Stoggle.mitigation^SAbility^Sdampen_harm^SIndicator^Snone^SRelease^N201506.221^SName^SDampen~`Harm^t^t^SName^SBM:~`Precombat^t^^]] )

    storeDefault( 'BM: Default', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SScript^S^SDefault^B^SRelease^N20150914.1^SSpecialization^N268^SActions^T^N1^T^SEnabled^B^SScript^Stoggle.interrupts~J^SAbility^Sspear_hand_strike^SIndicator^Snone^SRelease^N201506.221^SName^SSpear~`Hand~`Strike^t^N2^T^SEnabled^B^SScript^Stoggle.cooldowns&(energy.current<=40)^SAbility^Sblood_fury^SIndicator^Snone^SRelease^N201506.221^SName^SBlood~`Fury^t^N3^T^SEnabled^B^SScript^Stoggle.cooldowns&(energy.current<=40)^SAbility^Sberserking^SIndicator^Snone^SRelease^N201506.221^SName^SBerserking^t^N4^T^SEnabled^B^SScript^Schi.max-chi.current>=1&energy.current<=40^SAbility^Sarcane_torrent^SIndicator^Snone^SRelease^N201506.221^SName^SArcane~`Torrent^t^N5^T^SEnabled^B^SScript^Stalent.chi_brew.enabled&chi.max-chi.current>=2&buff.elusive_brew_stacks.stack<=10&((charges=1&recharge_time<5)|charges=2|(target.time_to_die<15&(cooldown.touch_of_death.remains>target.time_to_die|glyph.touch_of_death.enabled)))^SAbility^Schi_brew^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Brew^t^N6^T^SEnabled^B^SScript^S(chi.current<1&stagger.heavy)|(chi.current<2&buff.shuffle.down)^SAbility^Schi_brew^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Brew~`(1)^t^N7^T^SEnabled^B^SScript^Stoggle.mitigation&(incoming_damage_1500ms>0&buff.fortifying_brew.down)^SAbility^Sdiffuse_magic^SIndicator^Snone^SRelease^N201506.221^SName^SDiffuse~`Magic^t^N8^T^SEnabled^B^SScript^Stoggle.mitigation&(incoming_damage_1500ms>0&buff.fortifying_brew.down&buff.elusive_brew_activated.down)^SAbility^Sdampen_harm^SIndicator^Snone^SRelease^N201506.221^SName^SDampen~`Harm^t^N9^T^SEnabled^B^SScript^Sincoming_damage_1500ms>0&(buff.dampen_harm.down|buff.diffuse_magic.down)&buff.elusive_brew_activated.down^SAbility^Sfortifying_brew^SIndicator^Snone^SRelease^N201506.221^SName^SFortifying~`Brew^t^N10^T^SEnabled^B^SScript^Stoggle.mitigation&(buff.elusive_brew_stacks.react>=9&(buff.dampen_harm.down|buff.diffuse_magic.down)&buff.elusive_brew_activated.down)^SAbility^Selusive_brew^SIndicator^Snone^SRelease^N201506.221^SName^SElusive~`Brew^t^N11^T^SEnabled^B^SScript^Stoggle.cooldowns&(talent.invoke_xuen.enabled&target.time_to_die>15&buff.shuffle.remains>=3&buff.serenity.down)^SAbility^Sinvoke_xuen^SIndicator^Snone^SRelease^N201506.221^SName^SInvoke~`Xuen,~`the~`White~`Tiger^t^N12^T^SEnabled^B^SScript^Stoggle.cooldowns&(talent.serenity.enabled&cooldown.keg_smash.remains>6)^SAbility^Sserenity^SIndicator^Snone^SRelease^N201506.221^SName^SSerenity^t^N13^T^SEnabled^B^SScript^Stoggle.cooldowns&((buff.fortifying_brew.down&(buff.dampen_harm.down|buff.diffuse_magic.down)&buff.elusive_brew_activated.down))^SArgs^Sname=draenic_armor^SAbility^Spotion^SIndicator^Snone^SRelease^N201506.221^SName^SPotion^t^N14^T^SEnabled^B^SScript^Starget.health.percent<10&cooldown.touch_of_death.remains=0&((!glyph.touch_of_death.enabled&chi.current>=3&target.time_to_die<8)|(glyph.touch_of_death.enabled&target.time_to_die<5))^SAbility^Stouch_of_death^SIndicator^Snone^SRelease^N201506.221^SName^STouch~`of~`Death^t^N15^T^SEnabled^B^SScript^Smy_enemies<3^SArgs^Sname="BM:~`ST"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^N201506.221^SName^SCall~`Action~`List^t^N16^T^SEnabled^B^SScript^Smy_enemies>=3^SArgs^Sname="BM:~`AOE"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^N201506.221^SName^SCall~`Action~`List~`(1)^t^t^SName^SBM:~`Default^t^^]] )

    storeDefault( 'BM: ST', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SScript^S^SDefault^B^SRelease^N20150914.1^SSpecialization^N268^SActions^T^N1^T^SEnabled^B^SScript^Stoggle.mitigation&(stagger.heavy)^SAbility^Spurifying_brew^SIndicator^Snone^SRelease^N201506.221^SName^SPurifying~`Brew^t^N2^T^SEnabled^B^SScript^Stalent.chi_explosion.enabled&buff.shuffle.down&chi.current>=2^SAbility^Schi_explosion^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Explosion^t^N3^T^SEnabled^B^SScript^Sbuff.shuffle.down^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^N201506.221^SName^SBlackout~`Kick^t^N4^T^SEnabled^B^SScript^Stoggle.mitigation&(buff.serenity.up)^SAbility^Spurifying_brew^SIndicator^Snone^SRelease^N201506.221^SName^SPurifying~`Brew~`(1)^t^N5^T^SEnabled^B^SScript^Stalent.chi_explosion.enabled&chi.current>=3^SAbility^Schi_explosion^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Explosion~`(1)^t^N6^T^SEnabled^B^SScript^Stoggle.mitigation&(stagger.moderate&buff.shuffle.remains>=6)^SAbility^Spurifying_brew^SIndicator^Snone^SRelease^N201506.221^SName^SPurifying~`Brew~`(2)^t^N7^T^SEnabled^B^SScript^Stoggle.mitigation&((charges=1&recharge_time<5)|charges=2|target.time_to_die<15)^SAbility^Sguard^SIndicator^Snone^SRelease^N201506.221^SName^SGuard^t^N8^T^SEnabled^B^SScript^Stoggle.mitigation&(incoming_damage_10s>=health.max*0.5)^SAbility^Sguard^SIndicator^Snone^SRelease^N201506.221^SName^SGuard~`(1)^t^N9^T^SEnabled^B^SScript^Starget.health.percent<10&cooldown.touch_of_death.remains=0&chi.max-chi.current>=2&(buff.shuffle.remains>=6|target.time_to_die<buff.shuffle.remains)&!glyph.touch_of_death.enabled^SAbility^Schi_brew^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Brew^t^N10^T^SEnabled^B^SScript^Schi.max-chi.current>=2&!buff.serenity.up^SAbility^Skeg_smash^SIndicator^Snone^SRelease^N201506.221^SName^SKeg~`Smash^t^N11^T^SEnabled^B^SScript^Sbuff.shuffle.remains<=3&cooldown.keg_smash.remains>=gcd^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^N201506.221^SName^SBlackout~`Kick~`(1)^t^N12^T^SEnabled^B^SScript^Sbuff.serenity.up^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^N201506.221^SName^SBlackout~`Kick~`(2)^t^N13^T^SEnabled^B^SScript^Senergy.time_to_max>2&buff.serenity.down^SAbility^Schi_burst^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Burst^t^N14^T^SEnabled^B^SScript^Senergy.time_to_max>2&buff.serenity.down^SAbility^Schi_wave^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Wave^t^N15^T^SEnabled^B^SScript^S!dot.zen_sphere.ticking&energy.time_to_max>2&buff.serenity.down^SArgs^S^SAbility^Szen_sphere^SIndicator^Snone^SRelease^N201506.221^SName^SZen~`Sphere^t^N16^T^SEnabled^B^SScript^Sgroup&(!active_dot.zen_sphere>=group_members&energy.time_to_max>2&buff.serenity.down)^SArgs^Scycle_targets=1^SAbility^Szen_sphere^SIndicator^Scycle^SRelease^N201506.221^SName^SZen~`Sphere~`(1)^t^N17^T^SEnabled^B^SScript^Schi.max-chi.current<2^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^N201506.221^SName^SBlackout~`Kick~`(3)^t^N18^T^SEnabled^B^SScript^Shealth.percent<95&chi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd&(energy.current+(energy.regen*(cooldown.keg_smash.remains)))>=80^SAbility^Sexpel_harm^SIndicator^Snone^SRelease^N201506.221^SName^SExpel~`Harm^t^N19^T^SEnabled^B^SScript^Schi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd&(energy.current+(energy.regen*(cooldown.keg_smash.remains)))>=80^SAbility^Sjab^SIndicator^Snone^SRelease^N201506.221^SName^SJab^t^N20^T^SEnabled^B^SName^STiger~`Palm^SAbility^Stiger_palm^SIndicator^Snone^SRelease^N201506.221^t^t^SName^SBM:~`ST^t^^]] )

    storeDefault( 'BM: AOE', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SScript^S^SDefault^B^SRelease^N20150914.1^SSpecialization^N268^SActions^T^N1^T^SEnabled^B^SScript^Stoggle.mitigation&(stagger.heavy)^SAbility^Spurifying_brew^SIndicator^Snone^SRelease^N201506.221^SName^SPurifying~`Brew^t^N2^T^SEnabled^B^SScript^Stalent.chi_explosion.enabled&buff.shuffle.down&chi.current>=2^SAbility^Schi_explosion^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Explosion^t^N3^T^SEnabled^B^SScript^Sbuff.shuffle.down^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^N201506.221^SName^SBlackout~`Kick^t^N4^T^SEnabled^B^SScript^Stoggle.mitigation&(buff.serenity.up)^SAbility^Spurifying_brew^SIndicator^Snone^SRelease^N201506.221^SName^SPurifying~`Brew~`(1)^t^N5^T^SEnabled^B^SScript^Stalent.chi_explosion.enabled&chi.current>=4^SAbility^Schi_explosion^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Explosion~`(1)^t^N6^T^SEnabled^B^SScript^Stoggle.mitigation&(stagger.moderate&buff.shuffle.remains>=6)^SAbility^Spurifying_brew^SIndicator^Snone^SRelease^N201506.221^SName^SPurifying~`Brew~`(2)^t^N7^T^SEnabled^B^SScript^Stoggle.mitigation&((charges=1&recharge_time<5)|charges=2|target.time_to_die<15)^SAbility^Sguard^SIndicator^Snone^SRelease^N201506.221^SName^SGuard^t^N8^T^SEnabled^B^SScript^Stoggle.mitigation&(incoming_damage_10s>=health.max*0.5)^SAbility^Sguard^SIndicator^Snone^SRelease^N201506.221^SName^SGuard~`(1)^t^N9^T^SEnabled^B^SScript^Starget.health.percent<10&cooldown.touch_of_death.remains=0&chi.current<=3&chi.current>=1&(buff.shuffle.remains>=6|target.time_to_die<buff.shuffle.remains)&!glyph.touch_of_death.enabled^SAbility^Schi_brew^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Brew^t^N10^T^SEnabled^B^SScript^Schi.max-chi.current>=2&!buff.serenity.up^SAbility^Skeg_smash^SIndicator^Snone^SRelease^N201506.221^SName^SKeg~`Smash^t^N11^T^SEnabled^B^SScript^Sbuff.shuffle.remains<=3&cooldown.keg_smash.remains>=gcd^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^N201506.221^SName^SBlackout~`Kick~`(1)^t^N12^T^SEnabled^B^SScript^Sbuff.serenity.up^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^N201506.221^SName^SBlackout~`Kick~`(2)^t^N13^T^SEnabled^B^SScript^Schi.max-chi.current>=1&buff.serenity.down^SAbility^Srushing_jade_wind^SIndicator^Snone^SRelease^N201506.221^SName^SRushing~`Jade~`Wind^t^N14^T^SEnabled^B^SScript^Senergy.time_to_max>2&buff.serenity.down^SAbility^Schi_burst^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Burst^t^N15^T^SEnabled^B^SScript^Senergy.time_to_max>2&buff.serenity.down^SAbility^Schi_wave^SIndicator^Snone^SRelease^N201506.221^SName^SChi~`Wave^t^N16^T^SEnabled^B^SScript^S!dot.zen_sphere.ticking&energy.time_to_max>2&buff.serenity.down^SArgs^S^SAbility^Szen_sphere^SIndicator^Snone^SRelease^N201506.221^SName^SZen~`Sphere^t^N17^T^SEnabled^B^SScript^Sgroup&(!active_dot.zen_sphere>=group_members&energy.time_to_max>2&buff.serenity.down)^SArgs^Scycle_targets=1^SAbility^Szen_sphere^SIndicator^Scycle^SRelease^N201506.221^SName^SZen~`Sphere~`(1)^t^N18^T^SEnabled^B^SScript^Schi.max-chi.current<2^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^N201506.221^SName^SBlackout~`Kick~`(3)^t^N19^T^SEnabled^B^SScript^Shealth.percent<95&chi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd&(energy.current+(energy.regen*(cooldown.keg_smash.remains)))>=80^SAbility^Sexpel_harm^SIndicator^Snone^SRelease^N201506.221^SName^SExpel~`Harm^t^N20^T^SEnabled^B^SScript^Schi.max-chi.current>=1&cooldown.keg_smash.remains>=gcd&(energy.current+(energy.regen*(cooldown.keg_smash.remains)))>=80^SAbility^Sjab^SIndicator^Snone^SRelease^N201506.221^SName^SJab^t^N21^T^SEnabled^B^SName^STiger~`Palm^SAbility^Stiger_palm^SIndicator^Snone^SRelease^N201506.221^t^t^SName^SBM:~`AOE^t^^]] )

    storeDefault( 'WW: Precombat', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N20150914.1^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SScript^S!aura.str_agi_int.up|!aura.critical_strike.up^SAbility^Slegacy_of_the_white_tiger^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SLegacy~`of~`the~`White~`Tiger^t^N2^T^SEnabled^B^SScript^Stoggle.cooldowns^SArgs^Sname=draenic_agility^SAbility^Spotion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPotion^t^t^SName^SWW:~`Precombat^t^^]] )

    storeDefault( 'WW: Default', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N20150914.1^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SScript^Stoggle.cooldowns^SAbility^Sinvoke_xuen^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SInvoke~`Xuen,~`the~`White~`Tiger^t^N2^T^SEnabled^B^SScript^Stoggle.storm&(active_dot.storm_earth_and_fire_target<1)^SArgs^Starget=2^SAbility^Sstorm_earth_and_fire^SIndicator^Scycle^SRelease^F6923701033084388^f-35^SName^SStorm,~`Earth,~`and~`Fire^t^N3^T^SEnabled^B^SScript^Stoggle.storm&(active_dot.storm_earth_and_fire_target<2)^SArgs^Starget=3^SAbility^Sstorm_earth_and_fire^SIndicator^Scycle^SRelease^F6923701033084388^f-35^SName^SStorm,~`Earth,~`and~`Fire~`(1)^t^N4^T^SEnabled^B^SScript^Stalent.serenity.enabled&talent.chi_brew.enabled&cooldown.fists_of_fury.up&time<20^SArgs^Sname="WW:~`Opener"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCall~`Action~`List^t^N5^T^SEnabled^B^SScript^Stoggle.cooldowns&(buff.serenity.up|(!talent.serenity.enabled&(trinket.proc.agility.up|trinket.proc.multistrike.up))|buff.bloodlust.up|target.time_to_die<=60)^SArgs^Sname=draenic_agility^SAbility^Spotion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPotion^t^N6^T^SEnabled^B^SScript^Stoggle.cooldowns&(buff.tigereye_brew_use.up|target.time_to_die<18)^SAbility^Sblood_fury^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlood~`Fury^t^N7^T^SEnabled^B^SScript^Stoggle.cooldowns&(buff.tigereye_brew_use.up|target.time_to_die<18)^SAbility^Sberserking^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBerserking^t^N8^T^SEnabled^B^SScript^Stoggle.cooldowns&(chi.max-chi.current>=1&(buff.tigereye_brew_use.up|target.time_to_die<18))^SAbility^Sarcane_torrent^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SArcane~`Torrent^t^N9^T^SEnabled^B^SScript^Schi.max-chi.current>=2&((charges=1&recharge_time<=10)|charges=2|target.time_to_die<charges*10)&buff.tigereye_brew.stack<=16^SAbility^Schi_brew^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Brew^t^N10^T^SEnabled^B^SScript^S!talent.chi_explosion.enabled&buff.tiger_power.remains<6.6^SAbility^Stiger_palm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STiger~`Palm^t^N11^T^SEnabled^B^SScript^Stalent.chi_explosion.enabled&(cooldown.fists_of_fury.remains<5|cooldown.fists_of_fury.up)&buff.tiger_power.remains<5^SAbility^Stiger_palm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STiger~`Palm~`(1)^t^N12^T^SEnabled^B^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack=20^SAbility^Stigereye_brew^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STigereye~`Brew^t^N13^T^SEnabled^B^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack>=9&buff.serenity.up^SAbility^Stigereye_brew^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STigereye~`Brew~`(1)^t^N14^T^SEnabled^B^SScript^Stalent.chi_explosion.enabled&buff.tigereye_brew.stack>=1&t18_class_trinket&set_bonus.tier18_4pc=1&buff.tigereye_brew_use.down^SAbility^Stigereye_brew^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STigereye~`Brew~`(2)^t^N15^T^SEnabled^B^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack>=9&cooldown.fists_of_fury.up&chi.current>=3&debuff.rising_sun_kick.up&buff.tiger_power.up^SAbility^Stigereye_brew^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STigereye~`Brew~`(3)^t^N16^T^SEnabled^B^SScript^Stalent.hurricane_strike.enabled&buff.tigereye_brew_use.down&buff.tigereye_brew.stack>=9&cooldown.hurricane_strike.up&chi.current>=3&debuff.rising_sun_kick.up&buff.tiger_power.up^SAbility^Stigereye_brew^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STigereye~`Brew~`(4)^t^N17^T^SEnabled^B^SScript^Sbuff.tigereye_brew_use.down&chi.current>=2&(buff.tigereye_brew.stack>=16|target.time_to_die<40)&debuff.rising_sun_kick.up&buff.tiger_power.up^SAbility^Stigereye_brew^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STigereye~`Brew~`(5)^t^N18^T^SEnabled^B^SScript^Starget.health.percent<10&cooldown.touch_of_death.remains=0&(glyph.touch_of_death.enabled|chi.current>=3)^SAbility^Sfortifying_brew^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SFortifying~`Brew^t^N19^T^SEnabled^B^SScript^Starget.health.percent<10&(glyph.touch_of_death.enabled|chi.current>=3)^SAbility^Stouch_of_death^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STouch~`of~`Death^t^N20^T^SEnabled^B^SScript^S(debuff.rising_sun_kick.down|debuff.rising_sun_kick.remains<3)^SAbility^Srising_sun_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SRising~`Sun~`Kick^t^N21^T^SEnabled^B^SScript^Stoggle.cooldowns&(chi.current>=2&buff.tiger_power.up&debuff.rising_sun_kick.up)^SAbility^Sserenity^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SSerenity^t^N22^T^SEnabled^B^SScript^Sbuff.tiger_power.remains>cast_time&debuff.rising_sun_kick.remains>cast_time&!buff.serenity.up^SAbility^Sfists_of_fury^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SFists~`of~`Fury^t^N23^T^SEnabled^B^SScript^Senergy.time_to_max>cast_time&buff.tiger_power.remains>cast_time&debuff.rising_sun_kick.remains>cast_time&buff.energizing_brew.down^SAbility^Shurricane_strike^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SHurricane~`Strike^t^N24^T^SEnabled^B^SScript^Scooldown.fists_of_fury.remains>6&(!talent.serenity.enabled|(!buff.serenity.up&cooldown.serenity.remains>4))&energy.current+energy.regen<50^SAbility^Senergizing_brew^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SEnergizing~`Brew^t^N25^T^SEnabled^B^SScript^Smy_enemies<3&(level<100|!talent.chi_explosion.enabled)^SArgs^Sname="WW:~`ST"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCall~`Action~`List~`(1)^t^N26^T^SEnabled^B^SScript^Smy_enemies=1&talent.chi_explosion.enabled^SArgs^Sname="WW:~`ST~`ChiX"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCall~`Action~`List~`(2)^t^N27^T^SEnabled^B^SScript^S(my_enemies=2|my_enemies=3&!talent.rushing_jade_wind.enabled)&talent.chi_explosion.enabled^SArgs^Sname="WW:~`Cleave~`ChiX"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCall~`Action~`List~`(3)^t^N28^T^SEnabled^B^SScript^Smy_enemies>=3&!talent.rushing_jade_wind.enabled&!talent.chi_explosion.enabled^SArgs^Sname="WW:~`AOE~`NoRJW"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCall~`Action~`List~`(4)^t^N29^T^SEnabled^B^SScript^Smy_enemies>=4&!talent.rushing_jade_wind.enabled&talent.chi_explosion.enabled^SArgs^Sname="WW:~`AOE~`NoRJW~`ChiX"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCall~`Action~`List~`(5)^t^N30^T^SEnabled^B^SScript^Smy_enemies>=3&talent.rushing_jade_wind.enabled^SArgs^Sname="WW:~`AOE~`RJW"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCall~`Action~`List~`(6)^t^N31^T^SEnabled^B^SScript^Sbuff.combo_breaker_tp.up^SAbility^Stiger_palm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STiger~`Palm~`(2)^t^t^SName^SWW:~`Default^t^^]] )

    storeDefault( 'WW: Opener', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N20150914.1^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SScript^Sbuff.tigereye_brew_use.down&buff.tigereye_brew.stack>=9^SAbility^Stigereye_brew^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STigereye~`Brew^t^N2^T^SEnabled^B^SScript^Stoggle.cooldowns&(buff.tigereye_brew_use.up)^SAbility^Sblood_fury^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlood~`Fury^t^N3^T^SEnabled^B^SScript^Stoggle.cooldowns&(buff.tigereye_brew_use.up)^SAbility^Sberserking^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBerserking^t^N4^T^SEnabled^B^SScript^Stoggle.cooldowns&(buff.tigereye_brew_use.up&chi.max-chi.current>=1)^SAbility^Sarcane_torrent^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SArcane~`Torrent^t^N5^T^SEnabled^B^SScript^Sbuff.tiger_power.remains>cast_time&debuff.rising_sun_kick.remains>cast_time&buff.serenity.up&buff.serenity.remains<1.5^SAbility^Sfists_of_fury^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SFists~`of~`Fury^t^N6^T^SEnabled^B^SScript^Sbuff.tiger_power.remains<2^SAbility^Stiger_palm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STiger~`Palm^t^N7^T^SEnabled^B^SName^SRising~`Sun~`Kick^SAbility^Srising_sun_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N8^T^SEnabled^B^SScript^Schi.max-chi.current<=1&cooldown.chi_brew.up|buff.serenity.up^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlackout~`Kick^t^N9^T^SEnabled^B^SScript^Schi.max-chi.current>=2^SAbility^Schi_brew^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Brew^t^N10^T^SEnabled^B^SScript^Stoggle.cooldowns&(chi.max-chi.current<=2)^SAbility^Sserenity^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SSerenity^t^N11^T^SEnabled^B^SScript^Schi.max-chi.current>=2&!buff.serenity.up^SAbility^Sjab^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SJab^t^t^SName^SWW:~`Opener^t^^]] )

    storeDefault( 'WW: ST', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N20150914.1^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SScript^Sset_bonus.tier18_2pc=1&buff.combo_breaker_bok.up^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlackout~`Kick^t^N2^T^SEnabled^B^SScript^Sset_bonus.tier18_2pc=1&buff.combo_breaker_tp.up&buff.combo_breaker_tp.remains<=2^SAbility^Stiger_palm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STiger~`Palm^t^N3^T^SEnabled^B^SName^SRising~`Sun~`Kick^SAbility^Srising_sun_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N4^T^SEnabled^B^SScript^Sbuff.combo_breaker_bok.up|buff.serenity.up^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlackout~`Kick~`(1)^t^N5^T^SEnabled^B^SScript^Sbuff.combo_breaker_tp.up&buff.combo_breaker_tp.remains<=2^SAbility^Stiger_palm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STiger~`Palm~`(1)^t^N6^T^SEnabled^B^SScript^Senergy.time_to_max>2&buff.serenity.down^SAbility^Schi_wave^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Wave^t^N7^T^SEnabled^B^SScript^Senergy.time_to_max>2&buff.serenity.down^SAbility^Schi_burst^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Burst^t^N8^T^SEnabled^B^SScript^Senergy.time_to_max>2&!dot.zen_sphere.ticking&buff.serenity.down^SArgs^S^SAbility^Szen_sphere^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere^t^N9^T^SEnabled^B^SScript^Sgroup&(energy.time_to_max>2&!active_dot.zen_sphere>=group_members&buff.serenity.down)^SArgs^Scycle_targets=1^SAbility^Szen_sphere^SIndicator^Scycle^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere~`(1)^t^N10^T^SEnabled^B^SScript^Senergy.time_to_max>2&buff.serenity.down&(((charges=2|(charges=1&recharge_time<=4))&!talent.celerity.enabled)|((charges=3|(charges=2&recharge_time<=4))&talent.celerity.enabled))^SAbility^Schi_torpedo^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Torpedo^t^N11^T^SEnabled^B^SScript^Schi.max-chi.current<2^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlackout~`Kick~`(2)^t^N12^T^SEnabled^B^SScript^Schi.max-chi.current>=2&health.percent<95^SAbility^Sexpel_harm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExpel~`Harm^t^N13^T^SEnabled^B^SScript^Schi.max-chi.current>=2^SAbility^Sjab^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SJab^t^t^SName^SWW:~`ST^t^^]] )

    storeDefault( 'WW: ST ChiX', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N20150914.1^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SScript^Schi.current>=2&buff.combo_breaker_ce.up&cooldown.fists_of_fury.remains>2^SAbility^Schi_explosion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Explosion^t^N2^T^SEnabled^B^SScript^Sbuff.combo_breaker_tp.up&buff.combo_breaker_tp.remains<=2^SAbility^Stiger_palm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STiger~`Palm^t^N3^T^SEnabled^B^SName^SRising~`Sun~`Kick^SAbility^Srising_sun_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N4^T^SEnabled^B^SScript^Senergy.time_to_max>2^SAbility^Schi_wave^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Wave^t^N5^T^SEnabled^B^SScript^Senergy.time_to_max>2^SAbility^Schi_burst^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Burst^t^N6^T^SEnabled^B^SScript^Senergy.time_to_max>2&!dot.zen_sphere.ticking^SArgs^S^SAbility^Szen_sphere^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere^t^N7^T^SEnabled^B^SScript^Sgroup&(energy.time_to_max>2&!active_dot.zen_sphere>=group_members)^SArgs^Scycle_targets=1^SAbility^Szen_sphere^SIndicator^Scycle^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere~`(1)^t^N8^T^SEnabled^B^SScript^Schi.max-chi.current>=2&health.percent<95^SAbility^Sexpel_harm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExpel~`Harm^t^N9^T^SEnabled^B^SScript^Schi.max-chi.current>=2^SAbility^Sjab^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SJab^t^N10^T^SEnabled^B^SScript^Schi.current>=5&cooldown.fists_of_fury.remains>4^SAbility^Schi_explosion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Explosion~`(1)^t^N11^T^SEnabled^B^SScript^Senergy.time_to_max>2&(((charges=2|(charges=1&recharge_time<=4))&!talent.celerity.enabled)|((charges=3|(charges=2&recharge_time<=4))&talent.celerity.enabled))^SAbility^Schi_torpedo^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Torpedo^t^N12^T^SEnabled^B^SScript^Schi.current=4&!buff.combo_breaker_tp.up^SAbility^Stiger_palm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STiger~`Palm~`(1)^t^t^SName^SWW:~`ST~`ChiX^t^^]] )

    storeDefault( 'WW: Cleave ChiX', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N20150914.1^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SScript^Schi.current>=4&cooldown.fists_of_fury.remains>2^SAbility^Schi_explosion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Explosion^t^N2^T^SEnabled^B^SScript^Sbuff.combo_breaker_tp.up&buff.combo_breaker_tp.remains<=2^SAbility^Stiger_palm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STiger~`Palm^t^N3^T^SEnabled^B^SScript^Senergy.time_to_max>2^SAbility^Schi_wave^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Wave^t^N4^T^SEnabled^B^SScript^Senergy.time_to_max>2^SAbility^Schi_burst^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Burst^t^N5^T^SEnabled^B^SScript^Senergy.time_to_max>2&!dot.zen_sphere.ticking^SArgs^S^SAbility^Szen_sphere^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere^t^N6^T^SEnabled^B^SScript^Sgroup&(energy.time_to_max>2&!active_dot.zen_sphere>=group_members)^SArgs^Scycle_targets=1^SAbility^Szen_sphere^SIndicator^Scycle^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere~`(1)^t^N7^T^SEnabled^B^SScript^Senergy.time_to_max>2&(((charges=2|(charges=1&recharge_time<=4))&!talent.celerity.enabled)|((charges=3|(charges=2&recharge_time<=4))&talent.celerity.enabled))^SAbility^Schi_torpedo^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Torpedo^t^N8^T^SEnabled^B^SScript^Schi.max-chi.current>=2&health.percent<95^SAbility^Sexpel_harm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExpel~`Harm^t^N9^T^SEnabled^B^SScript^Schi.max-chi.current>=2^SAbility^Sjab^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SJab^t^t^SName^SWW:~`Cleave~`ChiX^t^^]] )

    storeDefault( 'WW: AOE NoRJW', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N20150914.1^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SScript^Senergy.time_to_max>2&buff.serenity.down^SAbility^Schi_wave^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Wave^t^N2^T^SEnabled^B^SScript^Senergy.time_to_max>2&buff.serenity.down^SAbility^Schi_burst^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Burst^t^N3^T^SEnabled^B^SScript^Senergy.time_to_max>2&!dot.zen_sphere.ticking&buff.serenity.down^SArgs^S^SAbility^Szen_sphere^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere^t^N4^T^SEnabled^B^SScript^Sgroup&(energy.time_to_max>2&!active_dot.zen_sphere>=group_members&buff.serenity.down)^SArgs^Scycle_targets=1^SAbility^Szen_sphere^SIndicator^Scycle^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere~`(1)^t^N5^T^SEnabled^B^SScript^Sbuff.combo_breaker_bok.up|buff.serenity.up^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlackout~`Kick^t^N6^T^SEnabled^B^SScript^Sbuff.combo_breaker_tp.up&buff.combo_breaker_tp.remains<=2^SAbility^Stiger_palm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STiger~`Palm^t^N7^T^SEnabled^B^SScript^Schi.max-chi.current<2&cooldown.fists_of_fury.remains>3^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlackout~`Kick~`(1)^t^N8^T^SEnabled^B^SScript^Senergy.time_to_max>2&(((charges=2|(charges=1&recharge_time<=4))&!talent.celerity.enabled)|((charges=3|(charges=2&recharge_time<=4))&talent.celerity.enabled))^SAbility^Schi_torpedo^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Torpedo^t^N9^T^SEnabled^B^SName^SSpinning~`Crane~`Kick^SAbility^Sspinning_crane_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^t^SName^SWW:~`AOE~`NoRJW^t^^]] )

    storeDefault( 'WW: AOE NoRJW ChiX', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N20150914.1^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SScript^Schi.current>=4&cooldown.fists_of_fury.remains>4^SAbility^Schi_explosion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Explosion^t^N2^T^SEnabled^B^SScript^Schi.current=chi.max^SAbility^Srising_sun_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SRising~`Sun~`Kick^t^N3^T^SEnabled^B^SScript^Senergy.time_to_max>2^SAbility^Schi_wave^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Wave^t^N4^T^SEnabled^B^SScript^Senergy.time_to_max>2^SAbility^Schi_burst^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Burst^t^N5^T^SEnabled^B^SScript^Senergy.time_to_max>2&!dot.zen_sphere.ticking^SArgs^S^SAbility^Szen_sphere^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere^t^N6^T^SEnabled^B^SScript^Sgroup&(energy.time_to_max>2&!active_dot.zen_sphere>=group_members)^SArgs^Scycle_targets=1^SAbility^Szen_sphere^SIndicator^Scycle^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere~`(1)^t^N7^T^SEnabled^B^SScript^Senergy.time_to_max>2&(((charges=2|(charges=1&recharge_time<=4))&!talent.celerity.enabled)|((charges=3|(charges=2&recharge_time<=4))&talent.celerity.enabled))^SAbility^Schi_torpedo^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Torpedo^t^N8^T^SEnabled^B^SName^SSpinning~`Crane~`Kick^SAbility^Sspinning_crane_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^t^SName^SWW:~`AOE~`NoRJW~`ChiX^t^^]] )

    storeDefault( 'WW: AOE RJW', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N20150914.1^SSpecialization^N269^SActions^T^N1^T^SEnabled^B^SScript^Schi.current>=4&cooldown.fists_of_fury.remains>4^SAbility^Schi_explosion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Explosion^t^N2^T^SEnabled^B^SName^SRushing~`Jade~`Wind^SAbility^Srushing_jade_wind^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N3^T^SEnabled^B^SScript^Senergy.time_to_max>2&buff.serenity.down^SAbility^Schi_wave^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Wave^t^N4^T^SEnabled^B^SScript^Senergy.time_to_max>2&buff.serenity.down^SAbility^Schi_burst^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Burst^t^N5^T^SEnabled^B^SScript^Senergy.time_to_max>2&!dot.zen_sphere.ticking&buff.serenity.down^SArgs^S^SAbility^Szen_sphere^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere^t^N6^T^SEnabled^B^SScript^Sgroup&(energy.time_to_max>2&!active_dot.zen_sphere>=group_members&buff.serenity.down)^SArgs^Scycle_targets=1^SAbility^Szen_sphere^SIndicator^Scycle^SRelease^F6923701033084388^f-35^SName^SZen~`Sphere~`(1)^t^N7^T^SEnabled^B^SScript^Sbuff.combo_breaker_bok.up|buff.serenity.up^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlackout~`Kick^t^N8^T^SEnabled^B^SScript^Sbuff.combo_breaker_tp.up&buff.combo_breaker_tp.remains<=2^SAbility^Stiger_palm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^STiger~`Palm^t^N9^T^SEnabled^B^SScript^Schi.max-chi.current<2&cooldown.fists_of_fury.remains>3^SAbility^Sblackout_kick^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlackout~`Kick~`(1)^t^N10^T^SEnabled^B^SScript^Senergy.time_to_max>2&(((charges=2|(charges=1&recharge_time<=4))&!talent.celerity.enabled)|((charges=3|(charges=2&recharge_time<=4))&talent.celerity.enabled))^SAbility^Schi_torpedo^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SChi~`Torpedo^t^N11^T^SEnabled^B^SScript^Schi.max-chi.current>=2&health.percent<95^SAbility^Sexpel_harm^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExpel~`Harm^t^N12^T^SEnabled^B^SScript^Schi.max-chi.current>=2^SAbility^Sjab^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SJab^t^t^SName^SWW:~`AOE~`RJW^t^^]] )

    storeDefault( 'MW: Default', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SName^SMW:~`Default^SDefault^B^SRelease^N20150914.1^SSpecialization^N270^SActions^T^N1^T^SEnabled^B^SScript^Stime=0&!buff.str_agi_int.up^SRelease^N201506.141^SIndicator^Snone^SAbility^Slegacy_of_the_emperor^SName^SLegacy~`of~`the~`Emperor^t^N2^T^SEnabled^B^SScript^Stoggle.interrupts^SRelease^N201506.141^SIndicator^Snone^SAbility^Sspear_hand_strike^SName^SSpear~`Hand~`Strike^t^N3^T^SEnabled^B^SScript^Stoggle.cooldowns^SRelease^N2.06^SName^SInvoke~`Xuen^SAbility^Sinvoke_xuen^SCaption^S^t^N4^T^SEnabled^B^SName^SBreath~`of~`the~`Serpent^SRelease^N2.06^SAbility^Sbreath_of_the_serpent^SScript^Stoggle.cooldowns^t^N5^T^SEnabled^B^SName^SSurging~`Mist^SRelease^N2.06^SCaption^S^SScript^S(health.pct<101|group)&buff.vital_mists.stack=5^SAbility^Ssurging_mist^t^N6^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SAbility^Schi_brew^SScript^Schi.max-chi.current>=2&((charges=1&recharge_time<=10)|charges=2|target.time_to_die<charges*10)&buff.mana_tea_stacks.stacks<=19^t^N7^T^SEnabled^B^SScript^S!group^SArgs^Sname="MW:~`Crane~`Solo"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^N201505.311^SName^SCall~`Action~`List^t^N8^T^SEnabled^B^SScript^S!talent.chi_explosion.enabled|toggle.optimize_dps^SArgs^Sname="MW:~`Crane~`NoChiX"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^N201505.311^SName^SCall~`Action~`List~`(1)^t^N9^T^SEnabled^B^SScript^Stalent.chi_explosion.enabled&!toggle.optimize_dps^SArgs^Sname="MW:~`Crane~`ChiX"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^N201505.311^SName^SCall~`Action~`List~`(2)^t^t^SScript^S^t^^]] )

    storeDefault( 'MW: Crane NoChiX', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SName^SMW:~`Crane~`NoChiX^SDefault^B^SRelease^N20150914.1^SSpecialization^N270^SActions^T^N1^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.06^SScript^Sbuff.tiger_power.remains<=3^SAbility^Stiger_palm^t^N2^T^SEnabled^B^SName^SRising~`Sun~`Kick^SAbility^Srising_sun_kick^SRelease^N2.06^SScript^S(debuff.rising_sun_kick.down|debuff.rising_sun_kick.remains<3)|(cooldown.rising_sun_kick.charges>1)^t^N3^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.06^SScript^Sbuff.cranes_zeal.down^SAbility^Sblackout_kick^t^N4^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.06^SAbility^Stiger_palm^SCaption^S^SScript^Sbuff.tiger_power.down&debuff.rising_sun_kick.remains>1^t^N5^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.06^SScript^S^SCaption^S^SAbility^Schi_wave^t^N6^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.06^SScript^S^SCaption^S^SAbility^Schi_burst^t^N7^T^SEnabled^B^SScript^S!buff.zen_sphere.up^SCaption^S^SAbility^Szen_sphere^SIndicator^Snone^SName^SZen~`Sphere^SRelease^N2.06^t^N8^T^SEnabled^B^SScript^Sgroup&buff.zen_sphere.up&active_dot.zen_sphere<2^SAbility^Szen_sphere^SIndicator^Scycle^SName^SZen~`Sphere~`(2)^SRelease^N201505.311^t^N9^T^SEnabled^B^SScript^Stalent.chi_explosion.enabled&chi.current>=4^SAbility^Schi_explosion^SIndicator^Snone^SName^SChi~`Explosion^SRelease^N201506.141^t^N10^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S!talent.chi_explosion.enabled&chi.max-chi.current<2^t^N11^T^SEnabled^B^SName^SSpinning~`Crane~`Kick^SRelease^N2.06^SAbility^Sspinning_crane_kick^SScript^S!talent.rushing_jade_wind.enabled&my_enemies>=3&chi.current<chi.max^t^N12^T^SEnabled^B^SScript^Schi.max-chi.current>=4&cooldown.rising_sun_kick.charges>=2&buff.mana_tea_stacks.stack>=10&mana.pct>=settings.cjl_threshold^SAbility^Scrackling_jade_lightning^SIndicator^Snone^SName^SCrackling~`Jade~`Lightning^SRelease^N201505.311^t^N13^T^SEnabled^B^SName^SJab^SRelease^N2.06^SAbility^Sjab^SScript^Schi.current<chi.max^t^N14^T^SEnabled^B^SName^SBlackout~`Kick~`(Filler)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S^t^t^SScript^S^t^^]] )

    storeDefault( 'MW: Crane ChiX', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SScript^S^SRelease^N20150914.1^SSpecialization^N270^SActions^T^N1^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.06^SAbility^Schi_wave^SCaption^S^SScript^S^t^N2^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.06^SAbility^Schi_burst^SCaption^S^SScript^S^t^N3^T^SEnabled^B^SScript^S!buff.zen_sphere.up^SRelease^N2.06^SCaption^S^SIndicator^Snone^SName^SZen~`Sphere^SAbility^Szen_sphere^t^N4^T^SEnabled^B^SScript^Sgroup&buff.zen_sphere.up&active_dot.zen_sphere<2^SAbility^Szen_sphere^SIndicator^Scycle^SRelease^N201505.311^SName^SZen~`Sphere~`(2)^t^N5^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.06^SAbility^Schi_explosion^SScript^S(!group&(chi.current>=2|health.pct=100))|chi.current>=4^t^N6^T^SEnabled^B^SScript^S!group&health.pct=100^SAbility^Schi_explosion^SIndicator^Snone^SRelease^N201505.311^SName^SChi~`Explosion~`(1)^t^N7^T^SEnabled^B^SName^SSpinning~`Crane~`Kick^SRelease^N2.06^SScript^S!talent.rushing_jade_wind.enabled&my_enemies>=3&chi.current<chi.max^SAbility^Sspinning_crane_kick^t^N8^T^SEnabled^B^SScript^Schi.max-chi.current>=4&cooldown.rising_sun_kick.charges>=2&buff.mana_tea_stacks.stack>=10&mana.pct>=settings.cjl_threshold^SAbility^Scrackling_jade_lightning^SIndicator^Snone^SRelease^N201505.311^SName^SCrackling~`Jade~`Lightning^t^N9^T^SEnabled^B^SName^SJab^SRelease^N2.06^SScript^Schi.current<chi.max^SAbility^Sjab^t^t^SName^SMW:~`Crane~`ChiX^t^^]] )

    storeDefault( 'MW: Crane Solo', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SName^SMW:~`Crane~`Solo^SDefault^B^SRelease^N20150914.1^SSpecialization^N270^SActions^T^N1^T^SEnabled^B^SScript^Stoggle.cooldowns^SRelease^N2.06^SName^SInvoke~`Xuen^SAbility^Sinvoke_xuen^SCaption^S^t^N2^T^SEnabled^B^SName^SBreath~`of~`the~`Serpent^SRelease^N2.06^SAbility^Sbreath_of_the_serpent^SScript^Stoggle.cooldowns^t^N3^T^SEnabled^B^SName^SSurging~`Mist^SRelease^N2.06^SCaption^S^SScript^S(health.pct<100|group)&buff.vital_mists.stack=5^SAbility^Ssurging_mist^t^N4^T^SEnabled^B^SName^SChi~`Brew^SRelease^N2.06^SAbility^Schi_brew^SScript^Schi.max-chi.current>=2&((charges=1&recharge_time<=10)|charges=2|target.time_to_die<charges*10)&buff.mana_tea_stacks.stacks<=19^t^N5^T^SEnabled^B^SName^STiger~`Palm^SRelease^N2.06^SScript^Sbuff.tiger_power.remains<=3^SAbility^Stiger_palm^t^N6^T^SEnabled^B^SName^SRising~`Sun~`Kick^SAbility^Srising_sun_kick^SRelease^N2.06^SScript^Sdebuff.rising_sun_kick.down|debuff.rising_sun_kick.remains<3|cooldown.rising_sun_kick.charges>1^t^N7^T^SEnabled^B^SName^SBlackout~`Kick^SRelease^N2.06^SScript^Sbuff.cranes_zeal.down^SAbility^Sblackout_kick^t^N8^T^SEnabled^B^SName^STiger~`Palm~`(1)^SRelease^N2.06^SAbility^Stiger_palm^SCaption^S^SScript^Sbuff.tiger_power.down&debuff.rising_sun_kick.remains>1^t^N9^T^SEnabled^B^SName^SChi~`Wave^SRelease^N2.06^SScript^S^SCaption^S^SAbility^Schi_wave^t^N10^T^SEnabled^B^SName^SChi~`Burst^SRelease^N2.06^SScript^S^SCaption^S^SAbility^Schi_burst^t^N11^T^SEnabled^B^SScript^S!buff.zen_sphere.up^SRelease^N2.06^SCaption^S^SIndicator^Snone^SName^SZen~`Sphere^SAbility^Szen_sphere^t^N12^T^SEnabled^B^SScript^Sgroup&buff.zen_sphere.up&active_dot.zen_sphere<2^SAbility^Szen_sphere^SIndicator^Scycle^SName^SZen~`Sphere~`(2)^SRelease^N201505.311^t^N13^T^SEnabled^B^SName^SChi~`Explosion^SRelease^N2.06^SScript^S((debuff.rising_sun_kick.remains>=3&health.pct>90&chi.current=1)|chi.current>=2)&buff.combo_breaker_ce.react^SAbility^Schi_explosion^t^N14^T^SEnabled^B^SName^SBlackout~`Kick~`(1)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S!talent.chi_explosion.enabled&chi.max-chi.current<2^t^N15^T^SEnabled^B^SName^SChi~`Explosion~`(1)^SRelease^N2.06^SAbility^Schi_explosion^SScript^S((debuff.rising_sun_kick.remains>=3&health.pct>90&chi.current=1)|chi.current>=2)^t^N16^T^SEnabled^B^SName^SSpinning~`Crane~`Kick^SRelease^N2.06^SAbility^Sspinning_crane_kick^SScript^S!talent.rushing_jade_wind.enabled&my_enemies>=3&chi.current<chi.max^t^N17^T^SEnabled^B^SName^SJab^SRelease^N2.06^SAbility^Sjab^SScript^Schi.current<chi.max^t^N18^T^SEnabled^B^SName^SBlackout~`Kick~`(Filler)^SRelease^N2.06^SAbility^Sblackout_kick^SScript^S^t^t^SScript^S^t^^]] )


    storeDefault( 'BM: Primary', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPvP~`-~`Target^b^SPrimary~`Caption~`Aura^SElusive~`Brew^Srel^SCENTER^SUse~`SpellFlash^b^SPvE~`-~`Target^b^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SBM:~`Precombat^SName^SBM:~`Precombat^SRelease^N201506.221^SScript^Stime=0^t^N2^T^SEnabled^B^SAction~`List^SBM:~`Default^SName^SBM:~`Default^SRelease^N201506.221^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^N-270^SAOE~`-~`Maximum^N0^SRelease^N20150914.1^SRange~`Checking^Sability^SPvE~`-~`Combat~`Alpha^N1^SPvP~`-~`Target~`Alpha^N1^SPvP~`-~`Combat~`Alpha^N1^SPrimary~`Caption^Sbuff^SAction~`Captions^B^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SSpecialization^N268^Sx^N0^SQueue~`Direction^SRIGHT^SPrimary~`Font~`Size^N12^SQueued~`Icon~`Size^N40^SPrimary~`Icon~`Size^N40^SEnabled^B^SName^SBM:~`Primary^SFont^SArial~`Narrow^SAOE~`-~`Minimum^N0^SIcons~`Shown^N4^STalent~`Group^N0^SSingle~`-~`Maximum^N1^SSingle~`-~`Minimum^N0^SSpacing^N5^SPvE~`-~`Target~`Alpha^N1^SAuto~`-~`Minimum^N0^SAuto~`-~`Maximum^N0^SDefault^B^SCopy~`To^SBM:~`AOE^SPvE~`-~`Default~`Alpha^N1^SScript^S^t^^]] )

    storeDefault( 'BM: AOE', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SUse~`SpellFlash^b^SPvE~`-~`Target^b^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SBM:~`Precombat^SName^SBM:~`Precombat^SRelease^N201505.311^SScript^Stime=0^t^N2^T^SEnabled^B^SAction~`List^SBM:~`Default^SName^SBM:~`Default^SRelease^N201505.311^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^N-225^Sx^N0^SPrimary~`Caption^Stargets^SRange~`Checking^Sability^SPvE~`-~`Combat~`Alpha^N1^SPvP~`-~`Target~`Alpha^N1^SPvP~`-~`Combat~`Alpha^N1^SScript^S^SPvE~`-~`Default~`Alpha^N1^SSpellFlash~`Color^T^Sa^N1^Sb^N1^Sg^N1^Sr^N1^t^SCopy~`To^SBM:~`AOE^SSpecialization^N268^SQueue~`Direction^SRIGHT^SSingle~`-~`Minimum^N3^SQueued~`Icon~`Size^N40^SDefault^B^SEnabled^B^SAuto~`-~`Minimum^N3^SPvE~`-~`Target~`Alpha^N1^SAOE~`-~`Minimum^N3^SSpacing^N5^SAuto~`-~`Maximum^N0^SSingle~`-~`Maximum^N0^STalent~`Group^N0^SIcons~`Shown^N4^SFont^SArial~`Narrow^SName^SBM:~`AOE^SPrimary~`Icon~`Size^N40^SPvP~`-~`Target^b^SRelease^N20150914.1^SAction~`Captions^B^SAOE~`-~`Maximum^N0^t^^]] )

    storeDefault( 'WW: Primary', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPvP~`-~`Target^b^SPrimary~`Caption~`Aura^STigereye~`Brew^Srel^SCENTER^SUse~`SpellFlash^b^SPvE~`-~`Target^b^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SWW:~`Precombat^SName^SWW:~`Precombat^SRelease^N201506.221^SScript^Stime=0^t^N2^T^SEnabled^B^SAction~`List^SWW:~`Default^SName^SWW:~`Default^SRelease^N201506.221^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^F-4749890768863230^f-44^Sx^N0^SRelease^N20150914.1^SRange~`Checking^Sability^SPvE~`-~`Combat~`Alpha^N1^SPvP~`-~`Target~`Alpha^N1^SPvP~`-~`Combat~`Alpha^N1^SAOE~`-~`Maximum^N0^SAction~`Captions^B^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SSpecialization^N269^SCopy~`To^SWW:~`AOE^SQueue~`Direction^SRIGHT^SPrimary~`Font~`Size^N12^SQueued~`Icon~`Size^N40^SPrimary~`Icon~`Size^N40^SEnabled^B^SName^SWW:~`Primary^SFont^SElvUI~`Font^SAOE~`-~`Minimum^N3^SPrimary~`Caption^Sbuff^SIcons~`Shown^N4^STalent~`Group^N0^SSingle~`-~`Maximum^N1^SSpacing^N5^SPvE~`-~`Target~`Alpha^N1^SDefault^B^SAuto~`-~`Maximum^N0^SSingle~`-~`Minimum^N0^SAuto~`-~`Minimum^N0^SPvE~`-~`Default~`Alpha^N1^SScript^S^t^^]] )

    storeDefault( 'WW: AOE', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^SStorm,~`Earth,~`and~`Fire^Srel^SCENTER^SUse~`SpellFlash^b^SPvE~`-~`Target^b^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SWW:~`Precombat^SName^SWW:~`Precombat^SRelease^N201505.311^SScript^Stime=0^t^N2^T^SEnabled^B^SAction~`List^SWW:~`Default^SName^SWW:~`Default^SRelease^N201505.311^t^t^SScript^S^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^N-225^SAOE~`-~`Maximum^N0^SRelease^N20150914.1^SRange~`Checking^Sability^SAuto~`-~`Maximum^N0^SPvP~`-~`Target~`Alpha^N1^SSingle~`-~`Minimum^N3^SPvP~`-~`Default~`Alpha^N1^SPvE~`-~`Default~`Alpha^N1^SSpellFlash~`Color^T^Sa^N1^Sb^N1^Sg^N1^Sr^N1^t^SCopy~`To^SWW:~`AOE^SPvP~`-~`Combat~`Alpha^N1^SQueue~`Direction^SRIGHT^SPvE~`-~`Combat~`Alpha^N1^SQueued~`Icon~`Size^N40^SAuto~`-~`Minimum^N3^SEnabled^B^SDefault^B^SPvE~`-~`Target~`Alpha^N1^SAOE~`-~`Minimum^N3^SSpacing^N5^SSingle~`-~`Maximum^N0^STalent~`Group^N0^SIcons~`Shown^N4^SPrimary~`Caption^Stargets^SFont^SElvUI~`Font^SName^SWW:~`AOE^SPrimary~`Icon~`Size^N40^SPvP~`-~`Target^b^Sx^N0^SAction~`Captions^B^SSpecialization^N269^t^^]] )

    storeDefault( 'MW: Primary', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^SVital~`Mists^Srel^SCENTER^SPvE~`-~`Target^b^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SMW:~`Default^SName^SMW:~`Default^SRelease^N201505.311^SScript^Sstance.spirited_crane^t^t^SScript^Sstance.spirited_crane^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^N-270^Sx^N0^SPvP~`Visibility^Salways^SRelease^N20150914.1^SRange~`Checking^Sability^SPvE~`-~`Combat~`Alpha^N1^SPvP~`-~`Target~`Alpha^N1^SSingle~`-~`Maximum^N1^SPvP~`-~`Default~`Alpha^N1^SPvE~`-~`Default~`Alpha^N1^SSpacing^N5^SPvP~`-~`Target^b^SSpellFlash~`Color^T^Sa^N1^Sb^N1^Sg^N1^Sr^N1^t^SSpecialization^N270^SPrimary~`Icon~`Size^N40^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SDefault^B^SEnabled^B^SPvE~`-~`Target~`Alpha^N1^SAOE~`-~`Maximum^N0^SAOE~`-~`Minimum^N3^SIcons~`Shown^N4^SPrimary~`Caption^Sbuff^SName^SMW:~`Primary^SSingle~`-~`Minimum^N0^SCopy~`To^SMW:~`AOE^SFont^SElvUI~`Font^SAuto~`-~`Minimum^N0^SAuto~`-~`Maximum^N0^SPvP~`-~`Combat~`Alpha^N1^STalent~`Group^N0^SAction~`Captions^B^SForce~`Targets^N1^t^^]] )

    storeDefault( 'MW: AOE', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPvP~`-~`Target^b^SPrimary~`Caption~`Aura^SVital~`Mists^Srel^SCENTER^SSpacing^N5^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SMW:~`Default^SName^SMW:~`Default^SRelease^N201505.311^SScript^Sstance.spirited_crane^t^t^SScript^Sstance.spirited_crane^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^N-225^STalent~`Group^N0^SPvP~`Visibility^Salways^SRelease^N20150914.1^SRange~`Checking^Sability^SPvE~`-~`Combat~`Alpha^N1^SPrimary~`Icon~`Size^N40^SSingle~`-~`Maximum^N0^Sx^N0^SAction~`Captions^B^SPvP~`-~`Combat~`Alpha^N1^SCopy~`To^SMW:~`AOE^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SSpecialization^N270^SAuto~`-~`Maximum^N0^SQueue~`Direction^SRIGHT^SPvE~`Visibility^Salways^SQueued~`Icon~`Size^N40^SAuto~`-~`Minimum^N3^SEnabled^B^SFont^SElvUI~`Font^SSingle~`-~`Minimum^N3^SAOE~`-~`Minimum^N3^SName^SMW:~`AOE^SPrimary~`Caption^Stargets^SIcons~`Shown^N4^SAOE~`-~`Maximum^N0^SPvE~`-~`Target^b^SPvE~`-~`Target~`Alpha^N1^SDefault^B^SPvP~`-~`Target~`Alpha^N1^SPrimary~`Font~`Size^N12^SPvP~`-~`Default~`Alpha^N1^SPvE~`-~`Default~`Alpha^N1^SForce~`Targets^N1^t^^]] )



  end

end
