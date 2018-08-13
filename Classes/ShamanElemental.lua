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

    spec:RegisterPack( "Elemental", 20180813.1733, [[dC0KOaqikP8iqvztikFIss1OeICkHOEfIQzrs1TKQqTlr(fO0WOeDmrLLjk8mskzAsv01OKQTrjX3iPiJJssohjf16OKuQ5jk6EiY(echeuvvleu5Hsvq1ebvvXfjPuBuQcItkvbwPO0lLQqmtPkKUjLKIDck(PufKgQufuEQuMQOQRsjPK9QYFL0GfCyIfJWJPyYGCzLntIptPgTu50Q61ucZg42sSBQ(nKHtsoojfwoPEouth11fQTlv13LQ04bvvopOkRhuvLMVqA)i9L7YFniH3btgwMZQS0QYPwPCQj1kdRN7Am8uTRPsmwi27AUu21uBWkZzbCnvc8aib6YFnmkwB216ywf2QnSWA)CxmrYGkWI)smq4h5gTOWWI)IbwcaIawcfPhdT(WQsJuEWWWM)NoJCWMpJC1wNueVQ2GvMZciH)I5AeXpG7b(rCniH3btgwMZQS0QS0kPCwjJEEnSQzoyYWkzCnOHnxlF3JPHhtdcnanfjgW0GkXyHypAaPqdIHFKtdGhZyAqbPPb1gSYCwa0qRtkIJPbfKMgGtb(pDnvAKYd21GpAqTHFZeZdIgiMcspAWGkectdeZ(DCIgG)nMPIX0GJ8ECNOlkXaAqm8JCmnGCa8s0SIHFKJtQ0ZGkectsbiylOzfd)ihNuPNbvieMCsWQGqq0SIHFKJtQ0ZGkectojyLy7YCw4h50SWhn0CrfUdX0GwEiAGiwrzq0aMfgtdetbPhnyqfcHPbIz)oMgehIguPxpwfI53TPHhtdqiFjAwXWpYXjv6zqfcHjNeSyxuH7qCfZcJPzfd)ihNuPNbvieMCsWYiELArW80WJMvm8JCCsLEguHqyYjbRYRxDGvMZcGMvm8JCCsLEguHqyYjbRke)iNMvm8JCCsLEguHqyYjb7aRmNfqLaiyMMLMf(Ob1g(ntmpiAy9NgE0a)LrdC3ObXWinn8yAq6lpqialrZcF0aCaecceJzAWiy(DBAGyDs)hPPHYR1inMg4Urd4VedegPPb8y(DBmnOG00Gknc(bpAGaGqqGymNOH2gnGuXpYX0GvNaGqqGymxvnTzoB1vNgehIgS6eaecceJ5k)Lz1t0anRy4h5yseaecceJz1FfsSOThN6Ma4UKkdNzgwpAu(llcltw3slPzHpAOh49ydQqimnOcXpYPHhtdQ0tz658laa8ObW7wmiAGr0a8qXAAqTbRmNfG60qSdggtdguHqyAO3haOH5q0aUdPza8Ozfd)ihtojyvH4h50SWhn0dCEADSkMgqk0GrWmMgehIgEmnOh4fcWObw)22ttdifAOnvDXWFPH2m6XjAwXWpYXKtc2EFhQI7MOPzfd)ihtojyzeVsTiyEA4P(RqIfWCoXiELArW80WlnxiadImIyfLKEyKlUzvgXRK0RiVJZmdAwXWpYXKtcwLxV6aRmNfG6VcjRXcyoNWmsxQdSYCwaP5cbyq0SIHFKJjNeSygPl1bwzola1FfsSaMZjmJ0L6aRmNfqAUqagenRy4h5yYjb7en3vhyL5Sau)vizqiaeQxpP86vhyL5Sas6vK3XzMldljZASaMZjmJ0L6aRmNfqAUqagu0OgecaH61tygPl1bwzolGKEf5DCM5YWsYybmNtygPl1bwzolG0CHamiAwXWpYXKtc2y8QpVcMMvm8JCm5KGLaGqqvLyn8u)viznwaZ5KGnZHe3S0CHamOOrjIvusc2mhsCZsXQIg1GqaiuVEsWM5qIBwsVI8oocRBjnRy4h5yYjblX04PT4DB1FfswJfWCojyZCiXnlnxiadkAuIyfLKGnZHe3SuSkAwXWpYXKtcwDSxfd)iVcEmRUlLrsqt9xHKy4V)QZx5hoImilsyvdaQSOThJtMo59k4T7y)D7iYiAuSQbavw02JXjG0xQetkrKrKPzfd)ihtojy1XEvm8J8k4XS6Uugj872GvzrBpMMLMf(ObRMya)0alA7X0Gy4h50Gk9J0pdpAa8yMMvm8JCCsqJeMr6IfBQMw9xHelG5CcZiDXInvtNMleGbrZkg(roojOrojyfSzoK4MP(RqIfWCojyZCiXnlnxiadISiXcyoNWmsxQdSYCwaP5cbyqKzqiaeQxpHzKUuhyL5Sas6vK3XzMldljZGqaiuVEcZiDPoWkZzbK0RiVJJiN1Jg1ASaMZjmJ0L6aRmNfqAUqaguKPzfd)ihNe0iNeSGxnIFOArSlsLr8kQ)kKybmNtGxnIFOArSlsLr8kP5cbyq0SIHFKJtcAKtcwfGuwf3HmwO(RqcRAaqLfT9yCY0jVxbVDh7VBNzpvNfT946Rqspf9WDcby0SIHFKJtcAKtc2jAUtnIflgnl8rd9qDa8ObJGzAOhv6l0aCXAmtdiNg4o9gnWI2EmMgEfA4zA4X0G40W7ywCorZkg(roojOrojybsFPseRXS6VcPireROKasFPIJ12lfRkAuIyfLKGnZHe3SuSQitgw1aGklA7X4KPtEVcE7o2F3oZEsZkg(roojOrojyhyL5SaQeabZQ)kKybmNtdSYCwavcGG50CHamiYWQgauzrBpgNmDY7vWB3X(72z2tAwXWpYXjbnYjblq6lvIjf1FfsSaMZjbBMdjUzP5cbyq0SIHFKJtcAKtcwtN8Ef82DS)UnnRy4h54KGg5KGfi9LkrSgZQxq9F3Muo1FfsSaMZjbBMdjUzP5cbyq0SIHFKJtcAKtcwfGuwf3HmwOEb1)DBs5uNfT946Rqspf9WDcby0SIHFKJtcAKtcwfncZvChYyH6fu)3TjLJMLMf(OH272Grd5fT9yAa(3WpYPHEy6hPFgE0qp6JzAwXWpYXj872GvzrBpMKcqkRI7qglu)vizn(nw8UD0OqioPaKYQ4oKXIKEf5DCMKSnq0SIHFKJt43TbRYI2Em5KGvWM5qIBM6VcjwaZ5KGnZHe3S0CHamiYIe)LfbjRyz0OeXkkjcacbbIXCkwvKjZGqaiuVEci9LkrSgZj9kY74iSKmRXcyoNWmsxQdSYCwaP5cbyq0SIHFKJt43TbRYI2Em5KGvWM5qIBM6VcjwaZ5KGnZHe3S0CHamiYIe)LfbjRyz0OeXkkjcacbbIXCkwvKjZGqaiuVEci9LkrSgZj9kY74iSKmdcbGq96jmJ0L6aRmNfqsVI8oots5YWsAw4JgG)GCRotdX4rdQnyL5SaOb4acMPHxHgGhkMgmOyaenyemtdcny1iyEAAaPqdC3Ob1gSYCgtdROc170dIguBrZD0qRdzSGgEhZtGs0SIHFKJt43TbRYI2Em5KGDGvMZcOsaemR(RqIfWConWkZzbujacMtZfcWGilsSaMZPIG5PRiLk3T6aRmNXP5cbyqKreROKkcMNUIuQC3QdSYCgNIvrwrgaZAujtRyz0OwJfWCovempDfPu5UvhyL5monxiadkY0SWhn0JSPIgA9i0GcstdarBpAaPPbmc50Gabrd9k9horZkg(rooHF3gSklA7XKtcwmJ0fl2unT6VcjwaZ5eMr6IfBQMonxiadISiPLhQU(Z5KabHtguSZzQwrJQLhQU(Z5KabHtVhH1TmY0SIHFKJt43TbRYI2Em5KGf8Qr8dvlIDrQmIxr9xHelG5Cc8Qr8dvlIDrQmIxjnxiadISiPLhQU(Z5KabHtguSZzQwrJQLhQU(Z5KabHtVhH1TmY0SIHFKJt43TbRYI2Em5KGDIM7uJyXIP(Rqsm83F15R8dhroYWQgauzrBpgNmDY7vWB3X(72rKJmRXcyoNg8tfcpO6aRmNXP5cbyq0SWhny1cpAG7gnanIyffAGyki9ObJG53TPb1w0Chn06qglObXwEprZkg(rooHF3gSklA7XKtcwWB3X(72vceGv)viXcyoNg8tfcpO6aRmNXP5cbyqKbnIyfL0GFQq4bvhyL5mofRISImaM1OseKSILKznIyfLKGnZHe3SuSkAw4Jg6bk0Gkeg)eGPoneJhnO2IM7OHwhYybn07ZD0GvJG5PPbKcnWDJguBWkZzCIMvm8JCCc)Unyvw02JjNeSt0Cxf3HmwO(RqIfWCovempDfPu5UvhyL5monxiadISireROKkcMNUIuQC3QdSYCgNIvfnArgaZAujcsQ5mIC0OwJfWCovempDfPu5UvhyL5monxiadIMvm8JCCc)Unyvw02JjNeSaPVujI1yw9xHKbHaqOE9QEIHJgLiwrjjyZCiXnlfRIMvm8JCCc)Unyvw02JjNeSkaPSkUdzSqDw02JRVcj9u0d3jeGrZkg(rooHF3gSklA7XKtcwgXRulcMNgEQ)kKybmNtmIxPwempn8sZfcWGilseXkkj9WixCZQmIxjPxrEhNPvIgnseXkkj9WixCZQmIxjPxrEhNzKiIvusc2mhsCZsqXAHFKtUbHaqOE9KGnZHe3SKEf5DCKjZGqaiuVEsWM5qIBwsVI8ooZCwpYrMMvm8JCCc)Unyvw02JjNeSkAeMR4oKXc1FfsSaMZP3mLyn8sZfcWGiJiwrj9MPeRHxkwfnRy4h54e(DBWQSOThtojyFZuI1Wt9xHelG5C6ntjwdV0CHamiAwXWpYXj872GvzrBpMCsWcK(sLysr9xHelG5CsWM5qIBwAUqagezIH)(RoFLF4iYrgw1aGklA7X4eq6lvIjLiYrZkg(rooHF3gSklA7XKtcwtN8Ef82DS)UT6VcjXWF)vNVYpCe5idRAaqLfT9yCY0jVxbVDh7VBhroAwXWpYXj872GvzrBpMCsWcE7o2F3UsGamnRy4h54e(DBWQSOThtojyvaszvChYyH6fu)3TjLtDw02JRVcj9u0d3jeGrZkg(rooHF3gSklA7XKtcwfGuwf3HmwOEb1)DBs5u)vivq9xzoNGEmlUzryfAw4Jg6HOryMgADiJf0WJPbuSMgkO(RmNPbLhaMorZkg(rooHF3gSklA7XKtcwfncZvChYyH6fu)3TjL7A9Ng)i)GjdlZzvwAvwALuoRKrpVwVI2F3gFTEqrfsZdIg6jnig(ronaEmJt0SxtI5oK(ATVede(rEpCTOW0a8N1hFnWJz8L)A43TbRYI2E8L)Gj3L)AZfcWGo4UMr)80VCnRrd8BS4DBAiAuAacXjfGuwf3HmwK0RiVJPHmjrd2gORjg(r(1uaszvChYyXXhmzC5V2CHamOdURz0pp9lxls0a)LrdrqIgSIL0q0O0arSIsIaGqqGymNIvrdrMgiJgmieac1RNasFPseRXCsVI8oMgIGgSKgiJgSgnWcyoNWmsxQdSYCwaP5cbyqxtm8J8RjyZCiXn74dg16YFT5cbyqhCxZOFE6xUwKOb(lJgIGenyflPHOrPbIyfLebaHGaXyofRIgImnqgnyqiaeQxpbK(sLiwJ5KEf5DmnebnyjnqgnyqiaeQxpHzKUuhyL5Sas6vK3X0qMKOHCzy51ed)i)Ac2mhsCZo(GPNx(Rnxiad6G7Ag9Zt)Y1ybmNtfbZtxrkvUB1bwzoJtZfcWGObYObIyfLurW80vKsL7wDGvMZ4uSkAGmAOidGznQqdzsdwXsAiAuAWA0alG5CQiyE6ksPYDRoWkZzCAUqag01ed)i)AdSYCwavcGG5JpyS(L)AZfcWGo4UMr)80VCnT8q11FoNeiiCYGIDMgYKgulAiAuAqlpuD9NZjbccNENgIGgSULxtm8J8RHzKUyXMQPp(GXkx(Rnxiad6G7Ag9Zt)Y10Ydvx)5CsGGWjdk2zAitAqTOHOrPbT8q11FoNeiiC6DAicAW6wEnXWpYVg4vJ4hQwe7IuzeVYXhmQPl)1MleGbDWDnJ(5PF5AeXkkPz6qdxrkvUBvB9eUIJDOPF3ofR6AIHFKFTjAUtnIfl2Xhmw1L)AZfcWGo4UMr)80VCnOreROKg8tfcpO6aRmNXPyv0az0qrgaZAuHgIGenyflPbYObRrdeXkkjbBMdjUzPyvxtm8J8RbE7o2F3UsGa8XhmQ5l)1MleGbDWDnJ(5PF5ASaMZPIG5PRiLk3T6aRmNXP5cbyq0az0qKObIyfLurW80vKsL7wDGvMZ4uSkAiAuAOidGznQqdrqIguZzqdrMgIgLgSgnWcyoNkcMNUIuQC3QdSYCgNMleGbDnXWpYV2en3vXDiJfhFWKZYl)1MleGbDWDnJ(5PF5AgecaH61R6jgMgIgLgiIvusc2mhsCZsXQUMy4h5xdi9LkrSgZhFWKl3L)AZfcWGo4UMr)80VCn9u0d3jeGDnXWpYVMcqkRI7qglo(Gjxgx(Rnxiad6G7Ag9Zt)Y1iIvus6HrU4MvzeVssVI8oMgYKgScnenknejAGiwrjPhg5IBwLr8kj9kY7yAitAis0arSIssWM5qIBwckwl8JCAGCAWGqaiuVEsWM5qIBwsVI8oMgImnqgnyqiaeQxpjyZCiXnlPxrEhtdzsd5Sone5Rjg(r(1yeVsTiyEA4D8bto16YFT5cbyqhCxZOFE6xUgrSIs6ntjwdVuSQRjg(r(1u0imxXDiJfhFWKRNx(Rjg(r(1EZuI1W7AZfcWGo4o(GjN1V8xBUqag0b31m6NN(LRjg(7V68v(HPHiOHC0az0aw1aGklA7X4eq6lvIjfAicAi31ed)i)AaPVujMuo(GjNvU8xBUqag0b31m6NN(LRjg(7V68v(HPHiOHC0az0aw1aGklA7X4KPtEVcE7o2F3MgIGgYDnXWpYVMPtEVcE7o2F3(4dMCQPl)1ed)i)AG3UJ93TReiaFT5cbyqhChFWKZQU8xRG6)U91YDnXWpYVMcqkRI7qglUMr)80VCn9u0d3jeGDT5cbyqhChFWKtnF5Vwb1)D7RL7AIHFKFnfGuwf3HmwCnJ(5PF5Afu)vMZjOhZIBgnebnyLRnxiad6G74dMmS8YFTcQ)72xl31ed)i)AkAeMR4oKXIRnxiad6G74JVMG2L)Gj3L)AIHFKFnmJ0fl2un91MleGbDWD8btgx(Rnxiad6G7Ag9Zt)Y1ybmNtygPl1bwzolG0CHamiAGmAWGqaiuVEcZiDPoWkZzbK0RiVJPHmPHCzyjnqgnyqiaeQxpHzKUuhyL5Sas6vK3X0qe0qoRtdrJsdwJgybmNtygPl1bwzolG0CHamORjg(r(1eSzoK4MD8bJAD5VMy4h5xd8Qr8dvlIDrQmIx5AZfcWGo4o(GPNx(Rnxiad6G7Ag9Zt)Y1WQgauzrBpgNmDY7vWB3X(720qM0qpVMy4h5xtbiLvXDiJfxJfT946RCn9u0d3jeGD8bJ1V8xBUqag0b31m6NN(LRn1i(vPAqPz6qdxrkvUBvB9eUIJDOPF3(AIHFKFTjAURI7qglo(GXkx(Rnxiad6G7Ag9Zt)Y1MAe)QunO0mDOHRiLk3TQTEcxXXo00VBtdKrdeXkkPz6qdxrkvUBvB9eUIJDOPF3ofRIgIgLgSgnm1i(vPAqPz6qdxrkvUBvB9eUIJDOPF3(AIHFKFTjAUtnIfl2XhmQPl)1MleGbDWDnJ(5PF5ArIgiIvusaPVuXXA7LIvrdrJsdeXkkjbBMdjUzPyv0qKPbYObSQbavw02JXjtN8Ef82DS)UnnKjn0ZRjg(r(1asFPseRX8Xhmw1L)AZfcWGo4UMr)80VCnSQbavw02JXjtN8Ef82DS)UnnKjn0ZRjg(r(1gyL5SaQeabZhFWOMV8xtm8J8RbK(sLys5AZfcWGo4o(GjNLx(Rjg(r(1mDY7vWB3X(72xBUqag0b3Xhm5YD5Vwb1)D7RL7AIHFKFnG0xQeXAmFT5cbyqhChFWKlJl)1kO(VBFTCxtm8J8RPaKYQ4oKXIRz0pp9lxtpf9WDcbyxBUqag0b3Xhm5uRl)1kO(VBFTCxtm8J8RPOryUI7qglU2CHamOdUJp(AqtrIb8L)Gj3L)AZfcWGoIRz0pp9lxJfT94u3ea3LuzyAitAidRtdrJsd8xgnebnyzY6wA51ed)i)AeaecceJ5JpyY4YFnXWpYVMke)i)AZfcWGo4o(GrTU8xtm8J8R177qvC3e91MleGbDWD8btpV8xBUqag0b31m6NN(LRreROK0dJCXnRYiELKEf5DmnKjnKX1ed)i)AmIxPwempn8o(GX6x(Rjg(r(1uE9QdSYCwaxBUqag0b3Xhmw5YFnXWpYVgMr6sDGvMZc4AZfcWGo4o(GrnD5V2CHamOdURz0pp9lxZGqaiuVEs51RoWkZzbK0RiVJPHmPHCzyjnqgnynAGfWCoHzKUuhyL5SasZfcWGOHOrPbdcbGq96jmJ0L6aRmNfqsVI8oMgYKgYLHL0az0alG5CcZiDPoWkZzbKMleGbDnXWpYV2en3vhyL5Sao(GXQU8xtm8J8RfJx95vWxBUqag0b3XhmQ5l)1MleGbDWDnJ(5PF5AwJgybmNtc2mhsCZsZfcWGOHOrPbIyfLKGnZHe3SuSkAiAuAWGqaiuVEsWM5qIBwsVI8oMgIGgSULxtm8J8RraqiOQsSgEhFWKZYl)1MleGbDWDnJ(5PF5AwJgybmNtc2mhsCZsZfcWGOHOrPbIyfLKGnZHe3SuSQRjg(r(1iMgpTfVBF8btUCx(Rnxiad6G7Ag9Zt)Y1ed)9xD(k)W0qe0qg0az0qKObSQbavw02JXjtN8Ef82DS)UnnebnKbnenknGvnaOYI2EmobK(sLysHgIGgYGgI81ed)i)A6yVkg(rEf8y(AGhZvxk7AcAhFWKlJl)1MleGbDWDnXWpYVMo2RIHFKxbpMVg4XC1LYUg(DBWQSOThF8XxtLEguHq4l)btUl)1MleGbDWD8btgx(Rnxiad6G74dg16YFT5cbyqhChFW0Zl)1MleGbDWD8bJ1V8xtm8J8RXiELArW80W7AZfcWGo4o(GXkx(Rjg(r(1uE9QdSYCwaxBUqag0b3XhmQPl)1ed)i)AQq8J8Rnxiad6G74dgR6YFnXWpYV2aRmNfqLaiy(AZfcWGo4o(4Jp(47a]] )

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
