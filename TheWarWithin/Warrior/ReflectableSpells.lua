-- Warrior/ReflectableSpells.lua (for The War Within)

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class = Hekili.Class

local reflectableFilters = {}

for zoneID, zoneData in pairs( class.spellFilters ) do
    for npcID, npcData in pairs( zoneData ) do
        if npcID ~= "name" then
            for spellID, spellData in pairs( npcData ) do
                if spellID ~= "name" and spellData.spell_reflection then
                    reflectableFilters[ spellID ] = true
                end
            end
        end
    end
end

class.reflectableFilters = reflectableFilters
