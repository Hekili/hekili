-- MageArcane.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 62 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)
local RC = LibStub("LibRangeCheck-3.0")

spec:RegisterResource( Enum.PowerType.ArcaneCharges, {
    arcane_orb = {
        aura = "arcane_orb",

        last = function ()
            local app = state.buff.arcane_orb.applied
            local t = state.query_time

            return app + floor( ( t - app ) * 2 ) * 0.5
        end,

        interval = 0.5,
        value = function () return state.active_enemies end,
    },
} )

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {

    -- Mage
    accumulative_shielding         = {  62093,  382800, 1 }, -- Your barrier's cooldown recharges $s1% faster while the shield persists
    alter_time                     = {  62115,  342245, 1 }, -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after $s1 sec. Effect negated by long distance or death
    arcane_warding                 = {  62114,  383092, 2 }, -- Reduces magic damage taken by $s1%
    barrier_diffusion              = {  62091,  455428, 1 }, -- Whenever one of your Barriers is removed, reduce its cooldown by $s1 sec
    blast_wave                     = {  62103,  157981, 1 }, -- Causes an explosion around yourself, dealing $s$s2 Fire damage to all enemies within $s3 yds, knocking them back, and reducing movement speed by $s4% for $s5 sec
    cryofreeze                     = {  62107,  382292, 2 }, -- While inside Ice Block, you heal for $s1% of your maximum health over the duration
    displacement                   = {  62095,  389713, 1 }, -- Teleports you back to where you last Blinked and heals you for $s1 million health. Only usable within $s2 sec of Blinking
    diverted_energy                = {  62101,  382270, 2 }, -- Your Barriers heal you for $s1% of the damage absorbed
    dragons_breath                 = { 101883,   31661, 1 }, -- Enemies in a cone in front of you take $s$s2 Fire damage and are disoriented for $s3 sec. Damage will cancel the effect
    energized_barriers             = {  62100,  386828, 1 }, -- When your barrier receives melee attacks, you have a $s1% chance to be granted Clearcasting. Casting your barrier removes all snare effects
    flow_of_time                   = {  62096,  382268, 2 }, -- The cooldowns of Blink and Shimmer are reduced by $s1 sec
    freezing_cold                  = {  62087,  386763, 1 }, -- Enemies hit by Cone of Cold are frozen in place for $s1 sec instead of snared. When your roots expire or are dispelled, your target is snared by $s2%, decaying over $s3 sec
    frigid_winds                   = {  62128,  235224, 2 }, -- All of your snare effects reduce the target's movement speed by an additional $s1%
    greater_invisibility           = {  93524,  110959, 1 }, -- Makes you invisible and untargetable for $s1 sec, removing all threat. Any action taken cancels this effect. You take $s2% reduced damage while invisible and for $s3 sec after reappearing
    ice_block                      = {  62122,   45438, 1 }, -- Encases you in a block of ice, protecting you from all attacks and damage for $s1 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for $s2% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for $s3 sec
    ice_cold                       = {  62085,  414659, 1 }, -- Ice Block now reduces all damage taken by $s1% for $s2 sec but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown
    ice_floes                      = {  62105,  108839, 1 }, -- Makes your next Mage spell with a cast time shorter than $s1 sec castable while moving. Unaffected by the global cooldown and castable while casting
    ice_nova                       = {  62088,  157997, 1 }, -- Causes a whirl of icy wind around the enemy, dealing $s$s2 Frost damage to the target and all other enemies within $s3 yds, freezing them in place for $s4 sec. Damage reduced beyond $s5 targets
    ice_ward                       = {  62086,  205036, 1 }, -- Frost Nova now has $s1 charges
    improved_frost_nova            = {  62108,  343183, 1 }, -- Frost Nova duration is increased by $s1 sec
    incantation_of_swiftness       = {  62112,  382293, 2 }, -- Greater Invisibility increases your movement speed by $s1% for $s2 sec
    incanters_flow                 = {  62118,    1463, 1 }, -- Magical energy flows through you while in combat, building up to $s1% increased damage and then diminishing down to $s2% increased damage, cycling every $s3 sec
    inspired_intellect             = {  62094,  458437, 1 }, -- Arcane Intellect grants you an additional $s1% Intellect
    mass_barrier                   = {  62092,  414660, 1 }, -- Cast Prismatic Barrier on yourself and $s1 allies within $s2 yds
    mass_invisibility              = {  62092,  414664, 1 }, -- You and your allies within $s1 yards instantly become invisible for $s2 sec. Taking any action will cancel the effect. Does not affect allies in combat
    mass_polymorph                 = {  62106,  383121, 1 }, -- Transforms all enemies within $s1 yards into sheep, wandering around incapacitated for $s2 sec. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters
    master_of_time                 = {  62102,  342249, 1 }, -- Reduces the cooldown of Alter Time by $s1 sec. Alter Time resets the cooldown of Blink and Shimmer when you return to your original location
    mirror_image                   = {  62124,   55342, 1 }, -- Creates $s1 copies of you nearby for $s2 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by $s3%. Taking direct damage will cause one of your images to dissipate
    overflowing_energy             = {  62120,  390218, 1 }, -- Your spell critical strike damage is increased by $s1%. When your direct damage spells fail to critically strike a target, your spell critical strike chance is increased by $s2%, up to $s3% for $s4 sec. When your spells critically strike Overflowing Energy is reset
    quick_witted                   = {  62104,  382297, 1 }, -- Successfully interrupting an enemy with Counterspell reduces its cooldown by $s1 sec
    reabsorption                   = {  62125,  382820, 1 }, -- You are healed for $s1% of your maximum health whenever a Mirror Image dissipates due to direct damage
    reduplication                  = {  62125,  382569, 1 }, -- Mirror Image's cooldown is reduced by $s1 sec whenever a Mirror Image dissipates due to direct damage
    remove_curse                   = {  62116,     475, 1 }, -- Removes all Curses from a friendly target
    rigid_ice                      = {  62110,  382481, 1 }, -- Frost Nova can withstand $s1% more damage before breaking
    ring_of_frost                  = {  62088,  113724, 1 }, -- Summons a Ring of Frost for $s1 sec at the target location. Enemies entering the ring are incapacitated for $s2 sec. Limit $s3 targets. When the incapacitate expires, enemies are slowed by $s4% for $s5 sec
    shifting_power                 = {  62113,  382440, 1 }, -- Draw power from within, dealing $s$s2 Arcane damage over $s3 sec to enemies within $s4 yds. While channeling, your Mage ability cooldowns are reduced by $s5 sec over $s6 sec
    shimmer                        = {  62105,  212653, 1 }, -- Teleports you $s1 yds forward, unless something is in the way. Unaffected by the global cooldown and castable while casting. Gain a shield that absorbs $s2% of your maximum health for $s3 sec after you Shimmer
    slow                           = {  62097,   31589, 1 }, -- Reduces the target's movement speed by $s1% for $s2 sec
    spellsteal                     = {  62084,   30449, 1 }, -- Steals a beneficial magic effect from the target. This effect lasts a maximum of $s1 min
    supernova                      = { 101883,  157980, 1 }, -- Pulses arcane energy around the target enemy or ally, dealing $s$s2 Arcane damage to all enemies within $s3 yds, and knocking them upward. A primary enemy target will take $s4% increased damage
    tempest_barrier                = {  62111,  382289, 2 }, -- Gain a shield that absorbs $s1% of your maximum health for $s2 sec after you Blink
    temporal_velocity              = {  62099,  382826, 2 }, -- Increases your movement speed by $s1% for $s2 sec after casting Blink and $s3% for $s4 sec after returning from Alter Time
    time_manipulation              = {  62129,  387807, 1 }, -- Casting Clearcasting Arcane Missiles reduces the cooldown of your loss of control abilities by $s1 sec
    tome_of_antonidas              = {  62098,  382490, 1 }, -- Increases Haste by $s1%
    tome_of_rhonin                 = {  62127,  382493, 1 }, -- Increases Critical Strike chance by $s1%
    volatile_detonation            = {  62089,  389627, 1 }, -- Greatly increases the effect of Blast Wave's knockback. Blast Wave's cooldown is reduced by $s1 sec
    winters_protection             = {  62123,  382424, 2 }, -- The cooldown of Ice Block is reduced by $s1 sec

    -- Arcane
    aether_attunement              = { 102476,  453600, 1 }, -- Every $s1 times you consume Clearcasting, gain Aether Attunement. Aether Attunement: Your next Arcane Missiles deals $s4% increased damage to your primary target and fires at up to $s5 nearby enemies dealing $s6% increased damage
    aether_fragment                = { 102477, 1222947, 1 }, -- Intuition's damage bonus increased by $s1%
    amplification                  = { 102448,  236628, 1 }, -- Arcane Missiles fires $s1 additional missiles
    arcane_bombardment             = { 102465,  384581, 1 }, -- Arcane Barrage deals an additional $s1% damage against targets below $s2% health
    arcane_debilitation            = { 102463,  453598, 2 }, -- Damaging a target with Arcane Missiles increases the damage they take from Arcane Missiles, Arcane Barrage, and Arcane Blast by $s1% for $s2 sec. Multiple instances may overlap
    arcane_echo                    = { 102457,  342231, 1 }, -- Direct damage you deal to enemies affected by Touch of the Magi, causes an explosion that deals $s$s2 Arcane damage to all nearby enemies. Deals reduced damage beyond $s3 targets
    arcane_familiar                = { 102439,  205022, 1 }, -- Casting Arcane Intellect summons a Familiar that attacks your enemies and increases your maximum mana by $s1% for $s2 |$s3hour:hrs;
    arcane_harmony                 = { 102447,  384452, 1 }, -- Each time Arcane Missiles hits an enemy, the damage of your next Arcane Barrage is increased by $s1%. This effect stacks up to $s2 times
    arcane_missiles                = { 102467,    5143, 1 }, -- Only castable when you have Clearcasting. Launches five waves of Arcane Missiles at the enemy over $s2 sec, causing a total of $s$s3 Arcane damage
    arcane_rebound                 = { 102441, 1223800, 1 }, -- When Arcane Barrage hits more than $s1 targets, it explodes for $s2 additional Arcane damage to all enemies within $s3 yds of the primary target
    arcane_surge                   = { 102449,  365350, 1 }, -- Expend all of your current mana to annihilate your enemy target and nearby enemies for up to $s$s2 Arcane damage based on Mana spent. Deals reduced damage beyond $s3 targets. Generates Clearcasting. For the next $s4 sec, your Mana regeneration is increased by $s5% and spell damage is increased by $s6%
    arcane_tempo                   = { 102446,  383980, 1 }, -- Consuming Arcane Charges increases your Haste by $s1% for $s2 sec, stacks up to $s3 times
    arcing_cleave                  = { 102458,  231564, 1 }, -- For each Arcane Charge, Arcane Barrage hits $s1 additional nearby target for $s2% damage
    big_brained                    = { 102446,  461261, 1 }, -- Gaining Clearcasting increases your Intellect by $s1% for $s2 sec. Multiple instances may overlap
    charged_orb                    = { 102475,  384651, 1 }, -- Arcane Orb gains $s1 additional charge. Arcane Orb damage increased by $s2%
    concentrated_power             = { 104113,  414379, 1 }, -- Arcane Missiles channels $s1% faster. Clearcasting makes Arcane Explosion echo for $s2% damage
    consortiums_bauble             = { 102453,  461260, 1 }, -- Reduces Arcane Blast's mana cost by $s1% and increases its damage by $s2%
    dematerialize                  = { 102456,  461456, 1 }, -- Spells empowered by Nether Precision cause their target to suffer an additional $s1% of the damage dealt over $s2 sec
    energized_familiar             = { 102462,  452997, 1 }, -- During Arcane Surge, your Familiar fires $s1 bolts instead of $s2. Damage from your Arcane Familiar has a small chance to grant you up to $s3% of your maximum mana
    energy_reconstitution          = { 102454,  461457, 1 }, -- Damage from Dematerialize has a small chance to summon an Arcane Explosion at its target's location at $s1% effectiveness. Arcane Explosions summoned from Energy Reconstitution do not generate Arcane Charges
    enlightened                    = { 102470,  321387, 1 }, -- Arcane damage dealt is increased based on your current mana, up to $s1% at full mana. Mana Regen is increased based on your current mana, up to $s2% when out of mana
    eureka                         = { 102455,  452198, 1 }, -- When a spell consumes Clearcasting, its damage is increased by $s1%
    evocation                      = { 102459,   12051, 1 }, -- Increases your mana regeneration by $s1% for $s2 sec and grants Clearcasting. While channeling Evocation, your Intellect is increased by $s3% every $s4 sec. Lasts $s5 sec
    high_voltage                   = { 102472,  461248, 1 }, -- Damage from Arcane Missiles has a $s1% chance to grant you $s2 Arcane Charge. Chance is increased by $s3% every time your Arcane Missiles fails to grant you an Arcane Charge
    illuminated_thoughts           = { 102444,  384060, 1 }, -- Clearcasting has a $s1% increased chance to proc
    impetus                        = { 102480,  383676, 1 }, -- Arcane Blast has a $s1% chance to generate an additional Arcane Charge. If you were to gain an Arcane Charge while at maximum charges instead gain $s2% Arcane damage for $s3 sec
    improved_clearcasting          = { 102445,  321420, 1 }, -- Clearcasting can stack up to $s1 additional times
    improved_touch_of_the_magi     = { 102452,  453002, 1 }, -- Your Touch of the Magi now accumulates $s1% of the damage you deal
    intuition                      = { 102471, 1223798, 1 }, -- Casting a damaging spell has a $s1% chance to make your next Arcane Barrage deal $s2% increased damage and generate $s3 Arcane Charges
    leydrinker                     = { 102474,  452196, 1 }, -- Consuming Clearcasting has a $s1% chance to make your next Arcane Blast echo, repeating its damage at $s2% effectiveness to the primary target and up to $s3 nearby enemies. Casting Touch of the Magi grants Leydrinker
    leysight                       = { 102477,  452187, 1 }, -- Nether Precision damage bonus increased by $s1%
    magis_spark                    = { 102435,  454016, 1 }, -- Your Touch of the Magi now also conjures a spark of potential for $s2 sec, causing the damage from your next Arcane Barrage, Arcane Blast, and Arcane Missiles to echo for $s3% of their damage. Upon receiving damage from all three spells, the spark explodes, dealing $s$s4 Arcane damage to all nearby enemies
    nether_munitions               = { 102435,  450206, 1 }, -- When your Touch of the Magi detonates, it increases the damage all affected targets take from you by $s1% for $s2 sec
    nether_precision               = { 102473,  383782, 1 }, -- Consuming Clearcasting increases the damage of your next $s1 Arcane Blasts or Arcane Barrages by $s2%
    orb_barrage                    = { 102443,  384858, 1 }, -- Arcane Barrage has a $s1% chance per Arcane Charge consumed to launch an Arcane Orb in front of you at $s2% effectiveness
    presence_of_mind               = { 102460,  205025, 1 }, -- Causes your next $s1 Arcane Blasts to be instant cast
    prodigious_savant              = { 102450,  384612, 2 }, -- Arcane Charges now increase the damage of Arcane Blast and Arcane Barrage by an additional $s1%
    resonance                      = { 102437,  205028, 1 }, -- Arcane Barrage deals $s1% increased damage per target it hits beyond the first
    reverberate                    = { 102448,  281482, 1 }, -- If Arcane Explosion hits at least $s1 targets, it has a $s2% chance to generate an extra Arcane Charge
    slipstream                     = { 102469,  236457, 1 }, -- Arcane Missiles and Evocation can now be channeled while moving
    static_cloud                   = { 102438,  461257, 1 }, -- Each time you cast Arcane Explosion, its damage increases by $s1%. Bonus resets after reaching $s2% damage
    surging_urge                   = { 102440,  457521, 1 }, -- Arcane Surge damage increased by $s1% per Arcane Charge
    time_loop                      = { 102451,  452924, 1 }, -- Arcane Debilitation's duration is increased by $s1 sec. When you apply a stack of Arcane Debilitation, you have a $s2% chance to apply another stack of Arcane Debilitation. This effect can trigger off of itself
    touch_of_the_magi              = { 102468,  321507, 1 }, -- Applies Touch of the Magi to your current target, accumulating $s1% of the damage you deal to the target for $s2 sec, and then exploding for that amount of Arcane damage to the target and reduced damage to all nearby enemies. Generates $s3 Arcane Charges

    -- Spellslinger
    augury_abounds                 = {  94662,  443783, 1 }, -- Casting Arcane Surge conjures $s1 Arcane Splinters. During Arcane Surge, whenever you conjure an Arcane Splinter, you have a $s2% chance to conjure an additional Arcane Splinter
    controlled_instincts           = {  94663,  444483, 1 }, -- For $s1 seconds after being struck by an Arcane Orb, $s2% of the direct damage dealt by an Arcane Splinter is also dealt to nearby enemies. Damage reduced beyond $s3 targets
    force_of_will                  = {  94656,  444719, 1 }, -- Gain $s1% increased critical strike chance. Gain $s2% increased critical strike damage
    look_again                     = {  94659,  444756, 1 }, -- Displacement has a $s1% longer duration and $s2% longer range
    phantasmal_image               = {  94660,  444784, 1 }, -- Your Mirror Image summons one extra clone. Mirror Image now reduces all damage taken by an additional $s1%
    reactive_barrier               = {  94660,  444827, 1 }, -- Your Prismatic Barrier can absorb up to $s1% more damage based on your missing Health. Max effectiveness when under $s2% health
    shifting_shards                = {  94657,  444675, 1 }, -- Shifting Power fires a barrage of $s1 Arcane Splinters at random enemies within $s2 yds over its duration
    signature_spell                = {  94657,  470021, 1 }, -- When your Magi's Spark explodes, you conjure $s1 Arcane Splinters
    slippery_slinging              = {  94659,  444752, 1 }, -- You have $s1% increased movement speed during Alter Time
    spellfrost_teachings           = {  94655,  444986, 1 }, -- Direct damage from Arcane Splinters reduces the cooldown of Arcane Orb by $s1 sec
    splintering_orbs               = {  94661,  444256, 1 }, -- Enemies damaged by your Arcane Orb conjure $s1 Arcane Splinters, up to $s2. Arcane Orb damage is increased by $s3%
    splintering_sorcery            = {  94664,  443739, 1 }, -- When you consume Nether Precision, conjure $s3 Arcane Splinters. Arcane Splinter: Conjure raw Arcane magic into a sharp projectile that deals $s$s6 Arcane damage. Arcane Splinters embed themselves into their target, dealing $s$s7 Arcane damage over $s8 sec. This effect stacks
    splinterstorm                  = {  94654,  443742, 1 }, -- Whenever you have $s2 or more active Embedded Arcane Splinters, you automatically cast a Splinterstorm at your target. Splinterstorm: Shatter all Embedded Arcane Splinters, dealing their remaining periodic damage instantly. Conjure an Arcane Splinter for each Splinter shattered, then unleash them all in a devastating barrage, dealing $s$s5 Arcane damage to your target for each Splinter in the Splinterstorm. Splinterstorm has a $s6% chance to grant Clearcasting
    unerring_proficiency           = {  94658,  444974, 1 }, -- Each time you conjure an Arcane Splinter, increase the damage of your next Supernova by $s1%. Stacks up to $s2 times
    volatile_magic                 = {  94658,  444968, 1 }, -- Whenever an Embedded Arcane Splinter is removed, it explodes, dealing $s$s2 Arcane damage to nearby enemies. Deals reduced damage beyond $s3 targets

    -- Sunfury
    burden_of_power                = {  94644,  451035, 1 }, -- Conjuring a Spellfire Sphere increases the damage of your next Arcane Blast by $s1% or Arcane Barrage by $s2%
    codex_of_the_sunstriders       = {  94643,  449382, 1 }, -- Over its duration, your Arcane Phoenix will consume each of your Spellfire Spheres to cast an exceptional spell. Upon consuming a Spellfire Sphere, your Arcane Phoenix will grant you Lingering Embers.  Lingering Embers Increases your spell damage by $s3%
    glorious_incandescence         = {  94645,  449394, 1 }, -- Consuming Burden of Power causes your next Arcane Barrage to deal $s1% increased damage, grant $s2 Arcane Charges, and call down a storm of $s3 Meteorites at your target
    gravity_lapse                  = {  94651,  458513, 1 }, -- Your Supernova becomes Gravity Lapse. Gravity Lapse The snap of your fingers warps the gravity around your target and $s4 other nearby enemies, suspending them in the air for $s5 sec. Upon landing, nearby enemies take $s$s6 Arcane damage
    ignite_the_future              = {  94648,  449558, 1 }, -- Generating a Spellfire Sphere while your Phoenix is active causes it to cast an exceptional spell. Mana Cascade can now stack up to $s1 times
    invocation_arcane_phoenix      = {  94652,  448658, 1 }, -- When you cast Arcane Surge, summon an Arcane Phoenix to aid you in battle.  Arcane Phoenix Your Arcane Phoenix aids you for the duration of your Arcane Surge, casting random Arcane and Fire spells
    lessons_in_debilitation        = {  94651,  449627, 1 }, -- Your Arcane Phoenix will Spellsteal when it is summoned and when it expires
    mana_cascade                   = {  94653,  449293, 1 }, -- Casting Arcane Blast or Arcane Barrage grants you $s1% Haste for $s2 sec. Stacks up to $s3 times. Multiple instances may overlap
    memory_of_alar                 = {  94646,  449619, 1 }, -- While under the effects of a casted Arcane Surge, you gain twice as many stacks of Mana Cascade. When your Arcane Phoenix expires, it empowers you, granting Arcane Soul for $s1 sec, plus an additional $s2 sec for each exceptional spell it had cast. Arcane Soul: Arcane Barrage grants Clearcasting and generates $s5 Arcane Charges. Each cast of Arcane Barrage increases the damage of Arcane Barrage by $s6%, up to $s7%
    merely_a_setback               = {  94649,  449330, 1 }, -- Your Prismatic Barrier now grants $s1% avoidance while active and $s2% leech for $s3 sec when it breaks or expires
    rondurmancy                    = {  94648,  449596, 1 }, -- Spellfire Spheres can now stack up to $s1 times
    savor_the_moment               = {  94650,  449412, 1 }, -- When you cast Arcane Surge, its duration is extended by $s1 sec for each Spellfire Sphere you have, up to $s2 sec
    spellfire_spheres              = {  94647,  448601, 1 }, -- Every $s1 times you cast Arcane Blast or Arcane Barrage, conjure a Spellfire Sphere. While you're out of combat, you will slowly conjure Spellfire Spheres over time.  Spellfire Sphere Increases your spell damage by $s4%. Stacks up to $s5 times
    sunfury_execution              = {  94650,  449349, 1 }, -- Arcane Bombardment damage bonus increased to $s1%.  Arcane Bombardment Arcane Barrage deals an additional $s4% damage against targets below $s5% health
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    arcanosphere                   = 5397, -- (353128) Builds a sphere of Arcane energy, gaining power over $s1 sec. Upon release, the sphere passes through any barriers, knocking enemies back and dealing up to $s2 million Arcane damage
    chrono_shift                   = 5661, -- (235711)
    ethereal_blink                 = 5601, -- (410939) Blink and Shimmer apply Slow at $s1% effectiveness to all enemies you Blink through. For each enemy you Blink through, the cooldown of Blink and Shimmer are reduced by $s2 sec, up to $s3 sec
    ice_wall                       = 5488, -- (352278) Conjures an Ice Wall $s1 yards long that obstructs line of sight. The wall has $s2% of your maximum health and lasts up to $s3 sec
    improved_mass_invisibility     =  637, -- (415945) The cooldown of Mass Invisibility is reduced by $s1 min and can affect allies in combat
    kleptomania                    = 3529, -- (198100)
    master_of_escape               =  635, -- (210476)
    master_shepherd                = 5589, -- (410248) While an enemy player is affected by your Polymorph or Mass Polymorph, your movement speed is increased by $s1% and your Versatility is increased by $s2%. Additionally, Polymorph and Mass Polymorph no longer heal enemies
    nether_flux                    = 5714, -- (461264)
    overpowered_barrier            = 5707, -- (1220739) Your barriers absorb $s2% more damage and have an additional effect, but last $s3 sec.  Prismatic Barrier If the barrier is fully absorbed, your next Blink or Shimmer within $s6 sec grants Invisibility and immunity to damage for $s7 sec$s$s8 The damage reduction is lost if Invisibility ends
    ring_of_fire                   = 5491, -- (353082) Summons a Ring of Fire for $s1 sec at the target location. Enemies entering the ring are disoriented and burn for $s2% of their total health over $s3 sec
} )

