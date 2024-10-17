-- BfA/Items.lua

local addon, ns = ...
local Hekili = _G[ addon ]

local class, state = Hekili.Class, Hekili.State
local all = Hekili.Class.specs[ 0 ]

-- 8.3
-- Corruption Curse that impacts resource costs.

all:RegisterAura( "hysteria", {
    id = 312677,
    duration = 30,
    max_stack = 99
} )


-- BFA TRINKETS
-- EQUIPPED EFFECTS
all:RegisterAuras( {
    -- Darkmoon Deck: Squalls
    suffocating_squall = { id = 276132, duration = 26, max_stack = 1 }, -- I made up max duration (assume 13 card types and 2s per card).

    -- Construct Overcharger
    titanic_overcharge = { id = 278070, duration = 10, max_stack = 8 },

    -- Xalzaix's Veiled Eye
    xalzaixs_gaze = { id = 278158, duration = 20, max_stack = 1 },

    -- Syringe of Bloodborne Infirmity
    wasting_infection = { id = 278110, duration = 12, max_stack = 1 },
    critical_prowess = { id = 278109, duration = 6, max_stack = 5 },

    -- Frenetic Corpuscle
    frothing_rage = { id = 278140, duration = 45, max_stack = 4 },

    -- Tear of the Void
    voidspark = { id = 278831, duration = 14, max_stack = 1 },

    -- Prism of Dark Intensity
    dark_intensity = { id = 278378, duration = 18, max_stack = 6,
        meta = {
            -- Stacks every 3 seconds until expiration; should generalize this kind of thing...
            stacks = function ( aura )
                if aura.up then return 1 + floor( ( query_time - aura.applied ) / 3 ) end
                return 0
            end
        }
    },

    -- Plume of the Seaborne Avian
    seaborne_tempest = { id = 278382, duration = 10, max_stack = 1 },

    -- Drust-Runed Icicle
    chill_of_the_runes = { id = 278862, duration = 12, max_stack = 1 },

    -- Permafrost-Encrusted Heart
    coldhearted_instincts = { id = 278388, duration = 15, max_stack = 5, copy = "cold_hearted_instincts",
        meta = {
            -- Stacks every 3 seconds until expiration; should generalize this kind of thing...
            stacks = function ( aura )
                if aura.up then return 1 + floor( ( query_time - aura.applied ) / 3 ) end
                return 0
            end
        }
    },

    -- Spiritbound Voodoo Burl
    coalesced_essence = { id = 278224, duration = 12, max_stack = 1 },

    -- Wing Bone of the Budding Tempest
    avian_tempest = { id = 278253, duration = 10, max_stack = 5 },

    -- Razorcrest of the Enraged Matriarch
    winged_tempest = { id = 278248, duration = 16, max_stack = 1 },

    -- Hurricane Heart
    hurricane_within = { id = 161416, duration = 12, max_stack = 6,
        meta = {
            -- Stacks every 2 seconds until expiration; should generalize this kind of thing...
            stacks = function ( aura )
                if aura.up then return 1 + floor( ( query_time - aura.applied ) / 2 ) end
                return 0
            end
        }
    },

    -- Kraulok's Claw
    krauloks_strength = { id = 278287, duration = 10, max_stack = 1 },

    -- Doom's Hatred
    blood_hatred = { id = 278356, duration = 10, max_stack = 1 },

    -- Lion's Grace
    lions_grace = { id = 278815, duration = 10, max_stack = 1 },

    -- Landoi's Scrutiny
    landois_scrutiny = { id = 281544, duration = 15, max_stack = 1 },

    -- Leyshock's Grand Compilation
    precision_module = { id = 281791, duration = 15, max_stack = 3 }, -- Crit.
    iteration_capacitor = { id = 281792, duration = 15, max_stack = 3 }, -- Haste.
    efficiency_widget = { id = 281794, duration = 15, max_stack = 3 }, -- Mastery.
    adaptive_circuit = { id = 281795, duration = 15, max_stack = 3 }, -- Versatility.
    leyshocks_grand_compilation = {
        alias = { "precision_module", "iteration_capacitor", "efficiency_widget", "adaptive_circuit" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 15,
    },

    -- Twitching Tentacle of Xalzaix
    lingering_power_of_xalzaix = { id = 278155, duration = 30, max_stack = 5 },
    uncontained_power = { id = 278156, duration = 12, max_stack = 1 },

    -- Surging Alchemist Stone
    -- I believe these buffs are recycled a lot...
    agility = { id = 60233, duration = 15, max_stack = 1 },
    intellect = { id = 60234, duration = 15, max_stack = 1 },
    strength = { id = 60229, duration = 15, max_stack = 1 },

    -- Harlan's Loaded Dice
    loaded_die_mastery = { id = 267325, duration = 15, max_stack = 1 },
    loaded_die_haste = { id = 267327, duration = 15, max_stack = 1 },
    loaded_die_critical_strike = { id = 267331, duration = 15, max_stack = 1 },
    loaded_die = {
        alias = { "loaded_die_mastery", "loaded_die_haste", "loaded_die_critical_strike" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 15,
    },

    -- Tiny Electromental in a Jar
    phenomenal_power = { id = 267179, duration = 30, max_stack = 12 },

    -- Rezan's Gleaming Eye
    rezans_gleaming_eye = { id = 271103, duration = 15, max_stack = 1 },

    -- Azerokk's Resonating Heart
    resonating_elemental_heart = { id = 268441, duration = 15, max_stack = 1 },

    -- Gore-Crusted Butcher's Block
    butchers_eye = { id = 271104, duration = 15, max_stack = 1 },

    -- Briny Barnacle
    choking_brine = { id = 268194, duration = 6, max_stack = 1 },

    -- Conch of Dark Whispers
    conch_of_dark_whispers = { id = 271071, duration = 15, max_stack = 1 },

    -- Dead Eye Spyglass
    dead_ahead = { id = 268756, duration = 10, max_stack = 1 },
    dead_ahead_crit = { id = 268769, duration = 10, max_stack = 5 },

    -- Lingering Sporepods
    lingering_spore_pods = { id = 268062, duration = 4, max_stack = 1 },

} )


-- BFA TRINKETS/ITEMS
-- Ny'alotha

all:RegisterAbility( "manifesto_of_madness", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 174103,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "manifesto_of_madness_chapter_one" )
    end,
} )

