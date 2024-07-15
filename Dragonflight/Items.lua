-- Dragonflight/Items.lua
-- December 2022

local addon, ns = ...
local Hekili = _G[ addon ]

local class, state = Hekili.Class, Hekili.State
local all = Hekili.Class.specs[ 0 ]

local FindPlayerAuraByID = ns.FindPlayerAuraByID
local RegisterEvent = ns.RegisterEvent

-- 10.0
all:RegisterAbilities( {
    algethar_puzzle_box = {
        cast = function() return 2 * haste end,
        cooldown = 180,
        gcd = "spell",

        item = 193701,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "algethar_puzzle" )
            if class.auras.stealth and buff.stealth.up then removeBuff( "stealth" ) end
        end,

        proc = "mastery",
        self_buff = "algethar_puzzle",

        auras = {
            algethar_puzzle = {
                id = 383781,
                duration = 30,
                max_stack = 1,
            },
        },

        copy = 383781
    },
    bag_of_biscuits = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 197960,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "biscuit_giver" )
        end,

        proc = "mastery",
        self_buff = "biscuit_giver",

        auras = {
            biscuit_giver = {
                id = 381902,
                duration = 15,
                max_stack = 1,
            },
        }
    },
    blazebinders_hoof = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 193762,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "bound_by_fire_and_blaze" )
        end,

        proc = "strength",
        self_buff = "bound_by_fire_and_blaze",

        auras = {
            bound_by_fire_and_blaze = {
                id = 383926,
                duration = 20,
                max_stack = 6,
            },
        }
    },
    bottomless_reliquary_satchel = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 198695,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "algethar_puzzle" )
        end,

        proc = "damage", -- don't really know.

        auras = {
            bottomless_reliquary_satchel = {
                duration = 0.01,
                max_stack = 1,
            },
        }
    },
    broodkeepers_promise = {
        cast = 1,
        cooldown = 5,
        gcd = "off",

        item = 194307,
        toggle = "cooldowns",
        nobuff = "broodkeepers_promise",

        usable = function() return group, "requires allies" end,
        handler = function()
            applyBuff( "broodkeepers_promise" )
        end,

        proc = "versatility",
        self_buff = "broodkeepers_promise",

        auras = {
            broodkeepers_promise = {
                id = 394457,
                duration = 3600,
                max_stack = 1,
            },
        }
    },
    burgeoning_seed = {
        cast = 0,
        cooldown = 30,
        gcd = "off",

        item = 193634,
        toggle = "cooldowns",
        buff = "brimming_lifepod",

        handler = function()
            removeBuff( "brimming_lifepod" )
            applyBuff( "supernatural" )
        end,

        proc = "versatility",
        self_buff = "supernatural",

        auras = {
            brimming_lifepod = {
                id = 384646,
                duration = 360,
                max_stack = 5,
            },
            supernatural = {
                id = 384658,
                duration = 12,
                max_stack = 1,
            }
        }
    },
    caregivers_charm = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 198081,
        toggle = "cooldowns",

        usable = function() return group and active_dot.caregivers_watch == 0, "requires an ally" end,

        handler = function()
            applyBuff( "caregivers_watch" )
        end,

        proc = "healing",
        self_buff = "caregivers_watch",

        auras = {
            caregivers_watch = {
                id = 382161,
                duration = 30,
                max_stack = 1,
                dot = "buff"
            }
        }
    },
    choker_of_shielding = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 193002,
        toggle = "defensives",

        handler = function()
            applyBuff( "choker_of_shielding" )
        end,

        proc = "absorb",
        self_buff = "choker_of_shielding",

        auras = {
            choker_of_shielding = {
                id = 384646,
                duration = 10,
                max_stack = 1,
            },
        }
    },
    conjured_chillglobe = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 194300,
        toggle = "cooldowns",

        handler = function()
            if mana.percent < 65 then gain( 11736, "mana" ) end
        end,

        proc = "mana",
    },
    darkmoon_deck_box_dance = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 198478,
        toggle = "cooldowns",

        proc = "damage",
    },
    darkmoon_deck_box_inferno = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 194872,
        toggle = "cooldowns",

        proc = "damage",
    },
    darkmoon_deck_box_rime = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 198477,
        toggle = "cooldowns",

        handler = function()
            applyDebuff( "target", "awakening_rime" )
        end,

        proc = "damage",

        auras = {
            awakening_rime = { -- TODO: Check actual aura ID.
                id = 384623,
                duration = 12,
                max_stack = 1,
            }
        }
    },
    darkmoon_deck_box_watcher = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 198481,
        toggle = "defensives",

        handler = function()
            applyBuff( "watchers_blessing" )
        end,

        proc = "versatility",
        self_buff = "watchers_blessing",

        auras = {
            watchers_blessing = {
                id = 384532,
                duration = 10,
                max_stack = 1
            },
            watchers_blessing_vers = {
                id = 384560,
                duration = 10,
                max_stack = 1
            }
        }
    },
    darkmoon_deck_dance = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 198088,
        toggle = "cooldowns",

        proc = "damage",

        auras = {
            ace_of_air = {
                id = 382860,
                duration = 3600,
                max_stack = 1
            },
            two_of_air = {
                id = 382861,
                duration = 3600,
                max_stack = 1
            },
            three_of_air = {
                id = 382862,
                duration = 3600,
                max_stack = 1
            },
            four_of_air = {
                id = 382863,
                duration = 3600,
                max_stack = 1
            },
            five_of_air = {
                id = 382864,
                duration = 3600,
                max_stack = 1
            },
            six_of_air = {
                id = 382865,
                duration = 3600,
                max_stack = 1
            },
            seven_of_air = {
                id = 382866,
                duration = 3600,
                max_stack = 1
            },
            eight_of_air = {
                id = 382867,
                duration = 3600,
                max_stack = 1
            },
        }
    },
    darkmoon_deck_inferno = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 198086,

        proc = "damage",

        auras = {
            ace_of_fire = {
                id = 382835,
                duration = 3600,
                max_stack = 1
            },
            two_of_fire = {
                id = 382836,
                duration = 3600,
                max_stack = 1
            },
            three_of_fire = {
                id = 382837,
                duration = 3600,
                max_stack = 1
            },
            four_of_fire = {
                id = 382838,
                duration = 3600,
                max_stack = 1
            },
            five_of_fire = {
                id = 382839,
                duration = 3600,
                max_stack = 1
            },
            six_of_fire = {
                id = 382840,
                duration = 3600,
                max_stack = 1
            },
            seven_of_fire = {
                id = 382841,
                duration = 3600,
                max_stack = 1
            },
            eight_of_fire = {
                id = 382842,
                duration = 3600,
                max_stack = 1
            }
        }
    },
    darkmoon_deck_rime = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 198087,
        handler = function()
            applyDebuff( "target", "awakening_rime" )
        end,

        proc = "damage",

        auras = {
            ace_of_frost = {
                id = 382844,
                duration = 3600,
                max_stack = 1
            },
            two_of_frost = {
                id = 382845,
                duration = 3600,
                max_stack = 1
            },
            three_of_frost = {
                id = 382846,
                duration = 3600,
                max_stack = 1
            },
            four_of_frost = {
                id = 382847,
                duration = 3600,
                max_stack = 1
            },
            five_of_frost = {
                id = 382848,
                duration = 3600,
                max_stack = 1
            },
            six_of_frost = {
                id = 382849,
                duration = 3600,
                max_stack = 1
            },
            seven_of_frost = {
                id = 382850,
                duration = 3600,
                max_stack = 1
            },
            eight_of_frost = {
                id = 382851,
                duration = 3600,
                max_stack = 1
            },
        }
    },
    darkmoon_deck_watcher = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 198089,
        toggle = "defensives",

        handler = function()
            applyBuff( "watchers_blessing" )
        end,

        proc = "versatility",

        auras = {
            ace_of_earth = {
                id = 382852,
                duration = 3600,
                max_stack = 1
            },
            two_of_earth = {
                id = 382853,
                duration = 3600,
                max_stack = 1
            },
            three_of_earth = {
                id = 382854,
                duration = 3600,
                max_stack = 1
            },
            four_of_earth = {
                id = 382855,
                duration = 3600,
                max_stack = 1
            },
            five_of_earth = {
                id = 382856,
                duration = 3600,
                max_stack = 1
            },
            six_of_earth = {
                id = 382857,
                duration = 3600,
                max_stack = 1
            },
            seven_of_earth = {
                id = 382858,
                duration = 3600,
                max_stack = 1
            },
            eight_of_earth = {
                id = 382859,
                duration = 3600,
                max_stack = 1
            },
        }
    },
    decoration_of_flame = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 194299,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "decoration_of_flame" )
        end,

        proc = "damage",
        self_buff = "decoration_of_flame",

        auras = {
            decoration_of_flame = {
                id = 382058,
                duration = 30,
                max_stack = 1
            }
        }
    },
    desperate_invokers_codex = {
        cast = 0,
        cooldown = function() return 240 - buff.hatred.stack end,
        gcd = "off",

        item = 194310,
        toggle = "cooldowns",

        proc = "damage",

        auras = {
            hatred = {
                id = 382419,
                duration = 3600,
                max_stack = 180
            }
        }
    },
    dragon_games_equipment = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 193719,
        toggle = "cooldowns",

        proc = "damage",
    },
    emerald_coachs_whistle = {
        cast = 0,
        cooldown = 1,
        gcd = "off",

        item = 193718,
        usable = function() return group, "requires an ally" end,
        nobuff = "coaching",

        handler = function()
            applyBuff( "coaching" )
            active_dot.coached = 1
        end,

        proc = "mastery",

        auras = {
            coaching = {
                id = 389581,
                duration = 3600,
                max_stack = 1,
            },
            coached = {
                id = 386578,
                duration = 3600,
                max_stack = 1,
                dot = "buff"
            },
            time_to_shine = {
                id = 383799,
                duration = 10,
                max_stack = 1
            }
        }
    },
    erupting_spear_fragment = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 193769,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "erupting_spear_fragment", nil, min( 5, active_enemies ) )
        end,

        proc = "crit",
        self_buff = "erupting_spear_fragment",

        auras = {
            erupting_spear_fragment = {
                id = 381484,
                duration = 10,
                max_stack = 5
            }
        }
    },
    essence_of_somnikuss_shade = {
        cast = 0,
        cooldown = 300,
        gcd = "off",

        item = 200679,
        toggle = "cooldowns",

        handler = function()
            applyDebuff( "target", "ancient_poison_cloud" )
        end,

        proc = "damage",

        auras = {
            ancient_poison_cloud = {
                id = 391621,
                duration = 45,
                max_stack = 1
            }
        }
    },
    globe_of_jagged_ice = {
        cast = 0,
        cooldown = 30,
        gcd = "off",

        item = 212683,

        -- usable = function() return active_dot.skewering_cold > 0, "requires skewering_cold stacks" end,
        handler = function()
            if debuff.skewering_cold.up then
                removeDebuff( "target", "skewering_cold" )
                applyDebuff( "target", "breaking_the_ice" )
            end

            active_dot.skewering_cold = 0
        end,

        proc = "damage",

        auras = {
            skewering_cold = {
                id = 388929,
                duration = 60,
                max_stack = 4
            },
            breaking_the_ice = {
                id = 388948,
                duration = 10,
                max_stack = 1
            }
        }
    },
    homeland_raid_horn = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 193815,
        toggle = "cooldowns",

        proc = "damage",
    },
    iceblood_deathsnare = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 194304,
        toggle = "cooldowns",

        handler = function()
            applyDebuff( "target", "crystalline_web" )
        end,

        proc = "damage",

        auras = {
            crystalline_web = {
                id = 382130,
                duration = 15,
                max_stack = 5,
                copy = 394618
            },
        }
    },
    integrated_primal_fire = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 200868,
        toggle = "cooldowns",
    },
    irideus_fragment = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 193743,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "crumbling_power", nil, 20 )
        end,

        proc = "primary",
        self_buff = "crumbling_power",

        auras = {
            crumbling_power = {
                id = 383941,
                duration = 20,
                max_stack = 20
            }
        }
    },
    kharnalex_the_first_light = {
        cast = 3,
        channeled = true,
        cooldown = 180,
        gcd = "off",

        item = 195519,
        toggle = "cooldowns",

        usable = function() return class.evoker, "evoker only" end,
    },
    lifeflame_ampoule = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 198451,
        toggle = "cooldowns",
    },
    manic_grieftorch = {
        cast = function() return 2 * haste end,
        channeled = true,
        cooldown = 120,
        gcd = "off",

        cycle = function()
            -- Recommend a different target if yours is expected to die before the channel would complete, with a little buffer added.
            if active_enemies > 1 and fight_remains > 3 * haste and target.time_to_die < 3 * haste then
                return "cycle"
            end
        end,

        item = 194308,
        toggle = "cooldowns",
    },
    miniature_singing_stone = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 193678,
        toggle = "defensives",

        -- TODO: May require an ally?
        handler = function()
            applyBuff( "miniature_singing_stone" )
        end,

        proc = "absorb",

        auras = {
            miniature_singing_stone = {
                id = 388855,
                duration = 10,
                max_stack = 1
            }
        }
    },
    mote_of_sanctification = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 133646,
        toggle = "cooldowns",

        handler = function()
        end,
    },
    primal_ritual_shell = {
        cast = 0,
        cooldown = 1,
        gcd = "off",

        item = 200563,

        usable = false,
        auras = {
            stone_turtles_blessing = {
                id = 390643,
                duration = 3600,
                max_stack = 1,
            },
            flame_turtles_blessing = {
                id = 390835,
                duration = 3600,
                max_stack = 1,
            },
            sea_turtles_blessing = {
                id = 390869,
                duration = 3600,
                max_stack = 1,
            },
            wind_turtles_blessing = {
                id = 390899,
                duration = 3600,
                max_stack = 1
            },
            primal_turtles_wish = {
                id = 390936,
                duration = 20,
                max_stack = 1,
            },
        }
    },
    restored_titan_artifact = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 200549,

        handler = function()
            applyBuff( "restored_titan_artifact" )
        end,

        proc = "absorb",

        auras = {
            restored_titan_artifact = {
                id = 390420,
                duration = 10,
                max_stack = 1
            }
        }
    },
    --[[ ringbound_hourglass = {
        cast = 0,
        cooldown = 3600,
        gcd = "off",

        item = 193000,
        toggle = "cooldowns",
    }, ]]
    ruby_whelp_shell = {
        cast = 0,
        cooldown = 1,
        gcd = "off",

        item = 193757,
        usable = false,

        auras = {
            under_red_wings = {
                id = 389820,
                duration = 12,
                max_stack = 1
            }
        }
    },
    spoils_of_neltharus = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 193773,
        toggle = "cooldowns",

        proc = function()
            if     buff.spoils_of_neltharus_crit.up    then return "critical_strike"
            elseif buff.spoils_of_neltharus_haste.up   then return "haste"
            elseif buff.spoils_of_neltharus_mastery.up then return "mastery"
            elseif buff.spoils_of_neltharus_vers.up    then return "versatility"     end
            return "random"
        end,
        self_buff = "spoils_of_neltharus_crit",

        handler = function()
            if     buff.spoils_of_neltharus_crit.up    then applyBuff( "spoils_of_neltharus_crit"    )
            elseif buff.spoils_of_neltharus_haste.up   then applyBuff( "spoils_of_neltharus_haste"   )
            elseif buff.spoils_of_neltharus_mastery.up then applyBuff( "spoils_of_neltharus_mastery" )
            elseif buff.spoils_of_neltharus_vers.up    then applyBuff( "spoils_of_neltharus_vers"    ) end
        end,

        auras = {
            spoils_of_neltharus_crit = {
                id = 381954,
                duration = 20,
                max_stack = 1,
            },
            spoils_of_neltharus_haste = {
                id = 381955,
                duration = 20,
                max_stack = 1,
            },
            spoils_of_neltharus_mastery = {
                id = 381956,
                duration = 20,
                max_stack = 1,
            },
            spoils_of_neltharus_vers = {
                id = 381957,
                duration = 20,
                max_stack = 1
            }
        }
    },
    stormeaters_boon = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 194302,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "stormeaters_boon" )
            applyDebuff( "player", "rooted", 10 )
        end,

        proc = "damage",

        auras = {
            stormeaters_boon = {
                id = 377453,
                duration = 10,
                max_stack = 1
            }
        }
    },
    timebreaching_talon = {
        cast = 0,
        cooldown = 150,
        gcd = "off",

        item = 193791,
        toggle = "cooldowns",

        proc = "primary",
        self_buff = "power_theft",

        handler = function()
            applyBuff( "power_theft" )
        end,

        auras = {
            power_theft = {
                id = 382126,
                duration = 15,
                max_stack = 1,
            },
            price_of_power = {
                id = 384050,
                duration = 15,
                max_stack = 1
            },
        }
    },
    tome_of_unstable_power = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 193628,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "tome_of_unstable_power" )
        end,

        proc = "primary",
        self_buff = "tome_of_unstable_power",

        auras = {
            tome_of_unstable_power = {
                id = 388583,
                duration = 15,
                max_stack = 1
            }
        }
    },
    torrent_callers_shell = {
        cast = 3,
        channeled = true,
        cooldown = 150,
        gcd = "off",

        item = 200552,
        toggle = "cooldowns"
    },
    treemouths_festering_splinter = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 193652,
        toggle = "defensives",

        handler = function()
            applyBuff( "treemouths_festering_splinter" )
        end,

        proc = "absorb",

        auras = {
            treemouths_festering_splinter = {
                id = 395175,
                duration = 15,
                max_stack = 1
            }
        }
    },
    uncanny_pocketwatch = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 195220,
        toggle = "interrupts",

        handler = function()
            applyBuff( "pocketwatch_acceleration" )
        end,

        proc = "speed",
        self_buff = "pocketwatch_acceleration",

        auras = {
            pocketwatch_acceleration = {
                id = 381609,
                duration = 8,
                max_stack = 1
            }
        }
    },
    waters_beating_heart = {
        cast = 8,
        channeled = true,
        cooldown = 120,
        gcd = "off",

        item = 193736,
        toggle = "defensives",

        start = function()
            applyBuff( "waters_beating_heart" )
        end,

        auras = {
            waters_beating_heart = {
                id = 383934,
                duration = 8,
                tick_time = 2,
                max_stack = 1,
                dot = "buff"
            }
        }
    },


    -- Shadowmoon Burial Grounds
    bonemaws_big_toe = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 110012,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "bonemaws_big_toe" )
        end,

        proc = "crit",
        self_buff = "bonemaws_big_toe",

        auras = {
            bonemaws_big_toe = {
                id = 397400,
                duration = 20,
                max_stack = 1
            }
        }
    },
    voidmenders_shadowgem = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 110007,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "voidmenders_shadowgem" )
        end,

        proc = "crit",
        self_buff = "voidmenders_shadowgem",

        auras = {
            voidmenders_shadowgem = {
                id = 397399,
                duration = 15,
                max_stack = 1
            }
        }
    },

    -- Trial of Valor
    gift_of_radiance = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 133647,
    },

    -- 10.0.7
    winterpelt_totem = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 202268,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "winterpelts_blessing" )
        end,

        auras = {
            winterpelts_blessing = {
                id = 398293,
                duration = 20,
                max_stack = 1
            }
        }
    }
} )


