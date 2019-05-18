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

        potion = "battle_potion_of_strength",

        package = "Unholy",
    } )


    spec:RegisterSetting( "festermight_cycle", false, {
        name = "Festermight:  Spread |T237530:0|t Festering Wounds before |T136144:0|t Death and Decay",
        desc = function ()
            return  "If checked, the addon will encourage you to spread Festering Wounds to multiple targets before |T136144:0|t Death and Decay.\n\n" ..
                    "Requires |cFF" .. ( state.azerite.festermight.enabled and "00FF00" or "FF0000" ) .. "Festermight|r (Azerite)\n" .. 
                    "Requires |cFF" .. ( state.settings.cycle and "00FF00" or "FF0000" ) .. "Recommend Target Swaps|r in |cFFFFD100Targeting|r section."
        end,
        type = "toggle",
        width = "full"
    } )  


    spec:RegisterPack( "Unholy", 20190518.1630, [[dKu37aqiQOEKQG2Kc1OOcDkQiVsHywePULQaTlQ6xiPggrKJrfSmvepdjjttvORPI02uiX3qskJtvaNdjrwNcP4DijvzEuP6EQs7dvQdQqQAHuP8qfsLjIKuPlIKqTrKeYjviLSsvuVejrv3ejbTtIWprsQyOijv1srsuXtvvtfvYvrsu2ksIkTxe)vWGj5WuwScEmPMmkxgSzv6ZkA0ujNwQvRqk1RjsMnHBJQ2TKFlA4e1XviPLd1ZfA6kDDKA7QI(osmEKe48QW6jIA(OI9dzIdeUiFMTarItKKdujjDQdpG3Hr5Kh4rQe5VhYa5lBAPSjq(LXdKpvw5kfhKVSDisJr4I8JjnwdK)drkx7khhnut9Sxx0dEDYtDS5Pf22zPX2DPo28AQj)b6wSJwfzG8z2cejorsoqLK0Po8aEhgLtOkQIQr(rzqtK4KtpH8D1mguKbYNbrn5)qKIkRCLIdKIQlyRlKIkF1txl68drkx7khhnut9Sxx0dEDYtDS5Pf22zPX2DPo28AQrNFisrfAhiLdpG0i1jsYbQes9GiLdJYO5ejHoJo)qKA05YQjehnOZpePEqKA0ZyadPOc7IHuuryaKm4rNFis9Gi1OlRNaEbgsTgEcBOViLolwVDwrKAtKcdtAHHrkDwSE7SIE05hIupis9tEaPs5T5BjBBNfsLxKIkcIlGhe901IuDHuJEQouXu9qQiaifvw5kfhivkVDwrp5l64gjCr(tOaCRjCrKWbcxKpu2Gaye3iFnUxa3g5pqFV(inJbvGLjVhdMErQXiLZi1td32Ga8Yzk6AgUjomn8mpeasXHdsjdRFA4zEiaVP3(jq(ME7SiFgyRRGoBbzjsCcHlYhkBqamIBKVg3lGBJ8X0vRdYjfa7zWT19IuUJuo8isngPCeP0zkyjLYBYP2ehYrWJbERRisXnsDksXHdsXGb671FH4c4UMbkjDX8X10sHuCJupIuoHuJrkNrQNgUTbb4LZu01mCtCyA4zEiaY30BNf5ZaBDf0zlilrcQIWf5dLniagXnYxJ7fWTr(RjGA9YqCBbuAWdLniagsngP0zkyjLYBYP2ehYrWJbERRi5B6TZI8zGTUcwXcmqBhKLiXJeUiFOSbbWiUr(ACVaUnYxNPGLukVjNAtCihbpg4TUIKVP3olYNb3waKLiXPeUiFOSbbWiUr(ACVaUnY3rKYrKIbd03R)cXfWDndus6I5PLrQXiLotblPuEto1M4qocEmWBDfrkUrQtrkNqkoCqkgmqFV(lexa31mqjPlMpUMwkKIBK6rKYjKAmsPZuWskL3W8hH8gwxqGbgZJbERRisXnsDk5B6TZI8J6KgpHqCXTuazjsmkeUiFOSbbWiUr(ACVaUnY3rKYrKIbd03R)cXfWDndus6I5PLrQXiLotblPuEto1M4qocEmWBDfrkUrQtrkNqkoCqkgmqFV(lexa31mqjPlMpUMwkKIBK6rKYjKAmsPZuWskL3W8hH8gwxqGbgZJbERRisXnsDk5B6TZI81cJsxZq0LXskrYsKGQr4I8HYgeaJ4g5RX9c42iFmD16GCsbWEgCBDViL7i1jscPgJuoJupnCBdcWlNPORz4M4W0WZ8qaKVP3olYNb26kOZwqwIepaHlYhkBqamIBKVg3lGBJ8DePCePCePCePyWa996VqCbCxZaLKUy(4AAPqk3rQhrQXiLZi1a996PlxP4iCXqj5dpTms5esXHdsXGb671FH4c4UMbkjDX8X10sHuUJuufs5esngP0zkyjLYBYP2ehYrWJbERRis5osrviLtifhoifdgOVx)fIlG7AgOK0fZhxtlfs5os5as5esngP0zkyjLYBy(JqEdRliWaJ5XaV1veP4gPoL8n92zr(xiUaURziU4wkGSejOseUiFOSbbWiUr(ACVaUnY3zK6PHBBqaE5mfDnd3ehMgEMhcG8n92zr(mWwxbD2cYswYNbxJwSeUis4aHlY30BNf5Z3flCXaizG8HYgeaJ4gzjsCcHlYhkBqamIBKFkt(ryjFtVDwK)td32Gai)NMGgiFDMcwsP8rAE(SctdpZdb4XaV1vePChPofPgJuRjGA9rAE(SctdpZdb4HYgeaJ8FA4qz8a5lNPORz4M4W0WZ8qaKLibvr4I8HYgeaJ4g5RX9c42iFmD16GCsbWEgCBDVif3i1OCksngPCeP0zkyjLYhP55Zkmn8mpeGhd8wxrKIdhKYzKAnbuRpsZZNvyA4zEiapu2GayiLti1yKctxGNb3w3lsX9lsDk5B6TZI8nS2kiSjgd1swIeps4I8HYgeaJ4g5RX9c42iFzy9tdpZdb4n92pbKIdhKYzKAnbuRpsZZNvyA4zEiapu2GayKVP3olYFqKjlCPXhKLiXPeUiFOSbbWiUr(ACVaUnYxgw)0WZ8qaEtV9taP4WbPCgPwta16J088zfMgEMhcWdLniag5B6TZI8haCeWs11KSejgfcxKVP3olYNocHEb(i5dLniagXnYsKGQr4I8HYgeaJ4g5B6TZI8XgVCxZGXll6LMbHzpTNPydqn7ciFnUxa3g57is5isTMaQ1txUsXr4IHsYhEOSbbWqkoCqktYaUxWZBt6yiVH1feyGX8qzdcGHuoHuJrkhrkDMcwsP8gM)iK3W6ccmWyEmWBDfrkUFrQhprsifhoiLotblPuEto1M4qocEmWBDfrkNqkNqkoCqkS1Sa8eQ1Bmw03fs5osDk5xgpq(yJxURzW4Lf9sZGWSN2ZuSbOMDbKLiXdq4I8HYgeaJ4g5B6TZI8XgVCxZGXll6LMbHzpTNPydqn7ciFnUxa3g5RZuWskL3KtTjoKJGhd8wxrKYDK6eKIdhKAnbuR3W8hH8gwxqGz8fW8qzdcGHuC4GuyRzb4juR3ySOVlKYDK6uYVmEG8XgVCxZGXll6LMbHzpTNPydqn7cilrcQeHlYhkBqamIBKVP3olYF4yMfegaiycERmn5RX9c42iFDMcwsP8rAE(SctdpZdb4XaV1veP4gPgfjHuC4GuoJuRjGA9rAE(SctdpZdb4HYgeadPgJuBZdif3i1jscP4WbPCgPGrLULLbMhB8YDndgVSOxAgeM90EMIna1SlG8lJhi)HJzwqyaGGj4TY0KLiHdsIWf5dLniagXnY30BNf5pAdXGRKIaWKVg3lGBJ8LH1pn8mpeG30B)eqkoCqkNrQ1eqT(inpFwHPHN5Ha8qzdcGHuJrQT5bKIBK6ejHuC4GuoJuWOs3YYaZJnE5UMbJxw0lndcZEAptXgGA2fq(LXdK)OnedUskcatwIeo4aHlYhkBqamIBKVP3olYFAcqBcbGJHbWKI814EbCBKVmS(PHN5Ha8ME7NasXHds5msTMaQ1hP55Zkmn8mpeGhkBqamKAmsTnpGuCJuNijKIdhKYzKcgv6wwgyESXl31my8YIEPzqy2t7zk2auZUaYVmEG8NMa0Mqa4yyamPilrchoHWf5dLniagXnY30BNf5pXznJbzCZBIa2Ma5RX9c42iFNrkyuPBzzG5XgVCxZGXll6LMbHzpTNPydqn7cqQXiLJi1a996PlxP4iCXqj5dpg4TUIifhoiLJifMUaKY9xKIQqQXiLZi1AcOwpD5kfhHlgkjF4HYgeadPCcPCI8lJhi)joRzmiJBEteW2eilrchOkcxKpu2Gaye3iFtVDwK)eN1mgKXnVjcyBcKVg3lGBJ8HrLULLbMhB8YDndgVSOxAgeM90EMIna1SlaPgJu6mfSKs5n5uBId5i4XaV1veP4gPorsKFz8a5pXznJbzCZBIa2Mazjs4WJeUiFOSbbWiUr(ACVaUnYxNPGLukVH5pc5nSUGadmMhdg7aP4WbPKH1pn8mpeG30B)eqkoCqQb671txUsXr4IHsYhEAzY30BNf5lNBNfzjs4WPeUiFOSbbWiUr(ME7Si)KEhWGjf5RX9c42iFwU(NnMwa1gKf2Kg8yG36kIuU)IutnJ81hAbewdpHnsKWbYsKWHrHWf5dLniagXnY30BNf5RnHiy6TZki64s(IoUHY4bYxNPGLuQizjs4avJWf5dLniagXnYxJ7fWTr(ME7NqakGVHisX9lsDc5B6TZI8X0vW0BNvq0XL8fDCdLXdKVLazjs4Wdq4I8HYgeaJ4g5B6TZI81Mqem92zfeDCjFrh3qz8a5pHcWTMSKL8LXGo5hSLWfrchiCr(qzdcGrCJSejoHWf5dLniagXnYsKGQiCr(qzdcGrCJSejEKWf5dLniagXnYsK4ucxKVP3olYxo3olYhkBqamIBKLiXOq4I8n92zr(yRJqGbgJ8HYgeaJ4gzjsq1iCr(qzdcGrCJ8zGWoi)tiFtVDwKVH5pc5nSUGadmgzjl5RZuWskvKWfrchiCr(ME7SiFdZFeYByDbbgymYhkBqamIBKLiXjeUiFOSbbWiUr(ACVaUnYNbd03R)cXfWDndus6I5JRPLcP4(fPEK8n92zr(MCQnXHCeilrcQIWf5dLniagXnYxJ7fWTr(oJuyRzb4juR3ySOhOc64grkoCqkS1Sa8eQ1Bmw03fsXns5WPKVP3olYNzyPcl2Q4nX822zrwIeps4I8HYgeaJ4g5RX9c42iFmD16GCsbWEgCBDViL7iLdps(ME7Si)inpFwHPHN5HailrItjCr(qzdcGrCJ814EbCBKpdgOVx)fIlG7AgOK0fZhxtlfs5os9isngPCgPCePGrLULLbMhB8YDndgVSOxAgeM90EMIna1SlaP4WbPmjd4EbpVnPJH8gwxqGbgZdLniags5e5B6TZI8PlxP4iCXqj5dYsKyuiCr(qzdcGrCJ814EbCBKVotblPuEto1M4qocEmWBDfrk3FrQtqQXiLJifmQ0TSmW8yJxURzW4Lf9sZGWSN2ZuSbOMDbifhoiLjza3l45TjDmK3W6ccmWyEOSbbWqkNiFtVDwKpD5kfhHlgkjFqwIeuncxKpu2Gaye3iFnUxa3g5B6TFcbOa(gIif3Vi1ji1yKYrKYrKsNPGLukpdS1vWkwGbA7WJbERRis5(lsn1mKAms5msTMaQ1ZGBlapu2GayiLtifhoiLJiLotblPuEgCBb4XaV1vePC)fPMAgsngPwta16zWTfGhkBqamKYjKYjY30BNf5txUsXr4IHsYhKLiXdq4I8HYgeaJ4g5RX9c42i)1Wty9BZdHndSgqk3rQhaPgJuRHNW63MhcBgynGuCJups(ME7Si)yslcyWKbmzjsqLiCr(qzdcGrCJ814EbCBKVJiLZif2AwaEc16ngl6bQGoUrKIdhKcBnlapHA9gJf9DHuCJuNijKYjKAmsHPlaPC)fPCePCaPEqKAG(E90LRuCeUyOK8HNwgPCI8n92zr(XKweWGjdyYsKWbjr4I8n92zr(0LRuCege901s(qzdcGrCJSKL8TeiCrKWbcxKpu2Gaye3iFnUxa3g5RZuWskL3KtTjoKJGhd8wxrY30BNf5ZaBDfSIfyG2oilrItiCr(ME7SiFgCBbq(qzdcGrCJSejOkcxKpu2Gaye3iFnUxa3g5ZaBDfSIfyG2o8BRLQRjsngPCePm92pHalx)fIlG7AgOK0fdPErkjHuJrkmDbiL7i1jifhoifMUaKYDKYbKYjKAms5ms90WTniaVCMIUMHBIdtdpZdbq(ME7SiFqUzaFRjlrIhjCr(qzdcGrCJ814EbCBKpdS1vWkwGbA7WVTwQUMi1yKctxas5osDcsngPCgPEA42geGxotrxZWnXHPHN5HaiFtVDwKpdS1vqNTGSejoLWf5dLniagXnYxJ7fWTr(mWwxbRybgOTd)2AP6AIuJrkDMcwsP8MCQnXHCe8yG36ks(ME7Si)OoPXtiexClfqwIeJcHlYhkBqamIBKVg3lGBJ8zGTUcwXcmqBh(T1s11ePgJu6mfSKs5n5uBId5i4XaV1vK8n92zr(AHrPRzi6YyjLizjsq1iCr(qzdcGrCJ814EbCBKVZi1td32Ga8Yzk6AgUjomn8mpea5B6TZI8b5Mb8TMSejEacxKpu2Gaye3iFtVDwK)fIlG7AgIlULciFnUxa3g5ZGb671FH4c4UMbkjDX8X10sHuU)IuoGuJrkDMcwsP8mWwxbRybgOTdpg4TUIKV(qlGWA4jSrIeoqwIeujcxKpu2Gaye3iFnUxa3g5VMaQ1pqJJBxZqmXq0dLniagsngPIYGqewdpHn6hOXXTRziMyiIuC)IuNGuJrkgmqFV(lexa31mqjPlMpUMwkKY9xKYbY30BNf5FH4c4UMH4IBPaYsKWbjr4I8HYgeaJ4g5RX9c42i)b671hPzmOcSm59yW0lsngPW0f4zWT19IuC)Iups(ME7SiFgyRRGoBbzjs4GdeUiFOSbbWiUr(ACVaUnYFG(E9rAgdQaltEpgm9IuJrkNrQNgUTbb4LZu01mCtCyA4zEiaKIdhKsgw)0WZ8qaEtV9tG8n92zr(mWwxbD2cYsKWHtiCr(qzdcGrCJ814EbCBKpMUADqoPaypdUTUxKYDKYHhrQXiLJiLotblPuEto1M4qocEmWBDfrkUrQtrkoCqkgmqFV(lexa31mqjPlMpUMwkKIBK6rKYjKAms5ms90WTniaVCMIUMHBIdtdpZdbq(ME7SiFgyRRGoBbzjs4avr4I8HYgeaJ4g5RX9c42iFNrQOmgmwxZaLKUyrKAms5is5isXGb671FH4c4UMbkjDX80Yi1yKsNPGLukVjNAtCihbpg4TUIif3i1PiLtifhoifdgOVx)fIlG7AgOK0fZhxtlfsXns9is5esngP0zkyjLYBy(JqEdRliWaJ5XaV1veP4gPoL8n92zr(rDsJNqiU4wkGSejC4rcxKpu2Gaye3iFnUxa3g57msfLXGX6AgOK0flIuJrkhrkhrkgmqFV(lexa31mqjPlMNwgPgJu6mfSKs5n5uBId5i4XaV1veP4gPofPCcP4WbPyWa996VqCbCxZaLKUy(4AAPqkUrQhrkNqQXiLotblPuEdZFeYByDbbgympg4TUIif3i1PKVP3olYxlmkDndrxglPejlrchoLWf5dLniagXnYxJ7fWTr(y6Q1b5KcG9m426Erk3rQtKesngPCgPEA42geGxotrxZWnXHPHN5HaiFtVDwKpdS1vqNTGSejCyuiCr(qzdcGrCJ814EbCBKVJiLJiLJiLJifdgOVx)fIlG7AgOK0fZhxtlfs5os9isngPCgPgOVxpD5kfhHlgkjF4PLrkNqkoCqkgmqFV(lexa31mqjPlMpUMwkKYDKIQqkNqQXiLotblPuEto1M4qocEmWBDfrk3rkQcPCcP4WbPyWa996VqCbCxZaLKUy(4AAPqk3rkhqkNqQXiLotblPuEdZFeYByDbbgympg4TUIif3i1PKVP3olY)cXfWDndXf3sbKLiHduncxKpu2Gaye3iFnUxa3g57ms90WTniaVCMIUMHBIdtdpZdbq(ME7SiFgyRRGoBbzjlzj)Nao2zrK4ej5avssNkPt9oq1o9rYNIHRUMrYF0IxoXlWqQtrktVDwiLOJB0Jot(g96kXK)V5Pf22zn6W2DjFzCEBbq(pePOYkxP4aPO6c26cPOYx901Io)qKY1UYXrd1up71f9GxN8uhBEAHTDwASDxQJnVMA05hIuuH2bs5WdinsDIKCGkHupis5WOmAorsOZOZpePgDUSAcXrd68drQhePg9mgWqkQWUyifvegajdE05hIupisn6Y6jGxGHuRHNWg6lsPZI1BNveP2ePWWKwyyKsNfR3oROhD(Hi1dIu)KhqQuEB(wY22zHu5fPOIG4c4brpDTivxi1ONQdvmvpKkcasrLvUsXbsLYBNv0JoJo)qKIkMka00lWqQb4MyaP0j)GTi1am7k6rQrVwdYBePQSEqxgM)slqktVDwrKklXHhD20BNv0lJbDYpy77vyrPqNn92zf9YyqN8d2oYl13mzOZME7SIEzmOt(bBh5LAJEYd1ABNf68drQFzYrx5IuyRzi1a99cmKkU2grQb4MyaP0j)GTi1am7kIuwXqkzm8GY5UDnrQoIuSSap6SP3oROxgd6KFW2rEPowMC0vUH4ABeD20BNv0lJbDYpy7iVulNBNf6SP3oROxgd6KFW2rEPgBDecmWyOZME7SIEzmOt(bBh5LAdZFeYByDbbgymPzGWoEpbDgD(HifvmvaOPxGHuWtaFGuBZdi16cqktVjgP6iszpTwydcWJoB6TZk(Y3flCXaizaD20BNvCKxQFA42geG0LXdVYzk6AgUjomn8mpeG0pnbn8QZuWskLpsZZNvyA4zEiapg4TUIUF641eqT(inpFwHPHN5Ha8qzdcGHo)qKIkht3MiknsnATaFuAKYkgsLRlaJu5uZIOZME7SIJ8sTH1wbHnXyOwP77lMUADqoPaypdUTUxUhLth7OotblPu(inpFwHPHN5Ha8yG36kYHJZRjGA9rAE(SctdpZdb4HYgeaZPXy6c8m426E5(9u0ztVDwXrEPEqKjlCPXhs33xzy9tdpZdb4n92pboCCEnbuRpsZZNvyA4zEiapu2GayOZME7SIJ8s9aGJawQUMs33xzy9tdpZdb4n92pboCCEnbuRpsZZNvyA4zEiapu2GayOZpePgD0Xn5rQf3LuWgrk6Onb0ztVDwXrEPMocHEb(i6SP3oR4iVuthHqVaV0LXdVyJxURzW4Lf9sZGWSN2ZuSbOMDbs33xhDCnbuRNUCLIJWfdLKp8qzdcGXHJjza3l45TjDmK3W6ccmWyEOSbbWCASJ6mfSKs5nm)riVH1feyGX8yG36kY97JNijoC0zkyjLYBYP2ehYrWJbERROtoXHd2AwaEc16ngl67Y9trNn92zfh5LA6ie6f4LUmE4fB8YDndgVSOxAgeM90EMIna1Slq6((QZuWskL3KtTjoKJGhd8wxr3pHdN1eqTEdZFeYByDbbMXxaZdLniaghoyRzb4juR3ySOVl3pfD20BNvCKxQPJqOxGx6Y4H3HJzwqyaGGj4TY0s33xDMcwsP8rAE(SctdpZdb4XaV1vK7rrsC448AcOwFKMNpRW0WZ8qaEOSbbWgVnpW9jsIdhNHrLULLbMhB8YDndgVSOxAgeM90EMIna1SlaD20BNvCKxQPJqOxGx6Y4H3rBigCLueaw6((kdRFA4zEiaVP3(jWHJZRjGA9rAE(SctdpZdb4HYgeaB828a3NijoCCggv6wwgyESXl31my8YIEPzqy2t7zk2auZUa0ztVDwXrEPMocHEbEPlJhENMa0Mqa4yyamPKUVVYW6NgEMhcWB6TFcC448AcOwFKMNpRW0WZ8qaEOSbbWgVnpW9jsIdhNHrLULLbMhB8YDndgVSOxAgeM90EMIna1SlaD20BNvCKxQPJqOxGx6Y4H3joRzmiJBEteW2eKUVVodJkDlldmp24L7AgmEzrV0mim7P9mfBaQzxWyhhOVxpD5kfhHlgkjF4XaV1vKdhhX0f4(lvn251eqTE6Yvkocxmus(WdLniaMtoHoB6TZkoYl10ri0lWlDz8W7eN1mgKXnVjcyBcs33xyuPBzzG5XgVCxZGXll6LMbHzpTNPydqn7cgRZuWskL3KtTjoKJGhd8wxrUprsOZME7SIJ8sTCUDws33xDMcwsP8gM)iK3W6ccmWyEmySdoCKH1pn8mpeG30B)e4WzG(E90LRuCeUyOK8HNwgD(HifvO11AD11ePOYTX0cOwKIQVWM0as1rKYqkzCN4EpqNn92zfh5L6KEhWGjL06dTacRHNWgFDq6((YY1)SX0cO2GSWM0Ghd8wxr3FNAg6SP3oR4iVuRnHiy6TZki64kDz8WRotblPur0ztVDwXrEPgtxbtVDwbrhxPlJhETeKUVVME7NqakGVHi3VNGoB6TZkoYl1AticME7ScIoUsxgp8oHcWTgDgD(Hi1OpPIrkCU22zHoB6TZk6TeEzGTUcwXcmqBhs33xDMcwsP8MCQnXHCe8yG36kIoB6TZk6Teg5LAgCBbGoB6TZk6Teg5LAqUzaFRLUVVmWwxbRybgOTd)2AP6Ao2rtV9tiWY1FH4c4UMbkjDXEL0ymDbUFchoy6cC3bNg78td32Ga8Yzk6AgUjomn8mpea6SP3oRO3syKxQzGTUc6Sfs33xgyRRGvSad02HFBTuDnhJPlW9tg78td32Ga8Yzk6AgUjomn8mpea6SP3oRO3syKxQJ6KgpHqCXTuG099Lb26kyflWaTD43wlvxZX6mfSKs5n5uBId5i4XaV1veD20BNv0BjmYl1AHrPRzi6YyjLO099Lb26kyflWaTD43wlvxZX6mfSKs5n5uBId5i4XaV1veD20BNv0BjmYl1GCZa(wlDFFD(PHBBqaE5mfDnd3ehMgEMhcaD20BNv0BjmYl1xiUaURziU4wkqA9HwaH1WtyJVoiDFFzWa996VqCbCxZaLKUy(4AAPC)1HX6mfSKs5zGTUcwXcmqBhEmWBDfrNn92zf9wcJ8s9fIlG7AgIlULcKUVVRjGA9d04421metme9qzdcGnokdcryn8e2OFGgh3UMHyIHi3VNmMbd03R)cXfWDndus6I5JRPLY9xhqNn92zf9wcJ8sndS1vqNTq6((oqFV(inJbvGLjVhdMEhJPlWZGBR7L73hrNn92zf9wcJ8sndS1vqNTq6((oqFV(inJbvGLjVhdMEh78td32Ga8Yzk6AgUjomn8mpeahoYW6NgEMhcWB6TFcOZME7SIElHrEPMb26kOZwiDFFX0vRdYjfa7zWT196Udpo2rDMcwsP8MCQnXHCe8yG36kY9PC4WGb671FH4c4UMbkjDX8X10sX9Jon25NgUTbb4LZu01mCtCyA4zEia0ztVDwrVLWiVuh1jnEcH4IBPaP77RZrzmySUMbkjDXIJD0rgmqFV(lexa31mqjPlMNwESotblPuEto1M4qocEmWBDf5(uN4WHbd03R)cXfWDndus6I5JRPLI7hDASotblPuEdZFeYByDbbgympg4TUICFk6SP3oRO3syKxQ1cJsxZq0LXskrP77RZrzmySUMbkjDXIJD0rgmqFV(lexa31mqjPlMNwESotblPuEto1M4qocEmWBDf5(uN4WHbd03R)cXfWDndus6I5JRPLI7hDASotblPuEdZFeYByDbbgympg4TUICFk6SP3oRO3syKxQzGTUc6Sfs33xmD16GCsbWEgCBDVUFIKg78td32Ga8Yzk6AgUjomn8mpea68drkjaGHuBIuxiUagPO4QfasrX6TRjs5cWG37rkKIkQN0yaP6fPs61zNDgD20BNv0BjmYl1xiUaURziU4wkq6((6OJo6idgOVx)fIlG7AgOK0fZhxtlL7po25b671txUsXr4IHsYhEAzN4WHbd03R)cXfWDndus6I5JRPLYDQYPX6mfSKs5n5uBId5i4XaV1v0DQYjoCyWa996VqCbCxZaLKUy(4AAPC3bNgRZuWskL3W8hH8gwxqGbgZJbERRi3NIoB6TZk6Teg5LAgyRRGoBH09915NgUTbb4LZu01mCtCyA4zEia0z0ztVDwrVotblPuXxdZFeYByDbbgym0ztVDwrVotblPuXrEP2KtTjoKJG099Lbd03R)cXfWDndus6I5JRPLI73hrNn92zf96mfSKsfh5LAMHLkSyRI3eZBBNL0991zS1Sa8eQ1Bmw0dubDCJC4GTMfGNqTEJXI(U42HtrNn92zf96mfSKsfh5L6inpFwHPHN5HaKUVVy6Q1b5KcG9m426ED3HhrNn92zf96mfSKsfh5LA6Yvkocxmus(q6((YGb671FH4c4UMbkjDX8X10s5(JJD2ryuPBzzG5XgVCxZGXll6LMbHzpTNPydqn7c4WXKmG7f882KogYByDbbgympu2GayoHoB6TZk61zkyjLkoYl10LRuCeUyOK8H099vNPGLukVjNAtCihbpg4TUIU)EYyhHrLULLbMhB8YDndgVSOxAgeM90EMIna1SlGdhtYaUxWZBt6yiVH1feyGX8qzdcG5e6SP3oROxNPGLuQ4iVutxUsXr4IHsYhs33xtV9tiafW3qK73tg7OJ6mfSKs5zGTUcwXcmqBhEmWBDfD)DQzJDEnbuRNb3waEOSbbWCIdhh1zkyjLYZGBlapg4TUIU)o1SXRjGA9m42cWdLniaMtoHoB6TZk61zkyjLkoYl1XKweWGjdyP777A4jS(T5HWMbwdU)aJxdpH1Vnpe2mWAG7hrNn92zf96mfSKsfh5L6yslcyWKbS0991rNXwZcWtOwVXyrpqf0XnYHd2AwaEc16ngl67I7tKKtJX0f4(RJo8Gd03RNUCLIJWfdLKp80YoHoB6TZk61zkyjLkoYl10LRuCege901IoJoB6TZk6Nqb4w)YaBDf0zlKUVVd03RpsZyqfyzY7XGP3Xo)0WTniaVCMIUMHBIdtdpZdbWHJmS(PHN5Ha8ME7Na6SP3oROFcfGB9iVuZaBDf0zlKUVVy6Q1b5KcG9m426ED3Hhh7OotblPuEto1M4qocEmWBDf5(uoCyWa996VqCbCxZaLKUy(4AAP4(rNg78td32Ga8Yzk6AgUjomn8mpea6SP3oROFcfGB9iVuZaBDfSIfyG2oKUVVRjGA9YqCBbuAWdLnia2yDMcwsP8MCQnXHCe8yG36kIoB6TZk6Nqb4wpYl1m42cq6((QZuWskL3KtTjoKJGhd8wxr0ztVDwr)eka36rEPoQtA8ecXf3sbs33xhDKbd03R)cXfWDndus6I5PLhRZuWskL3KtTjoKJGhd8wxrUp1joCyWa996VqCbCxZaLKUy(4AAP4(rNgRZuWskL3W8hH8gwxqGbgZJbERRi3NIoB6TZk6Nqb4wpYl1AHrPRzi6YyjLO0991rhzWa996VqCbCxZaLKUyEA5X6mfSKs5n5uBId5i4XaV1vK7tDIdhgmqFV(lexa31mqjPlMpUMwkUF0PX6mfSKs5nm)riVH1feyGX8yG36kY9POZME7SI(juaU1J8sndS1vqNTq6((IPRwhKtka2ZGBR719tK0yNFA42geGxotrxZWnXHPHN5HaqNn92zf9tOaCRh5L6lexa31mexClfiDFFD0rhDKbd03R)cXfWDndus6I5JRPLY9hh78a996PlxP4iCXqj5dpTStC4WGb671FH4c4UMbkjDX8X10s5ov50yDMcwsP8MCQnXHCe8yG36k6ov5ehomyG(E9xiUaURzGssxmFCnTuU7GtJ1zkyjLYBy(JqEdRliWaJ5XaV1vK7trNn92zf9tOaCRh5LAgyRRGoBH09915NgUTbb4LZu01mCtCyA4zEiaYswcb]] )

end
