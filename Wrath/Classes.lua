local addon, ns = ...
local Hekili = _G[ addon ]

if not Hekili.IsWrath() then return end

local class, state = Hekili.Class, Hekili.State

function ns.updateTalents()
    for k, _ in pairs( state.talent ) do
        state.talent[ k ].enabled = false
    end

    for k, v in pairs( class.talents ) do
        local maxRank = v[ 2 ]

        local talent = rawget( state.talent, k ) or {}
        talent.enabled = false

        for i = #v, 3, -1 do
            if IsPlayerSpell( v[i] ) then
                talent.enabled = true
                talent.rank = i - 2
            end
        end

        state.talent[ k ] = talent
    end
end