-- Auras
spec:RegisterAuras( {
    aether_attunement = {
        id = 453601,
        duration = 30,
        max_stack = 1
    },
    aether_attunement_stack = {
        id = 458388,
        duration = 180,
        max_stack = 3,
        copy = "aether_attunement_counter"
    },
    --[[aethervision = {
        id = 467634,
        duration = 10,
        max_stack = 2
    },--]]
    -- Talent: Altering Time. Returning to past location and health when duration expires.
    -- https://wowhead.com/beta/spell=342246
    alter_time = {
        id = 342246,
        duration = 10,
        max_stack = 1
    },
    arcane_blast_overcapped = {
        duration = 3,
        max_stack = 1,
    },
    -- Increases the damage of Arcane Blast, Arcane Missiles, Arcane Explosion, and Arcane Barrage by $36032w1%.    Increases the mana cost of Arcane Blast by $36032w2%$?{$w5<0}[, and reduces the cast time of Arcane Blast by $w5%.][.]    Increases the number of targets hit by Arcane Barrage for 50% damage by $36032w3.
    -- https://wowhead.com/beta/spell=36032
    arcane_charge = {
        duration = 3600,
        max_stack = 4,
        generate = function ()
            local ac = buff.arcane_charge

            if arcane_charges.current > 0 then
                ac.count = arcane_charges.current
                ac.applied = query_time
                ac.expires = query_time + 3600
                ac.caster = "player"
                return
            end

            ac.count = 0
            ac.applied = 0
            ac.expires = 0
            ac.caster = "nobody"
        end,
    },
    arcane_debilitation = {
        id = 453599,
        duration = function () return 6 + (talent.time_loop.enabled and 2 or 0) end,
        max_stack = 15
    },
    -- Talent: Maximum mana increased by $s1%.
    -- https://wowhead.com/beta/spell=210126
    arcane_familiar = {
        id = 210126,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Increases the damage of your next Arcane Barrage by $s1%.
    -- https://wowhead.com/beta/spell=384455
    arcane_harmony = {
        id = 384455,
        duration = 3600,
        max_stack = 20,
        copy = 332777
    },
    -- Intellect increased by $w1%.
    -- https://wowhead.com/beta/spell=1459
    arcane_intellect = {
        id = 1459,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        shared = "player"
    },
    arcane_orb = {
        duration = 2.5,
        max_stack = 1,
        --[[ generate = function ()
            local last = action.arcane_orb.lastCast
            local ao = buff.arcane_orb

            if query_time - last < 2.5 then
                ao.count = 1
                ao.applied = last
                ao.expires = last + 2.5
                ao.caster = "player"
                return
            end

            ao.count = 0
            ao.applied = 0
            ao.expires = 0
            ao.caster = "nobody"
        end, ]]
    },
    arcane_soul = {
        id = 451038,
        duration = function () return 2 + ( buff.lingering_embers.stacks * 1 ) end,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=1223522
    -- Arcane Soul Arcane Barrage deals 90% increased damage.
    arcane_soul_damage_buff = {
        id = 1223522,
        duration = 5,
        max_stack = 10,
    },
    -- Talent: Spell damage increased by $w1% and Mana Regeneration increase $w3%.
    -- https://wowhead.com/beta/spell=365362
    arcane_surge = {
        id = 365362,
        duration = function() return 15 + ( set_bonus.tier30_2pc > 0 and 3 or 0 ) + ( talent.savor_the_moment.enabled and buff.spellfire_spheres.stacks * 0.5 or 0 ) end,
        type = "Magic",
        max_stack = 1
    },
    arcane_tempo = {
        id = 383997,
        duration = 12,
        max_stack = 5
    },
    big_brained = {
        id = 461531,
        duration = 8,
        max_stack = 10
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=157981
    blast_wave = {
        id = 157981,
        duration = 6,
        type = "Magic",
        max_stack = 1

        -- Affected by:
        -- frigid_winds[235224] #6: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- volatile_detonation[389627] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Absorbs $w1 damage.  Melee attackers take $235314s1 Fire damage.
    -- https://wowhead.com/beta/spell=235313
    blazing_barrier = {
        id = 235313,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Blinking.
    -- https://wowhead.com/beta/spell=1953
    blink = {
        id = 1953,
        duration = 0.3,
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=12486
    blizzard = {
        id = 12486,
        duration = 3,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    burden_of_power = {
        id = 451049,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Your next Arcane Missiles or Arcane Explosion costs no mana$?s321758[ and Arcane Missiles fires an additional missile][].
    -- https://wowhead.com/beta/spell=263725
    clearcasting = {
        id = function () return pvptalent.arcane_empowerment.enabled and 276743 or 263725 end,
        duration = 15,
        type = "Magic",
        max_stack = function ()
            return ( talent.improved_clearcasting.enabled and 3 or 1 ) + ( pvptalent.arcane_empowerment.enabled and 2 or 0 )
        end,
        copy = { 263725, 276743 }
    },
    clearcasting_channel = {
        duration = function () return 2.5 * haste end,
        tick_time = function () return ( 2.5 / 6 ) * haste end,
        max_stack = 1,
    },
    -- Talent: Your next Clearcasting will not be consumed.
    -- https://wowhead.com/beta/spell=384379
    --[[concentration = {
        id = 384379,
        duration = 30,
        max_stack = 1
    },--]]
    dematerialize = {
        id = 461498,
        duration = 6,
        max_stack = 1
    },
    embedded_arcane_splinter = {
        id = 444735,
        duration = 18,
        max_stack = 99
    },
    enlightened = {
        id = 1217242,
        duration = 3600,
        max_stack = 1
    },
    expanded_potential = {
        id = 327495,
        duration = 300,
        max_stack = 1
    },
    -- Talent: Mana regeneration increased by $s1%.
    -- https://wowhead.com/beta/spell=12051
    evocation = {
        id = 12051,
        duration = function () return 2.8 * haste end,
        tick_time = function () return 0.5 * haste end,
        max_stack = 1,
    },
    freezing_cold = {
        id = 386770,
        duration = 5,
        max_stack = 1,
    },
    -- Frozen in place.
    -- https://wowhead.com/beta/spell=122
    frost_nova = {
        id = 122,
        duration = function() return talent.improved_frost_nova.enabled and 8 or 6 end,
        type = "Magic",
        max_stack = 1,
        copy = 235235
    },
    glorious_incandescence = {
        id = 451073,
        duration = 11,
        max_stack = 1
    },
    gravity_lapse = {
        id = 473291,
        duration = 3,
        max_stack = 1
    },
    high_voltage = {
        id = 461525,
        duration = 3600,
        max_stack = 10
    },
    hypothermia = {
        id = 41425,
        duration = 30,
        max_stack = 1,
    },
    -- Talent: Immune to all attacks and damage.  Cannot attack, move, or use spells.
    -- https://wowhead.com/beta/spell=45438
    ice_block = {
        id = 45438,
        duration = 10,
        mechanic = "invulneraility",
        type = "Magic",
        max_stack = 1
    },
    ice_cold = {
        id = 414658,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Able to move while casting spells.
    -- https://wowhead.com/beta/spell=108839
    ice_floes = {
        id = 108839,
        duration = 15,
        type = "Magic",
        max_stack = 3
    },
    impetus = {
        id = 393939,
        duration = 10,
        max_stack = 1,
    },
    incantation_of_swiftness = {
        id = 382294,
        duration = 6,
        max_stack = 1,
        copy = 337278
    },
    incanters_flow = {
        id = 116267,
        duration = 3600,
        max_stack = 5,
        meta = {
            stack = function() return state.incanters_flow_stacks end,
            stacks = function() return state.incanters_flow_stacks end,
        }
    },
    intuition = {
        id = 1223797,
        duration = 5,
        max_stack = 1
    },
    leydrinker = {
        id = 453758,
        duration = 30,
        max_stack = 1
    },
    lingering_embers = {
        id = 461145,
        duration = 10,
        max_stack = 15
    },
    magis_spark_arcane_barrage = {
        duration = 12,
        max_stack = 1
    },
    magis_spark_arcane_blast = {
        duration = 12,
        max_stack = 1
    },
    magis_spark_arcane_missiles = {
        duration = 12,
        max_stack = 1
    },
    mana_cascade = {
        id = 449322,
        duration = 10,
        max_stack = function () return 10 + talent.ignite_the_future.enabled and 5 or 0 end
    },
    mass_polymorph = {
        id = 383121,
        duration = 15,
        max_stack = 1
    },
    mirror_image = {
        id = 55342,
        duration = 40,
        max_stack = 3,
        generate = function ()
            local mi = buff.mirror_image

            if action.mirror_image.lastCast > 0 and query_time < action.mirror_image.lastCast + 40 then
                mi.count = 1
                mi.applied = action.mirror_image.lastCast
                mi.expires = mi.applied + 40
                mi.caster = "player"
                return
            end

            mi.count = 0
            mi.applied = 0
            mi.expires = 0
            mi.caster = "nobody"
        end,
    },
    mirrors_of_torment = {
        id = 314793,
        duration = 20,
        type = "Magic",
        max_stack = 3,
    },
    nether_munitions = {
        id = 454004,
        duration = 12,
        max_stack = 1
    },
    nether_precision = {
        id = 383783,
        duration = 10,
        max_stack = 2,
        copy = 336889
    },
    -- Talent: Deals $w1 Arcane damage and an additional $w1 Arcane damage to all enemies within $114954A1 yards every $t sec.
    -- https://wowhead.com/beta/spell=114923
    nether_tempest = {
        id = 114923,
        duration = 12,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Spell critical strike chance increased by $w1%.
    -- https://wowhead.com/beta/spell=394195
    overflowing_energy = {
        id = 394195,
        duration = 8,
        max_stack = 5
    },
    -- Talent: Arcane Blast is instant cast.
    -- https://wowhead.com/beta/spell=205025
    presence_of_mind = {
        id = 205025,
        duration = 3600,
        max_stack = 2,
        onRemove = function( t )
            setCooldown( "presence_of_mind", action.presence_of_mind.cooldown )
        end,
    },
    -- Talent: Absorbs $w1 damage.  Magic damage taken reduced by $s3%.  Duration of all harmful Magic effects reduced by $w4%.
    -- https://wowhead.com/beta/spell=235450
    prismatic_barrier = {
        id = 235450,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Every $t1 sec, deal $382445s1 Nature damage to enemies within $382445A1 yds and reduce the remaining cooldown of your abilities by ${-$s2/1000} sec.
    -- https://wowhead.com/beta/spell=382440
    shifting_power = {
        id = 382440,
        duration = function() return 4 * haste end,
        tick_time = function() return haste end,
        type = "Magic",
        max_stack = 1,
        copy = 314791
    },
    -- Talent: Shimmering.
    -- https://wowhead.com/beta/spell=212653
    shimmer = {
        id = 212653,
        duration = 0.65,
        type = "Magic",
        max_stack = 1
    },
    siphon_storm = {
        id = 384267,
        duration = 30,
        max_stack = 10,
        copy = 332934
    },
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=31589
    slow = {
        id = 31589,
        duration = 15,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    spellfrost_teachings = {
        id = 458411,
        duration = 10,
        max_stack = 1
    },
    static_cloud = {
        id = 461515,
        duration = 60,
        max_stack = 4
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=382290
    tempest_barrier = {
        id = 382290,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    temporal_velocity = {
        id = 384360,
        duration = 3,
        type = "Magic",
        max_stack = 1,
    },
    -- Rooted and Silenced.
    -- https://wowhead.com/beta/spell=317589
    tormenting_backlash = {
        id = 317589,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Will explode for $w1 Arcane damage upon expiration.
    -- https://wowhead.com/beta/spell=210824
    touch_of_the_magi = {
        id = 210824,
        duration = 12,
        max_stack = 1
    },
    -- Suffering $w1 Fire damage every $t1 sec.
    -- https://wowhead.com/beta/spell=277703
    trailing_embers = {
        id = 277703,
        duration = 6,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    unerring_proficiency = {
        id = 444981,
        duration = 60,
        max_stack = 30
    },

    -- Azerite Powers
    brain_storm = {
        id = 273330,
        duration = 30,
        max_stack = 1,
    },
    equipoise = {
        id = 264352,
        duration = 3600,
        max_stack = 1,
    },

    -- Legendaries
    heart_of_the_fae = {
        id = 356881,
        duration = 15,
        max_stack = 1,
    },
    grisly_icicle = {
        id = 348007,
        duration = 8,
        max_stack = 1
    },

    -- Sunfury
	-- Spellfire Spheres actual buff
	-- Spellfire Spheres has two diffrent counter. 449400 for create a Sphere, 448604 is Sphere number
	-- https://www.wowhead.com/spell=449400/spellfire-spheres
    spellfire_spheres = {
        id = 448604,
        duration = 3600,
        max_stack = function() return 3 + ( talent.rondurmancy.enabled and 2 or 0 ) end,
    },

    next_blast_spheres = {
        id = 449400,
        duration = 30,
        max_stack = 5,
    }

} )

local TriggerArcaneOverloadT30 = setfenv( function()
    applyBuff( "arcane_overload" )
end, state )

local TriggerArcaneSoul = setfenv( function()

    local mod = 1.5

    if set_bonus.tww3 >= 4 then
        mod = 2
        applyBuff( "lesser_time_warp" )
        applyBuff( "flame_quills" )
    end

    applyBuff( "arcane_soul", 2 + ( buff.lingering_embers.stacks * mod ) )

end, state )

-- Variables from APL (2022-11-30)
-- actions.precombat+=/variable,name=aoe_target_count,default=-1,op=set,if=variable.aoe_target_count=-1,value=3
spec:RegisterVariable( "aoe_target_count", function ()
    return 3
end )

-- Goal is to conserve mana through the first TotM in a fight, then burn otherwise.
local totm_casts = 0
local clearcasting_consumed = 0

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_CAST_SUCCESS" and spellID == 321507 then
            totm_casts = ( totm_casts + 1 ) % 2

        elseif ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" ) and spellID == 458411 then
            -- Handle Arcane Orb projectile.
            local travel = ( UnitExists( "target" ) and select( 2, RC:GetRange( "target" ) ) or 40 ) / 30
            state:QueueEvent( "arcane_orb", GetTime(), 0.05 + travel, "PROJECTILE_IMPACT", UnitGUID( "target" ), true )

        elseif subtype == "SPELL_AURA_REMOVED" and ( spellID == 276743 or spellID == 263725 ) then
            -- Clearcasting was consumed.
            clearcasting_consumed = GetTime()
        end
    end
end, false )

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
    totm_casts = 0
end )

-- actions.precombat+=/variable,name=conserve_mana,op=set,value=0
-- actions.touch_phase+=/variable,name=conserve_mana,op=set,if=debuff.touch_of_the_magi.remains>9,value=1-variable.conserve_mana
spec:RegisterVariable( "conserve_mana", function ()
    return totm_casts % 2 > 0
end )

do
    -- Builds Disciplinary Command; written so that it can be ported to the other two Mage specs.
    function Hekili:EmbedDisciplinaryCommand( x )
        local file_id = x.id

        x:RegisterAuras( {
            disciplinary_command = {
                id = 327371,
                duration = 20,
            },

            disciplinary_command_arcane = {
                duration = 10,
                max_stack = 1,
            },

            disciplinary_command_frost = {
                duration = 10,
                max_stack = 1,
            },

            disciplinary_command_fire = {
                duration = 10,
                max_stack = 1,
            }
        } )

        local __last_arcane, __last_fire, __last_frost, __last_disciplinary_command = 0, 0, 0, 0
        local __last_arcSpell, __last_firSpell, __last_froSpell

        x:RegisterHook( "reset_precast", function ()
            if not legendary.disciplinary_command.enabled then return end

            if now - __last_arcane < 10 then applyBuff( "disciplinary_command_arcane", 10 - ( now - __last_arcane ) ) end
            if now - __last_fire   < 10 then applyBuff( "disciplinary_command_fire",   10 - ( now - __last_fire ) ) end
            if now - __last_frost  < 10 then applyBuff( "disciplinary_command_frost",  10 - ( now - __last_frost ) ) end

            if now - __last_disciplinary_command < 30 then
                setCooldown( "buff_disciplinary_command", 30 - ( now - __last_disciplinary_command ) )
            end

            Hekili:Debug( "Disciplinary Command:\n - Arcane: %.2f, %s\n - Fire  : %.2f, %s\n - Frost : %.2f, %s\n - ICD   : %.2f", buff.disciplinary_command_arcane.remains, __last_arcSpell or "None", buff.disciplinary_command_fire.remains, __last_firSpell or "None", buff.disciplinary_command_frost.remains, __last_froSpell or "None", cooldown.buff_disciplinary_command.remains )
        end )

        x:RegisterStateFunction( "update_disciplinary_command", function( action )
            local ability = class.abilities[ action ]

            if not ability then return end
            if ability.item or ability.from == 0 then return end

            if     ability.school == "arcane" then applyBuff( "disciplinary_command_arcane" )
            elseif ability.school == "fire"   then applyBuff( "disciplinary_command_fire"   )
            elseif ability.school == "frost"  then applyBuff( "disciplinary_command_frost"  )
            else
                local sAction = x.abilities[ action ]
                local sDiscipline = sAction and sAction.school

                if sDiscipline then
                    if     sDiscipline == "arcane" then applyBuff( "disciplinary_command_arcane" )
                    elseif sDiscipline == "fire"   then applyBuff( "disciplinary_command_fire"   )
                    elseif sDiscipline == "frost"  then applyBuff( "disciplinary_command_frost"  ) end
                else applyBuff( "disciplinary_command_" .. state.spec.key ) end
            end

            if buff.disciplinary_command_arcane.up and buff.disciplinary_command_fire.up and buff.disciplinary_command_frost.up then
                applyBuff( "disciplinary_command" )
                setCooldown( "buff_disciplinary_command", 30 )
                removeBuff( "disciplinary_command_arcane" )
                removeBuff( "disciplinary_command_fire" )
                removeBuff( "disciplinary_command_frost" )
            end
        end )

        x:RegisterHook( "runHandler", function( action )
            if not legendary.disciplinary_command.enabled or cooldown.buff_disciplinary_command.remains > 0 then return end
            update_disciplinary_command( action )
        end )

        local triggerEvents = {
            SPELL_CAST_SUCCESS = true,
            SPELL_HEAL = true,
            SPELL_SUMMON= true
        }

        local spellChanges = {
            [108853] = 319836,
            [212653] = 1953,
            [342130] = 116011,
            [337137] = 1,
        }

        local spellSchools = {
            [4] = "fire",
            [16] = "frost",
            [64] = "arcane"
        }

        x:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, _, _, _, _, _, _, _, spellID, spellName, spellSchool )
            if sourceGUID == GUID then
                if triggerEvents[ subtype ] then
                    spellID = spellChanges[ spellID ] or spellID
                    if not IsSpellKnownOrOverridesKnown( spellID ) then return end

                    local school = spellSchools[ spellSchool ]
                    if not school then return end

                    if     school == "arcane" then __last_arcane = GetTime(); __last_arcSpell = spellName
                    elseif school == "fire"   then __last_fire   = GetTime(); __last_firSpell = spellName
                    elseif school == "frost"  then __last_frost  = GetTime(); __last_froSpell = spellName end
                    return
                elseif subtype == "SPELL_AURA_APPLIED" and spellID == class.auras.disciplinary_command.id then
                    __last_disciplinary_command = GetTime()
                    __last_arcane = 0
                    __last_fire = 0
                    __last_frost = 0
                end
            end
        end, false )

        x:RegisterAbility( "buff_disciplinary_command", {
            cooldown_special = function ()
                local remains = ( now + offset ) - __last_disciplinary_command

                if remains < 30 then
                    return __last_disciplinary_command, 30
                end

                return 0, 0
            end,
            unlisted = true,

            cast = 0,
            cooldown = 30,
            gcd = "off",

            handler = function()
                applyBuff( "disciplinary_command" )
            end,
        } )
    end
end

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237721, 237719, 237718, 237716, 237717 },
        auras = {
            -- Sunfury
            flame_quills = {
                id = 1236145,
                duration = 13,
                max_stack = 1
            },
            lesser_time_warp = {
                id = 1236231,
                duration = 13,
                max_stack = 1
            },
            -- Spellslinger
            -- Spherical Sorcery Your spell damage is increased by $s1% $s2 seconds remaining
            -- https://www.wowhead.com/spell=1247525
            spherical_sorcery = {
                id = 1247525,
                duration = 10,
                max_stack = 1
            },
        }
    },
    tww2 = {
        items = { 229346, 229344, 229342, 229343, 229341 },
        auras = {
            clarity = {
                id = 1216178,
                duration = 12,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207288, 207289, 207290, 207291, 207293, 217232, 217234, 217235, 217231, 217233 },
        auras = {
            forethought = {
                id = 424293,
                duration = 20,
                max_stack = 5
            },
            arcane_battery = {
                id = 424334,
                duration = 30,
                max_stack = 3
            },
            arcane_artillery = {
                id = 424331,
                duration = 30,
                max_stack = 1
            }
        }
    },
    tier30 = {
        items = { 202554, 202552, 202551, 202550, 202549 },
        auras = {
            arcane_overload = {
                id = 409022,
                duration = 18,
                max_stack = 25
            }
        }
    },
    tier29 = {
        items = { 200318, 200320, 200315, 200317, 200319 },
        auras = {
            bursting_energy = {
                id = 395006,
                duration = 12,
                max_stack = 4
            }
        }
    }
} )

spec:RegisterHook( "spend", function( amt, resource )
    if resource == "arcane_charges" then
        if arcane_charges.current == 0 then
            removeBuff( "arcane_charge" )
        else
            applyBuff( "arcane_charge", nil, arcane_charges.current )
        end
        if amt > 0 and talent.arcane_tempo.enabled then
            addStack( "arcane_tempo", nil, 1 )
        end

    elseif resource == "mana" then
        if azerite.equipoise.enabled and mana.percent < 70 then
            removeBuff( "equipoise" )
        end
    end
end )

spec:RegisterHook( "gain", function( amt, resource )
    if resource == "arcane_charges" then
        if arcane_charges.current == 0 then
            removeBuff( "arcane_charge" )
        else
            applyBuff( "arcane_charge", nil, arcane_charges.current )
        end
    end
end )

spec:RegisterHook( "runHandler", function( action )
    if buff.ice_floes.up then
        local ability = class.abilities[ action ]
        if ability and ability.cast > 0 and ability.cast < 10 then removeStack( "ice_floes" ) end
    end
end )

spec:RegisterStateTable( "incanters_flow", {
    changed = 0,
    count = 0,
    direction = 0,

    startCount = 0,
    startTime = 0,
    startIndex = 0,

    values = {
        [0] = { 0, 1 },
        { 1, 1 },
        { 2, 1 },
        { 3, 1 },
        { 4, 1 },
        { 5, 0 },
        { 5, -1 },
        { 4, -1 },
        { 3, -1 },
        { 2, -1 },
        { 1, 0 }
    },

    f = CreateFrame( "Frame" ),
    fRegistered = false,

    reset = setfenv( function ()
        if talent.incanters_flow.enabled then
            if not incanters_flow.fRegistered then
                Hekili:ProfileFrame( "Incanters_Flow_Arcane", incanters_flow.f )
                -- One-time setup.
                incanters_flow.f:RegisterUnitEvent( "UNIT_AURA", "player" )
                incanters_flow.f:SetScript( "OnEvent", function ()
                    -- Check to see if IF changed.
                    if state.talent.incanters_flow.enabled then
                        local flow = state.incanters_flow
                        local name, _, count = FindUnitBuffByID( "player", 116267, "PLAYER" )
                        local now = GetTime()

                        if name then
                            if count ~= flow.count then
                                if count == 1 then flow.direction = 0
                                elseif count == 5 then flow.direction = 0
                                else flow.direction = ( count > flow.count ) and 1 or -1 end

                                flow.changed = GetTime()
                                flow.count = count
                            end
                        else
                            flow.count = 0
                            flow.changed = GetTime()
                            flow.direction = 0
                        end
                    end
                end )

                incanters_flow.fRegistered = true
            end

            if now - incanters_flow.changed >= 1 then
                if incanters_flow.count == 1 and incanters_flow.direction == 0 then
                    incanters_flow.direction = 1
                    incanters_flow.changed = incanters_flow.changed + 1
                elseif incanters_flow.count == 5 and incanters_flow.direction == 0 then
                    incanters_flow.direction = -1
                    incanters_flow.changed = incanters_flow.changed + 1
                end
            end

            if incanters_flow.count == 0 then
                incanters_flow.startCount = 0
                incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                incanters_flow.startIndex = 0
            else
                incanters_flow.startCount = incanters_flow.count
                incanters_flow.startTime = incanters_flow.changed + floor( now - incanters_flow.changed )
                incanters_flow.startIndex = 0

                for i, val in ipairs( incanters_flow.values ) do
                    if val[1] == incanters_flow.count and val[2] == incanters_flow.direction then incanters_flow.startIndex = i; break end
                end
            end
        else
            incanters_flow.count = 0
            incanters_flow.changed = 0
            incanters_flow.direction = 0
        end
    end, state ),
} )

spec:RegisterStateExpr( "incanters_flow_stacks", function ()
    if not talent.incanters_flow.enabled then return 0 end

    local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
    if index > 10 then index = index % 10 end

    return incanters_flow.values[ index ][ 1 ]
end )

spec:RegisterStateExpr( "incanters_flow_dir", function()
    if not talent.incanters_flow.enabled then return 0 end

    local index = incanters_flow.startIndex + floor( query_time - incanters_flow.startTime )
    if index > 10 then index = index % 10 end

    return incanters_flow.values[ index ][ 2 ]
end )

-- Seemingly, a very silly way to track Incanter's Flow...
local incanters_flow_time_obj = setmetatable( { __stack = 0 }, {
    __index = function( t, k )
        if not state.talent.incanters_flow.enabled then return 0 end

        local stack = t.__stack
        local ticks = #state.incanters_flow.values

        local start = state.incanters_flow.startIndex + floor( state.offset + state.delay )

        local low_pos, high_pos

        if k == "up" then low_pos = 5
        elseif k == "down" then high_pos = 6 end

        local time_since = ( state.query_time - state.incanters_flow.changed ) % 1

        for i = 0, 10 do
            local index = ( start + i )
            if index > 10 then index = index % 10 end

            local values = state.incanters_flow.values[ index ]

            if values[ 1 ] == stack and ( not low_pos or index <= low_pos ) and ( not high_pos or index >= high_pos ) then
                return max( 0, i - time_since )
            end
        end

        return 0
    end
} )

spec:RegisterStateTable( "incanters_flow_time_to", setmetatable( {}, {
    __index = function( t, k )
        incanters_flow_time_obj.__stack = tonumber( k ) or 0
        return incanters_flow_time_obj
    end
} ) )

spec:RegisterStateExpr( "tick_reduction", function ()
    return action.shifting_power.cdr / 4
end )

spec:RegisterStateExpr( "full_reduction", function ()
    return action.shifting_power.cdr
end )

local NetherMunitions = setfenv( function()
    applyDebuff( "target", "nether_munitions" )
    active_dot.nether_munitions = true_active_enemies
end, state )

spec:RegisterHook( "reset_precast", function ()
   --[[ if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
    else removeBuff( "rune_of_power" ) end --]]

    if buff.casting.up and buff.casting.v1 == 5143 and abs( action.arcane_missiles.lastCast - clearcasting_consumed ) < 0.15 then
        applyBuff( "clearcasting_channel", buff.casting.remains )
    end

    if arcane_charges.current > 0 then applyBuff( "arcane_charge", nil, arcane_charges.current ) end

    if buff.arcane_surge.up and set_bonus.tier30_4pc > 0 then
        state:QueueAuraEvent( "arcane_overload", TriggerArcaneOverloadT30, buff.arcane_surge.expires, "AURA_EXPIRATION" )
    end

    if buff.arcane_surge.up and talent.memory_of_alar.enabled then
        state:QueueAuraEvent( "arcane_soul", TriggerArcaneSoul, buff.arcane_surge.expires, "AURA_EXPIRATION" )
    end

    incanters_flow.reset()

    if talent.magis_spark.enabled and debuff.touch_of_the_magi.up then
        if action.arcane_barrage.lastCast < debuff.touch_of_the_magi.applied then applyDebuff( "target", "magis_spark_arcane_barrage" ) end
        if action.arcane_blast.lastCast < debuff.touch_of_the_magi.applied then applyDebuff( "target", "magis_spark_arcane_blast" ) end
        if action.arcane_missiles.lastCast < debuff.touch_of_the_magi.applied then applyDebuff( "target", "magis_spark_arcane_missiles" ) end
    end

    if talent.nether_munitions.enabled and debuff.touch_of_the_magi.up then
        state:QueueAuraExpiration( "touch_of_the_magi", NetherMunitions, debuff.touch_of_the_magi.expires )
    end
end )

-- Abilities
spec:RegisterAbilities( {
    -- Alters the fabric of time, returning you to your current location and health when cast a second time, or after 10 seconds. Effect negated by long distance or death.
    alter_time = {
        id = 342245,
        cast = 0,
        cooldown = function () return talent.master_of_time.enabled and 50 or 60 end,
        gcd = "off",
        school = "arcane",

        texture = 609811,

        spend = 0.01,
        spendType = "mana",
        nobuff = "alter_time",

        talent = "alter_time",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "alter_time" )
            setCooldown( "alter_time_return", 0 )
        end,

        copy = { 342247, 342245 }
    },

    alter_time_return = {
        id = 342247,
        cast = 0,
        cooldown = function () return talent.master_of_time.enabled and 50 or 60 end,
        gcd = "off",
        school = "arcane",

        texture = 985088,

        spend = 0.01,
        spendType = "mana",
        buff = "alter_time",

        talent = "alter_time",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            removeBuff( "alter_time" )
            if talent.master_of_time.enabled then setCooldown( "blink", 0 ) end
        end,

        copy = { 342247, 342245 }
    },

    -- Talent: Launches bolts of arcane energy at the enemy target, causing 1,617 Arcane damage. For each Arcane Charge, deals 36% additional damage and hits 1 additional nearby target for 40% of its damage. Consumes all Arcane Charges.
    arcane_barrage = {
        id = 44425,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        startsCombat = true,

        -- TODO: Determine if I need to separate what is consumed/built on impact vs. on cast.
        -- velocity = 24,
        handler = function ()
            gain( 0.02 * mana.modmax * arcane_charges.current, "mana" )

            spend( arcane_charges.current, "arcane_charges" )
            removeBuff( "arcane_harmony" )
            removeBuff( "bursting_energy" )

            if buff.burden_of_power.up then
                removeBuff( "burden_of_power" )
                applyBuff( "glorious_incandescence" )
            elseif buff.glorious_incandescence.up then
                gain( 4, "arcane_charges")
                removeBuff( "glorious_incandescence" )
            end

            if talent.spellfire_spheres.enabled then
                if buff.next_blast_spheres.stacks == 5 then
                    removeBuff( "next_blast_spheres" )
                    addStack( "spellfire_spheres" )
                    applyBuff( "burden_of_power" )
                else addStack( "next_blast_spheres" )
                end
            end

            if buff.arcane_soul.up then
                addStack( "clearcasting" )
                gain( 4, "arcane_charges" )
                addStack( "arcane_soul_damage_buff" )
            end

            if buff.intuition.up then
                gain( 4, "arcane_charges" )
                removeBuff( "intuition" )
            end

            --[[if buff.aethervision.up then
                gain( 2*buff.aethervision.stacks, "arcane_charges" )
                removeBuff( "aethervision" )
            end--]]

            if buff.nether_precision.up then
                removeStack( "nether_precision" )
                if talent.dematerialize.enabled then applyDebuff( "target", "dematerialize" ) end
            end

            if debuff.magis_spark_arcane_barrage.up then
                removeDebuff( "target", "magis_spark_arcane_barrage" )
            end
        end,
    },

    -- Blasts the target with energy, dealing 1,340 Arcane damage. Each Arcane Charge increases damage by 72% and mana cost by 100%, and reduces cast time by 8%. Generates 1 Arcane Charge.
    arcane_blast = {
        id = 30451,
        cast = function ()
            if buff.presence_of_mind.up then return 0 end
            return 2.25 * ( 1 - ( 0.08 * arcane_charges.current ) ) * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function ()
            -- More mana trickery to achieve the correct rotation
           -- if buff.concentration.up then return 0 end
            local mult = 0.0275 * ( 1 + arcane_charges.current ) * ( talent.consortiums_bauble.enabled and 0.95 or 1 )
            -- if azerite.equipoise.enabled and mana.pct < 70 then return ( mana.modmax * mult ) - 190 end
            return mana.modmax * mult, "mana"
        end,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            if buff.presence_of_mind.up then
                removeStack( "presence_of_mind" )
                if buff.presence_of_mind.down then setCooldown( "presence_of_mind", 60 ) end
            end

            -- removeBuff( "concentration" )
            removeBuff( "leydrinker" )

            if buff.burden_of_power.up then
                removeBuff( "burden_of_power" )
                applyBuff( "glorious_incandescence" )
            end

            if talent.spellfire_spheres.enabled then
                if buff.next_blast_spheres.stacks == 5 then
                    removeBuff( "next_blast_spheres" )
                    addStack( "spellfire_spheres" )
                    applyBuff( "burden_of_power" )
                else addStack( "next_blast_spheres" )
                end
            end

            if buff.nether_precision.up then
                removeStack( "nether_precision" )
                if talent.dematerialize.enabled then applyDebuff( "target", "dematerialize" ) end
                -- if talent.aethervision.enabled then addStack( "aethervision" ) end
            end

            if debuff.magis_spark_arcane_blast.up then
                removeDebuff( "target", "magis_spark_arcane_blast" )
            end

            if arcane_charges.current == arcane_charges.max then
                applyBuff( "arcane_blast_overcapped" )
                if talent.arcane_echo.enabled then echo_opened = true end
            end -- Use this to catch "5th" cast of Arcane Blast.
            gain( 1, "arcane_charges" )

            if set_bonus.tww3_spellslinger >= 2 then
                addStack( "arcane_harmony" )
                if buff.arcane_harmony.at_max_stacks then applyBuff( "intuition" ) end
            end
        end,
    },

    -- Causes an explosion of magic around the caster, dealing 1,684 Arcane damage to all enemies within 10 yards. Generates 1 Arcane Charge if any targets are hit.
    arcane_explosion = {
        id = 1449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function ()
            if not pvptalent.arcane_empowerment.enabled and buff.clearcasting.up then return 0 end
            return 0.1
        end,
        spendType = "mana",

        startsCombat = true,

        usable = function () return not settings.check_explosion_range or target.maxR < 10, "target out of range" end,
        handler = function ()
            if buff.expanded_potential.up then removeBuff( "expanded_potential" )
            else
                if buff.clearcasting.up then
                    if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                    else removeStack( "clearcasting" ) end
                    if talent.aether_attunement.enabled then
                        if buff.aether_attunement_stack.stack == 2 then
                            removeBuff( "aether_attunement_stack" )
                            applyBuff( "aether_attunement" )
                        else
                            addStack( "aether_attunement_stack" )
                        end
                    end
                    if talent.arcane_debilitation.enabled then addStack( "arcane_debilitation" ) end
                    if conduit.nether_precision.enabled or talent.nether_precision.enabled then addStack( "nether_precision", nil, 2 ) end
                    if set_bonus.tier31_2pc > 0 then addStack( "forethought" ) end
                    if set_bonus.tier31_4pc > 0 then
                        if buff.arcane_battery.stack == 2 then
                            removeBuff( "arcane_battery" )
                            applyBuff( "arcane_artillery" )
                        else
                            addStack( "arcane_battery" )
                        end
                    end
                end
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
            end
            if talent.static_cloud.enabled then
                if buff.static_cloud.stack == 4 then
                    removeStack( "static_cloud", nil, 3 )
                else
                    addStack( "static_cloud" )
                end
            end
            gain( 1, "arcane_charges" )
        end,
    },

    --[[ Talent: Summon a Familiar that attacks your enemies and increases your maximum mana by 10% for 1 |4hour:hrs;.
    arcane_familiar = {
        id = 205022,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "arcane",

        talent = "arcane_familiar",
        startsCombat = false,
        nobuff = "arcane_familiar",
        essential = true,

        handler = function ()
            if buff.arcane_familiar.down then mana.max = mana.max * 1.10 end
            applyBuff( "arcane_familiar" )
        end,

        copy = "summon_arcane_familiar"
    }, ]]

    -- Infuses the target with brilliance, increasing their Intellect by 5% for 1 |4hour:hrs;. If the target is in your party or raid, all party and raid members will be affected.
    arcane_intellect = {
        id = 1459,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        nobuff = "arcane_intellect",
        essential = true,

        handler = function ()
            applyBuff( "arcane_intellect" )
            if talent.arcane_familiar.enabled then
                if buff.arcane_familiar.down then mana.max = mana.max * 1.10 end
                applyBuff( "arcane_familiar" )
            end
        end,
    },

    -- Talent: Launches five waves of Arcane Missiles at the enemy over 2.2 sec, causing a total of 5,158 Arcane damage.
    arcane_missiles = {
        id = 5143,
        cast = function () return ( talent.concentrated_power.enabled and buff.clearcasting.up and 0.8 or 1 ) * 2.5 * haste end,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = function ()
            if buff.clearcasting.up then return 0 end
            return 0.15
        end,
        spendType = "mana",

        talent = "arcane_missiles",
        startsCombat = true,
        buff = "clearcasting",

        aura = function () return buff.clearcasting_channel.up and "clearcasting_channel" or "casting" end,
        breakchannel = function ()
            removeBuff( "clearcasting_channel" )
        end,

        tick_time = function ()
            if buff.clearcasting_channel.up then return buff.clearcasting_channel.tick_time end
            return 0.5 * haste
        end,

        start = function ()
            removeBuff( "arcane_blast_overcapped" )
            removeBuff( "arcane_artillery" )

            if debuff.magis_spark_arcane_missiles.up then
                removeDebuff( "target", "magis_spark_arcane_missiles" )
            end

            if buff.clearcasting.up then
                    if buff.expanded_potential.up then removeBuff( "expanded_potential" )
                    else removeStack( "clearcasting" ) end
                    if buff.aether_attunement_stack.stack == 2 then
                        removeBuff( "aether_attunement_stack" )
                        applyBuff( "aether_attunement" )
                    else
                        addStack( "aether_attunement_stack" )
                    end
                    if talent.arcane_debilitation.enabled then addStack( "arcane_debilitation" ) end
                    if conduit.nether_precision.enabled or talent.nether_precision.enabled then addStack( "nether_precision", nil, 2 ) end
                    if set_bonus.tier31_2pc > 0 then addStack( "forethought" ) end
                    if set_bonus.tier31_4pc > 0 then
                        if buff.arcane_battery.stack > 1 then
                            removeBuff( "arcane_battery" )
                            applyBuff( "arcane_artillery" )
                        else
                            addStack( "arcane_battery" )
                        end
                    end

                if talent.amplification.enabled then applyBuff( "clearcasting_channel" ) end
                if legendary.sinful_delight.enabled then gainChargeTime( "mirrors_of_torment", 4 ) end
            end

            if buff.expanded_potential.up then removeBuff( "expanded_potential" ) end

            if talent.high_voltage.enabled then
                if buff.high_voltage.stack == 10 then
                    removeBuff( "high_voltage" )
                    gain( 1, "arcane_charges" )
                else
                    addStack( "high_voltage" )
                end
            end

            if conduit.arcane_prodigy.enabled and cooldown.arcane_surge.remains > 0 then
                reduceCooldown( "arcane_surge", conduit.arcane_prodigy.mod * 0.1 )
            end
        end,

        tick = function ()
            if talent.arcane_harmony.enabled or legendary.arcane_harmony.enabled then
                addStack( "arcane_harmony", nil, 1 )
                if buff.arcane_harmony.at_max_stacks and set_bonus.tww3_spellslinger >= 4 then applyBuff( "intuition" ) end
            end
        end,
    },

    -- Talent: Launches an Arcane Orb forward from your position, traveling up to 40 yards, dealing 2,997 Arcane damage to enemies it passes through. Grants 1 Arcane Charge when cast and every time it deals damage.
    arcane_orb = {
        id = 153626,
        cast = 0,
        charges = function() if talent.charged_orb.enabled then return 2 end end,
        cooldown = 20,
        recharge = function() if talent.charged_orb.enabled then return 20 end end,
        gcd = "spell",
        school = "arcane",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,

        velocity = 30,

        start = function ()
            gain( 1, "arcane_charges" )
            applyBuff( "arcane_orb" )
        end,

        impact = function ()
            gain( true_active_enemies, "arcane_charges" )
            if set_bonus.tww3_spellslinger >= 4 then
                addStack( "arcane_harmony", min( 8, true_active_enemies ) )
                if buff.arcane_harmony.at_max_stacks then applyBuff( "intuition" ) end
            end
        end
    },

    -- Talent: Expend all of your current mana to annihilate your enemy target and nearby enemies for up to ${$s1*$s2} Arcane damage based on Mana spent. Deals reduced damage beyond $s3 targets.; For the next $365362d, your Mana regeneration is increased by $365362s3% and spell damage is increased by $365362s1%.
    arcane_surge = {
        id = 365350,
        cast = 2.5,
        cooldown = 90,
        gcd = "spell",
        school = "arcane",

        -- Mana cap for arcane surge this tier is 2,900,001 mana
        spend = function() return min( mana.current, 2900001 ) end,
        spendType = "mana",

        talent = "arcane_surge",
        startsCombat = true,
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "arcane_surge" )
            addStack( "clearcasting" )
            mana.regen = mana.regen * 5.25
            -- trick addon into thinking you have enough mana to cast arcane blast right after, because in reality you do
            gain ( mana.modmax * 0.25, "mana" )
            -- forecastResources( "mana" )
            -- if talent.rune_of_power.enabled then applyBuff( "rune_of_power" ) end
            -- start_burn_phase()

        end,

        copy = "arcane_power"
    },


    arcanosphere = {
        id = 353128,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "arcanosphere",
        startsCombat = false,
        texture = 4226155,

        handler = function ()
        end,
    },


    blink = {
        id = function () return talent.shimmer.enabled and 212653 or 1953 end,
        cast = 0,
        charges = function () if talent.shimmer.enabled then return 2 end end,
        cooldown = function () return ( talent.shimmer.enabled and 25 or 15 ) - conduit.flow_of_time.mod * 0.001 - ( 2 * talent.flow_of_time.rank ) end,
        recharge = function () if talent.shimmer.enabled then return ( 25 - conduit.flow_of_time.mod * 0.001 - talent.flow_of_time.rank * 2 ) end end,
        gcd = "off",
        icd = 6,

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = function () return talent.shimmer.enabled and 135739 or 135736 end,

        handler = function ()
            if talent.displacement.enabled then applyBuff( "displacement_beacon" ) end
            if talent.tempest_barrier.enabled then applyBuff( "tempest_barrier" ) end
            if talent.temporal_velocity.enabled then applyBuff( "temporal_velocity" ) end
        end,

        copy = { 212653, 1953, "shimmer", "blink_any", "any_blink" }
    },

    -- Counters the enemy's spellcast, preventing any spell from that school of magic from being cast for 6 sec.
    counterspell = {
        id = 2139,
        cast = 0,
        cooldown = function () return 24 - ( conduit.grounding_surge.mod * 0.1 ) end,
        gcd = "off",
        school = "arcane",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        toggle = "interrupts",
        debuff = function () return not runeforge.disciplinary_command.enabled and "casting" or nil end,
        readyTime = function () if debuff.casting.up then return state.timeToInterrupt() end end,

        handler = function ()
            interrupt()
            if talent.quick_witted.enabled then reduceCooldown( "counterspell", 4 ) end
        end,
    },

    -- Talent: Teleports you back to where you last Blinked. Only usable within 8 sec of Blinking.
    displacement = {
        id = 389713,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "arcane",

        talent = "displacement",
        startsCombat = false,
        buff = "displacement_beacon",

        handler = function ()
            gain( 0.2 * health.max, "health" )
            removeBuff( "displacement_beacon" )
        end,
    },

    -- Talent: Increases your mana regeneration by 750% for 5.3 sec.
    evocation = {
        id = 12051,
        cast = 3,
        charges = 1,
        cooldown = 90,
        recharge = 90,
        gcd = "spell",
        school = "arcane",

        channeled = true,
        fixedCast = true,

        talent = "evocation",
        startsCombat = false,
        toggle = "cooldowns",

        aura = "evocation",
        tick_time = function () return 0.5 * haste end,

        start = function ()
            applyBuff( "evocation" )
            addStack( "clearcasting" )
            if azerite.brain_storm.enabled then
                gain( 2, "arcane_charges" )
                applyBuff( "brain_storm" )
            end

            mana.regen = mana.regen * ( 8.5 / haste )
        end,

        tick = function ()
            addStack( "siphon_storm", nil, 1 )
        end,

        finish = function ()
            mana.regen = mana.regen / ( 8.5 * haste )
        end,

        breakchannel = function ()
            removeBuff( "evocation" )
            mana.regen = mana.regen / ( 8.5 * haste )
        end,
    },


    focus_magic = {
        id = 321358,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135754,

        talent = "focus_magic",

        usable = function () return active_dot.focus_magic == 0 and group, "can apply one in a group" end,
        handler = function ()
            applyBuff( "focus_magic" )
        end,
    },

    -- Blasts enemies within 12 yds of you for 45 Frost damage and freezes them in place for 6 sec. Damage may interrupt the freeze effect.
    frost_nova = {
        id = 122,
        cast = 0,
        charges = function () if talent.ice_ward.enabled then return 2 end end,
        cooldown = 30,
        recharge = function () if talent.ice_ward.enabled then return 30 end end,
        gcd = "spell",
        school = "frost",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        usable = function () return not state.spec.frost or target.maxR < 12, "target out of range" end,
        handler = function ()
            applyDebuff( "target", "frost_nova" )
            if talent.bone_chilling.enabled then addStack( "bone_chilling" ) end
            if legendary.grisly_icicle.enabled then applyDebuff( "target", "grisly_icicle" ) end
        end,
    },

    greater_invisibility = {
        id = 110959,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        toggle = "defensives",
        defensive = true,

        startsCombat = false,
        texture = 575584,

        handler = function ()
            applyBuff( "greater_invisibility" )
            if conduit.incantation_of_swiftness.enabled or talent.incantation_of_swiftness.enabled then applyBuff( "incantation_of_swiftness" ) end
        end,
    },

    -- Talent: Encases you in a block of ice, protecting you from all attacks and damage for 10 sec, but during that time you cannot attack, move, or cast spells. While inside Ice Block, you heal for 40% of your maximum health over the duration. Causes Hypothermia, preventing you from recasting Ice Block for 30 sec.
    ice_block = {
        id = 45438,
        cast = 0,
        cooldown = function () return 240 + ( conduit.winters_protection.mod * 0.001 ) - 30 * talent.winters_protection.rank end,
        gcd = "spell",
        school = "frost",

        talent = "ice_block",
        notalent = "ice_cold",
        startsCombat = false,
        nodebuff = "hypothermia",
        toggle = "defensives",

        handler = function ()
            applyBuff( "ice_block" )
            applyDebuff( "player", "hypothermia" )
        end,
    },

    -- Talent: Ice Block now reduces all damage taken by $414658s8% for $414658d but no longer grants Immunity, prevents movement, attacks, or casting spells. Does not incur the Global Cooldown.
    ice_cold = {
        id = 414658,
        known = 45438,
        cast = 0,
        cooldown = function () return 240 + ( conduit.winters_protection.mod * 0.001 ) - 30 * talent.winters_protection.rank end,
        gcd = "spell",
        school = "frost",

        talent = "ice_cold",
        startsCombat = false,
        nodebuff = "hypothermia",
        toggle = "defensives",

        handler = function ()
            applyBuff( "ice_cold" )
            applyDebuff( "player", "hypothermia" )
        end,
    },

    -- Talent: Makes your next Mage spell with a cast time shorter than 10 sec castable while moving. Unaffected by the global cooldown and castable while casting.
    ice_floes = {
        id = 108839,
        cast = 0,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "off",
        dual_cast = true,
        school = "frost",

        talent = "ice_floes",
        startsCombat = false,

        handler = function ()
            addStack( "ice_floes" )
        end,
    },

    -- Talent: Causes a whirl of icy wind around the enemy, dealing 2,328 Frost damage to the target and reduced damage to all other enemies within 8 yards, and freezing them in place for 2 sec.
    ice_nova = {
        id = 157997,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "frost",

        talent = "ice_nova",
        startsCombat = false,

        handler = function ()
            applyBuff( "ice_nova" )
        end,
    },


    ice_wall = {
        id = 352278,
        cast = 1.5,
        cooldown = 90,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        pvptalent = "ice_wall",
        startsCombat = false,
        texture = 4226156,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    -- Cast $?c1[Prismatic]?c2[Blazing]?c3[Ice][] Barrier on yourself and $414661i nearby allies.
    mass_barrier = {
        id = 414660,
        cast = 0.0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.08,
        spendType = 'mana',

        talent = "mass_barrier",
        startsCombat = false,

        handler = function ()
            if state.spec.arcane then applyBuff( "prismatic_barrier" )
            elseif state.spec.fire then applyBuff( "blazing_barrier" )
            elseif state.spec.frost then applyBuff( "ice_barrier" ) end
        end,
    },

    -- You and your allies within $A1 yards instantly become invisible for $d. Taking any action will cancel the effect.; $?a415945[]; [Does not affect allies in combat.]
    mass_invisibility = {
        id = 414664,
        cast = 0.0,
        cooldown = function() return pvptalent.improved_mass_invisibility.rank and 60 or 300 end,
        gcd = "spell",

        spend = 0.060,
        spendType = 'mana',

        talent = "mass_invisibility",
        startsCombat = false,

        handler = function()
            applyBuff( "mass_invisibility" )
        end,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INVISIBILITY, 'points': 200.0, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': 1.0, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCREEN_EFFECT, 'value': 1421, 'schools': ['physical', 'fire', 'nature'], 'value1': 7, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #3: { 'type': SANCTUARY_2, 'subtype': NONE, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_CASTER_AREA_RAID, }

        -- Affected by:
        -- improved_mass_invisibility[415945] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -240000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Talent: Transforms all enemies within 10 yards into sheep, wandering around incapacitated for 1 min. While affected, the victims cannot take actions but will regenerate health very quickly. Damage will cancel the effect. Only works on Beasts, Humanoids and Critters.
    mass_polymorph = {
        id = 383121,
        cast = 1.7,
        cooldown = 60,
        gcd = "spell",
        school = "arcane",

        spend = 0.04,
        spendType = "mana",

        talent = "mass_polymorph",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mass_polymorph" )
        end,
    },

    -- Talent: Creates 3 copies of you nearby for 40 sec, which cast spells and attack your enemies. While your images are active damage taken is reduced by 20%. Taking direct damage will cause one of your images to dissipate.
    mirror_image = {
        id = 55342,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "arcane",

        spend = 0.02,
        spendType = "mana",

        talent = "mirror_image",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "mirror_image", nil, 3 )
        end,
    },


    polymorph = {
        id = 118,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 136071,

        handler = function ()
        end,
    },

    -- Talent: Causes your next 2 Arcane Blasts to be instant cast.
    presence_of_mind = {
        id = 205025,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "arcane",

        talent = "presence_of_mind",
        startsCombat = false,
        nobuff = "presence_of_mind",

        handler = function ()
            applyBuff( "presence_of_mind", nil, 2 )
        end,
    },

    -- Talent: Shields you with an arcane force, absorbing 8,622 damage and reducing magic damage taken by 15% for 1 min. The duration of harmful Magic effects against you is reduced by 25%.
    prismatic_barrier = {
        id = 235450,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "arcane",

        spend = 0.03,
        spendType = "mana",

        talent = "prismatic_barrier",
        startsCombat = false,

        handler = function ()
            applyBuff( "prismatic_barrier" )
            if legendary.triune_ward.enabled then
                applyBuff( "blazing_barrier" )
                applyBuff( "ice_barrier" )
            end
        end,
    },

    -- Talent: Removes all Curses from a friendly target.
    remove_curse = {
        id = 475,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "arcane",

        spend = 0.013,
        spendType = "mana",

        talent = "remove_curse",
        startsCombat = false,
        debuff = "dispellable_curse",

        handler = function ()
            removeDebuff( "player", "dispellable_curse" )
        end,
    },


    ring_of_fire = {
        id = 353082,
        cast = 2,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        pvptalent = "ring_of_fire",
        startsCombat = false,
        texture = 4067368,

        handler = function ()
        end,
    },

    -- Talent: Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 65% for 4 sec.
    ring_of_frost = {
        id = 113724,
        cast = 2,
        cooldown = 45,
        gcd = "spell",
        school = "frost",

        spend = 0.08,
        spendType = "mana",

        talent = "ring_of_frost",
        startsCombat = true,

        handler = function ()
        end,
    },

    --[[ Talent: Teleports you 20 yards forward, unless something is in the way. Unaffected by the global cooldown and castable while casting. Gain a shield that absorbs 3% of your maximum health for 15 sec after you Shimmer.
    shimmer = {
        id = 212653,
        cast = 0,
        charges = 2,
        cooldown = function() return 25 - talent.flow_of_time.rank * 2 end,
        recharge = function() return 25 - talent.flow_of_time.rank * 2 end,
        gcd = "off",
        school = "arcane",

        spend = 0.02,
        spendType = "mana",

        talent = "shimmer",
        startsCombat = false,

        handler = function ()
            applyBuff( "shimmer" )
        end,
    }, ]]

    -- Talent: Reduces the target's movement speed by 50% for 15 sec.
    slow = {
        id = 31589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = 0.01,
        spendType = "mana",

        talent = "slow",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "slow" )
        end,
    },

    -- Talent: Steals a beneficial magic effect from the target. This effect lasts a maximum of 2 min.
    spellsteal = {
        id = 30449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "arcane",

        spend = 0.21,
        spendType = "mana",

        talent = "spellsteal",
        startsCombat = true,
        debuff = "stealable_magic",

        handler = function ()
            applyBuff( "time_warp" )
            applyDebuff( "player", "temporal_displacement" )
        end,
    },

    -- Talent: Pulses arcane energy around the target enemy or ally, dealing 748 Arcane damage to all enemies within 8 yards, and knocking them upward. A primary enemy target will take 100% increased damage.
    supernova = {
        id = function() return talent.gravity_lapse.enabled and 449700 or 157980 end,
        cast = 0,
        cooldown = function() return talent.gravity_lapse.enabled and 30 or 45 end,
        gcd = "spell",
        school = "arcane",

        talent = "supernova",
        startsCombat = false,

        handler = function ()
            if talent.gravity_lapse.enabled then
                applyDebuff( "target", "gravity_lapse" )
                return
            end

            applyDebuff( "target", "supernova" )
            removeBuff( "unerring_proficiency" )
        end,

        copy = { 157980, "gravity_lapse", 449700 }
    },


    temporal_shield = {
        id = 198111,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "temporal_shield",
        startsCombat = false,

        handler = function ()
            applyBuff( "temporal_shield" )
        end,
    },

    -- Warp the flow of time, increasing haste by 30% for all party and raid members for 40 sec. Allies will be unable to benefit from Bloodlust, Heroism, or Time Warp again for 10 min.
    time_warp = {
        id = 80353,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        spend = 0.04,
        spendType = "mana",

        nobuff = "bloodlust",
        startsCombat = false,
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "time_warp" )
            applyDebuff( "player", "temporal_displacement" )
        end,
    },

    -- Talent: Applies Touch of the Magi to your current target, accumulating 20% of the damage you deal to the target for 10 sec, and then exploding for that amount of Arcane damage to the target and reduced damage to all nearby enemies. Generates 4 Arcane Charges.
    touch_of_the_magi = {
        id = 321507,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "arcane",
        -- More mana trickery
        -- spend = function () return buff.arcane_surge.up and 0 or 0.05 end,
        spend = 0.05,
        spendType = "mana",

        talent = "touch_of_the_magi",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "touch_of_the_magi" )
            if talent.nether_munitions.enabled then
                state:QueueAuraEvent( "touch_of_the_magi", NetherMunitions, debuff.touch_of_the_magi.expires, "AURA_EXPIRATION" )
            end
            if talent.magis_spark.enabled then
                applyDebuff( "target", "magis_spark_arcane_barrage" )
                applyDebuff( "target", "magis_spark_arcane_blast" )
                applyDebuff( "target", "magis_spark_arcane_missiles" )
            end
            if talent.leydrinker.enabled then
                applyBuff( "leydrinker" )
            end
            gain( 4, "arcane_charges" )
        end,
    },
} )

spec:RegisterRanges( "arcane_blast", "polymorph", "fire_blast" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageExpiration = 6,

    potion = "tempered_potion",

    package = "Arcane",
} )

spec:RegisterSetting( "check_explosion_range", true, {
    name = strformat( "%s: Range Check", Hekili:GetSpellLinkWithTexture( spec.abilities.arcane_explosion.id ) ),
    desc = strformat( "If checked, %s will not be recommended when you are more than 10 yards from your target.", Hekili:GetSpellLinkWithTexture( spec.abilities.arcane_explosion.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "cancel_pom", false, {
    name = strformat( "Cancel %s", Hekili:GetSpellLinkWithTexture( spec.abilities.presence_of_mind.id ) ),
    desc = strformat( "If checked, canceling %s (icon with a red X) may be recommended during the opener with cooldowns. " ..
                      "\n\nThis behavior is consistent with the SimulationCraft priority but may feel awkward or incorrect. The DPS impact is minor.", Hekili:GetSpellLinkWithTexture( spec.abilities.presence_of_mind.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterPack( "Arcane", 20250812, [[Hekili:T3tdVTTrw(Bjyb0kL4OOpSDslSvqAtx0w0MuCo3vC4WzAkkklEHIul)WoEHH(TFV3BMHC(MuojTPyZHBBseho8nVV)IpE50lF3LxSkSk(Y3mBYStM8IPZgp5fZEX0lVO6UDXxEXUWO3hEn8xYc3c)3xvefMr)8DP5HRW7UmVUic(Pnvv7k)2N9SRtQ2uVCCu(2NvMSTonSkjplQiCDf(VJE2Y08LpRAt8THf3clnj7zVkcxYVvKKxKuD3VKuwv(SvXRdRtRE2w4Hhesp1X4TF5flRtsR(PSlxAdWF(jZaiAxC0LV5u4VTjz1Qy2sJlH79PpD)vVBt8(R(9Wc4)qp(9xDrCyzo8NZ3)Z4E90jV4PtN9T7V6v)2Vax8USO9xb33Ytp95tx)nTRzYjWA(hjfLvSL(Z7)z)7)mX9E8tNDkCV)hX3Kucl(7F9(RY3fNfxa7W(REZBF3pGpD6qV)QI40K4syfWo8U8QFD)vaQnj7A4xwVMDZRZHNwsfUiaXwG)i83RYbGg2G6Y4vJfp65pDYuyZF3V)7YW1v17iC5fPiYhPQrRcyGe8pEdXLeNfUmnE1LF3Lxesem4pjqmyzAyzfdfxKSJDP3LxhTbbraoqeYVgEDcdu2F1TBIZApFFxyrbqKHdaaZBtw901PjxVbWP0HcU)7YR3F1)xnIMz3V4oVOUaVVWSv8fTkp7VdRAt4nWpFC7c)(nHWklpIdl3gMaRIZCIOw6xRs2IabCLQW3hZXF)Z64A6rWrSaRvAk8VxxH)l(HKDEiiGdsjz4ntxMEOf53wIi5MBje(NL5iYh)B7YlltaK7(RIVb3kuUiVUsGBiI9AgJgIqsQ(7LiFr4Q740EGFizzDr2yGWbYqXfjHOGY61J3vexgNffhKVoaw1QX17UScKz0OOT3vvyACw14nani4M80kG0mMVW9xny)v3ecld(xJ5ShaldWceT6YlMoXGZiVyPgFX)jYW)2ILCaNtzyC3ezGli0s5zuZFeGN9x9FXaigwJXxLaOUuChUnbPmxJ3nqv5xUiEBiGBqei7rX30Sy4Cd4H5oXde2JFmQI3UlFms(gGsF5PRYVnBC8n5rKYTXCsbCrZ7Ibba8DgaCrRgVn8d7V6X7V6ezm3utzkMuHg2RrwzzmG(G)8heWadH9o8rkqfXFyxsrmEkp25PS5WWFSLi)RcmpufSNV)QrQOHkKJgzVaeEaOUoX3TFcC7TN1gmicKN4xjZwoH(YlaHR4II6DvbjB3gVkHuCnv(3VgmXeMs)y7rDibmG8WnbienTL(T)Q7Vx5kYid68IxxJXxGhikEwmQEia2IOKsKJaXmse45tua71Gyws07dqvolWhjhJnGX(W2SWQQ6S4TOWiB3I2aRHouMsuTIbOINRJbnfVjMPY63eaftbej2bYafiOtQuUfulKFlONkknz3oswjn)6eWQx4UDmBpO4wAoEf8VzQR9v8N1RAHzKKEQFskHF1on)p)y87tst(FbE53(63cwQ(X8Bb9BKstn9(OLp4SLFtCbi8vcAmtrJlKc(sudajrqwmtkjGLKtFPv()o5IzWUQCs8hIJQRIdyMoEIb3(qvfcrKgOXLvGpv7V6CYe1i2)pGTilOKtpnMCf4RO8AK5Hm(iJqfkYfRJwaC0d1xLB1Cpc0t8pRb6o4Jq5U72IyUIYGBJxsC3ItqzYUn5zbLv5fBjfHOebCXhHwljdgTAdLTw4s)cPVCuJSvVabLljdeRr)fcAOxlaTuZN0kCAa7JuucTlxObYTAsncj7uGNl6PSkMUOjluZkWN1nXbGEJTK80IZjVUKGcYNNYG)V6vxJIp2ui2coouv1UBlbSuCX7bzzBIHhYgLMNVkyDDXD4g98h(gbUVetBgUpV4HVpHGVmLvfHPbrHGWaSzFJdLmGVIbW2UTutdZpLDt(7rtNFaEMzHPLm)TA5vlrtNrX7q36RRQ3IoKTjbvaj0XaoGhlCjL7kO0n)UIKS3JAGX4qswJksRrD0rHLiThSJC3ritdjRZC7LTvAGHxJxQMOK9ldfrYtwfuXaJaHSvJW2WoelpOn7r9AXYBzwEM7fYHV(TyRc4YQTNorObXQtBT6lM(C2JM)mg3SC5fnBsJ6AABvo6TkNwLxd)saaqevNFIwcU4t3LMYQZ47lYjdoqBNvUcOmrGb286saneMvUnPQc99wZDvjOOiExErLWwd8uoEIigEx7gcbUI0tv57bWzQ5zLKpxJe0gtmYlMWjhO9siweWGw1MX7IQORo)KgwpUThHpZ5Bb3MxrUF0yesG)9IFqBXtSrEqY(XtKnv1jHKJL1WyiYvpOlbYLI1cuwaHDcRomkQiMB3xgl)aqXkNDDRGMXY1Cg9jTCg52sFWe9wirGYCHhqCNUhmcCxY2DXfRJJQcclJIZwb2hUlaS9vVvd95oSnLtSnfIDDyN(qoSEaC88Q7lI48MfxJg)kVllCxj6rXg0IyH2H1PhjYm2VWiIv2PM7IeN55a2QwT2mGeoWyIjKekCb94jw3DN8DGquCv7rxS94FlTg(JjYNANWPDEDA7cyqf)xqGOJiwAIkV95AHFqkWVtODv3VPUpACnFyGfbv5bRsIz2PorO0unCeoCnojlGL9mjac0TnzmxLPuSMsxzKIF2g8c(KpKC5EImxJppv8gvKK6fNbwlRo2JZmQWwxPSWwgCSbAmXCZZ3srQzgjZAXEsr5zRsAuL5273gEu9BJCMnF9A8rIXg26zG(j5RPH9lI0WI0z9atCLNd8u3KU99xHPGNrfO9e)zw(lFnI5wIWdGgAJUacdct)bOXOIrOJq3GQgV)kapKSTe)HSsytb3IWvg)be5k9azHD8U3(UFLLg2V)1JLs9aS9bS)raczpGKNmJYfstEr6Hdg(UdNjQu5MyvYGle2wldmHj6ozBK6BI5cJxf8fb42IlfotckTHaeIQuKanrqsp5Y6mrSZZ0DTwjhmFgE0uUGadrxZp3kzks3EMC2IQOWWzCrgPIIFJyYmttbVxSLoknlDyfiCyRtOMmmhmZrM8cOCD1MkSlMzl)vDBa9BSJGbWhWibrPXGYPwKRhiXsEHoGdfJS0CyMylVoDFyAsp21PHy(UZbNkxgUs48FB2ZsUgmykee3Hfu9oTL4Wh7osdNYfDe)O2QC7FR2cH)m693IPdh4SwLgxIPgxhEYRbUTQkK2vuVu)qTUoduudMibACP(boNz7e29Iv6xCDAybaB5Lb7ssZRc4M8ouKQtNYBzgCLfdB5N7Rme)LJHqMuRg9JT8MEaeyQ26mu)8jtMObkfHvRdbuqv(hs0jzOM)SeKMSnmleypqAIoI66yqxhWsUcPSL7GdFW7JVthRal4ActNuvdNST1R03M88GLGTMGRbSx4kD2WS8Rbyzn(FlcafHjBbh(cwfNw)b9LEDyXsWI0wsaQmap9qSmL5f6uHTHRca3cb6lE(wrL8vLuchTLfC(64On56BayFnDviCXQC0zs9dK85rH86oLK2YTnpAFRedP0yy)6wsVD38oy1KLIaXUWzqJjEqoOSYA6h9NUWoZozt(eflCBsrrErqYwdxomZnwNjjPpzaYwIJS5vGrTRmDukvGKCxKOU3m56Dx16DONoSPCtYAsj3U8BrCUsme)dm(GlyBceAWf81U)QFdxm6mp6VFtyr)DSHbOqhQr5DE8wXRrChlYHWS7KQ)WyZ086PiyMjz8aQpwxPN)KUJFxA1njF0mzUTxt5OawtAbgX5e8XTMc)MFjubH514Pxs7xLFMO8fVeX8s9A4MCRh9GAV0aCZmJ5VJSbtSOTWIrJ)0MQ7PnzpbFUY1LetXbRwcCTh67InNX7ro4uY5utCDdCLKhoo1o0jWv2anxznft1GC)2CcQdnc8hF8KtKpa8SQzG7O8WvMa)ebfWTn9eBUYRiE(7k5x5cGhJfwF9UJ4veuVRneTUKLw3aZpb20sSe3KGjPimTeUlWayDbj1tz(igZcd7zXIRFoeqpeTtbYfclBSHQT2gRrRAsoY9MGQfjVRYsbYcvU(Dz5dToM4yw3wA8i48VJ6vN04UlHA7IgB9lKfVXJS2sy8tNZiQT41NRyVvyA4DbBY)kUPBUOeR9tcvlSCpbugqvDiQrpCjLJkKdI1Xxhr5gcVjZ2YXOV6oExeWVmdUfSI1I2kJspMU(F5JVshXzEb58Y0qEh9avHQSh2CXsbk5wHZlw2KvC(sTQtzbPou7qSjSyBE2DcwoSBnM(cHTHHw3K5IlZF(OpRzO2C1kr6T7kLkYOh5p3xxrdVmQ2ZkN5qGUDfZBQ6TpMDD3uBfZCQUPhIXdgYilw7iU7VFOkHyX8bdFehdtAStZZ3D)96uKrJg5r9GQ0UnLCGKsWY8S6YXvsDXo4Yj2n1bZcirQgokdqxVns9N8unLJZjLJWFzkw4Mh3j3yRpUnieRmKwyxhjr3DOQ0iIbD)f5oeGNkw4LVpq2BfbUOFlwgTmuXTQNOQLXHZnTYf8dDA8DROi4kCkdkTeEzr9wIOZfLiYPKNOGAMCx8kBj5MYmhHHO1tWm)(q38JVjUqr7o5HpXRcodxKVD)v)sZbIvzhSGqyzmUaX3CFt41VjL1dt0VZSSGvubSM82FyCBWDhQbU26m1wCgdRsrI2cNf8cvWI8TXKZtM94ENKIUl8hss6PejJzfc09gWt9g(p0tsI)yXl1ygTgEBVqvaIwQUCnvdSKB4phw2wWrHv8kfTUollofOFH3KNGz2c7m2OqEl9(JmBAuLIIEpC1HiFgAYpf7WwUVgSFdCP4M4rc)iK6E(sLQSXOvHyL8UJ5acMtbKdhqCaV2njHgnUpcOu7)ZDIDhG0PhqjqFrSzj)0ikQh5elMJJCKjMj52C2PqfncuTRxHHE5dGdUj)U(63K8OosiHDD5mqRRZ0hnO70qfDvqTprbcGyGa)rJXmTePh9VEaZEDyWtIuSJhMjJhC5ExxOPUSXOEG8JpD3DAd6vNP1hZeoxGNyXAHZj9Y1nJoVr3kUDIbh88WX(XHEgjm3Qx6xG2B3fP(r26JAETOspvqS6h7dIzAD8sAXkhoN6mADkYl3CFIdywVJdyQdMj5(TXpxKECZkMYuZ0HWmrRrfslVftfi9Oke96qpNijzhqQmSP1By3OyVmuNjE)n6kGT(LXI)ec1PRmHy03A9YRLghwye1VRUyvmpRfZE6Xc9cLYnmKBhjABzOn53YCVT89jKhgyQ0W)N0o8DHyJwY3zLUqsH1YxInCO0WPwol5O8KwgNL0Hh1Xq5V)bW6zW5kZW5WQSsmgQPzHRnO3QufXrLRS0g3ZxiBJrC0Av9HnEuErvs9wS80iT5qYgcXcQNRhnwqZxWur(wjNmfSseJtJ2gQaZyPrqEsU)VZ7zyfOjmcWC9ANCiYgsj1dv29tkurd45qP2uHgC9kfyK9C9xsgkoVJi9T0czvi6xtqrlkl2upasVJ51j4lfdh9oUnL3)Wh2LMZsFn8d7BEz0vUn2RIiVT6y7XbjFox607AnZeCNgIXNZjNE6olV8cZCQDWGJiwGnONN1UXIfDFluGlCUTf6OTTu65RhAvf)DI1STyIxSH1Ne4lwjrgPsxyuSX28pSmSu0vIRHqrzfNq69JQKAQIuSKLnDyj1VNWFf1sZEdoZ450MEA4LH1vMSkw0JJ8TRnDfrHsnMjwqFq7Z60e0VtdPnkDgS6mA6U7q5086qXxJZ1D5FkYkCAJw7(47PYRpHmZ3NYcUo0riBpOe0BwJZdXrB4XnDgLdLtvB7Z2uXn0Bdx3gordFDjXZAnuRpNN4H2iyc9ZEFbfuyoC0uSAwATxCBtOqRImAH2mt8QbyElcVx)4Rx9hvXQTyzQeOXOFEmxjfvt1MLQWkEsqzVK4uvXYx3KDjL(IN1x6mJvWPkSUiKFvegzAJ4Tzn9Rc61rIwzpHhEJOL25RBfSx3XEwBsQ4knTbRSUzxVj3rgTXFrxu(MxBb9MNLUHw3bHiAkkiZof5RtIsGZWDMnjtFQR)h9PZkOi5uH0OmPSExCrw(nH2k4FNUJsUH2KDBSc(nz3U)ECEST6sFyoCknDqq2uJIg)jVyV9Oc4THRBoqlSv6AecevOMhsKRciGv0MQdNO18yNvkZ444KilAdRzi0PaFclx3CprXnqPmI3E7mwz7SvD7haDMJskzOS8cXeHHCaFxtU3vELFWCSqQRctk0zg(tT(jcBAh(R5L9fcGWZpHZG(GcI7vzvGgJDTk4LCS86cWXvQImu12Ol3oEX4nzbr07NWVAY75lXs7jmBIopLLstphlnT162Ak)j3ZqO3x5rCJBVpoENJHlZrsIHkzFPrASQGNFhSSp2fYPI)iiH75dNMY(LRVHEe3SBut2H4Uy0T7a1Z7dpN59mYvzGfe1MIv3rMK1ZOt)1pjZyznRJnqzV64bf31nFRypXJ2W)6MHu9iSTL0BrAOwt6GBcHSJbCg6ryCcx(WICcLDCYuy1gmQ88mRsTJXXmy0MyKN6vV9h6LyuxjM0QyMbFBNcJ2T1oYwOVwYb3Fv5yEqDcaPsUXmJPTd90(5PiZDvclL0jQ0(lhCNP8RH4C2bufYfbctVneF3si0oz(K66KhzTCW9y)TgkyBllWYSOflvIoGa)78UNH8jgJp7AAX74ZIuMBrQpdtSVRqL8yZgdkz6PDWN7S6duyX2QCBVyMu8vu8EbCDoHZinv1zu22yXMIVpkC1rmfvuenKBFkycCDnv5D6eJJMw2RoKIqmYA9f7zOxWJ7I35YXew(MxrhQJeEjZBBg2Bg(r8ZUiUJyuSwnJMkObBKkJdSFB0NQB3NXvSIqqk29nXVg5ssc3YT8eSUGH6ctzQRhl8g(JSEFAg0Yr0VYOQT1RoEBKT31qdioJLk4n6nTeYFULuRGjC528IQn8GzWRSjhROa5bj5Pnza0h1zHAhW6xkS38RM5GZI0)qAQPWMzGO4YJjkEpCG3OEBd7kbPidH5Lj6Zip(gR27shudh4ZzB711ZdnsqIg2lQuVrIozV7r198NNhsHkvvr0cJsJ35xzrFAg9ZAc2ZB2MDBysusxD5GNl4g6b6ZBPf9QTWCCJiufOP(WMpV8Knqknu8x(q8E9JshGhhxDeDJ1Ql2j7u7ysM5JF41xdoGwcaUOU1SryahzeIDUzvfQhe8LVCFBF62hUTHwZQRLcRQYIn0hx2OdLB6b5xSIThMii6i3nHjP4gDG4HEq)7PnG2k3EONOFYBuH0iSH7CwOKqKW7ePKm3u7u1ycjJJV53gFism9aV4pspFMwiuvxo)3NMPGi)n)gEm5JNx7EMGWhj7KLBnibCdWl10ss0qvUP4m0Ts4x3nCI5CpI5Gcgkj(ntOuTvN1gstAaTsJ6dr1FHuBqXqaQ5zuphU(Cm1xt1YL0)K1nNhKJ)9L9RNoxB2wN9ibBQL21ZlLLZL0Dxw2UcZzmAFvG2rSGTTFIflnsDQJ08bN3uomC(E1bbMv1t0vIA6rKKM05Y3HzC5M5IbzvitpMOJqAdaNXUHu16SQ(P9EyhEiEMyHT0BNVgEYKtxB2Cf(clnnRuhUvGDgZs6T714fSIiEDeCRlI3)Tkc3sJxzM)cBK4z71FLBKiYOwqRLdG56rrmf4MscdgJJ1mrdAYgdbHIAWxYNPkxhMiy3kP5PmvkwQhHX3RzE8GRJJtvFLMORX081ViV9sfD9(pIKqIY8rgtCMPzik8GMgtWOLekSDr(aTtunKdx9)WU1IpSpd7twb8K1IoD8Stu1V39USyVJbyPszbvQOG1OD6PvdL5AA)mQCWQF1dOvHF4n54nbsoXPLn8WVKN9rGA(wzHNx24gJzvVAMdjZ(M(3xGvxEbi6rQp4FSKWPEaCwWblyj4Z5wCwiJQKorqxyJHqGr7NHnVUAtEXLxCrZxZPVh)AoHDQbjWE5f)T)giD(hYN)P9)m(S0Geq9u(2TO1g8J103UV9t1eU4xdkD)wmOzXx2j8d1e7uwInEeBk48KZFghjMigTD2xLOzxoc7fNZ174LJY3DonA4oIFcoF2dDBWnHMOpN)nhLS(8h16KvsZeSRV7nsmBGOjnazFUDxZ6ivq05aj7(79o3SKUSJbrM8gOmeYKUGJjqK0kCpKGKwK1bpM8ZxBOJjDjLboM8HszyJjFd2g0y9hz5yIZ1hcQ64j7RKX)WjJ9Ii5EiJ5GIPnO4KGbLHeNmY06mhtAbogoCYBDI(GHt(21gkCYSVEgiCY7GZHbN0ImheCY0h9HaN8nQma4ubCLHzNv6L4ZlcJEzhx2hkD)MpBCQ90P9byCnpgTERYdLT(S5EgJJ(SQsSNY2XA)mfy92AUmEpM3sZnblv(RJK8V3(1qs(xzFUFiiXHgjExdO9bt4(7hAa6dC12pHRUB0iNQ8epa9pOrWJqPVzwmF(Kb2GLrJKprAF6GWJ2qtVFrWCG3xmGbQrqT48zkpM2VPq4tWSEsSb8U8n08TdQN3qZ3iOEUE1VfqEVP)g2(eFE)U)qoB2cCj0JdICN90WEKNKFOx5gWjZ11LC(q3aDxB4AMi5smN)OAyGIgsqoUTDNqSfNqiMpvFVIKjnnF8LiUXHooIdUPRpDqGq0qpcz9AdEuNlQDB8y3fGK(SmlcSC09ztNmyO7xYJftF(9376dq0IztgnA0aPJIJpViauIFQsgOOi5m4UTrD8AUaPC66PK)Q5C2Xt0zrxLh4YCwvy57ps6ne58PT7VUIwDyhptucAkUdINoceEaP(AUrdXYEjTe4PdQdX4AdYI)aadr5zqSVxtVqbRse)vT7kUaBBxY096CyfbXuBX1sBgD2C34pv94Ez4V)(Dw(q9mAGQE)ZEXeSTZ0svZzZpb4LDMQDbsYb168JNOYtSy2XtqBuhk3Id)7PJ9bDQBayvYFRSiBM9dGOBzMZo21bOhIkUpJU9XHoMwHhqBKeKAQQYoGo9JdqDegibLDLfUfVyGTCKHAC7XTEJ9V1pkmoQo6YiNIOxai0ZleNota393jkw)vY51r8Et88tWTwdl7gO0(qRWFoMF9Dwm9KbdzBIEkln(M7C25tgdIQs9Hk9lJgyXRmuDN3EhFX8jifXLb0HUYJjjzyTAu4JAKp7QIN7GUETpg4(Hp4rMqmhHnI50H1AEw)1pmnSB5Z1hMgzjbdQQP95BC8bjIiHFz)jSrjcrTpukmz)M7VFElF2ShZlXGxls2wLnbS2fQ7fLDOLpSWdcZJLcj24dgZaLxgtIq0jIGV1hX(eZWO8U2)ESBsdHaLT8r9zpv1vGb6)vLf)5PSqIXCCJ4s)uD4u))xTJ(jZoQnsJyrI8Tr79o93VEG7bfSABZqIY3mHCqEjIpwOGTJxwjbBF7y(I1k9TJ0C6YmCss78KuUJ18DAYlwkPusUTnm8uu4h40j0j0Of5(H2ppQsVt0mWLpLt9Ix5UBkWS8Fw8kspWvSbdmxTGPMBg4XN0c7tTddkjf1V1LHIDD(i)8FAl)KrTmg6JN(khV3NkDucO5GLBiStfoc7t1e(einn)Am3sH72LsnObY1KMJxb)BM6Cn7a4XEjnIxLnJiWLc50H8pigRh25a3s9hj)QNDU938mg526lE2rwE5XqDMAVWyWprVnzWFk4lMpr3XR3(63(TG4i2uOBjBbAMZ((x30pI31Mht2e2Pu0tkVlV6xrlMeUN4wFPxenHY6PttAk7zmP8oIHWApPH1ZPo4ZpEeMXB6S)VztNOw6GSBvyXnugHtmwE4)tfBl9w)C(KrgvRqQVlxm9u5eT4Xj4jJSK2a8MSK4t6N9xZbgrxDO8iYmK8B14aTFra3nJHNr9rp3IHtN9KtfoEpYUhbc)uSpuH(KcXo8KXtMr8h7bLKy108HjD2PTNfczVzONwMlJ8XHx9e9(i8Fhg7oof)IAh8rSOE09WQxoeJ(OnWUdAmfFtDcagppFjuRX9zo52HTnGNfFATLa8mNt2NbpYZm9rnUbnahPzhvghDooXpqOoKRZYaf0(r35m6dUJBDHIj0Zdaj4EqajS26Bc(4eKu9B1T)9Q(O25q6PRNNK3Pwe6f6K85fQK7F)XmcE66ij7vNdNQKD72nDVXHygsq7LvzG644zXClug(XS8bpwD66Skt(6kOXEzTE4qPgQ9jOe3OfVSX63Gdi0vRbz8CE0cFAMioha2XTNIkC4kV6KloF2Kb9OBEBfa(sBg40fcsjaiRm5UJPzWq)CCQUl8C)mgTRBe3RcZ32LftBRMP07DJC(u6ww(yFXzbp7Em4AiNavRx0jw1qmQpH99zAGJCWHmsmXFbo)zoewyBz7XcBDd3KhwEB2mgnYDE3M)xoAT2eIPl8SUUuLjFkX70Zz3sNpirEi7EUZWvvOmZzAs9Xm3rH85FIV07dPt)QDAv6SZNEQt(qWCMkxeNy)PBcU05jRLprmGxW2ysgGLYaGH)eszyq1bZ)WMnlDDa5EORJMh0hRqN2AbtAeTOghT7YtyFKSSy6yUtvFPpxv6cZkX6OPk88z(447bpKAgn0KNg(INmC6Kh)OE4QhMTKH2AwloSBlFXa44k3W8y2h5QIrSRpZBbLE4y1zUlIfGv7f6WiExVtYKUavRIwlM6rx4SjUYiMlfR3FVoV1Zh1BN8)8mls6cTirbT5HZbjR405gREWQvYVpUjlsxhtxuFn)IoBUl9LdDrZh1FkCVNpiDDACl2n9JuxgZVgV(I)PBQFCahtB8MDXj2VWnBsTPmb6RZWdBVe3ha9AOPlmMJ1dqQYwFfpWzxfBljr2CQZhRrpCLQjHbNAnPaIcLy1KPtnfC(mlSMSRW6O((Qk5VcZjJUyxAgJe21m7UjyM2KVFz9bJeOEB3YCBXQZOxMdfdQ(Uas(F3NNfFeeWZDBi6SzwKbOaguTrM9N1SQORJTSAUH21G1zpR32Il4aRa1R11DSGbuAXeipIkOChAXJvVAhBA0EFknpaftp0zlrNiDkpjDTioZdR5m(hidXf8Uj1sxyWKCAeijMlQrGRX3XybF0A8nVGbYHy0gwdMN9qo3wBqyISPKtq)8H2EcUl2o(gb0ddBtNywqEn(H860p59cHbM6HvZABHg3DrRhPhvgwNtt45pMsyB9rBweAMOEN1GUTf9yV7K)Us3hFbqkffiu0Ee6nrNOHiT4Uk2gCOB8S2AMY(sykA7iod4Jfz4KRPL9SyQtNRAqZuoXt5uTxni3UZlZ1A7309OB4Xp1Hdy9PGkpGKH78O7O(H8tcro5dHMK)vCtH4jNcKQNzcZd)72Z(iSBuJErcPTN1an)cPccIvgKvguE8CK1vFeXpbL5)a0RiL52EbrMHDONudp5aAX5tFXGHwkEIELsACJuXJuN5EJPl1(14QT6iqcBorXUY8r2v46sKZtRh4QkLEY0t3gHAkx6W5pD40XN84hCTP6Ji7xw1fJxTN2()u21BQjZqeVO7e(LMApXCUvjGDUwDUJ8PS3yE6359nUTSjziOikv0WHDxrSbDVOgVBBm()KRB7Ur9qeAqSTfzRrKrPUB(dO3LTxBf7NYQTwz8Kc5O5vBXq3OwaC0B8fexfzCTNkh9Dg(dO)AyjzgZNCZbU5nORKB)iFhCRG9gr9vwxNLfNIv2c7tQYMkEXAH(FuVUndre7EXhXyUjl2VbwMUjEKs9r)ENXeB7BVnCAbrIBscT(LzNsvg3lfStwOhag4lIk0YkgZlfSzcZrzngpyZzpKri7hjDypYzU3uY62ZgN1ZPNqMbu8jlfQUZWVJVj0T(WPgnXd8OmBGfB62oDDPTQfUSJcoSKt6trKNeg6nHG9ebzGHmnSn9apnJ82G(NPe3JDSx3kSAZZ6GoTSWmxBnBSUq7dSjD2z1qp403sCYC1RQHxjuD1QOJ08yr9fIoQOm2Phiws2bf)KUa7qRAOCr1o7yVES(xq)TulOZ3vxSkMh10SNESiNTLYDOGBlqYfD5wM7BLs5se)Fs7W3fwt10J2zL2EqH(3xdnEe0mK01Y5aVbcxshEuoKYovhCh6TBiNVW5x9F(1LdGZYlJQfvim3cZT1iklOAI0WGGV195fvj1BXXajIDTh1Ls10nRHwJ0inzgfLzM7ZYCF0JU6F(5245KcwhL0)jf8w)i(hmMVP70a39oY(7zcLwOsrrAxwNGLrKJAgBTwhryHqOMlx)2uk2bBpSEYSLIn3m2ALIx5AZgz0zcZ9GlvkuHtY3mdjPUICQBYhnVJV8))]] )