all:RegisterAuras( {
    manifesto_of_madness_chapter_one = {
        id = 313948,
        duration = 10,
        max_stack = 1
    },

    manifesto_of_madness_chapter_two = {
        id = 314040,
        duration = 10,
        max_stack = 1
    }
} )


all:RegisterAbility( "forbidden_obsidian_claw", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 173944,
    toggle = "cooldowns",

    handler = function ()
        applyDebuff( "target", "obsidian_claw" )
    end,
} )

all:RegisterAura( "obsidian_claw", {
    id = 313148,
    duration = 8.5,
    max_stack = 1
} )


all:RegisterAbility( "sigil_of_warding", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 173940,
    toggle = "defensives",

    handler = function ()
        applyBuff( "stoneskin", 8 )
    end,
} )

all:RegisterAura( "stoneskin", {
    id = 313060,
    duration = 16,
    max_stack = 1,
} )


all:RegisterAbility( "writhing_segment_of_drestagath", {
    cast = 0,
    cooldown = 80,
    gcd = "off",

    item = 173946,
    toggle = "cooldowns",
} )


all:RegisterAbility( "lingering_psychic_shell", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 174277,
    toggle = "defensives",

    handler = function ()
        applyBuff( "" )
    end,
} )

all:RegisterAura( "psychic_shell", {
    id = 314585,
    duration = 8,
    max_stack = 1
} )




-- Azshara's EP
all:RegisterAbility( "orgozoas_paralytic_barb", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 168899,
    toggle = "defensives",

    handler = function ()
        applyBuff( "paralytic_spines" )
    end,
} )

all:RegisterAura( "paralytic_spines", {
    id = 303350,
    duration = 15,
    max_stack = 1
} )

all:RegisterAbility( "azsharas_font_of_power", {
    cast = 4,
    channeled = true,
    cooldown = 120,
    gcd = "spell",

    item = 169314,
    toggle = "cooldowns",

    start = function ()
        applyBuff( "latent_arcana_channel" )
    end,

    breakchannel = function ()
        removeBuff( "latent_arcana_channel" )
        applyBuff( "latent_arcana" )
    end,

    finish = function ()
        removeBuff( "latent_arcana_channel" )
        applyBuff( "latent_arcana" )
    end,

    copy = { "latent_arcana" }
} )

all:RegisterAuras( {
    latent_arcana = {
        id = 296962,
        duration = 30,
        max_stack = 5
    },

    latent_arcana_channel = {
        id = 296971,
        duration = 4,
        max_stack = 1
    }
} )


all:RegisterAbility( "shiver_venom_relic", {
    cast = 0,
    cooldown = 60,
    gcd = "spell",

    item = 168905,
    toggle = "cooldowns",

    usable = function ()
        if debuff.shiver_venom.stack < 5 then return false, "shiver_venom is not at max stacks" end
        return true
    end,

    aura = "shiver_venom",
    cycle = "shiver_venom",

    handler = function()
        removeDebuff( "target", "shiver_venom" )
    end,
} )

all:RegisterAura( "shiver_venom", {
    id = 301624,
    duration = 20,
    max_stack = 5
} )


