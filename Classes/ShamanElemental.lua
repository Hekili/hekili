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
            duration = function () return level > 58 and ( fire_elemental.up or storm_elemental.up ) and 36 or 18 end,
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

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

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

                if runeforge.echoes_of_great_sundering.enabled then
                    applyBuff( "echoes_of_great_sundering" )
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

    spec:RegisterPack( "Elemental", 20220315, [[dG0KscqiePhbHO2ee9juLWOKs5usPAvOkPxjLywcOBbHuAxi9lPOggQsDmuvTmPKEMqPMgIixdruBtOK(geImoiKCouLO1juImpiW9qu7dr4GcLGwOqXdfkrnrHsGUiec5JqifDsiKQvIQYmHqGBcHqzNOk(jecvTuiKcpfvMQuKRcHqLVkucySqiO9sXFjmyromvlgHhtPjd0Lv2SO(mGrlKtRYRLcZwv3gs7wYVrz4c64qOwouph00jDDPA7c03HGgVqj05fG5luTFI2WVPjdhORZWtR8U1w5DS5NKP8JOIDSssKKHtdiCgUq32WbMHRC0z4qe9dDL6VHl0d4zoOPjdhK1X2z4Iunegl1CZaNg1jOwgAZWdT)UESYI9S2m8qTnB4i63Ri6LHWWb66m80kVBTvEhB(jzk)iQyhRKKHdgoRHNwJ1wnCrhi4kdHHdCqRHdr0p0vQ)YexKJ6LKpeXCSnsM4V1aLPw5DRTk5tYxSCKxadglj5drRmHOxwgoKHDDYeCQEfaKcv32qq0Z5HLPmdlti62L74acuM4uggTXw4WujFiALPyHGGYeIythdltEbktiIcyYelltA0KjoLHrLjhWVIA4cXS89ZWHiJiltiI(HUs9xM4ICuVK8HiJiltiI5yBKmXFRbktTY7wBvYNKpezezzkwoYlGbJLK8HiJiltiALje9YYWHmSRtMGt1RaGuO62gcIEopSmLzyzcr3UChhqGYeNYWOn2chMk5drgrwMq0ktXcbbLjeXMogwM8cuMqefWKjwwM0OjtCkdJktoGFfvYNKpezzcruS4SDDGY0coCaYKEOtM0OjtUvzyz6GYKh0V3j(rL85w9yfKgINLHs4k55ynsSFORu)d8YKjv9FLsdXhQ)I9dDL6)bv6kN4hOKpezzcrCWjtCkdJ2ylCyzkepldLWvzQx)GqzcYqNm5GGqzcH3)Yem0ryjtqgROs(CREScsdXZYqjCTfYnN)bJSypRbEzYqw)jUcKg2HA)Ny4EOESkECiR)exbsdYExVFci7dUsL85w9yfKgINLHs4AlKBgQmmAJTWHd8YKv)xPuOYWOn2chMUYj(bISnSFGIfCLsDqqi1Y6LIGyhpo2pqXcUsPoiiKEfjizE3UKp3QhRG0q8SmucxBHCZ5dpX(HUs9xYNB1JvqAiEwgkHRTqU59dDL6VG4DOg4LjR(VsP7h6k1FbX7qLUYj(bIegU)fQJbMcP2i)kXFarADfacITKpezzkMz9oCYeIGGXitrouMCzsXEW9YKEOlqzsJMm5GGSsMcF3oOmXRA0bLPvkoaEvMyLmflhlOmLzyzk2YeCwwbcLjLjtEq2bktGSoXpeTiccgJmXkzkS)pvYNB1JvqAiEwgkHRTqU53d6cIogQb(xnHfKCSd8YKjv9FLs3p0vQ)cI3HkDLt8dejmC)luhdmfsTr(vI)aI06kaee74Xj65mfQmmAJTWHP9qjFUvpwbPH4zzOeU2c5MTr(vI)aI06kGaVmzsv)xP09dDL6VG4DOsx5e)arcd3)c1XatHuBKFL4pGiTUcGeKJnssj65mfQmmAJTWHP9qjFUvpwbPH4zzOeU2c5Mdz6XkjFs(qKLje9shg3dvzILLjRdvivYNB1JvWwi3mcVcuaJMJL85w9yfSfYnddp8Pi0)gddfay3UarzbVcGm)s(CRESc2c5Mdz6XkjFUvpwbBHCZD4eNouOKp3QhRGTqU587OtaJy2gbEzYTrQ6)kLUFORu)feVdv6kN4hy7ijvpBJRaqsA4ukuzyuX(HUs9N6w9coKTbd3)c1XatHuBKFL4pGiTUcabXoEC1)vkf1H6WcwwOrtSFORuiDLt8dmECCVwMHbgf2iac88gddf5B4aeGd9GJoe3VWWb2UKp3QhRGTqU5q8HYWGN)ce6bxG2aS)eQJbMcjZFGxMmPe9CMgIpugg88xGqp4O9qKTrA4ukuzyuX(HUs9N6w9cU4XHH7FH6yGPqQnYVs8hqKwxbGGyJKONZueEfOaOdvkuDBde0kVJhhY6pXvG0FoOGiaXIfD0WF0voXpW4XX9Azggyuy4FLo8af7h6kfshI7xy4aBhzBWW9VqDmWui1g5xj(disRRaqajhpU6)kLI6qDybll0Oj2p0vkKUYj(bgpoUxlZWaJcBeabEEJHHI8nCacWHEWrhI7xy4aJhhY6pXvG0FoOGiaXIfD0WF0voXpW4XX9Azggyuy4FLo8af7h6kfshI7xy4aBhjPe9CMcd)R0HhOy)qxPqApuYNB1JvWwi3C(D0jGrmBJaVmzs1Z24kaKTrA4ukuzyuX(HUs9N6w9cU4XHH7FH6yGPqQnYVs8hqKwxbGGyJKONZueEfOaOdvkuDBde0kVBhzBWW9VqDmWui1g5xj(disRRaqqSJhx9FLsrDOoSGLfA0e7h6kfsx5e)aJhh3RLzyGrHncGapVXWqr(goab4qp4OdX9lmCGTl5ZT6XkylKBoF4j2p0vQ)s(CRESc2c5MrNogwYNB1JvWwi3mXZyGIChhqGxMmPQ)RuQdTRa9Yo6kN4hy84e9CM6q7kqVSJ2dJh3YypidHf1H2vGEzhfpu)kijizEl5ZT6XkylKBMyy4WnUciWltMu1)vk1H2vGEzhDLt8dmECIEotDODfOx2r7Hs(CRESc2c5MZhEepJbg4LjtQ6)kL6q7kqVSJUYj(bgporpNPo0Uc0l7O9W4XTm2dYqyrDODfOx2rXd1VcscsM3s(CRESc2c5M9YoOI9xy9)d8YKjv9FLsDODfOx2rx5e)aJhNONZuhAxb6LD0Ey84wg7bziSOo0Uc0l7O4H6xbjbjZBjFUvpwbBHCZeoGGLfk(SnGbEzYKQ(VsPo0Uc0l7ORCIFGXJtkrpNPo0Uc0l7O9qjFUvpwbBHCZbhmCyHY0Hk5ZT6XkylKBo7tOyVG5o8yvGxMSLfCLxkToGivK9HKuCVwMHbgfUbcfSSa7OHEPcamdHAeDiUFHHdezBKQ(VsPOouhwWYcnAI9dDLcPRCIFGXJt0ZzkQd1HfSSqJMy)qxPqApSDKWW9VqDmWui1g5xj(disRRaqqSL85w9yfSfYnN9juSxWChESkWlt2YcUYlLwhqKkY(qI71YmmWOWnqOGLfyhn0lvaGziuJOdX9lmCGiBJu1)vkf1H6WcwwOrtSFORuiDLt8dmECIEotrDOoSGLfA0e7h6kfs7HXJdd3)c1XatHuBKFL4pGiTUcGeKJD7iBZYypidHfnF4j2p0vQ)u8q9RGKOvEhpULXEqgclkuzyuX(HUs9NIhQFfKeTY72L85w9yfSfYnJ7LWT6XkXFqnWYrhzNTaHk(Skz(d8YKDREbNy1qVbjrRiBdgU)fQJbMcP2i)kXFarADfajAnECy4(xOogykK(EqxqmhLeT2UKp3QhRGTqUzCVeUvpwj(dQbwo6idVc4NqDmW0aHk(Skz(d8YKjv9FLsHkdJk2p0vQ)0voXpqKUvVGtSAO3GiGCRs(CRESc2c5MX9s4w9yL4pOgy5OJmCc4va)eQJbMgiuXNvjZFGxMS6)kLcvggvSFORu)PRCIFGiDREbNy1qVbra5wL8j5ZT6Xki1zJmuzyuX(HUs9pWltM0WPuOYWOI9dDL6p1T6fCs(CREScsD2AHCZlGjyzHgnbuzy0aVmzIEotT()I)aI06kakEO(vqsqMFEl5ZT6Xki1zRfYnphRriU7nwGxMmrpNPZgXUcqaJy2g0EOKp3QhRGuNTwi3SnYVse54GdQs(CREScsD2AHCZqLHrBSfoCGxMS6)kLcvggTXw4W0voXpqjFUvpwbPoBTqU587OtaJy2gbAdW(tOogykKm)bEzY4LXdg5e)q2wBUvVGtaYuA(D0jGrmBde0ks3QxWjwn0Bqeqo2iTm2dYqyrdXhkddE(lqOhCu8q9RGiG)yfPLfCLxkTMfZEggejPHtPqLHrf7h6k1FQB1l4Ih3T6fCcqMsZVJobmIzBGa(r6w9coXQHEdscYKessdNsHkdJk2p0vQ)u3QxWHu9FLsrDOoSGLfA0e7h6kfsx5e)aBpE82W9AzggyuyJaiWZBmmuKVHdqao0do6qC)cdhissdNsHkdJk2p0vQ)u3QxW1E84TH71YmmWOWW)kD4bk2p0vkKoe3VWWbISn3QxWjazkn)o6eWiMTbcInssX9Azggy0zJydkyzbaEUkG9cC4RaOdX9lmCGXJ7w9cobitP53rNagXSnqaj1oY2Sm2dYqyrdXhkddE(lqOhCu8q9RGiG)ynECIEotdXhkddE(lqOhC0Ey7T3UKp3QhRGuNTwi3C(D0jGrmBJaVmzsDREbNaKP087OtaJy2gijnCkfQmmQy)qxP(tDREbhY2u)xPuuhQdlyzHgnX(HUsH0voXpW4XX9AzggyuyJaiWZBmmuKVHdqao0do6qC)cdhy7XJ3gUxlZWaJcd)R0HhOy)qxPq6qC)cdhiss1Z24kaKe9CMgIpugg88xGqp4O9W2L85w9yfK6S1c5MNnIDfGagXSnc8YKv)xP0zJyxbiGrmBd6kN4hisuFpuXmusqow5nY2W9Azggy0zJydkyzbaEUkG9cC4RaOdX9lmCGij65mD2i2GcwwaGNRcyVah(kaApmECsX9Azggy0zJydkyzbaEUkG9cC4RaOdX9lmCGTl5ZT6Xki1zRfYn7q7kqVSlWltw9FLsDODfOx2rx5e)ar2gPHtPqLHrf7h6k1FQB1l4AhzBKQ(VsPND5ooa6kN4hy84Ks0Zz6zxUJdG2drsQLXEqgcl6zxUJdG2dBxYNB1JvqQZwlKB(pe3pqbQdG6cLPdnWltw9FLs)dX9duG6aOUqz6qPRCIFGs(CREScsD2AHCZ2i)kXFarADfqGxMmmC)luhdmfsTr(vI)aI06kaeqsij65mf1H6WcwwOrtSFORuiThIe13dvmdfbKmVL85w9yfK6S1c5MNJ1ibmIzBe4LjJ71YmmWOZgXguWYca8Cva7f4WxbqhI7xy4arskrpNPZgXguWYca8Cva7f4Wxbq7Hs(CREScsD2AHCZVh0feDmud8YKbzkn)o6eWiMTbfpu)kisy4(xOogykKAJ8Re)beP1vaiGKq2gPHtPqLHrf7h6k1FQB1l4AhzBe9CM(Eqxa7yGr7HijLONZuuhQdlyzHgnX(HUsH0Eis1)vkf1H6WcwwOrtSFORuiDLt8dSDjFUvpwbPoBTqU55yncXDVXc8YKHH7FH6yGPqQnYVs8hqKwxbqcYTIKuCVwMHbgD2i2GcwwaGNRcyVah(ka6qC)cdhiY2u)xPuuhQdlyzHgnX(HUsH0voXpqKO(EOIzOKGmjZBKKs0ZzkQd1HfSSqJMy)qxPqApSDjFUvpwbPoBTqU53d6cIogQbAdW(tOogykKm)bEzYwwWvEP0Awm7zyqK4ETmddm6SrSbfSSaapxfWEbo8va0H4(fgoqKWPccw1Hu9gUveLGKcTij65m99GUa2XaJ2drskrpNPH4dLHbp)fi0doApuYNB1JvqQZwlKB(9GUGOJHAG2aS)eQJbMcjZFGxMmrpNPVh0fWogy0EisIEotdXhkddE(lqOhC0EiY2i65mneFOmm45VaHEWrXd1VcIGyZRawW4XDREbNaKP087OtaJy2gKHH7FH6yGPqQnYVs8hqKwxbepUB1l4eGmLMFhDcyeZ2GCSrskUxlZWaJoBeBqbllaWZvbSxGdFfaDiUFHHdmEC3QxWjazkn)o6eWiMTbzsQDjFUvpwbPoBTqU53d6cIogQbEzYGmLMFhDcyeZ2GIhQFfejmC)luhdmfsTr(vI)aI06kaeqsiX9AzggyuyJaiWZBmmuKVHdqao0do6qC)cdhisIEotFpOlGDmWO9qKQ)RukQd1HfSSqJMy)qxPq6kN4hissj65mf1H6WcwwOrtSFORuiThIe13dvmdLeKjzEl5ZT6Xki1zRfYn)Eqxq0XqnWltgKP087OtaJy2gu8q9RGiBRny4(xOogykKAJ8Re)beP1vaiGKqI71YmmWOWgbqGN3yyOiFdhGaCOhC0H4(fgoqKQ)RukQd1HfSSqJMy)qxPq6kN4hy7XJ3M6)kLI6qDybll0Oj2p0vkKUYj(bIe13dvmdLeKjzEJKuIEotrDOoSGLfA0e7h6kfs7HiBJuCVwMHbgD2i2GcwwaGNRcyVah(ka6qC)cdhy84e9CMoBeBqbllaWZvbSxGdFfaTh2ossX9AzggyuyJaiWZBmmuKVHdqao0do6qC)cdhy7Tl5ZT6Xki1zRfYn)Eqxq0XqnWltgKP087OtaJy2gu8q9RGiHH7FH6yGPqQnYVs8hqKwxbqMKqI71YmmWOWgbqGN3yyOiFdhGaCOhC0H4(fgoqKe9CM(Eqxa7yGr7Hiv)xPuuhQdlyzHgnX(HUsH0voXpqKKs0ZzkQd1HfSSqJMy)qxPqApejQVhQygkjitY8wYNB1JvqQZwlKBEowJqC3BSaVmzy4(xOogykKAJ8Re)beP1vaKGCRs(CREScsD2AHCZ2i)kXFarADfqGxMmrpNPqLHrBSfomfpu)kicInVcyb5vIEotHkdJ2ylCykuDBdjFUvpwbPoBTqU53d6cIogQbAdW(tOogykKm)bEzYWPccw1Hu9gUveLGKcTij65m99GUa2XaJ2drskrpNPH4dLHbp)fi0doApuYNB1JvqQZwlKB(9GUGOJHAGxMmCQGGvDivVHBfrjiPqlsIEotFpOlGDmWO9qKKs0ZzAi(qzyWZFbc9GJ2dL85w9yfK6S1c5MFpOli6yOg4Ljt0Zz67bDbSJbgThIegU)fQJbMcP2i)kXFarADfacijKTrA4ukuzyuX(HUs9N6w9cU2rcYuA(D0jGrmBdQE2gxbi5ZT6Xki1zRfYnVFORu)feVd1aVmz1)vkD)qxP(liEhQ0voXpqKWW9VqDmWui1g5xj(disRRaqajJSnsdNsHkdJk2p0vQ)u3QxW1UKp3QhRGuNTwi387bDbXC0aVmz1)vk1H2vGEzhDLt8duYNB1JvqQZwlKB2g5xj(disRRaK85w9yfK6S1c5MFpOli6yOgikl4vaK5pWltMONZ03d6cyhdmApePLXEqgclbEUvL85w9yfK6S1c5MZVJobmIzBeikl4vaK5pqBa2Fc1XatHK5pWltgVmEWiN4NKp3QhRGuNTwi3CgZGQagXSnceLf8kaY8l5tYNB1JvqkCc4va)eQJbMsgQmmQy)qxP(h4LjtA4ukuzyuX(HUs9N6w9cojFUvpwbPWjGxb8tOogyAlKB(pGiTUcqqWEnWltMONZuyhdmbllcziCyApuYNB1JvqkCc4va)eQJbM2c5MdXhkddE(lqOhCbAdW(tOogykKm)bEzYwwWvEP0Awm7zyqKKs0ZzAi(qzyWZFbc9GJ2drskrpNPWW)kD4bk2p0vkK2dL85w9yfKcNaEfWpH6yGPTqU5fWeSSqJMaQmmAGxMmrpNPw)FXFarADfafpu)kijiZpVL85w9yfKcNaEfWpH6yGPTqU5mMbvbmIzBe4LjR(VsPND5ooa6kN4hisIEotp7YDCa0EisIEotp7YDCau8q9RGiaovVcasHQBBii658W8kGfKxj65m9Sl3XbqHQBBGKONZueEfOaOdvkuDBdeWpIsYNB1JvqkCc4va)eQJbM2c5MZVJobmIzBeOna7pH6yGPqY8h4LjJxgpyKt8tYNB1JvqkCc4va)eQJbM2c5MZygufWiMTrGxMS6)kLE2L74aORCIFGij65m9Sl3Xbq7Hij65m9Sl3XbqXd1VcIa(P8ZRawqELONZ0ZUChhafQUTHKp3QhRGu4eWRa(juhdmTfYnVFORu)feVd1aVmz1)vkD)qxP(liEhQ0voXpqjFUvpwbPWjGxb8tOogyAlKBgQmmAJTWHd8YKv)xPuOYWOn2chMUYj(bk5ZT6Xkifob8kGFc1XatBHCZZgXUcqaJy2gbEzYQ)Ru6SrSRaeWiMTbDLt8dePLXEqgcl67bDbrhdvkEO(vqeqgWcIegU)fQJbMcP2i)kXFarADfacAnECuFpuXmusqow5nsy4(xOogykKAJ8Re)beP1vaKGCRiBJuCVwMHbgD2i2GcwwaGNRcyVah(ka6qC)cdhy84e9CMoBeBqbllaWZvbSxGdFfaTh2UKp3QhRGu4eWRa(juhdmTfYn)Eqxq0XqnWltUnIEotr4vGcGouPq1Tnqa)ikKKs0ZzkXZyGFhQ0Ey7XJt0Zz67bDbSJbgThk5ZT6Xkifob8kGFc1XatBHCZVh0feDmud8YKv)xP0zJyxbiGrmBd6kN4hisIEotNnIDfGagXSnO9qKWW9VqDmWui1g5xj(disRRaqqRs(CREScsHtaVc4NqDmW0wi38CSgH4U3ybEzYQ)Ru6SrSRaeWiMTbDLt8dejrpNPZgXUcqaJy2g0Eisy4(xOogykKAJ8Re)beP1vaKGCRs(CREScsHtaVc4NqDmW0wi38FarADfGGG9AGxMmrpNPqLHrBSfomThk5ZT6Xkifob8kGFc1XatBHCZZXAeI7EJf4Ljt0Zz6SrSbfSSaapxfWEbo8va0EOKp3QhRGu4eWRa(juhdmTfYnphRrcyeZ2iWltggU)fQJbMcP2i)kXFarADfacAfjQVhQygkjihR8gzBe9CMIWRafaDOsHQBBGGw5D84O(EOIzOKGxY72JhVnCVwMHbgD2i2GcwwaGNRcyVah(ka6qC)cdhissj65mD2i2GcwwaGNRcyVah(kaApS94XX9AzggyueEfimCEJHHI3d6c8GDmWk7OdX9lmCGs(CREScsHtaVc4NqDmW0wi38CSgH4U3ybEzYTbd3)c1XatHuBKFL4pGiTUcGe83oY2ifKP087OtaJy2gu8Y4bJCIFTl5ZT6Xkifob8kGFc1XatBHCZ2i)kXFarADfqGxMSB1l4eRg6nij4hz4ukuzyuX(HUs9N6w9coKe9CMs8mg43HkThk5ZT6Xkifob8kGFc1XatBHCZ)beP1vacc2RbEzYHtPqLHrf7h6k1FQB1l4qs0ZzkXZyGFhQ0EOKp3QhRGu4eWRa(juhdmTfYn)Eqxq0XqnWltMONZuhAxb6LD0EOKp3QhRGu4eWRa(juhdmTfYn)Eqxq0XqnWlt2YypidHLap3Qs(CREScsHtaVc4NqDmW0wi387bDbrhd1aVmzlJ9Gmewc8CRI0g5yGbjH6)kLoBetWYcnAI9dDLcPRCIFGs(CREScsHtaVc4NqDmW0wi3CgZGQagXSnc8YKv)xP0ZUChhaDLt8dejrpNPND5ooaApuYNB1JvqkCc4va)eQJbM2c5MTr(vIihhCqvYNB1JvqkCc4va)eQJbM2c5MZ)GrwSN1aVmziR)exbsdYExVFci7dUsrskrpNPbzVR3pbK9bxPIOoQxSdK2dd8kDyCpufhk6apxhz(d8kDyCpufapJWFY8h4v6W4EOkUmziR)exbsdYExVFci7dUsL85w9yfKcNaEfWpH6yGPTqUzO66zfGh0g5yGf4LjR(VsPq11ZkapOnYXaJUYj(bk5ZT6Xkifob8kGFc1XatBHCZZXAKy)qxP(h4LjtQ6)kLgIpu)f7h6k1)dQ0voXpW4Xv)xP0q8H6Vy)qxP(FqLUYj(bISnsdNsHkdJk2p0vQ)u3QxW1UKp3QhRGu4eWRa(juhdmTfYnBJ8Re)beP1vabEzYUvVGtSAO3GKGFKTbd3)c1XatHuBKFL4pGiTUcGe8hpomC)luhdmfsFpOliMJsc(BxYNB1JvqkCc4va)eQJbM2c5M)disRRaeeSxL85w9yfKcNaEfWpH6yGPTqU587OtaJy2gbIYcEfaz(d0gG9NqDmWuiz(d8YKXlJhmYj(j5ZT6Xkifob8kGFc1XatBHCZ53rNagXSnceLf8kaY8h4LjJYco0vkf8GQx2rIyvYNB1JvqkCc4va)eQJbM2c5MZygufWiMTrGOSGxbqMFjFs(CREScsHxb8tOogyk5)aI06kabb71aVm52i65mfQmmAJTWHP4H6xbraCQEfaKcv32qq0Z5H5valiVs0Zzkuzy0gBHdtHQBB0UKp3QhRGu4va)eQJbM2c5MZygufWiMTrGxMS6)kLE2L74aORCIFGij65m9Sl3Xbq7Hij65m9Sl3XbqXd1VcIa4u9kaifQUTHGONZdZRawqELONZ0ZUChhafQUTHKp3QhRGu4va)eQJbM2c5MZVJobmIzBeOna7pH6yGPqY8h4Lj3gP6zBCfq84GmLMFhDcyeZ2GIhQFfebKbSGXJR(VsPo0Uc0l7ORCIFGibzkn)o6eWiMTbfpu)kicAZYypidHf1H2vGEzhfpu)kyle9CM6q7kqVSJc2XUESQDKwg7bziSOo0Uc0l7O4H6xbraj1oY2i65m99GUa2XaJ2dJhNuIEotjEgd87qL2dBxYNB1Jvqk8kGFc1XatBHCZ53rNagXSnc0gG9NqDmWuiz(d8YKj65mneFOmm45VaHEWr7HiXlJhmYj(j5ZT6XkifEfWpH6yGPTqUzhAxb6LDbEzYQ)RuQdTRa9Yo6kN4hiY20dDKGCSY74Xj65mL4zmWVdvApSDKTzzShKHWI(Eqxq0XqLIhQFfKe8UDKTrQ6)kLE2L74aORCIFGXJtkrpNPND5ooaApejPwg7bziSOND5ooaApSDjFUvpwbPWRa(juhdmTfYn)Eqxq0XqnWltMONZ03d6cyhdmApezB4ETmddmkcVcegoVXWqX7bDbEWogyLD0H4(fgoW4XjLONZuuhQdlyzHgnX(HUsH0Eis1)vkf1H6WcwwOrtSFORuiDLt8dSDjFUvpwbPWRa(juhdmTfYnVFORu)feVd1aVmz1)vkD)qxP(liEhQ0voXpqKTH67HkMHIaejE3ossj65m1H2vGEzhThk5ZT6XkifEfWpH6yGPTqUzOYWOn2choWltw9FLsHkdJ2ylCy6kN4hiY2W(bkwWvk1bbHulRxkcID84y)afl4kL6GGq6vKGK5D7iBd13dvmdfbKej1UKp3QhRGu4va)eQJbM2c5MNnIDfGagXSnc8YKv)xP0zJyxbiGrmBd6kN4hislJ9Gmew03d6cIogQu8q9RGiGmGfuYNB1Jvqk8kGFc1XatBHCZVh0feDmud8YKv)xP0zJyxbiGrmBd6kN4hisIEotNnIDfGagXSnO9qjFUvpwbPWRa(juhdmTfYn)hI7hOa1bqDHY0Hg4LjR(VsP)H4(bkqDauxOmDO0voXpqjFUvpwbPWRa(juhdmTfYnphRriU7nwGxMmrpNPZgXguWYca8Cva7f4Wxbq7Hiv)xPuuhQdlyzHgnX(HUsH0voXpqKe9CMI6qDybll0Oj2p0vkK2dL85w9yfKcVc4NqDmW0wi38FarADfGGG9AGxMmrpNPqLHrBSfomThIKONZuuhQdlyzHgnX(HUsH0EisuFpuXmueeR8wYNB1Jvqk8kGFc1XatBHCZZXAeI7EJf4Ljt0Zz6SrSbfSSaapxfWEbo8va0EiY2u)xPuuhQdlyzHgnX(HUsH0voXpqKTr0ZzkQd1HfSSqJMy)qxPqApmEClJ9Gmew03d6cIogQu8q9RGKG3ir99qfZqjbzEzRXJdd3)c1XatHuBKFL4pGiTUcabTIKONZuOYWOn2chM2drAzShKHWI(Eqxq0XqLIhQFfebKbSGThpoPQ)RukQd1HfSSqJMy)qxPq6kN4hy84wg7bziSO7h6k1FbX7qLIhQFfebKHt1RaGuO62gcIEopmVcyb51wBxYNB1Jvqk8kGFc1XatBHCZZXAeI7EJf4Ljdd3)c1XatHuBKFL4pGiTUcGe8JKuqMsZVJobmIzBqXlJhmYj(HKuCVwMHbgD2i2GcwwaGNRcyVah(ka6qC)cdhiY2iv9FLsrDOoSGLfA0e7h6kfsx5e)aJhNONZuuhQdlyzHgnX(HUsH0Ey84wg7bziSOVh0feDmuP4H6xbjbVrI67HkMHscY8YwBxYNB1Jvqk8kGFc1XatBHCZZXAKagXSnc8YKX9AzggyueEfimCEJHHI3d6c8GDmWk7OdX9lmCGij65m1H2vGEzhThk5ZT6XkifEfWpH6yGPTqU53d6cIogQbEzYwg7bziSe45wfzBKs0ZzkQd1HfSSqJMy)qxPqApejrpNPND5ooaApSDjFUvpwbPWRa(juhdmTfYn)Eqxq0XqnWlt2YypidHLap3QiTrogyqsO(VsPZgXeSSqJMy)qxPq6kN4hissj65m9Sl3Xbq7Hs(CREScsHxb8tOogyAlKB(9GUGOJHAGxMS6)kLoBetWYcnAI9dDLcPRCIFGijLONZuuhQdlyzHgnX(HUsH0EisuFpuXmusqMK5nssj65mD2i2GcwwaGNRcyVah(kaApuYNB1Jvqk8kGFc1XatBHCZZXAKagXSnc8YKBd3RLzyGrNnInOGLfa45Qa2lWHVcGoe3VWWbgpomC)luhdmfsTr(vI)aI06kae0A7iBt9FLsrDOoSGLfA0e7h6kfsx5e)arskrpNPZgXguWYca8Cva7f4Wxbq7HiBJONZuuhQdlyzHgnX(HUsH0Ey84O(EOIzOKGmVS14XHH7FH6yGPqQnYVs8hqKwxbGGwrs0Zzkuzy0gBHdt7HiTm2dYqyrFpOli6yOsXd1VcIaYawW2JhNu1)vkf1H6WcwwOrtSFORuiDLt8dmEClJ9Gmew09dDL6VG4DOsXd1VcIaYWP6vaqkuDBdbrpNhMxbSG8ARTl5ZT6XkifEfWpH6yGPTqU5mMbvbmIzBe4LjR(VsPND5ooa6kN4his1)vkf1H6WcwwOrtSFORuiDLt8dejrpNPND5ooaApejrpNPOouhwWYcnAI9dDLcP9qjFUvpwbPWRa(juhdmTfYn)Eqxq0XqnWltMONZuhAxb6LD0EOKp3QhRGu4va)eQJbM2c5MFpOli6yOg4LjBzShKHWsGNBvKKQ(VsPOouhwWYcnAI9dDLcPRCIFGs(CREScsHxb8tOogyAlKB(Sl3Xbe4LjR(VsPND5ooa6kN4hissBd13dvmdLeXMKrAzShKHWI(Eqxq0XqLIhQFfebK5D7s(CREScsHxb8tOogyAlKBoJzqvaJy2gbEzYQ)Ru6zxUJdGUYj(bIKONZ0ZUChhaThISnIEotp7YDCau8q9RGiaWcYRKeVs0Zz6zxUJdGcv32iECIEotHkdJ2ylCyApmECsv)xPuuhQdlyzHgnX(HUsH0voXpW2L85w9yfKcVc4NqDmW0wi387bDbrhdvjFUvpwbPWRa(juhdmTfYnNFhDcyeZ2iqBa2Fc1XatHK5pWltgVmEWiN4NKp3QhRGu4va)eQJbM2c5MZygufWiMTrGxMmUxlZWaJUFORu)fdX97pc81rPdX9lmCGijLONZ09dDL6VyiUF)rGVoQaCe9CM2drsQ6)kLUFORu)feVdv6kN4hissv)xP0zJyxbiGrmBd6kN4hOKp3QhRGu4va)eQJbM2c5MZ)GrwSN1aVmziR)exbsdYExVFci7dUsrskrpNPbzVR3pbK9bxPIOoQxSdK2dd8kDyCpufhk6apxhz(d8kDyCpufapJWFY8h4v6W4EOkUmziR)exbsdYExVFci7dUsL85w9yfKcVc4NqDmW0wi3SnYVse54GdQs(CREScsHxb8tOogyAlKBoJzqvaJy2gbEzYQ)Ru6zxUJdGUYj(bIKONZ0ZUChhaThk5ZT6XkifEfWpH6yGPTqUzO66zfGh0g5yGf4LjR(VsPq11ZkapOnYXaJUYj(bk5ZT6XkifEfWpH6yGPTqU55ynsSFORu)d8YKjv9FLsdXhQ)I9dDL6)bv6kN4hy84KgoLMp8e7h6k1FQB1l4K85w9yfKcVc4NqDmW0wi3SnYVs8hqKwxbe4Ljdd3)c1XatHuBKFL4pGiTUcGe8l5ZT6XkifEfWpH6yGPTqU5)aI06kabb7vjFUvpwbPWRa(juhdmTfYnNFhDcyeZ2iquwWRaiZFG2aS)eQJbMcjZFGxMmEz8GroXpjFUvpwbPWRa(juhdmTfYnNFhDcyeZ2iquwWRaiZFGxMmkl4qxPuWdQEzhjIvjFUvpwbPWRa(juhdmTfYnNXmOkGrmBJarzbVcGm)s(CREScsHxb8tOogyAlKBoJzqvaJy2gbEzYQ)Ru6zxUJdGUYj(bIKONZ0ZUChhaThIKONZ0ZUChhafpu)kicGt1RaGuO62gcIEopmVcyb5vIEotp7YDCauO62ggUGddpwz4PvE3AR8o28ownCi0X1vaqdxSaXcr0GheDEq0mwsMKPMIMmDOHmSktzgwM4fWRa(juhdmLxit4H4(HhOmbzOtM8UYqDDGYKnYlGbPs(qeC1KPw5LXsYuSmRcoSoqzIxaz9N4kqkIqEHmPmzIxaz9N4kqkIq6kN4hiVqMAJ)yX2Ps(K8flqSqen4brNhenJLKjzQPOjthAidRYuMHLjEriEwgkHR8czcpe3p8aLjidDYK3vgQRduMSrEbmivYhIGRMm1ASKmflZQGdRduM4fqw)jUcKIiKxitktM4fqw)jUcKIiKUYj(bYlKP24pwSDQKpebxnzQ1yjzkwMvbhwhOmXlGS(tCfifriVqMuMmXlGS(tCfifriDLt8dKxitUktiIqepIazQn(JfBNk5tYxSaXcr0GheDEq0mwsMKPMIMmDOHmSktzgwM4fWjGxb8tOogykVqMWdX9dpqzcYqNm5DLH66aLjBKxadsL8Hi4QjtTsYXsYuSmRcoSoqzIxaz9N4kqkIqEHmPmzIxaz9N4kqkIq6kN4hiVqMAJ)yX2Ps(K8HOJgYW6aLjswMCRESsM(dQqQKpdN31ig2WXDO931JvXYypRgU)Gk00KHdEfWpH6yGPMMm8WVPjd3kN4hOjgdNfF6WNB4AtMi65mfQmmAJTWHP4H6xbLjeitWP6vaqkuDBdbrpNhwM4vzcWckt8Qmr0Zzkuzy0gBHdtHQBBitTB4CRESYW9hqKwxbiiyVAudpTAAYWTYj(bAIXWzXNo85go1)vk9Sl3Xbqx5e)aLjKYerpNPND5ooaApuMqkte9CME2L74aO4H6xbLjeitWP6vaqkuDBdbrpNhwM4vzcWckt8Qmr0Zz6zxUJdGcv32WW5w9yLHlJzqvaJy2gg1WtSnnz4w5e)anXy4CRESYWLFhDcyeZ2WWzXNo85gU2KjsLj9SnUcqMIhxMazkn)o6eWiMTbfpu)kOmHaYYeGfuMIhxMu)xPuhAxb6LD0voXpqzcPmbYuA(D0jGrmBdkEO(vqzcbYuBYKLXEqgclQdTRa9YokEO(vqzQfzIONZuhAxb6LDuWo21JvYu7YeszYYypidHf1H2vGEzhfpu)kOmHazIKKP2LjKYuBYerpNPVh0fWogy0EOmfpUmrQmr0ZzkXZyGFhQ0EOm1UHZgG9NqDmWuOHh(nQHhsY0KHBLt8d0eJHZT6Xkdx(D0jGrmBddNfF6WNB4i65mneFOmm45VaHEWr7HYeszcVmEWiN4NHZgG9NqDmWuOHh(nQHhs20KHBLt8d0eJHZIpD4ZnCQ)RuQdTRa9Yo6kN4hOmHuMAtM0dDYejiltXkVLP4XLjIEotjEgd87qL2dLP2LjKYuBYKLXEqgcl67bDbrhdvkEO(vqzIeYeVLP2LjKYuBYePYK6)kLE2L74aORCIFGYu84YePYerpNPND5ooaApuMqktKktwg7bziSOND5ooaApuMA3W5w9yLHZH2vGEzNrn8eRMMmCRCIFGMymCw8PdFUHJONZ03d6cyhdmApuMqktTjt4ETmddmkcVcegoVXWqX7bDbEWogyLD0H4(fgoqzkECzIuzIONZuuhQdlyzHgnX(HUsH0EOmHuMu)xPuuhQdlyzHgnX(HUsH0voXpqzQDdNB1JvgU3d6cIogQg1WdIKPjd3kN4hOjgdNfF6WNB4u)xP09dDL6VG4DOsx5e)aLjKYuBYeQVhQygQmHazcrI3Yu7YeszIuzIONZuhAxb6LD0EOHZT6Xkd3(HUs9xq8ounQHheLPjd3kN4hOjgdNfF6WNB4u)xPuOYWOn2chMUYj(bktiLP2KjSFGIfCLsDqqi1Y6LktiqMITmfpUmH9duSGRuQdccPxjtKqMizEltTltiLP2KjuFpuXmuzcbYejrsYu7go3QhRmCqLHrBSfoSrn8Wlnnz4w5e)anXy4S4th(CdN6)kLoBe7kabmIzBqx5e)aLjKYKLXEqgcl67bDbrhdvkEO(vqzcbKLjalOHZT6Xkd3SrSRaeWiMTHrn8WpVnnz4w5e)anXy4S4th(CdN6)kLoBe7kabmIzBqx5e)aLjKYerpNPZgXUcqaJy2g0EOHZT6Xkd37bDbrhdvJA4HF(nnz4w5e)anXy4S4th(CdN6)kL(hI7hOa1bqDHY0Hsx5e)anCUvpwz4(dX9duG6aOUqz6qnQHh(B10KHBLt8d0eJHZIpD4ZnCe9CMoBeBqbllaWZvbSxGdFfaThktiLj1)vkf1H6WcwwOrtSFORuiDLt8duMqkte9CMI6qDybll0Oj2p0vkK2dnCUvpwz4MJ1ie39gZOgE4p2MMmCRCIFGMymCw8PdFUHJONZuOYWOn2chM2dLjKYerpNPOouhwWYcnAI9dDLcP9qzcPmH67HkMHktiqMIvEB4CRESYW9hqKwxbiiyVAudp8tsMMmCRCIFGMymCw8PdFUHJONZ0zJydkyzbaEUkG9cC4RaO9qzcPm1MmP(VsPOouhwWYcnAI9dDLcPRCIFGYeszQnzIONZuuhQdlyzHgnX(HUsH0EOmfpUmzzShKHWI(Eqxq0XqLIhQFfuMiHmXBzcPmH67HkMHktKGSmXlBvMIhxMGH7FH6yGPqQnYVs8hqKwxbitiqMAvMqkte9CMcvggTXw4W0EOmHuMSm2dYqyrFpOli6yOsXd1VcktiGSmbybLP2LP4XLjsLj1)vkf1H6WcwwOrtSFORuiDLt8duMIhxMSm2dYqyr3p0vQ)cI3Hkfpu)kOmHaYYeCQEfaKcv32qq0Z5HLjEvMaSGYeVktTktTB4CRESYWnhRriU7nMrn8WpjBAYWTYj(bAIXWzXNo85goy4(xOogykKAJ8Re)beP1vaYejKj(LjKYePYeitP53rNagXSnO4LXdg5e)KjKYePYeUxlZWaJoBeBqbllaWZvbSxGdFfaDiUFHHduMqktTjtKktQ)RukQd1HfSSqJMy)qxPq6kN4hOmfpUmr0ZzkQd1HfSSqJMy)qxPqApuMIhxMSm2dYqyrFpOli6yOsXd1VcktKqM4TmHuMq99qfZqLjsqwM4LTktTB4CRESYWnhRriU7nMrn8WFSAAYWTYj(bAIXWzXNo85goCVwMHbgfHxbcdN3yyO49GUapyhdSYo6qC)cdhOmHuMi65m1H2vGEzhThA4CRESYWnhRrcyeZ2WOgE4hrY0KHBLt8d0eJHZIpD4ZnCwg7bziSe45wvMqktTjtKkte9CMI6qDybll0Oj2p0vkK2dLjKYerpNPND5ooaApuMA3W5w9yLH79GUGOJHQrn8WpIY0KHBLt8d0eJHZIpD4ZnCwg7bziSe45wvMqkt2ihdmOmrczs9FLsNnIjyzHgnX(HUsH0voXpqzcPmrQmr0Zz6zxUJdG2dnCUvpwz4EpOli6yOAudp8Zlnnz4w5e)anXy4S4th(CdN6)kLoBetWYcnAI9dDLcPRCIFGYeszIuzIONZuuhQdlyzHgnX(HUsH0EOmHuMq99qfZqLjsqwMizEltiLjsLjIEotNnInOGLfa45Qa2lWHVcG2dnCUvpwz4EpOli6yOAudpTYBttgUvoXpqtmgol(0Hp3W1MmH71YmmWOZgXguWYca8Cva7f4WxbqhI7xy4aLP4XLjy4(xOogykKAJ8Re)beP1vaYecKPwLP2LjKYuBYK6)kLI6qDybll0Oj2p0vkKUYj(bktiLjsLjIEotNnInOGLfa45Qa2lWHVcG2dLjKYuBYerpNPOouhwWYcnAI9dDLcP9qzkECzc13dvmdvMibzzIx2QmfpUmbd3)c1XatHuBKFL4pGiTUcqMqGm1QmHuMi65mfQmmAJTWHP9qzcPmzzShKHWI(Eqxq0XqLIhQFfuMqazzcWcktTltXJltKktQ)RukQd1HfSSqJMy)qxPq6kN4hOmfpUmzzShKHWIUFORu)feVdvkEO(vqzcbKLj4u9kaifQUTHGONZdlt8QmbybLjEvMAvMA3W5w9yLHBowJeWiMTHrn80k)MMmCRCIFGMymCw8PdFUHt9FLsp7YDCa0voXpqzcPmP(VsPOouhwWYcnAI9dDLcPRCIFGYeszIONZ0ZUChhaThktiLjIEotrDOoSGLfA0e7h6kfs7Hgo3QhRmCzmdQcyeZ2WOgEATvttgUvoXpqtmgol(0Hp3Wr0ZzQdTRa9YoAp0W5w9yLH79GUGOJHQrn80ASnnz4w5e)anXy4S4th(CdNLXEqgclbEUvLjKYePYK6)kLI6qDybll0Oj2p0vkKUYj(bA4CRESYW9Eqxq0Xq1OgEALKmnz4w5e)anXy4S4th(CdN6)kLE2L74aORCIFGYeszIuzQnzc13dvmdvMiHmfBswMqktwg7bziSOVh0feDmuP4H6xbLjeqwM4Tm1UHZT6Xkd3zxUJdWOgEALKnnz4w5e)anXy4S4th(CdN6)kLE2L74aORCIFGYeszIONZ0ZUChhaThktiLP2KjIEotp7YDCau8q9RGYecKjalOmXRYejjt8Qmr0Zz6zxUJdGcv32qMIhxMi65mfQmmAJTWHP9qzkECzIuzs9FLsrDOoSGLfA0e7h6kfsx5e)aLP2nCUvpwz4YygufWiMTHrn80ASAAYW5w9yLH79GUGOJHQHBLt8d0eJrn80kIKPjd3kN4hOjgdNB1JvgU87OtaJy2ggol(0Hp3WHxgpyKt8ZWzdW(tOogyk0Wd)g1WtRikttgUvoXpqtmgol(0Hp3WH71YmmWO7h6k1FXqC)(JaFDu6qC)cdhOmHuMivMi65mD)qxP(lgI73Fe4RJkahrpNP9qzcPmrQmP(VsP7h6k1FbX7qLUYj(bktiLjsLj1)vkD2i2vacyeZ2GUYj(bA4CRESYWLXmOkGrmBdJA4PvEPPjd3kN4hOjgdNfF6WNB4GS(tCfini7D9(jGSp4kLUYj(bktiLjsLjIEotdYExVFci7dUsfrDuVyhiThA4Ushg3dvXLnCqw)jUcKgK9UE)eq2hCLA4Ushg3dvXHIoWZ1z443W5w9yLHl)dgzXEwnCxPdJ7HQa4ze(B443OgEInVnnz4CRESYWzJ8Reroo4GQHBLt8d0eJrn8eB(nnz4w5e)anXy4S4th(CdN6)kLE2L74aORCIFGYeszIONZ0ZUChhaThA4CRESYWLXmOkGrmBdJA4j2TAAYWTYj(bAIXWzXNo85go1)vkfQUEwb4bTrogy0voXpqdNB1JvgoO66zfGh0g5yGzudpXo2MMmCRCIFGMymCw8PdFUHJuzs9FLsdXhQ)I9dDL6)bv6kN4hOmfpUmrQmfoLMp8e7h6k1FQB1l4mCUvpwz4MJ1iX(HUs93OgEInjzAYWTYj(bAIXWzXNo85goy4(xOogykKAJ8Re)beP1vaYejKj(nCUvpwz4Sr(vI)aI06kaJA4j2KSPjdNB1JvgU)aI06kabb7vd3kN4hOjgJA4j2XQPjdhkl4vagE43WTYj(jqzbVcWeJHZT6Xkdx(D0jGrmBddNna7pH6yGPqdp8B4S4th(CdhEz8GroXpd3kN4hOjgJA4j2isMMmCRCIFGMymCRCIFcuwWRamXy4S4th(Cdhkl4qxPuWdQEzNmrczkwnCUvpwz4YVJobmIzBy4qzbVcWWd)g1WtSruMMmCOSGxby4HFd3kN4NaLf8katmgo3QhRmCzmdQcyeZ2WWTYj(bAIXOgEInV00KHBLt8d0eJHZIpD4ZnCQ)Ru6zxUJdGUYj(bktiLjIEotp7YDCa0EOmHuMi65m9Sl3XbqXd1VcktiqMGt1RaGuO62gcIEopSmXRYeGfuM4vzIONZ0ZUChhafQUTHHZT6XkdxgZGQagXSnmQrnCGl79xnnz4HFttgUvoXpqtmgoWbT4lupwz4q0lDyCpuLjwwMSouHudNB1JvgoeEfOagnhBudpTAAYWHYcEfGHh(nCRCIFcuwWRamXy4CRESYWbdp8Pi0)gddfay3od3kN4hOjgJA4j2MMmCUvpwz4cz6Xkd3kN4hOjgJA4HKmnz4CRESYW1HtC6qHgUvoXpqtmg1WdjBAYWTYj(bAIXWzXNo85gU2KjsLj1)vkD)qxP(liEhQ0voXpqzQDzcPmrQmPNTXvaYeszIuzkCkfQmmQy)qxP(tDREbNmHuMAtMGH7FH6yGPqQnYVs8hqKwxbitiqMITmfpUmP(VsPOouhwWYcnAI9dDLcPRCIFGYu84YeUxlZWaJcBeabEEJHHI8nCacWHEWrhI7xy4aLP2nCUvpwz4YVJobmIzByudpXQPjd3kN4hOjgdNB1JvgUq8HYWGN)ce6bNHZIpD4ZnCKkte9CMgIpugg88xGqp4O9qzcPm1MmrQmfoLcvggvSFORu)PUvVGtMIhxMGH7FH6yGPqQnYVs8hqKwxbitiqMITmHuMi65mfHxbka6qLcv32qMqGm1kVLP4XLjiR)exbs)5GcIaelw0rd)rx5e)aLP4XLjCVwMHbgfg(xPdpqX(HUsH0H4(fgoqzQDzcPm1Mmbd3)c1XatHuBKFL4pGiTUcqMqGmrYYu84YK6)kLI6qDybll0Oj2p0vkKUYj(bktXJlt4ETmddmkSrae45nggkY3Wbiah6bhDiUFHHduMIhxMGS(tCfi9NdkicqSyrhn8hDLt8duMIhxMW9Azggyuy4FLo8af7h6kfshI7xy4aLP2LjKYePYerpNPWW)kD4bk2p0vkK2dnC2aS)eQJbMcn8WVrn8GizAYWTYj(bAIXWzXNo85gosLj9SnUcqMqktTjtKktHtPqLHrf7h6k1FQB1l4KP4XLjy4(xOogykKAJ8Re)beP1vaYecKPyltiLjIEotr4vGcGouPq1TnKjeitTYBzQDzcPm1Mmbd3)c1XatHuBKFL4pGiTUcqMqGmfBzkECzs9FLsrDOoSGLfA0e7h6kfsx5e)aLP4XLjCVwMHbgf2iac88gddf5B4aeGd9GJoe3VWWbktTB4CRESYWLFhDcyeZ2WOgEquMMmCUvpwz4YhEI9dDL6VHBLt8d0eJrn8Wlnnz4CRESYWHoDmSHBLt8d0eJrn8WpVnnz4w5e)anXy4S4th(CdhPYK6)kL6q7kqVSJUYj(bktXJlte9CM6q7kqVSJ2dLP4XLjlJ9GmewuhAxb6LDu8q9RGYejKjsM3go3QhRmCepJbkYDCag1Wd)8BAYWTYj(bAIXWzXNo85gosLj1)vk1H2vGEzhDLt8duMIhxMi65m1H2vGEzhThA4CRESYWrmmC4gxbyudp83QPjd3kN4hOjgdNfF6WNB4ivMu)xPuhAxb6LD0voXpqzkECzIONZuhAxb6LD0EOmfpUmzzShKHWI6q7kqVSJIhQFfuMiHmrY82W5w9yLHlF4r8mgOrn8WFSnnz4w5e)anXy4S4th(CdhPYK6)kL6q7kqVSJUYj(bktXJlte9CM6q7kqVSJ2dLP4XLjlJ9GmewuhAxb6LDu8q9RGYejKjsM3go3QhRmCEzhuX(lS()g1Wd)KKPjd3kN4hOjgdNfF6WNB4ivMu)xPuhAxb6LD0voXpqzkECzIuzIONZuhAxb6LD0EOHZT6XkdhHdiyzHIpBdOrn8WpjBAYW5w9yLHl4GHdluMoud3kN4hOjgJA4H)y10KHBLt8d0eJHZIpD4ZnCwwWvEP06aIur2NmHuMivMW9Azggyu4giuWYcSJg6LkaWmeQr0H4(fgoqzcPm1MmrQmP(VsPOouhwWYcnAI9dDLcPRCIFGYu84YerpNPOouhwWYcnAI9dDLcP9qzQDzcPmbd3)c1XatHuBKFL4pGiTUcqMqGmfBdNB1JvgUSpHI9cM7WJvg1Wd)isMMmCRCIFGMymCw8PdFUHZYcUYlLwhqKkY(KjKYeUxlZWaJc3aHcwwGD0qVubaMHqnIoe3VWWbktiLP2KjsLj1)vkf1H6WcwwOrtSFORuiDLt8duMIhxMi65mf1H6WcwwOrtSFORuiThktXJltWW9VqDmWui1g5xj(disRRaKjsqwMITm1UmHuMAtMSm2dYqyrZhEI9dDL6pfpu)kOmrczQvEltXJltwg7bziSOqLHrf7h6k1FkEO(vqzIeYuR8wMA3W5w9yLHl7tOyVG5o8yLrn8WpIY0KHBLt8d0eJHZIpD4ZnCUvVGtSAO3GYejKPwLjKYuBYemC)luhdmfsTr(vI)aI06kazIeYuRYu84YemC)luhdmfsFpOliMJktKqMAvMA3Wbv8zvdp8B4CRESYWH7LWT6XkXFq1W9hufLJodNZMrn8WpV00KHBLt8d0eJHZIpD4ZnCKktQ)RukuzyuX(HUs9NUYj(bktiLj3QxWjwn0BqzcbKLPwnCqfFw1Wd)go3QhRmC4EjCRESs8hunC)bvr5OZWbVc4NqDmWuJA4PvEBAYWTYj(bAIXWzXNo85go1)vkfQmmQy)qxP(tx5e)aLjKYKB1l4eRg6nOmHaYYuRgoOIpRA4HFdNB1JvgoCVeUvpwj(dQgU)GQOC0z4GtaVc4NqDmWuJAudxiEwgkHRMMm8WVPjd3kN4hOjgdNB1JvgU5ynsSFORu)nCGdAXxOESYWHikwC2UoqzAbhoazsp0jtA0Kj3QmSmDqzYd637e)Ogol(0Hp3WrQmP(VsPH4d1FX(HUs9)GkDLt8d0OgEA10KHBLt8d0eJHZT6Xkdx(hmYI9SA4ah0IVq9yLHdrCWjtCkdJ2ylCyzkepldLWvzQx)GqzcYqNm5GGqzcH3)Yem0ryjtqgROgol(0Hp3Wbz9N4kqAyhQ9FIH7H6Xk6kN4hOmfpUmbz9N4kqAq2769tazFWvkDLt8d0OgEITPjd3kN4hOjgdNfF6WNB4u)xPuOYWOn2chMUYj(bktiLP2KjSFGIfCLsDqqi1Y6LktiqMITmfpUmH9duSGRuQdccPxjtKqMizEltTB4CRESYWbvggTXw4Wg1WdjzAYW5w9yLHlF4j2p0vQ)gUvoXpqtmg1WdjBAYWTYj(bAIXWzXNo85go1)vkD)qxP(liEhQ0voXpqzcPmbd3)c1XatHuBKFL4pGiTUcqMqGmfBdNB1JvgU9dDL6VG4DOAudpXQPjd3kN4hOjgdNB1JvgU3d6cIogQgU)QjSGgUyB4S4th(CdhPYK6)kLUFORu)feVdv6kN4hOmHuMGH7FH6yGPqQnYVs8hqKwxbitiqMITmfpUmr0Zzkuzy0gBHdt7HgoWbT4lupwz4IzwVdNmHiiymYuKdLjxMuShCVmPh6cuM0OjtoiiRKPW3Tdkt8QgDqzALIdGxLjwjtXYXcktzgwMITmbNLvGqzszYKhKDGYeiRt8drlIGGXitSsMc7)tnQHhejttgUvoXpqtmgol(0Hp3WrQmP(VsP7h6k1FbX7qLUYj(bktiLjy4(xOogykKAJ8Re)beP1vaYejiltXwMqktKkte9CMcvggTXw4W0EOHZT6XkdNnYVs8hqKwxbyudpikttgo3QhRmCHm9yLHBLt8d0eJrnQHZzZ0KHh(nnz4w5e)anXy4S4th(CdhPYu4ukuzyuX(HUs9N6w9codNB1JvgoOYWOI9dDL6Vrn80QPjd3kN4hOjgdNfF6WNB4i65m16)l(disRRaO4H6xbLjsqwM4N3go3QhRmClGjyzHgnbuzyuJA4j2MMmCRCIFGMymCw8PdFUHJONZ0zJyxbiGrmBdAp0W5w9yLHBowJqC3BmJA4HKmnz4CRESYWzJ8Reroo4GQHBLt8d0eJrn8qYMMmCRCIFGMymCw8PdFUHt9FLsHkdJ2ylCy6kN4hOHZT6Xkdhuzy0gBHdBudpXQPjd3kN4hOjgdNB1JvgU87OtaJy2ggol(0Hp3WHxgpyKt8tMqktTjtTjtUvVGtaYuA(D0jGrmBdzcbYuRYeszYT6fCIvd9guMqazzk2YeszYYypidHfneFOmm45VaHEWrXd1VcktiqM4pwLjKYKLfCLxkTMfZEgguMqktKktHtPqLHrf7h6k1FQB1l4KP4XLj3QxWjazkn)o6eWiMTHmHazIFzcPm5w9coXQHEdktKGSmrsYeszIuzkCkfQmmQy)qxP(tDREbNmHuMu)xPuuhQdlyzHgnX(HUsH0voXpqzQDzkECzQnzc3RLzyGrHncGapVXWqr(goab4qp4OdX9lmCGYeszIuzkCkfQmmQy)qxP(tDREbNm1UmfpUm1MmH71YmmWOWW)kD4bk2p0vkKoe3VWWbktiLP2Kj3QxWjazkn)o6eWiMTHmHazk2YeszIuzc3RLzyGrNnInOGLfa45Qa2lWHVcGoe3VWWbktXJltUvVGtaYuA(D0jGrmBdzcbYejjtTltiLP2KjlJ9Gmew0q8HYWGN)ce6bhfpu)kOmHazI)yvMIhxMi65mneFOmm45VaHEWr7HYu7Yu7Yu7goBa2Fc1XatHgE43OgEqKmnz4w5e)anXy4S4th(CdhPYKB1l4eGmLMFhDcyeZ2qMqktKktHtPqLHrf7h6k1FQB1l4KjKYuBYK6)kLI6qDybll0Oj2p0vkKUYj(bktXJlt4ETmddmkSrae45nggkY3Wbiah6bhDiUFHHduMAxMIhxMAtMW9Azggyuy4FLo8af7h6kfshI7xy4aLjKYePYKE2gxbitiLjIEotdXhkddE(lqOhC0EOm1UHZT6Xkdx(D0jGrmBdJA4brzAYWTYj(bAIXWzXNo85go1)vkD2i2vacyeZ2GUYj(bktiLjuFpuXmuzIeKLPyL3YeszQnzc3RLzyGrNnInOGLfa45Qa2lWHVcGoe3VWWbktiLjIEotNnInOGLfa45Qa2lWHVcG2dLP4XLjsLjCVwMHbgD2i2GcwwaGNRcyVah(ka6qC)cdhOm1UHZT6Xkd3SrSRaeWiMTHrn8Wlnnz4w5e)anXy4S4th(CdN6)kL6q7kqVSJUYj(bktiLP2KjsLPWPuOYWOI9dDL6p1T6fCYu7YeszQnzIuzs9FLsp7YDCa0voXpqzkECzIuzIONZ0ZUChhaThktiLjsLjlJ9Gmew0ZUChhaThktTB4CRESYW5q7kqVSZOgE4N3MMmCRCIFGMymCw8PdFUHt9FLs)dX9duG6aOUqz6qPRCIFGgo3QhRmC)H4(bkqDauxOmDOg1Wd)8BAYWTYj(bAIXWzXNo85goy4(xOogykKAJ8Re)beP1vaYecKjssMqkte9CMI6qDybll0Oj2p0vkK2dLjKYeQVhQygQmHazIK5THZT6XkdNnYVs8hqKwxbyudp83QPjd3kN4hOjgdNfF6WNB4W9Azggy0zJydkyzbaEUkG9cC4RaOdX9lmCGYeszIuzIONZ0zJydkyzbaEUkG9cC4RaO9qdNB1JvgU5ynsaJy2gg1Wd)X20KHBLt8d0eJHZIpD4ZnCGmLMFhDcyeZ2GIhQFfuMqktWW9VqDmWui1g5xj(disRRaKjeitKKmHuMAtMivMcNsHkdJk2p0vQ)u3QxWjtTltiLP2KjIEotFpOlGDmWO9qzcPmrQmr0ZzkQd1HfSSqJMy)qxPqApuMqktQ)RukQd1HfSSqJMy)qxPq6kN4hOm1UHZT6Xkd37bDbrhdvJA4HFsY0KHBLt8d0eJHZIpD4ZnCWW9VqDmWui1g5xj(disRRaKjsqwMAvMqktKkt4ETmddm6SrSbfSSaapxfWEbo8va0H4(fgoqzcPm1MmP(VsPOouhwWYcnAI9dDLcPRCIFGYeszc13dvmdvMibzzIK5TmHuMivMi65mf1H6WcwwOrtSFORuiThktTB4CRESYWnhRriU7nMrn8WpjBAYWTYj(bAIXW5w9yLH79GUGOJHQHZIpD4ZnCwwWvEP0Awm7zyqzcPmH71YmmWOZgXguWYca8Cva7f4WxbqhI7xy4aLjKYeCQGGvDivVHBfrjiPqRmHuMi65m99GUa2XaJ2dLjKYePYerpNPH4dLHbp)fi0doAp0WzdW(tOogyk0Wd)g1Wd)XQPjd3kN4hOjgdNB1JvgU3d6cIogQgol(0Hp3Wr0Zz67bDbSJbgThktiLjIEotdXhkddE(lqOhC0EOmHuMAtMi65mneFOmm45VaHEWrXd1VcktiqMITmXRYeGfuMIhxMCREbNaKP087OtaJy2gYezzcgU)fQJbMcP2i)kXFarADfGmfpUm5w9cobitP53rNagXSnKjYYuSLjKYePYeUxlZWaJoBeBqbllaWZvbSxGdFfaDiUFHHduMIhxMCREbNaKP087OtaJy2gYezzIKKP2nC2aS)eQJbMcn8WVrn8WpIKPjd3kN4hOjgdNfF6WNB4azkn)o6eWiMTbfpu)kOmHuMGH7FH6yGPqQnYVs8hqKwxbitiqMijzcPmH71YmmWOWgbqGN3yyOiFdhGaCOhC0H4(fgoqzcPmr0Zz67bDbSJbgThktiLj1)vkf1H6WcwwOrtSFORuiDLt8duMqktKkte9CMI6qDybll0Oj2p0vkK2dLjKYeQVhQygQmrcYYejZBdNB1JvgU3d6cIogQg1Wd)ikttgUvoXpqtmgol(0Hp3WbYuA(D0jGrmBdkEO(vqzcPm1Mm1Mmbd3)c1XatHuBKFL4pGiTUcqMqGmrsYeszc3RLzyGrHncGapVXWqr(goab4qp4OdX9lmCGYeszs9FLsrDOoSGLfA0e7h6kfsx5e)aLP2LP4XLP2Kj1)vkf1H6WcwwOrtSFORuiDLt8duMqktO(EOIzOYejiltKmVLjKYePYerpNPOouhwWYcnAI9dDLcP9qzcPm1MmrQmH71YmmWOZgXguWYca8Cva7f4WxbqhI7xy4aLP4XLjIEotNnInOGLfa45Qa2lWHVcG2dLP2LjKYePYeUxlZWaJcBeabEEJHHI8nCacWHEWrhI7xy4aLP2LP2nCUvpwz4EpOli6yOAudp8Zlnnz4w5e)anXy4S4th(CdhitP53rNagXSnO4H6xbLjKYemC)luhdmfsTr(vI)aI06kazISmrsYeszc3RLzyGrHncGapVXWqr(goab4qp4OdX9lmCGYeszIONZ03d6cyhdmApuMqktQ)RukQd1HfSSqJMy)qxPq6kN4hOmHuMivMi65mf1H6WcwwOrtSFORuiThktiLjuFpuXmuzIeKLjsM3go3QhRmCVh0feDmunQHNw5TPjd3kN4hOjgdNfF6WNB4GH7FH6yGPqQnYVs8hqKwxbitKGSm1QHZT6Xkd3CSgH4U3yg1WtR8BAYWTYj(bAIXWzXNo85goIEotHkdJ2ylCykEO(vqzcbYuSLjEvMaSGYeVkte9CMcvggTXw4WuO62ggo3QhRmC2i)kXFarADfGrn80ARMMmCRCIFGMymCUvpwz4EpOli6yOA4S4th(CdhCQGGvDivVHBfrjiPqRmHuMi65m99GUa2XaJ2dLjKYePYerpNPH4dLHbp)fi0doAp0WzdW(tOogyk0Wd)g1WtRX20KHBLt8d0eJHZIpD4ZnCWPccw1Hu9gUveLGKcTYeszIONZ03d6cyhdmApuMqktKkte9CMgIpugg88xGqp4O9qdNB1JvgU3d6cIogQg1WtRKKPjd3kN4hOjgdNfF6WNB4i65m99GUa2XaJ2dLjKYemC)luhdmfsTr(vI)aI06kazcbYejjtiLP2KjsLPWPuOYWOI9dDL6p1T6fCYu7YeszcKP087OtaJy2gu9SnUcWW5w9yLH79GUGOJHQrn80kjBAYWTYj(bAIXWzXNo85go1)vkD)qxP(liEhQ0voXpqzcPmbd3)c1XatHuBKFL4pGiTUcqMqGmrYYeszQnzIuzkCkfQmmQy)qxP(tDREbNm1UHZT6Xkd3(HUs9xq8ounQHNwJvttgUvoXpqtmgol(0Hp3WP(VsPo0Uc0l7ORCIFGgo3QhRmCVh0feZrnQHNwrKmnz4CRESYWzJ8Re)beP1vagUvoXpqtmg1WtRikttgUvoXpqtmgUvoXpbkl4vaMymCw8PdFUHJONZ03d6cyhdmApuMqktwg7bziSe45w1W5w9yLH79GUGOJHQHdLf8kadp8BudpTYlnnz4qzbVcWWd)gUvoXpbkl4vaMymCUvpwz4YVJobmIzBy4Sby)juhdmfA4HFdNfF6WNB4WlJhmYj(z4w5e)anXyudpXM3MMmCOSGxby4HFd3kN4NaLf8katmgo3QhRmCzmdQcyeZ2WWTYj(bAIXOg1WbNaEfWpH6yGPMMm8WVPjd3kN4hOjgdNfF6WNB4ivMcNsHkdJk2p0vQ)u3QxWz4CRESYWbvggvSFORu)nQHNwnnz4w5e)anXy4S4th(CdhrpNPWogycwweYq4W0EOHZT6Xkd3FarADfGGG9Qrn8eBttgUvoXpqtmgo3QhRmCH4dLHbp)fi0dodNfF6WNB4SSGR8sP1Sy2ZWGYeszIuzIONZ0q8HYWGN)ce6bhThktiLjsLjIEotHH)v6WduSFORuiThA4Sby)juhdmfA4HFJA4HKmnz4w5e)anXy4S4th(CdhrpNPw)FXFarADfafpu)kOmrcYYe)82W5w9yLHBbmbll0OjGkdJAudpKSPjd3kN4hOjgdNfF6WNB4u)xP0ZUChhaDLt8duMqkte9CME2L74aO9qzcPmr0Zz6zxUJdGIhQFfuMqGmbNQxbaPq1Tnee9CEyzIxLjalOmXRYerpNPND5ooakuDBdzcPmr0ZzkcVcua0HkfQUTHmHazIFeLHZT6XkdxgZGQagXSnmQHNy10KHBLt8d0eJHZT6Xkdx(D0jGrmBddNfF6WNB4WlJhmYj(z4Sby)juhdmfA4HFJA4brY0KHBLt8d0eJHZIpD4ZnCQ)Ru6zxUJdGUYj(bktiLjIEotp7YDCa0EOmHuMi65m9Sl3XbqXd1VcktiqM4NYVmXRYeGfuM4vzIONZ0ZUChhafQUTHHZT6XkdxgZGQagXSnmQHheLPjd3kN4hOjgdNfF6WNB4u)xP09dDL6VG4DOsx5e)anCUvpwz42p0vQ)cI3HQrn8Wlnnz4w5e)anXy4S4th(CdN6)kLcvggTXw4W0voXpqdNB1JvgoOYWOn2ch2OgE4N3MMmCRCIFGMymCw8PdFUHt9FLsNnIDfGagXSnORCIFGYeszYYypidHf99GUGOJHkfpu)kOmHaYYeGfuMqktWW9VqDmWui1g5xj(disRRaKjeitTktXJltO(EOIzOYejiltXkVLjKYemC)luhdmfsTr(vI)aI06kazIeKLPwLjKYuBYePYeUxlZWaJoBeBqbllaWZvbSxGdFfaDiUFHHduMIhxMi65mD2i2GcwwaGNRcyVah(kaApuMA3W5w9yLHB2i2vacyeZ2WOgE4NFttgUvoXpqtmgol(0Hp3W1Mmr0ZzkcVcua0HkfQUTHmHazIFeLmHuMivMi65mL4zmWVdvApuMAxMIhxMi65m99GUa2XaJ2dnCUvpwz4EpOli6yOAudp83QPjd3kN4hOjgdNfF6WNB4u)xP0zJyxbiGrmBd6kN4hOmHuMi65mD2i2vacyeZ2G2dLjKYemC)luhdmfsTr(vI)aI06kazcbYuRgo3QhRmCVh0feDmunQHh(JTPjd3kN4hOjgdNfF6WNB4u)xP0zJyxbiGrmBd6kN4hOmHuMi65mD2i2vacyeZ2G2dLjKYemC)luhdmfsTr(vI)aI06kazIeKLPwnCUvpwz4MJ1ie39gZOgE4NKmnz4w5e)anXy4S4th(CdhrpNPqLHrBSfomThA4CRESYW9hqKwxbiiyVAudp8tYMMmCRCIFGMymCw8PdFUHJONZ0zJydkyzbaEUkG9cC4RaO9qdNB1JvgU5yncXDVXmQHh(JvttgUvoXpqtmgol(0Hp3Wbd3)c1XatHuBKFL4pGiTUcqMqGm1QmHuMq99qfZqLjsqwMIvEltiLP2KjIEotr4vGcGouPq1TnKjeitTYBzkECzc13dvmdvMiHmXl5Tm1UmfpUm1MmH71YmmWOZgXguWYca8Cva7f4WxbqhI7xy4aLjKYePYerpNPZgXguWYca8Cva7f4Wxbq7HYu7Yu84YeUxlZWaJIWRaHHZBmmu8EqxGhSJbwzhDiUFHHd0W5w9yLHBowJeWiMTHrn8WpIKPjd3kN4hOjgdNfF6WNB4AtMGH7FH6yGPqQnYVs8hqKwxbitKqM4xMAxMqktTjtKktGmLMFhDcyeZ2GIxgpyKt8tMA3W5w9yLHBowJqC3BmJA4HFeLPjd3kN4hOjgdNfF6WNB4CREbNy1qVbLjsit8ltiLPWPuOYWOI9dDL6p1T6fCYeszIONZuINXa)ouP9qdNB1JvgoBKFL4pGiTUcWOgE4NxAAYWTYj(bAIXWzXNo85gUWPuOYWOI9dDL6p1T6fCYeszIONZuINXa)ouP9qdNB1JvgU)aI06kabb7vJA4PvEBAYWTYj(bAIXWzXNo85goIEotDODfOx2r7Hgo3QhRmCVh0feDmunQHNw530KHBLt8d0eJHZIpD4ZnCwg7bziSe45w1W5w9yLH79GUGOJHQrn80ARMMmCRCIFGMymCw8PdFUHZYypidHLap3QYeszYg5yGbLjsitQ)Ru6Srmbll0Oj2p0vkKUYj(bA4CRESYW9Eqxq0Xq1OgEAn2MMmCRCIFGMymCw8PdFUHt9FLsp7YDCa0voXpqzcPmr0Zz6zxUJdG2dnCUvpwz4YygufWiMTHrn80kjzAYW5w9yLHZg5xjICCWbvd3kN4hOjgJA4Pvs20KHBLt8d0eJHZIpD4ZnCqw)jUcKgK9UE)eq2hCLsx5e)aLjKYePYerpNPbzVR3pbK9bxPIOoQxSdK2dnCxPdJ7HQ4YgoiR)exbsdYExVFci7dUsnCxPdJ7HQ4qrh456mC8B4CRESYWL)bJSypRgUR0HX9qva8mc)nC8BudpTgRMMmCRCIFGMymCw8PdFUHt9FLsHQRNvaEqBKJbgDLt8d0W5w9yLHdQUEwb4bTrogyg1WtRisMMmCRCIFGMymCw8PdFUHJuzs9FLsdXhQ)I9dDL6)bv6kN4hOmfpUmP(VsPH4d1FX(HUs9)GkDLt8duMqktTjtKktHtPqLHrf7h6k1FQB1l4KP2nCUvpwz4MJ1iX(HUs93OgEAfrzAYWTYj(bAIXWzXNo85go3QxWjwn0BqzIeYe)YeszQnzcgU)fQJbMcP2i)kXFarADfGmrczIFzkECzcgU)fQJbMcPVh0feZrLjsit8ltTB4CRESYWzJ8Re)beP1vag1WtR8sttgo3QhRmC)beP1vacc2RgUvoXpqtmg1WtS5TPjdhkl4vagE43WTYj(jqzbVcWeJHZT6Xkdx(D0jGrmBddNna7pH6yGPqdp8B4S4th(CdhEz8GroXpd3kN4hOjgJA4j28BAYWTYj(bAIXWTYj(jqzbVcWeJHZIpD4ZnCOSGdDLsbpO6LDYejKPy1W5w9yLHl)o6eWiMTHHdLf8kadp8BudpXUvttgouwWRam8WVHBLt8tGYcEfGjgdNB1JvgUmMbvbmIzBy4w5e)anXyuJAuJAuJb]] )

end
