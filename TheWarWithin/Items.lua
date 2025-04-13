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

        proc = "secondary",
        self_buff = "bolstering_light",

        handler = function()
            applyBuff( "bolstering_light")
        end,

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

        copy = "bursting_lightshard"
    },

    mereldars_toll = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 219313,
        toggle = "cooldowns",

        proc = "damage",

        handler = function()
            applyDebuff( "target", "mereldars_toll_stack", nil, 5 )
        end,

        auras = {
            mereldars_toll_stack = {
                id = 443539,
                duration = 20,
                max_stack = 5
            },
            blessing_of_mereldar = {
                id = 450551,
                duration = 10,
                max_stack = 1
            }
        }
    },

    charged_stormrook_plume = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 219294,
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

        auras = {
            overclock = {
                id = 450453,
                duration = 15,
                max_stack = 1
            }
        }
    },

    skarmorak_shard = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 219300,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "skarmorak_shard" )
        end,

        proc = "mastery",
        self_buff = "skarmorak_shard",

        auras = {
            crystalline_coalescence = {
                id = 449792,
                duration = 15,
                max_stack = 5
            },
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

        item = 219318,
        toggle = "cooldowns",
        buff = "oppressive_orators_influence",

        proc = "damage",
        self_buff = "oppressive_orators_influence",

        handler = function()
            removeBuff( "oppressive_orators_influence" )
            applyDebuff( "target", "oppressive_oration" )
        end,

        auras = {
            oppressive_orators_influence = {
                id = 451011,
                duration = 30,
                max_stack = 10,
                copy = 443540
            },
            oppressive_oration = {
                id = 443552,
                duration = 3,
                tick_time = 1,
                max_stack = 1
            }
        },
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
        cooldown = 90,
        gcd = "off",

        item = 221023,
        toggle = "cooldowns",

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
    },

    abyssal_trap = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 215170,
        toggle = "essences",

        proc = "damage",
    },

    arathi_demolition_charge = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 220118,
        toggle = "cooldowns",

        proc = "damage",
    },

    bronzebeard_family_compass = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 219916,
        toggle = "cooldowns",

        proc = "primary",
        self_buff = "bronzebeard_family_compass",

        handler = function()
            applyBuff( "bronzebeard_family_compass" )
        end,

        auras = {
            bronzebeard_family_compass = { -- may be hidden.
                id = 444265,
                duration = 10,
                max_stack = 1
            }
        }
    },

    burin_of_the_candle_king = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 219306,
        toggle = "cooldowns",

        proc = "absorb",

    },

    concoction_kiss_of_death = {
        cast = 0,
        cooldown = function() return buff.concoction_kiss_of_death.up and 150 or 0 end,
        gcd = "off",

        item = 215174,
        toggle = function() return buff.concoction_kiss_of_death.down and "cooldowns" or nil end,

        buff = function() return buff.concoction_kiss_of_death.up and buff.concoction_kiss_of_death.remains < 3 and "concoction_kiss_of_death" or nil end,
        nobuff = function() return buff.concoction_kiss_of_death.up and buff.concoction_kiss_of_death.remains >= 3 and "concoction_kiss_of_death" or nil end,

        proc = "secondary",
        self_buff = "concoction_kiss_of_death",

        handler = function()
            if buff.concoction_kiss_of_death.down then
                applyBuff( "concoction_kiss_of_death" )
            else removeBuff( "concoction_kiss_of_death" ) end
        end,

        auras = {
            concoction_kiss_of_death = {
                id = 435493,
                duration = 30,
                max_stack = 1
            }
        }
    },

    creeping_coagulum = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 219917,
        toggle = "cooldowns",

        proc = "healing", -- sort of
        self_buff = "creeping_coagulum",

        handler = function()
            applyBuff( "creeping_coagulum" )
        end,

        auras = {
            creeping_coagulum = {
                id = 444282,
                duration = 30,
                max_stack = 1
            },
            lingering_effluvia = {
                id = 453211,
                duration = 15,
                max_stack = 1
            }
        }
    },

    delve_ring = {
        cast = 2.5,
        channeled = true,
        cooldown = 120,
        gcd = "off",

        item = 219299,
        toggle = "cooldowns",

        proc = "absorb",
        self_buff = "cauterizing_flame",

        start = function()
            applyBuff( "cauterizing_flame" )
        end,

        auras = {
            cauterizing_flame = {
                id = 405068,
                duration = 2.5,
                max_stack = 1
            }
        }
    },

    fearbreakers_echo = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 224449,
        toggle = "cooldowns",

        proc = "damage",
    },

    foul_behemoths_chelicera = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 219915,

        proc = "damage",

        handler = function()
            applyDebuff( "target", "digestive_venom" )
        end,

        auras = {
            digestive_venom = {
                id = 444264,
                duration = 20,
                tick_time = 2,
                max_stack = 1
            }
        }
    },

    goldenglow_censer = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 225656,

        proc = "absorb",
        self_buff = "golden_glow",

        handler = function()
            applyBuff( "golden_glow" )
        end,

        auras = {
            golden_glow = {
                id = 455486,
                duration = 15,
                max_stack = 1
            }
        }
    },

    high_speakers_accretion = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 219303,
        toggle = "cooldowns",

        proc = "damage",

        auras = {
            shadowy_accretion = {
                id = 451248,
                duration = 20,
                max_stack = 1
            }
        }
    },

    horn_of_declaration = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 217041,
        toggle = "cooldowns",

        proc = "mastery",
        self_buff = "horn_of_declaration",

        handler = function()
            applyBuff( "horn_of_declaration" )
        end,

        auras = {
            horn_of_declaration = {
                id = 438753,
                duration = 10,
                max_stack = 1
            }
        }
    },

    imperfect_ascendancy_serum = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 225654,
        toggle = "cooldowns",

        proc = "primary",
        self_buff = "ascension",

        handler = function()
            applyBuff( "ascension" )
        end,

        auras = {
            ascension = {
                id = 455482,
                duration = 20,
                max_stack = 1
            }
        }
    },

    kaheti_shadeweavers_emblem = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 225651,
        toggle = "cooldowns",
        buff = "kaheti_shadeweavers_dark_ritual",

        proc = "damage",

        handler = function()
            removeBuff( "kaheti_shadeweavers_dark_ritual" )
        end,

        auras = {
            kaheti_shadeweavers_dark_ritual = {
                id = 455464,
                duration = 30,
                max_stack = 10
            }
        }
    },

    mad_queens_mandate = {
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        item = 212454,
        toggle = "cooldowns",

        proc = "damage",
    },

    messageimprinted_silken_square = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 226166,
        toggle = "cooldowns",

        proc = "mastery",
        self_buff = "silken_square_pheromones",

        handler = function()
            applyBuff( "silken_square_pheromones" )
        end,

        auras = {
            silken_square_pheromones = {
                id = 458132,
                duration = 12,
                max_stack = 1
            }
        }
    },

    ovinaxs_mercurial_egg = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 220305,
        toggle = "cooldowns",

        proc = "primary",
        self_buff = "suspended_incubation",

        usable = function()
            return buff.deliberate_incubation.stack + buff.reckless_incubation.stack > 25, "arbitrarily requiring 26+ stacks"
        end,

        handler = function()
            applyBuff( "suspended_incubation" )
        end,

        auras = {
            suspended_incubation = {
                id = 445560,
                duration = 20,
                max_stack = 1
            },
            deliberate_incubation = {
                id = 449578,
                duration = 3600,
                max_stack = 30
            },
            reckless_incubation_haste = {
                id = 449581,
                duration = 3600,
                max_stack = 30
            },
            reckless_incubation_mastery = {
                id = 449594,
                duration = 3600,
                max_stack = 30
            },
            reckless_incubation_crit = {
                id = 449593,
                duration = 3600,
                max_stack = 30
            },
            reckless_incubation_vers = {
                id = 449595,
                duration = 3600,
                max_stack = 30
            },
            reckless_incubation = {
                alias = { "reckless_incubation_haste", "reckless_incubation_mastery", "reckless_incubation_crit", "reckless_incubation_vers" },
                aliasMode = "first",
                aliasType = "buff",
                duration = 3600,
            }
        }
    },

    quickwick_candlestick = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 225649,
        items = { 225648, 225649 },
        toggle = "cooldowns",

        proc = "haste",
        self_buff = "quickwicks_quick_trick_wick_walk", -- goddamnit

        handler = function()
            applyBuff( "quickwicks_quick_trick_wick_walk" )
        end,

        auras = {
            quickwicks_quick_trick_wick_walk = {
                id = 455451,
                duration = 20,
                max_stack = 1
            }
        }
    },

    shriveled_ancient_tentacle = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 223509,
        toggle = "cooldowns",

        proc = "damage",
    },

    sikrans_endless_arsenal = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 212449,
        toggle = "essences",

        proc = "damage", -- lie.

        auras = {
            stance_surekian_flourish = {
                id = 447962,
                duration = 3600,
                max_stack = 1
            },
            stance_surekian_decimation = {
                id = 447978,
                duration = 3600,
                max_stack = 1
            },
            stance_surekian_barrage = {
                id = 448036,
                duration = 3600,
                max_stack = 5
            }
        }
    },

    silken_chain_weaver = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 215172,
        toggle = "defensives",

        proc = "absorb", -- ?
        self_buff = "silken_chain_weaver",

        handler = function()
            applyDebuff( "target", "silken_chain_weaver" ) -- ??
            applyBuff( "silken_chain_weaver" )
        end,

        auras = {
            silken_chain_weaver = {
                id = 435482,
                duration = 15,
                max_stack = 1
            }
        }
    },

    skyterrors_corrosive_organ = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 212453,
        toggle = "cooldowns",

        proc = "damage",

        handler = function()
            applyDebuff( "target", "volatile_acid" )
        end,

        auras = {
            volatile_acid = {
                id = 447471,
                duration = 20,
                tick_time = 1,
                max_stack = 1
            }
        }
    },

    swarmlords_authority = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 212450,
        toggle = "essences",

        proc = "damage",

        handler = function()
            applyBuff( "ravenous_swarm" )
        end,

        auras = {
            ravenous_swarm = {
                id = 444301,
                duration = 3,
                max_stack = 1
            }
        }
    },

    tome_of_lights_devotion = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 219309,
        toggle = "defensives",

        proc = "absorb",
        self_buff = "radiance",

        handler = function()
            applyBuff( "radiance" )
        end,

        auras = {
            radiance = {
                id = 443534,
                duration = 20,
                max_stack = 1
            },
            inner_radiance = {
                id = 450720,
                duration = 20,
                max_stack = 1
            },
            inner_resilience = {
                id = 450706,
                duration = 20,
                max_stack = 1
            },
            ward_of_devotion = {
                id = 450719,
                duration = 20,
                max_stack = 1
            },
        }
    },

    twin_fang_instruments = {
        cast = 0,
        cooldown = 120,
        gcd = "off",
        icd = function() return gcd.max end,

        item = 219319,
        toggle = "cooldowns",

        proc = "damage",

        handler = function()
            if buff.twin_fang_instruments.down then
                applyBuff( "twin_fang_instruments", nil, 2 )
                setCooldown( "twin_fang_instruments", 0 )
                return
            end

            removeStack( "twin_fang_instruments" )

            if buff.twin_fang_instruments.up then
                setCooldown( "twin_fang_instruments", 0 )
            end
        end,

        auras = {
            twin_fang_instruments = {
                id = 450157,
                duration = 20,
                max_stack = 2
            }
        }
    },

    viscous_coaglam = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 219320,
        toggle = "interrupts",

        proc = "absorb",

        -- Cannot find these auras.
    },

    mark_of_khadros = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 133300,
        toggle = "cooldowns",

        proc = "mastery",
        self_buff = "battle_prowess",

        handler = function()
            applyBuff( "battle_prowess" )
        end,

        auras = {
            battle_prowess = {
                id = 91374,
                duration = 15,
                max_stack = 1
            }
        }
    },

    -- Anniversary
    burst_of_knowledge = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 231424,
        toggle = "cooldowns",

        proc = "primary",
        self_buff = "burst_of_knowledge",

        handler = function()
            applyBuff( "burst_of_knowledge" )
        end,

        auras = {
            burst_of_knowledge = {
                id = 469925,
                duration = 20,
                max_stack = 20
            }
        }
    },

    living_flame_trinket = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 155947,
        toggle = "cooldowns",

        proc = "primary",
        self_buff = "living_flame_buff",

        handler = function ()
            applyBuff( "living_flame_buff" )
        end,

        auras = {
            living_flame_buff = {
                id = 64712,
                duration = 20,
                max_stack = 1
            }
        }
    },

    -- https://www.wowhead.com/item=169344/ingenious-mana-battery
    ingenious_mana_battery = {
        cast = 8,
        channeled = true,
        cooldown = 60,
        gcd = "spell",

        item = 169344,
        toggle = "cooldowns",
        proc = "versatility",

        start = function()
            applyBuff( "ingenious_mana_battery_mana" )
            applyBuff( "ingenious_mana_battery_vers" )
        end,

        auras = {
            ingenious_mana_battery = {
                alias = { "ingenious_mana_battery_mana", "ingenious_mana_battery_vers" },
                aliasMode = "first",
                aliasType = "buff",
                duration = 3600
            },
            ingenious_mana_battery_mana = {
                id = 300989,
                duration = 3600,
                max_stack = 1
            },
            ingenious_mana_battery_vers = {
                id = 300970,
                durration = 3600,
                max_stack = 1
            },
        }
    },
} )

