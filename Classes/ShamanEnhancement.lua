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


    spec:RegisterPack( "Enhancement", 20181230.2133, [[dGel4aqiPqpsjO2ef6tsb0OakNcOAvsb6vuGzrbDlKKQDrv)sj1WOcDmKOLHK6zkHMgvkDnG02Oc03ucmoPGoNsqADijY8OsX9ayFiHdQeelKe6HuPAIijjDrKKYhrsICsKKuRukAMijbTtG4NubmuKewQuaEQunvLORIKe4RijH2Rk)LKgmPomQfRWJjmzL6YqBwrFgqJwkDAjVMemBq3gP2TWVjA4ujhhjjXYv1ZP00fDDkA7KOVtf04rsI68kjRhjrnFQO9J4JYB513CIhiu7iLnKsQx0rp1uU4IuUGRNRCHx3fluGbIxpyA86uTOLdbsJrEDx8kOK33YRBLMVaVEBMUSuP1RbwzR5WlK0RTfTjKZsgINN5ABrlwpGYX6XKP6Bu5AxVCwq0UEzHp1uVEj1uR2BzAouPArlhcKgJ0BlAX1hMfmPQJBC9nN4bc1oszdPK6fD0tnLlUiLGED2mBL)17fTjKZsgU)8mVEBT3yCJRVrR46lmrt1Iwoeingjr3BzAoinxyIUntxwQ061aRS1C4fs612I2eYzjdXZZCTTOfRhq5y9yYu9nQCTRxoliAxtfp2a4ABxtfna1EltZHkvlA5qG0yKEBrlinxyIMQkkq6b(e9IoAirtTJu2qIMQt0utjvArkVoSSP9wEDPlmW)wEGq5T86yWdiUpfVU4Re)IVonJqB(sAI2nenLGs0gj6SOrI2nenqX(6SilzC9xkuyuj(xE51P5ksm4qG3YdekVLxhdEaX9P41fFL4x81BKOhMZPFczAmLbqt0B666SilzC9jKPXuganXlpqO(wEDm4be3NIxx8vIFXxpzigPVLlOnLpThdEaXnrBKOBKOhMZPF(sBoEo2EtxeTrIwj)fpGOFA(RCVffkqnOxNfzjJRpFPnhph7lpqw8wEDm4be3NIxx8vIFXxFyoN(jKPXuganr)J0CfwI2neTB9nKOnGObk2xNfzjJRpHmnMYaOjE5bIBVLxhdEaX9P41fFL4x81tgIr6B5cAt5t7XGhqCt0gj6H5C6NV0MJNJT)rAUclr7gI2T(gs0gq0afBI2irRK)Ihq0pn)vU3IcfOg0RZISKX1NV0MJNJ9LxEDH8XB5bcL3YRJbpG4(u86IVs8l(6k5V4be9tZFL7TOqbQb96SilzCDK)SfdvRRsb8YdeQVLxhdEaX9P41fFL4x81zrwkrvmq6cTenfai6fVolYsgx3AgB8Ra4LhilElVog8aI7tXRZISKX1TP8PT5xkGxx8vIFXxNPY4xj6HfW2mQaOQqgBZk9yWdiUjAJeDJe9ghMZPhwaBZOcGQczSnR0B6IOns0SilLOkgiDHwIMcIMsI2irdgrpmNtVnLp94Rai(EtxeTtNenyeTs(lEarVd4oviLWf4irBKOvYFXdi6NM)k3BrHclckrdord(1fRequn5hiM2dekV8aXT3YRJbpG4(u86IVs8l(6dZ50Bt5tp(kaIV30fr70jrdgrpmNtpqoBXVcGQ2u(0wVPlI2irRK)Ihq07aUtfsjCbos0gjAL8x8aI(P5VY9wuOWIGs0GFDwKLmUUnLpTn)sb8YdeqVLxhdEaX9P41fFL4x81zrwkrvmq6cTenfai6fjAJeTs(lEar)08x5ElkuGAqVolYsgxx8STvfwaBZOcGxEG4G3YRJbpG4(u86IVs8l(6jdXi9sL4lA5hi6XGhqCt0gjAwKLsufdKUqlrdGOPKOns0k5V4be9tZFL7TOqb3ckrBKOPzeAZxst0uaGODRJxNfzjJRdlGTzubq1HeMxEGSGB51XGhqCFkEDXxj(fFDL8x8aIEhWDQqkHlWrI2irRK)Ihq0pn)vU3Icfwe0RZISKX1TP8PT5xkGxEG0WB51zrwY46wZyJFfaVog8aI7tXlpqwO3YRJbpG4(u86IVs8l(6jdXi9t5lWPju1HvSTEm4be3eTrIMfzPevXaPl0s0uq0us0gjAL8x8aI(P5VY9wuOa1GEDwKLmUU4zBRkSa2MrfaV8aHshVLxhdEaX9P41fFL4x81tgIr6Ti)vauLTw2eMEm4be3xNfzjJRpHmnMYaOjE5bcLuElVog8aI7tXRl(kXV4RNmeJ03kt1wo2Em4be3eTrIEyoN(wzQ2YX2)ilYRZISKX1HSswfY22lpqOK6B51XGhqCFkEDXxj(fFDwKLsufdKUqlrtbrtjrBKOvYFXdi6NM)k3BrHcud61zrwY46INTTQWcyBgva8YlV(gNSjmVLhiuElVolYsgx3HvSvTTi)xhdEaX9P4LhiuFlVog8aI7tXRRKHM41bJOBKOtgIr6NM)kv5uLR3JbpG4MOD6KObJOtgIr6NM)kv5uLR3JbpG4MOns00mcT5lPjAkiA3ckrdord(1zrwY46k5V4beVUs(vdMgV(08x5ElkuWTGE5bYI3YRJbpG4(u86kzOjEDWi6gj6KHyK(P5Vsvov569yWdiUjANojAWi6KHyK(P5Vsvov569yWdiUjAJennJqB(sAIMcIErqjAWjAWVolYsgxxj)fpG41vYVAW041NM)k3BrHclc6LhiU9wEDm4be3NIxxjdnXRdgr3irNmeJ0pn)vQYPkxVhdEaXnr70jrdgrNmeJ0pn)vQYPkxVhdEaXnrBKOPzeAZxst0uq0udkrdord(1zrwY46k5V4beVUs(vdMgV(08x5ElkuGAqV8ab0B51XGhqCFkEDLm0eVoyeDJeDYqmsVuj(Iw(bIEm4be3eTtNenlYsjQIbsxOLOPGOPKOD6KObJOtgIr6LkXx0Ypq0JbpG4MOns0SilLOkgiDHwIgartjrBKObJOfsjClDy4HfW2mQaO6qct)J0CfwIMcaen1eDds0afBI2PtIMMrOnFjnrtbr3qhjAWjAWjAWVolYsgxxj)fpG41vYVAW041Da3PcPe2qhV8aXbVLxhdEaX9P41vYqt86Gr0ns0jdXi9sL4lA5hi6XGhqCt0oDs0SilLOkgiDHwIMcIMsI2PtIgmIozigPxQeFrl)arpg8aIBI2irZISuIQyG0fAjAaenLeTrIgmIwiLWT0HHhwaBZOcGQdjm9psZvyjAkaq0ut0nirduSjANojAAgH28L0enfe9cCKObNObNOb)6SilzCDL8x8aIxxj)QbtJx3bCNkKs4cC8YdKfClVog8aI7tXRRKHM41bJOBKOtgIr6LkXx0Ypq0JbpG4MOD6KOzrwkrvmq6cTenfenLeTtNenyeDYqmsVuj(Iw(bIEm4be3eTrIMfzPevXaPl0s0aiAkjAJenyeTqkHBPddpSa2Mrfavhsy6FKMRWs0uaGOPMOBqIgOyt0oDs00mcT5lPjAkiAh0rIgCIgCIg8RZISKX1vYFXdiEDL8RgmnEDhWDQqkHoOJxEG0WB51zrwY46Szkv5mzHcxhdEaX9P4Lhil0B51zrwY46MwuTsK2EDm4be3NIxEGqPJ3YRJbpG4(u86SilzCDbdHQSilzOclBEDyzt1GPXRlDHb(xEGqjL3YRJbpG4(u86IVs8l(6dZ50ZwbgBoeO3011zrwY46cgcvzrwYqfw286WYMQbtJxNTIlpqOK6B51XGhqCFkEDwKLmUUGHqvwKLmuHLnVoSSPAW041D9L8RCL6WCoTxEGq5I3YRJbpG4(u86IVs8l(6SilLOkgiDHwI2ne9IxNfzjJRlyiuLfzjdvyzZRdlBQgmnEDAUIedoe4Lhiu62B51XGhqCFkEDwKLmUUGHqvwKLmuHLnVoSSPAW041fB7Lhiuc6T86yWdiUpfVolYsgxxWqOklYsgQWYMxhw2unyA86c5JxEGqPdElVog8aI7tXRl(kXV4RZISuIQyG0fAjAkaq0lEDwKLmUUGHqvwKLmuHLnVoSSPAW041P5ksm4qGxEGq5cULxhdEaX9P41zrwY46cgcvzrwYqfw286WYMQbtJxFwqi(xE51D9Oqsp48wEGq5T86yWdiUpfV8aH6B51XGhqCFkE5bYI3YRJbpG4(u8Yde3ElVog8aI7tXlpqa9wEDwKLmUUlzwY46yWdiUpfV8aXbVLxNfzjJRNYePvPzBI)QRJbpG4(u8YdKfClVolYsgxhwaBZOcGQ22cH7RJbpG4(u8YlVoBf3YdekVLxhdEaX9P41fFL4x81BKOhMZPx8STvfwaBZOcGEtxeTrIMfzPevXaPl0s0uq0us0gjAL8x8aI(P5VY9wuOa1GEDwKLmUU4zBRkSa2MrfaV8aH6B51XGhqCFkEDXxj(fF9KHyKEihBlS2OhdEaXnrBKOBKOhMZPhYX2cRn6nDr0gjArl)arR68zrwYGHenfenL(fCDwKLmU(lfkmQe)lpqw8wEDwKLmUUdRyBZVuaVog8aI7tXlV86IT9wEGq5T86yWdiUVX1fFL4x81zQm(vIEoeOnFgQ(OvgCiqpg8aI7RZISKX1hqPCdnT5LhiuFlVog8aI7tXRl(kXV4RdgrNmeJ0ZwbgBoeOhdEaXnrBKOhMZPNTcm2CiqVPlIgCI2PtIgmIozigPhHingjdvTUQVsRhdEaXnrBKON4ZqvRR6R0)inxHLOPGObLObNOD6KObJOBKOtgIr6zRaJnhc0JbpG4MOns0ns0jdXi9iePXizOQ1v9vA9yWdiUjAWVolYsgxFGVfFfQa4LhilElVog8aI7tXRl(kXV4RdgrNmeJ0ZwbgBoeOhdEaXnrBKObJOhMZPNTcm2CiqVPlI2PtIwiLWT0HHNTcm2Ciq)J0CfwIMcIguhjAWjAWjANojAWi6gj6KHyKE2kWyZHa9yWdiUjAJenye9eFgQADvFL(hP5kSenfenOeTtNeTqkHBPdd)eFgQADvFL(hP5kSenfenOos0Gt0GFDwKLmU(akLB1P5V6Yde3ElVog8aI7tXRl(kXV4RdgrNmeJ0ZwbgBoeOhdEaXnrBKObJOhMZPNTcm2CiqVPlI2PtIwiLWT0HHNTcm2Ciq)J0CfwIMcIguhjAWjAWjANojAWi6gj6KHyKE2kWyZHa9yWdiUjAJenye9eFgQADvFL(hP5kSenfenOeTtNeTqkHBPdd)eFgQADvFL(hP5kSenfenOos0Gt0GFDwKLmU(SECaLY9LhiGElVog8aI7tXRl(kXV4RdgrNmeJ0ZwbgBoeOhdEaXnrBKObJOhMZPNTcm2CiqVPlI2PtIwiLWT0HHNTcm2Ciq)J0CfwIMcIguhjAWjAWjANojAWi6gj6KHyKE2kWyZHa9yWdiUjAJenye9eFgQADvFL(hP5kSenfenOeTtNeTqkHBPdd)eFgQADvFL(hP5kSenfenOos0Gt0GFDwKLmUohc0MpdvfmeE5bIdElVog8aI7tXRl(kXV4RpmNtpBfyS5qGEtxeTtNeDJeDYqmspBfyS5qGEm4be3eTrIEIpdvTUQVs)J0CfwIMcIguI2PtIolAunLQ7cjA3aGODqhVolYsgx3LmlzC5bYcULxNfzjJRpXNHQwx1x51XGhqCFkE5bsdVLxhdEaX9P41fFL4x81fsjClDy4T5xkG(hP5kSenfeTJxNfzjJRZwbgBoe4Lhil0B51zrwY46i)zRkcrAmsgEDm4be3NIxE51NfeI)T8aHYB51XGhqCFkEDXxj(fFDAgH28L0eTBi6f4irBKOBKOhMZP3MpgaZwv5uf5pB9MUUolYsgx)LcfgvI)LhiuFlVog8aI7tXRl(kXV4RNmeJ0lE22wbqvBkFApg8aIBI2irRK)Ihq07aUtfsj0bD86SilzCDXZ2wvybSnJkaE5bYI3YRJbpG4(u86IVs8l(6k5V4be9oG7uHucBOJeTrIwj)fpGOFA(RCVffk4wqVolYsgxhYkzviBBV8aXT3YRZISKX1FPqHrL4FDm4be3NIxEGa6T86SilzC9jKPXuganXRJbpG4(u8YlVURVKFLRuhMZP9wEGq5T86yWdiUpfVU4Re)IVEJe9WCo9INTTQWcyBgva0B6IOns0SilLOkgiDHwIMcIMsI2irRK)Ihq0pn)vU3IcfOg0RZISKX1fpBBvHfW2mQa4LhiuFlVog8aI7tXRl(kXV4RNmeJ0d5yBH1g9yWdiUjAJeDJe9WCo9qo2wyTrVPlI2irlA5hiAvNplYsgmKOPGOP0VGRZISKX1FPqHrL4F5bYI3YRJbpG4(u86IVs8l(6ns0zjuOcGeTrIMMrOnFjnrtbaIMAhVolYsgxFA(RuLtvU(lpqC7T86yWdiUpfVU4Re)IVEYqmsFRmvB5y7XGhqCt0gj6gj6H5C6NqMgtza0e9MUUolYsgxFczAmLbqt8YdeqVLxhdEaX9P41fFL4x81tgIr6B5cAt5t7XGhqCt0gj6gj6H5C6NV0MJNJT30frBKOvYFXdi6NM)k3BrHcudkrBKObJOzrwkrvmq6cTeTBi6fjANojAWiAMkJFLOp408zOAl)0YyLhdEaXnrBKOhMZPp408zOAl)0YyL68L20)inxHLODdaIMAIUbjAGInrdord(1zrwY46ZxAZXZX(Ydeh8wEDm4be3NIxx8vIFXxpzigPVvMQTCS9yWdiUjAJe9WCo9titJPmaAI(hP5kSeTBiA36BirBarduSVolYsgxFczAmLbqt8YdKfClVog8aI7tXRl(kXV4RNmeJ03Yf0MYN2JbpG4MOns0dZ50pFPnhphB)J0CfwI2neTB9nKOnGObk2eTrIwj)fpGOFA(RCVffkqnOeTrIgmIMfzPevXaPl0s0UHOxKOD6KObJOzQm(vI(GtZNHQT8tlJvEm4be3eTrIEyoN(GtZNHQT8tlJvQZxAt)J0CfwI2naiAQj6gKObk2en4en4xNfzjJRpFPnhph7lpqA4T86yWdiUpfVU4Re)IV(WCo9pALbhcunLjs7FKMRWs0Ubartnr3GenqX(6SilzC9uMiTknBt8xD5LxEDL4BlzCGqTJu2qkPMsh9utTBxOx3H8hva0EDQIlKgaiu1GqvIkr0e9YwKOlAxYpj6P8j6gORVKFLRuhMZPTbs0psvXSECt0wjns0SzkP5e3eTOLdGO1tAUSfj6PecLoScGenB(SLODi(irBAXnrxbrNTirZISKbrdlBs0dZKODi(irhYKONsZyt0vq0zls08EldIEZjpylsLinjAQorhCA(muTLFAzSsD(sBsAsAsvCH0aaHQgeQsujIMOx2IeDr7s(jrpLpr3a34KnHzdKOFKQIz94MOTsAKOzZusZjUjArlharRN0KQWkqIUHujIMQGWA6YL8tCt0Silzq0nq2mLQCMSqHgON0K0KQM2L8tCt0luIMfzjdIgw206jnVURxoliE9fMOPArlhcKgJKO7TmnhKMlmr3MPllvA9AGv2Ao8cj9ABrBc5SKH45zU2w0I1dOCSEmzQ(gvU21lNfeTRPIhBaCTTRPIgGAVLP5qLQfTCiqAmsVTOfKMlmrtvffi9aFIErhnKOP2rkBirt1jAQPKkTiLKMKMlmrt1OkJcZe3e9aNYhjAHKEWjrpqGvy9e9criqxPLOdzq1B5NEAcjAwKLmSeTmGR8KMSilzy9UEuiPhCcyczRcKMSilzy9UEuiPhCAaG1tPCtAYISKH176rHKEWPbawZMaPXi5SKbP5ct09GDzBLjr)CTj6H5CIBI2MCAj6boLps0cj9GtIEGaRWs0CSjAxps1DjZScGeDzj6TmqpPjlYsgwVRhfs6bNgayTnyx2wzQAtoTKMSilzy9UEuiPhCAaG1UKzjdstwKLmSExpkK0donaW6uMiTknBt8xrAYISKH176rHKEWPbawdlGTzubqvBBHWnPjP5ct0unQYOWmXnrJkXFfrNfns0zls0SiLprxwIMvYfKhq0tAYISKHfGdRyRABr(jnzrwYWAaG1k5V4benmyAeW08x5ElkuWTGAOsgAIaaRXKHyK(P5Vsvov569yWdiUD6eSKHyK(P5Vsvov569yWdiUnsZi0MVKMc3ck4GtAYISKH1aaRvYFXdiAyW0iGP5VY9wuOWIGAOsgAIaaRXKHyK(P5Vsvov569yWdiUD6eSKHyK(P5Vsvov569yWdiUnsZi0MVKMIfbfCWjnzrwYWAaG1k5V4benmyAeW08x5ElkuGAqnujdnraG1yYqms)08xPkNQC9Em4be3oDcwYqms)08xPkNQC9Em4be3gPzeAZxstb1Gco4KMSilzynaWAL8x8aIggmncWbCNkKsydD0qLm0ebawJjdXi9sL4lA5hi6XGhqC70jlYsjQIbsxOLckD6eSKHyKEPs8fT8de9yWdiUnYISuIQyG0fAbqPrWesjClDy4HfW2mQaO6qct)J0CfwkaqDdcuSD6KMrOnFjnfn0rWbhCstwKLmSgayTs(lEarddMgb4aUtfsjCboAOsgAIaaRXKHyKEPs8fT8de9yWdiUD6KfzPevXaPl0sbLoDcwYqmsVuj(Iw(bIEm4be3gzrwkrvmq6cTaO0iycPeULom8WcyBgvauDiHP)rAUclfaOUbbk2oDsZi0MVKMIf4i4GdoPjlYsgwdaSwj)fpGOHbtJaCa3PcPe6GoAOsgAIaaRXKHyKEPs8fT8de9yWdiUD6KfzPevXaPl0sbLoDcwYqmsVuj(Iw(bIEm4be3gzrwkrvmq6cTaO0iycPeULom8WcyBgvauDiHP)rAUclfaOUbbk2oDsZi0MVKMch0rWbhCstwKLmSgaynBMsvotwOaPjlYsgwdaS20IQvI0wstwKLmSgayTGHqvwKLmuHLnnmyAeG0fg4tAYISKH1aaRfmeQYISKHkSSPHbtJayRWWAcyyoNE2kWyZHa9MUinzrwYWAaG1cgcvzrwYqfw20WGPraU(s(vUsDyoNwstwKLmSgayTGHqvwKLmuHLnnmyAeanxrIbhc0WAcGfzPevXaPl06MfjnzrwYWAaG1cgcvzrwYqfw20WGPraITL0KfzjdRbawlyiuLfzjdvyztddMgbiKpsAYISKH1aaRfmeQYISKHkSSPHbtJaO5ksm4qGgwtaSilLOkgiDHwkaSiPjlYsgwdaSwWqOklYsgQWYMggmncywqi(KMKMSilzy9Svaq8STvfwaBZOcGgwtanomNtV4zBRkSa2Mrfa9MUmYISuIQyG0fAPGsJk5V4be9tZFL7TOqbQbL0KfzjdRNTcdaS(LcfgvIVH1eqYqmspKJTfwB0JbpG42yJdZ50d5yBH1g9MUmkA5hiAvNplYsgmKck9lG0KfzjdRNTcdaS2HvST5xkGKMKMlmr7oBtIwrOuUHM2KOP5WKHWveDnj6Sfj6fcvg)krIE5Zvs0lKqG28zir3aqRm4qGeDzjAxpAXi9KMSilzy9ITfWakLBOPnnSMayQm(vIEoeOnFgQ(OvgCiqpg8aIBstwKLmSEX2AaG1d8T4RqfanSMaalzigPNTcm2Ciqpg8aIBJdZ50ZwbgBoeO30f4oDcwYqmspcrAmsgQADvFLwpg8aIBJt8zOQ1v9v6FKMRWsbOG70jynMmeJ0ZwbgBoeOhdEaXTXgtgIr6risJrYqvRR6R06XGhqCdoPjlYsgwVyBnaW6buk3QtZFLH1eayjdXi9SvGXMdb6XGhqCBeSH5C6zRaJnhc0B6YPtHuc3shgE2kWyZHa9psZvyPauhbhCNobRXKHyKE2kWyZHa9yWdiUnc2eFgQADvFL(hP5kSuaQtNcPeULom8t8zOQ1v9v6FKMRWsbOoco4KMSilzy9IT1aaRN1JdOuUnSMaalzigPNTcm2Ciqpg8aIBJGnmNtpBfyS5qGEtxoDkKs4w6WWZwbgBoeO)rAUclfG6i4G70jynMmeJ0ZwbgBoeOhdEaXTrWM4ZqvRR6R0)inxHLcqD6uiLWT0HHFIpdvTUQVs)J0Cfwka1rWbN0KfzjdRxSTgaynhc0MpdvfmeAynbawYqmspBfyS5qGEm4be3gbByoNE2kWyZHa9MUC6uiLWT0HHNTcm2Ciq)J0Cfwka1rWb3PtWAmzigPNTcm2Ciqpg8aIBJGnXNHQwx1xP)rAUclfG60PqkHBPdd)eFgQADvFL(hP5kSuaQJGdoPjlYsgwVyBnaWAxYSKHH1eWWCo9SvGXMdb6nD50zJjdXi9SvGXMdb6XGhqCBCIpdvTUQVs)J0Cfwka1PZSOr1uQUl0naCqhjnzrwYW6fBRbawpXNHQwx1xjPjlYsgwVyBnaWA2kWyZHanSMaesjClDy4T5xkG(hP5kSu4iPjlYsgwVyBnaWAK)SvfHingjdjnjnzrwYW6fYhbG8NTyOADvkGgwtak5V4be9tZFL7TOqbQbL0KfzjdRxiF0aaRTMXg)kaAynbWISuIQyG0fAPaWIKMSilzy9c5JgayTnLpTn)sb0qXkbevt(bIPfaLgwtamvg)krpSa2MrfavfYyBwPhdEaXTXg34WCo9WcyBgvauviJTzLEtxgzrwkrvmq6cTuqPrWgMZP3MYNE8vaeFVPlNobtj)fpGO3bCNkKs4cC0Os(lEar)08x5ElkuyrqbhCstwKLmSEH8rdaS2MYN2MFPaAynbmmNtVnLp94Rai(EtxoDc2WCo9a5Sf)kaQAt5tB9MUmQK)Ihq07aUtfsjCboAuj)fpGOFA(RCVffkSiOGtAYISKH1lKpAaG1INTTQWcyBgva0WAcGfzPevXaPl0sbGfnQK)Ihq0pn)vU3IcfOgustwKLmSEH8rdaSgwaBZOcGQdjmnSMasgIr6LkXx0Ypq0JbpG42ilYsjQIbsxOfaLgvYFXdi6NM)k3BrHcUfuJ0mcT5lPPaGBDK0KfzjdRxiF0aaRTP8PT5xkGgwtak5V4be9oG7uHucxGJgvYFXdi6NM)k3BrHclckPjlYsgwVq(ObawBnJn(vaK0KfzjdRxiF0aaRfpBBvHfW2mQaOH1eqYqms)u(cCAcvDyfBRhdEaXTrwKLsufdKUqlfuAuj)fpGOFA(RCVffkqnOKMSilzy9c5Jgay9eY0ykdGMOH1eqYqmsVf5VcGQS1YMW0JbpG4M0KfzjdRxiF0aaRHSswfY2wdRjGKHyK(wzQ2YX2JbpG424WCo9TYuTLJT)rwKKMSilzy9c5JgayT4zBRkSa2MrfanSMayrwkrvmq6cTuqPrL8x8aI(P5VY9wuOa1GsAsAYISKH1plieFaVuOWOs8nSMaOzeAZxs7Mf4OXghMZP3MpgaZwv5uf5pB9MUinzrwYW6NfeIVbawlE22QclGTzubqdRjGKHyKEXZ22kaQAt5t7XGhqCBuj)fpGO3bCNkKsOd6iPjlYsgw)SGq8naWAiRKvHST1WAcqj)fpGO3bCNkKsydD0Os(lEar)08x5ElkuWTGsAYISKH1plieFdaS(LcfgvIpPjlYsgw)SGq8naW6jKPXuganrststwKLmSEAUIedoeiGjKPXuganrdRjGghMZPFczAmLbqt0B6I0KfzjdRNMRiXGdbAaG1ZxAZXZX2WAcizigPVLlOnLpThdEaXTXghMZPF(sBoEo2EtxgvYFXdi6NM)k3BrHcudkPjlYsgwpnxrIbhc0aaRNqMgtza0enSMagMZPFczAmLbqt0)inxH1nU13qdak2KMSilzy90CfjgCiqdaSE(sBoEo2gwtajdXi9TCbTP8P9yWdiUnomNt)8L2C8CS9psZvyDJB9n0aGITrL8x8aI(P5VY9wuOa1GsAsAYISKH1lDHb(aEPqHrL4BynbqZi0MVK2nucQXSOr3auSjnjnzrwYW6D9L8RCL6WCoTaepBBvHfW2mQaOH1eqJdZ50lE22QclGTzubqVPlJSilLOkgiDHwkO0Os(lEar)08x5ElkuGAqjnzrwYW6D9L8RCL6WCoTgay9lfkmQeFdRjGKHyKEihBlS2OhdEaXTXghMZPhYX2cRn6nDzu0Ypq0QoFwKLmyifu6xaPjlYsgwVRVKFLRuhMZP1aaRNM)kv5uLR3WAcOXSekubqJ0mcT5lPPaa1osAYISKH176l5x5k1H5CAnaW6jKPXuganrdRjGKHyK(wzQ2YX2JbpG42yJdZ50pHmnMYaOj6nDrAYISKH176l5x5k1H5CAnaW65lT545yBynbKmeJ03Yf0MYN2JbpG42yJdZ50pFPnhphBVPlJk5V4be9tZFL7TOqbQb1iySilLOkgiDHw3SOtNGXuz8Re9bNMpdvB5NwgR8yWdiUnomNtFWP5Zq1w(PLXk15lTP)rAUcRBaqDdcuSbhCstwKLmSExFj)kxPomNtRbawpHmnMYaOjAynbKmeJ03kt1wo2Em4be3ghMZPFczAmLbqt0)inxH1nU13qdak2KMSilzy9U(s(vUsDyoNwdaSE(sBoEo2gwtajdXi9TCbTP8P9yWdiUnomNt)8L2C8CS9psZvyDJB9n0aGITrL8x8aI(P5VY9wuOa1GAemwKLsufdKUqRBw0PtWyQm(vI(GtZNHQT8tlJvEm4be3ghMZPp408zOAl)0YyL68L20)inxH1naOUbbk2GdoPjlYsgwVRVKFLRuhMZP1aaRtzI0Q0SnXFLH1eWWCo9pALbhcunLjs7FKMRW6gau3Gaf7RBDHIdeQDWfV8Y7aa]] )


end
