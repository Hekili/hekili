local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local L = LibStub("AceLocale-3.0"):NewLocale( "Hekili", "enUS", true, debug )

L["'%1$s' is not a valid option for |cFFFFD100%2$s|r."] = true
L["'%s' is not a valid profile name.\nValid profile |cFFFFD100name|rs are:"] = true
L["(current)"] = true
L["(none)"] = true
L["(not found)"] = true
L["(not set)"] = true
L["%1$s set to %2$s."] = true
L["%1$s set to |cFF00FF00%2$s|r."] = true
L["%1$s, and %2$s."] = true
L["%1$s, if |cffffd100%2$s|r"] = true
L["%1$s|w|r is on your action bar and will be used for all your %2$s pets."] = true
L["%s - Ability: %s\n"] = true
L["%s - Aura: %s\n"] = true
L["%s |cFF00FF00ENABLED|r."] = true
L["%s |cFFFF0000DISABLED|r."] = true
L["%s does not have any Hekili modules loaded (yet).\nWatch for updates."] = true
L["%s hold removed."] = true
L["%s mode activated."] = true
L["%s placed on hold until end of combat."] = true
L["%s placed on hold."] = true
L["%s set to |cFF00B4FF%.2f|r."] = true
L["%s\n - |cFFFFD100%s|r = |cFF00FF00%.2f|r, min: %.2f, max: %.2f (%s)"] = true
L["%s\n - |cFFFFD100cycle|r, |cFFFFD100swap|r, or |cFFFFD100target_swap|r = %s|r (%s)"] = true
L["%s\n\nTo control your display mode (currently |cFFFFD100%s|r):\n - Toggle Mode:  |cFFFFD100/hek set mode|r\n - Set Mode:  |cFFFFD100/hek set mode aoe|r (or |cFFFFD100automatic|r, |cFFFFD100single|r, |cFFFFD100dual|r, |cFFFFD100reactive|r)"] = true
L["%s\n\nTo control your toggles (|cFFFFD100cooldowns|r, |cFFFFD100covenants|r, |cFFFFD100defensives|r, |cFFFFD100interrupts|r, |cFFFFD100potions|r, |cFFFFD100custom1|r and |cFFFFD100custom2|r):\n - Enable Cooldowns:  |cFFFFD100/hek set cooldowns on|r\n - Disable Interrupts:  |cFFFFD100/hek set interupts off|r\n - Toggle Defensives:  |cFFFFD100/hek set defensives|r"] = true
L["%s\n\nTo create a new priority, see |cFFFFD100/hekili|r > |cFFFFD100Priorities|r."] = true
L["%s\n\nTo create a new profile, see |cFFFFD100/hekili|r > |cFFFFD100Profiles|r."] = true
L["%s\n\nTo select another priority, see |cFFFFD100/hekili priority|r."] = true
L["%s\n\nTo set a |cFFFFD100number|r value, use the following commands:\n - Set to #:  |cFFFFD100/hek set %s #|r\n - Reset to Default:  |cFFFFD100/hek set %s default|r"] = true
L["%s\n\nTo set a |cFFFFD100specialization toggle|r, use the following commands:\n - Toggle On/Off:  |cFFFFD100/hek set %s|r\n - Enable:  |cFFFFD100/hek set %s on|r\n - Disable:  |cFFFFD100/hek set %s off|r\n - Reset to Default:  |cFFFFD100/hek set %s default|r"] = true
L["%s\nTo create a new profile, see |cFFFFD100/hekili|r > |cFFFFD100Profiles|r."] = true
L["%sSpecialization: %s\n"] = true
L["^Rank (%d+)$"] = true
L["|c%s%s|r %sCD|r %sCov|r %sInt|r"] = true
L["|c%s%s|r %sCD|r %sInt|r %sDef|r"] = true
L["|cFF00CCFFTHANK YOU TO OUR SUPPORTERS!|r\n\n%s\n\nPlease see the |cFFFFD100Issue Reporting|r tab for information about reporting bugs.\n\n"] = true
L["|cFFFF0000Requires enemy nameplates.|r"] = true
L["|cFFFF0000Requires pet ability on one of your action bars.|r"] = true
L["|cFFFF0000WARNING!|r  Pet-based target detection requires |cFFFFD100enemy nameplates|r to be enabled."] = true
L["|cFFFF0000WARNING|r: This version of Hekili is for a future version of WoW; you should reinstall for %s."] = true
L["|cFFFFD100%1$s|r toggle set to %2$s."] = true
L["|cFFFFD100Current Status|r\n\nAll specializations are currently supported, though healer priorities are experimental and focused on rotational DPS only.\n\nIf you find odd recommendations or other issues, please follow the |cFFFFD100Issue Reporting|r link below and submit all the necessary information to have your issue investigated.\n\nPlease do not submit tickets for routine priority updates (i.e., from SimulationCraft).  I will routinely update those when they are published.  Thanks!"] = true
L["|r (to toggle)"] = true
L["A rough skeleton of your current spec, for development purposes only."] = true
L["A target count indicator can be shown on the display's first recommendation."] = true
L["Abilities"] = true
L["Action Criteria"] = true
L["Action list names should be at least 2 characters in length."] = true
L["Action List"] = true
L["Action Lists are used to determine which abilities should be used at what time."] = true
L["Action Lists"] = true
L["Action Name"] = true
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
L["Allows editing of multiple displays at once.  Settings displayed are from the Primary display (other display settings are shown in the tooltip).\n\nCertain options are disabled when editing multiple displays."] = true
L["Alternative(s): "] = true
L["Anchor Point"] = true
L["Anchor To"] = true
L["and"] = true
L["AOE (Multi-Target)"] = true
L["AOE Display:  Minimum Targets"] = true
L["AOE"] = true
L["Apply Changes"] = true
L["Apply ElvUI Cooldown Style"] = true
L["Attempted to serialize an invalid display (%s)"] = true
L["Author"] = true
L["Auto Snapshot"] = true
L["Auto"] = true
L["AutoCast Shine"] = true
L["Automatic"] = true
L["Bloodlust Override"] = true
L["Border Inside"] = true
L["Border Thickness"] = true
L["Border"] = true
L["Boss Encounter Only"] = true
L["Bottom Left"] = true
L["Bottom Right"] = true
L["Bottom"] = true
L["Buff Name"] = true
L["Button Blink"] = true
L["By default, calculations can take 80% of your frametime or 50ms, whichever is lower.  If recommendations take more than the alotted time, then the work will be split across multiple frames to reduce impact to your framerate.\n\nIf you choose to |cffffd100Set Update Time|r, you can specify the |cffffd100Maximum Update Time|r used per frame."] = true
L["By storing your export string, you can save these display settings and retrieve them later if you make changes to your settings.\n\nThe stored style can be retrieved from any of your characters, even if you are using different profiles."] = true
L["Call Action List"] = true
L["Called from %s, %s, #%s."] = true
L["Cancel Action"] = true
L["Cancel Buff"] = true
L["Cancel"] = true
L["Caption"] = true
L["Captions are |cFFFF0000very|r short descriptions that can appear on the icon of a recommended ability.\n\nThis can be useful for understanding why an ability was recommended at a particular time.\n\nRequires Captions to be Enabled on each display."] = true
L["Captions are brief descriptions sometimes (rarely) used in action lists to describe why the action is shown."] = true
L["Captions should be 20 characters or less."] = true
L["Captions"] = true
L["Casting"] = true
L["ceil"] = true
L["Ceiling of Value"] = true
L["Center"] = true
L["Changes |cFF00FF00will|r be applied to the %s display."] = true
L["Changes |cFFFF0000will not|r be applied to the %s display."] = true
L["Changing the font below will modify |cFFFF0000ALL|r text on all displays.\nTo modify one bit of text individually, select the Display (at left) and select the appropriate text."] = true
L["Character Data"] = true
L["Check Movement"] = true
L["Checked"] = true
L["Circle"] = true
L["Clash"] = true
L["Class"] = true
L["Click here and press CTRL-A, CTRL-C to copy the snapshot.\n\nPaste in a text editor to review or upload to Pastebin to support an issue ticket."] = true
L["Color"] = true
L["Coloring Mode"] = true
L["Combat Only"] = true
L["Combat w/ Target"] = true
L["Combat"] = true
L["Conditions"] = true
L["ConsolePort Button Zoom"] = true
L["ConsolePort"] = true
L["Cooldown: Show Separately - Use Actual Cooldowns"] = true
L["Cooldowns Override"] = true
L["Cooldowns"] = true
L["Copy Priority"] = true
L["Core features and specialization options for %s."] = true
L["Core"] = true
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
L["Default Button Glow"] = true
L["Default displays and action lists restored."] = true
L["default"] = true
L["Default"] = true
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
L["Determines the thickness (width) of the border.  Default is |cFFFFD1001|r."] = true
L["Disable %s via |cff00ccff[Use Items]|r"] = true
L["Disable %s"] = true
L["DISABLED"] = true
L["Display Mode"] = true
L["Display Modes"] = true
L["Display not found."] = true
L["Displays are not unlocked.  Use |cFFFFD100/hek move|r or |cFFFFD100/hek unlock|r to allow click-and-drag."] = true
L["Displays"] = true
L["div"] = true
L["Divide Value"] = true
L["Don't get smart, missy."] = true
L["Down"] = true
L["Dual"] = true
L["During Channel"] = true
L["Each Priority can be shared with other addon users with these export strings.\n\nYou can also import a shared export string here."] = true
L["Empower To"] = true
L["Empowerment stages are shown with additional text placed on the recommendation icon."] = true
L["Empowerment"] = true
L["Enable Action Highlight"] = true
L["Enable Overlay Glow"] = true
L["Enable"] = true
L["Enable/disable or set the color for icon borders.\n\nYou may want to disable this if you use Masque or other tools to skin your Hekili icons."] = true
L["Enabled for Queued Icons"] = true
L["Enabled"] = true
L["ENABLED"] = true
L["Enables or disables the addon."] = true
L["Enemy nameplates are |cFF00FF00enabled|r and will be used to detect targets near your pet."] = true
L["Enhanced Recheck"] = true
L["Enter a new, unique name for this package.  Only alphanumeric characters, spaces, underscores, and apostrophes are allowed."] = true
L["Enter the horizontal position of the notification panel, relative to the center of the screen.  Negative values move the panel left; positive values move the panel right."] = true
L["Enter the vertical position of the notification panel, relative to the center of the screen.  Negative values move the panel down; positive values move the panel up."] = true
L["Entry Cooldown"] = true
L["Entry"] = true
L["Exclude Out-of-Range"] = true
L["Export Snapshot"] = true
L["Export Style"] = true
L["Export"] = true
L["Extend Spiral"] = true
L["Extra Pooling"] = true
L["Fade as Unusable"] = true
L["Fade the primary icon when you should wait before using the ability, similar to when an ability is lacking required resources."] = true
L["Filter Damaged Enemies by Range"] = true
L["Fixed Brightness"] = true
L["Fixed Dual Display"] = true
L["Fixed Size"] = true
L["Flash Brightness"] = true
L["Flash Size"] = true
L["Floor of Value"] = true
L["floor"] = true
L["Font and Style"] = true
L["Font"] = true
L["Fonts"] = true
L["For %1$s, %2$s is recommended due to its range.  It will work for all your pets."] = true
L["For Empowered spells, specify the empowerment level for this usage (default is max)."] = true
L["For pet-based detection to work, you must take an ability from your |cFF00FF00pet's spellbook|r and place it on one of |cFF00FF00your|r action bars.\n\n"] = true
L["Forecast Period"] = true
L["Frame Layer"] = true
L["Frame Level determines the display's position within its current layer.\n\nDefault value is |cFFFFD10010|r."] = true
L["Frame Level"] = true
L["Frame Strata determines which graphical layer that this display is drawn on.\n\nThe default layer is |cFFFFD100MEDIUM|r."] = true
L["Frame Strata"] = true
L["Gear and Items"] = true
L["General"] = true
L["Generate Skeleton"] = true
L["Glow Color"] = true
L["Glow Style"] = true
L["Glows"] = true
L["Grow Direction"] = true
L["Healthstone"] = true
L["Heart Essence"] = true
L["Height"] = true
L["Hekili has up to five built-in displays (identified in blue) that can display different kinds of recommendations.  The addon's recommendations are based upon the Priorities that are generally (but not exclusively) based on SimulationCraft profiles so that you can compare your performance to the results of your simulations."] = true
L["Hekili is designed for current content.\nUse below level 50 at your own risk."] = true
L["Hide Display"] = true
L["Hide Minimap Icon"] = true
L["Hide OmniCC"] = true
L["Hide When Mounted"] = true
L["Hook Criteria"] = true
L["Icon Replacement"] = true
L["Icon Size"] = true
L["Icon Spacing"] = true
L["Icon Zoom"] = true
L["Icons Shown"] = true
L["If checked and properly configured, the addon will count targets near your pet as valid targets, when your target is also within range of your pet."] = true
L["If checked, abilities from Covenants can be recommended."] = true
L["If checked, abilities linked to Custom #1 can be recommended."] = true
L["If checked, abilities linked to Custom #2 can be recommended."] = true
L["If checked, abilities marked as cooldowns can be recommended."] = true
L["If checked, abilities marked as defensives can be recommended.\n\nThis applies only to tanking specializations."] = true
L["If checked, abilities marked as interrupts can be recommended."] = true
L["If checked, abilities marked as potions can be recommended."] = true
L["If checked, cooldown abilities will be shown separately in your Cooldowns Display.\n\nThis is an experimental feature and may not work well for some specializations."] = true
L["If checked, defensive/mitigation abilities will be shown separately in your Defensives Display.\n\nThis applies only to tanking specializations."] = true
L["If checked, interrupt abilities will be shown separately in the Interrupts Display only (if enabled)."] = true
L["If checked, options are provided to fine-tune display visibility and transparency."] = true
L["If checked, some additional modifiers and conditions may be set."] = true
L["If checked, the addon will assume this entry is not time-sensitive and will not test actions in the linked priority list if criteria are not presently met."] = true
L["If checked, the addon will automatically create a snapshot whenever it failed to generate a recommendation.\n\nThis automatic snapshot can only occur once per episode of combat."] = true
L["If checked, the addon will check each available target and show whether to switch targets."] = true
L["If checked, the addon will count any enemies that you've hit (or hit you) within the past several seconds as active enemies.  This is typically desirable for |cFFFF0000ranged|r specializations."] = true
L["If checked, the addon will count any enemies with visible nameplates within a small radius of your character.  This is typically desirable for |cFFFF0000melee|r specializations."] = true
L["If checked, the addon will count enemies that your pets or minions have hit (or hit you) within the past several seconds.  This may give misleading target counts if your pet/minions are spread out over the battlefield."] = true
L["If checked, the addon will not recommend %1$s unless you are in a boss fight (or encounter).  If left unchecked, %2$s can be recommended in any type of fight."] = true
L["If checked, the addon will not recommend %1$s via [Use Items] unless you are in a boss fight (or encounter).  If left unchecked, %2$s can be recommended in any type of fight."] = true
L["If checked, the addon will not recommend |W%1$s|w unless you are in a boss fight (or encounter).  If left unchecked, |W%2$s|w can be recommended in any type of fight."] = true
L["If checked, the addon will not show this display and will make recommendations via SpellFlash only."] = true
L["If checked, the addon will only create flashes when you are in combat."] = true
L["If checked, the addon will pool resources until the next entry has enough resources to use."] = true
L["If checked, the addon will provide priority recommendations for %s based on the selected priority list."] = true
L["If checked, the addon will take a screenshot when you manually create a snapshot.\n\nSubmitting both with your issue tickets will provide useful information for investigation purposes."] = true
L["If checked, the addon will track processing time and volume of events."] = true
L["If checked, the addon's recommendations for this specialization are based on this priority package."] = true
L["If checked, the damage-based target system will only count enemies that are on screen.  If unchecked, offscreen targets can be included in target counts.\n\n"] = true
L["If checked, the Display Mode toggle can select AOE mode.\n\nThe Primary display shows recommendations as though you have at least |cFFFFD100%d|r targets (even if fewer are detected).\n\nThe number of targets is set in your specialization's options."] = true
L["If checked, the Display Mode toggle can select Automatic mode.\n\nThe Primary display shows recommendations based upon the detected number of enemies (based on your specialization's options)."] = true
L["If checked, the Display Mode toggle can select Dual Display mode.\n\nThe Primary display shows single-target recommendations and the AOE display shows recommendations for |cFFFFD100%d|r or more targets (even if fewer are detected).\n\nThe number of AOE targets is set in your specialization's options."] = true
L["If checked, the Display Mode toggle can select Reactive mode.\n\nThe Primary display shows single-target recommendations, while the AOE display remains hidden until/unless |cFFFFD100%d|r or more targets are detected."] = true
L["If checked, the Display Mode toggle can select Single-Target mode.\n\nThe Primary display shows recommendations as though you have one target (even if more targets are detected)."] = true
L["If checked, the display will not be visible when you are mounted unless you are in combat."] = true
L["If checked, the display will not be visible when you are mounted when out of combat."] = true
L["If checked, the minimap icon will be hidden."] = true
L["If checked, the primary icon's cooldown spiral will continue until the ability should be used."] = true
L["If checked, the SpellFlash glow will not dim/brighten."] = true
L["If checked, the SpellFlash pulse (grow and shrink) animation will be suppressed."] = true
L["If checked, this ability will |cffff0000NEVER|r be recommended by the addon.  This can cause issues for some specializations, if other abilities depend on you using |W%s|w."] = true
L["If checked, this entry can be checked even if the global cooldown (GCD) is active."] = true
L["If checked, this entry can be checked even if you are already casting or channeling."] = true
L["If checked, this entry can only be recommended when your character movement matches the setting."] = true
L["If checked, this entry can only be used if you are channeling another spell."] = true
L["If checked, when Bloodlust (or similar effects) are active, the addon will recommend cooldown abilities even if Show Cooldowns is not checked."] = true
L["If checked, when Cooldowns are enabled, the addon will also recommend Covenants even if Show Covenants is not checked."] = true
L["If checked, when using the Cooldown: Show Separately feature and Cooldowns are enabled, the addon will |cFFFF0000NOT|r pretend your cooldown abilities are fully on cooldown.  This may help resolve scenarios where abilities become desynchronized due to behavior differences between the Cooldowns display and your other displays.\n\nSee |cFFFFD100Toggles|r > |cFFFFD100Cooldowns|r for the |cFFFFD100Cooldown: Show Separately|r feature."] = true
L["If checked, you may specify how frequently new recommendations can be generated, in- and out-of-combat.\n\nMore frequent updates can utilize more CPU time, but increase responsiveness. After certain critical combat events, recommendations will always update earlier, regardless of these settings."] = true
L["If cycle targets is checked, the addon will check up to the specified number of targets."] = true
L["If disabled, the addon will not recommend this item via the |cff00ccff[Use Items]|r action.  You can still manually include the item in your action lists with your own tailored criteria."] = true
L["If disabled, this display will not appear under any circumstances."] = true
L["If disabled, this entry will not be shown even if its criteria are met."] = true
L["If ElvUI is installed, you can apply the ElvUI cooldown style to your queued icons.\n\nDisabling this setting requires you to reload your UI (|cFFFFD100/reload|r)."] = true
L["If enabled, abilities that have active glows (or overlays) will also glow in your queue.\n\nThis may not be ideal, the glow may no longer be correct by that point in the future."] = true
L["If enabled, descriptive captions will be shown for queued abilities, if appropriate."] = true
L["If enabled, each icon in this display will have a thin border."] = true
L["If enabled, empowerment stage text will be shown for queued empowered abilities."] = true
L["If enabled, OmniCC will be hidden from each icon oh this display."] = true
L["If enabled, small indicators for target-swapping, aura-cancellation, etc. may appear on your primary icon."] = true
L["If enabled, the addon can highlight abilities on your action bars when they are recommended for use."] = true
L["If enabled, the addon will apply the default highlight when the first recommended item/ability is currently queued."] = true
L["If enabled, the addon will place a colorful glow on the first recommended ability for this display."] = true
L["If enabled, the addon will provide a red warning highlight when you are not in range of your enemy."] = true
L["If enabled, the addon will show the number of active (or virtual) targets for this display."] = true
L["If enabled, the whole action button will fade in and out.  The default is |cFFFF0000disabled|r."] = true
L["If enabled, these indicators will appear on queued icons as well as the primary icon, when appropriate."] = true
L["If enabled, when borders are enabled, the button's border will fit inside the button (instead of around it)."] = true
L["If enabled, when the ability for the first icon has an active glow (or overlay), it will also glow in this display."] = true
L["If enabled, when the first ability shown has a descriptive caption, the caption will be shown."] = true
L["If enabled, when the first ability shown is an empowered spell, the empowerment stage of the spell will be shown."] = true
L["If non-zero, this display is shown with the specified level of opacity by default."] = true
L["If non-zero, this display is shown with the specified level of opacity in %s combat."] = true
L["If non-zero, this display is shown with the specified level of opacity when you are in combat and have an attackable %s target."] = true
L["If non-zero, this display is shown with the specified level of opacity when you have an attackable %s target."] = true
L["If set above 0, the addon will attempt to avoid counting targets that were out of range when last seen.  This is based on cached data and may be inaccurate."] = true
L["If set above zero, the addon will only allow %s to be recommended via [Use Items] if there are at least this many detected enemies.\nSet to zero to ignore."] = true
L["If set above zero, the addon will only allow %s to be recommended via [Use Items] if there are this many detected enemies (or fewer).\nSet to zero to ignore."] = true
L["If set above zero, the addon will only allow %s to be recommended, if there are at least this many detected enemies.  All other action list conditions must also be met.\nSet to zero to ignore."] = true
L["If set above zero, the addon will only allow %s to be recommended, if there are this many detected enemies (or fewer).  All other action list conditions must also be met.\nSet to zero to ignore."] = true
L["If set above zero, the addon will pretend %s has come off cooldown this much sooner than it actually has.  This can be helpful when an ability is very high priority and you want the addon to prefer it over abilities that are available sooner."] = true
L["If set, this entry can only be recommended when your movement matches the setting."] = true
L["If set, this entry cannot be recommended unless this time has passed since the last time the ability was used."] = true
L["If specified, the addon will attempt to load this texture instead of the default icon.  This can be a texture ID or a path to a texture file.\n\nLeave blank and press Enter to reset to the default icon."] = true
L["If specified, the addon will show this text in place of the auto-detected keybind text when recommending this ability.  This can be helpful if the addon incorrectly detects your keybindings."] = true
L["If specified, the addon will show this text in place of the auto-detected keybind text when recommending this ability.  This can be helpful if your keybinds are detected incorrectly or is found on multiple action bars."] = true
L["If the Priority is based on a SimulationCraft profile or a popular guide, it is a good idea to provide a link to the source (especially before sharing)."] = true
L["If this pack's action lists were imported from a SimulationCraft profile, the profile is included here."] = true
L["If this Priority was generated with a SimulationCraft profile, the profile can be stored or retrieved here.  The profile can also be re-imported or overwritten with a newer profile."] = true
L["If you are having a technical issue with the addon, please submit an issue report via the link below.  When submitting your report, please include the information below (specialization, talents, traits, gear), which can be copied and pasted for your convenience.  If you have a concern about the addon's recommendations, it is preferred that you provide a Snapshot (which will include this information) instead."] = true
L["If your primary or queued icons are not square, checking this option will prevent the icon textures from being stretched and distorted, trimming some of the texture instead."] = true
L["Import Log"] = true
L["Import Priority"] = true
L["Import String"] = true
L["Import Style"] = true
L["Import"] = true
L["Imported settings were successfully applied!\n\nClick Reset to start over, if needed."] = true
L["In-Combat Period"] = true
L["Includes anchoring, size, shape, and position settings when a display can show more than one icon."] = true
L["Includes display position, icons, primary icon size/shape, etc."] = true
L["Indicator"] = true
L["Indicators are small icons that can indicate target-swapping or (rarely) cancelling auras."] = true
L["Indicators"] = true
L["Installed Packs"] = true
L["Interrupts"] = true
L["Invalid characters entered.  Try again."] = true
L["Issue Reporting"] = true
L["Keep Aspect Ratio"] = true
L["Keybind Text"] = true
L["Keybindings should be no longer than 6 characters in length."] = true
L["Keybindings should be no longer than 20 characters in length."] = true
L["Keybinds"] = true
L["Last Updated"] = true
L["Left Bottom"] = true
L["Left Top"] = true
L["Left-click and hold to move."] = true
L["Left-click to make quick adjustments."] = true
L["Left"] = true
L["Link"] = true
L["List Name"] = true
L["Main"] = true
L["Max Cycle Targets"] = true
L["Max Energy"] = true
L["max"] = true
L["Max"] = true
L["Maximum of Values"] = true
L["Maximum Targets"] = true
L["Maximum Update Time (ms)"] = true
L["Melee Range"] = true
L["min"] = true
L["Minimum of Values"] = true
L["Minimum Target Time-to-Die"] = true
L["Minimum Targets"] = true
L["mod"] = true
L["Mode: "] = true
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
L["New warnings were loaded in |cFFFFD100/hekili|r > |cFFFFD100Warnings|r."] = true
L["No active pet."] = true
L["No displays selected to export."] = true
L["No entry #%s for that display."] = true
L["No Indicator"] = true
L["No match found for priority '%s'.\nValid options are"] = true
L["No Name"] = true
L["No queue for that display."] = true
L["No snapshots have been generated."] = true
L["No Specialization Set"] = true
L["none"] = true
L["None"] = true
L["Not a valid option."] = true
L["NOT BOUND"] = true
L["Not Set"] = true
L["nothing"] = true
L["Notification Panel"] = true
L["Notifications"] = true
L["Null Cooldown"] = true
L["OFF"] = true
L["off|r (to disable)"] = true
L["On Screen Enemies Only"] = true
L["ON"] = true
L["on|r (to enable)"] = true
L["Only alphanumeric characters and underscores can be used in list names."] = true
L["Only alphanumeric characters, spaces, parentheses, underscores, and apostrophes are allowed in pack names."] = true
L["Only alphanumeric characters, spaces, underscores, and apostrophes are allowed in pack names."] = true
L["Open and view this priority pack and its action lists."] = true
L["Open Hekili Options Panel"] = true
L["Operation"] = true
L["Options for keybinding text on displayed icons."] = true
L["Out-of-Combat Period"] = true
L["Outline"] = true
L["Override Keybind Text"] = true
L["Pack Date"] = true
L["Pack Name"] = true
L["Pack Specialization"] = true
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
L["Please specify a unique pack name."] = true
L["Pool for Next Entry (%s)"] = true
L["Pool Resource"] = true
L["Pooling Time"] = true
L["Position"] = true
L["Positioning"] = true
L["Potion"] = true
L["Potions"] = true
L["pow"] = true
L["precombat"] = true
L["Preferences for Blizzard action button glows (not SpellFlash)."] = true
L["Preferences for range-check warnings, if desired."] = true
L["Preferences"] = true
L["Press CTRL-A to select, then CTRL-C to copy."] = true
L["Pressing this binding will cycle your Display Mode through the options checked below."] = true
L["Primary Icon"] = true
L["Primary"] = true
L["Priorities (or action packs) are bundles of action lists used to make recommendations for each specialization.  They can be customized and shared.  |cFFFF0000Imported SimulationCraft priorities often require some translation before they will work with this addon.  No support is offered for customized or imported priorities.|r"] = true
L["Priorities (or action packs) are bundles of action lists used to make recommendations for each specialization."] = true
L["Priorities"] = true
L["Priority Export String"] = true
L["Priority Name"] = true
L["Priority set to %s%s|r."] = true
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
L["Require Toggle"] = true
L["Requires Enemy Nameplates"] = true
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
L["Save Style"] = true
L["Saw %s exactly %.2f seconds ago."] = true
L["Seconds"] = true
L["See the Skeleton tab for more information."] = true
L["Select a Priority pack to export."] = true
L["Select a saved Style or paste an import string in the box provided."] = true
L["Select a Saved Style"] = true
L["Select a Snapshot to export."] = true
L["Select Snapshot"] = true
L["Select the |cFFFFD100Display Modes|r that you wish to use.  Each time you press your |cFFFFD100Display Mode|r keybinding, the addon will switch to the next checked mode."] = true
L["Select the action list to view or modify."] = true
L["Select the action that will be recommended when this entry's criteria are met."] = true
L["Select the coloring mode for this glow effect.\n\nClass-colored borders will automatically change to match the class you are playing."] = true
L["Select the custom glow color for your display."] = true
L["Select the direction for the icon queue."] = true
L["Select the display style settings to export, then click Export Styles to generate an export string."] = true
L["Select the entry to modify in this action list.\n\nEntries in red are disabled, have no action set, have a conditional error, or use actions that are disabled/toggled off."] = true
L["Select the glow style for your display."] = true
L["Select the height of the queued icons."] = true
L["Select the kind of range checking and range coloring to be used by this display.\n\n|cFFFFD100Ability|r - Each ability is highlighted in red if that ability is out of range.\n\n|cFFFFD100Melee|r - All abilities are highlighted in red if you are out of melee range.\n\n|cFFFFD100Exclude|r - If an ability is not in-range, it will not be recommended."] = true
L["Select the number of pixels between icons in the queue."] = true
L["Select the point on the primary icon to which the queued icons will attach."] = true
L["Select the width of the queued icons."] = true
L["Select the zoom percentage for the icon textures in this display. (Roughly 30% will trim off the default Blizzard borders.)"] = true
L["Select your current Display Mode."] = true
L["Sephuz's Secret (ICD)"] = true
L["Set a key to make a snapshot (without pausing) that can be viewed on the Snapshots tab.  This can be useful information for testing and debugging."] = true
L["Set a key to pause processing of your action lists. Your current display(s) will freeze, and you can mouseover each icon to see information about the displayed action.\n\nThis will also create a Snapshot that can be used for troubleshooting and error reporting."] = true
L["Set a key to toggle cooldown recommendations on/off."] = true
L["Set a key to toggle Covenant recommendations on/off."] = true
L["Set a key to toggle defensive/mitigation recommendations on/off.\n\nThis applies only to tanking specializations."] = true
L["Set a key to toggle potion recommendations on/off."] = true
L["Set a key to toggle your first custom set."] = true
L["Set a key to toggle your second custom set."] = true
L["Set a key to use for toggling interrupts on/off."] = true
L["Set Default Value"] = true
L["Set profile to |cFF00FF00%s|r."] = true
L["Set the horizontal position for this display's primary icon relative to the center of the screen.  Negative values will move the display left; positive values will move it to the right."] = true
L["Set the transparency of the display when in PvE environments.  If set to 0, the display will not appear in PvE."] = true
L["Set the transparency of the display when in PvP environments.  If set to 0, the display will not appear in PvP."] = true
L["Set the vertical position for this display's primary icon relative to the center of the screen.  Negative values will move the display down; positive values will move it up."] = true
L["Set Update Period"] = true
L["Set Update Time"] = true
L["Set Value If..."] = true
L["Set Value"] = true
L["set"] = true
L["setif"] = true
L["SetMode failed:  '%s' is not a valid mode.\nTry |cFFFFD100automatic|r, |cFFFFD100single|r, |cFFFFD100aoe|r, |cFFFFD100dual|r, or |cFFFFD100reactive|r."] = true
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
L["Snapshots are logs of the addon's decision-making process for a set of recommendations.  If you have questions about -- or disagree with -- the addon's recommendations, reviewing a snapshot can help identify what factors led to the specific recommendations that you saw.\n\nSnapshots only capture a specific point in time, so snapshots have to be taken at the time you saw the specific recommendations that you are concerned about.  You can generate snapshots by using the |cffffd100Snapshot|r binding ( |cffffd100%1$s|r ) from the Toggles section.\n\nYou can also freeze the addon's recommendations using the |cffffd100Pause|r binding ( |cffffd100%2$s|r ).  Doing so will freeze the addon's recommendations, allowing you to mouseover the display and see which conditions were met to display those recommendations.  Press Pause again to unfreeze the addon.\n\nFinally, using the settings at the bottom of this panel, you can ask the addon to automatically generate a snapshot for you when no recommendations were able to be made.\n\n"] = true
L["Snapshots saved:  %s."] = true
L["Snapshots"] = true
L["Some specialization options were reset to default; this can occur once per profile/specialization."] = true
L["Some specialization options were reset."] = true
L["Source"] = true
L["Specialization"] = true
L["Specify a Custom Color"] = true
L["Specify a descriptive name for this custom toggle."] = true
L["Specify a glow color for the SpellFlash highlight."] = true
L["Specify a name for this variable.  Variables must be lowercase with no spaces or symbols aside from the underscore."] = true
L["Specify a required toggle for this action to be used in the addon action list.  When toggled off, abilities are treated as unusable and the addon will pretend they are on cooldown (unless specified otherwise)."] = true
L["Specify how frequently the flash should restart.  The default is |cFFFFD1000.4s|r."] = true
L["Specify the action to cancel; the result is that the addon will allow the channel to be removed immediately."] = true
L["Specify the amount of extra resources to pool in addition to what is needed for the next entry."] = true
L["Specify the amount of time that the addon can look forward to generate a recommendation.  For example, in a Cooldowns display, if this is set to |cFFFFD10015|r (default), then a cooldown ability could start to appear when it has 15 seconds remaining on its cooldown and its usage conditions are met.\n\nIf set to a very short period of time, recommendations may be prevented due to having no abilities off cooldown with resource requirements and usage conditions met."] = true
L["Specify the brightness of the SpellFlash glow.  The default brightness is |cFFFFD100100|r."] = true
L["Specify the buff to remove."] = true
L["Specify the height of the primary icon for each display."] = true
L["Specify the height of the primary icon for your %s Display."] = true
L["Specify the horizontal offset (in pixels) for the queue, in relation to the anchor point on the primary icon for this display.  Positive numbers move the queue to the right, negative numbers move it to the left."] = true
L["Specify the maximum amount of time (in milliseconds) that can be used |cffffd100per frame|r when updating.  If set to |cffffd1000|r, then there is no maximum regardless of your frame rate.\n\n|cffffd100Examples|r\n|W- 60 FPS: 1 second / 60 frames = |cffffd10016.7|rms|w\n|W- 100 FPS: 1 second / 100 frames = |cffffd10010|rms|w\n\nIf you set this value too low, it can take longer to update and may feel less responsive.\n\nIf set too high (or to zero), updates may resolve more quickly but with possible impact to your FPS.\n\nThe default value is |cffffd10020|rms."] = true
L["Specify the number of recommendations to show.  Each icon shows an additional step forward in time."] = true
L["Specify the size of the SpellFlash glow.  The default size is |cFFFFD100240|r."] = true
L["Specify the time, in seconds, as a number or as an expression that evaluates to a number.\nDefault is |cFFFFD1000.5|r.  An example expression would be |cFFFFD100energy.time_to_max|r."] = true
L["Specify the type of indicator to use when you should wait before casting the ability."] = true
L["Specify the vertical offset (in pixels) for the queue, in relation to the anchor point on the primary icon for this display.  Positive numbers move the queue up, negative numbers move it down."] = true
L["Specify the width of the primary icon for each display."] = true
L["Specify the width of the primary icon for your %s Display."] = true
L["Specify whether to use Class or Custom color borders.\n\nClass-colored borders will automatically change to match the class you are playing."] = true
L["Specify which abilities are controlled by each toggle keybind for this specialization."] = true
L["Speed"] = true
L["SpellFlash"] = true
L["ST"] = true
L["Star (Default)"] = true
L["Starburst"] = true
L["Stationary"] = true
L["Store Export String"] = true
L["Stress test completed; no issues found."] = true
L["Strict / Time Insensitive"] = true
L["Style Name"] = true
L["Style String"] = true
L["Style"] = true
L["sub"] = true
L["Subtract Value"] = true
L["Summary"] = true
L["Take Screenshot"] = true
L["Target"] = true
L["Targeting"] = true
L["Targets"] = true
L["Text"] = true
L["Texture"] = true
L["The %1$s, and |cFFFFD100%2$s|r priorities were updated."] = true
L["The |cFFFFD100%1$s|r and |cFFFFD100%2$s|r priorities were updated."] = true
L["The |cFFFFD100%s|r priority was updated."] = true
L["The addon will only recommend this trinket (via |cff00ccff[Use Items]|r) when there are at least this many targets available to hit."] = true
L["The addon will only recommend this trinket (via |cff00ccff[Use Items]|r) when there are no more than this many targets detected.\n\nThis setting is ignored if set to 0."] = true
L["The addon will use the selected package when making its priority recommendations."] = true
L["The author field is automatically filled out when creating a new Priority.  You can update it here."] = true
L["The ConsolePort button textures generally have a significant amount of blank padding around them. Zooming in removes some of this padding to help the buttons fit on the icon.  The default is |cFFFFD1000.6|r."] = true
L["The defensive toggle is generally intended for tanking specializations, as you may want to turn on/off recommendations for damage mitigation abilities for any number of reasons during a fight.  DPS players may want to add their own defensive abilities, but would also need to add the abilities to their own custom priority packs."] = true
L["The Import String provided could not be decompressed."] = true
L["The imported Priority has no lists included."] = true
L["The imported Priority has one action list:  %s."] = true
L["The imported Priority has the following lists included:  "] = true
L["The imported Priority has two action lists:  %1$s and %2$s."] = true
L["The imported style will create the following display(s):  "] = true
L["The imported style will overwrite the following display(s):  "] = true
L["The Notification Panel provides brief updates when settings are changed or toggled while in combat."] = true
L["The value for %1$s must be between %2$s and %3$s."] = true
L["There is already a style with the name '%s' -- overwrite it?"] = true
L["There is already an action list by that name."] = true
L["These options apply to your selected specialization."] = true
L["These settings are unavailable because the SpellFlashCore addon / library is not installed or is disabled."] = true
L["These settings will apply to |cFF00FF00ALL|r of the %s PvP trinkets."] = true
L["Thick Outline"] = true
L["This allows you to provide text that explains this entry, which will show when you Pause and mouseover the ability to see why this entry was recommended."] = true
L["This date is automatically updated when any changes are made to the action lists for this Priority."] = true
L["This display is not currently active."] = true
L["This feature requires the SpellFlashCore addon or library to function properly."] = true
L["This is a default priority package.  It will be automatically updated when the addon is updated.  If you want to customize this priority, make a copy by clicking |TInterface\\Addons\\Hekili\\Textures\\WhiteCopy:0|t.|r"] = true
L["This is a package of action lists for Hekili."] = true
L["This section shows which Abilities are enabled/disabled when you toggle each category when in this specialization.  Gear and Items can be adjusted via their own section (left).\n\nRemoving an ability from its toggle leaves it |cFF00FF00ENABLED|r regardless of whether the toggle is active."] = true
L["Time Script"] = true
L["Toggles are keybindings that you can use to direct the addon's recommendations and how they are presented."] = true
L["Toggles"] = true
L["Top Left"] = true
L["Top Right"] = true
L["Top"] = true
L["Trinket #1"] = true
L["Trinket #2"] = true
L["Troubleshooting"] = true
L["Unable to decode."] = true
L["Unable to decompress decoded string"] = true
L["Unable to deserialized decompressed string"] = true
L["Unable to make recommendation for %s #%d; triggering auto-snapshot..."] = true
L["Unable to restore Priority from the provided string."] = true
L["Unable to stress test abilities and auras while in combat."] = true
L["unassigned"] = true
L["Unassigned"] = true
L["Unchecked"] = true
L["unknown"] = true
L["Unpause"] = true
L["UNPAUSED"] = true
L["Up"] = true
L["Usage: "] = true
L["Use |cFFFFD100/hekili priority name|r to change your current specialization's priority via command-line or macro."] = true
L["Use |cFFFFD100/hekili profile name|r to swap profiles via command-line or macro.\nValid profile |cFFFFD100name|rs are:"] = true
L["Use |cFFFFD100/hekili set|r to adjust your specialization options via chat or macros.\n\nOptions for %s are:"] = true
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
L["Value Else"] = true
L["Value"] = true
L["Values"] = true
L["Variable Name"] = true
L["Variable"] = true
L["Variables must be at least 3 characters in length."] = true
L["Visibility and transparency settings in PvE / PvP."] = true
L["Visibility"] = true
L["Wait"] = true
L["Warning Identifier"] = true
L["Warning Information"] = true
L["Warnings"] = true
L["When |cFFFFD100Detect Damaged Enemies|r is checked, the addon will remember enemies until they have been ignored/undamaged for this amount of time.  Enemies will also be forgotten if they die or despawn.  This is helpful when enemies spread out or move out of range."] = true
L["When |cffffd100Recommend Target Swaps|r is checked, this value determines which targets are counted for target swapping purposes.  If set to 5, the addon will not recommend swapping to a target that will die in fewer than 5 seconds.  This can be beneficial to avoid applying damage-over-time effects to a target that will die too quickly to be damaged by them.\n\nSet to 0 to count all detected targets."] = true
L["When |cFFFFD100Use Nameplate Detection|r is checked, the addon will count any enemies with visible nameplates within this radius of your character."] = true
L["When an ability is recommended some time in the future, a colored indicator or countdown timer can communicate that there is a delay."] = true
L["When borders are enabled and the Coloring Mode is set to |cFFFFD100Custom Color|r, the border will use this color."] = true
L["When checked, the addon will continue to count enemies who are taking damage from your damage over time effects (bleeds, etc.), even if they are not nearby or taking other damage from you.\n\nThis may not be ideal for melee specializations, as enemies may wander away after you've applied your dots/bleeds.  If used with |cFFFFD100Use Nameplate Detection|r, dotted enemies that are no longer in melee range will be filtered.\n\nFor ranged specializations with damage over time effects, this should be enabled."] = true
L["When checked, this entry will require that the player have enough energy to trigger Ferocious Bite's full damage bonus."] = true
L["When in-combat, each display will update its recommendations as frequently as you specify.\n\nSpecifying a lower number means updates are generated more frequently, potentially using more CPU time.\n\nSome critical events, like generating resources, will force an update to occur earlier, regardless of this setting.\n\nDefault value:  |cffffd1000.25|rs."] = true
L["When out-of-combat, each display will update its recommendations as frequently as you specify. Specifying a lower number means updates are generated more frequently, potentially using more CPU time.\n\nSome critical events, like generating resources, will force an update to occur earlier, regardless of this setting.\n\nDefault value:  |cffffd1000.5|rs."] = true
L["When target swapping is enabled, the addon may show an icon (|TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t) when you should use an ability on a different target.  This works well for some specs that simply want to apply a debuff to another target (like Windwalker), but can be less-effective for specializations that are concerned with maintaining dots/debuffs based on their durations (like Affliction).  This feature is targeted for improvement in a future update."] = true
L["When the addon cannot recommend an ability at the present time, it rechecks action conditions at a few points in the future.  If checked, this feature will enable the addon to do additional checking on entries that use the 'variable' feature.  This may use slightly more CPU, but can reduce the likelihood that the addon will fail to make a recommendation."] = true
L["When the AOE Display is shown, its recommendations will be made assuming this many targets are available."] = true
L["Width"] = true
L["X Offset"] = true
L["X"] = true
L["Y Offset"] = true
L["Y"] = true
L["You already have a \"%s\" Priority.\nOverwrite it?"] = true
L["You can copy the above string to share your selected display style settings, or use the options below to store these settings (to be retrieved at a later date)."] = true
L["You must have multiple priorities for your specialization to use this feature."] = true
L["You must provide a number value for %s (or default)."] = true
L["You must provide the priority name (case sensitive).\nValid options are"] = true
L["Your display options can be shared with other addon users with these export strings.\n\nYou can also import a shared export string here."] = true
L["Your display styles can be shared with other addon users with these export strings.\n\nYou can also import a shared export string here."] = true
L["Your Priorities can be shared with other addon users with these export strings.\n\nYou can also import a shared export string here."] = true
L["Your selection will override the SpellFlash texture for all displays' flashes."] = true


