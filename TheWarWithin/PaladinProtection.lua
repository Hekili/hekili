-- PaladinProtection.lua
-- July 2024

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local FindUnitBuffByID = ns.FindUnitBuffByID

local spec = Hekili:NewSpecialization( 66 )

local strformat = string.format

local GetSpellInfo = ns.GetUnpackedSpellInfo

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Paladin
    afterimage                      = { 93188, 385414, 1 }, -- After you spend 20 Holy Power, your next Word of Glory echoes onto a nearby ally at 30% effectiveness.
    auras_of_the_resolute           = { 81599, 385633, 1 }, -- Learn Concentration Aura and Devotion Aura: Concentration Aura: Interrupt and Silence effects on party and raid members within 40 yds are 30% shorter.  Devotion Aura: Party and raid members within 40 yds are bolstered by their devotion, reducing damage taken by 3%.
    avenging_wrath                  = { 81606, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, allowing Hammer of Wrath to be used on any target, increasing your damage and healing by 20% for 20 sec.
    blessing_of_freedom             = { 81600, 1044  , 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    blessing_of_protection          = { 81616, 1022  , 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Spellwarding.
    blessing_of_sacrifice           = { 81614, 6940  , 1 }, -- Blesses a party or raid member, reducing their damage taken by 30%, but you suffer 100% of damage prevented. Last 12 sec, or until transferred damage would cause you to fall below 20% health.
    blinding_light                  = { 81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within 10 yds, causing them to wander disoriented for 6 sec.
    cavalier                        = { 81605, 230332, 1 }, -- Divine Steed now has 2 charges.
    cleanse_toxins                  = { 81507, 213644, 1 }, -- Cleanses a friendly target, removing all Poison and Disease effects.
    crusader_aura                   = { 81601, 32223 , 1 }, -- Increases mounted speed by 20% for all party and raid members within 40 yds.
    divine_purpose                  = { 93192, 223817, 1 }, -- Holy Power abilities have a 15% chance to make your next Holy Power ability free and deal 15% increased damage and healing.
    divine_resonance                = { 81479, 386738, 1 }, -- After casting Divine Toll, you instantly cast Avenger's Shield every 5 sec for 15 sec.
    divine_steed                    = { 81632, 190784, 1 }, -- Leap atop your Charger for 3 sec, increasing movement speed by 100%. Usable while indoors or in combat.
    divine_toll                     = { 81496, 375576, 1 }, -- Instantly cast Avenger's Shield on up to 5 targets within 30 yds. After casting Divine Toll, you instantly cast Avenger's Shield every 5 sec. This effect lasts 15 sec. Generates 1 Holy Power per target hit.
    fading_light                    = { 81623, 405768, 1 }, -- Blessing of Dawn: Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional 10%. Blessing of Dusk: Blessing of Dusk causes your Holy Power generating abilities to also grant an absorb shield for 20% of damage or healing dealt.
    faiths_armor                    = { 81495, 406101, 1 }, -- Shield of the Righteous grants 5% bonus armor for 4.5 sec.
    fist_of_justice                 = { 81602, 234299, 2 }, -- Each Holy Power spent reduces the remaining cooldown on Hammer of Justice by 1 sec.
    golden_path                     = { 81610, 377128, 1 }, -- Consecration heals you and 5 allies within it for 902 every 0.7 sec.
    greater_judgment                = { 81603, 231663, 1 }, -- Judgment causes the target to take 40% increased damage from your next Holy Power ability. Multiple applications may overlap.
    hammer_of_wrath                 = { 81510, 24275 , 1 }, -- Hurls a divine hammer that strikes an enemy for 47,636 Holy damage. Only usable on enemies that have less than 20% health, or during Avenging Wrath. Generates 1 Holy Power.
    holy_aegis                      = { 81609, 385515, 2 }, -- Armor and critical strike chance increased by 2%.
    improved_blessing_of_protection = { 81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection and Blessing of Spellwarding by 60 sec.
    incandescence                   = { 81628, 385464, 1 }, -- Each Holy Power you spend has a 5% chance to cause your Consecration to flare up, dealing 7,127 Holy damage to up to 5 enemies standing within it.
    judgment_of_light               = { 81608, 183778, 1 }, -- Judgment causes the next 5 successful attacks against the target to heal the attacker for 3,499.
    justification                   = { 81509, 377043, 1 }, -- Judgment's damage is increased by 10%.
    lay_on_hands                    = { 81597, 633   , 1 }, -- Heals a friendly target for an amount equal to 100% your maximum health. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    lightforged_blessing            = { 93168, 406468, 1 }, -- Shield of the Righteous heals you and up to 2 nearby allies for 1% of maximum health.
    obduracy                        = { 81630, 385427, 1 }, -- Speed increased by 2% and damage taken from area of effect attacks reduced by 2%.
    of_dusk_and_dawn                = { 93356, 409441, 1 }, -- When you cast 3 Holy Power generating abilities, you gain Blessing of Dawn. When you consume Blessing of Dawn, you gain Blessing of Dusk. Blessing of Dawn Your next Holy Power spending ability deals 30% additional increased damage and healing. This effect stacks. Blessing of Dusk Damage taken reduced by 5%, armor increased by 10%, and Holy Power generating abilities cool down 10% faster For 10 sec.
    punishment                      = { 93165, 403530, 1 }, -- Successfully interrupting an enemy with Rebuke or Avenger's Shield casts an extra Blessed Hammer.
    quickened_invocation            = { 81479, 379391, 1 }, -- Divine Toll's cooldown is reduced by 15 sec.
    rebuke                          = { 81604, 96231 , 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for 3 sec.
    recompense                      = { 81607, 384914, 1 }, -- After your Blessing of Sacrifice ends, 50% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing. This effect's bonus damage cannot exceed 30% of your maximum health and its bonus healing cannot exceed 100% of your maximum health.
    repentance                      = { 81598, 20066 , 1 }, -- Forces an enemy target to meditate, incapacitating them for 1 min. Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    sacrifice_of_the_just           = { 81607, 384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by 60 sec.
    sanctified_plates               = { 93009, 402964, 2 }, -- Armor increased by 5%, Stamina increased by 5% and damage taken from area of effect attacks reduced by 3%.
    seal_of_alacrity                = { 81619, 385425, 2 }, -- Haste increased by 2% and Judgment cooldown reduced by 0.5 sec.
    seal_of_mercy                   = { 81611, 384897, 1 }, -- Golden Path strikes the lowest health ally within it an additional time for 100% of its effect.
    seal_of_might                   = { 81621, 385450, 2 }, -- Mastery increased by 2% and strength increased by 2%.
    seal_of_order                   = { 81623, 385129, 1 }, -- Blessing of Dawn: Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional 10%. Blessing of Dusk: Blessing of Dusk increases your armor by 10% and your Holy Power generating abilities cooldown 10% faster.
    seal_of_the_crusader            = { 93684, 385728, 2 }, -- Your auto attacks deal 1,979 additional Holy damage.
    seasoned_warhorse               = { 81631, 376996, 1 }, -- Increases the duration of Divine Steed by 2 sec.
    strength_of_conviction          = { 81480, 379008, 2 }, -- While in your Consecration, your Shield of the Righteous and Word of Glory have 10% increased initial damage and healing.
    touch_of_light                  = { 81543, 385349, 1 }, -- Your spells and abilities have a chance to cause your target to erupt in a blinding light dealing 5,939 Holy damage or healing an ally for 8,116 health.
    turn_evil                       = { 93010, 10326 , 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to 40 sec. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbound_freedom                 = { 93187, 305394, 1 }, -- Blessing of Freedom increases movement speed by 30%, and you gain Blessing of Freedom when cast on a friendly target.
    unbreakable_spirit              = { 81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, Ardent Defender, and Lay on Hands by 30%.
    zealots_paragon                 = { 81625, 391142, 1 }, -- Hammer of Wrath and Judgment deal 10% additional damage and extend the duration of Sentinel by 0.5 sec.

    -- Protection
    ardent_defender                 = { 81481, 31850 , 1 }, -- Reduces all damage you take by 20% for 8 sec. While Ardent Defender is active, the next attack that would otherwise kill you will instead bring you to 20% of your maximum health.
    avengers_shield                 = { 81502, 31935 , 1 }, -- Hurls your shield at an enemy target, dealing 14,918 Holy damage, interrupting and silencing the non-Player target for 3 sec, and then jumping to 2 additional nearby enemies. Shields you for 8 sec, absorbing 50% as much damage as it dealt. Deals 1,592 additional damage to all enemies within 5 yds of each target hit.
    avenging_wrath_might            = { 81483, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, allowing Hammer of Wrath to be used on any target, increasing your damage and healing by 20% for 20 sec.
    barricade_of_faith              = { 81501, 385726, 1 }, -- When you use Avenger's Shield, your block chance is increased by 10% for 10 sec.
    bastion_of_light                = { 81488, 378974, 1 }, -- Your next 5 casts of Judgment generate 2 additional Holy Power.
    blessed_hammer                  = { 81469, 204019, 1 }, -- Throws a Blessed Hammer that spirals outward, dealing 3,217 Holy damage to enemies and reducing the next damage they deal to you by 5,411. Generates 1 Holy Power.
    blessing_of_spellwarding        = { 90062, 204018, 1 }, -- Blesses a party or raid member, granting immunity to magical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Protection.
    bulwark_of_order                = { 81499, 209389, 1 }, -- Avenger's Shield also shields you for 8 sec, absorbing 50% as much damage as it dealt, up to 50% of your maximum health.
    bulwark_of_righteous_fury       = { 81491, 386653, 1 }, -- Avenger's Shield increases the damage of your next Shield of the Righteous by 20% for each target hit by Avenger's Shield, stacking up to 5 times, and increases its radius by 6 yds.
    consecrated_ground              = { 81492, 204054, 1 }, -- Your Consecration is 15% larger, and enemies within it have 50% reduced movement speed.
    consecration_in_flame           = { 81470, 379022, 1 }, -- Consecration lasts 2 sec longer and its damage is increased by 20%.
    crusaders_judgment              = { 81473, 204023, 1 }, -- Judgment now has 2 charges, and Grand Crusader now also reduces the cooldown of Judgment by 3 sec.
    crusaders_resolve               = { 81493, 380188, 1 }, -- Enemies hit by Avenger's Shield deal 10% reduced melee damage to you for 10 sec.
    eye_of_tyr                      = { 81497, 387174, 1 }, -- Releases a blinding flash from your shield, causing 12,756 Holy damage to all nearby enemies within 8 yds and reducing all damage they deal to you by 25% for 9 sec.
    faith_in_the_light              = { 81485, 379043, 2 }, -- Casting Word of Glory grants you an additional 5% block chance for 5 sec.
    ferren_marcuss_fervor           = { 81482, 378762, 2 }, -- Avenger's Shield deals 10% increased damage to its primary target.
    final_stand                     = { 81504, 204077, 1 }, -- During Divine Shield, all targets within 15 yds are taunted.
    focused_enmity                  = { 81472, 378845, 1 }, -- When Avenger's Shield strikes a single enemy, it deals 100% additional Holy damage.
    gift_of_the_golden_valkyr       = { 81484, 378279, 2 }, -- Each enemy hit by Avenger's Shield reduces the remaining cooldown on Guardian of Ancient Kings by 0.5 sec. When you drop below 30% health, you become infused with Guardian of Ancient Kings for 4 sec. This cannot occur again for 45 sec.
    grand_crusader                  = { 81487, 85043 , 1 }, -- When you avoid a melee attack or use Blessed Hammer, you have a 15% chance to reset the remaining cooldown on Avenger's Shield.
    guardian_of_ancient_kings       = { 81490, 86659 , 1 }, -- Empowers you with the spirit of ancient kings, reducing all damage you take by 50% for 8 sec.
    hammer_of_the_righteous         = { 81469, 53595 , 1 }, -- Hammers the current target for 19,303 Physical damage. While you are standing in your Consecration, Hammer of the Righteous also causes a wave of light that hits all other targets within 8 yds for 2,684 Holy damage. Generates 1 Holy Power.
    hand_of_the_protector           = { 81475, 315924, 1 }, -- When you cast Word of Glory on someone other than yourself, its healing is increased by up to 100% based on the target's missing health.
    holy_shield                     = { 81489, 152261, 1 }, -- Your block chance is increased by 20%, you are able to block spells, and your successful blocks deal 2,211 Holy damage to your attacker.
    improved_ardent_defender        = { 90062, 393114, 1 }, -- Ardent Defender reduces damage taken by an additional 10%.
    improved_holy_shield            = { 81486, 393030, 1 }, -- Your chance to block spells is increased by 10%.
    inmost_light                    = { 92953, 405757, 1 }, -- Eye of Tyr deals 300% increased damage and has 25% reduced cooldown.
    inner_light                     = { 81494, 386568, 1 }, -- When Shield of the Righteous expires, gain 10% block chance and deal 4,499 Holy damage to all attackers for 4 sec.
    inspiring_vanguard              = { 81476, 393022, 1 }, --
    light_of_the_titans             = { 81503, 378405, 1 }, -- Word of Glory heals for an additional 20% over 15 sec. Increased by 100% if cast on yourself while you are afflicted by a harmful damage over time effect.
    moment_of_glory                 = { 81505, 327193, 1 }, -- For the next 15 sec, you generate an absorb shield for 25% of all damage you deal, and Avenger's Shield damage is increased by 20% and its cooldown is reduced by 75%.
    redoubt                         = { 81494, 280373, 1 }, -- Shield of the Righteous increases your Strength and Stamina by 2% for 10 sec, stacking up to 3.
    relentless_inquisitor           = { 81506, 383388, 1 }, -- Spending Holy Power grants you 1% haste per finisher for 12 sec, stacking up to 3 times.
    resolute_defender               = { 81471, 385422, 2 }, -- Each 3 Holy Power you spend reduces the cooldown of Ardent Defender and Divine Shield by 1.0 sec.
    righteous_protector             = { 81477, 204074, 1 }, -- Holy Power abilities reduce the remaining cooldown on Avenging Wrath and Guardian of Ancient Kings by 2.0 sec.
    sanctified_wrath                = { 81620, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, allowing Hammer of Wrath to be used on any target, increasing your damage and healing by 20% for 20 sec.
    sanctuary                       = { 101927, 379021, 1 }, -- Consecration's benefits persist for 4.0 seconds after you leave it.
    seal_of_charity                 = { 81612, 384815, 1 }, -- When you cast Word of Glory on someone other than yourself, you are also healed for 50% of the amount healed.
    seal_of_reprisal                = { 81629, 377053, 1 }, -- Your Blessed Hammer deals 20% increased damage.
    sentinel                        = { 81483, 389539, 1 }, -- Call upon the Light and gain 15 stacks of Divine Resolve, increasing your maximum health by 1% and reducing your damage taken by 2% per stack for 20 sec. After 5 sec, you will begin to lose 1 stack per second, but each 3 Holy Power spent will delay the loss of your next stack by 1 sec. While active, your damage and healing is increased by 20%, and Hammer of Wrath may be cast on any target. Combines with Avenging Wrath.
    shining_light                   = { 81498, 321136, 1 }, -- Every 3 Shields of the Righteous make your next Word of Glory cost no Holy Power. Maximum 2 stacks.
    soaring_shield                  = { 101928, 378457, 1 }, -- Avenger's Shield jumps to 2 additional targets.
    strength_in_adversity           = { 81493, 393071, 1 }, -- For each target hit by Avenger's Shield, gain 5% parry for 15 sec.
    tirions_devotion                = { 81503, 392928, 1 }, -- Lay on Hands' cooldown is reduced by 1.0 sec per Holy Power spent.
    tyrs_enforcer                   = { 81474, 378285, 2 }, -- Your Avenger's Shield is imbued with holy fire, causing it to deal 1,592 Holy damage to all enemies within 5 yards of each target hit.
    uthers_counsel                  = { 81500, 378425, 2 }, -- Your Lay on Hands, Divine Shield, Blessing of Protection, and Blessing of Spellwarding have 20% reduced cooldown.

    -- Lightsmith
    blessed_assurance               = { 95235, 433015, 1 }, -- Casting a Holy Power Spender increases the damage and healing of your next Blessed Hammer by 100%.
    blessing_of_the_forge           = { 95230, 433011, 1 }, -- Avenging Wrath summons an additional  Sacred Weapon, and during Avenging Wrath your Sacred Weapon casts spells on your target and echoes the effects of your Holy Power abilities.
    divine_guidance                 = { 95235, 433106, 1 }, -- For each Holy Power ability cast, your next Consecration deals 39,596 damage or healing immediately, split across all enemies and allies.
    divine_inspiration              = { 95231, 432964, 1 }, -- Your spells and abilities have a chance to manifest a Holy Armament for a nearby ally.
    excoriation                     = { 95232, 433896, 1 }, -- Enemies within 8 yards of Hammer of Justice's target are slowed by 15% for 5 sec.
    fear_no_evil                    = { 95232, 432834, 1 }, -- While wielding an Armament the duration of Fear effects is reduced by 50%.
    forewarning                     = { 95231, 432804, 1 }, -- The cooldown of Holy Armaments is reduced by 20%.
    hammer_and_anvil                = { 95238, 433718, 1 }, -- Judgment critical strikes cause a shockwave around the target, dealing 29,697 damage at the target's location.
    holy_armaments                  = { 95234, 432459, 1, "lightsmith" }, -- Will the Light to coalesce and become manifest as a Holy Armament, wielded by your friendly target.  Holy Bulwark: While wielding a Holy Bulwark, gain an absorb shield for 15.0% of your max health and an additional 2.0% every 2 sec. Lasts 20 sec. Becomes Sacred Weapon after use.
    laying_down_arms                = { 95236, 432866, 1 }, -- When an Armament fades from you, the cooldown of Lay on Hands is reduced by 15.0 sec and you gain Shining Light.
    rite_of_adjuration              = { 95233, 433583, 1 }, -- Imbue your weapon with the power of the Light, increasing your Stamina by 3% and causing your Holy Power abilities to sometimes unleash a burst of healing around a target. Lasts 1 |4hour:hrs;.
    rite_of_sanctification          = { 95233, 433568, 1 }, -- Imbue your weapon with the power of the Light, increasing your armor by 5% and your primary stat by 1%. Lasts 1 |4hour:hrs;.
    shared_resolve                  = { 95237, 432821, 1 }, -- The effect of your active Aura is increased by 33% on targets with your Armaments.
    solidarity                      = { 95228, 432802, 1 }, -- If you bestow an Armament upon an ally, you also gain its benefits. If you bestow an Armament upon yourself, a nearby ally also gains its benefits.
    valiance                        = { 95229, 432919, 1 }, -- Consuming Shining Light reduces the cooldown of Holy Armaments by 3.0 sec.

    -- Templar
    bonds_of_fellowship             = { 95181, 432992, 1 }, -- You receive 20% less damage from Blessing of Sacrifice and each time its target takes damage, you gain 4% movement speed up to a maximum of 40%.
    endless_wrath                   = { 95185, 432615, 1 }, -- Calling down an Empyrean Hammer has a 10% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    for_whom_the_bell_tolls         = { 95183, 432929, 1 }, -- Divine Toll grants up to 100% increased damage to your next 3 Judgment when striking only 1 enemy. This amount is reduced by 20% for each additional target struck.
    hammerfall                      = { 95184, 432463, 1 }, -- Shield of the Righteous and Word of Glory calls down an Empyrean Hammer on a nearby enemy. While Shake the Heavens is active, this effect calls down an additional Empyrean Hammer.
    higher_calling                  = { 95178, 431687, 1 }, -- Crusader Strike, Hammer of Wrath and Judgment extend the duration of Shake the Heavens by 1 sec.
    lights_deliverance              = { 95182, 425518, 1 }, -- You gain a stack of Light's Deliverance when you call down an Empyrean Hammer. While Eye of Tyr and Hammer of Light are unavailable, you consume 60 stacks of Light's Deliverance, empowering yourself to cast Hammer of Light an additional time for free.
    lights_guidance                 = { 95180, 427445, 1, "templar" }, -- Eye of Tyr is replaced with Hammer of Light for 12 sec after it is cast.  Hammer of Light: Hammer down your enemy with the power of the Light, dealing 114,956 Holy damage and 57,478 Holy damage up to 4 nearby enemies. Additionally, calls down Empyrean Hammers from the sky to strike 3 nearby enemies for 9,701 Holy damage each. Costs 5 Holy Power.
    sacrosanct_crusade              = { 95179, 431730, 1 }, -- Eye of Tyr surrounds you with a Holy barrier for 15% of your maximum health. Hammer of Light heals you for 15% of your maximum health, increased by 2% for each additional target hit. Any overhealing done with this effect gets converted into a Holy barrier instead.
    sanctification                  = { 95185, 432977, 1 }, -- Casting Judgment increases the damage of Empyrean Hammer by 10% for 10 sec. Multiple applications may overlap.
    shake_the_heavens               = { 95187, 431533, 1 }, -- After casting Hammer of Light, you call down an Empyrean Hammer on a nearby target every 2 sec, for 8 sec.
    undisputed_ruling               = { 95186, 432626, 1 }, -- Hammer of Light applies Judgment to its targets, and increases your Haste by 15% for 6 sec. Additionally, Eye of Tyr grants 3 Holy Power.
    unrelenting_charger             = { 95181, 432990, 1 }, -- Divine Steed lasts 2 sec longer and increases your movement speed by an additional 30% for the first 3 sec.
    wrathful_descent                = { 95177, 431551, 1 }, -- When Empyrean Hammer critically strikes, 60% of its damage is dealt to nearby enemies. Enemies hit by this effect deal 5% reduced damage to you for 8 sec.
    zealous_vindication             = { 95183, 431463, 1 }, -- Hammer of Light instantly calls down 2 Empyrean Hammers on your target when it is cast.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning               = 5554, -- (247675) When you or allies within your Aura are critically struck, gain Reckoning. Gain 1 additional stack if you are the victim. At 100 stacks of Reckoning, your next weapon swing deals 200% increased damage, will critically strike, and activates Avenging Wrath for 6 sec.
    guarded_by_the_light            = 97  , -- (216855) Your Flash of Light reduces all damage the target receives by 10% for 6 sec. Stacks up to 2 times.
    guardian_of_the_forgotten_queen = 94  , -- (228049) Empowers the friendly target with the spirit of the forgotten queen, causing the target to be immune to all damage for 10 sec.
    hallowed_ground                 = 90  , -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    inquisition                     = 844 , -- (207028)
    luminescence                    = 3474, -- (199428) When healed by an ally, allies within your Aura gain 2% increased damage and healing for 6 sec.
    sacred_duty                     = 92  , -- (216853) Reduces the cooldown of your Blessing of Protection and Blessing of Sacrifice by 33%.
    searing_glare                   = 5582, -- (410126) Call upon the light to blind your enemies in a 25 yd cone, causing enemies to miss their spells and attacks for 4 sec.
    shield_of_virtue                = 861 , -- (215652) When activated, your next Avenger's Shield will interrupt and silence all enemies within 8 yds of the target.
    steed_of_glory                  = 91  , -- (199542) Your Divine Steed lasts for an additional 2 sec. While active you become immune to movement impairing effects, and you knock back enemies that you move through.
    warrior_of_light                = 860 , -- (210341) Increases the damage done by your Shield of the Righteous by 30%, but reduces armor granted by 30%.
    wrench_evil                     = 5652, -- (460720) Turn Evil's cast time is reduced by 100%.
} )


-- Auras
spec:RegisterAuras( {
    -- The Guardian of Ancient Kings is protecting you, reducing all damage taken by $s2%.
    ancient_guardian = {
        id = 86657,
        duration = 40.0,
        max_stack = 1,
    },
    -- Talent: Damage taken reduced by $w1%.  The next attack that would otherwise kill you will instead bring you to $w2% of your maximum health.
    -- https://wowhead.com/beta/spell=31850
    ardent_defender = {
        id = 31850,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=31935
    avengers_shield = {
        id = 31935,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $?$w2>0&w4>0[Damage, healing and critical strike chance increased by $w2%.]?w4==0[Damage and healing increased by $w2%.]?w2==0[Critical strike chance increased by $w4%.][]
    -- https://wowhead.com/beta/spell=31884
    avenging_wrath = {
        id = 31884,
        duration = 20,
        max_stack = 1
    },
    -- Alias for Avenging Wrath vs. Sentinel
    aw_sentinel = {
        alias = { "avenging_wrath", "sentinel" },
        aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff",
        duration = 16,
    },
    -- Talent: Block chance increased by $s1%.
    -- https://wowhead.com/beta/spell=385724
    barricade_of_faith = {
        id = 385724,
        duration = 10,
        max_stack = 1
    },
    -- Your next $U casts of Judgment generate $s1 additional Holy Power.
    bastion_of_light = {
        id = 378974,
        duration = 30,
        max_stack = 5
    },
    -- Damage and healing of your next $?s204019[Blessed Hammer]?s53595[Hammer of the Righteous][Crusader Strike] increased by $w1%.
    blessed_assurance = {
        id = 433019,
        duration = 20.0,
        max_stack = 1,
    },
    -- Talent: Damage against $@auracaster reduced by $w2.
    -- https://wowhead.com/beta/spell=204301
    blessed_hammer = {
        id = 204301,
        duration = 10,
        max_stack = 1
    },
    -- Your next Holy Power spending ability deals 20% additional increased damage and healing.
    -- https://wowhead.com/beta/spell=385127
    blessing_of_dawn = {
        id = 385127,
        duration = 20,
        max_stack = 2
    },
    blessing_of_dusk = {
        id = 385126,
        duration = 10,
        max_stack = 1
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
    -- Talent: Immune to magical damage and harmful effects.
    -- https://wowhead.com/beta/spell=204018
    blessing_of_spellwarding = {
        id = 204018,
        duration = 10,
        mechanic = "invulneraility",
        type = "Magic",
        max_stack = 1
    },
    blinding_light = {
        id = 105421,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    bulwark_of_order = {
        id = 209388,
        duration = 8,
        max_stack = 1
    },
    bulwark_of_righteous_fury = {
        id = 386652,
        duration = 15,
        max_stack = 5,
        copy = 337848
    },
    -- Interrupt and Silence effects reduced by $w1%. $?s339124[Fear effects are reduced by $w4%.][]
    -- https://wowhead.com/beta/spell=317920
    concentration_aura = {
        id = 317920,
        duration = 3600,
        max_stack = 1
    },
    -- Damage every $t1 sec.
    -- https://wowhead.com/beta/spell=26573
    consecration = {
        id = 26573,
        duration = function() return talent.consecration_in_flame.enabled and 14 or 12 end,
        tick_time = 1,
        type = "Magic",
        max_stack = 1,
        generate = function( c, type )
            if type == "buff" and FindUnitBuffByID( "player", 188370 ) then
                local dropped, expires

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
                    return
                end
            end

            c.count = 0
            c.expires = 0
            c.applied = 0
            c.caster = "unknown"
        end
    },
    consecration_dot = {
        id = 204242,
        duration = 12,
        max_stack = 1,
    },
    -- Mounted speed increased by $w1%.$?$w5>0[  Incoming fear duration reduced by $w5%.][]
    -- https://wowhead.com/beta/spell=32223
    crusader_aura = {
        id = 32223,
        duration = 3600,
        max_stack = 1
    },
    -- Melee attack damage to the Paladin reduced by $w1%
    crusaders_resolve = {
        id = 383843,
        duration = 10,
        max_stack = 3
    },
    -- Damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=465
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1
    },
    divine_purpose = {
        id = 223819,
        duration = 12,
        max_stack = 1,
    },
    divine_resonance = {
        id = 384029,
        duration = 15,
        tick_time = 5,
        max_stack = 1
    },
    divine_shield = {
        id = 642,
        duration = 8,
        mechanic = "invulneraility",
        type = "Magic",
        max_stack = 1
    },
    divine_steed = {
        id = 221886,
        duration = function () return 4 * ( 1 + ( conduit.lights_barding.mod * 0.01 ) ) + ( 2 * talent.seasoned_warhorse.rank ) + ( 2 * talent.unrelenting_charger.rank ) end,
        max_stack = 1,
    },
    -- $?j1g[Increases ground speed by $j1g%. ][]$?j1f[Increases flight speed by $j1f%. ][]$?j1s[Increases swim speed by $j1s%. ][]
    earthen_ordinants_ramolith = {
        id = 453785,
        duration = 3600,
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
    -- Sentenced to suffer $w1 Holy damage.
    -- https://wowhead.com/beta/spell=343527
    execution_sentence = {
        id = 343527,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Counterattacking all melee attacks.
    -- https://wowhead.com/beta/spell=205191
    eye_for_an_eye = {
        id = 205191,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Dealing $s1% less damage to the Paladin.
    -- https://wowhead.com/beta/spell=387174
    eye_of_tyr = {
        id = 387174,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    fading_light = {
        id = 405790,
        duration = 10,
        max_stack = 1,
    },
    faith_barricade = {
        id = 385724,
        duration = 10,
        max_stack = 1
    },
    faith_in_the_light = {
        id = 379041,
        duration = 5,
        max_stack = 1
    },
    final_reckoning = {
        id = 343721,
        duration = 8,
        max_stack = 1
    },
    final_stand = {
        id = 204079,
        duration = 8,
        max_stack = 1,
    },
    first_avenger = {
        id = 327225,
        duration = 8,
        max_stack = 1
    },
    -- Your Judgment deals ${$w2*$w4}% increased damage.
    for_whom_the_bell_tolls = {
        id = 433618,
        duration = 20.0,
        max_stack = 1,
    },
    forbearance = {
        id = 25771,
        duration = 30,
        max_stack = 1,
    },
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 5
    },
    -- Gift of the Golden Val'kyr has ended and will not activate.
    gift_of_the_golden_valkyr = {
        id = 393879,
        duration = 45.0,
        max_stack = 1,
    },
    -- Talent: Damage taken reduced by $86657s2%.
    -- https://wowhead.com/beta/spell=86659
    guardian_of_ancient_kings = {
        id = 86659,
        duration = 8,
        max_stack = 1
    },
    guardian_of_the_forgotten_queen_228048 = { -- TODO: Disambiguate -- TODO: Check Aura (https://wowhead.com/beta/spell=228048)
        id = 228048,
        duration = 10,
        max_stack = 1
    },
    guardian_of_the_forgotten_queen_228049 = { -- TODO: Disambiguate -- TODO: Check Aura (https://wowhead.com/beta/spell=228049)
        id = 228049,
        duration = 10,
        max_stack = 1
    },
    hammer_of_light_free = {
        duration = 3600,
        max_stack = 1
    },
    hammer_of_light_ready = {
        id = 427453,
        duration = 12,
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
    hand_of_hindrance = {
        id = 183218,
        duration = 10,
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
    --[[ Talent: Your Holy Power generation is tripled.
    -- https://wowhead.com/beta/spell=105809
    holy_avenger = {
        id = 105809,
        duration = 20,
        max_stack = 1
    }, ]]
    -- Wielding a Holy Bulwark.$?$w3<0[; Duration of Fear effects reduced by $s3%.][]
    holy_bulwark = {
        id = 432496,
        duration = 20.0,
        pandemic = true,
        max_stack = 1,
    },
    holy_bulwark_ready = {
        duration = 3600,
        max_stack = 1
    },
    inner_light = {
        id = 386556,
        duration = 4,
        max_stack = 1
    },
    -- Talent: Strength increased by $w1.
    -- https://wowhead.com/beta/spell=393019
    inspiring_vanguard = {
        id = 393019,
        duration = 8,
        max_stack = 1,
        copy = 279397
    },
    -- Taking $w1% increased damage from $@auracaster's next Holy Power ability.
    -- https://wowhead.com/beta/spell=197277
    judgment = {
        id = 197277,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Attackers are healed for $183811s1.
    -- https://wowhead.com/beta/spell=196941
    judgment_of_light = {
        id = 196941,
        duration = 30,
        max_stack = 25
    },
    -- Talent: Healing for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=378412
    light_of_the_titans = {
        id = 378412,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- $?$W1==$U[Ready to deliver Light's justice.][Building up Light's Deliverance. At $u stacks, your next Hammer of Light cast will activate another Hammer of Light for free.]
    lights_deliverance = {
        id = 433674,
        duration = 3600,
        max_stack = 60,
    },
    -- Talent: Avenger's Shield damage increased by $s2% and cooldown reduced by $s1%. Generating an absorb shield for $s2% of all damage dealt.
    -- https://wowhead.com/beta/spell=327193
    moment_of_glory = {
        id = 327193,
        duration = 15,
        max_stack = 1
    },
    -- Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=383469
    radiant_decree = {
        id = 383469,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Strength and Stamina increased by $w1%.
    -- https://wowhead.com/beta/spell=280375
    redoubt = {
        id = 280375,
        duration = 10,
        max_stack = 3
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=383389
    relentless_inquisitor = {
        id = 383389,
        duration = 12,
        max_stack = 3
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
    -- Used to model 1s ICD of Righteous Protector after Holy Power spender.
    righteous_protector_icd = {
        duration = 1,
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
    sacred_weapon = {
        id = 432502,
        duration = 20,
        max_stack = 1
    },
    sacred_weapon_ready = {
        duration = 3600,
        max_stack = 1
    },
    -- Empyrean Hammer damage increased by $w1%
    sanctification = {
        id = 433671,
        duration = 10.0,
        max_stack = 1,
    },
    -- Talent: $@spellaura385728
    -- https://wowhead.com/beta/spell=385723
    seal_of_the_crusader = {
        id = 385723,
        duration = 5,
        max_stack = 1
    },
    -- Misses spells and melee attacks.
    searing_glare = {
        id = 410201,
        duration = 4.0,
        max_stack = 1,
    },
    sense_undead = {
        id = 5502,
        duration = 3600,
        max_stack = 1
    },
    -- Damage taken reduced by $s12%. Maximum health increased by $s11%.; $?s53376[; Judgment generates $53376s3~ additional Holy Power.][]; $?s384376[; Damage and healing increased by $s1~%. Hammer of Wrath may be cast on any target.][]
    sentinel = {
        id = 389539,
        duration = function() return 16 * ( 1 + 0.25 * talent.sanctified_wrath.rank ) end,
        max_stack = 15,
        copy = "divine_resolve"
    },
    -- Casting Empyrean Hammer on a nearby target every $t sec.
    shake_the_heavens = {
        id = 431536,
        duration = 8.0,
        max_stack = 1,
    },
    -- Armor increased by $?c1[${$W1*$INT/100}][${$W1*$STR/100}].
    -- https://wowhead.com/beta/spell=132403
    shield_of_the_righteous = {
        id = 132403,
        duration = 4.5,
        max_stack = 1
    },
    -- Absorbs $w1 damage and deals damage when the barrier fades or is fully consumed.
    -- https://wowhead.com/beta/spell=184662
    shield_of_vengeance = {
        id = 184662,
        duration = 15,
        mechanic = "shield",
        type = "Magic",
        max_stack = 1
    },
    shield_of_virtue = {
        id = 215652,
        duration = 3600,
        max_stack = 1
    },
    shining_light = {
        id = 182104,
        duration = 15,
        max_stack = 3,
    },
    shining_light_free = {
        id = 327510,
        duration = 15,
        max_stack = 2,
        copy = "shining_light_full"
    },
    strength_in_adversity = {
        id = 393038,
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

    -- Generic Aura to cover any Aura.
    paladin_aura = {
        alias = { "concentration_aura", "crusader_aura", "devotion_aura", "retribution_aura" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },

    -- Azerite Powers
    empyreal_ward = {
        id = 287731,
        duration = 60,
        max_stack = 1,
    },

    -- Conduits
    royal_decree = {
        id = 340147,
        duration = 15,
        max_stack = 1
    },
    shielding_words = {
        id = 338788,
        duration = 10,
        max_stack = 1
    },
    vengeful_shock = {
        id = 340007,
        duration = 5,
        max_stack = 1
    },
} )


spec:RegisterGear( "tier31", 207189, 207190, 207191, 207192, 207194 )
spec:RegisterAuras( {
    sanctification = { -- TODO: Explore reset of stacks when empowered Consecration expires.
        id = 424616,
        duration = 20,
        max_stack = 5
    },
    sanctification_empower = {
        id = 424622,
        duration = 30,
        max_stack = 1
    },
})

-- Tier 30
spec:RegisterGear( "tier30", 202455, 202453, 202452, 202451, 202450 )
spec:RegisterAura( "heartfire", {
    id = 408399,
    duration = 5,
    max_stack = 1
} )


-- Gear Sets
spec:RegisterGear( "tier29", 200417, 200419, 200414, 200416, 200418, 217198, 217200, 217196, 217197, 217199 )
spec:RegisterAuras( {
    ally_of_the_light = {
        id = 394714,
        duration = 8,
        max_stack = 1
    },
    deflecting_light = {
        id = 394727,
        duration = 10,
        max_stack = 1
    }
} )

spec:RegisterGear( "tier19", 138350, 138353, 138356, 138359, 138362, 138369 )
spec:RegisterGear( "tier20", 147160, 147162, 147158, 147157, 147159, 147161 )
    spec:RegisterAura( "sacred_judgment", {
        id = 246973,
        duration = 8,
        max_stack = 1,
    } )

spec:RegisterGear( "tier21", 152151, 152153, 152149, 152148, 152150, 152152 )
spec:RegisterGear( "class", 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )

spec:RegisterGear( "breastplate_of_the_golden_valkyr", 137017 )
spec:RegisterGear( "heathcliffs_immortality", 137047 )
spec:RegisterGear( "justice_gaze", 137065 )
spec:RegisterGear( "saruans_resolve", 144275 )
spec:RegisterGear( "tyelca_ferren_marcuss_stature", 137070 )
spec:RegisterGear( "tyrs_hand_of_faith", 137059 )
spec:RegisterGear( "uthers_guard", 137105 )

spec:RegisterGear( "soul_of_the_highlord", 151644 )
spec:RegisterGear( "pillars_of_inmost_light", 151812 )


spec:RegisterStateExpr( "last_consecration", function () return action.consecration.lastCast end )
spec:RegisterStateExpr( "last_blessed_hammer", function () return action.blessed_hammer.lastCast end )
spec:RegisterStateExpr( "last_shield", function () return action.shield_of_the_righteous.lastCast end )

spec:RegisterStateExpr( "consecration", function () return buff.consecration end )

local holy_power_generators_used = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, overEnergize, powerType )
    if sourceGUID ~= state.GUID then return end

    if subtype == "SPELL_ENERGIZE" and powerType == Enum.PowerType.HolyPower and ( amount + overEnergize ) > 0 then
        local ability = class.abilities[ spellName ]

        if ability and ability.key ~= "arcane_torrent" and ability.key ~= "divine_toll" then
            holy_power_generators_used = ( holy_power_generators_used + 1 ) % 3
            return
        end
    elseif spellID == class.auras.blessing_of_dawn.id and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
        holy_power_generators_used = max( 0, holy_power_generators_used - 3 )
        return
    end
end )

spec:RegisterStateExpr( "hpg_used", function() return holy_power_generators_used end )

spec:RegisterStateExpr( "hpg_to_2dawn", function()
    return max( -1, 6 - hpg_used - ( buff.blessing_of_dawn.stack * 3 ) )
end )

rawset( state, "holy_bulwark", "holy_bulwark" )
rawset( state, "sacred_weapon", "sacred_weapon" )

local ld_stacks = 0
local free_hol_triggered = 0

spec:RegisterHook( "reset_precast", function ()
    last_consecration = nil
    last_blessed_hammer = nil
    last_shield = nil

    if buff.divine_resonance.up then
        state:QueueAuraEvent( "divine_toll", class.abilities.avengers_shield.handler, buff.divine_resonance.expires, "AURA_PERIODIC" )
        if buff.divine_resonance.remains > 5 then state:QueueAuraEvent( "divine_toll", class.abilities.avengers_shield.handler, buff.divine_resonance.expires - 5, "AURA_PERIODIC" ) end
        if buff.divine_resonance.remains > 10 then state:QueueAuraEvent( "divine_toll", class.abilities.avengers_shield.handler, buff.divine_resonance.expires - 10, "AURA_PERIODIC" ) end
    end

    if talent.righteous_protector.enabled then
        local lastAbility = prev.last and class.abilities[ prev.last ]
        if lastAbility and lastAbility.spendType == "holy_power" and now - lastAbility.lastCast < 1 then
            applyBuff( "righteous_protector_icd" )
            buff.righteous_protector_icd.expires = lastAbility.lastCast + 1
        end
    end

    if talent.holy_armaments.enabled then
        if IsActiveSpell( 432472 ) then applyBuff( "sacred_weapon_ready" )
        else applyBuff( "holy_bulwark_ready" ) end
    end

    if IsSpellKnownOrOverridesKnown( 427453 ) then
        if talent.lights_deliverance.enabled then
            -- We need to track when it ticks over from 59/60 stacks.
            local stacks = buff.lights_deliverance.stack

            if stacks < ld_stacks then
                free_hol_triggered = now
            end
            ld_stacks = stacks

            if free_hol_triggered + 12 < now then free_hol_triggered = 0 end -- Reset.

            if free_hol_triggered > 0 and action.hammer_of_light.lastCast > action.eye_of_tyr.lastCast then
                local hol_remains = free_hol_triggered + 12 - query_time
                hol_remains = hol_remains > 0 and hol_remains or ( 2 * gcd.max )

                applyBuff( "hammer_of_light_free", max( 2 * gcd.max, hol_remains ) )
                if Hekili.ActiveDebug then Hekili:Debug( "Hammer of Light active; applied hammer_of_light_free: %.2f : %.2f : %.2f : %d", buff.hammer_of_light_free.remains, free_hol_triggered, query_time, ld_stacks ) end
            else
                if Hekili.ActiveDebug then Hekili:Debug( "Hammer of Light active; hammer_of_light_free ruled out: %.2f : %.2f : %d", free_hol_triggered, query_time, ld_stacks ) end
            end
        end

        if not buff.hammer_of_light_free.up then
            local hol_remains = action.eye_of_tyr.lastCast + 12 - query_time
            hol_remains = hol_remains > 0 and hol_remains or ( 2 * gcd.max )
            applyBuff( "hammer_of_light_ready", hol_remains )
            if Hekili.ActiveDebug then Hekili:Debug( "Hammer of Light not active; applied hammer_of_light_ready: %.2f", buff.hammer_of_light_ready.remains ) end
        end

        if buff.hammer_of_light_ready.down and buff.hammer_of_light_free.down then
            if Hekili.ActiveDebug then Hekili:Debug( "Hammer of Light appears active [ %.2f ] but I don't know why; applying hammer_of_light_ready." ) end
            applyBuff( "hammer_of_light_ready", 2 * gcd.max )
        end
    end

    hpg_used = nil
    hpg_to_2dawn = nil
end )


spec:RegisterStateExpr( "next_armament", function()
    if buff.sacred_weapon_ready.up then return "sacred_weapon" end
    return "holy_bulwark"
end )

spec:RegisterStateExpr( "judgment_holy_power", function()
    return 1 + ( buff.bastion_of_light.up and 2 or 0 ) + ( ( buff.avenging_wrath.up or buff.sentinel.up ) and talent.sanctified_wrath.enabled and 1 or 0 )
end )


spec:RegisterHook( "spend", function( amt, resource )
    if amt > 0 and resource == "holy_power" then
        if talent.righteous_protector.enabled then
            reduceCooldown( "avenging_wrath", 1.5 )
            reduceCooldown( "guardian_of_ancient_kings", 1.5 )
            applyBuff( "righteous_protector_icd" )
        end
        if talent.fist_of_justice.enabled then
            reduceCooldown( "hammer_of_justice", talent.fist_of_justice.rank * amt )
        end
        if buff.blessing_of_dawn.up then
            removeBuff( "blessing_of_dawn" )
            applyBuff( "blessing_of_dusk" )
        end
        if talent.relentless_inquisitor.enabled or legendary.relentless_inquisitor.enabled then
            addStack( "relentless_inquisitor" )
        end
        if talent.resolute_defender.enabled and amt > 2 then
            reduceCooldown( "ardent_defender", talent.resolute_defender.rank )
            reduceCooldown( "divine_shield", talent.resolute_defender.rank )
        end
        if talent.tirions_devotion.enabled then
            reduceCooldown( "lay_on_hands", amt )
        end
        if legendary.uthers_devotion.enabled then
            reduceCooldown( "blessing_of_freedom", 1 )
            reduceCooldown( "blessing_of_protection", 1 )
            reduceCooldown( "blessing_of_sacrifice", 1 )
            reduceCooldown( "blessing_of_spellwarding", 1 )
        end
    end
end )


-- TODO: Need to count HoPo generators and stack Blessing of Dawn on third cast.
spec:RegisterHook( "gain", function( amt, resource, overcap )
    if amt > 0 and resource == "holy_power" then
        if buff.blessing_of_dusk.up then
            applyBuff( "fading_light" )
        end

        if this_action ~= "arcane_torrent" and this_action ~= "divine_toll" then
            if hpg_used == 2 then
                hpg_used = 0
                addStack( "blessing_of_dawn" )
            else
                hpg_used = hpg_used + 1
            end
        end
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Talent: Reduces all damage you take by 20% for 8 sec. While Ardent Defender is active, the next attack that would otherwise kill you will instead bring you to 20% of your maximum health.
    ardent_defender = {
        id = 31850,
        cast = 0,
        cooldown = function ()
            return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 120
        end,
        gcd = "off",
        school = "physical",

        talent = "ardent_defender",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "ardent_defender" )
        end,
    },

    -- Talent: Hurls your shield at an enemy target, dealing 1,240 Holy damage, interrupting and silencing the non-Player target for 3 sec, and then jumping to 2 additional nearby enemies. Shields you for 8 sec, absorbing 25% as much damage as it dealt. Deals 167 additional damage to all enemies within 5 yards of each target hit.
    avengers_shield = {
        id = 31935,
        cast = 0,
        cooldown = function() return 15 * ( buff.moment_of_glory.up and 0.25 or 1 ) end,
        gcd = "spell",

        talent = "avengers_shield",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "avengers_shield" )
            interrupt()
            removeStack( "moment_of_glory", nil, 1 )
            removeBuff( "shield_of_virtue" )

            if talent.barricade_of_faith.enabled then applyBuff( "barricade_of_faith" ) end
            if talent.bulwark_of_order.enabled then applyBuff( "bulwark_of_order" ) end
            if talent.crusaders_resolve.enabled then applyDebuff( "target", "crusaders_resolve" ) end
            if talent.first_avenger.enabled then applyBuff( "first_avenger" ) end
            if talent.gift_of_the_golden_valkyr.enabled then
                reduceCooldown( "guardian_of_ancient_kings", 0.5 * talent.gift_of_the_golden_valkyr.rank * min( active_enemies, 3 + ( talent.soaring_shield.enabled and 2 or 0 ) ) )
            end
            if talent.strength_in_adversity.enabled then addStack( "strength_in_adversity", nil, min( active_enemies, 3 + ( talent.soaring_shield.enabled and 2 or 0 ) ) ) end

            if set_bonus.tier29_2pc > 0 then applyBuff( "ally_of_the_light" ) end
            if set_bonus.tier30_2pc > 0 then
                applyDebuff( "target", "heartfire" )
                if active_enemies > 1 then active_dot.heartfire = min( active_enemies, active_dot.heartfire + 2 ) end
            end

            if conduit.vengeful_shock.enabled then applyDebuff( "target", "vengeful_shock" ) end
            if legendary.bulwark_of_righteous_fury.enabled then addStack( "bulwark_of_righteous_fury", nil, min( 5, active_enemies ) ) end
        end,
    },

    -- Talent: Call upon the Light to become an avatar of retribution, causing Judgment to generate 1 additional Holy Power, allowing Hammer of Wrath to be used on any target, increasing your damage, healing and critical strike chance by 20% for 25 sec.
    avenging_wrath = {
        id = function() return talent.sentinel.enabled and 389539 or 31884 end,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
        gcd = "off",
        school = "holy",

        startsCombat = false,
        toggle = function()
            return ( talent.sentinel.enabled and defensive_sentinel and "defensives" ) or "cooldowns"
        end,

        handler = function ()
            -- Talents:
            -- Avenging Wrath - 20% damage/healing, use Hammer of Wrath on any target.
            -- Sanctified Wrath - +5 seconds, Judgment generates +1 HP.
            -- Avenging Wrath: Might - +20% critical strike.
            -- Sentinel - Gain 15 stacks of Divine Resolve, decaying every 1 second after 5 seconds.
            if talent.sentinel.enabled then applyBuff( "sentinel", nil, 15 )
            else applyBuff( "avenging_wrath" ) end
        end,

        copy = { 31884, "sentinel", 389539 }
    },

    -- Talent: Your next 3 casts of Shield of the Righteous or Word of Glory cost no holy power.
    bastion_of_light = {
        id = 378974,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "holy",

        talent = "bastion_of_light",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "bastion_of_light", nil, 5 )
        end,
    },

    -- Talent: Throws a Blessed Hammer that spirals outward, dealing 260 Holy damage to enemies and reducing the next damage they deal to you by 626. Generates 1 Holy Power.
    blessed_hammer = {
        id = 204019,
        cast = 0,
        charges = 3,
        cooldown = function() return 6 * ( buff.blessing_of_dusk.up and talent.seal_of_order.enabled and 0.9 or 1 ) end,
        recharge = function() return 6 * ( buff.blessing_of_dusk.up and talent.seal_of_order.enabled and 0.9 or 1 ) end,
        gcd = "spell",
        school = "holy",

        talent = "blessed_hammer",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "blessed_hammer" )
            last_blessed_hammer = query_time
            gain( 1, "holy_power" )

            if set_bonus.tier29_4pc > 0 then
                applyBuff( "deflecting_light" )
                if buff.ally_of_the_light.up then buff.ally_of_the_light.expires = buff.ally_of_the_light.expires + 1 end
            end
        end,
    },

    -- Talent: Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    blessing_of_freedom = {
        id = 1044,
        cast = 0,
        charges = 1,
        cooldown = 25,
        recharge = 25,
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

    -- Talent: Blesses a party or raid member, granting immunity to Physical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Spellwarding.
    blessing_of_protection = {
        id = 1022,
        cast = 0,
        charges = 1,
        cooldown = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( 1 - 0.15 * talent.uthers_counsel.rank ) end,
        recharge = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( 1 - 0.15 * talent.uthers_counsel.rank ) end,
        gcd = "spell",
        school = "holy",

        spend = 0.15,
        spendType = "mana",

        talent = "blessing_of_protection",
        startsCombat = false,
        notalent = "blessing_of_spellwarding",
        nodebuff = "forbearance",
        toggle = "defensives",

        handler = function ()
            applyBuff( "blessing_of_protection" )
            applyDebuff( "player", "forbearance" )
        end,
    },

    -- Talent: Blesses a party or raid member, reducing their damage taken by 30%, but you suffer 100% of damage prevented. Last 12 sec, or until transferred damage would cause you to fall below 20% health.
    blessing_of_sacrifice = {
        id = 6940,
        cast = 0,
        charges = 1,
        cooldown = function() return talent.sacrifice_of_the_just.enabled and 60 or 120 end,
        recharge = 120,
        gcd = "off",
        school = "holy",

        spend = 0.07,
        spendType = "mana",

        talent = "blessing_of_sacrifice",
        startsCombat = false,

        usable = function() return group, "requires an ally" end,

        handler = function ()
            active_dot.blessing_of_sacrifice = 1
        end,
    },

    -- Talent: Blesses a party or raid member, granting immunity to magical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Protection.
    blessing_of_spellwarding = {
        id = 204018,
        cast = 0,
        charges = 1,
        cooldown = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( 1 - 0.15 * talent.uthers_counsel.rank ) end,
        recharge = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( 1 - 0.15 * talent.uthers_counsel.rank ) end,
        gcd = "spell",
        school = "holy",

        spend = 0.15,
        spendType = "mana",

        talent = "blessing_of_spellwarding",
        startsCombat = false,
        nodebuff = "forbearance",

        handler = function ()
            applyBuff( "blessing_of_spellwarding" )
            applyDebuff( "player", "forbearance" )
        end,
    },

    -- Talent: Cleanses a friendly target, removing all Poison and Disease effects.
    cleanse_toxins = {
        id = 213644,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "holy",

        spend = 0.10,
        spendType = "mana",

        talent = "cleanse_toxins",
        startsCombat = false,
        toggle = "interrupts",

        usable = function ()
            return buff.dispellable_poison.up or buff.dispellable_disease.up, "requires poison or disease"
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_disease" )
        end,
    },

    -- Interrupt and Silence effects on party and raid members within 40 yards are 30% shorter.
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
            applyBuff( "concentration_aura" )
        end,
    },

    -- Consecrates the land beneath you, causing 1,952 Holy damage over 12 sec to enemies who enter the area. Limit 1.
    consecration = {
        id = 26573,
        cast = 0,
        cooldown = 9,
        gcd = "spell",
        school = "holy",

        startsCombat = true,

        handler = function ()
            applyBuff( "consecration" )
            applyDebuff( "target", "consecration_dot" )
            last_consecration = query_time
        end,
    },

    -- Increases mounted speed by 20% for all party and raid members within 40 yards.
    crusader_aura = {
        id = 32223,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        talent = "crusader_aura",
        startsCombat = false,
        nobuff = "paladin_aura",

        handler = function ()
            applyBuff( "crusader_aura" )
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

        spend = 0.016,
        spendType = "mana",

        notalent = function() return talent.blessed_hammer.enabled and "blessed_hammer" or "hammer_of_the_righteous" end,
        startsCombat = true,

        handler = function ()
            gain( 1, "holy_power" )
            if talent.crusaders_might.enabled then reduceCooldown( "holy_shock", 1 ) end

            if set_bonus.tier29_4pc > 0 then
                applyBuff( "deflecting_light" )
                if buff.ally_of_the_light.up then buff.ally_of_the_light.expires = buff.ally_of_the_light.expires + 1 end
            end
        end,
    },

    -- Party and raid members within 40 yards are bolstered by their devotion, reducing damage taken by 3%.
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
            applyBuff( "devotion_aura" )
        end,
    },

    -- Grants immunity to all damage and harmful effects for 8 sec. Cannot be used if you have Forbearance. Causes Forbearance for 30 sec.
    divine_shield = {
        id = 642,
        cast = 0,
        cooldown = function () return 300 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * ( 1 - 0.15 * talent.uthers_counsel.rank ) end,
        gcd = "spell",
        school = "holy",

        startsCombat = false,

        toggle = "defensives",
        nodebuff = "forbearance",

        handler = function ()
            applyBuff( "divine_shield" )
            applyDebuff( "player", "forbearance" )

            if talent.final_stand.enabled then
                applyDebuff( "target", "final_stand" )
                active_dot.final_stand = min( active_dot.final_stand, active_enemies )
            end
        end,
    },

    -- Releases a blinding flash from your shield, causing $s2 Holy damage to all nearby enemies within $A1 yds and reducing all damage they deal to you by $s1% for $d.
    eye_of_tyr = {
        id = 387174,
        cast = 0,
        cooldown = function() return talent.inmost_light.enabled and 45 or 60 end,
        gcd = "spell",
        school = "holy",

        talent = "eye_of_tyr",
        startsCombat = true,
        nobuff = function() return buff.hammer_of_light_free.up and "hammer_of_light_free" or "hammer_of_light_ready" end,

        toggle = function()
            if not talent.lights_guidance.enabled then return "defensives" end
        end,

        handler = function ()
            applyDebuff( "target", "eye_of_tyr" )
            active_dot.eye_of_tyr = active_enemies

            if talent.lights_guidance.enabled then
                applyBuff( "hammer_of_light_ready" )
            end
        end,

        bind = "hammer_of_light"
    },

    -- Quickly heal a friendly target for $?$c1&$?a134735[${$s1*1}][$s1].
    flash_of_light = {
        id = 19750,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.10,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            gain( 1.67 * 1.68 * ( 1 + stat.versatility_atk_mod ) * stat.spell_power, "health" )
        end,
    },

    -- Talent: Empowers you with the spirit of ancient kings, reducing all damage you take by 50% for 8 sec.
    guardian_of_ancient_kings = {
        id = function () return IsSpellKnownOrOverridesKnown( 212641 ) and 212641 or 86659 end,
        cast = 0,
        cooldown = function () return 300 - ( conduit.royal_decree.mod * 0.001 ) end,
        gcd = "off",
        school = "holy",

        talent = "guardian_of_ancient_kings",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "guardian_of_ancient_kings" )
            if conduit.royal_decree.enabled then applyBuff( "royal_decree" ) end
        end,

        copy = { 86659, 212641 }
    },

    -- Empowers the friendly target with the spirit of the forgotten queen, causing the target to be immune to all damage for 10 sec.
    guardian_of_the_forgotten_queen = {
        id = 228049,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        school = "holy",

        pvptalent = "guardian_of_the_forgotten_queen",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "guardian_of_the_forgotten_queen" )
        end,
    },

    -- Stuns the target for 6 sec.
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

    -- Talent: Hammers the current target for 1,302 Physical damage. While you are standing in your Consecration, Hammer of the Righteous also causes a wave of light that hits all other targets within 8 yds for 226 Holy damage. Generates 1 Holy Power.
    hammer_of_the_righteous = {
        id = 53595,
        cast = 0,
        charges = 2,
        cooldown = function() return 6 * ( buff.blessing_of_dusk.up and talent.seal_of_order.enabled and 0.9 or 1 ) end,
        recharge = function() return 6 * ( buff.blessing_of_dusk.up and talent.seal_of_order.enabled and 0.9 or 1 ) end,
        gcd = "spell",
        school = "physical",

        talent = "hammer_of_the_righteous",
        startsCombat = true,
        notalent = "blessed_hammer",

        handler = function ()
            gain( 1, "holy_power" )

            if set_bonus.tier29_4pc > 0 then
                applyBuff( "deflecting_light" )
                if buff.ally_of_the_light.up then buff.ally_of_the_light.expires = buff.ally_of_the_light.expires + 1 end
            end
        end,
    },

    -- Talent: Hurls a divine hammer that strikes an enemy for 2,840 Holy damage. Only usable on enemies that have less than 20% health, or during Avenging Wrath. Generates 1 Holy Power.
    hammer_of_wrath = {
        id = 24275,
        cast = 0,
        charges = 1,
        cooldown = function() return 7.5 * ( buff.blessing_of_dusk.up and talent.seal_of_order.enabled and 0.9 or 1 ) end,
        recharge = function() return 7.5 * ( buff.blessing_of_dusk.up and talent.seal_of_order.enabled and 0.9 or 1 ) end,
        gcd = "spell",
        school = "holy",

        talent = "hammer_of_wrath",
        startsCombat = false,

        usable = function () return target.health_pct < 20 or ( level > 57 and ( buff.avenging_wrath.up or buff.sentinel.up ) and talent.avenging_wrath.enabled ) or buff.hammer_of_wrath_hallow.up or buff.negative_energy_token_proc.up, "requires low health, avenging_wrath, or ashen_hallow" end,
        handler = function ()
            gain( 1, "holy_power" )

            if talent.zealots_paragon.enabled then
                if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 0.5 end
                if buff.sentinel.up then buff.sentinel.expires = buff.sentinel.expires + 0.5 end
            end

            if legendary.the_mad_paragon.enabled then
                if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 1 end
                if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 1 end
            end
        end,
    },


    hand_of_hindrance = {
        id = 183218,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        talent = "hand_of_hindrance",
        startsCombat = true,
        texture = 1360760,

        handler = function ()
            applyDebuff( "target", "hand_of_hindrance" )
        end,
    },

    -- Commands the attention of an enemy target, forcing them to attack you.
    hand_of_reckoning = {
        id = 62124,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "off",
        school = "holy",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "hand_of_reckoning" )
        end,
    },

    --[[ Talent: Your Holy Power generation is tripled for 20 sec.
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
    }, ]]

    -- [432496] While wielding a Holy Bulwark, gain an absorb shield for ${$s2/10}.1% of your max health and an additional ${$s4/10}.1% every $t2 sec. Lasts $d.
    holy_armaments = {
        id = function() return buff.holy_bulwark_ready.up and 432459 or 432472 end,
        known = 432459,
        cast = 0.0,
        cooldown = 60,
        charges = 2,
        recharge = 60,
        gcd = "spell",

        startsCombat = false,
        buff = function()
            if buff.holy_bulwark_ready.up then return "holy_bulwark_ready" end
            return "sacred_weapon_ready"
        end,
        texture = function() return buff.holy_bulwark_ready.up and 5927636 or 5927637 end,

        handler = function ()
            if buff.holy_bulwark_ready.up then
                applyBuff( "holy_bulwark" )
                removeBuff( "holy_bulwark_ready" )
                applyBuff( "sacred_weapon_ready" )
            else
                applyBuff( "sacred_weapon" )
                removeBuff( "sacred_weapon_ready" )
                applyBuff( "holy_bulwark_ready" )
            end
        end,

        copy = { "holy_bulwark", 432459, "sacred_weapon", 432472 }
    },

    -- Judges the target, dealing 2,824 Holy damage, and causing them to take 20% increased damage from your next Holy Power ability. Generates 1 Holy Power.
    judgment = {
        id = 275779,
        cast = 0,
        charges = function () return talent.crusaders_judgment.enabled and 2 or nil end,
        cooldown = function() return ( 6 - ( 0.5 * talent.seal_of_alacrity.rank ) ) * ( buff.blessing_of_dusk.up and talent.seal_of_order.enabled and 0.9 or 1 ) end,
        recharge = function () return talent.crusaders_judgment.enabled and ( 6 - ( 0.5 * talent.seal_of_alacrity.rank ) * ( buff.blessing_of_dusk.up and talent.seal_of_order.enabled and 0.9 or 1 ) ) or nil end,
        gcd = "spell",
        school = "holy",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        aura = "judgment",

        handler = function ()
            if talent.greater_judgment.enabled then applyDebuff( "target", "judgment" ) end
            removeBuff( "recompense" )
            gain( judgment_holy_power, "holy_power" )
            removeStack( "bastion_of_light" )
            if talent.judgment_of_light.enabled then applyDebuff( "target", "judgment_of_light", nil, 5 ) end
        end,

        copy = 220637
    },

    -- Talent: Heals a friendly target for an amount equal to 100% your maximum health. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    lay_on_hands = {
        id = 633,
        cast = 0,
        cooldown = function () return 600 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * ( 1 - 0.15 * talent.uthers_counsel.rank ) end,
        gcd = "off",
        school = "holy",

        talent = "lay_on_hands",
        startsCombat = false,

        toggle = "defensives",
        nodebuff = "forbearance",

        handler = function ()
            gain( health.max, "health" )
            applyDebuff( "player", "forbearance" )
            if azerite.empyreal_ward.enabled then applyBuff( "empyrael_ward" ) end
        end,
    },

    -- Talent: For the next 15 sec, you generate an absorb shield for 20% of all damage you deal, and Avenger's Shield damage is increased by 20% and its cooldown is reduced by 75%.
    moment_of_glory = {
        id = 327193,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "holy",

        talent = "moment_of_glory",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            setCooldown( "avengers_shield", 0 )
            applyBuff( "moment_of_glory" )
        end,
    },

    -- Talent: Interrupts spellcasting and prevents any spell in that school from being cast for 4 sec.
    rebuke = {
        id = 96231,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "physical",

        talent = "rebuke",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if talent.punishment.enabled then class.abilities.judgment.handler() end
        end,
    },

    -- When any party or raid member within 40 yards dies, you gain Avenging Wrath for 12 sec. When any party or raid member within 40 yards takes more than 50% of their health in damage, you gain Seraphim for 4 sec. This cannot occur more than once every 30 sec.
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
            applyBuff( "retribution_aura" )
        end,
    },

    -- Slams enemies in front of you with your shield, causing $s1 Holy damage, and increasing your Armor by $?c1[${$132403s1*$INT/100}][${$132403s1*$STR/100}] for $132403d.$?a386568[    $@spelldesc386568][]$?a280373[    $@spelldesc280373][]
    shield_of_the_righteous = {
        id = 53600,
        cast = 0,
        cooldown = 1,
        gcd = "off",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3 - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        startsCombat = true,

        usable = function() return equipped.shield, "requires a shield" end,

        handler = function ()
            removeBuff( "bulwark_of_righteous_fury" )
            removeBuff( "divine_purpose" )
            removeBuff( "the_magistrates_judgment" )
            removeDebuff( "target", "judgment" )

            if talent.faiths_armor.enabled then applyBuff( "faiths_armor" ) end
            if talent.redoubt.enabled then addStack( "redoubt", nil, 3 ) end

            if buff.shining_light_full.up then removeBuff( "shining_light_full" )
            elseif talent.shining_light.enabled then
                addStack( "shining_light", nil, 1 )
                if buff.shining_light.stack == 3 then
                    applyBuff( "shining_light_full" )
                    removeBuff( "shining_light" )
                end
            end

            applyBuff( "shield_of_the_righteous", buff.shield_of_the_righteous.remains + 4.5 )
            last_shield = query_time
        end,
    },


    shield_of_virtue = {
        id = 215652,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        pvptalent = "shield_of_virtue",
        startsCombat = false,
        texture = 237452,

        handler = function ()
            applyBuff( "shield_of_virtue" )
        end,
    },

    -- Calls down the Light to heal a friendly target for 7,531 and an additional 313 over 15 sec. Protection: Healing increased by up to 250% based on the target's missing health.
    word_of_glory = {
        id = 85673,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up or buff.shining_light_full.up or buff.royal_decree.up or buff.bastion_of_light.up then return 0 end
            return 3 - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        startsCombat = false,

        handler = function ()
            spend( 0.1 * mana.max, "mana" )

            if buff.royal_decree.up then removeBuff( "royal_decree" )
            elseif buff.divine_purpose.up then removeBuff( "divine_purpose" )
            elseif buff.bastion_of_light.up then removeStack( "bastion_of_light" )
            else removeBuff( "shining_light_full" ) end

            removeBuff( "the_magistrates_judgment" )
            gain( 2.9 * stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )
            removeBuff( "recompense" )

            if buff.vanquishers_hammer.up then
                applyBuff( "shield_of_the_righteous" )
                removeStack( "vanquishers_hammer" )
            end

            if talent.faith_in_the_light.enabled then applyBuff( "faith_in_the_light" ) end
            if talent.light_of_the_titans.enabled then applyBuff( "light_of_the_titans" ) end

            if conduit.shielding_words.enabled then applyBuff( "shielding_words" ) end

        end,
    },
} )


spec:RegisterSetting( "wog_health", 40, {
    name = "|T133192:0|t Word of Glory Health Threshold",
    desc = "When set above zero, the addon may recommend |T133192:0|t Word of Glory when your health falls below this percentage.",
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterStateExpr( "wog_health", function ()
    return settings.wog_health or 0
end )


spec:RegisterSetting( "goak_damage", 40, {
    name = "|T135919:0|t Guardian of Ancient Kings Damage Threshold",
    desc = function() return "When set above zero, the addon may recommend |T135919:0|t " .. ( GetSpellInfo( class.abilities.guardian_of_ancient_kings.id ) or "Guardian of Ancient Kings" )
            .. " when you take this percentage of your maximum health in damage in the past 5 seconds.\n\n"
            .. "By default, your Defensives toggle must also be enabled."
        end,
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterStateExpr( "goak_damage", function ()
    return ( settings.goak_damage or 0 ) * health.max * 0.01
end )


spec:RegisterSetting( "ds_damage", 60, {
    name = "|T524354:0|t Divine Shield Damage Threshold",
    desc = function() return "When set above zero, the addon may recommend |T524354:0|t " .. ( GetSpellInfo( class.abilities.divine_shield.id ) or "Divine Shield" )
            .. " when you take this percentage of your maximum health in damage in the past 5 seconds.\n\n"
            .. "By default, your Defensives toggle must also be enabled."
        end,
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterStateExpr( "ds_damage", function ()
    return ( settings.ds_damage or 0 ) * health.max * 0.01
end )


spec:RegisterSetting( "sentinel_def", false, {
    name = strformat( "%s: Use Defensively", Hekili:GetSpellLinkWithTexture( 389539 ) ),
    desc = function()
        return strformat( "When enabled, %s is placed on the Defensives toggle by default (rather than Cooldowns) and is recommended based on your Guardian of Ancient Kings "
            .. "Damage Threshold setting.", Hekili:GetSpellLinkWithTexture( 389539 ) )
    end,
    type = "toggle",
    width = "full",
} )

spec:RegisterStateExpr( "defensive_sentinel", function()
    if settings.sentinel_def ~= nil then return settings.sentinel_def end
    return false
end )


spec:RegisterRanges( "shield_of_the_righteous", "rebuke", "avengers_shield" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    potion = "phantom_fire",

    package = "Protection Paladin",
} )


spec:RegisterPack( "Protection Paladin", 20271011, [[Hekili:TVXAVTnoYFlbfW1gBQRLsCsArCa2BXbSBqXIfx2dhUVyzAjABTrw0NOus9Ha)B)MHupiLiLKDt71fy)qBsKgoCE)IIZDM)7ZFiGKsN)RUtCV0zIJZ4j3m9sNRM)q6(D05pSJ4)izn8lXKTW))BjSuQFAil(WIFJerccJry2hXibiU4SSeFaUnPP74F89VFDy6MSLJ9zBFppCBwebxQFczvk(3(VF(dlZcJs)L45lntitN)ajlDdlz(dpeU9NamhgeqLGt5(ZFab)DotENJZhpS4FUdXXHfRsyBpSaxWH7pCVaKjF4DtUba5Fq5PSeaMTHPHRjswHKZsrH8uTv4E(Hf4pVm)NigeODrMCRkb(gGcaGCD7GmU(DUxaG87BG3)VijW)bIiukI7nxidtjXbKeuE(RcfenMSmIgm)Vn)b)KWuAsibupKiAC64OW1Bs5ERZcdiX(0X5WEyXGdlgEyHpJffWEoEmDp1JTYlDFY4e6wsym)WIBbY9WIxE5WILzRwnEdz7wAccLaPEjusW(Xz7oSyub6o7WI89nHgWYwMwTFLOP4naB4)4Hf3nRCxQw9schf4L7vfAKB1zwiPvjukqrGnHqHbYdsuKN8p8qbOum6jnwRT65PGXLv5P99ZM8IVH8i1lDd1BdL8enMpoilj3Gca1PKPTankzri6sh5mEQeWv5QffYPssyGzVWkZQRkr4PSmU3oP3nlrxTwsGgG0l0pOIAbD9KU0HfMvvKoFtinkqW6G4PCtqw4sRSqm9ZPEKKTGMoovSZCIpy759mLSdvbLwSsXV6llf9dn(wvj8vA8cQ4whgV27zqrVrGMbkYNAVUcpa1DHuWmsrJXI2xYbcUDAnUTaY)ilyncKk)Z3rbt)usYAAkFSfri4(b7SGif0)YSONjjpIWvPlxLLSx1BvcVG62XEMMiKdxa79E)iAXoIHMak(kluSqsqt4EsctgSojCN8TIGFRyrrSNbPfg2ngEWgcqVlPuq3rda2maHb299qoLdla5lQIJdt3dHzdbvEiaoyeUjoeJcShIIFyrWo4HRbPo8kgSOy85zCa7)4dYhLqbNA(gyNijjWkdG3XwbBfbIdd4ig2wEAcq(4FIiIe8eWjKeCheB52DryGB8DrO0aEod(VFgewaKkuh8xWI8Zs40GZZXDmBjlaEkFdllkqK6jts(ba1bPc4NJkledRe8oKY6V)JF6t)7dlEMelKkPmaKSyiPQ02hxuHquShLVHLjEn8C0DbERuT8woU)OIrUSXfza5Jls(8dZEFnD45HRMDwhwrz7gueH3km5wld6Lb8DZUyWzdh2EYU(IkNjJE5LCwOq5JGju9aTps1)6SoDzY9(7ldlaUxuAUBi6FDn6F1meVi(IQJha6nhrWd)nifW1YoVkdOSeQ8vEPHBPYaxRHa8BjF2S))hoI4ZIik5IjzCZcQyMEMSgXfDM0rMSesyGh48b6bsqaFm9ZyXus(Q(7q3wiQOZeTGXbHpbocEPqqjXowVWldstdIdNoQVaEmhIf4r4COub0eo3iQN2fYaXf0sb2K2fI93Ek)Vc7FL9yJ82o2tC)Arikwm(jzCWxoXdcCh(ivqa2YL2EMPFbtYa5KIOOJnseqO2FViIFrm7DjHmGFc)VyBeqYMu4FIezpGf5LhX9NLL5bHrWCaybViec(Jl70aJjGwJ)mWxyA2FcYdaanUwyO2d(jy26PH1wVpexN6lRmvV4zLxiqZ1T5MLtgHXBzqf21kBFGf)mWZ(Y8Qx7PMnVcKYAi15(aAuiKvvtauYpv1pl4M6be7BSPwJe9b1aY1Ca1Jh7oXCSBDFLARXrDn1nRRbBhXAajmAuQ35KAgR2ADSSKwjDVcBZQrL(vu6ZSeHUCDelzVG4UqLrA4ZPZi2Jv8LO)DRhbOpYN2yj7oz1QvEQcNN4tePvssWKgiA0sPR5cQjwsXitRizrPLZbOyrj0LznnhSeVR1oKluZCtTl2lmunfftTR1luag3XpsBVdOwrq5atesTDqnmSTljnLBb0NycmqGCoMeFfaMBSvLRxduDtBDfSoKx2pvDdUMb2HCAA1AFIa2zWBXFlkd(HJQ5xUaCCQd4UY9kuQsFD93bIki8C8EprJsvd1PakxdqHbVvqtzOHQPDGXSvqHbigvnbi9TQawbpQBq4X3h77XJyc)M6EFDlJCnkJCBrgzI7BkJmjj1KrgLa31Lq0GiY5OerPQ(ZTo7q9uX1S2RpYUtO26RNA(1QXxR7Jv3huFwkMCbThAVXyAQq7oMTyvAf7ycnAZKBA5aKKDkv0rHwtfBziRPLfXEsPJP(iLyA69TyphLT5xPnGV2hGLsHp1MFlU12lESvHji4UPcXRcHKBrmwES8YudgmNlwsomo10GfHdg3Wvru8ItHNDBYL6dCfRMDsPNA3BIR5qSvZtfhfQ(yInqjJuJn02ocwE4VWvKjTuyqomUhNCZ9BHCZXCy3VzYnxP1x9rQ3Am1crYsSNaKqGLfqaITyYQIrJRFmiiiz8h9GYxKWwwc(OJUNPPM61OhN7XMDRHOhEU4(le(t7lvARWB7bNBSxxwHJt6qaAGqhLZNPnnHnAF6CJ9Szkh0vQGAPurTA9x2w3I3yEJBRzrTwrBVxrhTErvZzuVNdL65744hJFumqJbLNVLr934YQSgQEMcJHEBc9dtloYOsLwoTTllzhJl7yDuVmsAXcNsIGqc78tfPUFMT2t(OVmYs5Can2OTcz3Oxs7Ui5(CRcJjrEIgB06lxvShINaaUXbKTK1uVPYSPb88humbLYG1jby1ialsJblfDMyDg86qIiLo0DDicjUtCDWYLds9G(RKvwvN11wq7oZ9G3wZip(9e3zfVTxQNGi5HpbBfScylJ6RY97nbqTQ0BTc0)mYE6BA7L5wloJJsg5iYEpOC5nG7mFEEVA4HkIVe)GxUEYhMCZyOe2NjjXc7h5zKgUDhljn)CqFB5KnElEmM)NmOwz8Wkzy)hKSu2wIyKY(W2SMYhF4(pjosWPF8WIFIfd7N41VTOIk9UlFR84rFRLMpHxp05ZJ6jsvBo2cIRbsVqEZ(ZBGCJG0lKBOPCdKUjy(QI(orSHPnyqQCY09PI(EG4wn)A8AnQ9QV9i9l0SZgYFvCySt5NMY7Rm67eXNQZspP7tf99aXNui1d3BiAF(Q4hxWENUvvIUNBtpvaGMS81dXLO0TB1JzuAaanA91dXcLZVi0liMUw)tfff7Ib35d19CfE0dSvH4eOFZBQ(IAkZA)dZEpwRawJchksjneA1qo7377cEsWFumN47nbN2jBygK6t51iq6NMHzyuphdZqumRLZXzvplx4wnWLZfZNFMd(bfz2XzG9GJdgEM9WYV8slE43nRLWw4hgK5CiFjSORkl6AMfBYfkSyt(VIfnWf31c7RYH1oNO7l5r0KtC4IQpP(zVj55IvZ7guLV06oHTiQx3qwCQFkKFjxZBAWJQIwp3J7M5cIiZN2XlV08KoU76PnFm0)GrIrVpjZWiBbbPtlt004QQDgd4Yh2Ya3V1bO6H4zwCNZKrJmJtLbe1uSz)l1ZmYQFwb2zWxEP0Q1cXp7Ij6blv3OW4Nyps9OFg6hdNEcUjstfXSD8cJxLXpbjC5zsyBH5u3D3OAkwz0dOWImteEq2v8GohI2GHnNt1SjV8I55tnYcLOnkkC)R6A92QjJDC7v(ZnohmB0HwR4s5GTbFnOqe1COb3voSRbNn0YycYPU2grGoJvoEG8hxoAaB8IvuRQFnq8kt74)NKFXmOqQT5KPAt6)DcduBp)ZHuxDKq18dDMQgir5lY2CIWAh3JIZKTVx6HLXzBELtU1nNdSDVngH1Ny8saLVqTlaKmRAhx7NrdoZ4wwmlDtYcdCTDCuN3SF1DU1P4te30f2rjdLbjNZyi3Q2zFERRrAVL0bvY2IN28w5OqfDCJCMnXMOT8YDzu2Q9DpIKL2xm5mTRldyoiLx1UHnqzggEEHG5QC6Qro4b9Oga16wui7Ys90(0SLnA0VAyUqMgUJRjdEPeQYpElu3ZBYVqF)1DA5VUtlDBL9n9oTy0t57eXqhb2R1Rup90ZVvjIepnVtl3ol)(SCsb(u)mXhKVrZmhJVwpudpMolbL6rX2gbw)ZnOm)4sd38I(PWUTl9vJKzFD2WAFQdVgBKRie(3fx(JE7V2XxXVrjhRA0DcCu7QHyCrvf6iSJB5AGmWGP8SlHAI6LsaIhafR05N7)xSFBpCwog78(yIAeMgDINx1PHMOh0rUIYsMmFBnMnPpgv9q5FIANJGtntOAtLw0Suv1xt70sxTzQALbBUpIHvHtcR)5JD3KQ2zyw(W4g1Bl(PTrz6YE1p1Tzt7MiAdZT0)H22C5jsEo5Tzzte2p9rT0)nbT5zz0egBo2TTXw8VBUeRU5nbvPCav7XIXDdqav07bDiSLFU4JrTys4IAAgA)ZxDMZaJZ7fBatVx0zxI1k2gQC1oDf9JcROkZgBZiSau7iD0XWSUDXSUVEmRJ25S8kXSIpTN5)V]] )