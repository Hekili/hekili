-- ShamanEnhancement.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Generate the Enhancement spec database only if you're actually a Shaman.
if select( 2, UnitClass( 'player' ) ) == 'SHAMAN' then
    local spec = Hekili:NewSpecialization( 263 )

    spec:RegisterResource( Enum.PowerType.Mana )   
    spec:RegisterResource( Enum.PowerType.Maelstrom, {
        mainhand = {
            last = function ()
                local swing = state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = 'mainhand_speed',
            value = 5
        },

        offhand = {
            last = function ()
                local swing = state.swings.offhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
            end,

            interval = 'offhand_speed',
            value = 5
        },

        fury_of_air = {
            aura = 'fury_of_air',

            last = function ()
                local app = state.buff.fury_of_air.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x )
                return x < 3
            end,

            interval = 1,
            value = -3,
        },

        ls_overcharge = not PTR and {
            aura = "lightning_shield_overcharge",

            last = function ()
                local app = state.buff.lightning_shield_overcharge.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 10
        } or nil,

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


    -- TALENTS
    spec:RegisterTalents( {
        boulderfist = 22354,
        hot_hand = 22355,
        lightning_shield = 22353,

        landslide = 22636,
        forceful_winds = 22150,
        totem_mastery = 23109,

        spirit_wolf = 23165,
        earth_shield = 19260,
        static_charge = 23166,

        searing_assault = 23089,
        hailstorm = 23090,
        overcharge = 22171,

        natures_guardian = 22144,
        feral_lunge = 22149,
        wind_rush_totem = 21966,

        crashing_storm = 21973,
        fury_of_air = 22352,
        sundering = 22351,

        elemental_spirits = 21970,
        earthen_spike = 22977,
        ascendance = 21972
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        relentless = 3553, -- 196029
        adaptation = 3552, -- 214027
        gladiators_medallion = 3551, -- 208683

        forked_lightning = 719, -- 204349
        static_cling = 720, -- 211062
        thundercharge = 725, -- 204366
        shamanism = 722, -- 193876
        spectral_recovery = 3519, -- 204261
        ride_the_lightning = 721, -- 204357
        grounding_totem = 3622, -- 204336
        swelling_waves = 3623, -- 204264
        ethereal_form = 1944, -- 210918
        skyfury_totem = 3487, -- 204330
        counterstrike_totem = 3489, -- 204331
        purifying_waters = 3492, -- 204247
    } )


    spec:RegisterAuras( {
        ascendance = {
            id = 114051,
            duration = 15,
        },
        
        astral_shift = { 
            id = 108271,
            duration = 8,
        },

        boulderfist = {
            id = 218825,
            duration = 10,
        },

        chill_of_the_twisting_nether = {
            id = 207998,
            duration = 8,
        },

        crackling_surge = {
            id = 224127,
            duration = 15,
        },

        crash_lightning = {
            id = 187878,
            duration = 10,
        },

        crashing_lightning = {
            id = 242286,
            duration = 16,
            max_stack = 15,
        },

        earthen_spike = {
            id = 188089,
            duration = 10,
        },

        ember_totem = {
            id = 262399,
            duration = 120,
            max_stack =1 ,
        },
        
        feral_spirit = {            
            name = "Feral Spirit",
            duration = 15,
            generate = function ()
                local cast = rawget( class.abilities.feral_spirit, "lastCast" ) or 0
                local up = cast + 15 > query_time

                local fs = buff.feral_spirit
                fs.name = "Feral Spirit"

                if up then
                    fs.count = 1
                    fs.expires = cast + 15
                    fs.applied = cast
                    fs.caster = "player"
                    return
                end
                fs.count = 0
                fs.expires = 0
                fs.applied = 0
                fs.caster = "nobody"
            end,
        },

        fire_of_the_twisting_nether = {
            id = 207995,
            duration = 8,
        },

        flametongue = {
            id = 194084,
            duration = 16,
        },

        frostbrand = {
            id = 196834,
            duration = 16,
        },

        fury_of_air = {
            id = 197211,
            duration = 3600,
        },

        gathering_storms = {
            id = 198300,
            duration = 12,
            max_stack = 1,
        },

        hot_hand = {
            id = 215785,
            duration = 15,
        },

        landslide = {
            id = 202004,
            duration = 10,
        },

        lashing_flames = {
            id = 240842,
            duration = 10,
            max_stack = 99,
        },

        lightning_crash = {
            id = 242284,
            duration = 16
        },

        lightning_shield = {
            id = 192106,
            duration = 3600,
            max_stack = 20,
        },

        lightning_shield_overcharge = {
            id = 273323,
            duration = 10,
            max_stack = 1,
        },

        molten_weapon = {
            id = 271924,
            duration = 4,
        },

        resonance_totem = {
            id = 262417,
            duration = 120,
            max_stack =1 ,
        },

        shock_of_the_twisting_nether = {
            id = 207999,
            duration = 8,
        },

        storm_totem = {
            id = 262397,
            duration = 120,
            max_stack =1 ,
        },

        stormbringer = {
            id = 201846,
            duration = 12,
            max_stack = 1,
        },

        tailwind_totem = {
            id = 262400,
            duration = 120,
            max_stack =1 ,
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

        lightning_conduit = {
            id = 275391,
            duration = 60,
            max_stack = 1
        },

        primal_primer = {
            id = 273006,
            duration = 30,
            max_stack = 10,
        },

        roiling_storm = {
            id = 278719,
            duration = 3600,
            max_stack = 15,
            meta = {
                stack = function ( t )
                    if t.down then return 0 end
                    return min( 15, t.count + floor( ( query_time - t.applied ) / 2 ) )
                end,
            }
        },

        strength_of_earth = {
            id = 273465,
            duration = 10,
            max_stack = 1,
        },

        thunderaans_fury = {
            id = 287802,
            duration = 6,
            max_stack = 1,
        },
    } )


    spec:RegisterStateTable( 'feral_spirit', setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.feral_spirit.lastCast or 0
                return t.cast_time
            elseif k == 'active' or k == 'up' then
                return query_time < t.cast_time + 15
            elseif k == 'remains' then
                return max( 0, t.cast_time + 15 - query_time )
            end

            return false
        end 
    } ) )

    spec:RegisterStateTable( 'twisting_nether', setmetatable( { onReset = function( self ) end }, { 
        __index = function( t, k )
            if k == 'count' then
                return ( buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( buff.shock_of_the_twisting_nether.up and 1 or 0 )
            end
            
            return 0
        end 
    } ) )

    spec:RegisterGear( 'waycrest_legacy', 158362, 159631 )
    spec:RegisterGear( 'electric_mail', 161031, 161034, 161032, 161033, 161035 )

    spec:RegisterGear( 'tier21', 152169, 152171, 152167, 152166, 152168, 152170 )
        spec:RegisterAura( 'force_of_the_mountain', {
            id = 254308,
            duration = 10
        } )
        spec:RegisterAura( 'exposed_elements', {
            id = 252151,
            duration = 4.5
        } )

    spec:RegisterGear( 'tier20', 147175, 147176, 147177, 147178, 147179, 147180 )
        spec:RegisterAura( "lightning_crash", {
            id = 242284,
            duration = 16
        } )
        spec:RegisterAura( "crashing_lightning", {
            id = 242286,
            duration = 16,
            max_stack = 15
        } )

    spec:RegisterGear( 'tier19', 138341, 138343, 138345, 138346, 138348, 138372 )
    spec:RegisterGear( 'class', 139698, 139699, 139700, 139701, 139702, 139703, 139704, 139705 )
    


    spec:RegisterGear( 'akainus_absolute_justice', 137084 )
    spec:RegisterGear( 'emalons_charged_core', 137616 )
    spec:RegisterGear( 'eye_of_the_twisting_nether', 137050 )
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

    spec:RegisterGear( 'smoldering_heart', 151819 )
    spec:RegisterGear( 'soul_of_the_farseer', 151647 )
    spec:RegisterGear( 'spiritual_journey', 138117 )
    spec:RegisterGear( 'storm_tempests', 137103 )
    spec:RegisterGear( 'uncertain_reminder', 143732 )

    spec:RegisterAbilities( {
        ascendance = {
            id = 114051,
            cast = 0,
            cooldown = 180,
            gcd = 'off',

            readyTime = function() return buff.ascendance.remains end,
            recheck = function () return buff.ascendance.remains end,
            
            nobuff = 'ascendance',
            talent = 'ascendance',
            toggle = 'cooldowns',

            startsCombat = false,

            handler = function ()
                applyBuff( 'ascendance', 15 )
                setCooldown( 'stormstrike', 0 )
                setCooldown( 'windstrike', 0 )
            end,
        },

        astral_shift = {
            id = 108271,
            cast = 0,
            cooldown = 90,
            gcd = 'off',

            startsCombat = false,

            handler = function ()
                applyBuff( 'astral_shift', 8 )
            end,
        },

        bloodlust = {
            id = 2825,
            cast = 0,
            cooldown = 300,
            gcd = 'spell', -- Ugh.
            
            spend = 0.215,
            spendType = 'mana',
            
            startsCombat = false,

            handler = function ()
                applyBuff( 'bloodlust', 40 )
            end,
        },

        crash_lightning = {
            id = 187874,
            cast = 0,
            cooldown = function () return 6 * haste end,
            gcd = 'spell',

            spend = 20,
            spendType = 'maelstrom',

            recheck = function () return buff.crash_lightning.remains end,
            
            startsCombat = true,

            handler = function ()
                if active_enemies >= 2 then
                    applyBuff( 'crash_lightning', 10 )
                    applyBuff( "gathering_storms" )
                end

                removeBuff( 'crashing_lightning' )
                
                if level < 116 then 
                    if equipped.emalons_charged_core and spell_targets.crash_lightning >= 3 then
                        applyBuff( 'emalons_charged_core', 10 )
                    end

                    if set_bonus.tier20_2pc > 1 then
                        applyBuff( 'lightning_crash' )
                    end
    
                    if equipped.eye_of_the_twisting_nether then
                        applyBuff( 'shock_of_the_twisting_nether', 8 )
                    end
                end
            end,
        },

        earth_elemental = {
            id = 198103,
            cast = 0,
            cooldown = 300,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136024,

            toggle = "defensives",            
            
            handler = function ()
                summonPet( "greater_earth_elemental", 60 )
            end,
        },
        
        earthen_spike = {
            id = 188089,
            cast = 0,
            cooldown = function () return 20 * haste end,
            gcd = 'spell',

            spend = 20,
            spendType = 'maelstrom',

            startsCombat = true,

            handler = function ()
                applyDebuff( 'target', 'earthen_spike' )
            end,
        },

        feral_spirit = {
            id = 51533,
            cast = 0,
            cooldown = function () return 120 - ( talent.elemental_spirits.enabled and 30 or 0 ) end,
            gcd = "spell",

            startsCombat = false,
            toggle = "cooldowns",

            handler = function () feral_spirit.cast_time = query_time; applyBuff( "feral_spirit" ) end
        },

        flametongue = {
            id = 193796,
            cast = 0,
            cooldown = function () return 12 * haste end,
            gcd = 'spell',

            startsCombat = true,

            handler = function ()
                applyBuff( 'flametongue', 16 + min( 4.8, buff.flametongue.remains ) )

                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'fire_of_the_twisting_nether', 8 )
                end

                removeBuff( "strength_of_earth" )
            end,
        },


        frostbrand = {
            id = 196834,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 20,
            spendType = 'maelstrom',

            startsCombat = true,

            handler = function ()
                applyBuff( 'frostbrand', 16 + min( 4.8, buff.frostbrand.remains ) )

                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'chill_of_the_twisting_nether', 8 )
                end

                removeBuff( "strength_of_earth" )
            end,
        },


        fury_of_air = {
            id = 197211,
            cast = 0,
            cooldown = 0,
            gcd = function( x )
                if buff.fury_of_air.up then return 'off' end
                return "spell"
            end,

            spend = 3,
            spendType = "maelstrom",

            talent = 'fury_of_air',

            startsCombat = false,

            handler = function ()
                if buff.fury_of_air.up then removeBuff( 'fury_of_air' )
                else applyBuff( 'fury_of_air', 3600 ) end
            end,
        },


        healing_surge = {
            id = 188070,
            cast = function() return maelstrom.current >= 20 and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return maelstrom.current >= 20 and 20 or 0 end,
            spendType = "maelstrom",

            startsCombat = false,
        },


        heroism = {
            id = 32182,
            cast = 0,
            cooldown = 300,
            gcd = "spell", -- Ugh.

            spend = 0.215,
            spendType = 'mana',

            startsCombat = false,
            toggle = 'cooldowns',

            handler = function ()
                applyBuff( 'heroism' )
                applyDebuff( 'player', 'exhaustion', 600 )
            end,
        },


        lava_lash = {
            id = 60103,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function() return buff.hot_hand.up and 0 or 30 end,
            spendType = "maelstrom",

            startsCombat = true,

            handler = function ()
                removeBuff( 'hot_hand' )
                removeDebuff( "target", "primal_primer" )

                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'fire_of_the_twisting_nether' )
                    if buff.crash_lightning.up then applyBuff( 'shock_of_the_twisting_nether' ) end
                end
            end,
        },


        lightning_bolt = {
            id = 187837,
            cast = 0,
            cooldown = function() return talent.overcharge.enabled and ( 12 * haste ) or 0 end,
            gcd = "spell",
            
            spend = function() return talent.overcharge.enabled and min( maelstrom.current, 40 ) or 0 end,
            spendType = 'maelstrom',

            startsCombat = true,

            handler = function ()
                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'shock_of_the_twisting_nether' )
                end
            end,
        },


        lightning_shield = {
            id = 192106,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            talent = 'lightning_shield',
            essential = true,
        
            readyTime = function () return buff.lightning_shield.remains - 120 end,
            usable = function () return buff.lightning_shield.remains < 120 end,
            handler = function () applyBuff( 'lightning_shield' ) end,
        },


        rockbiter = {
            id = 193786,
            cast = 0,
            cooldown = function() local x = 6 * haste; return talent.boulderfist.enabled and ( x * 0.85 ) or x end,
            recharge = function() local x = 6 * haste; return talent.boulderfist.enabled and ( x * 0.85 ) or x end,
            charges = 2,
            gcd = "spell",
            
            spend = -25,
            spendType = "maelstrom",

            startsCombat = true,

            recheck = function () return ( 1.7 - charges_fractional ) * recharge end,

            handler = function ()
                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'shock_of_the_twisting_nether' )
                end
                removeBuff( 'force_of_the_mountain' )
                if set_bonus.tier21_4pc > 0 then applyDebuff( 'target', 'exposted_elements', 4.5 ) end

                if azerite.strength_of_earth.enabled then applyBuff( "strength_of_earth" ) end
            end,
        },


        stormstrike = {
            id = 17364,
            cast = 0,
            cooldown = function()
                if buff.stormbringer.up then return 0 end
                if buff.ascendance.up then return 3 * haste end
                return 9 * haste
            end,
            gcd = "spell",

            spend = function()
                if buff.stormbringer.up then return 0 end
                return max( 0, ( buff.roiling_storm.stack * -2 ) + ( buff.ascendance.up and 10 or 30 ) )
            end,

            spendType = 'maelstrom',

            startsCombat = true,
            texture = 132314,

            cycle = function () return azerite.lightning_conduit.enabled and "lightning_conduit" or nil end,

            usable = function() return buff.ascendance.down end,
            handler = function ()
                if buff.lightning_shield.up then
                    addStack( "lightning_shield", 3600, 2 )
                    if buff.lightning_shield.stack >= 20 then
                        applyBuff( "lightning_shield" )
                        applyBuff( "lightning_shield_overcharge" )
                    end
                end

                setCooldown( 'windstrike', action.stormstrike.cooldown )
                setCooldown( 'strike', action.stormstrike.cooldown )

                if buff.stormbringer.up then
                    removeBuff( 'stormbringer' )
                elseif azerite.roiling_storm.enabled then
                    applyBuff( "roiling_storm", nil, 0 )
                end

                removeBuff( "gathering_storms" )

                if azerite.lightning_conduit.enabled then
                    applyDebuff( "target", "lightning_conduit" )
                end

                removeBuff( "strength_of_earth" )

                if level < 116 then
                    if equipped.storm_tempests then
                        applyDebuff( 'target', 'storm_tempests', 15 )
                    end
    
                    if set_bonus.tier20_4pc > 0 then
                        addStack( 'crashing_lightning', 16, 1 )
                    end

                    if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                        applyBuff( 'shock_of_the_twisting_nether', 8 )
                    end
                end
            end,                    

            copy = "strike", -- copies this ability to this key or keys (if a table value)
        },


        sundering = {
            id = 197214,
            cast = 0,
            cooldown = 40,
            gcd = "spell",

            spend = 20,
            spendType = "maelstrom",

            startsCombat = true,
            talent = 'sundering',

            handler = function () if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( 'shock_of_the_twisting_nether' ) end end,
        },


        totem_mastery = {
            id = 262395,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            talent = "totem_mastery",
            essential = true,

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


        wind_shear = {
            id = 57994,
            cast = 0,
            cooldown = 12,
            gcd = "off",

            startsCombat = true,
            toggle = "interrupts",

            usable = function () return debuff.casting.up end,
            handler = function () interrupt() end,
        },

        windstrike = {
            id = 115356,
            cast = 0,
            cooldown = function() return buff.stormbringer.up and 0 or ( 3 * haste ) end,
            gcd = "spell",

            spend = function() return buff.stormbringer.up and 0 or 10 end,
            spendType = "maelstrom",
            
            texture = 1029585,

            known = 17364,
            usable = function () return buff.ascendance.up end,
            handler = function ()
                setCooldown( 'stormstrike', action.stormstrike.cooldown )
                setCooldown( 'strike', action.stormstrike.cooldown )

                if buff.stormbringer.up then
                    removeBuff( 'stormbringer' )
                elseif azerite.roiling_storm.enabled then
                    applyBuff( "roiling_storm", nil, 0 ) -- apply at 0 stacks, will stack over time.
                end

                removeBuff( "gathering_storms" )

                removeBuff( "strength_of_earth" )

                if level < 116 then
                    if equipped.storm_tempests then
                        applyDebuff( 'target', 'storm_tempests', 15 )
                    end
    
                    if set_bonus.tier20_4pc > 0 then
                        addStack( 'crashing_lightning', 16, 1 )
                    end

                    if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                        applyBuff( 'shock_of_the_twisting_nether', 8 )
                    end
                end
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        potion = "battle_potion_of_agility",
        
        package = "Enhancement",
    } )


    spec:RegisterPack( "Enhancement", 20181210.2249, [[dGusWaqiPqpskO2eL0NuvrAuOGtPQQvrjIEfkvZIs4wQQuTlQ6xsjdJK4yQkwgk0ZOsY0Oe11uuTnss6Buj14KcCokrQ1rjcZJKe3tvAFkkhuvLIfII6HujMOQkIUOQkQpQQsPoPuqyLsrZuvfH2PQs)uvLmuvvyPuIKNkvtvk1vvvrWxLcIAVk9xk1GP4WelwHhJyYQ4YqBwL(SQy0kYPL8AuKzdCBsSBHFJQHtL64sbrwoONtQPl66uX2rjFNKuJxvLsopkL1lfKMpj1(r69Z2E7hjX9lJQ8PbFy8JkEgz0Yw6pny7jBUXT7wimjp42drb3(phtsqqfmYT7wydWLZ2E7AUdKGBFkt3AlrRwpvo5m8eUslDP4aKS4bbk3SLUuiTga(O14k)(bz1YnKFlaQB1UqiJm2QnJmA3NefjS)5ysccQGr61Lcz7dNcKneXo2(rsC)YOkFAWhg)OINrgTSL(Z8Tlo5ehU9EP4aKS4Hlq5MBFQohm2X2pOMS9gMA(5ysccQGrsn9jrrcAZgMAMY0T2s0Q1tLtodpHR0sxkoajlEqGYnBPlfsRbGpAnUYVFqwTCd53cG6w)aIwkPo6w)Wsz3NefjS)5ysccQGr61LcH2SHPMFsKGkdesnFuXcQHrv(0aQ53Pggz0syzxVDqPt92E7C3yGWT9(9Z2E7yidaEwM3obwjclz7kcc0jKRqnQc18zo1yLAYsbPgvHAEiNTlKS4X2HCctJkr4MBUDchIB797NT92Xqga8SmVDcSsewY2zjWsga0FDGS5YesyIX5BxizXJTJcmNWWw7Uyc3C)Y42E7yidaEwM3obwjclz7cjlwOngOsHAQz2l14QTlKS4X21oXbHv8S5(1vB7TJHma4zzE7cjlESDDYHk6ewmHBNaReHLSDPHIWkrpOEMYOIhBcpoov6Xqga8qnwPMgPMdoCUxpOEMYOIhBcpoov6DCtnwPgHKfl0gduPqn1mJA(qnwPggOMHZ961jhQmGv8GqVJBQrTAQHbQHLalzaq)VC5hCoW1QqnwPgwcSKba9xhiBUmHeMC1CQ5p18F7e2ia0of4dM697Nn3VwEBVDmKbaplZBNaReHLS9HZ961jhQmGv8GqVJBQrTAQHbQz4CV(hjNqyfp26Kdv0Eh3uJvQHLalzaq)VC5hCoW1QqnwPgwcSKba9xhiBUmHeMC1CQ5)2fsw8y76Kdv0jSyc3C)oFBVDmKbaplZBNaReHLSDHKfl0gduPqn1m7LACf1yLAyjWsga0FDGS5YesyIX5BxizXJTtGIEYguptzuXZM7xvDBVDmKbaplZBNaReHLS9uayKEolesMe4d6Xqga8qnwPgHKfl0gduPqn18snFOgRudlbwYaG(RdKnxMqctwEo1yLAueeOtixHAM9snwwLTlKS4X2b1Zugv8yp4GCZ9RR32BhdzaWZY82jWkryjBNLalzaq)VC5hCoW1QqnwPgwcSKba9xhiBUmHeMC18TlKS4X21jhQOtyXeU5(TbB7TlKS4X21oXbHv8SDmKbaplZBUFT0B7TJHma4zzE7eyLiSKTNcaJ0F5qcEDa2QUIJ2JHma4HASsncjlwOngOsHAQzg18HASsnSeyjda6Voq2CzcjmX48TlKS4X2jqrpzdQNPmQ4zZ97hv22BhdzaWZY82jWkryjBpfagPxJcSIhBrRfhq6Xqga8SDHKfp2(fikyYJhhCZ97NpB7TJHma4zzE7eyLiSKTNcaJ0pXt7jjoEmKbapuJvQz4CV(jEApjXXdrHKBxizXJTdewInq0tBUF)W42E7yidaEwM3obwjclz7cjlwOngOsHAQzg18HASsnSeyjda6Voq2CzcjmX48TlKS4X2jqrpzdQNPmQ4zZn3(bVIdi3273pB7TlKS4X2vDfhB9ekWTJHma4zzEZ9lJB7TJHma4zzE7SeGdUDgOMgPMuayK(RdKnB(1wkOhdzaWd1Own1Wa1KcaJ0FDGSzZV2sb9yidaEOgRuJIGaDc5kuZmQXYZPM)uZ)TlKS4X2zjWsgaC7SeODik42Voq2Czcjmz55BUFD12E7yidaEwM3olb4GBNbQPrQjfagP)6azZMFTLc6Xqga8qnQvtnmqnPaWi9xhiB28RTuqpgYaGhQXk1OiiqNqUc1mJAC1CQ5p18F7cjlESDwcSKba3olbAhIcU9RdKnxMqctUA(M7xlVT3ogYaGNL5TZsao42zGAAKAsbGr6Voq2S5xBPGEmKbapuJA1uddutkams)1bYMn)Alf0JHma4HASsnkcc0jKRqnZOggNtn)PM)BxizXJTZsGLma42zjq7quWTFDGS5YesyIX5BUFNVT3ogYaGNL5TZsao42zGAAKAsbGr65SqizsGpOhdzaWd1Own1iKSyH2yGkfQPMzuZhQrTAQHbQjfagPNZcHKjb(GEmKbapuJvQrizXcTXavkutnVuZhQXk1Wa1q4CWHR6WdQNPmQ4XEWbPhIksfAQz2l1Wi1yjPMhYHAuRMAueeOtixHAMrnnqfQ5p18NA(VDHKfp2olbwYaGBNLaTdrb3(VC5hCoObQS5(vv32BhdzaWZY82zjahC7mqnnsnPaWi9CwiKmjWh0JHma4HAuRMAeswSqBmqLc1uZmQ5d1Own1Wa1KcaJ0ZzHqYKaFqpgYaGhQXk1iKSyH2yGkfQPMxQ5d1yLAyGAiCo4WvD4b1Zugv8yp4G0drfPcn1m7LAyKASKuZd5qnQvtnkcc0jKRqnZOgxRc18NA(tn)3UqYIhBNLalzaWTZsG2HOGB)xU8doh4Av2C)66T92Xqga8SmVDwcWb3odutJutkamspNfcjtc8b9yidaEOg1QPgHKfl0gduPqn1mJA(qnQvtnmqnPaWi9CwiKmjWh0JHma4HASsncjlwOngOsHAQ5LA(qnwPggOgcNdoCvhEq9mLrfp2doi9qurQqtnZEPggPglj18qouJA1uJIGaDc5kuZmQrvvHA(tn)PM)BxizXJTZsGLma42zjq7quWT)lx(bNduvv2C)2GT92fsw8y7ItYTLmfctBhdzaWZY8M7xl92E7cjlESDhnAxjQO3ogYaGNL5n3VFuzBVDmKbaplZBxizXJTteaWwizXdBqPZTdkDAhIcUDUBmq4M73pF22BhdzaWZY82jWkryjBF4CVErtW4ibb9oU3UqYIhBNiaGTqYIh2GsNBhu60oefC7IMS5(9dJB7TJHma4zzE7cjlESDIaa2cjlEydkDUDqPt7quWTpCUx9M73pUABVDmKbaplZBxizXJTteaWwizXdBqPZTdkDAhIcUDYrV5(9JL32BhdzaWZY82fsw8y7ebaSfsw8Wgu6C7GsN2HOGBNWH4M73pZ32BhdzaWZY82fsw8y7ebaSfsw8Wgu6C7GsN2HOGB)waac3CZT7gIeUYqYT9(9Z2E7yidaEwM3C)Y42E7yidaEwM3C)6QT92Xqga8SmV5(1YB7TJHma4zzEZ978T92fsw8y7U5zXJTJHma4zzEZ9RQUT3UqYIhBp5jQyRi6eHSTDmKbaplZBUFD92E7cjlESDq9mLrfp26PcbNTJHma4zzEZn3UOjB797NT92Xqga8SmVDcSsewY2BKAgo3RNaf9KnOEMYOIhVJBQXk1iKSyH2yGkfQPMzuZhQXk1WsGLmaO)6azZLjKWeJZ3UqYIhBNaf9KnOEMYOINn3VmUT3ogYaGNL5TtGvIWs2EkamspqIJguh0JHma4HASsnnsndN71dK4Ob1b9oUPgRudzsGpO2(cfsw8qauZmQ5J31BxizXJTd5eMgvIWn3VUABVDHKfp2UQR4OtyXeUDmKbaplZBU52ho3REBVF)ST3ogYaGNL5TtGvIWs2EJuZW5E9eOONSb1Zugv84DCtnwPgHKfl0gduPqn1mJA(qnwPgwcSKba9xhiBUmHeMyC(2fsw8y7eOONSb1Zugv8S5(LXT92Xqga8SmVDcSsewY2tbGr6bsC0G6GEmKbapuJvQPrQz4CVEGehnOoO3Xn1yLAitc8b12xOqYIhcGAMrnF8UE7cjlESDiNW0OseU5(1vB7TJHma4zzE7eyLiSKT3i1KfHPkEOgRuJIGaDc5kuZSxQHrv2UqYIhB)6azZMFTLcU5(1YB7TJHma4zzE7eyLiSKT3i1mCUx)fikyYJhh074E7cjlES9lquWKhpo4M735B7TJHma4zzE7eyLiSKTNcaJ0pjfqNCOIhdzaWd1yLAAKAgo3R)c56CaL44DCtnwPgwcSKba9xhiBUmHeMyC(2fsw8y7xixNdOeNn3VQ62E7yidaEwM3obwjclz7dN71FbIcM84Xb9qurQqtnQc1yzFdOg2PMhYz7cjlES9lquWKhpo4M7xxVT3ogYaGNL5TtGvIWs2Ekams)KuaDYHkEmKbapuJvQz4CV(lKRZbuIJhIksfAQrvOgl7Ba1Wo18qouJvQHLalzaq)1bYMltiHjgNVDHKfp2(fY15akXzZ9Bd22BhdzaWZY82jWkryjBF4CVEiQ5Hee0o5jQ4HOIuHMAufQHXTlKS4X2tEIk2kIoriBBU52jh92E)(zBVDmKbap7y7eyLiSKTlnuewj6LGG6ekaBiQ5Hee0JHma4z7cjlES9bGZpahDU5(LXT92Xqga8SmVDcSsewY2zGAsbGr6fnbJJee0JHma4HASsndN71lAcghjiO3Xn18NAuRMAyGAsbGr6raQGrkaBT7cwP2JHma4HASsnxekaBT7cwPhIksfAQzg1mNA(tnQvtnmqnnsnPaWi9IMGXrcc6Xqga8qnwPMgPMuayKEeGkyKcWw7UGvQ9yidaEOM)BxizXJTpqOgHmvXZM7xxTT3ogYaGNL5TtGvIWs2odutkamsVOjyCKGGEmKbapuJvQHbQz4CVErtW4ibb9oUPg1QPgcNdoCvhErtW4ibb9qurQqtnZOM5Qqn)PM)uJA1uddutJutkamsVOjyCKGGEmKbapuJvQHbQ5IqbyRDxWk9qurQqtnZOM5uJA1udHZbhUQd)fHcWw7UGv6HOIuHMAMrnZvHA(tn)3UqYIhBFa48J91bY2M7xlVT3ogYaGNL5TtGvIWs2odutkamsVOjyCKGGEmKbapuJvQHbQz4CVErtW4ibb9oUPg1QPgcNdoCvhErtW4ibb9qurQqtnZOM5Qqn)PM)uJA1uddutJutkamsVOjyCKGGEmKbapuJvQHbQ5IqbyRDxWk9qurQqtnZOM5uJA1udHZbhUQd)fHcWw7UGv6HOIuHMAMrnZvHA(tn)3UqYIhB)wqCa48ZM735B7TJHma4zzE7eyLiSKTZa1KcaJ0lAcghjiOhdzaWd1yLAyGAgo3Rx0emosqqVJBQrTAQHW5Gdx1Hx0emosqqpevKk0uZmQzUkuZFQ5p1Own1Wa10i1KcaJ0lAcghjiOhdzaWd1yLAyGAUiua2A3fSspevKk0uZmQzo1Own1q4CWHR6WFrOaS1UlyLEiQivOPMzuZCvOM)uZ)TlKS4X2LGG6ekaBIaaBUFv1T92Xqga8SmVDcSsewY2ho3Rx0emosqqVJBQrTAQPrQjfagPx0emosqqpgYaGhQXk1CrOaS1UlyLEiQivOPMzuZCQrTAQjlf0o52NcPgv5LAuvv2UqYIhB3nplES5(11B7TlKS4X2Viua2A3fSYTJHma4zzEZ9Bd22BhdzaWZY82jWkryjBNW5Gdx1HxNWIj0drfPcn1mJAuz7cjlESDrtW4ibb3C)AP32BxizXJTJcmNSraQGrkGTJHma4zzEZn3(TaaeUT3VF22BhdzaWZY82jWkryjBxrqGoHCfQrvOgxRc1yLAAKAgo3RxNqmEYjB(1gfyo5DCVDHKfp2oKtyAujc3C)Y42E7yidaEwM3obwjclz7PaWi9eOONQ4XwNCOIhdzaWd1yLAyjWsga0)lx(bNduvv2UqYIhBNaf9KnOEMYOINn3VUABVDmKbaplZBNaReHLSDwcSKba9)YLFW5GgOc1yLAyjWsga0FDGS5YesyYYZ3UqYIhBhiSeBGON2C)A5T92fsw8y7qoHPrLiC7yidaEwM3C)oFBVDHKfp2(fikyYJhhC7yidaEwM3CZn3oleQlESFzuLpn4JkmYONXpmAP3UQfyuXJE7nK)nwQVneF)TTeud10EcPMsXnhMuZLdPMF6bVIdi)PudeBi5uq8qnAUcsnItYvKepudzsIhu7Pn)jwbsnnWsqn)ecTJB3CyIhQrizXdQ5Nkoj3wYuim9t90M0MnekU5WeputdOgHKfpOgqPtTN2C7A3iz)YOQ6QT7gYVfa3Edtn)CmjbbvWiPM(KOibTzdtntz6wBjA16PYjNHNWvAPlfhGKfpiq5MT0LcP1aWhTgx53piRwUH8BbqDRFarlLuhDRFyPS7tIIe2)CmjbbvWi96sHqB2WuZpjsqLbcPMpQyb1WOkFAa187udJmAjSSRPnPnByQ5N)TqItIhQzGxoePgcxzij1mWNk0EQ53qiO7utnbp(9jbQCDauJqYIhAQHha280McjlEO9UHiHRmK89cent0McjlEO9UHiHRmKK93wxo)qBkKS4H27gIeUYqs2FBjopkyKsw8G2SHPMEiU1t8KAGsDOMHZ9IhQrNsQPMbE5qKAiCLHKuZaFQqtnsCOg3q83DZZSIhQP0uZHhON2uizXdT3nejCLHKS)2shIB9epT1PKAAtHKfp0E3qKWvgsY(Bl38S4bTPqYIhAVBis4kdjz)TvYtuXwr0jczJ2uizXdT3nejCLHKS)2cuptzuXJTEQqWH2K2SHPMF(3cjojEOgKfczJAYsbPMCcPgHKCi1uAQryjfqga0tBkKS4H(v1vCS1tOaPnfsw8qZ(BlwcSKbaTief896azZLjKWKLNBblb4GVm0ykams)1bYMn)Alf0JHma4rTAgsbGr6Voq2S5xBPGEmKbapwveeOtixzMLN))pTPqYIhA2FBXsGLmaOfHOGVxhiBUmHeMC1Clyjah8LHgtbGr6Voq2S5xBPGEmKbapQvZqkams)1bYMn)Alf0JHma4XQIGaDc5kZC18))Pnfsw8qZ(BlwcSKbaTief896azZLjKWeJZTGLaCWxgAmfagP)6azZMFTLc6Xqga8OwndPaWi9xhiB28RTuqpgYaGhRkcc0jKRmJX5))tBkKS4HM93wSeyjdaArik47VC5hCoObQyblb4GVm0ykamspNfcjtc8b9yidaEuRwizXcTXavkup7JA1mKcaJ0ZzHqYKaFqpgYaGhRcjlwOngOsH63pwzGW5Gdx1HhuptzuXJ9GdspevKk0ZEz0s(qoQvRiiqNqUYSgOY)))Pnfsw8qZ(BlwcSKbaTief89xU8doh4AvSGLaCWxgAmfagPNZcHKjb(GEmKbapQvlKSyH2yGkfQN9rTAgsbGr65SqizsGpOhdzaWJvHKfl0gduPq97hRmq4CWHR6WdQNPmQ4XEWbPhIksf6zVmAjFih1QveeOtixzMRv5)))0McjlEOz)TflbwYaGweIc((lx(bNduvvSGLaCWxgAmfagPNZcHKjb(GEmKbapQvlKSyH2yGkfQN9rTAgsbGr65SqizsGpOhdzaWJvHKfl0gduPq97hRmq4CWHR6WdQNPmQ4XEWbPhIksf6zVmAjFih1QveeOtixzMQQY)))Pnfsw8qZ(BlXj52sMcHjAtHKfp0S)2YrJ2vIkAAtHKfp0S)2IiaGTqYIh2GsNweIc(YDJbcPnfsw8qZ(BlIaa2cjlEydkDArik4ROjwu33HZ96fnbJJee074M2uizXdn7VTicaylKS4HnO0PfHOGVdN7vtBkKS4HM93webaSfsw8Wgu60IquWxYrtBkKS4HM93webaSfsw8Wgu60IquWxchI0McjlEOz)TfraaBHKfpSbLoTief89waacPnPnfsw8q7fn5Laf9KnOEMYOIhlQ7BJdN71tGIEYguptzuXJ3XTvHKfl0gduPq9SpwzjWsga0FDGS5YesyIX50McjlEO9IMW(BliNW0OseArDFtbGr6bsC0G6GEmKbapwBC4CVEGehnOoO3XTvYKaFqT9fkKS4HaM9X7AAtHKfp0Erty)TLQR4OtyXesBsBkKS4H2pCUx9lbk6jBq9mLrfpwu33gho3RNaf9KnOEMYOIhVJBRcjlwOngOsH6zFSYsGLmaO)6azZLjKWeJZPnfsw8q7ho3RM93wqoHPrLi0I6(McaJ0dK4Ob1b9yidaES24W5E9ajoAqDqVJBRKjb(GA7luizXdbm7J310McjlEO9dN7vZ(BRRdKnB(1wkOf19TXSimvXJvfbb6eYvM9YOk0McjlEO9dN7vZ(BRlquWKhpoOf19TXHZ96VarbtE84GEh30McjlEO9dN7vZ(BRlKRZbuIJf19nfagPFskGo5qfpgYaGhRnoCUx)fY15akXX742klbwYaG(RdKnxMqctmoN2uizXdTF4CVA2FBDbIcM84XbTOUVdN71FbIcM84Xb9qurQqRkw23a2FihAtHKfp0(HZ9Qz)T1fY15akXXI6(McaJ0pjfqNCOIhdzaWJ1HZ96VqUohqjoEiQivOvfl7Ba7pKJvwcSKba9xhiBUmHeMyCoTPqYIhA)W5E1S)2k5jQyRi6eHSzrDFho3RhIAEibbTtEIkEiQivOvfgPnPnByQXfrNudZao)aC0j1OiHJaaSrn1LAYjKA(nnuewjsnTHsLuZVjiOoHcGASuOMhsqqQP0uJBiQXi90McjlEO9KJ(Da48dWrNwu3xPHIWkrVeeuNqbydrnpKGGEmKbap0McjlEO9KJM93wdeQritv8yrDFzifagPx0emosqqpgYaGhRdN71lAcghjiO3X9F1QzifagPhbOcgPaS1UlyLApgYaGhRxekaBT7cwPhIksf6zZ)RwndnMcaJ0lAcghjiOhdzaWJ1gtbGr6raQGrkaBT7cwP2JHma45pTPqYIhAp5Oz)T1aW5h7RdKnlQ7ldPaWi9IMGXrcc6Xqga8yLHHZ96fnbJJee074wTAcNdoCvhErtW4ibb9qurQqpBUk))RwndnMcaJ0lAcghjiOhdzaWJvgUiua2A3fSspevKk0ZMRwnHZbhUQd)fHcWw7UGv6HOIuHE2Cv()N2uizXdTNC0S)26wqCa48Jf19LHuayKErtW4ibb9yidaESYWW5E9IMGXrcc6DCRwnHZbhUQdVOjyCKGGEiQivONnxL))vRMHgtbGr6fnbJJee0JHma4XkdxekaBT7cwPhIksf6zZvRMW5Gdx1H)IqbyRDxWk9qurQqpBUk))tBkKS4H2toA2FBjbb1jua2ebaSOUVmKcaJ0lAcghjiOhdzaWJvggo3Rx0emosqqVJB1QjCo4WvD4fnbJJee0drfPc9S5Q8)VA1m0ykamsVOjyCKGGEmKbapwz4IqbyRDxWk9qurQqpBUA1eohC4Qo8xekaBT7cwPhIksf6zZv5)FAtHKfp0EYrZ(Bl38S4Hf19D4CVErtW4ibb9oUvRUXuayKErtW4ibb9yidaESErOaS1UlyLEiQivONnxT6Suq7KBFkuvEvvvOnfsw8q7jhn7VTUiua2A3fSsAtHKfp0EYrZ(BlrtW4ibbTOUVeohC4Qo86ewmHEiQivONPcTPqYIhAp5Oz)TfkWCYgbOcgPaOnPnfsw8q7jCi(IcmNWWw7UycTOUVSeyjda6Voq2CzcjmX4CAtHKfp0EchIS)2s7ehewXJf19vizXcTXavkup71v0McjlEO9eoez)TLo5qfDclMqliSraODkWhm1VFSOUVsdfHvIEq9mLrfp2eECCQ0JHma4XAJhC4CVEq9mLrfp2eECCQ0742QqYIfAJbQuOE2hRmmCUxVo5qLbSIhe6DCRwndSeyjda6)Ll)GZbUwfRSeyjda6Voq2Czcjm5Q5))tBkKS4H2t4qK93w6Kdv0jSycTOUVdN71RtouzaR4bHEh3QvZWW5E9psoHWkES1jhQO9oUTYsGLmaO)xU8doh4AvSYsGLmaO)6azZLjKWKRM)N2uizXdTNWHi7VTiqrpzdQNPmQ4XI6(kKSyH2yGkfQN96kRSeyjda6Voq2CzcjmX4CAtHKfp0EchIS)2cuptzuXJ9GdslQ7BkamspNfcjtc8b9yidaESkKSyH2yGkfQF)yLLalzaq)1bYMltiHjlp3QIGaDc5kZETSk0McjlEO9eoez)TLo5qfDclMqlQ7llbwYaG(F5Yp4CGRvXklbwYaG(RdKnxMqctUAoTPqYIhApHdr2FBPDIdcR4H2uizXdTNWHi7VTiqrpzdQNPmQ4XI6(McaJ0F5qcEDa2QUIJ2JHma4XQqYIfAJbQuOE2hRSeyjda6Voq2CzcjmX4CAtHKfp0EchIS)26cefm5XJdArDFtbGr61OaR4Xw0AXbKEmKbap0McjlEO9eoez)Tfqyj2arpzrDFtbGr6N4P9KehpgYaGhRdN71pXt7jjoEikKK2uizXdTNWHi7VTiqrpzdQNPmQ4XI6(kKSyH2yGkfQN9XklbwYaG(RdKnxMqctmoN2K2uizXdT)waacFHCctJkrOf19vrqGoHCfvX1QyTXHZ961jeJNCYMFTrbMtEh30McjlEO93caqi7VTiqrpzdQNPmQ4XI6(McaJ0tGIEQIhBDYHkEmKbapwzjWsga0)lx(bNduvvOnfsw8q7VfaGq2FBbewInq0twu3xwcSKba9)YLFW5GgOIvwcSKba9xhiBUmHeMS8CAtHKfp0(BbaiK93wqoHPrLiK2uizXdT)waacz)T1fikyYJhhK2K2uizXdTN7gde(c5eMgvIqlQ7RIGaDc5kQYN5wZsbvLhYzZn3f]] )


end
