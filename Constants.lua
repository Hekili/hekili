-- Constants.lua
-- June 2014

local addon, ns = ...
local Hekili = _G[ addon ]


-- Class Localization
ns.getLocalClass = function ( class )
    if not ns.player.sex then ns.player.sex = UnitSex( "player" ) end
    return ns.player.sex == 1 and LOCALIZED_CLASS_NAMES_MALE[ class ] or LOCALIZED_CLASS_NAMES_FEMALE[ class ]
end


local InverseDirection = {
    LEFT = "RIGHT",
    RIGHT = "LEFT",
    TOP = "BOTTOM",
    BOTTOM = "TOP"
}

ns.getInverseDirection = function ( dir )

    return InverseDirection[ dir ] or dir

end


local ClassIDs = {}

for i = 1, GetNumClasses() do
    local _, classTag = GetClassInfo( i )
    if classTag then ClassIDs[ classTag ] = i end
end

ns.getClassID = function( class )
    return ClassIDs[ class ] or -1
end


local ResourceInfo = {
    -- health       = Enum.PowerType.HealthCost,
    none            = Enum.PowerType.None,
    mana            = Enum.PowerType.Mana,
    rage            = Enum.PowerType.Rage,
    focus           = Enum.PowerType.Focus,
    energy          = Enum.PowerType.Energy,
    combo_points    = Enum.PowerType.ComboPoints,
    runes           = Enum.PowerType.Runes,
    runic_power     = Enum.PowerType.RunicPower,
    soul_shards     = Enum.PowerType.SoulShards,
    astral_power    = Enum.PowerType.LunarPower,
    holy_power      = Enum.PowerType.HolyPower,
    alternate       = Enum.PowerType.Alternate,
    maelstrom       = Enum.PowerType.Maelstrom,
    chi             = Enum.PowerType.Chi,
    insanity        = Enum.PowerType.Insanity,
    obsolete        = Enum.PowerType.Obsolete,
    obsolete2       = Enum.PowerType.Obsolete2,
    arcane_charges  = Enum.PowerType.ArcaneCharges,
    fury            = Enum.PowerType.Fury,
    pain            = Enum.PowerType.Pain,
    essence         = Enum.PowerType.Essence
}

local ResourceByID = {}

for k, powerType in pairs( ResourceInfo ) do
    ResourceByID[ powerType ] = k
end


function ns.GetResourceInfo()
    return ResourceInfo
end


function ns.GetResourceID( key )
    return ResourceInfo[ key ]
end


function ns.GetResourceKey( id )
    return ResourceByID[ id ]
end


local passive_regen = {
    mana = 1,
    focus = 1,
    energy = 1,
    essence = 1
}

function ns.ResourceRegenerates( key )
    -- Does this resource have a passive gain from waiting?
    if passive_regen[ key ] then return true end
    return false
end

