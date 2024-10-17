-- Legion/Items.lua

local addon, ns = ...
local Hekili = _G[ addon ]

local class, state = Hekili.Class, Hekili.State
local all = Hekili.Class.specs[ 0 ]

-- LEGION LEGENDARIES
all:RegisterGear( "rethus_incessant_courage", 146667 )
    all:RegisterAura( "rethus_incessant_courage", { id = 241330 } )

all:RegisterGear( "vigilance_perch", 146668 )
    all:RegisterAura( "vigilance_perch", { id = 241332, duration =  60, max_stack = 5 } )

all:RegisterGear( "the_sentinels_eternal_refuge", 146669 )
    all:RegisterAura( "the_sentinels_eternal_refuge", { id = 241331, duration = 60, max_stack = 5 } )

all:RegisterGear( "prydaz_xavarics_magnum_opus", 132444 )
    all:RegisterAura( "xavarics_magnum_opus", { id = 207428, duration = 30 } )



all:RegisterAbility( "draught_of_souls", {
    cast = 0,
    cooldown = 80,
    gcd = "off",

    item = 140808,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "fel_crazed_rage", 3 )
        setCooldown( "global_cooldown", 3 )
    end,
} )

all:RegisterAura( "fel_crazed_rage", {
    id = 225141,
    duration = 3,
})


all:RegisterAbility( "faulty_countermeasure", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 137539,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "sheathed_in_frost" )
    end
} )

all:RegisterAura( "sheathed_in_frost", {
    id = 214962,
    duration = 30
} )


all:RegisterAbility( "feloiled_infernal_machine", {
    cast = 0,
    cooldown = 80,
    gcd = "off",

    item = 144482,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "grease_the_gears" )
    end,
} )

all:RegisterAura( "grease_the_gears", {
    id = 238534,
    duration = 20
} )


all:RegisterAbility( "forgefiends_fabricator", {
    item = 151963,
    spend = 0,
    cast = 0,
    cooldown = 30,
    gcd = "off",
} )


all:RegisterAbility( "horn_of_valor", {
    item = 133642,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = "off",
    toggle = "cooldowns",
    handler = function () applyBuff( "valarjars_path" ) end
} )

all:RegisterAura( "valarjars_path", {
    id = 215956,
    duration = 30,
    max_stack = 1
} )


all:RegisterAbility( "kiljaedens_burning_wish", {
    item = 144259,

    cast = 0,
    cooldown = 75,
    gcd = "off",

    texture = 1357805,

    toggle = "cooldowns",
} )


all:RegisterAbility( "might_of_krosus", {
    item = 140799,
    spend = 0,
    cast = 0,
    cooldown = 30,
    gcd = "off",
    handler = function () if active_enemies > 3 then setCooldown( "might_of_krosus", 15 ) end end
} )


all:RegisterAbility( "ring_of_collapsing_futures", {
    item = 142173,
    spend = 0,
    cast = 0,
    cooldown = 15,
    gcd = "off",
    readyTime = function () return debuff.temptation.remains end,
    handler = function () applyDebuff( "player", "temptation", 30, debuff.temptation.stack + 1 ) end
} )

all:RegisterAura( "temptation", {
    id = 234143,
    duration = 30,
    max_stack = 20
} )


all:RegisterAbility( "specter_of_betrayal", {
    item = 151190,
    spend = 0,
    cast = 0,
    cooldown = 45,
    gcd = "off",
} )


all:RegisterAbility( "tiny_oozeling_in_a_jar", {
    item = 137439,
    spend = 0,
    cast = 0,
    cooldown = 20,
    gcd = "off",
    usable = function () return buff.congealing_goo.stack == 6 end,
    handler = function () removeBuff( "congealing_goo" ) end
} )

all:RegisterAura( "congealing_goo", {
    id = 215126,
    duration = 60,
    max_stack = 6
} )


all:RegisterAbility( "umbral_moonglaives", {
    item = 147012,
    spend = 0,
    cast = 0,
    cooldown = 90,
    gcd = "off",
    toggle = "cooldowns",
} )


all:RegisterAbility( "unbridled_fury", {
    item = 139327,
    spend = 0,
    cast = 0,
    cooldown = 120,
    gcd = "off",
    toggle = "cooldowns",
    handler = function () applyBuff( "wild_gods_fury" ) end
} )

all:RegisterAura( "wild_gods_fury", {
    id = 221695,
    duration = 30
} )


all:RegisterAbility( "vial_of_ceaseless_toxins", {
    item = 147011,
    spend = 0,
    cast = 0,
    cooldown = 60,
    gcd = "off",
    toggle = "cooldowns",
    handler = function () applyDebuff( "target", "ceaseless_toxin", 20 ) end
} )

all:RegisterAura( "ceaseless_toxin", {
    id = 242497,
    duration = 20
} )


all:RegisterAbility( "tome_of_unraveling_sanity", {
    item = 147019,
    spend = 0,
    cast = 0,
    cooldown = 60,
    gcd = "off",
    toggle = "cooldowns",
    handler = function () applyDebuff( "target", "insidious_corruption", 12 ) end
} )

all:RegisterAura( "insidious_corruption", {
    id = 243941,
    duration = 12
} )
all:RegisterAura( "extracted_sanity", {
    id = 243942,
    duration =  24
} )

