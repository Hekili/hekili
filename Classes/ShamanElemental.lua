-- ShamanElemental.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'SHAMAN' then
    local spec = Hekili:NewSpecialization( 262 )

    spec:RegisterResource( Enum.PowerType.Maelstrom )
    spec:RegisterResource( Enum.PowerType.Mana )
    
    -- Talents
    spec:RegisterTalents( {
        exposed_elements = 22356, -- 260694
        echo_of_the_elements = 22357, -- 108283
        elemental_blast = 22358, -- 117014

        aftershock = 23108, -- 273221
        master_of_the_elements = 22139, -- 16166
        totem_mastery = 23190, -- 210643

        spirit_wolf = 23162, -- 260878
        earth_shield = 23163, -- 974
        static_charge = 23164, -- 265046

        high_voltage = 19271, -- 260890
        storm_elemental = 19272, -- 192249
        liquid_magma_totem = 19273, -- 192222

        natures_guardian = 22144, -- 30884
        ancestral_guidance = 22172, -- 108281
        wind_rush_totem = 21966, -- 192077

        earthen_rage = 22145, -- 170374
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
            duration = 18,
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
        
        --[[ don't need this, it is in Classes.lua
        sated = {
            id = 57724,
            duration = 600,
            max_stack = 1,
        }, ]]

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
        }
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
            cast = function () return buff.stormkeeper.up and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return -4 * ( min( 5, active_enemies ) ) end,
            spendType = 'maelstrom',

            nobuff = 'ascendance',
            bind = 'lava_beam',

            startsCombat = true,
            texture = 136015,
            
            handler = function ()
                removeBuff( 'master_of_the_elements' )
                removeBuff( 'stormkeeper' )

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
            cooldown = 150,
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
            
            spend = -15,
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
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 237582,
            
            handler = function ()
                removeBuff( "lava_surge" )
                gain( 10, "maelstrom" )
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
                removeStack( 'stormkeeper' )
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
            cooldown = 150,
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

    
    spec:RegisterPack( "Elemental", 20180930.2038, [[dGu(UaqiejpsbYMuu9jfQenkePofIkVIuYSec3cHGDj4xkKHjeDmfLLPaEMcutdHKRrkvBtHQ(gIQ04iLIZHqO1PqfnpvkUhPyFcvDqeIYcruEicrLjQqLuxeHuBuHkHtQqfwPc6LkuPAMkuPCtevv2jI4NievnuevXsruvEQkMQkvxvHkj7f0FvLbtvhg1IvvpMKjlQllTzs1NvjJgbNg41cvMTs3wKDt53qnCH0XjLslNkphY0jUUISDeQVRqz8ie58QuA9iQQA(cL9J0WzW7WtMLcjzGiNPnrsehCKHbgyWAtKdgEKBJw4jkRIJVk8yCQWdrVnvt4fEIY3UyodVdpi8Ktv4HGirrJZrJUacHPFqHtJqG00YcaBkhRlJqGKA0FX)rFDMiKlXJI6W6GTOrKhxjFmiJgrEiFVdboX2JO3MQj8gqGKcE(tGvghg8dpzwkKKbICM2ejrCWrggyGzAJ2jVWdkAvqsgy8dapea5Cn4hEYfPGNbr9e92unHxQ)qGtSrhoiQNGirrJZrJUacHPFqHtJqG00YcaBkhRlJqGKA0FX)rFDMiKlXJI6W6GTOrKhxjFmiJgrEiFVdboX2JO3MQj8gqGKIoCqu)PrLM(1r9doYiO(bICM2q9ebQFGzJtTRD4jQdRd2cpdI6j6TPAcVu)HaNyJoCqupbrIIgNJgDbect)GcNgHaPPLfa2uowxgHaj1O)I)J(6mrixIhf1H1bBrJipUs(yqgnI8q(EhcCIThrVnvt4nGajfD4GO(tJkn9RJ6hCKrq9de5mTH6jcu)aZgNAx70H0HdI6jAIuvtsZu)V6yxPEfo9zH6)9cyOa1tKPunQGOEdBebcSlPpTupRea2qup22Bd0HSsaydfI6QcN(SOrFzuC0HSsaydfI6QcN(SOLMr6yCMoKvcaBOquxv40NfT0mINUs1ewayJoCqu)X4OicyH6Dmit9)jD9MPEKWcI6)vh7k1RWPplu)Vxadr9SLP(OUseIIfbyxupar9zS1aDiRea2qHOUQWPplAPzeY4Oicy5Hewq0HSsaydfI6QcN(SOLMrcwA6LyKu3T0HSsaydfI6QcN(SOLMr6axFDBQMWlDiRea2qHOUQWPplAPzuuSaWgDiRea2qHOUQWPplAPzu3MQj8((lJe6q6Wbr9enrQQjPzQVex3TuVasL6fcL6zLGDupar9mXmy5)2aD4GOEICmsOEYwmoVtiH6tSnX7El1d0PEHqPEImY)6asP(7ogiuprMPksC8s9KVIWgBQs9ae1h1vunjqhYkbGnKM)IX5Dcjra01WK)1bKgytvK4495kcBSPAOg)3MPdhe1pomIGcN(Sq9rXcaBupar9rDvVUAcG39wQFbwCnt9cM6Vfp5OEIEBQMWBeu)KTfHOEfo9zH6hdSl1xlt9icyNS3shYkbGnKwAgfflaSrhoiQFCysDUPOc1J1PEfJeuGoKvcaBiT0mAmGLFicLD0HSsaydPLMrcwA6LyKu3Tra01i8wtccwA6LyKu3THA8FBE(Fsxp4kcBSP6tWstbxtmWq3maDiRea2qAPzKoW1x3MQj8gbqxdPeERjbKGDPx3MQj8gQX)Tz6qwjaSH0sZiKGDPx3MQj8gbqxJWBnjGeSl962unH3qn(VnthYkbGnKwAgv2jeEDBQMWBeaDnkmEZ4XSGoW1x3MQj8gCnXadDZSbICoPeERjbKGDPx3MQj8gQX)T5yXuy8MXJzbKGDPx3MQj8gCnXadDZSbICUWBnjGeSl962unH3qn(VnthYkbGnKwAgnH6dinHOdzLaWgslnJ(lgNF6tUBJaORHucV1KaJu1YSPAOg)3MJf7pPRhyKQwMnvdtrJftHXBgpMfyKQwMnvdUMyGHIx7rshYkbGnKwAg9RdvxCa7kcGUgsj8wtcmsvlZMQHA8FBowS)KUEGrQAz2unmfLoKvcaBiT0msh46FX4CeaDnKs4TMeyKQwMnvd14)2CSy)jD9aJu1YSPAykASykmEZ4XSaJu1YSPAW1edmu8Aps6qwjaSH0sZi2ufjoEFkE3ia6AiLWBnjWivTmBQgQX)T5yX(t66bgPQLzt1Wu0yXuy8MXJzbgPQLzt1GRjgyO41EK0HSsaydPLMrUj7XkbGT3cqsegNQgg3ia6AyLaiUVAnbkk(bMtAu0U7ty3vfuqrGb2BbxeedyxXpqSyOOD3NWURkOWYeZVF5u8dqo6qwjaSH0sZi3K9yLaW2BbijcJtvdcyxBFc7UQqhshoiQN8BAfa1lS7Qc1ZkbGnQpQdGDa5wQFbiHoKvcaBOaJRgKGDP4AJwxeaDncV1KasWUuCTrRluJ)BZ0HSsaydfyC1sZigPQLzt1ia6AeERjbgPQLzt1qn(VnpN0cV1KasWU0RBt1eEd14)28CfgVz8ywajyx61TPAcVbxtmWq3mBGiNRW4nJhZcib7sVUnvt4n4AIbgk(zApwmsj8wtcib7sVUnvt4nuJ)BZKJoKvcaBOaJRwAgTaTDcKFj(kXpblnfbqxJWBnjSaTDcKFj(kXpblnfQX)Tz6qwjaSHcmUAPzK(YP(qeWQ4IaORXvDxre4)25OOD3NWURkOGIadS3cUiigWUUHOOdzLaWgkW4QLMrLDcbTDIJR0HdI6jYB7TuVIrc1pUXeZupztoKq9yJ6fcUwQxy3vfe1d0PEGq9ae1Zg1dmKWMeOdzLaWgkW4QLMrltm)(toKebqxdP)t66HLjMFOj3vdtrJf7pPRhyKQwMnvdtrj3Cu0U7ty3vfuqrGb2Bbxeedyx3qu0HSsaydfyC1sZOUnvt499xgjra01i8wtcDBQMW77Vmsc14)28Cu0U7ty3vfuqrGb2Bbxeedyx3qu0HSsaydfyC1sZOLjMF)YPia6AeERjbgPQLzt1qn(VnthYkbGnuGXvlnJueyG9wWfbXa2fDiRea2qbgxT0mAzI53FYHKisyIb2LMzra01i8wtcmsvlZMQHA8FBMoKvcaBOaJRwAgPVCQpebSkUisyIb2LMzra014QURic8FlDiRea2qbgxT0ms3HrYdraRIlIeMyGDPzgDiD4GO(dWU2s93z3vfQNitjaSr9Khha7aYTu)4gaj0HSsaydfqa7A7ty3vfn6lN6draRIlcGUgsjavCa7kwSmwc6lN6draRIl4AIbg6gnxQCSycV1KaJu1YSPAOg)3MNNXsqF5uFicyvCbxtmWq3qAfgVz8ywGrQAz2un4AIbgsR)KUEGrQAz2unKNCSaWg5MRW4nJhZcmsvlZMQbxtmWq3quZjnPeERjbKGDPx3MQj8gQX)T5yXeERjbKGDPx3MQj8gQX)T55kmEZ4XSasWU0RBt1eEdUMyGHUz2arso6qwjaSHciGDT9jS7QIwAgXivTmBQgbqxJWBnjWivTmBQgQX)T55KwaPgVMXhzSy)jD9WFX48oHKWuuYnxHXBgpMfwMy(9NCij4AIbgk(iNtkH3Asajyx61TPAcVHA8FBMoKvcaBOacyxBFc7UQOLMrmsvlZMQra01i8wtcmsvlZMQHA8FBEoPfqQXRz8rgl2Fsxp8xmoVtijmfLCZvy8MXJzHLjMF)jhscUMyGHIpY5kmEZ4XSasWU0RBt1eEdUMyGHUrZSbIKoCqu)4ASnUuO(juPEIEBQMWl1t2YiH6b6u)T4jQxHN2m1RyKq9m1t(XiPoQhRt9cHs9e92unbr9nffpwDnt9en7ecu)Hawfh1dmKuohOdzLaWgkGa212NWURkAPzu3MQj8((lJKia6AeERjHUnvt499xgjHA8FBEoPfERjHeJK6Ey9NqOVUnvtqHA8FBE(FsxpKyKu3dR)ec91TPAckmfDEI7IehoDZ4Jmwmsj8wtcjgj19W6pHqFDBQMGc14)2m5Odhe1pU3gL6pJ7uVo2r9l7Uk1JDupcJnQNZzQFmM4Ic0HSsaydfqa7A7ty3vfT0mcjyxkU2O1fbqxJWBnjGeSlfxB06c14)28Cs7yq(vIRjboNrbfEYKBgCSyogKFL4AsGZzuayXR9ijhDiRea2qbeWU2(e2DvrlnJwG2obYVeFL4NGLMIaORr4TMewG2obYVeFL4NGLMc14)28Cs7yq(vIRjboNrbfEYKBgCSyogKFL4AsGZzuayXR9ijhDiRea2qbeWU2(e2DvrlnJk7ecA7ehxJaORHvcG4(Q1eOO4NnhfT7(e2DvbfueyG9wWfbXa2v8ZMtkH3AsOePOyuZVUnvtqHA8FBMoCqu)4kuPEHqP(C)t66u)V6yxPEfJeGDr9en7ecu)Hawfh1ZxmWc0HSsaydfqa7A7ty3vfT0mAbxeedyxVpELia6AeERjHsKIIrn)62unbfQX)T555(N01dLiffJA(1TPAckmfDEI7IehofVMXh5Cs9N01dmsvlZMQHPO0HdI6hh6uFumcb(BJG6NqL6jA2jeO(dbSkoQFmGqG6j)yKuh1J1PEHqPEIEBQMGc0HSsaydfqa7A7ty3vfT0mQSti8qeWQ4IaORr4TMesmsQ7H1FcH(62unbfQX)T55K(pPRhsmsQ7H1FcH(62unbfMIglwI7IehofVgI4aKlwmsj8wtcjgj19W6pHqFDBQMGc14)2mDiRea2qbeWU2(e2DvrlnJwMy(9NCijcGUgfgVz8y2ZvwjXI9N01dmsvlZMQHPO0HSsaydfqa7A7ty3vfT0msF5uFicyvCra014QURic8FlDiRea2qbeWU2(e2DvrlnJeS00lXiPUBJaORr4TMeeS00lXiPUBd14)28Cs)N01dUIWgBQ(eS0uW1edm0nJpwms)N01dUIWgBQ(eS0uW1edm0nK(pPRhyKQwMnvd5jhlaSPLcJ3mEmlWivTmBQgCnXadrU5kmEZ4XSaJu1YSPAW1edm0nZ0o5ihDiRea2qbeWU2(e2DvrlnJ0DyK8qeWQ4IaORr4TMeaQQp5UnuJ)BZZ)t66bGQ6tUBdtrPdzLaWgkGa212NWURkAPzeqv9j3Tra01i8wtcav1NC3gQX)Tz6qwjaSHciGDT9jS7QIwAgTmX87xofbqxJWBnjWivTmBQgQX)T55Ssae3xTMaff)S5OOD3NWURkOWYeZVF5u8ZOdzLaWgkGa212NWURkAPzKIadS3cUiigWUIaORHvcG4(Q1eOO4NnhfT7(e2DvbfueyG9wWfbXa2v8ZOdzLaWgkGa212NWURkAPz0cUiigWUEF8k0HSsaydfqa7A7ty3vfT0msF5uFicyvCrKWedSlnZIaORXvDxre4)w6qwjaSHciGDT9jS7QIwAgPVCQpebSkUisyIb2LMzra01KWe3unjKbiHnvJF80HdI6hx4WiH6peWQ4OEaI6XtoQpHjUPAc1Rd2TUaDiRea2qbeWU2(e2DvrlnJ0DyK8qeWQ4IiHjgyxAMbpexhcGnijde5mTjsTz2GdZiVdEWWZySZa2fcEghPOyN0m1tuupRea2O(fGeuGoeEwasqW7WdcyxBFc7UQaVdjzg8o8uJ)BZqYGhLdi1by4HuuVauXbSlQpwmQpJLG(YP(qeWQ4cUMyGHO(B0q9xQm1hlg1l8wtcmsvlZMQHA8FBM6Nt9zSe0xo1hIawfxW1edme1Fd1tAQxHXBgpMfyKQwMnvdUMyGHOETO()KUEGrQAz2unKNCSaWg1toQFo1RW4nJhZcmsvlZMQbxtmWqu)nuprr9ZPEst9KI6fERjbKGDPx3MQj8gQX)TzQpwmQx4TMeqc2LEDBQMWBOg)3MP(5uVcJ3mEmlGeSl962unH3GRjgyiQ)gQF2ars9KdEyLaWg8OVCQpebSkoOajza4D4Pg)3MHKbpkhqQdWWJWBnjWivTmBQgQX)TzQFo1tAQxaPs9XRH6hFKuFSyu)Fsxp8xmoVtijmfL6jh1pN6vy8MXJzHLjMF)jhscUMyGHO(4P(iP(5upPOEH3Asajyx61TPAcVHA8FBgEyLaWg8WivTmBQcfijdgEhEQX)TzizWJYbK6am8i8wtcmsvlZMQHA8FBM6Nt9KM6fqQuF8AO(Xhj1hlg1)N01d)fJZ7esctrPEYr9ZPEfgVz8ywyzI53FYHKGRjgyiQpEQpsQFo1RW4nJhZcib7sVUnvt4n4AIbgI6Vrd1pBGiHhwjaSbpmsvlZMQqbscrbVdp14)2mKm4r5asDagEeERjHUnvt499xgjHA8FBM6Nt9KM6fERjHeJK6Ey9NqOVUnvtqHA8FBM6Nt9)jD9qIrsDpS(ti0x3MQjOWuuQFo1N4UiXHtu)nu)4JK6JfJ6jf1l8wtcjgj19W6pHqFDBQMGc14)2m1to4HvcaBWt3MQj8((lJeOajr7W7Wtn(VndjdEuoGuhGHhH3AsajyxkU2O1fQX)TzQFo1tAQ3XG8RextcCoJck8Kju)nu)GP(yXOEhdYVsCnjW5mkamQpEQx7rs9KdEyLaWg8GeSlfxB06GcKKXdVdp14)2mKm4r5asDagEeERjHfOTtG8lXxj(jyPPqn(Vnt9ZPEst9ogKFL4AsGZzuqHNmH6VH6hm1hlg17yq(vIRjboNrbGr9Xt9ApsQNCWdRea2GNfOTtG8lXxj(jyPjOajH8cVdp14)2mKm4r5asDagEyLaiUVAnbkI6JN6Nr9ZPEu0U7ty3vfuqrGb2BbxeedyxuF8u)mQFo1tkQx4TMekrkkg18RBt1euOg)3MHhwjaSbpLDcbTDIJRqbsI2aVdp14)2mKm4r5asDagEeERjHsKIIrn)62unbfQX)TzQFo1N7FsxpuIuumQ5x3MQjOWuuQFo1N4UiXHtuF8AO(Xhj1pN6jf1)N01dmsvlZMQHPOWdRea2GNfCrqmGD9(4vGcKeIi8o8uJ)BZqYGhLdi1by4r4TMesmsQ7H1FcH(62unbfQX)TzQFo1tAQ)pPRhsmsQ7H1FcH(62unbfMIs9XIr9jUlsC4e1hVgQNioa1toQpwmQNuuVWBnjKyKu3dR)ec91TPAckuJ)BZWdRea2GNYoHWdraRIdkqsMfj8o8uJ)BZqYGhLdi1by4rHXBgpM9CLvc1hlg1)N01dmsvlZMQHPOWdRea2GNLjMF)jhsGcKKzZG3HNA8FBgsg8OCaPoadpUQ7kIa)3cpSsaydE0xo1hIawfhuGKmBa4D4Pg)3MHKbpkhqQdWWJWBnjiyPPxIrsD3gQX)TzQFo1tAQ)pPRhCfHn2u9jyPPGRjgyiQ)gQF8uFSyupPP()KUEWve2yt1NGLMcUMyGHO(BOEst9)jD9aJu1YSPAip5ybGnQxlQxHXBgpMfyKQwMnvdUMyGHOEYr9ZPEfgVz8ywGrQAz2un4AIbgI6VH6NPDQNCup5GhwjaSbpcwA6LyKu3TqbsYSbdVdp14)2mKm4r5asDagEeERjbGQ6tUBd14)2m1pN6)t66bGQ6tUBdtrHhwjaSbp6omsEicyvCqbsYmIcEhEQX)TzizWJYbK6am8i8wtcav1NC3gQX)Tz4HvcaBWdqv9j3TqbsYmTdVdp14)2mKm4r5asDagEeERjbgPQLzt1qn(Vnt9ZPEwjaI7RwtGIO(4P(zu)CQhfT7(e2DvbfwMy(9lNO(4P(zWdRea2GNLjMF)YjOajz24H3HNA8FBgsg8OCaPoadpSsae3xTMafr9Xt9ZO(5upkA39jS7QckOiWa7TGlcIbSlQpEQFg8WkbGn4rrGb2BbxeedyxqbsYmYl8o8WkbGn4zbxeedyxVpEf4Pg)3MHKbfijZ0g4D4jHjgyxWZm4Pg)3MHKbpSsaydE0xo1hIawfh8OCaPoadpUQ7kIa)3cfijZiIW7WtctmWUGNzWtn(VndjdEyLaWg8OVCQpebSko4r5asDagEsyIBQMeYaKWMQuF8u)4HcKKbIeEhEsyIb2f8mdEyLaWg8O7Wi5HiGvXbp14)2mKmOaf4HXfEhsYm4D4Pg)3MHKbpkhqQdWWJWBnjGeSlfxB06c14)2m8WkbGn4bjyxkU2O1bfijdaVdp14)2mKm4r5asDagEeERjbgPQLzt1qn(Vnt9ZPEst9cV1KasWU0RBt1eEd14)2m1pN6vy8MXJzbKGDPx3MQj8gCnXadr93q9ZgisQFo1RW4nJhZcib7sVUnvt4n4AIbgI6JN6NPDQpwmQNuuVWBnjGeSl962unH3qn(Vnt9KdEyLaWg8WivTmBQcfijdgEhEQX)TzizWJYbK6am8i8wtclqBNa5xIVs8tWstHA8FBgEyLaWg8SaTDcKFj(kXpblnbfijef8o8uJ)BZqYGhLdi1by4XvDxre4)wQFo1JI2DFc7UQGckcmWEl4IGya7I6VH6jk4HvcaBWJ(YP(qeWQ4GcKeTdVdpSsaydEk7ecA7ehxHNA8FBgsguGKmE4D4Pg)3MHKbpkhqQdWWdPP()KUEyzI5hAYD1WuuQpwmQ)pPRhyKQwMnvdtrPEYr9ZPEu0U7ty3vfuqrGb2Bbxeedyxu)nuprbpSsaydEwMy(9NCibkqsiVW7Wtn(VndjdEuoGuhGHhH3AsOBt1eEF)LrsOg)3MP(5upkA39jS7QckOiWa7TGlcIbSlQ)gQNOGhwjaSbpDBQMW77VmsGcKeTbEhEQX)TzizWJYbK6am8i8wtcmsvlZMQHA8FBgEyLaWg8SmX87xobfijer4D4HvcaBWJIadS3cUiigWUGNA8FBgsguGKmls4D4jHjgyxWZm4Pg)3MHKbpSsaydEwMy(9NCibEuoGuhGHhH3AsGrQAz2unuJ)BZqbsYSzW7WtctmWUGNzWtn(VndjdEyLaWg8OVCQpebSko4r5asDagECv3veb(VfkqsMna8o8KWedSl4zg8WkbGn4r3HrYdraRIdEQX)TzizqbkWtU680kW7qsMbVdp14)2m8dpkhqQdWWdt(xhqAGnvrIJ3NRiSXMQHA8FBgEyLaWg88xmoVtibkqsgaEhEyLaWg8eflaSbp14)2mKmOajzWW7WdRea2GNXaw(Hiu2bp14)2mKmOajHOG3HNA8FBgsg8OCaPoadpcV1KGGLMEjgj1DBOg)3MP(5u)Fsxp4kcBSP6tWstbxtmWqu)nu)aWdRea2Ghbln9smsQ7wOajr7W7Wtn(VndjdEuoGuhGHhsr9cV1KasWU0RBt1eEd14)2m8WkbGn4rh46RBt1eEHcKKXdVdp14)2mKm4r5asDagEeERjbKGDPx3MQj8gQX)Tz4HvcaBWdsWU0RBt1eEHcKeYl8o8uJ)BZqYGhLdi1by4rHXBgpMf0bU(62unH3GRjgyiQ)gQF2ars9ZPEsr9cV1KasWU0RBt1eEd14)2m1hlg1RW4nJhZcib7sVUnvt4n4AIbgI6VH6NnqKu)CQx4TMeqc2LEDBQMWBOg)3MHhwjaSbpLDcHx3MQj8cfijAd8o8WkbGn4zc1hqAcbp14)2mKmOajHicVdp14)2mKm4r5asDagEif1l8wtcmsvlZMQHA8FBM6JfJ6)t66bgPQLzt1WuuQpwmQxHXBgpMfyKQwMnvdUMyGHO(4PEThj8WkbGn45VyC(Pp5UfkqsMfj8o8uJ)BZqYGhLdi1by4HuuVWBnjWivTmBQgQX)TzQpwmQ)pPRhyKQwMnvdtrHhwjaSbp)6q1fhWUGcKKzZG3HNA8FBgsg8OCaPoadpKI6fERjbgPQLzt1qn(Vnt9XIr9)jD9aJu1YSPAykk1hlg1RW4nJhZcmsvlZMQbxtmWquF8uV2JeEyLaWg8OdC9VyCgkqsMna8o8uJ)BZqYGhLdi1by4HuuVWBnjWivTmBQgQX)TzQpwmQ)pPRhyKQwMnvdtrP(yXOEfgVz8ywGrQAz2un4AIbgI6JN61EKWdRea2Gh2ufjoEFkExOajz2GH3HNA8FBgsg8WkbGn4XnzpwjaS9wasGhLdi1by4HvcG4(Q1eOiQpEQFaQFo1tAQhfT7(e2DvbfueyG9wWfbXa2f1hp1pa1hlg1JI2DFc7UQGcltm)(LtuF8u)aup5GNfGKNXPcpmUqbsYmIcEhEQX)TzizWdRea2Gh3K9yLaW2BbibEwasEgNk8Ga212NWURkqbkWtuxv40Nf4DijZG3HNA8FBgsguGKma8o8uJ)BZqYGcKKbdVdp14)2mKmOajHOG3HNA8FBgsguGKOD4D4HvcaBWJGLMEjgj1Dl8uJ)BZqYGcKKXdVdpSsaydE0bU(62unHx4Pg)3MHKbfijKx4D4HvcaBWtuSaWg8uJ)BZqYGcKeTbEhEyLaWg80TPAcVV)YibEQX)TzizqbkqbE4jHa2bphqAAzbGnICowxGcuGqa]] )


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
