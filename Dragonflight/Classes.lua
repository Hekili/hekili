-- Classes.lua (for Dragonflight)
-- Overrides legacy class/spec registration methods as needed.

local addon, ns = ...
local Hekili = _G[ addon ]

if not Hekili.IsDragonflight() then return end

local C_ClassTalents, C_Traits = _G.C_ClassTalents, _G.C_Traits
local IsPlayerSpell = _G.IsPlayerSpell

local ResetDisabledGearAndSpells, WipeCovenantCache = ns.ResetDisabledGearAndSpells, ns.WipeCovenantCache

local state, class = Hekili.State, Hekili.Class

-- Revise state.talent to use trait metatables instead of legacy talent API.
table.wipe( state.talent )
setmetatable( state.talent, ns.metatables.mt_generic_traits )
state.talent.no_trait = { rank = 0, max = 1 }

-- Replace ns.updateTalents() as DF talents use new Traits and ClassTalents API.
do
    function ns.updateTalents()
        for _, data in pairs( state.talent ) do
            data.rank = 0
        end

        WipeCovenantCache()
        ResetDisabledGearAndSpells()

        if GetSpecialization() == 5 then return end

        local configID = C_ClassTalents.GetActiveConfigID() or -1

        for token, data in pairs( class.talents ) do
            local node = C_Traits.GetNodeInfo( configID, data[1] )
            local talent = rawget( state.talent, token ) or {}

            if not node or not node.activeEntry then
                talent.rank = 0
                talent.max = 1
            else
                local entryID = node.activeEntry.entryID
                local entry   = entryID and C_Traits.GetEntryInfo( configID, entryID )
                local defn    = entry and C_Traits.GetDefinitionInfo( entry.definitionID )

                talent.rank = defn and defn.spellID == data[2] and node.activeEntry.rank or 0
                talent.max = node.maxRanks
            end

            -- Perform a sanity check on maxRanks vs. data[3].  If they don't match, the talent model is likely wrong.
            if data[3] and node and node.maxRanks > 0 and node.maxRanks ~= data[3] then
                Hekili:Error( "Talent '%s' model expects %d ranks but actual max ranks was %d.", token, data[3], node.maxRanks )
            end

            state.talent[ token ] = talent
        end

        for k, _ in pairs( state.pvptalent ) do
            state.pvptalent[ k ]._enabled = false
        end

        for k, v in pairs( class.pvptalents ) do
            local _, name, _, enabled, _, sID, _, _, _, known = GetPvpTalentInfoByID( v, 1 )

            if not name then
                enabled = IsPlayerSpell( v )
            end

            enabled = enabled or known

            if rawget( state.pvptalent, k ) then
                state.pvptalent[ k ]._enabled = enabled
            else
                state.pvptalent[ k ] = {
                    _enabled = enabled
                }
            end
        end

        ns.callHook( "TALENTS_UPDATED" )
    end
end