-- Primary purpose of this table is to store information we know about a spec, but is not directly retrieveable via API calls in-game.
ns.Specializations = {
    [250] = {
        key = "blood",
        class = "DEATHKNIGHT",
        ranged = false
    },
    [251] = {
        key = "frost",
        class = "DEATHKNIGHT",
        ranged = false
    },
    [252] = {
        key = "unholy",
        class = "DEATHKNIGHT",
        ranged = false
    },
    [102] = {
        key = "balance",
        class = "DRUID",
        ranged = true
    },
    [103] = {
        key = "feral",
        class = "DRUID",
        ranged = false
    },
    [104] = {
        key = "guardian",
        class = "DRUID",
        ranged = false
    },
    [105] = {
        key = "restoration",
        class = "DRUID",
        ranged = true
    },
    [253] = {
        key = "beast_mastery",
        class = "HUNTER",
        ranged = true
    },
    [254] = {
        key = "marksmanship",
        class = "HUNTER",
        ranged = true
    },
    [255] = {
        key = "survival",
        class = "HUNTER",
        ranged = false
    },
    [62] = {
        key = "arcane",
        class = "MAGE",
        ranged = true
    },
    [63] = {
        key = "fire",
        class = "MAGE",
        ranged = true
    },
    [64] = {
        key = "frost",
        class = "MAGE",
        ranged = true
    },
    [268] = {
        key = "brewmaster",
        class = "MONK",
        ranged = false
    },
    [269] = {
        key = "windwalker",
        class = "MONK",
        ranged = false
    },
    [270] = {
        key = "mistweaver",
        class = "MONK",
        ranged = false
    },
    [65] = {
        key = "holy",
        class = "PALADIN",
        ranged = false
    },
    [66] = {
        key = "protection",
        class = "PALADIN",
        ranged = false
    },
    [70] = {
        key = "retribution",
        class = "PALADIN",
        ranged = false
    },
    [256] = {
        key = "discipline",
        class = "PRIEST",
        ranged = true
    },
    [257] = {
        key = "holy",
        class = "PRIEST",
        ranged = true
    },
    [258] = {
        key = "shadow",
        class = "PRIEST",
        ranged = true
    },
    [259] = {
        key = "assassination",
        class = "ROGUE",
        ranged = false
    },
    [260] = {
        key = "outlaw",
        class = "ROGUE",
        ranged = false
    },
    [261] = {
        key = "subtlety",
        class = "ROGUE",
        ranged = false
    },
    [262] = {
        key = "elemental",
        class = "SHAMAN",
        ranged = true
    },
    [263] = {
        key = "enhancement",
        class = "SHAMAN",
        ranged = false
    },
    [264] = {
        key = "restoration",
        class = "SHAMAN",
        ranged = true
    },
    [265] = {
        key = "affliction",
        class = "WARLOCK",
        ranged = true
    },
    [266] = {
        key = "demonology",
        class = "WARLOCK",
        ranged = true
    },
    [267] = {
        key = "destruction",
        class = "WARLOCK",
        ranged = true
    },
    [71] = {
        key = "arms",
        class = "WARRIOR",
        ranged = false
    },
    [72] = {
        key = "fury",
        class = "WARRIOR",
        ranged = false
    },
    [73] = {
        key = "protection",
        class = "WARRIOR",
        ranged = false
    },
    [577] = {
        key = "havoc",
        class = "DEMONHUNTER",
        ranged = false
    },
    [581] = {
        key = "vengeance",
        class = "DEMONHUNTER",
        ranged = false
    },
    [1467] = {
        key = "devastation",
        class = "EVOKER",
        ranged = true
    },
    [1468] = {
        key = "preservation",
        class = "EVOKER",
        ranged = true
    },
    [1473] = {
        key = "augmentation",
        class = "EVOKER",
        ranged = true
    },
}

ns.getSpecializationKey = function ( id )
    local spec = ns.Specializations[ id ]
    return spec and spec.key or "none"
end

ns.getSpecializationID = function ( index )
    return GetSpecializationInfo( index or GetSpecialization() or 0 )
end