-- 10.1
-- TODO: Add triggers to specs' cooldowns.
all:RegisterGear( "neltharions_call_to_dominance", 204202 )
all:RegisterAuras( {
    domineering_arrogance = {
        id = 411661,
        duration = 10,
        max_stack = 10
    },
    call_to_dominance = {
        id = 403380,
        duration = 10,
        max_stack = 10
    }
} )

all:RegisterGear( "neltharions_call_to_suffering", 204211 )
all:RegisterAura( "call_to_suffering", {
    id = 403386,
    duration = 12,
    max_stack = 1
} )

all:RegisterGear( "neltharions_call_to_chaos", 204201 )
all:RegisterAura( "call_to_chaos", {
    id = 403382,
    duration = 18,
    max_stack = 1
} )

all:RegisterGear( "igneous_flowstone", 203996 )
all:RegisterAuras( {
    igneous_ebb_tide = {
        id = 402898,
        duration = 30,
        max_stack = 1
    },
    igneous_low_tide = {
        id = 402896,
        duration = 60,
        max_stack = 1
    },
    igneous_fury = {
        id = 402897,
        duration = 12,
        max_stack = 1
    },

    igneous_flood_tide = {
        id = 402894,
        duration = 30,
        max_stack = 1
    },
    igneous_high_tide = {
        id = 402903,
        duration = 60,
        max_stack = 1
    },
} )

