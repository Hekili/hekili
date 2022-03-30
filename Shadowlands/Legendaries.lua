-- Legendaries.lua
-- June 2021

-- This file is intended to manage detection/identification of Anima Powers (MawPowers in the DB files).

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local all = Hekili.Class.specs[ 0 ]

local state = Hekili.State

local legendaries = {
    -- Death Knight/Blood
    [7458] = { "abominations_frenzy", 1, 250 }, -- 353447
    [6947] = { "deaths_embrace", 1, 250 }, -- 334728
    [7467] = { "final_sentence", 1, 250 }, -- 353822
    [6948] = { "grip_of_the_everlasting", 1, 250 }, -- 334724
    [7468] = { "insatiable_hunger", 1, 250 }, -- 353699
    [6954] = { "phearomones", 1, 250 }, -- 335177
    [7466] = { "rampant_transference", 1, 250 }, -- 353882
    [6953] = { "superstrain", 1, 250 }, -- 334974
    [6940] = { "bryndaors_might", 1, 250 }, -- 334501
    [6941] = { "crimson_rune_weapon", 1, 250 }, -- 334525
    [6943] = { "gorefiends_domination", 1, 250 }, -- 334580
    [6942] = { "vampiric_aura", 1, 250 }, -- 334547

    -- Death Knight/Frost
    [6946] = { "absolute_zero", 1, 251 }, -- 334692
    [6945] = { "biting_cold", 1, 251 }, -- 334678
    [6944] = { "koltiras_favor", 1, 251 }, -- 334583
    [7160] = { "rage_of_the_frozen_champion", 1, 251 }, -- 341724

    -- Death Knight/Unholy
    [6952] = { "deadliest_coil", 1, 252 }, -- 334949
    [6951] = { "deaths_certainty", 1, 252 }, -- 334898
    [6950] = { "frenzied_monstrosity", 1, 252 }, -- 334888
    [6949] = { "reanimated_shambler", 1, 252 }, -- 334836

    -- Demon Hunter/Havoc
    [7219] = { "burning_wound", 1, 577 }, -- 346279
    [7050] = { "chaos_theory", 1, 577 }, -- 337551
    [7218] = { "darker_nature", 1, 577 }, -- 346264
    [7051] = { "erratic_fel_core", 1, 577 }, -- 337685
    [7681] = { "agony_gaze", 1, 577 }, -- 355886
    [7698] = { "blazing_slaughter", 1, 577 }, -- 355890
    [7699] = { "blind_faith", 1, 577 }, -- 355893
    [7041] = { "collective_anguish", 1, 577 }, -- 337504
    [7044] = { "darkest_hour", 1, 577 }, -- 337539
    [7043] = { "darkglare_boon", "darkglare_medallion", 1, 577 }, -- 337534
    [7700] = { "demonic_oath", 1, 577 }, -- 355996
    [7052] = { "fel_bombardment", 1, 577 }, -- 337775

    -- Demon Hunter/Vengeance
    [7047] = { "fel_flame_fortification", 1, 581 }, -- 337545
    [7048] = { "fiery_soul", 1, 581 }, -- 337547
    [7046] = { "razelikhs_defilement", 1, 581 }, -- 337544
    [7045] = { "spirit_of_the_darkness_flame", 1, 581 }, -- 337541

    -- Druid/Balance
    [7571] = { "celestial_spirits", 1, 102 }, -- 354118
    [7085] = { "circle_of_life_and_death", 1, 102 }, -- 338657
    [7086] = { "draught_of_deep_focus", 1, 102 }, -- 338658
    [7477] = { "kindred_affinity", 1, 102 }, -- 354115
    [7110] = { "lycaras_fleeting_glimpse", 1, 102 }, -- 340059
    [7084] = { "oath_of_the_elder_druid", 1, 102 }, -- 338608
    [7474] = { "sinful_hysteria", 1, 102 }, -- 354109
    [7472] = { "unbridled_swarm", 1, 102 }, -- 354123
    [7107] = { "balance_of_all_things", 1, 102 }, -- 339942
    [7087] = { "oneths_clear_vision", 1, 102 }, -- 338661
    [7088] = { "primordial_arcanic_pulsar", 1, 102 }, -- 338668
    [7108] = { "timeworn_dreambinder", 1, 102 }, -- 339949

    -- Druid/Feral
    [7091] = { "apex_predators_craving", 1, 103 }, -- 339139
    [7089] = { "cateye_curio", 1, 103 }, -- 339144
    [7090] = { "eye_of_fearful_symmetry", 1, 103 }, -- 339141
    [7109] = { "frenzyband", 1, 103 }, -- 340053

    -- Druid/Guardian
    [7095] = { "legacy_of_the_sleeper", 1, 104 }, -- 339062
    [7092] = { "luffainfused_embrace", 1, 104 }, -- 339060
    [7093] = { "the_natural_orders_will", 1, 104 }, -- 339063
    [7094] = { "ursocs_fury_remembered", 1, 104 }, -- 339056

    -- Druid/Restoration
    [7096] = { "memory_of_the_mother_tree", 1, 105 }, -- 339064
    [7097] = { "the_dark_titans_lesson", 1, 105 }, -- 338831
    [7098] = { "verdant_infusion", 1, 105 }, -- 338829
    [7099] = { "vision_of_unending_growth", 1, 105 }, -- 338832

    -- Hunter/Beast Mastery
    [7715] = { "bag_of_munitions", 1, 253 }, -- 356264
    [7003] = { "call_of_the_wild", 1, 253 }, -- 336742
    [7006] = { "craven_strategem", 1, 253 }, -- 336747
    [7716] = { "fragments_of_the_elder_antlers", 1, 253 }, -- 356375
    [7004] = { "nessingwarys_trapping_apparatus", "nesingwarys_trapping_apparatus", 1, 253 }, -- 336743
    [7714] = { "pact_of_the_soulstalkers", 1, 253 }, -- 356262
    [7717] = { "pouch_of_razor_fragments", 1, 253 }, -- 356618
    [7005] = { "soulforge_embers", 1, 253 }, -- 336745
    [7007] = { "dire_command", 1, 253 }, -- 336819
    [7008] = { "flamewakers_cobra_sting", 1, 253 }, -- 336822
    [7009] = { "qapla,_eredun_war_order", 1, 253 }, -- 336830
    [7010] = { "rylakstalkers_piercing_fangs", 1, 253 }, -- 336844

    -- Hunter/Marksmanship
    [7011] = { "eagletalons_true_focus", 1, 254 }, -- 336849
    [7014] = { "secrets_of_the_unblinking_vigil", 1, 254 }, -- 336878
    [7013] = { "serpentstalkers_trickery", 1, 254 }, -- 336870
    [7012] = { "surging_shots", 1, 254 }, -- 336867

    -- Hunter/Survival
    [7018] = { "butchers_bone_fragments", 1, 255 }, -- 336907
    [7017] = { "latent_poison_injectors", 1, 255 }, -- 336902
    [7016] = { "rylakstalkers_confounding_strikes", 1, 255 }, -- 336901
    [7015] = { "wildfire_cluster", 1, 255 }, -- 336895

    -- Mage/Arcane
    [7475] = { "deaths_fathom", 1, 62 }, -- 354294
    [6832] = { "disciplinary_command", 1, 62 }, -- 327365
    [6831] = { "expanded_potential", 1, 62 }, -- 327489
    [6937] = { "grisly_icicle", 1, 62 }, -- 333393
    [7473] = { "harmonic_echo", 1, 62 }, -- 354186
    [7727] = { "heart_of_the_fae", 1, 62 }, -- 356877
    [7476] = { "sinful_delight", 1, 62 }, -- 354333
    [6834] = { "temporal_warp", 1, 62 }, -- 327351
    [6936] = { "triune_ward", 1, 62 }, -- 333373
    [6927] = { "arcane_bombardment", 1, 62 }, -- 332892
    [6926] = { "arcane_harmony", "arcane_infinity", 1, 62 }, -- 332769 -- SimC uses original runeforge name.
    [6928] = { "siphon_storm", 1, 62 }, -- 332928

    -- Mage/Fire
    [6931] = { "fevered_incantation", 1, 63 }, -- 333030
    [6932] = { "firestorm", 1, 63 }, -- 333097
    [6933] = { "molten_skyfall", 1, 63 }, -- 333167
    [6934] = { "sun_kings_blessing", 1, 63 }, -- 333313

    -- Mage/Frost
    [6828] = { "cold_front", 1, 64 }, -- 327284
    [6829] = { "freezing_winds", 1, 64 }, -- 327364
    [6830] = { "glacial_fragments", 1, 64 }, -- 327492
    [6823] = { "slick_ice", 1, 64 }, -- 327508

    -- Monk/Brewmaster
    [7707] = { "bountiful_brew", 1, 268 }, -- 356592
    [7718] = { "call_to_arms", 1, 268 }, -- 356684
    [7184] = { "escape_from_reality", 1, 268 }, -- 343250
    [7721] = { "faeline_harmony", 1, 268 }, -- 356705
    [7081] = { "fatal_touch", 1, 268 }, -- 337296
    [7082] = { "invokers_delight", 1, 268 }, -- 337298
    [7080] = { "roll_out", 1, 268 }, -- 337294
    [7726] = { "sinister_teachings", 1, 268 }, -- 356818
    [7076] = { "charred_passions", 1, 268 }, -- 338138
    [7078] = { "mighty_pour", 1, 268 }, -- 337290
    [7079] = { "shaohaos_might", 1, 268 }, -- 337570
    [7077] = { "stormstouts_last_keg", 1, 268 }, -- 337288

    -- Monk/Mistweaver
    [7075] = { "ancient_teachings_of_the_monastery", 1, 270 }, -- 337172
    [7074] = { "clouded_focus", 1, 270 }, -- 337343
    [7072] = { "tear_of_morning", 1, 270 }, -- 337473
    [7073] = { "yulons_whisper", 1, 270 }, -- 337225

    -- Monk/Windwalker
    [7071] = { "jade_ignition", 1, 269 }, -- 337483
    [7068] = { "keefers_skyreach", 1, 269 }, -- 337334
    [7069] = { "last_emperors_capacitor", 1, 269 }, -- 337292
    [7070] = { "xuens_battlegear", 1, 269 }, -- 337481

    -- Paladin/Holy
    [7679] = { "divine_resonance", 1, 65 }, -- 355098
    [7680] = { "dutybound_gavel", 1, 65 }, -- 355099
    [7055] = { "of_dusk_and_dawn", 1, 65 }, -- 337746
    [7701] = { "radiant_embers", 1, 65 }, -- 355447
    [7066] = { "relentless_inquisitor", 1, 65 }, -- 337297
    [7702] = { "seasons_of_plenty", 1, 65 }, -- 355100
    [7054] = { "the_mad_paragon", 1, 65 }, -- 337594
    [7056] = { "the_magistrates_judgment", 1, 65 }, -- 337681
    [7053] = { "uthers_devotion", 1, 65 }, -- 337600
    [7058] = { "inflorescence_of_the_sunwell", 1, 65 }, -- 337777
    [7128] = { "maraads_dying_breath", 1, 65 }, -- 340458
    [7057] = { "shadowbreaker,_dawn_of_the_sun", 1, 65 }, -- 337812
    [7059] = { "shock_barrier", 1, 65 }, -- 337825

    -- Paladin/Protection
    [7062] = { "bulwark_of_righteous_fury", 1, 66 }, -- 337847
    [7060] = { "holy_avengers_engraved_sigil", 1, 66 }, -- 337831
    [7063] = { "reign_of_endless_kings", 1, 66 }, -- 337850
    [7061] = { "the_ardent_protectors_sanctum", 1, 66 }, -- 337838

    -- Paladin/Retribution
    [7064] = { "final_verdict", 1, 70 }, -- 337247
    [7067] = { "tempest_of_the_lightbringer", 1, 70 }, -- 337257
    [7065] = { "vanguards_momentum", 1, 70 }, -- 337638

    -- Priest/Discipline
    [7703] = { "bwonsamdis_pact", 1, 256 }, -- 356391
    [6975] = { "cauterizing_shadows", 1, 256 }, -- 336370
    [7161] = { "measured_contemplation", 1, 256 }, -- 341804
    [7729] = { "pallid_command", 1, 256 }, -- 356390
    [7704] = { "shadow_word_manipulation", 1, 256 }, -- 356392
    [7728] = { "spheres_harmony", 1, 256 }, -- 356395
    [7002] = { "twins_of_the_sun_priestess", 1, 256 }, -- 336897
    [6972] = { "vault_of_heavens", 1, 256 }, -- 336470
    [6980] = { "clarity_of_mind", 1, 256 }, -- 336067
    [6978] = { "crystalline_reflection", 1, 256 }, -- 336507
    [6979] = { "kiss_of_death", 1, 256 }, -- 336133
    [6976] = { "the_penitent_one", 1, 256 }, -- 336011

    -- Priest/Holy
    [6973] = { "divine_image", 1, 257 }, -- 336400
    [6974] = { "flash_concentration", 1, 257 }, -- 336266
    [6977] = { "harmonious_apparatus", 1, 257 }, -- 336314
    [6984] = { "xanshi,_return_of_archbishop_benedictus", 1, 257 }, -- 337477

    -- Priest/Shadow
    [6983] = { "eternal_call_to_the_void", 1, 258 }, -- 336214
    [6981] = { "painbreaker_psalm", 1, 258 }, -- 336165
    [6982] = { "shadowflame_prism", 1, 258 }, -- 336143
    [7162] = { "talbadars_stratagem", 1, 258 }, -- 342415

    -- Rogue/Assassination
    [7126] = { "deathly_shadows", 1, 259 }, -- 340092
    [7573] = { "deathspike", 1, 259 }, -- 354731
    [7113] = { "essence_of_bloodfang", 1, 259 }, -- 340079
    [7114] = { "invigorating_shadowdust", 1, 259 }, -- 340080
    [7111] = { "mark_of_the_master_assassin", 1, 259 }, -- 340076
    [7572] = { "obedience", 1, 259 }, -- 354703
    [7577] = { "resounding_clarity", 1, 259 }, -- 354837
    [7112] = { "tiny_toxic_blade", 1, 259 }, -- 340078
    [7478] = { "toxic_onslaught", 1, 259 }, -- 354473
    [7115] = { "dashing_scoundrel", 1, 259 }, -- 340081
    [7116] = { "doomblade", 1, 259 }, -- 340082
    [7118] = { "duskwalkers_patch", 1, 259 }, -- 340084
    [7117] = { "zoldyck_insignia", 1, 259 }, -- 340083

    -- Rogue/Outlaw
    [7121] = { "celerity", 1, 260 }, -- 340087
    [7122] = { "concealed_blunderbuss", 1, 260 }, -- 340088
    [7119] = { "greenskins_wickers", 1, 260 }, -- 340085
    [7120] = { "guile_charm", 1, 260 }, -- 340086

    -- Rogue/Subtlety
    [7124] = { "akaaris_soul_fragment", 1, 261 }, -- 340090
    [7123] = { "finality", 1, 261 }, -- 340089
    [7125] = { "the_rotten", 1, 261 }, -- 340091

    -- Shaman/Elemental
    [6985] = { "ancestral_reminder", 1, 262 }, -- 336741
    [6988] = { "chains_of_devastation", 1, 262 }, -- 336735
    [6987] = { "deeply_rooted_elements", 1, 262 }, -- 336738
    [6986] = { "deeptremor_stone", 1, 262 }, -- 336739
    [7709] = { "elemental_conduit", 1, 262 }, -- 356250
    [7722] = { "raging_vesper_vortex", 1, 262 }, -- 356789
    [7708] = { "seeds_of_rampant_growth", 1, 262 }, -- 356218
    [7570] = { "splintered_elements", 1, 262 }, -- 354647
    [6991] = { "echoes_of_great_sundering", 1, 262 }, -- 336215
    [6990] = { "elemental_equilibrium", 1, 262 }, -- 336730
    [6989] = { "skybreakers_fiery_demise", 1, 262 }, -- 336734
    [6992] = { "windspeakers_lava_resurgence", 1, 262 }, -- 336063

    -- Shaman/Enhancement
    [6993] = { "doom_winds", 1, 263 }, -- 335902
    [6994] = { "legacy_of_the_frost_witch", 1, 263 }, -- 335899
    [6996] = { "primal_lava_actuators", 1, 263 }, -- 335895
    [6995] = { "witch_doctors_wolf_bones", 1, 263 }, -- 335897

    -- Shaman/Restoration
    [7000] = { "earthen_harmony", 1, 264 }, -- 335886
    [6997] = { "jonats_natural_focus", 1, 264 }, -- 335893
    [6999] = { "primal_tide_core", 1, 264 }, -- 335889
    [6998] = { "spiritwalkers_tidal_totem", 1, 264 }, -- 335891

    -- Warlock/Affliction
    [7026] = { "claw_of_endereth", 1, 265 }, -- 337038
    [7713] = { "contained_perpetual_explosion", 1, 265 }, -- 356259
    [7712] = { "decaying_soul_satchel", 1, 265 }, -- 356362
    [7710] = { "languishing_soul_detritus", 1, 265 }, -- 356254
    [7028] = { "pillars_of_the_dark_portal", 1, 265 }, -- 337065
    [7027] = { "relic_of_demonic_synergy", 1, 265 }, -- 337057
    [7711] = { "shard_of_annihilation", 1, 265 }, -- 356344
    [7025] = { "wilfreds_sigil_of_superior_summoning", 1, 265 }, -- 337020
    [7031] = { "malefic_wrath", 1, 265 }, -- 337122
    [7029] = { "perpetual_agony_of_azjaqir", 1, 265 }, -- 337106
    [7030] = { "sacrolashs_dark_strike", 1, 265 }, -- 337111
    [7032] = { "wrath_of_consumption", 1, 265 }, -- 337128

    -- Warlock/Demonology
    [7036] = { "balespiders_burning_core", 1, 266 }, -- 337159
    [7035] = { "forces_of_the_horned_nightmare", 1, 266 }, -- 337146
    [7034] = { "grim_inquisitors_dread_calling", 1, 266 }, -- 337141
    [7033] = { "implosive_potential", 1, 266 }, -- 337135

    -- Warlock/Destruction
    [7038] = { "cinders_of_the_azjaqir", 1, 267 }, -- 337166
    [7040] = { "embers_of_the_diabolic_raiment", 1, 267 }, -- 337272
    [7039] = { "madness_of_the_azjaqir", 1, 267 }, -- 337169
    [7037] = { "odr_shawl_of_the_ymirjar", 1, 267 }, -- 337163

    -- Warrior/Arms
    [7730] = { "elysian_might", 1, 71 }, -- 357996
    [7469] = { "glory", 1, 71 }, -- 353577
    [6955] = { "leaper", 1, 71 }, -- 335214
    [6958] = { "misshapen_mirror", 1, 71 }, -- 335253
    [7471] = { "natures_fury", 1, 71 }, -- 354161
    [6971] = { "seismic_reverberation", 1, 71 }, -- 335758
    [6959] = { "signet_of_tormented_kings", 1, 71 }, -- 335266
    [7470] = { "sinful_surge", 1, 71 }, -- 354131
    [6960] = { "battlelord", 1, 71 }, -- 335274
    [6962] = { "enduring_blow", 1, 71 }, -- 335458
    [6961] = { "exploiter", 1, 71 }, -- 335451
    [6970] = { "unhinged", 1, 71 }, -- 335282

    -- Warrior/Fury
    [6963] = { "cadence_of_fujieda", 1, 72 }, -- 335555
    [6964] = { "deathmaker", 1, 72 }, -- 335567
    [6965] = { "reckless_defense", 1, 72 }, -- 335582
    [6966] = { "will_of_the_berserker", 1, 72 }, -- 335594

    -- Warrior/Protection
    [6969] = { "reprisal", 1, 73 }, -- 335718
    [6957] = { "the_wall", 1, 73 }, -- 335239
    [6956] = { "thunderlord", 1, 73 }, -- 335229
    [6967] = { "unbreakable_will", 1, 73 }, -- 335629

    -- Shared
    [7100] = { "echo_of_eonar", 1, 0 }, -- 338477
    [7101] = { "judgment_of_the_arbiter", 1, 0 }, -- 339344
    [7159] = { "maw_rattle", 1, 0 }, -- 340197
    [7102] = { "norgannons_sagacity", 1, 0 }, -- 339340
    [7103] = { "sephuzs_proclamation", 1, 0 }, -- 339348
    [7104] = { "stable_phantasma_lure", 1, 0 }, -- 339351
    [7105] = { "third_eye_of_the_jailer", 1, 0 }, -- 339058
    [7106] = { "vitality_sacrifice", 1, 0 }, -- 338743
}



