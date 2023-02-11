if UnitClassBase( 'player' ) ~= 'MAGE' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 8 )

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Increases magic damage taken by up to $s1 and healing by up to $s2.
    amplify_magic = {
        id = 1008,
        duration = 600,
        max_stack = 1,
        copy = { 1008, 8455, 10169, 10170, 27130, 33946, 43017 },
    },
    -- Arcane spell damage increased by $s1% and mana cost of Arcane Blast increased by $s2%.
    arcane_blast = {
        id = 36032,
        duration = 6,
        max_stack = 4,
    },
    -- Increases Intellect by $s1.
    arcane_brilliance = {
        id = 23028,
        duration = 3600,
        max_stack = 1,
        copy = { 23028, 27127, 43002 },
    },
    -- Increases Intellect by $s1.
    arcane_intellect = {
        id = 1459,
        duration = 1800,
        max_stack = 1,
        copy = { 1459, 1460, 1461, 10156, 10157, 16876, 27126, 39235, 42995 },
    },
    arcane_mind = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=12503)
        id = 12503,
        duration = 3600,
        max_stack = 1,
        copy = { 12503, 12502, 12501, 12500, 11232 },
    },
    arcane_missiles = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=5143)
        id = 5143,
        duration = 3,
        max_stack = 1,
    },
    -- Increased damage and mana cost for your spells.
    arcane_power = {
        id = 12042,
        duration = function() return glyph.arcane_power.enabled and 18 or 15 end,
        max_stack = 1,
    },
    arctic_winds = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=31678)
        id = 31678,
        duration = 3600,
        max_stack = 1,
        copy = { 31678, 31677, 31676, 31675, 31674 },
    },
    -- Dazed.
    blast_wave = {
        id = 11113,
        duration = 6,
        max_stack = 1,
        copy = { 11113, 13018, 13019, 13020, 13021, 27133, 33933, 42944, 42945 },
    },
    blazing_speed = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=31642)
        id = 31642,
        duration = 3600,
        max_stack = 1,
        copy = { 31642, 31641 },
    },
    -- Blinking.
    blink = {
        id = 1953,
        duration = 1,
        max_stack = 1,
    },
    -- $42208s1 Frost damage every $42208t1 $lsecond:seconds;.
    blizzard = {
        id = 10,
        duration = 8,
        max_stack = 1,
        copy = { 10, 6141, 8427, 10185, 10186, 10187, 27085, 27618, 42939, 42940 },
    },
    -- Immune to Interrupt and Silence mechanics.
    burning_determination = {
        id = 54748,
        duration = 20,
        max_stack = 1,
    },
    -- Movement slowed by $s1% and time between attacks increased by $s2%.
    chilled = {
        id = 7321,
        duration = 5,
        max_stack = 1,
        copy = { 6136, 7321, 12484, 12485, 12486, 18101, 50459 },
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
        copy = { 28682, 11129 },
    },
    -- Movement slowed by $s1%.
    cone_of_cold = {
        id = 120,
        duration = 8,
        max_stack = 1,
        copy = { 120, 8492, 10159, 10160, 10161, 27087, 42930, 42931, 65023 },
    },
    counterspell = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=2139)
        id = 2139,
        duration = 8,
        max_stack = 1,
    },
    critical_mass = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=11368)
        id = 11368,
        duration = 3600,
        max_stack = 1,
        copy = { 11368, 11367, 11115 },
    },
    -- Glyph.
    curse_immunity = {
        id = 60803,
        duration = 4,
        max_stack = 1,
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
        tick_time = 2,
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
        max_stack = 1,
    },
    -- Absorbs Fire damage.
    fire_ward = {
        id = 543,
        duration = 30,
        max_stack = 1,
        copy = { 543, 8457, 8458, 10223, 10225, 27128, 43010 },
    },
    -- Your next Fireball or Frostfire Bolt spell is instant and costs no mana.
    fireball = {
        id = 57761,
        duration = 15,
        max_stack = 1,
        copy = { 57761, 133 },
    },
    -- Your next Flamestrike spell is instant cast and costs no mana.
    firestarter = {
        id = 54741,
        duration = 10,
        max_stack = 1,
    },
    -- $s2 Fire damage every $t2 seconds.
    flamestrike = {
        id = 2120,
        duration = 8,
        max_stack = 1,
        copy = { 2120, 2121, 8422, 8423, 10215, 10216, 27086, 42925, 42926, 72169 },
    },
    -- Chance to critically hit with spells increased by $s1%.  When a critical hit occurs, the caster's chance to critically hit is increased.
    focus_magic = {
        id = 54646,
        duration = 1800,
        max_stack = 1,
    },
    -- Increases Armor by $s1 and may slow attackers.
    frost_armor = {
        id = 168,
        duration = function() return glyph.frost_ward.enabled and 3600 or 1800 end,
        max_stack = 1,
        copy = { 168, 7300, 7301 },
    },
    -- Frozen in place.
    frost_nova = {
        id = 122,
        duration = 8,
        max_stack = 1,
        copy = { 122, 865, 6131, 9915, 10230, 27088, 42917 },
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
        duration = 5,
        max_stack = 1,
        copy = { 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304, 27071, 27072, 38697, 42841, 42842 },
    },
    -- Movement slowed by $s1%.  $s3 Frostfire damage every $t3 sec.
    frostfire_bolt = {
        id = 44614,
        duration = 9,
        max_stack = 1,
        copy = { 44614, 47610 },
    },
    -- Increases Armor by $s1, Frost resistance by $s3 and may slow attackers.
    ice_armor = {
        id = 7302,
        duration = function() return glyph.frost_ward.enabled and 3600 or 1800 end,
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
    -- Next Fire Blast stuns the target for $12355d.
    impact = {
        id = 64343,
        duration = 10,
        max_stack = 1,
        copy = { 12355, 64343 },
    },
    -- Chance to be hit by all attacks and spells reduced by $s1%.
    improved_blink = {
        id = 47000,
        duration = 4,
        max_stack = 1,
        copy = { 47000, 46989 },
    },
    improved_blizzard = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=12488)
        id = 12488,
        duration = 3600,
        max_stack = 1,
        copy = { 12488, 12487, 11185 },
    },
    improved_fireball = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=12341)
        id = 12341,
        duration = 3600,
        max_stack = 1,
        copy = { 12341, 12340, 12339, 12338 },
    },
    improved_frostbolt = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=16766)
        id = 16766,
        duration = 3600,
        max_stack = 1,
        copy = { 16766, 16765, 16763, 12473 },
    },
    -- Spells have a $s1% additional chance to critically hit.
    improved_scorch = {
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
    initialize_images = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=58836)
        id = 58836,
        duration = 30,
        max_stack = 1,
    },
    invisibiilty = {
        id = 32612,
        duration = function() return glyph.invisibility.enabled and 30 or 20 end,
        max_stack = 1,
    },
    -- Fading.
    invisibility_fading = {
        id = 66,
        duration = 3,
        tick_time = 1,
        max_stack = 1,
    },
    -- Causes $s1 Fire damage every $t1 sec.  After $d or when the spell is dispelled, the target explodes causing $44461s1 Fire damage to all enemies within $44461a1 yards.
    living_bomb = {
        id = 44457,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
        copy = { 44457, 55359, 55360 },
    },
    -- Resistance to all magic schools increased by $s1 and allows $s2% of your mana regeneration to continue while casting.
    mage_armor = {
        id = 6117,
        duration = 1800,
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
    mirror_image = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=58834)
        id = 58834,
        duration = 30,
        max_stack = 1,
        copy = { 58834, 58833, 58831, 55342 },
    },
    -- Reduces the channeled duration of your next Arcane Missiles spell by $/1000;S1 secs, reduces the mana cost by $s3%, and the missiles fire every .5 secs.
    missile_barrage = {
        id = 44401,
        duration = 15,
        max_stack = 1,
    },
    -- Causes $34913s1 Fire damage to attackers.  Chance to receive a critical hit reduced by $s2%.  Critical strike rating increased by $s3% of Spirit.
    molten_armor = {
        id = 30482,
        duration = 1800,
        max_stack = 1,
        copy = { 30482, 43045, 43046 },
    },
    playing_with_fire = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=31640)
        id = 31640,
        duration = 3600,
        max_stack = 1,
        copy = { 31640, 31639, 31638 },
    },
    -- Cannot attack or cast spells.  Increased regeneration.
    polymorph = {
        id = 118,
        duration = 20,
        max_stack = 1,
        copy = { 118, 12824, 12825, 12826 },
    },
    portal_orgrimmar = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=11417)
        id = 11417,
        duration = 60,
        max_stack = 1,
    },
    portal_shattrath = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=35717)
        id = 35717,
        duration = 60,
        max_stack = 1,
    },
    portal_thunder_bluff = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=11420)
        id = 11420,
        duration = 60,
        max_stack = 1,
    },
    portal_undercity = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=11418)
        id = 11418,
        duration = 60,
        max_stack = 1,
    },
    -- Your next Mage spell with a casting time less than 10 sec will be an instant cast spell.
    presence_of_mind = {
        id = 12043,
        duration = 3600,
        max_stack = 1,
    },
    -- $s2 Fire damage every $t2 seconds.
    pyroblast = {
        id = 11366,
        duration = 12,
        max_stack = 1,
        copy = { 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809, 27132, 33938, 42890, 42891 },
    },
    -- Replenishes $s1% of maximum mana per 5 sec.
    replenishment = {
        id = 57669,
        duration = 15,
        tick_time = 1,
        max_stack = 1,
    },
    ritual_of_refreshment = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=43987)
        id = 43987,
        duration = 60,
        max_stack = 1,
    },
    -- Silenced.
    silenced_improved_counterspell = {
        id = 55021,
        duration = 4,
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
    -- Spells have a $s1% additional chance to critically hit.
    winters_chill = {
        id = 12579,
        duration = 15,
        max_stack = 5,
    },
} )


