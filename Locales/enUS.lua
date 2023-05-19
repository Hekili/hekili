local addon, ns = ...
local L = LibStub("AceLocale-3.0"):NewLocale( addon, "enUS", true )
local isDF, isWrath = ns.IsDragonflight(), ns.IsWrath()
if not L then return end


L["'%1$s' is not a valid option for %2$s."] = true
L["'%s' is not a valid profile name."] = true
L["(current)"] = true
L["(none)"] = true
L["(not set)"] = true
L["(to disable)"] = true
L["(to enable)"] = true
L["(to toggle)"] = true
L["[Trinket 1] and [Trinket 2], which will recommend the trinket for the numbered slot."] = true
L["[Use Items], which includes any trinkets not explicitly included in the priority; or"] = true
L["%1$s %2$s (%3$s)"] = true
L["%1$s set to %2$s."] = true
L["%1$s toggle set to %2$s."] = true
L["%1$s, if %2$s"] = true
L["%1$s|w|r is on your action bar and will be used for all your %2$s pets."] = true
L["%s |cFF00FF00ENABLED|r."] = true
L["%s |cFFFF0000DISABLED|r."] = true
L["%s default = %s"] = true
L["%s hold removed."] = true
L["%s mode activated."] = true
L["%s not set."] = true
L["%s Override"] = true
L["%s placed on hold until end of combat."] = true
L["%s placed on hold."] = true
L["%s set to %.2f."] = true
L["%s, and %s."] = true
L["|cFFFF0000WARNING|r:  Pet-based target detection requires |cFFFFD100enemy nameplates|r to be enabled."] = true
L["|cFFFFD100cycle|r, |cFFFFD100swap|r, or |cFFFFD100target_swap|r = %s|r (%s)"] = true
L["A rough skeleton of your current spec, for development purposes only."] = true
L["A target count indicator can be shown on the display's first recommendation."] = true
L["Abilities"] = true
L["Ability"] = true
L["Action Criteria"] = true
L["Action list names should be at least %d characters in length."] = true
L["Action List"] = true
L["Action Lists are used to determine which abilities should be used at what time."] = true
L["Action Lists"] = true
L["Action"] = true
L["Active"] = true
L["Add Ability"] = true
L["Add List"] = true
L["Add Value"] = true
L["add"] = true
L["Addon |cFFFFD100DISABLED|r."] = true
L["Addon |cFFFFD100ENABLED|r."] = true
L["Addon will now gather specialization information.  Select all talents and use all abilities for best results."] = true
L["Advanced"] = true
L["Alignment"] = true
L["All abilities are highlighted in red if you are out of melee range."] = true
L["All other action list conditions must also be met."] = true
L["All specializations are currently supported, though healer priorities are experimental and focused on rotational DPS only."] = true
L["Allows editing of multiple displays at once."] = true
L["alternate"] = true
L["Alternative(s):"] = true
L["An example expression would be |cFFFFD100energy.time_to_max|r."] = true
L["Anchor Point"] = true
L["Anchor To"] = true
L["and"] = true
L["AOE (Multi-Target)"] = true
L["AOE Display"] = true
L["AOE"] = true
L["Apply Changes"] = true
L["Apply ElvUI Cooldown Style"] = true
L["arcane_charges"] = true
L["astral_power"] = true
L["Attempted to serialize an invalid display (%s)"] = true
L["Author"] = true
L["Auto Snapshot"] = true
L["Auto"] = true
L["AutoCast Shine"] = true
L["Automatic"] = true
L["BACKGROUND"] = "Background"
L["Bloodlust"] = true
L["Border Inside"] = true
L["Border Thickness"] = true
L["Border"] = true
L["Boss Encounter Only"] = true
L["Bottom Left"] = true
L["Bottom Right"] = true
L["Bottom"] = true
L["Buff Name"] = true
L["By storing your export string, you can save these display settings and retrieve them later if you make changes to your settings."] = true
L["Call Action List"] = true
L["Called from %s, %s, #%s."] = true
L["Cancel Action"] = true
L["Cancel Buff"] = true
L["Cancel"] = true
L["Caption"] = true
L["Captions are |cFFFF0000very|r short descriptions that can appear on the icon of a recommended ability."] = true
L["Captions are brief descriptions sometimes (rarely) used in action lists to describe why the action is shown."] = true
L["Captions should be %d characters or less."] = true
L["Captions"] = true
L["Casting"] = true
L["CD"] = true
L["ceil"] = true
L["Ceiling of Value"] = true
L["Center"] = true
L["Certain options are disabled when editing multiple displays."] = true
L["Changes |cFF00FF00will|r be applied to the %s display."] = true
L["Changes |cFFFF0000will not|r be applied to the %s display."] = true
L["Changing the font below will modify |cFFFF0000ALL|r text on all displays."] = true
L["Character Data"] = true
L["Check Movement"] = true
L["Checked"] = true
L["chi"] = true
L["Circle"] = true
L["Clash"] = true
L["Class-colored borders will automatically change to match the class you are playing."] = true
L["Class"] = true
L["Click here and press Ctrl-A, Ctrl-C to copy the snapshot.\n\nPaste in a text editor to review or upload to Pastebin to support an issue ticket."] = true
L["Color"] = true
L["Coloring Mode"] = true
L["Combat w/ Target"] = true
L["Combat"] = true
L["combo_points"] = true
L["Conditions"] = true
L["ConsolePort Button Zoom"] = true
L["ConsolePort"] = true
L["Converted '%s' to '%s' (%sx)."] = true
L["Converted '%s' to '%s'."] = true
L["Converted operations in '%s' to '%s'."] = true
L["Cooldown: Show Separately - Use Actual Cooldowns"] = true
L["Cooldowns Override"] = true
L["cooldowns"] = true
L["Cooldowns"] = true
L["Copy Priority"] = true
L["Core features and specialization options for %s."] = true
L["Core"] = true
L["Cov"] = true
L["Covenants"] = true
L["Create a copy of this priority pack?"] = true
L["Create a New Action List"] = true
L["Create a new Priority named \"%s\" from the imported data?"] = true
L["Create a New Priority"] = true
L["Create New Entry"] = true
L["Create New Pack"] = true
L["Current Display Mode"] = true
L["Current DoT Information at %1$s for %2$s:"] = true
L["Current DoT Information at %s:"] = true
L["Current Status"] = true
L["Custom #1 Name"] = true
L["Custom #1"] = true
L["Custom #2 Name"] = true
L["Custom #2"] = true
L["Custom 1"] = true
L["Custom 2"] = true
L["Custom Color"] = true
L["Custom"] = true
L["Cycle Targets"] = true
L["Damage Detection Timeout"] = true
L["Def"] = true
L["Default %s"] = true
L["Default Button Glow"] = true
L["Default displays and action lists restored."] = true
L["Default value is %s."] = true
L["Default"] = true
L["defensives"] = true
L["Defensives"] = true
L["Delays"] = true
L["Delete Priority"] = true
L["Delete this action list?"] = true
L["Delete this Action List"] = true
L["Delete this entry?"] = true
L["Delete this priority package?"] = true
L["Description"] = true
L["Detect Damaged Enemies"] = true
L["Detect Dotted Enemies"] = true
L["Detect Enemies Damaged by Pets"] = true
L["Determines the thickness (width) of the border."] = true
L["DIALOG"] = "Dialog"
L["Disable %s via |cff00ccff[Use Items]|r"] = true
L["Disable %s"] = true
L["Disable Interrupts:  |cFFFFD100/hek set interupts off|r"] = true
L["Disable:  |cFFFFD100/hek set %s off|r"] = true
L["disabled"] = true
L["DISABLED"] = true
L["Display Mode"] = true
L["Display Modes"] = true
L["Display not found."] = true
L["Displays are not unlocked.  Use |cFFFFD100/hek move|r or |cFFFFD100/hek unlock|r to allow click-and-drag."] = true
L["Displays"] = true
L["div"] = true
L["Divide Value"] = true
L["Doing so will freeze the addon's recommendations, allowing you to mouseover the display and see which conditions were met to display those recommendations."] = true
L["Don't get smart, missy."] = true
L["Down"] = true
L["DPS players may want to add their own defensive abilities, but would also need to add the abilities to their own custom priority packs."] = true
L["Dual"] = true
L["During Channel"] = true
L["Each ability is highlighted in red if that ability is out of range."] = true
L["Each Priority can be shared with other addon users with these export strings."] = true
L["Enable Cooldowns:  |cFFFFD100/hek set cooldowns on|r"] = true
L["Enable:  |cFFFFD100/hek set %s on|r"] = true
L["Enable"] = true
L["Enable/disable or set the color for icon borders."] = true
L["Enabled for Queued Icons"] = true
L["enabled"] = true
L["Enabled"] = true
L["ENABLED"] = true
L["Enables or disables the addon."] = true
L["Enemies will also be forgotten if they die or despawn."] = true
L["Enemy nameplates are |cFF00FF00enabled|r and will be used to detect targets near your pet."] = true
L["energy"] = true
L["Enhanced Recheck"] = true
L["Enter a new, unique name for this package.  Only alphanumeric characters, spaces, underscores, and apostrophes are allowed."] = true
L["Enter the horizontal position of the notification panel, relative to the center of the screen."] = true
L["Enter the vertical position of the notification panel, relative to the center of the screen."] = true
L["Entries in red are disabled, have no action set, have a conditional error, or use actions that are disabled/toggled off."] = true
L["Entry Cooldown"] = true
L["Entry"] = true
L["essence"] = true
L["Exclude Out-of-Range"] = true
L["Exclude"] = true
L["Export %s"] = true
L["Export Snapshot"] = true
L["Export Style"] = true
L["Export"] = true
L["Extend Spiral"] = true
L["Extra Pooling"] = true
L["Fade as Unusable"] = true
L["Fade the primary icon when you should wait before using the ability, similar to when an ability is lacking required resources."] = true
L["false"] = true
L["Filter Damaged Enemies by Range"] = true
L["Finally, using the settings at the bottom of this panel, you can ask the addon to automatically generate a snapshot for you when no recommendations were able to be made."] = true
L["Fixed Brightness"] = true
L["Fixed Dual Display"] = true
L["Fixed Dual"] = true
L["Fixed Size"] = true
L["Floor of Value"] = true
L["floor"] = true
L["focus"] = true
L["Font and Style"] = true
L["Font"] = true
L["Fonts"] = true
L["For %1$s, %2$s is recommended due to its range.  It will work for all your pets."] = true
L["For pet-based detection to work, you must take an ability from your |cFF00FF00pet's spellbook|r and place it on one of |cFF00FF00your|r action bars."] = true
L["For ranged specializations with damage over time effects, this should be enabled."] = true
L["Frame Layer"] = true
L["Frame Level determines the display's position within its current layer."] = true
L["Frame Level"] = true
L["Frame Strata determines which graphical layer that this display is drawn on."] = true
L["Frame Strata"] = true
L["FULLSCREEN_DIALOG"] = "Fullscreen Dialog"
L["FULLSCREEN"] = "Fullscreen"
L["fury"] = true
L["Gear and Items can be adjusted via their own section (left)."] = true
L["Gear and Items"] = true
L["General"] = true
L["Generate Skeleton"] = true
L["Glow Color"] = true
L["Glow Style"] = true
L["Glows"] = true
L["Grow Direction"] = true
L["happiness"] = true
L["Healthstone"] = true
L["Heart Essence"] = true
L["Height"] = true
L["Hekili has up to five built-in displays (identified in blue) that can display different kinds of recommendations."] = true
L["Hekili is designed for current content.\nUse below level 50 at your own risk."] = true
L["Heroism"] = true
L["Hide Display"] = true
L["Hide Minimap Icon"] = true
L["Hide When Mounted"] = true
L["HIGH"] = "High"
L["holy_power"] = true
L["Hook Criteria"] = true
L["I will routinely update those when they are published.  Thanks!"] = true
L["Icon Replacement"] = true
L["Icon Size"] = true
L["Icon Spacing"] = true
L["Icon Zoom"] = true
L["Icons Shown"] = true
L["If an ability is not in-range, it will not be recommended."] = true
L["If checked and properly configured, the addon will count targets near your pet as valid targets, when your target is also within range of your pet."] = true
L["If checked, abilities from Covenants can be recommended."] = true
L["If checked, abilities linked to %s can be recommended."] = true
L["If checked, abilities marked as %s can be recommended."] = true
L["If checked, cooldown abilities will be shown separately in your Cooldowns Display."] = true
L["If checked, defensive/mitigation abilities will be shown separately in your Defensives Display."] = true
L["If checked, interrupt abilities will be shown separately in the Interrupts Display only (if enabled)."] = true
L["If checked, options are provided to fine-tune display visibility and transparency."] = true
L["If checked, some additional modifiers and conditions may be set."] = true
L["If checked, the addon will assume this entry is not time-sensitive and will not test actions in the linked priority list if criteria are not presently met."] = true
L["If checked, the addon will automatically create a snapshot whenever it failed to generate a recommendation."] = true
L["If checked, the addon will check each available target and show whether to switch targets."] = true
L["If checked, the addon will count any enemies that you've hit (or hit you) within the past several seconds as active enemies."] = true
L["If checked, the addon will count any enemies with visible nameplates within a small radius of your character."] = true
L["If checked, the addon will count enemies that your pets or minions have hit (or hit you) within the past several seconds."] = true
L["If checked, the addon will not recommend |W%s|w unless you are in a boss fight (or encounter)."] = true
L["If checked, the addon will not recommend |W%s|w via |cff00ccff[Use Items]|r unless you are in a boss fight (or encounter)."] = true
L["If checked, the addon will not show this display and will make recommendations via SpellFlash only."] = true
L["If checked, the addon will pool resources until the next entry has enough resources to use."] = true
L["If checked, the addon will provide priority recommendations for %s based on the selected priority list."] = true
L["If checked, the addon will take a screenshot when you manually create a snapshot."] = true
L["If checked, the addon will track processing time and volume of events."] = true
L["If checked, the addon's recommendations for this specialization are based on this priority package."] = true
L["If checked, the Display Mode toggle can select %s mode."] = true
L["If checked, the display will not be visible when you are mounted unless you are in combat."] = true
L["If checked, the display will not be visible when you are mounted when out of combat."] = true
L["If checked, the minimap icon will be hidden."] = true
L["If checked, the primary icon's cooldown spiral will continue until the ability should be used."] = true
L["If checked, this ability will |cffff0000NEVER|r be recommended by the addon."] = true
L["If checked, this entry can be checked even if the global cooldown (GCD) is active."] = true
L["If checked, this entry can be checked even if you are already casting or channeling."] = true
L["If checked, this entry can only be recommended when your character movement matches the setting."] = true
L["If checked, this entry can only be used if you are channeling another spell."] = true
L["If checked, this feature will enable the addon to do additional checking on entries that use the 'variable' feature."] = true
L["If checked, when %s (or similar effects) are active, the addon will recommend cooldown abilities even if Show Cooldowns is not checked."] = true
L["If checked, when Cooldowns are enabled, the addon will also recommend Covenants even if Show Covenants is not checked."] = true
L["If checked, when using the Cooldown: Show Separately feature and Cooldowns are enabled, the addon will |cFFFF0000NOT|r pretend your cooldown abilities are fully on cooldown."] = true
L["If cycle targets is checked, the addon will check up to the specified number of targets."] = true
L["If disabled, the addon will not recommend this item via the |cff00ccff[Use Items]|r action."] = true
L["If disabled, this display will not appear under any circumstances."] = true
L["If disabled, this entry will not be shown even if its criteria are met."] = true
L["If ElvUI is installed, you can apply the ElvUI cooldown style to your queued icons.\n\nDisabling this setting requires you to reload your UI (|cFFFFD100/reload|r)."] = true
L["If enabled, abilities that have active glows (or overlays) will also glow in your queue."] = true
L["If enabled, descriptive captions will be shown for queued abilities, if appropriate."] = true
L["If enabled, each icon in this display will have a thin border."] = true
L["If enabled, small indicators for target-swapping, aura-cancellation, etc. may appear on your primary icon."] = true
L["If enabled, the addon can highlight abilities on your action bars when they are recommended for use."] = true
L["If enabled, the addon will place a colorful glow on the first recommended ability for this display."] = true
L["If enabled, the addon will provide a red warning highlight when you are not in range of your enemy."] = true
L["If enabled, the addon will show the number of active (or virtual) targets for this display."] = true
L["If enabled, the whole action button will fade in and out."] = true
L["If enabled, these indicators will appear on queued icons as well as the primary icon, when appropriate."] = true
L["If enabled, when borders are enabled, the button's border will fit inside the button (instead of around it)."] = true
L["If enabled, when the ability for the first icon has an active glow (or overlay), it will also glow in this display."] = true
L["If enabled, when the first ability shown has a descriptive caption, the caption will be shown."] = true
L["If left unchecked, |W%s|w can be recommended in any type of fight."] = true
L["If non-zero, this display is shown with the specified level of opacity by default."] = true
L["If non-zero, this display is shown with the specified level of opacity in %s combat."] = true
L["If non-zero, this display is shown with the specified level of opacity when you are in combat and have an attackable %s target."] = true
L["If non-zero, this display is shown with the specified level of opacity when you have an attackable %s target."] = true
L["If set above zero, the addon will attempt to avoid counting targets that were out of range when last seen.  This is based on cached data and may be inaccurate."] = true
L["If set above zero, the addon will only allow %s to be recommended via |cff00ccff[Use Items]|r if there are at least this many detected enemies."] = true
L["If set above zero, the addon will only allow %s to be recommended via |cff00ccff[Use Items]|r if there are this many detected enemies (or fewer)."] = true
L["If set above zero, the addon will only allow %s to be recommended, if there are at least this many detected enemies."] = true
L["If set above zero, the addon will only allow %s to be recommended, if there are this many detected enemies (or fewer)."] = true
L["If set above zero, the addon will pretend %s has come off cooldown this much sooner than it actually has."] = true
L["If set to 5, the addon will not recommend swapping to a target that will die in fewer than 5 seconds."] = true
L["If set, this entry can only be recommended when your movement matches the setting."] = true
L["If set, this entry cannot be recommended unless this time has passed since the last time the ability was used."] = true
L["If specified, the addon will attempt to load this texture instead of the default icon."] = true
L["If specified, the addon will show this text in place of the auto-detected keybind text when recommending this ability."] = true
L["If the Priority is based on a SimulationCraft profile or a popular guide, it is a good idea to provide a link to the source (especially before sharing)."] = true
L["If this pack's action lists were imported from a SimulationCraft profile, the profile is included here."] = true
L["If this Priority was generated with a SimulationCraft profile, the profile can be stored or retrieved here."] = true
L["If used with |cFFFFD100Use Nameplate Detection|r, dotted enemies that are no longer in melee range will be filtered."] = true
L["If you are having a technical issue with the addon, please submit an issue report via the link below."] = true
L["If you find odd recommendations or other issues, please follow the |cFFFFD100Issue Reporting|r link below and submit all the necessary information to have your issue investigated."] = true
L["If you have a concern about the addon's recommendations, it is preferred that you provide a Snapshot (which will include this information) instead."] = true
L["If you have questions about -- or disagree with -- the addon's recommendations, reviewing a snapshot can help identify what factors led to the specific recommendations that you saw."] = true
L["If you want to customize this priority, make a copy by clicking %s."] = true
L["If your primary or queued icons are not square, checking this option will prevent the icon textures from being stretched and distorted, trimming some of the texture instead."] = true
L["Import %s"] = true
L["Import Log"] = true
L["Import Priority"] = true
L["Import String"] = true
L["Import Style"] = true
L["Import"] = true
L["Imported %d action lists."] = true
L["Imported settings were successfully applied!\n\nClick Reset to start over, if needed."] = true
L["Imported SimulationCraft priorities often require some translation before they will work with this addon."] = true
L["Includes anchoring, size, shape, and position settings when a display can show more than one icon."] = true
L["Includes display position, icons, primary icon size/shape, etc."] = true
L["Indicator"] = true
L["Indicators are small icons that can indicate target-swapping or (rarely) cancelling auras."] = true
L["Indicators"] = true
L["insanity"] = true
L["Installed Packs"] = true
L["Int"] = true
L["interrupts"] = true
L["Interrupts"] = true
L["Invalid characters entered.  Try again."] = true
L["Issue Reporting"] = true
L["Keep Aspect Ratio"] = true
L["Keybind Text"] = true
L["Keybindings should be no longer than %d characters in length."] = true
L["Keybinds"] = true
L["Last Updated"] = true
L["Leave blank and press Enter to reset to the default icon."] = true
L["Left Bottom"] = true
L["Left Top"] = true
L["Left-click and hold to move."] = true
L["Left-click to make quick adjustments."] = true
L["Left"] = true
L["Line %s"] = true
L["Link"] = true
L["List Name"] = true
L["LOW"] = "Low"
L["maelstrom"] = true
L["Main"] = true
L["mana"] = true
L["Max Cycle Targets"] = true
L["Max Energy"] = true
L["max"] = true
L["Maximum of Values"] = true
L["Maximum Targets"] = true
L["Maximum Update Time (ms)"] = true
L["MEDIUM"] = "Medium"
L["Melee Range"] = true
L["Melee"] = true
L["min"] = true
L["Minimum of Values"] = true
L["Minimum Target Time-to-Die"] = true
L["Minimum Targets"] = true
L["mod"] = true
L["Mode: %s"] = true
L["Modulo of Value"] = true
L["Monitor Performance"] = true
L["Monochrome Circle Thick"] = true
L["Monochrome Circle Thin"] = true
L["Monochrome, Outline"] = true
L["Monochrome, Thick Outline"] = true
L["Monochrome"] = true
L["Movement"] = true
L["Movers cannot be activated while in combat."] = true
L["Moving"] = true
L["mul"] = true
L["Multiple"] = true
L["Multiply Value"] = true
L["N/A"] = true
L["Nameplate Detection Range"] = true
L["Negative values move the panel down; positive values move the panel up."] = true
L["Negative values move the panel left; positive values move the panel right."] = true
L["Negative values will move the display down; positive values will move it up."] = true
L["Negative values will move the display left; positive values will move it to the right."] = true
L["nil"] = true
L["No action lists were imported from this profile."] = true
L["No active pet."] = true
L["No displays selected to export."] = true
L["No entry #%s for that display."] = true
L["No Indicator"] = true
L["No match found for priority '%s'.\nValid options are"] = true
L["No Name"] = true
L["No queue for that display."] = true
L["No snapshots have been generated."] = true
L["No Specialization Set"] = true
L["No support is offered for customized or imported priorities."] = true
L["none"] = true
L["None"] = true
L["NOT BOUND"] = true
L["Not Set"] = true
L["nothing"] = true
L["Notification Panel"] = true
L["Notifications"] = true
L["Null Cooldown"] = true
L["obsolete"] = true
L["obsolete2"] = true
L["off"] = true
L["OFF"] = true
L["on"] = true
L["ON"] = true
L["Only alphanumeric characters and underscores can be used in list names."] = true
L["Only alphanumeric characters, spaces, parentheses, underscores, and apostrophes are allowed in pack names."] = true
L["Only alphanumeric characters, spaces, underscores, and apostrophes are allowed in pack names."] = true
L["Open and view this priority pack and its action lists."] = true
L["Open Hekili Options Panel"] = true
L["Operation"] = true
L["Options for %s are:"] = true
L["Options for keybinding text on displayed icons."] = true
L["Outline"] = true
L["Override Keybind Text"] = true
L["Pack Date"] = true
L["Pack Name"] = true
L["Pack Specialization"] = true
L["pain"] = true
L["Paste a Priority import string here to begin."] = true
L["Paste your SimulationCraft action priority list or profile here."] = true
L["Pause"] = true
L["PAUSED"] = true
L["Per Ability"] = true
L["Performance"] = true
L["Pet action not found in player action bars."] = true
L["Pet is dead."] = true
L["Pixel Glow"] = true
L["Player has target and player's target not in range of pet."] = true
L["Please do not submit tickets for routine priority updates (i.e., from SimulationCraft)."] = true
L["Please see the |cFFFFD100Issue Reporting|r tab for information about reporting bugs."] = true
L["Please specify a unique pack name."] = true
L["Pool for Next Entry (%s)"] = true
L["Pool Resource"] = true
L["Pooling Time"] = true
L["Position"] = true
L["Positioning"] = true
L["Positive numbers move the queue to the right, negative numbers move it to the left."] = true
L["Positive numbers move the queue up, negative numbers move it down."] = true
L["Potion"] = true
L["potions"] = true
L["Potions"] = true
L["pow"] = true
L["Preferences for Blizzard action button glows (not SpellFlash)."] = true
L["Preferences for range-check warnings, if desired."] = true
L["Preferences"] = true
L["Press Ctrl-A to select, then Ctrl-C to copy."] = true
L["Press Pause again to unfreeze the addon."] = true
L["Pressing this binding will cycle your Display Mode through the options checked below."] = true
L["Primary Icon"] = true
L["Primary"] = true
L["Priorities (or action packs) are bundles of action lists used to make recommendations for each specialization."] = true
L["Priorities"] = true
L["Priority Export String"] = true
L["Priority Name"] = true
L["Priority set to %s."] = true
L["Priority"] = true
L["Profile"] = true
L["Provide the value to store (or calculate) if this variable's conditions are not met."] = true
L["Provide the value to store (or calculate) when this variable is invoked."] = true
L["PvE Alpha"] = true
L["PvE"] = true
L["PvP Alpha"] = true
L["PvP"] = true
L["Queue"] = true
L["Queued Font and Style"] = true
L["rage"] = true
L["Raise Value to X Power"] = true
L["Range Checking"] = true
L["Range"] = true
L["React"] = true
L["Reactive Dual Display"] = true
L["Reactive Dual"] = true
L["Reactive"] = true
L["Rebuild the action list(s) from the profile above."] = true
L["Recommend Target Swaps set to %s."] = true
L["Recommend Target Swaps"] = true
L["Reload Defaults"] = true
L["Reload Priority"] = true
L["Reload this priority pack from defaults?"] = true
L["Remove %1$s from %2$s toggle."] = true
L["Removed unnecessary energy cap check from action entry for fists_of_fury (%sx)."] = true
L["Removed unnecessary expel_harm cooldown check from action entry for jab (%sx)."] = true
L["Removing an ability from its toggle leaves it |cFF00FF00ENABLED|r regardless of whether the toggle is active."] = true
L["Require Toggle"] = true
L["Requires Captions to be Enabled on each display."] = true
L["Requires enemy nameplates."] = true
L["Requires pet ability on one of your action bars."] = true
L["reset %s"] = true
L["Reset to Default:  |cFFFFD100/hek set %s default|r"] = true
L["Reset to Default"] = true
L["reset"] = true
L["Reset"] = true
L["Restart"] = true
L["Right Bottom"] = true
L["Right Top"] = true
L["Right-click to open %s display settings."] = true
L["Right-click to open Notification panel settings."] = true
L["Right-click to open the options interface."] = true
L["Right"] = true
L["Run Action List"] = true
L["rune_blood"] = true
L["rune_frost"] = true
L["rune_unholy"] = true
L["runes"] = true
L["runic_power"] = true
L["Save Style"] = true
L["Saw %s exactly %.2f seconds ago."] = true
L["Seconds"] = true
L["See |cFFFFD100Toggles|r > |cFFFFD100Cooldowns|r for the |cFFFFD100Cooldown: Show Separately|r feature."] = true
L["See the Skeleton tab for more information."] = true
L["Select a Priority pack to export."] = true
L["Select a saved Style or paste an import string in the box provided."] = true
L["Select a Saved Style"] = true
L["Select a Snapshot to export."] = true
L["Select Snapshot"] = true
L["Select the |cFFFFD100Display Modes|r that you wish to use.  Each time you press your |cFFFFD100Display Mode|r keybinding, the addon will switch to the next checked mode."] = true
L["Select the action list to view or modify."] = true
L["Select the action that will be recommended when this entry's criteria are met."] = true
L["Select the coloring mode for this glow effect."] = true
L["Select the custom glow color for your display."] = true
L["Select the direction for the icon queue."] = true
L["Select the display style settings to export, then click Export Styles to generate an export string."] = true
L["Select the entry to modify in this action list."] = true
L["Select the glow style for your display."] = true
L["Select the height of the queued icons."] = true
L["Select the kind of range checking and range coloring to be used by this display."] = true
L["Select the number of pixels between icons in the queue."] = true
L["Select the point on the primary icon to which the queued icons will attach."] = true
L["Select the width of the queued icons."] = true
L["Select the zoom percentage for the icon textures in this display. (Roughly 30% will trim off the default Blizzard borders.)"] = true
L["Select your current Display Mode."] = true
L["Sephuz's Secret (ICD)"] = true
L["set %s = %s"] = true
L["Set a key to make a snapshot (without pausing) that can be viewed on the Snapshots tab.  This can be useful information for testing and debugging."] = true
L["Set a key to pause processing of your action lists."] = true
L["Set a key to toggle cooldown recommendations on/off."] = true
L["Set a key to toggle Covenant recommendations on/off."] = true
L["Set a key to toggle defensive/mitigation recommendations on/off."] = true
L["Set a key to toggle potion recommendations on/off."] = true
L["Set a key to toggle your first custom set."] = true
L["Set a key to toggle your second custom set."] = true
L["Set a key to use for toggling interrupts on/off."] = true
L["Set Default Value"] = true
L["Set Mode:  |cFFFFD100/hek set mode aoe|r (or |cFFFFD100automatic|r, |cFFFFD100single|r, |cFFFFD100dual|r, |cFFFFD100reactive|r)"] = true
L["Set profile to %s."] = true
L["Set the horizontal position for this display's primary icon relative to the center of the screen."] = true
L["Set the transparency of the display when in %s environments.  If set to 0, the display will not appear in %s."] = true
L["Set the vertical position for this display's primary icon relative to the center of the screen."] = true
L["Set to #:  |cFFFFD100/hek set %s #|r"] = true
L["Set to 0 to count all detected targets."] = true
L["Set to zero to ignore."] = true
L["Set Value If..."] = true
L["Set Value"] = true
L["set"] = true
L["setif"] = true
L["SetMode failed:  '%s' is not a valid mode."] = true
L["Settings displayed are from the Primary display (other display settings are shown in the tooltip)."] = true
L["Settings related to how enemies are identified and counted by the addon."] = true
L["Share Priorities"] = true
L["Share Styles"] = true
L["Sharing"] = true
L["Show Cooldowns"] = true
L["Show Covenants"] = true
L["Show Custom #1"] = true
L["Show Custom #2"] = true
L["Show Defensives"] = true
L["Show Icon (Color)"] = true
L["Show Interrupts"] = true
L["Show Modifiers"] = true
L["Show Potions"] = true
L["Show Separately"] = true
L["Show Text (Countdown)"] = true
L["Shown"] = true
L["Single-Target"] = true
L["Single"] = true
L["Size"] = true
L["Skeleton"] = true
L["Snapshot"] = true
L["Snapshots / Troubleshooting"] = true
L["Snapshots are logs of the addon's decision-making process for a set of recommendations."] = true
L["Snapshots only capture a specific point in time, so snapshots have to be taken at the time you saw the specific recommendations that you are concerned about."] = true
L["Snapshots saved:  %s."] = true
L["Snapshots"] = true
L["Some specialization options were reset to default; this can occur once per profile/specialization."] = true
L["Some specialization options were reset."] = true
L["soul_shards"] = true
L["Source"] = true
L["Specialization"] = true
L["Specify a Custom Color"] = true
L["Specify a descriptive name for this custom toggle."] = true
L["Specify a glow color for the SpellFlash highlight."] = true
L["Specify a name for this variable.  Variables must be lowercase with no spaces or symbols aside from the underscore."] = true
L["Specify a required toggle for this action to be used in the addon action list."] = true
L["Specify the amount of extra resources to pool in addition to what is needed for the next entry."] = true
L["Specify the brightness of the SpellFlash glow."] = true
L["Specify the buff to remove."] = true
L["Specify the height of the primary icon for each display."] = true
L["Specify the height of the primary icon for your %s Display."] = true
L["Specify the horizontal offset (in pixels) for the queue, in relation to the anchor point on the primary icon for this display."] = true
L["Specify the number of recommendations to show.  Each icon shows an additional step forward in time."] = true
L["Specify the size of the SpellFlash glow."] = true
L["Specify the time, in seconds, as a number or as an expression that evaluates to a number."] = true
L["Specify the type of indicator to use when you should wait before casting the ability."] = true
L["Specify the vertical offset (in pixels) for the queue, in relation to the anchor point on the primary icon for this display."] = true
L["Specify the width of the primary icon for each display."] = true
L["Specify the width of the primary icon for your %s Display."] = true
L["Specify whether to use Class or Custom color borders."] = true
L["Specify which abilities are controlled by each toggle keybind for this specialization."] = true
L["SpellFlash"] = true
L["ST"] = true
L["Star (Default)"] = true
L["Starburst"] = true
L["Stationary"] = true
L["Store Export String"] = true
L["Strict / Time Insensitive"] = true
L["Style Name"] = true
L["Style String"] = true
L["Style"] = true
L["sub"] = true
L["Submitting both with your issue tickets will provide useful information for investigation purposes."] = true
L["Subtract Value"] = true
L["Summary"] = true
L["SYMBOL_MILLISECOND"] = "ms"
L["SYMBOL_SECOND"] = "s"
L["Take Screenshot"] = true
L["Target"] = true
L["Targeting"] = true
L["Targets"] = true
L["Text"] = true
L["Texture"] = true
L["THANK YOU TO OUR SUPPORTERS!"] = true
L["The %s and %s priorities were updated."] = true
L["The %s priority was updated."] = true
L["The addon will only recommend this trinket (via |cff00ccff[Use Items]|r) when there are at least this many targets available to hit."] = true
L["The addon will only recommend this trinket (via |cff00ccff[Use Items]|r) when there are no more than this many targets detected."] = true
L["The addon will use the selected package when making its priority recommendations."] = true
L["The addon's recommendations are based upon the Priorities that are generally (but not exclusively) based on SimulationCraft profiles so that you can compare your performance to the results of your simulations."] = true
L["The author field is automatically filled out when creating a new Priority.  You can update it here."] = true
L["The ConsolePort button textures generally have a significant amount of blank padding around them."] = true
L["The defensive toggle is generally intended for tanking specializations, as you may want to turn on/off recommendations for damage mitigation abilities for any number of reasons during a fight."] = true
L["The following auras were used in the action list but were not found in the addon database:"] = true
L["The import for '%s' required some automated changes."] = true
L["The Import String provided could not be decompressed."] = true
L["The imported Priority has no lists included."] = true
L["The imported Priority has one action list:  %s."] = true
L["The imported Priority has the following lists included:"] = true
L["The imported Priority has two action lists:  %s and %s."] = true
L["The imported style will create the following display(s):"] = true
L["The imported style will overwrite the following display(s):"] = true
L["The Notification Panel provides brief updates when settings are changed or toggled while in combat."] = true
L["The number of AOE targets is set in your specialization's options."] = true
L["The number of targets is set in your specialization's options."] = true
L["The Primary display shows recommendations as though you have at least |cFFFFD100%d|r targets (even if fewer are detected)."] = true
L["The Primary display shows recommendations as though you have one target (even if more targets are detected)."] = true
L["The Primary display shows recommendations based upon the detected number of enemies (based on your specialization's options)."] = true
L["The Primary display shows single-target recommendations and the AOE display shows recommendations for |cFFFFD100%d|r or more targets (even if fewer are detected)."] = true
L["The Primary display shows single-target recommendations, while the AOE display remains hidden until/unless |cFFFFD100%d|r or more targets are detected."] = true
L["The profile can also be re-imported or overwritten with a newer profile."] = true
L["The stored style can be retrieved from any of your characters, even if you are using different profiles."] = true
L["The value for %1$s must be between %2$s and %3$s."] = true
L["There is already a style with the name '%s' -- overwrite it?"] = true
L["There is already an action list by that name."] = true
L["These options apply to your selected specialization."] = true
L["These settings are unavailable because the SpellFlashCore addon / library is not installed or is disabled."] = true
L["They can be customized and shared."] = true
L["Thick Outline"] = true
L["This allows you to provide text that explains this entry, which will show when you Pause and mouseover the ability to see why this entry was recommended."] = true
L["This applies only to tanking specializations."] = true
L["This automatic snapshot can only occur once per episode of combat."] = true
L["This can be a texture ID or a path to a texture file."] = true
L["This can be beneficial to avoid applying damage-over-time effects to a target that will die too quickly to be damaged by them."] = true
L["This can be helpful if the addon incorrectly detects your keybindings."] = true
L["This can be helpful when an ability is very high priority and you want the addon to prefer it over abilities that are available sooner."] = true
L["This can be useful for understanding why an ability was recommended at a particular time."] = true
L["This can cause issues for some specializations, if other abilities depend on you using |W%s|w."] = true
L["This date is automatically updated when any changes are made to the action lists for this Priority."] = true
L["This display is not currently active."] = true
L["This feature is targeted for improvement in a future update."] = true
L["This feature requires the SpellFlashCore addon or library to function properly."] = true
L["This is a default priority package.  It will be automatically updated when the addon is updated."] = true
L["This is a package of action lists for Hekili."] = true
L["This is an experimental feature and may not work well for some specializations."] = true
L["This is helpful when enemies spread out or move out of range."] = true
L["This is typically desirable for |cFFFF0000melee|r specializations."] = true
L["This is typically desirable for |cFFFF0000ranged|r specializations."] = true
L["This may give misleading target counts if your pet/minions are spread out over the battlefield."] = true
L["This may help resolve scenarios where abilities become desynchronized due to behavior differences between the Cooldowns display and your other displays."] = true
L["This may not be ideal for melee specializations, as enemies may wander away after you've applied your dots/bleeds."] = true
L["This may not be ideal, the glow may no longer be correct by that point in the future."] = true
L["This may use slightly more CPU, but can reduce the likelihood that the addon will fail to make a recommendation."] = true
L["This profile is missing support for generic trinkets.  It is recommended that every priority includes either:"] = true
L["This section shows which Abilities are enabled/disabled when you toggle each category when in this specialization."] = true
L["This setting is ignored if set to 0."] = true
L["This will also create a Snapshot that can be used for troubleshooting and error reporting."] = true
L["This works well for some specs that simply want to apply a debuff to another target (like Windwalker), but can be less-effective for specializations that are concerned with maintaining dots/debuffs based on their durations (like Affliction)."] = true
L["Time Script"] = true
L["To control your display mode (currently %s):"] = true
L["To control your toggles (|cFFFFD100cooldowns|r, |cFFFFD100covenants|r, |cFFFFD100defensives|r, |cFFFFD100interrupts|r, |cFFFFD100potions|r, |cFFFFD100custom1|r and |cFFFFD100custom2|r):"] = true
L["To create a new priority, see |cFFFFD100/hekili|r > |cFFFFD100Priorities|r."] = true
L["To create a new profile, see |cFFFFD100/hekili|r > |cFFFFD100Profiles|r."] = true
L["To modify one bit of text individually, select the Display (at left) and select the appropriate text."] = true
L["To set a |cFFFFD100number|r value, use the following commands:"] = true
L["To set a |cFFFFD100specialization toggle|r, use the following commands:"] = true
L["Toggle Defensives:  |cFFFFD100/hek set defensives|r"] = true
L["Toggle Mode:  |cFFFFD100/hek set mode|r"] = true
L["Toggle On/Off:  |cFFFFD100/hek set %s|r"] = true
L["Toggles are keybindings that you can use to direct the addon's recommendations and how they are presented."] = true
L["Toggles"] = true
L["TOOLTIP"] = "Tooltip"
L["Top Left"] = true
L["Top Right"] = true
L["Top"] = true
L["Trinket #1"] = true
L["Trinket #2"] = true
L["Troubleshooting"] = true
L["true"] = true
L["Try |cFFFFD100automatic|r, |cFFFFD100single|r, |cFFFFD100aoe|r, |cFFFFD100dual|r, or |cFFFFD100reactive|r."] = true
L["Unable to convert wait_for_cooldown,name=X to wait,sec=cooldown.X.remains; entry disabled."] = true
L["Unable to decode."] = true
L["Unable to decompress decoded string"] = true
L["Unable to deserialized decompressed string"] = true
L["Unable to make recommendation for %s #%d; triggering auto-snapshot..."] = true
L["Unable to restore Priority from the provided string."] = true
L["Unassigned"] = true
L["unassigned"] = true
L["Unchecked"] = true
L["unknown"] = true
L["Unpause"] = true
L["UNPAUSED"] = true
L["Unsupported action '%s'."] = true
L["Unsupported use_item action [%s]; entry disabled."] = true
L["Up"] = true
L["Usage: %s"] = true
L["Use |cFFFFD100/hekili priority name|r to change your current specialization's priority via command-line or macro."] = true
L["Use |cFFFFD100/hekili profile name|r to swap profiles via command-line or macro."] = true
L["Use |cFFFFD100/hekili set|r to adjust your specialization options via chat or macros."] = true
L["Use ConsolePort Buttons"] = true
L["Use Default Color"] = true
L["Use Different Settings for Queue"] = true
L["Use Items"] = true
L["Use Lowercase in Queue"] = true
L["Use Lowercase"] = true
L["Use Nameplate Detection"] = true
L["Use Off GCD"] = true
L["Use Pet-Based Detection"] = true
L["Use While Casting"] = true
L["UseItems is a reserved name."] = true
L["Utility / Interrupts"] = true
L["Valid priority |cFFFFD100name|rs are:"] = true
L["Valid profile |cFFFFD100name|rs are:"] = true
L["Value Else"] = true
L["Value"] = true
L["Values"] = true
L["Variable Name"] = true
L["Variable"] = true
L["Variables must be at least %d characters in length."] = true
L["Visibility and transparency settings in PvE / PvP."] = true
L["Visibility"] = true
L["Wait"] = true
L["Warning Identifier"] = true
L["Warning Information"] = true
L["Warnings"] = true
L["When |cFFFFD100Detect Damaged Enemies|r is checked, the addon will remember enemies until they have been ignored/undamaged for this amount of time."] = true
L["When |cffffd100Recommend Target Swaps|r is checked, this value determines which targets are counted for target swapping purposes."] = true
L["When |cFFFFD100Use Nameplate Detection|r is checked, the addon will count any enemies with visible nameplates within this radius of your character."] = true
L["When an ability is recommended some time in the future, a colored indicator or countdown timer can communicate that there is a delay."] = true
L["When borders are enabled and the Coloring Mode is set to |cFFFFD100Custom Color|r, the border will use this color."] = true
L["When checked, the addon will continue to count enemies who are taking damage from your damage over time effects (bleeds, etc.), even if they are not nearby or taking other damage from you."] = true
L["When checked, this entry will require that the player have enough energy to trigger Ferocious Bite's full damage bonus."] = true
L["When submitting your report, please include the information below (specialization, talents, traits, gear), which can be copied and pasted for your convenience."] = true
L["When target swapping is enabled, the addon may show an icon (%s) when you should use an ability on a different target."] = true
L["When the addon cannot recommend an ability at the present time, it rechecks action conditions at a few points in the future."] = true
L["When the AOE Display is shown, its recommendations will be made assuming this many targets are available."] = true
L["When toggled off, abilities are treated as unusable and the addon will pretend they are on cooldown (unless specified otherwise)."] = true
L["Width"] = true
L["X Offset"] = true
L["X"] = true
L["Y Offset"] = true
L["Y"] = true
L["You already have a \"%s\" Priority.\nOverwrite it?"] = true
L["You can also freeze the addon's recommendations using the %s binding (%s)."] = true
L["You can also import a shared export string here."] = true
L["You can copy the above string to share your selected display style settings, or use the options below to store these settings (to be retrieved at a later date)."] = true
L["You can generate snapshots by using the %s binding (%s) from the Toggles section."] = true
L["You can still manually include the item in your action lists with your own tailored criteria."] = true
L["You may want to disable this if you use Masque or other tools to skin your Hekili icons."] = true
L["You must have multiple priorities for your specialization to use this feature."] = true
L["You must provide a number value for %s (or default)."] = true
L["You must provide the priority name (case sensitive).\nValid options are"] = true
L["Your current display(s) will freeze, and you can mouseover each icon to see information about the displayed action."] = true
L["Your display options can be shared with other addon users with these export strings."] = true
L["Your display styles can be shared with other addon users with these export strings."] = true
L["Your Priorities can be shared with other addon users with these export strings."] = true
L["Zooming in removes some of this padding to help the buttons fit on the icon."] = true


