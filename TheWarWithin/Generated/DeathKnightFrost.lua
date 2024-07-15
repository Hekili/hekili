-- DeathKnightFrost.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 251 )

-- Resources
spec:RegisterResource( Enum.PowerType.RunicPower )
spec:RegisterResource( Enum.PowerType.Runes )

spec:RegisterTalents( {
    -- Death Knight Talents
    abomination_limb            = { 76049, 383269, 1 }, -- Sprout an additional limb, dealing ${$383313s1*13} Shadow damage over $d to all nearby enemies. Deals reduced damage beyond $s5 targets. Every $t1 sec, an enemy is pulled to your location if they are further than $383312s3 yds from you. The same enemy can only be pulled once every $383312d.
    antimagic_barrier           = { 76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by ${$s1/-1000} sec and increases its duration and amount absorbed by $s2%.
    antimagic_zone              = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by $145629m1%. The Anti-Magic Zone lasts for $d or until it absorbs $?a374383[${$<absorb>*1.1}][$<absorb>] damage.
    asphyxiate                  = { 76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for $d.
    assimilation                = { 76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by $s1% and its cooldown is reduced by ${$s2/-1000} sec.
    blinding_sleet              = { 76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for $d. Damage may cancel the effect.; When Blinding Sleet ends, enemies are slowed by $317898s1% for $317898d.
    blood_draw                  = { 76056, 374598, 1 }, -- When you fall below $s1% health you drain $374606s1 health from nearby enemies, the damage you take is reduced by $454871s1% and your Death Strike cost is reduced by ${$454871s2/-10} for $454871d.; Can only occur every $374609d.
    blood_scent                 = { 76078, 374030, 1 }, -- Increases Leech by $s1%.
    brittle                     = { 76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal $374557s1% increased damage for $374557d.
    cleaving_strikes            = { 76073, 316916, 1 }, -- $?a137008[Heart Strike hits up to $s3]?a137006[Obliterate hits up to $s2]?s207311[Clawing Shadows][Scourge Strike]$?a137007[ hits up to ${$55090s4-1}][] additional enemies while you remain in Death and Decay. ; When leaving your Death and Decay you retain its bonus effects for ${$316916s4/1000} sec.
    coldthirst                  = { 76083, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants ${$378849s1/10} Runic Power and reduces its cooldown by ${$378849s2/-1000} sec.
    control_undead              = { 76059, 111673, 1 }, -- Dominates the target undead creature up to level $s1, forcing it to do your bidding for $d.
    death_pact                  = { 76075, 48743 , 1 }, -- Create a death pact that heals you for $s1% of your maximum health, but absorbs incoming healing equal to $s3% of your max health for $d.
    death_strike                = { 76071, 49998 , 1 }, -- Focuses dark power into a strike$?s137006[ with both weapons, that deals a total of ${$s1+$66188s1}][ that deals $s1] Physical damage and heals you for ${$s2}.2% of all damage taken in the last $s4 sec, minimum ${$s3}.1% of maximum health.
    deaths_echo                 = { 102007, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have $s1 additional charge.
    deaths_reach                = { 102006, 276079, 1 }, -- Increases the range of Death Grip by $s1 yds.; Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    enfeeble                    = { 76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by $392490s1% and the damage they deal to you by $392490s2% for $392490d.
    gloom_ward                  = { 76052, 391571, 1 }, -- Absorbs are $s1% more effective on you. 
    grip_of_the_dead            = { 76057, 273952, 1 }, -- $?s152280[Defile][Death and Decay] reduces the movement speed of enemies within its area by $s1%, decaying by $s2% every sec.
    ice_prison                  = { 76086, 454786, 1 }, -- Chains of Ice now also roots enemies for $454787d but its cooldown is increased to ${$s2/1000} sec.
    icy_talons                  = { 76085, 194878, 1 }, -- Your Runic Power spending abilities increase your melee attack speed by $s1% for $194879d, stacking up to $194879u times.
    improved_death_strike       = { 76067, 374277, 1 }, -- Death Strike's cost is reduced by $?a137008[${$s5/-10}][${$s3/-10}], and its healing is increased by $?a137008[$s4%][$s1%].
    insidious_chill             = { 76051, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by $s1% for $391568d, stacking up to $391568u times.
    march_of_darkness           = { 76074, 391546, 1 }, -- Death's Advance grants an additional $s1% movement speed over the first $338093d.
    mind_freeze                 = { 76084, 47528 , 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    null_magic                  = { 102008, 454842, 1 }, -- Magic damage taken is reduced by $s1% and the duration of harmful Magic effects against you are reduced by $s2%.
    osmosis                     = { 76088, 454835, 1 }, -- Anti-Magic Shell increases healing received by $s1%.
    permafrost                  = { 76066, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to $s1% of the damage dealt.
    proliferating_chill         = { 101708, 373930, 1 }, -- Chains of Ice affects $s1 additional nearby enemy.
    rune_mastery                = { 76079, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by $s1% for $374585d.
    runic_attenuation           = { 76045, 207104, 1 }, -- Auto attacks have a chance to generate ${$221322s1/10} Runic Power.
    runic_protection            = { 76055, 454788, 1 }, -- Your chance to be critically struck is reduced by $s2% and your Armor is increased by $s1%.
    sacrificial_pact            = { 76060, 327574, 1 }, -- Sacrifice your ghoul to deal $327611s1 Shadow damage to all nearby enemies and heal for $s1% of your maximum health. Deals reduced damage beyond $327611s2 targets.
    soul_reaper                 = { 76063, 343294, 1 }, -- Strike an enemy for $s1 Shadowfrost damage and afflict the enemy with Soul Reaper. ; After $d, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    subduing_grasp              = { 76080, 454822, 1 }, -- When you pull an enemy, the damage they deal to you is reduced by $454824s1% for $454824d.
    suppression                 = { 76087, 374049, 1 }, -- Damage taken from area of effect attacks reduced by $s1%. When suffering a loss of control effect, this bonus is increased by an additional $454886s1% for $454886d.
    unholy_bond                 = { 76076, 374261, 1 }, -- Increases the effectiveness of your Runeforge effects by $s1%.
    unholy_endurance            = { 76058, 389682, 1 }, -- Increases Lichborne duration by ${$s1/1000} sec and while active damage taken is reduced by $49039s8%.
    unholy_ground               = { 76069, 374265, 1 }, -- Gain $374271s1% Haste while you remain within your Death and Decay.
    unyielding_will             = { 76050, 457574, 1 }, -- Anti-Magic Shell's cooldown is increased by ${$s2/1000} sec and it now also removes all harmful magic effects when activated.
    vestigial_shell             = { 76053, 454851, 1 }, -- Casting Anti-Magic Shell grants $454863i nearby allies a Lesser Anti-Magic Shell that Absorbs up to $454863s1 magic damage and reduces the duration of harmful Magic effects against them by $454863s2%. 
    veteran_of_the_third_war    = { 76068, 48263 , 1 }, -- Stamina increased by $s1%.; $?s316714[Damage taken reduced by $s3%.][]
    will_of_the_necropolis      = { 76054, 206967, 2 }, -- Damage taken below $s3% Health is reduced by $s2%.
    wraith_walk                 = { 76077, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by $s1% for $d. Taking any action cancels the effect.; While active, your movement speed cannot be reduced below $m2%.

    -- Frost Talents
    a_feast_of_souls            = { 95042, 444072, 1 }, -- While you have $s1 or more Horsemen aiding you, your Runic Power spending abilities deal $440861s1% increased damage.
    absolute_zero               = { 102009, 377047, 1 }, -- Frostwyrm's Fury has $s1% reduced cooldown and Freezes all enemies hit for $377048d.
    apocalypse_now              = { 95041, 444040, 1 }, -- Army of the Dead and Frostwyrm's Fury call upon all 4 Horsemen to aid you for 20 sec.
    arctic_assault              = { 76091, 456230, 1 }, -- Consuming Killing Machine fires a Glacial Advance through your target.
    avalanche                   = { 76105, 207142, 1 }, -- Casting Howling Blast with Rime active causes jagged icicles to fall on enemies nearby your target, applying Razorice and dealing $207150s1 Frost damage.
    bind_in_darkness            = { 95043, 440031, 1 }, -- Shadowfrost damage applies 2 stacks to Reaper's Mark and 4 stacks when it is a critical strike.; Additionally, $?a137008[Blood Boil][Rime empowered Howling Blast] deals Shadowfrost damage.
    biting_cold                 = { 76111, 377056, 1 }, -- Remorseless Winter damage is increased by $s2%. The first time Remorseless Winter deals damage to $s1 different enemies, you gain Rime.
    blood_fever                 = { 95058, 440002, 1 }, -- Your $?a137008[Blood Plague][Frost Fever] has a chance to deal $s1% increased damage as Shadowfrost.
    bonegrinder                 = { 76122, 377098, 2 }, -- Consuming Killing Machine grants $377101s1% critical strike chance for $377101d, stacking up to ${$377101u-1} times. At ${$377101u-1} stacks your next Killing Machine consumes the stacks and grants you $s1% increased Frost damage for $377103d.
    breath_of_sindragosa        = { 76093, 152279, 1 }, -- Continuously deal ${$155166s2*$<CAP>/$AP} Frost damage every $t1 sec to enemies in a cone in front of you, until your Runic Power is exhausted. Deals reduced damage to secondary targets.; Generates $303753s1 $lRune:Runes; at the start and end.
    chill_streak                = { 76098, 305392, 1 }, -- Deals $204167s4 Frost damage to the target and reduces their movement speed by $204206m2% for $204206d.; Chill Streak bounces up to $m1 times between closest targets within $204165A1 yards.
    cold_heart                  = { 76035, 281208, 1 }, -- Every $t1 sec, gain a stack of Cold Heart, causing your next Chains of Ice to deal $281210s1 Frost damage. Stacks up to $281209u times.
    cryogenic_chamber           = { 76109, 456237, 1 }, -- Each time Frost Fever deals damage, $s1% of the damage dealt is gathered into the next cast of Remorseless Winter, up to $s2 times.
    dark_talons                 = { 95057, 436687, 1 }, -- $?a137008[Marrowrend and Heart Strike have][Consuming Killing Machine or Rime has] a $s1% chance to increase the maximum stacks of an active $@spellname194878 by $s2, up to $s3 times.; While Icy Talons is active, your Runic Power spending abilities also count as Shadowfrost damage.
    death_charge                = { 95060, 444010, 1 }, -- Call upon your Death Charger to break free of movement impairment effects.; For $444347d, while upon your Death Charger your movement speed is increased by 100%, you cannot be slowed, and you are immune to forced movement effects and knockbacks.
    deaths_messenger            = { 95049, 437122, 1 }, -- Reduces the cooldowns of Lichborne and Raise Dead by ${$s1/-1000} sec.
    empower_rune_weapon         = { 76110, 47568 , 1 }, -- Empower your rune weapon, gaining $s3% Haste and generating $s1 $LRune:Runes; and ${$m2/10} Runic Power instantly and every $t1 sec for $d.
    enduring_chill              = { 76097, 377376, 1 }, -- Chill Streak's bounce range is increased by $s2 yds and each time Chill Streak bounces it has a $s1% chance to increase the maximum number of bounces by $s3.
    enduring_strength           = { 76100, 377190, 1 }, -- When Pillar of Frost expires, your Strength is increased by $377195s1% for $377195d. This effect lasts ${$s2/1000} sec longer for each Obliterate and Frostscythe critical strike during Pillar of Frost.
    everfrost                   = { 76113, 376938, 1 }, -- Remorseless Winter deals $s1% increased damage to enemies it hits, stacking up to $376974u times.
    expelling_shield            = { 95049, 439948, 1 }, -- When an enemy deals direct damage to your Anti-Magic Shell, their cast speed is reduced by $440739s1% for $440739d.
    exterminate                 = { 95068, 441378, 1 }, -- After Reaper's Mark explodes, your next $?a443564[$s3 ][]$?a137008[Marrowrend][Obliterate]$?a443564[s][] costs $?a443564[$s4][no] Rune and summon$?a443564[][s] $s1 scythes to strike your enemies.; The first scythe strikes your target for $?a137008[$$441424s1][$441424s2] Shadowfrost damage and has a $?a443564[${$s2*1.5}][$s2]% chance to apply Reaper's Mark, the second scythe strikes all enemies around your target for $?a137008[$$441426s1][$441426s2] Shadowfrost damage$?(a441894&a137008)[ and applies Blood Plague]?(a441894&$a137006)[ and applies Frost Fever][]. Deals reduced damage beyond $s5 targets.
    frigid_executioner          = { 76120, 377073, 1 }, -- Obliterate deals $s2% increased damage and has a $h% chance to refund $377074m1 $Lrune:runes;.
    frost_strike                = { 76115, 49143 , 1 }, -- Chill your $?$owb==0[weapon with icy power and quickly strike the enemy, dealing $<2hDamage> Frost damage.][weapons with icy power and quickly strike the enemy with both, dealing a total of $<dualWieldDamage> Frost damage.]
    frostscythe                 = { 76096, 207230, 1 }, -- A sweeping attack that strikes all enemies in front of you for $s2 Frost damage. This attack always critically strikes and critical strikes with Frostscythe deal $s3 times normal damage. Deals reduced damage beyond $s5 targets. ; Consuming Killing Machine reduces the cooldown of Frostscythe by ${$s1/1000}.1 sec.
    frostwhelps_aid             = { 76106, 377226, 1 }, -- Pillar of Frost summons a Frostwhelp who breathes on all enemies within $s2 yards in front of you for $377245s1 Frost damage. Each unique enemy hit by Frostwhelp's Aid grants you ${$377253s1*2}% Mastery for $287338d, up to ${$s3*2*$377253u}%.; 
    frostwyrms_fury             = { 101931, 279302, 1 }, -- Summons a frostwyrm who breathes on all enemies within $s1 yd in front of you, dealing $279303s1 Frost damage and slowing movement speed by $279303s2% for $279303d.
    fury_of_the_horsemen        = { 95042, 444069, 1 }, -- Every $s1 Runic Power you spend extends the duration of the Horsemen's aid in combat by $s3 sec, up to $s2 sec.
    gathering_storm             = { 76099, 194912, 1 }, -- Each Rune spent during Remorseless Winter increases its damage by $211805s1%, and extends its duration by ${$m1/10}.1 sec.
    glacial_advance             = { 76092, 194913, 1 }, -- Summon glacial spikes from the ground that advance forward, each dealing ${$195975s1*$<CAP>/$AP} Frost damage and applying Razorice to enemies near their eruption point.
    grim_reaper                 = { 95034, 434905, 1 }, -- Reaper's Mark explosion deals up to $s1% increased damage based on your target's missing health, and applies Soul Reaper to targets below $s2% health.
    horn_of_winter              = { 76089, 57330 , 1 }, -- Blow the Horn of Winter, gaining $s1 $LRune:Runes; and generating ${$s2/10} Runic Power.
    horsemens_aid               = { 95037, 444074, 1 }, -- While at your aid, the Horsemen will occasionally cast Anti-Magic Shell on you and themselves at 80% effectiveness.; You may only benefit from this effect every $451777d.
    howling_blast               = { 76114, 49184 , 1 }, -- [55095] A disease that deals ${$o1*$<CAP>/$AP} Frost damage over $d and has a chance to grant the Death Knight ${$195617m1/10} Runic Power each time it deals damage.
    hungering_thirst            = { 95044, 444037, 1 }, -- The damage of your diseases and $?a137006[Frost Strike][Death Coil] are increased by $s1%.
    hyperpyrexia                = { 76108, 456238, 1 }, -- Your Runic Power spending abilities have a chance to additionally deal $s1% of the damage dealt over 4 sec.
    icebound_fortitude          = { 76081, 48792 , 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by $s3% for $d.
    icebreaker                  = { 76033, 392950, 2 }, -- When empowered by Rime, Howling Blast deals $s1% increased damage to your primary target.
    icecap                      = { 101930, 207126, 1 }, -- Reduces Pillar of Frost cooldown by ${$s1/-1000} sec.
    icy_death_torrent           = { 101933, 435010, 1 }, -- Your auto attack critical strikes have a chance to send out a sleet of ice dealing $439539s1  Frost damage to enemies in front of you.
    improved_frost_strike       = { 76103, 316803, 2 }, -- Increases Frost Strike damage by $s1%.
    improved_obliterate         = { 76119, 317198, 1 }, -- Increases Obliterate damage by $s1%.
    improved_rime               = { 76112, 316838, 1 }, -- Increases Howling Blast damage done by an additional $s1%.
    inexorable_assault          = { 76037, 253593, 1 }, -- Gain Inexorable Assault every $t1 sec, stacking up to $253595u times.; $?s207230[Obliterate and Frostscythe consume][Obliterate consumes] a stack to deal an additional $253597s1 Frost damage.
    killing_machine             = { 76117, 51128 , 1 }, -- Your auto attack critical strikes have a chance to make your next Obliterate$?s317214[ deal Frost damage and][] critically strike.
    mawsworn_menace             = { 95054, 444099, 1 }, -- $?a137006[Obliterate deals $s4]?s207311[Clawing Shadows deals $s3][Scourge Strike deals $s3]% increased damage and the cooldown of your $?s152280[Defile is reduced by ${$s2/-1000}][Death and Decay is reduced by ${$s1/-1000}] sec.
    mograines_might             = { 95067, 444047, 1 }, -- Your damage is increased by 5% and you gain the benefits of your Death and Decay while inside Mograine's Death and Decay.
    murderous_efficiency        = { 76121, 207061, 1 }, -- Consuming the Killing Machine effect has a $s1% chance to grant you $207062s1 Rune.
    nazgrims_conquest           = { 95059, 444052, 1 }, -- If an enemy dies while Nazgrim is active, the strength of Apocalyptic Conquest is increased by $s1%.; Additionally, each Rune you spend increase its value by $s2%.
    obliterate                  = { 76116, 49020 , 1 }, -- A brutal attack $?$owb==0[that deals $<2hDamage> Physical damage.][with both weapons that deals a total of $<dualWieldDamage> Physical damage.]$?a134735&a51128[; Damage increased by $s6% in PvP Combat when Killing Machine is not active.][]
    obliteration                = { 76123, 281238, 1 }, -- While Pillar of Frost is active, Frost Strike$?s194913[, Glacial Advance,][]$?s343294[, Soul Reaper,][] and Howling Blast always grant Killing Machine and have a $s2% chance to generate a Rune. to deal additional damage.
    on_a_paler_horse            = { 95060, 444008, 1 }, -- While outdoors you are able to mount your Acherus Deathcharger in combat.
    pact_of_the_apocalypse      = { 95037, 444083, 1 }, -- When you take damage, $s1% of the damage is redirected to each active horsemen.
    pact_of_the_deathbringer    = { 95035, 440476, 1 }, -- When you suffer a damaging effect equal to $s1% of your maximum health, you instantly cast Death Pact at $s3% effectiveness. May only occur every $s2 min.; When a Reaper's Mark explodes, the cooldowns of this effect and Death Pact are reduced by $s4 sec.
    painful_death               = { 95032, 443564, 1 }, -- Reaper's Mark deals $s1% increased damage and Exterminate empowers an additional $?a137008[Marrowrend][Obliterate], but now reduces its cost by 1 Rune.; Additionally, Exterminate now has a $s2% chance to apply Reaper's Mark.
    piercing_chill              = { 76097, 377351, 1 }, -- Enemies suffer $377359s1% increased damage from Chill Streak each time they are struck by it.
    pillar_of_frost             = { 101929, 51271 , 1 }, -- The power of frost increases your Strength by $s1% for $d.
    rage_of_the_frozen_champion = { 76120, 377076, 1 }, -- Obliterate has a $s1% increased chance to trigger Rime and Howling Blast generates ${$341725s1/10} Runic Power while Rime is active.
    reapers_mark                = { 95062, 439843, 1 }, -- Viciously slice into the soul of your enemy, dealing $?a137008[$s1][$s4] Shadowfrost damage and applying Reaper's Mark.; Each time you deal Shadow or Frost damage, add a stack of Reaper's Mark. After $434765d or reaching $434765u stacks, the mark explodes, dealing $?a137008[$436304s1][$436304s2] damage per stack.; Reaper's Mark travels to an unmarked enemy nearby if the target dies, or explodes below 35% health when there are no enemies to travel to. This explosion cannot occur again on a target for $443761d.
    riders_champion             = { 95066, 444005, 1 }, -- Spending Runes has a chance to call forth the aid of a Horsemen for $454390d.; Mograine; Casts Death and Decay at his location that follows his position.; Whitemane; Casts Undeath on your target dealing $444633s1 Shadowfrost damage per stack every $444633t sec, for $444633d. Each time Undeath deals damage it gains a stack. Cannot be Refreshed.; Trollbane; Casts Chains of Ice on your target slowing their movement speed by $444834s1% and increasing the damage they take from you by 5% for 8 sec.; Nazgrim; While Nazgrim is active you gain Apocalyptic Conquest, increasing your Strength by $444763s1%.; 
    rune_carved_plates          = { 95035, 440282, 1 }, -- Each Rune spent reduces the magic damage you take by $440290s1% and each Rune generated reduces the physical damage you take by $440289s1% for $440289d, up to $440290u times.
    runic_command               = { 76102, 376251, 2 }, -- Increases your maximum Runic Power by ${$s1/10}.
    shattered_frost             = { 76094, 455993, 1 }, -- When Frost Strike consumes $51714u Razorice stacks, it deals $s1% of the damage dealt to nearby enemies. Deals reduced damage beyond $455996s2 targets.
    shattering_blade            = { 76095, 207057, 1 }, -- When Frost Strike damages an enemy with $51714u stacks of Razorice it will consume them to deal an additional $s1% damage.
    smothering_offense          = { 76101, 435005, 1 }, -- Your auto attack damage is increased by $s2%. ; This amount is increased for each stack of Icy Talons you have and it can stack up to $s1 additional times.
    soul_rupture                = { 95061, 437161, 1 }, -- When Reaper's Mark explodes, it deals $?a137008[$s1][$s2]% of the damage dealt damage to nearby enemies.; Enemies hit by this effect deal $s3% reduced physical damage to you for 10 sec.
    swift_end                   = { 95032, 443560, 1 }, -- Reaper's Mark's cost is reduced by $s2 Rune and its cooldown is reduced by ${$s1/-1000} sec.
    the_long_winter             = { 101932, 456240, 1 }, -- While Pillar of Frost is active your auto-attack critical strikes increase its duration by $s1 sec, up to a maximum of $s2 sec.
    trollbanes_icy_fury         = { 95063, 444097, 1 }, -- $?a137006[Obliterate]?s207311[Clawing Shadows][Scourge Strike] shatters Trollbane's Chains of Ice when hit, dealing $444834s2 Shadowfrost damage to nearby enemies, and slowing them by $444834s1% for $444834d. Deals reduced damage beyond $s1 targets.
    unleashed_frenzy            = { 76118, 376905, 1 }, -- Damaging an enemy with a Runic Power ability increases your Strength by $s1% for $376907d, stacks up to $338501u times.
    wave_of_souls               = { 95036, 439851, 1 }, -- Reaper's Mark sends forth bursts of Shadowfrost energy and back, dealing $?a137008[$435802s1][$435802s2] Shadowfrost damage both ways to all enemies caught in its path.; Wave of Souls critical strikes cause enemies to take $443404s1% increased Shadowfrost damage for $443404d, stacking up to 2 times, and it is always a critical strike on its way back.
    whitemanes_famine           = { 95047, 444033, 1 }, -- When $?a137006[Obliterate]?s207311[Clawing Shadows][Scourge Strike] damages an enemy affected by Undeath it gains $s1 $Lstack:stacks; and infects another nearby enemy.
    wither_away                 = { 95057, 441894, 1 }, -- $?a137008[Blood Plague][Frost Fever] deals its damage in half the duration and the second scythe of Exterminate applies $?a137008[Blood Plague][Frost Fever].
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bitter_chill      = 5435, -- (356470) Chains of Ice reduces the target's Haste by $s1%. Frost Strike refreshes the duration of Chains of Ice.
    bloodforged_armor = 5586, -- (410301) Death Strike reduces all Physical damage taken by $410305s1% for $410305d.
    dark_simulacrum   = 3512, -- (77606 ) Places a dark ward on an enemy player that persists for $d, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    dead_of_winter    = 3743, -- (287250) After your Remorseless Winter deals damage $s4 times to a target, they are stunned for $287254d.; Remorseless Winter's cooldown is increased by ${$m1/1000} sec.
    deathchill        = 701 , -- (204080) Your Remorseless Winter and Chains of Ice apply Deathchill, rooting the target in place for 4 sec.; Remorseless Winter ; All targets within $m1 yards are afflicted with Deathchill when Remorseless Winter is cast.; Chains of Ice; When you Chains of Ice a target already afflicted by your Chains of Ice they will be afflicted by Deathchill.
    delirium          = 702 , -- (233396) Howling Blast applies Delirium, reducing the cooldown recovery rate of movement enhancing abilities by $233397s1% for $233397d.
    necrotic_aura     = 5512, -- (199642) All enemies within $a2 yards take $214968m1% increased magical damage.
    rot_and_wither    = 5510, -- (202727) Your $?s315442[Death's Due][Death and Decay] rots enemies each time it deals damage, absorbing healing equal to $s1% of damage dealt.
    shroud_of_winter  = 3439, -- (199719) Enemies within $a2 yards of you become shrouded in winter, reducing the range of their spells and abilities by $214975s1%.
    spellwarden       = 5591, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by ${$s1/-1000} sec.
    strangulate       = 5429, -- (47476 ) Shadowy tendrils constrict an enemy's throat, silencing them for $d$?s58618[ (${$d+($58618m1/1000)} sec when used on a target who is casting a spell)][].
} )

-- Auras
spec:RegisterAuras( {
    -- Your Runic Power spending abilities deal $w1% increased damage.
    a_feast_of_souls = {
        id = 440861,
        duration = 3600,
        max_stack = 1,
    },
    -- Recently pulled  by Abomination Limb and can't be pulled again.
    abomination_limb = {
        id = 383312,
        duration = 4.0,
        max_stack = 1,
    },
    -- Frozen.
    absolute_zero = {
        id = 377048,
        duration = 3.0,
        max_stack = 1,
    },
    -- Absorbing up to $w1 magic damage.; Immune to harmful magic effects.
    antimagic_shell = {
        id = 48707,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- antimagic_barrier[205727] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- antimagic_barrier[205727] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- osmosis[454835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- unyielding_will[457574] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- spellwarden[410320] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Magic damage taken reduced by $w1%.
    antimagic_zone = {
        id = 145629,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- assimilation[374383] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Stunned.
    asphyxiate = {
        id = 108194,
        duration = 4.0,
        max_stack = 1,
    },
    -- Next Howling Blast deals Shadowfrost damage.
    bind_in_darkness = {
        id = 443532,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement slowed by $w1%.
    blinding_sleet = {
        id = 317898,
        duration = 6.0,
        max_stack = 1,
    },
    -- You may not benefit from the effects of Blood Draw.
    blood_draw = {
        id = 374609,
        duration = 120.0,
        max_stack = 1,

        -- Affected by:
        -- blood_draw[374598] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Draining $w1 health from the target every $t1 sec.
    blood_plague = {
        id = 55078,
        duration = 24.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- frost_death_knight[137006] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_death_knight[137006] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frost_death_knight[137006] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_death_knight[137006] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- might_of_the_frozen_wastes[81333] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_plague[55078] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- frost_fever[55095] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- hungering_thirst[444037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hungering_thirst[444037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wither_away[441894] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- wither_away[441894] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- brittle[374557] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- blood_death_knight[137008] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_death_knight[137008] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blood_death_knight[137008] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Physical damage taken reduced by $w1%.
    bloodforged_armor = {
        id = 410305,
        duration = 3.0,
        max_stack = 1,
    },
    -- Critical Strike chance increased by $s1%.
    bonegrinder = {
        id = 377101,
        duration = 10.0,
        max_stack = 1,
    },
    -- Continuously dealing Frost damage every $t1 sec to enemies in a cone in front of you.
    breath_of_sindragosa = {
        id = 152279,
        duration = 3600,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- a_feast_of_souls[440861] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Damage taken from $@auracaster increased by $s1%.
    brittle = {
        id = 374557,
        duration = 5.0,
        max_stack = 1,
    },
    -- Movement slowed $w1% $?$w5!=0[and Haste reduced $w5% ][]by frozen chains.
    chains_of_ice = {
        id = 45524,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- ice_prison[454786] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 12000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- proliferating_chill[373930] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
    },
    -- Movement speed reduced by $w1%.
    clenching_grasp = {
        id = 389681,
        duration = 6.0,
        max_stack = 1,
    },
    -- Your next Chains of Ice will deal $281210s1 Frost damage.
    cold_heart = {
        id = 281209,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- mastery_frozen_heart[77514] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_frozen_heart[77514] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- razorice[51714] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Controlled.
    control_undead = {
        id = 111673,
        duration = 300.0,
        max_stack = 1,
    },
    -- Taunted.
    dark_command = {
        id = 56222,
        duration = 3.0,
        max_stack = 1,
    },
    -- Your next spell with a mana cost will be copied by the Death Knight's runeblade.
    dark_simulacrum = {
        id = 77606,
        duration = 12.0,
        max_stack = 1,
    },
    -- Your next Death Strike is free and heals for an additional $s1% of maximum health.
    dark_succor = {
        id = 101568,
        duration = 20.0,
        max_stack = 1,
    },
    -- Stunned.
    dead_of_winter = {
        id = 287254,
        duration = 4.0,
        max_stack = 1,
    },
    -- [444347] $@spelldesc444010
    death_charge = {
        id = 461461,
        duration = 0.001,
        max_stack = 1,
    },
    -- The next $w2 healing received will be absorbed.
    death_pact = {
        id = 48743,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your movement speed is increased by $w1%, you cannot be slowed below $s2% of normal speed, and you are immune to forced movement effects and knockbacks.
    deaths_advance = {
        id = 48265,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- deaths_echo[356367] #2: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Cooldown recovery of movement abilities reduced by $m1%.
    delirium = {
        id = 233397,
        duration = 12.0,
        max_stack = 1,
    },
    -- Haste increased by $s3%.; Generating $s1 $LRune:Runes; and ${$m2/10} Runic Power every $t1 sec.
    empower_rune_weapon = {
        id = 47568,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Strength increased by $w1%.
    enduring_strength = {
        id = 377195,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- enduring_strength[377190] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'pvp_multiplier': 0.8, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Movement Speed slowed by $w1% and damage dealt to $@auracaster reduced by $w2%.
    enfeeble = {
        id = 392490,
        duration = 6.0,
        max_stack = 1,
    },
    -- Damage taken from Remorseless Winter increased by $w1%.
    everfrost = {
        id = 376974,
        duration = 8.0,
        max_stack = 1,
    },
    -- Casting speed reduced by $w1%.
    expelling_shield = {
        id = 440739,
        duration = 6.0,
        max_stack = 1,
    },
    -- Death's Advance movement speed increased by $w1%.
    fleeting_wind = {
        id = 338093,
        duration = 3.0,
        max_stack = 1,
    },
    -- Movement speed slowed by $s2%.
    frost_breath = {
        id = 190780,
        duration = 10.0,
        max_stack = 1,
    },
    -- Suffering $w1 Frost damage every $t1 sec.
    frost_fever = {
        id = 55095,
        duration = 24.0,
        tick_time = 3.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- mastery_frozen_heart[77514] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_frozen_heart[77514] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frost_death_knight[137006] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_death_knight[137006] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frost_death_knight[137006] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 2.37, 'points': 57.44, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frost_death_knight[137006] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_death_knight[137006] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- might_of_the_frozen_wastes[81333] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_plague[55078] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- frost_fever[55095] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- hungering_thirst[444037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hungering_thirst[444037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wither_away[441894] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- wither_away[441894] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- brittle[374557] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- blood_death_knight[137008] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_death_knight[137008] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- razorice[51714] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Grants ${$s1*$mas}% Mastery.
    frostwhelps_aid = {
        id = 377253,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- frostwhelps_aid[377226] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'pvp_multiplier': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Grants $w1 Mastery.
    frostwhelps_indignation = {
        id = 287338,
        duration = 15.0,
        max_stack = 1,
    },
    -- Movement speed slowed by $s2%.
    frostwyrms_fury = {
        id = 410790,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_frozen_heart[77514] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_frozen_heart[77514] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- razorice[51714] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Remorseless Winter damage increased by $s1%.
    gathering_storm = {
        id = 211805,
        duration = 8.0,
        max_stack = 1,
    },
    -- Dealing $w1 Frost damage every $t1 sec.
    glacial_contagion = {
        id = 274074,
        duration = 14.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_frozen_heart[77514] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_frozen_heart[77514] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- razorice[51714] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Rooted.
    ice_prison = {
        id = 454787,
        duration = 4.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w3%.; Immune to Stun effects.
    icebound_fortitude = {
        id = 48792,
        duration = 8.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Attack speed increased by $w1%$?a436687[, and Runic Power spending abilities deal Shadowfrost damage.][.]
    icy_talons = {
        id = 194879,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- smothering_offense[435005] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- $?s207230[Your next $m2 $LObliterate or Frostscythe:Obliterates or Frostscythes; $Ldeals:deal; an additional $253597s1 Frost damage.][Your next $m2 $LObliterate:Obliterates; $Ldeals:deal; an additional $253597s1 Frost damage.]
    inexorable_assault = {
        id = 253595,
        duration = 3600,
        max_stack = 1,
    },
    -- Time between auto-attacks increased by $w1%.
    insidious_chill = {
        id = 391568,
        duration = 30.0,
        max_stack = 1,
    },
    -- Guaranteed critical strike on your next Obliterate$?s207230[ or Frostscythe][].
    killing_machine = {
        id = 51124,
        duration = 10.0,
        max_stack = 1,
    },
    -- Absorbing up to $w1 magic damage.; Duration of harmful magic effects reduced by $s2%.
    lesser_antimagic_shell = {
        id = 454863,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- antimagic_barrier[205727] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- antimagic_barrier[205727] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- osmosis[454835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- unyielding_will[457574] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- spellwarden[410320] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Leech increased by $s1%$?a389682[, damage taken reduced by $s8%][] and immune to Charm, Fear and Sleep. Undead.
    lichborne = {
        id = 49039,
        duration = 10.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- unholy_endurance[389682] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- deaths_messenger[437122] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Death's Advance movement speed increased by $w1%.
    march_of_darkness = {
        id = 391547,
        duration = 3.0,
        max_stack = 1,
    },
    -- Taking $w1% increased magical damage.
    necrotic_aura = {
        id = 214968,
        duration = 3.0,
        max_stack = 1,
    },
    -- [281238] Frost Strike$?s194913[, Glacial Advance,][] and Howling Blast grant Killing Machine and have a $s2% chance to generate a Rune.
    obliteration = {
        id = 207256,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Grants the ability to walk across water.
    path_of_frost = {
        id = 3714,
        duration = 600.0,
        tick_time = 0.5,
        max_stack = 1,

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Damage taken from $@auracaster's Chill Streak increased by $s1%.
    piercing_chill = {
        id = 377359,
        duration = 10.0,
        max_stack = 1,
    },
    -- Strength increased by $w1%.
    pillar_of_frost = {
        id = 51271,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- icecap[207126] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Reduces healing received from critical heals by $w1%.$?$w2>0[; Damage taken increased by $w2.][]
    pvp_rules_enabled_hardcoded = {
        id = 134735,
        duration = 20.0,
        max_stack = 1,
    },
    -- Frost damage taken from the Death Knight's abilities increased by $s1%.
    razorice = {
        id = 51714,
        duration = 20.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- unholy_bond[374261] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- You are a prey for the Deathbringer... This effect will explode for $436304s1 Shadowfrost damage for each stack.
    reapers_mark = {
        id = 434765,
        duration = 12.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Dealing $196771s1 Frost damage to enemies within $196771A1 yards each second.
    remorseless_winter = {
        id = 196770,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- dead_of_winter[287250] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Your next Howling Blast will consume no Runes, generate no Runic Power, and deals $s2% additional damage.
    rime = {
        id = 59052,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- improved_rime[316838] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Magical damage taken reduced by $w1%.
    rune_carved_plates = {
        id = 440290,
        duration = 5.0,
        max_stack = 1,
    },
    -- Strength increased by $w1%.
    rune_mastery = {
        id = 374585,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- rune_mastery[374574] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Range of spells and abilities decreased by $m1%.
    shroud_of_winter = {
        id = 214975,
        duration = 5.0,
        max_stack = 1,
    },
    -- Afflicted by Soul Reaper, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage.
    soul_reaper = {
        id = 448229,
        duration = 5.0,
        tick_time = 5.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_frozen_heart[77514] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_frozen_heart[77514] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- razorice[51714] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Silenced.
    strangulate = {
        id = 47476,
        duration = 5.0,
        max_stack = 1,
    },
    -- Damage dealt to $@auracaster reduced by $w1%.
    subduing_grasp = {
        id = 454824,
        duration = 6.0,
        max_stack = 1,
    },
    -- Damage taken from area of effect attacks reduced by an additional $w1%.
    suppression = {
        id = 454886,
        duration = 6.0,
        max_stack = 1,
    },
    -- Haste increased by $w1%.
    unholy_ground = {
        id = 374271,
        duration = 3600,
        max_stack = 1,
    },
    -- Strength increased by $w1%.
    unleashed_frenzy = {
        id = 376907,
        duration = 10.0,
        max_stack = 1,
    },
    -- The touch of the spirit realm lingers....
    voidtouched = {
        id = 97821,
        duration = 300.0,
        max_stack = 1,
    },
    -- [212552] Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by $s1% for $d. Taking any action cancels the effect.; While active, your movement speed cannot be reduced below $m2%.
    wraith_walk = {
        id = 212654,
        duration = 0.001,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Sprout an additional limb, dealing ${$383313s1*13} Shadow damage over $d to all nearby enemies. Deals reduced damage beyond $s5 targets. Every $t1 sec, an enemy is pulled to your location if they are further than $383312s3 yds from you. The same enemy can only be pulled once every $383312d.
    abomination_limb = {
        id = 383269,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "abomination_limb",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 383312, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 383313, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Surrounds you in an Anti-Magic Shell for $d, absorbing up to $<shield> magic damage and preventing application of harmful magical effects.$?s207188[][ Damage absorbed generates Runic Power.]
    antimagic_shell = {
        id = 48707,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'pvp_multiplier': 0.75, 'value': 126, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_IMMUNE_AURA_APPLY_SCHOOL, 'points': 30.0, 'value': 126, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_PCT, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': REFLECT_SPELLS, 'amplitude': 1.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_RUNE_REGEN_SPEED, 'value': 6, 'schools': ['holy', 'fire'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- antimagic_barrier[205727] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- antimagic_barrier[205727] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- osmosis[454835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- unyielding_will[457574] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- spellwarden[410320] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by $145629m1%. The Anti-Magic Zone lasts for $d or until it absorbs $?a374383[${$<absorb>*1.1}][$<absorb>] damage.
    antimagic_zone = {
        id = 51052,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "antimagic_zone",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 1193, 'schools': ['physical', 'nature', 'shadow'], 'radius': 6.5, 'target': TARGET_UNIT_DEST_AREA_ALLY, }

        -- Affected by:
        -- assimilation[374383] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Strikes the enemy, dealing $sw1 Physical damage and bursting up to $s3 Festering Wounds on the target, summoning a member of your Army of the Dead for $221180d for each burst Festering Wound.
    apocalypse = {
        id = 220143,
        color = 'artifact',
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': NORMALIZED_WEAPON_DMG, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': WEAPON_PERCENT_DAMAGE, 'subtype': NONE, 'points': 306.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'resource': runes, }
    },

    -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for $d.
    asphyxiate = {
        id = 221562,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "asphyxiate",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': STRANGULATE, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for $d.
    asphyxiate_108194 = {
        id = 108194,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': STRANGULATE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "pvp_talent_requires",
    },

    -- Targets in a cone in front of you are blinded, causing them to wander disoriented for $d. Damage may cancel the effect.; When Blinding Sleet ends, enemies are slowed by $317898s1% for $317898d.
    blinding_sleet = {
        id = 207167,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "blinding_sleet",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CONFUSE, 'points': 1.0, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -60.0, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
    },

    -- Continuously deal ${$155166s2*$<CAP>/$AP} Frost damage every $t1 sec to enemies in a cone in front of you, until your Runic Power is exhausted. Deals reduced damage to secondary targets.; Generates $303753s1 $lRune:Runes; at the start and end.
    breath_of_sindragosa = {
        id = 152279,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        spendType = 'runic_power',

        talent = "breath_of_sindragosa",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 155166, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 303753, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- a_feast_of_souls[440861] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Shackles the target $?a373930[and $373930s1 nearby enemy ][]with frozen chains, reducing movement speed by $s1% for $d.
    chains_of_ice = {
        id = 45524,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'chain_targets': 1, 'mechanic': snared, 'points': -70.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'mechanic': snared, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': SCHOOL_MASK_DAMAGE_FROM_CASTER, 'chain_targets': 1, 'value': 17, 'schools': ['physical', 'frost'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- ice_prison[454786] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 12000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- proliferating_chill[373930] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
    },

    -- Deals $204167s4 Frost damage to the target and reduces their movement speed by $204206m2% for $204206d.; Chill Streak bounces up to $m1 times between closest targets within $204165A1 yards.
    chill_streak = {
        id = 305392,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        talent = "chill_streak",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Strikes all enemies in front of you with a hungering attack that deals $sw2 Physical damage and heals you for $s3% of that damage.
    consumption = {
        id = 205223,
        color = 'artifact',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': NORMALIZED_WEAPON_DMG, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': WEAPON_PERCENT_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'points': 87.0, 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, }
        -- #5: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 224685, 'target': TARGET_UNIT_CASTER, }
    },

    -- Dominates the target undead creature up to level $s1, forcing it to do your bidding for $d.
    control_undead = {
        id = 111673,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        talent = "control_undead",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CHARM, 'points_per_level': 1.0, 'points': 38.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Cause a target corpse to explode in a shower of gore. Does not affect mechanical or elemental corpses.
    corpse_exploder = {
        id = 127344,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'value': 28590, 'schools': ['holy', 'fire', 'nature', 'shadow'], 'value1': 9, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_DEST_TARGET_ANY, }
    },

    -- Command the target to attack you.
    dark_command = {
        id = 56222,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "none",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': ATTACK_ME, 'subtype': NONE, 'sp_bonus': 0.25, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_TAUNT, 'points': 400.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Places a dark ward on an enemy player that persists for $d, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    dark_simulacrum = {
        id = 77606,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 20.0,
        gcd = "none",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Corrupts the targeted ground, causing ${$341340m1*11} Shadow damage over $d to targets within the area.$?!c2[; While you remain within the area, your ][]$?s223829&!c2[Necrotic Strike and ][]$?c1[Heart Strike will hit up to $188290m3 additional targets.]?s207311&!c2[Clawing Shadows will hit up to ${$55090s4-1} enemies near the target.]?!c2[Scourge Strike will hit up to ${$55090s4-1} enemies near the target.][; While you remain within the area, your Obliterate will hit up to $316916M2 additional $Ltarget:targets;.]
    death_and_decay = {
        id = 43265,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_DEST_DYNOBJ_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'attributes': ['No Immunity'], 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 26.0, 'value': 4485, 'schools': ['physical', 'fire'], 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- deaths_echo[356367] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Fires a blast of unholy energy at the target$?a377580[ and $377580s2 additional nearby target][], causing $47632s1 Shadow damage to an enemy or healing an Undead ally for $47633s1 health.$?s390268[; Increases the duration of Dark Transformation by $390268s1 sec.][]
    death_coil = {
        id = 47541,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 300,
        spendType = 'runic_power',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- hungering_thirst[444037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hungering_thirst[444037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Opens a gate which you can use to return to Ebon Hold.; Using a Death Gate while in Ebon Hold will return you back to near your departure point.
    death_gate = {
        id = 50977,
        cast = 4.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRANS_DOOR, 'subtype': NONE, 'value': 190942, 'schools': ['holy', 'fire', 'nature', 'frost', 'arcane'], 'radius': 3.0, 'target': TARGET_DEST_CASTER_FRONT, }
        -- #1: { 'type': KILL_CREDIT, 'subtype': NONE, 'value': 98305, 'schools': ['physical'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Harnesses the energy that surrounds and binds all matter, drawing the target toward you$?a389679[ and slowing their movement speed by $389681s1% for $389681d][]$?s137008[ and forcing the enemy to attack you][].
    death_grip = {
        id = 49576,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- deaths_echo[356367] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- deaths_reach[276079] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Create a death pact that heals you for $s1% of your maximum health, but absorbs incoming healing equal to $s3% of your max health for $d.
    death_pact = {
        id = 48743,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "death_pact",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL_PCT, 'subtype': NONE, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_HEAL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
    },

    -- Focuses dark power into a strike$?s137006[ with both weapons, that deals a total of ${$s1+$66188s1}][ that deals $s1] Physical damage and heals you for ${$s2}.2% of all damage taken in the last $s4 sec, minimum ${$s3}.1% of maximum health.
    death_strike = {
        id = 49998,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 450,
        spendType = 'runic_power',

        talent = "death_strike",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.464256, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- frost_death_knight[137006] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_death_knight[137006] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frost_death_knight[137006] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_death_knight[137006] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- might_of_the_frozen_wastes[81333] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_plague[55078] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- frost_fever[55095] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- improved_death_strike[374277] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- improved_death_strike[374277] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- improved_death_strike[374277] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dark_succor[101568] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- blood_draw[454871] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- brittle[374557] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- blood_death_knight[137008] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_death_knight[137008] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blood_death_knight[137008] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 139.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- a_feast_of_souls[440861] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- For $d, your movement speed is increased by $s1%, you cannot be slowed below $s2% of normal speed, and you are immune to forced movement effects and knockbacks.; Passive: You cannot be slowed below $124285s1% of normal speed.
    deaths_advance = {
        id = 48265,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 35.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'amplitude': 1.0, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY_MASK, 'amplitude': 1.0, 'value': 1887, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_MOVEMENT_FORCE_MAGNITUDE, 'amplitude': 1.0, 'points': -100.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- deaths_echo[356367] #2: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Empower your rune weapon, gaining $s3% Haste and generating $s1 $LRune:Runes; and ${$m2/10} Runic Power instantly and every $t1 sec for $d.
    empower_rune_weapon = {
        id = 47568,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "empower_rune_weapon",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_ENERGIZE, 'tick_time': 5.0, 'points': 1.0, 'value': 5, 'schools': ['physical', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_ENERGIZE, 'tick_time': 5.0, 'points': 50.0, 'value': 6, 'schools': ['holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'pvp_multiplier': 0.334, 'points': 15.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Chill your $?$owb==0[weapon with icy power and quickly strike the enemy, dealing $<2hDamage> Frost damage.][weapons with icy power and quickly strike the enemy with both, dealing a total of $<dualWieldDamage> Frost damage.]
    frost_strike = {
        id = 49143,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 300,
        spendType = 'runic_power',

        talent = "frost_strike",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 222026, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 66196, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 325464, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- hungering_thirst[444037] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hungering_thirst[444037] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_frost_strike[316803] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- a_feast_of_souls[440861] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- A sweeping attack that strikes all enemies in front of you for $s2 Frost damage. This attack always critically strikes and critical strikes with Frostscythe deal $s3 times normal damage. Deals reduced damage beyond $s5 targets. ; Consuming Killing Machine reduces the cooldown of Frostscythe by ${$s1/1000}.1 sec.
    frostscythe = {
        id = 207230,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 2,
        spendType = 'runes',

        talent = "frostscythe",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'ap_bonus': 0.8547, 'pvp_multiplier': 1.5, 'variance': 0.05, 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'resource': runic_power, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_frozen_heart[77514] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_frozen_heart[77514] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- death_knight[137005] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- killing_machine[51124] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- razorice[51714] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Summons a frostwyrm who breathes on all enemies within $s1 yd in front of you, dealing $279303s1 Frost damage and slowing movement speed by $279303s2% for $279303d.
    frostwyrms_fury = {
        id = 279302,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "frostwyrms_fury",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 40.0, 'value': 14881, 'schools': ['physical', 'shadow'], 'target': TARGET_DEST_CASTER, }

        -- Affected by:
        -- absolute_zero[377047] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Summon glacial spikes from the ground that advance forward, each dealing ${$195975s1*$<CAP>/$AP} Frost damage and applying Razorice to enemies near their eruption point.
    glacial_advance = {
        id = 194913,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 300,
        spendType = 'runic_power',

        talent = "glacial_advance",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 30.0, 'target': TARGET_DEST_CASTER_FRONT, }
    },

    -- Blow the Horn of Winter, gaining $s1 $LRune:Runes; and generating ${$s2/10} Runic Power.
    horn_of_winter = {
        id = 57330,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        talent = "horn_of_winter",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': ENERGIZE, 'subtype': NONE, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'resource': runes, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 250.0, 'target': TARGET_UNIT_CASTER, 'resource': runic_power, }

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- [55095] A disease that deals ${$o1*$<CAP>/$AP} Frost damage over $d and has a chance to grant the Death Knight ${$195617m1/10} Runic Power each time it deals damage.
    howling_blast = {
        id = 49184,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        talent = "howling_blast",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.220356, 'pvp_multiplier': 1.3, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mastery_frozen_heart[77514] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_frozen_heart[77514] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frost_death_knight[137006] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_death_knight[137006] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- frost_death_knight[137006] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- frost_death_knight[137006] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- might_of_the_frozen_wastes[81333] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_plague[55078] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- frost_fever[55095] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- rime[59052] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rime[59052] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 225.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rime[59052] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- bind_in_darkness[443532] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 48, 'schools': ['frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- brittle[374557] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- blood_death_knight[137008] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_death_knight[137008] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- razorice[51714] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by $s3% for $d.
    icebound_fortitude = {
        id = 48792,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "icebound_fortitude",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 12, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -30.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, }
    },

    -- Draw upon unholy energy to become Undead for $d, increasing Leech by $s1%$?a389682[, reducing damage taken by $s8%][], and making you immune to Charm, Fear, and Sleep.
    lichborne = {
        id = 49039,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_LEECH, 'points': 6.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'mechanic': 1, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 5, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 10, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 23, }
        -- #5: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': MOD_SHAPESHIFT, 'target': TARGET_UNIT_CASTER, 'form': undead, 'creature_type': undead, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -15.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- unholy_endurance[389682] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- deaths_messenger[437122] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    mind_freeze = {
        id = 47528,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "none",

        spendType = 'runic_power',

        talent = "mind_freeze",
        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- A brutal attack $?$owb==0[that deals $<2hDamage> Physical damage.][with both weapons that deals a total of $<dualWieldDamage> Physical damage.]$?a134735&a51128[; Damage increased by $s6% in PvP Combat when Killing Machine is not active.][]
    obliterate = {
        id = 49020,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 2,
        spendType = 'runes',

        talent = "obliterate",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 222024, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 66198, 'value': 20, 'schools': ['fire', 'frost'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 325461, 'value': 20, 'schools': ['fire', 'frost'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #4: { 'type': ENERGIZE, 'subtype': NONE, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'resource': runic_power, }
        -- #5: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- might_of_the_frozen_wastes[81333] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- frigid_executioner[377073] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'trigger_spell': 208783, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- improved_obliterate[317198] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- killing_machine[51124] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- killing_machine[51124] #1: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 16, 'schools': ['frost'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Activates a freezing aura for $d that creates ice beneath your feet, allowing party or raid members within $a1 yards to walk on water.; Usable while mounted, but being attacked or damaged will cancel the effect.
    path_of_frost = {
        id = 3714,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AREA_AURA_RAID, 'subtype': WATER_WALK, 'variance': 0.25, 'radius': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.5, 'points': 60068.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- The power of frost increases your Strength by $s1% for $d.
    pillar_of_frost = {
        id = 51271,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        talent = "pillar_of_frost",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_TOTAL_STAT_PERCENTAGE, 'pvp_multiplier': 0.4, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': unknown, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'pvp_multiplier': 0.5, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- icecap[207126] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Pours dark energy into a dead target, reuniting spirit and body to allow the target to reenter battle with $s2% health and at least $s1% mana.
    raise_ally = {
        id = 61999,
        cast = 0.0,
        cooldown = 600.0,
        gcd = "global",

        spend = 300,
        spendType = 'runic_power',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 20.0, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 97821, 'points': 60.0, }

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Viciously slice into the soul of your enemy, dealing $?a137008[$s1][$s4] Shadowfrost damage and applying Reaper's Mark.; Each time you deal Shadow or Frost damage, add a stack of Reaper's Mark. After $434765d or reaching $434765u stacks, the mark explodes, dealing $?a137008[$436304s1][$436304s2] damage per stack.; Reaper's Mark travels to an unmarked enemy nearby if the target dies, or explodes below 35% health when there are no enemies to travel to. This explosion cannot occur again on a target for $443761d.
    reapers_mark = {
        id = 439843,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 2,
        spendType = 'runes',

        talent = "reapers_mark",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 0.8, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 434765, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'resource': runic_power, }
        -- #3: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 1.5, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- painful_death[443564] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- swift_end[443560] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- swift_end[443560] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Drain the warmth of life from all nearby enemies within $196771A1 yards, dealing ${9*$196771s1*$<CAP>/$AP} Frost damage over $d and reducing their movement speed by $211793s1%.
    remorseless_winter = {
        id = 196770,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 196771, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': AREA_TRIGGER, 'value': 6917, 'schools': ['physical', 'fire'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- dead_of_winter[287250] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Strike the target for $s1 Physical damage. This attack cannot be dodged, blocked, or parried.
    rune_strike = {
        id = 316239,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.6, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Sacrifice your ghoul to deal $327611s1 Shadow damage to all nearby enemies and heal for $s1% of your maximum health. Deals reduced damage beyond $327611s2 targets.
    sacrificial_pact = {
        id = 327574,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        spend = 200,
        spendType = 'runic_power',

        talent = "sacrificial_pact",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL_PCT, 'subtype': NONE, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summons Sindragosa, who breathes frost on all enemies within $s1 yd in front of you, dealing $190780s1 Frost damage and slowing movement speed by $190780s2% for $190780d.
    sindragosas_fury = {
        id = 190778,
        color = 'artifact',
        cast = 0.0,
        cooldown = 300.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 40.0, 'value': 4714, 'schools': ['holy', 'nature', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }
    },

    -- Strike an enemy for $s1 Shadowfrost damage and afflict the enemy with Soul Reaper. ; After $d, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    soul_reaper = {
        id = 343294,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        talent = "soul_reaper",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.4488, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_frozen_heart[77514] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_frozen_heart[77514] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- razorice[51714] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- After $d, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    soul_reaper_448229 = {
        id = 448229,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 5.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mastery_frozen_heart[77514] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_frozen_heart[77514] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- razorice[51714] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        from = "affected_by_mastery",
    },

    -- Shadowy tendrils constrict an enemy's throat, silencing them for $d$?s58618[ (${$d+($58618m1/1000)} sec when used on a target who is casting a spell)][].
    strangulate = {
        id = 47476,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "none",

        spendType = 'runes',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_SILENCE, 'mechanic': silenced, 'points': 1.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- [55095] A disease that deals ${$o1*$<CAP>/$AP} Frost damage over $d and has a chance to grant the Death Knight ${$195617m1/10} Runic Power each time it deals damage.
    superstrain = {
        id = 331959,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 55095, 'triggers': frost_fever, 'ap_bonus': 0.134316, 'radius': 10.0, 'target': TARGET_DEST_CASTER_SUMMON, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- mastery_frozen_heart[77514] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_frozen_heart[77514] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rime[59052] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rime[59052] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 225.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- rime[59052] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- bind_in_darkness[443532] #0: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'value': 48, 'schools': ['frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- razorice[51714] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by $s1% for $d. Taking any action cancels the effect.; While active, your movement speed cannot be reduced below $m2%.
    wraith_walk = {
        id = 212552,
        cast = 4.0,
        channeled = true,
        cooldown = 60.0,
        gcd = "global",

        talent = "wraith_walk",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 70.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'amplitude': 1.0, 'points': 170.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 212654, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': HOVER, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_DETECT_RANGE, 'points': -5.0, }
        -- #6: { 'type': UNKNOWN, 'subtype': NONE, 'points': 100.0, }

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

} )