------------------------------------------------------------------------
-- Shadowlands
------------------------------------------------------------------------

L["(Heal)"] = true
L["Phial of Serenity"] = true


------------------------------------------------------------------------
-- Dragonflight
------------------------------------------------------------------------

L["|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk."] = true

--[[ Death Knigh ]]
if UnitClassBase( "player" ) == "DEATHKNIGHT" then

L["[Any]"] = true

L["Blood"] = true
L["Save %s"] = true
L["If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r) will try to avoid letting your %s fall off during lulls in damage."] = true
L["%s Damage Threshold"] = true
L["When set above zero, the default priority can recommend %1$s if you've lost this percentage of your maximum health in the past 5 seconds.\n\n|W%2$s|w also requires the Defensives toggle by default."] = true

L["Frost DK"] = true
L["Frozen Pulse"] = true
L["%1$s for %2$s"] = true
L["%1$s will only be recommended when you have at least this much |W%2$s|w."] = true

L["Unholy"] = true
L["[Wound Spender]"] = true
L["Death and Decay"] = true
L["Use %s Offensively"] = true
L["If checked, %s will not be on the Defensives toggle by default."] = true
L["%s Macro"] = true
L["Using a mouseover macro makes it easier to apply %1$s and %2$s to other enemies without retargeting."] = true

