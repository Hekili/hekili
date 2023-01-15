local addon, ns = ...
local L = LibStub("AceLocale-3.0"):NewLocale( ns.addon_name, "esES" )

if not L then return end

--[[

------------------------------------------------------------------------
-- Death Knight
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "DEATHKNIGHT" then

L["[Any]"] = true

L["Blood"] = true
L["Save |T237517:0|t Blood Shield"] = true
L["If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r expression) will try to avoid letting your |T237517:0|t Blood Shield fall off during lulls in damage."] = true
L["|T237525:0|t Icebound Fortitude Damage Threshold"] = true
L["When set above zero, the default priority can recommend |T237525:0|t Icebound Fortitude if you've taken this percentage of your maximum health in the past 5 seconds.  Icebound Fortitude also requires the Defensives toggle by default."] = true
L["|T237529:0|t Rune Tap Damage Threshold"] = true
L["When set above zero, the default priority can recommend |T237529:0|t Rune Tap if you've taken this percentage of your maximum health in the past 5 seconds.  Rune Tap also requires the Defensives toggle by default."] = true
L["|T136168:0|t Vampiric Blood Damage Threshold"] = true
L["When set above zero, the default priority can recommend |T136168:0|t Vampiric Blood if you've taken this percentage of your maximum health in the past 5 seconds.  Vampiric Blood also requires the Defensives toggle by default."] = true

L["Frost DK"] = true
L["Frozen Pulse"] = true
L["Runic Power for |T1029007:0|t Breath of Sindragosa"] = true
L["The addon will recommend |T1029007:0|t Breath of Sindragosa only if you have this much Runic Power (or more)."] = true

L["Unholy"] = true
L["[Wound Spender]"] = true
L["Death and Decay"] = true
L["Disable |T2000857:0|t Inscrutable Quantum Device Execute"] = true
L["If checked, the default Unholy priority will not try to use |T2000857:0|t Inscrutable Quantum Device solely because your enemy is in execute range."] = true

end

------------------------------------------------------------------------
-- Demon Hunder
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "DEMONHUNTER" then

L["Havoc"] = true
L["|cFFFF0000WARNING!|r  Demon Blades cannot be forecasted.\nSee /hekili > Havoc for more information."] = true
L["Recommend Movement"] = true
L["If checked, the addon will recommend |T1247261:0|t Fel Rush / |T1348401:0|t Vengeful Retreat when it is a potential DPS gain.\n\nThese abilities are critical for DPS when using |T1029722:0|t Momentum and similar talents.\n\nIf not using any talents related to movement, you may want to disable this to avoid unnecessary movement in combat."] = true
L["Recommend Movement for |T1392567:0|t Unbound Chaos"] = true
L["When Recommend Movement is disabled, you can enable this option to override it and allow |T1247261:0|t Fel Rush to be recommended when |T1392567:0|t Unbound Chaos is active."] = true
L["Demon Blades"] = true
L["|cFFFF0000WARNING!|r  If using the |T237507:0|t Demon Blades talent, the addon will not be able to predict Fury gains from your auto-attacks.  This will result in recommendations that jump forward in your display(s)."] = true
L["I understand that Demon Blades is unpredictable; don't warn me."] = true
L["If checked, the addon will not provide a warning about Demon Blades when entering combat."] = true

L["Vengeance"] = true
L["Reserve |T1344650:0|t Infernal Strike Charges"] = true
L["If set above zero, the addon will not recommend |T1344650:0|t Infernal Strike if it would leave you with fewer charges."] = true
L["Require |T1097742:0|t Frailty Stacks"] = true
L["If set above zero, the default priority will not allow certain abilities to be used unless you have at least this many stacks of |T1097742:0|t Frailty on your target.\n\nThis is an experimental setting.  Requiring too many stacks may result in delays to using your major cooldowns and cause a loss of DPS."] = true

end

------------------------------------------------------------------------
-- Druid
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "DRUID" then

L["Incarnation"] = true

L["Balance"] = true
L["Starsurge Empowerment (Lunar)"] = true
L["Starsurge Empowerment (Solar)"] = true
L["Cancel |T462651:0|t Starlord"] = true
L["If checked, the addon will recommend canceling your Starlord buff before starting to build stacks with Starsurge again.\n\nYou will likely want a |cFFFFD100/cancelaura Starlord|r macro to manage this during combat."] = true
L["Delay |T135727:0|t Berserking (Troll only)"] = true
L["If checked, the default priority will attempt to adjust the timing of |T135727:0|t Berserking to be consistent with simmed |T135939:0|t Power Infusion usage."] = true

L["Feral"] = true
L["(Cat)"] = true
-- L["|T136036:0|t Attempt Owlweaving (Experimental)"] = true
-- L["If checked, the addon will swap to Moonkin Form based on the default priority."] = true
-- L["|T136085:0|t Use Regrowth as Filler"] = true
-- L["If checked, the default priority will recommend |T136085:0|t Regrowth when you use the Bloodtalons talent and would otherwise be pooling Energy to retrigger Bloodtalons."] = true
L["|T132152:0|t Rip Duration"] = true
L["If set above 0, the addon will not recommend |T132152:0|t Rip if your target will die within the timeframe specified."] = true
L["Allow |T132089:0|t Shadowmeld (Night Elf only)"] = true
L["If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat)."] = true

L["Guardian"] = true
L["(Bear)"] = true
L["Excess Rage for |T132136:0|t Maul"] = true
L["If set above zero, the addon will recommend |T132136:0|t Maul only if you have at least this much excess Rage."] = true
L["Use |T132135:0|t Mangle More in Multi-Target"] = true
L["If checked, the default priority will recommend |T132135:0|t Mangle more often in |cFFFFD100multi-target|r scenarios.\n\nThis will generate roughly 15% more Rage and allow for more mitigation (or |T132136:0|t Maul) than otherwise, funnel slightly more damage into your primary target, but will |T134296:0|t Swipe less often, dealing less damage/threat to your secondary targets."] = true
L["Required Damage % for |T1378702:0|t Ironfur"] = true
L["If set above zero, the addon will not recommend |T1378702:0|t Ironfur unless your incoming damage for the past 5 seconds is greater than this percentage of your maximum health."] = true
-- L["|T3636839:0|t Powershift for Convoke the Spirits"] = true
-- L["If checked, the addon will recommend swapping to Cat Form before using |T3636839:0|t Convoke the Spirits.\n\nThis is a DPS gain unless you die horribly."] = true
L["|T132115:0|t Attempt Catweaving (Experimental)"] = true
L["If checked, the addon will use the experimental |cFFFFD100catweave|r priority included in the default priority pack."] = true
L["|T136036:0|t Attempt Owlweaving (Experimental)"] = true
L["If checked, the addon will use the experimental |cFFFFD100owlweave|r priority included in the default priority pack."] = true

L["Restoration"] = true

end

------------------------------------------------------------------------
-- Evoker
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "EVOKER" then

L["Use |T4622450:0|t Deep Breath"] = true
L["If checked, the addon may recommend |T4622450:0|t Deep Breath, which causes your character to fly forward while damaging enemies.  This ability requires your Cooldowns toggle to be active by default.\n\nDisabling this setting will prevent the addon from ever recommending Deep Breath, which you may prefer due to the movement (or for any other reason)."] = true
L["Use |T4630499:0|t Unravel"] = true
L["If checked, the addon may recommend |T4630499:0|t Unravel when your target has an absorb shield applied.  By default, Unravel also requires your Interrupts toggle to be active."] = true
L["Early Chain |T4622451:0|t Disintegrate"] = true
L["If checked, the default priority may recommend |T4622451:0|t Disintegrate in the middle of a Disintegrate channel."] = true
L["Clip |T4622451:0|t Disintegrate"] = true
L["If checked, the default priority may recommend interrupting a |T4622451:0|t Disintegrate channel when another spell is ready."] = true

L["Devastation"] = true

L["Preservation"] = true

end

------------------------------------------------------------------------
-- Hunter
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "HUNTER" then

L["Beast Mastery"] = true
L["|T2058007:0|t Barbed Shot Grace Period"] = true
L["If set above zero, the addon (using the default priority or |cFFFFD100barbed_shot_grace_period|r expression) will recommend |T2058007:0|t Barbed Shot up to 1 global cooldown earlier."] = true
L["Avoid |T132127:0|t Bestial Wrath Overlap"] = true
L["If checked, the addon will not recommend |T132127:0|t Bestial Wrath if the buff is already applied."] = true
L["Check Pet Range for |T132176:0|t Kill Command"] = true
L["If checked, the addon will not recommend |T132176:0|t Kill Command if your pet is not in range of your target.\n\nRequires |c%sPet-Based Target Detection|r."] = true

L["Marksmanship"] = true
L["Prevent Hardcasts of |T135130:0|t Aimed Shot During Movement"] = true
L["If checked, the addon will not recommend |T135130:0|t Aimed Shot if it has a cast time and you are moving."] = true
L["Use |T132329:0|t Trueshot with |T537444:0|t Eagletalon's True Focus Runeforge"] = true
L["If checked, the default priority includes usage of |T132329:0|t Trueshot pre-pull, assuming you will successfully swap your legendary on your own.  The addon will not tell you to swap your gear."] = true

L["Survival"] = true
L["Use |T1376040:0|t Harpoon"] = true
L["If checked, the addon will recommend |T1376040:0|t Harpoon when you are out of range and Harpoon is available."] = true
L["Allow Focus Overcap"] = true
L["The default priority tries to avoid overcapping Focus by default.  In simulations, this helps to avoid wasting Focus.  In actual gameplay, this can result in trying to use Focus spenders when other important buttons (Wildfire Bomb, Kill Command) are available to push.  On average, enabling this feature appears to be DPS neutral vs. the default setting, but has higher variance.  Your mileage may vary.\n\nThe default setting is |cFFFFD100unchecked|r."] = true

end

------------------------------------------------------------------------
-- Mage
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "MAGE" then

L["Arcane"] = true
L["Mana Gem"] = true

L["Fire"] = true
-- L["Accept Fire Disclaimer"] = true
-- L["The Fire Mage module is disabled by default, as it tends to require *much* more CPU usage than any other specialization module.  If you wish to use the Fire module, can check this box and reload your UI (|cFFFFD100/reload|r) and the module will be available again."] = true
L["Allow |T135808:0|t Pyroblast Hardcast Pre-Pull"] = true
L["If checked, the addon will recommend an opener |T135808:0|t Pyroblast against bosses, if included in the current priority."] = true
L["Prevent |T135808:0|t Pyroblast and |T135812:0|t Fireball Hardcasts While Moving"] = true
L["If checked, the addon will not recommend |T135808:0|t Pyroblast or |T135812:0|t Fireball if they have a cast time and you are moving.\n\nInstant |T135808:0|t Pyroblasts will not be affected."] = true

L["Frost Mage"] = true
-- L["Ignore |T629077:0|t Freezing Rain in Single-Target"] = true
-- L["If checked, the default action list will not recommend using |T135857:0|t Blizzard in single-target due to the |T629077:0|t Freezing Rain talent proc."] = true
L["Manually Control |T1698701:0|t Water Jet (Water Elemental)"] = true
L["If checked, |T1698701:0|t Water Jet can be recommended by the addon.  This spell is normally auto-cast by your Water Elemental.  You will want to disable its auto-cast before using this feature."] = true

end

------------------------------------------------------------------------
-- Monk
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "MONK" then

L["Brewmaster"] = true
L["Use |T606543:0|t Spinning Crane Kick in Single-Target with |T611419:0|t Walk with the Ox"] = true
L["If checked, the default priority will recommend |T606543:0|t Spinning Crane Kick when |T611419:0|t Walk with the Ox is active.  This tends to reduce mitigation slightly but increase damage based on using |T627607:0|t Invoke Niuzao more frequently."] = true
L["Maximize |T1360979:0|t Celestial Brew Shield"] = true
L["If checked, the addon will focus on using |T133701:0|t Purifying Brew as often as possible, to build stacks of Purified Chi for your Celestial Brew shield.\n\nThis is likely to work best with the Light Brewing talent, but risks leaving you without a charge of Purifying Brew following a large spike in your Stagger.\n\nCustom priorities may ignore this setting."] = true
L["|T133701:0|t Purifying Brew: Stagger Tick % Current Health"] = true
L["If set above zero, the addon will recommend |T133701:0|t Purifying Brew when your current stagger ticks for this percentage of your |cFFFF0000current|r effective health (or more).  Custom priorities may ignore this setting.\n\nThis value is halved when playing solo."] = true
L["|T133701:0|t Purifying Brew: Stagger Tick % Maximum Health"] = true
L["If set above zero, the addon will recommend |T133701:0|t Purifying Brew when your current stagger ticks for this percentage of your |cFFFF0000maximum|r health (or more).  Custom priorities may ignore this setting.\n\nThis value is halved when playing solo."] = true
L["|T615339:0|t Breath of Fire: Require |T594274:0|t Keg Smash %"] = true
L["If set above zero, |T615339:0|t Breath of Fire will only be recommended if this percentage of your targets are afflicted with |T594274:0|t Keg Smash.\n\nExample:  If set to |cFFFFD10050|r, with 2 targets, Breath of Fire will be saved until at least 1 target has Keg Smash applied."] = true
L["|T627486:0|t Expel Harm: Health %"] = true
L["If set above zero, the addon will not recommend |T627486:0|t Expel Harm until your health falls below this percentage."] = true

L["Mistweaver"] = true

L["Windwalker"] = true
L["Flying Serpent Kick"] = true
L["Use |T606545:0|t Flying Serpent Kick"] = true
L["If unchecked, |T606545:0|t Flying Serpent Kick will not be recommended (this is the same as disabling the ability via Windwalker > Abilities > Flying Serpent Kick > Disable)."] = true
-- L["Optimize |T627486:0|t Reverse Harm"] = true
-- L["If checked, |T627486:0|t Reverse Harm's caption will show the recommended target's name."] = true
L["Reserve One |T136038:0|t Storm, Earth, and Fire Charge as CD"] = true
L["If checked, |T136038:0|t when Storm, Earth, and Fire's toggle is set to Default, only one charge will be reserved for use with the Cooldowns toggle."] = true
L["Required Damage for |T651728:0|t Touch of Karma"] = true
L["If set above zero, |T651728:0|t Touch of Karma will only be recommended while you have taken this percentage of your maximum health in damage in the past 3 seconds."] = true
L["Check |T988194:0|t Whirling Dragon Punch Range"] = true
L["If checked, when your target is outside of |T988194:0|t Whirling Dragon Punch's range, it will not be recommended."] = true
L["Check |T606543:0|t Spinning Crane Kick Range"] = true
L["If checked, when your target is outside of |T606543:0|t Spinning Crane Kick's range, it will not be recommended."] = true
L["Use |T775460:0|t Diffuse Magic to Self-Dispel"] = true
L["If checked, when you have a dispellable magic debuff, |T775460:0|t Diffuse Magic can be recommended in the default Windwalker priority.\n\nRequires %s|r Toggle."] = true
L["If checked, when you have a dispellable magic debuff, |T775460:0|t Diffuse Magic can be recommended in the default Windwalker priority."] = true

end

------------------------------------------------------------------------
-- Paladin
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "PALADIN" then

L["Holy"] = true

L["Protection Paladin"] = true
L["|T133192:0|t Word of Glory Health Threshold"] = true
L["When set above zero, the addon may recommend |T133192:0|t Word of Glory when your health falls below this percentage."] = true
L["|T135919:0|t Guardian of Ancient Kings Damage Threshold"] = true
L["Guardian of Ancient Kings"] = true
L["|T524354:0|t Divine Shield Damage Threshold"] = true
L["Divine Shield"] = true
L["When set above zero, the addon may recommend %s when you take this percentage of your maximum health in damage in the past 5 seconds.\n\nBy default, your Defensives toggle must also be enabled."] = true

L["Retribution"] = true
L["Check |T1112939:0|t Wake of Ashes Range"] = true
L["If checked, when your target is outside of |T1112939:0|t Wake of Ashes' range, it will not be recommended."] = true

end

------------------------------------------------------------------------
-- Priest
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "PRIEST" then

L["Discipline"] = true

L["Holy"] = true

L["Shadow"] = true
L["Pad |T1035040:0|t Void Bolt Cooldown"] = true
L["If checked, the addon will treat |T1035040:0|t Void Bolt's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T1386550:0|t Voidform."] = true
L["Pad |T3528286:0|t Ascended Blast Cooldown"] = true
L["If checked, the addon will treat |T3528286:0|t Ascended Blast's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T3565449:0|t Boon of the Ascended."] = true
L["|T136149:0|t Shadow Word: Death Health Threshold"] = true
L["If set above 0, the addon will not recommend |T136149:0|t Shadow Word: Death while your health percentage is below this threshold.  This setting can help keep you from killing yourself."] = true
L["Ignore |T1500943:0|t Volatile Solvent for |T1386548:0|t Void Eruption"] = true
L["If disabled, when you have the |T1500943:0|t Volatile Solvent conduit enabled, the addon will not use |T1386548:0|t Void Eruption unless you currently have a Volatile Solvent buff applied (from casting |T3586267:0|t Fleshcraft)."] = true
L["|T237565:0|t Mind Sear Ticks"] = true
L["|T237565:0|t Mind Sear costs 25 Insanity (and 25 additional Insanity per tick).  If set above 0, this setting will treat Mind Sear as unusable if your cast would result in fewer ticks of Mind Sear than desired."] = true

end

------------------------------------------------------------------------
-- Rogue
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "ROGUE" then

L["|T236364:0|t Marked for Death Combo Points"] = true
L["The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer."] = true
L["Allow |T132089:0|t Shadowmeld (Night Elf only)"] = true
L["If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat)."] = true
L["Allow |T132331:0|t Vanish when Solo"] = true
L["If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat)."] = true

L["Assassination"] = true
L["Funnel AOE -> Target"] = true
L["If checked, the addon's default priority list will focus on funneling damage into your primary target when multiple enemies are present."] = true
L["Energy % for |T132287:0|t Envenom"] = true
L["If set above 0, the addon will pool to this Energy threshold before recommending |T132287:0|t Envenom."] = true

L["Outlaw"] = true
L["Use |T132282:0|t Ambush Regardless of Talents"] = true
L["If checked, the addon will recommend |T132282:0|t Ambush even without Hidden Opportunity or Find Weakness talented.\n\nDragonflight sim profiles only use Ambush with Hidden Opportunity or Find Weakness talented; this is likely suboptimal."] = true

L["Subtlety"] = true
L["Use Priority Rotation (Funnel Damage)"] = true
L["If checked, the default priority will recommend building combo points with |T1375677:0|t Shuriken Storm and spending on single-target finishers."] = true

end

------------------------------------------------------------------------
-- Shaman
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "SHAMAN" then

L["Use |T136075:0|t Purge or |T451166:0|t Greater Purge on Enemies"] = true
L["If checked, |T136075:0|t Purge or |T451166:0|t Greater Purge can be recommended by the addon when your target has a dispellable magic effect.\n\nThese abilities are also on the Interrupts toggle by default."] = true
L["|T136075:0|t Purge Internal Cooldown"] = true
L["If set above zero, the addon will not recommend |T136075:0|t Purge more frequently than this amount of time, even if there are more dispellable magic effects on your target.  This can prevent you from being encouraged to spam Purge endlessly against enemies with rapidly stacking magic buffs."] = true

L["Elemental"] = true
L["|T135855:0|t Icefury and |T839977:0|t Stormkeeper Padding"] = true
L["The default priority tries to avoid wasting |T839977:0|t Stormkeeper and |T135855:0|t Icefury stacks with a grace period of 1.1 GCD per stack.\n\nIncreasing this number will reduce the likelihood of wasted Icefury / Stormkeeper stacks due to other procs taking priority, and leave you with more time to react."] = true

L["Enhancement"] = true
L["Pad |T1029585:0|t Windstrike Cooldown"] = true
L["If checked, the addon will treat |T1029585:0|t Windstrike's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T135791:0|t Ascendance."] = true
L["Pad |T236289:0|t Lava Lash Cooldown"] = true
L["If checked, the addon will treat |T236289:0|t Lava Lash's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T135823:0|t Hot Hand."] = true
L["Filler |T135813:0|t Shock"] = true
L["If checked, the addon's default priority will recommend a filler |T135813:0|t Flame Shock when there's nothing else to push, even if something better will be off cooldown very soon.  This matches sim behavior and is a small DPS increase, but has been confusing to some users."] = true

L["Restoration"] = true

end

------------------------------------------------------------------------
-- Warlock
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "WARLOCK" then

L["Summon Demon"] = true

L["Affliction"] = true
L["Model |T136163:0|t Drain Soul Ticks"] = true
L["If checked, the addon will expend |cFFFF0000more CPU|r determining when to break |T136163:0|t Drain Soul channels in favor of other spells.  This is generally not worth it, but is technically more accurate."] = true
L["|T136139:0|t Agony Macro"] = true
L["|T136118:0|t Corruption Macro"] = true
L["|T136188:0|t Siphon Life Macro"] = true
L["Using a macro makes it easier to apply your DoT effects to other targets without switching targets."] = true

L["Demonology"] = true
L["Wild Imps Required"] = true
L["If set above zero, |T2065628:0|t Summon Demonic Tyrant will not be recommended unless the specified number of imps are summoned.\n\nThis can backfire horribly, letting your Felguard or Vilefiend expire when you could've extended them with Summon Demonic Tyrant."] = true

L["Destruction"] = true
L["Preferred Demon"] = true
L["Specify which demon should be summoned if you have no active pet."] = true
L["Require 3+ Targets for AOE"] = true
L["If checked, the default action list will only use its AOE action list (including |T%s:0|t Rain of Fire) when there are 3+ targets.\n\nIn multi-target Patchwerk simulations, this setting creates a significant DPS loss.  However, this option may be useful in real-world scenarios, especially if you are fighting two moving targets that will not stand in your Rain of Fire for the whole duration."] = true
L["When %1$s is shown with a |TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t indicator, the addon is recommending that you cast %2$s on a different target (without swapping).  A mouseover macro is useful for this and an example is included below."] = true
L["Havoc"] = true
L["Havoc Macro"] = true
L["Immolate"] = true
L["Immolate Macro"] = true

end

------------------------------------------------------------------------
-- Warriror
------------------------------------------------------------------------

if UnitClassBase( "player" ) == "WARRIOR" then

L["Only |T236312:0|t Shockwave as Interrupt (when Talented)"] = true
L["If checked, |T236312:0|t Shockwave will only be recommended when your target is casting."] = true
L["Use Heroic Charge Combo"] = true
L["If checked, the default priority will check |cFFFFD100settings.heroic_charge|r to determine whether to use |T236171:0|t Heroic Leap + |T132337:0|t Charge together.\n\nThis is generally a DPS increase but the erratic movement can be disruptive to smooth gameplay."] = true

L["Arms"] = true

L["Fury"] = true
L["Check |T132369:0|t Whirlwind Range"] = true
L["If checked, when your target is outside of |T132369:0|t Whirlwind's range, it will not be recommended."] = true

L["Protection Warrior"] = true
L["Overlap |T1377132:0|t Ignore Pain"] = true
L["If checked, |T1377132:0|t Ignore Pain can be recommended while it is already active.  This setting may cause you to spend more Rage on mitigation."] = true
L["Overlap |T132110:0|t Shield Block"] = true
L["If checked, the addon can recommend overlapping |T132110:0|t Shield Block usage.\n\nThis setting avoids leaving Shield Block at 2 charges, which wastes cooldown recovery time."] = true
L["Allow Stance Changes"] = true
L["If checked, custom priorities can be written to recommend changing between stances.  For example, Battle Stance could be recommended when using offensive cooldowns, then Defensive Stance can be recommended when tanking resumes.\n\nIf left unchecked, the addon will not recommend changing your stance as long as you are already in a stance.  This choice prevents the addon from endlessly recommending that you change your stance when you do not want to change it."] = true
L["|T135726:0|t Reserve Rage for Mitigation"] = true
L["If set above 0, the addon will not recommend |T132353:0|t Revenge or |T135358:0|t Execute unless you'll be still have this much Rage afterward.\n\nWhen set to |cFFFFD10035|r or higher, this feature ensures that you can always use |T1377132:0|t Ignore Pain and |T132110:0|t Shield Block when following recommendations for damage and threat."] = true
L["|T132362:0|t Shield Wall Damage Required"] = true
L["If set above 0, the addon will not recommend |T132362:0|t Shield Wall unless you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\nIf set to |cFFFFD10050%|r and your maximum health is 50,000, then the addon will only recommend Shield Wall when you've taken 25,000 damage in the past 5 seconds.\n\nThis value is reduced by 50% when playing solo."] = true
L["|T132362:0|t Shield Wall Health Percentage"] = true
L["If set below 100, the addon will not recommend |T132362:0|t Shield Wall unless your current health has fallen below this percentage."] = true
L["Require |T132362:0|t Shield Wall Damage and Health"] = true
L["If checked, |T132362:0|t Shield Wall will not be recommended unless both the Damage Required |cFFFFD100and|r Health Percentage requirements are met.\n\nOtherwise, Shield Wall can be recommended when |cFFFFD100either|r requirement is met."] = true
L["|T132351:0|t Rallying Cry Damage Required"] = true
L["If set above 0, the addon will not recommend |T132351:0|t Rallying Cry unless you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\nIf set to |cFFFFD10050%|r and your maximum health is 50,000, then the addon will only recommend Rallying Cry when you've taken 25,000 damage in the past 5 seconds.\n\nThis value is reduced by 50% when playing solo."] = true
L["|T132351:0|t Rallying Cry Health Percentage"] = true
L["If set below 100, the addon will not recommend |T132351:0|t Rallying Cry unless your current health has fallen below this percentage."] = true
L["Require |T132351:0|t Rallying Cry Damage and Health"] = true
L["If checked, |T132351:0|t Rallying Cry will not be recommended unless both the Damage Required |cFFFFD100and|r Health Percentage requirements are met.\n\nOtherwise, Rallying Cry can be recommended when |cFFFFD100either|r requirement is met."] = true
L["Use |T135871:0|t Last Stand Offensively"] = true
L["If checked, the addon will recommend using |T135871:0|t Last Stand to generate rage.\n\nIf unchecked, the addon will only recommend |T135871:0|t Last Stand defensively after taking significant damage.\n\nRequires |T571316:0|t Unnerving Focus %1$s or %2$s."] = true
L["Talent"] = true
L["Conduit"] = true
L["|T135871:0|t Last Stand Damage Required"] = true
L["If set above 0, the addon will not recommend |T135871:0|t Last Stand unless you have taken this much damage in the past 5 seconds, as a percentage of your maximum health.\n\nIf set to |cFFFFD10050%|r and your maximum health is 50,000, then the addon will only recommend Last Stand when you've taken 25,000 damage in the past 5 seconds.\n\nThis value is reduced by 50% when playing solo."] = true
L["|T135871:0|t Last Stand Health Percentage"] = true
L["If set below 100, the addon will not recommend |T135871:0|t Last Stand unless your current health has fallen below this percentage."] = true
L["Require |T135871:0|t Last Stand Damage and Health"] = true
L["If checked, |T135871:0|t Last Stand will not be recommended unless both the Damage Required |cFFFFD100and|r Health Percentage requirements are met.\n\nOtherwise, Last Stand can be recommended when |cFFFFD100either|r requirement is met."] = true

end

]]
