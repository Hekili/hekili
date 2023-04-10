local addon, ns = ...
local Hekili = _G[ addon ]

if not Hekili.IsWrath() then return end

local class, state = Hekili.Class, Hekili.State

local RegisterEvent = ns.RegisterEvent

function ns.updateTalents()
    for _, tal in pairs( state.talent ) do
        tal.enabled = false
        tal.rank = 0
    end

    for k, v in pairs( class.talents ) do
        local maxRank = v[ 2 ]

        local talent = rawget( state.talent, k ) or {}
        talent.enabled = false
        talent.rank = 0

        for i = #v, 3, -1 do
            local spell = v[i]
            local ability = class.abilities[ spell ]

            if ability then
                -- This is a talent, but it could also be an ability with multiple ranks.
                local spellID = select( 7, GetSpellInfo( ability.name ) ) or spell
                if IsPlayerSpell( spellID ) then
                    talent.enabled = true
                    talent.rank = i - 2
                    break
                end
            elseif IsPlayerSpell( spell ) then
                talent.enabled = true
                talent.rank = i - 2
                break
            end
        end

        state.talent[ k ] = talent
    end

    local spec = state.spec.id or select( 3, UnitClass( "player" ) )
    if not Hekili.DB.profile.specs[ spec ].usePackSelector then return end

    -- Swap priorities if needed.
    local tab1 = select( 3, GetTalentTabInfo(1) )
    local tab2 = select( 3, GetTalentTabInfo(2) )
    local tab3 = select( 3, GetTalentTabInfo(3) )

    local fromPackage = Hekili.DB.profile.specs[ spec ].package

    for _, selector in ipairs( class.specs[ spec ].packSelectors ) do
        local toPackage = Hekili.DB.profile.specs[ state.spec.id ].autoPacks[ selector.key ] or "none"

        if not rawget( Hekili.DB.profile.packs, toPackage ) then toPackage = "none" end

        if type( selector.condition ) == "function" and selector.condition( tab1, tab2, tab3 ) or
            type( selector.condition ) == "number" and
                ( selector.condition == 1 and tab1 > max( tab2, tab3 ) or
                  selector.condition == 2 and tab2 > max( tab1, tab3 ) or
                  selector.condition == 3 and tab3 > max( tab1, tab2 ) ) then

            if toPackage ~= "none" and fromPackage ~= toPackage then
                Hekili.DB.profile.specs[ spec ].package = toPackage
                C_Timer.After( Hekili.PLAYER_ENTERING_WORLD and 0 or 5, function() Hekili:Notify( toPackage .. " priority activated." ) end )
            end
            break
        end
    end
end


local HekiliSpecMixin = ns.HekiliSpecMixin

function HekiliSpecMixin:RegisterGlyphs( glyphs )
    for id, name in pairs( glyphs ) do
        self.glyphs[ id ] = name
    end
end


function ns.updateGlyphs()
    for _, glyph in pairs( state.glyph ) do
        glyph.rank = 0
    end

    for i = 1, 6 do
        local enabled, rank, spellID = GetGlyphSocketInfo( i )

        if enabled and spellID then
            local name = class.glyphs[ spellID ]

            if name then
                local glyph = rawget( state.glyph, name ) or {}
                glyph.rank = rank
                state.glyph[ name ] = glyph
            end
        end
    end
end

RegisterEvent( "GLYPH_ADDED", ns.updateGlyphs )
RegisterEvent( "GLYPH_REMOVED", ns.updateGlyphs )
RegisterEvent( "GLYPH_UPDATED", ns.updateGlyphs )
RegisterEvent( "USE_GLYPH", ns.updateGlyphs )
RegisterEvent( "PLAYER_LEVEL_UP", ns.updateGlyphs )
RegisterEvent( "PLAYER_ENTERING_WORLD", ns.updateGlyphs )