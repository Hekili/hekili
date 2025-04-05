-- PriestHoly.lua
-- January 2025

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 257 )

spec:RegisterResource( Enum.PowerType.Insanity )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Priest
    angelic_bulwark            = {  82675, 108945, 1 }, -- When an attack brings you below 30% health, you gain an absorption shield equal to 15% of your maximum health for 20 sec. Cannot occur more than once every 90 sec.
    angelic_feather            = {  82703, 121536, 1 }, -- Places a feather at the target location, granting the first ally to walk through it 40% increased movement speed for 5 sec. Only 3 feathers can be placed at one time.
    angels_mercy               = {  82678, 238100, 1 }, -- Reduces the cooldown of Desperate Prayer by 20 sec.
    apathy                     = {  82689, 390668, 1 }, -- Your Holy Fire critical strikes reduce your target's movement speed by 75% for 4 sec.
    benevolence                = {  82676, 415416, 1 }, -- Increases the healing of your spells by 3%.
    binding_heals              = {  82678, 368275, 1 }, -- 20% of Heal or Flash Heal healing on other targets also heals you.
    blessed_recovery           = {  82720, 390767, 1 }, -- After being struck by a melee or ranged critical hit, heal 20% of the damage taken over 6 sec.
    body_and_soul              = {  82706,  64129, 1 }, -- Power Word: Shield and Leap of Faith increase your target's movement speed by 40% for 3 sec.
    cauterizing_shadows        = {  82687, 459990, 1 }, -- When your Shadow Word: Pain expires or is refreshed with less than 5 sec remaining, a nearby ally within 46 yards is healed for 168,494.
    crystalline_reflection     = {  82681, 373457, 2 }, -- Power Word: Shield instantly heals the target for 31,116 and reflects 10% of damage absorbed.
    death_and_madness          = {  82711, 321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below 20% health, its cooldown is reset. Cannot occur more than once every 10 sec.
    dispel_magic               = {  82715,    528, 1 }, -- Dispels Magic on the enemy target, removing 1 beneficial Magic effect.
    divine_star                = {  82682, 110744, 1 }, -- Throw a Divine Star forward 31 yds, healing allies in its path for 45,212 and dealing 65,137 Holy damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond 6 targets.
    dominate_mind              = {  82710, 205364, 1 }, -- Controls a mind up to 1 level above yours for 30 sec while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings or players. This spell shares diminishing returns with other disorienting effects.
    essence_devourer           = {  82674, 415479, 1 }, -- Attacks from your Shadowfiend siphon life from enemies, healing a nearby injured ally for 126,370.
    focused_mending            = {  82719, 372354, 1 }, -- Prayer of Mending does 45% increased healing to the initial target.
    from_darkness_comes_light  = {  82707, 390615, 1 }, -- Each time Shadow Word: Pain or Holy Fire deals damage, the healing of your next Flash Heal is increased by 3%, up to a maximum of 60%.
    halo                       = {  82682, 120517, 1 }, -- Creates a ring of Holy energy around you that quickly expands to a 46 yd radius, healing allies for 154,287 and dealing 218,049 Holy damage to enemies. Healing reduced beyond 6 targets.
    holy_nova                  = {  82701, 132157, 1 }, -- An explosion of holy light around you deals up to 47,632 Holy damage to enemies and up to 22,114 healing to allies within 13 yds, reduced if there are more than 5 targets.
    improved_fade              = {  82686, 390670, 2 }, -- Reduces the cooldown of Fade by 5 sec.
    improved_flash_heal        = {  82714, 393870, 1 }, -- Increases healing done by Flash Heal by 15%.
    improved_purify            = {  82705, 390632, 1 }, -- Purify additionally removes all Disease effects.
    inspiration                = {  82696, 390676, 1 }, -- Reduces your target's physical damage taken by 5% for 15 sec after a critical heal with Flash Heal, Heal, or Holy Word: Serenity.
    leap_of_faith              = {  82716,  73325, 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    lights_inspiration         = {  82679, 373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by 8%.
    manipulation               = {  82672, 459985, 1 }, -- You take 2% less damage from enemies affected by your Shadow Word: Pain or Holy Fire.
    mass_dispel                = {  82699,  32375, 1 }, -- Dispels magic in a 15 yard radius, removing all harmful Magic from 5 friendly targets and 1 beneficial Magic effect from 5 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mental_agility             = {  82698, 341167, 1 }, -- Reduces the mana cost of Purify and Mass Dispel by 50% and Dispel Magic by 10%.
    mind_control               = {  82710,    605, 1 }, -- Controls a mind up to 1 level above yours for 30 sec. Does not work versus Demonic, Undead, or Mechanical beings. Shares diminishing returns with other disorienting effects.
    move_with_grace            = {  82702, 390620, 1 }, -- Reduces the cooldown of Leap of Faith by 30 sec.
    petrifying_scream          = {  82695,  55676, 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear.
    phantasm                   = {  82556, 108942, 1 }, -- Activating Fade removes all snare effects.
    phantom_reach              = {  82673, 459559, 1 }, -- Increases the range of most spells by 15%.
    power_infusion             = {  82694,  10060, 1 }, -- Infuses the target with power for 15 sec, increasing haste by 20%. Can only be cast on players.
    power_word_life            = {  82676, 373481, 1 }, -- A word of holy power that heals the target for 892,665. Only usable if the target is below 35% health.
    prayer_of_mending          = {  82718,  33076, 1 }, -- Places a ward on an ally that heals them for 54,645 the next time they take damage, and then jumps to another ally within 30 yds. Jumps up to 6 times and lasts 30 sec after each jump.
    protective_light           = {  82707, 193063, 1 }, -- Casting Flash Heal on yourself reduces all damage you take by 10% for 10 sec.
    psychic_voice              = {  82695, 196704, 1 }, -- Reduces the cooldown of Psychic Scream by 15 sec.
    renew                      = {  82717,    139, 1 }, -- Fill the target with faith in the light, healing for 162,642 over 15 sec.
    rhapsody                   = {  82700, 390622, 1 }, -- Every 1 sec, the damage of your next Holy Nova is increased by 20% and its healing is increased by 20%. Stacks up to 20 times.
    sanguine_teachings         = {  82691, 373218, 1 }, -- Increases your Leech by 4%.
    sanlayn                    = {  82690, 199855, 1 }, --  Sanguine Teachings Sanguine Teachings grants an additional 2% Leech.  Vampiric Embrace Reduces the cooldown of Vampiric Embrace by 30 sec, increases its healing done by 25%.
    shackle_undead             = {  82693,   9484, 1 }, -- Shackles the target undead enemy for 50 sec, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shadow_word_death          = {  82712,  32379, 1 }, -- A word of dark binding that inflicts 98,870 Shadow damage to your target. If your target is not killed by Shadow Word: Death, you take backlash damage equal to 5% of your maximum health. Damage increased by 150% to targets below 20% health.
    shadowfiend                = {  82713,  34433, 1 }, -- Summons a shadowy fiend to attack the target for 15 sec. Generates 0.5% Mana each time the Shadowfiend attacks.
    sheer_terror               = {  82708, 390919, 1 }, -- Increases the amount of damage required to break your Psychic Scream by 75%.
    spell_warding              = {  82720, 390667, 1 }, -- Reduces all magic damage taken by 3%.
    surge_of_light             = {  82677, 109186, 1 }, -- Your healing spells and Smite have a 8% chance to make your next Flash Heal instant and cost no mana. Stacks to 2.
    throes_of_pain             = {  82709, 377422, 2 }, -- Shadow Word: Pain deals an additional 3% damage. When an enemy dies while afflicted by your Shadow Word: Pain, you gain 0.5% Mana.
    tithe_evasion              = {  82688, 373223, 1 }, -- Shadow Word: Death deals 50% less damage to you.
    translucent_image          = {  82685, 373446, 1 }, -- Fade reduces damage you take by 10%.
    twins_of_the_sun_priestess = {  82683, 373466, 1 }, -- Power Infusion also grants you its effect at 100% value when used on an ally. If no ally is targeted, it will grant its effect at 100% value to a nearby ally, preferring damage dealers.
    twist_of_fate              = {  82684, 390972, 2 }, -- After damaging or healing a target below 35% health, gain 5% increased damage and healing for 8 sec.
    unwavering_will            = {  82697, 373456, 2 }, -- While above 75% health, the cast time of your Flash Heal, Heal, Prayer of Healing, and Smite are reduced by 5%.
    vampiric_embrace           = {  82691,  15286, 1 }, -- Fills you with the embrace of Shadow energy for 12 sec, causing you to heal a nearby ally for 50% of any single-target Shadow spell damage you deal.
    void_shield                = {  82692, 280749, 1 }, -- When cast on yourself, 30% of damage you deal refills your Power Word: Shield.
    void_shift                 = {  82674, 108968, 1 }, -- Swap health percentages with your ally. Increases the lower health percentage of the two to 25% if below that amount.
    void_tendrils              = {  82708, 108920, 1 }, -- Summons shadowy tendrils, rooting all enemies within 8 yards for 15 sec or until the tendril is killed.
    words_of_the_pious         = {  82721, 377438, 1 }, -- For 12 sec after casting Power Word: Shield, you deal 10% additional damage and healing with Smite and Holy Nova.

    -- Holy
    afterlife                  = {  82635, 196707, 1 }, -- Increases the duration of Spirit of Redemption by 50% and the range of its spells by 50%.
    answered_prayers           = {  82608, 391387, 1 }, -- After your Prayer of Mending heals 50 times, gain Apotheosis for 8 sec.
    apotheosis                 = {  82614, 200183, 1 }, -- Gain a charge of your Holy Words, and enter a pure Holy form for 20 sec, increasing the cooldown reductions to your Holy Words by 200% and reducing their cost by 100%.
    benediction                = {  82641, 193157, 1 }, -- Your Prayer of Mending has a 12% chance to leave a Renew on each target it heals.
    burning_vehemence          = {  82607, 372307, 1 }, -- Increases the damage of Holy Fire by 30%. Holy Fire deals 75% of its initial damage to all nearby enemies within 12 yards of your target. Damage reduced beyond 5 targets.
    censure                    = {  82619, 200199, 1 }, -- Holy Word: Chastise stuns the target for 4 sec and is not broken by damage.
    cosmic_ripple              = {  82630, 238136, 1 }, -- When Holy Word: Serenity or Holy Word: Sanctify finish their cooldown, you emit a burst of light that heals up to 5 injured targets within 46 yards for 86,138.
    crisis_management          = {  82627, 390954, 1 }, -- Increases the critical strike chance of Heal, Flash Heal, and Power Word: Life by 15%.
    desperate_times            = {  82609, 391381, 2 }, -- Increases healing by 10% on friendly targets at or below 50% health.
    dispersing_light           = {  82604, 1215265, 1 }, -- 6% of healing done with Heal, Flash Heal, and Power Word: Life is replicated to 4 injured allies within 46 yards.
    divine_hymn                = {  82621,  64843, 1 }, -- Heals all party or raid members within 46 yards for 984,425 over 4.3 sec. Each heal increases all targets' healing taken by 4% for 15 sec, stacking. Healing reduced beyond 5 targets.
    divine_image               = {  82554, 392988, 1 }, -- When you use a Holy Word spell, you summon an image of a Naaru at your side. For 9 sec, whenever you cast a healing or damaging spell, the Naaru will cast a similar spell. If an image has already been summoned, that image is empowered instead.
    divine_service             = {  82642, 391233, 1 }, -- Prayer of Mending heals 4% more for each bounce remaining.
    divine_word                = { 103901, 372760, 1 }, -- The effectiveness of your next Holy Word: Serenity, Sanctify, or Chastise is increased by 30% and grants a corresponding Divine Favor for 15 sec. Chastise: Increases your damage by 20% and refunds 15 sec from the cooldown of Holy Word: Chastise. Sanctify: Blesses the target area, healing up to 5 allies for 448,182 over 15 sec. Serenity: Flash Heal, Heal, and Renew heal for 30% more and cost 20% less mana.
    divinity                   = { 104097, 1215241, 1 }, -- Your healing is increased by 10% while Apotheosis is active. Casting Apotheosis causes your next 3 Heal or Prayer of Healing casts to be instant and heal for 25% more.
    empowered_renew            = { 104108, 391339, 1 }, -- Renew reduces the cooldown of Sanctify by an additional 6 sec and heals for 60% more when cast, but has a 12 sec cooldown.
    empyreal_blaze             = {  82640, 372616, 1 }, -- Holy Word: Chastise causes your next 2 casts of Holy Fire to be instant, cost no mana, and incur no cooldown. Refreshing Holy Fire on a target now extends its duration by 7 sec.
    enlightenment              = {  82618, 193155, 1 }, -- You regenerate mana 10% faster.
    epiphany                   = {  82606, 414553, 1 }, -- Your Holy Words have a 25% chance to reset the cooldown of Prayer of Mending.
    eternal_sanctity           = { 104097, 1215245, 1 }, -- Your Holy Words extend the duration of Apotheosis by 1.5 sec.
    everlasting_light          = {  82622, 391161, 1 }, -- Heal restores up to 15% additional health, based on your missing mana.
    gales_of_song              = {  82613, 372370, 1 }, -- While channeling Divine Hymn, place 2 stacks of Prayer of Mending on up to 3 allies within its range every 0.9 sec.
    guardian_angel             = {  82636, 200209, 1 }, -- When Guardian Spirit saves the target from death, it does not expire. When Guardian Spirit expires without saving the target from death, reduce its remaining cooldown to 60 seconds.
    guardian_spirit            = {  82637,  47788, 1 }, -- Calls upon a guardian spirit to watch over the friendly target for 10 sec, increasing healing received by 60%. If the target would die, the Spirit sacrifices itself and restores the target to 40% health. Castable while stunned. Cannot save the target from massive damage.
    holy_celerity              = {  82612, 1215275, 1 }, -- Reduces the cooldown of your Holy Words by 15 sec.
    holy_mending               = { 103916, 391154, 1 }, -- When Prayer of Mending jumps to a target affected by your Renew, that target is instantly healed for 27,783.
    holy_word_chastise         = {  82639,  88625, 1 }, -- Chastises the target for 285,792 Holy damage and incapacitates them for 4 sec. Cooldown reduced by 4 sec when you cast Smite or Holy Nova.
    holy_word_sanctify         = {  82631,  34861, 1 }, -- Releases miraculous light at a target location, healing up to 5 allies within 13 yds for 439,752. Cooldown reduced by 6 sec when you cast Prayer of Healing and by 2 sec when you cast Renew.
    holy_word_serenity         = {  82638,   2050, 1 }, -- Perform a miracle, healing an ally for 1.5 million. Cooldown reduced by 6 sec when you cast Heal or Flash Heal.
    lasting_words              = { 103901, 471504, 1 }, -- Holy Word: Serenity applies 12 sec of Renew to its target. Holy Word: Sanctify applies 6 sec of Renew to allies it heals.
    light_in_the_darkness      = { 103914, 471668, 2 }, -- Increases the healing done by Holy Word: Serenity and Holy Word: Sanctify by 30%. Increases the radius of Holy Word: Sanctify by 30%.
    light_of_the_naaru         = {  82629, 196985, 2 }, -- The cooldowns of your Holy Words are reduced by an additional 10% when you cast the relevant spells.
    lightweaver                = {  82603, 390992, 1 }, -- Flash Heal reduces the cast time of your next Heal or Prayer of Healing within 20 sec by 30% and increases its healing done by 25%. Can accumulate up to 4 charges.
    lightwell                  = { 103900, 372835, 1 }, -- Creates a Holy Lightwell. Every 1 sec the Lightwell will attempt to heal a nearby party or raid member within 46 yards that is lower than 75% health for 129,529 and apply a Renew to them for 6 sec. Lightwell lasts for 2 min or until it heals 15 times. Cooldown reduced by 3 sec when you cast Holy Word: Serenity or Holy Word: Sanctify.
    miracle_worker             = {  82610, 235587, 1 }, -- Holy Word: Serenity and Holy Word: Sanctify gain an additional charge.
    prayer_circle              = {  82633, 321377, 1 }, -- Holy Word: Sanctify reduces the cast time and cost of your Prayer of Healing by 20% for 8 sec.
    prayer_of_healing          = {  82632,    596, 1 }, -- A powerful prayer that heals the target and the 4 nearest allies within 40 yards for 130,625.
    prayerful_litany           = {  82623, 391209, 1 }, -- The primary target of Prayer of Healing is healed for 75% more.
    prayers_of_the_virtuous    = {  82616, 390977, 1 }, -- Prayer of Mending jumps 2 additional times.
    prismatic_echoes           = {  82611, 390967, 2 }, -- Increases the healing done by your Mastery: Echo of Light by 5% and your Renew by 13%.
    renewed_faith              = {  82634, 341997, 1 }, -- Your healing on allies with your Renew is increased by 6%.
    resonant_words             = {  82628, 372309, 1 }, -- Casting a Holy Word spell increases the healing of your next Flash Heal, Heal, Prayer of Healing, or Power Word: Life by 40%. Lasts 30 sec.
    restitution                = {  82636, 391124, 1 }, -- After Spirit of Redemption expires, you will revive at up to 100% health, based on your healing done during Spirit of Redemption. After reviving, you cannot benefit from Spirit of Redemption for 10 min.
    say_your_prayers           = {  82615, 391186, 1 }, -- Prayer of Mending has a 15% chance to not consume a charge when it jumps to a new target.
    seraphic_crescendo         = {  82613, 419110, 1 }, -- Reduces the cooldown of Divine Hymn by 60 sec.
    symbol_of_hope             = {  82617,  64901, 1 }, -- Bolster the morale of raid members within 46 yds. They each recover 30 sec of cooldown of a major defensive ability, and regain 10% of their missing mana, over 3.4 sec.
    trail_of_light             = {  82604, 200128, 1 }, -- 35% of healing done by Heal, Flash Heal, and Power Word: Life is replicated to the previous target you healed with those spells.
    voice_of_harmony           = {  82620, 390994, 1 }, -- Prayer of Mending and Power Word: Life reduce the cooldown of Holy Word: Serenity by 4 sec. Halo and Divine Star reduce the cooldown of Holy Word: Sanctify by 4 sec. Holy Fire reduces the cooldown of Holy Word: Chastise by 4 sec.

    -- Oracle
    assured_safety             = {  94691, 440766, 1 }, -- Prayer of Mending casts apply a Power Word: Shield to your target at 100% effectiveness.
    clairvoyance               = {  94687, 428940, 1 }, -- Casting Premonition of Solace invokes Clairvoyance, expanding your mind and opening up all possibilities of the future.  Premonition of Clairvoyance Grants Premonition of Insight, Piety, and Solace at 100% effectiveness.
    desperate_measures         = {  94690, 458718, 1 }, -- Desperate Prayer lasts an additional 10 sec. Angelic Bulwark's absorption effect is increased by 15% of your maximum health.
    divine_feathers            = {  94675, 440670, 1 }, -- Your Angelic Feathers increase movement speed by an additional 10%. When an ally walks through your Angelic Feather, you are also granted 100% of its effect.
    fatebender                 = {  94700, 440743, 1 }, -- Increases the effects of Premonition by 40%.
    foreseen_circumstances     = {  94689, 440738, 1 }, -- Guardian Spirit lasts an additional 2 sec.
    miraculous_recovery        = {  94679, 440674, 1 }, -- Reduces the cooldown of Power Word: Life by 3 sec and allows it to be usable on targets below 50% health.
    perfect_vision             = {  94700, 440661, 1 }, -- Reduces the cooldown of Premonition by 15 sec.
    preemptive_care            = {  94674, 440671, 1 }, -- Increases the duration of all Renews by 25%.
    premonition                = {  94683, 428924, 1, "oracle" }, -- Gain access to a spell that gives you an advantage against your fate. Premonition rotates to the next spell when cast.  Premonition of Insight Reduces the cooldown of your next 3 spell casts by 7 sec.  Premonition of Piety Increases your healing done by 15% and causes 70% of overhealing on players to be redistributed to up to 4 nearby allies for 15 sec.  Premonition of Solace Your next single target healing spell grants your target a shield that absorbs 301,473 damage and reduces their damage taken by 15% for 15 sec.
    preventive_measures        = {  94698, 440662, 1 }, -- Increases the healing done by Prayer of Mending by 25%. All damage dealt by Smite, Holy Fire and Holy Nova increased by 25%.
    prophets_will              = {  94690, 433905, 1 }, -- Your Flash Heal, Heal, and Holy Word: Serenity are 30% more effective when cast on yourself.
    save_the_day               = {  94675, 440669, 1 }, -- For 6 sec after casting Leap of Faith you may cast it a second time for free, ignoring its cooldown.
    twinsight                  = {  94673, 440742, 1 }, -- An additional 2 stacks of Prayer of Mending is placed on a second ally within 46 yards when casting Prayer of Mending.
    waste_no_time              = {  94679, 440681, 1 }, -- Premonition causes your next Heal or Prayer of Healing cast to be instant and cost 15% less mana.

    -- Archon
    concentrated_infusion      = {  94676, 453844, 1 }, -- Your Power Infusion effect grants you an additional 10% haste.
    divine_halo                = {  94702, 449806, 1 }, -- Halo now centers around you and returns to you after it reaches its maximum distance, healing allies and damaging enemies each time it passes through them.
    empowered_surges           = {  94688, 453799, 1 }, -- Increases the healing done by Flash Heals affected by Surge of Light by 30%.
    energy_compression         = {  94678, 449874, 1 }, -- Halo damage and healing is increased by 30%.
    energy_cycle               = {  94685, 453828, 1 }, -- Consuming Surge of Light reduces the cooldown of Holy Word: Sanctify by 4 sec.
    heightened_alteration      = {  94680, 453729, 1 }, -- Increases the duration of Spirit of Redemption by 5 sec.
    incessant_screams          = {  94686, 453918, 1 }, -- Psychic Scream creates an image of you at your location. After 4 sec, the image will let out a Psychic Scream.
    manifested_power           = {  94699, 453783, 1 }, -- Creating a Halo grants Surge of Light.
    perfected_form             = {  94677, 453917, 1 }, -- Your healing done is increased by 10% while Apotheosis is active.
    power_surge                = {  94697, 453109, 1, "archon" }, -- Casting Halo also causes you to create a Halo around you at 100% effectiveness every 5 sec for 10 sec. Additionally, the radius of Halo is increased by 10 yards.
    resonant_energy            = {  94681, 453845, 1 }, -- Allies healed by your Halo receive 2% increased healing from you for 8 sec, stacking up to 5 times.
    shock_pulse                = {  94686, 453852, 1 }, -- Halo damage reduces enemy movement speed by 5% for 5 sec, stacking up to 5 times.
    sustained_potency          = {  94678, 454001, 1 }, -- Creating a Halo extends the duration of Apotheosis by 1 sec. If Apotheosis is not active, up to 6 seconds is stored. While out of combat or affected by a loss of control effect, the duration of Apotheosis is paused for up to 20 sec.
    word_of_supremacy          = {  94680, 453726, 1 }, -- Power Word: Fortitude grants you an additional 5% stamina.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_faith         = 1927, -- (408853)
    catharsis              = 5485, -- (391297)
    divine_ascension       = 5366, -- (328530) You ascend into the air out of harm's way. While floating, your spell range is increased by 50%, but you are only able to cast Holy spells.
    greater_heal           =  112, -- (289666) An exceptional spell that heals an ally for 40% of their maximum health, ignoring healing reduction effects.
    holy_ward              =  101, -- (213610) Wards the friendly target against the next full loss of control effect.
    improved_mass_dispel   = 5634, -- (426438)
    mindgames              = 5639, -- (375901) Assault an enemy's mind, dealing 222,263 Shadow damage and briefly reversing their perception of reality. For 7 sec, the next 777,921 damage they deal will heal their target, and the next 777,921 healing they deal will damage their target.
    phase_shift            = 5569, -- (408557)
    purification           = 5479, -- (196439)
    ray_of_hope            =  127, -- (197268) For the next 6 sec, all damage and healing dealt to the target is delayed until Ray of Hope ends. All healing that is delayed by Ray of Hope is increased by 50%.
    sanctified_ground      =  108, -- (357481)
    spirit_of_the_redeemer =  124, -- (215982)
    thoughtsteal           = 5365, -- (316262) Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for 20 sec. Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
} )

-- Auras
spec:RegisterAuras( {
    answered_prayers = {
        id = 394289,
        duration = 3600,
        max_stack = function() return talent.answered_prayers.rank > 1 and 50 or 100 end,
    },
    apathy = {
        id = 390669,
        duration = 4,
        max_stack = 1
    },
    apotheosis = {
        id = 200183,
        duration = 20,
        max_stack = 1
    },
    body_and_soul = {
        id = 65081,
        duration = 3,
        max_stack = 1
    },
    desperate_prayer = {
        id = 19236,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    divine_ascension_immune = {
        id = 328530,
        duration = 1,
        max_stack = 1
    },
    divine_ascension = {
        id = 329543,
        duration = 10,
        max_stack = 1
    },
    divine_favor_chastise = {
        id = 372761,
        duration = 15,
        max_stack = 1
    },
    divine_favor_serenity = {
        id = 372791,
        duration = 15,
        max_stack = 1
    },
    divine_hymn = {
        id = 64843,
        duration = function() return 5 * haste end,
        tick_time = function() return haste end,
        max_stack = 1
    },
    divine_hymn_buff = {
        id = 64844,
        duration = 15,
        max_stack = 5
    },
    divine_image = {
        id = 392990,
        duration = 9,
        max_stack = 1
    },
    divine_word = {
        id = 372760,
        duration = 10,
        max_stack = 1
    },
    divinity = {
        id = 1216314,
        duration = 3,
        max_stack = 3
    },
    dominate_mind = {
        id = 205364,
        duration = 30,
        max_stack = 1
    },
     -- Healing $w1 every $t1 sec.
     echo_of_light = {
        id = 77489,
        duration = 4.0,
        max_stack = 1,
    },
    empyreal_blaze = {
        id = 372617,
        duration = 30,
        max_stack = 3
    },
    fade = {
        id = 586,
        duration = 10,
        max_stack = 1
    },
    focused_will = {
        id = 426401,
        duration = 8,
        max_stack = 1
    },
    guardian_spirit = {
        id = 47788,
        duration = 10,
        max_stack = 1
    },
    --[[healing_chorus = {
        id = 390885,
        duration = 20,
        max_stack = 50
    },--]]
    holy_fire = {
        id = 14914,
        duration = function () return talent.empyreal_blaze.enabled and debuff.holy_fire.up and 21 or 7 end,
        tick_time = 1,
        max_stack = 1
    },
    holy_ward = {
        id = 213610,
        duration = 15,
        max_stack = 1
    },
    holy_word_chastise = {
        id = 247587,
        duration = 5,
        max_stack = 1
    },
    inspiration = {
        id = 390677,
        duration = 15,
        max_stack = 1
    },
    leap_of_faith = {
        id = 73325,
        duration = 1.5,
        max_stack = 1
    },
    lightweaver = {
        id = 390993,
        duration = 20,
        max_stack = 2
    },
    lightwell = {
        id = 372835,
        duration = 180,
        max_stack = 15
    },
    mind_control = {
        id = 605,
        duration = 30,
        max_stack = 1
    },
    mind_soothe = {
        id = 453,
        duration = 20,
        max_stack = 1
    },
    mind_vision = {
        id = 2096,
        duration = 60,
        max_stack = 1
    },
    mindgames = {
        id = 375901,
        duration = function() return 5 + ( 2 * talent.shattered_perceptions.rank ) end,
        max_stack = 1
    },
    --[[pontifex = {
        id = 390989,
        duration = 30,
        max_stack = 2
    },--]]
    power_infusion = {
        id = 10060,
        duration = 15,
        max_stack = 1
    },
    power_word_fortitude = {
        id = 21562,
        duration = 3600,
        max_stack = 1
    },
    power_word_shield = {
        id = 17,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    prayer_circle = {
        id = 321379,
        duration = 8,
        max_stack = 1
    },
    psychic_scream = {
        id = 8122,
        duration = 8,
        max_stack = 1
    },
    ray_of_hope = {
        id = 232707,
        duration = 6,
        max_stack = 1
    },
    renew = {
        id = 139,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    resonant_words = {
        id = 372313,
        duration = 30,
        max_stack = 1
    },
    --[[sanctified_prayers = {
        id = 196490,
        duration = 15,
        max_stack = 1
    },--]]
    -- Taking $s1% increased damage from the Priest.
    schism = {
        id = 214621,
        duration = 9.0,
        max_stack = 1,

         -- Affected by:
        -- twilight_equilibrium[390707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    shackle_undead = {
        id = 9484,
        duration = 50,
        max_stack = 1
    },
    shadow_word_pain = {
        id = 589,
        duration = 16,
        tick_time = 2,
        max_stack = 1
    },
    shadowfiend = {
        id = 34433,
        duration = 15,
        max_stack = 1
    },
    symbol_of_hope = {
        id = 64901,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    symbol_of_hope_buff = {
        id = 265144,
        duration = 1.1,
        max_stack = 1
    },
    vampiric_embrace = {
        id = 15286,
        duration = 15,
        tick_time = 0.5,
        max_stack = 1
    },
} )



-- The War Within
spec:RegisterGear( "tww2", 229334, 229332, 229337, 229335, 229333 )

-- Dragonflight
spec:RegisterGear( "tier30", 202543, 202542, 202541, 202545, 202540 )
spec:RegisterAuras( {
    inspired_word = {
        id = 409479,
        duration = 3600,
        max_stack = 15
    }
} )
spec:RegisterGear( "tier31", 207279, 207280, 207281, 207282, 207284, 217202, 217204, 217205, 217201, 217203 )
spec:RegisterAura( "sacred_reverence", {
    id = 423510,
    duration = 3600,
    max_stack = 2
} )

local naaruMulti = 1 + ( 0.1 * state.talent.light_of_the_naaru.rank )

spec:RegisterHook( "reset_precast", function ()
    naaruMulti = 1 + ( 0.1 * talent.light_of_the_naaru.rank ) -- manual syncing in case of talent change for completeness
end )


-- Abilities
spec:RegisterAbilities( {
    -- Reset the cooldown of your Holy Words, and enter a pure Holy form for 20 sec, increasing the cooldown reductions to your Holy Words by 300% and reducing their cost by 100%.
    apotheosis = {
        id = 200183,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 1060983,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "apotheosis" )
            gainCharges( "holy_word_chastise", 1 )
            gainCharges( "holy_word_sanctify", 1 )
            gainCharges( "holy_word_serenity", 1 )
            if talent.divinity.enabled then addStack( "divinity", nil, 3 ) end
        end,
    },

    --[[Heals the target and 4 injured allies within 30 yards of the target for 1,968.
    circle_of_healing = {
        id = 204883,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "circle_of_healing",
        startsCombat = false,

        handler = function ()
            removeBuff( "healing_chorus" )
            if talent.harmonious_apparatus.enabled then
                reduceCooldown( "holy_word_sanctify", 2 * talent.harmonious_apparatus.rank * ( buff.apotheosis.up and 3 or 1 ) )
            end
        end,
    },--]]

    -- You ascend into the air out of harm's way. While floating, your spell range is increased by 50%, but you are only able to cast Holy spells.
    divine_ascension = {
        id = 328530,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        pvptalent = "divine_ascension",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "divine_ascension" )
        end,
    },

    divine_hymn = {
        id = 64843,
        cast = 5,
        channeled = true,
        cooldown = function() return 180 - ( 60 * talent.seraphic_crescendo.rank ) end,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "divine_hymn",
        startsCombat = false,

        toggle = "cooldowns",

        start = function ()
            applyBuff( "divine_hymn_buff" )
        end,
    },

    divine_star = {
        id = 110744,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "divine_star",
        startsCombat = true,

        handler = function ()
            if talent.voice_of_harmony.enabled then
                reduceCooldown( "holy_word_sanctify", 4 * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) )
            end
        end,
    },

    -- The effectiveness of your next Holy Word: Serenity, Sanctify, or Chastise is increased by 50% and grants a corresponding Divine Favor for 15 sec. Chastise: Increases your damage by 30% and Smite has a 40% chance to apply Holy Fire. Sanctify: Blesses the target area, healing up to 6 allies for 8,655 over 15 sec. Serenity: Flash Heal, Heal, and Renew heal for 30% more, have a 20% increased chance to critically strike, and cost 20% less mana.
    divine_word = {
        id = 372760,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "divine_word",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "divine_word" )
        end,
    },

    dominate_mind = {
        id = 205364,
        cast = 1.8,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "dominate_mind",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "dominate_mind" )
        end,
    },

    --[[ Refreshes Holy Fire. Your next 3 casts of Holy Fire cost no Mana, incur no cooldown, and cast instantly. Whenever Holy Fire is reapplied, its duration is now extended instead.
    empyreal_blaze = {
        id = 372616,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 500,
        spendType = "mana",

        talent = "empyreal_blaze",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "empyreal_blaze", nil, 3 )
            setCooldown( "holy_fire", 0 )
        end,
    }, ]]

    fade = {
        id = 586,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 135994,

        handler = function ()
            applyBuff( "fade" )
        end,
    },

    flash_heal = {
        id = 2061,
        cast = function() return buff.surge_of_light.up and 1.35 or 0 end,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            if buff.surge_of_light.up then return 0 end
            return 0.04 * ( buff.divine_favor_serenity.up and 0.8 or 1 )
        end,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
            removeBuff( "resonant_words" )
            if buff.surge_of_light.up then
                removeStack( "surge_of_light" )
                if talent.energy_cycle.enabled then reduceCooldown( "holy_word_sanctify", 6 * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) ) end
            end
            reduceCooldown( "holy_word_serenity", 6 * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) )
            if talent.lightweaver.enabled then
                addStack( "lightweaver" )
            end
        end,
    },

    greater_heal = {
        id = 289666,
        cast = 3,
        cooldown = 12,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        pvptalent = "greater_heal",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Calls upon a guardian spirit to watch over the friendly target for 10 sec, increasing healing received by 60%. If the target would die, the Spirit sacrifices itself and restores the target to 40% health. Castable while stunned. Cannot save the target from massive damage.
    guardian_spirit = {
        id = 47788,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        spend = 0.01,
        spendType = "mana",

        talent = "guardian_spirit",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "guardian_spirit" )
        end,
    },

    -- Creates a ring of Holy energy around you that quickly expands to a 30 yd radius, healing allies for 3,176 and dealing 3,082 Holy damage to enemies. Healing reduced beyond 6 targets.
    halo = {
        id = 120517,
        cast = 1.5,
        cooldown = 40,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "halo",
        startsCombat = true,

        handler = function ()
            if talent.voice_of_harmony.enabled then
                reduceCooldown( "holy_word_sanctify", 4 * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) )
            end
        end,
    },

    heal = {
        id = 2060,
        cast = function() if buff.divinity.up or buff.waste_no_time.up then return 0 end
            return 2.25
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.02 * ( buff.divine_favor_serenity.up and 0.8 or 1 ) * ( buff.waste_no_time.up and 0.85 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135913,

        handler = function ()
            reduceCooldown( "holy_word_serenity", 6 * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) )
            removeStack( "lightweaver" )
            removeBuff( "resonant_words" )
            if buff.divinity.up then removeStack( "divinity" )
            elseif buff.waste_no_time.up then removeStack( "waste_no_time" ) end
        end,
    },

    holy_fire = {
        id = 14914,
        cast = function() return buff.empyreal_blaze.up and 0 or 1.5 end,
        cooldown = 10,
        gcd = "spell",

        spend = function() return buff.empyreal_blaze.up and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,

        cycle = "holy_fire",

        handler = function ()
            applyDebuff( "target", "holy_fire", buff.empyreal_blaze.up and debuff.holy_fire.up and ( debuff.holy_fire.remains + 7 ) or nil )

            if buff.empyreal_blaze.up then
                removeStack( "empyreal_blaze" )
                setCooldown( "holy_fire", 0 )
            end

            if talent.manipulation.enabled then
                reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank )
            end

            if talent.voice_of_harmony.enabled then
                reduceCooldown( "holy_word_chastise", 4 * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) )
            end
        end,
    },
    holy_nova = {
        id = 132157,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "holy_nova",
        startsCombat = true,

        handler = function ()
            removeBuff( "rhapsody" )
            reduceCooldown( "holy_word_chastise", 4 * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) )
        end,
    },
    holy_ward = {
        id = 213610,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "holy_ward",
        startsCombat = false,

        handler = function ()
            applyBuff( "holy_ward" )
        end,
    },
    holy_word_chastise = {
        id = 88625,
        cast = 0,
        cooldown = function() return 60 - ( 15 * talent.holy_celerity.rank ) end,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "holy_word_chastise",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "inspired_word" )
            applyDebuff( "target", "holy_word_chastise" )
            if buff.divine_word.up then
                applyBuff( "divine_favor_chastise" )
                removeBuff( "divine_word" )
            end

            if talent.empyreal_blaze.enabled then
                applyBuff( "empyreal_blaze", nil, 2 )
            end

            if talent.divine_image.enabled then applyBuff( "divine_image" ) end
            if talent.resonant_words.enabled then applyBuff( "resonant_words" ) end

            if talent.eternal_sanctity.enabled and buff.apotheosis.up then
                buff.apotheosis.expires = buff.apotheosis.expires + 1
            end
        end,
    },
    --[[holy_word_salvation = {
        id = 265202,
        cast = 2.5,
        cooldown = 720,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "holy_word_salvation",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "inspired_word" )
            applyBuff( "renew" )
            addStack( "prayer_of_mending", nil, 2 )
            if talent.divine_image.enabled then applyBuff( "divine_image" ) end
            if talent.resonant_words.enabled then applyBuff( "resonant_words" ) end
        end,
    },--]]

    holy_word_sanctify = {
        id = 34861,
        cast = 0,
        charges = function() if talent.miracle_worker.enabled then return 2 end end,
        cooldown = function() return 60 - ( 15 * talent.holy_celerity.rank ) end,
        recharge = function() if talent.miracle_worker.enabled then return 60 - ( 15 * talent.holy_celerity.rank ) end end,
        gcd = "spell",

        spend = function() return 0.04 * ( buff.sacred_reverence.up and 0.5 or 1 ) end,
        spendType = "mana",

        talent = "holy_word_sanctify",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "inspired_word" )
            -- reduceCooldown( "holy_word_salvation", 30 )
            removeBuff( "divine_word" )
            if buff.sacred_reverence.up then
                gainCharges( "holy_word_sanctify", 1)
                removeStack( "sacred_reverence" )
            end
            if talent.divine_image.enabled then applyBuff( "divine_image" ) end
            if talent.resonant_words.enabled then applyBuff( "resonant_words" ) end
            if talent.eternal_sanctity.enabled and buff.apotheosis.up then
                buff.apotheosis.expires = buff.apotheosis.expires + 1
            end
            reduceCooldown( "lightwell", 3 )
            if talent.lasting_words.enabled then applyBuff( "renew", 6 ) end
        end,
    },

    holy_word_serenity = {
        id = 2050,
        cast = 0,
        charges = function() if talent.miracle_worker.enabled then return 2 end end,
        cooldown = function() return 60 - ( 15 * talent.holy_celerity.rank ) end,
        recharge = function() if talent.miracle_worker.enabled then return 60 - ( 15 * talent.holy_celerity.rank ) end end,
        gcd = "spell",

        spend = function() return 0.02 * ( buff.sacred_reverence.up and 0.5 or 1 ) end,
        spendType = "mana",

        talent = "holy_word_serenity",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "inspired_word" )
            if buff.divine_word.up then
                applyBuff( "divine_favor_serenity" )
                removeBuff( "divine_word" )
            end
            if buff.sacred_reverence.up then
                gainCharges( "holy_word_serenity", 1 )
                removeStack( "sacred_reverence" )
            end
            -- reduceCooldown( "holy_word_salvation", 30 )

            if set_bonus.tier31_2pc > 0 then
                applyBuff( "renew", 14 )
            end
            if talent.lasting_words.enabled then applyBuff( "renew", 12 ) end

            if talent.resonant_words.enabled then applyBuff( "resonant_words" ) end
            if talent.eternal_sanctity.enabled and buff.apotheosis.up then
                buff.apotheosis.expires = buff.apotheosis.expires + 1
            end
            reduceCooldown( "lightwell", 3 )
        end,
    },
    leap_of_faith = {
        id = 73325,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        talent = "leap_of_faith",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            if talent.body_and_soul.enabled then
                applyBuff( "body_and_soul" )
            end
        end,
    },

    levitate = {
        id = 1706,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135928,

        handler = function ()
            applyBuff( "levitate" )
        end,
    },

    lightwell = {
        id = 372835,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "lightwell",
        startsCombat = false,
        texture = 135980,

        toggle = "cooldowns",

        handler = function ()
            addStack( "lightwell", 15 )
        end,
    },

    mind_control = {
        id = 605,
        cast = 1.8,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "mind_control",
        startsCombat = true,
        texture = 136206,

        handler = function ()
            applyDebuff( "target", "mind_control" )
        end,
    },

    mind_soothe = {
        id = 453,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135933,

        handler = function ()
            applyDebuff( "target", "mind_soothe" )
        end,
    },

    mind_vision = {
        id = 2096,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135934,

        handler = function ()
            applyDebuff( "target", "mind_vision" )
        end,
    },

    mindgames = {
        id = 375901,
        cast = 1.5,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",
        damage = 1,

        spend = 0.02,
        spendType = "mana",

        talent = "mindgames",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mindgames" )
        end,
    },

    power_infusion = {
        id = 10060,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "power_infusion",
        startsCombat = false,
        texture = 135939,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "power_infusion" )
            if group and talent.twins_of_the_sun_priestess.enabled then
                active_dot.power_infusion = 2
            end
        end,
    },

    power_word_life = {
        id = 373481,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 4667420,

        usable = function () return health.pct < 35, "health must be under 35 percent" end,

        handler = function ()
            gain( 7.5 * stat.spell_power, "health" )
            if talent.voice_of_harmony.enabled then
                reduceCooldown( "holy_word_serenity", 4 * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) )
            end
        end,
    },

    power_word_shield = {
        id = 17,
        cast = 0,
        cooldown = function() return buff.rapture.up and 0 or 7.5 end,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135940,

        handler = function ()
            applyBuff( "power_word_shield" )
            removeStack( "rapture" )

            if talent.body_and_soul.enabled then
                applyBuff( "body_and_soul" )
            end
        end,
    },

    prayer_of_healing = {
        id = 596,
        cast = function() if buff.divinity.up or buff.waste_no_time.up then return 0 end
            return 2.5
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 0.06 * ( buff.waste_no_time.up and 0.85 or 1 ) end,
        spendType = "mana",

        talent = "prayer_of_healing",
        startsCombat = false,

        handler = function ()
            reduceCooldown( "holy_word_sanctify", 6 * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) )
            if buff.divinity.up then removeStack( "divinity" )
            elseif buff.waste_no_time.up then removeStack( "waste_no_time" ) end
        end,
    },

    prayer_of_mending = {
        id = 33076,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "prayer_of_mending",
        startsCombat = false,

        handler = function ()
            addStack( "prayer_of_mending", 5 )
            if talent.voice_of_harmony.enabled then
                reduceCooldown( "holy_word_serenity", 4 * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) )
            end
            if talent.assured_safety.enabled then applyBuff( "power_word_shield" ) end
        end,
    },

    psychic_scream = {
        id = 8122,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 136184,

        handler = function ()
            applyDebuff( "target", "psychic_scream" )
        end,
    },

    -- Dispels harmful effects on the target, removing all Magic$?s390632[ and Disease][] effects.
    purify = {
        id = 527,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = function() return 0.013 * ( talent.mental_agility.enabled and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135894,

        toggle = "interrupts",
        usable = function() return debuff.dispellable_magic.up or talent.improved_purify.enabled and debuff.dispellable_disease.up, "requires a dispellable effect" end,

        handler = function ()
            removeDebuff( "player", "dispellable_magic" )
            if talent.improved_purify.enabled then
                removeDebuff( "player", "dispellable_disease" )
            end
        end,
    },

    ray_of_hope = {
        id = 197268,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "ray_of_hope",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ray_of_hope" )
        end,
    },

    renew = {
        id = 139,
        cast = 0,
        cooldown = function() if talent.empowered_renew.enabled then return 12 end
            return 0
        end,
        gcd = "spell",

        spend = function() return 0.02 * ( buff.divine_favor_serenity.up and 0.8 or 1 ) end,
        spendType = "mana",

        talent = "renew",
        startsCombat = false,
        texture = 135953,

        handler = function ()
            applyBuff( "renew" )
            reduceCooldown( "holy_word_sanctify", ( 2 + 6 * talent.empowered_renew.rank ) * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) )
        end,
    },

    shackle_undead = {
        id = 9484,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "shackle_undead",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "shackle_undead" )
        end,
    },

    shadow_word_death = {
        id = 32379,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 250,
        spendType = "mana",

        talent = "shadow_word_death",
        startsCombat = true,

        handler = function ()
        end,
    },

    shadow_word_pain = {
        id = 589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = 136207,

        handler = function ()
            applyDebuff( "target", "shadow_word_pain" )
        end,
    },

    smite = {
        id = 585,
        cast = 1.35,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "mana",

        startsCombat = true,

        cycle = "holy_fire",
        cycle_to = true,

        handler = function ()
            reduceCooldown( "holy_word_chastise", 4 * naaruMulti * ( buff.apotheosis.up and 3 or 1 ) )
            if talent.manipulation.enabled then
                reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank )
            end
        end,
    },

    symbol_of_hope = {
        id = 64901,
        channeled = true,
        cast = 4,
        cooldown = 180,
        gcd = "spell",

        talent = "symbol_of_hope",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "symbol_of_hope_buff" )
        end,
    },

    thoughtsteal = {
        id = 316262,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "thoughtsteal",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    vampiric_embrace = {
        id = 15286,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "vampiric_embrace",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "vampiric_embrace" )
        end,
    },

    void_shift = {
        id = 108968,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        talent = "void_shift",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
        end,
    },

    void_tendrils = {
        id = 108920,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "void_tendrils",
        startsCombat = true,

        toggle = "defensives",

        handler = function ()
            applyDebuff( "target", "void_tendrils" )
        end,
    },
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )


spec:RegisterSetting( "sw_death_protection", 50, {
    name = "|T136149:0|t Shadow Word: Death Health Threshold",
    desc = "If set above 0, the addon will not recommend |T136149:0|t Shadow Word: Death while your health percentage is below this threshold.  This setting can help keep you from killing yourself.",
    type = "range",
    min = 0,
    max = 100,
    step = 0.1,
    width = "full",
} )


spec:RegisterRanges( "smite", "dispel_magic" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    potion = "tempered_potion",

    package = "Holy Priest",

    strict = false
} )


spec:RegisterPack( "Holy Priest", 20240828, [[Hekili:TVvBZTTns4FlE6mosTk6SDCsC6eLzAt6Dn5UPnZPEt(MKGjHSWzkcEKGwX34H)2VDxaqcscsrL62R1J)sScbWI999blbxC6IFzX8qMIV4No7KZo)Klo7IPN(ItE(zNTyU62e(I5jSGRzxb)iMTf(3FugDBXQpMk4zkCWBJKSqKizY80ayclMFzUis9(4fx6NYNcZnHhap(5VCX8nIWqUEU8SaG(CwepTyvsQqMkuW2uSILYlw9Upo)PRLb5z8WIvYyGl(qXhqk)0tU4PNDX3wS6FLbtlqkJcL7IXLfOeY4IvrImv1KF5tF2jWK)LnWK)ed2PpjuBeXGSKkxlIajqVUSPjP8a52lzQVz2FjrUJNUCNmnC5AzQsOYd5innZfMralkAP()Ue3XjO(Awf78HVQy13fTJDlWz5iN(J)1IvI1fR2b)Ed7g4F5BtUnfK)IvxgX(VWdgfkvWJ)SIhNb0Dmi4P4Kt3kJfYCugtsyPmf(ZrbGIjLhMt8GzU4giupbgogjvqEAkpwHMqLi4Ar8vtlw9ZQn80DIm(eJIvZF72WJrcUoLNTHDze8iLeyn4Vz5Ofbz8R4avvOUmsgFf4tuSkmhyisXNiZYeWcH949epa6p1gKH0KkGHZNFdUp6DJOKILsKDNicufHcCdLi9UKzm(fR(35z2nwedUjOsBds3q2wWBf2XpbdXIYGTjug)eKCS4A7Ry7wEOaCqrjwgh4ZaiqJvIL7qbM8fbpJKeq5HC3nIyojzHUEdBGWKLRfP8jb3geXxQLPSzNorSE2if4JhRMA3UL0UD3DMhxzFxwAEV7UJmgS7UZXKm(4JgDz(61ni108KJhzD9MQ5rY5fg4U7Ofu)HJpUC2eNto6bBa9e4wGJtUVVtRi1QV5F6B)izSj9alrcgdzgQWq)oREzn7gzkeUvslpggsdzn7zOhwaJ8ar7PitB80EoKb)V923LbUQzcYMnFRqb)jeeEyTzrIR2q(3BLOLs7oGlKbgqgWq5OtfY8tDTxG6eKETCNWeXKzYrrxP)hF8inNovj2cgw5sWd9nZGi1PnjYuBOayMCv6KsXv9AgUsjcpJ04FeC0ipo0Tf8n49OA3FYiVB)s0zgfxJ3NJJXXwhYwUeh3J4GEreZ)dA(9Dg(9VItdsOivM0d7eOjTtXzfUhu4NJGLMhpu5cN2n8jzQurGsh41RrG45)zECdwc(dKhINM1M11mOwEpewutWFt0514FH23VlnUzy9gYdhQmqlRMATUuOjlYmLfwW6eXCybomZ(2n7kQkY6x2j)xGi3WsfyKQE1L5d5FMhSeJuNitMLXvtUHfLZNDcXGvbCvZdCbNROChBK70L1Gc3oP30LLuSRTHLWkZv8Vi20hdyyuX6jbY4qbstRgUA6gXqVLUjomCJMs0KwYJYScmbrYnxnkauX23wf2ba(SahY0vBTfhG1ghwfr)jSONrFGWcWkLyLAts(amLlLi3v9n6STc45V9DJ17oKHT((VgJ5aqbPyzz0dQ5go6ulfMoqLUJEdZR3xTUu(wiZD2B8w90m44okUAg(1ZgzTYtB7h(nLJ5Z4p2uPTMaRbLzXksQ1SBJdSXZvQoY6mcNOnOguY)qjOMVNa1mmvMJCH6S(HhC8OJ6asJFWjAHuFucc5KtwF0NaYTC1vdQwx)crBMfLf)86XEGfvcjZ3uBiv6uW7JX0fLqwJfjrMbokeuQ2G9zk(03m7SbtfZWzW6BtmNbjA(v0PEWmBAqSm4Cmb5r4zGUeeKRtKIymIhp0JiMYsJX)G3u6gwsMm8wJhgTn1aSDReF(UnIGnyEt0UglVHHdXWzqHZ4XSGCPy6ihp5q5GLwYCI0LIIBO5SJbIQ2(yz6PGci463m70lgF3DDVQN5FvVQ3fDU)fDoSOoxZZhS8cP5cVcktKn4v4IafqeR2OlptWv3a(QQnttcuV(StgmfBhcrosy(DNduPrWNPHIJpjuSEnhpQPJBc(8miYKfA9rWdiHEa4Oyk9V7N)bexVkx78nbXTxvYvd3QY7cprPbF)qLgId9DKSUDMomA3zganMVVWa)Yf)qoEVsd9GomVum3x0D5epGG6VQjYRG6WQShhMLzr2I)cTn6qmDFOCbiYUHjI0D)5s(AcxmDi8y(Nv1B)XedCnnGFNgjHhJx3afHYfUOgOjcAKz7LtgOpWwtT1WJU0FFQj)f7RqQ5as2cuRxqEGdrFOESNThWULWdaOwVEwVKBFSFxPpOJt1cdRUFbXz7G47qaUd7w4eQegKJpYhBNXIbYU(wcuJVXXK1cvNJ7a2tdElc5nSJJqc9B4uEKu(tXwdrb929ZMbXqEysy)zGNUJD7eSeIz(ypDOU0G9dsMhfAorb1WpSWrsQmO1rxlB237XEhYjAnX6kTJJNRilb775LSig1TOl5k454bzcdPn20Mix6s1D0iqB0BRjgXPumTXte3VJzkYfv2uudFUovUfseYOSLqelT2noWFbFiQuOneZrv2L)qBB7eJnz2RgYImwKdArDc)UCQhuXn7QEywvRM67by5mR81DDm7moGcyDrHMjhnDhQBaQWHldR34b8yXvLdB31cFeVEs3H03GrxfeoDl7ZF9Zg7LBhwas1cEGfB0WU9qkSOs08erun4xqWGZIBghu((flP8AbhSuORWCQhrF897Vt72wlPKYR7c0L7oPFBOI4154RLKmGh1Uv2UaOCreLNSV32KgIXptqiHiqb2dsrJUEr8a(ynt0fJQmmizARZ32E(VHsvav8JVU8CQ63akTrGc0lTHPSeSgBZ6M8lMdrf4VnVd8x(StwmFhlngctYwm)x0qesKPkd(8NuUbpbbb8FYbuby4OKaeNRKBzyN6rth(2wNw8H)bzQodmNVvgd7gn8tABmEIwU8mYuEmIVhNXOt)m2t1Ip4HZc5Rz5rQ7f(QERZAWAn6RwlURxk77DN2G((Msx7Y53R61EPz7iHM8D7qLo2Hx8Bax3bnVh56x2lxtib8Z20qd1l29Sx1Ax89IJDfEHgSQ7BO5GClUhcvE(FQOCXhEpzXqcErrTlXdQ(xmN(fDTLAFoA4X)eDLMmKDX3VyEqkKLovWORDudqxfREZmWyAVZplMJpCHcsxpqI4GaRfTCgdj5ZAqYYT0IMqFfOsfj6N)hsKCUAIrgQ3gxKrvuS6yDxBBGPsp8PG1DCXQ7Udm97HspRFk9QbtOZ7NqNxsOEPYZrZ55O50Adlr85AHHj98oDJAH4Ry1Rbv2jv0SfqrKGVOpNOAPzB4n9GTTGn8i7PDFKgUVE056gDqT(dO8S9sA089sxNgcmFDhgvzwdQOw)PZ6UhGKx(rDjho9culU93pWoNJdIDu8kLRknVVmPT9yT8tdp2h7W4VpDySutVy(R2BDQAohnxzTuI(YinWCJhqD6M5dVhQt)YhRt)qQo9fdPo9RUVRtF6jditV(e1(sYBxyZ7XPg97s9vXVSxb7nnl(E2H57(AVX9SUpsV4Z1A7bCcA9epQWE)Y1))A3I8XoLN8F)GOjmQJkQ2ksEUVowApGIv1cHF8E5)q(E53xrTMxz7gogpWUX7nI4R5d1mSDSni0Kb052URZU27nE3jkV)lDT7KQD)3lbu4y1QzBoK7gFFzuDZ13v3Wi2CVD0QQOLFXftjvldE3DJYhaPAs)91LRVsZ04wydXg0v8UrHIETMdq4WD4gUpOB1eVVW7HFpsZFumZMgv5bOz3kGd7I8FOM0E6MQpXqFYulYQU4)(U7)9WGoBNzzASsLFlELOLSKW3xMxxhQ2xGMh0xsWroJRQ2d7v2g)vuo8NtONzy023XBFaYmevS2JQVD3HBOnVp)qfCzDF0TtXM(qcmYoPf0ZRRV(G(k760IG6c6dTpqHU6oLNSlLDk6n7Tvs9IpUQBxZOj1Z3IqXQVXzCFod0Mn2xT4gNEw3kU6GNQPuUx)igCvR7dSVwvD0GoGtxhhzSV6X91PJAkIFfFOdUc6(fHJ74uroNDBFl1Zx1GofQnDCZ8V7TppDDY0oZbC4xDNH6o4gIb(eMRQtXQVMADXyFzS(I6kvZyL7HUs1RZ3JDL6pBDL6fdPRunbi(RURuxS)Msv1uPMb6ixEjpoeaVoSa86xhMg(N3hxoPgUtv5h9cTV5l2PzsYH03OossujXQ2s6bDnMADuR23POEQfxELKAWcB23nCAqBBN4OnNP7X39(Jzp)9j75)hF37dg2txVgjtA3(AgF)wwpVy))48L4nSQm4rRZvBKqLK)olbcTIf0tx8)o]] )