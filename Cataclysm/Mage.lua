if UnitClassBase( 'player' ) ~= 'MAGE' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 8 )

function round_half_to_even(val)
    -- if decimal value is exactly halfway
    if val%1 == 0.5 then
        local val_floored = floor(val)

        -- if floored value is even then return even value
        if val_floored%2 == 0 then return val_floored end

        -- otherwise return the ceiling (which has to be the even value)
        return val_floored + 1
    end

    -- round "normally"
    return floor(val+0.5)
end

function compute_dot_duration(base_dur, base_tick_dur)
    local tick_dur = floor(base_tick_dur/(1+UnitSpellHaste("player")/100) * 1000 + 0.5)/1000
    local tick_cnt = round_half_to_even(base_dur/tick_dur)
    return tick_dur * tick_cnt
end

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    arcane_barrage = {1847, 1, 44425},
    arcane_empowerment = {1727, 3, 31579, 31582, 31583},
    arcane_flows = {1843, 2, 44378, 44379},
    arcane_focus = {76, 3, 11222, 12839, 12840},
    arcane_fortitude = {85, 3, 28574, 54658, 54659},
    arcane_instability = {421, 3, 15058, 15059, 15060},
    arcane_meditation = {1142, 3, 18462, 18463, 18464},
    arcane_mind = {77, 5, 11232, 12500, 12501, 12502, 12503},
    arcane_potency = {1725, 2, 31571, 31572},
    arcane_power = {87, 1, 12042},
    arcane_repulsion = {1845, 3, 44397, 44398, 44399},
    arcane_shielding = {83, 2, 11252, 12605},
    arcane_stability = {80, 2, 11237, 12463},
    arctic_reach = {741, 2, 16757, 16758},
    arctic_winds = {1738, 3, 31674, 31675, 31676},
    blast_wave = {32, 1, 11113},
    blazing_speed = {1731, 2, 31641, 31642},
    brain_freeze = {1854, 3, 44546, 44548, 44549},
    burnout = {1851, 5, 44449, 44469, 44470, 44471, 44472},
    chilled_to_the_bone = {1856, 5, 44566, 44567, 44568, 44570, 44571},
    cold_as_ice = {1737, 2, 55091, 55092},
    cold_snap = {72, 1, 11958},
    combustion = {36, 1, 11129},
    critical_mass = {25, 3, 11095, 12872, 12873},
    deep_freeze = {1857, 1, 44572},
    dragons_breath = {1735, 1, 31661},
    empowered_fire = {1734, 3, 31656, 31657, 31658},
    fiery_payback = {1848, 2, 64353, 64357},
    fire_power = {1141, 3, 18459, 18460, 54734},
    focus_magic = {2211, 1, 54646},
    frost_channeling = {66, 3, 11160, 12518, 12519},
    frost_warding = {70, 2, 11189, 28332},
    frozen_core = {1736, 3, 31667, 31668, 31669},
    ice_barrier = {71, 1, 11426},
    icy_veins = {69, 1, 12472},
    impact = {30, 3, 11103, 12357, 12358},
    improved_blink = {1724, 2, 31569, 31570},
    improved_cone_of_cold = {64, 2, 11190, 12489},
    improved_counterspell = {88, 2, 11255, 12598},
    improved_fire_blast = {27, 2, 11078, 11080},
    improved_fireball = {26, 5, 11069, 12338, 12339, 12340, 12341},
    improved_frostbolt = {37, 5, 11070, 12473, 16763, 16765, 16766},
    improved_mana_gem = {1728, 3, 31584, 31585, 31586},
    improved_polymorph = {74, 2, 11210, 12592},
    living_bomb = {1852, 1, 44457},
    magic_absorption = {1650, 2, 29441, 29444},
    magic_attunement = {82, 2, 11247, 12606},
    master_of_elements = {1639, 3, 29074, 29075, 29076},
    netherwind_presence = {1846, 3, 44400, 44402, 44403},
    permafrost = {65, 3, 11175, 12569, 12571},
    piercing_ice = {61, 3, 11151, 12952, 12953},
    playing_with_fire = {1730, 3, 31638, 31639, 31640},
    precision = {1649, 3, 29438, 29439, 29440},
    presence_of_mind = {86, 1, 12043},
    prismatic_cloak = {1726, 3, 31574, 31575, 54354},
    pyroblast = {29, 1, 11366},
    pyromaniac = {1733, 3, 34293, 34295, 34296},
    shatter = {67, 3, 11170, 12982, 12983},
    shattered_barrier = {2214, 2, 44745, 54787},
    slow = {1729, 1, 31589},
    spell_impact = {81, 3, 11242, 12467, 12469},
    spell_power = {1826, 2, 35578, 35581},
    summon_water_elemental = {1741, 1, 31687},
    torment_the_weak = {2222, 3, 29447, 55339, 55340},
    winters_chill = {68, 3, 11180, 28592, 28593},
    world_in_flames = {31, 3, 11108, 12349, 12350},
    } )

spec:RegisterStateExpr( "lb_duration", function() 
    local description = GetSpellDescription(44457)
    -- Pattern to match the duration value (number with optional decimal followed by " sec")
    local duration = string.match(description, "(%d+%.%d+) sec")
    if not duration then
        duration = string.match(description, "(%d+) sec")
    end
    if duration then
        return tonumber(duration)
    else
        return nil -- Return nil if the duration is not found
    end
 end )

