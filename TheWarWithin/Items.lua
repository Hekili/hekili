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
    },

    aberrant_spellforge = {
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        item = 212451,
        toggle = "cooldowns",

        proc = "haste",
        self_buff = "aberrant_alacrity",

        handler = function()
            addStack( "aberrant_spellforge" )
            if buff.aberrant_spellforge.stack_pct == 100 then
                applyBuff( "aberrant_alacrity" )
            end
        end,

        auras = {
            aberrant_alacrity = {
                id = 451845,
                duration = 6,
                max_stack = 1
            },
            aberrant_spellforge = {
                id = 445619,
                duration = 3600,
                max_stack = 5
            }
        }
    }
} )