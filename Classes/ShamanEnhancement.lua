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
            id = function () return pvptalent.shamanism.enabled and 204361 or 2825 end,
            known = 2825,
            cast = 0,
            cooldown = 300,
            gcd = 'spell', -- Ugh.
            
            spend = 0.215,
            spendType = 'mana',
            
            startsCombat = false,

            handler = function ()
                applyBuff( 'bloodlust', 40 )
            end,

            copy = { 204361, 2825 }
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

                    if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                    if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                    if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end
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

                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end
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

                if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end

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

                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end

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

                if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end
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

            spend = function() return buff.hot_hand.up and 0 or 40 end,
            spendType = "maelstrom",

            startsCombat = true,

            handler = function ()
                removeBuff( 'hot_hand' )
                removeDebuff( "target", "primal_primer" )

                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'fire_of_the_twisting_nether' )
                    if buff.crash_lightning.up then applyBuff( 'shock_of_the_twisting_nether' ) end
                end

                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_fire" ) end
                if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
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

                if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end
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
            usable = function () return buff.lightning_shield.remains < 120 and ( time == 0 or buff.lightning_shield.stack == 1 ) end,
            handler = function () applyBuff( 'lightning_shield', nil, 1 ) end,
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

            toggle = "interrupts",
            interrupt = true,
            
            usable = function () return debuff.dispellable_magic.up, "requires dispellable magic aura" end,
            handler = function ()
                removeDebuff( "dispellable_magic" )
            end,
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
                if set_bonus.tier21_4pc > 0 then applyDebuff( 'target', 'exposed_elements', 4.5 ) end

                if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end

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
    
                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
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

            handler = function ()
                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'fire_of_the_twisting_nether' )
                end

                if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
            end,
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

                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
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


    spec:RegisterPack( "Enhancement", 20190123.1037, [[dSepnbqiLu5rkPKnjj(evimkIsNIOYQusXRuPAwiHBPKQSlQ6xGsdtLshJOyzQu8mQqnnqv5AuH02avvFJOQACGQOZruLADGQW8iQI7jP2hfXbjQkTqqLhQsmrLuQ4IkPQ2irvXhvsPQrQKsLojviYkvsMjvWorI(jOknuksTuLukpvIPckUkrvs5RuHOglrvs1Eb(RkgmPomQfRupMKjJuxgAZG8zK0OPsNw0RLKMTQUnr2TIFty4uuhNOkjlxQNtPPlCDkSDL47uKmEIQeNNkA9QKA(QKSFedKbadOqZbcO8MBLrEFRm34yVm36y59TYpOeonJGIzwvLPIGYWsiOS(JlpkucNaumZoFbtdGbuScJwHGIBeMTWdyHLAgUgBVsibRnLmEosXOAgkG1Msky3Vyd7gIxpACbwZTakF0clmj23CdSWCZnNIllXZz9hxEuOeoH3MskqzBKF4inGnOqZbcO8MBLrEFRm34yVm36y53rLbuyJWv0GsjLmEosXCPzOauCtAACaBqHgTkqzTi61FC5rHs4eeDXLL4HSATiA3imBHhWcl1mCn2ELqcwBkz8CKIr1muaRnLuWUFXg2neVE04cSMBbu(Ofwt34AJtAlSMETDkUSepN1FC5rHs4eEBkPiRwlIEfpgC7KOVXXuq03CRmYBIE9iAzUfE4y5hu(0gwamGIWmoydGbqPmayafC49J0a4afvNb2jdksm(2OfseT8q0Y4OeDfIosjKOLhIMQIguyvKIbuAHQ6odSbbiafjoNahEuiagaLYaGbuWH3psdGduuDgyNmOSoIEBab5HEwcdXq1a9gMbfwfPyafONLWqmunqqaO8gamGco8(rAaCGIQZa7KbLGFCcVlNVneTKhhE)inrxHOxhrVnGG8qTWg7MhAVHzIUcrVWDY7h9qgTZlUOQ6r(ahOWQifdOa1cBSBEObbiafO8FSbWaOugamGcRIumGI1yOXohQGco8(rAaCGaq5nayafC49J0a4afvNb2jdkb)4eEirRqiJ)yQCOTEC49J0eDfIMvrUGhCqPeTeTjeTmeDfIEH7K3p6HmANxCrv1ZfhafwfPyafvZw3ZNuDJjhQGaqPJbWak4W7hPbWbkQodStguc(Xj8wK7COEyRLn(WJdVFKguyvKIbuGEwcdXq1abbGs4dadOGdVFKgahOO6mWozqzDenFn2zGEZDkX)XCNsy7XH3pst0vi6GFCcVRioU8q7XH3pst0vi6TbeK3vehxEO9nYQauyvKIbuEEHppBDbbGshfadOGdVFKgahOO6mWozqHvrUGhCqPeTeTjeTmeDfIEH7K3p6HmANxCrv1ZfhafwfPyafvZw3ZNuDJjhQGaqj8dGbuWH3psdGduuDgyNmOiX4BJwir0Ydrl)3s0vi61r0BdiiVnACOgUhb0b5oC9gMbfwfPyaLwOQUZaBqaOu(bWak4W7hPbWbkQodStguc(Xj8QMTU5q9ydrl5XH3pst0vi6fUtE)OhEVyAH4pxCauyvKIbuunBDpFs1nMCOccaLWtamGco8(rAaCGIQZa7KbLfUtE)OhEVyAH4po4arxHOx4o59JEiJ25fxuv94GdGcRIumGYZl85zRliaukVbWakSksXakTqvDNb2Gco8(rAaCGaqPm3cGbuWH3psdGduuDgyNmOe8Jt4D58THOL84W7hPj6ke92acYd1cBSBEO9nkX5yjA5HOHpp8KOVt0uv0eDfIEH7K3p6HmANxCrv1J8boqHvrkgqbQf2y38qdcaLYidagqHvrkgqb6zjmedvdeuWH3psdGdeGaum3POZWjagaLYaGbuWH3psdGduuDgyNmOWQixWdoOuIwI2KAIwwIgEs0Rhrllrh8Jt4HeTcHm(JPYH26XH3pst0RHODmrlhrlhrxHOx4o59JEOgXRXEB0ZbhE)inrxHOx4o59JEiJ25fxuv9CXbqHvrkgqr1S198jv3yYHkiauEdagqbhE)inaoqr1zGDYGcFn2zGEZDkX)XCNsy7BEQs0Mut03q0viAACBab5n3Pe)hZDkHT3gSQkrxt0YClrxHOzvKl4bhukrlrxt0Yq0vi6fUtE)OhQr8AS3g9CWH3pst0vi6fUtE)OhYODEXfvvpo4aOWQifdO88cFE26ccaLogadOGdVFKgahOO6mWozqzDe92acYRA26E(KQBm5q1ByMORq0SkYf8GdkLOLOnHOLHORq0lCN8(rpKr78IlQQEU4aOWQifdOOA26E(KQBm5qfeakHpamGco8(rAaCGIQZa7KbL1r0BdiipKr78iGoC2EdZeDfIwIX3gTqIOnPMOV5wIUcrBnJ)FcUPIH1dz0opcOdN9HMLyQirBsnrllrldrFNOx4o59JEOgXRXEB0ZbhE)inrlhOWQifdOaz0opcOdNniau6OayafC49J0a4afvNb2jdkBdiipKr78iGoC2EdZeDfIUcrBnJ)FcUPIH1dz0opcOdN9HMLyQirlpeTSeTme9DIEH7K3p6HAeVg7TrphC49J0eTCGcRIumGcKr78iGoC2Gaqj8dGbuWH3psdGduuDgyNmOSnGG8nAfdpk8eIaL8nkX5yjA5PMOVHOxdrtvrdkSksXakHiqPJeBdSDccaLYpagqbhE)inaoqr1zGDYGcRICbp4GsjAjAtQjAhdkSksXakwJHg7COccaLWtamGco8(rAaCGIQZa7KbLGFCc)ZdT9tA0JdVFKMORq0RJO3gqq(NhA7N0O3WmrxHOvUCtfThOMvrkg(jAtiAz8YpOWQifdO0cv1DgydcaLYBamGco8(rAaCGIQZa7KbfzjA(ASZa9dhgn)hxULeJtpo8(rAIUcrVnGG8dhgn)hxULeJZdulSHVrjohlrlp1e9ne9AiAQkAIwoIUcrh8Jt4D58THOL84W7hPj6ke9c3jVF0dz0oV4IQQh5dCGcRIumGculSXU5HgeakL5wamGco8(rAaCGIQZa7KbfzjA(ASZa9dhgn)hxULeJtpo8(rAIUcrVnGG8dhgn)hxULeJZdu2OVrjohlrlp1e9ne9AiAQkAIwoqHvrkgqb6zjmedvdeeakLrgamGco8(rAaCGIQZa7KbfzjA(ASZa9dhgn)hxULeJtpo8(rAIUcrVnGG8dhgn)hxULeJZZWHrJ(gL4CSeT8ut03q0RHOPQOjA5i6keTeJVnAHerlpeT8FlOWQifdO0cv1DgydcqakqnIxJ92ONJs0iagaLYaGbuWH3psdGduyvKIbuEEHppBDbfvNb2jdk81yNb6n3Pe)hZDkHTV5PkrBsnrFdrxHOPXTbeK3CNs8Fm3Pe2EBWQQeDnrlZTeDfIEH7K3p6HmANxCrv1Jdoq0vi6fUtE)O)IdMwi(Jdoakb3uX4KqGciauEdagqbhE)inaoqr1zGDYGYc3jVF0dz0oV4IQQN1VakSksXaki3HlohR5SkccaLogadOGdVFKgahOWQifdOydrlzJoRIGIQZa7Kbfwf5cEWbLs0s0Mq0Yq0viA(ASZa9Fs1nMCOEuIH2idpo8(rAIUcrVoIMg3gqq(pP6gtoupkXqBKH3WmrxHOx4o59JEiJ25fxuv9ukGIYP6XtWnvmSakLbeakHpamGco8(rAaCGIQZa7KbLTbeK3gIwA35qfBVHzI(QRiAzjAwf5cEWbLs0s0Mq0Yq0vi6TbeKNkhUyNd1JneTK1ByMORq0lCN8(rpKr78IlQQEkfIwoqHvrkgqXgIwYgDwfbbGshfadOGdVFKgahOO6mWozqHvrUGhCqPeTeTj1eTJj6ke9c3jVF0dz0oV4IQQNloakSksXakQMTUNpP6gtoubbGs4hadOGdVFKgahOO6mWozqj4hNWlwWw5Ynv0JdVFKMORq0SkYf8GdkLOLORjAzi6ke9c3jVF0dz0oV4IQQhhGJORq0sm(2OfseTj1en8DlOWQifdO8jv3yYH6zl(aeakLFamGco8(rAaCGIQZa7Kbf(ASZa9M7uI)J5oLW238uLOnPMOVHORq0042acYBUtj(pM7ucBVnyvvI2eIw(j6ke9c3jVF0dz0oV4IQQhhCGORq0lCN8(r)fhmTq8hhCauyvKIbuEEHppBDbbGs4jagqbhE)inaoqr1zGDYGYc3jVF0dVxmTq8NsHORq0lCN8(rpKr78IlQQEkfIUcrVWDY7h9xCW0cXFkfqHvrkgqXgIwYgDwfbbGs5nagqbhE)inaoqr1zGDYGcnUnGG8M7uI)J5oLW2BdwvLORjAzULORq0lCN8(rpKr78IlQQECWbqHvrkgq55f(8S1feGaum3OsiT5aadGszaWak4W7hPbWbcaL3aGbuWH3psdGdeakDmagqbhE)inaoqaOe(aWak4W7hPbWbcaLokagqHvrkgqXSisXak4W7hPbWbcaLWpagqHvrkgq5tQUXKd1J1nXNguWH3psdGdeGauyRcadGszaWak4W7hPbWbkQodStguwhrVnGG8QMTUNpP6gtou9gMj6kenRICbp4GsjAjAtiAzi6ke9c3jVF0dz0oV4IQQNloakSksXakQMTUNpP6gtoubbGYBaWak4W7hPbWbkQodStguc(Xj8pp02pPrpo8(rAIUcrVoIEBab5FEOTFsJEdZeDfIw5Ynv0EGAwfPy4NOnHOLXl)GcRIumGsluv3zGniau6yamGcRIumGIPYH2gDwfbfC49J0a4abiaffTfadGszaWak4W7hPbBqr1zGDYGcFn2zGEEuOnA(pnAfdpk0JdVFKguyvKIbu2Vqq)g2aeakVbadOGdVFKgahOO6mWozqzH7K3p6vcXtlm1CSohfOWQifdOSX2ID1COccaLogadOGdVFKgahOO6mWozqzH7K3p6vcXtlm1CSohfOWQifdOSFHG(az0obbGs4dadOGdVFKgahOO6mWozqzH7K3p6vcXtlm1CSohfOWQifdOaLnUFHGgeakDuamGco8(rAaCGIQZa7KbLfUtE)OxjepTWuZX6CuGcRIumGcpk0gn)hf)piauc)ayafC49J0a4afvNb2jdkBdiipBv4qZJc9gMj6RUIOxhrh8Jt4zRchAEuOhhE)inrxHOHWM)J1C2z4BuIZXs0Mq0okrF1veDWnvm8rkHNqCOtKOLNAIg(VfuyvKIbumlIumGaqP8dGbuyvKIbuGWM)J1C2zak4W7hPbWbcaLWtamGco8(rAaCGIQZa7KbfLq80ctnEB0zv03OeNJLOnHOVfuyvKIbuyRchAEuiiaukVbWakSksXaki3H7bFucNGFqbhE)inaoqacqHgHyJpaWaOugamGcRIumGIPYH(yDrUbfC49J0a4abGYBaWak4W7hPbWbkl8BGGISeDWpoHNTkCO5rHEC49J0eDfIwwIEBab5zRchAEuO3WmrF1veTsiEAHPgpBv4qZJc9nkX5yjAtiAh9wIwoIwoI(QRiAzj61r0b)4eE2QWHMhf6XH3pst0viAzjAiS5)ynNDg(gL4CSeTjeTJs0xDfrReINwyQXdHn)hR5SZW3OeNJLOnHOD0BjA5iA5afwfPyaLfUtE)iOSW9zyjeuucXtlm1CSohfiau6yamGco8(rAaCGYc)giOiX4BJwir0Mut0Ys0b)4eEiJ25raD4S94W7hPj61q0Ys0WprFNOzvKIXBdrlzJoRIELWgeTCeTCGcRIumGYc3jVFeuw4(mSeckqgTZlUOQ6PuabGs4dadOGdVFKgahOSWVbcksm(2OfseTj1eTSeDWpoHhYODEeqhoBpo8(rAIEneTSen8t03jAwfPy8pVWNNTUELWgeTCeTCGcRIumGYc3jVFeuw4(mSeckqgTZlUOQ6XbhabGshfadOGdVFKgahOSWVbcksm(2OfseTj1eTSeDWpoHhYODEeqhoBpo8(rAIEneTSen8t03jAwfPy8QMTUNpP6gtou9kHniA5iA5afwfPyaLfUtE)iOSW9zyjeuGmANxCrv1ZfhabGs4hadOGdVFKgahOSWVbcksm(2OfseTj1eTSeDWpoHhYODEeqhoBpo8(rAIEneTSen8t03jAwfPy8qTWg7MhAVsydIwoIwoqHvrkgqzH7K3pcklCFgwcbfiJ25fxuv9iFGdeakLFamGco8(rAaCGYc)giOiX4BJwir0Mut0Ys0b)4eEiJ25raD4S94W7hPj61q0Ys0WprFNOzvKIXJChU4CSMZQOxjSbrlhrlhOWQifdOSWDY7hbLfUpdlHGcKr78IlQQEw)ciaucpbWak4W7hPbWbkl8BGGIeJVnAHerBsnrllrh8Jt4HmANhb0HZ2JdVFKMOxdrllrd)e9DIg(ULOLJOLduyvKIbuw4o59JGYc3NHLqqbYODEXfvvpoahiaukVbWak4W7hPbWbkl8BGGISenRICbp4GsjAjAtiAzi6RUIOLLOvcXtlm14)KQBm5q9SfF4BuIZXs0Mut03q0RHOPQOjA5iA5afwfPyaLfUtE)iOSW9zyjeuG3lMwiEqaOuMBbWak4W7hPbWbkl8BGGISe9c3jVF0dVxmTq8e9vxr0sm(2OfseTj1eTSeDWpoHxSGTYLBQOhhE)inrVgIwwIg(ULOVt0SksX4THOLSrNvrVsydIwoIwoIwoqHvrkgqzH7K3pcklCFgwcbf49IPfI)ukGaqPmYaGbuWH3psdGduw43abfzj6fUtE)OhEVyAH4j6RUIOLy8TrlKiAtQjAzj6GFCcVybBLl3urpo8(rAIEneTSen8DlrFNOzvKIX)8cFE266vcBq0Yr0Yr0YbkSksXaklCN8(rqzH7ZWsiOaVxmTq8hhCaeakL5gamGco8(rAaCGYc)giOilrVWDY7h9W7ftleprF1veTeJVnAHerBsnrllrh8Jt4flyRC5Mk6XH3pst0RHOLLOHVBj67enRIumEvZw3ZNuDJjhQELWgeTCeTCeTCGcRIumGYc3jVFeuw4(mSeckW7ftle)5IdGaqPmogadOGdVFKgahOSWVbckYs0lCN8(rp8EX0cXt0xDfrlX4BJwir0Mut0Ys0b)4eEXc2kxUPIEC49J0e9AiAzjA47wI(orZQifJhQf2y38q7vcBq0Yr0Yr0YbkSksXaklCN8(rqzH7ZWsiOaVxmTq8h5dCGaqPmWhagqbhE)inaoqzHFdeuyvKl4bhukrlrxt0Yq0xDfrlX4BJwir0Mut0Ys0SksX4vnBDpFs1nMCO6vcBq03jAwfPy8pVWNNTUELWgeTCGcRIumGYc3jVFeuw4(mSeckxCW0cXFCWbqaOughfadOGdVFKgahOSWVbckSkYf8GdkLOLORjAzi6RUIOLy8TrlKiAtQjAzjAwfPy8QMTUNpP6gtou9kHni67enRIumEBiAjB0zv0Re2GOLduyvKIbuw4o59JGYc3NHLqq5IdMwi(tPacaLYa)ayafC49J0a4aLf(nqqrwIo4hNW7kIJlp0EC49J0eDfIo4hNW7Y5Bdrl5XH3pst0viA(ASZa9M7uI)J5oLW2JdVFKMOLduyvKIbuw4o59JGYc3NHLqqbQr8AS3g9CWH3psdcaLYi)ayafC49J0a4aLf(nqqrwIEDe9c3jVF0d1iEn2BJEo4W7hPj6keTSeDWpoHFlmEASHsB4XH3pst0vi6GFCc)ZdT9tA0JdVFKMORq081yNb6TrJd1W9iGoi3HRhhE)inrlhrlhOWQifdOSWDY7hbLfUpdlHGsluvTFsJhC49J0GaqPmWtamGcRIumGcBeIdhbRQck4W7hPbWbcaLYiVbWakSksXakgw8KbkzbfC49J0a4abGYBUfadOGdVFKgahOWQifdOO4)pSksXC(0gGYN24mSeckcZ4GniauEJmayafC49J0a4afvNb2jdkBdiipBv4qZJc9gMbfwfPyaff))HvrkMZN2au(0gNHLqqHTkqaO8MBaWak4W7hPbWbkSksXakk()dRIumNpTbO8PnodlHGI5ofDgobbGYBCmagqbhE)inaoqr1zGDYGcRICbp4GsjAjA5HODmOWQifdOO4)pSksXC(0gGYN24mSecksCobo8OqqaO8g4dadOGdVFKgahOWQifdOO4)pSksXC(0gGYN24mSeckkAliauEJJcGbuWH3psdGduuDgyNmOSWDY7h9qnIxJ92ONdo8(rAqHvrkgqrX)FyvKI58PnaLpTXzyjeuGAeVg7TrphLOrqaO8g4hadOGdVFKgahOO6mWozqzDe9c3jVF0d1iEn2BJEo4W7hPbfwfPyaff))HvrkMZN2au(0gNHLqqHgHyJpokrJGaq5nYpagqbhE)inaoqr1zGDYGcRICbp4GsjAjAtQjAhdkSksXakk()dRIumNpTbO8PnodlHGIeNtGdpkeeakVbEcGbuWH3psdGduyvKIbuu8)hwfPyoFAdq5tBCgwcbfO8FSbbiafAeIn(4OencGbqPmayafC49J0a4afvNb2jdklCN8(rpKr78IlQQEw)cOWQifdOGChU4CSMZQiiauEdagqbhE)inaoqHvrkgqXgIwYgDwfbfvNb2jdkSkYf8GdkLOLOnHOLHORq081yNb6)KQBm5q9OedTrgEC49J0eDfIEDennUnGG8Fs1nMCOEuIH2idVHzIUcrVWDY7h9qgTZlUOQ6PuafLt1JNGBQyybukdiau6yamGco8(rAaCGIQZa7KbLTbeK3gIwA35qfBVHzI(QRiAzjAwf5cEWbLs0s0Mq0Yq0vi6TbeKNkhUyNd1JneTK1ByMORq0lCN8(rpKr78IlQQEkfIwoqHvrkgqXgIwYgDwfbbGs4dadOGdVFKgahOO6mWozqHvrUGhCqPeTeTj1eTJj6ke9c3jVF0dz0oV4IQQNloakSksXakQMTUNpP6gtoubbGshfadOGdVFKgahOO6mWozqj4hNWlwWw5Ynv0JdVFKMORq0SkYf8GdkLOLORjAzi6ke9c3jVF0dz0oV4IQQhhGJORq0sm(2OfseTj1en8DlOWQifdO8jv3yYH6zl(aeakHFamGco8(rAaCGIQZa7KbLfUtE)OhEVyAH4pLcrxHOx4o59JEiJ25fxuv9ukGcRIumGIneTKn6SkccqacqzbBBkgaL3CRmWtzUXX36Vrgh7yqXuCp5q1ckoYY31gLosuU2dpiAIggxKOtjZIoiAirt0ocZDk6mC6ii6gLxzKnst0wHes0SriK4aPjALlpurRNScgxKOHe)lmvoujA2OzlrBkSrI2WI0eDoeD4IenRIume9N2GO3gbrBkSrIEebrdjmgAIohIoCrIMPPfdrtZbVzlcpiRi61JOhomA(pUCljgNhOSrYkIE9i6HdJM)Jl3sIX5bQf2GSISYrw(U2O0rIY1E4brt0W4IeDkzw0brdjAI2rqJqSXhocIUr5vgzJ0eTviHenBecjoqAIw5Ydv06jRCihKOLbEcpiA51gRHzZIoqAIMvrkgI2rWgH4WrWQQocpzfzLJS8DTrPJeLR9WdIMOHXfj6uYSOdIgs0eTJaQr8AS3g9CuIgDeeDJYRmYgPjARqcjA2iesCG0eTYLhQO1tw5qoirld8GOxBOKybPjAjwEbEiVorRCrvvIw2reenVW5Z7hj6CiAuY45ifJCe96TEeTSYiViNNSISYrsYSOdKMOL5wIMvrkgI(tBy9KvGI1mQauEd87yqXClGYhbL1IOx)XLhfkHtq0fxwIhYQ1IODJWSfEalSuZW1y7vcjyTPKXZrkgvZqbS2usb7(fBy3q86rJlWAUfq5JwynDJRnoPTWA612P4Ys8Cw)XLhfkHt4TPKISATi6v8yWTtI(ghtbrFZTYiVj61JOL5w4HJLFYkYQ1IOxF5fuzeinrVrirJeTsiT5GO3i1CSEIw(QuO5Ws0JywpxULGmEIMvrkglrlM3PNSIvrkgR3CJkH0MJAONTvjRyvKIX6n3OsiT54EnSqcbnzfRIumwV5gvcPnh3RHLnOkHtWrkgYQ1IOldB26kcIU5KMO3gqqinrBdoSe9gHens0kH0MdIEJuZXs08qt0MBC9mlIihQeDAjAAXGEYkwfPySEZnQesBoUxdRDyZwxrCSbhwYkwfPySEZnQesBoUxdRzrKIHSIvrkgR3CJkH0MJ71W(jv3yYH6X6M4ttwrwTwe96lVGkJaPjACbBNeDKsirhUirZQq0eDAjAEHZN3p6jRyvKIXwBQCOpwxKBYQ1IOLVrGsMdIoeeT15Oi6Mvj)eTsiEAHPglrBQmCjA5RvHdnpkKOfnrlFWMFIUyo7mSuq0IMOnSirlgIwjepTWudrNqeTLxYHkrhUOerBQ8FIUrRXheDoeTnPojuQ4jiALq80ctneTPyBGKvSksXyVxd7c3jVFKIHLWALq80ctnhRZrrXc)gyTSb)4eE2QWHMhf6XH3psxr2TbeKNTkCO5rHEdZxDLsiEAHPgpBv4qZJc9nkX5ynXrVvo5U6kzxxWpoHNTkCO5rHEC49J0vKfcB(pwZzNHVrjohRjo6vxPeINwyQXdHn)hR5SZW3OeNJ1eh9w5KJSATi61ocIEebrByrIMjAjgFB0cP1tjSroujAENFgoj6eIOZGOnv(prV7COs0ofgeDii6BjAjgFB0cjIMhAIwXJcFIgYODs0ciIMZ2twXQifJ9EnSlCN8(rkgwcRHmANxCrv1tPqXc)gyTeJVnAHKj1Yg8Jt4HmANhb0HZ2JdVFKEnYc)3zvKIXBdrlzJoRIELWgYjhzfRIum271WUWDY7hPyyjSgYODEXfvvpo4afl8BG1sm(2OfsMulBWpoHhYODEeqhoBpo8(r61il8FNvrkg)Zl85zRRxjSHCYrwXQifJ9EnSlCN8(rkgwcRHmANxCrv1ZfhOyHFdSwIX3gTqYKAzd(Xj8qgTZJa6Wz7XH3psVgzH)7SksX4vnBDpFs1nMCO6vcBiNCKvSksXyVxd7c3jVFKIHLWAiJ25fxuv9iFGJIf(nWAjgFB0cjtQLn4hNWdz0opcOdNThhE)i9AKf(VZQifJhQf2y38q7vcBiNCKvSksXyVxd7c3jVFKIHLWAiJ25fxuv9S(fkw43aRLy8TrlKmPw2GFCcpKr78iGoC2EC49J0Rrw4)oRIumEK7WfNJ1Cwf9kHnKtoYkwfPyS3RHDH7K3psXWsynKr78IlQQECaokw43aRLy8TrlKmPw2GFCcpKr78iGoC2EC49J0Rrw4)o8DRCYrwTweT8ncuYCq0HGOnleprlX4BJwir0wbr7uy4i(NO3irZ7hj6qq0k2gent0qg)7C9mlmf2inr)jv3yYHkrVfFq0SLOTcXq0SLOZWryjAEHZN3ps0MYfhIgkP6g5qLOfds0b3uXWtwXQifJ9EnSlCN8(rkgwcRH3lMwiEkw43aRLLvrUGhCqPeTMiZvxjRsiEAHPg)NuDJjhQNT4dFJsCowtQVznuv0YjhzfRIum271WUWDY7hPyyjSgEVyAH4pLcfl8BG1YUWDY7h9W7ftle)vxjX4BJwizsTSb)4eEXc2kxUPIEC49J0Rrw4727SksX4THOLSrNvrVsyd5KtoYkwfPyS3RHDH7K3psXWsyn8EX0cXFCWbkw43aRLDH7K3p6H3lMwi(RUsIX3gTqYKAzd(Xj8IfSvUCtf94W7hPxJSW3T3zvKIX)8cFE266vcBiNCYrwXQifJ9EnSlCN8(rkgwcRH3lMwi(ZfhOyHFdSw2fUtE)OhEVyAH4V6kjgFB0cjtQLn4hNWlwWw5Ynv0JdVFKEnYcF3ENvrkgVQzR75tQUXKdvVsyd5KtoYkwfPyS3RHDH7K3psXWsyn8EX0cXFKpWrXc)gyTSlCN8(rp8EX0cXF1vsm(2OfsMulBWpoHxSGTYLBQOhhE)i9AKf(U9oRIumEOwyJDZdTxjSHCYjhz1Ar0Y3iqjZbrhcI2Sq8eTeJVnAHerdjAI(sZwxI2HKQBm5qLOtiIwY4J08JeDWnvmSen3irBUrloHNSIvrkg79Ayx4o59JumSewFXbtle)XbhOyHFdSMvrUGhCqPeT1YC1vsm(2OfsMullRIumEvZw3ZNuDJjhQELWg3zvKIX)8cFE266vcBihzfRIum271WUWDY7hPyyjS(IdMwi(tPqXc)gynRICbp4GsjARL5QRKy8TrlKmPwwwfPy8QMTUNpP6gtou9kHnUZQifJ3gIwYgDwf9kHnKJSIvrkg79Ayx4o59JumSewd1iEn2BJEo4W7hPPyHFdSw2GFCcVRioU8q7XH3psxj4hNW7Y5Bdrl5XH3psxHVg7mqV5oL4)yUtjS94W7hPLJSIvrkg79Ayx4o59JumSew3cvv7N04bhE)infl8BG1YUUfUtE)OhQr8AS3g9CWH3psxr2GFCc)wy80ydL2WJdVFKUsWpoH)5H2(jn6XH3psxHVg7mqVnACOgUhb0b5oC94W7hPLtoYkwfPyS3RHLncXHJGvvjRyvKIXEVgwdlEYaLSKvSksXyVxdRI))WQifZ5tBqXWsyTWmoytwXQifJ9EnSk()dRIumNpTbfdlH1SvrrcvVnGG8SvHdnpk0ByMSIvrkg79Ayv8)hwfPyoFAdkgwcRn3POZWjzfRIum271WQ4)pSksXC(0gumSewlX5e4WJcPiHQzvKl4bhukrR84yYkwfPyS3RHvX)FyvKI58PnOyyjSwrBjRyvKIXEVgwf))HvrkMZN2GIHLWAOgXRXEB0ZrjAKIeQEH7K3p6HAeVg7TrphC49J0KvSksXyVxdRI))WQifZ5tBqXWsynncXgFCuIgPiHQx3c3jVF0d1iEn2BJEo4W7hPjRyvKIXEVgwf))HvrkMZN2GIHLWAjoNahEuifjunRICbp4GsjAnP2XKvSksXyVxdRI))WQifZ5tBqXWsynu(p2KvKvSksXy9SvvRA26E(KQBm5qLIeQEDBdiiVQzR75tQUXKdvVH5kSkYf8GdkLO1ezQSWDY7h9qgTZlUOQ65IdKvSksXy9SvDVg2wOQUZaBksO6GFCc)ZdT9tA0JdVFKUY62gqq(NhA7N0O3WCfLl3ur7bQzvKIHFtKXl)KvSksXy9SvDVgwtLdTn6SkswrwTwe9f2genCVqq)g2GOL4XG)3jrNqeD4IeT89ASZajAyAodIw(ok0gn)e9AdTIHhfs0PLOn3OfNWtwXQifJ1ROT17xiOFdBqrcvZxJDgONhfAJM)tJwXWJc94W7hPjRyvKIX6v0271WUX2ID1COsrcvVWDY7h9kH4PfMAowNJISIvrkgRxrBVxd7(fc6dKr7KIeQEH7K3p6vcXtlm1CSohfzfRIumwVI2EVgwOSX9le0uKq1lCN8(rVsiEAHPMJ15OiRyvKIX6v0271WYJcTrZ)rX)trcvVWDY7h9kH4PfMAowNJISATiA5BeOK5GOdbrBDokI2PWOj61oMUq0MfrkgI2uz4s0mrReINwyQHcI2yE0Aj6Wfj6GBQyq0PLO5TWii6qq00j6jRyvKIX6v0271WAwePyOiHQ3gqqE2QWHMhf6nmF1vRl4hNWZwfo08Oqpo8(r6kqyZ)XAo7m8nkX5ynXrV6QGBQy4JucpH4qNO8ud)3swXQifJ1ROT3RHfcB(pwZzNbzfRIumwVI2EVgw2QWHMhfsrcvReINwyQXBJoRI(gL4CSMClzfRIumwVI2EVgwK7W9GpkHtWpzfzfRIumwpncXgFCuIgRrUdxCowZzvKIeQEH7K3p6HmANxCrv1Z6xiRyvKIX6Pri24JJs049AyTHOLSrNvrkuovpEcUPIHTwgksOAwf5cEWbLs0AImv4RXod0)jv3yYH6rjgAJm84W7hPRSoACBab5)KQBm5q9OedTrgEdZvw4o59JEiJ25fxuv9ukKvSksXy90ieB8XrjA8EnS2q0s2OZQifju92acYBdrlT7COIT3W8vxjlRICbp4GsjAnrMkBdiipvoCXohQhBiAjR3WCLfUtE)OhYODEXfvvpLICKvSksXy90ieB8XrjA8EnSQMTUNpP6gtouPiHQzvKl4bhukrRj1oUYc3jVF0dz0oV4IQQNloqwXQifJ1tJqSXhhLOX71W(jv3yYH6zl(GIeQo4hNWlwWw5Ynv0JdVFKUcRICbp4GsjARLPYc3jVF0dz0oV4IQQhhGRIeJVnAHKj1W3TKvSksXy90ieB8XrjA8EnS2q0s2OZQifju9c3jVF0dVxmTq8NsPYc3jVF0dz0oV4IQQNsHSISIvrkgRhk)h7ARXqJDoujRyvKIX6HY)X(EnSQMTUNpP6gtouPiHQd(Xj8qIwHqg)Xu5qB94W7hPRWQixWdoOuIwtKPYc3jVF0dz0oV4IQQNloqwXQifJ1dL)J99AyHEwcdXq1aPiHQd(Xj8wK7COEyRLn(WJdVFKMSIvrkgRhk)h771W(8cFE26srcvVo(ASZa9M7uI)J5oLW2JdVFKUsWpoH3vehxEO94W7hPRSnGG8UI44YdTVrwfKvSksXy9q5)yFVgwvZw3ZNuDJjhQuKq1SkYf8GdkLO1ezQSWDY7h9qgTZlUOQ65IdKvSksXy9q5)yFVg2wOQUZaBksOAjgFB0cj5r(VTY62gqqEB04qnCpcOdYD46nmtwXQifJ1dL)J99AyvnBDpFs1nMCOsrcvh8Jt4vnBDZH6XgIwYJdVFKUYc3jVF0dVxmTq8NloqwXQifJ1dL)J99AyFEHppBDPiHQx4o59JE49IPfI)4Gdvw4o59JEiJ25fxuv94GdKvSksXy9q5)yFVg2wOQUZaBYkwfPySEO8FSVxdlulSXU5HMIeQo4hNW7Y5Bdrl5XH3psxzBab5HAHn2np0(gL4CSYd85HN3PQORSWDY7h9qgTZlUOQ6r(ahzfRIumwpu(p23RHf6zjmedvdKSISIvrkgRhQr8AS3g9CuIgRFEHppBDPi4MkgNeQwILxGh042acYBUtj(pM7ucBVnyvvksOA(ASZa9M7uI)J5oLW238u1K6BQqJBdiiV5oL4)yUtjS92GvvRL52klCN8(rpKr78IlQQECWHklCN8(r)fhmTq8hhCGSIvrkgRhQr8AS3g9CuIgVxdlYD4IZXAoRIuKq1lCN8(rpKr78IlQQEw)czfRIumwpuJ41yVn65OenEVgwBiAjB0zvKcLt1JNGBQyyRLHIeQMvrUGhCqPeTMitf(ASZa9Fs1nMCOEuIH2idpo8(r6kRJg3gqq(pP6gtoupkXqBKH3WCLfUtE)OhYODEXfvvpLczfRIumwpuJ41yVn65OenEVgwBiAjB0zvKIeQEBab5THOL2DouX2By(QRKLvrUGhCqPeTMitLTbeKNkhUyNd1JneTK1ByUYc3jVF0dz0oV4IQQNsroYkwfPySEOgXRXEB0ZrjA8EnSQMTUNpP6gtouPiHQzvKl4bhukrRj1oUYc3jVF0dz0oV4IQQNloqwXQifJ1d1iEn2BJEokrJ3RH9tQUXKd1Zw8bfjuDWpoHxSGTYLBQOhhE)iDfwf5cEWbLs0wltLfUtE)OhYODEXfvvpoaxfjgFB0cjtQHVBjRyvKIX6HAeVg7TrphLOX71W(8cFE26srcvZxJDgO3CNs8Fm3Pe2(MNQMuFtfACBab5n3Pe)hZDkHT3gSQQjYFLfUtE)OhYODEXfvvpo4qLfUtE)O)IdMwi(JdoqwXQifJ1d1iEn2BJEokrJ3RH1gIwYgDwfPiHQx4o59JE49IPfI)ukvw4o59JEiJ25fxuv9ukvw4o59J(loyAH4pLczfRIumwpuJ41yVn65OenEVg2Nx4ZZwxksOAACBab5n3Pe)hZDkHT3gSQATm3wzH7K3p6HmANxCrv1JdoqwrwXQifJ1lX5e4WJcRHEwcdXq1aPiHQx32acYd9SegIHQb6nmtwXQifJ1lX5e4WJcVxdlulSXU5HMIeQo4hNW7Y5Bdrl5XH3psxzDBdiipulSXU5H2ByUYc3jVF0dz0oV4IQQh5dCKvKvSksXy9cZ4GDDluv3zGnfjuTeJVnAHK8iJJwjsjuEOQOjRiRyvKIX6n3POZWzTQzR75tQUXKdvksOAwf5cEWbLs0AsTSWZ1t2GFCcpKOviKXFmvo0wpo8(r614y5KRYc3jVF0d1iEn2BJEo4W7hPRSWDY7h9qgTZlUOQ65IdKvSksXy9M7u0z48EnSpVWNNTUuKq181yNb6n3Pe)hZDkHTV5PQj13uHg3gqqEZDkX)XCNsy7TbRQwlZTvyvKl4bhukrBTmvw4o59JEOgXRXEB0ZbhE)iDLfUtE)OhYODEXfvvpo4azfRIumwV5ofDgoVxdRQzR75tQUXKdvksO61TnGG8QMTUNpP6gtou9gMRWQixWdoOuIwtKPYc3jVF0dz0oV4IQQNloqwXQifJ1BUtrNHZ71Wcz0opcOdNnfju962gqqEiJ25raD4S9gMRiX4BJwizs9n3wXAg))eCtfdRhYODEeqho7dnlXurtQLvM7lCN8(rpuJ41yVn65GdVFKwoYkwfPySEZDk6mCEVgwiJ25raD4SPiHQ3gqqEiJ25raD4S9gMRuXAg))eCtfdRhYODEeqho7dnlXur5rwzUVWDY7h9qnIxJ92ONdo8(rA5iRyvKIX6n3POZW59AydrGshj2gy7KIeQEBab5B0kgEu4jebk5BuIZXkp13SgQkAYkwfPySEZDk6mCEVgwRXqJDouPiHQzvKl4bhukrRj1oMSIvrkgR3CNIodN3RHTfQQ7mWMIeQo4hNW)8qB)Kg94W7hPRSUTbeK)5H2(jn6nmxr5Ynv0EGAwfPy43ez8Ypz1Ar0oYz4s0uYHrZprV2LBjX4KcIgFCHdKOdxKOn3POZWjrlGiA8rjCc(jAocwv1s05q0IMgBIoeeTeNtW5q0Hls0BdiilrBkxCi6WfD6iAKO5TWii6qq0O8I5SrpzfRIumwV5ofDgoVxdlulSXU5HMIeQww(ASZa9dhgn)hxULeJtpo8(r6kBdii)WHrZ)XLBjX48a1cB4BuIZXkp13SgQkA5Qe8Jt4D58THOL84W7hPRSWDY7h9qgTZlUOQ6r(ahzfRIumwV5ofDgoVxdl0ZsyigQgifjuTS81yNb6homA(pUCljgNEC49J0v2gqq(HdJM)Jl3sIX5bkB03OeNJvEQVznuv0YrwXQifJ1BUtrNHZ71W2cv1DgytrcvllFn2zG(HdJM)Jl3sIXPhhE)iDLTbeKF4WO5)4YTKyCEgomA03OeNJvEQVznuv0YvrIX3gTqsEK)Bbbiaaa]] )


end
