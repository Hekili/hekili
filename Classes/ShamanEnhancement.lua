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

            stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
            interval = 'mainhand_speed',
            value = 5
        },

        offhand = {
            last = function ()
                local swing = state.swings.offhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
            end,

            stop = function () return state.time == 0 or state.swings.offhand == 0 end,
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
                        if cast + duration > expires then
                            expires = cast + duration
                            remains = expires - now
                        end
                    end
                end

                local up = buff.resonance_totem.up and remains > 0

                local tm = buff.totem_mastery
                tm.name = class.abilities.totem_mastery.name

                if remains > 0 and up then
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


    local hadTotem = false
    local hadTotemAura = false

    spec:RegisterHook( "reset_precast", function ()
        for i = 1, 5 do
            local hasTotem, name = GetTotemInfo( i )

            if name == class.abilities.totem_mastery.name and hasTotem ~= up then
                ScrapeUnitAuras( "player" )
                return
            end
        end

        local hasTotemAura = FindUnitBuffByID( "player", 262417 ) ~= nil
        if hasTotemAura ~= hadTotemAura then ScrapeUnitAuras( "player" ) end
    end )


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

            readyTime = function () return buff.totem_mastery.remains - 15 end,

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

            debuff = "casting",
            readyTime = state.timeToInterrupt,

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


    spec:RegisterPack( "Enhancement", 20190123.1930, [[dWeJpbqivs5reLQnrf9jQGQrru1PiQSkLu6vaXSqsUfvOAxu1VasddO0XqsTmvkEMsQmnIs6AubzBeL4BuHY4ujvDoLu06ikfZtLsDpLyFuehuLuzHavpuLyIkPQOlQKQSrLu4JkPQIrsukLoPsQkTsQuZKI0nvsvHDsu8tvkzOubwkvq5PsmvvQUkrPu8vLuv1yvsvL2lO)QIbtQdJAXk1JjzYi1LH2mGpJeJwsoTOxRKmBvDBISBf)MWWPOoorPuTCPEoLMUW1PW2LuFNkKXtuk58ujRxLK5duSFedPgEhwO5aHYCdyPEnbl13Sop1R5nR5nYcSeUmJWIzwTIPGWYWsiSSEtfpkucNawmZUEbtdVdlwHrRqyPkcZwzdOGsjJkJTxjKa1MsgphPyundeGAtjfO7xSbDdWoonwdQ5waKpAb9EI9n3a69BU5uQyjEoR3uXJcLWj82usblBJ8J13bUHfAoqOm3awQxtWs9nRZt9AEZAc2RhwyJOs0WsjLmEosXCPzGawQsAACGByHgTkyr2j61BQ4rHs4eeDPIL4H4w2j6QimBLnGckLmQm2ELqcuBkz8CKIr1mqaQnLuGUFXg0na740ynOMBbq(Ofuh0OdJtAlOoWHDkvSepN1BQ4rHs4eEBkPiULDI2npgC7IOVzDur03awQxtI2XjAQxtzZ6alXnXTSt0xQ4HcALne3Yor74e91rtJ0eT5gvcPnhe9DrGse96d2gy7YtCl7eTJt0omeOrBfrVgTWg7MhAqxJNLWqmumqIohI(6U16r0aIMOxJgXRWgCJEi6Tr(0Ey5tByH3HfHzCWgEhkd1W7Wco8(rAi4WIQZa7KHfjgFB0cjI(2en1oer7KOJucj6Bt0uu0WcRIumWsluR2zGnmGbSiX5e4WJcH3HYqn8oSGdVFKgcoSO6mWozy5Ae92aaWd8SegIHIb6nmdlSksXalaplHHyOyGWakZnW7Wco8(rAi4WIQZa7KHLGFCcFfNVneTKhhE)inr7KOVgrVnaa8aTWg7MhAVHzI2jrxZDY7h9agTRlvOA1znahwyvKIbwaAHn2np0WagWcqJ4vyVn65OencVdLHA4DybhE)ineCyHvrkgy55A(8STcwuDgyNmSWxHDgO3CNs8Fm3Pe2(MNveTjle9neTtIMg3gaaEZDkX)XCNsy7TbRwr0len1GLODs01CN8(rpGr76sfQwDm1uI2jrxZDY7h9xm1bcXFm1uyj4McgNeawGbuMBG3HfC49J0qWHfvNb2jdl1CN8(rpGr76sfQwDwVcSWQifdSGChv4CSMZvimGYSo4DybhE)ineCyHvrkgyXgIwYgDUcHfvNb2jdlSkYA8GdkLOLOnHOPMODs08vyNb6)Ksvm5q5OedTrgEC49J0eTtI(AennUnaa8FsPkMCOCuIH2idVHzI2jrxZDY7h9agTRlvOA1PuGfLl1JNGBkyyHYqnmGYiRW7Wco8(rAi4WIQZa7KHLTbaG3gIwA35qbBVHzIgmGHOLNOzvK14bhukrlrBcrtnr7KO3gaaEkCuHDouo2q0swVHzI2jrxZDY7h9agTRlvOA1PuiA5GfwfPyGfBiAjB05kegqzCi4DybhE)ineCyr1zGDYWcRISgp4GsjAjAtwi61r0oj6AUtE)OhWODDPcvRoxmfwyvKIbwunBRoFsPkMCOadOmYc8oSGdVFKgcoSO6mWozyj4hNWlQXwvXnf0JdVFKMODs0SkYA8GdkLOLOxiAQjANeDn3jVF0dy0UUuHQvhtbNODs0sm(2OfseTjleTScwyHvrkgy5tkvXKdLZw8bmGY4yW7Wco8(rAi4WIQZa7KHf(kSZa9M7uI)J5oLW238SIOnzHOVHODs0042aaWBUtj(pM7ucBVny1kI2eI2XiANeDn3jVF0dy0UUuHQvhtnLODs01CN8(r)ftDGq8htnfwyvKIbwEUMppBRGbuMRhEhwWH3psdbhwuDgyNmSuZDY7h936IdeI)ukeTtIUM7K3p6bmAxxQq1QtPq0oj6AUtE)O)IPoqi(tPalSksXal2q0s2OZvimGYSMW7Wco8(rAi4WIQZa7KHfACBaa4n3Pe)hZDkHT3gSAfrVq0udwI2jrxZDY7h9agTRlvOA1XutHfwfPyGLNR5ZZ2kyadybi)hB4DOmudVdlSksXalwJHg7COal4W7hPHGddOm3aVdl4W7hPHGdlQodStgwc(Xj8aIwHag)Xr5qB94W7hPjANenRISgp4GsjAjAtiAQjANeDn3jVF0dy0UUuHQvNlMclSksXalQMTvNpPuftouGbuM1bVdl4W7hPHGdlQodStgwc(Xj8wK7COCyRLn(WJdVFKgwyvKIbwaEwcdXqXaHbugzfEhwWH3psdbhwuDgyNmSCnIMVc7mqV5oL4)yUtjS94W7hPjANeDWpoHVseNkEO94W7hPjANe92aaWxjItfp0(gzvalSksXalpxZNNTvWakJdbVdl4W7hPHGdlQodStgwyvK14bhukrlrBcrtnr7KOR5o59JEaJ21LkuT6CXuyHvrkgyr1ST68jLQyYHcmGYilW7Wco8(rAi4WIQZa7KHfjgFB0cjI(2eTJbwI2jrFnIEBaa4TrJdLO6iaoi3rL3WmSWQifdS0c1QDgyddOmog8oSGdVFKgcoSO6mWozyj4hNWRA2wLdLJneTKhhE)inr7KOR5o59J(BDXbcXFUykSWQifdSOA2wD(Ksvm5qbgqzUE4DybhE)ineCyr1zGDYWsn3jVF0FRloqi(JPMs0oj6AUtE)OhWODDPcvRoMAkSWQifdS8CnFE2wbdOmRj8oSWQifdS0c1QDgydl4W7hPHGddOmudw4DybhE)ineCyr1zGDYWsWpoHVIZ3gIwYJdVFKMODs0BdaapqlSXU5H23OeNJLOVnrlR(RNObHOPOOjANeDn3jVF0dy0UUuHQvN1aCyHvrkgybOf2y38qddOmutn8oSWQifdSa8SegIHIbcl4W7hPHGddyalSvbVdLHA4DybhE)ineCyr1zGDYWY1i6TbaGx1ST68jLQyYHI3Wmr7KOzvK14bhukrlrBcrtnr7KOR5o59JEaJ21LkuT6CXuyHvrkgyr1ST68jLQyYHcmGYCd8oSGdVFKgcoSO6mWozyj4hNW)8qB)Kg94W7hPjANe91i6TbaG)5H2(jn6nmt0ojAvf3uq7bOzvKIHFI2eIMAVJblSksXalTqTANb2WakZ6G3HfwfPyGfhLdTn6Cfcl4W7hPHGddyal0iaB8XrjAeEhkd1W7Wco8(rAi4WIQZa7KHLAUtE)OhWODDPcvRoRxbwyvKIbwqUJkCowZ5kegqzUbEhwWH3psdbhwyvKIbwSHOLSrNRqyr1zGDYWcRISgp4GsjAjAtiAQjANenFf2zG(pPuftouokXqBKHhhE)inr7KOVgrtJBdaa)NuQIjhkhLyOnYWByMODs01CN8(rpGr76sfQwDkfyr5s94j4McgwOmuddOmRdEhwWH3psdbhwuDgyNmSSnaa82q0s7ohky7nmt0GbmeT8enRISgp4GsjAjAtiAQjANe92aaWtHJkSZHYXgIwY6nmt0oj6AUtE)OhWODDPcvRoLcrlhSWQifdSydrlzJoxHWakJScVdl4W7hPHGdlQodStgwyvK14bhukrlrBYcrVoI2jrxZDY7h9agTRlvOA15IPWcRIumWIQzB15tkvXKdfyaLXHG3HfC49J0qWHfvNb2jdlb)4eErn2QkUPGEC49J0eTtIMvrwJhCqPeTe9crtnr7KOR5o59JEaJ21LkuT6yk4eTtIwIX3gTqIOnzHOLvWclSksXalFsPkMCOC2IpGbugzbEhwWH3psdbhwuDgyNmSuZDY7h936IdeI)ukeTtIUM7K3p6bmAxxQq1QtPalSksXal2q0s2OZvimGbSyUtrNHl4DOmudVdl4W7hPHGdlQodStgwyvK14bhukrlrBYcrlprF9eTJt0Yt0b)4eEarRqaJ)4OCOTEC49J0e9Aj61r0Yr0Yr0oj6AUtE)OhOr8kS3g9CWH3pst0oj6AUtE)OhWODDPcvRoxmfwyvKIbwunBRoFsPkMCOadOm3aVdl4W7hPHGdlQodStgw4RWod0BUtj(pM7ucBFZZkI2KfI(gI2jrtJBdaaV5oL4)yUtjS92GvRi6fIMAWs0ojAwfznEWbLs0s0len1eTtIUM7K3p6bAeVc7TrphC49J0eTtIUM7K3p6bmAxxQq1QJPMclSksXalpxZNNTvWakZ6G3HfC49J0qWHfvNb2jdl1CN8(rpqJ4vyVn65GdVFKMODs0BdaapWZsyigkgOVrjohlrFBIMIIMODs0SkYA8GdkLOLOnHOPgwyvKIbwaEwcdXqXaHbugzfEhwWH3psdbhwuDgyNmSuZDY7h9anIxH92ONdo8(rAI2jrVnaa8aTWg7MhAFJsCowI(2enffnr7KOzvK14bhukrlrBcrtnSWQifdSa0cBSBEOHbughcEhwWH3psdbhwuDgyNmSCnIEBaa4vnBRoFsPkMCO4nmt0ojAwfznEWbLs0s0Mq0ut0oj6AUtE)OhWODDPcvRoxmfwyvKIbwunBRoFsPkMCOadOmYc8oSGdVFKgcoSO6mWozy5Ae92aaWdy0UocGdNT3Wmr7KOLy8TrlKiAtwi6Balr7KOTMX)pb3uWW6bmAxhbWHZ(qZsmfKOnzHOLNOPMObHOR5o59JEGgXRWEB0ZbhE)inrlhSWQifdSay0UocGdNnmGY4yW7Wco8(rAi4WIQZa7KHLTbaGhWODDeahoBVHzI2jr7KOTMX)pb3uWW6bmAxhbWHZ(qZsmfKOVnrlprtnrdcrxZDY7h9anIxH92ONdo8(rAIwoyHvrkgybWODDeahoByaL56H3HfC49J0qWHfvNb2jdlBdaaFJwXWJcpHiqjFJsCowI(2le9ne9AjAkkAyHvrkgyjebkDKyBGTlyaLznH3HfC49J0qWHfvNb2jdlSkYA8GdkLOLOnzHOxhSWQifdSyngASZHcmGYqnyH3HfC49J0qWHfvNb2jdlb)4e(NhA7N0OhhE)inr7KOVgrVnaa8pp02pPrVHzI2jrRQ4McApanRIum8t0Mq0u7DmyHvrkgyPfQv7mWggqzOMA4DybhE)ineCyr1zGDYWI8enFf2zG(HdJM)tf3sIXLhhE)inr7KO3gaa(HdJM)tf3sIX1bOf2W3OeNJLOV9crFdrVwIMIIMOLJODs0b)4e(koFBiAjpo8(rAI2jrxZDY7h9agTRlvOA1znahwyvKIbwaAHn2np0Wakd13aVdl4W7hPHGdlQodStgwKNO5RWod0pCy08FQ4wsmU84W7hPjANe92aaWpCy08FQ4wsmUoazJ(gL4CSe9Txi6Bi61s0uu0eTCWcRIumWcWZsyigkgimGYq96G3HfC49J0qWHfvNb2jdlYt08vyNb6homA(pvCljgxEC49J0eTtIEBaa4homA(pvCljgxNHdJg9nkX5yj6BVq03q0RLOPOOjA5iANeTeJVnAHerFBI2XalSWQifdS0c1QDgyddyalkAl8ougQH3HfC49J0WnSO6mWozyHVc7mqppk0gn)NgTIHhf6XH3psdlSksXal7xiOFdBadOm3aVdl4W7hPHGdlQodStgwQ5o59JELq80chnhRRrblSksXalBSTyVkhkWakZ6G3HfC49J0qWHfvNb2jdl1CN8(rVsiEAHJMJ11OGfwfPyGL9le0haJ2fmGYiRW7Wco8(rAi4WIQZa7KHLAUtE)OxjepTWrZX6AuWcRIumWcq24(fcAyaLXHG3HfC49J0qWHfvNb2jdl1CN8(rVsiEAHJMJ11OGfwfPyGfEuOnA(pk(FyaLrwG3HfC49J0qWHfvNb2jdlBdaapBv4qZJc9gMjAWagI(AeDWpoHNTkCO5rHEC49J0eTtIgaB(pwZzNHVrjohlrBcr7qenyadrhCtbdFKs4jeh6ej6BVq0YcyHfwfPyGfZIifdmGY4yW7WcRIumWca28FSMZodybhE)ineCyaL56H3HfC49J0qWHfvNb2jdlkH4PfoA82OZvOVrjohlrBcrdwyHvrkgyHTkCO5rHWakZAcVdlSksXali3r1bFucNGFybhE)ineCyadyXCJkH0Md4DOmudVdl4W7hPHGddOm3aVdl4W7hPHGddOmRdEhwWH3psdbhgqzKv4DybhE)ineCyaLXHG3HfwfPyGLqeO0rITb2UGfC49J0qWHbugzbEhwyvKIbw(Ksvm5q5yRs8PHfC49J0qWHbughdEhwyvKIbwmlIumWco8(rAi4WagWcncWgFaVdLHA4DyHvrkgyXr5qFSvi3Wco8(rAi4WakZnW7Wco8(rAi4Wsn)giSiprh8Jt4zRchAEuOhhE)inr7KOLNO3gaaE2QWHMhf6nmt0GbmeTsiEAHJgpBv4qZJc9nkX5yjAtiAhcSeTCeTCenyadrlprFnIo4hNWZwfo08Oqpo8(rAI2jrlprdGn)hR5SZW3OeNJLOnHODiIgmGHOvcXtlC04bWM)J1C2z4BuIZXs0Mq0oeyjA5iA5GfwfPyGLAUtE)iSuZ9zyjewucXtlC0CSUgfmGYSo4DybhE)ineCyPMFdewKy8TrlKiAtwiA5j6GFCcpGr76iaoC2EC49J0e9AjA5jAzHObHOzvKIXBdrlzJoxHELWgeTCeTCWcRIumWsn3jVFewQ5(mSeclagTRlvOA1PuGbugzfEhwWH3psdbhwQ53aHfjgFB0cjI2KfIwEIo4hNWdy0UocGdNThhE)inrVwIwEIwwiAqiAwfPy8pxZNNTvELWgeTCeTCWcRIumWsn3jVFewQ5(mSeclagTRlvOA1XutHbughcEhwWH3psdbhwQ53aHfjgFB0cjI2KfIwEIo4hNWdy0UocGdNThhE)inrVwIwEIwwiAqiAwfPy8QMTvNpPuftou8kHniA5iA5GfwfPyGLAUtE)iSuZ9zyjewamAxxQq1QZftHbugzbEhwWH3psdbhwQ53aHfjgFB0cjI2KfIwEIo4hNWdy0UocGdNThhE)inrVwIwEIwwiAqiAwfPy8aTWg7MhAVsydIwoIwoyHvrkgyPM7K3pcl1CFgwcHfaJ21LkuT6SgGddOmog8oSGdVFKgcoSuZVbclsm(2OfseTjleT8eDWpoHhWODDeahoBpo8(rAIETeT8eTSq0Gq0SksX4rUJkCowZ5k0Re2GOLJOLdwyvKIbwQ5o59JWsn3NHLqybWODDPcvRoRxbgqzUE4DybhE)ineCyPMFdewKy8TrlKiAtwiA5j6GFCcpGr76iaoC2EC49J0e9AjA5jAzHObHOLvWs0Yr0YblSksXal1CN8(ryPM7ZWsiSay0UUuHQvhtbhgqzwt4DybhE)ineCyPMFdewKNOzvK14bhukrlrBcrtnrdgWq0Yt0kH4PfoA8FsPkMCOC2Ip8nkX5yjAtwi6Bi61s0uu0eTCeTCWcRIumWsn3jVFewQ5(mSecl36IdeIhgqzOgSW7Wco8(rAi4Wsn)giSiprxZDY7h936IdeINObdyiAjgFB0cjI2KfIwEIo4hNWlQXwvXnf0JdVFKMOxlrlprlRGLObHOzvKIXBdrlzJoxHELWgeTCeTCeTCWcRIumWsn3jVFewQ5(mSecl36IdeI)ukWakd1udVdl4W7hPHGdl18BGWI8eDn3jVF0FRloqiEIgmGHOLy8TrlKiAtwiA5j6GFCcVOgBvf3uqpo8(rAIETeT8eTScwIgeIMvrkg)Z185zBLxjSbrlhrlhrlhSWQifdSuZDY7hHLAUpdlHWYTU4aH4pMAkmGYq9nW7Wco8(rAi4Wsn)giSiprxZDY7h936IdeINObdyiAjgFB0cjI2KfIwEIo4hNWlQXwvXnf0JdVFKMOxlrlprlRGLObHOzvKIXRA2wD(Ksvm5qXRe2GOLJOLJOLdwyvKIbwQ5o59JWsn3NHLqy5wxCGq8NlMcdOmuVo4DybhE)ineCyPMFdewKNOR5o59J(BDXbcXt0GbmeTeJVnAHerBYcrlprh8Jt4f1yRQ4Mc6XH3pst0RLOLNOLvWs0Gq0SksX4bAHn2np0ELWgeTCeTCeTCWcRIumWsn3jVFewQ5(mSecl36IdeI)SgGddOmulRW7Wco8(rAi4Wsn)giSWQiRXdoOuIwIEHOPMObdyiAjgFB0cjI2KfIwEIMvrkgVQzB15tkvXKdfVsydIgeIMvrkg)Z185zBLxjSbrlhSWQifdSuZDY7hHLAUpdlHWYftDGq8htnfgqzO2HG3HfC49J0qWHLA(nqyHvrwJhCqPeTe9crtnrdgWq0sm(2OfseTjleT8enRIumEvZ2QZNuQIjhkELWgenienRIumEBiAjB05k0Re2GOLdwyvKIbwQ5o59JWsn3NHLqy5IPoqi(tPadOmullW7Wco8(rAi4Wsn)giSiprh8Jt4ReXPIhApo8(rAI2jrh8Jt4R48THOL84W7hPjANenFf2zGEZDkX)XCNsy7XH3pst0YblSksXal1CN8(ryPM7ZWsiSa0iEf2BJEo4W7hPHbugQDm4DybhE)ineCyPMFdewKNOVgrxZDY7h9anIxH92ONdo8(rAI2jrlprh8Jt43cJNgBG0gEC49J0eTtIo4hNW)8qB)Kg94W7hPjANenFf2zGEB04qjQocGdYDu5XH3pst0Yr0YblSksXal1CN8(ryPM7ZWsiS0c1k7N04bhE)inmGYq91dVdlSksXalSrioCeSAfSGdVFKgcomGYq9AcVdlSksXalgw8KbkzHfC49J0qWHbuMBal8oSGdVFKgcoSWQifdSO4)pSksXC(0gWYN24mSeclcZ4GnmGYCd1W7Wco8(rAi4WIQZa7KHLTbaGNTkCO5rHEdZWcRIumWII))WQifZ5tBalFAJZWsiSWwfmGYCZnW7Wco8(rAi4WcRIumWII))WQifZ5tBalFAJZWsiSyUtrNHlyaL5M1bVdl4W7hPHGdlQodStgwyvK14bhukrlrFBIEDWcRIumWII))WQifZ5tBalFAJZWsiSiX5e4WJcHbuMBKv4DybhE)ineCyHvrkgyrX)FyvKI58PnGLpTXzyjewu0wyaL5ghcEhwWH3psdbhwuDgyNmSuZDY7h9anIxH92ONdo8(rAyHvrkgyrX)FyvKI58PnGLpTXzyjewaAeVc7TrphLOryaL5gzbEhwWH3psdbhwuDgyNmSCnIUM7K3p6bAeVc7TrphC49J0WcRIumWII))WQifZ5tBalFAJZWsiSqJaSXhhLOryaL5ghdEhwWH3psdbhwuDgyNmSWQiRXdoOuIwI2KfIEDWcRIumWII))WQifZ5tBalFAJZWsiSiX5e4WJcHbuMBUE4DybhE)ineCyHvrkgyrX)FyvKI58PnGLpTXzyjewaY)XggWagWsn22umqzUbSuVMGL6BwNN6R3HCiyXrCp5qXclR)xNdtM1xzw)iBiAI(Efs0PKzrhenGOjAhoncWgF4Wj6gLTBKnst0wHes0SriK4aPjAvfpuqRN420CqIM6Rx2q0Y2mwdZMfDG0enRIumeTdNncXHJGvRC4EIBI71)RZHjZ6RmRFKnenrFVcj6uYSOdIgq0eTdhOr8kS3g9CuIgD4eDJY2nYgPjARqcjA2iesCG0eTQIhkO1tCBAoirtTSHODyOKOgPjAjw2s2S(LOvvOAfrl)icIMR5859JeDoenkz8CKIroI2XDCIwEQLTKZtCtCV(kzw0bst0udwIMvrkgI(tBy9e3WI1mQGYCJSSoyXClaYhHfzNOxVPIhfkHtq0LkwIhIBzNORIWSv2akOuYOYy7vcjqTPKXZrkgvZabO2usb6(fBq3aSJtJ1GAUfa5JwqDqJomoPTG6ah2PuXs8CwVPIhfkHt4TPKI4w2jA38yWTlI(M1rfrFdyPEnjAhNOPEnLnRdSe3e3YorFPIhkOv2qCl7eTJt0xhnnst0MBujK2Cq03fbkr0RpyBGTlpXTSt0oor7WqGgTve9A0cBSBEObDnEwcdXqXaj6Ci6R7wRhrdiAIEnAeVcBWn6HO3g5t7jUjULDIE9KTqLrG0e9gbens0kH0MdIEJuYX6j6RtPqZHLOhX44vClby8enRIumwIwmVlpXnRIumwV5gvcPnhlapBxrCZQifJ1BUrLqAZbilGcie0e3SksXy9MBujK2CaYcOSbfjCcosXqCl7eDzyZ2krq0nN0e92aaaPjABWHLO3iGOrIwjK2Cq0BKsowIMhAI2CJoUzre5qHOtlrtlg0tCZQifJ1BUrLqAZbilGAh2STsehBWHL4MvrkgR3CJkH0MdqwanebkDKyBGTlIBwfPySEZnQesBoazb0pPuftouo2QeFAIBwfPySEZnQesBoazbuZIifdXnXTSt0RNSfQmcKMOXASDr0rkHeDuHenRcrt0PLO5AoFE)ON4Mvrkg7IJYH(yRqUjULDI(6IaLmheDiiARRrr0nRs(jALq80chnwI2rzur0xNvHdnpkKOfnrVgyZprxmNDgwQiArt0gwKOfdrReINw4OHOtaI2Y15qHOJkuIODu(pr3O14dIohI2MuMeiv8eeTsiEAHJgI2rSnqIBwfPySGSaAn3jVFKQHLWfLq80chnhRRrrvn)g4I8b)4eE2QWHMhf6XH3ps7u(TbaGNTkCO5rHEdZGbmkH4PfoA8SvHdnpk03OeNJ1ehcSYjhyaJ8xl4hNWZwfo08Oqpo8(rANYdGn)hR5SZW3OeNJ1ehcmGrjepTWrJhaB(pwZzNHVrjohRjoeyLtoIBzNOxFki6reeTHfjAMOLy8TrlKCCLWg5qHO5D(z4IOtaIodI2r5)e9UZHcr7syq0HGOblrlX4BJwir08qt0kEu4t0agTlIwaq0C2EIBwfPySGSaAn3jVFKQHLWfaJ21LkuT6ukuvZVbUiX4BJwizYI8b)4eEaJ21raC4S94W7hPxR8YciSksX4THOLSrNRqVsyd5KJ4MvrkglilGwZDY7hPAyjCbWODDPcvRoMAkv18BGlsm(2OfsMSiFWpoHhWODDeahoBpo8(r61kVSacRIum(NR5ZZ2kVsyd5KJ4MvrkglilGwZDY7hPAyjCbWODDPcvRoxmLQA(nWfjgFB0cjtwKp4hNWdy0UocGdNThhE)i9ALxwaHvrkgVQzB15tkvXKdfVsyd5KJ4MvrkglilGwZDY7hPAyjCbWODDPcvRoRb4uvZVbUiX4BJwizYI8b)4eEaJ21raC4S94W7hPxR8YciSksX4bAHn2np0ELWgYjhXnRIumwqwaTM7K3ps1Ws4cGr76sfQwDwVcv18BGlsm(2OfsMSiFWpoHhWODDeahoBpo8(r61kVSacRIumEK7OcNJ1CUc9kHnKtoIBwfPySGSaAn3jVFKQHLWfaJ21LkuT6yk4uvZVbUiX4BJwizYI8b)4eEaJ21raC4S94W7hPxR8YciYkyLtoIBzNOVUiqjZbrhcI2Sq8eTeJVnAHerBfeTlHHd)FIEJenVFKOdbrRyBq0mrdy8Vlh3SWryJ0e9NuQIjhke9w8brZwI2kedrZwIodhULO5AoFE)ir7OkCiAGKsvKdfIwmirhCtbdpXnRIumwqwaTM7K3ps1Ws4YTU4aH4PQMFdCrEwfznEWbLs0Ac1GbmYReINw4OX)jLQyYHYzl(W3OeNJ1KLBwlffTCYrCZQifJfKfqR5o59JunSeUCRloqi(tPqvn)g4I81CN8(r)TU4aH4bdyKy8TrlKmzr(GFCcVOgBvf3uqpo8(r61kVScwqyvKIXBdrlzJoxHELWgYjNCe3SksXybzb0AUtE)ivdlHl36IdeI)yQPuvZVbUiFn3jVF0FRloqiEWagjgFB0cjtwKp4hNWlQXwvXnf0JdVFKETYlRGfewfPy8pxZNNTvELWgYjNCe3SksXybzb0AUtE)ivdlHl36IdeI)CXuQQ53axKVM7K3p6V1fhiepyaJeJVnAHKjlYh8Jt4f1yRQ4Mc6XH3psVw5LvWccRIumEvZ2QZNuQIjhkELWgYjNCe3SksXybzb0AUtE)ivdlHl36IdeI)SgGtvn)g4I81CN8(r)TU4aH4bdyKy8TrlKmzr(GFCcVOgBvf3uqpo8(r61kVScwqyvKIXd0cBSBEO9kHnKto5iULDI(6IaLmheDiiAZcXt0sm(2OfsenGOj6lnBRiAttkvXKdfIobiAjJpsZps0b3uWWs0CJeT5gT4eEIBwfPySGSaAn3jVFKQHLWLlM6aH4pMAkv18BGlSkYA8GdkLODHAWagjgFB0cjtwKNvrkgVQzB15tkvXKdfVsydqyvKIX)CnFE2w5vcBihXnRIumwqwaTM7K3ps1Ws4YftDGq8NsHQA(nWfwfznEWbLs0UqnyaJeJVnAHKjlYZQifJx1ST68jLQyYHIxjSbiSksX4THOLSrNRqVsyd5iUzvKIXcYcO1CN8(rQgwcxaAeVc7TrphC49J0uvZVbUiFWpoHVseNkEO94W7hPDg8Jt4R48THOL84W7hPDYxHDgO3CNs8Fm3Pe2EC49J0YrCZQifJfKfqR5o59JunSeU0c1k7N04bhE)inv18BGlYFTAUtE)OhOr8kS3g9CWH3ps7u(GFCc)wy80ydK2WJdVFK2zWpoH)5H2(jn6XH3ps7KVc7mqVnACOevhbWb5oQ84W7hPLtoIBwfPySGSakBeIdhbRwrCZQifJfKfqnS4jduYsCZQifJfKfqv8)hwfPyoFAdQgwcxeMXbBIBwfPySGSaQI))WQifZ5tBq1Ws4cBvuLalBdaapBv4qZJc9gMjUzvKIXcYcOk()dRIumNpTbvdlHlM7u0z4I4MvrkglilGQ4)pSksXC(0gunSeUiX5e4WJcPkbwyvK14bhukr7TxhXnRIumwqwavX)FyvKI58PnOAyjCrrBjUzvKIXcYcOk()dRIumNpTbvdlHlanIxH92ONJs0ivjWsn3jVF0d0iEf2BJEo4W7hPjUzvKIXcYcOk()dRIumNpTbvdlHl0iaB8XrjAKQey5A1CN8(rpqJ4vyVn65GdVFKM4MvrkglilGQ4)pSksXC(0gunSeUiX5e4WJcPkbwyvK14bhukrRjlRJ4MvrkglilGQ4)pSksXC(0gunSeUaK)JnXnXnRIumwpBvlQMTvNpPuftouOkbwU22aaWRA2wD(Ksvm5qXBy2jRISgp4GsjAnHAN1CN8(rpGr76sfQwDUykXnRIumwpBvGSaAluR2zGnvjWsWpoH)5H2(jn6XH3ps78ABdaa)ZdT9tA0By2PQIBkO9a0SksXWVju7DmIBwfPySE2QazbuhLdTn6CfsCtCl7e9f2gen4Vqq)g2GOL4XG)3frNaeDuHe91Df2zGe99MZGOVUrH2O5NODyOvm8OqIoTeT5gT4eEIBwfPySEfTDz)cb9BydQsGf(kSZa98OqB08FA0kgEuOhhE)inXnRIumwVI2cYcOBSTyVkhkuLal1CN8(rVsiEAHJMJ11OiUzvKIX6v0wqwaD)cb9bWODrvcSuZDY7h9kH4PfoAowxJI4MvrkgRxrBbzbuGSX9le0uLal1CN8(rVsiEAHJMJ11OiUzvKIX6v0wqwaLhfAJM)JI)NQeyPM7K3p6vcXtlC0CSUgfXTSt0xxeOK5GOdbrBDnkI2LWOj61NoOq0MfrkgI2rzur0mrReINw4OHkI2yE0Aj6Ocj6GBkyq0PLO5TWii6qq00j6jUzvKIX6v0wqwa1SisXqvcSSnaa8SvHdnpk0BygmG5Ab)4eE2QWHMhf6XH3ps7eaB(pwZzNHVrjohRjoeyatWnfm8rkHNqCOt82lYcyjUzvKIX6v0wqwafaB(pwZzNbXnRIumwVI2cYcOSvHdnpkKQeyrjepTWrJ3gDUc9nkX5ynbSe3SksXy9kAlilGIChvh8rjCc(jUjUzvKIX6Pra24JJs04cYDuHZXAoxHuLal1CN8(rpGr76sfQwDwVcXnRIumwpncWgFCuIgbzbuBiAjB05kKkLl1JNGBkyyxOMQeyHvrwJhCqPeTMqTt(kSZa9FsPkMCOCuIH2idpo8(rANxJg3gaa(pPuftouokXqBKH3WSZAUtE)OhWODDPcvRoLcXnRIumwpncWgFCuIgbzbuBiAjB05kKQeyzBaa4THOL2DouW2BygmGrEwfznEWbLs0Ac1o3gaaEkCuHDouo2q0swVHzN1CN8(rpGr76sfQwDkf5iUzvKIX6Pra24JJs0iilGQA2wD(Ksvm5qHQeyHvrwJhCqPeTMSSoN1CN8(rpGr76sfQwDUykXnRIumwpncWgFCuIgbzb0pPuftouoBXhuLalb)4eErn2QkUPGEC49J0ozvK14bhukr7c1oR5o59JEaJ21LkuT6yk4oLy8TrlKmzrwblXnRIumwpncWgFCuIgbzbuBiAjB05kKQeyPM7K3p6V1fhie)PuCwZDY7h9agTRlvOA1PuiUjUzvKIX6bY)XEXAm0yNdfIBwfPySEG8FSbzbuvZ2QZNuQIjhkuLalb)4eEarRqaJ)4OCOTEC49J0ozvK14bhukrRju7SM7K3p6bmAxxQq1QZftjUzvKIX6bY)XgKfqbEwcdXqXaPkbwc(Xj8wK7COCyRLn(WJdVFKM4MvrkgRhi)hBqwa95A(8STIQey5A8vyNb6n3Pe)hZDkHThhE)iTZGFCcFLiov8q7XH3ps7CBaa4ReXPIhAFJSkiUzvKIX6bY)XgKfqvnBRoFsPkMCOqvcSWQiRXdoOuIwtO2zn3jVF0dy0UUuHQvNlMsCZQifJ1dK)JnilG2c1QDgytvcSiX4BJwiDBhdSoV22aaWBJghkr1raCqUJkVHzIBwfPySEG8FSbzbuvZ2QZNuQIjhkuLalb)4eEvZ2QCOCSHOL84W7hPDwZDY7h936IdeI)CXuIBwfPySEG8FSbzb0NR5ZZ2kQsGLAUtE)O)wxCGq8htn1zn3jVF0dy0UUuHQvhtnL4MvrkgRhi)hBqwaTfQv7mWM4MvrkgRhi)hBqwafOf2y38qtvcSe8Jt4R48THOL84W7hPDUnaa8aTWg7MhAFJsCo2BlR(RhekkAN1CN8(rpGr76sfQwDwdWjUzvKIX6bY)XgKfqbEwcdXqXajUjUzvKIX6bAeVc7TrphLOXLNR5ZZ2kQcUPGXjbwKyzlzdnUnaa8M7uI)J5oLW2BdwTIQeyHVc7mqV5oL4)yUtjS9npRmz5gN042aaWBUtj(pM7ucBVny1QfQbRZAUtE)OhWODDPcvRoMAQZAUtE)O)IPoqi(JPMsCZQifJ1d0iEf2BJEokrJGSakYDuHZXAoxHuLal1CN8(rpGr76sfQwDwVcXnRIumwpqJ4vyVn65OencYcO2q0s2OZvivkxQhpb3uWWUqnvjWcRISgp4GsjAnHAN8vyNb6)Ksvm5q5OedTrgEC49J0oVgnUnaa8FsPkMCOCuIH2idVHzN1CN8(rpGr76sfQwDkfIBwfPySEGgXRWEB0ZrjAeKfqTHOLSrNRqQsGLTbaG3gIwA35qbBVHzWag5zvK14bhukrRju7CBaa4PWrf25q5ydrlz9gMDwZDY7h9agTRlvOA1PuKJ4MvrkgRhOr8kS3g9CuIgbzbuvZ2QZNuQIjhkuLalSkYA8GdkLO1KL15SM7K3p6bmAxxQq1QZftjUzvKIX6bAeVc7TrphLOrqwa9tkvXKdLZw8bvjWsWpoHxuJTQIBkOhhE)iTtwfznEWbLs0UqTZAUtE)OhWODDPcvRoMcUtjgFB0cjtwKvWsCZQifJ1d0iEf2BJEokrJGSa6Z185zBfvjWcFf2zGEZDkX)XCNsy7BEwzYYnoPXTbaG3CNs8Fm3Pe2EBWQvM4yoR5o59JEaJ21LkuT6yQPoR5o59J(lM6aH4pMAkXnRIumwpqJ4vyVn65OencYcO2q0s2OZvivjWsn3jVF0FRloqi(tP4SM7K3p6bmAxxQq1QtP4SM7K3p6VyQdeI)uke3SksXy9anIxH92ONJs0iilG(CnFE2wrvcSqJBdaaV5oL4)yUtjS92GvRwOgSoR5o59JEaJ21LkuT6yQPe3e3SksXy9sCobo8OWfGNLWqmumqQsGLRTnaa8aplHHyOyGEdZe3SksXy9sCobo8OqqwafOf2y38qtvcSe8Jt4R48THOL84W7hPDETTbaGhOf2y38q7nm7SM7K3p6bmAxxQq1QZAaoXnXnRIumwVWmoyV0c1QDgytvcSiX4BJwiDBQDiNrkH3MIIM4M4MvrkgR3CNIodxlQMTvNpPuftouOkbwyvK14bhukrRjlYF9oU8b)4eEarRqaJ)4OCOTEC49J0RDDYjNZAUtE)OhOr8kS3g9CWH3ps7SM7K3p6bmAxxQq1QZftjUzvKIX6n3POZWfilG(CnFE2wrvcSWxHDgO3CNs8Fm3Pe2(MNvMSCJtACBaa4n3Pe)hZDkHT3gSA1c1G1jRISgp4GsjAxO2zn3jVF0d0iEf2BJEo4W7hPDwZDY7h9agTRlvOA1XutjUzvKIX6n3POZWfilGc8SegIHIbsvcSuZDY7h9anIxH92ONdo8(rANBdaapWZsyigkgOVrjoh7TPOODYQiRXdoOuIwtOM4MvrkgR3CNIodxGSakqlSXU5HMQeyPM7K3p6bAeVc7TrphC49J0o3gaaEGwyJDZdTVrjoh7TPOODYQiRXdoOuIwtOM4MvrkgR3CNIodxGSaQQzB15tkvXKdfQsGLRTnaa8QMTvNpPuftou8gMDYQiRXdoOuIwtO2zn3jVF0dy0UUuHQvNlMsCZQifJ1BUtrNHlqwafWODDeahoBQsGLRTnaa8agTRJa4Wz7nm7uIX3gTqYKLBaRtRz8)tWnfmSEaJ21raC4Sp0SetbnzrEQbPM7K3p6bAeVc7TrphC49J0YrCZQifJ1BUtrNHlqwafWODDeahoBQsGLTbaGhWODDeahoBVHzNoTMX)pb3uWW6bmAxhbWHZ(qZsmf82Ytni1CN8(rpqJ4vyVn65GdVFKwoIBwfPySEZDk6mCbYcOHiqPJeBdSDrvcSSnaa8nAfdpk8eIaL8nkX5yV9YnRLIIM4MvrkgR3CNIodxGSaQ1yOXohkuLalSkYA8GdkLO1KL1rCZQifJ1BUtrNHlqwaTfQv7mWMQeyj4hNW)8qB)Kg94W7hPDETTbaG)5H2(jn6nm7uvXnf0EaAwfPy43eQ9ogXTSt0R)zur0YWHrZprlBl3sIXfven(ynhirhvirBUtrNHlIwaq04Js4e8t0CeSALLOZHOfnn2eDiiAjoNGZHOJkKO3gaawI2rv4q0rf6YH3irZBHrq0HGOrzlZzJEIBwfPySEZDk6mCbYcOaTWg7MhAQsGf55RWod0pCy08FQ4wsmU84W7hPDUnaa8dhgn)NkULeJRdqlSHVrjoh7TxUzTuu0Y5m4hNWxX5Bdrl5XH3ps7SM7K3p6bmAxxQq1QZAaoXnRIumwV5ofDgUazbuGNLWqmumqQsGf55RWod0pCy08FQ4wsmU84W7hPDUnaa8dhgn)NkULeJRdq2OVrjoh7TxUzTuu0YrCZQifJ1BUtrNHlqwaTfQv7mWMQeyrE(kSZa9dhgn)NkULeJlpo8(rANBdaa)WHrZ)PIBjX46mCy0OVrjoh7TxUzTuu0Y5uIX3gTq62ogyHbmGq]] )


end
