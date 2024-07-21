-- PaladinProtection.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 66 )

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

    -- Protection Talents
    afterimage                      = { 93188, 385414, 1 }, -- After you spend $s3 Holy Power, your next Word of Glory echoes onto a nearby ally at $s1% effectiveness.
    ardent_defender                 = { 81481, 31850 , 1 }, -- Reduces all damage you take by $s1% for $d.; While Ardent Defender is active, the next attack that would otherwise kill you will instead bring you to $s2% of your maximum health.
    avengers_shield                 = { 81502, 31935 , 1 }, -- Hurls your shield at an enemy target, dealing $s1 Holy damage, interrupting and silencing the non-Player target for $d, and then jumping to ${$x1-1} additional nearby enemies. $?a209389[; Shields you for $209388d, absorbing $209389s1% as much damage as it dealt.][]$?a378285[; Deals $<dmg> additional damage to all enemies within $378286A1 yds of each target hit.][]; 
    avenging_wrath_might            = { 81483, 31884 , 1 }, -- Call upon the Light and become an avatar of retribution, increasing your critical strike chance by $s1% for $31884d.; Combines with other Avenging Wrath abilities.
    barricade_of_faith              = { 81501, 385726, 1 }, -- When you use Avenger's Shield, your block chance is increased by $385724s1% for $385724d.
    bastion_of_light                = { 81488, 378974, 1 }, -- Your next $U casts of Judgment generate $s1 additional Holy Power.
    blessed_assurance               = { 95235, 433015, 1 }, -- Casting a Holy Power ability increases the damage and healing of your next $?s204019[Blessed Hammer]?s53595[Hammer of the Righteous][Crusader Strike] by $433019s1%.
    blessed_hammer                  = { 81469, 204019, 1 }, -- Throws a Blessed Hammer that spirals outward, dealing $204301s1 Holy damage to enemies and reducing the next damage they deal to you by $<shield>.; Generates $s2 Holy Power.
    blessing_of_spellwarding        = { 90062, 204018, 1 }, -- Blesses a party or raid member, granting immunity to magical damage and harmful effects for $d.; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.; Shares a cooldown with Blessing of Protection.
    blessing_of_the_forge           = { 95230, 433011, 1 }, -- Avenging Wrath summons an additional $@spellicon432502 Sacred Weapon, and during Avenging Wrath your Sacred Weapon casts spells on your target and echoes the effects of your Holy Power abilities.
    bonds_of_fellowship             = { 95181, 432992, 1 }, -- You receive 20% less damage from Blessing of Sacrifice and each time its target takes damage, you gain 4% movement speed up to a maximum of 40%.
    bulwark_of_order                = { 81499, 209389, 1 }, -- Avenger's Shield also shields you for $209388d, absorbing $s1% as much damage as it dealt, up to $s2% of your maximum health.
    bulwark_of_righteous_fury       = { 81491, 386653, 1 }, -- Avenger's Shield increases the damage of your next Shield of the Righteous by $386652s1% for each target hit by Avenger's Shield, stacking up to $386652u times, and increases its radius by $386652s3 yds.
    cleanse_toxins                  = { 81507, 213644, 1 }, -- Cleanses a friendly target, removing all Poison and Disease effects.
    consecrated_ground              = { 81492, 204054, 1 }, -- Your Consecration is $s1% larger, and enemies within it have $s2% reduced movement speed.$?c3[; Your Divine Hammer is $s4% larger, and enemies within them have ${$198137s3*-1}% reduced movement speed.][]
    consecration_in_flame           = { 81470, 379022, 1 }, -- Consecration lasts ${$s1/1000} sec longer and its damage is increased by $s2%.
    crusaders_judgment              = { 81473, 204023, 1 }, -- Judgment now has ${1+$s1} charges, and Grand Crusader now also reduces the cooldown of Judgment by ${$s2/1000} sec.
    crusaders_resolve               = { 81493, 380188, 1 }, -- Enemies hit by Avenger's Shield deal $s1% reduced melee damage to you for $383843d. 
    divine_guidance                 = { 95235, 433106, 1 }, -- For each Holy Power ability cast, your next Consecration deals $<value> damage or healing immediately, split across all enemies and allies.
    divine_inspiration              = { 95231, 432964, 1 }, -- Your spells and abilities have a chance to manifest a Holy Armament for a nearby ally.
    divine_purpose                  = { 93192, 223817, 1 }, -- Holy Power spending abilities have a $s1% chance to make your next Holy Power spending ability free and deal $223819s2% increased damage and healing.
    divine_resonance                = { 81479, 386738, 1 }, -- [386732] After casting Divine Toll, you instantly cast $?c2[Avenger's Shield]?c1[Holy Shock][Judgment] every $386730t1 sec for $386730s2 sec.
    endless_wrath                   = { 95185, 432615, 1 }, -- Calling down an Empyrean Hammer has a $s1% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    excoriation                     = { 95232, 433896, 1 }, -- Enemies within $439632a1 yards of Hammer of Justice's target are slowed by $439632s1% for $439632d.
    eye_of_tyr                      = { 81497, 387174, 1 }, -- Releases a blinding flash from your shield, causing $s2 Holy damage to all nearby enemies within $A1 yds and reducing all damage they deal to you by $s1% for $d.
    faith_in_the_light              = { 81485, 379043, 2 }, -- Casting Word of Glory grants you an additional $s1% block chance for $379041d.
    fear_no_evil                    = { 95232, 432834, 1 }, -- While wielding an Armament the duration of Fear effects is reduced by $s1%.
    ferren_marcuss_fervor           = { 81482, 378762, 2 }, -- Avenger's Shield deals $s1% increased damage to its primary target.
    final_stand                     = { 81504, 204077, 1 }, -- During Divine Shield, all targets within $s1 yds are taunted.
    focused_enmity                  = { 81472, 378845, 1 }, -- When Avenger's Shield strikes a single enemy, it deals $s1% additional Holy damage.
    for_whom_the_bell_tolls         = { 95183, 432929, 1 }, -- Divine Toll grants up to $433618s1% increased damage to your next $s2 Judgment when striking only $s3 enemy. This amount is reduced by $433618s4% for each additional target struck.
    forewarning                     = { 95231, 432804, 1 }, -- The cooldown of Holy Armaments is reduced by $s1%.
    gift_of_the_golden_valkyr       = { 81484, 378279, 2 }, -- Each enemy hit by Avenger's Shield reduces the remaining cooldown on Guardian of Ancient Kings by ${$s1/1000}.1 sec.; When you drop below $s2% health, you become infused with Guardian of Ancient Kings for $s3 sec. This cannot occur again for $337852d.
    grand_crusader                  = { 81487, 85043 , 1 }, -- When you avoid a melee attack or use $?S53595[Hammer of the Righteous]?S204019[Blessed Hammer][Crusader Strike], you have a $s1% chance to reset the remaining cooldown on Avenger's Shield$?S393022[ and increase your Strength by $393019s1% for $393019d.][.]; $?a204023[Reduces the cooldown of Judgment by ${$204023s2/1000} sec.][]
    greater_judgment                = { 81603, 231663, 1 }, -- Judgment causes the target to take $s1% increased damage from your next Holy Power ability.; Multiple applications may overlap.
    guardian_of_ancient_kings       = { 81490, 86659 , 1 }, -- Empowers you with the spirit of ancient kings, reducing all damage you take by $86657s2% for $d.
    hammer_and_anvil                = { 95238, 433718, 1 }, -- Judgment critical strikes cause a shockwave around the target, dealing $?c1[$433722s1][$433717s1] $?c1[healing][damage] at the target's location.
    hammer_of_the_righteous         = { 81469, 53595 , 1 }, -- Hammers the current target for $53595sw1 Physical damage.$?s26573&s203785[; Hammer of the Righteous also causes a wave of light that hits all other targets within $88263A1 yds for $88263sw1 Holy damage.]?s26573[; While you are standing in your Consecration, Hammer of the Righteous also causes a wave of light that hits all other targets within $88263A1 yds for $88263sw1 Holy damage.][]; Generates $s2 Holy Power.
    hammerfall                      = { 95184, 432463, 1 }, -- $?a137028[Shield of the Righteous and Word of Glory]?s198034[Templar's Verdict, Divine Storm and Divine Hammer][Templar's Verdict and Divine Storm] calls down an Empyrean Hammer on a nearby enemy.; While Shake the Heavens is active, this effect calls down an additional Empyrean Hammer.
    hand_of_the_protector           = { 81475, 315924, 1 }, -- When you cast Word of Glory on someone other than yourself, its healing is increased by up to $s1% based on the target's missing health.
    higher_calling                  = { 95178, 431687, 1 }, -- $?a137028[Crusader Strike, Hammer of Wrath and Judgment][Crusader Strike, Hammer of Wrath and Blade of Justice] extend the duration of Shake the Heavens by $s1 sec.
    holy_bulwark                    = { 95234, 432459, 1 }, -- [432496] While wielding a Holy Bulwark, gain an absorb shield for ${$s2/10}.1% of your max health and an additional ${$s4/10}.1% every $t2 sec. Lasts $d.
    holy_shield                     = { 81489, 152261, 1 }, -- Your block chance is increased by $s1%, you are able to block spells, and your successful blocks deal $157122s1 Holy damage to your attacker.
    improved_ardent_defender        = { 90062, 393114, 1 }, -- Ardent Defender reduces damage taken by an additional $s1%.
    improved_holy_shield            = { 81486, 393030, 1 }, -- Your chance to block spells is increased by $s1%.
    inmost_light                    = { 92953, 405757, 1 }, -- Eye of Tyr deals $s1% increased damage and has $s2% reduced cooldown.
    inner_light                     = { 81494, 386568, 1 }, -- When Shield of the Righteous expires, gain $386556s1% block chance and deal $386553s1 Holy damage to all attackers for $386556d.
    inspiring_vanguard              = { 81476, 393022, 1 }, -- [393020] Grand Crusader's chance to occur is increased to $s2% and it grants you $393019s1% strength for $393019d.
    laying_down_arms                = { 95236, 432866, 1 }, -- When an Armament fades from you, the cooldown of Lay on Hands is reduced by ${$s1/1000}.1 sec and you gain $?a137028[Shining Light][Infusion of Light].
    light_of_the_titans             = { 81503, 378405, 1 }, -- Word of Glory heals for an additional $s1% over $378412d.; Increased by $s2% if cast on yourself while you are afflicted by a harmful damage over time effect.
    lightforged_blessing            = { 93168, 406468, 1 }, -- $?s2812[Denounce][Shield of the Righteous] heals you and up to $s3 nearby allies for ${$53600s2}.1% of maximum health.
    lights_deliverance              = { 95182, 425518, 1 }, -- You gain a stack of Light's Deliverance when you call down an Empyrean Hammer.; While $?a137028[Eye of Tyr][Wake of Ashes] and Hammer of Light are unavailable, you consume $433674U stacks of Light's Deliverance, empowering yourself to cast Hammer of Light an additional time for free.
    lights_guidance                 = { 95180, 427445, 1 }, -- [427453] Hammer down your enemy with the power of the Light, dealing $429826s1 Holy damage and ${$429826s1/2} Holy damage up to 4 nearby enemies. ; Additionally, calls down Empyrean Hammers from the sky to strike $427445s2 nearby enemies for $431398s1 Holy damage each.; 
    moment_of_glory                 = { 81505, 327193, 1 }, -- For the next $d, you generate an absorb shield for $s3% of all damage you deal, and Avenger's Shield damage is increased by $s2% and its cooldown is reduced by $s1%.
    of_dusk_and_dawn                = { 93356, 409441, 1 }, -- [385127] Your next Holy Power spending ability deals $s1% additional increased damage and healing. This effect stacks.
    quickened_invocation            = { 81479, 379391, 1 }, -- Divine Toll's cooldown is reduced by ${-$s1/1000} sec.
    redoubt                         = { 81494, 280373, 1 }, -- Shield of the Righteous increases your Strength and Stamina by $280375s2% for $280375d, stacking up to $280375u.
    relentless_inquisitor           = { 81506, 383388, 1 }, -- Spending Holy Power grants you $s1% haste per finisher for $383389d, stacking up to ${$s2+$s3} times.
    resolute_defender               = { 81471, 385422, 2 }, -- Each $s2 Holy Power you spend reduces the cooldown of Ardent Defender and Divine Shield by ${$s1/10}.1 sec.
    righteous_protector             = { 81477, 204074, 1 }, -- Holy Power abilities reduce the remaining cooldown on Avenging Wrath and Guardian of Ancient Kings by $<reduction> sec.
    rite_of_adjuration              = { 95233, 433583, 1 }, -- Imbue your weapon with the power of the Light, increasing your Stamina by $433584s1% and causing your Holy Power abilities to sometimes unleash a burst of healing around a target.; Lasts $433584d.
    rite_of_sanctification          = { 95233, 433568, 1 }, -- Imbue your weapon with the power of the Light, increasing your armor by $433550s2% and your primary stat by $433550s1%.; Lasts $433550d.
    sacrosanct_crusade              = { 95179, 431730, 1 }, -- $?a137028[Eye of Tyr][Wake of Ashes] surrounds you with a Holy barrier for $?a137028[$s1][$s4]% of your maximum health.; Hammer of Light heals you for $?a137028[$s2][$s5]% of your maximum health, increased by $?a137028[$s3][$s6]% for each additional target hit. Any overhealing done with this effect gets converted into a Holy barrier instead.
    sanctification                  = { 95185, 432977, 1 }, -- Casting Judgment increases the damage of Empyrean Hammer by $433671s1% for $433671d.; Multiple applications may overlap.
    sanctified_wrath                = { 81620, 31884 , 1 }, -- Call upon the Light and become an avatar of retribution for $<time> sec, $?c1[reducing Holy Shock's cooldown by $s2%.]?c2[causing Judgment to generate $s3 additional Holy Power.]?c3[each Holy Power spent causing you to explode with Holy light for $326731s1 damage to nearby enemies.][.]; Combines with Avenging Wrath.; 
    sanctuary                       = { 101927, 379021, 1 }, -- Consecration's benefits persist for ${$s1/1000}.0 seconds after you leave it.
    seal_of_charity                 = { 81612, 384815, 1 }, -- When you cast Word of Glory on someone other than yourself, you are also healed for $s1% of the amount healed.
    seal_of_reprisal                = { 81629, 377053, 1 }, -- Your $?s204019[Blessed Hammer]?s53595[Hammer of the Righteous][Crusader Strike] deals $s1% increased damage.
    seal_of_the_crusader            = { 93684, 385728, 2 }, -- Your auto attacks deal ${$385723s1*(1+$s2/100)} additional Holy damage.
    sentinel                        = { 81483, 389539, 1 }, -- [389539] Call upon the Light and gain 15 stacks of Divine Resolve, increasing your maximum health by $s11% and reducing your damage taken by $s12% per stack for $d. After ${$d-15} sec, you will begin to lose 1 stack per second, but each 3 Holy Power spent will delay the loss of your next stack by 1 sec.$?s53376&s384376[; While active, your Judgment generates $53376s3 additional Holy Power, your damage and healing is increased by $384376s1%, and Hammer of Wrath may be cast on any target.]?s53376[; While active, your Judgment generates $53376s3 additional Holy Power.]?s384376[; While active, your damage and healing is increased by $384376s1%, and Hammer of Wrath may be cast on any target.][]; Combines with Avenging Wrath.
    shake_the_heavens               = { 95187, 431533, 1 }, -- After casting Hammer of Light, you call down an Empyrean Hammer on a nearby target every $431536T sec, for $431536d.
    shared_resolve                  = { 95237, 432821, 1 }, -- The effect of your active Aura is increased by $432496s1% on targets with your Armaments.
    shining_light                   = { 81498, 321136, 1 }, -- Every $s1 Shields of the Righteous make your next Word of Glory cost no Holy Power. Maximum $327510U stacks.
    soaring_shield                  = { 101928, 378457, 1 }, -- Avenger's Shield jumps to $s1 additional targets.
    solidarity                      = { 95228, 432802, 1 }, -- If you bestow an Armament upon an ally, you also gain its benefits.; If you bestow an Armament upon yourself, a nearby ally also gains its benefits.
    strength_in_adversity           = { 81493, 393071, 1 }, -- For each target hit by Avenger's Shield, gain $s1% parry for $393038d.
    tirions_devotion                = { 81503, 392928, 2 }, -- Lay on Hands' cooldown is reduced by ${$s1/1000}.1 sec per Holy Power spent.
    tyrs_enforcer                   = { 81474, 378285, 2 }, -- Your Avenger's Shield is imbued with holy fire, causing it to deal $<dmg> Holy damage to all enemies within $378286A1 yards of each target hit.
    unbound_freedom                 = { 93187, 305394, 1 }, -- Blessing of Freedom increases movement speed by $m1%, and you gain Blessing of Freedom when cast on a friendly target.
    undisputed_ruling               = { 95186, 432626, 1 }, -- Hammer of Light applies Judgment to its targets, and increases your Haste by $432629s1% for $432629d.$?a137028[; Additionally, Eye of Tyr grants $s2 Holy Power.][]
    unrelenting_charger             = { 95181, 432990, 1 }, -- Divine Steed lasts ${$s1/1000} sec longer and increases your movement speed by an additional $442221s1% for the first $442221d.
    uthers_counsel                  = { 81500, 378425, 2 }, -- Your Lay on Hands, Divine Shield, Blessing of Protection, and Blessing of Spellwarding have $s1% reduced cooldown.
    valiance                        = { 95229, 432919, 1 }, -- Consuming $?a137028[Shining Light][Infusion of Light] reduces the cooldown of Holy Armaments by ${$s1/1000}.1 sec.
    wrathful_descent                = { 95177, 431551, 1 }, -- When Empyrean Hammer critically strikes, $s2% of its damage is dealt to nearby enemies.; Enemies hit by this effect deal $431625s3% reduced damage to you for $431625d.
    zealots_paragon                 = { 81625, 391142, 1 }, -- Hammer of Wrath and Judgment deal $s2% additional damage and extend the duration of $?s384092[Crusade]?s394088[Avenging Crusader]?s385438[Sentinel][Avenging Wrath] by ${$s1/1000}.1 sec.
    zealous_vindication             = { 95183, 431463, 1 }, -- Hammer of Light instantly calls down $s1 Empyrean Hammers on your target when it is cast.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning               = 5554, -- (247675) When you or allies within your Aura are critically struck, gain Reckoning. Gain $s5 additional stack if you are the victim.; At $s2 stacks of Reckoning, your next $?a137029[Judgment deals $392885s1%][weapon swing deals $247677s1%] increased damage, will critically strike, and activates $?s231895[Crusade][Avenging Wrath] for $?s231895[$s4][$s3] sec.
    guarded_by_the_light            = 97  , -- (216855) Your Flash of Light reduces all damage the target receives by $216857m1% for $216857d. Stacks up to $216857m2 times.
    guardian_of_the_forgotten_queen = 94  , -- (228049) Empowers the friendly target with the spirit of the forgotten queen, causing the target to be immune to all damage for $d.
    hallowed_ground                 = 90  , -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    inquisition                     = 844 , -- (207028) [206891] You focus the assault on this target, increasing their damage taken by $s1% for $d. Each unique player that attacks the target increases the damage taken by an additional $s1%, stacking up to $u times.; Your melee attacks refresh the duration of Focused Assault.
    luminescence                    = 3474, -- (199428) When healed by an ally, allies within your Aura gain $s2% increased damage and healing for $355575d.
    sacred_duty                     = 92  , -- (216853) Reduces the cooldown of your Blessing of Protection and Blessing of Sacrifice by $m1%.
    searing_glare                   = 5582, -- (410126) Call upon the light to blind your enemies in a $410201a1 yd cone, causing enemies to miss their spells and attacks for $410201d.
    shield_of_virtue                = 861 , -- (215652) When activated, your next Avenger's Shield will interrupt and silence all enemies within $m1 yds of the target.
    steed_of_glory                  = 91  , -- (199542) Your Divine Steed lasts for an additional ${$m1/1000} sec.; While active you become immune to movement impairing effects, and you knock back enemies that you move through.
    warrior_of_light                = 860 , -- (210341) Increases the damage done by your Shield of the Righteous by $m1%, but reduces armor granted by $m2%.
    wrench_evil                     = 5652, -- (460720) Turn Evil's cast time is reduced by $s1%.
} )