end

--[[ Demon Hunder ]]
if UnitClassBase( "player" ) == "DEMONHUNTER" then

L["Reserve %s Charges"] = true
L["If set above zero, %s will not be recommended if it would leave you with fewer (fractional) charges."] = true
L["If set above zero, %s will not be recommended if it would leave you with fewer charges."] = true

L["Havoc"] = true
L["|cFFFF0000WARNING!|r  Demon Blades cannot be forecasted.\nSee /hekili > Havoc for more information."] = true
L["|cFFFF0000WARNING!|r  If using the %s talent, Fury gains from your auto-attacks will be forecast conservatively and updated when you actually gain resources.  This prediction can result in Fury spenders appearing abruptly since it was not guaranteed that you'd have enough Fury on your next melee swing."] = true
L["I understand that Fury generation from %s is unpredictable."] = true
L["If checked, %s will not trigger a warning when entering combat."] = true
L["The %1$s, %2$s, and/or %3$s talents require the use of %4$s.  If you do not want |W%5$s|w to be recommended to trigger these talents, you may want to consider a different talent build.\n\nYou can reserve |W%6$s|w charges to ensure recommendations will always leave you with charge(s) available to use, but failing to use |W%7$s|w may ultimately cost you DPS."] = true
L["%s: Filler and Movement"] = true
L["When enabled, %1$s may be recommended as a filler ability or for movement.\n\nThese recommendations may occur with %2$s talented, when your other abilities are on cooldown, and/or because you are out of range of your target."] = true
L["You can reserve charges of %1$s to ensure that it is always available for %2$s or |W|T1385910:0::::64:64:4:60:4:60|t |cff71d5ff%3$s (affix)|r|w procs. If set to your maximum charges (2 with %4$s, 1 otherwise), |W%5$s|w will never be recommended.  Failing to use |W%6$s|w when appropriate may impact your DPS."] = true
L["The %1$s, %2$s, and/or %3$s talents require the use of %4$s.  If you do not want |W%5$s|w to be recommended to trigger the benefit of these talents, you may want to consider a different talent build."] = true
L["%1$s: %2$s and %3$s"] = true
L["When enabled, %1$s will |cFFFF0000NOT|r be recommended unless either %2$s or %3$s are available to quickly return to your current target.  This requirement applies to all |W%4$s|w and |W%5$s|w recommendations, regardless of talents.\n\nIf |W%6$s|w is not talented, its cooldown will be ignored.\n\nThis option does not guarantee that |W%7$s|w or |W%8$s|w will be the first recommendation after |W%9$s|w but will ensure that either/both are available immediately."] = true
L["Disabled (default)"] = true
L["Require %s"] = true
L["Either %s or %s"] = true
L["When enabled, %1$s may be recommended as a filler ability or for movement.\n\nThese recommendations may occur with %2$s talented, when your other abilities being on cooldown, and/or because you are out of range of your target."] = true