local unityBonuses = {
    -- [1] = Kyrian
    -- [2] = Venthyr
    -- [3] = Night Fae
    -- [4] = Necrolord
    [8119] = { "final_sentence"            , "insatiable_hunger"             , "rampant_transference"           , "abominations_frenzy"   }, -- 364758; DK
    [8120] = { "blind_faith"               , "agony_gaze"                    , "blazing_slaughter"              , "demonic_oath"          }, -- 364824; DH
    [8121] = { "kindred_affinity"          , "sinful_hysteria"               , "celestial_spirits"              , "unbridled_swarm"       }, -- 364814; Druid
    [8122] = { "pact_of_the_soulstalkers"  , "pouch_of_razor_fragments"      , "fragments_of_the_elder_antlers" , "bag_of_munitions"      }, -- 364743; Hunter
    [8123] = { "harmonic_echo"             , "sinful_delight"                , "heart_of_the_fae"               , "deaths_fathom"         }, -- 364852; Mage
    [8124] = { "call_to_arms"              , "sinister_teachings"            , "faeline_harmony"                , "bountiful_brew"        }, -- 364857; Monk
    [8125] = { "divine_resonance"          , "radiant_embers"                , "seasons_of_plenty"              , "dutybound_gavel"       }, -- 364642; Paladin
    [8126] = { "spheres_harmony"           , "shadow_word_manipulation"      , "bwonsamdis_pact"                , "pallid_command"        }, -- 364911; Priest
    [8127] = { "resounding_clarity"        , "obedience"                     , "toxic_onslaught"                , "deathspike"            }, -- 364922; Rogue
    [8128] = { "raging_vesper_totem"       , "elemental_conduit"             , "seeds_of_rampant_growth"        , "splintered_elements"   }, -- 364738; Shaman
    [8129] = { "languishing_soul_detritus" , "contained_perpetual_explosion" , "decaying_soul_satchel"          , "shard_of_annihilation" }, -- 364939; Warlock
    [8130] = { "elysian_might"             , "sinful_surge"                  , "natures_fury"                   , "glory"                 }, -- 364929; Warrior
}