do
    -- local coralGUID, coralApplied, coralStacks = "none", 0, 0

    -- Ashvane's Razor Coral, 169311
    all:RegisterAbility( "ashvanes_razor_coral", {
        cast = 0,
        cooldown = 20,
        gcd = "off",

        item = 169311,
        toggle = "cooldowns",

        --[[ usable = function ()
            if active_dot.razor_coral > 0 and target.unit ~= coralGUID then
                return false, "current target does not have razor_coral applied"
            end
            return true
        end, ]]

        handler = function ()
            if active_dot.razor_coral > 0 then
                removeDebuff( "target", "razor_coral" )
                active_dot.razor_coral = 0

                applyBuff( "razor_coral_crit" )
                setCooldown( "ashvanes_razor_coral", 20 )
            else
                applyDebuff( "target", "razor_coral" )
            end
        end
    } )


    --[[
    local HandleRazorCoral = function( event )
        if not state.equipped.ashvanes_razor_coral then return end

        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

            if sourceGUID == state.GUID and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
                if spellID == 303568 and destGUID then
                    coralGUID = destGUID
                    coralApplied = GetTime()
                    coralStacks = ( subtype == "SPELL_AURA_APPLIED_DOSE" ) and ( coralStacks + 1 ) or 1
                elseif spellID == 303570 then
                    -- Coral was removed.
                    coralGUID = "none"
                    coralApplied = 0
                    coralStacks = 0
                end
            end
        else
            coralGUID = "none"
            coralApplied = 0
            coralStacks = 0
        end
    end

    RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", HandleRazorCoral )
    RegisterEvent( "PLAYER_REGEN_ENABLED", HandleRazorCoral )

    all:RegisterStateExpr( "coral_time_to_30", function()
        if coralGUID == 0 then return 3600 end
        return Hekili:GetTimeToPctByGUID( coralGUID, 30 ) - ( offset + delay )
    end ) ]]

    all:RegisterAuras( {
        razor_coral = {
            id = 303568,
            duration = 120,
            max_stack = 100, -- ???
            copy = "razor_coral_debuff",
            generate = function( t, auraType )
                local name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = FindUnitDebuffByID( "target", 303568, "PLAYER" )

                if name then
                    -- It's on our actual target, trust it.
                    t.name = name
                    t.count = count > 0 and count or 1
                    t.expires = expirationTime
                    t.applied = expirationTime - duration
                    t.caster = "player"
                    return

                --[[ elseif coralGUID ~= "none" then
                    t.name = class.auras.razor_coral.name
                    t.count = coralStacks > 0 and coralStacks or 1
                    t.applied = coralApplied > 0 and coralApplied or state.query_time
                    t.expires = coralApplied > 0 and ( coralApplied + 120 ) or ( state.query_time + Hekili:GetDeathClockByGUID( coralGUID ) )
                    t.caster = "player"

                    return ]]
                end

                t.name = class.auras.razor_coral.name
                t.count = 0
                t.applied = 0
                t.expires = 0

                t.caster = "nobody"
            end,
        },

        razor_coral_crit = {
            id = 303570,
            duration = 20,
            max_stack = 1,
        }
    } )
end

-- Dribbling Inkpod
all:RegisterAura( "conductive_ink", {
    id = 302565,
    duration = 60,
    max_stack = 999, -- ???
    copy = "conductive_ink_debuff"
} )


-- Edicts of the Faithless, 169315

-- Vision of Demise, 169307
all:RegisterAbility( "vision_of_demise", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 169307,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "vision_of_demise" )
    end
} )

all:RegisterAura( "vision_of_demise", {
    id = 303431,
    duration = 10,
    max_stack = 1
} )


-- Aquipotent Nautilus, 169305
all:RegisterAbility( "aquipotent_nautilus", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 169305,
    toggle = "cooldowns",

    handler = function ()
        applyDebuff( "target", "surging_flood" )
    end
} )

all:RegisterAura( "surging_flood", {
    id = 302580,
    duration = 4,
    max_stack = 1
} )


-- Chain of Suffering, 169308
all:RegisterAbility( "chain_of_suffering", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 169308,
    toggle = "defensives",

    handler = function ()
        applyBuff( "chain_of_suffering" )
    end,
} )

all:RegisterAura( "chain_of_suffering", {
    id = 297036,
    duration = 25,
    max_stack = 1
} )


