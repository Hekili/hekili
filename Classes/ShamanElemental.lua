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

    spec:RegisterPack( "Elemental", 20220227, [[dKKKocqiufpsqv1Muv9jejAuIQCkrvTkej9krLMLG0TuvuLDH0VevmmePoMGyzIs9mvfzAiI6AiISnbv5BcQKXPQOCobv06euHMNQc3drTpvL6GQkQQfkO8qbvktuqLkDrbvWgfuPkFuvrfDsejyLOQmtej0nfuPQ2jQs)uvrLSuvfvQNIktvuYvfuPIVQQOcJvqvXEj5VegSqhMQfdPhtQjdXLv2Su(SQmAboTkVwenBGBJWUL8BugUiDCeHLd1ZbnDkxxQ2UO47Qkz8cQkDEuvnFry)eTkevwkoe3MI3SjD2zt6SZoCrjnPjnjLD4sXz8NofxQRt6VP4kNykUWbWiwzoqXL68dyoIklfhK1X6P4cmlfgoMtoVZc6OunJih4r0bUDSsJ9MLd8i05O4q7hWifkfQIdXTP4nBsND2Ko7SdxustAstsKoCP4GPtR4n7WlBfxWHGSsHQ4qguR4chaJyL5azKlWj8sYx4Edf3Dm)Yy2KuOYy2Ko7SL8j5lClWR3GHJs((8KrsHsZWPmSBtgHZSREqk0CDsbAV1gwgBmSmskOxRJ5puzKZyyIKBPdtL895jJF(iiYy4(ZgdlJEHiJHd8pzK1KrlyYiNXWeYO)8ROkUumRDGP4c)HFzmCamIvMdKrUaNWljFH)WVmgU3qXDhZVmMnjfQmMnPZoBjFs(c)HFzmClWR3GHJs(c)HFz8ZtgjfkndNYWUnzeoZU6bPqZ1jfO9wByzSXWYiPGEToM)qLroJHjsULomvYx4p8lJFEY4NpcImgU)SXWYOxiYy4a)tgznz0cMmYzmmHm6p)kQKpjFHFzmCi8D6UnezCzgMFz0oIjJwWKrxBmSmEqz0Z4hWrbJk5Z12XkinfpnJa1nYZXwGyGrSYCqOxJmpMdwz0u8r4aXaJyL5GdA0vokyis(c)Yy4oWjJCgdtKClDyzmfpnJa1nzSxGbHYiKrmz0rqGY4xhaiJWu)RsgHmwrL85A7yfKMINMrG6wUKZPbgmqJ9Mf61idzDa6vi00o06GjgUNAhRsKaY6a0RqOzya3oWeqgiZktYNRTJvqAkEAgbQB5sohOXWej3sho0Rr2CWkJcngMi5w6W0vokyi)5H9drSmRmQJGaPAwVSp(uIey)qelZkJ6iiq6vFtsKoFjFU2owbPP4PzeOULl5CAhEIbgXkZbs(CTDScstXtZiqDlxY5mWiwzoqGcCOf61iBoyLrhyeRmhiqbo0ORCuWq(HPdaeMJFZGuDGFLaCVaRU69XNK8f(LXWM27WjJKIzctgdCOm6YOH9mdiJ2rSqLrlyYOJGWkzmf46bLrs1coOmUYW8tQYiRKXWTWDLXgdlJFsgHtZkeOmAmz0ZWoezeH1rb7ZJumtyYiRKX0oaqL85A7yfKMINMrG6wUKZb4zCbAhdTqbxnHgH8Nc9AK5XCWkJoWiwzoqGcCOrx5OGH8dthaimh)MbP6a)kb4EbwD17JpLibAV1OqJHjsULomTNk5Z12XkinfpnJa1TCjNJoWVsaUxGvx9c9AK5XCWkJoWiwzoqGcCOrx5OGH8dthaimh)MbP6a)kb4EbwD17BYF6Nh0ERrHgdtKClDyApvYNRTJvqAkEAgbQB5soNuMDSsYNKVWVmsku2W4EQjJSMmQDObPs(CTDScMl5C(6kebmyowYNRTJvWCjNdm9WN9Ldsomu8WUEHsWYC1JCis(CTDScMl5Csz2XkjFU2owbZLCoD4eNncOKpxBhRG5soNgWjMagW0jd9AKZJhZbRm6aJyL5abkWHgDLJcgs()8yNo5vVFEsNrHgdtigyeRmhqDTDz2FEW0bacZXVzqQoWVsaUxGvx9(4tjsyoyLrjCOnSG1ewWedmIvgKUYrbdjrcCVwJHFJctYpkEEYHHI2nm)cKrCWrhj6xA6qYxYxUYORTJvWCjNtk(iyyKZbIV8mlun)AWeMJFZGKdj0RrMh0ERrtXhbdJCoq8LNz0E6FE8KoJcngMqmWiwzoG6A7YSejGPdaeMJFZGuDGFLaCVaRU69XN(r7Tg9RRqeVo0OqZ1j)iBsNibK1bOxHqbZreO8lw4RtKcgDLJcgsIe4ETgd)gfMcUYgEiIbgXkdshj6xA6qY)ppy6aaH543mivh4xja3lWQREFqsjsyoyLrjCOnSG1ewWedmIvgKUYrbdjrcCVwJHFJctYpkEEYHHI2nm)cKrCWrhj6xA6qsKaY6a0RqOG5icu(fl81jsbJUYrbdjrcCVwJHFJctbxzdpeXaJyLbPJe9lnDi5)ZdAV1OWuWv2WdrmWiwzqApvYNRTJvWCjNtd4etady6KHEnY8yNo5vV)84jDgfAmmHyGrSYCa112Lzjsathaimh)MbP6a)kb4EbwD17Jp9J2Bn6xxHiEDOrHMRt(r2Ko))8GPdaeMJFZGuDGFLaCVaRU69XNsKWCWkJs4qBybRjSGjgyeRmiDLJcgsIe4ETgd)gfMKFu88KddfTBy(fiJ4GJos0V00HKVKpxBhRG5soN2HNyGrSYCGKpxBhRG5sohIzJHL85A7yfmxY5GcymerRJ5p0RrMhZbRmQd1Rq8sp6khfmKejq7Tg1H6viEPhTNMiHMXaiSVkQd1Rq8spkEe(vWVjjsl5Z12XkyUKZbDy4WjV6f61iZJ5Gvg1H6viEPhDLJcgsIeO9wJ6q9keV0J2tL85A7yfmxY50o8qbmgsOxJmpMdwzuhQxH4LE0vokyijsG2BnQd1Rq8spApnrcnJbqyFvuhQxH4LEu8i8RGFtsKwYNRTJvWCjNJx6bnSdeAhac9AK5XCWkJ6q9keV0JUYrbdjrc0ERrDOEfIx6r7PjsOzmac7RI6q9keV0JIhHFf8BsI0s(CTDScMl5Cq9NG1eg(0jHHEnY8yoyLrDOEfIx6rx5OGHKibpO9wJ6q9keV0J2tL85A7yfmxY5KzW0HfgZgHKpxBhRG5soNMpHH9c26WJvHEnYAwMvEz06EbMO57NhCVwJHFJc3qGcwtGDIuVmXdZ(YcOJe9lnDi)5XJ5GvgLWH2WcwtybtmWiwzq6khfmKejq7TgLWH2WcwtybtmWiwzqApn)Fy6aaH543mivh4xja3lWQREF8jjFU2owbZLConFcd7fS1HhRc9AK1SmR8YO19cmrZ3pUxRXWVrHBiqbRjWorQxM4HzFzb0rI(LMoK)84XCWkJs4qBybRjSGjgyeRmiDLJcgsIeO9wJs4qBybRjSGjgyeRmiTNMibmDaGWC8BgKQd8ReG7fy1vVVj)P8)ZtZyae2xfTD4jgyeRmhqXJWVc(D2KorcnJbqyFvuOXWeIbgXkZbu8i8RGFNnPZxYNRTJvWCjNdUxcxBhReGdAHwoXi7Sfk0WN2ihsOxJSRTlZeRgXn43z)NhmDaGWC8BgKQd8ReG7fy1vVVZorcy6aaH543mif4zCb6CIVZoFjFU2owbZLCo4EjCTDSsaoOfA5eJm8QhycZXVzHcn8PnYHe61iZJ5GvgfAmmHyGrSYCaDLJcgYVRTlZeRgXn4hKZwYNRTJvWCjNdUxcxBhReGdAHwoXidNaE1dmH543SqHg(0g5qc9AKnhSYOqJHjedmIvMdORCuWq(DTDzMy1iUb)GC2s(K85A7yfK6SrgAmmHyGrSYCGKpxBhRGuNTCjNZ4FcwtybtangMi0RrgT3AuTdacW9cS6Qhfpc)k43KdH0s(CTDScsD2YLCoZXwaj6EYf61iJ2Bn60bSREcyatNK2tL85A7yfK6SLl5C0b(vIahNzqtYNRTJvqQZwUKZbAmmrYT0Hd9AKnhSYOqJHjsULomDLJcgIKpxBhRGuNTCjNtd4etady6KHQ5xdMWC8BgKCiHEnY41Wdg4OG9NxEU2UmtGWmAd4etady6KFK9VRTlZeRgXn4hK)0VMXaiSVkAk(iyyKZbIV8mJIhHFf8JqcVFnlZkVmAnnMbyyKFEsNrHgdtigyeRmhqDTDzwIeU2UmtGWmAd4etady6KFeYVRTlZeRgXn43Kj5FEsNrHgdtigyeRmhqDTDz2V5GvgLWH2WcwtybtmWiwzq6khfmK8tKipCVwJHFJctYpkEEYHHI2nm)cKrCWrhj6xA6q(5jDgfAmmHyGrSYCa112Lz5NirE4ETgd)gfMcUYgEiIbgXkdshj6xA6q(ZZ12LzceMrBaNycyatN8Jp9ZdUxRXWVrNoGnOG1ep8Cta7fYWx9OJe9lnDijs4A7YmbcZOnGtmbmGPt(bjN)FEAgdGW(QOP4JGHrohi(YZmkEe(vWpcj8sKaT3A0u8rWWiNdeF5zgTNMF(5l5Z12Xki1zlxY50aoXeWaMozOxJmpU2UmtGWmAd4etady6K)8KoJcngMqmWiwzoG6A7YS)8mhSYOeo0gwWAclyIbgXkdsx5OGHKibUxRXWVrHj5hfpp5Wqr7gMFbYio4OJe9lnDi5NirE4ETgd)gfMcUYgEiIbgXkdshj6xA6q(5XoDYRE)O9wJMIpcgg5CG4lpZO908L85A7yfK6SLl5CMoGD1tady6KHEnYMdwz0Pdyx9eWaMojDLJcgYpHpa0WmIVjhEK(ppCVwJHFJoDaBqbRjE45Ma2lKHV6rhj6xA6q(r7TgD6a2Gcwt8WZnbSxidF1J2ttKGhCVwJHFJoDaBqbRjE45Ma2lKHV6rhj6xA6qYxYNRTJvqQZwUKZXH6viEPxOxJS5Gvg1H6viEPhDLJcgYFE8KoJcngMqmWiwzoG6A7YS8)ZJhZbRm6PxRJ5NUYrbdjrcEq7Tg90R1X8t7P)8Ozmac7RIE616y(P908L85A7yfK6SLl5Cahj6hIGWFeUWy2ic9AKnhSYOGJe9drq4pcxymBe0vokyis(CTDScsD2YLCo6a)kb4EbwD1l0RrgMoaqyo(nds1b(vcW9cS6Q3hK8pAV1Oeo0gwWAclyIbgXkds7P)e(aqdZi(GKiTKpxBhRGuNTCjNZCSfiGbmDYqVgzCVwJHFJoDaBqbRjE45Ma2lKHV6rhj6xA6q(5bT3A0PdydkynXdp3eWEHm8vpApvYNRTJvqQZwUKZb4zCbAhdTqVgzeMrBaNycyatNKIhHFf8hMoaqyo(nds1b(vcW9cS6Q3hK8FE8KoJcngMqmWiwzoG6A7YS8)ZdT3AuGNXfWo(nAp9Nh0ERrjCOnSG1ewWedmIvgK2t)nhSYOeo0gwWAclyIbgXkdsx5OGHKVKpxBhRGuNTCjNZCSfqIUNCHEnYW0bacZXVzqQoWVsaUxGvx9(MC2)8G71Am8B0PdydkynXdp3eWEHm8vp6ir)sthYFEMdwzuchAdlynHfmXaJyLbPRCuWq(j8bGgMr8nzsI0)8G2BnkHdTHfSMWcMyGrSYG0EA(s(CTDScsD2YLCoapJlq7yOfQMFnycZXVzqYHe61iRzzw5LrRPXmadJ8J71Am8B0PdydkynXdp3eWEHm8vp6ir)sthYpCMaLvDi1UHZ(ZeKCQ(hT3AuGNXfWo(nAp9Nh0ERrtXhbdJCoq8LNz0EQKpxBhRGuNTCjNdWZ4c0ogAHQ5xdMWC8BgKCiHEnYO9wJc8mUa2XVr7P)O9wJMIpcgg5CG4lpZO90)8q7TgnfFemmY5aXxEMrXJWVc(XNi1NgjrcxBxMjqygTbCIjGbmDsYW0bacZXVzqQoWVsaUxGvx9sKW12LzceMrBaNycyatNK8N(5b3R1y43OthWguWAIhEUjG9cz4RE0rI(LMoKejCTDzMaHz0gWjMagW0jjtY5l5Z12Xki1zlxY5a8mUaTJHwOxJmcZOnGtmbmGPtsXJWVc(dthaimh)MbP6a)kb4EbwD17ds(h3R1y43OWK8JINNCyOODdZVazehC0rI(LMoKF0ERrbEgxa743O90FZbRmkHdTHfSMWcMyGrSYG0vokyi)8G2BnkHdTHfSMWcMyGrSYG0E6pHpa0WmIVjtsKwYNRTJvqQZwUKZb4zCbAhdTqVgzeMrBaNycyatNKIhHFf8pV8GPdaeMJFZGuDGFLaCVaRU69bj)J71Am8Buys(rXZtomu0UH5xGmIdo6ir)sthYV5GvgLWH2WcwtybtmWiwzq6khfmK8tKipZbRmkHdTHfSMWcMyGrSYG0vokyi)e(aqdZi(Mmjr6FEq7TgLWH2WcwtybtmWiwzqAp9ppEW9Ang(n60bSbfSM4HNBcyVqg(QhDKOFPPdjrc0ERrNoGnOG1ep8Cta7fYWx9O908)5b3R1y43OWK8JINNCyOODdZVazehC0rI(LMoK8ZxYNRTJvqQZwUKZb4zCbAhdTqVgzeMrBaNycyatNKIhHFf8hMoaqyo(nds1b(vcW9cS6Qhzs(h3R1y43OWK8JINNCyOODdZVazehC0rI(LMoKF0ERrbEgxa743O90FZbRmkHdTHfSMWcMyGrSYG0vokyi)8G2BnkHdTHfSMWcMyGrSYG0E6pHpa0WmIVjtsKwYNRTJvqQZwUKZzo2cir3tUqVgzy6aaH543mivh4xja3lWQREFtoBjFU2owbPoB5sohDGFLaCVaRU6f61iJ2Bnk0yyIKBPdtXJWVc(XNi1NgHur7TgfAmmrYT0HPqZ1jL85A7yfK6SLl5CaEgxG2Xqlun)AWeMJFZGKdj0RrgotGYQoKA3Wz)zcsov)J2BnkWZ4cyh)gTN(ZdAV1OP4JGHrohi(YZmApvYNRTJvqQZwUKZb4zCbAhdTqVgz4mbkR6qQDdN9Nji5u9pAV1OapJlGD8B0E6ppO9wJMIpcgg5CG4lpZO9ujFU2owbPoB5sohGNXfODm0c9AKr7Tgf4zCbSJFJ2t)HPdaeMJFZGuDGFLaCVaRU69bj)NhpPZOqJHjedmIvMdOU2Uml)FeMrBaNycyatNKANo5vpjFU2owbPoB5soNbgXkZbcuGdTqVgzZbRm6aJyL5abkWHgDLJcgYpmDaGWC8BgKQd8ReG7fy1vVpiP)84jDgfAmmHyGrSYCa112Lz5l5Z12Xki1zlxY5a8mUaDorOxJS5Gvg1H6viEPhDLJcgIKpxBhRGuNTCjNJoWVsaUxGvx9K85A7yfK6SLl5CaEgxG2XqlucwMREKdj0RrgT3AuGNXfWo(nAp9xZyae2xLapxBs(CTDScsD2YLConGtmbmGPtgkblZvpYHeQMFnycZXVzqYHe61iJxdpyGJcMKpxBhRGuNTCjNtdZGMagW0jdLGL5Qh5qK8j5Z12Xkifob8QhycZXVzKHgdtigyeRmhi5Z12Xkifob8QhycZXVz5sohW9cS6QNaLbSqVgz0ERrHD8BcwtKY(AyApvYNRTJvqkCc4vpWeMJFZYLCoP4JGHrohi(YZSq18Rbtyo(ndsoKqVgznlZkVmAnnMbyyKFEq7TgnfFemmY5aXxEMr7P)8G2BnkmfCLn8qedmIvgK2tL85A7yfKcNaE1dmH543SCjNZ4FcwtybtangMi0RrgT3AuTdacW9cS6Qhfpc)k43KdH0s(CTDScsHtaV6bMWC8BwUKZPHzqtady6KHEnYMdwz0tVwhZpDLJcgYpAV1ONEToMFAp9hT3A0tVwhZpfpc)k4hWz2vpifAUoPaT3AdtQpncPI2Bn6PxRJ5NcnxN8hT3A0VUcr86qJcnxN8Jq(mjFU2owbPWjGx9atyo(nlxY50aoXeWaMozOA(1Gjmh)MbjhsOxJmEn8Gbokys(CTDScsHtaV6bMWC8BwUKZPHzqtady6KHEnYMdwz0tVwhZpDLJcgYpAV1ONEToMFAp9hT3A0tVwhZpfpc)k4hHqdHuFAesfT3A0tVwhZpfAUoPKpxBhRGu4eWREGjmh)MLl5CgyeRmhiqbo0c9AKnhSYOdmIvMdeOahA0vokyis(CTDScsHtaV6bMWC8BwUKZbAmmrYT0Hd9AKnhSYOqJHjsULomDLJcgIKpxBhRGu4eWREGjmh)MLl5CMoGD1tady6KHEnYMdwz0Pdyx9eWaMojDLJcgYVMXaiSVkkWZ4c0ogAu8i8RGFq(Pr(HPdaeMJFZGuDGFLaCVaRU69r2jsq4danmJ4BYHhP)HPdaeMJFZGuDGFLaCVaRU69n5S)ZJhCVwJHFJoDaBqbRjE45Ma2lKHV6rhj6xA6qsKaT3A0PdydkynXdp3eWEHm8vpApn)ejGPdaeMJFZGuDGFLaCVaRU69r2)O9wJ(1viIxhAuO56KFtoKp7ppEW9Ang(n60bSbfSM4HNBcyVqg(QhDKOFPPdjrc0ERrNoGnOG1ep8Cta7fYWx9O908)j8bGgMr8n5WJ0s(CTDScsHtaV6bMWC8BwUKZb4zCbAhdTqVg58q7Tg9RRqeVo0OqZ1j)iKp7Nh0ERrrbmgcOdnApn)ejq7Tgf4zCbSJFJ2tL85A7yfKcNaE1dmH543SCjNdWZ4c0ogAHEnYMdwz0Pdyx9eWaMojDLJcgYpAV1OthWU6jGbmDsAp9hMoaqyo(nds1b(vcW9cS6Q3hzl5Z12Xkifob8QhycZXVz5soN5ylGeDp5c9AKnhSYOthWU6jGbmDs6khfmKF0ERrNoGD1tady6K0E6pmDaGWC8BgKQd8ReG7fy1vVVjNTKpxBhRGu4eWREGjmh)MLl5Ca3lWQREcugWc9AKr7TgfAmmrYT0HP9ujFU2owbPWjGx9atyo(nlxY5mhBbKO7jxOxJmAV1OthWguWAIhEUjG9cz4RE0EQKpxBhRGu4eWREGjmh)MLl5CMJTabmGPtg61idthaimh)MbP6a)kb4EbwD17JS)j8bGgMr8n5WJ0)5H2Bn6xxHiEDOrHMRt(r2KorccFaOHzeFhojD(jsKhUxRXWVrNoGnOG1ep8Cta7fYWx9OJe9lnDi)8G2Bn60bSbfSM4HNBcyVqg(QhTNMFIe4ETgd)g9RRqGPZtomua8mUapyh)wPhDKOFPPdrYNRTJvqkCc4vpWeMJFZYLCoZXwaj6EYf61iNhmDaGWC8BgKQd8ReG7fy1vVVdj))84bHz0gWjMagW0jP41Wdg4OGLVKpxBhRGu4eWREGjmh)MLl5C0b(vcW9cS6QxOxJSRTlZeRgXn43H8NoJcngMqmWiwzoG6A7YSF0ERrrbmgcOdnApvYNRTJvqkCc4vpWeMJFZYLCoG7fy1vpbkdyHEnYPZOqJHjedmIvMdOU2Um7hT3AuuaJHa6qJ2tL85A7yfKcNaE1dmH543SCjNdWZ4c0ogAHEnYO9wJ6q9keV0J2tL85A7yfKcNaE1dmH543SCjNdWZ4c0ogAHEnYAgdGW(Qe45AtYNRTJvqkCc4vpWeMJFZYLCoapJlq7yOf61iRzmac7RsGNRTFDGJFd(T5GvgD6aMG1ewWedmIvgKUYrbdrYNRTJvqkCc4vpWeMJFZYLConmdAcyatNm0Rr2CWkJE616y(PRCuWq(r7Tg90R1X8t7Ps(CTDScsHtaV6bMWC8BwUKZrh4xjcCCMbnjFU2owbPWjGx9atyo(nlxY50adgOXEZc9kByCp1ihsOxJmK1bOxHqZWaUDGjGmqMvMKpxBhRGu4eWREGjmh)MLl5CGMBNwGCqDGJFl0Rr2CWkJcn3oTa5G6ah)gDLJcgIKpxBhRGu4eWREGjmh)MLl5CMJTaXaJyL5GqVgzEmhSYOP4JWbIbgXkZbh0ORCuWqsKWCWkJMIpchigyeRmhCqJUYrbd5ppEsNrHgdtigyeRmhqDTDzw(s(CTDScsHtaV6bMWC8BwUKZrh4xja3lWQREHEnYU2UmtSAe3GFhYFEW0bacZXVzqQoWVsaUxGvx9(oKejGPdaeMJFZGuGNXfOZj(oK8L85A7yfKcNaE1dmH543SCjNd4EbwD1tGYaMKpxBhRGu4eWREGjmh)MLl5CAaNycyatNmucwMREKdjun)AWeMJFZGKdj0RrgVgEWahfmjFU2owbPWjGx9atyo(nlxY50aoXeWaMozOeSmx9ihsOxJmblZiwzuKdAEP33HNKpxBhRGu4eWREGjmh)MLl5CAyg0eWaMozOeSmx9ihIKpjFU2owbPWREGjmh)MrgCVaRU6jqzal0Rrop0ERrHgdtKClDykEe(vWpGZSREqk0CDsbAV1gMuFAesfT3AuOXWej3shMcnxNmFjFU2owbPWREGjmh)MLl5CAyg0eWaMozOxJS5Gvg90R1X8tx5OGH8J2Bn6PxRJ5N2t)r7Tg90R1X8tXJWVc(bCMD1dsHMRtkq7T2WK6tJqQO9wJE616y(PqZ1jL85A7yfKcV6bMWC8BwUKZPbCIjGbmDYq18Rbtyo(ndsoKqVg584XoDYREjsGWmAd4etady6Ku8i8RGFq(PrsKWCWkJ6q9keV0JUYrbd5hHz0gWjMagW0jP4r4xb)ipnJbqyFvuhQxH4LEu8i8RG5I2BnQd1Rq8spksh72XQ8)1mgaH9vrDOEfIx6rXJWVc(bjN)FEO9wJc8mUa2XVr7PjsWdAV1OOagdb0HgTNMVKpxBhRGu4vpWeMJFZYLConGtmbmGPtgQMFnycZXVzqYHe61iJ2BnAk(iyyKZbIV8mJ2t)XRHhmWrbtYNRTJvqk8QhycZXVz5sohhQxH4LEHEnYMdwzuhQxH4LE0vokyi)5zhX(MC4r6ejq7TgffWyiGo0O908)ZtZyae2xff4zCbAhdnkEe(vWVjD()5XJ5Gvg90R1X8tx5OGHKibpO9wJE616y(P90FE0mgaH9vrp9ADm)0EA(s(CTDScsHx9atyo(nlxY5a8mUaTJHwOxJmAV1OapJlGD8B0E6FE4ETgd)g9RRqGPZtomua8mUapyh)wPhDKOFPPdjrcEq7TgLWH2WcwtybtmWiwzqAp93CWkJs4qBybRjSGjgyeRmiDLJcgs(s(CTDScsHx9atyo(nlxY5mWiwzoqGcCOf61iBoyLrhyeRmhiqbo0ORCuWq(ZJWhaAygXhHlsNVKpxBhRGu4vpWeMJFZYLCoqJHjsULoCOxJS5GvgfAmmrYT0HPRCuWq(Zd7hIyzwzuhbbs1SEzF8PejW(HiwMvg1rqG0R(MKiD()5r4danmJ4dsMKZxYNRTJvqk8QhycZXVz5soNPdyx9eWaMozOxJS5GvgD6a2vpbmGPtsx5OGH8Rzmac7RIc8mUaTJHgfpc)k4hKFAejFU2owbPWREGjmh)MLl5CaEgxG2Xql0Rr2CWkJoDa7QNagW0jPRCuWq(r7TgD6a2vpbmGPts7Ps(CTDScsHx9atyo(nlxY5aos0pebH)iCHXSre61iBoyLrbhj6hIGWFeUWy2iORCuWqK85A7yfKcV6bMWC8BwUKZzo2cir3tUqVgz0ERrNoGnOG1ep8Cta7fYWx9O90FZbRmkHdTHfSMWcMyGrSYG0vokyi)O9wJs4qBybRjSGjgyeRmiTNk5Z12XkifE1dmH543SCjNd4EbwD1tGYawOxJmAV1OqJHjsULomTN(J2BnkHdTHfSMWcMyGrSYG0E6pHpa0WmIpcpsl5Z12XkifE1dmH543SCjNZCSfqIUNCHEnYO9wJoDaBqbRjE45Ma2lKHV6r7P)5zoyLrjCOnSG1ewWedmIvgKUYrbd5pp0ERrjCOnSG1ewWedmIvgK2ttKqZyae2xff4zCbAhdnkEe(vWVj9pHpa0WmIVjhoZorcy6aaH543mivh4xja3lWQREFK9pAV1OqJHjsULomTN(Rzmac7RIc8mUaTJHgfpc)k4hKFAK8tKGhZbRmkHdTHfSMWcMyGrSYG0vokyijsOzmac7RIoWiwzoqGcCOrXJWVc(bz4m7QhKcnxNuG2BTHj1NgHuZoFjFU2owbPWREGjmh)MLl5CMJTas09Kl0RrgMoaqyo(nds1b(vcW9cS6Q33H8ZdcZOnGtmbmGPtsXRHhmWrb7NhCVwJHFJoDaBqbRjE45Ma2lKHV6rhj6xA6q(ZJhZbRmkHdTHfSMWcMyGrSYG0vokyijsG2BnkHdTHfSMWcMyGrSYG0EAIeAgdGW(QOapJlq7yOrXJWVc(nP)j8bGgMr8n5Wz25l5Z12XkifE1dmH543SCjNdWZ4c0ogAHEnYAgdGW(Qe45A7ppEq7TgLWH2WcwtybtmWiwzqAp9hT3A0tVwhZpTNMVKpxBhRGu4vpWeMJFZYLCoapJlq7yOf61iRzmac7RsGNRTFDGJFd(T5GvgD6aMG1ewWedmIvgKUYrbd5Nh0ERrp9ADm)0EQKpxBhRGu4vpWeMJFZYLCoapJlq7yOf61iBoyLrNoGjynHfmXaJyLbPRCuWq(5bT3AuchAdlynHfmXaJyLbP90FcFaOHzeFtMKi9ppO9wJoDaBqbRjE45Ma2lKHV6r7Ps(CTDScsHx9atyo(nlxY5mhBbcyatNm0RropCVwJHFJoDaBqbRjE45Ma2lKHV6rhj6xA6qsKaMoaqyo(nds1b(vcW9cS6Q3hzN)FEMdwzuchAdlynHfmXaJyLbPRCuWq(5bT3A0PdydkynXdp3eWEHm8vpAp9pp0ERrjCOnSG1ewWedmIvgK2ttKGWhaAygX3KdNzNibmDaGWC8BgKQd8ReG7fy1vVpY(hT3AuOXWej3shM2t)1mgaH9vrbEgxG2XqJIhHFf8dYpns(jsWJ5GvgLWH2WcwtybtmWiwzq6khfmKej0mgaH9vrhyeRmhiqbo0O4r4xb)GmCMD1dsHMRtkq7T2WK6tJqQzNVKpxBhRGu4vpWeMJFZYLConmdAcyatNm0Rr2CWkJE616y(PRCuWq(nhSYOeo0gwWAclyIbgXkdsx5OGH8J2Bn6PxRJ5N2t)r7TgLWH2WcwtybtmWiwzqApvYNRTJvqk8QhycZXVz5sohGNXfODm0c9AKr7Tg1H6viEPhTNk5Z12XkifE1dmH543SCjNdWZ4c0ogAHEnYAgdGW(Qe45A7NhZbRmkHdTHfSMWcMyGrSYG0vokyis(CTDScsHx9atyo(nlxY5C616y(d9AKnhSYONEToMF6khfmKFEYJWhaAygX3FIK(1mgaH9vrbEgxG2XqJIhHFf8dYKoFjFU2owbPWREGjmh)MLl5CAyg0eWaMozOxJS5Gvg90R1X8tx5OGH8J2Bn6PxRJ5N2t)ZdT3A0tVwhZpfpc)k4hpncPsYKkAV1ONEToMFk0CDYejq7TgfAmmrYT0HP90ej4XCWkJs4qBybRjSGjgyeRmiDLJcgs(s(CTDScsHx9atyo(nlxY5a8mUaTJHMKpxBhRGu4vpWeMJFZYLConGtmbmGPtgQMFnycZXVzqYHe61iJxdpyGJcMKpxBhRGu4vpWeMJFZYLConmdAcyatNm0Rrg3R1y43OdmIvMdeJe9dCO4Rtqhj6xA6q(5bT3A0bgXkZbIrI(bou81jeidT3A0E6ppMdwz0bgXkZbcuGdn6khfmKFEmhSYOthWU6jGbmDs6khfmejFU2owbPWREGjmh)MLl5CAGbd0yVzHELnmUNAKdj0RrgY6a0RqOzya3oWeqgiZktYNRTJvqk8QhycZXVz5sohDGFLiWXzg0K85A7yfKcV6bMWC8BwUKZPHzqtady6KHEnYMdwz0tVwhZpDLJcgYpAV1ONEToMFApvYNRTJvqk8QhycZXVz5sohO52Pfihuh443c9AKnhSYOqZTtlqoOoWXVrx5OGHi5Z12XkifE1dmH543SCjNZCSfigyeRmhe61iZJ5GvgnfFeoqmWiwzo4GgDLJcgsIe8KoJ2o8edmIvMdOU2UmtYNRTJvqk8QhycZXVz5sohDGFLaCVaRU6f61idthaimh)MbP6a)kb4EbwD177qK85A7yfKcV6bMWC8BwUKZbCVaRU6jqzatYNRTJvqk8QhycZXVz5soNgWjMagW0jdLGL5Qh5qcvZVgmH543mi5qc9AKXRHhmWrbtYNRTJvqk8QhycZXVz5soNgWjMagW0jdLGL5Qh5qc9AKjyzgXkJICqZl9(o8K85A7yfKcV6bMWC8BwUKZPHzqtady6KHsWYC1JCis(CTDScsHx9atyo(nlxY50WmOjGbmDYqVgzZbRm6PxRJ5NUYrbd5hT3A0tVwhZpTN(J2Bn6PxRJ5NIhHFf8d4m7QhKcnxNuG2BTHj1NgHur7Tg90R1X8tHMRtQ4Ymm8yLI3SjD2zt6SZoef3xoUU6bvCFo(8)CZlPaVFodhLrzmRGjJhrkdBYyJHLrsj8QhycZXVzKszeps0p8qKriJyYO3ngHBdrg1bE9gKk5Ju8QjJz)zHJYy4gRYmSnezKuczDa6vi0WhsPmAmzKuczDa6vi0Wh6khfmesPm6Mmgo85IuugZlKW38Ps(K8954Z)ZnVKc8(5mCugLXScMmEePmSjJngwgjLP4PzeOUrkLr8ir)WdrgHmIjJE3yeUnezuh41BqQKpsXRMmMD4OmgUXQmdBdrgjLqwhGEfcn8HukJgtgjLqwhGEfcn8HUYrbdHukJ5fs4B(ujFKIxnzm7WrzmCJvzg2gImskHSoa9keA4dPugnMmskHSoa9keA4dDLJcgcPugDtgdh(CrkkJ5fs4B(ujFs((C85)5MxsbE)CgokJYywbtgpIug2KXgdlJKs4eWREGjmh)MrkLr8ir)WdrgHmIjJE3yeUnezuh41BqQKpsXRMmMnjfokJHBSkZW2qKrsjK1bOxHqdFiLYOXKrsjK1bOxHqdFORCuWqiLYOBYy4WNlsrzmVqcFZNk5tYhParkdBdrgjjz012XkzeCqdsL8P48UfWWkoUJOdC7yv4g2BMIdCqdQYsXbV6bMWC8BMklfVHOYsXTYrbdrfMItJpB4ZvC5jJO9wJcngMi5w6Wu8i8RGY4hYiCMD1dsHMRtkq7T2WYiPkJpnImsQYiAV1OqJHjsULomfAUoPmMVIZ12Xkfh4EbwD1tGYaMYu8MTklf3khfmevykon(SHpxXzoyLrp9ADm)0vokyiY4VmI2Bn6PxRJ5N2tLXFzeT3A0tVwhZpfpc)kOm(HmcNzx9GuO56Kc0ERnSmsQY4tJiJKQmI2Bn6PxRJ5NcnxNuX5A7yLIRHzqtady6KktX7NuzP4w5OGHOctX5A7yLIRbCIjGbmDsfNgF2WNR4Ytg5rgTtN8QNmMiHmIWmAd4etady6Ku8i8RGY4hKLXNgrgtKqgnhSYOouVcXl9ORCuWqKXFzeHz0gWjMagW0jP4r4xbLXpKX8KrnJbqyFvuhQxH4LEu8i8RGYyUYiAV1OouVcXl9OiDSBhRKX8LXFzuZyae2xf1H6viEPhfpc)kOm(HmsYYy(Y4VmMNmI2BnkWZ4cyh)gTNkJjsiJ8iJO9wJIcymeqhA0EQmMVItZVgmH543mOI3quMIxswLLIBLJcgIkmfNRTJvkUgWjMagW0jvCA8zdFUIdT3A0u8rWWiNdeF5zgTNkJ)YiEn8Gbokykon)AWeMJFZGkEdrzkEjjvwkUvokyiQWuCA8zdFUIZCWkJ6q9keV0JUYrbdrg)LX8Kr7iMm(nzzm8iTmMiHmI2BnkkGXqaDOr7PYy(Y4VmMNmQzmac7RIc8mUaTJHgfpc)kOm(TmsAzmFz8xgZtg5rgnhSYONEToMF6khfmezmrczKhzeT3A0tVwhZpTNkJ)YipYOMXaiSVk6PxRJ5N2tLX8vCU2owP4COEfIx6PmfVHNklf3khfmevykon(SHpxXH2BnkWZ4cyh)gTNkJ)YyEYiUxRXWVr)6key68KddfapJlWd2XVv6rhj6xA6qKXejKrEKr0ERrjCOnSG1ewWedmIvgK2tLXFz0CWkJs4qBybRjSGjgyeRmiDLJcgImMVIZ12XkfhWZ4c0ogAktXB4sLLIBLJcgIkmfNgF2WNR4mhSYOdmIvMdeOahA0vokyiY4VmMNms4danmJqg)qgdxKwgZxX5A7yLIBGrSYCGaf4qtzkE)mvwkUvokyiQWuCA8zdFUIZCWkJcngMi5w6W0vokyiY4VmMNmI9drSmRmQJGaPAwVmz8dz8tYyIeYi2peXYSYOoccKELm(TmssKwgZxg)LX8KrcFaOHzeY4hYijtYYy(koxBhRuCqJHjsULoSYu8govzP4w5OGHOctXPXNn85koZbRm60bSREcyatNKUYrbdrg)LrnJbqyFvuGNXfODm0O4r4xbLXpilJpnIIZ12Xkf30bSREcyatNuzkEdH0QSuCRCuWquHP404Zg(CfN5GvgD6a2vpbmGPtsx5OGHiJ)YiAV1OthWU6jGbmDsApvX5A7yLId4zCbAhdnLP4nKquzP4w5OGHOctXPXNn85koZbRmk4ir)qee(JWfgZgbDLJcgIIZ12Xkfh4ir)qee(JWfgZgHYu8gs2QSuCRCuWquHP404Zg(CfhAV1OthWguWAIhEUjG9cz4RE0EQm(lJMdwzuchAdlynHfmXaJyLbPRCuWqKXFzeT3AuchAdlynHfmXaJyLbP9ufNRTJvkU5ylGeDp5uMI3q(Kklf3khfmevykon(SHpxXH2Bnk0yyIKBPdt7PY4VmI2BnkHdTHfSMWcMyGrSYG0EQm(lJe(aqdZiKXpKXWJ0koxBhRuCG7fy1vpbkdyktXBiKSklf3khfmevykon(SHpxXH2Bn60bSbfSM4HNBcyVqg(QhTNkJ)YyEYO5GvgLWH2WcwtybtmWiwzq6khfmez8xgZtgr7TgLWH2WcwtybtmWiwzqApvgtKqg1mgaH9vrbEgxG2XqJIhHFfug)wgjTm(lJe(aqdZiKXVjlJHZSLXejKry6aaH543mivh4xja3lWQREY4hYy2Y4VmI2Bnk0yyIKBPdt7PY4VmQzmac7RIc8mUaTJHgfpc)kOm(bzz8PrKX8LXejKrEKrZbRmkHdTHfSMWcMyGrSYG0vokyiYyIeYOMXaiSVk6aJyL5abkWHgfpc)kOm(bzzeoZU6bPqZ1jfO9wByzKuLXNgrgjvzmBzmFfNRTJvkU5ylGeDp5uMI3qijvwkUvokyiQWuCA8zdFUIdMoaqyo(nds1b(vcW9cS6QNm(TmgIm(lJ8iJimJ2aoXeWaMojfVgEWahfmz8xg5rgX9Ang(n60bSbfSM4HNBcyVqg(QhDKOFPPdrg)LX8KrEKrZbRmkHdTHfSMWcMyGrSYG0vokyiYyIeYiAV1Oeo0gwWAclyIbgXkds7PYyIeYOMXaiSVkkWZ4c0ogAu8i8RGY43YiPLXFzKWhaAygHm(nzzmCMTmMVIZ12Xkf3CSfqIUNCktXBiHNklf3khfmevykon(SHpxXPzmac7RsGNRnz8xgZtg5rgr7TgLWH2WcwtybtmWiwzqApvg)Lr0ERrp9ADm)0EQmMVIZ12XkfhWZ4c0ogAktXBiHlvwkUvokyiQWuCA8zdFUItZyae2xLapxBY4VmQdC8Bqz8Bz0CWkJoDatWAclyIbgXkdsx5OGHiJ)YipYiAV1ONEToMFApvX5A7yLId4zCbAhdnLP4nKptLLIBLJcgIkmfNgF2WNR4mhSYOthWeSMWcMyGrSYG0vokyiY4VmYJmI2BnkHdTHfSMWcMyGrSYG0EQm(lJe(aqdZiKXVjlJKePLXFzKhzeT3A0PdydkynXdp3eWEHm8vpApvX5A7yLId4zCbAhdnLP4nKWPklf3khfmevykon(SHpxXLNmI71Am8B0PdydkynXdp3eWEHm8vp6ir)sthImMiHmcthaimh)MbP6a)kb4EbwD1tg)qgZwgZxg)LX8KrZbRmkHdTHfSMWcMyGrSYG0vokyiY4VmYJmI2Bn60bSbfSM4HNBcyVqg(QhTNkJ)YyEYiAV1Oeo0gwWAclyIbgXkds7PYyIeYiHpa0Wmcz8BYYy4mBzmrczeMoaqyo(nds1b(vcW9cS6QNm(HmMTm(lJO9wJcngMi5w6W0EQm(lJAgdGW(QOapJlq7yOrXJWVckJFqwgFAezmFzmrczKhz0CWkJs4qBybRjSGjgyeRmiDLJcgImMiHmQzmac7RIoWiwzoqGcCOrXJWVckJFqwgHZSREqk0CDsbAV1gwgjvz8PrKrsvgZwgZxX5A7yLIBo2ceWaMoPYu8MnPvzP4w5OGHOctXPXNn85koZbRm6PxRJ5NUYrbdrg)LrZbRmkHdTHfSMWcMyGrSYG0vokyiY4VmI2Bn6PxRJ5N2tLXFzeT3AuchAdlynHfmXaJyLbP9ufNRTJvkUgMbnbmGPtQmfVzhIklf3khfmevykon(SHpxXH2BnQd1Rq8spApvX5A7yLId4zCbAhdnLP4n7SvzP4w5OGHOctXPXNn85konJbqyFvc8CTjJ)YipYO5GvgLWH2WcwtybtmWiwzq6khfmefNRTJvkoGNXfODm0uMI3S)Kklf3khfmevykon(SHpxXzoyLrp9ADm)0vokyiY4VmYJmMNms4danmJqg)wg)ejjJ)YOMXaiSVkkWZ4c0ogAu8i8RGY4hKLrslJ5R4CTDSsXD616y(vMI3SjzvwkUvokyiQWuCA8zdFUIZCWkJE616y(PRCuWqKXFzeT3A0tVwhZpTNkJ)YyEYiAV1ONEToMFkEe(vqz8dz8PrKrsvgjzzKuLr0ERrp9ADm)uO56KYyIeYiAV1OqJHjsULomTNkJjsiJ8iJMdwzuchAdlynHfmXaJyLbPRCuWqKX8vCU2owP4Ayg0eWaMoPYu8MnjPYsX5A7yLId4zCbAhdnf3khfmevyktXB2HNklf3khfmevykoxBhRuCnGtmbmGPtQ404Zg(CfhEn8Gbokykon)AWeMJFZGkEdrzkEZoCPYsXTYrbdrfMItJpB4ZvC4ETgd)gDGrSYCGyKOFGdfFDc6ir)sthIm(lJ8iJO9wJoWiwzoqms0pWHIVoHazO9wJ2tLXFzKhz0CWkJoWiwzoqGcCOrx5OGHiJ)YipYO5GvgD6a2vpbmGPtsx5OGHO4CTDSsX1WmOjGbmDsLP4n7ptLLIBLJcgIkmfNgF2WNR4GSoa9keAggWTdmbKbYSYORCuWquCU2owP4AGbd0yVzkURSHX9utXfIYu8MD4uLLIZ12XkfNoWVse44mdAkUvokyiQWuMI3prAvwkUvokyiQWuCA8zdFUIZCWkJE616y(PRCuWqKXFzeT3A0tVwhZpTNQ4CTDSsX1WmOjGbmDsLP49tHOYsXTYrbdrfMItJpB4ZvCMdwzuO52Pfihuh443ORCuWquCU2owP4GMBNwGCqDGJFtzkE)u2QSuCRCuWquHP404Zg(CfhpYO5GvgnfFeoqmWiwzo4GgDLJcgImMiHmYJmMoJ2o8edmIvMdOU2UmtX5A7yLIBo2cedmIvMduMI3p9jvwkUvokyiQWuCA8zdFUIdMoaqyo(nds1b(vcW9cS6QNm(TmgIIZ12XkfNoWVsaUxGvx9uMI3prYQSuCU2owP4a3lWQREcugWuCRCuWquHPmfVFIKuzP4iyzU6P4nef3khfmbblZvpvykoxBhRuCnGtmbmGPtQ408Rbtyo(ndQ4nefNgF2WNR4WRHhmWrbtXTYrbdrfMYu8(PWtLLIBLJcgIkmf3khfmbblZvpvykon(SHpxXrWYmIvgf5GMx6jJFlJHNIZ12Xkfxd4etady6KkocwMREkEdrzkE)u4sLLIJGL5QNI3quCRCuWeeSmx9uHP4CTDSsX1WmOjGbmDsf3khfmevyktX7N(mvwkUvokyiQWuCA8zdFUIZCWkJE616y(PRCuWqKXFzeT3A0tVwhZpTNkJ)YiAV1ONEToMFkEe(vqz8dzeoZU6bPqZ1jfO9wByzKuLXNgrgjvzeT3A0tVwhZpfAUoPIZ12XkfxdZGMagW0jvMYuCiR5DGPYsXBiQSuCRCuWquHP4qguJVu7yLIJuOSHX9utgznzu7qdsvCU2owP4(6kebmyowzkEZwLLIJGL5QNI3quCRCuWeeSmx9uHP4CTDSsXbtp8zF5GKddfpSRNIBLJcgIkmLP49tQSuCU2owP4sz2Xkf3khfmevyktXljRYsX5A7yLIRdN4SravCRCuWquHPmfVKKklf3khfmevykon(SHpxXLNmYJmAoyLrhyeRmhiqbo0ORCuWqKX8LXFzKhz0oDYREY4VmYJmMoJcngMqmWiwzoG6A7Ymz8xgZtgHPdaeMJFZGuDGFLaCVaRU6jJFiJFsgtKqgnhSYOeo0gwWAclyIbgXkdsx5OGHiJjsiJ4ETgd)gfMKFu88KddfTBy(fiJ4GJos0V00HiJ5R4CTDSsX1aoXeWaMoPYu8gEQSuCRCuWquHP404Zg(CfhpYOD6Kx9KXFzmpzKhzmDgfAmmHyGrSYCa112LzYyIeYimDaGWC8BgKQd8ReG7fy1vpz8dz8tY4VmI2Bn6xxHiEDOrHMRtkJFiJztAzmFz8xgZtgHPdaeMJFZGuDGFLaCVaRU6jJFiJFsgtKqgnhSYOeo0gwWAclyIbgXkdsx5OGHiJjsiJ4ETgd)gfMKFu88KddfTBy(fiJ4GJos0V00HiJ5R4CTDSsX1aoXeWaMoPYu8gUuzP4CTDSsX1o8edmIvMduCRCuWquHPmfVFMklfNRTJvkoIzJHvCRCuWquHPmfVHtvwkUvokyiQWuCA8zdFUIJhz0CWkJ6q9keV0JUYrbdrgtKqgr7Tg1H6viEPhTNkJjsiJAgdGW(QOouVcXl9O4r4xbLXVLrsI0koxBhRuCOagdr06y(vMI3qiTklf3khfmevykon(SHpxXXJmAoyLrDOEfIx6rx5OGHiJjsiJO9wJ6q9keV0J2tvCU2owP4qhgoCYREktXBiHOYsXTYrbdrfMItJpB4ZvC8iJMdwzuhQxH4LE0vokyiYyIeYiAV1OouVcXl9O9uzmrczuZyae2xf1H6viEPhfpc)kOm(TmssKwX5A7yLIRD4HcymeLP4nKSvzP4w5OGHOctXPXNn85koEKrZbRmQd1Rq8sp6khfmezmrczeT3AuhQxH4LE0EQmMiHmQzmac7RI6q9keV0JIhHFfug)wgjjsR4CTDSsX5LEqd7aH2baLP4nKpPYsXTYrbdrfMItJpB4ZvC8iJMdwzuhQxH4LE0vokyiYyIeYipYiAV1OouVcXl9O9ufNRTJvkou)jynHHpDsOYu8gcjRYsX5A7yLIlZGPdlmMncf3khfmevyktXBiKKklf3khfmevykon(SHpxXPzzw5LrR7fyIMpz8xg5rgX9Ang(nkCdbkynb2js9Yepm7llGos0V00HiJ)YyEYipYO5GvgLWH2WcwtybtmWiwzq6khfmezmrczeT3AuchAdlynHfmXaJyLbP9uzmFz8xgHPdaeMJFZGuDGFLaCVaRU6jJFiJFsX5A7yLIR5tyyVGTo8yLYu8gs4PYsXTYrbdrfMItJpB4ZvCAwMvEz06EbMO5tg)LrCVwJHFJc3qGcwtGDIuVmXdZ(YcOJe9lnDiY4VmMNmYJmAoyLrjCOnSG1ewWedmIvgKUYrbdrgtKqgr7TgLWH2WcwtybtmWiwzqApvgtKqgHPdaeMJFZGuDGFLaCVaRU6jJFtwg)KmMVm(lJ5jJAgdGW(QOTdpXaJyL5akEe(vqz8BzmBslJjsiJAgdGW(QOqJHjedmIvMdO4r4xbLXVLXSjTmMVIZ12XkfxZNWWEbBD4XkLP4nKWLklf3khfmevykon(SHpxX5A7YmXQrCdkJFlJzlJ)YyEYimDaGWC8BgKQd8ReG7fy1vpz8BzmBzmrczeMoaqyo(ndsbEgxGoNqg)wgZwgZxXbn8PnfVHO4CTDSsXH7LW12Xkb4GMIdCqtuoXuCoBktXBiFMklf3khfmevykon(SHpxXXJmAoyLrHgdtigyeRmhqx5OGHiJ)YORTlZeRgXnOm(bzzmBfh0WN2u8gIIZ12XkfhUxcxBhReGdAkoWbnr5etXbV6bMWC8BMYu8gs4uLLIBLJcgIkmfNgF2WNR4mhSYOqJHjedmIvMdORCuWqKXFz012LzIvJ4gug)GSmMTIdA4tBkEdrX5A7yLId3lHRTJvcWbnfh4GMOCIP4GtaV6bMWC8BMYuMIlfpnJa1nvwkEdrLLIBLJcgIkmfNRTJvkU5ylqmWiwzoqXHmOgFP2Xkfx4q470DBiY4Ymm)YODetgTGjJU2yyz8GYONXpGJcgvXPXNn85koEKrZbRmAk(iCGyGrSYCWbn6khfmeLP4nBvwkUvokyiQWuCU2owP4AGbd0yVzkoKb14l1owP4c3bozKZyyIKBPdlJP4PzeOUjJ9cmiugHmIjJoccug)6aazeM6FvYiKXkQItJpB4ZvCqwhGEfcnTdToyIH7P2Xk6khfmezmrczeY6a0RqOzya3oWeqgiZkJUYrbdrzkE)Kklf3khfmevykon(SHpxXzoyLrHgdtKClDy6khfmez8xgZtgX(HiwMvg1rqGunRxMm(Hm(jzmrcze7hIyzwzuhbbsVsg)wgjjslJ5R4CTDSsXbngMi5w6WktXljRYsX5A7yLIRD4jgyeRmhO4w5OGHOctzkEjjvwkUvokyiQWuCA8zdFUIZCWkJoWiwzoqGcCOrx5OGHiJ)YimDaGWC8BgKQd8ReG7fy1vpz8dz8tkoxBhRuCdmIvMdeOahAktXB4PYsXTYrbdrfMIZ12XkfhWZ4c0ogAkoWvtOruCFsXPXNn85koEKrZbRm6aJyL5abkWHgDLJcgIm(lJW0bacZXVzqQoWVsaUxGvx9KXpKXpjJjsiJO9wJcngMi5w6W0EQIdzqn(sTJvkUWM27WjJKIzctgdCOm6YOH9mdiJ2rSqLrlyYOJGWkzmf46bLrs1coOmUYW8tQYiRKXWTWDLXgdlJFsgHtZkeOmAmz0ZWoezeH1rb7ZJumtyYiRKX0oaqvMI3WLklf3khfmevykon(SHpxXXJmAoyLrhyeRmhiqbo0ORCuWqKXFzeMoaqyo(nds1b(vcW9cS6QNm(nzz8tY4VmYJmI2Bnk0yyIKBPdt7PkoxBhRuC6a)kb4EbwD1tzkE)mvwkoxBhRuCPm7yLIBLJcgIkmLPmfNZMklfVHOYsX5A7yLIdAmmHyGrSYCGIBLJcgIkmLP4nBvwkUvokyiQWuCA8zdFUIdT3AuTdacW9cS6Qhfpc)kOm(nzzmesR4CTDSsXn(NG1ewWeqJHjuMI3pPYsXTYrbdrfMItJpB4ZvCO9wJoDa7QNagW0jP9ufNRTJvkU5ylGeDp5uMIxswLLIZ12XkfNoWVse44mdAkUvokyiQWuMIxssLLIBLJcgIkmfNgF2WNR4mhSYOqJHjsULomDLJcgIIZ12Xkfh0yyIKBPdRmfVHNklf3khfmevykoxBhRuCnGtmbmGPtQ404Zg(CfhEn8GbokyY4VmMNmMNm6A7YmbcZOnGtmbmGPtkJFiJzlJ)YORTlZeRgXnOm(bzz8tY4VmQzmac7RIMIpcgg5CG4lpZO4r4xbLXpKXqcpz8xg1SmR8YO10ygGHrKXFzKhzmDgfAmmHyGrSYCa112LzYyIeYORTlZeimJ2aoXeWaMoPm(HmgIm(lJU2UmtSAe3GY43KLrswg)LrEKX0zuOXWeIbgXkZbuxBxMjJ)YO5GvgLWH2WcwtybtmWiwzq6khfmezmFzmrczmpze3R1y43OWK8JINNCyOODdZVazehC0rI(LMoez8xg5rgtNrHgdtigyeRmhqDTDzMmMVmMiHmMNmI71Am8Buyk4kB4HigyeRmiDKOFPPdrg)LX8KrxBxMjqygTbCIjGbmDsz8dz8tY4VmYJmI71Am8B0PdydkynXdp3eWEHm8vp6ir)sthImMiHm6A7YmbcZOnGtmbmGPtkJFiJKSmMVm(lJ5jJAgdGW(QOP4JGHrohi(YZmkEe(vqz8dzmKWtgtKqgr7TgnfFemmY5aXxEMr7PYy(Yy(Yy(kon)AWeMJFZGkEdrzkEdxQSuCRCuWquHP404Zg(CfhpYORTlZeimJ2aoXeWaMoPm(lJ8iJPZOqJHjedmIvMdOU2Umtg)LX8KrZbRmkHdTHfSMWcMyGrSYG0vokyiYyIeYiUxRXWVrHj5hfpp5Wqr7gMFbYio4OJe9lnDiYy(YyIeYyEYiUxRXWVrHPGRSHhIyGrSYG0rI(LMoez8xg5rgTtN8QNm(lJO9wJMIpcgg5CG4lpZO9uzmFfNRTJvkUgWjMagW0jvMI3ptLLIBLJcgIkmfNgF2WNR4mhSYOthWU6jGbmDs6khfmez8xgj8bGgMriJFtwgdpslJ)YyEYiUxRXWVrNoGnOG1ep8Cta7fYWx9OJe9lnDiY4VmI2Bn60bSbfSM4HNBcyVqg(QhTNkJjsiJ8iJ4ETgd)gD6a2Gcwt8WZnbSxidF1Jos0V00HiJ5R4CTDSsXnDa7QNagW0jvMI3WPklf3khfmevykon(SHpxXzoyLrDOEfIx6rx5OGHiJ)YyEYipYy6mk0yycXaJyL5aQRTlZKX8LXFzmpzKhz0CWkJE616y(PRCuWqKXejKrEKr0ERrp9ADm)0EQm(lJ8iJAgdGW(QONEToMFApvgZxX5A7yLIZH6viEPNYu8gcPvzP4w5OGHOctXPXNn85koZbRmk4ir)qee(JWfgZgbDLJcgIIZ12Xkfh4ir)qee(JWfgZgHYu8gsiQSuCRCuWquHP404Zg(CfhmDaGWC8BgKQd8ReG7fy1vpz8dzKKLXFzeT3AuchAdlynHfmXaJyLbP9uz8xgj8bGgMriJFiJKePvCU2owP40b(vcW9cS6QNYu8gs2QSuCRCuWquHP404Zg(CfhUxRXWVrNoGnOG1ep8Cta7fYWx9OJe9lnDiY4VmYJmI2Bn60bSbfSM4HNBcyVqg(QhTNQ4CTDSsXnhBbcyatNuzkEd5tQSuCRCuWquHP404Zg(CfhcZOnGtmbmGPtsXJWVckJ)YimDaGWC8BgKQd8ReG7fy1vpz8dzKKLXFzmpzKhzmDgfAmmHyGrSYCa112LzYy(Y4VmMNmI2BnkWZ4cyh)gTNkJ)YipYiAV1Oeo0gwWAclyIbgXkds7PY4VmAoyLrjCOnSG1ewWedmIvgKUYrbdrgZxX5A7yLId4zCbAhdnLP4neswLLIBLJcgIkmfNgF2WNR4GPdaeMJFZGuDGFLaCVaRU6jJFtwgZwg)LrEKrCVwJHFJoDaBqbRjE45Ma2lKHV6rhj6xA6qKXFzmpz0CWkJs4qBybRjSGjgyeRmiDLJcgIm(lJe(aqdZiKXVjlJKePLXFzKhzeT3AuchAdlynHfmXaJyLbP9uzmFfNRTJvkU5ylGeDp5uMI3qijvwkUvokyiQWuCU2owP4aEgxG2XqtXPXNn85konlZkVmAnnMbyyez8xgX9Ang(n60bSbfSM4HNBcyVqg(QhDKOFPPdrg)Lr4mbkR6qQDdN9Nji5uTm(lJO9wJc8mUa2XVr7PY4VmYJmI2BnAk(iyyKZbIV8mJ2tvCA(1Gjmh)Mbv8gIYu8gs4PYsXTYrbdrfMIZ12XkfhWZ4c0ogAkon(SHpxXH2BnkWZ4cyh)gTNkJ)YiAV1OP4JGHrohi(YZmApvg)LX8Kr0ERrtXhbdJCoq8LNzu8i8RGY4hY4NKrsvgFAezmrcz012LzceMrBaNycyatNugjlJW0bacZXVzqQoWVsaUxGvx9KXejKrxBxMjqygTbCIjGbmDszKSm(jz8xg5rgX9Ang(n60bSbfSM4HNBcyVqg(QhDKOFPPdrgtKqgDTDzMaHz0gWjMagW0jLrYYijlJ5R408Rbtyo(ndQ4neLP4nKWLklf3khfmevykon(SHpxXHWmAd4etady6Ku8i8RGY4Vmcthaimh)MbP6a)kb4EbwD1tg)qgjzz8xgX9Ang(nkmj)O45jhgkA3W8lqgXbhDKOFPPdrg)Lr0ERrbEgxa743O9uz8xgnhSYOeo0gwWAclyIbgXkdsx5OGHiJ)YipYiAV1Oeo0gwWAclyIbgXkds7PY4Vms4danmJqg)MSmssKwX5A7yLId4zCbAhdnLP4nKptLLIBLJcgIkmfNgF2WNR4qygTbCIjGbmDskEe(vqz8xgZtgZtgHPdaeMJFZGuDGFLaCVaRU6jJFiJKSm(lJ4ETgd)gfMKFu88KddfTBy(fiJ4GJos0V00HiJ)YO5GvgLWH2WcwtybtmWiwzq6khfmezmFzmrczmpz0CWkJs4qBybRjSGjgyeRmiDLJcgIm(lJe(aqdZiKXVjlJKePLXFzKhzeT3AuchAdlynHfmXaJyLbP9uz8xgZtg5rgX9Ang(n60bSbfSM4HNBcyVqg(QhDKOFPPdrgtKqgr7TgD6a2Gcwt8WZnbSxidF1J2tLX8LXFzKhze3R1y43OWK8JINNCyOODdZVazehC0rI(LMoezmFzmFfNRTJvkoGNXfODm0uMI3qcNQSuCRCuWquHP404Zg(CfhcZOnGtmbmGPtsXJWVckJ)YimDaGWC8BgKQd8ReG7fy1vpzKSmsYY4VmI71Am8Buys(rXZtomu0UH5xGmIdo6ir)sthIm(lJO9wJc8mUa2XVr7PY4VmAoyLrjCOnSG1ewWedmIvgKUYrbdrg)LrEKr0ERrjCOnSG1ewWedmIvgK2tLXFzKWhaAygHm(nzzKKiTIZ12XkfhWZ4c0ogAktXB2KwLLIBLJcgIkmfNgF2WNR4GPdaeMJFZGuDGFLaCVaRU6jJFtwgZwX5A7yLIBo2cir3toLP4n7quzP4w5OGHOctXPXNn85ko0ERrHgdtKClDykEe(vqz8dz8tYiPkJpnImsQYiAV1OqJHjsULomfAUoPIZ12XkfNoWVsaUxGvx9uMI3SZwLLIBLJcgIkmfNRTJvkoGNXfODm0uCA8zdFUIdotGYQoKA3Wz)zcsovlJ)YiAV1OapJlGD8B0EQm(lJ8iJO9wJMIpcgg5CG4lpZO9ufNMFnycZXVzqfVHOmfVz)jvwkUvokyiQWuCA8zdFUIdotGYQoKA3Wz)zcsovlJ)YiAV1OapJlGD8B0EQm(lJ8iJO9wJMIpcgg5CG4lpZO9ufNRTJvkoGNXfODm0uMI3SjzvwkUvokyiQWuCA8zdFUIdT3AuGNXfWo(nApvg)Lry6aaH543mivh4xja3lWQREY4hYijlJ)YyEYipYy6mk0yycXaJyL5aQRTlZKX8LXFzeHz0gWjMagW0jP2PtE1tX5A7yLId4zCbAhdnLP4nBssLLIBLJcgIkmfNgF2WNR4mhSYOdmIvMdeOahA0vokyiY4Vmcthaimh)MbP6a)kb4EbwD1tg)qgjjz8xgZtg5rgtNrHgdtigyeRmhqDTDzMmMVIZ12Xkf3aJyL5abkWHMYu8MD4PYsXTYrbdrfMItJpB4ZvCMdwzuhQxH4LE0vokyikoxBhRuCapJlqNtOmfVzhUuzP4CTDSsXPd8ReG7fy1vpf3khfmevyktXB2FMklf3khfmevykUvokyccwMREQWuCA8zdFUIdT3AuGNXfWo(nApvg)LrnJbqyFvc8CTP4CTDSsXb8mUaTJHMIJGL5QNI3quMI3SdNQSuCeSmx9u8gIIBLJcMGGL5QNkmfNRTJvkUgWjMagW0jvCA(1Gjmh)Mbv8gIItJpB4ZvC41Wdg4OGP4w5OGHOctzkE)ePvzP4iyzU6P4nef3khfmbblZvpvykoxBhRuCnmdAcyatNuXTYrbdrfMYuMIdob8QhycZXVzQSu8gIklfNRTJvkoOXWeIbgXkZbkUvokyiQWuMI3SvzP4w5OGHOctXPXNn85ko0ERrHD8BcwtKY(AyApvX5A7yLIdCVaRU6jqzatzkE)Kklf3khfmevykoxBhRuCP4JGHrohi(YZmfNgF2WNR40SmR8YO10ygGHrKXFzKhzeT3A0u8rWWiNdeF5zgTNkJ)YipYiAV1OWuWv2WdrmWiwzqApvXP5xdMWC8BguXBiktXljRYsXTYrbdrfMItJpB4ZvCO9wJQDaqaUxGvx9O4r4xbLXVjlJHqAfNRTJvkUX)eSMWcMaAmmHYu8ssQSuCRCuWquHP404Zg(CfN5Gvg90R1X8tx5OGHiJ)YiAV1ONEToMFApvg)Lr0ERrp9ADm)u8i8RGY4hYiCMD1dsHMRtkq7T2WYiPkJpnImsQYiAV1ONEToMFk0CDsz8xgr7Tg9RRqeVo0OqZ1jLXpKXq(mfNRTJvkUgMbnbmGPtQmfVHNklf3khfmevykoxBhRuCnGtmbmGPtQ404Zg(CfhEn8Gbokykon)AWeMJFZGkEdrzkEdxQSuCRCuWquHP404Zg(CfN5Gvg90R1X8tx5OGHiJ)YiAV1ONEToMFApvg)Lr0ERrp9ADm)u8i8RGY4hYyi0qKrsvgFAezKuLr0ERrp9ADm)uO56KkoxBhRuCnmdAcyatNuzkE)mvwkUvokyiQWuCA8zdFUIZCWkJoWiwzoqGcCOrx5OGHO4CTDSsXnWiwzoqGcCOPmfVHtvwkUvokyiQWuCA8zdFUIZCWkJcngMi5w6W0vokyikoxBhRuCqJHjsULoSYu8gcPvzP4w5OGHOctXPXNn85koZbRm60bSREcyatNKUYrbdrg)LrnJbqyFvuGNXfODm0O4r4xbLXpilJpnIm(lJW0bacZXVzqQoWVsaUxGvx9KXpKXSLXejKrcFaOHzeY43KLXWJ0Y4Vmcthaimh)MbP6a)kb4EbwD1tg)MSmMTm(lJ5jJ8iJ4ETgd)gD6a2Gcwt8WZnbSxidF1Jos0V00HiJjsiJO9wJoDaBqbRjE45Ma2lKHV6r7PYy(YyIeYimDaGWC8BgKQd8ReG7fy1vpz8dzmBz8xgr7Tg9RRqeVo0OqZ1jLXVjlJH8zY4VmMNmYJmI71Am8B0PdydkynXdp3eWEHm8vp6ir)sthImMiHmI2Bn60bSbfSM4HNBcyVqg(QhTNkJ5lJ)YiHpa0Wmcz8BYYy4rAfNRTJvkUPdyx9eWaMoPYu8gsiQSuCRCuWquHP404Zg(CfxEYiAV1OFDfI41HgfAUoPm(HmgYNjJ)YipYiAV1OOagdb0HgTNkJ5lJjsiJO9wJc8mUa2XVr7PkoxBhRuCapJlq7yOPmfVHKTklf3khfmevykon(SHpxXzoyLrNoGD1tady6K0vokyiY4VmI2Bn60bSREcyatNK2tLXFzeMoaqyo(nds1b(vcW9cS6QNm(HmMTIZ12XkfhWZ4c0ogAktXBiFsLLIBLJcgIkmfNgF2WNR4mhSYOthWU6jGbmDs6khfmez8xgr7TgD6a2vpbmGPts7PY4Vmcthaimh)MbP6a)kb4EbwD1tg)MSmMTIZ12Xkf3CSfqIUNCktXBiKSklf3khfmevykon(SHpxXH2Bnk0yyIKBPdt7PkoxBhRuCG7fy1vpbkdyktXBiKKklf3khfmevykon(SHpxXH2Bn60bSbfSM4HNBcyVqg(QhTNQ4CTDSsXnhBbKO7jNYu8gs4PYsXTYrbdrfMItJpB4ZvCW0bacZXVzqQoWVsaUxGvx9KXpKXSLXFzKWhaAygHm(nzzm8iTm(lJ5jJO9wJ(1viIxhAuO56KY4hYy2KwgtKqgj8bGgMriJFlJHtslJ5lJjsiJ5jJ4ETgd)gD6a2Gcwt8WZnbSxidF1Jos0V00HiJ)YipYiAV1OthWguWAIhEUjG9cz4RE0EQmMVmMiHmI71Am8B0VUcbMop5WqbWZ4c8GD8BLE0rI(LMoefNRTJvkU5ylqady6KktXBiHlvwkUvokyiQWuCA8zdFUIlpzeMoaqyo(nds1b(vcW9cS6QNm(TmgImMVm(lJ5jJ8iJimJ2aoXeWaMojfVgEWahfmzmFfNRTJvkU5ylGeDp5uMI3q(mvwkUvokyiQWuCA8zdFUIZ12LzIvJ4gug)wgdrg)LX0zuOXWeIbgXkZbuxBxMjJ)YiAV1OOagdb0HgTNQ4CTDSsXPd8ReG7fy1vpLP4nKWPklf3khfmevykon(SHpxXLoJcngMqmWiwzoG6A7Ymz8xgr7TgffWyiGo0O9ufNRTJvkoW9cS6QNaLbmLP4nBsRYsXTYrbdrfMItJpB4ZvCO9wJ6q9keV0J2tvCU2owP4aEgxG2XqtzkEZoevwkUvokyiQWuCA8zdFUItZyae2xLapxBkoxBhRuCapJlq7yOPmfVzNTklf3khfmevykon(SHpxXPzmac7RsGNRnz8xg1bo(nOm(TmAoyLrNoGjynHfmXaJyLbPRCuWquCU2owP4aEgxG2XqtzkEZ(tQSuCRCuWquHP404Zg(CfN5Gvg90R1X8tx5OGHiJ)YiAV1ONEToMFApvX5A7yLIRHzqtady6KktXB2KSklfNRTJvkoDGFLiWXzg0uCRCuWquHPmfVztsQSuCRCuWquHP404Zg(CfhK1bOxHqZWaUDGjGmqMvgDLJcgIIZ12XkfxdmyGg7ntXDLnmUNAkUquMI3SdpvwkUvokyiQWuCA8zdFUIZCWkJcn3oTa5G6ah)gDLJcgIIZ12Xkfh0C70cKdQdC8BktXB2HlvwkUvokyiQWuCA8zdFUIJhz0CWkJMIpchigyeRmhCqJUYrbdrgtKqgnhSYOP4JWbIbgXkZbh0ORCuWqKXFzmpzKhzmDgfAmmHyGrSYCa112LzYy(koxBhRuCZXwGyGrSYCGYu8M9NPYsXTYrbdrfMItJpB4ZvCU2UmtSAe3GY43YyiY4VmMNmcthaimh)MbP6a)kb4EbwD1tg)wgdrgtKqgHPdaeMJFZGuGNXfOZjKXVLXqKX8vCU2owP40b(vcW9cS6QNYu8MD4uLLIZ12Xkfh4EbwD1tGYaMIBLJcgIkmLP49tKwLLIJGL5QNI3quCRCuWeeSmx9uHP4CTDSsX1aoXeWaMoPItZVgmH543mOI3quCA8zdFUIdVgEWahfmf3khfmevyktX7NcrLLIBLJcgIkmf3khfmbblZvpvykon(SHpxXrWYmIvgf5GMx6jJFlJHNIZ12Xkfxd4etady6KkocwMREkEdrzkE)u2QSuCeSmx9u8gIIBLJcMGGL5QNkmfNRTJvkUgMbnbmGPtQ4w5OGHOctzktzktzkfa]] )

end
