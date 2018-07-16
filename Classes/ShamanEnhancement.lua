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
            resource = 'maelstrom',
            -- setting = 'forecast_swings',

            last = function ()
                local swing = state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            stop = function ()
                local swing = state.swings.mainhand
                local t = state.query_time

                return t - swing > state.swings.mainhand_speed * 1.5
            end,

            interval = 'mainhand_speed',
            value = 5
        },

        offhand = {
            resource = 'maelstrom',
            -- setting = 'forecast_swings',

            last = function ()
                local swing = state.swings.offhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
            end,

            stop = function ()
                local swing = state.swings.offhand
                local t = state.query_time

                return t - swing > state.swings.offhand_speed * 1.5
            end,

            interval = 'offhand_speed',
            value = 5
        },

        fury_of_air = {
            resource = 'maelstrom',
            -- setting = 'forecast_fury',
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
        },

        molten_weapon = {
            id = 271924,
            duration = 4,
        },

        shock_of_the_twisting_nether = {
            id = 207999,
            duration = 8,
        },

        stormbringer = {
            id = 201846,
            duration = 12,
            max_stack = 1,
        },

        totem_mastery = {
            name = "Totem Mastery",
            duration = 120,
            generate = function ()
                local expires, remains = 0, 0

                for i = 1, 5 do
                    local _, name, cast, duration = GetTotemInfo(i)

                    if name == class.abilities.totem_mastery.name then
                        expires = cast_time + 120
                        remains = expires - now
                        break
                    end
                end

                local up = buff.resonance_totem.up or remains > 110

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


    spec:RegisterStateTable( 'feral_spirit', 
        setmetatable( { onReset = function( self ) self.cast_time = nil end },
        { __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.feral_spirit.lastCast or 0
                return t.cast_time
            elseif k == 'active' or k == 'up' then
                return query_time < t.cast_time + 15
            elseif k == 'remains' then
                return max( 0, t.cast_time + 15 - query_time )
            end

            return false
        end } ) )

    spec:RegisterStateTable( 'twisting_nether',
        setmetatable( { onReset = function( self ) end },
        { __index = function( t, k )
            if k == 'count' then
                return ( buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( buff.shock_of_the_twisting_nether.up and 1 or 0 )
            end
            
            return 0
        end } ) )

    spec:RegisterGear( 'tier21', 152169, 152171, 152167, 152166, 152168, 152170 )
        spec:RegisterAura( 'force_of_the_mountain', {
            id = 254308,
            duration = 10
        } )
        spec:RegisterAura( 'exposed_elements', {
            id = 252151,
            duration = 4.5
        } )

    spec:RegisterGear( 'waycrest_legacy', 158362, 159631 )
    spec:RegisterGear( 'electric_mail', 161031, 161034, 161032, 161033, 161035 )
    -- spec:RegisterGear( 'fake_set_test', 155325, 155262, 159907 )

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
                
                if set_bonus.tier20_2pc > 1 then
                    applyBuff( 'lightning_crash' )
                end

                if level < 105 then 
                    if equipped.emalons_charged_core and spell_targets.crash_lightning >= 3 then
                        applyBuff( 'emalons_charged_core', 10 )
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

            recheck = function () return buff.flametongue.remains, buff.flametongue.remains - 4.8, buff.flametongue.remains - ( 6 + gcd ) end,

            startsCombat = true,

            handler = function ()
                applyBuff( 'flametongue', 16 + min( 4.8, buff.flametongue.remains ) )

                if level < 105 and equipped.eye_of_the_twisting_nether then
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

            recheck = function () return buff.frostbrand.remains, buff.frostbrand.remains - 4.8, buff.frostbrand.remains - ( 6 + gcd ) end,
            handler = function ()
                applyBuff( 'frostbrand', 16 + min( 4.8, buff.frostbrand.remains ) )
                if level < 105 and equipped.eye_of_the_twisting_nether then
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
                if level < 105 and equipped.eye_of_the_twisting_nether then
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
                if level < 105 and equipped.eye_of_the_twisting_nether then
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
                if level < 105 and equpped.eye_of_the_twisting_nether then
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
                if buff.ascendance.up then return 9 * 0.2 end
                return 9 * haste
            end,
            gcd = "spell",

            spend = function()
                if buff.stormbringer.up then return 0 end
                if buff.ascendance.up then return 6 end
                return 30
            end,

            spendType = 'maelstrom',

            startsCombat = true,
            texture = 132314,

            usable = function() return buff.ascendance.down end,
            handler = function ()
                removeBuff( 'stormbringer' )
                setCooldown( 'windstrike', action.stormstrike.cooldown )
                setCooldown( 'strike', action.stormstrike.cooldown )
    
                if level < 105 and equipped.storm_tempests then
                    applyDebuff( 'target', 'storm_tempests', 15 )
                end
    
                if set_bonus.tier20_4pc > 0 then
                    addStack( 'crashing_lightning', 16, 1 )
                end
    
                if level < 105 and equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                    applyBuff( 'shock_of_the_twisting_nether', 8 )
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

            handler = function () if level < 105 and equipped.eye_of_the_twisting_nether then applyBuff( 'shock_of_the_twisting_nether' ) end end,
        },


        totem_mastery = {
            id = 210643,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            talent = "totem_mastery",

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
            cooldown = function() return buff.stormbringer.up and 0 or ( 9 * 0.2 * haste ) end,
            gcd = "off",

            spend = function() return buff.stormbringer.up and 0 or 6 end,
            spendType = "maelstrom",
            
            texture = 1029585,

            known = 17364,
            usable = function () return buff.ascendance.up end,
            handler = function ()
                setCooldown( 'stormstrike', action.stormstrike.cooldown )
                setCooldown( 'strike', action.stormstrike.cooldown )

                removeBuff( 'stormbringer' )

                if level < 105 and equipped.storm_tempests then
                    applyDebuff( 'target', 'storm_tempests', 15 )
                end
    
                if set_bonus.tier20_4pc > 0 then
                    addStack( 'crashing_lightning', 16, 1 )
                end
    
                if level < 105 and equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                    applyBuff( 'shock_of_the_twisting_nether', 8 )
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
    
        package = "Enhancement",
    } )


    spec:RegisterPack( "Enhancement", 20180625.1050,
        [[di0LQaqiLqpsjOSjr0NucQgfc5uiuRsji5vGuZcbUfIi1Ue6xQKgMsQJjcTmrWZifzAkjDnePTHi8nsbJtjW5ucsToLGG5rk09eL9bchuji0cbrpujXfreHrQee5KkbrTsLODQs8tsr1qre1srerpvWufP2RK)sQgmLomQfRupMKjdQldTzv8zvQrlQoTIxdsMTQUnr2Tu)MWWfjlh45umDQUorTDe13jfLXJisopcA(Ks7hPReR0vaMDSUKW6exWAnKiPXe00AstiXk4eMcRqkwbfFJvOzjScKeDo3kucBVcPycFbdxPRGriduyfYDpLzHW1R3JNlVJkH0vZij)SpIwb4JF1msQR7xSVUpmjnms(AkG4mpAUEJncyxamxjzassYdS5kjtsQhYzjU1jj6CUvOe2E0msQkSLN3xi31UcWSJ1LewN4cwRHejnMGMwtAIAOcMuOQUKaj0ufGrJQcPZhd1ogQLP2uSck(gPwXHAzLpIMA)X4gQ9iau7cjeQ5Nyf(X4MkDfucawPRljwPRa28(r4cYkOaJJGHRazgm8(X4rgq4k5OcQeiTcSYhrxbKbEo26Muduy51LeQ0vaBE)iCbzfuGXrWWvyrQDlForfGn56)CN7903r5uuBsQLv(qg1XgLg0qTqKrTjubw5JORGcWMC9FUZ9E67YRlAQsxbS59JWfKvqbghbdxbw5dzuhBuAqd1crg1UaQvRwQLiQLv(qg1XgLg0qTqKrTKGAtsTo)y7rfGn5tFRBCbqkInVFeMAjUcSYhrxbfGn56)CN7903LxxwTsxbS59JWfKvqbghbdxHT85enUaiTbtFJGOCQkWkFeDfmUaizCWafwEDH0kDfWM3pcxqwbfyCemCfyLpKrDSrPbnulezu7QuRwTulrulR8HmQJnknOHAHiJAtGAtsTo)y7rfGn5tFRBCbqkInVFeMAjUcSYhrxbfGn56)CN7903LxxirLUcyZ7hHliRGcmocgUco)y7rbzeOYzWngXM3pctTjPwYmy49JXJmGWvYrfuRsk1MKALy8noqirTqKrTRUUcSYhrxHFUZ9E6B9T49YRlAOsxbS59JWfKvqbghbdxbIO2fPwNFS9OGmcu5m4gJyZ7hHP2Kulzgm8(X4rgq4k5Ocknrk1sm1Qvl1se168JThfKrGkNb3yeBE)im1MKAjZGH3pgpYacxjhvqTG1ulXvGv(i6kyCbqY4GbkS86YcQ0vGv(i6kyKByem9DfWM3pcxqwEDzHUsxbS59JWfKvqbghbdxbNFS9ObzW036SXWYVhXM3pcxbw5JORW5zj0f9TmwEDjX1v6kGnVFeUGSckW4iy4kSLpNyUW1Z5gocqw5vGv(i6k8mzw)ztE51LetSsxbS59JWfKvqbghbdxbw5dzuhBuAqd1crg1QPkWkFeDfua2KR)ZDU3tFxE5vqKcBeuPRljwPRa28(r4cYkOaJJGHRGeJVXbcjQvJuBIKsTjPwFKqQvJu7TcUcSYhrxbGqb1ECeuE5vagpS87v66sIv6kWkFeDf0SPH1n5idQa28(r4cYYRljuPRa28(r4cYkqMFzScerTerTo)y7XCEEJlasrS59JWuBsQDrQDlFoXdqy8nGB4OCkQLyQvRwQDrQ15hBpMZZBCbqkInVFeMAjUcSYhrxbYmy49JvGmd0BwcRqopVXfaPvYrfuLxx0uLUcyZ7hHliRaz(LXkqe1Ui168JThpYac1fhDEarS59JWuRwTulruRZp2E8idiuxC05beXM3pctTjPwIOwIOwjgFJdesuleuRMiLAtsTkH4HfAwh)5o37PV13I3JauIN2qTqKrTAIAxOO2Bfm1sm1Qvl1kX4BCGqIAHGAxWAQLyQLyQL4kWkFeDfiZGH3pwbYmqVzjSchzaHRKJkOwW6YRlRwPRa28(r4cYkqMFzScerTlsTo)y7XJmGqDXrNhqeBE)im1Qvl1se168JThpYac1fhDEarS59JWuBsQvIX34aHe1cb1QH1ulXulXvGv(i6kqMbdVFScKzGEZsyfoYacxjhvqPH1LxxiTsxbS59JWfKvGm)YyfiIAxKAD(X2JhzaH6IJopGi28(ryQvRwQLiQ15hBpEKbeQlo68aIyZ7hHP2KuReJVXbcjQfcQDvsPwIPwIRaR8r0vGmdgE)yfiZa9MLWkCKbeUsoQGAvslVUqIkDfWM3pcxqwbY8lJvGiQDrQ15hBpEKbeQlo68aIyZ7hHPwTAPwIOwNFS94rgqOU4OZdiInVFeMAtsTsm(ghiKOwiOwnrk1sm1sCfyLpIUcKzWW7hRazgO3SewHJmGWvYrfuAI0YRlAOsxbS59JWfKvGm)YyfiIAxKAD(X2JhzaH6IJopGi28(ryQvRwQLiQ15hBpEKbeQlo68aIyZ7hHP2KuReJVXbcjQfcQnbsPwIPwIRaR8r0vGmdgE)yfiZa9MLWkCKbeUsoQGkbslVUSGkDfWM3pcxqwbY8lJvGiQDrQ15hBpkiJavodUXi28(ryQvRwQLiQ15hBpkiJavodUXi28(ryQnj1kX4BCGqIAHGA1WAQLyQL4kWkFeDfiZGH3pwbYmqVzjScA(kKSq8AyD51Lf6kDfWM3pcxqwbY8lJvGiQDrQ15hBpkiJavodUXi28(ryQvRwQLiQ15hBpkiJavodUXi28(ryQnj1kX4BCGqIAHGAjXAQLyQL4kWkFeDfiZGH3pwbYmqVzjScA(kKSq8KyD51LexxPRaR8r0vGLDHo7oRGQcyZ7hHlilVUKyIv6kWkFeDfKnO(4OKPcyZ7hHlilVUKycv6kGnVFeUGScSYhrxbf)VoR8r06)y8k8JX1BwcRGif2iO86sIAQsxbS59JWfKvqbghbdxHT85ezJcByUvyuovfyLpIUck(FDw5JO1)X4v4hJR3Sewb2OkVUK4Qv6kGnVFeUGScSYhrxbf)VoR8r06)y8k8JX1BwcRWw(CmLxxsK0kDfWM3pcxqwbw5JORGI)xNv(iA9FmEf(X46nlHvqbBkVUKijQ0vaBE)iCbzfyLpIUck(FDw5JO1)X4v4hJR3SewbLaGLxxsudv6kGnVFeUGScSYhrxbf)VoR8r06)y8k8JX1BwcRWz(hbLxEfsbqLqAZELUUKyLUcyZ7hHlilVUKqLUcyZ7hHlilVUOPkDfWM3pcxqwEDz1kDfWM3pcxqwEDH0kDfyLpIUcPe(i6kGnVFeUGS86cjQ0vGv(i6k8ZDU3tFRBYh8HRa28(r4cYYlVcN5FeuPRljwPRa28(r4cYkOaJJGHRGeJVXbcjQvJuRgwxbw5JORaqOGApockVUKqLUcyZ7hHliRGcmocgUco)y7rdYGPV1zJHLFpInVFeMA1QLA3YNt88Se6I(wgJauIN2qTAKAxnUGkWkFeDfoplHUOVLXYRlAQsxbS59JWfKvqbghbdxbIOwNFS9OcWM8PV1nUaifXM3pctTA1sTSYhYOo2O0GgQfImQnbQLyQnj1cJB5ZjImWZXw3KAGcJYPO2KuReJVXbcjQfImQD11uBsQLmdgE)yuZxHKfINeRRaR8r0vqbytU(p35Ep9D51LvR0vaBE)iCbzfuGXrWWvW5hBpMZZBCbqkInVFeMAtsTB5ZjEacJVbCdhbOepTHA1i1UACbuBsQvIX34aHe1cb1U66kWkFeDfoaHX3aUHlVUqALUcyZ7hHliRGcmocgUcsm(ghiKOwiYOwsxtTjPwYmy49JrnFfswiEnSMAtsTKzWW7hJhzaHRKJkOwW6kWkFeDfEMmR)SjV86cjQ0vGv(i6kaekO2JJGkGnVFeUGS86IgQ0vaBE)iCbzfuGXrWWvGiQvIX34aHe1crg1scsPwTAPwNFS9OcWM8PV1nUaifXM3pctTA1sTSYhYOo2O0GgQfImQnbQLyQnj1sMbdVFmQ5RqYcXtI1uBsQLmdgE)y8idiCLCub1QKwbw5JORGcWMC9FUZ9E67YRllOsxbw5JORW5zj0f9TmwbS59JWfKLxEf2YNJPsxxsSsxbS59JWfKvqbghbdxbNFS94ZnS5hymInVFeMAtsTlsTB5Zj(CdB(bgJYPO2KuRkNb3Or)ayLpIMFQfcQnXOgQaR8r0vaiuqThhbLxxsOsxbS59JWfKvqbghbdxHfPwFuqn9n1MKALy8noqirTqqTjKqfyLpIUchzaH6IJopGYRlAQsxbS59JWfKvqbghbdxHfP2T85epplHUOVLXOCQkWkFeDfoplHUOVLXYRlRwPRa28(r4cYkOaJJGHRGZp2EmNN34cGueBE)im1MKAxKA3YNt8aegFd4gokNIAtsTKzWW7hJhzaHRKJkOwL0kWkFeDfoaHX3aUHlVUqALUcyZ7hHliRGcmocgUcB5ZjEEwcDrFlJrakXtBOwnsTKGAHMAVvWvGv(i6kCEwcDrFlJLxxirLUcyZ7hHliRGcmocgUco)y7XCEEJlasrS59JWuBsQDlFoXdqy8nGB4iaL4PnuRgPwsqTqtT3k4kWkFeDfoaHX3aUHlVUOHkDfWM3pcxqwbfyCemCf2YNteGgrZTc1DHJsrakXtBOwnsTjubw5JORGlCusxInociS8YRGc2uPRljwPRa28(r4AxbfyCemCfCgCJEmh53ZJPuo1QrQnbsPwTAPwFKqQfcQDDK01RRaR8r0vy)cb8lB8YRljuPRa28(r4cYkOaJJGHRWw(CISrHnm3kmkNIA1QLAjIApiGFDtQbmEeGs80gQfcQLuQLyQvRwQ9rY4tTAKAtC96kWkFeDf2iWGaOM(U86IMQ0vaBE)iCbzfuGXrWWvylFor2OWgMBfgLtrTA1sTerTheWVUj1agpcqjEAd1cb1sk1sm1Qvl1(iz8PwnsTjUEDfyLpIUc7xiG1pYaclVUSALUcyZ7hHliRGcmocgUcB5ZjYgf2WCRWOCkQvRwQDrQ15hBpYgf2WCRWi28(ryQnj1Eqa)6Mudy8iaL4PnuleulPuRwTuRZGB0J(iH6UqhEqQvJzuljwxbw5JORqkHpIU86cPv6kWkFeDfoiGFDtQbmEfWM3pcxqwEDHev6kGnVFeUGSckW4iy4kqe1QeIhwOzD04GbkmcqjEAd1cb1UMAjMAtsTB5ZjYgf2WCRWiSqZ6kWkFeDfyJcByUvy51fnuPRaR8r0vazGNRJpkHTZFfWM3pcxqwE5vGnQkDDjXkDfyLpIUcid8CS1nPgOWkGnVFeUGS86scv6kGnVFeUGSckW4iy4kSi1ULpNOcWMC9FUZ9E67OCkQnj1YkFiJ6yJsdAOwiYO2eQaR8r0vqbytU(p35Ep9D51fnvPRa28(r4cYkOaJJGHRGZp2E85g28dmgXM3pctTjP2fP2T85eFUHn)aJr5uuBsQvLZGB0OFaSYhrZp1cb1MyudvGv(i6kaekO2JJGYRlRwPRaR8r0vqZMg24GbkScyZ7hHlilV8YRazeygrxxsyDIlynjsG0yIRjTcAgd6PVnvOcSSNlavGKu2W5eqTKSm4gRqkG4mpwHfg1ssqsHkzhHP2nEeaKAvcPn7u7gVN2eP2fIkfMYnuBlAs6CgiDKFQLv(iAd1k6NWiDjR8r0MykaQesB2ZopBGIUKv(iAtmfavcPn7qND9ieW0LSYhrBIPaOsiTzh6SRS8Te2o7JOPlxyuBO5uMCHtTaEGP2T85GWuRXz3qTB8iai1QesB2P2nEpTHA5gMAtbqs6uc3N(MAhd1clAmsxYkFeTjMcGkH0MDOZUAAoLjx46gNDdDjR8r0MykaQesB2Ho7AkHpIMUKv(iAtmfavcPn7qND9N7CVN(w3Kp4dtxsxUWOwscskuj7im1IKraHuRpsi165i1YkxaO2XqTmzEEE)yKUKv(iAtMMnnSUjhzaDjR8r0gOZUsMbdVFKGMLWSCEEJlasRKJkOiGm)Yygre58JThZ55nUaifXM3pcNCXT85epaHX3aUHJYPiwR2fD(X2J588gxaKIyZ7hHjMUKv(iAd0zxjZGH3psqZsy2rgq4k5OcQfSMaY8lJzeTOZp2E8idiuxC05beXM3pcRvlro)y7XJmGqDXrNhqeBE)iCsIisIX34aHeeAI0KkH4HfAwh)5o37PV13I3JauIN2arMMwOUvWeRvReJVXbcjiwWAIjMy6sw5JOnqNDLmdgE)ibnlHzhzaHRKJkO0WAciZVmMr0Io)y7XJmGqDXrNhqeBE)iSwTe58JThpYac1fhDEarS59JWjLy8noqibHgwtmX0LSYhrBGo7kzgm8(rcAwcZoYacxjhvqTkPeqMFzmJOfD(X2JhzaH6IJopGi28(ryTAjY5hBpEKbeQlo68aIyZ7hHtkX4BCGqcIvjLyIPlzLpI2aD2vYmy49Je0SeMDKbeUsoQGstKsaz(LXmIw05hBpEKbeQlo68aIyZ7hH1QLiNFS94rgqOU4OZdiInVFeoPeJVXbcji0ePetmDjR8r0gOZUsMbdVFKGMLWSJmGWvYrfujqkbK5xgZiArNFS94rgqOU4OZdiInVFewRwIC(X2JhzaH6IJopGi28(r4Ksm(ghiKGibsjMy6sw5JOnqNDLmdgE)ibnlHzA(kKSq8AynbK5xgZiArNFS9OGmcu5m4gJyZ7hH1QLiNFS9OGmcu5m4gJyZ7hHtkX4BCGqccnSMyIPlzLpI2aD2vYmy49Je0SeMP5RqYcXtI1eqMFzmJOfD(X2JcYiqLZGBmInVFewRwIC(X2JcYiqLZGBmInVFeoPeJVXbcjiiXAIjMUKv(iAd0zxzzxOZUZkOOlzLpI2aD2vzdQpokzOlzLpI2aD2vf)VoR8r06)yCcAwcZePWgb0LSYhrBGo7QI)xNv(iA9FmobnlHzSrrWCY2YNtKnkSH5wHr5u0LSYhrBGo7QI)xNv(iA9FmobnlHzB5ZXqxYkFeTb6SRk(FDw5JO1)X4e0SeMPGn0LSYhrBGo7QI)xNv(iA9FmobnlHzkbaPlzLpI2aD2vf)VoR8r06)yCcAwcZoZ)iGUKUKv(iAtKnQmKbEo26MuduiDjR8r0MiBuqNDvbytU(p35Ep9nbZjBXT85eva2KR)ZDU3tFhLtLKv(qg1XgLg0arwc0LSYhrBISrbD2vGqb1ECeqWCYC(X2Jp3WMFGXi28(r4KlULpN4ZnS5hymkNkPkNb3Or)ayLpIMFismQb6sw5JOnr2OGo7QMnnSXbduiDjDjR8r0M4w(CmzaHcQ94iGG5K58JThFUHn)aJrS59JWjxClFoXNByZpWyuovsvodUrJ(bWkFen)qKyud0LSYhrBIB5ZXaD21JmGqDXrNhabZjBrFuqn9DsjgFJdesqKqc0LSYhrBIB5ZXaD21ZZsOl6BzKG5KT4w(CINNLqx03YyuofDjR8r0M4w(CmqND9aegFd4gMG5K58JThZ55nUaifXM3pcNCXT85epaHX3aUHJYPssMbdVFmEKbeUsoQGAvsPlzLpI2e3YNJb6SRNNLqx03YibZjBlFoXZZsOl6BzmcqjEAJgjb03ky6sw5JOnXT85yGo76bim(gWnmbZjZ5hBpMZZBCbqkInVFeo5w(CIhGW4Ba3WrakXtB0ijG(wbtxYkFeTjULphd0zxDHJs6sSXraHemNST85ebOr0CRqDx4OueGs80gnMaDjD5cJAH8fc4x24uRIn(03u7gZzYJaqTsdaiagQ1ZrQ1msYp7ca1Aq3N(2qThbGAtbeKuesT7xiGFzJhP2aIuRiLpI2qTl89leWVSX1tHaf2(cNaQLByQDHVFHa(LnUUps4cpsT0LSYhrBIkyt2(fc4x24emNmNb3OhZr(98ykLRXeivRwFKqiwhjD9A6sw5JOnrfSb6SRBeyqautFtWCY2YNtKnkSH5wHr5uA1s0bb8RBsnGXJauIN2abPeRv7JKXxJjUEnDjR8r0MOc2aD219leW6hzaHemNST85ezJcByUvyuoLwTeDqa)6Mudy8iaL4PnqqkXA1(iz81yIRxtxYkFeTjQGnqNDnLWhrtWCY2YNtKnkSH5wHr5uA1UOZp2EKnkSH5wHrS59JWjpiGFDtQbmEeGs80giivRwNb3Oh9rc1DHo8GAmJeRPlzLpI2evWgOZUEqa)6MudyC6sw5JOnrfSb6SRSrHnm3kKG5KrKsiEyHM1rJdgOWiaL4PnqSM4KB5ZjYgf2WCRWiSqZA6sw5JOnrfSb6SRid8CD8rjSD(PlPlzLpI2evcaMHmWZXw3KAGcjyozKzWW7hJhzaHRKJkOsGu6sw5JOnrLaGqNDvbytU(p35Ep9nbZjBXT85eva2KR)ZDU3tFhLtLKv(qg1XgLg0arwc0LSYhrBIkbaHo7QcWMC9FUZ9E6BcMtgR8HmQJnknObISfOvlrSYhYOo2O0GgiYirsNFS9OcWM8PV1nUaifXM3pctmDjR8r0MOsaqOZUACbqY4GbkKG5KTLpNOXfaPny6BeeLtrxYkFeTjQeae6SRkaBY1)5o37PVjyozSYhYOo2O0GgiYwvRwIyLpKrDSrPbnqKLqsNFS9OcWM8PV1nUaifXM3pctmDjR8r0MOsaqOZU(ZDU3tFRVfVtWCYC(X2JcYiqLZGBmInVFeojzgm8(X4rgq4k5OcQvjnPeJVXbcjiYwDnDjR8r0MOsaqOZUACbqY4GbkKG5Kr0Io)y7rbzeOYzWngXM3pcNKmdgE)y8idiCLCubLMiLyTAjY5hBpkiJavodUXi28(r4KKzWW7hJhzaHRKJkOwWAIPlzLpI2evcacD2vJCdJGPVPlzLpI2evcacD21ZZsOl6BzKG5K58JThnidM(wNngw(9i28(ry6sw5JOnrLaGqND9zYS(ZMCcMt2w(CI5cxpNB4iazLtxYkFeTjQeae6SRkaBY1)5o37PVjyozSYhYOo2O0GgiY0eDjDjR8r0M4z(hbzaHcQ94iGG5KjX4BCGqsJAynDjR8r0M4z(hbqND98Se6I(wgjyozo)y7rdYGPV1zJHLFpInVFewR2T85epplHUOVLXiaL4PnAC14cOlzLpI2epZ)ia6SRkaBY1)5o37PVjyoze58JThva2Kp9TUXfaPi28(ryTAzLpKrDSrPbnqKLaXjHXT85erg45yRBsnqHr5ujLy8noqibr2QRtsMbdVFmQ5RqYcXtI10LSYhrBIN5FeaD21dqy8nGBycMtMZp2EmNN34cGueBE)iCYT85epaHX3aUHJauIN2OXvJliPeJVXbcjiwDnDjR8r0M4z(hbqND9zYS(ZMCcMtMeJVXbcjiYiDDsYmy49JrnFfswiEnSojzgm8(X4rgq4k5OcQfSMUKv(iAt8m)JaOZUcekO2JJa6sw5JOnXZ8pcGo7QcWMC9FUZ9E6BcMtgrsm(ghiKGiJeKQvRZp2Eubyt(036gxaKIyZ7hH1QLv(qg1XgLg0arwceNKmdgE)yuZxHKfINeRtsMbdVFmEKbeUsoQGAvsPlzLpI2epZ)ia6SRNNLqx03YiDjDjR8r0MOif2iidiuqThhbemNmjgFJdesAmrst6JeQXBfC5Lxf]] )

end
