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

        fleshcraft = {
            id = 324631,
            duration = 120,
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

    spec:RegisterPack( "Elemental", 20220306, [[dG0FrcqiurpcisTjG6tOkWOev5uIQAvOk0RevAwcOBbevAxi9lrfddvrhdvvltuQNjuQPHkKRHkuBtOK(gqenoGOCoHs06ekbZdiCpuP9bK6GOkiTqHIhkucnrufeDrGiXhbIk6KarvRevLzceb3eisYorv6Nars1sbIk8uenvrjxfiskFfvbHXceH2lf)LWGf5WuTyeEmLMmexwzZs5ZagTGoTkVwumBvDBiTBj)gLHlKJJky5q9CqtN01LQTlqFhiz8OkOoVamFHQ9t0g(nzzirCDgEZMNzNnpJnpJvk)GKzND2GmdPgq0mKrUnJdmdz5OZqcs5h6k1FdzKhWZCetwgsiRJTZqgQAemwiNCaonStqTm0CGhA)D9yLf7nnh4HAZXqs0Vxb5ldHHeX1z4nBEMD28m28mwP8dsMD2zhRgsy0SgEZowZ2qgEiiRmegsKbTgsqk)qxP(ltKHoQxs(aPYX2qzkwduMYMNzNTKpjFXIHEbmySGKpqUYeiFzz4ig21jtWP6vaqkuDBgbrV1gwMAmSmbYBxRJdiqzIuzy0mBrdtL8bYvM4HIGitGunDmSm5fImbsjGjtSMmPHtMivggvMCa)kQHmcZA3pdjiniTmbs5h6k1FzIm0r9sYhiniTmbsLJTHYuSgOmLnpZoBjFs(aPbPLPyXqVagmwqYhiniTmbYvMa5lldhXWUozcovVcasHQBZii6T2WYuJHLjqE7ADCabktKkdJMzlAyQKpqAqAzcKRmXdfbrMaPA6yyzYlezcKsatMynzsdNmrQmmQm5a(vujFs(aPLjqk8WZ21Hitl4Wbit6HozsdNm5wLHLPdktEq)EN4hvYNB1JvqAeEwgkHRCNJ1qX(HUs9pWRXLt1)vkncFO(l2p0vQ)huPRCIFis(aPLjqQbNmrQmmAMTOHLPi8SmucxLPE9dcLjidDYKJGaLjqD)ltWihuLmbzSIk5ZT6XkincpldLW1C5Mt7hm0I9Mg414cz9N4keAuhQ9FIH7r6XQ4XHS(tCfcni7D9(jGSp4kvYNB1JvqAeEwgkHR5YnhOYWOz2IgoWRXv9FLsHkdJMzlAy6kN4hc48W(HiwWvk1rqGulRxkiID84y)qel4kL6iiq6vGMJ5z(s(CREScsJWZYqjCnxU50o8e7h6k1FjFUvpwbPr4zzOeUMl3C2p0vQ)cI3HAGxJR6)kLUFORu)feVdv6kN4hcyy0(xOogykKAd9Re)beQ1vaGi2s(aPLPyM17WjtGecgJmf6qzYLjf7b3lt6HUaLjnCYKJGWkzk6D7GYepQHhuMwP4a4rzIvYuSipKYuJHLPyltWzzfcuMuMm5bzhImHW6e)a5csiymYeRKPO()ujFUvpwbPr4zzOeUMl3CEpOli6yOg4F1eweUXoWRXLt1)vkD)qxP(liEhQ0voXpeWWO9VqDmWui1g6xj(diuRRaarSJhNO3AuOYWOz2IgM2JK85w9yfKgHNLHs4AUCZXg6xj(diuRRac8AC5u9FLs3p0vQ)cI3HkDLt8dbmmA)luhdmfsTH(vI)ac16kaqZn2G5KO3AuOYWOz2IgM2JK85w9yfKgHNLHs4AUCZjIPhRK8j5dKwMa5lDyCpsLjwtMSouHujFUvpwbZLBoG6kebmCowYNB1JvWC5Mdm6WNck)ZmmuaGD7ceLf8kaU8l5ZT6XkyUCZjIPhRK85w9yfmxU50HtC6qHs(CREScMl3CAVJobmKzZe414MhNQ)Ru6(HUs9xq8ouPRCIFi5dMt9SzUcamNrtPqLHrf7h6k1FQB1l4aNhmA)luhdmfsTH(vI)ac16kaqe74Xv)xPuuhQdlynHgoX(HUsH0voXpK4XX9AnggyuyMaiWZZmmu0UHdqGm0do64q)IIgs(s(CREScMl3CIWhkdJC(laLhCbAdW(tOogykKl)bEnUCs0BnAe(qzyKZFbO8GJ2JaNhNrtPqLHrf7h6k1FQB1l4IhhgT)fQJbMcP2q)kXFaHADfaiInyIERrb1vicGouPq1Tzar28mECiR)exHq)5icIaeJh2rJ(rx5e)qIhh3R1yyGrHr)v6WdrSFORuiDCOFrrdjFW5bJ2)c1XatHuBOFL4pGqTUcaeCC84Q)RukQd1HfSMqdNy)qxPq6kN4hs844ETgddmkmtae45zggkA3Wbiqg6bhDCOFrrdjECiR)exHq)5icIaeJh2rJ(rx5e)qIhh3R1yyGrHr)v6WdrSFORuiDCOFrrdjFWCs0Bnkm6VshEiI9dDLcP9ijFUvpwbZLBoT3rNagYSzc8AC5upBMRaaNhNrtPqLHrf7h6k1FQB1l4IhhgT)fQJbMcP2q)kXFaHADfaiInyIERrb1vicGouPq1Tzar28mFW5bJ2)c1XatHuBOFL4pGqTUcaeXoEC1)vkf1H6WcwtOHtSFORuiDLt8djECCVwJHbgfMjac88mddfTB4aeid9GJoo0VOOHKVKp3QhRG5YnN2HNy)qxP(l5ZT6XkyUCZbD6yyjFUvpwbZLBoepJHiADCabEnUCQ(VsPo0UcXl7ORCIFiXJt0BnQdTRq8YoApkEClJ9imqvuhAxH4LDu8q9RGGMJ5PKp3QhRG5YnhIHHdN5kGaVgxov)xPuhAxH4LD0voXpK4Xj6Tg1H2viEzhThj5ZT6XkyUCZPD4r8mgsGxJlNQ)RuQdTRq8Yo6kN4hs84e9wJ6q7keVSJ2JIh3Yypcduf1H2viEzhfpu)kiO5yEk5ZT6XkyUCZXl7Gk2FH1)pWRXLt1)vk1H2viEzhDLt8djECIERrDODfIx2r7rXJBzShHbQI6q7keVSJIhQFfe0CmpL85w9yfmxU5q4acwtO4ZMbg414YP6)kL6q7keVSJUYj(HepoNe9wJ6q7keVSJ2JK85w9yfmxU5eCWOHfkthQKp3QhRG5YnNMpHI9c26WJvbEnUwwWvEP06acvrZhyoX9Anggyu4gcuWAcSJg5LkaWmqPH0XH(ffneW5XP6)kLI6qDybRj0Wj2p0vkKUYj(HeporV1OOouhwWAcnCI9dDLcP9O8bdJ2)c1XatHuBOFL4pGqTUcaeXwYNB1JvWC5MtZNqXEbBD4XQaVgxll4kVuADaHQO5dmUxRXWaJc3qGcwtGD0iVubaMbknKoo0VOOHaopov)xPuuhQdlynHgoX(HUsH0voXpK4Xj6Tgf1H6WcwtOHtSFORuiThfpomA)luhdmfsTH(vI)ac16kaqZn25doplJ9imqv02HNy)qxP(tXd1Vcc6S5z84wg7ryGQOqLHrf7h6k1FkEO(vqqNnpZxYNB1JvWC5MdUxc3QhRe)b1alhDCD2ceQ4ZQC5pWRX1T6fCIvd9ge0zdopy0(xOogykKAd9Re)beQ1vaGo74XHr7FH6yGPq67bDbXCuqND(s(CREScMl3CW9s4w9yL4pOgy5OJl8kGFc1XatdeQ4ZQC5pWRXLt1)vkfQmmQy)qxP(tx5e)qa7w9coXQHEdccUzl5ZT6XkyUCZb3lHB1JvI)GAGLJoUWjGxb8tOogyAGqfFwLl)bEnUQ)RukuzyuX(HUs9NUYj(Ha2T6fCIvd9geeCZwYNKp3QhRGuNnUqLHrf7h6k1)aVgxoJMsHkdJk2p0vQ)u3QxWj5ZT6Xki1zlxU5SaMG1eA4eqLHrd8ACj6Tg16)l(diuRRaO4H6xbbnx(5PKp3QhRGuNTC5MZCSgYHUNzbEnUe9wJoBi7kabmKzZq7rs(CREScsD2YLBo2q)krOJdoOk5ZT6Xki1zlxU5avggnZw0WbEnUQ)Rukuzy0mBrdtx5e)qK85w9yfK6SLl3CAVJobmKzZeOna7pH6yGPqU8h414IxdpyOt8dCE55w9cobctPT3rNagYSzar2GDREbNy1qVbbb3yd2YypcdufncFOmmY5VauEWrXd1Vccc(JvWwwWvEP0Awm7zyeWCgnLcvggvSFORu)PUvVGlEC3QxWjqykT9o6eWqMndi4hSB1l4eRg6niO5YrG5mAkfQmmQy)qxP(tDREbhy1)vkf1H6WcwtOHtSFORuiDLt8dj)4XZd3R1yyGrHzcGappZWqr7goabYqp4OJd9lkAiG5mAkfQmmQy)qxP(tDREbx(XJNhUxRXWaJcJ(R0HhIy)qxPq64q)IIgc48CREbNaHP027Otadz2mGi2G5e3R1yyGrNnKnOG1ea45Qa2lKHVcGoo0VOOHepUB1l4eimL2EhDcyiZMbeCu(GZZYypcdufncFOmmY5VauEWrXd1Vccc(J14Xj6TgncFOmmY5VauEWr7r5NF(s(CREScsD2YLBoT3rNagYSzc8AC50T6fCceMsBVJobmKzZaMZOPuOYWOI9dDL6p1T6fCGZt9FLsrDOoSG1eA4e7h6kfsx5e)qIhh3R1yyGrHzcGappZWqr7goabYqp4OJd9lkAi5hpEE4ETgddmkm6VshEiI9dDLcPJd9lkAiG5upBMRaat0BnAe(qzyKZFbO8GJ2JYxYNB1JvqQZwUCZz2q2vacyiZMjWRXv9FLsNnKDfGagYSzORCIFiGr99qfZqbn3yLNGZd3R1yyGrNnKnOG1ea45Qa2lKHVcGoo0VOOHaMO3A0zdzdkynbaEUkG9cz4RaO9O4X5e3R1yyGrNnKnOG1ea45Qa2lKHVcGoo0VOOHKVKp3QhRGuNTC5MJdTRq8YUaVgx1)vk1H2viEzhDLt8dbCECgnLcvggvSFORu)PUvVGlFW5XP6)kLE2164aORCIFiXJZjrV1ONDTooaApcmNwg7ryGQONDTooaApkFjFUvpwbPoB5YnN)4q)qeOoaQluMo0aVgx1)vk9po0pebQdG6cLPdLUYj(Hi5ZT6Xki1zlxU5yd9Re)beQ1vabEnUWO9VqDmWui1g6xj(diuRRaabhbMO3AuuhQdlynHgoX(HUsH0EeyuFpuXmuqWX8uYNB1JvqQZwUCZzowdfWqMntGxJlUxRXWaJoBiBqbRjaWZvbSxidFfaDCOFrrdbmNe9wJoBiBqbRjaWZvbSxidFfaThj5ZT6Xki1zlxU58Eqxq0XqnWRXfHP027Otadz2mu8q9RGGHr7FH6yGPqQn0Vs8hqOwxbacocCECgnLcvggvSFORu)PUvVGlFW5r0Bn67bDbSJbgThbMtIERrrDOoSG1eA4e7h6kfs7rGv)xPuuhQdlynHgoX(HUsH0voXpK8L85w9yfK6SLl3CMJ1qo09mlWRXfgT)fQJbMcP2q)kXFaHADfaO5MnyoX9Anggy0zdzdkynbaEUkG9cz4RaOJd9lkAiGZt9FLsrDOoSG1eA4e7h6kfsx5e)qaJ67HkMHcAUCmpbZjrV1OOouhwWAcnCI9dDLcP9O8L85w9yfK6SLl3CEpOli6yOgOna7pH6yGPqU8h414Azbx5LsRzXSNHraJ71AmmWOZgYguWAca8Cva7fYWxbqhh6xu0qadNkiyvhs1B4SbzcokYcMO3A03d6cyhdmApcmNe9wJgHpugg58xakp4O9ijFUvpwbPoB5YnN3d6cIogQbAdW(tOogykKl)bEnUe9wJ(Eqxa7yGr7rGj6TgncFOmmY5VauEWr7rGZJO3A0i8HYWiN)cq5bhfpu)kiiInpcyrIh3T6fCceMsBVJobmKzZWfgT)fQJbMcP2q)kXFaHADfq84UvVGtGWuA7D0jGHmBgUXgmN4ETgddm6SHSbfSMaapxfWEHm8va0XH(ffnK4XDREbNaHP027Otadz2mC5O8L85w9yfK6SLl3CEpOli6yOg414IWuA7D0jGHmBgkEO(vqWWO9VqDmWui1g6xj(diuRRaabhbg3R1yyGrHzcGappZWqr7goabYqp4OJd9lkAiGj6Tg99GUa2XaJ2JaR(VsPOouhwWAcnCI9dDLcPRCIFiG5KO3AuuhQdlynHgoX(HUsH0EeyuFpuXmuqZLJ5PKp3QhRGuNTC5MZ7bDbrhd1aVgxeMsBVJobmKzZqXd1VccoV8Gr7FH6yGPqQn0Vs8hqOwxbacocmUxRXWaJcZeabEEMHHI2nCacKHEWrhh6xu0qaR(VsPOouhwWAcnCI9dDLcPRCIFi5hpEEQ)RukQd1HfSMqdNy)qxPq6kN4hcyuFpuXmuqZLJ5jyoj6Tgf1H6WcwtOHtSFORuiThbopoX9Anggy0zdzdkynbaEUkG9cz4RaOJd9lkAiXJt0Bn6SHSbfSMaapxfWEHm8va0Eu(G5e3R1yyGrHzcGappZWqr7goabYqp4OJd9lkAi5NVKp3QhRGuNTC5MZ7bDbrhd1aVgxeMsBVJobmKzZqXd1VccggT)fQJbMcP2q)kXFaHADfaxocmUxRXWaJcZeabEEMHHI2nCacKHEWrhh6xu0qat0Bn67bDbSJbgThbw9FLsrDOoSG1eA4e7h6kfsx5e)qaZjrV1OOouhwWAcnCI9dDLcP9iWO(EOIzOGMlhZtjFUvpwbPoB5YnN5ynKdDpZc8ACHr7FH6yGPqQn0Vs8hqOwxbaAUzl5ZT6Xki1zlxU5yd9Re)beQ1vabEnUe9wJcvggnZw0Wu8q9RGGi28iGfHhj6TgfQmmAMTOHPq1TzK85w9yfK6SLl3CEpOli6yOgOna7pH6yGPqU8h414cNkiyvhs1B4SbzcokYcMO3A03d6cyhdmApcmNe9wJgHpugg58xakp4O9ijFUvpwbPoB5YnN3d6cIogQbEnUWPccw1Hu9goBqMGJISGj6Tg99GUa2XaJ2JaZjrV1Or4dLHro)fGYdoApsYNB1JvqQZwUCZ59GUGOJHAGxJlrV1OVh0fWogy0Eeyy0(xOogykKAd9Re)beQ1vaGGJaNhNrtPqLHrf7h6k1FQB1l4YhmctPT3rNagYSzO6zZCfGKp3QhRGuNTC5MZ(HUs9xq8oud8ACv)xP09dDL6VG4DOsx5e)qadJ2)c1XatHuBOFL4pGqTUcaeCm484mAkfQmmQy)qxP(tDREbx(s(CREScsD2YLBoVh0feZrd8ACv)xPuhAxH4LD0voXpejFUvpwbPoB5YnhBOFL4pGqTUcqYNB1JvqQZwUCZ59GUGOJHAGOSGxbWL)aVgxIERrFpOlGDmWO9iWwg7ryGQe45wvYNB1JvqQZwUCZP9o6eWqMntGOSGxbWL)aTby)juhdmfYL)aVgx8A4bdDIFs(CREScsD2YLBonmdQcyiZMjquwWRa4YVKpjFUvpwbPWjGxb8tOogykxOYWOI9dDL6FGxJlNrtPqLHrf7h6k1FQB1l4K85w9yfKcNaEfWpH6yGP5YnN)ac16kabb71aVgxIERrHDmWeSMiIbQHP9ijFUvpwbPWjGxb8tOogyAUCZjcFOmmY5VauEWfOna7pH6yGPqU8h414Azbx5LsRzXSNHraZjrV1Or4dLHro)fGYdoApcmNe9wJcJ(R0HhIy)qxPqApsYNB1JvqkCc4va)eQJbMMl3CwatWAcnCcOYWObEnUe9wJA9)f)beQ1vau8q9RGGMl)8uYNB1JvqkCc4va)eQJbMMl3CAygufWqMntGxJR6)kLE2164aORCIFiGj6Tg9SR1Xbq7rGj6Tg9SR1XbqXd1Vccc4u9kaifQUnJGO3AdZJaweEKO3A0ZUwhhafQUndyIERrb1vicGouPq1Tzab)GmjFUvpwbPWjGxb8tOogyAUCZP9o6eWqMntG2aS)eQJbMc5YFGxJlEn8GHoXpjFUvpwbPWjGxb8tOogyAUCZPHzqvadz2mbEnUQ)Ru6zxRJdGUYj(HaMO3A0ZUwhhaThbMO3A0ZUwhhafpu)kii4NYppcyr4rIERrp7ADCauO62ms(CREScsHtaVc4NqDmW0C5MZ(HUs9xq8oud8ACv)xP09dDL6VG4DOsx5e)qK85w9yfKcNaEfWpH6yGP5YnhOYWOz2IgoWRXv9FLsHkdJMzlAy6kN4hIKp3QhRGu4eWRa(juhdmnxU5mBi7kabmKzZe414Q(VsPZgYUcqadz2m0voXpeWwg7ryGQOVh0feDmuP4H6xbbbxalcyy0(xOogykKAd9Re)beQ1vaGi74Xr99qfZqbn3yLNGHr7FH6yGPqQn0Vs8hqOwxbaAUzdopoX9Anggy0zdzdkynbaEUkG9cz4RaOJd9lkAiXJt0Bn6SHSbfSMaapxfWEHm8va0Eu(s(CREScsHtaVc4NqDmW0C5MZ7bDbrhd1aVg38i6TgfuxHia6qLcv3Mbe8dYaZjrV1OepJH8DOs7r5hporV1OVh0fWogy0EKKp3QhRGu4eWRa(juhdmnxU58Eqxq0XqnWRXv9FLsNnKDfGagYSzORCIFiGj6TgD2q2vacyiZMH2JadJ2)c1XatHuBOFL4pGqTUcaezl5ZT6Xkifob8kGFc1XatZLBoZXAih6EMf414Q(VsPZgYUcqadz2m0voXpeWe9wJoBi7kabmKzZq7rGHr7FH6yGPqQn0Vs8hqOwxbaAUzl5ZT6Xkifob8kGFc1XatZLBo)beQ1vacc2RbEnUe9wJcvggnZw0W0EKKp3QhRGu4eWRa(juhdmnxU5mhRHCO7zwGxJlrV1OZgYguWAca8Cva7fYWxbq7rs(CREScsHtaVc4NqDmW0C5MZCSgkGHmBMaVgxy0(xOogykKAd9Re)beQ1vaGiBWO(EOIzOGMBSYtW5r0BnkOUcra0HkfQUndiYMNXJJ67HkMHc6yjpZpE88W9Anggy0zdzdkynbaEUkG9cz4RaOJd9lkAiG5KO3A0zdzdkynbaEUkG9cz4RaO9O8Jhh3R1yyGrb1viWO5zggkEpOlWd2XaRSJoo0VOOHi5ZT6Xkifob8kGFc1XatZLBoZXAih6EMf414MhmA)luhdmfsTH(vI)ac16kaqZF(GZJteMsBVJobmKzZqXRHhm0j(LVKp3QhRGu4eWRa(juhdmnxU5yd9Re)beQ1vabEnUUvVGtSAO3GGMFWrtPqLHrf7h6k1FQB1l4at0BnkXZyiFhQ0EKKp3QhRGu4eWRa(juhdmnxU58hqOwxbiiyVg414gnLcvggvSFORu)PUvVGdmrV1OepJH8DOs7rs(CREScsHtaVc4NqDmW0C5MZ7bDbrhd1aVgxIERrDODfIx2r7rs(CREScsHtaVc4NqDmW0C5MZ7bDbrhd1aVgxlJ9imqvc8CRk5ZT6Xkifob8kGFc1XatZLBoVh0feDmud8ACTm2JWavjWZTkyBOJbge0Q)Ru6SHmbRj0Wj2p0vkKUYj(Hi5ZT6Xkifob8kGFc1XatZLBonmdQcyiZMjWRXv9FLsp7ADCa0voXpeWe9wJE2164aO9ijFUvpwbPWjGxb8tOogyAUCZXg6xjcDCWbvjFUvpwbPWjGxb8tOogyAUCZP9dgAXEtd8ACHS(tCfcni7D9(jGSp4kfmNe9wJgK9UE)eq2hCLkc7OEXoeApkWR0HX9ivCOOd5CDC5pWR0HX9iva8mc)5YFGxPdJ7rQ4ACHS(tCfcni7D9(jGSp4kvYNB1JvqkCc4va)eQJbMMl3CGQRNvGCqBOJbwGxJR6)kLcvxpRa5G2qhdm6kN4hIKp3QhRGu4eWRa(juhdmnxU5mhRHI9dDL6FGxJlNQ)RuAe(q9xSFORu)pOsx5e)qIhx9FLsJWhQ)I9dDL6)bv6kN4hc484mAkfQmmQy)qxP(tDREbx(s(CREScsHtaVc4NqDmW0C5MJn0Vs8hqOwxbe4146w9coXQHEdcA(bNhmA)luhdmfsTH(vI)ac16kaqZF84WO9VqDmWui99GUGyokO5pFjFUvpwbPWjGxb8tOogyAUCZ5pGqTUcqqWEvYNB1JvqkCc4va)eQJbMMl3CAVJobmKzZeikl4vaC5pqBa2Fc1XatHC5pWRXfVgEWqN4NKp3QhRGu4eWRa(juhdmnxU50EhDcyiZMjquwWRa4YFGxJlkl4qxPuKdQEzhOJvjFUvpwbPWjGxb8tOogyAUCZPHzqvadz2mbIYcEfax(L8j5ZT6XkifEfWpH6yGPC)diuRRaeeSxd8ACZJO3AuOYWOz2IgMIhQFfeeWP6vaqkuDBgbrV1gMhbSi8irV1OqLHrZSfnmfQUnt(s(CREScsHxb8tOogyAUCZPHzqvadz2mbEnUQ)Ru6zxRJdGUYj(HaMO3A0ZUwhhaThbMO3A0ZUwhhafpu)kiiGt1RaGuO62mcIERnmpcyr4rIERrp7ADCauO62ms(CREScsHxb8tOogyAUCZP9o6eWqMntG2aS)eQJbMc5YFGxJBECQNnZvaXJJWuA7D0jGHmBgkEO(vqqWfWIepU6)kL6q7keVSJUYj(HagHP027Otadz2mu8q9RGGiplJ9imqvuhAxH4LDu8q9RG5s0BnQdTRq8Yoksh76XQ8bBzShHbQI6q7keVSJIhQFfeeCu(GZJO3A03d6cyhdmApkECoj6TgL4zmKVdvApkFjFUvpwbPWRa(juhdmnxU50EhDcyiZMjqBa2Fc1XatHC5pWRXLO3A0i8HYWiN)cq5bhThbgVgEWqN4NKp3QhRGu4va)eQJbMMl3CCODfIx2f414Q(VsPo0UcXl7ORCIFiGZtp0bAUXkpJhNO3AuINXq(ouP9O8bNNLXEegOk67bDbrhdvkEO(vqqZZ8bNhNQ)Ru6zxRJdGUYj(HepoNe9wJE2164aO9iWCAzShHbQIE2164aO9O8L85w9yfKcVc4NqDmW0C5MZ7bDbrhd1aVgxIERrFpOlGDmWO9iW5H71AmmWOG6key08mddfVh0f4b7yGv2rhh6xu0qIhNtIERrrDOoSG1eA4e7h6kfs7rGv)xPuuhQdlynHgoX(HUsH0voXpK8L85w9yfKcVc4NqDmW0C5MZ(HUs9xq8oud8ACv)xP09dDL6VG4DOsx5e)qaNhQVhQygkiaj5z(s(CREScsHxb8tOogyAUCZbQmmAMTOHd8ACv)xPuOYWOz2IgMUYj(HaopSFiIfCLsDeei1Y6LcIyhpo2peXcUsPoccKEfO5yEMp48q99qfZqbbhXr5l5ZT6XkifEfWpH6yGP5YnNzdzxbiGHmBMaVgx1)vkD2q2vacyiZMHUYj(Ha2Yypcduf99GUGOJHkfpu)kii4cyrK85w9yfKcVc4NqDmW0C5MZ7bDbrhd1aVgx1)vkD2q2vacyiZMHUYj(HaMO3A0zdzxbiGHmBgApsYNB1Jvqk8kGFc1XatZLBo)XH(HiqDauxOmDObEnUQ)Ru6FCOFicuha1fkthkDLt8drYNB1Jvqk8kGFc1XatZLBoZXAih6EMf414s0Bn6SHSbfSMaapxfWEHm8va0Eey1)vkf1H6WcwtOHtSFORuiDLt8dbmrV1OOouhwWAcnCI9dDLcP9ijFUvpwbPWRa(juhdmnxU58hqOwxbiiyVg414s0Bnkuzy0mBrdt7rGj6Tgf1H6WcwtOHtSFORuiThbg13dvmdfeXkpL85w9yfKcVc4NqDmW0C5MZCSgYHUNzbEnUe9wJoBiBqbRjaWZvbSxidFfaThbop1)vkf1H6WcwtOHtSFORuiDLt8dbCEe9wJI6qDybRj0Wj2p0vkK2JIh3Yypcduf99GUGOJHkfpu)kiO5jyuFpuXmuqZnwMD84WO9VqDmWui1g6xj(diuRRaar2Gj6TgfQmmAMTOHP9iWwg7ryGQOVh0feDmuP4H6xbbbxals(XJZP6)kLI6qDybRj0Wj2p0vkKUYj(HepULXEegOk6(HUs9xq8ouP4H6xbbbx4u9kaifQUnJGO3AdZJaweEm78L85w9yfKcVc4NqDmW0C5MZCSgYHUNzbEnUWO9VqDmWui1g6xj(diuRRaan)G5eHP027Otadz2mu8A4bdDIFG5e3R1yyGrNnKnOG1ea45Qa2lKHVcGoo0VOOHaopov)xPuuhQdlynHgoX(HUsH0voXpK4Xj6Tgf1H6WcwtOHtSFORuiThfpULXEegOk67bDbrhdvkEO(vqqZtWO(EOIzOGMBSm78L85w9yfKcVc4NqDmW0C5MZ7bDbrhd1aVgxlJ9imqvc8CRcopoj6Tgf1H6WcwtOHtSFORuiThbMO3A0ZUwhhaThLVKp3QhRGu4va)eQJbMMl3CEpOli6yOg414AzShHbQsGNBvW2qhdmiOv)xP0zdzcwtOHtSFORuiDLt8dbmNe9wJE2164aO9ijFUvpwbPWRa(juhdmnxU58Eqxq0XqnWRXv9FLsNnKjynHgoX(HUsH0voXpeWCs0BnkQd1HfSMqdNy)qxPqApcmQVhQygkO5YX8emNe9wJoBiBqbRjaWZvbSxidFfaThj5ZT6XkifEfWpH6yGP5YnN5ynuadz2mbEnU5H71AmmWOZgYguWAca8Cva7fYWxbqhh6xu0qIhhgT)fQJbMcP2q)kXFaHADfaiYoFW5P(VsPOouhwWAcnCI9dDLcPRCIFiG5KO3A0zdzdkynbaEUkG9cz4RaO9iW5r0BnkQd1HfSMqdNy)qxPqApkECuFpuXmuqZnwMD84WO9VqDmWui1g6xj(diuRRaar2Gj6TgfQmmAMTOHP9iWwg7ryGQOVh0feDmuP4H6xbbbxals(XJZP6)kLI6qDybRj0Wj2p0vkKUYj(HepULXEegOk6(HUs9xq8ouP4H6xbbbx4u9kaifQUnJGO3AdZJaweEm78L85w9yfKcVc4NqDmW0C5MtdZGQagYSzc8ACv)xP0ZUwhhaDLt8dbS6)kLI6qDybRj0Wj2p0vkKUYj(HaMO3A0ZUwhhaThbMO3AuuhQdlynHgoX(HUsH0EKKp3QhRGu4va)eQJbMMl3CEpOli6yOg414s0BnQdTRq8YoApsYNB1Jvqk8kGFc1XatZLBoVh0feDmud8ACTm2JWavjWZTkyov)xPuuhQdlynHgoX(HUsH0voXpejFUvpwbPWRa(juhdmnxU5C2164ac8ACv)xP0ZUwhhaDLt8dbmN5H67HkMHc6yZXGTm2JWavrFpOli6yOsXd1VcccU8mFjFUvpwbPWRa(juhdmnxU50WmOkGHmBMaVgx1)vk9SR1Xbqx5e)qat0Bn6zxRJdG2JaNhrV1ONDTooakEO(vqqayr4roIhj6Tg9SR1XbqHQBZeporV1OqLHrZSfnmThfpoNQ)RukQd1HfSMqdNy)qxPq6kN4hs(s(CREScsHxb8tOogyAUCZ59GUGOJHQKp3QhRGu4va)eQJbMMl3CAVJobmKzZeOna7pH6yGPqU8h414IxdpyOt8tYNB1Jvqk8kGFc1XatZLBonmdQcyiZMjWRXf3R1yyGr3p0vQ)IXH(9hb(6O0XH(ffneWCs0Bn6(HUs9xmo0V)iWxhvGmIERr7rG5u9FLs3p0vQ)cI3HkDLt8dbmNQ)Ru6SHSRaeWqMndDLt8drYNB1Jvqk8kGFc1XatZLBoTFWql2BAGxJlK1FIRqObzVR3pbK9bxPG5KO3A0GS317NaY(GRuryh1l2Hq7rbELomUhPIdfDiNRJl)bELomUhPcGNr4px(d8kDyCpsfxJlK1FIRqObzVR3pbK9bxPs(CREScsHxb8tOogyAUCZXg6xjcDCWbvjFUvpwbPWRa(juhdmnxU50WmOkGHmBMaVgx1)vk9SR1Xbqx5e)qat0Bn6zxRJdG2JK85w9yfKcVc4NqDmW0C5MduD9ScKdAdDmWc8ACv)xPuO66zfih0g6yGrx5e)qK85w9yfKcVc4NqDmW0C5MZCSgk2p0vQ)bEnUCQ(VsPr4d1FX(HUs9)GkDLt8djECoJMsBhEI9dDL6p1T6fCs(CREScsHxb8tOogyAUCZXg6xj(diuRRac8ACHr7FH6yGPqQn0Vs8hqOwxbaA(L85w9yfKcVc4NqDmW0C5MZFaHADfGGG9QKp3QhRGu4va)eQJbMMl3CAVJobmKzZeikl4vaC5pqBa2Fc1XatHC5pWRXfVgEWqN4NKp3QhRGu4va)eQJbMMl3CAVJobmKzZeikl4vaC5pWRXfLfCORukYbvVSd0XQKp3QhRGu4va)eQJbMMl3CAygufWqMntGOSGxbWLFjFUvpwbPWRa(juhdmnxU50WmOkGHmBMaVgx1)vk9SR1Xbqx5e)qat0Bn6zxRJdG2Jat0Bn6zxRJdGIhQFfeeWP6vaqkuDBgbrV1gMhbSi8irV1ONDTooakuDBgdzWHHhRm8MnpZoBEgBEYVHeuoUUcaAi5HGhkih8cYZliNXcYKmLv4KPdnIHvzQXWYepaEfWpH6yGP8azcpo0p8qKjidDYK3vgQRdrMSHEbmivYhiHRMmLnilwqMIfzvWH1Hit8aiR)exHqbjYdKjLjt8aiR)exHqbjsx5e)q4bYuE8ZdNpvYNKpEi4HcYbVG88cYzSGmjtzfoz6qJyyvMAmSmXdIWZYqjCLhit4XH(HhImbzOtM8UYqDDiYKn0lGbPs(ajC1KPSJfKPyrwfCyDiYepaY6pXviuqI8azszYepaY6pXviuqI0voXpeEGmLh)8W5tL8bs4QjtzhlitXISk4W6qKjEaK1FIRqOGe5bYKYKjEaK1FIRqOGePRCIFi8azYvzcKci1bjit5XppC(ujFs(4HGhkih8cYZliNXcYKmLv4KPdnIHvzQXWYepaob8kGFc1Xat5bYeECOF4Hitqg6KjVRmuxhImzd9cyqQKpqcxnzkBoowqMIfzvWH1Hit8aiR)exHqbjYdKjLjt8aiR)exHqbjsx5e)q4bYuE8ZdNpvYNKpqE0igwhImXXYKB1JvY0FqfsL8zi)dQqtwgs4va)eQJbMAYYWl)MSmKRCIFiMymKw8PdFUHmpzIO3AuOYWOz2IgMIhQFfuMaHmbNQxbaPq1Tzee9wByzIhLjalImXJYerV1OqLHrZSfnmfQUnJmLVH0T6Xkd5FaHADfGGG9Qrn8MTjld5kN4hIjgdPfF6WNBiv)xP0ZUwhhaDLt8drMalte9wJE2164aO9izcSmr0Bn6zxRJdGIhQFfuMaHmbNQxbaPq1Tzee9wByzIhLjalImXJYerV1ONDTooakuDBgdPB1JvgYgMbvbmKzZyudVX2KLHCLt8dXeJH0T6Xkdz7D0jGHmBgdPfF6WNBiZtM4uM0ZM5kazkECzcHP027Otadz2mu8q9RGYei4ktawezkECzs9FLsDODfIx2rx5e)qKjWYectPT3rNagYSzO4H6xbLjqit5jtwg7ryGQOo0UcXl7O4H6xbLPCLjIERrDODfIx2rr6yxpwjt5ltGLjlJ9imqvuhAxH4LDu8q9RGYeiKjosMYxMalt5jte9wJ(Eqxa7yGr7rYu84YeNYerV1OepJH8DOs7rYu(gsBa2Fc1XatHgE53OgE5itwgYvoXpetmgs3QhRmKT3rNagYSzmKw8PdFUHKO3A0i8HYWiN)cq5bhThjtGLj8A4bdDIFgsBa2Fc1XatHgE53OgE5ytwgYvoXpetmgsl(0Hp3qQ(VsPo0UcXl7ORCIFiYeyzkpzsp0jtGMRmfR8uMIhxMi6TgL4zmKVdvApsMYxMalt5jtwg7ryGQOVh0feDmuP4H6xbLjqlt8uMYxMalt5jtCktQ)Ru6zxRJdGUYj(HitXJltCkte9wJE2164aO9izcSmXPmzzShHbQIE2164aO9izkFdPB1JvgshAxH4LDg1WBSAYYqUYj(HyIXqAXNo85gsIERrFpOlGDmWO9izcSmLNmH71AmmWOG6key08mddfVh0f4b7yGv2rhh6xu0qKP4XLjoLjIERrrDOoSG1eA4e7h6kfs7rYeyzs9FLsrDOoSG1eA4e7h6kfsx5e)qKP8nKUvpwziFpOli6yOAudVGKMSmKRCIFiMymKw8PdFUHu9FLs3p0vQ)cI3HkDLt8drMalt5jtO(EOIzOYeiKjqsEkt5BiDRESYqUFORu)feVdvJA4fKzYYqUYj(HyIXqAXNo85gs1)vkfQmmAMTOHPRCIFiYeyzkpzc7hIybxPuhbbsTSEPYeiKPyltXJlty)qel4kL6iiq6vYeOLjoMNYu(Yeyzkpzc13dvmdvMaHmXrCKmLVH0T6Xkdjuzy0mBrdBudVXstwgYvoXpetmgsl(0Hp3qQ(VsPZgYUcqadz2m0voXpezcSmzzShHbQI(Eqxq0XqLIhQFfuMabxzcWIyiDRESYqoBi7kabmKzZyudV8ZttwgYvoXpetmgsl(0Hp3qQ(VsPZgYUcqadz2m0voXpezcSmr0Bn6SHSRaeWqMndThziDRESYq(Eqxq0Xq1OgE5NFtwgYvoXpetmgsl(0Hp3qQ(VsP)XH(HiqDauxOmDO0voXpedPB1JvgY)4q)qeOoaQluMouJA4L)Snzzix5e)qmXyiT4th(CdjrV1OZgYguWAca8Cva7fYWxbq7rYeyzs9FLsrDOoSG1eA4e7h6kfsx5e)qKjWYerV1OOouhwWAcnCI9dDLcP9idPB1JvgY5ynKdDpZmQHx(JTjld5kN4hIjgdPfF6WNBij6TgfQmmAMTOHP9izcSmr0BnkQd1HfSMqdNy)qxPqApsMaltO(EOIzOYeiKPyLNgs3QhRmK)beQ1vacc2Rg1Wl)CKjld5kN4hIjgdPfF6WNBij6TgD2q2GcwtaGNRcyVqg(kaApsMalt5jtQ)RukQd1HfSMqdNy)qxPq6kN4hImbwMYtMi6Tgf1H6WcwtOHtSFORuiThjtXJltwg7ryGQOVh0feDmuP4H6xbLjqlt8uMaltO(EOIzOYeO5ktXYSLP4XLjy0(xOogykKAd9Re)beQ1vaYeiKPSLjWYerV1OqLHrZSfnmThjtGLjlJ9imqv03d6cIogQu8q9RGYei4ktawezkFzkECzItzs9FLsrDOoSG1eA4e7h6kfsx5e)qKP4XLjlJ9imqv09dDL6VG4DOsXd1VcktGGRmbNQxbaPq1Tzee9wByzIhLjalImXJYu2Yu(gs3QhRmKZXAih6EMzudV8ZXMSmKRCIFiMymKw8PdFUHegT)fQJbMcP2q)kXFaHADfGmbAzIFzcSmXPmHWuA7D0jGHmBgkEn8GHoXpzcSmXPmH71AmmWOZgYguWAca8Cva7fYWxbqhh6xu0qKjWYuEYeNYK6)kLI6qDybRj0Wj2p0vkKUYj(HitXJlte9wJI6qDybRj0Wj2p0vkK2JKP4XLjlJ9imqv03d6cIogQu8q9RGYeOLjEktGLjuFpuXmuzc0CLPyz2Yu(gs3QhRmKZXAih6EMzudV8hRMSmKRCIFiMymKw8PdFUH0YypcduLap3QYeyzkpzItzIO3AuuhQdlynHgoX(HUsH0EKmbwMi6Tg9SR1Xbq7rYu(gs3QhRmKVh0feDmunQHx(bjnzzix5e)qmXyiT4th(CdPLXEegOkbEUvLjWYKn0XadktGwMu)xP0zdzcwtOHtSFORuiDLt8drMaltCkte9wJE2164aO9idPB1JvgY3d6cIogQg1Wl)GmtwgYvoXpetmgsl(0Hp3qQ(VsPZgYeSMqdNy)qxPq6kN4hImbwM4uMi6Tgf1H6WcwtOHtSFORuiThjtGLjuFpuXmuzc0CLjoMNYeyzItzIO3A0zdzdkynbaEUkG9cz4RaO9idPB1JvgY3d6cIogQg1Wl)XstwgYvoXpetmgsl(0Hp3qMNmH71AmmWOZgYguWAca8Cva7fYWxbqhh6xu0qKP4XLjy0(xOogykKAd9Re)beQ1vaYeiKPSLP8LjWYuEYK6)kLI6qDybRj0Wj2p0vkKUYj(HitGLjoLjIERrNnKnOG1ea45Qa2lKHVcG2JKjWYuEYerV1OOouhwWAcnCI9dDLcP9izkECzc13dvmdvManxzkwMTmfpUmbJ2)c1XatHuBOFL4pGqTUcqMaHmLTmbwMi6TgfQmmAMTOHP9izcSmzzShHbQI(Eqxq0XqLIhQFfuMabxzcWIit5ltXJltCktQ)RukQd1HfSMqdNy)qxPq6kN4hImfpUmzzShHbQIUFORu)feVdvkEO(vqzceCLj4u9kaifQUnJGO3Adlt8OmbyrKjEuMYwMY3q6w9yLHCowdfWqMnJrn8Mnpnzzix5e)qmXyiT4th(CdP6)kLE2164aORCIFiYeyzs9FLsrDOoSG1eA4e7h6kfsx5e)qKjWYerV1ONDTooaApsMalte9wJI6qDybRj0Wj2p0vkK2JmKUvpwziBygufWqMnJrn8Mn)MSmKRCIFiMymKw8PdFUHKO3AuhAxH4LD0EKH0T6Xkd57bDbrhdvJA4n7Snzzix5e)qmXyiT4th(CdPLXEegOkbEUvLjWYeNYK6)kLI6qDybRj0Wj2p0vkKUYj(HyiDRESYq(Eqxq0Xq1OgEZo2MSmKRCIFiMymKw8PdFUHu9FLsp7ADCa0voXpezcSmXPmLNmH67HkMHktGwMInhltGLjlJ9imqv03d6cIogQu8q9RGYei4kt8uMY3q6w9yLH8SR1XbyudVzZrMSmKRCIFiMymKw8PdFUHu9FLsp7ADCa0voXpezcSmr0Bn6zxRJdG2JKjWYuEYerV1ONDTooakEO(vqzceYeGfrM4rzIJKjEuMi6Tg9SR1XbqHQBZitXJlte9wJcvggnZw0W0EKmfpUmXPmP(VsPOouhwWAcnCI9dDLcPRCIFiYu(gs3QhRmKnmdQcyiZMXOgEZMJnzziDRESYq(Eqxq0Xq1qUYj(HyIXOgEZownzzix5e)qmXyiDRESYq2EhDcyiZMXqAXNo85gs8A4bdDIFgsBa2Fc1XatHgE53OgEZgK0KLHCLt8dXeJH0IpD4ZnK4ETgddm6(HUs9xmo0V)iWxhLoo0VOOHitGLjoLjIERr3p0vQ)IXH(9hb(6OcKr0BnApsMaltCktQ)Ru6(HUs9xq8ouPRCIFiYeyzItzs9FLsNnKDfGagYSzORCIFigs3QhRmKnmdQcyiZMXOgEZgKzYYqUYj(HyIXqAXNo85gsiR)exHqdYExVFci7dUsPRCIFiYeyzItzIO3A0GS317NaY(GRuryh1l2Hq7rgYR0HX9ivCndjK1FIRqObzVR3pbK9bxPgYR0HX9ivCOOd5CDgs(nKUvpwziB)GHwS3ud5v6W4EKkaEgH)gs(nQH3SJLMSmKUvpwziTH(vIqhhCq1qUYj(HyIXOgEJnpnzzix5e)qmXyiT4th(CdP6)kLE2164aORCIFiYeyzIO3A0ZUwhhaThziDRESYq2WmOkGHmBgJA4n28BYYqUYj(HyIXqAXNo85gs1)vkfQUEwbYbTHogy0voXpedPB1JvgsO66zfih0g6yGzudVXoBtwgYvoXpetmgsl(0Hp3qYPmP(VsPr4d1FX(HUs9)GkDLt8drMIhxM4uMIMsBhEI9dDL6p1T6fCgs3QhRmKZXAOy)qxP(BudVXo2MSmKRCIFiMymKw8PdFUHegT)fQJbMcP2q)kXFaHADfGmbAzIFdPB1JvgsBOFL4pGqTUcWOgEJnhzYYq6w9yLH8pGqTUcqqWE1qUYj(HyIXOgEJnhBYYqIYcEfGHx(nKRCIFcuwWRamXyiDRESYq2EhDcyiZMXqAdW(tOogyk0Wl)gsl(0Hp3qIxdpyOt8ZqUYj(HyIXOgEJDSAYYqUYj(HyIXqUYj(jqzbVcWeJH0IpD4ZnKOSGdDLsroO6LDYeOLPy1q6w9yLHS9o6eWqMnJHeLf8kadV8BudVXgK0KLHeLf8kadV8Bix5e)eOSGxbyIXq6w9yLHSHzqvadz2mgYvoXpetmg1WBSbzMSmKRCIFiMymKw8PdFUHu9FLsp7ADCa0voXpezcSmr0Bn6zxRJdG2JKjWYerV1ONDTooakEO(vqzceYeCQEfaKcv3Mrq0BTHLjEuMaSiYepkte9wJE2164aOq1TzmKUvpwziBygufWqMnJrnQHeznV)QjldV8BYYqUYj(HyIXqImOfFr6XkdjiFPdJ7rQmXAYK1HkKAiDRESYqcQRqeWW5yJA4nBtwgsuwWRam8YVHCLt8tGYcEfGjgdPB1Jvgsy0Hpfu(NzyOaa72zix5e)qmXyudVX2KLH0T6Xkdzetpwzix5e)qmXyudVCKjldPB1JvgYoCIthk0qUYj(HyIXOgE5ytwgYvoXpetmgsl(0Hp3qMNmXPmP(VsP7h6k1FbX7qLUYj(Hit5ltGLjoLj9SzUcqMaltCktrtPqLHrf7h6k1FQB1l4KjWYuEYemA)luhdmfsTH(vI)ac16kazceYuSLP4XLj1)vkf1H6WcwtOHtSFORuiDLt8drMIhxMW9AnggyuyMaiWZZmmu0UHdqGm0do64q)IIgImLVH0T6Xkdz7D0jGHmBgJA4nwnzzix5e)qmXyiDRESYqgHpugg58xakp4mKw8PdFUHKtzIO3A0i8HYWiN)cq5bhThjtGLP8KjoLPOPuOYWOI9dDL6p1T6fCYu84YemA)luhdmfsTH(vI)ac16kazceYuSLjWYerV1OG6kebqhQuO62mYeiKPS5PmfpUmbz9N4ke6phrqeGy8WoA0p6kN4hImfpUmH71AmmWOWO)kD4Hi2p0vkKoo0VOOHit5ltGLP8Kjy0(xOogykKAd9Re)beQ1vaYeiKjowMIhxMu)xPuuhQdlynHgoX(HUsH0voXpezkECzc3R1yyGrHzcGappZWqr7goabYqp4OJd9lkAiYu84YeK1FIRqO)CebraIXd7Or)ORCIFiYu84YeUxRXWaJcJ(R0HhIy)qxPq64q)IIgImLVmbwM4uMi6Tgfg9xPdpeX(HUsH0EKH0gG9NqDmWuOHx(nQHxqstwgYvoXpetmgsl(0Hp3qYPmPNnZvaYeyzkpzItzkAkfQmmQy)qxP(tDREbNmfpUmbJ2)c1XatHuBOFL4pGqTUcqMaHmfBzcSmr0BnkOUcra0HkfQUnJmbczkBEkt5ltGLP8Kjy0(xOogykKAd9Re)beQ1vaYeiKPyltXJltQ)RukQd1HfSMqdNy)qxPq6kN4hImfpUmH71AmmWOWmbqGNNzyOODdhGazOhC0XH(ffnezkFdPB1JvgY27Otadz2mg1WliZKLH0T6Xkdz7WtSFORu)nKRCIFiMymQH3yPjldPB1Jvgs0PJHnKRCIFiMymQHx(5Pjld5kN4hIjgdPfF6WNBi5uMu)xPuhAxH4LD0voXpezkECzIO3AuhAxH4LD0EKmfpUmzzShHbQI6q7keVSJIhQFfuMaTmXX80q6w9yLHK4zmerRJdWOgE5NFtwgYvoXpetmgsl(0Hp3qYPmP(VsPo0UcXl7ORCIFiYu84YerV1Oo0UcXl7O9idPB1JvgsIHHdN5kaJA4L)Snzzix5e)qmXyiT4th(CdjNYK6)kL6q7keVSJUYj(HitXJlte9wJ6q7keVSJ2JKP4XLjlJ9imqvuhAxH4LDu8q9RGYeOLjoMNgs3QhRmKTdpINXqmQHx(JTjld5kN4hIjgdPfF6WNBi5uMu)xPuhAxH4LD0voXpezkECzIO3AuhAxH4LD0EKmfpUmzzShHbQI6q7keVSJIhQFfuMaTmXX80q6w9yLH0l7Gk2FH1)3OgE5NJmzzix5e)qmXyiT4th(CdjNYK6)kL6q7keVSJUYj(HitXJltCkte9wJ6q7keVSJ2JmKUvpwzijCabRju8zZanQHx(5ytwgs3QhRmKbhmAyHY0HAix5e)qmXyudV8hRMSmKRCIFiMymKw8PdFUH0YcUYlLwhqOkA(KjWYeNYeUxRXWaJc3qGcwtGD0iVubaMbknKoo0VOOHitGLP8KjoLj1)vkf1H6WcwtOHtSFORuiDLt8drMIhxMi6Tgf1H6WcwtOHtSFORuiThjt5ltGLjy0(xOogykKAd9Re)beQ1vaYeiKPyBiDRESYq28juSxWwhESYOgE5hK0KLHCLt8dXeJH0IpD4ZnKwwWvEP06acvrZNmbwMW9Anggyu4gcuWAcSJg5LkaWmqPH0XH(ffnezcSmLNmXPmP(VsPOouhwWAcnCI9dDLcPRCIFiYu84YerV1OOouhwWAcnCI9dDLcP9izkECzcgT)fQJbMcP2q)kXFaHADfGmbAUYuSLP8LjWYuEYKLXEegOkA7WtSFORu)P4H6xbLjqltzZtzkECzYYypcduffQmmQy)qxP(tXd1VcktGwMYMNYu(gs3QhRmKnFcf7fS1HhRmQHx(bzMSmKRCIFiMymKw8PdFUH0T6fCIvd9guMaTmLTmbwMYtMGr7FH6yGPqQn0Vs8hqOwxbitGwMYwMIhxMGr7FH6yGPq67bDbXCuzc0Yu2Yu(gsOIpRA4LFdPB1JvgsCVeUvpwj(dQgY)GQOC0ziD2mQHx(JLMSmKRCIFiMymKw8PdFUHKtzs9FLsHkdJk2p0vQ)0voXpezcSm5w9coXQHEdktGGRmLTHeQ4ZQgE53q6w9yLHe3lHB1JvI)GQH8pOkkhDgs4va)eQJbMAudVzZttwgYvoXpetmgsl(0Hp3qQ(VsPqLHrf7h6k1F6kN4hImbwMCREbNy1qVbLjqWvMY2qcv8zvdV8BiDRESYqI7LWT6XkXFq1q(hufLJodjCc4va)eQJbMAuJAiJWZYqjC1KLHx(nzzix5e)qmXyiDRESYqohRHI9dDL6VHezql(I0Jvgsqk8WZ21Hitl4Wbit6HozsdNm5wLHLPdktEq)EN4h1qAXNo85gsoLj1)vkncFO(l2p0vQ)huPRCIFig1WB2MSmKRCIFiMymKUvpwziB)GHwS3udjYGw8fPhRmKGudozIuzy0mBrdltr4zzOeUkt96hektqg6KjhbbktG6(xMGroOkzcYyf1qAXNo85gsiR)exHqJ6qT)tmCpspwrx5e)qKP4XLjiR)exHqdYExVFci7dUsPRCIFig1WBSnzzix5e)qmXyiT4th(CdP6)kLcvggnZw0W0voXpezcSmLNmH9drSGRuQJGaPwwVuzceYuSLP4XLjSFiIfCLsDeei9kzc0YehZtzkFdPB1JvgsOYWOz2Ig2OgE5itwgs3QhRmKTdpX(HUs93qUYj(HyIXOgE5ytwgYvoXpetmgsl(0Hp3qQ(VsP7h6k1FbX7qLUYj(HitGLjy0(xOogykKAd9Re)beQ1vaYeiKPyBiDRESYqUFORu)feVdvJA4nwnzzix5e)qmXyiDRESYq(Eqxq0Xq1q(xnHfXqgBdPfF6WNBi5uMu)xP09dDL6VG4DOsx5e)qKjWYemA)luhdmfsTH(vI)ac16kazceYuSLP4XLjIERrHkdJMzlAyApYqImOfFr6XkdzmZ6D4KjqcbJrMcDOm5YKI9G7Lj9qxGYKgozYrqyLmf9UDqzIh1WdktRuCa8OmXkzkwKhszQXWYuSLj4SScbktktM8GSdrMqyDIFGCbjemgzIvYuu)FQrn8csAYYqUYj(HyIXqAXNo85gsoLj1)vkD)qxP(liEhQ0voXpezcSmbJ2)c1XatHuBOFL4pGqTUcqManxzk2YeyzItzIO3AuOYWOz2IgM2JmKUvpwziTH(vI)ac16kaJA4fKzYYq6w9yLHmIPhRmKRCIFiMymQrnKoBMSm8YVjld5kN4hIjgdPfF6WNBi5uMIMsHkdJk2p0vQ)u3QxWziDRESYqcvggvSFORu)nQH3Snzzix5e)qmXyiT4th(CdjrV1Ow)FXFaHADfafpu)kOmbAUYe)80q6w9yLHCbmbRj0WjGkdJAudVX2KLHCLt8dXeJH0IpD4ZnKe9wJoBi7kabmKzZq7rgs3QhRmKZXAih6EMzudVCKjldPB1JvgsBOFLi0XbhunKRCIFiMymQHxo2KLHCLt8dXeJH0IpD4ZnKQ)Rukuzy0mBrdtx5e)qmKUvpwziHkdJMzlAyJA4nwnzzix5e)qmXyiDRESYq2EhDcyiZMXqAXNo85gs8A4bdDIFYeyzkpzkpzYT6fCceMsBVJobmKzZitGqMYwMaltUvVGtSAO3GYei4ktXwMaltwg7ryGQOr4dLHro)fGYdokEO(vqzceYe)XQmbwMSSGR8sP1Sy2ZWiYeyzItzkAkfQmmQy)qxP(tDREbNmfpUm5w9cobctPT3rNagYSzKjqit8ltGLj3QxWjwn0Bqzc0CLjosMaltCktrtPqLHrf7h6k1FQB1l4KjWYK6)kLI6qDybRj0Wj2p0vkKUYj(Hit5ltXJlt5jt4ETgddmkmtae45zggkA3Wbiqg6bhDCOFrrdrMaltCktrtPqLHrf7h6k1FQB1l4KP8LP4XLP8KjCVwJHbgfg9xPdpeX(HUsH0XH(ffnezcSmLNm5w9cobctPT3rNagYSzKjqitXwMaltCkt4ETgddm6SHSbfSMaapxfWEHm8va0XH(ffnezkECzYT6fCceMsBVJobmKzZitGqM4izkFzcSmLNmzzShHbQIgHpugg58xakp4O4H6xbLjqit8hRYu84YerV1Or4dLHro)fGYdoApsMYxMYxMY3qAdW(tOogyk0Wl)g1WliPjld5kN4hIjgdPfF6WNBi5uMCREbNaHP027Otadz2mYeyzItzkAkfQmmQy)qxP(tDREbNmbwMYtMu)xPuuhQdlynHgoX(HUsH0voXpezkECzc3R1yyGrHzcGappZWqr7goabYqp4OJd9lkAiYu(Yu84YuEYeUxRXWaJcJ(R0HhIy)qxPq64q)IIgImbwM4uM0ZM5kazcSmr0BnAe(qzyKZFbO8GJ2JKP8nKUvpwziBVJobmKzZyudVGmtwgYvoXpetmgsl(0Hp3qQ(VsPZgYUcqadz2m0voXpezcSmH67HkMHktGMRmfR8uMalt5jt4ETgddm6SHSbfSMaapxfWEHm8va0XH(ffnezcSmr0Bn6SHSbfSMaapxfWEHm8va0EKmfpUmXPmH71AmmWOZgYguWAca8Cva7fYWxbqhh6xu0qKP8nKUvpwziNnKDfGagYSzmQH3yPjld5kN4hIjgdPfF6WNBiv)xPuhAxH4LD0voXpezcSmLNmXPmfnLcvggvSFORu)PUvVGtMYxMalt5jtCktQ)Ru6zxRJdGUYj(HitXJltCkte9wJE2164aO9izcSmXPmzzShHbQIE2164aO9izkFdPB1JvgshAxH4LDg1Wl)80KLHCLt8dXeJH0IpD4ZnKQ)Ru6FCOFicuha1fkthkDLt8dXq6w9yLH8po0pebQdG6cLPd1OgE5NFtwgYvoXpetmgsl(0Hp3qcJ2)c1XatHuBOFL4pGqTUcqMaHmXrYeyzIO3AuuhQdlynHgoX(HUsH0EKmbwMq99qfZqLjqitCmpnKUvpwziTH(vI)ac16kaJA4L)Snzzix5e)qmXyiT4th(CdjUxRXWaJoBiBqbRjaWZvbSxidFfaDCOFrrdrMaltCkte9wJoBiBqbRjaWZvbSxidFfaThziDRESYqohRHcyiZMXOgE5p2MSmKRCIFiMymKw8PdFUHeHP027Otadz2mu8q9RGYeyzcgT)fQJbMcP2q)kXFaHADfGmbczIJKjWYuEYeNYu0ukuzyuX(HUs9N6w9cozkFzcSmLNmr0Bn67bDbSJbgThjtGLjoLjIERrrDOoSG1eA4e7h6kfs7rYeyzs9FLsrDOoSG1eA4e7h6kfsx5e)qKP8nKUvpwziFpOli6yOAudV8ZrMSmKRCIFiMymKw8PdFUHegT)fQJbMcP2q)kXFaHADfGmbAUYu2YeyzItzc3R1yyGrNnKnOG1ea45Qa2lKHVcGoo0VOOHitGLP8Kj1)vkf1H6WcwtOHtSFORuiDLt8drMaltO(EOIzOYeO5ktCmpLjWYeNYerV1OOouhwWAcnCI9dDLcP9izkFdPB1JvgY5ynKdDpZmQHx(5ytwgYvoXpetmgs3QhRmKVh0feDmunKw8PdFUH0YcUYlLwZIzpdJitGLjCVwJHbgD2q2GcwtaGNRcyVqg(ka64q)IIgImbwMGtfeSQdP6nC2GmbhfzLjWYerV1OVh0fWogy0EKmbwM4uMi6TgncFOmmY5VauEWr7rgsBa2Fc1XatHgE53OgE5pwnzzix5e)qmXyiDRESYq(Eqxq0Xq1qAXNo85gsIERrFpOlGDmWO9izcSmr0BnAe(qzyKZFbO8GJ2JKjWYuEYerV1Or4dLHro)fGYdokEO(vqzceYuSLjEuMaSiYu84YKB1l4eimL2EhDcyiZMrM4ktWO9VqDmWui1g6xj(diuRRaKP4XLj3QxWjqykT9o6eWqMnJmXvMITmbwM4uMW9Anggy0zdzdkynbaEUkG9cz4RaOJd9lkAiYu84YKB1l4eimL2EhDcyiZMrM4ktCKmLVH0gG9NqDmWuOHx(nQHx(bjnzzix5e)qmXyiT4th(CdjctPT3rNagYSzO4H6xbLjWYemA)luhdmfsTH(vI)ac16kazceYehjtGLjCVwJHbgfMjac88mddfTB4aeid9GJoo0VOOHitGLjIERrFpOlGDmWO9izcSmP(VsPOouhwWAcnCI9dDLcPRCIFiYeyzItzIO3AuuhQdlynHgoX(HUsH0EKmbwMq99qfZqLjqZvM4yEAiDRESYq(Eqxq0Xq1OgE5hKzYYqUYj(HyIXqAXNo85gseMsBVJobmKzZqXd1VcktGLP8KP8Kjy0(xOogykKAd9Re)beQ1vaYeiKjosMalt4ETgddmkmtae45zggkA3Wbiqg6bhDCOFrrdrMaltQ)RukQd1HfSMqdNy)qxPq6kN4hImLVmfpUmLNmP(VsPOouhwWAcnCI9dDLcPRCIFiYeyzc13dvmdvManxzIJ5PmbwM4uMi6Tgf1H6WcwtOHtSFORuiThjtGLP8KjoLjCVwJHbgD2q2GcwtaGNRcyVqg(ka64q)IIgImfpUmr0Bn6SHSbfSMaapxfWEHm8va0EKmLVmbwM4uMW9AnggyuyMaiWZZmmu0UHdqGm0do64q)IIgImLVmLVH0T6Xkd57bDbrhdvJA4L)yPjld5kN4hIjgdPfF6WNBirykT9o6eWqMndfpu)kOmbwMGr7FH6yGPqQn0Vs8hqOwxbitCLjosMalt4ETgddmkmtae45zggkA3Wbiqg6bhDCOFrrdrMalte9wJ(Eqxa7yGr7rYeyzs9FLsrDOoSG1eA4e7h6kfsx5e)qKjWYeNYerV1OOouhwWAcnCI9dDLcP9izcSmH67HkMHktGMRmXX80q6w9yLH89GUGOJHQrn8Mnpnzzix5e)qmXyiT4th(CdjmA)luhdmfsTH(vI)ac16kazc0CLPSnKUvpwziNJ1qo09mZOgEZMFtwgYvoXpetmgsl(0Hp3qs0Bnkuzy0mBrdtXd1VcktGqMITmXJYeGfrM4rzIO3AuOYWOz2IgMcv3MXq6w9yLH0g6xj(diuRRamQH3SZ2KLHCLt8dXeJH0T6Xkd57bDbrhdvdPfF6WNBiHtfeSQdP6nC2GmbhfzLjWYerV1OVh0fWogy0EKmbwM4uMi6TgncFOmmY5VauEWr7rgsBa2Fc1XatHgE53OgEZo2MSmKRCIFiMymKw8PdFUHeovqWQoKQ3WzdYeCuKvMalte9wJ(Eqxa7yGr7rYeyzItzIO3A0i8HYWiN)cq5bhThziDRESYq(Eqxq0Xq1OgEZMJmzzix5e)qmXyiT4th(CdjrV1OVh0fWogy0EKmbwMGr7FH6yGPqQn0Vs8hqOwxbitGqM4izcSmLNmXPmfnLcvggvSFORu)PUvVGtMYxMaltimL2EhDcyiZMHQNnZvags3QhRmKVh0feDmunQH3S5ytwgYvoXpetmgsl(0Hp3qQ(VsP7h6k1FbX7qLUYj(HitGLjy0(xOogykKAd9Re)beQ1vaYeiKjowMalt5jtCktrtPqLHrf7h6k1FQB1l4KP8nKUvpwzi3p0vQ)cI3HQrn8MDSAYYqUYj(HyIXqAXNo85gs1)vk1H2viEzhDLt8dXq6w9yLH89GUGyoQrn8MniPjldPB1JvgsBOFL4pGqTUcWqUYj(HyIXOgEZgKzYYqUYj(HyIXqUYj(jqzbVcWeJH0IpD4ZnKe9wJ(Eqxa7yGr7rYeyzYYypcduLap3Qgs3QhRmKVh0feDmunKOSGxby4LFJA4n7yPjldjkl4vagE53qUYj(jqzbVcWeJH0T6Xkdz7D0jGHmBgdPna7pH6yGPqdV8BiT4th(CdjEn8GHoXpd5kN4hIjgJA4n280KLHeLf8kadV8Bix5e)eOSGxbyIXq6w9yLHSHzqvadz2mgYvoXpetmg1Ogs4eWRa(juhdm1KLHx(nzzix5e)qmXyiT4th(CdjNYu0ukuzyuX(HUs9N6w9codPB1JvgsOYWOI9dDL6Vrn8MTjld5kN4hIjgdPfF6WNBij6Tgf2XatWAIigOgM2JmKUvpwzi)diuRRaeeSxnQH3yBYYqUYj(HyIXq6w9yLHmcFOmmY5VauEWziT4th(CdPLfCLxkTMfZEggrMaltCkte9wJgHpugg58xakp4O9izcSmXPmr0Bnkm6VshEiI9dDLcP9idPna7pH6yGPqdV8BudVCKjld5kN4hIjgdPfF6WNBij6Tg16)l(diuRRaO4H6xbLjqZvM4NNgs3QhRmKlGjynHgobuzyuJA4LJnzzix5e)qmXyiT4th(CdP6)kLE2164aORCIFiYeyzIO3A0ZUwhhaThjtGLjIERrp7ADCau8q9RGYeiKj4u9kaifQUnJGO3Adlt8OmbyrKjEuMi6Tg9SR1XbqHQBZitGLjIERrb1vicGouPq1TzKjqit8dYmKUvpwziBygufWqMnJrn8gRMSmKRCIFiMymKUvpwziBVJobmKzZyiT4th(CdjEn8GHoXpdPna7pH6yGPqdV8BudVGKMSmKRCIFiMymKw8PdFUHu9FLsp7ADCa0voXpezcSmr0Bn6zxRJdG2JKjWYerV1ONDTooakEO(vqzceYe)u(LjEuMaSiYepkte9wJE2164aOq1TzmKUvpwziBygufWqMnJrn8cYmzzix5e)qmXyiT4th(CdP6)kLUFORu)feVdv6kN4hIH0T6Xkd5(HUs9xq8ounQH3yPjld5kN4hIjgdPfF6WNBiv)xPuOYWOz2IgMUYj(HyiDRESYqcvggnZw0Wg1Wl)80KLHCLt8dXeJH0IpD4ZnKQ)Ru6SHSRaeWqMndDLt8drMaltwg7ryGQOVh0feDmuP4H6xbLjqWvMaSiYeyzcgT)fQJbMcP2q)kXFaHADfGmbczkBzkECzc13dvmdvManxzkw5PmbwMGr7FH6yGPqQn0Vs8hqOwxbitGMRmLTmbwMYtM4uMW9Anggy0zdzdkynbaEUkG9cz4RaOJd9lkAiYu84YerV1OZgYguWAca8Cva7fYWxbq7rYu(gs3QhRmKZgYUcqadz2mg1Wl)8BYYqUYj(HyIXqAXNo85gY8KjIERrb1vicGouPq1TzKjqit8dYKjWYeNYerV1OepJH8DOs7rYu(Yu84YerV1OVh0fWogy0EKH0T6Xkd57bDbrhdvJA4L)Snzzix5e)qmXyiT4th(CdP6)kLoBi7kabmKzZqx5e)qKjWYerV1OZgYUcqadz2m0EKmbwMGr7FH6yGPqQn0Vs8hqOwxbitGqMY2q6w9yLH89GUGOJHQrn8YFSnzzix5e)qmXyiT4th(CdP6)kLoBi7kabmKzZqx5e)qKjWYerV1OZgYUcqadz2m0EKmbwMGr7FH6yGPqQn0Vs8hqOwxbitGMRmLTH0T6Xkd5CSgYHUNzg1Wl)CKjld5kN4hIjgdPfF6WNBij6TgfQmmAMTOHP9idPB1JvgY)ac16kabb7vJA4LFo2KLHCLt8dXeJH0IpD4ZnKe9wJoBiBqbRjaWZvbSxidFfaThziDRESYqohRHCO7zMrn8YFSAYYqUYj(HyIXqAXNo85gsy0(xOogykKAd9Re)beQ1vaYeiKPSLjWYeQVhQygQmbAUYuSYtzcSmLNmr0BnkOUcra0HkfQUnJmbczkBEktXJltO(EOIzOYeOLPyjpLP8LP4XLP8KjCVwJHbgD2q2GcwtaGNRcyVqg(ka64q)IIgImbwM4uMi6TgD2q2GcwtaGNRcyVqg(kaApsMYxMIhxMW9AnggyuqDfcmAEMHHI3d6c8GDmWk7OJd9lkAigs3QhRmKZXAOagYSzmQHx(bjnzzix5e)qmXyiT4th(CdzEYemA)luhdmfsTH(vI)ac16kazc0Ye)Yu(YeyzkpzItzcHP027Otadz2mu8A4bdDIFYu(gs3QhRmKZXAih6EMzudV8dYmzzix5e)qmXyiT4th(CdPB1l4eRg6nOmbAzIFzcSmfnLcvggvSFORu)PUvVGtMalte9wJs8mgY3HkThziDRESYqAd9Re)beQ1vag1Wl)XstwgYvoXpetmgsl(0Hp3qgnLcvggvSFORu)PUvVGtMalte9wJs8mgY3HkThziDRESYq(hqOwxbiiyVAudVzZttwgYvoXpetmgsl(0Hp3qs0BnQdTRq8YoApYq6w9yLH89GUGOJHQrn8Mn)MSmKRCIFiMymKw8PdFUH0YypcduLap3Qgs3QhRmKVh0feDmunQH3SZ2KLHCLt8dXeJH0IpD4ZnKwg7ryGQe45wvMalt2qhdmOmbAzs9FLsNnKjynHgoX(HUsH0voXpedPB1JvgY3d6cIogQg1WB2X2KLHCLt8dXeJH0IpD4ZnKQ)Ru6zxRJdGUYj(HitGLjIERrp7ADCa0EKH0T6XkdzdZGQagYSzmQH3S5itwgs3QhRmK2q)krOJdoOAix5e)qmXyudVzZXMSmKRCIFiMymKw8PdFUHeY6pXvi0GS317NaY(GRu6kN4hImbwM4uMi6Tgni7D9(jGSp4kve2r9IDi0EKH8kDyCpsfxZqcz9N4keAq2769tazFWvQH8kDyCpsfhk6qoxNHKFdPB1JvgY2pyOf7n1qELomUhPcGNr4VHKFJA4n7y1KLHCLt8dXeJH0IpD4ZnKQ)RukuD9ScKdAdDmWORCIFigs3QhRmKq11ZkqoOn0XaZOgEZgK0KLHCLt8dXeJH0IpD4ZnKCktQ)RuAe(q9xSFORu)pOsx5e)qKP4XLj1)vkncFO(l2p0vQ)huPRCIFiYeyzkpzItzkAkfQmmQy)qxP(tDREbNmLVH0T6Xkd5CSgk2p0vQ)g1WB2GmtwgYvoXpetmgsl(0Hp3q6w9coXQHEdktGwM4xMalt5jtWO9VqDmWui1g6xj(diuRRaKjqlt8ltXJltWO9VqDmWui99GUGyoQmbAzIFzkFdPB1JvgsBOFL4pGqTUcWOgEZowAYYq6w9yLH8pGqTUcqqWE1qUYj(HyIXOgEJnpnzzirzbVcWWl)gYvoXpbkl4vaMymKUvpwziBVJobmKzZyiTby)juhdmfA4LFdPfF6WNBiXRHhm0j(zix5e)qmXyudVXMFtwgYvoXpetmgYvoXpbkl4vaMymKw8PdFUHeLfCORukYbvVStMaTmfRgs3QhRmKT3rNagYSzmKOSGxby4LFJA4n2zBYYqIYcEfGHx(nKRCIFcuwWRamXyiDRESYq2WmOkGHmBgd5kN4hIjgJAuJAi9UgYWgsYdT)UESkwe7n1Og1ya]] )

end