------------------------------------------------------------------------
-- Dragonflight
------------------------------------------------------------------------

if isDF then
L["(not found)"] = true
L["%s does not have any Hekili modules loaded (yet).\nWatch for updates."] = true
L["^Rank (%d+)$"] = true
L["|cFFFF0000WARNING|r:  This version of Hekili is for a future version of WoW; you should reinstall for %s."] = true
L["|W100 FPS: 1 second / 100 frames = |cffffd10010|rms|w"] = true
L["|W60 FPS: 1 second / 60 frames = |cffffd10016.7|rms|w"] = true
L["Action Name"] = true
L["After certain critical combat events, recommendations will always update earlier, regardless of these settings."] = true
L["Aura"] = true
L["Button Blink"] = true
L["By default, calculations can take 80% of your frametime or 50ms, whichever is lower."] = true
L["Combat Only"] = true
L["Empower To"] = true
L["Empowerment stages are shown with additional text placed on the recommendation icon."] = true
L["Empowerment"] = true
L["Enable Action Highlight"] = true
L["Enable Overlay Glow"] = true
L["Examples"] = true
L["Flash Brightness"] = true
L["Flash Size"] = true
L["For Empowered spells, specify the empowerment level for this usage (default is max)."] = true
L["For example, in a Cooldowns display, if this is set to |cFFFFD10015|r (default), then a cooldown ability could start to appear when it has 15 seconds remaining on its cooldown and its usage conditions are met."] = true
L["Forecast Period"] = true
L["Hide OmniCC"] = true
L["If checked, the %s indicator may be displayed which means you should use the ability on a different target."] = true
L["If checked, the addon will only create flashes when you are in combat."] = true
L["If checked, the damage-based target system will only count enemies that are on screen.  If unchecked, offscreen targets can be included in target counts."] = true
L["If checked, the SpellFlash glow will not dim/brighten."] = true
L["If checked, the SpellFlash pulse (grow and shrink) animation will be suppressed."] = true
L["If checked, you may specify how frequently new recommendations can be generated, in- and out-of-combat."] = true
L["If enabled, empowerment stage text will be shown for queued empowered abilities."] = true
L["If enabled, OmniCC will be hidden from each icon oh this display."] = true
L["If enabled, the addon will apply the default highlight when the first recommended item/ability is currently queued."] = true
L["If enabled, when the first ability shown is an empowered spell, the empowerment stage of the spell will be shown."] = true
L["If recommendations take more than the alotted time, then the work will be split across multiple frames to reduce impact to your framerate."] = true
L["If set to |cffffd1000|r, then there is no maximum regardless of your frame rate."] = true
L["If set to a very short period of time, recommendations may be prevented due to having no abilities off cooldown with resource requirements and usage conditions met."] = true
L["If set too high (or to zero), updates may resolve more quickly but with possible impact to your FPS."] = true
L["If you choose to |cffffd100Set Update Time|r, you can specify the |cffffd100Maximum Update Time|r used per frame."] = true
L["If you set this value too low, it can take longer to update and may feel less responsive."] = true
L["In-Combat Period"] = true
L["Max"] = true
L["More frequent updates can utilize more CPU time, but increase responsiveness."] = true
L["New warnings were loaded in |cFFFFD100/hekili|r > |cFFFFD100Warnings|r."] = true
L["Not a valid option."] = true
L["OmniCC"] = true
L["On Screen Enemies Only"] = true
L["Out-of-Combat Period"] = true
L["Requires Enemy Nameplates"] = true
L["Set Update Period"] = true
L["Set Update Time"] = true
L["Some critical events, like generating resources, will force an update to occur earlier, regardless of this setting."] = true
L["Specify how frequently the flash should restart."] = true
L["Specify the action to cancel; the result is that the addon will allow the channel to be removed immediately."] = true
L["Specify the amount of time that the addon can look forward to generate a recommendation."] = true
L["Specify the maximum amount of time (in milliseconds) that can be used |cffffd100per frame|r when updating."] = true
L["Specifying a lower number means updates are generated more frequently, potentially using more CPU time."] = true
L["Speed"] = true
L["Stress test completed; no issues found."] = true
L["These settings will apply to |cFF00FF00ALL|r of the %s PvP trinkets."] = true
L["This can be helpful if your keybinds are detected incorrectly or is found on multiple action bars."] = true
L["To select another priority, see |cFFFFD100/hekili priority|r."] = true
L["Unable to stress test abilities and auras while in combat."] = true
L["When in-combat, each display will update its recommendations as frequently as you specify."] = true
L["When out-of-combat, each display will update its recommendations as frequently as you specify."] = true
L["Your selection will override the SpellFlash texture for all displays' flashes."] = true
end


