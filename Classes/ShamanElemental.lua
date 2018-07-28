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
                    return ( state.buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( state.buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( state.buff.shock_of_the_twisting_nether.up and 1 or 0 )
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
            charges = function () return talent.echo_of_the_elements.enabled and 2 or 1 end,
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

    spec:RegisterPack( "Elemental", 20180728.1808, [[dGeejbqiespsscBsG8jPkOrjvPoLuL8ka1SOKCleIQDjYVKQAyusDmjLLHq9mjjnnPk6AifTnbuFdHiJtaPZHqO1jjrW8eOUhc2NaCqPkWcbOhkjrutusIIlkvH2OKerojcrzLsIxkjrYmrii3eHGANa4NsseAOssK6PsmvjvxvsIsNvsIk7vXFf1Gf6WelgrpgvtgOlRAZi5ZuQrlvoTsVgP0SHCBPSBQ(nOHJuDCbelNINd10jDDbTDa57ssnEecCEKcRxsIQMpLy)O8uBQpfqr)aaXwxlqTMirCGMQfOwhO1c0PO0G(NcDHtRy)P4s7tPhrVDxf0uOl0abfWP(uWWqd)tPtv64Qe633E1UqYeh26J3wis0f6CJqP9XBJ3Nebj7tsje5GhO(0nqQfDC)67nexRFDIRLlDst8CpIE7UkOeEB8PqgUiLiZhYPak6hai26AbQ1ejId0uTa16EwRNtbt)8baIdmXtb8y(uQ3TywCXSOWIGNscrklsx40k2NfHuSOW1f6SiAXkMfPGgwShrVDxfelw6KM4ywKcAyraP6bPPq3aPw0NsvWI9irW5H6bzrYtbnNf5WgPOSi5TxhNyXEaNF6kMfDOtK3jMgviIffUUqhZIqhrJeRIW1f64eDZ5WgPOeOqcMwwfHRl0Xj6MZHnsrbMqFkieKvr46cDCIU5CyJuuGj0xcTB3vrxOZQufSyXf64oOYIgzbzrYqkQdYIyvumlsEkO5Sih2ifLfjV96ywuCqwKU5e50HQUUnlUywee6pXQiCDHoor3CoSrkkWe6JDHoUdQzSkkMvr46cDCIU5CyJuuGj0xH6B5MG1BObRIW1f64eDZ5WgPOatOp1AE(O3URcIvr46cDCIU5CyJuuGj0NouxOZQiCDHoor3CoSrkkWe6F0B3vbLjrcwzvyvQcwShjcopupilEGUHgSOUTZIA3zrHRqdlUywuaswKqIEIvPkyrarqiikeRSixW662Si57eGwOHfBRXanywu7olI3wisuOHfXx11TXSif0WI0nqIaAWIKiieefI1elw(zriDDHoMf7HKiieefI1m9B431EOvSO4GSypKebHGOqSM1T9EyIfzveUUqhtGebHGOqSA1srqfJ91u3fK2LOZ1GjMMwSOB7byDIMwBnRsvWIezoroh2ifLfPd1f6S4Izr6MtDZDDfeIgSiADApilQqwKgWqdl2JO3URcYkwm0rhJzroSrkklw9IqS4Dqwe3bnkIgSkcxxOJbMqF6qDHoRsvWIezUEJjKUYIqkwKlyfZIIdYIlMfnhTcj6SOAwB7Byriflwo9UWQ8Sy5CZ1eRIW1f6yGj0V61bZ4UlgwfHRl0XatOVc13YnbR3qdRwkcKHuujZXqxC(ZkuFlzEtwhhmXSkcxxOJbMqFQ188rVDxfeRIW1f6yGj0hRqtlF0B3vbXQiCDHogyc9Vy0U8rVDxfKvlfboeIaHv7jQ188rVDxfuY8MSoo4AeBDqevf0DnHvOPLp6T7QGs3fs0bTyHdHiqy1EcRqtlF0B3vbLmVjRJdUgXwhKkO7AcRqtlF0B3vbLUlKOdYQiCDHogyc9dXpV6BywfHRl0XatOpjccbZuHgAy1srGOQGURjbZVdko)P7cj6GwSqgsrLem)oO48NcPBXchcrGWQ9KG53bfN)K5nzDCa00AwfHRl0XatOp5n4BODDBRwkcevf0Dnjy(DqX5pDxirh0IfYqkQKG53bfN)uiDwfHRl0XatOVj0ZcxxONrlwTYL2jiWB1srq46c0Z3FBpoaIdQ3y6hHYQySVIt8oz9mAT7uFD7ai2Ifm9Jqzvm2xXjKaKKjV0cG4EXQiCDHogyc9nHEw46c9mAXQvU0ob862ONvXyFLvHvPkyrIWHiDzrvm2xzrHRl0zr6MfAwLgSiAXkRIW1f64KapbScnnA)PFdRIW1f64KapWe6ly(DqX53QLIGkO7AcRqtlF0B3vbLUlKOdgehcrGWQ9ewHMw(O3URckzEtwhhCnIToioeIaHv7jScnT8rVDxfuY8MSooGA00IfIQc6UMWk00Yh92DvqP7cj6GSkcxxOJtc8atOpAdKWfm3e7MKvO(gRIW1f64KapWe6tHK2Z4oiNwRwkcy6hHYQySVIt8oz9mAT7uFD7G7PvQySVMxkcMtzoUtirNvPkyXQCWWEO5SiccPDDBwuuwuCwuiHT1fDHEIfRYDmlw9QDSiUdgIaVbZI0agYICXzrUGvwe6iAWI9Oy0owS0b50YIGHM1TzXEa8SO4GSy1YQSif0WI4oyic8gwKUbYXjwSE3Izr6iHgyLgOZIvdn0IzrkOHfdMalgywufJ9vCIfbmuzrYZIs1I5SO2jklsdyypeHyrYZI2sJeTUnlcD(zXg08ukXQiCDHoojWdmH(xmAxg3b50A1sr4bs4sN(btN3bpodPYA3Z2MlAgh6G3SUnRIW1f64KapWe6FXODbsOq7TAPi8ajCPt)GPZ7GhNHuzT7zBZfnJdDWBw3oiYqkQ05DWJZqQS29ST5IMXHo4nRBNcPBXcrFGeU0PFW05DWJZqQS29ST5IMXHo4nRBZQufSyvIoIgSixWklsesasyradnyLfHolQDMFwufJ9vmlUuS4QS4IzrXzX1XQ4AIvr46cDCsGhyc9rcqsMm0GvRwkc9MmKIkHeGKmo0y)uiDlwidPOscMFhuC(tH07vqy6hHYQySVIt8oz9mAT7uFD7G7jRIW1f64KapWe6F0B3vbLjrcwTAPiGPFekRIX(koX7K1ZO1Ut91TdUNSkcxxOJtc8atOpsasYKxASkcxxOJtc8atOpVtwpJw7o1x3Mvr46cDCsGhyc9rcqsMm0GvRAqGw3MqnwfHRl0XjbEGj0NcjTNXDqoTw1GaTUnHAwPIX(AEPiyoL54oHeDwfHRl0XjbEGj0NYaXAg3b50Avdc062eQXQWQufSyzDB0zX6IX(kl2d46cDwSkTzHMvPblseAXkRIW1f64eEDB0ZQySVsGcjTNXDqoTwTueiQUCAx32IfqOMOqs7zChKtBY8MSooyc2CqwfHRl0Xj862ONvXyFfyc9fm)oO48B1srO362EaecS1wSqgsrLirqiikeRPq69kioeIaHv7jKaKKjdnynzEtwhhG1bruvq31ewHMw(O3URckDxirhKvr46cDCcVUn6zvm2xbMqFbZVdko)wTue6TUThaHaBTflKHuujseecIcXAkKEVcIdHiqy1EcjajzYqdwtM3K1XbyDqCiebcR2tyfAA5JE7UkOK5nzDCWeQrS1SkvblwLb69qLfdXNf7r0B3vbXIaIeSYIlflsdyilYHHiqwKlyLffwKiSG1ByriflQDNf7r0B3vml(gDy13CqwShfJ2XILoiNwwCDSEbmXQiCDHooHx3g9Skg7RatO)rVDxfuMejy1QLIGkO7AQjy9MmKkRDpF0B3vC6UqIoyqKHuuPMG1BYqQS298rVDxXPq6b1KJWQb2coWwBXcrvbDxtnbR3KHuzT75JE7UIt3fs0bzvQcwSk1pDwSuLIfPGgwejg7ZIqdlIHqNffqqwSAbOJtSkcxxOJt41TrpRIX(kWe6JvOPr7p9BSAPiyKfmFGURjbeeN4WqxdUQwSyKfmFGURjbeeNwpaAAnRIW1f64eEDB0ZQySVcmH(OnqcxWCtSBswH6BwTuemYcMpq31KacItCyORbxvlwmYcMpq31KacItRhanTMvPkyXQS4ZI0agAyr6giNfjpf0CwKlyDDBwShfJ2XILoiNwwuSL1tSkcxxOJt41TrpRIX(kWe6FXODbsOq7TAPiqgsrLoVdECgsL1UNTnx0mo0bVzD7uiDwLQGfRYIplQDNfbpzifflsEkO5SixW662SypkgTJflDqoTSOylRNyveUUqhNWRBJEwfJ9vGj0hT2DQVUDMeIuRwkcGNmKIkDIa6q8bZh92DfNcPhutocRgylacb26GikzifvsW87GIZFkKoRsvWIezuSiDigVKOBflgIpl2JIr7yXshKtllw9QDSirybR3WIqkwu7ol2JO3UR4eRIW1f64eEDB0ZQySVcmH(xmAxg3b50A1srqf0Dn1eSEtgsL1UNp6T7koDxirhmOEtgsrLAcwVjdPYA3Zh92DfNcPBXstocRgylacerI7Lflevf0Dn1eSEtgsL1UNp6T7koDxirhKvr46cDCcVUn6zvm2xbMqFKaKKjdny1QLIahcrGWQ9S5cxTyHmKIkjy(DqX5pfsNvr46cDCcVUn6zvm2xbMqFkK0Eg3b50ALkg7R5LIG5uMJ7es0zveUUqhNWRBJEwfJ9vGj0xH6B5MG1BOHvlfbYqkQK5yOlo)zfQVLmVjRJdoWwS0BYqkQK5yOlo)zfQVLmVjRJdU3KHuujbZVdko)jWqJOl0bMdHiqy1EsW87GIZFY8MSoUxbXHqeiSApjy(DqX5pzEtwhhCnA2lwfHRl0Xj862ONvXyFfyc9PmqSMXDqoTwTueidPOsl)uHgAKcPZQiCDHooHx3g9Skg7RatO)YpvOHgSkcxxOJt41TrpRIX(kWe6JeGKm5LMvlfbHRlqpF)T94aQfeM(rOSkg7R4esasYKxAbuJvr46cDCcVUn6zvm2xbMqFENSEgT2DQVUTvlfbHRlqpF)T94aQfeM(rOSkg7R4eVtwpJw7o1x3oGASkcxxOJt41TrpRIX(kWe6Jw7o1x3otcrkRIW1f64eEDB0ZQySVcmH(uiP9mUdYP1QgeO1TjuZkvm2xZlfbZPmh3jKOZQiCDHooHx3g9Skg7RatOpfsApJ7GCATQbbADBc1SAPi0Ga92DnbUyvC(diWSkvblwLKbIvwS0b50YIlMfHHgwSbb6T7klsTi0njwfHRl0Xj862ONvXyFfyc9PmqSMXDqoTw1GaTUnHAUk6cDwfHRl0Xj6MZHnsrbMqFSl0XDqnJvrXSkcxxOJt0nNdBKIcmH(kuFl3eSEdnyveUUqhNOBoh2iffyc9PwZZh92DvqSkcxxOJt0nNdBKIcmH(yfAA5JE7UkiwfHRl0Xj6MZHnsrbMqF6qDHoRIW1f64eDZ5WgPOatO)rVDxfuMejyLvHvr46cDmWe6tIGqquiwzveUUqhdmH(0H6cDwfHRl0XatOF1RdMXDxmSkcxxOJbMqFfQVLBcwVHgwTueidPOsMJHU48NvO(wY8MSooyIzveUUqhdmH(uR55JE7UkiwfHRl0XatOpwHMw(O3URcIvr46cDmWe6FXOD5JE7UkiRwkcCiebcR2tuR55JE7UkOK5nzDCW1i26GiQkO7AcRqtlF0B3vbLUlKOdAXchcrGWQ9ewHMw(O3URckzEtwhhCnIToivq31ewHMw(O3URckDxirhKvr46cDmWe6hIFE13WSkcxxOJbMqFseecMPcn0WQLIarvbDxtcMFhuC(t3fs0bTyHmKIkjy(DqX5pfs3IfoeIaHv7jbZVdko)jZBY64aOP1SkcxxOJbMqFX5hRgbL5ccz1srGOQGURjbZVdko)P7cj6GwSqgsrLem)oO48NcPBXchcrGWQ9KG53bfN)K5nzDCa00AwfHRl0XatOp1AojccbTAPiquvq31KG53bfN)0DHeDqlwidPOscMFhuC(tH0TyHdHiqy1EsW87GIZFY8MSooaAAnRIW1f6yGj0N8g8n0UUTvlfbIQc6UMem)oO48NUlKOdAXczifvsW87GIZFkKoRIW1f6yGj03e6zHRl0ZOfRw5s7ee4TAPiiCDb657VThhaXb1Bm9Jqzvm2xXjENSEgT2DQVUDaeBXcM(rOSkg7R4esasYKxAbqCVyveUUqhdmH(MqplCDHEgTy1kxANaEDB0ZQySVYQWQWQ0Vpl2dGNf7bvPjcXQiCDHoojWtaRqtJ2F63WQiCDHoojWdmH(cMFhuC(TAPiOc6UMWk00Yh92DvqP7cj6GbXHqeiSApHvOPLp6T7QGsM3K1XbxJyRdIdHiqy1EcRqtlF0B3vbLmVjRJdOgnTyHOQGURjScnT8rVDxfu6UqIoiRIW1f64KapWe6J2ajCbZnXUjzfQVXQiCDHoojWdmH(uiP9mUdYP1QLIaM(rOSkg7R4eVtwpJw7o1x3o4EALkg7R5LIG5uMJ7es0zveUUqhNe4bMq)lgTlqcfApRIW1f64KapWe6JeGKmzObRwTue6nzifvcjajzCOX(Pq6wSqgsrLem)oO48NcP3RGW0pcLvXyFfN4DY6z0A3P(62b3twfHRl0XjbEGj0)O3URcktIeSA1srat)iuwfJ9vCI3jRNrRDN6RBhCpzveUUqhNe4bMqFKaKKjV0yveUUqhNe4bMqFENSEgT2DQVUnRIW1f64KapWe6JeGKmzObRw1GaTUnHASkcxxOJtc8atOpfsApJ7GCATQbbADBc1SAPiyoL54oHeDwfHRl0XjbEGj0NYaXAg3b50Avdc062eQXQWQ0Vplww3gDwufJ9vwKiNf7by(DqX5Nvr46cDCcVUn6zvm2xjqHK2Z4oiNwRwkcevxoTRBBXciutuiP9mUdYPnzEtwhhmbBoiRIW1f64eEDB0ZQySVcmH(cMFhuC(TAPi0BDBpacb2AlwidPOsKiieefI1ui9EfehcrGWQ9esasYKHgSMmVjRJdW6GiQkO7AcRqtlF0B3vbLUlKOdYQiCDHooHx3g9Skg7RatOVG53bfNFRwkc9w32dGqGT2IfYqkQejccbrHynfsVxbXHqeiSApHeGKmzObRjZBY64aSoioeIaHv7jScnT8rVDxfuY8MSooyc1i2AwfwfHRl0Xj862ONvXyFLWrVDxfuMejy1QLIGkO7AQjy9MmKkRDpF0B3vC6UqIoyqKHuuPMG1BYqQS298rVDxXPq6b1KJWQb2coWwBXcrvbDxtnbR3KHuzT75JE7UIt3fs0bzveUUqhNWRBJEwfJ9vGj0hRqtJ2F63y1srWily(aDxtciioXHHUgCvTyXily(aDxtciioTEa00AwfHRl0Xj862ONvXyFfyc9rBGeUG5My3KSc13SAPiyKfmFGURjbeeN4WqxdUQwSyKfmFGURjbeeNwpaAAnRIW1f64eEDB0ZQySVcmH(xmAxGek0ERwkcKHuuPZ7GhNHuzT7zBZfnJdDWBw3ofsNvr46cDCcVUn6zvm2xbMqF0A3P(62zsisTAPiaEYqkQ0jcOdXhmF0B3vCkKEqn5iSAGTaieyRdIOKHuujbZVdko)Pq6SkcxxOJt41TrpRIX(kWe6FXODzChKtRvlfbvq31utW6nzivw7E(O3UR40DHeDWG6nzifvQjy9MmKkRDpF0B3vCkKUfln5iSAGTaiqejUxwSquvq31utW6nzivw7E(O3UR40DHeDqwfHRl0Xj862ONvXyFfyc9rcqsMm0GvRwkcCiebcR2ZMlC1IfYqkQKG53bfN)uiDwfHRl0Xj862ONvXyFfyc9Pqs7zChKtRvlfbZPmh3jKOZQiCDHooHx3g9Skg7RatOVc13YnbR3qdRwkcKHuujZXqxC(ZkuFlzEtwhhCGTyP3KHuujZXqxC(ZkuFlzEtwhhCVjdPOscMFhuC(tGHgrxOdmhcrGWQ9KG53bfN)K5nzDCVcIdHiqy1EsW87GIZFY8MSoo4A0SxSkcxxOJt41TrpRIX(kWe6tzGynJ7GCATAPiqgsrLw(Pcn0ifsNvr46cDCcVUn6zvm2xbMq)LFQqdnyveUUqhNWRBJEwfJ9vGj0hjajzYlnRwkccxxGE((B7Xbulim9Jqzvm2xXjKaKKjV0cOgRIW1f64eEDB0ZQySVcmH(8oz9mAT7uFDBRwkccxxGE((B7Xbulim9Jqzvm2xXjENSEgT2DQVUDa1yveUUqhNWRBJEwfJ9vGj0hT2DQVUDMeIuwfHRl0Xj862ONvXyFfyc9Pqs7zChKtRvniqRBtOMvlfbZPmh3jKOZQiCDHooHx3g9Skg7RatOpfsApJ7GCATQbbADBc1SAPi0Ga92DnbUyvC(diWSkcxxOJt41TrpRIX(kWe6tzGynJ7GCATQbbADBc1Mcq3GxOpaqS11cuRjs1OzI4QsmnNs1IXx3gpfISgDOrpil2twu46cDweTyfNyvMIeQDqZukBlej6c9QKncLYIvzoq4PGwSIN6tbVUn6zvm2xN6da1M6t5UqIo4a4u4MvVzLPquwuxoTRBZIwSWIGqnrHK2Z4oiN2K5nzDmlgmbw0MdofHRl0NcfsApJ7GCAhDaG4P(uUlKOdoaofUz1Bwzk9Mf1TDwmacSyGTMfTyHfjdPOsKiieefI1uiDwSxSyqSihcrGWQ9esasYKHgSMmVjRJzXayrRzXGyrIYIQGURjScnT8rVDxfu6UqIo4ueUUqFkcMFhuC(hDaOQt9PCxirhCaCkCZQ3SYu6nlQB7SyaeyXaBnlAXclsgsrLirqiikeRPq6SyVyXGyroeIaHv7jKaKKjdnynzEtwhZIbWIwZIbXICiebcR2tyfAA5JE7UkOK5nzDmlgmbwSgXwpfHRl0NIG53bfN)rha65uFk3fs0bhaNc3S6nRmfvq31utW6nzivw7E(O3UR40DHeDqwmiwKmKIk1eSEtgsL1UNp6T7kofsNfdIfBYry1aBSyWSyGTMfTyHfjklQc6UMAcwVjdPYA3Zh92DfNUlKOdofHRl0NYrVDxfuMejyD0baAo1NYDHeDWbWPWnREZktXily(aDxtciioXHHUYIbZIvLfTyHfnYcMpq31KacItRZIbWI006PiCDH(uWk00O9N(nJoae4P(uUlKOdoaofUz1BwzkgzbZhO7AsabXjom0vwmywSQSOflSOrwW8b6UMeqqCADwmawKMwpfHRl0NcAdKWfm3e7MKvO(2OdaePP(uUlKOdoaofUz1BwzkKHuuPZ7GhNHuzT7zBZfnJdDWBw3ofsFkcxxOpLlgTlqcfA)Odab6uFk3fs0bhaNc3S6nRmfWtgsrLoraDi(G5JE7UItH0zXGyXMCewnWglgabwmWwZIbXIeLfjdPOscMFhuC(tH0NIW1f6tbT2DQVUDMeI0rhaiIt9PCxirhCaCkCZQ3SYuubDxtnbR3KHuzT75JE7UIt3fs0bzXGyXEZIKHuuPMG1BYqQS298rVDxXPq6SOflSytocRgyJfdGalsejMf7flAXclsuwuf0Dn1eSEtgsL1UNp6T7koDxirhCkcxxOpLlgTlJ7GCAhDaOM1t9PCxirhCaCkCZQ3SYu4qicewTNnx4klAXclsgsrLem)oO48NcPpfHRl0NcsasYKHgSo6aqTAt9PCxirhCaCkCZQ3SYumNYCCNqI(ueUUqFkuiP9mUdYPD0bGAep1NYDHeDWbWPWnREZktHmKIkzog6IZFwH6BjZBY6ywmywmWSOflSyVzrYqkQK5yOlo)zfQVLmVjRJzXGzXEZIKHuujbZVdko)jWqJOl0zrGzroeIaHv7jbZVdko)jZBY6ywSxSyqSihcrGWQ9KG53bfN)K5nzDmlgmlwJMSyVMIW1f6trH6B5MG1BOXOda1Q6uFk3fs0bhaNc3S6nRmfYqkQ0YpvOHgPq6tr46c9PqzGynJ7GCAhDaOwpN6tr46c9PS8tfAOXuUlKOdoao6aqnAo1NYDHeDWbWPWnREZktr46c0Z3FBpMfdGfRXIbXIy6hHYQySVItibijtEPXIbWI1MIW1f6tbjajzYlTrhaQf4P(uUlKOdoaofUz1BwzkcxxGE((B7XSyaSynwmiwet)iuwfJ9vCI3jRNrRDN6RBZIbWI1MIW1f6tH3jRNrRDN6RBp6aqnI0uFkcxxOpf0A3P(62zsisNYDHeDWbWrhaQfOt9PCxirhCaCkCZQ3SYumNYCCNqI(ueUUqFkuiP9mUdYPDkniqRBpLAJoauJio1NYDHeDWbWPWnREZktPbb6T7AcCXQ48ZIbWIbEkcxxOpfkK0Eg3b50oLgeO1TNsTrhai26P(uAqGw3Ek1Cv0f6tr46c9PqzGynJ7GCANYDHeDWbWrhaiU2uFk3fs0bhaNc3S6nRmfIYI6YPDDBw0IfweeQjkK0Eg3b50MmVjRJzXGjWI2CWPiCDH(uOqs7zChKt7Odaet8uFk3fs0bhaNc3S6nRmLEZI62olgabwmWwZIwSWIKHuujseecIcXAkKol2lwmiwKdHiqy1EcjajzYqdwtM3K1XSyaSO1SyqSirzrvq31ewHMw(O3URckDxirhCkcxxOpfbZVdko)JoaqCvN6t5UqIo4a4u4MvVzLP0Bwu32zXaiWIb2Aw0IfwKmKIkrIGqquiwtH0zXEXIbXICiebcR2tibijtgAWAY8MSoMfdGfTMfdIf5qicewTNWk00Yh92DvqjZBY6ywmycSynITEkcxxOpfbZVdko)JoaqCpN6t5UqIo4a4u4MvVzLPOc6UMAcwVjdPYA3Zh92DfNUlKOdYIbXIKHuuPMG1BYqQS298rVDxXPq6SyqSytocRgyJfdMfdS1SOflSirzrvq31utW6nzivw7E(O3UR40DHeDWPiCDH(uo6T7QGYKibRJoaqmnN6t5UqIo4a4u4MvVzLPyKfmFGURjbeeN4WqxzXGzXQYIwSWIgzbZhO7AsabXP1zXayrAA9ueUUqFkyfAA0(t)MrhaioWt9PCxirhCaCkCZQ3SYumYcMpq31KacItCyORSyWSyvzrlwyrJSG5d0DnjGG406SyaSinTEkcxxOpf0giHlyUj2njRq9TrhaiMin1NYDHeDWbWPWnREZktHmKIkDEh84mKkRDpBBUOzCOdEZ62Pq6tr46c9PCXODbsOq7hDaG4aDQpL7cj6GdGtHBw9MvMc4jdPOsNiGoeFW8rVDxXPq6SyqSytocRgyJfdGalgyRzXGyrIYIKHuujbZVdko)Pq6tr46c9PGw7o1x3otcr6OdaeteN6t5UqIo4a4u4MvVzLPOc6UMAcwVjdPYA3Zh92DfNUlKOdYIbXI9MfjdPOsnbR3KHuzT75JE7UItH0zrlwyXMCewnWglgabwKisml2lw0IfwKOSOkO7AQjy9MmKkRDpF0B3vC6UqIo4ueUUqFkxmAxg3b50o6aqvTEQpL7cj6GdGtHBw9MvMchcrGWQ9S5cxzrlwyrYqkQKG53bfN)ui9PiCDH(uqcqsMm0G1rhaQATP(uUlKOdoaofUz1BwzkMtzoUtirFkcxxOpfkK0Eg3b50o6aqvjEQpL7cj6GdGtHBw9MvMczifvYCm0fN)Sc13sM3K1XSyWSyGzrlwyXEZIKHuujZXqxC(ZkuFlzEtwhZIbZI9MfjdPOscMFhuC(tGHgrxOZIaZICiebcR2tcMFhuC(tM3K1XSyVyXGyroeIaHv7jbZVdko)jZBY6ywmywSgnzXEnfHRl0NIc13YnbR3qJrhaQAvN6t5UqIo4a4u4MvVzLPqgsrLw(Pcn0ifsFkcxxOpfkdeRzChKt7OdavTNt9PiCDH(uw(Pcn0yk3fs0bhahDaOQ0CQpL7cj6GdGtHBw9MvMIW1fONV)2EmlgalwJfdIfX0pcLvXyFfNqcqsM8sJfdGfRnfHRl0NcsasYKxAJoau1ap1NYDHeDWbWPWnREZktr46c0Z3FBpMfdGfRXIbXIy6hHYQySVIt8oz9mAT7uFDBwmawS2ueUUqFk8oz9mAT7uFD7rhaQkrAQpfHRl0NcAT7uFD7mjePt5UqIo4a4OdavnqN6t5UqIo4a4u4MvVzLPyoL54oHe9PiCDH(uOqs7zChKt7uAqGw3Ek1gDaOQeXP(uUlKOdoaofUz1BwzkniqVDxtGlwfNFwmawmWtr46c9PqHK2Z4oiN2P0GaTU9uQn6aqpTEQpLgeO1TNsTPiCDH(uOmqSMXDqoTt5UqIo4a4OJofb(P(aqTP(ueUUqFkyfAA0(t)MPCxirhCaC0baIN6t5UqIo4a4u4MvVzLPOc6UMWk00Yh92DvqP7cj6GSyqSihcrGWQ9ewHMw(O3URckzEtwhZIbZI1i2AwmiwKdHiqy1EcRqtlF0B3vbLmVjRJzXayXA0KfTyHfjklQc6UMWk00Yh92DvqP7cj6Gtr46c9Piy(DqX5F0bGQo1NIW1f6tbTbs4cMBIDtYkuFBk3fs0bhahDaONt9PCxirhCaCkCZQ3SYuW0pcLvXyFfN4DY6z0A3P(62SyWSypNIW1f6tHcjTNXDqoTtrfJ918snfZPmh3jKOp6aanN6t5UqIo4a4u4MvVzLP8ajCPt)GPZ7GhNHuzT7zBZfnJdDWBw3EkcxxOpLlgTlJ7GCAhDaiWt9PCxirhCaCkCZQ3SYuEGeU0PFW05DWJZqQS29ST5IMXHo4nRBZIbXIKHuuPZ7GhNHuzT7zBZfnJdDWBw3ofsNfTyHfjkl(ajCPt)GPZ7GhNHuzT7zBZfnJdDWBw3EkcxxOpLlgTlqcfA)OdaePP(uUlKOdoaofUz1Bwzk9MfjdPOsibijJdn2pfsNfTyHfjdPOscMFhuC(tH0zXEXIbXIy6hHYQySVIt8oz9mAT7uFDBwmywSNtr46c9PGeGKmzObRJoaeOt9PCxirhCaCkCZQ3SYuW0pcLvXyFfN4DY6z0A3P(62SyWSypNIW1f6t5O3URcktIeSo6aarCQpfHRl0NcsasYKxAt5UqIo4a4Oda1SEQpfHRl0NcVtwpJw7o1x3Ek3fs0bhahDaOwTP(uAqGw3Ek1MIW1f6tbjajzYqdwNYDHeDWbWrhaQr8uFk3fs0bhaNc3S6nRmfZPmh3jKOpfHRl0NcfsApJ7GCANsdc062tP2Oda1Q6uFkniqRBpLAtr46c9PqzGynJ7GCANYDHeDWbWrhaQ1ZP(ueUUqFkyfAA0(t)MPCxirhCaC0bGA0CQpL7cj6GdGtHBw9MvMIkO7AcRqtlF0B3vbLUlKOdYIbXICiebcR2tyfAA5JE7UkOK5nzDmlgmlwJyRzXGyroeIaHv7jScnT8rVDxfuY8MSoMfdGfRrtw0IfwKOSOkO7AcRqtlF0B3vbLUlKOdofHRl0NIG53bfN)rhaQf4P(ueUUqFkOnqcxWCtSBswH6Bt5UqIo4a4Oda1ist9PCxirhCaCkCZQ3SYuW0pcLvXyFfN4DY6z0A3P(62SyWSypNIW1f6tHcjTNXDqoTtrfJ918snfZPmh3jKOp6aqTaDQpfHRl0NYfJ2fiHcTFk3fs0bhahDaOgrCQpL7cj6GdGtHBw9MvMsVzrYqkQesasY4qJ9tH0zrlwyrYqkQKG53bfN)uiDwSxSyqSiM(rOSkg7R4eVtwpJw7o1x3MfdMf75ueUUqFkibijtgAW6OdaeB9uFk3fs0bhaNc3S6nRmfm9Jqzvm2xXjENSEgT2DQVUnlgml2ZPiCDH(uo6T7QGYKibRJoaqCTP(ueUUqFkibijtEPnL7cj6GdGJoaqmXt9PiCDH(u4DY6z0A3P(62t5UqIo4a4Odaex1P(uAqGw3Ek1MIW1f6tbjajzYqdwNYDHeDWbWrhaiUNt9PCxirhCaCkCZQ3SYumNYCCNqI(ueUUqFkuiP9mUdYPDkniqRBpLAJoaqmnN6tPbbAD7PuBkcxxOpfkdeRzChKt7uUlKOdoao6Otb8usisN6da1M6t5UqIo4qofUz1BwzkQySVM6UG0UeDUYIbZIettw0Ifwu32zXayrRt00ARNIW1f6tHebHGOqSo6aaXt9PiCDH(uOd1f6t5UqIo4a4OdavDQpfHRl0Ns1RdMXDxmt5UqIo4a4Oda9CQpL7cj6GdGtHBw9MvMczifvYCm0fN)Sc13sM3K1XSyWSiXtr46c9POq9TCtW6n0y0baAo1NIW1f6tHAnpF0B3vbnL7cj6GdGJoae4P(ueUUqFkyfAA5JE7UkOPCxirhCaC0baI0uFk3fs0bhaNc3S6nRmfoeIaHv7jQ188rVDxfuY8MSoMfdMfRrS1SyqSirzrvq31ewHMw(O3URckDxirhKfTyHf5qicewTNWk00Yh92DvqjZBY6ywmywSgXwZIbXIQGURjScnT8rVDxfu6UqIo4ueUUqFkxmAx(O3URcA0bGaDQpfHRl0Nsi(5vFdpL7cj6GdGJoaqeN6t5UqIo4a4u4MvVzLPquwuf0Dnjy(DqX5pDxirhKfTyHfjdPOscMFhuC(tH0zrlwyroeIaHv7jbZVdko)jZBY6ywmawKMwpfHRl0NcjccbZuHgAm6aqnRN6t5UqIo4a4u4MvVzLPquwuf0Dnjy(DqX5pDxirhKfTyHfjdPOscMFhuC(tH0NIW1f6tH8g8n0UU9Oda1Qn1NYDHeDWbWPWnREZktr46c0Z3FBpMfdGfjMfdIf7nlIPFekRIX(koX7K1ZO1Ut91TzXayrIzrlwyrm9Jqzvm2xXjKaKKjV0yXayrIzXEnfHRl0NIj0ZcxxONrlwNcAXA2L2NIa)Oda1iEQpL7cj6GdGtr46c9Pyc9SW1f6z0I1PGwSMDP9PGx3g9Skg7RJoauRQt9PiCDH(uirqiikeRt5UqIo4qo6aqTEo1NIW1f6tHouxOpL7cj6GdGJoauJMt9PiCDH(uQEDWmU7Izk3fs0bhahDaOwGN6t5UqIo4a4u4MvVzLPqgsrLmhdDX5pRq9TK5nzDmlgmls8ueUUqFkkuFl3eSEdngDaOgrAQpfHRl0Nc1AE(O3URcAk3fs0bhahDaOwGo1NIW1f6tbRqtlF0B3vbnL7cj6GdGJoauJio1NYDHeDWbWPWnREZktHdHiqy1EIAnpF0B3vbLmVjRJzXGzXAeBnlgelsuwuf0DnHvOPLp6T7QGs3fs0bzrlwyroeIaHv7jScnT8rVDxfuY8MSoMfdMfRrS1SyqSOkO7AcRqtlF0B3vbLUlKOdofHRl0NYfJ2Lp6T7QGgDaGyRN6tr46c9PeIFE13Wt5UqIo4a4OdaexBQpL7cj6GdGtHBw9MvMcrzrvq31KG53bfN)0DHeDqw0IfwKmKIkjy(DqX5pfsNfTyHf5qicewTNem)oO48NmVjRJzXayrAA9ueUUqFkKiiemtfAOXOdaet8uFk3fs0bhaNc3S6nRmfIYIQGURjbZVdko)P7cj6GSOflSizifvsW87GIZFkKolAXclYHqeiSApjy(DqX5pzEtwhZIbWI006PiCDH(ueNFSAeuMli0Odaex1P(uUlKOdoaofUz1BwzkeLfvbDxtcMFhuC(t3fs0bzrlwyrYqkQKG53bfN)uiDw0IfwKdHiqy1EsW87GIZFY8MSoMfdGfPP1tr46c9PqTMtIGqWrhaiUNt9PCxirhCaCkCZQ3SYuiklQc6UMem)oO48NUlKOdYIwSWIKHuujbZVdko)Pq6tr46c9PqEd(gAx3E0baIP5uFk3fs0bhaNc3S6nRmfHRlqpF)T9ywmawKywmiwS3SiM(rOSkg7R4eVtwpJw7o1x3MfdGfjMfTyHfX0pcLvXyFfNqcqsM8sJfdGfjMf71ueUUqFkMqplCDHEgTyDkOfRzxAFkc8JoaqCGN6t5UqIo4a4ueUUqFkMqplCDHEgTyDkOfRzxAFk41TrpRIX(6OJof6MZHnsrN6da1M6t5UqIo4a4Odaep1NYDHeDWbWrhaQ6uFk3fs0bhahDaONt9PCxirhCaC0baAo1NIW1f6trH6B5MG1BOXuUlKOdoao6aqGN6tr46c9PqTMNp6T7QGMYDHeDWbWrhaist9PiCDH(uOd1f6t5UqIo4a4Odab6uFkcxxOpLJE7UkOmjsW6uUlKOdoao6aarCQpL7cj6GdGJoauZ6P(ueUUqFkkuFl3eSEdnMYDHeDWbWrhaQvBQpfHRl0Nc1AE(O3URcAk3fs0bhahDaOgXt9PiCDH(uWk00Yh92Dvqt5UqIo4a4Oda1Q6uFkcxxOpf6qDH(uUlKOdoao6aqTEo1NIW1f6t5O3URcktIeSoL7cj6GdGJo6OJo6ma]] )

    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        package = "Elemental",
    } )
end
