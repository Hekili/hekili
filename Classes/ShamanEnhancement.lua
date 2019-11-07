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
                local speed = state.swings.mainhand_speed
                local t = state.query_time

                if speed == 0 then return swing end

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
            interval = 'mainhand_speed',
            value = 5
        },

        offhand = {
            last = function ()
                local swing = state.swings.offhand
                local speed = state.swings.offhand_speed
                local t = state.query_time

                if speed == 0 then return swing end

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

        icy_edge = {
            id = 224126,
            duration = 15,
            max_stack = 1,
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

                local up = PlayerBuffUp( "resonance_totem" ) and remains > 0

                local tm = buff.totem_mastery
                tm.name = class.abilities.totem_mastery.name

                if up then
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

                removeBuff( "resonance_totem" )
                removeBuff( "tailwind_totem" )
                removeBuff( "storm_totem" )
                removeBuff( "ember_totem" )
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
            max_stack = 1,
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

        -- PvP Talents
        earth_shield = {
            id = 204288,
            duration = 600,
            max_stack = 4,
        },

        thundercharge = {
            id = 204366,
            duration = 10,
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


    spec:RegisterHook( "reset_precast", function ()
        class.auras.totem_mastery.generate()
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

        earth_shield = {
            id = 204288,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = false,
            -- texture = ,

            pvptalent = "earth_shield",

            handler = function ()
                applyBuff( "earth_shield" )
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( 120 - ( talent.elemental_spirits.enabled and 30 or 0 ) ) end,
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

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 136075,

            toggle = "interrupts",
            interrupt = true,

            usable = function () return buff.dispellable_magic.up, "requires dispellable magic aura" end,
            handler = function ()
                removeBuff( "dispellable_magic" )
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
                return max( 0,  buff.ascendance.up and 10 or 30 )
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


        thundercharge = {
            id = 204366,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1385916,

            pvptalent = function () return not essence.conflict_and_strife.major and "thundercharge" or nil end,
            
            handler = function ()
                applyBuff( "thundercharge" )
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

        potion = "superior_battle_potion_of_agility",

        package = "Enhancement",
    } )


    spec:RegisterPack( "Enhancement", 20190810, [[dWu8wbqisv1JqfPnrf9jQKKrrQ4uKkTkaKxHaZcH6wOIQ2fv9levdJkvhdqwgPkEgQiMga4AKQKTbOY3ivPghQOY5aqzDujPMha09Ku7dr5GaQQfIqEianrauLlcOkBKkj8rQKizKujrQtcGQALkvMjvIBsLev7ev4NOIYqPsQLcGk6Psmve0vPsIsFfavyVQ6VkzWuCyIfRIhtYKb6YqBwL(mImAj50cRgav61kvnBq3gvTBf)gLHJkDCQKOy5s9CknDrxNu2Us57KQY4PsI48uH1dOmFQu2ps)a9e(fqjXNd94oqam35Ca5UxpaXj6nq69xshCXVWvu7fs4xgHh)cWBQKrH84KFHR4aYeWNWVyzATc)svMCTUAYjNuKvAhVIXtUn41GsgSr1Ynj3g8kY)YrlGja)5pFbus85qpUdeaZDohqU71dqCIEdKE9frlRy9xkbVguYGna2Yn)svacIZF(ciAvFHtPgG3ujJc5XjPMsLWldDhNsnvzY16QjNCsrwPD8kgp52GxdkzWgvl3KCBWRiNUJtPgGVgjnBsna5oXuJEChiag1W5Pg94URgaCNUJUJtPgaRKHeAD10DCk1W5PgGpiicsnCBuX4pssneYsKNACLl2eBhE6ooLA48udap24QsQrZIudWt6SIAaEqKhNuGuJowzdPMiPMlRPgTmGr6qx)xGHnTpHF5gqi2pHpha9e(fCKdebFI(IQJe7q(slb4c3Wj9ciO1hd1qg1aaU)frLbB(IvBaXogsF(CONNWVGJCGi4t0xuDKyhYxAjax4goPxabT(yOgYOgaM7uJtQr)uZr7E9IvHdOmk0RXLACsn6NAoA3RNNbtCw6dfUSXRXLACsn6NAoA3Rpuowiij0RXLACsn6NAoA3Rx1IApmgslRwtc9ACPgNuJ(Pgq8ODVEu6ScNLLBSh9AC)IOYGnF5YuAweCjad7iX1bf(pFo4KNWVGJCGi4t0xuDKyhYxAjax4goPxabT(yOgYOgGZ9ViQmyZx4Q1X1rmKwhOyZpFoaGNWVGJCGi4t0xuDKyhYxAjax4goPxabT(yOgYOgGZ9ViQmyZx6GlxiUIzz5kk8ZNd96j8lIkd28LSsBaXwvjnj8l4ihic(e95ZbW9e(frLbB(IInkCYwseCDHcp(fCKdebFI(85qVFc)coYbIGprFr1rIDiFjfioP)YAfE1Gl9fdO1JJCGii14KAevgB4chKpql1qg1ae14KA2KoKde9xT2bGvOA)cqx(IOYGnFr1ITAbdsv5edPpFo4CpHFbh5arWNOVO6iXoKVKceN0BrPJH0sSwrdMECKdeb)IOYGnF5cfEmzdjn8ZNda2t4xWroqe8j6lQosSd5l6NAeGHDKONBh8cCXTdES94ihicsnoPMuG4K(kwUQKb0JJCGii14KAoA3RVILRkza9nkQ8lIkd28fOSjlOyR(85ai3Fc)coYbIGprFr1rIDiFruzSHlCq(aTudzudquJtQzt6qoq0F1AhawHQ9laD5lIkd28fvl2QfmivLtmK(85aiGEc)coYbIGprFr1rIDiFHxqOnBgp1aGuJE7o14KA0p1C0UxVnBCiLvl2DHsNvEnUFruzWMV0m1(tKy)5Zbq65j8l4ihic(e9fvhj2H8LuG4KEvl2QyiTSjR594ihicsnoPMnPd5arpNbORzm4cqx(IOYGnFr1ITAbdsv5edPpFoaItEc)coYbIGprFr1rIDiFzt6qoq0Zza6AgdUCXfQXj1SjDihi6VATdaRq1(LlU8frLbB(cu2KfuSvF(Caea8e(frLbB(cpYZAhl2Db1ub4cSrH3(fCKdebFI(85ai96j8lIkd28LMP2FIe7VGJCGi4t0NphabCpHFbh5arWNOVO6iXoKVKceN0xjb0MSM3JJCGii14KAoA3R)2mBEAza9nYlXyPgaKAaapNJAiGAiPaPgNuZM0HCGO)Q1oaScv7xUcI(IOYGnF52mBEAza)85ai9(j8lIkd28Llu4XKnK0WVGJCGi4t0NphaX5Ec)coYbIGprFr1rIDiF5ODVEyCXdKXa92uu7PgaKAaGViQmyZx0hRHGBymRgTSrgf(5NFHxIjXrgf(e(Ca0t4xWroqe8j6lQosSd5l6NAoA3R)cfEmzdjn0RX9lIkd28Llu4XKnK0WpFo0Zt4xWroqe8j6lQosSd5lPaXj9vsaTjR594ihicsnoPg9tnhT71FBMnpTmGEnUuJtQzt6qoq0F1AhawHQ9lxbrFruzWMVCBMnpTmGF(5xUnIad7JwplfRXNWNdGEc)coYbIGprFruzWMVaLnzbfB1xuDKyhYxeGHDKONBh8cCXTdES9Tm7PgYQPg9qnoPgq8ODVEUDWlWf3o4X2BtrTNAQPgGCNACsnBshYbI(Rw7aWkuTF5IluJtQzt6qoq0dOlUMXGlxC5lkhkiUsPjHP95aOpFo0Zt4xWroqe8j6lQosSd5lBshYbI(Rw7aWkuTFb8kFruzWMVGsNv4SSCJ94NphCYt4xWroqe8j6lIkd28fBYAEB2XE8lQosSd5lIkJnCHdYhOLAiJAaIACsncWWos0ddsv5edPLInGAr6XroqeKACsn6NAaXJ296HbPQCIH0sXgqTi9ACPgNuZM0HCGO)Q1oaScv7xLYxuouqCLstct7ZbqF(CaapHFbh5arWNOVO6iXoKVC0UxVnzn)PJHe2EnUuJBUrn6qnIkJnCHdYhOLAiJAaIACsnhT71tsYkSJH0YMSM3614snoPMnPd5ar)vRDayfQ2VkfQr3ViQmyZxSjR5Tzh7XpFo0RNWVGJCGi4t0xuDKyhYxevgB4chKpql1qwn1WjuJtQzt6qoq0F1AhawHQ9laD5lIkd28fvl2QfmivLtmK(85a4Ec)coYbIGprFr1rIDiFjfioPNTHTQsAsOhh5arqQXj1iQm2WfoiFGwQPMAaIACsnBshYbI(Rw7aWkuTF5cruJtQHxqOnBgp1qwn1aaU)frLbB(cmivLtmKwhgm)85qVFc)coYbIGprFr1rIDiFrag2rIEUDWlWf3o4X23YSNAiRMA0d14KAaXJ29652bVaxC7GhBVnf1EQHmQrVPgNuZM0HCGO)Q1oaScv7xU4c14KA2KoKde9a6IRzm4Yfx(IOYGnFbkBYck2QpFo4CpHFbh5arWNOVO6iXoKVSjDihi65maDnJbxLc14KA2KoKde9xT2bGvOA)QuOgNuZM0HCGOhqxCnJbxLYxevgS5l2K182SJ94NphaSNWVGJCGi4t0xuDKyhYxaXJ29652bVaxC7GhBVnf1EQPMAaYDQXj1SjDihi6VATdaRq1(LlU8frLbB(cu2KfuSvF(5x42OIXFK8j85aONWViQmyZxswI8lEXMy74l4ihic(e95ZHEEc)IOYGnFbgKQYjgslBvGqWVGJCGi4t0NphCYt4xevgS5lCzzWMVGJCGi4t0NF(fq8kAW8j85aONWViQmyZx0xmGlBfk9xWroqe8j6ZNd98e(fCKdebFI(cJ7xSy(frLbB(YM0HCG4x2eOg(fDOMuG4KEXQWbugf6XroqeKACsn6qnhT71lwfoGYOqVgxQXn3OgfJbbz6B8IvHdOmk03iVeJLAiJA0l3PgDPgDPg3CJA0HA0p1KceN0lwfoGYOqpoYbIGuJtQrhQ5ITaxwUrhPVrEjgl1qg1OxuJBUrnkgdcY034VylWLLB0r6BKxIXsnKrn6L7uJUuJUFzt61i84xumgeKPVzzDmQpFo4KNWVGJCGi4t0xyC)IfZViQmyZx2KoKde)YMa1WVWli0MnJNAiRMA0HAsbIt6VATJf7UKO94ihicsnae1Od1aCudbuJOYGnEBYAEB2XE0Ry2KA0LA09lBsVgHh)YvRDayfQ2VkLpFoaGNWVGJCGi4t0xyC)IfZViQmyZx2KoKde)YMa1WVWli0MnJNAiRMA0HAsbIt6VATJf7UKO94ihicsnae1Od1aCudbuJOYGnEOSjlOyR8kMnPgDPgD)YM0Rr4XVC1AhawHQ9lxC5ZNd96j8l4ihic(e9fg3VyX8lIkd28LnPd5aXVSjqn8l8ccTzZ4PgYQPgDOMuG4K(Rw7yXUljApoYbIGudarn6qnah1qa1iQmyJx1ITAbdsv5edjVIztQrxQr3VSj9AeE8lxT2bGvOA)cqx(85a4Ec)coYbIGprFHX9lwm)IOYGnFzt6qoq8lBcud)cVGqB2mEQHSAQrhQjfioP)Q1owS7sI2JJCGii1aquJoudWrneqnIkd24VnZMNwgqVIztQrxQr3VSj9AeE8lxT2bGvOA)Yvq0Nph69t4xWroqe8j6lmUFXI5xevgS5lBshYbIFztGA4x4feAZMXtnKvtn6qnPaXj9xT2XIDxs0ECKdebPgaIA0HAaoQHaQruzWgpkDwHZYYn2JEfZMuJUuJUFzt61i84xUATdaRq1(fWR85ZbN7j8l4ihic(e9fg3VyX8lIkd28LnPd5aXVSjqn8l8ccTzZ4PgYQPgDOMuG4K(Rw7yXUljApoYbIGudarn6qnah1qa1aaUtn6sn6(LnPxJWJF5Q1oaScv7xUq0NphaSNWVGJCGi4t0xyC)IfZViQmyZx2KoKde)YMa1WVOd1iQm2WfoiFGwQHmQbiQXn3OgDOgfJbbz6B8WGuvoXqADyW03iVeJLAiRMA0d1aqudjfi1Ol1O7x2KEncp(fodqxZyWpFoaY9NWVGJCGi4t0xyC)IfZViQmyZx2KoKde)YMa1WVOd1SjDihi65maDnJbPg3CJA4feAZMXtnKvtn6qnPaXj9SnSvvstc94ihicsnae1Od1aaUtneqnIkd24TjR5Tzh7rVIztQrxQrxQr3VSj9AeE8lCgGUMXGRs5ZNdGa6j8l4ihic(e9fg3VyX8lIkd28LnPd5aXVSjqn8l6qnBshYbIEodqxZyqQXn3OgEbH2Sz8udz1uJoutkqCspBdBvL0KqpoYbIGudarn6qnaG7udbuJOYGnEOSjlOyR8kMnPgDPgDPgD)YM0Rr4XVWza6AgdUCXLpFoasppHFbh5arWNOVW4(flMFruzWMVSjDihi(LnbQHFrhQzt6qoq0Zza6AgdsnU5g1Wli0MnJNAiRMA0HAsbIt6zByRQKMe6XroqeKAaiQrhQbaCNAiGAevgSXRAXwTGbPQCIHKxXSj1Ol1Ol1O7x2KEncp(fodqxZyWfGU85ZbqCYt4xWroqe8j6lmUFXI5xevgS5lBshYbIFztGA4x0HA2KoKde9CgGUMXGuJBUrn8ccTzZ4PgYQPgDOMuG4KE2g2QkPjHECKdebPgaIA0HAaa3PgcOgrLbB83MzZtldOxXSj1Ol1Ol1O7x2KEncp(fodqxZyWLRGOpFoacaEc)coYbIGprFHX9lwm)IOYGnFzt6qoq8lBcud)IOYydx4G8bAPMAQbiQXn3OgEbH2Sz8udz1uJouJOYGnEvl2QfmivLtmK8kMnPgcOgrLbB8qztwqXw5vmBsn6(LnPxJWJFbqxCnJbxU4YNphaPxpHFbh5arWNOVW4(flMFruzWMVSjDihi(LnbQHFruzSHlCq(aTutn1ae14MBudVGqB2mEQHSAQrhQruzWgVQfB1cgKQYjgsEfZMudbuJOYGnEBYAEB2XE0Ry2KA09lBsVgHh)cGU4AgdUkLpFoac4Ec)coYbIGprFHX9lwm)IOYGnFzt6qoq8lBcud)IoutkqCsFflxvYa6XroqeKACsnPaXj9vsaTjR594ihicsnoPgbyyhj652bVaxC7GhBpoYbIGuJUFzt61i84xUnIad7JwplCKdeb)85ai9(j8l4ihic(e9fg3VyX8lIkd28LnPd5aXVSjqn8l6qn6NA2KoKde93grGH9rRNfoYbIGuJtQrhQjfioP)W0GGyFdB6XroqeKACsnPaXj9qzaTWae94ihicsnoPgbyyhj6TzJdPSAXUlu6SYJJCGii1Ol1O7x2KEncp(LMP2BHbiUWroqe8ZNdG4CpHFbh5arWNOViQmyZxuceUevgSzbdB(fyyZ1i84xyCXb7pFoacG9e(fCKdebFI(IQJe7q(Yr7E9IvHdOmk0RX9lIkd28fLaHlrLbBwWWMFbg2Cncp(fXQ(85qpU)e(fCKdebFI(IOYGnFrjq4suzWMfmS5xGHnxJWJFHBhSoshF(COhGEc)coYbIGprFr1rIDiFruzSHlCq(aTudasnCYxevgS5lkbcxIkd2SGHn)cmS5AeE8l8smjoYOWpFo0JEEc)coYbIGprFruzWMVOeiCjQmyZcg28lWWMRr4XVOaTF(COho5j8l4ihic(e9fvhj2H8LnPd5ar)TreyyF06zHJCGi4xevgS5lkbcxIkd2SGHn)cmS5AeE8l3grGH9rRNLI14Nph6baEc)coYbIGprFr1rIDiFr)uZM0HCGO)2icmSpA9SWroqe8lIkd28fLaHlrLbBwWWMFbg2Cncp(fq8kAWCPyn(5ZHE0RNWVGJCGi4t0xuDKyhYxevgB4chKpql1qwn1WjFruzWMVOeiCjQmyZcg28lWWMRr4XVWlXK4iJc)85qpa3t4xWroqe8j6lIkd28fLaHlrLbBwWWMFbg2Cncp(LBaHy)5NFbeVIgmxkwJpHpha9e(fCKdebFI(IQJe7q(YM0HCGO)Q1oaScv7xaVYxevgS5lO0zfoll3yp(5ZHEEc)coYbIGprFruzWMVytwZBZo2JFr1rIDiFruzSHlCq(aTudzudquJtQrag2rIEyqQkNyiTuSbulspoYbIGuJtQr)udiE0UxpmivLtmKwk2aQfPxJl14KA2KoKde9xT2bGvOA)Qu(IYHcIRuAsyAFoa6ZNdo5j8l4ihic(e9fvhj2H8LJ296TjR5pDmKW2RXLACZnQrhQruzSHlCq(aTudzudquJtQ5ODVEsswHDmKw2K18wVgxQXj1SjDihi6VATdaRq1(vPqn6(frLbB(InznVn7yp(5Zba8e(fCKdebFI(IQJe7q(IOYydx4G8bAPgYQPgoHACsnBshYbI(Rw7aWkuTFbOlFruzWMVOAXwTGbPQCIH0Nph61t4xWroqe8j6lQosSd5lPaXj9SnSvvstc94ihicsnoPgrLXgUWb5d0sn1udquJtQzt6qoq0F1AhawHQ9lxiIACsn8ccTzZ4PgYQPgaW9ViQmyZxGbPQCIH06WG5Npha3t4xWroqe8j6lQosSd5lBshYbIEodqxZyWvPqnoPMnPd5ar)vRDayfQ2VkLViQmyZxSjR5Tzh7Xp)8lmU4G9t4ZbqpHFbh5arWNOVO6iXoKVWli0MnJNAaqQbi9IACsnzWJudasnKuGFruzWMV0m1(tKy)5NFHBhSoshpHpha9e(fCKdebFI(IQJe7q(IOYydx4G8bAPgYQPgDOgoh1W5PgDOMuG4K(lRv4vdU0xmGwpoYbIGudarnCc1Ol1Ol14KA2KoKde93grGH9rRNfoYbIGuJtQzt6qoq0F1AhawHQ9laD5lIkd28fvl2QfmivLtmK(85qppHFbh5arWNOVO6iXoKVC0UxFJQ9q0AxxwRqVgxQXn3OMm4rQbaPg96lIkd28LScxAZHPnGRlRv4NphCYt4xWroqe8j6lQosSd5lcWWos0ZTdEbU42bp2(wM9udz1uJEOgNudiE0Uxp3o4f4IBh8y7TPO2tn1udqUtnoPgrLXgUWb5d0sn1udquJtQzt6qoq0FBebg2hTEw4ihicsnoPMnPd5ar)vRDayfQ2VCXLViQmyZxGYMSGIT6ZNda4j8l4ihic(e9fvhj2H8LnPd5ar)TreyyF06zHJCGii14KAoA3R)cfEmzdjn03iVeJLAaqQHKcKACsnIkJnCHdYhOLAiJAa6lIkd28Llu4XKnK0WpFo0RNWVGJCGi4t0xuDKyhYx2KoKde93grGH9rRNfoYbIGuJtQ5ODV(BZS5PLb03iVeJLAaqQHKcKACsnIkJnCHdYhOLAiJAa6lIkd28LBZS5PLb8ZNdG7j8l4ihic(e9fvhj2H8f9tnhT71RAXwTGbPQCIHKxJl14KAevgB4chKpql1qg1ae14KA2KoKde9xT2bGvOA)cqx(IOYGnFr1ITAbdsv5edPpFo07NWVGJCGi4t0xuDKyhYx0p1C0Ux)vRDSy3LeTxJl14KA4feAZMXtnKvtn6XDQXj1y5Iq4kLMeMw)vRDSy3Le9cu4fsi1qwn1Od1ae1qa1SjDihi6VnIad7JwplCKdebPgD)IOYGnF5Q1owS7sI(ZNdo3t4xWroqe8j6lQosSd5lhT71F1Ahl2Djr714snoPglxecxP0KW06VATJf7UKOxGcVqcPgaKA0HAaIAiGA2KoKde93grGH9rRNfoYbIGuJUFruzWMVC1Ahl2Djr)5Zba7j8l4ihic(e9fvhj2H8LJ296B0Ygzu4kzjY7BKxIXsnayn1OhQbGOgskWViQmyZxswI8lEXMy74ZNdGC)j8l4ihic(e9fvhj2H8frLXgUWb5d0snKvtnCc14KA0HA0p1Gwlok0FGmg4IDxzfUWb5D45faUSMACZnQrhQbTwCuO)azmWf7UYkCHdY7WZlaCzn14KA0HAoA3R3IywfdPvlKqVgxQXn3OgfJbbz6B8hiJbUy3vwHlCqEh(g5LySudzuda4o1Ol1Ol1O7xevgS5lwTbe7yi95Zbqa9e(fCKdebFI(IQJe7q(IOYydx4G8bAPgYOgG(IOYGnF5YuAweCjad7iX1bf(pFoasppHFbh5arWNOVO6iXoKViQm2WfoiFGwQHmQbOViQmyZx4Q1X1rmKwhOyZpFoaItEc)coYbIGprFr1rIDiFruzSHlCq(aTudzudqFruzWMV0bxUqCfZYYvu4NphabapHFbh5arWNOVO6iXoKVKceN0dLb0cdq0JJCGii14KA0p1C0UxpugqlmarVgxQXj1OQKMeAx3wuzWgbsnKrna517ViQmyZxAMA)jsS)85ai96j8l4ihic(e9fvhj2H8fDOgbyyhj6hj1AbUQKMNno84ihicsnoPMJ296hj1AbUQKMNnow3MztFJ8smwQbaRPg9qnae1qsbsn6snoPMuG4K(kjG2K18ECKdebPgNuZM0HCGO)Q1oaScv7xUcI(IOYGnF52mBEAza)85aiG7j8l4ihic(e9fvhj2H8fDOgbyyhj6hj1AbUQKMNno84ihicsnoPMJ296hj1AbUQKMNnow3OrFJ8smwQbaRPg9qnae1qsbsn6(frLbB(Yfk8yYgsA4NphaP3pHFbh5arWNOVO6iXoKVOd1iad7ir)iPwlWvL08SXHhh5arqQXj1C0Ux)iPwlWvL08SXXAKuRrFJ8smwQbaRPg9qnae1qsbsn6snoPgEbH2Sz8udasn6T7FruzWMV0m1(tKy)5NFrbAFcFoa6j8l4ihic(NVO6iXoKViad7irVmk0MTaxnAzJmk0JJCGi4xevgS5lhiJbc1S5Nph65j8l4ihic(e9fvhj2H8LnPd5arVIXGGm9nlRJr9frLbB(YbBl27JH0NphCYt4xWroqe8j6lQosSd5lBshYbIEfJbbz6BwwhJ6lIkd28LdKXaxxT2XNphaWt4xWroqe8j6lQosSd5lBshYbIEfJbbz6BwwhJ6lIkd28LB04bYyGF(COxpHFbh5arWNOVO6iXoKVSjDihi6vmgeKPVzzDmQViQmyZxKrH2Sf4sjq4Npha3t4xWroqe8j6lQosSd5lhT71lwfoGYOqVgxQXn3Og9tnPaXj9IvHdOmk0JJCGii14KAUylWLLB0r6BKxIXsnKrn6f14MButknjm9zWJRKTadKAaWAQb4C)lIkd28fUSmyZNph69t4xevgS5lK0KgmKzXUlbyyZYQVGJCGi4t0NphCUNWViQmyZxUylWLLB0r(fCKdebFI(85aG9e(fCKdebFI(IQJe7q(slb4c3Wj9ciO1hd1qg1aWCNACZnQruzSHlCq(aTudzudqFruzWMVCGmg4IDxzfUWb5D85ZbqU)e(fCKdebFI(IQJe7q(IIXGGm9nEB2XE03iVeJLAiJAC)lIkd28fXQWbugf(5Zbqa9e(frLbB(IMfxrI82VGJCGi4t0NF(fXQEcFoa6j8l4ihic(e9fvhj2H8f9tnhT71RAXwTGbPQCIHKxJl14KAevgB4chKpql1qg1ae14KA2KoKde9xT2bGvOA)cqx(IOYGnFr1ITAbdsv5edPpFo0Zt4xWroqe8j6lQosSd5lPaXj9qzaTWae94ihicsnoPg9tnhT71dLb0cdq0RXLACsnQkPjH21TfvgSrGudzudqE9(lIkd28LMP2FIe7pFo4KNWViQmyZx0xmG2SJ94xWroqe8j6Zp)8lByBd28COh3bcG5UE7oaZdeWPxFrFspXqY(faoa(aCYbaFoCLYvtnudHvi1e8CzDsnxwtnUQBaHy7QOMgDLrlAeKASmEKAeTKXljcsnQkziHwpDNlXGuJE5QPgxzhRgxUSorqQruzWgQXvLvAdi2QkPjHUkpDhDhaFEUSorqQbi3PgrLbBOgyytRNU7lCB2nG4x4uQb4nvYOqECsQPuj8Yq3XPutvMCTUAYjNuKvAhVIXtUn41GsgSr1Ynj3g8kYP74uQb4RrsZMudqUtm1Oh3bcGrnCEQrpU7Qba3P7O74uQbWkziHwxnDhNsnCEQb4dcIGud3gvm(JKudHSe5Pgx5InX2HNUJtPgop1aWJnUQKA0Si1a8KoROgGhe5Xjfi1OJv2qQjsQ5YAQrldyKo01t3r3XPudWZvcQ0seKAo4L1i1Oy8hjPMdskgRNAa(kfYnTuZWgoFL08xni1iQmyJLAyd0HNUJtPgrLbBSEUnQy8hjRVqXUNUJtPgrLbBSEUnQy8hjjOM8lJbs3XPuJOYGnwp3gvm(JKeutUOrIhNuYGn0DCk1ugHRTILutlbi1C0UxeKASPKwQ5GxwJuJIXFKKAoiPySuJmGud3g58CzzgdjQjSudiBqpDhNsnIkd2y9CBuX4pssqn52r4ARy5YMsAP7evgSX652OIXFKKGAYtwI8lEXMy7GUtuzWgRNBJkg)rscQjhgKQYjgslBvGqq6orLbBSEUnQy8hjjOMCUSmydDhDhNsnapxjOslrqQb3W2b1KbpsnzfsnIkzn1ewQr2Kakhi6P7evgSXwRVyax2kuA6ooLAa(zI8CtQjzuJ1XOOMwuHaPgfJbbz6BSuJ(ISIAa(wfoGYOqQH1uJRaBbsnfUrhPLyQH1uJMfPg2qnkgdcY03qnXLASYwmKOMSc5Pg9fqi10OvdMutmuJninXnuYKuJIXGGm9nuJ(eBI0DIkd2yjOM8nPd5arIhHhRvmgeKPVzzDmkI3eOgwRtkqCsVyv4akJc94ihic6uNJ296fRchqzuOxJRBUPymiitFJxSkCaLrH(g5LySKPxURRUU5Mo6pfioPxSkCaLrHECKdebDQZfBbUSCJosFJ8smwY0l3CtXyqqM(g)fBbUSCJosFJ8smwY0l31vx6ooLAa4XOMHLuJMfPgHA4feAZMXZ5vmBgdjQrobmshutCPMiPg9fqi1C6yirnoyAutYOg3PgEbH2Sz8uJmGuJsgfcPMRw7GAyxQrI2t3jQmyJLGAY3KoKdejEeES(Q1oaScv7xLcXBcudR5feAZMXtwToPaXj9xT2XIDxs0ECKdebbiDaocevgSXBtwZBZo2JEfZM6QlDNOYGnwcQjFt6qoqK4r4X6Rw7aWkuTF5IleVjqnSMxqOnBgpz16KceN0F1Ahl2Djr7XroqeeG0b4iquzWgpu2KfuSvEfZM6QlDNOYGnwcQjFt6qoqK4r4X6Rw7aWkuTFbOleVjqnSMxqOnBgpz16KceN0F1Ahl2Djr7XroqeeG0b4iquzWgVQfB1cgKQYjgsEfZM6QlDNOYGnwcQjFt6qoqK4r4X6Rw7aWkuTF5kiI4nbQH18ccTzZ4jRwNuG4K(Rw7yXUljApoYbIGaKoahbIkd24VnZMNwgqVIztD1LUtuzWglb1KVjDihis8i8y9vRDayfQ2VaEfI3eOgwZli0MnJNSADsbIt6VATJf7UKO94ihiccq6aCeiQmyJhLoRWzz5g7rVIztD1LUtuzWglb1KVjDihis8i8y9vRDayfQ2VCHiI3eOgwZli0MnJNSADsbIt6VATJf7UKO94ihiccq6aCeaaURRU0DCk1a8Ze55MutYOgUmgKA4feAZMXtnwg14GP5QGqQ5GuJCGi1KmQrj2KAeQ5QbHo48Cz6dBeKAGbPQCIHe1CyWKAel1yzSHAel1ePRYsnYMeq5arQrFv4qn3GuvgdjQHni1KstctpDNOYGnwcQjFt6qoqK4r4XAodqxZyqI3eOgwRJOYydx4G8bAjdi3CthfJbbz6B8WGuvoXqADyW03iVeJLSA9aqKuG6QlDNOYGnwcQjFt6qoqK4r4XAodqxZyWvPq8Ma1WAD2KoKde9CgGUMXGU5gVGqB2mEYQ1jfioPNTHTQsAsOhh5arqashaWDcevgSXBtwZBZo2JEfZM6QRU0DIkd2yjOM8nPd5arIhHhR5maDnJbxU4cXBcudR1zt6qoq0Zza6Agd6MB8ccTzZ4jRwNuG4KE2g2QkPjHECKdebbiDaa3jquzWgpu2KfuSvEfZM6QRU0DIkd2yjOM8nPd5arIhHhR5maDnJbxa6cXBcudR1zt6qoq0Zza6Agd6MB8ccTzZ4jRwNuG4KE2g2QkPjHECKdebbiDaa3jquzWgVQfB1cgKQYjgsEfZM6QRU0DIkd2yjOM8nPd5arIhHhR5maDnJbxUcIiEtGAyToBshYbIEodqxZyq3CJxqOnBgpz16KceN0Z2Wwvjnj0JJCGiiaPda4obIkd24VnZMNwgqVIztD1vx6ooLAa(zI8CtQjzudxgdsn8ccTzZ4PMlRPgaBXwrnUeKQYjgsutCPgEnygCHi1Kstctl1insnCB0It6P7evgSXsqn5BshYbIepcpwdOlUMXGlxCH4nbQH1IkJnCHdYhOTgi3CJxqOnBgpz16iQmyJx1ITAbdsv5edjVIztcevgSXdLnzbfBLxXSPU0DIkd2yjOM8nPd5arIhHhRb0fxZyWvPq8Ma1WArLXgUWb5d0wdKBUXli0MnJNSADevgSXRAXwTGbPQCIHKxXSjbIkd24TjR5Tzh7rVIztDP7evgSXsqn5BshYbIepcpwFBebg2hTEw4ihics8Ma1WADsbIt6Ry5QsgqpoYbIGotbIt6RKaAtwZ7Xroqe0PamSJe9C7GxGlUDWJThh5arqDP7evgSXsqn5BshYbIepcpw3m1ElmaXfoYbIGeVjqnSwh9VjDihi6VnIad7JwplCKdebDQtkqCs)HPbbX(g20JJCGiOZuG4KEOmGwyaIECKdebDkad7irVnBCiLvl2DHsNvECKdeb1vx6orLbBSeutUsGWLOYGnlyytIhHhRzCXbB6orLbBSeutUsGWLOYGnlyytIhHhRfRI44wF0UxVyv4akJc9ACP7evgSXsqn5kbcxIkd2SGHnjEeESMBhSosh0DIkd2yjOMCLaHlrLbBwWWMepcpwZlXK4iJcjoU1IkJnCHdYhOfa5e6orLbBSeutUsGWLOYGnlyytIhHhRvGw6orLbBSeutUsGWLOYGnlyytIhHhRVnIad7JwplfRrIJB9M0HCGO)2icmSpA9SWroqeKUtuzWglb1KReiCjQmyZcg2K4r4XAq8kAWCPynsCCR1)M0HCGO)2icmSpA9SWroqeKUtuzWglb1KReiCjQmyZcg2K4r4XAEjMehzuiXXTwuzSHlCq(aTKvZj0DIkd2yjOMCLaHlrLbBwWWMepcpwFdieB6o6orLbBSEXQQvTyRwWGuvoXqI44wR)J296vTyRwWGuvoXqYRX1POYydx4G8bAjdiNBshYbI(Rw7aWkuTFbOl0DIkd2y9Ivrqn5ntT)ej2eh36uG4KEOmGwyaIECKdebDQ)J296HYaAHbi6146uvjnj0UUTOYGncKmG86nDNOYGnwVyveutU(Ib0MDShP7O74uQbqXMudrqgdeQztQHxgnbcDqnXLAYkKAa(ad7irQHWwIKAa(JcTzlqQbGt0Ygzui1ewQHBJwCspDNOYGnwVc0wFGmgiuZMeh3Abyyhj6LrH2Sf4QrlBKrHECKdebP7evgSX6vGwcQj)GTf79XqI44wVjDihi6vmgeKPVzzDmk6orLbBSEfOLGAYpqgdCD1Aheh36nPd5arVIXGGm9nlRJrr3jQmyJ1RaTeut(nA8azmqIJB9M0HCGOxXyqqM(ML1XOO7evgSX6vGwcQjxgfAZwGlLaHeh36nPd5arVIXGGm9nlRJrr3XPudWptKNBsnjJASogf14GP1udapxxOgUSmyd1OViROgHAumgeKPVHyQrBGO1snzfsnP0KWKAcl1ihMwsnjJAad0t3jQmyJ1RaTeutoxwgSH44wF0UxVyv4akJc9ACDZn9NceN0lwfoGYOqpoYbIGoVylWLLB0r6BKxIXsME5MBP0KW0NbpUs2cmqaSg4CNUtuzWgRxbAjOMCsAsdgYSy3LamSzzfDNOYGnwVc0sqn5xSf4YYn6iP7evgSX6vGwcQj)azmWf7UYkCHdY7G44w3saUWnCsVacA9XqgaZD3CtuzSHlCq(aTKbeDNOYGnwVc0sqn5IvHdOmkK44wRymiitFJ3MDSh9nYlXyjZD6orLbBSEfOLGAY1S4ksK3s3XPuJOYGnwVc0sqn5O0z1cHipoPaP7O7evgSX6bXRObZLI1ynkDwHZYYn2Jeh36nPd5ar)vRDayfQ2VaEf6orLbBSEq8kAWCPynsqn52K182SJ9iXkhkiUsPjHPTgiIJBTOYydx4G8bAjdiNcWWos0ddsv5edPLInGAr6Xroqe0P(bXJ296HbPQCIH0sXgqTi9ACDUjDihi6VATdaRq1(vPq3jQmyJ1dIxrdMlfRrcQj3MSM3MDShjoU1hT71BtwZF6yiHTxJRBUPJOYydx4G8bAjdiNhT71tsYkSJH0YMSM36146Ct6qoq0F1AhawHQ9Rsrx6orLbBSEq8kAWCPynsqn5QwSvlyqQkNyirCCRfvgB4chKpqlz1CIZnPd5ar)vRDayfQ2Va0f6orLbBSEq8kAWCPynsqn5WGuvoXqADyWK44wNceN0Z2Wwvjnj0JJCGiOtrLXgUWb5d0wdKZnPd5ar)vRDayfQ2VCHiN8ccTzZ4jRgaCNUtuzWgRheVIgmxkwJeutUnznVn7ypsCCR3KoKde9CgGUMXGRsX5M0HCGO)Q1oaScv7xLcDhDNOYGnw)nGqSRTAdi2XqI44w3saUWnCsVacA9Xqga4oDNOYGnw)nGqSjOM8ltPzrWLamSJexhu4joU1TeGlCdN0lGGwFmKbWC3P(pA3RxSkCaLrHEnUo1)r7E98myIZsFOWLnEnUo1)r7E9HYXcbjHEnUo1)r7E9Qwu7HXqAz1AsOxJRt9dIhT71JsNv4SSCJ9OxJlDNOYGnw)nGqSjOMCUADCDedP1bk2K44w3saUWnCsVacA9XqgW5oDNOYGnw)nGqSjOM8o4YfIRywwUIcjoU1TeGlCdN0lGGwFmKbCUt3jQmyJ1FdieBcQjpR0gqSvvstcP7evgSX6VbeInb1KRyJcNSLebxxOWJ0DIkd2y93acXMGAYvTyRwWGuvoXqI44wNceN0FzTcVAWL(Ib06Xroqe0POYydx4G8bAjdiNBshYbI(Rw7aWkuTFbOl0DIkd2y93acXMGAYVqHht2qsdjoU1PaXj9wu6yiTeRv0GPhh5arq6orLbBS(BaHytqn5qztwqXwrCCR1VamSJe9C7GxGlUDWJThh5arqNPaXj9vSCvjdOhh5arqNhT71xXYvLmG(gfvs3jQmyJ1FdieBcQjx1ITAbdsv5edjIJBTOYydx4G8bAjdiNBshYbI(Rw7aWkuTFbOl0DIkd2y93acXMGAYBMA)jsSjoU18ccTzZ4bq92DN6)ODVEB24qkRwS7cLoR8ACP7evgSX6VbeInb1KRAXwTGbPQCIHeXXTofioPx1ITkgslBYAEpoYbIGo3KoKde9CgGUMXGlaDHUtuzWgR)gqi2eutou2KfuSveh36nPd5arpNbORzm4YfxCUjDihi6VATdaRq1(LlUq3jQmyJ1FdieBcQjNh5zTJf7UGAQaCb2OWBP7evgSX6VbeInb1K3m1(tKyt3jQmyJ1FdieBcQj)2mBEAzajoU1PaXj9vsaTjR594ihic68ODV(BZS5PLb03iVeJfabapNJaskqNBshYbI(Rw7aWkuTF5kiIUtuzWgR)gqi2eut(fk8yYgsAiDNOYGnw)nGqSjOMC9XAi4ggZQrlBKrHeh36J296HXfpqgd0BtrThaba6o6orLbBS(BJiWW(O1ZsXASgkBYck2kIvouqCLstctBnqeh3Abyyhj652bVaxC7GhBFlZEYQ1Jtq8ODVEUDWlWf3o4X2BtrTVgi3DUjDihi6VATdaRq1(LlU4Ct6qoq0dOlUMXGlxCHUtuzWgR)2icmSpA9SuSgjOMCu6ScNLLBShjoU1BshYbI(Rw7aWkuTFb8k0DIkd2y93grGH9rRNLI1ib1KBtwZBZo2JeRCOG4kLMeM2AGioU1IkJnCHdYhOLmGCkad7irpmivLtmKwk2aQfPhh5arqN6hepA3RhgKQYjgslfBa1I0RX15M0HCGO)Q1oaScv7xLcDNOYGnw)TreyyF06zPynsqn52K182SJ9iXXT(ODVEBYA(thdjS9ACDZnDevgB4chKpqlza58ODVEsswHDmKw2K18wVgxNBshYbI(Rw7aWkuTFvk6s3jQmyJ1FBebg2hTEwkwJeutUQfB1cgKQYjgseh3ArLXgUWb5d0swnN4Ct6qoq0F1AhawHQ9laDHUtuzWgR)2icmSpA9SuSgjOMCyqQkNyiTomysCCRtbIt6zByRQKMe6Xroqe0POYydx4G8bARbY5M0HCGO)Q1oaScv7xUqKtEbH2Sz8KvdaUt3jQmyJ1FBebg2hTEwkwJeutou2KfuSveh3Abyyhj652bVaxC7GhBFlZEYQ1Jtq8ODVEUDWlWf3o4X2BtrTNm925M0HCGO)Q1oaScv7xU4IZnPd5arpGU4AgdUCXf6orLbBS(BJiWW(O1ZsXAKGAYTjR5Tzh7rIJB9M0HCGONZa01mgCvko3KoKde9xT2bGvOA)QuCUjDihi6b0fxZyWvPq3jQmyJ1FBebg2hTEwkwJeutou2KfuSveh3Aq8ODVEUDWlWf3o4X2BtrTVgi3DUjDihi6VATdaRq1(LlUq3r3jQmyJ1ZlXK4iJcRVqHht2qsdjoU16)ODV(lu4XKnK0qVgx6orLbBSEEjMehzuib1KFBMnpTmGeh36uG4K(kjG2K18ECKdebDQ)J296VnZMNwgqVgxNBshYbI(Rw7aWkuTF5kiIUJUtuzWgRNXfhSRBMA)jsSjoU18ccTzZ4bqG0lNzWJaijfiDhDNOYGnwp3oyDKoQvTyRwWGuvoXqI44wlQm2WfoiFGwYQ1HZX51jfioP)YAfE1Gl9fdO1JJCGiiaXj6QRZnPd5ar)TreyyF06zHJCGiOZnPd5ar)vRDayfQ2Va0f6orLbBSEUDW6iDqqn5zfU0MdtBaxxwRqIJB9r7E9nQ2drRDDzTc9ACDZTm4rauVO7evgSX652bRJ0bb1KdLnzbfBfXXTwag2rIEUDWlWf3o4X23YSNSA94eepA3RNBh8cCXTdES92uu7RbYDNIkJnCHdYhOTgiNBshYbI(BJiWW(O1Zch5arqNBshYbI(Rw7aWkuTF5Il0DIkd2y9C7G1r6GGAYVqHht2qsdjoU1BshYbI(BJiWW(O1Zch5arqNhT71FHcpMSHKg6BKxIXcGKuGofvgB4chKpqlzar3jQmyJ1ZTdwhPdcQj)2mBEAzajoU1BshYbI(BJiWW(O1Zch5arqNhT71FBMnpTmG(g5LySaijfOtrLXgUWb5d0sgq0DIkd2y9C7G1r6GGAYvTyRwWGuvoXqI44wR)J296vTyRwWGuvoXqYRX1POYydx4G8bAjdiNBshYbI(Rw7aWkuTFbOl0DIkd2y9C7G1r6GGAYVATJf7UKOjoU16)ODV(Rw7yXUljAVgxN8ccTzZ4jRwpU70YfHWvknjmT(Rw7yXUlj6fOWlKqYQ1bic2KoKde93grGH9rRNfoYbIG6s3jQmyJ1ZTdwhPdcQj)Q1owS7sIM44wF0Ux)vRDSy3LeTxJRtlxecxP0KW06VATJf7UKOxGcVqcbqDaIGnPd5ar)TreyyF06zHJCGiOU0DIkd2y9C7G1r6GGAYtwI8lEXMy7G44wF0UxFJw2iJcxjlrEFJ8smwaSwpaejfiDNOYGnwp3oyDKoiOMCR2aIDmKioU1IkJnCHdYhOLSAoXPo6hTwCuO)azmWf7UYkCHdY7WZlaCzTBUPdAT4Oq)bYyGl2DLv4chK3HNxa4YAN6C0UxVfXSkgsRwiHEnUU5MIXGGm9n(dKXaxS7kRWfoiVdFJ8smwYaa31vxDP7evgSX652bRJ0bb1KFzknlcUeGHDK46GcpXXTwuzSHlCq(aTKbeDNOYGnwp3oyDKoiOMCUADCDedP1bk2K44wlQm2WfoiFGwYaIUtuzWgRNBhSosheutEhC5cXvmllxrHeh3ArLXgUWb5d0sgq0DIkd2y9C7G1r6GGAYBMA)jsSjoU1PaXj9qzaTWae94ihic6u)hT71dLb0cdq0RX1PQsAsODDBrLbBeiza51B6ooLAa4iYkQHdj1AbsnUslnpBCqm1GqCtsKAYkKA42bRJ0b1WUudcrECsbsnsMIAVLAIHAyni2utYOgEjMuIHAYkKAoA3RLA0xfoutwHoCvnsnYHPLutYOg0vc3OrpDNOYGnwp3oyDKoiOM8BZS5PLbK44wRJamSJe9JKATaxvsZZghECKdebDE0Ux)iPwlWvL08SXX62mB6BKxIXcG16bGiPa11zkqCsFLeqBYAEpoYbIGo3KoKde9xT2bGvOA)YvqeDNOYGnwp3oyDKoiOM8lu4XKnK0qIJBTocWWos0psQ1cCvjnpBC4Xroqe05r7E9JKATaxvsZZghRB0OVrEjglawRhaIKcux6orLbBSEUDW6iDqqn5ntT)ej2eh3ADeGHDKOFKuRf4QsAE24WJJCGiOZJ296hj1AbUQKMNnowJKAn6BKxIXcG16bGiPa11jVGqB2mEauVD)lwUO65qpahN85N)d]] )


end
