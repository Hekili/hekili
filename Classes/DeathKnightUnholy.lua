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

            if amount > 0 then
                state.gain( amount * 10, "runic_power" )

                if state.set_bonus.tier20_4pc == 1 then
                    state.cooldown.army_of_the_dead.expires = max( 0, state.cooldown.army_of_the_dead.expires - 1 )
                end
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

            targets = {
                count = function () return active_dot.virulent_plague end,
            },

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

            spend = 1,
            spendType = "runes",

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


    spec:RegisterPack( "Unholy", 20200301, [[dW0uFbqiHWJiH0MesFsQQKrrcofuPxjL0SekDlbQyxe(LqXWirCmHQwMuvEgjsnnsOUMaLTjqvFtGknoPQIohjezDsvv18KQ4Eqv7Je1bjHqluQspuQQstuQQu1fLQkLnkvvWhjHG6KKqGvcv8sPQkyMsvvOBkvvODkL4NKqqgkjevlvQQIEkctvOYvjHOSvPQsL(QuvPI9sP)I0GP4WuTyP4XOmzuDzvBgWNHYObYPvSAsK41cKztQBJODl63sgUGoojsA5GEortxPRtsBxk13fW4LQQY5LkRxiA(a1(HSnEBCwcUV32sFkPpLOeLwjXlIxjkj4QyL2sSDH3se6SGCSBjsN8wcfzjOs3zjc9oD5CBCwczPcz3saA3qz)pMyWMfKAJGvKXihsvTVtLmOdSXihswmwIg1rVkcsBJLG77TT0Ns6tjkrPvs8I4vIscUkTITeYWZST0xW6ZsaA48N2glb)sMLqrrgfzjOs3Hm97VVGqM(d5GbAr4OOidODdL9)yIbBwqQncwrgJCiv1(ovYGoWgJCizXGWrrrM(rhYaHmXhlY0Ns6tjiCq4OOit)fKNyx2)r4OOitWbzue58ZrM(Xj5it)a8pYlq4OOitWbz6Vv2(W9CKzDi2x6aGmSk5ZovkrMTqg4Xu1oezyvYNDQukq4OOitWbzikYJmv4oKtK(ovImfaY0pC5Ei5GbArMjrgfrfH63eiCuuKj4Gm9NoBCTmM(HkxKPaqgf5vGdrMnW9GKclHEKR0gNL4s5t2L24STeVnolXtVrFUTxlbdo7HJBjGQ5f7qE6w04rgLrgmghzIImq1Cy0WkWHitpiJIvILWz7uPLG8KfSJwauTkB4uo8oP0U2w6ZgNL4P3Op32RLGbN9WXTekGmSQ08kqk43xqup5u(zENaEsFsjYefzKHxRPRdX(kf87liQNCk)mVdzugzIhzWfzadgzuazyvP5vGuWpWOVaEsFsjYefzKHxRPRdX(kf8dm6JmkJmXJm4ImGbJmkGmSQ08kqk8WI56Uq5fWt6tkrMOiJZ2P9Ppp5CjYGhzIhzW1s4SDQ0s0ORItla6c60NNSZU2wuABCwINEJ(CBVwcgC2dh3sOaYWQsZRaPWdlMR7cLxapPpPez6bzcEKjkYWQsZRaPWHKD0cGUGoLFNlGN0NuImkJmSQ08kqkyvYFkpNQhGduq2fWt6tkrgCrgWGrgwvAEfifoKSJwa0f0P87Cb8K(KsKPhKPplHZ2PslbMQd5JN0cG6rEyTGSRTffBJZs80B0NB71sWGZE44wIgvaab8SG0xkPafKDHAiYagmY0OcaiGNfK(sjfOGStzLAUhkKRZccz6bzIpElHZ2PslXc6u1SPutofOGSBxBlbZgNL4P3Op32RLGbN9WXTerGm87liQNCk)mVtSdlOjXSeoBNkTeaftvEo1J8WzpT5oPDTTe824Sep9g952ETem4ShoULGxRGvj75c99CkG2jpTrfMc4j9jLidEKrjwcNTtLwcwLSNl03ZPaAN8212sW1gNL4P3Op32RLGbN9WXTerGm87liQNCk)mVtSdlOjXSeoBNkTeHQWbOBsmAJ2LRDTT0pTXzjE6n6ZT9AjyWzpCClX66NRWHKD0cGUGoL7K55INEJ(CKjkYCP8j7I2JCQKwa0WdboBNkfKtwqKjkY0OcaiutqLUJkx4tSfKqnezadgzUu(KDr7rovslaA4HaNTtLcYjliYefzc)k8WIrXavQAHZ2P9rgWGrM11pxHdj7OfaDbDk3jZZfp9g95ituKj8RWdlgfduPQfoBN2hzIImSQ08kqkCizhTaOlOt535c4j9jLiJYitWReKbmyKzD9Zv4qYoAbqxqNYDY8CXtVrFoYefzc)kCizhfduPQfoBN23s4SDQ0seOGAE7pjfEzLEYUDTTOizJZs80B0NB71sWGZE44wIiqg(9fe1toLFM3j2Hf0KyituKPrfaqOMGkDhvUWNyliHAiYefzIazUu(KDr7rovslaA4HaNTtLcYjliYefzIazwx)CfoKSJwa0f0PCNmpx80B0NJmGbJmRdX(k2H80TO85itpidRknVcKcpSyUUluEb8K(KslHZ2PslrGcQ5T)Ku4Lv6j7212s8kXgNL4P3Op32RLGbN9WXTerGm87liQNCk)mVtSdlOjXSeoBNkTeWjmuF6KuzOZUDTTeF824SeoBNkTeW7HtIrb0o5LwINEJ(CBV21Uwc(bCv9AJZ2s824SeoBNkTeKtYPaW)iVL4P3Op32RDTT0NnolXtVrFUTxlrfAjKFTeoBNkTeTD44n6BjA7A1BjyvP5vGuivjjRKI5qSQtFb8K(KsKPhKjyituKzD9ZvivjjRKI5qSQtFXtVrFULOTdPPtElryv6jXOafKI5qSQtF7ABrPTXzjE6n6ZT9AjyWzpCClbunhgnScCOGFGHnlYOmYe8bdzIImkGmHFfyoeR60x4SDAFKbmyKjcKzD9ZvivjjRKI5qSQtFXtVrFoYGlYefzGQ5f8dmSzrgLXJmbZs4SDQ0s4qMNNUfe(CTRTffBJZs80B0NB71sWGZE44wIWVcmhIvD6lC2oTpYagmYebYSU(5kKQKKvsXCiw1PV4P3Op3s4SDQ0s0ORItbuHD212sWSXzjE6n6ZT9AjyWzpCClrJkaGqnbv6oka8zKDc1qKbmyKj8RaZHyvN(cNTt7JmGbJmkGmRRFUchs2rla6c6uUtMNlE6n6ZrMOit4xHhwmkgOsvlC2oTpYGRLWz7uPLO5q5HbnjMDTTe824Sep9g952ETem4ShoULqbKPrfaqOMGkDhvUWNyliHAiYefzAubaeaxUhsoyGwb8K(KsKPh8itWqgCrgWGrgNTt7tFEY5sKrz8itFituKrbKPrfaqOMGkDhvUWNyliHAiYagmY0OcaiaUCpKCWaTc4j9jLitp4rMGHm4AjC2ovAj0dgOvsvkQCmYNRDTTeCTXzjE6n6ZT9AjyWzpCClHcit4xbMdXQo9foBN2hzIImRRFUcPkjzLumhIvD6lE6n6ZrgCrgWGrMWVcpSyumqLQw4SDAFlHZ2PslHNSlxORPmxRTRTL(PnolXtVrFUTxlbdo7HJBjC2oTp95jNlrgLXJm9HmGbJmkGmq18c(bg2SiJY4rMGHmrrgOAomAyf4qb)adBwKrz8itWReKbxlHZ2PslHdzEEAOQwE7ABrrYgNL4P3Op32RLGbN9WXTekGmHFfyoeR60x4SDAFKjkYSU(5kKQKKvsXCiw1PV4P3OphzWfzadgzc)k8WIrXavQAHZ2P9TeoBNkTead8n6Q4212s8kXgNL4P3Op32RLGbN9WXTenQaac1euP7OYf(eBbjudrMOiJZ2P9Ppp5CjYGhzIhzadgzAubaeaxUhsoyGwb8K(KsKPhKbJXrMOiJZ2P9Ppp5CjYGhzI3s4SDQ0s04y0cGUWHfK0U2wIpEBCwINEJ(CBVwcgC2dh3sSd5rgLrM(ucYagmYebYCLQ6egEUa6KHtIrDYq9SQ8tXgmVDPx6tSjpYagmYebYCLQ6egEUO9iNkPfaLFYrElHZ2PslHQ80zpP0U2wIVpBCwINEJ(CBVwcNTtLwcpsjih6skqLlTaOHvGdTem4ShoULqbK5s5t2fTh5ujTaOHhcC2ovkE6n6ZrMOiteiZ66NRqnbv6oka8zKDINEJ(CKbxKbmyKrbKjcK5s5t2fSk5pLNt1dWbki7csxPuqKjkYebYCP8j7I2JCQKwa0WdboBNkfp9g95idUwI0jVLWJucYHUKcu5slaAyf4q7ABjEL2gNL4P3Op32RLWz7uPLWJucYHUKcu5slaAyf4qlbdo7HJBjyvP5vGu4HfZ1DHYlGN0NuIm9GmXRyKjkYOaYCP8j7cwL8NYZP6b4afKDbPRukiYagmYCP8j7I2JCQKwa0WdboBNkfp9g95ituKzD9ZvOMGkDhfa(mYoXtVrFoYGRLiDYBj8iLGCOlPavU0cGgwbo0U2wIxX24Sep9g952ETeoBNkTeEKsqo0LuGkxAbqdRahAjyWzpCClXoKNUfLphz6bzyvP5vGu4HfZ1DHYlGN0NuImTImkTITePtElHhPeKdDjfOYLwa0WkWH212s8bZgNL4P3Op32RLWz7uPLWLGA75LuOhzbPSc6Albdo7HJBj4Vrfaqa9iliLvqxt5VrfaqixNfeY0dYeVLiDYBjCjO2EEjf6rwqkRGU2U2wIp4TXzjE6n6ZT9AjC2ovAjCjO2EEjf6rwqkRGU2sWGZE44wIWVcmvhYhpPfa1J8WAbjC2oTpYefzc)k8WIrXavQAHZ2P9TePtElHlb12ZlPqpYcszf01212s8bxBCwINEJ(CBVwcNTtLwcxcQTNxsHEKfKYkORTem4ShoULGvLMxbsHhwmx3fkVaEN3HmrrgfqMlLpzxWQK)uEovpahOGSliDLsbrMOiZoKNUfLphz6bzyvP5vGuWQK)uEovpahOGSlGN0NuImTIm9PeKbmyKjcK5s5t2fSk5pLNt1dWbki7csxPuqKbxlr6K3s4sqT98sk0JSGuwbDTDTTeF)0gNL4P3Op32RLWz7uPLWLGA75LuOhzbPSc6Albdo7HJBj2H80TO85itpidRknVcKcpSyUUluEb8K(KsKPvKPpLyjsN8wcxcQTNxsHEKfKYkORTRTL4vKSXzjE6n6ZT9AjC2ovAjApYPsAbq5NCK3sWGZE44wcfqgwvAEfifEyXCDxO8c4DEhYefz4VrfaqaC5E4Ky0aLAYfY1zbHmkJhzumYefzUu(KDr7rovslaA4HaNTtLINEJ(CKbxKbmyKPrfaqOMGkDhfa(mYoHAiYagmYe(vG5qSQtFHZ2P9TePtElr7rovslak)KJ8212sFkXgNL4P3Op32RLWz7uPLa6KHtIrDYq9SQ8tXgmVDPx6tSjVLGbN9WXTeSQ08kqk8WI56Uq5fWt6tkrMEqM(qgWGrM11pxHdj7OfaDbDk3jZZfp9g95idyWid0ho9TFUcNZLIjrMEqMGzjsN8wcOtgojg1jd1ZQYpfBW82LEPpXM8212sFXBJZs80B0NB71s4SDQ0s00Hv5Pn)uxt6PZSem4ShoULGvLMxbsHuLKSskMdXQo9fWt6tkrgLrMGxjidyWiteiZ66NRqQsswjfZHyvN(INEJ(CKjkYSd5rgLrM(ucYagmYebYCLQ6egEUa6KHtIrDYq9SQ8tXgmVDPx6tSjVLiDYBjA6WQ80MFQRj90z212sF9zJZs80B0NB71s4SDQ0sOuUKcQcOp0sWGZE44wIWVcmhIvD6lC2oTpYagmYebYSU(5kKQKKvsXCiw1PV4P3OphzIIm7qEKrzKPpLGmGbJmrGmxPQoHHNlGoz4KyuNmupRk)uSbZBx6L(eBYBjsN8wcLYLuqva9H212sFkTnolXtVrFUTxlHZ2PslbMRpZ16dL0M7bzjyWzpCClr4xbMdXQo9foBN2hzadgzIazwx)CfsvsYkPyoeR60x80B0NJmrrMDipYOmY0NsqgWGrMiqMRuvNWWZfqNmCsmQtgQNvLFk2G5Tl9sFIn5TePtElbMRpZ16dL0M7bzxBl9PyBCwINEJ(CBVwcNTtLwcmyLysAiCiDnf6y3sWGZE44wcOAEKPh8iJsJmrrgfqMDipYOmY0NsqgWGrMiqMRuvNWWZfqNmCsmQtgQNvLFk2G5Tl9sFIn5rgCTePtElbgSsmjneoKUMcDSBxBl9fmBCwINEJ(CBVwcgC2dh3sWQsZRaPWHKD0cGUGoLFNlG35DidyWit4xbMdXQo9foBN2hzadgzAubaeQjOs3rbGpJStOgAjC2ovAjcRDQ0U2w6l4TXzjE6n6ZT9AjyWzpCClbVwr7bQQFU0qTJPEb8K(KsKPh8idgJBjC2ovAjk1TbEpi7ABPVGRnolXtVrFUTxlHZ2PslbZ1AQZ2PsQEKRLqpYLMo5TexkFYU0U2w6RFAJZs80B0NB71s4SDQ0sWCTM6SDQKQh5Aj0JCPPtElbRknVcKs7ABPpfjBCwINEJ(CBVwcgC2dh3s4SDAF6ZtoxImkJhz6Zs4SDQ0savtQZ2PsQEKRLqpYLMo5TeED7ABrPvInolXtVrFUTxlHZ2PslbZ1AQZ2PsQEKRLqpYLMo5TeyppCy21UwIq4zfzJV24STeVnolHZ2PslryTtLwINEJ(CBV212sF24SeoBNkTeqFKNYVZTep9g952ETRTfL2gNL4P3Op32RLiDYBj8iLGCOlPavU0cGgwbo0s4SDQ0s4rkb5qxsbQCPfanScCODTTOyBCwINEJ(CBVwc(1ENLOplHZ2PslHdj7OfaDbDk)o3U21sWQsZRaP0gNTL4TXzjC2ovAjCizhTaOlOt535wINEJ(CBV212sF24Sep9g952ETem4ShoULG)gvaabWL7HtIrduQjxixNfeYOmEKrXituKrbKXz70(0NNCUezugzIhzadgzIazUu(KDr7rovslaA4HaNTtLINEJ(CKbmyK5s5t2fTh5ujTaOHhcC2ovkE6n6ZrMOiJciZ66NRqnbv6oka8zKDINEJ(CKjkYWQsZRaPqnbv6oka8zKDc4j9jLitp4rgLgzadgzIazwx)CfQjOs3rbGpJSt80B0NJm4Im4AjC2ovAj8WI56Uq5TRTfL2gNL4P3Op32RLGbN9WXTerGmqF403(5kCoxkE)BKRezadgzG(WPV9Zv4CUumjYOmYeFWSeoBNkTeChgeDHEkbkiPVtL212IITXzjE6n6ZT9AjyWzpCClbunhgnScCOGFGHnlY0dYeVITeoBNkTesvsYkPyoeR603U2wcMnolXtVrFUTxlbdo7HJBjUu(KDr7rovslaA4HaNTtLINEJ(CKjkYe(v4HfJIbQu1cNTt7JmGbJm83OcaiaUCpCsmAGsn5c56SGqMEqgfJmrrgfqMiqgpYdN9cshtvsla6c6u(DU4P3Ophzadgz8ipC2liDmvjTaOlOt535INEJ(CKjkYe(v4HfJIbQu1cNTt7Jm4AjC2ovAjutqLUJcaFgzNDTTe824Sep9g952ETem4ShoULWz70(0NNCUezugpY0hYefzuazuazyvP5vGuWVVGOEYP8Z8ob8K(KsKPh8idgJJmrrMiqM11pxb)aJ(INEJ(CKbxKbmyKrbKHvLMxbsb)aJ(c4j9jLitp4rgmghzIImRRFUc(bg9fp9g95idUidUwcNTtLwc1euP7OaWNr2zxBlbxBCwINEJ(CBVwcNTtLwczPQPW7HhAjyWzpCClX6qSVIDipDlkFoY0dY0prMOiZ6qSVIDipDlkFoYOmYOylbRJPpDDi2xPTL4TRTL(PnolXtVrFUTxlbdo7HJBjuazIazG(WPV9Zv4CUu8(3ixjYagmYa9HtF7NRW5CPysKrzKPpLGm4ImrrgOAEKPh8iJcit8itWbzAubaeQjOs3rbGpJStOgIm4AjC2ovAjKLQMcVhEODTTOizJZs4SDQ0sOMGkDhTrpyGwlXtVrFUTx7Axlb2ZdhMnoBlXBJZs80B0NB71sWGZE44wIgvaaHuLZFs5vrkG3zlYefzIazA7WXB0xewLEsmkqbPyoeR60hzadgzc)kWCiw1PVWz70(wcNTtLwc(9feLvJ2U2w6ZgNL4P3Op32RLGbN9WXTeq1Cy0WkWHc(bg2Sitpit8kgzIImkGmSQ08kqk8WI56Uq5fWt6tkrgLrMGHmGbJm83OcaiaUCpCsmAGsn5c56SGqgLrgfJm4ImrrMiqM2oC8g9fHvPNeJcuqkMdXQo9TeoBNkTe87likRgTDTTO024Sep9g952ETem4ShoULyD9ZveE5o6NSlE6n6ZrMOidRknVcKcpSyUUluEb8K(KslHZ2Pslb)(cI6jNYpZ7SRTffBJZs80B0NB71sWGZE44wcwvAEfifEyXCDxO8c4j9jLwcNTtLwc(bg9TRTLGzJZs80B0NB71sWGZE44wcfqgfqg(BubaeaxUhojgnqPMCHAiYefzuazyvP5vGu4HfZ1DHYlGN0NuImkJmbdzIImkGmrGmxkFYUO9iNkPfan8qGZ2PsXtVrFoYagmYebYSU(5kutqLUJcaFgzN4P3OphzWfzadgzUu(KDr7rovslaA4HaNTtLINEJ(CKjkYSU(5kutqLUJcaFgzN4P3OphzIImkGmSQ08kqkutqLUJcaFgzNaEsFsjYOmYe8ituKXJ8WzVG0XuL0cGUGoLFNlE6n6ZrgWGrMiqgpYdN9cshtvsla6c6u(DU4P3OphzIImSQ08kqk8WI56Uq5fWt6tkrgLrgfJm4Im4Im4ImGbJm83OcaiaUCpCsmAGsn5c56SGqgLrgfJm4ImrrgfqgwvAEfifoKSJwa0f0P87Cb8K(KsKrzKjyidyWid)(cIguoyGwbFKEJ(uVwoYGRLWz7uPLqYkvi2PYfobD7ABj4TXzjE6n6ZT9AjyWzpCClHciJcid)nQaacGl3dNeJgOutUqnezIImkGmSQ08kqk8WI56Uq5fWt6tkrgLrMGHmrrgfqMiqMlLpzx0EKtL0cGgEiWz7uP4P3OphzadgzIazwx)CfQjOs3rbGpJSt80B0NJm4ImGbJmxkFYUO9iNkPfan8qGZ2PsXtVrFoYefzwx)CfQjOs3rbGpJSt80B0NJmrrgfqgwvAEfifQjOs3rbGpJStapPpPezugzcEKjkY4rE4Sxq6yQsAbqxqNYVZfp9g95idyWiteiJh5HZEbPJPkPfaDbDk)ox80B0NJmrrgwvAEfifEyXCDxO8c4j9jLiJYiJIrgCrgCrgCrgWGrg(BubaeaxUhojgnqPMCHCDwqiJYiJIrgCrMOiJcidRknVcKchs2rla6c6u(DUaEsFsjYOmYemKbmyKHFFbrdkhmqRGpsVrFQxlhzW1s4SDQ0sW0EGjXOsqoVciTRTLGRnolXtVrFUTxlbdo7HJBjGQ5WOHvGdf8dmSzrMEqM(ucYefzIazA7WXB0xewLEsmkqbPyoeR603s4SDQ0sWVVGOSA0212s)0gNL4P3Op32RLGbN9WXTe83OcaiaUCpCsmAGsn5c56SGqMEqgfJmrrgfqgwvAEfifEyXCDxO8c4j9jLitpiJsJmrrgfqMiqMlLpzx0EKtL0cGgEiWz7uP4P3OphzadgzIazwx)CfQjOs3rbGpJSt80B0NJmGbJmxkFYUO9iNkPfan8qGZ2PsXtVrFoYefzwx)CfQjOs3rbGpJSt80B0NJmrrgfqgwvAEfifQjOs3rbGpJStapPpPez6bzcUituKXJ8WzVG0XuL0cGUGoLFNlE6n6ZrgWGrMiqgpYdN9cshtvsla6c6u(DU4P3OphzWfzWfzWfzadgz4VrfaqaC5E4Ky0aLAYfY1zbHm9GmXJmrrgfqgwvAEfifoKSJwa0f0P87Cb8K(KsKrzKjyidyWid)(cIguoyGwbFKEJ(uVwoYGRLWz7uPLa4Y9WjXOYfobD7ABrrYgNL4P3Op32RLGbN9WXTerGmTD44n6lcRspjgfOGumhIvD6BjC2ovAj43xquwnA7AxlHx3gNTL4TXzjE6n6ZT9AjyWzpCClbRknVcKcpSyUUluEb8K(KslHZ2Pslb)(cI6jNYpZ7SRTL(SXzjC2ovAj4hy03s80B0NB71U2wuABCwINEJ(CBVwcgC2dh3sWVVGOEYP8Z8oXoSGMedzIImq18itpitFituKjcKPTdhVrFryv6jXOafKI5qSQtFlHZ2PslXdh(jhMDTTOyBCwINEJ(CBVwcgC2dh3sWVVGOEYP8Z8oXoSGMedzIImq18itpitFituKjcKPTdhVrFryv6jXOafKI5qSQtFlHZ2Pslb)(cIYQrBxBlbZgNL4P3Op32RLGbN9WXTe87liQNCk)mVtSdlOjXqMOidRknVcKcpSyUUluEb8K(KslHZ2PslHKvQqStLlCc6212sWBJZs80B0NB71sWGZE44wc(9fe1toLFM3j2Hf0KyituKHvLMxbsHhwmx3fkVaEsFsPLWz7uPLGP9atIrLGCEfqAxBlbxBCwINEJ(CBVwcgC2dh3sebY02HJ3OViSk9KyuGcsXCiw1PVLWz7uPL4Hd)KdZU2w6N24Sep9g952ETeoBNkTeaxUhojgvUWjOBjyWzpCClb)nQaacGl3dNeJgOutUqUoliKPh8it8ituKHvLMxbsb)(cI6jNYpZ7eWt6tkTeSoM(01HyFL2wI3U2wuKSXzjE6n6ZT9AjyWzpCClX66NROrfk3jXOYcEP4P3OphzIImYWR101HyFLIgvOCNeJkl4LiJY4rM(qMOid)nQaacGl3dNeJgOutUqUoliKPh8it8wcNTtLwcGl3dNeJkx4e0TRTL4vInolXtVrFUTxlbdo7HJBjAubaesvo)jLxfPaENTituKbQMxWpWWMfzugpYOylHZ2Pslb)(cIYQrBxBlXhVnolXtVrFUTxlbdo7HJBjAubaesvo)jLxfPaENTituKjcKPTdhVrFryv6jXOafKI5qSQtFKbmyKj8RaZHyvN(cNTt7BjC2ovAj43xquwnA7ABj((SXzjE6n6ZT9AjyWzpCClbunhgnScCOGFGHnlY0dYeVIrMOiJcidRknVcKcpSyUUluEb8K(KsKrzKjyidyWid)nQaacGl3dNeJgOutUqUoliKrzKrXidUituKjcKPTdhVrFryv6jXOafKI5qSQtFlHZ2Pslb)(cIYQrBxBlXR024Sep9g952ETem4ShoULqbKrbKH)gvaabWL7HtIrduQjxOgImrrgwvAEfifEyXCDxO8c4j9jLiJYitWqgCrgWGrg(BubaeaxUhojgnqPMCHCDwqiJYiJIrgCrMOiJcidRknVcKchs2rla6c6u(DUaEsFsjYOmYemKbmyKHFFbrdkhmqRGpsVrFQxlhzW1s4SDQ0sizLke7u5cNGUDTTeVITXzjE6n6ZT9AjyWzpCClHciJcid)nQaacGl3dNeJgOutUqnezIImSQ08kqk8WI56Uq5fWt6tkrgLrMGHm4ImGbJm83OcaiaUCpCsmAGsn5c56SGqgLrgfJm4ImrrgfqgwvAEfifoKSJwa0f0P87Cb8K(KsKrzKjyidyWid)(cIguoyGwbFKEJ(uVwoYGRLWz7uPLGP9atIrLGCEfqAxBlXhmBCwINEJ(CBVwcgC2dh3savZHrdRahk4hyyZIm9Gm9PeKjkYebY02HJ3OViSk9KyuGcsXCiw1PVLWz7uPLGFFbrz1OTRTL4dEBCwINEJ(CBVwcgC2dh3sOaYOaYOaYOaYWFJkaGa4Y9WjXObk1KlKRZccz6bzumYefzIazAubaeQjOs3rbGpJStOgIm4ImGbJm83OcaiaUCpCsmAGsn5c56SGqMEqgLgzWfzIImSQ08kqk8WI56Uq5fWt6tkrMEqgLgzWfzadgz4VrfaqaC5E4Ky0aLAYfY1zbHm9GmXJm4ImrrgfqgwvAEfifoKSJwa0f0P87Cb8K(KsKrzKjyidyWid)(cIguoyGwbFKEJ(uVwoYGRLWz7uPLa4Y9WjXOYfobD7ABj(GRnolXtVrFUTxlbdo7HJBjIazA7WXB0xewLEsmkqbPyoeR603s4SDQ0sWVVGOSA021U21s0(q5uPTL(usFkrj91xFwIaomNetAj63rrS)SffbTOiC)hzqM4aDKzidl4Imafez6x8d4Q6TFHmWRuvh45iJSipY4QBr675iddKNyxkq40FCYJmXR4(pY0FRS9H75it)ADi2xr8IDipDlkFE)cz2cz6x7qE6wu(8(fYOq89pCfiC6po5rM47N9FKP)wz7d3ZrM(16qSVI4f7qE6wu(8(fYSfY0V2H80TO859lKrH47F4kq4GWrrazyb3ZrMGhzC2ovIm6rUsbchlHRUGkOLGyiv1(ov2FHoWAjcHfWOVLqrrgfzjOs3Hm97VVGqM(d5GbAr4OOidODdL9)yIbBwqQncwrgJCiv1(ovYGoWgJCizXGWrrrM(rhYaHmXhlY0Ns6tjiCq4OOit)fKNyx2)r4OOitWbzue58ZrM(Xj5it)a8pYlq4OOitWbz6Vv2(W9CKzDi2x6aGmSk5ZovkrMTqg4Xu1oezyvYNDQukq4OOitWbzikYJmv4oKtK(ovImfaY0pC5Ei5GbArMjrgfrfH63eiCuuKj4Gm9NoBCTmM(HkxKPaqgf5vGdrMnW9GKceoiCuuKPFR)DM6EoY0CGcEKHvKn(ImnhBsPazuezShUsKjRm4aYHKaQAKXz7uPezQu3jq4OOiJZ2PsPieEwr24lEaTldcHJIImoBNkLIq4zfzJVTIpgGQ4iCuuKXz7uPuecpRiB8Tv8X4QyKpxFNkr4OOidr6Hsq1ImqF4itJkaW5iJC9vImnhOGhzyfzJVitZXMuImEYrMq4doH1UtIHmJez4vEbchffzC2ovkfHWZkYgFBfFmY0dLGQLkxFLiCC2ovkfHWZkYgFBfFmH1ovIWXz7uPuecpRiB8Tv8Xa9rEk)ohHJZ2PsPieEwr24BR4JrvE6SNm20jpEpsjih6skqLlTaOHvGdr44SDQukcHNvKn(2k(yCizhTaOlOt535XYV27W3hcheokkY0V1)otDphzE7d7qMDipYSGoY4STGiZirgVTpAVrFbchNTtLs8KtYPaW)ipchNTtLYwXhtBhoEJ(XMo5XhwLEsmkqbPyoeR60p22Uw94zvP5vGuivjjRKI5qSQtFb8K(KYEcw011pxHuLKSskMdXQo9fp9g95iCuuKP)0zJRLXImkc2tkJfz8KJm1c6qKPWyCjchNTtLYwXhJdzEE6wq4Zn2bapunhgnScCOGFGHnRYbFWIQq4xbMdXQo9foBN2hm4iwx)CfsvsYkPyoeR60x80B0NJBuOAEb)adBwLXhmeooBNkLTIpMgDvCkGkSl2baF4xbMdXQo9foBN2hm4iwx)CfsvsYkPyoeR60x80B0NJWXz7uPSv8X0CO8WGMel2baFJkaGqnbv6oka8zKDc1qWGd)kWCiw1PVWz70(GbRW66NRWHKD0cGUGoL7K55INEJ(8OHFfEyXOyGkvTWz70(4IWXz7uPSv8XOhmqRKQuu5yKp3yha8k0OcaiutqLUJkx4tSfKqnmAJkaGa4Y9qYbd0kGN0Nu2d(GHlyWoBN2N(8KZLkJVVOk0OcaiutqLUJkx4tSfKqnem4gvaabWL7HKdgOvapPpPSh8bdxeooBNkLTIpgpzxUqxtzUwh7aGxHWVcmhIvD6lC2oTF011pxHuLKSskMdXQo9fp9g954cgC4xHhwmkgOsvlC2oTpchNTtLYwXhJdzEEAOQw(yha8oBN2N(8KZLkJVpWGvaQMxWpWWMvz8blkunhgnScCOGFGHnRY4dELGlchNTtLYwXhdWaFJUkESdaEfc)kWCiw1PVWz70(rxx)CfsvsYkPyoeR60x80B0NJlyWHFfEyXOyGkvTWz70(iCC2ovkBfFmnogTaOlCybjJDaW3OcaiutqLUJkx4tSfKqnmQZ2P9Ppp5Cj(4bdUrfaqaC5Ei5GbAfWt6tk7bJXJ6SDAF6ZtoxIpEeoiCuuKP)Qk3Iezw4Kb9vImQsh7iCC2ovkBfFmQYtN9KYyha87qEL7tjGbhXvQQty45cOtgojg1jd1ZQYpfBW82LEPpXM8GbhXvQQty45I2JCQKwau(jh5r44SDQu2k(yuLNo7jJnDYJ3JucYHUKcu5slaAyf4Wyha8kCP8j7I2JCQKwa0WdboBNkfp9g95rJyD9ZvOMGkDhfa(mYoXtVrFoUGbRqexkFYUGvj)P8CQEaoqbzxq6kLcgnIlLpzx0EKtL0cGgEiWz7uP4P3OphxeooBNkLTIpgv5PZEYytN849iLGCOlPavU0cGgwbom2bapRknVcKcpSyUUluEb8K(KYEIxXrv4s5t2fSk5pLNt1dWbki7csxPuqWGVu(KDr7rovslaA4HaNTtLINEJ(8ORRFUc1euP7OaWNr2jE6n6ZXfHJZ2PszR4JrvE6SNm20jpEpsjih6skqLlTaOHvGdJDaWVoe7RiEXoKNUfLpVhwvAEfifEyXCDxO8c4j9jLTQ0kgHJZ2PszR4JrvE6SNm20jpExcQTNxsHEKfKYkORJDaWZFJkaGa6rwqkRGUMYFJkaGqUolOEIhHJZ2PszR4JrvE6SNm20jpExcQTNxsHEKfKYkORJDaWh(vGP6q(4jTaOEKhwliHZ2P9Jg(v4HfJIbQu1cNTt7JWXz7uPSv8XOkpD2tgB6KhVlb12ZlPqpYcszf01Xoa4zvP5vGu4HfZ1DHYlG35Drv4s5t2fSk5pLNt1dWbki7csxPuWO7qE6wu(8EyvP5vGuWQK)uEovpahOGSlGN0Nu2AFkbm4iUu(KDbRs(t55u9aCGcYUG0vkfexeooBNkLTIpgv5PZEYytN84DjO2EEjf6rwqkRGUo2ba)6qSVI4f7qE6wu(8EyvP5vGu4HfZ1DHYlGN0Nu2AFkbHJZ2PszR4JrvE6SNm20jp(2JCQKwau(jh5JDaWRaRknVcKcpSyUUluEb8oVlk)nQaacGl3dNeJgOutUqUoliLXR4OxkFYUO9iNkPfan8qGZ2PsXtVrFoUGb3OcaiutqLUJcaFgzNqnem4WVcmhIvD6lC2oTpchNTtLYwXhJQ80zpzSPtE8qNmCsmQtgQNvLFk2G5Tl9sFIn5JDaWZQsZRaPWdlMR7cLxapPpPSN(adED9Zv4qYoAbqxqNYDY8CXtVrFoyWqF403(5kCoxkMSNGHWXz7uPSv8XOkpD2tgB6KhFthwLN28tDnPNol2bapRknVcKcPkjzLumhIvD6lGN0NuQCWReWGJyD9ZvivjjRKI5qSQtFXtVrFE0DiVY9PeWGJ4kv1jm8Cb0jdNeJ6KH6zv5NInyE7sV0NytEeooBNkLTIpgv5PZEYytN84vkxsbvb0hg7aGp8RaZHyvN(cNTt7dgCeRRFUcPkjzLumhIvD6lE6n6ZJUd5vUpLagCexPQoHHNlGoz4KyuNmupRk)uSbZBx6L(eBYJWXz7uPSv8XOkpD2tgB6KhpMRpZ16dL0M7bf7aGp8RaZHyvN(cNTt7dgCeRRFUcPkjzLumhIvD6lE6n6ZJUd5vUpLagCexPQoHHNlGoz4KyuNmupRk)uSbZBx6L(eBYJWXz7uPSv8XOkpD2tgB6KhpgSsmjneoKUMcDSh7aGhQMVh8kDuf2H8k3NsadoIRuvNWWZfqNmCsmQtgQNvLFk2G5Tl9sFIn5XfHJZ2PszR4JjS2PYyha8SQ08kqkCizhTaOlOt535c4DEhyWHFfyoeR60x4SDAFWGBubaeQjOs3rbGpJStOgIWrrrM(rFY1NCsmKPF3bQQFUiJICTJPEKzKiJJmHWPGZ2HWXz7uPSv8XuQBd8EqXoa451kApqv9ZLgQDm1lGN0Nu2dEmghHJZ2PszR4JH5An1z7ujvpYn20jp(lLpzxIWXz7uPSv8XWCTM6SDQKQh5gB6KhpRknVcKseooBNkLTIpgOAsD2ovs1JCJnDYJ3Rh7aG3z70(0NNCUuz89HWXz7uPSv8XWCTM6SDQKQh5gB6Khp2ZdhgcheokkYOiw9BidSwFNkr44SDQuk86453xqup5u(zExSdaEwvAEfifEyXCDxO8c4j9jLiCC2ovkfE9wXhd)aJ(iCC2ovkfE9wXhZdh(jhwSdaE(9fe1toLFM3j2Hf0KyrHQ57PVOr02HJ3OViSk9KyuGcsXCiw1PpchNTtLsHxVv8XWVVGOSA0Xoa453xqup5u(zENyhwqtIffQMVN(IgrBhoEJ(IWQ0tIrbkifZHyvN(iCC2ovkfE9wXhJKvQqStLlCc6Xoa453xqup5u(zENyhwqtIfLvLMxbsHhwmx3fkVaEsFsjchNTtLsHxVv8XW0EGjXOsqoVciJDaWZVVGOEYP8Z8oXoSGMelkRknVcKcpSyUUluEb8K(KseooBNkLcVER4J5Hd)Kdl2baFeTD44n6lcRspjgfOGumhIvD6JWXz7uPu41BfFmaxUhojgvUWjOhlRJPpDDi2xj(4JDaWZFJkaGa4Y9WjXObk1KlKRZcQh8XhLvLMxbsb)(cI6jNYpZ7eWt6tkr44SDQuk86TIpgGl3dNeJkx4e0JDaWVU(5kAuHYDsmQSGxkE6n6ZJkdVwtxhI9vkAuHYDsmQSGxQm((IYFJkaGa4Y9WjXObk1KlKRZcQh8XJWXz7uPu41BfFm87likRgDSda(gvaaHuLZFs5vrkG3zBuOAEb)adBwLXRyeooBNkLcVER4JHFFbrz1OJDaW3OcaiKQC(tkVksb8oBJgrBhoEJ(IWQ0tIrbkifZHyvN(Gbh(vG5qSQtFHZ2P9r44SDQuk86TIpg(9feLvJo2bapunhgnScCOGFGHnBpXR4OkWQsZRaPWdlMR7cLxapPpPu5Gbgm)nQaacGl3dNeJgOutUqUoliLvmUrJOTdhVrFryv6jXOafKI5qSQtFeooBNkLcVER4JrYkvi2PYfob9yha8kOa)nQaacGl3dNeJgOutUqnmkRknVcKcpSyUUluEb8K(KsLdgUGbZFJkaGa4Y9WjXObk1KlKRZcszfJBufyvP5vGu4qYoAbqxqNYVZfWt6tkvoyGbZVVGObLdgOvWhP3Op1RLJlchNTtLsHxVv8XW0EGjXOsqoVciJDaWRGc83OcaiaUCpCsmAGsn5c1WOSQ08kqk8WI56Uq5fWt6tkvoy4cgm)nQaacGl3dNeJgOutUqUoliLvmUrvGvLMxbsHdj7OfaDbDk)oxapPpPu5Gbgm)(cIguoyGwbFKEJ(uVwoUiCC2ovkfE9wXhd)(cIYQrh7aGhQMdJgwbouWpWWMTN(us0iA7WXB0xewLEsmkqbPyoeR60hHJZ2PsPWR3k(yaUCpCsmQCHtqp2baVckOGc83OcaiaUCpCsmAGsn5c56SG6rXrJOrfaqOMGkDhfa(mYoHAiUGbZFJkaGa4Y9WjXObk1KlKRZcQhLg3OSQ08kqk8WI56Uq5fWt6tk7rPXfmy(BubaeaxUhojgnqPMCHCDwq9epUrvGvLMxbsHdj7OfaDbDk)oxapPpPu5Gbgm)(cIguoyGwbFKEJ(uVwoUiCC2ovkfE9wXhd)(cIYQrh7aGpI2oC8g9fHvPNeJcuqkMdXQo9r4GWXz7uPuWQsZRaPeVdj7OfaDbDk)ohHJZ2PsPGvLMxbszR4JXdlMR7cLp2bap)nQaacGl3dNeJgOutUqUoliLXR4Ok4SDAF6ZtoxQC8GbhXLYNSlApYPsAbqdpe4SDQu80B0Ndg8LYNSlApYPsAbqdpe4SDQu80B0NhvH11pxHAcQ0Dua4Zi7ep9g95rzvP5vGuOMGkDhfa(mYob8K(KYEWR0GbhX66NRqnbv6oka8zKDINEJ(CCXfHJZ2PsPGvLMxbszR4JH7WGOl0tjqbj9DQm2baFeqF403(5kCoxkE)BKRemyOpC6B)CfoNlftQC8bdHJZ2PsPGvLMxbszR4JrQsswjfZHyvN(Xoa4HQ5WOHvGdf8dmSz7jEfJWXz7uPuWQsZRaPSv8XOMGkDhfa(mYUyha8xkFYUO9iNkPfan8qGZ2PsXtVrFE0WVcpSyumqLQw4SDAFWG5VrfaqaC5E4Ky0aLAYfY1zb1JIJQqeEKho7fKoMQKwa0f0P87CXtVrFoyWEKho7fKoMQKwa0f0P87CXtVrFE0WVcpSyumqLQw4SDAFCr44SDQukyvP5vGu2k(yutqLUJcaFgzxSdaENTt7tFEY5sLX3xufuGvLMxbsb)(cI6jNYpZ7eWt6tk7bpgJhnI11pxb)aJ(INEJ(CCbdwbwvAEfif8dm6lGN0Nu2dEmgp666NRGFGrFXtVrFoU4IWXz7uPuWQsZRaPSv8XilvnfEp8WyzDm9PRdX(kXhFSda(1HyFf7qE6wu(8E6NrxhI9vSd5PBr5ZvwXiCC2ovkfSQ08kqkBfFmYsvtH3dpm2baVcra9HtF7NRW5CP49VrUsWGH(WPV9Zv4CUumPY9PeCJcvZ3dEfIp40OcaiutqLUJcaFgzNqnexeooBNkLcwvAEfiLTIpg1euP7On6bd0IWbHJZ2PsP4s5t2L4jpzb7OfavRYgoLdVtkJDaWdvZl2H80TOXRmgJhfQMdJgwboShfReeooBNkLIlLpzx2k(yA0vXPfaDbD6Zt2f7aGxbwvAEfif87liQNCk)mVtapPpPmQm8AnDDi2xPGFFbr9Kt5N5DkhpUGbRaRknVcKc(bg9fWt6tkJkdVwtxhI9vk4hy0x54XfmyfyvP5vGu4HfZ1DHYlGN0Nug1z70(0NNCUeF84IWXz7uPuCP8j7YwXhdMQd5JN0cG6rEyTGIDaWRaRknVcKcpSyUUluEb8K(KYEc(OSQ08kqkCizhTaOlOt535c4j9jLkZQsZRaPGvj)P8CQEaoqbzxapPpPexWGzvP5vGu4qYoAbqxqNYVZfWt6tk7PpeooBNkLIlLpzx2k(ywqNQMnLAYPafK9yha8nQaac4zbPVusbki7c1qWGBubaeWZcsFPKcuq2PSsn3dfY1zb1t8XJWXz7uPuCP8j7YwXhdqXuLNt9ipC2tBUtg7aGpc(9fe1toLFM3j2Hf0KyiCC2ovkfxkFYUSv8XWQK9CH(Eofq7Kp2bapVwbRs2Zf675uaTtEAJkmfWt6tkXReeooBNkLIlLpzx2k(ycvHdq3Ky0gTl3yha8rWVVGOEYP8Z8oXoSGMedHJZ2PsP4s5t2LTIpMafuZB)jPWlR0t2JDaWVU(5kCizhTaOlOt5ozEU4P3Opp6LYNSlApYPsAbqdpe4SDQuqozbJ2OcaiutqLUJkx4tSfKqnem4lLpzx0EKtL0cGgEiWz7uPGCYcgn8RWdlgfduPQfoBN2hm411pxHdj7OfaDbDk3jZZfp9g95rd)k8WIrXavQAHZ2P9JYQsZRaPWHKD0cGUGoLFNlGN0NuQCWReWGxx)CfoKSJwa0f0PCNmpx80B0Nhn8RWHKDumqLQw4SDAFeooBNkLIlLpzx2k(ycuqnV9NKcVSspzp2baFe87liQNCk)mVtSdlOjXI2OcaiutqLUJkx4tSfKqnmAexkFYUO9iNkPfan8qGZ2Psb5KfmAeRRFUchs2rla6c6uUtMNlE6n6ZbdEDi2xXoKNUfLpVhwvAEfifEyXCDxO8c4j9jLiCC2ovkfxkFYUSv8XaNWq9PtsLHo7Xoa4JGFFbr9Kt5N5DIDybnjgchNTtLsXLYNSlBfFmW7HtIrb0o5LiCq44SDQukWEE4WWZVVGOSA0Xoa4Bubaesvo)jLxfPaENTrJOTdhVrFryv6jXOafKI5qSQtFWGd)kWCiw1PVWz70(iCC2ovkfyppCyTIpg(9feLvJo2bapunhgnScCOGFGHnBpXR4OkWQsZRaPWdlMR7cLxapPpPu5Gbgm)nQaacGl3dNeJgOutUqUoliLvmUrJOTdhVrFryv6jXOafKI5qSQtFeooBNkLcSNhoSwXhd)(cI6jNYpZ7IDaWVU(5kcVCh9t2fp9g95rzvP5vGu4HfZ1DHYlGN0NuIWXz7uPuG98WH1k(y4hy0p2bapRknVcKcpSyUUluEb8K(KseooBNkLcSNhoSwXhJKvQqStLlCc6Xoa4vqb(BubaeaxUhojgnqPMCHAyufyvP5vGu4HfZ1DHYlGN0NuQCWIQqexkFYUO9iNkPfan8qGZ2PsXtVrFoyWrSU(5kutqLUJcaFgzN4P3OphxWGVu(KDr7rovslaA4HaNTtLINEJ(8ORRFUc1euP7OaWNr2jE6n6ZJQaRknVcKc1euP7OaWNr2jGN0NuQCWh1J8WzVG0XuL0cGUGoLFNlE6n6ZbdocpYdN9cshtvsla6c6u(DU4P3OppkRknVcKcpSyUUluEb8K(KsLvmU4IlyW83OcaiaUCpCsmAGsn5c56SGuwX4gvbwvAEfifoKSJwa0f0P87Cb8K(KsLdgyW87liAq5GbAf8r6n6t9A54IWXz7uPuG98WH1k(yyApWKyujiNxbKXoa4vqb(BubaeaxUhojgnqPMCHAyufyvP5vGu4HfZ1DHYlGN0NuQCWIQqexkFYUO9iNkPfan8qGZ2PsXtVrFoyWrSU(5kutqLUJcaFgzN4P3OphxWGVu(KDr7rovslaA4HaNTtLINEJ(8ORRFUc1euP7OaWNr2jE6n6ZJQaRknVcKc1euP7OaWNr2jGN0NuQCWh1J8WzVG0XuL0cGUGoLFNlE6n6ZbdocpYdN9cshtvsla6c6u(DU4P3OppkRknVcKcpSyUUluEb8K(KsLvmU4IlyW83OcaiaUCpCsmAGsn5c56SGuwX4gvbwvAEfifoKSJwa0f0P87Cb8K(KsLdgyW87liAq5GbAf8r6n6t9A54IWXz7uPuG98WH1k(y43xquwn6yha8q1Cy0WkWHc(bg2S90NsIgrBhoEJ(IWQ0tIrbkifZHyvN(iCC2ovkfyppCyTIpgGl3dNeJkx4e0JDaWZFJkaGa4Y9WjXObk1KlKRZcQhfhvbwvAEfifEyXCDxO8c4j9jL9O0rviIlLpzx0EKtL0cGgEiWz7uP4P3Ophm4iwx)CfQjOs3rbGpJSt80B0Ndg8LYNSlApYPsAbqdpe4SDQu80B0NhDD9ZvOMGkDhfa(mYoXtVrFEufyvP5vGuOMGkDhfa(mYob8K(KYEcUr9ipC2liDmvjTaOlOt535INEJ(CWGJWJ8WzVG0XuL0cGUGoLFNlE6n6ZXfxCbdM)gvaabWL7HtIrduQjxixNfupXhvbwvAEfifoKSJwa0f0P87Cb8K(KsLdgyW87liAq5GbAf8r6n6t9A54IWXz7uPuG98WH1k(y43xquwn6yha8r02HJ3OViSk9KyuGcsXCiw1PVDTR1c]] )

end
