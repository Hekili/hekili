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


    spec:RegisterPack( "Unholy", 20200204, [[dW0JEbqiHIhHujBsi9jPQIgfuYPGIELusZsiClbsSlu9lbQHjqCmPuwMuvEguknnKkUguQ2MaP(MuvHXjvvY5GsHwNuvvMNqL7Hu2Nq0bHsrwOuQEOuvLMOuvPYffiP2iuk4JqPO0jLQQWkHcVekffZuQQu1nfijTtHQ(PuvP0qHsr1sLQQONcvtvO0vfij2QuvPWxLQkfTxs9xugmfhMQflfpgXKj6YQ2mGpJKrdKtRy1ivkVgPQztPBts7w0VLmCbDCKkvlh0ZjmDLUoj2UuLVlGXlvvvNxQSEPeZhO2pK1TPJvJl99647li9fKG0xqOdVT(WEqWUgF7cVgp0j07uxJNU614bvsqLTtJh6D2YL6y14IsbsUgh0UHI(xWbtnliLgoPudwmQkwFNkjqhydwmQKG14nkJD7psDJgx671X3xq6libPVGqhEB9H9GqhSRXfHNOJVpS3Ngh0iLp1nAC5fenoDHmbvsqLTdz63DFbHmyZKdfOfHbDHmG2nu0)coyQzbP0WjLAWIrvX67ujb6aBWIrLemcd6czWgEduXHDid2gbY0xq6liimqyqxit)fKNux0)qyqxitqbzWMKYlrMGQtkrgSb4FlNJWGUqMGcY0FRS3H7LiZ6qQVSbazivkNDQuGmBHmWtPyDiYqQuo7uPGJWGUqMGcYGxQhzQWDuNw8DQezkaKbB4I9q1Hc0ImtImyt9BdQ5imOlKjOGm9NozCRiySHkxKPaqgS5vGdrMnWD6fCnUDeRqhRg)cXtYf6y1X3Mown(tVXEPUDnobo7HJRXHk557OE2wS2qMirgkIezIImqLCiSWkWHitCidDcIg3j7uPgx9QfSJvamRczKmj8UQqV647thRg)P3yVu3UgNaN9WX14yHmKQSYkqYL3xqmpLm5jEhhEvFsbYefzeH3AzRdP(k4Y7liMNsM8eVdzIezAdzWezadgzWczivzLvGKlpWyphEvFsbYefzeH3AzRdP(k4Ydm2JmrImTHmyImGbJmyHmKQSYkqY9WI42UqX5WR6tkqMOidPkRScKC59feZtjtEI3XH3LDidMACNStLA8gBvswbWwqN98QD6vhp2QJvJ)0BSxQBxJtGZE44ACSqgsvwzfi5EyrCBxO4C4v9jfitCitqJmrrgsvwzfi5ouTJvaSf0zY7so8Q(KcKjsKHuLvwbsoPs5tXLm7aCGcsohEvFsbYGjYagmYqQYkRaj3HQDScGTGotExYHx1NuGmXHm9PXDYovQXPuCOC8KvamVLdRfKE1XthDSA8NEJ9sD7ACcC2dhxJ3OaaWHNqV9cbdOGKZvcrgWGrMgfaao8e6TxiyafKCgPuY9qUyDc9itCitBTPXDYovQXxqNPKnLskzafKC9QJh76y14p9g7L6214e4ShoUgpgKrEFbX8uYKN4D8Di0pjLg3j7uPghOikIlzElho7zn3v1Ro(GwhRg)P3yVu3UgNaN9WX14YA5KkjpxOVxYaSU6znkWKdVQpPazOHmbrJ7KDQuJtQK8CH(EjdW6QxV647h6y14p9g7L6214e4ShoUgpgKrEFbX8uYKN4D8Di0pjLg3j7uPgpuboaDtsXASUy1Ro((Lown(tVXEPUDnobo7HJRXx3(C5ouTJvaSf0zsxnVK)0BSxImrrMlepjN3BetLScGfEiWj7ujxDYcImrrMgfaaUscQSDmXcFsTG4kHidyWiZfINKZ7nIPswbWcpe4KDQKRozbrMOit4xUhwegfOsXYDYo9oYagmYSU95YDOAhRaylOZKUAEj)P3yVezIImHF5EyryuGkfl3j707ituKHuLvwbsUdv7yfaBbDM8UKdVQpPazIezc6GGmGbJmRBFUChQ2Xka2c6mPRMxYF6n2lrMOit4xUdv7yuGkfl3j707ACNStLA8af0k79jzWlQ0tY1RoESrDSA8NEJ9sD7ACcC2dhxJhdYiVVGyEkzYt8o(oe6NKczIImnkaaCLeuz7yIf(KAbXvcrMOitmiZfINKZ7nIPswbWcpe4KDQKRozbrMOitmiZ62Nl3HQDScGTGot6Q5L8NEJ9sKbmyKzDi1x(oQNTftohzIdzivzLvGK7HfXTDHIZHx1NuOXDYovQXduqRS3NKbVOspjxV64Bli6y14p9g7L6214e4ShoUgpgKrEFbX8uYKN4D8Di0pjLg3j7uPghoHH2ZMKjcDY1Ro(2AthRg3j7uPghEpCskgG1vVqJ)0BSxQBxV6vJlpGRyxDS64BthRg3j7uPgxDsjda(3Y14p9g7L621Ro((0XQXF6n2l1TRXRqnU4Rg3j7uPgVNdhVXEnEp3QCnoPkRScKCHIQALmkhsvD2ZHx1NuGmXHmyhzIImRBFUCHIQALmkhsvD2ZF6n2l149CilD1RXdRYojfdOGmkhsvD2RxD8yRown(tVXEPUDnobo7HJRXHk5qyHvGd5YdmKzrMirMGg7ituKblKj8lNYHuvN9CNStVJmGbJmXGmRBFUCHIQALmkhsvD2ZF6n2lrgmrMOidujpxEGHmlYejnKb7ACNStLAChs88STGWNRE1XthDSA8NEJ9sD7ACcC2dhxJh(Lt5qQQZEUt2P3rgWGrMyqM1TpxUqrvTsgLdPQo75p9g7LACNStLA8gBvsgGcStV64XUown(tVXEPUDnobo7HJRXBuaa4kjOY2XaGpBPJReImGbJmHF5uoKQ6SN7KD6DKbmyKblKzD7ZL7q1owbWwqNjD18s(tVXEjYefzc)Y9WIWOavkwUt2P3rgm14ozNk14nhkoK(jP0Ro(GwhRg)P3yVu3UgNaN9WX14yHmnkaaCLeuz7yIf(KAbXvcrMOitJcaah4I9q1Hc0YHx1NuGmXrdzWoYGjYagmY4KD6D2ZRoxGmrsdz6dzIImyHmnkaaCLeuz7yIf(KAbXvcrgWGrMgfaaoWf7HQdfOLdVQpPazIJgYGDKbtnUt2PsnUDOaTcgDtrsP(C1Ro((Hown(tVXEPUDnobo7HJRXXczc)YPCiv1zp3j707ituKzD7ZLluuvRKr5qQQZE(tVXEjYGjYagmYe(L7HfHrbQuSCNStVRXDYovQX9KCXcDlJ4wRE1X3V0XQXF6n2l1TRXjWzpCCnUt2P3zpV6CbYejnKPpKbmyKblKbQKNlpWqMfzIKgYGDKjkYavYHWcRahYLhyiZImrsdzc6GGmyQXDYovQXDiXZZcvSIRxD8yJ6y14p9g7L6214e4ShoUghlKj8lNYHuvN9CNStVJmrrM1TpxUqrvTsgLdPQo75p9g7LidMidyWit4xUhwegfOsXYDYo9Ug3j7uPghyGVXwLuV64Bli6y14p9g7L6214e4ShoUgVrbaGRKGkBhtSWNuliUsiYefzCYo9o75vNlqgAitBidyWitJcaah4I9q1Hc0YHx1NuGmXHmuejYefzCYo9o75vNlqgAitBACNStLA8gNIvaSfoe6f6vhFBTPJvJ)0BSxQBxJtGZE44A8DupYejY0xqqgWGrMyqMt3vMWWl5qxnCskMRgANvrEg1q59k7YEsn5rgWGrMyqMt3vMWWl59gXujRayYRoIRXDYovQXveNn7vf6vhFB9PJvJ)0BSxQBxJ7KDQuJ7Tia5qxWaQCzfalScCOgNaN9WX14yHmxiEsoV3iMkzfal8qGt2Ps(tVXEjYefzIbzw3(C5kjOY2XaGpBPJ)0BSxImyImGbJmyHmXGmxiEsoNuP8P4sMDaoqbjNR60TcImrrMyqMlepjN3BetLScGfEiWj7uj)P3yVezWuJNU614Elcqo0fmGkxwbWcRahQxD8THT6y14p9g7L6214ozNk14Elcqo0fmGkxwbWcRahQXjWzpCCnoPkRScKCpSiUTluCo8Q(KcKjoKPn6GmrrgSqMlepjNtQu(uCjZoahOGKZvD6wbrgWGrMlepjN3BetLScGfEiWj7uj)P3yVezIImRBFUCLeuz7yaWNT0XF6n2lrgm14PREnU3IaKdDbdOYLvaSWkWH6vhFB0rhRg)P3yVu3Ug3j7uPg3BraYHUGbu5Ykawyf4qnobo7HJRX3r9STyY5itCidPkRScKCpSiUTluCo8Q(KcKPvKbBPJgpD1RX9weGCOlyavUScGfwbouV64Bd76y14p9g7L6214ozNk14UauppVGb9wkiJuq3QXjWzpCCnU8nkaaCO3sbzKc6wM8nkaaCX6e6rM4qM204PREnUla1ZZlyqVLcYif0T6vhFBbTown(tVXEPUDnUt2PsnUla1ZZlyqVLcYif0TACcC2dhxJh(LtP4q54jRayElhwliUt2P3rMOit4xUhwegfOsXYDYo9UgpD1RXDbOEEEbd6TuqgPGUvV64BRFOJvJ)0BSxQBxJ7KDQuJ7cq988cg0BPGmsbDRgNaN9WX14KQSYkqY9WI42UqX5W7YoKjkYGfYCH4j5CsLYNIlz2b4afKCUQt3kiYefz2r9STyY5itCidPkRScKCsLYNIlz2b4afKCo8Q(KcKPvKPVGGmGbJmXGmxiEsoNuP8P4sMDaoqbjNR60TcImyQXtx9ACxaQNNxWGElfKrkOB1Ro(26x6y14p9g7L6214ozNk14UauppVGb9wkiJuq3QXjWzpCCn(oQNTftohzIdzivzLvGK7HfXTDHIZHx1NuGmTIm9fenE6QxJ7cq988cg0BPGmsbDRE1X3g2Oown(tVXEPUDnUt2PsnEVrmvYkaM8QJ4ACcC2dhxJJfYqQYkRaj3dlIB7cfNdVl7qMOiJ8nkaaCGl2dNKIfOusjxSoHEKjsAidDqMOiZfINKZ7nIPswbWcpe4KDQK)0BSxImyImGbJmnkaaCLeuz7yaWNT0XvcrgWGrMWVCkhsvD2ZDYo9UgpD1RX7nIPswbWKxDexV647li6y14p9g7L6214ozNk14qxnCskMRgANvrEg1q59k7YEsn514e4ShoUgNuLvwbsUhwe32fkohEvFsbYehY0hYagmYSU95YDOAhRaylOZKUAEj)P3yVezadgzG(izV3ZL7sPGpjYehYGDnE6QxJdD1WjPyUAODwf5zudL3RSl7j1KxV647RnDSA8NEJ9sD7ACNStLA8MoQkpR5N5wvpDIgNaN9WX14KQSYkqYfkQQvYOCiv1zphEvFsbYejYe0bbzadgzIbzw3(C5cfv1kzuoKQ6SN)0BSxImrrMDupYejY0xqqgWGrMyqMt3vMWWl5qxnCskMRgANvrEg1q59k7YEsn514PREnEthvLN18ZCRQNorV647RpDSA8NEJ9sD7ACNStLAC62fmqva7HACcC2dhxJh(Lt5qQQZEUt2P3rgWGrMyqM1TpxUqrvTsgLdPQo75p9g7LituKzh1JmrIm9feKbmyKjgK50DLjm8so0vdNKI5QH2zvKNrnuEVYUSNutEnE6QxJt3UGbQcypuV647dB1XQXF6n2l1TRXDYovQXPC7jU1EOG1CNEnobo7HJRXd)YPCiv1zp3j707idyWitmiZ62NlxOOQwjJYHuvN98NEJ9sKjkYSJ6rMirM(ccYagmYedYC6UYegEjh6QHtsXC1q7SkYZOgkVxzx2tQjVgpD1RXPC7jU1EOG1CNE9QJVp6OJvJ)0BSxQBxJ7KDQuJtbRKsWcHJQBzqN6ACcC2dhxJdvYJmXrdzWwKjkYGfYSJ6rMirM(ccYagmYedYC6UYegEjh6QHtsXC1q7SkYZOgkVxzx2tQjpYGPgpD1RXPGvsjyHWr1TmOtD9QJVpSRJvJ)0BSxQBxJtGZE44ACsvwzfi5ouTJvaSf0zY7so8USdzadgzc)YPCiv1zp3j707idyWitJcaaxjbv2oga8zlDCLqnUt2PsnEyTtL6vhFFbTown(tVXEPUDnobo7HJRXL1Y7nqf7ZLfADkLZHx1NuGmXrdzOisnUt2PsnEPSnW70RxD891p0XQXF6n2l1TRXDYovQXjU1YCYovYSJy142rSS0vVg)cXtYf6vhFF9lDSA8NEJ9sD7ACNStLACIBTmNStLm7iwnUDellD1RXjvzLvGuOxD89HnQJvJ)0BSxQBxJtGZE44ACNStVZEE15cKjsAitFACNStLACOsYCYovYSJy142rSS0vVg3RRxD8yBq0XQXF6n2l1TRXDYovQXjU1YCYovYSJy142rSS0vVgN65HdrV6vJhcpPuB8vhRo(20XQXDYovQXdRDQuJ)0BSxQBxV647thRg3j7uPgh6J4m5DPg)P3yVu3UE1XJT6y14p9g7L6214PREnU3IaKdDbdOYLvaSWkWHACNStLACVfbih6cgqLlRayHvGd1RoE6OJvJ)0BSxQBxJlV17049PXDYovQXDOAhRaylOZK3L6vVACsvwzfif6y1X3MownUt2PsnUdv7yfaBbDM8UuJ)0BSxQBxV647thRg)P3yVu3UgNaN9WX14Y3OaaWbUypCskwGsjLCX6e6rMiPHm0bzIImyHmXGmxiEsoV3iMkzfal8qGt2Ps(tVXEjYagmYCH4j58EJyQKvaSWdbozNk5p9g7LituKblKzD7ZLRKGkBhda(SLo(tVXEjYefzivzLvGKRKGkBhda(SLoo8Q(KcKjoAid2ImGbJmXGmRBFUCLeuz7yaWNT0XF6n2lrgmrgm14ozNk14EyrCBxO46vhp2QJvJ)0BSxQBxJtGZE44A8yqgOps279C5Uuk4V)pIvGmGbJmqFKS375YDPuWNezIezAd7ACNStLACPdPNTqpfafu13Ps9QJNo6y14p9g7L6214e4ShoUghQKdHfwboKlpWqMfzIdzAJoACNStLACHIQALmkhsvD2RxD8yxhRg)P3yVu3UgNaN9WX14xiEsoV3iMkzfal8qGt2Ps(tVXEjYefzc)Y9WIWOavkwUt2P3rgWGrg5Buaa4axShojflqPKsUyDc9itCidDqMOidwitmiJ3YHZEUQtPiyfaBbDM8UK)0BSxImGbJmElho75QoLIGvaSf0zY7s(tVXEjYefzc)Y9WIWOavkwUt2P3rgm14ozNk14kjOY2XaGpBPtV64dADSA8NEJ9sD7ACcC2dhxJ7KD6D2ZRoxGmrsdz6dzIImyHmyHmKQSYkqYL3xqmpLm5jEhhEvFsbYehnKHIirMOitmiZ62NlxEGXE(tVXEjYGjYagmYGfYqQYkRajxEGXEo8Q(KcKjoAidfrImrrM1TpxU8aJ98NEJ9sKbtKbtnUt2PsnUscQSDma4Zw60Ro((Hown(tVXEPUDnUt2PsnUOuSm49Wd14e4ShoUgFDi1x(oQNTftohzIdz6xituKzDi1x(oQNTftohzIezOJgN0rSNToK6RqhFB6vhF)shRg)P3yVu3UgNaN9WX14yHmXGmqFKS375YDPuWF)FeRazadgzG(izV3ZL7sPGpjYejY0xqqgmrMOidujpYehnKblKPnKjOGmnkaaCLeuz7yaWNT0Xvcrgm14ozNk14IsXYG3dpuV64Xg1XQXDYovQXvsqLTJ1yhkqRg)P3yVu3UE1Rg3RRJvhFB6y14p9g7L6214e4ShoUgNuLvwbsUhwe32fkohEvFsHg3j7uPgxEFbX8uYKN4D6vhFF6y14ozNk14Ydm2RXF6n2l1TRxD8yRown(tVXEPUDnobo7HJRXL3xqmpLm5jEhFhc9tsHmrrgOsEKjoKPpKjkYedY0ZHJ3yppSk7KumGcYOCiv1zVg3j7uPg)HJ8QdrV64PJown(tVXEPUDnobo7HJRXL3xqmpLm5jEhFhc9tsHmrrgOsEKjoKPpKjkYedY0ZHJ3yppSk7KumGcYOCiv1zVg3j7uPgxEFbXi1y1RoESRJvJ)0BSxQBxJtGZE44AC59feZtjtEI3X3Hq)KuituKHuLvwbsUhwe32fkohEvFsHg3j7uPgxqkfi1zIfo0F9QJpO1XQXF6n2l1TRXjWzpCCnU8(cI5PKjpX747qOFskKjkYqQYkRaj3dlIB7cfNdVQpPqJ7KDQuJtSEGjPycqUSci0Ro((Hown(tVXEPUDnobo7HJRXJbz65WXBSNhwLDskgqbzuoKQ6SxJ7KDQuJ)WrE1HOxD89lDSA8NEJ9sD7ACNStLACGl2dNKIjw4q)14e4ShoUgx(gfaaoWf7HtsXcukPKlwNqpYehnKPnKjkYqQYkRajxEFbX8uYKN4DC4v9jfACshXE26qQVcD8TPxD8yJ6y14p9g7L6214e4ShoUgFD7ZL3Oaf7KumrbVG)0BSxImrrgr4Tw26qQVcEJcuStsXef8cKjsAitFituKr(gfaaoWf7HtsXcukPKlwNqpYehnKPnnUt2PsnoWf7HtsXelCO)6vhFBbrhRg)P3yVu3UgNaN9WX14nkaaCHIu(KjRsLdVtwKjkYavYZLhyiZImrsdzOJg3j7uPgxEFbXi1y1Ro(2AthRg)P3yVu3UgNaN9WX14nkaaCHIu(KjRsLdVtwKjkYedY0ZHJ3yppSk7KumGcYOCiv1zpYagmYe(Lt5qQQZEUt2P314ozNk14Y7ligPgRE1X3wF6y14p9g7L6214e4ShoUghQKdHfwboKlpWqMfzIdzAJoituKblKHuLvwbsUhwe32fkohEvFsbYejYGDKbmyKr(gfaaoWf7HtsXcukPKlwNqpYejYqhKbtKjkYedY0ZHJ3yppSk7KumGcYOCiv1zVg3j7uPgxEFbXi1y1Ro(2WwDSA8NEJ9sD7ACcC2dhxJJfYGfYiFJcaah4I9WjPybkLuYvcrMOidPkRScKCpSiUTluCo8Q(KcKjsKb7idMidyWiJ8nkaaCGl2dNKIfOusjxSoHEKjsKHoidMituKblKHuLvwbsUdv7yfaBbDM8UKdVQpPazIezWoYagmYiVVGy0NdfOLlhH3ypZRvImyQXDYovQXfKsbsDMyHd9xV64BJo6y14p9g7L6214e4ShoUghlKblKr(gfaaoWf7HtsXcukPKReImrrgsvwzfi5EyrCBxO4C4v9jfitKid2rgmrgWGrg5Buaa4axShojflqPKsUyDc9itKidDqgmrMOidwidPkRScKChQ2Xka2c6m5DjhEvFsbYejYGDKbmyKrEFbXOphkqlxocVXEMxRezWuJ7KDQuJtSEGjPycqUSci0Ro(2WUown(tVXEPUDnobo7HJRXHk5qyHvGd5YdmKzrM4qM(ccYefzIbz65WXBSNhwLDskgqbzuoKQ6SxJ7KDQuJlVVGyKAS6vhFBbTown(tVXEPUDnobo7HJRXXczWczWczWczKVrbaGdCXE4KuSaLsk5I1j0JmXHm0bzIImXGmnkaaCLeuz7yaWNT0XvcrgmrgWGrg5Buaa4axShojflqPKsUyDc9itCid2ImyImrrgsvwzfi5EyrCBxO4C4v9jfitCid2ImyImGbJmY3OaaWbUypCskwGsjLCX6e6rM4qM2qgmrMOidwidPkRScKChQ2Xka2c6m5DjhEvFsbYejYGDKbmyKrEFbXOphkqlxocVXEMxRezWuJ7KDQuJdCXE4KumXch6VE1X3w)qhRg)P3yVu3UgNaN9WX14XGm9C44n2ZdRYojfdOGmkhsvD2RXDYovQXL3xqmsnw9Qxno1ZdhIowD8TPJvJ)0BSxQBxJtGZE44A8gfaaUqrkFYKvPYH3jlYefzIbz65WXBSNhwLDskgqbzuoKQ6Shzadgzc)YPCiv1zp3j707ACNStLAC59feJuJvV647thRg)P3yVu3UgNaN9WX14qLCiSWkWHC5bgYSitCitB0bzIImyHmKQSYkqY9WI42UqX5WR6tkqMirgSJmGbJmY3OaaWbUypCskwGsjLCX6e6rMirg6GmyImrrMyqMEoC8g75HvzNKIbuqgLdPQo714ozNk14Y7ligPgRE1XJT6y14p9g7L6214e4ShoUgFD7ZLhEXo2NKZF6n2lrMOidPkRScKCpSiUTluCo8Q(KcnUt2PsnU8(cI5PKjpX70RoE6OJvJ)0BSxQBxJtGZE44ACsvwzfi5EyrCBxO4C4v9jfACNStLAC5bg71RoESRJvJ)0BSxQBxJtGZE44ACSqgSqg5Buaa4axShojflqPKsUsiYefzWczivzLvGK7HfXTDHIZHx1NuGmrImyhzIImyHmXGmxiEsoV3iMkzfal8qGt2Ps(tVXEjYagmYedYSU95YvsqLTJbaF2sh)P3yVezWezadgzUq8KCEVrmvYkaw4HaNStL8NEJ9sKjkYSU95YvsqLTJbaF2sh)P3yVezIImKQSYkqYvsqLTJbaF2shhEvFsbYejYe0idMidMidyWiJ8nkaaCGl2dNKIfOusjxSoHEKjsKHoidMituKblKHuLvwbsUdv7yfaBbDM8UKdVQpPazIezWoYGPg3j7uPgxqkfi1zIfo0F9QJpO1XQXF6n2l1TRXjWzpCCnowidwiJ8nkaaCGl2dNKIfOusjxjezIImyHmKQSYkqY9WI42UqX5WR6tkqMirgSJmrrgSqMyqMlepjN3BetLScGfEiWj7uj)P3yVezadgzIbzw3(C5kjOY2XaGpBPJ)0BSxImyImGbJmxiEsoV3iMkzfal8qGt2Ps(tVXEjYefzw3(C5kjOY2XaGpBPJ)0BSxImrrgsvwzfi5kjOY2XaGpBPJdVQpPazIezcAKbtKbtKbmyKr(gfaaoWf7HtsXcukPKlwNqpYejYqhKbtKjkYGfYqQYkRaj3HQDScGTGotExYHx1NuGmrImyhzWuJ7KDQuJtSEGjPycqUSci0Ro((Hown(tVXEPUDnobo7HJRXHk5qyHvGd5YdmKzrM4qM(ccYefzIbz65WXBSNhwLDskgqbzuoKQ6SxJ7KDQuJlVVGyKAS6vhF)shRg)P3yVu3UgNaN9WX14yHmyHmyHmyHmY3OaaWbUypCskwGsjLCX6e6rM4qg6GmrrMyqMgfaaUscQSDma4Zw64kHidMidyWiJ8nkaaCGl2dNKIfOusjxSoHEKjoKbBrgmrMOidPkRScKCpSiUTluCo8Q(KcKjoKbBrgmrgWGrg5Buaa4axShojflqPKsUyDc9itCitBidMituKblKHuLvwbsUdv7yfaBbDM8UKdVQpPazIezWoYagmYiVVGy0NdfOLlhH3ypZRvImyQXDYovQXbUypCskMyHd9xV64Xg1XQXF6n2l1TRXjWzpCCnU8nkaaCGl2dNKIfOusjxSoHEKjoKHoituKblKHuLvwbsUhwe32fkohEvFsbYehYGTituKblKjgK5cXtY59gXujRayHhcCYovYF6n2lrgWGrMyqM1TpxUscQSDma4Zw64p9g7LidyWiZfINKZ7nIPswbWcpe4KDQK)0BSxImrrM1TpxUscQSDma4Zw64p9g7LituKHuLvwbsUscQSDma4Zw64WR6tkqM4qM(bYGjYGjYagmYiFJcaah4I9WjPybkLuYfRtOhzIdzAdzIImyHmKQSYkqYDOAhRaylOZK3LC4v9jfitKid2rgm14ozNk14axShojftSWH(RxD8TfeDSA8NEJ9sD7ACcC2dhxJhdY0ZHJ3yppSk7KumGcYOCiv1zVg3j7uPgxEFbXi1y1RE1RgV3HIPsD89fK(csqARp6OXd4WCskHgVFtSP(Z47pIhB2(hYGmXc6iZOgwWfzakiY0pLhWvSB)ezGNURmWlrgrPEKXv2s13lrgcipPUGJWOF)KhzAJo9pKP)wzVd3lrM(56qQV8247OE2wm58(jYSfY0p3r9STyY59tKbR26)yYry0VFYJmT1V6Fit)TYEhUxIm9Z1HuF5TX3r9STyY59tKzlKPFUJ6zBXKZ7NidwT1)XKJWaHr)HAyb3lrMGgzCYovIm2rScocdnEiSag7140fYeujbv2oKPF39feYGntouGweg0fYaA3qr)l4GPMfKsdNuQblgvfRVtLeOdSblgvsWimOlKbB4nqfh2HmyBeitFbPVGGWaHbDHm9xqEsDr)dHbDHmbfKbBskVezcQoPezWgG)TCocd6czckit)TYEhUxImRdP(YgaKHuPC2PsbYSfYapLI1HidPs5StLcocd6czckidEPEKPc3rDAX3PsKPaqgSHl2dvhkqlYmjYGn1VnOMJWGUqMGcY0F6KXTIGXgQCrMcazWMxboez2a3PxWryGWGUqMG6()jk7LitZbk4rgsP24lY0CQjfCKbBIqE4kqMSYGcihQcOyrgNStLcKPsBhhHbDHmozNkf8q4jLAJV0aSUGEeg0fY4KDQuWdHNuQn(2kTGbQsIWGUqgNStLcEi8KsTX3wPfSRqP(C9DQeHbDHm4PhkavlYa9rImnkaaxImI1xbY0CGcEKHuQn(ImnNAsbY4PezcHpOew7ojfYmcKrw55imOlKXj7uPGhcpPuB8TvAblspuaQwMy9vGWWj7uPGhcpPuB8TvAbhw7ujcdNStLcEi8KsTX3wPfm0hXzY7segozNkf8q4jLAJVTslyfXzZE1isx908weGCOlyavUScGfwboeHHt2PsbpeEsP24BR0c2HQDScGTGotExgH8wVJwFimqyqxitqD))eL9sK59oSdz2r9iZc6iJt2cImJaz8E(y9g75imCYovkOPoPKba)B5imCYovkALwW9C44n2hr6QNwyv2jPyafKr5qQQZ(i65wLtJuLvwbsUqrvTsgLdPQo75WR6tkId7rx3(C5cfv1kzuoKQ6SN)0BSxIWGUqM(tNmUvebY0FSxvebY4PezQf0HitrrKcegozNkfTslyhs88STGWNBedanOsoewyf4qU8adz2idAShfRWVCkhsvD2ZDYo9oyWXSU95YfkQQvYOCiv1zp)P3yVeZOqL8C5bgYSrsd7imCYovkALwWn2QKmafyxedaTWVCkhsvD2ZDYo9oyWXSU95YfkQQvYOCiv1zp)P3yVeHHt2PsrR0cU5qXH0pjvedaTgfaaUscQSDma4Zw64kHGbh(Lt5qQQZEUt2P3bdgR1TpxUdv7yfaBbDM0vZl5p9g7Lrd)Y9WIWOavkwUt2P3XeHHt2PsrR0c2ouGwbJUPiPuFUrma0WQrbaGRKGkBhtSWNuliUsy0gfaaoWf7HQdfOLdVQpPioAyhtWGDYo9o75vNlIKwFrXQrbaGRKGkBhtSWNuliUsiyWnkaaCGl2dvhkqlhEvFsrC0WoMimCYovkALwWEsUyHULrCRnIbGgwHF5uoKQ6SN7KD69ORBFUCHIQALmkhsvD2ZF6n2lXem4WVCpSimkqLIL7KD6DegozNkfTslyhs88SqfR4rma0CYo9o75vNlIKwFGbJfujpxEGHmBK0WEuOsoewyf4qU8adz2iPf0bbtegozNkfTslyGb(gBvYigaAyf(Lt5qQQZEUt2P3JUU95YfkQQvYOCiv1zp)P3yVetWGd)Y9WIWOavkwUt2P3ry4KDQu0kTGBCkwbWw4qOxeXaqRrbaGRKGkBhtSWNuliUsyuNStVZEE15cATbgCJcaah4I9q1Hc0YHx1Nuehfrg1j707SNxDUGwBimqyqxit)vrSLkYSWjP)Razueo1ry4KDQu0kTGveNn7vfrma02r9r2xqadoMt3vMWWl5qxnCskMRgANvrEg1q59k7YEsn5bdoMt3vMWWl59gXujRayYRoIJWWj7uPOvAbRioB2Rgr6QNM3IaKdDbdOYLvaSWkWHrma0W6cXtY59gXujRayHhcCYovYF6n2lJgZ62Nlxjbv2oga8zlD8NEJ9smbdgRyUq8KCoPs5tXLm7aCGcsox1PBfmAmxiEsoV3iMkzfal8qGt2Ps(tVXEjMimCYovkALwWkIZM9QrKU6P5Tia5qxWaQCzfalScCyedansvwzfi5EyrCBxO4C4v9jfX1gDII1fINKZjvkFkUKzhGduqY5QoDRGGbFH4j58EJyQKvaSWdbozNk5p9g7Lrx3(C5kjOY2XaGpBPJ)0BSxIjcdNStLIwPfSI4SzVAePREAElcqo0fmGkxwbWcRahgXaqBDi1xEB8DupBlMCECKQSYkqY9WI42UqX5WR6tkAfBPdcdNStLIwPfSI4SzVAePREAUauppVGb9wkiJuq3gXaqt(gfaao0BPGmsbDlt(gfaaUyDc9X1gcdNStLIwPfSI4SzVAePREAUauppVGb9wkiJuq3gXaql8lNsXHYXtwbW8woSwqCNStVhn8l3dlcJcuPy5ozNEhHHt2PsrR0cwrC2SxnI0vpnxaQNNxWGElfKrkOBJyaOrQYkRaj3dlIB7cfNdVl7II1fINKZjvkFkUKzhGduqY5QoDRGr3r9STyY5XrQYkRajNuP8P4sMDaoqbjNdVQpPO1(ccyWXCH4j5CsLYNIlz2b4afKCUQt3kiMimCYovkALwWkIZM9QrKU6P5cq988cg0BPGmsbDBedaT1HuF5TX3r9STyY5XrQYkRaj3dlIB7cfNdVQpPO1(cccdNStLIwPfSI4SzVAePREA9gXujRayYRoIhXaqdlsvwzfi5EyrCBxO4C4Dzxu5Buaa4axShojflqPKsUyDc9rsJorVq8KCEVrmvYkaw4HaNStL8NEJ9smbdUrbaGRKGkBhda(SLoUsiyWHF5uoKQ6SN7KD6DegozNkfTslyfXzZE1isx90GUA4Kumxn0oRI8mQHY7v2L9KAYhXaqJuLvwbsUhwe32fkohEvFsrC9bg862Nl3HQDScGTGot6Q5L8NEJ9sWGH(izV3ZL7sPGpzCyhHHt2PsrR0cwrC2SxnI0vpTMoQkpR5N5wvpDsedansvwzfi5cfv1kzuoKQ6SNdVQpPiYGoiGbhZ62NlxOOQwjJYHuvN98NEJ9YO7O(i7liGbhZP7kty4LCORgojfZvdTZQipJAO8ELDzpPM8imCYovkALwWkIZM9QrKU6Pr3UGbQcypmIbGw4xoLdPQo75ozNEhm4yw3(C5cfv1kzuoKQ6SN)0BSxgDh1hzFbbm4yoDxzcdVKdD1WjPyUAODwf5zudL3RSl7j1KhHHt2PsrR0cwrC2SxnI0vpnk3EIBThkyn3PpIbGw4xoLdPQo75ozNEhm4yw3(C5cfv1kzuoKQ6SN)0BSxgDh1hzFbbm4yoDxzcdVKdD1WjPyUAODwf5zudL3RSl7j1KhHHt2PsrR0cwrC2SxnI0vpnkyLucwiCuDld6upIbGgujFC0W2OyTJ6JSVGagCmNURmHHxYHUA4Kumxn0oRI8mQHY7v2L9KAYJjcdNStLIwPfCyTtLrma0ivzLvGK7q1owbWwqNjVl5W7YoWGd)YPCiv1zp3j707Gb3OaaWvsqLTJbaF2shxjeHbDHmbv9jxFYjPqM(ngOI95ImyZToLYrMrGmoYecNcoBhcdNStLIwPfCPSnW70hXaqtwlV3avSpxwO1PuohEvFsrC0OisegozNkfTslyIBTmNStLm7i2isx90Uq8KCbcdNStLIwPfmXTwMt2PsMDeBePREAKQSYkqkqy4KDQu0kTGHkjZj7ujZoInI0vpnVEedanNStVZEE15IiP1hcdNStLIwPfmXTwMt2PsMDeBePREAuppCiimqyqxid2ufuJmWA9DQeHHt2Psb3RttEFbX8uYKN4Drma0ivzLvGK7HfXTDHIZHx1NuGWWj7uPG71BLwWYdm2JWWj7uPG71BLwWpCKxDirma0K3xqmpLm5jEhFhc9tsffQKpU(IgtphoEJ98WQStsXakiJYHuvN9imCYovk4E9wPfS8(cIrQXgXaqtEFbX8uYKN4D8Di0pjvuOs(46lAm9C44n2ZdRYojfdOGmkhsvD2JWWj7uPG71BLwWcsPaPotSWH(hXaqtEFbX8uYKN4D8Di0pjvusvwzfi5EyrCBxO4C4v9jfimCYovk4E9wPfmX6bMKIja5YkGiIbGM8(cI5PKjpX747qOFsQOKQSYkqY9WI42UqX5WR6tkqy4KDQuW96Tsl4hoYRoKigaAX0ZHJ3yppSk7KumGcYOCiv1zpcdNStLcUxVvAbdCXE4KumXch6FeKoI9S1HuFf0AlIbGM8nkaaCGl2dNKIfOusjxSoH(4O1wusvwzfi5Y7liMNsM8eVJdVQpPaHHt2Psb3R3kTGbUypCskMyHd9pIbG262NlVrbk2jPyIcEb)P3yVmQi8wlBDi1xbVrbk2jPyIcErK06lQ8nkaaCGl2dNKIfOusjxSoH(4O1gcdNStLcUxVvAblVVGyKASrma0Auaa4cfP8jtwLkhENSrHk55YdmKzJKgDqy4KDQuW96Tsly59feJuJnIbGwJcaaxOiLpzYQu5W7KnAm9C44n2ZdRYojfdOGmkhsvD2dgC4xoLdPQo75ozNEhHHt2Psb3R3kTGL3xqmsn2igaAqLCiSWkWHC5bgYSX1gDIIfPkRScKCpSiUTluCo8Q(KIiXoyWY3OaaWbUypCskwGsjLCX6e6JKoygnMEoC8g75HvzNKIbuqgLdPQo7ry4KDQuW96TslybPuGuNjw4q)JyaOHfwY3OaaWbUypCskwGsjLCLWOKQSYkqY9WI42UqX5WR6tkIe7ycgS8nkaaCGl2dNKIfOusjxSoH(iPdMrXIuLvwbsUdv7yfaBbDM8UKdVQpPisSdgS8(cIrFouGwUCeEJ9mVwjMimCYovk4E9wPfmX6bMKIja5YkGiIbGgwyjFJcaah4I9WjPybkLuYvcJsQYkRaj3dlIB7cfNdVQpPisSJjyWY3OaaWbUypCskwGsjLCX6e6JKoygflsvwzfi5ouTJvaSf0zY7so8Q(KIiXoyWY7lig95qbA5Yr4n2Z8ALyIWWj7uPG71BLwWY7ligPgBedanOsoewyf4qU8adz246lirJPNdhVXEEyv2jPyafKr5qQQZEegozNkfCVER0cg4I9WjPyIfo0)igaAyHfwyjFJcaah4I9WjPybkLuYfRtOpo6enMgfaaUscQSDma4Zw64kHycgS8nkaaCGl2dNKIfOusjxSoH(4WwmJsQYkRaj3dlIB7cfNdVQpPioSftWGLVrbaGdCXE4KuSaLsk5I1j0hxBygflsvwzfi5ouTJvaSf0zY7so8Q(KIiXoyWY7lig95qbA5Yr4n2Z8ALyIWWj7uPG71BLwWY7ligPgBedaTy65WXBSNhwLDskgqbzuoKQ6ShHbcdNStLcoPkRScKcAouTJvaSf0zY7segozNkfCsvwzfifTslypSiUTlu8igaAY3OaaWbUypCskwGsjLCX6e6JKgDIIvmxiEsoV3iMkzfal8qGt2Ps(tVXEjyWxiEsoV3iMkzfal8qGt2Ps(tVXEzuSw3(C5kjOY2XaGpBPJ)0BSxgLuLvwbsUscQSDma4Zw64WR6tkIJg2cgCmRBFUCLeuz7yaWNT0XF6n2lXetegozNkfCsvwzfifTslyPdPNTqpfafu13PYigaAXa9rYEVNl3Lsb)9)rScWGH(izV3ZL7sPGpzKTHDegozNkfCsvwzfifTslyHIQALmkhsvD2hXaqdQKdHfwboKlpWqMnU2OdcdNStLcoPkRScKIwPfSscQSDma4Zw6IyaODH4j58EJyQKvaSWdbozNk5p9g7Lrd)Y9WIWOavkwUt2P3bdw(gfaaoWf7HtsXcukPKlwNqFC0jkwX4TC4SNR6ukcwbWwqNjVl5p9g7LGb7TC4SNR6ukcwbWwqNjVl5p9g7Lrd)Y9WIWOavkwUt2P3XeHHt2PsbNuLvwbsrR0cwjbv2oga8zlDrma0CYo9o75vNlIKwFrXclsvwzfi5Y7liMNsM8eVJdVQpPioAuez0yw3(C5Ydm2ZF6n2lXemySivzLvGKlpWyphEvFsrC0OiYORBFUC5bg75p9g7LyIjcdNStLcoPkRScKIwPfSOuSm49WdJG0rSNToK6RGwBrma0whs9LVJ6zBXKZJRFfDDi1x(oQNTftops6GWWj7uPGtQYkRaPOvAblkfldEp8WigaAyfd0hj79EUCxkf83)hXkadg6JK9EpxUlLc(Kr2xqWmkujFC0WQTGsJcaaxjbv2oga8zlDCLqmry4KDQuWjvzLvGu0kTGvsqLTJ1yhkqlcdegozNkf8lepjxqt9QfSJvamRczKmj8UQiIbGgujpFh1Z2I1wKuezuOsoewyf4W4Otqqy4KDQuWVq8KCrR0cUXwLKvaSf0zpVAxedanSivzLvGKlVVGyEkzYt8oo8Q(KIOIWBTS1HuFfC59feZtjtEI3fzBycgmwKQSYkqYLhySNdVQpPiQi8wlBDi1xbxEGX(iBdtWGXIuLvwbsUhwe32fkohEvFsrusvwzfi5Y7liMNsM8eVJdVl7WeHHt2Psb)cXtYfTslykfhkhpzfaZB5WAbfXaqdlsvwzfi5EyrCBxO4C4v9jfXf0rjvzLvGK7q1owbWwqNjVl5WR6tkIKuLvwbsoPs5tXLm7aCGcsohEvFsbMGbtQYkRaj3HQDScGTGotExYHx1NuexFimCYovk4xiEsUOvAbVGotjBkLuYaki5rma0Auaa4WtO3EHGbuqY5kHGb3OaaWHNqV9cbdOGKZiLsUhYfRtOpU2AdHHt2Psb)cXtYfTslyGIOiUK5TC4SN1CxnIbGwmY7liMNsM8eVJVdH(jPqy4KDQuWVq8KCrR0cMuj55c99sgG1vFedanzTCsLKNl03lzawx9SgfyYHx1NuqliimCYovk4xiEsUOvAbhQahGUjPynwxSrma0IrEFbX8uYKN4D8Di0pjfcdNStLc(fINKlALwWbkOv27tYGxuPNKhXaqBD7ZL7q1owbWwqNjD18s(tVXEz0lepjN3BetLScGfEiWj7ujxDYcgTrbaGRKGkBhtSWNuliUsiyWxiEsoV3iMkzfal8qGt2PsU6KfmA4xUhwegfOsXYDYo9oyWRBFUChQ2Xka2c6mPRMxYF6n2lJg(L7HfHrbQuSCNStVhLuLvwbsUdv7yfaBbDM8UKdVQpPiYGoiGbVU95YDOAhRaylOZKUAEj)P3yVmA4xUdv7yuGkfl3j707imCYovk4xiEsUOvAbhOGwzVpjdErLEsEedaTyK3xqmpLm5jEhFhc9tsfTrbaGRKGkBhtSWNuliUsy0yUq8KCEVrmvYkaw4HaNStLC1jly0yw3(C5ouTJvaSf0zsxnVK)0BSxcg86qQV8DupBlMCECKQSYkqY9WI42UqX5WR6tkqy4KDQuWVq8KCrR0cgoHH2ZMKjcDYJyaOfJ8(cI5PKjpX747qOFskegozNkf8lepjx0kTGH3dNKIbyD1lqyGWWj7uPGt98WHqtEFbXi1yJyaO1OaaWfks5tMSkvo8ozJgtphoEJ98WQStsXakiJYHuvN9Gbh(Lt5qQQZEUt2P3ry4KDQuWPEE4qALwWY7ligPgBedanOsoewyf4qU8adz24AJorXIuLvwbsUhwe32fkohEvFsrKyhmy5Buaa4axShojflqPKsUyDc9rshmJgtphoEJ98WQStsXakiJYHuvN9imCYovk4uppCiTsly59feZtjtEI3fXaqBD7ZLhEXo2NKZF6n2lJsQYkRaj3dlIB7cfNdVQpPaHHt2PsbN65HdPvAblpWyFedansvwzfi5EyrCBxO4C4v9jfimCYovk4uppCiTslybPuGuNjw4q)JyaOHfwY3OaaWbUypCskwGsjLCLWOyrQYkRaj3dlIB7cfNdVQpPisShfRyUq8KCEVrmvYkaw4HaNStL8NEJ9sWGJzD7ZLRKGkBhda(SLo(tVXEjMGbFH4j58EJyQKvaSWdbozNk5p9g7Lrx3(C5kjOY2XaGpBPJ)0BSxgLuLvwbsUscQSDma4Zw64WR6tkImOXetWGLVrbaGdCXE4KuSaLsk5I1j0hjDWmkwKQSYkqYDOAhRaylOZK3LC4v9jfrIDmry4KDQuWPEE4qALwWeRhyskMaKlRaIigaAyHL8nkaaCGl2dNKIfOusjxjmkwKQSYkqY9WI42UqX5WR6tkIe7rXkMlepjN3BetLScGfEiWj7uj)P3yVem4yw3(C5kjOY2XaGpBPJ)0BSxIjyWxiEsoV3iMkzfal8qGt2Ps(tVXEz01TpxUscQSDma4Zw64p9g7LrjvzLvGKRKGkBhda(SLoo8Q(KIidAmXemy5Buaa4axShojflqPKsUyDc9rshmJIfPkRScKChQ2Xka2c6m5DjhEvFsrKyhtegozNkfCQNhoKwPfS8(cIrQXgXaqdQKdHfwboKlpWqMnU(cs0y65WXBSNhwLDskgqbzuoKQ6ShHHt2PsbN65HdPvAbdCXE4KumXch6FedanSWclSKVrbaGdCXE4KuSaLsk5I1j0hhDIgtJcaaxjbv2oga8zlDCLqmbdw(gfaaoWf7HtsXcukPKlwNqFCylMrjvzLvGK7HfXTDHIZHx1Nueh2IjyWY3OaaWbUypCskwGsjLCX6e6JRnmJIfPkRScKChQ2Xka2c6m5DjhEvFsrKyhmy59feJ(COaTC5i8g7zETsmry4KDQuWPEE4qALwWaxShojftSWH(hXaqt(gfaaoWf7HtsXcukPKlwNqFC0jkwKQSYkqY9WI42UqX5WR6tkIdBJIvmxiEsoV3iMkzfal8qGt2Ps(tVXEjyWXSU95YvsqLTJbaF2sh)P3yVem4lepjN3BetLScGfEiWj7uj)P3yVm662Nlxjbv2oga8zlD8NEJ9YOKQSYkqYvsqLTJbaF2shhEvFsrC9dmXemy5Buaa4axShojflqPKsUyDc9X1wuSivzLvGK7q1owbWwqNjVl5WR6tkIe7yIWWj7uPGt98WH0kTGL3xqmsn2igaAX0ZHJ3yppSk7KumGcYOCiv1zVg3vwqfuJJpQkwFNk7Vqhy1RE1A]] )

end
