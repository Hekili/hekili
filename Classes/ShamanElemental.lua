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
    } )

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
            
            spend = function () return -3 * ( min( 5, active_enemies ) ) end,
            spendType = 'maelstrom',

            nobuff = 'ascendance',
            bind = 'lava_beam',

            startsCombat = true,
            texture = 136015,
            
            handler = function ()
                removeBuff( 'master_of_the_elements' )
                removeBuff( 'stormkeeper' )
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
            
            spend = 75,
            spendType = "maelstrom",
            
            startsCombat = true,
            texture = 451165,
            
            handler = function ()
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
            
            spend = function () return -3 * ( min( 5, active_enemies ) ) end,
            spendType = 'maelstrom',

            buff = 'ascendance',
            bind = 'chain_lightning',

            startsCombat = true,
            texture = 236216,
            
            handler = function ()
                removeStack( 'stormkeeper' )
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
            end,
        },
        

        lightning_bolt = {
            id = 188196,
            cast = function () return buff.stormkeeper.up and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",
            
            spend = -6,
            spendType = "maelstrom",
            
            startsCombat = true,
            texture = 136048,
            
            handler = function ()
                removeStack( 'stormkeeper' )
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
            
            startsCombat = true,
            texture = 511726,
            
            handler = function ()
                -- applies ember_totem (210657)
                -- applies tailwind_totem (210660)
                -- applies resonance_totem (202188)
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

    spec:RegisterPack( "Elemental", 20180618.201500, [[dyuDCaqijs6rQuYMuP4tsazuseoLeOxPqnlkf3sIe7sf)sIAyukDmfYYKGEMIQAAsQ4AOISnjv6BkQsJtcW5KikRtcOmpfvUNkzFOchurvyHsIhQsPWevPu0fLivNuIiTskvVuLsvZuLsLBkbuTtjPFQOkYqLiILQsP0tPQPkH2RWFvYGPYHjwmOEmktgKldTzu1NPKrRiNwQxRs1Sr62k1Uf9BGHJkDCjsz5u8CvnDsxxbBxs57OIA8sevNxsvRxrvuZxrz)iogffdpKOyuTqBhva2w3rfWPWchvN5pk8A9CXWZvy3flm8PSXWx6uCJPk0WZvQNceOOy4FWGHHHFsvUFbw5YgHZhRwNgGhE0WaPIPEyGD5V3durBqYmcVw(7nRmmVukqyTYCna(MIF5sIbVTsd9Llj32LFs2sUkDkUXuf657nl8WdnvlPzahEirXWxOTJkGsX26wkJkaIRWclWSDEd)Zfzr1cRBHHhcFw4lo1pX1pXjeheYlduL44kS7IfsCaEItyAdsIJ2V(ehpWqCLof3yQcL48tYwYN44bgIRc)84eEUgaFtXWFlIR0l5iBqriIdg5bgK4yGnSOehmA15FiU5bJHC1N4sqwktIzZpqjoHPniFIdK06pe7ctBq(hUgKb2WIEXtL)oXUW0gK)HRbzGnSOJVkZdaqe7ctBq(hUgKb2WIo(QSmyTXufTbjX(TioFkC)jGsCgPHio4bEEeI4Ev0N4GrEGbjogydlkXbJwD(eNKqehxdwkCbQ2PfX1pXbbs8qSlmTb5F4Aqgydl64RYFkC)jGUEv0NyxyAdY)W1GmWgw0XxLvGI71wEfn1tSlmTb5F4Aqgydl64RY8Tbxif3yQcLyxyAdY)W1GmWgw0XxL5c0gKe7ctBq(hUgKb2WIo(QmsXnMQqxWu5vIDI9BrCLEjhzdkcrCyn0upXP9gjoDcjoHPadX1pXj1KMkWu8qSFlIRcfaGOdVsCm51oTioyCsQ1adXTBJbyEItNqI779avuGH4Eu1oTEIJhyioUgqjVEIdMcaq0HxpeNhrIdWvBq(exbcMcaq0HxxCrddtTazdXjjeXvGGPaaeD41L2BSaDioIDHPni)lykaarhE1MM)sfJfQNjuO60HltNRqonBM2BKdBpCYwBj2VfXvsZsHb2WIsCCbAdsIRFIJRb5rdMAluA9ehTZ7ieXPaIREWGH4kDkUXufQne3qsX)jogydlkXX5MsjomHiUFcyuA9e7ctBq(JVkZfOnij2VfXvstfnMbUkXb4joM86tCscrC9tCgK2cmfjo10wwOH4a8eNh5onmptCEKzq9qSlmTb5p(QmN7eA9tOyi2fM2G8hFvwbkUxB5v0uVnn)f8ap)XGpiLKHlfO4(yWT05pxHe7ctBq(JVkZ3gCHuCJPkuIDHPni)XxLFfy2lKIBmvHsSlmTb5p(Q8WJRwX9tSlmTb5p(QmmfaGw8dM6TP5VkvvOyQh5zycjjdpykWueA2m4bE(J8mmHKKHNbUZMXaakeGZ5rEgMqsYWJb3sNphCYwIDHPni)XxLHrZJM7DAztZFvQQqXupYZWessgEWuGPi0SzWd88h5zycjjdpdCj2fM2G8hFv2mKlHPnix0(vBszJxcaTP5VeM21WfM4UXNJcVPepxKsxQySq9pSjPZfTTM0StlokC2SNlsPlvmwO(hQutwWOS5OWcsSlmTb5p(QSzixctBqUO9R2KYgV(oTO4sfJfQe7e73I4kWhOAtCQySqL4eM2GK44AAGP16joA)kXUW0gK)ra41RaZ(oICrdXUW0gK)ra44RYYZWessgsSlmTb5Feao(QmTlTHgATfRTSuGIBIDHPni)JaWXxL5PYgx)eGD3MM)65Iu6sfJfQ)HnjDUOT1KMDAnxDSrfJfQRM)YG8g8NeyksSlmTb5Feao(QmkgDQ0gK7iX(TiU5PKwpXXKxjUBNutiUkdMxjoqsC6KbrItfJfQpX18exRex)eNKexNVkPEi2fM2G8pcahFvMk1Kf8G5vBA(liGE4PYgx)eGD)yWT05ZbtEDP9gVbEGN)qLAY6hmw4zG7npxKsxQySq9pSjPZfTTM0StR5QdXUW0gK)ra44RYif3yQcDbtLxTP5VEUiLUuXyH6FytsNlABnPzNwZvhIDHPni)JaWXxLPsnzbJYMyxyAdY)iaC8vz2K05I2wtA2PfXUW0gK)ra44RYuPMSGhmVAZguRtRRre7ctBq(hbGJVkZtLnU(ja7UnBqToTUgzJkgluxn)Lb5n4pjWuKyNy)weNVtlksCffJfQe38GPnijUsIPbMwRN4UD9Re7ctBq(NVtlkUuXyH6fpv246NaS7208xLQ2S7DAnBgeqp8uzJRFcWUFm4w68N7YIbrSlmTb5F(oTO4sfJfQJVklpdtijzOnn)vj0EJCCvxBNndEGN)atbai6WRNbUf8ggaqHaCopuPMSGhmVEm4w685WwIDHPni)Z3PffxQySqD8vzKIBmvHUGPYRe7ctBq(NVtlkUuXyH64RYnd5hm1tSFlI72JixIZF7joEGH4OIXcjoGH4EaijobcI44Sud)dXUW0gK)570IIlvmwOo(Q8RaZ(oICrJnn)LrAOfwdt9iqq)HbgsDU5pBMrAOfwdt9iqq)Pto4KTe7ctBq(NVtlkUuXyH64RY0U0gAO1wS2YsbkUTP5VmsdTWAyQhbc6pmWqQZn)zZmsdTWAyQhbc6pDYbNSLyxyAdY)8DArXLkgluhFvM3aED9ta2DBA(l4bE(tZq(bt9NbU3SfK(QbS54QqBj2fM2G8pFNwuCPIXc1XxLrXOtRFcWUtSlmTb5F(oTO4sfJfQJVktLAYcEW8Qnn)feqp8uzJRFcWUFm4w685GjVU0EJ3ucgaqHaCoxguy6SzWd88h5zycjjdpdCliXUW0gK)570IIlvmwOo(Qmpv246NaS7208xBbPVAaBoUk0wBuXyH6Q5VmiVb)jbMIe7ctBq(NVtlkUuXyH64RYkqX9AlVIM6TP5VGh45pg8bPKmCPaf3hdULo)5gz7SzLaEGN)yWhKsYWLcuCFm4w68NReWd88h5zycjjdpqdgrBqoMbauiaNZJ8mmHKKHhdULo)cEddaOqaoNh5zycjjdpgClD(ZnItfKyxyAdY)8DArXLkgluhFvMk1KfmkBBA(lHPDnCHjUB85y0npxKsxQySq9puPMSGrzZXiIDHPni)Z3PffxQySqD8vz2K05I2wtA2PLnn)LW0UgUWe3n(Cm6MNlsPlvmwO(h2K05I2wtA2PfhJi2fM2G8pFNwuCPIXc1XxLPT1KMDATGbuLyxyAdY)8DArXLkgluhFvMNkBC9ta2DB2GADADnYgvmwOUA(ldYBWFsGPiXUW0gK)570IIlvmwOo(Qmpv246NaS72Sb1606AKnn)1gud3yQhO(vjzih1n8CwmzNwF4dVmOtat499EGkAdYBdJWRe3Tjw7dpTF9JIH)70IIlvmwOgfJQJIIHhtbMIqrLWZmTIMwcFPsCAZU3PfXnBgXbb0dpv246NaS7hdULoFIBUlIZIbfEHPnidppv246NaS7HgvlmkgEmfykcfvcpZ0kAAj8LG40EJehhxexDTL4MnJ4Gh45pWuaaIo86zGlXvqI7gIJbauiaNZdvQjl4bZRhdULoFIJdIZ2WlmTbz4LNHjKKmm0O68JIHxyAdYWJuCJPk0fmvEn8ykWuekQeAuTorXWlmTbz4BgYpyQp8ykWuekQeAuLtrXWJPatrOOs4zMwrtlH3in0cRHPEeiO)WadPsCZrCZN4MnJ4msdTWAyQhbc6pDsCCqCCY2WlmTbz4Ffy23rKlAcnQw3Oy4XuGPiuuj8mtROPLWBKgAH1Wupce0FyGHujU5iU5tCZMrCgPHwynm1Jab9NojooioozB4fM2Gm80U0gAO1wS2YsbkUdnQoVrXWJPatrOOs4zMwrtlHhEGN)0mKFWu)zGlXDdXTfK(QbSjooUiUcTn8ctBqgEEd411pby3dnQwarXWlmTbz4rXOtRFcWUhEmfykcfvcnQwYIIHhtbMIqrLWZmTIMwcpeqp8uzJRFcWUFm4w68jooioM86s7nsC3qCLG4yaafcW5CzqHPe3Szeh8ap)rEgMqsYWZaxIRGHxyAdYWtLAYcEW8AOr1r2gfdpMcmfHIkHxyAdYWZtLnU(ja7E4zMwrtlHVee3wq6RgWM444I4k0wIRGe3nexjiodYBWFsGPiXvWWRIXc1vZhEdYBWFsGPyOr1rJIIHhtbMIqrLWZmTIMwcp8ap)XGpiLKHlfO4(yWT05tCZrCJSL4MnJ4kbXbpWZFm4dsjz4sbkUpgClD(e3Cexjio4bE(J8mmHKKHhObJOnijUXehdaOqaoNh5zycjjdpgClD(exbjUBiogaqHaCopYZWessgEm4w68jU5iUrCI4ky4fM2Gm8kqX9AlVIM6dnQoQWOy4XuGPiuuj8mtROPLWlmTRHlmXDJpXXbXnI4UH4EUiLUuXyH6FOsnzbJYM44G4gfEHPnidpvQjlyu2Hgvhn)Oy4XuGPiuuj8mtROPLWlmTRHlmXDJpXXbXnI4UH4EUiLUuXyH6FytsNlABnPzNwehhe3OWlmTbz4ztsNlABnPzNwHgvhvNOy4fM2Gm802AsZoTwWaQgEmfykcfvcnQoItrXWJPatrOOs4fM2Gm88uzJRFcWUhEMPv00s4niVb)jbMIHFdQ1Pv4hfEvmwOUA(WBqEd(tcmfdnQoQUrXWVb160k8JcpMcmfHIkHxyAdYWZtLnU(ja7E4zMwrtlHxfJfQhO(vjziXXbXv3qdn8caJIr1rrXWlmTbz4Ffy23rKlAcpMcmfHIkHgvlmkgEHPnidV8mmHKKHHhtbMIqrLqJQZpkgEHPnidpTlTHgATfRTSuGI7WJPatrOOsOr16efdpMcmfHIkHxyAdYWZtLnU(ja7E4zMwrtlHVee3ZfP0Lkglu)dBs6CrBRjn70I4MJ4QdXvqI7gIReeNb5n4pjWuK4ky4vXyH6Q5dVb5n4pjWum0OkNIIHxyAdYWJIrNkTb5ogEmfykcfvcnQw3Oy4XuGPiuuj8mtROPLWdb0dpv246NaS7hdULoFIJdIJjVU0EJe3neh8ap)Hk1K1pySWZaxI7gI75Iu6sfJfQ)HnjDUOT1KMDArCZrC1j8ctBqgEQutwWdMxdnQoVrXWJPatrOOs4zMwrtlH)5Iu6sfJfQ)HnjDUOT1KMDArCZrC1j8ctBqgEKIBmvHUGPYRHgvlGOy4fM2Gm8uPMSGrzhEmfykcfvcnQwYIIHxyAdYWZMKox02AsZoTcpMcmfHIkHgvhzBum8BqToTc)OWlmTbz4PsnzbpyEn8ykWuekQeAuD0OOy4XuGPiuuj8ctBqgEEQSX1pby3dpZ0kAAj8gK3G)KatXWVb160k8JcVkgluxnF4niVb)jbMIHgA4HqEzGQrXO6OOy4XuGPiuahEMPv00s4vXyH6zcfQoD4YuIBoIRqorCZMrCAVrIJdIZ2dNS12WlmTbz4HPaaeD41qJQfgfdVW0gKHNlqBqgEmfykcfvcnQo)Oy4fM2Gm8CUtO1pHIj8ykWuekQeAuTorXWJPatrOOs4zMwrtlHhEGN)yWhKsYWLcuCFm4w68jU5iUcdVW0gKHxbkUxB5v0uFOrvoffdVW0gKHNVn4cP4gtvOHhtbMIqrLqJQ1nkgEHPnid)RaZEHuCJPk0WJPatrOOsOr15nkgEHPnid)WJRwX9hEmfykcfvcnQwarXWJPatrOOs4zMwrtlHVujovOyQh5zycjjdpykWueI4MnJ4Gh45pYZWessgEg4sCZMrCmaGcb4CEKNHjKKm8yWT05tCCqCCY2WlmTbz4HPaa0IFWuFOr1swum8ykWuekQeEMPv00s4lvItfkM6rEgMqsYWdMcmfHiUzZio4bE(J8mmHKKHNbUHxyAdYWdJMhn370k0O6iBJIHhtbMIqrLWlmTbz4nd5syAdYfTFn8mtROPLWlmTRHlmXDJpXXbXviXDdXvcI75Iu6sfJfQ)HnjDUOT1KMDArCCqCfsCZMrCpxKsxQySq9puPMSGrztCCqCfsCfm80(1vkBm8cadnQoAuum8ykWuekQeEHPnidVzixctBqUO9RHN2VUszJH)70IIlvmwOgAOHNRbzGnSOrXO6OOy4XuGPiuuj0OAHrXWJPatrOOsOr15hfdpMcmfHIkHgvRtum8ykWuekQeAuLtrXWlmTbz4vGI71wEfn1hEmfykcfvcnQw3Oy4fM2Gm88Tbxif3yQcn8ykWuekQeAuDEJIHxyAdYWZfOnidpMcmfHIkHgvlGOy4fM2Gm8if3yQcDbtLxdpMcmfHIkHgAOHgAea]] )

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
