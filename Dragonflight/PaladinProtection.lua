-- PaladinProtection.lua
-- September 2022

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local FindUnitBuffByID = ns.FindUnitBuffByID

local spec = Hekili:NewSpecialization( 66 )

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Paladin
    afterimage                      = { 81613, 385414, 1 }, -- After you spend 20 Holy Power, your next Word of Glory echoes onto a nearby ally at 30% effectiveness
    aspiration_of_divinity          = { 81622, 385416, 2 }, -- Your Blessed Hammer now also grants you 1% increased Strength for 6 sec. Multiple applications may overlap.
    avenging_wrath                  = { 81606, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, and activating all the effects learned for Avenging Wrath for 20 sec.
    blessing_of_freedom             = { 81600, 1044  , 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    blessing_of_protection          = { 81616, 1022  , 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Spellwarding.
    blessing_of_sacrifice           = { 81614, 6940  , 1 }, -- Blesses a party or raid member, reducing their damage taken by 30%, but you suffer 100% of damage prevented. Last 12 sec, or until transferred damage would cause you to fall below 20% health.
    blinding_light                  = { 81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within 10 yards, causing them to wander disoriented for 6 sec. Non-Holy damage will break the disorient effect.
    cavalier                        = { 81605, 230332, 1 }, -- Divine Steed now has 2 charges.
    divine_purpose                  = { 81618, 223817, 1 }, -- Holy Power abilities have a 15% chance to make your next Holy Power ability free and deal 15% increased damage and healing.
    divine_steed                    = { 81632, 190784, 1 }, -- Leap atop your Charger for 3 sec, increasing movement speed by 100%. Usable while indoors or in combat.
    fist_of_justice                 = { 81602, 234299, 2 }, -- Each Holy Power spent reduces the remaining cooldown on Hammer of Justice by 1 sec.
    golden_path                     = { 81610, 377128, 1 }, -- Consecration heals you and 5 allies within it for 110 every 0.9 sec.
    hallowed_ground                 = { 81509, 377043, 1 }, -- Consecration's damage is increased by 10%.
    holy_aegis                      = { 81609, 385515, 2 }, -- Armor and critical strike chance increased by 2%.
    holy_avenger                    = { 81618, 105809, 1 }, -- Your Holy Power generation is tripled for 20 sec.
    improved_blessing_of_protection = { 81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection and Blessing of Spellwarding by 60 sec.
    incandescence                   = { 81628, 385464, 1 }, -- Each Holy Power you spend has a 5% chance to cause your Consecration to flare up, dealing 911 Holy damage to up to 5 enemies standing within it.
    judgment_of_light               = { 81608, 183778, 1 }, -- Judgment causes the next 25 successful attacks against the target to heal the attacker for 89.
    obduracy                        = { 81627, 385427, 1 }, -- Speed and Avoidance increased by 2%.
    of_dusk_and_dawn                = { 81624, 385125, 1 }, -- When you reach 5 Holy Power, you gain Blessing of Dawn. When you reach 0 Holy Power, you gain Blessing of Dusk. Blessing of Dawn Damage and healing increased by 9%, and Holy Power-spending abilities dealing 8% additional increased damage and healing for 20 sec. Blessing of Dusk Damage taken reduced by 4%, armor increased by 10%, and Holy Power generating abilities cool down 10% faster for 20 sec.
    rebuke                          = { 81604, 96231 , 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for 4 sec.
    recompense                      = { 81607, 384914, 1 }, -- After your Blessing of Sacrifice ends, 50% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing. This effect's bonus damage cannot exceed 30% of your maximum health and its bonus healing cannot exceed 100% of your maximum health.
    repentance                      = { 81598, 20066 , 1 }, -- Forces an enemy target to meditate, incapacitating them for 1 min. Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    sacrifice_of_the_just           = { 81607, 384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by 60 sec.
    sanctified_wrath                = { 81620, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, and activating all the effects learned for Avenging Wrath for 20 sec.
    seal_of_alacrity                = { 81619, 385425, 2 }, -- Haste increased by 2%.
    seal_of_clarity                 = { 81612, 384815, 2 }, -- Spending Holy Power has a 5% chance to reduce the Holy Power cost of your next Word of Glory or Shield of the Righteous by 1.
    seal_of_mercy                   = { 81611, 384897, 2 }, -- Golden Path strikes the lowest health ally within it an additional time for 50.0% of its effect.
    seal_of_might                   = { 81621, 385450, 2 }, -- During Avenging Wrath, your Mastery is increased by 4%.
    seal_of_order                   = { 81623, 385129, 1 }, -- In the Dawn, your Holy Power-spending abilities deal 8% increased damage and healing. In the Dusk, your armor is increased by 10% and your Holy Power generating abilities cool down 10% faster.
    seal_of_reprisal                = { 81629, 377053, 2 }, -- Your Blessed Hammer deals 10% increased damage.
    seal_of_the_crusader            = { 81626, 385728, 2 }, -- Your attacks have a chance to cause your target to take 3% increased Holy damage for 5 sec.
    seal_of_the_templar             = { 81631, 377016, 1 }, -- While mounted on your Charger or under the effects of Crusader Aura, the ranges of Hammer of the Righteous, Rebuke, and Hammer of Justice are increased by 3 yards.
    seasoned_warhorse               = { 81631, 376996, 1 }, -- Increases the duration of Divine Steed by 1 sec.
    seraphim                        = { 81620, 152262, 1 }, -- The Light magnifies your power for 15 sec, granting 8% Haste, Critical Strike, and Versatility, and 8% Mastery.
    touch_of_light                  = { 81628, 385349, 1 }, -- Your spells and abilities have a chance to cause your target to erupt in a blinding light dealing 759 Holy damage or healing an ally for 988 health.
    turn_evil                       = { 81630, 10326 , 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to 40 sec. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbreakable_spirit              = { 81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, Ardent Defender, and Lay on Hands by 30%.
    zealots_paragon                 = { 81625, 391142, 1 }, -- Hammer of Wrath and Judgment deal 10% additional damage and extend the duration of Sentinel by 0.5 sec.

    -- Protection
    ardent_defender                 = { 81481, 31850 , 1 }, -- Reduces all damage you take by 20% for 8 sec. While Ardent Defender is active, the next attack that would otherwise kill you will instead bring you to 20% of your maximum health.
    auras_of_swift_vengeance        = { 81601, 385639, 1 }, -- Learn Retribution Aura and Crusader Aura:  Retribution Aura: When any party or raid member within 40 yards dies, you gain Avenging Wrath for 12 sec. When any party or raid member within 40 yards takes more than 50% of their health in damage in a single hit, you gain Seraphim for 4 sec. This cannot occur more than once every 30 sec.  Crusader Aura: Increases mounted speed by 20% for all party and raid members within 40 yards.
    auras_of_the_resolute           = { 81599, 385633, 1 }, -- Learn Concentration Aura and Devotion Aura: Concentration Aura: Interrupt and Silence effects on party and raid members within 40 yards are 30% shorter.  Devotion Aura: Party and raid members within 40 yards are bolstered by their devotion, reducing damage taken by 3%.
    avengers_shield                 = { 81502, 31935 , 1 }, -- Hurls your shield at an enemy target, dealing 1,526 Holy damage, interrupting and silencing the non-Player target for 3 sec, and then jumping to 4 additional nearby enemies. Shields you for 8 sec, absorbing 25% as much damage as it dealt. Deals 179 additional damage to all enemies within 5 yards of each target hit.
    avenging_wrath_might            = { 81483, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, and activating all the effects learned for Avenging Wrath for 20 sec.
    barricade_of_faith              = { 81501, 385726, 1 }, -- When you use Avenger's Shield, your block chance is increased by 10% for 10 sec.
    bastion_of_light                = { 81488, 378974, 1 }, -- Your next 3 casts of Shield of the Righteous or Word of Glory cost no Holy Power.
    blessed_hammer                  = { 81469, 204019, 1 }, -- Throws a Blessed Hammer that spirals outward, dealing 306 Holy damage to enemies and reducing the next damage they deal to you by 659. Generates 1 Holy Power.
    blessing_of_spellwarding        = { 90062, 204018, 1 }, -- Blesses a party or raid member, granting immunity to magical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Protection.
    bulwark_of_order                = { 81499, 209389, 2 }, -- Avenger's Shield also shields you for 8 sec, absorbing 25% as much damage as it dealt, up to 30% of your maximum health.
    bulwark_of_righteous_fury       = { 81491, 386653, 1 }, -- Avenger's Shield increases the damage of your next Shield of the Righteous by 20% for each target hit by Avenger's Shield, stacking up to 5 times, and increases its radius by 6 yds.
    cleanse_toxins                  = { 81507, 213644, 1 }, -- Cleanses a friendly target, removing all Poison and Disease effects.
    consecrated_ground              = { 81492, 204054, 1 }, -- Your Consecration is 15% larger, and enemies within it have 50% reduced movement speed.
    consecration_in_flame           = { 81470, 379022, 1 }, -- Consecration lasts 2 sec longer and its damage is increased by 20%.
    crusaders_judgment              = { 81473, 204023, 1 }, -- Judgment now has 2 charges, and Grand Crusader now also reduces the cooldown of Judgment by 3 sec.
    crusaders_resolve               = { 81493, 380188, 1 }, -- Enemies hit by Avenger's Shield deal 2% reduced damage to you for 10 sec. Multiple applications may overlap, up to a maximum of 3.
    divine_resonance                = { 81479, 386738, 1 }, --
    divine_toll                     = { 81496, 375576, 1 }, -- Instantly cast Avenger's Shield on up to 5 targets within 30 yds. Generates 1 Holy Power per target hit.
    eye_of_tyr                      = { 81497, 387174, 1 }, -- Releases a blinding flash from your shield, causing 1,435 Holy damage to all nearby enemies within 8 yds and reducing all damage they deal to you by 25% for 9 sec.
    faith_in_the_light              = { 81480, 379043, 2 }, -- Casting Word of Glory grants you an additional 5% block chance for 5 sec.
    faiths_armor                    = { 81495, 379017, 1 }, -- Shield of the Righteous grants 10% additional armor.
    ferren_marcuss_fervor           = { 81482, 378762, 2 }, -- Avenger's Shield deals 10% increased damage to its primary target.
    final_stand                     = { 81504, 204077, 1 }, -- During Divine Shield, all targets within 15 yards are taunted.
    focused_enmity                  = { 81472, 378845, 1 }, -- Avenger's Shield deals 100% increased damage but only strikes one target.
    gift_of_the_golden_valkyr       = { 81484, 378279, 2 }, -- Each enemy hit by Avenger's Shield reduces the remaining cooldown on Guardian of Ancient Kings by 0.5 sec. When you drop below 30% health, you become infused with Guardian of Ancient Kings for 4 sec. This cannot occur again for 45 sec.
    grand_crusader                  = { 81487, 85043 , 1 }, -- When you avoid a melee attack or use Blessed Hammer, you have a 20% chance to reset the remaining cooldown on Avenger's Shield and increase your Strength by 2% for 8 sec. Grants a charge of Judgment.
    greater_judgment                = { 81603, 231663, 1 }, -- Judgment causes the target to take 20% increased damage from your next Holy Power ability.
    guardian_of_ancient_kings       = { 81490, 86659 , 1 }, -- Empowers you with the spirit of ancient kings, reducing all damage you take by 50% for 8 sec.
    hammer_of_the_righteous         = { 81469, 53595 , 1 }, -- Hammers the current target for 1,532 Physical damage. While you are standing in your Consecration, Hammer of the Righteous also causes a wave of light that hits all other targets within 8 yds for 242 Holy damage. Generates 1 Holy Power.
    hammer_of_wrath                 = { 81510, 24275 , 1 }, -- Hurls a divine hammer that strikes an enemy for 3,038 Holy damage. Only usable on enemies that have less than 20% health. Generates 1 Holy Power.
    hand_of_the_protector           = { 81475, 315924, 1 }, -- Word of Glory's healing is increased by the target's missing health, on any target.
    holy_shield                     = { 81489, 152261, 1 }, -- Your block chance is increased by 20%, you are able to block spells, and your successful blocks deal 249 Holy damage to your attacker.
    improved_ardent_defender        = { 90062, 393114, 1 }, -- Ardent Defender reduces damage taken by an additional 10%.
    improved_holy_shield            = { 81486, 393030, 1 }, -- Your chance to block spells is increased by 10%.
    improved_lay_on_hands           = { 81492, 393027, 1 }, -- Cooldown of Lay on Hands reduced by 10%.
    inner_light                     = { 81494, 386568, 1 }, -- When Shield of the Righteous expires, gain 10% block chance and deal 506 Holy damage to all attackers for 4 sec.
    inspiring_vanguard              = { 81476, 393022, 1 }, -- Grand Crusader's chance to proc is increased to 20% and it grants you 2% Strength for 8 sec.
    lay_on_hands                    = { 81597, 633   , 1 }, -- Heals a friendly target for an amount equal to 100% your maximum health. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    light_of_the_titans             = { 81503, 378405, 2 }, -- Word of Glory heals for an additional 2,559 over 15 sec. Increased by 50% if cast on yourself while you are afflicted by a harmful periodic effect.
    moment_of_glory                 = { 81505, 327193, 1 }, -- For the next 15 sec, you generate an absorb shield for 20% of all damage you deal, and Avenger's Shield damage is increased by 20% and its cooldown is reduced by 75%.
    quickened_invocations           = { 81479, 379391, 1 }, -- Cooldown of Seraphim is reduced by 5 sec and Divine Toll by 15 sec.
    redoubt                         = { 81494, 280373, 1 }, -- Shield of the Righteous increases your Strength and Stamina by 2% for 10 sec, stacking up to 3.
    relentless_inquisitor           = { 81506, 383388, 1 }, -- Spending Holy Power grants you 1% haste per finisher for 12 sec, stacking up to 3 times.
    resolute_defender               = { 81471, 385422, 1 }, -- Each 3 Holy Power you spend reduces the cooldown of Ardent Defender and Divine Shield by 1.0 sec.
    righteous_protector             = { 81477, 204074, 2 }, -- Holy Power abilities reduce the remaining cooldown on Avenging Wrath and Guardian of Ancient Kings by 1.5 sec.
    sanctuary                       = { 81486, 379021, 1 }, -- While in your Consecration, your damage taken is reduced by an additional 5%.
    sentinel                        = { 81483, 389539, 1 }, -- Call upon the Light and gain 15 stacks of Divine Resolve, increasing your maximum health by 2% and reducing your damage taken by 2% per stack for 20 sec. After 5 sec, you will begin to lose 1 stack per second, but each 3 Holy Power spent will delay the loss of your next stack by 1 sec. Combines with Avenging Wrath.
    shining_light                   = { 81498, 321136, 1 }, -- Every 3 Shields of the Righteous make your next Word of Glory free.
    soaring_shield                  = { 81472, 378457, 1 }, -- Avenger's Shield jumps to 2 additional targets.
    strength_in_adversity           = { 81493, 393071, 1 }, -- For each target hit by Avenger's Shield, gain 2% parry for 15 sec.
    strength_of_conviction          = { 81485, 379008, 2 }, -- While in your Consecration, your Shield of the Righteous and Word of Glory have 10% increased damage and healing.
    tyrs_enforcer                   = { 81474, 378285, 2 }, -- Your Avenger's Shield is imbued with holy fire, causing it to deal 179 Holy damage to all enemies within 5 yards of each target hit.
    uthers_counsel                  = { 81500, 378425, 1 }, -- Your Lay on Hands, Divine Shield, Blessing of Protection, and Blessing of Spellwarding have 20% reduced cooldown.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning               = 5554, -- (247675) When you or allies within your Aura are critically struck, gain Reckoning. Gain 1 additional stack if you are the victim. At 50 stacks of Reckoning, your next weapon swing deals 200% increased damage, will critically strike, and activates Avenging Wrath for 6 sec.
    guarded_by_the_light            = 97  , -- (216855) Your Flash of Light reduces all damage the target receives by 10% for 6 sec. Stacks up to 2 times.
    guardian_of_the_forgotten_queen = 94  , -- (228049) Empowers the friendly target with the spirit of the forgotten queen, causing the target to be immune to all damage for 10 sec.
    hallowed_ground                 = 90  , -- (216868) Your Consecration clears and suppresses all snare effects on allies within its area of effect.
    inquisition                     = 844 , -- (207028) You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    judgments_of_the_pure           = 93  , -- (355858) Casting Judgment on an enemy cleanses 1 Poison, Disease, and Magic effect they have caused on allies within your Aura.
    luminescence                    = 3474, -- (199428) When healed by an ally, allies within your Aura gain 4% increased damage and healing for 6 sec.
    sacred_duty                     = 92  , -- (216853) Reduces the cooldown of your Blessing of Protection and Blessing of Sacrifice by 33%.
    shield_of_virtue                = 861 , -- (215652) When activated, your next Avenger's Shield will interrupt and silence all enemies within 8 yards of the target.
    steed_of_glory                  = 91  , -- (199542) Your Divine Steed lasts for an additional 2 sec. While active you become immune to movement impairing effects, and you knock back enemies that you move through.
    unbound_freedom                 = 3475, -- (305394) Blessing of Freedom increases movement speed by 30%, and you gain Blessing of Freedom when cast on a friendly target. Unbound Freedom also causes any Blessing of Freedom applied to yourself to be undispellable.
    vengeance_aura                  = 5536, -- (210323) When a full loss of control effect is applied to you or an ally within your Aura, gain 6% critical strike chance for 8 sec. Max 2 stacks.
    warrior_of_light                = 860 , -- (210341) Increases the damage done by your Shield of the Righteous by 30%, but reduces armor granted by 30%.
} )


-- Auras
spec:RegisterAuras( {
    -- Talent: Damage taken reduced by $w1%.  The next attack that would otherwise kill you will instead bring you to $w2% of your maximum health.
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
        duration = function() return talent.sanctified_wrath.enabled and 25 or 20 end,
        max_stack = 1
    },
    -- Alias for Avenging Wrath vs. Sentinel
    aw_sentinel = {
        alias = { "avenging_wrath", "sentinel" },
        aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff",
        duration = function() return talent.sanctified_wrath.enabled and 25 or 20 end,
    },
    -- Talent: Block chance increased by $s1%.
    -- https://wowhead.com/beta/spell=385724
    barricade_of_faith = {
        id = 385724,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Your next cast of Shield of the Righteous or Word of Glory cost no Holy Power.
    -- https://wowhead.com/beta/spell=378974
    bastion_of_light = {
        id = 378974,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Damage against $@auracaster reduced by $w2.
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
        duration = 15,
        max_stack = 1
    },
    blessing_of_dusk = {
        id = 385126,
        duration = 15,
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
    -- Damage taken reduced by $w1%.
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
        duration = function () return 3 * ( 1 + ( conduit.lights_barding.mod * 0.01 ) ) + talent.seasoned_warhorse.rank end,
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
        duration = 9,
        type = "Magic",
        max_stack = 1
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
    -- Talent: Your Holy Power generation is tripled.
    -- https://wowhead.com/beta/spell=105809
    holy_avenger = {
        id = 105809,
        duration = 20,
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
    -- Talent: $@spellaura385728
    -- https://wowhead.com/beta/spell=385723
    seal_of_the_crusader = {
        id = 385723,
        duration = 5,
        max_stack = 1
    },
    sense_undead = {
        id = 5502,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $s12%. Maximum health increased by $s11%.  $?s53376[  Judgment generates $53376s3~ additional Holy Power.][]  $?s384376[  Damage and healing increased by $384376s1~%. Hammer of Wrath may be cast on any target.][]
    -- https://wowhead.com/beta/spell=389539
    sentinel = {
        id = 389539,
        duration = 20,
        max_stack = 15,
        copy = "divine_resolve"
    },
    -- Talent: Haste, Critical Strike, and Versatility increased by $s1%, and Mastery increased by $?c1[${$s4*$183997bc1}]?c2[${$s4*$76671bc1}][${$s4*$267316bc1}]%.
    -- https://wowhead.com/beta/spell=152262
    seraphim = {
        id = 152262,
        duration = 15,
        max_stack = 1
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
        max_stack = 1,
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


-- Gear Sets
spec:RegisterGear( "tier29", 200417, 200419, 200414, 200416, 200418 )
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
        if lastAbility and lastAbility.spendType == "holy_power" and now - ability.lastCast < 1 then
            applyBuff( "righteous_protector_icd" )
            buff.righteous_protector_icd.expires = ability.lastCast + 1
        end
    end
end )


spec:RegisterHook( "spend", function( amt, resource )
    if amt > 0 and resource == "holy_power" then
        if talent.righteous_protector.enabled then
            reduceCooldown( "avenging_wrath", 1.5 * talent.righteous_protector.rank )
            reduceCooldown( "guardian_of_ancient_kings", 1.5 * talent.righteous_protector.rank )
            applyBuff( "righteous_protector_icd" )
        end
        if talent.fist_of_justice.enabled then
            reduceCooldown( "hammer_of_justice", talent.fist_of_justice.rank * amt )
        end
        if ( talent.of_dusk_and_dawn.enabled or legendary.of_dusk_and_dawn.enabled ) and holy_power.current == 0 then applyBuff( "blessing_of_dusk" ) end
        if talent.relentless_inquisitor.enabled or legendary.relentless_inquisitor.enabled then
            addStack( "relentless_inquisitor" )
        end
        if talent.righteous_protector.enabled then
            reduceCooldown( "avenging_wrath", 0.5 * amt * talent.righteous_protector.rank )
        end
        if legendary.uthers_devotion.enabled then
            reduceCooldown( "blessing_of_freedom", 1 )
            reduceCooldown( "blessing_of_protection", 1 )
            reduceCooldown( "blessing_of_sacrifice", 1 )
            reduceCooldown( "blessing_of_spellwarding", 1 )
        end
    end
end )


spec:RegisterHook( "gain", function( amt, resource, overcap )
    if ( talent.of_dusk_and_dawn.enabled or legendary.of_dusk_and_dawn.enabled ) and amt > 0 and resource == "holy_power" and holy_power.current == 5 then
        applyBuff( "blessing_of_dawn" )
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
                reduceCooldown( "guardian_of_ancient_kings", 0.5 * talent.gift_of_the_golden_valkyr.rank * min( active_enemies, (talent.focused_enmity.enabled and 1 or 3 ) + ( talent.soaring_shield.enabled and 2 or 0 ) ) )
            end
            if talent.strength_in_adversity.enabled then addStack( "strength_in_adversity", nil, min( active_enemies, (talent.focused_enmity.enabled and 1 or 3 ) + ( talent.soaring_shield.enabled and 2 or 0 ) ) ) end

            if set_bonus.tier29_2pc > 0 then applyBuff( "ally_of_the_light" ) end

            if conduit.vengeful_shock.enabled then applyDebuff( "target", "vengeful_shock" ) end
            if legendary.bulwark_of_righteous_fury.enabled then addStack( "bulwark_of_righteous_fury", nil, min( 5, active_enemies ) ) end
        end,
    },

    -- Talent: Call upon the Light to become an avatar of retribution, causing Judgment to generate 1 additional Holy Power, allowing Hammer of Wrath to be used on any target, increasing your damage, healing and critical strike chance by 20% for 25 sec.
    avenging_wrath = {
        id = 31884,
        flash = { 31884, 389539 },
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
        gcd = "off",
        school = "holy",

        startsCombat = false,
        toggle = "cooldowns",

        handler = function ()
            -- Talents:
            -- Avenging Wrath - 20% damage/healing, use Hammer of Wrath on any target.
            -- Sanctified Wrath - +5 seconds, Judgment generates +1 HP.
            -- Avenging Wrath: Might - +20% critical strike.
            -- Sentinel - Gain 15 stacks of Divine Resolve, decaying every 1 second after 5 seconds.
            if talent.sentinel.enabled then applyBuff( "sentinel", nil, 15 )
            else applyBuff( "avenging_wrath" ) end
        end,

        copy = { "sentinel", 389539 }
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
            applyBuff( "bastion_of_light", nil, 3 )
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
            if talent.aspiration_of_divinity.enabled then addStack( "aspiration_of_divinity" ) end
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )

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
        cooldown = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( talent.uthers_counsel.enabled and 0.8 or 1 ) end,
        recharge = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( talent.uthers_counsel.enabled and 0.8 or 1 ) end,
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
        cooldown = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( talent.uthers_counsel.enabled and 0.8 or 1 ) end,
        recharge = function() return ( talent.improved_blessing_of_protection.enabled and 240 or 300 ) * ( talent.uthers_counsel.enabled and 0.8 or 1 ) end,
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
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",
        school = "holy",

        spend = 0.065,
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

        talent = "auras_of_swift_vengeance",
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

        spend = 0.11,
        spendType = "mana",

        notalent = function() return talent.blessed_hammer.enabled and "blessed_hammer" or "hammer_of_the_righteous" end,
        startsCombat = true,

        handler = function ()
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            if talent.aspiration_of_divinity.enabled then addStack( "aspiration_of_divinity" ) end
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
        cooldown = function () return 300 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * ( talent.uthers_counsel.enabled and 0.8 or 1 ) end,
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

    -- Talent: Releases a blinding flash from your shield, causing 1,342 Holy damage to all nearby enemies within 8 yds and reducing all damage they deal to you by 25% for 9 sec.
    eye_of_tyr = {
        id = 387174,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "holy",

        talent = "eye_of_tyr",
        startsCombat = true,
        toggle = "defensives",

        handler = function ()
            applyDebuff( "target", "eye_of_tyr" )
            active_dot.eye_of_tyr = active_enemies
        end,
    },

    -- Expends a large amount of mana to quickly heal a friendly target for 6,713.
    flash_of_light = {
        id = 19750,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.22,
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
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            if talent.aspiration_of_divinity.enabled then addStack( "aspiration_of_divinity" ) end

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
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )

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

    -- Talent: Your Holy Power generation is tripled for 20 sec.
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

    -- Petition the Light on the behalf of a fallen ally, restoring spirit to body and allowing them to reenter battle with 60% health and at least 20% mana.
    intercession = {
        id = 391054,
        cast = 2,
        cooldown = 600,
        gcd = "spell",
        school = "holy",

        spend = 3,
        spendType = "holy_power",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
        end,
    },

    -- Judges the target, dealing 2,824 Holy damage, and causing them to take 20% increased damage from your next Holy Power ability. Generates 1 Holy Power.
    judgment = {
        id = 275779,
        cast = 0,
        charges = function () return talent.crusaders_judgment.enabled and 2 or nil end,
        cooldown = function() return 6 * ( buff.blessing_of_dusk.up and talent.seal_of_order.enabled and 0.9 or 1 ) end,
        recharge = function () return talent.crusaders_judgment.enabled and ( 6 * ( buff.blessing_of_dusk.up and talent.seal_of_order.enabled and 0.9 or 1 ) ) or nil end,
        gcd = "spell",
        school = "holy",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        aura = "judgment",

        handler = function ()
            if talent.greater_judgment.enabled then applyDebuff( "target", "judgment" ) end
            removeBuff( "recompense" )
            gain( ( buff.holy_avenger.up and 3 or 1 ) + ( ( buff.avenging_wrath.up or buff.sentinel.up ) and talent.sanctified_wrath.enabled and 1 or 0 ), "holy_power" )
            if talent.judgment_of_light.enabled then applyDebuff( "target", "judgment_of_light", nil, 25 ) end
        end,
    },

    -- Talent: Heals a friendly target for an amount equal to 100% your maximum health. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    lay_on_hands = {
        id = 633,
        cast = 0,
        cooldown = function () return 600 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * ( talent.improved_lay_on_hands.enabled and 0.9 or 1 ) * ( talent.uthers_counsel.enabled and 0.8 or 1 ) end,
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

    -- Talent: The Light magnifies your power for $d, granting $s1% Haste, Critical Strike, and Versatility, and $?c1[${$s4*$183997bc1}]?c2[${$s4*$76671bc1}][${$s4*$267316bc1}]% Mastery.
    seraphim = {
        id = 152262,
        cast = 0,
        cooldown = function() return talent.quickened_invocations.enabled and 40 or 45 end,
        gcd = "spell",
        school = "holy",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3 - ( buff.the_magistrates_judgment.up and 1 or 0 )
        end,
        spendType = "holy_power",

        talent = "seraphim",
        startsCombat = false,

        handler = function ()
            removeBuff( "divine_purpose" )
            removeBuff( "the_magistrates_judgment" )
            applyBuff( "seraphim", min( 2, cooldown.shield_of_the_righteous.charges ) * 8 )
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
            if buff.bastion_of_light.up or buff.divine_purpose.up then return 0 end
            return 3 - ( buff.the_magistrates_judgment.up and 1 or 0 ) - ( buff.seal_of_clarity.up and 1 or 0 )
        end,
        spendType = "holy_power",

        startsCombat = true,

        usable = function() return equipped.shield, "requires a shield" end,

        handler = function ()
            removeStack( "bastion_of_light" )
            removeBuff( "bulwark_of_righteous_fury" )
            removeBuff( "divine_purpose" )
            removeBuff( "the_magistrates_judgment" )
            removeDebuff( "target", "judgment" )

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

            if conduit.resolute_defender.enabled and buff.ardent_defender.up then
                buff.ardent_defender.expires = buff.ardent_defender.expires + ( buff.ardent_defender.duration * ( conduit.resolute_defender.mod * 0.01 ) )
            end
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
            if buff.royal_decree.up then removeBuff( "royal_decree" )
            elseif buff.divine_purpose.up then removeBuff( "divine_purpose" )
            elseif buff.bastion_of_light.up then removeStack( "bastion_of_light" )
            else removeBuff( "shining_light_full" ) end

            removeBuff( "the_magistrates_judgment" )
            gain( 2.9 * stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )

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


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "phantom_fire",

    package = "Protection Paladin",
} )


spec:RegisterPack( "Protection Paladin", 20230227, [[Hekili:DZXAVnUnYFlghwV2DZ6ePSo72f15dT9aUUOOOOU3xTeJLSTUil5tKoPbWq)2VziLOePiLLFLT7HwueloCE)GA0WoZz2FoBAaHfo73CVX92BCD)4iNpE7NUD8SPSx2eoB6gY8hjlH)iHSg(V)EwklColknj3)3jXKGOeeMxItjbiUOPBZMdWTIX2q)81xVmITA7dJMNU(AA06TXeCRZZily4VNF9SPpSnkM9ljZEWmJC7SPKTSvPzZMonA9pbyokiiuaEiD(SPi4V)g337(XpN7N7)VPH5(ttz)rU)ZaTZ9)rcvWUPlY9)1OLRyxL7)ZrpfLaa(7BZ2KsdHNKML7F77Y9)xPXVapp95q4brWw(dClHPBPWtfcpcAe8ZKuwUpJehMWcdeyaFC6wgnkaqEed(1V8t)8OztJJOmkxxhUGSnMb)5VX19HjKhIddM9JcXjlAdYSZM(p)RW5B5On8PWmGJyrRbuYwb)hsflqEIefJyaObzUyRzHpS9XWzmqtIuO8XZJdjj0qpw6FfLqRtzaYB14f5MiXXEIF4HYGqs8e(cZttJdsFgqgGHpCmyyDelAj3LarX4JbfSSOKhdzCE4UJbbugjjGKfaiawytwi4R(aXOfcmpSWSic60UyXOnc)FpY2mYiururXGWNs5KdxRHPigDPOE)NTblxdopMSfLGsYMtsqJwwwti)GI9nfSUqKL4x1HJPOOBvUaDXJrjlZ97N7ZLr6QOW4aV0fEGRNxwzSaxC5qni3FfeY4TbJygbU3rZJGWIj5(3K7VBxbAc4XBEBeHBJ2Uj3FyfRBHis9MrwDvijMTA0M5a1(biypDPN4rNgBjxdyQeqv4XnwElYcBW2pNMXz6LXPzVykkYSEnkb8Wqmhqwdzw9gdXX3N7VmL8yXJ4G1JleCwb8obJVhifHjbG4OWNl3clhrsqoHKmpcHePfvfScrvOQvxAd3vvx6SIxtr71LumF4OfrjKypES1Oc44svhueb0)oPgu2GPSuFtBK1iQPKOwJ4CgxlJg5fpiB3kWCtfzCK5LnKVjDdeZhYIwOO9eByeZz0kc1BluQcz8YO5bLLAhToftAkd8uDVQqsz1PrbBfjfZ9FtUV8P6yPckroIHcD3aUn6SszYtHjlrxJNHvxzIWd1pmWtK4TWzJWc(skrRqjC8f0YhGSYdWzfe8P4epCovC4KscdjlrktFBnumcoPYc8il4drYb(NGzapKtUFw4Ase6FG)jBBgWRoandJXZAv(KBgngoeYtKm1cZEoE0xsMx5QaqeHQn8VaY4Hyz2uy3fpy2uhtj(R5Zyct6u1TGQg8VCph(xU7ZkFX8V2lL7K)vR6E96yhOUFtwukO2FPU2VNsesddGvJdQJ6GLRvLZ1kaGB1RArqD8DCC4mACU)7AHAsilL9rQoBcvlpnVgxzmLW1ka0zUsx5zNRCQXvQgChP521uX8cZT1q2wYvRyUEvw0CkhCfQPQ1hGSDqUIxKfnNytkB2EDNcqDQh)vEkd9umLNrWAsiVccOKmsCGLN9OaKWboIfhROmGSxdbQ09VH0kJleLyOcaA4kxMrHNdZrM88HukvV4RwG09WgwWpbFbfaZFCkRMscuKFSDfP7FhuKoTPiDokfPBlkYg5j3NIKNj5thGhzpJPS4o3LY)EDumHd3sCuuE1AfzjMGe2U3CGLJRJyPXZegTvwwh2HY)1Kh63FaEOTQu6BTY0EvSo)FMIL7X6Ct9EOGjEb14AAJgOi7suRTprL5ZiBwfTUgdbHqJ1ZsibtQegw7GndQ3gdEq7TLV3ip1bSdkfL9umwL(ip)rT15BMRGkEJYQJDQH3Xvjd4iw01ueV8gGy89mvANt(j3rhfFe5EGCwfDDTsfjzedq5fnpOO9usn5Xjs4A11s3lsz2jP0ERGoUQhLYETxDxyvP1AnH9UYyOotfMwrwVomdjfpcQTwXw1YYkCpFfjBj(UPIskQIX8STusaYMLBTssM)Y84qpgUBgfdRAT7dIgGRMszq7rssJRCjLYRgl(QY(A5wQNOQoHl2FZq4tZyRhvv4JYsJJLhBXM7GANI)uDq1T3QGARutntVb7MipQrdxpmPyvVPvC9uAAnIgN6mA4lH8GRxY04rhL2PZtcgg4jKlDqV1SORgXQTh1gRx4c7rHchpgQdR9(bkC9m1g5w6HSZDZ6At9R((lLfLKjMk83141wt92mqzVfQ08(KXjTNa88tRJmVNOLOMs31KzTDidEFqL5JK5OC0pKIXJYuUZUCugNX1sROUHQO(QD0VgqYmVgxvlBqfqQ5E0sr1EUARzw7IKExN0D3DtTO6ANYX07Z1r)b9dimt8ptFcuWiaIVmTJ7DqyljlH)TqM(N4xKnA9M0mg8csyBwFBX5lPVfBo6)DBug6attrxdYww6Ac)76cLnb(Lok)l)k)tr785C)FknbigF5sSmsTDhaozP1wL1y5bo)1WoG0gDKYaMnbZff9xme)vIVt3ekGGIFri7MT(dg0(jb63g5FZBS(QyLGm5MH72nO35HiwAWmqJH7X98eLZxdXStsP0E7AXrYT9G2glR4DAhP7370mmxu0FXq8xj(2EqR7X6mBG8N)G22jYHe0EwLZxdXStsP0EF7LOsRnKEszcELr6XfhDHrFhq8MS05JijV4fSH2gYTbxh5)UsguP7D4OhTzIxmILbEXSvwSR6WCMr)H62CSNz6cJ(oG4UzpTdxh5)UsMJYTXPd2vZWCMrFhDBAuCTNf803IB5UDwwalt1sEK3ylaD43nWz043zbRWQw(C)dhEFnkA6OK2ST6u0zVu0PGIL6(xlL21V6kTRVaknPV4hozV8wdIoD0BliQdyEnHYcZEPn(UcKZlYpbUgwJcM34iwRCUkyNFICcsWku10gVxcW5eXNa)I9cRn2Ty9ZiATXSJp5JQ0A04PJ(tGXTfWyeKZlYpbUUTafRGD(jYjibMdAmaW5eXNa)AmSP56Nr0AJzVthRToetsK3PrDAV0srckptGfbO2YDePYdzu89dmGydGCbr(ErB3FPHo9UjNozqpgRVBYhFfDDAqlLsrwDDASChr6ETUgb5cI89I2U3MIo56C6KPvxNpDwJRUOixI2V)SAq145ZlYb0Y)(KlsJJtFMF1pWlKi8U3phMbphkgeiEp8YlwAeoRN4TJe)U3Ss44301fPBtuGoiaboGWipqOHFo)l5(Vp3hR9a)5xm8HrlhIU3EqFyulvMuB1RwwfZZTZEZlQoppA4uFmFQWw(x(fUCIi5ov1ikgZMs3eoF2VD3D49lnDreoT5cGOJKx403n5ALBn6vrlMWlM34AMM)ftBw7sLAgi1RtQzyQpZjOS9pY9p4BJSeZte3gz5Vr8RCrKvwr7E6Efo67tk9Q7aOvxZ19dBrCthWAPBlQmkvysMAs5SQyynuHR4iI20bIx9OA4x2TRNLXEzOzCw6iEEWMykyKEBAtTHXTOvZUIpmpvh)GZ4D7gGUm37CZUDYSu6Z1X9iCYvnJlaMH9hOcuZ5FPVea9zFPAflZ9YqlQP6ZyIfL1(z(7Av8V7gZKwFUuSARQ2EvGWeldPkIKIlSAFHpul307(dAEzQNaYcFJnMC2HM4dqouM1nK(vxO0FO66BFy0Q45gNYoB8H1ltBDDsZlW791U8U97v4W34s7wWqTDHDvLf5L1T4XYlQRn2xzFcwMhVB4kx3VfPrEnR)AklA08Bddq9l7SMBSZ46rHLfoWC22JchulJG6vg4(jJBjDE)bdQfQm52(94S)dnVsafRODzaWV6ET9pEyH8Byo5TgPp8Gf2E7F((lOwBZ2pi8hkVUBxLWEVRzgxRCImrBZj4UYUyB2TnHFTAo7TOBTTwwi7kLPVEIdIJIjWFIBfxzFU7nI9AtwopgeRv7cjDhmWM7xzI3QtEuAt0lk2Z4zY73t7y1LB)i01wCd1SMDXICqQEJax)0ZOQSN2SVBCtvd6UXLFqza33JCOeYzMfvhODJW0OwT9YS7vnu(seFR8)fdQeOsMeeOYpVOYlpu8ngVkDZe(9J)konHGYQBB9eaJxbAJGieLtu7x1HpIvVgJ)5rp9NhGIZ9yvCn)(1DtOEngbVJEc8oafx5n4vx15wx15utX1ZIlNzfA1KcyDqbAB4kS0wqTpEVHpbxhhzG2gZclDZwJ2g(y8Tn8ahGLP4(XwypAHEv64MFIDJRv7tMzCD(hNY4kIMX1zrW1OiyWCP7Mywem)v)mUUMi42braDnXlR7v4T6TKzDQAgXbCqIYV6qFdhGboxspv2Q0fSo7Q361D7SE37N4GN0oLs7Vhp37NOCH77UsW9IQeCSOeA2)52ucU6kblPooALa3tONTBXEFtPZKSDZTvezafdSwZO8L24NBEFLmgyVnqU3S)gj5cfnSKCYUhHvPQVP8RTOmC(Mtzi(FkzZ(Fp]] )