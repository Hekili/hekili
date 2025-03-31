local addon, ns = ...
local Hekili = _G[ addon ]

if not Hekili.IsCataclysm() then return end

local class, state = Hekili.Class, Hekili.State

local getSpecializationKey, RegisterEvent = ns.getSpecializationKey, ns.RegisterEvent

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
    -- Swap priorities if needed.
    local main, tabs = GetPrimaryTalentTree(), {}

    for i = 1, 3 do
        local id, _, _, _, tab = GetTalentTabInfo( i )

        tabs[ i ] = tab

        if i == main then
            state.spec[ getSpecializationKey( id ) ] = true
        else
            state.spec[ getSpecializationKey( id ) ] = nil
        end
    end

    if not Hekili.DB.profile.specs[ spec ].usePackSelector then return end

    local fromPackage = Hekili.DB.profile.specs[ spec ].package

    for _, selector in ipairs( class.specs[ spec ].packSelectors ) do
        local toPackage = Hekili.DB.profile.specs[ state.spec.id ].autoPacks[ selector.key ] or "none"

        if not rawget( Hekili.DB.profile.packs, toPackage ) then toPackage = "none" end

        if type( selector.condition ) == "function" and selector.condition( tabs[1], tabs[2], tabs[3], main ) or
            type( selector.condition ) == "number" and
                ( selector.condition == 1 and tabs[1] > max( tabs[2], tabs[3] ) or
                  selector.condition == 2 and tabs[2] > max( tabs[1], tabs[3] ) or
                  selector.condition == 3 and tabs[3] > max( tabs[1], tabs[2] ) ) then

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

    for i = 1, 9 do
        local enabled, rank, index, spellID, icon = GetGlyphSocketInfo( i )

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


all = class.specs[ 0 ]

all:RegisterAuras({
    -- Spell Vulnerability Debuffs
    spell_vulnerability = {
        alias = {
            "curse_of_the_elements",
            "master_poisoner",
            "earth_and_moon",
            "ebon_plaguebringer",
            "fire_breath"
        },
        aliasMode = "latest",
        aliasType = "debuff",
        shared = "target",
        shared_aura = true
    },

    curse_of_the_elements = {
        id = 1490,
        duration = 300,
        tick_time = 2,
        max_stack = 1,
        shared = "target",
        shared_aura = true
    },
    master_poisoner = {
        id = 60433,
        duration = 15,
        max_stack = 1,
        shared = "target",
        shared_aura = true
    },
    earth_and_moon = {
        id = 48506,
        duration = 15,
        max_stack = 1,
        shared = "target",
        shared_aura = true
    },
    ebon_plaguebringer = {
        id = 65142,
        duration = 21,
        max_stack = 1,
        shared = "target",
        shared_aura = true
    },
    fire_breath = {
        id = 34889,
        duration = 15,
        max_stack = 1,
        shared = "target",
        shared_aura = true
    },

    -- Alysrazor Flight (Used for ignoring movement logic)
    alysrazor_movement = {
        alias = {
            "wings_of_flame",
            "molten_feather"
        },
        aliasMode = "latest",
        aliasType = "buff",
    },

    -- Wings of Flame
    wings_of_flame = {
        id = 98619,
        duration = 30,
        max_stack = 1,
        copy = {98624, 98630}
    },

    -- Molten Feather
    molten_feather = {
        id = 97128,
        duration = 900,
        max_stack = 3,
        copy = {98734, 98771, 98766, 98768, 98761, 98769, 98765, 98767, 98770, 98764, 98762}
    },

    -- Cataclysm Trinkets

    -- Insignia of the Corrupted Mind, Starcatcher Compass, Seal of the Seven Signs
    -- Increases haste rating by %/s for 20 sec.
    velocity = {
        id = 109789,
        duration = 20,
        max_stack = 1,
        copy = {107982, 109709, 109711, 109787, 109802, 109804}
    },

    -- Callable aura for trinket procs
    trinket_proc = {
        alias = {
            "velocity",
            "combat_mind",
            "combat_trance",
            "titanic_strength",
            "find_weakness",
            "master_tactician",
            "surge_of_dominance",
            "slowing_the_sands"
        },
        aliasMode = "latest",
        aliasType = "buff",
    },

    -- Will of Unbinding
    -- Increases your Intellect by %/s. Effect lasts for 10 sec.
    combat_mind = {
        id = 109795,
        duration = 10,
        max_stack = 10,
        copy = {107970, 109793}
    },

    -- Wrath of Unchaining
    -- Increases your Agility by %/s. Effect lasts for 10 sec.
    combat_trance = {
        id = 107960,
        duration = 10,
        max_stack = 10,
        copy = {109717, 109719}
    },

    -- Eye of Unmaking
    -- Increases your Strength by %/s. Effect lasts for 10 sec.
    titanic_strength = {
        id = 107966,
        duration = 10,
        max_stack = 10,
        copy = {109748, 109750}
    },

    -- Creche of the Final Dragon
    -- Increases critical strike rating by %/s for 20 sec.
    find_weakness = {
        id = 107988,
        duration = 20,
        max_stack = 1,
        copy = {109742, 109744}
    },

    -- Soulshifter Vortex
    -- Increases master rating by 2904 for 20 sec.
    master_tactician = {
        id = 107986,
        duration = 20,
        max_stack = 1,
        copy = {109774, 109776}
    },

    -- Gladiator's Dominance Trinket
    -- Increases spell power by %/s for 20 sec.
    surge_of_dominance = {
        id = 102435,
        duration = 20,
        max_stack = 1,
        copy = {85027, 92218, 99719, 99742, 105137}
    },

    -- Ti'Tahk the Steps of Time
    -- Increases the caster's haste rating by %/s and haste rating of up to 3 allies by %s.
    slowing_the_sands = {
        id = 109842,
        duration = 10,
        max_stack = 1,
        copy = {107804, 109844}
    }
} )

all:RegisterAbilities( {
    -- Cataclysm Trinkets

    figurine_demon_panther = {
        cast = 0,
        cooldown = 900,
        gcd = "off",

        item = 52199,

        toggle = "cooldowns",
    },

    soul_casket = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 58183,

        toggle = "cooldowns",
    },
} )