-- Mechagon
do
    all:RegisterGear( "pocketsized_computation_device", 167555 )
    all:RegisterGear( "cyclotronic_blast", 167672 )
    all:RegisterGear( "harmonic_dematerializer", 167677 )

    all:RegisterAura( "cyclotronic_blast", {
        id = 293491,
        duration = function () return 2.5 * haste end,
        max_stack = 1
    } )

    --[[ all:RegisterAbility( "pocketsized_computation_device", {
        -- key = "pocketsized_computation_device",
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        -- item = 167555,
        texture = 2115322,
        bind = { "cyclotronic_blast", "harmonic_dematerializer", "inactive_red_punchcard" },
        startsCombat = true,

        unlisted = true,

        usable = function() return false, "no supported red punchcard installed" end,
        copy = "inactive_red_punchcard"
    } ) ]]

    all:RegisterAbility( "cyclotronic_blast", {
        id = 293491,
        known = function () return equipped.cyclotronic_blast end,
        cast = function () return 1.5 * haste end,
        channeled = function () return cooldown.cyclotronic_blast.remains > 0 end,
        cooldown = function () return equipped.cyclotronic_blast and 120 or 0 end,
        gcd = "spell",

        item = 167672,
        itemCd = 167555,
        itemKey = "cyclotronic_blast",

        texture = 2115322,
        bind = { "pocketsized_computation_device", "inactive_red_punchcard", "harmonic_dematerializer" },
        startsCombat = true,

        toggle = "cooldowns",

        usable = function ()
            return equipped.cyclotronic_blast, "punchcard not equipped"
        end,

        handler = function()
            setCooldown( "global_cooldown", 2.5 * haste )
            applyBuff( "casting", 2.5 * haste )
        end,

        copy = "pocketsized_computation_device"
    } )

    all:RegisterAura( "harmonic_dematerializer", {
        id = 293512,
        duration = 300,
        max_stack = 99
    } )

    all:RegisterAbility( "harmonic_dematerializer", {
        id = 293512,
        known = function () return equipped.harmonic_dematerializer end,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        item = 167677,
        itemCd = 167555,
        itemKey = "harmonic_dematerializer",

        texture = 2115322,

        bind = { "pocketsized_computation_device", "cyclotronic_blast", "inactive_red_punchcard" },

        startsCombat = true,

        usable = function ()
            return equipped.harmonic_dematerializer, "punchcard not equipped"
        end,

        handler = function ()
            addStack( "harmonic_dematerializer", nil, 1 )
        end
    } )


    -- Hyperthread Wristwraps
    all:RegisterAbility( "hyperthread_wristwraps", {
        id = 300142,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        handler = function ()
            -- Gain 5 seconds of CD for the last 3 spells.
            for i = 1, 3 do
                local ability = prev[i].spell

                if ability and ability ~= "no_action" then
                    gainChargeTime( ability, 5 )
                end
            end
        end,

        copy = "hyperthread_wristwraps_300142"
    } )

    local hyperthread_blocks = {
        berserking      = true,
        arcane_torrent  = true,
        blood_fury      = true,
        shadowmeld      = true,
        stoneform       = true,
        darkflight      = true,
        rocket_barrage  = true,
        lights_judgment = true,
        arcane_pulse    = true,
        fireblood       = true,
        ancestral_call  = true,
        haymaker        = true,
        bag_of_tricks   = true
    }


    local first_remains = setmetatable( {}, {
        __index = function( t, k )
            if hyperthread_blocks[ k ] then return 0 end

            local slot = 0
            local counted = 0
            for i = 1, 10 do
                if not hyperthread_blocks[ state.prev[ i ].spell ] then
                    counted = counted + 1
                end

                if counted == 4 then break end

                if state.prev[ i ].spell == k then
                    slot = i
                end
            end

            if slot > 0 then return 3 - slot end
            return 0
        end
    } )

    all:RegisterStateTable( "hyperthread_wristwraps", setmetatable( {
    }, {
        __index = function( t, k )
            if type( k ) == "string" then
                if k == "first_remains" then return first_remains end
                if k == "count" then return state.hyperthread_wristwraps end

                if hyperthread_blocks[ k ] then return 0 end

                local count = 0
                local counted = 0
                for i = 1, 10 do
                    if not hyperthread_blocks[ state.sprev[ i ].spell ] then
                        counted = counted + 1
                    end

                    if counted == 4 then break end

                    if state.prev[ i ].spell == k then
                        count = count + 1
                    end
                end

                return count
            end
        end,
    } ) )


    all:RegisterAbility( "neural_synapse_enhancer", {
        cast = 0,
        cooldown = 45,
        gcd = "off",

        item = 168973,

        handler = function ()
            applyBuff( "enhance_synapses" )
        end,

        copy = "enhance_synapses_300612"
    } )

    all:RegisterAura( "enhance_synapses", {
        id = 300612,
        duration = 15,
        max_stack = 1
    } )

    all:RegisterAbility( "wraps_of_electrostatic_potential", {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        item = 169069,

        handler = function()
            applyDebuff( "target", "electrostatic_induction" )
        end,

        auras = {
            electrostatic_induction = {
                id = 300145,
                duration = 8,
                max_stack = 1
            }
        }
    } )
end


-- Shockbiter's Fang
all:RegisterAbility( "shockbiters_fang", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 169318,
    toggle = "cooldowns",

    handler = function () applyBuff( "shockbitten" ) end
} )

all:RegisterAura( "shockbitten", {
    id = 303953,
    duration = 12,
    max_stack = 1
} )


all:RegisterAbility( "living_oil_canister", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 158216,

    copy = "living_oil_cannister"
} )


-- Remote Guidance Device, 169769
all:RegisterAbility( "remote_guidance_device", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 169769,
    toggle = "cooldowns",
} )


-- Modular Platinum Plating, 168965
all:RegisterAbility( "modular_platinum_plating", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 168965,
    toggle = "defensives",

    handler = function ()
        applyBuff( "platinum_plating", nil, 4 )
    end
} )

all:RegisterAura( "platinum_plating", {
    id = 299869,
    duration = 30,
    max_stack = 4
} )


