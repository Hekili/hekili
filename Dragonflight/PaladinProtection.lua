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
    avenging_wrath                  = { 81606, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, and activating all the effects learned for Avenging Wrath for 20 sec.
    blessing_of_protection          = { 81616, 1022  , 1 }, -- Blesses a party or raid member, granting immunity to Physical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Spellwarding.
    blessing_of_sacrifice           = { 81614, 6940  , 1 }, -- Blesses a party or raid member, reducing their damage taken by 30%, but you suffer 100% of damage prevented. Last 12 sec, or until transferred damage would cause you to fall below 20% health.
    blinding_light                  = { 81598, 115750, 1 }, -- Emits dazzling light in all directions, blinding enemies within 10 yds, causing them to wander disoriented for 6 sec. Non-Holy damage will break the disorient effect.
    cavalier                        = { 81605, 230332, 1 }, -- Divine Steed now has 2 charges.
    crusaders_reprieve              = { 81543, 403042, 1 }, -- Increases the range of your Crusader Strike, Rebuke and auto-attacks by 3 yds. Using Blessed Hammer heals you for 2% of your maximum health.
    divine_steed                    = { 81632, 190784, 1 }, -- Leap atop your Charger for 3 sec, increasing movement speed by 100%. Usable while indoors or in combat.
    divine_toll                     = { 81496, 375576, 1 }, -- Instantly cast Avenger's Shield on up to 5 targets within 30 yds. Generates 1 Holy Power per target hit.
    fading_light                    = { 81623, 405768, 1 }, -- Blessing of Dawn: Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional 10%. Blessing of Dusk: Blessing of Dusk causes your Holy Power generating abilities to also grant an absorb shield for 20% of damage or healing dealt.
    faiths_armor                    = { 81495, 406101, 1 }, -- Shield of the Righteous grants 20% bonus armor for 4.5 sec.
    fist_of_justice                 = { 81602, 234299, 2 }, -- Each Holy Power spent reduces the remaining cooldown on Hammer of Justice by 1 sec.
    golden_path                     = { 81610, 377128, 1 }, -- Consecration heals you and 5 allies within it for 117 every 0.9 sec.
    holy_aegis                      = { 81609, 385515, 2 }, -- Armor and critical strike chance increased by 2%.
    improved_blessing_of_protection = { 81617, 384909, 1 }, -- Reduces the cooldown of Blessing of Protection and Blessing of Spellwarding by 60 sec.
    incandescence                   = { 81628, 385464, 1 }, -- Each Holy Power you spend has a 5% chance to cause your Consecration to flare up, dealing 950 Holy damage to up to 5 enemies standing within it.
    judgment_of_light               = { 81608, 183778, 1 }, -- Judgment causes the next 5 successful attacks against the target to heal the attacker for 466.
    justification                   = { 81509, 377043, 1 }, -- Judgment's damage is increased by 10%.
    obduracy                        = { 81630, 385427, 1 }, -- Speed and Avoidance increased by 2%.
    of_dusk_and_dawn                = { 81624, 385125, 1 }, -- When you cast 3 Holy Power generating abilities, you gain Blessing of Dawn. When you consume Blessing of Dawn, you gain Blessing of Dusk. Blessing of Dawn Your next Holy Power spending ability deals 20% additional increased damage and healing. This effect stacks. Blessing of Dusk Damage taken reduced by 5% For 10 sec.
    punishment                      = { 93165, 403530, 1 }, -- Successfully interrupting an enemy with Rebuke casts an extra Crusader Strike.
    rebuke                          = { 81604, 96231 , 1 }, -- Interrupts spellcasting and prevents any spell in that school from being cast for 4 sec.
    recompense                      = { 81607, 384914, 1 }, -- After your Blessing of Sacrifice ends, 50% of the total damage it diverted is added to your next Judgment as bonus damage, or your next Word of Glory as bonus healing. This effect's bonus damage cannot exceed 30% of your maximum health and its bonus healing cannot exceed 100% of your maximum health.
    repentance                      = { 81598, 20066 , 1 }, -- Forces an enemy target to meditate, incapacitating them for 60 sec. Usable against Humanoids, Demons, Undead, Dragonkin, and Giants.
    sacrifice_of_the_just           = { 81607, 384820, 1 }, -- Reduces the cooldown of Blessing of Sacrifice by 60 sec.
    sanctified_plates               = { 93009, 402964, 2 }, -- Armor increased by 10%, Stamina increased by 5% and damage taken from area of effect attacks reduced by 5%.
    seal_of_alacrity                = { 81619, 385425, 2 }, -- Haste increased by 2% and Judgment cooldown reduced by 0.5 sec.
    seal_of_mercy                   = { 81611, 384897, 1 }, -- Golden Path strikes the lowest health ally within it an additional time for 100% of its effect.
    seal_of_might                   = { 81621, 385450, 2 }, -- Mastery increased by 2% and strength increased by 2%.
    seal_of_order                   = { 81623, 385129, 1 }, -- Blessing of Dawn: Blessing of Dawn increases the damage and healing of your next Holy Power spending ability by an additional 10%. Blessing of Dusk: Blessing of Dusk increases your armor by 10% and your Holy Power generating abilities cool down 10% faster.
    seal_of_the_crusader            = { 81626, 385728, 2 }, -- Your auto attacks deal 132 additional Holy damage.
    seasoned_warhorse               = { 81631, 376996, 1 }, -- Increases the duration of Divine Steed by 2 sec.
    strength_of_conviction          = { 81480, 379008, 2 }, -- While in your Consecration, your Shield of the Righteous and Word of Glory have 10% increased damage and healing.
    touch_of_light                  = { 81628, 385349, 1 }, -- Your spells and abilities have a chance to cause your target to erupt in a blinding light dealing 791 Holy damage or healing an ally for 1,053 health.
    turn_evil                       = { 93010, 10326 , 1 }, -- The power of the Light compels an Undead, Aberration, or Demon target to flee for up to 40 sec. Damage may break the effect. Lesser creatures have a chance to be destroyed. Only one target can be turned at a time.
    unbreakable_spirit              = { 81615, 114154, 1 }, -- Reduces the cooldown of your Divine Shield, Ardent Defender, and Lay on Hands by 30%.

    -- Protection
    afterimage                      = { 93188, 385414, 1 }, -- After you spend 20 Holy Power, your next Word of Glory echoes onto a nearby ally at 30% effectiveness
    ardent_defender                 = { 81481, 31850 , 1 }, -- Reduces all damage you take by 20% for 8 sec. While Ardent Defender is active, the next attack that would otherwise kill you will instead bring you to 20% of your maximum health.
    auras_of_swift_vengeance        = { 81601, 385639, 1 }, -- Learn Retribution Aura and Crusader Aura:  Retribution Aura: When any party or raid member within 40 yds takes more than 30% of their health in damage in a single hit, each member gains 5% increased damage and healing, decaying over 30 sec. This cannot occur within 30 sec of the aura being applied.  Crusader Aura: Increases mounted speed by 20% for all party and raid members within 40 yds.
    auras_of_the_resolute           = { 81599, 385633, 1 }, -- Learn Concentration Aura and Devotion Aura: Concentration Aura: Interrupt and Silence effects on party and raid members within 40 yds are 30% shorter.  Devotion Aura: Party and raid members within 40 yds are bolstered by their devotion, reducing damage taken by 3%.
    avengers_shield                 = { 81502, 31935 , 1 }, -- Hurls your shield at an enemy target, dealing 1,750 Holy damage, interrupting and silencing the non-Player target for 3 sec, and then jumping to 2 additional nearby enemies. Shields you for 8 sec, absorbing 25% as much damage as it dealt. Deals 186 additional damage to all enemies within 5 yds of each target hit.
    avenging_wrath_might            = { 81483, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, and activating all the effects learned for Avenging Wrath for 20 sec.
    barricade_of_faith              = { 81501, 385726, 1 }, -- When you use Avenger's Shield, your block chance is increased by 10% for 10 sec.
    bastion_of_light                = { 81488, 378974, 1 }, -- Your next 3 casts of Shield of the Righteous or Word of Glory cost no Holy Power.
    blessed_hammer                  = { 81469, 204019, 1 }, -- Throws a Blessed Hammer that spirals outward, dealing 453 Holy damage to enemies and reducing the next damage they deal to you by 702. Generates 1 Holy Power.
    blessing_of_freedom             = { 81600, 1044  , 1 }, -- Blesses a party or raid member, granting immunity to movement impairing effects for 8 sec.
    blessing_of_spellwarding        = { 90062, 204018, 1 }, -- Blesses a party or raid member, granting immunity to magical damage and harmful effects for 10 sec. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec. Shares a cooldown with Blessing of Protection.
    bulwark_of_order                = { 81499, 209389, 2 }, -- Avenger's Shield also shields you for 8 sec, absorbing 25% as much damage as it dealt, up to 30% of your maximum health.
    bulwark_of_righteous_fury       = { 81491, 386653, 1 }, -- Avenger's Shield increases the damage of your next Shield of the Righteous by 20% for each target hit by Avenger's Shield, stacking up to 5 times, and increases its radius by 6 yds.
    cleanse_toxins                  = { 81507, 213644, 1 }, -- Cleanses a friendly target, removing all Poison and Disease effects.
    consecrated_ground              = { 81492, 204054, 1 }, -- Your Consecration is 15% larger, and enemies within it have 50% reduced movement speed. Your Divine Hammer is 25% larger, and enemies within them have 30% reduced movement speed.
    consecration_in_flame           = { 81470, 379022, 1 }, -- Consecration lasts 2 sec longer and its damage is increased by 20%.
    crusaders_judgment              = { 81473, 204023, 1 }, -- Judgment now has 2 charges, and Grand Crusader now also reduces the cooldown of Judgment by 3 sec.
    crusaders_resolve               = { 81493, 380188, 1 }, -- Enemies hit by Avenger's Shield deal 2% reduced damage to you for 10 sec. Multiple applications may overlap, up to a maximum of 3.
    divine_purpose                  = { 93192, 223817, 1 }, -- Holy Power abilities have a 15% chance to make your next Holy Power ability free and deal 15% increased damage and healing.
    divine_resonance                = { 81479, 386738, 1 }, -- After casting Divine Toll, you instantly cast Avenger's Shield every 5 sec for 15 sec.
    eye_of_tyr                      = { 81497, 387174, 1 }, -- Releases a blinding flash from your shield, causing 1,496 Holy damage to all nearby enemies within 8 yds and reducing all damage they deal to you by 25% for 9 sec.
    faith_in_the_light              = { 81485, 379043, 2 }, -- Casting Word of Glory grants you an additional 5% block chance for 5 sec.
    ferren_marcuss_fervor           = { 81482, 378762, 2 }, -- Avenger's Shield deals 10% increased damage to its primary target.
    final_stand                     = { 81504, 204077, 1 }, -- During Divine Shield, all targets within 15 yds are taunted.
    focused_enmity                  = { 81472, 378845, 1 }, -- When Avenger's Shield strikes a single enemy, it deals 100% additional Holy damage.
    gift_of_the_golden_valkyr       = { 81484, 378279, 2 }, -- Each enemy hit by Avenger's Shield reduces the remaining cooldown on Guardian of Ancient Kings by 0.5 sec. When you drop below 30% health, you become infused with Guardian of Ancient Kings for 4 sec. This cannot occur again for 45 sec.
    grand_crusader                  = { 81487, 85043 , 1 }, -- When you avoid a melee attack or use Blessed Hammer, you have a 20% chance to reset the remaining cooldown on Avenger's Shield and increase your Strength by 2% for 8 sec.
    greater_judgment                = { 81603, 231663, 1 }, -- Judgment causes the target to take 40% increased damage from your next Holy Power ability.
    guardian_of_ancient_kings       = { 81490, 86659 , 1 }, -- Empowers you with the spirit of ancient kings, reducing all damage you take by 50% for 8 sec.
    hammer_of_the_righteous         = { 81469, 53595 , 1 }, -- Hammers the current target for 2,716 Physical damage. While you are standing in your Consecration, Hammer of the Righteous also causes a wave of light that hits all other targets within 8 yds for 429 Holy damage. Generates 1 Holy Power.
    hammer_of_wrath                 = { 81510, 24275 , 1 }, -- Hurls a divine hammer that strikes an enemy for 5,541 Holy damage. Only usable on enemies that have less than 20% health. Generates 1 Holy Power.
    hand_of_the_protector           = { 81475, 315924, 1 }, -- Word of Glory's healing is increased by the target's missing health, on any target.
    holy_shield                     = { 81489, 152261, 1 }, -- Your block chance is increased by 20%, you are able to block spells, and your successful blocks deal 259 Holy damage to your attacker.
    improved_ardent_defender        = { 90062, 393114, 1 }, -- Ardent Defender reduces damage taken by an additional 10%.
    improved_holy_shield            = { 81486, 393030, 1 }, -- Your chance to block spells is increased by 10%.
    inmost_light                    = { 92953, 405757, 1 }, -- Eye of Tyr deals 300% increased damage and has 25% reduced cooldown.
    inner_light                     = { 81494, 386568, 1 }, -- When Shield of the Righteous expires, gain 10% block chance and deal 527 Holy damage to all attackers for 4 sec.
    inspiring_vanguard              = { 81476, 393022, 1 }, -- Grand Crusader's chance to occur is increased to 20% and it grants you 2% strength for 8 sec.
    lay_on_hands                    = { 81597, 633   , 1 }, -- Heals a friendly target for an amount equal to 100% your maximum health. Cannot be used on a target with Forbearance. Causes Forbearance for 30 sec.
    light_of_the_titans             = { 81503, 378405, 2 }, -- Word of Glory heals for an additional 2,761 over 15 sec. Increased by 50% if cast on yourself while you are afflicted by a harmful damage over time effect.
    lightforged_blessing            = { 93168, 406468, 1 }, -- Shield of the Righteous heals you and up to 4 nearby allies for 1% of maximum health.
    moment_of_glory                 = { 81505, 327193, 1 }, -- For the next 15 sec, you generate an absorb shield for 20% of all damage you deal, and Avenger's Shield damage is increased by 20% and its cooldown is reduced by 75%.
    quickened_invocation            = { 81479, 379391, 1 }, -- Divine Toll's cooldown is reduced by 15 sec.
    redoubt                         = { 81494, 280373, 1 }, -- Shield of the Righteous increases your Strength and Stamina by 2% for 10 sec, stacking up to 3.
    relentless_inquisitor           = { 81506, 383388, 1 }, -- Spending Holy Power grants you 1% haste per finisher for 12 sec, stacking up to 3 times.
    resolute_defender               = { 81471, 385422, 2 }, -- Each 3 Holy Power you spend reduces the cooldown of Ardent Defender and Divine Shield by 1.0 sec.
    righteous_protector             = { 81477, 204074, 1 }, -- Holy Power abilities reduce the remaining cooldown on Avenging Wrath and Guardian of Ancient Kings by 3.0 sec.
    sanctified_wrath                = { 81620, 31884 , 1 }, -- Call upon the Light to become an avatar of retribution, and activating all the effects learned for Avenging Wrath for 20 sec.
    sanctuary                       = { 81486, 379021, 1 }, -- While in your Consecration, your damage taken is reduced by an additional 5%.
    seal_of_charity                 = { 81612, 384815, 1 }, -- When you cast Word of Glory on someone other than yourself, you are also healed for 50% of the amount healed.
    seal_of_reprisal                = { 81629, 377053, 1 }, -- Your Blessed Hammer deals 20% increased damage.
    sentinel                        = { 81483, 389539, 1 }, -- Call upon the Light and gain 15 stacks of Divine Resolve, increasing your maximum health by 2% and reducing your damage taken by 2% per stack for 20 sec. After 5 sec, you will begin to lose 1 stack per second, but each 3 Holy Power spent will delay the loss of your next stack by 1 sec. Combines with Avenging Wrath.
    shining_light                   = { 81498, 321136, 1 }, -- Every 3 Shields of the Righteous make your next Word of Glory free.
    soaring_shield                  = { 81472, 378457, 1 }, -- Avenger's Shield jumps to 2 additional targets.
    strength_in_adversity           = { 81493, 393071, 1 }, -- For each target hit by Avenger's Shield, gain 2% parry for 15 sec.
    tirions_devotion                = { 81492, 392928, 1 }, -- Lay on Hands' cooldown is reduced by 1 sec per Holy Power spent.
    tyrs_enforcer                   = { 81474, 378285, 2 }, -- Your Avenger's Shield is imbued with holy fire, causing it to deal 187 Holy damage to all enemies within 5 yards of each target hit.
    unbound_freedom                 = { 93187, 305394, 1 }, -- Blessing of Freedom increases movement speed by 30%, and you gain Blessing of Freedom when cast on a friendly target.
    uthers_counsel                  = { 81500, 378425, 2 }, -- Your Lay on Hands, Divine Shield, Blessing of Protection, and Blessing of Spellwarding have 20% reduced cooldown.
    zealots_paragon                 = { 81625, 391142, 1 }, -- Hammer of Wrath and Judgment deal 10% additional damage and extend the duration of Sentinel by 0.5 sec.
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
        duration = 20,
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
        duration = function () return 4 * ( 1 + ( conduit.lights_barding.mod * 0.01 ) ) + ( 2 * talent.seasoned_warhorse.rank ) end,
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
    --[[ Talent: Your Holy Power generation is tripled.
    -- https://wowhead.com/beta/spell=105809
    holy_avenger = {
        id = 105809,
        duration = 20,
        max_stack = 1
    }, ]]
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
            reduceCooldown( "avenging_wrath", 3 )
            reduceCooldown( "guardian_of_ancient_kings", 3 )
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
    if amt > 0 and resource == "holy_power" and buff.blessing_of_dusk.up then
        applyBuff( "fading_light" )
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

    -- Talent: Releases a blinding flash from your shield, causing 1,342 Holy damage to all nearby enemies within 8 yds and reducing all damage they deal to you by 25% for 9 sec.
    eye_of_tyr = {
        id = 387174,
        cast = 0,
        cooldown = function() return talent.inmost_light.enabled and 45 or 60 end,
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
            gain( ( 1 ) + ( ( buff.avenging_wrath.up or buff.sentinel.up ) and talent.sanctified_wrath.enabled and 1 or 0 ), "holy_power" )
            if talent.judgment_of_light.enabled then applyDebuff( "target", "judgment_of_light", nil, 5 ) end
        end,
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
            if buff.bastion_of_light.up or buff.divine_purpose.up then return 0 end
            return 3 - ( buff.the_magistrates_judgment.up and 1 or 0 )
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


spec:RegisterPack( "Protection Paladin", 20230327, [[Hekili:DZXAVnUnYFlghwh7UPkwknjnfRdWT7Eh6UOODrDVVAjAjzBDrwsvpswdyOF73mK6fPiLLJTt7EafBxloCEpdhsoCNRp)pMpZHK6o)xnMyC9KRnUttx)M70VE(S0TrUZNfrSFKSc(lbKnWF(L4Wux7uVWGCRVq8joEbimB9djoiUscZITb4wNMgL8txD1kV01zl0Sd3CvI3MmFcov7yYYu832xnF2Imp)0pfmFHugzY9ZNrYsxhgpF2mVnFaWSNJJldC3e75ZqW)(jgFVXD)uUvU1)jXn3Awy6VNB9mq7CR3tsySB4YCRFXB160lZT(O3tEbaGFjlokmXf(syCU11Vn36Nd93cFp8zx4dEWu(DCkUHzjWxzcpcQh8ZGW0CRuIVBqQRddd4NdZst8CaK7Lc)6tF4JA5Fo)Zm2e(VBPS5hw7A)yU1sCs)gqLpMLa)Kea45JKNbUDr2YLW0x4cGa4kjYna01RYTYsO)pMisao4AaBFHJg63ZufrOc1PGk6t0MODhhCg6u4(TWOeqd8EF3Kee8FMSzdk9GEZ3p3Y9REjPj8t82gea4YLXHBawQYa)b0aNBn6F(KBWk34laqa7MRVdY(G3ublzezNB9hEiTmU)Yszcv6GwJPmxSnIGC1yT5Z8r(G6W6UKK5Nc)1FL6a7gqw476m)9mFIyViKjMp7F9vx7mQgW9j3yWSM6TbOD6A4pi12rYtepFedani2SPg7Ui7r35PG7isHYpB77scsCntd)QxqstkdqETaVunjIVVj7hMOmWKetwaLDyOVt4ZaYam8dVemSXl1BfvTJO4MxcksJ9cE0nLYd3(sqqsk46sIDaeadef7cb8lisTqG5j1n2JGr(lxQfXsIysYIjAOIOMIoUpfsjhowltHpgxMy(FZCwTbIaLzlkbLeBtcqJwCCBi)bo7BiyDH0tSF1eUuofDNYfOlEKgJoKfgRLq99ndxAcUEMXLjuOIlfQr5wRH8oMryAhnW92Z2dIFMMBnj3A3Uc04qtAzgXYzPLfLBnUM1vqKk9MuwDTlXpDTwKnqT3bzmdxzY(0XXwvJbmvaOkmPglZLXUTy7NdJPm9k)W4TYIIKRx9capmeZoKnqcfZBG44hYTwfsES4tuWgqfckRaENGX3eKcitkioC85QmyypsaYjKaBpesKwj8GviQmvn)qruxvrPtjELfT3usXfv0w6fq8nPXwAfWrLQEOiCs(7KAGBcYYs9nTrwGOYsIQmIt)Mgz0iBnHSDRbZDclJtvEzj5BcJGyE3uVLCAp2e0s11wtsmZGLQqgVmAEuz9kABcXKMvbE8Ux1iPC1jnNmwsXCR3KBv9vrSudflhXyMUBe1gDsPmbRSaDnEggDTmcpwSyGNi(zSYvivukPgLq9hOL3bzLfqTcm(Kv2iLtzv4vsyizjs5KlAGcnOWLLyDF4hrYb(NGzaRum3k2DdXd9pW)AAwmWR6anD9Xcwl)YeTBGIqEIeZVWSPUzY2a7AxfacpuTH)nGmMiwMpdMDXhMptxwI)g(mYWKivnkOQe)lJtH)LX(SYNn)R9s5E5F1PUxCDSdu3hf7fcQ9Tn1(d4IqAzauACqDupSCDQCUIdaCQM1dcQJVJIdDTBYTEBhuRcYszxJ3zJPAPP5f4kPPeUIdGEZvIkp1CLEdUI3GRxzUnKTyEH5wziBh5Q5mxVkdkpLdDlOYwT(aKTdYv8SmO8eBvYMQT7uaQEZ4VYQmetXuwJGYKqMfeGlzeRGLNntaiHco8zLvugqoOLav6(3sARIlylXKWaOLRCzgfAom9QKNlctsex8viq6byclPvWxqbW87hM2qjbkY76wrA83bfPExks9xKI0OdfzR8K7trsZK8JhGh5aPPSOo3LY)EDuKHdJsCuS8QYvKRWeKW2yYbUCCtexz8KHrvlllc74Q)tMh69hGhANkLHkxzAVkw9)ptXs9y1N08muWeVGACtsRdqP(SUKSFMQDtXoZWKYDlYxfp94DLCSIyv2l9ItGc2Rdplp8usW2010A2XLUVKDeJPg3xCcK4za6(NzErrqIfUQDPhxiRIpqRcl5zUimilrl1Zn24Ety2TowkEfzNNkvxqQ(SbKKTRgNSnO29oShjjJzL9MUL0kVnMc4b8WJf8xK6vvoZ(4vHWoULZQGXVEgdBau5r(jF010tVgJlei6yUnTle(09M27uNVGDbdiQOhZfZxV6er7Wvx1r2jXLV0ph3nk98RBCTeeB7Wy2LdKgk)clWqLp9HpEjA6tXdHNE9eyydjIfoW20kbplFxxmikeImg9(SvRWCkEbGMGX2xImagY4TkaIUyiESGdgxMQkbdw5SGFQZwvD2ksGY0Z2P4qszUk1NgjlZu9AVigenespwN6JPu2gKp(Kq)BwsOVuLe651UbfjAy1QI6UnEj414O1YjtvfrJKN(PrromFuFqbv4pjrh0E4Mb(RaT9gYxlIu68Oy7mGqicuw6SsqRp9(ACBVMeVc9RyvxXxpODCwcXbTmvzbkr7m7T2(UMP4SttWOUUpOXYCBnwDvwQX21KkKvR5cV1avn)QHRY29Yk9LdrTpB10qF)QKykDJ5wJ5UMGkA04bvvnPnSFsu(IfCXvEvZRAHZ9H7oyAvDH7wxQh82ybwuxVjylyxMPjtSeb1qUKlKfMFoCRDx6gAMa1b9ORiS7z1BP3ksnYBDLi6Q9IBMrecHBCAYcx6fIgoFJUV)mDoNJUUwmyMpbUy4iLxD)TGmqIdO3ZXS)axTYBtuyCAX1(ErrTJjxGh8ju4vm6vNeIXJKS0WnSBTgYdaoV4fp)l07QhVS6pegaeJoCjw04pkJlylcErQ8t6agEK(xh3dK260MKGzzWCwr)zdX)fX3HrUmiW6jcuB2goAu3zfh2f5FZB27jkpDY4D7gn40qefhEmqJX7X98iLZxdXSxszL92qHJKr3bTTgMZ7uns3V3PCyoRO)SH4)I4B1bTgVuNzjK)0h02nroKG2tQC(AiM9skRS3xFowPvfspQmbVYi9LfhDMrFpqmUBEnsWwtNOKUqUk46j)3xYGkDZdh9OnJv)Ckus7Q01kSRIWCIr)H628sRz6mJ(EG4(zpvdxp5)(sMxKBJEpSRYH5eJ(E620AX1bkWZqfUL72PyaCzQoYJ8gvbOJ)Ur6A38wfyfgvXv5pE8dnOOSsjvzBfPO(EPOEbfl19VwkTRE1vAxDguAv(I)Wr7L3zq0XJEvbr9aZBijPUXB7IVRb50I8JGRHXsaZRVxANCopyNEICesWAu10fVxcWPeXhb)INTwxSBX4Nq0QIzV5OlvPZOXJh9hbJRkGrkiNwKFeCDxbkkb70tKJqcKh0ibGtjIpc(vAyt7XpHOvfZERiw7SbLQqEVAJP9slojOSMafcqJH7jsRkYO42aLGyjGCgr(ErB)30qV2BYXtg0Jr5EtU7v01PfT4wksPRtRH7js3R1vkiNrKVx02)JPOxUohpz6015hpPXvNvKxH27pPgubE(0ICaT07NCzOVF4Z0wObFSHWEVF2f7CSm6dIf3hE5Jg1d7Jt8Lpw0knm4Opf4LHzbCq74Ga7qsjlijU)u(NZT((ClCTh8X0k5IrlBAOloOlgT16DYAtbHSkY7HbrLTcmx2Bdc4uSLhQXw(N)evorKClVAefd8fJgU0d7FC2qjAvpH03o9kU3b6LElNsxcV1dhn)ZYMSW1Clhi(7kxomnVdCuI(h5wh87lUcZtzVV4QFJ4N7PfZnIWlV9sSz2Nw6l3dqRF4Q7h2IOLEG1sN1cLXzVZmRnlvIoA64BXf09aTctNmuA)sPghvbdYHP05w(OS(USY3uO)HKofH11X5oQ1KlYt9o9B2TBekxpOpz3UQ0yIW9acx1OY7(saMXdhXdu7oUCyfaIDBz9ik60YXJLlWITNNsTv90RDCNQOxjP2B2tgDiBlRD8wRhoQ9ZzEkOpPtSv)bowgFaYbx75G0V(jD(U6hq9HrRIVlTXGuXhkFoRn1jTFcTp045ZoCqHlxRNnBbd11tMLxwQEUSfFU6PYQI95MhJLv9ONh2H0u9qN)RuweO53ggGMp3yb3y9BAMu)V79ECT8vUKeMVwD(Irv3LEhDMCHwSRUsE8W6q8hmgxmdjDHSQO(9UU5H1mXs1dswFKYmT7)uyfgzlzoC0aMlQKwlUqWu2wXVBLTZy52hHfp27sNnMA5ksxY1ZPt1rCu08Wtn2TBWEBzyPyVr)0wwmXdgqI7rTxDgvadKwq9Wbc1edl5QuTVNo7qHcuWW2hL8bPnLcCZIGrTZaHU4v6KQBzxPdVGRvD3JCWfmlNf5BnxPW0AjC1R(kx3ZTFbAYZQmbV7gPtr5(quODl3IX3k)RwqTavYKGavELJCBTO4EhVmmAk99WFjLMq4B9RREkGXlbTHJhIYP8NH1H32vVgTe6lUJqpafNXlvX1(oT7Nq9A0wEV4UY7auCLB8uu1z0u1P3qXnqHlNCfAD3dOS5b6QHluCuHcxOVKRLRNTrqxTEHIt4wG2sUG(UAOGdWYu8EylShDqVADC7RDx6ynUgnPJtVWkPJWoGUElcgsfbjMlr3e5IG8Bcu64cIGrpeb01eFCUxIVI3sMvV(WhoG6tkVjIHsQlck3zapBv6c2KDfpo2D7u(w7NQJ1xhMKmCpEUpmL7b23FLGXzvjORqj0(mP7sjyiQeuK64fReOEcdu9Q1hklDwfB3EAfrgWIbkxZO8qPOvyVVLmgP(GVmMS)d(Yaw0qrYj1EekLQHYYV2HYq)BoLb(VofrU2Z)1BVL(oVM))c]] )