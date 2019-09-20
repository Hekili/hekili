-- DeathKnightUnholy.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local roundUp = ns.roundUp

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
                start = roundUp( start, 2 )

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

                    local slot_time = query_time
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
            duration = function () return 21 * ( talent.ebon_fever.enabled and 0.5 or 1 ) end,
            tick_time = function () return 3 * ( talent.ebon_fever.enabled and 0.5 or 1 ) end,
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


    spec:RegisterStateExpr( "spreading_wounds", function ()
        if talent.infected_claws.enabled and buff.dark_transformation.up then return false end -- Ghoul is dumping wounds for us, don't bother.
        return azerite.festermight.enabled and settings.cycle and settings.festermight_cycle and cooldown.death_and_decay.remains < 9 and active_dot.festering_wound < spell_targets.festering_strike
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
    spec:RegisterPet( "apoc_ghoul", 24207, "apocalypse", 15 )


    spec:RegisterHook( "reset_precast", function ()
        local expires = action.summon_gargoyle.lastCast + 35
        if expires > now then
            summonPet( "gargoyle", expires - now )
        end

        local control_expires = action.control_undead.lastCast + 300
        if control_expires > now and pet.up and not pet.ghoul.up then
            summonPet( "controlled_undead", control_expires - now )
        end

        local apoc_expires = action.apocalypse.lastCast + 15
        if apoc_expires > now then
            summonPet( "apoc_ghoul", apoc_expires - now )
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


    -- Not actively supporting this since we just respond to the player precasting AOTD as they see fit.
    rawset( state, "death_knight", {
        disable_aotd = false,
        delay = 6
    } )


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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( pvptalent.necromancers_bargain.enabled and 45 or 90 ) end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1392565,

            handler = function ()
                summonPet( "apoc_ghoul", 15 )

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

            cycle = function ()
                if settings.cycle and settings.festermight_cycle and dot.festering_wound.stack >= 2 and active_dot.festering_wound < spell_targets.festering_strike then return "festering_wound" end
            end,
            min_ttd = function () return min( cooldown.death_and_decay.remains + 4, 8 ) end, -- don't try to cycle onto targets that will die too fast to get consumed.

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

            pvptalent = function ()
                if essence.conflict_and_strife.major then return end
                return "necrotic_strike"
            end,
            debuff = "festering_wound",

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

            cycle = 'virulent_plague',

            handler = function ()
                applyDebuff( "target", "outbreak" )
                applyDebuff( "target", "virulent_plague" )
                active_dot.virulent_plague = active_enemies
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

        cycle = true,

        potion = "potion_of_unbridled_fury",

        package = "Unholy",
    } )


    spec:RegisterSetting( "festermight_cycle", false, {
        name = "Festermight: Spread |T237530:0|t Wounds",
        desc = function ()
            return  "If checked, the addon will encourage you to spread Festering Wounds to multiple targets before |T136144:0|t Death and Decay.\n\n" ..
                    "Requires |cFF" .. ( state.azerite.festermight.enabled and "00FF00" or "FF0000" ) .. "Festermight|r (Azerite)\n" .. 
                    "Requires |cFF" .. ( state.settings.cycle and "00FF00" or "FF0000" ) .. "Recommend Target Swaps|r in |cFFFFD100Targeting|r section."
        end,
        type = "toggle",
        width = "full"
    } )  


    spec:RegisterPack( "Unholy", 20190920, [[dWuvobqiHQEequBsr8jHqAueItrO8kHIzriDlHqzxu5xeQgguPoMqPLPq5zarMgujxtiyBaH8nGq14ecvNdiW6uivMNqL7bL2NqQdcekluH4HkKQMOcPOUOqiAJabLpkec5KkKsTsG0lvifAMkKsCtHqWofs(PcPidvieQLQqkPNcYufIUkqq1wvif4RkKcAVO6VenybhMYIvWJrzYiUSQnd4ZGA0qXPLA1kK0RHkMnvDBc2TKFlA4KQJRqILd55KmDLUoPSDfPVdvnEGGCEf16vOA(a1(rAES8i5qeBppQXWDSGaCdcgd3oCdcajqc3JXH2z9ZH0ngog85qLjCoei8ct6N5q62SpncpsoKk1qSZHWSRUA0jU4W9IrBWXsbXvTGM32olgYawXvTatCo0Gw73r7IpWHi2EEuJH7ybb4gemgUD4geasJfbCXHu6NXJASimghcttiV4dCiYvmoeitdGWlmPFMggnFBXqdJgRggZsbfKPbm7QRgDIloCVy0gCSuqCvlO5TTZIHmGvCvlWeNckitdqxFVWWr0Wy4wuAymChliGckfuqMgg9ySc(QrhfuqMgIy0aigHCcnerOlcnacd9p(DuqbzAiIrdJ(SME0EcnSgc(RSbObwwKE7Su0WM0a6WAEdrdSSi92zPCuqbzAiIrdqPWPHuFBHECB7SOHeGgaHD1EKqdJzPHUObqSrtrKooKVvRIhjh6k1l2v8i5rflpso0lBWFcFeoed17rTXHqA1DBlC5MYyPHOPbygHgMqdiTQzs9e)r0qC0aUWnhYyBNfhs4cjAwMasVgRjsc6MGIV8OgJhjh6Ln4pHpchIH69O24qIqdSm9KeF5i3wmsRisYz2SdDbRlfnmHgu637LRHG)QCKBlgPvej5mBMgIMgILgeJgadMgeHgyz6jj(Yroq7VdDbRlfnmHgu637LRHG)QCKd0(tdrtdXsdIrdGbtdIqdSm9KeF5m9Kz(zD1DOlyDPOHj0altpjXxoYTfJ0kIKCMn7q3iZ0GyCiJTDwCObFMezcixmx(6cZ8LhfiXJKd9Yg8NWhHdXq9EuBCirObwMEsIVCMEYm)SU6o0fSUu0qC0aiIgMqdSm9KeF5mKWSmbKlMlj3io0fSUu0q00altpjXxowwKxQtK(g4ajIDh6cwxkAqmAamyAGLPNK4lNHeMLjGCXCj5gXHUG1LIgIJggJdzSTZIdbRzisBLmbK24hLlg(YJcx8i5qVSb)j8r4qmuVh1ghAqdaWHodh)vkjqIy3PPtdGbtddAaao0z44Vsjbse7swQv7ro1AmCOH4OHyJLdzSTZIdTyUuRgsTIibse78Lhve4rYHEzd(t4JWHyOEpQnou80a52IrAfrsoZMDBZWPlyoKX2oloeqY0uNiTXpQ3lhUjWxEuGiEKCOx2G)e(iCigQ3JAJdrY1XYI9Ar2EIeWBcxoOHkh6cwxkAalnGBoKX2oloell2Rfz7jsaVjC(YJceNhjh6Ln4pHpchIH69O24qXtdKBlgPvej5mB2TndNUG5qgB7S4q6AOgyUly5G3ulF5rfX5rYHEzd(t4JWHyOEpQnou80a52IrAfrsoZMDBZWPlyoKX2oloe(e5jtFxs0vzzf78LhfiGhjh6Ln4pHpchIH69O24qXtdKBlgPvej5mB2TndNUG5qgB7S4qOwx3FzxsLUXoF5lhICatZV8i5rflpsoKX2oloKqxeja6F8ZHEzd(t4JWxEuJXJKd9Yg8NWhHdL6Ci1xoKX2olo0ud12G)COPMx7CiwMEsIVCknbHSKWgcoN93HUG1LIgIJgIanmHgwZ)ADknbHSKWgcoN939Yg8NWHMAizzcNdPNPVlyjqIKWgcoN9NV8OajEKCOx2G)e(iCigQ3JAJdH0QMj1t8h5ihOz9sdrtdGOiqdtObrOb9VoydbNZ(7m22tpnagmnepnSM)16uAcczjHneCo7V7Ln4pHgeJgMqdiT6oYbAwV0q0yPHiWHm22zXHmeZQl3eHET8LhfU4rYHEzd(t4JWHyOEpQnoK(xhSHGZz)DgB7PNgadMgINgwZ)ADknbHSKWgcoN939Yg8NWHm22zXHg8zsKaAOz(YJkc8i5qVSb)j8r4qmuVh1ghAqdaWPvys)Sea9A8zNMonagmnO)1bBi4C2FNX2E6PbWGPH4PH18VwNstqiljSHGZz)DVSb)jCiJTDwCOHJuhHtxW8LhfiIhjh6Ln4pHpchIH69O24qBlCAiAAymCtdGbtdXtdFu0AD9tCitqVlyPjO77vJCjCdBtt)kFb31PbWGPH4PHpkATU(jUPTQZsMasYfA15qgB7S4qAQl79ck(YJceNhjh6Ln4pHpchYyBNfhYgxHXqMscK1ktaPEI)ioed17rTXHeHgUs9ID30w1zjtaP(raNTDwobButenmHgINgwZ)ADAfM0plbqVgF29Yg8NqdIrdGbtdIqdXtdxPEXUJLf5L6ePVboqIy3jyJAIOHj0q80WvQxS7M2Qolzci1pc4STZYjyJAIObX4qLjCoKnUcJHmLeiRvMas9e)r8LhveNhjh6Ln4pHpchYyBNfhYgxHXqMscK1ktaPEI)ioed17rTXHyz6jj(Yz6jZ8Z6Q7qxW6srdXrdXIlAycnicnCL6f7owwKxQtK(g4ajIDNGnQjIgadMgUs9ID30w1zjtaP(raNTDwobButenmHgwZ)ADAfM0plbqVgF29Yg8NqdIXHkt4CiBCfgdzkjqwRmbK6j(J4lpkqapso0lBWFcFeoKX2oloKnUcJHmLeiRvMas9e)rCigQ3JAJdTTWLBkj9PH4ObwMEsIVCMEYm)SU6o0fSUu0qm0aiHlouzcNdzJRWyitjbYALjGupXFeF5rflU5rYHEzd(t4JWHm22zXHmfMPwDLezJNijlrMNdXq9EuBCiYh0aaCiB8ejzjY8sYh0aaCQ1y4qdXrdXYHkt4CitHzQvxjr24jsYsK55lpQyJLhjh6Ln4pHpchYyBNfhYuyMA1vsKnEIKSezEoed17rTXH0)6G1mePTsMasB8JYfJZyBp90WeAq)RZ0tMegtQ5DgB7PNdvMW5qMcZuRUsISXtKKLiZZxEuXogpso0lBWFcFeoKX2oloKPWm1QRKiB8ejzjY8CigQ3JAJdXY0ts8LZ0tM5N1v3HUrMPHj0Gi0WvQxS7yzrEPor6BGdKi2Dc2OMiAycnSTWLBkj9PH4ObwMEsIVCSSiVuNi9nWbse7o0fSUu0qm0Wy4MgadMgINgUs9IDhllYl1jsFdCGeXUtWg1erdIXHkt4CitHzQvxjr24jsYsK55lpQybjEKCOx2G)e(iCiJTDwCitHzQvxjr24jsYsK55qmuVh1ghABHl3us6tdXrdSm9KeF5m9Kz(zD1DOlyDPOHyOHXWnhQmHZHmfMPwDLezJNijlrMNV8OIfx8i5qVSb)j8r4qgB7S4qtBvNLmbKKl0QZHyOEpQnoKi0altpjXxotpzMFwxDh6gzMgMqdKpOba4aUApQlyj(uRio1AmCOHOXsd4IgMqdxPEXUBAR6SKjGu)iGZ2ol3lBWFcnignagmnmOba40kmPFwcGEn(SttNgadMg0)6GneCo7VZyBp9COYeohAAR6SKjGKCHwD(YJk2iWJKd9Yg8NWhHdzSTZIdHmb9UGLMGUVxnYLWnSnn9R8fCxNdXq9EuBCiwMEsIVCMEYm)SU6o0fSUu0qC0Wy0ayW0WA(xRZqcZYeqUyUKyc1jUx2G)eAamyAaznr(PVwNrikxx0qC0qe4qLjCoeYe07cwAc6(E1ixc3W200VYxWDD(YJkwqepso0lBWFcFeoKX2olo0WmCwxo8lnVGvgJdXq9EuBCiwMEsIVCknbHSKWgcoN93HUG1LIgIMgar4MgadMgINgwZ)ADknbHSKWgcoN939Yg8NqdtOHTfonennmgUPbWGPH4PHpkATU(joKjO3fS0e099QrUeUHTPPFLVG76COYeohAygoRlh(LMxWkJXxEuXcIZJKd9Yg8NWhHdzSTZIdnQxjXK49hXHyOEpQnoK(xhSHGZz)DgB7PNgadMgINgwZ)ADknbHSKWgcoN939Yg8NqdtOHTfonennmgUPbWGPH4PHpkATU(joKjO3fS0e099QrUeUHTPPFLVG76COYeohAuVsIjX7pIV8OInIZJKd9Yg8NWhHdzSTZIdbB(ZmV)iLC4goCigQ3JAJdP)1bBi4C2FNX2E6PbWGPH4PH18VwNstqiljSHGZz)DVSb)j0WeAyBHtdrtdJHBAamyAiEA4JIwRRFIdzc6DblnbDFVAKlHByBA6x5l4UohQmHZHGn)zM3FKsoCdh(YJkwqapso0lBWFcFeoKX2oloemklyLuh1cMxIm4ZHyOEpQnoesRonehwAaKOHj0Gi0W2cNgIMggd30ayW0q80WhfTwx)ehYe07cwAc6(E1ixc3W200VYxWDDAqmouzcNdbJYcwj1rTG5Lid(8Lh1y4Mhjh6Ln4pHpchIH69O24qSm9KeF5mKWSmbKlMlj3io0nYmnagmnO)1bBi4C2FNX2E6PbWGPHbnaaNwHj9Zsa0RXNDA6CiJTDwCi9C7S4lpQXILhjh6Ln4pHpchIH69O24qKCDtBKM)1k19gS2DOlyDPOH4WsdWmchYyBNfhk12b0nC4lpQXgJhjh6Ln4pHpchYyBNfhIzEV0yBNL03QLd5B1klt4CORuVyxXxEuJbs8i5qVSb)j8r4qgB7S4qmZ7LgB7SK(wTCiFRwzzcNdXY0ts8LIV8Ogdx8i5qVSb)j8r4qmuVh1ghYyBp9YxxOVIgIglnmghYyBNfhcPvsJTDwsFRwoKVvRSmHZHS88Lh1yrGhjh6Ln4pHpchYyBNfhIzEV0yBNL03QLd5B1klt4Ci4xh1m(YxoKo6SuyWwEK8OILhjhYyBNfhsp3olo0lBWFcFe(YJAmEKCiJTDwCiK1Qlj3iCOx2G)e(i8LhfiXJKd9Yg8NWhHdvMW5q24kmgYusGSwzci1t8hXHm22zXHSXvymKPKazTYeqQN4pIV8OWfpso0lBWFcFeoe5EBMdnghYyBNfhYqcZYeqUyUKCJWx(YHyz6jj(sXJKhvS8i5qgB7S4qgsywMaYfZLKBeo0lBWFcFe(YJAmEKCOx2G)e(iCigQ3JAJdr(GgaGd4Q9OUGL4tTI4uRXWHgIglnGloKX2oloKPNmZpRRoF5rbs8i5qVSb)j8r4qmuVh1ghkEAaznr(PVwNrik3bHA1QObWGPbK1e5N(ADgHOCDrdrtdXgboKX2oloeXq4ixKvkGejyBNfF5rHlEKCOx2G)e(iCigQ3JAJdH0QMj1t8h5ihOz9sdXrdXIloKX2oloKstqiljSHGZz)5lpQiWJKd9Yg8NWhHdXq9EuBCORuVy3nTvDwYeqQFeWzBNL7Ln4pHgadMgeHgUs9IDhllYl1jsFdCGeXU7Ln4pHgMqd6FDMEYKWysnVZyBp90Gy0ayW0a5dAaaoGR2J6cwIp1kItTgdhAioAax0WeAiEAqeA4JIwRRFIdzc6DblnbDFVAKlHByBA6x5l4UonagmnyJFuV3jyWAkzcixmxsUrCVSb)j0Gy0ayW0altpjXxotpzMFwxDh6cwxkAioAymAycnicn8rrR11pXHmb9UGLMGUVxnYLWnSnn9R8fCxNgadMgSXpQ37emynLmbKlMlj3iUx2G)eAqmoKX2oloKwHj9Zsa0RXN5lpkqepso0lBWFcFeoed17rTXHm22tV81f6ROHOXsdJrdtObrObrObwMEsIVCKBlgPvej5mB2HUG1LIgIdlnaZi0WeAiEAyn)R1roq7V7Ln4pHgeJgadMgeHgyz6jj(Yroq7VdDbRlfnehwAaMrOHj0WA(xRJCG2F3lBWFcnignighYyBNfhsRWK(zja614Z8Lhfiopso0lBWFcFeoKX2oloKk18s0n9J4qmuVh1ghAne8x32cxUPK0NgIJgI40WeAyne8x32cxUPK0NgIMgWfhInZ8xUgc(RIhvS8LhveNhjh6Ln4pHpchIH69O24qIqdXtdiRjYp916mcr5oiuRwfnagmnGSMi)0xRZieLRlAiAAymCtdIrdtObKwDAioS0Gi0qS0qeJgg0aaCAfM0plbqVgF2PPtdIXHm22zXHuPMxIUPFeF5rbc4rYHm22zXH0kmPFwo4Bymlh6Ln4pHpcF5lhYYZJKhvS8i5qVSb)j8r4qmuVh1ghILPNK4lNPNmZpRRUdDbRlfhYyBNfhICBXiTIijNzZ8Lh1y8i5qgB7S4qKd0(ZHEzd(t4JWxEuGepso0lBWFcFeoed17rTXHi3wmsRisYz2SBBgoDbtdtObKwDAioAymAycnepnm1qTn4VtptFxWsGejHneCo7phYyBNfh66n5cnJV8OWfpso0lBWFcFeoed17rTXHi3wmsRisYz2SBBgoDbtdtObKwDAioAymAycnepnm1qTn4VtptFxWsGejHneCo7phYyBNfhICBXizz75lpQiWJKd9Yg8NWhHdXq9EuBCiYTfJ0kIKCMn72MHtxW0WeAGLPNK4lNPNmZpRRUdDbRlfhYyBNfhsXsne8LQf14C(YJceXJKd9Yg8NWhHdXq9EuBCiYTfJ0kIKCMn72MHtxW0WeAGLPNK4lNPNmZpRRUdDbRlfhYyBNfhI5n8DblvymsIxXxEuG48i5qVSb)j8r4qmuVh1ghkEAyQHABWFNEM(UGLajscBi4C2FoKX2olo01BYfAgF5rfX5rYHEzd(t4JWHm22zXHaUApQlyPArnoNdXq9EuBCiYh0aaCaxTh1fSeFQveNAngo0qCyPHyPHj0altpjXxoYTfJ0kIKCMn7qxW6sXHyZm)LRHG)Q4rflF5rbc4rYHEzd(t4JWHyOEpQno0A(xRBqdP2UGLQeDL7Ln4pHgMqdk979Y1qWFvUbnKA7cwQs0v0q0yPHXOHj0a5dAaaoGR2J6cwIp1kItTgdhAioS0qSCiJTDwCiGR2J6cwQwuJZ5lpQyXnpso0lBWFcFeoed17rTXHg0aaCknc5LKKPGdDJT0WeAaPv3roqZ6LgIglnGloKX2oloe52IrYY2ZxEuXglpso0lBWFcFeoed17rTXHg0aaCknc5LKKPGdDJT0WeAiEAyQHABWFNEM(UGLajscBi4C2FAamyAq)Rd2qW5S)oJT90ZHm22zXHi3wmsw2E(YJk2X4rYHEzd(t4JWHyOEpQnoesRAMupXFKJCGM1lnehnelUOHj0Gi0altpjXxotpzMFwxDh6cwxkAiAAic0ayW0a5dAaaoGR2J6cwIp1kItTgdhAiAAax0Gy0WeAiEAyQHABWFNEM(UGLajscBi4C2FoKX2oloe52IrYY2ZxEuXcs8i5qVSb)j8r4qmuVh1ghseAqeAG8bnaahWv7rDblXNAfXPPtdtObwMEsIVCMEYm)SU6o0fSUu0q00qeObXObWGPbYh0aaCaxTh1fSeFQveNAngo0q00aUObXOHj0Gi0altpjXxodjmlta5I5sYnIdDbRlfnennebAamyAGCBXiXPAymRJ0kBWFPLlHgeJdzSTZIdPyPgc(s1IACoF5rflU4rYHEzd(t4JWHyOEpQnoKi0Gi0a5dAaaoGR2J6cwIp1kIttNgMqdSm9KeF5m9Kz(zD1DOlyDPOHOPHiqdIrdGbtdKpOba4aUApQlyj(uRio1AmCOHOPbCrdIrdtObrObwMEsIVCgsywMaYfZLKBeh6cwxkAiAAic0ayW0a52IrIt1WywhPv2G)slxcnighYyBNfhI5n8DblvymsIxXxEuXgbEKCOx2G)e(iCigQ3JAJdH0QMj1t8h5ihOz9sdXrdJHBAycnepnm1qTn4VtptFxWsGejHneCo7phYyBNfhICBXizz75lpQybr8i5qVSb)j8r4qmuVh1ghseAqeAqeAqeAG8bnaahWv7rDblXNAfXPwJHdnehnGlAycnepnmOba40kmPFwcGEn(SttNgeJgadMgiFqdaWbC1EuxWs8PwrCQ1y4qdXrdGenignmHgyz6jj(Yz6jZ8Z6Q7qxW6srdXrdGenignagmnq(GgaGd4Q9OUGL4tTI4uRXWHgIJgILgeJgMqdIqdSm9KeF5mKWSmbKlMlj3io0fSUu0q00qeObWGPbYTfJeNQHXSosRSb)LwUeAqmoKX2oloeWv7rDblvlQX58LhvSG48i5qVSb)j8r4qmuVh1ghkEAyQHABWFNEM(UGLajscBi4C2FoKX2oloe52IrYY2Zx(YHGFDuZ4rYJkwEKCOx2G)e(iCigQ3JAJdnOba4uAeYljjtbh6gBPHj0q80Wud12G)o9m9DblbsKe2qW5S)0ayW0G(xhSHGZz)DgB7PNdzSTZIdrUTyKSS98Lh1y8i5qVSb)j8r4qmuVh1ghcPvntQN4pYroqZ6LgIJgIfx0WeAqeAGLPNK4lNPNmZpRRUdDbRlfnennebAamyAG8bnaahWv7rDblXNAfXPwJHdnennGlAqmAycnepnm1qTn4VtptFxWsGejHneCo7phYyBNfhICBXizz75lpkqIhjh6Ln4pHpchIH69O24qR5FTo9R22)ID3lBWFcnmHgyz6jj(Yz6jZ8Z6Q7qxW6sXHm22zXHi3wmsRisYz2mF5rHlEKCOx2G)e(iCigQ3JAJdXY0ts8LZ0tM5N1v3HUG1LIdzSTZIdroq7pF5rfbEKCOx2G)e(iCigQ3JAJdjcnicnq(GgaGd4Q9OUGL4tTI400PHj0altpjXxotpzMFwxDh6cwxkAiAAic0Gy0ayW0a5dAaaoGR2J6cwIp1kItTgdhAiAAax0Gy0WeAqeAGLPNK4lNHeMLjGCXCj5gXHUG1LIgIMgIanagmnqUTyK4unmM1rALn4V0YLqdIXHm22zXHuSudbFPArnoNV8Oar8i5qVSb)j8r4qmuVh1ghseAqeAG8bnaahWv7rDblXNAfXPPtdtObwMEsIVCMEYm)SU6o0fSUu0q00qeObXObWGPbYh0aaCaxTh1fSeFQveNAngo0q00aUObXOHj0Gi0altpjXxodjmlta5I5sYnIdDbRlfnennebAamyAGCBXiXPAymRJ0kBWFPLlHgeJdzSTZIdX8g(UGLkmgjXR4lpkqCEKCOx2G)e(iCigQ3JAJdH0QMj1t8h5ihOz9sdXrdJHBAycnepnm1qTn4VtptFxWsGejHneCo7phYyBNfhICBXizz75lpQiopso0lBWFcFeoed17rTXHeHgeHgeHgeHgiFqdaWbC1EuxWs8PwrCQ1y4qdXrd4IgMqdXtddAaaoTct6NLaOxJp700PbXObWGPbYh0aaCaxTh1fSeFQveNAngo0qC0airdIrdtObwMEsIVCMEYm)SU6o0fSUu0qC0airdIrdGbtdKpOba4aUApQlyj(uRio1AmCOH4OHyPbXOHj0Gi0altpjXxodjmlta5I5sYnIdDbRlfnennebAamyAGCBXiXPAymRJ0kBWFPLlHgeJdzSTZIdbC1EuxWs1IACoF5rbc4rYHEzd(t4JWHyOEpQnou80Wud12G)o9m9DblbsKe2qW5S)CiJTDwCiYTfJKLTNV8LVCOPhP6S4rngUJfeG7iESGioeEdvDbR4qJgcInAnQr7OIiA0rd0qKyon0c6jAPbGerdruYbmn)grPb0hfTgDcnOsHtdM2Mc2EcnWWyf8vokOJw660aiy0rdJ(SME0Ecnerxdb)1fRBBHl3us6hrPHnPHi62cxUPK0pIsdIeliKyokOJw660qSG0OJgg9zn9O9eAiIUgc(Rlw32cxUPK0pIsdBsdr0TfUCtjPFeLgejwqiXCuqPGoAlONO9eAaerdgB7SObFRwLJckhshLaT)CiqMgaHxys)mnmA(2IHggnwnmMLckitdy2vxn6exC4EXOn4yPG4QwqZBBNfdzaR4QwGjofuqMgGU(EHHJOHXWTO0Wy4owqafukOGmnm6Xyf8vJokOGmneXObqmc5eAiIqxeAaeg6F87OGcY0qeJgg9zn9O9eAyne8xzdqdSSi92zPOHnPb0H18gIgyzr6TZs5OGcY0qeJgGsHtdP(2c9422zrdjanac7Q9iHggZsdDrdGyJMIiDuqPGcY0qeji0zA7j0WWbs0PbwkmylnmC4UuoAaeJXU(QOHkRiggdjaO5PbJTDwkAil)SJckitdgB7SuoD0zPWGTyb8MchkOGmnySTZs50rNLcd2gdwXbYKqbfKPbJTDwkNo6SuyW2yWkUPbl8ATTZIckitdqLPRWKlnGSMqddAaaNqdQ1wfnmCGeDAGLcd2sddhUlfnyfHg0rpIPN72fmn0kAGK1DuqbzAWyBNLYPJolfgSngSIRktxHjxPATvrb1yBNLYPJolfgSngSIRNBNffuJTDwkNo6SuyW2yWkoYA1LKBekOgB7SuoD0zPWGTXGvCn1L9Ebrlt4yTXvymKPKazTYeqQN4pIcQX2olLthDwkmyBmyf3qcZYeqUyUKCJik5EBg7yuqPGcY0qeji0zA7j0WNE0mnSTWPHfZPbJTjIgAfnytT2Bd(7OGASTZsHvOlIea9p(PGASTZsfdwXNAO2g8x0Yeow9m9DblbsKe2qW5S)Io18AhlltpjXxoLMGqwsydbNZ(7qxW6sfxeMSM)16uAcczjHneCo7V7Ln4pHckitdJwnwBELO0WO9EbLO0GveAixmhrdjmJOOGASTZsfdwXneZQl3eHETI2ayrAvZK6j(JCKd0SEJgefHjIO)1bBi4C2FNX2E6bdo(18VwNstqiljSHGZz)DVSb)jInbPv3roqZ6nASrGcQX2olvmyfFWNjrcOHMfTbWQ)1bBi4C2FNX2E6bdo(18VwNstqiljSHGZz)DVSb)juqn22zPIbR4dhPocNUGfTbWoOba40kmPFwcGEn(Stthmy9VoydbNZ(7m22tpyWXVM)16uAcczjHneCo7V7Ln4pHckitdJEn1Mc0WI6cNVkAqtzWNcQX2olvmyfxtDzVxqjAdGDBHh9y4gm44)OO166N4qMGExWstq33Rg5s4g2MM(v(cURdgC8Fu0AD9tCtBvNLmbKKl0Qtb1yBNLkgSIRPUS3liAzchRnUcJHmLeiRvMas9e)rI2ayf5k1l2DtBvNLmbK6hbC22z5eSrnrtIFn)R1Pvys)Sea9A8z3lBWFIyGbls8xPEXUJLf5L6ePVboqIy3jyJAIMe)vQxS7M2Qolzci1pc4STZYjyJAIeJcQX2olvmyfxtDzVxq0YeowBCfgdzkjqwRmbK6j(JeTbWYY0ts8LZ0tM5N1v3HUG1LkUyX1erUs9IDhllYl1jsFdCGeXUtWg1ebg8vQxS7M2Qolzci1pc4STZYjyJAIMSM)160kmPFwcGEn(S7Ln4prmkOgB7SuXGvCn1L9Ebrlt4yTXvymKPKazTYeqQN4ps0ga7Ai4VUyDBlC5Mss)4yz6jj(Yz6jZ8Z6Q7qxW6sfdiHlkOgB7SuXGvCn1L9Ebrlt4ynfMPwDLezJNijlrMx0gal5dAaaoKnEIKSezEj5dAaao1AmCIlwkOgB7SuXGvCn1L9Ebrlt4ynfMPwDLezJNijlrMx0gaR(xhSMHiTvYeqAJFuUyCgB7PFI(xNPNmjmMuZ7m22tpfuJTDwQyWkUM6YEVGOLjCSMcZuRUsISXtKKLiZlAdGLLPNK4lNPNmZpRRUdDJmprKRuVy3XYI8sDI03ahirS7eSrnrt2w4YnLK(XXY0ts8LJLf5L6ePVboqIy3HUG1LkMXWnyWXFL6f7owwKxQtK(g4ajIDNGnQjsmkOgB7SuXGvCn1L9Ebrlt4ynfMPwDLezJNijlrMx0ga7Ai4VUyDBlC5Mss)4yz6jj(Yz6jZ8Z6Q7qxW6sfZy4McQX2olvmyfxtDzVxq0Yeo2PTQZsMasYfA1fTbWkcltpjXxotpzMFwxDh6gzEc5dAaaoGR2J6cwIp1kItTgdNOXIRjxPEXUBAR6SKjGu)iGZ2ol3lBWFIyGbpOba40kmPFwcGEn(Stthmy9VoydbNZ(7m22tpfuJTDwQyWkUM6YEVGOLjCSitqVlyPjO77vJCjCdBtt)kFb31fTbWYY0ts8LZ0tM5N1v3HUG1LkUXadEn)R1ziHzzcixmxsmH6e3lBWFcyWiRjYp916mcr56kUiqb1yBNLkgSIRPUS3liAzch7WmCwxo8lnVGvgt0galltpjXxoLMGqwsydbNZ(7qxW6sfnic3Gbh)A(xRtPjiKLe2qW5S)Ux2G)KjBl8Ohd3Gbh)hfTwx)ehYe07cwAc6(E1ixc3W200VYxWDDkOgB7SuXGvCn1L9Ebrlt4yh1RKys8(JeTbWQ)1bBi4C2FNX2E6bdo(18VwNstqiljSHGZz)DVSb)jt2w4rpgUbdo(pkATU(joKjO3fS0e099QrUeUHTPPFLVG76uqn22zPIbR4AQl79cIwMWXcB(ZmV)iLC4goI2ay1)6GneCo7VZyBp9Gbh)A(xRtPjiKLe2qW5S)Ux2G)KjBl8Ohd3Gbh)hfTwx)ehYe07cwAc6(E1ixc3W200VYxWDDkOgB7SuXGvCn1L9Ebrlt4yHrzbRK6OwW8sKbFrBaSiT6XHfKMiY2cp6XWnyWX)rrR11pXHmb9UGLMGUVxnYLWnSnn9R8fCxxmkOgB7SuXGvC9C7SeTbWYY0ts8LZqcZYeqUyUKCJ4q3iZGbR)1bBi4C2FNX2E6bdEqdaWPvys)Sea9A8zNMofuqMgIiyDTwxDbtdJg0in)RLgIi2BWANgAfny0GoQtuVZuqn22zPIbR4P2oGUHJOnawsUUPnsZ)AL6Edw7o0fSUuXHfMrOGASTZsfdwXzM3ln22zj9TAfTmHJ9k1l2vuqn22zPIbR4mZ7LgB7SK(wTIwMWXYY0ts8LIcQX2olvmyfhPvsJTDwsFRwrlt4yT8I2ayn22tV81f6RIg7yuqn22zPIbR4mZ7LgB7SK(wTIwMWXc)6OMrbLckitdGyzejnGY12olkOgB7SuolpwYTfJ0kIKCMnlAdGLLPNK4lNPNmZpRRUdDbRlffuJTDwkNLpgSItoq7pfuJTDwkNLpgSIF9MCHMjAdGLCBXiTIijNzZUTz40f8eKw94gBs8tnuBd(70Z03fSeirsydbNZ(tb1yBNLYz5JbR4KBlgjlBVOnawYTfJ0kIKCMn72MHtxWtqA1JBSjXp1qTn4VtptFxWsGejHneCo7pfuJTDwkNLpgSIRyPgc(s1IACUOnawYTfJ0kIKCMn72MHtxWtyz6jj(Yz6jZ8Z6Q7qxW6srb1yBNLYz5JbR4mVHVlyPcJrs8krBaSKBlgPvej5mB2TndNUGNWY0ts8LZ0tM5N1v3HUG1LIcQX2olLZYhdwXVEtUqZeTbWg)ud12G)o9m9DblbsKe2qW5S)uqn22zPCw(yWkoWv7rDblvlQX5IYMz(lxdb)vHnwrBaSKpOba4aUApQlyj(uRio1AmCIdBStyz6jj(YrUTyKwrKKZSzh6cwxkkOgB7SuolFmyfh4Q9OUGLQf14CrBaSR5FTUbnKA7cwQs0vUx2G)Kjk979Y1qWFvUbnKA7cwQs0vrJDSjKpOba4aUApQlyj(uRio1AmCIdBSuqn22zPCw(yWko52IrYY2lAdGDqdaWP0iKxssMco0n2obPv3roqZ6nAS4IcQX2olLZYhdwXj3wmsw2ErBaSdAaaoLgH8ssYuWHUX2jXp1qTn4VtptFxWsGejHneCo7pyW6FDWgcoN93zSTNEkOgB7SuolFmyfNCBXizz7fTbWI0QMj1t8h5ihOz9gxS4AIiSm9KeF5m9Kz(zD1DOlyDPIocGbt(GgaGd4Q9OUGL4tTI4uRXWjACj2K4NAO2g83PNPVlyjqIKWgcoN9NcQX2olLZYhdwXvSudbFPArnox0gaRiIq(GgaGd4Q9OUGL4tTI400NWY0ts8LZ0tM5N1v3HUG1Lk6iigyWKpOba4aUApQlyj(uRio1AmCIgxInrewMEsIVCgsywMaYfZLKBeh6cwxQOJayWKBlgjovdJzDKwzd(lTCjIrb1yBNLYz5JbR4mVHVlyPcJrs8krBaSIic5dAaaoGR2J6cwIp1kIttFcltpjXxotpzMFwxDh6cwxQOJGyGbt(GgaGd4Q9OUGL4tTI4uRXWjACj2eryz6jj(YziHzzcixmxsUrCOlyDPIocGbtUTyK4unmM1rALn4V0YLigfuJTDwkNLpgSItUTyKSS9I2ayrAvZK6j(JCKd0SEJBmCpj(PgQTb)D6z67cwcKijSHGZz)PGASTZs5S8XGvCGR2J6cwQwuJZfTbWkIiIic5dAaaoGR2J6cwIp1kItTgdN4W1K4h0aaCAfM0plbqVgF2PPlgyWKpOba4aUApQlyj(uRio1AmCIdKeBcltpjXxotpzMFwxDh6cwxQ4ajXadM8bnaahWv7rDblXNAfXPwJHtCXk2eryz6jj(YziHzzcixmxsUrCOlyDPIocGbtUTyK4unmM1rALn4V0YLigfuJTDwkNLpgSItUTyKSS9I2ayJFQHABWFNEM(UGLajscBi4C2FkOuqn22zPCSm9KeFPWAiHzzcixmxsUrOGASTZs5yz6jj(sfdwXn9Kz(zD1fTbWs(GgaGd4Q9OUGL4tTI4uRXWjAS4IcQX2olLJLPNK4lvmyfNyiCKlYkfqIeSTZs0gaB8iRjYp916mcr5oiuRwfyWiRjYp916mcr56k6yJafuJTDwkhltpjXxQyWkUstqiljSHGZz)fTbWI0QMj1t8h5ihOz9gxS4IcQX2olLJLPNK4lvmyfxRWK(zja614ZI2ayVs9ID30w1zjtaP(raNTDwUx2G)eWGf5k1l2DSSiVuNi9nWbse7Ux2G)Kj6FDMEYKWysnVZyBp9Ibgm5dAaaoGR2J6cwIp1kItTgdN4W1K4f5JIwRRFIdzc6DblnbDFVAKlHByBA6x5l4UoyW24h17DcgSMsMaYfZLKBe3lBWFIyGbZY0ts8LZ0tM5N1v3HUG1LkUXMiYhfTwx)ehYe07cwAc6(E1ixc3W200VYxWDDWGTXpQ37emynLmbKlMlj3iUx2G)eXOGASTZs5yz6jj(sfdwX1kmPFwcGEn(SOnawJT90lFDH(QOXo2ereHLPNK4lh52IrAfrsoZMDOlyDPIdlmJmj(18Vwh5aT)Ux2G)eXadwewMEsIVCKd0(7qxW6sfhwygzYA(xRJCG2F3lBWFIyIrb1yBNLYXY0ts8LkgSIRsnVeDt)irzZm)LRHG)QWgROna21qWFDBlC5Mss)4I4twdb)1TTWLBkj9Jgxuqn22zPCSm9KeFPIbR4QuZlr30ps0gaRiXJSMi)0xRZieL7GqTAvGbJSMi)0xRZieLRROhd3InbPvpoSIeBeBqdaWPvys)Sea9A8zNMUyuqn22zPCSm9KeFPIbR4AfM0plh8nmMLckfuJTDwk3vQxSRWkCHenltaPxJ1ejbDtqjAdGfPv3TTWLBkJnAygzcsRAMupXFuC4c3uqn22zPCxPEXUkgSIp4ZKita5I5Yxxyw0gaRiSm9KeF5i3wmsRisYz2SdDbRl1eL(9E5Ai4Vkh52IrAfrsoZMJowXadwewMEsIVCKd0(7qxW6snrPFVxUgc(RYroq7F0XkgyWIWY0ts8LZ0tM5N1v3HUG1LAcltpjXxoYTfJ0kIKCMn7q3iZIrb1yBNLYDL6f7QyWkoSMHiTvYeqAJFuUyeTbWkcltpjXxotpzMFwxDh6cwxQ4artyz6jj(YziHzzcixmxsUrCOlyDPIMLPNK4lhllYl1jsFdCGeXUdDbRlLyGbZY0ts8LZqcZYeqUyUKCJ4qxW6sf3yuqn22zPCxPEXUkgSIVyUuRgsTIibse7I2ayh0aaCOZWXFLscKi2DA6GbpOba4qNHJ)kLeirSlzPwTh5uRXWjUyJLcQX2olL7k1l2vXGvCGKPPorAJFuVxoCtq0gaB8KBlgPvej5mB2TndNUGPGASTZs5Us9IDvmyfNLf71IS9ejG3eUOnawsUowwSxlY2tKaEt4Ybnu5qxW6sHf3uqn22zPCxPEXUkgSIRRHAG5UGLdEtTI2ayJNCBXiTIijNzZUTz40fmfuJTDwk3vQxSRIbR44tKNm9DjrxLLvSlAdGnEYTfJ0kIKCMn72MHtxWuqn22zPCxPEXUkgSIJADD)LDjv6g7I2ayJNCBXiTIijNzZUTz40fmfukOgB7Suo4xh1mSKBlgjlBVOna2bnaaNsJqEjjzk4q3y7K4NAO2g83PNPVlyjqIKWgcoN9hmy9VoydbNZ(7m22tpfuJTDwkh8RJAwmyfNCBXizz7fTbWI0QMj1t8h5ihOz9gxS4AIiSm9KeF5m9Kz(zD1DOlyDPIocGbt(GgaGd4Q9OUGL4tTI4uRXWjACj2K4NAO2g83PNPVlyjqIKWgcoN9NcQX2olLd(1rnlgSItUTyKwrKKZSzrBaSR5FTo9R22)ID3lBWFYewMEsIVCMEYm)SU6o0fSUuuqn22zPCWVoQzXGvCYbA)fTbWYY0ts8LZ0tM5N1v3HUG1LIcQX2olLd(1rnlgSIRyPgc(s1IACUOnawreH8bnaahWv7rDblXNAfXPPpHLPNK4lNPNmZpRRUdDbRlv0rqmWGjFqdaWbC1EuxWs8PwrCQ1y4enUeBIiSm9KeF5mKWSmbKlMlj3io0fSUurhbWGj3wmsCQggZ6iTYg8xA5seJcQX2olLd(1rnlgSIZ8g(UGLkmgjXReTbWkIiKpOba4aUApQlyj(uRion9jSm9KeF5m9Kz(zD1DOlyDPIocIbgm5dAaaoGR2J6cwIp1kItTgdNOXLyteHLPNK4lNHeMLjGCXCj5gXHUG1Lk6iagm52IrIt1WywhPv2G)slxIyuqn22zPCWVoQzXGvCYTfJKLTx0galsRAMupXFKJCGM1BCJH7jXp1qTn4VtptFxWsGejHneCo7pfuJTDwkh8RJAwmyfh4Q9OUGLQf14CrBaSIiIiIq(GgaGd4Q9OUGL4tTI4uRXWjoCnj(bnaaNwHj9Zsa0RXNDA6Ibgm5dAaaoGR2J6cwIp1kItTgdN4ajXMWY0ts8LZ0tM5N1v3HUG1LkoqsmWGjFqdaWbC1EuxWs8PwrCQ1y4exSInrewMEsIVCgsywMaYfZLKBeh6cwxQOJayWKBlgjovdJzDKwzd(lTCjIrb1yBNLYb)6OMfdwXj3wmsw2ErBaSXp1qTn4VtptFxWsGejHneCo7phY0wmjIdb1cAEB7Sg9idy5lF5C]] )

end
