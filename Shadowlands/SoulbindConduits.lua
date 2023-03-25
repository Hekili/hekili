-- SoulbindConduits.lua
-- November 2020

local addon, ns = ...
local Hekili = _G[ addon ]

local RegisterEvent = ns.RegisterEvent
local state = Hekili.State

local all = Hekili.Class.specs[ 0 ]

local AreCovenantsDisabled, WipeCovenantCache = ns.AreCovenantsDisabled, ns.WipeCovenantCache


state.conduit = {}
state.soulbind = {}

setmetatable( state.soulbind, ns.metatables.mt_generic_traits )
state.soulbind.no_trait = { rank = 0 }

setmetatable( state.conduit, ns.metatables.mt_generic_traits )
state.conduit.no_trait = { rank = 0, mod = 0 }


-- Update Conduit Data.
do
    local conduits = {
        [58081] = { "kilroggs_cunning", 50 },
        [334993] = { "stalwart_guardian", -20000 },
        [335010] = { "brutal_vitality", 4 },
        [335034] = { "inspiring_presence", 20 },
        [335196] = { "safeguard", -8 },
        [335232] = { "ashen_juggernaut", 2 },
        [335242] = { "crash_the_ramparts", 9 },
        [335250] = { "cacophonous_roar", 80 },
        [335260] = { "merciless_bonegrinder", 100 },
        [336191] = { "indelible_victory", 200 },
        [336379] = { "harm_denial", 25 },
        [336452] = { "inner_fury", 4 },
        [336460] = { "unrelenting_cold", 15 },
        [336472] = { "shivering_core", 8 },
        [336522] = { "icy_propulsion", 7 },
        [336526] = { "calculated_strikes", 10 },
        [336569] = { "ice_bite", 4 },
        [336598] = { "coordinated_offensive", 8 },
        [336613] = { "winters_protection", -25000 },
        [336616] = { "xuens_bond", 10 },
        [336632] = { "grounding_breath", 15 },
        [336636] = { "flow_of_time", -2000 },
        [336773] = { "jade_bond", 6 },
        [336777] = { "grounding_surge", 25 },
        [336812] = { "resplendent_mist", 50 },
        [336821] = { "infernal_cascade", 7 },
        [336852] = { "master_flame", 8 },
        [336853] = { "fortifying_ingredients", 12 },
        [336873] = { "arcane_prodigy", 3 },
        [336884] = { "lingering_numbness", 400 },
        [336886] = { "nether_precision", 6 },
        [336890] = { "dizzying_tumble", -62 },
        [336992] = { "discipline_of_the_grove", -1000 },
        [336999] = { "gift_of_the_lich", 12000 },
        [337058] = { "ire_of_the_ascended", 5 },
        [337078] = { "swift_transference", 12 },
        [337084] = { "tumbling_technique", 60 },
        [337087] = { "siphoned_malice", 2 },
        [337099] = { "rising_sun_revival", 12 },
        [337119] = { "scalding_brew", 7 },
        [337123] = { "cryofreeze", 5 },
        [337134] = { "celestial_effervescence", 18 },
        [337136] = { "diverted_energy", 25 },
        [337154] = { "unnerving_focus", 30 },
        [337162] = { "depths_of_insanity", 20 },
        [337192] = { "magis_brand", 6 },
        [337214] = { "hack_and_slash", 240 },
        [337224] = { "flame_accretion", 2 },
        [337240] = { "artifice_of_the_archmage", 40 },
        [337241] = { "nourishing_chi", 18 },
        [337250] = { "evasive_stride", 25 },
        [337264] = { "walk_with_the_ox", 25 },
        [337275] = { "incantation_of_swiftness", 45 },
        [337286] = { "strike_with_clarity", 1 },
        [337293] = { "tempest_barrier", 4 },
        [337295] = { "bone_marrow_hops", 40 },
        [337301] = { "imbued_reflections", 36 },
        [337302] = { "vicious_contempt", 24 },
        [337303] = { "way_of_the_fae", 21 },
        [337381] = { "eternal_hunger", 6 },
        [337662] = { "translucent_image", -6 },
        [337678] = { "move_with_grace", -20000 },
        [337704] = { "chilled_resilience", -20000 },
        [337705] = { "spirit_drain", 100 },
        [337707] = { "clear_mind", -15 },
        [337715] = { "charitable_soul", 13 },
        [337748] = { "lights_inspiration", 6 },
        [337762] = { "power_unto_others", 6 },
        [337764] = { "reinforced_shell", 2000 },
        [337778] = { "shining_radiance", 40 },
        [337786] = { "pain_transformation", 15 },
        [337790] = { "exaltation", 5 },
        [337811] = { "lasting_spirit", 13 },
        [337822] = { "accelerated_cold", 6 },
        [337884] = { "withering_plague", 15 },
        [337891] = { "swift_penitence", 30 },
        [337914] = { "focused_mending", 38 },
        [337934] = { "eradicating_blow", 6 },
        [337947] = { "resonant_words", 38 },
        [337954] = { "mental_recovery", 25 },
        [337957] = { "blood_bond", 2 },
        [337964] = { "astral_protection", -3 },
        [337966] = { "courageous_ascension", 25 },
        [337972] = { "hardened_bones", 6 },
        [337974] = { "refreshing_waters", 15 },
        [337979] = { "festering_transfusion", 12 },
        [337980] = { "embrace_death", 40 },
        [337981] = { "vital_accretion", 20 },
        [337988] = { "everfrost", 3 },
        [338033] = { "thunderous_paws", 10 },
        [338042] = { "totemic_surge", -1000 },
        [338048] = { "spiritual_resonance", 4000 },
        [338054] = { "crippling_hex", -8 },
        [338089] = { "fleeting_wind", 15 },
        [338131] = { "high_voltage", 25 },
        [338252] = { "shake_the_foundations", 10 },
        [338303] = { "call_of_flame", 35 },
        [338305] = { "fae_fermata", 3800 },
        [338311] = { "unending_grip", -20 },
        [338315] = { "shattered_perceptions", 13 },
        [338318] = { "unruly_winds", 15 },
        [338319] = { "haunting_apparitions", 31 },
        [338322] = { "focused_lightning", 5 },
        [338325] = { "chilled_to_the_core", 30 },
        [338329] = { "embrace_of_earth", 5 },
        [338330] = { "insatiable_appetite", 1 },
        [338331] = { "magma_fist", 12 },
        [338332] = { "mind_devourer", 5 },
        [338338] = { "rabid_shadows", 12 },
        [338339] = { "swirling_currents", 20 },
        [338342] = { "dissonant_echoes", 3 },
        [338343] = { "heavy_rainfall", 75 },
        [338345] = { "holy_oration", 6 },
        [338346] = { "natures_focus", 10 },
        [338435] = { "meat_shield", 2 },
        [338492] = { "unleashed_frenzy", 1 },
        [338516] = { "debilitating_malady", 7 },
        [338553] = { "convocation_of_the_dead", 15 },
        [338566] = { "lingering_plague", 10 },
        [338628] = { "impenetrable_gloom", 18 },
        [338651] = { "brutal_grasp", 30 },
        [338664] = { "proliferation", 20 },
        [338671] = { "fel_defender", -5000 },
        [338682] = { "viscous_ink", -6 },
        [338741] = { "divine_call", 48 },
        [338787] = { "shielding_words", 15 },
        [338793] = { "shattered_restoration", 5 },
        [338799] = { "felfire_haste", 5 },
        [338835] = { "ravenous_consumption", 15 },
        [339018] = { "enfeebled_mark", 7 },
        [339048] = { "demonic_parole", 5000 },
        [339059] = { "empowered_release", 5 },
        [339109] = { "spirit_attunement", 10 },
        [339114] = { "golden_path", 200 },
        [339124] = { "pure_concentration", 20 },
        [339129] = { "necrotic_barrage", 5 },
        [339130] = { "fel_celerity", -48000 },
        [339149] = { "lost_in_darkness", 3000 },
        [339151] = { "relentless_onslaught", 5 },
        [339182] = { "elysian_dirge", 60 },
        [339183] = { "essential_extraction", -25000 },
        [339185] = { "lavish_harvest", 10 },
        [339186] = { "tumbling_waves", 200 },
        [339228] = { "dancing_with_fate", 40 },
        [339230] = { "serrated_glaive", 10 },
        [339231] = { "growing_inferno", 10 },
        [339259] = { "piercing_verdict", 25 },
        [339264] = { "marksmans_advantage", -3 },
        [339265] = { "veterans_repute", 10 },
        [339268] = { "lights_barding", 50 },
        [339272] = { "resolute_barrier", 0 },
        [339282] = { "accrued_vitality", 44 },
        [339292] = { "wrench_evil", -40 },
        [339316] = { "echoing_blessings", 5 },
        [339370] = { "harrowing_punishment", 2 },
        [339371] = { "expurgation", 32 },
        [339374] = { "truths_wake", 13 },
        [339377] = { "harmony_of_the_tortollan", -10000 },
        [339379] = { "shade_of_terror", 100 },
        [339386] = { "mortal_combo", 10 },
        [339399] = { "rejuvenating_wind", 10 },
        [339411] = { "demonic_momentum", 30 },
        [339423] = { "soul_furnace", 30 },
        [339455] = { "corrupting_leer", 3 },
        [339459] = { "resilience_of_the_hunter", -3 },
        [339481] = { "rolling_agony", 4000 },
        [339495] = { "reversal_of_fortune", 5 },
        [339500] = { "focused_malignancy", 7 },
        [339518] = { "virtuous_command", 8 },
        [339531] = { "templars_vindication", 30 },
        [339558] = { "cheetahs_vigor", -16000 },
        [339570] = { "enkindled_spirit", 30 },
        [339576] = { "withering_bolt", 5 },
        [339578] = { "borne_of_blood", 16 },
        [339587] = { "demon_muzzle", -5 },
        [339644] = { "roaring_fire", 30 },
        [339651] = { "tactical_retreat", -20 },
        [339656] = { "carnivorous_stalkers", 3 },
        [339704] = { "ferocious_appetite", 10 },
        [339712] = { "resplendent_light", 4 },
        [339750] = { "one_with_the_beast", 1 },
        [339766] = { "tyrants_soul", 10 },
        [339818] = { "show_of_force", 12 },
        [339845] = { "fel_commando", 7 },
        [339890] = { "duplicitous_havoc", 10 },
        [339892] = { "ashen_remains", 4 },
        [339895] = { "repeat_decree", -85 },
        [339896] = { "combusting_engine", 8 },
        [339920] = { "sharpshooters_focus", 20 },
        [339924] = { "brutal_projectiles", 3 },
        [339939] = { "destructive_reverberations", 4 },
        [339948] = { "disturb_the_peace", -5000 },
        [339973] = { "deadly_chain", 5 },
        [339984] = { "focused_light", 5 },
        [339987] = { "untempered_dedication", 5 },
        [340006] = { "vengeful_shock", 3 },
        [340012] = { "punish_the_guilty", 15 },
        [340023] = { "resolute_defender", 1 },
        [340028] = { "increased_scrutiny", -5000 },
        [340030] = { "royal_decree", -15000 },
        [340033] = { "powerful_precision", 5 },
        [340041] = { "infernal_brand", 2 },
        [340063] = { "brooding_pool", 1000 },
        [340185] = { "the_long_summer", 25 },
        [340192] = { "righteous_might", 100 },
        [340212] = { "hallowed_discernment", 40 },
        [340218] = { "ringing_clarity", 40 },
        [340229] = { "soul_tithe", 10 },
        [340268] = { "fatal_decimation", 50 },
        [340316] = { "catastrophic_origin", 50 },
        [340348] = { "soul_eater", 25 },
        [340529] = { "tough_as_bark", -10 },
        [340540] = { "ursine_vigor", 12 },
        [340543] = { "innate_resolve", 12 },
        [340545] = { "tireless_pursuit", 3000 },
        [340549] = { "unstoppable_growth", 20 },
        [340550] = { "ready_for_anything", -10 },
        [340552] = { "unchecked_aggression", 15 },
        [340553] = { "wellhoned_instincts", 135 },
        [340562] = { "diabolic_bloodstone", 10 },
        [340605] = { "layered_mane", 8 },
        [340609] = { "savage_combatant", 15 },
        [340616] = { "flash_of_clarity", 20 },
        [340621] = { "floral_recycling", 40 },
        [340682] = { "taste_for_blood", 2 },
        [340686] = { "incessant_hunter", 10 },
        [340694] = { "sudden_ambush", 3 },
        [340705] = { "carnivorous_instinct", 3 },
        [340706] = { "precise_alignment", 5000 },
        [340708] = { "fury_of_the_skies", 1 },
        [340719] = { "umbral_intensity", 30 },
        [340720] = { "stellar_inspiration", 20 },
        [340876] = { "echoing_call", 5 },
        [341222] = { "strength_of_the_pack", 3 },
        [341246] = { "stinging_strike", 5 },
        [341264] = { "reverberation", 50 },
        [341272] = { "sudden_fractures", 30 },
        [341280] = { "born_anew", 20 },
        [341309] = { "septic_shock", 120 },
        [341310] = { "lashing_scars", 50 },
        [341311] = { "nimble_fingers", -5 },
        [341312] = { "recuperator", 1 },
        [341325] = { "controlled_destruction", 4 },
        [341344] = { "withering_ground", 75 },
        [341350] = { "deadly_tandem", 4000 },
        [341378] = { "deep_allegiance", -10 },
        [341383] = { "endless_thirst", 8 },
        [341399] = { "flame_infusion", 5 },
        [341440] = { "bloodletting", 5 },
        [341446] = { "conflux_of_elements", 15 },
        [341447] = { "evolved_swarm", 6 },
        [341450] = { "front_of_the_pack", 15 },
        [341451] = { "born_of_the_wilds", -10 },
        [341529] = { "cloaked_in_shadows", 15 },
        [341531] = { "quick_decisions", 12 },
        [341532] = { "fade_to_nothing", 10 },
        [341534] = { "rushed_setup", -20 },
        [341535] = { "prepared_for_all", 2 },
        [341536] = { "poisoned_katar", 7 },
        [341537] = { "wellplaced_steel", 10 },
        [341538] = { "maim_mangle", 9 },
        [341539] = { "lethal_poisons", 10 },
        [341540] = { "triple_threat", 9 },
        [341542] = { "ambidexterity", 3 },
        [341543] = { "sleight_of_hand", 10 },
        [341546] = { "count_the_odds", 15 },
        [341549] = { "deeper_daggers", 8 },
        [341556] = { "planned_execution", 4 },
        [341559] = { "stiletto_staccato", 1 },
        [341567] = { "perforated_veins", 18 },
        [344358] = { "unnatural_malice", 25 },
        [345594] = { "pyroclastic_shock", 15 },
        [346747] = { "ambuscade", 1000 },
        [347213] = { "fueled_by_violence", 15 },
        [357888] = { "condensed_anima_sphere", 25 },
        [357902] = { "adaptive_armor_fragment", 2 },
        [387198] = { "grandiose_boon", 1 },
        [387201] = { "spark_of_savagery", 1 },
        [387202] = { "intense_awakening", 1 },
        [387222] = { "bronze_acceleration", 1 },
        [387225] = { "primal_fortitude", 4 },
        [387227] = { "inherent_resistance", -2 },
        [387228] = { "circle_of_life", 2 },
        [387240] = { "graceful_stride", 3 },
        [387267] = { "natural_weapons", -6000 },
        [387270] = { "legacy_of_coldarra", 1000 },
    }


    local soulbinds = {
        [320658] = "stay_on_the_move",                   -- Niya
        [320659] = "niyas_tools_burrs",                  -- Niya
        [320660] = "niyas_tools_poison",                 -- Niya
        [320662] = "niyas_tools_herbs",                  -- Niya
        [320668] = "natures_splendor",                   -- Niya
        [320687] = "swift_patrol",                       -- Niya
        [322721] = "grove_invigoration",                 -- Niya
        [342270] = "run_without_tiring",                 -- Niya
        [352501] = "called_shot",                        -- Niya
        [352502] = "survivors_rally",                    -- Niya
        [352503] = "bonded_hearts",                      -- Niya
        [319191] = "field_of_blossoms",                  -- Dreamweaver
        [319210] = "social_butterfly",                   -- Dreamweaver
        [319211] = "soothing_voice",                     -- Dreamweaver
        [319213] = "empowered_chrysalis",                -- Dreamweaver
        [319214] = "faerie_dust",                        -- Dreamweaver
        [319216] = "somnambulist",                       -- Dreamweaver
        [319217] = "podtender",                          -- Dreamweaver
        [352779] = "waking_dreams",                      -- Dreamweaver
        [352782] = "cunning_dreams",                     -- Dreamweaver
        [352786] = "dream_delver",                       -- Dreamweaver
        [319973] = "built_for_war",                      -- General Draven
        [319978] = "enduring_gloom",                     -- General Draven
        [319982] = "move_as_one",                        -- General Draven
        [332753] = "superior_tactics",                   -- General Draven
        [332754] = "hold_your_ground",                   -- General Draven
        [332755] = "unbreakable_body",                   -- General Draven
        [332756] = "expedition_leader",                  -- General Draven
        [340159] = "service_in_stone",                   -- General Draven
        [352365] = "regenerative_stone_skin",            -- General Draven
        [352415] = "intimidation_tactics",               -- General Draven
        [352417] = "battlefield_presence",               -- General Draven
        [323074] = "volatile_solvent",                   -- Plague Deviser Marileth
        [323079] = "kevins_keyring",                     -- Plague Deviser Marileth
        [323081] = "plagueborn_cleansing_slime",         -- Plague Deviser Marileth
        [323089] = "travel_with_bloop",                  -- Plague Deviser Marileth
        [323090] = "plagueys_preemptive_strike",         -- Plague Deviser Marileth
        [323091] = "oozs_frictionless_coating",          -- Plague Deviser Marileth
        [323095] = "ultimate_form",                      -- Plague Deviser Marileth
        [352108] = "viscous_trail",                      -- Plague Deviser Marileth
        [352109] = "undulating_maneuvers",               -- Plague Deviser Marileth
        [352110] = "kevins_oozeling",                    -- Plague Deviser Marileth
        [323916] = "sulfuric_emission",                  -- Emeni
        [323918] = "gristled_toes",                      -- Emeni
        [323919] = "gnashing_chompers",                  -- Emeni
        [323921] = "emenis_magnificent_skin",            -- Emeni
        [324440] = "cartilaginous_legs",                 -- Emeni
        [324441] = "hearth_kidneystone",                 -- Emeni
        [341650] = "emenis_ambulatory_flesh",            -- Emeni
        [342156] = "lead_by_example",                    -- Emeni
        [351089] = "sole_slough",                        -- Emeni
        [351093] = "resilient_stitching",                -- Emeni
        [351094] = "pustule_eruption",                   -- Emeni
        [325065] = "wild_hunts_charge",                  -- Korayn
        [325066] = "wild_hunt_tactics",                  -- Korayn
        [325067] = "horn_of_the_wild_hunt",              -- Korayn
        [325068] = "face_your_foes",                     -- Korayn
        [325069] = "first_strike",                       -- Korayn
        [325072] = "vorkai_sharpening_techniques",       -- Korayn
        [325073] = "get_in_formation",                   -- Korayn
        [325601] = "hold_the_line",                      -- Korayn
        [352800] = "vorkai_ambush",                      -- Korayn
        [352805] = "wild_hunt_strategem",                -- Korayn
        [352806] = "hunts_exhilaration",                 -- Korayn
        [328257] = "let_go_of_the_past",                 -- Pelagos
        [328261] = "focusing_mantra",                    -- Pelagos
        [328263] = "cleansed_vestments",                 -- Pelagos
        [328265] = "bond_of_friendship",                 -- Pelagos
        [328266] = "combat_meditation",                  -- Pelagos
        [329777] = "phial_of_patience",                  -- Pelagos
        [329786] = "road_of_trials",                     -- Pelagos
        [351146] = "better_together",                    -- Pelagos
        [351147] = "path_of_the_devoted",                -- Pelagos
        [351149] = "newfound_resolve",                   -- Pelagos
        [331576] = "agent_of_chaos",                     -- Nadjia the Mistblade
        [331577] = "fancy_footwork",                     -- Nadjia the Mistblade
        [331579] = "friends_in_low_places",              -- Nadjia the Mistblade
        [331580] = "exacting_preparation",               -- Nadjia the Mistblade
        [331582] = "familiar_predicaments",              -- Nadjia the Mistblade
        [331584] = "dauntless_duelist",                  -- Nadjia the Mistblade
        [331586] = "thrill_seeker",                      -- Nadjia the Mistblade
        [352366] = "nimble_steps",                       -- Nadjia the Mistblade
        [352373] = "fatal_flaw",                         -- Nadjia the Mistblade
        [352405] = "sinful_preservation",                -- Nadjia the Mistblade
        [319983] = "wasteland_propriety",                -- Theotar the Mad Duke
        [336140] = "watch_the_shoes!",                   -- Theotar the Mad Duke
        [336147] = "leisurely_gait",                     -- Theotar the Mad Duke
        [336184] = "exquisite_ingredients",              -- Theotar the Mad Duke
        [336239] = "soothing_shade",                     -- Theotar the Mad Duke
        [336243] = "refined_palate",                     -- Theotar the Mad Duke
        [336245] = "token_of_appreciation",              -- Theotar the Mad Duke
        [336247] = "life_of_the_party",                  -- Theotar the Mad Duke
        [351747] = "its_always_tea_time",                -- Theotar the Mad Duke
        [351748] = "life_is_but_an_appetizer",           -- Theotar the Mad Duke
        [351750] = "party_favors",                       -- Theotar the Mad Duke
        [326504] = "serrated_spaulders",                 -- Bonesmith Heirmir
        [326507] = "resourceful_fleshcrafting",          -- Bonesmith Heirmir
        [326509] = "heirmirs_arsenal_ravenous_pendant",  -- Bonesmith Heirmir
        [326511] = "heirmirs_arsenal_gorestompers",      -- Bonesmith Heirmir
        [326512] = "runeforged_spurs",                   -- Bonesmith Heirmir
        [326513] = "bonesmiths_satchel",                 -- Bonesmith Heirmir
        [326514] = "forgeborne_reveries",                -- Bonesmith Heirmir
        [326572] = "heirmirs_arsenal_marrowed_gemstone", -- Bonesmith Heirmir
        [350899] = "carvers_eye",                        -- Bonesmith Heirmir
        [350935] = "waking_bone_breastplate",            -- Bonesmith Heirmir
        [350936] = "mnemonic_equipment",                 -- Bonesmith Heirmir
        [328258] = "ever_forward",                       -- Kleia
        [329776] = "ascendant_phial",                    -- Kleia
        [329778] = "pointed_courage",                    -- Kleia
        [329779] = "bearers_pursuit",                    -- Kleia
        [329781] = "resonant_accolades",                 -- Kleia
        [329784] = "cleansing_rites",                    -- Kleia
        [329791] = "valiant_strikes",                    -- Kleia
        [334066] = "mentorship",                         -- Kleia
        [351488] = "spear_of_the_archon",                -- Kleia
        [351489] = "hope_springs_eternal",               -- Kleia
        [351491] = "light_the_path",                     -- Kleia
        [331609] = "forgelite_filter",                   -- Forgelite Prime Mikanikos
        [331610] = "charged_additive",                   -- Forgelite Prime Mikanikos
        [331611] = "soulsteel_clamps",                   -- Forgelite Prime Mikanikos
        [331612] = "sparkling_driftglobe_core",          -- Forgelite Prime Mikanikos
        [331725] = "resilient_plumage",                  -- Forgelite Prime Mikanikos
        [331726] = "regenerating_materials",             -- Forgelite Prime Mikanikos
        [333935] = "hammer_of_genesis",                  -- Forgelite Prime Mikanikos
        [333950] = "brons_call_to_action",               -- Forgelite Prime Mikanikos
        [352186] = "soulglow_spectrometer",              -- Forgelite Prime Mikanikos
        [352187] = "reactive_retrofitting",              -- Forgelite Prime Mikanikos
        [352188] = "effusive_anima_accelerator",         -- Forgelite Prime Mikanikos
    }

    local soulbindEvents = {
        "CHALLENGE_MODE_COMPLETED",
        "CHALLENGE_MODE_RESET",
        "CHALLENGE_MODE_START",
        "PLAYER_ALIVE",
        "PLAYER_ENTERING_WORLD",
        "PLAYER_TALENT_UPDATE",
        "SOULBIND_ACTIVATED",
        "SOULBIND_CONDUIT_COLLECTION_CLEARED",
        "SOULBIND_CONDUIT_COLLECTION_REMOVED",
        "SOULBIND_CONDUIT_COLLECTION_UPDATED",
        "SOULBIND_CONDUIT_INSTALLED",
        "SOULBIND_CONDUIT_UNINSTALLED",
        "SOULBIND_FORGE_INTERACTION_ENDED",
        "SOULBIND_FORGE_INTERACTION_STARTED",
        "SOULBIND_NODE_LEARNED",
        "SOULBIND_NODE_UNLEARNED",
        "SOULBIND_NODE_UPDATED",
        "SOULBIND_PATH_CHANGED",
        "SOULBIND_PENDING_CONDUIT_CHANGED",
        "ZONE_CHANGED_NEW_AREA"
    }

    local GetActiveSoulbindID, GetSoulbindData, GetConduitSpellID = C_Soulbinds.GetActiveSoulbindID, C_Soulbinds.GetSoulbindData, C_Soulbinds.GetConduitSpellID

    function ns.updateConduits( event )
        WipeCovenantCache()

        for k, v in pairs( state.conduit ) do
            v.rank = 0
            v.mod = 0
        end

        for k, v in pairs( state.soulbind ) do
            v.rank = 0
        end

        if AreCovenantsDisabled() then return end

        local soulbind = GetActiveSoulbindID()
        if not soulbind then return end

        local souldata = GetSoulbindData( soulbind )
        if not souldata then return end

        for i, node in ipairs( souldata.tree.nodes ) do
            if node.state == Enum.SoulbindNodeState.Selected then
                if node.conduitID > 0 then
                    local spellID = GetConduitSpellID( node.conduitID, node.conduitRank )

                    if conduits[ spellID ] then
                        found = true

                        local data = conduits[ spellID ]
                        local key = data[ 1 ]

                        local conduit = rawget( state.conduit, key ) or {
                            rank = 0,
                            mod = 0
                        }

                        conduit.rank = node.conduitRank > 0 and 1 or 0
                        conduit.mod  = data[ 2 ]

                        state.conduit[ key ] = conduit
                    end
                elseif node.spellID > 0 then
                    if soulbinds[ node.spellID ] then
                        found = true

                        local key = soulbinds[ node.spellID ]

                        local sb = rawget( state.soulbind, key ) or {}
                        sb.rank = 1

                        state.soulbind[ key ] = sb
                    end
                end
            end
        end
    end

    local timer

    for _, event in pairs( soulbindEvents ) do
        RegisterEvent( event, function()
            if timer and not timer:IsCancelled() then timer:Cancel() end
            timer = C_Timer.NewTimer( 1, ns.updateConduits )
        end )
    end
