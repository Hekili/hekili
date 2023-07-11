-- PaladinHoly.lua
-- DF Pre-Patch Nov 2022

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 65 )

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

spec:RegisterTalents( {
    -- Paladin Talents
    auras_of_swift_vengeance        = { 81601, 385639, 1 }, -- [183435] When any party or raid member within $a1 yds takes more than $s3% of their health in damage in a single hit, each member gains $404996s1% increased damage and healing, decaying over $404996d. This cannot occur within $392503d of the aura being applied.
    auras_of_the_resolute           = { 81599, 385633, 1 }, -- [317920] Interrupt and Silence effects on party and raid members within $a1 yds are $s1% shorter. $?a339124[Fear effects are also reduced.][]
    avenging_wrath                  = { 81606, 384376, 1 }, -- Call upon the Light and become an avatar of retribution, increasing your damage and healing done by $s1% for $31884d, and allowing Hammer of Wrath to be cast on any target.; Combines with other Avenging Wrath abilities, granting all known Avenging Wrath effects while active.
    blessing_of_freedom             = { 81600, 1044  , 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects $?s199325[and increasing movement speed by $199325m1% ][]for $d.
    blessing_of_protection          = { 81616, 1022  , 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for $d.; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.$?c2[; Shares a cooldown with Blessing of Spellwarding.][]
    blessing_of_sacrifice           = { 81614, 6940  , 1 }, -- Blesses a party or raid member, reducing their damage taken by $s1%, but you suffer ${100*$e1}% of damage prevented.; Last $d, or until transferred damage would cause you to fall below $s3% health.
    blinding_light                  = { 81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within $105421A1 yds, causing them to wander disoriented for $105421d.
    cavalier                        = { 81605, 230332, 1 }, -- Divine Steed now has ${1+$m1} charges.
    crusaders_reprieve              = { 81543, 403042, 1 }, -- Increases the range of your $?s53595[Hammer of the Righteous and ]?s204019[][Crusader Strike, ]Rebuke $?!c2[and auto-attacks ][]by $s2 yds. Using $?s53595[Hammer of the Righteous]?s204019[Blessed Hammer][Crusader Strike] heals you for $403044s1% of your maximum health.
    divine_steed                    = { 81632, 190784, 1 }, -- Leap atop your Charger for $221883d, increasing movement speed by $221883s4%. Usable while indoors or in combat.
    divine_toll                     = { 81496, 375576, 1 }, -- Instantly cast $?a137029[Holy Shock]?a137028[Avenger's Shield]?a137027[Judgment][Holy Shock, Avenger's Shield, or Judgment] on up to $s1 targets within $A2 yds.$?(a384027|a386738|a387893)[; After casting Divine Toll, you instantly cast ][]$?(a387893&c1)[Holy Shock]?(a386738&c2)[Avenger's Shield]?(a384027&c3)[Judgment][]$?a387893[ every $387895t1 sec. This effect lasts $387895d.][]$?a384027[ every $384029t1 sec. This effect lasts $384029d.][]$?a386738[ every $386730t1 sec. This effect lasts $386730d.][]$?c3[; Divine Toll's Judgment deals $326011s1% increased damage.][]$?c2[; Generates $s5 Holy Power per target hit.][]
    fading_light                    = { 81623, 405768, 1 }, -- $@spellicon385127$@spellname385127:; Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional $s1%.; $@spellicon385126$@spellname385126:; Blessing of Dusk causes your Holy Power generating abilities to also grant an absorb shield for $s2% of damage or healing dealt.
    faiths_armor                    = { 81495, 406101, 1 }, -- [379017] $?c2[Shield of the Righteous][Word of Glory] grants $s1% bonus armor for $d.
    fist_of_justice                 = { 81602, 234299, 2 }, -- Each Holy Power spent reduces the remaining cooldown on Hammer of Justice by $s1 sec.
    golden_path                     = { 81610, 377128, 1 }, -- Consecration heals you and $s2 allies within it for $<points> every $26573t1 sec.
    hammer_of_wrath                 = { 81510, 24275 , 1 }, -- Hurls a divine hammer that strikes an enemy for $<damage> $?s403664[Holystrike][Holy] damage. Only usable on enemies that have less than 20% health$?s326730[, or during Avenging Wrath][].; Generates $s2 Holy Power.
    holy_aegis                      = { 81609, 385515, 2 }, -- Armor and critical strike chance increased by $s2%.
    improved_blessing_of_protection = { 81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection$?c2[ and Blessing of Spellwarding][] by ${-$s1/1000} sec.
    incandescence                   = { 81628, 385464, 1 }, -- Each Holy Power you spend has a $s1% chance to cause your Consecration to flare up, dealing $385816s1 Holy damage to up to $s1 enemies standing within it.
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
    strength_of_conviction          = { 81480, 379008, 2 }, -- While in your Consecration, your $?s2812[Denounce][Shield of the Righteous] and Word of Glory have $s1% increased damage and healing.
    touch_of_light                  = { 81628, 385349, 1 }, -- Your spells and abilities have a chance to cause your target to erupt in a blinding light dealing $385354s1 Holy damage or healing an ally for $385352s1 health.
    turn_evil                       = { 93010, 10326 , 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to $d. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbreakable_spirit              = { 81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, $?s184662[Shield of Vengeance, ][]$?s31850[Ardent Defender][Divine Protection], and Lay on Hands by $s1%.

    -- Holy Talents
    afterimage                      = { 81613, 385414, 1 }, -- After you spend $s3 Holy Power, your next Word of Glory echoes onto a nearby ally at $s1% effectiveness.
    aura_mastery                    = { 81567, 31821 , 1 }, -- Empowers your chosen aura for $d.$?a344218[; $@spellname465: Damage reduction increased to ${-$s1-$465s2}%.][]$?a344219[; $@spellname32223: Mount speed bonus increased to ${$s2+$32223s4}%.][]$?a344217[; $@spellname183435: Increases healing received by $s3% while its effect is active.][]$?a344220[; $@spellname317920: Affected allies immune to interrupts and silences.][]
    avenging_crusader               = { 81584, 394088, 1 }, -- You become the ultimate crusader of light for $216331d. Crusader Strike and Judgment cool down $216331s2% faster and heal up to $216331s6 injured allies for $216331s5% of the damage they deal.; If Avenging Wrath is known, also increases Judgment, Crusader Strike, and auto-attack damage by $216331s1%.
    avenging_wrath_might            = { 81584, 384442, 1 }, -- Call upon the Light and become an avatar of retribution, increasing your critical strike chance by $s1% for $31884d.; Combines with other Avenging Wrath abilities.
    awakening                       = { 81592, 414195, 1 }, -- While in combat, your Holy Power spenders generate $s3 stack of Awakening.; At $s1 stacks of Awakening, your next Judgment deals $414193s1% increased damage, will critically strike, and activates $?a394088[Avenging Crusader][Avenging Wrath] for $?a394088[${$s2-$s4}][$s2] sec.
    awestruck                       = { 81564, 417855, 1 }, -- Holy Shock, Holy Light, and Flash of Light critical healing increased by $s1%.
    barrier_of_faith                = { 81558, 148039, 1 }, -- Imbue a friendly target with a Barrier of Faith, absorbing $<shield> damage for $395180d. For the next $d, Barrier of Faith accumulates $s2% of effective healing from your Flash of Light, Holy Light, or Holy Shock spells. Every $t2 sec, the accumulated healing becomes an absorb shield.
    beacon_of_faith                 = { 81554, 156910, 1 }, -- Mark a second target as a Beacon, mimicking the effects of Beacon of Light. Your heals will now heal both of your Beacons, but at $s4% reduced effectiveness.
    beacon_of_the_lightbringer      = { 81568, 197446, 1 }, -- Mastery: Lightbringer now increases your healing based on the target's proximity to either you or your Beacon of Light, whichever is closer.
    beacon_of_virtue                = { 81554, 200025, 1 }, -- Apply a Beacon of Light to your target and $s2 injured allies within $A2 yds for $d.; All affected allies will be healed for $53651s1% of the amount of your other healing done.$?a231642[ Your Flash of Light and Holy Light on these targets will also grant $231642s1 Holy Power.][]
    blessed_focus                   = { 81563, 414708, 1 }, -- Glimmer of Light's healing and damage is increased by $s2%, but it can only affect ${$s1+3} target at a time.
    blessing_of_summer              = { 81593, 388007, 1 }, -- Bless an ally for $d, causing their attacks to have a $h% chance to deal $s1% additional damage as Holy.; Blessing of the Seasons: Turns to Autumn after use.
    boundless_salvation             = { 81587, 392951, 1 }, -- Your Holy Shock, Flash of Light, and Holy Light spells extend the duration of Tyr's Deliverance on yourself when cast on targets affected by Tyr's Deliverance.; $@spellicon20473$@spellname20473: Extends ${$s4/1000}.1 sec.; $@spellicon19750$@spellname19750: Extends ${$s1/1000}.1 sec.; $@spellicon82326 $@spellname82326: Extends ${$s2/1000}.1 sec.; Tyr's Deliverance can be extended up to a maximum of $s3 sec.
    breaking_dawn                   = { 81583, 387879, 2 }, -- Increases the range of Light of Dawn to $s1 yds.
    commanding_light                = { 81580, 387781, 1 }, -- Beacon of Light transfers an additional $s1% of the amount healed.
    crusaders_might                 = { 81594, 196926, 1 }, -- Crusader Strike reduces the cooldown of Holy Shock by ${$m1/-1000}.1 sec.
    daybreak                        = { 81579, 414170, 1 }, -- Absorb your active Glimmer of Lights, triggering their effects at $s3% value and $?a415244[restoring ${$415246s3*$415244s1} Mana over $415246d, but your healing and damage is decreased by $415246s1%][granting $414176s1 Mana per Glimmer of Light consumed].
    divine_favor                    = { 81570, 210294, 1 }, -- The healing of your next Holy Light or Flash of Light is increased by $m1%, its cast time is reduced by $s2%, and its Mana cost is reduced by $s3%.
    divine_glimpse                  = { 81585, 387805, 1 }, -- Holy Shock and Judgment have a $s1% increased critical strike chance.
    divine_purpose                  = { 93191, 223817, 1 }, -- Holy Power abilities have a $s1% chance to make your next Holy Power ability free and deal $223819s2% increased damage and healing.
    divine_resonance                = { 93180, 386738, 1 }, -- [386732] After casting Divine Toll, you instantly cast $?c2[Avenger's Shield]?c1[Holy Shock][Judgment] every $386730t1 sec for $386730s2 sec.
    divine_revelations              = { 81578, 387808, 1 }, -- While empowered by Infusion of Light, Flash of Light heals for an additional $s2%, and Holy Light or Judgment refund ${$s1/1000}.1% of your maximum mana.
    echoing_blessings               = { 93520, 387801, 1 }, -- Blessing of Freedom increases the target's movement speed by $s3%. $?s204018[Blessing of Spellwarding][Blessing of Protection] and Blessing of Sacrifice reduce the target's damage taken by $s4%. These effects linger for $339324d after the Blessing ends.
    empyrean_legacy                 = { 81591, 387170, 1 }, -- Judgment empowers your next $?c3[Single target Holy Power ability to automatically activate Divine Storm][Word of Glory to automatically activate Light of Dawn] with $s2% increased effectiveness.; This effect can only occur every $387441d.
    glimmer_of_light                = { 81569, 287269, 1 }, -- Holy Shock leaves a Glimmer of Light on the target for $287280d. When you Holy Shock, targets with Glimmer of Light are damaged for $325984s1 or healed for $325983s1, split evenly among them. Glimmer of Light's total healing and damage is increased by $s3% for each target affected.; You may have Glimmer of Light on up to $287269s1 $?a414708[target][targets].; When Glimmer of Light is dispelled, its effect is activated at $s4% value.
    glistening_radiance             = { 81576, 414139, 1 }, -- Spending Holy Power has a $s1% chance to trigger Glimmer of Light's healing and damage.
    glorious_dawn                   = { 93521, 414065, 1 }, -- Holy Shock has a $s1% chance to refund a charge when cast, increasing by ${$s2/1000}.1% for each Glimmer of Light you have active.; Glimmer of Light's healing and damage is increased by $s3%.
    greater_judgment                = { 92220, 231644, 1 }, -- Judgment deems the target unworthy, preventing the next $<shield> damage dealt by the target.;
    hand_of_divinity                = { 81570, 414273, 1 }, -- Call upon the Light to empower your spells, causing your next $n Holy Lights to heal $s1% more, cost $s3% less mana, and be instant cast.
    holy_infusion                   = { 81564, 414214, 1 }, -- Crusader Strike generates $s1 additional Holy Power and deals $s2% more damage.
    holy_prism                      = { 81577, 114165, 1 }, -- Fires a beam of light that scatters to strike a clump of targets. ; If the beam is aimed at an enemy target, it deals $114852s1 Holy damage and radiates ${$114852s2*$<healmod>} healing to 5 allies within $114852A2 yds.; If the beam is aimed at a friendly target, it heals for ${$114871s1*$<healmod>} and radiates $114871s2 Holy damage to 5 enemies within $114871A2 yds.
    holy_shock                      = { 81555, 20473 , 1 }, -- Triggers a burst of Light on the target, dealing $25912s1 Holy damage to an enemy, or $25914s1 healing to an ally.$?s272906[  Has an additional $272906s1% critical strike chance.][]; Generates $s2 Holy Power.;
    illumination                    = { 81563, 414378, 1 }, -- Glimmer of Light can affect $s1 additional targets.
    imbued_infusions                = { 81557, 392961, 1 }, -- Consuming Infusion of Light reduces the cooldown of Holy Shock by ${$s1/-1000}.1 sec.
    improved_cleanse                = { 81508, 393024, 1 }, -- Cleanse additionally removes all Disease and Poison effects.
    inflorescence_of_the_sunwell    = { 81591, 392907, 1 }, -- Infusion of Light has $s1 additional charge, increases Greater Judgment's effect by an additional $s4%, reduces the cost of Flash of Light by an additional $s2%, and causes every $s3 casts of Holy Light to generate an additional Holy Power.
    light_of_dawn                   = { 81565, 85222 , 1 }, -- Unleashes a wave of Holy energy, healing up to $s1 injured allies within a $?a337812[$a3]?a387879[$a3][$a1] yd frontal cone for $225311s1.
    light_of_the_martyr             = { 81561, 219562, 1 }, -- Description not found.
    lightforged_blessing            = { 93168, 406468, 1 }, -- $?s2812[Denounce][Shield of the Righteous] heals you and up to $s3 nearby allies for $53600s2% of maximum health.
    lights_conviction               = { 93927, 414073, 1 }, -- Holy Shock now has ${$s1+1} charges.
    lights_hammer                   = { 81577, 114158, 1 }, -- Hurls a Light-infused hammer to the ground, dealing $114919s1 Holy damage to nearby enemies and healing up to 6 nearby allies for $119952s1, every $114918t1 sec for ${$122773d-1.5} sec.
    lights_protection               = { 93522, 416799, 1 }, -- Your allies with Glimmer of Light take $s1% reduced damage, split evenly among them.
    maraads_dying_breath            = { 81559, 388018, 1 }, -- Light of Dawn increases your next Light of the Martyr by $388019s1% for each ally healed, and allows that Light of the Martyr to heal through Beacon of Light.; Light of the Martyr damages you over $196917d instead of instantly.
    merciful_auras                  = { 81593, 183415, 1 }, -- Your auras restore $210291s1 health to $210291s2 injured allies within $210291A1 yds every $t1 sec.; While Aura Mastery is active, heals all allies within ${$210291A1+$31821s5} yds and healing is increased by $31821s6%.
    moment_of_compassion            = { 81571, 387786, 1 }, -- Your Flash of Light heals for an additional $s1% when cast on a target affected by your Beacon of Light.
    of_dusk_and_dawn                = { 93357, 409439, 1 }, -- [385127] Your next Holy Power spending ability deals $s1% additional increased damage and healing. This effect stacks.
    overflowing_light               = { 81556, 414127, 1 }, -- $s1% of Glimmer of Light's overhealing is converted into an absorb shield. The shield amount cannot exceed $s2% of your max health.
    power_of_the_silver_hand        = { 81589, 200474, 1 }, -- Holy Light, Flash of Light, and Judgment have a chance to grant you Power of the Silver Hand, increasing the healing of your next Holy Shock by $200656s1% of all damage and effective healing you do within the next $200656d, up to a maximum of ${$MHP*$s1/100}.
    protection_of_tyr               = { 81566, 200430, 1 }, -- Aura Mastery also increases all healing received by party or raid members within $211210A1 yards by $s1%.
    quickened_invocation            = { 93180, 379391, 1 }, -- Divine Toll's cooldown is reduced by ${-$s1/1000} sec.
    reclamation                     = { 81558, 415364, 1 }, -- Holy Shock and Crusader Strike refund up to $s1% of their Mana cost and deal up to $s2% more healing or damage, based on the target's missing health.
    relentless_inquisitor           = { 81590, 383388, 1 }, -- Spending Holy Power grants you $s1% haste per finisher for $383389d, stacking up to ${$s2+$s3} times.
    resplendent_light               = { 81571, 392902, 1 }, -- Holy Light heals up to $s2 targets within $392903a1 yds for $s1% of its healing.
    righteous_judgment              = { 93523, 414113, 1 }, -- Judgment has a $s1% chance to cast Consecration at the target's location.; The limit on Consecration does not apply to this effect.
    rising_sunlight                 = { 81595, 414203, 1 }, -- After casting Daybreak, your next $414204u Holy Shocks cast $414204s1 additional times.
    sanctified_wrath                = { 81592, 53376 , 1 }, -- Call upon the Light and become an avatar of retribution for $<time> sec, $?c1[reducing Holy Shock's cooldown by $s2%.]?c2[causing Judgment to generate $s3 additional Holy Power.]?c3[each Holy Power spent causing you to explode with Holy light for $326731s1 damage to nearby enemies.][.]; Combines with Avenging Wrath.;
    saved_by_the_light              = { 81574, 157047, 1 }, -- When an ally with your Beacon of Light is damaged below $s1% health, they absorb the next $<shield> damage.; You cannot shield the same person this way twice within $157131d.
    seal_of_the_crusader            = { 93683, 416770, 2 }, -- Your auto attacks heal a nearby ally for ${$385723s1*(1+$s2/100)}.
    shining_righteousness           = { 81562, 414443, 1 }, -- $?s2812[Denounce][Shield of the Righteous] deals $414448s1 damage to its first target struck.; Every $s1 $?s2812[Denounces][Shields of the Righteous] make your next Word of Glory or Light of Dawn cost no Holy Power.
    tirions_devotion                = { 81573, 414720, 1 }, -- Lay on Hands' cooldown is reduced by ${$s1/1000}.1 sec per Holy Power spent and restores $415299s1% of your Mana.
    tower_of_radiance               = { 81586, 231642, 1 }, -- Casting Flash of Light or Holy Light on your Beacon of Light grants $s1 Holy Power.; Casting Flash of Light or Holy Light on targets without Beacon of Light has a chance to grant $s1 Holy Power, increasing based on their current health threshold.
    tyrs_deliverance                = { 81588, 200652, 1 }, -- Releases the Light within yourself, healing $s2 injured allies instantly and an injured ally every $t1 sec for $d within $200653A1 yds for $200654s1.; Allies healed also receive $200654s2% increased healing from your Holy Light, Flash of Light, and Holy Shock spells for $200654d.
    unending_light                  = { 81575, 387998, 1 }, -- Each Holy Power spent on Light of Dawn increases the healing of your next Word of Glory by $s1%, up to a maximum of $s2%.
    untempered_dedication           = { 81560, 387814, 1 }, -- Light of the Martyr's damage and healing is increased by $387815s1% each time it is cast. This effect can stack up to $387815u times and lasts for $387815d.
    unwavering_spirit               = { 81566, 392911, 1 }, -- The cooldown of Aura Mastery is reduced by ${$s1/-1000} sec.
    vanguards_momentum              = { 93176, 416869, 1 }, -- Hammer of Wrath has $s1 extra charge and on enemies below $s2% health generates ${$403081s1} additional Holy Power.
    veneration                      = { 81581, 392938, 1 }, -- Hammer of Wrath heals up to $s2 injured allies for $414411s2% of the damage done, split evenly among them.; Flash of Light, Holy Light, and Judgment critical strikes reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    avenging_light          = 82, -- (199441) When you heal with Holy Light, all enemies within $199443A1 yards of the target take Holy damage equal to $m1% of the amount healed.
    blessed_hands           = 88, -- (199454) Your Blessing of Protection and Blessing of Freedom spells now have 1 additional charge.
    cleanse_the_weak        = 642, -- (199330) When you Cleanse an ally, $s2 ally within $s3 yds $?$s2>$s5[are][is] dispelled of the same effects, but the cooldown of Cleanse is increased by ${$s4/1000} sec.; Healing allies with your Flash of Light or Holy Light will cleanse all Diseases and Poisons from the target.
    darkest_before_the_dawn = 86, -- (210378) Every $t1 sec the healing done by your next Light of Dawn is increased by $m1%. Stacks up to $210391u times.
    denounce                = 5618, -- (2812) Casts down the enemy with a bolt of Holy Light, causing $s1 Holy damage and preventing the target from causing critical effects for the next $d.
    divine_plea             = 5614, -- (415244) After casting Daybreak, you restore ${$415246s3*$s1} Mana over $415246d, but your healing and damage is decreased by $415246s1%.; Daybreak no longer restores Mana from each Glimmer consumed.
    divine_vision           = 640, -- (199324) Increases the range of your Aura by $m1 yards and reduces the cooldown of Aura Mastery by ${$s3/-1000} sec.
    hallowed_ground         = 3618, -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    judgments_of_the_pure   = 5421, -- (355858) Casting Judgment on an enemy cleanses $s1 Poison, Disease, and Magic effect they have caused on you.
    searing_glare           = 5583, -- (410126) Call upon the light to blind your enemies in a $410201a1 yd cone, causing enemies to miss their spells and attacks for $410201d.
    spreading_the_word      = 87, -- (199456) Your allies affected by your Aura gain an effect after you cast Blessing of Protection or Blessing of Freedom.; $@spellicon1022 $@spellname1022; Physical damage reduced by $199507m1% for $199507d.; $@spellicon1044 $@spellname1044; Cleared of all movement impairing effects.
    ultimate_sacrifice      = 85, -- (199452) Your Blessing of Sacrifice now transfers $m2% of all damage to you into a damage over time effect, but lasts $199448d and no longer cancels when you are below $6940s3% health.
} )


-- Auras
spec:RegisterAuras( {
    afterimage = {
        id = 385414,
    },
    aura_mastery = {
        id = 31821,
        duration = 8,
        max_stack = 1,
    },
    avenging_crusader = {
        id = 216331,
        duration = 12,
        max_stack = 1,
    },
    avenging_wrath = {
        id = 31884,
        duration = 25,
        max_stack = 1,
    },
    barrier_of_faith = {
        id = 148039,
        duration = 18,
        max_stack = 1,
    },
    beacon_of_faith = {
        id = 156910,
        duration = 3600,
        max_stack = 1,
    },
    beacon_of_light = {
        id = 53563,
        duration = 3600,
        max_stack = 1,
    },
    beacon_of_virtue = {
        id = 200025,
        duration = 8,
        max_stack = 1,
    },
    bestow_faith = {
        id = 223306,
        duration = 5,
        max_stack = 1,
    },
    blessing_of_autumn = {
        id = 388010,
        duration = 30,
        max_stack = 1,
    },
    blessing_of_freedom = {
        id = 1044,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    blessing_of_protection = {
        id = 1022,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    blessing_of_sacrifice = {
        id = 6940,
        duration = 12,
        max_stack = 1,
    },
    blessing_of_spring = {
        id = 388013,
        duration = 30,
        max_stack = 1,
    },
    blessing_of_summer = {
        id = 388007,
        duration = 30,
        max_stack = 1,
    },
    blessing_of_winter = {
        id = 388011,
        duration = 30,
        max_stack = 1,
    },
    blinding_light = {
        id = 115750,
    },
    concentration_aura = {
        id = 317920,
        duration = 3600,
        max_stack = 1,
    },
    consecration = {
        id = 26573,
    },
    contemplation = {
        id = 121183,
        duration = 8,
        max_stack = 1,
    },
    crusader_aura = {
        id = 32223,
        duration = 3600,
        max_stack = 1,
    },
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1,
    },
    divine_favor = {
        id = 210294,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
    },
    divine_plea = {
        id = 415246,
        duration = 15,
        max_stack = 1
    },
    divine_purpose = {
        id = 223819,
        duration = 12,
        max_stack = 1,
    },
    divine_resonance = {
        id = 387895,
        duration = 15,
        max_stack = 1,
    },
    divine_shield = {
        id = 642,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    echoing_freedom = {
        id = 339321,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    echoing_protection = {
        id = 339324,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    fading_light = {
        id = 405790,
        duration = 10,
        max_stack = 1
    },
    forbearance = {
        id = 25771,
        duration = 30,
        max_stack = 1,
    },
    glimmer_of_light = {
        id = 325966,
        duration = 30,
        max_stack = 1,
        max_applications = function()
            if talent.blessed_focus.enabled then return 1 end
            return 3 + 5 * talent.illumination.rank
        end,
    },
    golden_path = {
        id = 377128,
    },
    -- Your next Holy Light heals $s1% more, costs $s3% less mana, and is instant cast.
    hand_of_divinity = {
        id = 414273,
        duration = 20.0,
        max_stack = 2,
    },
    incandescence = {
        id = 385464,
    },
    infusion_of_light = {
        id = 54149,
        duration = 15,
        max_stack = 2,
        copy = 53576
    },
    light_of_the_martyr = {
        id = 196917,
        duration = 5.113,
        max_stack = 1,
    },
    maraads_dying_breath = {
        id = 388019,
        duration = 10,
        max_stack = 5,
    },
    mastery_lightbringer = {
        id = 183997,
    },
    of_dusk_and_dawn = {
        id = 385125,
    },
    overflowing_light = {
        id = 414133,
        duration = 8,
        max_stack = 1
    },
    -- $s1% of all effective healing done will be added onto your next Holy Shock.
    power_of_the_silver_hand = {
        id = 200656,
        duration = 10.0,
        max_stack = 1,
    },
    recompense = {
        id = 384914,
    },
    relentless_inquisitor = {
        id = 383389,
        duration = 12,
        max_stack = 5
    },
    retribution_aura = {
        id = 183435,
        duration = 3600,
        max_stack = 1,
    },
    rising_sunlight = {
        id = 414204,
        duration = 30,
        max_stack = 3,
    },
    rule_of_law = {
        id = 214202,
        duration = 10,
        max_stack = 1,
    },
    seal_of_mercy = {
        id = 384897,
    },
    shield_of_the_righteous = {
        id = 132403,
        duration = 4.5,
        max_stack = 1,
    },
    shielding_words = {
        id = 338788,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    shining_righteousness = {
        id = 414444,
        duration = 30,
        max_stack = 5
    },
    shining_righteousness_ready = {
        id = 414445,
        duration = 30,
        max_stack = 1
    },
    tyrs_deliverance = {
        id = 200652,
        duration = 20,
        max_stack = 1,
        dot = 'buff'
    },
    unending_light = {
        id = 394709,
        duration = 30,
        type = "Magic",
        max_stack = 6,
    },
    untempered_dedication = {
        id = 387815,
        duration = 15,
        max_stack = 5,
    },
    vanquishers_hammer = {
        id = 328204,
    },
    -- Hammer of Wrath can be used on any target.
    veneration = {
        id = 392939,
        duration = 15.0,
        max_stack = 1,
    },
} )


spec:RegisterGear( "tier30", 202455, 202453, 202452, 202451, 202450 )
-- 2pc is based on crits which aren't guaranteed, so we can't proactively model them.

local HandleAwakening = setfenv( function()
    if talent.awakening.enabled then
        if buff.awakening.stack == buff.awakening.max_stack - 1 then
            removeBuff( "awakening" )
            applyBuff( "awakening_ready" )
        else
            addStack( "awakening" )
        end
    end
end )

local TriggerLightsHammerT30 = setfenv( function()
    gain( 1, "holy_power" )
    HandleAwakening()
end, state )

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" and spellID == 114158 and state.set_bonus.tier30_4pc > 0 then
        local now = GetTime()
        state:QueueEvent( "lights_hammer", TriggerLightsHammerT30, now + 4, "AURA_PERIODIC", "player", true )
        state:QueueEvent( "lights_hammer", TriggerLightsHammerT30, now + 8, "AURA_PERIODIC", "player", true )
        state:QueueEvent( "lights_hammer", TriggerLightsHammerT30, now + 12, "AURA_PERIODIC", "player", true )
    end
end )


spec:RegisterHook( "reset_precast", function()
    if buff.divine_resonance.up then
        state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires, "AURA_PERIODIC" )
        if buff.divine_resonance.remains > 5 then state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires - 5, "AURA_PERIODIC" ) end
        if buff.divine_resonance.remains > 10 then state:QueueAuraEvent( "divine_toll", class.abilities.holy_shock.handler, buff.divine_resonance.expires - 10, "AURA_PERIODIC" ) end
    end
end )

spec:RegisterHook( "spend", function( amt, resource )
    if amt > 0 and resource == "holy_power" then
        if talent.tirions_devotion.enabled then
            reduceCooldown( "lay_on_hands", amt * 1.5 )
        end

        if talent.relentless_inquisition.enabled then
            addStack( "relentless_inquisitor" )
        end
    end
end )


-- Abilities
spec:RegisterAbilities( {
    absolution = {
        id = 212056,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 1030102,

        handler = function ()
        end,
    },


    aura_mastery = {
        id = 31821,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,
        texture = 135872,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "aura_mastery" )
        end,
    },


    avenging_crusader = {
        key = "avenging_crusader",
        id = 216331,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        startsCombat = false,
        texture = 589117,
        talent = "avenging_crusader",

        toggle = "cooldowns",

        handler = function ()
            spend( 0.18 * mana.max, "mana" )
            applyBuff( "avenging_crusader" )
        end,

        bind = { "avenging_wrath", "sanctified_wrath" }
    },


    avenging_wrath = {
        id = 31884,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        toggle = "cooldowns",
        notalent = "avenging_crusader",

        handler = function ()
            applyBuff( "avenging_wrath" )
        end,

        bind = { "avenging_crusader", "sanctified_wrath" }
    },


    barrier_of_faith = {
        id = 148039,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 0.024,
        spendType = "mana",

        startsCombat = false,
        texture = 4067370,

        handler = function ()
            applyBuff( "barrier_of_faith" )
        end,
    },


    beacon_of_faith = {
        id = 156910,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 1030095,

        handler = function ()
            applyBuff( "beacon_of_faith" )
        end,
    },


    beacon_of_light = {
        id = 53563,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 236247,

        handler = function ()
            applyBuff( "beacon_of_light" )
        end,
    },


    beacon_of_virtue = {
        id = 200025,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 1030094,

        handler = function ()
            applyBuff( "beacon_of_virtue" )
            active_dot.beacon_of_virtue = min( 5, group_members )
        end,
    },


    bestow_faith = {
        id = 223306,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 236249,

        handler = function ()
            applyBuff( "bestow_faith" )
        end,
    },


    blessing_of_autumn = {
        id = 388010,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636843,

        handler = function ()
            setCooldown( "blessing_of_winter", 45 )
            setCooldown( "blessing_of_summer", 90 )
            setCooldown( "blessing_of_spring", 135 )
        end,
    },


    blessing_of_freedom = {
        id = 1044,
        cast = 0,
        charges = 1,
        cooldown = 25,
        recharge = 25,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 135968,

        handler = function ()
            applyBuff( "blessing_of_freedom" )
        end,
    },


    blessing_of_protection = {
        id = 1022,
        cast = 0,
        charges = 1,
        cooldown = 300,
        recharge = 300,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 135964,

        toggle = "defensives",
        defensives = true,

        handler = function ()
            applyDebuff( "forbearance" )
            applyBuff( "blessing_of_protection" )
        end,
    },


    blessing_of_sacrifice = {
        id = 6940,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 135966,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "blessing_of_sacrifice" )
        end,
    },


    blessing_of_spring = {
        id = 388013,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636844,

        handler = function ()
            setCooldown( "blessing_of_summer", 45 )
            setCooldown( "blessing_of_autumn", 90 )
            setCooldown( "blessing_of_winter", 135 )
        end,
    },


    blessing_of_summer = {
        id = 388007,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636845,

        handler = function ()
            setCooldown( "blessing_of_autumn", 45 )
            setCooldown( "blessing_of_winter", 90 )
            setCooldown( "blessing_of_spring", 135 )
        end,
    },


    blessing_of_winter = {
        id = 388011,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636846,

        handler = function ()
            setCooldown( "blessing_of_spring", 45 )
            setCooldown( "blessing_of_summer", 90 )
            setCooldown( "blessing_of_autumn", 135 )
        end,
    },


    blinding_light = {
        id = 115750,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 571553,

        handler = function ()
            applyDebuff( "blinding_light" )
        end,
    },


    cleanse = {
        id = 4987,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 135949,

        handler = function ()
        end,
    },


    concentration_aura = {
        id = 317920,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135933,

        handler = function ()
            applyBuff( "concentration_aura" )
            removeBuff( "devotion_aura" )
            removeBuff( "crusader_aura" )
            removeBuff( "retribution_aura" )
        end,
    },


    contemplation = {
        id = 121183,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        startsCombat = false,
        texture = 134916,

        handler = function ()
        end,
    },


    crusader_aura = {
        id = 32223,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135890,

        handler = function ()
            applyBuff( "crusader_aura" )
            removeBuff( "devotion_aura" )
            removeBuff( "retribution_aura" )
            removeBuff( "concentration_aura" )
        end,
    },


    crusader_strike = {
        id = 35395,
        cast = 0,
        charges = 2,
        cooldown = function() return 6 * ( buff.avenging_crusader.up and 0.7 or 1 ) end,
        recharge = function() return 6 * ( buff.avenging_crusader.up and 0.7 or 1 ) end,
        gcd = "spell",

        spend = 0.016,
        spendType = "mana",

        startsCombat = true,
        texture = 135891,

        handler = function ()
            gain( talent.holy_infusion.enabled and 2 or 1, "holy_power" )

            if talent.crusaders_might.enabled then
                setCooldown( "holy_shock", max( 0, cooldown.holy_shock.remains - 2.0 ) )
            end
        end,
    },

    -- Absorb your active Glimmer of Lights, triggering their effects at $s3% value and $?a415244[restoring ${$415246s3*$415244s1} Mana over $415246d, but your healing and damage is decreased by $415246s1%][granting $414176s1 Mana per Glimmer of Light consumed].
    daybreak = {
        id = 414170,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "spell",

        talent = "daybreak",
        startsCombat = false,

        handler = function()
            active_dot.glimmer_of_light = 0
            applyBuff( "divine_plea" )

            if talent.rising_sunlight.enabled then applyBuff( "rising_sunlight", nil, 3 ) end
        end
    },

    devotion_aura = {
        id = 465,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135893,

        handler = function ()
            applyBuff( "devotion_aura" )
            removeBuff( "retribution_aura" )
            removeBuff( "crusader_aura" )
            removeBuff( "concentration_aura" )
        end,
    },


    divine_favor = {
        id = 210294,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 135915,

        handler = function ()
            applyBuff( "divine_favor" )
        end,
    },


    divine_shield = {
        id = 642,
        cast = 0,
        cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 300 end,
        gcd = "spell",

        startsCombat = false,
        texture = 524354,

        toggle = "defensives",
        defensives = true,

        handler = function ()
            applyDebuff( "forbearance" )
            applyBuff( "divine_shield" )
        end,
    },


    divine_steed = {
        id = 190784,
        cast = 0,
        charges = 2,
        cooldown = 45,
        recharge = 45,
        gcd = "off",

        startsCombat = false,
        texture = 1360759,

        handler = function ()
            applyBuff( "divine_steed" )
        end,
    },


    flash_of_light = {
        id = 19750,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.18 * ( buff.divine_favor.up and 0.5 or 1 ) * ( buff.infusion_of_light.up and 0.3 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
            removeBuff( "infusion_of_light" )
            removeBuff( "divine_favor" )
            if talent.boundless_salvation.enabled and buff.tyrs_deliverance.up then
                buff.tyrs_deliverance.expires = buff.tyrs_deliverance.expires + 4
            end
        end,
    },


    fleshcraft = {
        id = 324631,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 3586267,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "fleshcraft" )
        end,
    },


    hammer_of_justice = {
        id = 853,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 135963,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "hammer_of_justice" )
        end,
    },


    hammer_of_wrath = {
        id = 24275,
        cast = 0,
        cooldown = 7.5,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 613533,

        usable = function ()
            return target.health_pct < 20 or buff.veneration.up or talent.avenging_wrath.enabled and ( buff.avenging_wrath.up or buff.avenging_crusader.up ), "requires target below 20% health, veneration, or avenging_wrath active"
        end,

        handler = function ()
            removeBuff( "veneration" )
            gain( 1, "holy_power" )
            HandleAwakening()
        end,
    },

    -- Call upon the Light to empower your spells, causing your next $n Holy Lights to heal $s1% more, cost $s3% less mana, and be instant cast.
    hand_of_divinity = {
        id = 414273,
        cast = 1.5,
        cooldown = 90.0,
        gcd = "spell",

        talent = "hand_of_divinity",
        startsCombat = false,

        handler = function()
            addStack( "hand_of_divinity", nil, 2 )
        end
    },


    hand_of_reckoning = {
        id = 62124,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 135984,

        handler = function ()
            applyDeuff( "hand_of_reckoning" )
        end,
    },


    -- TODO: Verify if removed (or not).
    holy_light = {
        id = 82326,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.024 * ( buff.hand_of_divinity.up and 0.5 or 1 ) * ( buff.divine_favor.up and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135981,

        handler = function ()
            removeBuff( "divine_favor" )
            if buff.infusion_of_light.up then
                removeBuff( "infusion_of_light" )
                gain( 2, "holy_power" )
                HandleAwakening()
            end
            if talent.boundless_salvation.enabled and buff.tyrs_deliverance.up then
                buff.tyrs_deliverance.expires = buff.tyrs_deliverance.expires + 8
            end
        end,
    },


    holy_prism = {
        id = 114165,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 0.13,
        spendType = "mana",

        startsCombat = true,
        texture = 613408,

        handler = function ()
            if set_bonus.tier30_4pc > 0 then
                gain( 1, "holy_power" )
                HandleAwakening()
            end
        end,
    },


    holy_shock = {
        id = 20473,
        cast = 0,
        cooldown = function() return 8.5 - ( 2 * talent.imbued_infusions.rank ) - ( 1.5 * talent.crusaders_might.rank ) end,
        charges = function() return talent.lights_conviction.enabled and 2 or nil end,
        recharge = function() return talent.lights_conviction.enabled and ( 8.5 - ( 2 * talent.imbued_infusions.rank ) - ( 1.5 * talent.crusaders_might.rank ) ) or nil end,
        gcd = "spell",

        spend = 0.024,
        spendType = "mana",

        startsCombat = true,
        texture = 135972,

        handler = function ()
            if talent.vanguards_momentum.enabled and target.health_pct < 20 then
                gain( 2, "holy_power" )
            else
                gain( 1, "holy_power" )
            end
            HandleAwakening()

            removeBuff( "power_of_the_silver_hand" )
            removeStack( "rising_sunlight" )

            if talent.boundless_salvation.enabled and buff.tyrs_deliverance.up then
                buff.tyrs_deliverance.expires = buff.tyrs_deliverance.expires + 2
            end
            if talent.glimmer_of_light.enabled then
                if debuff.glimmer_of_light.down then
                    applyDebuff( "target", "glimmer_of_light" )
                end
                if active_dot.glimmer_of_light > class.auras.glimmer_of_light.max_applications then
                    active_dot.glimmer_of_light = class.auras.glimmer_of_light.max_applications
                end
            end
        end,
    },


    intercession = {
        id = 391054,
        cast = 2,
        cooldown = 600,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        startsCombat = false,
        texture = 4726195,

        handler = function ()
            spend( 0.02 * mana.max, "mana" )
        end,
    },


    judgment = {
        id = 275773,
        cast = 0,
        cooldown = function() return ( 12 - ( 0.5 * talent.seal_of_alacrity.rank ) )  * ( buff.avenging_crusader.up and 0.7 or 1 ) end,
        gcd = "spell",

        spend = 0.024,
        spendType = "mana",

        startsCombat = true,
        texture = 135959,

        handler = function ()
            gain( 1, "holy_power" )
            HandleAwakening()

            if talent.empyrean_legacy.enabled and debuff.empyrean_legacy_icd.down then
                applyBuff( "empyrean_legacy" )
                applyDebuff( "player", "empyrean_legacy_icd" )
            end
        end,
    },


    lay_on_hands = {
        id = 633,
        cast = 0,
        cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 600 end,
        gcd = "spell",

        startsCombat = false,
        texture = 135928,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "player", "forbearance" )
            if talent.tirions_devotion.enabled then gain( 0.05 * mana.max, "mana" ) end
        end,
    },


    light_of_dawn = {
        id = 85222,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up or buff.shining_righteousness_ready.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = false,
        texture = 461859,

        handler = function ()
            spend( 0.18 * mana.max, "mana" )
            removeBuff( "divine_purpose" )
            removeBuff( "shining_righteousness_ready" )
            if talent.maraads_dying_breath.enabled then applyBuff( "maraads_dying_breath" ) end
        end,
    },


    light_of_the_martyr = {
        id = 183998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.016,
        spendType = "mana",

        startsCombat = false,
        texture = 1360762,

        handler = function ()
            removeBuff( "maraads_dying_breath" )
        end,
    },


    lights_hammer = {
        id = 114158,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        startsCombat = true,
        texture = 613955,

        handler = function ()
            if set_bonus.tier30_4pc > 0 then
                state:QueueAuraEvent( "lights_hammer", TriggerLightsHammerT30, query_time + 4, "AURA_PERIODIC" )
                state:QueueAuraEvent( "lights_hammer", TriggerLightsHammerT30, query_time + 8, "AURA_PERIODIC" )
                state:QueueAuraEvent( "lights_hammer", TriggerLightsHammerT30, query_time + 12, "AURA_PERIODIC" )
            end
        end,
    },


    redemption = {
        id = 7328,
        cast = 10.000345582886,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 135955,

        handler = function ()
        end,
    },


    repentance = {
        id = 20066,
        cast = 1.7,
        cooldown = 15,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 135942,

        handler = function ()
            applyDebuff( "repentance" )
        end,
    },


    retribution_aura = {
        id = 183435,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135889,

        handler = function ()
            applyBuff( "retribution_aura" )
            removeBuff( "devotion_aura" )
            removeBuff( "crusader_aura" )
            removeBuff( "concentration_aura" )
        end,
    },


    shield_of_the_righteous = {
        id = 53600,
        cast = 0,
        cooldown = 1,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = true,
        texture = 236265,

        handler = function ()
            removeBuff( "divine_purpose" )
            reduceCooldown( "crusader_strike", 1.5 )

            if talent.shining_righteousness.enabled then
                if buff.shining_righteousness.stack == buff.shining_righteousness.max_stack - 1 then
                    removeBuff( "shining_righteousness" )
                    addBuff( "shining_righteousness_ready" )
                else
                    addStack( "shining_righteousness" )
                end
            end
        end,
    },


    turn_evil = {
        id = 10326,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 571559,

        handler = function ()
            applyDebuff( "turn_evil" )
        end,
    },


    tyrs_deliverance = {
        id = 200652,
        cast = 2,
        cooldown = 90,
        gcd = "spell",

        startsCombat = false,
        texture = 1122562,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "tyrs_deliverance" )
            active_dot.tyrs_deliverance = group_members
        end,
    },


    vanquishers_hammer = {
        id = 328204,
        cast = 0,
        charges = 2,
        cooldown = 30,
        recharge = 30,
        gcd = "spell",

        startsCombat = true,
        texture = 3578228,

        handler = function ()
            gain( 1, "holy_power" )
            HandleAwakening()
            applyBuff( "vanquishers_hammer" )
        end,
    },


    word_of_glory = {
        id = 85673,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up or buff.shining_righteousness_ready then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = false,
        texture = 133192,

        handler = function ()
            removeBuff( "divine_purpose" )
            removeBuff( "shining_righteousness_ready" )
            removeBuff( "empyrean_legacy" )

            spend( 0.06, "mana" )

            if talent.faiths_armor.enabled then applyBuff( "faiths_armor" ) end
        end,
    },
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 25,

    damage = true,
    damageDots = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_intellect",

    package = "Holy Paladin",
} )


spec:RegisterPack( "Holy Paladin", 20230327, [[Hekili:TAvWoUTnq0VL9YUjOBuTS6UUPaEbAZLMTflkGsrVjrAPXsSMIuHKYolGb)27qjlBkzP2gGCXqMZJpoKZBEKjHjFkjoNAGKxwUyz0IOLRccdF4XOhsInVwdjX10SD0c8dbTc)9xL8xTK)GYP5mHl6RCjn3XIw2OYqejXBAyCZhfjBMM6ieBnKL8YJ4IuYYZHoOGolj2b9DlIE3YL)KLyj)zTJHClzRuzjHlcweSYsEtmOO1LSklrbvY9q(9wYpVhefmrHL8xkQP0sOIC)r)GQrtZbKgDnNzEBqsmNPn62CVgeyi33V0EKac6goKN8ljXzkMbumAs8nwIHYbHjGEGUdeiTbNaAjhpIRyMHThsbbuXaTL8eMYjXUrL4zLUKb88u52utjKQyfLgq2Otm4b0SR58l4TwsHs2uFzb4okD8NtpiC0g9vt7fYoivT5AbxQEfjZ4QqBPnCZ5dPEOkytZoWFL63s9iONQcPhCLMriJMez2PY1iW)GpyCyT2bgZtDtv1vOFyo00gttLye6hNd9bMWCf3RMntQv4xJq)J(OB0qkwjQ0Ja9()psVXhqdLGzsjpxEqmboSvHYeDYYIS8Gk6x6Mtj2tNwlpGyWsmlJzSK1wYcuYAuSmJRCFo3ZOCEA3FsD9pDDrPDUdN7JCZzH)woNTNjGuJKZhTPdhOLA1W60s6evZWbAQUSwX0vJHnVS)g3bKqdzOmejjOPUTpYqvfGj4aZuYeyEFzZ6bUL6bYVUKSvGmHSoCG47VBYlQW63yqpE1wsxkZ2ng2Qz3sNl4xM8uvAV90j9qQR4ITTTT21kitwTHEDZDjqvMuuDdImVE8nTZdN5ESC7a2BYVeToOkNNcQU)ujyjSQAPYCYc)UEjYDoV7p3WuoLRwwHaXMszvNDFwjvua6a7Z)okBqBu82Gpif4I1g(UX(xiBg5eJ33CGXFt4xE7z(w(nMVOVz8zFEIdTtoVFDNzVFMCASXW4CBodg)C8JTPNJ2OUR9KclP96umStoj3Y4qVks)DR)(UljSpFzKHxkmzK(uWp41M(ZfTZKFUODM6ZYCRjUF0ZM2(do2n8ENp46En(9D(NRdVNTD9nZD(E84)TP9tNAJpE8AZ61l8ZipJw)Hh4R6h4In6G9LNXxBYpY282rwMdyCOTOFOExWRsGwFRbjWqxkxo8V401F84KMN4iOViGKnZlVguv67ipE0rWLxX9u4Kuo4TwoIgZZTTpoBY5o4PvtnxSVPXukX7)(nmICh(ABbR1Un5Fc]] )
