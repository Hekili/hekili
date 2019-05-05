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
                if dot.festering_wound.stack >= 2 and active_dot.festering_wound < active_enemies then return "festering_wound" end
            end,
            cycleMin = 8, -- don't try to cycle onto targets that will die too fast to get consumed.

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


    spec:RegisterPack( "Unholy", 20190505.1754, [[dGuL8aqiQQ6rkQ0MuOgfrQtre9kfsZIO4wkQODrLFHkzyOcDmQkwMcXZikX0uu11uuABeL03qfKXHkOoNIISoff08OQY9uL2hQOdQOcTqQk9qfvWevuaDrubQnIkGojQayLQcVurbYnrfi7Ki5NkkadfvaQLQOa1tvvtLiCvffL2kQaK9I0FfmysomLfRGhtQjJYLbBwL(Skgnr1PLA1kkkEnQuZMWTrv7w0VLmCQYXvuOLd1ZfA6kDDeTDvrFhbJxrr15vK1tuQ5Jq7hYuFOsq)mBbQuJWrFMjoolhN15dhA25NFMO)DYdOFptZTDa6pnEG(Nzt5LyI(9SjrzmQe0FSiXAG(NlsjFxV4mKlUo9kNCWPlEUInpPW2Usn2UlxXMxZf9pq2ILdqshOFMTavQr4OpZehNLJZ68HdnphEeoe9h9anvQrMDe6xEZyqshOFge10)CrQz2uEjMqQzGGTYrQzqzFKVOhZfPKVRxCgYfxNELto40fpxXMNuyBxPgB3LRyZR5c9yUifhKnHuJidsnch9zMqQ5ePgXNz4i(GEGEmxKAoi3YdeNHOhZfPMtKAoYyadP4G6KHuCGyaKn4qpMlsnNi1COYNaEbgsTg(aBOViLUswVDLrKAlKcdhsHHrkDLSE7kJo0J5IuZjs9lEaPkVT5BzBBxjsvxKIdeIlGhe9r(IuDIuZXzaCWo6x0XnsLG(pqc4wtLGkLpujOFiTbbWO(s)ACVaUn6FG8EDrsgdYaRkEhgm9IuJrk)rQNgUTbb48Qs05jClC4y4tnjaKIirKYdw3XWNAsaotV9tG(n92vs)mWw5bD1c6sLAeQe0pK2GayuFPFnUxa3g9JjZwh8kca2XGBR7fP8dP8zEKAmsjnsPRsWkcPZ8kTjM8IGdd8wNrKItKAwKIirKIbdK3R7cXfWDEcekYK5IRP5gP4ePMhPKePgJu(JupnCBdcW5vLOZt4w4WXWNAsa0VP3Us6Nb2kpORwqxQuYcvc6hsBqamQV0Vg3lGBJ(xta568G42ci1GdsBqamKAmsPRsWkcPZ8kTjM8IGdd8wNr630Bxj9ZaBLhSKfyG2MOlvQ5Psq)qAdcGr9L(14EbCB0VUkbRiKoZR0MyYlcomWBDgPFtVDL0pdUTaOlvQzPsq)qAdcGr9L(14EbCB0V0iL0ifdgiVx3fIlG78eiuKjZr6HuJrkDvcwriDMxPnXKxeCyG36mIuCIuZIusIuejIumyG8EDxiUaUZtGqrMmxCnn3ifNi18iLKi1yKsxLGvesNH5Nc1nSYHadmMdd8wNrKItKAw630Bxj9h1fj(aH4IBUb6sLswPsq)qAdcGr9L(14EbCB0V0iL0ifdgiVx3fIlG78eiuKjZr6HuJrkDvcwriDMxPnXKxeCyG36mIuCIuZIusIuejIumyG8EDxiUaUZtGqrMmxCnn3ifNi18iLKi1yKsxLGvesNH5Nc1nSYHadmMdd8wNrKItKAw630Bxj9RfgHopHOCJveI0LkfhIkb9dPniag1x6xJ7fWTr)yYS1bVIaGDm426Erk)qQr4isngP8hPEA42geGZRkrNNWTWHJHp1KaOFtVDL0pdSvEqxTGUuP4WujOFiTbbWO(s)ACVaUn6xAKsAKsAKsAKIbdK3R7cXfWDEcekYK5IRP5gP8dPMhPgJu(JudK3RJmLxIPWfdPSNCKEiLKifrIifdgiVx3fIlG78eiuKjZfxtZns5hsjliLKi1yKsxLGvesN5vAtm5fbhg4ToJiLFiLSGusIuejIumyG8EDxiUaUZtGqrMmxCnn3iLFiLpiLKi1yKsxLGvesNH5Nc1nSYHadmMdd8wNrKItKAw630Bxj9FH4c4opH4IBUb6sLAMOsq)qAdcGr9L(14EbCB0V)i1td32GaCEvj68eUfoCm8PMea9B6TRK(zGTYd6Qf0LU0pdUgPyPsqLYhQe0VP3Us6NVtw4Ibq2a9dPniag1x6sLAeQe0pK2GayuFP)YJ(JWs)ME7kP)NgUTbbq)pnbjq)6QeSIq6IK88vgog(utcWHbERZis5hsnlsngPwta56IK88vgog(utcWbPniag9)0WH04b63RkrNNWTWHJHp1KaOlvkzHkb9dPniag1x6xJ7fWTr)yYS1bVIaGDm426ErkorkzDwKAmsjnsPRsWkcPlsYZxz4y4tnjahg4ToJifrIiL)i1AcixxKKNVYWXWNAsaoiTbbWqkjrQXifMmbhdUTUxKIZxKAw630Bxj9ByTLqylmgYLUuPMNkb9dPniag1x6xJ7fWTr)EW6og(utcWz6TFcifrIiL)i1AcixxKKNVYWXWNAsaoiTbbWOFtVDL0)GOkw4sINOlvQzPsq)qAdcGr9L(14EbCB0VhSUJHp1KaCME7NasrKis5psTMaY1fj55RmCm8PMeGdsBqam630Bxj9pa4iG5UZdDPsjRujOFtVDL0pzec9c8r6hsBqamQV0LkfhIkb9dPniag1x630Bxj9JnEVopbJ3t0ljdcN(yplXgG80jq)ACVaUn6xAKsAKAnbKRJmLxIPWfdPSNCqAdcGHuejIuMSbCVGJ3oKXqDdRCiWaJ5G0geadPKePgJusJu6QeSIq6mm)uOUHvoeyGXCyG36mIuC(IuZpchrkIerkDvcwriDMxPnXKxeCyG36mIusIusIuejIuyRzb4jKRZySORtKYpKAw6pnEG(XgVxNNGX7j6LKbHtFSNLydqE6eOlvkomvc6hsBqamQV0VP3Us6hB8EDEcgVNOxsgeo9XEwIna5PtG(14EbCB0VUkbRiKoZR0MyYlcomWBDgrk)qQrqkIerQ1eqUodZpfQByLdbMXNaZbPniagsrKisHTMfGNqUoJXIUork)qQzP)04b6hB8EDEcgVNOxsgeo9XEwIna5PtGUuPMjQe0pK2GayuFPFtVDL0)W0PsimaqWe8wAA6xJ7fWTr)6QeSIq6IK88vgog(utcWHbERZisXjsjRCePiseP8hPwta56IK88vgog(utcWbPniagsngP2MhqkorQr4isrKis5psbZiz75bmh24968emEprVKmiC6J9SeBaYtNa9Ngpq)dtNkHWaabtWBPPPlvkF4ivc6hsBqamQV0VP3Us6FMbIb5fbbGPFnUxa3g97bR7y4tnjaNP3(jGuejIu(JuRjGCDrsE(kdhdFQjb4G0geadPgJuBZdifNi1iCePiseP8hPGzKS98aMdB8EDEcgVNOxsgeo9XEwIna5PtG(tJhO)zgigKxeeaMUuP8XhQe0pK2GayuFPFtVDL0)XeG2ecahddGXn9RX9c42OFpyDhdFQjb4m92pbKIirKYFKAnbKRlsYZxz4y4tnjahK2Gayi1yKABEaP4ePgHJifrIiL)ifmJKTNhWCyJ3RZtW49e9sYGWPp2ZsSbipDc0FA8a9FmbOnHaWXWayCtxQu(mcvc6hsBqamQV0VP3Us6)GR8edE4M3ebSDa6xJ7fWTr)(JuWms2EEaZHnEVopbJ3t0ljdcN(yplXgG80jGuJrkPrQbY71rMYlXu4IHu2tomWBDgrkIerkPrkmzciLFViLSGuJrk)rQ1eqUoYuEjMcxmKYEYbPniagsjjsjj9Ngpq)hCLNyWd38MiGTdqxQu(ilujOFiTbbWO(s)ME7kP)dUYtm4HBEteW2bOFnUxa3g9dZiz75bmh24968emEprVKmiC6J9SeBaYtNasngP0vjyfH0zEL2etErWHbERZisXjsnchP)04b6)GR8edE4M3ebSDa6sLYN5Psq)qAdcGr9L(14EbCB0VUkbRiKodZpfQByLdbgymhgm2esrKis5bR7y4tnjaNP3(jGuejIudK3RJmLxIPWfdPSNCKE0VP3Us63R2Us6sLYNzPsq)qAdcGr9L(n92vs)f5oGbJB6xJ7fWTr)SADpBmPaYn4jSdj4WaV1zeP87fPoAg9RN0ciSg(aBKkLp0LkLpYkvc6hsBqamQV0VP3Us6xBcrW0Bxzq0XL(fDCdPXd0VUkbRiKr6sLYhoevc6hsBqamQV0Vg3lGBJ(n92pHaKaFdrKIZxKAe630Bxj9JjZGP3UYGOJl9l64gsJhOFRa6sLYhomvc6hsBqamQV0VP3Us6xBcrW0Bxzq0XL(fDCdPXd0)bsa3A6sx63dd6IFWwQeuP8Hkb9dPniag1x6sLAeQe0pK2GayuFPlvkzHkb9dPniag1x6sLAEQe0pK2GayuFPlvQzPsq)ME7kPFVA7kPFiTbbWO(sxQuYkvc630Bxj9JTocbgym6hsBqamQV0LkfhIkb9dPniag1x6NbcBI(hH(n92vs)gMFku3WkhcmWy0LU0VUkbRiKrQeuP8Hkb9B6TRK(nm)uOUHvoeyGXOFiTbbWO(sxQuJqLG(H0geaJ6l9RX9c42OFgmqEVUlexa35jqOitMlUMMBKIZxKAE630Bxj9BEL2etErGUuPKfQe0pK2GayuFPFnUxa3g97psHTMfGNqUoJXIoyM3XnIuejIuyRzb4jKRZySORtKItKYNzPFtVDL0pZWChwSLXBH5TTRKUuPMNkb9dPniag1x6xJ7fWTr)yYS1bVIaGDm426Erk)qkFMN(n92vs)rsE(kdhdFQjbqxQuZsLG(H0geaJ6l9RX9c42OFgmqEVUlexa35jqOitMlUMMBKYpKAEKAms5psjnsbZiz75bmh24968emEprVKmiC6J9SeBaYtNasrKiszYgW9coE7qgd1nSYHadmMdsBqamKss630Bxj9tMYlXu4IHu2t0LkLSsLG(H0geaJ6l9RX9c42OFDvcwriDMxPnXKxeCyG36mIu(9IuJGuJrkPrkygjBppG5WgVxNNGX7j6LKbHtFSNLydqE6eqkIerkt2aUxWXBhYyOUHvoeyGXCqAdcGHuss)ME7kPFYuEjMcxmKYEIUuP4qujOFiTbbWO(s)ACVaUn630B)ecqc8nerkoFrQrqQXiL0iL0iLUkbRiKogyR8GLSad02Kdd8wNrKYVxK6Ozi1yKYFKAnbKRJb3waoiTbbWqkjrkIerkPrkDvcwriDm42cWHbERZis53lsD0mKAmsTMaY1XGBlahK2GayiLKiLK0VP3Us6NmLxIPWfdPSNOlvkomvc6hsBqamQV0Vg3lGBJ(xdFG1Tnpe2kWAaP8dP4Wi1yKAn8bw328qyRaRbKItKAE630Bxj9hlsradMhGPlvQzIkb9dPniag1x6xJ7fWTr)sJu(JuyRzb4jKRZySOdM5DCJifrIif2AwaEc56mgl66eP4ePgHJiLKi1yKctMas53lsjns5dsnNi1a596it5LykCXqk7jhPhsjj9B6TRK(JfPiGbZdW0LkLpCKkb9B6TRK(jt5Lykmi6J8L(H0geaJ6lDPl9BfqLGkLpujOFiTbbWO(s)ACVaUn6xxLGvesN5vAtm5fbhg4ToJ0VP3Us6Nb2kpyjlWaTnrxQuJqLG(n92vs)m42cG(H0geaJ6lDPsjlujOFiTbbWO(s)ACVaUn6Nb2kpyjlWaTn52wZDNhKAmsjnsz6TFcbwTUlexa35jqOitgs9IuCePgJuyYeqk)qQrqkIerkmzciLFiLpiLKi1yKYFK6PHBBqaoVQeDEc3chog(utcG(n92vs)GxZa(wtxQuZtLG(H0geaJ6l9RX9c42OFgyR8GLSad02KBBn3DEqQXifMmbKYpKAeKAms5ps90WTniaNxvIopHBHdhdFQjbq)ME7kPFgyR8GUAbDPsnlvc6hsBqamQV0Vg3lGBJ(zGTYdwYcmqBtUT1C35bPgJu6QeSIq6mVsBIjVi4WaV1zK(n92vs)rDrIpqiU4MBGUuPKvQe0pK2GayuFPFnUxa3g9ZaBLhSKfyG2MCBR5UZdsngP0vjyfH0zEL2etErWHbERZi9B6TRK(1cJqNNquUXkcr6sLIdrLG(H0geaJ6l9RX9c42OF)rQNgUTbb48Qs05jClC4y4tnja630Bxj9dEnd4BnDPsXHPsq)qAdcGr9L(n92vs)xiUaUZtiU4MBG(14EbCB0pdgiVx3fIlG78eiuKjZfxtZns53ls5dsngP0vjyfH0XaBLhSKfyG2MCyG36ms)6jTacRHpWgPs5dDPsntujOFiTbbWO(s)ACVaUn6FnbKRBGeh3opHyHHOdsBqamKAmsf9aHiSg(aB0nqIJBNNqSWqeP48fPgbPgJumyG8EDxiUaUZtGqrMmxCnn3iLFViLp0VP3Us6)cXfWDEcXf3Cd0LkLpCKkb9dPniag1x6xJ7fWTr)dK3RlsYyqgyvX7WGPxKAmsHjtWXGBR7fP48fPMN(n92vs)mWw5bD1c6sLYhFOsq)qAdcGr9L(14EbCB0)a596IKmgKbwv8omy6fPgJu(JupnCBdcW5vLOZt4w4WXWNAsaifrIiLhSUJHp1KaCME7Na9B6TRK(zGTYd6Qf0LkLpJqLG(H0geaJ6l9RX9c42OFmz26GxraWogCBDViLFiLpZJuJrkPrkDvcwriDMxPnXKxeCyG36mIuCIuZIuejIumyG8EDxiUaUZtGqrMmxCnn3ifNi18iLKi1yKYFK6PHBBqaoVQeDEc3chog(utcG(n92vs)mWw5bD1c6sLYhzHkb9dPniag1x6xJ7fWTr)sJu6QeSIq6yGTYdwYcmqBtomWBDgrkorQzcPisePyWa596UqCbCNNaHImzU4AAUrQxKswrkjrQXiL0iL0ifdgiVx3fIlG78eiuKjZr6HuJrkDvcwriDMxPnXKxeCyG36mIuCIuZIusIuejIumyG8EDxiUaUZtGqrMmxCnn3ifNi18iLKi1yKsxLGvesNH5Nc1nSYHadmMdd8wNrKItKAw630Bxj9h1fj(aH4IBUb6sLYN5Psq)qAdcGr9L(14EbCB0V0iLUkbRiKogyR8GLSad02Kdd8wNrKItKAMqkIerkgmqEVUlexa35jqOitMlUMMBK6fPKvKssKAmsjnsjnsXGbY71DH4c4opbcfzYCKEi1yKsxLGvesN5vAtm5fbhg4ToJifNi1SiLKifrIifdgiVx3fIlG78eiuKjZfxtZnsXjsnpsjjsngP0vjyfH0zy(PqDdRCiWaJ5WaV1zeP4ePML(n92vs)AHrOZtik3yfHiDPs5ZSujOFiTbbWO(s)ACVaUn6htMTo4veaSJb3w3ls5hsnchrQXiL)i1td32GaCEvj68eUfoCm8PMea9B6TRK(zGTYd6Qf0LkLpYkvc6hsBqamQV0Vg3lGBJ(LgPKgPKgPKgPyWa596UqCbCNNaHImzU4AAUrk)qQ5rQXiL)i1a596it5LykCXqk7jhPhsjjsrKisXGbY71DH4c4opbcfzYCX10CJu(HuYcsjjsngP0vjyfH0zEL2etErWHbERZis5hsjliLKifrIifdgiVx3fIlG78eiuKjZfxtZns5hs5dsjjsngP0vjyfH0zy(PqDdRCiWaJ5WaV1zeP4ePML(n92vs)xiUaUZtiU4MBGUuP8HdrLG(H0geaJ6l9RX9c42OF)rQNgUTbb48Qs05jClC4y4tnja630Bxj9ZaBLh0vlOlDPl9)eWXUsQuJWrFMjoolhhXnIpJ4d9tWWzNNi9ZbG3RWlWqQzrktVDLiLOJB0HEq)E462cG(NlsnZMYlXesndeSvosndk7J8f9yUiL8D9IZqU460RCYbNU45k28KcB7k1y7UCfBEnxOhZfP4GSjKAezqQr4OpZesnNi1iCCgochrpqpMlsnhKB5bIZq0J5IuZjsnhzmGHuCqDYqkoqmaYgCOhZfPMtKAou5taVadPwdFGn0xKsxjR3UYisTfsHHdPWWiLUswVDLrh6XCrQ5eP(fpGuL328TSTTRePQlsXbcXfWdI(iFrQorQ54maoyh6b6XCrko4zoOjxGHudWTWasPl(bBrQb40z0HuZrTg82isLvoNYnm)LuGuME7kJivLIjh6HP3UYOZdd6IFW23RWICJEy6TRm68WGU4hSD0xUUvXqpm92vgDEyqx8d2o6lxg5HhY12Us0J5Iu)08IYRfPWwZqQbY7fyivCTnIudWTWasPl(bBrQb40zePSKHuEyyo9QD78GuDePyvco0dtVDLrNhg0f)GTJ(YvmnVO8AdX12i6HP3UYOZdd6IFW2rF5YR2Us0dtVDLrNhg0f)GTJ(Yf26ieyGXqpm92vgDEyqx8d2o6lxgMFku3WkhcmWyYWaHn9oc6b6XCrko4zoOjxGHuWtapHuBZdi1khqktVfgP6iszpTwydcWHEy6TRm(Y3jlCXaiBa9W0BxzC0xUEA42geGmPXdVEvj68eUfoCm8PMeGmpnbj8QRsWkcPlsYZxz4y4tnjahg4ToJ(n741eqUUijpFLHJHp1KaCqAdcGHEmxKAgSPBteLbP4aSaFugKYsgsvRCaJu1rZIOhME7kJJ(YLH1wcHTWyixz67lMmBDWRiayhdUTUxoL1zhlTUkbRiKUijpFLHJHp1KaCyG36msKO)RjGCDrsE(kdhdFQjb4G0geatYXyYeCm426E58Dw0dtVDLXrF5AquflCjXtY03xpyDhdFQjb4m92pbIe9FnbKRlsYZxz4y4tnjahK2GayOhME7kJJ(Y1aGJaM7opY03xpyDhdFQjb4m92pbIe9FnbKRlsYZxz4y4tnjahK2GayOhZfPMdKXT4rQf3j3WgrkYODa0dtVDLXrF5ImcHEb(i6HP3UY4OVCrgHqVaVmPXdVyJ3RZtW49e9sYGWPp2ZsSbipDcY03xPLEnbKRJmLxIPWfdPSNCqAdcGrKOjBa3l44Tdzmu3WkhcmWyoiTbbWKCS06QeSIq6mm)uOUHvoeyGXCyG36mY578JWrIe1vjyfH0zEL2etErWHbERZOKssKi2AwaEc56mgl660Vzrpm92vgh9LlYie6f4LjnE4fB8EDEcgVNOxsgeo9XEwIna5PtqM((QRsWkcPZ8kTjM8IGdd8wNr)gHiX1eqUodZpfQByLdbMXNaZbPniagrIyRzb4jKRZySORt)Mf9W0BxzC0xUiJqOxGxM04H3HPtLqyaGGj4T00Y03xDvcwriDrsE(kdhdFQjb4WaV1zKtzLJej6)AcixxKKNVYWXWNAsaoiTbbWgVnpW5iCKir)HzKS98aMdB8EDEcgVNOxsgeo9XEwIna5Pta9W0BxzC0xUiJqOxGxM04H3zgigKxeeawM((6bR7y4tnjaNP3(jqKO)RjGCDrsE(kdhdFQjb4G0geaB828aNJWrIe9hMrY2ZdyoSX715jy8EIEjzq40h7zj2aKNob0dtVDLXrF5ImcHEbEzsJhEpMa0Mqa4yyamULPVVEW6og(utcWz6TFcej6)AcixxKKNVYWXWNAsaoiTbbWgVnpW5iCKir)HzKS98aMdB8EDEcgVNOxsgeo9XEwIna5Pta9W0BxzC0xUiJqOxGxM04H3dUYtm4HBEteW2bKPVV(dZiz75bmh24968emEprVKmiC6J9SeBaYtNWyPhiVxhzkVetHlgszp5WaV1zKirPXKj43RSm2)1eqUoYuEjMcxmKYEYbPniaMKsIEy6TRmo6lxKri0lWltA8W7bx5jg8WnVjcy7aY03xygjBppG5WgVxNNGX7j6LKbHtFSNLydqE6egRRsWkcPZ8kTjM8IGdd8wNrohHJOhME7kJJ(YLxTDLY03xDvcwriDgMFku3WkhcmWyomySjIe9G1Dm8PMeGZ0B)eisCG8EDKP8smfUyiL9KJ0d9yUifhK15AD25bP4aQXKcixKIdyHDibKQJiLHuE4UW9oHEy6TRmo6lxf5oGbJBz0tAbewdFGn(6Jm99LvR7zJjfqUbpHDibhg4ToJ(9E0m0dtVDLXrF5sBcrW0Bxzq0XvM04HxDvcwriJOhME7kJJ(YfMmdME7kdIoUYKgp8AfitFFn92pHaKaFdroFhb9W0BxzC0xU0Mqem92vgeDCLjnE49ajGBn6b6XCrQ5yXbJu4ATTRe9W0Bxz0zf8YaBLhSKfyG2MKPVV6QeSIq6mVsBIjVi4WaV1ze9W0Bxz0zfm6lxm42ca9W0Bxz0zfm6lxGxZa(wltFFzGTYdwYcmqBtUT1C35zS0ME7NqGvR7cXfWDEcekYK9YXXyYe8BeIeXKj4Npso2)NgUTbb48Qs05jClC4y4tnja0dtVDLrNvWOVCXaBLh0vlKPVVmWw5blzbgOTj32AU78mgtMGFJm2)NgUTbb48Qs05jClC4y4tnja0dtVDLrNvWOVCf1fj(aH4IBUbz67ldSvEWswGbABYTTM7opJ1vjyfH0zEL2etErWHbERZi6HP3UYOZky0xU0cJqNNquUXkcrz67ldSvEWswGbABYTTM7opJ1vjyfH0zEL2etErWHbERZi6HP3UYOZky0xUaVMb8TwM((6)td32GaCEvj68eUfoCm8PMea6HP3UYOZky0xUUqCbCNNqCXn3Gm6jTacRHpWgF9rM((YGbY71DH4c4opbcfzYCX10C73RpJ1vjyfH0XaBLhSKfyG2MCyG36mIEy6TRm6Scg9LRlexa35jexCZnitFFxta56giXXTZtiwyi6G0geaBC0deIWA4dSr3ajoUDEcXcdroFhzmdgiVx3fIlG78eiuKjZfxtZTFV(GEy6TRm6Scg9LlgyR8GUAHm99DG8EDrsgdYaRkEhgm9ogtMGJb3w3lNVZJEy6TRm6Scg9LlgyR8GUAHm99DG8EDrsgdYaRkEhgm9o2)NgUTbb48Qs05jClC4y4tnjaIe9G1Dm8PMeGZ0B)eqpm92vgDwbJ(YfdSvEqxTqM((IjZwh8kca2XGBR71pFMFS06QeSIq6mVsBIjVi4WaV1zKZzjsKbdK3R7cXfWDEcekYK5IRP5MZ5LCS)pnCBdcW5vLOZt4w4WXWNAsaOhME7kJoRGrF5kQls8bcXf3CdY03xP1vjyfH0XaBLhSKfyG2MCyG36mY5mrKidgiVx3fIlG78eiuKjZfxtZ9RSk5yPLMbdK3R7cXfWDEcekYK5i9gRRsWkcPZ8kTjM8IGdd8wNroNvsIezWa596UqCbCNNaHImzU4AAU5CEjhRRsWkcPZW8tH6gw5qGbgZHbERZiNZIEy6TRm6Scg9LlTWi05jeLBSIquM((kTUkbRiKogyR8GLSad02Kdd8wNroNjIezWa596UqCbCNNaHImzU4AAUFLvjhlT0myG8EDxiUaUZtGqrMmhP3yDvcwriDMxPnXKxeCyG36mY5SssKidgiVx3fIlG78eiuKjZfxtZnNZl5yDvcwriDgMFku3WkhcmWyomWBDg5Cw0dtVDLrNvWOVCXaBLh0vlKPVVyYS1bVIaGDm426E9Beoo2)NgUTbb48Qs05jClC4y4tnja0J5IusbadP2cPUqCbmsrqElaKIG1BNhKsoGbNZHuifhyFiXas1lsvKR)(7p6HP3UYOZky0xUUqCbCNNqCXn3Gm99vAPLwAgmqEVUlexa35jqOitMlUMMB)MFS)dK3RJmLxIPWfdPSNCKEssKidgiVx3fIlG78eiuKjZfxtZTFYIKJ1vjyfH0zEL2etErWHbERZOFYIKejYGbY71DH4c4opbcfzYCX10C7NpsowxLGvesNH5Nc1nSYHadmMdd8wNroNf9W0Bxz0zfm6lxmWw5bD1cz67R)pnCBdcW5vLOZt4w4WXWNAsaOhOhME7kJoDvcwriJVgMFku3WkhcmWyOhME7kJoDvcwriJJ(YL5vAtm5fbz67ldgiVx3fIlG78eiuKjZfxtZnNVZJEy6TRm60vjyfHmo6lxmdZDyXwgVfM32Usz67R)yRzb4jKRZySOdM5DCJejITMfGNqUoJXIUo50Nzrpm92vgD6QeSIqgh9LRijpFLHJHp1KaKPVVyYS1bVIaGDm426E9ZN5rpm92vgD6QeSIqgh9LlYuEjMcxmKYEsM((YGbY71DH4c4opbcfzYCX10C738J9xAygjBppG5WgVxNNGX7j6LKbHtFSNLydqE6eis0KnG7fC82HmgQByLdbgymhK2GaysIEy6TRm60vjyfHmo6lxKP8smfUyiL9Km99vxLGvesN5vAtm5fbhg4ToJ(9oYyPHzKS98aMdB8EDEcgVNOxsgeo9XEwIna5PtGirt2aUxWXBhYyOUHvoeyGXCqAdcGjj6HP3UYOtxLGveY4OVCrMYlXu4IHu2tY03xtV9tiajW3qKZ3rglT06QeSIq6yGTYdwYcmqBtomWBDg979OzJ9FnbKRJb3waoiTbbWKKirP1vjyfH0XGBlahg4ToJ(9E0SXRjGCDm42cWbPniaMKsIEy6TRm60vjyfHmo6lxXIueWG5byz677A4dSUT5HWwbwd(XHhVg(aRBBEiSvG1aNZJEy6TRm60vjyfHmo6lxXIueWG5byz67R0(JTMfGNqUoJXIoyM3XnsKi2AwaEc56mgl66KZr4OKJXKj43R0(mNdK3RJmLxIPWfdPSNCKEsIEy6TRm60vjyfHmo6lxKP8smfge9r(IEGEy6TRm6oqc4w)YaBLh0vlKPVVdK3RlsYyqgyvX7WGP3X()0WTniaNxvIopHBHdhdFQjbqKOhSUJHp1KaCME7Na6HP3UYO7ajGB9OVCXaBLh0vlKPVVyYS1bVIaGDm426E9ZN5hlTUkbRiKoZR0MyYlcomWBDg5CwIezWa596UqCbCNNaHImzU4AAU5CEjh7)td32GaCEvj68eUfoCm8PMea6HP3UYO7ajGB9OVCXaBLhSKfyG2MKPVVRjGCDEqCBbKAWbPnia2yDvcwriDMxPnXKxeCyG36mIEy6TRm6oqc4wp6lxm42cqM((QRsWkcPZ8kTjM8IGdd8wNr0dtVDLr3bsa36rF5kQls8bcXf3CdY03xPLMbdK3R7cXfWDEcekYK5i9gRRsWkcPZ8kTjM8IGdd8wNroNvsIezWa596UqCbCNNaHImzU4AAU5CEjhRRsWkcPZW8tH6gw5qGbgZHbERZiNZIEy6TRm6oqc4wp6lxAHrOZtik3yfHOm99vAPzWa596UqCbCNNaHImzosVX6QeSIq6mVsBIjVi4WaV1zKZzLKirgmqEVUlexa35jqOitMlUMMBoNxYX6QeSIq6mm)uOUHvoeyGXCyG36mY5SOhME7kJUdKaU1J(YfdSvEqxTqM((IjZwh8kca2XGBR71Vr44y)FA42geGZRkrNNWTWHJHp1Kaqpm92vgDhibCRh9LRlexa35jexCZnitFFLwAPLMbdK3R7cXfWDEcekYK5IRP52V5h7)a596it5LykCXqk7jhPNKejYGbY71DH4c4opbcfzYCX10C7NSi5yDvcwriDMxPnXKxeCyG36m6NSijrImyG8EDxiUaUZtGqrMmxCnn3(5JKJ1vjyfH0zy(PqDdRCiWaJ5WaV1zKZzrpm92vgDhibCRh9LlgyR8GUAHm991)NgUTbb48Qs05jClC4y4tnja63ix5fM()npPW2UY5a2UlDPlLc]] )

end
