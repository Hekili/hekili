-- DeathKnightUnholy.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'DEATHKNIGHT' then
    local spec = Hekili:NewSpecialization( 252 )

    spec:RegisterResource( Enum.PowerType.Runes, {
        rune_regen = {
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
            gain( amt * 10, "runic_power" )

            if set_bonus.tier20_4pc == 1 then
                cooldown.army_of_the_dead.expires = max( 0, cooldown.army_of_the_dead.expires - 1 )
            end
        end
    end

    spec:RegisterHook( "spend", spendHook )

    
    spec:RegisterStateFunction( "apply_festermight", function( n )
        if azerite.festermight.enabled then
            if buff.festermight.up then
                addStack( "festermight", buff.festermight.remains, n )
            else
                applyBuff( "festermight", nil, n )
            end
        end
    end )

    
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

        antimagic_zone = 42, -- 51052
        cadaverous_pallor = 163, -- 201995
        dark_simulacrum = 41, -- 77606
        lichborne = 3754, -- 287081 -- ADDED 8.1
        life_and_death = 40, -- 288855 -- ADDED 8.1
        necrotic_aura = 3437, -- 199642
        necrotic_strike = 149, -- 223829
        raise_abomination = 3747, -- 288853
        reanimation = 152, -- 210128
        transfusion = 3748, -- 288977 -- ADDED 8.1
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
            id = 101568,
            duration = 20,
        },
        dark_transformation = {
            id = 63560, 
            duration = 20,
            generate = function ()
                local cast = class.abilities.dark_transformation.lastCast or 0
                local up = pet.ghoul.up and cast + 20 > state.query_time

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
            meta = {
                stack = function ()
                    -- Designed to work with Unholy Frenzy, time until 4th Festering Wound would be applied.
                    local actual = debuff.festering_wound.count
                    if buff.unholy_frenzy.down then return actual end

                    local slot_time = now + offset
                    local swing, speed = state.swings.mainhand, state.swings.mainhand_speed

                    local last = swing + ( speed * floor( slot_time - swing ) / swing )
                    local window = min( buff.unholy_frenzy.expires, query_time ) - last

                    local bonus = floor( window / speed )

                    return min( 6, actual + bonus )
                end
            }
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
            tick_time = function () return 2 * haste end,
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


        -- PvP Talents
        crypt_fever = {
            id = 288849,
            duration = 4,
            max_stack = 1,
        },

        necrotic_wound = {
            id = 223929,
            duration = 18,
            max_stack = 1,
        },


        -- Azerite Powers
        cold_hearted = {
            id = 288426,
            duration = 8,
            max_stack = 1
        },

        festermight = {
            id = 274373,
            duration = 20,
            max_stack = 99,
        },

        helchains = {
            id = 286979,
            duration = 15,
            max_stack = 1
        }
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


    spec:RegisterStateFunction( "time_to_wounds", function( x )
        if debuff.festering_wound.stack >= x then return 0 end
        if buff.unholy_frenzy.down then return 3600 end

        local deficit = x - debuff.festering_wound.stack
        local swing, speed = state.swings.mainhand, state.swings.mainhand_speed

        local last = swing + ( speed * floor( query_time - swing ) / swing )
        local fw = last + ( speed * deficit ) - query_time

        if fw > buff.unholy_frenzy.remains then return 3600 end
        return fw
    end )


    spec:RegisterGear( "tier19", 138355, 138361, 138364, 138349, 138352, 138358 )
    spec:RegisterGear( "tier20", 147124, 147126, 147122, 147121, 147123, 147125 )
        spec:RegisterAura( "master_of_ghouls", {
            id = 246995,
            duration = 3,
            max_stack = 1
        } )        

    spec:RegisterGear( "tier21", 152115, 152117, 152113, 152112, 152114, 152116 )
        spec:RegisterAura( "coils_of_devastation", {
            id = 253367,
            duration = 4,
            max_stack = 1
        } )

    spec:RegisterGear( "acherus_drapes", 132376 )
    spec:RegisterGear( "cold_heart", 151796 ) -- chilled_heart stacks NYI
        spec:RegisterAura( "cold_heart_item", {
            id = 235599,
            duration = 3600,
            max_stack = 20 
        } )

    spec:RegisterGear( "consorts_cold_core", 144293 )
    spec:RegisterGear( "death_march", 144280 )
    -- spec:RegisterGear( "death_screamers", 151797 )
    spec:RegisterGear( "draugr_girdle_of_the_everlasting_king", 132441 )
    spec:RegisterGear( "koltiras_newfound_will", 132366 )
    spec:RegisterGear( "lanathels_lament", 133974 )
    spec:RegisterGear( "perseverance_of_the_ebon_martyr", 132459 )
    spec:RegisterGear( "rethus_incessant_courage", 146667 )
    spec:RegisterGear( "seal_of_necrofantasia", 137223 )
    spec:RegisterGear( "shackles_of_bryndaor", 132365 ) -- NYI
    spec:RegisterGear( "soul_of_the_deathlord", 151740 )
    spec:RegisterGear( "soulflayers_corruption", 151795 )
    spec:RegisterGear( "the_instructors_fourth_lesson", 132448 )
    spec:RegisterGear( "toravons_whiteout_bindings", 132458 )
    spec:RegisterGear( "uvanimor_the_unbeautiful", 137037 )


    spec:RegisterPet( "ghoul", 26125, "raise_dead", 3600 )
    spec:RegisterTotem( "gargoyle", 458967 )
    spec:RegisterTotem( "abomination", 298667 )


    spec:RegisterHook( "reset_precast", function ()
        local expires = action.summon_gargoyle.lastCast + 35
        if expires > now then
            summonPet( "gargoyle", expires - now )
        end

        local control_expires = action.control_undead.lastCast + 300
        if control_expires > now and pet.up and not pet.ghoul.up then
            summonPet( "controlled_undead", control_expires - now )
        end

        if talent.all_will_serve.enabled and pet.ghoul.up then
            summonPet( "skeleton" )
        end

        rawset( cooldown, "army_of_the_dead", nil )
        rawset( cooldown, "raise_abomination", nil )
    
        if pvptalent.raise_abomination.enabled then
            cooldown.army_of_the_dead = cooldown.raise_abomination
        else
            cooldown.raise_abomination = cooldown.army_of_the_dead
        end
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
            cooldown = function () return pvptalent.necromancers_bargain.enabled and 45 or 90 end,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1392565,
            
            handler = function ()
                if debuff.festering_wound.stack > 4 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.remains - 4 )
                    apply_festermight( 4 )
                    gain( 12, "runic_power" )
                else                    
                    gain( 3 * debuff.festering_wound.stack, "runic_power" )
                    apply_festermight( debuff.festering_wound.stack )
                    removeDebuff( "target", "festering_wound" )
                end

                if pvptalent.necromancers_bargain.enabled then applyDebuff( "target", "crypt_fever" ) end
                -- summon pets?                
            end,
        },
        

        army_of_the_dead = {
            id = function () return pvptalent.raise_abomination.enabled and 288853 or 42650 end,
            cast = 0,
            cooldown = 480,
            gcd = "spell",
            
            spend = function () return pvptalent.raise_abomination.enabled and 0 or 3 end,
            spendType = "runes",
            
            toggle = "cooldowns",
            -- nopvptalent = "raise_abomination",

            startsCombat = false,
            texture = function () return pvptalent.raise_abomination.enabled and 298667 or 237511 end,
            
            handler = function ()
                if pvptalent.raise_abomination.enabled then
                    summonPet( "abomination" )
                else
                    applyBuff( "army_of_the_dead", 4 )
                    if set_bonus.tier20_2pc == 1 then applyBuff( "master_of_ghouls" ) end
                end
            end,

            copy = { 288853, 42650, "army_of_the_dead", "raise_abomination" }
        },


        --[[ raise_abomination = {
            id = 288853,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",
            pvptalent = "raise_abomination",

            startsCombat = false,
            texture = 298667,
            
            handler = function ()                
            end,
        }, ]]
        

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
                if debuff.festering_wound.stack > 1 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                else removeDebuff( "target", "festering_wound" ) end
                apply_festermight( 1 )
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
                dismissPet( "ghoul" )
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
        

        dark_simulacrum = {
            id = 77606,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            spend = 0,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 135888,

            pvptalent = "dark_simulacrum",
            
            usable = function ()
                if not target.is_player then return false, "target is not a player" end
                return true
            end,
            handler = function ()
                applyDebuff( "target", "dark_simulacrum" )
            end,
        },
        

        dark_transformation = {
            id = 63560,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = false,
            texture = 342913,
            
            usable = function () return pet.ghoul.alive end,
            handler = function ()
                applyBuff( "dark_transformation" )
                if azerite.helchains.enabled then applyBuff( "helchains" ) end
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
                if set_bonus.tier21_2pc == 1 then applyDebuff( "target", "coils_of_devastation" ) end
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
            
            spend = function () return buff.dark_succor.up and 0 or ( ( buff.transfusion.up and 0.5 or 1 ) * 35 ) end,
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
            cooldown = function ()
                if azerite.cold_hearted.enabled then return 165 end
                return 180
            end,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = false,
            texture = 237525,
            
            handler = function ()
                applyBuff( "icebound_fortitude" )
                if azerite.cold_hearted.enabled then applyBuff( "cold_hearted" ) end
            end,
        },
        

        lichborne = {
            id = 287081,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            pvptalent = "lichborne",

            startsCombat = false,
            texture = 136187,
            
            handler = function ()
                applyBuff( "lichborne" )
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
            
            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        necrotic_strike = {
            id = 223829,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 132481,

            pvptalent = "necrotic_strike",

            handler = function ()
                if debuff.festering_wound.up then
                    if debuff.festering_wound.stack == 1 then removeDebuff( "target", "festering_wound" )
                    else applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 ) end

                    applyDebuff( "target", "necrotic_wound" )
                end
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

            essential = true, -- new flag, will allow recasting even in precombat APL.
            
            usable = function () return not pet.alive end,
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

            --[[ 20181230:  Remove Festering Wounds requirement, improves AOE.
            usable = function ()
                if debuff.festering_wound.down then return false, "requires festering_wound" end
                return true
            end, ]]
            handler = function ()
                gain( 3, "runic_power" )
                if debuff.festering_wound.stack > 1 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                else removeDebuff( "target", "festering_wound" ) end
                apply_festermight( 1 )
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
        

        transfusion = {
            id = 288977,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = -20,
            spendType = "runic_power",
            
            startsCombat = false,
            texture = 237515,

            pvptalent = "transfusion",
            
            handler = function ()
                applyBuff( "transfusion" )
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
    
        potion = "battle_potion_of_strength",
    
        package = "Unholy",
    } )

    spec:RegisterPack( "Unholy", 20181211.1740, [[dyKwXaqifspsvu2Kc1Oiv1PeKEfPIzrQ0Tivr7IKFPkmmejogIYYuf5zkennfvUMIQ2McbFtvu14ui05ivHwhPkyEcI7Hq7Jq6GQIkTqcXdjvPAIisvxKuLWgrKICssvswPIYlvfvCtsvsTtevdfrQSueP0tvPPQk1vjvPSvePO2lWFfAWu1HPSys5XOmzuDzOnRIpRQgnH60sTAsvIETQKzt0Tfy3s(TOHRGLd65uz6kDDc2oI47iy8isHZRiRhrsZxqTFKgqg4n4YTfbK)ePq2is2tKrMISNFK6X5idC3PbeChm2l7JGBzbi4Q3kXPCcChSjzACWBW1LcqgcUI3DWPhE8aAeu)EflOj4qilRfRvXYGhUoqqABNfdAN9HRdyp0oMEYrsEmaZtlr3dshejTwZDpiDK2iPhTvC85u9x8g1BL4uoPCDadC1eA5QxvanWLBlci)jsHSrKSNiJmfzp)i1JJupcUUbKbi)P5FcCf3CowanWLJog4(mQxVvIt5e1t6rBft9pNQ)Ix6SNr9I3DWPhE843RybnfldE46abPTDwmOD2hUoG9qtMAp0oMEYrsEmaZtlr3dshejTwZDpiDK2iPhTvC85u9x8g1BL4uoPCDaJo7zupPhzyGgcPEYitxQ)jsHSrK61tQNSrqpm3t0z0zpJ617IT6Jo9aD2ZOE9K6FUCoYPE96U4upPjiIKkQOZEg1RNuVEplsq4ICQFn4h3yFOEww8E7SCu)Mupe)csds9SS492z5uGRSDRd8gC)yHWMbEdiNmWBWflttICGiGld2lcBdC1eohLtGZXkYZmqbrJTu)yQFuQNed2MMevdzk76hpjm(n4pNKi1hom1pGR6BWFojrLX2MeeCn22zbUC0wXrw2sWci)jWBWflttICGiGld2lcBdCHcvZIdjbeQ44Pz9s9Hq9Knh1pM61N6zzk5jHszdjZKtdoubXaRlh1lk1pp1hom1ZrnHZrDq3IWU(rcPqXvU1yVOErP(5O(qP(Xu)OupjgSnnjQgYu21pEsy8BWFojrW1yBNf4YrBfhzzlblG8rcEdUyzAsKdebCzWEryBG7AsSw1a62wIfdvyzAsKt9JPEwMsEsOu2qYm50GdvqmW6YbUgB7SaxoAR4Ov8ihz2eybKph4n4ILPjroqeWLb7fHTbUSmL8KqPSHKzYPbhQGyG1LdCn22zbUC80seSaYNh8gCXY0Kihic4YG9IW2ax9PE9PEoQjCoQd6we21psifkUsyG6ht9SmL8KqPSHKzYPbhQGyG1LJ6fL6NN6dL6dhM65OMW5OoOBryx)iHuO4k3ASxuVOu)CuFOu)yQNLPKNekLbdMI5jUIXihnUcIbwxoQxuQFEW1yBNf46yPa8Jr3c7xiybKpcG3GlwMMe5araxgSxe2g4Qp1Rp1ZrnHZrDq3IWU(rcPqXvcdu)yQNLPKNekLnKmton4qfedSUCuVOu)8uFOuF4Wuph1eoh1bDlc76hjKcfx5wJ9I6fL6NJ6dL6ht9SmL8KqPmyWumpXvmg5OXvqmW6Yr9Is9ZdUgB7SaxM0i01p6eB8KGdSaYFEWBWflttICGiGld2lcBdCHcvZIdjbeQ44Pz9s9Hq9prku)yQFuQNed2MMevdzk76hpjm(n4pNKi4ASTZcC5OTIJSSLGfq(icEdUyzAsKdebCzWEryBGR(uV(uV(uV(uph1eoh1bDlc76hjKcfx5wJ9I6dH6NJ6ht9Js9AcNJsOeNYP4bIfPoPegO(qP(WHPEoQjCoQd6we21psifkUYTg7f1hc1psQpuQFm1ZYuYtcLYgsMjNgCOcIbwxoQpeQFKuFOuF4Wuph1eoh1bDlc76hjKcfx5wJ9I6dH6jJ6dL6ht9SmL8KqPmyWumpXvmg5OXvqmW6Yr9Is9ZdUgB7Sa3d6we21p6wy)cblGC9i4n4ILPjroqeWLb7fHTbUJs9KyW20KOAitzx)4jHXVb)5KebxJTDwGlhTvCKLTeSGfC54XeKl4nGCYaVbxJTDwGBqx84bIiPIGlwMMe5aralG8NaVbxSmnjYbIaUKysbeCzzk5jHs5eccYk(n4pNKOcIbwxoQpeQFEQFm1VMeRv5eccYk(n4pNKOclttICW1yBNf4sIbBttIGljgmwwacUdzk76hpjm(n4pNKiybKpsWBWflttICGiGld2lcBdCHcvZIdjbeQ44Pz9s9Is9JW8u)yQxFQNLPKNekLtiiiR43G)CsIkigyD5O(WHP(rP(1KyTkNqqqwXVb)5KevyzAsKt9Hs9JPEOqHkoEAwVuVOeP(5bxJTDwGRbzwHXnHqSwWciFoWBWflttICGiGld2lcBdChWv9n4pNKOYyBtcs9Hdt9Js9RjXAvoHGGSIFd(ZjjQWY0KihCn22zbUAYm5XJaCcSaYNh8gCXY0Kihic4YG9IW2a3bCvFd(ZjjQm22KGuF4Wu)Ou)AsSwLtiiiR43G)CsIkSmnjYbxJTDwGRgcDi8vxFWciFeaVbxJTDwGRGdJ9IboWflttICGiGfq(ZdEdUyzAsKdebCn22zbUAt)SWOgIrtgyLXaxgSxe2g4YYuYtcLYjeeKv8BWFojrfedSUCuVOu)iqkuF4Wu)Ou)AsSwLtiiiR43G)CsIkSmnjYb3YcqWvB6Nfg1qmAYaRmgybKpIG3GlwMMe5araxJTDwGREj6IItcsecUmyViSnWDax13G)CsIkJTnji1hom1pk1VMeRv5eccYk(n4pNKOclttICWTSaeC1lrxuCsqIqWcixpcEdUyzAsKdebCn22zbUFtImtkrOlQH2lWLb7fHTbUd4Q(g8NtsuzSTjbP(WHP(rP(1KyTkNqqqwXVb)5KevyzAsKdULfGG73KiZKse6IAO9cSaYjJuaVbxSmnjYbIaUmyViSnWLLPKNekLbdMI5jUIXihnUcIgFI6dhM6hWv9n4pNKOYyBtcs9Hdt9AcNJsOeNYP4bIfPoPegaxJTDwG7qUDwGfqozKbEdUyzAsKdebCzWEryBGR(uppxfjnuqI1ghK2xavBZEf3oaJqmW6Yr96q9BZEf3oaP(qis98CvK0qbjwBCqAFbubXaRlh1hk1pM655QiPHcsS24G0(cOcIbwxoQpeIu)NXbxJTDwGBkSAq0Ebwa5K9e4n4ILPjroqeW1yBNf4YmPmASTZkkB3cUY2TXYcqWLLPKNekhybKt2ibVbxSmnjYbIaUmyViSnW1yBtcgXcdA0r9IsK6FcCn22zbUqHkASTZkkB3cUY2TXYcqW1seSaYjBoWBWflttICGiGRX2olWLzsz0yBNvu2UfCLTBJLfGG7hle2mWcwWDaISmqZwWBa5KbEdUyzAsKdebSaYFc8gCXY0KihicybKpsWBWflttICGiGfq(CG3GlwMMe5aralG85bVbxJTDwG7qUDwGlwMMe5aralG8ra8gCn22zbUqRDyKJghCXY0KihicybK)8G3GlwMMe5araxokTjW9jW1yBNf4AWGPyEIRymYrJdwWcUSmL8Kq5aVbKtg4n4ASTZcCnyWumpXvmg5OXbxSmnjYbIawa5pbEdUyzAsKdebCzWEryBGlh1eoh1bDlc76hjKcfx5wJ9I6fLi1ph4ASTZcCTHKzYPbhcwa5Je8gCn22zbUCd(kUqRCNegyBNf4ILPjroqeWciFoWBWflttICGiGld2lcBdCHcvZIdjbeQ44Pz9s9Hq9Knh4ASTZcCDcbbzf)g8NtseSaYNh8gCXY0Kihic4YG9IW2axoQjCoQd6we21psifkUYTg7f1hc1ph4ASTZcCfkXPCkEGyrQtGfq(iaEdUyzAsKdebCzWEryBGRX2MemIfg0OJ6fLi1)e1pM61N61N6zzk5jHsXrBfhTIh5iZMuqmW6Yr9HqK6)mo1pM6hL6xtI1Q44PLOclttICQpuQpCyQxFQNLPKNekfhpTevqmW6Yr9HqK6)mo1pM6xtI1Q44PLOclttICQpuQpuW1yBNf4kuIt5u8aXIuNalG8Nh8gCXY0Kihic4YG9IW2a31GFCvBhGXnJ8gP(qO(rK6ht9Rb)4Q2oaJBg5ns9Is9ZbUgB7SaxxkiJq0gqiybKpIG3GlwMMe5araxgSxe2g4Qp1pk1dTMhrsWAvgN7uiPr7wh1hom1dTMhrsWAvgN7uDr9Is9prkuFOu)yQhkui1hcrQxFQNmQxpPEnHZrjuIt5u8aXIuNucduFOGRX2olW1LcYieTbecwa56rWBW1yBNf4kuIt5uut2FXl4ILPjroqeWcwW1se8gqozG3GlwMMe5araxgSxe2g4YYuYtcLYgsMjNgCOcIbwxoW1yBNf4YrBfhTIh5iZMalG8NaVbxJTDwGlhpTebxSmnjYbIawa5Je8gCXY0Kihic4YG9IW2axoAR4Ov8ihz2KAB2RU(u)yQhkui1hc1)e1pM6hL6jXGTPjr1qMYU(XtcJFd(ZjjcUgB7SaxCO5yqZalG85aVbxSmnjYbIaUmyViSnWLJ2koAfpYrMnP2M9QRp1pM6Hcfs9Hq9pr9JP(rPEsmyBAsunKPSRF8KW43G)CsIGRX2olWLJ2koYYwcwa5ZdEdUyzAsKdebCzWEryBGlhTvC0kEKJmBsTn7vxFQFm1ZYuYtcLYgsMjNgCOcIbwxoW1yBNf46yPa8Jr3c7xiybKpcG3GlwMMe5araxgSxe2g4YrBfhTIh5iZMuBZE11N6ht9SmL8KqPSHKzYPbhQGyG1LdCn22zbUmPrORF0j24jbhybK)8G3GlwMMe5araxgSxe2g4ok1tIbBttIQHmLD9JNeg)g8NtseCn22zbU4qZXGMbwa5Ji4n4ILPjroqeWLb7fHTbUCut4Cuh0TiSRFKqkuCLBn2lQpeIupzu)yQNLPKNekfhTvC0kEKJmBsbXaRlh4ASTZcCpOBryx)OBH9leSaY1JG3GlwMMe5araxgSxe2g4UMeRvPjaDBx)OlHOtHLPjro1pM6DdOugxd(X1P0eGUTRF0Lq0r9IsK6FI6ht9Cut4Cuh0TiSRFKqkuCLBn2lQpeIupzGRX2olW9GUfHD9JUf2VqWciNmsb8gCXY0Kihic4YG9IW2axnHZr5e4CSI8mduq0yl1pM6HcfQ44Pz9s9IsK6NdCn22zbUC0wXrw2sWciNmYaVbxSmnjYbIaUmyViSnWvt4CuobohRipZafen2s9JP(rPEsmyBAsunKPSRF8KW43G)CsIuF4Wu)aUQVb)5KevgBBsqW1yBNf4YrBfhzzlblGCYEc8gCXY0Kihic4YG9IW2axOq1S4qsaHkoEAwVuFiupzZr9JPE9PEwMsEsOu2qYm50GdvqmW6Yr9Is9Zt9Hdt9Cut4Cuh0TiSRFKqkuCLBn2lQxuQFoQpuQFm1pk1tIbBttIQHmLD9JNeg)g8NtseCn22zbUC0wXrw2sWciNSrcEdUyzAsKdebCzWEryBGR(uV(uph1eoh1bDlc76hjKcfxjmq9JPEwMsEsOu2qYm50GdvqmW6Yr9Is9Zt9Hs9Hdt9Cut4Cuh0TiSRFKqkuCLBn2lQxuQFoQpuQFm1ZYuYtcLYGbtX8exXyKJgxbXaRlh1lk1pp4ASTZcCDSua(XOBH9leSaYjBoWBWflttICGiGld2lcBdC1N61N65OMW5OoOBryx)iHuO4kHbQFm1ZYuYtcLYgsMjNgCOcIbwxoQxuQFEQpuQpCyQNJAcNJ6GUfHD9JesHIRCRXEr9Is9Zr9Hs9JPEwMsEsOugmykMN4kgJC04kigyD5OErP(5bxJTDwGltAe66hDInEsWbwa5Knp4n4ILPjroqeWLb7fHTbUqHQzXHKacvC80SEP(qO(NifQFm1pk1tIbBttIQHmLD9JNeg)g8NtseCn22zbUC0wXrw2sWciNSra8gCXY0Kihic4YG9IW2ax9PE9PE9PE9PEoQjCoQd6we21psifkUYTg7f1hc1ph1pM6hL61eohLqjoLtXdelsDsjmq9Hs9Hdt9Cut4Cuh0TiSRFKqkuCLBn2lQpeQFKuFOu)yQNLPKNekLnKmton4qfedSUCuFiu)iP(qP(WHPEoQjCoQd6we21psifkUYTg7f1hc1tg1hk1pM6zzk5jHszWGPyEIRymYrJRGyG1LJ6fL6NhCn22zbUh0TiSRF0TW(fcwa5K98G3GlwMMe5araxgSxe2g4ok1tIbBttIQHmLD9JNeg)g8NtseCn22zbUC0wXrw2sWcwWcUKGqxNfG8NifYgrYiLNit9ePq2ibxcgS667ax9QGHeUiN6NN6n22zr9Y2TofDg4oaZtlrW9zuVEReNYjQN0J2kM6Fov)fV0zpJ6fV7Gtp84XVxXcAkwg8W1bcsB7Syq7SpCDa7HMm1EODm9KJK8yaMNwIUhKoisATM7Eq6iTrspAR44ZP6V4nQ3kXPCs56agD2ZOEspYWanes9KrMUu)tKczJi1RNupzJGEyUNOZOZEg1R3fB1hD6b6SNr96j1)C5CKt961DXPEstqejvurN9mQxpPE9EwKGWf5u)AWpUX(q9SS492z5O(nPEi(fKgK6zzX7TZYPOZOZEg1RxqAGmHf5uVgEsis9SmqZwQxd)D5uu)ZLXWH1r9vw6PydgCeKuVX2olh1NLCsrNzSTZYPgGild0SL4rAUx0zgB7SCQbiYYanB1H4JtMC6mJTDwo1aezzGMT6q8Hj8dWATTZIo7zu)TSbN4CPEO1CQxt4Cqo17wBDuVgEsis9SmqZwQxd)D5OER4u)ae1ZHC3U(uF7OEEwOIoZyBNLtnarwgOzRoeF4kBWjo3OBT1rNzSTZYPgGild0SvhIpgYTZIoZyBNLtnarwgOzRoeFaT2HroAC6mJTDwo1aezzGMT6q8HbdMI5jUIXihnUUCuAteFIoJo7zuVEbPbYewKt9ijiCI63oaP(vms9gBti13oQ3iXAPPjrfDMX2olhXGU4XdersfPZm22z50H4dsmyBAsu3YcqIdzk76hpjm(n4pNKOUKysbKiltjpjukNqqqwXVb)5KevqmW6YfY8JxtI1QCcbbzf)g8NtsuHLPjroD2ZOEsRXAt60L61RwmWPl1BfN6ZvmcP(8Z4o6mJTDwoDi(WGmRW4MqiwRU9HiuOAwCijGqfhpnRxrhH5hRpltjpjukNqqqwXVb)5KevqmW6Yfo8ORjXAvoHGGSIFd(ZjjQWY0Kip0XqHcvC80SEfL480zgB7SC6q8HMmtE8iaN0TpehWv9n4pNKOYyBtcgo8ORjXAvoHGGSIFd(ZjjQWY0KiNoZyBNLthIp0qOdHV66RBFioGR6BWFojrLX2MemC4rxtI1QCcbbzf)g8NtsuHLPjroD2ZOE9UGBZaQFHD9cxh1l4SpsNzSTZYPdXhcom2lg4OZm22z50H4dbhg7fd0TSaKO20plmQHy0KbwzmD7drwMsEsOuoHGGSIFd(ZjjQGyG1Lt0rGuchE01KyTkNqqqwXVb)5KevyzAsKtNzSTZYPdXhcom2lgOBzbir9s0ffNeKiu3(qCax13G)CsIkJTnjy4WJUMeRv5eccYk(n4pNKOclttIC6mJTDwoDi(qWHXEXaDllaj(njYmPeHUOgAV0TpehWv9n4pNKOYyBtcgo8ORjXAvoHGGSIFd(ZjjQWY0KiNoZyBNLthIpgYTZs3(qKLPKNekLbdMI5jUIXihnUcIgFkC4bCvFd(ZjjQm22KGHdRjCokHsCkNIhiwK6KsyGo7zuVET11ADr9KMBOGeRL6jDs7lG0zgB7SC6q8rkSAq0EPBFiQppxfjnuqI1ghK2xavBZEf3oaJqmW6YPZ2SxXTdWqiYZvrsdfKyTXbP9fqfedSUCHoMNRIKgkiXAJds7lGkigyD5cH4NXPZm22z50H4dMjLrJTDwrz7wDllajYYuYtcLJoZyBNLthIpGcv0yBNvu2Uv3YcqIwI62hIgBBsWiwyqJorj(eDMX2olNoeFWmPmASTZkkB3QBzbiXpwiSz0z0zpJ6FUPEb1dZ12ol6mJTDwoLLiroAR4Ov8ihz2KU9HiltjpjukBizMCAWHkigyD5OZm22z5uwI6q8bhpTePZm22z5uwI6q8bo0CmOz62hIC0wXrR4roYSj12SxD9hdfkmKNgpkjgSnnjQgYu21pEsy8BWFojr6mJTDwoLLOoeFWrBfhzzl1Tpe5OTIJwXJCKztQTzV66pgkuyipnEusmyBAsunKPSRF8KW43G)CsI0zgB7SCklrDi(WXsb4hJUf2VqD7droAR4Ov8ihz2KAB2RU(Jzzk5jHszdjZKtdoubXaRlhDMX2olNYsuhIpysJqx)OtSXtcoD7droAR4Ov8ihz2KAB2RU(Jzzk5jHszdjZKtdoubXaRlhDMX2olNYsuhIpWHMJbnt3(qCusmyBAsunKPSRF8KW43G)CsI0zgB7SCklrDi(4GUfHD9JUf2VqD7droQjCoQd6we21psifkUYTg7viejBmltjpjukoAR4Ov8ihz2KcIbwxo6mJTDwoLLOoeFCq3IWU(r3c7xOU9H4AsSwLMa0TD9JUeIofwMMe5JDdOugxd(X1P0eGUTRF0Lq0jkXNgZrnHZrDq3IWU(rcPqXvU1yVcHiz0zgB7SCklrDi(GJ2koYYwQBFiQjCokNaNJvKNzGcIgBhdfkuXXtZ6vuIZrNzSTZYPSe1H4doAR4ilBPU9HOMW5OCcCowrEMbkiASD8OKyW20KOAitzx)4jHXVb)5KedhEax13G)CsIkJTnjiDMX2olNYsuhIp4OTIJSSL62hIqHQzXHKacvC80SEdHS5gRpltjpjukBizMCAWHkigyD5eD(WH5OMW5OoOBryx)iHuO4k3ASxIoxOJhLed2MMevdzk76hpjm(n4pNKiDMX2olNYsuhIpCSua(XOBH9lu3(quF95OMW5OoOBryx)iHuO4kHHXSmL8KqPSHKzYPbhQGyG1Lt05dnCyoQjCoQd6we21psifkUYTg7LOZf6ywMsEsOugmykMN4kgJC04kigyD5eDE6mJTDwoLLOoeFWKgHU(rNyJNeC62hI6Rph1eoh1bDlc76hjKcfxjmmMLPKNekLnKmton4qfedSUCIoFOHdZrnHZrDq3IWU(rcPqXvU1yVeDUqhZYuYtcLYGbtX8exXyKJgxbXaRlNOZtNzSTZYPSe1H4doAR4ilBPU9HiuOAwCijGqfhpnR3qEIugpkjgSnnjQgYu21pEsy8BWFojr6mJTDwoLLOoeFCq3IWU(r3c7xOU9HO(6RV(Cut4Cuh0TiSRFKqkuCLBn2RqMB8OAcNJsOeNYP4bIfPoPegcnCyoQjCoQd6we21psifkUYTg7viJm0XSmL8KqPSHKzYPbhQGyG1LlKrgA4WCut4Cuh0TiSRFKqkuCLBn2Rqil0XSmL8KqPmyWumpXvmg5OXvqmW6Yj680zgB7SCklrDi(GJ2koYYwQBFiokjgSnnjQgYu21pEsy8BWFojr6m6mJTDwofltjpjuoIgmykMN4kgJC040zgB7SCkwMsEsOC6q8HnKmton4qD7droQjCoQd6we21psifkUYTg7LOeNJoZyBNLtXYuYtcLthIp4g8vCHw5ojmW2ol6mJTDwofltjpjuoDi(WjeeKv8BWFojrD7drOq1S4qsaHkoEAwVHq2C0zgB7SCkwMsEsOC6q8HqjoLtXdelsDs3(qKJAcNJ6GUfHD9JesHIRCRXEfYC0zgB7SCkwMsEsOC6q8HqjoLtXdelsDs3(q0yBtcgXcdA0jkXNgRV(SmL8KqP4OTIJwXJCKztkigyD5cH4NXhp6AsSwfhpTevyzAsKhA4W6ZYuYtcLIJNwIkigyD5cH4NXhVMeRvXXtlrfwMMe5HgkDMX2olNILPKNekNoeF4sbzeI2ac1Tpexd(XvTDag3mYBmKrC8AWpUQTdW4MrEJIohDMX2olNILPKNekNoeF4sbzeI2ac1Tpe1FuO18iscwRY4CNcjnA36chgAnpIKG1Qmo3P6s0NiLqhdfkmeI6tMEQjCokHsCkNIhiwK6Ksyiu6mJTDwofltjpjuoDi(qOeNYPOMS)Ix6m6mJTDwo1hle2mIC0wXrw2sD7drnHZr5e4CSI8mduq0y74rjXGTPjr1qMYU(XtcJFd(Zjjgo8aUQVb)5KevgBBsq6mJTDwo1hle2mDi(GJ2koYYwQBFicfQMfhsciuXXtZ6neYMBS(SmL8KqPSHKzYPbhQGyG1Lt05dhMJAcNJ6GUfHD9JesHIRCRXEj6CHoEusmyBAsunKPSRF8KW43G)CsI0zgB7SCQpwiSz6q8bhTvC0kEKJmBs3(qCnjwRAaDBlXIHkSmnjYhZYuYtcLYgsMjNgCOcIbwxo6mJTDwo1hle2mDi(GJNwI62hISmL8KqPSHKzYPbhQGyG1LJoZyBNLt9XcHnthIpCSua(XOBH9lu3(quF95OMW5OoOBryx)iHuO4kHHXSmL8KqPSHKzYPbhQGyG1Lt05dnCyoQjCoQd6we21psifkUYTg7LOZf6ywMsEsOugmykMN4kgJC04kigyD5eDE6mJTDwo1hle2mDi(GjncD9JoXgpj40Tpe1xFoQjCoQd6we21psifkUsyymltjpjukBizMCAWHkigyD5eD(qdhMJAcNJ6GUfHD9JesHIRCRXEj6CHoMLPKNekLbdMI5jUIXihnUcIbwxorNNoZyBNLt9XcHnthIp4OTIJSSL62hIqHQzXHKacvC80SEd5jsz8OKyW20KOAitzx)4jHXVb)5KePZm22z5uFSqyZ0H4Jd6we21p6wy)c1Tpe1xF91NJAcNJ6GUfHD9JesHIRCRXEfYCJhvt4CucL4uofpqSi1jLWqOHdZrnHZrDq3IWU(rcPqXvU1yVczKHoMLPKNekLnKmton4qfedSUCHmYqdhMJAcNJ6GUfHD9JesHIRCRXEfczHoMLPKNekLbdMI5jUIXihnUcIbwxorNNoZyBNLt9XcHnthIp4OTIJSSL62hIJsIbBttIQHmLD9JNeg)g8NtseCnHvCcb3BhiiTTZsVdTZcwWcaa]] )

end
