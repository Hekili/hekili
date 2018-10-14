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

    
    spec:RegisterPack( "Elemental", 20181014.1124, [[dGeQUaqiefpsiQnPO6tkkv0OiLQtje5viQMfPKBPOu2LGFjQAycLoMq1YeL8mesMMqrxtrjBdrjFtOqghPuCoes16ekW8uL4EKI9jk1bfkOfIi9qeLsturPsUicrBurPsDsHc1kfvEPIsvntfLQCteLk7er8teLIHIqklfHGNQIPQk1vvuQWEb9xvAWu1HrTyv1JjzYkCzPntQ(SImAeCAGxleMTs3wKDt53qnCH0XjLslNkphY0jUUQy7iuFxrX4ri05vL06ruQA(II9J0W4W3WZGLcjjRyJRnXJnEmdXJNvmjQ4WJ8A0cprzve8uHhJtfEiYTPAcVWtu(1fZd4B4bHFCQcpeejkkgKp)eqi88dkCkpcKEwwayt5yDjpcKu5)l(N)RZZ2OeNpQdRd2IYt0CLiWGbkprJiCpe4eBxICBQMWBabsk45)awjgBWp8myPqsYk24At8yJhZq84zfZS0g4bfTkijzrwzbpeaJrn4hEgfPGNit9e52unHxQ)qGtSrZfzQNGirrXG85NacHNFqHt5rG0ZYcaBkhRl5rGKk)FX)8FDE2gL48rDyDWwuEIMRebgmq5jAeH7HaNy7sKBt1eEdiqsrZfzQNSrj4FDuF8yQf1NvSX1gQF2O(4XJbzruWtuhwhSfEIm1tKBt1eEP(dboXgnxKPEcIeffdYNFcieE(bfoLhbspllaSPCSUKhbsQ8)f)Z)15zBuIZh1H1bBr5jAUseyWaLNOreUhcCITlrUnvt4nGajfnxKPEYgLG)1r9XJPwuFwXgxBO(zJ6JhpgKfrrZrZfzQNSLaBtffdO5Im1pBuprOjmXL6fqQuFEQ)Vy8yFqc1RiuveuVUdNO(yisvBWMQbAoAUit9ejrSQhPdQ)xDSRuVcN(Sq9)obmuG6JHkvJkiQ3W2SrGDj9NL6zLaWgI6X2(AGMJvcaBOquxv40Nfn6lJIGMJvcaBOquxv40NfY1KxhJh0CSsaydfI6QcN(SqUM88ZuQMWcaB0CrM6pghfraluVJbdQ))OR3b1Jewqu)V6yxPEfo9zH6)DcyiQNTb1h11zlkweGnr9ae1pWwd0CSsaydfI6QcN(SqUM8iJJIiGLlsybrZXkbGnuiQRkC6Zc5AYlyPPBIrsDVsZXkbGnuiQRkC6Zc5AYRdC92TPAcV0CSsaydfI6QcN(SqUM8rXcaB0CSsaydfI6QcN(SqUM8DBQMW79VmsO5O5Im1tKeXQEKoO(sCDVs9civQxiuQNvc2r9ae1ZeZGL)Bd0CrM6jBzKq9KUy8yFqc1Ny7H39vQhOt9cHs9XqY(6asP(3ogiuFm0ufjoEPEIqryJnvPEaI6J6kQMeO5yLaWgsZFX4X(GeTa6AyY(6asdSPksC8EDfHn2unuJ)Bh0CrM6JX2SPWPpluFuSaWg1dquFux1RRMa4DFL6xGfrhuVGP(xXpoQNi3MQj8Qf1)yBriQxHtFwO(za7s91gupIa2j7R0CSsaydrUM8rXcaB0CrM6JXMuN7jQq9yDQxXibfO5yLaWgICn5NbyJlIqzhnhRea2qKRjVGLMUjgj19QwaDncV1KGGLMUjgj19AOg)3oM)F01dUIWgBQEfS0uW1edm0lzrZXkbGne5AYRdC92TPAcVAb01qgH3Asajyx62TPAcVHA8F7GMJvcaBiY1Khjyx62TPAcVAb01i8wtcib7s3Unvt4nuJ)Bh0CSsaydrUM8LDcHB3MQj8QfqxJcJ3bEglOdC92TPAcVbxtmWqVepRyNtgH3Asajyx62TPAcVHA8F7itgfgVd8mwajyx62TPAcVbxtmWqVepRyNl8wtcib7s3Unvt4nuJ)Bh0CSsaydrUM8pOEbstiAowjaSHixt()IXJR(J7vTa6AiJWBnjWivTbBQgQX)TJmz(p66bgPQnyt1Wt0mzuy8oWZybgPQnyt1GRjgyOSNvS0CSsaydrUM8)6q1fbWM0cORHmcV1KaJu1gSPAOg)3oYK5)ORhyKQ2GnvdprP5yLaWgICn51bU(xmEOfqxdzeERjbgPQnyt1qn(VDKjZ)rxpWivTbBQgEIMjJcJ3bEglWivTbBQgCnXadL9SILMJvcaBiY1KNnvrIJ3RI3vlGUgYi8wtcmsvBWMQHA8F7itM)JUEGrQAd2un8entgfgVd8mwGrQAd2un4AIbgk7zflnhRea2qKRjV7XUSsay7UaKOLXPQHXvlGUgwjaI7TwtGIYoR5AhfT7Ef2nvbfueyGDxWebXa2u2zLjdkA39kSBQckSmX89xoLDwrIMJvcaBiY1K39yxwjaSDxas0Y4u1Ga202RWUPk0C0CrM6j7Ewbq9c7MQq9SsayJ6J6ayhqEL6xasO5yLaWgkW4QbjyxkI2O1PfqxJWBnjGeSlfrB06c14)2bnhRea2qbgxY1KNrQAd2uvlGUgH3AsGrQAd2unuJ)BhZ1UWBnjGeSlD72unH3qn(VDmxHX7apJfqc2LUDBQMWBW1edm0lXZk25kmEh4zSasWU0TBt1eEdUMyGHYo(SYKHmcV1KasWU0TBt1eEd14)2rKO5yLaWgkW4sUM8lqBFaJBINs8vWstAb01i8wtclqBFaJBINs8vWstHA8F7GMJvcaBOaJl5AYRVCQxebSkcTa6ACv3veb(VDokA39kSBQckOiWa7UGjcIbSPxIjnhRea2qbgxY1KVStiOTpCeLMlYupzJTVs9kgju)Shtmt9K(4qc1JnQxi4APEHDtvqupqN6bc1dqupBupWqcBsGMJvcaBOaJl5AYVmX89)4qIwaDnA))ORhwMy(IECtn8entM)JUEGrQAd2un8ensZrr7UxHDtvqbfbgy3fmrqmGn9smP5yLaWgkW4sUM8DBQMW79Vms0cORr4TMe62unH37FzKeQX)TJ5OOD3RWUPkOGIadS7cMiigWMEjM0CSsaydfyCjxt(LjMV)YjTa6AeERjbgPQnyt1qn(VDqZXkbGnuGXLCn5veyGDxWebXa2enhRea2qbgxY1KFzI57)XHeTsyIb2KM4Ab01i8wtcmsvBWMQHA8F7GMJvcaBOaJl5AYRVCQxebSkcTsyIb2KM4Ab014QURic8FlnhRea2qbgxY1Kx3HrYfraRIqReMyGnPjonhnxKP(dWM2s9Vz3ufQpgQea2OEIMdGDa5vQF2dGeAowjaSHciGnT9kSBQIg9Lt9IiGvrOfqxdzeGkcGnLjZalb9Lt9IiGvreCnXad9IMj1itgH3AsGrQAd2unuJ)BhZhyjOVCQxebSkIGRjgyOx0UcJ3bEglWivTbBQgCnXadr()rxpWivTbBQggpowaylsZvy8oWZybgPQnyt1GRjgyOxI5CTtgH3Asajyx62TPAcVHA8F7itgH3Asajyx62TPAcVHA8F7yUcJ3bEglGeSlD72unH3GRjgyOxINvSrIMJvcaBOacytBVc7MQqUM8msvBWMQAb01i8wtcmsvBWMQHA8F7yUcJ3bEglSmX89)4qsW1edmu2XoNmcV1KasWU0TBt1eEd14)2bnhRea2qbeWM2Ef2nvHCn5zKQ2Gnv1cORr4TMeyKQ2Gnvd14)2XCfgVd8mwyzI57)XHKGRjgyOSJDUcJ3bEglGeSlD72unH3GRjgyOx0epRyP5Im1p7cBZofQ)bvQNi3MQj8s9KUmsOEGo1)k(H6v4NDq9kgjupt9KDmsQJ6X6uVqOuprUnvtquFtrXZuxhuprYoHa1FiGvrq9adjLhbAowjaSHciGnT9kSBQc5AY3TPAcV3)YirlGUgH3AsOBt1eEV)LrsOg)3oMRDH3AsiXiPUlw)ke6TBt1euOg)3oM)F01djgj1DX6xHqVDBQMGcprNN4UiXHtVqwXMjdzeERjHeJK6Uy9RqO3UnvtqHA8F7is0CrM6N9BJs9NzFQxh7O(LDtL6XoQhHXg1ZJb1pdtCrbAowjaSHciGnT9kSBQc5AYJeSlfrB060cORr4TMeqc2LIOnADHA8F7yU2DmyClX1KapgOGc)yYlevMmogmUL4AsGhduayzpRyJenhRea2qbeWM2Ef2nvHCn5xG2(ag3epL4RGLM0cORr4TMewG2(ag3epL4RGLMc14)2XCT7yW4wIRjbEmqbf(XKxiQmzCmyClX1KapgOaWYEwXgjAowjaSHciGnT9kSBQc5AYx2je02hoIQfqxdReaX9wRjqrzhFokA39kSBQckOiWa7UGjcIbSPSJpNmcV1KqjIrXOoUDBQMGc14)2bnxKP(zhOs9cHs9J(F01P(F1XUs9kgjaBI6js2jeO(dbSkcQNNyGfO5yLaWgkGa202RWUPkKRj)cMiigWMUF8kAb01i8wtcLigfJ642TPAckuJ)BhZh9)ORhkrmkg1XTBt1eu4j68e3fjoCkBnKvSZjZ)rxpWivTbBQgEIsZfzQpgRt9rXie4VvlQ)bvQNizNqG6peWQiO(zacbQNSJrsDupwN6fcL6jYTPAckqZXkbGnuabSPTxHDtvixt(YoHWfraRIqlGUgH3AsiXiPUlw)ke6TBt1euOg)3oMR9)JUEiXiPUlw)ke6TBt1eu4jAMmjUlsC4u2Ai6zfPmziJWBnjKyKu3fRFfc92TPAckuJ)Bh0CSsaydfqaBA7vy3ufY1KFzI57)XHeTa6Auy8oWZyxxzLKjZ)rxpWivTbBQgEIsZXkbGnuabSPTxHDtvixtE9Lt9IiGvrOfqxJR6UIiW)T0CSsaydfqaBA7vy3ufY1KxWst3eJK6EvlGUgH3AsqWst3eJK6EnuJ)BhZ1()rxp4kcBSP6vWstbxtmWqVqwzYO9)JUEWve2yt1RGLMcUMyGHEr7)hD9aJu1gSPAy84ybGnYvy8oWZybgPQnyt1GRjgyOinxHX7apJfyKQ2GnvdUMyGHEj(SIuKO5yLaWgkGa202RWUPkKRjVUdJKlIawfHwaDncV1Kaqv9h3RHA8F7y()rxpauv)X9A4jknhRea2qbeWM2Ef2nvHCn5bQQ)4EvlGUgH3AsaOQ(J71qn(VDqZXkbGnuabSPTxHDtvixt(LjMV)YjTa6AeERjbgPQnyt1qn(VDmNvcG4ER1eOOSJphfT7Ef2nvbfwMy((lNYoonhRea2qbeWM2Ef2nvHCn5veyGDxWebXa2KwaDnSsae3BTMafLD85OOD3RWUPkOGIadS7cMiigWMYoonhRea2qbeWM2Ef2nvHCn5xWebXa209JxHMJvcaBOacytBVc7MQqUM86lN6fraRIqReMyGnPjUwaDnUQ7kIa)3sZXkbGnuabSPTxHDtvixtE9Lt9IiGvrOvctmWM0exlGUMeM4MQjHbajSPA2KfnxKP(z3omsO(dbSkcQhGOE8JJ6tyIBQMq96GDRlqZXkbGnuabSPTxHDtvixtEDhgjxebSkcTsyIb2KM4WdX1HaydsswXgxBILOtuXgYkwIsBGNzyNbSje8eJtrXoPdQpMupRea2O(fGeuGMdE4hHa2bphq6zzbGnYwhRlWZcqcc(gEqaBA7vy3uf4BijXHVHNA8F7ask8OCaPoadpKH6fGkcGnr9zYq9dSe0xo1lIawfrW1edme1)IgQFsnO(mzOEH3AsGrQAd2unuJ)Bhu)CQFGLG(YPEreWQicUMyGHO(xOETt9kmEh4zSaJu1gSPAW1edme1to1)F01dmsvBWMQHXJJfa2O(ir9ZPEfgVd8mwGrQAd2un4AIbgI6FH6Jj1pN61o1tgQx4TMeqc2LUDBQMWBOg)3oO(mzOEH3Asajyx62TPAcVHA8F7G6Nt9kmEh4zSasWU0TBt1eEdUMyGHO(xO(4zfl1hj4HvcaBWJ(YPEreWQiGcKKSGVHNA8F7ask8OCaPoadpcV1KaJu1gSPAOg)3oO(5uVcJ3bEglSmX89)4qsW1edme1Nn1hl1pN6jd1l8wtcib7s3Unvt4nuJ)BhWdRea2GhgPQnytvOajHOGVHNA8F7ask8OCaPoadpcV1KaJu1gSPAOg)3oO(5uVcJ3bEglSmX89)4qsW1edme1Nn1hl1pN6vy8oWZybKGDPB3MQj8gCnXadr9VOH6JNvSWdRea2GhgPQnytvOajjMW3Wtn(VDajfEuoGuhGHhH3AsOBt1eEV)LrsOg)3oO(5uV2PEH3AsiXiPUlw)ke6TBt1euOg)3oO(5u))rxpKyKu3fRFfc92TPAck8eL6Nt9jUlsC4e1)c1twXs9zYq9KH6fERjHeJK6Uy9RqO3UnvtqHA8F7G6Je8WkbGn4PBt1eEV)LrcuGKml4B4Pg)3oGKcpkhqQdWWJWBnjGeSlfrB06c14)2b1pN61o17yW4wIRjbEmqbf(XeQ)fQNOO(mzOEhdg3sCnjWJbkamQpBQFwXs9rcEyLaWg8GeSlfrB06GcKeYc(gEQX)TdiPWJYbK6am8i8wtclqBFaJBINs8vWstHA8F7G6Nt9AN6DmyClX1KapgOGc)yc1)c1tuuFMmuVJbJBjUMe4Xafag1Nn1pRyP(ibpSsaydEwG2(ag3epL4RGLMGcKKye8n8uJ)BhqsHhLdi1by4HvcG4ER1eOiQpBQpo1pN6rr7UxHDtvqbfbgy3fmrqmGnr9zt9XP(5upzOEH3AsOeXOyuh3UnvtqHA8F7aEyLaWg8u2je02hoIcfijAd8n8uJ)BhqsHhLdi1by4r4TMekrmkg1XTBt1euOg)3oO(5u)O)hD9qjIrXOoUDBQMGcprP(5uFI7Iehor9zRH6jRyP(5upzO()JUEGrQAd2un8efEyLaWg8SGjcIbSP7hVcuGKq0HVHNA8F7ask8OCaPoadpcV1KqIrsDxS(vi0B3MQjOqn(VDq9ZPETt9)hD9qIrsDxS(vi0B3MQjOWtuQptgQpXDrIdNO(S1q9e9SO(ir9zYq9KH6fERjHeJK6Uy9RqO3UnvtqHA8F7aEyLaWg8u2jeUicyveqbss8yHVHNA8F7ask8OCaPoadpkmEh4zSRRSsO(mzO()JUEGrQAd2un8efEyLaWg8SmX89)4qcuGKepo8n8uJ)BhqsHhLdi1by4XvDxre4)w4HvcaBWJ(YPEreWQiGcKK4zbFdp14)2bKu4r5asDagEeERjbblnDtmsQ71qn(VDq9ZPETt9)hD9GRiSXMQxblnfCnXadr9Vq9Kf1Njd1RDQ))ORhCfHn2u9kyPPGRjgyiQ)fQx7u))rxpWivTbBQggpowayJ6jN6vy8oWZybgPQnyt1GRjgyiQpsu)CQxHX7apJfyKQ2GnvdUMyGHO(xO(4ZI6Je1hj4HvcaBWJGLMUjgj19kuGKeNOGVHNA8F7ask8OCaPoadpcV1Kaqv9h3RHA8F7G6Nt9)hD9aqv9h3RHNOWdRea2GhDhgjxebSkcOajjEmHVHNA8F7ask8OCaPoadpcV1Kaqv9h3RHA8F7aEyLaWg8auv)X9kuGKeFwW3Wtn(VDajfEuoGuhGHhH3AsGrQAd2unuJ)Bhu)CQNvcG4ER1eOiQpBQpo1pN6rr7UxHDtvqHLjMV)YjQpBQpo8WkbGn4zzI57VCckqsItwW3Wtn(VDajfEuoGuhGHhwjaI7TwtGIO(SP(4u)CQhfT7Ef2nvbfueyGDxWebXa2e1Nn1hhEyLaWg8OiWa7UGjcIbSjOajjEmc(gEyLaWg8SGjcIbSP7hVc8uJ)BhqsHcKK4Ad8n8uJ)BhqsHhLdi1by4XvDxre4)w4HvcaBWJ(YPEreWQiGNeMyGnbpXHcKK4eD4B4Pg)3oGKcpkhqQdWWtctCt1KWaGe2uL6ZM6jl4HvcaBWJ(YPEreWQiGNeMyGnbpXHcKKSIf(gEsyIb2e8ehEyLaWg8O7Wi5IiGvrap14)2bKuOaf4HXf(gssC4B4Pg)3oGKcpkhqQdWWJWBnjGeSlfrB06c14)2b8WkbGn4bjyxkI2O1bfijzbFdp14)2bKu4r5asDagEeERjbgPQnyt1qn(VDq9ZPETt9cV1KasWU0TBt1eEd14)2b1pN6vy8oWZybKGDPB3MQj8gCnXadr9Vq9XZkwQFo1RW4DGNXcib7s3Unvt4n4AIbgI6ZM6JplQptgQNmuVWBnjGeSlD72unH3qn(VDq9rcEyLaWg8WivTbBQcfijef8n8uJ)BhqsHhLdi1by4r4TMewG2(ag3epL4RGLMc14)2b8WkbGn4zbA7dyCt8uIVcwAckqsIj8n8uJ)BhqsHhLdi1by4XvDxre4)wQFo1JI2DVc7MQGckcmWUlyIGyaBI6FH6Jj8WkbGn4rF5uVicyveqbsYSGVHhwjaSbpLDcbT9HJOWtn(VDajfkqsil4B4Pg)3oGKcpkhqQdWWJ2P()JUEyzI5l6Xn1WtuQptgQ))ORhyKQ2GnvdprP(ir9ZPEu0U7vy3ufuqrGb2Dbteedytu)luFmHhwjaSbpltmF)poKafijXi4B4Pg)3oGKcpkhqQdWWJWBnj0TPAcV3)YijuJ)Bhu)CQhfT7Ef2nvbfueyGDxWebXa2e1)c1ht4HvcaBWt3MQj8E)lJeOajrBGVHNA8F7ask8OCaPoadpcV1KaJu1gSPAOg)3oGhwjaSbpltmF)Ltqbscrh(gEyLaWg8OiWa7UGjcIbSj4Pg)3oGKcfijXJf(gEQX)TdiPWJYbK6am8i8wtcmsvBWMQHA8F7aEyLaWg8SmX89)4qc8KWedSj4jouGKepo8n8uJ)BhqsHhLdi1by4XvDxre4)w4HvcaBWJ(YPEreWQiGNeMyGnbpXHcKK4zbFdpjmXaBcEIdpSsaydE0DyKCreWQiGNA8F7askuGc8mQo)Sc8nKK4W3Wtn(VDa)WJYbK6am8WK91bKgytvK4496kcBSPAOg)3oGhwjaSbp)fJh7dsGcKKSGVHhwjaSbprXcaBWtn(VDajfkqsik4B4HvcaBWZmaBCrek7GNA8F7askuGKet4B4Pg)3oGKcpkhqQdWWJWBnjiyPPBIrsDVgQX)TdQFo1)F01dUIWgBQEfS0uW1edme1)c1Nf8WkbGn4rWst3eJK6EfkqsMf8n8uJ)BhqsHhLdi1by4HmuVWBnjGeSlD72unH3qn(VDapSsaydE0bUE72unHxOajHSGVHNA8F7ask8OCaPoadpcV1KasWU0TBt1eEd14)2b8WkbGn4bjyx62TPAcVqbssmc(gEQX)TdiPWJYbK6am8OW4DGNXc6axVDBQMWBW1edme1)c1hpRyP(5upzOEH3Asajyx62TPAcVHA8F7G6ZKH6vy8oWZybKGDPB3MQj8gCnXadr9Vq9XZkwQFo1l8wtcib7s3Unvt4nuJ)BhWdRea2GNYoHWTBt1eEHcKeTb(gEyLaWg88G6finHGNA8F7askuGKq0HVHNA8F7ask8OCaPoadpKH6fERjbgPQnyt1qn(VDq9zYq9)hD9aJu1gSPA4jk1Njd1RW4DGNXcmsvBWMQbxtmWquF2u)SIfEyLaWg88xmEC1FCVcfijXJf(gEQX)TdiPWJYbK6am8qgQx4TMeyKQ2Gnvd14)2b1Njd1)F01dmsvBWMQHNOWdRea2GNFDO6Iaytqbss84W3Wtn(VDajfEuoGuhGHhYq9cV1KaJu1gSPAOg)3oO(mzO()JUEGrQAd2un8eL6ZKH6vy8oWZybgPQnyt1GRjgyiQpBQFwXcpSsaydE0bU(xmEafijXZc(gEQX)TdiPWJYbK6am8qgQx4TMeyKQ2Gnvd14)2b1Njd1)F01dmsvBWMQHNOuFMmuVcJ3bEglWivTbBQgCnXadr9zt9Zkw4HvcaBWdBQIehVxfVluGKeNOGVHNA8F7ask8OCaPoadpSsae3BTMafr9zt9zr9ZPETt9OOD3RWUPkOGIadS7cMiigWMO(SP(SO(mzOEu0U7vy3ufuyzI57VCI6ZM6ZI6Je8WkbGn4X9yxwjaSDxasGNfGKRXPcpmUqbss8ycFdp14)2bKu4HvcaBWJ7XUSsay7UaKaplajxJtfEqaBA7vy3ufOaf4jQRkC6Zc8nKK4W3Wtn(VDajfkqsYc(gEQX)TdiPqbscrbFdp14)2bKuOajjMW3Wtn(VDajfkqsMf8n8WkbGn4rWst3eJK6EfEQX)TdiPqbsczbFdpSsaydE0bUE72unHx4Pg)3oGKcfijXi4B4HvcaBWtuSaWg8uJ)BhqsHcKeTb(gEyLaWg80TPAcV3)YibEQX)TdiPqbkqbkqbcba]] )


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
