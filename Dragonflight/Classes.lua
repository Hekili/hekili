-- Classes.lua (for Dragonflight)
-- Overrides legacy class/spec registration methods as needed.

local addon, ns = ...
local Hekili = _G[ addon ]

if not Hekili.IsDragonflight() then return end

local C_ClassTalents, C_Traits = _G.C_ClassTalents, _G.C_Traits
local RegisterEvent = ns.RegisterEvent

local state, class = Hekili.State, Hekili.Class

-- Revise state.talent to use trait metatables instead of legacy talent API.
table.wipe( state.talent )
setmetatable( state.talent, ns.metatables.mt_generic_traits )
state.talent.no_trait = { rank = 0, max = 1 }

-- Replace ns.updateTalents() as DF talents use new Traits and ClassTalents API.
function ns.updateTalents()
    local configID = C_ClassTalents.GetActiveConfigID()

    for token, data in pairs( class.talents ) do
        local node = C_Traits.GetNodeInfo( configID, data[1] )
        local talent = rawget( state.talent, token ) or {}

        talent.rank = data[2] > 0 and IsPlayerSpell( data[2] ) and node.activeRank or 0
        talent.max = node.maxRanks

        -- Perform a sanity check on maxRanks vs. data[3].  If they don't match, the talent model is likely wrong.
        if data[3] and node.maxRanks > 0 and node.maxRanks ~= data[3] then
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
end


local all = Hekili.Class.specs[0]

all:RegisterAuras( {
    blessing_of_the_bronze = {
        alias = {
            "blessing_of_the_bronze_evoker",
            "blessing_of_the_bronze_deathknight",
            "blessing_of_the_bronze_demonhunter",
            "blessing_of_the_bronze_druid",
            "blessing_of_the_bronze_hunter",
            "blessing_of_the_bronze_mage",
            "blessing_of_the_bronze_monk",
            "blessing_of_the_bronze_paladin",
            "blessing_of_the_bronze_",
            "blessing_of_the_bronze_",
            "blessing_of_the_bronze_",
        },
        aliasType = "first",
    },
    blessing_of_the_bronze_deathknight = {
        id = 381732,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_demonhunter = {
        id = 381741,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_druid = {
        id = 381746,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_evoker = {
        id = 381748,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_hunter = {
        id = 364342,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_mage = {
        id = 381750,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_monk = {
        id = 381751,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_paladin = {
        id = 381752,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_priest = {
        id = 381753,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_rogue = {
        id = 381754,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_shaman = {
        id = 381756,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_warlock = {
        id = 381757,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },
    blessing_of_the_bronze_warrior = {
        id = 381758,
        duration = 3600,
        max_stack = 1,
        shared = "player"
    },

    fury_of_the_aspects = {
        id = 390386,
        duration = 40,
        max_stack = 1,
        shared = "player"
    }
} )

-- Make Exhaustion a duplicate of Heroism's Exhaustion aura.
all.auras.exhaustion.copy = 390435
all.auras[390435] = all.auras.exhaustion