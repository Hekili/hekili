-- ReflectableSpells.lua (for The War Within)
-- This file contains data and functions for handling reflectable spells in The War Within expansion
-- It's specifically tailored for the Warrior class and their spell reflection abilities

-- Early return if the player is not a Warrior
if UnitClassBase("player") ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[addon]
local class = Hekili.Class
local GetSpellInfo = GetSpellInfo

-- Reflectable Spells: TWW Season 1
-- This table will be populated with NPC data and their reflectable spells
local reflectableFiltersTWW1 = {}

-- npcData: A comprehensive list of NPCs and their reflectable spells
-- Format: [npcID] = {desc = "NPC Description", spells = {[spellID] = true, ...}}
-- This data structure allows for quick lookups and efficient memory usage
local npcData = {
    [40166] = {desc = "Grim Batol - Molten Giant", spells = {[451971] = true}},
    [40167] = {desc = "Grim Batol - Twilight Beguiler", spells = {[76369] = true}},
    [40319] = {desc = "Grim Batol - Drahga Shadowburner", spells = {[447966] = true}},
    [129367] = {desc = "Siege of Boralus - Bilge Rat Tempest", spells = {[272581] = true}},
    [129370] = {desc = "Siege of Boralus - Irontide Waveshaper", spells = {[257063] = true}},
    [135258] = {desc = "Siege of Boralus - Irontide Curseblade", spells = {[257168] = true}},
    [138247] = {desc = "Siege of Boralus - Irontide Curseblade", spells = {[257168] = true}},
    [144071] = {desc = "Siege of Boralus - Irontide Waveshaper", spells = {[257063] = true}},
    [162693] = {desc = "The Necrotic Wake - Nalthor the Rimebinder", spells = {[323730] = true}},
    [163126] = {desc = "The Necrotic Wake - Brittlebone Mage", spells = {[320336] = true}},
    [163128] = {desc = "The Necrotic Wake - Zolramus Sorcerer", spells = {[320462] = true}},
    [163618] = {desc = "The Necrotic Wake - Zolramus Necromancer", spells = {[320462] = true}},
    [164567] = {desc = "Mists of Tirna Scithe - Ingra Maloch", spells = {[323057] = true}},
    [164815] = {desc = "The Necrotic Wake - Zolramus Siphoner", spells = {[322274] = true}},
    [164920] = {desc = "Mists of Tirna Scithe - Drust Soulcleaver", spells = {[322557] = true}},
    [164921] = {desc = "Mists of Tirna Scithe - Drust Harvester", spells = {[322767] = true, [326319] = true}},
    [164926] = {desc = "Mists of Tirna Scithe - Drust Boughbreaker", spells = {[324923] = true}},
    [164929] = {desc = "Mists of Tirna Scithe - Tirnenn Villager", spells = {[322486] = true}},
    [165137] = {desc = "The Necrotic Wake - Zolramus Gatekeeper", spells = {[320462] = true, [323347] = true}},
    [165824] = {desc = "The Necrotic Wake - Nar'zudah", spells = {[320462] = true}},
    [166276] = {desc = "Mists of Tirna Scithe - Mistveil Guardian", spells = {[463217] = true}},
    [166302] = {desc = "The Necrotic Wake - Corpse Harvester", spells = {[334748] = true}},
    [166304] = {desc = "Mists of Tirna Scithe - Mistveil Stinger", spells = {[325223] = true}},
    [172991] = {desc = "Mists of Tirna Scithe - Drust Soulcleaver", spells = {[322557] = true}},
    [210966] = {desc = "The Dawnbreaker - Sureki Webmage", spells = {[451113] = true}},
    [212389] = {desc = "The Stonevault - Cursedheart Invader", spells = {[426283] = true}},
    [212403] = {desc = "The Stonevault - Cursedheart Invader", spells = {[426283] = true}},
    [212765] = {desc = "The Stonevault - Void Bound Despoiler", spells = {[459210] = true}},
    [213217] = {desc = "The Stonevault - Speaker Brokk", spells = {[428161] = true}},
    [213338] = {desc = "The Stonevault - Forgebound Mender", spells = {[429110] = true}},
    [213892] = {desc = "The Dawnbreaker - Nightfall Shadowmage", spells = {[431303] = true}},
    [213905] = {desc = "The Dawnbreaker - Animated Darkness", spells = {[451114] = true}},
    [213934] = {desc = "The Dawnbreaker - Nightfall Tactician", spells = {[431494] = true}},
    [214066] = {desc = "The Stonevault - Cursedforge Stoneshaper", spells = {[429422] = true}},
    [214350] = {desc = "The Stonevault - Turned Speaker", spells = {[429545] = true}},
    [214761] = {desc = "The Dawnbreaker - Nightfall Ritualist", spells = {[432448] = true}},
    [216293] = {desc = "Ara-Kara, City of Echoes - Trilling Attendant", spells = {[434786] = true}},
    [216658] = {desc = "City of Threads - Izo, the Grand Splicer", spells = {[438860] = true, [439341] = true}},
    [217531] = {desc = "Ara-Kara, City of Echoes - Ixin", spells = {[434786] = true}},
    [217533] = {desc = "Ara-Kara, City of Echoes - Atik", spells = {[436322] = true}},
    [218324] = {desc = "Ara-Kara, City of Echoes - Nakt", spells = {[434786] = true}},
    [220003] = {desc = "City of Threads - Eye of the Queen", spells = {[451222] = true}},
    [220195] = {desc = "City of Threads - Sureki Silkbinder", spells = {[443427] = true}},
    [221102] = {desc = "City of Threads - Elder Shadeweaver", spells = {[446717] = true, [443427] = true}},
    [223253] = {desc = "Ara-Kara, City of Echoes - Bloodstained Webmage", spells = {[434786] = true}},
    [223844] = {desc = "City of Threads - Covert Webmancer", spells = {[442536] = true}},
    [223994] = {desc = "The Dawnbreaker - Nightfall Shadowmage", spells = {[431303] = true}},
    [224240] = {desc = "Grim Batol - Twilight Flamerender", spells = {[451241] = true}},
    [224271] = {desc = "Grim Batol - Twilight Warlock", spells = {[76369] = true}},
    [224732] = {desc = "City of Threads - Covert Webmancer", spells = {[442536] = true}},
    [225977] = {desc = "Dornogal - Dungeoneer's Training Dummy", spells = {[167385] = true}},
    [228540] = {desc = "The Dawnbreaker - Nightfall Shadowmage", spells = {[431303] = true}},
    
    -- Nerub'ar Palace
    [203669] = {desc = "Nerub'ar Palace - Rasha'nan", spells = {[436996] = true}}, -- Stalking Shadows
    [201792] = {desc = "Nerub'ar Palace - Nexus-Princess Ky'veza", spells = {
        [437839] = true, -- Nether Rift
        [436787] = true, -- Regicide
        [436996] = true  -- Stalking Shadows
    }},
    [201793] = {desc = "Nerub'ar Palace - The Silken Court", spells = {
        [438200] = true, -- Poison Bolt
        [441772] = true  -- Void Bolt
    }},
    [201794] = {desc = "Nerub'ar Palace - Queen Ansurek", spells = {
        [451600] = true, -- Expulsion Beam
        [439865] = true  -- Silken Tomb
    }},
}