-- Crucible
all:RegisterAbility( "pillar_of_the_drowned_cabal", {
    cast = 0,
    cooldown = 30,
    gcd = "spell", -- ???

    item = 167863,
    toggle = "defensives", -- ???

    handler = function () applyBuff( "mariners_ward" ) end
} )

all:RegisterAura( "mariners_ward", {
    id = 295411,
    duration = 90,
    max_stack = 1,
} )


-- Abyssal Speaker's Guantlets (PROC)
all:RegisterAura( "ephemeral_vigor", {
    id = 295431,
    duration = 60,
    max_stack = 1
} )


-- Fathom Dredgers (PROC)
all:RegisterAura( "dredged_vitality", {
    id = 295134,
    duration = 8,
    max_stack = 1
} )


-- Gloves of the Undying Pact
all:RegisterAbility( "gloves_of_the_undying_pact", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 167219,
    toggle = "defensives", -- ???

    handler = function() applyBuff( "undying_pact" ) end
} )

all:RegisterAura( "undying_pact", {
    id = 295193,
    duration = 6,
    max_stack = 1
} )


-- Insurgent's Scouring Chain (PROC)
all:RegisterAura( "scouring_wake", {
    id = 295141,
    duration = 20,
    max_stack = 1
} )


-- Mindthief's Eldritch Clasp (PROC)
all:RegisterAura( "phantom_pain", {
    id = 295527,
    duration = 180,
    max_stack = 1,
} )


-- Leggings of the Aberrant Tidesage
-- HoT spell ID not found.

-- Zaxasj's Deepstriders (EFFECT)
all:RegisterAura( "deepstrider", {
    id = 295167,
    duration = 3600,
    max_stack = 1
} )


-- Trident of Deep Ocean
-- Custody of the Deep (shield proc)
all:RegisterAura( "custody_of_the_deep_shield", {
    id = 292675,
    duration = 40,
    max_stack = 1
} )
-- Custody of the Deep (mainstat proc)
all:RegisterAura( "custody_of_the_deep_buff", {
    id = 292653,
    duration = 60,
    max_stack = 3
} )


-- Malformed Herald's Legwraps
all:RegisterAbility( "malformed_heralds_legwraps", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 167835,
    toggle = "cooldowns",

    usable = function () return buff.movement.down end,
    handler = function () applyBuff( "void_embrace" ) end,
} )

all:RegisterAura( "void_embrace", {
    id = 295174,
    duration = 12,
    max_stack = 1,
} )


-- Idol of Indiscriminate Consumption
all:RegisterAbility( "idol_of_indiscriminate_consumption", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 167868,
    toggle = "cooldowns",

    handler = function() gain( 2.5 * 7000 * active_enemies, "health" ) end,
} )


-- Lurker's Insidious Gift
all:RegisterAbility( "lurkers_insidious_gift", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 167866,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "insidious_gift" )
        applyDebuff( "suffering" )
    end
} )

all:RegisterAura( "insidious_gift", {
    id = 295408,
    duration = 30,
    max_stack = 1
} )
all:RegisterAura( "suffering", {
    id = 295413,
    duration = 30,
    max_stack = 30,
    meta = {
        stack = function ()
            return buff.insidious_gift.up and floor( 30 - buff.insidious_gift.remains ) or 0
        end
    }
} )


-- Void Stone
all:RegisterAbility( "void_stone", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 167865,
    toggle = "defensives",

    handler = function ()
        applyBuff( "umbral_shell" )
    end,
} )

all:RegisterAura( "umbral_shell", {
    id = 295271,
    duration = 12,
    max_stack = 1
} )


-- ON USE
-- Kezan Stamped Bijou
all:RegisterAbility( "kezan_stamped_bijou", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 165662,
    toggle = "cooldowns",

    handler = function () applyBuff( "kajamite_surge" ) end
} )

all:RegisterAura( "kajamite_surge", {
    id = 285475,
    duration = 12,
    max_stack = 1,
} )


-- Sea Giant's Tidestone
all:RegisterAbility( "sea_giants_tidestone", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 165664,
    toggle = "cooldowns",

    handler = function () applyBuff( "ferocity_of_the_skrog" ) end
} )

all:RegisterAura( "ferocity_of_the_skrog", {
    id = 285482,
    duration = 12,
    max_stack = 1
} )


-- Ritual Feather
all:RegisterAbility( "ritual_feather_of_unng_ak", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 165665,
    toggle = "cooldowns",

    handler = function () applyBuff( "might_of_the_blackpaw" ) end
} )

all:RegisterAura( "might_of_the_blackpaw", {
    id = 285489,
    duration = 16,
    max_stack = 1
} )


-- Battle of Dazar'alor
all:RegisterAbility( "invocation_of_yulon", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 165568,
    toggle = "cooldowns",
} )


all:RegisterAbility( "ward_of_envelopment", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 165569,
    toggle = "defensives",

    handler = function() applyBuff( "enveloping_protection" ) end
} )

all:RegisterAura( "enveloping_protection", {
    id = 287568,
    duration = 10,
    max_stack = 1
} )


-- Everchill Anchor debuff.
all:RegisterAura( "everchill", {
    id = 289525,
    duration = 12,
    max_stack = 10
} )


-- Incandescent Sliver
all:RegisterAura( "incandescent_luster", {
    id = 289523,
    duration = 20,
    max_stack = 10
} )

all:RegisterAura( "incandescent_mastery", {
    id = 289524,
    duration = 20,
    max_stack = 1
} )



all:RegisterAbility( "variable_intensity_gigavolt_oscillating_reactor", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 165572,
    toggle = "cooldowns",

    buff = "vigor_engaged",
    usable = function ()
        if buff.vigor_engaged.stack < 6 then return false, "has fewer than 6 stacks" end
        return true
    end,
    handler = function() applyBuff( "oscillating_overload" ) end
} )

all:RegisterAura( "vigor_engaged", {
    id = 287916,
    duration = 3600,
    max_stack = 6
    -- May need to emulate the stacking portion.
} )

all:RegisterAura( "vigor_cooldown", {
    id = 287967,
    duration = 6,
    max_stack = 1
} )

all:RegisterAura( "oscillating_overload", {
    id = 287917,
    duration = 6,
    max_stack = 1
} )


-- Diamond-Laced Refracting Prism
all:RegisterAura( "diamond_barrier", {
    id = 288034,
    duration = 10,
    max_stack = 1
} )


all:RegisterAbility( "grongs_primal_rage", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 165574,
    toggle = "cooldowns",

    handler = function()
        applyBuff( "primal_rage" )
        setCooldown( "global_cooldown", 4 )
    end
} )

-- XXX This aura name conflicts with primal_rage that is the same as bloodlust.
-- XXX Possibly rename this to grongs_primal_rage.
all:RegisterAura( "primal_rage", {
    id = 288267,
    duration = 4,
    max_stack = 1
} )


all:RegisterAbility( "tidestorm_codex", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 165576,
    toggle = "cooldowns",
} )


-- Bwonsamdi's Bargain
all:RegisterAura( "bwonsamdis_due", {
    id = 288193,
    duration = 300,
    max_stack = 1
} )

all:RegisterAura( "bwonsamdis_bargain_fulfilled", {
    id = 288194,
    duration = 360,
    max_stack = 1
} )


all:RegisterAbility( "mirror_of_entwined_fate", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 165578,
    toggle = "defensives",

    handler = function() applyDebuff( "player", "mirror_of_entwined_fate" ) end
} )

all:RegisterAura( "mirror_of_entwined_fate", {
    id = 287999,
    duration = 30,
    max_stack = 1
} )


-- Kimbul's Razor Claw
all:RegisterAura( "kimbuls_razor_claw", {
    id = 288330,
    duration = 6,
    tick_time = 2,
    max_stack = 1
} )


all:RegisterAbility( "ramping_amplitude_gigavolt_engine", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 165580,
    toggle = "cooldowns",

    handler = function() applyBuff( "r_a_g_e" ) end
} )

all:RegisterAura( "rage", {
    id = 288156,
    duration = 18,
    max_stack = 15,
    copy = "r_a_g_e"
} )


-- Crest of Pa'ku
all:RegisterAura( "gift_of_wind", {
    id = 288304,
    duration = 15,
    max_stack = 1
} )


all:RegisterAbility( "endless_tincture_of_fractional_power", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 152636,

    toggle = "cooldowns",

    handler = function ()
        -- I don't know the auras it applies...
    end
} )


all:RegisterAbility( "mercys_psalter", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 155564,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "potency" )
    end,
} )

all:RegisterAura( "potency", {
    id = 268523,
    duration = 15,
    max_stack = 1,
} )


all:RegisterAbility( "clockwork_resharpener", {
    cast = 0,
    cooldown = 60, -- no CD reported in-game yet.
    gcd = "off",

    item = 161375,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "resharpened" )
    end,
} )

all:RegisterAura( "resharpened", {
    id = 278376,
    duration = 14,
    max_stack = 7,
    meta = {
        -- Stacks every 2 seconds until expiration; should generalize this kind of thing...
        stacks = function ( aura )
            if aura.up then return 1 + floor( ( query_time - aura.applied ) / 2 ) end
            return 0
        end
    }
} )


all:RegisterAbility( "azurethos_singed_plumage", {
    cast = 0,
    cooldown = 88,
    gcd = "off",

    item = 161377,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "ruffling_tempest" )
    end,
} )

all:RegisterAura( "ruffling_tempest", {
    id = 278383,
    duration = 15,
    max_stack = 1,
    -- Actually decrements but doesn't appear to use stacks to implement itself.
} )


all:RegisterAbility( "galecallers_beak", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 161379,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "gale_call" )
    end,
} )

all:RegisterAura( "gale_call", {
    id = 278385,
    duration = 15,
    max_stack = 1,
} )


all:RegisterAbility( "sublimating_iceshard", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 161382,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "sublimating_power" )
    end,
} )