-- Auras
spec:RegisterAuras( {
    -- The Guardian of Ancient Kings is protecting you, reducing all damage taken by $s2%.
    ancient_guardian = {
        id = 86657,
        duration = 40.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w1%.; The next attack that would otherwise kill you will instead bring you to $w2% of your maximum health.
    ardent_defender = {
        id = 31850,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- improved_ardent_defender[393114] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Aura effectiveness increased.
    aura_mastery = {
        id = 412629,
        duration = 8.0,
        max_stack = 1,
    },
    -- Silenced.
    avengers_shield = {
        id = 31935,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moment_of_glory[327193] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -75.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- moment_of_glory[327193] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sentinel[389539] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- soaring_shield[378457] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- $?$w2>0&$w3>0[Damage, healing and critical strike chance increased by $w2%.]?$w3==0&$w2>0[Damage and healing increased by $w2%.]?$w2==0&$w3>0[Critical strike chance increased by $w3%.][]$?a53376[ ][]$?a53376&a137029[Holy Shock's cooldown reduced by $w6%.]?a53376&a137028[Judgment generates $53376s3 additional Holy Power.]?a53376[Each Holy Power spent deals $326731s1 Holy damage to nearby enemies.][]
    avenging_wrath = {
        id = 31884,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- avenging_wrath[317872] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- sanctified_wrath[53376] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- lights_decree[286231] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Block chance increased by $s1%.
    barricade_of_faith = {
        id = 385724,
        duration = 10.0,
        max_stack = 1,
    },
    -- Your next $U casts of Judgment generate $s1 additional Holy Power.
    bastion_of_light = {
        id = 378974,
        duration = 30.0,
        max_stack = 1,
    },
    -- Damage and healing of your next $?s204019[Blessed Hammer]?s53595[Hammer of the Righteous][Crusader Strike] increased by $w1%.
    blessed_assurance = {
        id = 433019,
        duration = 20.0,
        max_stack = 1,
    },
    -- Damage against $@auracaster reduced by $w2.
    blessed_hammer = {
        id = 204301,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- seal_of_reprisal[377053] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Immune to movement impairing effects. $?s199325[Movement speed increased by $199325m1%][]
    blessing_of_freedom = {
        id = 1044,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- unbound_freedom[305394] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- unbound_freedom[199325] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Immune to Physical damage and harmful effects.
    blessing_of_protection = {
        id = 1022,
        duration = 10.0,
        max_stack = 1,
    },
    -- $?$w1>0[$w1% of damage taken is redirected to $@auracaster.][Taking ${$s1*$e1}% of damage taken by target ally.]
    blessing_of_sacrifice = {
        id = 6940,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- blessing_of_sacrifice[200327] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
    },
    -- Immune to magical damage and harmful effects.
    blessing_of_spellwarding = {
        id = 204018,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- sacred_duty[216853] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -33.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Disoriented.
    blinding_light = {
        id = 105421,
        duration = 6.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    bulwark_of_order = {
        id = 209388,
        duration = 8.0,
        max_stack = 1,
    },
    -- Increases your next Shield of the Righteous' damage by $w1% and radius by $s3~ yds.
    bulwark_of_righteous_fury = {
        id = 386652,
        duration = 15.0,
        max_stack = 1,
    },
    -- $?c1[Shield of the Righteous damage and Word of Glory healing increased by $w3%.]?c2[Hammer of the Righteous also causes a wave of light that hits all other enemies near the target.]?c3[Shield of the Righteous damage and Word of Glory healing increased by $w3%.][]$?$w2<0[; Damage taken reduced by ${-$W2}.1%.][]
    consecration = {
        id = 188370,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- mastery_divine_bulwark[317907] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': -0.28, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- consecration[344172] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
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
        -- holy_bulwark[432496] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': EFFECT_1_VALUE, }
        -- aura_mastery[31821] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': SPELL_EFFECTIVENESS, }
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    crusaders_direhorn = {
        id = 290608,
        duration = 3600,
        max_stack = 1,
    },
    -- Melee attack damage to the Paladin reduced by $w1%
    crusaders_resolve = {
        id = 383843,
        duration = 10.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w1%.
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- holy_bulwark[432496] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': EFFECT_1_VALUE, }
        -- aura_mastery[31821] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 2.34, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Movement speed reduced by ${$s3*-1}%.
    divine_hammer = {
        id = 198137,
        duration = 1.5,
        max_stack = 1,

        -- Affected by:
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- consecrated_ground[204054] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- uthers_counsel[378425] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Increases ground speed by $s4%$?$w1<0[, and reduces damage taken by $w1%][].
    divine_steed = {
        id = 221883,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- seasoned_warhorse[376996] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- unrelenting_charger[432990] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- steed_of_glory[199542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- unrelenting_charger[442221] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.0, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    earthen_ordinants_ramolith = {
        id = 453785,
        duration = 3600,
        max_stack = 1,
    },
    -- Armor increased by $s1%.
    empyreal_ward = {
        id = 387792,
        duration = 60.0,
        max_stack = 1,
    },
    -- Damage done to $@auracaster is reduced by $w3%.
    empyrean_hammer = {
        id = 431625,
        duration = 8.0,
        max_stack = 1,
    },
    -- Slowed by $s1%.
    excoriation = {
        id = 439632,
        duration = 5.0,
        max_stack = 1,
    },
    -- Dealing $s1% less damage to the Paladin.
    eye_of_tyr = {
        id = 387174,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- inmost_light[405757] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 300.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- undisputed_ruling[432626] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- hammer_of_light[427441] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 427453, 'target': TARGET_UNIT_CASTER, }
    },
    -- Block chance increased by $w1%.
    faith_in_the_light = {
        id = 379041,
        duration = 5.0,
        max_stack = 1,
    },
    -- Damage taken increased by $m1%.
    focused_assault = {
        id = 206891,
        duration = 6.0,
        max_stack = 1,
    },
    -- Your Judgment deals ${$w2*$w4}% increased damage.
    for_whom_the_bell_tolls = {
        id = 433618,
        duration = 20.0,
        max_stack = 1,
    },
    -- Cannot be affected by Divine Shield, Hand of Protection, or Lay on Hands.
    forbearance = {
        id = 25771,
        duration = 30.0,
        max_stack = 1,
    },
    -- Gift of the Golden Val'kyr has ended and will not activate.
    gift_of_the_golden_valkyr = {
        id = 393879,
        duration = 45.0,
        max_stack = 1,
    },
    -- All damage taken reduced by $w1%.
    guarded_by_the_light = {
        id = 216857,
        duration = 6.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $86657s2%.
    guardian_of_ancient_kings = {
        id = 393108,
        duration = 4.0,
        max_stack = 1,
    },
    -- Stunned.
    hammer_of_justice = {
        id = 853,
        duration = 6.0,
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
    -- Block chance increased by $w1%. Attackers take Holy damage.
    inner_light = {
        id = 386556,
        duration = 4.0,
        max_stack = 1,
    },
    -- Strength increased by $w1%.
    inspiring_vanguard = {
        id = 393019,
        duration = 8.0,
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
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #18: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- judgment[327977] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- justification[377043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- zealots_paragon[391142] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Attackers are healed for $183811s1.
    judgment_of_light = {
        id = 196941,
        duration = 30.0,
        max_stack = 1,
    },
    -- Healing for $w1 every $t1 sec.
    light_of_the_titans = {
        id = 378412,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- The paladin's healing spells cast on you also heal the Beacon of Light.
    lights_beacon = {
        id = 53651,
        duration = 0.0,
        max_stack = 1,
    },
    -- $?$W1==$U[Ready to deliver Light's justice.][Building up Light's Deliverance. At $u stacks, your next Hammer of Light cast will activate another Hammer of Light for free.]
    lights_deliverance = {
        id = 433674,
        duration = 3600,
        max_stack = 1,
    },
    -- $w1% increased damage and healing.
    luminescence = {
        id = 355575,
        duration = 6.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    moment_of_glory = {
        id = 393899,
        duration = 8.0,
        max_stack = 1,
    },
    -- $s1% of all effective healing done will be added onto your next Holy Shock.
    power_of_the_silver_hand = {
        id = 200656,
        duration = 10.0,
        max_stack = 1,
    },
    -- Reduces healing received from critical heals by $w1%.$?$w2>0[; Damage taken increased by $w2.][]
    pvp_rules_enabled_hardcoded = {
        id = 134735,
        duration = 20.0,
        max_stack = 1,
    },
    -- Strength and Stamina increased by $w1%.
    redoubt = {
        id = 280375,
        duration = 10.0,
        max_stack = 1,
    },
    -- Reign of Ancient Kings has ended and will not activate.
    reign_of_ancient_kings = {
        id = 337852,
        duration = 45.0,
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
    -- Increases your threat generation while active.
    righteous_fury = {
        id = 25780,
        duration = 0.0,
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
    -- Empyrean Hammer damage increased by $w1%
    sanctification = {
        id = 433671,
        duration = 10.0,
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
    -- Damage taken reduced by $s12%. Maximum health increased by $s11%.; $?s53376[; Judgment generates $53376s3~ additional Holy Power.][]; $?s384376[; Damage and healing increased by $s1~%. Hammer of Wrath may be cast on any target.][]
    sentinel = {
        id = 389539,
        duration = 16.0,
        max_stack = 1,

        -- Affected by:
        -- sanctified_wrath[53376] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Casting Empyrean Hammer on a nearby target every $t sec.
    shake_the_heavens = {
        id = 431536,
        duration = 8.0,
        max_stack = 1,
    },
    -- Silenced.
    shield_of_virtue = {
        id = 217824,
        duration = 4.0,
        max_stack = 1,
    },
    -- Your next Word of Glory costs no Holy Power.
    shining_light = {
        id = 327510,
        duration = 30.0,
        max_stack = 1,
    },
    -- Parry increased by $w1%.
    strength_in_adversity = {
        id = 393038,
        duration = 15.0,
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
    },
    -- Haste increased by $w1%
    undisputed_ruling = {
        id = 432629,
        duration = 6.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $s2%.; $?$w3!=0[Suffering $s3 Radiant damage every $t3 sec.][]
    wake_of_ashes = {
        id = 205273,
        duration = 6.0,
        tick_time = 1.0,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Reduces all damage you take by $s1% for $d.; While Ardent Defender is active, the next attack that would otherwise kill you will instead bring you to $s2% of your maximum health.
    ardent_defender = {
        id = 31850,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "ardent_defender",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -20.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB_OVERKILL, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 20, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- improved_ardent_defender[393114] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Empowers your chosen aura for $d.$?a344218[; $@spellname465: Damage reduction increased to ${-$s1-$465s2}%.][]$?a344219[; $@spellname32223: Mount speed bonus increased to ${$s2+$32223s4}%.][]$?a344217[; $@spellname183435: Increases healing received by $s3% while its effect is active.][]$?a344220[; $@spellname317920: Affected allies immune to interrupts and silences.][]
    aura_mastery = {
        id = 31821,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 2.34, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': SPELL_EFFECTIVENESS, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 412629, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Hurls your shield at an enemy target, dealing $s1 Holy damage, interrupting and silencing the non-Player target for $d, and then jumping to ${$x1-1} additional nearby enemies. $?a209389[; Shields you for $209388d, absorbing $209389s1% as much damage as it dealt.][]$?a378285[; Deals $<dmg> additional damage to all enemies within $378286A1 yds of each target hit.][]; 
    avengers_shield = {
        id = 31935,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        talent = "avengers_shield",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'chain_targets': 3, 'ap_bonus': 0.753523, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'chain_targets': -10, 'mechanic': interrupted, 'ap_bonus': 0.267813, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SILENCE, 'chain_targets': -10, 'mechanic': silenced, 'ap_bonus': 0.267813, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }

        -- Affected by:
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- moment_of_glory[327193] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -75.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- moment_of_glory[327193] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sentinel[389539] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- soaring_shield[378457] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHAINED_TARGETS, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- lights_decree[286231] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Throws a Blessed Hammer that spirals outward, dealing $204301s1 Holy damage to enemies and reducing the next damage they deal to you by $<shield>.; Generates $s2 Holy Power.
    blessed_hammer = {
        id = 204019,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.003,
        spendType = 'mana',

        talent = "blessed_hammer",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 30.0, 'value': 6006, 'schools': ['holy', 'fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }

        -- Affected by:
        -- seal_of_reprisal[377053] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- unbound_freedom[305394] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
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
        -- blessing_of_sacrifice[200327] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_TAKEN_BY_PCT, }
    },

    -- Blesses a party or raid member, granting immunity to magical damage and harmful effects for $d.; Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.; Shares a cooldown with Blessing of Protection.
    blessing_of_spellwarding = {
        id = 204018,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "global",

        spend = 0.030,
        spendType = 'mana',

        talent = "blessing_of_spellwarding",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 126, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_RAID, }

        -- Affected by:
        -- sacred_duty[216853] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -33.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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

    -- Cleanses a friendly target, removing all Poison and Disease effects.
    cleanse_toxins = {
        id = 213644,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        spend = 0.100,
        spendType = 'mana',

        talent = "cleanse_toxins",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_TARGET_ALLY, }
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
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- consecration[327980] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- consecration_in_flame[379022] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- consecration_in_flame[379022] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 64.0, 'modifies': DAMAGE_HEALING, }
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
        -- holy_bulwark[432496] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': EFFECT_1_VALUE, }
        -- aura_mastery[31821] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': SPELL_EFFECTIVENESS, }
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
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusader_strike[342348] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -80.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- seal_of_reprisal[377053] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sentinel[389539] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #31: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- holy_bulwark[432496] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': EFFECT_1_VALUE, }
        -- aura_mastery[31821] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 2.34, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'target2': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
        -- uthers_counsel[378425] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
        -- unrelenting_charger[432990] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- steed_of_glory[199542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- unrelenting_charger[442221] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.0, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
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
        -- unrelenting_charger[432990] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- steed_of_glory[199542] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- unrelenting_charger[442221] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'amplitude': 1.0, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
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
        -- paladin[137026] #7: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- quickened_invocation[379391] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'trigger_spell': 375576, 'triggers': divine_toll, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #14: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- divine_purpose[223819] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
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

    -- Releases a blinding flash from your shield, causing $s2 Holy damage to all nearby enemies within $A1 yds and reducing all damage they deal to you by $s1% for $d.
    eye_of_tyr_387174 = {
        id = 387174,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "eye_of_tyr_387174",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_TARGET_RESIST, 'points': -25.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.644318, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 25.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENTRY, }
        -- #3: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }

        -- Affected by:
        -- inmost_light[405757] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 300.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- undisputed_ruling[432626] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- hammer_of_light[427441] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 427453, 'target': TARGET_UNIT_CASTER, }
        from = "spec_talent",
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
        -- sanctuary[105805] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
        -- protection_paladin[137028] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- tyrs_deliverance[200654] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- sentinel[389539] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sentinel[389539] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Empowers you with the spirit of ancient kings, reducing all damage you take by $86657s2% for $d.
    guardian_of_ancient_kings = {
        id = 86659,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "none",

        talent = "guardian_of_ancient_kings",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': TRANSFORM, 'points': 1.0, 'value': 46490, 'schools': ['holy', 'nature', 'frost'], 'value1': 7, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -50.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },

    -- Empowers the friendly target with the spirit of the forgotten queen, causing the target to be immune to all damage for $d.
    guardian_of_the_forgotten_queen = {
        id = 228049,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 300.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 228048, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
    },

    -- [228049] Empowers the friendly target with the spirit of the forgotten queen, causing the target to be immune to all damage for $d.
    guardian_of_the_forgotten_queen_228048 = {
        id = 228048,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 10.0, 'value': 114565, 'schools': ['physical', 'fire'], 'value1': 3941, 'radius': 2.0, 'target': TARGET_DEST_CASTER_FRONT_LEFT, }
        from = "triggered_spell",
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

    -- Hammers the current target for $53595sw1 Physical damage.$?s26573&s203785[; Hammer of the Righteous also causes a wave of light that hits all other targets within $88263A1 yds for $88263sw1 Holy damage.]?s26573[; While you are standing in your Consecration, Hammer of the Righteous also causes a wave of light that hits all other targets within $88263A1 yds for $88263sw1 Holy damage.][]; Generates $s2 Holy Power.
    hammer_of_the_righteous = {
        id = 53595,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.003,
        spendType = 'mana',

        talent = "hammer_of_the_righteous",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'ap_bonus': 0.975, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'resource': holy_power, }

        -- Affected by:
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- seal_of_reprisal[377053] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sentinel[389539] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 68.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #6: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sentinel[389539] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- sentinel[389539] #6: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- zealots_paragon[391142] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 116.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sentinel[389539] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sentinel[389539] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        from = "class",
    },

    -- [206891] You focus the assault on this target, increasing their damage taken by $s1% for $d. Each unique player that attacks the target increases the damage taken by an additional $s1%, stacking up to $u times.; Your melee attacks refresh the duration of Focused Assault.
    inquisition = {
        id = 207028,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 206891, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
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
        -- protection_paladin[137028] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

    -- Judges the target, dealing $s1 Holy damage$?s231663[, and causing them to take $197277s1% increased damage from your next Holy Power ability][].$?a315867[; Generates $220637s1 Holy Power.][]; 
    judgment = {
        id = 275779,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.125, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[327977] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- justification[377043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusaders_judgment[204023] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- zealots_paragon[391142] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
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
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -14.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[327977] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- justification[377043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- crusaders_judgment[204023] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- sentinel[389539] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sentinel[389539] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- zealots_paragon[391142] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -36.0, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- sanctuary[105805] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
        -- unbreakable_spirit[114154] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- uthers_counsel[378425] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.67, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- For the next $d, you generate an absorb shield for $s3% of all damage you deal, and Avenger's Shield damage is increased by $s2% and its cooldown is reduced by $s1%.
    moment_of_glory = {
        id = 327193,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        talent = "moment_of_glory",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -75.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'trigger_spell': 393899, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
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
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
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
        -- holy_bulwark[432496] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': EFFECT_1_VALUE, }
    },

    -- Increases your threat generation while active, making you a more effective tank.
    righteous_fury = {
        id = 25780,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_THREAT, 'points': 650.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
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

    -- Call upon the Light and gain 15 stacks of Divine Resolve, increasing your maximum health by $s11% and reducing your damage taken by $s12% per stack for $d. After ${$d-15} sec, you will begin to lose 1 stack per second, but each 3 Holy Power spent will delay the loss of your next stack by 1 sec.$?s53376&s384376[; While active, your Judgment generates $53376s3 additional Holy Power, your damage and healing is increased by $384376s1%, and Hammer of Wrath may be cast on any target.]?s53376[; While active, your Judgment generates $53376s3 additional Holy Power.]?s384376[; While active, your damage and healing is increased by $384376s1%, and Hammer of Wrath may be cast on any target.][]; Combines with Avenging Wrath.
    sentinel = {
        id = 389539,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "sentinel",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_BLIND, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_AUTOATTACK_DAMAGE, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ABILITY_IGNORE_AURASTATE, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- #8: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #10: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_HEALTH_PERCENT, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #11: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -2.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #12: { 'type': APPLY_AURA, 'subtype': MASTERY, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- sanctified_wrath[53376] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- [386568] When Shield of the Righteous expires, gain $386556s1% block chance and deal $386553s1 Holy damage to all attackers for $386556d.
    shield_of_the_righteous = {
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
        -- protection_paladin[137028] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- protection_paladin[137028] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protection_paladin[137028] #3: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- protection_paladin[137028] #4: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sentinel[389539] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- warrior_of_light[210341] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- judgment[197277] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Suppress Points Stacking'], 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- holy_paladin[137029] #2: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #3: { 'type': APPLY_AURA, 'subtype': MOD_GLOBAL_COOLDOWN_BY_HASTE_REGEN, 'sp_bonus': 0.25, 'points': 100.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'target': TARGET_UNIT_CASTER, }
        -- holy_paladin[137029] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- bulwark_of_righteous_fury[386652] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bulwark_of_righteous_fury[386652] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
    },

    -- When activated, your next Avenger's Shield will interrupt and silence all enemies within $m1 yds of the target.
    shield_of_virtue = {
        id = 215652,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'trigger_spell': 217824, 'points': 8.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Your Divine Steed lasts for an additional ${$m1/1000} sec.; While active you become immune to movement impairing effects, and you knock back enemies that you move through.
    steed_of_glory = {
        id = 199542,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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

    -- Increases the damage done by your Shield of the Righteous by $m1%, but reduces armor granted by $m2%.
    warrior_of_light = {
        id = 210341,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
        -- sanctuary[105805] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': THREAT, }
        -- protection_paladin[137028] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 75.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- avenging_wrath[31884] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- avenging_wrath[31884] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'scaling_class': -7, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sentinel[389539] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- sentinel[389539] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'sp_bonus': 0.25, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- consecration[188370] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': DAMAGE_HEALING, }
        -- holy_paladin[137029] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_paladin[137029] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 65.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_purpose[223819] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.666667, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_purpose[223819] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- shining_light[327510] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

} )