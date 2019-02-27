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


    spec:RegisterPack( "Enhancement", 20190222.2344, [[dWeIpbqivk8iIs1MOs(eviAuevDkIkRIkv9kvQMfsYTOsf7IQ(fqAyeLCmIILrLYZujX0ujPRrfkBdOQ(gvOACeLIZbuLwhqvmpvk19uI9rrCqvkQfcuEOkXevPi0fPsL2ivi9rIsPAKQuK0jvPiALkjZKI0nvPiyNiP(PkLmuQalLkeEQetfiUkrPu8vvksnwIsP0Eb9xvmysDyulwPEmjtgPUm0Mb8zKy0sYPf9ALuZwv3Mi7wXVjmCkQJRsrILl1ZP00fUof2UK67ubnEIsjNNkA9QKA(av2pIHYabbwO5aHu7MSKb8kl3CZnVBx5QUDLRclHtZiSyMvRzkiSmSeclU7uXJcLWjGfZSZxW0qqGfRWOviSufHzl4buqPKrLX2ResGAtjJNJumQMbcqTPKc09l2GUby3HgRb1ClaYhTGcsITBUbkiU52PuXs8CC3PIhfkHt4TPKcw2g5h3KdCdl0CGqQDtwYaELLBU5M3TRCv3UcSWgrLOHLskz8CKI5sZabSuL004a3WcnAvWISt0U7uXJcLWji6sflXdzLSt0vry2cEafukzuzS9kHeO2uY45ifJQzGauBkPaD)InOBa2DOXAqn3cG8rlOoOrhbN0wqDGJ4uQyjEoU7uXJcLWj82usrwj7eTJI72GBNeTBUrfr7MSKb8s0Udr72vapx1nYkYkzNOVuXdf0cEiRKDI2Di6BMMgPjAZnQesBoiAqebkr03eyBGTtpzLSt0Udr7iqGgTveTJ2cBSBEOb1rFwcdXqXaj6Ci6B(wUlrdiAI2rBeVgBWm6HO3g5t7HLpTHfccSimJd2qqGuldeeybhE)inemyr1zGDYWIeJVnAHerFBIwghJODr0rkHe9TjAkkAyHvrkgyPfQ17mWggWawK4CcC4rHqqGuldeeybhE)inemyr1zGDYWYni6TbaGh4zjmedfd0BygwyvKIbwaEwcdXqXaHbKA3GGal4W7hPHGblQodStgwc(Xj8vC(2q0sEC49J0eTlI(ge92aaWd0cBSBEO9gMjAxeDn3jVF0dy0oVuHQ1hhfmyHvrkgybOf2y38qddyalanIxJ92ONJs0ieei1YabbwWH3psdbdwyvKIbwEUMppBRGfvNb2jdl81yNb6n3Pe)hZDkHTV5znrBYcr7gr7IOPXTbaG3CNs8Fm3Pe2EBWQ1e9crlJSiAxeDn3jVF0dy0oVuHQ1htnLODr01CN8(r)ftDGq8htnfwcUPGXjbGfyaP2niiWco8(rAiyWIQZa7KHLAUtE)OhWODEPcvRpUBbwyvKIbwqUJkCowZ5AegqQVceeybhE)inemyHvrkgyXgIwYgDUgHfvNb2jdlSkYA8GdkLOLOnHOLHODr081yNb6)Ksvm5q5OedTrgEC49J0eTlI(gennUnaa8FsPkMCOCuIH2idVHzI2frxZDY7h9agTZlvOA9PuGfLt1JNGBkyyHuldmGuFviiWco8(rAiyWIQZa7KHLTbaG3gIwA35qbBVHzIgCGJOLNOzvK14bhukrlrBcrldr7IO3gaaEkCuHDouo2q0swVHzI2frxZDY7h9agTZlvOA9PuiA5GfwfPyGfBiAjB05AegqQDmiiWco8(rAiyWIQZa7KHfwfznEWbLs0s0MSq0xHODr01CN8(rpGr78sfQwFUykSWQifdSOA2wD(Ksvm5qbgqQbFiiWco8(rAiyWIQZa7KHLGFCcVOgBvf3uqpo8(rAI2frZQiRXdoOuIwIEHOLHODr01CN8(rpGr78sfQwFmfmI2frlX4BJwir0MSq0xvwWcRIumWYNuQIjhkNT4dyaP2XHGal4W7hPHGblQodStgw4RXod0BUtj(pM7ucBFZZAI2KfI2nI2frtJBdaaV5oL4)yUtjS92GvRjAtiAhNODr01CN8(rpGr78sfQwFm1uI2frxZDY7h9xm1bcXFm1uyHvrkgy55A(8STcgqQLnqqGfC49J0qWGfvNb2jdl1CN8(r)TU4aH4pLcr7IOR5o59JEaJ25LkuT(ukeTlIUM7K3p6VyQdeI)ukWcRIumWIneTKn6Cncdi1GxiiWco8(rAiyWIQZa7KHfACBaa4n3Pe)hZDkHT3gSAnrVq0YilI2frxZDY7h9agTZlvOA9XutHfwfPyGLNR5ZZ2kyadyXCJkH0MdiiqQLbccSGdVFKgcgmGu7geeybhE)inemyaP(kqqGfC49J0qWGbK6RcbbwWH3psdbdgqQDmiiWcRIumWsicu6iX2aBNWco8(rAiyWasn4dbbwyvKIbw(Ksvm5q5yRs8PHfC49J0qWGbKAhhccSWQifdSywePyGfC49J0qWGbmGfAeGn(accKAzGGalSksXalomh6JTc5gwWH3psdbdgqQDdccSGdVFKgcgSuZVbclYt0b)4eE2QWHMhf6XH3pst0UiA5j6TbaGNTkCO5rHEdZen4ahrReINw4WXZwfo08OqFJsCowI2eI2XKfrlhrlhrdoWr0Yt03GOd(Xj8SvHdnpk0JdVFKMODr0Yt0ayZ)XAo7m8nkX5yjAtiAhJObh4iALq80choEaS5)ynNDg(gL4CSeTjeTJjlIwoIwoyHvrkgyPM7K3pcl1CFgwcHfLq80chohRZrbdi1xbccSGdVFKgcgSuZVbclsm(2OfseTjleT8eDWpoHhWODEeahoBpo8(rAI29eT8en4t03jAwfPy82q0s2OZ1OxjSbrlhrlhSWQifdSuZDY7hHLAUpdlHWcGr78sfQwFkfyaP(QqqGfC49J0qWGLA(nqyrIX3gTqIOnzHOLNOd(Xj8agTZJa4Wz7XH3pst0UNOLNObFI(orZQifJ)5A(8STYRe2GOLJOLdwyvKIbwQ5o59JWsn3NHLqybWODEPcvRpMAkmGu7yqqGfC49J0qWGLA(nqyrIX3gTqIOnzHOLNOd(Xj8agTZJa4Wz7XH3pst0UNOLNObFI(orZQifJx1ST68jLQyYHIxjSbrlhrlhSWQifdSuZDY7hHLAUpdlHWcGr78sfQwFUykmGud(qqGfC49J0qWGLA(nqyrIX3gTqIOnzHOLNOd(Xj8agTZJa4Wz7XH3pst0UNOLNObFI(orZQifJhOf2y38q7vcBq0Yr0YblSksXal1CN8(ryPM7ZWsiSay0oVuHQ1hhfmyaP2XHGal4W7hPHGbl18BGWIeJVnAHerBYcrlprh8Jt4bmANhbWHZ2JdVFKMODprlprd(e9DIMvrkgpYDuHZXAoxJELWgeTCeTCWcRIumWsn3jVFewQ5(mSeclagTZlvOA9XDlWasTSbccSGdVFKgcgSuZVbclsm(2OfseTjleT8eDWpoHhWODEeahoBpo8(rAI29eT8en4t03j6RklIwoIwoyHvrkgyPM7K3pcl1CFgwcHfaJ25LkuT(ykyWasn4fccSGdVFKgcgSuZVbclYt0SkYA8GdkLOLOnHOLHObh4iA5jALq80cho(pPuftouoBXh(gL4CSeTjleTBeT7jAkkAIwoIwoyHvrkgyPM7K3pcl1CFgwcHLBDXbcXddi1YiliiWco8(rAiyWsn)giSiprxZDY7h936IdeINObh4iAjgFB0cjI2KfIwEIo4hNWlQXwvXnf0JdVFKMODprlprFvzr03jAwfPy82q0s2OZ1OxjSbrlhrlhrlhSWQifdSuZDY7hHLAUpdlHWYTU4aH4pLcmGulJmqqGfC49J0qWGLA(nqyrEIUM7K3p6V1fhieprdoWr0sm(2OfseTjleT8eDWpoHxuJTQIBkOhhE)inr7EIwEI(QYIOVt0SksX4FUMppBR8kHniA5iA5iA5GfwfPyGLAUtE)iSuZ9zyjewU1fhie)XutHbKAzCdccSGdVFKgcgSuZVbclYt01CN8(r)TU4aH4jAWboIwIX3gTqIOnzHOLNOd(Xj8IASvvCtb94W7hPjA3t0Yt0xvwe9DIMvrkgVQzB15tkvXKdfVsydIwoIwoIwoyHvrkgyPM7K3pcl1CFgwcHLBDXbcXFUykmGulZvGGal4W7hPHGbl18BGWI8eDn3jVF0FRloqiEIgCGJOLy8TrlKiAtwiA5j6GFCcVOgBvf3uqpo8(rAI29eT8e9vLfrFNOzvKIXd0cBSBEO9kHniA5iA5iA5GfwfPyGLAUtE)iSuZ9zyjewU1fhie)XrbdgqQL5QqqGfC49J0qWGLA(nqyHvrwJhCqPeTe9crldrdoWr0sm(2OfseTjleT8enRIumEvZ2QZNuQIjhkELWge9DIMvrkg)Z185zBLxjSbrlhSWQifdSuZDY7hHLAUpdlHWYftDGq8htnfgqQLXXGGal4W7hPHGbl18BGWcRISgp4GsjAj6fIwgIgCGJOLy8TrlKiAtwiA5jAwfPy8QMTvNpPuftou8kHni67enRIumEBiAjB05A0Re2GOLdwyvKIbwQ5o59JWsn3NHLqy5IPoqi(tPadi1Ya(qqGfC49J0qWGLA(nqyrEIo4hNWxjItfp0EC49J0eTlIo4hNWxX5Bdrl5XH3pst0UiA(ASZa9M7uI)J5oLW2JdVFKMOLdwyvKIbwQ5o59JWsn3NHLqybOr8AS3g9CWH3psddi1Y44qqGfC49J0qWGLA(nqyrEI(geDn3jVF0d0iEn2BJEo4W7hPjAxeT8eDWpoHFlmEASbsB4XH3pst0Ui6GFCc)ZdT9tA0JdVFKMODr081yNb6TrJdLO6iaoi3rLhhE)inrlhrlhSWQifdSuZDY7hHLAUpdlHWsluRTFsJhC49J0WasTmYgiiWcRIumWcBeIdhbRwdl4W7hPHGbdi1YaEHGalSksXalgw8KbkzHfC49J0qWGbKA3KfeeybhE)inemyHvrkgyrX)FyvKI58PnGLpTXzyjeweMXbByaP2nzGGal4W7hPHGblQodStgw2gaaE2QWHMhf6nmdlSksXalk()dRIumNpTbS8PnodlHWcBvWasTBUbbbwWH3psdbdwyvKIbwu8)hwfPyoFAdy5tBCgwcHfZDk6mCcdi1UDfiiWco8(rAiyWIQZa7KHfwfznEWbLs0s03MOVcSWQifdSO4)pSksXC(0gWYN24mSeclsCobo8OqyaP2TRcbbwWH3psdbdwyvKIbwu8)hwfPyoFAdy5tBCgwcHffTfgqQDZXGGal4W7hPHGblQodStgwQ5o59JEGgXRXEB0ZbhE)inSWQifdSO4)pSksXC(0gWYN24mSeclanIxJ92ONJs0imGu7g4dbbwWH3psdbdwuDgyNmSCdIUM7K3p6bAeVg7TrphC49J0WcRIumWII))WQifZ5tBalFAJZWsiSqJaSXhhLOryaP2nhhccSGdVFKgcgSO6mWozyHvrwJhCqPeTeTjle9vGfwfPyGff))HvrkMZN2aw(0gNHLqyrIZjWHhfcdi1UjBGGal4W7hPHGblSksXalk()dRIumNpTbS8PnodlHWcq(p2WagWcncWgFCuIgHGaPwgiiWco8(rAiyWIQZa7KHLAUtE)OhWODEPcvRpUBbwyvKIbwqUJkCowZ5AegqQDdccSGdVFKgcgSWQifdSydrlzJoxJWIQZa7KHfwfznEWbLs0s0Mq0Yq0UiA(ASZa9FsPkMCOCuIH2idpo8(rAI2frFdIMg3gaa(pPuftouokXqBKH3Wmr7IOR5o59JEaJ25LkuT(ukWIYP6XtWnfmSqQLbgqQVceeybhE)inemyr1zGDYWY2aaWBdrlT7COGT3WmrdoWr0Yt0SkYA8GdkLOLOnHOLHODr0BdaapfoQWohkhBiAjR3Wmr7IOR5o59JEaJ25LkuT(ukeTCWcRIumWIneTKn6Cncdi1xfccSGdVFKgcgSO6mWozyHvrwJhCqPeTeTjle9viAxeDn3jVF0dy0oVuHQ1NlMclSksXalQMTvNpPuftouGbKAhdccSGdVFKgcgSO6mWozyj4hNWlQXwvXnf0JdVFKMODr0SkYA8GdkLOLOxiAziAxeDn3jVF0dy0oVuHQ1htbJODr0sm(2OfseTjle9vLfSWQifdS8jLQyYHYzl(agqQbFiiWco8(rAiyWIQZa7KHLAUtE)O)wxCGq8NsHODr01CN8(rpGr78sfQwFkfyHvrkgyXgIwYgDUgHbmGfG8FSHGaPwgiiWcRIumWI1yOXohkWco8(rAiyWasTBqqGfC49J0qWGfvNb2jdlb)4eEarRqaJ)4WCOTEC49J0eTlIMvrwJhCqPeTeTjeTmeTlIUM7K3p6bmANxQq16ZftHfwfPyGfvZ2QZNuQIjhkWas9vGGal4W7hPHGblQodStgwc(Xj8wK7COCyRLn(WJdVFKgwyvKIbwaEwcdXqXaHbK6RcbbwWH3psdbdwuDgyNmSCdIMVg7mqV5oL4)yUtjS94W7hPjAxeDWpoHVseNkEO94W7hPjAxe92aaWxjItfp0(gzvalSksXalpxZNNTvWasTJbbbwWH3psdbdwuDgyNmSWQiRXdoOuIwI2eIwgI2frxZDY7h9agTZlvOA95IPWcRIumWIQzB15tkvXKdfyaPg8HGal4W7hPHGblQodStgwKy8TrlKi6Bt0oUSiAxe9ni6TbaG3gnouIQJa4GChvEdZWcRIumWsluR3zGnmGu74qqGfC49J0qWGfvNb2jdlb)4eEvZ2QCOCSHOL84W7hPjAxeDn3jVF0FRloqi(ZftHfwfPyGfvZ2QZNuQIjhkWasTSbccSGdVFKgcgSO6mWozyPM7K3p6V1fhie)XutjAxeDn3jVF0dy0oVuHQ1htnfwyvKIbwEUMppBRGbKAWleeyHvrkgyPfQ17mWgwWH3psdbdgqQLrwqqGfC49J0qWGfvNb2jdlb)4e(koFBiAjpo8(rAI2frVnaa8aTWg7MhAFJsCowI(2e9v9YgI(ortrrt0Ui6AUtE)OhWODEPcvRpokyWcRIumWcqlSXU5HggqQLrgiiWcRIumWcWZsyigkgiSGdVFKgcgmGbSOOTqqGuldeeybhE)inCdlQodStgw4RXod0ZJcTrZ)PrRy4rHEC49J0WcRIumWY(fc63WgWasTBqqGfC49J0qWGfvNb2jdl1CN8(rVsiEAHdNJ15OGfwfPyGLn2wSxNdfyaP(kqqGfC49J0qWGfvNb2jdl1CN8(rVsiEAHdNJ15OGfwfPyGL9le0haJ2jmGuFviiWco8(rAiyWIQZa7KHLAUtE)OxjepTWHZX6CuWcRIumWcq24(fcAyaP2XGGal4W7hPHGblQodStgwQ5o59JELq80chohRZrblSksXal8OqB08Fu8)Wasn4dbbwWH3psdbdwuDgyNmSSnaa8SvHdnpk0ByMObh4i6Bq0b)4eE2QWHMhf6XH3pst0UiAaS5)ynNDg(gL4CSeTjeTJr0GdCeDWnfm8rkHNqCOtKOV9crd(YcwyvKIbwmlIumWasTJdbbwyvKIbwaWM)J1C2zal4W7hPHGbdi1YgiiWco8(rAiyWIQZa7KHfLq80choEB05A03OeNJLOnHOLfSWQifdSWwfo08OqyaPg8cbbwyvKIbwqUJQd(Oeob)Wco8(rAiyWagWI5ofDgoHGaPwgiiWco8(rAiyWIQZa7KHfwfznEWbLs0s0MSq0Yt0YgI2DiA5j6GFCcpGOviGXFCyo0wpo8(rAI29e9viA5iA5iAxeDn3jVF0d0iEn2BJEo4W7hPjAxeDn3jVF0dy0oVuHQ1NlMclSksXalQMTvNpPuftouGbKA3GGal4W7hPHGblQodStgw4RXod0BUtj(pM7ucBFZZAI2KfI2nI2frtJBdaaV5oL4)yUtjS92GvRj6fIwgzr0UiAwfznEWbLs0s0leTmeTlIUM7K3p6bAeVg7TrphC49J0eTlIUM7K3p6bmANxQq16JPMclSksXalpxZNNTvWas9vGGal4W7hPHGblQodStgwQ5o59JEGgXRXEB0ZbhE)inr7IO3gaaEGNLWqmumqFJsCowI(2enffnr7IOzvK14bhukrlrBcrldSWQifdSa8SegIHIbcdi1xfccSGdVFKgcgSO6mWozyPM7K3p6bAeVg7TrphC49J0eTlIEBaa4bAHn2np0(gL4CSe9TjAkkAI2frZQiRXdoOuIwI2eIwgyHvrkgybOf2y38qddi1ogeeybhE)inemyr1zGDYWYni6TbaGx1ST68jLQyYHI3Wmr7IOzvK14bhukrlrBcrldr7IOR5o59JEaJ25LkuT(CXuyHvrkgyr1ST68jLQyYHcmGud(qqGfC49J0qWGfvNb2jdl3GO3gaaEaJ25raC4S9gMjAxeTeJVnAHerBYcr7MSiAxeT1m()j4McgwpGr78iaoC2hAwIPGeTjleT8eTme9DIUM7K3p6bAeVg7TrphC49J0eTCWcRIumWcGr78iaoC2WasTJdbbwWH3psdbdwuDgyNmSSnaa8agTZJa4Wz7nmt0UiARz8)tWnfmSEaJ25raC4Sp0Setbj6Bt0Yt0Yq03j6AUtE)OhOr8AS3g9CWH3pst0YblSksXalagTZJa4Wzddi1YgiiWco8(rAiyWIQZa7KHLTbaGVrRy4rHNqeOKVrjohlrF7fI2nI29enffnSWQifdSeIaLosSnW2jmGudEHGal4W7hPHGblQodStgwyvK14bhukrlrBYcrFfyHvrkgyXAm0yNdfyaPwgzbbbwWH3psdbdwuDgyNmSe8Jt4FEOTFsJEC49J0eTlI(ge92aaW)8qB)Kg9gMjAxeTQIBkO9a0SksXWprBcrlJ3XHfwfPyGLwOwVZaByaPwgzGGal4W7hPHGblQodStgwKNO5RXod0pCy08FQ4wsmo94W7hPjAxe92aaWpCy08FQ4wsmopaTWg(gL4CSe9TxiA3iA3t0uu0eTCeTlIo4hNWxX5Bdrl5XH3pst0Ui6AUtE)OhWODEPcvRpokyWcRIumWcqlSXU5HggqQLXniiWco8(rAiyWIQZa7KHf5jA(ASZa9dhgn)NkULeJtpo8(rAI2frVnaa8dhgn)NkULeJZdq2OVrjohlrF7fI2nI29enffnrlhSWQifdSa8SegIHIbcdi1YCfiiWco8(rAiyWIQZa7KHf5jA(ASZa9dhgn)NkULeJtpo8(rAI2frVnaa8dhgn)NkULeJZZWHrJ(gL4CSe9TxiA3iA3t0uu0eTCeTlIwIX3gTqIOVnr74YcwyvKIbwAHA9odSHbmGf2QGGaPwgiiWco8(rAiyWIQZa7KHLBq0BdaaVQzB15tkvXKdfVHzI2frZQiRXdoOuIwI2eIwgI2frxZDY7h9agTZlvOA95IPWcRIumWIQzB15tkvXKdfyaP2niiWco8(rAiyWIQZa7KHLGFCc)ZdT9tA0JdVFKMODr03GO3gaa(NhA7N0O3Wmr7IOvvCtbThGMvrkg(jAtiAz8ooSWQifdS0c16Dgyddi1xbccSWQifdS4WCOTrNRrybhE)inemyadyal1yBtXaP2nzjd4vwY42v8YaEVcS4qUNCOyHLB6B2rq9nj1Y2bpenrdsfs0PKzrhenGOjAhjncWgF4ij6gVPyKnst0wHes0SriK4aPjAvfpuqRNSY0CqIwgzd4HOLTzSgMnl6aPjAwfPyiAhjBeIdhbRw7i9KvKv303SJG6BsQLTdEiAIgKkKOtjZIoiAart0osGgXRXEB0ZrjA0rs0nEtXiBKMOTcjKOzJqiXbst0QkEOGwpzLP5GeTmGhI2rGsIAKMOLyzlWJSTeTQcvRjA5hrq0CnNpVFKOZHOrjJNJumYr0UJ7q0YlJSLCEYkYQBsjZIoqAIwgzr0SksXq0FAdRNScwm3cG8ryr2jA3DQ4rHs4eeDPIL4HSs2j6QimBbpGckLmQm2ELqcuBkz8CKIr1mqaQnLuGUFXg0na7o0ynOMBbq(Ofuh0OJGtAlOoWrCkvSeph3DQ4rHs4eEBkPiRKDI2rXDBWTtI2n3OIODtwYaEjA3HOD7kGNR6gzfzLSt0xQ4HcAbpKvYor7oe9nttJ0eT5gvcPnheniIaLi6BcSnW2PNSs2jA3HODeiqJ2kI2rBHn2np0G6OplHHyOyGeDoe9nFl3LObenr7OnIxJnyg9q0BJ8P9KvKvYor7UYwOYiqAIEJaIgjALqAZbrVrk5y9e9nRuO5Ws0JyCNkULamEIMvrkglrlM3PNSIvrkgR3CJkH0MJfGNTRjRyvKIX6n3OsiT54(cOacbnzfRIumwV5gvcPnh3xaLnOiHtWrkgYkzNOldB2wjcIU5KMO3gaainrBdoSe9gbens0kH0MdIEJuYXs08qt0MB0DmlIihkeDAjAAXGEYkwfPySEZnQesBoUVaQDyZ2krCSbhwYkwfPySEZnQesBoUVaAicu6iX2aBNKvSksXy9MBujK2CCFb0pPuftouo2QeFAYkwfPySEZnQesBoUVaQzrKIHSISs2jA3v2cvgbst0yn2oj6iLqIoQqIMvHOj60s0CnNpVF0twXQifJDXH5qFSvi3KvYorFZrGsMdIoeeT15Oi6Mvj)eTsiEAHdhlr7WmQi6B2QWHMhfs0IMODuS5NOlMZodlveTOjAdls0IHOvcXtlC4q0jarB56COq0rfkr0om)NOB0A8brNdrBtktcKkEcIwjepTWHdr7q2gizfRIum27lGwZDY7hPAyjCrjepTWHZX6CuuvZVbUiFWpoHNTkCO5rHEC49J0UKFBaa4zRchAEuO3Wm4aNsiEAHdhpBv4qZJc9nkX5ynXXKLCYboWj)nc(Xj8SvHdnpk0JdVFK2L8ayZ)XAo7m8nkX5ynXXah4ucXtlC44bWM)J1C2z4BuIZXAIJjl5KJSs2j6BIcIEebrByrIMjAjgFB0cj3rjSrouiAENFgoj6eGOZGODy(prV7COq0ofgeDiiAzr0sm(2Ofsenp0eTIhf(enGr7KOfaenNTNSIvrkg79fqR5o59JunSeUay0oVuHQ1NsHQA(nWfjgFB0cjtwKp4hNWdy0opcGdNThhE)iT7Lh8VZQifJ3gIwYgDUg9kHnKtoYkwfPyS3xaTM7K3ps1Ws4cGr78sfQwFm1uQQ53axKy8TrlKmzr(GFCcpGr78iaoC2EC49J0UxEW)oRIum(NR5ZZ2kVsyd5KJSIvrkg79fqR5o59JunSeUay0oVuHQ1NlMsvn)g4IeJVnAHKjlYh8Jt4bmANhbWHZ2JdVFK29Yd(3zvKIXRA2wD(Ksvm5qXRe2qo5iRyvKIXEFb0AUtE)ivdlHlagTZlvOA9XrbJQA(nWfjgFB0cjtwKp4hNWdy0opcGdNThhE)iT7Lh8VZQifJhOf2y38q7vcBiNCKvSksXyVVaAn3jVFKQHLWfaJ25LkuT(4UfQQ53axKy8TrlKmzr(GFCcpGr78iaoC2EC49J0UxEW)oRIumEK7OcNJ1CUg9kHnKtoYkwfPyS3xaTM7K3ps1Ws4cGr78sfQwFmfmQQ53axKy8TrlKmzr(GFCcpGr78iaoC2EC49J0UxEW)(vLLCYrwj7e9nhbkzoi6qq0MfINOLy8TrlKiARGODkmCK)t0BKO59JeDiiAfBdIMjAaJ)D6oMfoeBKMO)Ksvm5qHO3IpiA2s0wHyiA2s0z4iTenxZ5Z7hjAhwHdrdKuQICOq0Ibj6GBky4jRyvKIXEFb0AUtE)ivdlHl36IdeINQA(nWf5zvK14bhukrRjYaoWjVsiEAHdh)NuQIjhkNT4dFJsCowtwCZ9uu0YjhzfRIum27lGwZDY7hPAyjC5wxCGq8NsHQA(nWf5R5o59J(BDXbcXdoWjX4BJwizYI8b)4eErn2QkUPGEC49J0Ux(RkR7SksX4THOLSrNRrVsyd5KtoYkwfPyS3xaTM7K3ps1Ws4YTU4aH4pMAkv18BGlYxZDY7h936IdeIhCGtIX3gTqYKf5d(Xj8IASvvCtb94W7hPDV8xvw3zvKIX)CnFE2w5vcBiNCYrwXQifJ9(cO1CN8(rQgwcxU1fhie)5IPuvZVbUiFn3jVF0FRloqiEWbojgFB0cjtwKp4hNWlQXwvXnf0JdVFK29YFvzDNvrkgVQzB15tkvXKdfVsyd5KtoYkwfPyS3xaTM7K3ps1Ws4YTU4aH4pokyuvZVbUiFn3jVF0FRloqiEWbojgFB0cjtwKp4hNWlQXwvXnf0JdVFK29YFvzDNvrkgpqlSXU5H2Re2qo5KJSs2j6BocuYCq0HGOnleprlX4BJwir0aIMOV0STIOnnPuftoui6eGOLm(in)irhCtbdlrZns0MB0It4jRyvKIXEFb0AUtE)ivdlHlxm1bcXFm1uQQ53axyvK14bhukr7ImGdCsm(2OfsMSipRIumEvZ2QZNuQIjhkELWg3zvKIX)CnFE2w5vcBihzfRIum27lGwZDY7hPAyjC5IPoqi(tPqvn)g4cRISgp4GsjAxKbCGtIX3gTqYKf5zvKIXRA2wD(Ksvm5qXRe24oRIumEBiAjB05A0Re2qoYkwfPyS3xaTM7K3ps1Ws4cqJ41yVn65GdVFKMQA(nWf5d(Xj8vI4uXdThhE)iTRGFCcFfNVneTKhhE)iTl(ASZa9M7uI)J5oLW2JdVFKwoYkwfPyS3xaTM7K3ps1Ws4sluRTFsJhC49J0uvZVbUi)nQ5o59JEGgXRXEB0ZbhE)iTl5d(Xj8BHXtJnqAdpo8(rAxb)4e(NhA7N0OhhE)iTl(ASZa92OXHsuDeahK7OYJdVFKwo5iRyvKIXEFbu2iehocwTMSIvrkg79fqnS4jduYswXQifJ9(cOk()dRIumNpTbvdlHlcZ4GnzfRIum27lGQ4)pSksXC(0gunSeUWwfvjWY2aaWZwfo08OqVHzYkwfPyS3xavX)FyvKI58PnOAyjCXCNIodNKvSksXyVVaQI))WQifZ5tBq1Ws4IeNtGdpkKQeyHvrwJhCqPeT3(kKvSksXyVVaQI))WQifZ5tBq1Ws4II2swXQifJ9(cOk()dRIumNpTbvdlHlanIxJ92ONJs0ivjWsn3jVF0d0iEn2BJEo4W7hPjRyvKIXEFbuf))HvrkMZN2GQHLWfAeGn(4OensvcSCJAUtE)OhOr8AS3g9CWH3pstwXQifJ9(cOk()dRIumNpTbvdlHlsCobo8OqQsGfwfznEWbLs0AYYviRyvKIXEFbuf))HvrkMZN2GQHLWfG8FSjRiRyvKIX6zRAr1ST68jLQyYHcvjWYn2gaaEvZ2QZNuQIjhkEdZUyvK14bhukrRjY4QM7K3p6bmANxQq16ZftjRyvKIX6zR6(cOTqTENb2uLalb)4e(NhA7N0OhhE)iTRBSnaa8pp02pPrVHzxQkUPG2dqZQifd)MiJ3XjRyvKIX6zR6(cOomhAB05AKSISs2j6lSniAWEHG(nSbrlXJb)VtIobi6Ocj6B(ASZajAqAodI(MhfAJMFI2rGwXWJcj60s0MB0It4jRyvKIX6v02L9le0VHnOkbw4RXod0ZJcTrZ)PrRy4rHEC49J0KvSksXy9kA79fq3yBXEDouOkbwQ5o59JELq80chohRZrrwXQifJ1ROT3xaD)cb9bWODsvcSuZDY7h9kH4PfoCowNJISIvrkgRxrBVVakq24(fcAQsGLAUtE)OxjepTWHZX6CuKvSksXy9kA79fq5rH2O5)O4)PkbwQ5o59JELq80chohRZrrwj7e9nhbkzoi6qq0wNJIODkmAI(MOdkeTzrKIHODygvent0kH4PfoCOIOnMhTwIoQqIo4McgeDAjAElmcIoeenDIEYkwfPySEfT9(cOMfrkgQsGLTbaGNTkCO5rHEdZGdC3i4hNWZwfo08Oqpo8(rAxayZ)XAo7m8nkX5ynXXah4cUPGHpsj8eIdDI3Eb8LfzfRIumwVI2EFbuaS5)ynNDgKvSksXy9kA79fqzRchAEuivjWIsiEAHdhVn6Cn6BuIZXAISiRyvKIX6v027lGIChvh8rjCc(jRiRyvKIX6Pra24JJs04cYDuHZXAoxJuLal1CN8(rpGr78sfQwFC3czfRIumwpncWgFCuIgVVaQneTKn6CnsLYP6XtWnfmSlYqvcSWQiRXdoOuIwtKXfFn2zG(pPuftouokXqBKHhhE)iTRBqJBdaa)NuQIjhkhLyOnYWBy2vn3jVF0dy0oVuHQ1NsHSIvrkgRNgbyJpokrJ3xa1gIwYgDUgPkbw2gaaEBiAPDNdfS9gMbh4KNvrwJhCqPeTMiJRTbaGNchvyNdLJneTK1By2vn3jVF0dy0oVuHQ1NsroYkwfPySEAeGn(4OenEFbuvZ2QZNuQIjhkuLalSkYA8GdkLO1KLR4QM7K3p6bmANxQq16ZftjRyvKIX6Pra24JJs049fq)Ksvm5q5SfFqvcSe8Jt4f1yRQ4Mc6XH3ps7IvrwJhCqPeTlY4QM7K3p6bmANxQq16JPG5sIX3gTqYKLRklYkwfPySEAeGn(4OenEFbuBiAjB05AKQeyPM7K3p6V1fhie)PuCvZDY7h9agTZlvOA9PuiRiRyvKIX6bY)XEXAm0yNdfYkwfPySEG8FSVVaQQzB15tkvXKdfQsGLGFCcpGOviGXFCyo0wpo8(rAxSkYA8GdkLO1ezCvZDY7h9agTZlvOA95IPKvSksXy9a5)yFFbuGNLWqmumqQsGLGFCcVf5ohkh2AzJp84W7hPjRyvKIX6bY)X((cOpxZNNTvuLal3GVg7mqV5oL4)yUtjS94W7hPDf8Jt4ReXPIhApo8(rAxBdaaFLiov8q7BKvbzfRIumwpq(p23xav1ST68jLQyYHcvjWcRISgp4GsjAnrgx1CN8(rpGr78sfQwFUykzfRIumwpq(p23xaTfQ17mWMQeyrIX3gTq62oUSCDJTbaG3gnouIQJa4GChvEdZKvSksXy9a5)yFFbuvZ2QZNuQIjhkuLalb)4eEvZ2QCOCSHOL84W7hPDvZDY7h936IdeI)CXuYkwfPySEG8FSVVa6Z185zBfvjWsn3jVF0FRloqi(JPM6QM7K3p6bmANxQq16JPMswXQifJ1dK)J99fqBHA9odSjRyvKIX6bY)X((cOaTWg7MhAQsGLGFCcFfNVneTKhhE)iTRTbaGhOf2y38q7BuIZXE7R6Ln3POODvZDY7h9agTZlvOA9XrbJSIvrkgRhi)h77lGc8SegIHIbswrwXQifJ1d0iEn2BJEokrJlpxZNNTvufCtbJtcSiXYwGhACBaa4n3Pe)hZDkHT3gSAnvjWcFn2zGEZDkX)XCNsy7BEwBYIBUOXTbaG3CNs8Fm3Pe2EBWQ1lYilx1CN8(rpGr78sfQwFm1ux1CN8(r)ftDGq8htnLSIvrkgRhOr8AS3g9CuIgVVakYDuHZXAoxJuLal1CN8(rpGr78sfQwFC3czfRIumwpqJ41yVn65OenEFbuBiAjB05AKkLt1JNGBkyyxKHQeyHvrwJhCqPeTMiJl(ASZa9FsPkMCOCuIH2idpo8(rAx3Gg3gaa(pPuftouokXqBKH3WSRAUtE)OhWODEPcvRpLczfRIumwpqJ41yVn65OenEFbuBiAjB05AKQeyzBaa4THOL2DouW2BygCGtEwfznEWbLs0AImU2gaaEkCuHDouo2q0swVHzx1CN8(rpGr78sfQwFkf5iRyvKIX6bAeVg7TrphLOX7lGQA2wD(Ksvm5qHQeyHvrwJhCqPeTMSCfx1CN8(rpGr78sfQwFUykzfRIumwpqJ41yVn65OenEFb0pPuftouoBXhuLalb)4eErn2QkUPGEC49J0UyvK14bhukr7ImUQ5o59JEaJ25LkuT(ykyUKy8TrlKmz5QYISIvrkgRhOr8AS3g9CuIgVVa6Z185zBfvjWcFn2zGEZDkX)XCNsy7BEwBYIBUOXTbaG3CNs8Fm3Pe2EBWQ1M44UQ5o59JEaJ25LkuT(yQPUQ5o59J(lM6aH4pMAkzfRIumwpqJ41yVn65OenEFbuBiAjB05AKQeyPM7K3p6V1fhie)PuCvZDY7h9agTZlvOA9PuCvZDY7h9xm1bcXFkfYkwfPySEGgXRXEB0ZrjA8(cOpxZNNTvuLal042aaWBUtj(pM7ucBVny16fzKLRAUtE)OhWODEPcvRpMAkzfzfRIumwVeNtGdpkCb4zjmedfdKQey5gBdaapWZsyigkgO3WmzfRIumwVeNtGdpk8(cOaTWg7MhAQsGLGFCcFfNVneTKhhE)iTRBSnaa8aTWg7MhAVHzx1CN8(rpGr78sfQwFCuWiRiRyvKIX6fMXb7LwOwVZaBQsGfjgFB0cPBlJJ5ksj82uu0KvKvSksXy9M7u0z4Cr1ST68jLQyYHcvjWcRISgp4GsjAnzrEzJ7iFWpoHhq0keW4pomhARhhE)iT7VICY5QM7K3p6bAeVg7TrphC49J0UQ5o59JEaJ25LkuT(CXuYkwfPySEZDk6mCEFb0NR5ZZ2kQsGf(ASZa9M7uI)J5oLW238S2Kf3CrJBdaaV5oL4)yUtjS92GvRxKrwUyvK14bhukr7ImUQ5o59JEGgXRXEB0ZbhE)iTRAUtE)OhWODEPcvRpMAkzfRIumwV5ofDgoVVakWZsyigkgivjWsn3jVF0d0iEn2BJEo4W7hPDTnaa8aplHHyOyG(gL4CS3MII2fRISgp4GsjAnrgYkwfPySEZDk6mCEFbuGwyJDZdnvjWsn3jVF0d0iEn2BJEo4W7hPDTnaa8aTWg7MhAFJsCo2Btrr7IvrwJhCqPeTMidzfRIumwV5ofDgoVVaQQzB15tkvXKdfQsGLBSnaa8QMTvNpPuftou8gMDXQiRXdoOuIwtKXvn3jVF0dy0oVuHQ1NlMswXQifJ1BUtrNHZ7lGcy0opcGdNnvjWYn2gaaEaJ25raC4S9gMDjX4BJwizYIBYYL1m()j4McgwpGr78iaoC2hAwIPGMSiVm3R5o59JEGgXRXEB0ZbhE)iTCKvSksXy9M7u0z48(cOagTZJa4WztvcSSnaa8agTZJa4Wz7nm7YAg))eCtbdRhWODEeaho7dnlXuWBlVm3R5o59JEGgXRXEB0ZbhE)iTCKvSksXy9M7u0z48(cOHiqPJeBdSDsvcSSnaa8nAfdpk8eIaL8nkX5yV9IBUNIIMSIvrkgR3CNIodN3xa1Am0yNdfQsGfwfznEWbLs0AYYviRyvKIX6n3POZW59fqBHA9odSPkbwc(Xj8pp02pPrpo8(rAx3yBaa4FEOTFsJEdZUuvCtbThGMvrkg(nrgVJtwj7e9nDgven1Cy08t03u5wsmoPIOXhR5aj6OcjAZDk6mCs0caIgFucNGFIMJGvRTeDoeTOPXMOdbrlX5eCoeDuHe92aaWs0oSchIoQqNoYgjAElmcIoeenkBzoB0twXQifJ1BUtrNHZ7lGc0cBSBEOPkbwKNVg7mq)WHrZ)PIBjX40JdVFK212aaWpCy08FQ4wsmopaTWg(gL4CS3EXn3trrlNRGFCcFfNVneTKhhE)iTRAUtE)OhWODEPcvRpokyKvSksXy9M7u0z48(cOaplHHyOyGuLalYZxJDgOF4WO5)uXTKyC6XH3ps7ABaa4homA(pvCljgNhGSrFJsCo2BV4M7POOLJSIvrkgR3CNIodN3xaTfQ17mWMQeyrE(ASZa9dhgn)NkULeJtpo8(rAxBdaa)WHrZ)PIBjX48mCy0OVrjoh7TxCZ9uu0Y5sIX3gTq62oUSGfRzubP2nW)kWagqi]] )


end
