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

    spec:RegisterPack( "Unholy", 20190214.1150, [[dye0XaqiPipsveBsQYOeKofPuVIu0SifUfPeTls(LQWWKc5yeILPkQNHiX0KI6AsbBtku(gPemovrY5qKI1rkHMNG4Ei0(quDqePKfsi9qsjLjkfQ6IKsI2OQivNuvKIvkv1lLcvUjIuQDIOmuePQLIivEQknveXvjLuTvvrkTxG)k0GPQdtzXKQhJQjJYLH2Sk(SQA0eQtRy1KscVwvYSj62cSBj)w0WLklh0ZPY0v66eSDvP(ocgpPK05LsRhrsZxqTFKgicGeWLzlci75gjcPPrplsZkrePHg1GwaC32oeC7m(l7JGBzbi4Q1lXPSfC7SwzAmajGRlfGCeCfVBNtl(4b0iO(ZkwqxWHqEwlwRINbpCtGG02jlo0o7d3eWFOFmTKHVF0bZZir3dspejD2WCpi9KUyJhTvCSXvZx8g16L4u2QCtahC1fg5(0uaDWLzlci75gjcPPrplsZkrePHgrkpf466qoGSNB4zWv8Wyyb0bxg64G7tOETEjoLTuFJhTvm134Q5lEP9Fc1lE3oNw8XJ)SIf0v8m4HBceK2ozXH2zF4Ma(dDzQ)q)yAjdF)OdMNrIUhKEis6SH5Eq6jDXgpAR4yJRMV4nQ1lXPSv5MaoT)tO(NoQdfmyl1lsZAq9p3irEkQxlPErerl2qJO9P9Fc1R1eB1hDArA)Nq9Aj1tAXyiJ6jTNIr9pDiIKkQO9Fc1RLuVwlR3iCrg1Vg8JBCouppl2StwoQFtQhIFbPbPEEwSzNSCkWvoU1bibC)yHWHdibqMiasaxSmDjYaIcUC4SiCmWvx4CuobgdRilZafen(s99O(MO(3gCmDjQ6Yuo1pEsy8BWF2krQpCyQVdx13G)SvIkJVZBeCn(ozbUm0wXrEosWci7zajGlwMUezarbxoCweog4cfQHh7sciuXWZWNL6dH6fPzQVh1hk1ZZuYscLY6sUjB7COcIb2uoQNCQVbQpCyQNH6cNJ6GUfHt9JesHIPCRXFr9Kt9nt9At99O(MO(3gCmDjQ6Yuo1pEsy8BWF2krW147Kf4YqBfh55iblGmsbqc4ILPlrgquWLdNfHJbURjXAvDOBhjwCuHLPlrg13J65zkzjHszDj3KTDoubXaBkh4A8DYcCzOTIJwXImKBTGfqwZasaxSmDjYaIcUC4SiCmWLNPKLekL1LCt225qfedSPCGRX3jlWLHNrIGfqwdasaxSmDjYaIcUC4SiCmWnuQpuQNH6cNJ6GUfHt9JesHIPe6O(EupptjljukRl5MSTZHkigyt5OEYP(gOETP(WHPEgQlCoQd6weo1psifkMYTg)f1to13m1Rn13J65zkzjHszWG2yEIRymYqJPGyGnLJ6jN6BaCn(ozbUoEka)y0TW5fcwazngGeWfltxImGOGlholchdCdL6dL6zOUW5OoOBr4u)iHuOykHoQVh1ZZuYscLY6sUjB7COcIb2uoQNCQVbQxBQpCyQNH6cNJ6GUfHt9JesHIPCRXFr9Kt9nt9At99OEEMswsOugmOnMN4kgJm0ykigyt5OEYP(gaxJVtwGlxAeM6hDInwsWbwazAbajGlwMUezarbxoCweog4cfQHh7sciuXWZWNL6dH6FUruFpQVjQ)TbhtxIQUmLt9JNeg)g8NTseCn(ozbUm0wXrEosWci7PaKaUyz6sKbefC5Wzr4yGBOuFOuFOuFOupd1foh1bDlcN6hjKcft5wJ)I6dH6BM67r9nr96cNJsOeNY24bIfP2Qe6OETP(WHPEgQlCoQd6weo1psifkMYTg)f1hc1tkuV2uFpQNNPKLekL1LCt225qfedSPCuFiupPq9At9Hdt9mux4Cuh0TiCQFKqkumLBn(lQpeQxeQxBQVh1ZZuYscLYGbTX8exXyKHgtbXaBkh1to13a4A8DYcCpOBr4u)OBHZleSaYinasaxSmDjYaIcUC4SiCmWTjQ)TbhtxIQUmLt9JNeg)g8NTseCn(ozbUm0wXrEosWcwWLHhtqUasaKjcGeW147Kf4gmflEGisQi4ILPlrgquWci7zajGlwMUezarb33MuabxEMswsOuoHGGSIFd(ZwjQGyGnLJ6dH6BG67r9RjXAvoHGGSIFd(ZwjQWY0LidCn(ozbUVn4y6seCFBWyzbi42LPCQF8KW43G)SvIGfqgPaibCXY0Lidik4YHZIWXaxOqn8yxsaHkgEg(Sup5uFJ1a13J6dL65zkzjHs5eccYk(n4pBLOcIb2uoQpCyQVjQFnjwRYjeeKv8BWF2krfwMUezuV2uFpQhkuOIHNHpl1torQVbW147Kf4AqUvyCtieRfSaYAgqc4ILPlrgquWLdNfHJbUD4Q(g8NTsuz8DEJuF4WuFtu)AsSwLtiiiR43G)SvIkSmDjYaxJVtwGRUmtw8iaBblGSgaKaUyz6sKbefC5Wzr4yGBhUQVb)zRevgFN3i1hom13e1VMeRv5eccYk(n4pBLOcltxImW147Kf4QJqhcFn1hSaYAmajGRX3jlWvWHXzXah4ILPlrgquWcitlaibCXY0Lidik4A8DYcC1B)zHrDeJMmWkJdUC4SiCmWLNPKLekLtiiiR43G)SvIkigyt5OEYP(gRruF4WuFtu)AsSwLtiiiR43G)SvIkSmDjYa3YcqWvV9Nfg1rmAYaRmoybK9uasaxSmDjYaIcUgFNSaxTc0ffNeKieC5Wzr4yGBhUQVb)zRevgFN3i1hom13e1VMeRv5eccYk(n4pBLOcltxImWTSaeC1kqxuCsqIqWciJ0aibCXY0Lidik4A8DYcC)Me5MuIqxuhTxGlholchdC7Wv9n4pBLOY478gP(WHP(MO(1KyTkNqqqwXVb)zRevyz6sKbULfGG73Ki3Kse6I6O9cSaYePrasaxSmDjYaIcUC4SiCmWLNPKLekLbdAJ5jUIXidnMcIgRL6dhM67Wv9n4pBLOY478gP(WHPEDHZrjuItzB8aXIuBvcDGRX3jlWTl3jlWciteraKaUyz6sKbefC5Wzr4yGBOuplx17bkiXAJDs7lGQD4VI7eGrigyt5OEnP(D4VI7eGuFiePEwUQ3duqI1g7K2xavqmWMYr9At99OEwUQ3duqI1g7K2xavqmWMYr9HqK6)Cg4A8DYcCtHvhI2lWcitKNbKaUyz6sKbefCn(ozbUCtkJgFNSIYXTGRCCBSSaeC5zkzjHYbwazIqkasaxSmDjYaIcUC4SiCmW1478gJyHbd6OEYjs9pdUgFNSaxOqfn(ozfLJBbx542yzbi4AjcwazI0mGeWfltxImGOGRX3jlWLBsz047KvuoUfCLJBJLfGG7hleoCWcwWTdI8mq3wajaYebqc4ILPlrgquWci7zajGlwMUezarblGmsbqc4ILPlrgquWciRzajGlwMUezarblGSgaKaUgFNSa3UCNSaxSmDjYaIcwazngGeW147Kf4cTXHrgAmWfltxImGOGfqMwaqc4ILPlrgquWLHsRfCFgCn(ozbUgmOnMN4kgJm0yGfSGlptjljuoajaYebqc4A8DYcCnyqBmpXvmgzOXaxSmDjYaIcwazpdibCXY0Lidik4YHZIWXaxgQlCoQd6weo1psifkMYTg)f1torQVzW147Kf4ADj3KTDoeSaYifajGlwMUezarbxoCweog42e1dTHfX3yTkJXCkuRoU1r9Hdt9qByr8nwRYymNAkQNCQxKgaxJVtwGlZGVIl0k3jHb2ozbwazndibCXY0Lidik4YHZIWXaxOqn8yxsaHkgEg(SuFiuVindUgFNSaxNqqqwXVb)zReblGSgaKaUyz6sKbefC5Wzr4yGld1foh1bDlcN6hjKcft5wJ)I6dH6BgCn(ozbUcL4u2gpqSi1wWciRXaKaUyz6sKbefC5Wzr4yGRX35ngXcdg0r9KtK6FM67r9Hs9Hs98mLSKqPyOTIJwXImKBTkigyt5O(qis9FoJ67r9nr9RjXAvm8msuHLPlrg1Rn1hom1hk1ZZuYscLIHNrIkigyt5O(qis9FoJ67r9RjXAvm8msuHLPlrg1Rn1Rn4A8DYcCfkXPSnEGyrQTGfqMwaqc4ILPlrgquWLdNfHJbURb)4Q2jaJBgzds9Hq9pf13J6xd(XvTtag3mYgK6jN6BgCn(ozbUUuqgHO1HqWci7PaKaUyz6sKbefC5Wzr4yGBOuFtup0gweFJ1QmgZPqT64wh1hom1dTHfX3yTkJXCQPOEYP(NBe1Rn13J6Hcfs9HqK6dL6fH61sQxx4CucL4u2gpqSi1wLqh1Rn4A8DYcCDPGmcrRdHGfqgPbqc4A8DYcCfkXPSnQlNV4fCXY0Lidikybl4AjcibqMiasaxSmDjYaIcUC4SiCmWLNPKLekL1LCt225qfedSPCGRX3jlWLH2koAflYqU1cwazpdibCn(ozbUm8mseCXY0LidikybKrkasaxSmDjYaIcUC4SiCmWLH2koAflYqU1Q2H)AQp13J6Hcfs9Hq9pt99O(MO(3gCmDjQ6Yuo1pEsy8BWF2krW147Kf4IDdddgoybK1mGeWfltxImGOGlholchdCzOTIJwXImKBTQD4VM6t99OEOqHuFiu)ZuFpQVjQ)TbhtxIQUmLt9JNeg)g8NTseCn(ozbUm0wXrEosWciRbajGlwMUezarbxoCweog4YqBfhTIfzi3Av7WFn1N67r98mLSKqPSUKBY2ohQGyGnLdCn(ozbUoEka)y0TW5fcwazngGeWfltxImGOGlholchdCzOTIJwXImKBTQD4VM6t99OEEMswsOuwxYnzBNdvqmWMYbUgFNSaxU0im1p6eBSKGdSaY0casaxSmDjYaIcUC4SiCmWTjQ)TbhtxIQUmLt9JNeg)g8NTseCn(ozbUy3WWGHdwazpfGeWfltxImGOGlholchdCzOUW5OoOBr4u)iHuOyk3A8xuFiePErO(EupptjljukgAR4OvSid5wRcIb2uoW147Kf4Eq3IWP(r3cNxiybKrAaKaUyz6sKbefC5Wzr4yG7AsSwLUa0Tt9JUeIofwMUezuFpQ31HszCn4hxNsxa62P(rxcrh1torQ)zQVh1ZqDHZrDq3IWP(rcPqXuU14VO(qis9IaUgFNSa3d6weo1p6w48cblGmrAeGeWfltxImGOGlholchdC1fohLtGXWkYYmqbrJVuFpQhkuOIHNHpl1torQVzW147Kf4YqBfh55iblGmrebqc4ILPlrgquWLdNfHJbU6cNJYjWyyfzzgOGOXxQVh13e1)2GJPlrvxMYP(XtcJFd(Zwjs9Hdt9D4Q(g8NTsuz8DEJGRX3jlWLH2koYZrcwazI8mGeWfltxImGOGlholchdCHc1WJDjbeQy4z4Zs9Hq9I0m13J6dL65zkzjHszDj3KTDoubXaBkh1to13a1hom1ZqDHZrDq3IWP(rcPqXuU14VOEYP(MPETP(EuFtu)BdoMUevDzkN6hpjm(n4pBLi4A8DYcCzOTIJ8CKGfqMiKcGeWfltxImGOGlholchdCdL6dL6zOUW5OoOBr4u)iHuOykHoQVh1ZZuYscLY6sUjB7COcIb2uoQNCQVbQxBQpCyQNH6cNJ6GUfHt9JesHIPCRXFr9Kt9nt9At99OEEMswsOugmOnMN4kgJm0ykigyt5OEYP(gaxJVtwGRJNcWpgDlCEHGfqMindibCXY0Lidik4YHZIWXa3qP(qPEgQlCoQd6weo1psifkMsOJ67r98mLSKqPSUKBY2ohQGyGnLJ6jN6BG61M6dhM6zOUW5OoOBr4u)iHuOyk3A8xup5uFZuV2uFpQNNPKLekLbdAJ5jUIXidnMcIb2uoQNCQVbW147Kf4YLgHP(rNyJLeCGfqMinaibCXY0Lidik4YHZIWXaxOqn8yxsaHkgEg(SuFiu)ZnI67r9nr9Vn4y6su1LPCQF8KW43G)SvIGRX3jlWLH2koYZrcwazI0yasaxSmDjYaIcUC4SiCmWnuQpuQpuQpuQNH6cNJ6GUfHt9JesHIPCRXFr9Hq9nt99O(MOEDHZrjuItzB8aXIuBvcDuV2uF4Wupd1foh1bDlcN6hjKcft5wJ)I6dH6jfQxBQVh1ZZuYscLY6sUjB7COcIb2uoQpeQNuOETP(WHPEgQlCoQd6weo1psifkMYTg)f1hc1lc1Rn13J65zkzjHszWG2yEIRymYqJPGyGnLJ6jN6BaCn(ozbUh0TiCQF0TW5fcwazIOfaKaUyz6sKbefC5Wzr4yGBtu)BdoMUevDzkN6hpjm(n4pBLi4A8DYcCzOTIJ8CKGfSGfCFJq3KfGSNBKiKMg9CJEkLiKMgAmWLGbRP(oW9PjOlHlYO(gOEJVtwuVCCRtr7dUDW8mseCFc1R1lXPSL6B8OTIP(gxnFXlT)tOEX7250IpE8NvSGUINbpCtGG02jlo0o7d3eWFOlt9h6htlz47hDW8ms09G0drsNnm3dspPl24rBfhBC18fVrTEjoLTk3eWP9Fc1)0rDOGbBPErAwdQ)5gjYtr9Aj1lIiAXgAeTpT)tOETMyR(Otls7)eQxlPEslgdzupP9umQ)PdrKurfT)tOETK61Az9gHlYO(1GFCJZH65zXMDYYr9Bs9q8lini1ZZIn7KLtr7t7)eQxRuRICHfzuVoEsis98mq3wQxh)t5uupPfNJDRJ6RS0sXgm4iiPEJVtwoQplzRI2347KLt1brEgOBlXJ0CVO9n(oz5uDqKNb62QjXhNmz0(gFNSCQoiYZaDB1K4dt4hG1A7KfT)tO(BzDoX5s9qByuVUW5GmQ3T26OED8KqK65zGUTuVo(NYr9wXO(oiQLD5Ut9P(Xr9SSqfTVX3jlNQdI8mq3wnj(WvwNtCUr3ARJ2347KLt1brEgOBRMeF0L7KfTVX3jlNQdI8mq3wnj(aAJdJm0y0(gFNSCQoiYZaDB1K4ddg0gZtCfJrgAmnyO0Aj(mTpT)tOETsTkYfwKr94Be2s97eGu)kgPEJVjK6hh1BVTrA6sur7B8DYYrmykw8arKurAFJVtwonj(4TbhtxIAuwasSlt5u)4jHXVb)zRe14TjfqI8mLSKqPCcbbzf)g8NTsubXaBkxin0BnjwRYjeeKv8BWF2krfwMUez0(pH6jDgFmPtdQ)PzXaNguVvmQpxXiK6ZpN5O9n(oz50K4ddYTcJBcHyTAmhIqHA4XUKacvm8m8zjVXAOxO8mLSKqPCcbbzf)g8NTsubXaBkx4WnTMeRv5eccYk(n4pBLOcltxImT7bfkuXWZWNLCInq7B8DYYPjXh6YmzXJaSvJ5qSdx13G)SvIkJVZBmC4MwtI1QCcbbzf)g8NTsuHLPlrgTVX3jlNMeFOJqhcFn1xJ5qSdx13G)SvIkJVZBmC4MwtI1QCcbbzf)g8NTsuHLPlrgT)tOETMGBZaQFHt9cxh1l4Sps7B8DYYPjXhcomolg4O9n(oz50K4dbhgNfd0OSaKOE7plmQJy0KbwzCnMdrEMswsOuoHGGSIFd(ZwjQGyGnLJ8gRrHd30AsSwLtiiiR43G)SvIkSmDjYO9n(oz50K4dbhgNfd0OSaKOwb6IItcseQXCi2HR6BWF2krLX35ngoCtRjXAvoHGGSIFd(ZwjQWY0LiJ2347KLttIpeCyCwmqJYcqIFtICtkrOlQJ2lnMdXoCvFd(ZwjQm(oVXWHBAnjwRYjeeKv8BWF2krfwMUez0(gFNSCAs8rxUtwAmhI8mLSKqPmyqBmpXvmgzOXuq0yTHd3HR6BWF2krLX35ngoSUW5OekXPSnEGyrQTkHoA)Nq9K22uRnf1)0oqbjwl1t6L2xaP9n(oz50K4Juy1HO9sJ5qmuwUQ3duqI1g7K2xav7WFf3jaJqmWMYP5o8xXDcWqiYYv9EGcsS2yN0(cOcIb2uoT7XYv9EGcsS2yN0(cOcIb2uUqi(5mAFJVtwonj(GBsz047KvuoUvJYcqI8mLSKq5O9n(oz50K4dOqfn(ozfLJB1OSaKOLOgZHOX35ngXcdg0roXNP9n(oz50K4dUjLrJVtwr54wnklaj(XcHdN2N2)jupPvQvs9WCTDYI2347KLtzjsKH2koAflYqU1QXCiYZuYscLY6sUjB7COcIb2uoAFJVtwoLLOMeFWWZirAFJVtwoLLOMeFGDdddgUgZHidTvC0kwKHCRvTd)1u)EqHcd55En92GJPlrvxMYP(XtcJFd(Zwjs7B8DYYPSe1K4dgAR4iphPgZHidTvC0kwKHCRvTd)1u)EqHcd55En92GJPlrvxMYP(XtcJFd(Zwjs7B8DYYPSe1K4dhpfGFm6w48c1yoezOTIJwXImKBTQD4VM63JNPKLekL1LCt225qfedSPC0(gFNSCklrnj(Glnct9JoXglj40yoezOTIJwXImKBTQD4VM63JNPKLekL1LCt225qfedSPC0(gFNSCklrnj(a7gggmCnMdXMEBWX0LOQlt5u)4jHXVb)zReP9n(oz5uwIAs8XbDlcN6hDlCEHAmhImux4Cuh0TiCQFKqkumLBn(RqikspEMswsOum0wXrRyrgYTwfedSPC0(gFNSCklrnj(4GUfHt9JUfoVqnMdX1KyTkDbOBN6hDjeDkSmDjY656qPmUg8JRtPlaD7u)OlHOJCIp3JH6cNJ6GUfHt9JesHIPCRXFfcrrO9n(oz5uwIAs8bdTvCKNJuJ5qux4CuobgdRilZafen(2dkuOIHNHpl5eBM2347KLtzjQjXhm0wXrEosnMdrDHZr5eymSISmduq04BVMEBWX0LOQlt5u)4jHXVb)zRedhUdx13G)SvIkJVZBK2347KLtzjQjXhm0wXrEosnMdrOqn8yxsaHkgEg(SHisZ9cLNPKLekL1LCt225qfedSPCK3q4Wmux4Cuh0TiCQFKqkumLBn(lYBw7En92GJPlrvxMYP(XtcJFd(Zwjs7B8DYYPSe1K4dhpfGFm6w48c1yoednugQlCoQd6weo1psifkMsORhptjljukRl5MSTZHkigyt5iVbTdhMH6cNJ6GUfHt9JesHIPCRXFrEZA3JNPKLekLbdAJ5jUIXidnMcIb2uoYBG2347KLtzjQjXhCPryQF0j2yjbNgZHyOHYqDHZrDq3IWP(rcPqXucD94zkzjHszDj3KTDoubXaBkh5nOD4Wmux4Cuh0TiCQFKqkumLBn(lYBw7E8mLSKqPmyqBmpXvmgzOXuqmWMYrEd0(gFNSCklrnj(GH2koYZrQXCicfQHh7sciuXWZWNnKNBuVMEBWX0LOQlt5u)4jHXVb)zReP9n(oz5uwIAs8XbDlcN6hDlCEHAmhIHgAOHYqDHZrDq3IWP(rcPqXuU14VcP5EnPlCokHsCkBJhiwKARsOt7WHzOUW5OoOBr4u)iHuOyk3A8xHqkA3JNPKLekL1LCt225qfedSPCHqkAhomd1foh1bDlcN6hjKcft5wJ)ker0Uhptjljukdg0gZtCfJrgAmfedSPCK3aTVX3jlNYsutIpyOTIJ8CKAmhIn92GJPlrvxMYP(XtcJFd(Zwjs7t7B8DYYP4zkzjHYr0GbTX8exXyKHgJ2347KLtXZuYscLttIpSUKBY2ohQXCiYqDHZrDq3IWP(rcPqXuU14ViNyZ0(gFNSCkEMswsOCAs8bZGVIl0k3jHb2ozPXCi2e0gweFJ1QmgZPqT64wx4WqByr8nwRYymNAkYfPbAFJVtwofptjljuonj(WjeeKv8BWF2krnMdrOqn8yxsaHkgEg(SHisZ0(gFNSCkEMswsOCAs8HqjoLTXdelsTvJ5qKH6cNJ6GUfHt9JesHIPCRXFfsZ0(gFNSCkEMswsOCAs8HqjoLTXdelsTvJ5q0478gJyHbd6iN4Z9cnuEMswsOum0wXrRyrgYTwfedSPCHq8Zz9AAnjwRIHNrIkSmDjY0oC4q5zkzjHsXWZirfedSPCHq8Zz9wtI1Qy4zKOcltxImT1M2347KLtXZuYscLttIpCPGmcrRdHAmhIRb)4Q2jaJBgzdgYt1Bn4hx1obyCZiBqYBM2347KLtXZuYscLttIpCPGmcrRdHAmhIH2e0gweFJ1QmgZPqT64wx4WqByr8nwRYymNAkYFUrA3dkuyiedveTux4CucL4u2gpqSi1wLqN20(gFNSCkEMswsOCAs8HqjoLTrD58fV0(0(gFNSCQpwiC4ezOTIJ8CKAmhI6cNJYjWyyfzzgOGOX3En92GJPlrvxMYP(XtcJFd(ZwjgoChUQVb)zRevgFN3iTVX3jlN6JfchUMeFWqBfh55i1yoeHc1WJDjbeQy4z4ZgIin3luEMswsOuwxYnzBNdvqmWMYrEdHdZqDHZrDq3IWP(rcPqXuU14ViVzT710BdoMUevDzkN6hpjm(n4pBLiTVX3jlN6JfchUMeFWqBfhTIfzi3A1yoextI1Q6q3osS4OcltxISE8mLSKqPSUKBY2ohQGyGnLJ2347KLt9XcHdxtIpy4zKOgZHiptjljukRl5MSTZHkigyt5O9n(oz5uFSq4W1K4dhpfGFm6w48c1yoednugQlCoQd6weo1psifkMsORhptjljukRl5MSTZHkigyt5iVbTdhMH6cNJ6GUfHt9JesHIPCRXFrEZA3JNPKLekLbdAJ5jUIXidnMcIb2uoYBG2347KLt9XcHdxtIp4sJWu)OtSXsconMdXqdLH6cNJ6GUfHt9JesHIPe66XZuYscLY6sUjB7COcIb2uoYBq7WHzOUW5OoOBr4u)iHuOyk3A8xK3S294zkzjHszWG2yEIRymYqJPGyGnLJ8gO9n(oz5uFSq4W1K4dgAR4iphPgZHiuOgESljGqfdpdF2qEUr9A6TbhtxIQUmLt9JNeg)g8NTsK2347KLt9XcHdxtIpoOBr4u)OBHZluJ5qm0qdnugQlCoQd6weo1psifkMYTg)vin3RjDHZrjuItzB8aXIuBvcDAhomd1foh1bDlcN6hjKcft5wJ)kesr7E8mLSKqPSUKBY2ohQGyGnLlesr7WHzOUW5OoOBr4u)iHuOyk3A8xHiI294zkzjHszWG2yEIRymYqJPGyGnLJ8gO9n(oz5uFSq4W1K4dgAR4iphPgZHytVn4y6su1LPCQF8KW43G)SvIGRjSIti4ENabPTtwAnODwWcwaa]] )

end