------------------------------------------------------------------------
-- Shadowlands
------------------------------------------------------------------------

L["(Heal)"] = true
L["Phial of Serenity"] = true


------------------------------------------------------------------------
-- Battle for Azeroth
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Wrath of the Lich King
------------------------------------------------------------------------

if isWrath then
L["(inactive)"] = true
L["(no list name)"] = true
L["Abilities and Items"] = true
L["Active Priority"] = true
L["Bind: %s"] = true
L["Blink"] = true
L["Brightness"] = true
L["By default, the addon will update its recommendations immediately following |cffff0000critical|r combat events, within |cffffd1000.1|rs of routine combat events, or every |cffffd1000.5|rs."] = true
L["By default, when the addon needs to generate new recommendations, it will use up to |cffffd10010ms|r per frame or up to half a frame, whichever is lower."] = true
L["Clash Value"] = true
L["Class/Specialization"] = true
L["Combat Refresh Interval"] = true
L["Default %s"] = true
L["Default Potion"] = true
L["Disable %1$s (#%2$s) in %3$s"] = true
L["Disable %1$s in |cFFFFD100%2$s (#%3$s)|r"] = true
L["Gladiator's Badge"] = true
L["Gladiator's Emblem"] = true
L["Gladiator's Medallion"] = true
L["Global SpellFlash Settings"] = true
L["Half of 16.67 is ~|cffffd1008ms|r, so the addon could use up to ~8ms per frame until it has successfully updated its recommendations for all visible displays."] = true
L["If |cffffd100Throttle Updates|r is checked, you can specify the |cffffd100Combat Refresh Interval|r and |cff00ff00Regular Refresh Interval|r for this specialization."] = true
L["If checked, the addon may automatically swap your current priority pack based on specific conditions (like your current specialization, talents, or glyphs)."] = true
L["If checked, the SpellFlash glow will not dim and brighten for all displays."] = true
L["If checked, the SpellFlash pulse (grow and shrink) animation will be suppressed for all displays."] = true
L["If more time is needed, the work will be split across multiple frames."] = true
L["If set to (inactive), your active priority will not change."] = true
L["If set to |cffffd1000.2|rs, the addon will not provide new updates until 0.2 seconds after its last update (unless forced by a critical combat event)."] = true
L["If set to |cffffd1001.0|rs, the addon will not provide new updates until 1 second after its last update (unless forced by a combat event)."] = true
L["If set to |cffffd10010|r, then recommendations should not impact a 100 FPS system (1 second / 100 frames = 10ms)."] = true
L["If set to |cffffd10016|r, then recommendations should not impact a 60 FPS system (1 second / 60 frames = 16.7ms)."] = true
L["If set too high, the addon will do more work each frame, finishing faster but potentially impacting your FPS."] = true
L["If you choose to |cffffd100Throttle Time|r, you can specify the |cffffd100Maximum Update Time|r the addon should use per frame."] = true
L["If you do not want the addon to recommend this ability via |cff00ccff[Use Items]|r, you can disable it here."] = true
L["If you do not want this item to be recommended via this action list, check this box."] = true
L["If you get 60 FPS, that is 1 second / 60 frames, which equals equals 16.67ms."] = true
L["If you set this value too low, the addon can take more frames to update its recommendations and may feel delayed."] = true
L["If your action list has a specific entry for a certain trinket with specific criteria, you will likely want to disable the trinket here."] = true
L["In the absence of combat events, this addon will allow itself to update according to the specified interval."] = true
L["Instead of manually editing your action lists, you can enable/disable specific trinkets or require a minimum or maximum number of enemies before allowing the trinket to be used."] = true
L["Priority Selector: %s"] = true
L["Priority Selectors"] = true
L["Read the tooltips carefully, as some options can result in odd or undesirable behavior if misused."] = true
L["Recommend Target Swaps: %s"] = true
L["Regular Refresh Interval"] = true
L["Require Active Toggle"] = true
L["Resumed thread..."] = true
L["Settings"] = true
L["Specify the maximum amount of time (in milliseconds) that the addon can use |cffffd100per frame|r when updating its recommendations."] = true
L["Specifying a higher value may reduce CPU usage but will result in slower updates, though combat events will always force the addon to update more quickly."] = true
L["Specifying a higher value may reduce CPU usage but will result in slower updates, though critical combat events will always force the addon to update more quickly."] = true
L["Started thread..."] = true
L["State: %s"] = true
L["These settings allow you to make minor changes to abilities that can impact how this addon makes its recommendations."] = true
L["These settings apply to trinkets/gear that are used via the |cff00ccff[Use Items]|r action in your action lists."] = true
L["This ability is listed in the action list(s) below.  You can disable any entries here, if desired."] = true
L["This ability is used in entry #%d of the %s action list."] = true
L["This ability requires that %s is equipped."] = true
L["This can be helpful when an ability is very high priority and you want the addon to consider it a bit earlier than it would actually be ready."] = true
L["This can cause issues for some classes or specializations, if other abilities depend on you using %s."] = true
L["This item can be recommended via |cFF00CCFF[Use Items]|r in your action lists."] = true
L["This item is used in entry #%d of the %s action list."] = true
L["This usually means that there is class- or spec-specific criteria for using this item."] = true
L["Throttle Time"] = true
L["Throttle Updates"] = true
L["Trinkets/Gear"] = true
L["Unknown"] = true
L["Unnamed List"] = true
L["Usable Items"] = true
L["Use Priority Selector"] = true
L["When recommending a potion, the addon will suggest this potion unless the action list specifies otherwise."] = true
L["When routine combat events occur, the addon will update more frequently than its Regular Refresh Interval."] = true
L["You can also specify a minimum or maximum number of targets for the item to be used."] = true
L["Your selection will override the SpellFlash texture on any frame flashed by the addon.  This setting is universal to all displays."] = true
end