ns.HeroTrees = {
    [31] = {
        name = "sanlayn",
        keyTalent = "vampiric_strike",
        specIDs = { 250, 252 }
    },
    [32] = {
        name = "rider_of_the_apocalypse",
        keyTalent = "riders_champion",
        specIDs = { 251, 252 }
    },
    [33] = {
        name = "deathbringer",
        keyTalent = "reapers_mark",
        specIDs = { 250, 251 }
    },

    [34] = {
        name = "felscarred",
        keyTalent = "demonsurge",
        specIDs = { 577, 581 }
    },
    [35] = {
        name = "aldrachi_reaver",
        keyTalent = "art_of_the_glaive",
        specIDs = { 577, 581 }
    },

    [21] = {
        name = "druid_of_the_claw",
        keyTalent = "ravage",
        specIDs = { 103, 104 }
    },
    [22] = {
        name = "wildstalker",
        keyTalent = "thriving_growth",
        specIDs = { 103, 105 }
    },
    [23] = {
        name = "keeper_of_the_grove",
        keyTalent = "dream_surge",
        specIDs = { 102, 105 }
    },
    [24] = {
        name = "elunes_chosen",
        keyTalent = "boundless_moonlight",
        specIDs = { 102, 104 }
    },
    [36] = {
        name = "scalecommander",
        keyTalent = {
            [1467] = "mass_disintegrate",
            [1468] = "mass_eruption"
        },
        specIDs = { 1467, 1468 }
    },
    [37] = {
        name = "flameshaper",
        keyTalent = "engulf",
        specIDs = { 1467, 1473 }
    },
    [38] = {
        name = "chronowarden",
        keyTalent = "chrono_flame",
        specIDs = { 1468, 1473 }
    },

    [42] = {
        name = "sentinel",
        keyTalent = "sentinel",
        specIDs = { 254, 255 }
    },
    [43] = {
        name = "pack_leader",
        keyTalent = "howl_of_the_pack_leader",
        specIDs = { 253, 255 }
    },
    [44] = {
        name = "dark_ranger",
        keyTalent = "black_arrow",
        specIDs = { 253, 254 }
    },

    [39] = {
        name = "sunfury",
        keyTalent = "spellfire_spheres",
        specIDs = { 62, 63 }
    },
    [40] = {
        name = "spellslinger",
        keyTalent = "splintering_sorcery",
        specIDs = { 62, 64 }
    },
    [41] = {
        name = "frostfire",
        keyTalent = "frostfire_mastery",
        specIDs = { 63, 64 }
    },

    [64] = {
        name = "conduit_of_the_celestials",
        keyTalent = "celestial_conduit",
        specIDs = { 269, 270 }
    },
    [65] = {
        name = "shado_pan",
        keyTalent = "flurry_strikes",
        specIDs = { 268, 269 }
    },
    [66] = {
        name = "master_of_harmony",
        keyTalent = "aspect_of_harmony",
        specIDs = { 268, 270 }
    },

    [48] = {
        name = "templar",
        keyTalent = "lights_guidance",
        specIDs = { 66, 70 }
    },
    [49] = {
        name = "lightsmith",
        keyTalent = "holy_armaments",
        specIDs = { 65, 66 }
    },
    [50] = {
        name = "herald_of_the_sun",
        keyTalent = "dawnlight",
        specIDs = { 65, 70 }
    },

    [18] = {
        name = "voidweaver",
        keyTalent = "entropic_rift",
        specIDs = { 257, 258 }
    },
    [19] = {
        name = "archon",
        keyTalent = "power_surge",
        specIDs = { 256, 258 }
    },
    [20] = {
        name = "oracle",
        keyTalent = "premonition",
        specIDs = { 256, 257 }
    },

    [51] = {
        name = "trickster",
        keyTalent = "unseen_blade",
        specIDs = { 260, 261 }
    },
    [52] = {
        name = "fatebound",
        keyTalent = "hand_of_fate",
        specIDs = { 259, 260 }
    },
    [53] = {
        name = "deathstalker",
        keyTalent = "deathstalkers_mark",
        specIDs = { 259, 261 }
    },

    [54] = {
        name = "totemic",
        keyTalent = "surging_totem",
        specIDs = { 262, 264 }
    },
    [55] = {
        name = "stormbringer",
        keyTalent = "tempest",
        specIDs = { 262, 263 }
    },
    [56] = {
        name = "farseer",
        keyTalent = "call_of_the_ancestors",
        specIDs = { 263, 264 }
    },

    [57] = {
        name = "soul_harvester",
        keyTalent = "demonic_soul",
        specIDs = { 265, 266 }
    },
    [58] = {
        name = "hellcaller",
        keyTalent = "wither",
        specIDs = { 265, 267 }
    },
    [59] = {
        name = "diabolist",
        keyTalent = "diabolic_ritual",
        specIDs = { 266, 267 }
    },

    [60] = {
        name = "slayer",
        keyTalent = "slayers_dominance",
        specIDs = { 71, 72 }
    },
    [61] = {
        name = "mountain_thane",
        keyTalent = "lightning_strikes",
        specIDs = { 71, 73 }
    },
    [62] = {
        name = "colossus",
        keyTalent = "demolish",
        specIDs = { 72, 73 }
    }
}

