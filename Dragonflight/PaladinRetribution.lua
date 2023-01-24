-- PaladinRetribution.lua
-- October 2022

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 70 )

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Paladin
    afterimage                      = { 81613, 385414, 1 }, -- After you spend 20 Holy Power, your next Word of Glory echoes onto a nearby ally at 30% effectiveness
    aspiration_of_divinity          = { 81622, 385416, 2 }, -- Your Crusader Strike now also grants you 1% increased Strength for 6 sec. Multiple applications may overlap.
    avenging_wrath                  = { 81606, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, allowing Hammer of Wrath to be used on any target, increasing your damage and healing by 20% for 20 sec.
    blessing_of_freedom             = { 81600, 1044  , 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    blessing_of_protection          = { 81616, 1022  , 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    blessing_of_sacrifice           = { 81614, 6940  , 1 }, -- Blesses a party or raid member, reducing their damage taken by 30%, but you suffer 100% of damage prevented. Last 12 sec, or until transferred damage would cause you to fall below 20% health.
    blinding_light                  = { 81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within 10 yards, causing them to wander disoriented for 6 sec. Non-Holy damage will break the disorient effect.
    cavalier                        = { 81605, 230332, 1 }, -- Divine Steed now has 2 charges.
    divine_purpose                  = { 81618, 223817, 1 }, -- Holy Power abilities have a 15% chance to make your next Holy Power ability free and deal 15% increased damage and healing.
    divine_steed                    = { 81632, 190784, 1 }, -- Leap atop your Charger for 4 sec, increasing movement speed by 100%. Usable while indoors or in combat.
    fist_of_justice                 = { 81602, 234299, 2 }, -- Each Holy Power spent reduces the remaining cooldown on Hammer of Justice by 1 sec.
    golden_path                     = { 81610, 377128, 1 }, -- Consecration heals you and 5 allies within it for 91 every 0.9 sec.
    hallowed_ground                 = { 81509, 377043, 1 }, -- Consecration's damage is increased by 10%.
    holy_aegis                      = { 81609, 385515, 2 }, -- Armor and critical strike chance increased by 2%.
    holy_avenger                    = { 81618, 105809, 1 }, -- Your Holy Power generation is tripled for 20 sec.
    improved_blessing_of_protection = { 81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection by 60 sec.
    incandescence                   = { 81628, 385464, 1 }, -- Each Holy Power you spend has a 5% chance to cause your Consecration to flare up, dealing 753 Holy damage to up to 5 enemies standing within it.
    judgment_of_light               = { 81608, 183778, 1 }, -- Judgment causes the next 25 successful attacks against the target to heal the attacker for 70.
    obduracy                        = { 81627, 385427, 1 }, -- Speed and Avoidance increased by 2%.
    of_dusk_and_dawn                = { 81624, 385125, 1 }, -- When you reach 5 Holy Power, you gain Blessing of Dawn. When you reach 0 Holy Power, you gain Blessing of Dusk. Blessing of Dawn Damage and healing increased by 5% for 20 sec. Blessing of Dusk Damage taken reduced by 4% for 20 sec.
    rebuke                          = { 81604, 96231 , 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for 4 sec.
    recompense                      = { 81607, 384914, 1 }, -- After your Blessing of Sacrifice ends, 50% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing. This effect's bonus damage cannot exceed 30% of your maximum health and its bonus healing cannot exceed 100% of your maximum health.
    repentance                      = { 81598, 20066 , 1 }, -- Forces an enemy target to meditate, incapacitating them for 1 min. Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    sacrifice_of_the_just           = { 81607, 384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by 60 sec.
    sanctified_wrath                = { 81620, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, allowing Hammer of Wrath to be used on any target, increasing your damage and healing by 20% for 20 sec.
    seal_of_alacrity                = { 81619, 385425, 2 }, -- Haste increased by 2%.
    seal_of_clarity                 = { 81612, 384815, 2 }, -- Spending Holy Power has a 5% chance to reduce the Holy Power cost of your next Word of Glory or Shield of the Righteous by 1.
    seal_of_mercy                   = { 81611, 384897, 2 }, -- Golden Path strikes the lowest health ally within it an additional time for 50.0% of its effect.
    seal_of_might                   = { 81621, 385450, 2 }, -- During Avenging Wrath, your Mastery is increased by 4%.
    seal_of_order                   = { 81623, 385129, 1 }, -- In the Dawn, your Holy Power-spending abilities deal 8% increased damage and healing. In the Dusk, your armor is increased by 10% and your Holy Power generating abilities cool down 10% faster.
    seal_of_reprisal                = { 81629, 377053, 2 }, -- Your Crusader Strike deals 10% increased damage.
    seal_of_the_crusader            = { 81626, 385728, 2 }, -- Your attacks have a chance to cause your target to take 3% increased Holy damage for 5 sec.
    seal_of_the_templar             = { 81631, 377016, 1 }, -- While mounted on your Charger or under the effects of Crusader Aura, the ranges of Crusader Strike, Templar's Verdict, and Hammer of Justice are increased by 3 yards.
    seasoned_warhorse               = { 81631, 376996, 1 }, -- Increases the duration of Divine Steed by 1 sec.
    seraphim                        = { 81620, 152262, 1 }, -- The Light magnifies your power for 15 sec, granting 8% Haste, Critical Strike, and Versatility, and 13% Mastery.
    touch_of_light                  = { 81628, 385349, 1 }, -- Your spells and abilities have a chance to cause your target to erupt in a blinding light dealing 627 Holy damage or healing an ally for 816 health.
    turn_evil                       = { 81630, 10326 , 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to 40 sec. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbreakable_spirit              = { 81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, Shield of Vengeance, and Lay on Hands by 30%.
    zealots_paragon                 = { 81625, 391142, 1 }, -- Hammer of Wrath and Judgment deal 10% additional damage and extend the duration of Avenging Wrath by 0.5 sec.

    -- Retribution
    art_of_war                      = { 81547, 267344, 1 }, -- Your auto attacks have a 18% chance to reset the cooldown of Blade of Justice.
    ashes_to_ashes                  = { 81550, 383276, 2 }, -- When you benefit from Art of War, you gain Seraphim for 2 sec. Seraphim: The Light magnifies your power for 15 sec, granting 8% Haste, Critical Strike, and Versatility, and 13% Mastery.
    ashes_to_dust                   = { 81523, 383300, 1 }, -- Art of War has a 35% chance to reset the cooldown of Wake of Ashes instead of Blade of Justice.
    auras_of_swift_vengeance        = { 81601, 385639, 1 }, -- Learn Retribution Aura and Crusader Aura:  Retribution Aura: When any party or raid member within 40 yards dies, you gain Avenging Wrath for 12 sec. When any party or raid member within 40 yards takes more than 50% of their health in damage in a single hit, you gain Seraphim for 4 sec. This cannot occur more than once every 30 sec.  Crusader Aura: Increases mounted speed by 20% for all party and raid members within 40 yards.
    auras_of_the_resolute           = { 81599, 385633, 1 }, -- Learn Concentration Aura and Devotion Aura: Concentration Aura: Interrupt and Silence effects on party and raid members within 40 yards are 30% shorter.  Devotion Aura: Party and raid members within 40 yards are bolstered by their devotion, reducing damage taken by 3%.
    avenging_wrath_might            = { 81525, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, allowing Hammer of Wrath to be used on any target, increasing your damage and healing by 20% for 20 sec.
    blade_of_condemnation           = { 81513, 383263, 1 }, -- Increases the critical strike chance of Blade of Justice by 5%.
    blade_of_justice                = { 81526, 184575, 1 }, -- Pierces an enemy with a blade of light, dealing 3,793 Physical damage. Generates 2 Holy Power.
    blade_of_wrath                  = { 81521, 231832, 1 }, -- Art of War resets the cooldown of Blade of Justice 50% more often and increases its damage by 25% for 10 sec.
    boundless_judgment              = { 81534, 383876, 1 }, -- Judgment has a 25% chance to chain to a nearby enemy.
    cleanse_toxins                  = { 81507, 213644, 1 }, -- Cleanses a friendly target, removing all Poison and Disease effects.
    consecrated_blade               = { 81553, 382275, 1 }, -- Art of War causes Blade of Justice to cast Consecration at the target's location. The limit on Consecration does not apply to this effect.
    consecrated_ground              = { 81535, 204054, 1 }, -- Your Consecration is 15% larger, and enemies within it have 50% reduced movement speed.
    crusade                         = { 81525, 231895, 1 }, -- Call upon the Light and begin a crusade, increasing your haste and damage by 3% for 25 sec. Each Holy Power spent during Crusade increases haste and damage by an additional 3%. Maximum 10 stacks. Hammer of Wrath may be cast on any target. Combines with Avenging Wrath.
    divine_protection               = { 81545, 498   , 1 }, -- Reduces all damage you take by 20% for 8 sec.
    divine_resonance                = { 81538, 384027, 1 }, -- After casting Divine Toll, you instantly cast Judgment every 5 sec for 15 sec.
    divine_storm                    = { 81529, 53385 , 1 }, -- Unleashes a whirl of divine energy, dealing 2,569 Holy damage to all nearby enemies. Deals reduced damage beyond 5 targets.
    divine_toll                     = { 81539, 375576, 1 }, -- Instantly cast Judgment on up to 5 targets within 30 yds. Divine Toll's Judgment deals 100% increased damage.
    empyrean_legacy                 = { 81511, 387170, 1 }, -- Judgment empowers your next Templar's Verdict to automatically activate Divine Storm with 25% increased effectiveness. This effect can only occur every 30 sec.
    empyrean_power                  = { 81532, 326732, 1 }, -- Crusader Strike has a 15% chance to make your next Divine Storm free and deal 25% additional damage.
    execution_sentence              = { 81537, 343527, 1 }, -- A hammer slowly falls from the sky upon the target. After 8 sec, they suffer 7,448 Holy damage, plus 10% of damage taken from your abilities in that time.
    executioners_will               = { 81536, 384162, 1 }, -- Templar's Verdict extends the duration of Execution Sentence on the target by 1 sec. This duration cannot extend beyond an additional 8 sec.
    executioners_wrath              = { 81536, 387196, 1 }, -- When Execution Sentence expires, 20% of damage done during its duration is also dealt to nearby enemies within 8 yards.
    exorcism                        = { 81542, 383185, 1 }, -- Blasts the target with Holy Light, causing 2,980 Holy damage and burns the target for an additional 4,111 Holy Damage over 12 sec. Stuns Demon and Undead targets for 5 sec. Applies the damage over time effect to up to 7 nearby enemies if the target is standing within your Consecration.
    expurgation                     = { 81519, 383344, 1 }, -- Your Blade of Justice critical strikes cause the target to burn for 60% of the damage dealt over 6 sec.
    eye_for_an_eye                  = { 81517, 205191, 1 }, -- Surround yourself with a bladed bulwark, reducing Physical damage taken by 35% and dealing 739 Physical damage to any melee attackers for 10 sec.
    final_reckoning                 = { 81548, 343721, 1 }, -- Call down a blast of heavenly energy, dealing 8,566 Holy damage to all targets in the target area and causing them to take 50% increased damage from your Holy Power abilities for 8 sec. Passive: While off cooldown, your attacks have a high chance to call down a bolt that deals 1,489 Holy damage and causes the target to take 10% increased damage from your next Holy Power ability.
    final_verdict                   = { 81515, 383328, 1 }, -- Unleashes a powerful weapon strike that deals 4,067 Holy damage to an enemy target, Final Verdict has a 10% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    fires_of_justice                = { 81552, 203316, 1 }, -- Reduces the cooldown of Crusader Strike by 15% and grants it a 15% chance to make your next ability consume 1 less Holy Power.
    greater_judgment                = { 81603, 231663, 1 }, -- Judgment causes the target to take 20% increased damage from your next Holy Power ability.
    hammer_of_wrath                 = { 81510, 24275 , 1 }, -- Hurls a divine hammer that strikes an enemy for 3,575 Holy damage. Only usable on enemies that have less than 20% health, or during Avenging Wrath. Generates 1 Holy Power.
    hand_of_hindrance               = { 81541, 183218, 1 }, -- Burdens an enemy target with the weight of their misdeeds, reducing movement speed by 70% for 10 sec.
    healing_hands                   = { 81551, 326734, 1 }, -- The cooldown of Lay on Hands is reduced up to 60%, based on the target's missing health. Word of Glory's healing is increased by up to 100%, based on the target's missing health.
    highlords_judgment              = { 81533, 383271, 2 }, -- Increases Judgment damage by 8%.
    holy_blade                      = { 81546, 383342, 1 }, -- Blade of Justice generates 1 additional Holy Power.
    holy_crusader                   = { 81527, 386967, 1 }, -- Increases your Mastery by 2%.
    improved_crusader_strike        = { 81528, 383254, 1 }, -- Crusader Strike now has 2 charges.
    improved_judgment               = { 81530, 383228, 1 }, -- Reduces the cooldown of Judgment by 1 sec.
    inner_grace                     = { 81543, 383334, 1 }, -- Every 12 sec in combat, you gain 1 Holy Power.
    justicars_vengeance             = { 81517, 215661, 1 }, -- Focuses Holy energy to deliver a powerful weapon strike that deals 4,171 Holy damage, and restores health equal to the damage done. Damage is increased by 50% when used against a stunned target.
    lay_on_hands                    = { 81597, 633   , 1 }, -- Heals a friendly target for an amount equal to 100% your maximum health. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    radiant_decree                  = { 81523, 384052, 1 }, -- Replaces Wake of Ashes with Radiant Decree.
    relentless_inquisitor           = { 81540, 383388, 2 }, -- Spending Holy Power grants you 1% haste per finisher for 12 sec, stacking up to 3 times.
    righteous_verdict               = { 81531, 267610, 1 }, -- Templar's Verdict increases the damage of your next Templar's Verdict by 5% for 6 sec.
    sanctification                  = { 81543, 382430, 1 }, -- Consecration periodic damage has a chance to grant you 1 Holy Power. Chances increase up to 4 targets within Consecration.
    sanctified_ground               = { 81535, 387479, 1 }, -- Your Consecration is 15% larger, and you cannot be slowed below 80% of normal movement speed within Consecration. This effect lasts for 2 sec after leaving Consecration.
    sanctify                        = { 81544, 382536, 1 }, -- Enemies hit by Divine Storm take 100% more damage from Consecration for 8 sec.
    seal_of_wrath                   = { 81520, 386901, 1 }, -- Judgment has a 25% chance to throw a second hammer dealing an additional 585 Holy damage to the target.
    sealed_verdict                  = { 81518, 387640, 2 }, -- Abilities that spend Holy Power increase the damage of Blade of Justice by 8%.
    selfless_healer                 = { 81551, 85804 , 1 }, -- Your Holy Power spending abilities reduce the cast time of your next Flash of Light by 25%, and increase its healing done by 10%. Stacks up to 4 times.
    shield_of_vengeance             = { 81545, 184662, 1 }, -- Creates a barrier of holy light that absorbs 17,046 damage for 15 sec. When the shield expires, it bursts to inflict Holy damage equal to the total amount absorbed, divided among all nearby enemies.
    tempest_of_the_lightbringer     = { 81512, 383396, 1 }, -- Divine Storm projects an additional wave of light, striking all enemies up to 20 yards in front of you for 20% of Divine Storm's damage.
    templars_vindication            = { 81516, 383274, 2 }, -- Templar's Verdict has a 15% chance to strike again for 10% of its damage.
    truths_wake                     = { 81522, 383350, 1 }, -- Wake of Ashes burns the target for an additional 10% damage over 6 sec.
    vanguards_momentum              = { 81514, 383314, 2 }, -- Hammer of Wrath has 1 extra charge and increases Holy damage done by 2% for 10 sec, stacking 3 times.
    virtuous_command                = { 81549, 383304, 2 }, -- Judgment grants you Virtuous Command for 5 sec, which causes your Templar's Verdict, Crusader Strike, Blade of Justice, and auto attacks to deal 5% additional Holy damage.
    wake_of_ashes                   = { 81524, 255937, 1 }, -- Lash out at your enemies, dealing 10,324 Radiant damage to all enemies within 12 yd in front of you and reducing their movement speed by 50% for 5 sec. Damage reduced on secondary targets. Demon and Undead enemies are also stunned for 5 sec. Generates 3 Holy Power.
    zeal                            = { 81552, 269569, 1 }, -- Judgment empowers you with holy zeal, causing your next 2 auto attacks to occur 30% faster and deal an additional 253 Holy damage.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning     = 756 , -- (247675) When you or allies within your Aura are critically struck, gain Reckoning. Gain 1 additional stack if you are the victim. At 50 stacks of Reckoning, your next weapon swing deals 200% increased damage, will critically strike, and activates Avenging Wrath for 6 sec.
    blessing_of_sanctuary = 752 , -- (210256) Instantly removes all stun, silence, fear and horror effects from the friendly target and reduces the duration of future such effects by 60% for 5 sec.
    divine_punisher       = 755 , -- (204914) Casting two consecutive Judgments on the same enemy will generate 3 Holy Power.
    hallowed_ground       = 5535, -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    judgments_of_the_pure = 5422, -- (355858) Casting Judgment on an enemy cleanses 1 Poison, Disease, and Magic effect they have caused on allies within your Aura.
    jurisdiction          = 757 , -- (204979) Increase the range of Blade of Justice and Hammer of Justice by 10 yds, and radius of Divine Storm by 4 yds.
    law_and_order         = 858 , -- (204934) When your Hand of Hindrance is dispelled or otherwise removed early, the cooldown is reduced by 15 sec. Your Blade of Justice applies Hand of Hindrance to the target for 3 sec.
    lawbringer            = 754 , -- (246806) Judgment now applies Lawbringer to initial targets hit for 1 min. Casting Judgment on an enemy causes all other enemies with your Lawbringer effect to suffer up to 10% of their maximum health in Holy damage.
    luminescence          = 81  , -- (199428) When healed by an ally, allies within your Aura gain 4% increased damage and healing for 6 sec.
    ultimate_retribution  = 753 , -- (355614) Mark an enemy player for retribution after they kill an ally within your Retribution Aura. If the marked enemy is slain within 8 sec, cast Redemption on the fallen ally.
    unbound_freedom       = 641 , -- (305394) Blessing of Freedom increases movement speed by 30%, and you gain Blessing of Freedom when cast on a friendly target. Unbound Freedom also causes any Blessing of Freedom applied to yourself to be undispellable.
    vengeance_aura        = 751 , -- (210323) When a full loss of control effect is applied to you or an ally within your Aura, gain 6% critical strike chance for 8 sec. Max 2 stacks.
} )


-- Auras
spec:RegisterAuras( {
    -- Damage taken reduced by $w1%.  The next attack that would otherwise kill you will instead bring you to $w2% of your maximum health.
    -- https://wowhead.com/beta/spell=31850
    ardent_defender = {
        id = 31850,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $pri increased by $s1%.
    -- https://wowhead.com/beta/spell=385417
    aspiration_of_divinity = {
        id = 385417,
        duration = 6,
        max_stack = 3
    },
    -- Silenced.
    -- https://wowhead.com/beta/spell=31935
    avengers_shield = {
        id = 31935,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Crusader Strike and Judgment cool down $w2% faster.$?a384376[    Judgment, Crusader Strike, and auto-attack damage increased by $s1%.][]    $w6 nearby allies will be healed for $w5% of the damage done.
    -- https://wowhead.com/beta/spell=216331
    avenging_crusader = {
        id = 216331,
        duration = 20,
        max_stack = 1
    },
    -- Talent: $?$w2>0&$w4>0[Damage, healing and critical strike chance increased by $w2%.]?$w4==0&$w2>0[Damage and healing increased by $w2%.]?$w2==0&$w4>0[Critical strike chance increased by $w4%.][]$?a53376[ ][]$?a53376&a137029[Holy Shock's cooldown reduced by $w6%.]?a53376&a137028[Judgment generates $53376s3 additional Holy Power.]?a53376[Each Holy Power spent deals $326731s1 Holy damage to nearby enemies.][]
    -- https://wowhead.com/beta/spell=31884
    avenging_wrath = {
        id = 31884,
        duration = function() return talent.sanctified_wrath.enabled and 25 or 20 end,
        max_stack = 1
    },
    avenging_wrath_autocrit = {
        id = 294027,
        duration = 20,
        max_stack = 1,
        copy = "avenging_wrath_crit"
    },
    -- Will be healed for $w1 upon expiration.
    -- https://wowhead.com/beta/spell=223306
    bestow_faith = {
        id = 223306,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    blade_of_wrath = {
        id = 281178,
        duration = 10,
        max_stack = 1,
    },
    -- Damage against $@auracaster reduced by $w2.
    -- https://wowhead.com/beta/spell=204301
    blessed_hammer = {
        id = 204301,
        duration = 10,
        max_stack = 1
    },
    -- Damage and healing increased by $w1%$?s385129[, and Holy Power-spending abilities dealing $w4% additional increased damage and healing.][.]
    -- https://wowhead.com/beta/spell=385127
    blessing_of_dawn = {
        id = 385127,
        duration = 20,
        max_stack = 1,
        copy = 337767
    },
    blessing_of_dusk = {
        id = 385126,
        duration = 20,
        max_stack = 1,
        copy = 337757
    },
    -- Talent: Immune to movement impairing effects. $?s199325[Movement speed increased by $199325m1%][]
    -- https://wowhead.com/beta/spell=1044
    blessing_of_freedom = {
        id = 1044,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Immune to Physical damage and harmful effects.
    -- https://wowhead.com/beta/spell=1022
    blessing_of_protection = {
        id = 1022,
        duration = 10,
        mechanic = "invulneraility",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $?$w1>0[$w1% of damage taken is redirected to $@auracaster.][Taking ${$s1*$e1}% of damage taken by target ally.]
    -- https://wowhead.com/beta/spell=6940
    blessing_of_sacrifice = {
        id = 6940,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    -- Immune to magical damage and harmful effects.
    -- https://wowhead.com/beta/spell=204018
    blessing_of_spellwarding = {
        id = 204018,
        duration = 10,
        mechanic = "invulneraility",
        type = "Magic",
        max_stack = 1
    },
    -- Attack speed reduced by $w3%.  Movement speed reduced by $w4%.
    -- https://wowhead.com/beta/spell=388012
    blessing_of_winter = {
        id = 388012,
        duration = 6,
        type = "Magic",
        max_stack = 10,
        copy = 328506
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=115750
    blinding_light = {
        id = 115750,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Interrupt and Silence effects reduced by $w1%. $?s339124[Fear effects are reduced by $w4%.][]
    -- https://wowhead.com/beta/spell=317920
    concentration_aura = {
        id = 317920,
        duration = 3600,
        max_stack = 1
    },
    consecrated_blade = {
        id = 382522,
        duration = 10,
        max_stack = 1,
    },
    -- Damage every $t1 sec.
    -- https://wowhead.com/beta/spell=26573
    consecration = {
        id = 26573,
        duration = 12,
        tick_time = 1,
        type = "Magic",
        max_stack = 1,
        generate = function( c, type )
            local dropped, expires

            c.count = 0
            c.expires = 0
            c.applied = 0
            c.caster = "unknown"

            for i = 1, 5 do
                local up, name, start, duration = GetTotemInfo( i )

                if up and name == class.abilities.consecration.name then
                    dropped = start
                    expires = dropped + duration
                    break
                end
            end

            if dropped and expires > query_time then
                c.expires = expires
                c.applied = dropped
                c.count = 1
                c.caster = "player"
            end
        end
    },
    crusade = {
        id = 231895,
        duration = 25,
        type = "Magic",
        max_stack = 10,
    },
    -- Mounted speed increased by $w1%.$?$w5>0[  Incoming fear duration reduced by $w5%.][]
    -- https://wowhead.com/beta/spell=32223
    crusader_aura = {
        id = 32223,
        duration = 3600,
        max_stack = 1
    },
    -- Damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=465
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=498
    divine_protection = {
        id = 498,
        duration = 8,
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
        copy = { 355455, 384029, 386730 }
    },
    -- Immune to all attacks and harmful effects.
    -- https://wowhead.com/beta/spell=642
    divine_shield = {
        id = 642,
        duration = 8,
        mechanic = "invulneraility",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Increases ground speed by $s4%$?$w1<0[, and reduces damage taken by $w1%][].
    -- https://wowhead.com/beta/spell=221883
    divine_steed = {
        id = 221883,
        duration = function () return ( 3 + talent.seasoned_warhorse.rank + pvptalent.steed_of_glory.rank ) * ( 1 + ( conduit.lights_barding.mod * 0.01 ) ) end,
        max_stack = 1,
        copy = { 221885, 221886 },
    },
    empyrean_legacy = {
        id = 387178,
        duration = 20,
        max_stack = 1
    },
    empyrean_legacy_icd = {
        duration = 30,
        max_stack = 1
    },
    -- Talent: Your next Divine Storm is free and deals $w1% additional damage.
    -- https://wowhead.com/beta/spell=326733
    empyrean_power = {
        id = 326733,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Sentenced to suffer $w1 Holy damage.
    -- https://wowhead.com/beta/spell=343527
    execution_sentence = {
        id = 343527,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $s1 damage every $t1 sec
    -- https://wowhead.com/beta/spell=383208
    exorcism = {
        id = 383208,
        duration = 12,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    exorcism_stun = {
        id = 385149,
        duration = 5,
        max_stack = 1,
    },
    -- Talent: Deals $w1 damage over $d1.
    -- https://wowhead.com/beta/spell=273481
    expurgation = {
        id = 273481,
        duration = 6,
        tick_time = 2,
        type = "Magic",
        max_stack = 1,
        copy = 344067
    },
    -- Talent: Counterattacking all melee attacks.
    -- https://wowhead.com/beta/spell=205191
    eye_for_an_eye = {
        id = 205191,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Taking $w3% increased damage from $@auracaster's Holy Power abilities.
    -- https://wowhead.com/beta/spell=343721
    final_reckoning = {
        id = 343721,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    final_verdict = {
        id = 383329,
        duration = 15,
        max_stack = 1,
        copy = 337228
    },
    -- Talent: Your next Holy Power spender costs $s2 less Holy Power.
    -- https://wowhead.com/beta/spell=209785
    fires_of_justice = {
        id = 209785,
        duration = 15,
        max_stack = 1,
        copy = "the_fires_of_justice" -- backward compatibility
    },
    forbearance = {
        id = 25771,
        duration = 30,
        max_stack = 1,
    },
    -- Damaged or healed whenever the Paladin casts Holy Shock.
    -- https://wowhead.com/beta/spell=287280
    glimmer_of_light = {
        id = 287280,
        duration = 30,
        type = "Magic",
        max_stack = 1
    },
    -- Stunned.
    -- https://wowhead.com/beta/spell=853
    hammer_of_justice = {
        id = 853,
        duration = 6,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=183218
    hand_of_hindrance = {
        id = 183218,
        duration = 10,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Taunted.
    -- https://wowhead.com/beta/spell=62124
    hand_of_reckoning = {
        id = 62124,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    -- Talent: Your Holy Power generation is tripled.
    -- https://wowhead.com/beta/spell=105809
    holy_avenger = {
        id = 105809,
        duration = 20,
        max_stack = 1
    },
    inquisition = {
        id = 84963,
        duration = 45,
        max_stack = 1,
    },
    -- Taking $w1% increased damage from $@auracaster's next Holy Power ability.
    -- https://wowhead.com/beta/spell=197277
    judgment = {
        id = 197277,
        duration = 15,
        max_stack = 1,
        copy = 214222
    },
    -- Talent: Attackers are healed for $183811s1.
    -- https://wowhead.com/beta/spell=196941
    judgment_of_light = {
        id = 196941,
        duration = 30,
        max_stack = 25
    },
    -- Healing for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=378412
    light_of_the_titans = {
        id = 378412,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=383469
    radiant_decree = {
        id = 383469,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Burning with holy fire for $w1 Holy damage every $t1 sec.
    -- https://wowhead.com/beta/spell=278145
    radiant_incandescence = {
        id = 278145,
        duration = 3,
        tick_time = 1,
        type = "Magic",
        max_stack = 1,
        copy = 278147
    },
    recompense = {
        id = 397191,
        duration = 12,
        max_stack = 1,
    },
    -- Taking $w2% increased damage from $@auracaster's next Holy Power ability.
    -- https://wowhead.com/beta/spell=343724
    reckoning = {
        id = 343724,
        duration = 15,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=383389
    relentless_inquisitor = {
        id = 383389,
        duration = 12,
        max_stack = 3,
        copy = 337315
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=20066
    repentance = {
        id = 20066,
        duration = 60,
        mechanic = "incapacitate",
        type = "Magic",
        max_stack = 1
    },
    -- When any party or raid member within $a1 yards dies, you gain Avenging Wrath for $w1 sec.    When any party or raid member within $a1 yards takes more than $s3% of their health in damage, you gain Seraphim for $s4 sec. This cannot occur more than once every 30 sec.
    -- https://wowhead.com/beta/spell=183435
    retribution_aura = {
        id = 183435,
        duration = 3600,
        max_stack = 1
    },
    righteous_verdict = {
        id = 267611,
        duration = 6,
        max_stack = 1,
    },
    sanctified_ground = {
        id = 387480,
        duration = 3600,
        max_stack = 1,
    },
    sanctify = {
        id = 382538,
        duration = 8,
        max_stack = 1,
    },
    seal_of_clarity = {
        id = 384810,
        duration = 15,
        max_stack = 1
    },
    -- Talent: $@spellaura385728
    -- https://wowhead.com/beta/spell=385723
    seal_of_the_crusader = {
        id = 385723,
        duration = 5,
        max_stack = 1
    },
    sealed_verdict = {
        id = 387643,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Flash of Light cast time reduced by $w1%.  Flash of Light heals for $w2% more.
    -- https://wowhead.com/beta/spell=114250
    selfless_healer = {
        id = 114250,
        duration = 15,
        max_stack = 4
    },
    -- Talent: Haste, Critical Strike, and Versatility increased by $s1%, and Mastery increased by $?c1[${$s4*$183997bc1}]?c2[${$s4*$76671bc1}][${$s4*$267316bc1}]%.
    -- https://wowhead.com/beta/spell=152262
    seraphim = {
        id = 152262,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Absorbs $w1 damage and deals damage when the barrier fades or is fully consumed.
    -- https://wowhead.com/beta/spell=184662
    shield_of_vengeance = {
        id = 184662,
        duration = 15,
        mechanic = "shield",
        type = "Magic",
        max_stack = 1
    },
    -- $?$w2>1[Absorbs the next ${$w2-1} damage.][Absorption exhausted.]  Refreshed to $w1 absorption every $t1 sec.
    -- https://wowhead.com/beta/spell=337824
    shock_barrier = {
        id = 337824,
        duration = 18,
        tick_time = 6,
        type = "Magic",
        max_stack = 1
    },
    the_magistrates_judgment = {
        id = 337682,
        duration = 15,
        max_stack = 1,
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=10326
    turn_evil = {
        id = 10326,
        duration = 40,
        mechanic = "turn",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Holy Damage increased by $w1%.
    -- https://wowhead.com/beta/spell=383311
    vanguards_momentum = {
        id = 383311,
        duration = 10,
        max_stack = 3,
        copy = 345046
    },
    virtuous_command = {
        id = 383307,
        duration = 5,
        max_stack = 1,
        copy = 339664
    },
    -- Talent: Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=255937
    wake_of_ashes = {
        id = 255937,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    wake_of_ashes_stun = {
        id = 255941,
        duration = 5,
        max_stack = 1,
    },
    -- Talent: Auto attack speed increased and deals additional Holy damage.
    -- https://wowhead.com/beta/spell=269571
    zeal = {
        id = 269571,
        duration = 20,
        max_stack = 1
    },

    paladin_aura = {
        alias = { "concentration_aura", "crusader_aura", "devotion_aura", "retribution_aura" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },

    empyreal_ward = {
        id = 387792,
        duration = 60,
        max_stack = 1,
        copy = 287731
    },
    -- Power: 335069
    negative_energy_token_proc = {
        id = 345693,
        duration = 5,
        max_stack = 1,
    },
    reckoning_pvp = {
        id = 247677,
        max_stack = 30,
        duration = 30
    },
    truths_wake = {
        id = 383351,
        duration = 6,
        max_stack = 1,
        copy = 339376
    },
} )


-- Legacy sets.
spec:RegisterAuras( {
    sacred_judgment = {
        id = 246973,
        duration = 8
    },
    hidden_retribution_t21_4p = {
        id = 253806,
        duration = 15
    },
    whisper_of_the_nathrezim = {
        id = 207633,
        duration = 3600
    },
    ashes_to_dust = {
        id = 236106,
        duration = 6
    },
    chain_of_thrayn = {
        id = 236328,
        duration = 3600
    },
    liadrins_fury_unleashed = {
        id = 208410,
        duration = 3600,
    },
    scarlet_inquisitors_expurgation = {
        id = 248289,
        duration = 3600,
        max_stack = 3
    }
} )


spec:RegisterHook( "prespend", function( amt, resource, overcap )
    if resource == "holy_power" and amt < 0 and buff.holy_avenger.up then
        return amt * 3, resource, overcap
    end
end )


spec:RegisterHook( "spend", function( amt, resource )
    if amt > 0 and resource == "holy_power" then
        if talent.crusade.enabled and buff.crusade.up then
            addStack( "crusade", buff.crusade.remains, amt )
        end
        if talent.fist_of_justice.enabled then
            setCooldown( "hammer_of_justice", max( 0, cooldown.hammer_of_justice.remains - talent.fist_of_justice.rank * amt ) )
        end
        if legendary.uthers_devotion.enabled then
            setCooldown( "blessing_of_freedom", max( 0, cooldown.blessing_of_freedom.remains - 1 ) )
            setCooldown( "blessing_of_protection", max( 0, cooldown.blessing_of_protection.remains - 1 ) )
            setCooldown( "blessing_of_sacrifice", max( 0, cooldown.blessing_of_sacrifice.remains - 1 ) )
            setCooldown( "blessing_of_spellwarding", max( 0, cooldown.blessing_of_spellwarding.remains - 1 ) )
        end
        if legendary.relentless_inquisitor.enabled or talent.relentless_inquisitor.enabled then
            if buff.relentless_inquisitor.stack < ( 3 * talent.relentless_inquisitor.rank ) then
                stat.haste = stat.haste + 0.01
            end
            addStack( "relentless_inquisitor" )
        end
        if ( talent.of_dusk_and_dawn.enabled or legendary.of_dusk_and_dawn.enabled ) and holy_power.current == 0 then applyBuff( "blessing_of_dusk" ) end
        if talent.sealed_verdict.enabled then applyBuff( "sealed_verdict" ) end
        if talent.selfless_healer.enabled then addStack( "selfless_healer" ) end
    end
end )

spec:RegisterHook( "gain", function( amt, resource, overcap )
    if ( talent.of_dusk_and_dawn.enabled or legendary.of_dusk_and_dawn.enabled ) and amt > 0 and resource == "holy_power" and holy_power.current == 5 then
        applyBuff( "blessing_of_dawn" )
    end
end )

spec:RegisterStateExpr( "time_to_hpg", function ()
    return max( gcd.remains, min( cooldown.judgment.true_remains, cooldown.crusader_strike.true_remains, cooldown.blade_of_justice.true_remains, ( state:IsUsable( "hammer_of_wrath" ) and cooldown.hammer_of_wrath.true_remains or 999 ), action.wake_of_ashes.known and cooldown.wake_of_ashes.true_remains or 999, ( race.blood_elf and cooldown.arcane_torrent.true_remains or 999 ), ( action.divine_toll.known and cooldown.divine_toll.true_remains or 999 ) ) )
end )


local last_empyrean_legacy_icd_expires = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if destGUID == state.GUID and subtype == "SPELL_AURA_APPLIED" and spellID == class.auras.empyrean_legacy.id then
        last_empyrean_legacy_icd_expires = GetTime() + 30
    end
end )

spec:RegisterStateExpr( "consecration", function () return buff.consecration end )


spec:RegisterGear( "tier29", 200417, 200419, 200414, 200416, 200418 )


spec:RegisterHook( "reset_precast", function ()
    if buff.divine_resonance.up then
        state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires, "AURA_PERIODIC" )
        if buff.divine_resonance.remains > 5 then state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires - 5, "AURA_PERIODIC" ) end
        if buff.divine_resonance.remains > 10 then state:QueueAuraEvent( "divine_toll", class.abilities.judgment.handler, buff.divine_resonance.expires - 10, "AURA_PERIODIC" ) end
    end

    if last_empyrean_legacy_icd_expires > query_time then
        applyDebuff( "player", "empyrean_legacy_icd", last_empyrean_legacy_icd_expires - query_time )
    end
end )


spec:RegisterStateFunction( "apply_aura", function( name )
    removeBuff( "concentration_aura" )
    removeBuff( "crusader_aura" )
    removeBuff( "devotion_aura" )
    removeBuff( "retribution_aura" )

    if name then applyBuff( name ) end
end )

spec:RegisterStateFunction( "foj_cost", function( amt )
    if buff.fires_of_justice.up then return max( 0, amt - 1 ) end
    return amt
end )


-- Abilities
spec:RegisterAbilities( {
    -- Talent: Call upon the Light to become an avatar of retribution, $?s53376&c2[causing Judgment to generate $53376s3 additional Holy Power, ]?s53376&c3[each Holy Power spent causing you to explode with Holy light for $326731s1 damage to nearby enemies, ]?s53376&c1[reducing Holy Shock's cooldown by $53376s2%, ][]$?s326730[allowing Hammer of Wrath to be used on any target, ][]$?s384442&s384376[increasing your damage, healing and critical strike chance by $s2% for $d.]?!s384442[increasing your damage and healing by $s1% for $d.]?!s384376[increasing your critical strike chance by $s3% for $d.][and activating all the effects learned for Avenging Wrath for $d.]
    avenging_wrath = {
        id = 31884,
        cast = 0,
        cooldown = function () return 120 * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) end,
        gcd = "off",
        school = "holy",

        notalent = "crusade",
        startsCombat = false,
        toggle = "cooldowns",

        usable = function() return talent.avenging_wrath.enabled or talent.sanctified_wrath.enabled or talent.avenging_wrath_might.enabled, "requires avenging_wrath/avenging_wrath_might/sanctified_wrath" end,

        handler = function ()
            applyBuff( "avenging_wrath" )
        end,
    },

    -- Talent: Pierces an enemy with a blade of light, dealing $s1 Physical damage.    |cFFFFFFFFGenerates $s2 Holy Power.|r
    blade_of_justice = {
        id = 184575,
        cast = 0,
        cooldown = function() return 12 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) end,
        gcd = "spell",
        school = "physical",

        spend = function() return talent.holy_blade.enabled and -3 or -2 end,
        spendType = "holy_power",

        talent = "blade_of_justice",
        startsCombat = true,

        handler = function ()
            if buff.consecrated_blade.up then
                class.abilities.consecration.handler()
                removeBuff( "consecrated_blade" )
            end
            removeBuff( "blade_of_wrath" )
            removeBuff( "sacred_judgment" )
        end,
    },

    -- Talent: Blesses a party or raid member, granting immunity to movement impairing effects $?s199325[and increasing movement speed by $199325m1% ][]for $d.
    blessing_of_freedom = {
        id = 1044,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "holy",

        spend = 0.07,
        spendType = "mana",

        talent = "blessing_of_freedom",
        startsCombat = false,

        handler = function ()
            applyBuff( "blessing_of_freedom" )
        end,
    },

    -- Talent: Blesses a party or raid member, granting immunity to Physical damage and harmful effects for $d.    Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.$?c2[    Shares a cooldown with Blessing of Spellwarding.][]
    blessing_of_protection = {
        id = 1022,
        cast = 0,
        cooldown = function() return talent.improved_blessing_of_protection.enabled and 240 or 300 end,
        gcd = "spell",
        school = "holy",

        spend = 0.15,
        spendType = "mana",

        talent = "blessing_of_protection",
        startsCombat = false,

        handler = function ()
            applyBuff( "blessing_of_protection" )
            applyDebuff( "player", "forbearance" )
            if talent.blessing_of_spellwarding.enabled then setCooldown( "blessing_of_spellwarding", action.blessing_of_spellwarding.cooldown ) end
        end,
    },

    -- Talent: Blesses a party or raid member, reducing their damage taken by $s1%, but you suffer ${100*$e1}% of damage prevented.    Last $d, or until transferred damage would cause you to fall below $s3% health.
    blessing_of_sacrifice = {
        id = 6940,
        cast = 0,
        cooldown = function() return talent.sacrifice_of_the_just.enabled and 60 or 120 end,
        gcd = "off",
        school = "holy",

        spend = 0.07,
        spendType = "mana",

        talent = "blessing_of_sacrifice",
        startsCombat = false,

        handler = function ()
            applyBuff( "blessing_of_sacrifice" )
        end,
    },

    -- Talent: Emits dazzling light in all directions, blinding enemies within $105421A1 yards, causing them to wander disoriented for $105421d. Non-Holy damage will break the disorient effect.
    blinding_light = {
        id = 115750,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        school = "holy",

        spend = 0.06,
        spendType = "mana",

        talent = "blinding_light",
        startsCombat = false,
        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "blinding_light" )
            active_dot.blinding_light = max( active_enemies, active_dot.blinding_light )
        end,
    },

    -- Talent: Cleanses a friendly target, removing all Poison and Disease effects.
    cleanse_toxins = {
        id = 213644,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "holy",

        spend = 0.065,
        spendType = "mana",

        talent = "cleanse_toxins",
        startsCombat = false,

        usable = function ()
            return buff.dispellable_poison.up or buff.dispellable_disease.up, "requires poison or disease"
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_disease" )
        end,
    },

    -- Interrupt and Silence effects on party and raid members within $a1 yards are $s1% shorter. $?s339124[Fear effects are also reduced.][]
    concentration_aura = {
        id = 317920,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        talent = "auras_of_the_resolute",
        startsCombat = false,
        nobuff = "paladin_aura",

        handler = function ()
            apply_aura( "concentration_aura" )
        end,
    },

    -- Consecrates the land beneath you, causing $<dmg> Holy damage over $d to enemies who enter the area$?s204054[ and reducing their movement speed by $204054s2%.][.] Limit $s2.
    consecration = {
        id = 26573,
        cast = 0,
        cooldown = 9,
        gcd = "spell",
        school = "holy",

        startsCombat = false,

        handler = function ()
            applyBuff( "consecration" )
        end,
    },


    crusade = {
        id = 231895,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "crusade",
        toggle = "cooldowns",

        startsCombat = false,
        texture = 236262,

        nobuff = "crusade",

        handler = function ()
            applyBuff( "crusade" )
        end,
    },

    -- Increases mounted speed by $s1% for all party and raid members within $a1 yards.
    crusader_aura = {
        id = 32223,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        talent = "auras_of_swift_vengeance",
        startsCombat = false,
        nobuff = "paladin_aura",

        handler = function ()
            apply_aura( "crusader_aura" )
        end,
    },

    -- Strike the target for $<damage> Physical damage.$?a196926[    Reduces the cooldown of Holy Shock by ${$196926m1/-1000}.1 sec.][]    |cFFFFFFFFGenerates $s2 Holy Power.
    crusader_strike = {
        id = 35395,
        cast = 0,
        charges = function() return talent.improved_crusader_strike.enabled and 2 or nil end,
        cooldown = function () return 6 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste end,
        recharge = function () return talent.improved_crusader_strike.enabled and ( 6 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste ) or nil end,
        gcd = "spell",
        school = "physical",

        spend = 0.11,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            if talent.aspiration_of_divinity.enabled then addStack( "aspiration_of_divinity" ) end
            if talent.crusaders_might.enabled then reduceCooldown( "holy_shock", 1 ) end
        end,
    },

    -- Party and raid members within $a1 yards are bolstered by their devotion, reducing damage taken by $s1%.
    devotion_aura = {
        id = 465,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        talent = "auras_of_the_resolute",
        startsCombat = false,
        nobuff = "paladin_aura",

        handler = function ()
            apply_aura( "devotion_aura" )
        end,
    },

    -- Talent: Reduces all damage you take by $s1% for $d.
    divine_protection = {
        id = 498,
        cast = 0,
        cooldown = function () return 60 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) end,
        gcd = "off",
        school = "holy",

        spend = 0.035,
        spendType = "mana",

        talent = "divine_protection",
        startsCombat = false,

        handler = function ()
            applyBuff( "divine_protection" )
        end,
    },

    -- Grants immunity to all damage and harmful effects for $d. $?a204077[Taunts all targets within 15 yd.][]    Cannot be used if you have Forbearance. Causes Forbearance for $25771d.
    divine_shield = {
        id = 642,
        cast = 0,
        cooldown = function () return 300 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) end,
        gcd = "spell",
        school = "holy",

        startsCombat = false,

        toggle = "cooldowns",
        nodebuff = "forbearance",

        handler = function ()
            applyBuff( "divine_shield" )
            applyDebuff( "player", "forbearance" )
        end,
    },

    -- Talent: Leap atop your Charger for $221883d, increasing movement speed by $221883s4%. Usable while indoors or in combat.
    divine_steed = {
        id = 190784,
        cast = 0,
        charges = function () return talent.cavalier.enabled and 2 or nil end,
        cooldown = 45,
        recharge = function () return talent.cavalier.enabled and 45 or nil end,
        gcd = "spell",
        school = "holy",

        talent = "divine_steed",
        startsCombat = false,

        handler = function ()
            applyBuff( "divine_steed" )
        end,

        copy = 221883
    },

    -- Talent: Unleashes a whirl of divine energy, dealing $s1 Holy damage to all nearby enemies. Deals reduced damage beyond $s2 targets.
    divine_storm = {
        id = 53385,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            if buff.empyrean_power.up then return 0 end
            return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        talent = "divine_storm",
        startsCombat = true,

        handler = function ()
            removeDebuff( "target", "judgment" )
            removeDebuff( "target", "reckoning" )

            if buff.empyrean_power.up then
                removeBuff( "empyrean_power" )
            elseif buff.divine_purpose.up then
                removeBuff( "divine_purpose" )
            else
                removeBuff( "fires_of_justice" )
                removeBuff( "hidden_retribution_t21_4p" )
            end

            if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
        end,
    },

    -- Talent: Instantly cast $?a137029[Holy Shock]?a137028[Avenger's Shield]?a137027[Judgment][Holy Shock, Avenger's Shield, or Judgment] on up to $s1 targets within $A2 yds.$?(a384027|a386738|a387893)[    After casting Divine Toll, you instantly cast ][]$?(a387893&c1)[Holy Shock]?(a386738&c2)[Avenger's Shield]?(a384027&c3)[Judgment][]$?a387893[ every $387895t1 sec. This effect lasts $387895d.][]$?a384027[ every $384029t1 sec. This effect lasts $384029d.][]$?a386738[ every $386730t1 sec. This effect lasts $386730d.][]$?c3[    Divine Toll's Judgment deals $326011s1% increased damage.][]$?c2[    Generates $s5 Holy Power per target hit.][]
    divine_toll = {
        id = function() return talent.divine_toll.enabled and 375576 or 304971 end,
        cast = 0,
        cooldown = function() return talent.quickened_invocations.enabled and 45 or 60 end,
        gcd = "spell",
        school = "arcane",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            local spellToCast

            if state.spec.protection then spellToCast = class.abilities.avengers_shield.handler
            elseif state.spec.retribution then spellToCast = class.abilities.judgment.handler
            else spellToCast = class.abilities.holy_shock.handler end

            for i = 1, min( 5, true_active_enemies ) do
                spellToCast()
            end

            if legendary.divine_resonance.enabled then
                applyBuff( "divine_resonance" )
                state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires, "AURA_PERIODIC" )
                state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires - 5, "AURA_PERIODIC" )
                state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires - 10, "AURA_PERIODIC" )
            end
        end,

        copy = { 375576, 304971 }
    },

    -- Talent: A hammer slowly falls from the sky upon the target. After $d, they suffer ${$387113s1*$<mult>} Holy damage$?s387196[ and enemies within $387200a2 yards will suffer $387196s1% of the damage taken from your abilities in that time.][, plus $s2% of damage taken from your abilities in that time.]
    execution_sentence = {
        id = 343527,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        talent = "execution_sentence",
        startsCombat = false,

        handler = function ()
            removeDebuff( "target", "reckoning" )
            if buff.divine_purpose.up then removeBuff( "divine_purpose" )
            else
                removeBuff( "fires_of_justice" )
                removeBuff( "hidden_retribution_t21_4p" )
            end
            applyDebuff( "target", "execution_sentence" )
        end,
    },

    -- Talent: Blasts the target with Holy Light, causing $383921s1 Holy damage and burns the target for an additional ${$383208s1*($383208d/$383208t)} Holy Damage over $383208d. Stuns Demon and Undead targets for $385149d.    Applies the damage over time effect to up to $s2 nearby enemies if the target is standing within your Consecration.
    exorcism = {
        id = 383185,
        cast = 0,
        cooldown = 20,
        gcd = "spell",
        school = "holy",

        talent = "exorcism",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "exorcism" )
            if target.is_demon or target.is_undead then applyDebuff( "target", "exorcism_stun" ) end
        end,
    },

    -- Talent: Surround yourself with a bladed bulwark, reducing Physical damage taken by $s2% and dealing $205202sw1 Physical damage to any melee attackers for $d.
    eye_for_an_eye = {
        id = 205191,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "physical",

        talent = "eye_for_an_eye",
        startsCombat = false,

        handler = function ()
            applyBuff( "eye_for_an_eye" )
        end,
    },

    -- Talent: Call down a blast of heavenly energy, dealing $s2 Holy damage to all targets in the target area and causing them to take $s3% increased damage from your Holy Power abilities for $d.    |cFFFFFFFFPassive:|r $@spelldesc343723
    final_reckoning = {
        id = 343721,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "holy",

        talent = "final_reckoning",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "final_reckoning" )
        end,
    },

    -- Expends a large amount of mana to quickly heal a friendly target for $?$c1&$?a134735[${$s1*1.15}][$s1].
    flash_of_light = {
        id = 19750,
        cast = function () return ( 1.5 - ( buff.selfless_healer.stack * 0.5 ) ) * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.22,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            removeBuff( "selfless_healer" )
        end,
    },

    -- Stuns the target for $d.
    hammer_of_justice = {
        id = 853,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "holy",

        spend = 0.035,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hammer_of_justice" )
        end,
    },


    hammer_of_reckoning = {
        id = 247675,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        startsCombat = true,
        -- texture = ???,

        pvptalent = "hammer_of_reckoning",

        usable = function () return buff.reckoning.stack >= 50 end,
        handler = function ()
            removeStack( "reckoning", 50 )
            if talent.crusade.enabled then
                applyBuff( "crusade", 12 )
            else
                applyBuff( "avenging_wrath", 6 )
            end
        end,
    },

    -- Talent: Hurls a divine hammer that strikes an enemy for $<damage> Holy damage. Only usable on enemies that have less than 20% health$?s326730[, or during Avenging Wrath][].    |cFFFFFFFFGenerates $s2 Holy Power.
    hammer_of_wrath = {
        id = 24275,
        cast = 0,
        charges = function() return talent.vanguards_momentum.enabled and 2 or nil end,
        cooldown = function() return 7.5 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) end,
        recharge = function() return talent.vanguards_momentum.enabled and ( 7.5 * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) ) or nil end,
        hasteCD = true,
        gcd = "spell",
        school = "holy",

        spend = -1,
        spendType = "holy_power",

        talent = "hammer_of_wrath",
        startsCombat = false,

        usable = function () return target.health_pct < 20 or ( level > 57 and talent.avenging_wrath.enabled and ( buff.avenging_wrath.up or buff.crusade.up ) ) or buff.final_verdict.up or buff.hammer_of_wrath_hallow.up or buff.negative_energy_token_proc.up, "requires buff/talent or target under 20% health" end,
        handler = function ()
            removeBuff( "final_verdict" )
            if legendary.the_mad_paragon.enabled then
                if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 1 end
                if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 1 end
            end
            if talent.vanguards_momentum.enabled or legendary.vanguards_momentum.enabled then addStack( "vanguards_momentum" ) end
            if talent.zealots_paragon.enabled then
                if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 0.5 end
                if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 0.5 end
            end
        end,
    },

    -- Talent: Burdens an enemy target with the weight of their misdeeds, reducing movement speed by $s1% for $d.
    hand_of_hindrance = {
        id = 183218,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "holy",

        spend = 0.1,
        spendType = "mana",

        talent = "hand_of_hindrance",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "hand_of_hindrance" )
        end,
    },

    -- Commands the attention of an enemy target, forcing them to attack you.
    hand_of_reckoning = {
        id = 62124,
        cast = 0,
        cooldown = 8,
        gcd = "off",
        school = "holy",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hand_of_reckoning" )
        end,
    },

    -- Talent: Your Holy Power generation is tripled for $d.
    holy_avenger = {
        id = 105809,
        cast = 0,
        cooldown = 180,
        gcd = "off",
        school = "physical",

        talent = "holy_avenger",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "holy_avenger" )
        end,
    },

    -- Petition the Light on the behalf of a fallen ally, restoring spirit to body and allowing them to reenter battle with $s2% health and at least $s1% mana.
    intercession = {
        id = 391054,
        cast = 2,
        cooldown = 600,
        gcd = "spell",
        school = "holy",

        spend = 3,
        spendType = "holy_power",

        startsCombat = false,

        handler = function ()
            -- brez.
        end,
    },

    -- Judges the target, dealing $s1 Holy damage$?s231663[, and causing them to take $197277s1% increased damage from your next Holy Power ability.][]$?s315867[    |cFFFFFFFFGenerates $220637s1 Holy Power.][]
    judgment = {
        id = 20271,
        cast = 0,
        -- charges = 1,
        cooldown = function() return ( talent.improved_judgment.enabled and 11 or 12 ) * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) end,
        -- recharge = function() return ( talent.improved_judgment.enabled and 11 or 12) * ( talent.seal_of_order.enabled and buff.blessing_of_dusk.up and 0.9 or 1 ) end,
        hasteCD = true,
        gcd = "spell",
        school = "holy",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            removeBuff( "recompense" )
            applyDebuff( "target", "judgment" )
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            if talent.empyrean_legacy.enabled and debuff.empyrean_legacy_icd.down then
                applyBuff( "empyrean_legacy" )
                applyDebuff( "player", "empyrean_legacy_icd" )
            end
            if talent.judgment_of_light.enabled then applyDebuff( "target", "judgment_of_light", nil, 25 ) end
            if talent.virtuous_command.enabled or conduit.virtuous_command.enabled then applyBuff( "virtuous_command" ) end
            if talent.zeal.enabled then applyBuff( "zeal", 20, 2 ) end
            if talent.zealots_paragon.enabled then
                if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 0.5 end
                if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 0.5 end
            end
        end,
    },

    -- Talent: Focuses Holy energy to deliver a powerful weapon strike that deals $s1 Holy damage, and restores health equal to the damage done.    Damage is increased by $s2% when used against a stunned target.
    justicars_vengeance = {
        id = 215661,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        talent = "justicars_vengeance",
        startsCombat = true,

        handler = function ()
            removeDebuff( "target", "reckoning" )
            if buff.divine_purpose.up then removeBuff( "divine_purpose" )
            else
                removeBuff( "fires_of_justice" )
                removeBuff( "hidden_retribution_t21_4p" )
            end
        end,
    },

    -- Talent: Heals a friendly target for an amount equal to $s2% your maximum health.$?a387791[    Grants the target $387792s1% increased armor for $387792d.][]    Cannot be used on a target with Forbearance. Causes Forbearance for $25771d.
    lay_on_hands = {
        id = 633,
        cast = 0,
        cooldown = function () return 600 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) end,
        gcd = "off",
        school = "holy",

        talent = "lay_on_hands",
        startsCombat = false,

        toggle = "cooldowns",
        nodebuff = "forbearance",

        handler = function ()
            gain( health.max, "health" )
            applyDebuff( "player", "forbearance", 30 )

            if talent.liadrins_fury_reborn.enabled then
                gain( 5, "holy_power" )
            end

            if azerite.empyreal_ward.enabled then applyBuff( "empyreal_ward" ) end
        end,
    },

    -- Talent: Lash out at your enemies, dealing $s1 Radiant damage to all enemies within $a1 yd in front of you and reducing their movement speed by $s2% for $d. Damage reduced on secondary targets.    Demon and Undead enemies are also stunned for $255941d.    |cFFFFFFFFGenerates $s3 Holy Power.
    radiant_decree = {
        id = 383469,
        known = 255937,
        flash = { 383469, 255937 },
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holyfire",

        spend = 3,
        spendType = "holy_power",

        talent = "radiant_decree",
        startsCombat = true,

        usable = function ()
            if settings.check_wake_range and not ( target.exists and target.within12 ) then return false, "target is outside of 12 yards" end
            return true
        end,

        handler = function ()
            removeDebuff( "target", "judgment" )
            removeDebuff( "target", "reckoning" )
            if target.is_undead or target.is_demon then applyDebuff( "target", "radiant_decree" ) end
            if talent.divine_judgment.enabled then addStack( "divine_judgment" ) end
            if talent.truths_wake.enabled or conduit.truths_wake.enabled then applyDebuff( "target", "truths_wake" ) end
        end,
    },

    -- Talent: Interrupts spellcasting and prevents any spell in that school from being cast for $d.
    rebuke = {
        id = 96231,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "rebuke",
        startsCombat = false,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },

    -- Talent: Forces an enemy target to meditate, incapacitating them for $d.    Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    repentance = {
        id = 20066,
        cast = 1.7,
        cooldown = 15,
        gcd = "spell",
        school = "holy",

        spend = 0.06,
        spendType = "mana",

        talent = "repentance",
        startsCombat = false,

        handler = function ()
            interrupt()
            applyDebuff( "target", "repentance" )
        end,
    },

    -- When any party or raid member within $a1 yards dies, you gain Avenging Wrath for $s1 sec.    When any party or raid member within $a1 yards takes more than $s3% of their health in damage, you gain Seraphim for $s4 sec. This cannot occur more than once every 30 sec.
    retribution_aura = {
        id = 183435,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        talent = "auras_of_swift_vengeance",
        startsCombat = false,
        nobuff = "paladin_aura",

        handler = function ()
            apply_aura( "retribution_aura" )
        end,
    },

    -- Talent: The Light magnifies your power for $d, granting $s1% Haste, Critical Strike, and Versatility, and $?c1[${$s4*$183997bc1}]?c2[${$s4*$76671bc1}][${$s4*$267316bc1}]% Mastery.
    seraphim = {
        id = 152262,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "holy",

        spend = function () return 3 - ( buff.the_magistrates_judgment.up and 1 or 0 ) end,
        spendType = "holy_power",

        talent = "seraphim",
        startsCombat = false,

        handler = function ()
            applyBuff( "seraphim" )
        end,
    },

    -- Slams enemies in front of you with your shield, causing $s1 Holy damage, and increasing your Armor by $?c1[${$132403s1*$INT/100}][${$132403s1*$STR/100}] for $132403d.$?a386568[    $@spelldesc386568][]$?a280373[    $@spelldesc280373][]
    shield_of_the_righteous = {
        id = 53600,
        cast = 0,
        cooldown = 1,
        gcd = "off",
        school = "holy",

        spend = function () return 3  - ( buff.the_magistrates_judgment.up and 1 or 0 ) - ( buff.seal_of_clarity.up and 1 or 0 ) end,
        spendType = "holy_power",

        startsCombat = true,

        usable = function() return equipped.shield, "requires a shield" end,

        handler = function ()
            removeBuff( "seal_of_clarity" )
            removeBuff( "the_magistrates_judgment" )
            applyBuff( "shield_of_the_righteous" )
        end,
    },

    -- Talent: Creates a barrier of holy light that absorbs $<shield> damage for $d.    When the shield expires, it bursts to inflict Holy damage equal to the total amount absorbed, divided among all nearby enemies.
    shield_of_vengeance = {
        id = 184662,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        school = "holy",

        talent = "shield_of_vengeance",
        startsCombat = false,

        toggle = "defensives",

        usable = function () return incoming_damage_3s > 0.2 * health.max, "incoming damage over 3s is less than 20% of max health" end,
        handler = function ()
            applyBuff( "shield_of_vengeance" )
        end,
    },

    -- Unleashes a powerful weapon strike that deals $224266s1 Holy damage to an enemy target.
    templars_verdict = {
        id = function() return talent.final_verdict.enabled and 383328 or runeforge.final_verdict.enabled and 336872 or 85256 end,
        known = 85256,
        flash = { 85256, 336872, 383328 },
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        startsCombat = true,

        handler = function ()
            removeDebuff( "target", "judgment" )
            removeDebuff( "target", "reckoning" )
            removeStack( "vanquishers_hammer" )
            if buff.divine_purpose.up then removeBuff( "divine_purpose" )
            else
                removeBuff( "fires_of_justice" )
                removeBuff( "hidden_retribution_t21_4p" )
            end
            if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
            if buff.empyrean_legacy.up then
                class.abilities.divine_storm.handler() -- TODO: Check for resource gain?
                removeBuff( "empyrean_legacy" )
            end
            if talent.executioners_will.enabled and debuff.execution_sentence.up and debuff.execution_sentence.expires - debuff.execution_sentence.applied < 16 then
                debuff.execution_sentence.expires = debuff.execution_sentence.expires + 1
            end
            if talent.righteous_verdict.enabled then applyBuff( "righteous_verdict" ) end
            if talent.divine_judgment.enabled then addStack( "divine_judgment" ) end
        end,

        copy = { "final_verdict", 336872, 383328 },
    },

    -- Talent: The power of the Light compels an Undead, Aberration, or Demon target to flee for up to $d. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    turn_evil = {
        id = 10326,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",
        school = "holy",

        spend = 0.105,
        spendType = "mana",

        talent = "turn_evil",
        startsCombat = false,

        handler = function ()
            applyBuff( "turn_evil" )
        end,
    },

    -- Talent: Lash out at your enemies, dealing $s1 Radiant damage to all enemies within $a1 yd in front of you and reducing their movement speed by $s2% for $d. Damage reduced on secondary targets.    Demon and Undead enemies are also stunned for $255941d.    |cFFFFFFFFGenerates $s3 Holy Power.
    wake_of_ashes = {
        id = 255937,
        flash = { 383469, 255937 },
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holyfire",

        spend = function() return -3 + ( buff.holy_avenger.up and -6 or 0 ) end,
        spendType = "holy_power",

        talent = "wake_of_ashes",
        notalent = "radiant_decree",
        startsCombat = true,

        usable = function ()
            if settings.check_wake_range and not ( target.exists and target.within12 ) then return false, "target is outside of 12 yards" end
            return true
        end,

        handler = function ()
            if target.is_undead or target.is_demon then applyDebuff( "target", "wake_of_ashes" ) end
            if talent.divine_judgment.enabled then addStack( "divine_judgment" ) end
            if conduit.truths_wake.enabled then applyDebuff( "target", "truths_wake" ) end
        end,
    },

    -- Calls down the Light to heal a friendly target for $130551s1$?a378405[ and an additional $378412s1 over $378412d][].$?a379043[ Your block chance is increased by$379043s1% for $379041d.][]$?a315921&!a315924[    |cFFFFFFFFProtection:|r If cast on yourself, healing increased by up to $315921s1% based on your missing health.][]$?a315924[    |cFFFFFFFFProtection:|r Healing increased by up to $315921s1% based on the target's missing health.][]
    word_of_glory = {
        id = 85673,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 ) - ( buff.the_magistrates_judgment.up and 1 or 0 ) - ( buff.seal_of_clarity.up and 1 or 0 )
        end,
        spendType = "holy_power",

        startsCombat = false,

        handler = function ()
            removeBuff( "recompense" )
            if buff.divine_purpose.up then removeBuff( "divine_purpose" )
            else
                removeBuff( "fires_of_justice" )
                removeBuff( "hidden_retribution_t21_4p" )
                removeBuff( "the_magistrates_judgment" )
                removeBuff( "seal_of_clarity" )
            end
            gain( 1.33 * stat.spell_power * 8, "health" )

            if conduit.shielding_words.enabled then applyBuff( "shielding_words" ) end
        end,
    },
} )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "spectral_strength",

    package = "Retribution",
} )


spec:RegisterSetting( "check_wake_range", false, {
    name = "Check |T1112939:0|t Wake of Ashes Range",
    desc = "If checked, when your target is outside of |T1112939:0|t Wake of Ashes' range, it will not be recommended.",
    type = "toggle",
    width = 1.5
} )


spec:RegisterPack( "Retribution", 20230123, [[Hekili:T3tYsUnoY(TuXlmTKB)KfPkzxUJs6W0X7q7yI(WuZzjXsIsIJPe1qsz7QJk03(dGlGyjtaWfvDptxx8IqYe5EMiba5c3f)ZfpSXplyXV5n2BYyxVjJCP)1hx8q2tNcw8Wj)1F1Fh5FC0)a5p)hbzjHpEolm(iDSNII93qXrA85K1KXx8WJNdJY(1JlEegXtjWEky9IF7tJx8W(WnBckaniDn9PpLeVnmIGi)105iD0PKG1XhE0p7NM9b)K1(hdwMfNKeCm79HBNL5hr(xJ2gE0pAjbYVgFm84oNYFoniX)0(Wdx(ce2s3hgeTzz82LFl44Ua)JRdGb8B(jH(pgf8EQiygH)p(1GSLUlF882TPV)B(rNz)6i3r79tZhzuAgHk3LT)5Nbg8GFAwqYtGJ9TGKu)SWOWm4X3tFwWrwNeM1eEWdKh80XdEA4bpd8Ghkp41EEWDz6thx)(4tZsdYc3wYlUf)9YGO0GzJhn99RJpUjKIZzvOzKKM0zqTeDDCC0M4VFC0MZj(0N6nVH9tRtoN6VjGn0SXp)m6GV5nAqk9jTBo9PMOel7LFNm0E4PgbgduWWMiR96SS2tww7DnK1aiLxwRFo7fznif0iz9PKWyIRWtYsBpEPTlNS(gudBmTWZpJRF0QGQhJeVE9i)JpTCZPu24dF3a3rt)jnXtiqam1uJRHdNpqRJy9y2m3aXJHMB3Y5(YxU8L)NlR()(rW6ZzbBUSkGei7PlRYcpeq(Z9K)GObJtUSkmL8p)MFyuoEykwI6mj4XZFnG)xw7hfTS4)UmkmnRqrxXAPMbniD52KLNipaXMJM3BWnj(HBwsOosAo)nBshf8dc0enQ8VF(K6VfE8(pd9RZNmEiXZSi5zqUmGshPK)Baj7OdtzOo2OKGd(HhtV)ZoK07eEiZpzxqgrVe(Tqso7uIq7W9tj(GWzSzOwAGA8sOSBktqu42t5mHFinJuRYmxcpSnC3(SLLp687Svat)5VfqLVBcYXmaFsN1YrLj1ZNmpr7coskkHimsPMAvrdyMcZoft)fkjKpfsXzuy5ZNCafbp)SGi4EVPatgHiJOqLU8FDEZUdLLujQ(Kay(mVNF2ABpIf1NMczsctmBdjUorXXBYTW7e)p05guZy4j)CAWYWSGdfQj)ic3V3N4ZD(3)9OGLpg)JCIclbqLCEkBElPiG0v1WkckXaFFC0te38VhKmFgzysqhQld)Voj)xNpDObUinkoRkvIBFiphCJy48QzfmRAjlcKFPkR2m3H81(agkF(mbJ4gWXE9lh7IWXUnIJ9gYlR6zooxhJxbau2CgjR(yS6dKJ46Gznp3BCf0ksChdEnKNTjMZEWSQsLLqAhuj0FAy10EW0fEgawVBrPeOrk5cEPjJ)up5eUUizBezO8jxiK3T6d5XkEiF0CKfKulX5)1kIBwHFSy7aiAp4Qq443kyzkomPAPWNYm2h9ggv8mqEZniWUmlE5(t7Mn2Pgp3pZZb1crmNIZamRy6YzKSMgQu1agtlj3Y1KakY7a5(z3n0XuI057wVbp1PDvcoN6kqRNTwmoFmpfnBkOXrXIfQ0)eXItxR2E(TJzvVcOY4PioMEV)Hdbju)vbrZq(ch5RBDgR(j4XrRjLOndt3hKKkAetjMYkDRk)tF1VodqgQYEIOuhDW)hp)m(seifyQP0THSzhSYCh8bLibujujTKfhfjknioDOp039)Aavp5tKIPkpgQyPMG1iWExT8OK2scsJp6NhEU7cd96cwjQYtTdUkcvk9yeX1KkM(xNtZcls(WqZPZj7YlbQ2Juzo5LQt4DBicz8PLFTn3OAp7WhHcxfBWZPLMgnswjW(TLDrFoPOn4cIIqSjetKKqU2CidNyV6rbl4hXjRdtpqj3IFCjzfYhcdsN5sJfEmnyDrTX6iEE4udpw23eAjqLr1Ld0vB0HxraMp6mQt6eZaoV06PcoUCpTTYlLPghw5zhRrmk(r1cV2M8qnSNn1XEV7yCsrYyLlsY38pU7SFYM0LhIPM8NpGJfdHTlXy(O06h2qCfXRNcV5W15TXiKg7Tx)On0DhveQrTl6WtNizzq1yJwVNMgHIGcS5hrkcB0NMY3zJ7PTqsG7QlHxwqWxo47eEmsjMw(u1WXKlcJRrVWhUajabNbX1XrT9oKwRsXbuDdx5vC3I)GDkSoSc41q0weIgjpiZM4NK3TjsGY1(KaU0FOy)L0wBEzK7GdNEkjW)yHLanaouLvfl4PedKc8ofNcSwnSO)oIZuuWo)1pLJ2sXsH3UFsk0(3ZZXcwrMw4P7u81DsgCyhkvO)nVunz0wnFtwjB(Qwb36O8vnOUWxYAZEmonvSvq37ovQ3qtTu9dRkvff1TlRcdubbEZ7CL77rzVcMymb(C3XDs7tF8cfZOQwsSjmy(DodSAhZySorsuqydHLrj(Bc9pMTCdjsqqJLpY6h7fpDZ3ykc3WlnO8cRbUCrUQ6TIAWcln2iu(aR34M8YgM0doVu88r7b9wHLQEl1Wq2yI2XnTraQB9zvqrB2u3YcL6I6vMx1bhaJIqYkDPTCAWzsDZRxB6W89Lj4ZTReaWERpylFG8BfTm))wSuF1u8pFMIoyrsHTrZiagvyIMSjCDMqH6VAF(Q9zpBFYVOM6JsZSg3AQbqBSbF3fg6WV4fwpORPuj6hISYxS1X)95cIyzrhxY7LqY5JbBJj2CJ2Co7PhJpFCZYDeKfHU1KA2ue5DT7oeAbVPz)EGFuCw6Yt(j(7ORCe857w7YGlAep2WqeQq3g0aUkul2HpoQqXnXTPRAAcWQMOBIiAdKAGM1867mvKUHL3cUgU7W0fTCRv0BvX1QWzJL2LhB75xdvzEiQmathCdLP9qEm3PTQQ(oLUHoNY6BJ2rn3VTrHOPNvalZhaozTS9JnX42UGSiq1Gg(3uH4Gs7N9Ky6e91P1ze)MQEEy(efH1Gpu1kNSmxsjjC1CAGXJji1F6)BElhAI6TLQa7eYiqHTnUOuWIhOx9h6)GEXV8C98MS4HV7NqJ5KU4H)j9i0hE4uCs2LvBPhK(3wJQ3EzvsaPEPe6jVpnMEK79pNfFWp)O4t00KITshD5l)DIn0LvE)8Lv)s8rY0Lp8BrlQIG2SyDamk4iTnsBiaoW9hdrNb4ySvOhE0gIB1KdsOhi7bYmmbEgKk2tc9sJIH7BHXTqXFsywymm8ofgVvjBLqjlhCZWwVO)qWDpQ)(uVklqW21NE7O0(YxaczSjyR)5OSMfVaXFOhLaiZW1qcWU)yntg4EvOqT4UL2RkYs8l0fdZLGKbdtpJE6b2McxlWC5fNvhDxds)I8oq1CxPxDuUiy9)K0boi)shRJ2RaOprChOx6vHwh5woEpIwmIvjFp76Ky2DbgMEg9DGWXCyabPFrEhOADokOG1)tsh4ayNgaa6te3b6f0TrD8EeTyeRsTNmFC2cpRUrza(5qWCvr)vdXVs3)LGUJpfuarkPk4JeSy(AocH)U)ALacR8VxjmmRsDFRDVyjGPHHvc4wkAAPKPtcgt8SvYftIfMn1hrJeB2yfggbFH(g9xne)kD)xc62CmtL7lne(7HyMgEx8yyw7sSbd0aEmt7enTuY0jbJjE2k5IjXcZMsPJED0yvYxOVrVfig8TUaaYXGZs632PHAMTS5O32ffRDn3Dh9ylpbdZTTUWRm6TaX2PpXHZs632PPvMn23zZwz2yp6T0Srjd2v69BgyCwmFuP3Uysocw(wndSAym1R8m6ACgRExMvj(FbLBF4fxU9HRGCBu5oUSnokk(7KeO0TujXNyh(9GeYVtqYMcBYQxiCK57Yk6o2Fz1JNZQG7yC(21C(Oa0B2qbEJFM)J(Pb)8LVCz1)7LvfV1lb3QNkEUHBp(1F7Uq2e4YkEKqBvDqVa4cRVeIV4QqsQXnSLiLztwEgp0vRsnixrKBeT2NPXQeADFA0MqdBjtU6vNkdBjsnkXbb5kICJO1(6nTsD29PPv1N0oB9RkYzO9UEvHkrZ9lYzO1D8vpbGlYw(ZF24LqUWXMVHOTLNKam01ph6bK0STkXLlswWgZ4G1rWohHVTr1rGi9aUDAsKhaen8WW1lAO)WoOD9c1BQko2LbgJ6za0WkV6fQh5qY1kNJR)bU7)4p8H9lL2VyRJ5eukkPdwsi4QhTKqMHwkrrWwVyj9IqP9l26OLeYXuTvws)HDOABPe96CeDFbP0(fBT2scS(k(3jDVTrLyD9lrbjjV81Bvc)k3(1)mH9Eu6GwAb7TsPcQzJ0qC2zzIgtVY3dunZ27QU4ORUM7As9iLER(gguc9Qa0ql7oFlA(8vuQGTg1RkY7tlMRd9F5l)AUhjfLFsCpbO(AlEi)Fr)sPvFD3i)VFl)dWwj2w83w8aDFacsc9x8q9fp8YQzK4jxw98ZKP7YkG7IA(qspWTxwn8Ykh6osSf8fzqXtLpQ0lZGQV(AeYr6gjwWhll(wWXAOWISf)MhkJCdjEKPBExbTqGuV8oNFQHcxRxGpXpMcRU)YQ7Qzn1xndu2yckBuoNixqUA8kDdGPi9wRuY3tuAE5COoF9CaiwbSg)bFbTleamGKUK2etJAcw4g4tj3PnKCVb2MSGoR1wYfPXz)XgQYQKr4YxZ(lRMt8HNwzBxmbWx1)cmPED)ZrXKXWdtjGHsMz6mgh0r7XIbWVK0eITW5FO1k(sbKE9phq034d5ihK84mu4E1Bqnt(OopEedcEdikJ5vJ9kqPO(tOOEGsCUXQr)QnnzcaSlSDUKyx5lf(vVl)56OPLNrtllCl07amfetMm)y4eaqidd13efT1M1cFjbcugkiQd2A1AVK2hE8oRcpsfbtQZ)w)gwq93YFzwKZbUJBtQ3pJsqIV7lYDxCRyDH3ra1tB1RodkIjKtJCXHDMDZRXbl9ih6PWIxgHSd(KACk7CNJj8m5dyM21VKmkdAmMlPKYlldUX4vNSFu5LMHGDK96tx86fUrrZLBozYxKlmRW7Qb6KHNTx29qZ7CJIPH(E3OYbeiEmuy6jTpmnCnVTfB8pN8BTdWKeCIurXtUuvo5ylScWtcQAfOr)EhV3NmPk599zEyfF1FibQ3yb0k8caHhWm6N258lRp0QDOF1Ntcpv8yn(JUz98x8j3eAziwj3Ru8P6xbqZRiOk8auLcKW9F2yjQS8zwKI3XYm8ftSHOg3ZwXPPe3o2K3Uyo5RhapmQuArACfMKqkP)CHv0Pvhl0Im9lkt3xvNc6e9lBrJiMISZqR4YkKW1iHC)m2Rec99vWc9jsLPOHgQ87Qgg4lnNu4dzNSyIKlniJF15fNot6)k6m5VYGpiNL2OVOdMtDLkHsqQosTqgwnG380reVidcXBE18MSHAjVfUfM7uLs0JylV1i2ztMf3d4OovDYYUS6na1WxpA9Id1a0Bmnh1yXEAb5M3assOWAjLnS0mk)dc(IhgpAkZUYfAz6nuL5zwL5HOYaoG49UkdCoauzgPLExLPHYmPYKR8RHQSQV4SsLmQ1vdxPs5CtQCJA9piaa9zxwp4W8AQhqx)aPMJFstGlgKixxGCigMxxWalcF8bbaSMQKtvGtvUCuLOo3LPX9kYExxdQ2S3nALPinAOSIk4MO4nT2iR4Jrouz11eK2px4LR(SyUAyTZLvb)PPyLwxtNsZQXQ47rHOCVIXlqVMCzFNoHQwGvIL6xGCjUWylUkQHxG8KopliHAvXa2JpeA5(LD)ZPAfC1RLaUbzfqv2wZfpuemdI)1uPCPhN71wtx2mtXauvcq8CocTDujmrva7Qg0nuPEdPytuzNGRlXpmkoJtmaK4xsu59clQC1jQupi72iQ8ufvkjxmjQ8Gs4QZQYuMuKCHcSfeoes4cTazhd7NtvZlVbxx6yruJsmneYKsU136mP0YJ4f3Buo5(NB5uU9eEh57zhTAva77h)c9nUV)3XiA4Dp8g04ovFJby7qag5cKD522MDPmArb3dDg)e19cqWyQYI45dYPBR8A6MFbUJFIkBrRNf2VXjTp1SspKxOFtw4(QRxjXCW2LwdofyfF4iUtFk(61RCtXTAiA5VIcAEdGf63AgZMP3zHKEwd3gt(nMqFTConUZRZRtNx3hAE16CWDFFg2E)A7baPT7)UUUTti1BLCA1zYbF4RQJla)P5xW0rYzVyvE17WdWQ8m3OqJ7ZhNify3iD0DwDQKikFVoBwMP7lSzCKPI6pKuLtwPrHMBjgFVn4(A)PF9Ow60y9jK5QCggkBPFDXWxXtZHYCrFytgsD)awDlYPGPCRVecAHCszYn7WpCsUtrQ4yAlSy5QrPmuKDDrG1DYCrRPspDHYhXfTDIKQvNbmCjiD32SgXqN)N555NkM1gT)H4xirHOMQgZ63RU2PhGSqANA4AfHyQGur8t6kuFqaAppxit5SEqrLBSldhNpOd9ys6Ovm5QgmKFM(y7F0BvkMTSCVcd(oES5OGPRQjN2r0ExjtvDYuBFodculeeGRAcG0SvWAlL71xRQ8Ef)aMhP0XZVD(Q1rt4n6GAuO8QVF112oxBBnTAa18QpBteS2s5)hJpBoa4jTRDPbwffuFTrAd4RU1V6wBRKYcbXRU16CR521ePpE2fTis4Sbw1Li1Tow880zx3FRlVe7oeIEWgRSwraau0rrOPYDz3GmlcBmuGgroEMo6aaGmxy3HTu4OzJ3waL(BRu1v1TNQP3jqCzVixBLM5DQcESBE(1qMBNPHWjpaN8CSZ2Pwr0G77idXkx3F1O3APqzDAzifavnhHcDTwEbV0Dn3VWUBgLKFHI6aFZtvKI6Lv)rD9LK2OmSlBXeEy1Ezl0SRtf5jA)n8AQabR7ACiEa6B4vxVNl1HQ8bYqB(bN)c27DtezB6BVjX3q4(y3YYdGY00H6DSpqIXBHp(7ydCx1wK0TC2S7I4RSojbTnwpKBxIPggjSHzn0KFWU4G4jcKLwVENc5x9cEUdT5fTiUQKT6lzClKyskzNBEycXuZgs3AxmqkZFlAA5mTh5LUMlw7UCzHo2UuGMuVVM7uYo16sKONCJZz7Jtw8WdHh(L8FzX))d]] )