end


-- Conduit Auras
-- Probably want to automate more of these...
all:RegisterAuras( {
    lead_by_example = {
        id = 342181,
        duration = 10,
        max_stack = 1,
    },

    -- Night Fae: Niya
    redirected_anima = {
        id = 342814,
        duration = 30,
        max_stack = 99
    },

    first_strike = {
        id = 325381,
        duration = 5,
        max_stack = 1
    },

    cloaked_in_shadows = {
        id = 341530,
        duration = 4,
        max_stack = 1,
    },

    marrowed_gemstone_enhancement = {
        id = 327069,
        duration = 10,
        max_stack = 1,
    },

    marrowed_gemstone_charging = {
        id = 327066,
        duration = 3600,
        max_stack = 10,
    },

    thrill_seeker = {
        id = 331939,
        duration = 3600,
        max_stack = 40,
    },

    euphoria = {
        id = 331937,
        duration = 10,
        max_stack = 1,
    },

    kevins_oozeling = {
        id = 352500,
        duration = 20,
        max_stack = 1,
    },

    kevins_wrath = {
        id = 352528,
        duration = 30,
        max_stack = 1,
    },

    carvers_eye = {
        id = 351414,
        duration = 5,
        max_stack = 5,
    },

    carvers_eye_debuff = {
        duration = 10,
    },

    soulglow_spectrometer = {
        id = 352939,
        duration = 15,
        max_stack = 5
    }
} )