-- TheWarWithin/Items.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]

local class, state = Hekili.Class, Hekili.State
local all = Hekili.Class.specs[ 0 ]

local FindPlayerAuraByID = ns.FindPlayerAuraByID
local RegisterEvent = ns.RegisterEvent

-- 10.0
all:RegisterAbilities( {
    spymasters_web = {
        cast = 0,
        cooldown = 20,
        gcd = "off",

        item = 220202,
        toggle = "cooldowns",

        buff = "spymasters_report",

        handler = function()
            applyBuff( "spymasters_web", nil, buff.spymasters_report.stack )
            removeBuff( "spymasters_report" )
        end,

        proc = "primary",
        self_buff = "spymasters_web",

        auras = {
            spymasters_report = {
                id = 451199,
                duration = 20, -- ???
                max_stack = 40
            },
            spymasters_web = {
                id = 444959,
                duration = 20,
                max_stack = 40
            }
        },
    },

    treacherous_transmitter = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 221023,
        toggle = "cooldowns",

        buff = "ethereal_powerlink",
        proc = "primary",
        self_buff = "ethereal_powerlink",

        auras = {
            ethereal_powerlink = {
                id = 449954,
                duration = 15,
                max_stack = 1
            }
        }
    }
} )