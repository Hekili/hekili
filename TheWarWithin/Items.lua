-- TheWarWithin/Items.lua
-- September 2024

local addon, ns = ...
local Hekili = _G[ addon ]

local class, state = Hekili.Class, Hekili.State
local all = Hekili.Class.specs[ 0 ]

local FindPlayerAuraByID = ns.FindPlayerAuraByID
local RegisterEvent = ns.RegisterEvent

-- 11.0
all:RegisterAbilities( {
   signet_of_the_priory = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 219308,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "bolstering_light")
        end,

        proc = "secondary",
        self_buff = "bolstering_light",

        auras = {
            bolstering_light = {
                id = 443531,
                duration = 20,
                max_stack = 1
            },
        },
    },

    ravenous_honey_buzzer = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 219298,
        toggle = "cooldowns",

        proc = "damage",
    },	
	
    bursting_light_shard = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 219310,
        toggle = "cooldowns",

        proc = "damage",
    },		
	
    mereldars_toll = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 219313,
        toggle = "cooldowns",

        proc = "damage",
    },			

    charged_stormrook_plume = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 219294,
        toggle = "cooldowns",

        proc = "damage",
    },		

    high_speakers_accretion = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 219303,
        toggle = "cooldowns",

        proc = "damage",
    },	

    overclocked_geararang_launcher = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 219301,
        toggle = "cooldowns",

        proc = "damage",
    },	
	
    skarmorak_shard = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 219300,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "skarmorak_shard")
        end,

        proc = "mastery",
        self_buff = "skarmorak_shard",

        auras = {
            skarmorak_shard = {
                id = 443407,
                duration = 15,
                max_stack = 1
            },
        },
    },
	
    oppressive_orators_larynx = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 219298,
        toggle = "cooldowns",

        proc = "damage",
    },	

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


all:RegisterAuras( {
    -- Darkmoon Card: Ascendance
    ascendance_haste = {
        id = 458503,
        duration = 15,
        max_stack = 1
    },
    ascendance_vers = {
        id = 458524,
        duration = 15,
        max_stack = 1
    }
} )
