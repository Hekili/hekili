if UnitClassBase( 'player' ) ~= 'HUNTER' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID


local hunter = Hekili:NewSpecialization( 3 )

hunter:RegisterResource( Enum.PowerType.Focus )


hunter:RegisterTalents( {
    -- Beast Mastery

    intimidation                     = { 19577, 1, 19577 },
    animal_handler                   = { 87325, 1, 87325 },
    master_of_beasts                 = { 76657, 1, 76657 },
    improved_kill_command            = { 9494, 2, 35029, 35030 },
    one_with_nature                  = { 9490, 3, 82682, 82683, 82684 },
    bestial_discipline               = { 9492, 3, 19590, 19592, 82687 },
    pathfinding                      = { 9502, 2, 19559, 19560 },
    spirit_bond                      = { 9514, 2, 19578, 20895 },
    frenzy                           = { 9512, 3, 19621, 19622, 19623 },
    improved_mend_pet                = { 9510, 2, 19572, 19573 },
    cobra_strikes                    = { 9530, 3, 53256, 53259, 53260 },
    fervor                           = { 9504, 1, 82726 },
    focus_fire                       = { 9520, 1, 82692 },
    longevity                        = { 9534, 3, 53262, 53263, 53264 },
    killing_streak                   = { 9534, 2, 82748, 82749 },
    crouching_tiger_hidden_chimera   = { 11714, 2, 82898, 82899 },
    bestial_wrath                    = { 9524, 1, 19574 },
    ferocious_inspiration            = { 9518, 1, 34460 },
    kindred_spirits                  = { 9538, 2, 56314, 56315 },
    the_beast_within                 = { 9536, 1, 34692 },
    invigoration                     = { 9522, 2, 53252, 53253 },
    beast_mastery                    = { 9542, 1, 53270 },

    -- Marksmanship

    aimed_shot                       = { 19434, 1, 19434 },
    artisan_quiver                   = { 87326, 1, 87326 },
    wild_quiver                      = { 76659, 1, 76659 },
    go_for_the_throat                = { 9390, 2, 34950, 34954 },
    efficiency                       = { 9380, 2, 19416, 19417 },
    rapid_killing                    = { 9378, 2, 34948, 34949 },
    sic_em                           = { 9396, 2, 83340, 83356 },
    improved_stead_shot              = { 9402, 3, 53221, 53222, 53224 },
    careful_aim                      = { 9398, 2, 34482, 34483 },
    silencing_shot                   = { 9424, 1, 34490 },
    concussive_barrage               = { 9406, 2, 35100, 35102 },
    piercing_shots                   = { 11225, 3, 53234, 53237, 53238 },
    bombardment                      = { 9408, 2, 35104, 35110 },
    trueshot_aura                    = { 9412, 1, 19506 },
    termination                      = { 9416, 2, 83489, 83490 },
    resistance_is_futile             = { 9420, 2, 82893, 82894 },
    rapid_recuperation               = { 9422, 2, 53228, 53232 },
    master_marksman                  = { 9418, 3, 34485, 34486, 34487 },
    readiness                        = { 9404, 1, 23989 },
    posthaste                        = { 9426, 2, 83558, 83560 },
    marked_for_death                 = { 9428, 2, 53241, 53243 },
    chimera_shot                     = { 9430, 1, 53209 },

    -- Survival

    explosive_shot                   = { 53301, 1, 53301 },
    into_the_wilderness              = { 84729, 1, 84729 },
    essence_of_the_viper             = { 76658, 1, 76658 },
    hunter_vs_wild                   = { 9442, 3, 56339, 56340, 56341 },
    pathing                          = { 9432, 3, 52783, 52785, 52786 },
    improved_serpent_sting           = { 9450, 2, 19464, 82834 },
    survival_tactics                 = { 9444, 2, 19286, 19287 },
    trap_mastery                     = { 10753, 3, 19376, 63457, 63458 },
    entrapment                       = { 9440, 2, 19184, 19387 },
    point_of_no_escape               = { 9472, 2, 53298, 53299 },
    thrill_of_the_hunt               = { 9484, 3, 34497, 34498, 34499 },
    counterattack                    = { 9448, 1, 19306 },
    lock_and_load                    = { 9452, 2, 56342, 56343 },
    resourcefulness                  = { 9460, 3, 34491, 34492, 34493 },
    mirrored_blades                  = { 9482, 2, 83494, 83495 },
    tnt                              = { 9462, 2, 56333, 56336 },
    toxicology                       = { 9464, 2, 82832, 82833 },
    wyvern_sting                     = { 9468, 1, 19386 },
    noxious_stings                   = { 9474, 2, 53295, 53296 },
    hunting_party                    = { 9476, 1, 53290 },
    sniper_training                  = { 9478, 3, 53302, 53303, 53304 },
    serpent_spread                   = { 11698, 2, 87934, 87935 },
    black_arrow                      = { 9480, 1, 3674 },
} )