spec:RegisterAuras( {
    active_flamestrike = {
        duration = function() return 8 end,
        max_stack = 20,
        generate = function ( t )
            local applied = action.flamestrike.lastCast

            if applied and now - applied < 8 then
                t.count = t.count + 1
                t.expires = applied + 8
                t.applied = applied
                t.caster = "player"
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    -- Arcane spell damage increased by $s1% and mana cost of Arcane Blast increased by $s2%.
    arcane_blast = {
        id = 36032,
        duration = 6,
        max_stack = 4,
        copy = { 36032 },

    },
    -- Increases Intellect by $s1.
    arcane_brilliance = {
        id = 79058,
        duration = 3600,
        max_stack = 1,
        shared = "player",
        dot = "buff",
        copy = { 23028, 27127, 43002, 61316 },
 },
    -- Increases Intellect by $s1.
    arcane_intellect = {
        id = 1459,
        duration = 1800,
        max_stack = 1,
        shared = "player",
        dot = "buff",
        copy = { 1459, 1460, 1461, 10156, 10157, 27126, 42995 },
 },
    -- Increased damage and mana cost for your spells.
    arcane_power = {
        id = 12042,
        duration = function() return talent.arcane_power.enabled and 18 or 15 end,
        max_stack = 1,
},
    -- Dazed.
    blast_wave = {
        id = 11113,
        duration = 6,
        max_stack = 1,
        copy = { 11113, 13018, 13019, 13020, 13021, 27133, 33933, 42944, 42945 },
    },
    -- Movement speed increased by $s1%.
    blazing_speed = {
        id = 31643,
        duration = 8,
        max_stack = 1,
 },
    -- Blinking.
    blink = {
        id = 1953,
        duration = 1,
        max_stack = 1,
 },
    -- $42938s1 Frost damage every $42938t1 $lsecond:seconds;.
    blizzard = {
        id = 42208,
        duration = 8,
        max_stack = 1,
        copy = { 42208, 42209, 42210, 42211, 42212, 42213, 42198, 42939, 42940 },
},
 -- $42938s1 Frost damage every $42938t1 $lsecond:seconds;.
    brain_freeze = {
        id = 57761,
        duration = 8,
        max_stack = 1,
        copy = { 42208, 42209, 42210, 42211, 42212, 42213, 42198, 42939, 42940 },
},
    -- Immune to Interrupt and Silence mechanics.
    burning_determination = {
        id = 54748,
        duration = 20,
        max_stack = 1,
    },
    -- Movement slowed by $s1% and time between attacks increased by $s2%.
    chilled = {
        id = 6136,
        duration = function() return 5 + talent.permafrost.rank end,
        max_stack = 1,
        copy = { 6136, 7321, 12484, 12485, 12486, 15850, 18101, 31257 },
        shared = "target",
},
    cho_gall = {
        id = 82170,
        duration = 3600,
        max_stack = 1,
},
    -- Your next damage spell has its mana cost reduced by $/10;s1%.
    clearcasting = {
        id = 12536,
        duration = 15,
        max_stack = 1,
},
    -- Increases critical strike chance from Fire damage spells by $28682s1%.
    combustion = {
        id = 28682,
        duration = 3600,
        max_stack = 10,
},
    -- Movement slowed by $s1%.
    cone_of_cold = {
        id = 120,
        duration = function() return 8 + talent.permafrost.rank end,
        max_stack = 1,
        copy = { 120, 8492, 10159, 10160, 10161, 27087, 42930, 42931 },
},
    -- Immune to all Curse effects.
    curse_immunity = {
        id = 60803,
        duration = 4,
        max_stack = 1,
        shared = "player",
        dot = "buff",
},
    -- Increases Intellect by $s1.
    dalaran_brilliance = {
        id = 61316,
        duration = 3600,
        max_stack = 1,
        shared = "player",
        dot = "buff",
},
    -- Increases Intellect by $s1.
    dalaran_intellect = {
        id = 61024,
        duration = 1800,
        max_stack = 1,
        shared = "player",
        dot = "buff",
},
    -- Reduces magic damage taken by up to $s1 and healing by up to $s2.
    dampen_magic = {
        id = 604,
        duration = 600,
        max_stack = 1,
        copy = { 604, 8450, 8451, 10173, 10174, 33944, 43015 },
},
    -- Stunned and Frozen.
    deep_freeze = {
        id = 44572,
        duration = 5,
        max_stack = 1,
},
    -- Increased spell power by $w1.
    demonic_pact = {
        id = 48090,
        duration = 45,
        max_stack = 1,
        shared = "player",
        dot = "buff",
    },
    -- Disoriented.
    dragons_breath = {
        id = 31661,
        duration = 5,
        max_stack = 1,
        copy = { 31661, 33041, 33042, 33043, 42949, 42950 },
},
    -- Gain $s1% of total mana every $t1 sec.
    evocation = {
        id = 12051,
        duration = 8,
        max_stack = 1,
 },
    -- Disarmed!
    fiery_payback = {
        id = 64346,
        duration = 6,
        max_stack = 1,
 },
    -- Your next $s1 spells treat the target as if it were Frozen.
    fingers_of_frost = {
        id = 44544,
        duration = 15,
        max_stack = 2,
},
    -- Absorbs Fire damage.
    fire_ward = {
        id = 543,
        duration = 30,
        max_stack = 1,
        copy = { 543, 8457, 8458, 10223, 10225, 27128, 43010 },
},
    -- $s2 Fire damage every $t2 seconds.
    fireball = {
        id = 133,
        duration = 8,
        tick_time = 2,
        max_stack = 1,
        copy = { 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306, 27070, 38692, 42832, 42833 },
},
    -- Your next Fireball or Frostfire Bolt spell is instant and costs no mana.
    fireball_proc = {
        id = 57761,
        duration = 15,
        max_stack = 1,
        copy = "brain_freeze",
},
    -- Your next Flamestrike spell is instant cast and costs no mana.
    firestarter = {
        id = 54741,
        duration = 10,
        max_stack = 1,
    },
    -- $s2 Fire damage every $t2.
    flamestrike = {
        id = 2120,
        duration = 8,
        tick_time = 2,
        max_stack = 1,
        copy = { 2120, 88148 },
},
    -- Increases chance to critically hit with spells by $s1%.
    focus_magic = {
        id = 54646,
        duration = 1800,
        max_stack = 1,
    },
    focus_magic_proc = {
        id = 54648,
        duration = 10,
        max_stack = 1,
 },
    -- Increases Armor by $s1 and may slow attackers.
    frost_armor = {
        id = 168,
        duration = function() return glyph.frost_armor.enabled and 3600 or 1800 end,
        max_stack = 1,
        copy = { 168, 7300, 7301 },
},
    -- Frozen in place.
    frost_nova = {
        id = 122,
        duration = 8,
        max_stack = 1,
        copy = { 122, 865, 6131, 10230, 27088, 42917 },
},
    -- Absorbs Frost damage.
    frost_ward = {
        id = 6143,
        duration = 30,
        max_stack = 1,
        copy = { 6143, 8461, 8462, 10177, 28609, 32796, 43012 },
},
    -- Frozen.
    frostbite = {
        id = 12494,
        duration = 5,
        max_stack = 1,
},
    -- Movement slowed by $s1%.
    frostbolt = {
        id = 116,
        duration = function() return 9 + talent.permafrost.rank end,
        max_stack = 1,
        copy = { 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304, 27071, 27072, 38697, 42841, 42842 },
},
    -- Movement slowed by $s1%.  $s3 Fire damage every $t3 sec.
    frostfire_bolt = {
        id = 44614,
        duration = function() return 9 + talent.permafrost.rank end,
        tick_time = 3,
        max_stack = 1,
        copy = { 44614, 47610 },
},
    heating_up = {
        duration = 3600, -- Heating up is a pseudo buff that has no duration
        max_stack = 1,
    },
    -- Your next Pyroblast spell is instant cast.
    hot_streak = {
        id = 48108,
        duration = 10,
        max_stack = 1,
    },
    -- Cannot be made invulnerable by Ice Block.
    hypothermia = {
        id = 41425,
        duration = 30,
        max_stack = 1,
    },
    -- Increases armor by $s1, Frost resistance by $s3 and may slow attackers.
    ice_armor = {
        id = 7302,
        duration = function() return glyph.frost_armor.enabled and 3600 or 1800 end,
        tick_time = 6,
        max_stack = 1,
        copy = { 7302, 7320, 10219, 10220, 27124, 43008 },
},
    -- Absorbs damage.
    ice_barrier = {
        id = 11426,
        duration = 60,
        max_stack = 1,
        copy = { 11426, 13031, 13032, 13033, 27134, 33405, 43038, 43039 },
},
    -- Immune to all attacks and spells.  Cannot attack, move or use spells.
    ice_block = {
        id = 45438,
        duration = 10,
        max_stack = 1,
},
    -- Casting speed of all spells increased by $s1% and reduces pushback suffered by damaging attacks while casting by $s2%.
    icy_veins = {
        id = 12472,
        duration = 20,
        max_stack = 1,
},
    -- Deals Fire damage every $t1 sec.
    ignite = {
        id = 413841,
        duration = 4,
        tick_time = 2,
        max_stack = 1,
        copy = { 413843, 413841 },
    },

    -- Next Fire Blast stuns the target for $12355d.
    impact_stun = {
        id = 64343,
        duration = 10,
        max_stack = 1,
        copy = { 12355, 64343 },
},
    -- Chance to be hit by all attacks and spells reduced by $s1%.
    improved_blink = {
        id = 46989,
        duration = 4,
        max_stack = 1,
},
-- Chance to be hit by all attacks and spells reduced by $s1%.
    improved_cone_of_cold = {
        id = 83302,
        duration = 4,
        max_stack = 1,
},
    -- Spells have a $s1% additional chance to critically hit.
    critical_mass = {
        id = 22959,
        duration = 30,
        max_stack = 1,
},
    -- Spell power increased.
    incanters_absorption = {
        id = 44413,
        duration = 10,
        max_stack = 1,
},
    -- Invisible.
    invisibility = {
        id = 32612,
        duration = 20,
        max_stack = 1,
},
    -- Fading.
    invisibility_fading = {
        id = 66,
        duration = function() return 3 - talent.prismatic_cloak.rank end,
        tick_time = 1,
        max_stack = 1,
    },
    -- Causes $s1 Fire damage every $t1 sec.  After $d or when the spell is dispelled, the target explodes causing $55362s1 Fire damage to all enemies within $55362a1 yards.
    living_bomb = {
        id = 44457,
        --usable = function() return debuff.living_bomb.down end,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
 },
    -- Resistance to all magic schools increased by $s1 and allows $s2% of your mana regeneration to continue while casting.  Duration of all harmful Magic effects reduced by $s3%.
    mage_armor = {
        id = 6117,
        duration = 1800,
        tick_time = 6,
        max_stack = 1,
        copy = { 6117, 22782, 22783, 27125, 43023, 43024 },
},
    -- Absorbs damage, draining mana instead.
    mana_shield = {
        id = 1463,
        duration = 60,
        max_stack = 1,
        copy = { 1463, 8494, 8495, 10191, 10192, 10193, 27131, 43019, 43020 },
},
    -- Copies of the caster that attack on their own.
    mirror_image = {
        id = 55342,
        duration = 30,
        tick_time = 1,
        max_stack = 1,
},
    -- Reduces the channeled duration of your next Arcane Missiles spell by $/1000;S1 secs, reduces the mana cost by $s3%, and the missiles fire every .5 secs.
    arcane_missiles = {
        id = 79683,
        duration = 20,
        max_stack = 1,
},
    -- Causes $43044s1 Fire damage to attackers.  Chance to receive a critical hit reduced by $s2%.  Critical strike rating increased by $s3% of Spirit.
    molten_armor = {
        id = 30482,
        duration = 1800,
        tick_time = 6,
        max_stack = 1,
        copy = { 34913, 43045, 43046 },
},
    -- Cannot attack or cast spells.  Increased regeneration.
    polymorph = {
        id = 118,
        duration = 50,
        max_stack = 1,
        copy = { 118, 12824, 12825, 12826, 28271, 28272, 61025, 61305, 61721, 61780 },
},
    -- Your next Mage spell with a casting time less than 10 sec will be an instant cast spell.
    presence_of_mind = {
        id = 12043,
        duration = 3600,
        max_stack = 1,
},
    -- $s2 Fire damage every $t2 seconds.
    pyroblast = {
        id = 92315,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
        copy = { 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809, 27132, 33938, 42890, 42891 },
},
    -- Replenishes $s1% of maximum mana per 5 sec.
    replenishment = {
        id = 57669,
        duration = 15,
        max_stack = 1,
        shared = "player",
        dot = "buff",
    },
    -- Frozen in place.
    shattered_barrier = {
        id = 55080,
        duration = 8,
        max_stack = 1,
},
    -- Silenced.
    silenced_improved_counterspell = {
        id = 18469,
        duration = function() return 2 * talent.improved_counterspell.rank end,
        max_stack = 1,
        copy = { 18469, 55021 },
},
    -- Movement speed reduced by $s1%.  Time between ranged attacks increased by $s2%.  Casting time increased by $s3%.
    slow = {
        id = 31589,
        duration = 15,
        max_stack = 1,
},
    -- Slows falling speed.
    slow_fall = {
        id = 130,
        duration = 30,
        max_stack = 1,
},
    -- Mage lust
    time_warp = {
        id = 80353,
        duration = 40,
        max_stack = 1,
},
    water_elemental = {
        duration = function()
            if glyph.eternal_water.enabled then return 3600 end
            return 45 + ( 5 * talent.enduring_winter.rank )
        end,
        max_stack = 1,
    },
    -- Spells have a $s1% additional chance to critically hit.
    winters_chill = {
        id = 12579,
        duration = 15,
        max_stack = 5,
},

    -- Aliases
    unique_armor = {
        alias = { "frost_armor", "molten_armor", "mage_armor", "ice_armor" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },
    frozen = {
        alias = { "deep_freeze", "frost_nova", "frostbite", "shattered_barrier", "improved_cone_of_cold" },
        aliasMode = "first",
        aliasType = "debuff",
    }
} )


-- Glyphs
spec:RegisterGlyphs( {
    [63092] = "arcane_barrage",
    [62210] = "arcane_blast",
    [57924] = "arcane_brilliance",
    [56363] = "arcane_missiles",
    [56381] = "arcane_power",
    [89749] = "armors",
    [62126] = "blast_wave",
    [56365] = "blink",
    [56364] = "cone_of_cold",
    [57928] = "conjuring",
    [63090] = "deep_freeze",
    [56373] = "dragons_breath",
    [56380] = "evocation",
    [56368] = "fireball",
    [98397] = "frost_armor",
    [56376] = "frost_nova",
    [56370] = "frostbolt",
    [61205] = "frostfire",
    [63095] = "ice_barrier",
    [56372] = "ice_block",
    [56377] = "ice_lance",
    [56374] = "icy_veins",
    [56366] = "invisibility",
    [89926] = "living_bomb",
    [56383] = "mage_armor",
    [70937] = "mana_shield",
    [63093] = "mirror_image",
    [56382] = "molten_armor",
    [56375] = "polymorph",
    [56384] = "pyroblast",
    [63091] = "slow",
    [57925] = "slow_fall",
    [57927] = "the_monkey",
} )


-- Events that will provoke a 
local AURA_EVENTS = {
    SPELL_AURA_APPLIED      = 1,
    SPELL_AURA_APPLIED_DOSE = 1,
    SPELL_AURA_REFRESH      = 1,
    SPELL_AURA_REMOVED      = 1,
    SPELL_AURA_REMOVED_DOSE = 1,
}

local AURA_REMOVED = {
    SPELL_AURA_REFRESH      = 1,
    SPELL_AURA_REMOVED      = 1,
    SPELL_AURA_REMOVED_DOSE = 1,
}

local FORCED_RESETS = {}

for _, aura in pairs( { "arcane_power", "clearcasting", "fingers_of_frost", "fireball_proc", "firestarter", "hot_streak", "arcane_missiles", "presence_of_mind", "deep_freeze", "frost_nova", "frostbite", "shattered_barrier" } ) do
    FORCED_RESETS[ spec.auras[ aura ].id ] = 1
end

local lastFingersConsumed = 0
local lastFrostboltCast = 0

local heating_spells = {
    [42833] = 1,
    [42873] = 1,
    [42859] = 1,
    [55362] = 1,
    [47610] = 1
}
local heatingUp = false
local igniteDamage = 0
local lastTickTime = 0
local fs_down = false

-- Function to reset igniteDamage after a delay
local function ResetIgniteDamage()
    -- Check if the last tick was recent, assuming the tick time is 2 seconds
    if (GetTime() - lastTickTime) > 2 then
        igniteDamage = 0
        --print("Ignite damage reset to 0 after removal")
    else
        -- Re-schedule the reset if the last tick was very recent
        C_Timer.After(0.1, ResetIgniteDamage)
    end
end
-- Initialize ignite and combustion tables
local ignite = {}
local combustion = {}

-- Allowed Spell IDs
local allowedSpellIds = {
    [133] = true,    -- Fireball
    [44614] = true,  -- Frostfire Bolt
    [2948] = true,   -- Scorch
    [2136] = true,   -- Fireblast
    [11366] = true,  -- Pyroblast
    [92315] = true,  -- Instant Pyroblast
    [31661] = true,  -- Dragon's Breath
    [2120] = true,   -- Flamestrike
    [11113] = true,  -- Blast Wave
    [88148] = true,  -- Flamestrike from BW
    [44461] = false, -- Living Bomb Explosion
    [11129] = true   -- Combustion Initial
}

local function CombustionCooldown()
    local startTime, cooldown = GetSpellCooldown(11129)
    local currentTime = GetTime()
    local remainingCooldown = math.max(0, cooldown - (currentTime - startTime))
    --print("Debug: Combustion Cooldown:", remainingCooldown)
    return remainingCooldown
end

local function CalculateBerserkingHaste(haste)
    local _, cooldown = GetSpellCooldown(26297)
    local _, raceEn = UnitRace("player")
    if raceEn == "Troll" and cooldown == 0 then
        haste = (((((haste / 100) + 1) * 1.2) - 1) * 100)
    end
    --print("Debug: Calculated Berserking Haste:", haste)
    return haste
end

local function CalculateTicks()
    local haste = UnitSpellHaste("player")
    local ticks = 0
    local berserkEnabled = true -- Set this based on your custom addon configuration
    if berserkEnabled then
            haste = CalculateBerserkingHaste(haste)
    end

    for i = 10, 40 do
        local tickspeed =  1000 / (1000 / (10000 / (i - 0.5)))
        local adjusted_tickspeed = (i % 2 == 0) and (math.floor(tickspeed) + 0.4999) or (math.floor(tickspeed) - 0.5001)

        local breakpoint = 1000 / adjusted_tickspeed
        local adjusted_haste = (haste / 100) + 1
        if adjusted_haste > breakpoint then
            ticks = i
        else
            break
        end
    end
        --print("Debug: Calculated Ticks:", ticks)
    return ticks
end

local function CalculateLivingBombContrib(spellpower, floorMastery)
    return math.ceil((math.floor(0.25 * 937.3) + 0.258 * spellpower) * 1.25 * 1.03 * floorMastery * 1.15 / 3)
end

local function CalculatePyroblastContrib(spellpower, floorMastery)
    return math.ceil((math.floor(0.175 * 973.3) + 0.180 * spellpower) * 1.25 * 1.03 * floorMastery / 3)
end
-- Create a table to store the variable data
local ignite_contrib_tracker = {
    lowest = nil,
    highest = nil,
    total = 0,
    count = 0,
    average = nil,
    highest_ticks = 10,
    lowest_ticks = 10,
    average_ticks = 10,
    total_ticks = 0,
    highest_spellpower = 0,
    lowest_spellpower = 0,
    average_spellpower = 0,
    total_spellpower = 0,
    highest_mastery = 0,
    lowest_mastery = 0,
    average_mastery= 0,
    total_mastery = 0,
    highest_combust = 0,
    lowest_combust = 0,
    average_combust = 0,
    total_combust = 0,
}

-- Function to update the tracker with a new number
local function updateIgniteContribTracker(value, ticks, spellpower, mastery, combust)
    -- Ignore nil or zero values
    if value == nil or value == 0 then
        return
    end

    -- Update the lowest value
    if ignite_contrib_tracker.lowest == nil or value < ignite_contrib_tracker.lowest then
        ignite_contrib_tracker.lowest = value
    end
    -- Update the lowest value
    if ignite_contrib_tracker.lowest_combust == nil or combust < ignite_contrib_tracker.lowest_combust then
        ignite_contrib_tracker.lowest_combust = combust
    end
    -- Update the lowest value
    if ignite_contrib_tracker.lowest_ticks == nil or ticks < ignite_contrib_tracker.lowest_ticks then
        ignite_contrib_tracker.lowest_ticks = ticks
    end
    -- Update the lowest value
    if ignite_contrib_tracker.lowest_spellpower == nil or spellpower < ignite_contrib_tracker.lowest_spellpower then
        ignite_contrib_tracker.lowest_spellpower = spellpower
    end
    -- Update the lowest value
    if ignite_contrib_tracker.lowest_mastery == nil or mastery < ignite_contrib_tracker.lowest_mastery then
        ignite_contrib_tracker.lowest_mastery = mastery
    end

    -- Update the highest value
    if ignite_contrib_tracker.highest == nil or value > ignite_contrib_tracker.highest then
        ignite_contrib_tracker.highest = value
    end
    -- Update the lowest value
    if ignite_contrib_tracker.highest_combust == nil or combust > ignite_contrib_tracker.highest_combust then
        ignite_contrib_tracker.highest_combust = combust
    end
    -- Update the highest value
    if ignite_contrib_tracker.highest_ticks == nil or ticks > ignite_contrib_tracker.highest_ticks then
        ignite_contrib_tracker.highest_ticks = ticks
    end
    -- Update the highest value
    if ignite_contrib_tracker.highest_spellpower == nil or spellpower > ignite_contrib_tracker.highest_spellpower then
        ignite_contrib_tracker.highest_spellpower = spellpower
    end
    -- Update the highest value
    if ignite_contrib_tracker.highest_mastery == nil or mastery > ignite_contrib_tracker.highest_mastery then
        ignite_contrib_tracker.highest_mastery = mastery
    end

    -- Update the total and count for calculating the average
    ignite_contrib_tracker.total = ignite_contrib_tracker.total + value
    ignite_contrib_tracker.count = ignite_contrib_tracker.count + 1
    ignite_contrib_tracker.average = ignite_contrib_tracker.total / ignite_contrib_tracker.count
    -- Update the total and count for calculating the average
    ignite_contrib_tracker.total_ticks = ignite_contrib_tracker.total_ticks + ticks
    ignite_contrib_tracker.average_ticks = ignite_contrib_tracker.total_ticks / ignite_contrib_tracker.count
    -- Update the total and count for calculating the average
    ignite_contrib_tracker.total_spellpower = ignite_contrib_tracker.total_spellpower + spellpower
    ignite_contrib_tracker.average_spellpower = ignite_contrib_tracker.total_spellpower / ignite_contrib_tracker.count
    -- Update the total and count for calculating the average
    ignite_contrib_tracker.total_mastery = ignite_contrib_tracker.total_mastery + mastery
    ignite_contrib_tracker.average_mastery = ignite_contrib_tracker.total_mastery / ignite_contrib_tracker.count
    -- Update the total and count for calculating the average
    ignite_contrib_tracker.total_combust = ignite_contrib_tracker.total_combust + combust
    ignite_contrib_tracker.average_combust = ignite_contrib_tracker.total_combust / ignite_contrib_tracker.count
end

-- Function to get the tracker data
local function getTrackerData()
    return {
        lowest = ignite_contrib_tracker.lowest,
        highest = ignite_contrib_tracker.highest,
        average = ignite_contrib_tracker.average,
        lowest_ticks = ignite_contrib_tracker.lowest_ticks,
        highest_ticks = ignite_contrib_tracker.highest_ticks,
        average_ticks = ignite_contrib_tracker.average_ticks,
        total_ticks = ignite_contrib_tracker.total_ticks,
        count = ignite_contrib_tracker.count,
        lowest_spellpower = ignite_contrib_tracker.lowest_spellpower,
        highest_spellpower = ignite_contrib_tracker.highest_spellpower,
        average_spellpower= ignite_contrib_tracker.average_spellpower,
        lowest_mastery = ignite_contrib_tracker.lowest_mastery,
        highest_mastery = ignite_contrib_tracker.highest_mastery,
        average_mastery = ignite_contrib_tracker.average_mastery,
        lowest_combust = ignite_contrib_tracker.lowest_combust,
        highest_combust = ignite_contrib_tracker.highest_combust,
        average_combust = ignite_contrib_tracker.average_combust,
    }
end
-- Create a table to store the variable data
local combust_tracker = {
    lowest = nil,
    highest = nil,
    total = 0,
    count = 0,
    average = nil,
}


-- Function to get the tracker data
local function getCombustTrackerData()
    return {
        lowest = combust_tracker.lowest,
        highest = combust_tracker.highest,
        average = combust_tracker.average,
        count = combust_tracker.count,
    }
end
-- Register state expression for predicted combustion
spec:RegisterStateExpr("ignite_contrib_tracker", function()
    local data = getTrackerData()
    return data
end)
spec:RegisterStateExpr("has_cho_gall_debuff", function()
    local DEBUFF_ID = 82170
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitDebuff("player", i)
        if not name then
            break
        end

        if spellId == DEBUFF_ID then
            return true
        end
    end

    return false
end)


spec:RegisterStateExpr("combustion_settings_helper", function()
    local tracker_data = getCombustTrackerData()
    local settings_helper = {
        lowest_combust = 0,
        highest_combust = 0,
        average_combust = 0,
    }

    local spellpower = GetSpellBonusDamage(3)
    local floorMastery = math.floor(GetMastery() * 2.8) / 100 + 1


    if tracker_data.lowest and tracker_data.highest and tracker_data.average > 0 then
        settings_helper.lowest_combust = combust_tracker.lowest
        settings_helper.highest_combust = combust_tracker.highest
        settings_helper.average_combust = combust_tracker.average
    end
    return settings_helper
end)


local function IgniteContrib(floorMastery, mastery, ignite)
    local combustTicks = CalculateTicks()
    local spellpower = GetSpellBonusDamage(3)
    if ignite then
        local total_amount = ignite.total_amount
        if total_amount then
            local contrib = math.ceil((total_amount / ignite.ticks_remaining) / 2 * floorMastery / mastery)
            return contrib
        else
            --print("Debug: Ignite Total Amount is nil during contribution calculation")
        end
    return 0
    else
        --print("Debug: No Ignite Found")
    end

end

local function CalculatePredictedCombustion()
    local spellpower = GetSpellBonusDamage(3)
    local mastery = GetMastery() * 2.8 / 100 + 1
    local floorMastery = math.floor(GetMastery() * 2.8) / 100 + 1

    local targetGuid = UnitGUID("target")

    local igniteEntry = ignite[targetGuid]
    local igniteContrib = 0

    local livingBombContrib = 0
    local pyroblastContrib = 0
    local critPresent = false

    for i = 1, 40 do
        local name, _, _, _, _, _, unitCaster, _, _, spellId = UnitDebuff("target", i)
        if not name then break end
        if unitCaster == "player" then
        --print("Debug: Beginning contributions")
            if spellId == 44457 then  -- Living Bomb
                livingBombContrib = CalculateLivingBombContrib(spellpower, floorMastery)
                --print("Debug: livingBombContrib:", livingBombContrib)
            elseif spellId == 11366 or spellId == 92315 then  -- Pyroblast
                pyroblastContrib = CalculatePyroblastContrib(spellpower, floorMastery)
                --print("Debug: pyroblastContrib:", pyroblastContrib)
            elseif spellId == 413841 or spellId == 12654 then  -- Ignite
                --print(igniteEntry.total_amount)
                igniteContrib = IgniteContrib(floorMastery, mastery, igniteEntry) or 0
                --print("Debug: igniteContrib:", igniteContrib)
            end
        end
        if spellId == 22959 or spellId == 17800 then  -- Critical debuffs
            critPresent = true
        end
    end

    local ticks = CalculateTicks()
    --print("Ticks : ", ticks)
    local tickDamage = livingBombContrib + pyroblastContrib + igniteContrib
    local total = 0
    if igniteEntry then
        total = igniteContrib * igniteEntry.ticks_remaining
    else
        total = igniteContrib
    end
    --print("livingBombContrib ", livingBombContrib, " + pyroblastContrib ", pyroblastContrib," + igniteContrib ", igniteContrib )
    --print("Tick damage : ")
    local totalCombustionDamage = tickDamage * ticks

    if critPresent == true then
        totalCombustionDamage = totalCombustionDamage * (((GetSpellCritChance(3) + 5) / 100) + 1)
    end

    --print("Debug: Predicted Combustion - Tick Damage:", tickDamage, "Total Damage:", totalCombustionDamage
    return totalCombustionDamage
end

-- Function to update the tracker with a new number
local function combustTracker()
    local ticks = CalculateTicks()
    local combust = CalculatePredictedCombustion()

    if combust == nil or combust == 0 then
        return
    end

    -- Update the lowest value
    if combust_tracker.lowest == nil or combust < combust_tracker.lowest then
        combust_tracker.lowest = combust
    end

    -- Update the highest value
    if combust_tracker.highest == nil or combust > combust_tracker.highest then
        combust_tracker.highest = combust
    end


    -- Update the total and count for calculating the average
    combust_tracker.total = combust_tracker.total + combust
    combust_tracker.count = combust_tracker.count + 1
    combust_tracker.average = combust_tracker.total / combust_tracker.count
end

local latestCritDamage = 0
local latestMastery = 0
local latestIgniteTick = 0
local latestCombustionData = {
tick_damage = 0,
total_damage = 0
}

local function IgniteSpellcritUpdate(destGuid, amount, spellId)
    -- Ensure the ignite entry exists or create a new one with default ticks remaining
    local igniteEntry = ignite[destGuid]
    if igniteEntry and igniteEntry.total_amount > 0 then -- If the target already has an ignite, get the ignite from the table
        igniteEntry.ticks_remaining = 3
    else -- If the target does not have an ignite, create a new one
        igniteEntry.ticks_remaining = 2
    end

    -- Calculate mastery contribution
    local mastery = GetMastery() * 2.8 / 100 + 1
    --print("Mastery: ", mastery)
    local total = amount * 0.4 * mastery
    --print(amount .. " * 0.4 * " .. mastery .. " = " .. total)
    --print("Ticks Remaining: ", igniteEntry.ticks_remaining)
    --print(total / igniteEntry.ticks_remaining)

    -- Debugging:--print before updating
    --print("Debug: Before Update - GUID:", destGuid, "Total Amount:", igniteEntry.total_amount, "Total Amount No Combustion:", igniteEntry.total_amount_no_combustion)

    -- Update or initialize total_amount
    if igniteEntry.total_amount > 0 then
        --print("Update: ", total / igniteEntry.ticks_remaining )
        if spellId == 11129 then
            igniteEntry.total_amount_no_combustion = igniteEntry.total_amount
        end
        igniteEntry.total_amount = igniteEntry.total_amount + total
    else
        --print("Initialize: ", total / igniteEntry.ticks_remaining )
        igniteEntry.total_amount = total
    end


    -- Debugging:--print after updating
    --print("Debug: After Update - GUID:", destGuid, "Total Amount:", igniteEntry.total_amount, "Ticks Remaining:", igniteEntry.ticks_remaining)

    -- Store the updated entry back into the ignite table
    ignite[destGuid] = igniteEntry

    -- Debugging: Verify and--print the final stored ignite entry
    --print("Debug: Final Ignite Entry - GUID:", destGuid, "Stored Total Amount:", ignite[destGuid].total_amount, "Stored Ticks Remaining:", ignite[destGuid].ticks_remaining)

    return igniteEntry
end


-- Function to handle Ignite ticks
local function IgniteTickUpdate(destGuid)
    local igniteEntry = ignite[destGuid]
    if igniteEntry then
        --print("Debug: Ignite Tick - Initial State for GUID:", destGuid, "Total Amount:", igniteEntry.total_amount, "Ticks Remaining:", igniteEntry.ticks_remaining)

        -- Ensure igniteEntry is valid before performing tick updates
        if igniteEntry.total_amount and igniteEntry.ticks_remaining and igniteEntry.ticks_remaining > 0 then
            -- Calculate the tick damage and deplete the bank based on the remaining ticks
            local tick_damage = igniteEntry.total_amount / igniteEntry.ticks_remaining
            igniteEntry.total_amount = igniteEntry.total_amount - tick_damage
            igniteEntry.ticks_remaining = igniteEntry.ticks_remaining - 1

            ----print debug information for each tick


            -- Update or remove the entry based on remaining ticks and total amount
            if igniteEntry.ticks_remaining > 0 and igniteEntry.total_amount > 0 then
                ignite[destGuid] = igniteEntry
               -- print("Tick Damage:", tick_damage, "Remaining Ignite Bank:", igniteEntry.total_amount)
            else
                ignite[destGuid] = nil
                --print("Debug: Ignite expired for GUID:", destGuid)
            end
        else
            --print("Debug: Ignite Entry Invalid for Tick Update - GUID:", destGuid, "Total Amount:", igniteEntry.total_amount, "Ticks Remaining:", igniteEntry.ticks_remaining)
            ignite[destGuid] = nil
        end
    else
        --print("Debug: No Ignite Entry for GUID:", destGuid, "to update ticks")
    end
end

-- Function to handle Ignite impact spread
local function IgniteImpactSpread(destGuid, time)
    if destGuid ~= ignite.impact_destGuid and time - ignite.impact_time < 0.1 then
        ignite[destGuid] = {
            total_amount = ignite.impact_amount,
            ticks_remaining = 2
        }
        --print("Debug: Ignite Impact Spread to GUID:", destGuid, "Total Amount:", ignite.impact_amount)
    end
end

-- Register state expression for predicted combustion
spec:RegisterStateExpr("predicted_combustion", function()
    combustTracker()
    return CalculatePredictedCombustion()
end)

local lastMana = UnitPower("player", Enum.PowerType.Mana)
local inactive, active = GetManaRegen()
local avgManaGained = 0
local avgManaSpent = 0
local totalManaGained = 0
local totalManaSpent = 0
local difference = (avgManaSpent - avgManaGained) + active
local timeToOOM = lastMana / difference
local combatStart = 0
local inCombat = false
local currentRotation = "DPS" -- Initialize as DPS rotation

-- Event handler for entering combat
spec:RegisterEvent("PLAYER_REGEN_DISABLED", function(event)
    combatStart = GetTime()
    inCombat = true
    totalManaGained = 0
    totalManaSpent = 0
    avgManaGained = 0
    avgManaSpent = 0
    currentRotation = "DPS" -- Start with DPS rotation
end)

-- Event handler for leaving combat
spec:RegisterEvent("PLAYER_REGEN_ENABLED", function()
    combatStart = 0
    inCombat = false
    totalManaGained = 0
    totalManaSpent = 0
    avgManaGained = 0
    avgManaSpent = 0
    currentRotation = "DPS" -- Reset to DPS rotation
end)

spec:RegisterCombatLogEvent(function(...)
    local timestamp, subtype, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool,
          amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
    local inCombat = UnitAffectingCombat("player")

    if not ignite[destGUID] then
        ignite[destGUID] = { ticks_remaining = 2, total_amount = 0, total_amount_no_combustion = 0 }
        --print("Debug: Initialized Ignite Entry for GUID:", destGUID)
    end

    lastMana = UnitPower("player", Enum.PowerType.Mana)
    if sourceGUID == state.GUID then
        if subtype == 'SPELL_DAMAGE' then
            if spellID == 413841 or spellID == 413843 then
                IgniteTickUpdate(destGUID)
            end
        end
        if subtype == 'SPELL_DAMAGE' and allowedSpellIds[spellID] then
            if critical then
               -- print(amount)
                IgniteSpellcritUpdate(destGUID, amount, spellID)
            end
        elseif subtype == 'SPELL_AURA_APPLIED' then
            if spellID == 88148 or spellID == 2120 then
                local countdown = 8
                local delay = 1
                fs_down = true
                local timer
                timer = C_Timer.NewTicker(delay, function()
                    if countdown > 0 then
                        countdown = countdown - 1
                        fs_down = true
                    else
                        timer:Cancel()
                        fs_down = false
                    end
                end, 9)
            end



        elseif subtype == 'SPELL_AURA_REMOVED' then
            if spellID == 413841 then
                C_Timer.After(0.1, function()
                    ignite[destGUID] = nil
                end)
            end

        elseif subtype == 'SPELL_CAST_SUCCESS' and spellID == 2120 then
            local countdown = 8
            local delay = 1
            fs_down = true
            local timer
            timer = C_Timer.NewTicker(delay, function()
                if countdown > 0 then
                    countdown = countdown - 1
                    fs_down = true
                else
                    timer:Cancel()
                    fs_down = false
                end
            end, 9)
        end
    end

    -- Handle other events such as SPELL_AURA_REMOVED and forced updates
    if AURA_REMOVED[subtype] and spellID == spec.auras.fingers_of_frost.id then
        lastFingersConsumed = GetTime()
    end

    if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" and spec.abilities[spellID] and spec.abilities[spellID].key == "frostbolt" then
        lastFrostboltCast = GetTime()
    end

    if AURA_EVENTS[subtype] and FORCED_RESETS[spellID] then
        Hekili:ForceUpdate("MAGE_AURA_CHANGED", true)
    end
end, false)

-- Declare static variables to retain their values across function calls
local oldHealth = nil
local initialHealth, initialTime = nil, nil
local averageHealth, averageTime = nil, nil

-- Declare static variables to retain their values across function calls
local oldHealth = nil
local initialHealth, initialTime = nil, nil
local averageHealth, averageTime = nil, nil
local lastCalculatedTTD = 300  -- Start with a default high value

spec:RegisterStateExpr("my_ttd", function()
    -- Get current target health and time
    local health = UnitHealth("target")
    local time = GetTime()

    -- If there's no valid target or the target is dead, return 0
    if not UnitExists("target") or UnitIsDead("target") then
        --print("Debug: No valid target or target is dead. Returning 0.")
        return 300
    end

    --print("Debug: Starting function execution")
    --print("Debug: Current target health:", health)
    --print("Debug: Current time:", time)
    if health == UnitHealthMax("target") then
        lastCalculatedTTD = 300
        return 300
    end
    -- Check if health has changed
    if oldHealth ~= health then
        oldHealth = health
        --print("Debug: Health changed, updating oldHealth to:", oldHealth)

        -- If target health is at maximum, reset the calculation but don't return a new TTD
        if health == UnitHealthMax("target") then
            initialHealth, initialTime = nil, nil
            averageHealth, averageTime = nil, nil
            --print("Debug: Target health is at maximum, resetting variables")
            return lastCalculatedTTD  -- Return the last valid TTD without updating
        end

        -- Initialize on first valid health update
        if not initialHealth then
            initialHealth, initialTime = health, time
            averageHealth, averageTime = health, time
            --print("Debug: Initializing health and time values")
            --print("Debug: initialHealth, initialTime set to:", initialHealth, initialTime)
            --print("Debug: averageHealth, averageTime set to:", averageHealth, averageTime)
            return lastCalculatedTTD  -- Return the last valid TTD without updating
        end

        -- Update average health and time
        averageHealth = (averageHealth + health) * 0.5
        averageTime = (averageTime + time) * 0.5
       --print("Debug: Updating average health and time")
       --print("Debug: Before update - averageHealth:", averageHealth, "averageTime:", averageTime)

        -- Check if average health is increasing (which indicates healing or stabilization)
        if averageHealth >= initialHealth then
            initialHealth, initialTime = nil, nil
            averageHealth, averageTime = nil, nil
           --print("Debug: Average health is greater than or equal to initial health, resetting variables")
            return lastCalculatedTTD  -- Return the last valid TTD without updating
        else
            -- Calculate time to die in seconds
            local healthDropRate = (initialHealth - averageHealth)
            local timeElapsed = (time - averageTime)
            local timeToDie = health * timeElapsed / healthDropRate

           --print("Debug: Calculating time to die")
           --print("Debug: initialHealth:", initialHealth, "initialTime:", initialTime, "averageHealth:", averageHealth, "averageTime:", averageTime)
           --print("Debug: Calculated TTD in seconds:", timeToDie)

            lastCalculatedTTD = timeToDie  -- Store the calculated TTD
            return timeToDie  -- Return the calculated time to die in seconds
        end
    else
       --print("Debug: Health did not change, returning last calculated TTD:", lastCalculatedTTD)
    end

    return lastCalculatedTTD  -- Return the last valid TTD if health has not changed
end)

-- Register state expressions to expose Ignite data
spec:RegisterStateExpr("ignite_total_amount", function()
    local targetGuid = UnitGUID("target")
    local igniteEntry = ignite[targetGuid]

    if igniteEntry and igniteEntry.total_amount then
        return igniteEntry.total_amount
    else
        return 0
    end
end)

spec:RegisterStateExpr("ignite_ticks_remaining", function()
    local targetGuid = UnitGUID("target")
    local igniteEntry = ignite[targetGuid]

    if igniteEntry and igniteEntry.ticks_remaining then
        return igniteEntry.ticks_remaining
    else
        return 0
    end
end)

spec:RegisterStateExpr("ignite_total_amount_no_combustion", function()
    local targetGuid = UnitGUID("target")
    local igniteEntry = ignite[targetGuid]

    if igniteEntry and igniteEntry.total_amount_no_combustion then
        return igniteEntry.total_amount_no_combustion
    else
        return 0
    end
end)




local mana_gem_values = {
    [5514] = 390,
    [5513] = 585,
    [8007] = 829,
    [8008] = 1073,
    [22044] = 2340,
    [36799] = 3330
}

spec:RegisterStateExpr( "mana_gem_charges", function() return 0 end )
spec:RegisterStateExpr( "mana_gem_id", function() return 36799 end )
spec:RegisterStateExpr( "ignite_damage", function() return igniteDamage end )

spec:RegisterStateExpr( "frozen", function()
    return buff.fingers_of_frost.up or debuff.frozen.up
end )

spec:RegisterHook( "reset_precast", function()
    mana_gem_charges = nil
    mana_gem_id = nil

    for item in pairs( mana_gem_values ) do
        count = GetItemCount( item, nil, true )
        if count > 0 then
            mana_gem_charges = count
            mana_gem_id = item
            break
        end
    end

    -- When Frostbolt consumes FoF, we can still make use of that FoF until the Frostbolt impact.

    local frostbolt_remains = action.frostbolt.in_flight_remains
    if frostbolt_remains == 0 and query_time - lastFrostboltCast < 0.2 then
        frostbolt_remains = max( 0, lastFrostboltCast + ( target.distance / action.frostbolt.velocity ) - query_time )
    end

    if lastFingersConsumed == lastFrostboltCast and frostbolt_remains > 0 and frostbolt_remains < cooldown.deep_freeze.remains then
        if buff.fingers_of_frost.up then 
            addStack( "fingers_of_frost" )
        else
            addStack( "fingers_of_frost", frostbolt_remains )
        end
    end

    if heatingUp then
        applyBuff("heating_up")
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Launches several missiles at the enemy target, causing $s1 Arcane damage.
    arcane_barrage = {
        id = 44425,
        cast = 0,
        cooldown = 4,
        gcd = "spell",

        spend = function()
              if buff.clearcasting.up then
                 return 0
              else
                 local base_cost = 0.11
                 local cost_with_arcane_power = buff.arcane_power.up and base_cost * 1.1 or base_cost
                 return cost_with_arcane_power
              end
        end,
        spendType = "mana",
        stance = "None",
        startsCombat = true,
        texture = 236205,
        velocity = 24,
        impact = function()
        end,

        handler = function()
            removeDebuff( "player", "arcane_blast" )
            if buff.clearcasting.up then removeBuff( "clearcasting" ) end
        end,
    },

    -- Blasts the target with energy, dealing $s1 Arcane damage.  Each time you cast Arcane Blast, the damage of all Arcane spells is increased by $36032s1% and mana cost of Arcane Blast is increased by $36032s2%.  Effect stacks up to $36032u times and lasts $36032d or until any Arcane damage spell except Arcane Blast is cast.
    arcane_blast = {
        id = 30451,
        cast = function()
            return (buff.presence_of_mind.up and 0) or (2 * haste)
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            if buff.clearcasting.up then
                return 0
            else
                local base_cost = 0.05 * (debuff.arcane_blast.stack * 1.75)
                local cost_with_arcane_power = buff.arcane_power.up and base_cost * 1.1 or base_cost
                return cost_with_arcane_power
            end
        end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if buff.presence_of_mind.up then removeBuff( "presence_of_mind" )
            elseif buff.clearcasting.up then removeBuff( "clearcasting" ) end

            applyDebuff( "player", "arcane_blast", nil, min( 4, debuff.arcane_blast.stack + 1 ) )

        end,

    },

    -- Infuses all party and raid members with brilliance, increasing their Intellect by $s1 for $d.
    arcane_brilliance = {
        id = 1459,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            local base_cost = 0.26
            local cost_with_glyph = glyph.arcane_brilliance.enabled and base_cost * .5 or base_cost
            return cost_with_glyph
        end,
        spendType = "mana",

        startsCombat = false,
        bagItem = 17020,

        nobuff = "arcane_brilliance",
        handler = function()
            applyBuff( "arcane_brilliance" )
            active_dot.arcane_brilliance = group_members

        end,

        copy = { 23028, 27127, 43002, 61316, "arcane_intellect", "dalaran_brilliance" },
    },

    -- Causes an explosion of arcane magic around the caster, causing $s1 Arcane damage to all targets within $a1 yards.
    arcane_explosion = {
        id = 1449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",


        spend = function()
            if buff.clearcasting.up then
                return 0
            else
                local base_cost = 0.15 * (1 - (talent.improved_arcane_explosion.rank * 0.25))
                local cost_with_arcane_power = buff.arcane_power.up and base_cost * 1.1 or base_cost
                return cost_with_arcane_power
            end
        end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            return true
        end,

    },

    -- Launches Arcane Missiles at the enemy, causing $7268s1 Arcane damage every $5143t2 sec for $5143d.
    arcane_missiles = {
        id = 5143,
        cast = Channeled,
        cooldown = 0,
        gcd = "spell",
        cast = 2.5,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        spend = function() return ( buff.clearcasting.up or buff.arcane_missiles.up ) and 0 or 0.310 * ( buff.arcane_power.up and 1.1 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        start = function()
            removeDebuff( "player", "arcane_blast" )

            if buff.arcane_missiles.up then removeBuff( "arcane_missiles" )
            elseif buff.clearcasting.up then removeBuff( "clearcasting" ) end

        end,


        copy = { 5143, 7269, 7270, 8419, 8418, 10273, 10274, 25346, 27076, 38700, 38704, 42844, 42846 },
    },
    --Increases the damage of your Arcane spells by 25%. In the Arcane Abilities category. Learn how to use this in our class guide. Added in World of Warcraft: Cataclysm.
    arcane_specialization = {
        id = 84671,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 425951,

        --fix:
        stance = "None",
        handler = function()
            --"/cata/spell=84671/arcane-specialization"
        end,

    },

    -- When activated, your spells deal $s1% more damage while costing $s2% more mana to cast.  This effect lasts $D.
    arcane_power = {
        id = 12042,
        cast = 0,
        cooldown = function() return 120 - ( 12.5 * talent.arcane_flows.rank ) end,
        gcd = "off",

        toggle = "cooldowns",
        startsCombat = false,

        handler = function()
            applyBuff( "arcane_power" )
        end,

    },

    -- A wave of flame radiates outward from the caster, damaging all enemies caught within the blast for $s1 Fire damage, knocking them back and dazing them for $d.
    blast_wave = {
        id = 11113,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spendType = "mana",

        startsCombat = true,
        texture = 135903,

        spend = function() return buff.clearcasting.up and 0 or 0.070 * ( buff.arcane_power.up and 1.1 or 1 ) end,


        handler = function()
            if target.within10 then
                applyDebuff( "target", "blast_wave" )
                applyBuff("active_flamestrike")
            end
        end,

    },

    -- Teleports the caster $a1 yards forward, unless something is in the way.  Also frees the caster from stuns and bonds.
    blink = {
        id = 1953,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = function() return 0.12 end,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            applyBuff( "blink" )
            setDistance( max( 5, target.distance - ( glyph.blink.enabled and 25 or 20 ) ) )

            if talent.improved_blink.enabled then applyBuff( "improved_blink" ) end
        end,
 },

    -- Ice shards pelt the target area doing ${$42208m1*8*$<mult>} Frost damage over $10d.
    blizzard = {
        id = 10,
        cast = 8,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.740 * ( buff.arcane_power.up and 1.1 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if talent.improved_blizzard.enabled then
                applyDebuff("chilled")
            end
        end,
    },

    -- When activated, this spell finishes the cooldown on all Frost spells you recently cast.
    cold_snap = {
        id = 11958,
        cast = 0,
        cooldown = function()
            local base_cooldown = 480 -- base cooldown in seconds

            -- Get the talent ranks
            local ice_floes_rank = talent.ice_floes.rank

            -- Calculate reduction from ice_floes
            local ice_floes_reduction = 0
            if ice_floes_rank == 3 then
                ice_floes_reduction = 0.20
            else
                ice_floes_reduction = ice_floes_rank * 0.07
            end

            -- Total reduction
            local total_reduction = ice_floes_reduction

            -- Calculate the final cooldown
            return base_cooldown * (1 - total_reduction)
        end,
        gcd = "off",

        startsCombat = true,
        texture = 135865,
        toggle = "cooldowns",

        handler = function()
            setCooldown("ice_block", 0)
            setCooldown("icy_veins", 0)
            setCooldown("summon_water_elemental", 0)
        end,
    },


    --Combines your damaging periodic Fire effects on an enemy target but does not consume them, instantly dealing 955 to 1131 Fire damage and creating a new periodic effect that lasts 10 sec and deals damage per time equal to the sum of the combined effects.
    combustion = {
        id = 11129,
        cast = 0,
        cooldown = 120,
        gcd = "off",



        startsCombat = true,
        texture = 135824,

        --fix:
        stance = "None",
        handler = function()
            --"/cata/spell=100287/bens-test-spell"
        end,

    },

    -- Targets in a cone in front of the caster take ${$m2*$<mult>} to ${$M2*$<mult>} Frost damage and are slowed by $s1% for $d.
    cone_of_cold = {
        id = 120,
        cast = 0,
        cooldown = function()
                    local base_cooldown = 10 -- base cooldown in seconds

                    -- Get the talent ranks
                    local ice_floes_rank = talent.ice_floes.rank

                    -- Calculate reduction from ice_floes
                    local ice_floes_reduction = 0
                    if ice_floes_rank == 3 then
                        ice_floes_reduction = 0.20
                    else
                        ice_floes_reduction = ice_floes_rank * 0.07
                    end

                    -- Total reduction
                    local total_reduction = ice_floes_reduction

                    -- Calculate the final cooldown
                    return base_cooldown * (1 - total_reduction)
                end,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.250 * ( buff.arcane_power.up and 1.1 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if target[ "within" .. ( 10 * ( 1 + 0.1 * talent.arctic_reach.rank ) ) ] then
                applyDebuff( "target", "cone_of_cold" )
            end

        end,

        copy = { 120, 8492, 10159, 10160, 10161, 27087, 42930, 42931 },
    },

    -- Conjures a mana agate that can be used to instantly restore $5405s1 mana.
    conjure_mana_gem = {
        id = 759,
        cast = function() return buff.presence_of_mind.up and 0 or 3 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.750,
        spendType = "mana",

        startsCombat = false,

        usable = function() return mana_gem_charges < 3, "mana gem is fully charged" end,
        handler = function()
            mana_gem_id = 36799
            mana_gem_charges = 3
        end,
    },

    -- Conjures $s1 Mana Pies providing the mage and $ghis:her; allies with something to eat.; Conjured items disappear if logged out for more than 15 minutes.
    conjure_refreshment = {
        id = 42955,
        cast = function() return buff.presence_of_mind.up and 0 or 3 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.400,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            -- Effects:
            -- [ ] 1.0 CREATE_ITEM, NONE, item_type: 43518, item: conjured_mana_pie, points: 20, target: TARGET_UNIT_CASTER
            -- [ ] 2.0 CREATE_ITEM, NONE, item_type: 43523, item: conjured_mana_strudel, points: 20, target: TARGET_UNIT_CASTER
        end,

        copy = { 42955, 42956 },
    },

    -- Counters the enemy's spellcast, preventing any spell from that school of magic from being cast for $d.  Generates a high amount of threat.
    counterspell = {
        id = 2139,
        cast = 0,
        cooldown = 24,
        gcd = "off",

        spend = 0.090,
        spendType = "mana",

        startsCombat = true,
        toggle = "interrupts",

        readyTime = state.timeToInterrupt,
        debuff = "casting",

        handler = function()
            interrupt()
            if talent.improved_counterspell.enabled then applyDebuff( "target", "silenced_improved_counterspell" ) end
        end,

    },

    -- Stuns the target for $d.  Only usable on Frozen targets.  Deals ${$71757m1*$<mult>} to ${$71757M1*$<mult>} damage to targets permanently immune to stuns.
    deep_freeze = {
        id = 44572,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 236214,

        debuff = function() return buff.fingers_of_frost.down and "frozen" or nil end,
        handler = function()
            if buff.fingers_of_frost.up then removeStack( "fingers_of_frost" ) end
            applyDebuff( "target", "deep_freeze" )
        end,
    },

    -- Targets in a cone in front of the caster take $s1 Fire damage and are Disoriented and Snared for $d.  Any direct damaging attack will revive targets.  Turns off your attack when used.
    dragons_breath = {
        id = 31661,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = true,
        texture = 134153,

        handler = function()
            if target.within10 then
                applyDebuff( "target", "dragons_breath" )
            end
        end,
    },

    -- While channeling this spell, you gain $o1% of your total mana over $d.
    evocation = {
        id = 12051,
        cast = function() return 8 * haste end,
        channeled = true,
        cooldown = function() return 240 - ( 60 * talent.arcane_flows.rank ) end,
        gcd = "spell",

        startsCombat = false,

        start = function()
            applyBuff( "evocation" )

        end,

        tick = function()
            gain( 0.15 * power.max, "mana" )
        end,

        finish = function()
            removeBuff( "evocation" )
        end,

        onBreakChannel = function()
            removeBuff( "evocation" )
        end,

    },

    -- Blasts the enemy for $s1 Fire damage.
    fire_blast = {
        id = 2136,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.210 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.1 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            removeBuff("impact_stun")
        end,


        copy = { 2136, 2137, 2138, 8412, 8413, 10197, 10199, 27078, 27079, 42872, 42873 },
    },

    -- Hurls a fiery ball that causes $s1 Fire damage and an additional $o2 Fire damage over $d.
    fireball = {
        id = 133,
        cast = function()
            if buff.presence_of_mind.up then return 0 end
            local base = level > 23 and 3.5 or level > 17 and 3 or level > 11 and 2.5 or level > 5 and 2 or 1.5
            return base * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return ( buff.clearcasting.up or buff.fireball_proc.up ) and 0 or 0.19 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.1 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        velocity = 24,

        handler = function()
            if buff.fireball_proc.up then removeBuff( "fireball_proc" )
            elseif buff.clearcasting.up then removeBuff( "clearcasting" )
            elseif buff.presence_of_mind then removeBuff( "presence_of_mind" ) end
        end,

        impact = function()
            if not glyph.fireball.enabled then applyDebuff( "target", "fireball" ) end

        
        end,

        

        copy = { 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306, 27070, 38692, 42832, 42833 },
    },
    --At the end of its duration your Flame Orb explodes, dealing 1235.5 Fire damage to all nearby enemies. In the Fire Abilities category. A spell.
    fire_power = {
        id = 83619,
        cast = 0,
        cooldown = 0,
        gcd = "off",



        startsCombat = true,
        texture = 236207,

        --fix:
        stance = "None",
        handler = function()
            --"/cata/spell=97070/flamestrike-test"
        end,

    },

    --Increases the damage of your Fire spells by 25%. In the Fire Abilities category. Learn how to use this in our class guide. Added in World of Warcraft: Cataclysm.
    fire_specialization = {
        id = 84668,
        cast = 0,
        cooldown = 0,
        gcd = "off",



        startsCombat = true,
        texture = 135805,

        --fix:
        stance = "None",
        handler = function()
            --"/cata/spell=11129/combustion"
        end,

    },

    --Launches a Flame Orb forward from the Mage's position, dealing 229 to 293 Fire damage every second to the closest enemy target for 15 secsFire Power and exploding for 1235.5 at the end of its duration with a 66% chance to explode for 1235.5 at the end of its duration with a 33% chance to explode for 1235.5 at the end of its duration.
    flame_orb = {
        id = 82731,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 451164,

        --fix:
        stance = "None",
        handler = function()
            --"/cata/spell=82731/flame-orb"
        end,
        copy = { 82731, 92283 },

    },

    -- Calls down a pillar of fire, burning all enemies within the area for $s1 Fire damage and an additional $o2 Fire damage over $d.
    flamestrike = {
        id = 2120,
        cast = function() return ( buff.firestarter.up or buff.presence_of_mind.up ) and 0 or 2 * haste end,
        cooldown = 8,
        gcd = "spell",

        spend = function() return ( buff.firestarter.up or buff.clearcasting.up ) and 0 or 0.300 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.1 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if buff.clearcasting.up then removeBuff( "clearcasting" ) end
            if buff.presence_of_mind.up then removeBuff( "presence_of_mind" ) end
            applyDebuff( "target", "flamestrike" )
            applyBuff("active_flamestrike")
        end,

        
        copy = { 2120, 2121, 8422, 8423, 10215, 10216, 27086, 42925, 42926, 88148 },
    },

    -- Increases the target's chance to critically hit with spells by $s1%.  When the target critically hits the caster's chance to critically hit with spells is increased by $54648s1% for $54648d.  Cannot be cast on self.
    focus_magic = {
        id = 54646,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 135754,

        usable = function() return group, "cannot cast on self" end,
        handler = function()
            active_dot.focus_magic = active_dot.focus_magic + 1
        end,

      },

    -- Increases Armor by $s1.  If an enemy strikes the caster, they may have their movement slowed by $6136s1% and the time between their attacks increased by $6136s2% for $6136d.  Only one type of Armor spell can be active on the Mage at any time.  Lasts $d.
    frost_armor = {
        id = 7302,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.240 * ( 1 - ( 0.01 * talent.precision.rank ) ) * ( 1 - ( talent.frost_channeling.enabled and ( 1 + talent.frost_channeling.rank * 0.03 ) or 0 ) ) end,
        spendType = "mana",

        startsCombat = false,
        essential = true,
        nobuff = "frost_armor",

        handler = function()
            removeBuff( "unique_armor" )
            applyBuff( "frost_armor" )

        end,
        copy = { 168, 7300, 7301 },
    },

    -- Blasts enemies near the caster for ${$m1*$<mult>} to ${$M1*$<mult>} Frost damage and freezes them in place for up to $d.  Damage caused may interrupt the effect.
    frost_nova = {
        id = 122,
        cast = 0,
        cooldown = function()
                            local base_cooldown = 25 -- base cooldown in seconds

                            -- Get the talent ranks
                            local ice_floes_rank = talent.ice_floes.rank

                            -- Calculate reduction from ice_floes
                            local ice_floes_reduction = 0
                            if ice_floes_rank == 3 then
                                ice_floes_reduction = 0.20
                            else
                                ice_floes_reduction = ice_floes_rank * 0.07
                            end

                            -- Total reduction
                            local total_reduction = ice_floes_reduction

                            -- Calculate the final cooldown
                            return base_cooldown * (1 - total_reduction)
                        end,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.070 * ( 1 - 0.01 * buff.precision.rank ) * ( buff.arcane_power.up and 1.1 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if target[ "within" .. ( 10 + target.arctic_reach.rank ) ] then
                applyDebuff( "target", "frost_nova" )
            end

         end,

        copy = { 122, 865, 6131, 10230, 27088, 42917 },
    },
    --Increases the damage of your Frost spells by 25% and of your Frostbolt spell by an additional 15%Frostburn but reduces your mastery by 6. Always up to date.
    frost_specialization = {
        id = 84669,
        cast = 0,
        cooldown = 0,
        gcd = "off",



        startsCombat = true,
        texture = 135777,

        --fix:
        stance = "None",
        handler = function()
            --"/cata/spell=99560/piercing-chill"
        end,

    },

    -- Launches a bolt of frost at the enemy, causing ${$m2*$<mult>} to ${$M2*$<mult>} Frost damage and slowing movement speed by $s1% for $d.
    frostbolt = {
        id = 116,
        cast = function() return buff.presence_of_mind.up and 0 or 2 - ( 0.3 * talent.early_frost.rank ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.110 * ( buff.arcane_power.up and 1.1 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        velocity = 28,

        handler = function()
            if buff.clearcasting.up then removeBuff( "clearcasting" ) end
            if buff.presence_of_mind.up then removeBuff( "presence_of_mind" ) end
        end,

        impact = function()
            applyDebuff( "target", "frostbolt" )
        end,
        copy = { 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304, 27071, 27072, 38697, 42841, 42842 },
    },

    -- Launches a bolt of frostfire at the enemy, causing ${$m2*$<mult>} to ${$M2*$<mult>} Frostfire damage, slowing movement speed by $s1% and causing an additional $o3 Frostfire damage over $d. This spell will be checked against the lower of the target's Frost and Fire resists.
    frostfire_bolt = {
        id = 44614,
        cast = function() return ( buff.fireball_proc.up or buff.presence_of_mind.up ) and 0 or 3 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.fireball_proc.up and 0 or 0.140 * ( buff.arcane_power.up and 1.1 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        velocity = 28,

        handler = function()
            if buff.fireball_proc.up then removeBuff( "fireball_proc" )
            elseif buff.presence_of_mind.up then removeBuff( "presence_of_mind" ) end
            if buff.fingers_of_frost.up then removeStack( "fingers_of_frost" ) end
        end,

        impact = function()
            applyDebuff( "frostfire_bolt" )

        end,

    

        copy = { 44614, 47610 },
    },

    -- Instantly shields you, absorbing $s1 damage.  Lasts $d.  While the shield holds, spellcasting will not be delayed by damage.
    ice_barrier = {
        id = 11426,
        cast = 0,
        cooldown = function()
                            local base_cooldown = 30 -- base cooldown in seconds

                            -- Get the talent ranks
                            local ice_floes_rank = talent.ice_floes.rank

                            -- Calculate reduction from ice_floes
                            local ice_floes_reduction = 0
                            if ice_floes_rank == 3 then
                                ice_floes_reduction = 0.20
                            else
                                ice_floes_reduction = ice_floes_rank * 0.07
                            end

                            -- Total reduction
                            local total_reduction = ice_floes_reduction

                            -- Calculate the final cooldown
                            return base_cooldown * (1 - total_reduction)
                        end,
        gcd = "spell",

        spend = 0.21,
        spendType = "mana",

        startsCombat = true,
        texture = 135988,

        stance = "None",
        handler = function()
            applyBuff( "ice_barrier" )
        end,
    },


    -- You become encased in a block of ice, protecting you from all physical attacks and spells for $d, but during that time you cannot attack, move or cast spells.  Also causes Hypothermia, preventing you from recasting Ice Block for $41425d.
    ice_block = {
        id = 45438,
        cast = 0,
        cooldown = function()
                            local base_cooldown = 300 -- base cooldown in seconds

                            -- Get the talent ranks
                            local ice_floes_rank = talent.ice_floes.rank

                            -- Calculate reduction from ice_floes
                            local ice_floes_reduction = 0
                            if ice_floes_rank == 3 then
                                ice_floes_reduction = 0.20
                            else
                                ice_floes_reduction = ice_floes_rank * 0.07
                            end

                            -- Total reduction
                            local total_reduction = ice_floes_reduction

                            -- Calculate the final cooldown
                            return base_cooldown * (1 - total_reduction)
                        end,
        gcd = "spell",

        spend = 15,
        spendType = "mana",

        startsCombat = false,

        nodebuff = "hypothermia",
        handler = function()
            applyBuff( "ice_block" )
            removeDebuff( "player", "hypothermia" )

         end,

    },

    -- Deals ${$m1*$<mult>} to ${$M1*$<mult>} Frost damage to an enemy target.  Causes triple damage against Frozen targets.
    ice_lance = {
        id = 30455,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.060 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.1 or 1 ) * ( talent.frost_channeling.enabled and ( 0.99 - 0.03 * talent.frost_channeling.rank ) or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        velocity = 38,

        handler = function()
         end,

        impact = function()
            if buff.fingers_of_frost.up then removeBuff( "fingers_of_frost" )
            elseif debuff.frost_nova.up then removeDebuff( "target", "frost_nova" )
            elseif debuff.frostbite.up then removeDebuff( "target", "frostbite" ) end
        end,

        copy = { 30455, 42913, 42914 },
    },

    -- Hastens your spellcasting, increasing spell casting speed by $s1% and reduces the pushback suffered from damaging attacks while casting by $s2%.  Lasts $d.
    icy_veins = {
        id = 12472,
        cast = 0,
        startsCombat = true,
        texture = 135838,

        cooldown = function()
            local base_cooldown = 180 -- base cooldown in seconds
            local ice_floes_rank = talent.ice_floes.rank
            local ice_floes_reduction = 0

            if ice_floes_rank == 3 then
                ice_floes_reduction = 0.20
            else
                ice_floes_reduction = ice_floes_rank * 0.07
            end

            return base_cooldown * (1 - ice_floes_reduction)
        end,
        gcd = "off",

        spend = 0.030,
        spendType = "mana",

        toggle = "cooldowns",

        handler = function()
            applyBuff("icy_veins")
            stat.haste = stat.haste + 20
        end,
    },

    -- $?s54354[Instantly makes the caster invisible, reducing all threat.][Fades the caster to invisibility over $66d, reducing threat each second.]  The effect is cancelled if you perform any actions.  While invisible, you can only see other invisible targets and those who can see invisible.  Lasts $32612d.
    invisibility = {
        id = 66,
        cast = 0,
        cooldown = function() return 180 * ( 1 - 0.125 * talent.arcane_flows.rank ) end,
        gcd = "spell",

        spend = 0.160,
        spendType = "mana",

        startsCombat = false,
        toggle = "defensives",

        handler = function()
            if talent.prismatic_cloak.rank == 3 then
                applyBuff( "invisibility" )
            else
                applyBuff( "invisibility_fading" )
                applyBuff( "invisibility" )
                buff.invisibility.applied = buff.invisibility_fading.expires
            end
        end,

       
    },

    -- The target becomes a Living Bomb, taking $o1 Fire damage over $d.  After $d or when the spell is dispelled, the target explodes dealing $44461s1 Fire damage to all enemies within $44461a1 yards.
    living_bomb = {
        id = 44457,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.220,
        spendType = "mana",

        startsCombat = true,
        cycle = "living_bomb",

        handler = function()
            applyDebuff( "target", "living_bomb" )
         end,

        

        copy = { 44461, 55361, 55362 },
    },

    -- Increases your resistance to all magic by $s1 and allows $s2% of your mana regeneration to continue while casting.  Only one type of Armor spell can be active on the Mage at any time.  Lasts $d.
    mage_armor = {
        id = 6117,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.260,
        spendType = "mana",

        startsCombat = false,

        nobuff = "mage_armor",
        handler = function()
            removeBuff( "unique_armor" )
            applyBuff( "mage_armor" )

        end,

    
        copy = { 6117, 22782, 22783, 27125, 43023, 43024 },
    },

    mage_ward = {
        id = 543,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            applyBuff( "mage_ward" )
        end,
    },

    -- Absorbs $s1 damage, draining mana instead.  Drains $e mana per damage absorbed.  Lasts $d.
    mana_shield = {
        id = 1463,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.070,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            applyBuff( "mana_shield" )

         end,

        copy = { 1463, 8494, 8495, 10191, 10192, 10193, 27131, 43019, 43020 },
    },

    -- Creates $<images> copies of the caster nearby, which cast spells and attack the mage's enemies.  Lasts $55342d.
    mirror_image = {
        id = 55342,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.100,
        spendType = "mana",

        startsCombat = false,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "mirror_image" )

        end,
    },

    -- Causes $34913s1 Fire damage when hit, increases your critical strike rating by $30482s3% of your Spirit, and reduces the chance you are critically hit by $30482s2%.  Only one type of Armor spell can be active on the Mage at any time.  Lasts $30482d.
    molten_armor = {
        id = 30482,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.280 * ( 1 - 0.01 * talent.precision.rank ) end,
        spendType = "mana",

        startsCombat = false,
        essential = true,
        nobuff = "molten_armor",

        handler = function()
            removeBuff( "unique_armor" )
            applyBuff( "molten_armor" )

        end,

        copy = { 34913, 43045, 43046 },
    },

    -- Transforms the enemy into a sheep, forcing it to wander around for up to $d.  While wandering, the sheep cannot attack or cast spells but will regenerate very quickly.  Any damage will transform the target back into its normal form.  Only one target can be polymorphed at a time.  Only works on Beasts, Humanoids and Critters.
    polymorph = {
        id = 118,
        cast = function() return buff.presence_of_mind.up and 0 or 1.5 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.070 * ( 1 - 0.01 * talent.arcane_focus.rank ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if buff.presence_of_mind.up then removeBuff( "presence_of_mind" ) end

            active_dot.polymorph = 0
            applyDebuff( "target", "polymorph" )

        end,

        copy = { 118, 12824, 12825, 12826, 28271, 28272, 61025, 61305, 61721, 61780 },
    },

    -- When activated, your next Mage spell with a casting time less than 10 sec becomes an instant cast spell.
    presence_of_mind = {
        id = 12043,
        cast = 0,
        gcd = "off",



        startsCombat = true,
        texture = 136031,
        cooldown = function() return 120 - ( 1 - 0.125 * talent.arcane_flows.rank ) end,

        toggle = "cooldowns",

        handler = function()
            applyBuff( "presence_of_mind" )
        end,

    },

    -- Hurls an immense fiery boulder that causes $s1 Fire damage and an additional $o2 Fire damage over $d.
    pyroblast = {
        id = 11366,
        cast = function()
            if buff.presence_of_mind.up then
                return 0
            elseif buff.hot_streak.up then
                return 0
            else
                return 3.5
            end
        end,
        cooldown = function() return ( talent.fiery_payback.enabled and health.pct < 35 and ( 2.5 * buff.fiery_payback.rank ) or 0 ) end,
        gcd = "spell",

        spend = function() return ( buff.clearcasting.up or buff.hot_streak.up ) and 0 or 0.220 * ( 1 - 0.01 * talent.precision.rank ) * ( buff.arcane_power.up and 1.1 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        velocity = 24,

        handler = function()
            if buff.clearcasting.up then removeBuff( "clearcasting" )
            elseif buff.hot_streak.up then removeBuff( "hot_streak" ) end
            if buff.presence_of_mind.up then removeBuff( "presence_of_mind" ) end
            if talent.critical_mass.rank == 3 then
               applyDebuff( "target", "critical_mass" )
            end
        end,

        impact = function()
            applyDebuff( "target", "pyroblast" )
        end,
        copy = { 11366, 92315 }
    },

    -- Removes $m1 Curse from a friendly target.
    remove_curse = {
        id = 475,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.080 * ( 1 - 0.01 * talent.arcane_focus.rank ) end,
        spendType = "mana",

        startsCombat = false,

        buff = "dispellable_curse",
        handler = function()
            removeBuff( "dispellable_curse" )
        end,

},

    -- TODO: Replace with Use Mana Gem.
    -- Restores $s1 mana.
    replenish_mana = {
        id = 42987,
        name = "|cff00ccff[Mana Gem]|r",
        link = "|cff00ccff[Mana Gem]|r",
        known = function()
            return state.mana_gem_charges > 0
        end,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,

        item = function() return state.mana_gem_id or 36799 end,
        bagItem = true,
        texture = function() return GetItemIcon( state.mana_gem_id or 36799 ) end,

        usable = function ()
            return mana_gem_charges > 0, "requires mana_gem in bags"
        end,

        readyTime = function ()
            local start, duration = GetItemCooldown( state.mana_gem_id )
            return max( 0, start + duration - query_time )
        end,

        handler = function()
            gain( mana_gem_values[ state.mana_gem_id ] * ( glyph.mana_gem.enabled and 1.4 or 1 ), "mana" )
            mana_gem_charges = mana_gem_charges - 1

        end,


        copy = { 5405, 10052, 10057, 10058, 27103, 42987, "mana_gem", "use_mana_gem" },
    },
    --Summons a Ring of Frost, taking 3 sec to coalesce.  Enemies entering the fully-formed ring will become frozen for 10 sec.  Lasts 12 sec.  10 yd radius.
    ring_of_frost = {
        id = 82676,
        cast = 0,
        cooldown = 2,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = true,
        texture = 464484,

        --fix:
        stance = "None",
        handler = function()
            --"/cata/spell=82676/ring-of-frost"
        end,
        copy = { 82676, 82691 },

    },

    -- Scorch the enemy for $s1 Fire damage.
    scorch = {
        id = 2948,
        cast = function() return buff.presence_of_mind.up and 0 or 1.5 * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return buff.clearcasting.up and 0 or 0.080 * ( buff.arcane_power.up and 1.1 or 1 ) end,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            if talent.critical_mass.rank == 3 then
                applyDebuff( "target", "critical_mass" )
            end

        end,


        copy = { 2948, 8444, 8445, 8446, 10205, 10206, 10207, 27073, 27074, 42858, 42859 },
    },

    -- Reduces target's movement speed by $s1%, increases the time between ranged attacks by $s2% and increases casting time by $s3%.  Lasts $d.  Slow can only affect one target at a time.
    slow = {
        id = 31589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.120,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            applyDebuff( "target", "slow" )

        end,
    },

    -- Slows friendly party or raid target's falling speed for $d.
    slow_fall = {
        id = 130,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.060,
        spendType = "mana",

        startsCombat = false,
        bagItem = function()
            if glyph.slow_fall.enabled then return end
            return 17056
        end,

        handler = function()
            applyBuff( "slow_fall" )

        end,

     },

    -- Steals a beneficial magic effect from the target.  This effect lasts a maximum of 2 min.
    spellsteal = {
        id = 30449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.200,
        spendType = "mana",

        startsCombat = true,

        debuff = "stealable_magic",
        handler = function()
            removeDebuff( "target", "stealable_magic" )

        end,

    },

    -- Summon a Water Elemental to fight for the caster$?(s70937)[][ for $70907d].
    summon_water_elemental = {
        id = 31687,
        cast = 0,
        cooldown = function() return ( glyph.water_elemental.enabled and 150 or 180 ) * ( 1 - 0.1 * talent.cold_as_ice.rank ) end,
        gcd = "spell",

        spend = function() return 0.160 * ( talent.frost_channeling.enabled and ( 0.99 - 0.03 * talent.frost_channeling.rank ) or 1 ) end,
        spendType = "mana",

        startsCombat = false,

        handler = function()
            summonPet( "water_elemental", spec.auras.water_elemental.duration )
            applyBuff( "water_elemental" )

        end,

    }
} )

spec:RegisterStateExpr( "is_fs_down", function() return fs_down end )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 1459,

    nameplates = true,
    nameplateRange = 15,

    damage = true,
    damageExpiration = 6,

    potion = "potion_of_speed",

    -- package = "",
    -- package1 = "",
    -- package2 = "",
    -- package3 = "",
} )

spec:RegisterSetting( "minimum_combustion", 150, {
    type = "range",
    name = strformat( "Targeted Minimum Combustion Amount: ", Hekili:GetSpellLinkWithTexture( spec.abilities.combustion.id ) ),
    desc = strformat( "Set a minimum amount for a combustion",
        Hekili:GetSpellLinkWithTexture( spec.abilities.combustion.id ) ),
    width = "full",
    min = 0,
    max = 1000,
    step = 10
} )

spec:RegisterStateExpr( "minimum_combustion", function()
    return settings.minimum_combustion * 1000 or 140000
end )

spec:RegisterSetting( "cooldown_combustion_increase", 50, {
    type = "range",
    name = strformat( "Lust Combust Increase: ", Hekili:GetSpellLinkWithTexture( spec.abilities.combustion.id ) ),
    desc = strformat( "Percent increase during Bloodlust",
        Hekili:GetSpellLinkWithTexture( spec.abilities.combustion.id ) ),
    width = "full",
    min = 0,
    max = 100,
    step = 5
} )

spec:RegisterStateExpr( "cooldown_combustion_increase", function()
    return settings.cooldown_combustion_increase or 50
end )

spec:RegisterStateExpr( "combustion_with_cooldowns", function()
    return (settings.minimum_combustion * 1000) * (1+settings.cooldown_combustion_increase / 100)
end )


spec:RegisterSetting( "use_cold_snap", false, {
    type = "toggle",
    name = strformat( "%s %s", USE, Hekili:GetSpellLinkWithTexture( spec.abilities.cold_snap.id ) ),
    desc = strformat( "If enabled, the default Frost priority %s may recommend to reset the cooldown of %s.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.cold_snap.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.icy_veins.id ) ),
} )

spec:RegisterStateExpr( "use_cold_snap", function()
    return settings.use_cold_snap
end )


spec:RegisterPackSelector( "arcane", "Arcane Experimental WoW Sims", "|T135932:0|t Arcane",
    "If you have spent more points in |W|T135932:0|t Arcane|w than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )

spec:RegisterPackSelector( "fire", "Fire Experimental", "|T135810:0|t Fire",
    "If you have spent more points in |W|T135810:0|t Fire|w than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

spec:RegisterPackSelector( "frost", "Frost Wowhead", "|T135846:0|t Frost",
    "If you have spent more points in |W|T135846:0|t Frost|w than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )

-- spec:RegisterPack( "Arcane Wowhead", 20230924, [[Hekili:9EvBVTTnq4FlffWjfRw2X5TLIMc01bSLGTGH5o09jjrjF2MiuKAKu2nfb63(UJ6Lqjl7g0c0Vyjt(W7nE39Ck8KWpgoFbZcH3nB6StNE1SZdMoD6StonCU9HCiCEol9E2k8fjld)996uMekJ)KA7AGTG2)bHcFbLJrvOtrmRT2CZBMmz72TbBRWfKQYMSvzf3pzvbFbmjvWmgWmjdL9eMtOtwKBgRvwMLRKJtvkXc1wPzmlHl4woygNVbLEsbxyVrgMmSHplCoRWUwPdN)7W94jr7HVybuDaWKgoNoW4PxnE2zVPm(gjkBMOm2QzsJWP8Y4LAvwRtgeoxWnwd5JmfGpUZf3ajlralc)LW5PAUf0Cgg1y6vGnyl3UMlpzkEIusK4tNtgbFoxOm0kw00DISgqUgmGmfIulJY4Yf(kaXEQp2eb)lFHP7J5mFmlf4nMXQ53dDHzPaXswHW26knNjvvirhXKdcrpz3XwDamwG1hvhRudzQnquAH2adzP7jakaPnGlXWfzkrSeJsNtsmO(aLXJkJtkwUCyuuAJdsLDeSsOsyIi7AqNHpnS8CqhLUMUPc04f8dEbnUgI2srw0ip)hHr6G0Q2GI8NmMdz4K9DrN0hv1ZoH5l9ruNbMR2c6E4(zFC80hI2aCPPhOR8bLX1ALoIN5Ao0bhM13nUrLDAEE1b)hd2(GjFGQ44Y7bRbFBnZIlQb5r4tf5WB5eomplLVKdunyJMlmqeEpKzC6A)vIeEm7dKqg28Om(DLXZ8Y0zcru1FIOQ7QA8OQUCuvoj8z7v4la39wDinb7MzdmwSxzz81LXN5UzpU(YnJBmCbIIP1y0cVIlJF8XYySGFt0Q0fbx0roLXVAN7SAru5YN(DzvdAsTzJyblxUAh9xJZP(ZgiNYPQ(Pb7V8jJjzb5POR(2Y4lN63XihlS4M1reeNuU45jf)wTWgvQRrEvZomoJ0pjm7qDU77iAUqWzsIhRtA7CihZ5sanMfH8h(2HMX9Q23rqUGBBh0b9Kxug)CeYo7ZX2kcbKAR0rFNPD7D6mtvTrmDMs3NAaJxBWwveQgMv0zXwtsmVa7i8P3)33DZD)gYCwg)X1yjkplxPX7GLkm0CunXYrOdb)xb2vdDkJkJk5lSQmKWgxa7GjxbMGYB)donmbXd)bLe1RB7JQ7U(VOuSkV)30Afx)4t(8RAp)5FZNV82BCMpDStBimkJD0942uUJAjwOeo)LLX)jg0qnvpc0T4k(t6GDnh76A(0SoJDt5WtRhWzmf1htt5GdYCWjDCcVxghzSVex(VAYMlVTYCnbTj4)01t2jZ518LxtjxJouI1HevBwejPx81e1O9NFoSwEkvSXd)1QCOw4ii)5s8x)P5q8x1FUJkr(HMySpSwsxYXoaJ(OdZIp6zpMHVYpe6Vt7zNjk81B1yc(R4pwG)6TJb4VOpTVll9BKo3xMTe6DUX7Xp)AIz(AKyMcoDP2F3SbCNggtc(EPfV(SrhVhk6hFCp0ZVAaLvFSVMU2l17OkA3HKSBIGo52(mKKgBObF7Lt9b2sc2bZjtPQSM6qmC(KQA)YKQ0VoFgt)J0)Bv6VFZ3N0F9oFtcLnqJEsKoH))]] )
--spec:RegisterPack( "Fire WoW Sims", 20240617, [[Hekili:1w1YUTnmqWVLCj3QHKQDEaK6d9qr6fFHbi3Oef1kBwZhcKujnx43Exs5hQjk2nbOWWcuCjNDMLRgsZPpqjnmpqxvKvmp7QSBNvKNFBXvuI)LoGs6y8TS14antHp)HWcHQhnpgQicLlg)fPH1eXXz6TCCnusDVq6)PMw)AWXf1bC6QBOKnIMgyyjGJtjpSr4cvX)Sq1USgQmT47CVWOdvsHZJHBn2q19WwHumJsstMub0Y6LEC4Q89p8ucOz1sOH(DkzahkXcDsqlCBkvmnJs4wHhScCu89zk2VdvFjuLEH3BTG2hQwgQYlwKLHyUQ404RmspOlzwLX(g074(LZxCzDFBlMP1WWYM13fb(RNg4AW6a7wHE9yyJBC(P3i3OQ7D7gFyJEHcRW39nuzxhQUel(R1ySYgMkv7xIrUgLCkwdKO8Wsq6oEsP4jKtL1ywEvKUxSMAjZ53pFA2J6yNUxmn9)yufz6NIQVLstoTfumHg7)UluvmBXKfxukx95pjw()qDtCqeP51FEAI6pFX7rZ5F8(LiDU500PfDDkt0FmDgsGc9k8VkbhP)(arKEckbnOeGBOwht8TNRZlH3gJV05TaBl2gGqDKzhQRrWYZoTmgP7XP4IjklEbp9DEe1ZyN1krN5sJ9VWKBmYgZZ6XLIdDWO4t(y5NZi7G)0yOBfR34lpcgEQxmCMV3GBOhzifJT0uMOaPRY2NTYDZ89PSjhoKYE3gIAMuMsXzm)CCJLVjTY3XNzI2S4psNfILp2Hlv(iU9xSBR)d3xiSwJTuOs3ZojcN5IbUr)REK7Xsx5Aqnnkjn9e6Of3ZORKFMz14PGlEZnR3VjQJ7zYgSvxzs7I(Nd]] )
-- spec:RegisterPack( "Frost Wowhead", 20230930, [[Hekili:fJ1FpsTnq0plOkT3Du2S)4G7a0DivkQTGApv1qf9VsI3Kj76Eo2bBNBzpDkF27yNnjoztwOuHQqcYAp(nppEM5ztWIG3h4Nq0qWnlNV885V485ElE6Y5p95b(6D5qGFoj(wYA8dojd)7Fsku6YOpi2UbijMP3Xe4himkrHmgnzJwNRE5SzB3U1BBLDEXISzBfA2TZwxqtGzXmIsbQzzi0Zsnyoljxnvk0envWNgleSeXwUAkzfLr1uqnn)oe8vfuM(T8Gvdt7lrAKdXb3G8FdnjbQSeuXb()g6RxwgvTdENllPX7MEhq5QwEo1YqACf5MA45uddrsCuww(oFixdzRazzKHByisksPmK7FxzuxoGd8nJgi29ys57WrXH)DjG4VIGeGeBaq5Lxp03F9mImMWHWvskJrj8y4j00RLeAYKvfPPEhmTNX1hfkkxdmgeRni9OphuDMRzPhXlXc(FxiHWmcNeUgYmEP(7W4ne5AqD1YHxBMGPbEirMjKM1z9DbN(XcOAWJ4xvrwMGhUftdLHadYaUMWS7XCq7zwYDWK1SD5B8a0goHvzShWjRyqYWWMkIlu4Mznn2G1APOiFsfyHjcTNZ8xpFyiY3jfRWehBaFLqPQp6FdKskyTh82OxbgJLyvdJ5oUDaLgWDeJINeXjx3ouyDkxfS)yDcOlazuPuidPMC2oapEy7ljwHiG1jH26e3b3NWKl2I57oJNYW(wHXKC3bZfMVEsHccfPPHRXn3IUbfwsOItYn0YyvZavzNnmOkJToA4mUeYi4)(QlMBlf)tfugr47kJ0sk)wqRWV2GLGrejWpb)xHEdi3sn2z6GrtPqINlNm0GI1ZQwaFda5MMjaCp(lTOmcRfW4l(JDyZ4YitoaAaLVgpHrFKw36jQQUa9fndtiWiNOqXq6TLQ3GKAVDRWYdCzY9)mLkXL8ACWomlbPryQLfM41PjGniHTSUh4Ef5p8q1VRObgXdTDZ8uAuB56fNn50kS8sRDsOXXEuEykJUEJ(HhCnO7CN15WUE(MA5dCkwmHPByoNNdTBpbDgS(m8QymkgQPzWJpY(4aA0SpA4YkS1hVfC0E3fTIrV)EImXy((YDGdzyZ8xTCYJYe3HUTBok3K9AtnhCnAZjS2ZCIs5lMp5qi2xZaFkNjuMcIVoyQ2P19BQMV7YwoVZofW4PTd9NRo0mrtB9owv3K3lpwF1LDGhUteBfg7yZ5ZhmrjW)o8SehT9Meb(BjsoUhub(F4h(JBE7n)mkzxg9(nyYpnlxiXAIutrXjjv9tpPmscFSaddjyfLWu)rk0ImSbwITudtyuyjZVInslJwS8LMwMC0X25pzF(4FDsvnCZVR79HJF6IpDMNPl(BT(3SSLOtS7hSmNQ0g8d8r3Urid8)f4w8Mab(2zS3XRIP4N3yVZx1sd8DB)h4V3HbVoqJXdJDTJ0SKwzad(wPb3bB0gmyCURVCve65RN2ZxXsSvNKsc8Fuz0rKfCy1GYkgSFMlhA6q3Jax4AKRwsp7U01UgTLEg9CJroPRMyEZIQY57TIxm6(VJ6tz0KYObuGSJpUkuz0RkJUyU7P(Ean(EX8Eo3CDzjnVY0VsLRwF1OBz91IrsQC67oeb(FuPZ9W40YO(IBLrp8W(ZKregIUgR5lJoZEiDADv7OIDvaoUGhIKns2V8SLLJj8zjWHIFnxXQts0acHLrxHgulgwg94JUVDktAA2A495hN3hks2dOMqMfTXBC0viZwcS0UfXokvAuTaxR9AH8z)7HSNgPDS((WvV26Nl(24N(I6wFD5O(AVC(bOV0PDrRaVfSJ2ERV4EVgDlgVtxTuTnn7sh3lHCmNLQ2yX9axBKQ63cBeup3b1MRjybOJOOZTdCjV28w(9VYQriDGEzh8U2ED0o4)HGw2AECCBt(HFG8qAZD0l)sa5G57(s7d2mnt3OQpA029D32O(YofbDER(X1(h(14oxOW517nk9JfvAFtUDV)F8sfJx8AFWU1f7lJ79ODREGBXv7unxWy4Ob(qENRru)g)G2)e8pd]] )
spec:RegisterPack( "Fire Experimental", 20240726, [[Hekili:1E1oVnooq4FlPXfBHGLCESbiRloG7qUM0OTMuus0wCdFiqsLe3OF73qs5yAh9i7ICf2qIC484Bg(nJqPOFIYRjwk6PS1zxV(USBts3S5(nOC7HwkkVLu9mzp8GKiG))hMM2x83V1s1mbvAjCNih4ksTttgvNUcedLx2X42)vIkpt93MEpiulTc903r5nS6AAqeQPcL)ZgMPVW9J0xmy4(c1o49kltj7l4mJf2ENs3x8i9zgNLGY9l6TEJsBX1DAItAmrrHvFYhIujPKtRr)fkpOlu(ooeryLUezbV7OK2rLTKtmw8RKxOoH3mVW1AYEL0Gl1uITXDGRN)aEpXy1SN9Q)MfKgsbyVdHYR0mlKjio8E3UeMaqnBsxBFXQ(IAAyX9sqiyrqFwhuVJ0XThTXmgYCqsAnuSPvZK7nXwZcj)(IT9f39japnTLtLmtdwqKKy14EpPTY2x8qFX9R9EDLsusS(hF3kz3mfSxEYmcf3sHSUwO0JzKTz3SYPrSvHRz0TPRxDLhGIpyaMMkHDsPTAAnRYsRXo)TZekp3gC)WR4xz2gyBfVw9QeQA)geij34JSgIbx1OW7jCooKNofiNuXNOAGZEbso4s4mX(3igyaDdUtYjJCSC5QH6LinoGg3oVliGRPWDdD9coGtv3TeWolY0EqRcv(whbYSEvekE51KsUsvZHnpg6)HzZ0HSzOo9HFaR4VpC)sb5xNxeFlbm(e1qPR)cWkNfN3pfmjt0jIw(BtbrPlW98)Mh9biZ5mlqGDQtrKV428fkMkPcgfYeBHyBJxBl0EiQxYNsDl084IUnXK0e9EQnXvYWKPb21PnZFuxNbkJZitwDUn2M6v)eCixKBBuwm0iKsEob(RYoXv)0jOrgNu8qfhi99GHXDkGW6n85RMpsqfZd6Q0ogx1kB8EpeGVjyJgTbneIDYP6sptAASKHZ2tW38Phyym)5J9h(GpbxFCMpBbYLrV9C1LnIgA1KTaVGVxZhAXVJTVXI1ubHjhqRSq9(ztya0GotmXT9WJyHYLAVe)kH2rJp5YwVEZho2tbtSafGPsPR8tgMT0OHNLPZIVK(crJddLh1FOHYHrZJ90OnnuR1nj3GujC1RWyNhjhFF6RjKUba5FdXb(nTlznisygFnRDG1s1xivGscX8PagIkMFf)WQaXEyEq0YJRwPK)QdqlxQbVNkUOCZRLHHv)DgFm6OlKvfmTwPXmH)7LgvdlKTprYn6X9qcaRgNWrFqfm7LmmHoOQoBJlaEKWRbkuHYFk0)9]] )
spec:RegisterPack( "Arcane Experimental WoW Sims", 20240622, [[Hekili:Ds1xVTniq8pl7L9ONTttAJ02K2KMu3l5fQuFdZz7ZnOGbla3SkvXN9DqtAsAtYYAKcg7d(9N7GJxWVJZAbpYxuMxEv(SYRZYlNKNpLZ8pnGC2a0ScEGMOHEA8h2gqJbXV(ZaAL9O2dQG4EZ9bbt27IR)jLbAJ46mJ2gApCw9Ou5)TMx)gYkPfnGn8f3WzlLTT4llbDnC2DlLUGi(hcInQiimD07nEPrhekPZtH7m2G4wCLujZ4S0htUc7GrLNMUOy7GNZqnuRWw(p5SxWHEM8u1GznA5SgR0twdIiup21LTjCTcC(mNNusq89Gysqeep)Cq4P0qL3u1kj991GOmN4zr555SgTo0UsQFyFg3NVKCYghcIphePa1kJPvnsQO1SwFoYNetahHvloOqT0TSQh0WfXCCHzdn(e6ZNgr)QZBn8rtd8Y0D4)PtsWboGYRLtFpVtsUA6fvgt1P)L1IWn7JbxsynJwlD2pi(cjo6xs5h4KdSafSizHRpoN7qVXyuXQB2RzXml2dsTlLikMEcb6J3H(4(zRkNNu58ZJuNIAfuzS17dtCFKhVej0lDoPcDNQiTn(M6uXLD9TgS2uJQ)JlWhEo7BbXnPd4f7F5945VD6iM7zdwSX0xdV2U5ycTNKxfy7n2358DHoOCpz2L0l5nhesc6rQ)sm4EDAxdwn1VXfBidJ(LrzClOATi0Bs7I)3d]])