------------------------------------------------------------------------
-- Classes
------------------------------------------------------------------------

L["Custom priorities may ignore this setting."] = true

if isDF then
L["%s Damage Threshold"] = true
L["%s Macro"] = true
L["%s: Range Check"] = true
L["|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only."] = true
L["By default, |W%1$s|w also requires the %2$s toggle to be active."] = true
L["The %1$s, %2$s, and/or %3$s talents require the use of %4$s."] = true
L["This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk."] = true
L["This value is halved when playing solo."] = true
L["Use %s"] = true
end

if isWrath then
L["%s priority activated."] = true
L["Adjust the settings below according to your playstyle preference."] = true
L["If you have spent more points in %s than in any other tree, this priority will be automatically selected for you."] = true
L["It is always recommended that you use a simulator to determine the optimal values for these settings for your specific character."] = true
end


-- Death Knight

if isDF then
L["[Any]"] = true
L["[Wound Spender]"] = true
L["%1$s for %2$s"] = true
L["%1$s will only be recommended when you have at least this much |W%2$s|w."] = true
L["%s Requirements"] = true
L["Damage"] = true
L["Death and Decay"] = true
L["Frozen Pulse"] = true
L["If checked, %s will not be on the Defensives toggle by default."] = true
L["If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r) will try to avoid letting your %s fall off during lulls in damage."] = true
L["Requires both of the above."] = true
L["Requires incoming magic damage within the past 3 seconds."] = true
L["Requires the Defensives toggle to be active."] = true
L["Save %s"] = true
L["The default priority uses |W%1$s|w to generate |W%2$s|w regardless of whether there is incoming magic damage."] = true
L["Use %s Offensively"] = true
L["Use on cooldown if priority conditions are met."] = true
L["Using a mouseover macro makes it easier to apply %s and %s to other enemies without retargeting."] = true
L["When set above zero, the default priority can recommend %s if you've lost this percentage of your maximum health in the past 5 seconds."] = true
L["You can specify additional conditions for |W%s|w usage here."] = true
end


