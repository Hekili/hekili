-- PaladinProtection.lua
-- April 2025

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID

local spec = Hekili:NewSpecialization( 66 )
local QueenGlyphed = IsSpellKnownOrOverridesKnown
local strformat = string.format

local GetSpellInfo = ns.GetUnpackedSpellInfo
local spellwardingFilters = {}

for zoneID, zoneData in pairs( class.spellFilters ) do
    for npcID, npcData in pairs( zoneData ) do
        if npcID ~= "name" then
            for spellID, spellData in pairs( npcData ) do
                if spellID ~= "name" and spellData.spell_reflection then
                    spellwardingFilters[ spellID ] = true
                end
            end
        end
    end
end

class.spellwardingFilters = spellwardingFilters

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Paladin
    a_just_reward                   = { 103858, 469411, 1 }, -- After Cleanse Toxins successfully removes an effect from an ally, they are healed for 25,016.
    afterimage                      = {  93188, 385414, 1 }, -- After you spend 20 Holy Power, your next Word of Glory echoes onto a nearby ally at 30% effectiveness.
    auras_of_the_resolute           = {  81600, 385633, 1 }, -- Learn Concentration Aura, Devotion Aura, and Crusader Aura: Concentration Aura: Interrupt and Silence effects on party and raid members within 40 yds are 30% shorter.  Devotion Aura: Party and raid members within 40 yds are bolstered by their devotion, reducing damage taken by 3%.  Crusader Aura: Increases mounted speed by 20% for all party and raid members within 40 yds.
    blessed_calling                 = { 103868, 469770, 1 }, -- Allies affected by your Blessings have 15% increased movement speed.
    blessing_of_freedom             = {  81631,   1044, 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    blessing_of_protection          = {  81616,   1022, 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Spellwarding.
    blessing_of_sacrifice           = {  81614,   6940, 1 }, -- Blesses a party or raid member, reducing their damage taken by 30%, but you suffer 100% of damage prevented. Last 12 sec, or until transferred damage would cause you to fall below 20% health.
    blinding_light                  = {  81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within 10 yds, causing them to wander disoriented for 6 sec.
    cavalier                        = {  81605, 230332, 1 }, -- Divine Steed now has 2 charges.
    cleanse_toxins                  = {  81507, 213644, 1 }, -- Cleanses a friendly target, removing all Poison and Disease effects.
    consecrated_ground              = {  81543, 204054, 1 }, -- Your Consecration is 15% larger, and enemies within it have 50% reduced movement speed.
    divine_purpose                  = {  93192, 223817, 1 }, -- Holy Power spending abilities have a 15% chance to make your next Holy Power spending ability free and deal 15% increased damage and healing.
    divine_reach                    = {  93168, 469476, 1 }, -- The radius of your auras is increased by 20 yds.
    divine_resonance                = {  81479, 386738, 1 }, --
    divine_spurs                    = { 103857, 469409, 1 }, -- Divine Steed's cooldown is reduced by 20%, but its duration is reduced by 40%.
    divine_steed                    = {  81632, 190784, 1 }, -- Leap atop your Charger for 5 sec, increasing movement speed by 100%. Usable while indoors or in combat.
    divine_toll                     = {  81496, 375576, 1 }, -- Instantly cast Avenger's Shield on up to 5 targets within 30 yds. Generates 1 Holy Power per target hit.
    empyreal_ward                   = { 103859, 387791, 1 }, -- Lay on Hands grants the target 30% increased armor for 8 sec and now ignores healing reduction effects.
    eye_for_an_eye                  = {  81628, 469309, 1 }, -- Melee and ranged attackers receive 9,385 Holy damage each time they strike you during Ardent Defender and Divine Shield.
    faiths_armor                    = {  81495, 406101, 1 }, -- Shield of the Righteous grants 5% bonus armor for 4.5 sec.
    fist_of_justice                 = {  81602, 234299, 1 }, -- Hammer of Justice's cooldown is reduced by 15 sec.
    golden_path                     = { 103856, 377128, 1 }, -- Consecration heals you and 5 allies within it for 911 every 0.8 sec.
    greater_judgment                = {  81603, 231663, 1 }, -- Judgment causes the target to take 40% increased damage from your next Holy Power ability. Multiple applications may overlap.
    hammer_of_wrath                 = {  81510,  24275, 1 }, -- Hurls a divine hammer that strikes an enemy for 54,302 Holy damage. Only usable on enemies that have less than 20% health, or during Avenging Wrath. Generates 1 Holy Power.
    holy_aegis                      = {  81609, 385515, 1 }, -- Armor and critical strike chance increased by 4%.
    holy_reprieve                   = { 103860, 469445, 1 }, -- Your Forbearance's duration is reduced by 10 sec.
    holy_ritual                     = { 103866, 199422, 1 }, -- Allies are healed for 20,013 when you cast a Blessing spell on them and healed again for 20,013 when the blessing ends.
    improved_blessing_of_protection = {  81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection and Blessing of Spellwarding by 60 sec.
    inspired_guard                  = { 103864, 469439, 1 }, -- Ardent Defender increases healing taken by 15% for its duration.
    judgment_of_light               = {  81608, 183778, 1 }, -- Judgment causes the next 5 successful attacks against the target to heal the attacker for 3,502.
    lay_on_hands                    = {  81597,    633, 1 }, -- Heals a friendly target for an amount equal to 100% your maximum health. Grants the target 30% increased armor for 8 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    lead_the_charge                 = { 103867, 469780, 1 }, -- Divine Steed reduces the cooldown of 4 nearby ally's major movement ability by 3.0 sec. Your movement speed is increased by 3%.
    lightbearer                     = { 103861, 469416, 1 }, -- 10% of all healing done to you from other sources heals up to 4 nearby allies, divided evenly among them.
    lightforged_blessing            = { 103850, 406468, 1 }, -- Shield of the Righteous heals you and up to 2 nearby allies for 2.0% of maximum health.
    lights_countenance              = { 103854, 469325, 1 }, -- The cooldowns of Repentance and Blinding Light are reduced by 15 sec.
    lights_revocation               = { 103863, 146956, 1 }, -- Removing harmful effects with Divine Shield heals you for 10% for each effect removed. This heal cannot exceed 30% of your maximum health. Divine Shield may now be cast while Forbearance is active.
    obduracy                        = {  81630, 385427, 1 }, -- Speed increased by 2% and damage taken from area of effect attacks reduced by 2%.
    of_dusk_and_dawn                = {  93356, 409441, 1 }, -- When you cast 3 Holy Power generating abilities, you gain Blessing of Dawn. When you consume Blessing of Dawn, you gain Blessing of Dusk. Blessing of Dawn Your next Holy Power spending ability deals 30% additional increased damage and healing. This effect stacks. Blessing of Dusk Damage taken reduced by 4% For 10 sec.
    punishment                      = {  93165, 403530, 1 }, -- Successfully interrupting an enemy with Rebuke or Avenger's Shield casts an extra Hammer of the Righteous.
    quickened_invocation            = {  81479, 379391, 1 }, -- Divine Toll's cooldown is reduced by 15 sec.
    rebuke                          = {  81604,  96231, 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for 3 sec.
    recompense                      = {  81607, 384914, 1 }, -- After your Blessing of Sacrifice ends, 50% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing. This effect's bonus damage cannot exceed 30% of your maximum health and its bonus healing cannot exceed 100% of your maximum health.
    repentance                      = {  81598,  20066, 1 }, -- Forces an enemy target to meditate, incapacitating them for 1 min. Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    righteous_protection            = { 103865, 469321, 1 }, -- Blessing of Sacrifice now removes and prevents all Poison and Disease effects.
    sacred_strength                 = {  93192, 469337, 1 }, -- Holy Power spending abilities are 2% more effective.
    sacrifice_of_the_just           = {  81607, 384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by 60 sec.
    sanctified_plates               = {  93009, 402964, 2 }, -- Armor increased by 5%, Stamina increased by 5% and damage taken from area of effect attacks reduced by 3%.
    seal_of_might                   = {  81621, 385450, 2 }, -- Mastery increased by 2% and strength increased by 2%.
    seal_of_the_crusader            = {  93683, 416770, 1 }, -- Your auto attacks heal a nearby ally for 13,275.
    selfless_healer                 = { 103856, 469434, 1 }, -- Flash of Light is 30% more effective on your allies and 40% of the healing done also heals you.
    stand_against_evil              = { 103855, 469317, 1 }, -- Turn Evil now affects 5 additional enemies.
    steed_of_liberty                = {  81631, 469304, 1 }, -- Divine Steed also grants Blessing of Freedom for 3.0 sec.  Blessing of Freedom: Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    stoicism                        = { 103862, 469316, 1 }, -- The duration of stun effects on you is reduced by 20%.
    turn_evil                       = {  93010,  10326, 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to 40 sec. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbound_freedom                 = {  93187, 305394, 1 }, -- Blessing of Freedom increases movement speed by 30%, and you gain Blessing of Freedom when cast on a friendly target.
    unbreakable_spirit              = {  81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, Ardent Defender, and Lay on Hands by 30%.
    worthy_sacrifice                = { 103865, 469279, 1 }, -- You automatically cast Blessing of Sacrifice onto an ally within 40 yds when they are below 35% health and you are not in a loss of control effect. This effect activates 100% of Blessing of Sacrifice's cooldown.
    wrench_evil                     = { 103855, 460720, 1 }, -- Turn Evil's cast time is reduced by 100%.
    zealots_paragon                 = {  81625, 391142, 2 }, -- Hammer of Wrath and Judgment deal 10% additional damage and extend the duration of Avenging Wrath by 0.5 sec.

    -- Protection
    ardent_defender                 = {  81481,  31850, 1 }, -- Reduces all damage you take by 30% for 8 sec. While Ardent Defender is active, the next attack that would otherwise kill you will instead bring you to 20% of your maximum health.
    avengers_shield                 = {  81502,  31935, 1 }, -- Hurls your shield at an enemy target, dealing 20,007 Holy damage, interrupting and silencing the non-Player target for 3 sec, and then jumping to 2 additional nearby enemies. Shields you for 8 sec, absorbing 60% as much damage as it dealt. Deals 2,135 additional damage to all enemies within 5 yds of each target hit.
    avenging_wrath                  = {  81483,  31884, 1 }, -- Call upon the Light to become an avatar of retribution, causing Judgment to generate 1 additional Holy Power, allowing Hammer of Wrath to be used on any target, increasing your damage, healing, and critical strike chance by 20% for 25 sec.
    barricade_of_faith              = {  81501, 385726, 1 }, -- When you use Avenger's Shield, your block chance is increased by 10% for 10 sec.
    bastion_of_light                = {  81488, 378974, 1 }, -- Your next 5 casts of Judgment generate 2 additional Holy Power.
    blessed_hammer                  = {  81469, 204019, 1 }, -- Throws a Blessed Hammer that spirals outward, dealing 5,177 Holy damage to enemies and reducing the next damage they deal to you by 5,466. Generates 1 Holy Power.
    blessing_of_spellwarding        = {  90062, 204018, 1 }, -- Blesses a party or raid member, granting immunity to magical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Protection.
    bulwark_of_order                = {  81499, 209389, 1 }, -- Avenger's Shield also shields you for 8 sec, absorbing 60% as much damage as it dealt, up to 50% of your maximum health.
    bulwark_of_righteous_fury       = {  81491, 386653, 1 }, -- Avenger's Shield increases the damage of your next Shield of the Righteous by 20% for each target hit by Avenger's Shield, stacking up to 5 times, and increases its radius by 6 yds.
    consecration_in_flame           = {  81470, 379022, 1 }, -- Consecration lasts 2 sec longer and its damage is increased by 20%.
    crusaders_judgment              = {  81473, 204023, 1 }, -- Judgment now has 2 charges, and Grand Crusader now also reduces the cooldown of Judgment by 3 sec.
    crusaders_resolve               = {  81493, 380188, 1 }, -- Enemies hit by Avenger's Shield deal 10% reduced melee damage to you for 10 sec.
    eye_of_tyr                      = {  81497, 387174, 1 }, -- Releases a blinding flash from your shield, causing 68,430 Holy damage to all nearby enemies within 8 yds and reducing all damage they deal to you by 25% for 6 sec.
    faith_in_the_light              = {  81485, 379043, 2 }, -- Casting Word of Glory grants you an additional 5% block chance for 6 sec.
    ferren_marcuss_fervor           = {  81482, 378762, 2 }, -- Avenger's Shield deals 10% increased damage to its primary target.
    final_stand                     = {  81504, 204077, 1 }, -- During Divine Shield, all targets within 15 yds are taunted.
    focused_enmity                  = {  81472, 378845, 1 }, -- When Avenger's Shield strikes a single enemy, it deals 100% additional Holy damage.
    gift_of_the_golden_valkyr       = {  81484, 378279, 1 }, -- Each enemy hit by Avenger's Shield reduces the remaining cooldown on Guardian of Ancient Kings by 1.0 sec. When you drop below 30% health, you become infused with Guardian of Ancient Kings for 4 sec. This cannot occur again for 45 sec.
    grand_crusader                  = {  81487,  85043, 1 }, -- When you avoid a melee attack or use Hammer of the Righteous, you have a 15% chance to reset the remaining cooldown on Avenger's Shield. Reduces the cooldown of Judgment by 3 sec.
    guardian_of_ancient_kings       = {  81490,  86659, 1 }, -- Empowers you with the spirit of ancient kings, reducing all damage you take by 50% for 8 sec.
    hammer_of_the_righteous         = {  81469,  53595, 1 }, -- Hammers the current target for 31,065 Physical damage. While you are standing in your Consecration, Hammer of the Righteous also causes a wave of light that hits all other targets within 8 yds for 4,320 Holy damage. Generates 1 Holy Power.
    hand_of_the_protector           = {  81475, 315924, 1 }, -- When you cast Word of Glory on someone other than yourself, its healing is increased by up to 100% based on the target's missing health.
    holy_shield                     = {  81489, 152261, 1 }, -- Your block chance is increased by 20%, you are able to block spells, and your successful blocks deal 2,965 Holy damage to your attacker.
    improved_ardent_defender        = {  90062, 393114, 1 }, -- Ardent Defender reduces damage taken by an additional 10%.
    improved_holy_shield            = {  81486, 393030, 1 }, -- Your chance to block spells is increased by 8%.
    inmost_light                    = {  92953, 405757, 1 }, -- Eye of Tyr deals 300% increased damage and has 33% reduced cooldown.
    inner_light                     = {  81494, 386568, 1 }, -- When Shield of the Righteous expires, gain 10% block chance and deal 6,034 Holy damage to all attackers for 4 sec.
    inspiring_vanguard              = {  81476, 393022, 1 }, --
    light_of_the_titans             = {  81503, 378405, 1 }, -- Word of Glory heals for an additional 20% over 10 sec. Increased by 100% if cast on yourself while you are afflicted by a harmful damage over time effect.
    moment_of_glory                 = {  81505, 327193, 1 }, -- For the next 15 sec, you generate an absorb shield for 25% of all damage you deal, and Avenger's Shield damage is increased by 20% and its cooldown is reduced by 75%.
    redoubt                         = {  81494, 280373, 1 }, -- Shield of the Righteous increases your Strength and Stamina by 2% for 10 sec, stacking up to 3.
    refining_fire                   = {  81492, 469883, 1 }, --
    relentless_inquisitor           = {  81506, 383388, 1 }, -- Spending Holy Power grants you 1% haste per finisher for 12 sec, stacking up to 3 times.
    resolute_defender               = {  81471, 385422, 2 }, -- Each 3 Holy Power you spend reduces the cooldown of Ardent Defender and Divine Shield by 1.0 sec.
    righteous_protector             = {  81477, 204074, 1 }, -- Holy Power abilities reduce the remaining cooldown on Avenging Wrath and Guardian of Ancient Kings by 1.5 sec.
    sanctified_wrath                = { 103877,  53376, 1 }, -- Avenging Wrath now causes Judgment to generate 1 additional Holy Power. and its duration is increased by 25%.
    sanctuary                       = { 101927, 379021, 1 }, -- Consecration's benefits persist for 4.0 seconds after you leave it.
    seal_of_charity                 = {  81612, 384815, 1 }, -- When you cast Word of Glory on someone other than yourself, you are also healed for 50% of the amount healed.
    seal_of_reprisal                = {  81629, 377053, 1 }, -- Your Hammer of the Righteous deals 20% increased damage.
    sentinel                        = {  81483, 389539, 1 }, -- Call upon the Light and gain 15 stacks of Divine Resolve, increasing your maximum health by 1% and reducing your damage taken by 2% per stack for 20 sec. After 5 sec, you will begin to lose 1 stack per second, but each 3 Holy Power spent will delay the loss of your next stack by 1 sec. While active, your Judgment generates 1 additional Holy Power, your damage and healing is increased by 20%, and Hammer of Wrath may be cast on any target. Combines with Avenging Wrath.
    shining_light                   = {  81498, 321136, 1 }, -- Every 3 Shields of the Righteous make your next Word of Glory cost no Holy Power. Maximum 2 stacks.
    soaring_shield                  = { 101928, 378457, 1 }, -- Avenger's Shield jumps to 2 additional targets.
    strength_in_adversity           = {  81493, 393071, 1 }, -- For each target hit by Avenger's Shield, gain 5% parry for 15 sec.
    tirions_devotion                = {  81503, 392928, 1 }, -- Lay on Hands' cooldown is reduced by 1.0 sec per Holy Power spent.
    tyrs_enforcer                   = {  81474, 378285, 2 }, -- Your Avenger's Shield is imbued with holy fire, causing it to deal 2,135 Holy damage to all enemies within 5 yards of each target hit.
    uthers_counsel                  = {  81500, 378425, 1 }, -- Your Lay on Hands, Divine Shield, Blessing of Protection, and Blessing of Spellwarding have 30% reduced cooldown.

    -- Lightsmith
    authoritative_rebuke            = {  95232, 469886, 1 }, -- Successfully interrupting an enemy spellcast reduces your Rebuke's cooldown by 1.0 sec. Effect increased by 100% while wielding a Holy Armament.
    blessed_assurance               = {  95235, 433015, 1 }, -- Casting a Holy Power ability increases the damage and healing of your next Hammer of the Righteous by 200%.
    blessing_of_the_forge           = {  95230, 433011, 1 }, -- Avenging Wrath summons an additional Sacred Weapon, and during Avenging Wrath your Sacred Weapon casts spells on your target and echoes the effects of your Holy Power abilities.
    divine_guidance                 = {  95235, 433106, 1 }, -- For each Holy Power ability cast, your next Consecration deals 59,443 damage or healing immediately, split across all enemies and allies.
    divine_inspiration              = {  95231, 432964, 1 }, -- Your spells and abilities have a chance to manifest a Holy Armament for a nearby ally.
    forewarning                     = {  95231, 432804, 1 }, -- The cooldown of Holy Armaments is reduced by 20%.
    hammer_and_anvil                = {  95238, 433718, 1 }, -- Judgment critical strikes cause a shockwave around the target, dealing 39,827 damage at the target's location.
    holy_armaments                  = {  95234, 432459, 1, "lightsmith" }, -- Will the Light to coalesce and become manifest as a Holy Armament, wielded by your friendly target.  Holy Bulwark: While wielding a Holy Bulwark, gain an absorb shield for 15.0% of your max health and an additional 2.0% every 2 sec. Lasts 20 sec. Becomes Sacred Weapon after use.
    laying_down_arms                = {  95236, 432866, 1 }, -- When an Armament fades from you, the cooldown of Lay on Hands is reduced by 15.0 sec and you gain Shining Light.
    rite_of_adjuration              = {  95233, 433583, 1 }, -- Imbue your weapon with the power of the Light, increasing your Stamina by 3% and causing your Holy Power abilities to sometimes unleash a burst of healing around a target. Lasts 1 |4hour:hrs;.
    rite_of_sanctification          = {  95233, 433568, 1 }, -- Imbue your weapon with the power of the Light, increasing your armor by 5% and your primary stat by 2%. Lasts 1 |4hour:hrs;.
    shared_resolve                  = {  95237, 432821, 1 }, -- The effect of your active Aura is increased by 33% on targets with your Armaments.
    solidarity                      = {  95228, 432802, 1 }, -- If you bestow an Armament upon an ally, you also gain its benefits. If you bestow an Armament upon yourself, a nearby ally also gains its benefits.
    tempered_in_battle              = {  95232, 469701, 1 }, -- When you or an ally wielding a Holy Bulwark are healed above maximum health, transfer 100% of the overhealing to your ally. When you or an ally wielding a Sacred Weapon drop below 40% health, redistribute your health immediately and every 1 sec for 4 sec.
    valiance                        = {  95229, 432919, 1 }, -- Consuming Shining Light reduces the cooldown of Holy Armaments by 3.0 sec.

    -- Templar
    bonds_of_fellowship             = {  95181, 432992, 1 }, -- You receive 20% less damage from Blessing of Sacrifice and each time its target takes damage, you gain 4% movement speed up to a maximum of 40%.
    endless_wrath                   = {  95185, 432615, 1 }, -- Calling down an Empyrean Hammer has a 10% chance to reset the cooldown of Hammer of Wrath and make it usable on any target, regardless of their health.
    for_whom_the_bell_tolls         = {  95183, 432929, 1 }, -- Divine Toll grants up to 100% increased damage to your next 3 Judgment when striking only 1 enemy. This amount is reduced by 20% for each additional target struck.
    hammerfall                      = {  95184, 432463, 1 }, -- Shield of the Righteous and Word of Glory calls down an Empyrean Hammer on a nearby enemy. While Shake the Heavens is active, this effect calls down an additional Empyrean Hammer.
    higher_calling                  = {  95178, 431687, 1 }, -- Crusader Strike, Hammer of Wrath and Judgment extend the duration of Shake the Heavens by 1 sec.
    lights_deliverance              = {  95182, 425518, 1 }, -- You gain a stack of Light's Deliverance when you call down an Empyrean Hammer. While Eye of Tyr and Hammer of Light are unavailable, you consume 60 stacks of Light's Deliverance, empowering yourself to cast Hammer of Light an additional time for free.
    lights_guidance                 = {  95180, 427445, 1, "templar" }, -- Eye of Tyr is replaced with Hammer of Light for 12 sec after it is cast.  Hammer of Light: Hammer down your enemy with the power of the Light, dealing 157,254 Holy damage and 78,626 Holy damage up to 4 nearby enemies. Additionally, calls down Empyrean Hammers from the sky to strike 3 nearby enemies for 12,359 Holy damage each. Costs 5 Holy Power.
    sacrosanct_crusade              = {  95179, 431730, 1 }, -- Eye of Tyr surrounds you with a Holy barrier for 15% of your maximum health. Hammer of Light heals you for 15% of your maximum health, increased by 2% for each additional target hit. Any overhealing done with this effect gets converted into a Holy barrier instead.
    sanctification                  = {  95185, 432977, 1 }, -- Casting Judgment increases the damage of Empyrean Hammer by 10% for 10 sec. Multiple applications may overlap.
    shake_the_heavens               = {  95187, 431533, 1 }, -- After casting Hammer of Light, you call down an Empyrean Hammer on a nearby target every 2 sec, for 8 sec.
    undisputed_ruling               = {  95186, 432626, 1 }, -- Hammer of Light applies Judgment to its targets, and increases your Haste by 12% for 6 sec. Additionally, Eye of Tyr grants 3 Holy Power.
    unrelenting_charger             = {  95181, 432990, 1 }, -- Divine Steed lasts 2 sec longer and increases your movement speed by an additional 30% for the first 3 sec.
    wrathful_descent                = {  95177, 431551, 1 }, -- When Empyrean Hammer critically strikes, 100% of its damage is dealt to nearby enemies. Enemies hit by this effect deal 5% reduced damage to you for 8 sec.
    zealous_vindication             = {  95183, 431463, 1 }, -- Hammer of Light instantly calls down 2 Empyrean Hammers on your target when it is cast.
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
        duration = function() return 12 + ( talent.consecration_in_flame.enabled and 2 or 0 ) + ( talent.sanctuary.enabled and 4 or 0 ) end,
        tick_time = 1,
        type = "Magic",
        max_stack = 1,
        generate = function( c, type )
            local cons = GetPlayerAuraBySpellID( 188370 )

            if type == "buff" and cons then
                local expires = 0
                local duration = class.auras.consecration.duration

                if cons.expirationTime == 0 then
                    expires = action.consecration.lastCast + duration
                    if talent.undisputed_ruling.enabled then expires = max( expires, action.hammer_of_light.lastCast + duration ) end
                else
                    expires = cons.expirationTime
                end

                c.expires = expires
                c.applied = expires - duration
                c.duration = duration
                c.count = 1
                c.caster = "player"
                return
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
        max_stack = 1,
        dot = "buff",
        shared = "player",
        friendly = true
    },
    divine_guidance = {
        id = 460822,
        duration = 30,
        max_stack = 50
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
        duration = function () return 4 * ( 1 + ( conduit.lights_barding.mod * 0.01 ) ) + ( level > 39 and 2 or 0 ) + ( 2 * talent.unrelenting_charger.rank ) end,
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
        duration = function() return talent.holy_reprieve.enabled and 20 or 30 end,
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
        id = function() return QueenGlyphed( 212641 ) and 212641 or 86659 end,
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
    refining_fire = {
        id = 469882,
        duration = 5,
        max_stack = 1
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

-- The War Within
spec:RegisterGear( "tww2", 229244, 229242, 229243, 229245, 229247 )
spec:RegisterAura( "luck_of_the_draw", {
    -- https://www.wowhead.com/ptr-2/spell=1218114/luck-of-the-draw
    -- Each time you take damage you have a chance to activate Luck of the Draw! causing you to cast Guardian of Ancient Kings for 4.0 sec. Your damage done is increased by 15% for 10 sec after Luck of the Draw! activates.
        id = 1218114,
        duration = 10,
        max_stack = 1
} )

-- Legacy
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
        if IsSpellKnownOrOverridesKnown( 432472 ) then applyBuff( "sacred_weapon_ready" )
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
        if talent.divine_guidance.enabled then
            addStack( "divine_guidance", nil, 1 )
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
            if talent.refining_fire.enabled then applyDebuff( "target", "refining_fire" ) end
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
        cooldown = 5,
        recharge = 5,
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
        -- charges = 1,
        cooldown = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( 1 - 0.15 * talent.uthers_counsel.rank ) end,
        -- recharge = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( 1 - 0.3 * talent.uthers_counsel.rank ) end,
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
            if talent.righteous_protection.enabled then
                removeBuff( "dispellable_poison" )
                removeBuff( "dispellable_disease" )
            end
        end,
    },

    -- Talent: Blesses a party or raid member, granting immunity to magical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Protection.
    blessing_of_spellwarding = {
        id = 204018,
        cast = 0,
        -- charges = 1,
        cooldown = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( 1 - 0.15 * talent.uthers_counsel.rank ) end,
        -- recharge = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( 1 - 0.15 * talent.uthers_counsel.rank ) end,
        gcd = "spell",
        school = "holy",

        spend = 0.15,
        spendType = "mana",

        talent = "blessing_of_spellwarding",
        startsCombat = false,
        nodebuff = "forbearance",
		toggle = "defensives",

        usable = function()
            if not settings.bosp_filter then return true end

            local zone = state.instance_id
            local npcid = target.npcid or -1
            local t = debuff.casting

            -- Only use on a spell targeted at the player.
            if not t.up then
                return false, "target is not casting"
            end
            if not state.target.is_dummy and not class.spellFilters[ t.v1 ] then
                return false, "spell[" .. t.v1 .. "] in zone[" .. zone .. "] by npc[" .. npcid .. "] is not on filter"
            end
            if not UnitIsUnit( "player", t.caster .. "target" ) then
                return false, "player is not target of cast"
            end
            return true
        end,
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
            if buff.divine_guidance.up then removeBuff( "divine_guidance" ) end
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

        talent = "auras_of_the_resolute",
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
        cooldown = function () return 6 * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste end,
        recharge = function () return talent.improved_crusader_strike.enabled and ( 6 * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste ) or nil end,
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
        nodebuff = function() if not talent.lights_revocation.enabled then return "forbearance" end end,

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
        cooldown = function() return 60 * ( 1 - 0.33 * talent.inmost_light.rank ) end,
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

            if talent.undisputed_ruling.enabled then gain( 3, "holy_power" ) end
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
        id = function() return QueenGlyphed( 212641 ) and 212641 or 86659 end,
        cast = 0,
        cooldown = function () return 300 - ( conduit.royal_decree.mod * 0.001 ) end,
        gcd = "off",
        school = "holy",

        talent = "guardian_of_ancient_kings",
        startsCombat = false,
        nopvptalent = "guardian_of_the_forgotten_queen",

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
        cooldown = 300,
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
        cooldown = function() return 45 - ( 15 * talent.fist_of_justice.rank ) end,
        gcd = "spell",
        school = "holy",

        spend = 0.035,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "hammer_of_justice" )
        end,
    },

        -- Hammer down your enemy with the power of the Light, dealing $429826s1 Holy damage and ${$429826s1/2} Holy damage up to 4 nearby enemies. ; Additionally, calls down Empyrean Hammers from the sky to strike $427445s2 nearby enemies for $431398s1 Holy damage each.;
        hammer_of_light = {
            id = 427453,
            known = 387174,
            flash = 387174,
            cast = 0.0,
            cooldown = 0.0,
            gcd = "spell",

            spend = function()
                if buff.divine_purpose.up or buff.hammer_of_light_free.up then return 0 end
                return 3
            end,
            spendType = "holy_power",

            startsCombat = true,
            buff = function() return buff.hammer_of_light_free.up and "hammer_of_light_free" or "hammer_of_light_ready" end,

            handler = function ()
                removeBuff( "divine_purpose" )
                if talent.undisputed_ruling.enabled then
                    spec.abilities.consecration.handler()
                    applyBuff( "shield_of_the_righteous", buff.shield_of_the_righteous.remains + 4.5 )
                end


                if buff.hammer_of_light_free.up then
                    removeBuff( "hammer_of_light_free" )
                else
                    removeBuff( "hammer_of_light_ready" )

                    if buff.lights_deliverance.stack_pct == 100 then
                        removeBuff( "lights_deliverance" )
                        applyBuff( "hammer_of_light_free" )
                    end
                end
            end,

            bind = { "wake_of_ashes", "eye_of_tyr" }
        },

    -- Talent: Hammers the current target for 1,302 Physical damage. While you are standing in your Consecration, Hammer of the Righteous also causes a wave of light that hits all other targets within 8 yds for 226 Holy damage. Generates 1 Holy Power.
    hammer_of_the_righteous = {
        id = 53595,
        cast = 0,
        charges = 2,
        cooldown = 5,
        recharge = 5,
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
        -- charges = 1,
        cooldown = 7.5,
        -- recharge = 7.5,
        gcd = "spell",
        school = "holy",

        talent = "hammer_of_wrath",
        startsCombat = false,

        usable = function () return target.health_pct < 20 or ( level > 57 and ( buff.avenging_wrath.up or buff.sentinel.up ) ) or buff.hammer_of_wrath_hallow.up or buff.negative_energy_token_proc.up, "requires low health, avenging_wrath, or ashen_hallow" end,
        handler = function ()
            gain( 1, "holy_power" )

            if talent.zealots_paragon.enabled then
                if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + ( 0.5 * talent.zealots_paragon.rank ) end
                if buff.sentinel.up then buff.sentinel.expires = buff.sentinel.expires + ( 0.5 * talent.zealots_paragon.rank ) end
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
        cooldown = function() return 60 * ( 1 - 0.2 * talent.forewarning.rank ) end,
        charges = 2,
        recharge = function() return 60 * ( 1 - 0.2 * talent.forewarning.rank ) end,
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
        charges = function () if talent.crusaders_judgment.enabled then return 2 end end,
        cooldown = function() return 11 - ( 0.5 * talent.seal_of_alacrity.rank ) end,
        recharge = function () return talent.crusaders_judgment.enabled and ( 11 - ( 0.5 * talent.seal_of_alacrity.rank ) ) or nil end,
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
        id = function() if talent.empyreal_ward.enabled then
            return 471195 end
            return 633
        end,
        cast = 0,
        cooldown = function () return 600 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * ( talent.uthers_counsel.enabled and 0.85 or 1 ) end,
        gcd = "off",
        school = "holy",

        talent = "lay_on_hands",
        startsCombat = false,

        toggle = "defensives",
        nodebuff = "forbearance",

        handler = function ()
            gain( health.max, "health" )
            if talent.tirions_devotion.enabled then gain( 0.05 * mana.max, "mana" ) end
            -- applyDebuff( "", "forbearance" )
            if talent.empyreal_ward.enabled then applyBuff( "empyrael_ward" ) end
        end,

        copy = { 633, 471195 }
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
            if talent.authoritative_rebuke.enabled and debuff.casting.up then reduceCooldown( "rebuke", ( buff.sacred_weapon.up or buff.holy_bulwark.up ) and 2 or 1 ) end
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
            return 3
        end,
        spendType = "holy_power",

        startsCombat = true,

        usable = function() return equipped.shield, "requires a shield" end,

        handler = function ()
            removeBuff( "bulwark_of_righteous_fury" )
            removeBuff( "divine_purpose" )
            removeDebuff( "target", "judgment" )

            if talent.faiths_armor.enabled then applyBuff( "faiths_armor" ) end
            if talent.redoubt.enabled then addStack( "redoubt", nil, 3 ) end
            if talent.shining_light.enabled then
                addStack( "shining_light", nil, 1 )
                if buff.shining_light.stack == 3 then
                    addStack( "shining_light_full" )
                    removeBuff( "shining_light" )
                end
            end

            if set_bonus.tww2 >= 4 and buff.luck_of_the_draw.up then
                gain( 1, "holy_power" )
                buff.luck_of_the_draw.expires = buff.luck_of_the_draw.expires + 0.5
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
            return 3
        end,
        spendType = "holy_power",

        startsCombat = false,

        handler = function ()
            spend( 0.1 * mana.max, "mana" )

            if buff.royal_decree.up then removeBuff( "royal_decree" )
            elseif buff.divine_purpose.up then removeBuff( "divine_purpose" )
            elseif buff.bastion_of_light.up then removeStack( "bastion_of_light" )
            else removeBuff( "shining_light_full" ) end

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

local wog_str = Hekili:GetSpellLinkWithTexture( spec.abilities.word_of_glory.id )

spec:RegisterSetting( "wog_health", 40, {
    name = format( "%s Health Threshold", wog_str ),
    desc = format( "If set above zero, %s may be recommended when your health falls below this percentage.", wog_str ),
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterStateExpr( "wog_health", function ()
    return settings.wog_health or 0
end )

local loh_str = Hekili:GetSpellLinkWithTexture( spec.abilities.lay_on_hands.id )

spec:RegisterSetting( "loh_health", 30, {
    name = format( "%s Health Threshold", loh_str ),
    desc = format( "If set above zero, %s may be recommended when your health falls below this percentage.", loh_str ),
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterStateExpr( "loh_health", function ()
    return settings.loh_health or 0
end )

local ad_str = Hekili:GetSpellLinkWithTexture( spec.abilities.ardent_defender.id )

spec:RegisterSetting( "ad_damage", 40, {
    name = format( "%s Damage Threshold", ad_str ),
    desc = format( "If set above zero, %s may be recommended when you take this percentage of your maximum health in damage over 5 seconds.\n\n"
        .. "It is better to learn to use your defensive abilities proactively before taking damage, but this setting may help you learn (and prevent death).\n\n"
        .. "By default, your |cFFFFD100Defensives|r toggle must also be enabled.", ad_str ),
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterStateExpr( "ad_damage", function ()
    return ( settings.ad_damage or 0 ) * health.max * 0.01
end )

local goak_str = Hekili:GetSpellLinkWithTexture( spec.abilities.guardian_of_ancient_kings.id )

spec:RegisterSetting( "goak_damage", 40, {
    name = format( "%s Damage Threshold", goak_str ),
    desc = format( "If set above zero, %s may be recommended when you take this percentage of your maximum health in damage over 5 seconds.\n\n"
        .. "It is better to learn to use your defensive abilities proactively before taking damage, but this setting may help you learn (and prevent death).\n\n"
        .. "By default, your |cFFFFD100Defensives|r toggle must also be enabled.", goak_str ),
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterStateExpr( "goak_damage", function ()
    return ( settings.goak_damage or 0 ) * health.max * 0.01
end )

local ds_str = Hekili:GetSpellLinkWithTexture( spec.abilities.divine_shield.id )

spec:RegisterSetting( "ds_damage", 60, {
    name = format( "%s Damage Threshold", ds_str ),
    desc = format( "If set above zero, %s may be recommended when you take this percentage of your maximum health in damage over 5 seconds.\n\n"
        .. "It is better to learn to use your defensive abilities proactively before taking damage, but this setting may help you learn (and prevent death).\n\n"
        .. "If you are actively tanking for a group and use %s, you will lose threat on all enemies and need to taunt to regain it.\n\n"
        .. "By default, your |cFFFFD100Defensives|r toggle must also be enabled.", ds_str, spec.abilities.divine_shield.name ),
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterStateExpr( "ds_damage", function ()
    return ( settings.ds_damage or 0 ) * health.max * 0.01
end )

local bosp_str = Hekili:GetSpellLinkWithTexture( spec.abilities.blessing_of_spellwarding.id )

spec:RegisterSetting( "bosp_filter", false, {
    name = format( "%s: Cast Filter", bosp_str ),
    desc = format( "If checked, %s may be recommended |cffff0000ONLY|r when your target is casting specific spells on you.\n\n"
        .. "The spell filter is updated behind the scenes for each season and raid tier.", bosp_str ),
    type = "toggle",
    width = "full",
} )

local sent_str = Hekili:GetSpellLinkWithTexture( 389539 )

spec:RegisterSetting( "sentinel_def", false, {
    name = strformat( "%s: Use Defensively", sent_str ),
    desc = format( "If enabled, %s is placed on the |cFFFFD100Defensives|r toggle by default (rather than |cFFFFD100Cooldowns|r) and is recommended based on your %s Damage Threshold Setting.",
        sent_str, goak_str ),
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

    potion = "tempered_potion",

    package = "Protection Paladin",
} )


spec:RegisterPack( "Protection Paladin", 20250425, [[Hekili:nZvBVnUns4FlbfWRn6ghl5KSzxeBG2E4W1f9wS4sl2pCOwM2I2MnYs(eLs2ae4F73mK6fsjsjzhVPlqrtS1OHZB8HZmC2mZz2Vp7oFscD2NCh5E1OlDVAOJJ71UZUl5PD0z3TJS8EYA4xcjBH))NJJsOltyrH7N)zsaXNfI08uqeXhzfpknEjq3MKKD8pCXfRzjBsxmCz02l4STPbe8vxgtwLGFE5fZUBrkli5xdNTWOC48(z3rst2efp7U7yB)fGZmFFQKCkF5S7qYpF0LN7E1h2p)FY(6(5)C0DFE)8vaBPX7)4(pMtXiKcKjW))PWLLpYf(p4r)umW4K9Z)h0v0qF4DNNUdfj)mkV8CNrN74829ZHF6k(PZ5UUz)ez(FiOhw74OTzlv(Ro69Np6gGK)dLNefd0SLLWwtKwssMfnGXt0EdK54pVm7N3uObsrRK4BKsMRBlIX7o3DmqYVVbE(xiGo(fWdHorCT5IOb6ksAqc8RFseDifUz3ftxKEp4APHKfbu)z)8SeWzHuu(nfeVKee4j)GhYzj)9KbrLQoYIXhdlwgff4h9yih5WLhdhsIzH3ttem4QJHb8esOpj2hya8GDXuiiFbPUDZN(qKGdK0yIjZxoHbS1Bs4E)vQ)6TqGyfshRskjEjjK6brsX1P8svkxgfYPWgo5N0ORQwhTdukAs57(ajMHpf)TGu4hoa)IzW2kgPWaomXz4gc3l3JSFEV9ZR8mWuLmKe(KN)oU4593p)mfQCnq1ZpRXMC2p0pnoBxZ0jASWafdKSP(sLtRqh1di84a2GhpicDRF66d2g5A0g52GnYK2x3gzYsQzJmAbM2Mr0GjY5GmrjQBgZJ9vSyLgd(okSDkHeVg22nSs0U0D6winXeMVh9b4jdj((8H0VI4tYhx9zmPI(URm)40D23JvDpibET1SW1EpcgOnM2cAu1wKUA1q93vBz3fLJ2vfRQKhG)2eBIPBjSqqZVfoNjtdbstyBPcT2zKWjoOCX2gHQMx0kV1brXpzARUnNcFdJg4JVAYgQxmASOrPCPZzScMg7bMa)jiW0UK2mmsTOiA0QgJl6OYvDbHlasbXt4hXL(Dh0sxWAWWDtjJxXGd3cIIYWYloAWq4C(RKag5cbH7LdYxtayHH0yVykNfWOHlPIWISDtwyrdhRMjzovIBYbHgwBd6(5Gn0jhpPjVXkuk80S9xoQaFO9fX1mWEHtoMs8FQy7TnjzGkIutRieVJ)cxXM0qUez04Ey2n3xd7MJzW(xn7MRmMViBMgI5lZmP0kUCdcDW1GVxLcqkq(qIh5jrQq7Y6L(d3s(k8spTmGMd6GRNHq(k7J2q2Uf2iLVDXBvmLQHnMT2cI5Bi3tfqyBOOXIRJIQBnRtCnak6tInQjpfRZOHxzogaKMsRwfjV5dsG4Gn7wdaREU(emrbWSDv5r0Ka8unGv(P879apMhs1WmwjIb6vqwgUY6uMpbrEYxWcjRuTA9KPAcLJI5gEdohJhrbdLhiyA59cq2rVmzY(5w9vnifhu5TtwFAuCPnrZtAGspgeww47MOiZ5rivJ9eBj1oF3Y5MMoBSTxruwBmBx2bTPWU01qLHPObnAfOYyLB(XKh7)7F5lqq)LFEaFhbQZJhLaLZraDyB6YnYFBxe4yGvE)8hHY8IsbaGhXdrrwcQn8PnuSy0C6uTWTP9AGJO8LRlOWP8Cm6jk4jVDrpI1u)J7NNJJ4P(9tLr6L4MFBDVIuMmK)WH5EalkN5tLEgd(O3IM2OaPfa)DHQAZhLebwt4NKIpbAp(cg4m6rdbDMlDTadfDvqzDoyFjuxJ3IOWu(qyvEKe)OOZaECkHdjD56D5ULhQpTIlTtVJmoO3X5vrx6nwbno7GuYVTbGNk8L3Fahw31K9H0UfcOeDpnaStID3LA3Q04NkG5NKtVQF8wrbdMoP3zutoOwwZSy1mhJD6kCpyGDhvB9ACezzrJHAUfVGqYTxCB5bHuFpcNdfylZ2)qKGBZnKwZ0ZuAf1cjCAjxQxtXmFTKIRq6APm6tG052vPBzCkN4dMroKn89uH4zppib3Yk9TidMSnbiQLLUUHm1EImH0VM4rI3sKDbb4dNSmg0)hPKDrHkGrYSvvFyrMQ9n(u1esVUztIoGBZfKxTFdID95AGma8A1EQugPAQPkoVtLw1gluHo7W65O00vSquQXY5RNzPP9Zhc4zdgUmbitrX0YjHpWckLbJf8yhgSEmHWgNH2j9v51DnrVyJA(c3ounNjPZogsZfovAoQ)8U4tCBS4OtfcX4I0sSQkDcQ1T9(59AlT1rCDBSmQtLq6EicPbGxx7Dr8SUx)OPik79i8me0ReQwxeRGH7AhaQFH8Xc3gXtK5XPLdIXEwJ9kkR6(oANZY1Qi)rDZIpnG9anUlvw7wf6RROpnH1mEKkwELarD48XoMpIOs1w6VJwR6RgcvH2wYYaSWIZku6MuzjR5zxwBtrHhnVl8ngvQFOQuhxHxPOTIxk0ThJIfE)Ig4pw7s9QgKxr1TVD)LeXmULU8B0I2KkzFBzL6iusSQYfFIS5gTGcRx3zI29o34fvLqcVx0IKEfyzg3ooS4U80QTDOpKiYswsURTasml5MDPXqn)Y4nfFEd14z76awO04nbacSb1h(CLUu8F)x07zbS)eN(GLrquyOF(usWY7Pq24smNXXUoKf(IGuaFHkIJeSIpC)8FjLNGJvWUyweyXyyoiGpz)8uonNRYosefR02jOkBGWvusskKCMwrP0eSHu8HlI478KYHWXAp8GscGKV2TmreE8y0Ap5x9Y8fkhDzeBOP9N2tdiB)gKAkjWt0LDn4b1ynwi4DWf2NSLSM6DLSwCFE2xKd6xCJeIbwb2dlNxfDLyDkglqe3wgS9MHuEVWoRrwMDqg8P)i5Lwwv11Ebu1TJ20bDBDe5(VN0oR8f1u7aGcHKdiPEC4nGLmORo3V3ma5YpQV2bO7GIr8)EsTQSOO2zpDUk4lbrBYWxk5xa5jVOqi1MqF(SSXGaohLJpmBc2g9EaNGehkIEUtmWvST7IIbMUcHgFtXid9gi9q6)lfQA1hBJpEDzKuaKvm7zyLEWH9a07h)nqNHtd)aachfcRM4XVj)sd1hBJ3iBG8BSmvhWJ7781bDKPQtDIfgxHKoX86d(snMBKKoXCdt7Ibr3enFtzFRm2Wy8yWQC0Y9XY(oW4gd)Q9ynP96xFM(cd7SX8tYgg7s(X58(gZ(wz8XUzPJY9XY(oW4JcsD)hnG2N9w8ddS3TDxL42IAYpLtGMT80X4cwoUD3JzwAGanz90XyHZ5xf(fKtxRp61OzhNK3iOie6S7(HFaQKOJZX(IGOfxOEJIx8tcg)zzvsp9Bi7VyNCI5ZVBqmpf8T3)rCP(JDsXxo72YsOWz3gu()nu2l8jNXGFdYTy)8Zbb)g)XV7sXSPJVTup4dlsQ4hNCbMqJO0qitQeguhKCMpBLEI)FLpFOF0eDAt0SzsQoDNgjsVyEZ0OwqVzkYN2P3Itv3KmFF5ip9wXC5oX5TSvtmVVUNDS7E9pZ(Pgp)CdaqtN0aQ6GNF(mZhX9surxvv01SkwxluuX66FPkAqlM2G6RQHvMp8pwOJyiN4FubQFt1zUxQZk)RLOvAZxjE7KMdk3oL5ZhNI4xO186b8OROX5DE6exWezEkNF(56DlE67UQ(xdf5yuy0VLkZ0iRtcLtlxSLX3QYSfJVEFtVFw3nV1bK6(4eao1z0GbM5PYD(v3SzPRytNm2mZQoJW2vWNFUiQ1IWpz8iDWs1fIf(q09up6xHIgXw7GlImur04jpw4Qu(ryHlMfzBVyM0n9g1qXY9halSyZeWdYc371ABn71VEt0Mm65Nn38mWZcMPV)6ZOfdKT(Mkc)m0oslSrRlG47w24GBlBk5HzjZ(EJTGCGf5qRBisVSTEo2lpaOExBMw0NXEN13sNAYKUM6sJUIv0HMSVUO7m20fRSwn61GWR0hT)of)82NHsB9Mc2K1)7efOYA2IvVOjF)DkYQ9IRYUWYw3PcwMFwo8UfNxRndeYSfZgXcXj11hP9BNKno7g5BLr6RalVPXy)w3In)wgF9BDGCgSqI2bA1hy9BDgchfRnO636Au0lFxXP7Qt(9KRW06AEi0h0RLlf9qxtNmRYcJtz(0rh1c2WrK9pR9P(uXu3YeFobKVZm66lM9w8OZx558(qTjnRb9K79nmd496RC43pAyEFNo5kOuHtUjFGmHKVNhp7tSlOdZ1C7odHVOvhwVdXrCWQzNuKtD8sRBrpWJo6wnmJLPH3YawdL60R0(F7yJctLjcPmGPPjPUxxNI6EDtFMyw2SmCpfNjUWWSN1Tv82XzoUgQTsrqwOnqsV(RFLjw6uiaU2faSW1yQFkS64yCfa5w9HYsz7yG8ljhi1w3vORghF6jxzoWrBaZqwOnAAt0M2zauqMzuLbKgq0m895PaDTn7xVo0CalOBvM3zJ0O0ZJUUFUPPC(GbOSO0TmiZhLxsD4b7LfpnXCQN2K4UAISNBCV2Mj5df5Q)lDN74bwZ2VZWx)niegWWEXsH7blfM89hrvavrOoRYWa3LAvAyWF7zOnUtUeQHQtMf44uiVKwhxZx8EYoeRDiBo6suJrAQ1nTSqcdncRx)2MqxSRZngpuIVBEUCTM7ALqVoeICK(WdWEywq1UDnrJrkZI08bU6x2wjj5xtcqskN6XsOBZU)eZ)jSOqAn8x)Ig5k)TI)4eKFVmIJQ6B)pNbtC6z82hWt91B1XKlhH120aRC1URp97noVRl1wMb49CzNPdoeL1TnL190PSoA363jszf)7lD5SpD91I5HB2))d]] )