-- Essences.lua
-- November 2020

local addon, ns = ...
local Hekili = _G[ addon ]

local all = Hekili.Class.specs[ 0 ]
local state = Hekili.State


all:RegisterAbility( "reaping_flames", {
    id = 310690,
    cast = 0,
    cooldown = function ()
        if target.health.pct < 20 then return 15 end
        if essence.breath_of_the_dying.rank > 1 and target.health.pct > 80 then return 15 end
        return 45
    end,
    startsCombat = true,
    toggle = "essences",
    essence = true,

    handler = function ()
        removeBuff( "reaping_flames" )
    end,
} )

all:RegisterAura( "reaping_flames", {
    id = 311202,
    duration = 30,
    max_stack = 1
} )


-- Spark of Inspiration
all:RegisterAbility( "moment_of_glory", {
    id = 311203,
    cast = 1.5,
    cooldown = 60,

    startsCombat = false,
    toggle = "essences",
    essence = true,

    handler = function ()
        applyBuff( "moment_of_glory" )
    end,
} )

all:RegisterAura( "moment_of_glory", {
    id = 311203,
    duration = function () return essence.spark_of_inspiration.rank > 1 and 20 or 10 end,
    max_stack = 1,
} )


-- The Formless Void
all:RegisterAbility( "replica_of_knowledge", {
    id = 312725,
    cast = 1.5,
    cooldown = 15,

    startsCombat = false,
    toggle = "essences",
    essence = true,
} )

all:RegisterAura( "symbiotic_presence", {
    id = 312915,
    duration = 20,
    max_stack = 1,
    copy = 313918,
} )


-- Touch of the Everlasting
all:RegisterAuras( {
    touch_of_the_everlasting = {
        id = 295048,
        duration = 3,
        max_stack = 1
    },

    touch_of_the_everlasting_icd = {
        id = 295047,
        duration = 600,
        max_stack = 1
    },

    will_to_survive =  {
        id = 295343,
        duration = 15,
        max_stack = 1
    },

    will_to_survive_am = {
        id = 312922,
        duration = 15,
        max_stack = 1,
    },

    will_to_survive_icd = {
        id = 295339,
        duration = function () return essence.touch_of_the_everlasting.rank > 1 and 60 or 90 end,
        max_stack = 1
    },
} )


-- Strength of the Warden
all:RegisterAbility( "vigilant_protector", {
    id = 310592,
    cast = 0,
    cooldown = 120,

    startsCombat = true,
    toggle = "essences",
    essence = true,

    function ()
        applyDebuff( "target", "vigilant_protector" )
    end,
} )

all:RegisterAura( "vigilant_protector", {
    id = 310592,
    duration = 6,
    max_stack = 1
} )

all:RegisterAura( "endurance", {
    id = 312107,
    duration = 3600,
    max_stack = 1,
} )


-- DPS Essences
-- Blood of the Enemy
all:RegisterAbility( "blood_of_the_enemy", {
    id = 297108,
    cast = 0,
    cooldown = function () return essence.blood_of_the_enemy.rank > 1 and 90 or 120 end,

    startsCombat = true,
    toggle = "essences",
    essence = true,

    range = 11,

    handler = function()
        applyDebuff( "target", "blood_of_the_enemy" )
        active_dot.blood_of_the_enemy = active_enemies
        if essence.blood_of_the_enemy.rank > 2 then applyBuff( "seething_rage_297126" ) end
    end
} )

all:RegisterAuras( {
    seething_rage_297126 = {
        id = 297126,
        duration = 10,
        max_stack = 1,
    },
    bloodsoaked = {
        id = 297162,
        duration = 3600,
        max_stack = 40
    },
    blood_of_the_enemy ={
        id = 297108,
        duration = 10,
        max_stack = 1,
    }
} )


-- Condensed Life-Force
all:RegisterAbility( "guardian_of_azeroth", {
    id = 295840,
    cast = 0,
    cooldown = 180,

    startsCombat = true,
    toggle = "essences",
    essence = true,

    handler = function()
        summonPet( "guardian_of_azeroth", 30 )
    end,

    copy = "condensed_lifeforce"
} )

all:RegisterPet( "guardian_of_azeroth", 152396, 300091, 31 )

all:RegisterAuras( {
    guardian_of_azeroth = {
        id = 295855,
        duration = 30,
        max_stack = 5
    },
    condensed_lifeforce = {
        id = 295838,
        duration = 6,
        max_stack = 1
    }
} )


