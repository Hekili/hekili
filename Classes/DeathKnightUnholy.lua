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


    spec:RegisterPack( "Unholy", 20200124, [[dW0RybqifQEeuK2Kc5tksWOisofr0ReknlHWTisvTls9lQOggvehtOyzkuEgvKmnOOUgrkBtrI(MIeACePkNJks16GIqZtOY9Gs7ti1bHIOwOqvpekImrfjL6IurkTrQifFursHoPIKQwju4LkskzMePs4MePsANcj)ursrdLivQwQIKkpfutvi6QePszRksk4RePs0Ej8xunybhMYIvWJrAYOCzvBgWNbz0a50sTAIuXRjcZMQUnuTBj)w0WPshxrswoKNtY0v66e12veFNkmEOi48kQ1Ri18bQ9JyrmIifWmBViQXCYyoXjXmgM1oXP7utXXKEc4D29cyxJkHbDbCz4xalDRaL(zbSRn7tJjIuaRsze9cyq76QWeD2zOEbjpOPjUZQgx2BBNffzaRZQgN6SaEqU97uFjgeWmBViQXCYyoXjXmgM1oXP7utXyKEcyL7PIOgtAJjGb1m2lXGaMDfvaJPKG0Tcu6NjHP23wqKWuRQHaTemWusa0UUkmrNDgQxqYdAAI7SQXL922zrrgW6SQXPotWatjbmSs2qZKWyXebjmMtgZjemiyGPKaMeiRGUctKGbMscsFsatMXoJeKU2fJeCAq)tFnbdmLeK(KaMuwtoApJewdb9L3aKanlwVDwksytsaDizVHibAwSE7SuAcgykji9jb4e)Kq6UnEpTTDwKqcqconxThH3qGwsOlsatEQPtRMGbMscsFsyQZOT5vo70K1scjajiDpDCejSoUjHslG9TAvIifWxPErVsePiQyerkGFzd(ZeXlGPOEpQnbmsUUEB8Z3KhdjenjarzKWisajxnL7MooIeIJeWSteWgD7SeW4hprZ8eG7LPnJZq3WvIve1yIifWVSb)zI4fWuuVh1MawksGMPNLokn72cIBfJZo1M1OJBDPiHrKGY9EpFne0xLMDBbXTIXzNAZKq0KqmKGKKayWKGuKantplDuA2bA)1OJBDPiHrKGY9EpFne0xLMDG2FsiAsigsqssamysqksGMPNLokT5MuZp7QUgDCRlfjmIeOz6zPJsZUTG4wX4StTzn6gBMeKuaB0TZsap4ZKXta(c68xhFwSIOCkrKc4x2G)mr8cykQ3JAtalfjqZ0ZshL2CtQ5NDvxJoU1LIeIJeMssyejqZ0ZshL2q4Z8eGVGoNDJPrh36srcrtc0m9S0rPPzXEPoJ7BGdKi61OJBDPibjjbWGjbAMEw6O0gcFMNa8f05SBmn64wxksiosymbSr3olbmKSHyTv8eGBtFuUGeRikmlIua)Yg8NjIxatr9EuBc4bzaan6uj8xP4ajIETSljagmjmidaOrNkH)kfhir0ZPPCThPvRrLGeIJeIjgbSr3olb8c6C5AiLlghir0lwrustePa(Ln4pteVaMI69O2eWJtcSBliUvmo7uBwVnvIUGeWgD7SeWajvwDg3M(OEpF4gUyfrnLIifWVSb)zI4fWuuVh1MaMLRMMf91IS9moG3WpFqgvA0XTUuKawsWjcyJUDwcyAw0xlY2Z4aEd)Ive1uuePa(Ln4pteVaMI69O2eWJtcSBliUvmo7uBwVnvIUGeWgD7SeWUYOgyUli(G3uRyfrj9erkGFzd(ZeXlGPOEpQnb8A(xR2q4Z8eGVGoNz41z6x2G)msyejCL6f96jTQZINaC3JaoD7S04DLisyejmidaOLlqPFMRw0lOfKw2LeadMeUs9IE9Kw1zXtaU7raNUDwA8UsejmIeC)Qn3KYHaLYETr3EYjbWGjH18VwTHWN5jaFbDoZWRZ0VSb)zKWisW9R2Ctkhcuk71gD7jNegrc0m9S0rPne(mpb4lOZz3yA0XTUuKq0KWu6esamysyn)RvBi8zEcWxqNZm86m9lBWFgjmIeC)Qne(mhcuk71gD7jxaB0TZsa7irE2K3fhDvwwrVyfr50frkGFzd(ZeXlGPOEpQnb84Ka72cIBfJZo1M1BtLOlisyejmidaOLlqPFMRw0lOfKw2LegrcJtcxPErVEsR6S4ja39iGt3olnExjIegrcJtcR5FTAdHpZta(c6CMHxNPFzd(ZibWGjH1qqF1BJF(MCwFsiosGMPNLokT5MuZp7QUgDCRlLa2OBNLa2rI8SjVlo6QSSIEXkIkgNiIua)Yg8NjIxatr9EuBc4Xjb2Tfe3kgNDQnR3MkrxqcyJUDwcyu766pVlUY1OxSIOIjgrKcyJUDwcy0n3UG4aEd)kb8lBWFMiEXkwbm7aMSFfrkIkgrKcyJUDwcy8UyCa0)0xa)Yg8NjIxSIOgtePa(Ln4pteVaoDfWQVcyJUDwc4jgQTb)fWtmV8fW0m9S0rPvY44zXHmeuo7VgDCRlfjehjinsyejSM)1QvY44zXHmeuo7V(Ln4ptapXq8YWVa2ntFxqCGeXHmeuo7Vyfr5uIifWVSb)zI4fWuuVh1MagjxnL7MoosZoqt7LeIMeMsPrcJibPib3VAidbLZ(Rn62tojagmjmojSM)1QvY44zXHmeuo7V(Ln4pJeKKegrci56A2bAAVKq0yjbPjGn62zjGne1QZ3eHETIvefMfrkGFzd(ZeXlGPOEpQnbS7xnKHGYz)1gD7jNeadMegNewZ)A1kzC8S4qgckN9x)Yg8NjGn62zjGh8zY4aYOzXkIsAIifWVSb)zI4fWuuVh1MaEqgaqlxGs)mha9A6zTSljagmj4(vdziOC2FTr3EYjbWGjbPiH18VwTHWN5jaFbDoZWRZ0VSb)zKWisW9R2Ctkhcuk71gD7jNeKuaB0TZsapCK6ij6csSIOMsrKc4x2G)mr8cykQ3JAtalfjmidaOLlqPFMRw0lOfKw2LegrcdYaaAGR2JWBiqRgDCRlfjehwsqAKGKKayWKGr3EY5VoEFfjenwsymsyejifjmidaOLlqPFMRw0lOfKw2LeadMegKba0axThH3qGwn64wxksioSKG0ibjfWgD7SeW(gc0Q4shzge(RvSIOMIIifWVSb)zI4fWuuVh1MawksW9RgYqq5S)AJU9KtcJiH18VwTsghploKHGYz)1VSb)zKGKKayWKG7xT5MuoeOu2Rn62tUa2OBNLa2k6vlY8CQ59IveL0tePa(Ln4pteVaMI69O2eWgD7jN)649vKq0yjHXibWGjbPibKCDn7anTxsiASKG0iHrKasUAk3nDCKMDGM2ljenwsykDcjiPa2OBNLa2quRo3v2RUyfr50frkGFzd(ZeXlGPOEpQnbSuKG7xnKHGYz)1gD7jNegrcR5FTALmoEwCidbLZ(RFzd(ZibjjbWGjb3VAZnPCiqPSxB0TNCbSr3olbmqJ(GptMyfrfJterkGFzd(ZeXlGPOEpQnb8GmaGwUaL(zUArVGwqAzxsyejy0TNC(RJ3xrcyjHyibWGjHbzaanWv7r4neOvJoU1LIeIJeGOmsyejy0TNC(RJ3xrcyjHyeWgD7SeWdgepb4lQPsOeRiQyIrePa(Ln4pteVaMI69O2eWBJFsiAsymNqcGbtcJtcFQKBx3Z0id3TliUH767vMDoudzts)YFb11jbWGjHXjHpvYTR7z6jTQZINaC2XB1fWgD7SeWYQZ794kXkIkMXerkGFzd(ZeXlGn62zjGTPvGmKP4azT8eG7Moosatr9EuBcyPiHRuVOxpPvDw8eG7EeWPBNL(Ln4pJegrcJtcR5FTA5cu6N5aOxtpRFzd(ZibjjbWGjbPiHXjHRuVOxtZI9sDg33ahir0RXnPtIiHrKW4KWvQx0RN0QolEcWDpc40TZs)Yg8NrcskGld)cyBAfidzkoqwlpb4UPJJeRiQyCkrKc4x2G)mr8cyJUDwcyBAfidzkoqwlpb4UPJJeWuuVh1MaMMPNLokT5MuZp7QUgDCRlfjehjedMjHrKGuKWvQx0RPzXEPoJ7BGdKi614M0jrKayWKWvQx0RN0QolEcWDpc40TZs)Yg8NrcJiH18VwTCbk9ZCa0RPN1VSb)zKGKc4YWVa2MwbYqMIdK1YtaUB64iXkIkgmlIua)Yg8NjIxaB0TZsaBtRazitXbYA5ja3nDCKaMI69O2eWBJF(MCwFsiosGMPNLokT5MuZp7QUgDCRlfjelj4uywaxg(fW20kqgYuCGSwEcWDthhjwruXinrKc4x2G)mr8cyJUDwcytbAIvxXr20jIttK5fWuuVh1MaM9bzaanYMorCAImpN9bzaaTAnQeKqCKqmc4YWVa2uGMy1vCKnDI40ezEXkIkMPuePa(Ln4pteVa2OBNLa2uGMy1vCKnDI40ezEbmf17rTjGD)QHKneRTINaCB6JYfK2OBp5KWisW9R2Ctkhcuk71gD7jxaxg(fWMc0eRUIJSPteNMiZlwruXmffrkGFzd(ZeXlGn62zjGnfOjwDfhztNionrMxatr9EuBcyAMEw6O0MBsn)SR6A0n2mjmIeKIeUs9IEnnl2l1zCFdCGerVg3KojIegrcBJF(MCwFsiosGMPNLoknnl2l1zCFdCGerVgDCRlfjeljmMtibWGjHXjHRuVOxtZI9sDg33ahir0RXnPtIibjfWLHFbSPanXQR4iB6eXPjY8IvevmsprKc4x2G)mr8cyJUDwcytbAIvxXr20jIttK5fWuuVh1MaEB8Z3KZ6tcXrc0m9S0rPn3KA(zx11OJBDPiHyjHXCIaUm8lGnfOjwDfhztNionrMxSIOIXPlIua)Yg8NjIxaB0TZsapPvDw8eGZoERUaMI69O2eWsrc0m9S0rPn3KA(zx11OBSzsyejW(GmaGg4Q9OUG4os5IPvRrLGeIgljGzsyejCL6f96jTQZINaC3JaoD7S0VSb)zKGKKayWKWGmaGwUaL(zoa610ZAzxsamysW9RgYqq5S)AJU9KlGld)c4jTQZINaC2XB1fRiQXCIisb8lBWFMiEbSr3olbmYWD7cIB4U(ELzNd1q2K0V8xqDDbmf17rTjGPz6zPJsBUj18ZUQRrh36srcXrcJrcGbtcR5FTAdHpZta(c6CMHxNPFzd(ZibWGjbK1m(N8A1gJP0DrcXrcstaxg(fWid3TliUH767vMDoudzts)YFb11fRiQXIrePa(Ln4pteVa2OBNLaEygkRZh(5Mh3kJkGPOEpQnbmntplDuALmoEwCidbLZ(Rrh36srcrtctPtibWGjHXjH18VwTsghploKHGYz)1VSb)zKWisyB8tcrtcJ5esamysyCs4tLC76EMgz4UDbXnCxFVYSZHAiBs6x(lOUUaUm8lGhMHY68HFU5XTYOIve1yJjIua)Yg8NjIxaB0TZsalDUIdkD4psatr9EuBcy3VAidbLZ(Rn62tojagmjmojSM)1QvY44zXHmeuo7V(Ln4pJegrcBJFsiAsymNqcGbtcJtcFQKBx3Z0id3TliUH767vMDoudzts)YFb11fWLHFbS05koO0H)iXkIAmNsePa(Ln4pteVa2OBNLagY8NAE)rk(WnjeWuuVh1Ma29RgYqq5S)AJU9KtcGbtcJtcR5FTALmoEwCidbLZ(RFzd(ZiHrKW24NeIMegZjKayWKW4KWNk5219mnYWD7cIB4U(ELzNd1q2K0V8xqDDbCz4xadz(tnV)ifF4MeIve1yywePa(Ln4pteVa2OBNLagcLfKI7IACZZrg0fWuuVh1MagjxNeIdlj4uKWisqksyB8tcrtcJ5esamysyCs4tLC76EMgz4UDbXnCxFVYSZHAiBs6x(lOUojiPaUm8lGHqzbP4UOg38CKbDXkIAmPjIua)Yg8NjIxatr9EuBcyAMEw6O0gcFMNa8f05SBmn6gBMeadMeC)QHmeuo7V2OBp5KayWKWGmaGwUaL(zoa610ZAzxbSr3olbSBUDwIve1ytPisb8lBWFMiEbmf17rTjGz5QN0iz)RL76ni5Rrh36srcXHLeGOmbSr3olbCkVdOBsiwruJnffrkGFzd(ZeXlGn62zjGPM3Zn62zX9TAfW(wT8YWVa(k1l6vIve1ysprKc4x2G)mr8cyJUDwcyQ59CJUDwCFRwbSVvlVm8lGPz6zPJsjwruJ50frkGFzd(ZeXlGPOEpQnbSr3EY5VoEFfjenwsymbSr3olbmsU4gD7S4(wTcyFRwEz4xaB5fRikNYjIifWVSb)zI4fWgD7SeWuZ75gD7S4(wTcyFRwEz4xad96OMkwXkGDrNM4d2kIuevmIifWgD7SeWU52zjGFzd(ZeXlwruJjIuaB0TZsaJSwDo7gta)Yg8NjIxSIOCkrKc4x2G)mr8c4YWVa2MwbYqMIdK1YtaUB64ibSr3olbSnTcKHmfhiRLNaC30XrIvefMfrkGFzd(ZeXlGz3BZc4XeWgD7SeWgcFMNa8f05SBmXkwbmntplDukrKIOIrePa2OBNLa2q4Z8eGVGoNDJjGFzd(ZeXlwruJjIua)Yg8NjIxatr9EuBcy2hKba0axTh1fe3rkxmTAnQeKq0yjbmlGn62zjGn3KA(zx1fRikNsePa(Ln4pteVaMI69O2eWJtciRz8p51QngtPpMqRwfjagmjGSMX)KxR2ymLUlsiAsigPjGn62zjGzgsc(ISsbKiCB7SeRikmlIua)Yg8NjIxatr9EuBcyKC1uUB64in7anTxsiosigmlGn62zjGvY44zXHmeuo7VyfrjnrKc4x2G)mr8cykQ3JAtaFL6f96jTQZINaC3JaoD7S0VSb)zKayWKGuKWvQx0RPzXEPoJ7BGdKi61VSb)zKWisW9R2Ctkhcuk71gD7jNeKKeadMeyFqgaqdC1EuxqChPCX0Q1OsqcXrcyMegrcJtcsrcFQKBx3Z0id3TliUH767vMDoudzts)YFb11jbWGjbB6J69ACdswXta(c6C2nM(Ln4pJeKKeadMeOz6zPJsBUj18ZUQRrh36srcXrcJrcJibPiHpvYTR7zAKH72fe3WD99kZohQHSjPF5VG66KayWKGn9r9EnUbjR4jaFbDo7gt)Yg8NrcskGn62zjGLlqPFMdGEn9SyfrnLIifWVSb)zI4fWuuVh1Ma2OBp58xhVVIeIgljmgjmIeKIeKIeOz6zPJsZUTG4wX4StTzn64wxksioSKaeLrcJiHXjH18Vwn7aT)6x2G)msqssamysqksGMPNLokn7aT)A0XTUuKqCyjbikJegrcR5FTA2bA)1VSb)zKGKKGKcyJUDwcy5cu6N5aOxtplwrutrrKc4x2G)mr8cyJUDwcyvk75OBUhjGPOEpQnb8AiOV6TXpFtoRpjehji9iHrKWAiOV6TXpFtoRpjenjGzbmDM6pFne0xLiQyeRikPNisb8lBWFMiEbmf17rTjGLIegNeqwZ4FYRvBmMsFmHwTksamysaznJ)jVwTXykDxKq0KWyoHeKKegrci56KqCyjbPiHyibPpjmidaOLlqPFMdGEn9Sw2LeKuaB0TZsaRszphDZ9iXkIYPlIuaB0TZsalxGs)mFW3qGwb8lBWFMiEXkwbm0RJAQisruXiIua)Yg8NjIxatr9EuBc4bzaaTsMXEXzzIRr3OljmIegNeMyO2g8x7MPVlioqI4qgckN9NeadMeC)QHmeuo7V2OBp5cyJUDwcy2TfeNMTxSIOgtePa(Ln4pteVaMI69O2eWi5QPC30XrA2bAAVKqCKqmyMegrcsrc0m9S0rPn3KA(zx11OJBDPiHOjbPrcGbtcSpidaObUApQliUJuUyA1AujiHOjbmtcsscJiHXjHjgQTb)1Uz67cIdKioKHGYz)fWgD7SeWSBlionBVyfr5uIifWVSb)zI4fWuuVh1MaEn)Rv7E12(x0RFzd(ZiHrKantplDuAZnPMF2vDn64wxkbSr3olbm72cIBfJZo1MfRikmlIua)Yg8NjIxatr9EuBcyAMEw6O0MBsn)SR6A0XTUucyJUDwcy2bA)fRikPjIua)Yg8NjIxatr9EuBcyPibPib2hKba0axTh1fe3rkxmTSljmIeOz6zPJsBUj18ZUQRrh36srcrtcsJeKKeadMeyFqgaqdC1EuxqChPCX0Q1OsqcrtcyMeKKegrcsrc0m9S0rPne(mpb4lOZz3yA0XTUuKq0KG0ibWGjb2TfexIQHaTAwRSb)5wUmsqsbSr3olbSIMYiOZvlQL4Ive1ukIua)Yg8NjIxatr9EuBcyPibPib2hKba0axTh1fe3rkxmTSljmIeOz6zPJsBUj18ZUQRrh36srcrtcsJeKKeadMeyFqgaqdC1EuxqChPCX0Q1OsqcrtcyMeKKegrcsrc0m9S0rPne(mpb4lOZz3yA0XTUuKq0KG0ibWGjb2TfexIQHaTAwRSb)5wUmsqsbSr3olbm1Bo6cIRazS0HsSIOMIIifWVSb)zI4fWuuVh1MagjxnL7MoosZoqt7LeIJegZjKWisyCsyIHABWFTBM(UG4ajIdziOC2FbSr3olbm72cItZ2lwrusprKc4x2G)mr8cykQ3JAtalfjifjifjifjW(GmaGg4Q9OUG4os5IPvRrLGeIJeWmjmIegNegKba0YfO0pZbqVMEwl7scsscGbtcSpidaObUApQliUJuUyA1AujiH4ibNIeKKegrc0m9S0rPn3KA(zx11OJBDPiH4ibNIeKKeadMeyFqgaqdC1EuxqChPCX0Q1OsqcXrcXqcsscJibPibAMEw6O0gcFMNa8f05SBmn64wxksiAsqAKayWKa72cIlr1qGwnRv2G)ClxgjiPa2OBNLag4Q9OUG4Qf1sCXkIYPlIua)Yg8NjIxatr9EuBc4XjHjgQTb)1Uz67cIdKioKHGYz)fWgD7SeWSBlionBVyfRa2YlIuevmIifWVSb)zI4fWuuVh1MaMMPNLokT5MuZp7QUgDCRlLa2OBNLaMDBbXTIXzNAZIve1yIifWgD7SeWSd0(lGFzd(ZeXlwruoLisb8lBWFMiEbmf17rTjGz3wqCRyC2P2SEBQeDbrcJibKCDsiosymsyejmojmXqTn4V2ntFxqCGeXHmeuo7Va2OBNLa(Un74nvSIOWSisb8lBWFMiEbmf17rTjGz3wqCRyC2P2SEBQeDbrcJibKCDsiosymsyejmojmXqTn4V2ntFxqCGeXHmeuo7Va2OBNLaMDBbXPz7fRikPjIua)Yg8NjIxatr9EuBcy2Tfe3kgNDQnR3MkrxqKWisGMPNLokT5MuZp7QUgDCRlLa2OBNLawrtze05Qf1sCXkIAkfrkGFzd(ZeXlGPOEpQnbm72cIBfJZo1M1BtLOlisyejqZ0ZshL2CtQ5NDvxJoU1LsaB0TZsat9MJUG4kqglDOeRiQPOisb8lBWFMiEbmf17rTjGhNeMyO2g8x7MPVlioqI4qgckN9xaB0TZsaF3MD8MkwrusprKc4x2G)mr8cyJUDwcyGR2J6cIRwulXfWuuVh1MaM9bzaanWv7rDbXDKYftRwJkbjehwsigsyejqZ0ZshLMDBbXTIXzNAZA0XTUucy6m1F(AiOVkruXiwruoDrKc4x2G)mr8cykQ3JAtaVM)1QhKrQTliUkrxPFzd(ZiHrKGY9EpFne0xLEqgP2UG4QeDfjenwsymsyejW(GmaGg4Q9OUG4os5IPvRrLGeIdljeJa2OBNLag4Q9OUG4Qf1sCXkIkgNiIua)Yg8NjIxatr9EuBc4bzaaTsMXEXzzIRr3OljmIeqY11Sd00EjHOXscywaB0TZsaZUTG40S9IvevmXiIua)Yg8NjIxatr9EuBc4bzaaTsMXEXzzIRr3OljmIegNeMyO2g8x7MPVlioqI4qgckN9NeadMeC)QHmeuo7V2OBp5cyJUDwcy2TfeNMTxSIOIzmrKc4x2G)mr8cykQ3JAtaJKRMYDthhPzhOP9scXrcXGzsyejifjqZ0ZshL2CtQ5NDvxJoU1LIeIMeKgjagmjW(GmaGg4Q9OUG4os5IPvRrLGeIMeWmjijjmIegNeMyO2g8x7MPVlioqI4qgckN9xaB0TZsaZUTG40S9IvevmoLisb8lBWFMiEbmf17rTjGLIeKIeyFqgaqdC1EuxqChPCX0YUKWisGMPNLokT5MuZp7QUgDCRlfjenjinsqssamysG9bzaanWv7rDbXDKYftRwJkbjenjGzsqssyejifjqZ0ZshL2q4Z8eGVGoNDJPrh36srcrtcsJeadMey3wqCjQgc0QzTYg8NB5YibjfWgD7SeWkAkJGoxTOwIlwruXGzrKc4x2G)mr8cykQ3JAtalfjifjW(GmaGg4Q9OUG4os5IPLDjHrKantplDuAZnPMF2vDn64wxksiAsqAKGKKayWKa7dYaaAGR2J6cI7iLlMwTgvcsiAsaZKGKKWisqksGMPNLokTHWN5jaFbDo7gtJoU1LIeIMeKgjagmjWUTG4suneOvZALn4p3YLrcskGn62zjGPEZrxqCfiJLouIvevmstePa(Ln4pteVaMI69O2eWi5QPC30XrA2bAAVKqCKWyoHegrcJtctmuBd(RDZ03fehirCidbLZ(lGn62zjGz3wqCA2EXkIkMPuePa(Ln4pteVaMI69O2eWsrcsrcsrcsrcSpidaObUApQliUJuUyA1AujiH4ibmtcJiHXjHbzaaTCbk9ZCa0RPN1YUKGKKayWKa7dYaaAGR2J6cI7iLlMwTgvcsiosWPibjjHrKantplDuAZnPMF2vDn64wxksiosWPibjjbWGjb2hKba0axTh1fe3rkxmTAnQeKqCKqmKGKKWisqksGMPNLokTHWN5jaFbDo7gtJoU1LIeIMeKgjagmjWUTG4suneOvZALn4p3YLrcskGn62zjGbUApQliUArTexSIOIzkkIua)Yg8NjIxatr9EuBc4XjHjgQTb)1Uz67cIdKioKHGYz)fWgD7SeWSBlionBVyfRyfWtos1zjIAmNeJt3jo9XKMa2HHQUGucyPlXKN6IAQpQPgXejbsisqNeAC3eTKaqIiHPa7aMSFNcKa6tLCJoJeuj(jbtEtCBpJeOGSc6knbdPl66KqmygtKeWKYAYr7zKWuyne0xDm6TXpFtoR)uGe2KeMcBJF(MCw)PajivmycsQjyiDrxNeIr6Hjscyszn5O9msykSgc6Rog924NVjN1FkqcBsctHTXpFtoR)uGeKkgmbj1emiym1J7MO9msykjbJUDwKGVvRstWqaBYlOejGHBCzVTDwysidyfWUOeO9xaJPKG0Tcu6NjHP23wqKWuRQHaTemWusa0UUkmrNDgQxqYdAAI7SQXL922zrrgW6SQXPotWatjbmSs2qZKWyXebjmMtgZjemiyGPKaMeiRGUctKGbMscsFsatMXoJeKU2fJeCAq)tFnbdmLeK(KaMuwtoApJewdb9L3aKanlwVDwksytsaDizVHibAwSE7SuAcgykji9jb4e)Kq6UnEpTTDwKqcqconxThH3qGwsOlsatEQPtRMGbMscsFsyQZOT5vo70K1scjajiDpDCejSoUjHstWGGbMscoTycNkVNrcdhirNeOj(GTKWWH6sPjbmzk9URIeQSK(GmeoGSNem62zPiHS8ZAcgykjy0TZsPDrNM4d2IfWBkjiyGPKGr3olL2fDAIpyBSyDgitgbdmLem62zP0UOtt8bBJfRZMme(R12olcgykjaxMRcuUKaYAgjmidaCgjOwBvKWWbs0jbAIpyljmCOUuKGvmsWfDPVBUBxqKqRibwwxtWatjbJUDwkTl60eFW2yX6SQmxfOC5Q1wfbdJUDwkTl60eFW2yX6SBUDwemm62zP0UOtt8bBJfRZiRvNZUXiyy0TZsPDrNM4d2glwNLvN37XJOm8J1MwbYqMIdK1YtaUB64icggD7SuAx0Pj(GTXI1zdHpZta(c6C2nweS7TzSJrWGGbMscoTycNkVNrcFYrZKW24NewqNem6MisOvKGnXAVn4VMGHr3olfw8UyCa0)0NGHr3olvSyDEIHABW)ikd)yDZ03fehirCidbLZ(hXeZlFS0m9S0rPvY44zXHmeuo7VgDCRlvCsB0A(xRwjJJNfhYqq5S)6x2G)mcgykjm1z028QiiHP(94QiibRyKqUGoIesiktrWWOBNLkwSoBiQvNVjc9AJObWIKRMYDthhPzhOP9g9ukTrs5(vdziOC2FTr3EYbdE818VwTsghploKHGYz)1VSb)zsocjxxZoqt7nASsJGHr3olvSyDEWNjJdiJMJObW6(vdziOC2FTr3EYbdE818VwTsghploKHGYz)1VSb)zemm62zPIfRZdhPosIUGIObWoidaOLlqPFMdGEn9Sw2fmy3VAidbLZ(Rn62toyWsTM)1Qne(mpb4lOZzgEDM(Ln4pBK7xT5MuoeOu2Rn62tUKemm62zPIfRZ(gc0Q4shzge(RnIgaRudYaaA5cu6N5Qf9cAbPLDhnidaObUApcVHaTA0XTUuXHvAscgSr3EY5VoEFv0yhBKudYaaA5cu6N5Qf9cAbPLDbdEqgaqdC1EeEdbA1OJBDPIdR0KKGHr3olvSyD2k6vlY8CQ59r0ayLY9RgYqq5S)AJU9KpAn)RvRKXXZIdziOC2F9lBWFMKGb7(vBUjLdbkL9AJU9KtWWOBNLkwSoBiQvN7k7vpIgaRr3EY5VoEFv0yhdmyPqY11Sd00EJgR0gHKRMYDthhPzhOP9gn2P0jssWWOBNLkwSod0Op4ZKfrdGvk3VAidbLZ(Rn62t(O18VwTsghploKHGYz)1VSb)zscgS7xT5MuoeOu2Rn62tobdJUDwQyX68GbXta(IAQeQiAaSdYaaA5cu6N5Qf9cAbPLDhz0TNC(RJ3xHngWGhKba0axThH3qGwn64wxQ4GOSrgD7jN)649vyJHGbbdmLeWKKvBItclQlj(QibzLbDcggD7SuXI1zz159ECvena2TXF0J5eWGh)tLC76EMgz4UDbXnCxFVYSZHAiBs6x(lOUoyWJ)PsUDDptpPvDw8eGZoERobdJUDwQyX6SS68EpEeLHFS20kqgYuCGSwEcWDthhfrdGvQRuVOxpPvDw8eG7EeWPBNL(Ln4pB04R5FTA5cu6N5aOxtpRFzd(ZKemyPg)k1l610SyVuNX9nWbse9ACt6KOrJFL6f96jTQZINaC3JaoD7S0VSb)zssWWOBNLkwSolRoV3Jhrz4hRnTcKHmfhiRLNaC30Xrr0ayPz6zPJsBUj18ZUQRrh36sfxmyEKuxPErVMMf7L6mUVboqIOxJBsNebg8vQx0RN0QolEcWDpc40TZs)Yg8NnAn)RvlxGs)mha9A6z9lBWFMKemm62zPIfRZYQZ794rug(XAtRazitXbYA5ja3nDCuena21qqF1XO3g)8n5S(XrZ0ZshL2CtQ5NDvxJoU1LkwNcZemm62zPIfRZYQZ794rug(XAkqtS6koYMorCAImFenaw2hKba0iB6eXPjY8C2hKba0Q1Osexmemm62zPIfRZYQZ794rug(XAkqtS6koYMorCAImFenaw3VAizdXAR4ja3M(OCbPn62t(i3VAZnPCiqPSxB0TNCcggD7SuXI1zz159E8ikd)ynfOjwDfhztNionrMpIgalntplDuAZnPMF2vDn6gBEKuxPErVMMf7L6mUVboqIOxJBsNenAB8Z3KZ6hhntplDuAAwSxQZ4(g4ajIEn64wxQyhZjGbp(vQx0RPzXEPoJ7BGdKi614M0jrssWWOBNLkwSolRoV3Jhrz4hRPanXQR4iB6eXPjY8r0ayxdb9vhJEB8Z3KZ6hhntplDuAZnPMF2vDn64wxQyhZjemm62zPIfRZYQZ794rug(XoPvDw8eGZoEREenawPOz6zPJsBUj18ZUQRr3yZJyFqgaqdC1EuxqChPCX0Q1Osenwmp6k1l61tAvNfpb4UhbC62zPFzd(ZKem4bzaaTCbk9ZCa0RPN1YUGb7(vdziOC2FTr3EYjyy0TZsflwNLvN37XJOm8Jfz4UDbXnCxFVYSZHAiBs6x(lOUEenawAMEw6O0MBsn)SR6A0XTUuXngyWR5FTAdHpZta(c6CMHxNPFzd(ZadgznJ)jVwTXykDxXjncggD7SuXI1zz159E8ikd)yhMHY68HFU5XTYOr0ayPz6zPJsRKXXZIdziOC2Fn64wxQONsNag84R5FTALmoEwCidbLZ(RFzd(ZgTn(JEmNag84FQKBx3Z0id3TliUH767vMDoudzts)YFb11jyy0TZsflwNLvN37XJOm8Jv6Cfhu6WFuenaw3VAidbLZ(Rn62toyWJVM)1QvY44zXHmeuo7V(Ln4pB024p6XCcyWJ)PsUDDptJmC3UG4gURVxz25qnKnj9l)fuxNGHr3olvSyDwwDEVhpIYWpwiZFQ59hP4d3KiIgaR7xnKHGYz)1gD7jhm4XxZ)A1kzC8S4qgckN9x)Yg8NnAB8h9yobm4X)uj3UUNPrgUBxqCd313Rm7COgYMK(L)cQRtWWOBNLkwSolRoV3Jhrz4hleklif3f14MNJmOhrdGfjxpoSo1iP2g)rpMtadE8pvYTR7zAKH72fe3WD99kZohQHSjPF5VG66ssWWOBNLkwSo7MBNvenawAMEw6O0gcFMNa8f05SBmn6gBgmy3VAidbLZ(Rn62toyWdYaaA5cu6N5aOxtpRLDjyGPKG0vRR16QlisyQHgj7FTKG0DVbjFsOvKGrcUOor9otWWOBNLkwSoNY7a6Mer0ayz5QN0iz)RL76ni5Rrh36sfhwikJGHr3olvSyDMAEp3OBNf33QnIYWp2RuVOxrWWOBNLkwSotnVNB0TZI7B1grz4hlntplDukcggD7SuXI1zKCXn62zX9TAJOm8J1YhrdG1OBp58xhVVkASJrWWOBNLkwSotnVNB0TZI7B1grz4hl0RJAkbdcgykjGjNoTKakxB7Siyy0TZsPT8yz3wqCRyC2P2CenawAMEw6O0MBsn)SR6A0XTUuemm62zP0w(yX6m7aT)emm62zP0w(yX68DB2XBAenaw2Tfe3kgNDQnR3MkrxqJqY1JBSrJpXqTn4V2ntFxqCGeXHmeuo7pbdJUDwkTLpwSoZUTG40S9r0ayz3wqCRyC2P2SEBQeDbncjxpUXgn(ed12G)A3m9DbXbsehYqq5S)emm62zP0w(yX6SIMYiOZvlQL4r0ayz3wqCRyC2P2SEBQeDbnIMPNLokT5MuZp7QUgDCRlfbdJUDwkTLpwSot9MJUG4kqglDOIObWYUTG4wX4StTz92uj6cAentplDuAZnPMF2vDn64wxkcggD7SuAlFSyD(Un74nnIga74tmuBd(RDZ03fehirCidbLZ(tWWOBNLsB5JfRZaxTh1fexTOwIhbDM6pFne0xf2yIObWY(GmaGg4Q9OUG4os5IPvRrLioSXmIMPNLokn72cIBfJZo1M1OJBDPiyy0TZsPT8XI1zGR2J6cIRwulXJObWUM)1QhKrQTliUkrxPFzd(ZgPCV3Zxdb9vPhKrQTliUkrxfn2XgX(GmaGg4Q9OUG4os5IPvRrLioSXqWWOBNLsB5JfRZSBlionBFena2bzaaTsMXEXzzIRr3O7iKCDn7anT3OXIzcggD7SuAlFSyDMDBbXPz7JObWoidaOvYm2loltCn6gDhn(ed12G)A3m9DbXbsehYqq5S)Gb7(vdziOC2FTr3EYjyy0TZsPT8XI1z2TfeNMTpIgalsUAk3nDCKMDGM2BCXG5rsrZ0ZshL2CtQ5NDvxJoU1LkAPbgm7dYaaAGR2J6cI7iLlMwTgvIOXSKJgFIHABWFTBM(UG4ajIdziOC2FcggD7SuAlFSyDwrtze05Qf1s8iAaSsjf7dYaaAGR2J6cI7iLlMw2DentplDuAZnPMF2vDn64wxQOLMKGbZ(GmaGg4Q9OUG4os5IPvRrLiAml5iPOz6zPJsBi8zEcWxqNZUX0OJBDPIwAGbZUTG4suneOvZALn4p3YLjjbdJUDwkTLpwSot9MJUG4kqglDOIObWkLuSpidaObUApQliUJuUyAz3r0m9S0rPn3KA(zx11OJBDPIwAscgm7dYaaAGR2J6cI7iLlMwTgvIOXSKJKIMPNLokTHWN5jaFbDo7gtJoU1LkAPbgm72cIlr1qGwnRv2G)ClxMKemm62zP0w(yX6m72cItZ2hrdGfjxnL7MoosZoqt7nUXCYOXNyO2g8x7MPVlioqI4qgckN9NGHr3olL2YhlwNbUApQliUArTepIgaRusjLuSpidaObUApQliUJuUyA1AujIdZJgFqgaqlxGs)mha9A6zTSRKGbZ(GmaGg4Q9OUG4os5IPvRrLioNsYr0m9S0rPn3KA(zx11OJBDPIZPKemy2hKba0axTh1fe3rkxmTAnQeXfJKJKIMPNLokTHWN5jaFbDo7gtJoU1LkAPbgm72cIlr1qGwnRv2G)ClxMKemm62zP0w(yX6m72cItZ2hrdGD8jgQTb)1Uz67cIdKioKHGYz)jyqWWOBNLstZ0ZshLcRHWN5jaFbDo7gJGHr3olLMMPNLokvSyD2CtQ5NDvpIgal7dYaaAGR2J6cI7iLlMwTgvIOXIzcggD7SuAAMEw6OuXI1zMHKGViRuajc32oRiAaSJJSMX)KxR2ymL(ycTAvGbJSMX)KxR2ymLUROJrAemm62zP00m9S0rPIfRZkzC8S4qgckN9pIgalsUAk3nDCKMDGM2BCXGzcggD7SuAAMEw6OuXI1z5cu6N5aOxtphrdG9k1l61tAvNfpb4UhbC62zPFzd(ZadwQRuVOxtZI9sDg33ahir0RFzd(Zg5(vBUjLdbkL9AJU9KljyWSpidaObUApQliUJuUyA1AujIdZJgxQpvYTR7zAKH72fe3WD99kZohQHSjPF5VG66GbBtFuVxJBqYkEcWxqNZUX0VSb)zscgmntplDuAZnPMF2vDn64wxQ4gBKuFQKBx3Z0id3TliUH767vMDoudzts)YFb11bd2M(OEVg3GKv8eGVGoNDJPFzd(ZKKGHr3olLMMPNLokvSyDwUaL(zoa610Zr0ayn62to)1X7RIg7yJKskAMEw6O0SBliUvmo7uBwJoU1LkoSqu2OXxZ)A1Sd0(RFzd(ZKemyPOz6zPJsZoq7VgDCRlvCyHOSrR5FTA2bA)1VSb)zskjbdJUDwknntplDuQyX6SkL9C0n3JIGot9NVgc6RcBmr0ayxdb9vVn(5BYz9Jt6nAne0x924NVjN1pAmtWWOBNLstZ0ZshLkwSoRszphDZ9OiAaSsnoYAg)tETAJXu6Jj0QvbgmYAg)tETAJXu6UIEmNi5iKC94Wkvms)bzaaTCbk9ZCa0RPN1YUssWWOBNLstZ0ZshLkwSolxGs)mFW3qGwcgemm62zP0xPErVcl(Xt0mpb4EzAZ4m0nCvenawKCD924NVjpMOHOSri5QPC30XrXHzNqWWOBNLsFL6f9QyX68Gptgpb4lOZFD85iAaSsrZ0ZshLMDBbXTIXzNAZA0XTUuJuU375RHG(Q0SBliUvmo7uBo6yKemyPOz6zPJsZoq7VgDCRl1iL79E(AiOVkn7aT)rhJKGblfntplDuAZnPMF2vDn64wxQr0m9S0rPz3wqCRyC2P2SgDJnljbdJUDwk9vQx0RIfRZqYgI1wXtaUn9r5ckIgaRu0m9S0rPn3KA(zx11OJBDPIBkhrZ0ZshL2q4Z8eGVGoNDJPrh36sfnntplDuAAwSxQZ4(g4ajIEn64wxkjbdMMPNLokTHWN5jaFbDo7gtJoU1LkUXiyy0TZsPVs9IEvSyDEbDUCnKYfJdKi6JObWoidaOrNkH)kfhir0RLDbdEqgaqJovc)vkoqIONtt5ApsRwJkrCXedbdJUDwk9vQx0RIfRZajvwDg3M(OEpF4gEena2Xz3wqCRyC2P2SEBQeDbrWWOBNLsFL6f9QyX6mnl6Rfz7zCaVH)iAaSSC10SOVwKTNXb8g(5dYOsJoU1LcRtiyy0TZsPVs9IEvSyD2vg1aZDbXh8MAJObWoo72cIBfJZo1M1BtLOlicggD7Su6RuVOxflwNDKipBY7IJUklROpIga7A(xR2q4Z8eGVGoNz41z6x2G)SrxPErVEsR6S4ja39iGt3olnExjA0GmaGwUaL(zUArVGwqAzxWGVs9IE9Kw1zXtaU7raNUDwA8Us0i3VAZnPCiqPSxB0TNCWGxZ)A1gcFMNa8f05mdVot)Yg8NnY9R2Ctkhcuk71gD7jFentplDuAdHpZta(c6C2nMgDCRlv0tPtadEn)RvBi8zEcWxqNZm86m9lBWF2i3VAdHpZHaLYETr3EYjyy0TZsPVs9IEvSyD2rI8SjVlo6QSSI(iAaSJZUTG4wX4StTz92uj6cA0GmaGwUaL(zUArVGwqAz3rJFL6f96jTQZINaC3JaoD7S04DLOrJVM)1Qne(mpb4lOZzgEDM(Ln4pdm41qqF1BJF(MCw)4Oz6zPJsBUj18ZUQRrh36srWWOBNLsFL6f9QyX6mQDD9N3fx5A0hrdGDC2Tfe3kgNDQnR3Mkrxqemm62zP0xPErVkwSoJU52fehWB4xrWGGHr3olLg61rnfl72cItZ2hrdGDqgaqRKzSxCwM4A0n6oA8jgQTb)1Uz67cIdKioKHGYz)bd29RgYqq5S)AJU9KtWWOBNLsd96OMglwNz3wqCA2(iAaSi5QPC30XrA2bAAVXfdMhjfntplDuAZnPMF2vDn64wxQOLgyWSpidaObUApQliUJuUyA1AujIgZsoA8jgQTb)1Uz67cIdKioKHGYz)jyy0TZsPHEDutJfRZSBliUvmo7uBoIga7A(xR29QT9VOx)Yg8NnIMPNLokT5MuZp7QUgDCRlfbdJUDwkn0RJAASyDMDG2)iAaS0m9S0rPn3KA(zx11OJBDPiyy0TZsPHEDutJfRZkAkJGoxTOwIhrdGvkPyFqgaqdC1EuxqChPCX0YUJOz6zPJsBUj18ZUQRrh36sfT0Kemy2hKba0axTh1fe3rkxmTAnQerJzjhjfntplDuAdHpZta(c6C2nMgDCRlv0sdmy2TfexIQHaTAwRSb)5wUmjjyy0TZsPHEDutJfRZuV5OliUcKXshQiAaSsjf7dYaaAGR2J6cI7iLlMw2DentplDuAZnPMF2vDn64wxQOLMKGbZ(GmaGg4Q9OUG4os5IPvRrLiAml5iPOz6zPJsBi8zEcWxqNZUX0OJBDPIwAGbZUTG4suneOvZALn4p3YLjjbdJUDwkn0RJAASyDMDBbXPz7JObWIKRMYDthhPzhOP9g3yoz04tmuBd(RDZ03fehirCidbLZ(tWWOBNLsd96OMglwNbUApQliUArTepIgaRusjLuSpidaObUApQliUJuUyA1AujIdZJgFqgaqlxGs)mha9A6zTSRKGbZ(GmaGg4Q9OUG4os5IPvRrLioNsYr0m9S0rPn3KA(zx11OJBDPIZPKemy2hKba0axTh1fe3rkxmTAnQeXfJKJKIMPNLokTHWN5jaFbDo7gtJoU1LkAPbgm72cIlr1qGwnRv2G)ClxMKemm62zP0qVoQPXI1z2TfeNMTpIga74tmuBd(RDZ03fehirCidbLZ(lwXkea]] )

end
