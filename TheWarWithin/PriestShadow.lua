-- PriestShadow.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR
local spec = Hekili:NewSpecialization( 258 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
-- local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)
local min = ns.safeMin
local GetSpellCooldown = C_Spell.GetSpellCooldown

spec:RegisterResource( Enum.PowerType.Insanity, {
    mind_flay = {
        aura = "mind_flay",
        debuff = true,

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.mind_flay.tick_time ) * class.auras.mind_flay.tick_time
        end,

        interval = function () return class.auras.mind_flay.tick_time end,
        value = 3
    },

    mind_flay_insanity = {
        aura = "mind_flay_insanity_dot",
        debuff = true,

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.mind_flay_insanity_dot.tick_time ) * class.auras.mind_flay_insanity_dot.tick_time
        end,

        interval = function () return class.auras.mind_flay_insanity_dot.tick_time end,
        value = 2
    },

    void_lasher_mind_sear = {
        aura = "void_lasher_mind_sear",
        debuff = true,

        last = function ()
            local app = state.debuff.void_lasher_mind_sear.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = function () return class.auras.void_lasher_mind_sear.tick_time end,
        value = 1
    },

    void_tendril_mind_flay = {
        aura = "void_tendril_mind_flay",
        debuff = true,

        last = function ()
            local app = state.debuff.void_tendril_mind_flay.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = function () return class.auras.void_tendril_mind_flay.tick_time end,
        value = 1
    },

    void_torrent = {
        channel = "void_torrent",

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.abilities.void_torrent.tick_time ) * class.abilities.void_torrent.tick_time
        end,

        interval = function () return class.abilities.void_torrent.tick_time end,
        value = 6
    },

    voidwraith = {
        aura = "voidwraith",

        last = function ()
            local app = state.buff.voidwraith.expires - ( 15 * ( state.talent.subservient_shadows.enabled and 1.2 or 1 ) )
            local t = state.query_time

            return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
        end,

        interval = function () return 1.5 * state.haste * ( state.conduit.rabid_shadows.enabled and 0.85 or 1 ) end,
        value = 2
    },

    mindbender = {
        aura = "mindbender",

        last = function ()
            local app = state.buff.mindbender.expires - ( 15 * ( state.talent.subservient_shadows.enabled and 1.2 or 1 ) )
            local t = state.query_time

            return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
        end,

        interval = function () return 1.5 * state.haste * ( state.conduit.rabid_shadows.enabled and 0.85 or 1 ) end,
        value = 2
    },

    shadowfiend = {
        aura = "shadowfiend",

        last = function ()
            local app = state.buff.shadowfiend.expires - ( 15 * ( state.talent.subservient_shadows.enabled and 1.2 or 1 ) )
            local t = state.query_time

            return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
        end,

        interval = function () return 1.5 * state.haste * ( state.conduit.rabid_shadows.enabled and 0.85 or 1 ) end,
        value = 2
    },

    -- Gain 10 insanity every new halo ring via power surge (5s)
    halo_power_surge = {
        aura = "power_surge",

        last = function ()
            local app = state.buff.power_surge.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 5,
        value = 10,
    },

    -- Gain 10 insanity over 5s
    halo_power_surge_tww3_2pc = {
        aura = "power_surge",
        set_bonus = "tww3_2pc",

        last = function ()
            local app = state.buff.power_surge.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 2,
    }
} )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {

    -- Priest
    angelic_bulwark                = {  82675,  108945, 1 }, -- When an attack brings you below $s1% health, you gain an absorption shield equal to $s2% of your maximum health for $s3 sec. Cannot occur more than once every $s4 sec
    angelic_feather                = {  82703,  121536, 1 }, -- Places a feather at the target location, granting the first ally to walk through it $s1% increased movement speed for $s2 sec. Only $s3 feathers can be placed at one time
    angels_mercy                   = {  82678,  238100, 1 }, -- Reduces the cooldown of Desperate Prayer by $s1 sec
    apathy                         = {  82689,  390668, 1 }, -- Your Mind Blast critical strikes reduce your target's movement speed by $s1% for $s2 sec
    benevolence                    = {  82676,  415416, 1 }, -- Increases the healing of your spells by $s1%
    binding_heals                  = {  82678,  368275, 1 }, -- $s1% of Flash Heal healing on other targets also heals you
    blessed_recovery               = {  82720,  390767, 1 }, -- After being struck by a melee or ranged critical hit, heal $s1% of the damage taken over $s2 sec
    body_and_soul                  = {  82706,   64129, 1 }, -- Power Word: Shield and Leap of Faith increase your target's movement speed by $s1% for $s2 sec
    cauterizing_shadows            = {  82687,  459990, 1 }, -- When your Shadow Word: Pain expires or is refreshed with less than $s1 sec remaining, a nearby ally within $s2 yards is healed for $s3
    crystalline_reflection         = {  82681,  373457, 2 }, -- Power Word: Shield instantly heals the target for $s1 and reflects $s2% of damage absorbed
    death_and_madness              = {  82711,  321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below $s1% health, its cooldown is reset. Cannot occur more than once every $s2 sec. If a target dies within $s3 sec after being struck by your Shadow Word: Death, you gain $s4 Insanity
    dispel_magic                   = {  82715,     528, 1 }, -- Dispels Magic on the enemy target, removing $s1 beneficial Magic effect
    divine_star                    = {  82680,  122121, 1 }, -- Throw a Divine Star forward $s2 yds, healing allies in its path for $s3 and dealing $s$s4 Shadow damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond $s5 targets. Generates $s6 Insanity
    dominate_mind                  = {  82710,  205364, 1 }, -- Controls a mind up to $s1 level above yours for $s2 sec while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings or players. This spell shares diminishing returns with other disorienting effects
    essence_devourer               = {  82674,  415479, 1 }, -- Attacks from your Shadowfiend siphon life from enemies, healing a nearby injured ally for $s1. Attacks from your Mindbender siphon life from enemies, healing a nearby injured ally for $s2
    focused_mending                = {  82719,  372354, 1 }, -- Prayer of Mending does $s1% increased healing to the initial target
    from_darkness_comes_light      = {  82707,  390615, 1 }, -- Each time Shadow Word: Pain deals damage, the healing of your next Flash Heal is increased by $s1%, up to a maximum of $s2%
    halo                           = {  82680,  120644, 1 }, -- Creates a ring of Shadow energy around you that quickly expands to a $s2 yd radius, healing allies for $s3 and dealing $s$s4 Shadow damage to enemies. Healing reduced beyond $s5 targets. Generates $s6 Insanity
    holy_nova                      = {  82701,  132157, 1 }, -- An explosion of holy light around you deals up to $s$s2 Holy damage to enemies and up to $s3 healing to allies within $s4 yds, reduced if there are more than $s5 targets
    improved_fade                  = {  82686,  390670, 2 }, -- Reduces the cooldown of Fade by $s1 sec
    improved_flash_heal            = {  82714,  393870, 1 }, -- Increases healing done by Flash Heal by $s1%
    inspiration                    = {  82696,  390676, 1 }, -- Reduces your target's physical damage taken by $s1% for $s2 sec after a critical heal with Flash Heal
    leap_of_faith                  = {  82716,   73325, 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you
    lights_inspiration             = {  82679,  373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by $s1%
    manipulation                   = {  82672,  459985, 1 }, -- You take $s1% less damage from enemies affected by your Shadow Word: Pain
    mass_dispel                    = {  82699,   32375, 1 }, -- Dispels magic in a $s1 yard radius, removing all harmful Magic from $s2 friendly targets and $s3 beneficial Magic effect from $s4 enemy targets. Potent enough to remove Magic that is normally undispellable
    mental_agility                 = {  82698,  341167, 1 }, -- Reduces the mana cost of Purify Disease and Mass Dispel by $s1% and Dispel Magic by $s2%
    mind_control                   = {  82710,     605, 1 }, -- Controls a mind up to $s1 level above yours for $s2 sec. Does not work versus Demonic, Undead, or Mechanical beings. Shares diminishing returns with other disorienting effects
    move_with_grace                = {  82702,  390620, 1 }, -- Reduces the cooldown of Leap of Faith by $s1 sec
    petrifying_scream              = {  82695,   55676, 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear
    phantasm                       = {  82556,  108942, 1 }, -- Activating Fade removes all snare effects
    phantom_reach                  = {  82673,  459559, 1 }, -- Increases the range of most spells by $s1%
    power_infusion                 = {  82694,   10060, 1 }, -- Infuses the target with power for $s1 sec, increasing haste by $s2%. Can only be cast on players
    power_word_life                = {  82676,  373481, 1 }, -- A word of holy power that heals the target for $s1. Only usable if the target is below $s2% health
    prayer_of_mending              = {  82718,   33076, 1 }, -- Places a ward on an ally that heals them for $s1 the next time they take damage, and then jumps to another ally within $s2 yds. Jumps up to $s3 times and lasts $s4 sec after each jump
    protective_light               = {  82707,  193063, 1 }, -- Casting Flash Heal on yourself reduces all damage you take by $s1% for $s2 sec
    psychic_voice                  = {  82695,  196704, 1 }, -- Reduces the cooldown of Psychic Scream by $s1 sec
    purify_disease                 = {  82704,  213634, 1 }, -- Removes all Disease effects from a friendly target
    renew                          = {  82717,     139, 1 }, -- Fill the target with faith in the light, healing for $s1 over $s2 sec
    rhapsody                       = {  82700,  390622, 1 }, -- Every $s1 sec, the damage of your next Holy Nova is increased by $s2% and its healing is increased by $s3%. Stacks up to $s4 times
    sanguine_teachings             = {  82691,  373218, 1 }, -- Increases your Leech by $s1%
    sanlayn                        = {  82690,  199855, 1 }, --  Sanguine Teachings Sanguine Teachings grants an additional $s3% Leech.  Vampiric Embrace Reduces the cooldown of Vampiric Embrace by $s6 sec, increases its healing done by $s7%
    shackle_undead                 = {  82693,    9484, 1 }, -- Shackles the target undead enemy for $s1 sec, preventing all actions and movement. Damage will cancel the effect. Limit $s2
    shadow_word_death              = {  82712,   32379, 1 }, -- A word of dark binding that inflicts $s$s2 Shadow damage to your target. If your target is not killed by Shadow Word: Death, you take backlash damage equal to $s3% of your maximum health. Damage increased by $s4% to targets below $s5% health. Generates $s6 Insanity
    shadowfiend                    = {  82713,   34433, 1 }, -- Summons a shadowy fiend to attack the target for $s1 sec. Generates $s2 Insanity each time the Shadowfiend attacks
    sheer_terror                   = {  82708,  390919, 1 }, -- Increases the amount of damage required to break your Psychic Scream by $s1%
    spell_warding                  = {  82720,  390667, 1 }, -- Reduces all magic damage taken by $s1%
    surge_of_light                 = {  82677,  109186, 1 }, -- Your healing spells and Smite have a $s1% chance to make your next Flash Heal instant and cost $s2% less mana. Stacks to $s3
    throes_of_pain                 = {  82709,  377422, 2 }, -- Shadow Word: Pain deals an additional $s1% damage. When an enemy dies while afflicted by your Shadow Word: Pain, you gain $s2 Insanity
    tithe_evasion                  = {  82688,  373223, 1 }, -- Shadow Word: Death deals $s1% less damage to you
    translucent_image              = {  82685,  373446, 1 }, -- Fade reduces damage you take by $s1%
    twins_of_the_sun_priestess     = {  82683,  373466, 1 }, -- Power Infusion also grants you its effect at $s1% value when used on an ally. If no ally is targeted, it will grant its effect at $s2% value to a nearby ally, preferring damage dealers
    twist_of_fate                  = {  82684,  390972, 2 }, -- After damaging or healing a target below $s1% health, gain $s2% increased damage and healing for $s3 sec
    unwavering_will                = {  82697,  373456, 2 }, -- While above $s1% health, the cast time of your Flash Heal is reduced by $s2%
    vampiric_embrace               = {  82691,   15286, 1 }, -- Fills you with the embrace of Shadow energy for $s1 sec, causing you to heal a nearby ally for $s2% of any single-target Shadow spell damage you deal
    void_shield                    = {  82692,  280749, 1 }, -- When cast on yourself, $s1% of damage you deal refills your Power Word: Shield
    void_shift                     = {  82674,  108968, 1 }, -- Swap health percentages with your ally. Increases the lower health percentage of the two to $s1% if below that amount
    void_tendrils                  = {  82708,  108920, 1 }, -- Summons shadowy tendrils, rooting all enemies within $s1 yards for $s2 sec or until the tendril is killed
    words_of_the_pious             = {  82721,  377438, 1 }, -- For $s1 sec after casting Power Word: Shield, you deal $s2% additional damage and healing with Smite and Holy Nova

    -- Shadow
    ancient_madness                = {  82656,  341240, 1 }, -- Voidform and Dark Ascension increase the critical strike chance of your spells by $s1% for $s2 sec, reducing by $s3% every sec
    auspicious_spirits             = {  82667,  155271, 1 }, -- Your Shadowy Apparitions deal $s1% increased damage and have a chance to generate $s2 Insanity
    dark_ascension                 = {  82657,  391109, 1 }, -- Increases your non-periodic Shadow damage by $s1% for $s2 sec. Generates $s3 Insanity
    dark_evangelism                = { 108031,  391099, 1 }, -- Increases your periodic spell damage by $s1%
    dark_thoughts                  = {  82660, 1240388, 1 }, -- Increases the chance for Shadowy Insight to occur by $s1%. When consuming Shadowy Insight, Mind Blast generates $s2 additional Insanity
    deaths_torment                 = { 108006, 1240364, 1 }, -- Shadow Word: Death deals damage $s1 additional times at $s2% effectiveness
    deathspeaker                   = {  82558,  392507, 1 }, -- Shadow Word: Death damage increased by $s1%. Shadow Word: Death gains its damage and talent bonuses against targets below $s2% health instead of $s3%
    descending_darkness            = { 108029, 1242666, 1 }, -- Increases Shadow Crash damage by $s1%
    devouring_plague               = {  82665,  335467, 1 }, -- Afflicts the target with a disease that instantly causes $s$s3 Shadow damage plus an additional $s$s4 Shadow damage over $s5 sec. Heals you for $s6% of damage dealt. If this effect is reapplied, any remaining damage will be added to the new Devouring Plague
    dispersion                     = {  82663,   47585, 1 }, -- Disperse into pure shadow energy, reducing all damage taken by $s1% for $s2 sec and healing you for $s3% of your maximum health over its duration, but you are unable to attack or cast spells. Increases movement speed by $s4% and makes you immune to all movement impairing effects. Castable while stunned, feared, or silenced
    distorted_reality              = {  82647,  409044, 1 }, -- Increases the damage of Devouring Plague by $s1% and causes it to deal its damage over $s2 sec, but increases its Insanity cost by $s3
    idol_of_cthun                  = {  82643,  377349, 1 }, -- Mind Flay has a chance to spawn a Void Tendril that channels Mind Flay or Void Lasher that channels Mind Sear at your target. Casting Void Torrent or Void Volley always spawns one.  Mind Flay Assaults the target's mind with Shadow energy, causing $s$s5 Shadow damage over $s6 sec and slowing their movement speed by $s7%. Generates $s8 Insanity over the duration.  Mind Sear Corrosive shadow energy radiates from the target, dealing $s$s11 Shadow damage over $s12 sec to all enemies within $s13 yards of the target. Damage reduced beyond $s14 targets. Generates $s15 Insanity over the duration
    idol_of_nzoth                  = {  82552,  373280, 1 }, -- You create Horrific Visions when casting harmful spells on enemies. At $s3 stacks of Horrific Visions, your target sees a nightmare, dealing $s$s4 Shadow damage and granting you $s5 Insanity over $s6 sec. At $s7 stacks, your target witnesses a vision of N'Zoth, dealing $s$s8 Shadow damage and granting you $s9 Insanity over $s10 sec
    idol_of_yoggsaron              = {  82555,  373273, 1 }, -- After conjuring Shadowy Apparitions, gain a stack of Idol of Yogg-Saron. At $s3 stacks, you summon a Thing from Beyond that casts Void Spike at nearby enemies for $s4 sec.  Void Spike Hurls a bolt of dark magic, dealing $s$s7 Shadow damage and $s$s8 Shadow damage to all enemies within $s9 yards of the target. Damage reduced beyond $s10 targets
    idol_of_yshaarj                = {  82553,  373310, 1 }, -- Your damaging spells have a chance to grant Call of the Void, increasing your haste by $s1% for $s2 sec. When Call of the Void ends you are afflicted with Overburdened Mind, reducing your haste by $s3% for $s4 sec
    inescapable_torment            = {  82644,  373427, 1 }, -- Mind Blast and Shadow Word: Death cause your Mindbender or Shadowfiend to teleport behind your target, slashing up to $s2 nearby enemies for $s$s3 Shadow damage and extending its duration by $s4 sec
    insidious_ire                  = {  82560,  373212, 2 }, -- While you have Shadow Word: Pain, Devouring Plague, and Vampiric Touch active on the same target, your Mind Blast, Void Torrent, and Void Volley deal $s1% more damage
    instilled_doubt                = { 108152, 1242862, 2 }, -- Increases the critical strike chance of Vampiric Touch and Shadow Word: Pain by $s1% and their critical strike damage by $s2%
    intangibility                  = {  82659,  288733, 1 }, -- Dispersion heals you for an additional $s1% of your maximum health over its duration and its cooldown is reduced by $s2 sec
    last_word                      = {  82652,  263716, 1 }, -- Reduces the cooldown of Silence by $s1 sec
    maddening_touch                = {  82662,  391228, 2 }, -- Vampiric Touch deals $s1% additional damage and has a chance to generate $s2 Insanity each time it deals damage
    madness_weaving                = {  82671, 1240394, 2 }, -- The damage bonus from your Mastery: Shadow Weaving gains $s1% additional benefit from Devouring Plague
    mastermind                     = {  82645,  391151, 2 }, -- Increases the critical strike chance of Mind Blast, Mind Flay, and Shadow Word: Death by $s1% and increases their critical strike damage by $s2%
    mental_decay                   = {  82658,  375994, 1 }, -- Increases the damage of Mind Flay by $s1%. The duration of your Shadow Word: Pain and Vampiric Touch is increased by $s2 sec when enemies suffer damage from Mind Flay
    mental_fortitude               = {  82659,  377065, 1 }, -- Healing from Vampiric Touch and Devouring Plague when you are at maximum health will shield you for the same amount. The shield cannot exceed $s1% of your maximum health
    mind_devourer                  = { 108153,  373202, 1 }, -- Mind Blast has a $s1% chance to make your next Devouring Plague cost no Insanity and deal $s2% additional damage
    mindbender                     = {  82648,  200174, 1 }, -- Summons a Mindbender to attack the target for $s1 sec. Generates $s2 Insanity each time the Mindbender attacks
    minds_eye                      = {  82647,  407470, 1 }, -- Reduces the Insanity cost of Devouring Plague by $s1
    misery                         = {  93171,  238558, 1 }, -- Vampiric Touch also applies Shadow Word: Pain to the target. Shadow Word: Pain lasts an additional $s1 sec
    phantasmal_pathogen            = {  82563,  407469, 2 }, -- Shadow Apparitions deal $s1% increased damage to targets affected by your Devouring Plague
    phantom_menace                 = {  82646, 1242779, 1 }, -- Increases the critical strike chance of Shadowy Apparitions by $s1% and their critical strike damage by $s2%
    psychic_horror                 = {  82652,   64044, 1 }, -- Terrifies the target in place, stunning them for $s1 sec
    psychic_link                   = {  82670,  199484, 1 }, -- Your direct damage spells inflict $s1% of their damage on all other targets afflicted by your Vampiric Touch within $s2 yards. Does not apply to damage from Shadowy Apparitions, Shadow Word: Pain, and Vampiric Touch
    screams_of_the_void            = {  82649,  375767, 2 }, -- Devouring Plague causes your Shadow Word: Pain and Vampiric Touch to deal damage $s1% faster on all targets for $s2 sec
    shadow_crash_ground            = { 108007,  205385, 1 }, -- Aim a bolt of slow-moving Shadow energy at the destination, dealing $s$s2 Shadow damage to all enemies within $s3 yds and applying Vampiric Touch to up to $s4 of them. Generates $s5 Insanity. This spell is cast at a selected location
    shadow_crash_targeted          = { 108007,  457042, 1 }, -- Hurl a bolt of slow-moving Shadow energy at your target, dealing $s$s2 Shadow damage to all enemies within $s3 yds and applying Vampiric Touch to up to $s4 of them. Generates $s5 Insanity. This spell is cast at your target
    shadowy_apparitions            = {  82666,  341491, 1 }, -- Mind Blast, Devouring Plague, and Void Bolt conjure Shadowy Apparitions that float towards all targets afflicted by your Vampiric Touch for $s$s2 Shadow damage
    shadowy_insight                = {  82669,  375888, 1 }, -- Shadow Word: Pain periodic damage has a chance to reset the remaining cooldown on Mind Blast and cause your next Mind Blast to be instant
    shattered_psyche               = {  82658,  391090, 1 }, -- Mind Flay damage increases the critical strike chance of Mind Blast by $s1%, stacking up to $s2 times. Lasts $s3 sec
    silence                        = {  82651,   15487, 1 }, -- Silences the target, preventing them from casting spells for $s1 sec. Against non-players, also interrupts spellcasting and prevents any spell in that school from being cast for $s2 sec
    subservient_shadows            = {  82559, 1228516, 1 }, -- Summoned minions last $s1% longer and deal an additional $s2% damage
    surge_of_insanity              = {  82668,  391399, 1 }, -- Every $s2 casts of Devouring Plague transforms your next Mind Flay into a more powerful spell. Can accumulate up to $s3 charges.  Mind Flay: Insanity Assaults the target's mind with Shadow energy, causing $s$s6 Shadow damage over $s7 sec and slowing their movement speed by $s8%. Generates $s9 Insanity over the duration
    thought_harvester              = {  82653,  406788, 1 }, -- Mind Blast gains an additional charge
    tormented_spirits              = {  93170,  391284, 1 }, -- Your Shadow Word: Pain damage has a chance to create Shadowy Apparitions that float towards all targets afflicted by your Vampiric Touch. Critical strikes increase the chance by $s1%
    void_eruption                  = {  82657,  228260, 1 }, -- Releases an explosive blast of pure void energy, activating Voidform and causing $s$s2 Shadow damage to all enemies within $s3 yds of your target. During Voidform, this ability is replaced by Void Bolt. Casting Devouring Plague increases the duration of Voidform by $s4 sec
    void_torrent                   = {  82654,  263165, 1 }, -- Channel a torrent of void energy into the target, dealing $s$s2 Shadow damage over $s3 sec. Generates $s4 Insanity over the duration
    void_volley                    = {  82655, 1240401, 1 }, -- Void Torrent is replaced with Void Volley for $s2 sec after it is cast.  Void Volley Releases a volley of pure void energy, firing $s5 bolts at your target and $s6 bolt at all enemies within $s7 yards of your target for $s$s8 Shadow damage. Generates $s9 Insanity
    voidtouched                    = { 108147,  407430, 1 }, -- Increases your Devouring Plague damage by $s1% and increases your maximum Insanity by $s2

    -- Archon
    concentrated_infusion          = {  94676,  453844, 1 }, -- Your Power Infusion effect grants you an additional $s1% haste
    divine_halo                    = {  94702,  449806, 1 }, -- Halo now centers around you and returns to you after it reaches its maximum distance, healing allies and damaging enemies each time it passes through them
    empowered_surges               = {  94688,  453799, 1 }, -- Increases the damage done by Mind Flay: Insanity by $s1%. Increases the healing done by Flash Heals affected by Surge of Light by $s2%
    energy_compression             = {  94678,  449874, 1 }, -- Halo damage and healing is increased by $s1%
    energy_cycle                   = {  94685,  453828, 1 }, -- Consuming Surge of Insanity has a $s1% chance to conjure Shadowy Apparitions
    heightened_alteration          = {  94680,  453729, 1 }, -- Increases the duration of Dispersion by $s1 sec
    incessant_screams              = {  94686,  453918, 1 }, -- Psychic Scream creates an image of you at your location. After $s1 sec, the image will let out a Psychic Scream
    manifested_power               = {  94699,  453783, 1 }, -- Creating a Halo grants Surge of Insanity
    perfected_form                 = {  94677,  453917, 1 }, -- Your damage dealt is increased by $s1% while Dark Ascension is active and by $s2% while Voidform is active
    power_surge                    = {  94697,  453109, 1 }, -- Casting Halo also causes you to create a Halo around you at $s1% effectiveness every $s2 sec for $s3 sec. Additionally, the radius of Halo is increased by $s4 yards
    resonant_energy                = {  94681,  453845, 1 }, -- Enemies damaged by your Halo take $s1% increased damage from you for $s2 sec, stacking up to $s3 times
    shock_pulse                    = {  94686,  453852, 1 }, -- Halo damage reduces enemy movement speed by $s1% for $s2 sec, stacking up to $s3 times
    sustained_potency              = {  94678,  454001, 1 }, -- Creating a Halo extends the duration of Voidform by $s1 sec. If Voidform is not active, up to $s2 seconds is stored. While out of combat or affected by a loss of control effect, the duration of Voidform is paused for up to $s3 sec
    word_of_supremacy              = {  94680,  453726, 1 }, -- Power Word: Fortitude grants you an additional $s1% stamina

    -- Voidweaver
    collapsing_void                = {  94694,  448403, 1 }, -- Each time you cast Devouring Plague, Entropic Rift is empowered, increasing its damage and size by $s2%. After Entropic Rift ends it collapses, dealing $s$s3 Shadow damage split amongst enemy targets within $s4 yds
    dark_energy                    = {  94693,  451018, 1 }, -- Void Torrent can be used while moving. While Entropic Rift is active, you move $s1% faster
    darkening_horizon              = {  94695,  449912, 1 }, -- Void Blast increases the duration of Entropic Rift by $s1 sec, up to a maximum of $s2 sec
    depth_of_shadows               = { 100212,  451308, 1 }, -- Shadow Word: Death has a high chance to summon a Shadowfiend for $s1 sec when damaging targets below $s2% health
    devour_matter                  = {  94668,  451840, 1 }, -- Shadow Word: Death consumes absorb shields from your target, dealing $s$s2 extra damage to them and granting you $s3 Insanity if a shield was present
    embrace_the_shadow             = {  94696,  451569, 1 }, -- You absorb $s1% of all magic damage taken. Absorbing Shadow damage heals you for $s2% of the amount absorbed
    entropic_rift                  = {  94684,  447444, 1 }, -- Void Torrent tears open an Entropic Rift that follows the enemy for $s2 sec. Enemies caught in its path suffer $s$s3 Shadow damage every $s4 sec while within its reach
    inner_quietus                  = {  94670,  448278, 1 }, -- Vampiric Touch and Shadow Word: Pain deal $s1% additional damage
    no_escape                      = {  94693,  451204, 1 }, -- Entropic Rift slows enemies by up to $s1%, increased the closer they are to its center
    void_blast                     = {  94703,  450405, 1 }, -- Entropic Rift upgrades Mind Blast into Void Blast while it is active. Void Blast: Sends a blast of cosmic void energy at the enemy, causing $s$s2 Shadow damage. Generates $s3 Insanity
    void_empowerment               = {  94695,  450138, 1 }, -- Summoning an Entropic Rift grants you Mind Devourer
    void_infusion                  = {  94669,  450612, 1 }, -- Void Blast generates $s1% additional Insanity
    void_leech                     = {  94696,  451311, 1 }, -- Every $s1 sec siphon an amount equal to $s2% of your health from an ally within $s3 yds if they are higher health than you
    voidheart                      = {  94692,  449880, 1 }, -- While Entropic Rift is active, your Shadow damage is increased by $s1%
    voidwraith                     = { 100212,  451234, 1 }, -- Transform your Shadowfiend or Mindbender into a Voidwraith. Voidwraith Summon a Voidwraith for $s3 sec that casts Void Flay from afar. Void Flay deals bonus damage to high health enemies, up to a maximum of $s4% if they are full health. Generates $s5 Insanity each time the Voidwraith attacks
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_faith                 = 5481, -- (408853) Leap of Faith also pulls the spirit of the $s1 furthest allies within $s2 yards and shields you and the affected allies for $s3
    cascading_horrors              = 5447, -- (357711) After casting Void Eruption or Dark Ascension, send a slow-moving bolt of Shadow energy at a random location every $s2 sec for $s3 sec, dealing $s$s4 Shadow damage to all targets within $s5 yds, and causing them to flee in Horror for $s6 sec
    catharsis                      = 5486, -- (391297) $s1% of all damage you take is stored. The stored amount cannot exceed $s2% of your maximum health. The initial damage of your next Shadow Word: Pain deals this stored damage to your target
    driven_to_madness              =  106, -- (199259) While Voidform or Dark Ascension is not active, being attacked will reduce the cooldown of Void Eruption and Dark Ascension by $s1 sec
    improved_mass_dispel           = 5636, -- (426438) Reduces the cooldown of Mass Dispel by $s1 sec
    mind_trauma                    =  113, -- (199445) Siphon haste from enemies, stealing $s1% haste per stack of Mind Trauma, stacking up to $s2 times. Fully channeled Mind Flays grant $s3 stack of Mind Trauma and fully channeled Void Torrents grant $s4 stacks of Mind Trauma. Lasts $s5 sec. You can only gain $s6 stacks of Mind Trauma from a single enemy
    mindgames                      = 5638, -- (375901) Assault an enemy's mind, dealing $s$s2 Shadow damage and briefly reversing their perception of reality. For $s3 sec, the next $s4 damage they deal will heal their target, and the next $s5 healing they deal will damage their target. Generates $s6 Insanity
    phase_shift                    = 5568, -- (408557) Step into the shadows when you cast Fade, avoiding all attacks and spells for $s1 sec. Interrupt effects are not affected by Phase Shift
    psyfiend                       =  763, -- (211522) Summons a Psyfiend with $s1 health for $s2 sec beside you to attack the target at range with Psyflay.  Psyflay Deals up to $s5% of the target's total health in Shadow damage every $s6 sec. Also slows their movement speed by $s7% and reduces healing received by $s8%
    thoughtsteal                   = 5381, -- (316262) Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for $s1 sec. Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset
} )

-- Auras
spec:RegisterAuras( {
    ancient_madness = {
        id = 341240,
        duration = 20,
        max_stack = 20
    },
    angelic_feather = {
        id = 121557,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=390669
    apathy = {
        id = 390669,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    blessed_recovery = {
        id = 390771,
        duration = 6,
        tick_time = 2,
        max_stack = 1
    },
    -- Talent: Movement speed increased by $s1%.
    -- https://wowhead.com/beta/spell=65081
    body_and_soul = {
        id = 65081,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Call of the Void Haste increased by $s1%. $s2 seconds remaining
    -- https://www.wowhead.com/spell=373316
    call_of_the_void = {
        id = 373316,
        duration = 12,
        max_stack = 1,
        onRemove = function()
            applyBuff( "overburdened_mind" )
        end,
    },
    -- Talent: Your non-periodic Shadow damage is increased by $w1%. $?s341240[Critical strike chance increased by ${$W4}.1%.][]
    -- https://wowhead.com/beta/spell=391109
    dark_ascension = {
        id = 391109,
        duration = 20,
        max_stack = 1
    },
    dark_thought = {
        id = 341207,
        duration = 10,
        max_stack = 1,
        copy = "dark_thoughts"
    },
    death_and_madness_debuff = {
        id = 322098,
        duration = 7,
        max_stack = 1
    },
    -- Talent: Shadow Word: Death damage increased by $s2% and your next Shadow Word: Death deals damage as if striking a target below $32379s2% health.
    -- https://wowhead.com/beta/spell=392511
    deathspeaker = {
        id = 392511,
        duration = 15,
        max_stack = 1
    },
    -- Maximum health increased by $w1%.
    -- https://wowhead.com/beta/spell=19236
    desperate_prayer = {
        id = 19236,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=335467
    devouring_plague = {
        id = 335467,
        duration = function() return talent.distorted_reality.enabled and 12 or 6 end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $s1%. Healing for $?s288733[${$s5+$288733s2}][$s5]% of maximum health.    Cannot attack or cast spells.    Movement speed increased by $s4% and immune to all movement impairing effects.
    -- https://wowhead.com/beta/spell=47585
    dispersion = {
        id = 47585,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Healing received increased by $w2%.
    -- https://wowhead.com/beta/spell=64844
    divine_hymn = {
        id = 64844,
        duration = 15,
        type = "Magic",
        max_stack = 5
    },
    -- Talent: Under the control of the Priest.
    -- https://wowhead.com/beta/spell=205364
    dominate_mind = {
        id = 205364,
        duration = 30,
        mechanic = "charm",
        type = "Magic",
        max_stack = 1
    },
    echoing_void = {
        id = 373281,
        duration = 20,
        max_stack = 20
    },
    empty_mind = {
        id = 247226,
        duration = 12,
        max_stack = 10
    },
    entropic_rift = {
        duration = 8,
        max_stack = 1
    },
    -- Reduced threat level. Enemies have a reduced attack range against you.$?e3  [   Damage taken reduced by $s4%.][]
    -- https://wowhead.com/beta/spell=586
    fade = {
        id = 586,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Covenant: Damage taken reduced by $w2%.
    -- https://wowhead.com/beta/spell=324631
    fleshcraft = {
        id = 324631,
        duration = 3,
        tick_time = 0.5,
        max_stack = 1
    },
    -- All magical damage taken reduced by $w1%.; All physical damage taken reduced by $w2%.
    -- https://wowhead.com/beta/spell=426401
    focused_will = {
        id = 426401,
        duration = 8,
        max_stack = 1
    },
    -- Penance fires $w2 additional $Lbolt:bolts;.
    harsh_discipline = {
        id = 373183,
        duration = 30,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=1243069
    horrific_visions = {
        id = 1243069,
        duration = 30,
        max_stack = 99,
        type = "magic"
    },
    -- Talent: Conjuring $373273s1 Shadowy Apparitions will summon a Thing from Beyond.
    -- https://wowhead.com/beta/spell=373276
    idol_of_yoggsaron = {
        id = 373276,
        duration = 120,
        max_stack = 25
    },
    insidious_ire = {
        id = 373213,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Reduces physical damage taken by $s1%.
    -- https://wowhead.com/beta/spell=390677
    inspiration = {
        id = 390677,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Being pulled toward the Priest.
    -- https://wowhead.com/beta/spell=73325
    leap_of_faith = {
        id = 73325,
        duration = 1.5,
        mechanic = "grip",
        type = "Magic",
        max_stack = 1
    },
    levitate = {
        id = 111759,
        duration = 600,
        type = "Magic",
        max_stack = 1
    },
    mental_fortitude = {
        id = 377066,
        duration = 15,
        max_stack = 1,
        copy = 194022
    },
    -- Talent: Under the command of the Priest.
    -- https://wowhead.com/beta/spell=605
    mind_control = {
        id = 605,
        duration = 30,
        mechanic = "charm",
        type = "Magic",
        max_stack = 1
    },
    mind_devourer = {
        id = 373204,
        duration = 15,
        max_stack = 1,
        copy = 338333
    },
    -- Movement speed slowed by $s2% and taking Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=15407
    mind_flay = {
        id = 15407,
        duration = function () return 4.5 * haste end,
        tick_time = function () return 0.75 * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed slowed by $s2% and taking Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=391403
    mind_flay_insanity = {
        id = 391401,
        duration = 30,
        max_stack = 4
    },
    mind_flay_insanity_dot = {
        id = 391403,
        duration = function () return 2 * haste end,
        tick_time = function () return 0.5 * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: The cast time of your next Mind Blast is reduced by $w1% and its critical strike chance is increased by $s2%.
    -- https://wowhead.com/beta/spell=391092
    shattered_psyche = {
        id = 391092,
        duration = 10,
        max_stack = 12
    },
    -- Reduced distance at which target will attack.
    -- https://wowhead.com/beta/spell=453
    mind_soothe = {
        id = 453,
        duration = 20,
        type = "Magic",
        max_stack = 1
    },
    -- Sight granted through target's eyes.
    -- https://wowhead.com/beta/spell=2096
    mind_vision = {
        id = 2096,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Talent / Covenant: The next $w2 damage and $w5 healing dealt will be reversed.
    -- https://wowhead.com/beta/spell=323673
    mindgames = {
        id = 375901,
        duration = 5,
        type = "Magic",
        max_stack = 1,
        copy = 323673
    },
    mind_trauma = {
        id = 247776,
        duration = 15,
        max_stack = 1
    },
    -- Overburdened Mind Haste reduced by $s1%. $s2 seconds remaining
    -- https://www.wowhead.com/spell=373317
    overburdened_mind = {
        id = 373317,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=10060
    power_infusion = {
        id = 10060,
        duration = 15,
        max_stack = 1
    },
    power_surge = {
        id = 453113,
        duration = 10,
        tick_time = 5,
        max_stack = 1
    },
    -- Stamina increased by $w1%.$?$w2>0[  Magic damage taken reduced by $w2%.][]
    -- https://wowhead.com/beta/spell=21562
    power_word_fortitude = {
        id = 21562,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        shared = "player" -- use anyone's buff on the player, not just player's.
    },
    -- Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=17
    power_word_shield = {
        id = 17,
        duration = 15,
        mechanic = "shield",
        type = "Magic",
        max_stack = 1
    },
    protective_light = {
        id = 193065,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=64044
    psychic_horror = {
        id = 64044,
        duration = 4,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Disoriented.
    -- https://wowhead.com/beta/spell=8122
    psychic_scream = {
        id = 8122,
        duration = 8,
        mechanic = "flee",
        type = "Magic",
        max_stack = 1
    },
    -- $w1 Radiant damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=204213
    purge_the_wicked = {
        id = 204213,
        duration = 20,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Healing $w1 health every $t1 sec.
    -- https://wowhead.com/beta/spell=139
    renew = {
        id = 139,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    rhapsody = {
        id = 390636,
        duration = 3600,
        max_stack = 20
    },
    -- Taking $s2% increased damage from the Priest.
    -- https://wowhead.com/beta/spell=214621
    schism = {
        id = 214621,
        duration = 9,
        type = "Magic",
        max_stack = 1
    },
    -- Shadow Word: Pain and Vampiric Touch are dealing damage $w2% faster.
    screams_of_the_void = {
        id = 393919,
        duration = 3,
        max_stack = 1
    },
    -- Talent: Shackled.
    -- https://wowhead.com/beta/spell=9484
    shackle_undead = {
        id = 9484,
        duration = 50,
        mechanic = "shackle",
        type = "Magic",
        max_stack = 1
    },
    shadow_crash_debuff = {
        id = 342385,
        duration = 15,
        max_stack = 2
    },
    -- Suffering $w2 Shadow damage every $t2 sec.
    -- https://wowhead.com/beta/spell=589
    shadow_word_pain = {
        id = 589,
        duration = function() return talent.misery.enabled and 21 or 16 end,
        tick_time = function () return 2 * haste * ( 1 - 0.4 * ( buff.screams_of_the_void.up and talent.screams_of_the_void.rank or 0 ) ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Spell damage dealt increased by $s1%.
    -- https://wowhead.com/beta/spell=232698
    shadowform = {
        id = 232698,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    shadowy_apparitions = {
        id = 78203
    },
    shadowy_insight = {
        id = 375981,
        duration = 10,
        max_stack = 1,
        copy = 124430
    },
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=15487
    silence = {
        id = 15487,
        duration = 4,
        mechanic = "silence",
        type = "Magic",
        max_stack = 1
    },
    surge_of_insanity = {
        id = 423846,
        duration = 3600,
        max_stack = 1
    },
    sustained_potency = {
        id = 454002,
        duration =  60,
        max_stack = 6
    },
    -- Taking Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=363656
    torment_mind = {
        id = 363656,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Increases damage and healing by $w1%.
    -- https://wowhead.com/beta/spell=390978
    twist_of_fate = {
        id = 390978,
        duration = 8,
        max_stack = 1
    },
    -- Absorbing $w3 damage.
    ultimate_penitence = {
        id = 421453,
        duration = 6.0,
        max_stack = 1
    },
    -- Suffering $w1 damage every $t1 sec. When damaged, the attacker is healed for $325118m1.
    -- https://wowhead.com/beta/spell=325203
    unholy_transfusion = {
        id = 325203,
        duration = 15,
        tick_time = 3,
        type = "Magic",
        max_stack = 1
    },
    -- $15286s1% of any single-target Shadow spell damage you deal heals a nearby ally.
    vampiric_embrace = {
        id = 15286,
        duration = 12.0,
        tick_time = 0.5,
        pandemic = true,
        max_stack = 1
    },
    -- Suffering $w2 Shadow damage every $t2 sec.
    -- https://wowhead.com/beta/spell=34914
    vampiric_touch = {
        id = 34914,
        duration = 21,
        tick_time = function () return 3 * haste * ( 1 - 0.4 * ( buff.screams_of_the_void.up and talent.screams_of_the_void.rank or 0 ) ) end,
        type = "Magic",
        max_stack = 1
    },
    void_bolt = {
        id = 228266,
    },
    voidheart = {
        id = 449887,
        duration = 8,
        max_stack = 1
    },
    -- Talent: A Shadowy tendril is appearing under you.
    -- https://wowhead.com/beta/spell=108920
    void_tendrils_root = {
        id = 108920,
        duration = 0.5,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Dealing $s1 Shadow damage to the target every $t1 sec.
    -- https://wowhead.com/beta/spell=263165
    void_torrent = {
        id = 263165,
        duration = 3,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: |cFFFFFFFFGenerates ${$s1*$s2/100} Insanity over $d.|r
    -- https://wowhead.com/beta/spell=289577
    void_torrent_insanity = {
        id = 289577,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    voidform = {
        id = 194249,
        duration = 15, -- function () return talent.legacy_of_the_void.enabled and 3600 or 15 end,
        max_stack = 1
    },
    void_tendril_mind_flay = {
        id = 193473,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    void_lasher_mind_sear = {
        id = 394976,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    -- Void Volley Void Volley is available. $s1 seconds remaining
    -- https://www.wowhead.com/spell=1242171
    void_volley = {
        id = 1242171,
        duration = 20
    },
    weakened_soul = {
        id = 6788,
        duration = function () return 7.5 * haste end,
        max_stack = 1
    },
    -- The damage of your next Smite is increased by $w1%, or the absorb of your next Power Word: Shield is increased by $w2%.
    weal_and_woe = {
        id = 390787,
        duration = 20.0,
        max_stack = 1
    },
    -- Talent: Damage and healing of Smite and Holy Nova is increased by $s1%.
    -- https://wowhead.com/beta/spell=390933
    words_of_the_pious = {
        id = 390933,
        duration = 12,
        max_stack = 1
    },

    anunds_last_breath = {
        id = 215210,
        duration = 15,
        max_stack = 50
    },
    zeks_exterminatus = {
        id = 236546,
        duration = 15,
        max_stack = 1
    },

    -- Azerite Powers
    chorus_of_insanity = {
        id = 279572,
        duration = 120,
        max_stack = 120
    },
    death_denied = {
        id = 287723,
        duration = 10,
        max_stack = 1
    },
    depth_of_the_shadows = {
        id = 275544,
        duration = 12,
        max_stack = 30
    },
    searing_dialogue = {
        id = 288371,
        duration = 1,
        max_stack = 1
    },
    thought_harvester = {
        id = 288343,
        duration = 20,
        max_stack = 1,
        copy = "harvested_thoughts" -- SimC uses this name (carryover from Legion?)
    },

    -- Legendaries (Shadowlands)
    measured_contemplation = {
        id = 341824,
        duration = 3600,
        max_stack = 4
    },
    shadow_word_manipulation = {
        id = 357028,
        duration = 10,
        max_stack = 1
    },

    -- Conduits
    dissonant_echoes = {
        id = 343144,
        duration = 10,
        max_stack = 1
    },
    lights_inspiration = {
        id = 337749,
        duration = 5,
        max_stack = 1
    },
    translucent_image = {
        id = 337661,
        duration = 5,
        max_stack = 1
    },
} )

spec:RegisterTotems( {
    mindbender = {
        id = 136214,
        copy = "mindbender_actual"
    },
    shadowfiend = {
        id = 136199,
        copy = "shadowfiend_actual"
    },
    voidwraith = {
        id = 615099
    },
} )

local entropic_rift_expires = 0
local er_extensions = 0
local PowerSurgeDPs = 0

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, _, _, _, _, _, _, _, spellID )
    if sourceGUID ~= GUID then return end

    if subtype == "SPELL_AURA_REMOVED" then
        if spellID == 341207 then
            Hekili:ForceUpdate( subtype )
        elseif spellID == 453113 then
            PowerSurgeDPs = 0
        end
    elseif subtype == "SPELL_AURA_APPLIED" and spellID == 341207 then
        Hekili:ForceUpdate( subtype )

    elseif ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" ) and spellID == 450193 then
        entropic_rift_expires = GetTime() + 8 -- Assuming it will re-refresh from VT ticks and be caught by SPELL_AURA_REFRESH.
        er_extensions = 0
        return

    elseif state.talent.darkening_horizon.enabled and subtype == "SPELL_CAST_SUCCESS" and er_extensions < 3 and spellID == 450405 and entropic_rift_expires > GetTime() then
        entropic_rift_expires = entropic_rift_expires + 1
        er_extensions = er_extensions + 1
    elseif spellID == 335467 and subtype == "SPELL_CAST_SUCCESS" and state.set_bonus.tww3 >= 4 then
        local PowerSurgeBuff = GetPlayerAuraBySpellID( 453113 )
        if PowerSurgeBuff then
            PowerSurgeDPs = min( 6, PowerSurgeDPs + 1 )
        end
    end

end, false )

spec:RegisterStateExpr( "rift_extensions", function()
    return er_extensions
end )

spec:RegisterStateExpr( "tww3_archon_4pc_helper_stacks", function()
    return PowerSurgeDPs
end )

spec:RegisterStateExpr( "tww3_archon_halo_extensions", function()
    return floor( PowerSurgeDPs / 2 )
end )

spec:RegisterStateTable( "priest", setmetatable( {},{
    __index = function( t, k )
        if k == "self_power_infusion" then return true
    elseif k == "force_devour_matter" then return debuff.all_absorbs.up end
        return false
    end
} ) )

local ExpireVoidform = setfenv( function()
    applyBuff( "shadowform" )
    if Hekili.ActiveDebug then Hekili:Debug( "Voidform expired, Shadowform applied.  Did it stick?  %s.", buff.voidform.up and "Yes" or "No" ) end
end, state )

local PowerSurge = setfenv( function()
    class.abilities.halo.handler()
end, state )

spec:RegisterGear( {
    -- The War Within
    tww3 = {
        items = { 237710, 237708, 237709, 237712, 237707 },
        auras = {
            -- Voidweaver
            overflowing_void = {
                id = 1237615,
                duration = 3600,
                max_stack = 1
            },
            -- Archon
            tww3_archon_4pc_helper = {
                -- id = 999999, -- dummy ID
                duration = spec.auras.power_surge.duration,
                max_stack = 4, -- 3 extensions max * 2 casts per extension
                generate = function( t )
                    if tww3_archon_4pc_helper_stacks > 0 and state.buff.power_surge.up then
                        local power_surge_expiry = state.buff.power_surge.expires
                        t.name = "tww3_archon_4pc_helper"
                        t.count = tww3_archon_4pc_helper_stacks
                        t.expires = power_surge_expiry
                        t.duration = power_surge_expiry - ( power_surge_expiry - spec.auras.power_surge.duration )
                        t.applied = t.expires - t.duration
                        t.caster = "player"
                    else
                        t.name = "tww3_archon_4pc_helper"
                        t.count = 0
                        t.expires = 0
                        t.duration = 0
                        t.applied = 0
                        t.caster = "nobody"
                    end
                end
            }

        }
    },
    tww2 = {
        items = { 229334, 229332, 229337, 229335, 229333 }
    },
    -- Dragonflight
    tier31 = {
        items = { 207279, 207280, 207281, 207282, 207284 },
        auras = {
            deaths_torment = {
                id = 423726,
                duration = 60,
                max_stack = 12
            }
        }
    },
    tier30 = {
        items = { 202543, 202542, 202541, 202545, 202540, 217202, 217204, 217205, 217201, 217203 },
        auras = {
            darkflame_embers = {
                id = 409502,
                duration = 3600,
                max_stack = 4
            },
            darkflame_shroud = {
                id = 410871,
                duration = 10,
                max_stack = 1
            }
        }
    },
    tier29 = {
        items = { 200327, 200329, 200324, 200326, 200328 },
        auras = {
            dark_reveries = {
                id = 394963,
                duration = 8,
                max_stack = 1
            },
            gathering_shadows = {
                id = 394961,
                duration = 15,
                max_stack = 3
            }
        }
    }
} )

-- Don't need to actually snapshot this, the APL only cares about the power of the cast.
spec:RegisterStateExpr( "pmultiplier", function ()
    if this_action ~= "devouring_plague" then return 1 end

    local mult = 1
    if buff.gathering_shadows.up then mult = mult * ( 1 + ( buff.gathering_shadows.stack * 0.12 ) ) end
    if buff.mind_devourer.up     then mult = mult * 1.2                                             end

    return mult
end )

spec:RegisterHook( "reset_precast", function ()
    tww3_archon_4pc_helper_stacks = nil

    -- Debug: Track fiend cooldown states for desync troubleshooting
    if Hekili.ActiveDebug then
        local shadowfiendCd = GetSpellCooldown( 34433 )  -- Shadowfiend
        local mindbenderCd = GetSpellCooldown( 200174 )  -- Mindbender
        local voidwraithCd = GetSpellCooldown( 451234 )  -- Voidwraith

        Hekili:Debug( "Shadowfiend Cooldown - (34433): start=%.2f, duration=%.2f, remains=%.2f",
            shadowfiendCd.startTime or 0, shadowfiendCd.duration or 0,
            shadowfiendCd.startTime > 0 and (shadowfiendCd.startTime + shadowfiendCd.duration - GetTime()) or 0 )
        Hekili:Debug( "Mindbender Cooldown - (200174): start=%.2f, duration=%.2f, remains=%.2f",
            mindbenderCd.startTime or 0, mindbenderCd.duration or 0,
            mindbenderCd.startTime > 0 and (mindbenderCd.startTime + mindbenderCd.duration - GetTime()) or 0 )
        Hekili:Debug( "Voidwraith Cooldown - (451234): start=%.2f, duration=%.2f, remains=%.2f",
            voidwraithCd.startTime or 0, voidwraithCd.duration or 0,
            voidwraithCd.startTime > 0 and (voidwraithCd.startTime + voidwraithCd.duration - GetTime()) or 0 )

        Hekili:Debug( "Addon sees: Remaining cooldowns -  shadowfiend=%.2f, mindbender=%.2f, fiend=%.2f",
            cooldown.shadowfiend.remains, cooldown.mindbender.remains, cooldown.fiend.remains )

        Hekili:Debug( "Fiend Debug - Active talents: mindbender=%s, voidwraith=%s",
            talent.mindbender.enabled and "true" or "false", talent.voidwraith.enabled and "true" or "false" )

        Hekili:Debug( "Fiend Debug - Ability data: spec.abilities.mindbender.id=%s, class.abilities.mindbender.id=%s, class.abilities.mindbender.cooldown=%s",
            spec.abilities.mindbender and spec.abilities.mindbender.id or "nil",
            class.abilities.mindbender and class.abilities.mindbender.id or "nil",
            class.abilities.mindbender and class.abilities.mindbender.cooldown or "nil" )
    end

    if buff.voidform.up or time > 0 then
        applyBuff( "shadowform" )
    end

    if buff.voidform.up then
        state:QueueAuraExpiration( "voidform", ExpireVoidform, buff.voidform.expires )
    end

    if not IsSpellKnownOrOverridesKnown( 391403 ) then
        removeBuff( "mind_flay_insanity" )
    end

    if IsActiveSpell( 356532 ) then
        applyBuff( "direct_mask", class.abilities.fae_guardians.lastCast + 20 - now )
    end

    if settings.pad_void_bolt and cooldown.void_bolt.remains > 0 then
        reduceCooldown( "void_bolt", latency * 2 )
    end

    if settings.pad_ascended_blast and cooldown.ascended_blast.remains > 0 then
        reduceCooldown( "ascended_blast", latency * 2 )
    end

    if buff.voidheart.up then
        applyBuff( "entropic_rift", buff.voidheart.remains )
    elseif entropic_rift_expires > query_time then
        applyBuff( "entropic_rift", entropic_rift_expires - query_time )
    end

    -- Sanity check that Void Blast is enabled.
    if buff.entropic_rift.up and talent.void_blast.enabled and not IsSpellKnownOrOverridesKnown( 450983 ) then
        -- Void Blast isn't known for some reason; let's remove ER so MB can be queued.
        removeBuff( "entropic_rift" )
    end

    rift_extensions = nil

    if buff.power_surge.up then
        local tick, expires = buff.power_surge.applied, buff.power_surge.expires
        local final_tick = ( 2 + tww3_archon_halo_extensions )
        for i = 1, final_tick do
            tick = tick + 5
            if tick > query_time and tick <= expires then
                state:QueueAuraEvent( "create_additional_halo", PowerSurge, tick, "AURA_TICK" )
            end
        end
    end

    local vwRemains = cooldown.voidwraith.true_remains
    if vwRemains > cooldown.shadowfiend.remains then
        setCooldown( "shadowfiend", vwRemains )
    end
end )

spec:RegisterHook( "TALENTS_UPDATED", function()
    talent.shadow_crash = talent.shadow_crash_targeted.enabled and talent.shadow_crash_targeted or talent.shadow_crash_ground

    -- For ability/cooldown, Mindbender takes precedent.
    local sf = talent.mindbender.enabled and "mindbender_actual" or talent.voidwraith.enabled and "voidwraith" or "shadowfiend_actual"

    class.abilities.shadowfiend = class.abilities[ sf ]
    class.abilities.mindbender = class.abilities[ sf ]

    rawset( cooldown, "shadowfiend", cooldown[ sf ] )
    rawset( cooldown, "mindbender", cooldown[ sf ] )
    rawset( cooldown, "fiend", cooldown[ sf ] )

    -- For totem/pet/buff, Voidwraith takes precedent.
    sf = talent.voidwraith.enabled and "voidwraith" or talent.mindbender.enabled and "mindbender" or "shadowfiend"

    class.totems.fiend = spec.totems[ sf ]
    totem.fiend = totem[ sf ]
    pet.fiend = pet[ sf ]
    buff.fiend = buff[ sf ]
end )

spec:RegisterHook( "pregain", function( amount, resource, overcap )
    if amount > 0 and resource == "insanity" and state.buff.memory_of_lucid_dreams.up then
        amount = amount * 2
    end

    return amount, resource, overcap
end )

local InescapableTorment = setfenv( function ()
    if buff.mindbender.up then buff.mindbender.expires = buff.mindbender.expires + 0.7
    elseif buff.shadowfiend.up then buff.shadowfiend.expires = buff.shadowfiend.expires + 0.7
    elseif buff.voidwraith.up then buff.voidwraith.expires = buff.voidwraith.expires + 0.7
    end
end, state )

local TWW3ArchonTrigger = setfenv( function()
    if tww3_archon_4pc_helper_stacks >= 4 then
        return
    else
        tww3_archon_4pc_helper_stacks = min( 4, tww3_archon_4pc_helper_stacks + 1 )
        if tww3_archon_4pc_helper_stacks % 2 == 0 then
            buff.power_surge.expires = buff.power_surge.expires + 5
        end
    end
end, state )

-- Abilities
spec:RegisterAbilities( {
    -- Talent: Places a feather at the target location, granting the first ally to walk through it $121557s1% increased movement speed for $121557d. Only 3 feathers can be placed at one time.
    angelic_feather = {
        id = 121536,
        cast = 0,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",
        school = "holy",

        talent = "angelic_feather",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Heals the target and ${$s2-1} injured allies within $A1 yards of the target for $s1.
    circle_of_healing = {
        id = 204883,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holy",

        spend = 0.033,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
        end,
    },

    -- Talent: Increases your non-periodic Shadow damage by $s1% for 20 sec.    |cFFFFFFFFGenerates ${$m2/100} Insanity.|r
    dark_ascension = {
        id = 391109,
        cast = function ()
            if pvptalent.void_origins.enabled then return 0 end
            return 1.5 * haste
        end,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        spend = -30,
        spendType = "insanity",

        talent = "dark_ascension",
        startsCombat = false,
        toggle = "essences",

        handler = function ()
            applyBuff( "dark_ascension" )
            if talent.ancient_madness.enabled then applyBuff( "ancient_madness", nil, 20 ) end
            if set_bonus.tww2 >= 2 then
                spec.abilities.void_bolt.handler()
                spend( spec.abilities.void_bolt.spend, spec.abilities.void_bolt.spendType )
                applyBuff( "power_infusion", buff.power_infusion.remains + 5 )
            end
        end,
    },

    desperate_prayer = {
        id = 19236,
        cast = 0,
        cooldown = function() return talent.angels_mercy.enabled and 70 or 90 end,
        gcd = "off",
        school = "holy",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "desperate_prayer" )
            health.max = health.max * 1.25
            gain( 0.8 * health.max, "health" )
            if conduit.lights_inspiration.enabled then applyBuff( "lights_inspiration" ) end
        end,
    },

    -- Talent: Afflicts the target with a disease that instantly causes $s1 Shadow damage plus an additional $o2 Shadow damage over $d. Heals you for ${$e2*100}% of damage dealt.    If this effect is reapplied, any remaining damage will be added to the new Devouring Plague.
    devouring_plague = {
        id = 335467,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = function ()
            if buff.mind_devourer.up then return 0 end
            return 50 + ( talent.distorted_reality.enabled and 5 or 0 ) + ( talent.minds_eye.enabled and -5 or 0 )
        end,
        spendType = "insanity",

        talent = "devouring_plague",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "devouring_plague" )
            if buff.voidform.up then buff.voidform.expires = buff.voidform.expires + 2.5 end

            removeBuff( "mind_devourer" )
            removeBuff( "gathering_shadows" )

            if talent.surge_of_insanity.enabled then
                addStack( "mind_flay_insanity" )
            end

            -- Manage fake aura, I hope
            if set_bonus.tww3 >= 4 and buff.power_surge.up then TWW3ArchonTrigger() end

            -- Legacy
            if set_bonus.tier29_4pc > 0 then applyBuff( "dark_reveries" ) end

            if set_bonus.tier30_4pc > 0 then
                -- TODO: Revisit if shroud procs on 4th cast or 5th (simc implementation looks like it procs on 5th).
                if buff.darkflame_embers.stack == 3 then
                    removeBuff( "darkflame_embers" )
                    applyBuff( "darkflame_shroud" )
                else
                    addStack( "darkflame_embers" )
                end
            end
        end,
    },

    -- Talent: Dispels Magic on the enemy target, removing $m1 beneficial Magic $leffect:effects;.
    dispel_magic = {
        id = 528,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function () return ( state.spec.shadow and 0.14 or 0.02 ) * ( 1 + conduit.clear_mind.mod * 0.01 ) * ( 1 - 0.1 * talent.mental_agility.rank ) end,
        spendType = "mana",

        talent = "dispel_magic",
        startsCombat = false,

        buff = "dispellable_magic",
        handler = function ()
            removeBuff( "dispellable_magic" )
        end,

        -- Affected by:
        -- mental_agility[341167] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- mental_agility[341167] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- mental_agility[341167] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Talent: Disperse into pure shadow energy, reducing all damage taken by $s1% for $d and healing you for $?s288733[${$s5+$288733s2}][$s5]% of your maximum health over its duration, but you are unable to attack or cast spells.    Increases movement speed by $s4% and makes you immune to all movement impairing effects.    Castable while stunned, feared, or silenced.
    dispersion = {
        id = 47585,
        cast = 0,
        cooldown = function () return talent.intangibility.enabled and 90 or 120 end,
        gcd = "spell",
        school = "shadow",

        talent = "dispersion",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "dispersion" )
            setCooldown( "global_cooldown", 6 )
        end,
    },

    -- Talent: Throw a Divine Star forward 24 yds, healing allies in its path for $110745s1 and dealing $122128s1 Shadow damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond $s1 targets.
    divine_star = {
        id = 122121,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "divine_star",
        startsCombat = true,

        handler = function ()
            if time > 0 then gain( 6, "insanity" ) end
        end,
    },

    -- Talent: Controls a mind up to 1 level above yours for $d while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings$?a205477[][ or players]. This spell shares diminishing returns with other disorienting effects.
    dominate_mind = {
        id = 205364,
        cast = 1.8,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "dominate_mind",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "dominate_mind" )
        end,
    },

    -- Fade out, removing all your threat and reducing enemies' attack range against you for $d.
    fade = {
        id = 586,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.improved_fade.rank end,
        gcd = "off",
        school = "shadow",

        startsCombat = false,

        handler = function ()
            applyBuff( "fade" )
            if conduit.translucent_image.enabled then applyBuff( "translucent_image" ) end
        end,
    },

    -- A fast spell that heals an ally for $s1.
    flash_heal = {
        id = 2061,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function() return buff.surge_of_light.up and 0 or 0.10 end,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            removeBuff( "from_darkness_comes_light" )
            removeStack( "surge_of_light" )
            if talent.protective_light.enabled then applyBuff( "protective_light" ) end
        end,
    },

    -- Talent: Creates a ring of Shadow energy around you that quickly expands to a 30 yd radius, healing allies for $120692s1 and dealing $120696s1 Shadow damage to enemies.    Healing reduced beyond $s1 targets.
    halo = {
        id = 120644,
        cast = 1.5,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        spend = 0.04,
        spendType = "mana",

        talent = "halo",
        startsCombat = true,

        handler = function ()
            if talent.power_surge.enabled then
                if buff.power_surge.down then
                    -- Don't repeatedly run these during "additional Halos", only run during initial cast
                    gain( 10, "insanity" )
                    applyBuff( "power_surge", nil, 10 )
                    for i = 5, 10, 5 do
                        -- Queue the additional Halos, one every 5 seconds until expiry
                        -- Further halos beyond base duration from TWW3 set will be added during reset_precast
                        state:QueueAuraEvent( "create_additional_halo", PowerSurge, query_time + i, "AURA_TICK" )
                    end
                end
                if talent.manifested_power.enabled then addStack( "mind_flay_insanity" ) end
                if talent.sustained_potency.enabled then
                    if buff.voidform.up then
                        buff.voidform.expires = buff.voidform.expires + 1
                    else
                        addStack( "sustained_potency" )
                    end
                end
            else
                gain( 10, "insanity" )
            end
        end,
    },

    -- Talent: An explosion of holy light around you deals up to $s1 Holy damage to enemies and up to $281265s1 healing to allies within $A1 yds, reduced if there are more than $s3 targets.
    holy_nova = {
        id = 132157,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",
        damage = 1,

        spend = 0.016,
        spendType = "mana",

        talent = "holy_nova",
        startsCombat = true,

        handler = function ()
            removeBuff( "rhapsody" )
        end,
    },

    -- Talent: Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    leap_of_faith = {
        id = 73325,
        cast = 0,
        charges = function () return legendary.vault_of_heavens.enabled and 2 or nil end,
        cooldown = function() return talent.move_with_grace.enabled and 60 or 90 end,
        recharge = function () return legendary.vault_of_heavens.enabled and ( talent.move_with_grace.enabled and 60 or 90 ) or nil end,
        gcd = "off",
        school = "holy",

        spend = 0.026,
        spendType = "mana",

        talent = "leap_of_faith",
        startsCombat = false,
        toggle = "interrupts",

        usable = function() return group, "requires an ally" end,
        handler = function ()
            if talent.body_and_soul.enabled then applyBuff( "body_and_soul" ) end
            if azerite.death_denied.enabled then applyBuff( "death_denied" ) end
            if legendary.vault_of_heavens.enabled then setDistance( 5 ) end
        end,
    },

    --[[  Talent: You pull your spirit to an ally, instantly moving you directly in front of them.
    leap_of_faith = {
        id = 336471,
        cast = 0,
        charges = 2,
        cooldown = 1.5,
        recharge = 90,
        gcd = "off",
        school = "holy",

        talent = "leap_of_faith",
        startsCombat = false,

        handler = function ()
        end,
    }, ]]

    -- Levitates a party or raid member for $111759d, floating a few feet above the ground, granting slow fall, and allowing travel over water.
    levitate = {
        id = 1706,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.009,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "levitate" )
        end,
    },

    --[[ Invoke the Light's wrath, dealing $s1 Radiant damage to the target, increased by $s2% per ally affected by your Atonement.
    lights_wrath = {
        id = 373178,
        cast = 2.5,
        cooldown = 90,
        gcd = "spell",
        school = "holyfire",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    }, ]]

    -- Talent: Dispels magic in a $32375a1 yard radius, removing all harmful Magic from $s4 friendly targets and $32592m1 beneficial Magic $leffect:effects; from $s4 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mass_dispel = {
        id = 32375,
        cast = 1.5,
        cooldown = function () return pvptalent.improved_mass_dispel.enabled and 60 or 120 end,
        gcd = "spell",
        school = "holy",

        spend = function () return 0.20 * ( talent.mental_agility.enabled and 0.5 or 1 ) end,
        spendType = "mana",

        talent = "mass_dispel",
        startsCombat = false,

        usable = function () return buff.dispellable_magic.up or debuff.dispellable_magic.up, "requires a dispellable magic effect" end,
        handler = function ()
            removeBuff( "dispellable_magic" )
            removeDebuff( "player", "dispellable_magic" )
            if time > 0 and state.spec.shadow then gain( 6, "insanity" ) end
        end,
    },

    -- Blasts the target's mind for $s1 Shadow damage$?s424509[ and increases your spell damage to the target by $424509s1% for $214621d.][.]$?s137033[; Generates ${$s2/100} Insanity.][]
    mind_blast = {
        id = 8092,
        cast = function () return buff.shadowy_insight.up and 0 or ( 1.5 * haste ) end,
        charges = function()
            if talent.thought_harvester.enabled then return 2 end
        end,
        cooldown = 9,
        recharge = function ()
            if talent.thought_harvester.enabled then return 9 * haste end
        end,
        hasteCD = true,
        gcd = "spell",
        school = "shadow",

        spend = function () return talent.dark_thoughts.enabled and buff.shadowy_insight.up and -7 or -6 end,
        spendType = "insanity",

        cycle = function()
            if buff.voidform.down then return "devouring_plague" end
            end,
        cycle_to = true,

        startsCombat = true,
        texture = 136224,
        velocity = 15,
        nobuff = function() return talent.void_blast.enabled and "entropic_rift" or nil end,

        handler = function()
            removeBuff( "empty_mind" )
            removeBuff( "harvested_thoughts" )
            removeBuff( "shattered_psyche" )
            removeBuff( "shadowy_insight" )

            if talent.inescapable_torment.enabled then InescapableTorment() end

            if talent.schism.enabled then applyDebuff( "target", "schism" ) end

            if set_bonus.tier29_2pc > 0 then
                addStack( "gathering_shadows" )
            end

            if talent.void_blast.enabled then
                spendCharges( "void_blast", 1 )
            end
        end,

        bind = "void_blast"
    },

    -- Blasts the target's mind for $s1 Shadow damage$?s424509[ and increases your spell damage to the target by $424509s1% for $214621d.][.]$?s137033[; Generates ${$s2/100} Insanity.][]
    void_blast = {
        id = 450983,
        known = 8092,
        flash = 8092,
        cast = function () return buff.shadowy_insight.up and 0 or ( 1.5 * haste * ( set_bonus.tww3 >= 2 and 0.8 or 1 ) ) end,
        charges = function()
            if talent.thought_harvester.enabled then return 2 end
        end,
        cooldown = function() return 9 * ( set_bonus.tww3 >= 2 and 0.5 or 1 ) end,
        recharge = function ()
            if talent.thought_harvester.enabled then return 9 * ( set_bonus.tww3 >= 2 and 0.5 or 1 ) * haste end
        end,
        hasteCD = true,
        gcd = "spell",
        school = "shadow",

        spend = function () return ( set_bonus.tier30_2pc > 0 and buff.shadowy_insight.up and -4 or 0 ) + ( talent.void_infusion.enabled and -12 or -6 ) end,
        spendType = "insanity",

        startsCombat = true,
        texture = 4914668,
        velocity = 15,
        talent = "void_blast",
        buff = "entropic_rift",

        handler = function()
            removeBuff( "empty_mind" )
            removeBuff( "harvested_thoughts" )
            removeBuff( "shattered_psyche" )
            removeBuff( "shadowy_insight" )

            if talent.darkening_horizon.enabled and rift_extensions < 3 then
                buff.entropic_rift.expires = buff.entropic_rift.expires + 1
                if buff.voidheart.up then buff.voidheart.expires = buff.voidheart.expires + 1 end
                rift_extensions = rift_extensions + 1
            end

            if talent.inescapable_torment.enabled then InescapableTorment() end

            if talent.schism.enabled then applyDebuff( "target", "schism" ) end

            if set_bonus.tier29_2pc > 0 then
                addStack( "gathering_shadows" )
            end

            spendCharges( "mind_blast", 1 )
        end,

        copy = 450405,
        bind = "mind_blast"
    },


    -- Talent: Controls a mind up to 1 level above yours for $d. Does not work versus Demonic$?A320889[][, Undead,] or Mechanical beings. Shares diminishing returns with other disorienting effects.
    mind_control = {
        id = 605,
        cast = 1.8,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "mind_control",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mind_control" )
        end,
    },

    -- Assaults the target's mind with Shadow energy, causing $o1 Shadow damage over $d and slowing their movement speed by $s2%.    |cFFFFFFFFGenerates ${$s4*$s3/100} Insanity over the duration.|r
    mind_flay = {
        id = function() return buff.mind_flay_insanity.up and 391403 or 15407 end,
        known = 15407,
        cast = function() return ( buff.mind_flay_insanity.up and 1.5 or 4.5 ) * haste end,
        channeled = true,
        breakable = true,
        cooldown = 0,
        hasteCD = true,
        gcd = "spell",
        school = "shadow",

        spend = 0,
        spendType = "insanity",

        startsCombat = true,
        texture = function()
            if buff.mind_flay_insanity.up then return 425954 end
            return 136208
        end,
        nobuff = "boon_of_the_ascended",
        bind = "ascended_blast",
        cycle = function()
            if buff.voidform.down then return "devouring_plague" end
            end,
        cycle_to = true,

        aura = function() return buff.mind_flay_insanity.up and "mind_flay_insanity" or "mind_flay" end,
        tick_time = function () return class.auras.mind_flay.tick_time end,

        start = function ()
            if buff.mind_flay_insanity.up then
                removeStack( "mind_flay_insanity" )
                applyDebuff( "target", "mind_flay_insanity_dot" )
            else
                applyDebuff( "target", "mind_flay" )
            end
            if talent.mental_decay.enabled then
                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 1 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 1 end
            end
            if talent.shattered_psyche.enabled then addStack( "shattered_psyche" ) end
        end,

        tick = function ()
            if talent.mental_decay.enabled then
                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 1 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 1 end
            end
            if talent.shattered_psyche.enabled then addStack( "shattered_psyche" ) end
        end,

        breakchannel = function ()
            removeDebuff( "target", "mind_flay" )
            removeDebuff( "target", "mind_flay_insanity_dot" )
        end,

        copy = { "mind_flay_insanity", 391403 }
    },

    -- Soothes enemies in the target area, reducing the range at which they will attack you by $s1 yards. Only affects Humanoid and Dragonkin targets. Does not cause threat. Lasts $d.
    mind_soothe = {
        id = 453,
        cast = 0,
        cooldown = 5,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mind_soothe" )
        end,
    },

    -- Allows the caster to see through the target's eyes for $d. Will not work if the target is in another instance or on another continent.
    mind_vision = {
        id = 2096,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mind_vision" )
        end,
    },

    --[[ -- Talent: Summons a Mindbender to attack the target for $d.     |cFFFFFFFFGenerates ${$123051m1/100}.1% mana each time the Mindbender attacks.|r
    mindbender = {
        id = function()
            if talent.voidwraith.enabled then
                return 451235
            end
            if talent.mindbender.enabled then
                return state.spec.discipline and 123040 or 200174
            end
            return 34433
        end,
        known = 34433,
        flash = { 34433, 123040, 200174 },
        cast = 0,
        cooldown = function () return talent.mindbender.enabled and 60 or 180 end,
        gcd = "spell",
        school = "shadow",

        toggle = function()
            if not talent.mindbender.enabled then return "cooldowns" end
        end,
        startsCombat = true,
        -- texture = function() return talent.mindbender.enabled and 136214 or 136199 end,

        handler = function ()
            local fiend = talent.voidwraith.enabled and "voidwraith" or talent.mindbender.enabled and "mindbender" or "shadowfiend"
            summonPet( fiend, 15 )
            applyBuff( fiend )

            if talent.shadow_covenant.enabled then applyBuff( "shadow_covenant" ) end
        end,

        copy = { "shadowfiend", 34433, 123040, 200174, "voidwraith", 451235 }
    }, ]]

    -- Covenant (Venthyr): Assault an enemy's mind, dealing ${$s1*$m3/100} Shadow damage and briefly reversing their perception of reality.    $?c3[For $d, the next $<damage> damage they deal will heal their target, and the next $<healing> healing they deal will damage their target.    |cFFFFFFFFReversed damage and healing generate up to ${$323706s2*2} Insanity.|r]  ][For $d, the next $<damage> damage they deal will heal their target, and the next $<healing> healing they deal will damage their target.    |cFFFFFFFFReversed damage and healing restore up to ${$323706s3*2}% mana.|r]
    mindgames = {
        id = function() return pvptalent.mindgames.enabled and 375901 or 323673 end,
        cast = 1.5,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",
        damage = 1,

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mindgames" )
            gain( 10, "insanity" )
        end,

        copy = { 375901, 323673 }
    },

    -- Talent: Infuses the target with power for $d, increasing haste by $s1%.
    power_infusion = {
        id = 10060,
        cast = 0,
        cooldown = function () return 120 - ( conduit.power_unto_others.mod and group and conduit.power_unto_others.mod or 0 ) end,
        gcd = "off",
        school = "holy",

        talent = "power_infusion",
        startsCombat = false,

        toggle = "cooldowns",
        indicator = function () return group and ( talent.twins_of_the_sun_priestess.enabled or legendary.twins_of_the_sun_priestess.enabled ) and "cycle" or nil end,

        handler = function ()
            applyBuff( "power_infusion", max( 30,  buff.power_infusion.remains + 15 ) )
            stat.haste = stat.haste + 0.25
        end,
    },

    -- Infuses the target with vitality, increasing their Stamina by $s1% for $d.    If the target is in your party or raid, all party and raid members will be affected.
    power_word_fortitude = {
        id = 21562,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        nobuff = "power_word_fortitude",

        handler = function ()
            applyBuff( "power_word_fortitude" )
        end,
    },

    -- Talent: A word of holy power that heals the target for $s1. ; Only usable if the target is below $s2% health.
    power_word_life = {
        id = 373481,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holy",

        spend = function () return state.spec.shadow and 0.1 or 0.025 end,
        spendType = "mana",

        talent = "power_word_life",
        startsCombat = false,
        usable = function() return health.pct < 35, "requires target below 35% health" end,

        handler = function ()
            gain( 7.5 * stat.spell_power, "health" )
        end,
    },

    -- Shields an ally for $d, absorbing ${$<shield>*$<aegis>*$<benevolence>} damage.
    power_word_shield = {
        id = 17,
        cast = 0,
        cooldown = function() return buff.rapture.up and 0 or ( 7.5 * haste ) end,
        gcd = "spell",
        school = "holy",

        spend = 0.10,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "power_word_shield" )

            if talent.body_and_soul.enabled then
                applyBuff( "body_and_soul" )
            end

            if state.spec.discipline then
                applyBuff( "atonement" )
                removeBuff( "shield_of_absolution" )
                removeBuff( "weal_and_woe" )

                if set_bonus.tier29_2pc > 0 then
                    applyBuff( "light_weaving" )
                end
                if talent.borrowed_time.enabled then
                    applyBuff( "borrowed_time" )
                end
            else
                applyDebuff( "player", "weakened_soul" )
            end
        end,
    },

    -- Talent: Places a ward on an ally that heals them for $33110s1 the next time they take damage, and then jumps to another ally within $155793a1 yds. Jumps up to $s1 times and lasts $41635d after each jump.
    prayer_of_mending = {
        id = 33076,
        cast = 0,
        cooldown = 12,
        hasteCD = true,
        gcd = "spell",
        school = "holy",

        spend = 0.04,
        spendType = "mana",

        talent = "prayer_of_mending",
        startsCombat = false,

        handler = function ()
            applyBuff( "prayer_of_mending" )
        end,
    },

    -- Talent: Terrifies the target in place, stunning them for $d.
    psychic_horror = {
        id = 64044,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",

        talent = "psychic_horror",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "psychic_horror" )
        end,
    },

    -- Lets out a psychic scream, causing $i enemies within $A1 yards to flee, disorienting them for $d. Damage may interrupt the effect.
    psychic_scream = {
        id = 8122,
        cast = 0,
        cooldown = function() return talent.psychic_void.enabled and 30 or 45 end,
        gcd = "spell",
        school = "shadow",

        spend = 0.012,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "psychic_scream" )
        end,
    },

    -- PvP Talent: [199845] Deals up to $s2% of the target's total health in Shadow damage every $t1 sec. Also slows their movement speed by $s3% and reduces healing received by $s4%.
    psyfiend = {
        id = 211522,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        startsCombat = true,
        pvptalent = "psyfiend",

        function()
            -- Just assume the fiend is immediately flaying your target.
            applyDebuff( "target", "psyflay" )
        end,

        auras = {
            psyflay = {
                id = 199845,
                duration = 12,
                max_stack = 1
            }
        }

        -- Effects:
        -- [x] #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 4.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- [x] #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 199824, 'target': TARGET_UNIT_CASTER, }
    },

    -- Talent: Removes all Disease effects from a friendly target.
    purify_disease = {
        id = 213634,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",
        school = "holy",

        spend = function() return 0.013 * ( talent.mental_agility.enabled and 0.5 or 1 ) end,
        spendType = "mana",

        talent = "purify_disease",
        startsCombat = false,
        debuff = "dispellable_disease",

        handler = function ()
            removeDebuff( "player", "dispellable_disease" )
            -- if time > 0 then gain( 6, "insanity" ) end
        end,
    },

    -- Talent: Fill the target with faith in the light, healing for $o1 over $d.
    renew = {
        id = 139,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.04,
        spendType = "mana",

        talent = "renew",
        startsCombat = false,

        handler = function ()
            applyBuff( "renew" )
        end,
    },

    -- Talent: Shackles the target undead enemy for $d, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shackle_undead = {
        id = 9484,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.012,
        spendType = "mana",

        talent = "shackle_undead",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "shackle_undead" )
        end,
    },

    -- Talent: Hurl a bolt of slow-moving Shadow energy at the destination, dealing $205386s1 Shadow damage to all targets within $205386A1 yards and applying Vampiric Touch to $391286s1 of them.    |cFFFFFFFFGenerates $/100;s2 Insanity.|r
    shadow_crash = {
        id = function() return talent.shadow_crash_targeted.enabled and 457042 or 205385 end,
        cast = 0,
        cooldown = 15,
        charges = 2,
        recharge = 15,
        gcd = "spell",
        school = "shadow",

        spend = -6,
        spendType = "insanity",

        talent = "shadow_crash",
        startsCombat = true,

        flightTime = 1.5,

        cycle = "vampiric_touch",

        impact = function ()
            applyDebuff( "target", "vampiric_touch" )
            active_dot.vampiric_touch = min( active_enemies, active_dot.vampiric_touch + 5 )
            if talent.misery.enabled then
                applyDebuff( "target", "shadow_word_pain" )
                active_dot.shadow_word_pain = min( active_enemies, active_dot.shadow_word_pain + 5 )
            end
        end,

        readyTime = function()
            local holdCount = settings.hold_crash
            if holdCount > 0 and active_enemies < holdCount then return action.shadow_crash.full_recharge_time end
        end,

        copy = { 205385, 457042 }
    },

    -- Talent: A word of dark binding that inflicts $s1 Shadow damage to your target. If your target is not killed by Shadow Word: Death, you take backlash damage equal to $s5% of your maximum health.$?A364675[; Damage increased by ${$s3+$364675s2}% to targets below ${$s2+$364675s1}% health.][; Damage increased by $s3% to targets below $s2% health.]$?c3[][]$?s137033[; Generates ${$s4/100} Insanity.][]
    shadow_word_death = {
        id = 32379,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "shadow",
        damage = 1,

        spend = 0.005,
        spendType = "mana",

        talent = "shadow_word_death",
        startsCombat = true,

        cycle = function()
            if talent.devour_matter.enabled then return "all_absorbs" end
            end,
        cycle_to = true,

        usable = function ()
            if settings.sw_death_protection == 0 then return true end
            return health.percent >= settings.sw_death_protection, "player health [ " .. health.percent .. " ] is below user setting [ " .. settings.sw_death_protection .. " ]"
        end,

        handler = function ()
            gain( 4 + 2 * talent.deaths_torment.rank, "insanity" )
            if talent.devour_matter.enabled and debuff.all_absorbs.up then gain( 5 + 2 * talent.deaths_torment.rank, "insanity" ) end

            removeBuff( "zeks_exterminatus" )

            if talent.death_and_madness.enabled then
                applyDebuff( "target", "death_and_madness_debuff" )
            end

            if talent.inescapable_torment.enabled then InescapableTorment() end

            local swp_reduction = 3 * talent.expiation.rank
            if swp_reduction > 0 then debuff.shadow_word_pain.expires = max( 0, debuff.shadow_word_pain.expires - swp_reduction ) end

            -- Legacy

            if set_bonus.tier31_4pc > 0 then
                addStack( "deaths_torment", nil, ( buff.deathspeaker.up or target.health.pct < 20 ) and 3 or 2 )
            end

            if legendary.painbreaker_psalm.enabled then
                local power = 0
                if debuff.shadow_word_pain.up then
                    power = power + 15 * min( debuff.shadow_word_pain.remains, 8 ) / 8
                    if debuff.shadow_word_pain.remains < 8 then removeDebuff( "shadow_word_pain" )
                    else debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires - 8 end
                end
                if debuff.vampiric_touch.up then
                    power = power + 15 * min( debuff.vampiric_touch.remains, 8 ) / 8
                    if debuff.vampiric_touch.remains <= 8 then removeDebuff( "vampiric_touch" )
                    else debuff.vampiric_touch.expires = debuff.vampiric_touch.expires - 8 end
                end
                if power > 0 then gain( power, "insanity" ) end
            end

            if legendary.shadowflame_prism.enabled then
                if pet.fiend.active then pet.fiend.expires = pet.fiend.expires + 1 end
            end
        end,
    },

    -- A word of darkness that causes $?a390707[${$s1*(1+$390707s1/100)}][$s1] Shadow damage instantly, and an additional $?a390707[${$o2*(1+$390707s1/100)}][$o2] Shadow damage over $d.$?s137033[    |cFFFFFFFFGenerates ${$m3/100} Insanity.|r][]
    shadow_word_pain = {
        id = 589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = -3,
        spendType = "insanity",

        startsCombat = true,
        cycle = "shadow_word_pain",

        handler = function ()
            removeBuff( "deaths_torment" )
            applyDebuff( "target", "shadow_word_pain" )
        end,
    },

    -- Assume a Shadowform, increasing your spell damage dealt by $s1%.
    shadowform = {
        id = 232698,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        startsCombat = false,
        essential = true,
        nobuff = function () return buff.voidform.up and "voidform" or "shadowform" end,

        handler = function ()
            applyBuff( "shadowform" )
        end,
    },

    -- Talent: Silences the target, preventing them from casting spells for $d. Against non-players, also interrupts spellcasting and prevents any spell in that school from being cast for $263715d.
    silence = {
        id = 15487,
        cast = 0,
        cooldown = function() return talent.last_word.enabled and 30 or 45 end,
        gcd = "off",
        school = "shadow",

        talent = "silence",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "silence" )
        end,
    },

    -- Talent: Fills you with the embrace of Shadow energy for $d, causing you to heal a nearby ally for $s1% of any single-target Shadow spell damage you deal.
    vampiric_embrace = {
        id = 15286,
        cast = 0,
        cooldown = function() return talent.sanlayn.enabled and 75 or 120 end,
        gcd = "off",
        school = "shadow",

        talent = "vampiric_embrace",
        startsCombat = false,
        texture = 136230,

        toggle = "defensives",

        handler = function ()
            applyBuff( "vampiric_embrace" )
            -- if time > 0 then gain( 6, "insanity" ) end
        end,
    },

    -- A touch of darkness that causes $34914o2 Shadow damage over $34914d, and heals you for ${$e2*100}% of damage dealt. If Vampiric Touch is dispelled, the dispeller flees in Horror for $87204d.    |cFFFFFFFFGenerates ${$m3/100} Insanity.|r
    vampiric_touch = {
        id = 34914,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = -4,
        spendType = "insanity",

        startsCombat = true,
        cycle = function ()
            if talent.misery.enabled and debuff.shadow_word_pain.remains < debuff.vampiric_touch.remains then return "shadow_word_pain" end
            return "vampiric_touch"
        end,
        max_targets = 1,

        handler = function ()
            applyDebuff( "target", "vampiric_touch" )

            if talent.misery.enabled then
                applyDebuff( "target", "shadow_word_pain" )
            end

        end,
    },

    -- Sends a bolt of pure void energy at the enemy, causing $s2 Shadow damage$?s193225[, refreshing the duration of Devouring Plague on the target][]$?a231688[ and extending the duration of Shadow Word: Pain and Vampiric Touch on all nearby targets by $<ext> sec][].     Requires Voidform.    |cFFFFFFFFGenerates $/100;s3 Insanity.|r
    void_bolt = {
        id = 205448,
        known = 228260,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",
        school = "shadow",

        spend = -10,
        spendType = "insanity",

        startsCombat = true,
        velocity = 40,
        buff = function () return buff.dissonant_echoes.up and "dissonant_echoes" or "voidform" end,
        bind = "void_eruption",

        handler = function ()
            removeBuff( "dissonant_echoes" )

            if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 3 end
            if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 3 end

            removeBuff( "anunds_last_breath" )
        end,

        impact = function ()
        end,

        copy = 343355,
    },

    -- Talent: Releases an explosive blast of pure void energy, activating Voidform and causing ${$228360s1*2} Shadow damage to all enemies within $a1 yds of your target.    During Voidform, this ability is replaced by Void Bolt.    Each $s4 Insanity spent during Voidform increases the duration of Voidform by ${$s3/1000}.1 sec.
    void_eruption = {
        id = 228260,
        cast = function ()
            if pvptalent.void_origins.enabled then return 0 end
            return haste * 1.5
        end,
        cooldown = 120,
        gcd = "spell",
        school = "shadow",

        talent = "void_eruption",
        startsCombat = true,
        toggle = "cooldowns",
        nobuff = function () return buff.dissonant_echoes.up and "dissonant_echoes" or "voidform" end,
        bind = "void_bolt",

        cooldown_ready = function ()
            return cooldown.void_eruption.remains == 0 and buff.voidform.down
        end,

        handler = function ()
            if set_bonus.tww2 >= 2 then
                spec.abilities.void_bolt.handler()
                spend( spec.abilities.void_bolt.spend, spec.abilities.void_bolt.spendType )
                applyBuff( "power_infusion", buff.power_infusion.remains + 5 )
            end
            applyBuff( "voidform", nil, ( 20 + ( buff.sustained_potency.stack ) ) )
            if talent.ancient_madness.enabled then applyBuff( "ancient_madness", nil, 20 ) end
        end,
    },

    -- Talent: You and the currently targeted party or raid member swap health percentages. Increases the lower health percentage of the two to $s1% if below that amount.
    void_shift = {
        id = 108968,
        cast = 0,
        cooldown = 300,
        gcd = "off",
        school = "shadow",

        talent = "void_shift",
        startsCombat = false,

        toggle = "defensives",
        usable = function() return group, "requires an ally" end,

        handler = function ()
        end,
    },

    -- Talent: Summons shadowy tendrils, rooting up to $108920i enemy targets within $108920A1 yards for $114404d or until the tendril is killed.
    void_tendrils = {
        id = 108920,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "void_tendrils",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "void_tendrils_root" )
        end,
    },

    -- Talent: Channel a torrent of void energy into the target, dealing $o Shadow damage over $d.    |cFFFFFFFFGenerates ${$289577s1*$289577s2/100} Insanity over the duration.|r
    void_torrent = {
        id = 263165,
        cast = 3,
        channeled = true,
        fixedCast = true,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = -24,
        spendType = "insanity",

        talent = "void_torrent",
        startsCombat = true,
        aura = "void_torrent",
        tick_time = function () return class.auras.void_torrent.tick_time end,

        cycle = function()
            if buff.voidform.down then return "devouring_plague" end
            end,
        cycle_to = true,

        breakchannel = function ()
            removeDebuff( "target", "void_torrent" )
        end,

        start = function ()
            applyDebuff( "target", "void_torrent" )
            if talent.entropic_rift.enabled then
                if talent.voidheart.enabled then applyBuff( "voidheart", 11 ) end
                applyBuff( "entropic_rift", class.auras.entropic_rift.duration + ( 3 * talent.voidheart.rank ) )
            end
            if talent.idol_of_cthun.enabled then applyDebuff( "target", "void_tendril_mind_flay" ) end
            if talent.void_volley.enabled then applyBuff( "void_volley" ) end
            if set_bonus.tww3_voidweaver >= 4 then removeBuff( "overflowing_void" ) end
        end,

    },

    -- Releases a volley of pure void energy, firing $s2 bolts at your target and $s3 bolt at all enemies within $s4 yards of your target for $s$s5 Shadow damage. Generates $s6 Insanity
    -- https://www.wowhead.com/spell=1242173
    void_volley = {
        id = 1242173,
        known = 1240401,
        cast = 0,
        gcd = "spell",
        school = "shadow",
        cooldown = 0,

        spend = -10,
        spendType = "insanity",

        texture = 425955,
        talent = "void_volley",
        startsCombat = true,
        buff = "void_volley",

        handler = function ()
            removeBuff( "void_volley" )
        end,

        bind = "void_torrent"
    },

} )

spec:RegisterRanges( "mind_blast", "dispel_magic" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageExpiration = 6,

    potion = "tempered_potion",

    package = "Shadow"
} )

spec:RegisterSetting( "pad_void_bolt", true, {
    name = "Pad |T1035040:0|t Void Bolt Cooldown",
    desc = "If checked, the addon will treat |T1035040:0|t Void Bolt's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Voidform.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "pad_ascended_blast", true, {
    name = "Pad |T3528286:0|t Ascended Blast Cooldown",
    desc = "If checked, the addon will treat |T3528286:0|t Ascended Blast's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Boon of the Ascended.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "sw_death_protection", 50, {
    name = "|T136149:0|t Shadow Word: Death Health Threshold",
    desc = "If set above 0, the addon will not recommend |T136149:0|t Shadow Word: Death while your health percentage is below this threshold.  This setting can help keep you from killing yourself.",
    type = "range",
    min = 0,
    max = 100,
    step = 0.1,
    width = "full"
} )

spec:RegisterSetting( "hold_crash", 0, {
    name = strformat( "Reserve %s Charge for Target Count", Hekili:GetSpellLinkWithTexture( spec.abilities.shadow_crash.id ) ),
    desc = strformat( "If set above 0, the addon will not recommend your second charge of %s while there are fewer targets than specified.", Hekili:GetSpellLinkWithTexture( spec.abilities.shadow_crash.id ) ),
    type = "range",
    min = 0,
    max = 15,
    step = 1,
    width = "full"
} )

spec:RegisterPack( "Shadow", 20250823, [[Hekili:T3ZAVnoYr(BXiiCK2XwwpSN1ZalhSzFGD3lzZG4928HdXuuKTSigksgskRrbc63(vv)GSFsrPXENjhoGfESjBwD1vvD9QRU2hg9WV(W9rbvKh(LXdhF9WBgpzWWHxnAYBE4(QT5KhUppi8dbpc)sAWk4N3VmikBd(4Tjzbr4NxMTUieE1YQQ8Y3D5LpgxTC98bHzRUSmE16KGQ4S0WIGfv4FhE58KS5xwTKSjOydm040l)MqCiVVioRiUA7FjUSQ8YiYIG1jvxMxetkR8lPZ7aeapC)81Xjv)u6dZTI7JU6H7dwxTmRaq34vFlGzXrre2WjLW3FXf7N9Rlj7N9pckGFqrI9ZUNeuMb)7K9)mcVlgEZfJN8U9Z(M3)xGxUnn889Zwg8e8zlwddlVGuwgN(i8NjbLlH3rcsA(0rdHp9x3qc(a8XuKF)SVTahy9qgEdmKFi(J7N9BzXrWOZkkiPv7NfUminLKukn0RPdTOSIIppCFcsKOmpgDc(1FHYmdO0sGReNqsr2cjnyEcj6H)8dvaHchsZtUplhgjPQ5ZEkOigFl(BjRH)zrqsj9Vk8zsalZsIGLTFiUyqyo5OHzpyjMbGjBt6GNGLUpPyDoo2bfKvbXPL7ND709ZEmmAWQaG88vitzM3(zvbWIQs7B4t9(z72jb3OGIp4hugsslXbToxgaAVSgc9zarEAQymLMX0aL8YTHlJd9tIt)GY7vxCciOS2UIoWZ2ptqCgOqxfVD(6flOqzrwXkyriZiYHzXhEUFyujYhUsJpecBMiaWzmINi(KuYkyZ0(z3TF2yGhvvehwHIn1CQWGKeF2F4Jsym5m(8fKrWP5ATPr8TfRtD(P4ch(w4HWCM(bcv0LjVkbjU8fO2POAzbjiYFtbaJnfb5LpC)6sIF2If(GuHco7A8nlFz25CyVQkZ0(3lnAGEbmSXcwsnZDvCQaEO0fk4CMQSJ5K1J(FToLzj8zCKvyAk23)GlJkHIfoy7BtvaNjpNuueKckCZjjjG0fQ63fP36GBO74(3AHEqMBifrPI0w(YbLvGPg(UdB6vyiykzDrqIF52uy5HY0GUYqsHBK05h0GO94yvE2gsHF5AeBeSu6laIxrwoSvViErd3UERlxO2FKpo6shVDS4T9fIc67U1uH5q1iYeVAOe2zrvxFBkeyeqWAfimeLv6NhNKvbBwFCzLBYNJHFiUSZvNeHooDX6sJL2OdT04VoRSKotlqeYVr5kSvDOn9uSv)JKGIhbgsePOee(G1M)hiBBr9IZpOfkao9VXHAYY8TRaTci02qM7wk0nXrShscsfK8SIkXoiCGtEJnIdQ4hfDoGeOlsVQ6ixgr96Moley9AqIUUQbVhZIswZv62jAXOHnsnDCQ61Qa2OXmi(fez0j2IMUoWokV2)83mSvnHn(dP(o5fsBGFsT84zMmtylc1Rh2MxT9oWUSV2XUmiQH)njY)XKGO4aW8xP)8GOhXD4(lifzHqyg22698RTIZEANnA4YOfL(kIXK)1648Cs0ahg3A2yyYV6K(tobVlKrGlCJtppFzjSV8KbH8eADawtRkzEXcUc7lSVB1v2dhdKHp5)juVst8C3J)rJZ(qCq(pvvEAXWnugSYqnUeaQFoqdIXXFsbZns1vBW3PQbvXRiGxN(rXeo38M2NwDxvo80cswCsyugSXkyvEmeodmPRdHONE9(z3qJBKpmqOHLbbw4vdIt9xq9KHY7TnczDS9zlIAp64mJAn51VqBHrt3qrCoBj8R)TV7VbrX)3jiYcQeYqHoi621GVfLXf4CnNSm4P4mqWfZmc(kQzm8vu5ZszQiSUl9bLJw81PtKpZLZfTst7t3vWcCTia1s9eQtlikQCaM)euf11mAITxFBTXv93gMTMgCcLBD0yLS4xlbt3kp2csr(indlTL4dDx86evVlcTTKwGtwuuwvs6Aqzj8v(b55jXaYtvQLxqcZwnpWmxsm90BYkIW8nufxToICGel1WtQTQtP815XO2F46hFAQFqJRSaSgunAWYaylbORgNrEUC(8(Y4YbLXpMcH)b2mRws8ZXSCUvY3rPb3K8kWCgUE5PEyivmVHdQfV5jRaTEQh32I4ZZlpcc34JMWnUHWzt1zbXjPRw5BbUviKHwkMxDOyOdWeSz6gM6E62vyY9BqXVclUS1rWzAGJdvAmVV90akMitufhMqnAkZk1b8OHYQJckcdsjISAPPiAKURyUtdAtEy7zgP8uEyEOyPTpCSuulI8blL(ibc0KMYGKmk(PRPuvri36YbWA03qGKr8dHz4Aky11CQOaMJG2n(zBfc2IVrMPjBOQ2fyBo(k(KdLjzj3NTy9WXeFF42WeGXtDYSKMMgLqnmTkwNpQZuERUbqXqoGRIQHPQhtHM7E)i8n7NjoulbSz(9LVgGwg(JFJVcXt)H6eaoKA2q1YGk0xWKK9ZsIXJEc)7ecnR0JaNfkbt2PrLNdUkYDPC0yKDtjq7NXwPjWSVzzCcHEOv550dT6BY(EBgCTlnQSW(Vlj6hPfDMrA5wlRi67yidsgaNRy)TqlsnYnNqXmYIfXHX08vZ8c2aIfKfGALL47tbSOutA3UVtmXw8SsSi2EGiw9ShW6Hs0t)wuUmrjRmQz16qXMsZAIS7z0)TvVWCH(Ns(R6a6jP8ybeAdD5ztC7ZgcIAqfy4CsrjP4dGKInpP(8HIxlHIib0FX6IT28z5lcueZ4szfMggu3Vn3GQLiWZl3hpUCBAwUny)SLWo8PVsuqbB2SzWMSnWheXQQa8mJMoA4W3m8s6A9cXA9v39E8V3p7N4p42ldURw)sNH8BVA8vV9sbH6v39B8FJbnm88UcQjVD0OHV9sK6Ern19v39DWFdQGfpGb34sHD4bGE1LbyqZrWMNWkuTAWIkCHTnBn8tWv3UJdDMqbtlLd8dS6z4hX6zGzUQidu((lKpUU8I)lyBYRam9BZwbk0JQDdxwkukVCWNGBSk9dfJxOlnlOA5CiY)ijbuHP15zGBdC)(XXvcXEQPU1(qKZF3ejfWDjfSh7bYX3J0Kd(dNq)2Qobd4yXDsvGGUuA)tDNjE7LMGyPylqd1KaieG025ILhd4SJQmvT9BobLT1rt2)G2EBtfLvRRu7pCJR28Q)kTdV5S2nUdHV4pplDD5GQnBg7FvEOt)b00nYjO6HAPerGkz8Vg8by)hWYHF(xXOHi45okRAa9scinORCzCp50iOywdb3QlP6kevSeGvqW0XGJvbOFvmXeegXPOFIiFPklt4JMWbBZAOWLmjqgZHqXxaUTfnqGPYIBS3OEg20rWb8Q6vRAGjN16i8uRid2KiyCwIPzSweBqiuLHb5i0W9cRiYf6J603sjdXw)2QlKWLiLeM7P04q4q09Eq1P0HQQwujPqFLlFQRK2hrXViYtGLeGwY3gjrKBExZI0w091bPjJcphc0SQH775qegiA2iAnM08AcA2cga3p7pZQrN46h8DC0NnlPzvntffs0Tfb4msF33ueU0qn0Pim)zwC9yfeXZOrjP9NQWr93Qx(m9BsDJfXg1nu28e0qXg4ztQIAnsA2Amk7FkTmiLgLn6UsivGGjgqfOEFsWJRjd()q8yoGWtrisSo9ZPlZ9YfpwCnHbFypwkrVG(BxtvmiTsk9jBjkZ1RnhyuCjGvvKiWOAqcazLp4chwc(kr(YeozyKLUoL3O6IhST8ObYr5KIGkmnQbBXc9YIKLymycAWbXeCOvWlntkLlZwNe1KMJ)rwr07WVlaDObnxMboEc)tuWQGhrLymjnQS5Csc(nF91)rzjoe4vlhKhwX8p4RVMLrcuaZwkjoCg8Lec0pkPPMYAc5pN53Q1KocUt74ShBjNdUpB9jcLq2oVyMkPANZCDuyU3q1VJYt8cN1voWA2E7odyu5CUHfzdCO6kHsaw6UsYqbe83mYNf9R1e1Epn(pQzkfRxLupTzow3UR0OCbNttp6UCaIaLo8dujvpjclNB2bzev3MnJerv)OvVfRbWNM4HmECax0uCysBqYZATdtTM2djp71tvKqWrMQhHQmApZ1SR4Wa2z)WuN7VkOQIxalIvN8lAoFHwZ5SD1xsMrPYx4etLjQW7ebnwh4HfzRegrbrB6SAl3tkEbsD24GPP3MvlvlTKpscxdAWz(Ou7GHAyTkrBPW74IWkUxZVtfczFfxSxrfuDyQvycfqzmV0IQO(nAYvsoBTynOZPGW85IVgmWXoVG6RXJ5(7UI6Z8810ReY72eJvjY7AlRB6u82ztwZbUyBnPybje9bG(szxFu)m7liDQVwaoAl3VlJ7NEcPsovcF)hbDOeMF)urziYwGZ)en2H4QbTLkdMSAwYbevTW5zmEp9aWqy1SAVuAXIR8HdgzZacUwyv7p9yHwsyh8ZwH2D6tsO(TxjCxh9sb0coa2stWnsiTbx6uZeZPNOeQmh9bjmyT6SGrdLLsZLyyirC2lyMbIG)9PAk7MLXOrPhxhGvOpbnRclL4vRxrpBgGZ3wwnooXSw9J9wMFSEhsJHU0vVxOGONuNPntjd6zY0EGuo21R8k9qOeBPQ2SzIFansvmdu(ljjWUW6RmHizk0XkNImxBMYEIuarzWe9eRMdgKF9jUBYsJbjLcKc6hVOoBrQlui0b(gCPbVAfblTuIwDe2IBFmg8HTHmEW1gre7Y4p70(7AkFSKLgTB6t)UjGrfAoOcrtta1QpKUZGOEW46dl(ruzzkbVEJO1i0aow300JNfJDOTaZPiXtzjjKTUN3FJ(EPPLfVeHRvUmt1D0A7cCaRsdUU1nhEQg0534kQSKpVUdBZyQl)iPtCRXIs3cVijyBhmvwpw)ADdg7((R)WpXZ8fWGYYIq8UQkl9yklKwWJ23ZCOQBOdhYVAumAPrJpJuVj3loLFmGfJODqkWg(DUnhgce6wiw)LPpsSwjlnX)29IbHxHabutCEUdKySS(e1jOjuj((DZWLQ9r0vHNylevMrnLm5OZuKfUNAf3uKUBlazhSDt3CpK8HPwO3)SuelJl1I)LlS1K72NcItymsQwfueXvGxnoHFWGqoZQD6csaMFgZ085iVNTC0GNMw9aKk1EwU)KsFWbtrEwH8w7M6fsnP8uUanuqRwnAyn440JiPBrz0IJBwDvIPNV9Ku2IBQiIQhVqdIspjD)66QcvDODqE437YN4wkMk8q2P0x6mSVUkXWSuX1LIN(ol(8FDd9POuXpa(mna7zbv4aO5pOcFl9Q5Gj)et3OFrE(QP3I)8owSdRONhdO7LgIW(zqicrdeZA5auPYRNEPEsZohtx2ukebmcubT484ftpJ7zQ0ScmcpZN6dHM5xve)4JaddajwrAu8dhEpopRyzqEzw02D7QzIpHv4i4IBr9ZqkD)UBZZ6Tuykl9sYjwbDXJ(POhFPqOrkX0kbLvGFZ00e0ajkJ3LxZ2seK0rQsTjPKx4MlRxnYH12qob4BQhYG9VEY1wu8HjP1LZEhadp8rs4zMVFhOWj5MLwCfGj5Y7MoULqiW6MH(BnJ4XKS5yTgXqJXYATKeY00An(zQYi51Eei5el8CkaDJAZf5gLgklXCmFNy2lPQMlZd2qdtJjDWR5tLJZYX9XHDtOh)mLNsxcSTrf0Z8y3jg4sGNhq6IWvIhpYfrBbo(sSqO4UUfWdonmZ3hXSyLCGz8NDitY6UTDytMi0pcQAz2mcc)xRPb1Pz(H5ncnRB0smMMao0OcozOQbQ1lm4qQNhXvsEBeUMg2k(zRZhyAkvpAilhHhDNlq4Qck(9hpL1B0YjibMK26NM9uGvkCgc2FbERyN)FNBdKHayG7WVwFda)9AnQ5EMWWSizttzAHASFwpabbOIjZ9ePGEQu8UZ0iqpXMGIuSAaF4EA7xkEfEv95i3ReNU7RWc8MUmJqx(X0EgSUkBfSmJO(gdbkwoy)p)xO8)rVdRfXuyYOV(vhSDUWUUHVIrpp8WHb2B0h7FAZhMw4UpDWO)uMT6t6ORti)dAMZ9)Sf2cQz84yjFTksNrpQD0)sMs9xPN907g9gp35t)pYtb7TthoyKyzDCG4sfqmGVmxabRKTHPzDDbQCfcOG7tmdtPzGx1J85y8USXr38SaRGv5rhfHdokOkyEqj5DarfRkIU5pSdoq9fZ84ydt0KDe3xo2nwKU3g9rcIylSwCr7AnAmifHZNHjqC9)obqZ6eeBBdZBgYZlW)eWAuPiSzadkTnmxDyp)tYNWkyjsAAd3fd45eWFc4lAoRn0L)(NrWE8iRJl7Qf47EKDCQmUQSwMeBJ5ff81a(khaECxuP4yqky(ZWe4I92bq7sTI1H88c8pbSUn1joh2Z)K8jScSRAXYaEob8Na(Av5I57Fgb7XJSDvNvBJSJt1HvQyFmVOG)ZHBKideDs8NO(hIW)gviJE)Hfuw2IySqr)d)bicWFNAlV7)zC2UVg0Flc6907jggUjEdHaoW8O3gCZq(G)oWX13HHtkAzU4AtKl6AVEF90lT1asSpYM2jstkQv68i2)mrsKzz6MZ3f9xJZP1B70Enw5mTvSBNL3Y1iB9Ds67S(EQMfRVbfcKFHJTx99KqydX37MoEy)JHwm2oTWMDZgKZ06K13zLwORL16BuPfov1irlSSvUZ0cLM(X58TcthDEw(uABUOlWqPjFCQWGDkZnF94J6ZvBIh1qz4rbeZM2HvaHBZTbmrdvJJrqGRPXzRl9xfKg4pNwTPBTJgQD)JUodwA4S2bpMbsu1b7OmehB)TtVYRNsLaFhq1hUBN(Wg337mZQFMHL)p3VTiEX)KQj)7Fct4hRq)WSiwv(TumGMFTQI1KZ3ZpMo(bdgLrkX68jjMEcEz8pdpcA87gSNwHG(LXPHe652Ihgqj(DRbE2f07etlAmzNNX58MkY0RTrcgn2LGHCTjq17Yjb2Q5aDA2D3iP1hXhwJlx(rQsEkNZhkQbcAC1s0MvU7VuUJzR(H9AVuTUDkpdsF1epBhp9UDUkXS15EwRMS(1NPPCQ4eJvUZI7z)6cwJzx5DM9Ja1Jz9t(41LOm2pJ3GmY5S(coOsYqe4UXYqqRHFlunb(WizfhayBtwtBGb2ISF2x(9mf9vMMSVYjpXiH90loO7gkXXm7fnENXMbh1HtFoBLOxNCi97lVwZIo9srBdQPWXX3Rkc1iM40wiF7SKjr2oBnj4)KSsS2HSMzsf9fdBMONdWrfumRrnWgZnu(6ZrRJSR4jV6200pYjJMLI2RV5R61QaRNT3YTf0V)Dt13ESBxJmHknRRRGwmqySz8cNlS(3ELN5XQF3OR3TZ8X3oAOXGPNdZDhZmIsbo0L3cr0yIzTUYUsTm1aDeSEhBFps2kZ9iUq(3efjvnPOQ6yMra6HHSHexiePzU8uYnpKXgft6Nx4an0aWIpnos8VOAL1TnYQBjJEaXUD0NByvVVH7Gtq3bPdwUzob25XBsMNYGVD6KH6OwDBscXo74INbs7e7SpR3OpPnD(OxWzvwJlFAR7MrVKt716tRAhk6fEQfwJF27sp))TZOosOgWJ66hjFioj(FILAXCAXv8ywAAa72tHHynqngsMSsikSKqtYGi2bzPeu4P2VCtbixVQoJdd9mBRmw1avltnMHLMyAC6tzFaCW5JabnnODuUZc272zIFcppn7towOFUXQATJTSb0YMkA0222SD1WMnBNuNRYqtCD7jdXWw6LvmgMCFSYRhJe5Q)vjmq0wVR62jGTLE2IY0MEjNfGEFq3upRHE65owvPVrk7fE63ZBPHPegIJqvrKHYJo9UeLPH8tw0wZWnyveeS0tTZvd73xWmT4tWXU5D01mcWj1oCEX6Vt6evrQVSib0tVgF9S3OuUB6vEs3Ac26dC9Z4zENz0Iumsm046uPfBwbYnavlXkE9SDNS5xPIPaV(mxsPnG0vYDSMCO7Qto0vCzo97(PNTlsYNGeXNJgKKUWIcPGUbS7IiVicehMXJrlqJFR7mj(yvVRj9Bm48C3II0PYQY2FHqMLciuVsQbvN72jkoV7M2B8Wl6D9xjHf0Mmu)x38qJ7Qt)lmwIF14(97RtASNtrUn9sjw0Vt96hdwNwFiczEnLo)Tt)6RPb(YXYFpl36gmvUSW5gaKiCFgQWANOMubxlr0(IScQDtEfvdETNVQ1w90Xd90QPA58GYVCwDiBDsBqvZyJw2qz78DM5olNb0ed0X(2q8awWfPP)6tqfXMz6C01G7w2tMKP(P(6j7(lPUWKbfQr5lv)DBTLjVAkaNVEaoe6JQUZ5nA9T0(LGp4y4ji8T6LL7d8satUprwJzt4o8lC7kYGtyCvHSDEnU7gt1NKNslAcxiT1tEm3axF3cSECrTDbLUBQCNrI7CcXwFpO(elRLGuVJa1Ddj1ZZSPtibSEJISF6O3iX4BTJhjn)DajzIdNAR(XGcRt(SrN1dxS(OxvAUrEQdthVTEyWnkN(p3o8JdHwywSrlneu6(f6qLXBTT0CsS3w8rfch3RTnznC3EFIXdoPFJZWcAZTtN4kceRBvQFSAmiIRzT72c0TxXgJshZwr08u7Em2fo4QwSXmCvGchqx34bxlftND7myz44kvaAXZtvv1)qCpG)yDxD)ZLVkYtTL(R6oC05wUDYthPt87ql0XoLM1LfuuIP1wDUD61oeM8KTgO1kDUZTMAB(hatclfgoARnwDeIErVDQp2Ax0XzLn8Y3pAC5bb7KLpcj92RPd6k8Zt7uXs4fhQGwK6ToE28ACmBFT9UPJ8XaZ9Xf80WSez0D6F6iEIh0jInsVtD3NC2TZvOfwzmnolFGAXPr08)q6Bl23t62z0ZSyOI2JCuZTKu(YCEGe21Q2MgUdB4Vf)40mzBXeQuNgrlfugtSiZ4kTbM7yA0)IOdU8ZshahhN)YUjU0UM1w0KAPKCMozytOzg9Yfp79VL7uQbJJjarJ2GXTJh2SGL6xlEMJCY1N6C6kFSEgDB9UB2L2SuWjWM7kA(7W78kNR3wvKlaoX2uB5Q73T2IYbLSSibnEOjIEQn8J9YDUKtLBBkH9mIGNeo1Ad30fUDSTXKwrnmrzY5dvKQ)xlvR)4VKTyHpebgG2mnEw7acsBQACf27GDdcEr9nDS05OiLheJZqKb2E9ouFFqa3roodY(TIAkD(bai9pAIKLRhbsHWazfbAnKhoP5i5XBo9QJEAD8)3(BopFDl2ocqU2wH2n3YYB43JP(hrXu0CIAdDwiyh9shuid8SOSs)84KSk)6mURsZDvwd2R0aG37gfTMk2XdpAm)rcOxagAePOeKcGLH)hiBlnW92bmfuL5Bz3lSs)nK56SDBRoMqO03bo6c(UXebbB6VrD9D34RgALvBNg5ktcE23uUBxVUHVYve6bwbJg2)GSyRjXF0yAnR8YTuTv8vJDkUzRgUM(MHUslHT8PyfetgkQdnvHNbYxTtNcCGbN)n4N)JjbOxozWNopi6rc1jxc4LoylQrk85yxxtLsPqp9oGQgQuGuPNzvnPNvs5jTpV85Ev)8I70gWzi2e4UH2BPE4)n]] )
