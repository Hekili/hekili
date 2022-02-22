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

    spec:RegisterPack( "Elemental", 20220221, [[dKKFmcqiePhjkuTjvvFcrOgLOkNsuvRsuGxjQ0See3svrv2fs)suXWqvQJHQQLjk6zQkY0qeCnuLyBIc6BIcLXPQOCouLuRdvjP5PQW9qu7tvPoOQIQAHcspuuimrrHiDruLeBuuikFuvrfDseHyLOQmteH0nffIQDIQ4NQkQKLQQOs9uuzQcQUQOqeFvvrfgROqYEP4VegSqhMQfJWJP0KH4YkBwkFwvgTaNwLxlknBGBdPDl53OmCr64iIwouph00jDDPA7IOVRQKXlkK68ckZxe2prB43eUHdX1z4jtENzM8oZm5NMj)KqM8ZVHtdlDgUu3M1FZWvo6mC8kGHUsDGHl1ddWCet4goiRJTZWfOAkKxnNCENg0jOwgAoWdTdC9yLf7nnh4HAZXWr0pGsIugcdhIRZWtM8oZm5DMzYpnt(jHm59NmCW0zn8KzgMPHl4qqwzimCidAnC8kGHUsDGmYf4OEj5lJSrG7oomzmt(drgZK3zMPKpjFzebE9gKxvY3NNmsIuwgoLHDDYiCQE1dsHQBZki6T2WYyJHLrse7ADCyHiJCkdJMDlDyQKVppz8ZhbrgZiF6yyz0lezKxjSjJSMmQbtg5uggvg9NFf1WLIzTdmdxgpJlJ8kGHUsDGmYf4OEj5lJNXLXmYgbU74WKXm5pezmtENzMs(K8LXZ4YygrGxVb5vL8LXZ4Y4NNmsIuwgoLHDDYiCQE1dsHQBZki6T2WYyJHLrse7ADCyHiJCkdJMDlDyQKVmEgxg)8KXpFeezmJ8PJHLrVqKrELWMmYAYOgmzKtzyuz0F(vujFs(Y4YiVsg9SDDiY4soCyYOEOtg1GjJUvzyz8GYON0pGtagvYNB1JvqAkEwgkHRKNJ1aXadDL6GqUgzsvhSsPP4d1bIbg6k1bhuPRCcWqK8LXLXmsGtg5uggn7w6WYykEwgkHRYyVadcLridDYOJGaLXVoaqgHP(xLmczSIk5ZT6XkinfpldLW1CjNtdmyGf7nnKRrgY6aIRqOPDO2btmCpvpwLibK1bexHqtYaUEGjGmqYvQKp3QhRG0u8SmucxZLCoqLHrZULoCixJS6GvkfQmmA2T0HPRCcWq(Zd7hIyjxPuhbbsTSEPF8PejW(HiwYvk1rqG0R(Mx4D(s(CREScstXZYqjCnxY50o8edm0vQdK85w9yfKMINLHs4AUKZzGHUsDGGa4qnKRrwDWkLoWqxPoqqaCOsx5eGH8dthaiuh)McP2a)kb4EbAD17Jpj5lJlJHoR3HtgjrtgQmg4qz0Lrf7jhqg1dDHiJAWKrhbHvYykWTdkJzGgCqzCLIdldKrwjJzezKkJngwg)KmcNLviqzuzYONKDiYicRta2NhjAYqLrwjJPDaGk5ZT6XkinfpldLW1CjNdWt6cIogQHaUAclc5pfY1itQ6GvkDGHUsDGGa4qLUYjad5hMoaqOo(nfsTb(vcW9c06Q3hFkrcIERrHkdJMDlDyApvYNB1JvqAkEwgkHR5sohBGFLaCVaTU6fY1itQ6GvkDGHUsDGGa4qLUYjad5hMoaqOo(nfsTb(vcW9c06Q33K)0pPe9wJcvggn7w6W0EQKp3QhRG0u8SmucxZLCoPm9yLKpjFzCzKeP0HX9uvgznz06qfsL85w9yfmxY581vicyWCSKp3QhRG5sohy6Hp9lhKDyO4HD7cbLL8Qhz(L85w9yfmxY5KY0Jvs(CREScMl5C6WjoDOqjFUvpwbZLConGJobmGzZgY1iNhPQdwP0bg6k1bccGdv6kNamK8)jvpB2RE)KMoLcvggvmWqxPoG6w9sU)8GPdaeQJFtHuBGFLaCVaTU69XNsKqDWkLI6qDybRj0GjgyORuiDLtagsIe4ETgd)gfMnmc88SddfTB4Weid9GJos2V00HKVKVCLr3QhRG5soNu8HYWiNdeF5jxi2WSGjuh)McjZFixJmPe9wJMIpugg5CG4lp5O90)8inDkfQmmQyGHUsDa1T6LCjsathaiuh)McP2a)kb4EbAD17Jp9t0Bn6xxHiEDOsHQBZ(rM8orciRdiUcHcMJiictSmAhnfm6kNamKejW9Ang(nkmfCLo8qedm0vkKos2V00HK)FEW0bac1XVPqQnWVsaUxGwx9(GxsKqDWkLI6qDybRj0GjgyORuiDLtagsIe4ETgd)gfMnmc88SddfTB4Weid9GJos2V00HKibK1bexHqbZreeHjwgTJMcgDLtagsIe4ETgd)gfMcUshEiIbg6kfshj7xA6qY)NuIERrHPGR0HhIyGHUsH0EQKp3QhRG5soNgWrNagWSzd5AKjvpB2RE)5rA6ukuzyuXadDL6aQB1l5sKaMoaqOo(nfsTb(vcW9c06Q3hF6NO3A0VUcr86qLcv3M9Jm5D()5bthaiuh)McP2a)kb4EbAD17JpLiH6Gvkf1H6WcwtObtmWqxPq6kNamKejW9Ang(nkmBye45zhgkA3WHjqg6bhDKSFPPdjFjFUvpwbZLCoTdpXadDL6ajFUvpwbZLCoOthdl5ZT6XkyUKZHaWyiIwhhwixJmPQdwPuhAxH4LD0vobyijsq0BnQdTRq8YoApnrclJbqyFvuhAxH4LDu8q9RGFZl8wYNB1JvWCjNdXWWHZE1lKRrMu1bRuQdTRq8Yo6kNamKeji6Tg1H2viEzhTNk5ZT6XkyUKZPD4raymKqUgzsvhSsPo0UcXl7ORCcWqsKGO3AuhAxH4LD0EAIewgdGW(QOo0UcXl7O4H6xb)Mx4TKp3QhRG5sohVSdQyhiSoaeY1itQ6Gvk1H2viEzhDLtagsIee9wJ6q7keVSJ2ttKWYyae2xf1H2viEzhfpu)k438cVL85w9yfmxY5q4pbRju8zZcd5AKjvDWkL6q7keVSJUYjadjrcsj6Tg1H2viEzhTNk5ZT6XkyUKZj5GPdluMoujFUvpwbZLConFcf7fS1HhRc5AKTSKR8sP19curZ3pP4ETgd)gfUHafSMa7OPEPIhM9Lgqhj7xA6q(ZJu1bRukQd1HfSMqdMyGHUsH0vobyijsq0BnkQd1HfSMqdMyGHUsH0EA()W0bac1XVPqQnWVsaUxGwx9(4ts(CREScMl5CA(ek2lyRdpwfY1iBzjx5LsR7fOIMVFCVwJHFJc3qGcwtGD0uVuXdZ(sdOJK9lnDi)5rQ6Gvkf1H6WcwtObtmWqxPq6kNamKeji6Tgf1H6WcwtObtmWqxPqApnrcy6aaH643ui1g4xja3lqRREFt(t5)NNLXaiSVkA7WtmWqxPoGIhQFf87m5DIewgdGW(QOqLHrfdm0vQdO4H6xb)otENVKp3QhRG5sohCVeUvpwjahudPC0r2zleOIpRsM)qUgz3QxYjwn0BWVZ8ppy6aaH643ui1g4xja3lqRREFNzIeW0bac1XVPqkWt6cI5OFNz(s(CREScMl5CW9s4w9yLaCqnKYrhz4vpWeQJFtdbQ4ZQK5pKRrMu1bRukuzyuXadDL6a6kNamKF3QxYjwn0BWpiNPKp3QhRG5sohCVeUvpwjahudPC0rgob8Qhyc1XVPHav8zvY8hY1iRoyLsHkdJkgyORuhqx5eGH87w9soXQHEd(b5mL8j5ZT6Xki1zJmuzyuXadDL6ajFUvpwbPoB5soNf2eSMqdMaQmmAixJmrV1OwhaeG7fO1vpkEO(vWVjZpVL85w9yfK6SLl5CMJ1as29SlKRrMO3A0zdyx9eWaMnlTNk5ZT6Xki1zlxY5yd8Reboo5GQKp3QhRGuNTCjNduzy0SBPdhY1iRoyLsHkdJMDlDy6kNamejFUvpwbPoB5soNgWrNagWSzdXgMfmH643uiz(d5AKZZT6LCceMsBahDcyaZM9Jm)DREjNy1qVb)G8N(TmgaH9vrtXhkdJCoq8LNCu8q9RGFWFg(Bzjx5LsRzXmadJ8tA6ukuzyuXadDL6aQB1l5sKWT6LCceMsBahDcyaZM9d()DREjNy1qVb)Mmj8tA6ukuzyuXadDL6aQB1l5(vhSsPOouhwWAcnyIbg6kfsx5eGHKFIe5H71Am8Buy2WiWZZomu0UHdtGm0do6iz)sthYpPPtPqLHrfdm0vQdOUvVKl)ejYd3R1y43OWuWv6WdrmWqxPq6iz)sthYFEUvVKtGWuAd4Otady2SF8PFsX9Ang(n6SbSbfSM4HNRcyVqg(QhDKSFPPdjrc3QxYjqykTbC0jGbmB2piH8)ZZYyae2xfnfFOmmY5aXxEYrXd1Vc(b)zyIee9wJMIpugg5CG4lp5O908Zpe1XVPIRrgVgEWaNamjFUvpwbPoB5soNgWrNagWSzd5AKj1T6LCceMsBahDcyaZM9N00PuOYWOIbg6k1bu3QxY9NN6Gvkf1H6WcwtObtmWqxPq6kNamKejW9Ang(nkmBye45zhgkA3WHjqg6bhDKSFPPdj)ejYd3R1y43OWuWv6WdrmWqxPq6iz)sthYpP6zZE17NO3A0u8HYWiNdeF5jhTNMVKp3QhRGuNTCjNZSbSREcyaZMnKRrwDWkLoBa7QNagWSzPRCcWq(r9bGkMH(n5mK3)5H71Am8B0zdydkynXdpxfWEHm8vp6iz)sthYprV1OZgWguWAIhEUkG9cz4RE0EAIeKI71Am8B0zdydkynXdpxfWEHm8vp6iz)sths(s(CREScsD2YLCoo0UcXl7c5AKvhSsPo0UcXl7ORCcWq(ZJ00PuOYWOIbg6k1bu3QxYL)FEKQoyLsp7ADCy0vobyijsqkrV1ONDToomAp9NulJbqyFv0ZUwhhgTNMVKp3QhRGuNTCjNd4iz)qeO(d1fkthAixJS6GvkfCKSFicu)H6cLPdLUYjadrYNB1JvqQZwUKZXg4xja3lqRREHCnYW0bac1XVPqQnWVsaUxGwx9(Ge(j6Tgf1H6WcwtObtmWqxPqAp9h1haQyg6h8cVL85w9yfK6SLl5CMJ1abmGzZgY1iJ71Am8B0zdydkynXdpxfWEHm8vp6iz)sthYpPe9wJoBaBqbRjE45Qa2lKHV6r7Ps(CREScsD2YLCoapPli6yOgY1iJWuAd4Otady2Su8q9RG)W0bac1XVPqQnWVsaUxGwx9(Ge(ZJ00PuOYWOIbg6k1bu3QxYL)FEe9wJc8KUa2XVr7P)Ks0BnkQd1HfSMqdMyGHUsH0E6V6Gvkf1H6WcwtObtmWqxPq6kNamK8L85w9yfK6SLl5CMJ1as29SlKRrgMoaqOo(nfsTb(vcW9c06Q33KZ8NuCVwJHFJoBaBqbRjE45Qa2lKHV6rhj7xA6q(ZtDWkLI6qDybRj0GjgyORuiDLtagYpQpauXm0VjZl8(NuIERrrDOoSG1eAWedm0vkK2tZxYNB1JvqQZwUKZb4jDbrhd1qSHzbtOo(nfsM)qUgzll5kVuAnlMbyyKFCVwJHFJoBaBqbRjE45Qa2lKHV6rhj7xA6q(HtfeSQdP6nCMFMGesT)e9wJc8KUa2XVr7P)Ks0BnAk(qzyKZbIV8KJ2tL85w9yfK6SLl5CaEsxq0XqneBywWeQJFtHK5pKRrMO3AuGN0fWo(nAp9NO3A0u8HYWiNdeF5jhTN(NhrV1OP4dLHrohi(YtokEO(vWp(ug8Sijs4w9sobctPnGJobmGzZsgMoaqOo(nfsTb(vcW9c06QxIeUvVKtGWuAd4Otady2SK)0pP4ETgd)gD2a2Gcwt8WZvbSxidF1Jos2V00HKiHB1l5eimL2ao6eWaMnlzsiFjFUvpwbPoB5sohGN0feDmud5AKrykTbC0jGbmBwkEO(vWFy6aaH643ui1g4xja3lqRREFqc)4ETgd)gfMnmc88SddfTB4Weid9GJos2V00H8t0BnkWt6cyh)gTN(RoyLsrDOoSG1eAWedm0vkKUYjad5NuIERrrDOoSG1eAWedm0vkK2t)r9bGkMH(nzEH3s(CREScsD2YLCoapPli6yOgY1iJWuAd4Otady2Su8q9RG)5LhmDaGqD8BkKAd8ReG7fO1vVpiHFCVwJHFJcZggbEE2HHI2nCycKHEWrhj7xA6q(vhSsPOouhwWAcnyIbg6kfsx5eGHKFIe5PoyLsrDOoSG1eAWedm0vkKUYjad5h1haQyg63K5fE)tkrV1OOouhwWAcnyIbg6kfs7P)5rkUxRXWVrNnGnOG1ep8Cva7fYWx9OJK9lnDijsq0Bn6SbSbfSM4HNRcyVqg(QhTNM)pP4ETgd)gfMnmc88SddfTB4Weid9GJos2V00HKF(s(CREScsD2YLCoapPli6yOgY1iJWuAd4Otady2Su8q9RG)W0bac1XVPqQnWVsaUxGwx9itc)4ETgd)gfMnmc88SddfTB4Weid9GJos2V00H8t0BnkWt6cyh)gTN(RoyLsrDOoSG1eAWedm0vkKUYjad5NuIERrrDOoSG1eAWedm0vkK2t)r9bGkMH(nzEH3s(CREScsD2YLCoZXAaj7E2fY1idthaiuh)McP2a)kb4EbAD17BYzk5ZT6Xki1zlxY5yd8ReG7fO1vVqUgzIERrHkdJMDlDykEO(vWp(ug8SizarV1OqLHrZULomfQUnRKp3QhRGuNTCjNdWt6cIogQHydZcMqD8BkKm)HCnYWPccw1Hu9goZptqcP2FIERrbEsxa743O90Fsj6TgnfFOmmY5aXxEYr7Ps(CREScsD2YLCoapPli6yOgY1idNkiyvhs1B4m)mbjKA)j6Tgf4jDbSJFJ2t)jLO3A0u8HYWiNdeF5jhTNk5ZT6Xki1zlxY5a8KUGOJHAixJmrV1OapPlGD8B0E6pmDaGqD8BkKAd8ReG7fO1vVpiH)8inDkfQmmQyGHUsDa1T6LC5)JWuAd4Otady2Su9SzV6j5ZT6Xki1zlxY5mWqxPoqqaCOgY1iRoyLshyORuhiiaouPRCcWq(HPdaeQJFtHuBGFLaCVaTU69bV8NhPPtPqLHrfdm0vQdOUvVKlFjFUvpwbPoB5sohGN0feZrd5AKvhSsPo0UcXl7ORCcWqK85w9yfK6SLl5CSb(vcW9c06QNKp3QhRGuNTCjNdWt6cIogQHGYsE1Jm)HCnYe9wJc8KUa2XVr7P)wgdGW(Qe45wvYNB1JvqQZwUKZPbC0jGbmB2qqzjV6rM)qSHzbtOo(nfsM)qUgz8A4bdCcWK85w9yfK6SLl5CAygufWaMnBiOSKx9iZVKpjFUvpwbPWjGx9atOo(nLmuzyuXadDL6ajFUvpwbPWjGx9atOo(nnxY5aUxGwx9eemGgY1it0BnkSJFtWAIu2xdt7Ps(CREScsHtaV6bMqD8BAUKZjfFOmmY5aXxEYfInmlyc1XVPqY8hY1iBzjx5LsRzXmadJ8tkrV1OP4dLHrohi(YtoAp9NuIERrHPGR0HhIyGHUsH0EQKp3QhRGu4eWREGjuh)MMl5CwytWAcnycOYWOHCnYe9wJADaqaUxGwx9O4H6xb)Mm)8wYNB1JvqkCc4vpWeQJFtZLConmdQcyaZMnKRrwDWkLE2164WORCcWq(j6Tg9SR1XHr7P)e9wJE2164WO4H6xb)aovV6bPq1Tzfe9wB4m4zrYaIERrp7ADCyuO62S)e9wJ(1viIxhQuO62SFW)Nj5ZT6Xkifob8Qhyc1XVP5soNbg6k1bccGd1qUgz1bRu6adDL6abbWHkDLtagIKp3QhRGu4eWREGjuh)MMl5CGkdJMDlD4qUgz1bRukuzy0SBPdtx5eGHi5ZT6Xkifob8Qhyc1XVP5soNzdyx9eWaMnBixJS6GvkD2a2vpbmGzZsx5eGH8Bzmac7RIc8KUGOJHkfpu)k4hKFwKFy6aaH643ui1g4xja3lqRREFKzIeO(aqfZq)MCgY7Fy6aaH643ui1g4xja3lqRREFtoZ)8if3R1y43OZgWguWAIhEUkG9cz4RE0rY(LMoKeji6TgD2a2Gcwt8WZvbSxidF1J2tZprcy6aaH643ui1g4xja3lqRREFK5prV1OFDfI41HkfQUn73K5)Z(ZJuCVwJHFJoBaBqbRjE45Qa2lKHV6rhj7xA6qsKGO3A0zdydkynXdpxfWEHm8vpApn)FuFaOIzOFtod5TKp3QhRGu4eWREGjuh)MMl5CaEsxq0XqnKRropIERr)6keXRdvkuDB2p4)Z(jLO3AucaJHa6qL2tZprcIERrbEsxa743O9ujFUvpwbPWjGx9atOo(nnxY5a8KUGOJHAixJS6GvkD2a2vpbmGzZsx5eGH8t0Bn6SbSREcyaZML2t)HPdaeQJFtHuBGFLaCVaTU69rMs(CREScsHtaV6bMqD8BAUKZzowdiz3ZUqUgz1bRu6SbSREcyaZMLUYjad5NO3A0zdyx9eWaMnlTN(dthaiuh)McP2a)kb4EbAD17BYzk5ZT6Xkifob8Qhyc1XVP5sohW9c06QNGGb0qUgzIERrHkdJMDlDyApvYNB1JvqkCc4vpWeQJFtZLCoZXAaj7E2fY1it0Bn6SbSbfSM4HNRcyVqg(QhTNk5ZT6Xkifob8Qhyc1XVP5soN5ynqady2SHCnYW0bac1XVPqQnWVsaUxGwx9(iZFuFaOIzOFtod59FEe9wJ(1viIxhQuO62SFKjVtKa1haQyg638AENFIe5H71Am8B0zdydkynXdpxfWEHm8vp6iz)sthYpPe9wJoBaBqbRjE45Qa2lKHV6r7P5l5ZT6Xkifob8Qhyc1XVP5soN5ynGKDp7c5AKZdMoaqOo(nfsTb(vcW9c06Q338N)FEKIWuAd4Otady2Su8A4bdCcWYxYNB1JvqkCc4vpWeQJFtZLCo2a)kb4EbAD1lKRr2T6LCIvd9g8B()tNsHkdJkgyORuhqDREj3prV1Oeagdb0HkTNk5ZT6Xkifob8Qhyc1XVP5sohW9c06QNGGb0qUg50PuOYWOIbg6k1bu3QxY9t0BnkbGXqaDOs7Ps(CREScsHtaV6bMqD8BAUKZb4jDbrhd1qUgzIERrDODfIx2r7Ps(CREScsHtaV6bMqD8BAUKZb4jDbrhd1qUgzlJbqyFvc8CRk5ZT6Xkifob8Qhyc1XVP5sohGN0feDmud5AKTmgaH9vjWZT6VnWXVb)wDWkLoBatWAcnyIbg6kfsx5eGHi5ZT6Xkifob8Qhyc1XVP5soNgMbvbmGzZgY1iRoyLsp7ADCy0vobyi)e9wJE2164WO9ujFUvpwbPWjGx9atOo(nnxY5yd8Reboo5GQKp3QhRGu4eWREGjuh)MMl5CAGbdSyVPHCLomUNQK5pKRrgY6aIRqOjzaxpWeqgi5kvYNB1JvqkCc4vpWeQJFtZLCoq11ZkqoOnWXVfY1iRoyLsHQRNvGCqBGJFJUYjadrYNB1JvqkCc4vpWeQJFtZLCoZXAGyGHUsDqixJmPQdwP0u8H6aXadDL6GdQ0vobyijsOoyLstXhQdedm0vQdoOsx5eGH8NhPPtPqLHrfdm0vQdOUvVKlFjFUvpwbPWjGx9atOo(nnxY5yd8ReG7fO1vVqUgz3QxYjwn0BWV5)ppy6aaH643ui1g4xja3lqRREFZFIeW0bac1XVPqkWt6cI5OFZF(s(CREScsHtaV6bMqD8BAUKZbCVaTU6jiyavYNB1JvqkCc4vpWeQJFtZLConGJobmGzZgckl5vpY8hInmlyc1XVPqY8hY1iJxdpyGtaMKp3QhRGu4eWREGjuh)MMl5CAahDcyaZMneuwYREK5pKRrgLLCORukYbvVS77muYNB1JvqkCc4vpWeQJFtZLConmdQcyaZMneuwYREK5xYNKp3QhRGu4vpWeQJFtjdUxGwx9eemGgY1iNhrV1OqLHrZULomfpu)k4hWP6vpifQUnRGO3AdNbplsgq0Bnkuzy0SBPdtHQBZMVKp3QhRGu4vpWeQJFtZLConmdQcyaZMnKRrwDWkLE2164WORCcWq(j6Tg9SR1XHr7P)e9wJE2164WO4H6xb)aovV6bPq1Tzfe9wB4m4zrYaIERrp7ADCyuO62Ss(CREScsHx9atOo(nnxY50ao6eWaMnBi2WSGjuh)McjZFixJCEKQNn7vVejqykTbC0jGbmBwkEO(vWpi)SijsOoyLsDODfIx2rx5eGH8JWuAd4Otady2Su8q9RGFKNLXaiSVkQdTRq8YokEO(vWCj6Tg1H2viEzhfPJD9yv()wgdGW(QOo0UcXl7O4H6xb)GeY)ppIERrbEsxa743O90ejiLO3AucaJHa6qL2tZxYNB1Jvqk8Qhyc1XVP5soNgWrNagWSzdXgMfmH643uiz(d5AKj6TgnfFOmmY5aXxEYr7P)41Wdg4eGj5ZT6XkifE1dmH6430CjNJdTRq8YUqUgz1bRuQdTRq8Yo6kNamK)80dDFtod5DIee9wJsaymeqhQ0EA()5zzmac7RIc8KUGOJHkfpu)k438o))8ivDWkLE2164WORCcWqsKGuIERrp7ADCy0E6pPwgdGW(QONDToomApnFjFUvpwbPWREGjuh)MMl5CaEsxq0XqnKRrMO3AuGN0fWo(nAp9ppCVwJHFJ(1viW05zhgkaEsxGhSJFRSJos2V00HKibPe9wJI6qDybRj0GjgyORuiTN(RoyLsrDOoSG1eAWedm0vkKUYjadjFjFUvpwbPWREGjuh)MMl5CgyORuhiiaoud5AKvhSsPdm0vQdeeahQ0vobyi)5H6davmd9JmgVZxYNB1Jvqk8Qhyc1XVP5sohOYWOz3shoKRrwDWkLcvggn7w6W0vobyi)5H9drSKRuQJGaPwwV0p(uIey)qel5kL6iiq6vFZl8o))8q9bGkMH(bjqc5l5ZT6XkifE1dmH6430CjNZSbSREcyaZMnKRrwDWkLoBa7QNagWSzPRCcWq(TmgaH9vrbEsxq0XqLIhQFf8dYplIKp3QhRGu4vpWeQJFtZLCoapPli6yOgY1iRoyLsNnGD1tady2S0vobyi)e9wJoBa7QNagWSzP9ujFUvpwbPWREGjuh)MMl5Cahj7hIa1FOUqz6qd5AKvhSsPGJK9drG6puxOmDO0vobyis(CREScsHx9atOo(nnxY5mhRbKS7zxixJmrV1OZgWguWAIhEUkG9cz4RE0E6V6Gvkf1H6WcwtObtmWqxPq6kNamKFIERrrDOoSG1eAWedm0vkK2tL85w9yfKcV6bMqD8BAUKZbCVaTU6jiyanKRrMO3AuOYWOz3shM2t)j6Tgf1H6WcwtObtmWqxPqAp9h1haQyg6hziVL85w9yfKcV6bMqD8BAUKZzowdiz3ZUqUgzIERrNnGnOG1ep8Cva7fYWx9O90)8uhSsPOouhwWAcnyIbg6kfsx5eGH8NhrV1OOouhwWAcnyIbg6kfs7Pjsyzmac7RIc8KUGOJHkfpu)k438(h1haQyg63K51zMibmDaGqD8BkKAd8ReG7fO1vVpY8NO3AuOYWOz3shM2t)TmgaH9vrbEsxq0XqLIhQFf8dYpls(jsqQ6Gvkf1H6WcwtObtmWqxPq6kNamKejSmgaH9vrhyORuhiiaouP4H6xb)GmCQE1dsHQBZki6T2WzWZIKbzMVKp3QhRGu4vpWeQJFtZLCoZXAaj7E2fY1idthaiuh)McP2a)kb4EbAD17B()jfHP0gWrNagWSzP41Wdg4eG9tkUxRXWVrNnGnOG1ep8Cva7fYWx9OJK9lnDi)5rQ6Gvkf1H6WcwtObtmWqxPq6kNamKeji6Tgf1H6WcwtObtmWqxPqApnrclJbqyFvuGN0feDmuP4H6xb)M3)O(aqfZq)MmVoZ8L85w9yfKcV6bMqD8BAUKZb4jDbrhd1qUgzlJbqyFvc8CR(NhPe9wJI6qDybRj0GjgyORuiTN(t0Bn6zxRJdJ2tZxYNB1Jvqk8Qhyc1XVP5sohGN0feDmud5AKTmgaH9vjWZT6VnWXVb)wDWkLoBatWAcnyIbg6kfsx5eGH8tkrV1ONDToomApvYNB1Jvqk8Qhyc1XVP5sohGN0feDmud5AKvhSsPZgWeSMqdMyGHUsH0vobyi)Ks0BnkQd1HfSMqdMyGHUsH0E6pQpauXm0VjZl8(NuIERrNnGnOG1ep8Cva7fYWx9O9ujFUvpwbPWREGjuh)MMl5CMJ1abmGzZgY1iNhUxRXWVrNnGnOG1ep8Cva7fYWx9OJK9lnDijsathaiuh)McP2a)kb4EbAD17JmZ)pp1bRukQd1HfSMqdMyGHUsH0vobyi)Ks0Bn6SbSbfSM4HNRcyVqg(QhTN(NhrV1OOouhwWAcnyIbg6kfs7PjsG6davmd9BY86mtKaMoaqOo(nfsTb(vcW9c06Q3hz(t0Bnkuzy0SBPdt7P)wgdGW(QOapPli6yOsXd1Vc(b5Nfj)ejivDWkLI6qDybRj0GjgyORuiDLtagsIewgdGW(QOdm0vQdeeahQu8q9RGFqgovV6bPq1Tzfe9wB4m4zrYGmZxYNB1Jvqk8Qhyc1XVP5soNgMbvbmGzZgY1iRoyLsp7ADCy0vobyi)QdwPuuhQdlynHgmXadDLcPRCcWq(j6Tg9SR1XHr7P)e9wJI6qDybRj0GjgyORuiTNk5ZT6XkifE1dmH6430CjNdWt6cIogQHCnYe9wJ6q7keVSJ2tL85w9yfKcV6bMqD8BAUKZb4jDbrhd1qUgzlJbqyFvc8CR(tQ6Gvkf1H6WcwtObtmWqxPq6kNamejFUvpwbPWREGjuh)MMl5Co7ADCyHCnYQdwP0ZUwhhgDLtagYpP5H6davmd97pXl)wgdGW(QOapPli6yOsXd1Vc(bzENVKp3QhRGu4vpWeQJFtZLConmdQcyaZMnKRrwDWkLE2164WORCcWq(j6Tg9SR1XHr7P)5r0Bn6zxRJdJIhQFf8JNfjdiHmGO3A0ZUwhhgfQUnBIee9wJcvggn7w6W0EAIeKQoyLsrDOoSG1eAWedm0vkKUYjadjFjFUvpwbPWREGjuh)MMl5CaEsxq0XqvYNB1Jvqk8Qhyc1XVP5soNgWrNagWSzdXgMfmH643uiz(d5AKXRHhmWjatYNB1Jvqk8Qhyc1XVP5soNgMbvbmGzZgY1iJ71Am8B0bg6k1bIrY(boc81rPJK9lnDi)Ks0Bn6adDL6aXiz)ahb(6OcKr0BnAp9Nu1bRu6adDL6abbWHkDLtagYpPQdwP0zdyx9eWaMnlDLtagIKp3QhRGu4vpWeQJFtZLConWGbwS30qUshg3tvY8hY1idzDaXvi0KmGRhycidKCLk5ZT6XkifE1dmH6430CjNJnWVse44KdQs(CREScsHx9atOo(nnxY50WmOkGbmB2qUgz1bRu6zxRJdJUYjad5NO3A0ZUwhhgTNk5ZT6XkifE1dmH6430CjNduD9ScKdAdC8BHCnYQdwPuO66zfih0g443ORCcWqK85w9yfKcV6bMqD8BAUKZzowdedm0vQdc5AKjvDWkLMIpuhigyORuhCqLUYjadjrcstNsBhEIbg6k1bu3QxYj5ZT6XkifE1dmH6430CjNJnWVsaUxGwx9c5AKHPdaeQJFtHuBGFLaCVaTU69n)s(CREScsHx9atOo(nnxY5aUxGwx9eemGk5ZT6XkifE1dmH6430CjNtd4Otady2SHGYsE1Jm)HydZcMqD8BkKm)HCnY41Wdg4eGj5ZT6XkifE1dmH6430CjNtd4Otady2SHGYsE1Jm)HCnYOSKdDLsroO6LDFNHs(CREScsHx9atOo(nnxY50WmOkGbmB2qqzjV6rMFjFUvpwbPWREGjuh)MMl5CAygufWaMnBixJS6Gvk9SR1XHrx5eGH8t0Bn6zxRJdJ2t)j6Tg9SR1XHrXd1Vc(bCQE1dsHQBZki6T2WzWZIKbe9wJE2164WOq1TznCjhgESYWtM8ot(5ptENXmCF546Qh0W954Z)ZnpKi885KxvgLXWdMmEOPmSkJngwgjXWREGjuh)MsILr8iz)WdrgHm0jJExzOUoez0g41BqQKps0RMmM5NXRkJzeSk5W6qKrsmK1bexHqZOiXYOYKrsmK1bexHqZOORCcWqiXYORYiVYNlsuzmp(ZOZNk5tY3NJp)p38qIWZNtEvzugdpyY4HMYWQm2yyzKeNINLHs4kjwgXJK9dpezeYqNm6DLH66qKrBGxVbPs(irVAYyM8QYygbRsoSoezKedzDaXvi0mksSmQmzKedzDaXvi0mk6kNamesSmMh)z05tL8rIE1KXm5vLXmcwLCyDiYijgY6aIRqOzuKyzuzYijgY6aIRqOzu0vobyiKyz0vzKx5ZfjQmMh)z05tL8j57ZXN)NBEir45ZjVQmkJHhmz8qtzyvgBmSmsIHtaV6bMqD8BkjwgXJK9dpezeYqNm6DLH66qKrBGxVbPs(irVAYyMFIxvgZiyvYH1HiJKyiRdiUcHMrrILrLjJKyiRdiUcHMrrx5eGHqILrxLrELpxKOYyE8NrNpvYNKpse0ugwhImYlYOB1JvYi4GkKk5ZWboOcnHB4Gx9atOo(n1eUHh(nHB4w5eGHyc1WzXNo85gU8KrIERrHkdJMDlDykEO(vqz8dzeovV6bPq1Tzfe9wByzmdKXNfrgZazKO3AuOYWOz3shMcv3MvgZ3W5w9yLHdCVaTU6jiya1OgEY0eUHBLtagIjudNfF6WNB4uhSsPNDToom6kNamez8xgj6Tg9SR1XHr7PY4Vms0Bn6zxRJdJIhQFfug)qgHt1REqkuDBwbrV1gwgZaz8zrKXmqgj6Tg9SR1XHrHQBZA4CRESYW1WmOkGbmBwJA45tMWnCRCcWqmHA4CRESYW1ao6eWaMnRHZIpD4ZnC5jJKkJ6zZE1tgtKqgrykTbC0jGbmBwkEO(vqz8dYY4ZIiJjsiJQdwPuhAxH4LD0vobyiY4VmIWuAd4Otady2Su8q9RGY4hYyEYOLXaiSVkQdTRq8YokEO(vqzmxzKO3AuhAxH4LDuKo21JvYy(Y4VmAzmac7RI6q7keVSJIhQFfug)qgjbzmFz8xgZtgj6Tgf4jDbSJFJ2tLXejKrsLrIERrjamgcOdvApvgZ3WzdZcMqD8Bk0Wd)g1Wdjyc3WTYjadXeQHZT6Xkdxd4Otady2Sgol(0Hp3Wr0BnAk(qzyKZbIV8KJ2tLXFzeVgEWaNamdNnmlyc1XVPqdp8Budp8IjCd3kNametOgol(0Hp3WPoyLsDODfIx2rx5eGHiJ)YyEYOEOtg)MSmMH8wgtKqgj6TgLaWyiGouP9uzmFz8xgZtgTmgaH9vrbEsxq0XqLIhQFfug)wg5TmMVm(lJ5jJKkJQdwP0ZUwhhgDLtagImMiHmsQms0Bn6zxRJdJ2tLXFzKuz0Yyae2xf9SR1XHr7PYy(go3QhRmCo0UcXl7mQHNm0eUHBLtagIjudNfF6WNB4i6Tgf4jDbSJFJ2tLXFzmpze3R1y43OFDfcmDE2HHcGN0f4b743k7OJK9lnDiYyIeYiPYirV1OOouhwWAcnyIbg6kfs7PY4VmQoyLsrDOoSG1eAWedm0vkKUYjadrgZ3W5w9yLHd4jDbrhdvJA4jJzc3WTYjadXeQHZIpD4ZnCQdwP0bg6k1bccGdv6kNamez8xgZtgr9bGkMHkJFiJzmElJ5B4CRESYWnWqxPoqqaCOAudpFMjCd3kNametOgol(0Hp3WPoyLsHkdJMDlDy6kNamez8xgZtgX(HiwYvk1rqGulRxQm(Hm(jzmrcze7hIyjxPuhbbsVsg)wg5fElJ5lJ)YyEYiQpauXmuz8dzKeibzmFdNB1JvgoOYWOz3sh2OgE41MWnCRCcWqmHA4S4th(CdN6GvkD2a2vpbmGzZsx5eGHiJ)YOLXaiSVkkWt6cIogQu8q9RGY4hKLXNfXW5w9yLHB2a2vpbmGzZAudp8ZBt4gUvobyiMqnCw8PdFUHtDWkLoBa7QNagWSzPRCcWqKXFzKO3A0zdyx9eWaMnlTNA4CRESYWb8KUGOJHQrn8Wp)MWnCRCcWqmHA4S4th(CdN6GvkfCKSFicu)H6cLPdLUYjadXW5w9yLHdCKSFicu)H6cLPd1OgE4ptt4gUvobyiMqnCw8PdFUHJO3A0zdydkynXdpxfWEHm8vpApvg)Lr1bRukQd1HfSMqdMyGHUsH0vobyiY4Vms0BnkQd1HfSMqdMyGHUsH0EQHZT6Xkd3CSgqYUNDg1Wd)FYeUHBLtagIjudNfF6WNB4i6TgfQmmA2T0HP9uz8xgj6Tgf1H6WcwtObtmWqxPqApvg)LruFaOIzOY4hYygYBdNB1JvgoW9c06QNGGbuJA4HFsWeUHBLtagIjudNfF6WNB4i6TgD2a2Gcwt8WZvbSxidF1J2tLXFzmpzuDWkLI6qDybRj0GjgyORuiDLtagIm(lJ5jJe9wJI6qDybRj0GjgyORuiTNkJjsiJwgdGW(QOapPli6yOsXd1VckJFlJ8wg)LruFaOIzOY43KLrEDMYyIeYimDaGqD8BkKAd8ReG7fO1vpz8dzmtz8xgj6TgfQmmA2T0HP9uz8xgTmgaH9vrbEsxq0XqLIhQFfug)GSm(SiYy(YyIeYiPYO6Gvkf1H6WcwtObtmWqxPq6kNamezmrcz0Yyae2xfDGHUsDGGa4qLIhQFfug)GSmcNQx9GuO62ScIERnSmMbY4ZIiJzGmMPmMVHZT6Xkd3CSgqYUNDg1Wd)8IjCd3kNametOgol(0Hp3Wbthaiuh)McP2a)kb4EbAD1tg)wg5xg)LrsLreMsBahDcyaZMLIxdpyGtaMm(lJKkJ4ETgd)gD2a2Gcwt8WZvbSxidF1Jos2V00HiJ)YyEYiPYO6Gvkf1H6WcwtObtmWqxPq6kNamezmrczKO3AuuhQdlynHgmXadDLcP9uzmrcz0Yyae2xff4jDbrhdvkEO(vqz8BzK3Y4VmI6davmdvg)MSmYRZugZ3W5w9yLHBowdiz3ZoJA4H)m0eUHBLtagIjudNfF6WNB4SmgaH9vjWZTQm(lJ5jJKkJe9wJI6qDybRj0GjgyORuiTNkJ)YirV1ONDToomApvgZ3W5w9yLHd4jDbrhdvJA4H)mMjCd3kNametOgol(0Hp3Wzzmac7RsGNBvz8xgTbo(nOm(TmQoyLsNnGjynHgmXadDLcPRCcWqKXFzKuzKO3A0ZUwhhgTNA4CRESYWb8KUGOJHQrn8W)Nzc3WTYjadXeQHZIpD4ZnCQdwP0zdycwtObtmWqxPq6kNamez8xgjvgj6Tgf1H6WcwtObtmWqxPqApvg)LruFaOIzOY43KLrEH3Y4VmsQms0Bn6SbSbfSM4HNRcyVqg(QhTNA4CRESYWb8KUGOJHQrn8WpV2eUHBLtagIjudNfF6WNB4YtgX9Ang(n6SbSbfSM4HNRcyVqg(QhDKSFPPdrgtKqgHPdaeQJFtHuBGFLaCVaTU6jJFiJzkJ5lJ)YyEYO6Gvkf1H6WcwtObtmWqxPq6kNamez8xgjvgj6TgD2a2Gcwt8WZvbSxidF1J2tLXFzmpzKO3AuuhQdlynHgmXadDLcP9uzmrcze1haQygQm(nzzKxNPmMiHmcthaiuh)McP2a)kb4EbAD1tg)qgZug)LrIERrHkdJMDlDyApvg)LrlJbqyFvuGN0feDmuP4H6xbLXpilJplImMVmMiHmsQmQoyLsrDOoSG1eAWedm0vkKUYjadrgtKqgTmgaH9vrhyORuhiiaouP4H6xbLXpilJWP6vpifQUnRGO3AdlJzGm(SiYygiJzkJ5B4CRESYWnhRbcyaZM1OgEYK3MWnCRCcWqmHA4S4th(CdN6Gvk9SR1XHrx5eGHiJ)YO6Gvkf1H6WcwtObtmWqxPq6kNamez8xgj6Tg9SR1XHr7PY4Vms0BnkQd1HfSMqdMyGHUsH0EQHZT6XkdxdZGQagWSznQHNm53eUHBLtagIjudNfF6WNB4i6Tg1H2viEzhTNA4CRESYWb8KUGOJHQrn8KzMMWnCRCcWqmHA4S4th(CdNLXaiSVkbEUvLXFzKuzuDWkLI6qDybRj0GjgyORuiDLtagIHZT6XkdhWt6cIogQg1WtMFYeUHBLtagIjudNfF6WNB4uhSsPNDToom6kNamez8xgjvgZtgr9bGkMHkJFlJFIxKXFz0Yyae2xff4jDbrhdvkEO(vqz8dYYiVLX8nCUvpwz4o7ADCyg1WtMKGjCd3kNametOgol(0Hp3WPoyLsp7ADCy0vobyiY4Vms0Bn6zxRJdJ2tLXFzmpzKO3A0ZUwhhgfpu)kOm(Hm(SiYygiJKGmMbYirV1ONDToomkuDBwzmrczKO3AuOYWOz3shM2tLXejKrsLr1bRukQd1HfSMqdMyGHUsH0vobyiYy(go3QhRmCnmdQcyaZM1OgEYKxmHB4CRESYWb8KUGOJHQHBLtagIjuJA4jZm0eUHBLtagIjudNB1JvgUgWrNagWSznCw8PdFUHdVgEWaNamdNnmlyc1XVPqdp8BudpzMXmHB4w5eGHyc1WzXNo85goCVwJHFJoWqxPoqms2pWrGVokDKSFPPdrg)LrsLrIERrhyORuhigj7h4iWxhvGmIERr7PY4VmsQmQoyLshyORuhiiaouPRCcWqKXFzKuzuDWkLoBa7QNagWSzPRCcWqmCUvpwz4AygufWaMnRrn8K5Nzc3WTYjadXeQHZIpD4ZnCqwhqCfcnjd46bMaYajxP0vobyigo3QhRmCnWGbwS3ud3v6W4EQA443OgEYKxBc3W5w9yLHZg4xjcCCYbvd3kNametOg1WZN4TjCd3kNametOgol(0Hp3WPoyLsp7ADCy0vobyiY4Vms0Bn6zxRJdJ2tnCUvpwz4AygufWaMnRrn88j(nHB4w5eGHyc1WzXNo85go1bRukuD9ScKdAdC8B0vobyigo3QhRmCq11ZkqoOnWXVzudpFktt4gUvobyiMqnCw8PdFUHJuzuDWkLMIpuhigyORuhCqLUYjadrgtKqgjvgtNsBhEIbg6k1bu3QxYz4CRESYWnhRbIbg6k1bg1WZN(KjCd3kNametOgol(0Hp3Wbthaiuh)McP2a)kb4EbAD1tg)wg53W5w9yLHZg4xja3lqRREg1WZNibt4go3QhRmCG7fO1vpbbdOgUvobyiMqnQHNpXlMWnCOSKx9m8WVHBLtaMaLL8QNjudNB1JvgUgWrNagWSznC2WSGjuh)Mcn8WVHZIpD4ZnC41Wdg4eGz4w5eGHyc1OgE(ugAc3WTYjadXeQHBLtaMaLL8QNjudNfF6WNB4qzjh6kLICq1l7KXVLXm0W5w9yLHRbC0jGbmBwdhkl5vpdp8BudpFkJzc3WHYsE1ZWd)gUvobycuwYREMqnCUvpwz4AygufWaMnRHBLtagIjuJA45tFMjCd3kNametOgol(0Hp3WPoyLsp7ADCy0vobyiY4Vms0Bn6zxRJdJ2tLXFzKO3A0ZUwhhgfpu)kOm(HmcNQx9GuO62ScIERnSmMbY4ZIiJzGms0Bn6zxRJdJcv3M1W5w9yLHRHzqvady2Sg1OgoK18oqnHB4HFt4gUvobyiMqnCidAXxQESYWrIu6W4EQkJSMmADOcPgo3QhRmCFDfIagmhBudpzAc3WHYsE1ZWd)gUvobycuwYREMqnCUvpwz4GPh(0VCq2HHIh2TZWTYjadXeQrn88jt4go3QhRmCPm9yLHBLtagIjuJA4HemHB4CRESYW1HtC6qHgUvobyiMqnQHhEXeUHBLtagIjudNfF6WNB4YtgjvgvhSsPdm0vQdeeahQ0vobyiYy(Y4VmsQmQNn7vpz8xgjvgtNsHkdJkgyORuhqDREjNm(lJ5jJW0bac1XVPqQnWVsaUxGwx9KXpKXpjJjsiJQdwPuuhQdlynHgmXadDLcPRCcWqKXejKrCVwJHFJcZggbEE2HHI2nCycKHEWrhj7xA6qKX8nCUvpwz4AahDcyaZM1OgEYqt4gUvobyiMqnCw8PdFUHJuzupB2REY4VmMNmsQmMoLcvggvmWqxPoG6w9sozmrczeMoaqOo(nfsTb(vcW9c06QNm(Hm(jz8xgj6Tg9RRqeVouPq1TzLXpKXm5TmMVm(lJ5jJW0bac1XVPqQnWVsaUxGwx9KXpKXpjJjsiJQdwPuuhQdlynHgmXadDLcPRCcWqKXejKrCVwJHFJcZggbEE2HHI2nCycKHEWrhj7xA6qKX8nCUvpwz4AahDcyaZM1OgEYyMWnCUvpwz4AhEIbg6k1bgUvobyiMqnQHNpZeUHZT6Xkdh60XWgUvobyiMqnQHhETjCd3kNametOgol(0Hp3WrQmQoyLsDODfIx2rx5eGHiJjsiJe9wJ6q7keVSJ2tLXejKrlJbqyFvuhAxH4LDu8q9RGY43YiVWBdNB1JvgocaJHiADCyg1Wd)82eUHBLtagIjudNfF6WNB4ivgvhSsPo0UcXl7ORCcWqKXejKrIERrDODfIx2r7Pgo3QhRmCeddho7vpJA4HF(nHB4w5eGHyc1WzXNo85gosLr1bRuQdTRq8Yo6kNamezmrczKO3AuhAxH4LD0EQmMiHmAzmac7RI6q7keVSJIhQFfug)wg5fEB4CRESYW1o8iamgIrn8WFMMWnCRCcWqmHA4S4th(CdhPYO6Gvk1H2viEzhDLtagImMiHms0BnQdTRq8YoApvgtKqgTmgaH9vrDODfIx2rXd1VckJFlJ8cVnCUvpwz48YoOIDGW6aGrn8W)NmHB4w5eGHyc1WzXNo85gosLr1bRuQdTRq8Yo6kNamezmrczKuzKO3AuhAxH4LD0EQHZT6XkdhH)eSMqXNnl0OgE4NemHB4CRESYWLCW0HfkthQHBLtagIjuJA4HFEXeUHBLtagIjudNfF6WNB4SSKR8sP19curZNm(lJKkJ4ETgd)gfUHafSMa7OPEPIhM9Lgqhj7xA6qKXFzmpzKuzuDWkLI6qDybRj0GjgyORuiDLtagImMiHms0BnkQd1HfSMqdMyGHUsH0EQmMVm(lJW0bac1XVPqQnWVsaUxGwx9KXpKXpz4CRESYW18juSxWwhESYOgE4pdnHB4w5eGHyc1WzXNo85goll5kVuADVav08jJ)YiUxRXWVrHBiqbRjWoAQxQ4HzFPb0rY(LMoez8xgZtgjvgvhSsPOouhwWAcnyIbg6kfsx5eGHiJjsiJe9wJI6qDybRj0GjgyORuiTNkJjsiJW0bac1XVPqQnWVsaUxGwx9KXVjlJFsgZxg)LX8KrlJbqyFv02HNyGHUsDafpu)kOm(TmMjVLXejKrlJbqyFvuOYWOIbg6k1bu8q9RGY43YyM8wgZ3W5w9yLHR5tOyVGTo8yLrn8WFgZeUHBLtagIjudNfF6WNB4CREjNy1qVbLXVLXmLXFzmpzeMoaqOo(nfsTb(vcW9c06QNm(TmMPmMiHmcthaiuh)McPapPliMJkJFlJzkJ5B4Gk(SQHh(nCUvpwz4W9s4w9yLaCq1WboOkkhDgoNnJA4H)pZeUHBLtagIjudNfF6WNB4ivgvhSsPqLHrfdm0vQdORCcWqKXFz0T6LCIvd9gug)GSmMPHdQ4ZQgE43W5w9yLHd3lHB1JvcWbvdh4GQOC0z4Gx9atOo(n1OgE4NxBc3WTYjadXeQHZIpD4ZnCQdwPuOYWOIbg6k1b0vobyiY4Vm6w9soXQHEdkJFqwgZ0Wbv8zvdp8B4CRESYWH7LWT6Xkb4GQHdCqvuo6mCWjGx9atOo(n1Og1WLINLHs4QjCdp8Bc3WTYjadXeQHZT6Xkd3CSgigyORuhy4qg0IVu9yLHJxjJE2UoezCjhomzup0jJAWKr3QmSmEqz0t6hWjaJA4S4th(CdhPYO6GvknfFOoqmWqxPo4GkDLtagIrn8KPjCd3kNametOgo3QhRmCnWGbwS3udhYGw8LQhRmCzKaNmYPmmA2T0HLXu8SmucxLXEbgekJqg6KrhbbkJFDaGmct9VkzeYyf1WzXNo85goiRdiUcHM2HAhmXW9u9yfDLtagImMiHmczDaXvi0KmGRhycidKCLsx5eGHyudpFYeUHBLtagIjudNfF6WNB4uhSsPqLHrZULomDLtagIm(lJ5jJy)qel5kL6iiqQL1lvg)qg)KmMiHmI9drSKRuQJGaPxjJFlJ8cVLX8nCUvpwz4GkdJMDlDyJA4HemHB4CRESYW1o8edm0vQdmCRCcWqmHAudp8IjCd3kNametOgol(0Hp3WPoyLshyORuhiiaouPRCcWqKXFzeMoaqOo(nfsTb(vcW9c06QNm(Hm(jdNB1JvgUbg6k1bccGdvJA4jdnHB4w5eGHyc1W5w9yLHd4jDbrhdvdh4QjSigUpz4S4th(CdhPYO6GvkDGHUsDGGa4qLUYjadrg)Lry6aaH643ui1g4xja3lqRREY4hY4NKXejKrIERrHkdJMDlDyAp1WHmOfFP6XkdxOZ6D4Krs0KHkJbougDzuXEYbKr9qxiYOgmz0rqyLmMcC7GYygObhugxP4WYazKvYygrgPYyJHLXpjJWzzfcugvMm6jzhImIW6eG95rIMmuzKvYyAhaOg1WtgZeUHBLtagIjudNfF6WNB4ivgvhSsPdm0vQdeeahQ0vobyiY4Vmcthaiuh)McP2a)kb4EbAD1tg)MSm(jz8xgjvgj6TgfQmmA2T0HP9udNB1JvgoBGFLaCVaTU6zudpFMjCdNB1JvgUuMESYWTYjadXeQrnQHZzZeUHh(nHB4CRESYWbvggvmWqxPoWWTYjadXeQrn8KPjCd3kNametOgol(0Hp3Wr0BnQ1bab4EbAD1JIhQFfug)MSmYpVnCUvpwz4wytWAcnycOYWOg1WZNmHB4w5eGHyc1WzXNo85goIERrNnGD1tady2S0EQHZT6Xkd3CSgqYUNDg1Wdjyc3W5w9yLHZg4xjcCCYbvd3kNametOg1WdVyc3WTYjadXeQHZIpD4ZnCQdwPuOYWOz3shMUYjadXW5w9yLHdQmmA2T0HnQHNm0eUHBLtagIjudNB1JvgUgWrNagWSznC2WSGjuh)Mcn8WVHZIpD4ZnC5jJUvVKtGWuAd4Otady2SY4hYyMY4Vm6w9soXQHEdkJFqwg)Km(lJwgdGW(QOP4dLHrohi(YtokEO(vqz8dzK)mug)Lrll5kVuAnlMbyyez8xgjvgtNsHkdJkgyORuhqDREjNmMiHm6w9sobctPnGJobmGzZkJFiJ8lJ)YOB1l5eRg6nOm(nzzKeKXFzKuzmDkfQmmQyGHUsDa1T6LCY4VmQoyLsrDOoSG1eAWedm0vkKUYjadrgZxgtKqgZtgX9Ang(nkmBye45zhgkA3WHjqg6bhDKSFPPdrg)LrsLX0PuOYWOIbg6k1bu3QxYjJ5lJjsiJ5jJ4ETgd)gfMcUshEiIbg6kfshj7xA6qKXFzmpz0T6LCceMsBahDcyaZMvg)qg)Km(lJKkJ4ETgd)gD2a2Gcwt8WZvbSxidF1Jos2V00HiJjsiJUvVKtGWuAd4Otady2SY4hYijiJ5lJ)YyEYOLXaiSVkAk(qzyKZbIV8KJIhQFfug)qg5pdLXejKrIERrtXhkdJCoq8LNC0EQmMVmMVHtD8BQ4Ago8A4bdCcWmQHNmMjCd3kNametOgol(0Hp3WrQm6w9sobctPnGJobmGzZkJ)YiPYy6ukuzyuXadDL6aQB1l5KXFzmpzuDWkLI6qDybRj0GjgyORuiDLtagImMiHmI71Am8Buy2WiWZZomu0UHdtGm0do6iz)sthImMVmMiHmMNmI71Am8Buyk4kD4HigyORuiDKSFPPdrg)LrsLr9SzV6jJ)YirV1OP4dLHrohi(YtoApvgZ3W5w9yLHRbC0jGbmBwJA45ZmHB4w5eGHyc1WzXNo85go1bRu6SbSREcyaZMLUYjadrg)LruFaOIzOY43KLXmK3Y4VmMNmI71Am8B0zdydkynXdpxfWEHm8vp6iz)sthIm(lJe9wJoBaBqbRjE45Qa2lKHV6r7PYyIeYiPYiUxRXWVrNnGnOG1ep8Cva7fYWx9OJK9lnDiYy(go3QhRmCZgWU6jGbmBwJA4HxBc3WTYjadXeQHZIpD4ZnCQdwPuhAxH4LD0vobyiY4VmMNmsQmMoLcvggvmWqxPoG6w9sozmFz8xgZtgjvgvhSsPNDToom6kNamezmrczKuzKO3A0ZUwhhgTNkJ)YiPYOLXaiSVk6zxRJdJ2tLX8nCUvpwz4CODfIx2zudp8ZBt4gUvobyiMqnCw8PdFUHtDWkLcos2pebQ)qDHY0Hsx5eGHy4CRESYWbos2pebQ)qDHY0HAudp8ZVjCd3kNametOgol(0Hp3Wbthaiuh)McP2a)kb4EbAD1tg)qgjbz8xgj6Tgf1H6WcwtObtmWqxPqApvg)LruFaOIzOY4hYiVWBdNB1JvgoBGFLaCVaTU6zudp8NPjCd3kNametOgol(0Hp3WH71Am8B0zdydkynXdpxfWEHm8vp6iz)sthIm(lJKkJe9wJoBaBqbRjE45Qa2lKHV6r7Pgo3QhRmCZXAGagWSznQHh()KjCd3kNametOgol(0Hp3WHWuAd4Otady2Su8q9RGY4Vmcthaiuh)McP2a)kb4EbAD1tg)qgjbz8xgZtgjvgtNsHkdJkgyORuhqDREjNmMVm(lJ5jJe9wJc8KUa2XVr7PY4VmsQms0BnkQd1HfSMqdMyGHUsH0EQm(lJQdwPuuhQdlynHgmXadDLcPRCcWqKX8nCUvpwz4aEsxq0Xq1OgE4NemHB4w5eGHyc1WzXNo85goy6aaH643ui1g4xja3lqRREY43KLXmLXFzKuze3R1y43OZgWguWAIhEUkG9cz4RE0rY(LMoez8xgZtgvhSsPOouhwWAcnyIbg6kfsx5eGHiJ)YiQpauXmuz8BYYiVWBz8xgjvgj6Tgf1H6WcwtObtmWqxPqApvgZ3W5w9yLHBowdiz3ZoJA4HFEXeUHBLtagIjudNB1JvgoGN0feDmunCw8PdFUHZYsUYlLwZIzaggrg)LrCVwJHFJoBaBqbRjE45Qa2lKHV6rhj7xA6qKXFzeovqWQoKQ3Wz(zcsi1kJ)YirV1OapPlGD8B0EQm(lJKkJe9wJMIpugg5CG4lp5O9udNnmlyc1XVPqdp8Budp8NHMWnCRCcWqmHA4CRESYWb8KUGOJHQHZIpD4ZnCe9wJc8KUa2XVr7PY4Vms0BnAk(qzyKZbIV8KJ2tLXFzmpzKO3A0u8HYWiNdeF5jhfpu)kOm(Hm(jzmdKXNfrgtKqgDREjNaHP0gWrNagWSzLrYYimDaGqD8BkKAd8ReG7fO1vpzmrcz0T6LCceMsBahDcyaZMvgjlJFsg)LrsLrCVwJHFJoBaBqbRjE45Qa2lKHV6rhj7xA6qKXejKr3QxYjqykTbC0jGbmBwzKSmscYy(goBywWeQJFtHgE43OgE4pJzc3WTYjadXeQHZIpD4ZnCimL2ao6eWaMnlfpu)kOm(lJW0bac1XVPqQnWVsaUxGwx9KXpKrsqg)LrCVwJHFJcZggbEE2HHI2nCycKHEWrhj7xA6qKXFzKO3AuGN0fWo(nApvg)Lr1bRukQd1HfSMqdMyGHUsH0vobyiY4VmsQms0BnkQd1HfSMqdMyGHUsH0EQm(lJO(aqfZqLXVjlJ8cVnCUvpwz4aEsxq0Xq1OgE4)ZmHB4w5eGHyc1WzXNo85goeMsBahDcyaZMLIhQFfug)LX8KX8Kry6aaH643ui1g4xja3lqRREY4hYijiJ)YiUxRXWVrHzdJapp7Wqr7gombYqp4OJK9lnDiY4VmQoyLsrDOoSG1eAWedm0vkKUYjadrgZxgtKqgZtgvhSsPOouhwWAcnyIbg6kfsx5eGHiJ)YiQpauXmuz8BYYiVWBz8xgjvgj6Tgf1H6WcwtObtmWqxPqApvg)LX8KrsLrCVwJHFJoBaBqbRjE45Qa2lKHV6rhj7xA6qKXejKrIERrNnGnOG1ep8Cva7fYWx9O9uzmFz8xgjvgX9Ang(nkmBye45zhgkA3WHjqg6bhDKSFPPdrgZxgZ3W5w9yLHd4jDbrhdvJA4HFETjCd3kNametOgol(0Hp3WHWuAd4Otady2Su8q9RGY4Vmcthaiuh)McP2a)kb4EbAD1tgjlJKGm(lJ4ETgd)gfMnmc88SddfTB4Weid9GJos2V00HiJ)YirV1OapPlGD8B0EQm(lJQdwPuuhQdlynHgmXadDLcPRCcWqKXFzKuzKO3AuuhQdlynHgmXadDLcP9uz8xgr9bGkMHkJFtwg5fEB4CRESYWb8KUGOJHQrn8KjVnHB4w5eGHyc1WzXNo85goy6aaH643ui1g4xja3lqRREY43KLXmnCUvpwz4MJ1as29SZOgEYKFt4gUvobyiMqnCw8PdFUHJO3AuOYWOz3shMIhQFfug)qg)KmMbY4ZIiJzGms0Bnkuzy0SBPdtHQBZA4CRESYWzd8ReG7fO1vpJA4jZmnHB4w5eGHyc1W5w9yLHd4jDbrhdvdNfF6WNB4GtfeSQdP6nCMFMGesTY4Vms0BnkWt6cyh)gTNkJ)YiPYirV1OP4dLHrohi(YtoAp1WzdZcMqD8Bk0Wd)g1WtMFYeUHBLtagIjudNfF6WNB4GtfeSQdP6nCMFMGesTY4Vms0BnkWt6cyh)gTNkJ)YiPYirV1OP4dLHrohi(YtoAp1W5w9yLHd4jDbrhdvJA4jtsWeUHBLtagIjudNfF6WNB4i6Tgf4jDbSJFJ2tLXFzeMoaqOo(nfsTb(vcW9c06QNm(HmscY4VmMNmsQmMoLcvggvmWqxPoG6w9sozmFz8xgrykTbC0jGbmBwQE2Sx9mCUvpwz4aEsxq0Xq1OgEYKxmHB4w5eGHyc1WzXNo85go1bRu6adDL6abbWHkDLtagIm(lJW0bac1XVPqQnWVsaUxGwx9KXpKrErg)LX8KrsLX0PuOYWOIbg6k1bu3QxYjJ5B4CRESYWnWqxPoqqaCOAudpzMHMWnCRCcWqmHA4S4th(CdN6Gvk1H2viEzhDLtagIHZT6XkdhWt6cI5Og1WtMzmt4go3QhRmC2a)kb4EbAD1ZWTYjadXeQrn8K5Nzc3WTYjadXeQHBLtaMaLL8QNjudNfF6WNB4i6Tgf4jDbSJFJ2tLXFz0Yyae2xLap3Qgo3QhRmCapPli6yOA4qzjV6z4HFJA4jtETjCdhkl5vpdp8B4w5eGjqzjV6zc1W5w9yLHRbC0jGbmBwdNnmlyc1XVPqdp8B4S4th(CdhEn8GbobygUvobyiMqnQHNpXBt4gouwYREgE43WTYjatGYsE1ZeQHZT6XkdxdZGQagWSznCRCcWqmHAuJA4GtaV6bMqD8BQjCdp8Bc3W5w9yLHdQmmQyGHUsDGHBLtagIjuJA4jtt4gUvobyiMqnCw8PdFUHJO3Auyh)MG1ePSVgM2tnCUvpwz4a3lqRREccgqnQHNpzc3WTYjadXeQHZT6Xkdxk(qzyKZbIV8KZWzXNo85goll5kVuAnlMbyyez8xgjvgj6TgnfFOmmY5aXxEYr7PY4VmsQms0BnkmfCLo8qedm0vkK2tnC2WSGjuh)Mcn8WVrn8qcMWnCRCcWqmHA4S4th(CdhrV1OwhaeG7fO1vpkEO(vqz8BYYi)82W5w9yLHBHnbRj0GjGkdJAudp8IjCd3kNametOgol(0Hp3WPoyLsp7ADCy0vobyiY4Vms0Bn6zxRJdJ2tLXFzKO3A0ZUwhhgfpu)kOm(HmcNQx9GuO62ScIERnSmMbY4ZIiJzGms0Bn6zxRJdJcv3Mvg)LrIERr)6keXRdvkuDBwz8dzK)pZW5w9yLHRHzqvady2Sg1WtgAc3WTYjadXeQHZIpD4ZnCQdwP0bg6k1bccGdv6kNamedNB1JvgUbg6k1bccGdvJA4jJzc3WTYjadXeQHZIpD4ZnCQdwPuOYWOz3shMUYjadXW5w9yLHdQmmA2T0HnQHNpZeUHBLtagIjudNfF6WNB4uhSsPZgWU6jGbmBw6kNamez8xgTmgaH9vrbEsxq0XqLIhQFfug)GSm(SiY4Vmcthaiuh)McP2a)kb4EbAD1tg)qgZugtKqgr9bGkMHkJFtwgZqElJ)YimDaGqD8BkKAd8ReG7fO1vpz8BYYyMY4VmMNmsQmI71Am8B0zdydkynXdpxfWEHm8vp6iz)sthImMiHms0Bn6SbSbfSM4HNRcyVqg(QhTNkJ5lJjsiJW0bac1XVPqQnWVsaUxGwx9KXpKXmLXFzKO3A0VUcr86qLcv3Mvg)MSmY)NjJ)YyEYiPYiUxRXWVrNnGnOG1ep8Cva7fYWx9OJK9lnDiYyIeYirV1OZgWguWAIhEUkG9cz4RE0EQmMVm(lJO(aqfZqLXVjlJziVnCUvpwz4MnGD1tady2Sg1WdV2eUHBLtagIjudNfF6WNB4Ytgj6Tg9RRqeVouPq1TzLXpKr()mz8xgjvgj6TgLaWyiGouP9uzmFzmrczKO3AuGN0fWo(nAp1W5w9yLHd4jDbrhdvJA4HFEBc3WTYjadXeQHZIpD4ZnCQdwP0zdyx9eWaMnlDLtagIm(lJe9wJoBa7QNagWSzP9uz8xgHPdaeQJFtHuBGFLaCVaTU6jJFiJzA4CRESYWb8KUGOJHQrn8Wp)MWnCRCcWqmHA4S4th(CdN6GvkD2a2vpbmGzZsx5eGHiJ)YirV1OZgWU6jGbmBwApvg)Lry6aaH643ui1g4xja3lqRREY43KLXmnCUvpwz4MJ1as29SZOgE4ptt4gUvobyiMqnCw8PdFUHJO3AuOYWOz3shM2tnCUvpwz4a3lqRREccgqnQHh()KjCd3kNametOgol(0Hp3Wr0Bn6SbSbfSM4HNRcyVqg(QhTNA4CRESYWnhRbKS7zNrn8Wpjyc3WTYjadXeQHZIpD4ZnCW0bac1XVPqQnWVsaUxGwx9KXpKXmLXFze1haQygQm(nzzmd5Tm(lJ5jJe9wJ(1viIxhQuO62SY4hYyM8wgtKqgr9bGkMHkJFlJ8AElJ5lJjsiJ5jJ4ETgd)gD2a2Gcwt8WZvbSxidF1Jos2V00HiJ)YiPYirV1OZgWguWAIhEUkG9cz4RE0EQmMVHZT6Xkd3CSgiGbmBwJA4HFEXeUHBLtagIjudNfF6WNB4YtgHPdaeQJFtHuBGFLaCVaTU6jJFlJ8lJ5lJ)YyEYiPYictPnGJobmGzZsXRHhmWjatgZ3W5w9yLHBowdiz3ZoJA4H)m0eUHBLtagIjudNfF6WNB4CREjNy1qVbLXVLr(LXFzmDkfQmmQyGHUsDa1T6LCY4Vms0BnkbGXqaDOs7Pgo3QhRmC2a)kb4EbAD1ZOgE4pJzc3WTYjadXeQHZIpD4ZnCPtPqLHrfdm0vQdOUvVKtg)LrIERrjamgcOdvAp1W5w9yLHdCVaTU6jiya1OgE4)ZmHB4w5eGHyc1WzXNo85goIERrDODfIx2r7Pgo3QhRmCapPli6yOAudp8ZRnHB4w5eGHyc1WzXNo85golJbqyFvc8CRA4CRESYWb8KUGOJHQrn8KjVnHB4w5eGHyc1WzXNo85golJbqyFvc8CRkJ)YOnWXVbLXVLr1bRu6SbmbRj0GjgyORuiDLtagIHZT6XkdhWt6cIogQg1WtM8Bc3WTYjadXeQHZIpD4ZnCQdwP0ZUwhhgDLtagIm(lJe9wJE2164WO9udNB1JvgUgMbvbmGzZAudpzMPjCdNB1JvgoBGFLiWXjhunCRCcWqmHAudpz(jt4gUvobyiMqnCw8PdFUHdY6aIRqOjzaxpWeqgi5kLUYjadXW5w9yLHRbgmWI9MA4Ushg3tvdh)g1WtMKGjCd3kNametOgol(0Hp3WPoyLsHQRNvGCqBGJFJUYjadXW5w9yLHdQUEwbYbTbo(nJA4jtEXeUHBLtagIjudNfF6WNB4ivgvhSsPP4d1bIbg6k1bhuPRCcWqKXejKr1bRuAk(qDGyGHUsDWbv6kNamez8xgZtgjvgtNsHkdJkgyORuhqDREjNmMVHZT6Xkd3CSgigyORuhyudpzMHMWnCRCcWqmHA4S4th(CdNB1l5eRg6nOm(TmYVm(lJ5jJW0bac1XVPqQnWVsaUxGwx9KXVLr(LXejKry6aaH643uif4jDbXCuz8BzKFzmFdNB1JvgoBGFLaCVaTU6zudpzMXmHB4CRESYWbUxGwx9eemGA4w5eGHyc1OgEY8ZmHB4qzjV6z4HFd3kNambkl5vptOgo3QhRmCnGJobmGzZA4SHzbtOo(nfA4HFdNfF6WNB4WRHhmWjaZWTYjadXeQrn8KjV2eUHBLtagIjud3kNambkl5vptOgol(0Hp3WHYso0vkf5GQx2jJFlJzOHZT6Xkdxd4Otady2SgouwYREgE43OgE(eVnHB4qzjV6z4HFd3kNambkl5vptOgo3QhRmCnmdQcyaZM1WTYjadXeQrnQrnCExdyydh3H2bUESkJa7n1Og1ya]] )

end