-- Glyphs
spec:RegisterGlyphs( {
    [63092] = "arcane_barrage",
    [62210] = "arcane_blast",
    [56360] = "arcane_explosion",
    [57924] = "arcane_intellect",
    [56363] = "arcane_missiles",
    [56381] = "arcane_power",
    [62126] = "blast_wave",
    [56365] = "blink",
    [63090] = "deep_freeze",
    [58070] = "drain_soul",
    [70937] = "eternal_water",
    [56380] = "evocation",
    [56369] = "fire_blast",
    [57926] = "fire_ward",
    [56368] = "fireball",
    [57928] = "frost_armor",
    [56376] = "frost_nova",
    [57927] = "frost_ward",
    [56370] = "frostbolt",
    [61205] = "frostfire",
    [56384] = "ice_armor",
    [63095] = "ice_barrier",
    [56372] = "ice_block",
    [56377] = "ice_lance",
    [56374] = "icy_veins",
    [56366] = "invisibility",
    [63091] = "living_bomb",
    [56383] = "mage_armor",
    [56367] = "mana_gem",
    [63093] = "mirror_image",
    [56382] = "molten_armor",
    [56375] = "polymorph",
    [56364] = "remove_curse",
    [56371] = "scorch",
    [57925] = "slow_fall",
    [56373] = "water_elemental",
} )