local unityBelts = {
    [190470] = 8120, -- DH
    [190467] = 8119, -- DK
    [190465] = 8121, -- Druid
    [190466] = 8122, -- Hunter
    [190464] = 8123, -- Mage
    [190472] = 8124, -- Monk
    [190474] = 8125, -- Paladin
    [190468] = 8126, -- Priest
    [190471] = 8127, -- Rogue
    [190473] = 8128, -- Shaman
    [190469] = 8129, -- Warlock
    [190475] = 8130, -- Warrior
}


local GetActiveCovenantID = C_Covenants.GetActiveCovenantID


local function ResetLegendaries()
    for thing in pairs( state.legendary ) do
        state.legendary[ thing ].rank = 0
    end
end


local function UpdateLegendary( slot, item )
    local link = GetInventoryItemLink( "player", slot )
    local numBonuses = select( 14, string.split( ":", link ) )

    local covenant = GetActiveCovenantID()

    numBonuses = tonumber( numBonuses )
    if numBonuses and numBonuses > 0 then
        for i = 15, 14 + numBonuses do
            local bonusID = select( i, string.split( ":", link ) )
            bonusID = tonumber( bonusID )

            if legendaries[ bonusID ] then
                local entries = #legendaries[ bonusID ]
                local name, rank = legendaries[ bonusID ][ 1 ], legendaries[ bonusID ][ entries - 1 ]

                state.legendary[ name ] = rawget( state.legendary, name ) or { rank = 0 }
                state.legendary[ name ].rank = rank

                -- Multiple names, likely to accommodate a SimC typo.
                if entries > 3 then
                    for j = 2, entries - 2 do
                        local n = legendaries[ bonusID ][ j ]
                        state.legendary[ n ] = rawget( state.legendary, n ) or { rank = 0 }
                        state.legendary[ n ].rank = rank
                    end
                end
            end

            local unity = unityBonuses[ bonusID ]
            if unity then
                local runeforge = unity[ covenant ]

                if runeforge then
                    local legendary = rawget( state.legendary, runeforge ) or { rank = 0 }
                    legendary.rank = 1
                    state.legendary[ runeforge ] = legendary
                end
            end
        end
    end

    if slot == 6 then
        local id = GetInventoryItemID( "player", slot )
        local bonus = id and unityBelts[ id ]
        local unity = bonus and unityBonuses[ bonus ]
        local runeforge = unity and unity[ covenant ]

        if runeforge then
            if runeforge then
                local legendary = rawget( state.legendary, runeforge ) or { rank = 0 }
                legendary.rank = 1
                state.legendary[ runeforge ] = legendary
            end
        end
    end
end


Hekili:RegisterGearHook( ResetLegendaries, UpdateLegendary )