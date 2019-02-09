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

    spec:RegisterPack( "Unholy", 20190208.1956, [[dSuwYaqibvpsLK2Ku0NuPQ0OOI6ucIxrfAwub3Iqu7IKFPsmmPQYXOISmvQ8mvsmnvsDnPQSnbf(MkvX4eu05KQQADQuLMNG09qK9HO6GckvlKq6HckXeLQQ4IeIKnsieFKqiXjvPQyLsvEPuvLMPGsPUPGsXorugkHqTuvQQEQQmveQRsiITsiK6RckLSxG)k0GPQdtzXuPhJQjJYLH2Sk(SQA0eQtRy1eIuVwLYSj62cSBj)w0WLshNqiPLd65KA6kDDc2oc57iy8ckPZlvwpHG5lf2psdCcqm4XSfbKDx)CQ)73D9lmvo1)9fg9lmaVTRfbVwJFZ(i4vwacEIKsCk7aVwRtMgdqm4PtbihbpX72QV3lxGgb1FwXcUcAeYZAXAv8m4IEceK2ozXH2zVONa(f3JjYmKOlTW8msuFredX73gM(Ii((J9h0wXX(BnFXBuKuItzNspbCWZvyK79PaUGhZweq2D9ZP(VF31VWu5u)3xy0VRaE6wKdi7U(Ud8epmgwaxWJHAo4DvQxKuItzh13FqBft993A(IxAVRs9I3TvFVxU8NvSGRINbx0tGG02jlo0o7f9eWV4kt3lUhtKzirxAH5zKO(IigI3Vnm9fr89h7pOTIJ93A(I3OiPeNYoLEc40ExL6frqxOGb7O(W0bQ)U(5uys9Im17u)FVx5EO9O9Uk1hweB1h13lT3vPErM6d7mgYO(WMPyuVicerrav0ExL6fzQpSKfriCrg1Vg8JBCouppl2StwAQFtQhIFbPbPEEwSzNS0kWto6vdig8(yHWHdigqMtaIbpSmxjYaIcEC4SiCmWZv4CuAbgdRilZafen(s9nP(WPEIm4yUsu1MPCQF8KW43G)StIuFJguFlUQVb)zNevgFhIqWZ47Kf4XqBfh55iblGS7aedEyzUsKbef84Wzr4yGhuOgESnjGqfdpdFwQpuQ3PRP(MuVZupptjljukRn5MSRvJkigytPPEYP((O(gnOEg6kCoQdQxeo1psifkMsVg)g1to1Fn1hc13K6dN6jYGJ5krvBMYP(XtcJFd(ZojcEgFNSapgAR4iphjybKDfaXGhwMRezarbpoCweog4TMeRv1I6DKyXrfwMRezuFtQNNPKLekL1MCt21QrfedSP0GNX3jlWJH2koAflYqU1bwazxdig8WYCLidik4XHZIWXapEMswsOuwBYnzxRgvqmWMsdEgFNSapgEgjcwaz9big8WYCLidik4XHZIWXapNPENPEg6kCoQdQxeo1psifkMsOL6Bs98mLSKqPS2KBYUwnQGyGnLM6jN67J6dH6B0G6zORW5OoOEr4u)iHuOyk9A8Bup5u)1uFiuFtQNNPKLekLbd6I5jUIXidnMcIb2uAQNCQVpWZ47Kf4P5Pa8Jr9cNBiybKfgaIbpSmxjYaIcEC4SiCmWZzQ3zQNHUcNJ6G6fHt9JesHIPeAP(MupptjljukRn5MSRvJkigytPPEYP((O(qO(gnOEg6kCoQdQxeo1psifkMsVg)g1to1Fn1hc13K65zkzjHszWGUyEIRymYqJPGyGnLM6jN67d8m(ozbECPryQFul2yjbnybKDpaIbpSmxjYaIcEC4SiCmWdkudp2MeqOIHNHpl1hk1Fx)O(MuF4uprgCmxjQAZuo1pEsy8BWF2jrWZ47Kf4XqBfh55iblGSWeqm4HL5krgquWJdNfHJbEot9ot9ot9ot9m0v4CuhuViCQFKqkumLEn(nQpuQ)AQVj1ho17kCokHsCk7IhiwIqNsOL6dH6B0G6zORW5OoOEr4u)iHuOyk9A8BuFOu)vO(qO(MupptjljukRn5MSRvJkigytPP(qP(Rq9Hq9nAq9m0v4CuhuViCQFKqkumLEn(nQpuQ3jQpeQVj1ZZuYscLYGbDX8exXyKHgtbXaBkn1to13h4z8DYc8oOEr4u)OEHZneSaY6FaXGhwMRezarbpoCweog4fo1tKbhZvIQ2mLt9JNeg)g8NDse8m(ozbEm0wXrEosWcwWJHhtqUaIbK5eGyWZ47Kf4fmflEGikci4HL5krgquWci7oaXGhwMRezarbpImPacE8mLSKqP0cbbzf)g8NDsubXaBkn1hk13h13K6xtI1Q0cbbzf)g8NDsuHL5krg4z8DYc8iYGJ5krWJidgllabV2mLt9JNeg)g8NDseSaYUcGyWdlZvImGOGhholchd8Gc1WJTjbeQy4z4Zs9Kt9HrFuFtQ3zQNNPKLekLwiiiR43G)StIkigytPP(gnO(WP(1KyTkTqqqwXVb)zNevyzUsKr9Hq9nPEOqHkgEg(Sup5KO((apJVtwGNb5wHXnHqSwWci7AaXGhwMRezarbpoCweog41IR6BWF2jrLX3HiK6B0G6dN6xtI1Q0cbbzf)g8NDsuHL5krg4z8DYc8CLzYIhbyhybK1hGyWdlZvImGOGhholchd8AXv9n4p7KOY47qes9nAq9Ht9RjXAvAHGGSIFd(ZojQWYCLid8m(ozbEUiuJWBt9blGSWaqm4z8DYc8e0yCwmqdEyzUsKbefSaYUhaXGhwMRezarbpJVtwGNB3plm6Iy0KbwzCWJdNfHJbE8mLSKqP0cbbzf)g8NDsubXaBkn1to1hg9J6B0G6dN6xtI1Q0cbbzf)g8NDsuHL5krg4vwacEUD)SWOlIrtgyLXblGSWeqm4HL5krgquWZ47Kf4jsJ6O4KGeHGhholchd8AXv9n4p7KOY47qes9nAq9Ht9RjXAvAHGGSIFd(ZojQWYCLid8klabprAuhfNeKieSaY6FaXGhwMRezarbpJVtwG33Ki3KseQJUODd84Wzr4yGxlUQVb)zNevgFhIqQVrdQpCQFnjwRsleeKv8BWF2jrfwMRezGxzbi49njYnPeH6OlA3alGmN6hGyWdlZvImGOGhholchd84zkzjHszWGUyEIRymYqJPGOX6O(gnO(wCvFd(ZojQm(oeHuFJguVRW5OekXPSlEGyjcDkHwWZ47Kf41M7KfybK5KtaIbpSmxjYaIcEC4SiCmWZzQNLRIObkiXAJTs7lGQD43I7eGrigytPPEhP(D43I7eGuFOKOEwUkIgOGeRn2kTVaQGyGnLM6dH6Bs9SCvenqbjwBSvAFbubXaBkn1hkjQ)ZzGNX3jlWlfwxiA3alGmNUdqm4HL5krgquWZ47Kf4XnPmA8DYkkh9cEYrVXYcqWJNPKLeknybK50vaedEyzUsKbef84Wzr4yGNX3HimIfgmOM6jNe1Fh4z8DYc8Gcv047Kvuo6f8KJEJLfGGNLiybK501aIbpSmxjYaIcEgFNSapUjLrJVtwr5OxWto6nwwacEFSq4WblybVwiYZaxBbediZjaXGhwMRezarblGS7aedEyzUsKbefSaYUcGyWdlZvImGOGfq21aIbpSmxjYaIcwaz9big8m(ozbET5ozbEyzUsKbefSaYcdaXGNX3jlWdAJgJm0yGhwMRezarblGS7bqm4HL5krgquWJHsRd8Ud8m(ozbEgmOlMN4kgJm0yGfSGhptjljuAaXaYCcqm4z8DYc8myqxmpXvmgzOXapSmxjYaIcwaz3big8WYCLidik4XHZIWXapg6kCoQdQxeo1psifkMsVg)g1tojQ)AWZ47Kf4zTj3KDTAeSaYUcGyWdlZvImGOGhholchd8cN6H2WIiryTkJX0kmSo6vt9nAq9qByrKiSwLXyA1uup5uVt9bEgFNSapMbVfxOv6tcdSDYQalGSRbedEyzUsKbef84Wzr4yGhuOgESnjGqfdpdFwQpuQ3PRbpJVtwGNwiiiR43G)StIGfqwFaIbpSmxjYaIcEC4SiCmWJHUcNJ6G6fHt9JesHIP0RXVr9Hs9xdEgFNSapHsCk7IhiwIqhybKfgaIbpSmxjYaIcEC4SiCmWZ47qegXcdgut9KtI6VJ6Bs9ot9ot98mLSKqPyOTIJwXImKBDkigytPP(qjr9FoJ6Bs9Ht9RjXAvm8msuHL5krg1hc13Ob17m1ZZuYscLIHNrIkigytPP(qjr9FoJ6Bs9RjXAvm8msuHL5krg1hc1hc4z8DYc8ekXPSlEGyjcDGfq29aig8WYCLidik4XHZIWXaV1GFCv7eGXnJSbP(qP(WK6Bs9Rb)4Q2jaJBgzds9Kt9xdEgFNSapDkiJq0AriybKfMaIbpSmxjYaIcEC4SiCmWZzQpCQhAdlIeH1QmgtRWW6Oxn13Ob1dTHfrIWAvgJPvtr9Kt931pQpeQVj1dfkK6dLe17m17e1lYuVRW5OekXPSlEGyjcDkHwQpeWZ47Kf4PtbzeIwlcblGS(hqm4z8DYc8ekXPSl6kNV4f8WYCLidikybl4zjcigqMtaIbpSmxjYaIcEC4SiCmWJNPKLekL1MCt21QrfedSP0GNX3jlWJH2koAflYqU1bwaz3big8m(ozbEm8mse8WYCLidikybKDfaXGhwMRezarbpoCweog4XqBfhTIfzi36u7WVn1N6Bs9qHcP(qP(7O(MuF4uprgCmxjQAZuo1pEsy8BWF2jrWZ47Kf4HTdddgoybKDnGyWdlZvImGOGhholchd8yOTIJwXImKBDQD43M6t9nPEOqHuFOu)DuFtQpCQNidoMRevTzkN6hpjm(n4p7Ki4z8DYc8yOTIJ8CKGfqwFaIbpSmxjYaIcEC4SiCmWJH2koAflYqU1P2HFBQp13K65zkzjHszTj3KDTAubXaBkn4z8DYc808ua(XOEHZneSaYcdaXGhwMRezarbpoCweog4XqBfhTIfzi36u7WVn1N6Bs98mLSKqPS2KBYUwnQGyGnLg8m(ozbECPryQFul2yjbnybKDpaIbpSmxjYaIcEC4SiCmWlCQNidoMRevTzkN6hpjm(n4p7Ki4z8DYc8W2HHbdhSaYctaXGhwMRezarbpoCweog4XqxHZrDq9IWP(rcPqXu6143O(qjr9or9nPEEMswsOum0wXrRyrgYTofedSP0GNX3jlW7G6fHt9J6fo3qWciR)bedEyzUsKbef84Wzr4yG3AsSwLRauVt9J6eIAfwMRezuFtQx3IszCn4hxTYvaQ3P(rDcrn1tojQ)oQVj1ZqxHZrDq9IWP(rcPqXu6143O(qjr9obEgFNSaVdQxeo1pQx4CdblGmN6hGyWdlZvImGOGhholchd8CfohLwGXWkYYmqbrJVuFtQhkuOIHNHpl1tojQ)AWZ47Kf4XqBfh55iblGmNCcqm4HL5krgquWJdNfHJbEUcNJslWyyfzzgOGOXxQVj1ho1tKbhZvIQ2mLt9JNeg)g8NDsK6B0G6BXv9n4p7KOY47qecEgFNSapgAR4iphjybK50DaIbpSmxjYaIcEC4SiCmWdkudp2MeqOIHNHpl1hk1701uFtQ3zQNNPKLekL1MCt21QrfedSP0up5uFFuFJgupdDfoh1b1lcN6hjKcftPxJFJ6jN6VM6dH6Bs9Ht9ezWXCLOQnt5u)4jHXVb)zNebpJVtwGhdTvCKNJeSaYC6kaIbpSmxjYaIcEC4SiCmWZzQ3zQNHUcNJ6G6fHt9JesHIPeAP(MupptjljukRn5MSRvJkigytPPEYP((O(qO(gnOEg6kCoQdQxeo1psifkMsVg)g1to1Fn1hc13K65zkzjHszWGUyEIRymYqJPGyGnLM6jN67d8m(ozbEAEka)yuVW5gcwazoDnGyWdlZvImGOGhholchd8CM6DM6zORW5OoOEr4u)iHuOykHwQVj1ZZuYscLYAtUj7A1OcIb2uAQNCQVpQpeQVrdQNHUcNJ6G6fHt9JesHIP0RXVr9Kt9xt9Hq9nPEEMswsOugmOlMN4kgJm0ykigytPPEYP((apJVtwGhxAeM6h1Inwsqdwazo1hGyWdlZvImGOGhholchd8Gc1WJTjbeQy4z4Zs9Hs931pQVj1ho1tKbhZvIQ2mLt9JNeg)g8NDse8m(ozbEm0wXrEosWciZPWaqm4HL5krgquWJdNfHJbEot9ot9ot9ot9m0v4CuhuViCQFKqkumLEn(nQpuQ)AQVj1ho17kCokHsCk7IhiwIqNsOL6dH6B0G6zORW5OoOEr4u)iHuOyk9A8BuFOu)vO(qO(MupptjljukRn5MSRvJkigytPP(qP(Rq9Hq9nAq9m0v4CuhuViCQFKqkumLEn(nQpuQ3jQpeQVj1ZZuYscLYGbDX8exXyKHgtbXaBkn1to13h4z8DYc8oOEr4u)OEHZneSaYC6EaedEyzUsKbef84Wzr4yGx4uprgCmxjQAZuo1pEsy8BWF2jrWZ47Kf4XqBfh55iblybl4rec1twaYURFofMoDNtoPC6EUg8iyWAQVg8cBf2VFYUpKjIY9s9upXIrQFcAt4s9Nes93xEMswsO03xQhIIOkmqKr96maPEtyZaBrg1ZfB1h1kAVW2tHu)vUxQxKuAH22eUiJ6n(ozr93xMbVfxOv6tcdSDYQUVkApAV7tqBcxKr99r9gFNSOE5OxTI2d8AH5zKi4DvQxKuItzh13FqBft993A(IxAVRs9I3TvFVxU8NvSGRINbx0tGG02jlo0o7f9eWV4kt3lUhtKzirxAH5zKO(IigI3Vnm9fr89h7pOTIJ93A(I3OiPeNYoLEc40ExL6frqxOGb7O(W0bQ)U(5uys9Im17u)FVx5EO9O9Uk1hweB1h13lT3vPErM6d7mgYO(WMPyuVicerrav0ExL6fzQpSKfriCrg1Vg8JBCouppl2StwAQFtQhIFbPbPEEwSzNS0kApAVRs9IuHvKlSiJ6DXtcrQNNbU2s9U4FkTI6d7Co2UAQVYsKfBWGJGK6n(ozPP(SKDkApJVtwAvle5zGRTKostFJ2Z47KLw1crEg4ARJKUCYKr7z8DYsRAHipdCT1rsxmHFawRTtw0ExL6FL1QfNl1dTHr9UcNdYOE9ARM6DXtcrQNNbU2s9U4Fkn1BfJ6BHOi3M7o1N6hn1ZYcv0EgFNS0QwiYZaxBDK0fDzTAX5g1RTAApJVtwAvle5zGRTos6sBUtw0EgFNS0QwiYZaxBDK0fOnAmYqJr7z8DYsRAHipdCT1rsxmyqxmpXvmgzOXCGHsRJ0D0E0ExL6fPcRixyrg1JeHWoQFNaK6xXi1B8nHu)OPEJiBKMRev0EgFNS0KcMIfpqefbK2Z47KL2rsxiYGJ5krhklaj1MPCQF8KW43G)StIoqKjfqs8mLSKqP0cbbzf)g8NDsubXaBkDO91CnjwRsleeKv8BWF2jrfwMRez0ExL6VFJpMu7a1FFwmq7a1BfJ6ZvmcP(8ZzAApJVtwAhjDXGCRW4MqiwRdZHeuOgESnjGqfdpdFwYdJ(A6mptjljukTqqqwXVb)zNevqmWMs3Or4RjXAvAHGGSIFd(ZojQWYCLilKMqHcvm8m8zjNuF0EgFNS0os6IRmtw8ia7CyoKAXv9n4p7KOY47qe2Or4RjXAvAHGGSIFd(ZojQWYCLiJ2Z47KL2rsxCrOgH3M67WCi1IR6BWF2jrLX3HiSrJWxtI1Q0cbbzf)g8NDsuHL5krgT3vP(WIGEZaQFHtDdxn1lOTps7z8DYs7iPlcAmolgOP9m(ozPDK0fbngNfdCOSaKKB3plm6Iy0KbwzChMdjEMswsOuAHGGSIFd(ZojQGyGnLM8WOFnAe(AsSwLwiiiR43G)StIkSmxjYO9m(ozPDK0fbngNfdCOSaKKinQJItcse6WCi1IR6BWF2jrLX3HiSrJWxtI1Q0cbbzf)g8NDsuHL5krgTNX3jlTJKUiOX4SyGdLfGK(Me5MuIqD0fTBomhsT4Q(g8NDsuz8DicB0i81KyTkTqqqwXVb)zNevyzUsKr7z8DYs7iPlT5oz5WCiXZuYscLYGbDX8exXyKHgtbrJ11OrlUQVb)zNevgFhIWgnCfohLqjoLDXdelrOtj0s7DvQpSXMATPOEr0duqI1s9IyP9fqApJVtwAhjDjfwxiA3CyoKCMLRIObkiXAJTs7lGQD43I7eGrigytPDCh(T4obyOKy5QiAGcsS2yR0(cOcIb2u6qAYYvr0afKyTXwP9fqfedSP0Hs6Zz0EgFNS0os6c3KYOX3jROC0RdLfGK4zkzjHst7z8DYs7iPlqHkA8DYkkh96qzbijlrhMdjJVdryelmyqn5KUJ2Z47KL2rsx4Mugn(ozfLJEDOSaK0hleoCApAVRs9H9uKI6H5A7KfTNX3jlTYsKedTvC0kwKHCRZH5qINPKLekL1MCt21QrfedSP00EgFNS0klrhjDHHNrI0EgFNS0klrhjDbBhggmChMdjgAR4OvSid5wNAh(TP(nHcfg6DndNidoMRevTzkN6hpjm(n4p7KiTNX3jlTYs0rsxyOTIJ8CKomhsm0wXrRyrgYTo1o8Bt9Bcfkm07AgorgCmxjQAZuo1pEsy8BWF2jrApJVtwALLOJKUO5Pa8Jr9cNBOdZHedTvC0kwKHCRtTd)2u)M8mLSKqPS2KBYUwnQGyGnLM2Z47KLwzj6iPlCPryQFul2yjbTdZHedTvC0kwKHCRtTd)2u)M8mLSKqPS2KBYUwnQGyGnLM2Z47KLwzj6iPly7WWGH7WCiforgCmxjQAZuo1pEsy8BWF2jrApJVtwALLOJKUCq9IWP(r9cNBOdZHedDfoh1b1lcN6hjKcftPxJFluso1KNPKLekfdTvC0kwKHCRtbXaBknTNX3jlTYs0rsxoOEr4u)OEHZn0H5qAnjwRYvaQ3P(rDcrTclZvISM6wukJRb)4QvUcq9o1pQtiQjN0DnzORW5OoOEr4u)iHuOyk9A8BHsYjApJVtwALLOJKUWqBfh55iDyoKCfohLwGXWkYYmqbrJVnHcfQy4z4ZsoPRP9m(ozPvwIos6cdTvCKNJ0H5qYv4CuAbgdRilZafen(2mCIm4yUsu1MPCQF8KW43G)StInA0IR6BWF2jrLX3HiK2Z47KLwzj6iPlm0wXrEoshMdjOqn8yBsaHkgEg(SH601nDMNPKLekL1MCt21QrfedSP0K3xJgm0v4CuhuViCQFKqkumLEn(nYVoKMHtKbhZvIQ2mLt9JNeg)g8NDsK2Z47KLwzj6iPlAEka)yuVW5g6WCi5SZm0v4CuhuViCQFKqkumLqBtEMswsOuwBYnzxRgvqmWMstEFH0ObdDfoh1b1lcN6hjKcftPxJFJ8RdPjptjljukdg0fZtCfJrgAmfedSP0K3hTNX3jlTYs0rsx4sJWu)OwSXscAhMdjNDMHUcNJ6G6fHt9JesHIPeABYZuYscLYAtUj7A1OcIb2uAY7lKgnyORW5OoOEr4u)iHuOyk9A8BKFDin5zkzjHszWGUyEIRymYqJPGyGnLM8(O9m(ozPvwIos6cdTvCKNJ0H5qckudp2MeqOIHNHpBO31VMHtKbhZvIQ2mLt9JNeg)g8NDsK2Z47KLwzj6iPlhuViCQFuVW5g6WCi5SZo7mdDfoh1b1lcN6hjKcftPxJFl0RBgURW5OekXPSlEGyjcDkH2qA0GHUcNJ6G6fHt9JesHIP0RXVf6vcPjptjljukRn5MSRvJkigytPd9kH0ObdDfoh1b1lcN6hjKcftPxJFluNcPjptjljukdg0fZtCfJrgAmfedSP0K3hTNX3jlTYs0rsxyOTIJ8CKomhsHtKbhZvIQ2mLt9JNeg)g8NDsK2J2Z47KLwXZuYscLMKbd6I5jUIXidngTNX3jlTINPKLekTJKUyTj3KDTA0H5qIHUcNJ6G6fHt9JesHIP0RXVroPRP9m(ozPv8mLSKqPDK0fMbVfxOv6tcdSDYQCyoKchAdlIeH1QmgtRWW6OxDJgqByrKiSwLXyA1uK7uF0EgFNS0kEMswsO0os6IwiiiR43G)StIomhsqHA4X2Kacvm8m8zd1PRP9m(ozPv8mLSKqPDK0fHsCk7IhiwIqNdZHedDfoh1b1lcN6hjKcftPxJFl0RP9m(ozPv8mLSKqPDK0fHsCk7IhiwIqNdZHKX3HimIfgmOMCs310zN5zkzjHsXqBfhTIfzi36uqmWMshkPpN1m81KyTkgEgjQWYCLilKgnCMNPKLekfdpJevqmWMshkPpN1CnjwRIHNrIkSmxjYcjeApJVtwAfptjljuAhjDrNcYieTwe6WCiTg8JRANamUzKnyOHzZ1GFCv7eGXnJSbj)AApJVtwAfptjljuAhjDrNcYieTwe6WCi5C4qByrKiSwLXyAfgwh9QB0aAdlIeH1QmgtRMI876xinHcfgkjNDsKDfohLqjoLDXdelrOtj0gcTNX3jlTINPKLekTJKUiuItzx0voFXlThTNX3jlT6JfchojgAR4iphPdZHKRW5O0cmgwrwMbkiA8Tz4ezWXCLOQnt5u)4jHXVb)zNeB0Ofx13G)StIkJVdriTNX3jlT6JfchUJKUWqBfh55iDyoKGc1WJTjbeQy4z4ZgQtx30zEMswsOuwBYnzxRgvqmWMstEFnAWqxHZrDq9IWP(rcPqXu6143i)6qAgorgCmxjQAZuo1pEsy8BWF2jrApJVtwA1hleoChjDHH2koAflYqU15WCiTMeRv1I6DKyXrfwMRezn5zkzjHszTj3KDTAubXaBknTNX3jlT6JfchUJKUWWZirhMdjEMswsOuwBYnzxRgvqmWMst7z8DYsR(yHWH7iPlAEka)yuVW5g6WCi5SZm0v4CuhuViCQFKqkumLqBtEMswsOuwBYnzxRgvqmWMstEFH0ObdDfoh1b1lcN6hjKcftPxJFJ8RdPjptjljukdg0fZtCfJrgAmfedSP0K3hTNX3jlT6JfchUJKUWLgHP(rTyJLe0omhso7mdDfoh1b1lcN6hjKcftj02KNPKLekL1MCt21QrfedSP0K3xinAWqxHZrDq9IWP(rcPqXu6143i)6qAYZuYscLYGbDX8exXyKHgtbXaBkn59r7z8DYsR(yHWH7iPlm0wXrEoshMdjOqn8yBsaHkgEg(SHEx)AgorgCmxjQAZuo1pEsy8BWF2jrApJVtwA1hleoChjD5G6fHt9J6fo3qhMdjND2zNzORW5OoOEr4u)iHuOyk9A8BHEDZWDfohLqjoLDXdelrOtj0gsJgm0v4CuhuViCQFKqkumLEn(TqVsin5zkzjHszTj3KDTAubXaBkDOxjKgnyORW5OoOEr4u)iHuOyk9A8BH6uin5zkzjHszWGUyEIRymYqJPGyGnLM8(O9m(ozPvFSq4WDK0fgAR4iphPdZHu4ezWXCLOQnt5u)4jHXVb)zNebptyfNqW7nbcsBNSclq7SGfSaa]] )

end