-- Get full info for a Hero Tree by its Hero Spec ID (31–66)
ns.getHeroTree = function ( heroID )
    return ns.HeroTrees[ heroID ]
end

-- Get the name of the currently active Hero Tree
ns.getActiveHeroTreeName = function ()
    local id = C_ClassTalents and C_ClassTalents.GetActiveHeroTalentSpec()
    if not id or id == 0 then return nil end -- 0 is the API return for no tree
    local tree = ns.HeroTrees[ id ]
    return tree and tree.name or nil
end

-- Get the key talent from the currently active Hero Tree (with per-spec support)
ns.getActiveHeroTreeKeyTalent = function ()
    local id = C_ClassTalents and C_ClassTalents.GetActiveHeroTalentSpec()
    if not id then return nil end

    local tree = ns.HeroTrees[ id ]
    if not tree then return nil end

    local keyTalent = tree.keyTalent

    if type( keyTalent ) == "table" then
        local specID = state.spec.id or ns.getSpecializationID()
        return keyTalent[ specID ]
    end

    return keyTalent
end


ns.PvpDummies = {
    [114840] = true,  -- Orgrimmar
    [114832] = true,  -- Stormwind
    [189082] = true,  -- Nowhere
    [197833] = true,  -- Valdrakken
    [197834] = true,  -- Healing
    [219250] = true,  -- Dornogal
    [219251] = true   -- Dornogal Healing
}