-- Auras
hunter:RegisterAuras( {
    aspect = {
        alias = { "aspect_of_the_cheetah", "aspect_of_the_hawk", "aspect_of_the_pack", "aspect_of_the_wild", "aspect_of_the_fox" },
        aliasMode = "first",
        aliasType = "buff",
    },

    -- Aspects

    -- 30% increased movement speed. Dazed if struck.
    aspect_of_the_cheetah = {
        id = 5118,
        duration = 3600,
        max_stack = 1,
    },
    -- Steady Shot and Cobra Shot can be shot while moving. Melee attacks received instantly generate 2 Focus.
    aspect_of_the_fox = {
        id = 82661,
        duration = 3600,
        max_stack = 1
    },
    -- Increases ranged attack power by $s1.
    aspect_of_the_hawk = {
        id = 13165,
        duration = 3600,
        max_stack = 1
    },
    -- 30% increased movement speed. Dazed if struck.
    aspect_of_the_pack = {
        id = 13159,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    -- Nature resistance increased by 45.
    aspect_of_the_wild = {
        id = 20043,
        duration = 3600,
        max_stack = 1
    },

    -- Traps

    -- Fire damage every 2 seconds.
    explosive_trap = {
        id = 80595,
        duration = 20,
        max_stack = 1,
        copy = { 80595, 43446, 13812, "explosive_trap_effect" }
    },
    -- Frozen.
    freezing_trap = {
        id = 3355,
        duration = function() return 60 + (60 * 0.1 * talent.trap_mastery.rank) end,
        max_stack = 1,
    },
    -- Reduces movement speed by 50%.
    ice_trap = {
        id = 63487,
        duration = 30,
        max_stack = 1,
        copy = "ice_trap_effect"
    },
    -- Suffering 24225 to 26775 Fire damage every 3 sec.
    immolation_trap = {
        id = 99838,
        duration = 30,
        max_stack = 1
    },
    -- Snake trap
    -- Movement slowed by 50%.
    crippling_poison = {
        id = 25809,
        duration = 12,
        max_stack = 1
    },
    -- Snake trap
    -- Nature damage inflicted every 2 sec.
    deadly_poison = {
        id = 34655,
        duration = 8,
        max_stack = 5
    },
    --Snake trap
    -- Casting speed slowed by 30%.
    mind_numbing_poison = {
        id = 25810,
        duration = 12,
        max_stack = 1
    },

    --Tracking
    track = {
        alias = { "track_beasts", "track_demons", "track_dragonkin", "track_elementals", "track_giants", "track_hidden", "track_humanoids", "track_undead" },
        aliasMode = "first",
        aliasType = "buff",
    },
    -- Tracking Beasts.
    track_beasts = {
        id = 1494,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Demons.
    track_demons = {
        id = 19878,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Dragonkin.
    track_dragonkin = {
        id = 19879,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Elementals.
    track_elementals = {
        id = 19880,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Giants.
    track_giants = {
        id = 19882,
        duration = 3600,
        max_stack = 1,
    },
    -- Greatly increases stealth detection.
    track_hidden = {
        id = 19885,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Humanoids.
    track_humanoids = {
        id = 19883,
        duration = 3600,
        max_stack = 1,
    },
    -- Tracking Undead.
    track_undead = {
        id = 19884,
        duration = 3600,
        max_stack = 1,
    },

    -- Hunter Buffs

    -- Firing at the target.
    auto_shot = {
        id = 75,
        duration = 3600,
        max_stack = 1,
    },
    -- Untargetable by ranged attacks. Reducing the range at which enemy creatures will detect you.
    camouflage = {
        id = 51755,
        duration = 60,
        max_stack = 1
    },
    -- Deflecting melee attacks, ranged attacks, and spells. Damage taken reduced by 30%.
    deterrence = {
        id = 19263,
        duration = 5,
        max_stack = 1
    },
    -- You attempt to disengage from combat, leaping backwards.
    disengage = {
        id = 781,
        duration = 1,
        max_stack = 1
    },
    -- Vision is enhanced.
    eagle_eye = {
        id = 6197,
        duration = 60,
        max_stack = 1
    },
    -- Feigning death.
    feign_death = {
        id = 5384,
        duration = 360,
        max_stack = 1
    },
    -- Hidden and invisible units are revealed.
    flare = {
        id = 94528,
        duration = 20,
        max_stack = 1
    },
    -- Immune to root and movement impairing effects.
    masters_call = {
        id = 54216,
        duration = 4,
        max_stack = 1
    },
    -- Heals 5% of the pets health every 2 sec.
    mend_pet = {
        id = 136,
        duration = 10,
        tick_time = 2,
        max_stack = 1,
        generate = function( t )
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", class.auras.mend_pet.id )

            if name then
                t.count = 1
                t.applied = expires - duration
                t.expires = expires
                t.caster = "pet"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    -- Redirecting threat.
    misdirection = {
        id = 34477,
        duration = 30,
        max_stack = 1,
    },
    -- Increases ranged attack speed by 40%.
    rapid_fire = {
        id = 3045,
        duration = 15,
        max_stack = 1,
    },
    -- Next trap used will allow you to choose a target location to place it within 40 yards.
    trap_launcher = {
        id = 77769,
        duration = 15,
        max_stack = 1,
    },

    -- Hunter Debuffs

    -- Lore revealed.
    beast_lore = {
        id = 1462,
        duration = 30,
        max_stack = 1,
    },
    -- Movement slowed by 50%.
    -- ALT: Glyph of Concussive Shot - Maximum run speed limited.
    concussive_shot = {
        id = 5116,
        duration = 6,
        max_stack = 1,
    },
    -- Distracted.
    distracting_shot = {
        id = 20736,
        duration = 6,
        max_stack = 1,
        copy = { 20736 },
    },
    -- All attackers gain 0 ranged attack power against this target. Can be seen while stealthed or invisible.
    hunters_mark = {
        id = 1130,
        duration = 300,
        max_stack = 1,
        shared = "target"
    },
    -- Feared.
    scare_beast = {
        id = 1513,
        duration = 20,
        max_stack = 1
    },
    -- Causes Nature damage every 3 seconds.
    serpent_sting = {
        id = 1978,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    -- Taming pet.
    tame_beast = {
        id = 1515,
        duration = 10,
        max_stack = 1,
    },
    -- Healing received reduced by 25%
    widow_venom = {
        id = 82654,
        duration = 30,
        max_stack = 1,
    },
    -- Movement speed reduced by 50%.
    wing_clip = {
        id = 2974,
        duration = 10,
        max_stack = 1
    },

    -- Beast Mastery Buffs

    -- Enraged.
    bestial_wrath = {
        id = 19574,
        duration = 10,
        max_stack = 1,
        generate = function( t )
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 19574 )

            if name then
                t.count = 1
                t.applied = expires - duration
                t.expires = expires
                t.caster = "pet"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    -- Pet's critical strike chance with Basic Attacks increased by 100%.
    cobra_strikes = {
        id = 53257,
        duration = 15,
        max_stack = 2,
    },
    -- Stuns the target for 3 sec.
    intimidation = {
        id = 19577,
        duration = 15,
        max_stack = 1,
        generate = function( t )
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 19577 )

            if name then
                t.count = 1
                t.applied = expires - duration
                t.expires = expires
                t.caster = "pet"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    -- All damage increased by 3%.
    ferocious_inspiration = {
        id = 75447,
        duration = 3600,
        max_stack = 1,
        shared = "player",
    },
    -- Ranged haste increased by 3%.
    focus_fire = {
        id = 82692,
        duration = 20,
        max_stack = 1
    },
    -- Attack speed increased by $s1.
    frenzy_effect = {
        id = 19615,
        duration = 10,
        max_stack = 5,
        generate = function( t )
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 19615 )

            if name then
                t.count = count
                t.applied = expires - duration
                t.expires = expires
                t.caster = "pet"
                return
            end

            t.count = 0
            t.applied = 0
            t.expires = 0
            t.caster = "nobody"
        end,
    },
    -- Ready to kill.
    kill_command = {
        id = 83381,
        duration = 1,
        max_stack = 1,
    },
    -- Damage of your next Kill Command increased by 10/20%, and the Focus cost is reduced by 5.
    killing_streak = {
        id = function()
            if talent.killing_streak.rank == 1 then return 94006 end
            if talent.killing_streak.rank == 2 then return 94007 end
        end,
        duration = 8,
        max_stack = 1,
        copy = { 94006, 94007 }
    },
    -- While your pet is active, you and your pet will regenerate 1/2% of total health every 10 sec.
    spirit_bond = {
        id = function()
            if talent.spirit_bond.rank == 1 then return 19579 end
            if talent.spirit_bond.rank == 2 then return 24529 end
        end,
        duration = 3600,
        max_stack = 1,
        copy = { 19579, 24529 }
    },
    -- Enraged.
    the_beast_within = {
        id = 38373,
        duration = 18,
        max_stack = 1,
    },

    -- Beast Mastery Debuffs

    -- Stunned.
    intimidation_debuff = {
        id = 24394,
        duration = 3,
        max_stack = 1,
    },

    -- Marksmanship Buffs

    -- Focus cost of Multi-Shot is reduced by 0%.
    bombardment = {
        id = 82921,
        duration = 5,
        max_stack = 1,
    },
    -- Ranged attack speed increased by 0%.
    improved_steady_shot = {
        id = 53220,
        duration = 8,
        max_stack = 1,
    },
    -- After 5 stacks, your next Aimed Shot will be instant cast.
    ready_set_aim = {
        id = 82925,
        duration = 30,
        max_stack = 5,
    },
    -- Aimed Shot cast time and focus cost reduced by 100%.
    fire = {
        id = 82926,
        duration = 10,
        max_stack = 1,
    },
    -- Damage of your next Aimed Shot, Steady Shot or Cobra Shot increased by 10/20%.
    rapid_killing = {
        id = function()
            if talent.rapid_killing.rank == 1 then return 35098 end
            if talent.rapid_killing.rank == 2 then return 35099 end
        end,
        duration = 20,
        max_stack = 1,
        copy = { 35098, 35099 }
    },
    rapid_recuperation = {
        id = function()
            if talent.rapid_recuperation.rank == 1 then return 53230 end
            if talent.rapid_recuperation.rank == 2 then return 54227 end
        end,
        duration = 15,
        max_stack = 1,
        copy = { 53230, 54227 }
    },
    -- Next Kill Command on your marked target refunds 100% of the Focus cost.
    resistance_is_futile = {
        id = 82897,
        duration = 8,
        max_stack = 1,
    },
    -- The cost of your pet's next Bite, Claw, or Smack attack is reduced by 50/100% Focus.
    sic_em = {
        id = function()
            if talent.sic_em.rank == 1 then return 83359 end
            if talent.sic_em.rank == 2 then return 89388 end
        end,
        duration = 12,
        max_stack = 1,
        copy = { 83359, 89388 }
    },
    -- Increases melee attack power by 20% and ranged attack power by 10%.
    trueshot_aura = {
        id = 19506,
        duration = 3600,
        max_stack = 1,
    },

    -- Marksmanship Debuffs

    -- Bleeding.
    piercing_shots = {
        id = 63468,
        duration = 8,
        max_stack = 1,
        copy = { 63468, 413848 }
    },
    -- Dazed.
    concussive_barrage = {
        id = 35101,
        duration = 4,
        max_stack = 1,
    },
    -- All attackers gain 0 ranged attack power against this target.
    marked_for_death = {
        id = 88691,
        duration = 15,
        max_stack = 1,
    },
    -- Silenced.
    silencing_shot = {
        id = 34490,
        duration = 3,
        max_stack = 1,
    },

    -- Survival Buffs

    counterattack_usable = {
        duration = 5,
        max_stack = 1,
    },
    -- Melee and ranged attack speed increased by 10%.
    hunting_party = {
        id = 53290,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    -- Your Explosive Shot triggers no cooldown and costs no Focus.
    lock_and_load = {
        id = 56453,
        duration = 12,
        max_stack = 2,
    },
    -- Movement speed increased by 15/30%
    posthaste = {
        id = 83559,
        duration = 4,
        max_stack = 1,
    },
    -- Damage done by your Steady Shot and Cobra Shot increased by 2/4/6%.
    sniper_training = {
        id = function()
            if talent.sniper_training.rank == 1 then return 64418 end
            if talent.sniper_training.rank == 2 then return 64419 end
            if talent.sniper_training.rank == 3 then return 64420 end
        end,
        duration = 15,
        max_stack = 1,
        copy = { 64418, 64419, 64420 }
    },

    -- Survival Debuffs

    -- Shadow damage every 2 seconds.
    black_arrow = {
        id = 3674,
        duration = 20,
        tick_time = 2,
        max_stack = 1,
    },
    -- Immobile.
    counterattack = {
        id = 19306,
        duration = 5,
        max_stack = 1,
    },
    -- Immobile.
    entrapment = {
        id = function()
            if talent.entrapment.rank == 1 then return 19185 end
            if talent.entrapment.rank == 2 then return 64803 end
        end,
        duration = function()
            if talent.entrapment.rank == 1 then return 2 end
            if talent.entrapment.rank == 2 then return 4 end
        end,
        max_stack = 1,
        copy = { 19185, 64803 }
    },
    -- Taking 411 Fire damage every second.
    explosive_shot = {
        id = 53301,
        duration = 2,
        tick_time = 1,
        max_stack = 1,
    },
    -- Disoriented.
    scatter_shot = {
        id = 19503,
        duration = 4,
        max_stack = 1,
    },
    -- Asleep.
    wyvern_sting = {
        id = 19386,
        duration = 30,
        max_stack = 1,
    },
    -- Taking Nature damage every 2 seconds.
    wyvern_sting_damage = {
        id = 24131,
        duration = 6,
        max_stack = 1,
        tick_time = 2
    },

    -- TODO: Do more hunter pet buffs/debuffs need tracking?

    -- Pet Buffs

    -- Increases your melee and ranged attack power by 10%.
    call_of_the_wild = {
        id = 53434,
        duration = 10,
        max_stack = 1,
    },
} )


-- Glyphs
hunter:RegisterGlyphs( {
    [56824] = "aimed_shot",
    [56841] = "arcane_shot",
    [57904] = "aspect_of_the_pack",
    [56830] = "bestial_wrath",
    [63065] = "chimera_shot",
    [56851] = "concussive_shot",
    [56856] = "dazzled_prey",
    [56850] = "deterrence",
    [56844] = "disengage",
    [63066] = "explosive_shot",
    [57903] = "feign_death",
    [56845] = "freezing_trap",
    [56847] = "ice_trap",
    [56846] = "immolation_trap",
    [56842] = "kill_command",
    [63067] = "kill_shot",
    [57870] = "lesser_proportion",
    [63068] = "masters_call",
    [56833] = "mending",
    [56829] = "misdirection",
    [56828] = "rapid_fire",
    [63086] = "raptor_strike",
    [57866] = "revive_pet",
    [57902] = "scare_beast",
    [63069] = "scatter_shot",
    [56832] = "serpent_sting",
    [56836] = "silencing_shot",
    [56849] = "snake_trap",
    [56826] = "steady_shot",
    [56857] = "trap_launcher",
    [56848] = "wyvern_sting",
} )


-- Logic for counterattack activation
local repeating = 0
local last_parry = 0

hunter:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
    local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, missType, _, _, _, _, _, critical = CombatLogGetCurrentEventInfo()

    -- print( subtype, sourceGUID, sourceName, destGUID, destName, destFlags, "A", spellID, "B", spellName, "C", missType )
    if destGUID == state.GUID and subtype:match( "_MISSED$" ) then
        if missType == "PARRY" then
            last_parry = GetTime()
        end
    end
end )

hunter:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( event, unit, _, spellID )
    if UnitIsUnit( "player", unit ) and spellID == 75 then
        repeating = GetTime()
    end
end )

hunter:RegisterEvent( "START_AUTOREPEAT_SPELL", function()
    repeating = GetTime()
end )

hunter:RegisterEvent( "STOP_AUTOREPEAT_SPELL", function()
    repeating = 0
end )

hunter:RegisterStateExpr( "time_to_auto", function()
    if buff.auto_shot.down then return 3600 end

    local last = action.auto_shot.lastCast
    local time_since = query_time - last

    local speed = UnitRangedDamage( "player" )
    return max( speed - ( time_since % speed ), moving and 0.5 or nil )
end )

hunter:RegisterStateExpr( "auto_shot_cast_remains", function()
    if buff.auto_shot.down then return 0 end
    if time_to_auto > 0.5 then return 0 end
    return time_to_auto
end )

hunter:RegisterHook( "reset_precast", function()
    if repeating > 0 then applyBuff( "auto_shot" ) end

    if IsUsableSpell( class.abilities.counterattack.id ) and last_parry > 0 and now - last_parry < 5 then applyBuff( "counterattack_usable", last_parry + 5 - now ) end
end )

-- Logic to track the Kill Shot Glyph lockout
hunter:RegisterStateExpr("kill_shot_glyph_cooldown", function()
    local start = state.cooldown.kill_shot_glyph_start
    if start > 0 then
        return max(0, 6 - (query_time - start))
    else
        return 0
    end
end )

hunter:RegisterStateExpr( "kill_shot_glyph_cooldown", function()
    return max( 0, state.cooldown.kill_shot_glyph - (query_time - state.cooldown.kill_shot_glyph_start) )
end )

-- TODO: Some work probably needs to be added for tracking target swapping with Explosive Shot and Serpent Sting

-- Abilities
hunter:RegisterAbilities( {
    -- Pets

    -- Summons your pet to you.
    call_pet = {
        id = 883,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132161,

        handler = function ()
            summonPet( "pet" )
        end,
    },
    -- Summons your second pet to you.
    call_pet_2 = {
        id = 83242,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132161,

        handler = function ()
            summonPet( "pet" )
        end,
    },
    -- Summons your third pet to you.
    call_pet_3 = {
        id = 83243,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132161,

        handler = function ()
            summonPet( "pet" )
        end,
    },
    -- Summons your fourth pet to you.
    call_pet_4 = {
        id = 83244,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132161,

        handler = function ()
            summonPet( "pet" )
        end,
    },
    -- Summons your fifth pet to you.
    call_pet_5 = {
        id = 83245,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132161,

        handler = function ()
            summonPet( "pet" )
        end,
    },
    -- Dismiss your pet.  Dismissing your pet will reduce its happiness by 50.
    dismiss_pet = {
        id = 2641,
        cast = 5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 136095,

        handler = function ()
            dismissPet()
        end,
    },
    -- Feed your pet the selected item, instantly restoring 50% of its total health. Cannot be used while in combat.
    feed_pet = {
        id = 6991,
        cast = 0,
        cooldown = 10,
        gcd = "off",

        startsCombat = false,
        texture = 132165,

        handler = function ()
            healPet( 0.5 )
        end,
    },
    -- Heals your pet for 25% of its total health over 10 sec.
    mend_pet = {
        id = 136,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132179,

        usable = function() return pet.active, "requires an active pet" end,

        handler = function ()
            applyBuff( "mend_pet" )
        end,
    },
    -- Revive your pet, returning it to life with 15% of its base health.
    revive_pet = {
        id = 982,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132163,

        handler = function ()
            summonPet( "pet" )
        end,
    },
    -- Begins taming a beast to be your companion. If you lose the beast's attention for any reason, the taming process will fail.
    tame_beast = {
        id = 1515,
        cast = 10,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132164,

        usable = function() return not pet.active, "cannot have a pet" end,

        handler = function ()
            applyDebuff( "target", "tame_beast" )
        end,
    },

    -- Aspects

    -- The Hunter takes on the aspects of a cheetah, increasing movement speed by 30%. If the Hunter is struck, he will be dazed for 4 sec. Only one Aspect can be active at a time.
    aspect_of_the_cheetah = {
        id = 5118,
        cast = 0,
        cooldown = 2,
        gcd = "off",

        startsCombat = false,
        texture = 132242,

        nobuff = "aspect_of_the_cheetah",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_cheetah" )
        end,
    },
    -- The Hunter takes on the aspects of a fox, allowing him to shoot Steady Shot and Cobra Shot while moving and causing him to gain 2 Focus whenever he receives a melee attack.
    aspect_of_the_fox = {
        id = 82661,
        cast = 0,
        cooldown = 2,
        gcd = "off",

        startsCombat = false,
        texture = 458223,

        nobuff = "aspect_of_the_fox",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_fox" )
        end,
    },
    -- The Hunter takes on the aspects of a hawk, increasing ranged attack power by $s1. Only one Aspect can be active at a time.
    aspect_of_the_hawk = {
        id = 13165,
        cast = 0,
        cooldown = 2,
        gcd = "off",

        startsCombat = false,
        texture = 136076,

        nobuff = "aspect_of_the_hawk",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_hawk" )
        end,
    },
    -- The Hunter and raid members within 40 yards take on the aspects of a pack of cheetahs, increasing movement speed by 30%. 
    -- If you are struck under the effect of this aspect, you will be dazed for 4 sec. Only one Aspect can be active at a time.
    aspect_of_the_pack = {
        id = 13159,
        cast = 0,
        cooldown = 2,
        gcd = "off",

        startsCombat = false,
        texture = 132267,

        nobuff = "aspect_of_the_pack",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_pack" )
        end,
    },
    -- The Hunter, group and raid members within 30 yards take on the aspect of the wild, increasing Nature resistance by 195. Only one Aspect can be active at a time.
    aspect_of_the_wild = {
        id = 20043,
        cast = 0,
        cooldown = 2,
        gcd = "off",

        startsCombat = false,
        texture = 136074,

        nobuff = "aspect_of_the_wild",

        handler = function ()
            removeBuff( "aspect" )
            applyBuff( "aspect_of_the_wild" )
        end,
    },

    -- Traps

    -- Place a fire trap that explodes when an enemy approaches, causing Fire damage and burning all enemies for 290 additional
    -- Fire damage over 20 sec to all within 10 yards. Trap will exist for 1 min.
    explosive_trap = {
        id = 13813,
        cast = 0,
        cooldown = function()
            if talent.resourcefulness.rank == 1 then
                return 28
            elseif talent.resourcefulness.rank == 2 then
                return 26
            elseif talent.resourcefulness.rank == 3 then
                return 24
            else
                return 30
            end
        end,
        gcd = "spell",

        startsCombat = false,
        texture = 135826,

        handler = function ()
            if buff.trap_launcher.up then
                removeBuff( "trap_launcher" )
            end
        end,
    },
    -- Launch a frost trap to the target location that freezes the first enemy that approaches, preventing all action for up to 1 min.
    -- Any damage caused will break the ice. Only one target can be Freezing Trapped at a time. Trap will exist for 1 min.
    freezing_trap = {
        id = function()
            if buff.trap_launcher.up then return 60192
            else return 1499 end
        end,
        cast = 0,
        cooldown = function()
            if talent.resourcefulness.rank == 1 then
                return 28
            elseif talent.resourcefulness.rank == 2 then
                return 26
            elseif talent.resourcefulness.rank == 3 then
                return 24
            else
                return 30
            end
        end,
        gcd = "spell",

        startsCombat = false,
        texture = 135834,

        handler = function ()
            if buff.trap_launcher.up then
                removeBuff( "trap_launcher" )
            end
        end,
    },
    -- Place a frost trap that creates an ice slick around itself for 30 sec when the first enemy approaches it.
    -- All enemies within 10 yards will be slowed by 50% while in the area of effect. Trap will exist for 1 min.
    ice_trap = {
        id = function()
            if buff.trap_launcher.up then return 82941
            else return 13809 end
        end,
        cast = 0,
        cooldown = function()
            if talent.resourcefulness.rank == 1 then
                return 28
            elseif talent.resourcefulness.rank == 2 then
                return 26
            elseif talent.resourcefulness.rank == 3 then
                return 24
            else
                return 30
            end
        end,
        gcd = "spell",

        startsCombat = true,
        texture = 135840,

        handler = function ()
            if buff.trap_launcher.up then
                removeBuff( "trap_launcher" )
            end
        end,
    },
    -- Place a fire trap that will burn the first enemy to approach for ((Ranged attack power * 0.02 + 576) * 5)] Fire damage over 15 sec.
    -- Trap will exist for 1 min.
    immolation_trap = {
        id = function()
            if buff.trap_launcher.up then return 82945
            else return 13795 end
        end,
        cast = 0,
        cooldown = function()
            if talent.resourcefulness.rank == 1 then
                return 28
            elseif talent.resourcefulness.rank == 2 then
                return 26
            elseif talent.resourcefulness.rank == 3 then
                return 24
            else
                return 30
            end
        end,
        gcd = "spell",

        startsCombat = false,
        texture = 135813,

        handler = function ()
            if buff.trap_launcher.up then
                removeBuff( "trap_launcher" )
            end
        end,
    },
    -- Place a nature trap that will release several venomous snakes to attack the first enemy to approach.
    -- The snakes will die after 15 sec. Trap will exist for 1 min.
    snake_trap = {
        id = function()
            if buff.trap_launcher.up then return 82948
            else return 34600 end
        end,
        cast = 0,
        cooldown = function()
            if talent.resourcefulness.rank == 1 then
                return 28
            elseif talent.resourcefulness.rank == 2 then
                return 26
            elseif talent.resourcefulness.rank == 3 then
                return 24
            else
                return 30
            end
        end,
        gcd = "spell",

        startsCombat = false,
        texture = 132211,

        handler = function ()
            if buff.trap_launcher.up then
                removeBuff( "trap_launcher" )
            end
        end,
    },

    -- Tracking

    -- Shows the location of all nearby beasts on the minimap.  Only one form of tracking can be active at a time.
    track_beasts = {
        id = 1494,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 132328,

        nobuff = "track_beasts",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_beasts" )
        end,
    },
    -- Shows the location of all nearby demons on the minimap.  Only one form of tracking can be active at a time.
    track_demons = {
        id = 19878,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 136217,

        nobuff = "track_demons",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_demons" )
        end,
    },
    -- Shows the location of all nearby dragonkin on the minimap.  Only one form of tracking can be active at a time.
    track_dragonkin = {
        id = 19879,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 134153,

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_dragonkin" )
        end,
    },
    -- Shows the location of all nearby elementals on the minimap.  Only one form of tracking can be active at a time.
    track_elementals = {
        id = 19880,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 135861,

        nobuff = "track_elementals",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_elementals" )
        end,
    },
    -- Shows the location of all nearby giants on the minimap.  Only one form of tracking can be active at a time.
    track_giants = {
        id = 19882,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 132275,

        nobuff = "track_giants",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_giants" )
        end,
    },
    -- Greatly increases stealth detection and shows hidden units within detection range on the minimap.  Only one form of tracking can be active at a time.
    track_hidden = {
        id = 19885,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 132320,

        nobuff = "track_hidden",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_hidden" )
        end,
    },
    -- Shows the location of all nearby humanoids on the minimap.  Only one form of tracking can be active at a time.
    track_humanoids = {
        id = 19883,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 135942,

        nobuff = "track_humanoids",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_humanoids" )
        end,
    },
    -- Shows the location of all nearby undead on the minimap.  Only one form of tracking can be active at a time.
    track_undead = {
        id = 19884,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        startsCombat = false,
        texture = 136142,

        nobuff = "track_undead",

        handler = function ()
            removeBuff( "track" )
            applyBuff( "track_undead" )
        end,
    },

    -- Hunter Buff Abilities

    -- You blend into your surroundings, causing you and your pet to be untargetable by ranged attacks. Also reduces the range at which enemy creatures can detect you, and provides stealth while stationary.
    -- You can lay traps while camouflaged, but any damage done by you or your pet will cancel the effect. Cannot be cast while in combat. Lasts for 1 min.
    camouflage = {
        id = 51755,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = function() if buff.bestial_wrath.up then return 10 else return 20 end end,
        spendType = "focus",

        startsCombat = false,
        texture = 132171,

        nobuff = "camouflage",

        handler = function ()
            applyBuff( "camouflage" )
        end,
    },
    -- When activated, causes you to deflect melee attacks, ranged attacks, and spells, and reduces all damage taken by 30%. While Deterrence is active, you cannot attack. Lasts 5 sec.
    deterrence = {
        id = 19263,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 132369,

        nobuff = "deterrence",

        handler = function ()
            applyBuff( "deterrence" )
        end,
    },
    -- You attempt to disengage from combat, leaping backwards. Can only be used while in combat.
    disengage = {
        id = 781,
        cast = 0,
        cooldown = function() return glyph.disengage.enabled and 20 or 25 end,
        gcd = "off",

        startsCombat = false,
        texture = 132294,

        handler = function ()
            setDistance( 20 + target.distance )
        end,
    },
    -- Zooms in the Hunter's vision. Only usable outdoors. Lasts 1 min.
    eagle_eye = {
        id = 6197,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132172,

        handler = function ()
            applyBuff( "eagle_eye" )
        end,
    },
    -- Feign death, tricking enemies into ignoring you. Lasts up to 6 min.
    feign_death = {
        id = 5384,
        cast = 0,
        cooldown = function() return glyph.feign_death.enabled and 25 or 30 end,
        gcd = "off",

        startsCombat = false,
        texture = 132293,

        nobuff = "feign_death",

        handler = function ()
            applyBuff( "feign_death" )
        end,
    },
    -- Your pet attempts to remove all root and movement impairing effects from itself and its target, and causes your pet and its target to be immune to all such effects for 4 sec.
    masters_call = {
        id = 53271,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        startsCombat = false,
        texture = 236189,

        usable = function() return pet.active, "requires an active pet" end,

        handler = function ()
            applyBuff( "masters_call" )
        end,
    },
    -- The current party or raid member targeted will receive the threat caused by your next damaging attack and all actions taken for 4 sec afterwards.
    -- Transferred threat is not permanent, and will fade after 30 sec.
    misdirection = {
        id = 34477,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 132180,

        usable = function() return pet.active or group, "requires an active pet or a group" end,

        handler = function ()
            applyBuff( "misdirection" )
        end,
    },
    -- When used, your next Trap can be launched to a target location within 40 yards. Lasts for 15 sec.
    trap_launcher = {
        id = 77769,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 461122,

        nobuff = "trap_launcher",

        handler = function ()
            applyBuff( "trap_launcher" )
        end,
    },
    -- Increases ranged attack speed by 40% for 15 sec.
    rapid_fire = {
        id = 3045,
        cast = 0,
        cooldown = function()
            if talent.posthaste.rank == 1 then
                return 240
            elseif talent.posthaste.rank == 2 then
                return 180
            else
                return 300
            end
        end,
        gcd = "off",

        startsCombat = false,
        texture = 132208,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "rapid_fire" )
            if talent.rapid_recuperation.enabled then applyBuff( "rapid_recuperation" ) end
        end,
    },

    -- Hunter Debuff Abilities

    -- Gather information about the target beast. The tooltip will display damage, health, armor, any special resistances, and diet.
    -- In addition, Beast Lore will reveal whether or not the creature is tameable and what abilities the tamed creature has.
    beast_lore = {
        id = 1462,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132270,

        handler = function ()
            applyDebuff( "target", "beast_lore" )
        end,
    },
    -- Dazes the target, slowing movement speed by 50% for 4 sec.
    concussive_shot = {
        id = 5116,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        startsCombat = true,
        texture = 135860,

        handler = function ()
            applyDebuff( "target", "concussive_shot" )
        end,
    },
    -- Distracts the target to attack you, but has no effect if the target is already attacking you. Lasts 6 sec.
    distracting_shot = {
        id = 20736,
        cast = 0,
        cooldown = 8,
        gcd = "spell",


        startsCombat = true,
        texture = 135736,

        handler = function ()
            applyDebuff( "target", "distracting_shot" )
        end,
    },
    -- Exposes all hidden and invisible enemies within 10 yards of the targeted area for 20 sec.
    flare = {
        id = 1543,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        startsCombat = false,
        texture = 135815,

        handler = function ()
        end,
    },
    -- Places the Hunter's Mark on the target, increasing the ranged attack power of all attackers against that target by 0.
    -- In addition, the target of this ability can always be seen by the hunter whether it stealths or turns invisible.
    -- The target also appears on the mini-map. Lasts for 5 min.
    hunters_mark = {
        id = 1130,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132212,

        handler = function ()
            applyDebuff( "target", "hunters_mark" )
        end,
    },
    -- Scares a beast, causing it to run in fear for up to 20 sec. Damage caused may interrupt the effect. Only one beast can be feared at a time.
    scare_beast = {
        id = 1513,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = function() if buff.the_beast_within.up then return 13 else return 25 end end,
        spendType = "focus",

        startsCombat = true,
        texture = 132118,

        usable = function() return target.is_beast, "requires beast target" end,

        handler = function ()
            applyDebuff( "target", "scare_beast" )
        end,
    },
    -- A short-range shot that deals 50% weapon damage and disorients the target for 4 sec. Any damage caused will remove the effect. Turns off your attack when used.
    scatter_shot = {
        id = 19503,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "scatter_shot",
        startsCombat = true,
        texture = 132153,

        handler = function ()
            applyDebuff( "target", "scatter_shot" )
        end,
    },
    -- Causes [Ranged attack power * 0.4 + (460 * 15 / 3)] Nature damage over 15 sec.
    serpent_sting = {
        id = 1978,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() if buff.the_beast_within.up then return 13 else return 25 end end,
        spendType = "focus",

        startsCombat = true,
        texture = 132204,

        handler = function ()
            applyDebuff( "target", "serpent_sting" )
        end,
    },
    -- Attempts to remove 1 Enrage and 1 Magic effect from an enemy target.
    tranquilizing_shot = {
        id = 19801,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = function() if buff.the_beast_within.up then return 10 else return 20 end end,
        spendType = "focus",

        startsCombat = true,
        texture = 136020,

        debuff = function()
            return debuff.dispellable_enrage.up and "dispellable_enrage" or "dispellable_magic"
        end,

        handler = function ()
            removeDebuff( "target", "dispellable_enrage" )
            removeDebuff( "target", "dispellable_magic" )
        end,
    },
    -- A venomous shot that reduces the effectiveness of any healing taken for 30 sec.
    widow_venom = {
        id = 82654,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() if buff.the_beast_within.up then return 8 else return 15 end end,
        spendType = "focus",

        startsCombat = true,
        texture = 236200,

        handler = function ()
            applyDebuff( "target", "widow_venom" )
        end,
    },
    -- Maims the enemy, reducing the target's movement speed by 50% for 10 sec.
    wing_clip = {
        id = 2974,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132309,

        usable = function() return target.distance < 10, "requires melee range" end,

        handler = function()
            applyDebuff( "target", "wing_clip" )
        end,
    },

    -- Hunter Damage Abilities

    -- An instant shot that causes 65 Arcane damage.
    arcane_shot = {
        id = 3044,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            local cost = 25

            if talent.efficiency.rank == 1 then
                cost = cost - 1
            elseif talent.efficiency.rank == 2 then
                cost = cost - 2
            elseif talent.efficiency.rank == 3 then
                cost = cost -3
            end

            if buff.the_beast_within.up then
                cost = cost * 0.5
            end

            return cost
        end,
        spendType = "focus",

        startsCombat = true,
        texture = 132218,

        handler = function ()
            if buff.rapid_killing.up then
                removeBuff( "rapid_killing" )
            end
        end,
    },
    -- Automatically shoots the target until cancelled.
    auto_shot = {
        id = 75,
        cast = 0,
        cooldown = function() return UnitRangedDamage( "player" ) end,
        gcd = "off",

        startsCombat = false, -- it kinda doesn't.
        -- texture = 132369,

        nobuff = "auto_shot",

        handler = function()
            applyBuff( "auto_shot" )
        end
    },
    -- Deals weapon damage plus [277 + (Ranged attack power * 0.017)] in the form of Nature damage and increases the duration of your Serpent Sting on the target by 6 sec. 
    -- Generates 9 Focus.
    cobra_shot = {
        id = 77767,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 461114,

        handler = function ()
            gain( 9, "focus" )
        end,
    },
    -- A strike that becomes active after parrying an opponent's attack. This attack deals (Attack power * 0.2 + 321) damage and immobilizes the target for 5 sec.
    -- Counterattack cannot be blocked, dodged, or parried.
    counterattack = {
        id = 19306,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        talent = "counterattack",
        startsCombat = true,
        texture = 132336,

        buff = "counterattack_usable",

        usable = function() return target.distance < 10, "requires melee range" end,

        handler = function ()
            removeBufF( "counterattack_usable" )
            applyDebuff( "target", "counterattack" )
        end,
    },
    -- You attempt to finish the wounded target off, firing a long range attack dealing 116% weapon damage plus (Ranged attack power * 0.45 + 543).
    -- Kill Shot can only be used on enemies that have 20% or less health.
    kill_shot = {
        id = 53351,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        startsCombat = true,
        texture = 236174,
        velocity = 40,

        usable = function() return target.health.pct < 20, "enemy health must be below 20 percent" end,

        handler = function ()
        end,

        impact = function ()
            if glyph.kill_shot.enabled and kill_shot_glyph_cooldown == 0 then
                state.cooldown.kill_shot_glyph_start = query_time
            end
        end,
    },
    -- Fires several missiles, hitting your current target and all enemies within 8 yards of that target for 121% of weapon damage.
    multishot = {
        id = 2643,
        cast = 0,
        cooldown = 40,
        gcd = "spell",

        spend = function() 
            local cost = 40

            if buff.bombardment.up then
                cost = cost - ( cost * 0.25 )
            end

            if buff.the_beast_within.up then
                cost = cost * 0.5
            end

            return cost
        end,
        spendType = "focus",

        startsCombat = true,
        texture = 132330,
        velocity = 40,

        handler = function ()
        end,

        impact = function ()
            if talent.concussive_barrage.enabled then applyDebuff( "target", "concussive_barrage" ) end
        end,
    },
    -- An attack that instantly deals your normal weapon damage plus 374.
    raptor_strike = {
        id = 2973,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        startsCombat = true,
        texture = 132223,

        handler = function ()
        end,
    },
    -- A steady shot that causes 62% weapon damage plus (Ranged attack power * 0.021 + 280). Generates 9 Focus.
    steady_shot = {
        id = 56641,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132213,

        handler = function ()
            gain( 9, "focus" )
        end,
    },

    -- Beast Mastery Buff Abilities

    -- Send your pet into a rage causing 20% additional damage for 10 sec. The beast does not feel pity or remorse or fear and it cannot be stopped unless killed.
    bestial_wrath = {
        id = 19574,
        cast = 0,
        cooldown = function() return ( glyph.bestial_wrath.enabled and 100 or 120 ) * ( 1 - 0.1 * talent.longevity.rank ) end,
        gcd = "off",

        talent = "bestial_wrath",
        startsCombat = false,
        texture = 132127,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "bestial_wrath" )
            if talent.the_beast_within.enabled then applyBuff( "the_beast_within" ) end
        end,
    },
    -- Command your pet to intimidate the target, causing a high amount of threat and stunning the target for 3 sec. Lasts 15 sec.
    intimidation = {
        id = 19577,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        startsCombat = false,
        texture = 132111,


        handler = function ()
            applyBuff( "intimidation" )
        end,
    },
    -- Consumes your pet's Frenzy Effect stack, restoring 4 Focus to your pet and increasing your ranged haste by 3% for each Frenzy Effect stack consumed. Lasts for 20 sec.
    focus_fire = {
        id = 82692,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        startsCombat = false,
        texture = 461846,

        nobuff = "focus_fire",

        handler = function ()
            applyBuff( "focus_fire" )
            removeBuff( "frenzy_effect" )
        end,
    },

    -- Beast Mastery Damage Abilities

    -- Give the command to kill, causing your pet to instantly inflict [(849 + (Ranged attack power * 0.516)) * 1] damage to its target.
    -- The pet must be in combat and within 5 yards of the target to Kill Command.
    kill_command = {
        id = 34026,
        cast = 0,
        cooldown = function() return 60 - ( 10 * talent.catlike_reflexes.rank ) end,
        gcd = "off",

        spend = function() 
            local cost = 40

            if buff.killing_streak.up and talent.killing_streak.rank == 1 then
                cost = cost - 5
            end
            if buff.killing_streak.up and talent.killing_streak.rank == 2 then
                cost = cost - 10
            end

            if glyph.kill_command.enabled then
                cost = cost - 3
            end

            if buff.the_beast_within.up then
                cost = cost * 0.5
            end

            return cost
        end,
        spendType = "focus",

        startsCombat = true,
        texture = 132176,

        usable = function() return pet.active, "requires a pet" end,

        handler = function ()
            applyBuff( "kill_command" )
        end,
    },

    -- Marksmanship Buff Abilities

    -- Increases melee attack power by 20% and ranged attack power by 10% of party and raid members within 100 yards.
    trueshot_aura = {
        id = 19506,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        startsCombat = false,
        texture = 132329,

        nobuff = "trueshot_aura",

        handler = function ()
            applyBuff( "trueshot_aura" )
        end,
    },
    -- When activated, this ability immediately finishes the cooldown on all Hunter abilities.
    readiness = {
        id = 23989,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,
        texture = 132206,

        toggle = "cooldowns",

        handler = function ()
            -- TODO: Can't get these to work for some reason, needs to be fixed
            -- setCooldown( "rapid_fire", 0 )
            -- setCooldown( "chimera_shot", 0 )
            -- setcooldown( "kill_shot", 0 )
        end,
    },

    -- Marksmanship Debuff Abilities

    -- A shot that silences the target and interrupts spellcasting for 3 sec.
    silencing_shot = {
        id = 34490,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        startsCombat = true,
        texture = 132323,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "silencing_shot" )
        end,
    },

    -- Marksmanship Damage Abilities

    -- A powerful aimed shot that deals 132% ranged weapon damage plus [(Ranged attack power * 0.724) + 777].
    aimed_shot = {
        id = 19434,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() if buff.the_beast_within.up then return 25 else return 50 end end,
        spendType = "focus",

        talent = "aimed_shot",
        startsCombat = true,
        texture = 135130,

        handler = function ()
            removeBuff( "fire" )

            if talent.marked_for_death.rank == 1 and rng.roll(0.5) then
                applyDebuff( "target", "marked_for_death" )
            end
            if talent.marked_for_death.rank == 2 then
                applyDebuff( "target", "marked_for_death" )
            end
        end,
    },
    -- An instant shot that causes ranged weapon Nature damage plus (Ranged attack power * 0.732 + 1620), refreshing the duration of your Serpent Sting and healing you for 5% of your total health.
    chimera_shot = {
        id = 53209,
        cast = 0,
        cooldown = function() return glyph.chimera_shot.enabled and 9 or 10 end,
        gcd = "spell",

        spend = function()
            local cost = 50

            if talent.efficiency.rank == 1 then
                cost = cost - 2
            elseif talent.efficiency.rank == 2 then
                cost = cost - 4
            elseif talent.efficiency.rank == 3 then
                cost = cost - 6
            end

            if buff.the_beast_within.up then
                cost = cost * 0.5
            end

            return cost
        end,
        spendType = "focus",

        talent = "chimera_shot",
        startsCombat = true,
        texture = 236176,
        velocity = 40,

        handler = function ()
        end,

        impact = function ()
            if talent.concussive_barrage.enabled then applyDebuff( "target", "concussive_barrage" ) end
        end,
    },
    
    -- Survival Debuff Abilities

    -- Fires a Black Arrow at the target, dealing 2852 Shadow damage over 20 sec. Black Arrow shares a cooldown with other Fire Trap spells.
    black_arrow = {
        id = 3674,
        cast = 0,
        cooldown = function()
            if talent.resourcefulness.rank == 1 then
                return 28
            elseif talent.resourcefulness.rank == 2 then
                return 26
            elseif talent.resourcefulness.rank == 3 then
                return 24
            else
                return 30
            end
        end,
        gcd = "spell",

        spend = function() if buff.the_beast_within.up then return 18 else return 35 end end,
        spendType = "focus",

        talent = "black_arrow",
        startsCombat = true,
        texture = 136181,

        handler = function ()
            applyDebuff( "target", "black_arrow" )
        end,
    },
    -- A stinging shot that puts the target to sleep for 30 sec.  Any damage will cancel the effect.  When the target wakes up, the Sting causes 300 Nature damage over 6 sec.  Only one Sting per Hunter can be active on the target at a time.
    wyvern_sting = {
        id = 19386,
        cast = 0,
        cooldown = function() return glyph.wyvern_sting.enabled and 54 or 60 end,
        gcd = "spell",

        spend = function() if buff.the_beast_within.up then return 10 else return 20 end end,
        spendType = "focus",

        talent = "wyvern_sting",
        startsCombat = true,
        texture = 135125,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "wyvern_sting" )
        end,
    },

    -- Survival Buff Abilities
    -- Instantly restores 50 Focus to you and your pet.
    fervor = {
        id = 82726,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 132160,

        toggle = "cooldowns",

        handler = function ()
            gain( 50, "focus" )
        end,
    },

    -- Survival Damage Abilities

    -- TODO: Fix explosive shot with lock and load, timeout is currently not working
    -- You fire an explosive charge into the enemy target, dealing 191-219 Fire damage. The charge will blast the target every second for an additional 2 sec.
    explosive_shot = {
        id = 53301,
        cast = 0,
        cooldown = function() return buff.lock_and_load.up and 0 or 6 end,
        gcd = "spell",

        spend = function()
            local cost = 50

            if talent.efficiency.rank == 1 then
                cost = cost - 2
            elseif talent.efficiency.rank == 2 then
                cost = cost - 4
            elseif talent.efficiency.rank == 3 then
                cost = cost - 6
            end

            if buff.the_beast_within.up then
                cost = cost * 0.5
            end

            return cost
        end,
        spendType = "focus",

        talent = "explosive_shot",
        startsCombat = true,
        texture = 236178,
        velocity = 20,

        handler = function ()
            removeStack( "lock_and_load" )
        end,

        impact = function()
            applyDebuff("target", "explosive_shot")
        end,
    },

    -- TODO: Are more pet abilities needed?
    -- Pet Abilities

    -- Your pet roars, increasing your pet's and your melee and ranged attack power by 10%.  Lasts 20 sec.
    call_of_the_wild = {
        id = 53434,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        startsCombat = false,
        texture = 236159,

        handler = function ()
            applyBuff( "call_of_the_wild" )
        end,
    },
} )


-- Settings
hunter:RegisterStateTable("assigned_aspect", setmetatable( {}, {
    __index = function( t, k )
        return settings.assigned_aspect == k
    end
}))

hunter:RegisterSetting("hunter_description", nil, {
    type = "description",
    name = "Adjust the settings below according to your playstyle preference. It is always recommended that you use a simulator "..
        "to determine the optimal values for these settings for your character."
})
hunter:RegisterSetting("hunter_description_footer", nil, {
    type = "description",
    name = "\n\n"
})

hunter:RegisterSetting("general_header", nil, {
    type = "header",
    name = "General"
})
hunter:RegisterSetting("maintain_aspect", true, {
    type = "toggle",
    name = "Maintain Aspect",
    desc = "When enabled, selected aspect will be recommended if it is down",
    width = "full",
    set = function( _, val )
        Hekili.DB.profile.specs[ 3 ].settings.maintain_aspect = val
    end
})
local aspects = {}
hunter:RegisterSetting( "assigned_aspect", "aspect_of_the_hawk", {
    type = "select",
    name = "Assigned Aspect",
    desc = "Select the Aspect that should be recommended by the addon.  It is referenced as |cff00ccff[Assigned Aspect]|r in your priority.",
    width = "full",
    values = function()
        table.wipe( aspects )

        aspects.aspect_of_the_hawk = class.abilityList.aspect_of_the_hawk
        aspects.aspect_of_the_fox = class.abilityList.aspect_of_the_fox
        aspects.aspect_of_the_cheetah = class.abilityList.aspect_of_the_cheetah
        aspects.aspect_of_the_pack = class.abilityList.aspect_of_the_pack
        aspects.aspect_of_the_wild = class.abilityList.aspect_of_the_wild

        return aspects
    end,
    set = function( _, val )
        Hekili.DB.profile.specs[ 3 ].settings.assigned_aspect = val
        class.abilities.assigned_aspect = class.abilities[ val ]
    end,
} )
hunter:RegisterSetting( "aspect_of_the_fox_swap", nil, {
    type = "toggle",
    name = "Suggest Fox",
    desc = "When enabled, the addon will recommend Aspect of the Fox when you are moving.\n\n"..
        "Aspect of the Fox allows you to cast Steady Shot and Cobra Shot while moving.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 3 ].settings.aspect_of_the_fox_swap = val
    end
})
hunter:RegisterSetting( "trap_launcher_macro", nil, {
    type = "toggle",
    name = "Trap Launcher Macro",
    desc = "Check on if you've combined Trap Launcher and your traps into one macro.\n\n"..
        "This will turn off recommendation to cast Trap Launcher.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 3 ].settings.trap_launcher_macro = val
    end
})
hunter:RegisterSetting( "recommend_misdirection" , nil, {
    type = "toggle",
    name = "Recommend Misdirection",
    desc = "Check on if you want the addon to recommend casting Misdirection on another target.\n\n"..
        "You will likely want to set up a macro for this!\n\n"..
        "This will override the Misdirection Only setting.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 3 ].settings.recommend_misdirection = val
    end

})
hunter:RegisterSetting( "opener_misdirect_only" , nil, {
    type = "toggle",
    name = "Opener Misdirection Only",
    desc = "Check on if you want the addon to recommend casting Misdirection only on your opener.\n\n"..
        "You will likely want to set up a macro for this!\n\n"..
        "This will be overridden by Recommend Misdirection.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 3 ].settings.opener_misdirect_only = val
    end

})
hunter:RegisterSetting( "call_of_the_wild_macro", false, {
    type = "toggle",
    name = "Rapid Fire / Call of the Wild Macro",
    desc = "Check on if you've combined Rapid Fire and Call of the Wild into one macro.\n\n"..
        "This will turn off recommendation to cast Call of the Wild.",
    width = "single",
    set = function( _, val )
        Hekili.DB.profile.specs[ 3 ].settings.call_of_the_wild_macro = val
    end
})

if (Hekili.Version:match( "^Dev" )) then
    hunter:RegisterSetting("hunter_debug_header", nil, {
        type = "header",
        name = "Debug"
    })
    hunter:RegisterSetting( "hunter_debug_description", nil, {
        type = "description",
        name = "Settings used for testing\n\n"
    })
    hunter:RegisterSetting( "dummy_ttd", 300, {
        type = "range",
        name = "Training Dummy Time To Die",
        desc = "Select the time to die to report when targeting a training dummy",
        width = "full",
        min = 0,
        softMax = 300,
        step = 1,
        set = function( _, val )
            Hekili.DB.profile.specs[ 3 ].settings.dummy_ttd = val
        end
    })
    hunter:RegisterSetting( "hunter_debug_footer", nil, {
        type = "description",
        name = "\n\n"
    })
end


hunter:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 1494,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "speed",

    package = "Beast Mastery (Himea Beta)",
    usePackSelector = true
} )


