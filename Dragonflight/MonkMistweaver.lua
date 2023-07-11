-- MonkMistweaver.lua
-- DF Pre-Patch Nov 2022

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 270 )

spec:RegisterResource( Enum.PowerType.Mana )

spec:RegisterTalents( {
    -- Monk Talents
    bounce_back                   = { 80717, 389577, 2 }, -- When a hit deals more than $m2% of your maximum health, reduce all damage you take by $s1% for $390239d.; This effect cannot occur more than once every $m3  seconds.
    calming_presence              = { 80693, 388664, 1 }, -- Reduces all damage taken by $s1%.
    celerity                      = { 80685, 115173, 1 }, -- Reduces the cooldown of Roll by ${$m1/-1000} sec and increases its maximum number of charges by $m2.
    chi_burst                     = { 80709, 123986, 1 }, -- Hurls a torrent of Chi energy up to 40 yds forward, dealing $148135s1 Nature damage to all enemies, and $130654s1 healing to the Monk and all allies in its path. Healing reduced beyond $s1 targets.; $?c1[; Casting Chi Burst does not prevent avoiding attacks.][]$?c3[; Chi Burst generates 1 Chi per enemy target damaged, up to a maximum of $s3.][]
    chi_torpedo                   = { 80685, 115008, 1 }, -- Torpedoes you forward a long distance and increases your movement speed by $119085m1% for $119085d, stacking up to 2 times.
    chi_wave                      = { 80709, 115098, 1 }, -- A wave of Chi energy flows through friends and foes, dealing $132467s1 Nature damage or $132463s1 healing. Bounces up to $s1 times to targets within $132466a2 yards.
    close_to_heart                = { 80707, 389574, 2 }, -- You and your allies within $m2 yards have $s1% increased healing taken from all sources.
    dampen_harm                   = { 80704, 122278, 1 }, -- Reduces all damage you take by $m2% to $m3% for $d, with larger attacks being reduced by more.
    dance_of_the_wind             = { 80704, 414132, 1 }, -- Your dodge chance is increased by $s1%.
    diffuse_magic                 = { 80697, 122783, 1 }, -- Reduces magic damage you take by $m1% for $d, and transfers all currently active harmful magical effects on you back to their original caster if possible.
    disable                       = { 80679, 116095, 1 }, -- Reduces the target's movement speed by $s1% for $d, duration refreshed by your melee attacks.$?s343731[ Targets already snared will be rooted for $116706d instead.][]
    elusive_mists                 = { 80603, 388681, 2 }, -- Reduces all damage taken while channelling Soothing Mists by $s1%.
    escape_from_reality           = { 80715, 394110, 2 }, -- After you use Transcendence: Transfer, you can use Transcendence: Transfer again within $343249d, ignoring its cooldown.; During this time, if you cast Vivify on yourself, its healing is increased by $s1% and $343249m2% of its cost is refunded.
    expeditious_fortification     = { 80681, 388813, 1 }, -- Fortifying Brew cooldown reduced by ${$s1/-60000} min.
    eye_of_the_tiger              = { 80700, 196607, 1 }, -- Tiger Palm also applies Eye of the Tiger, dealing $196608o2 Nature damage to the enemy and $196608o1 healing to the Monk over $196608d. Limit 1 target.
    fast_feet                     = { 80705, 388809, 2 }, -- Rising Sun Kick deals $s1% increased damage. Spinning Crane Kick deals $s2% additional damage.;
    fatal_touch                   = { 80703, 394123, 2 }, -- Touch of Death cooldown reduced by ${$s1/-1000} sec.
    ferocity_of_xuen              = { 80706, 388674, 2 }, -- Increases all damage dealt by $s1%.
    fortifying_brew               = { 80680, 388917, 1 }, -- Turns your skin to stone for $120954d, increasing your current and maximum health by $<health>% and reducing all damage you take by $<damage>%.; Combines with other Fortifying Brew effects.
    generous_pour                 = { 80683, 389575, 2 }, -- You and your allies within $m2 yards take $s1% reduced damage from area-of-effect attacks.
    grace_of_the_crane            = { 80710, 388811, 2 }, -- Increases all healing taken by $s1%.
    hasty_provocation             = { 80696, 328670, 1 }, -- Provoked targets move towards you at $s1% increased speed.
    improved_paralysis            = { 80687, 344359, 1 }, -- Reduces the cooldown of Paralysis by ${$abs($s0/1000)} sec.
    improved_roll                 = { 80712, 328669, 1 }, -- Grants an additional charge of Roll and Chi Torpedo.
    improved_touch_of_death       = { 80684, 322113, 1 }, -- Touch of Death can now be used on targets with less than $s1% health remaining, dealing $s2% of your maximum health in damage.
    improved_vivify               = { 80692, 231602, 2 }, -- Vivify healing is increased by $s1%.
    ironshell_brew                = { 80681, 388814, 1 }, -- Increases Armor while Fortifying Brew is active by $s2%.; Increases Dodge while Fortifying Brew is active by $s1%.;
    paralysis                     = { 80688, 115078, 1 }, -- Incapacitates the target for $d. Limit 1. Damage will cancel the effect.
    profound_rebuttal             = { 80708, 392910, 1 }, -- Expel Harm's critical healing is increased by $s1%.
    resonant_fists                = { 80702, 389578, 2 }, -- Your attacks have a chance to resonate, dealing ${$@traitentryrank101520*$391400s1} Nature damage to enemies within $391400a1 yds.
    ring_of_peace                 = { 80698, 116844, 1 }, -- Form a Ring of Peace at the target location for $d. Enemies that enter will be ejected from the Ring.
    rising_sun_kick               = { 80690, 107428, 1 }, -- Kick upwards, dealing $?s137025[${$185099s1*$<CAP>/$AP}][$185099s1] Physical damage$?s128595[, and reducing the effectiveness of healing on the target for $115804d][].$?a388847[; Applies Renewing Mist for $388847s1 seconds to an ally within $388847r yds][]
    save_them_all                 = { 80714, 389579, 2 }, -- When your healing spells heal an ally whose health is below $s3% maximum health, you gain an additional $s1% healing for the next $390105d.
    song_of_chiji                 = { 80698, 198898, 1 }, -- Conjures a cloud of hypnotic mist that slowly travels forward. Enemies touched by the mist fall asleep, Disoriented for $198909d.
    soothing_mist                 = { 80691, 115175, 1 }, -- Heals the target for $o1 over $d. While channeling, Enveloping Mist$?s227344[, Surging Mist,][]$?s124081[, Zen Pulse,][] and Vivify may be cast instantly on the target.$?s117907[; Each heal has a chance to cause a Gust of Mists on the target.][]$?s388477[; Soothing Mist heals a second injured ally within $388478A2 yds for $388477s1% of the amount healed.][]
    spear_hand_strike             = { 80686, 116705, 1 }, -- Jabs the target in the throat, interrupting spellcasting and preventing any spell from that school of magic from being cast for $d.
    strength_of_spirit            = { 80682, 387276, 1 }, -- Expel Harm's healing is increased by up to $s1%, based on your missing health.
    summon_black_ox_statue        = { 80716, 115315, 1 }, -- Summons a Black Ox Statue at the target location for $d, pulsing threat to all enemies within $163178A1 yards.; You may cast Provoke on the statue to taunt all enemies near the statue.
    summon_jade_serpent_statue    = { 80713, 115313, 1 }, -- Summons a Jade Serpent Statue at the target location. When you channel Soothing Mist, the statue will also begin to channel Soothing Mist on your target, healing for $198533o1 over $198533d.
    summon_white_tiger_statue     = { 80701, 388686, 1 }, -- Summons a White Tiger Statue at the target location for $d, pulsing $389541s1 damage to all enemies every 2 sec for $d.
    tiger_tail_sweep              = { 80604, 264348, 2 }, -- Increases the range of Leg Sweep by $s1 yds and reduces its cooldown by ${$s2/-1000} sec.
    tigers_lust                   = { 80689, 116841, 1 }, -- Increases a friendly target's movement speed by $s1% for $d and removes all roots and snares.
    transcendence                 = { 80694, 101643, 1 }, -- Split your body and spirit, leaving your spirit behind for $d. Use Transcendence: Transfer to swap locations with your spirit.
    vigorous_expulsion            = { 80711, 392900, 1 }, -- Expel Harm's healing increased by $s1% and critical strike chance increased by $s2%.
    vivacious_vivification        = { 80695, 388812, 1 }, -- Every $t1 sec, your next Vivify becomes instant.
    windwalking                   = { 80699, 157411, 2 }, -- You and your allies within $m2 yards have $s1% increased movement speed.
    yulons_grace                  = { 80697, 414131, 1 }, -- Find resilience in the flow of chi in battle, gaining a magic absorb shield for ${$s1/10}.1% of your max health every $t sec in combat, stacking up to $s2%.

    -- Mistweaver Talents
    accumulating_mist             = { 80564, 388564, 1 }, -- Zen Pulse's damage and healing is increased by $388566s1% each time Soothing Mist heals, up to $388566u times. ; When your Soothing Mist channel ends, this effect is canceled.
    ancient_concordance           = { 80569, 388740, 2 }, -- Your Blackout Kicks strike ${$s2+1} targets and have an additional $s1% chance to reset the cooldown of your Rising Sun Kick while within your Faeline Stomp.
    ancient_teachings             = { 80598, 388023, 1 }, -- After casting Essence Font or Faeline Stomp, your Tiger Palm, Blackout Kick, and Rising Sun Kick heal up to $s2 injured allies within $388024A1 yds for $<healing>% of the damage done, split evenly among them. Lasts $388026d.
    awakened_faeline              = { 80577, 388779, 1 }, -- Your abilities reset Faeline Stomp $s2% more often. While within Faeline Stomp, your Tiger Palms strike twice and your Spinning Crane Kick heals $s4 nearby allies for $s1% of the damage done.
    burst_of_life                 = { 80583, 399226, 1 }, -- When Life Cocoon expires, it releases a burst of mist that restores $399230s2 health to $s3 nearby allies.
    calming_coalescence           = { 80599, 388218, 1 }, -- Each time Soothing Mist heals, the absorb amount of your next Life Cocoon is increased by $s1%, stacking up to $388220u times.
    celestial_harmony             = { 80582, 343655, 1 }, -- While active, Yu'lon and Chi'Ji heal up to $s3 nearby targets with Enveloping Breath when you cast Enveloping Mist, healing for ${$325209s1*$325209d/$325209t1} over $325209d, and increasing the healing they receive from you by $325209s3%.; When activated, Yu'lon and Chi'Ji apply Chi Cocoons to $406139s3 targets within $406139r yds, absorbing $<newshield> damage for $406139d.
    chrysalis                     = { 80583, 202424, 1 }, -- Reduces the cooldown of Life Cocoon by ${$m1/-1000} sec.
    clouded_focus                 = { 80598, 388047, 1 }, -- Healing with Enveloping Mists or Vivify while channeling Soothing Mists increases their healing done by $388048m1% and reduces their mana cost by $388048m2%. Stacks up to $388048u times.; When your Soothing Mists channel ends, this effect is cancelled.
    dancing_mists                 = { 80587, 388701, 2 }, -- Renewing Mist has a $s1% chance to immediately spread to an additional target when initially cast or when traveling to a new target.
    echoing_reverberation         = { 80564, 388604, 1 }, -- Zen Pulse triggers a second time at $s1% effectiveness if cast on targets with Enveloping Mist.
    enveloping_mist               = { 80568, 124682, 1 }, -- Wraps the target in healing mists, healing for $o1 over $d, and increasing healing received from your other spells by $m2%. $?a388847[; Applies Renewing Mist for $388847s1 seconds to an ally within $388847r yds.][]
    essence_font                  = { 80597, 191837, 1 }, -- Unleashes a rapid twirl of healing bolts at up to $s1 allies within $191840A1 yds, every ${6*$t1}.1 sec for $d. Each bolt heals a target for $191840s1, plus an additional $191840o2 over $191840d.; Gust of Mists will heal affected targets twice. Castable while moving.$?a337209[; Each bolt has a chance to reduce the cooldown of Thunder Focus Tea by $337209s1 sec.][]
    faeline_stomp                 = { 80560, 388193, 1 }, -- Strike the ground fiercely to expose a faeline for $d, dealing $388207s1 Nature damage to up to 5 enemies, and restores $388207s2 health to up to 5 allies within $388207a1 yds caught in the faeline. $?a137024[Up to 5 allies]?a137025[Up to 5 enemies][Stagger is $s3% more effective for $347480d against enemies] caught in the faeline$?a137023[]?a137024[ are healed with an Essence Font bolt][ suffer an additional $388201s1 damage].; Your abilities have a $s2% chance of resetting the cooldown of Faeline Stomp while fighting on a faeline.
    focused_thunder               = { 80593, 197895, 1 }, -- Thunder Focus Tea now empowers your next ${$m1+1} spells.
    font_of_life                  = { 80580, 337209, 1 }, -- Your Essence Font's initial heal is increased by $s2% and has a chance to reduce the cooldown of Thunder Focus Tea by $s1 sec.
    gift_of_the_celestials        = { 80576, 388212, 1 }, -- Reduces the cooldown of $?s325197[Invoke Chi-Ji, the Red Crane][Invoke Yul'on, the Jade Serpent] by 2 min, but decreases its duration to 12 sec.
    healing_elixir                = { 80572, 122281, 1 }, -- Drink a healing elixir, healing you for $s1% of your maximum health.
    improved_detox                = { 81634, 388874, 1 }, -- Detox additionally removes all Poison and Disease effects.
    invigorating_mists            = { 80559, 274586, 1 }, -- Vivify heals all allies with your Renewing Mist active for $116670s2.;
    invoke_chiji_the_red_crane    = { 80590, 325197, 1 }, -- Summon an effigy of Chi-Ji for $d that kicks up a Gust of Mist when you Blackout Kick, Rising Sun Kick, or Spinning Crane Kick, healing up to $343818s3 allies for $343819s1, and reducing the cost and cast time of your next Enveloping Mist by $343820s1%, stacking.; Chi-Ji's presence makes you immune to movement impairing effects.
    invoke_yulon_the_jade_serpent = { 80590, 322118, 1 }, -- Summons an effigy of Yu'lon, the Jade Serpent for $d. Yu'lon will heal injured allies with Soothing Breath, healing the target and up to $s2 allies for $343737o1 over $343737d. ; Enveloping Mist costs $s4% less mana while Yu'lon is active.
    invokers_delight              = { 80571, 388661, 1 }, -- You gain $388663m1% haste for $?a388212[${$s2-$s3} sec][$388663d] after summoning your Celestial.
    jade_bond                     = { 80576, 388031, 1 }, -- Abilities that activate Gust of Mist reduce the cooldown on $?s325197[Invoke Chi-Ji, the Red Crane][Invoke Yul'on, the Jade Serpent] by ${$s2/-1000}.1 sec, and $?s325197[Chi-Ji's Gusts of Mists][Yu'lon's Soothing Breath] healing is increased by $s1%.
    legacy_of_wisdom              = { 92684, 404408, 1 }, -- Sheilun's Gift heals $s1 additional allies and its cast time is reduced by ${$s2/-1000}.1 sec.
    life_cocoon                   = { 80584, 116849, 1 }, -- Encases the target in a cocoon of Chi energy for $d, absorbing $<newshield> damage and increasing all healing over time received by $m2%.$?a388548[; Applies Renewing Mist and Enveloping Mist to the target.][]
    lifecycles                    = { 80575, 197915, 1 }, -- Enveloping Mist reduces the mana cost of your next Vivify by $197916s1%.; Vivify reduces the mana cost of your next Enveloping Mist by $197919s1%.
    mana_tea                      = { 80575, 197908, 1 }, -- Reduces the mana cost of your spells by $s1% for $d.
    mastery_of_mist               = { 80589, 281231, 1 }, -- Renewing Mist now has ${$s1+1} charges.
    mending_proliferation         = { 80573, 388509, 1 }, -- Each time Enveloping Mist heals, its healing bonus has a $s2% chance to spread to an injured ally within $388508a1 yds.
    mist_wrap                     = { 80563, 197900, 1 }, -- Increases Enveloping Mist's duration by ${$m2/1000} sec and its healing bonus by $s1%.
    mists_of_life                 = { 80567, 388548, 1 }, -- Life Cocoon applies Renewing Mist and Enveloping Mist to the target.
    misty_peaks                   = { 80594, 388682, 2 }, -- Renewing Mist's heal over time effect has a $s3% chance to proc Enveloping Mist for $s2 sec.
    nourishing_chi                = { 80599, 387765, 1 }, -- Life Cocoon increases healing over time received by an additional $s1%, and this effect lingers for an additional $387766d after the cocoon is removed.
    overflowing_mists             = { 80581, 388511, 2 }, -- Your Enveloping Mists heal the target for ${$s1}.1% of their maximum health each time they take damage.
    peaceful_mending              = { 80592, 388593, 2 }, -- Allies targeted by Soothing Mist receive $s1% more healing from your Enveloping Mist and Renewing Mist effects.
    rapid_diffusion               = { 80579, 388847, 2 }, -- Rising Sun Kick and Enveloping Mist apply Renewing Mist for $s1 seconds to an ally within $r yds.
    refreshing_jade_wind          = { 80563, 196725, 1 }, -- Summon a whirling tornado around you, causing ${$162530s1*$s3} healing over $d to up to $s2 allies within $162530A1 yards.
    renewing_mist                 = { 80588, 115151, 1 }, -- Surrounds the target with healing mists, restoring $119611o1 health over $119611d.; If Renewing Mist heals a target past maximum health, it will travel to another injured ally within $119607A2 yds.$?a231606[; Each time Renewing Mist heals, it has a $s2% chance to increase the healing of your next Vivify by $197206s1%.][]
    resplendent_mist              = { 80585, 388020, 2 }, -- Gust of Mists has a $s2% chance to do $s1% more healing.
    restoral                      = { 80574, 388615, 1 }, -- Heals all party and raid members within $A1 yds for $s1 and clears them of all harmful Poison and Disease effects. ; Castable while stunned.; Healing increased by $s4% when not in a raid.
    revival                       = { 80574, 115310, 1 }, -- Heals all party and raid members within $A1 yds for $s1 and clears them of all harmful Magical, Poison, and Disease effects.; Healing increased by $s5% when not in a raid.
    rising_mist                   = { 80558, 274909, 1 }, -- Rising Sun Kick heals all allies with your Renewing Mist, Enveloping Mist, or Essence Font for $274912s1, and extends those effects by $s1 sec, up to $s2% of their original duration.
    secret_infusion               = { 80570, 388491, 2 }, -- After using Thunder Focus Tea, your next spell gives $s1% of a stat for $388497d:; $@spellname124682: Critical strike; $@spellname115151: Haste; $@spellname116670: Mastery; $@spellname107428: Versatility; $@spellname191837: Haste
    shaohaos_lessons              = { 80596, 400089, 1 }, -- Each time you cast Sheilun's Gift, you learn one of Shaohao's Lessons for up to $s1 sec, with the duration based on how many clouds of mist are consumed.; Lesson of Doubt: Your spells and abilities deal up to $400097s1% more healing and damage to targets, based on their current health.; Lesson of Despair: Your Critical Strike is increased by $400100s1% while above $400100s2% health.; Lesson of Fear: Decreases your damage taken by $400103s1% and increases your Haste by $400103s2%.; Lesson of Anger: $400106s1% of the damage or healing you deal is duplicated every $400106s2 sec.
    sheiluns_gift                 = { 80586, 399491, 1 }, -- Draws in all nearby clouds of mist, healing the friendly target and up to ${$s2-1} nearby allies for $s1 per cloud absorbed.; A cloud of mist is generated every $?a400053[$400053s2][$s3] sec while in combat.
    spirit_of_the_crane           = { 80562, 210802, 1 }, -- Teachings of the Monastery causes each additional Blackout Kick to restore ${$210803m1/100}.2% mana.
    tea_of_plenty                 = { 80565, 388517, 1 }, -- Thunder Focus Tea also empowers $s1 additional Renewing Mist, Essence Font, or Rising Sun Kick at random.
    tea_of_serenity               = { 80565, 393460, 1 }, -- Thunder Focus Tea also empowers $s1 additional Renewing Mist, Enveloping Mist, or Vivify at random.
    teachings_of_the_monastery    = { 80595, 116645, 1 }, -- Tiger Palm causes your next Blackout Kick to strike an additional time, stacking up to $202090u.; Blackout Kick has a $s1% chance to reset the remaining cooldown on Rising Sun Kick.; $?a210802[Each additional Blackout Kick restores ${$210803m1/100}.2% mana.][]
    tear_of_morning               = { 80558, 387991, 1 }, -- Casting Vivify or Enveloping Mist on a target with Renewing Mist has a $s3% chance to spread the Renewing Mist to another target.; Your Vivify healing through Renewing Mist is increased by $s1% and your Enveloping Mist also heals allies with Renewing Mist for $s2% of its healing.
    thunder_focus_tea             = { 80600, 116680, 1 }, -- Receive a jolt of energy, empowering your next $?a197895[$u spells][spell] cast:; $@spellname124682: Immediately heals for $274062s1 and is instant cast.; $@spellname115151: Duration increased by ${$s3/1000} sec.; $@spellname116670: No mana cost.; $@spellname107428: Cooldown reduced by ${$s1/-1000} sec.; $@spellname353937: Channels ${$s4*-2}% faster. $?s353936[; $@spellname117952: Knockback applied immediately.; $@spellname109132: Refund a charge and heal yourself for $407058s1.][]
    unison                        = { 80573, 388477, 1 }, -- Soothing Mist heals a second injured ally within $388478A2 yds for $s1% of the amount healed.
    uplifted_spirits              = { 80591, 388551, 1 }, -- Vivify critical strikes and Rising Sun Kicks reduce the remaining cooldown on $?s388615[Restoral][Revival] by ${$s2/1000} sec, and $?s388615[Restoral][Revival] heals targets for $s1% of $?s388615[Restoral's][Revival's] heal over $388555d.
    upwelling                     = { 80593, 274963, 1 }, -- For every $s1 sec Essence Font spends off cooldown, your next Essence Font may be channeled for 1 additional second.; The duration of Essence Font's heal over time is increased by ${$s2/1000} sec.
    veil_of_pride                 = { 80596, 400053, 1 }, -- Increases Sheilun's Gift cloud of mist generation to every ${-$s1/1000} sec.
    yulons_whisper                = { 80578, 388038, 1 }, -- Activating Thunder Focus Tea causes you to exhale the breath of Yu'lon, healing up to $s1 allies within $388044a1 yards for ${$388044s1*($388040d/$388040t1+1)} over $388040d.
    zen_pulse                     = { 80566, 124081, 1 }, -- Trigger a Zen Pulse around an ally.  Deals $405426s2 damage to all enemies within $405426A2 yds of the target. The ally is healed for $198487s1 per enemy damaged.$?a388604[; Zen Pulse triggers a second time at $388604s1% effectiveness if cast on targets with Enveloping Mist.][]
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    alpha_tiger          = 5551, -- (287503) Attacking new challengers with Tiger Palm fills you with the spirit of Xuen, granting you $287504m1% haste for $287504d. ; This effect cannot occur more than once every $290512d per target.
    counteract_magic     = 679, -- (353502) Removing hostile magic effects from a target increases the healing they receive from you by $353503s1% for $353503d, stacking up to $353503u times.
    dematerialize        = 5398, -- (353361) [357819] Demateralize into mist while stunned, reducing damage taken by $353362s1%. Each second you remain stunned reduces this bonus by 10%.
    dome_of_mist         = 680, -- (202577) Enveloping Mist transforms $s1% of its remaining periodic healing into a Dome of Mist when dispelled.; $@spellicon205655 $@spellname205655; Absorbs damage. All healing received by the Monk increased by $205655m2%. Lasts $205655d.
    eminence             = 70, -- (353584) Transcendence: Transfer can now be cast if you are stunned.  Cooldown reduced by ${($m1/1000)*-1)} sec if you are not.
    fae_accord           = 5565, -- (406888) Faeline Stomp's cooldown is reduced by ${$s2/-1000} sec.; Enemies struck by Faeline Stomp are snared by $406896s1% for $406896d.
    grapple_weapon       = 3732, -- (233759) You fire off a rope spear, grappling the target's weapons and shield, returning them to you for $d.
    healing_sphere       = 683, -- (205234) Coalesces a Healing Sphere out of the mists at the target location after 1.5 sec.  If allies walk through it, they consume the sphere, healing themselves for $115464s1 and dispelling all harmful periodic magic effects.; Maximum of $m1 Healing Spheres can be active by the Monk at any given time.
    mighty_ox_kick       = 5539, -- (202370) You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    peaceweaver          = 5395, -- (353313) $?s388615[Restoral's][Revival's] cooldown is reduced by $s2%, and provides immunity to magical damage and harmful effects for $353319d.
    refreshing_breeze    = 682, -- (353508) During Soothing Mist's channel, Expel Harm's healing is increased by $353509s1%, and dispels 1 Magic, Disease, and Poison effect from the target. Stacks each time Soothing Mist heals the target.
    thunderous_focus_tea = 5402, -- (353936) Thunder Focus Tea can now additionally cause Crackling Jade Lightning's knockback immediately or cause Roll and Chi Torpedo to refund a charge on use and heal you for $407058s1.
    zen_focus_tea        = 1928, -- (209584) Provides immunity to Silence and Interrupt effects for $d.
    zen_spheres          = 5603, -- (410777) Forms a sphere of Hope or Despair above the target. Only one of each sphere can be active at a time.; $@spellicon411036 $@spellname411036: Increases your healing done to the target by $411036s1%.; $@spellicon411038 $@spellname411038: Target deals $411038s1% less damage to you, and takes $411038s2% increased damage from all sources.;
} )