all:RegisterGear( "aggramars_stride", 132443 )
all:RegisterAura( "aggramars_stride", {
    id = 207438,
    duration = 3600
} )

all:RegisterGear( "sephuzs_secret", 132452 )
all:RegisterAura( "sephuzs_secret", {
    id = 208051,
    duration = 10
} )
all:RegisterAbility( "buff_sephuzs_secret", {
    name = "Sephuz's Secret (ICD)",
    cast = 0,
    cooldown = 30,
    gcd = "off",

    unlisted = true,
    usable = function () return false end,
} )

all:RegisterGear( "archimondes_hatred_reborn", 144249 )
all:RegisterAura( "archimondes_hatred_reborn", {
    id = 235169,
    duration = 10,
    max_stack = 1
} )

all:RegisterGear( "amanthuls_vision", 154172 )
all:RegisterAura( "glimpse_of_enlightenment", {
    id = 256818,
    duration = 12
} )
all:RegisterAura( "amanthuls_grandeur", {
    id = 256832,
    duration = 15
} )

all:RegisterGear( "insignia_of_the_grand_army", 152626 )

all:RegisterGear( "eonars_compassion", 154172 )
all:RegisterAura( "mark_of_eonar", {
    id = 256824,
    duration = 12
} )
all:RegisterAura( "eonars_verdant_embrace", {
    id = function ()
        if class.file == "SHAMAN" then return 257475 end
        if class.file == "DRUID" then return 257470 end
        if class.file == "MONK" then return 257471 end
        if class.file == "PALADIN" then return 257472 end
        if class.file == "PRIEST" then
            if spec.discipline then return 257473 end
            if spec.holy then return 257474 end
        end
        return 257475
    end,
    duration = 20,
    copy = { 257470, 257471, 257472, 257473, 257474, 257475 }
} )
all:RegisterAura( "verdant_embrace", {
    id = 257444,
    duration = 30
} )


all:RegisterGear( "aggramars_conviction", 154173 )
all:RegisterAura( "celestial_bulwark", {
    id = 256816,
    duration = 14
} )
all:RegisterAura( "aggramars_fortitude", {
    id = 256831,
    duration = 15
 } )

all:RegisterGear( "golganneths_vitality", 154174 )
all:RegisterAura( "golganneths_thunderous_wrath", {
    id = 256833,
    duration = 15
} )

all:RegisterGear( "khazgoroths_courage", 154176 )
all:RegisterAura( "worldforgers_flame", {
    id = 256826,
    duration = 12
} )
all:RegisterAura( "khazgoroths_shaping", {
    id = 256835,
    duration = 15
} )

all:RegisterGear( "norgannons_prowess", 154177 )
all:RegisterAura( "rush_of_knowledge", {
    id = 256828,
    duration = 12
} )
all:RegisterAura( "norgannons_command", {
    id = 256836,
    duration = 15,
    max_stack = 6
} )


-- Legion TW
all:RegisterAbilities( {
    windscar_whetstone = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 137486,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "slicing_maelstrom" )
        end,

        proc = "damage",

        auras = {
            slicing_maelstrom = {
                id = 214980,
                duration = 6,
                max_stack = 1
            }
        }
    },

    giant_ornamental_pearl = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 137369,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "gaseous_bubble" )
        end,

        auras = {
            gaseous_bubble = {
                id = 214971,
                duration = 8,
                max_stack = 1
            }
        }
    },

    bottled_hurricane = {
        cast = 0,
        gcd = "off",

        item = 137369,

        toggle = "cooldowns",

        buff = "gathering_clouds",

        handler = function ()
            removeBuff( "gathering_clouds" )
        end,

        auras = {
            gathering_clouds = {
                id = 215294,
                duration = 60,
                max_stack = 10
            }
        }
    },

    shard_of_rokmora = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 137338,

        toggle = "defensives",

        handler = function ()
            applyBuff( "crystalline_body" )
        end,

        auras = {
            crystalline_body = {
                id = 214366,
                duration = 30,
                max_stack = 1
            }
        }
    },

    talisman_of_the_cragshaper = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 137344,

        toggle = "defensives",

        handler = function ()
            applyBuff( "stance_of_the_mountain" )
        end,

        auras = {
            stance_of_the_mountain = {
                id = 214423,
                duration = 15,
                max_stack = 1
            }
        }
    },

    tirathons_betrayal = {
        cast = 0,
        cooldown = 75,
        gcd = "off",

        item = 137537,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "darkstrikes" )
        end,

        auras = {
            darkstrikes = {
                id = 215658,
                duration = 15,
                max_stack = 1
            }
        }
    },

    orb_of_torment = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 137538,

        toggle = "defensives",

        handler = function ()
            applyDebuff( "target", "soul_sap" )
        end,

        auras = {
            soul_sap = {
                id = 215936,
                duration = 20,
                max_stack = 1
            }
        }
    },

    moonlit_prism = {
        cast = 0,
        cooldown = 90,
        gcd = "off",

        item = 137541,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "elunes_light" )
        end,

        auras = {
            elunes_light = {
                id = 215648,
                duration = 20,
                max_stack = 20
            }
        }
    },
} )
