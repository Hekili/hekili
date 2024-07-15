-- DeathKnightBlood.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 250 )

-- Resources
spec:RegisterResource( Enum.PowerType.RunicPower )
spec:RegisterResource( Enum.PowerType.Runes )

spec:RegisterTalents( {
    -- Death Knight Talents
    abomination_limb               = { 76049, 383269, 1 }, -- Sprout an additional limb, dealing ${$383313s1*13} Shadow damage over $d to all nearby enemies. Deals reduced damage beyond $s5 targets. Every $t1 sec, an enemy is pulled to your location if they are further than $383312s3 yds from you. The same enemy can only be pulled once every $383312d.
    antimagic_barrier              = { 76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by ${$s1/-1000} sec and increases its duration and amount absorbed by $s2%.
    antimagic_zone                 = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by $145629m1%. The Anti-Magic Zone lasts for $d or until it absorbs $?a374383[${$<absorb>*1.1}][$<absorb>] damage.
    asphyxiate                     = { 76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for $d.
    assimilation                   = { 76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by $s1% and its cooldown is reduced by ${$s2/-1000} sec.
    blinding_sleet                 = { 76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for $d. Damage may cancel the effect.; When Blinding Sleet ends, enemies are slowed by $317898s1% for $317898d.
    blood_draw                     = { 76056, 374598, 1 }, -- When you fall below $s1% health you drain $374606s1 health from nearby enemies, the damage you take is reduced by $454871s1% and your Death Strike cost is reduced by ${$454871s2/-10} for $454871d.; Can only occur every $374609d.
    blood_scent                    = { 76078, 374030, 1 }, -- Increases Leech by $s1%.
    brittle                        = { 76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal $374557s1% increased damage for $374557d.
    cleaving_strikes               = { 76073, 316916, 1 }, -- $?a137008[Heart Strike hits up to $s3]?a137006[Obliterate hits up to $s2]?s207311[Clawing Shadows][Scourge Strike]$?a137007[ hits up to ${$55090s4-1}][] additional enemies while you remain in Death and Decay. ; When leaving your Death and Decay you retain its bonus effects for ${$316916s4/1000} sec.
    coldthirst                     = { 76083, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants ${$378849s1/10} Runic Power and reduces its cooldown by ${$378849s2/-1000} sec.
    control_undead                 = { 76059, 111673, 1 }, -- Dominates the target undead creature up to level $s1, forcing it to do your bidding for $d.
    death_pact                     = { 76075, 48743 , 1 }, -- Create a death pact that heals you for $s1% of your maximum health, but absorbs incoming healing equal to $s3% of your max health for $d.
    death_strike                   = { 76071, 49998 , 1 }, -- Focuses dark power into a strike$?s137006[ with both weapons, that deals a total of ${$s1+$66188s1}][ that deals $s1] Physical damage and heals you for ${$s2}.2% of all damage taken in the last $s4 sec, minimum ${$s3}.1% of maximum health.
    deaths_echo                    = { 102007, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have $s1 additional charge.
    deaths_reach                   = { 102006, 276079, 1 }, -- Increases the range of Death Grip by $s1 yds.; Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    enfeeble                       = { 76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by $392490s1% and the damage they deal to you by $392490s2% for $392490d.
    gloom_ward                     = { 76052, 391571, 1 }, -- Absorbs are $s1% more effective on you. 
    grip_of_the_dead               = { 76057, 273952, 1 }, -- $?s152280[Defile][Death and Decay] reduces the movement speed of enemies within its area by $s1%, decaying by $s2% every sec.
    ice_prison                     = { 76086, 454786, 1 }, -- Chains of Ice now also roots enemies for $454787d but its cooldown is increased to ${$s2/1000} sec.
    icy_talons                     = { 76085, 194878, 1 }, -- Your Runic Power spending abilities increase your melee attack speed by $s1% for $194879d, stacking up to $194879u times.
    improved_death_strike          = { 76067, 374277, 1 }, -- Death Strike's cost is reduced by $?a137008[${$s5/-10}][${$s3/-10}], and its healing is increased by $?a137008[$s4%][$s1%].
    insidious_chill                = { 76051, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by $s1% for $391568d, stacking up to $391568u times.
    march_of_darkness              = { 76074, 391546, 1 }, -- Death's Advance grants an additional $s1% movement speed over the first $338093d.
    mind_freeze                    = { 76084, 47528 , 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    null_magic                     = { 102008, 454842, 1 }, -- Magic damage taken is reduced by $s1% and the duration of harmful Magic effects against you are reduced by $s2%.
    osmosis                        = { 76088, 454835, 1 }, -- Anti-Magic Shell increases healing received by $s1%.
    permafrost                     = { 76066, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to $s1% of the damage dealt.
    proliferating_chill            = { 101708, 373930, 1 }, -- Chains of Ice affects $s1 additional nearby enemy.
    rune_mastery                   = { 76079, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by $s1% for $374585d.
    runic_attenuation              = { 76045, 207104, 1 }, -- Auto attacks have a chance to generate ${$221322s1/10} Runic Power.
    runic_protection               = { 76055, 454788, 1 }, -- Your chance to be critically struck is reduced by $s2% and your Armor is increased by $s1%.
    sacrificial_pact               = { 76060, 327574, 1 }, -- Sacrifice your ghoul to deal $327611s1 Shadow damage to all nearby enemies and heal for $s1% of your maximum health. Deals reduced damage beyond $327611s2 targets.
    soul_reaper                    = { 76063, 343294, 1 }, -- Strike an enemy for $s1 Shadowfrost damage and afflict the enemy with Soul Reaper. ; After $d, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    subduing_grasp                 = { 76080, 454822, 1 }, -- When you pull an enemy, the damage they deal to you is reduced by $454824s1% for $454824d.
    suppression                    = { 76087, 374049, 1 }, -- Damage taken from area of effect attacks reduced by $s1%. When suffering a loss of control effect, this bonus is increased by an additional $454886s1% for $454886d.
    unholy_bond                    = { 76076, 374261, 1 }, -- Increases the effectiveness of your Runeforge effects by $s1%.
    unholy_endurance               = { 76058, 389682, 1 }, -- Increases Lichborne duration by ${$s1/1000} sec and while active damage taken is reduced by $49039s8%.
    unholy_ground                  = { 76069, 374265, 1 }, -- Gain $374271s1% Haste while you remain within your Death and Decay.
    unyielding_will                = { 76050, 457574, 1 }, -- Anti-Magic Shell's cooldown is increased by ${$s2/1000} sec and it now also removes all harmful magic effects when activated.
    vestigial_shell                = { 76053, 454851, 1 }, -- Casting Anti-Magic Shell grants $454863i nearby allies a Lesser Anti-Magic Shell that Absorbs up to $454863s1 magic damage and reduces the duration of harmful Magic effects against them by $454863s2%. 
    veteran_of_the_third_war       = { 76068, 48263 , 1 }, -- Stamina increased by $s1%.; $?s316714[Damage taken reduced by $s3%.][]
    will_of_the_necropolis         = { 76054, 206967, 2 }, -- Damage taken below $s3% Health is reduced by $s2%.
    wraith_walk                    = { 76077, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by $s1% for $d. Taking any action cancels the effect.; While active, your movement speed cannot be reduced below $m2%.

    -- Blood Talents
    bind_in_darkness               = { 95043, 440031, 1 }, -- Shadowfrost damage applies 2 stacks to Reaper's Mark and 4 stacks when it is a critical strike.; Additionally, $?a137008[Blood Boil][Rime empowered Howling Blast] deals Shadowfrost damage.
    blood_boil                     = { 76170, 50842 , 1 }, -- [55078] A shadowy disease that drains $o1 health from the target over $d.  
    blood_feast                    = { 102243, 391386, 1 }, -- Anti-Magic Shell heals you for $s1% of the damage it absorbs.
    blood_fever                    = { 95058, 440002, 1 }, -- Your $?a137008[Blood Plague][Frost Fever] has a chance to deal $s1% increased damage as Shadowfrost.
    blood_tap                      = { 76039, 221699, 1 }, -- Consume the essence around you to generate $s1 Rune.; Recharge time reduced by $s2 sec whenever a Bone Shield charge is consumed.
    blooddrinker                   = { 102244, 206931, 1 }, -- Drains $o1 health from the target over $d. The damage they deal to you is reduced by $s2% for the duration and $458687d after channeling it fully.; You can move, parry, dodge, and use defensive abilities while channeling this ability.; Generates ${$s3*4/10} additional Runic Power over the duration.
    bloodied_blade                 = { 102242, 458753, 1 }, -- Parrying an attack grants you a charge of Bloodied Blade, increasing your Strength by ${$460499s1/10}.1%, up to ${$460499u*$460499s1/10}.1% for $460499d.; At $460499U stacks, your next parry consumes all charges to unleash a Heart Strike at $s1% effectiveness, and increases your Strength by $460500s1% for $460500d.
    bloodshot                      = { 76125, 391398, 1 }, -- While Blood Shield is active, you deal $s1% increased Physical damage.
    bloodsoaked_ground             = { 95048, 434033, 1 }, -- While you are within your Death and Decay, your physical damage taken is reduced by ${$434034s1*-1}% and your chance to gain Vampiric Strike is increased by $s2%.
    bloodworms                     = { 76174, 195679, 1 }, -- Your auto attacks have a chance to summon a Bloodworm.; Bloodworms deal minor damage to your target for $198494d and then burst, healing you for $s3% of your missing health.; If you drop below $s2% health, your Bloodworms will immediately burst and heal you.
    bloody_fortitude               = { 95056, 434136, 1 }, -- Icebound Fortitude reduces all damage you take by up to an additional $s1% based on your missing health.; Killing an enemy that yields experience or honor reduces the cooldown of Icebound Fortitude by $s2 sec.
    bone_collector                 = { 76171, 458572, 1 }, -- [195181] Surrounds you with a barrier of whirling bones, increasing Armor by ${$s1*$STR/100}$?s316746[, and your Haste by $s4%][]. Each melee attack against you consumes a charge. Lasts $d or until all charges are consumed.
    bonestorm                      = { 76127, 194844, 1 }, -- Consume your Bone Shield charges to create a whirl of bone and gore that batters all nearby enemies, dealing $196528s1 Shadow damage every $t3 sec, and healing you for $196545s1% of your maximum health every time it deals damage (up to ${$s1*$s4}%). Deals reduced damage beyond $196528s2 targets.; Lasts $d per Bone Shield charge spent and rapidly regenerates a Bone Shield every $t3 sec.
    carnage                        = { 102245, 458752, 1 }, -- Blooddrinker and Consumption now contribute to your Mastery: Blood Shield.; Each time an enemy strikes your Blood Shield, the cooldowns of Blooddrinker and Consumption have a chance to be reset.
    coagulopathy                   = { 76038, 391477, 1 }, -- Enemies affected by Blood Plague take $s1% increased damage from you and Death Strike increases the damage of your Blood Plague by $391481s1% for $391481d, stacking up to $391481u times.
    consumption                    = { 102244, 274156, 1 }, -- Strikes all enemies in front of you with a hungering attack that deals $sw1 Physical damage and heals you for ${$e1*100}% of that damage. Deals reduced damage beyond $s3 targets.; Causes your Blood Plague damage to occur $s5% more quickly for $d. ; Generates $s4 Runes.
    dancing_rune_weapon            = { 76138, 49028 , 1 }, -- Summons a rune weapon for $81256d that mirrors your melee attacks and bolsters your defenses.; While active, you gain $81256s1% parry chance.
    dark_talons                    = { 95057, 436687, 1 }, -- $?a137008[Marrowrend and Heart Strike have][Consuming Killing Machine or Rime has] a $s1% chance to increase the maximum stacks of an active $@spellname194878 by $s2, up to $s3 times.; While Icy Talons is active, your Runic Power spending abilities also count as Shadowfrost damage.
    deaths_messenger               = { 95049, 437122, 1 }, -- Reduces the cooldowns of Lichborne and Raise Dead by ${$s1/-1000} sec.
    everlasting_bond               = { 76130, 377668, 1 }, -- Summons $s1 additional copy of Dancing Rune Weapon and increases its duration by ${$s2/1000} sec.
    expelling_shield               = { 95049, 439948, 1 }, -- When an enemy deals direct damage to your Anti-Magic Shell, their cast speed is reduced by $440739s1% for $440739d.
    exterminate                    = { 95068, 441378, 1 }, -- After Reaper's Mark explodes, your next $?a443564[$s3 ][]$?a137008[Marrowrend][Obliterate]$?a443564[s][] costs $?a443564[$s4][no] Rune and summon$?a443564[][s] $s1 scythes to strike your enemies.; The first scythe strikes your target for $?a137008[$$441424s1][$441424s2] Shadowfrost damage and has a $?a443564[${$s2*1.5}][$s2]% chance to apply Reaper's Mark, the second scythe strikes all enemies around your target for $?a137008[$$441426s1][$441426s2] Shadowfrost damage$?(a441894&a137008)[ and applies Blood Plague]?(a441894&$a137006)[ and applies Frost Fever][]. Deals reduced damage beyond $s5 targets.
    foul_bulwark                   = { 76167, 206974, 1 }, -- Each charge of Bone Shield increases your maximum health by $<increase>%.
    frenzied_bloodthirst           = { 95065, 434075, 1 }, -- Essence of the Blood Queen stacks $s1 additional times and increases the damage of your Death Coil and Death Strike by $s2% per stack.
    gift_of_the_sanlayn            = { 95053, 434152, 1 }, -- While Vampiric Blood or Dark Transformation is active you gain Gift of the San'layn.; Gift of the San'layn increases the effectiveness of your Essence of the Blood Queen by $?a137007[$434153s1][$434153s4]%, and Vampiric Strike replaces your $?a137008[Heart Strike]?s207311[Clawing Shadows][Scourge Strike] for the duration.; 
    gorefiends_grasp               = { 76042, 108199, 1 }, -- Shadowy tendrils coil around all enemies within $A2 yards of a hostile or friendly target, pulling them to the target's location.
    grim_reaper                    = { 95034, 434905, 1 }, -- Reaper's Mark explosion deals up to $s1% increased damage based on your target's missing health, and applies Soul Reaper to targets below $s2% health.
    heart_strike                   = { 76169, 206930, 1 }, -- Instantly strike the target and 1 other nearby enemy, causing $s2 Physical damage, and reducing enemies' movement speed by $s5% for $d$?s316575[; Generates $s3 bonus Runic Power][]$?s221536[, plus ${$210738s1/10} Runic Power per additional enemy struck][].
    heartbreaker                   = { 76135, 221536, 1 }, -- Heart Strike generates ${$210738s1/10} additional Runic Power per target hit.
    heartrend                      = { 76131, 377655, 1 }, -- Heart Strike has a chance to increase the damage of your next Death Strike by $s1%.
    hemostasis                     = { 76137, 273946, 1 }, -- Each enemy hit by Blood Boil increases the damage and healing done by your next Death Strike by $273947s1%, stacking up to $273947u times.
    improved_bone_shield           = { 76142, 374715, 1 }, -- Bone Shield increases your Haste by $s1%.
    improved_heart_strike          = { 76126, 374717, 2 }, -- Heart Strike damage increased by $s1%.
    improved_vampiric_blood        = { 76140, 317133, 2 }, -- Vampiric Blood's healing and absorb amount is increased by $s1% and duration by ${$s3/1000} sec.
    incite_terror                  = { 95040, 434151, 1 }, -- Vampiric Strike and $?a137008[Heart Strike]?s207311[Clawing Shadows][Scourge Strike] cause your targets to take $458478s1% increased Shadow damage, up to ${$458478s1*$458478U}% for $458478d.; Vampiric Strike benefits from Incite Terror at $s2% effectiveness.
    infliction_of_sorrow           = { 95033, 434143, 1 }, -- When Vampiric Strike damages an enemy affected by your $?a137008[Blood Plague][Virulent Plague], it extends the duration of the disease by $s3 sec, and deals $s2% of the remaining damage to the enemy. ; After Gift of the San'layn ends, your next $?a137008[Heart Strike]?s207311[Clawing Shadows][Scourge Strike] consumes the disease to deal $s1% of their remaining damage to the target.
    insatiable_blade               = { 76129, 377637, 1 }, -- Dancing Rune Weapon generates $s2 Bone Shield charges. When a charge of Bone Shield is consumed, the cooldown of Dancing Rune Weapon is reduced by ${$s1/-1000} sec.
    iron_heart                     = { 76172, 391395, 1 }, -- Blood Shield's duration is increased by ${$s1/1000} sec and it absorbs $s2% more damage.
    leeching_strike                = { 76145, 377629, 1 }, -- Heart Strike heals you for ${$s1/10}.1% health for each enemy hit while affected by Blood Plague.
    mark_of_blood                  = { 76139, 206940, 1 }, -- Places a Mark of Blood on an enemy for $d. The enemy's damaging auto attacks will also heal their victim for $206940s1% of the victim's maximum health.
    marrowrend                     = { 76168, 195182, 1 }, -- [195181] Surrounds you with a barrier of whirling bones, increasing Armor by ${$s1*$STR/100}$?s316746[, and your Haste by $s4%][]. Each melee attack against you consumes a charge. Lasts $d or until all charges are consumed.
    newly_turned                   = { 95064, 433934, 1 }, -- Raise Ally revives players at full health and grants you and your ally an absorb shield equal to $s2% of your maximum health.
    ossified_vitriol               = { 76146, 458744, 1 }, -- When you lose a Bone Shield charge the damage of your next Marrowrend is increased by 15%, stacking up to 75%.
    ossuary                        = { 76144, 219786, 1 }, -- While you have at least $s1 Bone Shield charges, the cost of Death Strike is reduced by ${$219788m1/-10} Runic Power.; Additionally, your maximum Runic Power is increased by ${$m2/10}.
    pact_of_the_deathbringer       = { 95035, 440476, 1 }, -- When you suffer a damaging effect equal to $s1% of your maximum health, you instantly cast Death Pact at $s3% effectiveness. May only occur every $s2 min.; When a Reaper's Mark explodes, the cooldowns of this effect and Death Pact are reduced by $s4 sec.
    pact_of_the_sanlayn            = { 95055, 434261, 1 }, -- You store $s1% of all Shadow damage dealt into your Blood Beast to explode for additional damage when it expires.
    painful_death                  = { 95032, 443564, 1 }, -- Reaper's Mark deals $s1% increased damage and Exterminate empowers an additional $?a137008[Marrowrend][Obliterate], but now reduces its cost by 1 Rune.; Additionally, Exterminate now has a $s2% chance to apply Reaper's Mark.
    perseverance_of_the_ebon_blade = { 76124, 374747, 1 }, -- When Crimson Scourge is consumed, you gain $374748s1% Versatility for $374748d.
    purgatory                      = { 76133, 114556, 1 }, -- An unholy pact that prevents fatal damage, instead absorbing incoming healing equal to the damage prevented, lasting $116888d.; If any healing absorption remains when this effect expires, you will die. This effect may only occur every $123981d.
    rapid_decomposition            = { 76141, 194662, 1 }, -- Your Blood Plague and Death and Decay deal damage $s2% more often.; Additionally, your Blood Plague leeches $s3% more Health.
    reapers_mark                   = { 95062, 439843, 1 }, -- Viciously slice into the soul of your enemy, dealing $?a137008[$s1][$s4] Shadowfrost damage and applying Reaper's Mark.; Each time you deal Shadow or Frost damage, add a stack of Reaper's Mark. After $434765d or reaching $434765u stacks, the mark explodes, dealing $?a137008[$436304s1][$436304s2] damage per stack.; Reaper's Mark travels to an unmarked enemy nearby if the target dies, or explodes below 35% health when there are no enemies to travel to. This explosion cannot occur again on a target for $443761d.
    red_thirst                     = { 76132, 205723, 1 }, -- Reduces the cooldown on Vampiric Blood by ${$s1/1000}.1 sec per $s2 Runic Power spent.
    reinforced_bones               = { 76143, 374737, 1 }, -- Increases Armor gained from Bone Shield by $s1% and it can stack $s2 additional times.
    relish_in_blood                = { 76147, 317610, 1 }, -- While Crimson Scourge is active, your next Death and Decay heals you for $317614s1 health per Bone Shield charge and you immediately gain ${$317614s2/10} Runic Power.
    rune_carved_plates             = { 95035, 440282, 1 }, -- Each Rune spent reduces the magic damage you take by $440290s1% and each Rune generated reduces the physical damage you take by $440289s1% for $440289d, up to $440290u times.
    rune_tap                       = { 76166, 194679, 1 }, -- Reduces all damage taken by $s1% for $d.
    sanguine_ground                = { 76041, 391458, 1 }, -- You deal $391459s1% more damage and receive $391459s2% more healing while standing in your Death and Decay.
    sanguine_scent                 = { 95055, 434263, 1 }, -- Your Death Coil$?a137007[, Epidemic][] and Death Strike have a $s2% increased chance to trigger Vampiric Strike when damaging enemies below $s1% health.
    shattering_bone                = { 76128, 377640, 1 }, -- When Bone Shield is consumed it shatters dealing $s3 Shadow damage to nearby enemies. This damage is tripled while you are within your Death and Decay.
    soul_rupture                   = { 95061, 437161, 1 }, -- When Reaper's Mark explodes, it deals $?a137008[$s1][$s2]% of the damage dealt damage to nearby enemies.; Enemies hit by this effect deal $s3% reduced physical damage to you for 10 sec.
    swift_end                      = { 95032, 443560, 1 }, -- Reaper's Mark's cost is reduced by $s2 Rune and its cooldown is reduced by ${$s1/-1000} sec.
    the_blood_is_life              = { 95046, 434260, 1 }, -- Vampiric Strike has a chance to summon a Blood Beast to attack your enemy for $434237d.; Each time the Blood Beast attacks, it stores a portion of the damage dealt. When the Blood Beast dies, it explodes, dealing $?a137007[$s2][$s1]% of the damage accumulated to nearby enemies and healing the Death Knight for the same amount.
    tightening_grasp               = { 76165, 206970, 1 }, -- Gorefiend's Grasp cooldown is reduced by ${$m1/-1000} sec and it now also Silences enemies for $374776d.
    tombstone                      = { 76139, 219809, 1 }, -- Consume up to $s5 Bone Shield charges. For each charge consumed, you gain $s3 Runic Power and absorb damage equal to $s4% of your maximum health for $d.
    umbilicus_eternus              = { 76040, 391517, 1 }, -- After Vampiric Blood expires, you absorb damage equal to $s1 times the damage your Blood Plague dealt during Vampiric Blood.
    vampiric_aura                  = { 95056, 434100, 1 }, -- Your Leech is increased by $s1%.; While Lichborne is active, the Leech bonus of this effect is increased by $434105s1%, and it affects $s2 allies within 12 yds. 
    vampiric_blood                 = { 76173, 55233 , 1 }, -- Embrace your undeath, increasing your maximum health by $s4% and increasing all healing and absorbs received by $s1% for $d.
    vampiric_speed                 = { 95064, 434028, 1 }, -- Death's Advance and Wraith Walk movement speed bonuses are increased by $s1%.; Activating Death's Advance or Wraith Walk increases $434029s2 nearby allies movement speed by $434029s1% for $434029d.
    vampiric_strike                = { 95051, 433901, 1 }, -- Your Death Coil$?a137007[, Epidemic][] and Death Strike have a $s1% chance to make your next $?a137008[Heart Strike]?s207311[Clawing Shadows][Scourge Strike] become Vampiric Strike.; Vampiric Strike heals you for $?a137008[$434422s2][$434422s3]% of your maximum health and grants you Essence of the Blood Queen, increasing your Haste by ${$433925s1/10}.1%, up to ${$433925s1*$433925u/10}.1% for $433925d.; 
    visceral_strength              = { 95045, 434157, 1 }, -- When $?a137008[Crimson Scourge][Sudden Doom] is consumed, you gain $?a137008[$461130s1][$434159s1]% Strength for $?a137008[$461130d][$434159d].
    voracious                      = { 76043, 273953, 1 }, -- Death Strike's healing is increased by $s2% and grants you $274009s1% Leech for $274009d.
    wave_of_souls                  = { 95036, 439851, 1 }, -- Reaper's Mark sends forth bursts of Shadowfrost energy and back, dealing $?a137008[$435802s1][$435802s2] Shadowfrost damage both ways to all enemies caught in its path.; Wave of Souls critical strikes cause enemies to take $443404s1% increased Shadowfrost damage for $443404d, stacking up to 2 times, and it is always a critical strike on its way back.
    wither_away                    = { 95057, 441894, 1 }, -- $?a137008[Blood Plague][Frost Fever] deals its damage in half the duration and the second scythe of Exterminate applies $?a137008[Blood Plague][Frost Fever].
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bloodforged_armor = 5587, -- (410301) Death Strike reduces all Physical damage taken by $410305s1% for $410305d.
    dark_simulacrum   = 3511, -- (77606 ) Places a dark ward on an enemy player that persists for $d, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    death_chain       = 609 , -- (203173) Chains $x1 enemies together, dealing $m2 Shadow damage and causing $m1% of all damage taken to also be received by the others in the chain. Lasts for $d.
    decomposing_aura  = 3441, -- (199720) All enemies within $A2 yards slowly decay, losing up to $199721m1% of their max health every $m3 sec. Max $m2 stacks. Lasts 6 sec.
    last_dance        = 608 , -- (233412) Reduces the cooldown of Dancing Rune Weapon by $m1% and its duration by $m2%.
    murderous_intent  = 841 , -- (207018) [206891] You focus the assault on this target, increasing their damage taken by $s1% for $d. Each unique player that attacks the target increases the damage taken by an additional $s1%, stacking up to $u times.; Your melee attacks refresh the duration of Focused Assault.
    necrotic_aura     = 5513, -- (199642) All enemies within $a2 yards take $214968m1% increased magical damage.
    rot_and_wither    = 204 , -- (202727) Your $?s315442[Death's Due][Death and Decay] rots enemies each time it deals damage, absorbing healing equal to $s1% of damage dealt.
    spellwarden       = 5592, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by ${$s1/-1000} sec.
    strangulate       = 206 , -- (47476 ) Shadowy tendrils constrict an enemy's throat, silencing them for $d$?s58618[ (${$d+($58618m1/1000)} sec when used on a target who is casting a spell)][].
    walking_dead      = 205 , -- (202731) Your Death Grip causes the target to be unable to move faster than normal movement speed for $212610d.
} )

-- Auras
spec:RegisterAuras( {
    -- Recently pulled  by Abomination Limb and can't be pulled again.
    abomination_limb = {
        id = 383312,
        duration = 4.0,
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
        id = 221562,
        duration = 5.0,
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
        -- blood_death_knight[137008] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_death_knight[137008] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blood_death_knight[137008] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blood_plague[55078] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- frost_fever[55095] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- coagulopathy[391477] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- consumption[274156] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.5, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- rapid_decomposition[194662] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -18.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- rapid_decomposition[194662] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
        -- wither_away[441894] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- wither_away[441894] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- coagulopathy[391481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- brittle[374557] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- unholy_death_knight[137007] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sanguine_ground[391459] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sanguine_ground[391459] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Dealing $s1% reduced damage to $@auracaster.
    blooddrinker = {
        id = 458687,
        duration = 5.0,
        max_stack = 1,
    },
    -- Physical damage taken reduced by $w1%.
    bloodforged_armor = {
        id = 410305,
        duration = 3.0,
        max_stack = 1,
    },
    -- Strength increased by ${$W1}.1%.
    bloodied_blade = {
        id = 460499,
        duration = 15.0,
        max_stack = 1,
    },
    -- Physical damage taken reduced by $s1%.; Chance to gain Vampiric Strike increased by $434033s2%.
    bloodsoaked_ground = {
        id = 434034,
        duration = 3600,
        max_stack = 1,
    },
    -- Armor increased by ${$w1*$STR/100}.; $?a374715[Haste increased by $w4%.][]
    bone_shield = {
        id = 195181,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- foul_bulwark[206974] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- improved_bone_shield[374715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- reinforced_bones[374737] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- reinforced_bones[374737] #1: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'value': 37, 'schools': ['physical', 'fire', 'shadow'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Dealing $196528s1 Shadow damage to nearby enemies every $t3 sec, and healing for $196545s1% of maximum health for each target hit (up to ${$s1*$s4}%).
    bonestorm = {
        id = 194844,
        duration = 1.0,
        max_stack = 1,

        -- Affected by:
        -- veteran_of_the_third_war[48263] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
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
    -- Blood Plague damage is increased by $s1%.
    coagulopathy = {
        id = 391481,
        duration = 8.0,
        max_stack = 1,
    },
    -- Your Blood Plague deals damage $w5% more often.
    consumption = {
        id = 274156,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Controlled.
    control_undead = {
        id = 111673,
        duration = 300.0,
        max_stack = 1,
    },
    -- Parry chance increased by $s1%.
    dancing_rune_weapon = {
        id = 81256,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- everlasting_bond[377668] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- last_dance[233412] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
    -- When you take damage, $w1% of the damage is also dealt to enemies linked to you in this chain.
    death_chain = {
        id = 203173,
        duration = 10.0,
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
        -- vampiric_speed[434028] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Max health reduced by $w1%.
    decomposing_aura = {
        id = 199721,
        duration = 3600,
        tick_time = 2.0,
        max_stack = 1,
    },
    -- Movement Speed slowed by $w1% and damage dealt to $@auracaster reduced by $w2%.
    enfeeble = {
        id = 392490,
        duration = 6.0,
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
    -- Damage taken increased by $m1%.
    focused_assault = {
        id = 206891,
        duration = 6.0,
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
        -- blood_death_knight[137008] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_death_knight[137008] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blood_plague[55078] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- frost_fever[55095] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- wither_away[441894] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- wither_away[441894] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- brittle[374557] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- unholy_death_knight[137007] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sanguine_ground[391459] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sanguine_ground[391459] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Movement speed reduced by $s5%.
    heart_strike = {
        id = 206930,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- blood_plague[55078] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- improved_heart_strike[374717] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Damage and healing done by your next Death Strike increased by $s1%.
    hemostasis = {
        id = 273947,
        duration = 15.0,
        max_stack = 1,
    },
    -- Rooted.
    ice_prison = {
        id = 454787,
        duration = 4.0,
        max_stack = 1,
    },
    -- Attack speed increased by $w1%$?a436687[, and Runic Power spending abilities deal Shadowfrost damage.][.]
    icy_talons = {
        id = 194879,
        duration = 10.0,
        max_stack = 1,
    },
    -- Taking $w1% increased Shadow damage from $@auracaster.
    incite_terror = {
        id = 458478,
        duration = 15.0,
        max_stack = 1,
    },
    -- Time between auto-attacks increased by $w1%.
    insidious_chill = {
        id = 391568,
        duration = 30.0,
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
    -- Auto attacks will heal the victim for $206940s1% of their maximum health.
    mark_of_blood = {
        id = 206940,
        duration = 15.0,
        max_stack = 1,
    },
    -- Taking $w1% increased magical damage.
    necrotic_aura = {
        id = 214968,
        duration = 3.0,
        max_stack = 1,
    },
    -- Death Strike cost reduced by ${$m1/-10} Runic Power.
    ossuary = {
        id = 219788,
        duration = 3600,
        max_stack = 1,
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
    -- Versatility increased by $w1%
    perseverance_of_the_ebon_blade = {
        id = 374748,
        duration = 6.0,
        max_stack = 1,
    },
    -- You are a prey for the Deathbringer... This effect will explode for $436304s1 Shadowfrost damage for each stack.
    reapers_mark = {
        id = 434765,
        duration = 12.0,
        tick_time = 1.0,
        max_stack = 1,
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
    -- Damage taken reduced by $s1%.
    rune_tap = {
        id = 194679,
        duration = 4.0,
        max_stack = 1,
    },
    -- Damage dealt increased by $s1%.; Healing received increased by $s2%.
    sanguine_ground = {
        id = 391459,
        duration = 3600,
        max_stack = 1,
    },
    -- Absorbing the next ${$w1-1} healing received.; If any amount of heal absorption remains when this effect expires, you die.
    shroud_of_purgatory = {
        id = 116888,
        duration = 3.0,
        max_stack = 1,
    },
    -- Afflicted by Soul Reaper, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage.
    soul_reaper = {
        id = 343294,
        duration = 5.0,
        tick_time = 5.0,
        max_stack = 1,

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- unholy_death_knight[137007] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
    -- Silenced.
    tightening_grasp = {
        id = 374776,
        duration = 3.0,
        max_stack = 1,
    },
    -- Absorbing $w1 damage.
    tombstone = {
        id = 219809,
        duration = 8.0,
        max_stack = 1,
    },
    -- Absorbing damage dealt by Blood Plague.
    umbilicus_eternus = {
        id = 391519,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- improved_vampiric_blood[317133] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Haste increased by $w1%.
    unholy_ground = {
        id = 374271,
        duration = 3600,
        max_stack = 1,
    },
    -- Vampiric Aura's Leech amount increased by $s1% and is affecting $s2 nearby allies.
    vampiric_aura = {
        id = 434105,
        duration = 3600,
        max_stack = 1,
    },
    -- Maximum health increased by $s4%. Healing and absorbs received increased by $s1%.
    vampiric_blood = {
        id = 55233,
        duration = 10.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- improved_vampiric_blood[317133] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- improved_vampiric_blood[317133] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- improved_vampiric_blood[317133] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Movement speed increased by $w1%.
    vampiric_speed = {
        id = 434029,
        duration = 5.0,
        max_stack = 1,
    },
    -- The touch of the spirit realm lingers....
    voidtouched = {
        id = 97821,
        duration = 300.0,
        max_stack = 1,
    },
    -- Leech increased by $s1%.
    voracious = {
        id = 274009,
        duration = 8.0,
        max_stack = 1,
    },
    -- Unable to move faster than normal movement speed.
    walking_dead = {
        id = 212610,
        duration = 8.0,
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

    -- [55078] A shadowy disease that drains $o1 health from the target over $d.  
    blood_boil = {
        id = 50842,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "blood_boil",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'ap_bonus': 0.56304, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- blood_death_knight[137008] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_death_knight[137008] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blood_plague[55078] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- frost_fever[55095] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- bind_in_darkness[440031] #1: { 'type': APPLY_AURA, 'subtype': MOD_ABILITY_SCHOOL_MASK, 'points': 60.0, 'value': 48, 'schools': ['frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- brittle[374557] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- unholy_death_knight[137007] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sanguine_ground[391459] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sanguine_ground[391459] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Drains $o1 health from the target over $d. The damage they deal to you is reduced by $s2% for the duration and $458687d after channeling it fully.; You can move, parry, dodge, and use defensive abilities while channeling this ability.; Generates ${$s3*4/10} additional Runic Power over the duration.
    blooddrinker = {
        id = 206931,
        cast = 3.0,
        channeled = true,
        cooldown = 30.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        talent = "blooddrinker",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_LEECH, 'amplitude': 1.25, 'tick_time': 1.0, 'ap_bonus': 0.639, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_TARGET_RESIST, 'amplitude': 1.25, 'points': -20.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_ENERGIZE, 'amplitude': 1.25, 'tick_time': 1.0, 'points': 50.0, 'value': 6, 'schools': ['holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Consume your Bone Shield charges to create a whirl of bone and gore that batters all nearby enemies, dealing $196528s1 Shadow damage every $t3 sec, and healing you for $196545s1% of your maximum health every time it deals damage (up to ${$s1*$s4}%). Deals reduced damage beyond $196528s2 targets.; Lasts $d per Bone Shield charge spent and rapidly regenerates a Bone Shield every $t3 sec.
    bonestorm = {
        id = 194844,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "bonestorm",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 196528, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- veteran_of_the_third_war[48263] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
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

    -- Strikes all enemies in front of you with a hungering attack that deals $sw1 Physical damage and heals you for ${$e1*100}% of that damage. Deals reduced damage beyond $s3 targets.; Causes your Blood Plague damage to occur $s5% more quickly for $d. ; Generates $s4 Runes.
    consumption_274156 = {
        id = 274156,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        talent = "consumption_274156",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': HEALTH_LEECH, 'subtype': NONE, 'amplitude': 1.5, 'ap_bonus': 0.78624, 'radius': 8.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 274893, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'resource': runes, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.5, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        from = "spec_talent",
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

    -- Summons a rune weapon for $81256d that mirrors your melee attacks and bolsters your defenses.; While active, you gain $81256s1% parry chance.
    dancing_rune_weapon = {
        id = 49028,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "dancing_rune_weapon",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'amplitude': 1.0, 'points': 1.0, 'value': 27893, 'schools': ['physical', 'fire', 'frost', 'shadow', 'arcane'], 'value1': 3242, 'radius': 2.0, 'target': TARGET_DEST_TARGET_FRONT, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'trigger_spell': 1206, 'points': 50707.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- everlasting_bond[377668] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- last_dance[233412] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- last_dance[233412] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
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
        -- rapid_decomposition[194662] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -18.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
    },

    -- Chains $x1 enemies together, dealing $m2 Shadow damage and causing $m1% of all damage taken to also be received by the others in the chain. Lasts for $d.
    death_chain = {
        id = 203173,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'chain_targets': 3, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 3, 'ap_bonus': 0.29483998, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- blood_death_knight[137008] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_death_knight[137008] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blood_death_knight[137008] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 139.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- blood_plague[55078] #3: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- frost_fever[55095] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- improved_death_strike[374277] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- improved_death_strike[374277] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- improved_death_strike[374277] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- voracious[273953] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- voracious[273953] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- blood_draw[454871] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- hemostasis[273947] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- brittle[374557] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- unholy_death_knight[137007] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- unholy_death_knight[137007] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ossuary[219788] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- sanguine_ground[391459] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sanguine_ground[391459] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- vampiric_speed[434028] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- [55078] A shadowy disease that drains $o1 health from the target over $d.  
    deaths_caress = {
        id = 195292,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.19017, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 55078, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
    },

    -- Shadowy tendrils coil around all enemies within $A2 yards of a hostile or friendly target, pulling them to the target's location.
    gorefiends_grasp = {
        id = 108199,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "gorefiends_grasp",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'mechanic': knockbacked, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'mechanic': knockbacked, 'radius': 15.0, 'target': TARGET_DEST_TARGET_ANY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'mechanic': knockbacked, 'radius': 15.0, 'target': TARGET_DEST_TARGET_ANY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- tightening_grasp[206970] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Instantly strike the target and 1 other nearby enemy, causing $s2 Physical damage, and reducing enemies' movement speed by $s5% for $d$?s316575[; Generates $s3 bonus Runic Power][]$?s221536[, plus ${$210738s1/10} Runic Power per additional enemy struck][].
    heart_strike = {
        id = 206930,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 1,
        spendType = 'runes',

        spend = -150,
        spendType = 'runic_power',



        talent = "heart_strike",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'chain_targets': 2, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 2, 'ap_bonus': 0.475042, 'pvp_multiplier': 1.2, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'chain_targets': 2, 'mechanic': snared, 'points': -20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- blood_plague[55078] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'target': TARGET_UNIT_TARGET_ANY, }
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- improved_heart_strike[374717] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

    -- Places a Mark of Blood on an enemy for $d. The enemy's damaging auto attacks will also heal their victim for $206940s1% of the victim's maximum health.
    mark_of_blood = {
        id = 206940,
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        talent = "mark_of_blood",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- [195181] Surrounds you with a barrier of whirling bones, increasing Armor by ${$s1*$STR/100}$?s316746[, and your Haste by $s4%][]. Each melee attack against you consumes a charge. Lasts $d or until all charges are consumed.
    marrowrend = {
        id = 195182,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 2,
        spendType = 'runes',

        spend = -200,
        spendType = 'runic_power',

        talent = "marrowrend",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 1, 'ap_bonus': 0.63954, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'chain_targets': 1, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
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

    -- [206891] You focus the assault on this target, increasing their damage taken by $s1% for $d. Each unique player that attacks the target increases the damage taken by an additional $s1%, stacking up to $u times.; Your melee attacks refresh the duration of Focused Assault.
    murderous_intent = {
        id = 207018,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 206891, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
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
        -- newly_turned[433934] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
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

    -- Reduces all damage taken by $s1% for $d.
    rune_tap = {
        id = 194679,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "none",

        spend = 1,
        spendType = 'runes',

        spend = -100,
        spendType = 'runic_power',

        talent = "rune_tap",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -20.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
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
        -- death_knight[137005] #1: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- unholy_death_knight[137007] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

    -- Consume up to $s5 Bone Shield charges. For each charge consumed, you gain $s3 Runic Power and absorb damage equal to $s4% of your maximum health for $d.
    tombstone = {
        id = 219809,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "tombstone",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': runic_power, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, }
    },

    -- Embrace your undeath, increasing your maximum health by $s4% and increasing all healing and absorbs received by $s1% for $d.
    vampiric_blood = {
        id = 55233,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        talent = "vampiric_blood",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_PCT, 'points': 30.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_HEALTH, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_ABSORB_EFFECTS_TAKEN_PCT, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_LEECH, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- improved_vampiric_blood[317133] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- improved_vampiric_blood[317133] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- improved_vampiric_blood[317133] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
        -- vampiric_speed[434028] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

} )