-- Conflict and Strife
-- No direct ability; enable PvP talents for each spec.
all:RegisterAura( "strife", {
    id = 304056,
    duration = function () return essence.conflict_and_strife.rank > 1 and 14 or 8 end,
    max_stack = 8
} )


-- Essence of the Focusing Iris
all:RegisterAbility( "focused_azerite_beam", {
    id = 295258,
    cast = function () return essence.essence_of_the_focusing_iris.rank > 1 and 1.1 or 1.7 end,
    channeled = function () return cooldown.focused_azerite_beam.remains > 0 end,
    cooldown = 90,

    startsCombat = true,
    toggle = "essences",
    essence = true,

    handler = function()
        setCooldown( "global_cooldown", 2.5 * haste )
        applyBuff( "casting", 2.5 * haste )
    end
} )

all:RegisterAura( "focused_energy", {
    id = 295248,
    duration = 4,
    max_stack = 10
} )


-- Memory of Lucid Dreams
all:RegisterAbility( "memory_of_lucid_dreams", {
    id = 298357,
    cast = 0,
    cooldown = 120,

    startsCombat = true,
    toggle = "essences",
    essence = true,

    handler = function ()
        applyBuff( "memory_of_lucid_dreams" )
    end
} )

all:RegisterAuras( {
    memory_of_lucid_dreams = {
        id = 298357,
        duration = function () return essence.memory_of_lucid_dreams.rank > 1 and 15 or 12 end,
        max_stack = 1
    },
    lucid_dreams = {
        id = 298343,
        duration = 8,
        max_stack = 1
    }
} )


-- Purification Protocol
all:RegisterAbility( "purifying_blast", {
    id = 295337,
    cast = 0,
    cooldown = 60,

    toggle = "essences",
    essence = true,

    startsCombat = true,
    handler = function ()
        -- Reticle-based, no debuff on target.
    end
} )


-- Ripple in Space
all:RegisterAbility( "ripple_in_space", {
    id = 302731,
    cast = 0,
    cooldown = 60,

    toggle = "essences",
    essence = true,

    handler = function ()
        applyBuff( "ripple_in_space_blink" )
        if essence.ripple_in_space.rank > 2 then applyBuff( "ripple_in_space", buff.ripple_in_space_blink.duration + buff.ripple_in_space.duration ) end
    end
} )

all:RegisterAuras( {
    ripple_in_space_blink = {
        id = 302731,
        duration = function () return essence.ripple_in_space.rank > 1 and 2 or 4 end,
        max_stack = 1
    },
    ripple_in_space = { -- defensive
        id = 302864,
        duration = 10,
        max_stack = 1
    },
    reality_shift = {
        id = 302952,
        duration = function () return essence.ripple_in_space.rank > 1 and 20 or 15 end,
        max_stack = 1
    }
} )


-- The Crucible of Flame
all:RegisterAbility( "concentrated_flame", {
    id = 295373,
    cast = 0,
    charges = function () return essence.the_crucible_of_flame.rank > 2 and 2 or nil end,
    cooldown = 30,
    recharge = function () return essence.the_crucible_of_flame.rank > 2 and 30 or nil end,

    startsCombat = true,
    toggle = "essences",
    essence = true,

    handler = function ()
        if buff.concentrated_flame.stack == 2 then removeBuff( "concentrated_flame" )
        else addStack( "concentrated_flame" ) end

        if essence.the_crucible_of_flame.rank > 1 then applyDebuff( "target", "concentrated_flame_dot" ) end
    end,
} )

all:RegisterAuras( {
    concentrated_flame = {
        id = 295378,
        duration = 180,
        max_stack = 2
    },
    concentrated_flame_dot = {
        id = 295368,
        duration = 6,
        max_stack = 1,
        copy = "concentrated_flame_burn"
    }
} )


-- The Unbound Force
all:RegisterAbility( "the_unbound_force", {
    id = 298452,
    cast = 0,
    cooldown = function () return essence.the_unbound_force.rank > 1 and 45 or 60 end,

    startsCombat = true,
    toggle = "essences",
    essence = true,

    handler = function ()
        applyDebuff( "target", "the_unbound_force" )
    end
} )

all:RegisterAuras( {
    the_unbound_force = {
        id = 298452,
        duration = 2,
        max_stack = 1
    },
    reckless_force_counter = {
        id = 302917,
        duration = 3600,
        max_stack = 20
    },
    reckless_force = {
        id = 302932,
        duration = function () return essence.the_unbound_force.rank > 2 and 4 or 3 end,
        max_stack = 1
    }
} )


