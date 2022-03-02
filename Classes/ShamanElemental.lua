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

    spec:RegisterPack( "Elemental", 20220301, [[dGu8qcqiufpcirTjG6tOcLrjQYPev1QqfPxjQ0Seq3ciP0Uq6xIsnmurDmuvTmrfptOQMgQqUgQi2gqcFtOk14asY5qfQwNqvK5beUhQ0(asDqHQGwOqLhkuf1efQc0fbseFeiPOtcKuTsuvMPqvIBcKizNOk9tGePAPajfEkIMQOKRcKiLVkufWyfQsAVu8xcdwKdt1IH0JP0KH4YkBwkFgWOf0Pv51IIzRQBJWUL8BugUqooQGLd1ZbnDsxxQ2Ua9DGOXluf68cW8fk7NOn8BYYqI46m8MdNZjhohFoNdLZCMZCC(bvgsnGOziJCBghygYYjMHeuYpIvQ)gYipGN5iMSmKqwhBNHmu1iy8u2zdCAyhLAzezdpI(76Xkl2BA2WJWMTHeTFVcQxgudjIRZWBoCoNC4C85CouoZzoZX5pEBiHrZA4nhqrogYWdbzLb1qImO1qck5hXk1FzIm0j8sYhOuo2gkt8hOmLdNZjhjFs(INd9cyW4jjFGALjq9YYWrmSRtMGt1RaGuO62mc0ERnSm1yyzcu3UwhhqGYePYWez2IgMk5duRmfpebrMaLA6yyzYlezcusatMynzsdNmrQmmHm5a(vudzeM1UFgsqzqzzcuYpIvQ)YezOt4LKpqzqzzcukhBdLj(duMYHZ5KJKpjFGYGYYu8COxadgpj5duguwMa1ktG6LLHJyyxNmbNQxbaPq1TzeO9wByzQXWYeOUDTooGaLjsLHjYSfnmvYhOmOSmbQvMIhIGitGsnDmSm5fImbkjGjtSMmPHtMivgMqMCa)kQKpjFGYYeOK4Xz76qKPfC4aKj9iMmPHtMCRYWY0bLjpOFVJ(Jk5ZT6XkincplJa1vUZXAOy)iwP(h414YJ6)kLgHpc)f7hXk1)dQ0vo6pejFGYYeO0GtMivgMiZw0WYueEwgbQRYuV(bHYeKrmzYrqGYeiV)LjyKdYsMGmwrL85w9yfKgHNLrG6AUCZU9dgAXEtd8ACHS(JEfcnQd1(pXW9i9yvSyqw)rVcHgK9UE)eq2hCLk5ZT6XkincplJa11C5MnuzyImBrdh414Q(VsPqLHjYSfnmDLJ(dbCEy)qel4kL6iiqQL1lfeXpwmSFiIfCLsDeei9kqZjCoFjFUvpwbPr4zzeOUMl3SBhEI9JyL6VKp3QhRG0i8SmcuxZLB27hXk1Fb67qnWRXv9FLs3pIvQ)c03HkDLJ(dbmmA)luhdmfsTH(vI)ac16kaqeFjFGYYuCZ6D4KP4LGXjtHouMCzsXEW9YKEelqzsdNm5iiSsMIE3oOmXPA4bLPvkoaovMyLmfphpOm1yyzk(YeCwwHaLjLjtEq2HitiSo6pqTXlbJtMyLmf1)Nk5ZT6XkincplJa11C5M97bDbAhd1a)RMWIWn(bEnU8O(VsP7hXk1Fb67qLUYr)HaggT)fQJbMcP2q)kXFaHADfaiIFSyO9wJcvgMiZw0W0EKKp3QhRG0i8SmcuxZLB22q)kXFaHADfqGxJlpQ)Ru6(rSs9xG(ouPRC0FiGHr7FH6yGPqQn0Vs8hqOwxbaAUXhmpO9wJcvgMiZw0W0EKKp3QhRG0i8SmcuxZLB2rm9yLKpjFGYYeOEPdJ7rQmXAYK1HkKk5ZT6XkyUCZgKxHiGHZXs(CREScMl3SHrh(uq6FMHHcaSBxGeSGxbWLFjFUvpwbZLB2rm9yLKp3QhRG5Yn7oCIthbuYNB1JvWC5MD7DIjGHmBMaVg384r9FLs3pIvQ)c03HkDLJ(djFW8ONnZvaG5jAkfQmmHy)iwP(tDREbh48Gr7FH6yGPqQn0Vs8hqOwxbaI4hlM6)kLs4qDybRj0Wj2pIvkKUYr)HelgUxRXWaJcZeakEEMHHI2nCacKrCWrhh6xu0qYxYNB1JvWC5MDe(iyyKZFbi9GlqBa2Fc1XatHC5pWRXLh0ERrJWhbdJC(laPhC0Ee484jAkfQmmHy)iwP(tDREbxSyWO9VqDmWui1g6xj(diuRRaar8bJ2BnkiVcra0HkfQUndiYHZXIbz9h9ke6phrGgGyXJor0p6kh9hsSy4ETgddmkm6VshEiI9JyLcPJd9lkAi5dopy0(xOogykKAd9Re)beQ1vaGGtIft9FLsjCOoSG1eA4e7hXkfsx5O)qIfd3R1yyGrHzcafppZWqr7goabYio4OJd9lkAiXIbz9h9ke6phrGgGyXJor0p6kh9hsSy4ETgddmkm6VshEiI9JyLcPJd9lkAi5dMh0ERrHr)v6WdrSFeRuiThj5ZT6XkyUCZU9oXeWqMntGxJlp6zZCfa484jAkfQmmHy)iwP(tDREbxSyWO9VqDmWui1g6xj(diuRRaar8bJ2BnkiVcra0HkfQUndiYHZ5dopy0(xOogykKAd9Re)beQ1vaGi(XIP(VsPeouhwWAcnCI9JyLcPRC0FiXIH71AmmWOWmbGINNzyOODdhGazehC0XH(ffnK8L85w9yfmxUz3o8e7hXk1FjFUvpwbZLB2ethdl5ZT6XkyUCZg9zmerRJdiWRXLh1)vk1H2viEzhDLJ(djwm0ERrDODfIx2r7rXIzzShHbYI6q7keVSJIhHFfe0CcNL85w9yfmxUzJomC4mxbe414YJ6)kL6q7keVSJUYr)HelgAV1Oo0UcXl7O9ijFUvpwbZLB2Tdp0NXqc8AC5r9FLsDODfIx2rx5O)qIfdT3AuhAxH4LD0EuSywg7ryGSOo0UcXl7O4r4xbbnNWzjFUvpwbZLB2EzhuX(lS()bEnU8O(VsPo0UcXl7ORC0FiXIH2BnQdTRq8YoApkwmlJ9imqwuhAxH4LDu8i8RGGMt4SKp3QhRG5YnBuhqWAcfF2mWaVgxEu)xPuhAxH4LD0vo6pKyX4bT3AuhAxH4LD0EKKp3QhRG5Yn7GdgnSqz6iK85w9yfmxUz38juSxWwhESkWRX1YcUYlLwhqOkA(aZdUxRXWaJc3qGcwtGDIiVubaMbsnKoo0VOOHaopEu)xPuchQdlynHgoX(rSsH0vo6pKyXq7TgLWH6WcwtOHtSFeRuiThLpyy0(xOogykKAd9Re)beQ1vaGi(s(CREScMl3SB(ek2lyRdpwf414Azbx5LsRdiufnFGX9Anggyu4gcuWAcSte5LkaWmqQH0XH(ffneW5XJ6)kLs4qDybRj0Wj2pIvkKUYr)HelgAV1OeouhwWAcnCI9JyLcP9OyXGr7FH6yGPqQn0Vs8hqOwxbaAUXpFW5zzShHbYI2o8e7hXk1FkEe(vqqNdNJfZYypcdKffQmmHy)iwP(tXJWVcc6C4C(s(CREScMl3SX9s4w9yL4pOgy5eJRZwGqfFwLl)bEnUUvVGtSAe3GGohW5bJ2)c1XatHuBOFL4pGqTUca05elgmA)luhdmfsFpOlqNta6CYxYNB1JvWC5MnUxc3QhRe)b1alNyCHxb8tOogyAGqfFwLl)bEnU8O(VsPqLHje7hXk1F6kh9hcy3QxWjwnIBqqWnhjFUvpwbZLB24EjCRESs8hudSCIXfob8kGFc1XatdeQ4ZQC5pWRXv9FLsHkdti2pIvQ)0vo6peWUvVGtSAe3GGGBos(K85w9yfK6SXfQmmHy)iwP(l5ZT6Xki1zlxUzVaMG1eA4eqLHjc8ACr7Tg16)l(diuRRaO4r4xbbnx(5SKp3QhRGuNTC5M9CSgYHUNzbEnUO9wJoBi7kabmKzZq7rs(CREScsD2YLB22q)krOJdoOk5ZT6Xki1zlxUzdvgMiZw0WbEnUQ)RukuzyImBrdtx5O)qK85w9yfK6SLl3SBVtmbmKzZeOna7pH6yGPqU8h414IxdpyOJ(dCE55w9cobctPT3jMagYSzaroGDREbNy1iUbbb34d2YypcdKfncFemmY5VaKEWrXJWVccc(bfGTSGR8sP1Sy2ZWiG5jAkfQmmHy)iwP(tDREbxSyUvVGtGWuA7DIjGHmBgqWpy3QxWjwnIBqqZLJaZt0ukuzycX(rSs9N6w9coWQ)RukHd1HfSMqdNy)iwPq6kh9hs(XILhUxRXWaJcZeakEEMHHI2nCacKrCWrhh6xu0qaZt0ukuzycX(rSs9N6w9cU8JflpCVwJHbgfg9xPdpeX(rSsH0XH(ffneW55w9cobctPT3jMagYSzar8bZdUxRXWaJoBiBqbRjaWZvbSxidFfaDCOFrrdjwm3QxWjqykT9oXeWqMndi4O8bNNLXEegilAe(iyyKZFbi9GJIhHFfee8dkIfdT3A0i8rWWiN)cq6bhThLF(5l5ZT6Xki1zlxUz3ENycyiZMjWRXLh3QxWjqykT9oXeWqMndyEIMsHkdti2pIvQ)u3QxWbop1)vkLWH6WcwtOHtSFeRuiDLJ(djwmCVwJHbgfMjau88mddfTB4aeiJ4GJoo0VOOHKFSy5H71AmmWOWO)kD4Hi2pIvkKoo0VOOHaMh9SzUcamAV1Or4JGHro)fG0doApkFjFUvpwbPoB5Yn7zdzxbiGHmBMaVgx1)vkD2q2vacyiZMHUYr)HaMW3dvmJa0CbfCgCE4ETgddm6SHSbfSMaapxfWEHm8va0XH(ffneWO9wJoBiBqbRjaWZvbSxidFfaThflgp4ETgddm6SHSbfSMaapxfWEHm8va0XH(ffnK8L85w9yfK6SLl3SDODfIx2f414Q(VsPo0UcXl7ORC0FiGZJNOPuOYWeI9JyL6p1T6fC5dopEu)xP0ZUwhhaDLJ(djwmEq7Tg9SR1Xbq7rG5XYypcdKf9SR1Xbq7r5l5ZT6Xki1zlxUz)hh6hIGWbiCHY0re414Q(VsP)XH(HiiCacxOmDe0vo6pejFUvpwbPoB5YnBBOFL4pGqTUciWRXfgT)fQJbMcP2q)kXFaHADfai4iWO9wJs4qDybRj0Wj2pIvkK2Jat47HkMracoHZs(CREScsD2YLB2ZXAOagYSzc8ACX9Anggy0zdzdkynbaEUkG9cz4RaOJd9lkAiG5bT3A0zdzdkynbaEUkG9cz4RaO9ijFUvpwbPoB5Yn73d6c0ogQbEnUimL2ENycyiZMHIhHFfemmA)luhdmfsTH(vI)ac16kaqWrGZJNOPuOYWeI9JyL6p1T6fC5dop0ERrFpOlGDmWO9iW8G2BnkHd1HfSMqdNy)iwPqApcS6)kLs4qDybRj0Wj2pIvkKUYr)HKVKp3QhRGuNTC5M9CSgYHUNzbEnUWO9VqDmWui1g6xj(diuRRaan3CaZdUxRXWaJoBiBqbRjaWZvbSxidFfaDCOFrrdbCEQ)RukHd1HfSMqdNy)iwPq6kh9hcycFpuXmcqZLt4myEq7TgLWH6WcwtOHtSFeRuiThLVKp3QhRGuNTC5M97bDbAhd1aTby)juhdmfYL)aVgxll4kVuAnlM9mmcyCVwJHbgD2q2GcwtaGNRcyVqg(ka64q)IIgcy4ubkR6qQEdNdOsWrrwWO9wJ(Eqxa7yGr7rG5bT3A0i8rWWiN)cq6bhThj5ZT6Xki1zlxUz)EqxG2XqnqBa2Fc1XatHC5pWRXfT3A03d6cyhdmApcmAV1Or4JGHro)fG0doApcCEO9wJgHpcgg58xasp4O4r4xbbr85ualsSyUvVGtGWuA7DIjGHmBgUWO9VqDmWui1g6xj(diuRRaIfZT6fCceMsBVtmbmKzZWn(G5b3R1yyGrNnKnOG1ea45Qa2lKHVcGoo0VOOHelMB1l4eimL2ENycyiZMHlhLVKp3QhRGuNTC5M97bDbAhd1aVgxeMsBVtmbmKzZqXJWVccggT)fQJbMcP2q)kXFaHADfai4iW4ETgddmkmtaO45zggkA3WbiqgXbhDCOFrrdbmAV1OVh0fWogy0Eey1)vkLWH6WcwtOHtSFeRuiDLJ(dbmpO9wJs4qDybRj0Wj2pIvkK2Jat47HkMraAUCcNL85w9yfK6SLl3SFpOlq7yOg414IWuA7DIjGHmBgkEe(vqW5LhmA)luhdmfsTH(vI)ac16kaqWrGX9AnggyuyMaqXZZmmu0UHdqGmIdo64q)IIgcy1)vkLWH6WcwtOHtSFeRuiDLJ(dj)yXYt9FLsjCOoSG1eA4e7hXkfsx5O)qat47HkMraAUCcNbZdAV1OeouhwWAcnCI9JyLcP9iW5XdUxRXWaJoBiBqbRjaWZvbSxidFfaDCOFrrdjwm0ERrNnKnOG1ea45Qa2lKHVcG2JYhmp4ETgddmkmtaO45zggkA3WbiqgXbhDCOFrrdj)8L85w9yfK6SLl3SFpOlq7yOg414IWuA7DIjGHmBgkEe(vqWWO9VqDmWui1g6xj(diuRRa4YrGX9AnggyuyMaqXZZmmu0UHdqGmIdo64q)IIgcy0ERrFpOlGDmWO9iWQ)RukHd1HfSMqdNy)iwPq6kh9hcyEq7TgLWH6WcwtOHtSFeRuiThbMW3dvmJa0C5eol5ZT6Xki1zlxUzphRHCO7zwGxJlmA)luhdmfsTH(vI)ac16kaqZnhjFUvpwbPoB5YnBBOFL4pGqTUciWRXfT3AuOYWez2IgMIhHFfeeXNtbSiCkAV1OqLHjYSfnmfQUnJKp3QhRGuNTC5M97bDbAhd1aTby)juhdmfYL)aVgx4ubkR6qQEdNdOsWrrwWO9wJ(Eqxa7yGr7rG5bT3A0i8rWWiN)cq6bhThj5ZT6Xki1zlxUz)EqxG2XqnWRXfovGYQoKQ3W5aQeCuKfmAV1OVh0fWogy0EeyEq7TgncFemmY5VaKEWr7rs(CREScsD2YLB2Vh0fODmud8ACr7Tg99GUa2XaJ2JadJ2)c1XatHuBOFL4pGqTUcaeCe484jAkfQmmHy)iwP(tDREbx(GrykT9oXeWqMndvpBMRaK85w9yfK6SLl3S3pIvQ)c03HAGxJR6)kLUFeRu)fOVdv6kh9hcyy0(xOogykKAd9Re)beQ1vaGGtaNhprtPqLHje7hXk1FQB1l4YxYNB1JvqQZwUCZ(9GUaDorGxJR6)kL6q7keVSJUYr)Hi5ZT6Xki1zlxUzBd9Re)beQ1vas(CREScsD2YLB2Vh0fODmudKGf8kaU8h414I2Bn67bDbSJbgThb2YypcdKLap3Qs(CREScsD2YLB2T3jMagYSzcKGf8kaU8hOna7pH6yGPqU8h414IxdpyOJ(tYNB1JvqQZwUCZUHzqvadz2mbsWcEfax(L8j5ZT6Xkifob8kGFc1Xat5cvgMqSFeRu)L85w9yfKcNaEfWpH6yGP5Yn7)ac16kabk71aVgx0ERrHDmWeSMiIbYHP9ijFUvpwbPWjGxb8tOogyAUCZocFemmY5VaKEWfOna7pH6yGPqU8h414Azbx5LsRzXSNHraZdAV1Or4JGHro)fG0doApcmpO9wJcJ(R0HhIy)iwPqApsYNB1JvqkCc4va)eQJbMMl3SxatWAcnCcOYWebEnUO9wJA9)f)beQ1vau8i8RGGMl)CwYNB1JvqkCc4va)eQJbMMl3SBygufWqMntGxJR6)kLE2164aORC0FiGr7Tg9SR1Xbq7rGr7Tg9SR1XbqXJWVccc4u9kaifQUnJaT3AdZPaweofT3A0ZUwhhafQUndy0ERrb5vicGouPq1Tzab)GkjFUvpwbPWjGxb8tOogyAUCZU9oXeWqMntG2aS)eQJbMc5YFGxJlEn8GHo6pjFUvpwbPWjGxb8tOogyAUCZUHzqvadz2mbEnUQ)Ru6zxRJdGUYr)HagT3A0ZUwhhaThbgT3A0ZUwhhafpc)kii4NYpNcyr4u0ERrp7ADCauO62ms(CREScsHtaVc4NqDmW0C5M9(rSs9xG(oud8ACv)xP09JyL6Va9DOsx5O)qK85w9yfKcNaEfWpH6yGP5YnBOYWez2IgoWRXv9FLsHkdtKzlAy6kh9hIKp3QhRGu4eWRa(juhdmnxUzpBi7kabmKzZe414Q(VsPZgYUcqadz2m0vo6peWwg7ryGSOVh0fODmuP4r4xbbbxalcyy0(xOogykKAd9Re)beQ1vaGiNyXi89qfZianxqbNbdJ2)c1XatHuBOFL4pGqTUca0CZbCE8G71AmmWOZgYguWAca8Cva7fYWxbqhh6xu0qIfdT3A0zdzdkynbaEUkG9cz4RaO9O8L85w9yfKcNaEfWpH6yGP5Yn73d6c0ogQbEnU5H2BnkiVcra0HkfQUndi4hubMh0ERrrFgd57qL2JYpwm0ERrFpOlGDmWO9ijFUvpwbPWjGxb8tOogyAUCZ(9GUaTJHAGxJR6)kLoBi7kabmKzZqx5O)qaJ2Bn6SHSRaeWqMndThbggT)fQJbMcP2q)kXFaHADfaiYrYNB1JvqkCc4va)eQJbMMl3SNJ1qo09mlWRXv9FLsNnKDfGagYSzORC0FiGr7TgD2q2vacyiZMH2JadJ2)c1XatHuBOFL4pGqTUca0CZrYNB1JvqkCc4va)eQJbMMl3S)diuRRaeOSxd8ACr7TgfQmmrMTOHP9ijFUvpwbPWjGxb8tOogyAUCZEowd5q3ZSaVgx0ERrNnKnOG1ea45Qa2lKHVcG2JK85w9yfKcNaEfWpH6yGP5Yn75ynuadz2mbEnUWO9VqDmWui1g6xj(diuRRaaroGj89qfZianxqbNbNhAV1OG8kebqhQuO62mGihohlgHVhQygbO54Co)yXYd3R1yyGrNnKnOG1ea45Qa2lKHVcGoo0VOOHaMh0ERrNnKnOG1ea45Qa2lKHVcG2JYpwmCVwJHbgfKxHaJMNzyO49GUapyhdSYo64q)IIgIKp3QhRGu4eWRa(juhdmnxUzphRHCO7zwGxJBEWO9VqDmWui1g6xj(diuRRaan)5dopEqykT9oXeWqMndfVgEWqh9x(s(CREScsHtaVc4NqDmW0C5MTn0Vs8hqOwxbe4146w9coXQrCdcA(bhnLcvgMqSFeRu)PUvVGdmAV1OOpJH8DOs7rs(CREScsHtaVc4NqDmW0C5M9FaHADfGaL9AGxJB0ukuzycX(rSs9N6w9coWO9wJI(mgY3HkThj5ZT6Xkifob8kGFc1XatZLB2Vh0fODmud8ACr7Tg1H2viEzhThj5ZT6Xkifob8kGFc1XatZLB2Vh0fODmud8ACTm2JWazjWZTQKp3QhRGu4eWRa(juhdmnxUz)EqxG2XqnWRX1YypcdKLap3QGTHogyqqR(VsPZgYeSMqdNy)iwPq6kh9hIKp3QhRGu4eWRa(juhdmnxUz3WmOkGHmBMaVgx1)vk9SR1Xbqx5O)qaJ2Bn6zxRJdG2JK85w9yfKcNaEfWpH6yGP5YnBBOFLi0XbhuL85w9yfKcNaEfWpH6yGP5Yn72pyOf7nnWRXfY6p6vi0GS317NaY(GRuW8G2BnAq2769tazFWvQiSt4f7qO9OaVshg3JuXrqmKZ1XL)aVshg3JubWZq9Nl)bELomUhPIRXfY6p6vi0GS317NaY(GRujFUvpwbPWjGxb8tOogyAUCZgQUEwbYbTHogybEnUQ)RukuD9ScKdAdDmWORC0Fis(CREScsHtaVc4NqDmW0C5M9CSgk2pIvQ)bEnU8O(VsPr4JWFX(rSs9)GkDLJ(djwm1)vkncFe(l2pIvQ)huPRC0FiGZJNOPuOYWeI9JyL6p1T6fC5l5ZT6Xkifob8kGFc1XatZLB22q)kXFaHADfqGxJRB1l4eRgXniO5hCEWO9VqDmWui1g6xj(diuRRaan)XIbJ2)c1XatH03d6c05eGM)8L85w9yfKcNaEfWpH6yGP5Yn7)ac16kabk7vjFUvpwbPWjGxb8tOogyAUCZU9oXeWqMntGeSGxbWL)aTby)juhdmfYL)aVgx8A4bdD0Fs(CREScsHtaVc4NqDmW0C5MD7DIjGHmBMajybVcGl)bEnUeSGJyLsroO6LDGgui5ZT6Xkifob8kGFc1XatZLB2nmdQcyiZMjqcwWRa4YVKpjFUvpwbPWRa(juhdmL7FaHADfGaL9AGxJBEO9wJcvgMiZw0Wu8i8RGGaovVcasHQBZiq7T2WCkGfHtr7TgfQmmrMTOHPq1TzYxYNB1Jvqk8kGFc1XatZLB2nmdQcyiZMjWRXv9FLsp7ADCa0vo6peWO9wJE2164aO9iWO9wJE2164aO4r4xbbbCQEfaKcv3MrG2BTH5ualcNI2Bn6zxRJdGcv3MrYNB1Jvqk8kGFc1XatZLB2T3jMagYSzc0gG9NqDmWuix(d8ACZJh9SzUciwmeMsBVtmbmKzZqXJWVcccUawKyXu)xPuhAxH4LD0vo6peWimL2ENycyiZMHIhHFfee5zzShHbYI6q7keVSJIhHFfmx0ERrDODfIx2rr6yxpwLpylJ9imqwuhAxH4LDu8i8RGGGJYhCEO9wJ(Eqxa7yGr7rXIXdAV1OOpJH8DOs7r5l5ZT6XkifEfWpH6yGP5Yn727etadz2mbAdW(tOogykKl)bEnUO9wJgHpcgg58xasp4O9iW41Wdg6O)K85w9yfKcVc4NqDmW0C5MTdTRq8YUaVgx1)vk1H2viEzhDLJ(dbCE6rmqZfuW5yXq7Tgf9zmKVdvApkFW5zzShHbYI(EqxG2XqLIhHFfe0CoFW5XJ6)kLE2164aORC0FiXIXdAV1ONDTooaApcmpwg7ryGSONDTooaApkFjFUvpwbPWRa(juhdmnxUz)EqxG2XqnWRXfT3A03d6cyhdmApcCE4ETgddmkiVcbgnpZWqX7bDbEWogyLD0XH(ffnKyX4bT3AuchQdlynHgoX(rSsH0Eey1)vkLWH6WcwtOHtSFeRuiDLJ(djFjFUvpwbPWRa(juhdmnxUzVFeRu)fOVd1aVgx1)vkD)iwP(lqFhQ0vo6peW5r47HkMraI4nNZxYNB1Jvqk8kGFc1XatZLB2qLHjYSfnCGxJR6)kLcvgMiZw0W0vo6peW5H9drSGRuQJGaPwwVuqe)yXW(HiwWvk1rqG0RanNW58bNhHVhQygbi4iokFjFUvpwbPWRa(juhdmnxUzpBi7kabmKzZe414Q(VsPZgYUcqadz2m0vo6peWwg7ryGSOVh0fODmuP4r4xbbbxalIKp3QhRGu4va)eQJbMMl3SFpOlq7yOg414Q(VsPZgYUcqadz2m0vo6peWO9wJoBi7kabmKzZq7rs(CREScsHxb8tOogyAUCZ(po0pebHdq4cLPJiWRXv9FLs)Jd9drq4aeUqz6iORC0Fis(CREScsHxb8tOogyAUCZEowd5q3ZSaVgx0ERrNnKnOG1ea45Qa2lKHVcG2JaR(VsPeouhwWAcnCI9JyLcPRC0FiGr7TgLWH6WcwtOHtSFeRuiThj5ZT6XkifEfWpH6yGP5Yn7)ac16kabk71aVgx0ERrHkdtKzlAyApcmAV1OeouhwWAcnCI9JyLcP9iWe(EOIzeGauWzjFUvpwbPWRa(juhdmnxUzphRHCO7zwGxJlAV1OZgYguWAca8Cva7fYWxbq7rGZt9FLsjCOoSG1eA4e7hXkfsx5O)qaNhAV1OeouhwWAcnCI9JyLcP9OyXSm2JWazrFpOlq7yOsXJWVccAodMW3dvmJa0C545elgmA)luhdmfsTH(vI)ac16kaqKdy0ERrHkdtKzlAyApcSLXEegil67bDbAhdvkEe(vqqWfWIKFSy8O(VsPeouhwWAcnCI9JyLcPRC0FiXIzzShHbYIUFeRu)fOVdvkEe(vqqWfovVcasHQBZiq7T2WCkGfHtZjFjFUvpwbPWRa(juhdmnxUzphRHCO7zwGxJlmA)luhdmfsTH(vI)ac16kaqZpyEqykT9oXeWqMndfVgEWqh9hyEW9Anggy0zdzdkynbaEUkG9cz4RaOJd9lkAiGZJh1)vkLWH6WcwtOHtSFeRuiDLJ(djwm0ERrjCOoSG1eA4e7hXkfs7rXIzzShHbYI(EqxG2XqLIhHFfe0CgmHVhQygbO5YXZjFjFUvpwbPWRa(juhdmnxUz)EqxG2XqnWRX1YypcdKLap3QGZJh0ERrjCOoSG1eA4e7hXkfs7rGr7Tg9SR1Xbq7r5l5ZT6XkifEfWpH6yGP5Yn73d6c0ogQbEnUwg7ryGSe45wfSn0XadcA1)vkD2qMG1eA4e7hXkfsx5O)qaZdAV1ONDTooaApsYNB1Jvqk8kGFc1XatZLB2Vh0fODmud8ACv)xP0zdzcwtOHtSFeRuiDLJ(dbmpO9wJs4qDybRj0Wj2pIvkK2Jat47HkMraAUCcNbZdAV1OZgYguWAca8Cva7fYWxbq7rs(CREScsHxb8tOogyAUCZEowdfWqMntGxJBE4ETgddm6SHSbfSMaapxfWEHm8va0XH(ffnKyXGr7FH6yGPqQn0Vs8hqOwxbaICYhCEQ)RukHd1HfSMqdNy)iwPq6kh9hcyEq7TgD2q2GcwtaGNRcyVqg(kaApcCEO9wJs4qDybRj0Wj2pIvkK2JIfJW3dvmJa0C545elgmA)luhdmfsTH(vI)ac16kaqKdy0ERrHkdtKzlAyApcSLXEegil67bDbAhdvkEe(vqqWfWIKFSy8O(VsPeouhwWAcnCI9JyLcPRC0FiXIzzShHbYIUFeRu)fOVdvkEe(vqqWfovVcasHQBZiq7T2WCkGfHtZjFjFUvpwbPWRa(juhdmnxUz3WmOkGHmBMaVgx1)vk9SR1Xbqx5O)qaR(VsPeouhwWAcnCI9JyLcPRC0FiGr7Tg9SR1Xbq7rGr7TgLWH6WcwtOHtSFeRuiThj5ZT6XkifEfWpH6yGP5Yn73d6c0ogQbEnUO9wJ6q7keVSJ2JK85w9yfKcVc4NqDmW0C5M97bDbAhd1aVgxlJ9imqwc8CRcMh1)vkLWH6WcwtOHtSFeRuiDLJ(drYNB1Jvqk8kGFc1XatZLB2NDTooGaVgx1)vk9SR1Xbqx5O)qaZtEe(EOIzeGo(CcylJ9imqw03d6c0ogQu8i8RGGGlNZxYNB1Jvqk8kGFc1XatZLB2nmdQcyiZMjWRXv9FLsp7ADCa0vo6peWO9wJE2164aO9iW5H2Bn6zxRJdGIhHFfeeaweoLJ4u0ERrp7ADCauO62mXIH2BnkuzyImBrdt7rXIXJ6)kLs4qDybRj0Wj2pIvkKUYr)HKVKp3QhRGu4va)eQJbMMl3SFpOlq7yOk5ZT6XkifEfWpH6yGP5Yn727etadz2mbAdW(tOogykKl)bEnU41Wdg6O)K85w9yfKcVc4NqDmW0C5MDdZGQagYSzc8ACX9Anggy09JyL6VyCOF)HIVobDCOFrrdbmpO9wJUFeRu)fJd97pu81jeidT3A0EeyEu)xP09JyL6Va9DOsx5O)qaZJ6)kLoBi7kabmKzZqx5O)qK85w9yfKcVc4NqDmW0C5MD7hm0I9Mg414cz9h9keAq2769tazFWvkyEq7Tgni7D9(jGSp4kve2j8IDi0EuGxPdJ7rQ4iigY564YFGxPdJ7rQa4zO(ZL)aVshg3JuX14cz9h9keAq2769tazFWvQKp3QhRGu4va)eQJbMMl3STH(vIqhhCqvYNB1Jvqk8kGFc1XatZLB2nmdQcyiZMjWRXv9FLsp7ADCa0vo6peWO9wJE2164aO9ijFUvpwbPWRa(juhdmnxUzdvxpRa5G2qhdSaVgx1)vkfQUEwbYbTHogy0vo6pejFUvpwbPWRa(juhdmnxUzphRHI9JyL6FGxJlpQ)RuAe(i8xSFeRu)pOsx5O)qIfJNOP02HNy)iwP(tDREbNKp3QhRGu4va)eQJbMMl3STH(vI)ac16kGaVgxy0(xOogykKAd9Re)beQ1vaGMFjFUvpwbPWRa(juhdmnxUz)hqOwxbiqzVk5ZT6XkifEfWpH6yGP5Yn727etadz2mbsWcEfax(d0gG9NqDmWuix(d8ACXRHhm0r)j5ZT6XkifEfWpH6yGP5Yn727etadz2mbsWcEfax(d8ACjybhXkLICq1l7anOqYNB1Jvqk8kGFc1XatZLB2nmdQcyiZMjqcwWRa4YVKp3QhRGu4va)eQJbMMl3SBygufWqMntGxJR6)kLE2164aORC0FiGr7Tg9SR1Xbq7rGr7Tg9SR1XbqXJWVccc4u9kaifQUnJaT3AdZPaweofT3A0ZUwhhafQUnJHm4WWJvgEZHZ5KdNZjN4nLFdjiDCDfa0qgpq8qqn4fuNxqnJNKjzkRWjthredRYuJHLjog8kGFc1Xat5yYeECOF4HitqgXKjVRmcxhImzd9cyqQKV4LRMmLdOkEsMINzvWH1HitCmiR)OxHqJx5yYKYKjogK1F0RqOXR0vo6peoMmLh)XJ5tL8j5lEG4HGAWlOoVGAgpjtYuwHtMoIigwLPgdltCSi8Smcux5yYeECOF4HitqgXKjVRmcxhImzd9cyqQKV4LRMmLt8KmfpZQGdRdrM4yqw)rVcHgVYXKjLjtCmiR)OxHqJxPRC0FiCmzkp(JhZNk5lE5Qjt5epjtXZSk4W6qKjogK1F0RqOXRCmzszYehdY6p6vi04v6kh9hchtMCvMaLak94fzkp(JhZNk5tYx8aXdb1GxqDEb1mEsMKPScNmDermSktngwM4yWjGxb8tOogykhtMWJd9dpezcYiMm5DLr46qKjBOxadsL8fVC1KPC4K4jzkEMvbhwhImXXGS(JEfcnELJjtktM4yqw)rVcHgVsx5O)q4yYuE8hpMpvYNKpqDIigwhImXjYKB1JvY0FqfsL8zi)dQqtwgs4va)eQJbMAYYWl)MSmKRC0FiM4mKw8PdFUHmpzcT3AuOYWez2IgMIhHFfuMaHmbNQxbaPq1TzeO9wByzItLjalImXPYeAV1OqLHjYSfnmfQUnJmLVH0T6Xkd5FaHADfGaL9Qrn8MJjld5kh9hIjodPfF6WNBiv)xP0ZUwhhaDLJ(drMaltO9wJE2164aO9izcSmH2Bn6zxRJdGIhHFfuMaHmbNQxbaPq1TzeO9wByzItLjalImXPYeAV1ONDTooakuDBgdPB1JvgYgMbvbmKzZyudVX3KLHCLJ(dXeNH0T6Xkdz7DIjGHmBgdPfF6WNBiZtM4rM0ZM5kazkwmzcHP027etadz2mu8i8RGYei4ktawezkwmzs9FLsDODfIx2rx5O)qKjWYectPT3jMagYSzO4r4xbLjqit5jtwg7ryGSOo0UcXl7O4r4xbLPCLj0ERrDODfIx2rr6yxpwjt5ltGLjlJ9imqwuhAxH4LDu8i8RGYeiKjosMYxMalt5jtO9wJ(Eqxa7yGr7rYuSyYepYeAV1OOpJH8DOs7rYu(gsBa2Fc1XatHgE53OgE5itwgYvo6petCgs3QhRmKT3jMagYSzmKw8PdFUHeT3A0i8rWWiN)cq6bhThjtGLj8A4bdD0FgsBa2Fc1XatHgE53OgE5etwgYvo6petCgsl(0Hp3qQ(VsPo0UcXl7ORC0FiYeyzkpzspIjtGMRmbk4SmflMmH2Bnk6ZyiFhQ0EKmLVmbwMYtMSm2JWazrFpOlq7yOsXJWVcktGwM4SmLVmbwMYtM4rMu)xP0ZUwhhaDLJ(drMIftM4rMq7Tg9SR1Xbq7rYeyzIhzYYypcdKf9SR1Xbq7rYu(gs3QhRmKo0UcXl7mQHxqHjld5kh9hIjodPfF6WNBir7Tg99GUa2XaJ2JKjWYuEYeUxRXWaJcYRqGrZZmmu8EqxGhSJbwzhDCOFrrdrMIftM4rMq7TgLWH6WcwtOHtSFeRuiThjtGLj1)vkLWH6WcwtOHtSFeRuiDLJ(drMY3q6w9yLH89GUaTJHQrn8gVnzzix5O)qmXziT4th(CdP6)kLUFeRu)fOVdv6kh9hImbwMYtMi89qfZiKjqitXBolt5BiDRESYqUFeRu)fOVdvJA4fuzYYqUYr)HyIZqAXNo85gs1)vkfQmmrMTOHPRC0FiYeyzkpzc7hIybxPuhbbsTSEPYeiKP4ltXIjty)qel4kL6iiq6vYeOLjoHZYu(YeyzkpzIW3dvmJqMaHmXrCKmLVH0T6XkdjuzyImBrdBudVCCtwgYvo6petCgsl(0Hp3qQ(VsPZgYUcqadz2m0vo6pezcSmzzShHbYI(EqxG2XqLIhHFfuMabxzcWIyiDRESYqoBi7kabmKzZyudV8ZztwgYvo6petCgsl(0Hp3qQ(VsPZgYUcqadz2m0vo6pezcSmH2Bn6SHSRaeWqMndThziDRESYq(EqxG2Xq1OgE5NFtwgYvo6petCgsl(0Hp3qQ(VsP)XH(HiiCacxOmDe0vo6pedPB1JvgY)4q)qeeoaHluMocJA4L)Cmzzix5O)qmXziT4th(CdjAV1OZgYguWAca8Cva7fYWxbq7rYeyzs9FLsjCOoSG1eA4e7hXkfsx5O)qKjWYeAV1OeouhwWAcnCI9JyLcP9idPB1JvgY5ynKdDpZmQHx(JVjld5kh9hIjodPfF6WNBir7TgfQmmrMTOHP9izcSmH2BnkHd1HfSMqdNy)iwPqApsMalte(EOIzeYeiKjqbNnKUvpwzi)diuRRaeOSxnQHx(5itwgYvo6petCgsl(0Hp3qI2Bn6SHSbfSMaapxfWEHm8va0EKmbwMYtMu)xPuchQdlynHgoX(rSsH0vo6pezcSmLNmH2BnkHd1HfSMqdNy)iwPqApsMIftMSm2JWazrFpOlq7yOsXJWVcktGwM4SmbwMi89qfZiKjqZvM445itXIjtWO9VqDmWui1g6xj(diuRRaKjqit5itGLj0ERrHkdtKzlAyApsMaltwg7ryGSOVh0fODmuP4r4xbLjqWvMaSiYu(YuSyYepYK6)kLs4qDybRj0Wj2pIvkKUYr)HitXIjtwg7ryGSO7hXk1Fb67qLIhHFfuMabxzcovVcasHQBZiq7T2WYeNktawezItLPCKP8nKUvpwziNJ1qo09mZOgE5Ntmzzix5O)qmXziT4th(CdjmA)luhdmfsTH(vI)ac16kazc0Ye)YeyzIhzcHP027etadz2mu8A4bdD0FYeyzIhzc3R1yyGrNnKnOG1ea45Qa2lKHVcGoo0VOOHitGLP8KjEKj1)vkLWH6WcwtOHtSFeRuiDLJ(drMIftMq7TgLWH6WcwtOHtSFeRuiThjtXIjtwg7ryGSOVh0fODmuP4r4xbLjqltCwMalte(EOIzeYeO5ktC8CKP8nKUvpwziNJ1qo09mZOgE5huyYYqUYr)HyIZqAXNo85gslJ9imqwc8CRktGLP8KjEKj0ERrjCOoSG1eA4e7hXkfs7rYeyzcT3A0ZUwhhaThjt5BiDRESYq(EqxG2Xq1OgE5pEBYYqUYr)HyIZqAXNo85gslJ9imqwc8CRktGLjBOJbguMaTmP(VsPZgYeSMqdNy)iwPq6kh9hImbwM4rMq7Tg9SR1Xbq7rgs3QhRmKVh0fODmunQHx(bvMSmKRC0FiM4mKw8PdFUHu9FLsNnKjynHgoX(rSsH0vo6pezcSmXJmH2BnkHd1HfSMqdNy)iwPqApsMalte(EOIzeYeO5ktCcNLjWYepYeAV1OZgYguWAca8Cva7fYWxbq7rgs3QhRmKVh0fODmunQHx(54MSmKRC0FiM4mKw8PdFUHmpzc3R1yyGrNnKnOG1ea45Qa2lKHVcGoo0VOOHitXIjtWO9VqDmWui1g6xj(diuRRaKjqit5it5ltGLP8Kj1)vkLWH6WcwtOHtSFeRuiDLJ(drMalt8itO9wJoBiBqbRjaWZvbSxidFfaThjtGLP8Kj0ERrjCOoSG1eA4e7hXkfs7rYuSyYeHVhQygHmbAUYehphzkwmzcgT)fQJbMcP2q)kXFaHADfGmbczkhzcSmH2BnkuzyImBrdt7rYeyzYYypcdKf99GUaTJHkfpc)kOmbcUYeGfrMYxMIftM4rMu)xPuchQdlynHgoX(rSsH0vo6pezkwmzYYypcdKfD)iwP(lqFhQu8i8RGYei4ktWP6vaqkuDBgbAV1gwM4uzcWIitCQmLJmLVH0T6Xkd5CSgkGHmBgJA4nhoBYYqUYr)HyIZqAXNo85gs1)vk9SR1Xbqx5O)qKjWYK6)kLs4qDybRj0Wj2pIvkKUYr)HitGLj0ERrp7ADCa0EKmbwMq7TgLWH6WcwtOHtSFeRuiThziDRESYq2WmOkGHmBgJA4nh(nzzix5O)qmXziT4th(CdjAV1Oo0UcXl7O9idPB1JvgY3d6c0ogQg1WBo5yYYqUYr)HyIZqAXNo85gslJ9imqwc8CRktGLjEKj1)vkLWH6WcwtOHtSFeRuiDLJ(dXq6w9yLH89GUaTJHQrn8Mt8nzzix5O)qmXziT4th(CdP6)kLE2164aORC0FiYeyzIhzkpzIW3dvmJqMaTmfForMaltwg7ryGSOVh0fODmuP4r4xbLjqWvM4SmLVH0T6Xkd5zxRJdWOgEZHJmzzix5O)qmXziT4th(CdP6)kLE2164aORC0FiYeyzcT3A0ZUwhhaThjtGLP8Kj0ERrp7ADCau8i8RGYeiKjalImXPYehjtCQmH2Bn6zxRJdGcv3MrMIftMq7TgfQmmrMTOHP9izkwmzIhzs9FLsjCOoSG1eA4e7hXkfsx5O)qKP8nKUvpwziBygufWqMnJrn8MdNyYYq6w9yLH89GUaTJHQHCLJ(dXeNrn8MdOWKLHCLJ(dXeNH0T6Xkdz7DIjGHmBgdPfF6WNBiXRHhm0r)ziTby)juhdmfA4LFJA4nN4Tjld5kh9hIjodPfF6WNBiX9Anggy09JyL6VyCOF)HIVobDCOFrrdrMalt8itO9wJUFeRu)fJd97pu81jeidT3A0EKmbwM4rMu)xP09JyL6Va9DOsx5O)qKjWYepYK6)kLoBi7kabmKzZqx5O)qmKUvpwziBygufWqMnJrn8MdOYKLHCLJ(dXeNH0IpD4ZnKqw)rVcHgK9UE)eq2hCLsx5O)qKjWYepYeAV1ObzVR3pbK9bxPIWoHxSdH2JmKxPdJ7rQ4AgsiR)OxHqdYExVFci7dUsnKxPdJ7rQ4iigY56mK8BiDRESYq2(bdTyVPgYR0HX9iva8mu)nK8BudV5WXnzziDRESYqAd9ReHoo4GQHCLJ(dXeNrn8gFoBYYqUYr)HyIZqAXNo85gs1)vk9SR1Xbqx5O)qKjWYeAV1ONDTooaApYq6w9yLHSHzqvadz2mg1WB853KLHCLJ(dXeNH0IpD4ZnKQ)RukuD9ScKdAdDmWORC0Figs3QhRmKq11ZkqoOn0XaZOgEJFoMSmKRC0FiM4mKw8PdFUHKhzs9FLsJWhH)I9JyL6)bv6kh9hImflMmXJmfnL2o8e7hXk1FQB1l4mKUvpwziNJ1qX(rSs93OgEJF8nzzix5O)qmXziT4th(CdjmA)luhdmfsTH(vI)ac16kazc0Ye)gs3QhRmK2q)kXFaHADfGrn8gFoYKLH0T6Xkd5FaHADfGaL9QHCLJ(dXeNrn8gFoXKLHKGf8kadV8Bix5O)eeSGxbyIZq6w9yLHS9oXeWqMnJH0gG9NqDmWuOHx(nKw8PdFUHeVgEWqh9NHCLJ(dXeNrn8gFqHjld5kh9hIjod5kh9NGGf8katCgsl(0Hp3qsWcoIvkf5GQx2jtGwMafgs3QhRmKT3jMagYSzmKeSGxby4LFJA4n(XBtwgscwWRam8YVHCLJ(tqWcEfGjodPB1JvgYgMbvbmKzZyix5O)qmXzudVXhuzYYqUYr)HyIZqAXNo85gs1)vk9SR1Xbqx5O)qKjWYeAV1ONDTooaApsMaltO9wJE2164aO4r4xbLjqitWP6vaqkuDBgbAV1gwM4uzcWIitCQmH2Bn6zxRJdGcv3MXq6w9yLHSHzqvadz2mg1OgsK18(RMSm8YVjld5kh9hIjodjYGw8fPhRmKG6LomUhPYeRjtwhQqQH0T6XkdjiVcradNJnQH3CmzzijybVcWWl)gYvo6pbbl4vaM4mKUvpwziHrh(uq6FMHHcaSBNHCLJ(dXeNrn8gFtwgs3QhRmKrm9yLHCLJ(dXeNrn8YrMSmKUvpwzi7WjoDeqd5kh9hIjoJA4Ltmzzix5O)qmXziT4th(CdzEYepYK6)kLUFeRu)fOVdv6kh9hImLVmbwM4rM0ZM5kazcSmXJmfnLcvgMqSFeRu)PUvVGtMalt5jtWO9VqDmWui1g6xj(diuRRaKjqitXxMIftMu)xPuchQdlynHgoX(rSsH0vo6pezkwmzc3R1yyGrHzcafppZWqr7goabYio4OJd9lkAiYu(gs3QhRmKT3jMagYSzmQHxqHjld5kh9hIjodPB1JvgYi8rWWiN)cq6bNH0IpD4ZnK8itO9wJgHpcgg58xasp4O9izcSmLNmXJmfnLcvgMqSFeRu)PUvVGtMIftMGr7FH6yGPqQn0Vs8hqOwxbitGqMIVmbwMq7TgfKxHia6qLcv3MrMaHmLdNLPyXKjiR)OxHq)5ic0aelE0jI(rx5O)qKPyXKjCVwJHbgfg9xPdpeX(rSsH0XH(ffnezkFzcSmLNmbJ2)c1XatHuBOFL4pGqTUcqMaHmXjYuSyYK6)kLs4qDybRj0Wj2pIvkKUYr)HitXIjt4ETgddmkmtaO45zggkA3WbiqgXbhDCOFrrdrMIftMGS(JEfc9NJiqdqS4rNi6hDLJ(drMIftMW9Anggyuy0FLo8qe7hXkfshh6xu0qKP8LjWYepYeAV1OWO)kD4Hi2pIvkK2JmK2aS)eQJbMcn8YVrn8gVnzzix5O)qmXziT4th(CdjpYKE2mxbitGLP8KjEKPOPuOYWeI9JyL6p1T6fCYuSyYemA)luhdmfsTH(vI)ac16kazceYu8LjWYeAV1OG8kebqhQuO62mYeiKPC4SmLVmbwMYtMGr7FH6yGPqQn0Vs8hqOwxbitGqMIVmflMmP(VsPeouhwWAcnCI9JyLcPRC0FiYuSyYeUxRXWaJcZeakEEMHHI2nCacKrCWrhh6xu0qKP8nKUvpwziBVtmbmKzZyudVGktwgs3QhRmKTdpX(rSs93qUYr)HyIZOgE54MSmKUvpwzijMog2qUYr)HyIZOgE5NZMSmKRC0FiM4mKw8PdFUHKhzs9FLsDODfIx2rx5O)qKPyXKj0ERrDODfIx2r7rYuSyYKLXEegilQdTRq8YokEe(vqzc0YeNWzdPB1Jvgs0NXqeTooaJA4LF(nzzix5O)qmXziT4th(CdjpYK6)kL6q7keVSJUYr)HitXIjtO9wJ6q7keVSJ2JmKUvpwzirhgoCMRamQHx(ZXKLHCLJ(dXeNH0IpD4ZnK8itQ)RuQdTRq8Yo6kh9hImflMmH2BnQdTRq8YoApsMIftMSm2JWazrDODfIx2rXJWVcktGwM4eoBiDRESYq2o8qFgdXOgE5p(MSmKRC0FiM4mKw8PdFUHKhzs9FLsDODfIx2rx5O)qKPyXKj0ERrDODfIx2r7rYuSyYKLXEegilQdTRq8YokEe(vqzc0YeNWzdPB1JvgsVSdQy)fw)FJA4LFoYKLHCLJ(dXeNH0IpD4ZnK8itQ)RuQdTRq8Yo6kh9hImflMmXJmH2BnQdTRq8YoApYq6w9yLHe1beSMqXNnd0OgE5NtmzziDRESYqgCWOHfkthHHCLJ(dXeNrn8YpOWKLHCLJ(dXeNH0IpD4ZnKwwWvEP06acvrZNmbwM4rMW9Anggyu4gcuWAcSte5LkaWmqQH0XH(ffnezcSmLNmXJmP(VsPeouhwWAcnCI9JyLcPRC0FiYuSyYeAV1OeouhwWAcnCI9JyLcP9izkFzcSmbJ2)c1XatHuBOFL4pGqTUcqMaHmfFdPB1JvgYMpHI9c26WJvg1Wl)XBtwgYvo6petCgsl(0Hp3qAzbx5LsRdiufnFYeyzc3R1yyGrHBiqbRjWorKxQaaZaPgshh6xu0qKjWYuEYepYK6)kLs4qDybRj0Wj2pIvkKUYr)HitXIjtO9wJs4qDybRj0Wj2pIvkK2JKPyXKjy0(xOogykKAd9Re)beQ1vaYeO5ktXxMYxMalt5jtwg7ryGSOTdpX(rSs9NIhHFfuMaTmLdNLPyXKjlJ9imqwuOYWeI9JyL6pfpc)kOmbAzkholt5BiDRESYq28juSxWwhESYOgE5huzYYqUYr)HyIZqAXNo85gs3QxWjwnIBqzc0YuoYeyzkpzcgT)fQJbMcP2q)kXFaHADfGmbAzkhzkwmzcgT)fQJbMcPVh0fOZjKjqlt5it5BiHk(SQHx(nKUvpwziX9s4w9yL4pOAi)dQIYjMH0zZOgE5NJBYYqUYr)HyIZqAXNo85gsEKj1)vkfQmmHy)iwP(tx5O)qKjWYKB1l4eRgXnOmbcUYuogsOIpRA4LFdPB1JvgsCVeUvpwj(dQgY)GQOCIziHxb8tOogyQrn8MdNnzzix5O)qmXziT4th(CdP6)kLcvgMqSFeRu)PRC0FiYeyzYT6fCIvJ4guMabxzkhdjuXNvn8YVH0T6XkdjUxc3QhRe)bvd5FqvuoXmKWjGxb8tOogyQrnQHmcplJa1vtwgE53KLHCLJ(dXeNH0T6Xkd5CSgk2pIvQ)gsKbT4lspwzibLepoBxhImTGdhGmPhXKjnCYKBvgwMoOm5b97D0FudPfF6WNBi5rMu)xP0i8r4Vy)iwP(FqLUYr)HyudV5yYYqUYr)HyIZq6w9yLHS9dgAXEtnKidAXxKESYqckn4KjsLHjYSfnSmfHNLrG6Qm1RFqOmbzetMCeeOmbY7Fzcg5GSKjiJvudPfF6WNBiHS(JEfcnQd1(pXW9i9yfDLJ(drMIftMGS(JEfcni7D9(jGSp4kLUYr)HyudVX3KLHCLJ(dXeNH0IpD4ZnKQ)RukuzyImBrdtx5O)qKjWYuEYe2peXcUsPoccKAz9sLjqitXxMIftMW(HiwWvk1rqG0RKjqltCcNLP8nKUvpwziHkdtKzlAyJA4LJmzziDRESYq2o8e7hXk1Fd5kh9hIjoJA4Ltmzzix5O)qmXziT4th(CdP6)kLUFeRu)fOVdv6kh9hImbwMGr7FH6yGPqQn0Vs8hqOwxbitGqMIVH0T6Xkd5(rSs9xG(ounQHxqHjld5kh9hIjodPB1JvgY3d6c0ogQgY)QjSigY4BiT4th(CdjpYK6)kLUFeRu)fOVdv6kh9hImbwMGr7FH6yGPqQn0Vs8hqOwxbitGqMIVmflMmH2BnkuzyImBrdt7rgsKbT4lspwziJBwVdNmfVemozk0HYKltk2dUxM0JybktA4KjhbHvYu072bLjovdpOmTsXbWPYeRKP454bLPgdltXxMGZYkeOmPmzYdYoezcH1r)bQnEjyCYeRKPO()uJA4nEBYYqUYr)HyIZqAXNo85gsEKj1)vkD)iwP(lqFhQ0vo6pezcSmbJ2)c1XatHuBOFL4pGqTUcqManxzk(YeyzIhzcT3AuOYWez2IgM2JmKUvpwziTH(vI)ac16kaJA4fuzYYq6w9yLHmIPhRmKRC0FiM4mQrnKoBMSm8YVjldPB1JvgsOYWeI9JyL6VHCLJ(dXeNrn8MJjld5kh9hIjodPfF6WNBir7Tg16)l(diuRRaO4r4xbLjqZvM4NZgs3QhRmKlGjynHgobuzycJA4n(MSmKRC0FiM4mKw8PdFUHeT3A0zdzxbiGHmBgApYq6w9yLHCowd5q3ZmJA4LJmzziDRESYqAd9ReHoo4GQHCLJ(dXeNrn8YjMSmKRC0FiM4mKw8PdFUHu9FLsHkdtKzlAy6kh9hIH0T6XkdjuzyImBrdBudVGctwgYvo6petCgs3QhRmKT3jMagYSzmKw8PdFUHeVgEWqh9NmbwMYtMYtMCREbNaHP027etadz2mYeiKPCKjWYKB1l4eRgXnOmbcUYu8LjWYKLXEegilAe(iyyKZFbi9GJIhHFfuMaHmXpOqMaltwwWvEP0Awm7zyezcSmXJmfnLcvgMqSFeRu)PUvVGtMIftMCREbNaHP027etadz2mYeiKj(LjWYKB1l4eRgXnOmbAUYehjtGLjEKPOPuOYWeI9JyL6p1T6fCYeyzs9FLsjCOoSG1eA4e7hXkfsx5O)qKP8LPyXKP8KjCVwJHbgfMjau88mddfTB4aeiJ4GJoo0VOOHitGLjEKPOPuOYWeI9JyL6p1T6fCYu(YuSyYuEYeUxRXWaJcJ(R0HhIy)iwPq64q)IIgImbwMYtMCREbNaHP027etadz2mYeiKP4ltGLjEKjCVwJHbgD2q2GcwtaGNRcyVqg(ka64q)IIgImflMm5w9cobctPT3jMagYSzKjqitCKmLVmbwMYtMSm2JWazrJWhbdJC(laPhCu8i8RGYeiKj(bfYuSyYeAV1Or4JGHro)fG0doApsMYxMYxMY3qAdW(tOogyk0Wl)g1WB82KLHCLJ(dXeNH0IpD4ZnK8itUvVGtGWuA7DIjGHmBgzcSmXJmfnLcvgMqSFeRu)PUvVGtMalt5jtQ)RukHd1HfSMqdNy)iwPq6kh9hImflMmH71AmmWOWmbGINNzyOODdhGazehC0XH(ffnezkFzkwmzkpzc3R1yyGrHr)v6WdrSFeRuiDCOFrrdrMalt8it6zZCfGmbwMq7TgncFemmY5VaKEWr7rYu(gs3QhRmKT3jMagYSzmQHxqLjld5kh9hIjodPfF6WNBiv)xP0zdzxbiGHmBg6kh9hImbwMi89qfZiKjqZvMafCwMalt5jt4ETgddm6SHSbfSMaapxfWEHm8va0XH(ffnezcSmH2Bn6SHSbfSMaapxfWEHm8va0EKmflMmXJmH71AmmWOZgYguWAca8Cva7fYWxbqhh6xu0qKP8nKUvpwziNnKDfGagYSzmQHxoUjld5kh9hIjodPfF6WNBiv)xPuhAxH4LD0vo6pezcSmLNmXJmfnLcvgMqSFeRu)PUvVGtMYxMalt5jt8itQ)Ru6zxRJdGUYr)HitXIjt8itO9wJE2164aO9izcSmXJmzzShHbYIE2164aO9izkFdPB1JvgshAxH4LDg1Wl)C2KLHCLJ(dXeNH0IpD4ZnKQ)Ru6FCOFicchGWfkthbDLJ(dXq6w9yLH8po0pebHdq4cLPJWOgE5NFtwgYvo6petCgsl(0Hp3qcJ2)c1XatHuBOFL4pGqTUcqMaHmXrYeyzcT3AuchQdlynHgoX(rSsH0EKmbwMi89qfZiKjqitCcNnKUvpwziTH(vI)ac16kaJA4L)Cmzzix5O)qmXziT4th(CdjUxRXWaJoBiBqbRjaWZvbSxidFfaDCOFrrdrMalt8itO9wJoBiBqbRjaWZvbSxidFfaThziDRESYqohRHcyiZMXOgE5p(MSmKRC0FiM4mKw8PdFUHeHP027etadz2mu8i8RGYeyzcgT)fQJbMcP2q)kXFaHADfGmbczIJKjWYuEYepYu0ukuzycX(rSs9N6w9cozkFzcSmLNmH2Bn67bDbSJbgThjtGLjEKj0ERrjCOoSG1eA4e7hXkfs7rYeyzs9FLsjCOoSG1eA4e7hXkfsx5O)qKP8nKUvpwziFpOlq7yOAudV8ZrMSmKRC0FiM4mKw8PdFUHegT)fQJbMcP2q)kXFaHADfGmbAUYuoYeyzIhzc3R1yyGrNnKnOG1ea45Qa2lKHVcGoo0VOOHitGLP8Kj1)vkLWH6WcwtOHtSFeRuiDLJ(drMalte(EOIzeYeO5ktCcNLjWYepYeAV1OeouhwWAcnCI9JyLcP9izkFdPB1JvgY5ynKdDpZmQHx(5etwgYvo6petCgs3QhRmKVh0fODmunKw8PdFUH0YcUYlLwZIzpdJitGLjCVwJHbgD2q2GcwtaGNRcyVqg(ka64q)IIgImbwMGtfOSQdP6nCoGkbhfzLjWYeAV1OVh0fWogy0EKmbwM4rMq7TgncFemmY5VaKEWr7rgsBa2Fc1XatHgE53OgE5huyYYqUYr)HyIZq6w9yLH89GUaTJHQH0IpD4ZnKO9wJ(Eqxa7yGr7rYeyzcT3A0i8rWWiN)cq6bhThjtGLP8Kj0ERrJWhbdJC(laPhCu8i8RGYeiKP4ltCQmbyrKPyXKj3QxWjqykT9oXeWqMnJmXvMGr7FH6yGPqQn0Vs8hqOwxbitXIjtUvVGtGWuA7DIjGHmBgzIRmfFzcSmXJmH71AmmWOZgYguWAca8Cva7fYWxbqhh6xu0qKPyXKj3QxWjqykT9oXeWqMnJmXvM4izkFdPna7pH6yGPqdV8BudV8hVnzzix5O)qmXziT4th(CdjctPT3jMagYSzO4r4xbLjWYemA)luhdmfsTH(vI)ac16kazceYehjtGLjCVwJHbgfMjau88mddfTB4aeiJ4GJoo0VOOHitGLj0ERrFpOlGDmWO9izcSmP(VsPeouhwWAcnCI9JyLcPRC0FiYeyzIhzcT3AuchQdlynHgoX(rSsH0EKmbwMi89qfZiKjqZvM4eoBiDRESYq(EqxG2Xq1OgE5huzYYqUYr)HyIZqAXNo85gseMsBVtmbmKzZqXJWVcktGLP8KP8Kjy0(xOogykKAd9Re)beQ1vaYeiKjosMalt4ETgddmkmtaO45zggkA3WbiqgXbhDCOFrrdrMaltQ)RukHd1HfSMqdNy)iwPq6kh9hImLVmflMmLNmP(VsPeouhwWAcnCI9JyLcPRC0FiYeyzIW3dvmJqManxzIt4SmbwM4rMq7TgLWH6WcwtOHtSFeRuiThjtGLP8KjEKjCVwJHbgD2q2GcwtaGNRcyVqg(ka64q)IIgImflMmH2Bn6SHSbfSMaapxfWEHm8va0EKmLVmbwM4rMW9AnggyuyMaqXZZmmu0UHdqGmIdo64q)IIgImLVmLVH0T6Xkd57bDbAhdvJA4LFoUjld5kh9hIjodPfF6WNBirykT9oXeWqMndfpc)kOmbwMGr7FH6yGPqQn0Vs8hqOwxbitCLjosMalt4ETgddmkmtaO45zggkA3WbiqgXbhDCOFrrdrMaltO9wJ(Eqxa7yGr7rYeyzs9FLsjCOoSG1eA4e7hXkfsx5O)qKjWYepYeAV1OeouhwWAcnCI9JyLcP9izcSmr47HkMritGMRmXjC2q6w9yLH89GUaTJHQrn8MdNnzzix5O)qmXziT4th(CdjmA)luhdmfsTH(vI)ac16kazc0CLPCmKUvpwziNJ1qo09mZOgEZHFtwgYvo6petCgsl(0Hp3qI2BnkuzyImBrdtXJWVcktGqMIVmXPYeGfrM4uzcT3AuOYWez2IgMcv3MXq6w9yLH0g6xj(diuRRamQH3CYXKLHCLJ(dXeNH0T6Xkd57bDbAhdvdPfF6WNBiHtfOSQdP6nCoGkbhfzLjWYeAV1OVh0fWogy0EKmbwM4rMq7TgncFemmY5VaKEWr7rgsBa2Fc1XatHgE53OgEZj(MSmKRC0FiM4mKw8PdFUHeovGYQoKQ3W5aQeCuKvMaltO9wJ(Eqxa7yGr7rYeyzIhzcT3A0i8rWWiN)cq6bhThziDRESYq(EqxG2Xq1OgEZHJmzzix5O)qmXziT4th(CdjAV1OVh0fWogy0EKmbwMGr7FH6yGPqQn0Vs8hqOwxbitGqM4izcSmLNmXJmfnLcvgMqSFeRu)PUvVGtMYxMaltimL2ENycyiZMHQNnZvags3QhRmKVh0fODmunQH3C4etwgYvo6petCgsl(0Hp3qQ(VsP7hXk1Fb67qLUYr)HitGLjy0(xOogykKAd9Re)beQ1vaYeiKjorMalt5jt8itrtPqLHje7hXk1FQB1l4KP8nKUvpwzi3pIvQ)c03HQrn8MdOWKLHCLJ(dXeNH0IpD4ZnKQ)RuQdTRq8Yo6kh9hIH0T6Xkd57bDb6CcJA4nN4TjldPB1JvgsBOFL4pGqTUcWqUYr)HyIZOgEZbuzYYqUYr)HyIZqUYr)jiybVcWeNH0IpD4ZnKO9wJ(Eqxa7yGr7rYeyzYYypcdKLap3Qgs3QhRmKVh0fODmunKeSGxby4LFJA4nhoUjldjbl4vagE53qUYr)jiybVcWeNH0T6Xkdz7DIjGHmBgdPna7pH6yGPqdV8BiT4th(CdjEn8GHo6pd5kh9hIjoJA4n(C2KLHKGf8kadV8Bix5O)eeSGxbyIZq6w9yLHSHzqvadz2mgYvo6petCg1Ogs4eWRa(juhdm1KLHx(nzziDRESYqcvgMqSFeRu)nKRC0FiM4mQH3Cmzzix5O)qmXziT4th(CdjAV1OWogycwteXa5W0EKH0T6Xkd5FaHADfGaL9Qrn8gFtwgYvo6petCgs3QhRmKr4JGHro)fG0dodPfF6WNBiTSGR8sP1Sy2ZWiYeyzIhzcT3A0i8rWWiN)cq6bhThjtGLjEKj0ERrHr)v6WdrSFeRuiThziTby)juhdmfA4LFJA4LJmzzix5O)qmXziT4th(CdjAV1Ow)FXFaHADfafpc)kOmbAUYe)C2q6w9yLHCbmbRj0WjGkdtyudVCIjld5kh9hIjodPfF6WNBiv)xP0ZUwhhaDLJ(drMaltO9wJE2164aO9izcSmH2Bn6zxRJdGIhHFfuMaHmbNQxbaPq1TzeO9wByzItLjalImXPYeAV1ONDTooakuDBgzcSmH2BnkiVcra0HkfQUnJmbczIFqLH0T6XkdzdZGQagYSzmQHxqHjld5kh9hIjodPB1JvgY27etadz2mgsl(0Hp3qIxdpyOJ(ZqAdW(tOogyk0Wl)g1WB82KLHCLJ(dXeNH0IpD4ZnKQ)Ru6zxRJdGUYr)HitGLj0ERrp7ADCa0EKmbwMq7Tg9SR1XbqXJWVcktGqM4NYVmXPYeGfrM4uzcT3A0ZUwhhafQUnJH0T6XkdzdZGQagYSzmQHxqLjld5kh9hIjodPfF6WNBiv)xP09JyL6Va9DOsx5O)qmKUvpwzi3pIvQ)c03HQrn8YXnzzix5O)qmXziT4th(CdP6)kLcvgMiZw0W0vo6pedPB1JvgsOYWez2Ig2OgE5NZMSmKRC0FiM4mKw8PdFUHu9FLsNnKDfGagYSzORC0FiYeyzYYypcdKf99GUaTJHkfpc)kOmbcUYeGfrMaltWO9VqDmWui1g6xj(diuRRaKjqit5itXIjte(EOIzeYeO5ktGcoltGLjy0(xOogykKAd9Re)beQ1vaYeO5kt5itGLP8KjEKjCVwJHbgD2q2GcwtaGNRcyVqg(ka64q)IIgImflMmH2Bn6SHSbfSMaapxfWEHm8va0EKmLVH0T6Xkd5SHSRaeWqMnJrn8Yp)MSmKRC0FiM4mKw8PdFUHmpzcT3AuqEfIaOdvkuDBgzceYe)GkzcSmXJmH2Bnk6ZyiFhQ0EKmLVmflMmH2Bn67bDbSJbgThziDRESYq(EqxG2Xq1OgE5phtwgYvo6petCgsl(0Hp3qQ(VsPZgYUcqadz2m0vo6pezcSmH2Bn6SHSRaeWqMndThjtGLjy0(xOogykKAd9Re)beQ1vaYeiKPCmKUvpwziFpOlq7yOAudV8hFtwgYvo6petCgsl(0Hp3qQ(VsPZgYUcqadz2m0vo6pezcSmH2Bn6SHSRaeWqMndThjtGLjy0(xOogykKAd9Re)beQ1vaYeO5kt5yiDRESYqohRHCO7zMrn8YphzYYqUYr)HyIZqAXNo85gs0ERrHkdtKzlAyApYq6w9yLH8pGqTUcqGYE1OgE5Ntmzzix5O)qmXziT4th(CdjAV1OZgYguWAca8Cva7fYWxbq7rgs3QhRmKZXAih6EMzudV8dkmzzix5O)qmXziT4th(CdjmA)luhdmfsTH(vI)ac16kazceYuoYeyzIW3dvmJqManxzcuWzzcSmLNmH2BnkiVcra0HkfQUnJmbczkholtXIjte(EOIzeYeOLjooNLP8LPyXKP8KjCVwJHbgD2q2GcwtaGNRcyVqg(ka64q)IIgImbwM4rMq7TgD2q2GcwtaGNRcyVqg(kaApsMYxMIftMW9AnggyuqEfcmAEMHHI3d6c8GDmWk7OJd9lkAigs3QhRmKZXAOagYSzmQHx(J3MSmKRC0FiM4mKw8PdFUHmpzcgT)fQJbMcP2q)kXFaHADfGmbAzIFzkFzcSmLNmXJmHWuA7DIjGHmBgkEn8GHo6pzkFdPB1JvgY5ynKdDpZmQHx(bvMSmKRC0FiM4mKw8PdFUH0T6fCIvJ4guMaTmXVmbwMIMsHkdti2pIvQ)u3QxWjtGLj0ERrrFgd57qL2JmKUvpwziTH(vI)ac16kaJA4LFoUjld5kh9hIjodPfF6WNBiJMsHkdti2pIvQ)u3QxWjtGLj0ERrrFgd57qL2JmKUvpwzi)diuRRaeOSxnQH3C4Sjld5kh9hIjodPfF6WNBir7Tg1H2viEzhThziDRESYq(EqxG2Xq1OgEZHFtwgYvo6petCgsl(0Hp3qAzShHbYsGNBvdPB1JvgY3d6c0ogQg1WBo5yYYqUYr)HyIZqAXNo85gslJ9imqwc8CRktGLjBOJbguMaTmP(VsPZgYeSMqdNy)iwPq6kh9hIH0T6Xkd57bDbAhdvJA4nN4BYYqUYr)HyIZqAXNo85gs1)vk9SR1Xbqx5O)qKjWYeAV1ONDTooaApYq6w9yLHSHzqvadz2mg1WBoCKjldPB1JvgsBOFLi0XbhunKRC0FiM4mQH3C4etwgYvo6petCgsl(0Hp3qcz9h9keAq2769tazFWvkDLJ(drMalt8itO9wJgK9UE)eq2hCLkc7eEXoeApYqELomUhPIRziHS(JEfcni7D9(jGSp4k1qELomUhPIJGyiNRZqYVH0T6Xkdz7hm0I9MAiVshg3JubWZq93qYVrn8MdOWKLHCLJ(dXeNH0IpD4ZnKQ)RukuD9ScKdAdDmWORC0Figs3QhRmKq11ZkqoOn0XaZOgEZjEBYYqUYr)HyIZqAXNo85gsEKj1)vkncFe(l2pIvQ)huPRC0FiYuSyYK6)kLgHpc)f7hXk1)dQ0vo6pezcSmLNmXJmfnLcvgMqSFeRu)PUvVGtMY3q6w9yLHCowdf7hXk1FJA4nhqLjld5kh9hIjodPfF6WNBiDREbNy1iUbLjqlt8ltGLP8Kjy0(xOogykKAd9Re)beQ1vaYeOLj(LPyXKjy0(xOogykK(EqxGoNqMaTmXVmLVH0T6XkdPn0Vs8hqOwxbyudV5WXnzziDRESYq(hqOwxbiqzVAix5O)qmXzudVXNZMSmKeSGxby4LFd5kh9NGGf8katCgs3QhRmKT3jMagYSzmK2aS)eQJbMcn8YVH0IpD4ZnK41Wdg6O)mKRC0FiM4mQH34ZVjld5kh9hIjod5kh9NGGf8katCgsl(0Hp3qsWcoIvkf5GQx2jtGwMafgs3QhRmKT3jMagYSzmKeSGxby4LFJA4n(5yYYqsWcEfGHx(nKRC0FccwWRamXziDRESYq2WmOkGHmBgd5kh9hIjoJAuJAi9UgYWgsYJO)UESkEg7n1Og1ya]] )

end
