-- DeathKnightUnholy.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'DEATHKNIGHT' then
    local spec = Hekili:NewSpecialization( 252 )

    spec:RegisterResource( Enum.PowerType.RunicPower )
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

            fire = function( time, val )
                local r = state.runes 
                local v = r.actual

                if v == 6 then return end

                r.expiry[ v + 1 ] = 0
                table.sort( r.expiry )
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
                    amount = amount + ( t.expiry[i] <= state.query_time and 1 or 0 )
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

                if amount then
                    if amount > 6 then return 3600
                    elseif amount <= t.current then return 0 end

                    if t.forecast and t.fcount > 0 then
                        local q = state.query_time
                        local index, slice

                        if t.times[ amount ] then return max( 0, t.times[ amount ] - q ) end

                        if t.regen == 0 then
                            for i = 1, t.fcount do
                                local v = t.forecast[ i ]
                                if v.v >= amount then
                                    t.times[ amount ] = v.t
                                    return max( 0, t.times[ amount ] - q )
                                end
                            end
                            t.times[ amount ] = q + 3600
                            return max( 0, t.times[ amount ] - q )
                        end

                        for i = 1, t.fcount do
                            local slice = t.forecast[ i ]
                            local after = t.forecast[ i + 1 ]
                            
                            if slice.v >= amount then
                                t.times[ amount ] = slice.t
                                return max( 0, t.times[ amount ] - q )

                            elseif after and after.v >= amount then
                                -- Our next slice will have enough resources.  Check to see if we'd regen enough in-between.
                                local time_diff = after.t - slice.t
                                local deficit = amount - slice.v
                                local regen_time = deficit / t.regen

                                if regen_time < time_diff then
                                    t.times[ amount ] = ( slice.t + regen_time )
                                else
                                    t.times[ amount ] = after.t
                                end                        
                                return max( 0, t.times[ amount ] - q )
                            end
                        end
                        t.times[ amount ] = q + 3600
                        return max( 0, t.times[ amount ] - q )
                    end

                    return max( 0, t.expiry[ amount ] - state.query_time )
                end
            end
        end
    } ) )

    local spendHook = function( amt, resource )
        if amt > 0 and resource == "runes" then
            local r = state.runes
            r.actual = nil

            r.spend( amt )

            state.gain( amt * 10, "runic_power" )

            if state.set_bonus.tier20_4pc == 1 then
                state.cooldown.army_of_the_dead.expires = max( 0, state.cooldown.army_of_the_dead.expires - 1 )
            end
        
        end
    end

    spec:RegisterHook( "spend", spendHook )

    
    local gainHook = function( amt, resource )
        if resource == 'runes' then
            local r = state.runes
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
            duration = 27.299,
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

    spec:RegisterPack( "Unholy", 20180707.1120, [[dGuiAaWiLQ0MGunkiLofKIxbbZIK0TeQI2LI(fKyycvogeAzaQNrsyAauxJKOTPufFdsQgNqv15GKiwhKuY8ai3Js2Nq5GqsyHaYdfQstesI0ffQk2iKeLrcjjCsiPOvkeVuOQKBcjf2PsLHcjr1sHKe9urnvH0vfQc2QqvP(kKKYzfQcTxP(lPgSGdt1IPupg0KP4YiBwjFMeJwbNwYRjPMTi3wH2Tk)wvdhIooKuQLJYZr10jUoqBxPQ(UsX4HKKoVsP1djPA(ay)qDJyhTZgxOEhWXHy8hhQhhQprereJFvSNolBrsDgPdv7kuNpFK6C8Wn8PTDgPVn9UPJ2z(dYGuNhebjh1cfuq6CHSRBc)ruieJhrnwdX7(D2gSscQ512D24c17aooeJ)4q94qCIyCicSkvzN5ijyVdyvcCNneh25OdfhhkooideoyOLdMeCWHs9hoG0HQXH1ZWH4HB4tBXbuPXx4qD4aqluXehbhjEh8tH44WI9J4qUgJxulCeCeeN4aoGkmgYGdOcKp0tBrYjCGoHTfhCbhamc4aQmIleRofCav7bpdF25uXfEhTZWpz0dKZKoAVdXoANPZTtKPbQZqwjeR8oBdUwtWB4tB1CHrNImmz0OxhhhaeoOan4a64Gn4AnbVHpTvZfgDkYWKrouWb0XbBW1Ac)KrpqotMCXHQXHy4aI7PZouQ)6mCWRJR)LUGul9oG7ODMo3orMgOodzLqSY7Sn4AnhDUqm9V0kdpyIpz0OxhhhaeoOan4a64Gn4AnhDUqm9V0kdpyIpbrIdOJd2GR1e(jJEGCMm5IdvJdXWber9o7qP(RZWbVoU(x6csT07urhTZ052jY0a1ziReIvENTbxRj8tg9a5mzYfhQghSWbGJdhqhhSbxRj4n8PTAUWOtrgMmYHsNDOu)1z4Gxhx)lDbPwAPZgA5GjPJ27qSJ2zhk1FD2bLx7I4q1DMo3orMgOw6Da3r7SdL6VopwNrVyeHQtDMo3orMgOw6DQOJ2z6C7ezAG6mKvcXkVZmWRGAK)gInn0QGLGdXWbGJRZouQ)6SZG(rA5zm6Kw6DaUJ2zhk1FD2o9VrVazB7mDUDImnqT07uzhTZouQ)6SnX4etDDkDMo3orMgOw6D7PJ2zhk1FDgKt6sOrENPZTtKPbQLEhQ3r7mDUDImnqD(8rQZS6u0)sd)uYrYRtrVafqgX7SdL6VoZQtr)ln8tjhjVof9cuazeVZqwjeR8oJwCWgCTMcnIuCP(BYfhQghSWH4Wb0XbXzkKmLAK0YRnfHdXWH9ehoGgCaaaWbXzkKmLAK0YRnfHdach2tCT07I)oANPZTtKPbQZqwjeR8oBdUwtWB4tB1CHrNImmzKdLo7qP(RZiFP(RLEhQKoANPZTtKPT7mKvcXkVZOfhmVm3VyGj6enYKRastPGQ1snsAgn61XXbeWbPGQ1sns4aGSWbZlZ9lgyIorJm5kG0KrJEDCCan4a64G5L5(fdmrNOrMCfqAYOrVoooailCqbA6SdL6Vo)GInJC1T07qmUoANPZTtKPbQZouQ)6m0tjTdL6pDQ4sNtfx0NpsDg(FY8BoEl9oerSJ2z6C7ezAG6SdL6Vod9us7qP(tNkU05uXf95JuNvOJyfSLw6msgb)rBx6O9oe7ODMo3orMgOw6Da3r7mDUDImnqT07urhTZ052jY0a1sVdWD0otNBNitdul9ov2r7SdL6VoJ8L6VotNBNitdul9U90r7SdL6VoZ8ItAd5MotNBNitdul9ouVJ2zhk1FD2zJB1)sldK2qUPZ052jY0a1slD2FQJ27qSJ2z6C7ezAG6mKvcXkVZCKukPfNPqcFAixg0(z0gc6BXHyw4aWD2Hs9xNnKldA)mAdb9TT07aUJ2z6C7ezAG6mKvcXkVZouQ9jT5L5(fdmrNOrMCfqchIHdaUZouQ)6mHSm0ybBP3PIoANPZTtKPbQZqwjeR8oZrsPKwCMcj8jh(GmfsZfwPMWHyw4aW4a64aAXbd5YG2pJ2qqF7ukO66uWbaaahm0Qs0ukO66uWb00zhk1FDMdFqMcP5cRutT07aChTZ052jY0a1ziReIvEN5iPuslotHe(eM8n1PO5dU53WXHyw4aW4a64aAXbd5YG2pJ2qqF7ukO66uWbaaahm0Qs0ukO66uWb00zhk1FDgM8n1PO5dU53WBP3PYoANPZTtKPbQZqwjeR8o7qP2N0MxM7xmWeDIgzYvajCigoaCNDOu)1zczzOXc2slDwHoIvWoAVdXoANPZTtKPbQZqwjeR8oZaVcQr(Bi20qRcwcoaiCayG7SdL6VoBixg0WVsT07aUJ2zhk1FD2qRkrDMo3orMgOw6DQOJ2z6C7ezAG6mKvcXkVZouQ9jnD0yrCCiMfoaCNDOu)1zONsAhk1F6uXLoNkUOpFK6S)ul9oa3r7mDUDImnqDgYkHyL3zdzdUwZfXfIvNIEZdEMjxCOACaqw4aW4aaaGdmWJ4tPgjT8AaJdaYchuGMo7qP(RZlIleRofnxyLAQLENk7ODMo3orMgOodzLqSY7mAXbBW1AcEdFARMlm6uKHjJCOGdaaaoWapchIzHdaJdObhqhhmKn4AnxexiwDk6np4zMCXHQXHyw4aI4a64GHSbxR5I4cXQtrV5bpZKlounoeZchuboaaa4aAXb4)jZV5MoBCR(xAzG0gYntgn61XXHy4GkXbaaahyGhXNsnsA51aghaKfoOan4aA6SdL6VoZHpitH0CHvQPw6D7PJ2z6C7ezAG6mKvcXkVZOfhSbxRj4n8PTAUWOtrgMmYHcoaaa4ad8iCiMfoamoGgCaDCWq2GR1CrCHy1PO38GNzYfhQghIzHdiIdOJdgYgCTMlIleRof9Mh8mtU4q14qmlCqf4aaaGdOfhG)Nm)MB6SXT6FPLbsBi3mz0OxhhhIHdQehaaaCGbEeFk1iPLxdyCaqw4Gc0GdOPZouQ)6mm5BQtrZhCZVH3slDg(FY8BoEhT3HyhTZ052jY0a1ziReIvENjuBWcjsYmHFYOhiNj4a64Gn4AnHFYOhiNjtU4q14qmCaX46SdL6Vod9us7qP(tNkU05uXf95JuNHFYOhiNjT07aUJ2z6C7ezAG6SdL6Vo7iFON2IKtDgYkHyL3zdzdUwZfXfIvNIEZdEMjxCOACiMfoa4w6DQOJ2zhk1FD2zJB1)sldK2qUPZ052jY0a1sVdWD0otNBNitduNHSsiw5D2q2GR1CrCHy1PO38GNzYfhQghIzHdQahqhhyGhHdXSWbv0zhk1FDM)GjnJCKeRLENk7ODMo3orMgOodzLqSY7md8i(uQrslVgW4qmlCqbA6SdL6VoBCMATW8JVE2Ol1FT0slDEFIXR)6DahhIXFCOECiorerv25no7QtH35o7GYWZ6CUgbtUu)fVmFjDgj7xvI68EXH4dQkbbfYGd206zeoa)rBxWbBsPo(ehqfqiHu44W9x8CWzJlWeo4qP(JJd)L2oXrCOu)XNize8hTDXALCUACehk1F8jsgb)rBxqWcL1)gCehk1F8jsgb)rBxqWcfhuzKoXL6pCK9Id5ZrYhEbhyEzWbBW1Im4axCHJd206zeoa)rBxWbBsPooo4NbhqYO4jYxK6uWHIJdM)OjoIdL6p(ejJG)OTliyHc)CK8Hx0CXfooIdL6p(ejJG)OTliyHcYxQ)WrCOu)XNize8hTDbbluyEXjTHCdoIdL6p(ejJG)OTliyHIZg3Q)LwgiTHCdocoYEXH4dQkbbfYGd0(eBloi1iHdYaHdouEgouCCW33RKBNOjoIdL6pULdkV2fXHQXrCOu)XrWcLX6m6fJiuDchzV4aQshwEIRkoGAk0ixvCWpdo8YaXWHxbA44iouQ)4iyHIZG(rA5zm6evRLfd8kOg5VHytdTkyjXaooCehk1FCeSqXo9VrVazBXrCOu)XrWcfBIXjM66uWrCOu)XrWcfqoPlHg54iouQ)4iyHciN0LqJQE(izXQtr)ln8tjhjVof9cuazex1AzHwBW1Ak0isXL6VjxCOAR4qxCMcjtPgjT8AtrX2tCObaaeNPqYuQrslV2ueG2tC4iouQ)4iyHcYxQ)uTww2GR1e8g(0wnxy0Pidtg5qbhzV4aQHxN41HdX3fdmrNGdOYtUciHJ4qP(JJGfkpOyZixTQIZuirxll0AEzUFXat0jAKjxbKMsbvRLAK0mA0RJJGuq1APgjazzEzUFXat0jAKjxbKMmA0RJJg0nVm3VyGj6enYKRastgn61XbKLc0GJ4qP(JJGfkqpL0ouQ)0PIlQE(izb)pz(nhhhXHs9hhbluGEkPDOu)Ptfxu98rYsHoIvqCeCK9IdOIp(GdSxCP(dhXHs9hF6pzzixg0(z0gc6BvTwwCKukPfNPqcFAixg0(z0gc6BJzbmoIdL6p(0FcbluiKLHglOQ1YYHsTpPnVm3VyGj6enYKRasXamoIdL6p(0Fcblu4WhKPqAUWk1KQ1YIJKsjT4mfs4to8bzkKMlSsnfZcy0rRHCzq7NrBiOVDkfuDDkaaGHwvIMsbvxNcAWrCOu)XN(tiyHcm5BQtrZhCZVHRATS4iPuslotHe(eM8n1PO5dU53WJzbm6O1qUmO9ZOne03oLcQUofaaWqRkrtPGQRtbn4iouQ)4t)jeSqHqwgASGQwllhk1(K28YC)IbMOt0itUcifdyCeCK9IdX7Nm4aQcYzcoKif6moBloIdL6p(e(jJEGCMybh8646FPliPATSSbxRj4n8PTAUWOtrgMmA0RJdifObDBW1AcEdFARMlm6uKHjJCOGUn4AnHFYOhiNjtU4q1XqCp4iouQ)4t4Nm6bYzccwOah8646FPliPATSSbxR5OZfIP)Lwz4bt8jJg964asbAq3gCTMJoxiM(xALHhmXNGir3gCTMWpz0dKZKjxCO6yiI64iouQ)4t4Nm6bYzccwOah8646FPliPATSSbxRj8tg9a5mzYfhQ2c44q3gCTMG3WN2Q5cJofzyYihk4i4i7fhI3pzWHbYzco4NbhEzGy4WFXtfObhG)Nm)MJJJ4qP(JpH)Nm)MJBb9us7qP(tNkUO65JKf8tg9a5mr1AzrO2GfsKKzc)Krpqotq3gCTMWpz0dKZKjxCO6yighoIdL6p(e(FY8BoocwO4iFON2IKtQwlldzdUwZfXfIvNIEZdEMjxCO6ywaghXHs9hFc)pz(nhhbluC24w9V0YaPnKBWrCOu)XNW)tMFZXrWcf(dM0mYrsmvRLLHSbxR5I4cXQtrV5bpZKlouDmlvGod8OywQahXHs9hFc)pz(nhhblumotTwy(XxpB0L6pvRLfd8OPuJKwEnGJzPan4i4iouQ)4tf6iwbTmKldA4xjvRLfd8kOg5VHytdTkyjacyGXrCOu)XNk0rScIGfkgAvjchzV4qEtjWbCqECWFchXHs9hFQqhXkicwOa9us7qP(tNkUO65JKL)KQ1YYHsTpPPJglIhZcyCK9IdOAp4z44WOFUcnsNGJ4qP(JpvOJyfebluwexiwDkAUWk1KQ1YYq2GR1CrCHy1PO38GNzYfhQgqwadaamWJMsnsA51agqwkqdoIdL6p(uHoIvqeSqHdFqMcP5cRutQwll0AdUwtWB4tB1CHrNImmzKdfaaGbEumlGrd6gYgCTMlIleRof9Mh8mtU4q1XSqeDdzdUwZfXfIvNIEZdEMjxCO6ywQaaaql8)K53CtNnUv)lTmqAd5MjJg964XujaaWapAk1iPLxdyazPanObhXHs9hFQqhXkicwOat(M6u08b38B4Qwll0AdUwtWB4tB1CHrNImmzKdfaaGbEumlGrd6gYgCTMlIleRof9Mh8mtU4q1XSqeDdzdUwZfXfIvNIEZdEMjxCO6ywQaaaql8)K53CtNnUv)lTmqAd5MjJg964XujaaWapAk1iPLxdyazPanOPLw6g]] )

end
