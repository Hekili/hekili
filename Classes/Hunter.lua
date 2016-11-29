-- Hunter.lua
-- February 2015

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
local addCastExclusion = ns.addCastExclusion
local addExclusion = ns.addExclusion
local addGearSet = ns.addGearSet
local addGlyph = ns.addGlyph
local addTalent = ns.addTalent
local addPerk = ns.addPerk
local addResource = ns.addResource
local addStance = ns.addStance

local removeResource = ns.removeResource

local setClass = ns.setClass
local setPotion = ns.setPotion
local setRole = ns.setRole

local RegisterEvent = ns.RegisterEvent
local storeDefault = ns.storeDefault

-- This table gets loaded only if there's a ported class/specialization
if (select(2, UnitClass('player')) == 'HUNTER') then
  ns.initializeClassModule = function ()
    setClass( 'HUNTER' )
    setRole( 'attack' )

    addResource( 'focus', true )

    addTalent( 'posthaste', 109215 )
    addTalent( 'narrow_escape', 109298 )
    addTalent( 'crouching_tiger_hidden_chimaera', 118675 )

    addTalent( 'binding_shot', 109248 )
    addTalent( 'wyvern_sting', 19386 )
    addTalent( 'intimidation', 19577 )

    addTalent( 'exhilaration', 109304 )
    addTalent( 'iron_hawk', 109260 )
    addTalent( 'spirit_bond', 109212 )

    addTalent( 'steady_focus', 177667 )
    addTalent( 'dire_beast', 120679 )
    addTalent( 'thrill_of_the_hunt', 109306 )

    addTalent( 'a_murder_of_crows', 131894 )
    addTalent( 'blink_strikes', 130392 )
    addTalent( 'stampede', 121818 )

    addTalent( 'glaive_toss', 117050 )
    addTalent( 'powershot', 109259 )
    addTalent( 'barrage', 120360 )

    addTalent( 'exotic_munitions', 162534 )
    addTalent( 'focusing_shot', 152245 )
    addTalent( 'adaptation', 152244 )
    addTalent( 'lone_wolf', 155228 )

    -- Major Glyphs
    addGlyph( 'animal_bond', 20895 )
    addGlyph( 'black_ice', 109263 )
    addGlyph( 'camouflage', 42898 )
    addGlyph( 'chimaera_shot', 119447 )
    addGlyph( 'deterrence', 42903 )
    addGlyph( 'disengage', 42904 )
    addGlyph( 'distracting_shot', 42901 )
    addGlyph( 'enduring_deceit', 104276 )
    addGlyph( 'explosive_trap', 42908 )
    addGlyph( 'freezing_trap', 42905 )
    addGlyph( 'ice_trap', 42906 )
    addGlyph( 'liberation', 132106 )
    addGlyph( 'masters_call', 45733 )
    addGlyph( 'mend_pet', 42915 )
    addGlyph( 'mending', 56833 )
    addGlyph( 'mirrored_blades', 45735 )
    addGlyph( 'misdirection', 56829 )
    addGlyph( 'no_escape', 42910 )
    addGlyph( 'pathfinding', 19560 )
    addGlyph( 'quick_revival', 110821 )
    addGlyph( 'snake_trap', 110822 )
    addGlyph( 'solace', 42917 )
    addGlyph( 'lean_pack', 104270 )
    addGlyph( 'tranquilizing_shot', 45731 )

    -- Minor Glyphs
    addGlyph( 'aspect_of_the_beast', 85683 )
    addGlyph( 'aspect_of_the_cheetah', 45732 )
    addGlyph( 'aspect_of_the_pack', 43355 )
    addGlyph( 'aspects', 42897 )
    addGlyph( 'fetch', 87393 )
    addGlyph( 'fireworks', 43351 )
    addGlyph( 'lesser_proportion', 43350 )
    addGlyph( 'play_dead', 110819 )
    addGlyph( 'revive_pet', 43338 )
    addGlyph( 'stampede', 43356 )
    addGlyph( 'tame_beast', 42912)

    -- Player Buffs / Debuffs
    addAura( 'a_murder_of_crows', 131894, 'duration', 15 )
    addAura( 'aspect_of_the_fox', 172106, 'duration', 6 ) -- 6.2
    addAura( 'beast_cleave', 118455, 'duration', 4, 'feign', function ()
        if pet.exists and UnitBuff('pet', class.auras.beast_cleave.name ) then
          local _, _, _, count, _, duration, expires = UnitBuff( 'pet', class.auras.beast_cleave.name )

          buff.beast_cleave.count = count
          buff.beast_cleave.expires = expires
          buff.beast_cleave.applied = expires - duration
          buff.beast_cleave.caster = 'player'
        else
          buff.beast_cleave.count = 0
          buff.beast_cleave.expires = 0
          buff.beast_cleave.applied = 0
          buff.beast_cleave.caster = 'player'
        end
      end )
    addAura( 'bestial_wrath', 19574, 'duration', 10 )
    addAura( 'binding_shot', 109248, 'duration', 5 )
    addAura( 'black_arrow', 3674, 'duration', 20 )
    addAura( 'black_decay', 188400, 'duration', 15 )
    addAura( 'bombardment', 82921, 'duration', 5 )
    addAura( 'camouflage', 51753)
    addAura( 'careful_aim', 34483,
      'feign', function ()
        buff.careful_aim.caster = 'player'
        if target.health.pct >= 80 then
          buff.careful_aim.count = 1
          buff.careful_aim.expires = state.now + 3600
          buff.careful_aim.applied = state.now
        elseif target.health.pct < 80 and buff.rapid_fire.up then
          buff.careful_aim.count = 1
          buff.careful_aim.expires = buff.rapid_fire.expires
          buff.careful_aim.applied = buff.rapid_fire.applied
        else
          buff.careful_aim.count = 0
          buff.careful_aim.expires = 0
          buff.careful_aim.applied = 0
        end
      end )
    addAura( 'concussive_shot', 5116, 'duration', 6 )
    addAura( 'deterrence', 148467, 'duration', 5 )
    addAura( 'dire_beast', 120679, 'duration', 15 )
    addAura( 'explosive_shot', 53301, 'duration', 4 )
    addAura( 'explosive_trap', 82939, 'duration', 10 )
    addAura( 'feign_death', 5384, 'duration', 300 )
    addAura( 'focus_fire', 82692, 'duration', 20)
    addAura( 'freezing_trap', 60192, 'duration', 60 )
    addAura( 'frenzy', 19615, 'duration', 30, 'max_stacks', 5 )
    --[[ 'feign', function ()
        if pet.exists and UnitBuff('pet', class.auras.frenzy.name ) then
          local _, _, _, count, _, duration, expires = UnitBuff( 'pet', class.auras.frenzy.name )

          buff.frenzy.count = count
          buff.frenzy.expires = expires
          buff.frenzy.applied = expires - duration
          buff.frenzy.caster = 'pet'
        else
          buff.frenzy.count = 0
          buff.frenzy.expires = 0
          buff.frenzy.applied = 0
          buff.frenzy.caster = 'pet'
        end
      end ) ]]
    addAura( 'frozen_ammo', 162539, 'duration', 3600 )
    addAura( 'frozen_ammo_debuff', 162546, 'duration', 4 )
    addAura( 'glaive_toss', 117050, 'duration', 3 )
    addAura( 'ice_trap', 13809, 'duration', 60 )
    addAura( 'incendiary_ammo', 162536, 'duration', 3600 )
    addAura( 'intimidation', 19577, 'duration', 3)
    addAura( 'lock_and_load', 168980, 'duration', 15, 'max_stacks', 2)
    addAura( 'lone_wolf', 164273, 'duration', 3600 )
    addAura( 'lone_wolf_ferocity_of_the_raptor', 160200, 'duration', 3600 )
    addAura( 'lone_wolf_fortitude_of_the_bear', 160199, 'duration', 3600 )
    addAura( 'lone_wolf_grace_of_the_cat', 160198, 'duration', 3600 )
    addAura( 'lone_wolf_haste_of_the_hyena', 160203, 'duration', 3600 )
    addAura( 'lone_wolf_power_of_the_primates', 160206, 'duration', 3600 )
    addAura( 'lone_wolf_wisdom_of_the_serpent', 160205, 'duration', 3600 )
    addAura( 'lone_wolf_versatility_of_the_ravager', 172967, 'duration', 3600 )
    addAura( 'lone_wolf_quickness_of_the_dragonhawk', 172968, 'duration', 3600 )
    addAura( 'masters_call', 53271, 'duration', 4 )
    addAura( 'misdirection', 34477, 'duration', 8 )
    addAura( 'narrow_escape', 109298, 'duration', 8 )
    addAura( 'poisoned_ammo', 162537, 'duration', 3600)
    addAura( 'poisoned_ammo_debuff', 162543, 'duration', 16)
    addAura( 'posthaste', 109215, 'duration', 8 )    
    addAura( 'pre_steady_focus', -10, 'name', 'Pre-Steady Focus', 'duration', 10,
      'feign', function ()
        local up = ( player.lastcast == 'cobra_shot' or player.lastcast == 'steady_shot' ) and buff.steady_focus.applied < player.casttime
        buff.pre_steady_focus.name = "Pre-Steady Focus"
        buff.pre_steady_focus.count = up and 1 or 0
        buff.pre_steady_focus.expires = up and player.casttime + 3600 or 0
        buff.pre_steady_focus.applied = up and player.casttime or 0
        buff.pre_steady_focus.caster = 'player'
      end )
    addAura( 'rapid_fire', 3045, 'duration', 15 )
    addAura( 'serpent_sting', 87935 , 'duration', 15 )
    addAura( 'sniper_training', 168811, 'duration', 3600 )
    addAura( 'spirit_bond', 118694, 'duration', 3600 )
    addAura( 'stampede', 121818, 'duration', 40,
      'feign', function()
        buff.stampede.count = cooldown.stampede.remains > 260 and 1 or 0
        buff.stampede.expires = cooldown.stampede.expires - 260
        buff.stampede.applied = cooldown.stampede.expires - 300
        buff.stampede.caster = 'player'
      end )
    addAura( 'steady_focus', 177667, 'duration', 10 )
    addAura( 'thrill_of_the_hunt', 34720, 'duration', 15 , 'max_stacks', 3 )
    addAura( 'wyvern_sting', 19386, 'duration', 30 )
    addAura( 't17_4pc_survival', 165545, 'duration', 3 )

    -- Perks
    addPerk( 'improved_focus_fire', 157705 )
    addPerk( 'improved_beast_cleave', 157714 )
    addPerk( 'enhanced_basic_attacks', 157715 )
    addPerk( 'enhanced_camouflage', 157718 )
    addPerk( 'enhanced_aimed_shot', 157724 )
    addPerk( 'improved_focus', 157726 )
    addPerk( 'enhanced_kill_shot', 157707 )
    addPerk( 'empowered_explosive_shot', 157748 )
    addPerk( 'enhanced_traps', 157751 )
    addPerk( 'enhanced_entrapment', 157752 )

    -- Gear Sets
    addGearSet( 'tier17', 115545, 115546, 115547, 115548, 115549 )
    addGearSet( 'tier18', 124284, 124256, 124262, 124268, 124273 )
    addGearSet( 't18_class_trinket', 124515 )

    -- Pick an instant cast ability for checking the GCD.
    -- setGCD( 'arcane_shot' )

    class.auras.potion = class.auras.draenic_agility_potion
    setPotion( 'draenic_agility' )

    state.frozen = 'frozen'
    state.incendiary = 'incendiary'
    state.poisoned = 'poisoned'

    addCastExclusion( 75 ) -- ignore autoshots in SPELL_CAST_SUCCEEDED.

    addHook( 'runHandler', function( ability )
      if ability ~= 'steady_shot' and ability ~= 'cobra_shot' then
        state.removeBuff( 'pre_steady_focus' )
      end
    end )
    
    addHook( 'hasRequiredResources', function( spend )
      return spend + state.settings.focus_padding
    end )
    
    addHook( 'timeToReady_spend', function( spend )
      return spend + state.settings.focus_padding
    end )
    
    ns.addSetting( 'time_padding', 0, {
      name = "Time Padding",
      type = "range",
      desc = "...",
      min = 0,
      max = 0.50,
      step = 0.01,
    } )
    
    ns.addSetting( 'focus_padding', 0, {
      name = "Focus Padding",
      type = "range",
      desc = "...",
      min = 0,
      max = 10,
      step = 0.1
    } )
    
    addHook( 'advance', function( time )
      return time + Hekili.DB.profile['Class Option: time_padding']
    end )
    
    addAbility( 'a_murder_of_crows',
      {
        id = 131894,
        spend = 30,
        cast = 0,
        gcdType = 'spell',
        cooldown = 60
      })

    addHandler( 'a_murder_of_crows', function ()
      applyDebuff('target', 'a_murder_of_crows', 15 )
    end)

    addAbility( 'aimed_shot',
      {
        id = 19434,
        known = function() return spec.marksmanship end,
        spend = 50,
        cast = 2.5,
        gcdType = 'spell',
        cooldown = 0
      })

    modifyAbility( 'aimed_shot', 'spend', function ( x )
      if buff.thrill_of_the_hunt.up then
        return x - 20
      end
      return x
    end)

    modifyAbility( 'aimed_shot', 'cast', function ( x )
      if spec.marksmanship and set_bonus.tier18_4pc then return 0 end
      return x * haste
    end)

    addHandler( 'aimed_shot' , function()
      end)

    addAbility( 'arcane_shot',
      {
        id = 3044,
        spend = 30,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      })

    modifyAbility( 'arcane_shot', 'cost', function ( x )
      if buff.thrill_of_the_hunt.up then
        return x - 20
      end
      return x
    end)

    addHandler( 'arcane_shot', function()
      if spec.survival then
        applyDebuff( 'target', 'serpent_sting', 15 )
      end
      if talent.thrill_of_the_hunt.enabled then
        removeStack( 'thrill_of_the_hunt' )
      end
      if spec.beast_mastery and set_bonus.tier18_2pc == 1 and buff.focus_fire.up then
        buff.focus_fire.expires = buff.focus_fire.expires + 1
      end
    end)

    addAbility( 'aspect_of_the_cheetah',
      {
        id = 5118,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0,
        passive = true
      } )

    addHandler( 'aspect_of_the_cheetah', function ()
      applyBuff( 'aspect_of_the_cheetah', 3600 )
    end)

    addAbility( 'auto_shot',
      {
        id = 145759,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 3
      } )


    addAbility( 'barrage',
      {
        id = 120360,
        spend = 60,
        cast = 3,
        gcdType = 'spell',
        cooldown = 20,
        known = function () return talent.barrage.enabled end,
      })

    modifyAbility( 'barrage', 'cast', function ( x )
      return x * haste
    end)

    addHandler( 'barrage', function ()
      end)

    addAbility( 'bestial_wrath',
      {
        id = 19574,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 60,
        toggle = 'cooldowns'
      })

    addHandler( 'bestial_wrath', function ()
      applyBuff( 'bestial_wrath', 10)
    end)

    addAbility( 'black_arrow',
      {
        id = 3674,
        spend = 35,
        cast = 0,
        gcdType = 'spell',
        cooldown = 24
      })

    addHandler( 'black_arrow', function ()
      applyDebuff('target', 'black_arrow', 20)
      if set_bonus.tier17_2pc and spec.survival then
        applyBuff( 'lock_and_load', 15, 2 )
        setCooldown( 'explosive_shot', 0 )
      end
      if set_bonus.tier18_2pc and spec.survival then
        applyDebuff( 'target', 'black_decay', 15 )
      end
    end)

    addAbility( 'chimaera_shot',
      {
        id = 53209,
        spend = 35,
        cast = 0,
        gcdType = 'spell',
        cooldown = 9
      })

    addHandler( 'chimaera_shot', function ()
      end)

    addAbility( 'cobra_shot',
      {
        id = 77767,
        known = function () return level >= 81 and (spec.survival or spec.beast_mastery) end,
        spend = 0,
        cast = 2,
        gcdType = 'spell',
        cooldown = 0
      })

    modifyAbility( 'cobra_shot', 'cast', function ( x )
      return x * haste
    end)

    addHandler( 'cobra_shot', function ()
      if talent.steady_focus.enabled and buff.pre_steady_focus.up then
        applyBuff( 'steady_focus', 10 )
        removeBuff( 'pre_steady_focus' )
      elseif talent.steady_focus.enabled and buff.pre_steady_focus.down then
        applyBuff( 'pre_steady_focus', 3600 )
      end
      gain( 14, 'focus' )
    end)

    addAbility( 'counter_shot',
      {
        id = 147362,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 24,
        toggle = 'interrupts',
        usable = function () return target.casting end
      })

    addHandler( 'counter_shot', function ()
      interrupt()
    end)

    addAbility( 'dire_beast',
      {
        id = 120679,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 30,
        toggle = 'cooldowns'
      })

    addHandler( 'dire_beast', function ()
      end)
      
      
    addAbility( 'exotic_munitions',
      {
        id = 162534,
        spend = 0,
        cast = 3,
        gcdType = 'spell',
        cooldown = 0,
        known = function () return talent.exotic_munitions.enabled end,
        usable = function () return talent.exotic_munitions.enabled and args.ammo_type and not buff[ args.ammo_type .. '_ammo' ].up end
      } )
    
    addHandler( 'exotic_munitions', function ()
      if not args.ammo_type then return
      elseif args.ammo_type == 'frozen' then
        runHandler( 'frozen_ammo' )
      elseif args.ammo_type == 'incendiary' then
        runHandler( 'incendiary_ammo' )
      elseif args.ammo_type == 'poisoned' then
        runHandler( 'poisoned_ammo' )
      end
    end )
      

    addAbility( 'explosive_shot',
      {
        id = 53301,
        spend = 15,
        cast = 0,
        gcdType = 'spell',
        cooldown = 6
      })

    modifyAbility( 'explosive_shot', 'spend', function ( x )
      if buff.lock_and_load.up then return 0 end
      return x
    end)

    modifyAbility( 'explosive_shot', 'cooldown', function ( x )
      if buff.lock_and_load.up then return 0 end
      return x
    end)

    addHandler( 'explosive_shot', function()
      applyDebuff( 'target', 'explosive_shot', 4 )
      removeStack( 'lock_and_load' )
      if set_bonus.t17_4pc and spec.survival then
        applyBuff( 't17_4pc_survival', 3 )
      end
    end)

    addAbility( 'explosive_trap',
      {
        id = 13813,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 30
      })

    addHandler( 'explosive_trap' ,function ()
      end)

    modifyAbility( 'explosive_trap', 'cooldown' , function ( x )
      if spec.survival then
        return x * 0.66
      end
      return x
    end)

    addAbility( 'focusing_shot',
      {
        id = 152245,
        known = function() return talent.focusing_shot.enabled end,
        spend = 0,
        cast = 3,
        gcdType = 'spell',
        cooldown = 0
      })

    modifyAbility( 'focusing_shot', 'id', function ( x )
      if spec.marksmanship then return 163485 end
      return x
    end)

    modifyAbility( 'focusing_shot', 'cooldown', function ( x )
      return x * haste
    end)

    addHandler( 'focusing_shot', function()
      if talent.steady_focus.enabled then
        applyBuff( 'steady_focus', 10 )
      end
      gain( 50, 'focus' )
    end)

    addAbility( 'focus_fire',
      {
        id = 82692,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0,
        usable = function()
          if args.five_stacks ~= 0 and buff.frenzy.stacks < 5 then return false end
          return buff.frenzy.up
        end
      })

    addHandler( 'focus_fire', function()
      applyBuff( 'focus_fire', 20, buff.frenzy.stacks )
      removeBuff( 'frenzy' )
    end)    
    
    addAbility( 'frozen_ammo', 
      {
        id = 162539,
        spend = 0,
        cast = 3,
        gcdType = 'spell',
        cooldown = 0,
        texture = 'Interface\\ICONS\\spell_hunter_exoticmunitions_frozen',
        usable = function () return talent.exotic_munitions.enabled and not buff.frozen_ammo.up end
      } )
    
    addHandler( 'frozen_ammo', function ()
      removeBuff( 'incendiary_ammo' )
      removeBuff( 'poisoned_ammo' )
      applyBuff( 'frozen_ammo', 3600 )
    end )

    addAbility( 'glaive_toss',
      {
        id = 117050,
        known = function () return talent.glaive_toss.enabled end,
        spend = 15,
        cast = 0,
        gcdType = 'spell',
        cooldown = 15
      })

    addHandler( 'glaive_toss', function ()
      end)

    addAbility( 'incendiary_ammo', 
      {
        id = 162539,
        spend = 0,
        cast = 3,
        gcdType = 'spell',
        cooldown = 0,
        texture = 'Interface\\ICONS\\spell_hunter_exoticmunitions_incendiary',
        usable = function () return talent.exotic_munitions.enabled and not buff.incendiary_ammo.up end
      } )
    
    addHandler( 'incendiary_ammo', function ()
      removeBuff( 'poisoned_ammo' )
      removeBuff( 'frozen_ammo' )
      applyBuff( 'incendiary_ammo', 3600 )
    end )
      
    addAbility( 'kill_command',
      {
        id = 34026,
        spend = 40,
        cast = 0,
        gcdType = 'spell',
        cooldown = 6,
        usable = function () return pet.exists end
      })

    addHandler( 'kill_command', function ()
      end)

    addAbility( 'kill_shot',
      {
        id = 53351,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 10,
        known = 53351,
        usable = function() if perk.enhanced_kill_shot.enabled then return IsUsableSpell( 157708 ) end
          return IsUsableSpell( 53351 )
        end,
      })
      
    class.abilities[ 157708 ] = class.abilities[ 53351 ]
    
    modifyAbility( 'kill_shot', 'id', function( x )
      if perk.enhanced_kill_shot.enabled then return 157708 end
      return x
    end )

    addHandler( 'kill_shot', function ()
      end)

    addAbility( 'multishot',
      {
        id = 2643,
        spend = 40,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0
      })

    modifyAbility( 'multishot', 'spend', function ( x )
      if buff.thrill_of_the_hunt.up then
        x = x - 20
      end
      if buff.bombardment.up then
        x = x - 25
      end
      return max( 0, x )
    end)

    addHandler( 'multishot', function ()
      if spec.beast_mastery then
        applyBuff( 'beast_cleave', 4 )
      elseif spec.survival then
        applyDebuff( 'target', 'serpent_sting', 15 )
      end
      if talent.thrill_of_the_hunt.enabled then
        removeStack( 'thrill_of_the_hunt' )
      end
      if spec.beast_mastery and set_bonus.tier18_2pc == 1 and buff.focus_fire.up then
        buff.focus_fire.expires = buff.focus_fire.expires + 1
      end
    end)

    addAbility( 'poisoned_ammo', 
      {
        id = 162539,
        spend = 0,
        cast = 3,
        gcdType = 'spell',
        cooldown = 0,
        texture = 'Interface\\ICONS\\spell_hunter_exoticmunitions_poisoned',
        usable = function () return talent.exotic_munitions.enabled and not buff.poisoned_ammo.up end
      } )
    
    addHandler( 'poisoned_ammo', function ()
      removeBuff( 'incendiary_ammo' )
      removeBuff( 'frozen_ammo' )
      applyBuff( 'poisoned_ammo', 3600 )
    end )
    
    addAbility( 'powershot',
      {
        id = 109259,
        spend = 15,
        cast = 2.25,
        gcdType = 'spell',
        cooldown = 45,
        known = function () return talent.powershot.enabled end
      })

    addHandler( 'powershot', function ()
      end)

    addAbility( 'rapid_fire',
      {
        id = 3045,
        spend = 0,
        cast = 0,
        gcdType = 'off',
        cooldown = 120,
        toggle = 'cooldowns'
      })

    addHandler( 'rapid_fire', function ()
      applyBuff( 'rapid_fire', 15 )
    end)

    addAbility( 'stampede',
      {
        id = 121818,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 300,
        toggle = 'cooldowns'
      })

    addHandler( 'stampede', function ()
      end)

    addAbility( 'steady_shot',
      {
        id = 56641,
        known = function () return not (level >= 81 and (spec.survival or spec.beast_mastery)) end,
        spend = 0,
        cast = 2,
        gcdType = 'spell',
        cooldown = 0
      })

    modifyAbility( 'steady_shot', 'cast', function ( x )
      return x * haste
    end)

    addHandler( 'steady_shot', function ()
      if talent.steady_focus.enabled and buff.pre_steady_focus.up then
        applyBuff( 'steady_focus', 10 )
        removeBuff( 'pre_steady_focus' )
      elseif talent.steady_focus.enabled and buff.pre_steady_focus.down then
        applyBuff( 'pre_steady_focus', 3600 )
      end
      gain( 14, 'focus' )
    end)
    
    addAbility( 'summon_pet',
      {
        id = 883,
        spend = 0,
        cast = 0,
        gcdType = 'spell',
        cooldown = 0,
        passive = true,
        texture = 'INTERFACE\\ICONS\\Ability_Hunter_BeastCall',
        usable = function () return not talent.lone_wolf.enabled and not pet.exists end
      } )
    
    addHandler( 'summon_pet', function ()
      summonPet( 'cat', 3600 )
    end )

  end

    storeDefault( 'MM: Careful Aim', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SName^SMM:~`Careful~`Aim^SSpecialization^N254^SRelease^N20150706.1^SScript^S^SActions^T^N1^T^SEnabled^B^SScript^Smy_enemies>2^SAbility^Sglaive_toss^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SGlaive~`Toss^t^N2^T^SEnabled^B^SScript^Smy_enemies>1&cast_regen<focus.deficit^SAbility^Spowershot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPowershot^t^N3^T^SEnabled^B^SScript^Smy_enemies>1^SAbility^Sbarrage^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBarrage^t^N4^T^SEnabled^B^SName^SAimed~`Shot^SAbility^Saimed_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N5^T^SEnabled^B^SScript^S50+cast_regen<focus.deficit^SAbility^Sfocusing_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SFocusing~`Shot^t^N6^T^SEnabled^B^SName^SSteady~`Shot^SAbility^Ssteady_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^t^SDefault^B^t^^]] )

    storeDefault( 'MM: Default', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SName^SMM:~`Default^SSpecialization^N254^SRelease^N20150706.1^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SAuto~`Shot^SAbility^Sauto_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N2^T^SEnabled^B^SScript^Stoggle.cooldowns&(focus.deficit>=30)^SAbility^Sarcane_torrent^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SArcane~`Torrent^t^N3^T^SEnabled^B^SScript^Stoggle.cooldowns^SAbility^Sblood_fury^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlood~`Fury^t^N4^T^SEnabled^B^SScript^Stoggle.cooldowns^SAbility^Sberserking^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBerserking^t^N5^T^SEnabled^B^SScript^Stoggle.cooldowns&(((buff.rapid_fire.up|buff.bloodlust.up)&(cooldown.stampede.remains<1))|target.time_to_die<=25)^SArgs^Sname=draenic_agility^SAbility^Spotion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPotion^t^N6^T^SEnabled^B^SName^SChimaera~`Shot^SAbility^Schimaera_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N7^T^SEnabled^B^SName^SKill~`Shot^SAbility^Skill_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N8^T^SEnabled^B^SScript^Stoggle.cooldowns^SAbility^Srapid_fire^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SRapid~`Fire^t^N9^T^SEnabled^B^SScript^Stoggle.cooldowns&(buff.rapid_fire.up|buff.bloodlust.up|target.time_to_die<=25)^SAbility^Sstampede^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SStampede^t^N10^T^SEnabled^B^SScript^Sbuff.careful_aim.up^SArgs^Sname="MM:~`Careful~`Aim"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCall~`Action~`List^t^N11^T^SEnabled^B^SScript^Smy_enemies>1^SAbility^Sexplosive_trap^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExplosive~`Trap^t^N12^T^SEnabled^B^SName^SA~`Murder~`of~`Crows^SAbility^Sa_murder_of_crows^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N13^T^SEnabled^B^SScript^Stoggle.cooldowns&(cast_regen+action.aimed_shot.cast_regen<focus.deficit)^SAbility^Sdire_beast^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SDire~`Beast^t^N14^T^SEnabled^B^SName^SGlaive~`Toss^SAbility^Sglaive_toss^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N15^T^SEnabled^B^SScript^Scast_regen<focus.deficit^SAbility^Spowershot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPowershot^t^N16^T^SEnabled^B^SName^SBarrage^SAbility^Sbarrage^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N17^T^SEnabled^B^SScript^Sfocus.deficit*cast_time%(14+cast_regen)>cooldown.rapid_fire.remains^SAbility^Ssteady_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SSteady~`Shot^t^N18^T^SEnabled^B^SScript^Sfocus.deficit*cast_time%(50+cast_regen)>cooldown.rapid_fire.remains&focus.current<100^SAbility^Sfocusing_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SFocusing~`Shot^t^N19^T^SEnabled^B^SScript^Sbuff.pre_steady_focus.up&(14+cast_regen+action.aimed_shot.cast_regen)<=focus.deficit^SAbility^Ssteady_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SSteady~`Shot~`(1)^t^N20^T^SEnabled^B^SScript^Smy_enemies>6^SAbility^Smultishot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SMulti-Shot^t^N21^T^SEnabled^B^SScript^Stalent.focusing_shot.enabled^SAbility^Saimed_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SAimed~`Shot^t^N22^T^SEnabled^B^SScript^Sfocus.current+cast_regen>=85^SAbility^Saimed_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SAimed~`Shot~`(1)^t^N23^T^SEnabled^B^SScript^Sbuff.thrill_of_the_hunt.up&focus.current+cast_regen>=65^SAbility^Saimed_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SAimed~`Shot~`(2)^t^N24^T^SEnabled^B^SScript^S50+cast_regen-10<focus.deficit^SAbility^Sfocusing_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SFocusing~`Shot~`(1)^t^N25^T^SEnabled^B^SName^SSteady~`Shot~`(2)^SAbility^Ssteady_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^t^SDefault^B^t^^]] )

    storeDefault( 'MM: Precombat', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SName^SMM:~`Precombat^SSpecialization^N254^SRelease^N20150706.1^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SCall~`Pet~`1^SAbility^Ssummon_pet^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N2^T^SEnabled^B^SScript^Smy_enemies<3^SArgs^Sammo_type=poisoned^SAbility^Sexotic_munitions^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExotic~`Munitions^t^N3^T^SEnabled^B^SScript^Smy_enemies>=3^SArgs^Sammo_type=incendiary^SAbility^Sexotic_munitions^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExotic~`Munitions~`(1)^t^N4^T^SEnabled^B^SScript^Stoggle.cooldowns^SArgs^Sname=draenic_agility^SAbility^Spotion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPotion^t^N5^T^SEnabled^B^SName^SGlaive~`Toss^SAbility^Sglaive_toss^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N6^T^SEnabled^B^SName^SFocusing~`Shot^SAbility^Sfocusing_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^t^SDefault^B^t^^]] )

    storeDefault( 'BM: Default', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SSpecialization^N253^SName^SBM:~`Default^SRelease^N20150706.1^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SAuto~`Shot^SAbility^Sauto_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N2^T^SEnabled^B^SScript^Stoggle.cooldowns&(focus.deficit>=30)^SAbility^Sarcane_torrent^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SArcane~`Torrent^t^N3^T^SEnabled^B^SScript^Stoggle.cooldowns^SAbility^Sblood_fury^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlood~`Fury^t^N4^T^SEnabled^B^SScript^Stoggle.cooldowns^SAbility^Sberserking^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBerserking^t^N5^T^SEnabled^B^SScript^Stoggle.cooldowns&(!talent.stampede.enabled&((buff.bestial_wrath.up&(legendary_ring.up|!legendary_ring.has_cooldown)&target.health.pct<=20)|target.time_to_die<=20))^SArgs^Sname=draenic_agility^SAbility^Spotion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPotion^t^N6^T^SEnabled^B^SScript^Stoggle.cooldowns&(talent.stampede.enabled&((buff.stampede.up&(legendary_ring.up|!legendary_ring.has_cooldown)&(buff.bloodlust.up|buff.focus_fire.up))|target.time_to_die<=40))^SArgs^Sname=draenic_agility^SAbility^Spotion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPotion~`(1)^t^N7^T^SEnabled^B^SScript^Stoggle.cooldowns&(((buff.bloodlust.up|buff.focus_fire.up)&(legendary_ring.up|!legendary_ring.has_cooldown))|target.time_to_die<=25)^SAbility^Sstampede^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SStampede^t^N8^T^SEnabled^B^SScript^Stoggle.cooldowns^SAbility^Sdire_beast^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SDire~`Beast^t^N9^T^SEnabled^B^SScript^Sbuff.focus_fire.down&((cooldown.bestial_wrath.remains<1&buff.bestial_wrath.down)|(talent.stampede.enabled&buff.stampede.up)|buff.frenzy.remains<1)^SAbility^Sfocus_fire^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SFocus~`Fire^t^N10^T^SEnabled^B^SScript^Stoggle.cooldowns&(focus.current>30&!buff.bestial_wrath.up)^SAbility^Sbestial_wrath^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBestial~`Wrath^t^N11^T^SEnabled^B^SScript^Smy_enemies>1&buff.beast_cleave.remains<0.5^SAbility^Smultishot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SMulti-Shot^t^N12^T^SEnabled^B^SName^SFocus~`Fire~`(1)^SArgs^Smin_frenzy=5^SAbility^Sfocus_fire^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N13^T^SEnabled^B^SScript^Smy_enemies>1^SAbility^Sbarrage^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBarrage^t^N14^T^SEnabled^B^SScript^Smy_enemies>5^SAbility^Sexplosive_trap^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExplosive~`Trap^t^N15^T^SEnabled^B^SScript^Smy_enemies>5^SAbility^Smultishot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SMulti-Shot~`(1)^t^N16^T^SEnabled^B^SName^SKill~`Command^SAbility^Skill_command^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N17^T^SEnabled^B^SName^SA~`Murder~`of~`Crows^SAbility^Sa_murder_of_crows^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N18^T^SEnabled^B^SScript^Sfocus.time_to_max>gcd^SAbility^Skill_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SKill~`Shot^t^N19^T^SEnabled^B^SScript^Sfocus.current<50^SAbility^Sfocusing_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SFocusing~`Shot^t^N20^T^SEnabled^B^SScript^Sbuff.pre_steady_focus.up&buff.steady_focus.remains<7&(14+cast_regen)<focus.deficit^SAbility^Scobra_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCobra~`Shot^t^N21^T^SEnabled^B^SScript^Smy_enemies>1^SAbility^Sexplosive_trap^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExplosive~`Trap~`(1)^t^N22^T^SEnabled^B^SScript^Stalent.steady_focus.enabled&buff.steady_focus.remains<4&focus.current<50^SAbility^Scobra_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCobra~`Shot~`(1)^t^N23^T^SEnabled^B^SName^SGlaive~`Toss^SAbility^Sglaive_toss^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N24^T^SEnabled^B^SName^SBarrage~`(1)^SAbility^Sbarrage^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N25^T^SEnabled^B^SScript^Sfocus.time_to_max>cast_time^SAbility^Spowershot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPowershot^t^N26^T^SEnabled^B^SScript^Smy_enemies>5^SAbility^Scobra_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCobra~`Shot~`(2)^t^N27^T^SEnabled^B^SScript^S(buff.thrill_of_the_hunt.up&focus.current>35)|buff.bestial_wrath.up^SAbility^Sarcane_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SArcane~`Shot^t^N28^T^SEnabled^B^SScript^Sfocus.current>=75^SAbility^Sarcane_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SArcane~`Shot~`(1)^t^N29^T^SEnabled^B^SName^SCobra~`Shot~`(3)^SAbility^Scobra_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^t^SDefault^B^t^^]] )

    storeDefault( 'BM: Precombat', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SSpecialization^N253^SName^SBM:~`Precombat^SRelease^N20150706.1^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SCall~`Pet~`1^SAbility^Ssummon_pet^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N2^T^SEnabled^B^SScript^Smy_enemies<3^SArgs^Sammo_type=poisoned^SAbility^Sexotic_munitions^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExotic~`Munitions^t^N3^T^SEnabled^B^SScript^Smy_enemies>=3^SArgs^Sammo_type=incendiary^SAbility^Sexotic_munitions^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExotic~`Munitions~`(1)^t^N4^T^SEnabled^B^SScript^Stoggle.cooldowns^SArgs^Sname=draenic_agility^SAbility^Spotion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPotion^t^N5^T^SEnabled^B^SName^SGlaive~`Toss^SAbility^Sglaive_toss^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N6^T^SEnabled^B^SName^SFocusing~`Shot^SAbility^Sfocusing_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^t^SDefault^B^t^^]] )

    storeDefault( 'Sv: AOE', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SName^SSv:~`AOE^SRelease^N20150706.1^SScript^S^SActions^T^N1^T^SEnabled^B^SScript^Stoggle.cooldowns&(buff.potion.up|(cooldown.potion.remains>0&(buff.archmages_greater_incandescence_agi.up|trinket.stat.any.up|buff.archmages_incandescence_agi.up)))^SAbility^Sstampede^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SStampede^t^N2^T^SEnabled^B^SScript^Sbuff.lock_and_load.up&(!talent.barrage.enabled|cooldown.barrage.remains>0)^SAbility^Sexplosive_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExplosive~`Shot^t^N3^T^SEnabled^B^SName^SBarrage^SAbility^Sbarrage^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N4^T^SEnabled^B^SScript^Sremains<gcd*1.5^SArgs^S^SAbility^Sblack_arrow^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlack~`Arrow^t^N5^T^SEnabled^B^SScript^Sremains<gcd*1.5^SArgs^Scycle_targets=1^SAbility^Sblack_arrow^SIndicator^Scycle^SRelease^F6923701033084388^f-35^SName^SBlack~`Arrow~`(1)^t^N6^T^SEnabled^B^SScript^Smy_enemies<5^SAbility^Sexplosive_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExplosive~`Shot~`(1)^t^N7^T^SEnabled^B^SScript^Sdot.explosive_trap.remains<=5^SAbility^Sexplosive_trap^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExplosive~`Trap^t^N8^T^SEnabled^B^SName^SA~`Murder~`of~`Crows^SAbility^Sa_murder_of_crows^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N9^T^SEnabled^B^SScript^Stoggle.cooldowns^SAbility^Sdire_beast^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SDire~`Beast^t^N10^T^SEnabled^B^SScript^Sbuff.thrill_of_the_hunt.up&focus.current>50&cast_regen<=focus.deficit|dot.serpent_sting.remains<=5|target.time_to_die<4.5^SAbility^Smultishot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SMulti-Shot^t^N11^T^SEnabled^B^SName^SGlaive~`Toss^SAbility^Sglaive_toss^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N12^T^SEnabled^B^SName^SPowershot^SAbility^Spowershot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N13^T^SEnabled^B^SScript^Sbuff.pre_steady_focus.up&buff.steady_focus.remains<5&focus.current+14+cast_regen<80^SAbility^Scobra_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCobra~`Shot^t^N14^T^SEnabled^B^SScript^Sfocus.current>=70|talent.focusing_shot.enabled^SAbility^Smultishot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SMulti-Shot~`(1)^t^N15^T^SEnabled^B^SName^SFocusing~`Shot^SAbility^Sfocusing_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N16^T^SEnabled^B^SName^SCobra~`Shot~`(1)^SAbility^Scobra_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^t^SSpecialization^N255^t^^]] )

    storeDefault( 'Sv: Default', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SName^SSv:~`Default^SRelease^N20150706.1^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SAuto~`Shot^SAbility^Sauto_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N2^T^SEnabled^B^SScript^Stoggle.cooldowns&(focus.deficit>=30)^SAbility^Sarcane_torrent^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SArcane~`Torrent^t^N3^T^SEnabled^B^SScript^Stoggle.cooldowns^SAbility^Sblood_fury^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlood~`Fury^t^N4^T^SEnabled^B^SScript^Stoggle.cooldowns^SAbility^Sberserking^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBerserking^t^N5^T^SEnabled^B^SScript^Stoggle.cooldowns&((((cooldown.stampede.remains<1)&(cooldown.a_murder_of_crows.remains<1))&(trinket.stat.any.up|buff.archmages_greater_incandescence_agi.up))|target.time_to_die<=25)^SArgs^Sname=draenic_agility^SAbility^Spotion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPotion^t^N6^T^SEnabled^B^SScript^Smy_enemies>1^SArgs^Sname="Sv:~`AOE"^SAbility^Scall_action_list^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCall~`Action~`List^t^N7^T^SEnabled^B^SName^SA~`Murder~`of~`Crows^SAbility^Sa_murder_of_crows^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N8^T^SEnabled^B^SScript^Stoggle.cooldowns&(buff.potion.up|(cooldown.potion.remains>0&(buff.archmages_greater_incandescence_agi.up|trinket.stat.any.up))|target.time_to_die<=45)^SAbility^Sstampede^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SStampede^t^N9^T^SEnabled^B^SScript^Sremains<gcd*1.5^SArgs^S^SAbility^Sblack_arrow^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SBlack~`Arrow^t^N10^T^SEnabled^B^SScript^Sremains<gcd*1.5^SArgs^Scycle_targets=1^SAbility^Sblack_arrow^SIndicator^Scycle^SRelease^F6923701033084388^f-35^SName^SBlack~`Arrow~`(1)^t^N11^T^SEnabled^B^SScript^S(trinket.proc.any.up&trinket.proc.any.remains<4)|dot.serpent_sting.remains<=3^SAbility^Sarcane_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SArcane~`Shot^t^N12^T^SEnabled^B^SName^SExplosive~`Shot^SAbility^Sexplosive_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N13^T^SEnabled^B^SScript^Sbuff.pre_steady_focus.up^SAbility^Scobra_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCobra~`Shot^t^N14^T^SEnabled^B^SScript^Stoggle.cooldowns^SAbility^Sdire_beast^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SDire~`Beast^t^N15^T^SEnabled^B^SScript^S(buff.thrill_of_the_hunt.up&focus.current>35)|target.time_to_die<4.5^SAbility^Sarcane_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SArcane~`Shot~`(1)^t^N16^T^SEnabled^B^SName^SGlaive~`Toss^SAbility^Sglaive_toss^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N17^T^SEnabled^B^SName^SPowershot^SAbility^Spowershot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N18^T^SEnabled^B^SName^SBarrage^SAbility^Sbarrage^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N19^T^SEnabled^B^SScript^S!trinket.proc.any.up&!trinket.stacking_proc.any.up^SAbility^Sexplosive_trap^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExplosive~`Trap^t^N20^T^SEnabled^B^SScript^Stalent.steady_focus.enabled&!talent.focusing_shot.enabled&focus.deficit<action.cobra_shot.cast_regen*2+28^SAbility^Sarcane_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SArcane~`Shot~`(2)^t^N21^T^SEnabled^B^SScript^Stalent.steady_focus.enabled&buff.steady_focus.remains<5^SAbility^Scobra_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SCobra~`Shot~`(1)^t^N22^T^SEnabled^B^SScript^Stalent.steady_focus.enabled&buff.steady_focus.remains<=cast_time&focus.deficit>cast_regen^SAbility^Sfocusing_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SFocusing~`Shot^t^N23^T^SEnabled^B^SScript^Sfocus.current>=70|talent.focusing_shot.enabled|(talent.steady_focus.enabled&focus.current>=50)^SAbility^Sarcane_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SArcane~`Shot~`(3)^t^N24^T^SEnabled^B^SName^SFocusing~`Shot~`(1)^SAbility^Sfocusing_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N25^T^SEnabled^B^SName^SCobra~`Shot~`(2)^SAbility^Scobra_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^t^SSpecialization^N255^t^^]] )

    storeDefault( 'Sv: Precombat', 'actionLists', 20160203.1, [[^1^T^SEnabled^B^SDefault^B^SName^SSv:~`Precombat^SRelease^N20150706.1^SScript^S^SActions^T^N1^T^SEnabled^B^SName^SCall~`Pet~`1^SAbility^Ssummon_pet^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N2^T^SEnabled^B^SScript^Smy_enemies<3^SArgs^Sammo_type=poisoned^SAbility^Sexotic_munitions^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExotic~`Munitions^t^N3^T^SEnabled^B^SScript^Smy_enemies>=3^SArgs^Sammo_type=incendiary^SAbility^Sexotic_munitions^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SExotic~`Munitions~`(1)^t^N4^T^SEnabled^B^SScript^Stoggle.cooldowns^SArgs^Sname=draenic_agility^SAbility^Spotion^SIndicator^Snone^SRelease^F6923701033084388^f-35^SName^SPotion^t^N5^T^SEnabled^B^SName^SGlaive~`Toss^SAbility^Sglaive_toss^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N6^T^SEnabled^B^SName^SExplosive~`Shot^SAbility^Sexplosive_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^N7^T^SEnabled^B^SName^SFocusing~`Shot^SAbility^Sfocusing_shot^SIndicator^Snone^SRelease^F6923701033084388^f-35^t^t^SSpecialization^N255^t^^]] )


    storeDefault( 'Marksmanship: Primary', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPvP~`-~`Target^b^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SUse~`SpellFlash^b^SPvE~`-~`Target^b^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SMM:~`Precombat^SName^SMM:~`Precombat^SRelease^N201506.221^SScript^Stime=0^t^N2^T^SEnabled^B^SAction~`List^SMM:~`Default^SName^SMM:~`Default^SRelease^N201506.221^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^N-270^SAOE~`-~`Maximum^N0^SRelease^N20150706.1^SRange~`Checking^Sability^SAuto~`-~`Maximum^N0^SPrimary~`Icon~`Size^N40^SSingle~`-~`Minimum^N0^SPrimary~`Caption^Stargets^SAction~`Captions^B^SSpellFlash~`Color^T^Sa^N1^Sb^N1^Sg^N1^Sr^N1^t^SSpecialization^N254^SSpacing^N5^SQueue~`Direction^SRIGHT^SPrimary~`Font~`Size^N12^SQueued~`Icon~`Size^N40^SPvP~`-~`Target~`Alpha^N1^SEnabled^B^SName^SMarksmanship:~`Primary^SFont^SArial~`Narrow^SAOE~`-~`Minimum^N3^STalent~`Group^N0^SSingle~`-~`Maximum^N1^SIcons~`Shown^N4^SPvE~`-~`Combat~`Alpha^N1^SAuto~`-~`Minimum^N0^SPvE~`-~`Target~`Alpha^N1^SDefault^B^SPvP~`-~`Combat~`Alpha^N1^SCopy~`To^SMarksmanship:~`AOE^SScript^S^SPvE~`-~`Default~`Alpha^N1^Sx^N0^t^^]] )

    storeDefault( 'Marksmanship: AOE', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SUse~`SpellFlash^b^SSpacing^N5^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SMM:~`Precombat^SName^SMM:~`Precombat^SRelease^N201506.141^SScript^Stime=0^t^N2^T^SEnabled^B^SAction~`List^SMM:~`Default^SName^SMM:~`Default^SRelease^N201506.141^t^t^SScript^S^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^N-225^SAOE~`-~`Maximum^N0^SPrimary~`Caption^Stargets^SRange~`Checking^Sability^SAuto~`-~`Maximum^N0^SPrimary~`Icon~`Size^N40^SSingle~`-~`Minimum^N3^Sx^N0^SPvE~`-~`Default~`Alpha^N1^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SCopy~`To^SMarksmanship:~`AOE^SPvP~`-~`Default~`Alpha^N1^SQueue~`Direction^SRIGHT^SSpecialization^N254^SQueued~`Icon~`Size^N40^SPvP~`-~`Combat~`Alpha^N1^SEnabled^B^SDefault^B^SPvE~`-~`Target~`Alpha^N1^SAOE~`-~`Minimum^N3^SAuto~`-~`Minimum^N3^SPvE~`-~`Combat~`Alpha^N1^SIcons~`Shown^N4^SSingle~`-~`Maximum^N0^STalent~`Group^N0^SFont^SArial~`Narrow^SName^SMarksmanship:~`AOE^SPvP~`-~`Target~`Alpha^N1^SPvP~`-~`Target^b^SPvE~`-~`Target^b^SAction~`Captions^B^SRelease^N20150706.1^t^^]] )

    storeDefault( 'Beast Mastery: Primary', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SUse~`SpellFlash^b^SPvE~`-~`Target^b^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SBM:~`Precombat^SName^SBM:~`Precombat^SRelease^N201506.221^SScript^Stime=0^t^N2^T^SEnabled^B^SAction~`List^SBM:~`Default^SName^SBM:~`Default^SRelease^N201506.221^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^F-4749890768863230^f-44^SAOE~`-~`Maximum^N0^SPrimary~`Caption^Sdefault^SRange~`Checking^Sability^SAuto~`-~`Maximum^N0^SPrimary~`Icon~`Size^N40^SSingle~`-~`Minimum^N0^Sx^N0^SAction~`Captions^B^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SSpecialization^N253^SSpacing^N5^SQueue~`Direction^SRIGHT^SPvP~`-~`Target^b^SQueued~`Icon~`Size^N40^SPvP~`-~`Target~`Alpha^N1^SEnabled^B^SDefault^B^SFont^SElvUI~`Font^SAOE~`-~`Minimum^N3^SName^SBeast~`Mastery:~`Primary^SCopy~`To^SBeast~`Mastery:~`AOE^SIcons~`Shown^N4^STalent~`Group^N0^SSingle~`-~`Maximum^N1^SPvE~`-~`Target~`Alpha^N1^SAuto~`-~`Minimum^N0^SPvE~`-~`Combat~`Alpha^N1^SPvP~`-~`Combat~`Alpha^N1^SScript^S^SPvE~`-~`Default~`Alpha^N1^SRelease^N20150706.1^t^^]] )

    storeDefault( 'Beast Mastery: AOE', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPrimary~`Font~`Size^N12^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SUse~`SpellFlash^b^SPvE~`-~`Target^b^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SBM:~`Precombat^SName^SBM:~`Precombat^SRelease^N201505.311^SScript^Stime=0^t^N2^T^SEnabled^B^SAction~`List^SBM:~`Default^SName^SBM:~`Default^SRelease^N201505.311^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^N-225^SAOE~`-~`Maximum^N0^SRelease^N20150706.1^SRange~`Checking^Sability^SAuto~`-~`Maximum^N0^SPrimary~`Icon~`Size^N40^SSingle~`-~`Minimum^N3^SIcons~`Shown^N4^SPvE~`-~`Default~`Alpha^N1^SSpellFlash~`Color^T^Sa^N1^Sb^N1^Sg^N1^Sr^N1^t^SCopy~`To^SBeast~`Mastery:~`AOE^SScript^S^SQueue~`Direction^SRIGHT^SPvP~`-~`Combat~`Alpha^N1^SQueued~`Icon~`Size^N40^SPvE~`-~`Combat~`Alpha^N1^SEnabled^B^SDefault^B^SPvE~`-~`Target~`Alpha^N1^SAOE~`-~`Minimum^N3^SAuto~`-~`Minimum^N3^SPvP~`-~`Target^b^SSingle~`-~`Maximum^N0^STalent~`Group^N0^SPvP~`-~`Target~`Alpha^N1^SFont^SElvUI~`Font^SName^SBeast~`Mastery:~`AOE^SSpacing^N5^SSpecialization^N253^Sx^N0^SAction~`Captions^B^SPrimary~`Caption^Stargets^t^^]] )

    storeDefault( 'Survival: Primary', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPvP~`-~`Target^b^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SUse~`SpellFlash^b^SSpacing^N5^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SSv:~`Precombat^SName^SSv:~`Precombat^SRelease^N201506.221^SScript^Stime=0^t^N2^T^SEnabled^B^SAction~`List^SSv:~`Default^SName^SSv:~`Default^SRelease^N201506.221^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^F-4749889695121410^f-44^SIcons~`Shown^N4^SRelease^N20150706.1^SRange~`Checking^Sability^SAuto~`-~`Maximum^N0^SPrimary~`Icon~`Size^N40^SSingle~`-~`Minimum^N0^SAOE~`-~`Maximum^N0^SPvE~`-~`Default~`Alpha^N1^SSpellFlash~`Color^T^Sa^N1^Sb^N1^Sg^N1^Sr^N1^t^SCopy~`To^SSurvival:~`AOE^SScript^S^SQueue~`Direction^SRIGHT^SPvP~`-~`Combat~`Alpha^N1^SQueued~`Icon~`Size^N40^SPvE~`-~`Combat~`Alpha^N1^SEnabled^B^SAuto~`-~`Minimum^N0^SPvE~`-~`Target~`Alpha^N1^SAOE~`-~`Minimum^N3^SSingle~`-~`Maximum^N1^STalent~`Group^N0^SName^SSurvival:~`Primary^SPrimary~`Font~`Size^N12^SPrimary~`Caption^Sdefault^SFont^SElvUI~`Font^SDefault^B^SPvP~`-~`Target~`Alpha^N1^SSpecialization^N255^SPvE~`-~`Target^b^SAction~`Captions^B^Sx^N0.0003662109375^t^^]] )

    storeDefault( 'Survival: AOE', 'displays', 20160203.1, [[^1^T^SQueued~`Font~`Size^N12^SPvP~`-~`Target^b^SPrimary~`Caption~`Aura^S^Srel^SCENTER^SUse~`SpellFlash^b^SPvE~`-~`Target^b^SPvE~`-~`Default^B^SPvE~`-~`Combat^b^SMaximum~`Time^N30^SQueues^T^N1^T^SEnabled^B^SAction~`List^SSv:~`Precombat^SName^SSv:~`Precombat^SRelease^N201506.141^SScript^Stime=0^t^N2^T^SEnabled^B^SAction~`List^SSv:~`Default^SName^SSv:~`Default^SRelease^N201506.141^t^t^SPvP~`-~`Default~`Alpha^N1^SPvP~`-~`Combat^b^SPvP~`-~`Default^B^Sy^N-225^Sx^N0^SRelease^N20150706.1^SRange~`Checking^Sability^SAuto~`-~`Maximum^N0^SPvP~`-~`Target~`Alpha^N1^SSingle~`-~`Minimum^N3^SIcons~`Shown^N4^SAction~`Captions^B^SSpellFlash~`Color^T^Sa^N1^Sr^N1^Sg^N1^Sb^N1^t^SCopy~`To^SSurvival:~`AOE^SSpacing^N5^SQueue~`Direction^SRIGHT^SSpecialization^N255^SQueued~`Icon~`Size^N40^SPrimary~`Icon~`Size^N40^SEnabled^B^SDefault^B^SFont^SElvUI~`Font^SAOE~`-~`Minimum^N3^SPrimary~`Caption^Stargets^SPrimary~`Font~`Size^N12^SName^SSurvival:~`AOE^STalent~`Group^N0^SSingle~`-~`Maximum^N0^SPvE~`-~`Target~`Alpha^N1^SAuto~`-~`Minimum^N3^SPvE~`-~`Combat~`Alpha^N1^SPvP~`-~`Combat~`Alpha^N1^SScript^S^SPvE~`-~`Default~`Alpha^N1^SAOE~`-~`Maximum^N0^t^^]] )


end