-- Auras
spec:RegisterAuras( {
    accumulating_mist = {
        id = 388566,
        duration = 30,
        max_stack = 6
    },
    ancient_concordance = {
        id = 389391,
        duration = 3600,
        max_stack = 1
    },
    ancient_teachings = {
        id = 388026,
        duration = 15,
        max_stack = 1
    },
    awakened_faeline = {
        id = 389387,
        duration = 3600,
        max_stack = 1
    },
    bonedust_brew = {
        id = 386276,
        duration = 10,
        max_stack = 1
    },
    bounce_back = {
        id = 390239,
        duration = 4,
        max_stack = 1
    },
    chi_burst = { -- TODO: Hidden aura that procs Chi per enemy targeted.
        id = 123986,
        duration = 1,
        max_stack = 1
    },
    chi_torpedo = { -- Movement buff.
        id = 119085,
        duration = 10,
        max_stack = 2
    },
    close_to_heart = {
        id = 389684,
        duration = 3600,
        max_stack = 1,
        copy = 389574
    },
    clouded_focus = {
        id = 388048,
        duration = 8,
        max_stack = 3
    },
    crackling_jade_lightning = {
        id = 117952,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    dampen_harm = {
        id = 122278,
        duration = 10,
        max_stack = 1
    },
    diffuse_magic = {
        id = 122783,
        duration = 6,
        max_stack = 1
    },
    disable = {
        id = 116095,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    enveloping_mist = {
        id = 124682,
        duration = 6,
        tick_time = 1,
        max_stack = 1
    },
    essence_font = {
        id = 344006,
        duration = 8,
        tick_time = 2,
        max_stack = 1,
        copy = 191840
    },
    eye_of_the_tiger = {
        id = 196608,
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    fae_exposure_buff = {
        id = 356774,
        duration = 10,
        max_stack = 1,
        friendly = true
    },
    fae_exposure_debuff = {
        id = 356773,
        duration = 10,
        max_stack = 1
    },
    faeline_stomp = {
        id = 388193,
        duration = 30,
        max_stack = 1
    },
    fatal_touch = {
        id = 337296,
        duration = 3600,
        max_stack = 1
    },
    generous_pour = {
        id = 389685,
        duration = 3600,
        max_stack = 1
    },
    grapple_weapon = {
        id = 233759,
        duration = 6,
        max_stack = 1
    },
    invoke_chiji_the_red_crane = { -- This is not the presence of the totem, but the buff stacks gained while totem is up.
        id = 343820,
        duration = 20,
        max_stack = 3,
        copy = { "invoke_chiji", "chiji_the_red_crane", "chiji" }
    },
    invoke_yulon_the_jade_serpent = { -- Misleading; use pet.yulon.up or totem.yulon.up instead.
        id = 322118,
        duration = 25,
        tick_time = 1,
        max_stack = 1,
        copy = { "invoke_yulon", "yulon_the_jade_serpent", "yulon" }
    },
    invokers_delight = {
        id = 388663,
        duration = 20,
        max_stack = 1
    },
    leg_sweep = {
        id = 119381,
        duration = 3,
        max_stack = 1
    },
    life_cocoon = {
        id = 116849,
        duration = 12,
        max_stack = 1
    },
    mana_tea = {
        id = 197908,
        duration = 10,
        max_stack = 1
    },
    mastery_gust_of_mists = {
        id = 117907,
    },
    mystic_touch = {
        id = 8647,
    },
    overflowing_mists = {
        id = 388513,
        duration = 6,
        max_stack = 1
    },
    paralysis = {
        id = 115078,
        duration = 60,
        max_stack = 1
    },
    profound_rebuttal = {
        id = 392910,
    },
    refreshing_jade_wind = {
        id = 196725,
        duration = 9,
        tick_time = 0.75,
        max_stack = 1
    },
    ring_of_peace = {
        id = 116844,
        duration = 5,
        max_stack = 1
    },
    save_them_all = {
        id = 389579,
    },
    secret_infusion = {
        alias = { "secret_infusion_critical_strike", "secret_infusion_haste", "secret_infusion_mastery", "secret_infusion_versatility" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 10,
    },
    secret_infusion_critical_strike = {
        id = 388498,
        duration = 10,
        max_stack = 1,
        copy = "secret_infusion_crit"
    },
    secret_infusion_haste = {
        id = 388497,
        duration = 10,
        max_stack = 1
    },
    secret_infusion_mastery = {
        id = 388499,
        duration = 10,
        max_stack = 1
    },
    secret_infusion_versatility = {
        id = 388500,
        duration = 10,
        max_stack = 1
    },
    shaohaos_lesson_anger = {
        id = 405807,
        duration = 3600,
        max_stack = 1
    },
    shaohaos_lesson_despair = {
        id = 405810,
        duration = 3600,
        max_stack = 1
    },
    shaohaos_lesson_doubt = {
        id = 405808,
        duration = 3600,
        max_stack = 1
    },
    shaohaos_lesson_fear = {
        id = 405809,
        duration = 3600,
        max_stack = 1
    },
    lesson_of_anger = {
        id = 400106,
        duration = function() return 3 * gust_of_mist.count end,
        max_stack = 1
    },
    lesson_of_despair = {
        id = 400100,
        duration = function() return 3 * gust_of_mist.count end,
        max_stack = 1
    },
    lesson_of_doubt = {
        id = 400097,
        duration = function() return 3 * gust_of_mist.count end,
        max_stack = 1
    },
    lesson_of_fear = {
        id = 400103,
        duration = function() return 3 * gust_of_mist.count end,
        max_stack = 1
    },
    song_of_chiji = {
        id = 198909,
        duration = 20,
        max_stack = 1
    },
    soothing_breath = { -- Applied by Yu'lon while active.
        id = 343737,
        duration = 25,
        max_stack = 1,
    },
    soothing_mist = {
        id = 115175,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    spinning_crane_kick = {
        id = 101546,
        duration = 1.5,
        tick_time = 0.5,
        max_stack = 1
    },
    strength_of_spirit = {
        id = 387276,
    },
    summon_black_ox_statue = { -- TODO: Is a totem.
        id = 115315,
        duration = 900,
        max_stack = 1
    },
    summon_jade_serpent_statue = { -- TODO: Is a totem.
        id = 115313,
        duration = 900,
        max_stack = 1
    },
    summon_white_tiger_statue = { -- TODO: Is a totem.
        id = 388686,
        duration = 30,
        max_stack = 1
    },
    teachings_of_the_monastery = {
        id = 202090,
        duration = 10,
        max_stack = 3
    },
    thunder_focus_tea = {
        id = 116680,
        duration = 30,
        max_stack = 1,
        onRemove = function()
            setCooldown( "thunder_focus_tea", 30 )
        end,
    },
    tigers_lust = {
        id = 116841,
        duration = 6,
        max_stack = 1
    },
    transcendence = {
        id = 101643,
        duration = 900,
        max_stack = 1
    },
    transcendence_transfer = {
        id = 119996,
    },
    vigorous_expulsion = {
        id = 392900,
    },
    vivacious_vivification = {
        id = 392883,
        duration = 3600,
        max_stack = 1
    },
    yulons_whisper = { -- TODO: If needed, this would be triggered by TFT cast.
        id = 388040,
        duration = 2,
        tick_time = 1,
        max_stack = 1
    },
    zen_flight = {
        id = 125883,
        duration = 3600,
        max_stack = 1
    },
    zen_focus_tea = {
        id = 209584,
        duration = 5,
        max_stack = 1
    },
    zen_pilgrimage = {
        id = 126892,
    },
} )


-- Tier 30
spec:RegisterGear( "tier30", 202509, 202507, 202506, 202505, 202504 )
spec:RegisterAuras( {
    soulfang_infusion = {
        id = 410007,
        duration = 3,
        max_stack = 1
    },
    soulfang_vitality = {
        id = 410082,
        duration = 6,
        max_stack = 1
    }
} )


spec:RegisterTotem( "chiji", 877514 )
spec:RegisterTotem( "yulon", 574571 )

spec:RegisterStateTable( "gust_of_mist", setmetatable( {}, {
    __index = function( t,  k)
        if k == "count" then
            t[ k ] = GetSpellCount( action.sheiluns_gift.id )
            return t[ k ]
        end
    end
} ) )

spec:RegisterHook( "reset_precast", function()
    gust_of_mist.count = nil
end )


-- Abilities
spec:RegisterAbilities( {
    -- Strike with a blast of Chi energy, dealing 1,429 Physical damage and granting Shuffle for 3 sec.
    blackout_kick = {
        id = 100784,
        cast = 0,
        cooldown = 3,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            removeBuff( "teachings_of_the_monastery" )
            if pet.chiji.up then
                addStack( "invoke_chiji" )
                gust_of_mist.count = min( 10, gust_of_mist.count + 1 )
            end
        end,
    },

    enveloping_mist = {
        id = 124682,
        cast = function()
            if buff.invoke_chiji.stack == 3 or buff.thunder_focus_tea.up then return 0 end
            return 2 * ( 1 - 0.333 * buff.invoke_chiji.stack ) * haste
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            return pet.yulon.up and 0.12 or 0.24
        end,
        spendType = "mana",

        startsCombat = false,
        texture = 775461,

        handler = function ()
            if buff.thunder_focus_tea.up then removeBuff( "thunder_focus_tea" )
            else removeBuff( "invoke_chiji" ) end
            gust_of_mist.count = 0

            applyBuff( "enveloping_mist" )
            if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_versatility" ) end
        end,
    },

    essence_font = {
        id = 191837,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.36,
        spendType = "mana",

        startsCombat = false,
        texture = 1360978,

        handler = function ()
            applyBuff( "essence_font" )
            if talent.ancient_teachings.enabled then applyBuff( "ancient_teachings" ) end
            if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_haste" ) end
        end,
    },

    expel_harm = {
        id = 322101,
        cast = 0,
        cooldown = 15,
        gcd = "totem",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 627486,

        handler = function ()
        end,
    },

    invoke_chiji_the_red_crane = {
        id = 325197,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.25,
        spendType = "mana",

        startsCombat = false,
        texture = 877514,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "chiji", nil, 25 )
        end,

        copy = "invoke_chiji"
    },

    invoke_yulon_the_jade_serpent = {
        id = 322118,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.25,
        spendType = "mana",

        startsCombat = false,
        texture = 574571,

        toggle = "cooldowns",

        handler = function ()
            summonTotem( "yulon", nil, 25 )
        end,

        copy = "invoke_yulon"
    },

    life_cocoon = {
        id = 116849,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = 0.12,
        spendType = "mana",

        startsCombat = false,
        texture = 627485,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "life_cocoon" )
        end,
    },

    mana_tea = {
        id = 197908,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        startsCombat = false,
        texture = 608949,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "mana_tea" )
            if set_bonus.tier30_4pc > 0 then applyBuff( "soulfang_vitality" ) end
        end,
    },

    -- You perform a Mighty Ox Kick, hurling your enemy a distance behind you.
    mighty_ox_kick = {
        id = 202370,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        pvptalent = "mighty_ox_kick",
        startsCombat = false,
        texture = 1381297,

        handler = function ()
        end,
    },

    reawaken = {
        id = 212051,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 1056569,

        handler = function ()
        end,
    },

    refreshing_jade_wind = {
        id = 196725,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.25,
        spendType = "mana",

        startsCombat = false,
        texture = 606549,

        handler = function ()
        end,
    },

    renewing_mist = {
        id = 115151,
        cast = 0,
        charges = 2,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        startsCombat = false,
        texture = 627487,

        handler = function ()
            applyBuff( "renewing_mist" )
            if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_haste" ) end
        end,
    },

    restoral = {
        id = 388615,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "spell",

        spend = 0.2187,
        spendType = "mana",

        startsCombat = false,
        texture = 1381300,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    resuscitate = {
        id = 115178,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 132132,

        handler = function ()
        end,
    },

    revival = {
        id = 115310,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "spell",

        spend = 0.2187,
        spendType = "mana",

        startsCombat = false,
        texture = 1020466,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    -- Talent: Kick upwards, dealing 3,359 Physical damage.
    rising_sun_kick = {
        id = 107428,
        cast = 0,
        cooldown = function() return ( buff.thunder_focus_tea.up and 3 or 12 ) * haste end,
        gcd = "spell",
        school = "physical",

        talent = "rising_sun_kick",
        startsCombat = true,

        handler = function ()
            if state.spec.mistweaver then
                if talent.rapid_diffusion.enabled then
                    if solo then applyBuff( "renewing_mist", 3 * talent.rapid_diffusion.rank )
                    else active_dot.renewing_mist = max( group_members, active_dot.renewing_mist + 1 ) end
                end
                if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_versatility" ) end
                if pet.chiji.up then
                    addStack( "invoke_chiji" )
                    gust_of_mist.count = min( 10, gust_of_mist.count + 1 )
                end
                removeStack( "thunder_focus_tea" )
            end
        end,
    },

    -- Draws in all nearby clouds of mist, healing up to 3 nearby allies for 1,220 per cloud absorbed. A cloud of mist is generated every 8 sec while in combat.
    sheiluns_gift = {
        id = 399491,
        cast = function() return ( talent.legacy_of_wisdom.enabled and 1.5 or 2 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "sheiluns_gift",
        startsCombat = false,
        texture = 1242282,

        usable = function()
            return gust_of_mist.count > 0, "requires mists"
        end,

        handler = function ()
            if buff.shaohaos_lesson_anger.up then
                applyBuff( "lesson_of_anger" )
                removeBuff( "shaohaos_lesson_anger" )
            elseif buff.shaohaos_lesson_despair.up then
                applyBuff( "lesson_of_despair" )
                removeBuff( "shaohaos_lesson_despair" )
            elseif buff.shaohaos_lesson_doubt.up then
                applyBuff( "lesson_of_doubt" )
                removeBuff( "shaohaos_lesson_doubt" )
            elseif buff.shaohaos_lesson_fear.up then
                applyBuff( "lesson_of_fear" )
                stat.haste = stat.haste + 0.2
                removeBuff( "shaohaos_lesson_fear" )
            end
            gust_of_mist.count = 0
        end,
    },

    song_of_chiji = {
        id = 198898,
        cast = 1.8,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 332402,

        handler = function ()
            applyDebuff( "target", "song_of_chiji" )
        end,
    },

    soothing_mist = {
        id = 115175,
        cast = 8,
        channeled = true,
        cooldown = 0,
        gcd = "totem",

        spend = 0.16,
        spendType = "mana",

        startsCombat = false,
        texture = 606550,

        handler = function ()
            applyBuff( "soothing_mist" )
        end,
    },

    spinning_crane_kick = {
        id = 101546,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyBuff( "spinning_crane_kick" )
            if pet.chiji.up then
                addStack( "invoke_chiji" )
                gust_of_mist.count = min( 10, gust_of_mist.count + 1 )
            end
        end,
    },

    thunder_focus_tea = {
        id = 116680,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 611418,
        nobuff = "thunder_focus_tea",

        handler = function ()
            addStack( "thunder_focus_tea", nil, talent.focused_thunder.enabled and 2 or 1 )
        end,
    },

    -- Strike with the palm of your hand, dealing 568 Physical damage. Reduces the remaining cooldown on your Brews by 1 sec.
    tiger_palm = {
        id = 100780,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        startsCombat = true,

        handler = function ()
            if talent.eye_of_the_tiger.enabled then
                applyDebuff( "target", "eye_of_the_tiger" )
                applyBuff( "eye_of_the_tiger" )
            end
            if talent.teachings_of_the_monastery.enabled then
                addStack( "teachings_of_the_monastery" )
            end
        end,
    },

    vivify = {
        id = 116670,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.19,
        spendType = "mana",

        startsCombat = false,
        texture = 1360980,

        handler = function ()
            if talent.secret_infusion.enabled and buff.thunder_focus_tea.stack == buff.thunder_focus_tea.max_stack then applyBuff( "secret_infusion_mastery" ) end
        end,
    },

    zen_focus_tea = {
        id = 209584,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 651940,

        handler = function ()
            applyBuff( "zen_focus_tea" )
            if set_bonus.tier30_4pc > 0 then applyBuff( "soulfang_vitality" ) end
        end,
    },

    -- Trigger a Zen Pulse around an ally. Deals 2,013 damage to all enemies within 8 yds of the target. The ally is healed for 2,127 per enemy damaged.
    zen_pulse = {
        id = 124081,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,
        texture = 613397,

        handler = function ()
        end,
    },
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output "
        .. "is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )

spec:RegisterSetting( "save_faeline", false, {
    type = "toggle",
    name = strformat( "%s: Prevent Overlap", Hekili:GetSpellLinkWithTexture( spec.talents.faeline_stomp[2] ) ),
    desc = strformat( "If checked, %s will not be recommended when %s and/or %s are active.\n\n"
        .. "Disabling this option may impact your mana efficiency.", Hekili:GetSpellLinkWithTexture( spec.talents.faeline_stomp[2] ),
        Hekili:GetSpellLinkWithTexture( spec.auras.ancient_concordance.id ), Hekili:GetSpellLinkWithTexture( spec.auras.awakened_faeline.id ) ),
    width = "full",
} )

spec:RegisterSetting( "roll_movement", 5, {
    type = "range",
    name = strformat( "%s: Check Distance", Hekili:GetSpellLinkWithTexture( 109132 ), Hekili:GetSpellLinkWithTexture( 115008 ) ),
    desc = strformat( "If set above zero, %s (and %s) may be recommended when your target is at least this far away.", Hekili:GetSpellLinkWithTexture( 109132 ),
        Hekili:GetSpellLinkWithTexture( 115008 ) ),
    min = 0,
    max = 100,
    step = 1,
    width = "full"
} )

    spec:RegisterStateExpr( "distance_check", function()
        return target.minR > ( settings.roll_movement or 0 )
    end )


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,
    cycle = true,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_intellect",

    package = "Mistweaver",

    strict = false
} )


spec:RegisterPack( "Mistweaver", 20230325, [[Hekili:nFvxVnUnqWFl5LljOj(ITsYDTioaxpGcCbT3dv5zjrtrzXAjsvsQZjfg63EhkARqj)vWH20(qIt4oK7YDho76OXrpgfMsmSOVo5Qjbxfm5MrJdU(2GpgfAEUIffwrOliZXFiiL43)gxBwYiFJPSMEUqssThHwwROWCu4SAEH5lIOz76CVEmGwXOy1pCvuyopnL5GY00Oql0lVAYLJV9NAsAs(eSM2KiRmCPOjXiBsiFtYXskgLOnCX8MKFHWk4cwtsOrww1KSmNbSAdrK2ANJ)JGFypXxVJSn74SmPQjPKiiWCwgNYzc6ZNpQ5HMhCHsWLtUztO0K87YII3)5CEtYJsvflfXZsUjhEdxjoPG)xexK6I4rrHfWNAB(Hiz4JV2MUzcYScwA0phfsvCdtXjaa1W)glMjyLCMUj5UPnjbULLculYRfPmvCMKwRJnmsKb5WV3ttX1iteRRfXl40f2ZkyVN1jiZtkycZi4wAo2OowMfBYzXLsbkdm1ZJwVZMKvRAsMvNLDiW1Om9ouvoCqoRampzTPleVUnrU2ko74LGg6h0aZndXmRwPndaDRpiDfxiSzdQIiyoN1do2noHnfV9xq67Jj(GhMV7d9)GupvklsLlfJgezJuSscxGIX9njZPPJkjp9MvrEJsbqAGUaSnq2EDBOlNGTmXJbWNJ6FfPO0rsszzK6ITzkqCGOIZHEuS2O4lgMG2)R4uUvgJYIP5mlRPJobDOdtC23oT5FJt7AR6xTMfJ9xQpubCwHuMgNvRE(qVPMXuAMAbsNdq9bFuf855gD8FuNoVef4bq)Op0mUI166bG(rFq2lmYWKIykbjO(ihFvVaKmVToRarE49DCVQxL09zFi7VMb(QMzSnA0J041qCx3glvdwpBnHdrlA3yIPsbvQsTbF7RZogjzjzb0gt3CcTwp3lN4wgKk03RnQ2pFyOu79oPwlFKA3PhdbPUy3)eB7E56Hf7A(B7IzHF9R2r39D5hTX9KQc95LLZiB)OANLLjVgPMGJRz16BmHJ2IXn)YKX3gfUKOSDkaH5XCuq5LvsLbZtyNI4uKBo1oyYFwdUkKI0YsGHuJQdgdclqHeWCMgtx8RT8HamyXNLc4NwZNEuzUtDJaDCGB0dXgoB8tU5z2reRn))nGDE823qp28WxAZowhDTB4e7OCTtWbZwYOmJxW2qE0J6yN)W0374JnpSlBDmX9B2YbTHWA7y1T6A4B02a4cE20(Y8(i8e6pmWovF)fFrLV3QDQ6(Roqf33uNQT)I9vP7D((IY(ggKCTNSV2N9cEYofDxT6KZoGy7Qv7tO98E5YbsvxyfPMI37x401Mo2gb9v(UFAWXpc85(pH7c8ieyOfCkBnZ5a7dgMBG1EtV1MZo6RK1jOdop57o2SK3VEoYbHZl0(TwEWJf3DVBAR)Pc925aVl44axFpUBIFbbL)Dvr2rD0JjSExdsuVQ98Vv17OoE760lRpOq5mSZVqfARKlvrHFIVaFD7fK2ESr)n]] )