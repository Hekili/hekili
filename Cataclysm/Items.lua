-- Cataclysm/Items.lua

local addon, ns = ...
local Hekili = _G[ addon ]

local class, state = Hekili.Class, Hekili.State
local all = Hekili.Class.specs[ 0 ]

all:RegisterAbility( "skardyns_grace", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 133282,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "speed_of_thought" )
    end,

    auras = {
        speed_of_thought = {
            id = 92099,
            duration = 35,
            max_stack = 1
        }
    }
} )
