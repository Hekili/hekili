-- TheWarWithin/Classes.lua

local addon, ns = ...
local Hekili = _G[ addon ]
local class = Hekili.Class

if Hekili.CurrentBuild < 110000 then return end

-- spellFilters[ instanceID ][ npcID ][ spellID ] = { name = ..., interrupt = true, ... }
local spellFilters = {
    [ 670 ] = {
        name = "Grim Batol",
        [ 40167 ] = {
            name = "Twilight Beguiler",
            --[[ [ 76369 ] = {
                name = "Sear Mind",
                interrupt = true,
            }, -- Either wrong ID, or just used for testing.  I can't find Sear Mind via Wowhead. ]]
            [ 76369 ] = {
                name = "Shadowflame Bolt",
                spell_reflection = true
            },
        },
        [ 40166 ] = {
            name = "Molten Giant",
            [ 451971 ] = {
                name = "Lava Fist",
                spell_reflection = true,
            },
        },
        [ 40319 ] = {
            name = "Drahga Shadowburner",
            [ 447966 ] = {
                name = "Shadowflame Bolt",
                spell_reflection = true,
            },
        },
        [ 224219 ] = {
            name = "Twilight Earthcaller",
            [ 451871 ] = {
                name = "Mass Tremor",
                interrupt = true,
            },
        },
        [ 224240 ] = {
            name = "Twilight Flamerender",
            [ 451241 ] = {
                name = "Shadowflame Slash",
                spell_reflection = true,
            },
        },
        [ 224271 ] = {
            name = "Twilight Warlock",
            [ 76369 ] = {
                name = "Shadowflame Bolt",
                spell_reflection = true,
            },
        },
    },

    [ 1594 ] = {
        name = "The MOTHERLODE!!",
        [ 130661 ] = {
            name = "Venture Co. Earthshaper",
            [ 263202 ] = {
                name = "Rock Lance",
                spell_reflection = true,
            },
            [ 271579 ] = {
                name = "Rock Lance",
                spell_reflection = true,
            },
        },
        [ 136139 ] = {
            name = "Mechanized Peacekeeper",
            [ 263628 ] = {
                name = "Charged Shield",
                spell_reflection = true,
            },
        },
        [ 136934 ] = {
            name = "Weapons Tester",
            [ 268846 ] = {
                name = "Echo Blade",
                spell_reflection = true,
            },
        },
        [ 136470 ] = {
            name = "Refreshment Vendor",
            [ 280604 ] = {
                name = "Iced Spritzer",
                spell_reflection = true,
            },
        },
    },

    [ 1822 ] = {
        name = "Siege of Boralus",
        [ 129367 ] = {
            name = "Bilge Rat Tempest",
            [ 272571 ] = {
                name = "Choking Waters",
                interrupt = true,
            },
        },
        [ 128969 ] = {
            name = "Ashvane Commander",
            [ 275826 ] = {
                name = "Bolstering Shout",
                interrupt = true,
            },
        },
        [ 129367 ] = {
            name = "Bilge Rat Tempest",
            [ 272581 ] = {
                name = "Water Bolt",
                spell_reflection = true,
            },
        },
        [ 129370 ] = {
            name = "Irontide Waveshaper",
            [ 256957 ] = {
                name = "Watertight Shell",
                interrupt = true,
            },
            [ 257063 ] = {
                name = "Brackish Bolt",
                spell_reflection = true,
            },
        },
        [ 135241 ] = {
            name = "Bilge Rat Pillager",
            [ 454440 ] = {
                name = "Stinky Vomit",
                interrupt = true,
            },
        },
        [ 135258 ] = {
            name = "Irontide Curseblade",
            [ 257168 ] = {
                name = "Cursed Slash",
                spell_reflection = true,
            },
        },
        [ 138247 ] = {
            name = "Irontide Curseblade",
            [ 257168 ] = {
                name = "Cursed Slash",
                spell_reflection = true,
            },
        },
        [ 141284 ] = {
            name = "Kul Tiran Wavetender",
            [ 256957 ] = {
                name = "Watertight Shell",
                interrupt = true,
            },
        },
        [ 144071 ] = {
            name = "Irontide Waveshaper",
            [ 256957 ] = {
                name = "Watertight Shell",
                interrupt = true,
            },
            [ 257063 ] = {
                name = "Brackish Bolt",
                spell_reflection = true,
            },
        },
    },

    [ 2097 ] = {
        name = "Operation: Mechagon",
        [ 144294 ] = {
            name = "Mechagon Tinkerer",
            [ 293827 ] = {
                name = "Giga-Wallop",
                spell_reflection = true,
            },
        },
        [ 144298 ] = {
            name = "Defense Bot Mk III",
            [ 294195 ] = {
                name = "Arcing Zap",
                spell_reflection = true,
            },
        },
        [ 150396 ] = {
            name = "Aerial Unit R-21/X",
            [ 291878 ] = {
                name = "Pulse Blast",
                spell_reflection = true,
            },
        },
        [ 151649 ] = {
            name = "Defense Bot Mk I",
            [ 294195 ] = {
                name = "Arcing Zap",
                spell_reflection = true,
            },
        },
        [ 152033 ] = {
            name = "Inconspicuous Plant",
            [ 294855 ] = {
                name = "Blossom Blast",
                spell_reflection = true,
            },
        },
    },

    [ 2286 ] = {
        name = "The Necrotic Wake",
        [ 162693 ] = {
            name = "Nalthor the Rimebinder",
            [ 323730 ] = {
                name = "Frozen Binds",
                spell_reflection = true,
            },
            [ 320788 ] = {
                name = "Frozen Binds",
                spell_reflection = true,
            },
        },
        [ 163126 ] = {
            name = "Brittlebone Mage",
            [ 320336 ] = {
                name = "Frostbolt",
                spell_reflection = true,
            },
        },
        [ 163128 ] = {
            name = "Zolramus Sorcerer",
            [ 320462 ] = {
                name = "Necrotic Bolt",
                spell_reflection = true,
            },
            [ 333479 ] = {
                name = "Spew Disease",
                spell_reflection = true,
            },
            [ 333482 ] = {
                name = "Disease Cloud",
                spell_reflection = true,
            },
            [ 333485 ] = {
                name = "Disease Cloud",
                spell_reflection = true,
            },
        },
        [ 163618 ] = {
            name = "Zolramus Necromancer",
            [ 320462 ] = {
                name = "Necrotic Bolt",
                spell_reflection = true,
            },
        },
        [ 164815 ] = {
            name = "Zolramus Siphoner",
            [ 322274 ] = {
                name = "Enfeeble",
                spell_reflection = true,
            },
        },
        [ 165137 ] = {
            name = "Zolramus Gatekeeper",
            [ 320462 ] = {
                name = "Necrotic Bolt",
                spell_reflection = true,
            },
            [ 323347 ] = {
                name = "Clinging Darkness",
                spell_reflection = true,
            },
        },
        [ 165222 ] = {
            name = "Zolramus Bonemender",
            [ 335143 ] = {
                name = "Bonemend",
                interrupt = true,
            },
        },
        [ 165824 ] = {
            name = "Nar'zudah",
            [ 320462 ] = {
                name = "Necrotic Bolt",
                spell_reflection = true,
            },
        },
        [ 165872 ] = {
            name = "Flesh Crafter",
            [ 327130 ] = {
                name = "Repair Flesh",
                interrupt = true,
            },
        },
        [ 165919 ] = {
            name = "Skeletal Marauder",
            [ 324293 ] = {
                name = "Rasping Scream",
                interrupt = true,
            },
        },
        [ 166302 ] = {
            name = "Corpse Harvester",
            [ 334748 ] = {
                name = "Drain Fluids",
                interrupt = true,
                spell_reflection = true,
            },
        },
        [ 171095 ] = {
            name = "Grisly Colossus",
            [ 324293 ] = {
                name = "Rasping Scream",
                interrupt = true,
            },
        },
        [ 173016 ] = {
            name = "Corpse Collector",
            [ 334748 ] = {
                name = "Drain Fluids",
                interrupt = true,
            },
            [ 338353 ] = {
                name = "Goresplatter",
                interrupt = true,
            },
        },
        [ 173044 ] = {
            name = "Stitching Assistant",
            [ 334748 ] = {
                name = "Drain Fluids",
                interrupt = true,
            },
        },

    },

    [ 2290 ] = {
        name = "Mists of Tirna Scithe",
        [ 164517 ] = {
            name = "Tred'ova",
            [ 322450 ] = {
                name = "Consumption",
                interrupt = true,
            },
            [ 337235 ] = {
                name = "Parasitic Pacification",
                interrupt = true,
            },
        },
        [ 164567 ] = {
            name = "Ingra Maloch",
            [ 323057 ] = {
                name = "Spirit Bolt",
                spell_reflection = true,
            },
        },
        [ 164920 ] = {
            name = "Drust Soulcleaver",
            [ 322557 ] = {
                name = "Soul Split",
                spell_reflection = true,
            },
        },
        [ 164921 ] = {
            name = "Drust Harvester",
            [ 322767 ] = {
                name = "Spirit Bolt",
                spell_reflection = true,
            },
            [ 322938 ] = {
                name = "Harvest Essence",
                interrupt = true,
            },
            [ 326319 ] = {
                name = "Spirit Bolt",
                spell_reflection = true,
            },
        },
        [ 164926 ] = {
            name = "Drust Boughbreaker",
            [ 324923 ] = {
                name = "Bramble Burst",
                interrupt = true,
                spell_reflection = true,
            },
        },
        [ 164929 ] = {
            name = "Tirnenn Villager",
            [ 322486 ] = {
                name = "Overgrowth",
                spell_reflection = true,
            },
        },
        [ 166275 ] = {
            name = "Mistveil Shaper",
            [ 324776 ] = {
                name = "Bramblethorn Coat",
                interrupt = true,
            },
        },
        [ 166276 ] = {
            name = "Mistveil Guardian",
            [ 463217 ] = {
                name = "Anima Slash",
                spell_reflection = true,
            },
        },
        [ 166299 ] = {
            name = "Mistveil Tender",
            [ 324914 ] = {
                name = "Nourish the Forest",
                interrupt = true,
            },
        },
        [ 166304 ] = {
            name = "Mistveil Stinger",
            [ 325223 ] = {
                name = "Anima Injection",
                spell_reflection = true,
            },
        },
        [ 167111 ] = {
            name = "Spinemaw Staghorn",
            [ 326046 ] = {
                name = "Stimulate Resistance",
                interrupt = true,
            },
            [ 340544 ] = {
                name = "Stimulate Regeneration",
                interrupt = true,
            },
        },
        [ 172991 ] = {
            name = "Drust Soulcleaver",
            [ 322557 ] = {
                name = "Soul Split",
                spell_reflection = true,
            },
        },
    },

    [ 2293 ] = {
        name = "Theater of Pain",
        [ 160495] = {
            name = "Maniacal Soulbinder",
            [ 330784 ] = {
                name = "Necrotic Bolt",
                spell_reflection = true,
            },
        },
        [ 162309 ] = {
            name = "Kul'tharok",
            [  319669 ] = {
                name = "Spectral Reach",
                spell_reflection = true,
            },
            [ 1216475 ] = {
                name = "Necrotic Bolt",
                spell_reflection = true,
            },
        },
        [ 164461 ] = {
            name = "Sathel the Accursed",
            [ 1217138 ] = {
                name = "Necrotic Bolt",
                spell_reflection = true,
            },
			[ 324079 ] = {
				name = "Reaping Scythe",
				blessing_of_spellwarding = true,
			},
        },
        [ 165946 ] = {
            name = "Mordretha, the Endless Empress",
            [ 323608 ] = {
                name = "Dark Devastation",
                spell_reflection = true,
            },
        },
        [ 166524 ] = {
            name = "Deathwalker",
            [ 324589 ] = {
                name = "Death Bolt",
                spell_reflection = true,
            },
        },
        [ 169875 ] = {
            name = "Shackled Soul",
            [ 330810 ] = {
                name = "Bind Soul",
                spell_reflection = true,
            },
        },
        [ 169893 ] = {
            name = "Nefarious Darkspeaker",
            [ 330875 ] = {
                name = "Spirit Frost",
                spell_reflection = true,
            },
        },
        [ 170690 ] = {
            name = "Diseased Horror",
            [ 330697 ] = {
                name = "Decaying Strike",
                spell_reflection = true,
            },
        },
        [ 174197 ] = {
            name = "Battlefield Ritualist",
            [ 330784 ] = {
                name = "Necrotic Bolt",
                spell_reflection = true,
            },
        },
        [ 174210 ] = {
            name = "Blighted Sludge-Spewer",
            [ 341969 ] = {
                name = "Withering Discharge",
                spell_reflection = true,
            },
        },
    },

    [ 2552 ] = {
        name = "Khaz Algar Surface",
        [ 225977 ] = {
            name = "Dungeoneer's Training Dummy",
            [ 167385 ] = {
                name = "Uber Strike",
                spell_reflection = true, -- for testing
				blessing_of_spellwarding = true, -- for testing
            },
        },
    },

    [ 2601 ] = {
        name = "Khaz Algar Underground",
        [ 223469 ] = {
            name = "Voidtouched Speaker",
            [ 429545 ] = {
                name = "Censoring Gear",
                interrupt = true,
            },
        },
    },

    [ 2648 ] = {
        name = "The Rookery",
        [ 207202 ] = {
            name = "Void Fragment",
            [ 430238 ] = {
                name = "Void Bolt",
                spell_reflection = true,
            },
        },
        [ 207198 ] = {
            name = "Cursed Thunderer",
            [ 430109 ] = {
                name = "Lightning Bolt",
                spell_reflection = true,
            },
        },
        [ 212793 ] = {
            name = "Void Ascendant",
            [ 432959 ] = {
                name = "Void Volley",
                interrupt = true,
            },
        },
        [ 214421 ] = {
            name = "Coalescing Void Diffuser",
            [ 430805 ] = {
                name = "Arcing Void",
                interrupt = true,
                spell_reflection = true,
            },
        },
        [ 214439 ] = {
            name = "Corrupted Oracle",
            [ 430179 ] = {
                name = "Seeping Corruption",
                spell_reflection = true,
            },
        },
		[ 207207 ] = {
			name = "Voidstone Monstrosity",
			[ 445457 ] = {
				name = "Oblivion Wave",
				blessing_of_spellwarding = true,
			},
		},
    },

    [ 2649 ] = {
        name = "Priory of the Sacred Flame",
        [ 206697 ] = {
            name = "Devout Priest",
            [ 427356 ] = {
                name = "Greater Heal",
                interrupt = true,
            },
            [ 427357 ] = {
                name = "Holy Smite",
                spell_reflection = true,
            },
        },
        [ 206698 ] = {
            name = "Fanatical Conjuror",
            [ 427469 ] = {
                name = "Fireball",
                spell_reflection = true,
            },
        },
        [ 207939 ] = {
            name = "Baron Braunpyke",
            [ 423015 ] = {
                name = "Castigator's Shield",
                spell_reflection = true,
            },
            [ 423051 ] = {
                name = "Burning Light",
                interrupt = true,
            },
        },
        [ 207940 ] = {
            name = "Prioress Murrpray",
            [ 423536 ] = {
                name = "Holy Smite",
                spell_reflection = true,
            },
			[ 444608 ] = {
				name = "Inner Fire",
				blessing_of_spellwarding = true,
			},
        },
        [ 207946 ] = {
            name = "Captain Dailcry",
            [ 424419 ] = {
                name = "Battle Cry",
                interrupt = true,
            },
        },
        [ 211289 ] = {
            name = "Taener Duelmal",
            [ 424420 ] = {
                name = "Cinderblast",
                interrupt = true,
                spell_reflection = true,
            },
            [ 424421 ] = {
                name = "Fireball",
                spell_reflection = true,
            },
			[ 424462 ] = {
				name = "Ember Storm",
				blessing_of_spellwarding = true,
			},
        },
        [ 221760 ] = {
            name = "Risen Mage",
            [ 427469 ] = {
                name = "Fireball",
                spell_reflection = true,
            },
            [ 444743 ] = {
                name = "Fireball Volley",
                interrupt = true,
            },
        },
        [ 212827 ] = {
            name = "High Priest Aemya",
            [ 427357 ] = {
                name = "Holy Smite",
                spell_reflection = true,
            },
        },
		[ 217658 ] = {
			name = "Sir Braunpyke",
			[ 435165 ] = {
				name = "Blazing Strike",
				blessing_of_spellwarding = true,
			},
		},
		[ 206710 ] = {
			name = "Lightspawn",
			[ 448787 ] = {
				name = "Purification",
				blessing_of_spellwarding = true,
			},
		},
    },

    [ 2651 ] = {
        name = "Darkflame Cleft",
        [ 208743 ] = {
            name = "Blazikon",
            [ 421638 ] = {
                name = "Wicklighter Barrage",
                spell_reflection = true,
            },
            [ 421817 ] = {
                name = "Wicklighter Barrage",
                spell_reflection = true,
            },
        },
        [ 208745 ] = {
            name = "The Candle King",
            [ 426145 ] = {
                name = "Paranoid Mind",
                interrupt = true,
            },
        },
        [ 208747 ] = {
            name = "The Darkness",
            [ 427157 ] = {
                name = "Call Darkspawn",
                interrupt = true,
            },
        },
        [ 210812 ] = {
            name = "Royal Wicklighter",
            [ 423479 ] = {
                name = "Wicklighter Bolt",
                spell_reflection = true,
            },
        },
        [ 212412 ] = {
            name = "Sootsnout",
            [ 426295 ] = {
                name = "Flaming Tether",
                interrupt = true,
            },
            [ 426677 ] = {
                name = "Candleflame Bolt",
                spell_reflection = true,
            },
        },
        [ 213913 ] = {
            name = "Kobold Flametender",
            [ 428563 ] = {
                name = "Flame Bolt",
                spell_reflection = true,
            },
        },
		[ 210539 ] = {
			name = "Corridor Creeper",
			[ 469620 ] = {
				name = "Creeping Shadow",
				blessing_of_spellwarding = true,
			},
		},
    },

    [ 2652 ] = {
        name = "The Stonevault",
        [ 212389 ] = {
            name = "Cursedheart Invader",
            [ 426283 ] = {
                name = "Arcing Void",
                interrupt = true,
                spell_reflection = true,
            },
        },
        [ 212403 ] = {
            name = "Cursedheart Invader",
            [ 426283 ] = {
                name = "Arcing Void",
                interrupt = true,
                spell_reflection = true,
            },
        },
        [ 212453 ] = {
            name = "Ghastly Voidsoul",
            [ 449455 ] = {
                name = "Howling Fear",
                interrupt = true,
            },
        },
        [ 212765 ] = {
            name = "Void Bound Despoiler",
            [ 459210 ] = {
                name = "Shadow Claw",
                spell_reflection = true,
            },
        },
        [ 213217 ] = {
            name = "Speaker Brokk",
            [ 428161 ] = {
                name = "Molten Metal",
                spell_reflection = true,
            },
        },
        [ 213338 ] = {
            name = "Forgebound Mender",
            [ 429109 ] = {
                name = "Restoring Metals",
                interrupt = true,
            },
            [ 429110 ] = {
                name = "Alloy Bolt",
                spell_reflection = true,
            },
        },
        [ 214066 ] = {
            name = "Cursedforge Stoneshaper",
            [ 429422 ] = {
                name = "Stone Bolt",
                spell_reflection = true,
            },
        },
        [ 214350 ] = {
            name = "Turned Speaker",
            [ 429545 ] = {
                name = "Censoring Gear",
                interrupt = true,
                spell_reflection = true,
            },
        },
        [ 221979 ] = {
            name = "Void Bound Howler",
            [ 445207 ] = {
                name = "Piercing Wail",
                interrupt = true,
            },
        },
        [ 224962 ] = {
            name = "Cursedforge Mender",
            [ 429109 ] = {
                name = "Restoring Metals",
                interrupt = true,
            },
        },
    },

    [ 2657 ] = {
        name = "Nerub-ar Palace",
        [ 201792 ] = {
            name = "Nexus-Princess Ky'veza",
            [ 437839 ] = {
                name = "Nether Rift",
                interrupt = true,
            },
            [ 436787 ] = {
                name = "Regicide",
                interrupt = true,
            },
            [ 436996 ] = {
                name = "Stalking Shadows",
                interrupt = true,
            },
        },
        [ 201793 ] = {
            name = "The Silken Court",
            [ 438200 ] = {
                name = "Poison Bolt",
                interrupt = true,
            },
            [ 441772 ] = {
                name = "Void Bolt",
                interrupt = true,
            },
        },
        [ 201794 ] = {
            name = "Queen Ansurek",
            [ 451600 ] = {
                name = "Expulsion Beam",
                interrupt = true,
            },
            [ 439865 ] = {
                name = "Silken Tomb",
                interrupt = true,
            },
        },
        [ 203669 ] = {
            name = "Rasha'nan",
            [ 436996 ] = {
                name = "Stalking Shadows",
                interrupt = true,
            },
        },
        [ 455123 ] = {
            name = "Nerub-ar Palace - General Crixis",
            [ 451568 ] = {
                name = "Void Slash",
                spell_reflection = true,
            },
        },
        [ 455124 ] = {
            name = "Nerub-ar Palace - Arbitra's Fury",
            [ 451199 ] = {
                name = "Celestial Blast",
                spell_reflection = true,
            },
        },
        [ 455125 ] = {
            name = "Nerub-ar Palace - Netherblade Executioner",
            [ 450551 ] = {
                name = "Shadow Rend",
                spell_reflection = true,
            },
        },
        [ 455126 ] = {
            name = "Nerub-ar Palace - Frostbinder's Wrath",
            [ 444264 ] = {
                name = "Ice Shard",
                spell_reflection = true,
            },
        },
        [ 455127 ] = {
            name = "Nerub-ar Palace - Abyssal Devourer",
            [ 445619 ] = {
                name = "Devour Essence",
                spell_reflection = true,
            },
        },
        [ 455128 ] = {
            name = "Nerub-ar Palace - Sun King's Fury",
            [ 451895 ] = {
                name = "Blazing Inferno",
                spell_reflection = true,
            },
        },
        [ 455129 ] = {
            name = "Nerub-ar Palace - Starcaller Supreme",
            [ 451845 ] = {
                name = "Cosmic Burst",
                spell_reflection = true,
            },
        },
        [ 455130 ] = {
            name = "Nerub-ar Palace - Enraged Earthshaker",
            [ 444264 ] = {
                name = "Earthquake",
                spell_reflection = true,
            },
        },
        [ 455131 ] = {
            name = "Nerub-ar Palace - Mindshatter Lurker",
            [ 451678 ] = {
                name = "Mind Flay",
                spell_reflection = true,
            },
        },
        [ 455132 ] = {
            name = "Nerub-ar Palace - Spectral Overseer",
            [ 450551 ] = {
                name = "Wail of Suffering",
                spell_reflection = true,
            },
        },
        [ 455133 ] = {
            name = "Nerub-ar Palace - Necrotic Abomination",
            [ 450551 ] = {
                name = "Necrotic Burst",
                spell_reflection = true,
            },
        },
        [ 455134 ] = {
            name = "Nerub-ar Palace - Crimson Seeker",
            [ 444264 ] = {
                name = "Blood Lance",
                spell_reflection = true,
            },
        },
    },

    [ 2660 ] = {
        name = "Ara-Kara, City of Echoes",
        [ 216293 ] = {
            name = "Ara-Kara, City of Echoes - Trilling Attendant",
            [ 434786 ] = {
                name = "Web Bolt",
                spell_reflection = true,
            },
            [ 434793 ] = {
                name = "Resonant Barrage",
                interrupt = true,
            },
        },
        [ 216364 ] = {
            name = "Ara-Kara, City of Echoes - Blood Overseer",
            [ 433841 ] = {
                name = "Venom Volley",
                interrupt = true,
            },
        },
        [ 217531 ] = {
            name = "Ara-Kara, City of Echoes - Ixin",
            [ 434786 ] = {
                name = "Web Bolt",
                spell_reflection = true,
            },
            [ 434802 ] = {
                name = "Horrifying Shrill",
                interrupt = true,
            },
        },
        [ 217533 ] = {
            name = "Ara-Kara, City of Echoes - Atik",
            [ 436322 ] = {
                name = "Poison Bolt",
                interrupt = true,
                spell_reflection = true,
            },
        },
        [ 218324 ] = {
            name = "Ara-Kara, City of Echoes - Nakt",
            [ 434786 ] = {
                name = "Web Bolt",
                spell_reflection = true,
            },
        },
        [ 220599 ] = {
            name = "Ara-Kara, City of Echoes - Bloodstained Webmage",
            [ 442210 ] = {
                name = "Silken Restraints",
                interrupt = true,
            },
        },
        [ 223253 ] = {
            name = "Ara-Kara, City of Echoes - Bloodstained Webmage",
            [ 434786 ] = {
                name = "Web Bolt",
                spell_reflection = true,
            },
            [ 448248 ] = {
                name = "Revolting Volley",
                interrupt = true,
            },
        },
    },

    [ 2661 ] = {
        name = "Cinderbrew Meadery",
        [ 214661 ] = {
            name = "Goldie Baronbottom",
            [ 436640 ] = {
                name = "Burning Ricochet",
                spell_reflection = true,
            },
        },
        [ 218671 ] = {
            name = "Venture Co. Pyromaniac",
            [ 437733 ] = {
                name = "Boiling Flames",
                interrupt = true,
                spell_reflection = true,
            },
        },
        [ 214673 ] = {
            name = "Flavor Scientist",
            [ 441627 ] = {
                name = "Rejuvenating Honey",
                interrupt = true,
            },
        },
        [ 220141 ] = {
            name = "Royal Jelly Purveyor",
            [ 440687 ] = {
                name = "Honey Volley",
                interrupt = true,
            },
        },
        [ 222964 ] = {
            name = "Flavor Scientist",
            [ 441627 ] = {
                name = "Rejuvenating Honey",
                interrupt = true,
            },
        },
		[ 210265 ] = {
			name = "Worker Bee",
			[ 443487 ] = {
				name = "Final String",
				blessing_of_spellwarding = true,
			},
		},
		[ 218000 ] = {
			name = "Benk Buzzbee",
			[ 440134 ] = {
				name = "Honey Marinade",
				blessing_of_spellwarding = true,
			},
		},
    },

    [ 2662 ] = {
        name = "The Dawnbreaker",
        [ 210966 ] = {
            name = "Sureki Webmage",
            [ 451113 ] = {
                name = "Web Bolt",
                spell_reflection = true,
            },
        },
        [ 213892 ] = {
            name = "Nightfall Shadowmage",
            [ 431303 ] = {
                name = "Night Bolt",
                spell_reflection = true,
            },
            [ 431309 ] = {
                name = "Ensnaring Shadows",
                interrupt = true,
            },
        },
        [ 213893 ] = {
            name = "Nightfall Darkcaster",
            [ 431333 ] = {
                name = "Tormenting Beam",
                interrupt = true,
            },
        },
        [ 213905 ] = {
            name = "Animated Darkness",
            [ 451114 ] = {
                name = "Congealed Shadow",
                spell_reflection = true,
            },
        },
        [ 213932 ] = {
            name = "Sureki Militant",
            [ 451097 ] = {
                name = "Silken Shell",
                interrupt = true,
            },
        },
        [ 213934 ] = {
            name = "Nightfall Tactician",
            [ 431494 ] = {
                name = "Blade Edge",
                spell_reflection = true,
            },
        },
        [ 214761 ] = {
            name = "Nightfall Ritualist",
            [ 432448 ] = {
                name = "Stygian Seed",
                spell_reflection = true,
            },
        },
        [ 214762 ] = {
            name = "Nightfall Commander",
            [ 450756 ] = {
                name = "Abyssal Howl",
                interrupt = true,
            },
        },
        [ 223994 ] = {
            name = "Nightfall Shadowmage",
            [ 431303 ] = {
                name = "Night Bolt",
                spell_reflection = true,
            },
        },
        [ 225605 ] = {
            name = "Nightfall Darkcaster",
            [ 431333 ] = {
                name = "Tormenting Beam",
                interrupt = true,
            },
        },
        [ 228539 ] = {
            name = "Nightfall Darkcaster",
            [ 431333 ] = {
                name = "Tormenting Beam",
                interrupt = true,
            },
        },
        [ 228540 ] = {
            name = "Nightfall Shadowmage",
            [ 431303 ] = {
                name = "Night Bolt",
                spell_reflection = true,
            },
            [ 431309 ] = {
                name = "Ensnaring Shadows",
                interrupt = true,
            },
        },
    },

    [ 2669 ] = {
        name = "City of Threads",
        [ 216658 ] = {
            name = "Izo, the Grand Splicer",
            [ 438860 ] = {
                name = "Umbral Weave",
                spell_reflection = true,
            },
            [ 439341 ] = {
                name = "Splice",
                spell_reflection = true,
            },
            [ 439814 ] = {
                name = "Silken Tomb",
                spell_reflection = true,
            },
        },
        [ 220003 ] = {
            name = "Eye of the Queen",
            [ 451222 ] = {
                name = "Void Rush",
                spell_reflection = true,
            },
            [ 441772 ] = {
                name = "Void Bolt",
                spell_reflection = true,
            },
            [ 451600 ] = {
                name = "Expulsion Beam",
                spell_reflection = true,
            },
            [ 448660 ] = {
                name = "Acid Bolt",
                spell_reflection = true,
            },
        },
        [ 220195 ] = {
            name = "Sureki Silkbinder",
            [ 443427 ] = {
                name = "Web Bolt",
                spell_reflection = true,
            },
            [ 443430 ] = {
                name = "Silk Binding",
                interrupt = true,
            },
        },
        [ 220196 ] = {
            name = "Herald of Ansurek",
            [ 443433 ] = {
                name = "Twist Thoughts",
                interrupt = true,
            },
        },
        [ 220401 ] = {
            name = "Pale Priest",
            [ 448047 ] = {
                name = "Web Wrap",
                interrupt = true,
            },
        },
        [ 221102 ] = {
            name = "Elder Shadeweaver",
            [ 446717 ] = {
                name = "Umbral Weave",
                spell_reflection = true,
            },
            [ 443427 ] = {
                name = "Web Bolt",
                spell_reflection = true,
            },
        },
        [ 223844 ] = {
            name = "Covert Webmancer",
            [ 442536 ] = {
                name = "Grimweave Blast",
                interrupt = true,
                spell_reflection = true,
            },
            [ 452162 ] = {
                name = "Mending Web",
                interrupt = true,
            },
        },
        [ 224732 ] = {
            name = "Covert Webmancer",
            [ 442536 ] = {
                name = "Grimweave Blast",
                interrupt = true,
                spell_reflection = true,
            },
            [ 452162 ] = {
                name = "Mending Web",
                interrupt = true,
            },
        },
    },

    [ 2769 ] = {
        name = "Liberation of Undermine",
        [ 231839 ] = {
            name = "Scrapmaster",
            [ 1219384 ] = {
                name = "Scrap Rockets",
                spell_reflection = true,
            },
        },
        [ 234211 ] = {
            name = "Reel Assistant",
            [ 460847 ] = {
                name = "Electric Blast",
                spell_reflection = true,
            },
        },
    },

    [ 2773 ] = {
        name = "Operation: Floodgate",
        [ 226396 ] = {
            name = "Swampface",
            [ 473114 ] = {
                name = "Mudslide",
                spell_reflection = true,
            },
			[ 469478 ] = {
				name = "Sludge Claws",
				blessing_of_spellwarding = true,
			},
        },
        [ 229069 ] = {
            name = "Mechadrone Sniper",
            [ 1214468 ] = {
                name = "Trickshot",
                spell_reflection = true,
            },
        },
        [ 229686 ] = {
            name = "Venture Co. Surveyor",
            [ 462771 ] = {
                name = "Surveying Beam",
                spell_reflection = true,
            },
        },
        [ 230740 ] = {
            name = "Shreddinator 3000",
            [ 465754 ] = {
                name = "Flamethrower",
                spell_reflection = true,
            },
        },
        [ 230748 ] = {
            name = "Darkfuse Bloodwarper",
            [ 465871 ] = {
                name = "Blood Bolt",
                spell_reflection = true,
            },
        },
        [ 231197 ] = {
            name = "Bubbles",
            [ 469721 ] = {
                name = "Backwash",
                spell_reflection = true,
            },
			[ 469818 ] = {
				name = "Bubble Burp",
				blessing_of_spellwarding = true,
			},
        },
        [ 231312 ] = {
            name = "Venture Co. Electrician",
            [ 465595 ] = {
                name = "Lightning Bolt",
                spell_reflection = true,
            },
        },
		[ 226398 ] = {
			name = "Big M.O.M.M.A.",
			[ 473351 ] = {
				name = "Electrocrush",
				blessing_of_spellwarding = true,
			},
		},
		[ 242255 ] = {
			name = "Geezle Gigazap",
			[ 466190 ] = {
				name = "Thunder Punch",
				blessing_of_spellwarding = true,
			},
		},
    },
}

class.spellFilters = spellFilters

do
    local interruptibleFilters = {}

    for zoneID, zoneData in pairs( spellFilters ) do
        for npcID, npcData in pairs( zoneData ) do
            if npcID ~= "name" then
                for spellID, spellData in pairs( npcData ) do
                    if spellID ~= "name" and spellData.interrupt then
                        interruptibleFilters[ spellID ] = true
                    end
                end
            end
        end
    end

    class.interruptibleFilters = interruptibleFilters
end