all:RegisterAura( "sublimating_power", {
    id = 278869,
    duration = 14,
    max_stack = 1,
    -- Decrements after 6 sec but doesn't appear to use stacks to convey this...
} )


all:RegisterAbility( "tzanes_barkspines", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 161411,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "barkspines" )
    end,
} )

all:RegisterAura( "barkspines", {
    id = 278227,
    duration = 10,
    max_stack = 1,
} )


--[[ Redundant Ancient Knot of Wisdom???
all:RegisterAbility( "sandscoured_idol", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 161417,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "secrets_of_the_sands" )
    end,
} )

all:RegisterAura( "secrets_of_the_sands", {
    id = 278267,
    duration = 20,
    max_stack = 1,
} ) ]]


all:RegisterAbility( "deployable_vibro_enhancer", {
    cast = 0,
    cooldown = 105,
    gcd = "off",

    item = 161418,

    toggle = "cooldowns",

    handler = function ()
        applyBuff( "vibro_enhanced" )
    end,
} )

all:RegisterAura( "vibro_enhanced", {
    id = 278260,
    duration = 12,
    max_stack = 4,
    meta = {
        -- Stacks every 2 seconds until expiration; should generalize this kind of thing...
        stacks = function ( aura )
            if aura.up then return 1 + floor( ( query_time - aura.applied ) / 3 ) end
            return 0
        end
    }
} )


all:RegisterAbility( "dooms_wake", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 161462,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "dooms_wake" )
    end,
} )

all:RegisterAura( "dooms_wake", {
    id = 278317,
    duration = 16,
    max_stack = 1
} )


all:RegisterAbility( "dooms_fury", {
    cast = 0,
    cooldown = 105,
    gcd = "off",

    item = 161463,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "bristling_fury" )
    end,
} )

all:RegisterAura( "bristling_fury", {
    id = 278364,
    duration = 18,
    max_stack = 1,
} )


all:RegisterAbility( "lions_guile", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 161473,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "lions_guile" )
    end,
} )

all:RegisterAura( "lions_guile", {
    id = 278806,
    duration = 16,
    max_stack = 10,
    meta = {
        stack = function( t ) return t.down and 0 or min( 6, 1 + ( ( query_time - t.app ) / 2 ) ) end,
    }
} )


all:RegisterAbility( "lions_strength", {
    cast = 0,
    cooldown = 105,
    gcd = "off",

    item = 161474,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "lions_strength" )
    end,
} )

all:RegisterAura( "lions_strength", {
    id = 278819,
    duration = 18,
    max_stack = 1,
} )

all:RegisterAbility( "mr_munchykins", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 155567,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "tea_time" )
    end,
} )

all:RegisterAura( "tea_time", {
    id = 268504,
    duration = 15,
    max_stack = 1,
} )

all:RegisterAbility( "bygone_bee_almanac", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 163936,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "process_improvement" )
    end,
} )

all:RegisterAura( "process_improvement", {
    id = 281543,
    duration = 12,
    max_stack = 1,
} ) -- extends on spending resources, could hook here...


all:RegisterAbility( "mydas_talisman", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 158319,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "touch_of_gold" )
    end,
} )

all:RegisterAura( "touch_of_gold", {
    id = 265954,
    duration = 20,
    max_stack = 1,
} )


all:RegisterAbility( "merekthas_fang", {
    cast = 3,
    channeled = true,
    cooldown = 120,
    gcd = "off",

    item = 158367,
    toggle = "cooldowns",

    -- not sure if this debuffs during the channel...
} )


all:RegisterAbility( "razdunks_big_red_button", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 159611,
    toggle = "cooldowns",

    velocity = 10,
} )


all:RegisterAbility( "galecallers_boon", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 159614,
    toggle = "cooldowns",

    usable = function () return buff.movement.down end,
    handler = function ()
        applyBuff( "galecallers_boon" )
    end,
} )

all:RegisterAura( "galecallers_boon", {
    id = 268311,
    duration = 10,
    max_stack = 1,
    meta = {
        expires = function( t ) return max( 0, action.galecallers_boon.lastCast + 10 ) end
    }
} )


all:RegisterAbility( "ignition_mages_fuse", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 159615,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "ignition_mages_fuse" )
    end,
} )

all:RegisterAura( "ignition_mages_fuse", {
    id = 271115,
    duration = 20,
    max_stack = 1,
} )


all:RegisterAbility( "lustrous_golden_plumage", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 159617,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "golden_luster" )
    end,
} )

all:RegisterAura( "golden_luster", {
    id = 271107,
    duration = 20,
    max_stack = 1,
} )


all:RegisterAbility( "mchimbas_ritual_bandages", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 159618,
    toggle = "defensives",

    handler = function ()
        applyBuff( "ritual_wraps" )
    end,
} )

all:RegisterAura( "ritual_wraps", {
    id = 265946,
    duration = 6,
    max_stack = 1,
} )


