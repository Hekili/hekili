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

    spec:RegisterPack( "Elemental", 20220713, [[Hekili:T3ZAVnoYr(BriaCLMDIg9YEgVWYaz3SiygS3EaNZHCFsu0uTTjgksf(WEnGG(TFv3KSz)(HEmtoCbj7U2KnRUQQR3v3TxnD1FF19BIQqR(9ztMnBYhNoF8KBMF985RUV6TDOv3Vlk(Rrpb)qw0w4F)RPOTOSQOu8BElnpAdgcL51fXWBFUQAx5p9Hp8us1Z1pmooF7hkt2wNgvLKNfxe9yf(3J)WQ7FOojT6ZzREq50p7gaM7qXWJVEga2KnBqnJfvgZGehwF)ZrBJYo8LVuN(2H1ZEp8paGo8LdF5xEok7ju5pD4l)5dR)CwCEXU8cyQoSUevvLK9u54YkG4cFO(Xhrfhw)yo8V(Cm6X6I3a4CFvEX2VIq7qfJjW4VSzZH1)hOkeECrzWV8RVbql)XdRREg1(bWBEkkjBmWEkYFmjfyk)P)emszmg)yzSg)0Emh)BNdSVfoErbeSbgXFGIRRqWyrVGkaSTkzlQD8rXvyiLuc)4lrjPrpKIGVdEmSCxoExbcKaEiQAjkQO65quht49jpUCa8FHFbguY2O0(3LuwngLHH0gY8)FxI4OMdRPG9W66Suujm7L5yCkAZg4NFnjf4YL7IEnd)I8mvy0pU8dpcF6Zezsm6asWPpKKTz8U6YQ6uuiQOEh(J2VN(QxYXcYW7kZtFbqw1WTShxXaULmzEAh5fmSikzticdQXyCh0xQZQUD((9IVij7URMmsdDKuG6zFQhd91HpKgvwXGxcVHIBG2xAAyvuXtOkaXEgKicttE65Qmq2725KLMFgfhvJxE(Tx(5dRFoclgasgfrVGsBKtEFNGYMn5WQXU0OyemQ3v9mwMbM3I3Ehi)bV6x(RTIWZXs4X5z4LYQCSGvEci8TjVgWR)mzMiGQonvZcBkilcQffaDMMKHcJ3SCoRe3rsY73Jv14wiR3Pgde(2tEYVB58Gbop77YXpRv99ZzvOcSOCJAEmmNL98ny0Vcs2HLpdAOSpTCxsrs1RrPFfvug(ubSU9(T5Va4YYPSJRBU6FciqeMuH2wY(WhtbNhWSKh)vmZyOfUXOGbvjXFfMTGb7qTkp9Y4JXa(fuWqRRyTtZwa2OIW8hdbPXo4u2nBG6wDgce(EcnU8RV9qbkIq1pMa27c3G2MuIgJ(N1j72bOgh1d2UYl2Ka4)RGq)7JFlgSo0IplNsw3jlBcdew6cgAGYaBoMPSacujlDpb2RACfC7SjmgRsrrBcF4Tq0FeTDhywwfXUd0pagdAddpPJoTXDV6sWDpN4FRcJIXWO4ilBsL8UilqwzRxEHwn(lG3STjYaMN8qAE(Mqsifm2WIkJrzBIYIzwvi0lZlQ3TFFCEE6M8xZyFEbAlqWLG7mU5bqDuXxfSv628isBeC2FW4d6IFvj4Nlnmokn9YoxVGabMIWQCWMkhPgbwAkIYkFSUeEegjIZHigIaSidlofcJiyaJuccTPelovakuWOaR65Vw9mvijGAv2MKhHG0mO6DJS5i1FQ4BpryrbhCidAY0frEvk6cj2EmDmIgs6heN2jqQHn)wiou43JZ6Azuo69G8wsCvJtLgJqHOmqnhbGWIrL7MjsonHiHI2E3m7ZEjacQBno8yaBWTm0wxqn845TlNzFUalXANo)NT(aKaw4sHpKqb6TXZ9T4yOFd1jOq(a8NteIW2a6z20f2LtNibcCAq)ZAWsn9JrXpNdFvJ)hUq6A(KMLYNJka7avIV05une)qwFEkcAPa9ybKCe(tdgoSLVUjVAmZ3D7mjg(8aQ0UyapTmLBNEDqV(nkUipfgLPG82VxZ0pvy6VB5cJbl6KzHr73p0d)QMMqbqziuLaDC45SMVXckiIPVNaCQkSSoBdQalW1h8Kg4SG1wL(vMwBIYXQoA0itcqy1i1ZS5O3DAfXV4CCNNtdZthnlP7YQOYManNcCNTOTrOuW0v(27wE9KGH(SmgqTlOECyNtEjxirk9XCWqhYrUymc4r9EAtAk6u)kwtK3DpgY1zav6R)HsyvAcGVBc3g902OMWDyWo5xQZ0MICVnhpYIaZHc0VwE7vQTO3lt4ZYsBckMwOLyr9v2aMmbLTonzlHFTW2YkbRiZuznMsWRFw4qoPjlRrX5n0s8wZ8ZwOJwxy1tVAIn6uwKTF9qHxufo68IekrvHpKNvxoUcm2n7tHl2fhOD1r2eMFyRcaRT0fkFrNJK5V7PyT(ImVmR9RotEcxUW0s4jOs5HpkvRGUjRAtlKtw(4OZHwQoHFuQtKf2NTtd0pDvWkNFsmwngpIlzABeVCitUTcyK)V0p()3hjn)mR7G77M64XKudNLM3j9AsT28Z43f0u7fh6kaKnLyZraikA2gPS06C3hEM6P0vMrl1mbu0wJXWAr8YaNTRBhAyXDr0gcQGXsjMZMEefqMt0wcef5LvcGGTGgIvk5ORUHiGiHI3YFaX20EHmcXJThSl)vH(pPaio0CevLcqxqhovoFv4Xjv3gfWJDHPx0tijOaXuG4(9odykBLFVrTUHtER6okm9tMXvNRZZ3ksE64PAiqZlI(ASXi0oI6MPcN8QIa0uG7TXqzklboIfRJZ2VNVMc2CSEbcaYSndoNsd1iT2Qgt6rtk(fayBNAo7REmvg56uIkHPgR2y1Mx15cV5Cp5Cre5HLznBlaR4V1fD7WQx(3cBvSOykfrW9mPFC3mHVKE2LJDOQkJyRPiE(b8UjmAIGfyrelescIOfO2zcugQLoXmfx3m5y)PMHnRJPi44gV50IGpnWqfxLu98uu78bA5ayv3sx7FSU4W88ddawlmSY7yuO1LE053vPdl6sDasP3EL7OnXTTwRkI4JdFUEBuwEYgaHEFs32gkmz7weeiwfchYa9PpLM)quk3JmnLw8gdJnoCtszZIaNlz(x50sWXTzdP77cdJX1muosvxB2o03f3Pw8nZPkBCOpe9erUVas6R05yl9ohhxHh89Wpty0JbPGkSbI7U2znqLjoXo(LYw5gk5r1XW1LQbXint6XAM40tIWaczotHHD9lB)EnvUIeelvjsr3K09DdnSxy(rrFdBQli7L8rbg(ksdpLJPSRXuCbFE0CecOuKNQAXDby7Ch4WBIwC0sTXiZH6mn1voNI7MCo7qNdoW5lpYqpJWQdLoF9y6KZGmyyFJ)(4KU9tOU4uK8P5ygMEVjWzrRflmrWN10tDvwW)eIma5tTJWNyUpUjZzP9XMiphYLZ9MtF9KZhH7yhzgAg5y29BQmqXMp4nsBrn50hvXDSj2c5656gcKckr7bu4P3t7mt6HE0pKPbMso0VMGE(2kKESkAJp0BnYtheb(y91yMEdT5PrW3OZUbp(mkde9h76u6oSDWcctBvDSIqMxH9QUnwv)h5Qrj7uGD7w))dltULeItiP6uvogNIUxAiFugDJvRh4TuMb20G(4YUB(vMx(NCYlkIS7HCpOBIWcaluKgOYJYMRYJozpu)y0vGbr2WX05kZSsgZru9iS5N0KhksQ3kvczvdkCdI8sCktwsFyGPqHnr4)FGI4jGZ6kr55q02uowNsDdv67Y)IgskiOW5)aphVyqUurTaTewORjr4M(K)vRZfGLyRuDgKgKoAPNhzNtVGzRU)fiQuaJAVGcMp9Qv3)AubMJxU6()XF5)63)8V)3(PdRpS(VJpOZjB3Lxu1EuM)boI4hoSUaBjPaFw6BpW61v5BJihU(4MZ8)4dF53sYGxnFca0FjpdMEY7)bQA5)Zp0CWOzEsh9dVz40)ye5O7Bb1Ohyy)qRzNewDsWaFE))1)ZFZDsuS2WEsPxDCOjf7(mbzWF6vKBkHe8XwhB8aphRUN8tK7odwCeEWVtUtoAb4QFE19XfjG55KOv3p8WAjh3Ts1hwFR2RgI3DynUco4)R0N3uw41JwDFdkIrmwlkRQajFTiKA1WdRdANjgZ4sp7iqCbvZomMX2agDNlGU0H1B1sGPoaFBf0Sj3wVFp(YgqzPQbuDzlgHhvLUY2sOv9WaKraXn9LV(W6FSLEvu4ByPIaEJFpmfl6gyNmd)2RGqadAFfxFBXIcC(fWcKaxDHFCvcGvSvgXOeJpg1Z1v2e40WZh2D7KChSoD9KgQufj2nAdrPda5W6jmJDaDfxsCNLzkiYpGzsyFfJcxpXGP9R1s7QwgBqnpRLcpcRpjnm0DkLaE7huwjMC(OTLsnHp3rA0KQis1FKUGmqwfPExpsiavmM8jByIQ9)vhdwvn6jy08gMPCT6jYpxXkaXtklwWX1yMCmYEJnKvDwfCwgujt3AaJHrXch8mpDYXp1n5njuFFDsgt17NRYwj(z9wjogcS17YIIJARVLhI9b20Hyy00YatqqrNuciOWg6Y(ergcVe21tm5uFQObDFzrd9Hln0o(JvJCWEmpzIn0FZSMp2youeoYSEgPcgSlkoe15wRNos9C0LMk41aF7rbnJZMHGiLEVMw4maJDANrvdTFOBi(uwxzNNUWUUOIk6zG6D96Td2alUN6RuozM17Luy)T1ZoTXJed3wiOdbBX6DoQabA7SbHnxzVdeC(R7rhT4It((CAYC2Ajw24QjCFRj7F6q9z69Do0x9gNTOnYFRXUqJ(y2(FBqwPA9mRr4OkXzhPcv63wJsqBoZZSeWKg7ycI)6dQrHvexxW0oB6dGXa3DGyO4GnS5x5M42eUf7wOtqfRjS6AfsgAOijDYCl0uqegFNIkt(PGmsVycXfPI1dgIhpSpYomUo(iosrhpwkRG1shmtV3dx7)dVjsZDbsqs2uYSd4CwkLaL(YzP3PI2w1O0AVPEfbIZm9aYaK5gyxxLwD)u2vUUgyXo2MEnHhiMKMYkFW19ib5J5NJApQN1Q3GvL5gjXM4o)iiWvVPPEPatx8TDkSABUKOph67jt)jLjG4cd91eqZBaGpRsHLoIrGMo7GvoBFBy7t0QRlQuRt7NFYeTJinz9qrQlve6(An4tpbGNMBCMMyK04r1fwlWIdI0Yp7svo9k8LU9Jr1Pk7nb((4UizxZhQ8UMThU930Sed1UYjvCv0kU4Zkt2CJ0kYZzhb9gQvyq61Ag6KnEAHjP9siGQeR5qy36Y3EGYZ5A5Gnh4Kks6(ffbVhFgH)k5YrtzZ8L2xWehr8st1)hALP4wUdZ71beoeHnPw0w(FBxOSsCld3AymjBzh)U6YUKDPOTUvp1N0E1bDPV8fcAdFdx79yL67MY1NynlX7NxW20nSJS5E6vyegQB)aJ9QKM0a)(SJpnzvDzK0FdMW8P3vWe0rFUVhd6Wmn0RkyY0Op(WJzA8NQP34WeSrF8KFBWg8l7VyIjOeNRp2ltyr5h9U)KVrE7SuWOhy5I5Lr93d9mBfFQrj3bnCMfm(BCycPRVWVAi9V30TdwjXfIBUQwDR(YkMik15ZKowrR0IdEKz(QE)cnM77o7RnWZrd2ndvMd0uncu02UHmcNCg(2dMeFzhEwWFTd3SrCcB(JBtuEtJa0xn8(LrrwdIjyDrQdx8OzEJn8BmOkxQm(3aKsytv1KHaD3KPkhHoWkMPkFYdE)3zgVZQMM1HcCJTOfCO1z4p)mkRyJ4FMz41)TwyhAApwLgUaBOb2IFWTRfw4C8mwlyQPkP5L9EbazkNg26z2(xoMv3pxTC2jIFARvRG4339)e7yp8(tMF06PIn3dbws3cKIcs9jB5(x1yw34(Q0yojcs78LAZsBtuFfJ1qYtzIBt8okZS6nT3Djk3Mn8D1MtN0uPwTQsQWCIwlb6uXSxw)oludPESe2scmnouLlTgjjAemAULAjaz61TJv8wOZLk3G1FnGGtvIG419fUa9aNdxST9Nd9mPu7OGsaBSacb2w1MlN3GRTc3auxOkkxBR7uZVQQs1OM))ruSdDOPD2DGp9W3)AqCmlMcfVrp7YCbom6Mx7EjuypfC9eAOlEj7e40wDaZB8wSKTX)I7IsRrQRFhmBxTumJYl6(r2((b9e2MM6DjBpgQf9lUoVpFULVCjkINWqbL8t6iWTTzJy6r97jm9()1E0cShRfLV5HGgHgK335dCI57Obn97mn9Ts1HWkNDCoC8YwSSTkHDsMP6xPlQnPQXPkhfvLPIlegVPAv3u19Qz6LbK9kO23PuL2mtwAMvlDxs5Rz9)pVVvOMcTyPvTjlF9fiCNM4h1ezIH6TDomz4vah6LzCxTYbfivkFAnLOpAetSNHUuuYJMj5i3Op(nh)GtXQe19G)YTw93X0MrVyvJm5JqF0wNGC)YJDj9F1K7nSRKDXfQoxug2DRsfXrJ1xThivJHOjTxvn7e5s7tZWUE9Co1AwBTCkEKNdxnK5AaIA(RfHwe2AzMoHkj2SRlCd5nwH4z67iO283ePyuejhh(9cRO4mFj4K2nSn)OYDXMMLx(nATADdUT02m33sBNHTP3eNNmD7FUkf9G67tXDL(ZHbB6UCBmsfvZTBKg2hv6RlPPaGP1q3J9VJfJiNsvSTQU)DzZo2drvBFiiqrLYHNuDTvZ5TE8Opz2Z0XtpYD(PdvVtTPAJMwTwzmFAZG9ItDANtAhD60UFeuxYsxIX6IhZ9k9LQ0qr4gAujHZCJ0fSafZ48rPneER7ZFpp15UW6VLl6wbeYA31VaiKX4TTDGT110uzFrg2QxwLL0ID6JyYHvbvj00xXFTYGD7xj(JZ1ntu3Vdx0NcCRQT0jWZdgSa3JrjuVJa7fFO58BZ2yaJNIB9fDuVb)MOL42VwnD40slTKSnymZodjYF8ZJS8VHeIjWXTd7OEZMoedUQ0y1bGgVv(DMR1oPwnR5qahAdyyMZB2adPbADVpXPL(VohQn75mEChMSzUS9BSEyYCzCEN4S8rptkdwhmH4QboBB5ZPCiNQchXTl6fSlOkr1UHA6eS2CwgDkL2Zq(ZI2mKMSEOCkhZT5ott6tthB4RU6z8bv4(KT1PKRVSFHOcH)FR(F)d]] )

end