hunter:RegisterPack( "Beast Mastery (Himea Beta)", 20240509, [[Hekili:DR1EVTnos8plblGBl2uhzNK20I4a029WUTy3GIZ5q)pjrlrztujrDIu2nlc0N9Bi1dkjtkl74K7UIG8WKZBoZVHpI9e77SN7J4y7BNAn9cRlNynEY5wV16k7587tW2ZtqEFhTe(Jyue8ZpIrmEU7Fb)eNEFU7l)dsegL7(rmh9kb13hsr(cPYOzPEahR48e27p7Sn0n8fEJxU8mpehDMxiIXE9YmIpMD2cHuFDuHqF9QSy43NzpFrgjK)5y7f6TXZTNJY4ROP2ZLwbOlIVpUGEmZZE(DRiSCxX3Gjw6j5U0a4ZECcno3nKW4W0b00C3)a)Dsizm4fP0asiy7)cmO0yEVWdB55FrmNqRVGv495UF4R)zU7RZD)ncZJM6d8SsqWygIWPsg(lQpjGG9bfMsJYD)g9B39XpL7(jKG)FxgmKI4GdAfQbbRmIyv(xGpdd81uShnAbIN)LchNnoPAOFD2ziwc2J7qdC4RWoRqB((PKGzNSiliyCXCJZsgXWCojEjBCeIeZHVDkMBeytKLXy)YppEBXne1gq)XruRG0gIs9wHHLUvhrfxkXHOCrc5ruZcXne1UHe6FevRqC6vBrkjZjcLk9tFSuJnhESpDtSEUJimFc8zXmcURnpAcogN6upVdno8(Qm9FdhGYcv55GG8qHHofF0ruUFQajBgjM0IQmg2HWXrSMdMqLOengzfakMc(ViA45HdXPiPbkyNge4S0ZF2KMmKMfVTYruSWLeJVg7aUtebZUz6o5ZleJwRH1z7Mvge7cXvHPpl8E3VIsHPelgQLarCbKXAukbTiexWmhWXC4uhFc(01OWm8SxwUyYtHefq0o(zrr3lsJo3Y6vp8ahLUeZh3GXkv)b6)qPniq03sTmDich770KKrjGKrHG)3vq6bYoWeBb7JojIUg4TRIwGzCck0zdS8lrpcOEzSBUYQlHPOeIVtay6cQ8O0qrg)yzozJciiW1LZUK0IFLyfH8tQ9WUmbfzEP0UIgw0sCcrzXayvAl5I)rsiLjYSe00w2T4sVGBZ(wlZqHjHTIY7ob02n0rmHWwkZCwHrH8vJt84xpDROQhDrkQMJxwUi9Wdnq0A0iaCJxnkeVghQzbc6EI8V)aK11xnP)0VYgAfYtHUUfroSniZOVvLnFsw6R0ybuW(x8Orcpdvn16YyHZOsafgofW35omHYbFqOD2ntMQrwhsTvnZpjLx1spaNUMMw7FxFPLgIA5QN6DpmHtr2pB2KtJq)WP9ytB0eTDyQDxu1cBQhkgxNBxaydMUCNJGdWxrIneDAvGvhxAT6vT4mZstXLYjBxFnmr1Q2Qwusycronkg2g9mnDbAt6WquuRzIvQ60jzWsnKmepQyWuC8FFVdoiqK9Z4W2UMDPg5Tb22)PmSNYNB6avUCRGIocUXAuVZF9Krf1qZUqNx1jhOG03OZEpkGQMw3hU40V2)ucToVCRrvkTyRspgO1Aj8maTwRR9F721SEeqLRL1HGkxZ8tcQCT07dvUMO2OY9H4o6e48kRfB5F8K2tRltyFXIvXKhlwSY1E0yX1IQjs0P6bJBt7WaJvlvhhW4A59FvWytjbBdgByrF4ONdAHF4It)I)tbyS981akfONQB5Z6D2Z3GsfhUKzp)BF4FE7NV93FFUBU7DRW5UKOeAkV8M7ErrFIxK7MI)3zqgIFUlJgbKHY40iexmG3ku8smBC(x(tsmm1KjG0(xXSSeHKeuu4OG4mTtJxmw0Z4Zrvm8MoxKimT9CH7yF752ZLdjVkuzGd(RBL33kowCYAF7pAp3lLaGZeeqt)9wSNJk)DRr5q0A3ISBFp3rGDVZwnsYoj3TyHvzaBtPWmo3OzyQpKsInNsiRlmklzftU7n5UqEUW(6R)KKUjtv6PfoNqrxAur913sjqvhjH0EZULwRwyvb4D0itPUUZlu6B3vS66C3lTuYOOhOGZR21kMMZyuAXM67Put7HbT9oJAZuRWgzCkytHOMyT7aT2wA5UZYDlYBKOBLjsncW1OUs9yUADF1dSiC1KgrhfESurMRHRHEum3eCsYT5sVTA2kTKPwDewTDyUWtxhyPdAQlSmgCzJ8UAELAQBLh0AUruvxRvLOe9Y1UyOJn5ACXAXoOdImtK0vbYaoWfwsR1CLTcq6nxAoH1Cr6lBaXM7(WdLbuDTKZDF1WtDnxCF4AChjXMRWRu2OgyD63EqBA2Alc6BbbmBlmba3sE5)6A02ccT4dYlhVOlTtXJBkU776wQvCu)WanLxvdVkIkEOGouiRMA8WacRs1Zt)dj0reMBqjKJ6baKPdn6015jaA5Li6o6w1v0ZgSOl2gMU2sdH7YTjjxkRFjO(wm1Ste5d)MsskiO(HqB6EN0kJVQp8JCZs9VtSJUkfP89wn0Z(Xo6gt5tEAYGQMU3n2D0nkXRHAYIKZ1B11r3CKBxZG5uTvoZvK7)wOn3XP)3rvjXoNZGxaC8yodJmmPzdn)F3jAAEkeLu260fMZ2pKtxmGZQC8pDXaosZwpz4wkwZdhQ0ARjRZCRMTTW70C8QMuw)4IDiY8Us23nhB(uhh(wQo0ZFC4A8GpjYZ1M4k3dXJbO5NeOfPmFCxWXp1qq76comTh0oxzrRhzvUh9TE6v75t10oE77hPgvsR9U3x0HzSR99(h6hN54DFk7aDzsteBtxYAha8EGK2xeCZLDh7R3OBD3)BF9gMRRh21ByUe9W7t1Fg7tXfQSJCxZ11pxDgLxpHM(I0ez7lf)v)Z7j(RWmSmOy6)xpPjDULLmyicxB)FUNuGLNrV5W86VS)p]] )

