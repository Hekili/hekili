local addon, ns = ...
local Hekili = _G[ addon ]

if not Hekili.IsWrath() then return end

local class, state = Hekili.Class, Hekili.State

local RegisterEvent = ns.RegisterEvent

function ns.updateTalents()
    for _, tal in pairs( state.talent ) do
        tal.enabled = false
        tal.rank = 0
    end

    for k, v in pairs( class.talents ) do
        local maxRank = v[ 2 ]

        local talent = rawget( state.talent, k ) or {}
        talent.enabled = false
        talent.rank = 0

        for i = #v, 3, -1 do
            local spell = v[i]
            local ability = class.abilities[ spell ]

            if ability then
                -- This is a talent, but it could also be an ability with multiple ranks.
                local spellID = select( 7, GetSpellInfo( ability.name ) ) or spell
                if IsPlayerSpell( spellID ) then
                    talent.enabled = true
                    talent.rank = i - 2
                    break
                end
            elseif IsPlayerSpell( spell ) then
                talent.enabled = true
                talent.rank = i - 2
                break
            end
        end

        state.talent[ k ] = talent
    end

    local spec = state.spec.id or select( 3, UnitClass( "player" ) )
    if not Hekili.DB.profile.specs[ spec ].usePackSelector then return end

    -- Swap priorities if needed.
    local tab1 = select( 3, GetTalentTabInfo(1) )
    local tab2 = select( 3, GetTalentTabInfo(2) )
    local tab3 = select( 3, GetTalentTabInfo(3) )

    local fromPackage = Hekili.DB.profile.specs[ spec ].package

    for _, selector in ipairs( class.specs[ spec ].packSelectors ) do
        local toPackage = Hekili.DB.profile.specs[ state.spec.id ].autoPacks[ selector.key ] or "none"

        if not rawget( Hekili.DB.profile.packs, toPackage ) then toPackage = "none" end

        if type( selector.condition ) == "function" and selector.condition( tab1, tab2, tab3 ) or
            type( selector.condition ) == "number" and
                ( selector.condition == 1 and tab1 > max( tab2, tab3 ) or
                  selector.condition == 2 and tab2 > max( tab1, tab3 ) or
                  selector.condition == 3 and tab3 > max( tab1, tab2 ) ) then

            if toPackage ~= "none" and fromPackage ~= toPackage then
                Hekili.DB.profile.specs[ spec ].package = toPackage
                C_Timer.After( Hekili.PLAYER_ENTERING_WORLD and 0 or 5, function() Hekili:Notify( toPackage .. " priority activated." ) end )
            end
            break
        end
    end
end


local HekiliSpecMixin = ns.HekiliSpecMixin

function HekiliSpecMixin:RegisterGlyphs( glyphs )
    for id, name in pairs( glyphs ) do
        self.glyphs[ id ] = name
    end
end


function ns.updateGlyphs()
    for _, glyph in pairs( state.glyph ) do
        glyph.rank = 0
    end

    for i = 1, 6 do
        local enabled, rank, spellID = GetGlyphSocketInfo( i )

        if enabled and spellID then
            local name = class.glyphs[ spellID ]

            if name then
                local glyph = rawget( state.glyph, name ) or {}
                glyph.rank = rank
                state.glyph[ name ] = glyph
            end
        end
    end
end

RegisterEvent( "GLYPH_ADDED", ns.updateGlyphs )
RegisterEvent( "GLYPH_REMOVED", ns.updateGlyphs )
RegisterEvent( "GLYPH_UPDATED", ns.updateGlyphs )
RegisterEvent( "USE_GLYPH", ns.updateGlyphs )
RegisterEvent( "PLAYER_LEVEL_UP", ns.updateGlyphs )
RegisterEvent( "PLAYER_ENTERING_WORLD", ns.updateGlyphs )


all = class.specs[ 0 ]


all:RegisterAuras({
    -- Phase 4
    -- Death's Verdict/Choice Buffs
    paragon_str = {
        id = 67708,
        duration = 15,
        max_stack = 1,
        copy = {67708, 67773}
    },
    paragon_agi = {
        id = 67703,
        duration = 15,
        max_stack = 1,
        copy = {67703, 67772}
    },
    -- When you deal damage you have a chance to gain Paragon, increasing your Strength or Agility by 450/510 for 15 sec.  Your highest stat is always chosen.
    paragon = {
        --id = 67771,
        alias = { "paragon_agi", "paragon_str" },
        aliasMode = "latest",
        aliasType = "buff",        
    },
    
    -- DBW Buffs
    aim_of_the_iron_dwarves = {
        -- crit: DK, Hunter, Paladin
        id = 71491,
        duration = 30,
        copy= {71491,71559},
    },
    agility_of_the_vrykul = {
        -- agi: Druid, Hunter, Rogue, Shaman
        id = 71485,
        duration = 30,
        copy= {71485,71556},
    },
    power_of_the_taunka = {
        -- ap: Hunter, Rogue, Shaman
        id = 71486,
        duration = 30,
        copy= {71486,71558},
    },
    precision_of_the_iron_dwarves = {
        -- arp: Rogue, Shaman, Warrior
        id = 71487,
        duration = 30,
        copy= {71487,71557},
    },
    speed_of_the_vrykul = {
        -- haste: DK, Druid, Paladin
        id = 71492,
        duration = 30,
        copy= {71492,71560},
    },
    strength_of_the_taunka = {
        -- str: DK, Paladin, Warrior
        id = 71484,
        duration = 30,
        copy= {71484,71561},
    },
    -- Your attacks have a chance to awaken the powers of the races of Northrend, temporarily transforming you and increasing your combat capabilities for 30 sec.
    deathbringers_will = {
        alias = {"aim_of_the_iron_dwarves", "agility_of_the_vrykul", "power_of_the_taunka", "precision_of_the_iron_dwarves", "speed_of_the_vrykul", "strength_of_the_taunka"},
        aliasMode = "latest",
        aliasType = "buff",
    },


})

all:RegisterAbilities( {
    -- Phase 4

    abracadaver = {
        cast = 0,
        cooldown = 900,
        gcd = "off",

        items = { 51887, 50966 },
        item = function()
            if equipped[ 51887 ] then return 51887 end
            return 50966
        end,

        toggle = "cooldowns",
    },

    bauble_of_true_blood = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        items = { 50726, 50354},
        item = function()
            if equipped[ 50726 ] then return 50726 end
            return 50354
        end,
    },

    corroded_skeleton_key = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 50356,

        handler = function()
            applyBuff( "hardened_skin" )
        end,

        auras = {
            hardened_skin = {
                id = 71586,
                duration = 10,
                max_stack = 1
            }
        }
    },
    deathbringers_will = {
        cast = 0,
        cooldown = 105,
        gcd = "off",
        unlisted = true,

        items = {50362, 50363},
        item = function()
            if equipped[ 50362 ] then return 50362 end
            return 50363
        end,

        handler = function()
            applyBuff( "deathbringers_will" )
        end,

        aura = "deathbringers_will",

    },

    deaths_verdict = {
        cast = 0,
        cooldown = 45,
        gcd = "off",
        unlisted = true,

        items = {47115, 47131},
        item = function()
            if equipped[ 47115 ] then return 47115 end
            return 47131
        end,

        handler = function()
            if stat.strength >= stat.agility then 
                applyBuff( "paragon_str" )
            else
                applyBuff( "paragon_agi" )
            end
        end,

        aura = "paragon",

    },

    deaths_choice = {
        cast = 0,
        cooldown = 45,
        gcd = "off",
        unlisted = true,

        items = {47303, 47464},
        item = function()
            if equipped[ 47303 ] then return 47303 end
            return 47464
        end,


        handler = function()
            if stat.strength >= stat.agility then 
                applyBuff( "paragon_str" )
            else
                applyBuff( "paragon_agi" )
            end
        end,

        aura = "paragon",

    },

    ephemeral_snowflake = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 50260,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "urgency" )
        end,

        auras = {
            urgency = {
                id = 71586,
                duration = 20,
                max_stack = 1
            }
        }
    },

    icks_rotting_thumb = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 50235,
        toggle = "defensives",

        handler = function()
            applyBuff( "increased_fortitude" )
        end,

        auras = {
            increased_fortitude = {
                id = 71569,
                duration = 15,
                max_stack = 1
            }
        }
    },

    maghias_misguided_quill = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 50357,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "elusive_power" )
        end,

        auras = {
            elusive_power = {
                id = 71579,
                duration = 20,
                max_stack = 1
            }
        }
    },

    medallion_of_the_alliance = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 51377,
        toggle = "defensives"
    },

    medallion_of_the_horde = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 51378,
        toggle = "defensives",
    },

    nevermelting_ice_crystal = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 50259,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "deadly_precision", nil, 5 )
        end,

        auras = {
            deadly_precision = {
                id = 71563,
                duration = 20,
                max_stack = 5
            }
        }
    },

    sindragosas_flawless_fang = {
        cast = 0,
        cooldown = 60,
        gcd = "off",

        items = { 50364, 50361 },
        item = function()
            if equipped[ 50364 ] then return 50364 end
            return 50361
        end,
        toggle = "defensives",

        handler = function()
            applyBuff( "aegis_of_dalaran" )
        end,

        auras = {
            aegis_of_dalaran = {
                id = 71638,
                duration = 10,
                max_stack = 1,
                copy = 71635
            }
        }
    },

    sliver_of_pure_ice = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        items = { 50346, 50339 },
        item = function()
            if equipped[ 50346 ] then return 50346 end
            return 50339
        end,
        toggle = "cooldowns",

        usable = function()
            local restores = equipped[ 50346 ] and 1830 or 1625
            return mana.deficit > restores, "mana deficit should exceed " .. restores .. " before using"
        end,

        handler = function()
            gain( equipped[ 50346 ] and 1830 or 1625, "mana" )
        end,
    },

    -- Phase 3

    antediluvian_cornerstone_grimoire = {
        cast = 0,
        cooldown = 900,
        gcd = "off",

        item = 49490,
        toggle = "cooldowns",
    },

    antique_cornerstone_grimoire = {
        cast = 0,
        cooldown = 900,
        gcd = "off",

        item = 49308,
        toggle = "cooldowns",
    },

    battlemasters_fury = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 42133,
        toggle = "defensives",

        handler = function()
            applyBuff( "tremendous_fortitude" )
            health.max = health.max + 4608
        end,

        auras = {
            tremendous_fortitude = {
                id = 67596,
                duration = 15,
                max_stack = 1
            }
        }
    },

    battlemasters_precision = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 42134,
        toggle = "defensives",

        handler = function()
            applyBuff( "tremendous_fortitude" )
            health.max = health.max + 4608
        end,
    },

    battlemasters_rage = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 42136,
        toggle = "defensives",

        handler = function()
            applyBuff( "tremendous_fortitude" )
            health.max = health.max + 4608
        end,
    },

    battlemasters_ruination = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 42137,
        toggle = "defensives",

        handler = function()
            applyBuff( "tremendous_fortitude" )
            health.max = health.max + 4608
        end,
    },

    battlemasters_vivacity = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        item = 42135,
        toggle = "defensives",

        handler = function()
            applyBuff( "tremendous_fortitude" )
            health.max = health.max + 4608
        end,
    },

    binding_light = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        items = { 47947, 47728 },
        item = function()
            if equipped[ 47947 ] then return 47947 end
            return 47728
        end,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "escalating_power" )
        end,

        auras = {
            escalating_power = {
                id = 47947,
                duration = 20,
                max_stack = 8,
                copy = 67740
            }
        }
    },

    binding_stone = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        items = { 48019, 47880 },
        item = function()
            if equipped[ 48019 ] then return 48019 end
            return 47880
        end,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "escalating_power" )
        end,
    },

    bitter_balebrew_charm = {
        cast = 0,
        cooldown = 600,
        gcd = "off",

        item = 49116,
        toggle = "cooldowns",
    },

    brawlers_souvenir = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 49080,
        toggle = "defensives",

        handler = function()
            applyBuff( "drunken_evasiveness" )
        end,

        auras = {
            brawlers_fortitude = {
                id = 68443,
                duration = 20,
                max_stack = 1
            }
        }
    },

    bubbling_brightbrew_charm = {
        cast = 0,
        cooldown = 600,
        gcd = "off",

        item = 49118,
        toggle = "cooldowns",
    },

    eitriggs_oath = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        items = { 48021, 47882 },
        item = function()
            if equipped[ 48021 ] then return 48021 end
            return 47882
        end,
        toggle = "defensives",

        handler = function()
            applyBuff( "hardening_armor" )
        end,

        auras = {
            hardening_armor = {
                id = 67742,
                duration = 20,
                max_stack = 5,
                copy = 67728
            }
        }
    },

    fervor_of_the_frostborn = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        items = { 47949, 47727 },
        item = function()
            if equipped[ 47949 ] then return 47949 end
            return 47727
        end,
        toggle = "defensives",

        handler = function()
            applyBuff( "hardening_armor" )
        end,
    },

    fetish_of_volatile_power = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        items = { 48018, 47879 },
        item = function()
            if equipped[ 48018 ] then return 48018 end
            return 47879
        end,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "volatile_power" )
        end,

        auras = {
            volatile_power = {
                id = 67744,
                duration = 20,
                max_stack = 8,
                copy = 67736
            }
        }
    },

    glyph_of_indomitability = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 47735,
        toggle = "defensives",

        handler = function()
            applyBuff( "defensive_tactics" )
        end,

        auras = {
            defensive_tactics = {
                id = 67694,
                duration = 20,
                max_stack = 1
            }
        }
    },

    juggernauts_vitality = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        items = { 47451, 47290 },
        item = function()
            if equipped[ 47451 ] then return 47451 end
            return 47290
        end,
        toggle = "defensives",

        handler = function()
            applyBuff( "fortitude" )
        end,
    },

    mark_of_supremacy = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 47734,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "rage" )
        end,

        auras = {
            rage = {
                id = 67695,
                duration = 20,
                max_stack = 1
            }
        }
    },

    satrinas_impeding_scarab = {
        cast = 0,
        cooldown = 180,
        gcd = "off",

        items = { 47088, 47080 },
        item = function()
            if equipped[ 47088 ] then return 47088 end
            return 47080
        end,
        toggle = "defensives",

        handler = function()
            applyBuff( "fortitude" )
        end,
    },

    shard_of_the_crystal_heart = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 48772,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "celerity" )
        end,

        auras = {
            celerity = {
                id = 67683,
                duration = 20,
                max_stack = 1
            }
        }
    },

    talisman_of_resurgence = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        item = 48779,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "hospitality" )
        end,

        auras = {
            hospitality = {
                id = 67684,
                duration = 20,
                max_stack = 1
            }
        }
    },

    talisman_of_volatile_power = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        items = { 47946, 47726 },
        item = function()
            if equipped[ 47946 ] then return 47946 end
            return 47726
        end,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "volatile_power" )
        end,
    },

    vengeance_of_the_forsaken = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        items = { 48020, 47881 },
        item = function()
            if equipped[ 48020 ] then return 48020 end
            return 47881
        end,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "rising_fury" )
        end,

        auras = {
            rising_fury = {
                id = 67747,
                duration = 20,
                max_stack = 5,
                copy = 67738
            }
        }
    },

    victors_call = {
        cast = 0,
        cooldown = 120,
        gcd = "off",

        items = { 47948, 47725 },
        item = function()
            if equipped[ 47948 ] then return 47948 end
            return 47725
        end,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "rising_fury" )
        end,
    },

    -- Phase 2

} )