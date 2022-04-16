-- Covenants.lua
-- November 2020

local addon, ns = ...
local Hekili = _G[ addon ]

local state = Hekili.State
local class = Hekili.Class

local all = Hekili.Class.specs[ 0 ]

local GetItemCooldown = _G.GetItemCooldown

-- Covenants
do
    local CovenantSignatures = {
        kyrian = { 324739 },
        necrolord = { 324631 },
        night_fae = { 310143, 324701 },
        venthyr = { 300728 },
    }

    CovenantSignatures[1] = CovenantSignatures.kyrian
    CovenantSignatures[2] = CovenantSignatures.venthyr
    CovenantSignatures[3] = CovenantSignatures.night_fae
    CovenantSignatures[4] = CovenantSignatures.necrolord

    local CovenantKeys = { "kyrian", "venthyr", "night_fae", "necrolord" }
    local GetActiveCovenantID = C_Covenants.GetActiveCovenantID

    -- v1, no caching.
    state.covenant = setmetatable( {}, {
        __index = function( t, k )
            if type( k ) == "number" then
                if GetActiveCovenantID() == k then return true end
                if CovenantSignatures[ k ] then
                    for _, spell in ipairs( CovenantSignatures[ k ] ) do
                        if IsSpellKnownOrOverridesKnown( spell ) then return true end
                    end
                end
                return false
            end

            -- Strings.
            local myCovenant = GetActiveCovenantID()

            if k == "none" then
                -- thanks glue
                if myCovenant > 0 then return false end

                -- We have to rule out Threads of Fate as well as real Covenants.
                for i, cov in ipairs( CovenantSignatures ) do
                    for _, spell in ipairs( cov ) do
                        if IsSpellKnownOrOverridesKnown( spell ) then return false end
                    end
                end

                return true
            end

            if myCovenant > 0 then
                if k == CovenantKeys[ myCovenant ] then return true end
            end

            if CovenantSignatures[ k ] then
                for _, spell in ipairs( CovenantSignatures[ k ] ) do
                    if IsSpellKnownOrOverridesKnown( spell ) then return true end
                end
            end

            -- Support covenant.fae_guardians and similar syntax.
            if class.abilities[ k ] then
                if state:IsKnown( k ) then return true end
            end

            return false
        end,
    } )
end


-- 9.0 Covenant Shared Abilities and Effects
do
    all:RegisterGear( "relic_of_the_first_ones", 184807 )

    all:RegisterAbilities( {
        door_of_shadows = {
            id = 300728,
            cast = 1.5,
            cooldown = function () return equipped.relic_of_the_first_ones and 48 or 60 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 3586270,

            handler = function ()
            end,
        },

        phial_of_serenity = {
            name = "|cff00ccff[Phial of Serenity]|r",
            cast = 0,
            cooldown = function () return time > 0 and 3600 or 60 end,
            gcd = "off",

            item = 177278,
            bagItem = true,

            startsCombat = false,
            texture = 463534,

            toggle = function ()
                if not toggle.interrupts then return "interrupts" end
                if not toggle.essences then return "essences" end
                return "essences"
            end,

            usable = function ()
                if GetItemCount( 177278 ) == 0 then return false, "requires phial in bags"
                elseif not IsUsableItem( 177278 ) then return false, "phial on combat cooldown"
                elseif health.current == health.max then return false, "requires a health deficit" end
                return true
            end,

            readyTime = function ()
                local start, duration = GetItemCooldown( 177278 )
                return max( 0, start + duration - query_time )
            end,

            handler = function ()
                gain( 0.15 * health.max, "health" )
                removeBuff( "dispellable_disease" )
                removeBuff( "dispellable_poison" )
                removeBuff( "dispellable_curse" )
                removeBuff( "dispellable_bleed" ) -- TODO: Bleeds?
            end,
        },

        fleshcraft = {
            id = 324631,
            cast = function () return 3 * haste end,
            channeled = true,
            cooldown = function () return equipped.relic_of_the_first_ones and 96 or 120 end,
            gcd = "spell",

            startsCombat = false,
            texture = 3586267,

            start = function ()
                applyBuff( "fleshcraft" )

                if conduit.volatile_solvent.enabled then
                    applyBuff( "volatile_solvent" )
                end
            end,

            auras = {
                fleshcraft = {
                    id = 324867,
                    duration = 120,
                    max_stack = 1
                },
                volatile_solvent_beast = {
                    id = 323498,
                    duration = 120,
                    max_stack = 1,
                },
                volatile_solvent_elemental = {
                    id = 323504,
                    duration = 120,
                    max_stack = 1,
                },
                volatile_solvent_aberration = {
                    id = 323497,
                    duration = 120,
                    max_stack = 1,
                },
                volatile_solvent_mechanical = {
                    id = 323507,
                    duration = 120,
                    max_stack = 1,
                },
                volatile_solvent_undead = {
                    id = 323509,
                    duration = 120,
                    max_stack = 1,
                },
                volatile_solvent_humanoid = {
                    id = 323491,
                    duration = 120,
                    max_stack = 1,
                },
                volatile_solvent_demon = {
                    id = 323500,
                    duration = 120,
                    max_stack = 1,
                },
                volatile_solvent_dragonkin = {
                    id = 323502,
                    duration = 120,
                    max_stack = 1,
                },
                volatile_solvent_giant = {
                    id = 323506,
                    duration = 120,
                    max_stack = 1,
                },
                volatile_solvent = {
                    alias = { "volatile_solvent_beast", "volatile_solvent_elemental", "volatile_solvent_aberration", "volatile_solvent_mechanical", "volatile_solvent_undead", "volatile_solvent_humanoid", "volatile_solvent_demon", "volatile_solvent_dragonkin", "volatile_solvent_giant" },
                    aliasMode = "longest", -- use duration info from the buff with the longest remaining time.
                    aliasType = "buff",
                    duration = 120,
                },
            }
        },
    } )

    all:RegisterAuras( {
        echo_of_eonar = {
            id = 338489,
            duration = 10,
            max_stack = 1,
        },

        maw_rattle = {
            id = 341617,
            duration = 10,
            max_stack = 1
        },

        sephuzs_proclamation = {
            id = 339463,
            duration = 15,
            max_stack = 1
        },
        sephuz_proclamation_icd = {
            duration = 30,
            max_stack = 1,
            -- TODO: Track last application of Sephuz's buff via event and create a generator to manufacture this buff.
        },

        third_eye_of_the_jailer = {
            id = 339970,
            duration = 60,
            max_stack = 5,
        },

        vitality_sacrifice_buff = {
            id = 338746,
            duration = 20,
            max_stack = 1,
        },
        --[[ vitality_sacrifice_debuff = {
            id = 339131,
            duration = 60,
            max_stack = 1
        } ]]
    } )
end