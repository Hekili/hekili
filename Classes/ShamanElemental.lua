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
                summonPet( 'fire_elemental' )
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
                summonPet( 'storm_elemental' )
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

    
    spec:RegisterPack( "Elemental", 20181210.2248, [[d4KIBbqiPIEeqrxcOuTjG0NGuPgfK4uqsRsQKEfq0SubULuHDrYVKIAyqvoMuYYKcEgqHPbuY1GQY2GQQ(gKQOXbvvCoPsW6qvL6DOQcL5bu5EQq7dOQdcPkSqGWdLkHmrivvxevvTruvbFesvPrIQkuDsGsPvcP8suvHmtuvj3esvANQG(PujudvQeTuuvrpLunvPsDvGsXxHuvSxa)vLgSKdtzXOYJfAYqCzLndLplvnAv0Pr51OQmBvDBb7w0VbnCOYXHujlhXZrA6exNu2UuKVlLA8qQ48sHwpuvP5JQSFQgOfq3a6iMmGdBaVw4Nwn0cpvdGrdGvd4haDPrCdqhNf5Z6hGEAHbOZ)FHLI9a64SgFOHa0nGofQrIdq)ueCu(DZn3ZKtnovegAMYcAVjmygjgM0mLfInZ9qUM5WSoqwtnJJaXy)On3LKXpngcT5UKFE1pTGLx()lSuSxrzHiGoNg7fW2eGdqhXKbCyd41c)0QHw4PAObWc9eqNIBrGdBa)Baq)KHGSeGdqhz0iGoy6f))fwk27L(PfS0rdm96ueCu(DZn3ZKtnovegAMYcAVjmygjgM0mLfInZ9qUM5WSoqwtnJJaXy)On3LKXpngcT5UKFE1pTGLx()lSuSxrzHOJgy6f6FXf4gXRw4DGxnGxl8JxD4vdnWVXxlaDCeig7hGoy6f))fwk27L(PfS0rdm96ueCu(DZn3ZKtnovegAMYcAVjmygjgM0mLfInZ9qUM5WSoqwtnJJaXy)On3LKXpngcT5UKFE1pTGLx()lSuSxrzHOJgy6f6FXf4gXRw4DGxnGxl8JxD4vdnWVXxlhnhnW0l(JolQjdXlUHbjZRimWzIxCRNLuLxOhX4WjuVsy2XPrcyAVxwuyWK6fm)gvoAwuyWKQWrweg4m5i2Bu(C0SOWGjvHJSimWzcip2mgeI4OzrHbtQchzryGZeqESztRpSumHbthnW0l90WrpHIxeJH4fNgg2q8IkMq9IByqY8kcdCM4f36zj1llr8chzDGdkcl79Ir9cbMt5OzrHbtQchzryGZeqESzAA4ONq5sftOoAwuyWKQWrweg4mbKhBwGYc3GrLrA0rZIcdMufoYIWaNjG8yZZiY5D)clf7pGHDStX(LIchHfS)UFHLI9mQOwAC)qC0atVaBOZlDbsc8THBeVWrweg4mXlT8hL6ffgMxgcc1R2S)9IIZANErHWu5OzrHbtQchzryGZeqESzQajb(2WnYbmSJI9lffvGKaFB4grT04(HakkeJHCxtlfLHGqvrOwkGdm4XJymK7AAPOmeeQILGhF4HQJMffgmPkCKfHbota5XMXyKD3VWsX(dyyh7uSFPOOcKeU7xyPyVAPX9dXrZIcdMufoYIWaNjG8yZ4GcdMoAwuyWKQWrweg4mbKhBE)clf7VCVrLdyyhf7xkQ9lSuS)Y9gvulnUFioAoAGPx8hDwutgIxRPrA0lHfMxY58YIcK4fJ6L1KXEJ7NYrdm9QlYOIxG4HqKxJkEfSuZ(VrVyyEjNZl0d87imzE1nXyIxOhzCuHyVx8ZrHPLX5fJ6foYOlfLJMffgmPh5Eie51OYbmSJg(DeMmLLXrfI9xYOW0Y4ulnUFioAGPxGTPmcrdN4feZROrfQYrZIcdMuqES52Se5spNrC0SOWGjfKhBwGYc3GrLrA8ag2rX(LIsGYc3GrLrAuT04(HakNggMImkmTmURaLfuKfmwsbxdoAwuyWKcYJnJXi7UFHLI9hWWo2Py)srrfijC3VWsXE1sJ7hIJMffgmPG8yZubsc39lSuS)ag2rX(LIIkqs4UFHLI9QLg3peqrPtX(LIIfhMgPr1sJ7hcpEDYPHHPyXHPrAuPHd0oJq4JaBNkwCyAKgvA4q1rZIcdMuqES5ze58UFHLI9hWWo2Py)srHJWc2F3VWsXEgvulnUFi84j2Vuu4iSG939lSuSNrf1sJ7hcOOeHWhb2ovymYU7xyPyVISGXsk4A1aEG2Py)srrfijC3VWsXE1sJ7hcpEri8rGTtfvGKWD)clf7vKfmwsbxRgWduX(LIIkqs4UFHLI9QLg3peuD0SOWGjfKhBwJUltwG6OzrHbtkip2m3dHixmnsJhWWo2Py)srz04selJtT04(HWJhNggMYOXLiwgNsdhpEri8rGTtLrJlrSmofzbJLuWJp8C0SOWGjfKhBMBe6i8XY(dyyh7uSFPOmACjILXPwAC)q4XJtddtz04selJtPHZrZIcdMuqESzmgzCpeICad7yNI9lfLrJlrSmo1sJ7hcpECAyykJgxIyzCknC84fHWhb2ovgnUeXY4uKfmwsbp(WZrZIcdMuqESzlJJke7Vr7)dyyh7uSFPOmACjILXPwAC)q4XJtddtz04selJtPHJhVie(iW2PYOXLiwgNISGXsk4XhEoAwuyWKcYJnt0YRffgmVpJkhKwyhn4oGHD0IcRPDxUaBuW3aOOqXT)VIr6NqvXtJL3N1Fkjl7bFd84rXT)VIr6NqvV1KD5MfaFdO6OzrHbtkip2mrlVwuyW8(mQCqAHDKYY(FxXi9tC0C0atVqVAVW8sms)eVSOWGPx4imiHjn61ZOIJMffgmPkdUJubsc8THBKdyyhf7xkkQajb(2WnIAPX9dXrZIcdMuLbhip2SrJlrSmUdyyhf7xkkJgxIyzCQLg3peqrrSFPOOcKeU7xyPyVAPX9db0ie(iW2PIkqs4UFHLI9kYcglPGRvd4bAecFey7urfijC3VWsXEfzbJLuW3cF841Py)srrfijC3VWsXE1sJ7hcQoAwuyWKQm4a5XMFg6sJHCdwFWUcuw4ag2rX(LI6zOlngYny9b7kqzb1sJ7hIJMJgy6LooYmeV4hElmV0pHr(8ILEbUJGLxIr6N4fgR)uOh4fNM4vcfVq0iSS3lD(7LgoHf2bEPL)OuVAeQHUjZlmw)PWYEVadVeJ0pH6LLiEDAnnV(rPEjNw6vlWYl0hwI4f6Rgv8IkwKpQYrZIcdMuLbhip2m2BHDPNWiFheBm(7kgPFc9yRdyyhjdJm6PX9dukU9)vms)eQkEAS8(S(tjzzp4WhOO0Py)srrfijC3VWsXE1sJ7hcpEri8rGTtfvGKWD)clf7vKfmwsbxRgWJhpkU9)vms)eQkEAS8(S(tjzz)rWauonmmvBwIC71OIIkwKpW1cSq1rZrdm9QBsJEjqV6TW8I)grorxAgFZR2m50l0RrLr8cI5LCoV4)VWsH6fNggMxTpx6fgR)uyzVxGHxIr6NqvEH(Hj6w8c20irdNxOxBpviWqNoAwuyWKQm4a5XMNrKt0LMX3oGHDStX(LIkyuzKle7kN7UFHLcvT04(HWJhNggMIkqsGVnCJO0WXJxW2tfcma(JO0cp86aS6kf3()kgPFcvfpnwEFw)PKSShvE840WWubJkJCHyx5C39lSuOknC84rXT)VIr6NqvXtJL3N1Fkjl7bpy4O5ObME1fNFJEfnQ4f)YAY8ceAeQ4fm9sojBEjgPFc1lgMxmXlg1ll9ILuXsXllr8sxGKGx8)xyPyVxmQxh2f3TxwuynnLJMffgmPkdoqES53AYUCAeQCad7ikCAyyQ3AYUuns)uA44XJtddtz04selJtPHdvqP42)xXi9tOQ4PXY7Z6pLKL9GdSafLof7xkkQajH7(fwk2RwAC)q4XlcHpcSDQOcKeU7xyPyVISGXsk4A1aEO6O5ObMEb2qNx8)xyPyVxG4nQ4L1BSKkEPHZlb6fy4LyK(juVmQxpm79YOEPlqsWl()lSuS3lg1RekEzrH10uoAwuyWKQm4a5XM3VWsX(l3Bu5ag2rX(LIA)clf7VCVrf1sJ7hcOuC7)RyK(juv80y59z9NsYYEWbwGIsNI9lffvGKWD)clf7vlnUFi84fHWhb2ovubsc39lSuSxrwWyjfCTAapuD0SOWGjvzWbYJn)wt2LBw4ag2rX(LIYOXLiwgNAPX9dXrZIcdMuLbhip2C80y59z9NsYYEhnlkmysvgCG8yZV1KD50iu5GaSjw2FS1bmSJI9lfLrJlrSmo1sJ7hIJMffgmPkdoqESzS3c7spHr(oiaBIL9hBDqSX4VRyK(j0JToGHDKmmYONg3phnlkmysvgCG8yZyeivU0tyKVdcWMyz)XwoAoAoAGPx6SS)NxDBK(jEHEefgm9QljmiHjn6f)IrfhnW0l(NunY8IFq3lg1llkSMMxA5pk1RgHAEDAnnVAbwEbjEfGK5fvSiFuVGyEH(WseVqF1OIxyeyWlDbscEX)FHLI9kVqH)i9ZROrh)2lnCryGL9EHEqJEXPjEzrH108sN)8J5fcmr3IxO6OzrHbtQIYY(FxXi9toI9wyx6jmY3bmSJO0PWI8XYEE8e7xkkQajH7(fwk2RwAC)qancHpcSDQOcKeU7xyPyVISGXsk4AOR9reE8qGIc7TWU0tyKpfzbJLuWDSpIWJNy)srz04selJtT04(HakcuuyVf2LEcJ8PilySKcouIq4JaBNkJgxIyzCkYcglPGKtddtz04selJtHOrmHbtubncHpcSDQmACjILXPilySKcoWcuu6uSFPOOcKeU7xyPyVAPX9dHhpX(LIIkqs4UFHLI9QLg3peqJq4JaBNkQajH7(fwk2RilySKcUwnGhQOckNggMQnlrU9AurrflYh4AbwoAoAGPxGn05f6bnUeXY48YWKr8QrOg6UP5ff3sXl7FV4xwtMxGqJqfVINgPFuVSeXly(n6fdZRCm5CeV0fij4f))fwk27vcjEb2ghMgPrVmY8kQrilLVrVSOWAAkhnlkmysvuw2)7kgPFcip2SrJlrSmUdyyhf7xkkJgxIyzCQLg3peqrryHb(J4pE84XPHHP4Eie51OIsdhQGgHWhb2ovV1KD50iurrwWyjf84bkkDk2Vuuubsc39lSuSxT04(HWJxecFey7urfijC3VWsXEfzbJLuW3Qb8qfuu6uSFPOyXHPrAuT04(HWJxNCAyykwCyAKgvA4aTZie(iW2PIfhMgPrLgouD0C0atVq)WeDlEPrNx8)xyPyVxG4nQ4fdZRgHAEfHApIxrJkEzEHEnQmIxqmVKZ5f))fwkuVwahS9idXl(Be50l9tyKpVyjvMHO8c9dt0T4v0OIx8)xyPyVxG4nQ4fIgHL9EPlqsWl()lSuS3lT8hL6vJqnVoTMMxGb641HMOrS3l(XnsaMn6fl9Q9jlE6v0OZRgHAErfioV0OSS3l()lSuS3lq8gv8cMX5vJqnViZINE1cS8IkwKpQxqmVqFyjIxOVAur5OzrHbtQIYY(FxXi9ta5XM3VWsX(l3Bu5ag2rX(LIA)clf7VCVrf1sJ7hcOOi2VuubJkJCHyx5C39lSuOQLg3peq50WWubJkJCHyx5C39lSuOknCGgS9uHadGd)XJhVof7xkQGrLrUqSRCU7(fwku1sJ7hcQGIsNOeHWhb2ovubsc39lSuSxrwWyjf8TAapqf7xkkQajH7(fwk2RwAC)qqLhpd)octMknrJy)90iby2OIyjFhbdq50WWuTzjYTxJkkQyr(axlWcvhnhnW0l(rB48sNFKxyqIxVr6NxqIxuim9Yqq8QT10OkVaBYFuQxnc1860AAEPRr6NxqmV6sy7roWlw6v7tw80ROrNxnc18QTLIxc0leOg3pV40WW8IFX6pLKL9Ebc4lEX1Ox4GWNL9EHET9uHadEXnmizNwIO8I)OJfW9Zl6qxAlJJF7vl8Wd9QFGx8x)aV05hDGx8lqCGx8RMaXbEXF9d8IFbchnlkmysvuw2)7kgPFcip2mvGKaFB4g5ag2rX(LIIkqsGVnCJOwAC)qaffIXqURPLIYqqOQiulfWbg84rmgYDnTuugccvXsWJp8qfuu6uSFPOOAK(DHyxCW2JOwAC)q4XJtddtr1i97cXU4GThrPHJhVGTNkeya8hblWcvhnlkmysvuw2)7kgPFcip28ZqxAmKBW6d2vGYchWWok2VuupdDPXqUbRpyxbklOwAC)qaffIXqURPLIYqqOQiulfWbg84rmgYDnTuugccvXsWJp8q1rZrdm9Qlcg4y58sxGKaFB4gXR2m50l0RrLr8cI5LCoV4)VWsH6fK4LUgPFEbX8QlHThr5OzrHbtQIYY(FxXi9ta5XMFw)PKSS)YbF5ag2ronmmfvGKaFB4grPHdukU9)vms)eQkEAS8(S(tjzzp4Aauu40WWubJkJCHyx5C39lSuOknCG2Py)srr1i97cXU4GThrT04(HWJhNggMIQr63fIDXbBpIsdhQoAoAGPxDFoY8kW6pfVIWW8YsV0WHyY8cds8sozuVEwoVAZKtVOWW8sh2LE9WEwu5OzrHbtQIYY(FxXi9ta5XMNrKt0LMX3oGHD0IcRPDxUaBuW3cukU9)vms)eQkEAS8(S(tjzzp4BbkkDk2Vuuuns)UqSloy7rulnUFi841jcuuyVf2LEcJ8PidJm6PX9JhVie(iW2PIkqs4UFHLI9kYcglPGVvd4HkOO0Py)srfmQmYfIDLZD3VWsHQwAC)q4XJtddtfmQmYfIDLZD3VWsHQ0WXJxW2tfcma(JDHgq1rZrdm9ceWgvkv7tt8Y8kcteMWGPYl0hMC6f61OYiEbX8soNx8)xyPq9che(EHET9uHadEPHZlb6f(Xl0RTNkeyWlU9W2EjNZROHZlb61sQgzEXe0n1ln6q8Qnto9I)gro9s)eg5t5f6dtoHAIxOxJkJ4feZl5CEX)FHLc9aV0OZl(Be50l9tyKpVgtohXlgMx6cKe4Bd3iEXOEPH7aVqV2EQqGbVyuVAHNxOxBpviWGxC7HT9soNxrdNxqIx)O0d8cs8Am5CeV0fij4f))fwk27fJMOBXlX(LYq8cs8IjOBQxju8YIcRP5LLiE1iuJ41BuXlDbscEX)FHLI9EbX8soNxyS(tXR2S)960AAEbZVrVmVWzeHzVxiAetyWu5OzrHbtQIYY(FxXi9ta5XMNrKZl9eg57ag2Xo50WWuuns)UqSloy7ruA4avSFPOcgvg5cXUY5U7xyPqvlnUFiGIcNggMkyuzKle7kN7UFHLcvPHJhVGTNkeya8h7cnasWaVUk2Vuur7)RCURCQLiJOwAC)q4XJtddtrfijW3gUruA4a1IcRPDxUaBuW1aQ841Py)srfmQmYfIDLZD3VWsHQwAC)qaffonmmfvGKaFB4grPHJhVGTNkeya8h7c4bsWaVUk2Vuur7)RCURCQLiJOwAC)q4XRtuIq4JaBNkQajH7(fwk2RilySKc(wnGhOI9lffvGKWD)clf7vlnUFiOc6qhClkd5gHbotU)YE5SdHfwhri8rGTtfvGKWD)clf7vKfmws7Of(WRRypesqbLHo4wugYncdCMC)L9YzhclSoIq4JaBNkQajH7(fwk2RilySKIkyVf(WdvWFemWRRO0cKOy43ryYulEcVqSRCU7(fwk2tvel5d8hBavur1rZrdm9cSHoV4VrKtV0pHr(8IH5LUgPFEbX8QlHThXlg1lX(LYqoWlonXRCm5CeVyIxjK4L5f6Vl19I))clf79Ir9YIcRP5LjEjNZRamSuoWllr8IFznzEbcncv8Ir9ImdPrVGeVAZ(3lU5vBMCYsVKZ5vo0r8c9Tlc9RC0SOWGjvrzz)VRyK(jG8yZZiY5LEcJ8Dad7Oy)srr1i97cXU4GThrT04(HaANCAyykQgPFxi2fhS9iknCGgHWhb2ovV1KD50iurrwWyjfCh7JiGIsNI9lffvGKWD)clf7vlnUFiG2jkri8rGTtfgJS7(fwk2RilySKc(wnGhQ84j2Vuuubsc39lSuSxT04(HaANOeHWhb2ovubsc39lSuSxrwWyjf8TAapur1rZrdm9QlYOIx8lw)PKSS3lqaFH6fIgHL9EPlqsWl()lSuS3lenIjmyQC0SOWGjvrzz)VRyK(jG8yZpR)usw2F5GVCad7yecFey7urfijC3VWsXEfzbJLuW3Qb8avSFPOOcKeU7xyPyVAPX9dXrZrdm9cSHoV4hiqQ4L(jmYNxTzYPxGTXHPrA0llr8c9AuzeVGyEjNZl()lSuOkhnlkmysvuw2)7kgPFcip2mgbsLl9eg57ag2rX(LIIfhMgPr1sJ7hcOI9lfvWOYixi2vo3D)clfQAPX9dbuonmmflomnsJknCGYPHHPcgvg5cXUY5U7xyPqvA4C0SOWGjvrzz)VRyK(jG8yZV1KD50iu5ag2ronmmLrJlrSmoLgohnhnW0lWgH9m878sxJ0pVGyE1LW2J4La9IIJmdXl(H3cZl9tyKpVyyEf0EHH7NxlxGnQxgzEHJm6sr5OzrHbtQIYY(FxXi9ta5XMXElSl9eg57GyJXFxXi9tOhBDad7izyKrpnUFGArH10UlxGnk4BbkNggMIQr63fIDXbBpIsdNJMJgy6fydDEXVSMmVaHgHkE1MjNEPRr6NxqmV6sy7r8IH5LCoVEJkEHdklfM9EPrT(5feZlZl0FxQ7f))fwk271Prt0T4L5fM2)EHOrmHbtV6I5NEXW8QrOMxrO2J4v)eVSekNJ4Lg16NxqmVKZ5f6Vl19I))clf79IH5LCoVilySKL9EHX6pfVABuVAH)GDVEy2pIYrZIcdMufLL9)UIr6NaYJn)wt2LtJqLdyyhf7xkkQajH7(fwk2RwAC)qancHpcSDEjZIcOCAyykQgPFxi2fhS9iknCGIYqhClkd5gHbotU)YE5SdHfwhri8rGTtfvGKWD)clf7vKfmws7Of(WRRypesqbLHo4wugYncdCMC)L9YzhclSoIq4JaBNkQajH7(fwk2RilySKIkyVf(WdvWbg41vuAbsum87imzQfpHxi2vo3D)clf7PkIL8b(JnGkQ84Hslvl8VROm0b3IYqUryGZK7VSxo7qyHHAhri8rGTtfvGKWD)clf7vKfmws7Of(WRRypesqbLwQw4FxrzOdUfLHCJWaNj3FzVC2HWcd1oIq4JaBNkQajH7(fwk2RilySKIkyVf(WdvubhkdDWTOmKBeg4m5(l7LZoewyDeHWhb2ovubsc39lSuSxrwWyjTJw4dVUI9qibfug6GBrzi3imWzY9x2lNDiSW6icHpcSDQOcKeU7xyPyVISGXskQG9w4dpurfvhnhnW0lWg68IFznzEbcncv8Qnto9sxJ0pVGyE1LW2J4fdZl5CE9gv8chuwkm79sJA9ZliMxMxO)Uu3l()lSuS3RtJMOBXlZlmT)9crJycdME1fZp9IH5vJqnVIqThXR(jEzjuohXlnQ1pVGyEjNZl0FxQ7f))fwk27fdZl5CErwWyjl79cJ1FkE12OE1c)b7E9WSFeLJMffgmPkkl7)DfJ0pbKhB(TMSlNgHkhWWo2Py)srrfijC3VWsXE1sJ7hcOri8rGTZlzwuaLtddtr1i97cXU4GThrPHduug6GBrzi3imWzY9x2lNDiSW6icHpcSDQWyKD3VWsXEfzbJL0oAHp86k2dHeuqzOdUfLHCJWaNj3FzVC2HWcRJie(iW2PcJr2D)clf7vKfmwsrfS3cF4Hk4ad86kkTajkg(DeMm1INWle7kN7UFHLI9ufXs(a)XgqfvE8qPLQf(3vug6GBrzi3imWzY9x2lNDiSWqTJie(iW2PcJr2D)clf7vKfmws7Of(WRRypesqbLwQw4FxrzOdUfLHCJWaNj3FzVC2HWcd1oIq4JaBNkmgz39lSuSxrwWyjfvWEl8HhQOcoug6GBrzi3imWzY9x2lNDiSW6icHpcSDQWyKD3VWsXEfzbJL0oAHp86k2dHeuqzOdUfLHCJWaNj3FzVC2HWcRJie(iW2PcJr2D)clf7vKfmwsrfS3cF4HkQO6OzrHbtQIYY(FxXi9ta5XMFw)PKSS)YbF5ag2ronmmfvJ0Vle7Id2EeLgohnlkmysvuw2)7kgPFcip28BnzxoncvoGHDmcHpcSDEjZIIJMJgy6f6hMOBXllgzilf7)g9sJoV01i9ZliMxDjS9iE1MjNEXp8wyEPFcJ85fIgHL9Erzz)pVeJ0pr5OzrHbtQIYY(FxXi9ta5XMXElSl9eg57GyJXFxXi9tOhBDad7izyKrpnUFG2jNggMIQr63fIDXbBpIsdNJMffgmPkkl7)DfJ0pbKhBwGYc3GrLrA8ag2rX(LIsGYc3GrLrAuT04(HakkCAyykYOW0Y4UcuwqrwWyjfC4ppEOWPHHPiJctlJ7kqzbfzbJLuWHcNggMYOXLiwgNcrJycdMGmcHpcSDQmACjILXPilySKIkOri8rGTtLrJlrSmofzbJLuW1cFOIQJMJgy6L(Z6pLVrV6TW8cSnomnsJEXPHH5La96eIByA)3OxCAyyErHH5vBMC6f61OYiEbX8soNx8)xyPqvoAwuyWKQOSS)3vms)eqESzmcKkx6jmY3bmSJI9lfflomnsJQLg3peq50WWuS4W0inQ0WbkkCAyykwCyAKgvKfmwsbxFePRGvx50WWuS4W0inQOIf5JhponmmfvGKaFB4grPHJhVof7xkQGrLrUqSRCU7(fwku1sJ7hcQoAwuyWKQOSS)3vms)eqESzwCyAKgpGHDuSFPOyXHPrAuT04(H4OzrHbtQIYY(FxXi9ta5XMFw)PKSS)YbFXrZIcdMufLL9)UIr6NaYJnJ9wyx6jmY3bbytSS)yRdIng)DfJ0pHES1bmSJKHrg904(5OzrHbtQIYY(FxXi9ta5XMXElSl9eg57GaSjw2FS1bmSJbytlSuuimQyzCGh)D0C0atV4hiqQ4L(jmYNxmQxqnIxbytlSu8cJ9)ikhnlkmysvuw2)7kgPFcip2mgbsLl9eg57GaSjw2FSfGEtJqzWe4WgWRf(PvdTWt1qdGf6jGEBJKSSNcOJ(GEWppeS9q0x(TxE1958IfWbjIxyqIxOBdo0TxKHU0yKH4ffgMxMMadMmeVINw2pQYrR7Z5fg8FyBw27LPrmQxThzEPrhIxS0l5CEzrHbtVEgv8Itt8Q9iZRekEHb1seVyPxY58YqqGPxiMyCgD8BhnV6WR2Se52Rrfhnhn0h0d(5HGThI(YV9YRUpNxSaoir8cds8cDtzz)VRyK(jOBVidDPXidXlkmmVmnbgmziEfpTSFuLJw3NZlm4)W2SS3ltJyuVApY8sJoeVyPxY58YIcdME9mQ4fNM4v7rMxju8cdQLiEXsVKZ5LHGatVqmX4m643oAE1HxTzjYTxJkoAoAGTbCqImeValVSOWGPxpJkuLJgGUPjNqcGUolO9MWGzxeXWea9Nrfkq3a6uw2)7kgPFcq3ah2cOBa9Lg3peaqaOhjmzeMbOJIxD6LWI8XYEV4XZlX(LIIkqs4UFHLI9QLg3peVa1Rie(iW2PIkqs4UFHLI9kYcglPEboVAWRU6vFeXlE88cbkkS3c7spHr(uKfmws9cCh9QpI4fpEEj2VuugnUeXY4ulnUFiEbQxiqrH9wyx6jmYNISGXsQxGZlu8kcHpcSDQmACjILXPilySK6fi9Itddtz04selJtHOrmHbtVq1lq9kcHpcSDQmACjILXPilySK6f48cS8cuVqXRo9sSFPOOcKeU7xyPyVAPX9dXlE88sSFPOOcKeU7xyPyVAPX9dXlq9kcHpcSDQOcKeU7xyPyVISGXsQxGZRwnGNxO6fQEbQxCAyyQ2Se52RrffvSiFEboVAbwa6wuyWeqh7TWU0tyKpab4Wga6gqFPX9dbaea6rctgHza6I9lfLrJlrSmo1sJ7hIxG6fkEjSW8c8h9c)XZlE88ItddtX9qiYRrfLgoVq1lq9kcHpcSDQERj7YPrOIISGXsQxG3l88cuVqXRo9sSFPOOcKeU7xyPyVAPX9dXlE88kcHpcSDQOcKeU7xyPyVISGXsQxG3RwnGNxO6fOEHIxD6Ly)srXIdtJ0OAPX9dXlE88QtV40WWuS4W0inQ0W5fOE1Pxri8rGTtflomnsJknCEHkGUffgmb0nACjILXbiahcgaDdOV04(Haaca9iHjJWmaDX(LIA)clf7VCVrf1sJ7hIxG6fkEj2VuubJkJCHyx5C39lSuOQLg3peVa1lonmmvWOYixi2vo3D)clfQsdNxG6vW2tfcm4f48c)XZlE88QtVe7xkQGrLrUqSRCU7(fwku1sJ7hIxO6fOEHIxD6fkEfHWhb2ovubsc39lSuSxrwWyj1lW7vRgWZlq9sSFPOOcKeU7xyPyVAPX9dXlu9IhpVm87imzQ0enI93tJeGzJkIL851rVadVa1lonmmvBwIC71OIIkwKpVaNxTalVqfq3IcdMa67xyPy)L7nQaiahcwaDdOV04(Haaca9iHjJWmaDX(LIIkqsGVnCJOwAC)q8cuVqXlIXqURPLIYqqOQiulfVaNxGHx845fXyi310srziiufl9c8EHp88cvVa1lu8QtVe7xkkQgPFxi2fhS9iQLg3peV4XZlonmmfvJ0Vle7Id2EeLgoV4XZRGTNkeyWlWF0lWcS8cvaDlkmycOtfijW3gUraeGdXhq3a6lnUFiaGaqpsyYimdqxSFPOEg6sJHCdwFWUcuwqT04(H4fOEHIxeJHCxtlfLHGqvrOwkEboVadV4XZlIXqURPLIYqqOkw6f49cF45fQa6wuyWeq)zOlngYny9b7kqzbab4q8hOBa9Lg3peaqaOhjmzeMbOZPHHPOcKe4Bd3iknCEbQxuC7)RyK(juv80y59z9NsYYEVaNxn4fOEHIxCAyyQGrLrUqSRCU7(fwkuLgoVa1Ro9sSFPOOAK(DHyxCW2JOwAC)q8IhpV40WWuuns)UqSloy7ruA48cvaDlkmycO)S(tjzz)Ld(cGaCi6jq3a6lnUFiaGaqpsyYimdq3IcRPDxUaBuVaVxT8cuVO42)xXi9tOQ4PXY7Z6pLKL9EbEVA5fOEHIxD6Ly)srr1i97cXU4GThrT04(H4fpEE1PxiqrH9wyx6jmYNImmYONg3pV4XZRie(iW2PIkqs4UFHLI9kYcglPEbEVA1aEEHQxG6fkE1PxI9lfvWOYixi2vo3D)clfQAPX9dXlE88ItddtfmQmYfIDLZD3VWsHQ0W5fpEEfS9uHadEb(JE1fAWlub0TOWGjG(mICIU0m(gGaCi(bOBa9Lg3peaqaOhjmzeMbO3PxCAyykQgPFxi2fhS9iknCEbQxI9lfvWOYixi2vo3D)clfQAPX9dXlq9cfV40WWubJkJCHyx5C39lSuOknCEXJNxbBpviWGxG)OxDHg8cKEbg45vx9sSFPOI2)x5Cx5ulrgrT04(H4fpEEXPHHPOcKe4Bd3iknCEbQxwuynT7YfyJ6f48QbVq1lE88QtVe7xkQGrLrUqSRCU7(fwku1sJ7hIxG6fkEXPHHPOcKe4Bd3iknCEXJNxbBpviWGxG)OxDb88cKEbg45vx9sSFPOI2)x5Cx5ulrgrT04(H4fpEE1PxO4vecFey7urfijC3VWsXEfzbJLuVaVxTAapVa1lX(LIIkqs4UFHLI9QLg3peVq1lq9AOdUfLHCJWaNj3FzVC6vhEjSW8QdVIq4JaBNkQajH7(fwk2RilySK6vhE1cF45vx9c7HqIxO4fkEn0b3IYqUryGZK7VSxo9QdVewyE1Hxri8rGTtfvGKWD)clf7vKfmws9cvVa7E1cF45fQEb(JEbg45vx9cfVA5fi9cfVm87imzQfpHxi2vo3D)clf7PkIL85f4p6vdEHQxO6fQa6wuyWeqFgroV0tyKpab4WUaq3a6lnUFiaGaqpsyYimdqxSFPOOAK(DHyxCW2JOwAC)q8cuV60lonmmfvJ0Vle7Id2EeLgoVa1Rie(iW2P6TMSlNgHkkYcglPEbUJE1hr8cuVqXRo9sSFPOOcKeU7xyPyVAPX9dXlq9QtVqXRie(iW2PcJr2D)clf7vKfmws9c8E1Qb88cvV4XZlX(LIIkqs4UFHLI9QLg3peVa1Ro9cfVIq4JaBNkQajH7(fwk2RilySK6f49Qvd45fQEHkGUffgmb0NrKZl9eg5dqaoSfEaDdOV04(Haaca9iHjJWma9ie(iW2PIkqs4UFHLI9kYcglPEbEVA1aEEbQxI9lffvGKWD)clf7vlnUFia6wuyWeq)z9NsYY(lh8fab4WwTa6gqFPX9dbaea6rctgHza6I9lfflomnsJQLg3peVa1lX(LIkyuzKle7kN7UFHLcvT04(H4fOEXPHHPyXHPrAuPHZlq9ItddtfmQmYfIDLZD3VWsHQ0WbOBrHbtaDmcKkx6jmYhGaCyRga6gqFPX9dbaea6rctgHza6CAyykJgxIyzCknCa6wuyWeq)TMSlNgHkacWHTadGUb0xAC)qaabGEKWKrygGozyKrpnUFEbQxwuynT7YfyJ6f49QLxG6fNggMIQr63fIDXbBpIsdhGUffgmb0XElSl9eg5dqp2y83vms)ekWHTaeGdBbwaDdOV04(Haaca9iHjJWmaDX(LIIkqs4UFHLI9QLg3peVa1Rie(iW25LmlkEbQxCAyykQgPFxi2fhS9iknCEbQxO41qhClkd5gHbotU)YE50Ro8syH5vhEfHWhb2ovubsc39lSuSxrwWyj1Ro8Qf(WZRU6f2dHeVqXlu8AOdUfLHCJWaNj3FzVC6vhEjSW8QdVIq4JaBNkQajH7(fwk2RilySK6fQEb29Qf(WZlu9cCEbg45vx9cfVA5fi9cfVm87imzQfpHxi2vo3D)clf7PkIL85f4p6vdEHQxO6fpEEHIxTuTWFV6QxO41qhClkd5gHbotU)YE50Ro8syH5fQE1Hxri8rGTtfvGKWD)clf7vKfmws9QdVAHp88QREH9qiXlu8cfVAPAH)E1vVqXRHo4wugYncdCMC)L9YPxD4LWcZlu9QdVIq4JaBNkQajH7(fwk2RilySK6fQEb29Qf(WZlu9cvVaNxO41qhClkd5gHbotU)YE50Ro8syH5vhEfHWhb2ovubsc39lSuSxrwWyj1Ro8Qf(WZRU6f2dHeVqXlu8AOdUfLHCJWaNj3FzVC6vhEjSW8QdVIq4JaBNkQajH7(fwk2RilySK6fQEb29Qf(WZlu9cvVqfq3IcdMa6V1KD50iubqaoSf(a6gqFPX9dbaea6rctgHza6D6Ly)srrfijC3VWsXE1sJ7hIxG6vecFey78sMffVa1lonmmfvJ0Vle7Id2EeLgoVa1lu8AOdUfLHCJWaNj3FzVC6vhEjSW8QdVIq4JaBNkmgz39lSuSxrwWyj1Ro8Qf(WZRU6f2dHeVqXlu8AOdUfLHCJWaNj3FzVC6vhEjSW8QdVIq4JaBNkmgz39lSuSxrwWyj1lu9cS7vl8HNxO6f48cmWZRU6fkE1Ylq6fkEz43ryYulEcVqSRCU7(fwk2tvel5ZlWF0Rg8cvVq1lE88cfVAPAH)E1vVqXRHo4wugYncdCMC)L9YPxD4LWcZlu9QdVIq4JaBNkmgz39lSuSxrwWyj1Ro8Qf(WZRU6f2dHeVqXlu8QLQf(7vx9cfVg6GBrzi3imWzY9x2lNE1HxclmVq1Ro8kcHpcSDQWyKD3VWsXEfzbJLuVq1lWUxTWhEEHQxO6f48cfVg6GBrzi3imWzY9x2lNE1HxclmV6WRie(iW2PcJr2D)clf7vKfmws9QdVAHp88QREH9qiXlu8cfVg6GBrzi3imWzY9x2lNE1HxclmV6WRie(iW2PcJr2D)clf7vKfmws9cvVa7E1cF45fQEHQxOcOBrHbta93AYUCAeQaiah2c)b6gqFPX9dbaea6rctgHza6CAyykQgPFxi2fhS9iknCa6wuyWeq)z9NsYY(lh8fab4WwONaDdOV04(Haaca9iHjJWma9ie(iW25Lmlka6wuyWeq)TMSlNgHkacWHTWpaDdOV04(Haaca9iHjJWmaDYWiJEAC)8cuV60lonmmfvJ0Vle7Id2EeLgoaDlkmycOJ9wyx6jmYhGESX4VRyK(juGdBbiah2Qla0nG(sJ7hcaia0JeMmcZa0f7xkkbklCdgvgPr1sJ7hIxG6fkEXPHHPiJctlJ7kqzbfzbJLuVaNx4Vx845fkEXPHHPiJctlJ7kqzbfzbJLuVaNxO4fNggMYOXLiwgNcrJycdMEbsVIq4JaBNkJgxIyzCkYcglPEHQxG6vecFey7uz04selJtrwWyj1lW5vl85fQEHkGUffgmb0fOSWnyuzKgbeGdBapGUb0xAC)qaabGEKWKrygGUy)srXIdtJ0OAPX9dXlq9ItddtXIdtJ0OsdNxG6fkEXPHHPyXHPrAurwWyj1lW5vFeXRU6fy5vx9ItddtXIdtJ0OIkwKpV4XZlonmmfvGKaFB4grPHZlE88QtVe7xkQGrLrUqSRCU7(fwku1sJ7hIxOcOBrHbtaDmcKkx6jmYhGaCydTa6gqFPX9dbaea6rctgHza6I9lfflomnsJQLg3peaDlkmycOZIdtJ0iGaCydna0nGUffgmb0Fw)PKSS)YbFbqFPX9dbaeacWHnagaDdOV04(HaacaDlkmycOJ9wyx6jmYhGESX4VRyK(juGdBbOhGnXYEa9wa6rctgHza6KHrg904(biah2ayb0nG(sJ7hcaia0dWMyzpGElaDlkmycOJ9wyx6jmYhGEKWKrygGEa20clffcJkwgNxG3l8hqaoSb8b0nGEa2el7b0BbOBrHbtaDmcKkx6jmYhG(sJ7hcaiaeabq3GdOBGdBb0nG(sJ7hcaia0JeMmcZa0f7xkkQajb(2WnIAPX9dbq3IcdMa6ubsc8THBeab4Wga6gqFPX9dbaea6rctgHza6I9lfLrJlrSmo1sJ7hIxG6fkEj2Vuuubsc39lSuSxT04(H4fOEfHWhb2ovubsc39lSuSxrwWyj1lW5vRgWZlq9kcHpcSDQOcKeU7xyPyVISGXsQxG3Rw4ZlE88QtVe7xkkQajH7(fwk2RwAC)q8cvaDlkmycOB04selJdqaoema6gqFPX9dbaea6rctgHza6I9lf1ZqxAmKBW6d2vGYcQLg3peaDlkmycO)m0Lgd5gS(GDfOSaGaCiyb0nG(sJ7hcaia0JeMmcZa0jdJm6PX9Zlq9IIB)FfJ0pHQINglVpR)usw27f48cFEbQxO4vNEj2Vuuubsc39lSuSxT04(H4fpEEfHWhb2ovubsc39lSuSxrwWyj1lW5vRgWZlE88IIB)FfJ0pHQINglVpR)usw271rVadVa1lonmmvBwIC71OIIkwKpVaNxTalVqfq3IcdMa6yVf2LEcJ8bOhBm(7kgPFcf4WwacWH4dOBa9Lg3peaqaOhjmzeMbO3PxI9lfvWOYixi2vo3D)clfQAPX9dXlE88ItddtrfijW3gUruA48IhpVc2EQqGbVa)rVqXRw4HNxD4fy5vx9IIB)FfJ0pHQINglVpR)usw27fQEXJNxCAyyQGrLrUqSRCU7(fwkuLgoV4XZlkU9)vms)eQkEAS8(S(tjzzVxG3lWaq3IcdMa6ZiYj6sZ4BacWH4pq3a6lnUFiaGaqpsyYimdqhfV40WWuV1KDPAK(P0W5fpEEXPHHPmACjILXP0W5fQEbQxuC7)RyK(juv80y59z9NsYYEVaNxGLxG6fkE1PxI9lffvGKWD)clf7vlnUFiEXJNxri8rGTtfvGKWD)clf7vKfmws9cCE1Qb88cvaDlkmycO)wt2LtJqfab4q0tGUb0xAC)qaabGEKWKrygGUy)srTFHLI9xU3OIAPX9dXlq9IIB)FfJ0pHQINglVpR)usw27f48cS8cuVqXRo9sSFPOOcKeU7xyPyVAPX9dXlE88kcHpcSDQOcKeU7xyPyVISGXsQxGZRwnGNxOcOBrHbta99lSuS)Y9gvaeGdXpaDdOV04(Haaca9iHjJWmaDX(LIYOXLiwgNAPX9dbq3IcdMa6V1KD5MfaeGd7caDdOBrHbta94PXY7Z6pLKL9a6lnUFiaGaqaoSfEaDdOV04(Haaca9aSjw2dO3cq3IcdMa6V1KD50iubqpsyYimdqxSFPOmACjILXPwAC)qaeGdB1cOBa9Lg3peaqaOBrHbtaDS3c7spHr(a0Jng)DfJ0pHcCyla9aSjw2dO3cqpsyYimdqNmmYONg3pab4Wwna0nGEa2el7b0BbOBrHbtaDmcKkx6jmYhG(sJ7hcaiaeabqhzyM2laDdCylGUb0xAC)qa4a0JeMmcZa0n87imzklJJke7VKrHPLXPwAC)qa0TOWGjGo3dHiVgvaeGdBaOBaDlkmycO3MLix65mcG(sJ7hcaiaeGdbdGUb0xAC)qaabGEKWKrygGUy)srjqzHBWOYinQwAC)q8cuV40WWuKrHPLXDfOSGISGXsQxGZRga0TOWGjGUaLfUbJkJ0iGaCiyb0nG(sJ7hcaia0JeMmcZa070lX(LIIkqs4UFHLI9QLg3peaDlkmycOJXi7UFHLI9acWH4dOBa9Lg3peaqaOhjmzeMbOl2Vuuubsc39lSuSxT04(H4fOEHIxD6Ly)srXIdtJ0OAPX9dXlE88QtV40WWuS4W0inQ0W5fOE1Pxri8rGTtflomnsJknCEHkGUffgmb0PcKeU7xyPypGaCi(d0nG(sJ7hcaia0JeMmcZa070lX(LIchHfS)UFHLI9mQOwAC)q8IhpVe7xkkCewW(7(fwk2ZOIAPX9dXlq9cfVIq4JaBNkmgz39lSuSxrwWyj1lW5vRgWZlq9QtVe7xkkQajH7(fwk2RwAC)q8IhpVIq4JaBNkQajH7(fwk2RilySK6f48Qvd45fOEj2Vuuubsc39lSuSxT04(H4fQa6wuyWeqFgroV7xyPypGaCi6jq3a6wuyWeqxJUltwGcOV04(Haacab4q8dq3a6lnUFiaGaqpsyYimdqVtVe7xkkJgxIyzCQLg3peV4XZlonmmLrJlrSmoLgoV4XZRie(iW2PYOXLiwgNISGXsQxG3l8HhGUffgmb05Eie5IPrAeqaoSla0nG(sJ7hcaia0JeMmcZa070lX(LIYOXLiwgNAPX9dXlE88Itddtz04selJtPHdq3IcdMa6CJqhHpw2diah2cpGUb0xAC)qaabGEKWKrygGENEj2VuugnUeXY4ulnUFiEXJNxCAyykJgxIyzCknCEXJNxri8rGTtLrJlrSmofzbJLuVaVx4dpaDlkmycOJXiJ7Hqeab4WwTa6gqFPX9dbaea6rctgHza6D6Ly)srz04selJtT04(H4fpEEXPHHPmACjILXP0W5fpEEfHWhb2ovgnUeXY4uKfmws9c8EHp8a0TOWGjGULXrfI93O9pGaCyRga6gqFPX9dbaea6wuyWeqNOLxlkmyEFgva0JeMmcZa0TOWAA3LlWg1lW7vdEbQxO4ff3()kgPFcvfpnwEFw)PKSS3lW7vdEXJNxuC7)RyK(ju1BnzxUzbVaVxn4fQa6pJk30cdq3GdqaoSfya0nG(sJ7hcaia0TOWGjGorlVwuyW8(mQaO)mQCtlmaDkl7)DfJ0pbqaeaDCKfHbota6g4WwaDdOV04(Haacab4Wga6gqFPX9dbaeacWHGbq3a6lnUFiaGaqaoeSa6gqFPX9dbaeacWH4dOBaDlkmycOlqzHBWOYincOV04(Haacab4q8hOBa9Lg3peaoa9iHjJWma9o9sSFPOWryb7V7xyPypJkQLg3peaDlkmycOpJiN39lSuShqaoe9eOBa9Lg3peaqaOhjmzeMbOl2Vuuubsc8THBe1sJ7hIxG6fkErmgYDnTuugccvfHAP4f48cm8IhpVigd5UMwkkdbHQyPxG3l8HNxOcOBrHbtaDQajb(2WncGaCi(bOBa9Lg3peaqaOhjmzeMbO3PxI9lffvGKWD)clf7vlnUFia6wuyWeqhJr2D)clf7beGd7caDdOBrHbtaDCqHbta9Lg3peaqaiah2cpGUb0xAC)qaabGEKWKrygGUy)srTFHLI9xU3OIAPX9dbq3IcdMa67xyPy)L7nQaiacGaiacaa]] )


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