hunter:RegisterPack( "Marksmanship (Himea Beta)", 20240509, [[Hekili:TR1ERXnoq8plHd2lHl1X7Mxxkzd0hhxB4APGl0)Z2k2A3veBlJL2DBGG)SFJKFjBlTpsDB6FekPelnV0Oz(nJKI7y3V66eI4y3ppXEYz2Np22A8P2xC6LUo8hsXUoPOG7rZHFjbfd))Nqz3ZIrjSfK0C)d)ajgJY9FlMJosq7druuOqMm6YSaG(fCEk71NCYA6A(DbwZNFsaIJojicXyVA(ssiMDsSImF1ILjCC2jUo3TKeX)yI7D6nWZDDql5lOzUosJaufjmexqpMf4681fewUV4hWclxg5(0zW3bCcnj3pIW4W0ZOz5(FaFpjIyblIm6msey6)bmO0yEDUFRL9TIze68pzfl9C)38L)l3)v5(VNWcOzHahleeyXqeovYWNOHKzeCiOUmACU)3OF7RV9D5(Vdj4)FLEcPiEQEScTGEi3x4OYVf(gg4lz4aA8DiE(TfRAMvA1q)10tqSuCa3JoZJVa7TaT((JjZMEWDlNnZQyoRLPJyyoNKmNzfJijC4hVI5gbMezEcoS8BR(IBxu7m63hqTcsBxuAWcmSZTyavCPe3fLlIghqnle3UO21KOWbuTcXPxTfHKmprCQqHHyPgvh2kKUorp3Xewib(wmJG7AZJMItWzE1Z7rtIEOks)94zOLrnX5GGcqrrEfF6jY1pwGHnLKqAr1sg2JWXXm1btPsicLrwaWHzW6x4nccWr4mK0afStNnZBEq40XQmKTmPVYruSyjjgFf2dwoXem7MjBLVGimALgwNUDwzGVlcx5M(Oy17)fugmLyZOzlq4xazScLrq3fHlyMdWyECQxibF8ku0s80dl3m5zqGciAVWLXXpicJo12(OhFKJYMJ5wkmwP63q)NgTbocqzmogf(GhBbLlwBhkLmjgWGxb(zLzLHlp(O55ZWIGx21JTo)Orq00kXgI1ylfA6QCJXzYyXyCsONkjDzxp25tmxsW(OdIPRaE7QOmukj0BgyhcfeqPrcNHLm6wjvuSfi9pn03jjRqCD5RLqv4fe3b1RMUmb5Wbz0Ewk4RjjygZKml3LU5c7UScHtPErOLjamAwl2XFpnIYeX8cAABwT4sVn1M9EXaaKbrxWrNiZbjWSxeeKJe2wfLE(Uuc9Mevtyzg2cmkIVWknGF9KEUZoMFzKvPD2RGPgnQTeDHuAQx0Jip2AK56jvabVtcM1OXcWTNp4GA9)KreQLWVaqHADT)vzRzDWGuQL4pfuLg79PaS0ewHZGoh4qacO1JdEaMWRijInD8XXOV71ESjkEZw8AAX)ZfSOXhlourgYu07A4WghZWbk7Nkmuj72B4Ai4g7rBC(RhpAgnyj7MPNPZzVlGA1eVh4AguqpMU5kTmLfGsW1CvSaUuNt(ha50akWWcE6u2oxLslAV75d8Sw)pzWZAj8la8Swx7p4znRdg4zTe)PaE2yVpfWZMWQwGNBcyC0bQXkQtV9O1bjyvNNvlKz90pRqMnX97aKznX7bKPbfSziZgM2gKPP9Y9bY0qU)Waz66ScYLb9uD5H2x56SgLjo2kZ15JXP0mU4k5UOZDcALFRRJqeUF(uxh5qYl1uASWV9z59MIteNto09TUobzea2GGCDom3FZXY5(p(4MOPmKj3)6CFrmT)r5(JY91dd76uy3GTPmihwVgnWTal3iXwJYfEITkYULSeg(2rPLKDqUFXUDJb0NsHzCMrZWeeEJevNsiRZnkRnHQlTxDi7nkQzcHAUy7QPfiFLdzlq9nQR78cLE5EP06OUBGSbBLfsvTdHi)7T5610SC5sXuLbLa4wddA7kJABqtWmMcn2wya1UyfyDvZsqyx0aOGIAeKMccnYvubsFGNg2KBp2sF6wOtS2K0jHTb(MM7FMT0AndnOw5rjnSU4HKDZWa9QRinJjkrt11UKsYCMSgjbl8RSnAuMtKRw)5(xQSvRuBtYV5m0ACjLWkDL0mhgzorSsWJus11xIRnn9kZPhXey2vycq2P8QX1v4QfcsXhYRoUOQNxXJ(jUz46IkvCuFT5DYgovLOIRrVdfY9DLRnxyvnq06VM9oIW8(TqonxpUCJFIcCw7liV1Qer3cyDxrpDNfDXbd1HkVlCx22HCRS(Ds20MPMcNY3enJKwqq9Ze2jsxj6UQm0pyT9n3lYGRsri)gZg2qxmdUXu(GGMmOQP3ypndUrjERqtwKCUnMDn4MJSBfdMtvNmMZi3)o(mdgV5xz01uBX8cGJxotWVNNjyq7JFhoUWW3h)(D4HDQp(D4Ob9E0TERfnp9wJ6AnPB1rhQMTTW7uA)kvkRFEUUTCBV5MyhQmnJ5s965Fp7I2CU4(2f9glO9d26Q58QFvTUw250lWR)EcVU)fG3bm0HaQE)qnhiO6DaxDFHQ7ELl1XETVeLwVFP88u9EvtxNjA256FJn1yWpNORVC1l6kA8YvVSN1VE(V6f5vNOP6fnvIH3WF1F2DIFlAjwwvZ0FPDst6uBBzHkHRP)FZDsbwE)bQdZR)N7))d]])

-- TODO: Currently there is a problem with this APL not recomending serpent sting or explosive shot at the correct time if the player doesn't press any other button for their duration
-- This is done to solve the problem of recommending serpent sting or explosive shot for a brief period while the shot is still traveling to the target
hunter:RegisterPack( "Survival (Himea Beta)", 20240509, [[Hekili:TRvAVTnoq0FlblG3eSPk2o9iTOUa9yX2gSTOaUa9BsIwI2MisIcuu21ag63(od19bLDCvc2c0p0MysoV3WJ5ndzS5eZVzo3LiPMFz64PpD8ZMm2yY1JF2tnNl3fsnNhsCUJSc(LaIp8)ZJfByBiEj2N)rMpLKy)oQKCboUDECIlcxepw4aJDTugg9QRUAlFRCHJXQvx5qKKRC8irrpzvmZLgDvugEpzDCGKkUYC(IyMN8tbMl60VU(ga)qQJ5xUgiG56sthjnYXC(3wZIsSdfmUGj3LyJFAbjI6MyZdsSLRPj2fotI93fe56eBLNyyo3JfjJu(plyLhf(TVOwDObKfEuxZ3zo3bWLkyeymuPegwKHG6W99PbUw(Sixg8rjJhyoNK9ZATkHzZHH0NWcKW)Si4mvMypkXgwYyRcOUzTzK(dl(slywzTMS9o1WolX2NVbqP0bAps0nUwRB4W5EU8TbgoepVCZ2Y8CnIdlrvqczUwlHzgI2tpmALga4K7Rft5MCz5tCe8s6A2ps6Z0sQlDr8YLgrurinqAfHCyGEroVHc6gRvoUgtQpOscR3mW2ZpeB0Fe6XJyBOwrR5Ys6ohodI97XDUZIaNtWWe1AW(9nDM6yKyFrPdvVl0JEHwpsseROsJ1uINCTriEe61j2thxI2Dmy9mhOBo0uln2mc2ue3PMyLavTleRxEiSw4rW1bHGVTbuv6brAYyTqTK7edH2VjX(MkZjIWHeuU8mrFW75vcus3guUw9iLL8FO2LUqTl6r3q9ArPdFHGuYO(y7tNryJ7MjvoxkPe3DLuQpooNSrvcZAXNv0wsy9X0q9rNqcySj6cW(6ssSNSl5YArVPFWcvzt1ATsZOWcyYcHXClIJOwWeXpQkE5Yw5dkKNfAuDekPi0C(YLyuf6vLNwHuAcyAG6OooupkKbOne6fwqCGiqAa1NrtpboTIMyCG2zjHt7xfPj0ZoAOD8OKn0UueogRZs2P2kdvjZwq6DZSJ8jQ0Vcwy6a(mzhk2m9PvNENv7eFEkGFYuE9NpDWPepY3B0qpzvhCNXznfk8ATohkV7Etop4ofwSOops1xVrxdU7OQuqJ7KxfXbZRFps(PpJCXKGdvvqfL1kAXd82zQRArzQWXVRe9x1krliTS8njWFxeJTB5rIdGqxrtwR1zXX28ERdEJSzVO6i9Hm1mvXd1huZsaBJCQro7GSnwP1xgHhHM7t(Hv9wNpT6kGMAFHjV(6M7VqY7z1T9uh5Pxvw)1b(qu55bQduFW8JvDGzLH8BTQFT0Qkoqv)EWnc0NC4aDTx6URSShP(YXtRgvKhH7i)GjX)YJwIFWVQCh6ANWwZPl2L6U9RRD6O))(RuRUsChcP8qLExP9BiGFb9I)MxmvTOKfqahtaycwz5g77Vl)041JhRwmWLRSiajZh2a5wUmfmIS7fwTzzQBTbQ1fPn7fzh)sZ5BjcKeyN)t(HCHeFQ1Nd6Uk)dwWXNu1i5wWJJLR5cZ5QhngVPjFjd97)iX(JQQOFvIDXBlFl2koW)mk99LtSF7x)3e7NKy)bwKdx4cJEnoaJictYvg8zUlBjdDGLcUFI935F)BV79j2VNG2)pQNBwbXP8S0PmKFX2KBHpdn8187lNCB6moYO4k0)1SRANd5s2YzNv)ooJ0Dkz0rK86iOfounGScODmKMD7ZbK4mepgYXlAoGmJWDm0IjyhqAr46M2Q36eju39u726QvwHw3)ntZpP)H0h5RasaOMpQ3LOUXmu6Q6OkEiVQnM(WDvBrZdZDzLhYB2KQg04jTsjhURmoLW2lFkT3m9G2Lw6ABtNDyttF(S8LPpHZE7Vseqx4Mr5waUUayKlyNACfn2lvc4ZoxN69iq5(I97BRzNt9B5)DjBWcrFB1Dx9DtZ7w(6epoJMp6SSeOniQSixKG(QKUPLnhsn7Rv78OZoqvZnHUw5y1WTvDEvWUJk8AcCDZBTNLFbD9MH9EzT6UMn9Yw1IbTboDN3(Eup)fRAWArnWiyTkz(1th3AhPOIr0IZZ2X3VxBTzxmsvv2BUPfuvQl7(H1RVzs)NLZYjMI3OdukNwb88iV3Rupkzmvn5Nj(RaHhHqWcUoLOWcJFqcelqV2DkBC0FIUJ(6)Ja3MGEdUoed9ggvqX9isQWMhanOoMY1LHkp7vEhrKA1fjRfLwU5xgZFKRChFSC3momsdAcZgw1H5zfiKtAAbd)mQdfi8iOouW1POouy8dI6qb61vh6lYF0z6(IF0bSn0e6nEF05DMOD)(Z0(L74IoO8EOruyZ9)2afMw5lCrflB(f0ORdEhsAOCNFikhOCNEqc71e)mmH9QxkX8)c]] )


hunter:RegisterPackSelector( "beast_mastery", "Beast Mastery (Himea Beta))", "|T132164:0|t Beast Mastery",
    "If you have spent more points in |T132164:0|t Beast Mastery than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )

hunter:RegisterPackSelector( "marksmanship", "Marksmanship (Himea Beta)", "|T132222:0|t Marksmanship",
    "If you have spent more points in |T132222:0|t Marksmanship than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

hunter:RegisterPackSelector( "survival", "Survival (Himea Beta)", "|T132215:0|t Survival",
    "If you have spent more points in |T132215:0|t Survival than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )
