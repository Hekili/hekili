# Goodbye

The Hekili Project on Retail WoW has ended with the launch of the Midnight prepatch, version 12.0, on January 20th 2026. The new direction with Blizzard's API makes it impossible to continue the addon in a way that would meet our design goals and quality standards.

### From Syrif:
Thank you for the last couple years, I've enjoyed the opportunity to learn from Hekili while helping out. I will remember the positive messages I've received from users over the years. I hope our users are able to continue to find ways to enjoy the game in Midnight and beyond.

# Old Readme below

# Hekili

**Hekili** is a powerful, highly configurable **priority helper** for **World of Warcraft**. It supports **all 🗡️DPS and 🛡️Tank specializations**. ➕Healer specializations are supported with a focus on **DPS abilities**, great for solo content or downtime during PvE.

[➡️ Latest Release](https://github.com/Hekili/hekili/releases/latest)

## ✨ What Does It Do?

Hekili helps you play more effectively by recommending which abilities to use during combat. 

Its **key feature** is the display of multiple upcoming sequential actions, allowing you to plan ahead instead of reacting to a single, constantly changing icon. This approach reduces tunnel vision and helps you stay focused on the encounter itself.

These recommendations are provided using **Action Priority List (APL) logic** inherited from [**SimulationCraft**](https://www.simulationcraft.org) and [**RaidBots**](https://www.raidbots.com/simbot). This integration helps ensure consistency between your in-game decisions and the tools you already use to optimize talents, gear, and stats. APLs are **frequently updated** to reflect changes in class balance, mechanics, and theorycrafting.

**Hekili** can help:
- Increase your damage output
- Learn and master new specializations
- Improve consistency and compare your decisions against theorycrafted simulations

## 🔧 How Does It Work?

**Hekili** uses your current character state — including cooldowns, resources, buffs/debuffs, and enemies nearby — to **simulate several spells into the future** using your spec’s APL logic. It assumes you follow its recommendations in sequence.

If you cast something else, the addon **immediately re-evaluates** your game state and updates its suggestions in real time.

Other features include:
- Optional Separate Displays for:
  - AoE abilities
  - Cooldowns
  - Defensives
  - Interrupts
    - Guides you to interrupt late in the enemy cast
    - Filter recommendations to Mythic+ priority spells
- Toggle controls for cooldowns, defensives, interrupts, potions:
  - You can manually control whether major abilities like 2-minute cooldowns are used by enabling or disabling toggle options.
  - These toggles can be bound to hotkeys or macros, giving you flexible control on a fight-by-fight basis.
  - Rather than using the toggles, you can display these abilities in a dedicated Cooldowns display, allowing you to cast them manually when timing is ideal.
  - This system is especially powerful when paired with encounter knowledge — for example, holding cooldowns for a burn phase or add wave can result in substantial DPS gains.
- Compatible with **ElvUI**, **Bartender**, and other UI mods
- Customization
  - Choose from several display styles to match your needs — from a single Automatic display to AoE-specific or dual-display setups
  - Tailor the look and feel: adjust icon size, spacing, layout, fonts, and transparency
  - Show spell keybindings on icons, or swap out the default icon for another spell or texture
  - Disable individual abilities to fit your playstyle — for example, if you prefer to macro an on-use trinket into your cooldown, you can hide that trinket from the queue entirely
  - Advanced users can edit or create their own action lists using familiar **SimulationCraft-style syntax**

## 🚀 Getting Started

### 1. **Install the Addon**

There are two main ways to install **Hekili**:

- **Addon Managers** (recommended): Automatically install and keep the addon up to date
- **Manual Download**: Install it yourself from [**GitHub Releases**](https://github.com/Hekili/hekili/releases/latest) by extracting the `.zip` to `Interface/AddOns`

#### Recommended Addon Managers
Because **Hekili** is frequently updated, we suggest using one of these trusted tools:
- [**CurseForge**](https://www.curseforge.com/download) – A widely used manager for all types of addons. We recommend the standalone desktop version for Windows or macOS to avoid extra overlays.
- [**Wago App**](https://addons.wago.io/download) – Ideal if you also use **WeakAuras**, **Plater scripts**, or other Wago-hosted content.
- [**WowUp**](https://wowup.io/) – Supports both **CurseForge** and **Wago** backends, and includes its own addon library. We suggest using the **CurseForge** version unless you use another tool to manage your WeakAuras.
- [**CurseBreaker**](https://github.com/AcidWeb/CurseBreaker) (for 💪 power users) – A lightweight command-line interface (CLI) tool that supports **Wago**, **WoWInterface**, **Tukui**, **ElvUI**, **GitHub**, and more. No extra setup is needed for **WoWInterface**-based updates.

### 2. Configure In-Game

Use the minimap icon or the command: `/hekili`

## 🛠 Need Help?

### 🐛 Bug Reports

If something isn’t working:

1. Install [**BugSack**](https://www.curseforge.com/wow/addons/bugsack) and [**BugGrabber**](https://www.curseforge.com/wow/addons/bug-grabber)
2. Reproduce the issue, generate a [**snapshot**](https://github.com/Hekili/hekili/wiki/Report-An-Issue#how-do-i-get-a-snapshot), then open BugSack to check for LUA errors
3. Submit a report on the [**Issues page**](https://github.com/Hekili/hekili/issues/new/choose), be sure to include your newly acquired snapshot and LUA errors (if applicable)

### ❓ Other Support

- Review the [**Wiki**](https://github.com/Hekili/hekili/wiki)


---

## 🙏 Credits

- Based on logic from [**SimulationCraft**](https://www.simulationcraft.org/), which is maintained by many wonderful developers and theorycrafters
- Uses libraries like [**Ace3**](https://www.wowace.com/projects/ace3), [**LibRangeCheck**](https://www.wowace.com/projects/librangecheck-2-0), and others
- Maintained by [**Hekili**](https://github.com/Hekili), [**Syrif**](https://github.com/syrifgit), [**Nerien**](https://github.com/johnnylam88) and lots of help from our community contributors

---

## 🧪 Developer Notes

If you're working on custom spec modules, improving existing logic, or contributing to the addon’s development:

- See the [**Developer Stuff**](https://github.com/Hekili/hekili/wiki/Developer-Stuff) page
- Use `/hekili` and the Snapshots tab to inspect live decision-making
- Review existing and past [**Pull Requsts**](https://github.com/Hekili/hekili/pulls)
- Review existing and past [**Issues**](https://github.com/Hekili/hekili/issues)
