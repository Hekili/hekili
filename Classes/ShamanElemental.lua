-- ShamanElemental.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'SHAMAN' then
    local spec = Hekili:NewSpecialization( 262, true )

    spec:RegisterResource( Enum.PowerType.Maelstrom, {
        resonance_totem = {
            aura = 'resonance_totem',

            last = function ()
                local app = state.buff.resonance_totem.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 1,
        },
    } )
    spec:RegisterResource( Enum.PowerType.Mana )
    
    -- Talents
    spec:RegisterTalents( {
        earthen_rage = 22356, -- 170374
        echo_of_the_elements = 22357, -- 108283
        elemental_blast = 22358, -- 117014

        aftershock = 23108, -- 273221
        call_the_thunder = 22139, -- 260897
        totem_mastery = 23190, -- 210643

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
        relentless = 3596, -- 196029
        adaptation = 3597, -- 214027
        gladiators_medallion = 3598, -- 208683
        
        spectral_recovery = 3062, -- 204261
        control_of_lava = 728, -- 204393
        earthfury = 729, -- 204398
        traveling_storms = 730, -- 204403
        lightning_lasso = 731, -- 204437
        elemental_attunement = 727, -- 204385
        skyfury_totem = 3488, -- 204330
        grounding_totem = 3620, -- 204336
        counterstrike_totem = 3490, -- 204331
        purifying_waters = 3491, -- 204247
        swelling_waves = 3621, -- 204264
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
            duration = 8,
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
        
        earthquake = {
            id = 61882,
            duration = 3600,
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
                eb.caster = count > 0 and 'player' or 'nobody'
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

        ember_totem = {
            id = 210658,
            duration = 0,
            max_stack = 1,
        },

        exposed_elements = {
            id = 269808,
            duration = 15,
            max_stack = 1,
        },

        far_sight = {
            id = 6196,
            duration = 60,
            max_stack = 1,
        },

        flame_shock = {
            id = 188389,
            duration = 24,
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
            id = 77756,
            duration = 10,
            max_stack = 1,
        },

        master_of_the_elements = {
            id = 260734,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
                
        resonance_totem = {
            id = 202192,
            duration = 120,
            max_stack = 1,
        },
        
        spirit_wolf = {
            id = 260881,
            duration = 3600,
            max_stack = 4,
        },

        static_charge = {
            id = 265046,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        
        storm_totem = {
            id = 210652,
            duration = 120,
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

        tailwind_totem = {
            id = 210659,
            duration = 120,
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
            max_stack = 10, -- this is a guess.
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

        totem_mastery = {
            duration = 120,
            generate = function ()
                local expires, remains = 0, 0

                for i = 1, 5 do
                    local _, name, cast, duration = GetTotemInfo(i)

                    if name == class.abilities.totem_mastery.name then
                        if cast + duration > expires then
                            expires = cast + duration
                            remains = expires - now
                        end
                    end
                end

                local up = buff.resonance_totem.up and remains > 0

                local tm = buff.totem_mastery
                tm.name = class.abilities.totem_mastery.name

                if expires > 0 and up then
                    tm.count = 4
                    tm.expires = expires
                    tm.applied = expires - 120
                    tm.caster = "player"

                    applyBuff( "resonance_totem", remains )
                    applyBuff( "tailwind_totem", remains )
                    applyBuff( "storm_totem", remains )
                    applyBuff( "ember_totem", remains )
                    return
                end

                tm.count = 0
                tm.expires = 0
                tm.applied = 0
                tm.caster = "nobody"
            end,
        },

        wind_gust = {
            id = 263806,
            duration = 30,
            max_stack = 20
        },


        -- Azerite Powers
        ancestral_resonance = {
            id = 277943,
            duration = 15,
            max_stack = 1,
        },

        tectonic_thunder = {
            id = 286976,
            duration = 15,
            max_stack = 1,
        },
    } )


    -- Pets
    spec:RegisterPet( "primal_storm_elemental", 77942, "storm_elemental", 30 )
    spec:RegisterTotem( "greater_storm_elemental", 1020304 ) -- Texture ID
    
    spec:RegisterPet( "primal_fire_elemental", 61029, "fire_elemental", 30 )
    spec:RegisterTotem( "greater_fire_elemental", 135790 ) -- Texture ID
    
    spec:RegisterPet( "primal_earth_elemental", 61056, "earth_elemental", 60 )
    spec:RegisterTotem( "greater_earth_elemental", 136024 ) -- Texture ID


    spec:RegisterStateTable( 'fire_elemental', setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.fire_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_fire_elemental or pet.greater_fire_elemental

            if k == 'active' or k == 'up' then
                return elem.up

            elseif k == 'remains' then
                return max( 0, elem.remains )

            end

            return false
        end 
    } ) )

    spec:RegisterStateTable( 'storm_elemental', setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.storm_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_storm_elemental or pet.greater_storm_elemental

            if k == 'active' or k == 'up' then
                return elem.up

            elseif k == 'remains' then
                return max( 0, elem.remains )

            end

            return false
        end 
    } ) )

    spec:RegisterStateTable( 'earth_elemental', setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.earth_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_earth_elemental or pet.greater_earth_elemental

            if k == 'active' or k == 'up' then
                return elem.up

            elseif k == 'remains' then
                return max( 0, elem.remains )

            end

            return false
        end 
    } ) )


    local hadTotem = false
    local hadTotemAura = false

    spec:RegisterHook( "reset_precast", function ()
        for i = 1, 5 do
            local hasTotem, name = GetTotemInfo( i )

            if name == class.abilities.totem_mastery.name and hasTotem ~= up then
                ScrapeUnitAuras( "player" )
                return
            end
        end

        local hasTotemAura = FindUnitBuffByID( "player", 210652 ) ~= nil
        if hasTotemAura ~= hadTotemAura then ScrapeUnitAuras( "player" ) end
    end )


    spec:RegisterGear( "the_deceivers_blood_pact", 137035 ) -- 20% chance; not modeled.
    spec:RegisterGear( "alakirs_acrimony", 137102 ) -- passive dmg increase.
    spec:RegisterGear( "echoes_of_the_great_sundering", 137074 )
        spec:RegisterAura( "echoes_of_the_great_sundering", {
            id = 208723, 
            duration =  10
        } )

    spec:RegisterGear( "pristine_protoscale_girdle", 137083 ) -- not modeled.
    spec:RegisterGear( "eye_of_the_twisting_nether", 137050 )
        spec:RegisterAura( "fire_of_the_twisting_nether", {
            id = 207995,
            duration = 8 
        } )
        spec:RegisterAura( "chill_of_the_twisting_nether", {
            id = 207998,
            duration = 8 
        } )
        spec:RegisterAura( "shock_of_the_twisting_nether", {
            id = 207999,
            duration = 8 
        } )

        spec:RegisterStateTable( "twisting_nether", setmetatable( {}, {
            __index = function( t, k )
                if k == 'count' then
                    return ( buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( buff.shock_of_the_twisting_nether.up and 1 or 0 )
                end

                return 0
            end
        } ) )
    
    spec:RegisterGear( "uncertain_reminder", 143732 )
    

    -- Abilities
    spec:RegisterAbilities( {
        ancestral_guidance = {
            id = 108281,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            talent = 'ancestral_guidance',

            startsCombat = false,
            texture = 538564,
            
            handler = function ()
                applyBuff( 'ancestral_guidance' )
            end,
        },
        

        ancestral_spirit = {
            id = 2008,
            cast = 10.000215022888,
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
            
            toggle = 'cooldowns',
            talent = 'ascendance',

            startsCombat = false,
            texture = 135791,
            
            handler = function ()
                applyBuff( 'ascendance' )
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
            
            startsCombat = false,
            texture = 538565,
            
            handler = function ()
                applyBuff( 'astral_shift' )
            end,
        },
        

        bloodlust = {
            id = 2825,
            cast = 0,
            cooldown = 300,
            gcd = "spell",
            
            spend = 0.22,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136012,
            
            handler = function ()
                applyBuff( 'bloodlust' )
                applyDebuff( 'player', 'sated' )
            end,
        },
        

        capacitor_totem = {
            id = 192058,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136013,
            
            handler = function ()
            end,
        },
        

        chain_lightning = {
            id = 188443,
            cast = function () return ( buff.tectonic_thunder.up or buff.stormkeeper.up ) and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return -4 * ( min( 5, active_enemies ) ) end,
            spendType = 'maelstrom',

            nobuff = 'ascendance',
            bind = 'lava_beam',

            startsCombat = true,
            texture = 136015,
            
            handler = function ()
                removeBuff( "master_of_the_elements" )
                
                if buff.stormkeeper.up then
                    gain( 2 * min( 5, active_enemies ), "maelstrom" )
                    removeStack( "stormkeeper" )
                else
                    removeBuff( "tectonic_thunder" )
                end

                if pet.storm_elemental.up then
                    addStack( "wind_gust", nil, 1 )
                end
                
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
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
            
            startsCombat = false,
            texture = 136024,
            
            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_earth_elemental" or "greater_earth_elemental", 60 )
            end,
        },
        

        earth_shield = {
            id = 974,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",

            talent = 'earth_shield',
            
            startsCombat = false,
            texture = 136089,
            
            handler = function ()
                applyBuff( 'earth_shield' )                
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
                if talent.exposed_elements.enabled then applyBuff( 'exposed_elements' ) end
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
                if talent.surge_of_power.enabled then applyBuff( "surge_of_power" ) end
            end,
        },
        

        earthbind_totem = {
            id = 2484,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
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
            
            spend = function () return buff.echoes_of_the_great_sundering.up and 0 or 60 end,
            spendType = "maelstrom",
            
            startsCombat = true,
            texture = 451165,
            
            handler = function ()
                removeBuff( "echoes_of_the_great_sundering" )
                removeBuff( "master_of_the_elements" )
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
            end,
        },
        

        elemental_blast = {
            id = 117014,
            cast = function () return 2 * haste end,
            cooldown = 12,
            gcd = "spell",
            
            startsCombat = true,
            texture = 651244,
            
            handler = function ()
                applyBuff( 'elemental_blast' )

                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( "fire_of_the_twisting_nether" )
                    applyBuff( "chill_of_the_twisting_nether" )
                    applyBuff( "shock_of_the_twisting_nether" )
                end
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

            toggle = 'cooldowns',
            notalent = 'storm_elemental',
            
            startsCombat = false,
            texture = 135790,
            
            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_fire_elemental" or "greater_fire_elemental", 30 )
            end,
        },
        

        flame_shock = {
            id = 188389,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135813,
            
            handler = function ()
                applyDebuff( 'target', 'flame_shock' )
                if buff.surge_of_power.up then
                    active_dot.surge_of_power = min( active_enemies, active_dot.flame_shock + 1 )
                    removeBuff( "surge_of_power" )
                end
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "fire_of_the_twisting_nether" ) end
            end,
        },
        

        frost_shock = {
            id = 196840,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135849,
            
            handler = function ()
                removeBuff( 'master_of_the_elements' )
                applyDebuff( 'target', 'frost_shock' )

                if buff.icefury.up then
                    gain( 8, "maelstrom" )
                    removeStack( "icefury", 1 )
                end

                if buff.surge_of_power.up then
                    applyDebuff( "target", "surge_of_power_debuff" )
                    removeBuff( "surge_of_power" )
                end

                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "chill_of_the_twisting_nether" ) end
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
                applyBuff( 'ghost_wolf' )
                if talent.spirit_wolf.enabled then applyBuff( 'spirit_wolf' ) end
            end,
        },
        

        healing_surge = {
            id = 8004,
            cast = function () return 1.5 * haste end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.2,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136044,
            
            handler = function ()
            end,
        },
        

        hex = {
            id = 51514,
            cast = function () return 1.7 * haste end,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 237579,
            
            handler = function ()
                applyDebuff( 'target', 'hex' )
            end,
        },
        

        icefury = {
            id = 210714,
            cast = 1.9996204751587,
            cooldown = 30,
            gcd = "spell",
            
            spend = -25,
            spendType = 'maelstrom',

            startsCombat = true,
            texture = 135855,
            
            handler = function ()
                removeBuff( 'master_of_the_elements' )
                applyBuff( 'icefury', 15, 4 )
            end,
        },
        

        lava_beam = {
            id = 114074,
            cast = function () return 2 * haste end,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return -4 * ( min( 5, active_enemies ) ) end,
            spendType = 'maelstrom',

            buff = 'ascendance',
            bind = 'chain_lightning',

            startsCombat = true,
            texture = 236216,
            
            handler = function ()
                removeStack( 'stormkeeper' )
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "fire_of_the_twisting_nether" ) end
            end,
        },
        

        lava_burst = {
            id = 51505,
            cast = function () return buff.lava_surge.up and 0 or ( 2 * haste ) end,
            charges = function () return talent.echo_of_the_elements.enabled and 2 or nil end,
            cooldown = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            recharge = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            gcd = "spell",
            
            spend = -10,
            spendType = "maelstrom",
            
            startsCombat = true,
            texture = 237582,
            
            handler = function ()
                removeBuff( "lava_surge" )
                if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end
                if talent.surge_of_power.enabled then
                    gainChargeTime( "fire_elemental", 6 )
                    removeBuff( "surge_of_power" )
                end
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "fire_of_the_twisting_nether" ) end
            end,
        },
        

        lightning_bolt = {
            id = 188196,
            cast = function () return buff.stormkeeper.up and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",
            
            spend = -8,
            spendType = "maelstrom",
            
            startsCombat = true,
            texture = 136048,
            
            handler = function ()
                removeBuff( "master_of_the_elements" )
                
                if buff.stormkeeper.up then
                    gain( 3, "maelstrom" )
                    removeStack( 'stormkeeper' )
                end

                if buff.surge_of_power.up then
                    gain( 3, "maelstrom" )
                    removeBuff( "surge_of_power" )
                end

                if pet.storm_elemental.up then
                    addStack( "wind_gust", nil, 1 )
                end
                
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
            end,
        },
        

        liquid_magma_totem = {
            id = 192222,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 971079,
            
            handler = function ()
            end,
        },
        

        purge = {
            id = 370,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.2,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136075,
            
            handler = function ()
            end,
        },
        

        storm_elemental = {
            id = 192249,
            cast = 0,
            charges = 1,
            cooldown = 150,
            recharge = 150,
            gcd = "spell",
            
            toggle = 'cooldowns',
            talent = 'storm_elemental',

            startsCombat = true,
            texture = 2065626,
            
            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental", 30 )
            end,
        },
        

        stormkeeper = {
            id = 191634,
            cast = function () return 1.5 * haste end,
            cooldown = 60,
            gcd = "spell",
            
            talent = 'stormkeeper',

            startsCombat = true,
            texture = 839977,
            
            handler = function ()
                applyBuff( 'stormkeeper', 20, 2 )
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
                if target.within10 then applyDebuff( 'target', 'thunderstorm' ) end
            end,
        },
        

        totem_mastery = {
            id = 210643,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            talent = 'totem_mastery',
            essential = true,
            
            startsCombat = false,
            texture = 511726,
            
            readyTime = function () return buff.totem_mastery.remains - 15 end,

            handler = function ()
                applyBuff( 'resonance_totem', 120 )
                applyBuff( 'storm_totem', 120 )
                applyBuff( 'ember_totem', 120 )
                if buff.tailwind_totem.down then stat.spell_haste = stat.spell_haste + 0.02 end
                applyBuff( 'tailwind_totem', 120 )
                applyBuff( 'totem_mastery', 120 )
            end,
        },
        

        tremor_totem = {
            id = 8143,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136108,
            
            handler = function ()
            end,
        },
        

        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1518639,
            
            handler = function ()
            end,
        }, ]]
        

        water_walking = {
            id = 546,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135863,
            
            handler = function ()
                applyBuff( 'water_walking' )
            end,
        },
        

        wind_rush_totem = {
            id = 192077,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            talent = 'wind_rush_totem',

            startsCombat = false,
            texture = 538576,
            
            handler = function ()                
            end,
        },
        

        wind_shear = {
            id = 57994,
            cast = 0,
            cooldown = 12,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136018,

            toggle = 'interrupts',
            
            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },
    } )

    
    spec:RegisterPack( "Elemental", 20190201.2107, [[d80pzbqijupIuQUeqrTjvQ(KebgfiCkGQvjr0RasMLeLBjHSls(LePHrk5yaXYak9mGctdQOUgujBJuk9nOsvghuPOZbveRtIk17GkvY8GkCpvI9bvXbbkIfQsXdHkvmrsPWfHQ0gbksFuIq1iHkfQtcvQQvcIEjuPsntjc5MqfPDcK6NqLcgQevSujQKNsQMQkLUQeb9vjcLXcvkK9c4VQyWIomLftKhl0Kb1Lv2mu(SKmAj1Pj8AOQMTQUTGDl1VHmCq64qLslhXZrA6OUorTDjOVRsA8su15LaRNukA(KI9t1aGaClGoSXda0GvlqWjAbwTaRcSGOfUNwAlGoxa0bOd1I4BvdqVTWa0X7VWA2EaDOwbpYGbUfqNIKjXbOxZmuA5U0sReCTSKkIcLsfb53ybQJedJlLkcXsLEKuPsywrWRWsHsqyIF0slhYkxMaMwA5uUo61wW6dE)fwZ2ROIqeqxsw8mUFdibOdB8aany1ceCIwGvlWQaRw4sBbbma0Pqxea0GvBblGETagEnGeGo8OraDT7jE)fwZ27PETfS2Hu7EwZmuA5U0sReCTSKkIcLsfb53ybQJedJlLkcXsLEKuPsywrWRWsHsqyIF0slhYkxMaMwA5uUo61wW6dE)fwZ2ROIq0Hu7EcP1YgPapbBzEcwTabN4zrEcwTk34cxoKoKA3tCNARRgTC7qQDplYZsiDEIB0z)cRz7vYq9KyC9iEY1w7zSEr8fDLNre6HrxBQNmYt6MNcmp3VWA2EQNgzEArwu4uoKA3ZI8uBiOM0pypXRr4ApX7VWA2EpxZeXOkhsT7zrEcMkkVNGj04AyRJZZRcU2tDgrcEI3FH1S94U8KSaQW5jlcZZy9I4Ra0HsqyIFa6A3t8(lSMT3t9AlyTdP29SMzO0YDPLwj4AzjvefkLkcYVXcuhjggxkveILk9iPsLWSIGxHLcLGWe)OLwoKvUmbmT0YPCD0RTG1h8(lSMTxrfHOdP29esRLnsbEc2Y8eSAbcoXZI8eSAvUXfUCiDi1UN4o1wxnA52Hu7EwKNLq68e3OZ(fwZ2RKH6jX46r8KRT2Zy9I4l6kpJi0dJU2upzKN0npfyEUFH1S9upnY80ISOWPCi1UNf5P2qqnPFWEIxJW1EI3FH1S9EUMjIrvoKA3ZI8emvuEpbtOX1WwhNNxfCTN6mIe8eV)cRz7XD5jzbuHZtweMNX6fXx5q6qQDpXB5xuMhSNsddrMNruqYypLwLOPkpbtIXbLPE2OUOAJeWKFpTilqn1tu)fOCiTilqnvbLSikiz8fS3O47qArwGAQckzruqYyqDPumec2H0ISa1ufuYIOGKXG6sPMCvynBSa1oKA3t92GsRrSNeta7PKmg2G9KYgt9uAyiY8mIcsg7P0Qen1tRH9ekzfbfXSOR8uq9eg1t5qArwGAQckzruqYyqDPuABqP1i(qzJPoKwKfOMQGswefKmguxkLr8cNGr5rkWHu7EArwGAQckzruqYyqDP0zeU(SFH1S9LjWUumB)AwbLic2F2VWA2EbLvRnPFWoKA3ZsiDEQZisa)nOJ4juYIOGKXEk3)OupPOW80GHPEEv8VNuO212tkc1khslYcutvqjlIcsgdQlLszejG)g0rktGDHTFnROmIeWFd6iQ1M0p47qqmb8zfUMvgmmvfrYnJdWqJgIjGpRW1SYGHPkrJhCPf4oKwKfOMQGswefKmguxkftq2z)cRz7ltGDPy2(1SIYis4SFH1S9Q1M0pyhslYcutvqjlIcsgdQlLcfXcu7qArwGAQckzruqYyqDP09lSMT)i9gLltGDHTFnR2VWA2(J0BuwT2K(b7q6qQDpXB5xuMhSNRWrkWtweMNC980ImI4PG6PvOjEt6NYHu7EI7yu2ZBEec(LPSNbRLT)lWtbMNC98emrBoIGNN3smb7jyshhLj27z5AuuBDCEkOEcLm6Aw5qArwGA6fPhHGFzkxMa7IPnhrWtzDCuMy)HmkQToo1At6hSdP29e3V5riYqzpryEgnktvoKwKfOMcQlLEv0WhA9mIdPfzbQPG6sPmIx4emkpsbLjWUW2VMvmIx4emkpsbQ1M0p47sYyykYOO264omIxqrwWenfhG1H0ISa1uqDPumbzN9lSMTVmb2LIz7xZkkJiHZ(fwZ2RwBs)GDiTilqnfuxkLYis4SFH1S9LjWUW2VMvugrcN9lSMTxT2K(bFhIIz7xZkrCyYKcuRnPFWA0uSKmgMsehMmPaLm07fhrOhgDTvI4WKjfOKHcUdP290ISa1uqDP0zeU(SFH1S9LjWUumB)AwbLic2F2VWA2EbLvRnPFWA0W2VMvqjIG9N9lSMTxqz1At6h8DiIi0dJU2kmbzN9lSMTxrwWenfhGawTUxmB)AwrzejC2VWA2E1At6hSgnre6HrxBfLrKWz)cRz7vKfmrtXbiGvR7S9RzfLrKWz)cRz7vRnPFWG7qArwGAkOUuQmDhbVa1H0ISa1uqDPuPhHGpyYKcktGDPy2(1SYOX1WwhNATj9dwJgjzmmLrJRHTooLmunAIi0dJU2kJgxdBDCkYcMOP4bxA5qArwGAkOUuQ0i0rWx0vLjWUumB)Awz04AyRJtT2K(bRrJKmgMYOX1WwhNsgQdPfzbQPG6sPycYKEecUmb2LIz7xZkJgxdBDCQ1M0pynAKKXWugnUg264uYq1OjIqpm6ARmACnS1XPilyIMIhCPLdPfzbQPG6sPwhhLj2FI2)LjWUumB)Awz04AyRJtT2K(bRrJKmgMYOX1WwhNsgQgnre6HrxBLrJRHToofzbt0u8GlTCiTilqnfuxkLi3hlYcuFEbLlRTWUyOvMa7IfzrH7SEbXO4bS3HGcD)FyJunMQI1MOpVOQMBrxHhWQrdf6()WgPAmv9wH2rAwapGfChslYcutb1LsjY9XISa1Nxq5YAlSlurx97WgPASdPdP29eNk)SWt2ivJ90ISa1EcLiqebxGNVGYoKwKfOMQm0UqzejG)g0rktGDHTFnROmIeWFd6iQ1M0pyhslYcutvgAG6sPgnUg264ktGDHTFnRmACnS1XPwBs)GVdbB)AwrzejC2VWA2E1At6h89IPmIeo7xynBVsg69ic9WORTIYis4SFH1S9kYcMOP4beCPrtXS9RzfLrKWz)cRz7vRnPFWG7qArwGAQYqduxk9f4wzb8jyvb7WiEHYeyxy7xZQxGBLfWNGvfSdJ4fuRnPFWoKoKA3tDOKzWEcM(wyEQxJI47PO9ehxWzpzJun2tmrvntlZtjz2ZgXEclteDLN641tzOSiSY8uU)rPEwasUeqMNyIQAw0vEcgEYgPAm1tRH9S2kCE(Js9KRT2tqWzplXenSNL4Yu2tkBr8PkhslYcutvgAG6sPyVf2HwJI4xwSG4VdBKQX0lGuMa7czyKrRnPF3Pq3)h2ivJPQyTj6ZlQQ5w0v4ax3HOy2(1SIYis4SFH1S9Q1M0pynAIi0dJU2kkJiHZ(fwZ2RilyIMIdqaRwA0qHU)pSrQgtvXAt0NxuvZTORUag3LKXWuxfn8PsMYkkBr8Xbi4m4oKoKA3ZBjf4jJ8SYcZt8AeUg3kB4ppVk4ApXPgLhXteMNC98eV)cRzQNsYyyEETETNyIQAw0vEcgEYgPAmv5P2a1La2tuHJenOEItT9uMGcf7qArwGAQYqduxkDgHRXTYg(Rmb2LIz7xZQGr5roiSdxVZ(fwZu1At6hSgnsYyykkJib83GoIsgQgnbBpLjOaEUabiAPvr4CjPq3)h2ivJPQyTj6ZlQQ5w0vGRrJKmgMkyuEKdc7W17SFH1mvjdvJgk09)Hns1yQkwBI(8IQAUfDfEadhshsT7jUH(lWZOrzplrwHMN3itOSNO2tUMS5jBKQXupfyEkypfupT2trtzRzpTg2tDgrcEI3FH1S9EkOEcACd36PfzrHt5qArwGAQYqduxk9TcTJKmHYLjWUaHKmgM6TcTdvMunLmunAKKXWugnUg264uYqb)of6()WgPAmvfRnrFErvn3IUch48DikMTFnROmIeo7xynBVATj9dwJMic9WORTIYis4SFH1S9kYcMOP4aeWQf4oKoKA3ZsiDEI3FH1S9EEZBu2tRYenL9ugQNmYtWWt2ivJPEAupFux5Pr9uNrKGN49xynBVNcQNnI90ISOWPCiTilqnvzObQlLUFH1S9hP3OCzcSlS9Rz1(fwZ2FKEJYQ1M0p47uO7)dBKQXuvS2e95fv1Cl6kCGZ3HOy2(1SIYis4SFH1S9Q1M0pynAIi0dJU2kkJiHZ(fwZ2RilyIMIdqaRwG7qArwGAQYqduxk9TcTJ0SqzcSlS9RzLrJRHToo1At6hSdPfzbQPkdnqDP0yTj6ZlQQ5w0voKwKfOMQm0a1LsFRq7ijtOCzbuHIU6ciLjWUW2VMvgnUg264uRnPFWoKwKfOMQm0a1LsXElSdTgfXVSaQqrxDbKYIfe)DyJunMEbKYeyxidJmATj9ZH0ISa1uLHgOUukgbr5dTgfXVSaQqrxDbehshshsT7PUOR(55TgPASNGjrwGAplhIareCbEwIeu2Hu7EI3MktMNGP6EkOEArwu48uU)rPEwas2ZARW5ji4SNiINbezEszlIp1teMNLyIg2ZsCzk7jgbf8uNrKGN49xynBVYtiWlC18mA0vU9ugAefeDLNGj0ONsYSNwKffop1XlUlpHrDjG9eChslYcutvurx97WgPA8fS3c7qRrr8ltGDbIIzreFrxPrdB)AwrzejC2VWA2E1At6h89ic9WORTIYis4SFH1S9kYcMOP4aSLSkcRrdmIvyVf2HwJI4RilyIMIJlvrynAy7xZkJgxdBDCQ1M0p47WiwH9wyhAnkIVISGjAkoGiIqpm6ARmACnS1XPilyIMckjzmmLrJRHToofSmXybQb)EeHEy01wz04AyRJtrwWenfh48DikMTFnROmIeo7xynBVATj9dwJg2(1SIYis4SFH1S9Q1M0p47re6HrxBfLrKWz)cRz7vKfmrtXbiGvlWb)UKmgM6QOHpvYuwrzlIpoabNVxSKmgMIktQ2bHDGIUoIsgQdPdP29SesNNGj04AyRJZtdJhXZcqYLGcNNuORzpT)9SezfAEEJmHYEgRns1OEAnSNO(lWtbMN9eC9iEQZisWt8(lSMT3Zgr8e3pomzsbEAK5zuMqwZFbEArwu4uoKwKfOMQOIU63Hns1yqDPuJgxdBDCLjWUW2VMvgnUg264uRnPFW3Ji0dJU2Q3k0osYekRilyIMIhTUdrXS9RzfLrKWz)cRz7vRnPFWA0arXugrcN9lSMTxjd9EeHEy01wrzejC2VWA2Efzbt0u8acUah87qumB)AwjIdtMuGATj9dwJMILKXWuI4WKjfOKHEV4ic9WORTsehMmPaLmuWDiDi1UNAduxcypLPZt8(lSMT3ZBEJYEkW8SaKSNrK8d7z0OSNMN4uJYJ4jcZtUEEI3FH1m1ZfGIUoYG9eVgHR9uVgfX3trt5zWkp1gOUeWEgnk7jE)fwZ275nVrzpHLjIUYtDgrcEI3FH1S9Ek3)Ouplaj7zTv48emkVNG2yzI9EIBSrcOUapfTNxRfXApJgDEwas2tkJG6Pmv0vEI3FH1S9EEZBu2tuhNNfGK9Kmlw7ji4SNu2I4t9eH5zjMOH9SexMYkhslYcutvurx97WgPAmOUu6(fwZ2FKEJYLjWUW2VMv7xynB)r6nkRwBs)GVdbB)AwfmkpYbHD46D2VWAMQwBs)GVljJHPcgLh5GWoC9o7xyntvYqVhS9uMGc4qB1sJMIz7xZQGr5roiSdxVZ(fwZu1At6hm43HOyiOmIeo7xynBVsg6D2(1SIYis4SFH1S9Q1M0pyW1OX0MJi4PAJLj2FQnsa1fOiwJ)fW4UKmgM6QOHpvYuwrzlIpoabNb3H0Hu7EI7EdQN64U9edr88ns18er8KIqTNgmSNxTchv5zjS)rPEwas2ZARW5PUmPAEIW8SCqxhPmpfTNxRfXApJgDEwas2ZRwZEYipHrYs)8usgdZZsKOQMBrx55nON9uQapHIqVOR8eNA7Pmbf8uAyiYQTgw5jElVfG(Zt6WTYRJRC7jiAPfovVmpXREzEQJ7Umplr3uMNLOcVPmpXREzEwIUXH0ISa1ufv0v)oSrQgdQlLszejG)g0rktGDHTFnROmIeWFd6iQ1M0p47qqmb8zfUMvgmmvfrYnJdWqJgIjGpRW1SYGHPkrJhCPf43HOy2(1SIktQ2bHDGIUoIATj9dwJgjzmmfvMuTdc7afDDeLmunAc2Ektqb8CbNXzWDiTilqnvrfD1VdBKQXG6sPVa3klGpbRkyhgXluMa7cB)Aw9cCRSa(eSQGDyeVGATj9d(oeetaFwHRzLbdtvrKCZ4am0OHyc4ZkCnRmyyQs04bxAbUdPdP29e3bfKe98uNrKa(BqhXZRcU2tCQr5r8eH5jxppX7VWAM6jI4PUmPAEIW8SCqxhr5qArwGAQIk6QFh2ivJb1LsFrvn3IU6iHEUmb2fjzmmfLrKa(Bqhrjd9of6()WgPAmvfRnrFErvn3IUchG9oesYyyQGr5roiSdxVZ(fwZuLm07fZ2VMvuzs1oiSdu01ruRnPFWA0ijJHPOYKQDqyhOORJOKHcUdPdP29826rMNbrvn7zefMNw7PmuyJNNyiINCTG65l655vbx7jffMN6OYXZhvjIkhslYcutvurx97WgPAmOUu6mcxJBLn8xzcSlwKffUZ6feJIhqUtHU)pSrQgtvXAt0NxuvZTORWdi3HOy2(1SIktQ2bHDGIUoIATj9dwJMIHrSc7TWo0AueFfzyKrRnPFA0qzejC2VWA2ELmuWVdrXS9RzvWO8ihe2HR3z)cRzQATj9dwJgjzmmvWO8ihe2HR3z)cRzQsgQgnbBpLjOaEUGtal4oKoKA3ZBqfOuQR1g7P5ze1WcwGALNLycU2tCQr5r8eH5jxppX7VWAM6jue69eNA7Pmbf8ugQNmYtCtpXP2EktqbpL2JU6jxppJgupzKNRPYK5PGlbupLPd2ZRcU2t8AeU2t9AueFLNLycUgjZEItnkpINimp565jE)fwZ0Y8uMopXRr4Ap1Rrr89CcUEepfyEQZisa)nOJ4PG6Pm0Y8eNA7Pmbf8uq9eeT8eNA7Pmbf8uAp6QNC98mAq9er88hLwMNiINtW1J4PoJibpX7VWA2Epf0UeWEY2VMhSNiINcUeq9SrSNwKffopTg2ZcqYepFJYEQZisWt8(lSMT3teMNC98etuvZEEv8VN1wHZtu)f4P5juJWc79ewMySa1khslYcutvurx97WgPAmOUu6mcxFO1Oi(LjWUuSKmgMIktQ2bHDGIUoIsg6D2(1SkyuEKdc7W17SFH1mvT2K(bFhcjzmmvWO8ihe2HR3z)cRzQsgQgnbBpLjOaEUGtalOadTkjB)AwfT)pC9oCTCdpIATj9dwJgjzmmfLrKa(Bqhrjd9UfzrH7SEbXO4aSGRrtXS9RzvWO8ihe2HR3z)cRzQATj9d(oesYyykkJib83GoIsgQgnbBpLjOaEUGt0cuGHwLKTFnRI2)hUEhUwUHhrT2K(bRrtXqqzejC2VWA2ELm07S9RzfLrKWz)cRz7vRnPFWGFFLh6I8GpruqY4ZVUIRlIfHvueHEy01wrzejC2VWA2Efzbt00IabxAvsShHiqaXkp0f5bFIOGKXNFDfxxelcROic9WORTIYis4SFH1S9kYcMOPGdMbbxAboEUagAvsiabuqyAZre8ulwJoiSdxVZ(fwZ2tveRXhpxal4GdUdPdP29SesNN41iCTN61Oi(EkW8uxMunpryEwoORJ4PG6jB)AEWL5PKm7zpbxpINc2Zgr808uBuo6EI3FH1S9EkOEArwu480yp565zafwZL5P1WEwIScnpVrMqzpfupjZGlWteXZRI)9uAEEvW1I2tUEE2R8SNL44oAdLdPfzbQPkQOR(DyJunguxkDgHRp0Aue)Yeyxy7xZkQmPAhe2bk66iQ1M0p47fljJHPOYKQDqyhOORJOKHEpIqpm6ARERq7ijtOSISGjAkoUufHVdrXS9RzfLrKWz)cRz7vRnPFW3lgcmbzN9lSMTxjdfCnAy7xZkkJiHZ(fwZ2RwBs)GVxmeugrcN9lSMTxjdfCWDiDi1UN4ogL9SejQQ5w0vEEd6zQNWYerx5PoJibpX7VWA2EpHLjglqTYH0ISa1ufv0v)oSrQgdQlL(IQAUfD1rc9CzcSlugrcN9lSMTxjd9oB)AwrzejC2VWA2E1At6hSdPdP29SesNNGPeeL9uVgfX3ZRcU2tC)4WKjf4P1WEItnkpINimp565jE)fwZuLdPfzbQPkQOR(DyJunguxkfJGO8HwJI4xMa7cB)AwjIdtMuGATj9d(oB)AwfmkpYbHD46D2VWAMQwBs)GVljJHPeXHjtkqjd9UKmgMkyuEKdc7W17SFH1mvjd1H0ISa1ufv0v)oSrQgdQlL(wH2rsMq5YeyxKKXWugnUg264uYqDiDi1UNLqw8cT58uxMunpryEwoORJ4jJ8KcLmd2tW03cZt9AueFpfyEgKFwa9NNRxqmQNgzEcLm6Aw5qArwGAQIk6QFh2ivJb1LsXElSdTgfXVSybXFh2ivJPxaPmb2fYWiJwBs)UBrwu4oRxqmkEa5UKmgMIktQ2bHDGIUoIsgQdPdP29SesNNLiRqZZBKju2ZRcU2tDzs18eH5z5GUoINcmp5655Bu2tOiEnlS3tzQvnpryEAEQnkhDpX7VWA2EpRnAxcypnpXK)3tyzIXcu7jUHYLNcmplaj7zej)WEwn2tRrC9iEktTQ5jcZtUEEQnkhDpX7VWA2EpfyEY1ZtYcMOfDLNyIQA2ZRg1tq0wWSNpQRgr5qArwGAQIk6QFh2ivJb1LsFRq7ijtOCzcSlS9RzfLrKWz)cRz7vRnPFW3Ji0dJU2hYSiFxsgdtrLjv7GWoqrxhrjd9oeR8qxKh8jIcsgF(1vCDrSiSIIi0dJU2kkJiHZ(fwZ2RilyIMwei4sRsI9iebciw5HUip4tefKm(8RR46IyryffrOhgDTvugrcN9lSMTxrwWenfCWmi4slWXbyOvjHaeqbHPnhrWtTyn6GWoC9o7xynBpvrSgF8CbSGdUgnqaIceTTKqSYdDrEWNikiz85xxX1fXIWaVOic9WORTIYis4SFH1S9kYcMOPfbcU0QKypcrGacquGOTLeIvEOlYd(erbjJp)6kUUiweg4ffrOhgDTvugrcN9lSMTxrwWenfCWmi4slWbhhqSYdDrEWNikiz85xxX1fXIWkkIqpm6AROmIeo7xynBVISGjAArGGlTkj2JqeiGyLh6I8GpruqY4ZVUIRlIfHvueHEy01wrzejC2VWA2Efzbt0uWbZGGlTahCWDiDi1UNLq68SezfAEEJmHYEEvW1EQltQMNimplh01r8uG5jxppFJYEcfXRzH9EktTQ5jcZtZtTr5O7jE)fwZ27zTr7sa7P5jM8)EcltmwGApXnuU8uG5zbizpJi5h2ZQXEAnIRhXtzQvnpryEY1ZtTr5O7jE)fwZ27PaZtUEEswWeTOR8etuvZEE1OEcI2cM98rD1ikhslYcutvurx97WgPAmOUu6BfAhjzcLltGDPy2(1SIYis4SFH1S9Q1M0p47re6Hrx7dzwKVljJHPOYKQDqyhOORJOKHEhIvEOlYd(erbjJp)6kUUiwewrre6HrxBfMGSZ(fwZ2RilyIMwei4sRsI9iebciw5HUip4tefKm(8RR46IyryffrOhgDTvycYo7xynBVISGjAk4GzqWLwGJdWqRscbiGcctBoIGNAXA0bHD46D2VWA2EQIyn(45cybhCnAGaefiABjHyLh6I8GpruqY4ZVUIRlIfHbErre6HrxBfMGSZ(fwZ2RilyIMwei4sRsI9iebciarbI2wsiw5HUip4tefKm(8RR46IyryGxueHEy01wHji7SFH1S9kYcMOPGdMbbxAbo44aIvEOlYd(erbjJp)6kUUiwewrre6HrxBfMGSZ(fwZ2RilyIMwei4sRsI9iebciw5HUip4tefKm(8RR46IyryffrOhgDTvycYo7xynBVISGjAk4GzqWLwGdo4oKwKfOMQOIU63Hns1yqDP0xuvZTORosONltGDrsgdtrLjv7GWoqrxhrjd1H0ISa1ufv0v)oSrQgdQlL(wH2rsMq5YeyxIi0dJU2hYSi7q6qQDp1gOUeWEAXOaEnB)xGNY05PUmPAEIW8SCqxhXZRcU2tW03cZt9AueFpHLjIUYtQOR(5jBKQXkhslYcutvurx97WgPAmOUuk2BHDO1Oi(Lfli(7WgPAm9ciLjWUqggz0At639ILKXWuuzs1oiSdu01ruYqDiTilqnvrfD1VdBKQXG6sPmIx4emkpsbLjWUW2VMvmIx4emkpsbQ1M0p47qijJHPiJIARJ7WiEbfzbt0uCOTA0aHKmgMImkQToUdJ4fuKfmrtXbesYyykJgxdBDCkyzIXcudQic9WORTYOX1WwhNISGjAk43Ji0dJU2kJgxdBDCkYcMOP4aeCbo4oKoKA3t9xuvZFbEwzH5jUFCyYKc8usgdZtg5znc6WK)VapLKXW8KIcZZRcU2tCQr5r8eH5jxppX7VWAMQCiTilqnvrfD1VdBKQXG6sPyeeLp0Aue)Yeyxy7xZkrCyYKcuRnPFW3LKXWuI4WKjfOKHEhcjzmmLiomzsbkYcMOP4OkcxsCUKsYyykrCyYKcuu2I4RrJKmgMIYisa)nOJOKHQrtXS9RzvWO8ihe2HR3z)cRzQATj9dgChslYcutvurx97WgPAmOUuQiomzsbLjWUW2VMvI4WKjfOwBs)GDiTilqnvrfD1VdBKQXG6sPVOQMBrxDKqp7qArwGAQIk6QFh2ivJb1LsXElSdTgfXVSaQqrxDbKYIfe)DyJunMEbKYeyxidJmATj9ZH0ISa1ufv0v)oSrQgdQlLI9wyhAnkIFzbuHIU6ciLjWUeqfUWAwblOS1XHhT1H0Hu7EcMsqu2t9AueFpfuprYepdOcxyn7jM4)ruoKwKfOMQOIU63Hns1yqDPumcIYhAnkIFzbuHIU6cia6focvGAaqdwTabNOfiAbIcSGbUWnb0VAKw0vuaDC)aueHhSN4SNwKfO2ZxqzQYHeq)fuMcClGov0v)oSrQgdClaObb4wa91M0pyGBa0JebpIWa0HWZI9Kfr8fDLNA04jB)AwrzejC2VWA2E1At6hSN39mIqpm6AROmIeo7xynBVISGjAQN4WtW6zj9Skc7PgnEcJyf2BHDO1Oi(kYcMOPEIJlEwfH9uJgpz7xZkJgxdBDCQ1M0pypV7jmIvyVf2HwJI4RilyIM6jo8ecpJi0dJU2kJgxdBDCkYcMOPEckpLKXWugnUg264uWYeJfO2tW98UNre6HrxBLrJRHToofzbt0upXHN4SN39ecpl2t2(1SIYis4SFH1S9Q1M0pyp1OXt2(1SIYis4SFH1S9Q1M0pypV7zeHEy01wrzejC2VWA2Efzbt0upXHNGawT8eCpb3Z7EkjJHPUkA4tLmLvu2I47jo8eeC2Z7EwSNsYyykQmPAhe2bk66ikzOa6wKfOgqh7TWo0AueFaga0Gf4wa91M0pyGBa0JebpIWa0z7xZkJgxdBDCQ1M0pypV7zeHEy01w9wH2rsMqzfzbt0upXJNA55DpHWZI9KTFnROmIeo7xynBVATj9d2tnA8ecpl2tkJiHZ(fwZ2RKH65DpJi0dJU2kkJiHZ(fwZ2RilyIM6jE8eeC5j4EcUN39ecpl2t2(1SsehMmPa1At6hSNA04zXEkjJHPeXHjtkqjd1Z7EwSNre6HrxBLiomzsbkzOEcoGUfzbQb0nACnS1XbWaGgmaUfqFTj9dg4ga9irWJimaD2(1SA)cRz7psVrz1At6hSN39ecpz7xZQGr5roiSdxVZ(fwZu1At6hSN39usgdtfmkpYbHD46D2VWAMQKH65Dpd2EktqbpXHNARwEQrJNf7jB)AwfmkpYbHD46D2VWAMQwBs)G9eCpV7jeEwSNq4jLrKWz)cRz7vYq98UNS9RzfLrKWz)cRz7vRnPFWEcUNA04PPnhrWt1gltS)uBKaQlqrSgFpV4jy45DpLKXWuxfn8PsMYkkBr89ehEcco7j4a6wKfOgqF)cRz7psVrzaga04mWTa6RnPFWa3aOhjcEeHbOZ2VMvugrc4VbDe1At6hSN39ecpjMa(ScxZkdgMQIi5M9ehEcgEQrJNetaFwHRzLbdtvI2t84jU0YtW98UNq4zXEY2VMvuzs1oiSdu01ruRnPFWEQrJNsYyykQmPAhe2bk66ikzOEQrJNbBpLjOGN45IN4mo7j4a6wKfOgqNYisa)nOJaWaGgxa3cOV2K(bdCdGEKi4regGoB)Aw9cCRSa(eSQGDyeVGATj9d2Z7EcHNetaFwHRzLbdtvrKCZEIdpbdp1OXtIjGpRW1SYGHPkr7jE8exA5j4a6wKfOgq)f4wzb8jyvb7WiEbaga0AlWTa6RnPFWa3aOhjcEeHbOljJHPOmIeWFd6ikzOEE3tk09)Hns1yQkwBI(8IQAUfDLN4WtW65DpHWtjzmmvWO8ihe2HR3z)cRzQsgQN39Sypz7xZkQmPAhe2bk66iQ1M0pyp1OXtjzmmfvMuTdc7afDDeLmupbhq3ISa1a6VOQMBrxDKqpdWaGg3d4wa91M0pyGBa0JebpIWa0TilkCN1lig1t84jiEE3tk09)Hns1yQkwBI(8IQAUfDLN4Xtq88UNq4zXEY2VMvuzs1oiSdu01ruRnPFWEQrJNf7jmIvyVf2HwJI4RidJmATj9ZtnA8KYis4SFH1S9kzOEcUN39ecpl2t2(1SkyuEKdc7W17SFH1mvT2K(b7PgnEkjJHPcgLh5GWoC9o7xyntvYq9uJgpd2EktqbpXZfpXjG1tWb0TilqnG(mcxJBLn8hadaACtGBb0xBs)GbUbqpse8icdqVypLKXWuuzs1oiSdu01ruYq98UNS9RzvWO8ihe2HR3z)cRzQATj9d2Z7EcHNsYyyQGr5roiSdxVZ(fwZuLmup1OXZGTNYeuWt8CXtCcy9euEcgA5zj9KTFnRI2)hUEhUwUHhrT2K(b7PgnEkjJHPOmIeWFd6ikzOEE3tlYIc3z9cIr9ehEcwpb3tnA8Sypz7xZQGr5roiSdxVZ(fwZu1At6hSN39ecpLKXWuugrc4VbDeLmup1OXZGTNYeuWt8CXtCIwEckpbdT8SKEY2VMvr7)dxVdxl3WJOwBs)G9uJgpl2ti8KYis4SFH1S9kzOEE3t2(1SIYis4SFH1S9Q1M0pypb3Z7EUYdDrEWNikiz85xxX1EwKNSimplYZic9WORTIYis4SFH1S9kYcMOPEwKNGGlT8SKEI9ieXti8ecpx5HUip4tefKm(8RR4AplYtweMNf5zeHEy01wrzejC2VWA2Efzbt0upb3tWSNGGlT8eCpXZfpbdT8SKEcHNG4jO8ecpnT5icEQfRrhe2HR3z)cRz7PkI147jEU4jy9eCpb3tWb0TilqnG(mcxFO1Oi(amaOXja3cOV2K(bdCdGEKi4regGoB)AwrLjv7GWoqrxhrT2K(b75Dpl2tjzmmfvMuTdc7afDDeLmupV7zeHEy01w9wH2rsMqzfzbt0upXXfpRIWEE3ti8Sypz7xZkkJiHZ(fwZ2RwBs)G98UNf7jeEIji7SFH1S9kzOEcUNA04jB)AwrzejC2VWA2E1At6hSN39SypHWtkJiHZ(fwZ2RKH6j4EcoGUfzbQb0Nr46dTgfXhGbaniAbClG(At6hmWna6rIGhrya6ugrcN9lSMTxjd1Z7EY2VMvugrcN9lSMTxT2K(bdOBrwGAa9xuvZTORosONbyaqdcia3cOV2K(bdCdGEKi4regGoB)AwjIdtMuGATj9d2Z7EY2VMvbJYJCqyhUEN9lSMPQ1M0pypV7PKmgMsehMmPaLmupV7PKmgMkyuEKdc7W17SFH1mvjdfq3ISa1a6yeeLp0AueFaga0GawGBb0xBs)GbUbqpse8icdqxsgdtz04AyRJtjdfq3ISa1a6VvODKKjugGbaniGbWTa6RnPFWa3aOBrwGAaDS3c7qRrr8b0JebpIWa0jdJmATj9ZZ7EArwu4oRxqmQN4Xtq88UNsYyykQmPAhe2bk66ikzOa6XcI)oSrQgtbaniamaObbNbUfqFTj9dg4ga9irWJimaD2(1SIYis4SFH1S9Q1M0pypV7zeHEy01(qMfzpV7PKmgMIktQ2bHDGIUoIsgQN39ecpx5HUip4tefKm(8RR4AplYtweMNf5zeHEy01wrzejC2VWA2Efzbt0uplYtqWLwEwspXEeI4jeEcHNR8qxKh8jIcsgF(1vCTNf5jlcZZI8mIqpm6AROmIeo7xynBVISGjAQNG7jy2tqWLwEcUN4WtWqlplPNq4jiEckpHWttBoIGNAXA0bHD46D2VWA2EQIyn(EINlEcwpb3tW9uJgpHWtquGOTEwspHWZvEOlYd(erbjJp)6kU2ZI8KfH5j4EwKNre6HrxBfLrKWz)cRz7vKfmrt9SipbbxA5zj9e7riINq4jeEcIceT1Zs6jeEUYdDrEWNikiz85xxX1EwKNSimpb3ZI8mIqpm6AROmIeo7xynBVISGjAQNG7jy2tqWLwEcUNG7jo8ecpx5HUip4tefKm(8RR4AplYtweMNf5zeHEy01wrzejC2VWA2Efzbt0uplYtqWLwEwspXEeI4jeEcHNR8qxKh8jIcsgF(1vCTNf5jlcZZI8mIqpm6AROmIeo7xynBVISGjAQNG7jy2tqWLwEcUNG7j4a6wKfOgq)TcTJKmHYamaObbxa3cOV2K(bdCdGEKi4regGEXEY2VMvugrcN9lSMTxT2K(b75DpJi0dJU2hYSi75DpLKXWuuzs1oiSdu01ruYq98UNq45kp0f5bFIOGKXNFDfx7zrEYIW8SipJi0dJU2kmbzN9lSMTxrwWen1ZI8eeCPLNL0tShHiEcHNq45kp0f5bFIOGKXNFDfx7zrEYIW8SipJi0dJU2kmbzN9lSMTxrwWen1tW9em7ji4slpb3tC4jyOLNL0ti8eepbLNq4PPnhrWtTyn6GWoC9o7xynBpvrSgFpXZfpbRNG7j4EQrJNq4jikq0wplPNq45kp0f5bFIOGKXNFDfx7zrEYIW8eCplYZic9WORTctq2z)cRz7vKfmrt9SipbbxA5zj9e7riINq4jeEcIceT1Zs6jeEUYdDrEWNikiz85xxX1EwKNSimpb3ZI8mIqpm6ARWeKD2VWA2Efzbt0upb3tWSNGGlT8eCpb3tC4jeEUYdDrEWNikiz85xxX1EwKNSimplYZic9WORTctq2z)cRz7vKfmrt9SipbbxA5zj9e7riINq4jeEUYdDrEWNikiz85xxX1EwKNSimplYZic9WORTctq2z)cRz7vKfmrt9eCpbZEccU0YtW9eCpbhq3ISa1a6VvODKKjugGbaniAlWTa6RnPFWa3aOhjcEeHbOljJHPOYKQDqyhOORJOKHcOBrwGAa9xuvZTORosONbyaqdcUhWTa6RnPFWa3aOhjcEeHbOhrOhgDTpKzrgq3ISa1a6VvODKKjugGbani4Ma3cOV2K(bdCdGUfzbQb0XElSdTgfXhqpse8icdqNmmYO1M0ppV7zXEkjJHPOYKQDqyhOORJOKHcOhli(7WgPAmfa0GaWaGgeCcWTa6RnPFWa3aOhjcEeHbOZ2VMvmIx4emkpsbQ1M0pypV7jeEkjJHPiJIARJ7WiEbfzbt0upXHNARNA04jeEkjJHPiJIARJ7WiEbfzbt0upXHNq4PKmgMYOX1WwhNcwMySa1EckpJi0dJU2kJgxdBDCkYcMOPEcUN39mIqpm6ARmACnS1XPilyIM6jo8eeC5j4EcoGUfzbQb0zeVWjyuEKcayaqdwTaUfqFTj9dg4ga9irWJimaD2(1SsehMmPa1At6hSN39usgdtjIdtMuGsgQN39ecpLKXWuI4WKjfOilyIM6jo8Skc7zj9eN9SKEkjJHPeXHjtkqrzlIVNA04PKmgMIYisa)nOJOKH6PgnEwSNS9RzvWO8ihe2HR3z)cRzQATj9d2tWb0TilqnGogbr5dTgfXhGbanybb4wa91M0pyGBa0JebpIWa0z7xZkrCyYKcuRnPFWa6wKfOgqxehMmPaaga0GfSa3cOBrwGAa9xuvZTORosONb0xBs)GbUbGbanybdGBb0xBs)GbUbq3ISa1a6yVf2HwJI4dOhli(7WgPAmfa0GaOhjcEeHbOtggz0At6hGEavOORa0bbGbanyXzGBb0xBs)GbUbqpse8icdqpGkCH1ScwqzRJZt84P2cOBrwGAaDS3c7qRrr8b0dOcfDfGoiamaOblUaUfqpGku0va6GaOBrwGAaDmcIYhAnkIpG(At6hmWnamadOBObClaObb4wa91M0pyGBa0JebpIWa0z7xZkkJib83GoIATj9dgq3ISa1a6ugrc4VbDeaga0Gf4wa91M0pyGBa0JebpIWa0z7xZkJgxdBDCQ1M0pypV7jeEY2VMvugrcN9lSMTxT2K(b75Dpl2tkJiHZ(fwZ2RKH65DpJi0dJU2kkJiHZ(fwZ2RilyIM6jE8eeC5PgnEwSNS9RzfLrKWz)cRz7vRnPFWEcoGUfzbQb0nACnS1XbWaGgmaUfqFTj9dg4ga9irWJimaD2(1S6f4wzb8jyvb7WiEb1At6hmGUfzbQb0FbUvwaFcwvWomIxaGbanodClG(At6hmWna6wKfOgqh7TWo0AueFa9irWJimaDYWiJwBs)88UNuO7)dBKQXuvS2e95fv1Cl6kpXHN4YZ7EcHNf7jB)AwrzejC2VWA2E1At6hSNA04zeHEy01wrzejC2VWA2Efzbt0upXHNGawT8uJgpPq3)h2ivJPQyTj6ZlQQ5w0vEEXtWWZ7EkjJHPUkA4tLmLvu2I47jo8eeC2tWb0Jfe)DyJunMcaAqayaqJlGBb0xBs)GbUbqpse8icdqVypz7xZQGr5roiSdxVZ(fwZu1At6hSNA04PKmgMIYisa)nOJOKH6PgnEgS9uMGcEINlEcHNGOLwEwKN4SNL0tk09)Hns1yQkwBI(8IQAUfDLNG7PgnEkjJHPcgLh5GWoC9o7xyntvYq9uJgpPq3)h2ivJPQyTj6ZlQQ5w0vEIhpbdaDlYcudOpJW14wzd)bWaGwBbUfqFTj9dg4ga9irWJimaDi8usgdt9wH2HktQMsgQNA04PKmgMYOX1WwhNsgQNG75DpPq3)h2ivJPQyTj6ZlQQ5w0vEIdpXzpV7jeEwSNS9RzfLrKWz)cRz7vRnPFWEQrJNre6HrxBfLrKWz)cRz7vKfmrt9ehEccy1YtWb0TilqnG(BfAhjzcLbyaqJ7bClG(At6hmWna6rIGhrya6S9Rz1(fwZ2FKEJYQ1M0pypV7jf6()WgPAmvfRnrFErvn3IUYtC4jo75DpHWZI9KTFnROmIeo7xynBVATj9d2tnA8mIqpm6AROmIeo7xynBVISGjAQN4WtqaRwEcoGUfzbQb03VWA2(J0BugGbanUjWTa6RnPFWa3aOhjcEeHbOZ2VMvgnUg264uRnPFWa6wKfOgq)TcTJ0SaadaACcWTa6wKfOgqpwBI(8IQAUfDfG(At6hmWnamaObrlGBb0xBs)GbUbqpse8icdqNTFnRmACnS1XPwBs)Gb0TilqnG(BfAhjzcLb0dOcfDfGoiamaObbeGBb0xBs)GbUbq3ISa1a6yVf2HwJI4dOhli(7WgPAmfa0GaOhjcEeHbOtggz0At6hGEavOORa0bbGbaniGf4wa9aQqrxbOdcGUfzbQb0XiikFO1Oi(a6RnPFWa3aWamGo8Wm5NbUfa0GaClG(At6hmGeGEKi4regGUPnhrWtzDCuMy)HmkQToo1At6hmGUfzbQb0LEec(LPmadaAWcClGUfzbQb0VkA4dTEgbqFTj9dg4gaga0GbWTa6RnPFWa3aOhjcEeHbOZ2VMvmIx4emkpsbQ1M0pypV7PKmgMImkQToUdJ4fuKfmrt9ehEcwaDlYcudOZiEHtWO8ifaWaGgNbUfqFTj9dg4ga9irWJima9I9KTFnROmIeo7xynBVATj9dgq3ISa1a6ycYo7xynBpadaACbClG(At6hmWna6rIGhrya6S9RzfLrKWz)cRz7vRnPFWEE3ti8Sypz7xZkrCyYKcuRnPFWEQrJNf7PKmgMsehMmPaLmupV7zXEgrOhgDTvI4WKjfOKH6j4a6wKfOgqNYis4SFH1S9amaO1wGBb0TilqnGUmDhbVafqFTj9dg4gaga04Ea3cOV2K(bdCdGEKi4regGEXEY2VMvgnUg264uRnPFWEQrJNsYyykJgxdBDCkzOEQrJNre6HrxBLrJRHToofzbt0upXJN4slaDlYcudOl9ie8btMuaadaACtGBb0xBs)GbUbqpse8icdqVypz7xZkJgxdBDCQ1M0pyp1OXtjzmmLrJRHTooLmuaDlYcudOlncDe8fDfadaACcWTa6RnPFWa3aOhjcEeHbOxSNS9RzLrJRHToo1At6hSNA04PKmgMYOX1WwhNsgQNA04zeHEy01wz04AyRJtrwWen1t84jU0cq3ISa1a6ycYKEecgGbaniAbClG(At6hmWna6rIGhrya6f7jB)Awz04AyRJtT2K(b7PgnEkjJHPmACnS1XPKH6PgnEgrOhgDTvgnUg264uKfmrt9epEIlTa0TilqnGU1XrzI9NO9padaAqab4wa91M0pyGBa0JebpIWa0TilkCN1lig1t84jy98UNq4jf6()WgPAmvfRnrFErvn3IUYt84jy9uJgpPq3)h2ivJPQ3k0osZcEIhpbRNGdOBrwGAaDICFSilq95fugq)fu(0wya6gAamaObbSa3cOV2K(bdCdGUfzbQb0jY9XISa1Nxqza9xq5tBHbOtfD1VdBKQXamadOdLSikizmWTaGgeGBb0xBs)GbUbGbanybUfqFTj9dg4gaga0GbWTa6RnPFWa3aWaGgNbUfqFTj9dg4gaga04c4waDlYcudOZiEHtWO8ifaOV2K(bdCdadaATf4wa91M0pyGBa0JebpIWa0z7xZkkJib83GoIATj9d2Z7EcHNetaFwHRzLbdtvrKCZEIdpbdp1OXtIjGpRW1SYGHPkr7jE8exA5j4a6wKfOgqNYisa)nOJaWaGg3d4wa91M0pyGBa0JebpIWa0l2t2(1SIYis4SFH1S9Q1M0pyaDlYcudOJji7SFH1S9amaOXnbUfq3ISa1a6qrSa1a6RnPFWa3aWaGgNaClG(At6hmWna6rIGhrya6S9Rz1(fwZ2FKEJYQ1M0pyaDlYcudOVFH1S9hP3OmadWamGUjZ1icGUUii)glqnUdXWyagGbaa]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "battle_potion_of_intellect",
        
        package = "Elemental",
    } )
end