-- Demon Hunter

if isDF then
L["%s: %s and %s"] = true
L["%s: Filler and Movement"] = true
L["|cFFFF0000WARNING!|r  Demon Blades cannot be forecasted.\nSee /hekili > Havoc for more information."] = true
L["|cFFFF0000WARNING!|r  If using the %s talent, Fury gains from your auto-attacks will be forecast conservatively and updated when you actually gain resources."] = true
L["Disabled (default)"] = true
L["Either %s or %s"] = true
L["Failing to use |W%s|w when appropriate may impact your DPS."] = true
L["I understand that Fury generation from %s is unpredictable."] = true
L["If %1$s is not talented, then |cFFFFD100frailty_threshold_met|r will be |cFF00FF00true|r even with only one stack of %2$s."] = true
L["If %s is not talented, then |cFFFFD100frailty_threshold_met|r will always be |cFF00FF00true|r."] = true
L["If |W%s|w is not talented, its cooldown will be ignored."] = true
L["If checked, %s will not trigger a warning when entering combat."] = true
L["If set above zero, %s will not be recommended if it would leave you with fewer (fractional) charges."] = true
L["If set above zero, %s will not be recommended if it would leave you with fewer charges."] = true
L["If set above zero, the default priority will not recommend certain abilities unless you have at least this many stacks of %s on your target."] = true
L["If set to your maximum charges (2 with %1$s, 1 otherwise), |W%2$s|w will never be recommended."] = true
L["If you do not want |W%s|w to be recommended to trigger the benefit of these talents, you may want to consider a different talent build."] = true
L["If you do not want |W%s|w to be recommended to trigger these talents, you may want to consider a different talent build."] = true
L["Require %s Stacks"] = true
L["Require %s"] = true
L["Reserve %s Charges"] = true
L["These recommendations may occur with %s talented, when your other abilities are on cooldown, and/or because you are out of range of your target."] = true
L["These recommendations may occur with %s talented, when your other abilities being on cooldown, and/or because you are out of range of your target."] = true
L["This is an experimental setting.  Requiring too many stacks may result in a loss of DPS due to delaying use of your major cooldowns."] = true
L["This option does not guarantee that |W%1$s|w or |W%2$s|w will be the first recommendation after |W%3$s|w but will ensure that either/both are available immediately."] = true
L["This prediction can result in Fury spenders appearing abruptly since it was not guaranteed that you'd have enough Fury on your next melee swing."] = true
L["This requirement applies to all |W%s|w and |W%s|w recommendations, regardless of talents."] = true
L["When enabled, %1$s will |cFFFF0000NOT|r be recommended unless either %2$s or %3$s are available to quickly return to your current target."] = true
L["When enabled, %s may be recommended as a filler ability or for movement."] = true
L["You can reserve |W%1$s|w charges to ensure recommendations will always leave you with charge(s) available to use, but failing to use |W%2$s|w may ultimately cost you DPS."] = true
L["You can reserve charges of %1$s to ensure that it is always available for %2$s or |W|T1385910:0::::64:64:4:60:4:60|t |cff71d5ff%3$s (affix)|r|w procs."] = true
end


