-- Classes.lua (for The War Within)

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class

-- Reflectable Spells: TWW Season 1
local reflectableFiltersTWW1 = {
    -- [ npcID ] = { desc = "...", [ spellID ] = "...", ... }
    [  40166 ] = {
        desc = "Grim Batol - Molten Giant",
        [ 451971 ] = "Lava Fist",
    },
    [  40167 ] = {
        desc = "Grim Batol - Twilight Beguiler",
        [  76369 ] = "Shadowflame Bolt",
    },
    [  40319 ] = {
        desc = "Grim Batol - Drahga Shadowburner",
        [ 447966 ] = "Shadowflame Bolt",
    },
    [ 129367 ] = {
        desc = "Siege of Boralus - Bilge Rat Tempest",
        [ 272581 ] = "Water Bolt",
    },
    [ 129370 ] = {
        desc = "Siege of Boralus - Irontide Waveshaper",
        [ 257063 ] = "Brackish Bolt",
    },
    [ 135258 ] = {
        desc = "Siege of Boralus - Irontide Curseblade",
        [ 257168 ] = "Cursed Slash",
    },
    [ 138247 ] = {
        desc = "Siege of Boralus - Irontide Curseblade",
        [ 257168 ] = "Cursed Slash",
    },
    [ 144071 ] = {
        desc = "Siege of Boralus - Irontide Waveshaper",
        [ 257063 ] = "Brackish Bolt",
    },
    [ 162693 ] = {
        desc = "The Necrotic Wake - Nalthor the Rimebinder",
        [ 323730 ] = "Frozen Binds",
    },
    [ 163126 ] = {
        desc = "The Necrotic Wake - Brittlebone Mage",
        [ 320336 ] = "Frostbolt",
    },
    [ 163128 ] = {
        desc = "The Necrotic Wake - Zolramus Sorcerer",
        [ 320462 ] = "Necrotic Bolt",
    },
    [ 163618 ] = {
        desc = "The Necrotic Wake - Zolramus Necromancer",
        [ 320462 ] = "Necrotic Bolt",
    },
    [ 164567 ] = {
        desc = "Mists of Tirna Scithe - Ingra Maloch",
        [ 323057 ] = "Spirit Bolt",
    },
    [ 164815 ] = {
        desc = "The Necrotic Wake - Zolramus Siphoner",
        [ 322274 ] = "Enfeeble",
    },
    [ 164920 ] = {
        desc = "Mists of Tirna Scithe - Drust Soulcleaver",
        [ 322557 ] = "Soul Split",
    },
    [ 164921 ] = {
        desc = "Mists of Tirna Scithe - Drust Harvester",
        [ 322767 ] = "Spirit Bolt",
        [ 326319 ] = "Spirit Bolt",
    },
    [ 164926 ] = {
        desc = "Mists of Tirna Scithe - Drust Boughbreaker",
        [ 324923 ] = "Bramble Burst",
    },
    [ 164929 ] = {
        desc = "Mists of Tirna Scithe - Tirnenn Villager",
        [ 322486 ] = "Overgrowth",
    },
    [ 165137 ] = {
        desc = "The Necrotic Wake - Zolramus Gatekeeper",
        [ 320462 ] = "Necrotic Bolt",
        [ 323347 ] = "Clinging Darkness",
    },
    [ 165824 ] = {
        desc = "The Necrotic Wake - Nar'zudah",
        [ 320462 ] = "Necrotic Bolt",
    },
    [ 166276 ] = {
        desc = "Mists of Tirna Scithe - Mistveil Guardian",
        [ 463217 ] = "Anima Slash",
    },
    [ 166302 ] = {
        desc = "The Necrotic Wake - Corpse Harvester",
        [ 334748 ] = "Drain Fluids",
    },
    [ 166304 ] = {
        desc = "Mists of Tirna Scithe - Mistveil Stinger",
        [ 325223 ] = "Anima Injection",
    },
    [ 172991 ] = {
        desc = "Mists of Tirna Scithe - Drust Soulcleaver",
        [ 322557 ] = "Soul Split",
    },
    [ 210966 ] = {
        desc = "The Dawnbreaker - Sureki Webmage",
        [ 451113 ] = "Web Bolt",
    },
    [ 212389 ] = {
        desc = "The Stonevault - Cursedheart Invader",
        [ 426283 ] = "Arcing Void",
    },
    [ 212403 ] = {
        desc = "The Stonevault - Cursedheart Invader",
        [ 426283 ] = "Arcing Void",
    },
    [ 212765 ] = {
        desc = "The Stonevault - Void Bound Despoiler",
        [ 459210 ] = "Shadow Claw",
    },
    [ 213217 ] = {
        desc = "The Stonevault - Speaker Brokk",
        [ 428161 ] = "Molten Metal",
    },
    [ 213338 ] = {
        desc = "The Stonevault - Forgebound Mender",
        [ 429110 ] = "Alloy Bolt",
    },
    [ 213892 ] = {
        desc = "The Dawnbreaker - Nightfall Shadowmage",
        [ 431303 ] = "Night Bolt",
    },
    [ 213905 ] = {
        desc = "The Dawnbreaker - Animated Darkness",
        [ 451114 ] = "Congealed Shadow",
    },
    [ 213934 ] = {
        desc = "The Dawnbreaker - Nightfall Tactician",
        [ 431494 ] = "Blace Edge",
    },
    [ 214066 ] = {
        desc = "The Stonevault - Cursedforge Stoneshaper",
        [ 429422 ] = "Stone Bolt",
    },
    [ 214350 ] = {
        desc = "The Stonevault - Turned Speaker",
        [ 429545 ] = "Censoring Gear",
    },
    [ 214761 ] = {
        desc = "The Dawnbreaker - Nightfall Ritualist",
        [ 432448 ] = "Stygian Seed",
    },
    [ 216293 ] = {
        desc = "Ara-Kara, City of Echoes - Trilling Attendant",
        [ 434786 ] = "Web Bolt",
    },
    [ 216658 ] = {
        desc = "City of Threads - Izo, the Grand Splicer",
        [ 438860 ] = "Umbral Weave",
        [ 439341 ] = "Splice",
    },
    [ 217531 ] = {
        desc = "Ara-Kara, City of Echoes - Ixin",
        [ 434786 ] = "Web Bolt",
    },
    [ 217533 ] = {
        desc = "Ara-Kara, City of Echoes - Atik",
        [ 436322 ] = "Poison Bolt",
    },
    [ 218324 ] = {
        desc = "Ara-Kara, City of Echoes - Nakt",
        [ 434786 ] = "Web Bolt",
    },
    [ 220003 ] = {
        desc = "City of Threads - Eye of the Queen",
        [ 451222 ] = "Void Rush",
    },
    [ 220195 ] = {
        desc = "City of Threads - Sureki Silkbinder",
        [ 443427 ] = "Web Bolt",
    },
    [ 221102 ] = {
        desc = "City of Threads - Elder Shadeweaver",
        [ 446717 ] = "Umbral Weave",
        [ 443427 ] = "Web Bolt",
    },
    [ 223253 ] = {
        desc = "Ara-Kara, City of Echoes - Bloodstained Webmage",
        [ 434786 ] = "Web Bolt",
    },
    [ 223844 ] = {
        desc = "City of Threads - Covert Webmancer",
        [ 442536 ] = "Grimweave Blast",
    },
    [ 223994 ] = {
        desc = "The Dawnbreaker - Nightfall Shadowmage",
        [ 431303 ] = "Night Bolt",
    },
    [ 224240 ] = {
        desc = "Grim Batol - Twilight Flamerender",
        [ 451241 ] = "Shadowflame Slash",
    },
    [ 224271 ] = {
        desc = "Grim Batol - Twilight Warlock",
        [  76369 ] = "Shadowflame Bolt",
    },
    [ 224732 ] = {
        desc = "City of Threads - Covert Webmancer",
        [ 442536 ] = "Grimweave Blast",
    },
    [ 225977 ] = {
        -- TEST
        desc = "Dornogal - Dungeoneer's Training Dummy",
        [ 167385 ] = "Uber Strike",
    },
    [ 228540 ] = {
        desc = "The Dawnbreaker - Nightfall Shadowmage",
        [ 431303 ] = "Night Bolt",
    },
}

class.reflectableFilters = reflectableFiltersTWW1
