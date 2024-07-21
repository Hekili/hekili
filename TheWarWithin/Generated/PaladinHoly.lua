-- PaladinHoly.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 65 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.HolyPower )

spec:RegisterTalents( {
    -- Paladin Talents
    auras_of_the_resolute           = { 81599, 385633, 1 }, -- [317920] Interrupt and Silence effects on party and raid members within $a1 yds are $s1% shorter. $?a339124[Fear effects are also reduced.][]
    avenging_wrath                  = { 81606, 31884 , 1 }, -- Call upon the Light and become an avatar of retribution, increasing your damage and healing done by $s1% for $31884d, and allowing Hammer of Wrath to be cast on any target.; Combines with other Avenging Wrath abilities, granting all known Avenging Wrath effects while active.
    blessing_of_freedom             = { 81600, 1044  , 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects $?s199325[and increasing movement speed by $199325m1% ][]for $d.
    blessing_of_protection          = { 81616, 1022  , 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for $d.; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.$?c2[; Shares a cooldown with Blessing of Spellwarding.][]
    blessing_of_sacrifice           = { 81614, 6940  , 1 }, -- Blesses a party or raid member, reducing their damage taken by $s1%, but you suffer ${100*$e1}% of damage prevented.; Last $d, or until transferred damage would cause you to fall below $s3% health.
    blinding_light                  = { 81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within $105421A1 yds, causing them to wander disoriented for $105421d.
    cavalier                        = { 81605, 230332, 1 }, -- Divine Steed now has ${1+$m1} charges.
    crusader_aura                   = { 81601, 32223 , 1 }, -- Increases mounted speed by $s1% for all party and raid members within $a1 yds.
    divine_steed                    = { 81632, 190784, 1 }, -- Leap atop your Charger for $221883d, increasing movement speed by $221883s4%. Usable while indoors or in combat.
    divine_toll                     = { 81496, 375576, 1 }, -- Instantly cast $?a137029[Holy Shock]?a137028[Avenger's Shield]?a137027[Judgment][Holy Shock, Avenger's Shield, or Judgment] on up to $s1 targets within $A2 yds.$?(a384027|a386738|a387893)[; After casting Divine Toll, you instantly cast ][]$?(a387893&c1)[Holy Shock]?(a386738&c2)[Avenger's Shield]?(a384027&c3)[Judgment][]$?a387893[ every $387895t1 sec. This effect lasts $387895d.][]$?a384027[ every $384029t1 sec. This effect lasts $384029d.][]$?a386738[ every $386730t1 sec. This effect lasts $386730d.][]$?c3[; Divine Toll's Judgment deals $326011s1% increased damage.][]$?c2[; Generates $s5 Holy Power per target hit.][]
    fading_light                    = { 81623, 405768, 1 }, -- $@spellicon385127$@spellname385127:; Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional $s1%.; $@spellicon385126$@spellname385126:; Blessing of Dusk causes your Holy Power generating abilities to also grant an absorb shield for $s2% of damage or healing dealt.
    faiths_armor                    = { 81495, 406101, 1 }, -- [379017] $?c2[Shield of the Righteous][Word of Glory] grants $s1% bonus armor for $d.
    fist_of_justice                 = { 81602, 234299, 2 }, -- Each Holy Power spent reduces the remaining cooldown on Hammer of Justice by $s1 sec.
    golden_path                     = { 81610, 377128, 1 }, -- Consecration heals you and $s2 allies within it for $<points> every $26573t1 sec.
    hammer_of_wrath                 = { 81510, 24275 , 1 }, -- Hurls a divine hammer that strikes an enemy for $<damage> $?s403664[Holystrike][Holy] damage. Only usable on enemies that have less than 20% health$?s326730[, or during Avenging Wrath][].; Generates $s2 Holy Power.
    holy_aegis                      = { 81609, 385515, 2 }, -- Armor and critical strike chance increased by $s2%.
    improved_blessing_of_protection = { 81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection$?c2[ and Blessing of Spellwarding][] by ${-$s1/1000} sec.
    incandescence                   = { 81628, 385464, 1 }, -- Each Holy Power you spend has a $s1% chance to cause your $?s198034[Divine Hammer][Consecration] to flare up, dealing $385816s1 Holy damage to up to $s1 enemies standing within it.
    judgment_of_light               = { 81608, 183778, 1 }, -- Judgment causes the next $196941N successful attacks against the target to heal the attacker for $183811s1. $@switch<$s2>[][This effect can only occur once every $s1 sec on each target.]
    justification                   = { 81509, 377043, 1 }, -- Judgment's damage is increased by $s1%.
    lay_on_hands                    = { 81597, 633   , 1 }, -- Heals a friendly target for an amount equal to $s2% your maximum health.$?a387791[; Grants the target $387792s1% increased armor for $387792d.][]; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.
    obduracy                        = { 81630, 385427, 1 }, -- Speed increased by $s3% and damage taken from area of effect attacks reduced by $s2%.
    punishment                      = { 93165, 403530, 1 }, -- Successfully interrupting an enemy with Rebuke$?s31935[ or Avenger's Shield][] casts an extra $?s204019[Blessed Hammer]?s53595[Hammer of the Righteous][Crusader Strike].
    rebuke                          = { 81604, 96231 , 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for $d.
    recompense                      = { 81607, 384914, 1 }, -- After your Blessing of Sacrifice ends, $s1% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing.; This effect's bonus damage cannot exceed $s3% of your maximum health and its bonus healing cannot exceed $s4% of your maximum health.
    repentance                      = { 81598, 20066 , 1 }, -- Forces an enemy target to meditate, incapacitating them for $d.; Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    sacrifice_of_the_just           = { 81607, 384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by ${$m1/-1000} sec.
    sanctified_plates               = { 93009, 402964, 2 }, -- Armor increased by $s3%, Stamina increased by $s1% and damage taken from area of effect attacks reduced by $s2%.
    seal_of_alacrity                = { 81619, 385425, 2 }, -- Haste increased by $s1% and Judgment cooldown reduced by ${$abs($s2)/1000}.1 sec.
    seal_of_mercy                   = { 81611, 384897, 1 }, -- Golden Path strikes the lowest health ally within it an additional time for $s1% of its effect.
    seal_of_might                   = { 81621, 385450, 2 }, -- Mastery increased by $s2% and $?c1[intellect][strength] increased by $s1%.
    seal_of_order                   = { 81623, 385129, 1 }, -- $@spellicon385127$@spellname385127:; Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional $s3%.; $@spellicon385126$@spellname385126:; Blessing of Dusk increases your armor by $s2% and your Holy Power generating abilities cooldown $s1% faster.
    seasoned_warhorse               = { 81631, 376996, 1 }, -- Increases the duration of Divine Steed by ${$s1/1000} sec.
    strength_of_conviction          = { 81480, 379008, 2 }, -- While in your Consecration, your $?s2812[Denounce][Shield of the Righteous] and Word of Glory have $s1% increased initial damage and healing.
    touch_of_light                  = { 81543, 385349, 1 }, -- Your spells and abilities have a chance to cause your target to erupt in a blinding light dealing $385354s1 Holy damage or healing an ally for $385352s1 health.
    turn_evil                       = { 93010, 10326 , 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to $d. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbreakable_spirit              = { 81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, $?s184662[Shield of Vengeance, ][]$?s31850[Ardent Defender][Divine Protection], and Lay on Hands by $s1%.

    -- Holy Talents
    afterimage                      = { 81613, 385414, 1 }, -- After you spend $s3 Holy Power, your next Word of Glory echoes onto a nearby ally at $s1% effectiveness.
    aura_mastery                    = { 81567, 31821 , 1 }, -- Empowers your chosen aura for $d.$?a344218[; $@spellname465: Damage reduction increased to ${-$s1-$465s2}%.][]$?a344219[; $@spellname32223: Mount speed bonus increased to ${$s2+$32223s4}%.][]$?a344217[; $@spellname183435: Increases healing received by $s3% while its effect is active.][]$?a344220[; $@spellname317920: Affected allies immune to interrupts and silences.][]
    aurora                          = { 95069, 439760, 1 }, -- [223819] Your next Holy Power ability is free and deals $s2% increased damage and healing.
    avenging_crusader               = { 81584, 216331, 1 }, -- You become the ultimate crusader of light for $216331d. Crusader Strike and Judgment cool down $216331s2% faster and heal up to $216331s6 injured allies for $216331s5% of the damage they deal.; If Avenging Wrath is known, also increases Judgment, Crusader Strike, and auto-attack damage by $216331s1%.
    avenging_wrath_might            = { 81584, 31884 , 1 }, -- Call upon the Light and become an avatar of retribution, increasing your critical strike chance by $s1% for $31884d.; Combines with other Avenging Wrath abilities.
    awakening                       = { 81592, 414195, 1 }, -- While in combat, your Holy Power spenders generate $s3 stack of Awakening.; At $s1 stacks of Awakening, your next Judgment deals $414193s1% increased damage, will critically strike, and activates $?a394088[Avenging Crusader][Avenging Wrath] for $?a394088[${$s2-$s4}][$s2] sec.
    awestruck                       = { 81564, 417855, 1 }, -- Holy Shock, Holy Light, and Flash of Light critical healing increased by $s1%.
    barrier_of_faith                = { 81577, 148039, 1 }, -- Imbue a friendly target with a Barrier of Faith, absorbing $<shield> damage for $395180d. For the next $d, Barrier of Faith accumulates $s2% of effective healing from your Flash of Light, Holy Light, or Holy Shock spells. Every $t2 sec, the accumulated healing becomes an absorb shield.
    beacon_of_faith                 = { 81554, 156910, 1 }, -- Mark a second target as a Beacon, mimicking the effects of Beacon of Light. Your heals will now heal both of your Beacons, but at $s4% reduced effectiveness.
    beacon_of_the_lightbringer      = { 81568, 197446, 1 }, -- Mastery: Lightbringer now increases your healing based on the target's proximity to either you or your Beacon of Light, whichever is closer.
    beacon_of_virtue                = { 81554, 200025, 1 }, -- Apply a Beacon of Light to your target and $s2 injured allies within $A2 yds for $d.; All affected allies will be healed for $53651s1% of the amount of your other healing done.
    bestow_light                    = { 81560, 448040, 1 }, -- Light of the Martyr's health threshold is reduced to ${$s4+$s1}% and increases Holy Shock's healing by an additional $448087s1% for every $t2 sec Light of the Martyr is active, stacking up to $448087u times.; While below ${$s4+$s1}% health, the light urgently heals you for $448086s1 every $448086t1 sec.
    blessed_assurance               = { 95235, 433015, 1 }, -- Casting a Holy Power ability increases the damage and healing of your next $?s204019[Blessed Hammer]?s53595[Hammer of the Righteous][Crusader Strike] by $433019s1%.
    blessing_of_anshe               = { 95071, 445200, 1 }, -- Your damage and healing over time effects have a chance to increase the $?c1[healing or damage of your next Holy Shock by $445204s1%.]?c3[damage of your next Hammer of Wrath by $445206s1% and make it usable on any target, regardless of their health.][]
    blessing_of_summer              = { 81593, 388007, 1 }, -- Bless an ally for $d, causing $s1% of all healing to be converted into damage onto a nearby enemy and $s4% of all damage to be converted into healing onto an injured ally within $448227A1 yds.; Blessing of the Seasons: Turns to Autumn after use.
    blessing_of_the_forge           = { 95230, 433011, 1 }, -- Avenging Wrath summons an additional $@spellicon432502 Sacred Weapon, and during Avenging Wrath your Sacred Weapon casts spells on your target and echoes the effects of your Holy Power abilities.
    boundless_salvation             = { 81587, 392951, 1 }, -- Your Holy Shock, Flash of Light, and Holy Light spells extend the duration of Tyr's Deliverance on yourself when cast on targets affected by Tyr's Deliverance.; $@spellicon20473$@spellname20473: Extends ${$s4/1000}.1 sec.; $@spellicon19750$@spellname19750: Extends ${$s1/1000}.1 sec.; $@spellicon82326 $@spellname82326: Extends ${$s2/1000}.1 sec.; Tyr's Deliverance can be extended up to a maximum of $s3 sec.
    breaking_dawn                   = { 81583, 387879, 2 }, -- Increases the range of Light of Dawn to $s1 yds.
    commanding_light                = { 81580, 387781, 1 }, -- Beacon of Light transfers an additional $s1% of the amount healed.
    crusaders_might                 = { 81594, 196926, 1 }, -- Crusader Strike reduces the cooldown of Holy Shock and Judgment by ${$m1/-1000}.1 sec.
    dawnlight                       = { 95099, 431377, 1 }, -- Casting $?c1[Holy Prism or Barrier of Faith]?c3[Wake of Ashes][] causes your next $431522u Holy Power spending abilities to apply Dawnlight on your target, dealing $431380o1 Radiant damage or $431381o1 healing over $431380d.; $431581s1% of Dawnlight's damage and healing radiates to nearby allies or enemies, reduced beyond $431581s2 targets.
    divine_favor                    = { 81570, 460422, 1 }, -- After casting Barrier of Faith or Holy Prism, the healing of your next Holy Light or Flash of Light is increased by $210294m1%, its cast time is reduced by $210294s2%, and its mana cost is reduced by $210294s3%.; 
    divine_glimpse                  = { 81585, 387805, 1 }, -- Holy Shock and Judgment have a $s1% increased critical strike chance.
    divine_guidance                 = { 95235, 433106, 1 }, -- For each Holy Power ability cast, your next Consecration deals $<value> damage or healing immediately, split across all enemies and allies.
    divine_inspiration              = { 95231, 432964, 1 }, -- Your spells and abilities have a chance to manifest a Holy Armament for a nearby ally.
    divine_purpose                  = { 93191, 223817, 1 }, -- Holy Power spending abilities have a $s1% chance to make your next Holy Power spending ability free and deal $223819s2% increased damage and healing.
    divine_resonance                = { 93180, 386738, 1 }, -- [386732] After casting Divine Toll, you instantly cast $?c2[Avenger's Shield]?c1[Holy Shock][Judgment] every $386730t1 sec for $386730s2 sec.
    divine_revelations              = { 81578, 387808, 1 }, -- While empowered by Infusion of Light, Flash of Light heals for an additional $s2%, and Holy Light or Judgment refund ${$s1/1000}.1% of your maximum mana.
    echoing_blessings               = { 93520, 387801, 1 }, -- Blessing of Freedom increases the target's movement speed by $s3%. $?s204018[Blessing of Spellwarding][Blessing of Protection] and Blessing of Sacrifice reduce the target's damage taken by $s4%. These effects linger for $339324d after the Blessing ends.
    empyrean_legacy                 = { 81591, 387170, 1 }, -- Judgment empowers your next $?c3[Single target Holy Power ability to automatically activate Divine Storm][Word of Glory to automatically activate Light of Dawn] with $s2% increased effectiveness.; This effect can only occur every $387441d.
    eternal_flame                   = { 95095, 156322, 1 }, -- Heals an ally for $s2 and an additional $o1 over $d.; Healing increased by $s3% when cast on self.
    excoriation                     = { 95232, 433896, 1 }, -- Enemies within $439632a1 yards of Hammer of Justice's target are slowed by $439632s1% for $439632d.
    extrication                     = { 81569, 461278, 1 }, -- Word of Glory and Light of Dawn gain up to $s1% additional chance to critically strike, based on their target's current health. Lower health targets are more likely to be critically struck.
    fear_no_evil                    = { 95232, 432834, 1 }, -- While wielding an Armament the duration of Fear effects is reduced by $s1%.
    forewarning                     = { 95231, 432804, 1 }, -- The cooldown of Holy Armaments is reduced by $s1%.
    gleaming_rays                   = { 95073, 431480, 1 }, -- While a Dawnlight is active, your Holy Power spenders deal $431481s1% additional damage or healing.
    glistening_radiance             = { 81576, 461245, 1 }, -- Spending Holy Power has a $s1% chance to trigger Saved By The Light's absorb effect at $s2% effectiveness without activating its cooldown.
    glorious_dawn                   = { 93521, 461246, 1 }, -- Holy Shock has a $s1% chance to refund a charge when cast and its healing is increased by $s2%.
    greater_judgment                = { 92220, 231644, 1 }, -- Judgment deems the target unworthy, preventing the next $<shield> damage dealt by the target.; 
    hammer_and_anvil                = { 95238, 433718, 1 }, -- Judgment critical strikes cause a shockwave around the target, dealing $?c1[$433722s1][$433717s1] $?c1[healing][damage] at the target's location.
    hand_of_divinity                = { 81570, 414273, 1 }, -- Call upon the Light to empower your spells, causing your next $n Holy Lights to heal $s1% more, cost $s3% less mana, and be instant cast.
    holy_bulwark                    = { 95234, 432459, 1 }, -- [432496] While wielding a Holy Bulwark, gain an absorb shield for ${$s2/10}.1% of your max health and an additional ${$s4/10}.1% every $t2 sec. Lasts $d.
    holy_infusion                   = { 81564, 414214, 1 }, -- Crusader Strike generates $s1 additional Holy Power and deals $s2% more damage.
    holy_prism                      = { 81577, 114165, 1 }, -- Fires a beam of light that scatters to strike a clump of targets. ; If the beam is aimed at an enemy target, it deals $114852s1 Holy damage and radiates ${$114852s2*$<healmod>} healing to 5 allies within $114852A2 yds.; If the beam is aimed at a friendly target, it heals for ${$114871s1*$<healmod>} and radiates $114871s2 Holy damage to 5 enemies within $114871A2 yds.
    holy_shock                      = { 81555, 20473 , 1 }, -- Triggers a burst of Light on the target, dealing $25912s1 Holy damage to an enemy, or $25914s1 healing to an ally.$?s272906[  Has an additional $272906s1% critical strike chance.][]; Generates $s2 Holy Power.; 
    illumine                        = { 95098, 431423, 1 }, -- Dawnlight reduces the movement speed of enemies by $431380s3% and increases the movement speed of allies by $431381s3%.
    imbued_infusions                = { 81557, 392961, 1 }, -- Consuming Infusion of Light reduces the cooldown of Holy Shock by ${$s1/-1000}.1 sec.
    improved_cleanse                = { 81508, 393024, 1 }, -- Cleanse additionally removes all Disease and Poison effects.
    inflorescence_of_the_sunwell    = { 81591, 392907, 1 }, -- Infusion of Light has $s1 additional charge, increases Greater Judgment's effect by an additional $s4%, reduces the cost of Flash of Light by an additional $s2%, and Holy Light's healing is increased by an additional $s3%.
    laying_down_arms                = { 95236, 432866, 1 }, -- When an Armament fades from you, the cooldown of Lay on Hands is reduced by ${$s1/1000}.1 sec and you gain $?a137028[Shining Light][Infusion of Light].
    liberation                      = { 102502, 461287, 1 }, -- Word of Glory and Light of Dawn have a chance equal to your haste to reduce the cost of your next Holy Light, Crusader Strike, or Judgment by $461471s1.
    light_of_dawn                   = { 81565, 85222 , 1 }, -- Unleashes a wave of Holy energy, healing up to $s1 injured allies within a $?a337812[$a3]?a387879[$a3][$a1] yd frontal cone for $225311s1.
    light_of_the_martyr             = { 81561, 447985, 1 }, -- While above $s1% health, Holy Shock's healing is increased $447988s1%, but creates a heal absorb on you for $s2% of the amount healed that prevents Beacon of Light from healing you until it has dissipated.
    lightforged_blessing            = { 93168, 406468, 1 }, -- $?s2812[Denounce][Shield of the Righteous] heals you and up to $s3 nearby allies for ${$53600s2}.1% of maximum health.
    lights_conviction               = { 93927, 414073, 1 }, -- Holy Shock now has ${$s1+1} charges.
    lights_protection               = { 93522, 461243, 1 }, -- Allies with Beacon of Light receive $s1% less damage.
    lingering_radiance              = { 95071, 431407, 1 }, -- Dawnlight leaves an Eternal Flame for ${$s1/1000} sec on allies or a Greater Judgment on enemies when it expires or is extended.
    luminosity                      = { 95080, 431402, 1 }, -- $?c1[Critical Strike chance of Holy Shock and Light of Dawn increased by $s1%.]?c3[Critical Strike chance of Hammer of Wrath and Divine Storm increased by $s2%.][]
    merciful_auras                  = { 81593, 183415, 1 }, -- Your auras restore $210291s1 health to $210291s2 injured allies within $210291A1 yds every $t1 sec.; While Aura Mastery is active, heals all allies within ${$210291A1+$31821s5} yds and healing is increased by $31821s6%.
    moment_of_compassion            = { 81571, 387786, 1 }, -- Your Flash of Light heals for an additional $s1% when cast on a target affected by your Beacon of Light.
    morning_star                    = { 95073, 431482, 1 }, -- Every ${$t1}.1 sec, your next Dawnlight's damage or healing is increased by $431539s1%, stacking up to $431539u times.; Morning Star stacks twice as fast while out of combat.
    of_dusk_and_dawn                = { 93357, 409439, 1 }, -- [385127] Your next Holy Power spending ability deals $s1% additional increased damage and healing. This effect stacks.
    overflowing_light               = { 81556, 461244, 1 }, -- $s1% of Holy Shock's overhealing is converted into an absorb shield. The shield amount cannot exceed $s2% of your max health.
    power_of_the_silver_hand        = { 81589, 200474, 1 }, -- Holy Light, Flash of Light, and Judgment have a chance to grant you Power of the Silver Hand, increasing the healing of your next Holy Shock by $200656s1% of all damage and effective healing you do within the next $200656d, up to a maximum of ${$MHP*$s1/100}. 
    protection_of_tyr               = { 81566, 200430, 1 }, -- Aura Mastery also increases all healing received by party or raid members within $211210A1 yards by $s1%.
    quickened_invocation            = { 93180, 379391, 1 }, -- Divine Toll's cooldown is reduced by ${-$s1/1000} sec.
    reclamation                     = { 81558, 415364, 1 }, -- Holy Shock and Crusader Strike refund up to $s1% of their Mana cost and deal up to $s2% more healing or damage, based on the target's missing health.
    relentless_inquisitor           = { 81590, 383388, 1 }, -- Spending Holy Power grants you $s1% haste per finisher for $383389d, stacking up to ${$s2+$s3} times.
    resplendent_light               = { 81571, 392902, 1 }, -- Holy Light heals up to $s2 targets within $392903a1 yds for $s1% of its healing.
    righteous_judgment              = { 93523, 414113, 1 }, -- Judgment has a $s1% chance to cast Consecration at the target's location.; The limit on Consecration does not apply to this effect.
    rising_sunlight                 = { 81595, 461250, 1 }, -- $?s216331[After casting Avenging Crusader, your next Holy Shock casts $414204s1 additional times.][After casting Avenging Wrath, your next $s2 Holy Shocks cast $414204s1 additional times.]; After casting Divine Toll, your next $s2 Holy Shocks cast $414204s1 additional times.
    rite_of_adjuration              = { 95233, 433583, 1 }, -- Imbue your weapon with the power of the Light, increasing your Stamina by $433584s1% and causing your Holy Power abilities to sometimes unleash a burst of healing around a target.; Lasts $433584d.
    rite_of_sanctification          = { 95233, 433568, 1 }, -- Imbue your weapon with the power of the Light, increasing your armor by $433550s2% and your primary stat by $433550s1%.; Lasts $433550d.
    sanctified_wrath                = { 81592, 53376 , 1 }, -- Call upon the Light and become an avatar of retribution for $<time> sec, $?c1[reducing Holy Shock's cooldown by $s2%.]?c2[causing Judgment to generate $s3 additional Holy Power.]?c3[each Holy Power spent causing you to explode with Holy light for $326731s1 damage to nearby enemies.][.]; Combines with Avenging Wrath.; 
    saved_by_the_light              = { 81574, 157047, 1 }, -- When an ally with your Beacon of Light is damaged below $s1% health, they absorb the next $<shield> damage.; You cannot shield the same person this way twice within $157131d.
    seal_of_the_crusader            = { 93683, 416770, 2 }, -- Your auto attacks heal a nearby ally for ${$385723s1*(1+$s2/100)}.
    second_sunrise                  = { 95086, 431474, 1 }, -- $?c1[Light of Dawn and Holy Shock have a $s1% chance to cast again at $s2% effectiveness.]?c3[Divine Storm and Hammer of Wrath have a $s1% chance to cast again at $s2% effectiveness.][]
    shared_resolve                  = { 95237, 432821, 1 }, -- The effect of your active Aura is increased by $432496s1% on targets with your Armaments.
    shining_righteousness           = { 81562, 414443, 1 }, -- $?s2812[Denounce][Shield of the Righteous] deals $414448s1 damage to its first target struck.; Every $s1 $?s2812[Denounces][Shields of the Righteous] make your next Word of Glory or Light of Dawn cost no Holy Power.
    solar_grace                     = { 95094, 431404, 1 }, -- Your Haste is increased by $439841s1% for $439841d each time you apply Dawnlight. Multiple stacks may overlap.
    solidarity                      = { 95228, 432802, 1 }, -- If you bestow an Armament upon an ally, you also gain its benefits.; If you bestow an Armament upon yourself, a nearby ally also gains its benefits.
    sun_sear                        = { 95072, 431413, 1 }, -- $?c1[Holy Shock and Light of Dawn critical strikes cause the target to be healed for an additional $431415o1 over $431415d.]?c3[Hammer of Wrath and Divine Storm critical strikes cause the target to burn for an additional $431414o1 Radiant damage over $431414d.][]
    suns_avatar                     = { 95105, 431425, 1 }, -- During Avenging Wrath, you become linked to your Dawnlights, causing $431911s1 Radiant damage to enemies or $431939s1 healing to allies that pass through the beams, reduced beyond $s6 targets.; Activating Avenging Wrath applies up to $s3 Dawnlights onto nearby allies or enemies and increases Dawnlight's duration by $s5%.
    tirions_devotion                = { 81573, 414720, 1 }, -- Lay on Hands' cooldown is reduced by ${$s1/1000}.1 sec per Holy Power spent and restores $415299s1% of your Mana.
    tower_of_radiance               = { 81586, 231642, 1 }, -- Casting Flash of Light or Holy Light grants $s1 Holy Power.
    truth_prevails                  = { 81579, 461273, 1 }, -- Judgment heals you for $461546s1 and its cost is reduced by $s1%. $s2% of overhealing from this effect is transferred onto $s3 allies within $461529a1 yds.
    tyrs_deliverance                = { 81588, 200652, 1 }, -- Releases the Light within yourself, healing $s2 injured allies instantly and an injured ally every $t1 sec for $d within $200653A1 yds for $200654s1.; Allies healed also receive $200654s2% increased healing from your Holy Light, Flash of Light, and Holy Shock spells for $200654d.
    unending_light                  = { 81575, 387998, 1 }, -- Each Holy Power spent on Light of Dawn increases the healing of your next Word of Glory by $s1%, up to a maximum of $s2%.
    unwavering_spirit               = { 81566, 392911, 1 }, -- The cooldown of Aura Mastery is reduced by ${$s1/-1000} sec.
    valiance                        = { 95229, 432919, 1 }, -- Consuming $?a137028[Shining Light][Infusion of Light] reduces the cooldown of Holy Armaments by ${$s1/1000}.1 sec.
    vanguards_momentum              = { 93176, 416869, 1 }, -- Hammer of Wrath has $s1 extra charge and on enemies below $s2% health generates ${$403081s1} additional Holy Power.  
    veneration                      = { 81581, 392938, 1 }, -- Hammer of Wrath heals up to $s2 injured allies for $414411s2% of the damage done, split evenly among them.; Flash of Light, Holy Light, and Judgment critical strikes reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    will_of_the_dawn                = { 95098, 431406, 1 }, -- Movement speed increased by $431462s1% while above $s1% health.; When your health is brought below $s3%, your movement speed is increased by $431752s1% for $431752d. Cannot occur more than once every $456779d.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    blessed_hands           = 88  , -- (199454) Your Blessing of Protection and Blessing of Freedom spells now have 1 additional charge.
    cleanse_the_weak        = 642 , -- (199330) When you Cleanse an ally, $s2 ally within $s3 yds $?$s2>$s5[are][is] dispelled of the same effects, but the cooldown of Cleanse is increased by ${$s4/1000} sec.; Healing allies with your Flash of Light or Holy Light will cleanse all Diseases and Poisons from the target.
    darkest_before_the_dawn = 86  , -- (210378) Every $t1 sec the healing done by your next Light of Dawn is increased by $m1%. Stacks up to $210391u times.
    denounce                = 5618, -- (2812  ) Casts down the enemy with a bolt of Holy Light, causing $s1 Holy damage and preventing the target from causing critical effects for the next $d.
    divine_vision           = 640 , -- (199324) Increases the range of your Aura by $m1 yards and reduces the cooldown of Aura Mastery by ${$s3/-1000} sec.
    hallowed_ground         = 3618, -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    judgments_of_the_pure   = 5657, -- (355858) Casting Judgment on an enemy cleanses $s1 Poison, Disease, and Magic effect they have caused on you.
    searing_glare           = 5583, -- (410126) Call upon the light to blind your enemies in a $410201a1 yd cone, causing enemies to miss their spells and attacks for $410201d.
    spreading_the_word      = 87  , -- (199456) Your allies affected by your Aura gain an effect after you cast Blessing of Protection or Blessing of Freedom.; $@spellicon1022 $@spellname1022; Physical damage reduced by $199507m1% for $199507d.; $@spellicon1044 $@spellname1044; Cleared of all movement impairing effects.
    ultimate_sacrifice      = 85  , -- (199452) Your Blessing of Sacrifice now transfers $m2% of all damage to you into a damage over time effect, but lasts $199448d and no longer cancels when you are below $6940s3% health.
    wrench_evil             = 5651, -- (460720) Turn Evil's cast time is reduced by $s1%.
} )

-- Auras
spec:RegisterAuras( {
    -- Aura effectiveness increased.
    aura_mastery = {
        id = 412629,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- unwavering_spirit[392911] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- divine_vision[199324] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- divine_vision[199324] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },
    -- Crusader Strike and Judgment cool down $w2% faster.$?a384376[; Judgment, Crusader Strike, and auto-attack damage increased by $s1%.][]; $w6 nearby allies will be healed for $w5% of the damage done, split evenly among them.
    avenging_crusader = {
        id = 216331,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- sanctified_wrath[53376] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- $?$w2>0&$w3>0[Damage, healing and critical strike chance increased by $w2%.]?$w3==0&$w2>0[Damage and healing increased by $w2%.]?$w2==0&$w3>0[Critical strike chance increased by $w3%.][]$?a53376[ ][]$?a53376&a137029[Holy Shock's cooldown reduced by $w6%.]?a53376&a137028[Judgment generates $53376s3 additional Holy Power.]?a53376[Each Holy Power spent deals $326731s1 Holy damage to nearby enemies.][]
    avenging_wrath = {
        id = 31884,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- avenging_wrath[317872] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- sanctified_wrath[53376] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- avenging_wrath[384376] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- avenging_wrath[384376] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- avenging_wrath[384376] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- lights_decree[286231] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Your next Judgment deals $s1% increased damage and will critically strike. In addition, it activates Avenging Wrath for $414195s2 sec.
    awakening = {
        id = 414193,
        duration = 30.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    barrier_of_faith = {
        id = 395180,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- beacon_of_faith[156910] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Healed whenever the Paladin directly heals a nearby ally.$?e4[; Damage taken reduced by $w5%.][]
    beacon_of_faith = {
        id = 156910,
        duration = 3600,
        max_stack = 1,
    },
    -- Healed whenever the Paladin heals a nearby ally.$?e3[; Damage taken reduced by $w4%.][]
    beacon_of_light = {
        id = 53563,
        duration = 3600,
        max_stack = 1,
    },
    -- Healed whenever the Paladin heals a nearby ally.$?e2[; Damage taken reduced by $w3%.][]
    beacon_of_virtue = {
        id = 200025,
        duration = 8.0,
        max_stack = 1,
    },
    -- Healing $s1 every $t1 sec.
    bestow_light = {
        id = 448086,
        duration = 3600,
        max_stack = 1,
    },
    -- Damage and healing of your next $?s204019[Blessed Hammer]?s53595[Hammer of the Righteous][Crusader Strike] increased by $w1%.
    blessed_assurance = {
        id = 433019,
        duration = 20.0,
        max_stack = 1,
    },
    -- The healing or damage of your next Holy Shock is increased by $s1%.
    blessing_of_anshe = {
        id = 445204,
        duration = 20.0,
        max_stack = 1,
    },
    -- Immune to movement impairing effects. $?s199325[Movement speed increased by $199325m1%][]
    blessing_of_freedom = {
        id = 1044,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- echoing_blessings[387801] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- blessed_hands[199454] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- unbound_freedom[199325] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Immune to Physical damage and harmful effects.
    blessing_of_protection = {
        id = 1022,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- echoing_blessings[387801] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- blessed_hands[199454] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- $?$w1>0[$s1% of damage taken is transferred to the Paladin.][Taking $s3% of damage taken by target ally.]
    blessing_of_sacrifice = {
        id = 199448,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- blessing_of_sacrifice[200327] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
        -- echoing_blessings[387801] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- ultimate_sacrifice[199452] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 199448, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
    },
    -- $s1% of all healing is converted into damage onto a nearby enemy and $s4% of all damage is converted into healing onto an injured ally within $448227A1 yds.
    blessing_of_summer = {
        id = 388007,
        duration = 30.0,
        max_stack = 1,
    },
    -- Disoriented.
    blinding_light = {
        id = 105421,
        duration = 6.0,
        max_stack = 1,
    },
    -- $?c1[Shield of the Righteous damage and Word of Glory healing increased by $w3%.]?c2[Hammer of the Righteous also causes a wave of light that hits all other enemies near the target.]?c3[Shield of the Righteous damage and Word of Glory healing increased by $w3%.][]$?$w2<0[; Damage taken reduced by ${-$W2}.1%.][]
    consecration = {
        id = 188370,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- strength_of_conviction[379008] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'trigger_spell': 188370, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Pondering the nature of the Light.
    contemplation = {
        id = 121183,
        duration = 8.0,
        max_stack = 1,
    },
    -- Mounted speed increased by $w1%.$?$w5>0[; Incoming fear duration reduced by $w5%.][]
    crusader_aura = {
        id = 32223,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- aura_mastery[31821] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': SPELL_EFFECTIVENESS, }
        -- divine_vision[199324] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- holy_bulwark[432496] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': EFFECT_1_VALUE, }
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    crusaders_direhorn = {
        id = 290608,
        duration = 3600,
        max_stack = 1,
    },
    -- Increases the healing done by your next Light of Dawn by $w1%.
    darkest_before_the_dawn = {
        id = 210391,
        duration = 3600,
        max_stack = 1,
    },
    -- Dealing $w1 Radiant damage and radiating $431581s1% of this damage to nearby enemies every $t1 sec.$?e2[; Movement speed reduced by $w3%.][]
    dawnlight = {
        id = 431380,
        duration = 8.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- suns_avatar[431425] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Incapable of causing a critical effect.
    denounce = {
        id = 2812,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Damage taken reduced by $w1%.
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- aura_mastery[31821] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 2.34, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- divine_vision[199324] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- holy_bulwark[432496] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': EFFECT_1_VALUE, }
    },
    -- Holy Light or Flash of Light heal for $w1% more, their cast time is reduced by $s2%, and its Mana cost is reduced by $s3%.
    divine_favor = {
        id = 210294,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement speed reduced by ${$s3*-1}%.
    divine_hammer = {
        id = 198137,
        duration = 1.5,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- consecrated_ground[204054] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Damage taken reduced by $w1%.
    divine_protection = {
        id = 498,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Your next Holy Power ability is free and deals $s2% increased damage and healing.
    divine_purpose = {
        id = 223819,
        duration = 12.0,
        max_stack = 1,
    },
    -- Casting $?c2[Avenger's Shield]?c1[Holy Shock][Judgement] every $t1 sec for $s2 sec.
    divine_resonance = {
        id = 386730,
        duration = 15.0,
        max_stack = 1,
    },
    -- Immune to all attacks and harmful effects.
    divine_shield = {
        id = 642,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Increases ground speed by $s4%$?$w1<0[, and reduces damage taken by $w1%][].
    divine_steed = {
        id = 221883,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- seasoned_warhorse[376996] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    earthen_ordinants_ramolith = {
        id = 453785,
        duration = 3600,
        max_stack = 1,
    },
    -- Damage taken reduced by $w%.
    echoing_protection = {
        id = 339324,
        duration = 8.0,
        max_stack = 1,
    },
    -- Armor increased by $s1%.
    empyreal_ward = {
        id = 387792,
        duration = 60.0,
        max_stack = 1,
    },
    -- Cannot benefit from Empyrean Legacy.
    empyrean_legacy = {
        id = 387441,
        duration = 20.0,
        max_stack = 1,
    },
    -- Healing $w1 health every $t1 sec.
    eternal_flame = {
        id = 156322,
        duration = 16.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 65.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[428076] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[428076] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beacon_of_faith[156910] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Slowed by $s1%.
    excoriation = {
        id = 439632,
        duration = 5.0,
        max_stack = 1,
    },
    -- Dealing $s1% less damage to the Paladin.
    eye_of_tyr = {
        id = 209202,
        duration = 9.0,
        max_stack = 1,
    },
    -- Cannot be affected by Divine Shield, Hand of Protection, or Lay on Hands.
    forbearance = {
        id = 25771,
        duration = 30.0,
        max_stack = 1,
    },
    -- Your Holy Power spenders deal $s1% additional damage or healing while a Dawnlight is active.
    gleaming_rays = {
        id = 431481,
        duration = 30.0,
        max_stack = 1,
    },
    -- Stunned.
    hammer_of_justice = {
        id = 853,
        duration = 6.0,
        max_stack = 1,
    },
    -- Your next Holy Light heals $s1% more, costs $s3% less mana, and is instant cast.
    hand_of_divinity = {
        id = 414273,
        duration = 20.0,
        max_stack = 1,
    },
    -- Taunted.
    hand_of_reckoning = {
        id = 62124,
        duration = 3.0,
        max_stack = 1,
    },
    -- Wielding a Holy Bulwark.$?$w3<0[; Duration of Fear effects reduced by $s3%.][]
    holy_bulwark = {
        id = 432496,
        duration = 20.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- fear_no_evil[432834] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Your next spell is empowered:; -Flash of Light costs $w1% less Mana.; -Holy Light healing increased by $w2%.; -Greater Judgment prevents ${$w4-100}% more damage.
    infusion_of_light = {
        id = 54149,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- inflorescence_of_the_sunwell[392907] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHARGES, }
        -- inflorescence_of_the_sunwell[392907] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- inflorescence_of_the_sunwell[392907] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- inflorescence_of_the_sunwell[392907] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },
    -- Block chance increased by $w1%. Attackers take Holy damage.
    inner_light = {
        id = 386556,
        duration = 4.0,
        max_stack = 1,
    },
    -- Teleporting.
    jailers_judgment = {
        id = 162056,
        duration = 6.0,
        max_stack = 1,
    },
    -- Taking $w1% increased damage from $@auracaster's next Holy Power ability.
    judgment = {
        id = 197277,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- judgment[327977] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- justification[377043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_crusader[216331] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_glimpse[387805] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- truth_prevails[461273] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- awakening[414193] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- awakening[414193] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #18: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- liberation[461471] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'coefficient': -0.00152381, 'scaling_class': -2, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    -- Attackers are healed for $183811s1.
    judgment_of_light = {
        id = 196941,
        duration = 30.0,
        max_stack = 1,
    },
    -- The mana cost of your next Holy Light, Flash of Light, Crusader Strike, or Judgment is reduced by $w1.
    liberation = {
        id = 461471,
        duration = 20.0,
        max_stack = 1,
    },
    -- Holy Shock healing increased by $w1%.
    light_of_the_martyr = {
        id = 447988,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- bestow_light[448087] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- The paladin's healing spells cast on you also heal the Beacon of Light.
    lights_beacon = {
        id = 53651,
        duration = 0.0,
        max_stack = 1,

        -- Affected by:
        -- commanding_light[387781] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- $w1% increased damage and healing.
    luminescence = {
        id = 355575,
        duration = 6.0,
        max_stack = 1,
    },
    -- Restores health to $210291s2 injured allies within $210291A1 yards every $t1 sec.
    merciful_auras = {
        id = 183415,
        duration = 0.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- aura_mastery[31821] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- beacon_of_faith[156910] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- The damage and healing of your next Dawnlight is increased by $w1%.
    morning_star = {
        id = 431539,
        duration = 15.0,
        max_stack = 1,
    },
    -- $s1% of all effective healing done will be added onto your next Holy Shock.
    power_of_the_silver_hand = {
        id = 200656,
        duration = 10.0,
        max_stack = 1,
    },
    -- Healing received increased by $s1%.
    protection_of_tyr = {
        id = 211210,
        duration = 8.0,
        max_stack = 1,
    },
    -- Reduces healing received from critical heals by $w1%.$?$w2>0[; Damage taken increased by $w2.][]
    pvp_rules_enabled_hardcoded = {
        id = 134735,
        duration = 20.0,
        max_stack = 1,
    },
    -- You have recently benefited from Saved by the Light and cannot benefit from it again from the same caster.
    recently_saved_by_the_light = {
        id = 157131,
        duration = 60.0,
        max_stack = 1,
    },
    -- Haste increased by $w1%.
    relentless_inquisitor = {
        id = 383389,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- relentless_inquisitor[383388] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Incapacitated.
    repentance = {
        id = 20066,
        duration = 60.0,
        max_stack = 1,
    },
    -- Damage and healing increased by $w1%. $?a31821[Healing received increased by $w2%.][]
    retribution_aura = {
        id = 404996,
        duration = 30.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- aura_mastery[31821] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Holy Shock casts $s1 additional times.
    rising_sunlight = {
        id = 414204,
        duration = 30.0,
        max_stack = 1,
    },
    -- Stamina increased by $w1%.
    rite_of_adjuration = {
        id = 433584,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Primary stat increased by $w1%. Armor increased by $w2%.
    rite_of_sanctification = {
        id = 433550,
        duration = 3600.0,
        max_stack = 1,
    },
    -- $@spellaura385728
    seal_of_the_crusader = {
        id = 385723,
        duration = 0.0,
        max_stack = 1,
    },
    -- Misses spells and melee attacks.
    searing_glare = {
        id = 410201,
        duration = 4.0,
        max_stack = 1,
    },
    -- Detecting Undead.
    sense_undead = {
        id = 5502,
        duration = 3600,
        max_stack = 1,
    },
    -- Haste increased by $w1%.
    solar_grace = {
        id = 439841,
        duration = 12.0,
        max_stack = 1,
    },
    -- Physical damage taken reduced by $w1%.
    spreading_the_word_protection = {
        id = 199507,
        duration = 6.0,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_charger = {
        id = 23214,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_darkforge_ram = {
        id = 270562,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_dawnforge_ram = {
        id = 270564,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_exarchs_elekk = {
        id = 73629,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_great_exarchs_elekk = {
        id = 73630,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_great_sunwalker_kodo = {
        id = 69826,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_lightforged_ruinstrider = {
        id = 363613,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_sunwalker_kodo = {
        id = 69820,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_thalassian_charger = {
        id = 34767,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_thalassian_warhorse = {
        id = 34769,
        duration = 3600,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    summon_warhorse = {
        id = 13819,
        duration = 3600,
        max_stack = 1,
    },
    -- Healing $w1 every $t1 sec.
    sun_sear = {
        id = 431415,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- beacon_of_faith[156910] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Disoriented.
    turn_evil = {
        id = 10326,
        duration = 40.0,
        max_stack = 1,

        -- Affected by:
        -- wrench_evil[460720] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- Healing received from Holy Light, Flash of Light, and Holy Shock increased by $s2%.
    tyrs_deliverance = {
        id = 200654,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- beacon_of_faith[156910] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Hammer of Wrath can be used on any target.
    veneration = {
        id = 392939,
        duration = 15.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s2%.; $?$w3!=0[Suffering $s3 Radiant damage every $t3 sec.][]
    wake_of_ashes = {
        id = 205273,
        duration = 6.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    will_of_the_dawn = {
        id = 431462,
        duration = 5.0,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Returns all dead party members to life with $s1% of maximum health and mana.  Cannot be cast when in combat.
    absolution = {
        id = 212056,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT_WITH_AURA, 'subtype': NONE, 'points': 35.0, 'radius': 100.0, 'target': TARGET_CORPSE_SRC_AREA_RAID, }
    },

    -- Empowers your chosen aura for $d.$?a344218[; $@spellname465: Damage reduction increased to ${-$s1-$465s2}%.][]$?a344219[; $@spellname32223: Mount speed bonus increased to ${$s2+$32223s4}%.][]$?a344217[; $@spellname183435: Increases healing received by $s3% while its effect is active.][]$?a344220[; $@spellname317920: Affected allies immune to interrupts and silences.][]
    aura_mastery = {
        id = 31821,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "aura_mastery",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 2.34, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': SPELL_EFFECTIVENESS, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 412629, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }

        -- Affected by:
        -- unwavering_spirit[392911] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- divine_vision[199324] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- divine_vision[199324] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },

    -- You become the ultimate crusader of light for $d. Crusader Strike and Judgment cool down $s2% faster and heal up to $s6 injured allies within $216371A yds for $s5% of the damage done, split evenly among them.; Grants an additional charge of Crusader Strike for its duration.; If Avenging Wrath is known, also increases Judgment, Crusader Strike, and auto-attack damage by $s1%.
    avenging_crusader = {
        id = 216331,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        spend = 0.030,
        spendType = 'mana',

        talent = "avenging_crusader",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': APPLY_AURA, 'subtype': CHARGE_RECOVERY_MULTIPLIER, 'points': -30.0, 'value': 1627, 'schools': ['physical', 'holy', 'nature', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': CHARGE_RECOVERY_MULTIPLIER, 'points': -30.0, 'value': 1663, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 420.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': CHARGE_RECOVERY_MULTIPLIER, 'value': 2179, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MASTERY, 'target': TARGET_UNIT_CASTER, }
        -- #10: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- sanctified_wrath[53376] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Call upon the Light to become an avatar of retribution, $?s53376&c2[causing Judgment to generate $53376s3 additional Holy Power, ]?s53376&c3[each Holy Power spent causing you to explode with Holy light for $326731s1 damage to nearby enemies, ]?s53376&c1[reducing Holy Shock's cooldown by $53376s2%, ][]$?s326730[allowing Hammer of Wrath to be used on any target, ][]$?s384442&s384376[increasing your damage, healing and critical strike chance by $s2% for $d.]?!s384442&s384376[increasing your damage and healing by $s1% for $d.]?!s384376&s384442[increasing your critical strike chance by $s3% for $d.][and activating all the effects learned for Avenging Wrath for $d.]
    avenging_wrath = {
        id = 31884,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "avenging_wrath",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_PCT, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_BLIND, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': CHARGE_RECOVERY_MULTIPLIER, 'value': 2179, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 395605, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MASTERY, 'target': TARGET_UNIT_CASTER, }
        -- #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }

        -- Affected by:
        -- avenging_wrath[317872] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- sanctified_wrath[53376] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- avenging_wrath[384376] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- avenging_wrath[384376] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- avenging_wrath[384376] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- lights_decree[286231] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Imbue a friendly target with a Barrier of Faith, absorbing $<shield> damage for $395180d. For the next $d, Barrier of Faith accumulates $s2% of effective healing from your Flash of Light, Holy Light, or Holy Shock spells. Every $t2 sec, the accumulated healing becomes an absorb shield.
    barrier_of_faith = {
        id = 148039,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.024,
        spendType = 'mana',

        talent = "barrier_of_faith",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 395180, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 6.0, 'pvp_multiplier': 1.5, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
    },

    -- Mark a second target as a Beacon, mimicking the effects of Beacon of Light. Your heals will now heal both of your Beacons, but at $s4% reduced effectiveness.
    beacon_of_faith = {
        id = 156910,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.005,
        spendType = 'mana',

        talent = "beacon_of_faith",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'trigger_spell': 53651, 'triggers': lights_beacon, 'points': 50.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 53651, 'triggers': lights_beacon, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -5.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Wrap a single ally in holy energy, causing your heals on other party or raid members to also heal that ally for $53651s1% of the amount healed.$?a231642[ ; Healing this ally directly with Flash of Light or Holy Light grants $231642s1 Holy Power.][]
    beacon_of_light = {
        id = 53563,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.005,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'trigger_spell': 53651, 'triggers': lights_beacon, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 53651, 'triggers': lights_beacon, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -5.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Apply a Beacon of Light to your target and $s2 injured allies within $A2 yds for $d.; All affected allies will be healed for $53651s1% of the amount of your other healing done.
    beacon_of_virtue = {
        id = 200025,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        talent = "beacon_of_virtue",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 4.0, 'radius': 30.0, 'target': TARGET_DEST_TARGET_ALLY, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -5.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Your Blessing of Protection and Blessing of Freedom spells now have 1 additional charge.
    blessed_hands = {
        id = 199454,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Blesses a party or raid member, granting immunity to movement impairing effects $?s199325[and increasing movement speed by $199325m1% ][]for $d.
    blessing_of_freedom = {
        id = 1044,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "global",

        spend = 0.014,
        spendType = 'mana',

        talent = "blessing_of_freedom",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 7, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 11, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- echoing_blessings[387801] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- blessed_hands[199454] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- unbound_freedom[199325] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for $d.; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.$?c2[; Shares a cooldown with Blessing of Spellwarding.][]
    blessing_of_protection = {
        id = 1022,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        talent = "blessing_of_protection",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_RAID, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }

        -- Affected by:
        -- echoing_blessings[387801] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- blessed_hands[199454] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Blesses a party or raid member, reducing their damage taken by $s1%, but you suffer ${100*$e1}% of damage prevented.; Last $d, or until transferred damage would cause you to fall below $s3% health.
    blessing_of_sacrifice = {
        id = 6940,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        spend = 0.014,
        spendType = 'mana',

        talent = "blessing_of_sacrifice",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SPLIT_DAMAGE_PCT, 'amplitude': 1.0, 'points': 30.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 10, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }

        -- Affected by:
        -- holy_paladin[428076] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- blessing_of_sacrifice[200327] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
        -- echoing_blessings[387801] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- ultimate_sacrifice[199452] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 199448, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Places a Blessing on a party or raid member, transferring $s1% of damage taken to you over $d.
    blessing_of_sacrifice_199448 = {
        id = 199448,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "none",

        spend = 0.014,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'amplitude': 1.0, 'points': 100.0, 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': DISPEL, 'subtype': NONE, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- blessing_of_sacrifice[200327] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
        -- echoing_blessings[387801] #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- ultimate_sacrifice[199452] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 199448, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }
        from = "from_description",
    },

    -- Bless an ally for $d, causing $s1% of all healing to be converted into damage onto a nearby enemy and $s4% of all damage to be converted into healing onto an injured ally within $448227A1 yds.; Blessing of the Seasons: Turns to Autumn after use.
    blessing_of_summer = {
        id = 388007,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "blessing_of_summer",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'pvp_multiplier': 1.5, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 388014, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_RATING, 'value': 1792, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'pvp_multiplier': 1.5, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #4: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Emits dazzling light in all directions, blinding enemies within $105421A1 yds, causing them to wander disoriented for $105421d.
    blinding_light = {
        id = 115750,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 0.012,
        spendType = 'mana',

        talent = "blinding_light",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
    },

    -- Cleanses a friendly target, removing all $?s393024[Poison, Disease, and ][]Magic effects.
    cleanse = {
        id = 4987,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        spend = 0.013,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DISPEL, 'subtype': NONE, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #2: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- [213644] Cleanses a friendly target, removing all Poison and Disease effects.
    cleanse_toxins = {
        id = 440013,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, }
    },

    -- Consecrates the land beneath you, causing $?s405289[${$<dmg>*1.05} Radiant][${$<dmg>*1.05} Holy] damage over $d to enemies who enter the area$?s204054[ and reducing their movement speed by $204054s2%.][.] Limit $s2.
    consecration = {
        id = 26573,
        cast = 0.0,
        cooldown = 9.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 1.0, 'value': 4488, 'schools': ['nature'], 'target': TARGET_DEST_DEST, }
        -- #2: { 'type': SUMMON, 'subtype': NONE, 'value': 43499, 'schools': ['physical', 'holy', 'nature', 'shadow', 'arcane'], 'value1': 3002, 'target': TARGET_DEST_CASTER, }

        -- Affected by:
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 64.0, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Allows you a moment of peace as you kneel in quiet contemplation to ponder the nature of the Light.
    contemplation = {
        id = 121183,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Increases mounted speed by $s1% for all party and raid members within $a1 yds.
    crusader_aura = {
        id = 32223,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "crusader_aura",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AREA_AURA_RAID, 'subtype': MOD_MOUNTED_SPEED_NOT_STACK, 'points': 20.0, 'radius': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AREA_AURA_RAID, 'subtype': MOD_FLIGHT_SPEED_NOT_STACK, 'points': 20.0, 'radius': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AREA_AURA_RAID, 'subtype': DUMMY, 'points': 20.0, 'value': 33, 'schools': ['physical', 'shadow'], 'radius': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 344219, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- aura_mastery[31821] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': SPELL_EFFECTIVENESS, }
        -- divine_vision[199324] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- holy_bulwark[432496] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': EFFECT_1_VALUE, }
    },

    -- Strike the target for $<damage> $?s403664 [Holystrike][Physical] damage.$?a196926[; Reduces the cooldown of Holy Shock by ${$196926m1/-1000}.1 sec.][]; Generates $s2 Holy Power.
    crusader_strike = {
        id = 35395,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.016,
        spendType = 'mana',

        -- 1. [137029] holy_paladin
        -- spend = 0.006,
        -- spendType = 'mana',

        -- 2. [137027] retribution_paladin
        -- spend = 0.016,
        -- spendType = 'mana',

        -- 3. [137028] protection_paladin
        -- spend = 0.016,
        -- spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target'], 'ap_bonus': 1.071, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }

        -- Affected by:
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #31: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_crusader[216331] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_crusader[216331] #10: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- holy_infusion[414214] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- holy_infusion[414214] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- liberation[461471] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'coefficient': -0.00152381, 'scaling_class': -2, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
    },

    -- Casts down the enemy with a bolt of Holy Light, causing $s1 Holy damage and preventing the target from causing critical effects for the next $d.
    denounce = {
        id = 2812,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 3.179, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_CRIT_PCT, 'points': -100.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 403460, 'points': 1.0, }
        -- #3: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 407467, 'points': 1.0, }
        -- #4: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 433019, 'points': 1.0, }

        -- Affected by:
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Party and raid members within $a1 yds are bolstered by their devotion, reducing damage taken by $s1%.
    devotion_aura = {
        id = 465,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AREA_AURA_RAID, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -3.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 344218, 'points': -3.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- aura_mastery[31821] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 2.34, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- divine_vision[199324] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- holy_bulwark[432496] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': EFFECT_1_VALUE, }
    },

    -- Reduces all damage you take by $s1% for $d. Usable while stunned.
    divine_protection = {
        id = 498,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        spend = 0.007,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -20.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Grants immunity to all damage, harmful effects, knockbacks and forced movement effects for $d. $?a204077[Taunts all targets within 15 yd.][]; Cannot be used if you have Forbearance. Causes Forbearance for $25771d.
    divine_shield = {
        id = 642,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 126, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_MOVEMENT_FORCE_MAGNITUDE, 'points': -100.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Leap atop your Charger for $221883d, increasing movement speed by $221883s4%. Usable while indoors or in combat.
    divine_steed = {
        id = 190784,
        cast = 0.0,
        cooldown = 0.75,
        gcd = "none",

        talent = "divine_steed",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- cavalier[230332] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- seasoned_warhorse[376996] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- [190784] Leap atop your Charger for $221883d, increasing movement speed by $221883s4%. Usable while indoors or in combat.
    divine_steed_221883 = {
        id = 221883,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_MOUNTED_SPEED_NOT_STACK, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'value': 14584, 'schools': ['nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ANIM_REPLACEMENT_SET, 'value': 1154, 'schools': ['holy'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- seasoned_warhorse[376996] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        from = "from_description",
    },

    -- Instantly cast $?a137029[Holy Shock]?a137028[Avenger's Shield]?a137027[Judgment][Holy Shock, Avenger's Shield, or Judgment] on up to $s1 targets within $A2 yds.$?(a384027|a386738|a387893)[; After casting Divine Toll, you instantly cast ][]$?(a387893&c1)[Holy Shock]?(a386738&c2)[Avenger's Shield]?(a384027&c3)[Judgment][]$?a387893[ every $387895t1 sec. This effect lasts $387895d.][]$?a384027[ every $384029t1 sec. This effect lasts $384029d.][]$?a386738[ every $386730t1 sec. This effect lasts $386730d.][]$?c3[; Divine Toll's Judgment deals $326011s1% increased damage.][]$?c2[; Generates $s5 Holy Power per target hit.][]
    divine_toll = {
        id = 375576,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        talent = "divine_toll",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 30.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 30.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #14: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- paladin[137026] #7: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- beacon_of_faith[156910] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- quickened_invocation[379391] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'trigger_spell': 375576, 'triggers': divine_toll, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- divine_purpose[223819] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
    },

    -- Heals an ally for $s2 and an additional $o1 over $d.; Healing increased by $s3% when cast on self.
    eternal_flame = {
        id = 156322,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        spend = 0.100,
        spendType = 'mana',

        spend = 0.006,
        spendType = 'mana',

        talent = "eternal_flame",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 2.0, 'sp_bonus': 0.12, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 3.15, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 65.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[428076] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[428076] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beacon_of_faith[156910] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gleaming_rays[431481] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Releases a blinding flash from Truthguard, causing $s2 Holy damage to all nearby enemies within $A1 yds and reducing all damage they deal to you by $s1% for $d.
    eye_of_tyr = {
        id = 209202,
        color = 'artifact',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_TARGET_RESIST, 'points': -25.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.567, 'points': 1.0, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 25.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENTRY, }
    },

    -- Quickly heal a friendly target for $?$c1&$?a134735[${$s1*1}][$s1].
    flash_of_light = {
        id = 19750,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.1,
        spendType = 'mana',

        -- 0. [137027] retribution_paladin
        -- spend = 0.100,
        -- spendType = 'mana',

        -- 1. [137028] protection_paladin
        -- spend = 0.100,
        -- spendType = 'mana',

        -- 2. [137029] holy_paladin
        -- spend = 0.018,
        -- spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 3.156, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- beacon_of_light[53563] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tyrs_deliverance[200654] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- awestruck[417855] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- beacon_of_faith[156910] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- infusion_of_light[54149] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- infusion_of_light[54149] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor[210294] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- divine_favor[210294] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- protection_paladin[137028] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- liberation[461471] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'coefficient': -0.00152381, 'scaling_class': -2, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Stuns the target for $d.
    hammer_of_justice = {
        id = 853,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.007,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Hurls a divine hammer that strikes an enemy for $<damage> $?s403664[Holystrike][Holy] damage. Only usable on enemies that have less than 20% health$?s326730[, or during Avenging Wrath][].; Generates $s2 Holy Power.
    hammer_of_wrath = {
        id = 24275,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        talent = "hammer_of_wrath",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 1.302, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }

        -- Affected by:
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 116.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #6: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_crusader[216331] #6: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- luminosity[431402] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- vanguards_momentum[416869] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- vanguards_momentum[416869] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- veneration[392939] #0: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 68.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Call upon the Light to empower your spells, causing your next $n Holy Lights to heal $s1% more, cost $s3% less mana, and be instant cast.
    hand_of_divinity = {
        id = 414273,
        cast = 1.5,
        cooldown = 90.0,
        gcd = "global",

        talent = "hand_of_divinity",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- [432496] While wielding a Holy Bulwark, gain an absorb shield for ${$s2/10}.1% of your max health and an additional ${$s4/10}.1% every $t2 sec. Lasts $d.
    holy_bulwark = {
        id = 432459,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "holy_bulwark",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 432496, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- A powerful but expensive spell, healing a friendly target for $s1.
    holy_light = {
        id = 82326,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.064,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 4.0, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- beacon_of_light[53563] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tyrs_deliverance[200654] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- awestruck[417855] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- beacon_of_faith[156910] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- hand_of_divinity[414273] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- hand_of_divinity[414273] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- hand_of_divinity[414273] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- infusion_of_light[54149] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor[210294] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- divine_favor[210294] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- liberation[461471] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'coefficient': -0.00152381, 'scaling_class': -2, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- [114165] Fires a beam of light that scatters to strike a clump of targets. ; If the beam is aimed at an enemy target, it deals $114852s1 Holy damage and radiates ${$114852s2*$<healmod>} healing to 5 allies within $114852A2 yds.; If the beam is aimed at a friendly target, it heals for ${$114871s1*$<healmod>} and radiates $114871s2 Holy damage to 5 enemies within $114871A2 yds.
    holy_prism = {
        id = 114852,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.4, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': HEAL, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE'], 'sp_bonus': 3.5, 'variance': 0.05, 'radius': 30.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #2: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE'], 'radius': 30.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENTRY, }

        -- Affected by:
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Fires a beam of light that scatters to strike a clump of targets. ; If the beam is aimed at an enemy target, it deals $114852s1 Holy damage and radiates ${$114852s2*$<healmod>} healing to 5 allies within $114852A2 yds.; If the beam is aimed at a friendly target, it heals for ${$114871s1*$<healmod>} and radiates $114871s2 Holy damage to 5 enemies within $114871A2 yds.
    holy_prism_114165 = {
        id = 114165,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.026,
        spendType = 'mana',

        talent = "holy_prism_114165",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'chain_amp': 0.0, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        from = "spec_talent",
    },

    -- [114165] Fires a beam of light that scatters to strike a clump of targets. ; If the beam is aimed at an enemy target, it deals $114852s1 Holy damage and radiates ${$114852s2*$<healmod>} healing to 5 allies within $114852A2 yds.; If the beam is aimed at a friendly target, it heals for ${$114871s1*$<healmod>} and radiates $114871s2 Holy damage to 5 enemies within $114871A2 yds.
    holy_prism_114871 = {
        id = 114871,
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 7.0, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.4, 'variance': 0.05, 'radius': 30.0, 'target': TARGET_DEST_TARGET_ALLY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'radius': 30.0, 'target': TARGET_DEST_TARGET_ALLY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        from = "class",
    },

    -- Triggers a burst of Light on the target, dealing $25912s1 Holy damage to an enemy, or $25914s1 healing to an ally.$?s272906[  Has an additional $272906s1% critical strike chance.][]; Generates $s2 Holy Power.; 
    holy_shock = {
        id = 20473,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.026,
        spendType = 'mana',

        talent = "holy_shock",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }

        -- Affected by:
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- divine_glimpse[387805] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- lights_conviction[414073] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- luminosity[431402] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- blessing_of_anshe[445204] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Petition the Light on the behalf of a fallen ally, restoring spirit to body and allowing them to reenter battle with $s2% health and at least $s1% mana.
    intercession = {
        id = 391054,
        cast = 2.0,
        cooldown = 600.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        spend = 0.020,
        spendType = 'mana',

        spend = 0.020,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 20.0, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Stuns the target Player for $d. If the judgment holds for $d, the enemy will be instantly teleported to your jail. Can only be used while in Ashran.
    jailers_judgment = {
        id = 162056,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 6.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Judges the target, dealing $s1 Holy damage$?s231644[, and preventing $<shield> damage dealt by the target][].$?s315867[; Generates $220637s1 Holy Power.][]
    judgment = {
        id = 275773,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.024,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.125, 'pvp_multiplier': 1.3, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- judgment[327977] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- justification[377043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_crusader[216331] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_glimpse[387805] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- truth_prevails[461273] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- awakening[414193] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- awakening[414193] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- liberation[461471] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'coefficient': -0.00152381, 'scaling_class': -2, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Judges the target, dealing $s1 $?s403664[Holystrike][Holy] damage$?s231663[, and causing them to take $197277s1% increased damage from your next Holy Power ability.][.]$?s315867[; Generates $220637s1 Holy Power.][]
    judgment_20271 = {
        id = 20271,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'sp_bonus': 0.610542, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SPEED_ALWAYS, 'points': 10.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'sp_bonus': 0.305271, 'variance': 0.05, 'radius': 12.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[327977] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- justification[377043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_crusader[216331] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_glimpse[387805] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- truth_prevails[461273] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- awakening[414193] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- awakening[414193] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100000.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- liberation[461471] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'coefficient': -0.00152381, 'scaling_class': -2, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        from = "class",
    },

    -- Heals a friendly target for an amount equal to $s2% your maximum health.$?a387791[; Grants the target $387792s1% increased armor for $387792d.][]; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.
    lay_on_hands = {
        id = 633,
        cast = 0.0,
        cooldown = 600.0,
        gcd = "none",

        talent = "lay_on_hands",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL_MAX_HEALTH, 'subtype': NONE, 'pvp_multiplier': 0.75, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': HEAL_PCT, 'subtype': NONE, 'pvp_multiplier': 0.75, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Unleashes a wave of Holy energy, healing up to $s1 injured allies within a $?a337812[$a3]?a387879[$a3][$a1] yd frontal cone for $225311s1.
    light_of_dawn = {
        id = 85222,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        spend = 0.006,
        spendType = 'mana',

        talent = "light_of_dawn",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 15.0, 'target': TARGET_UNIT_CONE_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 4.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ALLY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 40.0, 'target': TARGET_UNIT_CONE_ALLY, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'radius': 25.0, 'target': TARGET_UNIT_CONE_ALLY, }

        -- Affected by:
        -- beacon_of_light[53563] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- luminosity[431402] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- darkest_before_the_dawn[210391] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Interrupts spellcasting and prevents any spell in that school from being cast for $d.
    rebuke = {
        id = 96231,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "none",

        talent = "rebuke",
        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PROC_TRIGGER_SPELL, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Brings a dead ally back to life with $s1% of maximum health and mana. Cannot be cast when in combat.
    redemption = {
        id = 7328,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 35.0, }
    },

    -- Forces an enemy target to meditate, incapacitating them for $d.; Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    repentance = {
        id = 20066,
        cast = 1.7,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.012,
        spendType = 'mana',

        talent = "repentance",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'variance': 0.25, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- When any party or raid member within $a1 yds takes more than $s3% of their health in damage in a single hit, each member gains $404996s1% increased damage and healing, decaying over $404996d. This cannot occur within $392503d of the aura being applied.
    retribution_aura = {
        id = 183435,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AREA_AURA_RAID, 'subtype': MOD_ATTACK_POWER, 'radius': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 344217, 'points': 8.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- retribution_aura[317906] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- divine_vision[199324] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- holy_bulwark[432496] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': EFFECT_1_VALUE, }
    },

    -- Call upon the light to blind your enemies in a $410201a1 yd cone, causing enemies to miss their spells and attacks for $410201d.
    searing_glare = {
        id = 410126,
        cast = 1.25,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 410201, 'target': TARGET_UNIT_CASTER, }
    },

    -- Shows the location of all nearby undead on the minimap until cancelled. Only one form of tracking can be active at a time.
    sense_undead = {
        id = 5502,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRACK_CREATURES, 'variance': 0.25, 'value': 6, 'schools': ['holy', 'fire'], 'target': TARGET_UNIT_CASTER, }
    },

    -- [386568] When Shield of the Righteous expires, gain $386556s1% block chance and deal $386553s1 Holy damage to all attackers for $386556d.
    shield_of_the_righteous = {
        id = 415091,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.5746, 'variance': 0.05, 'radius': 6.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 403460, 'points': 1.0, }
        -- #2: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 407467, 'points': 1.0, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- [386568] When Shield of the Righteous expires, gain $386556s1% block chance and deal $386553s1 Holy damage to all attackers for $386556d.
    shield_of_the_righteous_53600 = {
        id = 53600,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        spend = 3,
        spendType = 'holy_power',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.425, 'variance': 0.05, 'radius': 6.0, 'target': TARGET_UNIT_CONE_ENEMY_24, }
        -- #1: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 403460, 'points': 1.0, }
        -- #2: { 'type': TRIGGER_SPELL_WITH_VALUE, 'subtype': NONE, 'trigger_spell': 407467, 'points': 1.0, }

        -- Affected by:
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        from = "class",
    },

    -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to $d. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    turn_evil = {
        id = 10326,
        cast = 1.5,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.021,
        spendType = 'mana',

        talent = "turn_evil",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_FEAR, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 7.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- wrench_evil[460720] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Releases the Light within yourself, healing $s2 injured allies instantly and an injured ally every $t1 sec for $d within $200653A1 yds for $200654s1.; Allies healed also receive $200654s2% increased healing from your Holy Light, Flash of Light, and Holy Shock spells for $200654d.
    tyrs_deliverance = {
        id = 200652,
        cast = 2.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 0.024,
        spendType = 'mana',

        talent = "tyrs_deliverance",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 200653, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Lash out with the Ashbringer, dealing $sw1 Radiant damage$?a179546[, and an additional $o3 Radiant damage over $d,][] to all enemies within $a1 yd in front of you, and reducing movement speed by $s2% for $d.; Demon and Undead enemies are stunned for $205290d if struck by the Wake of Ashes.$?a179546[; Generates $218001s1 Holy Power.][]
    wake_of_ashes = {
        id = 205273,
        color = 'artifact',
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'ap_bonus': 1.743, 'points': 1.0, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'mechanic': snared, 'points': -50.0, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'tick_time': 1.0, 'ap_bonus': 0.294, 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': SCHOOL_MASK_DAMAGE_FROM_CASTER, 'attributes': ['Add Target (Dest) Combat Reach to AOE', 'Area Effects Use Target Radius'], 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 12.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
    },

    -- Calls down the Light to heal a friendly target for $130551s1$?a378405[ and an additional $<heal> over $378412d][].$?a379043[ Your block chance is increased by $379043s1% for $379041d.][]$?a315921&!a315924[; Protection: If cast on yourself, healing increased by up to $315921s1% based on your missing health.][]$?a315924[; Protection: Healing increased by up to $315921s1% based on your missing health, or up to $315924s1% if cast on another target.][]
    word_of_glory = {
        id = 85673,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'holy_power',

        spend = 0.006,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 3.465, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 65.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- beacon_of_faith[156910] #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- gleaming_rays[431481] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

} )