-- Druid

if isDF then
L["(Bear)"] = true
L["(Cat)"] = true
L["%s (or %s) Rage Threshold"] = true
L["%s Duration"] = true
L["%s Funnel"] = true
L["|W%s|w can only be recommended in boss fights or when you are in a group (to avoid resetting combat)."] = true
L["If checked, %1$s and %2$s are recommended more frequently even if you have talented %3$s or %4$s."] = true
L["If checked, %1$s can be recommended for |W%2$s|w players if its conditions for use are met."] = true
L["If checked, shifting between %s and %s may be recommended based on whether you're actively tanking and other conditions."] = true
L["If checked, when %1$s and %2$s are talented and %3$s is |cFFFFD100not|r talented, %4$s will be recommended over %5$s unless |W%6$s|w needs to be refreshed."] = true
L["If set above zero, %s and %s can be recommended only if you'll still have this much Rage after use."] = true
L["If set above zero, %s will not be recommended for mitigation purposes unless you've taken this much damage in the past 5 seconds (as a percentage of your total health)."] = true
L["If set above zero, %s will not be recommended if the target will die within the timeframe specified."] = true
L["If set below 100%%, |W%s|w may only be recommended if your health has dropped below the specified percentage."] = true
L["If unchecked, |W%s|w and |W%s|w abilities will be recommended based on your selected form, but swapping between forms will not be recommended."] = true
L["Incarnation"] = true
L["Requires %s"] = true
L["Requires |W|c%sno %s|r|w"] = true
L["Starsurge Empowerment (Lunar)"] = true
L["Starsurge Empowerment (Solar)"] = true
L["Taking %1$s and %2$s will result in |W%3$s|w recommendations for offensive purposes."] = true
L["These swaps may occur very frequently."] = true
L["This differs from the default SimulationCraft priority as of February 2023."] = true
L["This option helps to ensure that %s or %s are available if needed."] = true
L["Use %1$s and %2$s in %3$s Build"] = true
L["Weave %s and %s"] = true
L["Your stealth-based abilities can be used in |W%s|w, even if your action bar does not change."] = true
end

if isWrath then
L["any"] = true
L["aoe"] = true
L["Balance: General"] = true
L["Bearweaving Feral settings will change the parameters used when recommending bearshifting abilities."] = true
L["Boss Only"] = true
L["Cooldown Leeway"] = true
L["Debug"] = true
L["Default: %s"] = true
L["depending on character gear level"] = true
L["dungeon"] = true
L["Feral: Bearweaving [Experimental]"] = true
L["Feral: Ferocious Bite"] = true
L["Feral: Flowerweaving [Experimental]"] = true
L["Feral: General"] = true
L["Ferocious Bite Feral settings will change the parameters used when recommending ferocious bite."] = true
L["Flowerweaving Feral settings will change the parameters used when recommending flowerweaving abilities."] = true
L["General Balance settings will change the parameters used in the core balance rotation."] = true
L["General Feral settings will change the parameters used in the core cat rotation."] = true
L["if player stacks armor penetration"] = true
L["If you have spent more points in |T132276:0|t Feral than in any other tree and have not taken Thick Hide, this priority will be automatically selected for you."] = true
L["If you have spent more points in |T132276:0|t Feral than in any other tree and have taken Thick Hide, this priority will be automatically selected for you."] = true
L["Instance Type"] = true
L["Max Energy For Faerie Fire During Berserk"] = true
L["Maximum Energy Used For Bite During Berserk"] = true
L["Minimum Flowershift Mana"] = true
L["Minimum Group Size"] = true
L["Minimum Rip Remains For Bite"] = true
L["Minimum Roar Offset"] = true
L["Minimum Roar Remains For Bite"] = true
L["Optimize Rake Enabled"] = true
L["raid"] = true
L["Recommendation: %s"] = true
L["Recommendation:\n - 34 with T8-4PC\n - 24 without T8-4PC"] = true
L["Rip Leeway"] = true
L["Select the flowerweaving mode that determines when flowerweaving is recommended"] = true
L["Select the minimum amount of time left on lunar eclipse for consumable and cooldown recommendations"] = true
L["Select the minimum number of players present in a group before flowerweaving will be recommended"] = true
L["Select the time to die to report when targeting a training dummy"] = true
L["Select the type of instance that is required before the addon recomments your |cff00ccff[bear_lacerate]|r or |cff00ccff[bear_mangle]|r"] = true
L["Select whether or not bearweaving should be used in only boss fights, or whether it can be recommended in any engagement"] = true
L["Select whether or not bearweaving should be used"] = true
L["Select whether or not ferocious bite should be used"] = true
L["Select whether or not flowerweaving should be used"] = true
L["Selecting any will recommend bearweaving in any situation."] = true
L["Selecting AOE will recommend flowerweaving in only AOE situations. Selecting Any will recommend flowerweaving in any situation."] = true
L["Selecting party will work for a 5 person group or greater."] = true
L["Selecting raid will work for only 10 or 25 man groups."] = true
L["Sets the energy allowed for Faerie Fire recommendations during Berserk."] = true
L["Sets the energy allowed for Ferocious Bite recommendations during Berserk."] = true
L["Sets the leeway allowed when deciding whether to recommend clipping Savage Roar."] = true
L["Sets the minimum allowable mana for flowershifting"] = true
L["Sets the minimum number of seconds left on Rip when deciding whether to recommend Ferocious Bite."] = true
L["Sets the minimum number of seconds left on Savage Roar when deciding whether to recommend Ferocious Bite."] = true
L["Sets the minimum number of seconds over the current rip duration required for Savage Roar recommendations."] = true
L["Settings used for testing"] = true
L["Situation"] = true
L["There are cases where Rip falls very shortly before Roar and, due to default priorities and player reaction time, Roar falls off before the player is able to utilize their combo points."] = true
L["This leads to Roar being cast instead and having to rebuild 5CP for Rip."] = true
L["This setting helps address that by widening the rip/roar clipping window."] = true
L["Training Dummy Time To Die"] = true
L["When Berserk is down, any energy level is allowed as long as Minimum Rip and Minimum Roar settings are satisfied."] = true
L["When enabled, rake will only be suggested if it will do more damage than shred or if there is no active bleed."] = true
end


-- Evoker

if isDF then
L["%s: %s Padding"] = true
L["%s: Chain Channel"] = true
L["%s: Clip Channel"] = true
L["Deep Breath"] = true
L["If %s is not talented, this setting is ignored."] = true
L["If checked, %1$s may be recommended while already channeling |W%2$s|w, extending the channel."] = true
L["If checked, %s may be recommended if your target has an absorb shield applied."] = true
L["If checked, %s may be recommended, which will force your character to select a destination and move."] = true
L["If checked, other abilities may be recommended during %s, breaking its channel."] = true
L["If set above zero, extra time is allotted to help ensure that %1$s and %2$s are used before %3$s expires, reducing the risk that you'll fail to extend it."] = true
L["If unchecked, |W%s|w will never be recommended, which may result in lost DPS if left unused for an extended period of time."] = true
L["Unravel"] = true
end


-- Hunter

if isDF then
L["%s: %s Macro"] = true
L["|T2058007:0|t Barbed Shot Grace Period"] = true
L["Allow Focus Overcap"] = true
L["Avoid |T132127:0|t Bestial Wrath Overlap"] = true
L["Check Pet Range for |T132176:0|t Kill Command"] = true
L["During |W%1$s|w, some guides recommend using a macro to manually control your pet's attacks to empower |W%2$s|w."] = true
L["Enabling this option will allow |W%1$s|w to be recommended during %2$s without the empowerment buff active."] = true
L["If checked, the addon will not recommend |T132127:0|t Bestial Wrath if the buff is already applied."] = true
L["If checked, the addon will not recommend |T132176:0|t Kill Command if your pet is not in range of your target."] = true
L["If checked, the addon will not recommend |T135130:0|t Aimed Shot or |T132323:0|t Wailing Arrow when moving and hardcasting."] = true
L["If checked, the addon will recommend |T1376040:0|t Harpoon when you are out of range and Harpoon is available."] = true
L["If set above zero, the addon (using the default priority or |cFFFFD100barbed_shot_grace_period|r expression) will recommend |T2058007:0|t Barbed Shot up to 1 global cooldown earlier."] = true
L["In actual gameplay, this can result in trying to use Focus spenders when other important buttons (Wildfire Bomb, Kill Command) are available to push."] = true
L["In simulations, this helps to avoid wasting Focus."] = true
L["On average, enabling this feature appears to be DPS neutral vs. the default setting, but has higher variance.  Your mileage may vary."] = true
L["Prevent Hardcasts While Moving"] = true
L["Requires Pet-Based Target Detection"] = true
L["The default priority tries to avoid overcapping Focus by default."] = true
L["These macros prevent the |W%1$s|w empowerment from occurring naturally, which will prevent |W%2$s|w from being recommended."] = true
L["Use |T1376040:0|t Harpoon"] = true
end

