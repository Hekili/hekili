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

    
    spec:RegisterPack( "Elemental", 20181230.2248, [[d8K6BbqiPepskPUeqH2eq8jqOmkq0PGkwLukEfqQzjLQBjfzxK6xsrnmsOJPIAzaLEMuknnGIUguP2gjqFdOaghjaNtkjADKa6DafinpqW9ur2hjOdcuqluQQEiujXeHkPUijkBKev0hjrfgjqbItcvcwjq1lHkHAMKOQUjujANaj)eQeYqLsslvkj8usAQsv5QKOkFfQK0ybkqTxa)vLgSOdtzXOYJfAYG6YkBgkFwQmAv40O8AsKzRQBly3s(nKHdshheQwoINJ00jUoQA7sH(UuLXdc58sbRNevA(qv7NQbod0hGkSjdauGvXZkGZGTTkQbRI4wrCRGaQsdqhGkulQK1na1Ycdqvz)cRe7buHAn8idgOpavkINehG6HiqPkWMBUJjh8C6ik0mLf4FtyOksmmPzkleBM7rCnZHznbVgBgkbHX(rBUvjRvymyAZTAR4QEybRUk7xyLyVMYcravoE2l4cfahGkSjdauGvXZkGZGTTkQbRI4wrWubbuPqxeauGvbblG6bdgEfahGk8Ora1w7PY(fwj27P6HfSYbV1EEicuQcS5M7yYbpNoIcntzb(3egQIedtAMYcXM5EexZCywtWRXMHsqySF0MBvYAfgdM2CR2kUQhwWQRY(fwj2RPSq0bV1EIRxCbUr8STk2UNGvXZkapBYtWQOcemvao4o4T2tCLdR6gvb6G3ApBYtLhDEcg8D)cRe718q9KyYXiEkhw5z8yrLyvNNre6Hr9kQNcYt6MNmmp3VWkXEQNgzEArH140o4T2ZM8exZOg3pypvMrKdpv2VWkXEpxje2OAavOeeg7hGAR9uz)cRe79u9Wcw5G3Appebkvb2CZDm5GNthrHMPSa)BcdvrIHjntzHyZCpIRzomRj41yZqjim2pAZTkzTcJbtBUvBfx1dly1vz)cRe71uwi6G3ApX1lUa3iE2wfB3tWQ4zfGNn5jyvubcMkahCh8w7jUYHvDJQaDWBTNn5PYJopbd(UFHvI9AEOEsm5yepLdR8mESOsSQZZic9WOEf1tb5jDZtgMN7xyLyp1tJmpTOWACAh8w7ztEIRzuJ7hSNkZiYHNk7xyLyVNRecBuTdUdER9uzq0I8YG9KByiY8mIcCM4j36yfv7jyymoOc1ZcvnDyKag)7PffgQOEIQVbTdUffgQOAOKfrbotoH9gvjhClkmur1qjlIcCMa6tnJHqWo4wuyOIQHswef4mb0NA247cRetyOYbV1EQwgu6bs8Kymyp54XWgSNuXeQNCddrMNruGZep5whROEAfSNqjRjOiryvNNmQNWOAAhClkmur1qjlIcCMa6tntldk9ajxQyc1b3IcdvunuYIOaNjG(uZcsw4gmQmsdo4wuyOIQHswef4mb0NAEgroU7xyLyF7mStTi2Vs0qjSG939lSsSNrf9kJ7hSdER9u5rNNQcIeuAd6iEcLSikWzIN81pk1tkkmpnyyQN9y)7jfQ1R8KIqL2b3IcdvunuYIOaNjG(uZubrckTbDK2zyNe7xjAQGibL2GoIELX9dgeijgd(UgxjAdgMQJi(sGqBXJNym47ACLOnyyQMvke3kIJdUffgQOAOKfrbota9PMXyKD3VWkX(2zyNArSFLOPcIeU7xyLyVELX9d2b3IcdvunuYIOaNjG(uZqrcdvo4wuyOIQHswef4mb0NAE)cRe7VCVrL2zyNe7xj69lSsS)Y9gv0RmUFWo4o4T2tLbrlYld2Z14in4PWcZt5yEArbr8Kr90A0yVX9t7G3ApXvmQ4z)pcb)8uXZGv82)n4jdZt5yEcgQChHjZZ(igt8emSIJke79SvmkQSkopzupHsgDLODWTOWqf9e3JqWppvANHDYuUJWKPTkoQqS)sgfvwfNELX9d2bV1EIluYieEOINimpJgvOAhClkmurb9PM7Xk4l9ygXb3IcdvuqFQzbjlCdgvgPH2zyNe7xjAbjlCdgvgPb9kJ7hmiC8yyAYOOYQ4UcswqtwWyffcG1b3IcdvuqFQzmgz39lSsSVDg2Pwe7xjAQGiH7(fwj2RxzC)GDWTOWqff0NAMkis4UFHvI9TZWoj2Vs0ubrc39lSsSxVY4(bdcKTi2Vs0S4W4jnOxzC)GXJVfoEmmnlomEsdAEOG0seHEyuVsZIdJN0GMhkoo4wuyOIc6tnpJih39lSsSVDg2Pwe7xjAOewW(7(fwj2ZOIELX9dgpEX(vIgkHfS)UFHvI9mQOxzC)GbbYic9WOELgJr2D)cRe71KfmwrHWzWQiiTi2Vs0ubrc39lSsSxVY4(bJhFeHEyuVstfejC3VWkXEnzbJvuiCgSkcIy)krtfejC3VWkXE9kJ7hmoo4wuyOIc6tnZt3LjlqDWTOWqff0NAM7ri4lgpPH2zyNArSFLOnACfSvXPxzC)GXJNJhdtB04kyRItZdfp(ic9WOEL2OXvWwfNMSGXkQcXTIo4wuyOIc6tnZncDeLyvx7mStTi2Vs0gnUc2Q40RmUFW4XZXJHPnACfSvXP5H6GBrHHkkOp1mgJmUhHGBNHDQfX(vI2OXvWwfNELX9dgpEoEmmTrJRGTkonpu84Ji0dJ6vAJgxbBvCAYcgROke3k6GBrHHkkOp1SvXrfI93O9F7mStTi2Vs0gnUc2Q40RmUFW4XZXJHPnACfSvXP5HIhFeHEyuVsB04kyRIttwWyfvH4wrhClkmurb9PMj811Icdv3NrL2llStgATZWozrH14URwGnQcbliqsHU)VIr6Mq1XdJv3N1DifR6uiyXJNcD)FfJ0nHQFRr7YnlOqWIJdUffgQOG(uZe(6ArHHQ7ZOs7Lf2jkR6(DfJ0nXb3bV1EIl5FH5PyKUjEArHHkpHsyictAWZNrfhClkmur1gANOcIeuAd6iTZWoj2Vs0ubrckTbDe9kJ7hSdUffgQOAdnqFQzJgxbBvCTZWoj2Vs0gnUc2Q40RmUFWGaPy)krtfejC3VWkXE9kJ7hmire6Hr9knvqKWD)cRe71KfmwrHWzWQiire6Hr9knvqKWD)cRe71Kfmwrv4zCJhFlI9RenvqKWD)cRe71RmUFW44GBrHHkQ2qd0NA(zqCEg8nyDb7kizH2zyNe7xj6NbX5zW3G1fSRGKf0RmUFWo4o4T2tvOKzWEQC(wyEQEGIk5jR8ecNatpfJ0nXtmw3HqB3toEXZcjEcZtyvNNQkZtEOclS29KV(rPE2aIhIrMNySUdHvDE2wpfJ0nH6PvWEEynop)rPEkhw55zW0tCvwb7PYbpv8KkwujQ2b3IcdvuTHgOp1m2BHDPhOOsThBi(7kgPBc9052zyNidJm6HX9dek09)vms3eQoEyS6(SUdPyvheWniq2Iy)krtfejC3VWkXE9kJ7hmE8re6Hr9knvqKWD)cRe71KfmwrHWzWQiE8uO7)RyKUjuD8Wy19zDhsXQUtTfeoEmmDpwbF74PIMkwujiCgmXXb3bV1E2hPbpfKNDwyEQmJihqCEtP5zpMC4jU0OYiEIW8uoMNk7xyLq9KJhdZZEhR8eJ1DiSQZZ26PyKUjuTN4AubXeprnos0G6jU02tfck0IdUffgQOAdnqFQ5ze5aIZBkT2zyNArSFLOdgvg5IWUYXU7xyLq1RmUFW4XZXJHPPcIeuAd6iAEO4XhS9uHGck8eKNvuXMaZ2qHU)VIr6Mq1XdJv3N1DifR6WbpEoEmmDWOYixe2vo2D)cReQMhkE8uO7)RyKUjuD8Wy19zDhsXQof2whCh8w7jUO6BWZOrfpv(wJMN9ZtOINOYt5GS5PyKUjupzyEYepzupTYtwrfRepTc2tvbrcEQSFHvI9EYOEckCr95PffwJt7GBrHHkQ2qd0NA(TgTlhpHkTZWobjhpgM(TgTlLN0nnpu8454XW0gnUc2Q408qXbek09)vms3eQoEyS6(SUdPyvheatqGSfX(vIMkis4UFHvI96vg3py84Ji0dJ6vAQGiH7(fwj2RjlySIcHZGvrCCWDWBTNkp68uz)cRe79S)3OINwNXkQ4jpupfKNT1tXiDtOEAupFu15Pr9uvqKGNk7xyLyVNmQNfs80IcRXPDWTOWqfvBOb6tnVFHvI9xU3Os7mStI9Re9(fwj2F5EJk6vg3pyqOq3)xXiDtO64HXQ7Z6oKIvDqambbYwe7xjAQGiH7(fwj2RxzC)GXJpIqpmQxPPcIeU7xyLyVMSGXkkeodwfXXb3IcdvuTHgOp18BnAxUzH2zyNe7xjAJgxbBvC6vg3pyhClkmur1gAG(uZXdJv3N1DifR6CWTOWqfvBOb6tn)wJ2LJNqL2dOgzv3PZTZWoj2Vs0gnUc2Q40RmUFWo4wuyOIQn0a9PMXElSl9afvQ9aQrw1D6C7XgI)UIr6MqpDUDg2jYWiJEyC)CWTOWqfvBOb6tnJrqu5spqrLApGAKvDNo7G7G7G3Apvzv3pp7ZiDt8emmkmu5zRsyictAWtLpJko4T2tLvuEY8u5u1tg1tlkSgNN81pk1Zgq8EEynoppdMEIiEgqK5jvSOsupryEIRYkypvo4PINyeuWtvbrcEQSFHvI9ApHuzWDZZOrNc0tEOruGvDEcgsJEYXlEArH148uvzGb1tyubXepXXb3IcdvunLvD)UIr6MCc7TWU0duuP2zyNGSfHfvIvD4Xl2Vs0ubrc39lSsSxVY4(bdseHEyuVstfejC3VWkXEnzbJvuia220fHXJhgjAS3c7spqrL0KfmwrHWPUimE8I9ReTrJRGTko9kJ7hmiWirJ9wyx6bkQKMSGXkkeGmIqpmQxPnACfSvXPjlySIcAoEmmTrJRGTkonmpXegQWbKic9WOEL2OXvWwfNMSGXkkeatqGSfX(vIMkis4UFHvI96vg3py84f7xjAQGiH7(fwj2RxzC)GbjIqpmQxPPcIeU7xyLyVMSGXkkeodwfXbhq44XW09yf8TJNkAQyrLGWzWeKw44XW0uEs3UiSluuVr08qDWDWBTNkp68emKgxbBvCEAyYiE2aIhI148KcDL4P9VNkFRrZZ(5juXZ4Hr6g1tRG9evFdEYW8SgtogXtvbrcEQSFHvI9EwiIN4cXHXtAWtJmpJ8eYk5BWtlkSgN2b3IcdvunLvD)UIr6Ma6tnB04kyRIRDg2jX(vI2OXvWwfNELX9dgeifwyk8KcQiE8C8yyAUhHGFEQO5HIdire6Hr9k9BnAxoEcv0KfmwrvOIGazlI9RenvqKWD)cRe71RmUFW4XtfejC3VWkXEnpuCabYwe7xjAwCy8Kg0RmUFW4X3chpgMMfhgpPbnpuqAjIqpmQxPzXHXtAqZdfhhCh8w7jUgvqmXtE68uz)cRe79S)3OINmmpBaX7zeX)WEgnQ4P5jU0OYiEIW8uoMNk7xyLq9CbOOEJmypvMrKdpvpqrL8KvuzgS2tCnQGyINrJkEQSFHvI9E2)BuXtyEcR68uvqKGNk7xyLyVN81pk1Zgq8EEynopBle5jOmHNyVNGbXibu1GNSYZEhS4HNrJopBaX7jvqq9KNYQopv2VWkXEp7)nQ4jQIZZgq8EsMfp88my6jvSOsupryEIRYkypvo4PI2b3IcdvunLvD)UIr6Ma6tnVFHvI9xU3Os7mStI9Re9(fwj2F5EJk6vg3pyqGuSFLOdgvg5IWUYXU7xyLq1RmUFWGWXJHPdgvg5IWUYXU7xyLq18qbjy7PcbfGGcQiE8Ti2Vs0bJkJCryx5y39lSsO6vg3pyCabYwGKkis4UFHvI9AEOGi2Vs0ubrc39lSsSxVY4(bJdE8MYDeMmDzcpX(7HrcOQbnXkLo1wq44XW09yf8TJNkAQyrLGWzWehhCh8w7jU4nOEQIl2tmeXZ3iDZteXtkcvEAWWE2ZACuTNkV6hL6zdiEppSgNNQ8KU5jcZZwf1BK29KvE27Gfp8mA05zdiEp7zL4PG8egXZ9ZtoEmmpv(SUdPyvNN9JEXtUg8ekc9SQZtCPTNkeuWtUHHi7WkyTNkdISa0FEsheNFvCkqppROI4s129uzQT7PkU429u53F7EQ8BS)29uzQT7PYVFhClkmur1uw197kgPBcOp1mvqKGsBqhPDg2jX(vIMkisqPnOJOxzC)GbbsIXGVRXvI2GHP6iIVei0w84jgd(UgxjAdgMQzLcXTI4acKTi2Vs0uEs3UiSluuVr0RmUFW4XZXJHPP8KUDryxOOEJO5HIhFW2tfckOWtGjyIJdUffgQOAkR6(DfJ0nb0NA(zqCEg8nyDb7kizH2zyNe7xj6NbX5zW3G1fSRGKf0RmUFWGajXyW314krBWWuDeXxceAlE8eJbFxJReTbdt1SsH4wrCCWDWBTN4kOahRMNQcIeuAd6iE2JjhEIlnQmINimpLJ5PY(fwjuprepv5jDZteMNTkQ3iAhClkmur1uw197kgPBcOp18Z6oKIvDxo0lTZWoXXJHPPcIeuAd6iAEOGqHU)VIr6Mq1XdJv3N1DifR6GaybbsoEmmDWOYixe2vo2D)cReQMhkiTi2Vs0uEs3UiSluuVr0RmUFW4XZXJHPP8KUDryxOOEJO5HIJdUdER9SVJrMNbw3H4zefMNw5jpuytMNyiINYbJ65ZQ5zpMC4jffMNQOw1Zh1XIAhClkmur1uw197kgPBcOp18mICaX5nLw7mStwuynU7QfyJQWZGqHU)VIr6Mq1XdJv3N1DifR6u4zqGSfX(vIMYt62fHDHI6nIELX9dgp(wGrIg7TWU0duujnzyKrpmUF4XtfejC3VWkXEnpuCabYwe7xj6GrLrUiSRCS7(fwju9kJ7hmE8C8yy6GrLrUiSRCS7(fwjunpu84d2EQqqbfEQvcwCCWDWBTN9JAqR19omXtZZiQGzcdvApXvzYHN4sJkJ4jcZt5yEQSFHvc1tOi07jU02tfck4jpupfKNkapXL2EQqqbp52J65PCmpJgupfKNRO8K5jtGyup5Pd2ZEm5WtLze5Wt1duujTN4Qm5aXlEIlnQmINimpLJ5PY(fwj029KNopvMrKdpvpqrL8Cm5yepzyEQkisqPnOJ4jJ6jp029exA7Pcbf8Kr98SIEIlT9uHGcEYTh1Zt5yEgnOEIiE(JsB3teXZXKJr8uvqKGNk7xyLyVNmAbXepf7xjd2teXtMaXOEwiXtlkSgNNwb7zdiEINVrfpvfej4PY(fwj27jcZt5yEIX6oep7X(3ZdRX5jQ(g808eQreM9EcZtmHHkTdUffgQOAkR6(DfJ0nb0NAEgroU0duuP2zyNAHJhdtt5jD7IWUqr9grZdfeX(vIoyuzKlc7kh7UFHvcvVY4(bdcKC8yy6GrLrUiSRCS7(fwjunpu84d2EQqqbfEQvcwq3wfBJy)krhT)VYXUYbFbpIELX9dgpEoEmmnvqKGsBqhrZdfelkSg3D1cSrHayXbp(we7xj6GrLrUiSRCS7(fwju9kJ7hmiqYXJHPPcIeuAd6iAEO4XhS9uHGck8uRurq3wfBJy)krhT)VYXUYbFbpIELX9dgp(wGKkis4UFHvI9AEOGi2Vs0ubrc39lSsSxVY4(bJdidIGUOm4Bef4m5(R6KJMewynfrOhg1R0ubrc39lSsSxtwWyfTPZ4wX2G9iebsihebDrzW3ikWzY9x1jhnjSWAkIqpmQxPPcIeU7xyLyVMSGXkkoGXZ4wrCu4P2QyBG8mOH0uUJWKPx8aDryx5y39lSsSNQjwPKcpbwCWbhhCh8w7PYJopvMrKdpvpqrL8KH5PkpPBEIW8Svr9gXtg1tX(vYGB3toEXZAm5yepzINfI4P5jUUvv9uz)cRe79Kr90IcRX5PjEkhZZakSsA3tRG9u5BnAE2ppHkEYOEsMb3GNiIN9y)7j38ShtoyLNYX8SgejEQCGRGR1o4wuyOIQPSQ73vms3eqFQ5ze54spqrLANHDsSFLOP8KUDryxOOEJOxzC)GbPfoEmmnLN0Tlc7cf1BenpuqIi0dJ6v63A0UC8eQOjlySIcHtDryqGSfX(vIMkis4UFHvI96vg3pyqAbsmgz39lSsSxZdfh84f7xjAQGiH7(fwj2RxzC)GbPfiPcIeU7xyLyVMhko44G7G3ApXvmQ4PYN1DifR68SF0lupH5jSQZtvbrcEQSFHvI9EcZtmHHkTdUffgQOAkR6(DfJ0nb0NA(zDhsXQUlh6L2zyNOcIeU7xyLyVMhkiI9RenvqKWD)cRe71RmUFWo4o4T2tLhDEQCsquXt1duujp7XKdpXfIdJN0GNwb7jU0OYiEIW8uoMNk7xyLq1o4wuyOIQPSQ73vms3eqFQzmcIkx6bkQu7mStI9RenlomEsd6vg3pyqe7xj6GrLrUiSRCS7(fwju9kJ7hmiC8yyAwCy8Kg08qbHJhdthmQmYfHDLJD3VWkHQ5H6GBrHHkQMYQUFxXiDta9PMFRr7YXtOs7mStC8yyAJgxbBvCAEOo4o4T2tLNWEMYDEQYt6MNimpBvuVr8uqEsHsMb7PY5BH5P6bkQKNmmpd8VWG(ZZvlWg1tJmpHsgDLODWTOWqfvtzv3VRyKUjG(uZyVf2LEGIk1ESH4VRyKUj0tNBNHDImmYOhg3pqSOWAC3vlWgvHNbHJhdtt5jD7IWUqr9grZd1b3bV1EQ8OZtLV1O5z)8eQ4zpMC4PkpPBEIW8Svr9gXtgMNYX88nQ4juKSsy27jp16MNimpnpX1TQQNk7xyLyVNhgTGyINMNy8)7jmpXegQ8exuRWtgMNnG49mI4Fyp7M4Pvi5yep5Pw38eH5PCmpX1TQQNk7xyLyVNmmpLJ5jzbJvSQZtmw3H4zpJ65zfem65JQUr0o4wuyOIQPSQ73vms3eqFQ53A0UC8eQ0od7Ky)krtfejC3VWkXE9kJ7hmire6Hr9QlzwuaHJhdtt5jD7IWUqr9grZdfeihebDrzW3ikWzY9x1jhnjSWAkIqpmQxPPcIeU7xyLyVMSGXkAtNXTITb7ricKqoic6IYGVruGZK7VQtoAsyH1ueHEyuVstfejC3VWkXEnzbJvuCaJNXTI4aH2QyBG8mOH0uUJWKPx8aDryx5y39lSsSNQjwPKcpbwCWbpEipRpRGTbYbrqxug8nIcCMC)vDYrtclmCAkIqpmQxPPcIeU7xyLyVMSGXkAtNXTITb7ricKqEwFwbBdKdIGUOm4Bef4m5(R6KJMewy40ueHEyuVstfejC3VWkXEnzbJvuCaJNXTI4GdeGCqe0fLbFJOaNj3FvNC0KWcRPic9WOELMkis4UFHvI9AYcgROnDg3k2gShHiqc5GiOlkd(grbotU)Qo5OjHfwtre6Hr9knvqKWD)cRe71KfmwrXbmEg3kIdo44G7G3ApvE05PY3A08SFEcv8Shto8uLN0npryE2QOEJ4jdZt5yE(gv8ekswjm79KNADZteMNMN46wv1tL9lSsS3ZdJwqmXtZtm()9eMNycdvEIlQv4jdZZgq8Egr8pSNDt80kKCmIN8uRBEIW8uoMN46wv1tL9lSsS3tgMNYX8KSGXkw15jgR7q8SNr98Sccg98rv3iAhClkmur1uw197kgPBcOp18BnAxoEcvANHDQfX(vIMkis4UFHvI96vg3pyqIi0dJ6vxYSOachpgMMYt62fHDHI6nIMhkiqoic6IYGVruGZK7VQtoAsyH1ueHEyuVsJXi7UFHvI9AYcgROnDg3k2gShHiqc5GiOlkd(grbotU)Qo5OjHfwtre6Hr9kngJS7(fwj2RjlySIIdy8mUvehi0wfBdKNbnKMYDeMm9IhOlc7kh7UFHvI9unXkLu4jWIdo4Xd5z9zfSnqoic6IYGVruGZK7VQtoAsyHHttre6Hr9kngJS7(fwj2RjlySI20zCRyBWEeIajKN1NvW2a5GiOlkd(grbotU)Qo5OjHfgonfrOhg1R0ymYU7xyLyVMSGXkkoGXZ4wrCWbcqoic6IYGVruGZK7VQtoAsyH1ueHEyuVsJXi7UFHvI9AYcgROnDg3k2gShHiqc5GiOlkd(grbotU)Qo5OjHfwtre6Hr9kngJS7(fwj2RjlySIIdy8mUvehCWXb3IcdvunLvD)UIr6Ma6tn)SUdPyv3Ld9s7mStC8yyAkpPBxe2fkQ3iAEOo4wuyOIQPSQ73vms3eqFQ53A0UC8eQ0od7ueHEyuV6sMffhCh8w7jUgvqmXtlgzWRe7)g8KNopv5jDZteMNTkQ3iE2JjhEQC(wyEQEGIk5jmpHvDEszv3ppfJ0nr7GBrHHkQMYQUFxXiDta9PMXElSl9afvQ9ydXFxXiDtONo3od7ezyKrpmUFG0chpgMMYt62fHDHI6nIMhQdUffgQOAkR6(DfJ0nb0NAwqYc3GrLrAODg2jX(vIwqYc3GrLrAqVY4(bdcKC8yyAYOOYQ4UcswqtwWyffckiE8qYXJHPjJIkRI7kizbnzbJvuiajhpgM2OXvWwfNgMNycdvGoIqpmQxPnACfSvXPjlySIIdire6Hr9kTrJRGTkonzbJvuiCg34GJdUdER9u9zDhY3GNDwyEIlehgpPbp54XW8uqEEGGom()BWtoEmmpPOW8Shto8exAuzepryEkhZtL9lSsOAhClkmur1uw197kgPBcOp1mgbrLl9afvQDg2jX(vIMfhgpPb9kJ7hmiC8yyAwCy8Kg08qbbsoEmmnlomEsdAYcgROqOlc3gWSnC8yyAwCy8Kg0uXIkHhphpgMMkisqPnOJO5HIhFlI9ReDWOYixe2vo2D)cReQELX9dghhClkmur1uw197kgPBcOp1mlomEsdTZWoj2Vs0S4W4jnOxzC)GDWTOWqfvtzv3VRyKUjG(uZpR7qkw1D5qV4GBrHHkQMYQUFxXiDta9PMXElSl9afvQ9aQrw1D6C7XgI)UIr6MqpDUDg2jYWiJEyC)CWTOWqfvtzv3VRyKUjG(uZyVf2LEGIk1Ea1iR6oDUDg2PaQXfwjAygvSkofQGo4o4T2tLtcIkEQEGIk5jJ6jIN4za14cRepXy)pI2b3IcdvunLvD)UIr6Ma6tnJrqu5spqrLApGAKvDNodO24iugQaafyv8Sc4mypFwdwWIBWaaQ9msXQokGkUkyyRau4cGs5qb6PN9DmpzbOiI4jgI4jeZqdI5jzqCEgzWEsrH5PXlOGjd2Z4HvDJQDW77yEIH(h1JvDEA8eJ6zVrMN80b7jR8uoMNwuyOYZNrfp54fp7nY8SqINyi(c2tw5PCmpnyyu5jSjgNrNc0b3ZM8ShRGVD8uXb3bhxfmSvakCbqPCOa90Z(oMNSauer8edr8eIrzv3VRyKUjqmpjdIZZid2tkkmpnEbfmzWEgpSQBuTdEFhZtm0)OESQZtJNyup7nY8KNoypzLNYX80IcdvE(mQ4jhV4zVrMNfs8edXxWEYkpLJ5PbdJkpHnX4m6uGo4E2KN9yf8TJNko4o44cbOiImypbtpTOWqLNpJkuTdoGQXlhicGQklW)MWqfUcXWea1NrfkqFaQuw197kgPBcqFaG6mqFaQRmUFWa9dOgjmzeMbOcPNT4PWIkXQopXJ3tX(vIMkis4UFHvI96vg3pypbXZic9WOELMkis4UFHvI9AYcgROEcbpbRNTXZUiSN4X7jms0yVf2LEGIkPjlySI6jeo5zxe2t849uSFLOnACfSvXPxzC)G9eepHrIg7TWU0duujnzbJvupHGNq6zeHEyuVsB04kyRIttwWyf1tq7jhpgM2OXvWwfNgMNycdvEIJNG4zeHEyuVsB04kyRIttwWyf1ti4jy6jiEcPNT4Py)krtfejC3VWkXE9kJ7hSN4X7Py)krtfejC3VWkXE9kJ7hSNG4zeHEyuVstfejC3VWkXEnzbJvupHGNNbRIEIJN44jiEYXJHP7Xk4Bhpv0uXIk5je88my6jiE2INC8yyAkpPBxe2fkQ3iAEOaQwuyOcqf7TWU0duujabauGfOpa1vg3pyG(buJeMmcZauf7xjAJgxbBvC6vg3pypbXti9uyH5Pcp5PcQON4X7jhpgMM7ri4NNkAEOEIJNG4zeHEyuVs)wJ2LJNqfnzbJvupvONk6jiEcPNT4Py)krtfejC3VWkXE9kJ7hSN4X7jvqKWD)cRe718q9ehpbXti9Sfpf7xjAwCy8Kg0RmUFWEIhVNT4jhpgMMfhgpPbnpupbXZw8mIqpmQxPzXHXtAqZd1tCauTOWqfGQrJRGTkoabauTfOpa1vg3pyG(buJeMmcZauf7xj69lSsS)Y9gv0RmUFWEcINq6Py)krhmQmYfHDLJD3VWkHQxzC)G9eep54XW0bJkJCryx5y39lSsOAEOEcINbBpviOGNqWtfurpXJ3Zw8uSFLOdgvg5IWUYXU7xyLq1RmUFWEIJNG4jKE2INq6jvqKWD)cRe718q9eepf7xjAQGiH7(fwj2RxzC)G9ehpXJ3tt5octMUmHNy)9Wibu1GMyLsEEYZ26jiEYXJHP7Xk4Bhpv0uXIk5je88my6joaQwuyOcqD)cRe7VCVrfabauGjqFaQRmUFWa9dOgjmzeMbOk2Vs0ubrckTbDe9kJ7hSNG4jKEsmg8DnUs0gmmvhr8L4je8STEIhVNeJbFxJReTbdt1SYtf6jUv0tC8eepH0Zw8uSFLOP8KUDryxOOEJOxzC)G9epEp54XW0uEs3UiSluuVr08q9epEpd2EQqqbpv4jpbtW0tCauTOWqfGkvqKGsBqhbqaafUb6dqDLX9dgOFa1iHjJWmavX(vI(zqCEg8nyDb7kizb9kJ7hSNG4jKEsmg8DnUs0gmmvhr8L4je8STEIhVNeJbFxJReTbdt1SYtf6jUv0tCauTOWqfG6ZG48m4BW6c2vqYcacaOuqG(auxzC)Gb6hqnsyYimdqLJhdttfejO0g0r08q9eepPq3)xXiDtO64HXQ7Z6oKIvDEcbpbRNG4jKEYXJHPdgvg5IWUYXU7xyLq18q9eepBXtX(vIMYt62fHDHI6nIELX9d2t849KJhdtt5jD7IWUqr9grZd1tCauTOWqfG6Z6oKIvDxo0lacaOada0hG6kJ7hmq)aQrctgHzaQwuynU7QfyJ6Pc98SNG4jf6()kgPBcvhpmwDFw3HuSQZtf65zpbXti9Sfpf7xjAkpPBxe2fkQ3i6vg3pypXJ3Zw8egjAS3c7spqrL0KHrg9W4(5jE8EsfejC3VWkXEnpupXXtq8espBXtX(vIoyuzKlc7kh7UFHvcvVY4(b7jE8EYXJHPdgvg5IWUYXU7xyLq18q9epEpd2EQqqbpv4jpBLG1tCauTOWqfG6mICaX5nLgGaakfaqFaQRmUFWa9dOgjmzeMbO2INC8yyAkpPBxe2fkQ3iAEOEcINI9ReDWOYixe2vo2D)cReQELX9d2tq8esp54XW0bJkJCryx5y39lSsOAEOEIhVNbBpviOGNk8KNTsW6jO9STk6zB8uSFLOJ2)x5yx5GVGhrVY4(b7jE8EYXJHPPcIeuAd6iAEOEcINwuynU7QfyJ6je8eSEIJN4X7zlEk2Vs0bJkJCryx5y39lSsO6vg3pypbXti9KJhdttfejO0g0r08q9epEpd2EQqqbpv4jpBLk6jO9STk6zB8uSFLOJ2)x5yx5GVGhrVY4(b7jE8E2INq6jvqKWD)cRe718q9eepf7xjAQGiH7(fwj2RxzC)G9ehpbXZbrqxug8nIcCMC)vDYHNn5PWcZZM8mIqpmQxPPcIeU7xyLyVMSGXkQNn55zCRONTXtShHiEcPNq65GiOlkd(grbotU)Qo5WZM8uyH5ztEgrOhg1R0ubrc39lSsSxtwWyf1tC8em65zCRON44Pcp5zBv0Z24jKEE2tq7jKEAk3ryY0lEGUiSRCS7(fwj2t1eRuYtfEYtW6joEIJN4aOArHHka1ze54spqrLaeaq1kb6dqDLX9dgOFa1iHjJWmavX(vIMYt62fHDHI6nIELX9d2tq8Sfp54XW0uEs3UiSluuVr08q9eepJi0dJ6v63A0UC8eQOjlySI6jeo5zxe2tq8espBXtX(vIMkis4UFHvI96vg3pypbXZw8espXyKD3VWkXEnpupXXt849uSFLOPcIeU7xyLyVELX9d2tq8SfpH0tQGiH7(fwj2R5H6joEIdGQffgQauNrKJl9afvcqaa1zfb6dqDLX9dgOFa1iHjJWmavQGiH7(fwj2R5H6jiEk2Vs0ubrc39lSsSxVY4(bdOArHHka1N1DifR6UCOxaeaqD(mqFaQRmUFWa9dOgjmzeMbOk2Vs0S4W4jnOxzC)G9eepf7xj6GrLrUiSRCS7(fwju9kJ7hSNG4jhpgMMfhgpPbnpupbXtoEmmDWOYixe2vo2D)cReQMhkGQffgQauXiiQCPhOOsacaOodwG(auxzC)Gb6hqnsyYimdqLJhdtB04kyRItZdfq1IcdvaQV1OD54jubqaa152c0hG6kJ7hmq)aQwuyOcqf7TWU0duuja1iHjJWmavYWiJEyC)8eepTOWAC3vlWg1tf65zpbXtoEmmnLN0Tlc7cf1Benpua1ydXFxXiDtOaG6mGaaQZGjqFaQRmUFWa9dOgjmzeMbOk2Vs0ubrc39lSsSxVY4(b7jiEgrOhg1RUKzrXtq8KJhdtt5jD7IWUqr9grZd1tq8esphebDrzW3ikWzY9x1jhE2KNclmpBYZic9WOELMkis4UFHvI9AYcgROE2KNNXTIE2gpXEeI4jKEcPNdIGUOm4Bef4m5(R6KdpBYtHfMNn5zeHEyuVstfejC3VWkXEnzbJvupXXtWONNXTIEIJNqWZ2QONTXti98SNG2ti90uUJWKPx8aDryx5y39lSsSNQjwPKNk8KNG1tC8ehpXJ3ti98S(Sc6zB8esphebDrzW3ikWzY9x1jhE2KNclmpXXZM8mIqpmQxPPcIeU7xyLyVMSGXkQNn55zCRONTXtShHiEcPNq65z9zf0Z24jKEoic6IYGVruGZK7VQto8SjpfwyEIJNn5zeHEyuVstfejC3VWkXEnzbJvupXXtWONNXTIEIJN44je8esphebDrzW3ikWzY9x1jhE2KNclmpBYZic9WOELMkis4UFHvI9AYcgROE2KNNXTIE2gpXEeI4jKEcPNdIGUOm4Bef4m5(R6KdpBYtHfMNn5zeHEyuVstfejC3VWkXEnzbJvupXXtWONNXTIEIJN44joaQwuyOcq9TgTlhpHkacaOoJBG(auxzC)Gb6hqnsyYimdqTfpf7xjAQGiH7(fwj2RxzC)G9eepJi0dJ6vxYSO4jiEYXJHPP8KUDryxOOEJO5H6jiEcPNdIGUOm4Bef4m5(R6KdpBYtHfMNn5zeHEyuVsJXi7UFHvI9AYcgROE2KNNXTIE2gpXEeI4jKEcPNdIGUOm4Bef4m5(R6KdpBYtHfMNn5zeHEyuVsJXi7UFHvI9AYcgROEIJNGrppJBf9ehpHGNTvrpBJNq65zpbTNq6PPChHjtV4b6IWUYXU7xyLypvtSsjpv4jpbRN44joEIhVNq65z9zf0Z24jKEoic6IYGVruGZK7VQto8SjpfwyEIJNn5zeHEyuVsJXi7UFHvI9AYcgROE2KNNXTIE2gpXEeI4jKEcPNN1NvqpBJNq65GiOlkd(grbotU)Qo5WZM8uyH5joE2KNre6Hr9kngJS7(fwj2RjlySI6joEcg98mUv0tC8ehpHGNq65GiOlkd(grbotU)Qo5WZM8uyH5ztEgrOhg1R0ymYU7xyLyVMSGXkQNn55zCRONTXtShHiEcPNq65GiOlkd(grbotU)Qo5WZM8uyH5ztEgrOhg1R0ymYU7xyLyVMSGXkQN44jy0ZZ4wrpXXtC8ehavlkmubO(wJ2LJNqfabauNvqG(auxzC)Gb6hqnsyYimdqLJhdtt5jD7IWUqr9grZdfq1IcdvaQpR7qkw1D5qVaiaG6myaG(auxzC)Gb6hqnsyYimdqnIqpmQxDjZIcGQffgQauFRr7YXtOcGaaQZkaG(auxzC)Gb6hq1IcdvaQyVf2LEGIkbOgjmzeMbOsggz0dJ7NNG4zlEYXJHPP8KUDryxOOEJO5HcOgBi(7kgPBcfauNbeaqDUvc0hG6kJ7hmq)aQrctgHzaQI9ReTGKfUbJkJ0GELX9d2tq8esp54XW0KrrLvXDfKSGMSGXkQNqWtf0t849esp54XW0KrrLvXDfKSGMSGXkQNqWti9KJhdtB04kyRItdZtmHHkpbTNre6Hr9kTrJRGTkonzbJvupXXtq8mIqpmQxPnACfSvXPjlySI6je88mU9ehpXbq1IcdvaQcsw4gmQmsdacaOaRIa9bOUY4(bd0pGAKWKrygGQy)krZIdJN0GELX9d2tq8KJhdtZIdJN0GMhQNG4jKEYXJHPzXHXtAqtwWyf1ti4zxe2Z24jy6zB8KJhdtZIdJN0GMkwujpXJ3toEmmnvqKGsBqhrZd1t849Sfpf7xj6GrLrUiSRCS7(fwju9kJ7hSN4aOArHHkavmcIkx6bkQeGaakWEgOpa1vg3pyG(buJeMmcZauf7xjAwCy8Kg0RmUFWaQwuyOcqLfhgpPbabauGfSa9bOArHHka1N1DifR6UCOxauxzC)Gb6hqaafyBlqFaQRmUFWa9dOArHHkavS3c7spqrLauJne)DfJ0nHcaQZaQrctgHzaQKHrg9W4(bOgqnYQoa1ZacaOalyc0hG6kJ7hmq)aQrctgHzaQbuJlSs0WmQyvCEQqpvqavlkmubOI9wyx6bkQeGAa1iR6aupdiaGcS4gOpa1aQrw1bOEgq1IcdvaQyeevU0duuja1vg3pyG(beabq1qdOpaqDgOpa1vg3pyG(buJeMmcZauf7xjAQGibL2GoIELX9dgq1IcdvaQubrckTbDeabauGfOpa1vg3pyG(buJeMmcZauf7xjAJgxbBvC6vg3pypbXti9uSFLOPcIeU7xyLyVELX9d2tq8mIqpmQxPPcIeU7xyLyVMSGXkQNqWZZGvrpbXZic9WOELMkis4UFHvI9AYcgROEQqppJBpXJ3Zw8uSFLOPcIeU7xyLyVELX9d2tCauTOWqfGQrJRGTkoabauTfOpa1vg3pyG(buJeMmcZauf7xj6NbX5zW3G1fSRGKf0RmUFWaQwuyOcq9zqCEg8nyDb7kizbabauGjqFaQRmUFWa9dOArHHkavS3c7spqrLauJeMmcZaujdJm6HX9Ztq8KcD)FfJ0nHQJhgRUpR7qkw15je8e3EcINq6zlEk2Vs0ubrc39lSsSxVY4(b7jE8EgrOhg1R0ubrc39lSsSxtwWyf1ti45zWQON4X7jf6()kgPBcvhpmwDFw3HuSQZZtE2wpbXtoEmmDpwbF74PIMkwujpHGNNbtpXbqn2q83vms3ekaOodiaGc3a9bOUY4(bd0pGAKWKrygGAlEk2Vs0bJkJCryx5y39lSsO6vg3pypXJ3toEmmnvqKGsBqhrZd1t849my7Pcbf8uHN8esppROIE2KNGPNTXtk09)vms3eQoEyS6(SUdPyvNN44jE8EYXJHPdgvg5IWUYXU7xyLq18q9epEpPq3)xXiDtO64HXQ7Z6oKIvDEQqpBlGQffgQauNrKdioVP0aeaqPGa9bOUY4(bd0pGAKWKrygGkKEYXJHPFRr7s5jDtZd1t849KJhdtB04kyRItZd1tC8eepPq3)xXiDtO64HXQ7Z6oKIvDEcbpbtpbXti9Sfpf7xjAQGiH7(fwj2RxzC)G9epEpJi0dJ6vAQGiH7(fwj2RjlySI6je88myv0tCauTOWqfG6BnAxoEcvaeaqbgaOpa1vg3pyG(buJeMmcZauf7xj69lSsS)Y9gv0RmUFWEcINuO7)RyKUjuD8Wy19zDhsXQopHGNGPNG4jKE2INI9RenvqKWD)cRe71RmUFWEIhVNre6Hr9knvqKWD)cRe71Kfmwr9ecEEgSk6joaQwuyOcqD)cRe7VCVrfabaukaG(auxzC)Gb6hqnsyYimdqvSFLOnACfSvXPxzC)GbuTOWqfG6BnAxUzbabauTsG(auTOWqfGA8Wy19zDhsXQoa1vg3pyG(beaqDwrG(auxzC)Gb6hqnsyYimdqvSFLOnACfSvXPxzC)GbuTOWqfG6BnAxoEcvaudOgzvhG6zabauNpd0hG6kJ7hmq)aQwuyOcqf7TWU0duuja1ydXFxXiDtOaG6mGAKWKrygGkzyKrpmUFaQbuJSQdq9mGaaQZGfOpa1aQrw1bOEgq1IcdvaQyeevU0duuja1vg3pyG(beabqfEyg)la9baQZa9bOUY4(bdWbOgjmzeMbOAk3ryY0wfhvi2FjJIkRItVY4(bdOArHHkavUhHGFEQaiaGcSa9bOArHHka1ESc(spMrauxzC)Gb6hqaavBb6dqDLX9dgOFa1iHjJWmavX(vIwqYc3GrLrAqVY4(b7jiEYXJHPjJIkRI7kizbnzbJvupHGNGfq1IcdvaQcsw4gmQmsdacaOatG(auxzC)Gb6hqnsyYimdqTfpf7xjAQGiH7(fwj2RxzC)GbuTOWqfGkgJS7(fwj2diaGc3a9bOUY4(bd0pGAKWKrygGQy)krtfejC3VWkXE9kJ7hSNG4jKE2INI9RenlomEsd6vg3pypXJ3Zw8KJhdtZIdJN0GMhQNG4zlEgrOhg1R0S4W4jnO5H6joaQwuyOcqLkis4UFHvI9acaOuqG(auxzC)Gb6hqnsyYimdqTfpf7xjAOewW(7(fwj2ZOIELX9d2t849uSFLOHsyb7V7xyLypJk6vg3pypbXti9mIqpmQxPXyKD3VWkXEnzbJvupHGNNbRIEcINT4Py)krtfejC3VWkXE9kJ7hSN4X7zeHEyuVstfejC3VWkXEnzbJvupHGNNbRIEcINI9RenvqKWD)cRe71RmUFWEIdGQffgQauNrKJ7(fwj2diaGcmaqFaQwuyOcqLNUltwGcOUY4(bd0pGaakfaqFaQRmUFWa9dOgjmzeMbO2INI9ReTrJRGTko9kJ7hSN4X7jhpgM2OXvWwfNMhQN4X7zeHEyuVsB04kyRIttwWyf1tf6jUveq1IcdvaQCpcbFX4jnaiaGQvc0hG6kJ7hmq)aQrctgHzaQT4Py)krB04kyRItVY4(b7jE8EYXJHPnACfSvXP5HcOArHHkavUrOJOeR6aeaqDwrG(auxzC)Gb6hqnsyYimdqTfpf7xjAJgxbBvC6vg3pypXJ3toEmmTrJRGTkonpupXJ3Zic9WOEL2OXvWwfNMSGXkQNk0tCRiGQffgQauXyKX9iemGaaQZNb6dqDLX9dgOFa1iHjJWma1w8uSFLOnACfSvXPxzC)G9epEp54XW0gnUc2Q408q9epEpJi0dJ6vAJgxbBvCAYcgROEQqpXTIaQwuyOcq1Q4OcX(B0(hqaa1zWc0hG6kJ7hmq)aQrctgHzaQwuynU7QfyJ6Pc9eSEcINq6jf6()kgPBcvhpmwDFw3HuSQZtf6jy9epEpPq3)xXiDtO63A0UCZcEQqpbRN4aOArHHkavcFDTOWq19zubq9zu5wwyaQgAacaOo3wG(auxzC)Gb6hq1IcdvaQe(6ArHHQ7ZOcG6ZOYTSWauPSQ73vms3eabqauHswef4mbOpaqDgOpa1vg3pyG(beaqbwG(auxzC)Gb6hqaavBb6dqDLX9dgOFabauGjqFaQRmUFWa9diaGc3a9bOArHHkavbjlCdgvgPba1vg3pyG(beaqPGa9bOUY4(bd0pGAKWKrygGAlEk2Vs0qjSG939lSsSNrf9kJ7hmGQffgQauNrKJ7(fwj2diaGcmaqFaQRmUFWa9dOgjmzeMbOk2Vs0ubrckTbDe9kJ7hSNG4jKEsmg8DnUs0gmmvhr8L4je8STEIhVNeJbFxJReTbdt1SYtf6jUv0tCauTOWqfGkvqKGsBqhbqaaLcaOpa1vg3pyG(buJeMmcZauBXtX(vIMkis4UFHvI96vg3pyavlkmubOIXi7UFHvI9acaOALa9bOArHHkavOiHHka1vg3pyG(beaqDwrG(auxzC)Gb6hqnsyYimdqvSFLO3VWkX(l3BurVY4(bdOArHHka19lSsS)Y9gvaeabqaeabaaa]] )


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
