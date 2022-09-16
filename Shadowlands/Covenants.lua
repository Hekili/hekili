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


local baseClass = UnitClassBase( "player" )

if baseClass == "SHAMAN" then
    all:RegisterAbilities( {
        -- Shaman - Kyrian    - 324386 - vesper_totem         (Vesper Totem)
        vesper_totem = {
            id = 324386,
            cast = 0,
            cooldown = 60,
            gcd = "totem",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 3565451,

            toggle = "essences",

            handler = function ()
                summonPet( "vesper_totem", 30 )
                applyBuff( "vesper_totem" )

                vesper_totem_heal_charges = 3
                vesper_totem_dmg_charges = 3
                vesper_totem_used_charges = 0
            end,

            auras = {
                vesper_totem = {
                    duration = 30,
                    max_stack = 1,
                }
            }
        },

        -- Shaman - Necrolord - 326059 - primordial_wave      (Primordial Wave)
        primordial_wave = {
            id = 326059,
            cast = 0,
            cooldown = 45,
            recharge = 45,
            charges = 1,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 3578231,

            toggle = "essences",

            cycle = "flame_shock",
            velocity = 45,

            impact = function ()
                applyDebuff( "target", "flame_shock" )
                applyBuff( "primordial_wave" )
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
            end,

            auras = {
                primordial_wave = {
                    id = 327164,
                    duration = 15,
                    max_stack = 1,
                },
                splintered_elements = {
                    id = 354648,
                    duration = 10,
                    max_stack = 10,
                },
            }
        },

        -- Shaman - Night Fae - 328923 - fae_transfusion      (Fae Transfusion)
        fae_transfusion = {
            id = 328923,
            cast = function () return haste * 3 * ( 1 + ( conduit.essential_extraction.mod * 0.01 ) ) end,
            channeled = true,
            cooldown = 120,
            gcd = "spell",

            spend = 0.075,
            spendType = "mana",

            startsCombat = true,
            texture = 3636849,

            toggle = "essences",
            nobuff = "fae_transfusion",

            start = function ()
                applyBuff( "fae_transfusion" )
            end,

            tick = function ()
                if legendary.seeds_of_rampant_growth.enabled then
                    if state.spec.enhancement then reduceCooldown( "feral_spirit", 9 )
                    elseif state.spec.elemental then reduceCooldown( talent.storm_elemental.enabled and "storm_elemental" or "fire_elemental", 6 )
                    else reduceCooldown( "healing_tide_totem", 5 ) end
                    addStack( "seeds_of_rampant_growth" )
                end
            end,

            finish = function ()
                if state.spec.enhancement then addStack( "maelstrom_weapon", nil, 3 ) end
            end,

            auras = {
                fae_transfusion = {
                    id = 328933,
                    duration = 20,
                    max_stack = 1
                },
                seeds_of_rampant_growth = {
                    id = 358945,
                    duration = 15,
                    max_stack = 5
                }
            },
        },

        fae_transfusion_heal = {
            id = 328930,
            cast = 0,
            channeled = true,
            cooldown = 0,
            gcd = "spell",

            suffix = "(Heal)",

            startsCombat = false,
            texture = 3636849,

            buff = "fae_transfusion",

            handler = function ()
                removeBuff( "fae_transfusion" )
            end,
        },

        -- Shaman - Venthyr   - 320674 - chain_harvest        (Chain Harvest)
        chain_harvest = {
            id = 320674,
            cast = 2.5,
            cooldown = 90,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 3565725,

            toggle = "essences",

            handler = function ()
                if legendary.elemental_conduit.enabled then
                    applyDebuff( "target", "flame_shock" )
                    active_dot.flame_shock = min( active_enemies, active_dot.flame_shock + min( 5, active_enemies ) )
                end
            end,
        }
    } )