if isWrath then
L["|T132160:0|t Swap to Aspect of the Viper for Mana"] = true
L["|T135826:0|t Suggest Explosive Trap on Single Target"] = true
L["When enabled, |T135826:0|t Explosive Trap will be suggested in single target scenarios as well as AOE."] = true
L["When enabled, the profile will suggest swapping to |T132160:0|t Aspect of the Viper at low mana."] = true
end


-- Mage

if isDF then
L["%s and %s: Instant-Only When Moving"] = true
L["%s: Manual Control"] = true
L["%s: Non-Instant Opener"] = true
L["An exception is made if %1$s is talented and active and your cast would be complete before |W%2$s|w expires."] = true
L["If checked, %1$s will recommended less often when %2$s, %3$s, and %4$s are talented."] = true
L["If checked, %s will not be recommended when you are more than 10 yards from your target."] = true
L["If checked, a non-instant %s may be recommended as an opener against bosses."] = true
L["If checked, non-instant %s and %s casts will not be recommended while you are moving."] = true
L["If checked, your pet's %s may be recommended for manual use instead of auto-cast by your pet."] = true
L["Limit %s"] = true
L["Mana Gem"] = true
L["You will need to disable its auto-cast before using this feature."] = true
end


-- Monk

if isDF then
L["%s: %s Tick %% Current Health"] = true
L["%s: %s Tick %% Maximum Health"] = true
L["%s: Check Distance"] = true
L["%s: Health %%"] = true
L["%s: Maximize %s"] = true
L["%s: Maximize Shield"] = true
L["%s: Prevent Overlap"] = true
L["%s: Require %s %%"] = true
L["%s: Required Incoming Damage"] = true
L["%s: Reserve 1 Charge for Cooldowns Toggle"] = true
L["%s: Self-Dispel"] = true
L["Disabling this option may impact your mana efficiency."] = true
L["Example:  If set to |cFFFFD10050|r, with 4 targets, |W%1$s|w will only be recommended when at least 2 targets have |W%2$s|w applied."] = true
L["Flying Serpent Kick"] = true
L["If |W%s's|w |cFFFFD100Required Toggle|r is changed from |cFF00B4FFDefault|r, this feature is disabled."] = true
L["If checked, %1$s may be recommended more frequently to build stacks of %2$s for your %3$s shield."] = true
L["If checked, %1$s may be recommended when %2$s is active if %3$s is talented."] = true
L["If checked, %1$s will not be recommended when %2$s and/or %3$s are active."] = true
L["If checked, %s can be recommended while Cooldowns are disabled, as long as you will retain 1 remaining charge."] = true
L["If checked, %s may be recommended when when you have a dispellable magic debuff."] = true
L["If checked, %s will not be recommended if your target is out of range."] = true
L["If set above zero, %1$s may be recommended only if this percentage of your identified targets are afflicted with %2$s."] = true
L["If set above zero, %1$s may be recommended when your current %2$s ticks for this percentage of your |cFFFFD100current|r effective health (or more)."] = true
L["If set above zero, %1$s may be recommended when your current %2$s ticks for this percentage of your |cFFFFD100maximum|r health (or more)."] = true
L["If set above zero, %s (and %s) may be recommended when your target is at least this far away."] = true
L["If set above zero, %s will not be recommended until your health falls below this percentage."] = true
L["If set above zero, %s will only be recommended if you have taken this percentage of your maximum health in damage in the past 3 seconds."] = true
L["If unchecked, %s will not be recommended despite generally being used as a filler ability."] = true
L["Requires %s Toggle"] = true
L["This feature is used to maximize %s damage from your guardian."] = true
L["This feature may work best with the %1$s talent, but risks leaving you without a charge of %2$s following a large spike in your %3$s."] = true
L["Unchecking this option is the same as disabling the ability via |cFFFFD100Abilities|r > |cFFFFD100|W%s|w|r > |cFFFFD100|W%s|w|r > |cFFFFD100Disable|r."] = true
end


-- Paladin

if isDF then
L["|T133192:0|t Word of Glory Health Threshold"] = true
L["|T135919:0|t Guardian of Ancient Kings Damage Threshold"] = true
L["|T236264:0|t Shield of Vengeance Damage Threshold"] = true
L["|T524354:0|t Divine Shield Damage Threshold"] = true
L["By default, your Defensives toggle must also be enabled."] = true
L["Check |T1112939:0|t Wake of Ashes Range"] = true
L["Divine Shield"] = true
L["Guardian of Ancient Kings"] = true
L["If checked, when your target is outside of |T1112939:0|t Wake of Ashes' range, it will not be recommended."] = true
L["If set above zero, |T236264:0|t Shield of Vengeance can only be recommended when you've taken the specified amount of damage in the last 5 seconds, in addition to any other criteria in the priority."] = true
L["When set above zero, the addon may recommend %s when you take this percentage of your maximum health in damage in the past 5 seconds."] = true
L["When set above zero, the addon may recommend |T133192:0|t Word of Glory when your health falls below this percentage."] = true
end

if isWrath then
L["Amount of extra time in s to give main abilities to come off CD before using Exo or Cons"] = true
L["Assigned Aura"] = true
L["Assigned Blessing"] = true
L["Disable this setting if your raid group uses another blessing management tool such as PallyPower."] = true
L["Divine Plea Threshold"] = true
L["Enable to recommend Flash of Light on spare Art of War during Exo CDs"] = true
L["Enable when using Hand of Reckoning Macros (dont display HoR when using Glyph)"] = true
L["Flash of Light on AoW"] = true
L["Holy Wrath Threshold"] = true
L["Judgement of Wisdom Threshold"] = true
L["Maintain Aura"] = true
L["Mana Upkeep settings will change mana regeneration related recommendations"] = true
L["Mana Upkeep"] = true
L["Primary Slack (s)"] = true
L["Select the Aura that should be recommended by the addon.  It is referenced as |cff00ccff[Assigned Aura]|r in your priority."] = true
L["Select the Blessing that should be recommended by the addon.  It is referenced as |cff00ccff[Assigned Blessing]|r in your priority."] = true
L["Select the minimum mana percent at which divine plea will be recommended"] = true
L["Select the minimum mana percent at which judgement of wisdom will be recommended"] = true
L["Select the minimum number of enemies before holy wrath will be prioritized higher"] = true
L["Using HoR Macros"] = true
L["When enabled, selected aura will be recommended if it is down"] = true
L["When enabled, selected blessing will be recommended if it is down."] = true
end


-- Priest

if isDF then
L["|T136149:0|t Shadow Word: Death Health Threshold"] = true
L["If checked, the addon will treat |T1035040:0|t Void Bolt's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T1386550:0|t Voidform."] = true
L["If checked, the addon will treat |T3528286:0|t Ascended Blast's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T3565449:0|t Boon of the Ascended."] = true
L["If set above zero, the addon will not recommend |T136149:0|t Shadow Word: Death while your health percentage is below this threshold."] = true
L["Pad |T1035040:0|t Void Bolt Cooldown"] = true
L["Pad |T3528286:0|t Ascended Blast Cooldown"] = true
L["This setting can help keep you from killing yourself."] = true
end

if isWrath then
L["|T136199:0|t Shadowfiend Mana Threshold"] = true
L["|T136224:0|t Mind Blast: Optimize Use"] = true
L["|T252997:0|t|T136207:0|t|T135978:0|t Apply DoTs in AOE"] = true
L["If set above zero, |T136199:0|t Shadowfiend cannot be recommended until your mana falls below this percentage."] = true
L["When enabled, the Shadow priority will only recommend |T136224:0|t Mind Blast below an internally-calculated haste threshold (vs. using |T136208:0|t Mind Flay)."] = true
L["When enabled, the Shadow priority will recommend applying DoTs to your current target in multi-target scenarios before channeling |T237565:0|t Mind Sear."] = true
end


-- Rogue

if isDF then
L["|T132089:0|t Shadowmeld when Solo"] = true
L["|T132282:0|t Ambush Regardless of Talents"] = true
L["|T132331:0|t Vanish when Solo"] = true
L["|T236340:0|t Marked for Death Combo Points"] = true
L["Allow |T132089:0|t Shadowmeld"] = true
L["Dragonflight sim profiles only use Ambush with Hidden Opportunity or Find Weakness talented; this is likely suboptimal."] = true
L["Energy % for |T132287:0|t Envenom"] = true
L["Funnel AOE -> Target"] = true
L["If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met."] = true
L["If checked, |T1373910:0|t Roll the Bones will never be recommended during |T236279:0|t Shadow Dance."] = true
L["If checked, the addon will recommend |T132282:0|t Ambush even without Hidden Opportunity or Find Weakness talented."] = true
L["If checked, the addon will recommend |T136206:0|t Adrenaline Rush before |T1373910:0|t Roll the Bones during the opener to guarantee at least 2 buffs from |T236279:0|t Loaded Dice."] = true
L["If checked, the addon's default priority list will focus on funneling damage into your primary target when multiple enemies are present."] = true
L["If checked, the default priority will recommend building combo points with |T1375677:0|t Shuriken Storm and spending on single-target finishers."] = true
L["If set above zero, the addon will pool to this Energy threshold before recommending |T132287:0|t Envenom."] = true
L["If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat)."] = true
L["Never |T1373910:0|t Roll the Bones during |T236279:0|t Shadow Dance"] = true
L["Requires |T236279:0|t Loaded Dice"] = true
L["Requires |T237284:0|t Count the Odds"] = true
L["Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat)."] = true
L["The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer."] = true
L["This is consistent with guides but is not yet reflected in the default SimulationCraft profiles as of 12 February 2023."] = true
L["Use |T136206:0|t Adrenaline Rush before |T1373910:0|t Roll the Bones (Opener)"] = true
L["Use Priority Rotation (Funnel Damage)"] = true
L["Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change."] = true
end

if isWrath then
L["General settings will change the parameters used in the core rotation."] = true
L["Maintain Expose Armor"] = true
L["When enabled, expose armor will be recommended when there is no major armor debuff up on the boss"] = true
end


-- Shaman

if isDF then
L["%s and %s Padding"] = true
L["%s Internal Cooldown"] = true
L["Burn Maelstrom before %s"] = true
L["Filler %s"] = true
L["If checked, %s or %s can be recommended your target has a dispellable magic effect."] = true
L["If checked, a filler %s may be recommended when nothing else is currently ready, even if something better will be off cooldown very soon."] = true
L["If checked, spending %1$s stacks may be recommended before using %2$s when %3$s is talented."] = true
L["If checked, the cooldown of %1$s will be shortened to help ensure that it is recommended as frequently as possible during %2$s."] = true
L["If set above 1, %s will not be recommended unless multiple targets are detected."] = true
L["If set above zero, %1$s can be recommended to relocate your %2$s when it is active, will remain active for the specified time, and you are currently out of range."] = true
L["If set above zero, %s cannot be recommended again until time has passed since it was last used, even if there are more dispellable magic effects on your target."] = true
L["Increasing this number will reduce the likelihood of wasted |W%s|w / |W%s|w stacks due to other procs taking priority, leaving you with more time to react."] = true
L["Pad %s Cooldown"] = true
L["Required Targets for %s"] = true
L["The default priority tries to avoid wasting %s and %s stacks with a grace period of 1.1 GCD per stack."] = true
L["These abilities are also on the Interrupts toggle by default."] = true
L["This feature can prevent you from being encouraged to spam your dispel endlessly against enemies with rapidly stacking magic buffs."] = true
L["This feature is damage-neutral in single-target and a slight increase in multi-target scenarios."] = true
L["This feature matches simulation profile behavior and is a small DPS increase, but has been confusing to some users."] = true
L["This feature may be disruptive if you have other totems active that you do not want to move."] = true
L["This macro will use %1$s at your feet.  It can be useful for pulling your %2$s to you if you get out of range."] = true
L["This option can be quickly accessed via the icon or addon compartment on your minimap, to quickly change it for different boss encounters."] = true
L["This setting is also found in the |cFFFFD100Abilities |cFFFFFFFF>|r Enhancement |cFFFFFFFF>|r |W%s|w|r section."] = true
L["Use %1$s for %2$s"] = true
L["Use %s or %s"] = true
L["You can also add this command to a macro for other abilities (like %s) to routinely bring your totems to your character."] = true
end

