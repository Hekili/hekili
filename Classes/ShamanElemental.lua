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

    spec:RegisterPack( "Elemental", 20180806.1624, [[dGejOaqiQu8iPG2evL(esOmkKGofsGxHenlQKULus0UK4xGWWqrDmrQLrLQNrLqttkvUgvkTnQe9nQeyCsj15qcvRtkq08KcDpK0(OQ4Gsjjlee9qPaQMOusWfrczJsbuoPuawPi5LsbsZukq5MsjP2ji5NsbedvkG0tL0uLIUQuGQZkLeAVk(ROgmjhMYIrPhtQjdQlRAZi1NPIrlItR0RrrMnIBlv7w43adhfoUuQA5O65qnDIRtv2oi13LsmEQe05Lsz9sbcZNQQ9d5j90CQWM8bk3zoDRzU1m7Ys6w7E7s7(uL2y8PYW0mzoFQH1)uPiY7peJmvgwBeGbpnNkg4X1FQjIWa3GeciCwjXJTObDiWB3JyYccn3OfiWBxdblbWcblT1kHp0qWGdOxYXq0Cp390q00905AI1TitrK3FigPG3UEQSElrAaXWovyt(aL7mNU1m3AMDzjDRDVDPtpvmJRhOC3LUpv4J1tTzYIrQfJugsbFAZJiifdtZK5CKcqJuMwwqGuKflyKIgWrkkI8(dXiivnX6wGrkAahPGKUvvMkdoGEjFQnePOix41EYHrk2td4hP0GoRjif7D2axqQwLwFgcgPcq0ktmEN2JGuMwwqGrkqqARGszAzbbUWGFnOZAcvAIHzcLY0YccCHb)AqN1ekPcbnaaJszAzbbUWGFnOZAcLuHW8C6petwqGs1qKQggdCcqqkUTWifRhn9HrkSycgPypnGFKsd6SMGuS3zdmszbmsXG)wjdGiB4GulgPGbXlOuMwwqGlm4xd6SMqjviWHXaNaKmwmbJszAzbbUWGFnOZAcLuHqaY75UHLZBdLY0YccCHb)AqN1ekPcb9YF(K3FigbLY0YccCHb)AqN1ekPcbdGSGaLY0YccCHb)AqN1ekPcXjV)qmsMLyybLcLQHiff5cV2tomsDOpVnKs2(rkj5iLPfahPwmszqBlXyjVGs1qKcscaat8WcsPnSSHdsX(ed6fWrQ(Y5aogPKKJu4T7rmbWrk8fzdhmsrd4ifdoWf2gsXsaayIhwkiv9hPamKfeyKIIXsaayIhwYmox)qOyUIuwaJuumwcaat8Wsw2(PyfKcLY0Yccmvwcaat8WIRlnvX4oxkj3issHHwA0D363VS97dZf3YmZOunePAarRud6SMGumaYccKAXifd(Pp)HSgH0gsr2GPdJucaPAd4XrkkI8(dXiUIuEb5ymsPbDwtqQwwcbPEaJu4eaxiTHszAzbbMsQqWailiqPAis1ac5CUhdbPa0iL2WcgPSagPwmsXpznwYrkHVooNJuaAKQEgjEniqQ618lfuktlliWusfIw2aoJtUXrPmTSGatjvieG8EUBy582CDPPY6rtx4hdcl0pla59c)DBdCJUJszAzbbMsQqqV8Np59hIrqPmTSGatjviWcG3ZN8(dXiOuMwwqGPKke34ss(K3FigX1LMQgaiWGwIc9YF(K3FigPWF32a3yA3z2x3ig5HuWcG3ZN8(dXiLhgl5W(9RbacmOLOGfaVNp59hIrk83TnWnM2DM9vmYdPGfaVNp59hIrkpmwYHrPmTSGatjvi8WpVY7yuktlliWusfcwcaaNP94T56st1nIrEifdRFaBH(Lhgl5W(9Z6rtxmS(bSf6x8y43VgaiWGwIIH1pGTq)c)DBdSpULzuktlliWusfc2ZXNZ0goUU0uDJyKhsXW6hWwOF5HXsoSF)SE00fdRFaBH(fpgOuMwwqGPKkeCViBAzbrMSyX1W6NQbURlnvtll0p)499yFC3xkeZ4eswmUZfCrNyBKjRtIeB44J7(9JzCcjlg35cUqmOTm7TUpUtbOuMwwqGPKkeCViBAzbrMSyX1W6NkEdhYZIXDUGsHs1qKQv7rKfPeJ7CbPmTSGaPyWxaFL2qkYIfuktlliWfdCQybW7m9Z4CuktlliWfdCkPcHH1pGTqFxxAQIrEifSa498jV)qms5HXsoSVAaGadAjkybW75tE)HyKc)DBdCJPDNzF1aabg0suWcG3ZN8(dXif(72gyFs7w)(DJyKhsblaEpFY7peJuEySKdJszAzbbUyGtjviiB79w4C3C6wwaY7OuMwwqGlg4usfcAI1FgNa0m56stfZ4eswmUZfCrNyBKjRtIeB40y7CvmUZL8stLFA(Xjgl5OunePAfbEum(rkcaW0goiLjiLfiLXc6ByYcIcs1kEms1Ykjifob4rGphJuTb8qkTfiL2WcsbcsBiffzCjbPQjantifShFdhKQvboszbms1ITcsrd4ifob4rGphPyWbACbPAMSyKIbXAdlTros1cGZegPObCKQrQiLlrkX4oxWfKcspbPypszTy8JusIjivBapkgHGuShPCSolzdhKce6JuDa)LsbLY0YccCXaNsQqCJljzCcqZKRln13EVLbJdxUobCCgqNLKND43Km2lGpFdhuktlliWfdCkPcXnUK0EpJP76st9T3BzW4WLRtahNb0zj5zh(njJ9c4Z3WXxwpA6Y1jGJZa6SK8Sd)MKXEb85B4u8y43VBE79wgmoC56eWXzaDwsE2HFtYyVa(8nCqPAis1ajiTHuAdlivdMbTHuq6XXcsbcKss4)iLyCNlyKAPrQvqQfJuwGuBGflKckLPLfe4IboLuHGyqBzwpowCDPPsHSE00fIbTLXECNx8y43pRhnDXW6hWwOFXJbf4lMXjKSyCNl4IoX2itwNej2WPX2HszAzbbUyGtjvio59hIrYSedlUU0uXmoHKfJ7Cbx0j2gzY6KiXgon2ouktlliWfdCkPcbXG2YS36OuMwwqGlg4usfcDITrMSojsSHdkLPLfe4IboLuHGyqBzwpowCTdGEdhQPrPmTSGaxmWPKke0eR)mobOzY1oa6nCOM2vX4oxYlnv(P5hNySKJszAzbbUyGtjviO5aSKXjantU2bqVHd10OuOunePQB4qos104oxqQwLwwqGunq5lGVsBivd2IfuktlliWf8goKNfJ7CHknX6pJtaAMCDPP6gz1mTHJF)WaPqtS(Z4eGMPc)DBdCJuD0WOuMwwqGl4nCiplg35cLuHWW6hWwOVRlnvku2(9HQlz2VFwpA6clbaGjEyP4XGc8vdaeyqlrHyqBzwpowk83TnW(WSVUrmYdPGfaVNp59hIrkpmwYHrPmTSGaxWB4qEwmUZfkPcHH1pGTqFxxAQuOS97dvxYSF)SE00fwcaat8WsXJbf4RgaiWGwIcXG2YSECSu4VBBG9HzF1aabg0suWcG3ZN8(dXif(72g4gPM2DMrPAis1kackMGuE4Juue59hIrqkijgwqQLgPAd4HuAGhbgP0gwqkdPA1gwohPa0iLKCKIIiV)qWi17maTC(HrkkY4scsvtaAMqQnWYn4ckLPLfe4cEdhYZIXDUqjvio59hIrYSedlUU0ufJ8qkDdlNNb0zj55tE)HGlpmwYH9L1JMU0nSCEgqNLKNp59hcU4XW3UDcw4GEJUKz)(DJyKhsPBy58mGoljpFY7peC5HXsomkvdrQg0FgivTbfPObCKIyCNJuaosHbGaPmyyKQfd6JlOuMwwqGl4nCiplg35cLuHalaENPFgN76stLBlC(q)qkgmmUObEH0Ol63p3w48H(HumyyCzdFClZOuMwwqGl4nCiplg35cLuHGST3BHZDZPBzbiV76stLBlC(q)qkgmmUObEH0Ol63p3w48H(HumyyCzdFClZOunePAWXhPAd4XrkgCGgPypnGFKsByzdhKIImUKGu1eGMjKYCSnkOuMwwqGl4nCiplg35cLuH4gxsAVNX0DDPPY6rtxUobCCgqNLKND43Km2lGpFdNIhduQgIun44JusYrk4Z6rtJuSNgWpsPnSSHdsrrgxsqQAcqZeszo2gfuktlliWf8goKNfJ7CHsQqqwNej2WjZciIRlnv4Z6rtxUlKbaF48jV)qWfpg(2TtWch09HQlz2x3W6rtxmS(bSf6x8yGs1qKQbqJumay8YsURiLh(iffzCjbPQjantivlRKGuTAdlNJuaAKssosrrK3Fi4ckLPLfe4cEdhYZIXDUqjviUXLKmobOzY1LMQyKhsPBy58mGoljpFY7peC5HXsoSVuiRhnDPBy58mGoljpFY7peCXJHF)D7eSWbDFOsXDNc873nIrEiLUHLZZa6SK88jV)qWLhgl5WOuMwwqGl4nCiplg35cLuHGyqBzwpowCDPPQbacmOLiZVPf)(z9OPlgw)a2c9lEmqPmTSGaxWB4qEwmUZfkPcbnX6pJtaAMCvmUZL8stLFA(Xjgl5OuMwwqGl4nCiplg35cLuHqaY75UHLZBZ1LMkRhnDHFmiSq)SaK3l83TnWn6s)(PqwpA6c)yqyH(zbiVx4VBBGBKcz9OPlgw)a2c9lWECtwqqPgaiWGwIIH1pGTq)c)DBdmf4RgaiWGwIIH1pGTq)c)DBdCJPDlfGszAzbbUG3WH8SyCNlusfcAoalzCcqZKRlnvwpA6YQpThVTIhduktlliWf8goKNfJ7CHsQqS6t7XBdLY0YccCbVHd5zX4oxOKkeedAlZER76st10Yc9ZpEFp2N0(IzCcjlg35cUqmOTm7TUpPrPmTSGaxWB4qEwmUZfkPcHoX2itwNej2WX1LMQPLf6NF8(ESpP9fZ4eswmUZfCrNyBKjRtIeB44tAuktlliWf8goKNfJ7CHsQqqwNej2WjZcickLPLfe4cEdhYZIXDUqjviOjw)zCcqZKRDa0B4qnTRIXDUKxAQ8tZpoXyjhLY0YccCbVHd5zX4oxOKke0eR)mobOzY1oa6nCOM21LMAha97pKc8Ifl03hxIs1qKQbghGfKQMa0mHulgPaECKQdG(9hcsrVeY5fuktlliWf8goKNfJ7CHsQqqZbyjJtaAMCTdGEdhQPNk0NJxqmq5oZPBnZUa3BDjDRzU1tTfJhB4GNAdOZaWLdJuTdPmTSGaPilwWfuQPAEscGp1629iMSGObo3OfKQv4qJNkzXcEAov8goKNfJ7CzAoqLEAo1hgl5WdKtvZx581MQBqkz1mTHds53psbdKcnX6pJtaAMk83TnWivJurkhn8unTSGyQ0eR)mobOzAKbk3NMt9HXso8a5u18voFTPsHiLS9Ju(qfPCjZiLF)ifRhnDHLaaWepSu8yGuuas5lsPbacmOLOqmOTmRhhlf(72gyKYhKIzKYxKYniLyKhsblaEpFY7peJuEySKdpvtlliMQH1pGTq)rgOCXP5uFySKdpqovnFLZxBQuisjB)iLpurkxYms53psX6rtxyjaamXdlfpgiffGu(IuAaGadAjkedAlZ6XXsH)UTbgP8bPygP8fP0aabg0suWcG3ZN8(dXif(72gyKQrQivA3zEQMwwqmvdRFaBH(Jmq1UP5uFySKdpqovnFLZxBQIrEiLUHLZZa6SK88jV)qWLhgl5WiLVifRhnDPBy58mGoljpFY7peCXJbs5ls1TtWch0rQgrkxYms53ps5gKsmYdP0nSCEgqNLKNp59hcU8WyjhEQMwwqm1tE)HyKmlXWYiduUDAo1hgl5WdKtvZx581Mk3w48H(HumyyCrd8cbPAePCrKYVFKIBlC(q)qkgmmUSbs5ds5wMNQPLfetflaENPFgNpYaLlNMt9HXso8a5u18voFTPYTfoFOFifdggx0aVqqQgrkxeP87hP42cNp0pKIbdJlBGu(GuUL5PAAzbXujB79w4C3C6wwaY7Jmq5cMMt9HXso8a5u18voFTPY6rtxUobCCgqNLKND43Km2lGpFdNIhJPAAzbXuVXLK27zm9rgOA90CQpmwYHhiNQMVY5Rnv4Z6rtxUlKbaF48jV)qWfpgiLViv3oblCqhP8Hks5sMrkFrk3GuSE00fdRFaBH(fpgt10YcIPswNej2WjZciYiduu8P5uFySKdpqovnFLZxBQIrEiLUHLZZa6SK88jV)qWLhgl5WiLViffIuSE00LUHLZZa6SK88jV)qWfpgiLF)iv3oblCqhP8HksrXDhPOaKYVFKYniLyKhsPBy58mGoljpFY7peC5HXso8unTSGyQ34ssgNa0mnYavAMNMt9HXso8a5u18voFTPQbacmOLiZVPfKYVFKI1JMUyy9dyl0V4XyQMwwqmvIbTLz94yzKbQ0PNMt9HXso8a5u18voFTPYpn)4eJL8PAAzbXuPjw)zCcqZ0iduPDFAo1hgl5WdKtvZx581MkRhnDHFmiSq)SaK3l83TnWivJiLlrk)(rkkePy9OPl8JbHf6NfG8EH)UTbgPAePOqKI1JMUyy9dyl0Va7XnzbbsrjsPbacmOLOyy9dyl0VWF32aJuuas5lsPbacmOLOyy9dyl0VWF32aJunIuPDlsrbt10YcIPka59C3WY5TnYavAxCAo1hgl5WdKtvZx581MkRhnDz1N2J3wXJXunTSGyQ0CawY4eGMPrgOs3UP5unTSGyQR(0E82M6dJLC4bYrgOs72P5uFySKdpqovnFLZxBQMwwOF(X77XiLpivAKYxKcZ4eswmUZfCHyqBz2BDKYhKk9unTSGyQedAlZERpYavAxonN6dJLC4bYPQ5RC(At10Yc9ZpEFpgP8bPsJu(IuygNqYIXDUGl6eBJmzDsKydhKYhKk9unTSGyQ6eBJmzDsKydNrgOs7cMMt10YcIPswNej2WjZciYuFySKdpqoYav6wpnN6dJLC4bYPQ5RC(AtLFA(Xjgl5t10YcIPstS(Z4eGMPP2bqVHZutpYavAk(0CQpmwYHhiNQMVY5Rn1oa63Fif4flwOps5ds5YPAAzbXuPjw)zCcqZ0u7aO3WzQPhzGYDMNMtTdGEdNPMEQMwwqmvAoalzCcqZ0uFySKdpqoYit1aFAoqLEAovtlliMkwa8ot)moFQpmwYHhihzGY9P5uFySKdpqovnFLZxBQIrEifSa498jV)qms5HXsoms5lsPbacmOLOGfaVNp59hIrk83TnWivJivA3zgP8fP0aabg0suWcG3ZN8(dXif(72gyKYhKkTBrk)(rk3GuIrEifSa498jV)qms5HXso8unTSGyQgw)a2c9hzGYfNMt10YcIPs227TW5U50TSaK3N6dJLC4bYrgOA30CQpmwYHhiNQMVY5RnvmJtizX4oxWfDITrMSojsSHds1is1UPAAzbXuPjw)zCcqZ0ufJ7CjV0tLFA(Xjgl5Jmq52P5uFySKdpqovnFLZxBQV9EldghUCDc44mGoljp7WVjzSxaF(got10YcIPEJljzCcqZ0iduUCAo1hgl5WdKtvZx581M6BV3YGXHlxNaoodOZsYZo8Bsg7fWNVHds5lsX6rtxUobCCgqNLKND43Km2lGpFdNIhdKYVFKYni1BV3YGXHlxNaoodOZsYZo8Bsg7fWNVHZunTSGyQ34ss79mM(iduUGP5uFySKdpqovnFLZxBQuisX6rtxig0wg7XDEXJbs53psX6rtxmS(bSf6x8yGuuas5lsHzCcjlg35cUOtSnYK1jrInCqQgrQ2nvtlliMkXG2YSECSmYavRNMt9HXso8a5u18voFTPIzCcjlg35cUOtSnYK1jrInCqQgrQ2nvtlliM6jV)qmsMLyyzKbkk(0CQMwwqmvIbTLzV1N6dJLC4bYrgOsZ80CQMwwqmvDITrMSojsSHZuFySKdpqoYav60tZP2bqVHZutpvtlliMkXG2YSECSm1hgl5WdKJmqL29P5uFySKdpqovnFLZxBQ8tZpoXyjFQMwwqmvAI1FgNa0mn1oa6nCMA6rgOs7ItZP2bqVHZutpvtlliMknhGLmobOzAQpmwYHhihzKPcFAZJitZbQ0tZP(WyjhEyNQMVY5RnvX4oxkj3issHHwqQgrk3Dls53psjB)iLpifZf3YmZt10YcIPYsaayIhwgzGY9P5unTSGyQmaYcIP(WyjhEGCKbkxCAovtlliMAlBaNXj34t9HXso8a5iduTBAo1hgl5WdKtvZx581MkRhnDHFmiSq)SaK3l83TnWivJiL7t10YcIPka59C3WY5TnYaLBNMt10YcIPsV8Np59hIrM6dJLC4bYrgOC50CQMwwqmvSa498jV)qmYuFySKdpqoYaLlyAo1hgl5WdKtvZx581MQgaiWGwIc9YF(K3FigPWF32aJunIuPDNzKYxKYniLyKhsblaEpFY7peJuEySKdJu(9JuAaGadAjkybW75tE)HyKc)DBdms1isL2DMrkFrkXipKcwa8E(K3FigP8WyjhEQMwwqm1BCjjFY7peJmYavRNMt10YcIP6HFEL3Xt9HXso8a5iduu8P5uFySKdpqovnFLZxBQUbPeJ8qkgw)a2c9lpmwYHrk)(rkwpA6IH1pGTq)IhdKYVFKsdaeyqlrXW6hWwOFH)UTbgP8bPClZt10YcIPYsaa4mThVTrgOsZ80CQpmwYHhiNQMVY5Rnv3GuIrEifdRFaBH(Lhgl5WiLF)ifRhnDXW6hWwOFXJXunTSGyQSNJpNPnCgzGkD6P5uFySKdpqovnFLZxBQMwwOF(X77XiLpiL7iLViffIuygNqYIXDUGl6eBJmzDsKydhKYhKYDKYVFKcZ4eswmUZfCHyqBz2BDKYhKYDKIcMQPLfetL7fztlliYKfltLSyjhw)t1aFKbQ0UpnN6dJLC4bYPAAzbXu5Er20YcImzXYujlwYH1)uXB4qEwmUZLrgzQm4xd6SMmnhOspnN6dJLC4bYrgOCFAo1hgl5WdKJmq5ItZP(WyjhEGCKbQ2nnN6dJLC4bYrgOC70CQMwwqmvbiVN7gwoVTP(WyjhEGCKbkxonNQPLfetLE5pFY7peJm1hgl5WdKJmq5cMMt10YcIPYailiM6dJLC4bYrgOA90CQMwwqm1tE)HyKmlXWYuFySKdpqoYiJmYiZaa]] )

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
