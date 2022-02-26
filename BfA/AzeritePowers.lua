-- AzeritePowers.lua
-- November 2020

local addon, ns = ...
local Hekili = _G[ addon ]

local all = Hekili.Class.specs[ 0 ]
local state = Hekili.State

-- Globals.
local C_AzeriteItem, FindActiveAzeriteItem = _G.C_AzeriteItem, _G.C_AzeriteItem.FindActiveAzeriteItem


-- Register Azerite Powers before going with generics...
all:RegisterAuras( {
    anduins_dedication = {
        id = 280876,
        duration = 10,
        max_stack = 1,
    },

    sylvanas_resolve = {
        id = 280806,
        duration = 10,
        max_stack = 1,
    },

    archive_of_the_titans = {
        id = 280709,
        duration = 60,
        max_stack = 20,
    },

    battlefield_precision = {
        id = 280855,
        duration = 30,
        max_stack = 25,
    },

    battlefield_focus = {
        id = 280817,
        duration = 30,
        max_stack = 25,
    },

    -- from blightborne infusion; ruinous bolt.  ?
    wandering_soul = {
        id = 280204,
        duration = 14,
        max_stack = 1,
    },

    blood_rite = {
        id = 280409,
        duration = 15,
        max_stack = 1,
    },

    champion_of_azeroth = {
        id = 280713,
        duration = 60,
        max_stack = 4,
    },

    stand_as_one = {
        id = 280858,
        duration = 10,
        max_stack = 1,
    },

    collective_will = {
        id = 280830,
        duration = 10,
        max_stack = 1,
    },

    -- from stronger together
    strength_of_the_humans = {
        id = 280625,
        duration = 10,
        max_stack = 1,
    },

    -- from combined might
    might_of_the_orcs = {
        id = 280841,
        duration = 10,
        max_stack = 1,
    },

    dagger_in_the_back = {
        id = 280286,
        duration = 12,
        tick_time = 3,
        max_stack = 2,
    },

    filthy_transfusion = {
        id = 273836,
        duration = 6,
        tick_time = 1,
        max_stack = 1,
    },

    liberators_might = {
        id = 280852,
        duration = 10,
        max_stack = 1,
    },

    glory_in_battle = {
        id = 280577,
        duration = 10,
        max_stack = 1,
    },

    incite_the_pack = {
        id = 280412,
        duration = 20,
        max_stack = 1,
        copy = 280413,
    },

    last_gift = {
        id = 280862,
        duration = 10,
        max_stack = 1,
    },

    retaliatory_fury = {
        id = 280788,
        duration = 10,
        max_stack = 1,
    },

    meticulous_scheming = {
        id = 273685,
        duration = 8,
        max_stack = 1,
    },

    seize_the_moment = {
        id = 273714,
        duration = 8,
        max_stack = 1,
    },

    normalization_decrease = {
        id = 280654,
        duration = 10,
        max_stack = 1,
    },

    normalization_increase = {
        id = 280653,
        duration = 10,
        max_stack = 1,
    },

    rezans_fury = {
        id = 273794,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
    },

    secrets_of_the_deep = {
        id = 273842,
        duration = 18,
        max_stack = 1,
        copy = 273843, -- Technically, there are distinct buffs but I doubt any APLs will care.
    },

    swirling_sands = {
        id = 280433,
        duration = 12,
        max_stack = 1,
    },

    -- from synaptic_spark_capacitor
    spark_coil = {
        id = 280655,
        duration = 10,
        max_stack = 1,
        copy = 280847,            
    },

    building_pressure = {
        id = 280385,
        duration = 30,
        max_stack = 5,
    },

    tidal_surge = {
        id = 280404,
        duration = 6,
        max_stack = 1,
    },

    tradewinds = {
        id = 281843,
        duration = 15,
        max_stack = 1,
    },

    tradewinds_jumped = {
        id = 281844,
        duration = 8,
        max_stack = 1,
    },

    -- not sure about spell ID, or if there really is a buff...
    unstable_catalyst = {
        id = 281515,
        duration = 8,
        max_stack = 1,
    }
} )


-- "Ring 2" powers.
all:RegisterAuras( {
    ablative_shielding = {
        id = 271543,
        duration = 10,
        max_stack = 1,
    },

    azerite_globules = {
        id = 279956,
        duration = 60,
        max_stack = 3,
    },

    azerite_veins = {
        id = 270674,
        duration = 18,
        tick_time = 3,
        max_stack = 1,
    },

    crystalline_carapace = {
        id = 271538,
        duration = 12,
        max_stack = 1,
    },

    -- earthlink aura?

    elemental_whirl_versatility = {
        id = 268956,
        duration = 10,
        max_stack = 1,
    },

    elemental_whirl_mastery = {
        id = 268955,
        duration = 10,
        max_stack = 1,
    },

    elemental_whirl_haste = {
        id = 268954,
        duration = 10,
        max_stack = 1,
    },

    elemental_whirl_critical_strike = {
        id = 268953,
        duration = 10,
        max_stack = 1,
    },

    elemental_whirl = {
        alias = { "elemental_whirl_critical_strike", "elemental_whirl_haste", "elemental_whirl_mastery", "elemental_whirl_versatility" },
        aliasMode = "longest", -- use duration info from the first buff that's up, as they should all be equal.
        aliasType = "buff",
        duration = 10,
    },

    lifespeed = {
        id = 267665,
        duration = 3600,
        max_stack = 1,
    },

    overwhelming_power = {
        id = 266180,
        duration = 3600,
        max_stack = 25
    },

    strength_in_numbers = {
        id = 271550,
        duration = 15,
        max_stack = 5,
    },

    unstable_flames = {
        id = 279902,
        duration = 5,
        max_stack = 5,
    },

    winds_of_war = {
        id = 269214,
        duration = 3,
        max_stack = 5,
    },
} )


-- "Ring 3" powers.
all:RegisterAuras( {
    -- autoselfcauterizer snare debuff.
    cauterized = {
        id = 280583,
        duration = 5,
        max_stack = 1,
    },

    bulwark_of_the_masses = {
        id = 270657,
        duration = 15,
        max_stack = 1,
    },

    gemhide = {
        id = 270576,
        duration = 10,
        max_stack = 1,
    },

    personal_absorbotron = {
        id = 280661,
        duration = 20,
        max_stack = 1,
    },

    resounding_protection = {
        id = 269279,
        duration = 30,
        max_stack = 1,
    },

    vampiric_speed = {
        id = 269239,
        duration = 6,
        max_stack = 1,
    },
} )