if isWrath then
L["|T136088:0|t Shamanistic Rage Threshold"] = true
L["If |T237589:0|t Thunderstorm is known, the default priority may recommend using it to regenerate mana below this threshold."] = true
L["Minimum Maelstrom Weapon Stacks"] = true
L["Sets the minimum number of Maelstrom Weapon stacks before recommending the player cast a spell"] = true
L["Single-Target |T136015:0|t Chain Lightning Mana %"] = true
L["When below the specified mana percentage, the addon may recommend using Shamanistic Rage to regenerate mana."] = true
L["When below the specified mana percentage, the default priority will not recommend |T136015:0|t Chain Lightning in single-target."] = true
end


-- Warlock

if isDF then
L["|T136082:0|t Preferred Demon"] = true
L["|T136118:0|t Corruption Macro"] = true
L["|T136139:0|t Agony Macro"] = true
L["|T136188:0|t Siphon Life Macro"] = true
L["A mouseover macro is useful for this and an example is included below."] = true
L["Funnel Damage in AOE"] = true
L["Havoc Macro"] = true
L["Havoc"] = true
L["If checked, the addon will expend |cFFFF0000more CPU|r determining when to break |T136163:0|t Drain Soul channels in favor of other spells."] = true
L["If checked, the addon will use its cleave priority to funnel damage into your primary target (via |T%1$s:0|t Chaos Bolt) instead of spending Soul Shards on |T%2$s:0|t Rain of Fire."] = true
L["If set above zero, |T2065628:0|t Summon Demonic Tyrant will not be recommended unless the specified number of imps are summoned."] = true
L["Immolate Macro"] = true
L["Immolate"] = true
L["Model |T136163:0|t Drain Soul Ticks"] = true
L["Specify which demon should be summoned if you have no active pet."] = true
L["Summon Demon"] = true
L["This can backfire horribly, letting your Felguard or Vilefiend expire when you could've extended them with Summon Demonic Tyrant."] = true
L["This is generally not worth it, but is technically more accurate."] = true
L["Using a macro makes it easier to apply your DoT effects to other targets without switching targets."] = true
L["When %1$s is shown with a %2$s indicator, the addon is recommending that you cast %3$s on a different target (without swapping)."] = true
L["Wild Imps Required"] = true
L["You may wish to change this option for different fights and scenarios, which can be done here, via the minimap button, or with |cFFFFD100/hekili toggle cleave_apl|r."] = true
end

if isWrath then
L["Ensure this setting is |cFF00FF00enabled|r if Improved Shadow Bolt is talented, you are in a group, and you are responsible for maintaining the Shadow Mastery debuff on your target."] = true
L["Group Curse"] = true
L["Group Type for Group Curse"] = true
L["Handle Improved Shadow Bolt (Shadow Mastery)"] = true
L["If Curse of Doom is selected and your target is expected to die in fewer than 65 seconds, Curse of Agony will be used instead."] = true
L["If someone else is assigned, you can |cFFFF0000disable|r this setting to remove some Shadow Bolt casts from the default priority."] = true
L["In default priorities, |cffffd100curse_grouped|r will be |cffffd100true|r when this condition is met."] = true
L["Inferno: Enabled?"] = true
L["Preferred Curse when Grouped"] = true
L["Preferred Curse when Solo"] = true
L["Select the Curse you'd like to use when playing in a group.  It is referenced as |cff00ccff[Group Curse]|r in your priority."] = true
L["Select the Curse you'd like to use when playing solo.  It is referenced as |cff00ccff[Solo Curse]|r in your priority."] = true
L["Select the type of group that is required before the addon recommends your |cff00ccff[Group Curse]|r rather than |cff00ccff[Solo Curse]|r."] = true
L["Select whether or not Inferno should be used"] = true
L["Selecting %1$s will work for a 5 person group.  Selecting %2$s will work for any larger group."] = true
L["Solo Curse"] = true
end


-- Warriror

if isDF then
L["%s Critical Threshold (Tier 30)"] = true
L["%s Damage Required"] = true
L["%s Health Percentage"] = true
L["|T135726:0|t Reserve Rage for Mitigation"] = true
L["Allow Stance Changes"] = true
L["By default, if you have four pieces of Tier 30 equipped, |W%s|w and |W%s|w will be recommended when their chance to crit is |cFFFFD10095%%|r or higher."] = true
L["Check |T132369:0|t Whirlwind Range"] = true
L["Conduit"] = true
L["For example, Battle Stance could be recommended when using offensive cooldowns, then Defensive Stance can be recommended when tanking resumes."] = true
L["However, if set too low, you may use these abilities but fail to crit."] = true
L["If |W%1$s|w is talented, these crits will proc a %2$s for additional damage."] = true
L["If checked, %s will not be recommended unless both the Damage Required |cFFFFD100and|r Health Percentage requirements are met."] = true
L["If checked, |T1377132:0|t Ignore Pain can be recommended while it is already active."] = true
L["If checked, |T236312:0|t Shockwave will only be recommended when your target is casting (and talented)."] = true
L["If checked, custom priorities can be written to recommend changing between stances."] = true
L["If checked, the addon can recommend overlapping |T132110:0|t Shield Block usage."] = true
L["If checked, the addon will recommend using |T135871:0|t Last Stand to generate rage."] = true
L["If checked, the default priority will check |cFFFFD100settings.heroic_charge|r to determine whether to use |T236171:0|t Heroic Leap + |T132337:0|t Charge together."] = true
L["If checked, when your target is outside of |T132369:0|t Whirlwind's range, it will not be recommended."] = true
L["If left unchecked, the addon will not recommend changing your stance as long as you are already in a stance."] = true
L["If set above zero, the addon will not recommend %s unless you have taken this much damage in the past 5 seconds, as a percentage of your maximum health."] = true
L["If set above zero, the addon will not recommend |T132353:0|t Revenge or |T135358:0|t Execute unless you'll be still have this much Rage afterward."] = true
L["If set below 100, the addon will not recommend %s unless your current health has fallen below this percentage."] = true
L["If set to |cFFFFD10050%%|r and your maximum health is 50,000, then the addon will only recommend %s when you've taken 25,000 damage in the past 5 seconds."] = true
L["If unchecked, the addon will only recommend |T135871:0|t Last Stand defensively after taking significant damage."] = true
L["Last Stand"] = true
L["Lowering this percentage slightly may be helpful if your base Critical Strike chance is very low."] = true
L["Only |T236312:0|t Shockwave as Interrupt (when Talented)"] = true
L["Otherwise, %s can be recommended when |cFFFFD100either|r requirement is met."] = true
L["Overlap |T132110:0|t Shield Block"] = true
L["Overlap |T1377132:0|t Ignore Pain"] = true
L["Rallying Cry"] = true
L["Require %s Damage and Health"] = true
L["Requires |T571316:0|t Unnerving Focus %s or %s."] = true
L["Shield Wall"] = true
L["Talent"] = true
L["This choice prevents the addon from endlessly recommending that you change your stance when you do not want to change it."] = true
L["This is generally a DPS increase but the erratic movement can be disruptive to smooth gameplay."] = true
L["This setting avoids leaving Shield Block at 2 charges, which wastes cooldown recovery time."] = true
L["This setting may cause you to spend more Rage on mitigation."] = true
L["Use |T135871:0|t Last Stand Offensively"] = true
L["Use Heroic Charge Combo"] = true
L["When set to |cFFFFD10035|r or higher, this feature ensures that you can always use |T1377132:0|t Ignore Pain and |T132110:0|t Shield Block when following recommendations for damage and threat."] = true
L["Your tier set, %s, and %s can bring you over the 95%% threshold."] = true
end

if isWrath then
L["Bloodthirst During Execute"] = true
L["Cooldown Threshold"] = true
L["Debuffs settings will change which debuffs are recommended"] = true
L["Debuffs"] = true
L["Enabling weaving will cause Hekili to recommend the player swaps into battle stance and rends/overpowers the target under certain conditions.\n\nApplies to Fury only"] = true
L["Execute settings will change recommendations only during execute phase"] = true
L["Execute"] = true
L["Main GCD Spell"] = true
L["Maintain Demoralizing Shout"] = true
L["Maintain Sunder Armor"] = true
L["Maximum Rage"] = true
L["Minimum Target Health"] = true
L["Optimize Overpower"] = true
L["Predict Taste For Blood"] = true
L["Preferred Shout"] = true
L["Queue During Execute"] = true
L["Queue Rage Threshold"] = true
L["Refresh Time"] = true
L["Select the maximum rage at which weaving will be recommended"] = true
L["Select the minimum target health at which weaving will be recommended"] = true
L["Select the minimum time left allowed on bloodthirst and whirlwind before weaving can be recommended"] = true
L["Select the rage threshold after which heroic strike / cleave will be recommended"] = true
L["Select the time left on an existing rend debuff at which rendweaving can be recommended"] = true
L["Select which ability should be top priority"] = true
L["Select which shout should be recommended"] = true
L["Slam Over Execute"] = true
L["Weaving"] = true
L["When enabled, Overpower will be deprioritized until the GCD before a subsequent Taste For Blood proc.\n\nApplies to Arms only."] = true
L["When enabled, recommendations will include battle stance swapping under certain conditions"] = true
L["When enabled, recommendations will include bloodthirst during the execute phase"] = true
L["When enabled, recommendations will include demoralizing shout"] = true
L["When enabled, recommendations will include heroic strike or cleave during the execute phase"] = true
L["When enabled, recommendations will include sunder armor"] = true
L["When enabled, recommendations will include whirlwind during the execute phase"] = true
L["When enabled, recommendations will prioritize slam over execute during the execute phase"] = true
L["When enabled, Taste For Blood procs will be predicted and displayed in future recommendations"] = true
L["Whirlwind During Execute"] = true
end


------------------------------------------------------------------------
-- APLs
--
-- Some characters are replaced by automated translation.
-- actions.helloworld+= --> actions.default+=
-- ; --> ,
------------------------------------------------------------------------


-- Death Knight

if isDF then
L["Frost DK"] = "Frost"
end


-- Demon Hunder

if isDF then
L["Havoc DH"] = "Havoc"
end


-- Druid

if isDF then
L["Restoration Druid"] = "Restoration"
end


-- Mage

if isDF then
L["Frost Mage"] = "Frost"
end


-- Paladin

if isDF then
L["Holy Paladin"] = "Holy"
L["Protection Paladin"] = "Protection"
end

if isWrath then
L["Holy Paladin (wowtbc.gg)"] = "Holy (wowtbc.gg)"
L["Protection Paladin (wowtbc.gg)"] = "Protection (wowtbc.gg)"
end


-- Priest

if isDF then
L["Holy Priest"] = "Holy"
end


-- Shaman

if isDF then
L["Restoration Shaman"] = "Restoration"
end


-- Warriror

if isDF then
L["Protection Warrior"] = "Protection"
end

if isWrath then
L["Protection Warrior (IV)"] = "Protection (IV)"
L["Protection Warrior (wowtbc.gg)"] = "Protection (wowtbc.gg)"
end