ns.TargetDummies = {
    [   4952 ] = "Theramore Combat Dummy",
    [   5652 ] = "Undercity Combat Dummy",
    [  25225 ] = "Practice Dummy",
    [  25297 ] = "Drill Dummy",
    [  31144 ] = "Training Dummy",
    [  31146 ] = "Raider's Training Dummy",
    [  32541 ] = "Initiate's Training Dummy",
    [  32543 ] = "Veteran's Training Dummy",
    [  32546 ] = "Ebon Knight's Training Dummy",
    [  32542 ] = "Disciple's Training Dummy",
    [  32545 ] = "Training Dummy",
    [  32666 ] = "Training Dummy",
    [  32667 ] = "Training Dummy",
    [  44171 ] = "Training Dummy",
    [  44548 ] = "Training Dummy",
    [  44389 ] = "Training Dummy",
    [  44614 ] = "Training Dummy",
    [  44703 ] = "Training Dummy",
    [  44794 ] = "Training Dummy",
    [  44820 ] = "Training Dummy",
    [  44848 ] = "Training Dummy",
    [  44937 ] = "Training Dummy",
    [  46647 ] = "Training Dummy",
    [  48304 ] = "Training Dummy",
    [  60197 ] = "Training Dummy",
    [  64446 ] = "Training Dummy",
    [  67127 ] = "Training Dummy",
    [  70245 ] = "Training Dummy",
    [  79414 ] = "Training Dummy",
    [  87317 ] = "Training Dummy",
    [  87318 ] = "Dungeoneer's Training Dummy",
    [  87320 ] = "Raider's Training Dummy",
    [  87322 ] = "Dungeoneer's Training Dummy",
    [  87329 ] = "Raider's Training Dummy",
    [  87760 ] = "Training Dummy",
    [  87761 ] = "Dungeoneer's Training Dummy",
    [  87762 ] = "Raider's Training Dummy",
    [  88288 ] = "Dungeoneer's Training Dummy",
    [  88314 ] = "Dungeoneer's Training Dummy",
    [  88836 ] = "Dungeoneer's Training Dummy",
    [  88837 ] = "Raider's Training Dummy",
    [  88906 ] = "Combat Dummy",
    [  89078 ] = "Training Dummy",
    [  92164 ] = "Training Dummy",
    [  92165 ] = "Dungeoneer's Training Dummy",
    [  92166 ] = "Raider's Training Dummy",
    [  92168 ] = "Dungeoneer's Training Dummy",
    [  92169 ] = "Raider's Training Dummy",
    [  93828 ] = "Training Dummy",
    [  97668 ] = "Boxer's Training Dummy",
    [  98581 ] = "Prepfoot Training Dummy",
    [ 107104 ] = "Target Dummy",
    [ 108420 ] = "Training Dummy",
    [ 109066 ] = "Dungeon Damage Dummy",
    [ 109096 ] = "Normal Tanking Dummy",
    [ 111824 ] = "Training Dummy",
    [ 113858 ] = "Training Dummy",
    [ 113859 ] = "Dungeoneer's Training Dummy",
    [ 113860 ] = "Raider's Training Dummy",
    [ 113862 ] = "Training Dummy",
    [ 113863 ] = "Dungeoneer's Training Dummy",
    [ 113864 ] = "Raider's Training Dummy",
    [ 113871 ] = "Bombardier's Training Dummy",
    [ 126712 ] = "Training Dummy",
    [ 126781 ] = "Training Dummy",
    [ 127019 ] = "Training Dummy",
    [ 131983 ] = "Raider's Training Dummy",
    [ 131989 ] = "Training Dummy",
    [ 131990 ] = "Raider's Training Dummy",
    [ 131992 ] = "Dungeoneer's Training Dummy",
    [ 132976 ] = "Training Dummy",
    [ 134324 ] = "Training Dummy",
    [ 138048 ] = "Training Dummy",
    [ 143119 ] = "Gnoll Target Dummy",
    [ 143509 ] = "Training Dummy",
    [ 144073 ] = "Dungeoneer's Training Dummy",
    [ 144077 ] = "Training Dummy",
    [ 144081 ] = "Training Dummy",
    [ 144085 ] = "Training Dummy",
    [ 144086 ] = "Raider's Training Dummy",
    [ 153285 ] = "Training Dummy",
    [ 153292 ] = "Training Dummy",
    [ 172452 ] = "Raider's Tanking Dummy",
    [ 173942 ] = "Training Dummy",
    [ 174565 ] = "Raider's Tanking Dummy",
    [ 174566 ] = "Dungeoneer's Tanking Dummy",
    [ 174567 ] = "Raider's Tanking Dummy",
    [ 174568 ] = "Dungeoneer's Tanking Dummy",
    [ 175449 ] = "Dungeoneer's Training Dummy",
    [ 175450 ] = "Raider's Training Dummy",
    [ 175451 ] = "Dungeoneer's Training Dummy",
    [ 194643 ] = "Dungeoneer's Training Dummy",
    [ 194644 ] = "Dungeoneer's Training Dummy",
    [ 194648 ] = "Training Dummy",
    [ 194649 ] = "Normal Tank Dummy",
    [ 193394 ] = "Tuskarr Training Dummy",
    [ 193563 ] = "Training Dummy",
    [ 198594 ] = "Cleave Training Dummy",
    [ 199057 ] = "Black Dragon's Challenge Dummy",
    [ 216458 ] = "Sparring Dummy",
    [ 222275 ] = "Training Dummy",
    [ 225976 ] = "Normal Tank Dummy",
    [ 225977 ] = "Dungeoneer's Training Dummy",
    [ 225982 ] = "Cleave Training Dummy",
    [ 225983 ] = "Dungeoneer's Training Dummy",
    [ 225984 ] = "Training Dummy",
    [ 235830 ] = "Training Dummy",
}


ns.FrameStratas = {
    "BACKGROUND",
    "LOW",
    "MEDIUM",
    "HIGH",
    "DIALOG",
    "FULLSCREEN",
    "FULLSCREEN_DIALOG",
    "TOOLTIP",

    BACKGROUND = 1,
    LOW = 2,
    MEDIUM = 3,
    HIGH = 4,
    DIALOG = 5,
    FULLSCREEN = 6,
    FULLSCREEN_DIALOG = 7,
    TOOLTIP = 8
}