-- Abilities
spec:RegisterAbilities( {
    -- Amplifies magic used against the targeted party member, increasing damage taken from spells by up to 15 and healing spells by up to 16.  Lasts 10 min.
    amplify_magic = {
        id = 1008,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.27,
        spendType = "mana",

        startsCombat = true,
        texture = 135907,

        handler = function ()
        end,

        copy = { 8455, 10169, 10170, 27130, 33946, 43017 },
    },


    -- Launches several missiles at the enemy target, causing 401 to 485 Arcane damage.
    arcane_barrage = {
        id = 44425,
        cast = 0,
        cooldown = 3,
        gcd = "spell",

        spend = function() return 0.18 * ( glyph.arcane_barrage.enabled and 0.8 or 1 ) end,
        spendType = "mana",

        talent = "arcane_barrage",
        startsCombat = true,
        texture = 236205,

        handler = function ()
        end,
    },


    -- Blasts the target with energy, dealing 862 to 998 Arcane damage.  Each time you cast Arcane Blast, the damage of all Arcane spells is increased by 15% and mana cost of Arcane Blast is increased by 175%.  Effect stacks up to 4 times and lasts 6 sec or until any Arcane damage spell except Arcane Blast is cast.
    arcane_blast = {
        id = 30451,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = true,
        texture = 135735,

        handler = function ()
        end,

        copy = { 42894, 42896, 42897 },
    },


    -- Infuses all  party and raid members with brilliance, increasing their Intellect by 31 for 1 |4hour:hrs;.
    arcane_brilliance = {
        id = 23028,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.81 * ( glyph.arcane_intellect.enabled and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135869,

        handler = function ()
        end,

        copy = { 27127, 43002 },
    },


    -- Causes an explosion of arcane magic around the caster, causing 34 to 38 Arcane damage to all targets within 10 yards.
    arcane_explosion = {
        id = 1449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.22 * ( glyph.arcane_explosion.enabled and 0.9 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 136116,

        handler = function ()
        end,

        copy = { 8437, 8438, 8439, 10201, 10202, 27080, 27082, 42920, 42921 },
    },


    -- Increases the target's Intellect by 2 for 30 min.
    arcane_intellect = {
        id = 1459,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.31 * ( glyph.arcane_intellect.enabled and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 135932,

        handler = function ()
        end,

        copy = { 1460, 1461, 10156, 10157, 27126, 42995 },
    },


    -- Launches Arcane Missiles at the enemy, causing 25 Arcane damage every 1 sec for 3 sec.
    arcane_missiles = {
        id = 5143,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.31,
        spendType = "mana",

        startsCombat = true,
        texture = 136096,

        handler = function ()
        end,

        copy = { 5144, 5145, 8416, 8417, 10211, 10212, 25345, 27075, 38699, 38704, 42843, 42846 },
    },


    -- When activated, your spells deal 20% more damage while costing 20% more mana to cast.  This effect lasts 15 sec.
    arcane_power = {
        id = 12042,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "arcane_power",
        startsCombat = true,
        texture = 136048,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- A wave of flame radiates outward from the caster, damaging all enemies caught within the blast for 160 to 192 Fire damage, knocking them back and dazing them for 6 sec.
    blast_wave = {
        id = 11113,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = function() return 0.07 * ( glyph.blast_wave.enabled and 0.85 or 1 ) end,
        spendType = "mana",

        talent = "blast_wave",
        startsCombat = true,
        texture = 135903,

        handler = function ()
        end,
    },


    -- Teleports the caster 20 yards forward, unless something is in the way.  Also frees the caster from stuns and bonds.
    blink = {
        id = 1953,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.21,
        spendType = "mana",

        startsCombat = true,
        texture = 135736,

        handler = function ()
        end,
    },


    -- Ice shards pelt the target area doing 292 Frost damage over 8 sec.
    blizzard = {
        id = 10,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.74,
        spendType = "mana",

        startsCombat = true,
        texture = 135857,

        handler = function ()
        end,

        copy = { 6141, 8427, 10185, 10186, 10187, 27085, 42939, 42940 },
    },


    -- When activated, this spell finishes the cooldown on all Frost spells you recently cast.
    cold_snap = {
        id = 11958,
        cast = 0,
        cooldown = 480,
        gcd = "off",

        talent = "cold_snap",
        startsCombat = true,
        texture = 135865,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- When activated, this spell increases your critical strike damage bonus with Fire damage spells by 50%, and causes each of your Fire damage spell hits to increase your critical strike chance with Fire damage spells by 10%.  This effect lasts until you have caused 3 non-periodic critical strikes with Fire spells.
    combustion = {
        id = 11129,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "combustion",
        startsCombat = true,
        texture = 135824,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Targets in a cone in front of the caster take 102 to 112 Frost damage and are slowed by 50% for 8 sec.
    cone_of_cold = {
        id = 120,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 0.25,
        spendType = "mana",

        startsCombat = true,
        texture = 135852,

        handler = function ()
        end,

        copy = { 8492, 10159, 10160, 10161, 27087, 42930, 42931 },
    },


    -- Conjures 20 muffins, providing the mage and her allies with something to eat.    Conjured items disappear if logged out for more than 15 minutes.
    conjure_food = {
        id = 587,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.4,
        spendType = "mana",

        startsCombat = true,
        texture = 133952,

        handler = function ()
        end,

        copy = { 597, 990, 6129, 10144, 10145, 28612, 33717 },
    },


    -- Conjures a mana agate that can be used to instantly restore 390 to 410 mana.
    conjure_mana_gem = {
        id = 759,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.75,
        spendType = "mana",

        startsCombat = true,
        texture = 134104,

        handler = function ()
        end,

        copy = { 3552, 10053, 10054, 27101, 42985 },
    },


    -- Conjures 20 Mana Pies providing the mage and her allies with something to eat.    Conjured items disappear if logged out for more than 15 minutes.
    conjure_refreshment = {
        id = 42955,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.4,
        spendType = "mana",

        startsCombat = true,
        texture = 236212,

        handler = function ()
        end,

        copy = { 42956 },
    },


    -- Conjures 20 bottles of water, providing the mage and her allies with something to drink.    Conjured items disappear if logged out for more than 15 minutes.
    conjure_water = {
        id = 5504,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.4,
        spendType = "mana",

        startsCombat = true,
        texture = 132793,

        handler = function ()
        end,

        copy = { 5505, 5506, 6127, 10138, 10139, 10140, 37420, 27090 },
    },


    -- Counters the enemy's spellcast, preventing any spell from that school of magic from being cast for 8 sec.  Generates a high amount of threat.
    counterspell = {
        id = 2139,
        cast = 0,
        cooldown = 24,
        gcd = "off",

        spend = 0.09,
        spendType = "mana",

        startsCombat = true,
        texture = 135856,

        handler = function ()
        end,
    },


    -- Dampens magic used against the targeted party member, decreasing damage taken from spells by up to 10 and healing spells by up to 11.  Lasts 10 min.
    dampen_magic = {
        id = 604,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.27,
        spendType = "mana",

        startsCombat = true,
        texture = 136006,

        handler = function ()
        end,

        copy = { 8450, 8451, 10173, 10174, 33944, 43015 },
    },


    -- Stuns the target for 5 sec.  Only usable on Frozen targets.  Deals 2369 to 2641 damage to targets permanently immune to stuns.
    deep_freeze = {
        id = 44572,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        talent = "deep_freeze",
        startsCombat = true,
        texture = 236214,

        handler = function ()
        end,
    },


    -- Targets in a cone in front of the caster take 382 to 442 Fire damage and are Disoriented for 5 sec.  Any direct damaging attack will revive targets.  Turns off your attack when used.
    dragons_breath = {
        id = 31661,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        talent = "dragons_breath",
        startsCombat = true,
        texture = 134153,

        handler = function ()
        end,
    },


    -- While channeling this spell, you gain 60% of your total mana over 8 sec.
    evocation = {
        id = 12051,
        cast = 8,
        channeled = true,
        cooldown = 240,
        gcd = "spell",

        startsCombat = true,
        texture = 136075,

        toggle = "cooldowns",

        handler = function ()
            -- TODO: glyph.evocation.enabled makes the channel recover 60% of health as well.
        end,
    },


    -- Blasts the enemy for 27 to 35 Fire damage.
    fire_blast = {
        id = 2136,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.21,
        spendType = "mana",

        startsCombat = true,
        texture = 135807,

        handler = function ()
        end,

        copy = { 2137, 2138, 8412, 8413, 10197, 10199, 27078, 27079, 42872, 42873 },
    },


    -- Absorbs 165 Fire damage.  Lasts 30 sec.
    fire_ward = {
        id = 543,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        startsCombat = true,
        texture = 135806,

        handler = function ()
        end,

        copy = { 8457, 8458, 10223, 10225, 27128, 43010 },
    },


    -- Hurls a fiery ball that causes 16 to 25 Fire damage and an additional 2 Fire damage over 4 sec.
    fireball = {
        id = 133,
        cast = function() return glyph.fireball.enabled and 1.35 or 1.5 end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 135812,

        impact = function ()
            if not glyph.fireball.enabled then applyDebuff( "target", "fireball" ) end
        end,

        copy = { 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306, 27070, 38692, 42832, 42833 },
    },


    -- Calls down a pillar of fire, burning all enemies within the area for 55 to 71 Fire damage and an additional 48 Fire damage over 8 sec.
    flamestrike = {
        id = 2120,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.35,
        spendType = "mana",

        startsCombat = true,
        texture = 135826,

        handler = function ()
        end,

        copy = { 2121, 8422, 8423, 10215, 10216, 27086, 42925, 42926 },
    },


    -- Increases the target's chance to critically hit with spells by 3%.  When the target critically hits the caster's chance to critically hit with spells is increased by 3% for 10 sec.  Cannot be cast on self.
    focus_magic = {
        id = 54646,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "focus_magic",
        startsCombat = true,
        texture = 135754,

        handler = function ()
        end,
    },


    -- Increases Armor by 30.  If an enemy strikes the caster, they may have their movement slowed by 30% and the time between their attacks increased by 25% for 5 sec.  Only one type of Armor spell can be active on the Mage at any time.  Lasts 30 min.
    frost_armor = {
        id = 168,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.24,
        spendType = "mana",

        startsCombat = true,
        texture = 135843,

        handler = function ()
        end,

        copy = { 7300, 7301 },
    },


    -- Blasts enemies near the caster for 22 to 24 Frost damage and freezes them in place for up to 8 sec.  Damage caused may interrupt the effect.
    frost_nova = {
        id = 122,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = true,
        texture = 135848,

        handler = function ()
        end,

        copy = { 865, 6131, 10230, 27088, 42917 },
    },


    -- Absorbs 165 Frost damage.  Lasts 30 sec.
    frost_ward = {
        id = 6143,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.14,
        spendType = "mana",

        startsCombat = true,
        texture = 135850,

        handler = function ()
        end,

        copy = { 8461, 8462, 10177, 28609, 32796, 43012 },
    },


    -- Launches a bolt of frost at the enemy, causing 20 to 22 Frost damage and slowing movement speed by 40% for 5 sec.
    frostbolt = {
        id = 116,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 135846,

        handler = function ()
        end,

        copy = { 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304, 27071, 27072, 38697, 42841, 42842 },
    },


    -- Launches a bolt of frostfire at the enemy, causing 645 to 747 Frostfire damage, slowing movement speed by 40% and causing an additional 60 Frostfire damage over 9 sec. This spell will be checked against the lower of the target's Frost and Fire resists.
    frostfire_bolt = {
        id = 44614,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.14,
        spendType = "mana",

        startsCombat = true,
        texture = 236217,

        handler = function ()
        end,

        copy = { 47610 },
    },


    -- Increases Armor by 290 and Frost resistance by 6.   If an enemy strikes the caster, they may have their movement slowed by 30% and the time between their attacks increased by 25% for 5 sec.  Only one type of Armor spell can be active on the Mage at any time.  Lasts 30 min.
    ice_armor = {
        id = 7302,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.24,
        spendType = "mana",

        startsCombat = true,
        texture = 135843,

        handler = function ()
        end,

        copy = { 7320, 10219, 10220, 27124, 43008 },
    },


    -- Instantly shields you, absorbing 454 damage.  Lasts 1 min.  While the shield holds, spellcasting will not be delayed by damage.
    ice_barrier = {
        id = 11426,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.21,
        spendType = "mana",

        talent = "ice_barrier",
        startsCombat = true,
        texture = 135988,

        handler = function ()
        end,
    },


    -- You become encased in a block of ice, protecting you from all physical attacks and spells for 10 sec, but during that time you cannot attack, move or cast spells.  Also causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_block = {
        id = 45438,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        spend = 15,
        spendType = "mana",

        startsCombat = true,
        texture = 135841,

        toggle = "defensives",

        handler = function ()
            if glyph.ice_block.enabled then setCooldown( "frost_nova", 0 ) end
        end,
    },


    -- Deals 174 to 200 Frost damage to an enemy target.  Causes triple damage against Frozen targets.
    ice_lance = {
        id = 30455,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 135844,

        handler = function ()
        end,

        copy = { 42913 },
    },


    -- Hastens your spellcasting, increasing spell casting speed by 20% and reduces the pushback suffered from damaging attacks while casting by 100%.  Lasts 20 sec.
    icy_veins = {
        id = 12472,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        talent = "icy_veins",
        startsCombat = true,
        texture = 135838,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Fades the caster to invisibility over 3 sec, reducing threat each second.  The effect is cancelled if you perform any actions.  While invisible, you can only see other invisible targets and those who can see invisible.  Lasts 20 sec.
    invisibility = {
        id = 66,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        startsCombat = true,
        texture = 132220,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- The target becomes a Living Bomb, taking 612 Fire damage over 12 sec.  After 12 sec or when the spell is dispelled, the target explodes dealing 306 Fire damage to all enemies within 10 yards.
    living_bomb = {
        id = 44457,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        talent = "living_bomb",
        startsCombat = true,
        texture = 236220,

        handler = function ()
        end,
    },


    -- Increases your resistance to all magic by 5 and allows 50% of your mana regeneration to continue while casting.  Only one type of Armor spell can be active on the Mage at any time.  Lasts 30 min.
    mage_armor = {
        id = 6117,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.26,
        spendType = "mana",

        startsCombat = true,
        texture = 135991,

        handler = function ()
        end,

        copy = { 22782, 22783, 27125, 43023, 43024 },
    },


    -- Absorbs 120 damage, draining mana instead.  Drains 1.5 mana per damage absorbed.  Lasts 1 min.
    mana_shield = {
        id = 1463,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = true,
        texture = 136153,

        handler = function ()
        end,

        copy = { 8494, 8495, 10191, 10192, 10193, 27131, 43019, 43020 },
    },


    -- Creates 3 copies of the caster nearby, which cast spells and attack the mage's enemies.  Lasts 30 sec.
    mirror_image = {
        id = 55342,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 135994,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Causes 75 Fire damage when hit, increases your critical strike rating by 35% of your Spirit, and reduces the chance you are critically hit by 5%.  Only one type of Armor spell can be active on the Mage at any time.  Lasts 30 min.
    molten_armor = {
        id = 30482,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.28,
        spendType = "mana",

        startsCombat = true,
        texture = 132221,

        handler = function ()
        end,

        copy = { 43045, 43046 },
    },


    -- Transforms the enemy into a sheep, forcing it to wander around for up to 20 sec.  While wandering, the sheep cannot attack or cast spells but will regenerate very quickly.  Any damage will transform the target back into its normal form.  Only one target can be polymorphed at a time.  Only works on Beasts, Humanoids and Critters.
    polymorph = {
        id = 118,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = true,
        texture = 136071,

        handler = function ()
        end,

        copy = { 12824, 12825, 12826 },
    },


    -- Creates a portal, teleporting group members that use it to Orgrimmar.
    portal_orgrimmar = {
        id = 11417,
        cast = 10,
        cooldown = 60,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        startsCombat = true,
        texture = 135744,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Creates a portal, teleporting group members that use it to Shattrath.
    portal_shattrath = {
        id = 35717,
        cast = 10,
        cooldown = 60,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        startsCombat = true,
        texture = 135745,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Creates a portal, teleporting group members that use it to Thunder Bluff.
    portal_thunder_bluff = {
        id = 11420,
        cast = 10,
        cooldown = 60,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        startsCombat = true,
        texture = 135750,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Creates a portal, teleporting group members that use it to Undercity.
    portal_undercity = {
        id = 11418,
        cast = 10,
        cooldown = 60,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        startsCombat = true,
        texture = 135751,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- When activated, your next Mage spell with a casting time less than 10 sec becomes an instant cast spell.
    presence_of_mind = {
        id = 12043,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "presence_of_mind",
        startsCombat = true,
        texture = 136031,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Hurls an immense fiery boulder that causes 148 to 195 Fire damage and an additional 56 Fire damage over 12 sec.
    pyroblast = {
        id = 11366,
        cast = 5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        talent = "pyroblast",
        startsCombat = true,
        texture = 135808,

        handler = function ()
        end,
    },


    -- Removes 1 Curse from a friendly target.
    remove_curse = {
        id = 475,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 136082,

        handler = function ()
            if glyph.remove_curse.enabled then applyBuff( "curse_immunity" ) end
        end,
    },


    -- Begins a ritual that creates a refreshment table.  Raid members can click the table to acquire Conjured Mana Biscuits.  The tables lasts for 3 min or 50 charges.  Requires the caster and 2 additional party members to complete the ritual.  In order to participate, all players must right-click the refreshment portal and not move until the ritual is complete.
    ritual_of_refreshment = {
        id = 43987,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        spend = 0.8,
        spendType = "mana",

        startsCombat = true,
        texture = 135739,

        toggle = "cooldowns",

        handler = function ()
        end,

        copy = { 58659 },
    },


    -- Scorch the enemy for 56 to 69 Fire damage.
    scorch = {
        id = 2948,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 135827,

        handler = function ()
        end,

        copy = { 8444, 8445, 8446, 10205, 10206, 10207, 27073, 27074, 42858, 42859 },
    },


    -- Reduces target's movement speed by 60%, increases the time between ranged attacks by 60% and increases casting time by 30%.  Lasts 15 sec.  Slow can only affect one target at a time.
    slow = {
        id = 31589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        talent = "slow",
        startsCombat = true,
        texture = 136091,

        handler = function ()
        end,
    },


    -- Slows friendly party or raid target's falling speed for 30 sec.
    slow_fall = {
        id = 130,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 135992,

        handler = function ()
            -- TODO: glyph.slow_fall.enabled removes the requirement for a reagent.
        end,
    },


    -- Steals a beneficial magic effect from the target.  This effect lasts a maximum of 2 min.
    spellsteal = {
        id = 30449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        startsCombat = true,
        texture = 135729,

        handler = function ()
        end,
    },


    -- Summon a Water Elemental to fight for the caster for 45 sec.
    summon_water_elemental = {
        id = 31687,
        cast = 0,
        cooldown = function() return glyph.water_elemental.enabled and 150 or 180 end,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        talent = "summon_water_elemental",
        startsCombat = true,
        texture = 135862,

        toggle = "cooldowns",

        handler = function ()
            -- TODO: glyph.eternal_winter.enabled makes summoned pet permanent.
        end,
    },


    -- Teleports the caster to Orgrimmar.
    teleport_orgrimmar = {
        id = 3567,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 135759,

        handler = function ()
        end,
    },


    -- Teleports the caster to Shattrath.
    teleport_shattrath = {
        id = 35715,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 135760,

        handler = function ()
        end,
    },


    -- Teleports the caster to Thunder Bluff.
    teleport_thunder_bluff = {
        id = 3566,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 135765,

        handler = function ()
        end,
    },


    -- Teleports the caster to Undercity.
    teleport_undercity = {
        id = 3563,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 135766,

        handler = function ()
        end,
    },
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 1459,

    nameplates = true,
    nameplateRange = 8,

    damage = false,
    damageExpiration = 6,

    -- package = "",
    -- package1 = "",
    -- package2 = "",
    -- package3 = "",
} )


spec:RegisterPackSelector( "arcane", nil, "|T135932:0|t Arcane",
    "If you have spent more points in |T135932:0|t Arcane than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )

spec:RegisterPackSelector( "fire", nil, "|T135810:0|t Fire",
    "If you have spent more points in |T135810:0|t Fire than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 )
    end )

spec:RegisterPackSelector( "survival", nil, "|T135846:0|t Frost",
    "If you have spent more points in |T135846:0|t Frost than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab3 > max( tab1, tab2 )
    end )