elseif baseClass == "WARRIOR" then
    all:RegisterAbilities( {
        -- Warrior - Kyrian    - 307865 - spear_of_bastion      (Spear of Bastion)
        spear_of_bastion = {
            id = 307865,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = function () return -25 * ( 1 + conduit.piercing_verdict.mod * 0.01 ) end,
            spendType = "rage",

            startsCombat = true,
            texture = 3565453,

            toggle = "essences",

            velocity = 30,

            handler = function ()
                applyDebuff( "target", "spear_of_bastion" )
                if legendary.elysian_might.enabled then applyBuff( "elysian_might" ) end
            end,

            auras = {
                spear_of_bastion = {
                    id = 307871,
                    duration = function () return legendary.elysian_might.enabled and 8 or 4 end,
                    max_stack = 1
                },
                elysian_might = {
                    id = 311193,
                    duration = 8,
                    max_stack = 1,
                },
            }
        },

        -- Warrior - Necrolord - 324143 - conquerors_banner     (Conqueror's Banner)
        conquerors_banner = {
            id = 324143,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            startsCombat = false,
            texture = 3578234,

            toggle = "essences",

            handler = function ()
                applyBuff( "conquerors_banner" )
                if conduit.veterans_repute.enabled then
                    applyBuff( "veterans_repute" )
                end
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
            end,

            auras = {
                conquerors_banner = {
                    id = 324143,
                    duration = 20,
                    max_stack = 1
                },
                -- Conduit
                veterans_repute = {
                    id = 339267,
                    duration = 30,
                    max_stack = 1
                }
            }
        },

        -- Warrior - Night Fae - 325886 - ancient_aftershock    (Ancient Aftershock)
        ancient_aftershock = {
            id = 325886,
            cast = 0,
            cooldown = function () return 90 - conduit.destructive_reverberations.mod * 0.001 end,
            gcd = "spell",

            startsCombat = true,
            texture = 3636851,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "ancient_aftershock" )
                -- Rage gain will be reactive, can't tell what is going to get hit.
            end,

            auras = {
                ancient_aftershock = {
                    id = 325886,
                    duration = 1,
                    max_stack = 1,
                },
            }
        },

        -- Warrior - Venthyr   - 317320 - condemn               (Condemn)
        condemn = {
            id = function () return talent.massacre.enabled and 330325 or 317485 end,
            known = 317349,
            cast = 0,
            cooldown = function () return state.spec.fury and ( 4.5 * haste ) or 0 end,
            hasteCD = true,
            gcd = "spell",

            rangeSpell = function () return class.abilities.execute and class.abilities.execute.id end,

            spend = function ()
                if state.spec.fury then return -20 end
                return buff.sudden_death.up and 0 or 20
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 3565727,

            -- toggle = "essences", -- no need to toggle.

            usable = function ()
                if buff.sudden_death.up then return true end
                if cycle_for_condemn then return true end
                return target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or target.health_pct > 80, "requires > 80% or < " .. ( talent.massacre.enabled and 35 or 20 ) .. "% health"
            end,

            cycle = "condemn_ineligible",

            indicator = function () if cycle_for_condemn then return "cycle" end end,

            handler = function ()
                applyDebuff( "target", "condemned" )

                if not state.spec.fury and buff.sudden_death.down then
                    local extra = min( 20, rage.current )

                    if extra > 0 then spend( extra, "rage" ) end
                    gain( 4 + floor( 0.2 * extra ), "rage" )
                end

                if legendary.sinful_surge.enabled then
                    if state.spec.protection and buff.last_stand.up then buff.last_stand.expires = buff.last_stand.expires + 3
                    elseif state.spec.arms and debuff.colossus_smash.up then debuff.colossus_smash.expires = debuff.colossus_smash.expires + 1.5
                    elseif state.spec.fury and buff.recklessness.up then buff.recklessness.expires = buff.recklessness.expires + 1.5 end
                end

                if legendary.exploiter.enabled then applyDebuff( "target", "exploiter", nil, min( 2, debuff.exploiter.stack + 1 ) ) end

                removeBuff( "sudden_death" )

                if conduit.ashen_juggernaut.enabled then addStack( "ashen_juggernaut", nil, 1 ) end
            end,

            auras = {
                condemned = {
                    id = 317491,
                    duration = 10,
                    max_stack = 1,
                },
                -- Target Swapping
                condemn_ineligible = {
                    duration = 3600,
                    max_stack = 1,
                    generate = function( t, auraType )
                        if buff.sudden_death.up or not covenant.venthyr or ( target.health_pct > ( talent.massacre.enabled and 35 or 20 ) and target.health_pct < 80 ) then
                            t.count = 1
                            t.expires = query_time + 3600
                            t.applied = query_time
                            t.duration = 3600
                            t.caster = "player"
                            return
                        end
                        t.count = 0
                        t.expires = 0
                        t.applied = 0
                        t.caster = "nobody"
                    end
                }
            },

            copy = { 317485, 330325, 317349, 330334 }
        }
    } )
end