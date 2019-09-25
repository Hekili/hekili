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

                start = start or 0
                duration = duration or ( 10 * state.haste )
                
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


    spec:RegisterPack( "Unholy", 20190925, [[dW0JobqifIhbvInPi(KqkAuqvofuvVsO0SiuULqk1UOYViunmHuDmHKLPq6zqL00asDnOsTnGe9nGKY4esjNdijRtHszEcvUhuAFcfheiPAHcv9qGemrfkHUOqk0gbsiFuifuNuHsQvceVuHsKzQqjQBkKcStHOFQqjPHQqjOLQqjXtbzQcHRcKqTvHuq(QcLa7fv)LObl4WuwScEmktgXLvTzaFguJgkoTuRwHcVgQy2u1Tjy3s(TOHtkhxHIwoKNtY0v66KQTRi9Dcz8kuQoVIA9kunFGA)inpkEeCiITNh5Orpkqv0bvJcAxurROgf3Gso0oRDoKMXWXGphQmHZHafxys)mhsZM9Pr4rWHuPoIDoeMD1uJnXfhUxm6dowkiUQf0922zXqgWkUQfyIZHg0B)owx8boeX2ZJC0OhfOk6GQrbTlQOvuJI7r5qkTZ4rokUhLdHPjKx8boe5kghcxObqXfM0ptdJfVTyOHXsvdJzPGGl0aMD1uJnXfhUxm6dowkiUQf0922zXqgWkUQfyItbbxObORTxy4iAyuClgnmA0JcurbHccUqdGcySc(QXgfeCHgI20aOoHCcnenOlcnakc9p(DuqWfAiAtdGczn9O9eAyne8xzdqdSSi92zPOHnPb0H19gIgyzr6TZs5OGGl0q0MgGsHtdP22c9422zrdjanak6Q9iHggZsdDrdG6JvJgDCiFRwfpco0vQxSR4rWJmkEeCOx2G)eE8CigQ3JAJdH0R72w4YnLrrdXqdWmcnmHgq6vZKAPOJOH4ObqhDoKX2oloKWfs0SmbKEDwtKe0nbfF5rokpco0lBWFcpEoed17rTXHWJgyz6jPOYrUTyKwrKKZSzh6cwxkAycnO0U3lxdb)v5i3wmsRisYz2mnednefnGpnagmnGhnWY0tsrLJCG2Fh6cwxkAycnO0U3lxdb)v5ihO9NgIHgIIgWNgadMgWJgyz6jPOYzAjZ8ZAQ7qxW6srdtObwMEskQCKBlgPvej5mB2HUrMPb85qgB7S4qd(mjYeqUyU81fM5lpsCLhbh6Ln4pHhphIH69O24q4rdSm9Kuu5mTKz(zn1DOlyDPOH4ObqjnmHgyz6jPOYziHzzcixmxsUrCOlyDPOHyObwMEskQCSSiVuNi9nWbse7o0fSUu0a(0ayW0altpjfvodjmlta5I5sYnIdDbRlfnehnmkhYyBNfhcw3qK2kzciTXpkxm8LhjO5rWHEzd(t4XZHyOEpQno0GoaGdDgo(RusGeXUtxJgadMgg0baCOZWXFLscKi2LSuV2JCQ1y4qdXrdrffhYyBNfhAXCPEnK6frcKi25lpsCZJGd9Yg8NWJNdXq9EuBCOrObYTfJ0kIKCMn72MHtxWCiJTDwCiGKPRorAJFuVxoCtGV8ibL8i4qVSb)j845qmuVh1ghIKRJLf71IS9ejG3eUCqhvo0fSUu0awAi6CiJTDwCiwwSxlY2tKaEt48LhjOgpco0lBWFcpEoed17rTXHgHgi3wmsRisYz2SBBgoDbZHm22zXH00rnWCxWYbVPw(YJmAXJGd9Yg8NWJNdXq9EuBCOrObYTfJ0kIKCMn72MHtxWCiJTDwCirjYtM(UKORYYk25lpsqfpco0lBWFcpEoed17rTXHgHgi3wmsRisYz2SBBgoDbZHm22zXHqTMM)YUKknJD(Yxoe5aMUF5rWJmkEeCiJTDwCiHUisa0)4Nd9Yg8NWJNV8ihLhbh6Ln4pHhphk14qQVCiJTDwCOPgQTb)5qtnV(5qSm9Kuu5u6cczjHneCo7VdDbRlfnehnGBAycnSM)16u6cczjHneCo7V7Ln4pHdn1qYYeohsltFxWsGejHneCo7pF5rIR8i4qVSb)j845qmuVh1ghcPxntQLIoYroqZ6LgIHgaL4MgMqd4rdAFDWgcoN93zSTNEAamyAyeAyn)R1P0feYscBi4C2F3lBWFcnGpnmHgq61DKd0SEPHyWsd4MdzSTZIdziMvxUjc9A5lpsqZJGd9Yg8NWJNdXq9EuBCiTVoydbNZ(7m22tpnagmnmcnSM)16u6cczjHneCo7V7Ln4pHdzSTZIdn4ZKib0rZ8LhjU5rWHEzd(t4XZHyOEpQno0GoaGtVWK(zja614ZoDnAamyAq7Rd2qW5S)oJT90tdGbtd4rdR5FTodjmlta5I5sIjuN4Ezd(tOHj0G2xNPLmjmMu37m22tpnGphYyBNfhA4i1r40fmF5rck5rWHEzd(t4XZHyOEpQno02cNgIHggn60ayW0Wi0Wht9wt7ehYe06cwAcA(E1jxc3W200VYxWDDAamyAyeA4JPERPDIBAR6SKjGKCHwDoKX2oloKU6YEVGIV8ib14rWHEzd(t4XZHm22zXHSXvymKPKazTYeqQLIoIdXq9EuBCi8OHRuVy3nTvDwYeqQDeWzBNLtWgJerdtOHrOH18VwNEHj9Zsa0RXNDVSb)j0a(0ayW0aE0Wi0WvQxS7yzrEPor6BGdKi2Dc2yKiAycnmcnCL6f7UPTQZsMasTJaoB7SCc2yKiAaFouzcNdzJRWyitjbYALjGulfDeF5rgT4rWHEzd(t4XZHm22zXHSXvymKPKazTYeqQLIoIdXq9EuBCiwMEskQCMwYm)SM6o0fSUu0qC0quGMgMqd4rdxPEXUJLf5L6ePVboqIy3jyJrIObWGPHRuVy3nTvDwYeqQDeWzBNLtWgJerdtOH18VwNEHj9Zsa0RXNDVSb)j0a(COYeohYgxHXqMscK1ktaPwk6i(YJeuXJGd9Yg8NWJNdzSTZIdzJRWyitjbYALjGulfDehIH69O24qBlC5MssFAioAGLPNKIkNPLmZpRPUdDbRlfnelnGRGMdvMW5q24kmgYusGSwzci1srhXxEKrfDEeCOx2G)eE8CiJTDwCitHzQvxjr24jsYsK55qmuVh1ghI8bDaahYgprswImVK8bDaaNAngo0qC0quCOYeohYuyMA1vsKnEIKSezE(YJmQO4rWHEzd(t4XZHm22zXHmfMPwDLezJNijlrMNdXq9EuBCiTVoyDdrARKjG0g)OCX4m22tpnmHg0(6mTKjHXK6ENX2E65qLjCoKPWm1QRKiB8ejzjY88LhzuJYJGd9Yg8NWJNdzSTZIdzkmtT6kjYgprswImphIH69O24qSm9Kuu5mTKz(zn1DOBKzAycnGhnCL6f7owwKxQtK(g4ajIDNGngjIgMqdBlC5MssFAioAGLPNKIkhllYl1jsFdCGeXUdDbRlfnelnmA0PbWGPHrOHRuVy3XYI8sDI03ahirS7eSXir0a(COYeohYuyMA1vsKnEIKSezE(YJmkCLhbh6Ln4pHhphYyBNfhYuyMA1vsKnEIKSezEoed17rTXH2w4YnLK(0qC0altpjfvotlzMFwtDh6cwxkAiwAy0OZHkt4CitHzQvxjr24jsYsK55lpYOanpco0lBWFcpEoKX2olo00w1zjtaj5cT6CigQ3JAJdHhnWY0tsrLZ0sM5N1u3HUrMPHj0a5d6aaoGR2J6cwkk1lItTgdhAigS0aOPHj0WvQxS7M2Qolzci1oc4STZY9Yg8Nqd4tdGbtdd6aao9ct6NLaOxJp701ObWGPbTVoydbNZ(7m22tphQmHZHM2QolzcijxOvNV8iJc38i4qVSb)j845qgB7S4qitqRlyPjO57vNCjCdBtt)kFb315qmuVh1ghILPNKIkNPLmZpRPUdDbRlfnehnmknagmnSM)16mKWSmbKlMljMqDI7Ln4pHgadMgqwtKF6R1zeIY1fnehnGBouzcNdHmbTUGLMGMVxDYLWnSnn9R8fCxNV8iJcuYJGd9Yg8NWJNdzSTZIdnmdN1Ld)sZlyLX4qmuVh1ghILPNKIkNsxqiljSHGZz)DOlyDPOHyObqz0PbWGPHrOH18VwNsxqiljSHGZz)DVSb)j0WeAyBHtdXqdJgDAamyAyeA4JPERPDIdzcADblnbnFV6KlHByBA6x5l4UohQmHZHgMHZ6YHFP5fSYy8LhzuGA8i4qVSb)j845qgB7S4qJXvsmPi)rCigQ3JAJdP91bBi4C2FNX2E6PbWGPHrOH18VwNsxqiljSHGZz)DVSb)j0WeAyBHtdXqdJgDAamyAyeA4JPERPDIdzcADblnbnFV6KlHByBA6x5l4UohQmHZHgJRKysr(J4lpYOIw8i4qVSb)j845qgB7S4qWM)mZ7psjhUHdhIH69O24qAFDWgcoN93zSTNEAamyAyeAyn)R1P0feYscBi4C2F3lBWFcnmHg2w40qm0WOrNgadMggHg(yQ3AAN4qMGwxWstqZ3Ro5s4g2MM(v(cURZHkt4CiyZFM59hPKd3WHV8iJcuXJGd9Yg8NWJNdzSTZIdbJYcwj1qTG5Lid(CigQ3JAJdH0RtdXHLgWvAycnGhnSTWPHyOHrJonagmnmcn8XuV10oXHmbTUGLMGMVxDYLWnSnn9R8fCxNgWNdvMW5qWOSGvsnulyEjYGpF5roA05rWHEzd(t4XZHyOEpQnoeltpjfvodjmlta5I5sYnIdDJmtdGbtdAFDWgcoN93zSTNEAamyAyqhaWPxys)Sea9A8zNUghYyBNfhsl3ol(YJC0O4rWHEzd(t4XZHyOEpQnoejx30gP7FTsnVbRFh6cwxkAioS0amJWHm22zXHs9DaDdh(YJC0r5rWHEzd(t4XZHm22zXHyM3ln22zj9TA5q(wTYYeoh6k1l2v8Lh5O4kpco0lBWFcpEoKX2oloeZ8EPX2olPVvlhY3QvwMW5qSm9KuuP4lpYrbnpco0lBWFcpEoed17rTXHm22tV81f6ROHyWsdJYHm22zXHq6L0yBNL03QLd5B1klt4CilpF5rokU5rWHEzd(t4XZHm22zXHyM3ln22zj9TA5q(wTYYeohc(1rnJV8LdPHolfgSLhbpYO4rWHm22zXH0YTZId9Yg8NWJNV8ihLhbhYyBNfhczT6sYnch6Ln4pHhpF5rIR8i4qVSb)j845qLjCoKnUcJHmLeiRvMasTu0rCiJTDwCiBCfgdzkjqwRmbKAPOJ4lpsqZJGd9Yg8NWJNdrU3M5qJYHm22zXHmKWSmbKlMlj3i8LVCiwMEskQu8i4rgfpcoKX2oloKHeMLjGCXCj5gHd9Yg8NWJNV8ihLhbh6Ln4pHhphIH69O24qKpOda4aUApQlyPOuVio1AmCOHyWsdGMdzSTZIdzAjZ8ZAQZxEK4kpco0lBWFcpEoed17rTXHgHgqwtKF6R1zeIY9XERwfnagmnGSMi)0xRZieLRlAigAikCZHm22zXHigch5ISsbKibB7S4lpsqZJGd9Yg8NWJNdXq9EuBCiKE1mPwk6ih5anRxAioAikqZHm22zXHu6cczjHneCo7pF5rIBEeCOx2G)eE8CigQ3JAJdDL6f7UPTQZsMasTJaoB7SCVSb)j0ayW0aE0WvQxS7yzrEPor6BGdKi2DVSb)j0WeAq7RZ0sMegtQ7DgB7PNgWNgadMgiFqhaWbC1EuxWsrPErCQ1y4qdXrdGMgMqdJqd4rdFm1BnTtCitqRlyPjO57vNCjCdBtt)kFb31PbWGPbB8J69obdwxjta5I5sYnI7Ln4pHgWNgadMgyz6jPOYzAjZ8ZAQ7qxW6srdXrdJsdtOb8OHpM6TM2joKjO1fS0e089QtUeUHTPPFLVG760ayW0Gn(r9ENGbRRKjGCXCj5gX9Yg8Nqd4ZHm22zXH0lmPFwcGEn(mF5rck5rWHEzd(t4XZHyOEpQnoKX2E6LVUqFfnedwAyuAycnGhnGhnWY0tsrLJCBXiTIijNzZo0fSUu0qCyPbygHgMqdJqdR5FToYbA)DVSb)j0a(0ayW0aE0altpjfvoYbA)DOlyDPOH4WsdWmcnmHgwZ)ADKd0(7Ezd(tOb8Pb85qgB7S4q6fM0plbqVgFMV8ib14rWHEzd(t4XZHm22zXHuPUxIUPDehIH69O24qRHG)62w4YnLK(0qC0q0IgMqdRHG)62w4YnLK(0qm0aO5qSzM)Y1qWFv8iJIV8iJw8i4qVSb)j845qmuVh1ghcpAyeAaznr(PVwNrik3h7TAv0ayW0aYAI8tFToJquUUOHyOHrJonGpnmHgq61PH4Wsd4rdrrdrBAyqhaWPxys)Sea9A8zNUgnGphYyBNfhsL6Ej6M2r8LhjOIhbhYyBNfhsVWK(z5GVHXSCOx2G)eE88LVCi4xh1mEe8iJIhbh6Ln4pHhphIH69O24qd6aaoLoH8ssYuWHUXwAycnmcnm1qTn4VtltFxWsGejHneCo7pnagmnO91bBi4C2FNX2E65qgB7S4qKBlgjlBpF5rokpco0lBWFcpEoed17rTXHq6vZKAPOJCKd0SEPH4OHOannmHgWJgyz6jPOYzAjZ8ZAQ7qxW6srdXqd4MgadMgiFqhaWbC1EuxWsrPErCQ1y4qdXqdGMgWNgMqdJqdtnuBd(70Y03fSeirsydbNZ(ZHm22zXHi3wmsw2E(YJex5rWHEzd(t4XZHyOEpQno0A(xRt7QT9Vy39Yg8NqdtObwMEskQCMwYm)SM6o0fSUuCiJTDwCiYTfJ0kIKCMnZxEKGMhbh6Ln4pHhphIH69O24qSm9Kuu5mTKz(zn1DOlyDP4qgB7S4qKd0(ZxEK4Mhbh6Ln4pHhphIH69O24q4rd4rdKpOda4aUApQlyPOuVioDnAycnWY0tsrLZ0sM5N1u3HUG1LIgIHgWnnGpnagmnq(GoaGd4Q9OUGLIs9I4uRXWHgIHgannGpnmHgWJgyz6jPOYziHzzcixmxsUrCOlyDPOHyObCtdGbtdKBlgjovdJzDKwzd(lTCj0a(CiJTDwCifl1rWxQwuJZ5lpsqjpco0lBWFcpEoed17rTXHWJgWJgiFqhaWbC1EuxWsrPErC6A0WeAGLPNKIkNPLmZpRPUdDbRlfnednGBAaFAamyAG8bDaahWv7rDblfL6fXPwJHdnednaAAaFAycnGhnWY0tsrLZqcZYeqUyUKCJ4qxW6srdXqd4MgadMgi3wmsCQggZ6iTYg8xA5sOb85qgB7S4qmVjQlyPcJrsrk(YJeuJhbh6Ln4pHhphIH69O24qi9QzsTu0roYbAwV0qC0WOrNgMqdJqdtnuBd(70Y03fSeirsydbNZ(ZHm22zXHi3wmsw2E(YJmAXJGd9Yg8NWJNdXq9EuBCi8Ob8Ob8Ob8ObYh0baCaxTh1fSuuQxeNAngo0qC0aOPHj0Wi0WGoaGtVWK(zja614ZoDnAaFAamyAG8bDaahWv7rDblfL6fXPwJHdnehnGR0a(0WeAGLPNKIkNPLmZpRPUdDbRlfnehnGR0a(0ayW0a5d6aaoGR2J6cwkk1lItTgdhAioAikAaFAycnGhnWY0tsrLZqcZYeqUyUKCJ4qxW6srdXqd4MgadMgi3wmsCQggZ6iTYg8xA5sOb85qgB7S4qaxTh1fSuTOgNZxEKGkEeCOx2G)eE8CigQ3JAJdncnm1qTn4VtltFxWsGejHneCo7phYyBNfhICBXizz75lF5qwEEe8iJIhbh6Ln4pHhphIH69O24qSm9Kuu5mTKz(zn1DOlyDP4qgB7S4qKBlgPvej5mBMV8ihLhbhYyBNfhICG2Fo0lBWFcpE(YJex5rWHEzd(t4XZHyOEpQnoe52IrAfrsoZMDBZWPlyAycnG0RtdXrdJsdtOHrOHPgQTb)DAz67cwcKijSHGZz)5qgB7S4qxRjxOz8LhjO5rWHEzd(t4XZHyOEpQnoe52IrAfrsoZMDBZWPlyAycnG0RtdXrdJsdtOHrOHPgQTb)DAz67cwcKijSHGZz)5qgB7S4qKBlgjlBpF5rIBEeCOx2G)eE8CigQ3JAJdrUTyKwrKKZSz32mC6cMgMqdSm9Kuu5mTKz(zn1DOlyDP4qgB7S4qkwQJGVuTOgNZxEKGsEeCOx2G)eE8CigQ3JAJdrUTyKwrKKZSz32mC6cMgMqdSm9Kuu5mTKz(zn1DOlyDP4qgB7S4qmVjQlyPcJrsrk(YJeuJhbh6Ln4pHhphIH69O24qJqdtnuBd(70Y03fSeirsydbNZ(ZHm22zXHUwtUqZ4lpYOfpco0lBWFcpEoKX2oloeWv7rDblvlQX5CigQ3JAJdr(GoaGd4Q9OUGLIs9I4uRXWHgIdlnefnmHgyz6jPOYrUTyKwrKKZSzh6cwxkoeBM5VCne8xfpYO4lpsqfpco0lBWFcpEoed17rTXHwZ)ADd6i12fSuLORCVSb)j0WeAqPDVxUgc(RYnOJuBxWsvIUIgIblnmknmHgiFqhaWbC1EuxWsrPErCQ1y4qdXHLgIIdzSTZIdbC1EuxWs1IACoF5rgv05rWHEzd(t4XZHyOEpQno0GoaGtPtiVKKmfCOBSLgMqdi96oYbAwV0qmyPbqZHm22zXHi3wmsw2E(YJmQO4rWHEzd(t4XZHyOEpQno0GoaGtPtiVKKmfCOBSLgMqdJqdtnuBd(70Y03fSeirsydbNZ(tdGbtdAFDWgcoN93zSTNEoKX2oloe52IrYY2ZxEKrnkpco0lBWFcpEoed17rTXHq6vZKAPOJCKd0SEPH4OHOannmHgWJgyz6jPOYzAjZ8ZAQ7qxW6srdXqd4MgadMgiFqhaWbC1EuxWsrPErCQ1y4qdXqdGMgWNgMqdJqdtnuBd(70Y03fSeirsydbNZ(ZHm22zXHi3wmsw2E(YJmkCLhbh6Ln4pHhphIH69O24q4rd4rdKpOda4aUApQlyPOuVioDnAycnWY0tsrLZ0sM5N1u3HUG1LIgIHgWnnGpnagmnq(GoaGd4Q9OUGLIs9I4uRXWHgIHgannGpnmHgWJgyz6jPOYziHzzcixmxsUrCOlyDPOHyObCtdGbtdKBlgjovdJzDKwzd(lTCj0a(CiJTDwCifl1rWxQwuJZ5lpYOanpco0lBWFcpEoed17rTXHWJgWJgiFqhaWbC1EuxWsrPErC6A0WeAGLPNKIkNPLmZpRPUdDbRlfnednGBAaFAamyAG8bDaahWv7rDblfL6fXPwJHdnednaAAaFAycnGhnWY0tsrLZqcZYeqUyUKCJ4qxW6srdXqd4MgadMgi3wmsCQggZ6iTYg8xA5sOb85qgB7S4qmVjQlyPcJrsrk(YJmkCZJGd9Yg8NWJNdXq9EuBCiKE1mPwk6ih5anRxAioAy0OtdtOHrOHPgQTb)DAz67cwcKijSHGZz)5qgB7S4qKBlgjlBpF5rgfOKhbh6Ln4pHhphIH69O24q4rd4rd4rd4rdKpOda4aUApQlyPOuVio1AmCOH4ObqtdtOHrOHbDaaNEHj9Zsa0RXND6A0a(0ayW0a5d6aaoGR2J6cwkk1lItTgdhAioAaxPb8PHj0altpjfvotlzMFwtDh6cwxkAioAaxPb8PbWGPbYh0baCaxTh1fSuuQxeNAngo0qC0qu0a(0WeAapAGLPNKIkNHeMLjGCXCj5gXHUG1LIgIHgWnnagmnqUTyK4unmM1rALn4V0YLqd4ZHm22zXHaUApQlyPArnoNV8iJcuJhbh6Ln4pHhphIH69O24qJqdtnuBd(70Y03fSeirsydbNZ(ZHm22zXHi3wmsw2E(Yx(YHMEKQZIh5Orpkqv0bvJgDoKidvDbR4qJfaQpwjYX6iJgESrd0qeyon0cAjAPbGerdrtYbmD)gnPb0ht9gDcnOsHtdM(Mc2EcnWWyf8vokiJL760aOASrdGczn9O9eAiAUgc(Rlk32cxUPK0pAsdBsdrZTfUCtjPF0KgWlQXo(okiJL760qu46yJgafYA6r7j0q0Cne8xxuUTfUCtjPF0Kg2KgIMBlC5Mss)OjnGxuJD8DuqOGmwlOLO9eAausdgB7SObFRwLJcchY0xmjIdb1c6EB7SafqgWYH0qjq7phcxObqXfM0ptdJfVTyOHXsvdJzPGGl0aMD1uJnXfhUxm6dowkiUQf0922zXqgWkUQfyItbbxObORTxy4iAyuClgnmA0JcurbHccUqdGcySc(QXgfeCHgI20aOoHCcnenOlcnakc9p(DuqWfAiAtdGczn9O9eAyne8xzdqdSSi92zPOHnPb0H19gIgyzr6TZs5OGGl0q0MgGsHtdP22c9422zrdjanak6Q9iHggZsdDrdG6JvJgDuqOGGl0q04y)m99eAy4aj60alfgSLggoCxkhnaQZyxBv0qLv0gJHea090GX2olfnKLF2rbbxObJTDwkNg6SuyWwSaEtHdfeCHgm22zPCAOZsHbBJfR4azsOGGl0GX2olLtdDwkmyBSyf30HfET22zrbbxObOY0uyYLgqwtOHbDaGtOb1ARIggoqIonWsHbBPHHd3LIgSIqdAOhT1YD7cMgAfnqY6oki4cnySTZs50qNLcd2glwXvLPPWKRuT2QOGySTZs50qNLcd2glwX1YTZIcIX2olLtdDwkmyBSyfhzT6sYncfeJTDwkNg6SuyW2yXkUU6YEVGyLjCS24kmgYusGSwzci1srhrbXyBNLYPHolfgSnwSIBiHzzcixmxsUreJCVnJDukiuqWfAiACSFM(Ecn8PhntdBlCAyXCAWyBIOHwrd2uR92G)okigB7Suyf6Iibq)JFkigB7SuXIv8PgQTb)fRmHJvltFxWsGejHneCo7VytnV(XYY0tsrLtPliKLe2qW5S)o0fSUuXH7jR5FToLUGqwsydbNZ(7Ezd(tOGGl0WyfJ1MxjgnmwVxqjgnyfHgYfZr0qcZikkigB7SuXIvCdXS6YnrOxRynawKE1mPwk6ih5anR3yaL4EcEAFDWgcoN93zSTNEWGhzn)R1P0feYscBi4C2F3lBWFc(tq61DKd0SEJblUPGySTZsflwXh8zsKa6OzXAaSAFDWgcoN93zSTNEWGhzn)R1P0feYscBi4C2F3lBWFcfeJTDwQyXk(WrQJWPlyXAaSd6aao9ct6NLaOxJp701adw7Rd2qW5S)oJT90dgmER5FTodjmlta5I5sIjuN4Ezd(tMO91zAjtcJj19oJT90JpfeCHgaf0vBkqdlQlC(QObDLbFkigB7SuXIvCD1L9EbLyna2TfEmJgDWGh5JPERPDIdzcADblnbnFV6KlHByBA6x5l4UoyWJ8XuV10oXnTvDwYeqsUqRofeJTDwQyXkUU6YEVGyLjCS24kmgYusGSwzci1srhjwdGfVRuVy3nTvDwYeqQDeWzBNLtWgJenzK18VwNEHj9Zsa0RXNDVSb)j4dgmEJCL6f7owwKxQtK(g4ajIDNGngjAYixPEXUBAR6SKjGu7iGZ2olNGngjcFkigB7SuXIvCD1L9EbXkt4yTXvymKPKazTYeqQLIosSgalltpjfvotlzMFwtDh6cwxQ4Ic0tW7k1l2DSSiVuNi9nWbse7obBmseyWxPEXUBAR6SKjGu7iGZ2olNGngjAYA(xRtVWK(zja614ZUx2G)e8PGySTZsflwX1vx27feRmHJ1gxHXqMscK1ktaPwk6iXAaSRHG)6IYTTWLBkj9JJLPNKIkNPLmZpRPUdDbRlvS4kOPGySTZsflwX1vx27feRmHJ1uyMA1vsKnEIKSezEXAaSKpOda4q24jsYsK5LKpOda4uRXWjUOOGySTZsflwX1vx27feRmHJ1uyMA1vsKnEIKSezEXAaSAFDW6gI0wjtaPn(r5IXzSTN(jAFDMwYKWysDVZyBp9uqm22zPIfR46Ql79cIvMWXAkmtT6kjYgprswImVynawwMEskQCMwYm)SM6o0nY8e8Us9IDhllYl1jsFdCGeXUtWgJenzBHl3us6hhltpjfvowwKxQtK(g4ajIDh6cwxQyhn6GbpYvQxS7yzrEPor6BGdKi2Dc2yKi8PGySTZsflwX1vx27feRmHJ1uyMA1vsKnEIKSezEXAaSRHG)6IYTTWLBkj9JJLPNKIkNPLmZpRPUdDbRlvSJgDkigB7SuXIvCD1L9EbXkt4yN2QolzcijxOvxSgalESm9Kuu5mTKz(zn1DOBK5jKpOda4aUApQlyPOuVio1AmCIblONCL6f7UPTQZsMasTJaoB7SCVSb)j4dg8GoaGtVWK(zja614ZoDnWG1(6GneCo7VZyBp9uqm22zPIfR46Ql79cIvMWXImbTUGLMGMVxDYLWnSnn9R8fCxxSgalltpjfvotlzMFwtDh6cwxQ4gfm418VwNHeMLjGCXCjXeQtCVSb)jGbJSMi)0xRZieLRR4WnfeJTDwQyXkUU6YEVGyLjCSdZWzD5WV08cwzmXAaSSm9Kuu5u6cczjHneCo7VdDbRlvmGYOdg8iR5FToLUGqwsydbNZ(7Ezd(tMSTWJz0Odg8iFm1BnTtCitqRlyPjO57vNCjCdBtt)kFb31PGySTZsflwX1vx27feRmHJDmUsIjf5psSgaR2xhSHGZz)DgB7Phm4rwZ)ADkDbHSKWgcoN939Yg8NmzBHhZOrhm4r(yQ3AAN4qMGwxWstqZ3Ro5s4g2MM(v(cURtbXyBNLkwSIRRUS3liwzchlS5pZ8(JuYHB4iwdGv7Rd2qW5S)oJT90dg8iR5FToLUGqwsydbNZ(7Ezd(tMSTWJz0Odg8iFm1BnTtCitqRlyPjO57vNCjCdBtt)kFb31PGySTZsflwX1vx27feRmHJfgLfSsQHAbZlrg8fRbWI0RhhwCDcEBl8ygn6GbpYht9wt7ehYe06cwAcA(E1jxc3W200VYxWDD8PGySTZsflwX1YTZsSgalltpjfvodjmlta5I5sYnIdDJmdgS2xhSHGZz)DgB7Phm4bDaaNEHj9Zsa0RXND6AuqWfAiAG11AD1fmnenuJ09VwAySqVbRFAOv0GrdAOor9otbXyBNLkwSIN67a6goI1ayj56M2iD)RvQ5ny97qxW6sfhwygHcIX2olvSyfNzEV0yBNL03QvSYeo2RuVyxrbXyBNLkwSIZmVxASTZs6B1kwzchlltpjfvkkigB7SuXIvCKEjn22zj9TAfRmHJ1YlwdG1yBp9YxxOVkgSJsbXyBNLkwSIZmVxASTZs6B1kwzchl8RJAgfeki4cnaQNrJ0akxB7SOGySTZs5S8yj3wmsRisYz2SynawwMEskQCMwYm)SM6o0fSUuuqm22zPCw(yXko5aT)uqm22zPCw(yXk(1AYfAMynawYTfJ0kIKCMn72MHtxWtq61JB0jJm1qTn4VtltFxWsGejHneCo7pfeJTDwkNLpwSItUTyKSS9I1ayj3wmsRisYz2SBBgoDbpbPxpUrNmYud12G)oTm9DblbsKe2qW5S)uqm22zPCw(yXkUIL6i4lvlQX5I1ayj3wmsRisYz2SBBgoDbpHLPNKIkNPLmZpRPUdDbRlffeJTDwkNLpwSIZ8MOUGLkmgjfPeRbWsUTyKwrKKZSz32mC6cEcltpjfvotlzMFwtDh6cwxkkigB7SuolFSyf)An5cntSga7itnuBd(70Y03fSeirsydbNZ(tbXyBNLYz5JfR4axTh1fSuTOgNlgBM5VCne8xf2OeRbWs(GoaGd4Q9OUGLIs9I4uRXWjoSrnHLPNKIkh52IrAfrsoZMDOlyDPOGySTZs5S8XIvCGR2J6cwQwuJZfRbWUM)16g0rQTlyPkrx5Ezd(tMO0U3lxdb)v5g0rQTlyPkrxfd2rNq(GoaGd4Q9OUGLIs9I4uRXWjoSrrbXyBNLYz5JfR4KBlgjlBVyna2bDaaNsNqEjjzk4q3y7eKEDh5anR3yWcAkigB7SuolFSyfNCBXizz7fRbWoOda4u6eYljjtbh6gBNmYud12G)oTm9DblbsKe2qW5S)GbR91bBi4C2FNX2E6PGySTZs5S8XIvCYTfJKLTxSgalsVAMulfDKJCGM1BCrb6j4XY0tsrLZ0sM5N1u3HUG1LkgCdgm5d6aaoGR2J6cwkk1lItTgdNyan(tgzQHABWFNwM(UGLajscBi4C2FkigB7SuolFSyfxXsDe8LQf14CXAaS4Hh5d6aaoGR2J6cwkk1lItxBcltpjfvotlzMFwtDh6cwxQyWn(Gbt(GoaGd4Q9OUGLIs9I4uRXWjgqJ)e8yz6jPOYziHzzcixmxsUrCOlyDPIb3GbtUTyK4unmM1rALn4V0YLGpfeJTDwkNLpwSIZ8MOUGLkmgjfPeRbWIhEKpOda4aUApQlyPOuVioDTjSm9Kuu5mTKz(zn1DOlyDPIb34dgm5d6aaoGR2J6cwkk1lItTgdNyan(tWJLPNKIkNHeMLjGCXCj5gXHUG1LkgCdgm52IrIt1WywhPv2G)slxc(uqm22zPCw(yXko52IrYY2lwdGfPxntQLIoYroqZ6nUrJ(KrMAO2g83PLPVlyjqIKWgcoN9NcIX2olLZYhlwXbUApQlyPArnoxSgalE4HhEKpOda4aUApQlyPOuVio1AmCId0tgzqhaWPxys)Sea9A8zNUg(Gbt(GoaGd4Q9OUGLIs9I4uRXWjoCf)jSm9Kuu5mTKz(zn1DOlyDPIdxXhmyYh0baCaxTh1fSuuQxeNAngoXff(tWJLPNKIkNHeMLjGCXCj5gXHUG1LkgCdgm52IrIt1WywhPv2G)slxc(uqm22zPCw(yXko52IrYY2lwdGDKPgQTb)DAz67cwcKijSHGZz)PGqbXyBNLYXY0tsrLcRHeMLjGCXCj5gHcIX2olLJLPNKIkvSyf30sM5N1uxSgal5d6aaoGR2J6cwkk1lItTgdNyWcAkigB7SuowMEskQuXIvCIHWrUiRuajsW2olXAaSJGSMi)0xRZieL7J9wTkWGrwtKF6R1zeIY1vmrHBkigB7SuowMEskQuXIvCLUGqwsydbNZ(lwdGfPxntQLIoYroqZ6nUOanfeJTDwkhltpjfvQyXkUEHj9Zsa0RXNfRbWEL6f7UPTQZsMasTJaoB7SCVSb)jGbJ3vQxS7yzrEPor6BGdKi2DVSb)jt0(6mTKjHXK6ENX2E6XhmyYh0baCaxTh1fSuuQxeNAngoXb6jJG3ht9wt7ehYe06cwAcA(E1jxc3W200VYxWDDWGTXpQ37emyDLmbKlMlj3iUx2G)e8bdMLPNKIkNPLmZpRPUdDbRlvCJobVpM6TM2joKjO1fS0e089QtUeUHTPPFLVG76GbBJFuV3jyW6kzcixmxsUrCVSb)j4tbXyBNLYXY0tsrLkwSIRxys)Sea9A8zXAaSgB7Px(6c9vXGD0j4HhltpjfvoYTfJ0kIKCMn7qxW6sfhwygzYiR5FToYbA)DVSb)j4dgmESm9Kuu5ihO93HUG1LkoSWmYK18Vwh5aT)Ux2G)e8XNcIX2olLJLPNKIkvSyfxL6Ej6M2rIXMz(lxdb)vHnkXAaSRHG)62w4YnLK(XfTMSgc(RBBHl3us6hdOPGySTZs5yz6jPOsflwXvPUxIUPDKynaw8gbznr(PVwNrik3h7TAvGbJSMi)0xRZieLRRygn64pbPxpoS4fv0EqhaWPxys)Sea9A8zNUg(uqm22zPCSm9KuuPIfR46fM0plh8nmMLccfeJTDwk3vQxSRWkCHenltaPxN1ejbDtqjwdGfPx3TTWLBkJkgygzcsVAMulfDuCGo6uqm22zPCxPEXUkwSIp4ZKita5I5YxxywSgalESm9Kuu5i3wmsRisYz2SdDbRl1eL29E5Ai4Vkh52IrAfrsoZMJjk8bdgpwMEskQCKd0(7qxW6snrPDVxUgc(RYroq7FmrHpyW4XY0tsrLZ0sM5N1u3HUG1LAcltpjfvoYTfJ0kIKCMn7q3iZ4tbXyBNLYDL6f7QyXkoSUHiTvYeqAJFuUyeRbWIhltpjfvotlzMFwtDh6cwxQ4aLtyz6jPOYziHzzcixmxsUrCOlyDPIHLPNKIkhllYl1jsFdCGeXUdDbRlf(GbZY0tsrLZqcZYeqUyUKCJ4qxW6sf3Ouqm22zPCxPEXUkwSIVyUuVgs9Iibse7I1ayh0baCOZWXFLscKi2D6AGbpOda4qNHJ)kLeirSlzPETh5uRXWjUOIIcIX2olL7k1l2vXIvCGKPRorAJFuVxoCtqSga7iKBlgPvej5mB2TndNUGPGySTZs5Us9IDvSyfNLf71IS9ejG3eUynawsUowwSxlY2tKaEt4YbDu5qxW6sHn6uqm22zPCxPEXUkwSIRPJAG5UGLdEtTI1ayhHCBXiTIijNzZUTz40fmfeJTDwk3vQxSRIfR4IsKNm9DjrxLLvSlwdGDeYTfJ0kIKCMn72MHtxWuqm22zPCxPEXUkwSIJAnn)LDjvAg7I1ayhHCBXiTIijNzZUTz40fmfekigB7Suo4xh1mSKBlgjlBVyna2bDaaNsNqEjjzk4q3y7KrMAO2g83PLPVlyjqIKWgcoN9hmyTVoydbNZ(7m22tpfeJTDwkh8RJAwSyfNCBXizz7fRbWI0RMj1srh5ihOz9gxuGEcESm9Kuu5mTKz(zn1DOlyDPIb3Gbt(GoaGd4Q9OUGLIs9I4uRXWjgqJ)KrMAO2g83PLPVlyjqIKWgcoN9NcIX2olLd(1rnlwSItUTyKwrKKZSzXAaSR5FToTR22)ID3lBWFYewMEskQCMwYm)SM6o0fSUuuqm22zPCWVoQzXIvCYbA)fRbWYY0tsrLZ0sM5N1u3HUG1LIcIX2olLd(1rnlwSIRyPoc(s1IACUynaw8WJ8bDaahWv7rDblfL6fXPRnHLPNKIkNPLmZpRPUdDbRlvm4gFWGjFqhaWbC1EuxWsrPErCQ1y4edOXFcESm9Kuu5mKWSmbKlMlj3io0fSUuXGBWGj3wmsCQggZ6iTYg8xA5sWNcIX2olLd(1rnlwSIZ8MOUGLkmgjfPeRbWIhEKpOda4aUApQlyPOuVioDTjSm9Kuu5mTKz(zn1DOlyDPIb34dgm5d6aaoGR2J6cwkk1lItTgdNyan(tWJLPNKIkNHeMLjGCXCj5gXHUG1LkgCdgm52IrIt1WywhPv2G)slxc(uqm22zPCWVoQzXIvCYTfJKLTxSgalsVAMulfDKJCGM1BCJg9jJm1qTn4VtltFxWsGejHneCo7pfeJTDwkh8RJAwSyfh4Q9OUGLQf14CXAaS4HhE4r(GoaGd4Q9OUGLIs9I4uRXWjoqpzKbDaaNEHj9Zsa0RXND6A4dgm5d6aaoGR2J6cwkk1lItTgdN4Wv8NWY0tsrLZ0sM5N1u3HUG1LkoCfFWGjFqhaWbC1EuxWsrPErCQ1y4exu4pbpwMEskQCgsywMaYfZLKBeh6cwxQyWnyWKBlgjovdJzDKwzd(lTCj4tbXyBNLYb)6OMflwXj3wmsw2EXAaSJm1qTn4VtltFxWsGejHneCo7pF5lNd]] )

end