all:RegisterGear( "ominous_chromatic_essence", 203729 )
all:RegisterAuras( {
    obsidian_resonance = {
        id = 402221,
        duration = 3600,
        max_stack = 1
    },
    ruby_resonance = {
        id = 401516,
        duration = 3600,
        max_stack = 1
    },
    bronze_resonance = {
        id = 401518,
        duration = 3600,
        max_stack = 1
    },
    azure_resonance = {
        id = 401519,
        duration = 3600,
        max_stack = 1
    },
    emerald_resonance = {
        id = 401521,
        duration = 3600,
        max_stack = 1
    },

    minor_obsidian_resonance = {
        id = 405615,
        duration = 3600,
        max_stack = 1
    },
    minor_ruby_resonance = {
        id = 405613,
        duration = 3600,
        max_stack = 1
    },
    minor_bronze_resonance = {
        id = 405612,
        duration = 3600,
        max_stack = 1
    },
    minor_azure_resonance = {
        id = 405611,
        duration = 3600,
        max_stack = 1
    },
    minor_emerald_resonance = {
        id = 405608,
        duration = 3600,
        max_stack = 1
    },
} )

all:RegisterGear( "rashoks_molten_heart", 202614 )
all:RegisterAuras( {
    molten_radiance = {
        id = 409898,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    molten_overflow = {
        id = 401187,
        duration = 12,
        max_stack = 1
    }
} )

all:RegisterGear( "vessel_of_searing_shadow", 202615 )
all:RegisterAuras( {
    ravenous_shadowflame = {
        id = 401428,
        duration = 12,
        tick_time = 2,
        max_stack = 1
    },
    unstable_flames = {
        id = 401394,
        duration = 30,
        max_stack = 5
    }
} )

all:RegisterGear( "buzzing_orb_core", 204387 )
all:RegisterAuras( {
    buzzing_intensifies = {
        id = 405197,
        duration = 3600,
        max_stack = 120
    },
    orb_activated = {
        id = 405202,
        duration = 20,
        max_stack = 1
    },
} )

all:RegisterGear( "stirring_twilight_ember", 205200 )
all:RegisterAuras( {
    stirring_twilight_ember = {
        id = 409067,
        duration = 10,
        tick_time = 2,
        max_stack = 1
    },
    twilight_celerity = {
        id = 409077,
        duration = 10,
        max_stack = 1
    }
} )

all:RegisterGear( "underlight_globe", 205191 )

-- Drogbar Rocks / Drogbar Stones
all:RegisterAuras( {
    drogbar_stones = {
        id = 407904,
        duration = 10,
        max_stack = 1
    },
    might_of_the_drogbar = {
        id = 407913,
        duration = 10,
        max_stack = 1
    }
} )


all:RegisterAbilities( {
    beacon_to_the_beyond = {
        cast = function() return 2 * haste end,
        cooldown = 150,
        gcd = "off",

        item = 203963,
        toggle = "cooldowns",

        handler = function()
        end,

        copy = "anshuul_the_cosmic_wanderer"
    },

    ward_of_faceless_ire = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 203714,

        handler = function()
            applyBuff( "writhing_ward" )
        end,

        auras = {
            writhing_ward = {
                id = 401238,
                duration = 10,
                max_stack = 1
            },

            writhing_ire = {
                id = 401257,
                duration = 6,
                tick_time = 1,
                max_stack = 1
            }
        }
    },

    screaming_black_dragonscale = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 202612,
        toggle = "interrupts", -- utility.

        usable = function() return target.minR > 15, "only does damage if jumping 15+ yards" end,

        handler = function()
            setDistance( 5 )
            applyBuff( "seething_descent" )
        end,

        auras = {
            seething_descent = {
                id = 405940,
                duration = 5,
                max_stack = 1
            },

            screaming_flight = {
                id = 401469,
                duration = 15,
                max_stack = 1
            }
        }
    },

    dragonfire_bomb_dispenser = {
        cast = 0,
        charges = 3,
        cooldown = 30,
        recharge = 30,
        gcd = "off",
        icd = 10,

        item = 202610,
        no_icd = true, -- Does not trigger trinket CD, but looks confusing next to the icd.

        handler = function()
            applyDebuff( "target", "dragonfire_bomb_dispenser" )
        end,

        auras = {
            dragonfire_bomb_dispenser = {
                id = 408675,
                duration = 7,
                max_stack = 1
            },
            flash_of_inspiration = {
                id = 408770,
                duration = 3600,
                max_stack = 60
            }
        }
    },

    elementium_pocket_anvil = {
        cast = 0.5,
        cooldown = 60,
        gcd = "off",

        item = 202617,
        no_icd = true,

        handler = function()
            addStack( "anvil_strike", nil, 1 )
        end,


        auras = {
            anvil_strike = {
                id = 408578,
                duration = 3600,
                max_stack = 5,
                copy = { "anvil_strike_combat", 408533, "anvil_strike_no_combat" }
            }
        }
    },

    zaqali_chaos_grapnel = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 202613,
        toggle = "cooldowns",

        handler = function()
            setDistance( 5 )
        end,
    },

    enduring_dreadplate = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 202616,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "enduring_dreadplate", nil, 5 )
        end,

        auras = {
            hellsteel_plating = {
                id = 400986,
                duration = 15,
                max_stack = 5
            }
        }
    },

    smoldering_lava_puffer = {
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        item = 203987,
        nobuff = "volcanic_heartburn",

        handler = function()
            applyBuff( "volcanic_heartburn" )
        end,

        auras = {
            volcanic_heartburn = {
                id = 402685,
                duration = 3600,
                max_stack = 1
            }
        }
    },

    draconic_cauterizing_magma = {
        cast = 2.5,
        channeled = true,
        cooldown = 120,
        gcd = "spell",

        item = 204388,
        toggle = "defensives",

        handler = function()
            applyBuff( "cauterizing_shield" )
        end,

        auras = {
            cauterizing_shield = {
                id = 405109,
                duration = 2.5,
                max_stack = 1
            },
            cauterizing_flame = {
                id = 405068,
                duration = 2.5,
                max_stack = 1
            }
        }
    },

    pocket_darkened_elemental_core = {
        cast = 1,
        cooldown = 90,
        gcd = "off",

        item = 204386,
        toggle = "cooldowns",

        handler = function()
        end,
    },

    magma_serpent_lure = {
        cast = 0,
        cooldown = 150,
        gcd = "off",

        item = 205229,
        toggle = "cooldowns",

        handler = function()
        end,
    },

    heatbound_medallion = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 204736,
        toggle = "cooldowns",

        handler = function()
        end,
    },

    satchel_of_healing_spores = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 204714,
        toggle = "defensives",

        handler = function()
            applyBuff( "satchel_of_healing_spores" )
        end,

        auras = {
            satchel_of_healing_spores = {
                id = 406448,
                duration = 15,
                max_stack = 1
            }
        }
    },

    friendship_censer = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 204728,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "friendship_censer" )
        end,

        auras = {
            encouraging_friend = {
                id = 406485,
                duration = 20,
                max_stack = 1
            },
            angry_friend = {
                id = 406488,
                duration = 2,
                max_stack = 1
            }
        }
    },

    magmaclaw_lure = {
        cast = 0,
        cooldown = 150,
        gcd = "off",

        item = 205262,
        toggle = "defensives",

        handler = function()
            applyBuff( "magmaclaw_lure" )
        end,

        auras = {
            magmaclaw_lure = {
                id = 409296,
                duration = 10,
                max_stack = 1
            }
        }
    },

    zaqali_hand_cannon = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 205196,
        toggle = "cooldowns",

        handler = function()
            applyDebuff( "target", "zaqali_hand_cannon" )
        end,

        auras = {
            magma_pour = {
                id = 408635,
                duration = 8,
                tick_time = 2,
                max_stack = 1
            }
        }
    },

    deepflayer_lure = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 205276,
        toggle = "defensives",

        handler = function()
            applyBuff( "deepflayers_tenacity" )
        end,

        auras = {
            deepflayers_tenacity = {
                id = 409347,
                duration = 10,
                max_stack = 1
            }
        }
    },

    fractured_crystalspine_quill = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 205194,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "fractured_crystalspine_quill" )
        end,

        auras = {
            fractured_crystalspine_quill = {
                id = 408625,
                duration = 15,
                max_stack = 1
            }
        }
    },

    smoldering_howler_horn = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 205201,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "smoldering_howl" )
        end,

        auras = {
            smoldering_howl = {
                id = 408652,
                duration = 20,
                max_stack = 1
            }
        }
    },

    sturdy_deepflayer_scute = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 205193,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "sturdy_deepflayer_scute" )
        end,

        auras = {
            sturdy_deepflayer_scute = {
                id = 408612,
                duration = 15,
                max_stack = 1
            }
        }
    },

    -- Other slots.
    djaruun_pillar_of_the_elder_flame = {
        cast = 0,
        cooldown = 150,
        gcd = "off",

        item = 202569,
        no_icd = true,
        toggle = "cooldowns",

        handler = function()
        end,

        auras = {
            seething_rage = {
                id = 408835,
                duration = 10,
                max_stack = 1
            }
        }
    },

    shadowed_razing_annihilator = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 205046,
        toggle = "cooldowns",

        handler = function()
        end,
    },

    -- Patch 10.1.5
    mirror_of_fractured_tomorrows = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 207581,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "mirror_of_fractured_tomorrows" )
        end,

        proc = "primary",
        self_buff = "mirror_of_fractured_tomorrows",

        auras = {
            mirror_of_fractured_tomorrows = {
                id = 418527,
                duration = 20,
                max_stack = 1
            }
        }
    },

    echoing_tyrstone = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 207552,
        toggle = "defensives",
		
        usable = function() return buff.echoing_tyrstone_stored.down, "don't use when stored healing was not spent" end,

        handler = function()
            applyBuff( "echoing_tyrstone_stored" )
        end,

        auras = {
            echoing_tyrstone = {
                id = 417939,
                duration = 10,
                max_stack = 1
            },
            echoing_tyrstone_stored = {
                id = 417967,
                duration = 3600,
                max_stack = 1
            }
        }
    },


    paracausal_fragment_of_frostmourne = {
        cast = 2,
        cooldown = 150,
        gcd = "off",

        item = 206983,
        toggle = "cooldowns",

        usable = function() return buff.lost_soul.stack > 9, "requires lost souls" end,

        handler = function()
            removeBuff( "lost_soul" )
        end,

        auras = {
            lost_soul = {
                id = 415007,
                duration = 3600,
                max_stack = 10
            },
        }
    },


    iridal_the_earths_master = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 208321,
        toggle = "cooldowns",

        usable = function() return target.health_pct < 35, "requires target below 35% health" end,

        handler = function()
        end,
    },


    timethiefs_gambit = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 207579,
        toggle = "essences",

        handler = function()
            applyBuff( "timethiefs_gambit" )
            applyDebuff( "player", "paradox" )
        end,

        proc = "haste",
        self_buff = "timethiefs_gambit",

        auras = {
            timethiefs_gambit = {
                id = 417534,
                duration = 15,
                max_stack = 1
            },
            paradox = {
                id = 417543,
                duration = 120,
                max_stack = 1
            }
        }
    },


    paracausal_fragment_of_doomhammer = {
        cast = 1.5,
        cooldown = 90,
        gcd = "spell",

        item = 206964,
        toggle = "cooldowns",

        handler = function()
        end,
    },


    paracausal_fragment_of_shalamayne = {
        cast = 1.5,
        cooldown = 90,
        gcd = "spell",

        item = 207024,
        toggle = "cooldowns",

        handler = function()
        end,
    },


    -- 10.2

    ashes_of_the_embersoul = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 207167,
        toggle = "cooldowns",

        proc = "primary",
        self_buff = "soul_ignition",

        handler = function()
            applyBuff( "soul_ignition" )
        end,

        auras = {
            soul_ignition = {
                id = 423611,
                duration = 20,
                tick_time = 3,
                max_stack = 6
            },
            blazing_soul = {
                id = 426911,
                duration = 20,
                tick_time = 3,
                max_stack = 6
            },
            burned_out = {
                id = 426897,
                duration = 60,
                max_stack = 1
            }
        }
    },

    bandolier_of_twisted_blades = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 207165,
        toggle = "cooldowns",

        handler = function()
            applyDebuff( "target", "embed_blade" )
        end,

        auras = {
            embed_blade = {
                id = 422303,
                duration = 3,
                max_stack = 1
            }
        }
    },

    belorrelos_the_suncaller = {
        cast = 2,
        cooldown = 120,
        gcd = "off",

        item = 207172,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "solar_maelstrom" )
        end,

        proc = "damage",

        auras = {
            solar_maelstrom = {
                id = 425417,
                duration = 12,
                tick_time = 3,
                max_stack = 1
            }
        }
    },

    branch_of_the_tormented_ancient = {
        cast = 0,
        cooldown = 150,
        gcd = "off",

        item = 207169,
        toggle = "cooldowns",

        proc = "damage",

        handler = function()
            applyBuff( "roots_of_the_tormented_ancient", nil, 4 )
        end,

        auras = {
            roots_of_the_tormented_ancient = {
                id = 422441,
                duration = 4,
                max_stack = 1
            }
        }
    },

    fyrakks_tainted_rageheart = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 207174,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "shadowflame_rage" )
        end,

        proc = "absorb",
        self_buff = "shadowflame_rage",

        auras = {
            shadowflame_rage = {
                id = 422750,
                duration = 10,
                max_stack = 1
            }
        }
    },

    nymues_unraveling_spindle = {
        cast = 3,
        channeled = true,
        cooldown = 120,
        gcd = "off",

        item = 208615,
        toggle = "cooldowns",

        start = function()
            applyBuff( "nymues_vengeful_spindle" )
        end,

        proc = "mastery",
        self_buff = "nymues_vengeful_spindle",

        auras = {
            nymues_vengeful_spindle = {
                id = 427072,
                duration = 18,
                max_stack = 1
            }
        },

        copy = 422956
    },

    smoldering_seedling = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 207170,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "smoldering_seedling" )
        end,

        proc = "mastery",
        self_buff = "smoldering_seedling",

        auras = {
            smoldering_seedling = {
                id = 426566,
                duration = 12,
                max_stack = 1
            },
            seedlings_thanks = {
                id = 426624,
                duration = 10,
                max_stack = 1
            }
        }
    },

    witherbarks_branch = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 109999,
        toggle = "cooldowns",

        proc = "mastery",
        self_buff = "aqueous_enrichment",

        handler = function()
            -- Do nothing; it's up to the player to collect orbs.
        end,

        auras = {
            aqueous_enrichment = {
                id = 429262,
                duration = 10,
                max_stack = 3
            }
        }
    },

    dreambinder_loom_of_the_great_cycle = {
        cast = 2,
        channeled = true,
        cooldown = 120,
        gcd = "off",

        item = 208616,
        toggle = "cooldowns",

        start = function()
            applyBuff( "web_of_dreams" )
        end,

        auras = {
            web_of_dreams = {
                id = 427112,
                duration = 6,
                max_stack = 1
            }
        }
    },

    leaf_of_the_ancient_protectors = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 110009,
        toggle = "defensives",

        handler = function()
            applyBuff( "ancient_protection" )
        end,

        proc = "absorb",
        self_buff = "ancient_protection",

        auras = {
            ancient_protection = {
                id = 429271,
                duration = 15,
                max_stack = 1
            },
            ancient_resurgence = {
                id = 429272,
                duration = 15,
                max_stack = 1
            }
        }
    },

    -- Everbloom
    spores_of_alacrity = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 110014,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "alacritous_spores" )
        end,

        proc = "haste",
        self_buff = "alacritous_spores",

        auras = {
            alacritous_spores = {
                id = 429276,
                duration = 20,
                max_stack = 10 -- Ticks down?
            }
        }
    },

    -- Throne of the Tides
    might_of_the_ocean = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 133197,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "tidehunters_blessing" )
        end,

        proc = "primary",
        self_buff = "tidehunters_blessing",

        auras = {
            tidehunters_blessing = {
                id = 91340,
                duration = 20,
                max_stack = 1
            }
        }
    },

    -- Legendary
    fyralath_the_dreamrender = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 206448,
        toggle = "cooldowns",

        handler = function()
            removeDebuff( "target", "mark_of_fyralath" )
            active_dot.mark_of_fyralath = 0
            setDistance( 5 )
        end,

        auras = {
            mark_of_fyralath = {
                id = 414532,
                duration = 15,
                max_stack = 1
            },
        },

        copy = { "fyralath_the_dream_render", "rage_of_fyralath_417131" }
    },

    -- Missed items?
    granyths_enduring_scale = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 212757,
        toggle = "defensives",

        handler = function()
            applyBuff( "granyths_enduring_scale" )
        end,

        auras = {
            granyths_enduring_scale = {
                id = 434064,
                duration = 20,
                max_stack = 20
            }
        }
    }
} )