-- Vision of Perfection
-- ...is passive.  Can proc spec cooldown at 25% (2+ 35%).
-- ...procs haste buff when this happens.
-- Need to set up passive in *every spec.*
all:RegisterAura( "vision_of_perfection", {
    id = 303344,
    duration = 10,
    max_stack = 1
} )


-- Worldvein Resonance
all:RegisterAbility( "worldvein_resonance", {
    id = 295186,
    cast = 0,
    cooldown = 60,

    toggle = "essences",
    essence = true,

    handler = function()
        applyBuff( "worldvein_resonance" )
        addStack( "lifeblood", nil, essence.worldvein_resonance.rank > 1 and 3 or 2 )
    end,
} )

all:RegisterAuras( {
    lifeblood = {
        id = 295137,
        duration = function () return essence.worldvein_resonance.rank > 1 and 18 or 12 end,
        max_stack = 4,
    },
    worldvein_resonance = {
        id = 313310,
        duration = 18,
        max_stack = 1
    }
} )



-- Tanking Essences
-- Azeroth's Undying Gift
all:RegisterAbility( "azeroths_undying_gift", {
    id = 293019,
    cast = 0,
    cooldown = function () return essence.azeroths_undying_gift.rank > 1 and 45 or 60 end,

    toggle = "defensives",
    essence = true,

    function ()
        applyBuff( "azeroths_undying_gift" )
    end,
} )

all:RegisterAuras( {
    azeroths_undying_gift = {
        id = 293019,
        duration = 4,
        max_stack = 1
    },
    hardened_azerite = {
        id = 294685,
        duration = 8,
        max_stack = 1
    }
} )


-- Anima of Life and Death
all:RegisterAbility( "anima_of_death", {
    id = 294926,
    cast = 0,
    cooldown = function () return essence.anima_of_life_and_death.rank > 1 and 120 or 150 end,

    toggle = "defensives",
    essence = true,

    handler = function ()
        gain( health.max * min( 0.25, 0.05 * active_enemies ) * ( essence.anima_of_life_and_death.rank > 2 and 2 or 1 ), "health" )
    end,
} )

all:RegisterAura( "anima_of_life", {
    id = 294966,
    duration = 3600,
    max_stack = 10
} )


-- Aegis of the Deep
all:RegisterAbility( "aegis_of_the_deep", {
    id = 298168,
    cast = 0,
    cooldown = function () return essence.aegis_of_the_deep.rank > 1 and 67.5 or 90 end,

    toggle = "defensives",
    essence = true,

    handler = function ()
        applyBuff( "aegis_of_the_deep" )
    end
} )

all:RegisterAuras( {
    aegis_of_the_deep = {
        id = 298168,
        duration = 15,
        max_stack = 1
    },
    aegis_of_the_deep_avoidance = {
        id = 304693,
        duration = 6,
        max_stack = 1,
    },
    stand_your_ground = {
        id = 299274,
        duration = 3600,
        max_stack = 10
    }
} )


-- Nullification Dynamo
all:RegisterAbility( "empowered_null_barrier", {
    id = 295746,
    cast = 0,
    cooldown = function () return essence.nullification_dynamo.rank > 1 and 135 or 180 end,

    toggle = "defensives",
    essence = true,

    usable = function ()
        if buff.dispellable_curse.up or buff.dispellable_magic.up or buff.dispellable_poison.up or buff.dispellable_disease.up then return true end
        return false, "no dispellable effects active"
    end,
    handler = function ()
        removeBuff( "dispellable_magic" )
        removeBuff( "dispellable_curse" )
        removeBuff( "dispellable_poison" )
        removeBuff( "dispellable_disease" )
    end
} )

all:RegisterAura( "null_barrier", {
    id = 295842,
    duration = 10,
    max_stack = 1,
} )


-- Sphere of Suppression
all:RegisterAbility( "suppressing_pulse", {
    id = 293031,
    cast = 0,
    cooldown = function () return essence.sphere_of_suppression.rank > 1 and 45 or 60 end,

    startsCombat = true,
    toggle = "essences",
    essence = true,

    handler = function ()
        applyDebuff( "target", "suppressing_pulse" )
        active_dot.suppressing_pulse = active_enemies
        applyBuff( "sphere_of_suppression" )
    end,
} )

all:RegisterAuras( {
    suppressing_pulse = {
        id = 293031,
        duration = 8,
        max_stack = 1
    },
    sphere_of_suppression = {
        id = 294912,
        duration = 7,
        max_stack = 1
    },
    sphere_of_suppression_debuff = {
        id = 294909,
        duration = 7,
        max_stack = 1
    }
} )