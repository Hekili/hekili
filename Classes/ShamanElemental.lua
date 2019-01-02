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
        exposed_elements = not PTR and 22356 or nil, -- 260694
        earthen_rage = PTR and 22356 or nil, -- 170374
        echo_of_the_elements = 22357, -- 108283
        elemental_blast = 22358, -- 117014

        aftershock = 23108, -- 273221
        call_the_thunder = PTR and 22139 or nil, -- 260897
        totem_mastery = 23190, -- 210643

        spirit_wolf = 23162, -- 260878
        earth_shield = 23163, -- 974
        static_charge = 23164, -- 265046

        high_voltage = 19271, -- 260890
        storm_elemental = 19272, -- 192249
        liquid_magma_totem = 19273, -- 192222
        master_of_the_elements = 22139, -- 16166

        natures_guardian = 22144, -- 30884
        ancestral_guidance = 22172, -- 108281
        wind_rush_totem = 21966, -- 192077

        surge_of_power = PTR and 22145 or nil, -- 262303
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
                        expires = cast + duration
                        remains = expires - now
                        break
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
            
            spend = PTR and -25 or -15,
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
            
            usable = function () return buff.totem_mastery.remains < 15 end,
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
            
            usable = function () return debuff.casting.up end,
            handler = function ()
                interrupt()
            end,
        },
    } )

    
    spec:RegisterPack( "Elemental", 20190101.2358, [[d8KxCbqiPOEKuIUeujSjG4tqfPrbIofiSkvaVcOYSubDlPi7Iu)skPHrI6yQildOQNbKY0GkQRbvQTrIKVrIuACsjKZbvswhuL07GQezEqfUNkQ9bvXbLsOwiqYdHQeMiuLQlsIyJQavFKePyKqLuQtQcuwjq5LqvIAMsjWnHkr7ufQFcvsXqvbYsLsqpLKMQkKRsIu9vOsQglujLSxa)vLgSOdtzXOYJfAYG6YkBgkFwQmAPQtJYRHQA2Q62c2TKFdz4G0XHkILJ45inDIRJQ2UuOVlLA8aP68sbRhQsz(KW(PAGtahbOcBYaog8kFcxP8jLbVwzLvwPWn4buLgGoavOweFRBaQLfgGQs(fwj2dOc1A4rgmWraQuepjoa1ErGsXRT2Aht6550ruOvklW)MWqvKyysRuwi2k3J4ALdZAcEn2kuccJ9J26brwl0yW0wpOw4vT3cwDvYVWkXEnLfIaQC8SxoyfahGkSjd4yWR8jCLYNug8ALvwzCdELcqLcDrGJbVsbEa1Egm8kaoav4rJaQT0tL8lSsS3t1ElyLdwl9SxeOu8ART2XKEEoDefALYc8VjmufjgM0kLfITY9iUw5WSMGxJTcLGWy)OTEqK1cngmT1dQfEv7TGvxL8lSsSxtzHOdwl9emR4nsdEE6qpbVYNWvE2KNGh0WR4Uf5G5G1spXl6TQBu8Qdwl9Sjpv605jUw39lSsSxZd1tIj9J4P0BLNX(fXNvDEgrOhg1UOEkipPBEYW8C)cRe7PEAK5PffwJt7G1spBYt8oJAC)G9ujgr69uj)cRe79CLqyJQDWAPNn55bNb6E2IPXvWwfNNTzsVNQcIe8uj)cRe7Xl5jzbuJZtHfMNX(fXxdOcLGWy)auBPNk5xyLyVNQ9wWkhSw6zViqP41wBTJj98C6ik0kLf4FtyOksmmPvkleBL7rCTYHznbVgBfkbHX(rB9GiRfAmyARhul8Q2BbRUk5xyLyVMYcrhSw6jywXBKg880HEcELpHR8SjpbpOHxXDlYbZbRLEIx0Bv3O4vhSw6ztEQ0PZtCTU7xyLyVMhQNet6hXtP3kpJ9lIpR68mIqpmQDr9uqEs38KH55(fwj2t90iZtlkSgN2bRLE2KN4Dg14(b7PsmI07Ps(fwj275kHWgv7G1spBYZdod09SftJRGTkopBZKEpvfej4Ps(fwj2JxYtYcOgNNclmpJ9lIV2bZbRLEQeqFrEzWEYnmezEgrbot8KBDSIQ9SfhJdQq9Sqvt9gjGX)EArHHkQNO6Bq7GzrHHkQgkzruGZKZyVrX3bZIcdvunuYIOaNjG7CRyieSdMffgQOAOKfrbota35wn(UWkXegQCWAPNQLbL2Jepjgd2toEmSb7jvmH6j3WqK5zef4mXtU1XkQNwb7juYAcksew15jJ6jmQM2bZIcdvunuYIOaNjG7CR0YGs7rYLkMqDWSOWqfvdLSikWzc4o3QGKfUbJkJ0GdMffgQOAOKfrbota35wNrK(7(fwj2Fid7CZI9Renucly)D)cRe7zurVY4(b7G1spv605PQGib83GoINqjlIcCM4jF9Js9KIcZtdgM6zB2)EsHATlpPiuPDWSOWqfvdLSikWzc4o3kvqKa(Bqh5qg2zX(vIMkisa)nOJOxzC)GbbsIXGVRXvI2GHP6iIVeCaAkuqmg8DnUs0gmmvZk8GBLHWbZIcdvunuYIOaNjG7CRymYU7xyLy)HmSZnl2Vs0ubrc39lSsSxVY4(b7GzrHHkQgkzruGZeWDUvOiHHkhmlkmur1qjlIcCMaUZTUFHvI9xU3OYHmSZI9Re9(fwj2F5EJk6vg3pyhmhSw6Psa9f5Lb75ACKg8uyH5P0ppTOGiEYOEAnAS34(PDWAPN4fgv8eupcb)8uXZGv82)n4jdZtPFE2IXBJWK55reJjE2IR4OcXEpBHJIkRIZtg1tOKrxjAhmlkmurpZ9ie8ZtLdzyNn82imzARIJke7VKrrLvXPxzC)GDWAPNhSsgHWdv8eH5z0Ocv7GzrHHkk4o3ABwbFP9ZioywuyOIcUZTkizHBWOYinCid7Sy)krlizHBWOYinOxzC)GbHJhdttgfvwf3vqYcAYcgRO4a8oywuyOIcUZTIXi7UFHvI9hYWo3Sy)krtfejC3VWkXE9kJ7hSdMffgQOG7CRubrc39lSsS)qg2zX(vIMkis4UFHvI96vg3pyqGSzX(vIMfhgpPb9kJ7hScfnZXJHPzXHXtAqZdfKMJi0dJAxAwCy8Kg08qHWbZIcdvuWDU1zeP)UFHvI9hYWo3Sy)krdLWc2F3VWkXEgv0RmUFWkui2Vs0qjSG939lSsSNrf9kJ7hmiqgrOhg1U0ymYU7xyLyVMSGXkkoobELbPzX(vIMkis4UFHvI96vg3pyfkIi0dJAxAQGiH7(fwj2RjlySIIJtGxzqe7xjAQGiH7(fwj2RxzC)GHWbZIcdvuWDUvE6UmzbQdMffgQOG7CRCpcbFX4jnCid7CZI9ReTrJRGTko9kJ7hScfC8yyAJgxbBvCAEOkuerOhg1U0gnUc2Q40KfmwrXdUv2bZIcdvuWDUvUrOJGpR6oKHDUzX(vI2OXvWwfNELX9dwHcoEmmTrJRGTkonpuhmlkmurb35wXyKX9ie8HmSZnl2Vs0gnUc2Q40RmUFWkuWXJHPnACfSvXP5HQqreHEyu7sB04kyRIttwWyffp4wzhmlkmurb35wTkoQqS)gT)pKHDUzX(vI2OXvWwfNELX9dwHcoEmmTrJRGTkonpufkIi0dJAxAJgxbBvCAYcgRO4b3k7GzrHHkk4o3kHVUwuyO6(mQCyzHD2q7qg2zlkSg3D1cSrXd4bbsk09)vms3eQo2BS6(SUEPyvhEaVcfuO7)RyKUju9BnAxUzb8aEiCWSOWqffCNBLWxxlkmuDFgvoSSWotzv3VRyKUjoyoyT0tCj)lmpfJ0nXtlkmu5jucdrysdE(mQ4GzrHHkQ2q7mvqKa(Bqh5qg2zX(vIMkisa)nOJOxzC)GDWSOWqfvBObUZTA04kyRI7qg2zX(vI2OXvWwfNELX9dgeif7xjAQGiH7(fwj2RxzC)GbPzQGiH7(fwj2R5HcseHEyu7stfejC3VWkXEnzbJvu8Cc3ku0Sy)krtfejC3VWkXE9kJ7hmeoywuyOIQn0a35wFgoHNbFdwxWUcsw4qg2zX(vI(z4eEg8nyDb7kizb9kJ7hSdMdwl9ufkzgSNh83cZt1EueFpzLN44mo7PyKUjEIX66f6HEYXlEwiXtyEcR68uvjEYdvyHDON81pk1Zgq84uY8eJ11lSQZtqZtXiDtOEAfSN9wJZZFuQNsVvEEcN9exNvWEQ0WtfpPIfXNQDWSOWqfvBObUZTI9wyxApkI)HXgI)UIr6MqpF6qg2zYWiJ2BC)aHcD)FfJ0nHQJ9gRUpRRxkw1HdCdcKnl2Vs0ubrc39lSsSxVY4(bRqreHEyu7stfejC3VWkXEnzbJvuCCc8kRqbf6()kgPBcvh7nwDFwxVuSQ7mObchpgMUnRGVD8urtflIpooHZq4G5G1sppI0GNcYZolmpvIrKECcVH)8Snt69exAuzepryEk9ZtL8lSsOEYXJH5z7(vEIX66fw15jO5PyKUjuTN4DuHtfprnos0G6jU02tfck0SdMffgQOAdnWDU1zePhNWB4VdzyNBwSFLOdgvg5IWUs)U7xyLq1RmUFWkuWXJHPPcIeWFd6iAEOkueS9uHGc45mKNuw5MW5dqHU)VIr6Mq1XEJv3N11lfR6GqHcoEmmDWOYixe2v63D)cReQMhQcfuO7)RyKUjuDS3y19zD9sXQo8aAoyoyT0tCn13GNrJkE2cSgnpbfpHkEIkpLEYMNIr6Mq9KH5jt8Kr90kpzfvSs80kypvfej4Ps(fwj27jJ65X4AoYtlkSgN2bZIcdvuTHg4o36BnAxoEcvoKHDgsoEmm9BnAxkpPBAEOkuWXJHPnACfSvXP5HcbiuO7)RyKUjuDS3y19zD9sXQoCGZGazZI9RenvqKWD)cRe71RmUFWkuerOhg1U0ubrc39lSsSxtwWyffhNaVYq4G5G1spv605Ps(fwj27jOEJkEADgROIN8q9uqEcAEkgPBc1tJ65JQopnQNQcIe8uj)cRe79Kr9SqINwuynoTdMffgQOAdnWDU19lSsS)Y9gvoKHDwSFLO3VWkX(l3BurVY4(bdcf6()kgPBcvh7nwDFwxVuSQdh4miq2Sy)krtfejC3VWkXE9kJ7hScfre6HrTlnvqKWD)cRe71KfmwrXXjWRmeoywuyOIQn0a35wFRr7YnlCid7Sy)krB04kyRItVY4(b7GzrHHkQ2qdCNBn2BS6(SUEPyvNdMffgQOAdnWDU13A0UC8eQCya1iR6oF6qg2zX(vI2OXvWwfNELX9d2bZIcdvuTHg4o3k2BHDP9Oi(hgqnYQUZNom2q83vms3e65thYWotggz0EJ7NdMffgQOAdnWDUvmcIkxApkI)HbuJSQ78jhmhmhSw6PkR6(55rgPBINT4OWqLNheHHimPbpBbmQ4G1spvsr5jZZdUQNmQNwuynop5RFuQNnG49S3ACEEcN9er8mGiZtQyr8PEIW8exNvWEQ0WtfpXiOGNQcIe8uj)cRe71EcPsG7MNrJo8QN8qJOaR68SftJEYXlEArH148uvj4L8egv4uXtiCWSOWqfvtzv3VRyKUjNXElSlThfX)qg2ziBwyr8zvNcfI9RenvqKWD)cRe71RmUFWGerOhg1U0ubrc39lSsSxtwWyffhG)aDryfkGrIg7TWU0EueFnzbJvuCCUlcRqHy)krB04kyRItVY4(bdcms0yVf2L2JI4RjlySIIdiJi0dJAxAJgxbBvCAYcgROGJJhdtB04kyRItdZtmHHkiajIqpmQDPnACfSvXPjlySIIdCgeiBwSFLOPcIeU7xyLyVELX9dwHcX(vIMkis4UFHvI96vg3pyqIi0dJAxAQGiH7(fwj2RjlySIIJtGxziGaeoEmmDBwbF74PIMkweFCCcNbPzoEmmnLN0Tlc7cf1EenpuhmhSw6PsNopBX04kyRIZtdtgXZgq840gNNuORepT)9SfynAEckEcv8m2BKUr90kypr13GNmmpRXK(r8uvqKGNk5xyLyVNfI45blomEsdEAK5zKNqwjFdEArH140oywuyOIQPSQ73vms3eWDUvJgxbBvChYWol2Vs0gnUc2Q40RmUFWGerOhg1U0V1OD54jurtwWyffpkdcKnl2Vs0ubrc39lSsSxVY4(bRqbKntfejC3VWkXEnpuqIi0dJAxAQGiH7(fwj2RjlySIINt4gciabYMf7xjAwCy8Kg0RmUFWku0mhpgMMfhgpPbnpuqAoIqpmQDPzXHXtAqZdfchmhSw6jEhv4uXtE68uj)cRe79euVrfpzyE2aI3ZiI)H9mAuXtZtCPrLr8eH5P0ppvYVWkH65cqrThzWEQeJi9EQ2JI47jROYmyTN4DuHtfpJgv8uj)cRe79euVrfpH5jSQZtvbrcEQKFHvI9EYx)OupBaX7zV148e0aDpp2eEI9EIRTrcOQbpzLNT7zXEpJgDE2aI3tQGG6jpLvDEQKFHvI9EcQ3OINOkopBaX7jzwS3Zt4SNuXI4t9eH5jUoRG9uPHNkAhmlkmur1uw197kgPBc4o36(fwj2F5EJkhYWol2Vs07xyLy)L7nQOxzC)GbbsX(vIoyuzKlc7k97UFHvcvVY4(bdchpgMoyuzKlc7k97UFHvcvZdfKGTNkeuahkLYku0Sy)krhmQmYfHDL(D3VWkHQxzC)GHaeiBgsQGiH7(fwj2R5HcIy)krtfejC3VWkXE9kJ7hmekuy4TryY0Lj8e7V9gjGQg0eRW)mObchpgMUnRGVD8urtflIpooHZq4G5G1spXlVb1tv8YEIHiE(gPBEIiEsrOYtdg2Z2wJJQ9uPx)OupBaX7zV148uLN0npryEEqO2JCONSYZ29SyVNrJopBaX7zBRepfKNWiEUFEYXJH5zlG11lfR68euOx8KRbpHIqpR68exA7Pcbf8KByiY6Tcw7PsaDla9NN0Ht4xfhE1ZtkRmUu9qpvI6HEQIx(qpBbG6qpBbncQd9ujQh6zlauoywuyOIQPSQ73vms3eWDUvQGib83GoYHmSZI9RenvqKa(BqhrVY4(bdcKeJbFxJReTbdt1reFj4a0uOGym47ACLOnyyQMv4b3kdbiq2Sy)krt5jD7IWUqrThrVY4(bRqbhpgMMYt62fHDHIApIMhQcfbBpviOaEoJZ4meoywuyOIQPSQ73vms3eWDU1NHt4zW3G1fSRGKfoKHDwSFLOFgoHNbFdwxWUcswqVY4(bdcKeJbFxJReTbdt1reFj4a0uOGym47ACLOnyyQMv4b3kdHdMdwl9eVaf4y18uvqKa(BqhXZ2mP3tCPrLr8eH5P0ppvYVWkH6jI4PkpPBEIW88GqThr7GzrHHkQMYQUFxXiDta35wFwxVuSQ7YHE5qg2zoEmmnvqKa(BqhrZdfek09)vms3eQo2BS6(SUEPyvhoapiqYXJHPdgvg5IWUs)U7xyLq18qbPzX(vIMYt62fHDHIApIELX9dwHcoEmmnLN0Tlc7cf1EenpuiCWCWAPNh1pY8mW66fpJOW80kp5HcBY8edr8u6zupFwnpBZKEpPOW8ufDqE(Oowu7GzrHHkQMYQUFxXiDta35wNrKECcVH)oKHD2IcRXDxTaBu8Ccek09)vms3eQo2BS6(SUEPyvhEobcKnl2Vs0uEs3UiSluu7r0RmUFWku0mms0yVf2L2JI4RjdJmAVX9tHcQGiH7(fwj2R5Hcbiq2Sy)krhmQmYfHDL(D3VWkHQxzC)GvOGJhdthmQmYfHDL(D3VWkHQ5HQqrW2tfckGNZ4kWdHdMdwl9euOg0AD7Et808mIkyMWqL2tCDM07jU0OYiEIW8u6NNk5xyLq9ekc9EIlT9uHGcEYd1tb5zlYtCPTNkeuWtU9O2Ek9ZZOb1tb55kkpzEYeCk1tE6G9Snt69ujgr69uThfXx7jUot6r8IN4sJkJ4jcZtPFEQKFHvc9qp5PZtLyeP3t1EueFpht6hXtgMNQcIeWFd6iEYOEYd9qpXL2EQqqbpzuppPSN4sBpviOGNC7rT9u6NNrdQNiIN)O0d9er8CmPFepvfej4Ps(fwj27jJw4uXtX(vYG9er8Kj4uQNfs80IcRX5PvWE2aIN45BuXtvbrcEQKFHvI9EIW8u6NNySUEXZ2S)9S3ACEIQVbpnpHAeHzVNW8etyOs7GzrHHkQMYQUFxXiDta35wNrK(lThfX)qg25M54XW0uEs3UiSluu7r08qbrSFLOdgvg5IWUs)U7xyLq1RmUFWGajhpgMoyuzKlc7k97UFHvcvZdvHIGTNkeuapNXvGhCGMYhqSFLOJ2)xPFxPNVGhrVY4(bRqbhpgMMkisa)nOJO5HcIffwJ7UAb2O4a8qOqrZI9ReDWOYixe2v63D)cReQELX9dgei54XW0ubrc4VbDenpufkc2EQqqb8CgxPm4anLpGy)krhT)Vs)UspFbpIELX9dwHIMHKkis4UFHvI9AEOGi2Vs0ubrc39lSsSxVY4(bdbid0HUOm4Bef4m5(R6K(MewynfrOhg1U0ubrc39lSsSxtwWyfTPt4w5dG9iebsihOdDrzW3ikWzY9x1j9njSWAkIqpmQDPPcIeU7xyLyVMSGXkke4It4wziWZzqt5da5jWbPH3gHjtVyp6IWUs)U7xyLypvtScF8Cg8qabeoyoyT0tLoDEQeJi9EQ2JI47jdZtvEs38eH55bHApINmQNI9RKbFONC8IN1ys)iEYepleXtZt8(bP6Ps(fwj27jJ6PffwJZtt8u6NNbuyLCONwb7zlWA08eu8eQ4jJ6jzgCdEIiE2M9VNCZZ2mPNvEk9ZZAGU4PsdEbEx7GzrHHkQMYQUFxXiDta35wNrK(lThfX)qg2zX(vIMYt62fHDHIApIELX9dgKM54XW0uEs3UiSluu7r08qbjIqpmQDPFRr7YXtOIMSGXkkoo3fHbbYMf7xjAQGiH7(fwj2RxzC)GbPziXyKD3VWkXEnpuiuOqSFLOPcIeU7xyLyVELX9dgKMHKkis4UFHvI9AEOqaHdMdwl9eVWOINTawxVuSQZtqHEH6jmpHvDEQkisWtL8lSsS3tyEIjmuPDWSOWqfvtzv3VRyKUjG7CRpRRxkw1D5qVCid7mvqKWD)cRe718qbrSFLOPcIeU7xyLyVELX9d2bZbRLEQ0PZZdobrfpv7rr89Snt698GfhgpPbpTc2tCPrLr8eH5P0ppvYVWkHQDWSOWqfvtzv3VRyKUjG7CRyeevU0Eue)dzyNf7xjAwCy8Kg0RmUFWGi2Vs0bJkJCryxPF39lSsO6vg3pyq44XW0S4W4jnO5HcchpgMoyuzKlc7k97UFHvcvZd1bZIcdvunLvD)UIr6MaUZT(wJ2LJNqLdzyN54XW0gnUc2Q408qDWCWAPNkDH9m828uLN0npryEEqO2J4PG8KcLmd2Zd(BH5PApkIVNmmpd8VWG(ZZvlWg1tJmpHsgDLODWSOWqfvtzv3VRyKUjG7CRyVf2L2JI4FySH4VRyKUj0ZNoKHDMmmYO9g3pqSOWAC3vlWgfpNaHJhdtt5jD7IWUqrThrZd1bZbRLEQ0PZZwG1O5jO4juXZ2mP3tvEs38eH55bHApINmmpL(55BuXtOizLWS3tEQ1npryEAEI3pivpvYVWkXEp7nAHtfpnpX4)3tyEIjmu5jUMwONmmpBaX7zeX)WE2nXtRqs)iEYtTU5jcZtPFEI3pivpvYVWkXEpzyEk9ZtYcgRyvNNySUEXZ2g1ZtkfUWZhvDJODWSOWqfvtzv3VRyKUjG7CRV1OD54ju5qg2zX(vIMkis4UFHvI96vg3pyqIi0dJAxxYSOachpgMMYt62fHDHIApIMhkiqoqh6IYGVruGZK7VQt6BsyH1ueHEyu7stfejC3VWkXEnzbJv0MoHBLpa2JqeiHCGo0fLbFJOaNj3FvN03KWcRPic9WO2LMkis4UFHvI9AYcgROqGloHBLHahGMYhaYtGdsdVnctMEXE0fHDL(D3VWkXEQMyf(45m4HacfkG8K(KsDaihOdDrzW3ikWzY9x1j9njSWGOPic9WO2LMkis4UFHvI9AYcgROnDc3kFaShHiqc5j9jL6aqoqh6IYGVruGZK7VQt6BsyHbrtre6HrTlnvqKWD)cRe71KfmwrHaxCc3kdbe4aYb6qxug8nIcCMC)vDsFtclSMIi0dJAxAQGiH7(fwj2RjlySI20jCR8bWEeIajKd0HUOm4Bef4m5(R6K(MewynfrOhg1U0ubrc39lSsSxtwWyffcCXjCRmeqaHdMdwl9uPtNNTaRrZtqXtOINTzsVNQ8KU5jcZZdc1EepzyEk9ZZ3OINqrYkHzVN8uRBEIW808eVFqQEQKFHvI9E2B0cNkEAEIX)VNW8etyOYtCnTqpzyE2aI3ZiI)H9SBINwHK(r8KNADZteMNs)8eVFqQEQKFHvI9EYW8u6NNKfmwXQopXyD9INTnQNNukCHNpQ6gr7GzrHHkQMYQUFxXiDta35wFRr7YXtOYHmSZnl2Vs0ubrc39lSsSxVY4(bdseHEyu76sMffq44XW0uEs3UiSluu7r08qbbYb6qxug8nIcCMC)vDsFtclSMIi0dJAxAmgz39lSsSxtwWyfTPt4w5dG9iebsihOdDrzW3ikWzY9x1j9njSWAkIqpmQDPXyKD3VWkXEnzbJvuiWfNWTYqGdqt5da5jWbPH3gHjtVyp6IWUs)U7xyLypvtScF8Cg8qaHcfqEsFsPoaKd0HUOm4Bef4m5(R6K(Mewyq0ueHEyu7sJXi7UFHvI9AYcgROnDc3kFaShHiqc5j9jL6aqoqh6IYGVruGZK7VQt6BsyHbrtre6HrTlngJS7(fwj2RjlySIcbU4eUvgciWbKd0HUOm4Bef4m5(R6K(MewynfrOhg1U0ymYU7xyLyVMSGXkAtNWTYha7ricKqoqh6IYGVruGZK7VQt6BsyH1ueHEyu7sJXi7UFHvI9AYcgROqGloHBLHaciCWSOWqfvtzv3VRyKUjG7CRpRRxkw1D5qVCid7mhpgMMYt62fHDHIApIMhQdMffgQOAkR6(DfJ0nbCNB9TgTlhpHkhYWohrOhg1UUKzrXbZbRLEI3rfov80Irg8kX(Vbp5PZtvEs38eH55bHApINTzsVNh83cZt1EueFpH5jSQZtkR6(5PyKUjAhmlkmur1uw197kgPBc4o3k2BHDP9Oi(hgBi(7kgPBc98PdzyNjdJmAVX9dKM54XW0uEs3UiSluu7r08qDWSOWqfvtzv3VRyKUjG7CRcsw4gmQmsdhYWol2Vs0csw4gmQmsd6vg3pyqGKJhdttgfvwf3vqYcAYcgRO4qPuOasoEmmnzuuzvCxbjlOjlySIIdi54XW0gnUc2Q40W8etyOcCre6HrTlTrJRGTkonzbJvuiajIqpmQDPnACfSvXPjlySIIJt4gciCWCWAPNQpRRx(g8SZcZZdwCy8Kg8KJhdZtb5zpc6W4)Vbp54XW8KIcZZ2mP3tCPrLr8eH5P0ppvYVWkHQDWSOWqfvtzv3VRyKUjG7CRyeevU0Eue)dzyNf7xjAwCy8Kg0RmUFWGWXJHPzXHXtAqZdfei54XW0S4W4jnOjlySIIJUi8bW5dWXJHPzXHXtAqtflIVcfC8yyAQGib83GoIMhQcfnl2Vs0bJkJCryxPF39lSsO6vg3pyiCWSOWqfvtzv3VRyKUjG7CRS4W4jnCid7Sy)krZIdJN0GELX9d2bZIcdvunLvD)UIr6MaUZT(SUEPyv3Ld9IdMffgQOAkR6(DfJ0nbCNBf7TWU0Eue)ddOgzv35thgBi(7kgPBc98PdzyNjdJmAVX9ZbZIcdvunLvD)UIr6MaUZTI9wyxApkI)HbuJSQ78PdzyNdOgxyLOHzuXQ4WJs5G5G1spp4eev8uThfX3tg1tepXZaQXfwjEIX(FeTdMffgQOAkR6(DfJ0nbCNBfJGOYL2JI4Fya1iR6oFcqTXrOmubCm4v(ul6e4bnL1Gh84ClcqTTrkw1rbuX1BXTWJpyhR0Gx90ZJ6NNSauer8edr8eNAOHt9KmCcpJmypPOW804fuWKb7zS3QUr1oyh1ppXq)JAZQopnEIr9S9iZtE6G9KvEk9Ztlkmu55ZOINC8INThzEwiXtmeFb7jR8u6NNgmmQ8e2eJZOdV6G5ztE2MvW3oEQ4G5GHR3IBHhFWowPbV6PNh1ppzbOiI4jgI4joLYQUFxXiDtWPEsgoHNrgSNuuyEA8ckyYG9m2Bv3OAhSJ6NNyO)rTzvNNgpXOE2EK5jpDWEYkpL(5PffgQ88zuXtoEXZ2JmplK4jgIVG9KvEk9ZtdggvEcBIXz0HxDW8SjpBZk4BhpvCWCWoybOiImypXzpTOWqLNpJkuTdgGQXl9icGQklW)MWqfEbXWea1NrfkWraQuw197kgPBcWrahFc4ia1vg3pyaqbOgjmzeMbOcPNn7PWI4ZQopvOWtX(vIMkis4UFHvI96vg3pypbXZic9WO2LMkis4UFHvI9AYcgROEIdpbVNhWZUiSNku4jms0yVf2L2JI4RjlySI6joo7zxe2tfk8uSFLOnACfSvXPxzC)G9eepHrIg7TWU0EueFnzbJvupXHNq6zeHEyu7sB04kyRIttwWyf1tW5jhpgM2OXvWwfNgMNycdvEcHNG4zeHEyu7sB04kyRIttwWyf1tC4jo7jiEcPNn7Py)krtfejC3VWkXE9kJ7hSNku4Py)krtfejC3VWkXE9kJ7hSNG4zeHEyu7stfejC3VWkXEnzbJvupXHNNaVYEcHNq4jiEYXJHPBZk4Bhpv0uXI47jo88eo7jiE2SNC8yyAkpPBxe2fkQ9iAEOaQwuyOcqf7TWU0EueFab4yWdCeG6kJ7hmaOauJeMmcZauf7xjAJgxbBvC6vg3pypbXZic9WO2L(TgTlhpHkAYcgROEIhpv2tq8espB2tX(vIMkis4UFHvI96vg3pypvOWti9SzpPcIeU7xyLyVMhQNG4zeHEyu7stfejC3VWkXEnzbJvupXJNNWTNq4jeEcINq6zZEk2Vs0S4W4jnOxzC)G9uHcpB2toEmmnlomEsdAEOEcINn7zeHEyu7sZIdJN0GMhQNqaOArHHkavJgxbBvCacWXGgWraQRmUFWaGcqnsyYimdqvSFLO3VWkX(l3BurVY4(b7jiEcPNI9ReDWOYixe2v63D)cReQELX9d2tq8KJhdthmQmYfHDL(D3VWkHQ5H6jiEgS9uHGcEIdpvkL9uHcpB2tX(vIoyuzKlc7k97UFHvcvVY4(b7jeEcINq6zZEcPNubrc39lSsSxZd1tq8uSFLOPcIeU7xyLyVELX9d2ti8uHcpn82imz6YeEI93EJeqvdAIv475zpbnpbXtoEmmDBwbF74PIMkweFpXHNNWzpHaq1IcdvaQ7xyLy)L7nQaiahJZahbOUY4(bdaka1iHjJWmavX(vIMkisa)nOJOxzC)G9eepH0tIXGVRXvI2GHP6iIVepXHNGMNku4jXyW314krBWWunR8epEIBL9ecpbXti9Szpf7xjAkpPBxe2fkQ9i6vg3pypvOWtoEmmnLN0Tlc7cf1EenpupvOWZGTNkeuWt8C2tCgN9ecavlkmubOsfejG)g0raeGJXnWraQRmUFWaGcqnsyYimdqvSFLOFgoHNbFdwxWUcswqVY4(b7jiEcPNeJbFxJReTbdt1reFjEIdpbnpvOWtIXGVRXvI2GHPAw5jE8e3k7jeaQwuyOcq9z4eEg8nyDb7kizbab4yLc4ia1vg3pyaqbOgjmzeMbOYXJHPPcIeWFd6iAEOEcINuO7)RyKUjuDS3y19zD9sXQopXHNG3tq8esp54XW0bJkJCryxPF39lSsOAEOEcINn7Py)krt5jD7IWUqrThrVY4(b7PcfEYXJHPP8KUDryxOO2JO5H6jeaQwuyOcq9zD9sXQUlh6fab4yLwGJauxzC)GbafGAKWKrygGQffwJ7UAb2OEIhpp5jiEsHU)VIr6Mq1XEJv3N11lfR68epEEYtq8espB2tX(vIMYt62fHDHIApIELX9d2tfk8SzpHrIg7TWU0EueFnzyKr7nUFEQqHNubrc39lSsSxZd1ti8eepH0ZM9uSFLOdgvg5IWUs)U7xyLq1RmUFWEQqHNC8yy6GrLrUiSR0V7(fwjunpupvOWZGTNkeuWt8C2tCf49ecavlkmubOoJi94eEd)biah3IaocqDLX9dgauaQrctgHzaQn7jhpgMMYt62fHDHIApIMhQNG4Py)krhmQmYfHDL(D3VWkHQxzC)G9eepH0toEmmDWOYixe2v63D)cReQMhQNku4zW2tfck4jEo7jUc8EcopbnL98aEk2Vs0r7)R0VR0ZxWJOxzC)G9uHcp54XW0ubrc4VbDenpupbXtlkSg3D1cSr9ehEcEpHWtfk8Szpf7xj6GrLrUiSR0V7(fwju9kJ7hSNG4jKEYXJHPPcIeWFd6iAEOEQqHNbBpviOGN45SN4kL9eCEcAk75b8uSFLOJ2)xPFxPNVGhrVY4(b7PcfE2SNq6jvqKWD)cRe718q9eepf7xjAQGiH7(fwj2RxzC)G9ecpbXZb6qxug8nIcCMC)vDsVNn5PWcZZM8mIqpmQDPPcIeU7xyLyVMSGXkQNn55jCRSNhWtShHiEcPNq65aDOlkd(grbotU)QoP3ZM8uyH5ztEgrOhg1U0ubrc39lSsSxtwWyf1ti8ex45jCRSNq4jEo7jOPSNhWti98KNGZti90WBJWKPxShDryxPF39lSsSNQjwHVN45SNG3ti8ecpHaq1IcdvaQZis)L2JI4diahJRaocqDLX9dgauaQrctgHzaQI9RenLN0Tlc7cf1Ee9kJ7hSNG4zZEYXJHPP8KUDryxOO2JO5H6jiEgrOhg1U0V1OD54jurtwWyf1tCC2ZUiSNG4jKE2SNI9RenvqKWD)cRe71RmUFWEcINn7jKEIXi7UFHvI9AEOEcHNku4Py)krtfejC3VWkXE9kJ7hSNG4zZEcPNubrc39lSsSxZd1ti8ecavlkmubOoJi9xApkIpGaC8jLbocqDLX9dgauaQrctgHzaQubrc39lSsSxZd1tq8uSFLOPcIeU7xyLyVELX9dgq1IcdvaQpRRxkw1D5qVaiahF6eWraQRmUFWaGcqnsyYimdqvSFLOzXHXtAqVY4(b7jiEk2Vs0bJkJCryxPF39lSsO6vg3pypbXtoEmmnlomEsdAEOEcINC8yy6GrLrUiSR0V7(fwjunpuavlkmubOIrqu5s7rr8beGJpbEGJauxzC)GbafGAKWKrygGkhpgM2OXvWwfNMhkGQffgQauFRr7YXtOcGaC8jqd4ia1vg3pyaqbOArHHkavS3c7s7rr8buJeMmcZaujdJmAVX9Ztq80IcRXDxTaBupXJNN8eep54XW0uEs3UiSluu7r08qbuJne)DfJ0nHcC8jab44t4mWraQRmUFWaGcqnsyYimdqvSFLOPcIeU7xyLyVELX9d2tq8mIqpmQDDjZIING4jhpgMMYt62fHDHIApIMhQNG4jKEoqh6IYGVruGZK7VQt69SjpfwyE2KNre6HrTlnvqKWD)cRe71Kfmwr9SjppHBL98aEI9ieXti9esphOdDrzW3ikWzY9x1j9E2KNclmpBYZic9WO2LMkis4UFHvI9AYcgROEcHN4cppHBL9ecpXHNGMYEEapH0ZtEcopH0tdVnctMEXE0fHDL(D3VWkXEQMyf(EINZEcEpHWti8uHcpH0Zt6tkLNhWti9CGo0fLbFJOaNj3FvN07ztEkSW8ecpBYZic9WO2LMkis4UFHvI9AYcgROE2KNNWTYEEapXEeI4jKEcPNN0NukppGNq65aDOlkd(grbotU)QoP3ZM8uyH5jeE2KNre6HrTlnvqKWD)cRe71Kfmwr9ecpXfEEc3k7jeEcHN4Wti9CGo0fLbFJOaNj3FvN07ztEkSW8SjpJi0dJAxAQGiH7(fwj2RjlySI6ztEEc3k75b8e7riINq6jKEoqh6IYGVruGZK7VQt69SjpfwyE2KNre6HrTlnvqKWD)cRe71Kfmwr9ecpXfEEc3k7jeEcHNqaOArHHka13A0UC8eQaiahFc3ahbOUY4(bdaka1iHjJWma1M9uSFLOPcIeU7xyLyVELX9d2tq8mIqpmQDDjZIING4jhpgMMYt62fHDHIApIMhQNG4jKEoqh6IYGVruGZK7VQt69SjpfwyE2KNre6HrTlngJS7(fwj2RjlySI6ztEEc3k75b8e7riINq6jKEoqh6IYGVruGZK7VQt69SjpfwyE2KNre6HrTlngJS7(fwj2RjlySI6jeEIl88eUv2ti8ehEcAk75b8espp5j48espn82imz6f7rxe2v63D)cRe7PAIv47jEo7j49ecpHWtfk8esppPpPuEEapH0Zb6qxug8nIcCMC)vDsVNn5PWcZti8SjpJi0dJAxAmgz39lSsSxtwWyf1ZM88eUv2Zd4j2JqepH0ti98K(Ks55b8esphOdDrzW3ikWzY9x1j9E2KNclmpHWZM8mIqpmQDPXyKD3VWkXEnzbJvupHWtCHNNWTYEcHNq4jo8esphOdDrzW3ikWzY9x1j9E2KNclmpBYZic9WO2LgJr2D)cRe71Kfmwr9SjppHBL98aEI9ieXti9esphOdDrzW3ikWzY9x1j9E2KNclmpBYZic9WO2LgJr2D)cRe71Kfmwr9ecpXfEEc3k7jeEcHNqaOArHHka13A0UC8eQaiahFsPaocqDLX9dgauaQrctgHzaQC8yyAkpPBxe2fkQ9iAEOaQwuyOcq9zD9sXQUlh6fab44tkTahbOUY4(bdaka1iHjJWma1ic9WO21LmlkaQwuyOcq9TgTlhpHkacWXNArahbOUY4(bdakavlkmubOI9wyxApkIpGAKWKrygGkzyKr7nUFEcINn7jhpgMMYt62fHDHIApIMhkGASH4VRyKUjuGJpbiahFcxbCeG6kJ7hmaOauJeMmcZauf7xjAbjlCdgvgPb9kJ7hSNG4jKEYXJHPjJIkRI7kizbnzbJvupXHNkLNku4jKEYXJHPjJIkRI7kizbnzbJvupXHNq6jhpgM2OXvWwfNgMNycdvEcopJi0dJAxAJgxbBvCAYcgROEcHNG4zeHEyu7sB04kyRIttwWyf1tC45jC7jeEcbGQffgQaufKSWnyuzKgaeGJbVYahbOUY4(bdaka1iHjJWmavX(vIMfhgpPb9kJ7hSNG4jhpgMMfhgpPbnpupbXti9KJhdtZIdJN0GMSGXkQN4WZUiSNhWtC2Zd4jhpgMMfhgpPbnvSi(EQqHNC8yyAQGib83GoIMhQNku4zZEk2Vs0bJkJCryxPF39lSsO6vg3pypHaq1IcdvaQyeevU0EueFab4yWFc4ia1vg3pyaqbOgjmzeMbOk2Vs0S4W4jnOxzC)GbuTOWqfGklomEsdacWXGh8ahbOArHHka1N11lfR6UCOxauxzC)GbafGaCm4bnGJauxzC)GbafGQffgQauXElSlThfXhqn2q83vms3ekWXNauJeMmcZaujdJmAVX9dqnGAKvDaQNaeGJbpodCeG6kJ7hmaOauJeMmcZaudOgxyLOHzuXQ48epEQuaQwuyOcqf7TWU0EueFa1aQrw1bOEcqaog84g4ia1aQrw1bOEcq1IcdvaQyeevU0EueFa1vg3pyaqbiacGQHgWrahFc4ia1vg3pyaqbOgjmzeMbOk2Vs0ubrc4VbDe9kJ7hmGQffgQauPcIeWFd6iacWXGh4ia1vg3pyaqbOgjmzeMbOk2Vs0gnUc2Q40RmUFWEcINq6Py)krtfejC3VWkXE9kJ7hSNG4zZEsfejC3VWkXEnpupbXZic9WO2LMkis4UFHvI9AYcgROEIhppHBpvOWZM9uSFLOPcIeU7xyLyVELX9d2tiauTOWqfGQrJRGTkoab4yqd4ia1vg3pyaqbOgjmzeMbOk2Vs0pdNWZGVbRlyxbjlOxzC)GbuTOWqfG6ZWj8m4BW6c2vqYcacWX4mWraQRmUFWaGcq1IcdvaQyVf2L2JI4dOgjmzeMbOsggz0EJ7NNG4jf6()kgPBcvh7nwDFwxVuSQZtC4jU9eepH0ZM9uSFLOPcIeU7xyLyVELX9d2tfk8mIqpmQDPPcIeU7xyLyVMSGXkQN4WZtGxzpvOWtk09)vms3eQo2BS6(SUEPyvNNN9e08eep54XW0Tzf8TJNkAQyr89ehEEcN9eca1ydXFxXiDtOahFcqaog3ahbOUY4(bdaka1iHjJWma1M9uSFLOdgvg5IWUs)U7xyLq1RmUFWEQqHNC8yyAQGib83GoIMhQNku4zW2tfck4jEo7jKEEszL9SjpXzppGNuO7)RyKUjuDS3y19zD9sXQopHWtfk8KJhdthmQmYfHDL(D3VWkHQ5H6PcfEsHU)VIr6Mq1XEJv3N11lfR68epEcAaQwuyOcqDgr6Xj8g(dqaowPaocqDLX9dgauaQrctgHzaQq6jhpgM(TgTlLN0nnpupvOWtoEmmTrJRGTkonpupHWtq8KcD)FfJ0nHQJ9gRUpRRxkw15jo8eN9eepH0ZM9uSFLOPcIeU7xyLyVELX9d2tfk8mIqpmQDPPcIeU7xyLyVMSGXkQN4WZtGxzpHaq1IcdvaQV1OD54jubqaowPf4ia1vg3pyaqbOgjmzeMbOk2Vs07xyLy)L7nQOxzC)G9eepPq3)xXiDtO6yVXQ7Z66LIvDEIdpXzpbXti9Szpf7xjAQGiH7(fwj2RxzC)G9uHcpJi0dJAxAQGiH7(fwj2RjlySI6jo88e4v2tiauTOWqfG6(fwj2F5EJkacWXTiGJauxzC)GbafGAKWKrygGQy)krB04kyRItVY4(bdOArHHka13A0UCZcacWX4kGJauTOWqfGAS3y19zD9sXQoa1vg3pyaqbiahFszGJauxzC)GbafGAKWKrygGQy)krB04kyRItVY4(bdOArHHka13A0UC8eQaOgqnYQoa1tacWXNobCeG6kJ7hmaOauTOWqfGk2BHDP9Oi(aQXgI)UIr6Mqbo(eGAKWKrygGkzyKr7nUFaQbuJSQdq9eGaC8jWdCeGAa1iR6aupbOArHHkavmcIkxApkIpG6kJ7hmaOaeabqfEyg)lahbC8jGJauxzC)Gb4auJeMmcZaun82imzARIJke7VKrrLvXPxzC)GbuTOWqfGk3JqWppvaeGJbpWraQwuyOcqTnRGV0(zea1vg3pyaqbiahdAahbOUY4(bdaka1iHjJWmavX(vIwqYc3GrLrAqVY4(b7jiEYXJHPjJIkRI7kizbnzbJvupXHNGhq1IcdvaQcsw4gmQmsdacWX4mWraQRmUFWaGcqnsyYimdqTzpf7xjAQGiH7(fwj2RxzC)GbuTOWqfGkgJS7(fwj2diahJBGJauxzC)GbafGAKWKrygGQy)krtfejC3VWkXE9kJ7hSNG4jKE2SNI9RenlomEsd6vg3pypvOWZM9KJhdtZIdJN0GMhQNG4zZEgrOhg1U0S4W4jnO5H6jeaQwuyOcqLkis4UFHvI9acWXkfWraQRmUFWaCaQrctgHzaQn7Py)krdLWc2F3VWkXEgv0RmUFWEQqHNI9Renucly)D)cRe7zurVY4(b7jiEcPNre6HrTlngJS7(fwj2RjlySI6jo88e4v2tq8Szpf7xjAQGiH7(fwj2RxzC)G9uHcpJi0dJAxAQGiH7(fwj2RjlySI6jo88e4v2tq8uSFLOPcIeU7xyLyVELX9d2tiauTOWqfG6mI0F3VWkXEab4yLwGJauTOWqfGkpDxMSafqDLX9dgauacWXTiGJauxzC)GbafGAKWKrygGAZEk2Vs0gnUc2Q40RmUFWEQqHNC8yyAJgxbBvCAEOEQqHNre6HrTlTrJRGTkonzbJvupXJN4wzavlkmubOY9ie8fJN0aGaCmUc4ia1vg3pyaqbOgjmzeMbO2SNI9ReTrJRGTko9kJ7hSNku4jhpgM2OXvWwfNMhkGQffgQau5gHoc(SQdqao(KYahbOUY4(bdaka1iHjJWma1M9uSFLOnACfSvXPxzC)G9uHcp54XW0gnUc2Q408q9uHcpJi0dJAxAJgxbBvCAYcgROEIhpXTYaQwuyOcqfJrg3JqWacWXNobCeG6kJ7hmaOauJeMmcZauB2tX(vI2OXvWwfNELX9d2tfk8KJhdtB04kyRItZd1tfk8mIqpmQDPnACfSvXPjlySI6jE8e3kdOArHHkavRIJke7Vr7Fab44tGh4ia1vg3pyaqbOgjmzeMbOArH14URwGnQN4XtW7jiEcPNuO7)RyKUjuDS3y19zD9sXQopXJNG3tfk8KcD)FfJ0nHQFRr7Ynl4jE8e8EcbGQffgQauj811Icdv3Nrfa1NrLBzHbOAObiahFc0aocqDLX9dgauaQwuyOcqLWxxlkmuDFgvauFgvULfgGkLvD)UIr6MaiacGkuYIOaNjahbC8jGJauxzC)GbafGaCm4bocqDLX9dgauacWXGgWraQRmUFWaGcqaogNbocqDLX9dgauacWX4g4iavlkmubOkizHBWOYinaOUY4(bdakab4yLc4ia1vg3pyaoa1iHjJWma1M9uSFLOHsyb7V7xyLypJk6vg3pyavlkmubOoJi939lSsShqaowPf4ia1vg3pyaqbOgjmzeMbOk2Vs0ubrc4VbDe9kJ7hSNG4jKEsmg8DnUs0gmmvhr8L4jo8e08uHcpjgd(UgxjAdgMQzLN4XtCRSNqaOArHHkavQGib83GocGaCClc4ia1vg3pyaqbOgjmzeMbO2SNI9RenvqKWD)cRe71RmUFWaQwuyOcqfJr2D)cRe7beGJXvahbOArHHkavOiHHka1vg3pyaqbiahFszGJauxzC)GbafGAKWKrygGQy)krVFHvI9xU3OIELX9dgq1IcdvaQ7xyLy)L7nQaiacGaiacaaa]] )


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
