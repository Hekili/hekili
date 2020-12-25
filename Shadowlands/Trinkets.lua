-- Shadowlands/Trinkets.lua
-- November 2020

local addon, ns = ...
local Hekili = _G[ addon ]

local all = Hekili.Class.specs[ 0 ]


-- 9.0 Trinkets
do
    -- Trinket auras (not on-use effects)    
    all:RegisterAuras( {
        anima_field = {
            id = 345535,
            duration = 8,
            max_stack = 1
        },

        beating_abomination_core = {
            id = 336871,
            duration = 15,
            max_stack = 1
        },

        booksmart = {
            id = 340020,
            duration = 12,
            max_stack = 1,
        },

        -- Boon of the Archon
        -- ???

        crimson_chorus = {
            id = 344803,
            duration = 10,
            max_stack = 1
        },

        consumptive_infusion_proc = {
            id = 344225,
            duration = 15,
            max_stack = 1
        },

        consumptive_infusion = {
            id = 344227,
            duration = 10,
            max_stack = 1
        },

        dreamers_mending = {
            id = 339738,
            duration = 120,
            max_stack = 1,
        },

        everchill_brambles = {
            id = 339301,
            duration = 12,
            max_stack = 10,
        },

        everchill_brambles_root = {
            id = 339309,
            duration = 2,
            max_stack = 1
        },

        mote_of_anger = {
            id = 71432,
            duration = 3600,
            max_stack = 8
        },

        synaptic_feedback = {
            id = 344118,
            duration = 15,
            max_stack = 1
        },

        -- Murmurs in the Dark
        fall_of_night = {
            id = 339342,
            duration = 12,
            max_stack = 1
        },

        end_of_night = {
            id = 339341,
            duration = 8,
            max_stack = 1
        },
        -- End Murmurs

        phial_of_putrefaction = {
            id = 345464,
            duration = 10,
            max_stack = 1,
        },

        primalists_kelpling = {
            id = 268522,
            duration = 15,
            max_stack = 1
        },

        rejuvenating_serum = {
            id = 326377,
            duration = 6,
            max_stack = 1,
        },

        critical_resistance = {
            id = 336371,
            duration = 20,
            max_stack = 3
        },

        stone_legionnaire = {
            id = 344686,
            duration = 3600,
            max_stack = 1
        },

        caustic_liquid = {
            id = 329737,
            duration = 8,
            max_stack = 1
        },
    } )


    all:RegisterAbilities( {
        bargasts_leash = {
            cast = 0,
            cooldown = 120,
            gcd = "off",

            item = 184017,
            toggle = "defensives",
            defensive = true,

            handler = function ()
                applyBuff( "huntsmans_bond" )
            end,

            usable = function ()
                return incoming_damage_3s > 0 and health.pct < 70, "requires incoming damage and health below 70 percent"
            end,

            auras = {
                huntsmans_bond = {
                    id = 344388,
                    duration = 30,
                    max_stack = 1
                }
            }
        },

        bladedancers_armor_kit = {
            cast = 0,
            cooldown = 300,
            gcd = "off",

            item = 178862,
            toggle = "cooldowns", -- TODO:  Review.

            handler = function ()
                applyBuff( "bladedancers_armor" )
            end,

            auras = {
                bladedancers_armor = {
                    id = 342423,
                    duration = 120,
                    max_stack = 1
                }
            }
        },

        bloodspattered_scale = {
            cast = 0,
            cooldown = 120,
            gcd = "off",

            item = 179331,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "blood_barrier" )
            end,

            auras = {
                blood_barrier = {
                    id = 329840,
                    duration = 10,
                    max_stack = 1
                },
            },
        },

        bottled_flayedwing_toxin = {
            cast = 0,
            cooldown = 1,
            gcd = "off",

            item = 178742,

            readyTime = function ()
                if combat > 0 then return buff.flayedwing_toxin.remains end
                return buff.flayedwing_toxin.remains - 600
            end,
            handler = function ()
                applyBuff( "flayedwing_toxin" )
            end,

            auras = {
                flayedwing_toxin = {
                    id = 345545,
                    duration = 3600,
                    max_stack = 1,
                }
            }
        },

        brimming_ember_shard = {
            cast = 6,
            channeled = true,
            cooldown = 90,
            gcd = "spell",

            item = 175733,
            toggle = "cooldowns",
        },

        darkmoon_deck_indomitable = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 173096,
            toggle = "defensives",
            defensive = true,

            handler = function ()
                applyBuff( "indomitable_deck" )
            end,

            auras = {
                indomitable_deck = {
                    id = 311444,
                    duration = 10,
                    max_stack = 1
                }
            }
        },

        darkmoon_deck_putrescence = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 173069,
            toggle = "cooldowns",

            handler = function ()
                applyDebuff( "target", "putrid_burst" )
            end,

            auras = {
                putrid_burst = {
                    id = 334058,
                    duration = 10,
                    max_stack = 1
                }
            },

            copy = "darkmoon_deck__putrescence" -- simc
        },

        darkmoon_deck_repose = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 173078,
        },

        darkmoon_deck_voracity = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 173087,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "voracious_haste" )
                applyDebuff( "target", "voracious_lethargy" )
            end,

            auras = {
                voracious_haste = {
                    id = 311491,
                    duration = 20,
                    max_stack = 1
                },

                voracious_lethargy = {
                    id = 329449,
                    duration = 20,
                    max_stack = 1
                }
            }
        },

        dreadfire_vessel = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 184030,
            toggle = "cooldowns",
        },

        empyreal_ordnance = {
            cast = 0.5,
            cooldown = 180,
            gcd = "off",

            item = 180117,
            toggle = "cooldowns",

            handler = function ()
                applyDebuff( "target", "empyreal_ordnance" )
                active_dot.empyreal_ordnance = min( 5, active_enemies )
            end,

            auras = {
                empyreal_ordnance = {
                    id = 345540,
                    duration = 10,
                    max_stack = 1
                },

                empyreal_surge = {
                    id = 345541,
                    duration = 15,
                    max_stack = 1
                }
            }
        },

        flame_of_battle = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 181501,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "flame_of_battle" )
            end,

            auras = {
                flame_of_battle = {
                    id = 336841,
                    duration = 6,
                    max_stack = 1,
                }
            }
        },

        glyph_of_assimilation = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 184021,
            toggle = "cooldowns",

            handler = function ()
                applyDebuff( "target", "glyph_of_assimilation" )
            end,

            auras = {
                glyph_of_assimilation = {
                    id = 345319,
                    duration = 10,
                    max_stack = 1
                },

                glyph_of_assimilation_buff = {
                    id = 345320,
                    duration = 20,
                    max_stack = 1
                }
            }
        },

        grim_codex = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 178811,
            toggle = "cooldowns",
        },

        inscrutable_quantum_device = {
            cast = 0,
            cooldown = 180,
            gcd = "off",

            item = 179350,
            toggle = "cooldowns",

            auras = {
                inscrutable_quantum_device_crit = {
                    id = 330366,
                    duration = 30,
                    max_stack = 1
                },
                inscrutable_quantum_device_vers = {
                    id = 330367,
                    duration = 30,
                    max_stack = 1
                },
                inscrutable_quantum_device_haste = {
                    id = 330368,
                    duration = 30,
                    max_stack = 1
                },
                inscrutable_quantum_device_mastery = {
                    id = 330380,
                    duration = 30,
                    max_stack = 1
                },
                inscrutable_quantum_device = {
                    alias = { "inscrutable_quantum_device_crit", "inscrutable_quantum_device_vers", "inscrutable_quantum_device_haste", "inscrutable_quantum_device_mastery" },
                    aliasMode = "first",
                    aliasType = "buff",
                    duration = 30                    
                }
            }
        },

        lingering_sunmote = {
            cast = 0,
            cooldown = 120,
            gcd = "off",

            item = 178850,
            toggle = "defensives",
            defensive = true,

            handler = function ()
                applyBuff( "suns_embrace" )
            end,

            auras = {
                suns_embrace = {
                    id = 342435,
                    duration = 10,
                    max_stack = 1,
                }
            }
        },

        lyre_of_sacred_purpose = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 184841,
            toggle = "defensives",
            defensive = true,

            handler = function ()
                applyBuff( "lyre_of_sacred_purpose" )
            end,

            auras = {
                lyre_of_sacred_purpose = {
                    id = 348136,
                    duration = 15,
                    max_stack = 1
                }
            }
        },

        instructors_divine_bell = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 184842,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "instructors_divine_bell" )
            end,

            auras = {
                instructors_divine_bell = {
                    id = 348139,
                    duration = 9,
                    max_stack = 1
                }
            }
        },

        macabre_sheet_music = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 184024,
            toggle = "cooldowns",

            auras = {
                blood_waltz = {
                    id = 345439,
                    duration = 20,
                    max_stack = 1
                }
            }
        },

        maldraxxian_warhorn = {
            cast = 0,
            cooldown = 120,
            gcd = "off",

            item = 180827,
            toggle = "cooldowns",
        },

        manabound_mirror = {
            cast = 0,
            cooldown = 60,
            gcd = "off",

            item = 184029,

            handler = function ()
                removeBuff( "manabound_mirror" )
            end,

            auras = {
                manabound_mirror = {
                    id = 344244,
                    duration = 30,
                    max_stack = 1
                }
            }
        },

        memory_of_past_sins = {
            cast = 0,
            cooldown = 120,
            gcd = "off",

            item = 184025,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "shattered_psyche" )
            end,

            auras = {
                shattered_psyche = {
                    id = 344662,
                    duration = 30,
                    max_stack = 1,
                },

                shattered_psyche_debuff = {
                    id = 344663,
                    duration = 5,
                    max_stack = 1
                },
            }
        },

        overcharged_anima_battery = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 180116,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "overcharged_anima_battery" )
            end,

            auras = {
                overcharged_anima_battery = {
                    id = 345530,
                    duration = 16,
                    max_stack = 1
                }
            }
        },

        overflowing_anima_cage = {
            cast = 0,
            cooldown = 270,
            gcd = "off",

            item = 178849,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "anima_infusion" )
            end,

            auras = {
                anima_infusion = {
                    id = 343386,
                    duration = 15,
                    max_stack = 1
                }
            }
        },

        overflowing_ember_mirror = {
            cast = 0,
            cooldown = 270,
            gcd = "off",

            item = function ()
                if equipped[ 177657 ] then return 177657 end
                return 181359
            end,
            items = { 177657, 181359 },
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "pulsating_light_shield" )
            end,

            auras = {
                pulsating_light_shield = {
                    id = 336465,
                    duration = 12,
                    max_stack = 1
                }
            }
        },

        overwhelming_power_crystal = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 179342,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "power_overwhelming" )
            end,

            auras = {
                power_overwhelming = {
                    id = 329831,
                    duration = 15,
                    max_stack = 1
                }
            }
        },

        pulsating_stoneheart = {
            cast = 0,
            cooldown = 75,
            gcd = "off",

            item = 178825,
            toggle = "defensives",
            defensive = true,

            handler = function ()
                applyBuff( "heart_of_a_gargoyle" )
            end,

            auras = {
                heart_of_a_gargoyle = {
                    id = 343399,
                    duration = 12,
                    max_stack = 1,
                }
            }
        },

        sanguine_vintage = {
            cast = 0,
            cooldown = 60,
            gcd = "off",

            item = 184031,

            handler = function ()
                applyBuff( "sanguine_vintage" )
            end,

            auras = {
                sanguine_vintage = {
                    id = 344231,
                    duration = 6,
                    max_stack = 1
                }
            }
        },

        shadowgrasp_totem = {
            cast = 0,
            cooldown = 120,
            gcd = "off",

            item = 179356,
            toggle = "cooldowns",
        },

        siphoning_phylactery_shard = {
            cast = 0,
            cooldown = 30,
            gcd = "off",

            item = 178783,
            
            handler = function ()
                applyBuff( "charged_phylactery" )
            end,

            auras = {
                charged_phylactery = {
                    id = 345549,
                    duration = 30,
                    max_stack = 1
                }
            }
        },

        skulkers_wing = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 184016,
            toggle = "cooldowns",

            -- ???
        },

        slimy_consumptive_organ = {
            cast = 0,
            cooldown = 20,
            gcd = "off",

            item = 178770,
            toggle = "defensives",
            defensive = true,

            buff = "gluttonous",

            usable = function () return buff.gluttonous.stack > 8 and health.percent < 80, "requires gluttonous stacks and a health deficit" end,

            handler = function ()
                removeBuff( "gluttonous" )
            end,

            auras = {
                gluttonous = {
                    id = 334511,
                    duration = 3600,
                    max_stack = 9
                }
            }
        },

        soul_igniter = {
            cast = 0,
            cooldown = function () return debuff.soul_ignition.down and 0.5 or 60 end,
            gcd = "off",

            item = 184019,
            toggle = "cooldowns",

            handler = function ()
                if debuff.soul_ignition.down then
                    applyDebuff( "player", "soul_ignition" )
                else
                    -- Blazing Surge.
                    removeDebuff( "soul_ignition" )
                end
            end,

            auras = {
                soul_ignition = {
                    id = 345211,
                    duration = 15,
                    max_stack = 1
                }
            }
        },

        soulletting_ruby = {
            cast = 0,
            cooldown = 120,
            gcd = "off",

            item = 178809,
            toggle = "cooldowns",

            handler = function ()
                applyDebuff( "target", "soulletting_ruby" )
            end,

            auras = {
                soul_infusion = {
                    id = 345805,
                    duration = 16,
                    max_stack = 1
                },

                soulletting_ruby = {
                    id = 345801,
                    duration = 20,
                    max_stack = 1,
                }
            },

            copy = "soul_infusion"
        },

        spare_meat_hook = {
            cast = 0,
            cooldown = 120,
            gcd = "off",

            item = 178751,
            toggle = "cooldowns",

            handler = function ()
                applyDebuff( "target", "spare_meat_hook" )
            end,

            auras = {
                spare_meat_hook = {
                    id = 345548,
                    duration = 10,
                    max_stack = 1
                }
            }
        },

        sunblood_amethyst = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 178826,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "anima_font" )
            end,

            auras = {
                anima_font = {
                    id = 343396,
                    duration = 15,
                    max_stack = 1
                }
            }
        },

        tablet_of_despair = {
            cast = 0,
            cooldown = 120,
            gcd = "off",

            item = 175732,
            toggle = "cooldowns",

            handler = function ()
                applyDebuff( "target", "growing_despair" )
            end,

            auras = {
                growing_despair = {
                    id = 336182,
                    duration = 25,
                    max_stack = 1
                }
            }
        },

        tuft_of_smoldering_plumage = {
            cast = 0,
            cooldown = 120,
            gcd = "off",

            item = 184020,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "tuft_of_smoldering_plumage" )
            end,

            auras = {
                tuft_of_smoldering_plumage = {
                    id = 344916,
                    duration = 6,
                    max_stack = 1
                }
            }
        },

        vial_of_spectral_essence = {
            cast = 0,
            cooldown = 90,
            gcd = "off",

            item = 178810,
            toggle = "cooldowns",

            handler = function ()
                applyDebuff( "target", "vial_of_spectral_essence" )
            end,

            auras = {
                vial_of_spectral_essence = {
                    id = 345695,
                    duration = 20,
                    max_stack = 1
                }
            }
        },

        wakeners_frond = {
            cast = 0,
            cooldown = 120,
            gcd = "off",

            item = 181457,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "wakeners_frond" )
            end,

            auras = {
                wakeners_frond = {
                    id = 336588,
                    duration = 12,
                    max_stack = 1
                }
            },
        },
    } )
end