L["Vengeance"] = true
L["Require %s Stacks"] = true
L["If set above zero, the default priority will not recommend certain abilities unless you have at least this many stacks of %1$s on your target.\n\nIf %2$s is not talented, then |cFFFFD100frailty_threshold_met|r will always be |cFF00FF00true|r.\n\nIf %3$s is not talented, then |cFFFFD100frailty_threshold_met|r will be |cFF00FF00true|r even with only one stack of %4$s.\n\nThis is an experimental setting.  Requiring too many stacks may result in a loss of DPS due to delaying use of your major cooldowns."] = true

end

--[[ Druid ]]
if UnitClassBase( "player" ) == "DRUID" then

L["Incarnation"] = true

L["Balance"] = true
L["Starsurge Empowerment (Lunar)"] = true
L["Starsurge Empowerment (Solar)"] = true
-- L["Cancel |T462651:0|t Starlord"] = true
-- L["If checked, the addon will recommend canceling your Starlord buff before starting to build stacks with Starsurge again.\n\nYou will likely want a |cFFFFD100/cancelaura Starlord|r macro to manage this during combat."] = true
-- L["Delay %s"] = true
-- L["If checked, the default priority will attempt to adjust the timing of %1$s to be consistent with simmed %2$s usage."] = true

L["Feral"] = true
L["(Cat)"] = true
-- L["|T136036:0|t Attempt Owlweaving (Experimental)"] = true
-- L["If checked, the addon will swap to Moonkin Form based on the default priority."] = true
-- L["|T136085:0|t Use Regrowth as Filler"] = true
-- L["If checked, the default priority will recommend |T136085:0|t Regrowth when you use the Bloodtalons talent and would otherwise be pooling Energy to retrigger Bloodtalons."] = true
L["%s Duration"] = true
L["If set above 0, %s will not be recommended if the target will die within the timeframe specified."] = true
L["%s Funnel"] = true
L["If checked, when %1$s and %2$s are talented and %3$s is |cFFFFD100not|r talented, %4$s will be recommended over %5$s unless |W%6$s|w needs to be refreshed.\n\nRequires %7$s\nRequires %8$s\nRequires |W|c%9$sno %10$s|r|w"] = true
L["Use %s"] = true
L["If checked, %1$s can be recommended for |W%2$s|w players if its conditions for use are met.\n\nYour stealth-based abilities can be used in |W%3$s|w, even if your action bar does not change. |W%4$s|w can only be recommended in boss fights or when you are in a group (to avoid resetting combat)."] = true

L["Guardian"] = true
L["(Bear)"] = true
L["%s (or %s) Rage Threshold"] = true
L["If set above zero, %1$s and %2$s can be recommended only if you'll still have this much Rage after use.\n\nThis option helps to ensure that %3$s or %4$s are available if needed."] = true
L["Use %1$s and %2$s in %3$s Build"] = true
L["If checked, %1$s and %2$s are recommended more frequently even if you have talented %3$s or %4$s.\n\nThis differs from the default SimulationCraft priority as of February 2023."] = true
-- L["Use |T132135:0|t Mangle More in Multi-Target"] = true
-- L["If checked, the default priority will recommend |T132135:0|t Mangle more often in |cFFFFD100multi-target|r scenarios.\n\nThis will generate roughly 15% more Rage and allow for more mitigation (or |T132136:0|t Maul) than otherwise, funnel slightly more damage into your primary target, but will |T134296:0|t Swipe less often, dealing less damage/threat to your secondary targets."] = true
L["%s Damage Threshold"] = true
L["If set above zero, %1$s will not be recommended for mitigation purposes unless you've taken this much damage in the past 5 seconds (as a percentage of your total health).\n\nThis value is halved when playing solo.\n\nTaking %2$s and %3$s will result in |W%4$s|w recommendations for offensive purposes."] = true
-- L["|T3636839:0|t Powershift for Convoke the Spirits"] = true
-- L["If checked, the addon will recommend swapping to Cat Form before using |T3636839:0|t Convoke the Spirits.\n\nThis is a DPS gain unless you die horribly."] = true
L["Weave %s and %s"] = true
L["If checked, shifting between %1$s and %2$s may be recommended based on whether you're actively tanking and other conditions.  These swaps may occur very frequently.\n\nIf unchecked, |W%3$s|w and |W%4$s|w abilities will be recommended based on your selected form, but swapping between forms will not be recommended."] = true
-- L["|T136036:0|t Attempt Owlweaving (Experimental)"] = true
-- L["If checked, the addon will use the experimental |cFFFFD100owlweave|r priority included in the default priority pack."] = true

L["Restoration Druid"] = true

end

--[[ Evoker ]]
if UnitClassBase( "player" ) == "EVOKER" then

L["Use %s"] = true
L["If checked, %1$s may be recommended, which will force your character to select a destination and move.  By default, %2$s requires your Cooldowns toggle to be active.\n\nIf unchecked, |W%3$s|w will never be recommended, which may result in lost DPS if left unused for an extended period of time."] = true
L["If checked, %1$s may be recommended if your target has an absorb shield applied.  By default, %2$s also requires your Interrupts toggle to be active."] = true

L["Devastation"] = true
L["%s: %s Padding"] = true
L["If set above zero, extra time is allotted to help ensure that %1$s and %2$s are used before %3$s expires, reducing the risk that you'll fail to extend it.\n\nIf %4$s is not talented, this setting is ignored."] = true
L["%s: Chain Channel"] = true
L["If checked, %1$s may be recommended while already channeling |W%2$s|w, extending the channel."] = true
L["%s: Clip Channel"] = true
L["If checked, other abilities may be recommended during %s, breaking its channel."] = true

L["Preservation"] = true
L["Deep Breath"] = true
L["Unravel"] = true

end

--[[ Hunter ]]
if UnitClassBase( "player" ) == "HUNTER" then

L["Beast Mastery"] = true
L["|T2058007:0|t Barbed Shot Grace Period"] = true
L["If set above zero, the addon (using the default priority or |cFFFFD100barbed_shot_grace_period|r expression) will recommend |T2058007:0|t Barbed Shot up to 1 global cooldown earlier."] = true
L["Avoid |T132127:0|t Bestial Wrath Overlap"] = true
L["If checked, the addon will not recommend |T132127:0|t Bestial Wrath if the buff is already applied."] = true
L["Check Pet Range for |T132176:0|t Kill Command"] = true
L["If checked, the addon will not recommend |T132176:0|t Kill Command if your pet is not in range of your target.\n\nRequires |c%sPet-Based Target Detection|r."] = true

L["Marksmanship"] = true
L["Prevent Hardcasts While Moving"] = true
L["If checked, the addon will not recommend |T135130:0|t Aimed Shot or |T132323:0|t Wailing Arrow when moving and hardcasting."] = true
-- L["Use |T132329:0|t Trueshot with |T537444:0|t Eagletalon's True Focus Runeforge"] = true
-- L["If checked, the default priority includes usage of |T132329:0|t Trueshot pre-pull, assuming you will successfully swap your legendary on your own.  The addon will not tell you to swap your gear."] = true

L["Survival"] = true
L["Use |T1376040:0|t Harpoon"] = true
L["If checked, the addon will recommend |T1376040:0|t Harpoon when you are out of range and Harpoon is available."] = true
L["Allow Focus Overcap"] = true
L["The default priority tries to avoid overcapping Focus by default.  In simulations, this helps to avoid wasting Focus.  In actual gameplay, this can result in trying to use Focus spenders when other important buttons (Wildfire Bomb, Kill Command) are available to push.  On average, enabling this feature appears to be DPS neutral vs. the default setting, but has higher variance.  Your mileage may vary.\n\nThe default setting is |cFFFFD100unchecked|r."] = true

end

--[[ Mage ]]
if UnitClassBase( "player" ) == "MAGE" then

L["%s: Range Check"] = true
L["If checked, %s will not be recommended when you are more than 10 yards from your target."] = true

L["Arcane"] = true
L["Mana Gem"] = true

L["Fire"] = true
L["%s: Non-Instant Opener"] = true
L["If checked, a non-instant %s may be recommended as an opener against bosses."] = true
L["%s and %s: Instant-Only When Moving"] = true
L["If checked, non-instant %1$s and %2$s casts will not be recommended while you are moving.\n\nAn exception is made if %3$s is talented and active and your cast would be complete before |W%4$s|w expires."] = true

L["Frost Mage"] = true
-- L["Ignore |T629077:0|t Freezing Rain in Single-Target"] = true
-- L["If checked, the default action list will not recommend using |T135857:0|t Blizzard in single-target due to the |T629077:0|t Freezing Rain talent proc."] = true
L["%s: Manual Control"] = true
L["If checked, your pet's %s may be recommended for manual use instead of auto-cast by your pet.\n\nYou will need to disable its auto-cast before using this feature."] = true

end

--[[ Monk ]]
if UnitClassBase( "player" ) == "MONK" then

L["Brewmaster"] = true
-- L["Use |T606543:0|t Spinning Crane Kick in Single-Target with |T611419:0|t Walk with the Ox"] = true
-- L["If checked, the default priority will recommend |T606543:0|t Spinning Crane Kick when |T611419:0|t Walk with the Ox is active.  This tends to reduce mitigation slightly but increase damage based on using |T627607:0|t Invoke Niuzao more frequently."] = true
L["%s: Maximize Shield"] = true
L["If checked, %1$s may be recommended more frequently to build stacks of %2$s for your %3$s shield.\n\nThis feature may work best with the %4$s talent, but risks leaving you without a charge of %5$s following a large spike in your %6$s."] = true
L["%s: Maximize %s"] = true
L["If checked, %1$s may be recommended when %2$s is active if %3$s is talented.\n\nThis feature is used to maximize %4$s damage from your guardian."] = true
L["%s: %s Tick %% Current Health"] = true
L["If set above zero, %1$s may be recommended when your current %2$s ticks for this percentage of your |cFFFFD100current|r effective health (or more).  Custom priorities may ignore this setting.\n\nThis value is halved when playing solo."] = true
L["%s: %s Tick %% Maximum Health"] = true
L["If set above zero, %1$s may be recommended when your current %2$s ticks for this percentage of your |cFFFFD100maximum|r health (or more).  Custom priorities may ignore this setting.\n\nThis value is halved when playing solo."] = true
L["%s: Require %s %%"] = true
L["If set above zero, %1$s may be recommended only if this percentage of your identified targets are afflicted with %2$s.\n\nExample:  If set to |cFFFFD10050|r, with 4 targets, |W%3$s|w will only be recommended when at least 2 targets have |W%4$s|w applied."] = true
L["%s: Health %%"] = true
L["If set above zero, %s will not be recommended until your health falls below this percentage."] = true

L["Mistweaver"] = true
L["%s: Prevent Overlap"] = true
L["If checked, %1$s will not be recommended when %2$s and/or %3$s are active.\n\nDisabling this option may impact your mana efficiency."] = true
L["%s: Check Distance"] = true
L["If set above zero, %s (and %s) may be recommended when your target is at least this far away."] = true

L["Windwalker"] = true
L["Flying Serpent Kick"] = true
L["Use %s"] = true
L["If unchecked, %1$s will not be recommended despite generally being used as a filler ability.\n\nUnchecking this option is the same as disabling the ability via |cFFFFD100Abilities|r > |cFFFFD100|W%2$s|w|r > |cFFFFD100|W%3$s|w|r > |cFFFFD100Disable|r."] = true
-- L["Optimize |T627486:0|t Reverse Harm"] = true
-- L["If checked, |T627486:0|t Reverse Harm's caption will show the recommended target's name."] = true
L["%s: Reserve 1 Charge for Cooldowns Toggle"] = true
L["If checked, %1$s can be recommended while Cooldowns are disabled, as long as you will retain 1 remaining charge.\n\nIf |W%2$s's|w |cFFFFD100Required Toggle|r is changed from |cFF00B4FFDefault|r, this feature is disabled."] = true
L["%s: Required Incoming Damage"] = true
L["If set above zero, %s will only be recommended if you have taken this percentage of your maximum health in damage in the past 3 seconds."] = true
L["%s: Check Range"] = true
L["If checked, %s will not be recommended if your target is out of range."] = true
L["%s: Self-Dispel"] = true
L["If checked, %s may be recommended when when you have a dispellable magic debuff."] = true
L["Requires %s Toggle"] = true

end

--[[ Paladin ]]
if UnitClassBase( "player" ) == "PALADIN" then

L["Holy"] = true

L["Protection Paladin"] = true
L["|T133192:0|t Word of Glory Health Threshold"] = true
L["When set above zero, the addon may recommend |T133192:0|t Word of Glory when your health falls below this percentage."] = true
L["|T135919:0|t Guardian of Ancient Kings Damage Threshold"] = true
L["When set above zero, the addon may recommend %s when you take this percentage of your maximum health in damage in the past 5 seconds.\n\nBy default, your Defensives toggle must also be enabled."] = true
L["Guardian of Ancient Kings"] = true
L["|T524354:0|t Divine Shield Damage Threshold"] = true
L["Divine Shield"] = true

L["Retribution"] = true
L["Check |T1112939:0|t Wake of Ashes Range"] = true
L["If checked, when your target is outside of |T1112939:0|t Wake of Ashes' range, it will not be recommended."] = true
L["|T236264:0|t Shield of Vengeance Damage Threshold"] = true
L["If set above zero, |T236264:0|t Shield of Vengeance can only be recommended when you've taken the specified amount of damage in the last 5 seconds, in addition to any other criteria in the priority."] = true
L["Desync |T3565448:0|t Divine Toll"] = true
L["If checked, when Seraphim, Final Reckoning, and/or Execution Sentence are toggled off or disabled, the addon will recommend |T3565448:0|t Divine Toll despite being out of sync with your cooldowns.\n\nThis is useful for maximizing the number of Divine Toll casts in a fight, but may result in a lower overall DPS."] = true

end

--[[ Priest ]]
if UnitClassBase( "player" ) == "PRIEST" then

L["|T136149:0|t Shadow Word: Death Health Threshold"] = true
L["If set above 0, the addon will not recommend |T136149:0|t Shadow Word: Death while your health percentage is below this threshold.  This setting can help keep you from killing yourself."] = true

L["Discipline"] = true

L["Holy Priest"] = true
L["Holy"] = true

L["Shadow"] = true
L["Pad |T1035040:0|t Void Bolt Cooldown"] = true
L["If checked, the addon will treat |T1035040:0|t Void Bolt's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T1386550:0|t Voidform."] = true
L["Pad |T3528286:0|t Ascended Blast Cooldown"] = true
L["If checked, the addon will treat |T3528286:0|t Ascended Blast's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during |T3565449:0|t Boon of the Ascended."] = true
L["|T237565:0|t Mind Sear Ticks"] = true
L["|T237565:0|t Mind Sear costs 25 Insanity (and 25 additional Insanity per tick).  If set above 0, this setting will treat Mind Sear as unusable if your cast would result in fewer ticks of Mind Sear than desired."] = true

end

--[[ Rogue ]]
if UnitClassBase( "player" ) == "ROGUE" then

L["|T236364:0|t Marked for Death Combo Points"] = true
L["The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer."] = true
L["Allow |T132089:0|t Shadowmeld"] = true
L["If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat)."] = true
L["Allow |T132331:0|t Vanish when Solo"] = true
L["If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat)."] = true

L["Assassination"] = true
L["Funnel AOE -> Target"] = true
L["If checked, the addon's default priority list will focus on funneling damage into your primary target when multiple enemies are present."] = true
L["Energy % for |T132287:0|t Envenom"] = true
L["If set above 0, the addon will pool to this Energy threshold before recommending |T132287:0|t Envenom."] = true

L["Outlaw"] = true
L["|T132282:0|t Ambush Regardless of Talents"] = true
L["If checked, the addon will recommend |T132282:0|t Ambush even without Hidden Opportunity or Find Weakness talented.\n\nDragonflight sim profiles only use Ambush with Hidden Opportunity or Find Weakness talented; this is likely suboptimal."] = true
L["Never |T1373910:0|t Roll the Bones during |T236279:0|t Shadow Dance"] = true
L["If checked, |T1373910:0|t Roll the Bones will never be recommended during |T236279:0|t Shadow Dance. This is consistent with guides but is not yet reflected in the default SimulationCraft profiles as of 12 February 2023.\n\n%sRequires |T237284:0|t Count the Odds|r"] = true
L["Use |T136206:0|t Adrenaline Rush before |T1373910:0|t Roll the Bones (Opener)"] = true
L["If checked, the addon will recommend |T136206:0|t Adrenaline Rush before |T1373910:0|t Roll the Bones during the opener to guarantee at least 2 buffs from |T236279:0|t Loaded Dice.\n\n%sRequires |T236279:0|t Loaded Dice|r"] = true
L["|T132089:0|t Shadowmeld when Solo"] = true
L["|T132331:0|t Vanish when Solo"] = true

L["Subtlety"] = true
L["Use Priority Rotation (Funnel Damage)"] = true
L["If checked, the default priority will recommend building combo points with |T1375677:0|t Shuriken Storm and spending on single-target finishers."] = true

end

--[[ Shaman ]]
if UnitClassBase( "player" ) == "SHAMAN" then

L["Use %s or %s"] = true
L["If checked, %s or %s can be recommended your target has a dispellable magic effect.\n\nThese abilities are also on the Interrupts toggle by default."] = true
L["%s Internal Cooldown"] = true
L["If set above zero, %s cannot be recommended again until time has passed since it was last used, even if there are more dispellable magic effects on your target.\n\nThis feature can prevent you from being encouraged to spam your dispel endlessly against enemies with rapidly stacking magic buffs."] = true

L["Elemental"] = true
L["%s and %s Padding"] = true
L["The default priority tries to avoid wasting %1$s and %2$s stacks with a grace period of 1.1 GCD per stack.\n\nIncreasing this number will reduce the likelihood of wasted |W%3$s|w / |W%4$s|w stacks due to other procs taking priority, leaving you with more time to react."] = true

L["Enhancement"] = true
L["Pad %s Cooldown"] = true
L["If checked, the cooldown of %1$s will be shortened to help ensure that it is recommended as frequently as possible during %2$s."] = true
L["Use %1$s for %2$s"] = true
L["If set above zero, %1$s can be recommended to relocate your %2$s when it is active, will remain active for the specified time, and you are currently out of range.\n\nThis feature may be disruptive if you have other totems active that you do not want to move."] = true
L["%s Macro"] = true
L["This macro will use %1$s at your feet.  It can be useful for pulling your %2$s to you if you get out of range.\n\nYou can also add this command to a macro for other abilities (like %3$s) to routinely bring your totems to your character."] = true
L["Burn Maelstrom before %s"] = true
L["If checked, spending %1$s stacks may be recommended before using %2$s when %3$s is talented.\n\nThis feature is damage-neutral in single-target and a slight increase in multi-target scenarios."] = true
L["Filler %s"] = true
L["If checked, a filler %s may be recommended when nothing else is currently ready, even if something better will be off cooldown very soon.\n\nThis feature matches simulation profile behavior and is a small DPS increase, but has been confusing to some users."] = true

L["Restoration Shaman"] = true
L["Restoration"] = true

end

--[[ Warlock ]]
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
L["|T136082:0|t Preferred Demon"] = true
L["Specify which demon should be summoned if you have no active pet."] = true
L["Funnel Damage in AOE"] = true
L["If checked, the addon will use its cleave priority to funnel damage into your primary target (via |T%s:0|t Chaos Bolt) instead of spending Soul Shards on |T%s:0|t Rain of Fire.\n\nYou may wish to change this option for different fights and scenarios, which can be done here, via the minimap button, or with |cFFFFD100/hekili toggle cleave_apl|r."] = true
-- L["Require 3+ Targets for AOE"] = true
-- L["If checked, the default action list will only use its AOE action list (including |T%s:0|t Rain of Fire) when there are 3+ targets.\n\nIn multi-target Patchwerk simulations, this setting creates a significant DPS loss.  However, this option may be useful in real-world scenarios, especially if you are fighting two moving targets that will not stand in your Rain of Fire for the whole duration."] = true
L["When %1$s is shown with a |TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t indicator, the addon is recommending that you cast %2$s on a different target (without swapping).  A mouseover macro is useful for this and an example is included below."] = true
L["Havoc"] = true
L["Havoc Macro"] = true
L["Immolate"] = true
L["Immolate Macro"] = true

end

--[[ Warriror ]]

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
