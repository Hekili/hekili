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
        }
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

        potion = "battle_potion_of_agility",

        package = "Enhancement",
    } )


    spec:RegisterPack( "Enhancement", 20190709.1650, [[dKuWubqiQq9iaL2ev0NOcrnksrNIuXQaqEfGmlKs3cqvTlj(fsvddiCmKklJkWZaumnauxdiQTbOY3OcPXrLuCoQu06auLMhvkDpjzFKkDqQqyHaPhcqtKkPuxKkf2ivs1iPcrQtsLusRufzMujUjvsj2jPWpbImuQKSuQqepLQMksXxPcrYEv1FvYGP4WelwPEmjtgjxgAZQ0NbQrlPoTOvdOk8AvuZg0TrLDR43OmCsPLl1ZP00fUoQA7QW3PcA8aQIopPQ1daZNkv7hXpDpnVNsc81WbGGo3eeokiCZcDahi7MaSJ((qVw89Af1zbm((r4W37gtTmkKdN49Af9qMq908ElJVv47RJqRf4LE6bNrn)UOyC0BtoEOejBuTCd6TjNI(3V5ty4AD(97PKaFnCaiOZnbHJcc3SqhWbYVx4JAw)EFYXdLizdGTCJ3xNuu4873tHw17bwIXnMAzuihobX4RfoziNawIPocTwGx6PhCg187IIXrVn54HsKSr1YnO3MCk6jNawI5epupX4M0smoae05MedWNyOd4aEbzqqorobSedG1YagTaVKtalXa8jghbffsrmABuX42sqm0WcKJyCTi2aB9fYjGLya(eJJe82OTMyC9MzJDldf9Uou4WGnG5rIjhIXrasUbXCznX46nIaaBq57Hy28jKQqobSedWNyCTzJJCqm8wKyCdPJAIXnGihoHajgnTYbsmzqmxwtm8rcZqVoL3dtByFAEptloy)08Aq3tZ7Xr2qK6b99QodSt59CccTrZ4ig3sm0bYeJtIjsoKyClXawr9ErfjBEFZuN3zG9hF8EojNahzu4tZRbDpnVhhzdrQh03R6mWoL37yIzZFVLlu4WGnG5XcV23lQizZ7VqHdd2aMh)41WbpnVhhzdrQh03R6mWoL3hceNOulj0gSMRGJSHifX4KyCmXS5V3YTz2y3Yqv41smojMdPtzdXYLV1dynQoVCDqFVOIKnV)2mBSBzO(4J3FBeba2B(EwkwJpnVg0908ECKnePEqFVOIKnVhkhYck263R6mWoL3laa7mWI2o5e4sBNCyxAzotm6wrmoGyCsmu4M)ElA7KtGlTDYHDXgI6mXurm0bcIXjXCiDkBiwU8TEaRr15LlUqmojMdPtzdXcGU4kgdUCXL3R0RG4kKgmg2xd6(41WbpnVhhzdrQh03R6mWoL3FiDkBiwU8TEaRr15LB4FVOIKnVhLoQXzz1MNXpEnaMNM3JJSHi1d67fvKS592G1C2OZZ47vDgyNY7fvKh4chKlrlXOlXqhX4KyeaGDgybMGRJjhWlfBO4ZOGJSHifX4KyCmXqHB(7TatW1XKd4LInu8zu41smojMdPtzdXYLV1dynQoV8(3R0RG4kKgmg2xd6(41aGFAEpoYgIupOVx1zGDkVFZFVfBWAUDNdySl8Ajg3DNy0KyevKh4chKlrlXOlXqhX4Ky283BbSe1yNd4LnynNTWRLyCsmhsNYgILlFRhWAuDE59eJoVxurYM3BdwZzJopJF8AaYpnVhhzdrQh03R6mWoL3lQipWfoixIwIr3kIbyigNeZH0PSHy5Y36bSgvNxa6Y7fvKS59QwS1lycUoMCa)XRbW908ECKnePEqFVQZa7uEFiqCIc7aBvT0GXcoYgIueJtIrurEGlCqUeTetfXqhX4KyoKoLnelx(wpG1O68YfqjgNedNGqB0moIr3kIbGbX7fvKS59WeCDm5aETzW4Jxdh9P594iBis9G(EvNb2P8EbayNbw02jNaxA7Kd7slZzIr3kIXbeJtIHc383BrBNCcCPTtoSl2quNjgDjghLyCsmhsNYgILlFRhWAuDE5IleJtI5q6u2qSaOlUIXGlxC59Iks28EOCilOyR)41W1808ECKnePEqFVQZa7uE)H0PSHybKa0vmgC59eJtI5q6u2qSC5B9awJQZlVNyCsmhsNYgIfaDXvmgC59VxurYM3BdwZzJopJF8A4MpnVhhzdrQh03R6mWoL3tHB(7TOTtobU02jh2fBiQZetfXqhiigNeZH0PSHy5Y36bSgvNxU4Y7fvKS59q5qwqXw)XhVxrzFAEnO7P594iBis973R6mWoL3laa7mWImk0gTaxnAzJmkSGJSHi17fvKS59BiJrb5TXhVgo4P594iBis9G(EvNb2P8(dPtzdXIIXGumholR(r9ErfjBE)gBl2NZb8hVgaZtZ7Xr2qK6b99QodSt59hsNYgIffJbPyoCww9J69Iks28(nKXOwx(w)hVga8tZ7Xr2qK6b99QodSt59hsNYgIffJbPyoCww9J69Iks28(B24gYyuF8AaYpnVhhzdrQh03R6mWoL3FiDkBiwumgKI5Wzz1pQ3lQizZ7LrH2Of4sjq4hVga3tZ7Xr2qK6b99QodSt59B(7TiwfouYOWcVwIXD3jghtmHaXjkIvHdLmkSGJSHifX4KyUylWLvB2zuAKtYXsm6smGmX4U7etinymkrYHRGTOsKyCBfXaCG49Iks28ETSizZhVgo6tZ7fvKS59G5LMkLzXUlbayZI63JJSHi1d6hVgUMNM3lQizZ75qowRFXUliVkPwunkC23JJSHi1d6hVgU5tZ7fvKS59xSf4YQn7mEpoYgIupOF8AqhiEAEVOIKnVFdzmQf7UIACHdYP)94iBis9G(XRbD0908ECKnePEqFVQZa7uEVIXGumhofB05zS0iNKJLy0LyaX7fvKS59IvHdLmk8Jxd6CWtZ7fvKS598wCLbYzFpoYgIupOF8X7fR6P51GUNM3JJSHi1d67vDgyNY7DmXS5V3IQfB9cMGRJjhWfETeJtIrurEGlCqUeTeJUedDeJtI5q6u2qSC5B9awJQZlaD59Iks28Evl26fmbxhtoG)41WbpnVhhzdrQh03R6mWoL3hceNOaLHYctkSGJSHifX4KyCmXS5V3cugklmPWcVwIXjXOQLgmAx3wurYgbsm6sm0vC03lQizZ7BM68odS)41ayEAEVOIKnV3H5qzJopJVhhzdrQh0p(49u4v4HXsXA8P51GUNM3JJSHi1d67vDgyNY7pKoLnelx(wpG1O68Yn8VxurYM3Jsh14SSAZZ4hVgo4P594iBis9G(ErfjBEVnynNn68m(EvNb2P8Erf5bUWb5s0sm6sm0rmojgbayNbwGj46yYb8sXgk(mk4iBisrmojghtmu4M)ElWeCDm5aEPydfFgfETeJtI5q6u2qSC5B9awJQZlV)9k9kiUcPbJH91GUpEnaMNM3JJSHi1d67vDgyNY7383BXgSMB35ag7cVwIXD3jgnjgrf5bUWb5s0sm6sm0rmojMn)9walrn25aEzdwZzl8AjgNeZH0PSHy5Y36bSgvNxEpXOZ7fvKS592G1C2OZZ4hVga8tZ7Xr2qK6b99QodSt59IkYdCHdYLOLy0TIyagIXjXCiDkBiwU8TEaRr15fGU8ErfjBEVQfB9cMGRJjhWF8AaYpnVhhzdrQh03R6mWoL3hceNOWoWwvlnySGJSHifX4KyevKh4chKlrlXurm0rmojMdPtzdXYLV1dynQoVCbuIXjXWji0gnJJy0TIyayq8ErfjBEpmbxhtoGxBgm(41a4EAEpoYgIupOVx1zGDkV)q6u2qSasa6kgdU8EIXjXCiDkBiwU8TEaRr15L3)ErfjBEVnynNn68m(XhV)Mqi2pnVg0908ECKnePEqFVQZa7uEVOI8ax4GCjAjg3smaZ7fvKS59w(Hc7Ca)XRHdEAEpoYgIupOVx1zGDkV3XeZM)ElIvHdLmkSWRLyCsmoMy283BHJbdCwoefTSPWRLyCsmoMy283Bjv6xifySWRLyCsmoMy283Br1I6mmhWllFdgl8AjgNeJJjgkCZFVfu6OgNLvBEgl8AFVOIKnV)Yu8wKAjaa7mW1gfUpEnaMNM3lQizZ71Y35vFoGxBOyJ3JJSHi1d6hVga8tZ7fvKS59k2OWjAjqQ1fkC47Xr2qK6b9Jxdq(P594iBis9G(EvNb2P8(n)9wG5f3qgJQydrDMyClXaWVxurYM37qwdPoWCwnAzJmk8JxdG7P594iBis9G(EvNb2P8(qG4eLlRv4LhUCyou2coYgIueJtIrurEGlCqUeTeJUedDeJtI5q6u2qSC5B9awJQZlaD59Iks28Evl26fmbxhtoG)41WrFAEpoYgIupOVx1zGDkVpeiorXIsNd4LyTcpmk4iBis9ErfjBE)fkCyWgW84hVgUMNM3JJSHi1d67vDgyNY7DmXiaa7mWI2o5e4sBNCyxWr2qKIyCsmHaXjk1SyvldvbhzdrkIXjXS5V3snlw1YqvAuuX7fvKS59q5qwqXw)XRHB(08ECKnePEqFVQZa7uEVOI8ax4GCjAjgDjg6igNeZH0PSHy5Y36bSgvNxa6Y7fvKS59QwS1lycUoMCa)XRbDG4P594iBis9G(EvNb2P8EobH2OzCeJBjghfeeJtIXXeZM)El2OXbCuVy3fkDux41(ErfjBEFZuN3zG9hVg0r3tZ7Xr2qK6b99QodSt59HaXjkQwS15aEzdwZvWr2qKIyCsmhsNYgIfqcqxXyWfGU8ErfjBEVQfB9cMGRJjhWF8AqNdEAEpoYgIupOVx1zGDkV)q6u2qSasa6kgdUCXfIXjXCiDkBiwU8TEaRr15LlU8ErfjBEpuoKfuS1F8AqhW808ErfjBEFZuN3zG97Xr2qK6b9Jxd6a4NM3JJSHi1d67vDgyNY7dbItuQLeAdwZvWr2qKIyCsmB(7TCBMn2TmuLg5KCSeJBjgaU4AigGigWkkIXjXCiDkBiwU8TEaRr15LRd67fvKS593MzJDld1hVg0bYpnVxurYM3FHchgSbmp(ECKnePEq)4J3RTtwNH(NMxd6EAEpoYgIupOVx1zGDkVxurEGlCqUeTeJUveJMeJRHya(eJMetiqCIYL1k8YdxomhkBbhzdrkIbGigGHy0Hy0HyCsmhsNYgILBJiaWEZ3ZchzdrkIXjXCiDkBiwU8TEaRr15fGU8ErfjBEVQfB9cMGRJjhWF8A4GNM3JJSHi1d67vDgyNY7383BPr1ziATRlRvyHxlX4U7etKCiX4wIbKFVOIKnVpQXf)Sz8d16YAf(XRbW808ECKnePEqFVQZa7uEVaaSZalA7KtGlTDYHDPL5mXOBfX4aIXjXqHB(7TOTtobU02jh2fBiQZetfXqhiigNeJOI8ax4GCjAjMkIHoIXjXCiDkBiwUnIaa7nFplCKnePigNeZH0PSHy5Y36bSgvNxU4Y7fvKS59q5qwqXw)XRba)08ECKnePEqFVQZa7uE)H0PSHy52icaS389SWr2qKIyCsmB(7TCHchgSbmpwAKtYXsmULyaROigNeJOI8ax4GCjAjgDjg6EVOIKnV)cfomydyE8Jxdq(P594iBis9G(EvNb2P8(dPtzdXYTreayV57zHJSHifX4Ky283B52mBSBzOknYj5yjg3smGvueJtIrurEGlCqUeTeJUedDVxurYM3FBMn2TmuF8AaCpnVhhzdrQh03R6mWoL37yIzZFVfvl26fmbxhtoGl8AjgNeJOI8ax4GCjAjgDjg6igNeZH0PSHy5Y36bSgvNxa6Y7fvKS59QwS1lycUoMCa)XRHJ(08ECKnePEqFVQZa7uEVJjMn)9wU8T(f7UKSl8AjgNedNGqB0moIr3kIXbGGyCsmwTieUcPbJHTC5B9l2DjzVOeobmsm6wrmAsm0rmarmhsNYgILBJiaWEZ3ZchzdrkIrN3lQizZ7V8T(f7UKS)41W1808ECKnePEqFVQZa7uE)M)Elx(w)IDxs2fETeJtIXjXy1Iq4kKgmg2YLV1Vy3LK9Is4eWiX4wIrtIHoIbiI5q6u2qSCBeba2B(Ew4iBisrm68ErfjBE)LV1Vy3LK9hVgU5tZ7Xr2qK6b99QodSt59B(7T0OLnYOWvWcKR0iNKJLyCBfX4aIbGigWkQ3lQizZ7dwGCloXgyR)Jxd6aXtZ7Xr2qK6b99QodSt59IkYdCHdYLOLy0TIyagIXjXOjX4yIbTwCuyzdzmQf7UIACHdYPVWjapynX4U7eJMedAT4OWYgYyul2Df14chKtFHtaEWAIXjXOjXS5V3IfXOohWRwaJfETeJ7UtmkgdsXC4u2qgJAXUROgx4GC6lnYj5yjgDjgageeJoeJoeJoVxurYM3B5hkSZb8hVg0r3tZ7Xr2qK6b99QodSt59IkYdCHdYLOLy0TIyaM3lQizZ7VmfVfPwcaWodCTrH7Jxd6CWtZ7Xr2qK6b99QodSt59IkYdCHdYLOLy0TIyaM3lQizZ71Y35vFoGxBOyJpEnOdyEAEpoYgIupOVx1zGDkVpeiorbkdLfMuybhzdrkIXjX4yIzZFVfOmuwysHfETeJtIrvlny0UUTOIKncKy0LyOR4OVxurYM33m15Dgy)XRbDa8tZ7Xr2qK6b99QodSt59AsmcaWodSmsW3cCvlnhB0xWr2qKIyCsmB(7TmsW3cCvlnhB0VUnZgLg5KCSeJBRighqmaeXawrrm6qmojMqG4eLAjH2G1CfCKnePigNeZH0PSHy5Y36bSgvNxUoOVxurYM3FBMn2TmuF8Aqhi)08ECKnePEqFVQZa7uEVMeJaaSZalJe8Tax1sZXg9fCKnePigNeZM)ElJe8Tax1sZXg9RB2yProjhlX42kIXbedarmGvueJoVxurYM3FHchgSbmp(XRbDa3tZ7Xr2qK6b99QodSt59AsmcaWodSmsW3cCvlnhB0xWr2qKIyCsmB(7TmsW3cCvlnhB0Vgj4BS0iNKJLyCBfX4aIbGigWkkIrhIXjXWji0gnJJyClX4OG49Iks28(MPoVZa7p(49ABuX42s808Aq3tZ7fvKS59blqUfNydS1)ECKnePEq)41WbpnVxurYM3dtW1XKd4LTori17Xr2qK6b9JxdG5P59Iks28ETSizZ7Xr2qK6b9JpEpfEfEy808Aq3tZ7fvKS59omhQLTgL(94iBis9G(XRHdEAEpoYgIupOVNP99wmEVOIKnV)q6u2q89hcKhFVMetiqCIIyv4qjJcl4iBisrmojgnjMn)9weRchkzuyHxlX4U7eJIXGumhofXQWHsgfwAKtYXsm6smGmiigDigDig3DNy0KyCmXeceNOiwfouYOWcoYgIueJtIrtI5ITaxwTzNrProjhlXOlXaYeJ7UtmkgdsXC4uUylWLvB2zuAKtYXsm6smGmiigDigDE)H0Rr4W3RymifZHZYQFuF8AampnVhhzdrQh03Z0(ElgVxurYM3FiDkBi((dbYJVNtqOnAghXOBfXOjXeceNOC5B9l2DjzxWr2qKIyaiIrtIb4igGigrfjBk2G1C2OZZyrXSbXOdXOZ7pKEnch((lFRhWAuDE59F8AaWpnVhhzdrQh03Z0(ElgVxurYM3FiDkBi((dbYJVNtqOnAghXOBfXOjXeceNOC5B9l2DjzxWr2qKIyaiIrtIb4igGigrfjBkq5qwqXwxumBqm6qm68(dPxJWHV)Y36bSgvNxU4YhVgG8tZ7Xr2qK6b99mTV3IX7fvKS59hsNYgIV)qG8475eeAJMXrm6wrmAsmHaXjkx(w)IDxs2fCKnePigaIy0KyaoIbiIrurYMIQfB9cMGRJjhWffZgeJoeJoV)q61iC47V8TEaRr15fGU8XRbW908ECKnePEqFpt77Ty8ErfjBE)H0PSH47peip(EobH2OzCeJUveJMetiqCIYLV1Vy3LKDbhzdrkIbGignjgGJyaIyevKSPCBMn2TmuffZgeJoeJoV)q61iC47V8TEaRr15LRd6hVgo6tZ7Xr2qK6b99mTV3IX7fvKS59hsNYgIV)qG8475eeAJMXrm6wrmAsmHaXjkx(w)IDxs2fCKnePigaIy0KyaoIbiIrurYMckDuJZYQnpJffZgeJoeJoV)q61iC47V8TEaRr15LB4)41W1808ECKnePEqFpt77Ty8ErfjBE)H0PSH47peip(EobH2OzCeJUveJMetiqCIYLV1Vy3LKDbhzdrkIbGignjgGJyaIyayqqm6qm68(dPxJWHV)Y36bSgvNxUa6hVgU5tZ7Xr2qK6b99mTV3IX7fvKS59hsNYgIV)qG8471KyevKh4chKlrlXOlXqhX4U7eJMeJIXGumhofycUoMCaV2myuAKtYXsm6wrmoGyaiIbSIIy0Hy059hsVgHdFpibORym4hVg0bINM3JJSHi1d67zAFVfJ3lQizZ7pKoLneF)Ha5X3RjXCiDkBiwajaDfJbjg3DNy4eeAJMXrm6wrmAsmHaXjkSdSv1sdgl4iBisrmaeXOjXaWGGyaIyevKSPydwZzJopJffZgeJoeJoeJoV)q61iC47bjaDfJbxE)hVg0r3tZ7Xr2qK6b99mTV3IX7fvKS59hsNYgIV)qG8471KyoKoLnelGeGUIXGeJ7UtmCccTrZ4igDRignjMqG4ef2b2QAPbJfCKnePigaIy0KyayqqmarmIks2uGYHSGITUOy2Gy0Hy0Hy059hsVgHdFpibORym4Yfx(41Goh808ECKnePEqFpt77Ty8ErfjBE)H0PSH47peip(EnjMdPtzdXcibORymiX4U7edNGqB0moIr3kIrtIjeiorHDGTQwAWybhzdrkIbGignjgageedqeJOIKnfvl26fmbxhtoGlkMnigDigDigDE)H0Rr4W3dsa6kgdUa0LpEnOdyEAEpoYgIupOVNP99wmEVOIKnV)q6u2q89hcKhFVMeZH0PSHybKa0vmgKyC3DIHtqOnAghXOBfXOjXeceNOWoWwvlnySGJSHifXaqeJMedadcIbiIrurYMYTz2y3YqvumBqm6qm6qm68(dPxJWHVhKa0vmgC56G(XRbDa8tZ7Xr2qK6b99mTV3IX7fvKS59hsNYgIV)qG847fvKh4chKlrlXurm0rmU7oXWji0gnJJy0TIy0KyevKSPOAXwVGj46yYbCrXSbXaeXiQiztbkhYck26IIzdIrN3Fi9Aeo89a6IRym4Yfx(41Goq(P594iBis9G(EM23BX49Iks28(dPtzdX3FiqE89IkYdCHdYLOLyQig6ig3DNy4eeAJMXrm6wrmAsmIks2uuTyRxWeCDm5aUOy2GyaIyevKSPydwZzJopJffZgeJoV)q61iC47b0fxXyWL3)XRbDa3tZ7Xr2qK6b99mTV3IX7fvKS59hsNYgIV)qG8471KycbItuQzXQwgQcoYgIueJtIjeiorPwsOnynxbhzdrkIXjXiaa7mWI2o5e4sBNCyxWr2qKIy059hsVgHdF)TreayV57zHJSHi1hVg05OpnVhhzdrQh03Z0(ElgVxurYM3FiDkBi((dbYJVxtIXXeZH0PSHy52icaS389SWr2qKIyCsmAsmHaXjkBgpKc7BAJcoYgIueJtIjeiorbkdLfMuybhzdrkIXjXiaa7mWInACah1l2DHsh1fCKnePigDigDE)H0Rr4W33m1zlmPWfoYgIuF8AqNR5P594iBis9G(ErfjBEVsGWLOIKnlyAJ3dtBSgHdFptloy)XRbDU5tZ7Xr2qK6b99QodSt59B(7TiwfouYOWcV23lQizZ7vceUevKSzbtB8EyAJ1iC47fR6JxdhaINM3JJSHi1d67fvKS59kbcxIks2SGPnEpmTXAeo89A7K1zO)Jxdhq3tZ7Xr2qK6b99QodSt59IkYdCHdYLOLyClXamVxurYM3ReiCjQizZcM249W0gRr4W3Zj5e4iJc)41Wbo4P594iBis9G(ErfjBEVsGWLOIKnlyAJ3dtBSgHdFVIY(XRHdaMNM3JJSHi1d67vDgyNY7pKoLnel3graG9MVNfoYgIuVxurYM3ReiCjQizZcM249W0gRr4W3FBeba2B(EwkwJF8A4aa(P594iBis9G(EvNb2P8EhtmhsNYgILBJiaWEZ3ZchzdrQ3lQizZ7vceUevKSzbtB8EyAJ1iC47PWRWdJLI14hVgoaKFAEpoYgIupOVx1zGDkVxurEGlCqUeTeJUvedW8ErfjBEVsGWLOIKnlyAJ3dtBSgHdFpNKtGJmk8JxdhaCpnVhhzdrQh03lQizZ7vceUevKSzbtB8EyAJ1iC47VjeI9hF8X7pW2MS51WbGGo3eeokiCZcDahi)Ehk9Kdy77DTYPL1bsrm0bcIrurYgIbM2WwiNEVvlQEnCaWbmVxBZUjeFpWsmUXulJc5WjigFTWjd5eWsm1rO1c8sp9GZOMFxumo6TjhpuIKnQwUb92Ktrp5eWsmN4H6jg3KwIXbGGo3Kya(edDahWlidcYjYjGLyaSwgWOf4LCcyjgGpX4iOOqkIrBJkg3wcIHgwGCeJRfXgyRVqobSedWNyCKG3gT1eJR3mBSBzOO31HchgSbmpsm5qmocqYniMlRjgxVreaydkFpeZMpHufYjGLya(eJRnBCKdIH3IeJBiDutmUbe5WjeiXOPvoqIjdI5YAIHpsyg61PqorobSeJBa8ev8bsrmB8YAKyumUTeeZgbNJTqmocLc1gwIzydWVwAUlpKyevKSXsmSbQVqobSeJOIKn2I2gvmUTevxOyptobSeJOIKn2I2gvmUTeavr)LXOiNawIrurYgBrBJkg3wcGQOx4bZHtirYgYjGLy8JO1wZcIPLKIy283lsrm2qclXSXlRrIrX42sqmBeCowIrgkIrBJaFTSiYbmXKwIHInyHCcyjgrfjBSfTnQyCBjaQIE7iAT1SyzdjSKtIks2ylABuX42sauf9blqUfNydS1tojQizJTOTrfJBlbqv0dtW1XKd4LTorif5KOIKn2I2gvmUTeavrVwwKSHCICcyjg3a4jQ4dKIyWdS1tmrYHetuJeJOcwtmPLyKdjHYgIfYjrfjBSvomhQLTgLMCcyjghreiN2GycgXy1pkIPfvkqIrXyqkMdhlX4WmQjghHvHdLmkKyynX46ylqIXRn7mS0smSMy4TiXWgIrXyqkMdhIjVeJvoYbmXe1ihX4WecjMgT8WGyYHySj4jVPsMGyumgKI5WHyCOydKCsurYglqv0FiDkBis7iCyLIXGumholR(rr7Ha5XkndbItueRchkzuybhzdrkNAU5V3Iyv4qjJcl8AD3DfJbPyoCkIvHdLmkS0iNKJvxqge6OJ7URPJdbItueRchkzuybhzdrkNAEXwGlR2SZO0iNKJvxq2D3vmgKI5WPCXwGlR2SZO0iNKJvxqge6Od5eWsmU2mIzybXWBrIrigobH2OzCaFfZg5aMyKDcZqpXKxIjdIXHjesm7ohWeJEgpXemIbeedNGqB0moIrgkIrjJcHeZLV1tmSlXizxiNevKSXcuf9hsNYgI0ochwD5B9awJQZlVN2dbYJvCccTrZ40TsZqG4eLlFRFXUlj7coYgIuaKMahqIks2uSbR5SrNNXIIzdD0HCsurYglqv0FiDkBis7iCy1LV1dynQoVCXfApeipwXji0gnJt3kndbItuU8T(f7UKSl4iBisbqAcCajQiztbkhYck26IIzdD0HCsurYglqv0FiDkBis7iCy1LV1dynQoVa0fApeipwXji0gnJt3kndbItuU8T(f7UKSl4iBisbqAcCajQiztr1ITEbtW1XKd4IIzdD0HCsurYglqv0FiDkBis7iCy1LV1dynQoVCDqP9qG8yfNGqB0moDR0meior5Y36xS7sYUGJSHifaPjWbKOIKnLBZSXULHQOy2qhDiNevKSXcuf9hsNYgI0ochwD5B9awJQZl3Wt7Ha5XkobH2OzC6wPziqCIYLV1Vy3LKDbhzdrkastGdirfjBkO0rnolR28mwumBOJoKtIks2ybQI(dPtzdrAhHdRU8TEaRr15LlGs7Ha5XkobH2OzC6wPziqCIYLV1Vy3LKDbhzdrkastGdiage6Od5eWsmoIiqoTbXemIrlJbjgobH2OzCeJLrm6z8oYqiXSrIr2qKycgXOeBqmcXC5Hq9aFTmhInsrmWeCDm5aMy2myqmILySm2qmILyYWr2smYHKqzdrIXH14qm3eCDKdyIHniXesdgJc5KOIKnwGQO)q6u2qK2r4WkqcqxXyqApeipwPPOI8ax4GCjA1Lo3DxtfJbPyoCkWeCDm5aETzWO0iNKJv3khaqGvu6Od5KOIKnwGQO)q6u2qK2r4WkqcqxXyWL3t7Ha5XknpKoLnelGeGUIXGU7oNGqB0moDR0meiorHDGTQwAWybhzdrkastageajQiztXgSMZgDEglkMn0rhDiNevKSXcuf9hsNYgI0ochwbsa6kgdUCXfApeipwP5H0PSHybKa0vmg0D35eeAJMXPBLMHaXjkSdSv1sdgl4iBisbqAcWGairfjBkq5qwqXwxumBOJo6qojQizJfOk6pKoLnePDeoScKa0vmgCbOl0EiqESsZdPtzdXcibORymO7UZji0gnJt3kndbItuyhyRQLgmwWr2qKcG0eGbbqIks2uuTyRxWeCDm5aUOy2qhD0HCsurYglqv0FiDkBis7iCyfibORym4Y1bL2dbYJvAEiDkBiwajaDfJbD3DobH2OzC6wPziqCIc7aBvT0GXcoYgIuaKMamiasurYMYTz2y3YqvumBOJo6qobSeJJicKtBqmbJy0YyqIHtqOnAghXCznXayl2AIXLeCDm5aMyYlXWXdJulejMqAWyyjgPrIrBJwCIc5KOIKnwGQO)q6u2qK2r4WkaDXvmgC5Il0EiqESsurEGlCqUeTv05U7CccTrZ40TstrfjBkQwS1lycUoMCaxumBaKOIKnfOCilOyRlkMn0HCsurYglqv0FiDkBis7iCyfGU4kgdU8EApeipwjQipWfoixI2k6C3DobH2OzC6wPPOIKnfvl26fmbxhtoGlkMnasurYMInynNn68mwumBOd5KOIKnwGQO)q6u2qK2r4WQBJiaWEZ3ZchzdrkApeipwPziqCIsnlw1YqvWr2qKYziqCIsTKqBWAUcoYgIuofaGDgyrBNCcCPTtoSl4iBisPd5KOIKnwGQO)q6u2qK2r4WQMPoBHjfUWr2qKI2dbYJvA64dPtzdXYTreayV57zHJSHiLtndbItu2mEif230gfCKnePCgceNOaLHYctkSGJSHiLtbayNbwSrJd4OEXUlu6OUGJSHiLo6qojQizJfOk6vceUevKSzbtBq7iCyftloytojQizJfOk6vceUevKSzbtBq7iCyLyv0M3Qn)9weRchkzuyHxl5KOIKnwGQOxjq4surYMfmTbTJWHvA7K1zONCsurYglqv0ReiCjQizZcM2G2r4WkojNahzuiT5TsurEGlCqUeTUfyiNevKSXcuf9kbcxIks2SGPnODeoSsrzjNevKSXcuf9kbcxIks2SGPnODeoS62icaS389SuSgPnVvhsNYgILBJiaWEZ3ZchzdrkYjrfjBSavrVsGWLOIKnlyAdAhHdROWRWdJLI1iT5TYXhsNYgILBJiaWEZ3ZchzdrkYjrfjBSavrVsGWLOIKnlyAdAhHdR4KCcCKrH0M3krf5bUWb5s0QBfWqojQizJfOk6vceUevKSzbtBq7iCy1nHqSjNiNevKSXweRQs1ITEbtW1XKdyAZBLJ383Br1ITEbtW1XKd4cVwNIkYdCHdYLOvx6CEiDkBiwU8TEaRr15fGUqojQizJTiwfqv03m15DgytBERcbItuGYqzHjfwWr2qKYPJ383BbkdLfMuyHxRtvT0Gr762Iks2iqDPR4OKtIks2ylIvbuf9omhkB05zKCICcyjgafBqmGczmkiVnigoz4fiupXKxIjQrIXraaSZajgAAjdIXrmk0gTajghjOLnYOqIjTeJ2gT4efYjrfjBSffLTAdzmkiVnOnVvcaWodSiJcTrlWvJw2iJcl4iBisrojQizJTOOSavr)gBl2NZbmT5T6q6u2qSOymifZHZYQFuKtIks2ylkklqv0VHmg16Y36PnVvhsNYgIffJbPyoCww9JICsurYgBrrzbQI(B24gYyu0M3QdPtzdXIIXGumholR(rrojQizJTOOSavrVmk0gTaxkbcPnVvhsNYgIffJbPyoCww9JICcyjghreiN2GycgXy1pkIrpJVjgxBx5jgTSizdX4WmQjgHyumgKI5WHwIHFGO1smrnsmH0GXGyslXiBgFqmbJyOsSqojQizJTOOSavrVwwKSH28wT5V3Iyv4qjJcl8AD3DhhceNOiwfouYOWcoYgIuoVylWLvB2zuAKtYXQli7U7H0GXOejhUc2Ikr3wbCGGCsurYgBrrzbQIEW8stLYSy3LaaSzrn5KOIKn2IIYcuf9CihR1Vy3fKxLulQgfol5KOIKn2IIYcuf9xSf4YQn7miNevKSXwuuwGQOFdzmQf7UIACHdYPNCsurYgBrrzbQIEXQWHsgfsBERumgKI5WPyJopJLg5KCS6ccYjrfjBSffLfOk65T4kdKZsobSeJOIKn2IIYcuf9O0r9cHihoHajNiNevKSXwOWRWdJLI1yfkDuJZYQnpJ0M3QdPtzdXYLV1dynQoVCdp5KOIKn2cfEfEySuSgbQIEBWAoB05zKwLEfexH0GXWwrhT5TsurEGlCqUeT6sNtbayNbwGj46yYb8sXgk(mk4iBis50Xu4M)ElWeCDm5aEPydfFgfETopKoLnelx(wpG1O68Y7jNevKSXwOWRWdJLI1iqv0BdwZzJopJ0M3Qn)9wSbR52DoGXUWR1D31uurEGlCqUeT6sNZn)9walrn25aEzdwZzl8ADEiDkBiwU8TEaRr15L3Rd5KOIKn2cfEfEySuSgbQIEvl26fmbxhtoGPnVvIkYdCHdYLOv3kGX5H0PSHy5Y36bSgvNxa6c5KOIKn2cfEfEySuSgbQIEycUoMCaV2myqBERcbItuyhyRQLgmwWr2qKYPOI8ax4GCjAROZ5H0PSHy5Y36bSgvNxUaQtobH2OzC6wbWGGCsurYgBHcVcpmwkwJavrVnynNn68msBERoKoLnelGeGUIXGlV35H0PSHy5Y36bSgvNxEp5e5KOIKn2YnHqSRS8df25aM28wjQipWfoixIw3cmKtIks2yl3ecXgOk6VmfVfPwcaWodCTrHJ28w54n)9weRchkzuyHxRthV5V3chdg4SCikAztHxRthV5V3sQ0VqkWyHxRthV5V3IQf1zyoGxw(gmw4160Xu4M)ElO0rnolR28mw41sojQizJTCtieBGQOxlFNx95aETHIniNevKSXwUjeInqv0RyJcNOLaPwxOWHKtIks2yl3ecXgOk6DiRHuhyoRgTSrgfsBER283BbMxCdzmQIne1z3cWKtIks2yl3ecXgOk6vTyRxWeCDm5aM28wfceNOCzTcV8WLdZHYwWr2qKYPOI8ax4GCjA1LoNhsNYgILlFRhWAuDEbOlKtIks2yl3ecXgOk6VqHdd2aMhPnVvHaXjkwu6CaVeRv4HrbhzdrkYjrfjBSLBcHyduf9q5qwqXwtBERCSaaSZalA7KtGlTDYHDbhzdrkNHaXjk1SyvldvbhzdrkNB(7TuZIvTmuLgfvqojQizJTCtieBGQOx1ITEbtW1XKdyAZBLOI8ax4GCjA1LoNhsNYgILlFRhWAuDEbOlKtIks2yl3ecXgOk6BM68odSPnVvCccTrZ4CRJccNoEZFVfB04aoQxS7cLoQl8AjNevKSXwUjeInqv0RAXwVGj46yYbmT5Tkeiorr1ITohWlBWAUcoYgIuopKoLnelGeGUIXGlaDHCsurYgB5Mqi2avrpuoKfuS10M3QdPtzdXcibORym4YfxCEiDkBiwU8TEaRr15LlUqojQizJTCtieBGQOVzQZ7mWMCsurYgB5Mqi2avr)Tz2y3YqrBERcbItuQLeAdwZvWr2qKY5M)El3MzJDldvProjhRBb4IRbiWkkNhsNYgILlFRhWAuDE56GsojQizJTCtieBGQO)cfomydyEKCICsurYgB52icaS389SuSgRGYHSGITMwLEfexH0GXWwrhT5Tsaa2zGfTDYjWL2o5WU0YCw3kh4Kc383BrBNCcCPTtoSl2quNROdeopKoLnelx(wpG1O68YfxCEiDkBiwa0fxXyWLlUqojQizJTCBeba2B(EwkwJavrpkDuJZYQnpJ0M3QdPtzdXYLV1dynQoVCdp5KOIKn2YTreayV57zPyncuf92G1C2OZZiTk9kiUcPbJHTIoAZBLOI8ax4GCjA1LoNcaWodSatW1XKd4LInu8zuWr2qKYPJPWn)9wGj46yYb8sXgk(mk8ADEiDkBiwU8TEaRr15L3tojQizJTCBeba2B(EwkwJavrVnynNn68msBER283BXgSMB35ag7cVw3Dxtrf5bUWb5s0QlDo383BbSe1yNd4LnynNTWR15H0PSHy5Y36bSgvNxEVoKtIks2yl3graG9MVNLI1iqv0RAXwVGj46yYbmT5TsurEGlCqUeT6wbmopKoLnelx(wpG1O68cqxiNevKSXwUnIaa7nFplfRrGQOhMGRJjhWRndg0M3QqG4ef2b2QAPbJfCKnePCkQipWfoixI2k6CEiDkBiwU8TEaRr15LlG6KtqOnAgNUvamiiNevKSXwUnIaa7nFplfRrGQOhkhYck2AAZBLaaSZalA7KtGlTDYHDPL5SUvoWjfU5V3I2o5e4sBNCyxSHOoRRJ68q6u2qSC5B9awJQZlxCX5H0PSHybqxCfJbxU4c5KOIKn2YTreayV57zPyncuf92G1C2OZZiT5T6q6u2qSasa6kgdU8ENhsNYgILlFRhWAuDE59opKoLnela6IRym4Y7jNevKSXwUnIaa7nFplfRrGQOhkhYck2AAZBffU5V3I2o5e4sBNCyxSHOoxrhiCEiDkBiwU8TEaRr15LlUqorojQizJTWj5e4iJcRUqHdd2aMhPnVvoEZFVLlu4WGnG5XcVwYjrfjBSfojNahzuiqv0FBMn2Tmu0M3QqG4eLAjH2G1CfCKnePC64n)9wUnZg7wgQcVwNhsNYgILlFRhWAuDE56GsorojQizJTW0Id2vntDENb20M3kobH2OzCULoq2zKCOBbROiNiNevKSXw02jRZqFLQfB9cMGRJjhW0M3krf5bUWb5s0QBLMUgGVMHaXjkxwRWlpC5WCOSfCKnePaiGrhDCEiDkBiwUnIaa7nFplCKnePCEiDkBiwU8TEaRr15fGUqojQizJTOTtwNHEGQOpQXf)Sz8d16YAfsBER283BPr1ziATRlRvyHxR7Uhjh6wqMCsurYgBrBNSod9avrpuoKfuS10M3kbayNbw02jNaxA7Kd7slZzDRCGtkCZFVfTDYjWL2o5WUydrDUIoq4uurEGlCqUeTv058q6u2qSCBeba2B(Ew4iBis58q6u2qSC5B9awJQZlxCHCsurYgBrBNSod9avr)fkCyWgW8iT5T6q6u2qSCBeba2B(Ew4iBis5CZFVLlu4WGnG5XsJCsow3cwr5uurEGlCqUeT6sh5KOIKn2I2ozDg6bQI(BZSXULHI28wDiDkBiwUnIaa7nFplCKnePCU5V3YTz2y3YqvAKtYX6wWkkNIkYdCHdYLOvx6iNevKSXw02jRZqpqv0RAXwVGj46yYbmT5TYXB(7TOAXwVGj46yYbCHxRtrf5bUWb5s0QlDopKoLnelx(wpG1O68cqxiNevKSXw02jRZqpqv0F5B9l2DjztBERC8M)Elx(w)IDxs2fETo5eeAJMXPBLdaHtRwecxH0GXWwU8T(f7UKSxucNag1Tst6a6q6u2qSCBeba2B(Ew4iBisPd5KOIKn2I2ozDg6bQI(lFRFXUljBAZB1M)Elx(w)IDxs2fEToDA1Iq4kKgmg2YLV1Vy3LK9Is4eWOB1KoGoKoLnel3graG9MVNfoYgIu6qojQizJTOTtwNHEGQOpybYT4eBGTEAZB1M)ElnAzJmkCfSa5knYj5yDBLdaiWkkYjrfjBSfTDY6m0duf9w(Hc7CatBERevKh4chKlrRUvaJtnDmAT4OWYgYyul2Df14chKtFHtaEWA3Dxt0AXrHLnKXOwS7kQXfoiN(cNa8G1o1CZFVflIrDoGxTagl8AD3DfJbPyoCkBiJrTy3vuJlCqo9Lg5KCS6cWGqhD0HCsurYgBrBNSod9avr)LP4Ti1saa2zGRnkC0M3krf5bUWb5s0QBfWqojQizJTOTtwNHEGQOxlFNx95aETHInOnVvIkYdCHdYLOv3kGHCsurYgBrBNSod9avrFZuN3zGnT5TkeiorbkdLfMuybhzdrkNoEZFVfOmuwysHfETov1sdgTRBlQizJa1LUIJsobSeJJuzutmAibFlqIXrAP5yJEAjgeIhsGetuJeJ2ozDg6jg2LyqiYHtiqIrIquNTetoedRPWMycgXWj5esoetuJeZM)ETeJdRXHyIAuVJCJeJSz8bXemIbbEQnBSqojQizJTOTtwNHEGQO)2mBSBzOOnVvAkaa7mWYibFlWvT0CSrFbhzdrkNB(7TmsW3cCvlnhB0VUnZgLg5KCSUTYbaeyfLoodbItuQLeAdwZvWr2qKY5H0PSHy5Y36bSgvNxUoOKtIks2ylA7K1zOhOk6VqHdd2aMhPnVvAkaa7mWYibFlWvT0CSrFbhzdrkNB(7TmsW3cCvlnhB0VUzJLg5KCSUTYbaeyfLoKtIks2ylA7K1zOhOk6BM68odSPnVvAkaa7mWYibFlWvT0CSrFbhzdrkNB(7TmsW3cCvlnhB0Vgj4BS0iNKJ1TvoaGaRO0XjNGqB0mo36OG4Jp(h]] )


end