-- Create a reverse lookup table for quick spell-to-NPC mapping
-- This improves performance when checking if a spell is reflectable
local spellToNPC = {}
for npcID, data in pairs(npcData) do
    for spellID in pairs(data.spells) do
        spellToNPC[spellID] = npcID
    end
end

-- Spell Info Cache: Improves performance by caching GetSpellInfo results
-- Uses a metatable for lazy loading and error handling
local spellInfoCache = setmetatable({}, {
    __index = function(t, spellID)
        local spellName = GetSpellInfo(spellID)
        if not spellName then
            spellName = "Unknown Spell"
            Hekili:Error("Unable to get spell info for spellID: " .. tostring(spellID))
        end
        t[spellID] = spellName
        return spellName
    end
})

-- Metatable for reflectableFiltersTWW1: Provides lazy loading and caching of NPC spell data
-- This reduces memory usage and improves performance for large datasets
setmetatable(reflectableFiltersTWW1, {
    __index = function(t, k)
        local npcInfo = npcData[k]
        if not npcInfo then return {desc = "Unknown NPC"} end
        
        local result = {desc = npcInfo.desc}
        for spellID in pairs(npcInfo.spells) do
            result[spellID] = spellInfoCache[spellID]
        end
        
        t[k] = result
        return result
    end
})

