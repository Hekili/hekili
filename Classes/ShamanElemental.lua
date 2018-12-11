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

    
    spec:RegisterPack( "Elemental", 20181210.2247, [[d4eJBbqiPIEequxcuLAtaPpbQsgfO4uGsRsQeVcOywQa3sQWUi5xsjnmOkhtkAzsjEgqKPbQIRbQQTbvv9nPsQmouvPohuvQ1HQk5DsLuK5bu6EQq7dOQdcvfSqvqpuQKsteQQ4IOQQncvL0hHQsmsPskQtcuHwjOYlLkPWmrvfDtOQODce(PujvnuPsYsrvfEkPAQsL6QavWxHQcTxa)vLgSKdtzXOYJfAYGCzLndLplvnAv0Pr51OQmBvDBb7w0VHmCOYXbQOLJ45inDIRtkBxk03LsnEGkDEPG1dvvA(Ok7NQbAc0nGoKjdaeTGxt(DZwAINQLwGpibF8nGU0aUbOJZI8z9dqpTWa05)VWsXEaDCwdpYGa6gqNI0iXbOFkcok)Q1w7zYPgNkIcTszbT3egkJedtALYcXw5EexRCywhqRXwXrqySF0w7kY4hgdI2AxXpU6NwWYl))fwk2ROSqeqNtJ9c4ycWbOdzYaarl41KF3SLM4PAPf4dsWhKa0P4weaeTG)TaOFYGGwcWbOdnAeqhK9I))clf79s)0cw6WbYEDkcok)Q1w7zYPgNkIcTszbT3egkJedtALYcXw5EexRCywhqRXwXrqySF0w7kY4hgdI2AxXpU6NwWYl))fwk2ROSq0HdK9c)S4cCJ4vt8oWRwWRj)2Ro8QLw4xWVjGooccJ9dqhK9I))clf79s)0cw6WbYEDkcok)Q1w7zYPgNkIcTszbT3egkJedtALYcXw5EexRCywhqRXwXrqySF0w7kY4hgdI2AxXpU6NwWYl))fwk2ROSq0HdK9c)S4cCJ4vt8oWRwWRj)2Ro8QLw4xWVPdNdhi7f)b3f1Kb5f3WqK5vef4mXlU1ZsQYl8HyC4eQxjk740ibmT3llkmus9cLFdkholkmusv4ilIcCMCe7nkFoCwuyOKQWrwef4mbmhBfdHGC4SOWqjvHJSikWzcyo2QP1hwkMWqPdhi7LEA4ONiXlIXG8ItddBqErftOEXnmezEfrbot8IB9SK6LLqEHJSoWHeHL9EXOEbHYPC4SOWqjvHJSikWzcyo2knnC0tKCPIjuholkmusv4ilIcCMaMJTkizHBWOYin4WzrHHsQchzruGZeWCS1ze58UFHLI9hWWo2Py)srHJWc2F3VWsXEgvulnUFqoCGSxGd05LUGib(2WnIx4ilIcCM4Lw(Js9IIcZldcI6vB2)ErXzTtVOiuQC4SOWqjvHJSikWzcyo2kvqKaFB4g5ag2rX(LIIkisGVnCJOwAC)GafgIXGURXLIYGGOQislfWcs84rmg0DnUuugeevXsWdF8G1HZIcdLufoYIOaNjG5yRymYU7xyPy)bmSJDk2Vuuubrc39lSuSxT04(b5WzrHHsQchzruGZeWCSvCiHHsholkmusv4ilIcCMaMJTUFHLI9xU3OYbmSJI9lf1(fwk2F5EJkQLg3pihohoq2l(dUlQjdYR14in4LWcZl5CEzrbr8Ir9YA0yVX9t5WbYE11AuXRdFec61OIxbl1S)BWlgMxY58cFa)octMxDtmM4f(qghvi27f)yuuAzCEXOEHJm6sr5WzrHHs6rUhHGEnQCad7OHFhHjtzzCuHy)LmkkTmo1sJ7hKdhi7f4ykJq0WjEHW8kAuHQC4SOWqjfmhBTnlHU0ZzeholkmusbZXwfKSWnyuzKgoGHDuSFPOeKSWnyuzKgulnUFqGYPHHPiJIslJ7kizbfzbJLuW2IdNffgkPG5yRymYU7xyPy)bmSJDk2Vuuubrc39lSuSxT04(b5WzrHHskyo2kvqKWD)clf7pGHDuSFPOOcIeU7xyPyVAPX9dcuy6uSFPOyXHPrAqT04(bXJxNCAyykwCyAKguA4aTZic9qO2PIfhMgPbLgoyD4SOWqjfmhBDgroV7xyPy)bmSJDk2Vuu4iSG939lSuSNrf1sJ7hepEI9lffocly)D)clf7zurT04(bbkmre6HqTtfgJS7(fwk2RilySKc2MTGhODk2Vuuubrc39lSuSxT04(bXJxeHEiu7urfejC3VWsXEfzbJLuW2Sf8avSFPOOcIeU7xyPyVAPX9dcwholkmusbZXw1O7YKfOoCwuyOKcMJTY9ie0ftJ0WbmSJDk2VuugnUeYY4ulnUFq84XPHHPmACjKLXP0WXJxeHEiu7uz04silJtrwWyjf8WhpholkmusbZXw5gHocFSS)ag2Xof7xkkJgxczzCQLg3piE840WWugnUeYY4uA4C4SOWqjfmhBfJrg3JqqhWWo2Py)srz04silJtT04(bXJhNggMYOXLqwgNsdhpEre6HqTtLrJlHSmofzbJLuWdF8C4SOWqjfmhB1Y4OcX(B0()ag2Xof7xkkJgxczzCQLg3piE840WWugnUeYY4uA44XlIqpeQDQmACjKLXPilySKcE4JNdNffgkPG5yReT8ArHHY7ZOYbPf2rdTdyyhTOWAC3LlWgf8TakmuC7)RyK(juv80y59z9NsYYEW3cpEuC7)RyK(ju1BnAxUzbW3cSoCwuyOKcMJTs0YRffgkVpJkhKwyhPSS)3vms)ehohoq2l8P2lmVeJ0pXllkmu6focdrysdE9mQ4WzrHHsQYq7ivqKaFB4g5ag2rX(LIIkisGVnCJOwAC)GC4SOWqjvzObMJTA04silJ7ag2rX(LIYOXLqwgNAPX9dcuye7xkkQGiH7(fwk2RwAC)GanIqpeQDQOcIeU7xyPyVISGXskyB2cEGgrOhc1ovubrc39lSuSxrwWyjf8nHppEDk2Vuuubrc39lSuSxT04(bbRdNffgkPkdnWCS1Nbo1yq3G1hSRGKfoGHDuSFPOEg4uJbDdwFWUcswqT04(b5W5WbYEPJJmdYl813cZl9tuKpVyPxG9i84LyK(jEHX6pf6bEXPjELiXlincl79sN)EPHtyHDGxA5pk1RgqAWlY8cJ1FkSS3lqYlXi9tOEzjKxNwJZRFuQxYPLE1eE8cFKLqEHVOrfVOIf5JQC4SOWqjvzObMJTI9wyx6jkY3bXgI)UIr6Nqp28ag2rYWiJEAC)aLIB)FfJ0pHQINglVpR)usw2dw4dkmDk2Vuuubrc39lSuSxT04(bXJxeHEiu7urfejC3VWsXEfzbJLuW2Sf84XJIB)FfJ0pHQINglVpR)usw2FeKaLtddt1MLq3EnQOOIf5dSnHhyD4C4azV6M0GxcYRElmV4VrKtWPMX38Qnto9cFAuzeVqyEjNZl()lSuOEXPHH5v7ZLEHX6pfw27fi5LyK(juLx4hucVeVqnos0W5f(02tfck0PdNffgkPkdnWCS1ze5eCQz8Tdyyh7uSFPOcgvg5IWUY5U7xyPqvlnUFq84XPHHPOcIe4Bd3iknC84fS9uHGcG)imnXdVoGNUqXT)VIr6NqvXtJL3N1Fkjl7HLhponmmvWOYixe2vo3D)clfQsdhpEuC7)RyK(juv80y59z9NsYYEWdsoCoCGSxD953GxrJkEXpTgnVouJqfVqPxYjzZlXi9tOEXW8IjEXOEzPxSKkwkEzjKx6cIe8I))clf79Ir9ceD9D7LffwJt5WzrHHsQYqdmhB9TgTlNgHkhWWocdNggM6TgTlvJ0pLgoE840WWugnUeYY4uA4GfukU9)vms)eQkEAS8(S(tjzzpyHhqHPtX(LIIkis4UFHLI9QLg3piE8Ii0dHANkQGiH7(fwk2RilySKc2MTGhSoCoCGSxGd05f))fwk271HVrfVSEJLuXlnCEjiVajVeJ0pH6Lr96rzVxg1lDbrcEX)FHLI9EXOELiXllkSgNYHZIcdLuLHgyo26(fwk2F5EJkhWWok2Vuu7xyPy)L7nQOwAC)GaLIB)FfJ0pHQINglVpR)usw2dw4buy6uSFPOOcIeU7xyPyVAPX9dIhVic9qO2PIkis4UFHLI9kYcglPGTzl4bRdNffgkPkdnWCS13A0UCZchWWok2VuugnUeYY4ulnUFqoCwuyOKQm0aZXwJNglVpR)usw27WzrHHsQYqdmhB9TgTlNgHkheqnYY(JnpGHDuSFPOmACjKLXPwAC)GC4SOWqjvzObMJTI9wyx6jkY3bbuJSS)yZdIne)DfJ0pHES5bmSJKHrg904(5WzrHHsQYqdmhBfJGOYLEII8Dqa1il7p20HZHZHdK9sNL9)8QBJ0pXl8HOWqPxDfHHimPbV4NmQ4WbYEX)KQrMx4R6EXOEzrH148sl)rPE1asZRtRX5vt4XleXRaImVOIf5J6fcZl8rwc5f(Igv8cJGcEPlisWl()lSuSx5fm8hQFEfn64xEPHlIcSS3l8bA0lonXllkSgNx68VRjVGqj8s8cwholkmusvuw2)7kgPFYrS3c7sprr(oGHDeMofwKpw2ZJNy)srrfejC3VWsXE1sJ7heOre6HqTtfvqKWD)clf7vKfmwsbBlDPpcXJhesuyVf2LEII8PilySKc2J9riE8e7xkkJgxczzCQLg3piqHqIc7TWU0tuKpfzbJLuWcteHEiu7uz04silJtrwWyjfmCAyykJgxczzCkinIjmuclOre6HqTtLrJlHSmofzbJLuWcpGctNI9lffvqKWD)clf7vlnUFq84j2Vuuubrc39lSuSxT04(bbAeHEiu7urfejC3VWsXEfzbJLuW2Sf8Gfwq50WWuTzj0TxJkkQyr(aBt4XHZHdK9cCGoVWhOXLqwgNxgMmIxnG0GxnoVO4wkEz)7f)0A086qncv8kEAK(r9YsiVq53GxmmVYXKZr8sxqKGx8)xyPyVxjI4f4yCyAKg8YiZROgHSu(g8YIcRXPC4SOWqjvrzz)VRyK(jG5yRgnUeYY4oGHDuSFPOmACjKLXPwAC)GafgHfg4pI)4XJhNggMI7riOxJkknCWcAeHEiu7u9wJ2LtJqffzbJLuWJhOW0Py)srrfejC3VWsXE1sJ7hepEre6HqTtfvqKWD)clf7vKfmwsbFZwWdwqHPtX(LIIfhMgPb1sJ7hepEDYPHHPyXHPrAqPHd0oJi0dHANkwCyAKguA4G1HZHdK9c)Gs4L4LgDEX)FHLI9ED4BuXlgMxnG08kI0EiVIgv8Y8cFAuzeVqyEjNZl()lSuOETaou7rgKx83iYPx6NOiFEXsQmds5f(bLWlXROrfV4)VWsXEVo8nQ4fKgHL9EPlisWl()lSuS3lT8hL6vdinVoTgNxGe46fimrJyVxDnBKakBWlw6v7tw80ROrNxnG08IkiCEPrzzVx8)xyPyVxh(gv8cLX5vdinViZINE1eE8IkwKpQximVWhzjKx4lAur5WzrHHsQIYY(FxXi9taZXw3VWsX(l3Bu5ag2rX(LIA)clf7VCVrf1sJ7heOWi2VuubJkJCryx5C39lSuOQLg3piq50WWubJkJCryx5C39lSuOknCGgS9uHGcGf)XJhVof7xkQGrLrUiSRCU7(fwku1sJ7heSGctNWerOhc1ovubrc39lSuSxrwWyjf8nBbpqf7xkkQGiH7(fwk2RwAC)GGLhpd)octMknrJy)90ibu2GIyjFhbjq50WWuTzj0TxJkkQyr(aBt4bwhohoq2RUgB48sVRHxyiIxVr6NxiIxuek9YGG8QT14OkVahYFuQxnG0860ACEPRr6NximV6ku7roWlw6v7tw80ROrNxnG08QTLIxcYliKg3pV40WW8IFY6pLKL9EDi6fV4AWlCi0ZYEVWN2EQqqbV4ggIStlHuEXFW1c4(5fDGtTLXXV8QjE4Hp1pWl(RFGx6DnoWl(5Hh4f)SXdpWl(RFGx8ZdD4SOWqjvrzz)VRyK(jG5yRubrc8THBKdyyhf7xkkQGib(2WnIAPX9dcuyigd6UgxkkdcIQIiTualiXJhXyq314srzqquflbp8XdwqHPtX(LIIQr63fHDXHApIAPX9dIhponmmfvJ0Vlc7Id1EeLgoE8c2EQqqbWFeEGhyD4SOWqjvrzz)VRyK(jG5yRpdCQXGUbRpyxbjlCad7Oy)sr9mWPgd6gS(GDfKSGAPX9dcuyigd6UgxkkdcIQIiTualiXJhXyq314srzqquflbp8Xdwhohoq2RUwuGJLZlDbrc8THBeVAZKtVWNgvgXleMxY58I))clfQxiIx6AK(5fcZRUc1EeLdNffgkPkkl7)DfJ0pbmhB9z9NsYY(lh6Ldyyh50WWuubrc8THBeLgoqP42)xXi9tOQ4PXY7Z6pLKL9GTfqHHtddtfmQmYfHDLZD3VWsHQ0WbANI9lffvJ0Vlc7Id1Ee1sJ7hepECAyykQgPFxe2fhQ9iknCW6W5WbYE195iZRaR)u8kIcZll9sdhKjZlmeXl5Kr96z58Qnto9IIcZlDux51J6zrLdNffgkPkkl7)DfJ0pbmhBDgrobNAgF7ag2rlkSg3D5cSrbFtqP42)xXi9tOQ4PXY7Z6pLKL9GVjOW0Py)srr1i97IWU4qThrT04(bXJxNqirH9wyx6jkYNImmYONg3pE8Ii0dHANkQGiH7(fwk2RilySKc(MTGhSGctNI9lfvWOYixe2vo3D)clfQAPX9dIhponmmvWOYixe2vo3D)clfQsdhpEbBpviOa4pIVBbwhohoq2RdrnOuQ2NM4L5veLqmHHsLx4Jm50l8PrLr8cH5LCoV4)VWsH6foe69cFA7Pcbf8sdNxcYl(Tx4tBpviOGxC7rT9soNxrdNxcYRLunY8IjWlQxA0b5vBMC6f)nIC6L(jkYNYl8rMCI0eVWNgvgXleMxY58I))clf6bEPrNx83iYPx6NOiFEnMCoIxmmV0fejW3gUr8Ir9sd3bEHpT9uHGcEXOE1epVWN2EQqqbV42JA7LCoVIgoVqeV(rPh4fI41yY5iEPlisWl()lSuS3lgnHxIxI9lLb5fI4ftGxuVsK4LffwJZllH8QbKgXR3OIx6cIe8I))clf79cH5LCoVWy9NIxTz)71P148cLFdEzEHZicZEVG0iMWqPYHZIcdLufLL9)UIr6NaMJToJiNx6jkY3bmSJDYPHHPOAK(DryxCO2JO0WbQy)srfmQmYfHDLZD3VWsHQwAC)GafgonmmvWOYixe2vo3D)clfQsdhpEbBpviOa4pIVBbmGeEDrSFPOI2)x5Cx5ulHgrT04(bXJhNggMIkisGVnCJO0WbQffwJ7UCb2OGTfy5XRtX(LIkyuzKlc7kN7UFHLcvT04(bbkmCAyykQGib(2WnIsdhpEbBpviOa4pIVXdmGeEDrSFPOI2)x5Cx5ulHgrT04(bXJxNWerOhc1ovubrc39lSuSxrwWyjf8nBbpqf7xkkQGiH7(fwk2RwAC)GGf0bU4wug0nIcCMC)L9YzhclSoIi0dHANkQGiH7(fwk2RilySK2rt4JxxWEeIadmdCXTOmOBef4m5(l7LZoewyDerOhc1ovubrc39lSuSxrwWyjfw4Dt4JhSG)iiHxxGPjyGXWVJWKPw8eDryx5C39lSuSNQiwYh4p2cSWcRdNdhi7f4aDEXFJiNEPFII85fdZlDns)8cH5vxHApIxmQxI9lLbDGxCAIx5yY5iEXeVseXlZl8txP7f))fwk27fJ6LffwJZlt8soNxbuyPCGxwc5f)0A086qncv8Ir9ImdQbVqeVAZ(3lU5vBMCYsVKZ5voWv8cFPRf)OC4SOWqjvrzz)VRyK(jG5yRZiY5LEII8Dad7Oy)srr1i97IWU4qThrT04(bbANCAyykQgPFxe2fhQ9iknCGgrOhc1ovV1OD50iurrwWyjfSh7JqGctNI9lffvqKWD)clf7vlnUFqG2jmre6HqTtfgJS7(fwk2RilySKc(MTGhS84j2Vuuubrc39lSuSxT04(bbANWerOhc1ovubrc39lSuSxrwWyjf8nBbpyH1HZHdK9QR1OIx8tw)PKSS3RdrVq9csJWYEV0fej4f))fwk27fKgXegkvoCwuyOKQOSS)3vms)eWCS1N1Fkjl7VCOxoGHDmIqpeQDQOcIeU7xyPyVISGXsk4B2cEGk2Vuuubrc39lSuSxT04(b5W5WbYEboqNx4Reev8s)ef5ZR2m50lWX4W0in4LLqEHpnQmIximVKZ5f))fwkuLdNffgkPkkl7)DfJ0pbmhBfJGOYLEII8Dad7Oy)srXIdtJ0GAPX9dcuX(LIkyuzKlc7kN7UFHLcvT04(bbkNggMIfhMgPbLgoq50WWubJkJCryx5C39lSuOknCoCwuyOKQOSS)3vms)eWCS13A0UCAeQCad7iNggMYOXLqwgNsdNdNdhi7f4GWEg(DEPRr6NximV6ku7r8sqErXrMb5f(6BH5L(jkYNxmmVcAVWW9ZRLlWg1lJmVWrgDPOC4SOWqjvrzz)VRyK(jG5yRyVf2LEII8DqSH4VRyK(j0JnpGHDKmmYONg3pqTOWAC3LlWgf8nbLtddtr1i97IWU4qThrPHZHZHdK9cCGoV4NwJMxhQrOIxTzYPx6AK(5fcZRUc1EeVyyEjNZR3OIx4qYsHzVxAuRFEHW8Y8c)0v6EX)FHLI9EDA0eEjEzEHP9VxqAetyO0RUE(HxmmVAaP5veP9qE1pXllrY5iEPrT(5fcZl5CEHF6kDV4)VWsXEVyyEjNZlYcglzzVxyS(tXR2g1RM4p82RhL9JOC4SOWqjvrzz)VRyK(jG5yRV1OD50iu5ag2rX(LIIkis4UFHLI9QLg3piqJi0dHANxYSOakNggMIQr63fHDXHApIsdhOWmWf3IYGUruGZK7VSxo7qyH1reHEiu7urfejC3VWsXEfzbJL0oAcF86c2JqeyGzGlUfLbDJOaNj3FzVC2HWcRJic9qO2PIkis4UFHLI9kYcglPWcVBcF8GfSGeEDbMMGbgd)octMAXt0fHDLZD3VWsXEQIyjFG)ylWclpEW0u1e)7cmdCXTOmOBef4m5(l7LZoewyW2reHEiu7urfejC3VWsXEfzbJL0oAcF86c2JqeyGPPQj(3fyg4IBrzq3ikWzY9x2lNDiSWGTJic9qO2PIkis4UFHLI9kYcglPWcVBcF8GfwWcZaxClkd6grbotU)YE5SdHfwhre6HqTtfvqKWD)clf7vKfmws7Oj8XRlypcrGbMbU4wug0nIcCMC)L9YzhclSoIi0dHANkQGiH7(fwk2RilySKcl8Uj8XdwyH1HZHdK9cCGoV4NwJMxhQrOIxTzYPx6AK(5fcZRUc1EeVyyEjNZR3OIx4qYsHzVxAuRFEHW8Y8c)0v6EX)FHLI9EDA0eEjEzEHP9VxqAetyO0RUE(HxmmVAaP5veP9qE1pXllrY5iEPrT(5fcZl5CEHF6kDV4)VWsXEVyyEjNZlYcglzzVxyS(tXR2g1RM4p82RhL9JOC4SOWqjvrzz)VRyK(jG5yRV1OD50iu5ag2Xof7xkkQGiH7(fwk2RwAC)GanIqpeQDEjZIcOCAyykQgPFxe2fhQ9iknCGcZaxClkd6grbotU)YE5SdHfwhre6HqTtfgJS7(fwk2RilySK2rt4JxxWEeIadmdCXTOmOBef4m5(l7LZoewyDerOhc1ovymYU7xyPyVISGXskSW7MWhpybliHxxGPjyGXWVJWKPw8eDryx5C39lSuSNQiwYh4p2cSWYJhmnvnX)UaZaxClkd6grbotU)YE5SdHfgSDerOhc1ovymYU7xyPyVISGXsAhnHpEDb7ricmW0u1e)7cmdCXTOmOBef4m5(l7LZoewyW2reHEiu7uHXi7UFHLI9kYcglPWcVBcF8GfwWcZaxClkd6grbotU)YE5SdHfwhre6HqTtfgJS7(fwk2RilySK2rt4JxxWEeIadmdCXTOmOBef4m5(l7LZoewyDerOhc1ovymYU7xyPyVISGXskSW7MWhpyHfwholkmusvuw2)7kgPFcyo26Z6pLKL9xo0lhWWoYPHHPOAK(DryxCO2JO0W5WzrHHsQIYY(FxXi9taZXwFRr7YPrOYbmSJre6HqTZlzwuC4C4azVWpOeEjEzXidAPy)3GxA05LUgPFEHW8QRqThXR2m50l813cZl9tuKpVG0iSS3lkl7)5LyK(jkholkmusvuw2)7kgPFcyo2k2BHDPNOiFheBi(7kgPFc9yZdyyhjdJm6PX9d0o50WWuuns)UiSlou7ruA4C4SOWqjvrzz)VRyK(jG5yRcsw4gmQmsdhWWok2Vuucsw4gmQmsdQLg3piqHHtddtrgfLwg3vqYckYcglPGf)5XdgonmmfzuuAzCxbjlOilySKcwy40WWugnUeYY4uqAetyOemre6HqTtLrJlHSmofzbJLuybnIqpeQDQmACjKLXPilySKc2MWhwyD4C4azV0Fw)P8n4vVfMxGJXHPrAWlonmmVeKxNiCdt7)g8ItddZlkkmVAZKtVWNgvgXleMxY58I))clfQYHZIcdLufLL9)UIr6NaMJTIrqu5sprr(oGHDuSFPOyXHPrAqT04(bbkNggMIfhMgPbLgoqHHtddtXIdtJ0GISGXsky7JqDbE6cNggMIfhMgPbfvSiF84XPHHPOcIe4Bd3iknC841Py)srfmQmYfHDLZD3VWsHQwAC)GG1HZIcdLufLL9)UIr6NaMJTYIdtJ0WbmSJI9lfflomnsdQLg3piholkmusvuw2)7kgPFcyo26Z6pLKL9xo0loCwuyOKQOSS)3vms)eWCSvS3c7sprr(oiGAKL9hBEqSH4VRyK(j0JnpGHDKmmYONg3pholkmusvuw2)7kgPFcyo2k2BHDPNOiFheqnYY(JnpGHDmGACHLIcIrflJd84VdNdhi7f(kbrfV0prr(8Ir9cPr8kGACHLIxyS)hr5WzrHHsQIYY(FxXi9taZXwXiiQCPNOiFheqnYY(Jnb0BCekdLaGOf8AYVBIxt4r1SzlWdGEBJKSSNcOJpIpWpab4iiWx4xE5v3NZlwahIiEHHiEbVm0GxErg4uJrgKxuuyEzAckyYG8kEAz)OkhUUpNxyO)rTzzVxMgXOE1EK5LgDqEXsVKZ5Lffgk96zuXlonXR2JmVsK4fgslH8ILEjNZldccLEbzIXz0XVC48QdVAZsOBVgvC4C4WhXh4hGaCee4l8lV8Q7Z5flGdreVWqeVGxuw2)7kgPFc8YlYaNAmYG8IIcZlttqbtgKxXtl7hv5W1958cd9pQnl79Y0ig1R2JmV0OdYlw6LCoVSOWqPxpJkEXPjE1EK5vIeVWqAjKxS0l5CEzqqO0litmoJo(LdNxD4vBwcD71OIdNdh4yahIidYl4Xllkmu61ZOcv5WbO)mQqb6gqNYY(FxXi9ta6gaenb6gqFPX9dc4qa9iHjJWmaDy8QtVewKpw27fpEEj2Vuuubrc39lSuSxT04(b5fOEfrOhc1ovubrc39lSuSxrwWyj1lW6vlE1fV6JqEXJNxqirH9wyx6jkYNISGXsQxG9Ox9riV4XZlX(LIYOXLqwgNAPX9dYlq9ccjkS3c7sprr(uKfmws9cSEbJxre6HqTtLrJlHSmofzbJLuVaJxCAyykJgxczzCkinIjmu6fSEbQxre6HqTtLrJlHSmofzbJLuVaRxWJxG6fmE1PxI9lffvqKWD)clf7vlnUFqEXJNxI9lffvqKWD)clf7vlnUFqEbQxre6HqTtfvqKWD)clf7vKfmws9cSE1Sf88cwVG1lq9Itddt1MLq3EnQOOIf5ZlW6vt4bq3IcdLa6yVf2LEII8biaGOfGUb0xAC)GaoeqpsyYimdqxSFPOmACjKLXPwAC)G8cuVGXlHfMxG)Ox4pEEXJNxCAyykUhHGEnQO0W5fSEbQxre6HqTt1BnAxoncvuKfmws9c8EHNxG6fmE1PxI9lffvqKWD)clf7vlnUFqEXJNxre6HqTtfvqKWD)clf7vKfmws9c8E1Sf88cwVa1ly8QtVe7xkkwCyAKgulnUFqEXJNxD6fNggMIfhMgPbLgoVa1Ro9kIqpeQDQyXHPrAqPHZlyb0TOWqjGUrJlHSmoabaeGeq3a6lnUFqahcOhjmzeMbOl2Vuu7xyPy)L7nQOwAC)G8cuVGXlX(LIkyuzKlc7kN7UFHLcvT04(b5fOEXPHHPcgvg5IWUY5U7xyPqvA48cuVc2EQqqbVaRx4pEEXJNxD6Ly)srfmQmYfHDLZD3VWsHQwAC)G8cwVa1ly8QtVGXRic9qO2PIkis4UFHLI9kYcglPEbEVA2cEEbQxI9lffvqKWD)clf7vlnUFqEbRx845LHFhHjtLMOrS)EAKakBqrSKpVo6fi5fOEXPHHPAZsOBVgvuuXI85fy9Qj84fSa6wuyOeqF)clf7VCVrfabaeWdq3a6lnUFqahcOhjmzeMbOl2Vuuubrc8THBe1sJ7hKxG6fmErmg0DnUuugeevfrAP4fy9cK8IhpVigd6UgxkkdcIQyPxG3l4JNxW6fOEbJxD6Ly)srr1i97IWU4qThrT04(b5fpEEXPHHPOAK(DryxCO2JO0W5fpEEfS9uHGcEb(JEbpWJxWcOBrHHsaDQGib(2WncGaac4d0nG(sJ7heWHa6rctgHza6I9lf1ZaNAmOBW6d2vqYcQLg3piVa1ly8IymO7ACPOmiiQkI0sXlW6fi5fpEErmg0DnUuugeevXsVaVxWhpVGfq3IcdLa6pdCQXGUbRpyxbjlaiaGa)b6gqFPX9dc4qa9iHjJWmaDonmmfvqKaFB4grPHZlq9IIB)FfJ0pHQINglVpR)usw27fy9QfVa1ly8ItddtfmQmYfHDLZD3VWsHQ0W5fOE1PxI9lffvJ0Vlc7Id1Ee1sJ7hKx845fNggMIQr63fHDXHApIsdNxWcOBrHHsa9N1Fkjl7VCOxaeaq01b0nG(sJ7heWHa6rctgHza6wuynU7YfyJ6f49QPxG6ff3()kgPFcvfpnwEFw)PKSS3lW7vtVa1ly8QtVe7xkkQgPFxe2fhQ9iQLg3piV4XZRo9ccjkS3c7sprr(uKHrg904(5fpEEfrOhc1ovubrc39lSuSxrwWyj1lW7vZwWZly9cuVGXRo9sSFPOcgvg5IWUY5U7xyPqvlnUFqEXJNxCAyyQGrLrUiSRCU7(fwkuLgoV4XZRGTNkeuWlWF0l8DlEblGUffgkb0NrKtWPMX3aeaqWVb6gqFPX9dc4qa9iHjJWma9o9Itddtr1i97IWU4qThrPHZlq9sSFPOcgvg5IWUY5U7xyPqvlnUFqEbQxW4fNggMkyuzKlc7kN7UFHLcvPHZlE88ky7Pcbf8c8h9cF3IxGXlqcpV6IxI9lfv0()kN7kNAj0iQLg3piV4XZlonmmfvqKaFB4grPHZlq9YIcRXDxUaBuVaRxT4fSEXJNxD6Ly)srfmQmYfHDLZD3VWsHQwAC)G8cuVGXlonmmfvqKaFB4grPHZlE88ky7Pcbf8c8h9cFJNxGXlqcpV6IxI9lfv0()kN7kNAj0iQLg3piV4XZRo9cgVIi0dHANkQGiH7(fwk2RilySK6f49Qzl45fOEj2Vuuubrc39lSuSxT04(b5fSEbQxdCXTOmOBef4m5(l7LtV6WlHfMxD4veHEiu7urfejC3VWsXEfzbJLuV6WRMWhpV6Ixypcr8cgVGXRbU4wug0nIcCMC)L9YPxD4LWcZRo8kIqpeQDQOcIeU7xyPyVISGXsQxW6f82RMWhpVG1lWF0lqcpV6IxW4vtVaJxW4LHFhHjtT4j6IWUY5U7xyPypvrSKpVa)rVAXly9cwVGfq3IcdLa6ZiY5LEII8biaGaFd0nG(sJ7heWHa6rctgHza6I9lffvJ0Vlc7Id1Ee1sJ7hKxG6vNEXPHHPOAK(DryxCO2JO0W5fOEfrOhc1ovV1OD50iurrwWyj1lWE0R(iKxG6fmE1PxI9lffvqKWD)clf7vlnUFqEbQxD6fmEfrOhc1ovymYU7xyPyVISGXsQxG3RMTGNxW6fpEEj2Vuuubrc39lSuSxT04(b5fOE1PxW4veHEiu7urfejC3VWsXEfzbJLuVaVxnBbpVG1lyb0TOWqjG(mICEPNOiFacaiAIhq3a6lnUFqahcOhjmzeMbOhrOhc1ovubrc39lSuSxrwWyj1lW7vZwWZlq9sSFPOOcIeU7xyPyVAPX9dcq3IcdLa6pR)usw2F5qVaiaGOztGUb0xAC)GaoeqpsyYimdqxSFPOyXHPrAqT04(b5fOEj2VuubJkJCryx5C39lSuOQLg3piVa1lonmmflomnsdknCEbQxCAyyQGrLrUiSRCU7(fwkuLgoaDlkmucOJrqu5sprr(aeaq0SfGUb0xAC)GaoeqpsyYimdqNtddtz04silJtPHdq3IcdLa6V1OD50iubqaartqcOBa9Lg3piGdb0TOWqjGo2BHDPNOiFa6rctgHza6KHrg904(5fOEzrH14UlxGnQxG3RMEbQxCAyykQgPFxe2fhQ9iknCa6XgI)UIr6NqbartabaenHhGUb0xAC)GaoeqpsyYimdqxSFPOOcIeU7xyPyVAPX9dYlq9kIqpeQDEjZIIxG6fNggMIQr63fHDXHApIsdNxG6fmEnWf3IYGUruGZK7VSxo9QdVewyE1Hxre6HqTtfvqKWD)clf7vKfmws9QdVAcF88QlEH9ieXly8cgVg4IBrzq3ikWzY9x2lNE1HxclmV6WRic9qO2PIkis4UFHLI9kYcglPEbRxWBVAcF88cwVaRxGeEE1fVGXRMEbgVGXld)octMAXt0fHDLZD3VWsXEQIyjFEb(JE1IxW6fSEXJNxW4vtvt83RU4fmEnWf3IYGUruGZK7VSxo9QdVewyEbRxD4veHEiu7urfejC3VWsXEfzbJLuV6WRMWhpV6Ixypcr8cgVGXRMQM4VxDXly8AGlUfLbDJOaNj3FzVC6vhEjSW8cwV6WRic9qO2PIkis4UFHLI9kYcglPEbRxWBVAcF88cwVG1lW6fmEnWf3IYGUruGZK7VSxo9QdVewyE1Hxre6HqTtfvqKWD)clf7vKfmws9QdVAcF88QlEH9ieXly8cgVg4IBrzq3ikWzY9x2lNE1HxclmV6WRic9qO2PIkis4UFHLI9kYcglPEbRxWBVAcF88cwVG1lyb0TOWqjG(BnAxoncvaeaq0e(aDdOV04(bbCiGEKWKrygGENEj2Vuuubrc39lSuSxT04(b5fOEfrOhc1oVKzrXlq9Itddtr1i97IWU4qThrPHZlq9cgVg4IBrzq3ikWzY9x2lNE1HxclmV6WRic9qO2PcJr2D)clf7vKfmws9QdVAcF88QlEH9ieXly8cgVg4IBrzq3ikWzY9x2lNE1HxclmV6WRic9qO2PcJr2D)clf7vKfmws9cwVG3E1e(45fSEbwVaj88QlEbJxn9cmEbJxg(DeMm1INOlc7kN7UFHLI9ufXs(8c8h9QfVG1ly9IhpVGXRMQM4VxDXly8AGlUfLbDJOaNj3FzVC6vhEjSW8cwV6WRic9qO2PcJr2D)clf7vKfmws9QdVAcF88QlEH9ieXly8cgVAQAI)E1fVGXRbU4wug0nIcCMC)L9YPxD4LWcZly9QdVIi0dHANkmgz39lSuSxrwWyj1ly9cE7vt4JNxW6fSEbwVGXRbU4wug0nIcCMC)L9YPxD4LWcZRo8kIqpeQDQWyKD3VWsXEfzbJLuV6WRMWhpV6Ixypcr8cgVGXRbU4wug0nIcCMC)L9YPxD4LWcZRo8kIqpeQDQWyKD3VWsXEfzbJLuVG1l4TxnHpEEbRxW6fSa6wuyOeq)TgTlNgHkacaiAI)aDdOV04(bbCiGEKWKrygGoNggMIQr63fHDXHApIsdhGUffgkb0Fw)PKSS)YHEbqaarZUoGUb0xAC)GaoeqpsyYimdqpIqpeQDEjZIcGUffgkb0FRr7YPrOcGaaIM8BGUb0xAC)Gaoeq3IcdLa6yVf2LEII8bOhjmzeMbOtggz0tJ7NxG6vNEXPHHPOAK(DryxCO2JO0WbOhBi(7kgPFcfaenbeaq0eFd0nG(sJ7heWHa6rctgHza6I9lfLGKfUbJkJ0GAPX9dYlq9cgV40WWuKrrPLXDfKSGISGXsQxG1l83lE88cgV40WWuKrrPLXDfKSGISGXsQxG1ly8Itddtz04silJtbPrmHHsVaJxre6HqTtLrJlHSmofzbJLuVG1lq9kIqpeQDQmACjKLXPilySK6fy9Qj89cwVGfq3IcdLa6csw4gmQmsdacaiAbpGUb0xAC)GaoeqpsyYimdqxSFPOyXHPrAqT04(b5fOEXPHHPyXHPrAqPHZlq9cgV40WWuS4W0inOilySK6fy9Qpc5vx8cE8QlEXPHHPyXHPrAqrflYNx845fNggMIkisGVnCJO0W5fpEE1PxI9lfvWOYixe2vo3D)clfQAPX9dYlyb0TOWqjGogbrLl9ef5dqaarlnb6gqFPX9dc4qa9iHjJWmaDX(LIIfhMgPb1sJ7heGUffgkb0zXHPrAaqaarlTa0nGUffgkb0Fw)PKSS)YHEbqFPX9dc4qabaeTasaDdOV04(bbCiGUffgkb0XElSl9ef5dqp2q83vms)ekaiAcOhjmzeMbOtggz0tJ7hGEa1il7b0BciaGOf4bOBa9Lg3piGdb0JeMmcZa0dOgxyPOGyuXY48c8EH)a6wuyOeqh7TWU0tuKpa9aQrw2dO3eqaarlWhOBa9aQrw2dO3eq3IcdLa6yeevU0tuKpa9Lg3piGdbeabq3qdOBaq0eOBa9Lg3piGdb0JeMmcZa0f7xkkQGib(2WnIAPX9dcq3IcdLa6ubrc8THBeabaeTa0nG(sJ7heWHa6rctgHza6I9lfLrJlHSmo1sJ7hKxG6fmEj2Vuuubrc39lSuSxT04(b5fOEfrOhc1ovubrc39lSuSxrwWyj1lW6vZwWZlq9kIqpeQDQOcIeU7xyPyVISGXsQxG3RMW3lE88QtVe7xkkQGiH7(fwk2RwAC)G8cwaDlkmucOB04silJdqaabib0nG(sJ7heWHa6rctgHza6I9lf1ZaNAmOBW6d2vqYcQLg3piaDlkmucO)mWPgd6gS(GDfKSaGaac4bOBa9Lg3piGdb0TOWqjGo2BHDPNOiFa6rctgHza6KHrg904(5fOErXT)VIr6NqvXtJL3N1Fkjl79cSEbFVa1ly8QtVe7xkkQGiH7(fwk2RwAC)G8IhpVIi0dHANkQGiH7(fwk2RilySK6fy9Qzl45fpEErXT)VIr6NqvXtJL3N1Fkjl796OxGKxG6fNggMQnlHU9AurrflYNxG1RMWJxWcOhBi(7kgPFcfaenbeaqaFGUb0xAC)GaoeqpsyYimdqVtVe7xkQGrLrUiSRCU7(fwku1sJ7hKx845fNggMIkisGVnCJO0W5fpEEfS9uHGcEb(JEbJxnXdpV6Wl4XRU4ff3()kgPFcvfpnwEFw)PKSS3ly9IhpV40WWubJkJCryx5C39lSuOknCEXJNxuC7)RyK(juv80y59z9NsYYEVaVxGeGUffgkb0NrKtWPMX3aeaqG)aDdOV04(bbCiGEKWKrygGomEXPHHPERr7s1i9tPHZlE88Itddtz04silJtPHZly9cuVO42)xXi9tOQ4PXY7Z6pLKL9EbwVGhVa1ly8QtVe7xkkQGiH7(fwk2RwAC)G8IhpVIi0dHANkQGiH7(fwk2RilySK6fy9Qzl45fSa6wuyOeq)TgTlNgHkacai66a6gqFPX9dc4qa9iHjJWmaDX(LIA)clf7VCVrf1sJ7hKxG6ff3()kgPFcvfpnwEFw)PKSS3lW6f84fOEbJxD6Ly)srrfejC3VWsXE1sJ7hKx845veHEiu7urfejC3VWsXEfzbJLuVaRxnBbpVGfq3IcdLa67xyPy)L7nQaiaGGFd0nG(sJ7heWHa6rctgHza6I9lfLrJlHSmo1sJ7heGUffgkb0FRr7YnlaiaGaFd0nGUffgkb0JNglVpR)usw2dOV04(bbCiGaaIM4b0nG(sJ7heWHa6rctgHza6I9lfLrJlHSmo1sJ7heGUffgkb0FRr7YPrOcGEa1il7b0BciaGOztGUb0xAC)Gaoeq3IcdLa6yVf2LEII8bOhBi(7kgPFcfaenb0JeMmcZa0jdJm6PX9dqpGAKL9a6nbeaq0SfGUb0dOgzzpGEtaDlkmucOJrqu5sprr(a0xAC)GaoeqaeaDOHzAVa0naiAc0nG(sJ7heahGEKWKrygGUHFhHjtzzCuHy)LmkkTmo1sJ7heGUffgkb05Eec61OcGaaIwa6gq3IcdLa6Tzj0LEoJaOV04(bbCiGaacqcOBa9Lg3piGdb0JeMmcZa0f7xkkbjlCdgvgPb1sJ7hKxG6fNggMImkkTmURGKfuKfmws9cSE1cGUffgkb0fKSWnyuzKgaeaqapaDdOV04(bbCiGEKWKrygGENEj2Vuuubrc39lSuSxT04(bbOBrHHsaDmgz39lSuShqaab8b6gqFPX9dc4qa9iHjJWmaDX(LIIkis4UFHLI9QLg3piVa1ly8QtVe7xkkwCyAKgulnUFqEXJNxD6fNggMIfhMgPbLgoVa1Ro9kIqpeQDQyXHPrAqPHZlyb0TOWqjGovqKWD)clf7beaqG)aDdOV04(bbCiGEKWKrygGENEj2Vuu4iSG939lSuSNrf1sJ7hKx845Ly)srHJWc2F3VWsXEgvulnUFqEbQxW4veHEiu7uHXi7UFHLI9kYcglPEbwVA2cEEbQxD6Ly)srrfejC3VWsXE1sJ7hKx845veHEiu7urfejC3VWsXEfzbJLuVaRxnBbpVa1lX(LIIkis4UFHLI9QLg3piVGfq3IcdLa6ZiY5D)clf7beaq01b0nGUffgkb01O7YKfOa6lnUFqahciaGGFd0nG(sJ7heWHa6rctgHza6D6Ly)srz04silJtT04(b5fpEEXPHHPmACjKLXP0W5fpEEfrOhc1ovgnUeYY4uKfmws9c8EbF8a0TOWqjGo3JqqxmnsdacaiW3aDdOV04(bbCiGEKWKrygGENEj2VuugnUeYY4ulnUFqEXJNxCAyykJgxczzCknCa6wuyOeqNBe6i8XYEabaenXdOBa9Lg3piGdb0JeMmcZa070lX(LIYOXLqwgNAPX9dYlE88Itddtz04silJtPHZlE88kIqpeQDQmACjKLXPilySK6f49c(4bOBrHHsaDmgzCpcbbiaGOztGUb0xAC)GaoeqpsyYimdqVtVe7xkkJgxczzCQLg3piV4XZlonmmLrJlHSmoLgoV4XZRic9qO2PYOXLqwgNISGXsQxG3l4JhGUffgkb0TmoQqS)gT)beaq0SfGUb0xAC)GaoeqpsyYimdq3IcRXDxUaBuVaVxT4fOEbJxuC7)RyK(juv80y59z9NsYYEVaVxT4fpEErXT)VIr6NqvV1OD5Mf8c8E1IxWcOBrHHsaDIwETOWq59zubq)zu5Mwya6gAacaiAcsaDdOV04(bbCiGUffgkb0jA51IcdL3Nrfa9NrLBAHbOtzz)VRyK(jacGaOJJSikWzcq3aGOjq3a6lnUFqahciaGOfGUb0xAC)Gaoeqaabib0nG(sJ7heWHacaiGhGUb0xAC)Gaoeqaab8b6gq3IcdLa6csw4gmQmsda6lnUFqahciaGa)b6gqFPX9dc4qa9iHjJWma9o9sSFPOWryb7V7xyPypJkQLg3piaDlkmucOpJiN39lSuShqaarxhq3a6lnUFqahcOhjmzeMbOl2Vuuubrc8THBe1sJ7hKxG6fmErmg0DnUuugeevfrAP4fy9cK8IhpVigd6UgxkkdcIQyPxG3l4JNxWcOBrHHsaDQGib(2WncGaac(nq3a6lnUFqahcOhjmzeMbO3PxI9lffvqKWD)clf7vlnUFqa6wuyOeqhJr2D)clf7beaqGVb6gq3IcdLa64qcdLa6lnUFqahciaGOjEaDdOV04(bbCiGEKWKrygGUy)srTFHLI9xU3OIAPX9dcq3IcdLa67xyPy)L7nQaiacGaOBAYjIaORZcAVjmu21smmbqaeaaa]] )


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