all:RegisterPowers( {
    -- Ablative Shielding
    ablative_shielding = {
        id = 271540,
        triggers = {
            ablative_shielding = { 271544, 271540, 271543 },
        },
    },

    -- Ace Up Your Sleeve
    ace_up_your_sleeve = {
        id = 278676,
        triggers = {
            ace_up_your_sleeve = { 278676 },
        },
    },

    -- Ancestral Resonance
    ancestral_resonance = {
        id = 277666,
        triggers = {
            ancestral_resonance = { 277666, 277943 },
        },
    },

    -- Ancient Ankh Talisman
    ancient_ankh_talisman = {
        id = 287774,
        triggers = {
            ancient_ankh_talisman = { 287774 },
        },
    },

    -- Ancients' Bulwark
    ancients_bulwark = {
        id = 287604,
        triggers = {
            ancients_bulwark = { 287608, 287604 },
        },
    },

    -- Anduin's Dedication
    anduins_dedication = {
        id = 280628,
        triggers = {
            anduins_dedication = { 280876, 280628 },
        },
    },

    -- Apothecary's Concoctions
    apothecarys_concoctions = {
        id = 287631,
        triggers = {
            apothecarys_concoctions = { 287639, 287631 },
        },
    },

    -- Arcane Pressure
    arcane_pressure = {
        id = 274594,
        triggers = {
            arcane_pressure = { 274594 },
        },
    },

    -- Arcane Pummeling
    arcane_pummeling = {
        id = 270669,
        triggers = {
            arcane_pummeling = { 270669, 270670 },
        },
    },

    -- Arcanic Pulsar
    arcanic_pulsar = {
        id = 287773,
        triggers = {
            arcanic_pulsar = { 287773 },
        },
    },

    -- Archive of the Titans
    archive_of_the_titans = {
        id = 280555,
        triggers = {
            archive_of_the_titans = { 280555, 280709 },
        },
    },

    -- Auto-Self-Cauterizer
    autoselfcauterizer = {
        id = 280172,
        triggers = {
            autoselfcauterizer = { 280583, 280172 },
        },
    },

    -- Autumn Leaves
    autumn_leaves = {
        id = 274432,
        triggers = {
            autumn_leaves = { 274432, 287247 },
        },
    },

    -- Avenger's Might
    avengers_might = {
        id = 272898,
        triggers = {
            avengers_might = { 272898, 272903 },
        },
    },

    -- Azerite Empowered
    azerite_empowered = {
        id = 263978,
        triggers = {
            azerite_empowered = { 263978 },
        },
    },

    -- Azerite Fortification
    azerite_fortification = {
        id = 268435,
        triggers = {
            azerite_fortification = { 268435, 270659 },
        },
    },

    -- Azerite Globules
    azerite_globules = {
        id = 266936,
        triggers = {
            azerite_globules = { 279958, 266936 },
        },
    },

    -- Azerite Veins
    azerite_veins = {
        id = 267683,
        triggers = {
            azerite_veins = { 270674, 267683 },
        },
    },

    -- Baleful Invocation
    baleful_invocation = {
        id = 287059,
        triggers = {
            baleful_invocation = { 287060, 287059 },
        },
    },

    -- Barrage Of Many Bombs
    barrage_of_many_bombs = {
        id = 280163,
        triggers = {
            barrage_of_many_bombs = { 280163, 280984 },
        },
    },

    -- Bastion of Might
    bastion_of_might = {
        id = 287377,
        triggers = {
            bastion_of_might = { 287379, 287377 },
        },
    },

    -- Battlefield Focus
    battlefield_focus = {
        id = 280582,
        triggers = {
            battlefield_focus = { 282724, 280817, 280582 },
        },
    },

    -- Battlefield Precision
    battlefield_precision = {
        id = 280627,
        triggers = {
            battlefield_precision = { 282720, 280855, 280627 },
        },
    },

    -- Blade In The Shadows
    blade_in_the_shadows = {
        id = 275896,
        triggers = {
            blade_in_the_shadows = { 279754, 279752, 275896 },
        },
    },

    -- Blaster Master
    blaster_master = {
        id = 274596,
        triggers = {
            blaster_master = { 274596, 274598 },
        },
    },

    -- Blessed Portents
    blessed_portents = {
        id = 267889,
        triggers = {
            blessed_portents = { 271843, 267889 },
        },
    },

    -- Blessed Sanctuary
    blessed_sanctuary = {
        id = 273313,
        triggers = {
            blessed_sanctuary = { 273313 },
        },
    },

    -- Blightborne Infusion
    blightborne_infusion = {
        id = 273823,
        triggers = {
            blightborne_infusion = { 280204, 273823 },
        },
    },

    -- Blood Mist
    blood_mist = {
        id = 279524,
        triggers = {
            blood_mist = { 279524, 279526 },
        },
    },

    -- Blood Rite
    blood_rite = {
        id = 280407,
        triggers = {
            blood_rite = { 280407, 280409 },
        },
    },

    -- Blood Siphon
    blood_siphon = {
        id = 264108,
        triggers = {
            blood_siphon = { 264108 },
        },
    },

    -- Bloodsport
    bloodsport = {
        id = 279172,
        triggers = {
            bloodsport = { 279172, 279194 },
        },
    },

    -- Bloody Runeblade
    bloody_runeblade = {
        id = 289339,
        triggers = {
            bloody_runeblade = { 289339, 289348 },
        },
    },

    -- Blur of Talons
    blur_of_talons = {
        id = 277653,
        triggers = {
            blur_of_talons = { 277969, 277653 },
        },
    },

    -- Boiling Brew
    boiling_brew = {
        id = 272792,
        triggers = {
            boiling_brew = { 123725, 272792 },
        },
    },

    -- Bonded Souls
    bonded_souls = {
        id = 288802,
        triggers = {
            bonded_souls = { 288839, 288802 },
        },
    },

    -- Bone Spike Graveyard
    bone_spike_graveyard = {
        id = 273088,
        triggers = {
            bone_spike_graveyard = { 273088 },
        },
    },

    -- Bones of the Damned
    bones_of_the_damned = {
        id = 278484,
        triggers = {
            bones_of_the_damned = { 278484, 279503 },
        },
    },

    -- Brace for Impact
    brace_for_impact = {
        id = 277636,
        triggers = {
            brace_for_impact = { 277636, 278124 },
        },
    },

    -- Bracing Chill
    bracing_chill = {
        id = 267884,
        triggers = {
            bracing_chill = { 272276, 267884 },
        },
    },

    -- Brain Storm
    brain_storm = {
        id = 273326,
        triggers = {
            brain_storm = { 273326, 273330 },
        },
    },

    -- Breaking Dawn
    breaking_dawn = {
        id = 278594,
        triggers = {
            breaking_dawn = { 278594 },
        },
    },

    -- Brigand's Blitz
    brigands_blitz = {
        id = 277676,
        triggers = {
            brigands_blitz = { 277724, 277725, 277676 },
        },
    },

    -- Bulwark of Light
    bulwark_of_light = {
        id = 272976,
        triggers = {
            bulwark_of_light = { 272979, 272976 },
        },
    },

    -- Bulwark of the Masses
    bulwark_of_the_masses = {
        id = 268595,
        triggers = {
            bulwark_of_the_masses = { 268595, 270656 },
        },
    },

    -- Burning Soul
    burning_soul = {
        id = 280012,
        triggers = {
            burning_soul = { 274289, 280012 },
        },
    },

    -- Burst of Life
    burst_of_life = {
        id = 277667,
        triggers = {
            burst_of_life = { 277667, 287472 },
        },
    },

    -- Burst of Savagery
    burst_of_savagery = {
        id = 289314,
        triggers = {
            burst_of_savagery = { 289315, 289314 },
        },
    },

    -- Bursting Flare
    bursting_flare = {
        id = 279909,
        triggers = {
            bursting_flare = { 279909, 279913 },
        },
    },

    -- Bury the Hatchet
    bury_the_hatchet = {
        id = 280128,
        triggers = {
            bury_the_hatchet = { 280128, 280212 },
        },
    },

    -- Callous Reprisal
    callous_reprisal = {
        id = 278760,
        triggers = {
            callous_reprisal = { 278999, 278760 },
        },
    },

    -- Cankerous Wounds
    cankerous_wounds = {
        id = 278482,
        triggers = {
            cankerous_wounds = { 278482 },
        },
    },

    -- Cascading Calamity
    cascading_calamity = {
        id = 275372,
        triggers = {
            cascading_calamity = { 275378, 275372 },
        },
    },

    -- Cauterizing Blink
    cauterizing_blink = {
        id = 280015,
        triggers = {
            cauterizing_blink = { 280015, 280177 },
        },
    },

    -- Champion of Azeroth
    champion_of_azeroth = {
        id = 280710,
        triggers = {
            champion_of_azeroth = { 280710, 280713 },
        },
    },

    -- Chaos Shards
    chaos_shards = {
        id = 287637,
        triggers = {
            chaos_shards = { 287660, 287637 },
        },
    },

    -- Chaotic Inferno
    chaotic_inferno = {
        id = 278748,
        triggers = {
            chaotic_inferno = { 278748, 279672 },
        },
    },

    -- Chaotic Transformation
    chaotic_transformation = {
        id = 288754,
        triggers = {
            chaotic_transformation = { 288754 },
        },
    },

    -- Chorus of Insanity
    chorus_of_insanity = {
        id = 278661,
        triggers = {
            chorus_of_insanity = { 279572, 278661 },
        },
    },

    -- Cold Hearted
    cold_hearted = {
        id = 288424,
        triggers = {
            cold_hearted = { 288424, 288426 },
        },
    },

    -- Cold Steel, Hot Blood
    cold_steel_hot_blood = {
        id = 288080,
        triggers = {
            cold_steel_hot_blood = { 288080, 288091 },
            gushing_wound = { 288091 },
        },
    },

    -- Collective Will
    collective_will = {
        id = 280581,
        triggers = {
            collective_will = { 280581, 280830 },
        },
    },

    -- Combined Might
    combined_might = {
        id = 280580,
        triggers = {
            might_of_the_sindorei = { 280845 },
            might_of_the_orcs = { 280841 },
            might_of_the_forsaken = { 280844 },
            combined_might = { 280841, 280580 },
            might_of_the_tauren = { 280843 },
            might_of_the_trolls = { 280842 },
        },
    },

    -- Concentrated Mending
    concentrated_mending = {
        id = 267882,
        triggers = {
            concentrated_mending = { 267882, 272260 },
        },
    },

    -- Contemptuous Homily
    contemptuous_homily = {
        id = 278629,
        triggers = {
            contemptuous_homily = { 278629 },
        },
    },

    -- Crashing Chaos
    crashing_chaos = {
        id = 277644,
        triggers = {
            crashing_chaos = { 277706, 277644 },
        },
    },

    -- Crushing Assault
    crushing_assault = {
        id = 278751,
        triggers = {
            crushing_assault = { 278751 },
        },
    },

    -- Crystalline Carapace
    crystalline_carapace = {
        id = 271536,
        triggers = {
            crystalline_carapace = { 271536, 271538, 271539 },
        },
    },

    -- Cycle of Binding
    cycle_of_binding = {
        id = 278502,
        triggers = {
            cycle_of_binding = { 278769, 278502 },
        },
    },

    -- Dagger in the Back
    dagger_in_the_back = {
        id = 280284,
        triggers = {
            dagger_in_the_back = { 280286, 280284 },
        },
    },

    -- Dance of Chi-Ji
    dance_of_chiji = {
        id = 286585,
        triggers = {
            dance_of_chiji = { 286587, 286585 },
        },
    },

    -- Dance of Death
    dance_of_death = {
        id = 274441,
        triggers = {
            dance_of_death = { 274441, 274443 },
        },
    },

    -- Dawning Sun
    dawning_sun = {
        id = 276152,
        triggers = {
            dawning_sun = { 276152, 276154 },
        },
    },

    -- Deadshot
    deadshot = {
        id = 272935,
        triggers = {
            deadshot = { 272935, 272940 },
        },
    },

    -- Deafening Crash
    deafening_crash = {
        id = 272824,
        triggers = {
            deafening_crash = { 272824 },
        },
    },

    -- Death Denied
    death_denied = {
        id = 287717,
        triggers = {
            death_denied = { 287717, 287722, 287723 },
        },
    },

    -- Death Throes
    death_throes = {
        id = 278659,
        triggers = {
            death_throes = { 278659 },
        },
    },

    -- Deep Cuts
    deep_cuts = {
        id = 272684,
        triggers = {
            deep_cuts = { 272684, 272685 },
        },
    },

    -- Demonic Meteor
    demonic_meteor = {
        id = 278737,
        triggers = {
            demonic_meteor = { 278737 },
        },
    },

    -- Depth of the Shadows
    depth_of_the_shadows = {
        id = 275541,
        triggers = {
            depth_of_the_shadows = { 275541, 275544 },
        },
    },

    -- Desperate Power
    desperate_power = {
        id = 280022,
        triggers = {
            desperate_power = { 280022, 234153, 280208 },
        },
    },

    -- Dire Consequences
    dire_consequences = {
        id = 287093,
        triggers = {
            dire_consequences = { 287093 },
        },
    },

    -- Divine Revelations
    divine_revelations = {
        id = 275463,
        triggers = {
            divine_revelations = { 275468, 275463, 275469 },
        },
    },

    -- Double Dose
    double_dose = {
        id = 273007,
        triggers = {
            double_dose = { 273009, 273007 },
        },
    },

    -- Dreadful Calling
    dreadful_calling = {
        id = 278727,
        triggers = {
            dreadful_calling = { 278727, 233490 },
        },
    },

    -- Duck and Cover
    duck_and_cover = {
        id = 280014,
        triggers = {
            duck_and_cover = { 280170, 280014 },
        },
    },

    -- Duplicative Incineration
    duplicative_incineration = {
        id = 278538,
        triggers = {
            duplicative_incineration = { 278538 },
        },
    },

    -- Early Harvest
    early_harvest = {
        id = 287251,
        triggers = {
            early_harvest = { 287251 },
        },
    },

    -- Earthlink
    earthlink = {
        id = 279926,
        triggers = {
            earthlink = { 279926, 279928 },
        },
    },

    -- Echo of the Elementals
    echo_of_the_elementals = {
        id = 275381,
        triggers = {
            echo_of_the_elementals = { 275385, 275381 },
        },
    },

    -- Echoing Blades
    echoing_blades = {
        id = 287649,
        triggers = {
            echoing_blades = { 287653, 287649 },
        },
    },

    -- Echoing Howl
    echoing_howl = {
        id = 275917,
        triggers = {
            echoing_howl = { 275917, 275918 },
        },
    },

    -- Eldritch Warding
    eldritch_warding = {
        id = 274379,
        triggers = {
            eldritch_warding = { 274379 },
        },
    },

    -- Elemental Whirl
    elemental_whirl = {
        id = 263984,
        triggers = {
            elemental_whirl = { 268953, 268954, 268956, 268955, 263984 },
        },
    },

    -- Elusive Footwork
    elusive_footwork = {
        id = 278571,
        triggers = {
            elusive_footwork = { 278571 },
        },
    },

    -- Empyreal Ward
    empyreal_ward = {
        id = 287729,
        triggers = {
            empyreal_ward = { 287731, 287729 },
        },
    },

    -- Empyrean Power
    empyrean_power = {
        id = 286390,
        triggers = {
            empyrean_power = { 286390, 286393 },
        },
    },

    -- Endless Hunger
    endless_hunger = {
        id = 287662,
        triggers = {
            endless_hunger = { 287662 },
        },
    },

    -- Enduring Luminescence
    enduring_luminescence = {
        id = 278643,
        triggers = {
            enduring_luminescence = { 278643 },
        },
    },

    -- Ephemeral Recovery
    ephemeral_recovery = {
        id = 267886,
        triggers = {
            ephemeral_recovery = { 267886, 289362 },
        },
    },

    -- Equipoise
    equipoise = {
        id = 286027,
        triggers = {
            equipoise = { 286027, 264351, 264352 },
        },
    },

    -- Essence Sever
    essence_sever = {
        id = 278501,
        triggers = {
            essence_sever = { 279450, 278501 },
        },
    },

    -- Eternal Rune Weapon
    eternal_rune_weapon = {
        id = 278479,
        triggers = {
            eternal_rune_weapon = { 278543, 278479 },
        },
    },

    -- Everlasting Light
    everlasting_light = {
        id = 277681,
        triggers = {
            everlasting_light = { 277681 },
        },
    },

    -- Exit Strategy
    exit_strategy = {
        id = 289322,
        triggers = {
            exit_strategy = { 289324, 289322 },
        },
    },

    -- Explosive Echo
    explosive_echo = {
        id = 278537,
        triggers = {
            explosive_echo = { 278537 },
        },
    },

    -- Explosive Potential
    explosive_potential = {
        id = 275395,
        triggers = {
            explosive_potential = { 275395, 275398 },
        },
    },

    -- Expurgation
    expurgation = {
        id = 273473,
        triggers = {
            expurgation = { 273481, 273473 },
        },
    },

    -- Eyes of Rage
    eyes_of_rage = {
        id = 278500,
        triggers = {
            eyes_of_rage = { 278500 },
        },
    },

    -- Feeding Frenzy
    feeding_frenzy = {
        id = 278529,
        triggers = {
            feeding_frenzy = { 217200, 278529 },
        },
    },

    -- Festermight
    festermight = {
        id = 274081,
        triggers = {
            festermight = { 274373, 274081 },
        },
    },

    -- Fight or Flight
    fight_or_flight = {
        id = 287818,
        triggers = {
            fight_or_flight = { 287825, 287818 },
        },
    },

    -- Filthy Transfusion
    filthy_transfusion = {
        id = 273834,
        triggers = {
            filthy_transfusion = { 273836, 273834 },
        },
    },

    -- Firemind
    firemind = {
        id = 278539,
        triggers = {
            firemind = { 278539, 279715 },
        },
    },

    -- Fit to Burst
    fit_to_burst = {
        id = 275892,
        triggers = {
            fit_to_burst = { 275893, 275892, 275894 },
        },
    },

    -- Flames of Alacrity
    flames_of_alacrity = {
        id = 272932,
        triggers = {
            flames_of_alacrity = { 272934, 272932 },
        },
    },

    -- Flash Freeze
    flash_freeze = {
        id = 288164,
        triggers = {
            flash_freeze = { 288164 },
        },
    },

    -- Flashpoint
    flashpoint = {
        id = 275425,
        triggers = {
            flashpoint = { 275425, 275429 },
        },
    },

    -- Focused Fire
    focused_fire = {
        id = 278531,
        triggers = {
            focused_fire = { 278531, 279636 },
        },
    },

    -- Font of Life
    font_of_life = {
        id = 279875,
        triggers = {
            font_of_life = { 279875 },
        },
    },

    -- Footpad
    footpad = {
        id = 274692,
        triggers = {
            footpad = { 274692, 274695 },
        },
    },

    -- Fortifying Auras
    fortifying_auras = {
        id = 273134,
        triggers = {
            fortifying_auras = { 273134 },
        },
    },

    -- Frigid Grasp
    frigid_grasp = {
        id = 278542,
        triggers = {
            frigid_grasp = { 278542, 279684 },
        },
    },

    -- Frostwhelp's Indignation
    frostwhelps_indignation = {
        id = 287283,
        triggers = {
            frostwhelps_indignation = { 287338, 287283 },
        },
    },

    -- Frozen Tempest
    frozen_tempest = {
        id = 278487,
        triggers = {
            frozen_tempest = { 278487 },
        },
    },

    -- Furious Gaze
    furious_gaze = {
        id = 273231,
        triggers = {
            furious_gaze = { 273232, 273231 },
        },
    },

    -- Fury of Xuen
    fury_of_xuen = {
        id = 287055,
        triggers = {
            fury_of_xuen = { 287062, 287055, 287063 },
        },
    },

    -- Gallant Steed
    gallant_steed = {
        id = 280017,
        triggers = {
            gallant_steed = { 280191, 280192, 280017 },
        },
    },

    -- Galvanizing Spark
    galvanizing_spark = {
        id = 278536,
        triggers = {
            galvanizing_spark = { 278536 },
        },
    },

    -- Gathering Storm
    gathering_storm = {
        id = 273409,
        triggers = {
            gathering_storm = { 273415, 273409 },
        },
    },

    -- Gemhide
    gemhide = {
        id = 268596,
        triggers = {
            gemhide = { 268596, 270576 },
        },
    },

    -- Glacial Assault
    glacial_assault = {
        id = 279854,
        triggers = {
            glacial_assault = { 279854, 279856, 279855 },
        },
    },

    -- Glimmer of Light
    glimmer_of_light = {
        id = 287268,
        triggers = {
            glimmer_of_light = { 287280, 287268 },
        },
    },

    -- Glory in Battle
    glory_in_battle = {
        id = 280577,
        triggers = {
            glory_in_battle = { 280780, 280577 },
        },
    },

    -- Glory of the Dawn
    glory_of_the_dawn = {
        id = 288634,
        triggers = {
            glory_of_the_dawn = { 288636, 288634 },
        },
    },

    -- Gory Regeneration
    gory_regeneration = {
        id = 278510,
        triggers = {
            gory_regeneration = { 278510 },
        },
    },

    -- Grace of the Justicar
    grace_of_the_justicar = {
        id = 278593,
        triggers = {
            grace_of_the_justicar = { 278593, 278785 },
        },
    },

    -- Grove Tending
    grove_tending = {
        id = 279778,
        triggers = {
            grove_tending = { 279778, 279793 },
        },
    },

    -- Guardian's Wrath
    guardians_wrath = {
        id = 278511,
        triggers = {
            guardians_wrath = { 278511, 279541 },
        },
    },

    -- Gushing Lacerations
    gushing_lacerations = {
        id = 278509,
        triggers = {
            gushing_lacerations = { 278509, 279468 },
        },
    },

    -- Gutripper
    gutripper = {
        id = 266937,
        triggers = {
            gutripper = { 270668, 266937, 269031 },
        },
    },

    -- Harrowing Decay
    harrowing_decay = {
        id = 275929,
        triggers = {
            harrowing_decay = { 275931, 275929 },
        },
    },

    -- Haze of Rage
    haze_of_rage = {
        id = 273262,
        triggers = {
            haze_of_rage = { 273264, 273262 },
        },
    },

    -- Healing Hammer
    healing_hammer = {
        id = 273142,
        triggers = {
            healing_hammer = { 273142 },
        },
    },

    -- Heart of Darkness
    heart_of_darkness = {
        id = 317137,
        triggers = {
            heart_of_darkness = { 317137, 316101 }
        },
    },

    -- Heed My Call
    heed_my_call = {
        id = 263987,
        triggers = {
            heed_my_call = { 263987, 271686, 271685 },
        },
    },

    -- Helchains
    helchains = {
        id = 286832,
        triggers = {
            helchains = { 286832 },
        },
    },

    -- High Noon
    high_noon = {
        id = 278505,
        triggers = {
            high_noon = { 278505 },
        },
    },

    -- Hour of Reaping
    hour_of_reaping = {
        id = 288878,
        triggers = {
            hour_of_reaping = { 288882, 288878 },
        },
    },

    -- Icy Citadel
    icy_citadel = {
        id = 272718,
        triggers = {
            icy_citadel = { 272718, 272723 },
        },
    },

    -- Igneous Potential
    igneous_potential = {
        id = 279829,
        triggers = {
            igneous_potential = { 279829 },
        },
    },

    -- Impassive Visage
    impassive_visage = {
        id = 268437,
        triggers = {
            impassive_visage = { 270117, 270654, 268437 },
        },
    },

    -- In The Rhythm
    in_the_rhythm = {
        id = 264198,
        triggers = {
            in_the_rhythm = { 272733, 264198 },
        },
    },

    -- Incite the Pack
    incite_the_pack = {
        id = 280410,
        triggers = {
            incite_the_pack = { 280413, 280410, 280412 },
        },
    },

    -- Indomitable Justice
    indomitable_justice = {
        id = 275496,
        triggers = {
            indomitable_justice = { 275496 },
        },
    },

    -- Inevitability
    inevitability = {
        id = 278683,
        triggers = {
            inevitability = { 278683 },
        },
    },

    -- Inevitable Demise
    inevitable_demise = {
        id = 273521,
        triggers = {
            inevitable_demise = { 273521, 273525 },
        },
    },

    -- Infernal Armor
    infernal_armor = {
        id = 273236,
        triggers = {
            infernal_armor = { 273239, 273236 },
        },
    },

    -- Infinite Fury
    infinite_fury = {
        id = 277638,
        triggers = {
            infinite_fury = { 278134, 277638 },
        },
    },

    -- Inner Light
    inner_light = {
        id = 275477,
        triggers = {
            inner_light = { 275483, 275481, 275477 },
        },
    },

    -- Inspiring Beacon
    inspiring_beacon = {
        id = 273130,
        triggers = {
            inspiring_beacon = { 273130 },
        },
    },

    -- Inspiring Vanguard
    inspiring_vanguard = {
        id = 278609,
        triggers = {
            inspiring_vanguard = { 279397, 278609 },
        },
    },

    -- Intimidating Presence
    intimidating_presence = {
        id = 288641,
        triggers = {
            intimidating_presence = { 288644, 288641 },
        },
    },

    -- Iron Fortress
    iron_fortress = {
        id = 278765,
        triggers = {
            iron_fortress = { 278765 },
        },
    },

    -- Iron Jaws
    iron_jaws = {
        id = 276021,
        triggers = {
            iron_jaws = { 276021, 276026 },
        },
    },

    -- Judicious Defense
    judicious_defense = {
        id = 277675,
        triggers = {
            judicious_defense = { 277675, 278574 },
        },
    },

    -- Jungle Fury
    jungle_fury = {
        id = 274424,
        triggers = {
            jungle_fury = { 274424, 274426, 274425 },
        },
    },

    -- Keep Your Wits About You
    keep_your_wits_about_you = {
        id = 288979,
        triggers = {
            keep_your_wits_about_you = { 288979 },
        },
    },

    -- Killer Frost
    killer_frost = {
        id = 278480,
        triggers = {
            killer_frost = { 278480 },
        },
    },

    -- Laser Matrix
    laser_matrix = {
        id = 280559,
        triggers = {
            laser_matrix = { 280559 },
        },
    },

    -- Last Gift
    last_gift = {
        id = 280624,
        triggers = {
            last_gift = { 280861, 280862, 280624 },
        },
    },

    -- Last Surprise
    last_surprise = {
        id = 278489,
        triggers = {
            last_surprise = { 278489 },
        },
    },

    -- Latent Chill
    latent_chill = {
        id = 273093,
        triggers = {
            latent_chill = { 273093 },
        },
    },

    -- Latent Poison
    latent_poison = {
        id = 273283,
        triggers = {
            latent_poison = { 273286, 273283 },
        },
    },

    -- Lava Shock
    lava_shock = {
        id = 273448,
        triggers = {
            lava_shock = { 273448, 273453 },
        },
    },

    -- Layered Mane
    layered_mane = {
        id = 279552,
        triggers = {
            layered_mane = { 279552 },
        },
    },

    -- Liberator's Might
    liberators_might = {
        id = 280623,
        triggers = {
            liberators_might = { 280852, 280623 },
        },
    },

    -- Lifeblood
    lifeblood = {
        id = 274418,
        triggers = {
            lifeblood = { 274420, 274418 },
        },
    },

    -- Lifespeed
    lifespeed = {
        id = 267665,
        triggers = {
            lifespeed = { 267665 },
        },
    },

    -- Lightning Conduit
    lightning_conduit = {
        id = 275388,
        triggers = {
            lightning_conduit = { 275388, 275394, 275391 },
        },
    },

    -- Light's Decree
    lights_decree = {
        id = 286229,
        triggers = {
            lights_decree = { 286229, 286231 },
        },
    },

    -- Lively Spirit
    lively_spirit = {
        id = 279642,
        triggers = {
            lively_spirit = { 289335, 279642, 279648 },
        },
    },

    -- Longstrider
    longstrider = {
        id = 268594,
        triggers = {
            longstrider = { 268594 },
        },
    },

    -- Lord of War
    lord_of_war = {
        id = 278752,
        triggers = {
            lord_of_war = { 278752, 279203 },
        },
    },

    -- Lunar Shrapnel
    lunar_shrapnel = {
        id = 278507,
        triggers = {
            lunar_shrapnel = { 278507, 279641 },
        },
    },

    -- Lying In Wait
    lying_in_wait = {
        id = 288079,
        triggers = {
            lying_in_wait = { 288079 },
        },
    },

    -- Magus of the Dead
    magus_of_the_dead = {
        id = 288417,
        triggers = {
            magus_of_the_dead = { 288417, 288544 },
        },
    },

    -- March of the Damned
    march_of_the_damned = {
        id = 280011,
        triggers = {
            march_of_the_damned = { 280149, 280011 },
        },
    },

    -- Marrowblood
    marrowblood = {
        id = 274057,
        triggers = {
            marrowblood = { 274057 },
        },
    },

    -- Masterful Instincts
    masterful_instincts = {
        id = 273344,
        triggers = {
            masterful_instincts = { 273349, 273344 },
        },
    },

    -- Meticulous Scheming
    meticulous_scheming = {
        id = 273682,
        triggers = {
            seize_the_moment = { 273714 },
            meticulous_scheming = { 273714, 273682 },
        },
    },

    -- Misty Peaks
    misty_peaks = {
        id = 275975,
        triggers = {
            misty_peaks = { 276025, 275975 },
        },
    },

    -- Moment of Compassion
    moment_of_compassion = {
        id = 273513,
        triggers = {
            moment_of_compassion = { 273513 },
        },
    },

    -- Moment of Glory
    moment_of_glory = {
        id = 280023,
        triggers = {
            moment_of_glory = { 280210, 280023 },
        },
    },

    -- Moment of Repose
    moment_of_repose = {
        id = 272775,
        triggers = {
            moment_of_repose = { 272775 },
        },
    },

    -- Natural Harmony
    natural_harmony = {
        id = 278697,
        triggers = {
            natural_harmony_nature = { 279033 },
            natural_harmony_frost = { 279029 },
            natural_harmony_fire = { 279028 },
            natural_harmony = { 278697, 279028 },
        },
    },

    -- Nature's Salve
    natures_salve = {
        id = 287938,
        triggers = {
            natures_salve = { 287938, 287940 },
        },
    },

    -- Night's Vengeance
    nights_vengeance = {
        id = 273418,
        triggers = {
            nights_vengeance = { 273418, 273424 },
        },
    },

    -- Nothing Personal
    nothing_personal = {
        id = 286573,
        triggers = {
            nothing_personal = { 286573, 286581 },
        },
    },

    -- On My Way
    on_my_way = {
        id = 267879,
        triggers = {
            on_my_way = { 267879 },
        },
    },

    -- Open Palm Strikes
    open_palm_strikes = {
        id = 279918,
        triggers = {
            open_palm_strikes = { 279918 },
        },
    },

    -- Overflowing Mists
    overflowing_mists = {
        id = 273328,
        triggers = {
            overflowing_mists = { 273328, 273348 },
        },
    },

    -- Overflowing Shores
    overflowing_shores = {
        id = 277658,
        triggers = {
            overflowing_shores = { 277658, 278095 },
        },
    },

    -- Overwhelming Power
    overwhelming_power = {
        id = 266180,
        triggers = {
            overwhelming_power = { 271711, 266180 },
        },
    },

    -- Pack Spirit
    pack_spirit = {
        id = 280021,
        triggers = {
            pack_spirit = { 280205, 280021 },
        },
    },

    -- Packed Ice
    packed_ice = {
        id = 272968,
        triggers = {
            packed_ice = { 272968 },
        },
    },

    -- Pandemic Invocation
    pandemic_invocation = {
        id = 289364,
        triggers = {
            pandemic_invocation = { 289367, 289364 },
        },
    },

    -- Paradise Lost
    paradise_lost = {
        id = 278675,
        triggers = {
            paradise_lost = { 278962, 278675 },
        },
    },

    -- Perforate
    perforate = {
        id = 277673,
        triggers = {
            perforate = { 277673, 277720 },
        },
    },

    -- Permeating Glow
    permeating_glow = {
        id = 272780,
        triggers = {
            permeating_glow = { 272783, 272780 },
        },
    },

    -- Personal Absorb-o-Tron
    personal_absorbotron = {
        id = 280181,
        triggers = {
            personal_absorbotron = { 280660, 280181 },
        },
    },

    -- Power of the Moon
    power_of_the_moon = {
        id = 273367,
        triggers = {
            arcanic_pulsar = { 287790 },
            power_of_the_moon = { 273367 },
        },
    },

    -- Prayerful Litany
    prayerful_litany = {
        id = 275602,
        triggers = {
            prayerful_litany = { 275602 },
        },
    },

    -- Pressure Point
    pressure_point = {
        id = 278577,
        triggers = {
            pressure_point = { 278718, 278577 },
        },
    },

    -- Primal Instincts
    primal_instincts = {
        id = 279806,
        triggers = {
            primal_instincts = { 279806, 279810 },
        },
    },

    -- Primal Primer
    primal_primer = {
        id = 272992,
        triggers = {
            primal_primer = { 272992, 273006 },
        },
    },

    -- Primeval Intuition
    primeval_intuition = {
        id = 288570,
        triggers = {
            primeval_intuition = { 288570, 288573 },
        },
    },

    -- Promise of Deliverance
    promise_of_deliverance = {
        id = 287336,
        triggers = {
            promise_of_deliverance = { 287340, 287336 },
        },
    },

    -- Pulverizing Blows
    pulverizing_blows = {
        id = 275632,
        triggers = {
            pulverizing_blows = { 275672, 275632 },
        },
    },

    -- Quick Thinking
    quick_thinking = {
        id = 288121,
        triggers = {
            quick_thinking = { 288121 },
        },
    },

    -- Radiant Incandescence
    radiant_incandescence = {
        id = 277674,
        triggers = {
            radiant_incandescence = { 277674, 278147, 278145 },
        },
    },

    -- Rampant Growth
    rampant_growth = {
        id = 278515,
        triggers = {
            rampant_growth = { 278515 },
        },
    },

    -- Rapid Reload
    rapid_reload = {
        id = 278530,
        triggers = {
            multishot = { 278565 },
            rapid_reload = { 278530 },
        },
    },

    -- Reawakening
    reawakening = {
        id = 274813,
        triggers = {
            reawakening = { 274813, 285719 },
        },
    },

    -- Reckless Flurry
    reckless_flurry = {
        id = 278758,
        triggers = {
            reckless_flurry = { 278758, 283810 },
        },
    },

    -- Rejuvenating Grace
    rejuvenating_grace = {
        id = 273131,
        triggers = {
            rejuvenating_grace = { 273131 },
        },
    },

    -- Relational Normalization Gizmo
    relational_normalization_gizmo = {
        id = 280178,
        triggers = {
            relational_normalization_gizmo = { 280653, 280178 },
        },
    },

    -- Relentless Inquisitor
    relentless_inquisitor = {
        id = 278617,
        triggers = {
            relentless_inquisitor = { 278617, 279204 },
        },
    },

    -- Replicating Shadows
    replicating_shadows = {
        id = 286121,
        triggers = {
            replicating_shadows = { 286121, 286131 },
        },
    },

    -- Resounding Protection
    resounding_protection = {
        id = 263962,
        triggers = {
            resounding_protection = { 263962, 269279 },
        },
    },

    -- Retaliatory Fury
    retaliatory_fury = {
        id = 280579,
        triggers = {
            retaliatory_fury = { 280787, 280579, 280788 },
        },
    },

    -- Revel in Pain
    revel_in_pain = {
        id = 272983,
        triggers = {
            revel_in_pain = { 272983, 272987 },
        },
    },

    -- Revolving Blades
    revolving_blades = {
        id = 279581,
        triggers = {
            revolving_blades = { 279581, 279584 },
        },
    },

    -- Rezan's Fury
    rezans_fury = {
        id = 273790,
        triggers = {
            rezans_fury = { 273794, 273790 },
        },
    },

    -- Ricocheting Inflatable Pyrosaw
    ricocheting_inflatable_pyrosaw = {
        id = 280168,
        triggers = {
            ricocheting_inflatable_pyrosaw = { 280656, 280168 },
        },
    },

    -- Righteous Conviction
    righteous_conviction = {
        id = 287126,
        triggers = {
            righteous_conviction = { 287126 },
        },
    },

    -- Righteous Flames
    righteous_flames = {
        id = 273140,
        triggers = {
            righteous_flames = { 273140 },
        },
    },

    -- Rigid Carapace
    rigid_carapace = {
        id = 275350,
        triggers = {
            rigid_carapace = { 275350, 275351 },
        },
    },

    -- Roiling Storm
    roiling_storm = {
        id = 278719,
        triggers = {
            roiling_storm = { 279515, 278719 },
        },
    },

    -- Rolling Havoc
    rolling_havoc = {
        id = 278747,
        triggers = {
            rolling_havoc = { 278931, 278747 },
        },
    },

    -- Ruinous Bolt
    ruinous_bolt = {
        id = 273150,
        triggers = {
            ruinous_bolt = { 273150, 280204 },
        },
    },

    -- Runic Barrier
    runic_barrier = {
        id = 280010,
        triggers = {
            runic_barrier = { 280010 },
        },
    },

    -- Sanctum
    sanctum = {
        id = 274366,
        triggers = {
            sanctum = { 274369, 274366 },
        },
    },

    -- Savior
    savior = {
        id = 267883,
        triggers = {
            savior = { 267883, 270679 },
        },
    },

    -- Scent of Blood
    scent_of_blood = {
        id = 277679,
        triggers = {
            scent_of_blood = { 277679, 277731 },
        },
    },

    -- Searing Dialogue
    searing_dialogue = {
        id = 272788,
        triggers = {
            searing_dialogue = { 272788, 288371 },
        },
    },

    -- Secret Infusion
    secret_infusion = {
        id = 287829,
        triggers = {
            secret_infusion = { 287829, 287831 },
        },
    },

    -- Secrets of the Deep
    secrets_of_the_deep = {
        id = 273829,
        triggers = {
            secrets_of_the_deep = { 273842, 273829 },
        },
    },

    -- Seductive Power
    seductive_power = {
        id = 288749,
        triggers = {
            seductive_power = { 288777, 288749 },
        },
    },

    -- Seething Power
    seething_power = {
        id = 275934,
        triggers = {
            seething_power = { 275936, 275934 },
        },
    },

    -- Seismic Wave
    seismic_wave = {
        id = 277639,
        triggers = {
            seismic_wave = { 277639, 278497 },
        },
    },

    -- Self Reliance
    self_reliance = {
        id = 268600,
        triggers = {
            self_reliance = { 270661, 268600 },
        },
    },

    -- Serene Spirit
    serene_spirit = {
        id = 274412,
        triggers = {
            serene_spirit = { 274412, 274416 },
        },
    },

    -- Serrated Jaws
    serrated_jaws = {
        id = 272717,
        triggers = {
            serrated_jaws = { 272717 },
        },
    },

    -- Shadow of Elune
    shadow_of_elune = {
        id = 287467,
        triggers = {
            shadow_of_elune = { 287467, 287471 },
        },
    },

    -- Shadow's Bite
    shadows_bite = {
        id = 272944,
        triggers = {
            shadows_bite = { 272945, 272944 },
        },
    },

    -- Shellshock
    shellshock = {
        id = 274355,
        triggers = {
            shellshock = { 274355, 274357 },
        },
    },

    -- Shimmering Haven
    shimmering_haven = {
        id = 271557,
        triggers = {
            shimmering_haven = { 271560, 271557 },
        },
    },

    -- Shrouded Mantle
    shrouded_mantle = {
        id = 280020,
        triggers = {
            shrouded_mantle = { 280020, 280200 },
        },
    },

    -- Shrouded Suffocation
    shrouded_suffocation = {
        id = 278666,
        triggers = {
            shrouded_suffocation = { 278666 },
        },
    },

    -- Simmering Rage
    simmering_rage = {
        id = 278757,
        triggers = {
            simmering_rage = { 278841, 278757, 184367 },
        },
    },

    -- Snake Eyes
    snake_eyes = {
        id = 275846,
        triggers = {
            snake_eyes = { 275863, 275846 },
        },
    },

    -- Soaring Shield
    soaring_shield = {
        id = 278605,
        triggers = {
            soaring_shield = { 278605, 278954 },
        },
    },

    -- Soothing Waters
    soothing_waters = {
        id = 272989,
        triggers = {
            soothing_waters = { 272989 },
        },
    },

    -- Soulmonger
    soulmonger = {
        id = 274344,
        triggers = {
            soulmonger = { 274344, 274346 },
        },
    },

    -- Spiteful Apparitions
    spiteful_apparitions = {
        id = 277682,
        triggers = {
            spiteful_apparitions = { 277682 },
        },
    },

    -- Spouting Spirits
    spouting_spirits = {
        id = 278715,
        triggers = {
            spouting_spirits = { 278715, 279504 },
        },
    },

    -- Staggering Strikes
    staggering_strikes = {
        id = 273464,
        triggers = {
            staggering_strikes = { 273464, 273469 },
        },
    },

    -- Stalwart Protector
    stalwart_protector = {
        id = 274388,
        triggers = {
            stalwart_protector = { 274395, 274388 },
        },
    },

    -- Stand As One
    stand_as_one = {
        id = 280626,
        triggers = {
            stand_as_one = { 280626, 280858 },
        },
    },

    -- Steady Aim
    steady_aim = {
        id = 277651,
        triggers = {
            steady_aim = { 277651, 277959 },
        },
    },

    -- Straight, No Chaser
    straight_no_chaser = {
        id = 285958,
        triggers = {
            straight_no_chaser = { 285958 },
        },
    },

    -- Streaking Stars
    streaking_stars = {
        id = 272871,
        triggers = {
            streaking_star = { 272873 },
            streaking_stars = { 272871 },
        },
    },

    -- Strength in Numbers
    strength_in_numbers = {
        id = 271546,
        triggers = {
            strength_in_numbers = { 271546, 271550 },
        },
    },

    -- Strength of Earth
    strength_of_earth = {
        id = 273461,
        triggers = {
            strength_of_earth = { 273461, 273466 },
        },
    },

    -- Strength of Spirit
    strength_of_spirit = {
        id = 274762,
        triggers = {
            strength_of_spirit = { 274762, 274774 },
        },
    },

    -- Striking the Anvil
    striking_the_anvil = {
        id = 288452,
        triggers = {
            striking_the_anvil = { 288452 },
        },
    },

    -- Stronger Together
    stronger_together = {
        id = 280625,
        triggers = {
            strength_of_the_dwarves = { 280868 },
            stronger_together = { 280625, 280866 },
            strength_of_the_night_elves = { 280867 },
            strength_of_the_gnomes = { 280870 },
            strength_of_the_humans = { 280866 },
            strength_of_the_draenei = { 280869 },
        },
    },

    -- Sudden Onset
    sudden_onset = {
        id = 278721,
        triggers = {
            sudden_onset = { 278721 },
        },
    },

    -- Sudden Revelation
    sudden_revelation = {
        id = 287355,
        triggers = {
            sudden_revelation = { 287356, 287360, 287355 },
        },
    },

    -- Sunrise Technique
    sunrise_technique = {
        id = 273291,
        triggers = {
            sunrise_technique = { 275673, 273298, 273291 },
        },
    },

    -- Supreme Commander
    supreme_commander = {
        id = 279878,
        triggers = {
            supreme_commander = { 279885, 279878 },
        },
    },

    -- Surging Shots
    surging_shots = {
        id = 287707,
        triggers = {
            surging_shots = { 287707 },
        },
    },

    -- Surging Tides
    surging_tides = {
        id = 278713,
        triggers = {
            surging_tides = { 278713, 279187 },
        },
    },

    -- Sweep the Leg
    sweep_the_leg = {
        id = 280016,
        triggers = {
            sweep_the_leg = { 280187, 280016 },
        },
    },

    -- Swelling Stream
    swelling_stream = {
        id = 275488,
        triggers = {
            swelling_stream = { 275499, 275488 },
        },
    },

    -- Swirling Sands
    swirling_sands = {
        id = 280429,
        triggers = {
            swirling_sands = { 280429, 280433 },
        },
    },

    -- Switch Hitter
    switch_hitter = {
        id = 287803,
        triggers = {
            switch_hitter = { 287808, 287803 },
        },
    },

    -- Sylvanas' Resolve
    sylvanas_resolve = {
        id = 280598,
        triggers = {
            sylvanas_resolve = { 280809, 280598 },
        },
    },

    -- Synapse Shock
    synapse_shock = {
        id = 277671,
        triggers = {
            synapse_shock = { 277960, 277671 },
        },
    },

    -- Synaptic Spark Capacitor
    synaptic_spark_capacitor = {
        id = 280174,
        triggers = {
            synaptic_spark_capacitor = { 280847, 280174 },
        },
    },

    -- Synergistic Growth
    synergistic_growth = {
        id = 267892,
        triggers = {
            synergistic_growth = { 272089, 267892, 272090 },
        },
    },

    -- Tectonic Thunder
    tectonic_thunder = {
        id = 286949,
        triggers = {
            tectonic_thunder = { 286949 },
        },
    },

    -- Terror of the Mind
    terror_of_the_mind = {
        id = 287822,
        triggers = {
            terror_of_the_mind = { 287828, 287822 },
        },
    },

    -- Test of Might
    test_of_might = {
        id = 275529,
        triggers = {
            test_of_might = { 275529, 275540 },
        },
    },

    -- The First Dance
    the_first_dance = {
        id = 278681,
        triggers = {
            the_first_dance = { 278681, 278981 },
        },
    },

    -- Thirsting Blades
    thirsting_blades = {
        id = 278493,
        triggers = {
            thirsting_blades = { 278729, 278493 },
        },
    },

    -- Thought Harvester
    thought_harvester = {
        id = 288340,
        triggers = {
            thought_harvester = { 288340, 288343 },
        },
    },

    -- Thrive in Chaos
    thrive_in_chaos = {
        id = 288973,
        triggers = {
            thrive_in_chaos = { 288973 },
        },
    },

    -- Thunderaan's Fury
    thunderaans_fury = {
        id = 287768,
        triggers = {
            thunderaans_fury = { 287802, 287768 },
        },
    },

    -- Thunderous Blast
    thunderous_blast = {
        id = 280380,
        triggers = {
            thunderous_blast = { 280380, 280384, 280385 },
        },
    },

    -- Tidal Surge
    tidal_surge = {
        id = 280402,
        triggers = {
            tidal_surge = { 280402, 280404 },
        },
    },

    -- Tradewinds
    tradewinds = {
        id = 281841,
        triggers = {
            tradewinds = { 281841, 281843, 281844 },
        },
    },

    -- Trailing Embers
    trailing_embers = {
        id = 277656,
        triggers = {
            trailing_embers = { 277703, 277656 },
        },
    },

    -- Training of Niuzao
    training_of_niuzao = {
        id = 278569,
        triggers = {
            training_of_niuzao = { 278569 },
        },
    },

    -- Treacherous Covenant
    treacherous_covenant = {
        id = 288953,
        triggers = {
            treacherous_covenant = { 288953 },
        },
    },

    -- Tunnel of Ice
    tunnel_of_ice = {
        id = 277663,
        triggers = {
            tunnel_of_ice = { 277663, 277904 },
        },
    },

    -- Turn of the Tide
    turn_of_the_tide = {
        id = 287300,
        triggers = {
            turn_of_the_tide = { 287302, 287300 },
        },
    },

    -- Twist Magic
    twist_magic = {
        id = 280018,
        triggers = {
            twist_magic = { 280198, 280018 },
        },
    },

    -- Twist the Knife
    twist_the_knife = {
        id = 273488,
        triggers = {
            twist_the_knife = { 273488 },
        },
    },

    -- Twisted Claws
    twisted_claws = {
        id = 275906,
        triggers = {
            twisted_claws = { 275906, 275909 },
        },
    },

    -- Umbral Blaze
    umbral_blaze = {
        id = 273523,
        triggers = {
            umbral_blaze = { 273523, 273526 },
        },
    },

    -- Unbridled Ferocity
    unbridled_ferocity = {
        id = 288056,
        triggers = {
            unbridled_ferocity = { 288056, 288060 },
        },
    },

    -- Unerring Vision
    unerring_vision = {
        id = 274444,
        triggers = {
            unerring_vision = { 274444, 274447 },
        },
    },

    -- Unstable Catalyst
    unstable_catalyst = {
        id = 281514,
        triggers = {
            unstable_catalyst = { 281516, 281514 },
        },
    },

    -- Unstable Flames
    unstable_flames = {
        id = 279899,
        triggers = {
            unstable_flames = { 279899, 279902 },
        },
    },

    -- Untamed Ferocity
    untamed_ferocity = {
        id = 273338,
        triggers = {
            gushing_lacerations = { 279471 },
            untamed_ferocity = { 273338 },
        },
    },

    -- Uplifted Spirits
    uplifted_spirits = {
        id = 278576,
        triggers = {
            uplifted_spirits = { 278576 },
        },
    },

    -- Ursoc's Endurance
    ursocs_endurance = {
        id = 280013,
        triggers = {
            ursocs_endurance = { 280165, 280013 },
        },
    },

    -- Vampiric Speed
    vampiric_speed = {
        id = 268599,
        triggers = {
            vampiric_speed = { 268599, 269238, 269239 },
        },
    },

    -- Venomous Fangs
    venomous_fangs = {
        id = 274590,
        triggers = {
            venomous_fangs = { 274590 },
        },
    },

    -- Waking Dream
    waking_dream = {
        id = 278513,
        triggers = {
            waking_dream = { 278513 },
        },
    },

    -- Weal and Woe
    weal_and_woe = {
        id = 273307,
        triggers = {
            weal_and_woe = { 273307 },
        },
    },

    -- Whispers of the Damned
    whispers_of_the_damned = {
        id = 275722,
        triggers = {
            whispers_of_the_damned = { 275726, 275722 },
        },
    },

    -- Whiteout
    whiteout = {
        id = 278541,
        triggers = {
            whiteout = { 278541 },
        },
    },

    -- Wild Fleshrending
    wild_fleshrending = {
        id = 279527,
        triggers = {
            wild_fleshrending = { 279527 },
        },
    },

    -- Wilderness Survival
    wilderness_survival = {
        id = 278532,
        triggers = {
            wilderness_survival = { 278532 },
        },
    },

    -- Wildfire
    wildfire = {
        id = 288755,
        triggers = {
            wildfire = { 288800, 288755 },
        },
    },

    -- Wildfire Cluster
    wildfire_cluster = {
        id = 272742,
        triggers = {
            wildfire_cluster = { 272742, 272745 },
        },
    },

    -- Winds of War
    winds_of_war = {
        id = 267671,
        triggers = {
            winds_of_war = { 267671, 269214 },
        },
    },

    -- Word of Mending
    word_of_mending = {
        id = 278645,
        triggers = {
            word_of_mending = { 278645 },
        },
    },

    -- Woundbinder
    woundbinder = {
        id = 267880,
        triggers = {
            woundbinder = { 267880, 269085 },
        },
    },

    -- Wracking Brilliance
    wracking_brilliance = {
        id = 272891,
        triggers = {
            wracking_brilliance = { 272893, 272891 },
        },
    },


    -- 8.2
    -- Arcane Heart
    arcane_heart = {
        id = 303006,
        triggers = {
            arcane_heart = { 303211, 303209, 303210 },
        }
    },
    
    -- Loyal to the End
    loyal_to_the_end = {
        id = 303007,
        triggers = {
            loyal_to_the_end = { 303250, 303365 },
        }
    },

    -- Undulating Tides
    undulating_tides = {
        id = 303008,
        triggers = {
            undulating_tides = { 303438, 303390 }
        }
    }
} )


local function ResetAzerite()
    local heart = FindActiveAzeriteItem()

    if heart and heart:IsValid() then
        rawset( state.azerite, "heart", heart )
    else
        rawset( state.azerite, "heart", nil )
    end
end


Hekili:RegisterGearHook( ResetAzerite )