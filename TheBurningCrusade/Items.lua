-- TheBurningCrusade/Items.lua

local addon, ns = ...
local Hekili = _G[ addon ]

local class, state = Hekili.Class, Hekili.State
local all = Hekili.Class.specs[ 0 ]

--[[ WiP: Timewarped Trinkets
do
    local timewarped_trinkets = {
        { "runed_fungalcap",                127184, "shell_of_deterrence",              31771,  20,     1 },
        { "icon_of_the_silver_crescent",    129850, "blessing_of_the_silver_crescent",  194645, 20,     1 },
        { "essence_of_the_martyr",          129851, "essence_of_the_martyr",            194637, 20,     1 },
        { "gnomeregan_autoblocker_601",     129849, "gnome_ingenuity",                  194543, 40,     1 },
        { "emblem_of_fury",                 129937, "lust_for_battle_str",              194638, 20,     1 },
        { "bloodlust_brooch",               129848, "lust_for_battle_agi",              194632, 20,     1 },
        {}

    }

    { "vial_of_the_sunwell",            133462, "vessel_of_the_naaru",              45059,  3600,   1 }, -- vessel_of_the_naaru on-use 45064, 120 sec CD.
end ]]


all:RegisterAbility( "shadowmoon_insignia", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 150526,
    toggle = "defensives",

    proc = "health",

    handler = function ()
        applyBuff( "protectors_vigor" )
    end,

    auras = {
        protectors_vigor = {
            id = 244189,
            duration = 20,
            max_stack = 1
        }
    }
} )
