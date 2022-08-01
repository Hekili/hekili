-- ShamanElemental.lua
-- 09.2020

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [x] Call of Flame
-- [-] High Voltage
-- [-] Pyroclastic Shock
-- [-] Shake the Foundations

-- Covenants
-- [-] Elysian Dirge
-- [-] Lavish Harvest
-- [-] Tumbling Waves
-- [x] Essential Extraction

-- Endurance
-- [-] Astral Protection
-- [-] Refreshing Waters
-- [x] Vital Accretion

-- Finesse
-- [x] Crippling Hex
-- [x] Spiritual Resonance
-- [x] Thunderous Paws
-- [x] Totemic Surge


if UnitClassBase( "player" ) == "SHAMAN" then
    local spec = Hekili:NewSpecialization( 262, true )

    spec:RegisterResource( Enum.PowerType.Maelstrom )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        earthen_rage = 22356, -- 170374
        echo_of_the_elements = 22357, -- 333919
        static_discharge = 22358, -- 342243

        aftershock = 23108, -- 273221
        echoing_shock = 23460, -- 320125
        elemental_blast = 23190, -- 117014

        spirit_wolf = 23162, -- 260878
        earth_shield = 23163, -- 974
        static_charge = 23164, -- 265046

        master_of_the_elements = 19271, -- 16166
        storm_elemental = 19272, -- 192249
        liquid_magma_totem = 19273, -- 192222

        natures_guardian = 22144, -- 30884
        ancestral_guidance = 22172, -- 108281
        wind_rush_totem = 21966, -- 192077

        surge_of_power = 22145, -- 262303
        primal_elementalist = 19266, -- 117013
        icefury = 23111, -- 210714

        unlimited_power = 21198, -- 260895
        stormkeeper = 22153, -- 191634
        ascendance = 21675, -- 114050
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( {
        control_of_lava = 728, -- 204393
        counterstrike_totem = 3490, -- 204331
        grounding_totem = 3620, -- 204336
        lightning_lasso = 731, -- 305483
        seasoned_winds = 5415, -- 355630
        skyfury_totem = 3488, -- 204330
        spectral_recovery = 3062, -- 204261
        static_field_totem = 727, -- 355580
        swelling_waves = 3621, -- 204264
        traveling_storms = 730, -- 204403
        unleash_shield = 3491, -- 356736
    } )

    -- Auras
    spec:RegisterAuras( {
        ancestral_guidance = {
            id = 108281,
            duration = 10,
            max_stack = 1,
        },

        ascendance = {
            id = 114050,
            duration = 15,
            max_stack = 1,
        },

        astral_shift = {
            id = 108271,
            duration = function () return level > 53 and 12 or 8 end,
            max_stack = 1,
        },

        celestial_guidance = {
            id = 324748,
            duration = 10,
            max_stack = 1,
        },

        earth_shield = {
            id = 974,
            duration = 600,
            type = "Magic",
            max_stack = 9,
        },

        earthbind = {
            id = 3600,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        -- might be the debuff on targets
        earthquake = {
            id = 61882,
            duration = 3600,
            max_stack = 1,
        },

        echoing_shock = {
            id = 320125,
            duration = 8,
            max_stack = 1,
        },

        elemental_blast = {
            duration = 10,
            type = "Magic",
            max_stack = 3,
            generate = function ()
                local eb = buff.elemental_blast

                local count = ( buff.elemental_blast_critical_strike.up and 1 or 0 ) +
                              ( buff.elemental_blast_haste.up and 1 or 0 ) +
                              ( buff.elemental_blast_mastery.up and 1 or 0 )
                local applied = max( buff.elemental_blast_critical_strike.applied,
                                buff.elemental_blast_haste.applied,
                                buff.elemental_blast_mastery.applied )

                eb.name = class.abilities.elemental_blast.name or "Elemental Blast"
                eb.count = count
                eb.applied = applied
                eb.expires = applied + 15
                eb.caster = count > 0 and "player" or "nobody"
            end
        },

        elemental_blast_critical_strike = {
            id = 118522,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        elemental_blast_haste = {
            id = 173183,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        elemental_blast_mastery = {
            id = 173184,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        elemental_fury = {
            id = 60188,
        },

        far_sight = {
            id = 6196,
            duration = 60,
            max_stack = 1,
        },

        flame_shock = {
            id = 188389,
            duration = function () return level > 58 and fire_elemental.up and 36 or 18 end,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },

        frost_shock = {
            id = 196840,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },

        ghost_wolf = {
            id = 2645,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
        },

        icefury = {
            id = 210714,
            duration = 15,
            max_stack = 4,
        },

        lava_surge = {
            id = 77762,
            duration = 10,
            max_stack = 1,
        },

        lightning_lasso = {
            id = 305484,
            duration = 5,
            max_stack = 1
        },

        lightning_shield = {
            id = 192106,
            duration = 1800,
            type = "Magic",
            max_stack = 1,
        },

        master_of_the_elements = {
            id = 260734,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },

        primordial_wave = {
            id = 327164,
            duration = 15,
            max_stack = 1,
        },

        reincarnation = {
            id = 20608,
        },

        spirit_wolf = {
            id = 260881,
            duration = 3600,
            max_stack = 4,
        },

        spiritwalkers_grace = {
            id = 79206,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },

        static_discharge = {
            id = 342243,
            duration = 3,
            max_stack = 1,
        },

        stormkeeper = {
            id = 191634,
            duration = 15,
            max_stack = 2,
        },

        surge_of_power = {
            id = 285514,
            duration = 15,
            max_stack = 1,
        },

        surge_of_power_debuff = {
            id = 285515,
            duration = 6,
            max_stack = 1,
        },

        thunderstorm = {
            id = 51490,
            duration = 5,
            max_stack = 1,
        },

        unlimited_power = {
            id = 272737,
            duration = 10,
            max_stack = 99,
        },

        water_walking = {
            id = 546,
            duration = 600,
            max_stack = 1,
        },

        wind_rush = {
            id = 192082,
            duration = 5,
            max_stack = 1,
        },

        wind_gust = {
            id = 263806,
            duration = 30,
            max_stack = 20
        },


        -- Pet aura.
        call_lightning = {
            duration = 15,
            generate = function( t, db )
                if storm_elemental.up then
                    local name, _, count, _, duration, expires = FindUnitBuffByID( "pet", 157348 )

                    if name then
                        t.count = count
                        t.expires = expires
                        t.applied = expires - duration
                        t.caster = "pet"
                        return
                    end
                end

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end,
        },


        -- Legendaries
        -- TODO:  Implement like Bloodtalons, but APL doesn't really require it mechanically.
        elemental_equilibrium = {
            id = 347348,
            duration = 10,
            max_stack = 1
        },

        elemental_equilibrium_debuff = {
            id = 347349,
            duration = 30,
            max_stack = 1
        },

        -- Conduit
        swirling_currents = {
            id = 338340,
            duration = 15,
            max_stack = 1
        }
    } )


    -- Pets
    spec:RegisterPet( "primal_storm_elemental", 77942, "storm_elemental", function() return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) ) end )
    spec:RegisterTotem( "greater_storm_elemental", 1020304 ) -- Texture ID

    spec:RegisterPet( "primal_fire_elemental", 61029, "fire_elemental", function() return 30 * ( 1 + ( 0.01 * conduit.call_of_flame.mod ) ) end )
    spec:RegisterTotem( "greater_fire_elemental", 135790 ) -- Texture ID

    spec:RegisterPet( "primal_earth_elemental", 61056, "earth_elemental", 60 )
    spec:RegisterTotem( "greater_earth_elemental", 136024 ) -- Texture ID

    local elementals = {
        [77942] = { "primal_storm_elemental", function() return 30 * ( 1 + ( 0.01 * state.conduit.call_of_flame.mod ) ) end, true },
        [61029] = { "primal_fire_elemental", function() return 30 * ( 1 + ( 0.01 * state.conduit.call_of_flame.mod ) ) end, true },
        [61056] = { "primal_earth_elemental", function () return 60 end, false }
    }

    local death_events = {
        UNIT_DIED               = true,
        UNIT_DESTROYED          = true,
        UNIT_DISSIPATES         = true,
        PARTY_KILL              = true,
        SPELL_INSTAKILL         = true,
    }

    local summon = {}
    local wipe = table.wipe

    local vesper_heal = 0
    local vesper_damage = 0
    local vesper_used = 0

    local vesper_expires = 0
    local vesper_guid
    local vesper_last_proc = 0

    spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        -- Deaths/despawns.
        if death_events[ subtype ] then
            if destGUID == summon.guid then
                wipe( summon )
            elseif destGUID == vesper_guid then
                vesper_guid = nil
            end
            return
        end

        if sourceGUID == state.GUID then
            -- Summons.
            if subtype == "SPELL_SUMMON" then
                local npcid = destGUID:match("(%d+)-%x-$")
                npcid = npcid and tonumber( npcid ) or -1
                local elem = elementals[ npcid ]

                if elem then
                    summon.guid = destGUID
                    summon.type = elem[1]
                    summon.duration = elem[2]()
                    summon.expires = GetTime() + summon.duration
                    summon.extends = elem[3]
                end

                if spellID == 324386 then
                    vesper_guid = destGUID
                    vesper_expires = GetTime() + 30

                    vesper_heal = 3
                    vesper_damage = 3
                    vesper_used = 0
                end

            -- Tier 28
            elseif summon.extends and state.set_bonus.tier28_4pc > 0 and subtype == "SPELL_ENERGIZE" and ( spellID == 51505 or spellID == 285466 ) then
                summon.expires = summon.expires + 1.5
                summon.duration = summon.duration + 1.5

            -- Vesper Totem heal
            elseif spellID == 324522 then
                local now = GetTime()

                if vesper_last_proc + 0.75 < now then
                    vesper_last_proc = now
                    vesper_used = vesper_used + 1
                    vesper_heal = vesper_heal - 1
                end

            -- Vesper Totem damage; only fires on SPELL_DAMAGE...
            elseif spellID == 324520 then
                local now = GetTime()

                if vesper_last_proc + 0.75 < now then
                    vesper_last_proc = now
                    vesper_used = vesper_used + 1
                    vesper_damage = vesper_damage - 1
                end

            end

            if subtype == "SPELL_CAST_SUCCESS" then
                -- Reset in case we need to deal with an instant after a hardcast.
                vesper_last_proc = 0
            end
        end
    end )

    spec:RegisterStateExpr( "vesper_totem_heal_charges", function()
        return vesper_heal
    end )

    spec:RegisterStateExpr( "vesper_totem_dmg_charges", function ()
        return vesper_damage
    end )

    spec:RegisterStateExpr( "vesper_totem_used_charges", function ()
        return vesper_used
    end )

    spec:RegisterStateFunction( "trigger_vesper_heal", function ()
        if vesper_totem_heal_charges > 0 then
            vesper_totem_heal_charges = vesper_totem_heal_charges - 1
            vesper_totem_used_charges = vesper_totem_used_charges + 1
        end
    end )

    spec:RegisterStateFunction( "trigger_vesper_damage", function ()
        if vesper_totem_dmg_charges > 0 then
            vesper_totem_dmg_charges = vesper_totem_dmg_charges - 1
            vesper_totem_used_charges = vesper_totem_used_charges + 1
        end
    end )


    spec:RegisterTotem( "liquid_magma_totem", 971079 )
    spec:RegisterTotem( "tremor_totem", 136108 )
    spec:RegisterTotem( "wind_rush_totem", 538576 )

    spec:RegisterTotem( "vesper_totem", 3565451 )


    spec:RegisterStateTable( "fire_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == "cast_time" then
                t.cast_time = class.abilities.fire_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_fire_elemental or pet.greater_fire_elemental

            if k == "active" or k == "up" then
                return elem.up

            elseif k == "down" then
                return not elem.up

            elseif k == "remains" then
                return max( 0, elem.remains )

            end

            return false
        end
    } ) )

    spec:RegisterStateTable( "storm_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == "cast_time" then
                t.cast_time = class.abilities.storm_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_storm_elemental or pet.greater_storm_elemental

            if k == "active" or k == "up" then
                return elem.up

            elseif k == "down" then
                return not elem.up

            elseif k == "remains" then
                return max( 0, elem.remains )

            end

            return false
        end
    } ) )

    spec:RegisterStateTable( "earth_elemental", setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == "cast_time" then
                t.cast_time = class.abilities.earth_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_earth_elemental or pet.greater_earth_elemental

            if k == "active" or k == "up" then
                return elem.up

            elseif k == "down" then
                return not elem.up

            elseif k == "remains" then
                return max( 0, elem.remains )

            end

            return false
        end
    } ) )


    -- Tier 28
	spec:RegisterGear( "tier28", 188925, 188924, 188923, 188922, 188920 )
    spec:RegisterSetBonuses( "tier28_2pc", 364472, "tier28_4pc", 363671 )
    -- 2-Set - Fireheart - While your Storm Elemental / Fire Elemental is active, your Lava Burst deals 20% additional damage and you gain Lava Surge every 8 sec.
    -- 4-Set - Fireheart - Casting Lava Burst extends the duration of your Storm Elemental / Fire Elemental by 1.5 sec. If your Storm Elemental / Fire Elemental is not active. Lava Burst has a 20% chance to reduce its remaining cooldown by 10 sec instead.
    spec:RegisterAura( "fireheart", {
        id = 364523,
        duration = 30,
        tick_time = 8,
        max_stack = 1
    } )


    local TriggerFireheart = setfenv( function()
        applyBuff( "lava_surge" )
    end, state )


    spec:RegisterHook( "reset_precast", function ()
        if talent.master_of_the_elements.enabled and action.lava_burst.in_flight and buff.master_of_the_elements.down then
            applyBuff( "master_of_the_elements" )
        end

        if vesper_expires > 0 and now > vesper_expires then
            vesper_expires = 0
            vesper_heal = 0
            vesper_damage = 0
            vesper_used = 0
        end

        vesper_totem_heal_charges = nil
        vesper_totem_dmg_charges = nil
        vesper_totem_used_charges = nil

        if totem.vesper_totem.up then
            applyBuff( "vesper_totem", totem.vesper_totem.remains )
        end

        rawset( state.pet, "earth_elemental", talent.primal_elementalist.enabled and state.pet.primal_earth_elemental or state.pet.greater_earth_elemental )
        rawset( state.pet, "fire_elemental",  talent.primal_elementalist.enabled and state.pet.primal_fire_elemental  or state.pet.greater_fire_elemental  )
        rawset( state.pet, "storm_elemental", talent.primal_elementalist.enabled and state.pet.primal_storm_elemental or state.pet.greater_storm_elemental )

        if talent.primal_elementalist.enabled then
            dismissPet( "primal_fire_elemental" )
            dismissPet( "primal_storm_elemental" )
            dismissPet( "primal_earth_elemental" )

            if summon.expires then
                if summon.expires <= now then
                    wipe( summon )
                else
                    summonPet( summon.type, summon.expires - now )
                end
            end
        end

        if buff.fireheart.up then
            if pet.fire_elemental.up then buff.fireheart.expires = pet.fire_elemental.expires
            elseif pet.storm_elemental.up then buff.fireheart.expires = pet.storm_elemental.expires end

            -- Proc the next Lava Surge from Fireheart.
            local next_ls = 8 - ( ( query_time - buff.fireheart.applied ) % 8 )

            if next_ls < buff.fireheart.remains then
                state:QueueAuraEvent( "fireheart", TriggerFireheart, query_time + next_ls, "AURA_PERIODIC" )
            end
        end
    end )


    -- Abilities
    spec:RegisterAbilities( {
        ancestral_guidance = {
            id = 108281,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            talent = "ancestral_guidance",
            toggle = "defensives",

            startsCombat = false,
            texture = 538564,

            handler = function ()
                applyBuff( "ancestral_guidance" )

                if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
            end,
        },

        ancestral_spirit = {
            id = 2008,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = false,
            texture = 136077,

            handler = function ()
            end,
        },

        ascendance = {
            id = 114050,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            talent = "ascendance",
            toggle = "cooldowns",

            startsCombat = false,
            texture = 135791,

            handler = function ()
                applyBuff( "ascendance" )
                gainCharges( "lava_burst", 2 )
            end,
        },

        astral_recall = {
            id = 556,
            cast = function () return 10 * haste end,
            cooldown = 600,
            gcd = "spell",

            startsCombat = false,
            texture = 136010,

            handler = function ()
            end,
        },

        astral_shift = {
            id = 108271,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 538565,

            handler = function ()
                applyBuff( "astral_shift" )
            end,
        },

        bloodlust = {
            id = 2825,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            spend = 0.22,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136012,

            handler = function ()
                applyBuff( "bloodlust" )
                applyDebuff( "player", "sated" )
                if conduit.spiritual_resonance.enabled then
                    applyBuff( "spiritwalkers_grace", conduit.spiritual_resonance.mod * 0.001 )
                end
            end,
        },

        capacitor_totem = {
            id = 192058,
            cast = 0,
            cooldown = function () return 60 + ( conduit.totemic_surge.mod * 0.001 ) end,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = false,
            texture = 136013,

            handler = function ()
            end,
        },

        --[[ chain_harvest = {
            id = 320674,
            cast = function () return 2.5 * haste end,
            cooldown = 90,
            gcd = "spell",

            toggle = "covenant",

            startsCombat = true,
            texture = 3565725,

            handler = function ()
            end,
        }, ]]

        chain_heal = {
            id = 1064,
            cast = function ()
                if buff.chains_of_devastation_ch.up then return 0 end
                return 2.5 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.3,
            spendType = "mana",

            startsCombat = false,
            texture = 136042,

            handler = function ()
                removeBuff( "chains_of_devastation_ch" )
                removeBuff( "echoing_shock" )

                if legendary.chains_of_devastation.enabled then
                    applyBuff( "chains_of_devastation_cl" )
                end

                if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
            end,
        },

        chain_lightning = {
            id = 188443,
            cast = function () return ( buff.stormkeeper.up or buff.chains_of_devastation_cl.up ) and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            nobuff = "ascendance",
            bind = "lava_beam",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 136015,

            handler = function ()
                removeBuff( "master_of_the_elements" )
                removeBuff( "echoing_shock" )
                removeBuff( "chains_of_devastation_cl" )

                if legendary.chains_of_devastation.enabled then
                    applyBuff( "chains_of_devastation_ch" )
                end

                -- 4 MS per target, direct.
                -- 3 MS per target, overload.

                gain( ( buff.stormkeeper.up and 7 or 4 ) * min( 5, active_enemies ), "maelstrom" )
                removeStack( "stormkeeper" )

                if pet.storm_elemental.up then
                    addStack( "wind_gust", nil, 1 )
                end


                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        cleanse_spirit = {
            id = 51886,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 236288,

            handler = function ()
            end,
        },

        earth_elemental = {
            id = 198103,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 136024,

            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_earth_elemental" or "greater_earth_elemental", 60 )
                if conduit.vital_accretion.enabled then
                    applyBuff( "vital_accretion" )
                    health.max = health.max * ( 1 + ( conduit.vital_accretion.mod * 0.01 ) )
                end
            end,

            usable = function ()
                return max( cooldown.fire_elemental.true_remains, cooldown.storm_elemental.true_remains ) > 0, "DPS elementals must be on CD first"
            end,

            timeToReady = function ()
                return max( pet.fire_elemental.remains, pet.storm_elemental.remains, pet.primal_fire_elemental.remains, pet.primal_storm_elemental.remains )
            end,

            auras = {
                -- Conduit
                vital_accretion = {
                    id = 337984,
                    duration = 60,
                    max_stack = 1
                }
            }
        },

        earth_shield = {
            id = 974,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            talent = "earth_shield",

            startsCombat = false,
            texture = 136089,

            handler = function ()
                applyBuff( "earth_shield" )

                if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
            end,
        },

        earth_shock = {
            id = 8042,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 60,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 136026,

            handler = function ()
                if talent.surge_of_power.enabled then
                    applyBuff( "surge_of_power" )
                end

                if runeforge.echoes_of_great_sundering.enabled then
                    applyBuff( "echoes_of_great_sundering" )
                end

                if runeforge.windspeakers_lava_resurgence.enabled then
                    applyBuff( "lava_surge" )
                    gainCharges( "lava_burst", 1 )
                    applyBuff( "windspeakers_lava_resurgence" )
                end

                removeBuff( "echoing_shock" )

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,

            auras = {
                windspeakers_lava_resurgence = {
                    id = 336065,
                    duration = 15,
                    max_stack = 1,
                },
            }
        },

        earthbind_totem = {
            id = 2484,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136102,

            handler = function ()
            end,
        },

        earthquake = {
            id = 61882,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 60,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 451165,

            handler = function ()
                removeBuff( "echoes_of_great_sundering" )
                removeBuff( "master_of_the_elements" )
                removeBuff( "echoing_shock" )

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,

            auras = {
                echoes_of_great_sundering = {
                    id = 336217,
                    duration = 25,
                    max_stack = 1
                }
            }
        },

        echoing_shock = {
            id = 320125,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 1603013,

            talent = "echoing_shock",

            handler = function ()
                applyBuff( "echoing_shock" )

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        elemental_blast = {
            id = 117014,
            cast = function () return 2 * haste end,
            cooldown = 12,
            gcd = "spell",

            spend = -30,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 651244,

            handler = function ()
                applyBuff( "elemental_blast" )

                if talent.surge_of_power.enabled then
                    applyBuff( "surge_of_power" )
                end

                removeBuff( "master_of_the_elements" )
                removeBuff( "echoing_shock" )

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        far_sight = {
            id = 6196,
            cast = function () return 2 * haste end,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 136034,

            handler = function ()
            end,
        },

        fire_elemental = {
            id = 198067,
            cast = 0,
            charges = 1,
            cooldown = 150,
            recharge = 150,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            toggle = "cooldowns",
            notalent = "storm_elemental",

            startsCombat = false,
            texture = 135790,

            timeToReady = function ()
                return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.storm_elemental.remains, pet.primal_storm_elemental.remains )
            end,

            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_fire_elemental" or "greater_fire_elemental" )

                if set_bonus.tier28_2pc > 0 then
                    applyBuff( "fireheart", pet.fire_elemental.remains )
                    state:QueueAuraEvent( "fireheart", TriggerFireheart, query_time + 8, "AURA_PERIODIC" )
                end
            end,
        },

        flame_shock = {
            id = 188389,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135813,

            cycle = "flame_shock",
            min_ttd = function () return debuff.flame_shock.duration / 3 end,

            handler = function ()
                applyDebuff( "target", "flame_shock" )

                if buff.surge_of_power.up then
                    active_dot.surge_of_power = min( active_enemies, active_dot.flame_shock + 1 )
                    removeBuff( "surge_of_power" )
                end

                removeBuff( "echoing_shock" )

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        frost_shock = {
            id = 196840,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 135849,

            handler = function ()
                removeBuff( "master_of_the_elements" )
                removeBuff( "echoing_shock" )

                applyDebuff( "target", "frost_shock" )

                if buff.icefury.up then
                    gain( 8, "maelstrom" )
                    removeStack( "icefury", 1 )
                end

                if buff.surge_of_power.up then
                    applyDebuff( "target", "surge_of_power_debuff" )
                    removeBuff( "surge_of_power" )
                end

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        ghost_wolf = {
            id = 2645,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136095,

            handler = function ()
                applyBuff( "ghost_wolf" )
                if talent.spirit_wolf.enabled then applyBuff( "spirit_wolf" ) end
                if conduit.thunderous_paws.enabled then applyBuff( "thunderous_paws" ) end
            end,
        },

        healing_stream_totem = {
            id = 5394,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.09,
            spendType = "mana",

            startsCombat = true,
            texture = 135127,

            handler = function ()
                if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
                if conduit.swirling_currents.enabled then applyBuff( "swirling_currents" ) end
            end,
        },

        healing_surge = {
            id = 8004,
            cast = function () return 1.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.24,
            spendType = "mana",

            startsCombat = false,
            texture = 136044,

            handler = function ()
                removeBuff( "echoing_shock" )

                if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
                if buff.swirling_currents.up then removeStack( "swirling_currents" ) end
            end,
        },

        hex = {
            id = 51514,
            cast = function () return 1.7 * haste end,
            cooldown = function () return level > 55 and 20 or 30 end,
            gcd = "spell",

            startsCombat = false,
            texture = 237579,

            handler = function ()
                applyDebuff( "target", "hex" )
            end,

            auras = {
                -- Conduit
                crippling_hex = {
                    id = 338055,
                    duration = 8,
                    max_stack = 1
                }
            }
        },

        icefury = {
            id = 210714,
            cast = 2,
            cooldown = 30,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135855,

            talent = "icefury",

            handler = function ()
                removeBuff( "master_of_the_elements" )
                removeBuff( "echoing_shock" )

                applyBuff( "icefury", 15, 4 )
                gain( 25, "maelstrom" )

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        lava_beam = {
            id = 114074,
            cast = function () return 2 * haste end,
            cooldown = 0,
            gcd = "spell",

            buff = "ascendance",
            bind = "chain_lightning",

            startsCombat = true,
            texture = 236216,

            handler = function ()
                removeBuff( "echoing_shock" )

                -- 4 MS per target, direct.
                -- 3 MS per target, overload.

                gain( ( buff.stormkeeper.up and 7 or 4 ) * min( 5, active_enemies ), "maelstrom" )
                removeStack( "stormkeeper" )

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        lava_burst = {
            id = 51505,
            cast = function () return buff.lava_surge.up and 0 or ( 2 * haste ) end,
            charges = function () return talent.echo_of_the_elements.enabled and 2 or nil end,
            cooldown = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            recharge = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 237582,

            velocity = 30,

            indicator = function()
                return active_enemies > 1 and settings.cycle and dot.flame_shock.down and active_dot.flame_shock > 0 and "cycle" or nil
            end,

            handler = function ()
                removeBuff( "windspeakers_lava_resurgence" )
                removeBuff( "lava_surge" )
                removeBuff( "echoing_shock" )

                gain( 10, "maelstrom" )

                if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end

                if talent.surge_of_power.enabled then
                    gainChargeTime( "fire_elemental", 6 )
                    removeBuff( "surge_of_power" )
                end

                if buff.primordial_wave.up and state.spec.elemental and legendary.splintered_elements.enabled then
                    applyBuff( "splintered_elements", nil, active_dot.flame_shock )
                end
                removeBuff( "primordial_wave" )

                if set_bonus.tier28_4pc > 0 then
                    if pet.fire_elemental.up then
                        pet.fire_elemental.expires = pet.fire_elemental.expires + 1.5
                        buff.fireheart.expires = pet.fire_elemental.expires
                    elseif pet.storm_elemental.up then
                        pet.storm_elemental.expires = pet.storm_elemental.expires + 1.5
                        buff.fireheart.expires = pet.storm_elemental.expires
                    end
                end

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,

            impact = function () end,  -- This + velocity makes action.lava_burst.in_flight work in APL logic.
        },

        lightning_bolt = {
            id = 188196,
            cast = function () return buff.stormkeeper.up and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            essential = true,

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136048,

            handler = function ()
                removeBuff( "echoing_shock" )

                gain( ( buff.stormkeeper.up and 11 or 8 ) + ( buff.surge_of_power.up and 3 or 0 ), "maelstrom" )

                removeBuff( "master_of_the_elements" )
                removeBuff( "surge_of_power" )

                removeStack( "stormkeeper" )

                if pet.storm_elemental.up then
                    addStack( "wind_gust", nil, 1 )
                end

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        lightning_lasso = {
            id = 305483,
            cast = function () return 5 * haste end,
            channeled = true,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 1385911,

            pvptalent = function ()
                if essence.conflict_and_strife.major then return end
                return "lightning_lasso"
            end,

            start = function ()
                removeBuff( "echoing_shock" )
                applyDebuff( "target", "lightning_lasso" )

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,

            copy = 305485
        },

        lightning_shield = {
            id = 192106,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136051,

            readyTime = function () return buff.lightning_shield.remains - 120 end,

            handler = function ()
                applyBuff( "lightning_shield" )
            end,
        },

        liquid_magma_totem = {
            id = 192222,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 971079,

            talent = "liquid_magma_totem",

            handler = function ()
                summonTotem( "liquid_magma_totem" )

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        primal_strike = {
            id = 73899,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.09,
            spendType = "mana",

            startsCombat = true,
            texture = 460956,

            handler = function ()
                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        purge = {
            id = 370,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 136075,

            toggle = "interrupts",
            interrupt = true,

            buff = "dispellable_magic",

            handler = function ()
                removeBuff( "dispellable_magic" )
            end,
        },

        spiritwalkers_grace = {
            id = 79206,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = true,
            texture = 451170,

            handler = function ()
                applyBuff( "spiritwalkers_grace" )
            end,
        },

        static_discharge = {
            id = 342243,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = off,
            texture = 135845,

            talent = "static_discharge",
            buff = "lightning_shield",

            handler = function ()
                applyBuff( "static_discharge" )

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        storm_elemental = {
            id = 192249,
            cast = 0,
            charges = 1,
            cooldown = 150,
            recharge = 150,
            gcd = "spell",

            toggle = "cooldowns",
            talent = "storm_elemental",

            startsCombat = true,
            texture = 2065626,

            timeToReady = function ()
                return max( pet.earth_elemental.remains, pet.primal_earth_elemental.remains, pet.fire_elemental.remains, pet.primal_fire_elemental.remains )
            end,

            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental" )

                if set_bonus.tier28_2pc > 0 then
                    applyBuff( "fireheart", pet.storm_elemental.remains )
                    state:QueueAuraEvent( "fireheart", TriggerFireheart, query_time + 8, "AURA_PERIODIC" )
                end
            end,
        },

        stormkeeper = {
            id = 191634,
            cast = function () return 1.5 * haste end,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 839977,

            talent = "stormkeeper",

            handler = function ()
                applyBuff( "stormkeeper", 20, 2 )
            end,
        },

        thunderstorm = {
            id = 51490,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 237589,

            handler = function ()
                if target.within10 then applyDebuff( "target", "thunderstorm" ) end

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        tremor_totem = {
            id = 8143,
            cast = 0,
            cooldown = function () return 60 + ( conduit.totemic_surge.mod * 0.001 ) end,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136108,

            handler = function ()
                summonTotem( "tremor_totem" )
            end,
        },

        water_walking = {
            id = 546,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 135863,

            handler = function ()
                applyBuff( "water_walking" )
            end,
        },

        wind_rush_totem = {
            id = 192077,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 538576,

            talent = "wind_rush_totem",

            handler = function ()
                summonTotem( "wind_rush_totem" )
            end,
        },

        wind_shear = {
            id = 57994,
            cast = 0,
            cooldown = 12,
            gcd = "spell",

            startsCombat = true,
            texture = 136018,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        -- Pet Abilities
        meteor = {
            id = 117588,
            known = function () return talent.primal_elementalist.enabled and not talent.storm_elemental.enabled and fire_elemental.up end,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            startsCombat = true,
            texture = 1033911,

            talent = "primal_elementalist",

            usable = function () return fire_elemental.up end,
            handler = function () end,
        },

        eye_of_the_storm = {
            id = 157375,
            known = function () return talent.primal_elementalist.enabled and talent.storm_elemental.enabled and storm_elemental.up end,
            cast = 0,
            cooldown = 40,
            gcd = "off",

            startsCombat = true,
            -- texture = ,

            talent = "primal_elementalist",

            usable = function () return storm_elemental.up end,
            handler = function () end,
        },


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
                    max_stack = 1
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


    --[[ spec:RegisterSetting( "funnel_damage", false, {
        name = "Funnel AOE -> Target",
        desc = function ()
            local s = "If checked, the addon's default priority will encourage you to spread |T135813:0|t Flame Shock but will focus damage on your current target, using |T136026:0|t Earth Shock rather than |T451165:0|t Earthquake."

            if not Hekili.DB.profile.specs[ state.spec.id ].cycle then
                s = s .. "\n\n|cFFFF0000Requires 'Recommend Target Swaps' on Targeting tab.|r"
            end

            return s
        end,
        type = "toggle",
        width = 1.5
    } ) ]]


    spec:RegisterStateExpr( "funneling", function ()
        return false
        -- return active_enemies > 1 and settings.cycle and settings.funnel_damage
    end )


    spec:RegisterSetting( "stack_buffer", 1.1, {
        name = "|T135855:0|t Icefury and |T839977:0|t Stormkeeper Padding",
        desc = "The default priority tries to avoid wasting |T839977:0|t Stormkeeper and |T135855:0|t Icefury stacks with a grace period of 1.1 GCD per stack.\n\n" ..
                "Increasing this number will reduce the likelihood of wasted Icefury / Stormkeeper stacks due to other procs taking priority, and leave you with more time to react.",
        type = "range",
        min = 1,
        max = 2,
        step = 0.01,
        width = "full"
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageDots = true,
        damageExpiration = 8,

        potion = "potion_of_spectral_intellect",

        package = "Elemental",
    } )

    --[[ spec:RegisterSetting( "micromanage_pets", true, {
        name = "Micromanage Primal Elemental Pets",
        desc = "If checked, Meteor, Eye of the Storm, etc. will appear in your recommendations.",
        type = "toggle",
        width = 1.5
    } ) ]]

    spec:RegisterPack( "Elemental", 20220801, [[Hekili:T3Z(VTnoA(3IXcOXUtxx)kPTdIdWm9gCOfZnhW65WD)KLvKzIfQSKxj5Kjag(V99JuViP4hF4hT7I9WUOtIef537NKmlhV8pwUyDqbz5Vpz0KjJ(WOXdhd)ZSjlxu86oYYf7cc)AWtWpKeSf(3FnMSLKueetFZRXPbRPZqE6(Sq4TBkk2L)tV7DpfvSz)dddt3(U8OT7JdkIstcZcESG(7HVB5Ih2hfx85KLpOC5NEdmN7iHWJVfGKnrRxtkhljpKdioUAXMGTbjh)YpV)P95fhxn(ThxrNQJF54x(0MGKNi5)0XV8xpU6ZjHPz7sZGf74QCsrruYt5dZla0Z)H9p(ij74QhtH)5ZHKh3N9kmplksZ2(vczhjBiBo(51RpU6)IuqOJlib(LF9vy2sF84QInKQpaEZtbrjdbcuw6JrXaz5V8xGr2fMPpwfCtFElSt)Tlb8xnpoHdmObgXFsc3xqGXsEMK9kmYOTKQXhewqNPOC4hFoiko4Hyc8DWJbwE(WDzeqk4HGI5KGSIn(KAYWBJECEp4)c)cmOOTbXTVlkVyijHotRzR))toraBoUQzApUAFsmjhw98ukmfSEn8ZVefd058DbVKqFrAIki6hN)UhHpDdtUKcoGuC8drjRhUdyj7Jj(KS97OF0HdnV65uQWm8U804NbGv98M3cR0jUcn5EAn651pliATpHovdPWoOZSpP4UPhoi)IOK7Vz0ae8ikJ0s(upMMx7)qCqEbhCj9Mgyd0aJJ9lcYEIuaa2gqIWpo6PnfjGS3DtzSMFHegSNYE(TN)LJR2eqfdajJSGNjXLYjVTwqz96uGBSloiKaJ6nfBOYmW6M96Ba5p4vF6)OseEkvcpmnHYklsPcwPrGW3609aC9xzReBQ2hhJWyJbzrqTidWZ4OeIF465t5L4oru(WbQQMaJC)o1qG03E2l(9ZN61Z6vFxk9zvQVFoPGKrfLlvZdH1mVLUbJ(fqY2pFdOHY)08DrzrfVee)vswU)tzaF7TBtFgGL5J5hx9A1(eqGWpQGSnN)HpgdoqGvjn8RuIrFduJbE9kIc)kSAE92rQuEALXhsN4NjE9nYXQwMTWCtY8tF0hKgRNN86vdu32NqaHVNidZ)6RpKrcyy9JrG9o)1KTr5KHK)((OD7aqta7bBxPzRJa4)fqO)THVgcwhQGN5Jz8DgBtAGaRZRVgmdS5OhZ8yZkJ1rDHu6k4UjJ4mwftcw7)WR(K)my7oWSSkKDhOFaegYAoAsnEAI6EZ1G6EjH)kfgfJHtXPRSzJK3vHbzKSE9fAr8xaVzBzKbCp5H4001(Sqk4SHfKhsswhKeYXvy4l3l2V7WHW0041PVKW)8mYwaHZb3zcRda6KSVkzR0U1rg3yWS7tJlGl9v5GFUy)WG44R7A9mbeyY8lsbBQcOAayPjlij)X95WJOarykeXqaafjuXjFyeE94KsiK15uXPmqHcgfyvp9LInncjEnwLnj5XqiKbTF3atosDhl(2JeguWbhYGMCdtuuLQHrsTh3mgzdjTdsq7eqv)YFZNgk8BPzEnpiL8wqElkSO0PsPriFscOMtGPWGrL7NiJoLHirc2E)eZREomfnU1eGJE8b3YHB1b1icN3nFI51cSeJUCUVATbibKW5sFiddWTXl8T0yOFLulOW(a6NZeIO2aAj2nm25Jh1zkOPb933dwQB(ys4Mu4Rk9)iesx5NuYk3eKb2bkKFP1PAi)H8(8ue0sg5Xmi5i6N61VFfDDDAXqUV7UjDi4t9AK2Ld4PIOC34B9A1VjHzPXWO0fK3Hdil)yPL)(5Z0gSOvMfgC4qFh8RQBbLMknHQ4HrHNYB(MkOqyM(EcGPc)89jRjzubU2GNqMNz82QW5mv2e7gR6Gbd0jarvJuVY6JE3koIBX5ypnVjmpmCUJUlVIkFc0ckW12I2gqIbtxPBVF(TJ867cB0RXUG6XrDo5KCrhuPnMdo8OBKlAJaEqRN2OYIo1YXkJ8U(XqUo9AK(AFyhOkocG31(BdEABqz4oCqx3xIzAtrU36JhzMN(qbA5L3DJAl6TYeUWwQsqrhJUdjQTYgWIjPSvRjBi8RzMyRmOITs57PycL)zGczLMCxnkbVHgI3AIB2cT06cVE6nJmHNDfzB5hk8IQWrNtOqoPW)H0K95dlaJDt(G)SDHEOCNUMWCdAvmXOLUq5lQDKm9npfI6lspBg9RUqEcNpthl8muPCWhLkoODYQM0cfKLpn8SVHQt4gMAfAr9zB1aDtxfSY5MeJrJXdesM2eY3nKj74aAP)ZDJ()9rsZnZ6w4(USoECj1iyP5nDEnRwBUz87kAQ9Qp7kMitkX6Jaqw0Sks5o856p8c1tPB0dwQjcKGTAJH1G4LgkBD3oqiX1r06dQGHDsmNp9OMjsFI2DMIS08cPPGVGgYvk5KRUH8eXcfVI(aITXTczmKNApyx6ls9FsXKyrZruvkaSGoSQC(QGJZQUnkMpEgtRONusqEYPaj871gWu2k)wJA1dN9w1Duy8h0dRwxNNVvO84HJrqq9mrxn2OD2oH6MPcMCQIanPa3AJPHOmhOigSoo5WbXAkyYX6viai92meCk1hrATsnM1JMy6lGPTAPfSV6WsPLQ3GurC1y1ePwpxxi8Ml9IlerKdwMr2wagHFJmDZZvR8VbYQCrXukIq7zs74(4iXs6zwo2IQQmGVMI01hG7YWOzcwGfrQqiliIQj1mrOHGAOtmJP1nRBS)nMHnOJ1H7RP(QDu0CqNI9TQ7YQ5pgl0ih)qpG2bdl)EoDmSmwU8EV0oJinLrPdyLBYm5DswLuR8J93SFBqsA0AaGEBu9o5XpA7wceBubH6fV5PpfN(qqSWJ0TKgCqcJn0FDuEjtqWlP4RSIfCA7)VMTcHMXyBsdOCrHunl)SMwkn2uJvhJ3y1XUOkRDOpe8etUpdYdl36W9CoTdBNp47HFMrOhcsbfude3FR1AGkZLHF8Z7ALRFhNCwgbDNYcmazrpvZeNFC9Aai9bV3VUfwhoGumjwCLnkrkAWd231xZ2t5hL9nSEFgBlEpWtZxX6bz3W8Q7vKq8GNmfHnvksDuT4U0CBDtXO7RvAamvHTka6C9zTBy(3p6s20mlCGlwXI(og0tniD5A7ZzNuNx)2EX9(r1BXpS4u64tZYK(CEFzZdwZMPdHVOzmARSG75OOzMp3M0EMPJyNmNHo6Qd9Si9k77x8TJUCiULnjPVEGJBdPPYafFkAFSZUgRBgDQOoMeBH0VSDp61mvY2dAMpCpTt0Ph6qlkg7PlFn36l5LB3j6ax0eDO1AKJoi8CX6R2m96BYtJKVrRDdE6zu6j7p22L0(52cliCD60YI0ONd7uPumQ(pWwJsMXaZ2T(3dlt2LeIvaP6uvofNI2xAixugTJuJp5vyMgYuV24YUF6n6z)JoBMIm5UVWdQxiQaWmfPbQ80LzR8Ov2dXhdwbgKjdNsZK0tk5mh1Ohrn)eh9qw0(TDQQRQb5VMWEjnLjdPp0txOW6q8)fOiEsWmwjkVeI26YX6CQBOsFxUx0qwbbLosg014znYLkQfOHWcTnjc70NCVAD2mzrMkvNgPHoN2ZlJSZ5xWSLlEgIkfGOQ7nG3pE6YfVeKrP45lx8)(Z)TF)Z)()5pDC1Xv)b9ShhTDxAwr1Pl(heqIF44QmQLKm6XBV6mKVViDBa78UhwEm8hE8l)wuc8QPJGj9tPjWYZE)p0Ow()9dLNvzUNuJ)WB6p(phWon9gaTMZWRBG1KZcQoR5GEe8)1)7FZEuuU2WoIPZonWSb6(mdyOF6nSlVGi6jjNA8GUglxal9M0SLlw0CTv8jQr)LlydHDxxWd8Wd(D2DOr1kT8xwUimlcSBhfSCr)JR64rVsC)4Q7qVghEZXv0s7q)VD(8Y6fVAaaPmyNcy8MAwwaQeOaKA9ZJR8Qwjo77DE2ja4s6S1qmNrdk4ovcCBgwR5mjIAp6nlq5gsB1Hd0lgaL1Wga15vqeDufy1ZLHR4Zbi8aYH411(4QFScFvurCGvXMETFpSeZQhyTmJ4wHGHa9QELqdDPIccomOcKavDMBuv2eRyBhsbjoNpQxRBmjWHqZ7xFtICpWNUDujwQcfRhTMW3Hj54QrCJTxdhVJ4opXusKVh3IW)kofUwKHI73II7QyJLGMJfzreGXZEJo7wLRGO9JgsjfDEVjwjsC11Owt2wmP633Wq61vfz)UwGqAwPqYhmbjQ2Rw1eyvfVNbrtljMDlIpt(5gEbiruz2mbQg3Itb2pAcyvNUHGLbvY0vgW4iu8ZdDLhp60x6YeQKk8pMKXyC)CfMQ9pV3k5XWMBCxwnWiAHVCqS3ZKoehHUP(Wmau2jLeakT5RmVqSHikHD7iDo1hlBq3vsuFxOs9nd)u1ilShlIMud9FCs5hRn5kgfzslHubb2gfhM6CL1tlXEb8cP0ELZV5OGMiyZqsKc3RPbkdqyhxBuvtFjQhIl17TRZtBixxvrfCciURxNDW6zW9uBj0zRmUxsPn(wl50ensoCBPGoKSfJ7Cubau1YdgzUWCRje8x3coOWIv((SAXS2Ajv24MrcFRo7FyG(eCFN9DvVXAlAdC3ASn4OlMT))niRuTEIXiCuL4SLyHk9BJrjGMZ8edbmHyhts8hpOgfwrSLHHUA4bWOH62touCWg20BStCBKaZUA2zGIXewTTcj91uKKAzUzifeHZ3PSYKBkidWftyUivWp4qE6WEp)WeAfK8iLD8yOScglDWeCVh22yirtK6BpKKKSUKz7j4SStcu4LZc3PcApCuATxxtKaXzUMdPzMfgyD7MwUympNRUZw8JTSju0bsrPX8YhcTvss(y6LO2J4KwCdwf67WeFI7IJGnV4MMALc0Dj1wRWI21jzFonVNT8NvMaYmMMxZMArdaIzvkX6ygbkB5dv5S6T(vpbvxxwPgt7xCXKTJ0zXANLoTVIH33IapTiaDz(O14eNKMiOoZybwSqKU7ZUwLtVGEjz)yW(yL9MGE)zNfTR8dvEVW2oVT3kSmd12sjvCTXkZ85LjlV9yLP58JO52KvAq4An9TYgFtHjB6LGxJsmYbMUYLV5aLNk0YbtoWzvK0(l1brp(Cc)fDlhDdzwS0(sM4yIxiv)VVrIID5omTvhq6a)vMArv5)nD5V2HAP5g(IlzlZW3nxxw21c3Q5EQpv8Qd6cV8fsAdFd59oWP(UPC9bEZsI(5LSn9r(rwEN6kncn1TVN2Ev2K0G4gWtmnzvDzK1FdUW8BUxFzGdEUVNc4WTmnxRVSLbp(WtzzChRBUDGzqdE8KFBGg6lBVeHzGKGRp(l(xz5hC3FDV9CRTuWPhy4s0Lt93b9mtfFQuj3cnCogM4Tdmd1Xl8lcQ)9gVTWkjTqCtv1QB1xSWmrPAFMnJv2kT8GhONUI7xO0CF9HITC(S0GD5q7sbkRgbjyB9qgqtoJEt)YIVSgoZeVIGl3io(L)XOjiTSra4vdVLnktAiCbRlJD0IhnXzOrCJbvytLX)gaus72QYmeA2MzQYrOEALZuvm5bN)BcJZzv3K1HcyJVOfcG1f4pvmkRyJ8Fsye1)nwyNM0EmknCf2qd8f)qyxlmZ64zmwWuDvsZj79stKUCA4RNz1FLxwUyQA5SZe(qRvRK4339)C4yo8(ZMEu5PIp3djssndsrbP(GPC)lknRRDFvQnNejPDXsTzOTjQVoWkr5XCXTjFFIPx9UP3Drk3MnID1wqNuxPwnQsQWCcQLamvmZL1V2cv)gpwsBjbUghQYLwPKutemi3OSSjz8TvJv(gJZMk3q1F1aGJvcGu((mBMDpRdxSQ9N9DmPuZGGYjwBbe8mX1M2nVbBBfUMzDMQOCnX3Bm)QQkvdk))NqXoWatZKBpx6HV71G4uyMsfVbNCPVahADZJUxcL2tb3oQj0fNKD8SARoqPnolwY34F5DrPXi1X3bZMvlLZO8QUFKnVFqpJTPjUlzZXqnRL5A9(85oXYLOiEcnfuYnPdp72MnYPh1UNWW9)JE0cmhRvdDZbbngo0DFN3ZkIVLg0W3zA4Ts1IWkNCAoCCYwCxBvs7KmD1VclQTovJtvokQktLqimoJ1QUvPBvZWLb66vqTVZovAtpAHSQg6UKYxZ7)FABRq1fAXCJAtg(6Rq4oLXpIezIM6TDjmz4uah4Ym2RwzHcKkLputj4rJOJ803MIsEYejlPgTXVz5hCowLACp4UCRr)DCTz0js1aD(iWJ26mK7NFQS0)ztUxZUs2gxOyUO0S7w7ueheRVOhivTHO1zVQQ3jY12NMMD96LCPr4TgofpDxdBnKzBaIi)LDafGnwMPZOsIL76c7aETviEcEhbrZFtgJjbSCCe3lSYIZILGRZUHT8hvUl2qyVIB0A16gcBPTj2VL2UaBtVrwVyy7FUcf9G67tXD78NUc(0Df2yKkQMB9i1SpQWRlPUaGBQHUd7FhdgroNQyBuD)7YMDSDgvT9HGafvkhEw11wnL34XJ(SjpJho(e35Nwu9o1MQ1AA1yLXCPndMlo15DoPT0Pt1(rqDjlTjgRREm3lXlvPMIW1xRsIG5MoxWcnqMGpk0q4nUp)D8uNBdP)oHOBLaiJDx)kaqAJ320b2gRPPD9fPzREzuwcf6WJyYcUGQeAAR4pQmy9(vs84C9XrQ73Hn6tE2v12MfWXdgSe1Jtje3rG5IpuE(T5BmG2tXnErhXn4BOZvDmbOv8d3faBES7SgIB53IqG1N(65FKNrxuJM5SWFpQ)6jt7MQH6E9RjTrJB9ibLK)55mLzoXYt7SCPjvWE2SRZkTtyZ4CoV1UN8RjoTJlhxVMwzFX0oUCSaWPQUnc7vhj7csYNc73DDhGuhYO8cK(QSnJolw7SCoNYmRpBuAYsU8)T8F8]] )

end
