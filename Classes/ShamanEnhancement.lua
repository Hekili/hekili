-- ShamanEnhancement.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


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

        ls_overcharge = {
            aura = "lightning_shield_overcharge",

            last = function ()
                local app = state.buff.lightning_shield_overcharge.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 10
        }
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
        lightning_conduit = {
            id = 275391,
            duration = 60,
            max_stack = 1
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


    spec:SetPotion( 'prolonged_power' )

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

            toggle = "cooldowns",            
            
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
                if buff.ascendance.up then return 10 end
                return 30
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

                removeBuff( 'stormbringer' )

                if azerite.lightning_conduit.enabled then
                    applyDebuff( "target", "lightning_conduit" )
                end

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

                removeBuff( 'stormbringer' )

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


    spec:RegisterPack( "Enhancement", 20180813.1824, [[dKKuWaqifHhPQkYMOu9jfrmkvfNsvPvHsQ6vKsMfPu3svvu7IQ(fk0Wqjogkyzuk9mkfMgLIUMI02qjLVrLQghvQCovvPADkIK5PQQ6EQu7tL4GQQsAHOOEivkxuvvkFuvvqJurKItQQkXkLcZurKk3urKs7uL0pvvvgQIOwkkPspvQMQu0vvePQVQQkK9Q0FPIbtYHjwSkEmstwHldTzv5ZkQrlLoTKxRQYSbUnPA3I(nQgovYXvvfy5iEoftx46uY2rP(okjJhLuX5rrwVQQqnFsX(b9YW2C7djW9QTSWG7yXDmydpdSMT20M2C7btUWT7sO)KzC7POJB)VLTssrDmJT7sycWLX2C7gUfHIBVncxMjfJmoxrR1Xt56mAkDlGefpPe5fmAkDkJha)W45j)5bYMrxe(RaOHXMfsSLbgBAldo9wrxsN)w2kjf1Xm8MsNU9JvbI)sUNTpKa3R2YcdUJf3XGn8mWA2YGnTX2nUq6E1wwZgBFGg62B2wgOQmqLavUe6pzgHk(dQeAu8eQaLjmq1JtGQjn4VcuEydyJ)6yGdOYfbPC9JeqfMbHjO6XjqvtEG6q1KwXeiHj)2bLjmBZTt5eCBUxzyBUDmLdahlZBNsQajLSD2cPKda9plctU1I0F2oD7cnkEUDuirlMogx1pCJ9QTBZTJPCa4yzE7usfiPKTl0OyJoyI6fAGQl3qLn2UqJINB3yLdKu58g7vBSn3oMYbGJL5TtjvGKs2U8hJKkqpOMBJSYzhkphwv4XuoaCav2HQjGQbESEppOMBJSYzhkphwv4TCbv2HkHgfB0btuVqduDbQyaQSdvFGQJ175nbNOFivoJeVLlOsJgO6duXwiLCaO)FUnzoh4EwGk7qfBHuYbG(NfHj3Ar6pBmfQ(cvF3UqJINB3eCIUji1pC7uMOa0jeYmgM9kdBSxT52C7ykhaowM3oLubskz7hR3ZBcor)qQCgjElxqLgnq1hO6y9E(zjArsLZoMGt0nElxqLDOITqk5aq))CBYCoW9Sav2Hk2cPKda9plctU1I0F2yku9D7cnkEUDtWj6MGu)Wn2Rt3MBht5aWXY82PKkqsjBxOrXgDWe1l0avxUHkBav2Hk2cPKda9plctU1I0F2oD7cnkEUDkrmToGAUnYkN3yVYABZTJPCa4yzE7usfiPKThcaZWZzJeARqMrpMYbGdOYouj0OyJoyI6fAGQBOIbOYouXwiLCaO)zryYTwK(ZMtHk7qLUGatq46q1LBOYMSSDHgfp3oOMBJSYzNdheBSxD)2C7ykhaowM3oLubskz7Sfsjha6)NBtMZbUNfOYouXwiLCaO)zryYTwK(Zgt3UqJINB3eCIUji1pCJ9Q72MBxOrXZTBSYbsQCE7ykhaowM3yV(33MBht5aWXY82PKkqsjBpeaMH)Xju8zbCyvLdJht5aWbuzhQeAuSrhmr9cnq1fOIbOYouXwiLCaO)zryYTwK(Z2PBxOrXZTtjIP1buZTrw58g7vgyzBUDmLdahlZBNsQajLS9qaygEdkKkNDeJrSaHht5aWX2fAu8C7pGOJbpNTWn2RmWW2C7ykhaowM3oLubskz7HaWm8T8WPvYHht5aWbuzhQowVNVLhoTso8euOX2fAu8C7aHT4aet7g7vgSDBUDmLdahlZBNsQajLSDHgfB0btuVqduDbQyaQSdvSfsjha6FweMCRfP)SD62fAu8C7uIyADa1CBKvoVXgBxm0T5ELHT52XuoaCSmVDkPcKuY2NaQowVNNsetRdOMBJSYzVLlOYouj0OyJoyI6fAGQlqfdqLDOITqk5aq)ZIWKBTi9NTt3UqJINBNsetRdOMBJSY5n2R2Un3oMYbGJL5TtjvGKs2EiamdpqYHbud0JPCa4aQSdvtavhR3ZdKCya1a9wUGk7qfTviZOX5reAu8uaq1fOIbV73UqJINBNWP)ovGKn2R2yBUDHgfp3oRQCycs9d3oMYbGJL5n2y7d8jwGyBUxzyBUDHgfp3oRQC4yArHSDmLdahlZBSxTDBUD2cWc3(hOAcOkeaMH)zryYH)CKI4XuoaCavA0avFGQqayg(NfHjh(ZrkIht5aWbuzhQ0feyccxhQUav2Cku9fQ(UDmLdahlZBxOrXZTZwiLCa42zleNu0XT)Sim5wls)zZPBSxTX2C7SfGfU9pq1eqviamd)ZIWKd)5ifXJPCa4aQ0ObQ(avHaWm8plcto8NJuepMYbGdOYouPliWeeUouDbQSXuO6lu9D7ykhaowM3UqJINBNTqk5aWTZwioPOJB)zryYTwK(Zgt3yVAZT52zlalC7FGQjGQqayg(NfHjh(ZrkIht5aWbuPrdu9bQcbGz4FweMC4phPiEmLdahqLDOsxqGjiCDO6cuz7uO6lu9D7ykhaowM3UqJINBNTqk5aWTZwioPOJB)zryYTwK(Z2PBSxNUn3oBbyHB)dunbufcaZWZzJeARqMrpMYbGdOsJgOsOrXgDWe1l0avxGkgGknAGQpqviamdpNnsOTczg9ykhaoGk7qLqJIn6GjQxObQUHkgGk7q1hOIY5GbNvPhuZTrw5SZHdcpb1Lknq1LBOYwOI1dvZ0buPrduPliWeeUouDbQChlq1xO6lu9D7ykhaowM3UqJINBNTqk5aWTZwioPOJB)FUnzoh4ow2yVYABZTZwaw42)avtavHaWm8C2iH2kKz0JPCa4aQ0ObQeAuSrhmr9cnq1fOIbOsJgO6dufcaZWZzJeARqMrpMYbGdOYouj0OyJoyI6fAGQBOIbOYou9bQOCoyWzv6b1CBKvo7C4GWtqDPsduD5gQSfQy9q1mDavA0av6ccmbHRdvxGk3Zcu9fQ(cvF3oMYbGJL5Tl0O452zlKsoaC7SfItk642)NBtMZbUNLn2RUFBUD2cWc3(hOAcOkeaMHNZgj0wHmJEmLdahqLgnqLqJIn6GjQxObQUavmavA0avFGQqaygEoBKqBfYm6XuoaCav2HkHgfB0btuVqduDdvmav2HQpqfLZbdoRspOMBJSYzNdheEcQlvAGQl3qLTqfRhQMPdOsJgOsxqGjiCDO6cuXASavFHQVq13TJPCa4yzE7cnkEUD2cPKda3oBH4KIoU9)52K5CaRXYg7v3Tn3UqJINBxScUJeHq)TDmLdahlZBSx)7BZTl0O452TmOtfOUz7ykhaowM3yVYalBZTJPCa4yzE7cnkEUDQaaocnkE6aktSDqzcNu0XTZDHjs2yVYadBZTJPCa4yzE7cnkEUDQaaocnkE6aktSDkPcKuY2pwVNxmumhssrVLRTdkt4KIoUDXq3yVYGTBZTJPCa4yzE7cnkEUDQaaocnkE6aktSDqzcNu0XTFSEpZg7vgSX2C7ykhaowM3UqJINBNkaGJqJINoGYeBhuMWjfDC70HzJ9kd2CBUDmLdahlZBxOrXZTtfaWrOrXthqzITdkt4KIoUDkNGBSxzy62C7ykhaowM3UqJINBNkaGJqJINoGYeBhuMWjfDC7VcaqYgBSDxeKY1psSn3RmSn3oMYbGJL5n2R2Un3oMYbGJL5n2R2yBUDmLdahlZBSxT52C7ykhaowM3yVoDBUDHgfp3EWdu3rxmbsyA7ykhaowM3yVYABZTl0O452DXJINBht5aWXY8g7v3Vn3UqJINBhuZTrw5SJPTqWy7ykhaowM3yJTthMT5ELHT52XuoaCSNTtjvGKs2EiKzm8TOaIwVlAav)hQSDkuPrdufLocvxGkw8tzHLTl0O452paoFaSmXg7vB3MBht5aWXY82PKkqsjB)dufcaZWlgkMdjPOht5aWbuzhQowVNxmumhssrVLlO6luPrdu9bQcbGz4raQJziahJRIuHXJPCa4aQSdvpKiahJRIuHNG6sLgO6cunfQ(cvA0avFGQjGQqaygEXqXCijf9ykhaoGk7q1eqviamdpcqDmdb4yCvKkmEmLdahq13Tl0O452piXGKFvoVXE1gBZTJPCa4yzE7usfiPKT)bQcbGz4fdfZHKu0JPCa4aQSdvFGQJ175fdfZHKu0B5cQ0ObQOCoyWzv6fdfZHKu0tqDPsduDbQMYcu9fQ(cvA0avFGQjGQqaygEXqXCijf9ykhaoGk7q1hO6Heb4yCvKk8euxQ0avxGQPqLgnqfLZbdoRs)djcWX4Qiv4jOUuPbQUavtzbQ(cvF3UqJINB)a48HZZIW0g7vBUn3oMYbGJL5TtjvGKs2(hOkeaMHxmumhssrpMYbGdOYou9bQowVNxmumhssrVLlOsJgOIY5GbNvPxmumhssrpb1Lknq1fOAklq1xO6luPrdu9bQMaQcbGz4fdfZHKu0JPCa4aQSdvFGQhseGJXvrQWtqDPsduDbQMcvA0avuohm4Sk9pKiahJRIuHNG6sLgO6cunLfO6lu9D7cnkEU9xrWdGZhBSxNUn3oMYbGJL5TtjvGKs2(hOkeaMHxmumhssrpMYbGdOYou9bQowVNxmumhssrVLlOsJgOIY5GbNvPxmumhssrpb1Lknq1fOAklq1xO6luPrdu9bQMaQcbGz4fdfZHKu0JPCa4aQSdvFGQhseGJXvrQWtqDPsduDbQMcvA0avuohm4Sk9pKiahJRIuHNG6sLgO6cunLfO6lu9D7cnkEUDjPOjicWHkaWg7vwBBUDmLdahlZBNsQajLS9J175fdfZHKu0B5cQ0ObQMaQcbGz4fdfZHKu0JPCa4aQSdvpKiahJRIuHNG6sLgO6cunfQ0ObQcHmJHpkD0j4oJcHQ)FdvSglBxOrXZT7Ihfp3yV6(T52fAu8C7pKiahJRIuX2XuoaCSmVXE1DBZTJPCa4yzE7usfiPKTt5CWGZQ0Bcs9d9euxQ0avxGkw2UqJINBxmumhssXn2R)9T52fAu8C7OqIwheG6ygcy7ykhaowM3yJTFSEpZ2CVYW2C7ykhaowM3oLubskz7tavhR3ZtjIP1buZTrw5S3YfuzhQeAuSrhmr9cnq1fOIbOYouXwiLCaO)zryYTwK(Z2PBxOrXZTtjIP1buZTrw58g7vB3MBht5aWXY82PKkqsjBpeaMHhi5WaQb6XuoaCav2HQjGQJ175bsomGAGElxqLDOI2kKz048icnkEkaO6cuXG39BxOrXZTt40FNkqYg7vBSn3oMYbGJL5TtjvGKs2(eqvu0Fvodv2HkDbbMGW1HQl3qLTSSDHgfp3(ZIWKd)5ifzJ9Qn3MBht5aWXY82PKkqsjBFcO6y9E(hq0XGNZwO3Y12fAu8C7pGOJbpNTWn2Rt3MBht5aWXY82PKkqsjBpeaMHVvkGj4eDpMYbGdOYounbuDSEp)JWnXHi5WB5cQSdvSfsjha6FweMCRfP)SD62fAu8C7pc3ehIKJn2RS22C7ykhaowM3oLubskz7hR3Z)aIog8C2c9euxQ0av)hQSP3DqLwq1mDSDHgfp3(di6yWZzlCJ9Q73MBht5aWXY82PKkqsjBpeaMHVvkGj4eDpMYbGdOYouDSEp)JWnXHi5WtqDPsdu9FOYME3bvAbvZ0buzhQylKsoa0)Sim5wls)z70Tl0O452FeUjoejhBSxD32C7ykhaowM3oLubskz7hR3ZtqdpLKIobpqDpb1Lknq1)HkB3UqJINBp4bQ7OlMajmTXgB)vaas2M7vg2MBht5aWXY82PKkqsjBxxqGjiCDO6)qL7zz7cnkEUDcN(7ubs2yVA72C7ykhaowM3oLubskz7HaWm8uIyARC2XeCIUht5aWbuzhQylKsoa0)p3MmNdynw2UqJINBNsetRdOMBJSY5n2R2yBUDmLdahlZBNsQajLSD2cPKda9)ZTjZ5a3XcuzhQylKsoa0)Sim5wls)zZPBxOrXZTde2IdqmTBSxT52C7cnkEUDcN(7ubs2oMYbGJL5n2Rt3MBxOrXZT)aIog8C2c3oMYbGJL5n2y7CxyIKT5ELHT52XuoaCSmVDkPcKuY21feyccxhQ(puXWuOYoufLocv)hQMPJTl0O452jC6VtfizJn2y7SrIP45E1wwyWDS4EBDNNb3XYFF7SsizLZMT)h9xzDV(xU(hoPGkOQzlcvLUlojGQhNavtcLtWjbQi4FGvrWbuz46iujwbxxcCav0wjNrJh2OzlcvpoaWzvLZqLyreduXkKGqLLbhqvLqv0IqLqJINqfOmbuDScOIvibHQKhq1JBLdOQsOkArOsgdEcvdjKJyWjfSbu9NHQzjArsLZoMGt0nWgWg)r)vw3R)LR)HtkOcQA2IqvP7ItcO6Xjq1KmWNybIjbQi4FGvrWbuz46iujwbxxcCav0wjNrJh2ysxLiu5UjfunPpnwUCXjboGkHgfpHQjrScUJeHq)njEydyJ)IUlojWbu5oOsOrXtOcuMW4Hn2Ulc)vaC7)jO6VX6GuRahq1bFCccvuU(rcO6GZvA8q1FLsrxHbQsE(NBfI(ZcavcnkEAGkEcyYdBi0O4PX7IGuU(rI7hqm)GneAu804Drqkx)iHw3m(48bSHqJINgVlcs56hj06MrXAwhZqIINWg)jOQNIltlpGkIudO6y9E4aQmHegO6GpobHkkx)ibuDW5knqLKdOYfb)ZU4ru5muvgOAWt0dBi0O4PX7IGuU(rcTUz0KIltlpCmHegydHgfpnExeKY1psO1nJbpqDhDXeiHjydHgfpnExeKY1psO1nJU4rXtydHgfpnExeKY1psO1nJGAUnYkNDmTfcgWgWg)jO6VX6GuRahqfYgjmbvrPJqv0IqLqdobQkdujSLciha6HneAu80CZQkhoMwuiWgcnkEA06Mr2cPKda1ofD8(zryYTwK(ZMt1MTaSW7ptecaZW)Sim5WFosr8ykhao0O5tiamd)ZIWKd)5ifXJPCa4WUUGatq46xS50VFHneAu80O1nJSfsjhaQDk649ZIWKBTi9NnMQnBbyH3FMieaMH)zryYH)CKI4XuoaCOrZNqayg(NfHjh(ZrkIht5aWHDDbbMGW1VyJPF)cBi0O4PrRBgzlKsoau7u0X7NfHj3Ar6pBNQnBbyH3FMieaMH)zryYH)CKI4XuoaCOrZNqayg(NfHjh(ZrkIht5aWHDDbbMGW1Vy70VFHneAu80O1nJSfsjhaQDk649)CBYCoWDSOnBbyH3FMieaMHNZgj0wHmJEmLdahA0i0OyJoyI6fAUWGgnFcbGz45SrcTviZOht5aWHDHgfB0btuVqZnd2)q5CWGZQ0dQ52iRC25WbHNG6sLMl32Y6NPdnA0feyccx)I7y573VWgcnkEA06Mr2cPKda1ofD8(FUnzoh4Ew0MTaSW7ptecaZWZzJeARqMrpMYbGdnAeAuSrhmr9cnxyqJMpHaWm8C2iH2kKz0JPCa4WUqJIn6GjQxO5Mb7FOCoyWzv6b1CBKvo7C4GWtqDPsZLBBz9Z0Hgn6ccmbHRFX9S897xydHgfpnADZiBHuYbGANIoE)p3MmNdynw0MTaSW7ptecaZWZzJeARqMrpMYbGdnAeAuSrhmr9cnxyqJMpHaWm8C2iH2kKz0JPCa4WUqJIn6GjQxO5Mb7FOCoyWzv6b1CBKvo7C4GWtqDPsZLBBz9Z0Hgn6ccmbHRFH1y573VWgcnkEA06MrXk4osec9hSHqJINgTUz0YGovG6gydHgfpnADZivaahHgfpDaLj0ofD8M7ctKaBi0O4PrRBgPca4i0O4PdOmH2POJ3IHQD9UpwVNxmumhssrVLlydHgfpnADZivaahHgfpDaLj0ofD8(y9EgydHgfpnADZivaahHgfpDaLj0ofD8MomWgcnkEA06MrQaaocnkE6aktODk64nLtqydHgfpnADZivaahHgfpDaLj0ofD8(vaasGnGneAu804fd9MsetRdOMBJSYzTR39ehR3ZtjIP1buZTrw5S3YLDHgfB0btuVqZfgSZwiLCaO)zryYTwK(Z2PWgcnkEA8IHQ1nJeo93PcKOD9UdbGz4bsomGAGEmLdah2N4y9EEGKddOgO3YLDARqMrJZJi0O4PaUWG39WgcnkEA8IHQ1nJSQYHji1pe2a2qOrXtJ)y9EMBkrmToGAUnYkN1UE3tCSEppLiMwhqn3gzLZElx2fAuSrhmr9cnxyWoBHuYbG(NfHj3Ar6pBNcBi0O4PXFSEpJw3ms40FNkqI217oeaMHhi5WaQb6XuoaCyFIJ175bsomGAGElx2PTczgnopIqJINc4cdE3dBi0O4PXFSEpJw3m(Sim5WFosr0UE3tef9xLZ21feyccx)YTTSaBi0O4PXFSEpJw3m(aIog8C2c1UE3tCSEp)di6yWZzl0B5c2qOrXtJ)y9EgTUz8r4M4qKCOD9UdbGz4BLcycor3JPCa4W(ehR3Z)iCtCiso8wUSZwiLCaO)zryYTwK(Z2PWgcnkEA8hR3ZO1nJpGOJbpNTqTR39X698pGOJbpNTqpb1Lkn)3ME3P1mDaBi0O4PXFSEpJw3m(iCtCiso0UE3HaWm8TsbmbNO7XuoaCy)y9E(hHBIdrYHNG6sLM)BtV70AMoSZwiLCaO)zryYTwK(Z2PWgcnkEA8hR3ZO1nJbpqDhDXeiHjTR39X698e0WtjPOtWdu3tqDPsZ)Tf2a24pbvmd48bWYeqfvmrLZq1bBf2fNav6fHWjgOkArOYu6waj4eOYGru5SbQECcu5IWzDycQoaoFaSmHhQ6icvCxrXtdunjhaNpawMWXfsOygtI2qLKdOAsoaoFaSmHtu64K4HkydHgfpnE6WCFaC(ayzcTR3DiKzm8TOaIwVlA8FBNQrtu64fw8tzHfydHgfpnE6WO1nJhKyqYVkN1UE3FcbGz4fdfZHKu0JPCa4W(X698IHI5qsk6TC9vJMpHaWm8ia1XmeGJXvrQW4XuoaCy)Heb4yCvKk8euxQ0Cz6xnA(mriamdVyOyoKKIEmLdah2NieaMHhbOoMHaCmUksfgpMYbGJVWgcnkEA80HrRBgpaoF48SimPD9U)ecaZWlgkMdjPOht5aWH9phR3ZlgkMdjPO3YLgnuohm4Sk9IHI5qsk6jOUuP5Yuw((vJMptecaZWlgkMdjPOht5aWH9ppKiahJRIuHNG6sLMlt1OHY5GbNvP)Heb4yCvKk8euxQ0CzklF)cBi0O4PXthgTUz8ve8a48H217(tiamdVyOyoKKIEmLdah2)CSEpVyOyoKKIElxA0q5CWGZQ0lgkMdjPONG6sLMltz57xnA(mriamdVyOyoKKIEmLdah2)8qIaCmUksfEcQlvAUmvJgkNdgCwL(hseGJXvrQWtqDPsZLPS89lSHqJINgpDy06MrjPOjicWHkaG217(tiamdVyOyoKKIEmLdah2)CSEpVyOyoKKIElxA0q5CWGZQ0lgkMdjPONG6sLMltz57xnA(mriamdVyOyoKKIEmLdah2)8qIaCmUksfEcQlvAUmvJgkNdgCwL(hseGJXvrQWtqDPsZLPS89lSHqJINgpDy06Mrx8O4P217(y9EEXqXCijf9wU0OzIqaygEXqXCijf9ykhaoS)qIaCmUksfEcQlvAUmvJMqiZy4JshDcUZOW)FZASaBi0O4PXthgTUz8Heb4yCvKkGneAu804PdJw3mkgkMdjPO217MY5GbNvP3eK6h6jOUuP5clWgcnkEA80HrRBgrHeToia1XmeaSbSHqJINgpLtWBuirlMogx1pu76DZwiLCaO)zryYTwK(Z2PWgcnkEA8uob16MrJvoqsLZAxVBHgfB0btuVqZLBBaBi0O4PXt5euRBgnbNOBcs9d1MYefGoHqMXWCZG217w(JrsfOhuZTrw5SdLNdRk8ykhaoSpXapwVNhuZTrw5SdLNdRk8wUSl0OyJoyI6fAUWG9phR3ZBcor)qQCgjElxA08HTqk5aq))CBYCoW9SyNTqk5aq)ZIWKBTi9NnM(9lSHqJINgpLtqTUz0eCIUji1pu76DFSEpVj4e9dPYzK4TCPrZNJ175NLOfjvo7ycor34TCzNTqk5aq))CBYCoW9SyNTqk5aq)ZIWKBTi9NnM(f2qOrXtJNYjOw3msjIP1buZTrw5S217wOrXgDWe1l0C52g2zlKsoa0)Sim5wls)z7uydHgfpnEkNGADZiOMBJSYzNdheAxV7qaygEoBKqBfYm6XuoaCyxOrXgDWe1l0CZGD2cPKda9plctU1I0F2CQDDbbMGW1VCBtwGneAu804PCcQ1nJMGt0nbP(HAxVB2cPKda9)ZTjZ5a3ZID2cPKda9plctU1I0F2ykSHqJINgpLtqTUz0yLdKu5mSHqJINgpLtqTUzKsetRdOMBJSYzTR3Diamd)JtO4Zc4WQkhgpMYbGd7cnk2OdMOEHMlmyNTqk5aq)ZIWKBTi9NTtHneAu804PCcQ1nJpGOJbpNTqTR3DiamdVbfsLZoIXiwGWJPCa4a2qOrXtJNYjOw3mce2IdqmTAxV7qayg(wE40k5WJPCa4W(X698T8WPvYHNGcnGneAu804PCcQ1nJuIyADa1CBKvoRD9UfAuSrhmr9cnxyWoBHuYbG(NfHj3Ar6pBNcBaBi0O4PX)kaaj3eo93PcKOD9U1feyccx))UNfydHgfpn(xbairRBgPeX06aQ52iRCw76DhcaZWtjIPTYzhtWj6EmLdah2zlKsoa0)p3MmNdynwGneAu804FfaGeTUzeiSfhGyA1UE3Sfsjha6)NBtMZbUJf7Sfsjha6FweMCRfP)S5uydHgfpn(xbairRBgjC6Vtfib2qOrXtJ)vaas06MXhq0XGNZwiSbSHqJINgp3fMi5MWP)ovGeTR3TUGatq46)NHP2Jsh))mDSDXkA5KT3lD3GQpSUwgPvBOAYwKz87gBSla]] )


end
