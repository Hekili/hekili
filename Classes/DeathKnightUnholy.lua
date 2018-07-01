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

            gain( amt * 10, "runic_power" )

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
            duration = 10,
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
            id = 152280,
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
            duration = 18.2,
            type = "Disease",
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
            end

            return false
        end } ) )

    spec:RegisterStateTable( 'defile', 
        setmetatable( { onReset = function( self ) end },
        { __index = function( t, k )
            if k == 'ticking' then
                return buff.death_and_decay.up
            end

            return false
        end } ) )

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
                applyBuff( "antimagic_shell", talent.spell_eater.enabled and 10 or 5 )
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
            
            handler = function ()
                applyDebuff( "target", "chains_of_ice" )
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
            
            usable = function () return not pet.exists end,
            handler = function ()
                summonPet( "fake_pet" )
            end,
        },
        

        dark_command = {
            id = 56222,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
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
            end,
        },
        

        death_gate = {
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
        },
        

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
            
            handler = function ()
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
            end,
        },
        

        deaths_advance = {
            id = 48265,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
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
            
            spend = -10,
            spendType = "runic_power",
            
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
        

        raise_ally = {
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
        },
        

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
        

        runeforging = {
            id = 53428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 237523,
            
            usable = false,
            handler = function ()
            end,
        },
        

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
                if debuff.festering_wound.stack > 1 then applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
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
            
            spend = -10,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 136132,
            
            handler = function ()
                applyBuff( "unholy_blight" )
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
            
            handler = function ()
                applyBuff( "wraith_walk" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = false,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        package = nil,
    } )
end
