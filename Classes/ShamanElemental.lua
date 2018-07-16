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
                removeBuff( "lava_surge" )
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

    spec:RegisterPack( "Elemental", 20180715.2325, [[daKeJaqicHhriIAtujnkfuoLcQELc1SOcUfvIk7sOFrvzyekhJk1Yiu9maLMMOIUgGQTrLW3OsKXjQqNJquRJqezEIkDpa2hH0bjeHfQqEiHiXejePCrQevDscrsRuu1mPsuStfyOeIu9ubtLQQ9k5VszWaDyulgHhJ0Kv0LvTzc(mvz0iYPv61uHMnOBlv7MYVHmCQOJlQGLt0ZHA6KUUOSDa57kiJNkrPZdOy(iQ9lYL7YFfMS(AG4I5ohfZLCd8O4aR4INtrUckW48vWjtDK9EfmU)k4YdF)MYWk4KbgiINL)kGrzs6RajvDIfj5ZN3QKYiIuu3hE7zqwxKrLSG6dVDQpciIWhHa7Ynpq(U5T29rHmg36Ozg8yFyAdtI7SfPoDks2LXLYPi7IkqKTqvKQvevyY6RbIlM7CumxYnWJIdSIlEofVcyNNwde3fIxH5X0k4N0ItGlobYjW5f4mOMaDYuhzVNarcjqMQlYsGWfR4eOasMaD5HVFtzycmqI7SHtGcizcCKGirScoLiHf(kWuDrgo6uEkQtWkabiJDmLNP6ImC0P8uuNG1Xa8jGqZuEMQlYWrNYtrDcwhdWhN51VPSUilLNP6ImC0P8uuNG1Xa8Hn2jMesByLvCkpt1fz4Ot5POobRJb4tr67ToJ1lbMuEMQlYWrNYtrDcwhdWNWkF7W3VPmmLNP6ImC0P8uuNG1Xa8HvKS3o89Bkdt5zQUidhDkpf1jyDmaFor6ISuEMQlYWrNYtrDcwhdW3HVFtzyJaYynLpLNP6Im8ya(iGi0eMH1uEMQlYWJb4ZjsxKLYZuDrgEmaFdT2SHjDwMYZuDrgEmaFksFV1zSEjW4WkaGitqikpgzSrFtr67r578A4CfpLNP6Im8ya(ew5Bh((nLHP8mvxKHhdWhwrYE7W3VPmmLNP6Im8ya(olvsTdF)MYqhwbauecordzrHv(2HVFtzyu(oVgox3IlMRIqz4nnIvKS3o89BkdJ3yc4NKjtri4enKfXks2Bh((nLHr578A4CDlUyUQm8MgXks2Bh((nLHXBmb8ZuEMQlYWJb4ld)2QVJt5zQUidpgGpcicnBczsGXHvaGiugEtJmMEBYg9XBmb8tYKjYeeImMEBYg9XmNKjtri4enKfzm92Kn6JY351WIcCXs5zQUidpgGp2OhRsg2Ome6WkaqekdVPrgtVnzJ(4nMa(jzYezccrgtVnzJ(yMtYKPieCIgYImMEBYg9r578AyrbUyP8mvxKHhdWNWkpbeHMoScaeHYWBAKX0Bt2OpEJjGFsMmrMGqKX0Bt2OpM5KmzkcbNOHSiJP3MSrFu(oVgwuGlwkpt1fz4Xa8rCj(shxZZHvaGiugEtJmMEBYg9XBmb8tYKjYeeImMEBYg9XmNP8mvxKHhdWNmZAmvxK1GlwDW4(bWO7WkaGP6c0B3EFpwuXDDyyNhcBkl9UIJus8An46rsT18evCYKXope2uw6DfhHmqCJ4CxuXhEkpt1fz4Xa8jZSgt1fzn4IvhmUFa418GVPS07AkFkFkVpFjqrc0tGIeI0Dzs5zQUidhz0bGvKS74VZlt5zQUidhz0hdWhJP3MSrVdRaaLH30iwrYE7W3VPmmEJjGF6kfHGt0qweRizVD473uggLVZRHZ1T4I5kfHGt0qweRizVD473uggLVZRHf1nWjtwekdVPrSIK92HVFtzy8gta)mLNP6ImCKrFmaFWnhY2zRZEDUPi99uEMQlYWrg9Xa8ja5(BysiQJoScaWope2uw6DfhPK41AW1JKAR5LBoDqzP312kaqEb5XKyc4t5zQUidhz0hdW3zPskhYyhFkpt1fz4iJ(ya(GmqCJitIvhwbadJitqiczG4got69yMtYKjYeeImMEBYg9XmNd3vSZdHnLLExXrkjETgC9iP2AE5MZuEMQlYWrg9Xa8D473ug2iGmwDyfaGDEiSPS07kosjXR1GRhj1wZl3CMYZuDrgoYOpgGpide3io3t5zQUidhz0hdWhLeVwdUEKuBnVuEMQlYWrg9Xa8bzG4grMeRo0raTMha3P8mvxKHJm6Jb4taY93WKquhDOJaAnpaUDyfaiVG8ysmb8P8mvxKHJm6Jb4tqIWAdtcrD0HocO18a4oLpL3NVeyynp4tGkl9UMaD5sGIey6TjB0NYZuDrgoIxZd(MYsVRaeGC)nmje1rhwbaIqxQJR5rM8ePrbi3FdtcrDmkFNxdNlap6mLNP6ImCeVMh8nLLExhdWhJP3MSrVdRaGHPB)IcWfIrMmrMGqKaIqtygwJzohURuecordzride3iYKynkFNxdlQyUkcLH30iwrYE7W3VPmmEJjGFMYZuDrgoIxZd(MYsVRJb4JX0Bt2O3HvaWW0TFrb4cXitMitqisarOjmdRXmNd3vkcbNOHSiKbIBezsSgLVZRHfvmxPieCIgYIyfj7TdF)MYWO8DEnCUaClUyP8P8mvxKHJ418GVPS07kGdF)MYWgbKXQdRaaLH30yNX6LnKqtj92HVFtXXBmb8txjYeeIDgRx2qcnL0Bh((nfhZC6ANpeRsupxxigzYIqz4nn2zSEzdj0usVD473uC8gta)mLNP6ImCeVMh8nLLExhdWhwrYUJ)oV0HvaGK3z7aDtJ8CIJuuMP5cSKjl5D2oq30ipN44AIcCXs5zQUidhXR5bFtzP31Xa8b3CiBNTo715MI03Dyfai5D2oq30ipN4ifLzAUalzYsENTd0nnYZjoUMOaxSuEMQlYWr8AEW3uw6DDmaFNLkPCiJD8oScaiYeeINscDCdj0usV5jpRnCMnVCnVyMZuEMQlYWr8AEW3uw6DDmaFW1JKAR51iqq1HvaW8ezccX7Y6eH)SD473uCmZPRD(qSkrDrb4cXCveezccrgtVnzJ(yMZuEMQlYWr8AEW3uw6DDmaFNLkPgMeI6OdRaaLH30yNX6LnKqtj92HVFtXXBmb8txhgrMGqSZy9YgsOPKE7W3VP4yMtYK78HyvI6IcqKfF4KjlcLH30yNX6LnKqtj92HVFtXXBmb8ZuEMQlYWr8AEW3uw6DDmaFqgiUrKjXQdRaakcbNOHSM8mvjtMitqiYy6TjB0hZCMYZuDrgoIxZd(MYsVRJb4taY93WKquhDyfaiVG8ysmb8P8mvxKHJ418GVPS076ya(uK(ERZy9sGXHvaarMGquEmYyJ(MI03JY351W56cYKhgrMGquEmYyJ(MI03JY351W5omImbHiJP3MSrFCMjzDr2ykcbNOHSiJP3MSrFu(oVgE4Usri4enKfzm92Kn6JY351W56g4dpLNP6ImCeVMh8nLLExhdWNGeH1gMeI6OdRaaImbH4sVqMeyIzot5zQUidhXR5bFtzP31Xa8T0lKjbMuEMQlYWr8AEW3uw6DDmaFqgiUrCU7WkaGP6c0B3EFpwu3UIDEiSPS07koczG4gX5UOUt5zQUidhXR5bFtzP31Xa8rjXR1GRhj1wZZHvaat1fO3U9(ESOUDf78qytzP3vCKsIxRbxpsQTMNOUt5zQUidhXR5bFtzP31Xa8bxpsQTMxJab1uEMQlYWr8AEW3uw6DDmaFcqU)gMeI6OdDeqR5bWTdRaa5fKhtIjGpLNP6ImCeVMh8nLLExhdWNaK7VHjHOo6qhb0AEaC7WkaOJa69BACUyLn6f1fP8mvxKHJ418GVPS076ya(eKiS2WKquhDOJaAnpaURaqxIxKvdexm35OyUKBGhfhyDlYvyiwAR5HRqf4mLeswHW2ZGSUitKIKf0eOiTdeUcWfR4YFfWR5bFtzP31YFnWD5Vc3yc4N1OkqLRE5YvqejqDPoUMxcKm5e4ePrbi3FdtcrDmkFNxdNaZfqc0JoRat1fzvqaY93WKquhlTgiE5Vc3yc4N1OkqLRE5YvyyjqD7pbkkGeOlelbsMCcKitqisarOjmdRXmNjWHNaDnbsri4enKfHmqCJitI1O8DEnCcu0eOyjqxtGIibQm8MgXks2Bh((nLHXBmb8ZkWuDrwfym92Kn6lTgaSL)kCJjGFwJQavU6LlxHHLa1T)eOOasGUqSeizYjqImbHibeHMWmSgZCMahEc01eifHGt0qweYaXnImjwJY351WjqrtGILaDnbsri4enKfXks2Bh((nLHr578A4eyUasGUfxSkWuDrwfym92Kn6lTgKZYFfUXeWpRrvGkx9YLRGYWBASZy9YgsOPKE7W3VP44nMa(zc01eirMGqSZy9YgsOPKE7W3VP4yMZeORjWoFiwLOEcm3eOlelbsMCcuejqLH30yNX6LnKqtj92HVFtXXBmb8ZkWuDrwfo89BkdBeqgRLwdaE5Vc3yc4N1OkqLRE5YvqY7SDGUPrEoXrkkZ0eyUjqGnbsMCcuY7SDGUPrEoXX1sGIMabUyvGP6ISkGvKS74VZllTg4IYFfUXeWpRrvGkx9YLRGK3z7aDtJ8CIJuuMPjWCtGaBcKm5eOK3z7aDtJ8CIJRLafnbcCXQat1fzvaU5q2oBD2RZnfPVxAnWLk)v4gta)SgvbQC1lxUcezccXtjHoUHeAkP38KN1goZMxUMxmZzfyQUiRcNLkPCiJD8LwdYXYFfUXeWpRrvGkx9YLRW8ezccX7Y6eH)SD473uCmZzc01eyNpeRsupbkkGeOlelb6AcuejqImbHiJP3MSrFmZzfyQUiRcW1JKAR51iqqT0AGix(RWnMa(znQcu5QxUCfugEtJDgRx2qcnL0Bh((nfhVXeWptGUMahwcKitqi2zSEzdj0usVD473uCmZzcKm5eyNpeRsupbkkGeOilEcC4jqYKtGIibQm8Mg7mwVSHeAkP3o89BkoEJjGFwbMQlYQWzPsQHjHOowAnWTyL)kCJjGFwJQavU6LlxbkcbNOHSM8mvtGKjNajYeeImMEBYg9XmNvGP6ISkazG4grMeRLwdC7U8xHBmb8ZAufOYvVC5kiVG8ysmb8vGP6ISkia5(BysiQJLwdClE5Vc3yc4N1OkqLRE5YvGitqikpgzSrFtr67r578A4eyUjqxKajtoboSeirMGquEmYyJ(MI03JY351WjWCtGdlbsKjiezm92Kn6JZmjRlYsGJtGuecordzrgtVnzJ(O8DEnCcC4jqxtGuecordzrgtVnzJ(O8DEnCcm3eOBGNahEfyQUiRcksFV1zSEjWuAnWnWw(RWnMa(znQcu5QxUCfiYeeIl9czsGjM5ScmvxKvbbjcRnmje1XsRbUZz5VcmvxKvHLEHmjWuHBmb8ZAuP1a3aV8xHBmb8ZAufOYvVC5kWuDb6TBVVhNafnb6ob6Ace78qytzP3vCeYaXnIZ9eOOjq3vGP6ISkazG4gX5EP1a3UO8xHBmb8ZAufOYvVC5kWuDb6TBVVhNafnb6ob6Ace78qytzP3vCKsIxRbxpsQTMxcu0eO7kWuDrwfOK41AW1JKAR5vAnWTlv(Rat1fzvaUEKuBnVgbcQv4gta)SgvAnWDow(RWnMa(znQcu5QxUCfKxqEmjMa(kWuDrwfeGC)nmje1Xk0raTMxfCxAnWTix(RWnMa(znQcu5QxUCfuw6DnoxSYg9jqrtGUOcmvxKvbbi3FdtcrDScDeqR5vb3LwdexSYFf6iGwZRcURat1fzvqqIWAdtcrDSc3yc4N1OslTcm6L)AG7YFfyQUiRcyfj7o(78YkCJjGFwJkTgiE5Vc3yc4N1OkqLRE5Yvqz4nnIvKS3o89BkdJ3yc4NjqxtGuecordzrSIK92HVFtzyu(oVgobMBc0T4ILaDnbsri4enKfXks2Bh((nLHr578A4eOOjq3apbsMCcuejqLH30iwrYE7W3VPmmEJjGFwbMQlYQaJP3MSrFP1aGT8xbMQlYQaCZHSD26SxNBksFVc3yc4N1OsRb5S8xHBmb8ZAufOYvVC5kGDEiSPS07kosjXR1GRhj1wZlbMBcmNvGP6ISkia5(BysiQJvqzP312kub5fKhtIjGV0AaWl)vGP6ISkCwQKYHm2XxHBmb8ZAuP1axu(RWnMa(znQcu5QxUCfgwcKitqiczG4got69yMZeizYjqImbHiJP3MSrFmZzcC4jqxtGyNhcBkl9UIJus8An46rsT18sG5MaZzfyQUiRcqgiUrKjXAP1axQ8xHBmb8ZAufOYvVC5kGDEiSPS07kosjXR1GRhj1wZlbMBcmNvGP6ISkC473ug2iGmwlTgKJL)kWuDrwfGmqCJ4CVc3yc4N1OsRbIC5VcmvxKvbkjETgC9iP2AEv4gta)SgvAnWTyL)k0raTMxfCxbMQlYQaKbIBezsSwHBmb8ZAuP1a3Ul)v4gta)SgvbQC1lxUcYlipMetaFfyQUiRccqU)gMeI6yf6iGwZRcUlTg4w8YFf6iGwZRcURat1fzvqqIWAdtcrDSc3yc4N1OslTcZlWzqT8xdCx(Rat1fzvGaIqtygwRWnMa(zruAnq8YFfyQUiRcor6ISkCJjGFwJkTgaSL)kWuDrwfgATzdt6SSc3yc4N1OsRb5S8xHBmb8ZAufOYvVC5kqKjieLhJm2OVPi99O8DEnCcm3eO4vGP6ISkOi99wNX6LatP1aGx(Rat1fzvqyLVD473ugwHBmb8ZAuP1axu(Rat1fzvaRizVD473ugwHBmb8ZAuP1axQ8xHBmb8ZAufOYvVC5kqri4enKffw5Bh((nLHr578A4eyUjq3Ilwc01eOisGkdVPrSIK92HVFtzy8gta)mbsMCcKIqWjAilIvKS3o89BkdJY351WjWCtGUfxSeORjqLH30iwrYE7W3VPmmEJjGFwbMQlYQWzPsQD473ugwAnihl)vGP6ISkKHFB13Xv4gta)SgvAnqKl)v4gta)SgvbQC1lxUcIibQm8Mgzm92Kn6J3yc4NjqYKtGezccrgtVnzJ(yMZeizYjqkcbNOHSiJP3MSrFu(oVgobkAce4IvbMQlYQabeHMnHmjWuAnWTyL)kCJjGFwJQavU6LlxbrKavgEtJmMEBYg9XBmb8ZeizYjqImbHiJP3MSrFmZzcKm5eifHGt0qwKX0Bt2OpkFNxdNafnbcCXQat1fzvGn6XQKHnkdHLwdC7U8xHBmb8ZAufOYvVC5kiIeOYWBAKX0Bt2OpEJjGFMajtobsKjiezm92Kn6JzotGKjNaPieCIgYImMEBYg9r578A4eOOjqGlwfyQUiRccR8eqeAwAnWT4L)kCJjGFwJQavU6LlxbrKavgEtJmMEBYg9XBmb8ZeizYjqImbHiJP3MSrFmZzfyQUiRcexIV0X18kTg4gyl)v4gta)SgvbQC1lxUcmvxGE7277XjqrtGINaDnboSei25HWMYsVR4iLeVwdUEKuBnVeOOjqXtGKjNaXope2uw6DfhHmqCJ4CpbkAcu8e4WRat1fzvqMznMQlYAWfRvaUyTzC)vGrV0AG7Cw(RWnMa(znQcmvxKvbzM1yQUiRbxSwb4I1MX9xb8AEW3uw6DT0sRGt5POobRL)AG7YFfUXeWpRrLwdeV8xHBmb8ZAuP1aGT8xHBmb8ZAuP1GCw(RWnMa(znQ0AaWl)vGP6ISkOi99wNX6LatfUXeWpRrLwdCr5VcmvxKvbHv(2HVFtzyfUXeWpRrLwdCPYFfyQUiRcyfj7TdF)MYWkCJjGFwJkTgKJL)kWuDrwfCI0fzv4gta)SgvAnqKl)vGP6ISkC473ug2iGmwRWnMa(znQ0slT0sRca]] )

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
