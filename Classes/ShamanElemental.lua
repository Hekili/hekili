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

    spec:RegisterPack( "Elemental", 20220227.1, [[dK00ocqiurpcisTjG6tOcLrjQYPev1QqvIxjQ0Seq3ciQ0Uq5xIkggQsDmuvTmHQEMqLMgQqUgQsABar8nHkyCar5CcvO1Hku18ac3dvAFaPoiQqLwOqXdfQiMiqKexuOIQncejPpcev0jbIQwjQkZuOI0nbIKYorv8tGiPAPOcv4PiAQcLUkQqf9vGOcJfisSxk(lHblYHPAXq6XuAYqCzLnlLpdy0c60Q8ArPzRQBJWUL8BKgUqooQGLd1ZbnDsxxQ2Ua9DGKXlur58cW8ff7NOn8BI1qI46m8epVJpEEhF8Xbg)XZrXhVHudiAgYi3M1bMHSCIziJZ)rSs93qg5b8uhXeRHes7y7mKHQgb54ZjhGtd7OmlLih4r0FxpAzXEtZbEe2CmKO97vq(YGAirCDgEIN3XhpVJp(4aJ)45O45hKziHrZA4jEqs8gYWdbzLb1qImO1qgN)JyL6Vmrg6eEj5dKQdf3DCaYu8XHaLP45D8Xl5tYxCsOxadYXl5dKRmbYxwkoIIDDYeCQEfaKbv3MvG2BTHLPgfltG82164acuMivkMi7w0WmjFGCLjoUiiYei1MokwM8crMIZdyYeTjtA4KjsLIjKjhWVIziJW029ZqcsdsltX5)iwP(ltKHoHxs(aPbPLjqQouC3XbitXhhcuMIN3XhVKpjFG0G0YuCsOxadYXl5dKgKwMa5ktG8LLIJOyxNmbNQxbazq1TzfO9wByzQrXYeiVDTooGaLjsLIjYUfnmtYhiniTmbYvM44IGitGuB6OyzYlezkopGjt0MmPHtMivkMqMCa)kMKpjFG0YuCEC2SDDiY0coCaYKEetM0WjtUvPyz6GYKh0V3r)XK85w9OfKfHNLsG6k35ynuSFeRu)d8AC5u9FLYIWhH)I9JyL6)bv2kh9hIKpqAzIJt4KjsLIjYUfnSmfHNLsG6Qm1RFqOmbPetMCeeOmbQ7Fzcg5GQKjiLwmjFUvpAbzr4zPeOUMl3CA)GHwS30aVgxiT)OxHWI6qT)tmCpspALjdK2F0RqybPVR3pbK(bxPs(CRE0cYIWZsjqDnxU5avkMi7w0WbEnUQ)RuguPyISBrdZw5O)qaNh2peXcUszoccKzP9sbrCZKb7hIybxPmhbbYUc08kVZxYNB1JwqweEwkbQR5YnN2HNy)iwP(l5ZT6rlilcplLa11C5MZ(rSs9xG(oud8ACv)xPS9JyL6Va9DOYw5O)qadJ2)c1XatHmBOFL4pGqTUcaeXvYhiTmfZSEhozkonymYuOdLjxMuShCVmPhXcuM0WjtoccTKPO3Tdkt8IgEqzALIdGxKjAjtXjGurMAuSmfxzcolTqGYKsLjpi9qKjeAh9hi340GXit0sMI6)ZK85w9OfKfHNLsG6AUCZ59GUaTJHAG)vtyr4g3aVgxov)xPS9JyL6Va9DOYw5O)qadJ2)c1XatHmBOFL4pGqTUcaeXntg0ERXGkftKDlAywpsYNB1JwqweEwkbQR5YnhBOFL4pGqTUciWRXLt1)vkB)iwP(lqFhQSvo6peWWO9VqDmWuiZg6xj(diuRRaan34cMt0ERXGkftKDlAywpsYNB1JwqweEwkbQR5YnNiQE0sYNKpqAzcKV0HX9ivMOnzY6qfYK85w9OfmxU5aQRqeWW5yjFUvpAbZLBoWOdFkO8p7Wqba2TlqcAWRa4YVKp3QhTG5YnNiQE0sYNB1JwWC5MthoXPJak5ZT6rlyUCZP9oXeWqQnBGxJBECQ(Vsz7hXk1Fb67qLTYr)HKpyo1ZM9kaWCgnLbvkMqSFeRu)zUvVGdCEWO9VqDmWuiZg6xj(diuRRaarCZKr9FLYiCOoSG2eA4e7hXkfYw5O)qYKb3R1OyGXGzdafpp7Wqr7goabYio4yJd9lkAi5l5lxzYT6rlyUCZjcFeumY5VauEWfOna7pH6yGPqU8h414YjAV1yr4JGIro)fGYdowpcCECgnLbvkMqSFeRu)zUvVGltgy0(xOogykKzd9Re)beQ1vaGiUGr7TgduxHia6qLbv3MfeXZ7mzG0(JEfc7NJiqdqS4mNi6hBLJ(djtgCVwJIbgdg9xPdpeX(rSsHSXH(ffnK8bNhmA)luhdmfYSH(vI)ac16kaqWRzYO(VszeouhwqBcnCI9JyLczRC0FizYG71AumWyWSbGINNDyOODdhGazehCSXH(ffnKmzG0(JEfc7NJiqdqS4mNi6hBLJ(djtgCVwJIbgdg9xPdpeX(rSsHSXH(ffnK8bZjAV1yWO)kD4Hi2pIvkK1JK85w9OfmxU50ENycyi1MnWRXLt9SzVcaCECgnLbvkMqSFeRu)zUvVGltgy0(xOogykKzd9Re)beQ1vaGiUGr7TgduxHia6qLbv3MfeXZ78bNhmA)luhdmfYSH(vI)ac16kaqe3mzu)xPmchQdlOnHgoX(rSsHSvo6pKmzW9Ankgymy2aqXZZomu0UHdqGmIdo24q)IIgs(s(CRE0cMl3CAhEI9JyL6VKp3QhTG5YnhIPJIL85w9OfmxU5G(ukIO1Xbe414YP6)kL5q7keVSJTYr)HKjdAV1yo0UcXl7y9OmzSu6JqbvXCODfIx2XWJWVccAEL3s(CRE0cMl3CqhgoC2Rac8AC5u9FLYCODfIx2Xw5O)qYKbT3AmhAxH4LDSEKKp3QhTG5YnN2Hh6tPibEnUCQ(Vszo0UcXl7yRC0FizYG2BnMdTRq8YowpktglL(iuqvmhAxH4LDm8i8RGGMx5TKp3QhTG5YnhVSdQy)fw))aVgxov)xPmhAxH4LDSvo6pKmzq7TgZH2viEzhRhLjJLsFekOkMdTRq8YogEe(vqqZR8wYNB1JwWC5MdQdiOnHIpBwyGxJlNQ)RuMdTRq8Yo2kh9hsMmCI2BnMdTRq8YowpsYNB1JwWC5MtWbJgwOuDes(CRE0cMl3CA(ek2lyRdpAf414APbx5LYQdiufnFG5e3R1OyGXGBiqbTjWorKxQaatbLgYgh6xu0qaNhNQ)RugHd1Hf0MqdNy)iwPq2kh9hsMmO9wJr4qDybTj0Wj2pIvkK1JYhmmA)luhdmfYSH(vI)ac16kaqexjFUvpAbZLBonFcf7fS1HhTc8ACT0GR8sz1beQIMpW4ETgfdmgCdbkOnb2jI8sfaykO0q24q)IIgc484u9FLYiCOoSG2eA4e7hXkfYw5O)qYKbT3AmchQdlOnHgoX(rSsHSEuMmWO9VqDmWuiZg6xj(diuRRaan34Mp48Su6JqbvXAhEI9JyL6pdpc)kiOJN3zYyP0hHcQIbvkMqSFeRu)z4r4xbbD88oFjFUvpAbZLBo4EjCRE0s8hudSCIX1PlqOIpRYL)aVgx3QxWjwnIBqqhp48Gr7FH6yGPqMn0Vs8hqOwxba64ZKbgT)fQJbMczVh0fOZjaD85l5ZT6rlyUCZb3lHB1JwI)GAGLtmUWRa(juhdmnqOIpRYL)aVgxov)xPmOsXeI9JyL6pBLJ(dbSB1l4eRgXnii4gVKp3QhTG5YnhCVeUvpAj(dQbwoX4cNaEfWpH6yGPbcv8zvU8h414Q(VszqLIje7hXk1F2kh9hcy3QxWjwnIBqqWnEjFs(CRE0cYC64cvkMqSFeRu)L85w9OfK50Ll3CwatqBcnCcOsXebEnUO9wJz9)f)beQ1vam8i8RGGMl)8wYNB1JwqMtxUCZzowd5q3ZUaVgx0ERXMnKEfGagsTzz9ijFUvpAbzoD5YnhBOFLi0XbhuL85w9OfK50Ll3CGkftKDlA4aVgx1)vkdQumr2TOHzRC0Fis(CRE0cYC6YLBoT3jMagsTzd0gG9NqDmWuix(d8ACXRHhm0r)boV8CREbNaHQS27etadP2SGiEWUvVGtSAe3GGGBCbBP0hHcQIfHpckg58xakp4y4r4xbbb)GeWwAWvEPSAwm9PyeWCgnLbvkMqSFeRu)zUvVGltg3QxWjqOkR9oXeWqQnli4hSB1l4eRgXniO5YrG5mAkdQumHy)iwP(ZCREbhy1)vkJWH6WcAtOHtSFeRuiBLJ(dj)mzYd3R1OyGXGzdafpp7Wqr7goabYio4yJd9lkAiG5mAkdQumHy)iwP(ZCREbx(zYKhUxRrXaJbJ(R0HhIy)iwPq24q)IIgc48CREbNaHQS27etadP2SGiUG5e3R1OyGXMnKoOG2ea45Qa2lKHVcGno0VOOHKjJB1l4eiuL1ENycyi1MfeCu(GZZsPpcfuflcFeumY5VauEWXWJWVccc(bjzYG2Bnwe(iOyKZFbO8GJ1JYp)8L85w9OfK50Ll3CAVtmbmKAZg414YPB1l4eiuL1ENycyi1MfmNrtzqLIje7hXk1FMB1l4aNN6)kLr4qDybTj0Wj2pIvkKTYr)HKjdUxRrXaJbZgakEE2HHI2nCacKrCWXgh6xu0qYptM8W9Ankgymy0FLo8qe7hXkfYgh6xu0qaZPE2SxbagT3ASi8rqXiN)cq5bhRhLVKp3QhTGmNUC5MZSH0RaeWqQnBGxJR6)kLnBi9kabmKAZYw5O)qat47HkMsaAUGeEdopCVwJIbgB2q6GcAtaGNRcyVqg(ka24q)IIgcy0ERXMnKoOG2ea45Qa2lKHVcG1JYKHtCVwJIbgB2q6GcAtaGNRcyVqg(ka24q)IIgs(s(CRE0cYC6YLBoo0UcXl7c8ACv)xPmhAxH4LDSvo6peW5Xz0uguPycX(rSs9N5w9cU8bNhNQ)Ru2zxRJdGTYr)HKjdNO9wJD2164ay9iWCAP0hHcQID2164ay9O8L85w9OfK50Ll3C(Jd9drq4aeUqP6ic8ACv)xPS)4q)qeeoaHluQoc2kh9hIKp3QhTGmNUC5MJn0Vs8hqOwxbe414cJ2)c1XatHmBOFL4pGqTUcaeCey0ERXiCOoSG2eA4e7hXkfY6rGj89qftjabVYBjFUvpAbzoD5YnN5ynuadP2SbEnU4ETgfdm2SH0bf0MaapxfWEHm8vaSXH(ffneWCI2Bn2SH0bf0MaapxfWEHm8vaSEKKp3QhTGmNUC5MZ7bDbAhd1aVgxeQYAVtmbmKAZYWJWVccggT)fQJbMcz2q)kXFaHADfai4iW5Xz0uguPycX(rSs9N5w9cU8bNhAV1yVh0fWogySEeyor7TgJWH6WcAtOHtSFeRuiRhbw9FLYiCOoSG2eA4e7hXkfYw5O)qYxYNB1JwqMtxUCZzowd5q3ZUaVgxy0(xOogykKzd9Re)beQ1vaGMB8G5e3R1OyGXMnKoOG2ea45Qa2lKHVcGno0VOOHaop1)vkJWH6WcAtOHtSFeRuiBLJ(dbmHVhQykbO5YR8gmNO9wJr4qDybTj0Wj2pIvkK1JYxYNB1JwqMtxUCZ59GUaTJHAG2aS)eQJbMc5YFGxJRLgCLxkRMftFkgbmUxRrXaJnBiDqbTjaWZvbSxidFfaBCOFrrdbmCQaLwDitVHJhKj4Oily0ERXEpOlGDmWy9iWCI2Bnwe(iOyKZFbO8GJ1JK85w9OfK50Ll3CEpOlq7yOgOna7pH6yGPqU8h414I2Bn27bDbSJbgRhbgT3ASi8rqXiN)cq5bhRhbop0ERXIWhbfJC(laLhCm8i8RGGiU8cGfjtg3QxWjqOkR9oXeWqQnlxy0(xOogykKzd9Re)beQ1vazY4w9cobcvzT3jMagsTz5gxWCI71AumWyZgshuqBca8Cva7fYWxbWgh6xu0qYKXT6fCceQYAVtmbmKAZYLJYxYNB1JwqMtxUCZ59GUaTJHAGxJlcvzT3jMagsTzz4r4xbbdJ2)c1XatHmBOFL4pGqTUcaeCeyCVwJIbgdMnau88SddfTB4aeiJ4GJno0VOOHagT3AS3d6cyhdmwpcS6)kLr4qDybTj0Wj2pIvkKTYr)HaMt0ERXiCOoSG2eA4e7hXkfY6rGj89qftjanxEL3s(CRE0cYC6YLBoVh0fODmud8ACrOkR9oXeWqQnldpc)ki48YdgT)fQJbMcz2q)kXFaHADfai4iW4ETgfdmgmBaO45zhgkA3WbiqgXbhBCOFrrdbS6)kLr4qDybTj0Wj2pIvkKTYr)HKFMm5P(VszeouhwqBcnCI9JyLczRC0FiGj89qftjanxEL3G5eT3AmchQdlOnHgoX(rSsHSEe484e3R1OyGXMnKoOG2ea45Qa2lKHVcGno0VOOHKjdAV1yZgshuqBca8Cva7fYWxbW6r5dMtCVwJIbgdMnau88SddfTB4aeiJ4GJno0VOOHKF(s(CRE0cYC6YLBoVh0fODmud8ACrOkR9oXeWqQnldpc)kiyy0(xOogykKzd9Re)beQ1vaC5iW4ETgfdmgmBaO45zhgkA3WbiqgXbhBCOFrrdbmAV1yVh0fWogySEey1)vkJWH6WcAtOHtSFeRuiBLJ(dbmNO9wJr4qDybTj0Wj2pIvkK1Jat47HkMsaAU8kVL85w9OfK50Ll3CMJ1qo09SlWRXfgT)fQJbMcz2q)kXFaHADfaO5gVKp3QhTGmNUC5MJn0Vs8hqOwxbe414I2BnguPyISBrdZWJWVccI4YlaweEbT3AmOsXez3IgMbv3MvYNB1JwqMtxUCZ59GUaTJHAG2aS)eQJbMc5YFGxJlCQaLwDitVHJhKj4Oily0ERXEpOlGDmWy9iWCI2Bnwe(iOyKZFbO8GJ1JK85w9OfK50Ll3CEpOlq7yOg414cNkqPvhY0B44bzcokYcgT3AS3d6cyhdmwpcmNO9wJfHpckg58xakp4y9ijFUvpAbzoD5YnN3d6c0ogQbEnUO9wJ9Eqxa7yGX6rGHr7FH6yGPqMn0Vs8hqOwxbacocCECgnLbvkMqSFeRu)zUvVGlFWiuL1ENycyi1MLPNn7vas(CRE0cYC6YLBo7hXk1Fb67qnWRXv9FLY2pIvQ)c03HkBLJ(dbmmA)luhdmfYSH(vI)ac16kaqWRGZJZOPmOsXeI9JyL6pZT6fC5l5ZT6rliZPlxU58EqxGoNiWRXv9FLYCODfIx2Xw5O)qK85w9OfK50Ll3CSH(vI)ac16kajFUvpAbzoD5YnN3d6c0ogQbsqdEfax(d8ACr7Tg79GUa2XaJ1JaBP0hHcQsGNBvjFUvpAbzoD5YnN27etadP2SbsqdEfax(d0gG9NqDmWuix(d8ACXRHhm0r)j5ZT6rliZPlxU50WuOkGHuB2ajObVcGl)s(K85w9OfKbNaEfWpH6yGPCHkfti2pIvQ)s(CRE0cYGtaVc4NqDmW0C5MZFaHADfGaL(AGxJlAV1yWogycAterb1WSEKKp3QhTGm4eWRa(juhdmnxU5eHpckg58xakp4c0gG9NqDmWuix(d8ACT0GR8sz1Sy6tXiG5eT3ASi8rqXiN)cq5bhRhbMt0ERXGr)v6WdrSFeRuiRhj5ZT6rlidob8kGFc1XatZLBolGjOnHgobuPyIaVgx0ERXS()I)ac16kagEe(vqqZLFEl5ZT6rlidob8kGFc1XatZLBonmfQcyi1MnWRXv9FLYo7ADCaSvo6peWO9wJD2164ay9iWO9wJD2164ay4r4xbbbCQEfaKbv3MvG2BTH5falcVG2Bn2zxRJdGbv3MfmAV1yG6kebqhQmO62SGGFqMKp3QhTGm4eWRa(juhdmnxU50ENycyi1MnqBa2Fc1XatHC5pWRXfVgEWqh9NKp3QhTGm4eWRa(juhdmnxU50WuOkGHuB2aVgx1)vk7SR1XbWw5O)qaJ2Bn2zxRJdG1JaJ2Bn2zxRJdGHhHFfee8Z4NxaSi8cAV1yNDTooaguDBwjFUvpAbzWjGxb8tOogyAUCZz)iwP(lqFhQbEnUQ)Ru2(rSs9xG(ouzRC0Fis(CRE0cYGtaVc4NqDmW0C5MduPyISBrdh414Q(VszqLIjYUfnmBLJ(drYNB1JwqgCc4va)eQJbMMl3CMnKEfGagsTzd8ACv)xPSzdPxbiGHuBw2kh9hcylL(iuqvS3d6c0ogQm8i8RGGGlGfbmmA)luhdmfYSH(vI)ac16kaqeFMme(EOIPeGMliH3GHr7FH6yGPqMn0Vs8hqOwxbaAUXdopoX9AnkgySzdPdkOnbaEUkG9cz4RayJd9lkAizYG2Bn2SH0bf0MaapxfWEHm8vaSEu(s(CRE0cYGtaVc4NqDmW0C5MZ7bDbAhd1aVg38q7TgduxHia6qLbv3Mfe8dYaZjAV1yOpLI8DOY6r5NjdAV1yVh0fWogySEKKp3QhTGm4eWRa(juhdmnxU58EqxG2XqnWRXv9FLYMnKEfGagsTzzRC0FiGr7TgB2q6vacyi1ML1JadJ2)c1XatHmBOFL4pGqTUcaeXl5ZT6rlidob8kGFc1XatZLBoZXAih6E2f414Q(VszZgsVcqadP2SSvo6peWO9wJnBi9kabmKAZY6rGHr7FH6yGPqMn0Vs8hqOwxbaAUXl5ZT6rlidob8kGFc1XatZLBo)beQ1vacu6RbEnUO9wJbvkMi7w0WSEKKp3QhTGm4eWRa(juhdmnxU5mhRHCO7zxGxJlAV1yZgshuqBca8Cva7fYWxbW6rs(CRE0cYGtaVc4NqDmW0C5MZCSgkGHuB2aVgxy0(xOogykKzd9Re)beQ1vaGiEWe(EOIPeGMliH3GZdT3AmqDfIaOdvguDBwqepVZKHW3dvmLa0XrENFMm5H71AumWyZgshuqBca8Cva7fYWxbWgh6xu0qaZjAV1yZgshuqBca8Cva7fYWxbW6r5NjdUxRrXaJbQRqGrZZomu8EqxGhSJbwzhBCOFrrdrYNB1JwqgCc4va)eQJbMMl3CMJ1qo09SlWRXnpy0(xOogykKzd9Re)beQ1vaGM)8bNhNiuL1ENycyi1MLHxdpyOJ(lFjFUvpAbzWjGxb8tOogyAUCZXg6xj(diuRRac8ACDREbNy1iUbbn)GJMYGkfti2pIvQ)m3QxWbgT3Am0Nsr(ouz9ijFUvpAbzWjGxb8tOogyAUCZ5pGqTUcqGsFnWRXnAkdQumHy)iwP(ZCREbhy0ERXqFkf57qL1JK85w9OfKbNaEfWpH6yGP5YnN3d6c0ogQbEnUO9wJ5q7keVSJ1JK85w9OfKbNaEfWpH6yGP5YnN3d6c0ogQbEnUwk9rOGQe45wvYNB1JwqgCc4va)eQJbMMl3CEpOlq7yOg414AP0hHcQsGNBvW2qhdmiOv)xPSzdPcAtOHtSFeRuiBLJ(drYNB1JwqgCc4va)eQJbMMl3CAykufWqQnBGxJR6)kLD2164ayRC0FiGr7Tg7SR1XbW6rs(CRE0cYGtaVc4NqDmW0C5MJn0Vse64GdQs(CRE0cYGtaVc4NqDmW0C5Mt7hm0I9Mg414cP9h9kewq6769taPFWvkyor7Tgli9D9(jG0p4kve2j8IEiSEuGxPdJ7rQ4iigY564YFGxPdJ7rQa4PO(ZL)aVshg3JuX14cP9h9kewq6769taPFWvQKp3QhTGm4eWRa(juhdmnxU5avxpRa5G2qhdSaVgx1)vkdQUEwbYbTHogySvo6pejFUvpAbzWjGxb8tOogyAUCZzowdf7hXk1)aVgxov)xPSi8r4Vy)iwP(FqLTYr)HKjJ6)kLfHpc)f7hXk1)dQSvo6peW5Xz0uguPycX(rSs9N5w9cU8L85w9OfKbNaEfWpH6yGP5YnhBOFL4pGqTUciWRX1T6fCIvJ4ge08dopy0(xOogykKzd9Re)beQ1vaGM)mzGr7FH6yGPq27bDb6CcqZF(s(CRE0cYGtaVc4NqDmW0C5MZFaHADfGaL(QKp3QhTGm4eWRa(juhdmnxU50ENycyi1MnqcAWRa4YFG2aS)eQJbMc5YFGxJlEn8GHo6pjFUvpAbzWjGxb8tOogyAUCZP9oXeWqQnBGe0GxbWL)aVgxcAWrSszihu9YoqdsK85w9OfKbNaEfWpH6yGP5YnNgMcvbmKAZgibn4vaC5xYNKp3QhTGm4va)eQJbMY9pGqTUcqGsFnWRXnp0ERXGkftKDlAygEe(vqqaNQxbazq1TzfO9wByEbWIWlO9wJbvkMi7w0WmO62S5l5ZT6rlidEfWpH6yGP5YnNgMcvbmKAZg414Q(VszNDTooa2kh9hcy0ERXo7ADCaSEey0ERXo7ADCam8i8RGGaovVcaYGQBZkq7T2W8cGfHxq7Tg7SR1XbWGQBZk5ZT6rlidEfWpH6yGP5YnN27etadP2SbAdW(tOogykKl)bEnU5XPE2SxbKjdcvzT3jMagsTzz4r4xbbbxalsMmQ)RuMdTRq8Yo2kh9hcyeQYAVtmbmKAZYWJWVccI8Su6JqbvXCODfIx2XWJWVcMlAV1yo0UcXl7yiDSRhTYhSLsFekOkMdTRq8YogEe(vqqWr5dop0ERXEpOlGDmWy9Omz4eT3Am0Nsr(ouz9O8L85w9OfKbVc4NqDmW0C5Mt7DIjGHuB2aTby)juhdmfYL)aVgx0ERXIWhbfJC(laLhCSEey8A4bdD0Fs(CRE0cYGxb8tOogyAUCZXH2viEzxGxJR6)kL5q7keVSJTYr)Haop9igO5cs4DMmO9wJH(ukY3HkRhLp48Su6JqbvXEpOlq7yOYWJWVccAENp484u9FLYo7ADCaSvo6pKmz4eT3ASZUwhhaRhbMtlL(iuqvSZUwhhaRhLVKp3QhTGm4va)eQJbMMl3CEpOlq7yOg414I2Bn27bDbSJbgRhbopCVwJIbgduxHaJMNDyO49GUapyhdSYo24q)IIgsMmCI2BngHd1Hf0MqdNy)iwPqwpcS6)kLr4qDybTj0Wj2pIvkKTYr)HKVKp3QhTGm4va)eQJbMMl3C2pIvQ)c03HAGxJR6)kLTFeRu)fOVdv2kh9hc48i89qftjarCG35l5ZT6rlidEfWpH6yGP5YnhOsXez3IgoWRXv9FLYGkftKDlAy2kh9hc48W(HiwWvkZrqGmlTxkiIBMmy)qel4kL5iiq2vGMx5D(GZJW3dvmLaeCehLVKp3QhTGm4va)eQJbMMl3CMnKEfGagsTzd8ACv)xPSzdPxbiGHuBw2kh9hcylL(iuqvS3d6c0ogQm8i8RGGGlGfrYNB1Jwqg8kGFc1XatZLBoVh0fODmud8ACv)xPSzdPxbiGHuBw2kh9hcy0ERXMnKEfGagsTzz9ijFUvpAbzWRa(juhdmnxU58hh6hIGWbiCHs1re414Q(Vsz)XH(HiiCacxOuDeSvo6pejFUvpAbzWRa(juhdmnxU5mhRHCO7zxGxJlAV1yZgshuqBca8Cva7fYWxbW6rGv)xPmchQdlOnHgoX(rSsHSvo6peWO9wJr4qDybTj0Wj2pIvkK1JK85w9OfKbVc4NqDmW0C5MZFaHADfGaL(AGxJlAV1yqLIjYUfnmRhbgT3AmchQdlOnHgoX(rSsHSEeycFpuXucqas4TKp3QhTGm4va)eQJbMMl3CMJ1qo09SlWRXfT3ASzdPdkOnbaEUkG9cz4Ray9iW5P(VszeouhwqBcnCI9JyLczRC0FiGZdT3AmchQdlOnHgoX(rSsHSEuMmwk9rOGQyVh0fODmuz4r4xbbnVbt47HkMsaAUXX4ZKbgT)fQJbMcz2q)kXFaHADfaiIhmAV1yqLIjYUfnmRhb2sPpcfuf79GUaTJHkdpc)kii4cyrYptgov)xPmchQdlOnHgoX(rSsHSvo6pKmzSu6JqbvX2pIvQ)c03Hkdpc)kii4cNQxbazq1TzfO9wByEbWIWlXNVKp3QhTGm4va)eQJbMMl3CMJ1qo09SlWRXfgT)fQJbMcz2q)kXFaHADfaO5hmNiuL1ENycyi1MLHxdpyOJ(dmN4ETgfdm2SH0bf0MaapxfWEHm8vaSXH(ffneW5XP6)kLr4qDybTj0Wj2pIvkKTYr)HKjdAV1yeouhwqBcnCI9JyLcz9OmzSu6JqbvXEpOlq7yOYWJWVccAEdMW3dvmLa0CJJXNVKp3QhTGm4va)eQJbMMl3CEpOlq7yOg414AP0hHcQsGNBvW5XjAV1yeouhwqBcnCI9JyLcz9iWO9wJD2164ay9O8L85w9OfKbVc4NqDmW0C5MZ7bDbAhd1aVgxlL(iuqvc8CRc2g6yGbbT6)kLnBivqBcnCI9JyLczRC0FiG5eT3ASZUwhhaRhj5ZT6rlidEfWpH6yGP5YnN3d6c0ogQbEnUQ)Ru2SHubTj0Wj2pIvkKTYr)HaMt0ERXiCOoSG2eA4e7hXkfY6rGj89qftjanxEL3G5eT3ASzdPdkOnbaEUkG9cz4Ray9ijFUvpAbzWRa(juhdmnxU5mhRHcyi1MnWRXnpCVwJIbgB2q6GcAtaGNRcyVqg(ka24q)IIgsMmWO9VqDmWuiZg6xj(diuRRaar85dop1)vkJWH6WcAtOHtSFeRuiBLJ(dbmNO9wJnBiDqbTjaWZvbSxidFfaRhbop0ERXiCOoSG2eA4e7hXkfY6rzYq47HkMsaAUXX4ZKbgT)fQJbMcz2q)kXFaHADfaiIhmAV1yqLIjYUfnmRhb2sPpcfuf79GUaTJHkdpc)kii4cyrYptgov)xPmchQdlOnHgoX(rSsHSvo6pKmzSu6JqbvX2pIvQ)c03Hkdpc)kii4cNQxbazq1TzfO9wByEbWIWlXNVKp3QhTGm4va)eQJbMMl3CAykufWqQnBGxJR6)kLD2164ayRC0FiGv)xPmchQdlOnHgoX(rSsHSvo6peWO9wJD2164ay9iWO9wJr4qDybTj0Wj2pIvkK1JK85w9OfKbVc4NqDmW0C5MZ7bDbAhd1aVgx0ERXCODfIx2X6rs(CRE0cYGxb8tOogyAUCZ59GUaTJHAGxJRLsFekOkbEUvbZP6)kLr4qDybTj0Wj2pIvkKTYr)Hi5ZT6rlidEfWpH6yGP5YnNZUwhhqGxJR6)kLD2164ayRC0FiG5mpcFpuXucqhxEfSLsFekOk27bDbAhdvgEe(vqqWL35l5ZT6rlidEfWpH6yGP5YnNgMcvbmKAZg414Q(VszNDTooa2kh9hcy0ERXo7ADCaSEe48q7Tg7SR1XbWWJWVcccalcVWr8cAV1yNDTooaguDB2mzq7TgdQumr2TOHz9Omz4u9FLYiCOoSG2eA4e7hXkfYw5O)qYxYNB1Jwqg8kGFc1XatZLBoVh0fODmuL85w9OfKbVc4NqDmW0C5Mt7DIjGHuB2aTby)juhdmfYL)aVgx8A4bdD0Fs(CRE0cYGxb8tOogyAUCZPHPqvadP2SbEnU4ETgfdm2(rSs9xmo0V)qXxNGno0VOOHaMt0ERX2pIvQ)IXH(9hk(6ecKH2BnwpcmNQ)Ru2(rSs9xG(ouzRC0FiG5u9FLYMnKEfGagsTzzRC0Fis(CRE0cYGxb8tOogyAUCZP9dgAXEtd8ACH0(JEfcli9D9(jG0p4kfmNO9wJfK(UE)eq6hCLkc7eErpewpkWR0HX9ivCeed5CDC5pWR0HX9iva8uu)5YFGxPdJ7rQ4ACH0(JEfcli9D9(jG0p4kvYNB1Jwqg8kGFc1XatZLBo2q)krOJdoOk5ZT6rlidEfWpH6yGP5YnNgMcvbmKAZg414Q(VszNDTooa2kh9hcy0ERXo7ADCaSEKKp3QhTGm4va)eQJbMMl3CGQRNvGCqBOJbwGxJR6)kLbvxpRa5G2qhdm2kh9hIKp3QhTGm4va)eQJbMMl3CMJ1qX(rSs9pWRXLt1)vklcFe(l2pIvQ)huzRC0FizYWz0uw7WtSFeRu)zUvVGtYNB1Jwqg8kGFc1XatZLBo2q)kXFaHADfqGxJlmA)luhdmfYSH(vI)ac16kaqZVKp3QhTGm4va)eQJbMMl3C(diuRRaeO0xL85w9OfKbVc4NqDmW0C5Mt7DIjGHuB2ajObVcGl)bAdW(tOogykKl)bEnU41Wdg6O)K85w9OfKbVc4NqDmW0C5Mt7DIjGHuB2ajObVcGl)bEnUe0GJyLYqoO6LDGgKi5ZT6rlidEfWpH6yGP5YnNgMcvbmKAZgibn4vaC5xYNB1Jwqg8kGFc1XatZLBonmfQcyi1MnWRXv9FLYo7ADCaSvo6peWO9wJD2164ay9iWO9wJD2164ay4r4xbbbCQEfaKbv3MvG2BTH5falcVG2Bn2zxRJdGbv3M1qgCy4rldpXZ74JN3XhFCWqckhxxbanKGCWXLJdEa55bKtoEzsMInCY0rerXQm1OyzIJbVc4NqDmWuoMmHhh6hEiYeKsmzY7kLW1Hit2qVagKj5lo9QjtXdY44LP4eAfCyDiYehds7p6vimqkCmzsPYehds7p6vimqkSvo6peoMmLh)Xz5ZK8j5dKdoUCCWdippGCYXltYuSHtMoIikwLPgfltCSi8Sucux5yYeECOF4HitqkXKjVRucxhImzd9cyqMKV40RMmfphVmfNqRGdRdrM4yqA)rVcHbsHJjtkvM4yqA)rVcHbsHTYr)HWXKP84polFMKV40RMmfphVmfNqRGdRdrM4yqA)rVcHbsHJjtkvM4yqA)rVcHbsHTYr)HWXKjxLP4CqQhNkt5XFCw(mjFs(a5GJlhh8aYZdiNC8YKmfB4KPJiIIvzQrXYehdob8kGFc1Xat5yYeECOF4HitqkXKjVRucxhImzd9cyqMKV40RMmfpVYXltXj0k4W6qKjogK2F0RqyGu4yYKsLjogK2F0RqyGuyRC0FiCmzkp(JZYNj5tYhiprefRdrM4vzYT6rlz6pOczs(mK)bvOjwdj8kGFc1XatnXA4HFtSgYvo6petmgsl(0Hp3qMNmH2BnguPyISBrdZWJWVcktGqMGt1RaGmO62Sc0ERnSmXlYeGfrM4fzcT3AmOsXez3IgMbv3MvMY3q6w9OLH8pGqTUcqGsF1OgEI3eRHCLJ(dXeJH0IpD4ZnKQ)Ru2zxRJdGTYr)HitGLj0ERXo7ADCaSEKmbwMq7Tg7SR1XbWWJWVcktGqMGt1RaGmO62Sc0ERnSmXlYeGfrM4fzcT3ASZUwhhadQUnRH0T6rldzdtHQagsTznQHN4AI1qUYr)HyIXq6w9OLHS9oXeWqQnRH0IpD4ZnK5jtCkt6zZEfGmLjJmHqvw7DIjGHuBwgEe(vqzceCLjalImLjJmP(Vszo0UcXl7yRC0FiYeyzcHQS27etadP2Sm8i8RGYeiKP8KjlL(iuqvmhAxH4LDm8i8RGYuUYeAV1yo0UcXl7yiDSRhTKP8LjWYKLsFekOkMdTRq8YogEe(vqzceYehjt5ltGLP8Kj0ERXEpOlGDmWy9izktgzItzcT3Am0Nsr(ouz9izkFdPna7pH6yGPqdp8BudpCKjwd5kh9hIjgdPB1JwgY27etadP2Sgsl(0Hp3qI2Bnwe(iOyKZFbO8GJ1JKjWYeEn8GHo6pdPna7pH6yGPqdp8Budp8Qjwd5kh9hIjgdPfF6WNBiv)xPmhAxH4LDSvo6pezcSmLNmPhXKjqZvMaj8wMYKrMq7Tgd9PuKVdvwpsMYxMalt5jtwk9rOGQyVh0fODmuz4r4xbLjqlt8wMYxMalt5jtCktQ)Ru2zxRJdGTYr)HitzYitCktO9wJD2164ay9izcSmXPmzP0hHcQID2164ay9izkFdPB1JwgshAxH4LDg1WdiXeRHCLJ(dXeJH0IpD4ZnKO9wJ9Eqxa7yGX6rYeyzkpzc3R1OyGXa1viWO5zhgkEpOlWd2XaRSJno0VOOHitzYitCktO9wJr4qDybTj0Wj2pIvkK1JKjWYK6)kLr4qDybTj0Wj2pIvkKTYr)Hit5BiDRE0Yq(EqxG2Xq1OgEIdMynKRC0FiMymKw8PdFUHu9FLY2pIvQ)c03HkBLJ(drMalt5jte(EOIPeYeiKP4aVLP8nKUvpAzi3pIvQ)c03HQrn8aYmXAix5O)qmXyiT4th(CdP6)kLbvkMi7w0WSvo6pezcSmLNmH9drSGRuMJGazwAVuzceYuCLPmzKjSFiIfCLYCeei7kzc0YeVYBzkFzcSmLNmr47HkMsitGqM4iosMY3q6w9OLHeQumr2TOHnQHN4Ojwd5kh9hIjgdPfF6WNBiv)xPSzdPxbiGHuBw2kh9hImbwMSu6JqbvXEpOlq7yOYWJWVcktGGRmbyrmKUvpAziNnKEfGagsTznQHh(5Tjwd5kh9hIjgdPfF6WNBiv)xPSzdPxbiGHuBw2kh9hImbwMq7TgB2q6vacyi1ML1JmKUvpAziFpOlq7yOAudp8ZVjwd5kh9hIjgdPfF6WNBiv)xPS)4q)qeeoaHluQoc2kh9hIH0T6rld5FCOFicchGWfkvhHrn8WF8MynKRC0FiMymKw8PdFUHeT3ASzdPdkOnbaEUkG9cz4Ray9izcSmP(VszeouhwqBcnCI9JyLczRC0FiYeyzcT3AmchQdlOnHgoX(rSsHSEKH0T6rld5CSgYHUNDg1Wd)X1eRHCLJ(dXeJH0IpD4ZnKO9wJbvkMi7w0WSEKmbwMq7TgJWH6WcAtOHtSFeRuiRhjtGLjcFpuXuczceYeiH3gs3QhTmK)beQ1vacu6Rg1Wd)CKjwd5kh9hIjgdPfF6WNBir7TgB2q6GcAtaGNRcyVqg(kawpsMalt5jtQ)RugHd1Hf0MqdNy)iwPq2kh9hImbwMYtMq7TgJWH6WcAtOHtSFeRuiRhjtzYitwk9rOGQyVh0fODmuz4r4xbLjqlt8wMalte(EOIPeYeO5ktXX4LPmzKjy0(xOogykKzd9Re)beQ1vaYeiKP4LjWYeAV1yqLIjYUfnmRhjtGLjlL(iuqvS3d6c0ogQm8i8RGYei4ktawezkFzktgzItzs9FLYiCOoSG2eA4e7hXkfYw5O)qKPmzKjlL(iuqvS9JyL6Va9DOYWJWVcktGGRmbNQxbazq1TzfO9wByzIxKjalImXlYu8Yu(gs3QhTmKZXAih6E2zudp8ZRMynKRC0FiMymKw8PdFUHegT)fQJbMcz2q)kXFaHADfGmbAzIFzcSmXPmHqvw7DIjGHuBwgEn8GHo6pzcSmXPmH71AumWyZgshuqBca8Cva7fYWxbWgh6xu0qKjWYuEYeNYK6)kLr4qDybTj0Wj2pIvkKTYr)HitzYitO9wJr4qDybTj0Wj2pIvkK1JKPmzKjlL(iuqvS3d6c0ogQm8i8RGYeOLjEltGLjcFpuXuczc0CLP4y8Yu(gs3QhTmKZXAih6E2zudp8dsmXAix5O)qmXyiT4th(CdPLsFekOkbEUvLjWYuEYeNYeAV1yeouhwqBcnCI9JyLcz9izcSmH2Bn2zxRJdG1JKP8nKUvpAziFpOlq7yOAudp8hhmXAix5O)qmXyiT4th(CdPLsFekOkbEUvLjWYKn0XadktGwMu)xPSzdPcAtOHtSFeRuiBLJ(drMaltCktO9wJD2164ay9idPB1JwgY3d6c0ogQg1Wd)GmtSgYvo6petmgsl(0Hp3qQ(VszZgsf0MqdNy)iwPq2kh9hImbwM4uMq7TgJWH6WcAtOHtSFeRuiRhjtGLjcFpuXuczc0CLjEL3YeyzItzcT3ASzdPdkOnbaEUkG9cz4Ray9idPB1JwgY3d6c0ogQg1Wd)XrtSgYvo6petmgsl(0Hp3qMNmH71AumWyZgshuqBca8Cva7fYWxbWgh6xu0qKPmzKjy0(xOogykKzd9Re)beQ1vaYeiKP4LP8LjWYuEYK6)kLr4qDybTj0Wj2pIvkKTYr)HitGLjoLj0ERXMnKoOG2ea45Qa2lKHVcG1JKjWYuEYeAV1yeouhwqBcnCI9JyLcz9izktgzIW3dvmLqManxzkogVmLjJmbJ2)c1XatHmBOFL4pGqTUcqMaHmfVmbwMq7TgdQumr2TOHz9izcSmzP0hHcQI9EqxG2XqLHhHFfuMabxzcWIit5ltzYitCktQ)RugHd1Hf0MqdNy)iwPq2kh9hImLjJmzP0hHcQITFeRu)fOVdvgEe(vqzceCLj4u9kaidQUnRaT3Adlt8ImbyrKjErMIxMY3q6w9OLHCowdfWqQnRrn8epVnXAix5O)qmXyiT4th(CdP6)kLD2164ayRC0FiYeyzs9FLYiCOoSG2eA4e7hXkfYw5O)qKjWYeAV1yNDTooawpsMaltO9wJr4qDybTj0Wj2pIvkK1JmKUvpAziBykufWqQnRrn8ep)MynKRC0FiMymKw8PdFUHeT3AmhAxH4LDSEKH0T6rld57bDbAhdvJA4j(4nXAix5O)qmXyiT4th(CdPLsFekOkbEUvLjWYeNYK6)kLr4qDybTj0Wj2pIvkKTYr)HyiDRE0Yq(EqxG2Xq1OgEIpUMynKRC0FiMymKw8PdFUHu9FLYo7ADCaSvo6pezcSmXPmLNmr47HkMsitGwMIlVktGLjlL(iuqvS3d6c0ogQm8i8RGYei4kt8wMY3q6w9OLH8SR1XbyudpXZrMynKRC0FiMymKw8PdFUHu9FLYo7ADCaSvo6pezcSmH2Bn2zxRJdG1JKjWYuEYeAV1yNDTooagEe(vqzceYeGfrM4fzIJKjErMq7Tg7SR1XbWGQBZktzYitO9wJbvkMi7w0WSEKmLjJmXPmP(VszeouhwqBcnCI9JyLczRC0FiYu(gs3QhTmKnmfQcyi1M1OgEINxnXAiDRE0Yq(EqxG2Xq1qUYr)HyIXOgEIhKyI1qUYr)HyIXq6w9OLHS9oXeWqQnRH0IpD4ZnK41Wdg6O)mK2aS)eQJbMcn8WVrn8eFCWeRHCLJ(dXeJH0IpD4ZnK4ETgfdm2(rSs9xmo0V)qXxNGno0VOOHitGLjoLj0ERX2pIvQ)IXH(9hk(6ecKH2BnwpsMaltCktQ)Ru2(rSs9xG(ouzRC0FiYeyzItzs9FLYMnKEfGagsTzzRC0Figs3QhTmKnmfQcyi1M1OgEIhKzI1qUYr)HyIXqAXNo85gsiT)OxHWcsFxVFci9dUszRC0FiYeyzItzcT3ASG0317Nas)GRuryNWl6HW6rgYR0HX9ivCndjK2F0RqybPVR3pbK(bxPgYR0HX9ivCeed5CDgs(nKUvpAziB)GHwS3ud5v6W4EKkaEkQ)gs(nQHN4JJMynKUvpAziTH(vIqhhCq1qUYr)HyIXOgEIlVnXAix5O)qmXyiT4th(CdP6)kLD2164ayRC0FiYeyzcT3ASZUwhhaRhziDRE0Yq2WuOkGHuBwJA4jU8BI1qUYr)HyIXqAXNo85gs1)vkdQUEwbYbTHogySvo6pedPB1JwgsO66zfih0g6yGzudpXnEtSgYvo6petmgsl(0Hp3qYPmP(Vszr4JWFX(rSs9)GkBLJ(drMYKrM4uMIMYAhEI9JyL6pZT6fCgs3QhTmKZXAOy)iwP(BudpXnUMynKRC0FiMymKw8PdFUHegT)fQJbMcz2q)kXFaHADfGmbAzIFdPB1JwgsBOFL4pGqTUcWOgEIlhzI1q6w9OLH8pGqTUcqGsF1qUYr)HyIXOgEIlVAI1qsqdEfGHh(nKRC0FccAWRamXyiDRE0Yq2ENycyi1M1qAdW(tOogyk0Wd)gsl(0Hp3qIxdpyOJ(ZqUYr)HyIXOgEIliXeRHCLJ(dXeJHCLJ(tqqdEfGjgdPfF6WNBijObhXkLHCq1l7KjqltGedPB1JwgY27etadP2SgscAWRam8WVrn8e34Gjwdjbn4vagE43qUYr)jiObVcWeJH0T6rldzdtHQagsTznKRC0FiMymQHN4cYmXAix5O)qmXyiT4th(CdP6)kLD2164ayRC0FiYeyzcT3ASZUwhhaRhjtGLj0ERXo7ADCam8i8RGYeiKj4u9kaidQUnRaT3Adlt8ImbyrKjErMq7Tg7SR1XbWGQBZAiDRE0Yq2WuOkGHuBwJAudjYAE)vtSgE43eRHCLJ(dXeJHezql(I0Jwgsq(shg3JuzI2KjRdviZq6w9OLHeuxHiGHZXg1Wt8MynKe0Gxby4HFd5kh9NGGg8katmgs3QhTmKWOdFkO8p7Wqba2TZqUYr)HyIXOgEIRjwdPB1JwgYiQE0YqUYr)HyIXOgE4itSgs3QhTmKD4eNocOHCLJ(dXeJrn8WRMynKRC0FiMymKw8PdFUHmpzItzs9FLY2pIvQ)c03HkBLJ(drMYxMaltCkt6zZEfGmbwM4uMIMYGkfti2pIvQ)m3QxWjtGLP8Kjy0(xOogykKzd9Re)beQ1vaYeiKP4ktzYitQ)RugHd1Hf0MqdNy)iwPq2kh9hImLjJmH71AumWyWSbGINNDyOODdhGazehCSXH(ffnezkFdPB1JwgY27etadP2Sg1WdiXeRHCLJ(dXeJH0IpD4ZnKCkt6zZEfGmbwMYtM4uMIMYGkfti2pIvQ)m3QxWjtzYitWO9VqDmWuiZg6xj(diuRRaKjqitXvMaltO9wJbQRqeaDOYGQBZktGqMIN3Yu(YeyzkpzcgT)fQJbMcz2q)kXFaHADfGmbczkUYuMmYK6)kLr4qDybTj0Wj2pIvkKTYr)HitzYit4ETgfdmgmBaO45zhgkA3WbiqgXbhBCOFrrdrMY3q6w9OLHS9oXeWqQnRrn8ehmXAiDRE0Yq2o8e7hXk1Fd5kh9hIjgJA4bKzI1q6w9OLHKy6Oyd5kh9hIjgJA4joAI1qUYr)HyIXqAXNo85gsoLj1)vkZH2viEzhBLJ(drMYKrMq7TgZH2viEzhRhjtzYitwk9rOGQyo0UcXl7y4r4xbLjqlt8kVnKUvpAzirFkfr064amQHh(5Tjwd5kh9hIjgdPfF6WNBi5uMu)xPmhAxH4LDSvo6pezktgzcT3AmhAxH4LDSEKH0T6rldj6WWHZEfGrn8Wp)MynKRC0FiMymKw8PdFUHKtzs9FLYCODfIx2Xw5O)qKPmzKj0ERXCODfIx2X6rYuMmYKLsFekOkMdTRq8YogEe(vqzc0YeVYBdPB1JwgY2Hh6tPig1Wd)XBI1qUYr)HyIXqAXNo85gsoLj1)vkZH2viEzhBLJ(drMYKrMq7TgZH2viEzhRhjtzYitwk9rOGQyo0UcXl7y4r4xbLjqlt8kVnKUvpAzi9YoOI9xy9)nQHh(JRjwd5kh9hIjgdPfF6WNBi5uMu)xPmhAxH4LDSvo6pezktgzItzcT3AmhAxH4LDSEKH0T6rldjQdiOnHIpBwOrn8WphzI1q6w9OLHm4GrdluQocd5kh9hIjgJA4HFE1eRHCLJ(dXeJH0IpD4ZnKwAWvEPS6acvrZNmbwM4uMW9Ankgym4gcuqBcSte5LkaWuqPHSXH(ffnezcSmLNmXPmP(VszeouhwqBcnCI9JyLczRC0FiYuMmYeAV1yeouhwqBcnCI9JyLcz9izkFzcSmbJ2)c1XatHmBOFL4pGqTUcqMaHmfxdPB1JwgYMpHI9c26WJwg1Wd)GetSgYvo6petmgsl(0Hp3qAPbx5LYQdiufnFYeyzc3R1OyGXGBiqbTjWorKxQaatbLgYgh6xu0qKjWYuEYeNYK6)kLr4qDybTj0Wj2pIvkKTYr)HitzYitO9wJr4qDybTj0Wj2pIvkK1JKPmzKjy0(xOogykKzd9Re)beQ1vaYeO5ktXvMYxMalt5jtwk9rOGQyTdpX(rSs9NHhHFfuMaTmfpVLPmzKjlL(iuqvmOsXeI9JyL6pdpc)kOmbAzkEElt5BiDRE0Yq28juSxWwhE0YOgE4poyI1qUYr)HyIXqAXNo85gs3QxWjwnIBqzc0Yu8YeyzkpzcgT)fQJbMcz2q)kXFaHADfGmbAzkEzktgzcgT)fQJbMczVh0fOZjKjqltXlt5BiHk(SQHh(nKUvpAziX9s4w9OL4pOAi)dQIYjMH0PZOgE4hKzI1qUYr)HyIXqAXNo85gsoLj1)vkdQumHy)iwP(Zw5O)qKjWYKB1l4eRgXnOmbcUYu8gsOIpRA4HFdPB1JwgsCVeUvpAj(dQgY)GQOCIziHxb8tOogyQrn8WFC0eRHCLJ(dXeJH0IpD4ZnKQ)RuguPycX(rSs9NTYr)HitGLj3QxWjwnIBqzceCLP4nKqfFw1Wd)gs3QhTmK4EjCRE0s8hunK)bvr5eZqcNaEfWpH6yGPg1OgYi8SucuxnXA4HFtSgYvo6petmgs3QhTmKZXAOy)iwP(Birg0IVi9OLHmopoB2UoezAbhoazspIjtA4Kj3QuSmDqzYd637O)ygsl(0Hp3qYPmP(Vszr4JWFX(rSs9)GkBLJ(dXOgEI3eRHCLJ(dXeJH0T6rldz7hm0I9MAirg0IVi9OLHKJt4KjsLIjYUfnSmfHNLsG6Qm1RFqOmbPetMCeeOmbQ7Fzcg5GQKjiLwmdPfF6WNBiH0(JEfclQd1(pXW9i9OfBLJ(drMYKrMG0(JEfcli9D9(jG0p4kLTYr)HyudpX1eRHCLJ(dXeJH0IpD4ZnKQ)RuguPyISBrdZw5O)qKjWYuEYe2peXcUszoccKzP9sLjqitXvMYKrMW(HiwWvkZrqGSRKjqlt8kVLP8nKUvpAziHkftKDlAyJA4HJmXAiDRE0Yq2o8e7hXk1Fd5kh9hIjgJA4HxnXAix5O)qmXyiT4th(CdP6)kLTFeRu)fOVdv2kh9hImbwMGr7FH6yGPqMn0Vs8hqOwxbitGqMIRH0T6rld5(rSs9xG(ounQHhqIjwd5kh9hIjgdPB1JwgY3d6c0ogQgY)QjSigY4AiT4th(CdjNYK6)kLTFeRu)fOVdv2kh9hImbwMGr7FH6yGPqMn0Vs8hqOwxbitGqMIRmLjJmH2BnguPyISBrdZ6rgsKbT4lspAziJzwVdNmfNgmgzk0HYKltk2dUxM0JybktA4KjhbHwYu072bLjErdpOmTsXbWlYeTKP4eqQitnkwMIRmbNLwiqzsPYKhKEiYecTJ(dKBCAWyKjAjtr9)zg1WtCWeRHCLJ(dXeJH0IpD4ZnKCktQ)Ru2(rSs9xG(ouzRC0FiYeyzcgT)fQJbMcz2q)kXFaHADfGmbAUYuCLjWYeNYeAV1yqLIjYUfnmRhziDRE0YqAd9Re)beQ1vag1WdiZeRH0T6rldzevpAzix5O)qmXyuJAiD6mXA4HFtSgs3QhTmKqLIje7hXk1Fd5kh9hIjgJA4jEtSgYvo6petmgsl(0Hp3qI2BnM1)x8hqOwxbWWJWVcktGMRmXpVnKUvpAzixatqBcnCcOsXeg1WtCnXAix5O)qmXyiT4th(CdjAV1yZgsVcqadP2SSEKH0T6rld5CSgYHUNDg1WdhzI1q6w9OLH0g6xjcDCWbvd5kh9hIjgJA4HxnXAix5O)qmXyiT4th(CdP6)kLbvkMi7w0WSvo6pedPB1JwgsOsXez3Ig2OgEajMynKRC0FiMymKUvpAziBVtmbmKAZAiT4th(CdjEn8GHo6pzcSmLNmLNm5w9cobcvzT3jMagsTzLjqitXltGLj3QxWjwnIBqzceCLP4ktGLjlL(iuqvSi8rqXiN)cq5bhdpc)kOmbczIFqImbwMS0GR8sz1Sy6tXiYeyzItzkAkdQumHy)iwP(ZCREbNmLjJm5w9cobcvzT3jMagsTzLjqit8ltGLj3QxWjwnIBqzc0CLjosMaltCktrtzqLIje7hXk1FMB1l4KjWYK6)kLr4qDybTj0Wj2pIvkKTYr)Hit5ltzYit5jt4ETgfdmgmBaO45zhgkA3WbiqgXbhBCOFrrdrMaltCktrtzqLIje7hXk1FMB1l4KP8LPmzKP8KjCVwJIbgdg9xPdpeX(rSsHSXH(ffnezcSmLNm5w9cobcvzT3jMagsTzLjqitXvMaltCkt4ETgfdm2SH0bf0MaapxfWEHm8vaSXH(ffnezktgzYT6fCceQYAVtmbmKAZktGqM4izkFzcSmLNmzP0hHcQIfHpckg58xakp4y4r4xbLjqit8dsKPmzKj0ERXIWhbfJC(laLhCSEKmLVmLVmLVH0gG9NqDmWuOHh(nQHN4Gjwd5kh9hIjgdPfF6WNBi5uMCREbNaHQS27etadP2SYeyzItzkAkdQumHy)iwP(ZCREbNmbwMYtMu)xPmchQdlOnHgoX(rSsHSvo6pezktgzc3R1OyGXGzdafpp7Wqr7goabYio4yJd9lkAiYu(YuMmYuEYeUxRrXaJbJ(R0HhIy)iwPq24q)IIgImbwM4uM0ZM9kazcSmH2Bnwe(iOyKZFbO8GJ1JKP8nKUvpAziBVtmbmKAZAudpGmtSgYvo6petmgsl(0Hp3qQ(VszZgsVcqadP2SSvo6pezcSmr47HkMsitGMRmbs4TmbwMYtMW9AnkgySzdPdkOnbaEUkG9cz4RayJd9lkAiYeyzcT3ASzdPdkOnbaEUkG9cz4Ray9izktgzItzc3R1OyGXMnKoOG2ea45Qa2lKHVcGno0VOOHit5BiDRE0YqoBi9kabmKAZAudpXrtSgYvo6petmgsl(0Hp3qQ(Vszo0UcXl7yRC0FiYeyzkpzItzkAkdQumHy)iwP(ZCREbNmLVmbwMYtM4uMu)xPSZUwhhaBLJ(drMYKrM4uMq7Tg7SR1XbW6rYeyzItzYsPpcfuf7SR1XbW6rYu(gs3QhTmKo0UcXl7mQHh(5Tjwd5kh9hIjgdPfF6WNBiv)xPS)4q)qeeoaHluQoc2kh9hIH0T6rld5FCOFicchGWfkvhHrn8Wp)MynKRC0FiMymKw8PdFUHegT)fQJbMcz2q)kXFaHADfGmbczIJKjWYeAV1yeouhwqBcnCI9JyLcz9izcSmr47HkMsitGqM4vEBiDRE0YqAd9Re)beQ1vag1Wd)XBI1qUYr)HyIXqAXNo85gsCVwJIbgB2q6GcAtaGNRcyVqg(ka24q)IIgImbwM4uMq7TgB2q6GcAtaGNRcyVqg(kawpYq6w9OLHCowdfWqQnRrn8WFCnXAix5O)qmXyiT4th(CdjcvzT3jMagsTzz4r4xbLjWYemA)luhdmfYSH(vI)ac16kazceYehjtGLP8KjoLPOPmOsXeI9JyL6pZT6fCYu(YeyzkpzcT3AS3d6cyhdmwpsMaltCktO9wJr4qDybTj0Wj2pIvkK1JKjWYK6)kLr4qDybTj0Wj2pIvkKTYr)Hit5BiDRE0Yq(EqxG2Xq1OgE4NJmXAix5O)qmXyiT4th(CdjmA)luhdmfYSH(vI)ac16kazc0CLP4LjWYeNYeUxRrXaJnBiDqbTjaWZvbSxidFfaBCOFrrdrMalt5jtQ)RugHd1Hf0MqdNy)iwPq2kh9hImbwMi89qftjKjqZvM4vEltGLjoLj0ERXiCOoSG2eA4e7hXkfY6rYu(gs3QhTmKZXAih6E2zudp8ZRMynKRC0FiMymKUvpAziFpOlq7yOAiT4th(CdPLgCLxkRMftFkgrMalt4ETgfdm2SH0bf0MaapxfWEHm8vaSXH(ffnezcSmbNkqPvhY0B44bzcokYktGLj0ERXEpOlGDmWy9izcSmXPmH2Bnwe(iOyKZFbO8GJ1JmK2aS)eQJbMcn8WVrn8WpiXeRHCLJ(dXeJH0T6rld57bDbAhdvdPfF6WNBir7Tg79GUa2XaJ1JKjWYeAV1yr4JGIro)fGYdowpsMalt5jtO9wJfHpckg58xakp4y4r4xbLjqitXvM4fzcWIitzYitUvVGtGqvw7DIjGHuBwzIRmbJ2)c1XatHmBOFL4pGqTUcqMYKrMCREbNaHQS27etadP2SYexzkUYeyzItzc3R1OyGXMnKoOG2ea45Qa2lKHVcGno0VOOHitzYitUvVGtGqvw7DIjGHuBwzIRmXrYu(gsBa2Fc1XatHgE43OgE4poyI1qUYr)HyIXqAXNo85gseQYAVtmbmKAZYWJWVcktGLjy0(xOogykKzd9Re)beQ1vaYeiKjosMalt4ETgfdmgmBaO45zhgkA3WbiqgXbhBCOFrrdrMaltO9wJ9Eqxa7yGX6rYeyzs9FLYiCOoSG2eA4e7hXkfYw5O)qKjWYeNYeAV1yeouhwqBcnCI9JyLcz9izcSmr47HkMsitGMRmXR82q6w9OLH89GUaTJHQrn8WpiZeRHCLJ(dXeJH0IpD4ZnKiuL1ENycyi1MLHhHFfuMalt5jt5jtWO9VqDmWuiZg6xj(diuRRaKjqitCKmbwMW9Ankgymy2aqXZZomu0UHdqGmIdo24q)IIgImbwMu)xPmchQdlOnHgoX(rSsHSvo6pezkFzktgzkpzs9FLYiCOoSG2eA4e7hXkfYw5O)qKjWYeHVhQykHmbAUYeVYBzcSmXPmH2BngHd1Hf0MqdNy)iwPqwpsMalt5jtCkt4ETgfdm2SH0bf0MaapxfWEHm8vaSXH(ffnezktgzcT3ASzdPdkOnbaEUkG9cz4Ray9izkFzcSmXPmH71AumWyWSbGINNDyOODdhGazehCSXH(ffnezkFzkFdPB1JwgY3d6c0ogQg1Wd)XrtSgYvo6petmgsl(0Hp3qIqvw7DIjGHuBwgEe(vqzcSmbJ2)c1XatHmBOFL4pGqTUcqM4ktCKmbwMW9Ankgymy2aqXZZomu0UHdqGmIdo24q)IIgImbwMq7Tg79GUa2XaJ1JKjWYK6)kLr4qDybTj0Wj2pIvkKTYr)HitGLjoLj0ERXiCOoSG2eA4e7hXkfY6rYeyzIW3dvmLqManxzIx5TH0T6rld57bDbAhdvJA4jEEBI1qUYr)HyIXqAXNo85gsy0(xOogykKzd9Re)beQ1vaYeO5ktXBiDRE0YqohRHCO7zNrn8ep)MynKRC0FiMymKw8PdFUHeT3AmOsXez3IgMHhHFfuMaHmfxzIxKjalImXlYeAV1yqLIjYUfnmdQUnRH0T6rldPn0Vs8hqOwxbyudpXhVjwd5kh9hIjgdPB1JwgY3d6c0ogQgsl(0Hp3qcNkqPvhY0B44bzcokYktGLj0ERXEpOlGDmWy9izcSmXPmH2Bnwe(iOyKZFbO8GJ1JmK2aS)eQJbMcn8WVrn8eFCnXAix5O)qmXyiT4th(CdjCQaLwDitVHJhKj4OiRmbwMq7Tg79GUa2XaJ1JKjWYeNYeAV1yr4JGIro)fGYdowpYq6w9OLH89GUaTJHQrn8ephzI1qUYr)HyIXqAXNo85gs0ERXEpOlGDmWy9izcSmbJ2)c1XatHmBOFL4pGqTUcqMaHmXrYeyzkpzItzkAkdQumHy)iwP(ZCREbNmLVmbwMqOkR9oXeWqQnltpB2RamKUvpAziFpOlq7yOAudpXZRMynKRC0FiMymKw8PdFUHu9FLY2pIvQ)c03HkBLJ(drMaltWO9VqDmWuiZg6xj(diuRRaKjqit8QmbwMYtM4uMIMYGkfti2pIvQ)m3QxWjt5BiDRE0YqUFeRu)fOVdvJA4jEqIjwd5kh9hIjgdPfF6WNBiv)xPmhAxH4LDSvo6pedPB1JwgY3d6c05eg1Wt8XbtSgs3QhTmK2q)kXFaHADfGHCLJ(dXeJrn8epiZeRHCLJ(dXeJHCLJ(tqqdEfGjgdPfF6WNBir7Tg79GUa2XaJ1JKjWYKLsFekOkbEUvnKUvpAziFpOlq7yOAijObVcWWd)g1Wt8XrtSgscAWRam8WVHCLJ(tqqdEfGjgdPB1JwgY27etadP2SgsBa2Fc1XatHgE43qAXNo85gs8A4bdD0FgYvo6petmg1WtC5Tjwdjbn4vagE43qUYr)jiObVcWeJH0T6rldzdtHQagsTznKRC0FiMymQrnKWjGxb8tOogyQjwdp8BI1q6w9OLHeQumHy)iwP(Bix5O)qmXyudpXBI1qUYr)HyIXqAXNo85gs0ERXGDmWe0MiIcQHz9idPB1JwgY)ac16kabk9vJA4jUMynKRC0FiMymKUvpAziJWhbfJC(laLhCgsl(0Hp3qAPbx5LYQzX0NIrKjWYeNYeAV1yr4JGIro)fGYdowpsMaltCktO9wJbJ(R0HhIy)iwPqwpYqAdW(tOogyk0Wd)g1WdhzI1qUYr)HyIXqAXNo85gs0ERXS()I)ac16kagEe(vqzc0CLj(5TH0T6rld5cycAtOHtavkMWOgE4vtSgYvo6petmgsl(0Hp3qQ(VszNDTooa2kh9hImbwMq7Tg7SR1XbW6rYeyzcT3ASZUwhhadpc)kOmbczcovVcaYGQBZkq7T2WYeVitawezIxKj0ERXo7ADCamO62SYeyzcT3AmqDfIaOdvguDBwzceYe)GmdPB1JwgYgMcvbmKAZAudpGetSgYvo6petmgs3QhTmKT3jMagsTznKw8PdFUHeVgEWqh9NH0gG9NqDmWuOHh(nQHN4Gjwd5kh9hIjgdPfF6WNBiv)xPSZUwhhaBLJ(drMaltO9wJD2164ay9izcSmH2Bn2zxRJdGHhHFfuMaHmXpJFzIxKjalImXlYeAV1yNDTooaguDBwdPB1JwgYgMcvbmKAZAudpGmtSgYvo6petmgsl(0Hp3qQ(Vsz7hXk1Fb67qLTYr)HyiDRE0YqUFeRu)fOVdvJA4joAI1qUYr)HyIXqAXNo85gs1)vkdQumr2TOHzRC0Figs3QhTmKqLIjYUfnSrn8WpVnXAix5O)qmXyiT4th(CdP6)kLnBi9kabmKAZYw5O)qKjWYKLsFekOk27bDbAhdvgEe(vqzceCLjalImbwMGr7FH6yGPqMn0Vs8hqOwxbitGqMIxMYKrMi89qftjKjqZvMaj8wMaltWO9VqDmWuiZg6xj(diuRRaKjqZvMIxMalt5jtCkt4ETgfdm2SH0bf0MaapxfWEHm8vaSXH(ffnezktgzcT3ASzdPdkOnbaEUkG9cz4Ray9izkFdPB1JwgYzdPxbiGHuBwJA4HF(nXAix5O)qmXyiT4th(CdzEYeAV1yG6kebqhQmO62SYeiKj(bzYeyzItzcT3Am0Nsr(ouz9izkFzktgzcT3AS3d6cyhdmwpYq6w9OLH89GUaTJHQrn8WF8MynKRC0FiMymKw8PdFUHu9FLYMnKEfGagsTzzRC0FiYeyzcT3ASzdPxbiGHuBwwpsMaltWO9VqDmWuiZg6xj(diuRRaKjqitXBiDRE0Yq(EqxG2Xq1OgE4pUMynKRC0FiMymKw8PdFUHu9FLYMnKEfGagsTzzRC0FiYeyzcT3ASzdPxbiGHuBwwpsMaltWO9VqDmWuiZg6xj(diuRRaKjqZvMI3q6w9OLHCowd5q3ZoJA4HFoYeRHCLJ(dXeJH0IpD4ZnKO9wJbvkMi7w0WSEKH0T6rld5FaHADfGaL(Qrn8WpVAI1qUYr)HyIXqAXNo85gs0ERXMnKoOG2ea45Qa2lKHVcG1JmKUvpAziNJ1qo09SZOgE4hKyI1qUYr)HyIXqAXNo85gsy0(xOogykKzd9Re)beQ1vaYeiKP4LjWYeHVhQykHmbAUYeiH3YeyzkpzcT3AmqDfIaOdvguDBwzceYu88wMYKrMi89qftjKjqltXrElt5ltzYit5jt4ETgfdm2SH0bf0MaapxfWEHm8vaSXH(ffnezcSmXPmH2Bn2SH0bf0MaapxfWEHm8vaSEKmLVmLjJmH71AumWyG6key08SddfVh0f4b7yGv2Xgh6xu0qmKUvpAziNJ1qbmKAZAudp8hhmXAix5O)qmXyiT4th(CdzEYemA)luhdmfYSH(vI)ac16kazc0Ye)Yu(YeyzkpzItzcHQS27etadP2Sm8A4bdD0FYu(gs3QhTmKZXAih6E2zudp8dYmXAix5O)qmXyiT4th(CdPB1l4eRgXnOmbAzIFzcSmfnLbvkMqSFeRu)zUvVGtMaltO9wJH(ukY3HkRhziDRE0YqAd9Re)beQ1vag1Wd)XrtSgYvo6petmgsl(0Hp3qgnLbvkMqSFeRu)zUvVGtMaltO9wJH(ukY3HkRhziDRE0Yq(hqOwxbiqPVAudpXZBtSgYvo6petmgsl(0Hp3qI2BnMdTRq8YowpYq6w9OLH89GUaTJHQrn8ep)MynKRC0FiMymKw8PdFUH0sPpcfuLap3Qgs3QhTmKVh0fODmunQHN4J3eRHCLJ(dXeJH0IpD4ZnKwk9rOGQe45wvMalt2qhdmOmbAzs9FLYMnKkOnHgoX(rSsHSvo6pedPB1JwgY3d6c0ogQg1Wt8X1eRHCLJ(dXeJH0IpD4ZnKQ)Ru2zxRJdGTYr)HitGLj0ERXo7ADCaSEKH0T6rldzdtHQagsTznQHN45itSgs3QhTmK2q)krOJdoOAix5O)qmXyudpXZRMynKRC0FiMymKw8PdFUHes7p6viSG0317Nas)GRu2kh9hImbwM4uMq7Tgli9D9(jG0p4kve2j8IEiSEKH8kDyCpsfxZqcP9h9kewq6769taPFWvQH8kDyCpsfhbXqoxNHKFdPB1JwgY2pyOf7n1qELomUhPcGNI6VHKFJA4jEqIjwd5kh9hIjgdPfF6WNBiv)xPmO66zfih0g6yGXw5O)qmKUvpAziHQRNvGCqBOJbMrn8eFCWeRHCLJ(dXeJH0IpD4ZnKCktQ)Ruwe(i8xSFeRu)pOYw5O)qKPmzKj1)vklcFe(l2pIvQ)huzRC0FiYeyzkpzItzkAkdQumHy)iwP(ZCREbNmLVH0T6rld5CSgk2pIvQ)g1Wt8GmtSgYvo6petmgsl(0Hp3q6w9coXQrCdktGwM4xMalt5jtWO9VqDmWuiZg6xj(diuRRaKjqlt8ltzYitWO9VqDmWui79GUaDoHmbAzIFzkFdPB1JwgsBOFL4pGqTUcWOgEIpoAI1q6w9OLH8pGqTUcqGsF1qUYr)HyIXOgEIlVnXAijObVcWWd)gYvo6pbbn4vaMymKUvpAziBVtmbmKAZAiTby)juhdmfA4HFdPfF6WNBiXRHhm0r)zix5O)qmXyudpXLFtSgYvo6petmgYvo6pbbn4vaMymKw8PdFUHKGgCeRugYbvVStMaTmbsmKUvpAziBVtmbmKAZAijObVcWWd)g1WtCJ3eRHKGg8kadp8Bix5O)ee0GxbyIXq6w9OLHSHPqvadP2SgYvo6petmg1Og1q6DnKInKKhr)D9OvCc2BQrnQXa]] )

end