all:RegisterAbility( "rotcrusted_voodoo_doll", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 159624,
    toggle = "cooldowns",

    handler = function ()
        applyDebuff( "target", "rotcrusted_voodoo_doll" )
    end,
} )

all:RegisterAura( "rotcrusted_voodoo_doll", {
    id = 271465,
    duration = 6,
    max_stack = 1,
} )


all:RegisterAbility( "vial_of_animated_blood", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 159625,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "blood_of_my_enemies" )
    end,
} )

all:RegisterAura( "blood_of_my_enemies", {
    id = 268836,
    duration = 18,
    max_stack = 1,
} )


all:RegisterAbility( "jes_howler", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 159627,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "motivating_howl" )
    end,
} )

all:RegisterAura( "motivating_howl", {
    id = 266047,
    duration = 12,
    max_stack = 1,
} )


all:RegisterAbility( "balefire_branch", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 159630,
    toggle = "cooldowns",
    proc = "intellect",

    handler = function ()
        applyBuff( "kindled_soul" )
    end,
} )

all:RegisterAura( "kindled_soul", {
    id = 268998,
    duration = 20,
    max_stack = 1,
} )


all:RegisterAbility( "sanguinating_totem", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 160753,
    toggle = "defensives",
} )


all:RegisterAbility( "fetish_of_the_tormented_mind", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 160833,
    toggle = "defensives",

    handler = function ()
        applyDebuff( "target", "doubting_mind" )
    end,
} )

all:RegisterAura( "doubting_mind", {
    id = 273559,
    duration = 5,
    max_stack = 1
} )


all:RegisterAbility( "whirlwings_plumage", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 158215,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "gryphons_pride" )
    end,
} )

all:RegisterAura( "gryphons_pride", {
    id = 268550,
    duration = 20,
    max_stack = 1,
} )


-- Galewind Chimes
all:RegisterAura( "galewind_chimes", {
    id = 268518,
    duration = 8,
    max_stack = 1,
} )

-- Gilded Loa Figurine
all:RegisterAura( "will_of_the_loa", {
    id = 273974,
    duration = 10,
    max_stack = 1,
} )

-- Emblem of Zandalar
all:RegisterAura( "speed_of_the_spirits", {
    id = 273992,
    duration = 8,
    max_stack = 1,
} )

-- Dinobone Charm
all:RegisterAura( "primal_instinct", {
    id = 273988,
    duration = 7,
    max_stack = 1
} )


all:RegisterAbility( "pearl_divers_compass", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 158162,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "true_north" )
    end,
} )

all:RegisterAura( "true_north", {
    id = 273935,
    duration = 12,
    max_stack = 1,
} )


all:RegisterAbility( "first_mates_spyglass", {
    cast = 0,
    cooldown = 120,
    gcd = "off",

    item = 158163,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "spyglass_sight" )
    end,
} )

all:RegisterAura( "spyglass_sight", {
    id = 273955,
    duration = 15,
    max_stack = 1
} )


all:RegisterAbility( "plunderbeards_flask", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 158164,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "bolstered_spirits" )
    end,
} )

all:RegisterAura( "bolstered_spirits", {
    id = 273942,
    duration = 10,
    max_stack = 10,
} )


all:RegisterAura( "sound_barrier", {
    id = 268531,
    duration = 8,
    max_stack = 1,
} )


all:RegisterAbility( "vial_of_storms", {
    cast = 0,
    cooldown = 90,
    gcd = "off",

    item = 158224,
    toggle = "cooldowns",
} )


all:RegisterAura( "sirens_melody", {
    id = 268512,
    duration = 6,
    max_stack = 1,
} )


all:RegisterAura( "tick", {
    id = 274430,
    duration = 6,
    max_stack = 1,
} )

all:RegisterAura( "tock", {
    id = 274431,
    duration = 6,
    max_stack = 1,
} )

all:RegisterAura( "soulguard", {
    id = 274459,
    duration = 12,
    max_stack = 1,
} )


all:RegisterAbility( "berserkers_juju", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 161117,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "berserkers_frenzy" )
    end,
} )

all:RegisterAura( "berserkers_frenzy", {
    id = 274472,
    duration = 10,
    max_stack = 1,
} )


all:RegisterGear( "ancient_knot_of_wisdom", 161417, 166793 )

all:RegisterAbility( "ancient_knot_of_wisdom", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = function ()
        if equipped[161417] then return 161417 end
        return 166793
    end,
    items = { 167417, 166793 },
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "wisdom_of_the_forest_lord" )
    end,
} )

all:RegisterAura( "wisdom_of_the_forest_lord", {
    id = 278267,
    duration = 20,
    max_stack = 5
} )


all:RegisterAbility( "knot_of_ancient_fury", {
    cast = 0,
    cooldown = 60,
    gcd = "off",

    item = 166795,
    toggle = "cooldowns",

    handler = function ()
        applyBuff( "fury_of_the_forest_lord" )
    end,
} )

all:RegisterAura( "fury_of_the_forest_lord", {
    id = 278231,
    duration = 12,
    max_stack = 1
} )
