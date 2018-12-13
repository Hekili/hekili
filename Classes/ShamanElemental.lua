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

    
    spec:RegisterPack( "Elemental", 20181211.2257, [[d8eTBbqiPKEKuIUeqjTjG0NaHYOarNcQyvQi8kGIzjvXTKISls(LuudJuQJjLAzQi9mvennGsDnOsTnsj5BqLKghPq15KsqRJui9oGsinpqW9urTpsbheQeSqGOhcvsmrOsQlskXgjfI(iqjyKaLqCsGs0kbQEjujuZKus1nHkr7ei8tOsidvkHwQuc8us1uLQ0vjLu(kPqySaLqTxa)vLgSOdtzXOYJfAYG6YkBgkFwQmAv40O8AsrZwv3wWUL8BidhKooiuTCephPPtCDu12Lc(UuvJheY5LcTEsHY8HQ2pvd0gOxaDytgaiov72A82N2(u1PNIBC1tIRcOlncDa6qTOMw3a0llmaDT8lSsShqhQ14JmyGEb0PiEsCa6hIaLQrBU5oMCWZPIOqZuwG)nHHQiXWKMPSqSzUhX1mhM1e8AOzOeeg7hT5wKSwGXGPn3ITGR(HfS6QLFHvI9kkleb054zVawwaCa6WMmaqCQ2T14TpT9PQtpf3NEY2a6uOlcaIt1Qtb0pyWWRa4a0HhncO3sp1YVWkXEp1pSGvo4T0ZdrGs1On3Chto45uruOzklW)MWqvKyysZuwi2m3J4AMdZAcEn0muccJ9J2ClswlWyW0MBXwWv)WcwD1YVWkXEfLfIo4T0tC9IlWnINTB3JNNQDBnUNn55PNQrbBTDWDWBPN4khw1nQg1bVLE2KNAn68eS47(fwj2R4H6jXKJr8uoSYZ4XIAYQopJi0dJ6xupfKN0npzyEUFHvI9upnY80IcRHPCWBPNn5jUMrnUFWEQfJihEQLFHvI9EUsiSrva6qjim2pa9w6Pw(fwj27P(HfSYbVLEEicuQgT5M7yYbpNkIcntzb(3egQIedtAMYcXM5EexZCywtWRHMHsqySF0MBrYAbgdM2Cl2cU6hwWQRw(fwj2ROSq0bVLEIRxCbUr8SD7E88uTBRX9Sjpp9unkyRTdUdEl9ex5WQUr1Oo4T0ZM8uRrNNGfF3VWkXEfpupjMCmINYHvEgpwutw15zeHEyu)I6PG8KU5jdZZ9lSsSN6PrMNwuynmLdEl9SjpX1mQX9d2tTye5WtT8lSsS3ZvcHnQYb3bVLEQfiArEzWEYnmezEgrbot8KBDSIQ8exighuH6zHQMomsaJ)90Icdvupr13OYb3IcdvufuYIOaNjNXEJQPdUffgQOkOKfrbotaZ5MXqiyhClkmurvqjlIcCMaMZnB8DHvIjmu5G3sp1ldk9ajEsmgSNC8yyd2tQyc1tUHHiZZikWzINCRJvupTc2tOK1euKiSQZtg1tyunLdUffgQOkOKfrbotaZ5MPLbLEGKlvmH6GBrHHkQckzruGZeWCUzbjlCdgvgPrhClkmurvqjlIcCMaMZnpJih39lSsSVhg25wf7xjkOewW(7(fwj2ZOIALX9d2bVLEQ1OZtDbrcAUbDepHswef4mXt(6hL6jffMNgmm1Z(S)9Kc16xEsrOs5GBrHHkQckzruGZeWCUzQGibn3GospmSZI9RefvqKGMBqhrTY4(bdkKeJbFxdReLbdtvreFjq4K4Xtmg8DnSsugmmvXknGBTXXb3IcdvufuYIOaNjG5CZymYU7xyLyFpmSZTk2Vsuubrc39lSsSxTY4(b7GBrHHkQckzruGZeWCUzOiHHkhClkmurvqjlIcCMaMZnVFHvI9xU3OspmSZI9Re1(fwj2F5EJkQvg3pyhCh8w6PwGOf5Lb75AyKg9uyH5PCmpTOGiEYOEAnyS34(PCWBPN4kgv8eKpcb)8uXZGv82)n6jdZt5yEIlOXgHjZZEjgt8exOIJke79SfmkQSkopzupHsgDLOCWTOWqf9m3JqWppv6HHD20yJWKPSkoQqS)sgfvwfNALX9d2bVLEcwwYieEOINimpJgvOkhClkmurbZ5M7Zk4l9ygXb3IcdvuWCUzbjlCdgvgPXEyyNf7xjkbjlCdgvgPr1kJ7hmOC8yykYOOYQ4UcswqrwWyffcN6GBrHHkkyo3mgJS7(fwj23dd7CRI9RefvqKWD)cRe7vRmUFWo4wuyOIcMZntfejC3VWkX(EyyNf7xjkQGiH7(fwj2RwzC)GbfYwf7xjkwCy8KgvRmUFW4X3khpgMIfhgpPrfpuqBnIqpmQFPyXHXtAuXdfhhClkmurbZ5MNrKJ7(fwj23dd7CRI9Refucly)D)cRe7zurTY4(bJhVy)krbLWc2F3VWkXEgvuRmUFWGczeHEyu)sHXi7UFHvI9kYcgROqO9PAdARI9RefvqKWD)cRe7vRmUFW4XhrOhg1Vuubrc39lSsSxrwWyffcTpvBqf7xjkQGiH7(fwj2RwzC)GXXb3IcdvuWCUzE6UmzbQdUffgQOG5CZCpcbFX4jn2dd7CRI9ReLrJRGTko1kJ7hmE8C8yykJgxbBvCkEO4XhrOhg1VugnUc2Q4uKfmwr1aU12b3IcdvuWCUzUrOJOjR66HHDUvX(vIYOXvWwfNALX9dgpEoEmmLrJRGTkofpuhClkmurbZ5MXyKX9ieCpmSZTk2VsugnUc2Q4uRmUFW4XZXJHPmACfSvXP4HIhFeHEyu)sz04kyRItrwWyfvd4wBhClkmurbZ5MTkoQqS)gT)7HHDUvX(vIYOXvWwfNALX9dgpEoEmmLrJRGTkofpu84Ji0dJ6xkJgxbBvCkYcgROAa3A7GBrHHkkyo3mHVUwuyO6(mQ0tzHD2qRhg2zlkSg2D1cSr1WPGcjf6()kgPBcvfpmwDFw3HuSQtdNIhpf6()kgPBcv9wd2LBwqdNIJdUffgQOG5CZe(6ArHHQ7ZOspLf2zkR6(DfJ0nXb3bVLEIl5FH5PyKUjEArHHkpHsyictA0ZNrfhClkmurvgANPcIe0Cd6i9WWol2VsuubrcAUbDe1kJ7hSdUffgQOkdnWCUzJgxbBvC9WWol2VsugnUc2Q4uRmUFWGcPy)krrfejC3VWkXE1kJ7hmOre6Hr9lfvqKWD)cRe7vKfmwrHq7t1g0ic9WO(LIkis4UFHvI9kYcgROAOnUXJVvX(vIIkis4UFHvI9Qvg3pyCCWTOWqfvzObMZn)miopd(gSUGDfKSqpmSZI9Re1ZG48m4BW6c2vqYcQvg3pyhCh8w6PouYmyp1iFlmp1pqrn9KvEcHZGTNIr6M4jgR7qO94jhV4zHepH5jSQZtDT4jpuHfwpEYx)OupBeXdXiZtmw3HWQoppPNIr6Mq90kyppSgMN)OupLdR8Sny7PgbRG9eSapv8KkwutQYb3IcdvuLHgyo3m2BHDPhOOM9eBm(7kgPBc9C7EyyNjdJm6HX9duk09)vms3eQkEyS6(SUdPyvheWnOq2Qy)krrfejC3VWkXE1kJ7hmE8re6Hr9lfvqKWD)cRe7vKfmwrHq7t1gpEk09)vms3eQkEyS6(SUdPyv35tckhpgMQpRGVD8urrflQjeAd244G7G3sp7L0ONcYZolmp1IrKdioVP58Spto8exAuzepryEkhZtT8lSsOEYXJH5z)JvEIX6oew155j9ums3eQYtCnQGyINOggjAq9exA7PcbfA1b3IcdvuLHgyo38mICaX5nnxpmSZTk2VsubJkJCryx5y39lSsOQvg3py8454XWuubrcAUbDefpu84d2EQqqbnCgY2ARDtG9jOq3)xXiDtOQ4HXQ7Z6oKIvD4GhphpgMkyuzKlc7kh7UFHvcvXdfpEk09)vms3eQkEyS6(SUdPyvNgoPdUdEl9exu9n6z0OINADRbZtqYtOINOYt5GS5PyKUjupzyEYepzupTYtwrfRepTc2tDbrcEQLFHvI9EYOEccCr96Pffwdt5GBrHHkQYqdmNB(TgSlhpHk9WWodjhpgM6TgSlLN0nfpu8454XWugnUc2Q4u8qXbuk09)vms3eQkEyS6(SUdPyvheaBqHSvX(vIIkis4UFHvI9Qvg3py84Ji0dJ6xkQGiH7(fwj2RilySIcH2NQnoo4o4T0tTgDEQLFHvI9EcY3OINwNXkQ4jpupfKNN0tXiDtOEAupFu15Pr9uxqKGNA5xyLyVNmQNfs80IcRHPCWTOWqfvzObMZnVFHvI9xU3OspmSZI9Re1(fwj2F5EJkQvg3pyqPq3)xXiDtOQ4HXQ7Z6oKIvDqaSbfYwf7xjkQGiH7(fwj2RwzC)GXJpIqpmQFPOcIeU7xyLyVISGXkkeAFQ244GBrHHkQYqdmNB(TgSl3SqpmSZI9ReLrJRGTko1kJ7hSdUffgQOkdnWCU54HXQ7Z6oKIvDo4wuyOIQm0aZ5MFRb7YXtOspbudSQ7C7EyyNf7xjkJgxbBvCQvg3pyhClkmurvgAG5CZyVf2LEGIA2ta1aR6o3UNyJXFxXiDtONB3dd7mzyKrpmUFo4wuyOIQm0aZ5MXiiQCPhOOM9eqnWQUZTDWDWDWBPN6SQ7NN9AKUjEIlefgQ8SfjmeHjn6PwNrfh8w6PwkkpzEQrQ7jJ6PffwdZt(6hL6zJiEppSgMNTbBprepdiY8KkwutQNimp1iyfSNGf4PINyeuWtDbrcEQLFHvI9kpHulWDZZOrNg1tEOruGvDEIlqJEYXlEArH1W8uxlGf1tyubXepXXb3IcdvufLvD)UIr6MCg7TWU0duuZEyyNHSvHf1KvD4Xl2Vsuubrc39lSsSxTY4(bdAeHEyu)srfejC3VWkXEfzbJvuiC6j6IW4XdJef2BHDPhOOMkYcgROq4CxegpEX(vIYOXvWwfNALX9dguyKOWElSl9af1urwWyffcqgrOhg1VugnUc2Q4uKfmwrbdhpgMYOXvWwfNcMNycdv4aAeHEyu)sz04kyRItrwWyffcGnOq2Qy)krrfejC3VWkXE1kJ7hmE8I9RefvqKWD)cRe7vRmUFWGgrOhg1Vuubrc39lSsSxrwWyffcTpvBCWbuoEmmvFwbF74PIIkwuti0gSDWDWBPNAn68exGgxbBvCEAyYiE2iIhI1W8KcDL4P9VNADRbZtqYtOINXdJ0nQNwb7jQ(g9KH5znMCmIN6cIe8ul)cRe79SqepblJdJN0ONgzEg5jKvY3ONwuynmLdUffgQOkkR6(DfJ0nbmNB2OXvWwfxpmSZI9ReLrJRGTko1kJ7hmOqkSW0WzTsB8454XWuCpcb)8urXdfhqJi0dJ6xQ3AWUC8eQOilySIQbTbfYwf7xjkQGiH7(fwj2RwzC)GXJNkis4UFHvI9kEO4akKTk2VsuS4W4jnQwzC)GXJVvoEmmflomEsJkEOG2AeHEyu)sXIdJN0OIhkoo4o4T0tCnQGyIN805Pw(fwj27jiFJkEYW8SreVNre)d7z0OINMN4sJkJ4jcZt5yEQLFHvc1ZfGI6pYG9ulgro8u)af10twrLzWkpX1OcIjEgnQ4Pw(fwj27jiFJkEcZtyvNN6cIe8ul)cRe79KV(rPE2iI3ZdRH55jHipbHj8e79eSigjGQg9KvE2)Gfp8mA05zJiEpPccQN8uw15Pw(fwj27jiFJkEIQ48SreVNKzXdpBd2EsflQj1teMNAeSc2tWc8ur5GBrHHkQIYQUFxXiDtaZ5M3VWkX(l3BuPhg2zX(vIA)cRe7VCVrf1kJ7hmOqk2VsubJkJCryx5y39lSsOQvg3pyq54XWubJkJCryx5y39lSsOkEOGgS9uHGcqqR0gp(wf7xjQGrLrUiSRCS7(fwju1kJ7hmoGczRqsfejC3VWkXEfpuqf7xjkQGiH7(fwj2RwzC)GXbpEtJnctMQmHNy)9Wibu1OIyLMNpjOC8yyQ(Sc(2XtffvSOMqOnyJJdUdEl9ex8gup1Xf7jgI45BKU5jI4jfHkpnyyp7BnmQYtTw9Js9SreVNhwdZtDEs38eH5zlI6pspEYkp7FWIhEgn68SreVN9Ts8uqEcJ45(5jhpgMNADw3HuSQZtqIEXtUg9ekc9SQZtCPTNkeuWtUHHi7WkyLNAbISa0FEsheNFvCAupBRT24s9E8ul694PoU4E8uRdYE8uR3ai7XtTO3JNADq6GBrHHkQIYQUFxXiDtaZ5MPcIe0Cd6i9WWol2VsuubrcAUbDe1kJ7hmOqsmg8DnSsugmmvfr8LaHtIhpXyW31WkrzWWufR0aU1ghqHSvX(vIIYt62fHDHI6pIALX9dgpEoEmmfLN0Tlc7cf1Fefpu84d2EQqqbnCgSbBCCWTOWqfvrzv3VRyKUjG5CZpdIZZGVbRlyxbjl0dd7Sy)kr9miopd(gSUGDfKSGALX9dguijgd(UgwjkdgMQIi(sGWjXJNym47AyLOmyyQIvAa3AJJdUdEl9exbf4y18uxqKGMBqhXZ(m5WtCPrLr8eH5PCmp1YVWkH6jI4PopPBEIW8Sfr9hr5GBrHHkQIYQUFxXiDtaZ5MFw3HuSQ7YHEPhg2zoEmmfvqKGMBqhrXdfuk09)vms3eQkEyS6(SUdPyvheofui54XWubJkJCryx5y39lSsOkEOG2Qy)krr5jD7IWUqr9hrTY4(bJhphpgMIYt62fHDHI6pIIhkoo4o4T0ZEpgzEgyDhINruyEALN8qHnzEIHiEkhmQNpRMN9zYHNuuyEQJArpFuhlQCWTOWqfvrzv3VRyKUjG5CZZiYbeN30C9WWoBrH1WURwGnQgAdkf6()kgPBcvfpmwDFw3HuSQtdTbfYwf7xjkkpPBxe2fkQ)iQvg3py84BfgjkS3c7spqrnvKHrg9W4(HhpvqKWD)cRe7v8qXbuiBvSFLOcgvg5IWUYXU7xyLqvRmUFW4XZXJHPcgvg5IWUYXU7xyLqv8qXJpy7Pcbf0W5w4P44G7G3spbjQrLs1)WepnpJOcMjmuP8uJGjhEIlnQmINimpLJ5Pw(fwjupHIqVN4sBpviOGN8q9uqEQX9exA7Pcbf8KBpQVNYX8mAq9uqEUIYtMNmbIr9KNoyp7ZKdp1IrKdp1pqrnvEQrWKdeV4jU0OYiEIW8uoMNA5xyLq7XtE68ulgro8u)af10ZXKJr8KH5PUGibn3GoINmQN8q7XtCPTNkeuWtg1Z2A7jU02tfck4j3EuFpLJ5z0G6jI45pkThprephtogXtDbrcEQLFHvI9EYOfet8uSFLmyprepzceJ6zHepTOWAyEAfSNnI4jE(gv8uxqKGNA5xyLyVNimpLJ5jgR7q8Sp7FppSgMNO6B0tZtOgry27jmpXegQuo4wuyOIQOSQ73vms3eWCU5ze54spqrn7HHDUvoEmmfLN0Tlc7cf1Fefpuqf7xjQGrLrUiSRCS7(fwju1kJ7hmOqYXJHPcgvg5IWUYXU7xyLqv8qXJpy7Pcbf0W5w4PG5KAFcX(vIkA)FLJDLd(cEe1kJ7hmE8C8yykQGibn3GoIIhkOwuynS7QfyJcHtXbp(wf7xjQGrLrUiSRCS7(fwju1kJ7hmOqYXJHPOcIe0Cd6ikEO4XhS9uHGcA4CluBWCsTpHy)krfT)VYXUYbFbpIALX9dgp(wHKkis4UFHvI9kEOGk2Vsuubrc39lSsSxTY4(bJdOdIGUOm4Bef4m5(R6KJMewynfrOhg1Vuubrc39lSsSxrwWyfTP24w7tG9iebsihebDrzW3ikWzY9x1jhnjSWAkIqpmQFPOcIeU7xyLyVISGXkkoG124wBC0W5tQ9jGSnyG00yJWKPw8aDryx5y39lSsSNQiwPPgoFko4GJdUdEl9uRrNNAXiYHN6hOOMEYW8uNN0npryE2IO(J4jJ6Py)kzW94jhV4znMCmINmXZcr808ex3I6EQLFHvI9EYOEArH1W80epLJ5zafwj94PvWEQ1TgmpbjpHkEYOEsMb3ONiIN9z)7j38SptoyLNYX8SgejEcwaxbxRCWTOWqfvrzv3VRyKUjG5CZZiYXLEGIA2dd7Sy)krr5jD7IWUqr9hrTY4(bdARC8yykkpPBxe2fkQ)ikEOGgrOhg1VuV1GD54jurrwWyffcN7IWGczRI9RefvqKWD)cRe7vRmUFWG2kKymYU7xyLyVIhko4Xl2Vsuubrc39lSsSxTY4(bdARqsfejC3VWkXEfpuCWXb3bVLEIRyuXtToR7qkw15jirVq9eMNWQop1fej4Pw(fwj27jmpXegQuo4wuyOIQOSQ73vms3eWCU5N1DifR6UCOx6HHDMkis4UFHvI9kEOGk2Vsuubrc39lSsSxTY4(b7G7G3sp1A05Pgjbrfp1pqrn9Spto8eSmomEsJEAfSN4sJkJ4jcZt5yEQLFHvcv5GBrHHkQIYQUFxXiDtaZ5MXiiQCPhOOM9WWol2VsuS4W4jnQwzC)GbvSFLOcgvg5IWUYXU7xyLqvRmUFWGYXJHPyXHXtAuXdfuoEmmvWOYixe2vo2D)cReQIhQdUffgQOkkR6(DfJ0nbmNB(TgSlhpHk9WWoZXJHPmACfSvXP4H6G7G3sp1Ac7zAS5PopPBEIW8Sfr9hXtb5jfkzgSNAKVfMN6hOOMEYW8mW)cd6ppxTaBupnY8ekz0vIYb3IcdvufLvD)UIr6MaMZnJ9wyx6bkQzpXgJ)UIr6Mqp3Uhg2zYWiJEyC)a1IcRHDxTaBun0guoEmmfLN0Tlc7cf1FefpuhCh8w6PwJop16wdMNGKNqfp7ZKdp15jDZteMNTiQ)iEYW8uoMNVrfpHIKvcZEp5Pw38eH5P5jUUf19ul)cRe798WOfet808eJ)FpH5jMWqLN4IAbEYW8SreVNre)d7z3epTcjhJ4jp16MNimpLJ5jUUf19ul)cRe79KH5PCmpjlySIvDEIX6oep7BupBRvGvpFu1nIYb3IcdvufLvD)UIr6MaMZn)wd2LJNqLEyyNf7xjkQGiH7(fwj2RwzC)GbnIqpmQFDjZIcOC8yykkpPBxe2fkQ)ikEOGc5GiOlkd(grbotU)Qo5OjHfwtre6Hr9lfvqKWD)cRe7vKfmwrBQnU1(eypcrGeYbrqxug8nIcCMC)vDYrtclSMIi0dJ6xkQGiH7(fwj2RilySIIdyTnU1ghiCsTpbKTbdKMgBeMm1IhOlc7kh7UFHvI9ufXkn1W5tXbh84HSTQTwDcihebDrzW3ikWzY9x1jhnjSWWPPic9WO(LIkis4UFHvI9kYcgROn1g3AFcShHiqczBvBT6eqoic6IYGVruGZK7VQtoAsyHHttre6Hr9lfvqKWD)cRe7vKfmwrXbS2g3AJdoqaYbrqxug8nIcCMC)vDYrtclSMIi0dJ6xkQGiH7(fwj2RilySI2uBCR9jWEeIajKdIGUOm4Bef4m5(R6KJMewynfrOhg1Vuubrc39lSsSxrwWyffhWABCRno4GJdUdEl9uRrNNADRbZtqYtOIN9zYHN68KU5jcZZwe1FepzyEkhZZ3OINqrYkHzVN8uRBEIW808ex3I6EQLFHvI9EEy0cIjEAEIX)VNW8etyOYtCrTapzyE2iI3ZiI)H9SBINwHKJr8KNADZteMNYX8ex3I6EQLFHvI9EYW8uoMNKfmwXQopXyDhIN9nQNT1kWQNpQ6gr5GBrHHkQIYQUFxXiDtaZ5MFRb7YXtOspmSZTk2Vsuubrc39lSsSxTY4(bdAeHEyu)6sMffq54XWuuEs3UiSluu)ru8qbfYbrqxug8nIcCMC)vDYrtclSMIi0dJ6xkmgz39lSsSxrwWyfTP24w7tG9iebsihebDrzW3ikWzY9x1jhnjSWAkIqpmQFPWyKD3VWkXEfzbJvuCaRTXT24aHtQ9jGSnyG00yJWKPw8aDryx5y39lSsSNQiwPPgoFko4GhpKTvT1Qta5GiOlkd(grbotU)Qo5OjHfgonfrOhg1VuymYU7xyLyVISGXkAtTXT2Na7ricKq2w1wRobKdIGUOm4Bef4m5(R6KJMewy40ueHEyu)sHXi7UFHvI9kYcgRO4awBJBTXbhia5GiOlkd(grbotU)Qo5OjHfwtre6Hr9lfgJS7(fwj2RilySI2uBCR9jWEeIajKdIGUOm4Bef4m5(R6KJMewynfrOhg1VuymYU7xyLyVISGXkkoG124wBCWbhhClkmurvuw197kgPBcyo38Z6oKIvDxo0l9WWoZXJHPO8KUDryxOO(JO4H6GBrHHkQIYQUFxXiDtaZ5MFRb7YXtOspmSZre6Hr9RlzwuCWDWBPN4AubXepTyKbVsS)B0tE68uNN0npryE2IO(J4zFMC4Pg5BH5P(bkQPNW8ew15jLvD)8ums3eLdUffgQOkkR6(DfJ0nbmNBg7TWU0duuZEIng)DfJ0nHEUDpmSZKHrg9W4(bARC8yykkpPBxe2fkQ)ikEOo4wuyOIQOSQ73vms3eWCUzbjlCdgvgPXEyyNf7xjkbjlCdgvgPr1kJ7hmOqYXJHPiJIkRI7kizbfzbJvuiOv4XdjhpgMImkQSkURGKfuKfmwrHaKC8yykJgxbBvCkyEIjmubMic9WO(LYOXvWwfNISGXkkoGgrOhg1VugnUc2Q4uKfmwrHqBCJdoo4o4T0t9N1DiFJE2zH5jyzCy8Kg9KJhdZtb55bc6W4)Vrp54XW8KIcZZ(m5WtCPrLr8eH5PCmp1YVWkHQCWTOWqfvrzv3VRyKUjG5CZyeevU0duuZEyyNf7xjkwCy8KgvRmUFWGYXJHPyXHXtAuXdfui54XWuS4W4jnQilySIcHUi8ja7tWXJHPyXHXtAurflQjE8C8yykQGibn3GoIIhkE8Tk2VsubJkJCryx5y39lSsOQvg3pyCCWTOWqfvrzv3VRyKUjG5CZS4W4jn2dd7Sy)krXIdJN0OALX9d2b3IcdvufLvD)UIr6MaMZn)SUdPyv3Ld9IdUffgQOkkR6(DfJ0nbmNBg7TWU0duuZEcOgyv3529eBm(7kgPBc9C7EyyNjdJm6HX9Zb3IcdvufLvD)UIr6MaMZnJ9wyx6bkQzpbudSQ7C7EyyNdOgwyLOGzuXQ40Gw5G7G3sp1ijiQ4P(bkQPNmQNiEINbudlSs8eJ9)ikhClkmurvuw197kgPBcyo3mgbrLl9af1SNaQbw1DUnGEdJqzOcaeNQDBnE7tBRT60tbBnoGEFJuSQJcORrGl0cabyjialOr90ZEpMNSauer8edr8eIzObX8KmiopJmypPOW804fuWKb7z8WQUrvo49EmpXq)J6ZQopnEIr9S)iZtE6G9KvEkhZtlkmu55ZOINC8IN9hzEwiXtmeFb7jR8uoMNgmmQ8e2eJZOtJ6G7ztE2NvW3oEQ4G7GRrGl0cabyjialOr90ZEpMNSauer8edr8eIrzv3VRyKUjqmpjdIZZid2tkkmpnEbfmzWEgpSQBuLdEVhZtm0)O(SQZtJNyup7pY8KNoypzLNYX80IcdvE(mQ4jhV4z)rMNfs8edXxWEYkpLJ5PbdJkpHnX4m60Oo4E2KN9zf8TJNko4o4GLbOiImypbBpTOWqLNpJkuLdoGUXlhicGUolW)MWqfUcXWea9NrfkqVa6uw197kgPBcqVaGOnqVa6RmUFWaGeqpsyYimdqhspB1tHf1KvDEIhVNI9RefvqKWD)cRe7vRmUFWEcQNre6Hr9lfvqKWD)cRe7vKfmwr9ecEEQNNWZUiSN4X7jmsuyVf2LEGIAQilySI6jeo7zxe2t849uSFLOmACfSvXPwzC)G9eupHrIc7TWU0duutfzbJvupHGNq6zeHEyu)sz04kyRItrwWyf1tW4jhpgMYOXvWwfNcMNycdvEIJNG6zeHEyu)sz04kyRItrwWyf1ti4jy7jOEcPNT6Py)krrfejC3VWkXE1kJ7hSN4X7Py)krrfejC3VWkXE1kJ7hSNG6zeHEyu)srfejC3VWkXEfzbJvupHGNTpvBpXXtC8eup54XWu9zf8TJNkkQyrn9ecE2gSb0TOWqfGo2BHDPhOOMacaiofOxa9vg3pyaqcOhjmzeMbOl2VsugnUc2Q4uRmUFWEcQNq6PWcZtnC2tTsBpXJ3toEmmf3JqWppvu8q9ehpb1Zic9WO(L6TgSlhpHkkYcgROEQbp12tq9espB1tX(vIIkis4UFHvI9Qvg3pypXJ3tQGiH7(fwj2R4H6joEcQNq6zREk2VsuS4W4jnQwzC)G9epEpB1toEmmflomEsJkEOEcQNT6zeHEyu)sXIdJN0OIhQN4aOBrHHkaDJgxbBvCacaiojqVa6RmUFWaGeqpsyYimdqxSFLO2VWkX(l3BurTY4(b7jOEcPNI9RevWOYixe2vo2D)cReQALX9d2tq9KJhdtfmQmYfHDLJD3VWkHQ4H6jOEgS9uHGcEcbp1kT9epEpB1tX(vIkyuzKlc7kh7UFHvcvTY4(b7joEcQNq6zREcPNubrc39lSsSxXd1tq9uSFLOOcIeU7xyLyVALX9d2tC8epEpnn2imzQYeEI93dJeqvJkIvA65zppPNG6jhpgMQpRGVD8urrflQPNqWZ2GTN4aOBrHHka99lSsS)Y9gvaeaqa2a9cOVY4(bdasa9iHjJWmaDX(vIIkisqZnOJOwzC)G9eupH0tIXGVRHvIYGHPQiIVepHGNN0t849Kym47AyLOmyyQIvEQbpXT2EIJNG6jKE2QNI9RefLN0Tlc7cf1Fe1kJ7hSN4X7jhpgMIYt62fHDHI6pIIhQN4X7zW2tfck4Pgo7jyd2EIdGUffgQa0PcIe0Cd6iacaiWnqVa6RmUFWaGeqpsyYimdqxSFLOEgeNNbFdwxWUcswqTY4(b7jOEcPNeJbFxdReLbdtvreFjEcbppPN4X7jXyW31WkrzWWufR8udEIBT9ehaDlkmubO)miopd(gSUGDfKSaGaacTcOxa9vg3pyaqcOhjmzeMbOZXJHPOcIe0Cd6ikEOEcQNuO7)RyKUjuv8Wy19zDhsXQopHGNN6jOEcPNC8yyQGrLrUiSRCS7(fwjufpupb1Zw9uSFLOO8KUDryxOO(JOwzC)G9epEp54XWuuEs3UiSluu)ru8q9ehaDlkmubO)SUdPyv3Ld9cGaacCvGEb0xzC)GbajGEKWKrygGUffwd7UAb2OEQbpB7jOEsHU)VIr6MqvXdJv3N1DifR68udE22tq9espB1tX(vIIYt62fHDHI6pIALX9d2t849SvpHrIc7TWU0duutfzyKrpmUFEIhVNubrc39lSsSxXd1tC8eupH0Zw9uSFLOcgvg5IWUYXU7xyLqvRmUFWEIhVNC8yyQGrLrUiSRCS7(fwjufpupXJ3ZGTNkeuWtnC2Zw4PEIdGUffgQa0NrKdioVP5aeaqOXb6fqFLX9dgaKa6rctgHza6T6jhpgMIYt62fHDHI6pIIhQNG6Py)krfmQmYfHDLJD3VWkHQwzC)G9eupH0toEmmvWOYixe2vo2D)cReQIhQN4X7zW2tfck4Pgo7zl8upbJNNuBppHNI9Rev0()kh7kh8f8iQvg3pypXJ3toEmmfvqKGMBqhrXd1tq90IcRHDxTaBupHGNN6joEIhVNT6Py)krfmQmYfHDLJD3VWkHQwzC)G9eupH0toEmmfvqKGMBqhrXd1t849my7Pcbf8udN9SfQTNGXZtQTNNWtX(vIkA)FLJDLd(cEe1kJ7hSN4X7zREcPNubrc39lSsSxXd1tq9uSFLOOcIeU7xyLyVALX9d2tC8euphebDrzW3ikWzY9x1jhE2KNclmpBYZic9WO(LIkis4UFHvI9kYcgROE2KNTXT2EEcpXEeI4jKEcPNdIGUOm4Bef4m5(R6KdpBYtHfMNn5zeHEyu)srfejC3VWkXEfzbJvupXXtWQNTXT2EIJNA4SNNuBppHNq6zBpbJNq6PPXgHjtT4b6IWUYXU7xyLypvrSstp1Wzpp1tC8ehpXbq3Icdva6ZiYXLEGIAciaGOfc0lG(kJ7hmaib0JeMmcZa0f7xjkkpPBxe2fkQ)iQvg3pypb1Zw9KJhdtr5jD7IWUqr9hrXd1tq9mIqpmQFPERb7YXtOIISGXkQNq4SNDrypb1ti9Svpf7xjkQGiH7(fwj2RwzC)G9eupB1ti9eJr2D)cRe7v8q9ehpXJ3tX(vIIkis4UFHvI9Qvg3pypb1Zw9espPcIeU7xyLyVIhQN44joa6wuyOcqFgroU0duutabaeT1gOxa9vg3pyaqcOhjmzeMbOtfejC3VWkXEfpupb1tX(vIIkis4UFHvI9Qvg3pyaDlkmubO)SUdPyv3Ld9cGaaI2Tb6fqFLX9dgaKa6rctgHza6I9ReflomEsJQvg3pypb1tX(vIkyuzKlc7kh7UFHvcvTY4(b7jOEYXJHPyXHXtAuXd1tq9KJhdtfmQmYfHDLJD3VWkHQ4HcOBrHHkaDmcIkx6bkQjGaaI2Nc0lG(kJ7hmaib0JeMmcZa054XWugnUc2Q4u8qb0TOWqfG(BnyxoEcvaeaq0(Ka9cOVY4(bdasaDlkmubOJ9wyx6bkQjGEKWKrygGozyKrpmUFEcQNwuynS7QfyJ6Pg8STNG6jhpgMIYt62fHDHI6pIIhkGESX4VRyKUjuaq0gqaarBWgOxa9vg3pyaqcOhjmzeMbOl2Vsuubrc39lSsSxTY4(b7jOEgrOhg1VUKzrXtq9KJhdtr5jD7IWUqr9hrXd1tq9esphebDrzW3ikWzY9x1jhE2KNclmpBYZic9WO(LIkis4UFHvI9kYcgROE2KNTXT2EEcpXEeI4jKEcPNdIGUOm4Bef4m5(R6KdpBYtHfMNn5zeHEyu)srfejC3VWkXEfzbJvupXXtWQNTXT2EIJNqWZtQTNNWti9STNGXti900yJWKPw8aDryx5y39lSsSNQiwPPNA4SNN6joEIJN4X7jKE2w1wR88eEcPNdIGUOm4Bef4m5(R6KdpBYtHfMN44ztEgrOhg1Vuubrc39lSsSxrwWyf1ZM8SnU12Zt4j2JqepH0ti9STQTw55j8esphebDrzW3ikWzY9x1jhE2KNclmpXXZM8mIqpmQFPOcIeU7xyLyVISGXkQN44jy1Z24wBpXXtC8ecEcPNdIGUOm4Bef4m5(R6KdpBYtHfMNn5zeHEyu)srfejC3VWkXEfzbJvupBYZ24wBppHNypcr8espH0Zbrqxug8nIcCMC)vDYHNn5PWcZZM8mIqpmQFPOcIeU7xyLyVISGXkQN44jy1Z24wBpXXtC8ehaDlkmubO)wd2LJNqfabaeTXnqVa6RmUFWaGeqpsyYimdqVvpf7xjkQGiH7(fwj2RwzC)G9eupJi0dJ6xxYSO4jOEYXJHPO8KUDryxOO(JO4H6jOEcPNdIGUOm4Bef4m5(R6KdpBYtHfMNn5zeHEyu)sHXi7UFHvI9kYcgROE2KNTXT2EEcpXEeI4jKEcPNdIGUOm4Bef4m5(R6KdpBYtHfMNn5zeHEyu)sHXi7UFHvI9kYcgROEIJNGvpBJBT9ehpHGNNuBppHNq6zBpbJNq6PPXgHjtT4b6IWUYXU7xyLypvrSstp1Wzpp1tC8ehpXJ3ti9STQTw55j8esphebDrzW3ikWzY9x1jhE2KNclmpXXZM8mIqpmQFPWyKD3VWkXEfzbJvupBYZ24wBppHNypcr8espH0Z2Q2ALNNWti9Cqe0fLbFJOaNj3FvNC4ztEkSW8ehpBYZic9WO(LcJr2D)cRe7vKfmwr9ehpbRE2g3A7joEIJNqWti9Cqe0fLbFJOaNj3FvNC4ztEkSW8SjpJi0dJ6xkmgz39lSsSxrwWyf1ZM8SnU12Zt4j2JqepH0ti9Cqe0fLbFJOaNj3FvNC4ztEkSW8SjpJi0dJ6xkmgz39lSsSxrwWyf1tC8eS6zBCRTN44joEIdGUffgQa0FRb7YXtOcGaaI2AfqVa6RmUFWaGeqpsyYimdqNJhdtr5jD7IWUqr9hrXdfq3Icdva6pR7qkw1D5qVaiaGOnUkqVa6RmUFWaGeqpsyYimdqpIqpmQFDjZIcGUffgQa0FRb7YXtOcGaaI2ACGEb0xzC)GbajGUffgQa0XElSl9af1eqpsyYimdqNmmYOhg3ppb1Zw9KJhdtr5jD7IWUqr9hrXdfqp2y83vms3ekaiAdiaGODleOxa9vg3pyaqcOhjmzeMbOl2Vsucsw4gmQmsJQvg3pypb1ti9KJhdtrgfvwf3vqYckYcgROEcbp1kpXJ3ti9KJhdtrgfvwf3vqYckYcgROEcbpH0toEmmLrJRGTkofmpXegQ8emEgrOhg1VugnUc2Q4uKfmwr9ehpb1Zic9WO(LYOXvWwfNISGXkQNqWZ242tC8ehaDlkmubOlizHBWOYinciaG4uTb6fqFLX9dgaKa6rctgHza6I9ReflomEsJQvg3pypb1toEmmflomEsJkEOEcQNq6jhpgMIfhgpPrfzbJvupHGNDryppHNGTNNWtoEmmflomEsJkQyrn9epEp54XWuubrcAUbDefpupXJ3Zw9uSFLOcgvg5IWUYXU7xyLqvRmUFWEIdGUffgQa0XiiQCPhOOMacaioTnqVa6RmUFWaGeqpsyYimdqxSFLOyXHXtAuTY4(bdOBrHHkaDwCy8KgbeaqC6Pa9cOBrHHka9N1DifR6UCOxa0xzC)GbajGaaItpjqVa6RmUFWaGeq3Icdva6yVf2LEGIAcOhBm(7kgPBcfaeTb0JeMmcZa0jdJm6HX9dqpGAGvDa6TbeaqCkyd0lG(kJ7hmaib0JeMmcZa0dOgwyLOGzuXQ48udEQva6wuyOcqh7TWU0duuta9aQbw1bO3gqaaXP4gOxa9aQbw1bO3gq3Icdva6yeevU0duuta9vg3pyaqciacGUHgqVaGOnqVa6RmUFWaGeqpsyYimdqxSFLOOcIe0Cd6iQvg3pyaDlkmubOtfejO5g0raeaqCkqVa6RmUFWaGeqpsyYimdqxSFLOmACfSvXPwzC)G9eupH0tX(vIIkis4UFHvI9Qvg3pypb1Zic9WO(LIkis4UFHvI9kYcgROEcbpBFQ2EcQNre6Hr9lfvqKWD)cRe7vKfmwr9udE2g3EIhVNT6Py)krrfejC3VWkXE1kJ7hSN4aOBrHHkaDJgxbBvCacaiojqVa6RmUFWaGeqpsyYimdqxSFLOEgeNNbFdwxWUcswqTY4(bdOBrHHka9NbX5zW3G1fSRGKfaeaqa2a9cOVY4(bdasaDlkmubOJ9wyx6bkQjGEKWKrygGozyKrpmUFEcQNuO7)RyKUjuv8Wy19zDhsXQopHGN42tq9espB1tX(vIIkis4UFHvI9Qvg3pypXJ3Zic9WO(LIkis4UFHvI9kYcgROEcbpBFQ2EIhVNuO7)RyKUjuv8Wy19zDhsXQopp75j9eup54XWu9zf8TJNkkQyrn9ecE2gS9eha9yJXFxXiDtOaGOnGaacCd0lG(kJ7hmaib0JeMmcZa0B1tX(vIkyuzKlc7kh7UFHvcvTY4(b7jE8EYXJHPOcIe0Cd6ikEOEIhVNbBpviOGNA4SNq6zBT12ZM8eS98eEsHU)VIr6MqvXdJv3N1DifR68ehpXJ3toEmmvWOYixe2vo2D)cReQIhQN4X7jf6()kgPBcvfpmwDFw3HuSQZtn45jb0TOWqfG(mICaX5nnhGaacTcOxa9vg3pyaqcOhjmzeMbOdPNC8yyQ3AWUuEs3u8q9epEp54XWugnUc2Q4u8q9ehpb1tk09)vms3eQkEyS6(SUdPyvNNqWtW2tq9espB1tX(vIIkis4UFHvI9Qvg3pypXJ3Zic9WO(LIkis4UFHvI9kYcgROEcbpBFQ2EIdGUffgQa0FRb7YXtOcGaacCvGEb0xzC)GbajGEKWKrygGUy)krTFHvI9xU3OIALX9d2tq9KcD)FfJ0nHQIhgRUpR7qkw15je8eS9eupH0Zw9uSFLOOcIeU7xyLyVALX9d2t849mIqpmQFPOcIeU7xyLyVISGXkQNqWZ2NQTN4aOBrHHka99lSsS)Y9gvaeaqOXb6fqFLX9dgaKa6rctgHza6I9ReLrJRGTko1kJ7hmGUffgQa0FRb7YnlaiaGOfc0lGUffgQa0JhgRUpR7qkw1bOVY4(bdasabaeT1gOxa9vg3pyaqcOhjmzeMbOl2VsugnUc2Q4uRmUFWa6wuyOcq)TgSlhpHka6budSQdqVnGaaI2Tb6fqFLX9dgaKa6wuyOcqh7TWU0duuta9yJXFxXiDtOaGOnGEKWKrygGozyKrpmUFa6budSQdqVnGaaI2Nc0lGEa1aR6a0BdOBrHHkaDmcIkx6bkQjG(kJ7hmaibeabqhEyg)la9caI2a9cOVY4(bdWbOhjmzeMbOBASryYuwfhvi2FjJIkRItTY4(bdOBrHHkaDUhHGFEQaiaG4uGEb0TOWqfGEFwbFPhZia6RmUFWaGeqaaXjb6fqFLX9dgaKa6rctgHza6I9ReLGKfUbJkJ0OALX9d2tq9KJhdtrgfvwf3vqYckYcgROEcbppfq3Icdva6csw4gmQmsJacaiaBGEb0xzC)GbajGEKWKrygGEREk2Vsuubrc39lSsSxTY4(bdOBrHHkaDmgz39lSsShqaabUb6fqFLX9dgaKa6rctgHza6I9RefvqKWD)cRe7vRmUFWEcQNq6zREk2VsuS4W4jnQwzC)G9epEpB1toEmmflomEsJkEOEcQNT6zeHEyu)sXIdJN0OIhQN4aOBrHHkaDQGiH7(fwj2diaGqRa6fqFLX9dgGdqpsyYimdqVvpf7xjkOewW(7(fwj2ZOIALX9d2t849uSFLOGsyb7V7xyLypJkQvg3pypb1ti9mIqpmQFPWyKD3VWkXEfzbJvupHGNTpvBpb1Zw9uSFLOOcIeU7xyLyVALX9d2t849mIqpmQFPOcIeU7xyLyVISGXkQNqWZ2NQTNG6Py)krrfejC3VWkXE1kJ7hSN4aOBrHHka9ze54UFHvI9acaiWvb6fq3Icdva680DzYcua9vg3pyaqciaGqJd0lG(kJ7hmaib0JeMmcZa0B1tX(vIYOXvWwfNALX9d2t849KJhdtz04kyRItXd1t849mIqpmQFPmACfSvXPilySI6Pg8e3AdOBrHHkaDUhHGVy8Kgbeaq0cb6fqFLX9dgaKa6rctgHza6T6Py)krz04kyRItTY4(b7jE8EYXJHPmACfSvXP4HcOBrHHkaDUrOJOjR6aeaq0wBGEb0xzC)GbajGEKWKrygGEREk2VsugnUc2Q4uRmUFWEIhVNC8yykJgxbBvCkEOEIhVNre6Hr9lLrJRGTkofzbJvup1GN4wBaDlkmubOJXiJ7riyabaeTBd0lG(kJ7hmaib0JeMmcZa0B1tX(vIYOXvWwfNALX9d2t849KJhdtz04kyRItXd1t849mIqpmQFPmACfSvXPilySI6Pg8e3AdOBrHHkaDRIJke7Vr7FabaeTpfOxa9vg3pyaqcOhjmzeMbOBrH1WURwGnQNAWZt9eupH0tk09)vms3eQkEyS6(SUdPyvNNAWZt9epEpPq3)xXiDtOQ3AWUCZcEQbpp1tCa0TOWqfGoHVUwuyO6(mQaO)mQCllmaDdnabaeTpjqVa6RmUFWaGeq3Icdva6e(6ArHHQ7ZOcG(ZOYTSWa0PSQ73vms3eabqa0Hswef4mbOxaq0gOxa9vg3pyaqciaG4uGEb0xzC)GbajGaaItc0lG(kJ7hmaibeaqa2a9cOVY4(bdasabae4gOxaDlkmubOlizHBWOYincOVY4(bdasabaeAfqVa6RmUFWaCa6rctgHza6T6Py)krbLWc2F3VWkXEgvuRmUFWa6wuyOcqFgroU7xyLypGaacCvGEb0xzC)GbajGEKWKrygGUy)krrfejO5g0ruRmUFWEcQNq6jXyW31WkrzWWuveXxINqWZt6jE8Esmg8DnSsugmmvXkp1GN4wBpXbq3Icdva6ubrcAUbDeabaeACGEb0xzC)GbajGEKWKrygGEREk2Vsuubrc39lSsSxTY4(bdOBrHHkaDmgz39lSsShqaarleOxaDlkmubOdfjmubOVY4(bdasabaeT1gOxa9vg3pyaqcOhjmzeMbOl2Vsu7xyLy)L7nQOwzC)Gb0TOWqfG((fwj2F5EJkacGaiacGaaa]] )


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
