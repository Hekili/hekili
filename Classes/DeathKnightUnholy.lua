-- DeathKnightUnholy.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'DEATHKNIGHT' then
    local spec = Hekili:NewSpecialization( 252 )

    spec:RegisterResource( Enum.PowerType.Runes, {
        rune_regen = {
            resource = 'runes',

            last = function ()
                return state.query_time
            end,

            interval = function( time, val )
                local r = state.runes

                if val == 6 then return -1 end

                return r.expiry[ val + 1 ] - time
            end,

            stop = function( x )
                return x == 6
            end,

            value = 1,    
        }
    }, setmetatable( {
        expiry = { 0, 0, 0, 0, 0, 0 },
        cooldown = 10,
        regen = 0,
        max = 6,
        forecast = {},
        fcount = 0,
        times = {},
        values = {},

        reset = function()
            local t = state.runes

            for i = 1, 6 do
                local start, duration, ready = GetRuneCooldown( i )
                t.expiry[ i ] = ready and 0 or start + duration
                t.cooldown = duration
            end

            table.sort( t.expiry )

            t.actual = nil
        end,

        gain = function( amount )
            local t = state.runes

            for i = 1, amount do
                t.expiry[ 7 - i ] = 0
            end
            table.sort( t.expiry )

            t.actual = nil
        end,

        spend = function( amount )
            local t = state.runes

            for i = 1, amount do
                t.expiry[ 1 ] = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
                table.sort( t.expiry )
            end

            t.actual = nil
        end,
    }, {
        __index = function( t, k, v )
            if k == 'actual' then
                local amount = 0

                for i = 1, 6 do
                    amount = amount + ( t.expiry[ i ] <= state.query_time and 1 or 0 )
                end

                return amount

            elseif k == 'current' then
                -- If this is a modeled resource, use our lookup system.
                if t.forecast and t.fcount > 0 then
                    local q = state.query_time
                    local index, slice

                    if t.values[ q ] then return t.values[ q ] end

                    for i = 1, t.fcount do
                        local v = t.forecast[ i ]
                        if v.t <= q then
                            index = i
                            slice = v
                        else
                            break
                        end
                    end

                    -- We have a slice.
                    if index and slice then
                        t.values[ q ] = max( 0, min( t.max, slice.v ) )
                        return t.values[ q ]
                    end
                end

                return t.actual

            elseif k == 'time_to_next' then
                return t[ 'time_to_' .. t.current + 1 ]

            elseif k == 'time_to_max' then
                return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.RunicPower )


    local spendHook = function( amt, resource )
        if amt > 0 and resource == "runes" then
            local r = runes
            r.actual = nil

            r.spend( amt )

            gain( amt * 10, "runic_power" )

            if set_bonus.tier20_4pc == 1 then
                cooldown.army_of_the_dead.expires = max( 0, cooldown.army_of_the_dead.expires - 1 )
            end
        
        end
    end

    spec:RegisterHook( "spend", spendHook )

    
    local gainHook = function( amt, resource )
        if resource == 'runes' then
            local r = runes
            r.actual = nil

            r.gain( amt )
        end
    end

    spec:RegisterHook( "gain", gainHook )

    
    -- Talents
    spec:RegisterTalents( {
        infected_claws = 22024, -- 207272
        all_will_serve = 22025, -- 194916
        clawing_shadows = 22026, -- 207311

        bursting_sores = 22027, -- 207264
        ebon_fever = 22028, -- 207269
        unholy_blight = 22029, -- 115989

        grip_of_the_dead = 22516, -- 273952
        deaths_reach = 22518, -- 276079
        asphyxiate = 22520, -- 108194

        pestilent_pustules = 22522, -- 194917
        harbinger_of_doom = 22524, -- 276023
        soul_reaper = 22526, -- 130736

        spell_eater = 22528, -- 207321
        wraith_walk = 22529, -- 212552
        death_pact = 23373, -- 48743

        pestilence = 22532, -- 277234
        defile = 22534, -- 152280
        epidemic = 22536, -- 207317

        army_of_the_damned = 22030, -- 276837
        unholy_frenzy = 22110, -- 207289
        summon_gargoyle = 22538, -- 49206
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3537, -- 214027
        relentless = 3536, -- 196029
        gladiators_medallion = 3535, -- 208683

        ghoulish_monstrosity = 3733, -- 280428
        necrotic_aura = 3437, -- 199642
        cadaverous_pallor = 163, -- 201995
        reanimation = 152, -- 210128
        heartstop_aura = 44, -- 199719
        decomposing_aura = 3440, -- 199720
        necrotic_strike = 149, -- 223829
        unholy_mutation = 151, -- 201934
        wandering_plague = 38, -- 199725
        antimagic_zone = 42, -- 51052
        dark_simulacrum = 41, -- 77606
        crypt_fever = 40, -- 199722
        pandemic = 39, -- 199724
    } )

    -- Auras
    spec:RegisterAuras( {
        antimagic_shell = {
            id = 48707,
            duration = function () return 5 + ( talent.spell_eater.enabled and 5 or 0 ) + ( ( level < 116 and equipped.acherus_drapes ) and 5 or 0 ) end,
            max_stack = 1,
        },
        army_of_the_dead = {
            id = 42650,
            duration = 4,
            max_stack = 1,
        },
        asphyxiate = {
            id = 108194,
            duration = 4,
            max_stack = 1,
        },
        dark_succor = {
            id = 178819,
        },
        dark_transformation = {
            id = 63560, 
            duration = 20,
            generate = function ()
                local cast = class.abilities.dark_transformation.lastCast or 0
                local up = ( pet.ghoul.up or pet.abomination.up ) and cast + 20 > state.query_time

                local dt = buff.dark_transformation
                dt.name = class.abilities.dark_transformation.name
                dt.count = up and 1 or 0
                dt.expires = up and cast + 20 or 0
                dt.applied = up and cast or 0
                dt.caster = "player"
            end,
        },
        death_and_decay_debuff = {
            id = 43265,
            duration = 10,
            max_stack = 1,
        },
        death_and_decay = {
            id = 188290,
            duration = 10
        },
        death_pact = {
            id = 48743,
            duration = 15,
            max_stack = 1,
        },
        deaths_advance = {
            id = 48265,
            duration = 8,
            max_stack = 1,
        },
        defile = {
            id = 156004,
            duration = 10,
        },
        festering_wound = {
            id = 194310,
            duration = 30,
            max_stack = 6,
        },
        grip_of_the_dead = {
            id = 273977,
            duration = 3600,
            max_stack = 1,
        },
        icebound_fortitude = {
            id = 48792,
            duration = 8,
            max_stack = 1,
        },
        on_a_pale_horse = {
            id = 51986,
        },
        outbreak = {
            id = 196782,
            duration = 6,
            type = "Disease",
            max_stack = 1,
            tick_time = 1,
        },
        path_of_frost = {
            id = 3714,
            duration = 600,
            max_stack = 1,
        },
        runic_corruption = {
            id = 51460,
            duration = 3,
            max_stack = 1,
        },
        sign_of_the_skirmisher = {
            id = 186401,
            duration = 3600,
            max_stack = 1,
        },
        soul_reaper = {
            id = 130736,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        sudden_doom = {
            id = 81340,
            duration = 10,
            max_stack = 2,
        },
        unholy_blight = {
            id = 115989,
            duration = 6,
            max_stack = 1,
        },
        unholy_blight_dot = {
            id = 115994,
            duration = 14,
            tick_time = 2,
        },
        unholy_frenzy = {
            id = 207289,
            duration = 12,
            max_stack = 1,
        },
        unholy_strength = {
            id = 53365,
            duration = 15,
            max_stack = 1,
        },
        virulent_plague = {
            id = 191587,
            duration = 21,
            tick_time = function () return 3 * haste end,
            type = "Disease",
            max_stack = 1,
        },
        wraith_walk = {
            id = 212552,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
    } )


    spec:RegisterStateTable( 'death_and_decay', 
        setmetatable( { onReset = function( self ) end },
        { __index = function( t, k )
            if k == 'ticking' then
                return buff.death_and_decay.up
            
            elseif k == 'remains' then
                return buff.death_and_decay.remains
            
            end

            return false
        end } ) )

    spec:RegisterStateTable( 'defile', 
        setmetatable( { onReset = function( self ) end },
        { __index = function( t, k )
            if k == 'ticking' then
                return buff.death_and_decay.up

            elseif k == 'remains' then
                return buff.death_and_decay.remains
            
            end

            return false
        end } ) )

    spec:RegisterStateExpr( "dnd_ticking", function ()
        return death_and_decay.ticking
    end )

    spec:RegisterStateExpr( "dnd_remains", function ()
        return death_and_decay.remains
    end )

    spec:RegisterStateExpr( "rune", function ()
        return runes.current
    end )


    -- Abilities
    spec:RegisterAbilities( {
        antimagic_shell = {
            id = 48707,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            startsCombat = false,
            texture = 136120,
            
            handler = function ()
                applyBuff( "antimagic_shell" )
            end,
        },
        

        apocalypse = {
            id = 275699,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1392565,
            
            handler = function ()
                if debuff.festering_wound.stack > 4 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.remains - 4 )
                    gain( 12, "runic_power" )
                else                    
                    gain( 3 * debuff.festering_wound.stack, "runic_power" )
                    removeDebuff( "target", "festering_wound" )
                end
                -- summon pets?                
            end,
        },
        

        army_of_the_dead = {
            id = 42650,
            cast = 0,
            cooldown = 480,
            gcd = "spell",
            
            spend = 3,
            spendType = "runes",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 237511,
            
            handler = function ()
                applyBuff( "army_of_the_dead", 4 )
            end,
        },
        

        asphyxiate = {
            id = 108194,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 538558,

            talent = "asphyxiate",
            
            handler = function ()
                applyDebuff( "target", "asphyxiate" )
            end,
        },
        

        chains_of_ice = {
            id = 45524,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = true,
            texture = 135834,
            
            recheck = function ()
                return buff.unholy_strength.remains - gcd, buff.unholy_strength.remains
            end,
            handler = function ()
                applyDebuff( "target", "chains_of_ice" )
                removeBuff( "cold_heart_item" )
            end,
        },
        

        clawing_shadows = {
            id = 207311,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = true,
            texture = 615099,

            talent = "clawing_shadows",
            
            handler = function ()
                if debuff.festering_wound.stack > 1 then applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                else removeDebuff( "target", "festering_wound" ) end
                gain( 3, "runic_power" )
            end,
        },
        

        control_undead = {
            id = 111673,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = true,
            texture = 237273,
            
            usable = function () return target.is_undead and target.level <= level + 1 end,
            handler = function ()
                summonPet( "controlled_undead", 300 )
            end,
        },
        

        dark_command = {
            id = 56222,
            cast = 0,
            cooldown = 8,
            gcd = "off",
            
            startsCombat = true,
            texture = 136088,
            
            handler = function ()
                applyDebuff( "target", "dark_command" )
            end,
        },
        

        dark_transformation = {
            id = 63560,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = false,
            texture = 342913,
            
            usable = function () return pet.alive end,
            handler = function ()
                applyBuff( "dark_transformation" )
            end,
        },
        

        death_and_decay = {
            id = 43265,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = true,
            texture = 136144,

            notalent = "defile",
            
            handler = function ()
                applyBuff( "death_and_decay", 10 )
                if talent.grip_of_the_dead.enabled then applyDebuff( "target", "grip_of_the_dead" ) end
            end,
        },
        

        death_coil = {
            id = 47541,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return buff.sudden_doom.up and 0 or 40 end,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 136145,
            
            handler = function ()
                removeStack( "sudden_doom" )
                if cooldown.dark_transformation.remains > 0 then setCooldown( 'dark_transformation', cooldown.dark_transformation.remains - 1 ) end
            end,
        },
        

        --[[ death_gate = {
            id = 50977,
            cast = 4,
            cooldown = 60,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = false,
            texture = 135766,
            
            handler = function ()
            end,
        }, ]]
        

        death_grip = {
            id = 49576,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            startsCombat = true,
            texture = 237532,
            
            handler = function ()
                applyDebuff( "target", "death_grip" )
                setDistance( 5 )
            end,
        },
        

        death_pact = {
            id = 48743,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136146,

            talent = "death_pact",
            
            handler = function ()
                gain( health.max * 0.5, "health" )
                applyBuff( "death_pact" )
            end,
        },
        

        death_strike = {
            id = 49998,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return buff.dark_succor.up and 0 or 45 end,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 237517,
            
            handler = function ()
                removeBuff( "dark_succor" )
                if level < 116 and equipped.death_march then
                    local cd = cooldown[ talent.defile.enabled and "defile" or "death_and_decay" ]
                    cd.expires = max( 0, cd.expires - 2 )
                end
            end,
        },
        

        deaths_advance = {
            id = 48265,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = false,
            texture = 237561,
            
            handler = function ()
                applyBuff( "deaths_advance" )
            end,
        },
        

        defile = {
            id = 152280,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            talent = "defile",

            startsCombat = true,
            texture = 1029008,
            
            handler = function ()
                applyBuff( "death_and_decay" )
                applyDebuff( "target", "defile", 1 )
            end,
        },
        

        epidemic = {
            id = 207317,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 136066,

            talent = "epidemic",

            usable = function () return active_dot.virulent_plague > 0 end,
            handler = function ()
            end,
        },
        

        festering_strike = {
            id = 85948,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 2,
            spendType = "runes",
            
            startsCombat = true,
            texture = 879926,
            
            handler = function ()
                applyDebuff( "target", "festering_wound", 24, debuff.festering_wound.stack + 2 )
            end,
        },
        

        icebound_fortitude = {
            id = 48792,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = false,
            texture = 237525,
            
            handler = function ()
                applyBuff( "icebound_fortitude" )
            end,
        },
        

        mind_freeze = {
            id = 47528,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 237527,

            toggle = "interrupts",
            
            usable = function () return target.casting end,
            handler = function ()
                interrupt()
            end,
        },
        

        outbreak = {
            id = 77575,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = -10,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 348565,

            handler = function ()
                applyDebuff( "target", "outbreak" )
                applyDebuff( "target", "virulent_plague", talent.ebon_fever.enabled and 10.5 or 21 )
            end,
        },
        

        path_of_frost = {
            id = 3714,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = false,
            texture = 237528,
            
            handler = function ()
                applyBuff( "path_of_frost" )
            end,
        },
        

        --[[ raise_ally = {
            id = 61999,
            cast = 0,
            cooldown = 600,
            gcd = "spell",
            
            spend = 30,
            spendType = "runic_power",
            
            startsCombat = false,
            texture = 136143,
            
            handler = function ()
            end,
        }, ]]
        

        raise_dead = {
            id = 46584,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1100170,
            
            usable = function () return not pet.exists end,
            handler = function ()
                summonPet( "ghoul", 3600 )
                if talent.all_will_serve.enabled then summonPet( "skeleton", 3600 ) end
            end,
        },
        

        --[[ runeforging = {
            id = 53428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 237523,
            
            usable = false,
            handler = function ()
            end,
        }, ]]
        

        scourge_strike = {
            id = 55090,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = true,
            texture = 237530,
            
            notalent = "clawing_shadows",

            usable = function () return debuff.festering_wound.up end,
            handler = function ()
                gain( 3, "runic_power" )
                if debuff.festering_wound.stack > 1 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                else removeDebuff( "target", "festering_wound" ) end
            end,
        },
        

        soul_reaper = {
            id = 130736,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 636333,

            talent = "soul_reaper",
            
            handler = function ()
                applyDebuff( "target", "soul_reaper" )
            end,
        },
        

        summon_gargoyle = {
            id = 49206,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 458967,
            
            talent = "summon_gargoyle",

            handler = function ()
                summonPet( "gargoyle", 30 )
            end,
        },
        

        unholy_blight = {
            id = 115989,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = true,
            texture = 136132,

            talent = "unholy_blight",
            
            handler = function ()
                applyBuff( "unholy_blight" )
                applyDebuff( "unholy_blight_dot" )
            end,
        },
        

        unholy_frenzy = {
            id = 207289,
            cast = 0,
            cooldown = 75,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136224,

            talent = "unholy_frenzy",
            
            handler = function ()
                applyBuff( "unholy_frenzy" )
                stat.haste = state.haste + 0.20
            end,
        },
        

        wraith_walk = {
            id = 212552,
            cast = 0,
            channeled = 4,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1100041,

            talent = "wraith_walk",
            
            handler = function ()
                applyBuff( "wraith_walk" )
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
    
        package = "Unholy",
    } )

    spec:RegisterPack( "Unholy", 20180717.1350, [[dyeEPaqiLuEKsQQnPenkLGtrvQxHk1SOkClLuP2ff)cvyyaHJrvYYuQ4zarMgQixtPsBdiQVPeQXPeIZPKkzDkPcmpQIUhG2hQIdIkkzHOsEiQOOjQKkYfrfLAKkHuCsLurTsa8sLuHUPsiv2jqAOkPcAPkHu1tvXuvQ6QOIcBvjKs7vv)vWGf6WKwmL6XinzcxgAZQ0Nry0a1PL61a0Sr52uYUv8BrdNQ64kPklh0ZPY0LCDeTDuL(oQQXResoVsz9OIQ5RKSFI(963)hHw4d6oGWRfbel2RfB8cK21lV25p1Mp(hFLcOsG)zul8pCgd4KT9hFDJLQ43)hxscP4FaxLVBDahCq0fysBdnT4W1wKmT6COq9wC4Alkh2S0Md7RUUfiVC4dZBZqhh7BeUJxCSFhVcRtOwGdRJttaUcCgd4KTzCTf9p2KnRwNN3(pcTWh0DaHxlciwSxl24fiXPfzxq(poFK(GUZU78hb6O)zp42jJTtglWOmkWRsYkzuPvNJm6RuaLXBcLroJbCY2KX1P1rzShzKRlNL5pS2vUF)FOjteaJkS(9pOE97)doQndfpx)Hc7cHT(hBY71qoGt2wWvqCikWgiAP94KrpLrcQqgxkJ2K3RHCaNSTGRG4quGnquPLmUugTjVxdnzIayuHvOl0Y4kLcOmYJm6fi)hLwDo)Hcw7XfYBOP4xpO787)doQndfpx)Hc7cHT(hBY71qtMiagvyf6cTmUsPakJaLXDaHmUugTjVxd5aozBbxbXHOaBGOsR)O0QZ5puWApUqEdnf)6R)iWRsYQF)dQx)()O0QZ5pkzLbTkLc4FWrTzO456Rh0D(9)rPvNZFS6reUqe5C8p4O2mu8C91dki97)doQndfpx)HxLrI)zbzKMjtK8hJJ0YkNaHcjYngAGOL2Jtg9ug3vgxkJliJ0mzIK)yekeWqb1XDtOLwDogiAP94KrpLXDLXvRKX1KrC9iBFFuykfWcmc7c2lkxWbojzce6RcNm6Tm6TmUuglLHtzCKww5eiuirUXqdoQndf)rPvNZF4vHTAZW)WRcdJAH)XptwpeHBcdekKi3y4xpOC63)hCuBgkEU(df2fcB9pqYPPb)Kpcnc820UKrEKrqExzCPmUGm6JLHqHe5gdnkTAErzC1kzCnzSugoLXrAzLtGqHe5gdn4O2muiJElJlLri5GgbEBAxYipaLXD)JsRoN)OqQoyOsieN6Rh0D)9)bh1MHINR)qHDHWw)JpwgcfsKBm0O0Q5fLXvRKX1KXsz4ughPLvobcfsKBm0GJAZqXFuA158hBwMIWLeU91dki)7)doQndfpx)Hc7cHT(hFSmekKi3yOrPvZlkJRwjJRjJLYWPmoslRCcekKi3yObh1MHI)O0QZ5p2i0Hqa7H4Rh0f)7)JsRoN)q6WqxOL7p4O2mu8C91d6I87)doQndfpx)rPvNZFUilBgkc9Cr4OSGLsb3d(hkSle26F8XYqOqICJHgLwnVOmUALmUMmwkdNY4iTSYjqOqICJHgCuBgk(ZOw4FUilBgkc9Cr4OSGLsb3d(1d6663)hCuBgkEU(JsRoN)a7HiK3anzm131dr4swKq09hkSle26FwqgTjVxtHw(LwDogxPuaLrGYiiKXLYyPqcSmvBHHkdIgLrEKrqgeYO3Y4QvYyPqcSmvBHHkdIgLrpLrqge)zul8pWEic5nqtgt9D9qeUKfjeDF9G6fi(9)bh1MHINR)qHDHWw)dntMi5pgfATfYBOaJbbQcdevXMmUALm6JLHqHe5gdnkTAErzC1kz0M8EnKd4KTfUqC48ndP)FuA158h)S6C(6b1lV(9)bh1MHINR)qHDHWw)ZcISm82qsgovWNPeKOPAkGHQTWaeT0ECCxnfWq1wONafzz4THKmCQGptjirdeT0ECEVuKLH3gsYWPc(mLGenq0s7X5jqcQ4pkT6C(tsw2qub8RhuV253)hCuBgkEU(JsRoN)qvglO0QZjWAx9hw7QWOw4FOzYej)X91dQxG0V)p4O2mu8C9hkSle26FuA18IbCqRgDYipaLXD(JsRoN)qvglO0QZjWAx9hw7QWOw4F0e)6b1lo97)doQndfpx)rPvNZFOkJfuA15eyTR(dRDvyul8pe4GWM(1x)XhI00YwRF)dQx)()GJAZqXZ1xpO787)doQndfpxF9Gcs)()GJAZqXZ1xpOC63)hCuBgkEU(6bD3F)FuA158h)S6C(doQndfpxF9GcY)()O0QZ5pqTDyqGQ4p4O2mu8C91d6I)9)rPvNZFuO1wiVHcmgeOk(doQndfpxF91F0e)9pOE97)doQndfpx)Hc7cHT(hAMmrYFmQFsv2MVdnq0s7XjJ8iJG4pkT6C(Ja1cCqhrqGuD7Rh0D(9)rPvNZFe4Tz4FWrTzO456Rhuq63)hCuBgkEU(df2fcB9pculWbDebbs1nt1ua7HqgxkJqYbLrpLXDKXLY4AYiVkSvBgA8ZK1dr4MWaHcjYng(hLwDo)b9BbA10VEq50V)p4O2mu8C9hkSle26FeOwGd6iccKQBMQPa2dHmUugHKdkJEkJ7iJlLX1KXsz4ug0VfOvtn4O2muiJlLX1KrEvyR2m04NjRhIWnHbcfsKBm8pkT6C(Ja1cCGMn7Rh0D)9)bh1MHINR)qHDHWw)Ja1cCqhrqGuDZunfWEiKXLYintMi5pg1pPkBZ3HgiAP94KrEKrq8hLwDo)XrtsibgCfSbe)6bfK)9)bh1MHINR)qHDHWw)Ja1cCqhrqGuDZunfWEiKXLYintMi5pg1pPkBZ3HgiAP94KrEKrq8hLwDo)HYu(9qeCGvrY391d6I)9)bh1MHINR)qHDHWw)ZAYiVkSvBgA8ZK1dr4MWaHcjYng(hLwDo)b9BbA10VEqxKF)FWrTzO456puyxiS1)ukdNYytcDvpebxcrNbh1MHczCPm68rglukKalNXMe6QEicUeIozKhGY4oY4szuG2K3R5IUcH9qe4NKJW4kLcOm6jqz0R)O0QZ5px0viShIGRGnG4xpORRF)FWrTzO456puyxiS1)ytEVghPqGtqKPLbIkTKXLYiKCqJaVnTlzKhGYiN(JsRoN)iqTahOzZ(6R)qZKjs(J73)G61V)p4O2mu8C9hkSle26FW1JS99rHHMmramQWsgxkJ2K3RHMmramQWk0fAzCLsbug5rg9ce)rPvNZFOkJfuA15eyTR(dRDvyul8p0KjcGrfwF9GUZV)pkT6C(JcT2c5nuGXGavXFWrTzO456Rhuq63)hCuBgkEU(df2fcB9pc0M8Enx0viShIa)KCegxPuaLrEakJC6pkT6C(J6NuLT57WVEq50V)p4O2mu8C9hkSle26FwqgX1JS99rHPualWiSlyVOCbh4KKjqOVkCY4szKMjtK8hJJ0YkNaHcjYngAGOL2Jtg5rg5eiKrVLXvRKXfKX1KrC9iBFFuykfWcmc7c2lkxWbojzce6RcNmUALmUMmwkdNY4iTSYjqOqICJHgCuBgkKrV)JsRoN)iuiGHcQJ7MqlT6C(6bD3F)FWrTzO456puyxiS1)ajNMg8t(i0iWBt7sg9ug9It)rPvNZFCKww5eiuirUXWVEqb5F)FWrTzO456puyxiS1)iqBY71CrxHWEic8tYryCLsbug9ug50FuA158hYbCY2cxioC(2xpOl(3)hCuBgkEU(df2fcB9pkTAEXaoOvJozKhGY4oY4szCbzCbzKMjtK8hJa1cCqhrqGuDZarlThNm6jqzKGkKXLY4AYyPmCkJaVndn4O2muiJElJRwjJliJ0mzIK)ye4TzObIwApoz0tGYibviJlLXsz4ugbEBgAWrTzOqg9wg9(pkT6C(d5aozBHlehoF7Rh0f53)hCuBgkEU(df2fcB9plukKalt1wyOYGOrpxKvRGKd6jWD8E5A2K3RHCaNSTWfIdNVzi9)JsRoN)4sswaIQpc)6bDD97)JsRoN)qoGt2wWM1eGR)GJAZqXZ1xF9hcCqyt)9pOE97)doQndfpx)Hc7cHT(hBY714ifcCcImTmquPLmUugxtg5vHTAZqJFMSEic3egiuirUXqzC1kz0hldHcjYngAuA18I)rPvNZFeOwGd0SzF9GUZV)p4O2mu8C9hkSle26FGKttd(jFeAe4TPDjJEkJEXjzCPmUGmsZKjs(Jr9tQY28DObIwApozKhzCxzC1kzuG2K3R5IUcH9qe4NKJW4kLcOmYJmYjz0BzCPmUMmYRcB1MHg)mz9qeUjmqOqICJH)rPvNZFeOwGd0SzF9Gcs)()GJAZqXZ1FOWUqyR)PugoLXhDvZWHIgCuBgkKXLYintMi5pg1pPkBZ3HgiAP94KrEKrq8hLwDo)rGAboOJiiqQU91dkN(9)bh1MHINR)qHDHWw)dntMi5pg1pPkBZ3HgiAP94KrEKrq8hLwDo)rG3MHF9GU7V)p4O2mu8C9hkSle26FwqgxqgfOn59AUORqypeb(j5imK(Y4szKMjtK8hJ6NuLT57qdeT0ECYipY4UYO3Y4QvYOaTjVxZfDfc7HiWpjhHXvkfqzKhzKtYO3Y4szKMjtK8hJcT2c5nuGXGavHbIwApozKhzC3)O0QZ5poAscjWGRGnG4xpOG8V)p4O2mu8C9hkSle26FwqgxqgfOn59AUORqypeb(j5imK(Y4szKMjtK8hJ6NuLT57qdeT0ECYipY4UYO3Y4QvYOaTjVxZfDfc7HiWpjhHXvkfqzKhzKtYO3Y4szKMjtK8hJcT2c5nuGXGavHbIwApozKhzC3)O0QZ5puMYVhIGdSks(UVEqx8V)p4O2mu8C9hkSle26FGKttd(jFeAe4TPDjJEkJ7aczCPmUMmYRcB1MHg)mz9qeUjmqOqICJH)rPvNZFeOwGd0SzF9GUi)()GJAZqXZ1FOWUqyR)zbzCbzCbzCbzuG2K3R5IUcH9qe4NKJW4kLcOm6PmYjzCPmUMmAtEVgYbCY2cxioC(MH0xg9wgxTsgfOn59AUORqypeb(j5imUsPakJEkJGKm6TmUugPzYej)XO(jvzB(o0arlThNm6PmcsYO3Y4QvYOaTjVxZfDfc7HiWpjhHXvkfqz0tz0lz0BzCPmsZKjs(JrHwBH8gkWyqGQWarlThNmYJmU7FuA158Nl6ke2drWvWgq8Rh011V)p4O2mu8C9hkSle26Fwtg5vHTAZqJFMSEic3egiuirUXW)O0QZ5pculWbA2SV(6R)WlcDDopO7acVweqSyqSyJxETZF4RWPhc3F(JpmVnd)Z6lJC2lkKswOqgTXBcrzKMw2AjJ2irpoJmYzrPOF5KXjN1nyfADjzYOsRohNmMdBZibqPvNJZ4drAAzRfWltDakbqPvNJZ4drAAzRf3a54MPqcGsRohNXhI00YwlUbYHssyHtPvNJeG1xgpJ67aNLmc1wiJ2K3lkKrxPLtgTXBcrzKMw2AjJ2irpozuhHm6dX1TFwvpeYy7KrroOrcGsRohNXhI00YwlUbYHBuFh4ScUslNeaLwDooJpePPLTwCdKd)S6CKaO0QZXz8HinTS1IBGCa12HbbQcjakT6CCgFistlBT4gihk0AlK3qbgdcufsaKaS(YiN9IcPKfkKrKxeUjJvBHYybgLrLwjugBNmQ8QntTzOrcGsRohhqLSYGwLsbucGsRohh3a5WQhr4crKZrjakT6CCCdKdEvyR2m0JrTqG(zY6HiCtyGqHe5gd9GxLrIaxGMjtK8hJJ0YkNaHcjYngAGOL2JZZDxUantMi5pgHcbmuqDC3eAPvNJbIwApop3D1Q1W1JS99rHXlqAXGyX76T3llLHtzCKww5eiuirUXqdoQndfsawFzCrVsBL58qgxNl0Y5HmQJqgZcmcLXKGkCsauA1544gihkKQdgQecXP8OVaHKttd(jFeAe4TPDXdiV7Yf8XYqOqICJHgLwnV4QvRvkdNY4iTSYjqOqICJHgCuBgk8EjKCqJaVnTlEaUReaLwDooUbYHnltr4sc38OVa9XYqOqICJHgLwnV4QvRvkdNY4iTSYjqOqICJHgCuBgkKaO0QZXXnqoSrOdHa2dHh9fOpwgcfsKBm0O0Q5fxTATsz4ughPLvobcfsKBm0GJAZqHeaLwDooUbYbPddDHwojakT6CCCdKdshg6cT8yule4fzzZqrONlchLfSuk4Eqp6lqFSmekKi3yOrPvZlUA1ALYWPmoslRCcekKi3yObh1MHcjakT6CCCdKdshg6cT8yuleiShIqEd0KXuFxpeHlzrcrNh9f4c2K3RPql)sRohJRukGabXYsHeyzQ2cdvgenYdidcVxTQuibwMQTWqLbrJEcYGqcGsRohh3a5WpRohp6lqAMmrYFmk0AlK3qbgdcufgiQITvR8XYqOqICJHgLwnV4Qv2K3RHCaNSTWfIdNVzi9LaS(Y4IoTNs7rgx02qsgoLmUoKPeKOeaLwDooUbYrsw2qub0JsHeyf6lWfezz4THKmCQGptjirt1uadvBHbiAP944UAkGHQTqpbkYYWBdjz4ubFMsqIgiAP948EPildVnKKHtf8zkbjAGOL2JZtGeuHeaLwDooUbYbvzSGsRoNaRDLhJAHaPzYej)XjbqPvNJJBGCqvglO0QZjWAx5XOwiqnrp6lqLwnVyah0Qrhpa3rcGsRohh3a5GQmwqPvNtG1UYJrTqGe4GWMkbqcW6lJCwjNTmcZsRohjakT6CCgnrGculWbDebbs1np6lqAMmrYFmQFsv2MVdnq0s7XjbqPvNJZOjYnqoe4TzOeaLwDooJMi3a5a9BbA1up6lqbQf4GoIGaP6MPAkG9qSesoON7SCnEvyR2m04NjRhIWnHbcfsKBmucGsRohNrtKBGCiqTahOzZ8OVafOwGd6iccKQBMQPa2dXsi5GEUZY1kLHtzq)wGwn1GJAZqXY14vHTAZqJFMSEic3egiuirUXqjakT6CCgnrUbYHJMKqcm4kydi6rFbkqTah0reeiv3mvtbShIL0mzIK)yu)KQSnFhAGOL2JtcGsRohNrtKBGCqzk)EicoWQi578OVafOwGd6iccKQBMQPa2dXsAMmrYFmQFsv2MVdnq0s7XjbqPvNJZOjYnqoq)wGwn1J(cCnEvyR2m04NjRhIWnHbcfsKBmucGsRohNrtKBGCCrxHWEicUc2aIE0xGLYWPm2Kqx1drWLq0zWrTzOyPZhzSqPqcSCgBsOR6Hi4si64b4olfOn59AUORqypeb(j5imUsPa6jqVKaO0QZXz0e5gihculWbA2mp6lqBY714ifcCcImTmquP1si5GgbEBAx8aKtsaKaS(YiNzYeY4IguHLmYqcCekCtcGsRohNHMmramQWcifS2JlK3qtrp6lqBY71qoGt2wWvqCikWgiAP948KGkwAtEVgYbCY2cUcIdrb2arLwlTjVxdnzIayuHvOl0Y4kLcipEbYsauA154m0KjcGrfwCdKdkyThxiVHMIE0xG2K3RHMmramQWk0fAzCLsbe4oGyPn59AihWjBl4kioefydevAjbqcW6lJCMjtiJGrfwYOoczmlWiugZzDtqfYintMi5pojakT6CCgAMmrYFCaPkJfuA15eyTR8yuleinzIayuHLh9fiUEKTVpkm0KjcGrfwlTjVxdnzIayuHvOl0Y4kLcipEbcjakT6CCgAMmrYFCCdKdfATfYBOaJbbQcjakT6CCgAMmrYFCCdKd1pPkBZ3HE0xGc0M8Enx0viShIa)KCegxPua5biNKaO0QZXzOzYej)XXnqoekeWqb1XDtOLwDoE0xGlGRhz77JcJxG0IbXI3DjntMi5pghPLvobcfsKBm0arlThhpCceEVA1cRHRhz77JcJxG0IbXI3D1Q1kLHtzCKww5eiuirUXqdoQndfElbqPvNJZqZKjs(JJBGC4iTSYjqOqICJHE0xGqYPPb)Kpcnc820U80lojbqPvNJZqZKjs(JJBGCqoGt2w4cXHZ38OVafOn59AUORqypeb(j5imUsPa6jNKaO0QZXzOzYej)XXnqoihWjBlCH4W5BE0xGkTAEXaoOvJoEaUZYfwGMjtK8hJa1cCqhrqGuDZarlThNNajOILRvkdNYiWBZqdoQndfEVA1c0mzIK)ye4TzObIwApopbsqfllLHtze4TzObh1MHcV9wcGsRohNHMjtK8hh3a5WLKSaevFe6rPqcSc9f4cLcjWYuTfgQmiA0Zfz1ki5GEcChVxUMn59AihWjBlCH4W5BgsFjakT6CCgAMmrYFCCdKdYbCY2c2SMaCjbqcGsRohNHahe2uGculWbA2mp6lqBY714ifcCcImTmquP1Y14vHTAZqJFMSEic3egiuirUXWvR8XYqOqICJHgLwnVOeaLwDoodboiSPCdKdbQf4anBMh9fiKCAAWp5JqJaVnTlp9ItlxGMjtK8hJ6NuLT57qdeT0EC8S7Qvc0M8Enx0viShIa)KCegxPua5HtEVCnEvyR2m04NjRhIWnHbcfsKBmucGsRohNHahe2uUbYHa1cCqhrqGuDZJ(cSugoLXhDvZWHIgCuBgkwsZKjs(Jr9tQY28DObIwApojakT6CCgcCqyt5gihc82m0J(cKMjtK8hJ6NuLT57qdeT0ECsauA154me4GWMYnqoC0KesGbxbBarp6lWfwqG2K3R5IUcH9qe4NKJWq6VKMjtK8hJ6NuLT57qdeT0EC8SR3RwjqBY71CrxHWEic8tYryCLsbKho59sAMmrYFmk0AlK3qbgdcufgiAP944zxjakT6CCgcCqyt5gihuMYVhIGdSks(op6lWfwqG2K3R5IUcH9qe4NKJWq6VKMjtK8hJ6NuLT57qdeT0EC8SR3RwjqBY71CrxHWEic8tYryCLsbKho59sAMmrYFmk0AlK3qbgdcufgiAP944zxjakT6CCgcCqyt5gihculWbA2mp6lqi500GFYhHgbEBAxEUdiwUgVkSvBgA8ZK1dr4MWaHcjYngkbqPvNJZqGdcBk3a54IUcH9qeCfSbe9OVaxyHfwqG2K3R5IUcH9qe4NKJW4kLcONCA5A2K3RHCaNSTWfIdNVzi99E1kbAtEVMl6ke2drGFsocJRukGEcsEVKMjtK8hJ6NuLT57qdeT0ECEcsEVALaTjVxZfDfc7HiWpjhHXvkfqp9Y7L0mzIK)yuO1wiVHcmgeOkmq0s7XXZUsauA154me4GWMYnqoeOwGd0SzE0xGRXRcB1MHg)mz9qeUjmqOqICJH)rjlWj8pN2IKPvNdNjuV1xF9p]] )

end
