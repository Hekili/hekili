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
        enabled = true,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        package = "Unholy",
    } )

    spec:RegisterPack( "Unholy", 20180701.1150, [[duKfzaWiLQYMGunkisNcI4vquZIKYTiPsTlf9li0WePCmiyzaPNbP00aQ6AKu12aQ4BKuX4uQQCoifQ1bPOAEkv5EuY(ejhesbwiq5HqkYfjPsgjKc5KqkkRueUjKcANkvgkqLOLcuj8urnvr0vvQQkBvPQQ6RkvvXzvQQs7vQ)sQbl0HPAXuQhdAYuCzKnRKptIrRGtl51KKzl42k0Uv53QA4qYXbQuwouphvtN46a2UivFxPy8avsNhiwpqLQ5RuA)OCJqNSZgxOEhOPHW(LM6Kgcteqa87hArJ7SackQZOCOkxH685JuN3)UHpasNr5GeE30j7m)bWqQZdIGIJMJiIOCUq21nH)iIec7VOHRb0u6D2gOccA212D24c17anne2V0uN0qyIqAiaQ6vFN5OiyVdu1dANneh25KdfNflol6SikhQYviw8xSOdL6pwmuCHZIRhZIOrKQkuZohkUW7KDg(bJEGCS0j7Di0j7mDUDGmnyDgIlHWL3zBG1AcCdFaenxW0Pidtmn61XzX9yrfOHfrNfTbwRjWn8bq0CbtNImmXKdfweDw0gyTMWpy0dKJLjxCOkwmflIa40zhk1FDgo41X1)sxqQLEhODYotNBhitdwNH4siC5D2gyTMJoxiS(xALHhiWNyA0RJZI7XIkqdlIolAdSwZrNlew)lTYWde4tauSi6SOnWAnHFWOhihltU4qvSykweb1PZouQ)6mCWRJR)LUGul9o02j7mDUDGmnyDgIlHWL3zBG1Ac)GrpqowMCXHQyrlwe00yr0zrBG1AcCdFaenxW0Pidtm5qPZouQ)6mCWRJR)LUGulT0zdTCGG0j7Di0j7SdL6Vo7aYRDrCOQotNBhitdwl9oq7KD2Hs9xNhRZOxyIa3PotNBhitdwl9o02j7mDUDGmnyDgIlHWL3zmWvqnQFdHNgAvWsyXuSiOP1zhk1FD2Xq)iT8ymDsl9oW3j7SdL6VoBh(3Oxayq6mDUDGmnyT07uFNSZouQ)6SnH5ewvDkDMo3oqMgSw6DGtNSZouQ)6maN0LqJ8otNBhitdwl9o1Pt2z6C7azAW6SdL6VoJRtr)ln8dbhfVof9cqaWeVZqCjeU8oJuw0gyTMcnIsCP(BYfhQIfTyX0yr0zrXXkKmLAK0YRnfXIPyrWjnwejS42TSO4yfsMsnsA51MIyX9yrWjToF(i1zCDk6FPHFi4O41POxacaM4T072VozNPZTdKPbRZqCjeU8oBdSwtGB4dGO5cMofzyIjhkD2Hs9xNr9s9xl9o04ozNPZTdKPbRZqCjeU8oJuZlZ0lmqGorJk4ka0ukOkTuJKgtJEDCKLcQsl1iTNL5Lz6fgiqNOrfCfaAIPrVoosq38Ym9cdeOt0OcUcanX0OxhFplfOPZouQ)68di2yYv1sVdH06KDMo3oqMgSo7qP(RZqpe0ouQ)0HIlDouCrF(i1z4)bZV54T07qaHozNPZTdKPbRZouQ)6m0dbTdL6pDO4sNdfx0NpsDwHocxWwAPZOWe8hTDPt27qOt2z6C7azAWAP3bANSZ052bY0G1sVdTDYotNBhitdwl9oW3j7mDUDGmnyT07uFNSZouQ)6mQxQ)6mDUDGmnyT07aNozNDOu)1zSxCsBi30z6C7azAWAP3PoDYo7qP(RZoEee9V0YaPnKB6mDUDGmnyT0sN9N6K9oe6KDMo3oqMgSodXLq4Y7mhffcAXXkKWNgYLbTFgTHGoiSyklwe0o7qP(RZgYLbTFgTHGoiT07aTt2z6C7azAW6mexcHlVZouQ0jT5Lz6fgiqNOrfCfaIftXIGVZouQ)6mHQm0ybBP3H2ozNPZTdKPbRZqCjeU8oZrrHGwCScj8jh(ayfsZfCPIyXuwSiOSi6Siszrd5YG2pJ2qqhKPuqv1PWIB3YIgAvbAkfuvDkSis6SdL6VoZHpawH0CbxQOw6DGVt2z6C7azAW6mexcHlVZCuuiOfhRqcFcd(M6u08b38B4SyklweuweDwePSOHCzq7NrBiOdYukOQ6uyXTBzrdTQanLcQQofwejD2Hs9xNHbFtDkA(GB(n8w6DQVt2z6C7azAW6mexcHlVZouQ0jT5Lz6fgiqNOrfCfaIftXIG2zhk1FDMqvgASGT0sNvOJWfSt27qOt2z6C7azAW6mexcHlVZyGRGAu)gcpn0QGLWI7XIGcANDOu)1zd5YGg(vOLEhODYo7qP(RZgAvbQZ052bY0G1sVdTDYotNBhitdwNH4siC5D2HsLoPPJglIZIPSyrq7SdL6Vod9qq7qP(thkU05qXf95JuN9NAP3b(ozNPZTdKPbRZqCjeU8oBiBG1AUiUq46u0BEGZm5IdvXI7zXIGYIB3YIyGJ4tPgjT8AWZI7zXIkqtNDOu)15fXfcxNIMl4sf1sVt9DYotNBhitdwNH4siC5DgPSOnWAnbUHpaIMly6uKHjMCOWIB3YIyGJyXuwSiOSisyr0zrdzdSwZfXfcxNIEZdCMjxCOkwmLflIalIolAiBG1AUiUq46u0BEGZm5IdvXIPSyr0YIB3YIiLfH)hm)MB64rq0)sldK2qUzIPrVoolMIfvplUDllIboIpLAK0YRbplUNflQanSis6SdL6VoZHpawH0CbxQOw6DGtNSZ052bY0G1ziUecxENrklAdSwtGB4dGO5cMofzyIjhkS42TSig4iwmLflcklIeweDw0q2aR1CrCHW1PO38aNzYfhQIftzXIiWIOZIgYgyTMlIleUof9Mh4mtU4qvSyklweTS42TSiszr4)bZV5MoEee9V0YaPnKBMyA0RJZIPyr1ZIB3YIyGJ4tPgjT8AWZI7zXIkqdlIKo7qP(RZWGVPofnFWn)gElT0z4)bZV54DYEhcDYotNBhitdwNH4siC5DMa3akuOiZe(bJEGCSWIOZI2aR1e(bJEGCSm5IdvXIPyresRZouQ)6m0dbTdL6pDO4sNdfx0NpsDg(bJEGCS0sVd0ozNDOu)1zhpcI(xAzG0gYnDMo3oqMgSw6DOTt2z6C7azAW6mexcHlVZgYgyTMlIleUof9Mh4mtU4qvSyklweTSi6Sig4iwmLflI2o7qP(RZ8hiOXKJIWT07aFNSZ052bY0G1ziUecxENXahXNsnsA51GNftzXIkqtNDOu)1zJJvPfSF81JhDP(RLwAPZPtyE9xVd00qy)stDsdHjciaE135no(QtH35o7aYWJ7CUgbcUu)HMW(s6mk8VQa159XIQlWvcciKHfTP1Jjwe(J2UWI2KsD8jlIgaHekHZI3FQ7bhpUacSOdL6pol(xaKjlHdL6p(efMG)OTlwRGZvXs4qP(JprHj4pA7cYwiU(3Ws4qP(JprHj4pA7cYwi6akJ0jUu)XsSpwmFok(WlSi2ldlAdSwKHf5IlCw0MwpMyr4pA7clAtk1Xzr)mSikmPUr9IuNclwCw08hnzjCOu)XNOWe8hTDbzle5NJIp8IMlUWzjCOu)XNOWe8hTDbzler9s9hlHdL6p(efMG)OTliBHi2loPnKByjCOu)XNOWe8hTDbzleD8ii6FPLbsBi3WsWsSpwuDbUsqaHmSiLoHbHfLAKyrzGyrhkpMflol6P7vWTd0KLWHs9h3YbKx7I4qvSeouQ)4iBH4yDg9cte4oXsSpweCHdlpWvJfrZeAKRgl6NHfFzGWS4RanCwchk1FCKTq0Xq)iT8ymDIA1YcdCfuJ63q4PHwfSKuGMglHdL6poYwiAh(3OxayqyjCOu)Xr2crBcZjSQ6uyjCOu)Xr2craoPlHg5SeouQ)4iBHiaN0LqJQD(izHRtr)ln8dbhfVof9cqaWexTAzHuBG1Ak0ikXL6VjxCOkR0qxCScjtPgjT8AtrPaN0qY2TIJvizk1iPLxBkApWjnwchk1FCKTqe1l1FQvllBG1AcCdFaenxW0Pidtm5qHLyFSiAOxN41XI7)fgiqNWIGldUcaXs4qP(JJSfIpGyJjxLAIJvirxllKAEzMEHbc0jAubxbGMsbvPLAK0yA0RJJSuqvAPgP9SmVmtVWab6enQGRaqtmn61Xrc6MxMPxyGaDIgvWvaOjMg9647zPanSeouQ)4iBHi0dbTdL6pDO4IANpswW)dMFZXzjCOu)Xr2crOhcAhk1F6qXf1oFKSuOJWfKLGLyFSiAWRUyr8lUu)Xs4qP(Jp9NSmKldA)mAdbDquRwwCuuiOfhRqcFAixg0(z0gc6GKYcuwchk1F8P)eYwisOkdnwq1QLLdLkDsBEzMEHbc0jAubxbGsbEwchk1F8P)eYwiYHpawH0CbxQi1QLfhffcAXXkKWNC4dGvinxWLkkLfOOJud5YG2pJ2qqhKPuqv1PSDRHwvGMsbvvNcsyjCOu)XN(tiBHim4BQtrZhCZVHRwTS4OOqqlowHe(eg8n1PO5dU53Wtzbk6i1qUmO9ZOne0bzkfuvDkB3AOvfOPuqv1PGewchk1F8P)eYwisOkdnwq1QLLdLkDsBEzMEHbc0jAubxbGsbklblX(yr00hmSiAe5yHfdKcDghdclHdL6p(e(bJEGCSybh8646FPliPwTSSbwRjWn8bq0CbtNImmX0OxhFpfObDBG1AcCdFaenxW0Pidtm5qbDBG1Ac)GrpqowMCXHQsHa4Ws4qP(JpHFWOhihliBHiCWRJR)LUGKA1YYgyTMJoxiS(xALHhiWNyA0RJVNc0GUnWAnhDUqy9V0kdpqGpbqHUnWAnHFWOhihltU4qvPqqDyjCOu)XNWpy0dKJfKTqeo41X1)sxqsTAzzdSwt4hm6bYXYKlouLfOPHUnWAnbUHpaIMly6uKHjMCOWsWsSpwen9bdloqowyr)mS4ldeMf)tDRanSi8)G53CCwchk1F8j8)G53CClOhcAhk1F6qXf1oFKSGFWOhihlQvllcCdOqHImt4hm6bYXc62aR1e(bJEGCSm5IdvLcH0yjCOu)XNW)dMFZXr2crhpcI(xAzG0gYnSeouQ)4t4)bZV54iBHi)bcAm5OiSA1YYq2aR1CrCHW1PO38aNzYfhQkLfArhdCukl0Ys4qP(JpH)hm)MJJSfIghRsly)4Rhp6s9NA1YcdC0uQrslVg8PSuGgwcwchk1F8PcDeUGwgYLbn8RGA1YcdCfuJ63q4PHwfSK9afuwchk1F8PcDeUGiBHOHwvGyj2hlM3ucCGfLNf9NyjCOu)XNk0r4cISfIqpe0ouQ)0HIlQD(iz5pPwTSCOuPtA6OXI4PSaLLyFS4(ZdCgolo6NRqJ0jSeouQ)4tf6iCbr2cXfXfcxNIMl4sfPwTSmKnWAnxexiCDk6npWzMCXHQ2Zc0TBXahnLAK0YRb)EwkqdlHdL6p(uHocxqKTqKdFaScP5cUurQvllKAdSwtGB4dGO5cMofzyIjhkB3IbokLfOibDdzdSwZfXfcxNIEZdCMjxCOQuwiGUHSbwR5I4cHRtrV5boZKlouvkl0UDlsH)hm)MB64rq0)sldK2qUzIPrVoEk1VDlg4OPuJKwEn43ZsbAqclHdL6p(uHocxqKTqeg8n1PO5dU53WvRwwi1gyTMa3WharZfmDkYWetou2UfdCuklqrc6gYgyTMlIleUof9Mh4mtU4qvPSqaDdzdSwZfXfcxNIEZdCMjxCOQuwOD7wKc)py(n30XJGO)LwgiTHCZetJED8uQF7wmWrtPgjT8AWVNLc0GKwAPBa]] )

end