-- Core Functions:
-- These functions provide the main functionality for working with reflectable spells

-- Checks if a given spell ID is reflectable
local function isSpellReflectable(spellID)
    return spellToNPC[spellID] ~= nil
end

-- Retrieves NPC info based on a spell ID
local function getNPCInfoBySpellID(spellID)
    return npcData[spellToNPC[spellID]]
end

-- Returns the entire spellToNPC table for external use
local function getReflectableSpellIDs()
    return spellToNPC
end

-- Checks if an NPC has any reflectable spells
local function hasReflectableSpells(npcID)
    return npcData[npcID] ~= nil
end

-- Retrieves all reflectable spells for a given NPC
local function getReflectableSpellsForNPC(npcID)
    local npcInfo = npcData[npcID]
    if not npcInfo then return nil end
    
    return { unpack(npcInfo.spells) }
end

-- Preloads spell info for all reflectable spells
-- This function can be called to warm up the cache and catch any errors early
local function preloadSpellInfo()
    local totalSpells, loadedSpells, errorCount = 0, 0, 0
    
    for _, data in pairs(npcData) do
        totalSpells = totalSpells + #data.spells
    end
    
    for _, data in pairs(npcData) do
        for spellID in pairs(data.spells) do
            local success, result = pcall(function() return spellInfoCache[spellID] end)
            loadedSpells = loadedSpells + 1
            if not success then
                errorCount = errorCount + 1
                Hekili:Error("Error loading spell info for spellID: " .. tostring(spellID) .. " Error: " .. tostring(result))
            end
            if loadedSpells % 100 == 0 or loadedSpells == totalSpells then
                Hekili:Print(string.format("Preloading spell info: %d/%d (%.1f%%) - Errors: %d", loadedSpells, totalSpells, (loadedSpells / totalSpells) * 100, errorCount))
            end
        end
    end
    
    Hekili:Print("Spell info preloading complete. Total errors: " .. tostring(errorCount))
end

-- Clears the spell info cache
-- Useful for debugging or when spell data might have changed
local function clearSpellInfoCache()
    wipe(spellInfoCache)
    Hekili:Print("Spell info cache cleared.")
end

-- Updates the reflectable spells data with new information
-- This allows for dynamic updates to the spell database without reloading the addon
local function updateReflectableSpellsData(newData)
    for npcID, data in pairs(newData) do
        npcData[npcID] = data
        for spellID in pairs(data.spells) do
            spellToNPC[spellID] = npcID
        end
    end
    wipe(reflectableFiltersTWW1)
    wipe(spellInfoCache)
    Hekili:Print("Reflectable spells data updated and caches cleared.")
end

-- Expose the optimized functions and tables to the addon
-- This allows other parts of Hekili to access and use these functions
class.reflectableFilters = reflectableFiltersTWW1
class.isSpellReflectable = isSpellReflectable
class.getNPCInfoBySpellID = getNPCInfoBySpellID
class.getReflectableSpellIDs = getReflectableSpellIDs
class.hasReflectableSpells = hasReflectableSpells
class.getReflectableSpellsForNPC = getReflectableSpellsForNPC
class.preloadReflectableSpellInfo = preloadSpellInfo
class.clearReflectableSpellInfoCache = clearSpellInfoCache
class.updateReflectableSpellsData = updateReflectableSpellsData

-- Note to developers:
-- This module has been optimized for performance and memory usage.
-- Key optimizations include:
-- 1. Use of metatables for lazy loading of spell data
-- 2. Caching of GetSpellInfo results
-- 3. Efficient data structures for quick lookups
-- 4. Error handling and reporting for easier debugging
-- 5. Functions for preloading and updating spell data dynamically
-- 
-- If you need to modify or extend this module, please ensure that any changes
-- maintain the performance optimizations and error handling implemented here.