all:RegisterGear( "bestinslots_melee", 232526 )
all:RegisterGear( "bestinslots_caster", 232805 )
-- all:RegisterGear( "bestinslots", 232526, 232805 )

all:RegisterAbilities( {
    -- 11.1
    ringing_ritual_mud = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 232543,
        toggle = "defensives",

        proc = "defensive",
        self_buff = "mudborne",

        handler = function ()
            applyBuff( "mudborne" )
        end,

        auras = {
            mudborne = {
                id = 1219102,
                duration = 10,
                max_stack = 1
            }
        }
    },

    darkfuse_medichopper = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 232542,
        toggle = "defensives",

        proc = "defensive",

        handler = function ()
        end,
    },

    kuj0s_flame_vents = {
        cast = 2,
        channeled = true,
        cooldown = 120,
        gcd = "off",

        item = 232546,
        toggle = "cooldowns",

        proc = "damage",
        self_buff = "kuj0s_flame_vents",

        handler = function ()
            applyBuff( "kuj0s_flame_vents" )
        end,

        auras = {
            kuj0s_flame_vents = {
                id = 1218716,
                duration = 2,
                max_stack = 1,
                copy = "kujos_flame_vents"
            },
        },

        copy = "kujos_flame_vents"
    },

    house_of_cards = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 230027,
        toggle = "cooldowns",

        proc = "mastery",
        self_buff = "house_of_cards",

        handler = function ()
            removeBuff( "stacked_deck" )
            applyBuff( "house_of_cards" )
        end,

        auras = {
            house_of_cards = {
                id = 466681,
                duration = 15,
                max_stack = 1
            },
            stacked_deck = {
                id = 1219158,
                duration = 3600,
                max_stack = 3
            }
        }
    },


   --[[ reconfiguring_for_melee_combat = {
        id = 473401,
        item = 232805,
        cast = 5,
        cooldown = 30,
        gcd = "spell",

        texture = 6218212,

        known = function() return equipped.bestinslots_caster and not ( InCombatLockdown() or time > 0 ) and spec.primaryStat ~= "intellect" end,
    },

    reconfiguring_for_spell_Casting = {
        id = 473400,
        item = 232526,
        cast = 5,
        cooldown = 30,
        gcd = "spell",

        texture = 6218212,

        known = function() return equipped.bestinslots_melee and not ( InCombatLockdown() or time > 0 ) and spec.primaryStat == "intellect" end,

    },--]]

    bestinslots = {
        cast = 0,
        cooldown = 120,
        gcd = "off",
        texture = 6218212,

        -- known = function() return equipped.bestinslots end,
        usable = function() return time > 0, "Not usable out of combat" end,

        item = function() return equipped.bestinslots_caster and 232805 or 232526 end,
        items = { 232526, 232805 },
        toggle ="cooldowns",

        proc = "secondary",
        self_buff = "cheating",

        handler = function ()
            if time > 0 then applyBuff( "cheating" ) end
        end,

        auras = {
            cheating = {
                id = 473402,
                duration = 15,
                max_stack = 1
            }
        },
    },

    test_pilots_gopack = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 228844,
        toggle = "interrupts",

        proc = "speed",
        self_buff = "test_pilots_gopack",

        handler = function ()
            applyBuff( "test_pilots_gopack" )
        end,

        auras = {
            test_pilots_gopack = {
                id = 471383,
                duration = 1,
                max_stack = 1
            }
        }
    },

    -- skip mister_locknstalk ?

    geargrinders_spare_keys = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 230197,
        toggle = "cooldowns",

        proc = "damage",

        handler = function ()
        end,
    },

    chromebustible_bomb_suit = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 230029,
        toggle = "defensives",

        proc = "defensive",
        self_buff = "chromebustible_bomb_suit",

        handler = function ()
            applyBuff( "chromebustible_bomb_suit" )
        end,

        auras = {
            chromebustible_bomb_suit = {
                id = 466810,
                duration = 20,
                max_stack = 1
            }
        }
    },

    junkmaestros_mega_magnet = {
        cast = 0,
        cooldown = 20,
        gcd = "off",

        item = 230189,

        proc = "damage",
        usable = function() return buff.junkmaestros_mega_magnet.stack > 28 end,

        handler = function ()
            removeBuff( "junkmaestros_mega_magnet" )
        end,

        auras = {
            junkmaestros_mega_magnet = {
                id = 1219661,
                duration = 3600,
                max_stack = 30
            }
        }
    },

    gallagio_bottle_service = {
        cast = 4,
        channeled = true,
        cooldown = 90,
        gcd = "spell",

        item = 230188,
        toggle = "cooldowns",

        proc = "healing",
    },

    flarendos_pilot_light = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 230191,
        toggle = "cooldowns",

        proc = "intellect",
        self_buff = "flarendos_pilot_light",

        handler = function ()
            applyBuff( "flarendos_pilot_light" )
        end,

        auras = {
            flarendos_pilot_light = {
                id = 471142,
                duration = 15,
                max_stack = 1
            }
        }
    },

    vexies_pit_whistle = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 230019,
        toggle = "cooldowns",

        proc = "damage",

        -- idk
    },

    torqs_big_red_button = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 230190,
        toggle = "cooldowns",

        proc = "strength",
        self_buff = "torqs_big_red_button",

        handler = function ()
            applyBuff( "torqs_big_red_button" )
        end,

        auras = {
            torqs_big_red_button = {
                id = 470286,
                duration = 15,
                max_stack = 1
            }
        }
    },

    funhouse_lens = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 234217,
        toggle = "cooldowns",

        proc = "secondary",
        self_buff = "funhouse_lens",

        handler = function ()
            applyBuff( "funhouse_lens" )
        end,

        auras = {
            funhouse_lens_crit = {
                id = 1213433,
                duration = 15,
                max_stack = 1
            },

            funhouse_lens_haste = {
                id = 1213434,
                duration = 15,
                max_stack = 1,
            },

            funhouse_lens = {
                aliasType = "buff",
                alias = { "funhouse_lens_crit", "funhouse_lens_haste" },
                aliasMode = "first",
                duration = 15
            }
        }
    },

    noggenfogger_ultimate_deluxe = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 232486,
        toggle = "cooldowns",

        proc = "damage",
    },

    ratfang_toxin = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 235359,
        proc = "damage",

        handler = function ()
            removeDebuff( "target", "ratfang_toxin" )
        end,

        auras = {
            ratfang_toxin = {
                id = 1213433,
                duration = 20,
                max_stack = 5
            }
        }
    },

    blastmaster3000 = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 234717,
        proc = "damage",
    },

    gooblin_grenade = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 234218,
        toggle = "cooldowns",

        proc = "damage",

        handler = function()
            applyDebuff( "target", "gooblin_grenade" )
        end,

        auras = {
            gooblin_grenade = {
                id = 1213436,
                duration = 10,
                max_stack = 1
            }
        }
    },

    abyssal_volt = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 235373,
        toggle = "cooldowns",

        proc = "haste",
        self_buff = "abyssal_volt",

        handler = function ()
            applyBuff( "abyssal_volt" )
        end,

        auras = {
            abyssal_volt = {
                id = 1216770,
                duration = 15,
                max_stack = 1
            }
        }
    },

    core_recycling_unit = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 234326,
        toggle = "defensives",

        usable = function() return buff.core_recycling_unit.stack > 10 and health.pct < 60 end,

        proc = "healing",
        self_buff = "core_recycling_unit",

        handler = function ()
            removeBuff( "core_recycling_unit" )
        end,

        auras = {
            core_recycling_unit = {
                id = 1213758,
                duration = 3600,
                max_stack = 20
            }
        }
    },

    garbagemancers_last_resort = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 235984,
        toggle = "cooldowns",

        proc = "damage",
    },

    anodized_deflectors = {
        cast = 0,
        cooldown = 30,
        gcd = "off",

        item = 168978,
        toggle = "defensives",

        proc = "avoidance",
        self_buff = "anodized_deflectors",

        handler = function ()
            applyBuff( "anodized_deflectors" )
        end,

        auras = {
            anodized_deflectors = {
                id = 300140,
                duration = 6,
                max_stack = 1,
            }
        }
    },
} )

all:RegisterGear( "scroll_of_momentum", 226539 )

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
    },
    ascendance_crit = {
        id = 458502,
        duration = 15,
        max_stack = 1
    },
    ascendance_mastery = {
        id = 458525,
        duration = 15,
        max_stack = 1
    },

    -- Refracting Aggression Module
    refracting_resistance = {
        id = 451568,
        duration = 30,
        max_stack = 1
    },

    -- Scroll of Momentum
    building_momentum = {
        id = 459224,
        duration = 30,
        max_stack = 5
    },
    full_momentum = {
        id = 459228,
        duration = 10,
        max_stack = 1
    }
} )
