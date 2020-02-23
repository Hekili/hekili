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


    spec:RegisterPack( "Unholy", 20200222, [[dWKVEbqiHIhHukBsi9jPQIgfsXPGIELukZsi6wcKyxO6xcHHHuXXKsSmPu9mKsAAcexdPsBtGuFtQQW4KQk5CiLqRtQQkZtOY9Gs7tG6GiLiluQkpuQQstuQQu5IcKuBePe8rKsu6KsvvyLqHxIuIIzkvvQ6McKK2Pqv)uQQuAOiLOAPsvv0tHQPku6QcKeBvQQu4RsvLI2lf)fLbtQdt1ILIhJyYeDzvBgWNrYObYPvSAKsLxJu1SP0TjXUf9BjdxqhhPu1Yb9CctxPRtsBxQY3fW4LQQQZlvwVusZhO2pKnTyI1Gl99M4BNoTth60E7TZBNwPtl0LUg8Tl8g8qNqVtDdE6k3Ghujbv2odEO3zlxAI1Glkvi5gCq7gk6Freb1SGuB4KsjcXOOA9DQKaDGncXOqIWG3Oo2T)inngCPV3eF70PD6qN2BVDE70kDOtl9ddUi8et8Tt32n4GgP8PPXGlVGyWPnKoOscQSDiD)U7liKMwMCOaTimOnKg0UHI(xerqnli1goPuIqmkQwFNkjqhyJqmkKiqyqBinTWBGQoSdPBV9ir62Pt70bHbcdAdP7VG8K6I(hcdAdPdkinTKuEjshuDsjstla)B9Ceg0gshuq6(BL9oCVePxhs9LnainPs5StLcKElKgEkvRdrAsLYzNkfCeg0gshuqA8s5iDfUJY0QVtLiDbG00cxShQmuGwKEsKMwQFBqnhHbTH0bfKU)0jJBfrqlu5I0fastlVcCisVbUtVGBWTJyfMyn4xiEsUWeRj(wmXAWF6n2ln9zWjWzpCCdounpFhLZ2I1cshmstrKiDuKgQMdHfwboePJdPdcDm4ozNkn4kxPGDScGzvjJKjH3veM1eF7Myn4p9g7LM(m4e4ShoUbNgKMuLvwbsU8(cI5PKjpX74WR4tkq6OiTi8wlBDi1xbxEFbX8uYKN4DiDWiDlinMinyWinninPkRScKC5bg75WR4tkq6OiTi8wlBDi1xbxEGXEKoyKUfKgtKgmyKMgKMuLvwbsUhwe32fkohEfFsbshfPjvzLvGKlVVGyEkzYt8oo8USdPX0G7KDQ0G3yRsYka2c6SNxPZSM4PvtSg8NEJ9stFgCcC2dh3GtdstQYkRaj3dlIB7cfNdVIpPaPJdPdAKokstQYkRaj3HkDScGTGotExYHxXNuG0bJ0KQSYkqYjvkFkUKzhGduqY5WR4tkqAmrAWGrAsvwzfi5ouPJvaSf0zY7so8k(KcKooKUDdUt2PsdoLQdLJNScG5TEyTGmRj(GyI1G)0BSxA6ZGtGZE44g8gvaao8e6TxiyafKCUAisdgms3OcaWHNqV9cbdOGKZiLAUhYfRtOhPJdPBPfdUt2Psd(c6m1SPutjdOGKBwt801eRb)P3yV00NbNaN9WXn4XG0Y7liMNsM8eVJVdH(jPm4ozNkn4afrvCjZB9WzpR5UIznXh0Myn4p9g7LM(m4e4ShoUbxwlNuj55c99sgG1voRrfMC4v8jfinwKMogCNStLgCsLKNl03lzawx5M1eF)WeRb)P3yV00NbNaN9WXn4XG0Y7liMNsM8eVJVdH(jPm4ozNkn4HQWbOBskwJ1fRznX3VmXAWF6n2ln9zWjWzpCCd(62Nl3HkDScGTGot6k5L8NEJ9sKoksFH4j58EJyQKvaSWdbozNk5ktwqKoks3OcaWvtqLTJjw4tQfexnePbdgPVq8KCEVrmvYkaw4HaNStLCLjlishfPd)Y9WIWOavQwUt2P3rAWGr61TpxUdv6yfaBbDM0vYl5p9g7LiDuKo8l3dlcJcuPA5ozNEhPJI0KQSYkqYDOshRaylOZK3LC4v8jfiDWiDqthKgmyKED7ZL7qLowbWwqNjDL8s(tVXEjshfPd)YDOshJcuPA5ozNE3G7KDQ0GhOGwzVpjdErLEsUznXtlAI1G)0BSxA6ZGtGZE44g8yqA59feZtjtEI3X3Hq)KuiDuKUrfaGRMGkBhtSWNuliUAishfPJbPVq8KCEVrmvYkaw4HaNStLCLjlishfPJbPx3(C5ouPJvaSf0zsxjVK)0BSxI0GbJ0RdP(Y3r5STyY5iDCinPkRScKCpSiUTluCo8k(KcdUt2PsdEGcAL9(Km4fv6j5M1eFl0XeRb)P3yV00NbNaN9WXn4XG0Y7liMNsM8eVJVdH(jPm4ozNkn4Wjm0E2KmrOtUznX3slMyn4ozNkn4W7HtsXaSUYfg8NEJ9stFM1SgC5bCv7AI1eFlMyn4ozNkn4ktkzaW)wVb)P3yV00NznX3Ujwd(tVXEPPpdEfAWfFn4ozNkn49C44n2BW75w1BWjvzLvGKluvuQKr5qQQZEo8k(KcKooKMUiDuKED7ZLluvuQKr5qQQZE(tVXEPbVNdzPRCdEyv2jPyafKr5qQQZEZAINwnXAWF6n2ln9zWjWzpCCdounhclScCixEGHmlshmsh00fPJI00G0HF5uoKQ6SN7KD6DKgmyKogKED7ZLluvuQKr5qQQZE(tVXEjsJjshfPHQ55YdmKzr6GXI001G7KDQ0G7qINNTfe(CnRj(GyI1G)0BSxA6ZGtGZE44g8WVCkhsvD2ZDYo9osdgmshdsVU95YfQkkvYOCiv1zp)P3yV0G7KDQ0G3yRsYauHDM1epDnXAWF6n2ln9zWjWzpCCdEJkaaxnbv2oga8zRDC1qKgmyKo8lNYHuvN9CNStVJ0GbJ00G0RBFUChQ0Xka2c6mPRKxYF6n2lr6OiD4xUhwegfOs1YDYo9osJPb3j7uPbV5qXH0pjLznXh0Myn4p9g7LM(m4e4ShoUbNgKUrfaGRMGkBhtSWNuliUAishfPBuba4axShQmuGwo8k(KcKooSinDrAmrAWGrANStVZEEL5cKoySiD7iDuKMgKUrfaGRMGkBhtSWNuliUAisdgms3OcaWbUypuzOaTC4v8jfiDCyrA6I0yAWDYovAWTdfOvWODQskLNRznX3pmXAWF6n2ln9zWjWzpCCdoniD4xoLdPQo75ozNEhPJI0RBFUCHQIsLmkhsvD2ZF6n2lrAmrAWGr6WVCpSimkqLQL7KD6DdUt2PsdUNKlwOBze3AnRj((Ljwd(tVXEPPpdobo7HJBWDYo9o75vMlq6GXI0TJ0GbJ00G0q18C5bgYSiDWyrA6I0rrAOAoewyf4qU8adzwKoySiDqthKgtdUt2PsdUdjEEwOQvCZAINw0eRb)P3yV00NbNaN9WXn40G0HF5uoKQ6SN7KD6DKoksVU95YfQkkvYOCiv1zp)P3yVePXePbdgPd)Y9WIWOavQwUt2P3n4ozNkn4ad8n2QKM1eFl0XeRb)P3yV00NbNaN9WXn4nQaaC1euz7yIf(KAbXvdr6OiTt2P3zpVYCbsJfPBbPbdgPBuba4axShQmuGwo8k(KcKooKMIir6OiTt2P3zpVYCbsJfPBXG7KDQ0G34uScGTWHqVWSM4BPftSg8NEJ9stFgCcC2dh3GVJYr6Gr62PdsdgmshdsFAV6egEjh6kHtsXCLq7SQYZOgkVxzx2tQjpsdgmshdsFAV6egEjV3iMkzfatELrCdUt2PsdUQ4SzVIWSM4BPDtSg8NEJ9stFgCNStLgCVvbih6cgqLlRayHvGdn4e4ShoUbNgK(cXtY59gXujRayHhcCYovYF6n2lr6OiDmi962Nlxnbv2oga8zRD8NEJ9sKgtKgmyKMgKogK(cXtY5KkLpfxYSdWbki5CfN2vqKokshdsFH4j58EJyQKvaSWdbozNk5p9g7LinMg80vUb3BvaYHUGbu5Ykawyf4qZAIVfA1eRb)P3yV00Nb3j7uPb3BvaYHUGbu5Ykawyf4qdobo7HJBWjvzLvGK7HfXTDHIZHxXNuG0XH0TeeKokstdsFH4j5CsLYNIlz2b4afKCUIt7kisdgmsFH4j58EJyQKvaSWdbozNk5p9g7LiDuKED7ZLRMGkBhda(S1o(tVXEjsJPbpDLBW9wfGCOlyavUScGfwbo0SM4BjiMyn4p9g7LM(m4ozNkn4ERcqo0fmGkxwbWcRahAWjWzpCCd(okNTftohPJdPjvzLvGK7HfXTDHIZHxXNuG0TH00Aqm4PRCdU3QaKdDbdOYLvaSWkWHM1eFl01eRb)P3yV00Nb3j7uPb3fG655fmO3AbzKc6wdobo7HJBWLVrfaGd9wliJuq3YKVrfaGlwNqpshhs3IbpDLBWDbOEEEbd6TwqgPGU1SM4BjOnXAWF6n2ln9zWDYovAWDbOEEEbd6TwqgPGU1GtGZE44g8WVCkvhkhpzfaZB9WAbXDYo9oshfPd)Y9WIWOavQwUt2P3n4PRCdUla1ZZlyqV1cYif0TM1eFl9dtSg8NEJ9stFgCNStLgCxaQNNxWGERfKrkOBn4e4ShoUbNuLvwbsUhwe32fkohEx2H0rrAAq6lepjNtQu(uCjZoahOGKZvCAxbr6Oi9okNTftohPJdPjvzLvGKtQu(uCjZoahOGKZHxXNuG0TH0TthKgmyKogK(cXtY5KkLpfxYSdWbki5CfN2vqKgtdE6k3G7cq988cg0BTGmsbDRznX3s)YeRb)P3yV00Nb3j7uPb3fG655fmO3AbzKc6wdobo7HJBW3r5STyY5iDCinPkRScKCpSiUTluCo8k(KcKUnKUD6yWtx5gCxaQNNxWGERfKrkOBnRj(wOfnXAWF6n2ln9zWDYovAW7nIPswbWKxze3GtGZE44gCAqAsvwzfi5EyrCBxO4C4DzhshfPLVrfaGdCXE4KuSaLAk5I1j0J0bJfPdcshfPVq8KCEVrmvYkaw4HaNStL8NEJ9sKgtKgmyKUrfaGRMGkBhda(S1oUAisdgmsh(Lt5qQQZEUt2P3n4PRCdEVrmvYkaM8kJ4M1eF70XeRb)P3yV00Nb3j7uPbh6kHtsXCLq7SQYZOgkVxzx2tQjVbNaN9WXn4KQSYkqY9WI42UqX5WR4tkq64q62rAWGr61TpxUdv6yfaBbDM0vYl5p9g7LinyWin0hj79EUCxkf8jr64qA6AWtx5gCOReojfZvcTZQkpJAO8ELDzpPM8M1eF7TyI1G)0BSxA6ZG7KDQ0G30rv5zn)m3Q4Ptm4e4ShoUbNuLvwbsUqvrPsgLdPQo75WR4tkq6Gr6GMoinyWiDmi962NlxOQOujJYHuvN98NEJ9sKoksVJYr6Gr62PdsdgmshdsFAV6egEjh6kHtsXCLq7SQYZOgkVxzx2tQjVbpDLBWB6OQ8SMFMBv80jM1eF7TBI1G)0BSxA6ZG7KDQ0Gt7UGbQcyp0GtGZE44g8WVCkhsvD2ZDYo9osdgmshdsVU95YfQkkvYOCiv1zp)P3yVePJI07OCKoyKUD6G0GbJ0XG0N2RoHHxYHUs4Kumxj0oRQ8mQHY7v2L9KAYBWtx5gCA3fmqva7HM1eF70Qjwd(tVXEPPpdUt2PsdoLBpXT2dfSM70BWjWzpCCdE4xoLdPQo75ozNEhPbdgPJbPx3(C5cvfLkzuoKQ6SN)0BSxI0rr6Duoshms3oDqAWGr6yq6t7vNWWl5qxjCskMReANvvEg1q59k7YEsn5n4PRCdoLBpXT2dfSM70Bwt8ThetSg8NEJ9stFgCNStLgCkyLucwiCuCld6u3GtGZE44gCOAEKooSinTI0rrAAq6Duoshms3oDqAWGr6yq6t7vNWWl5qxjCskMReANvvEg1q59k7YEsn5rAmn4PRCdofSskbleokULbDQBwt8TtxtSg8NEJ9stFgCcC2dh3GtQYkRaj3HkDScGTGotExYH3LDinyWiD4xoLdPQo75ozNEhPbdgPBuba4QjOY2XaGpBTJRgAWDYovAWdRDQ0SM4BpOnXAWF6n2ln9zWjWzpCCdUSwEVbQAFUSqRtPEo8k(KcKooSinfrAWDYovAWl1TbENEZAIV9(Hjwd(tVXEPPpdUt2PsdoXTwMt2PsMDeRb3oILLUYn4xiEsUWSM4BVFzI1G)0BSxA6ZG7KDQ0GtCRL5KDQKzhXAWTJyzPRCdoPkRScKcZAIVDArtSg8NEJ9stFgCcC2dh3G7KD6D2ZRmxG0bJfPB3G7KDQ0GdvtMt2PsMDeRb3oILLUYn4EDZAINwPJjwd(tVXEPPpdUt2PsdoXTwMt2PsMDeRb3oILLUYn4uppCiM1Sg8q4jLsJVMynX3IjwdUt2PsdEyTtLg8NEJ9stFM1eF7Myn4ozNkn4qFeNjVln4p9g7LM(mRjEA1eRb)P3yV00NbpDLBW9wfGCOlyavUScGfwbo0G7KDQ0G7Tka5qxWaQCzfalScCOznXhetSg8NEJ9stFgC5TENbVDdUt2PsdUdv6yfaBbDM8U0SM1GtQYkRaPWeRj(wmXAWDYovAWDOshRaylOZK3Lg8NEJ9stFM1eF7Myn4p9g7LM(m4e4ShoUbx(gvaaoWf7HtsXcuQPKlwNqpshmwKoiiDuKMgK2j707SNxzUaPdgPBbPbdgPJbPVq8KCEVrmvYkaw4HaNStL8NEJ9sKgmyK(cXtY59gXujRayHhcCYovYF6n2lr6Oinni962Nlxnbv2oga8zRD8NEJ9sKokstQYkRajxnbv2oga8zRDC4v8jfiDCyrAAfPbdgPJbPx3(C5QjOY2XaGpBTJ)0BSxI0yI0yAWDYovAW9WI42UqXnRjEA1eRb)P3yV00NbNaN9WXn4XG0qFKS375YDPuWF)FeRaPbdgPH(izV3ZL7sPGpjshms3cDn4ozNkn4shspBHEkakOIVtLM1eFqmXAWF6n2ln9zWjWzpCCdounhclScCixEGHmlshhs3sqm4ozNkn4cvfLkzuoKQ6S3SM4PRjwd(tVXEPPpdobo7HJBWVq8KCEVrmvYkaw4HaNStL8NEJ9sKoksh(L7HfHrbQuTCNStVJ0GbJ0Y3OcaWbUypCskwGsnLCX6e6r64q6GG0rrAAq6yqAV1dN9CfNsvWka2c6m5Dj)P3yVePbdgP9wpC2ZvCkvbRaylOZK3L8NEJ9sKoksh(L7HfHrbQuTCNStVJ0yAWDYovAWvtqLTJbaF2ANznXh0Myn4p9g7LM(m4e4ShoUb3j707SNxzUaPdgls3oshfPPbPPbPjvzLvGKlVVGyEkzYt8oo8k(KcKooSinfrI0rr6yq61TpxU8aJ98NEJ9sKgtKgmyKMgKMuLvwbsU8aJ9C4v8jfiDCyrAkIePJI0RBFUC5bg75p9g7LinMinMgCNStLgC1euz7yaWNT2zwt89dtSg8NEJ9stFgCNStLgCrPAzW7HhAWjWzpCCd(6qQV8DuoBlMCoshhs3Vq6Oi96qQV8DuoBlMCoshmshedoPJypBDi1xHj(wmRj((Ljwd(tVXEPPpdobo7HJBWPbPJbPH(izV3ZL7sPG)()iwbsdgmsd9rYEVNl3LsbFsKoyKUD6G0yI0rrAOAEKooSinniDliDqbPBuba4QjOY2XaGpBTJRgI0yAWDYovAWfLQLbVhEOznXtlAI1G7KDQ0GRMGkBhRXouGwd(tVXEPPpZAwdo1ZdhIjwt8TyI1G)0BSxA6ZGtGZE44g8gvaaUqvkFYKvPWH3jlshfPJbP75WXBSNhwLDskgqbzuoKQ6ShPbdgPd)YPCiv1zp3j707gCNStLgC59feJuJ1SM4B3eRb)P3yV00NbNaN9WXn4q1CiSWkWHC5bgYSiDCiDlbbPJI00G0KQSYkqY9WI42UqX5WR4tkq6GrA6I0GbJ0Y3OcaWbUypCskwGsnLCX6e6r6Gr6GG0yI0rr6yq6EoC8g75HvzNKIbuqgLdPQo7n4ozNkn4Y7ligPgRznXtRMyn4p9g7LM(m4e4ShoUbFD7ZLhEXo2NKZF6n2lr6OinPkRScKCpSiUTluCo8k(KcdUt2PsdU8(cI5PKjpX7mRj(GyI1G)0BSxA6ZGtGZE44gCsvwzfi5EyrCBxO4C4v8jfgCNStLgC5bg7nRjE6AI1G)0BSxA6ZGtGZE44gCAqAAqA5Buba4axShojflqPMsUAishfPPbPjvzLvGK7HfXTDHIZHxXNuG0bJ00fPJI00G0XG0xiEsoV3iMkzfal8qGt2Ps(tVXEjsdgmshdsVU95YvtqLTJbaF2Ah)P3yVePXePbdgPVq8KCEVrmvYkaw4HaNStL8NEJ9sKoksVU95YvtqLTJbaF2Ah)P3yVePJI0KQSYkqYvtqLTJbaF2AhhEfFsbshmsh0inMinMinyWiT8nQaaCGl2dNKIfOutjxSoHEKoyKoiinMiDuKMgKMuLvwbsUdv6yfaBbDM8UKdVIpPaPdgPPlsJPb3j7uPbxqkvi1zIfo0FZAIpOnXAWF6n2ln9zWjWzpCCdoninniT8nQaaCGl2dNKIfOutjxnePJI00G0KQSYkqY9WI42UqX5WR4tkq6GrA6I0rrAAq6yq6lepjN3BetLScGfEiWj7uj)P3yVePbdgPJbPx3(C5QjOY2XaGpBTJ)0BSxI0yI0GbJ0xiEsoV3iMkzfal8qGt2Ps(tVXEjshfPx3(C5QjOY2XaGpBTJ)0BSxI0rrAsvwzfi5QjOY2XaGpBTJdVIpPaPdgPdAKgtKgtKgmyKw(gvaaoWf7HtsXcuQPKlwNqpshmsheKgtKokstdstQYkRaj3HkDScGTGotExYHxXNuG0bJ00fPX0G7KDQ0GtSEGjPycqUScimRj((Hjwd(tVXEPPpdobo7HJBWHQ5qyHvGd5YdmKzr64q62PdshfPJbP75WXBSNhwLDskgqbzuoKQ6S3G7KDQ0GlVVGyKASM1eF)YeRb)P3yV00NbNaN9WXn40G00G00G00G0Y3OcaWbUypCskwGsnLCX6e6r64q6GG0rr6yq6gvaaUAcQSDma4Zw74QHinMinyWiT8nQaaCGl2dNKIfOutjxSoHEKooKMwrAmr6OinPkRScKCpSiUTluCo8k(KcKooKMwrAmrAWGrA5Buba4axShojflqPMsUyDc9iDCiDlinMiDuKMgKMuLvwbsUdv6yfaBbDM8UKdVIpPaPdgPPlsdgmslVVGy0NdfOLlhH3ypZRvI0yAWDYovAWbUypCskMyHd93SM4PfnXAWF6n2ln9zWjWzpCCdU8nQaaCGl2dNKIfOutjxSoHEKooKoiiDuKMgKMuLvwbsUhwe32fkohEfFsbshhstRiDuKMgKogK(cXtY59gXujRayHhcCYovYF6n2lrAWGr6yq61TpxUAcQSDma4Zw74p9g7LinyWi9fINKZ7nIPswbWcpe4KDQK)0BSxI0rr61TpxUAcQSDma4Zw74p9g7LiDuKMuLvwbsUAcQSDma4Zw74WR4tkq64q6(bsJjsJjsdgmslFJkaah4I9WjPybk1uYfRtOhPJdPBbPJI00G0KQSYkqYDOshRaylOZK3LC4v8jfiDWinDrAmn4ozNkn4axShojftSWH(Bwt8TqhtSg8NEJ9stFgCcC2dh3Ghds3ZHJ3yppSk7KumGcYOCiv1zVb3j7uPbxEFbXi1ynRzn4EDtSM4BXeRb)P3yV00NbNaN9WXn4KQSYkqY9WI42UqX5WR4tkm4ozNkn4Y7liMNsM8eVZSM4B3eRb3j7uPbxEGXEd(tVXEPPpZAINwnXAWF6n2ln9zWjWzpCCdU8(cI5PKjpX747qOFskKoksdvZJ0XH0TJ0rr6yq6EoC8g75HvzNKIbuqgLdPQo7n4ozNkn4pCKxziM1eFqmXAWF6n2ln9zWjWzpCCdU8(cI5PKjpX747qOFskKoksdvZJ0XH0TJ0rr6yq6EoC8g75HvzNKIbuqgLdPQo7n4ozNkn4Y7ligPgRznXtxtSg8NEJ9stFgCcC2dh3GlVVGyEkzYt8o(oe6NKcPJI0KQSYkqY9WI42UqX5WR4tkm4ozNkn4csPcPotSWH(Bwt8bTjwd(tVXEPPpdobo7HJBWL3xqmpLm5jEhFhc9tsH0rrAsvwzfi5EyrCBxO4C4v8jfgCNStLgCI1dmjftaYLvaHznX3pmXAWF6n2ln9zWjWzpCCdEmiDphoEJ98WQStsXakiJYHuvN9gCNStLg8hoYRmeZAIVFzI1G)0BSxA6ZG7KDQ0GdCXE4KumXch6VbNaN9WXn4Y3OcaWbUypCskwGsnLCX6e6r64WI0TG0rrAsvwzfi5Y7liMNsM8eVJdVIpPWGt6i2Zwhs9vyIVfZAINw0eRb)P3yV00NbNaN9WXn4RBFU8gvOyNKIjk4f8NEJ9sKokslcV1Ywhs9vWBuHIDskMOGxG0bJfPBhPJI0Y3OcaWbUypCskwGsnLCX6e6r64WI0TyWDYovAWbUypCskMyHd93SM4BHoMyn4p9g7LM(m4e4ShoUbVrfaGluLYNmzvkC4DYI0rrAOAEU8adzwKoySiDqm4ozNkn4Y7ligPgRznX3slMyn4p9g7LM(m4e4ShoUbVrfaGluLYNmzvkC4DYI0rr6yq6EoC8g75HvzNKIbuqgLdPQo7rAWGr6WVCkhsvD2ZDYo9Ub3j7uPbxEFbXi1ynRj(wA3eRb)P3yV00NbNaN9WXn4q1CiSWkWHC5bgYSiDCiDlbbPJI00G0KQSYkqY9WI42UqX5WR4tkq6GrA6I0GbJ0Y3OcaWbUypCskwGsnLCX6e6r6Gr6GG0yI0rr6yq6EoC8g75HvzNKIbuqgLdPQo7n4ozNkn4Y7ligPgRznX3cTAI1G)0BSxA6ZGtGZE44gCAqAAqA5Buba4axShojflqPMsUAishfPjvzLvGK7HfXTDHIZHxXNuG0bJ00fPXePbdgPLVrfaGdCXE4KuSaLAk5I1j0J0bJ0bbPXePJI00G0KQSYkqYDOshRaylOZK3LC4v8jfiDWinDrAWGrA59feJ(COaTC5i8g7zETsKgtdUt2PsdUGuQqQZelCO)M1eFlbXeRb)P3yV00NbNaN9WXn40G00G0Y3OcaWbUypCskwGsnLC1qKokstQYkRaj3dlIB7cfNdVIpPaPdgPPlsJjsdgmslFJkaah4I9WjPybk1uYfRtOhPdgPdcsJjshfPPbPjvzLvGK7qLowbWwqNjVl5WR4tkq6GrA6I0GbJ0Y7lig95qbA5Yr4n2Z8ALinMgCNStLgCI1dmjftaYLvaHznX3cDnXAWF6n2ln9zWjWzpCCdounhclScCixEGHmlshhs3oDq6OiDmiDphoEJ98WQStsXakiJYHuvN9gCNStLgC59feJuJ1SM4BjOnXAWF6n2ln9zWjWzpCCdoninninninniT8nQaaCGl2dNKIfOutjxSoHEKooKoiiDuKogKUrfaGRMGkBhda(S1oUAisJjsdgmslFJkaah4I9WjPybk1uYfRtOhPJdPPvKgtKokstQYkRaj3dlIB7cfNdVIpPaPJdPPvKgtKgmyKw(gvaaoWf7HtsXcuQPKlwNqpshhs3csJjshfPPbPjvzLvGK7qLowbWwqNjVl5WR4tkq6GrA6I0GbJ0Y7lig95qbA5Yr4n2Z8ALinMgCNStLgCGl2dNKIjw4q)nRj(w6hMyn4p9g7LM(m4e4ShoUbpgKUNdhVXEEyv2jPyafKr5qQQZEdUt2PsdU8(cIrQXAwZAwdEVdftLM4BNoTth60oDcIbpGdZjPeg8(nPL6pJV)iEAz7FinshlOJ0JsybxKgOGiD)uEax1U9tKgEAV6aVePfLYrAxDlfFVePjG8K6cocJ(9tEKULG0)q6(BL9oCVeP7NRdP(YBHVJYzBXKZ7Ni9wiD)ChLZ2IjN3prAAAP)JjhHr)(jps3s)Q)H093k7D4Ejs3pxhs9L3cFhLZ2IjN3pr6Tq6(5okNTftoVFI000s)htocdeg9hkHfCVePdAK2j7ujsBhXk4imm4U6cQGgC8rr167uz)f6aRbpewaJ9gCAdPdQKGkBhs3V7(ccPPLjhkqlcdAdPbTBOO)freuZcsTHtkLieJIQ13Psc0b2ieJcjceg0gstl8gOQd7q62BpsKUD60oDqyGWG2q6(lipPUO)HWG2q6GcstljLxI0bvNuI00cW)wphHbTH0bfKU)wzVd3lr61HuFzdastQuo7uPaP3cPHNs16qKMuPC2PsbhHbTH0bfKgVuosxH7OmT67ujsxainTWf7HkdfOfPNePPL63guZryqBiDqbP7pDY4wre0cvUiDbG00YRahI0BG70l4imqyqBiDqD))e19sKU5af8inPuA8fPBo1KcostlripCfiDwzqbKdvauTiTt2PsbsxPTJJWG2qANStLcEi8KsPXxSawxqpcdAdPDYovk4HWtkLgFBdBeavjryqBiTt2PsbpeEsP04BByJWvPuEU(ovIWG2qA80dfGQfPH(ir6gvaGlrAX6RaPBoqbpstkLgFr6MtnPaP9uI0HWhucRDNKcPhbslR8Ceg0gs7KDQuWdHNukn(2g2iePhkavltS(kqy4KDQuWdHNukn(2g2icRDQeHHt2PsbpeEsP04BByJa6J4m5DjcdNStLcEi8KsPX32WgHQ4SzVsKPRCSERcqo0fmGkxwbWcRahIWWj7uPGhcpPuA8TnSr4qLowbWwqNjVlJuER3HTDegimOnKoOU)FI6Ejs)Eh2H07OCKEbDK2jBbr6rG0EpFSEJ9CegozNkfyvMuYaG)TEegozNkfTHnIEoC8g7JmDLJnSk7KumGcYOCiv1zFK9CR6XsQYkRajxOQOujJYHuvN9C4v8jfXr3ORBFUCHQIsLmkhsvD2ZF6n2lryqBiD)Ptg3kIeP7p2RiIeP9uI01c6qKUOisbcdNStLI2WgHdjEE2wq4ZnYbalunhclScCixEGHmBWbnDJst4xoLdPQo75ozNEhm4yw3(C5cvfLkzuoKQ6SN)0BSxIzuOAEU8adz2GXsxegozNkfTHnIgBvsgGkSlYbaB4xoLdPQo75ozNEhm4yw3(C5cvfLkzuoKQ6SN)0BSxIWWj7uPOnSr0CO4q6NKkYbaBJkaaxnbv2oga8zRDC1qWGd)YPCiv1zp3j707GbtZ62Nl3HkDScGTGot6k5L8NEJ9YOHF5EyryuGkvl3j707yIWWj7uPOnSryhkqRGr7uLukp3ihaS00OcaWvtqLTJjw4tQfexnmAJkaah4I9qLHc0YHxXNuehw6IjyWozNEN98kZfbJT9O00OcaWvtqLTJjw4tQfexnem4gvaaoWf7HkdfOLdVIpPioS0ftegozNkfTHncpjxSq3YiU1g5aGLMWVCkhsvD2ZDYo9E01TpxUqvrPsgLdPQo75p9g7LycgC4xUhwegfOs1YDYo9ocdNStLI2WgHdjEEwOQv8ihaSozNEN98kZfbJTDWGPbQMNlpWqMnyS0nkunhclScCixEGHmBWydA6GjcdNStLI2WgbWaFJTkzKdawAc)YPCiv1zp3j707rx3(C5cvfLkzuoKQ6SN)0BSxIjyWHF5EyryuGkvl3j707imCYovkAdBenofRaylCi0lICaW2OcaWvtqLTJjw4tQfexnmQt2P3zpVYCb2wadUrfaGdCXEOYqbA5WR4tkIJIiJ6KD6D2ZRmxGTfegimOnKU)Qk2sbPx4K0)vG0QcN6imCYovkAdBeQIZM9kIihaS7O8GBNoGbhZP9Qty4LCOReojfZvcTZQkpJAO8ELDzpPM8GbhZP9Qty4L8EJyQKvam5vgXry4KDQu0g2iufNn7vImDLJ1BvaYHUGbu5Ykawyf4WihaS0CH4j58EJyQKvaSWdbozNk5p9g7LrJzD7ZLRMGkBhda(S1o(tVXEjMGbttmxiEsoNuP8P4sMDaoqbjNR40UcgnMlepjN3BetLScGfEiWj7uj)P3yVetegozNkfTHncvXzZELitx5y9wfGCOlyavUScGfwbomYbalPkRScKCpSiUTluCo8k(KI4AjirP5cXtY5KkLpfxYSdWbki5CfN2vqWGVq8KCEVrmvYkaw4HaNStL8NEJ9YORBFUC1euz7yaWNT2XF6n2lXeHHt2PsrByJqvC2SxjY0vowVvbih6cgqLlRayHvGdJCaWUoK6lVf(okNTftoposvwzfi5EyrCBxO4C4v8jfTrRbbHHt2PsrByJqvC2SxjY0vowxaQNNxWGERfKrkOBJCaWkFJkaah6TwqgPGULjFJkaaxSoH(4AbHHt2PsrByJqvC2SxjY0vowxaQNNxWGERfKrkOBJCaWg(LtP6q54jRayERhwliUt2P3Jg(L7HfHrbQuTCNStVJWWj7uPOnSrOkoB2Rez6khRla1ZZlyqV1cYif0TroayjvzLvGK7HfXTDHIZH3LDrP5cXtY5KkLpfxYSdWbki5CfN2vWO7OC2wm584ivzLvGKtQu(uCjZoahOGKZHxXNu0w70bm4yUq8KCoPs5tXLm7aCGcsoxXPDfetegozNkfTHncvXzZELitx5yDbOEEEbd6TwqgPGUnYba76qQV8w47OC2wm584ivzLvGK7HfXTDHIZHxXNu0w70bHHt2PsrByJqvC2SxjY0vo2EJyQKvam5vgXJCaWsdPkRScKCpSiUTluCo8USlQ8nQaaCGl2dNKIfOutjxSoH(GXgKOxiEsoV3iMkzfal8qGt2Ps(tVXEjMGb3OcaWvtqLTJbaF2Ahxnem4WVCkhsvD2ZDYo9ocdNStLI2WgHQ4SzVsKPRCSqxjCskMReANvvEg1q59k7YEsn5JCaWsQYkRaj3dlIB7cfNdVIpPiU2bdED7ZL7qLowbWwqNjDL8s(tVXEjyWqFKS375YDPuWNmo6IWWj7uPOnSrOkoB2Rez6khBthvLN18ZCRINojYbalPkRScKCHQIsLmkhsvD2ZHxXNueCqthWGJzD7ZLluvuQKr5qQQZE(tVXEz0DuEWTthWGJ50E1jm8so0vcNKI5kH2zvLNrnuEVYUSNutEegozNkfTHncvXzZELitx5yPDxWavbShg5aGn8lNYHuvN9CNStVdgCmRBFUCHQIsLmkhsvD2ZF6n2lJUJYdUD6agCmN2RoHHxYHUs4Kumxj0oRQ8mQHY7v2L9KAYJWWj7uPOnSrOkoB2Rez6khlLBpXT2dfSM70h5aGn8lNYHuvN9CNStVdgCmRBFUCHQIsLmkhsvD2ZF6n2lJUJYdUD6agCmN2RoHHxYHUs4Kumxj0oRQ8mQHY7v2L9KAYJWWj7uPOnSrOkoB2Rez6khlfSskbleokULbDQh5aGfQMpoS0AuA2r5b3oDadoMt7vNWWl5qxjCskMReANvvEg1q59k7YEsn5XeHHt2PsrByJiS2PYihaSKQSYkqYDOshRaylOZK3LC4DzhyWHF5uoKQ6SN7KD6DWGBuba4QjOY2XaGpBTJRgIWG2q6GQ(KRp5KuiD)gdu1(CrAA5wNs9i9iqAhPdHtbNTdHHt2PsrByJOu3g4D6JCaWkRL3BGQ2Nll06uQNdVIpPioSuejcdNStLI2WgbXTwMt2PsMDeBKPRCSxiEsUaHHt2PsrByJG4wlZj7ujZoInY0vowsvwzfifimCYovkAdBeq1K5KDQKzhXgz6khRxpYbaRt2P3zpVYCrWyBhHHt2PsrByJG4wlZj7ujZoInY0vowQNhoeegimOnKMwQcQrAyT(ovIWWj7uPG71XkVVGyEkzYt8UihaSKQSYkqY9WI42UqX5WR4tkqy4KDQuW96THnc5bg7ry4KDQuW96THnIhoYRmKihaSY7liMNsM8eVJVdH(jPIcvZhx7rJPNdhVXEEyv2jPyafKr5qQQZEegozNkfCVEByJqEFbXi1yJCaWkVVGyEkzYt8o(oe6NKkkunFCThnMEoC8g75HvzNKIbuqgLdPQo7ry4KDQuW96THncbPuHuNjw4q)JCaWkVVGyEkzYt8o(oe6NKkkPkRScKCpSiUTluCo8k(KcegozNkfCVEByJGy9atsXeGCzfqe5aGvEFbX8uYKN4D8Di0pjvusvwzfi5EyrCBxO4C4v8jfimCYovk4E92WgXdh5vgsKda2y65WXBSNhwLDskgqbzuoKQ6ShHHt2Psb3R3g2iaUypCskMyHd9psshXE26qQVcSTe5aGv(gvaaoWf7HtsXcuQPKlwNqFCyBjkPkRScKC59feZtjtEI3XHxXNuGWWj7uPG71BdBeaxShojftSWH(h5aGDD7ZL3Ocf7KumrbVG)0BSxgveERLToK6RG3Ocf7KumrbViySThv(gvaaoWf7HtsXcuQPKlwNqFCyBbHHt2Psb3R3g2iK3xqmsn2ihaSnQaaCHQu(KjRsHdVt2Oq18C5bgYSbJniimCYovk4E92WgH8(cIrQXg5aGTrfaGluLYNmzvkC4DYgnMEoC8g75HvzNKIbuqgLdPQo7bdo8lNYHuvN9CNStVJWWj7uPG71BdBeY7ligPgBKdawOAoewyf4qU8adz24AjirPHuLvwbsUhwe32fkohEfFsrW0fmy5Buba4axShojflqPMsUyDc9bhemJgtphoEJ98WQStsXakiJYHuvN9imCYovk4E92WgHGuQqQZelCO)roayPHg5Buba4axShojflqPMsUAyusvwzfi5EyrCBxO4C4v8jfbtxmbdw(gvaaoWf7HtsXcuQPKlwNqFWbbZO0qQYkRaj3HkDScGTGotExYHxXNuemDbdwEFbXOphkqlxocVXEMxRetegozNkfCVEByJGy9atsXeGCzfqe5aGLgAKVrfaGdCXE4KuSaLAk5QHrjvzLvGK7HfXTDHIZHxXNuemDXemy5Buba4axShojflqPMsUyDc9bhemJsdPkRScKChQ0Xka2c6m5DjhEfFsrW0fmy59feJ(COaTC5i8g7zETsmry4KDQuW96THnc59feJuJnYbalunhclScCixEGHmBCTtNOX0ZHJ3yppSk7KumGcYOCiv1zpcdNStLcUxVnSraCXE4KumXch6FKdawAOHgAKVrfaGdCXE4KuSaLAk5I1j0hxqIgtJkaaxnbv2oga8zRDC1qmbdw(gvaaoWf7HtsXcuQPKlwNqFC0kMrjvzLvGK7HfXTDHIZHxXNuehTIjyWY3OcaWbUypCskwGsnLCX6e6JRfmJsdPkRScKChQ0Xka2c6m5DjhEfFsrW0fmy59feJ(COaTC5i8g7zETsmry4KDQuW96THnc59feJuJnYbaBm9C44n2ZdRYojfdOGmkhsvD2JWaHHt2PsbNuLvwbsbwhQ0Xka2c6m5DjcdNStLcoPkRScKI2WgHhwe32fkEKdaw5Buba4axShojflqPMsUyDc9bJnirPXj707SNxzUi4wadoMlepjN3BetLScGfEiWj7uj)P3yVem4lepjN3BetLScGfEiWj7uj)P3yVmknRBFUC1euz7yaWNT2XF6n2lJsQYkRajxnbv2oga8zRDC4v8jfXHLwbdoM1TpxUAcQSDma4Zw74p9g7LyIjcdNStLcoPkRScKI2WgH0H0ZwONcGcQ47uzKda2yG(izV3ZL7sPG)()iwbyWqFKS375YDPuWNm4wOlcdNStLcoPkRScKI2WgHqvrPsgLdPQo7JCaWcvZHWcRahYLhyiZgxlbbHHt2PsbNuLvwbsrByJqnbv2oga8zRDroayVq8KCEVrmvYkaw4HaNStL8NEJ9YOHF5EyryuGkvl3j707GblFJkaah4I9WjPybk1uYfRtOpUGeLMy8wpC2ZvCkvbRaylOZK3L8NEJ9sWG9wpC2ZvCkvbRaylOZK3L8NEJ9YOHF5EyryuGkvl3j707yIWWj7uPGtQYkRaPOnSrOMGkBhda(S1UihaSozNEN98kZfbJT9O0qdPkRScKC59feZtjtEI3XHxXNuehwkImAmRBFUC5bg75p9g7LycgmnKQSYkqYLhySNdVIpPioSuez01TpxU8aJ98NEJ9smXeHHt2PsbNuLvwbsrByJquQwg8E4Hrs6i2Zwhs9vGTLihaSRdP(Y3r5STyY5X1VIUoK6lFhLZ2IjNhCqqy4KDQuWjvzLvGu0g2ieLQLbVhEyKdawAIb6JK9EpxUlLc(7)JyfGbd9rYEVNl3LsbFYGBNoygfQMpoS00sqPrfaGRMGkBhda(S1oUAiMimCYovk4KQSYkqkAdBeQjOY2XASdfOfHbcdNStLc(fINKlWQCLc2XkaMvLmsMeExre5aGfQMNVJYzBXAjykImkunhclScCyCbHoimCYovk4xiEsUOnSr0yRsYka2c6SNxPlYbalnKQSYkqYL3xqmpLm5jEhhEfFsrur4Tw26qQVcU8(cI5PKjpX7cUfmbdMgsvwzfi5Ydm2ZHxXNueveERLToK6RGlpWyFWTGjyW0qQYkRaj3dlIB7cfNdVIpPikPkRScKC59feZtjtEI3XH3LDyIWWj7uPGFH4j5I2WgbLQdLJNScG5TEyTGICaWsdPkRScKCpSiUTluCo8k(KI4c6OKQSYkqYDOshRaylOZK3LC4v8jfbtQYkRajNuP8P4sMDaoqbjNdVIpPatWGjvzLvGK7qLowbWwqNjVl5WR4tkIRDegozNkf8lepjx0g2iwqNPMnLAkzafK8ihaSnQaaC4j0BVqWaki5C1qWGBuba4WtO3EHGbuqYzKsn3d5I1j0hxlTGWWj7uPGFH4j5I2WgbqrufxY8wpC2ZAURe5aGng59feZtjtEI3X3Hq)KuimCYovk4xiEsUOnSrqQK8CH(EjdW6kpYbaRSwoPsYZf67LmaRRCwJkm5WR4tkWshegozNkf8lepjx0g2icvHdq3KuSgRl2ihaSXiVVGyEkzYt8o(oe6NKcHHt2Psb)cXtYfTHnIaf0k79jzWlQ0tYJCaWUU95YDOshRaylOZKUsEj)P3yVm6fINKZ7nIPswbWcpe4KDQKRmzbJ2OcaWvtqLTJjw4tQfexnem4lepjN3BetLScGfEiWj7ujxzYcgn8l3dlcJcuPA5ozNEhm41TpxUdv6yfaBbDM0vYl5p9g7Lrd)Y9WIWOavQwUt2P3JsQYkRaj3HkDScGTGotExYHxXNueCqthWGx3(C5ouPJvaSf0zsxjVK)0BSxgn8l3HkDmkqLQL7KD6DegozNkf8lepjx0g2icuqRS3NKbVOspjpYbaBmY7liMNsM8eVJVdH(jPI2OcaWvtqLTJjw4tQfexnmAmxiEsoV3iMkzfal8qGt2PsUYKfmAmRBFUChQ0Xka2c6mPRKxYF6n2lbdEDi1x(okNTftoposvwzfi5EyrCBxO4C4v8jfimCYovk4xiEsUOnSraNWq7ztYeHo5roayJrEFbX8uYKN4D8Di0pjfcdNStLc(fINKlAdBeW7HtsXaSUYfimqy4KDQuWPEE4qWkVVGyKASroayBuba4cvP8jtwLchENSrJPNdhVXEEyv2jPyafKr5qQQZEWGd)YPCiv1zp3j707imCYovk4uppCiTHnc59feJuJnYbalunhclScCixEGHmBCTeKO0qQYkRaj3dlIB7cfNdVIpPiy6cgS8nQaaCGl2dNKIfOutjxSoH(GdcMrJPNdhVXEEyv2jPyafKr5qQQZEegozNkfCQNhoK2WgH8(cI5PKjpX7ICaWUU95YdVyh7tY5p9g7LrjvzLvGK7HfXTDHIZHxXNuGWWj7uPGt98WH0g2iKhySpYbalPkRScKCpSiUTluCo8k(KcegozNkfCQNhoK2WgHGuQqQZelCO)roayPHg5Buba4axShojflqPMsUAyuAivzLvGK7HfXTDHIZHxXNuemDJstmxiEsoV3iMkzfal8qGt2Ps(tVXEjyWXSU95YvtqLTJbaF2Ah)P3yVetWGVq8KCEVrmvYkaw4HaNStL8NEJ9YORBFUC1euz7yaWNT2XF6n2lJsQYkRajxnbv2oga8zRDC4v8jfbh0yIjyWY3OcaWbUypCskwGsnLCX6e6doiygLgsvwzfi5ouPJvaSf0zY7so8k(KIGPlMimCYovk4uppCiTHncI1dmjftaYLvarKdawAOr(gvaaoWf7HtsXcuQPKRggLgsvwzfi5EyrCBxO4C4v8jfbt3O0eZfINKZ7nIPswbWcpe4KDQK)0BSxcgCmRBFUC1euz7yaWNT2XF6n2lXem4lepjN3BetLScGfEiWj7uj)P3yVm662Nlxnbv2oga8zRD8NEJ9YOKQSYkqYvtqLTJbaF2AhhEfFsrWbnMycgS8nQaaCGl2dNKIfOutjxSoH(GdcMrPHuLvwbsUdv6yfaBbDM8UKdVIpPiy6IjcdNStLco1ZdhsByJqEFbXi1yJCaWcvZHWcRahYLhyiZgx70jAm9C44n2ZdRYojfdOGmkhsvD2JWWj7uPGt98WH0g2iaUypCskMyHd9pYbaln0qdnY3OcaWbUypCskwGsnLCX6e6JlirJPrfaGRMGkBhda(S1oUAiMGblFJkaah4I9WjPybk1uYfRtOpoAfZOKQSYkqY9WI42UqX5WR4tkIJwXemy5Buba4axShojflqPMsUyDc9X1cMrPHuLvwbsUdv6yfaBbDM8UKdVIpPiy6cgS8(cIrFouGwUCeEJ9mVwjMimCYovk4uppCiTHncGl2dNKIjw4q)JCaWkFJkaah4I9WjPybk1uYfRtOpUGeLgsvwzfi5EyrCBxO4C4v8jfXrRrPjMlepjN3BetLScGfEiWj7uj)P3yVem4yw3(C5QjOY2XaGpBTJ)0BSxcg8fINKZ7nIPswbWcpe4KDQK)0BSxgDD7ZLRMGkBhda(S1o(tVXEzusvwzfi5QjOY2XaGpBTJdVIpPiU(bMycgS8nQaaCGl2dNKIfOutjxSoH(4AjknKQSYkqYDOshRaylOZK3LC4v8jfbtxmry4KDQuWPEE4qAdBeY7ligPgBKda2y65WXBSNhwLDskgqbzuoKQ6S3SM1yaa]] )

end
