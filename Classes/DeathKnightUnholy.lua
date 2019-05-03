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

            cycle = function () if dot.festering_wound.stack >= 2 and active_dot.festering_wound < active_enemies then return "festering_wound" end end,
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


    spec:RegisterPack( "Unholy", 20190502.2121, [[dGuK4aqiQQ6rkQ0MuOgfvLofvvELcXSirULIIAxu5xOcddj0XirTmQIEMIQmnKGRPO02uuKVPOqnoff05uiL1PqIMhvf3tv1(qIoOIcSqQcpuHu1evuvLlQOQ0gvibNurvHvQQ4LkKqUPIQk7Ke6NkQQQHQOQOwQcjupvLMkQORQqQ0wvuvK9c5VcgmPomLfRGht0Kr5YGnRkFwfJMQ0PLSAfsfVMemBc3gvTBP(TOHtshxHKwoINl00v66i12vv67iPXROqoVISEfvmFuP9d1iLrCIUmBbKIEsrLhnkolf905PYZBEkptO7oPcORQjvWoa62gpGUJUT3umHUQ2KingIt0nM0ejGUZfR9URACuYbhNA9sp4KjphXINwyBLTKyVLJyXl5aDhOlXoF0Ob0LzlGu0tkQ8OrXzPONopvEEZt5zr3Okirk65SEIUElgdA0a6YGOeDNlwp62EtXewp)b26fRhf11X7I)mxS27UQXrjhCCQ1l9GtM8CelEAHTv2sI9woIfVKd8N5I1ZpBcR9ujS2tkQ8OH1Zmw7PYJspvg)b)zUy9O3R1hiokXFMlwpZy9mGXagwp)QMH1JceaMd4WFMlwpZy9Op7VazbgwVg5aBOEyTmBwTv2rSEtSMahAHrWAz2SARSJo8N5I1ZmwFtEaRt1T4R5yBLnwNpSEuaIlqge1X7I1vJ1ZG5)5RdDfvCJior3d0aPKiorkQmIt0fABqamKhORKulqkdDhOFpxKMXGoWYK3ratUy9yS2FS(RrkBqao1mfvFcVKeog5KtcaR5YfRvH1DmYjNeGZKB9fqxtUv2OldS1BqMLaTif9eXj6cTniagYd0vsQfiLHUe6UKb1KkqCm4vYAXAFWALPawpgR9fRLzkyj12zQP0etQrWraER6iwtjwplwZLlwZGb63Z9G4cKQpbQjDZCX1KkG1uI1uaR9dRhJ1(J1FnszdcWPMPO6t4LKWXiNCsaORj3kB0Lb26niZsGwKIZdXj6cTniagYd0vsQfiLHURjGEDQqClb0sWbTniagwpgRLzkyj12zQP0etQrWraER6i6AYTYgDzGTEdwZcmqAtOfPifqCIUqBdcGH8aDLKAbszORmtblP2otnLMysncocWBvhrxtUv2OldELaqlsXzrCIUqBdcGH8aDLKAbszORVyTVyndgOFp3dIlqQ(eOM0nZrRI1JXAzMcwsTDMAknXKAeCeG3QoI1uI1ZI1(H1C5I1myG(9CpiUaP6tGAs3mxCnPcynLynfWA)W6XyTmtblP2oJWpfYxy9cbgymhb4TQJynLy9SORj3kB0nktAYbcXLukaOfP4mH4eDH2gead5b6kj1cKYqxFXAFXAgmq)EUhexGu9jqnPBMJwfRhJ1YmfSKA7m1uAIj1i4iaVvDeRPeRNfR9dR5YfRzWa975EqCbs1Na1KUzU4AsfWAkXAkG1(H1JXAzMcwsTDgHFkKVW6fcmWyocWBvhXAkX6zrxtUv2ORuyuR(eIEnwsnIwKIZyeNOl02GayipqxjPwGug6sO7sgutQaXXGxjRfR9bR9KIy9yS2FS(RrkBqao1mfvFcVKeog5KtcaDn5wzJUmWwVbzwc0IuCgI4eDH2gead5b6kj1cKYqxFXAFXAFXAFXAgmq)EUhexGu9jqnPBMlUMubS2hSMcy9yS2FSEG(9C0T3umfEeONZKJwfR9dR5YfRzWa975EqCbs1Na1KUzU4AsfWAFW65H1(H1JXAzMcwsTDMAknXKAeCeG3QoI1(G1ZdR9dR5YfRzWa975EqCbs1Na1KUzU4AsfWAFWALXA)W6XyTmtblP2oJWpfYxy9cbgymhb4TQJynLy9SORj3kB09bXfivFcXLukaOfP4OH4eDH2gead5b6kj1cKYqx)X6VgPSbb4uZuu9j8ss4yKtoja01KBLn6YaB9gKzjqlArxg8mAXI4ePOYiorxtUv2OlF1SWJaWCa0fABqamKhOfPONiorxOTbbWqEGUPk6gHfDn5wzJUFnszdcaD)AcAaDLzkyj12fP55ZoCmYjNeGJa8w1rS2hSEwSEmwVMa61fP55ZoCmYjNeGdABqam09RrcTXdORAMIQpHxschJCYjbGwKIZdXj6cTniagYd0vsQfiLHUe6UKb1KkqCm4vYAXAkX6zAwSEmw7lwlZuWsQTlsZZND4yKtojahb4TQJynxUyT)y9AcOxxKMNp7WXiNCsaoOTbbWWA)W6XynHUbhdELSwSMYFSEw01KBLn6AeP1qytcb6fTifPaIt0fABqamKhORKulqkdDvH1DmYjNeGZKB9fWAUCXA)X61eqVUinpF2HJro5KaCqBdcGHUMCRSr3brMSWJMmHwKIZI4eDH2gead5b6kj1cKYqxvyDhJCYjb4m5wFbSMlxS2FSEnb0RlsZZND4yKtojah02GayORj3kB0DairGOq1h0IuCMqCIUqBdcGH8aDLKAbszO7w8awtjw7jfXAUCXA)XAyuPlvvG5igVA1NGXRkQLMbHtDSVPydqFQgqxtUv2OlDec1c8r0IuCgJ4eDH2gead5b6AYTYgDjgVA1NGXRkQLMbHtDSVPydqFQgqxjPwGug6kZuWsQTZutPjMuJGJa8w1rS2hS2tSMlxSEnb0RZi8tH8fwVqGz8nWCqBdcGH1C5I1eRyb4l0RZySORAS2hSEw0TnEaDjgVA1NGXRkQLMbHtDSVPydqFQgqlsXziIt0fABqamKhORj3kB0Dy6KnegaiycERnj6kj1cKYqxzMcwsTDrAE(SdhJCYjb4iaVvDeRPeRNjkI1C5I1(J1RjGEDrAE(SdhJCYjb4G2geadRhJ1BXdynLyTNueR5YfR9hRHrLUuvbMJy8QvFcgVQOwAgeo1X(MIna9PAaDBJhq3HPt2qyaGGj4T2KOfP4OH4eDH2gead5b6AYTYgDhDGyWBsvae0vsQfiLHUQW6og5KtcWzYT(cynxUyT)y9AcOxxKMNp7WXiNCsaoOTbbWW6Xy9w8awtjw7jfXAUCXA)XAyuPlvvG5igVA1NGXRkQLMbHtDSVPydqFQgq324b0D0bIbVjvbqqlsrLPiIt0fABqamKhORj3kB09ycqAcbqIHbWuaDLKAbszORkSUJro5KaCMCRVawZLlw7pwVMa61fP55ZoCmYjNeGdABqamSEmwVfpG1uI1EsrSMlxS2FSggv6svfyoIXRw9jy8QIAPzq4uh7Bk2a0NQb0TnEaDpMaKMqaKyyamfqlsrLvgXj6cTniagYd01KBLn6EizFIbvsXBIaXoa6kj1cKYqxcDdyTp)y98W6XyTVy9w8awtjw7jfXAUCXA)XAyuPlvvG5igVA1NGXRkQLMbHtDSVPydqFQgWA)q324b09qY(edQKI3ebIDa0IuuzprCIUqBdcGH8aDLKAbszORmtblP2oJWpfYxy9cbgymhbm2ewZLlwRcR7yKtojaNj36lG1C5I1d0VNJU9MIPWJa9CMC0QORj3kB0vn3kB0Iuu55H4eDH2gead5b6AYTYgDt6DGaMcORKulqkdDz56(weAb0BqvyhAWraER6iw7ZpwFKm0vojfqynYb2isrLrlsrLPaIt0fABqamKhORj3kB0vAcrWKBLDquXfDfvCdTXdORmtblP2r0Iuu5zrCIUqBdcGH8aDLKAbszORj36leGg4liI1u(J1EIUMCRSrxcDhm5wzhevCrxrf3qB8a6AjGwKIkptiorxOTbbWqEGUMCRSrxPjebtUv2brfx0vuXn0gpGUhObsjrlArxvcit(bBrCIuuzeNOl02GayipqlsrprCIUqBdcGH8aTifNhIt0fABqamKhOfPifqCIUqBdcGH8aTifNfXj6AYTYgDvZTYgDH2gead5bArkotiorxtUv2OlXQieyGXqxOTbbWqEGwKIZyeNOl02GayipqxgiSj01t01KBLn6Ae(Pq(cRxiWaJHw0IUYmfSKAhrCIuuzeNORj3kB01i8tH8fwVqGbgdDH2gead5bArk6jIt0fABqamKhORKulqkdDzWa975EqCbs1Na1KUzU4AsfWAk)XAkGUMCRSrxtnLMysncOfP48qCIUqBdcGH8aDLKAbszOR)ynXkwa(c96mgl6Gzuf3iwZLlwtSIfGVqVoJXIUQXAkXALNfDn5wzJUmJOqyjwhFjH32kB0IuKciorxOTbbWqEGUssTaPm0Lq3LmOMubIJbVswlw7dwRmfqxtUv2OBKMNp7WXiNCsaOfP4SiorxOTbbWqEGUssTaPm0Lbd0VN7bXfivFcut6M5IRjvaR9bRPawpgR9hR9fRHrLUuvbMJy8QvFcgVQOwAgeo1X(MIna9PAaR5YfRT5aKAbhVDOJH8fwVqGbgZbTniagw7h6AYTYgDPBVPyk8iqpNj0IuCMqCIUqBdcGH8aDLKAbszORmtblP2otnLMysncocWBvhXAFWApX6XyTVynmQ0LQkWCeJxT6tW4vf1sZGWPo23uSbOpvdynxUyTnhGul44TdDmKVW6fcmWyoOTbbWWA)qxtUv2OlD7nftHhb65mHwKIZyeNOl02GayipqxjPwGug6AYT(cbOb(cIynL)yTNy9yS2xS2xSwMPGLuBhdS1BWAwGbsBYraER6iw7ZpwFKmSEmw7pwVMa61XGxjah02GayyTFynxUyTVyTmtblP2og8kb4iaVvDeR95hRpsgwpgRxta96yWReGdABqamS2pS2p01KBLn6s3EtXu4rGEotOfP4meXj6cTniagYd0vsQfiLHURroW62IhcBgyfG1(G1ZqSEmwVg5aRBlEiSzGvawtjwtb01KBLn6gtArGaMkqqlsXrdXj6cTniagYd0vsQfiLHU(I1(J1eRyb4l0RZySOdMrvCJynxUynXkwa(c96mgl6QgRPeR9KIyTFy9ySMq3aw7Zpw7lwRmwpZy9a975OBVPyk8iqpNjhTkw7h6AYTYgDJjTiqatfiOfPOYueXj6AYTYgDPBVPykmiQJ3fDH2gead5bArl6AjG4ePOYiorxOTbbWqEGUssTaPm0vMPGLuBNPMstmPgbhb4TQJORj3kB0Lb26nynlWaPnHwKIEI4eDn5wzJUm4vcaDH2gead5bArkopeNOl02GayipqxjPwGug6YaB9gSMfyG0MCBjvO6dwpgR9fRn5wFHalx3dIlqQ(eOM0ndR)XAkI1JXAcDdyTpyTNynxUynHUbS2hSwzS2pSEmw7pw)1iLniaNAMIQpHxschJCYjbGUMCRSrxqTyaFjrlsrkG4eDH2gead5b6kj1cKYqxgyR3G1SadK2KBlPcvFW6XynHUbS2hS2tSEmw7pw)1iLniaNAMIQpHxschJCYjbGUMCRSrxgyR3GmlbArkolIt0fABqamKhORKulqkdDzGTEdwZcmqAtUTKku9bRhJ1YmfSKA7m1uAIj1i4iaVvDeDn5wzJUrzstoqiUKsbaTifNjeNOl02GayipqxjPwGug6YaB9gSMfyG0MCBjvO6dwpgRLzkyj12zQP0etQrWraER6i6AYTYgDLcJA1Nq0RXsQr0IuCgJ4eDH2gead5b6kj1cKYqx)X6VgPSbb4uZuu9j8ss4yKtoja01KBLn6cQfd4ljArkodrCIUqBdcGH8aDn5wzJUpiUaP6tiUKsbaDLKAbszOldgOFp3dIlqQ(eOM0nZfxtQaw7ZpwRmwpgRLzkyj12XaB9gSMfyG0MCeG3QoIUYjPacRroWgrkQmArkoAiorxOTbbWqEGUssTaPm0Dnb0RBGMe3QpHysGOdABqamSEmwhvbHiSg5aB0nqtIB1NqmjqeRP8hR9eRhJ1myG(9CpiUaP6tGAs3mxCnPcyTp)yTYORj3kB09bXfivFcXLukaOfPOYueXj6cTniagYd0vsQfiLHUd0VNlsZyqhyzY7iGjxSEmwtOBWXGxjRfRP8hRPa6AYTYgDzGTEdYSeOfPOYkJ4eDH2gead5b6kj1cKYq3b63ZfPzmOdSm5DeWKlwpgR9hR)AKYgeGtntr1NWljHJro5KaWAUCXAvyDhJCYjb4m5wFb01KBLn6YaB9gKzjqlsrL9eXj6cTniagYd0vsQfiLHUe6UKb1KkqCm4vYAXAFWALPawpgR9fRLzkyj12zQP0etQrWraER6iwtjwplwZLlwZGb63Z9G4cKQpbQjDZCX1KkG1uI1uaR9dRhJ1(J1FnszdcWPMPO6t4LKWXiNCsaORj3kB0Lb26niZsGwKIkppeNOl02GayipqxjPwGug6kZuWsQTJb26nynlWaPn5iaVvDeRPeRhnSEmw7lw7lwZGb63Z9G4cKQpbQjDZC0Qy9ySwMPGLuBNPMstmPgbhb4TQJynLy9SyTFynxUyndgOFp3dIlqQ(eOM0nZfxtQawtjwtbS2pSEmwlZuWsQTZi8tH8fwVqGbgZraER6iwtjwpl6AYTYgDJYKMCGqCjLcaArkQmfqCIUqBdcGH8aDLKAbszORmtblP2ogyR3G1SadK2KJa8w1rSMsSE0W6XyTVyTVyndgOFp3dIlqQ(eOM0nZrRI1JXAzMcwsTDMAknXKAeCeG3QoI1uI1ZI1(H1C5I1myG(9CpiUaP6tGAs3mxCnPcynLynfWA)W6XyTmtblP2oJWpfYxy9cbgymhb4TQJynLy9SORj3kB0vkmQvFcrVglPgrlsrLNfXj6cTniagYd0vsQfiLHUe6UKb1KkqCm4vYAXAFWApPiwpgR9hR)AKYgeGtntr1NWljHJro5KaqxtUv2OldS1BqMLaTifvEMqCIUqBdcGH8aDLKAbszORVyTVyTVyTVyndgOFp3dIlqQ(eOM0nZfxtQaw7dwtbSEmw7pwpq)Eo62BkMcpc0ZzYrRI1(H1C5I1myG(9CpiUaP6tGAs3mxCnPcyTpy98WA)W6XyTmtblP2otnLMysncocWBvhXAFW65H1(H1C5I1myG(9CpiUaP6tGAs3mxCnPcyTpyTYyTFy9ySwMPGLuBNr4Nc5lSEHadmMJa8w1rSMsSEw01KBLn6(G4cKQpH4skfa0Iuu5zmIt0fABqamKhORKulqkdD9hR)AKYgeGtntr1NWljHJro5KaqxtUv2OldS1BqMLaTOfTO7xGeRSrk6jfvE0O4Su0tNNu0t0LQr6Qpr0D(GxnjlWW6zXAtUv2yTOIB0H)GUg96njO7T4Pf2wzp6j2Brxvs(kbGUZfRhDBVPycRN)aB9I1JI664DXFMlw7Dx14OKdoo16LEWjtEoIfpTW2kBjXElhXIxYb(ZCX65NnH1EQew7jfvE0W6zgR9u5rPNkJ)G)mxSE0716dehL4pZfRNzSEgWyadRNFvZW6rbcaZbC4pZfRNzSE0N9xGSadRxJCGnupSwMnR2k7iwVjwtGdTWiyTmBwTv2rh(ZCX6zgRVjpG1P6w81CSTYgRZhwpkaXfidI64DX6QX6zW8)81H)G)mxSE(oJaj9cmSEaEjbWAzYpylwpaNQJoSEgiLG6gX6o7z2Rr4F0cS2KBLDeRZwm5WFm5wzhDQeqM8d2()ewub8htUv2rNkbKj)GTJ8ZXltg(Jj3k7OtLaYKFW2r(5WOp8qV2wzJ)mxS(2MA0BUynXkgwpq)EadRJRTrSEaEjbWAzYpylwpaNQJyT1mSwLaZSAUB1hSUIynlBWH)yYTYo6ujGm5hSDKFoITPg9MBiU2gXFm5wzhDQeqM8d2oYphQ5wzJ)yYTYo6ujGm5hSDKFoiwfHadmg(Jj3k7OtLaYKFW2r(5Wi8tH8fwVqGbgtjgiSPFpXFWFMlwpFNrGKEbgwdFbYewVfpG1RxaRn5MeSUIyT91kHniah(Jj3k74pF1SWJaWCa8htUv2Xr(54RrkBqak1gp8RMPO6t4LKWXiNCsak91e0WVmtblP2UinpF2HJro5KaCeG3Qo6ZSJxta96I088zhog5KtcWbTniag(ZCX6rXMSmrujSE(yb(OsyT1mSoxVabRZJKfXFm5wzhh5NdJiTgcBsiqVkvVFcDxYGAsfiog8kzTuotZo2xzMcwsTDrAE(SdhJCYjb4iaVvDKlx)xta96I088zhog5KtcWbTniaMFJj0n4yWRK1s5)S4pMCRSJJ8ZXGitw4rtMuQE)QW6og5KtcWzYT(cC56)AcOxxKMNp7WXiNCsaoOTbbWWFm5wzhh5NJbGebIcvFuQE)QW6og5KtcWzYT(cC56)AcOxxKMNp7WXiNCsaoOTbbWWFMlwp6PJBYJ1lPAfGnI10r7a4pMCRSJJ8ZbDec1c8rLQ3)w8aLEsrUC9hgv6svfyoIXRw9jy8QIAPzq4uh7Bk2a0NQb8htUv2Xr(5GocHAbELAJh(jgVA1NGXRkQLMbHtDSVPydqFQguQE)YmfSKA7m1uAIj1i4iaVvD0hp5YDnb0RZi8tH8fwVqGz8nWCqBdcGXLlXkwa(c96mgl6Q2NzXFm5wzhh5Nd6ieQf4vQnE4Fy6KnegaiycERnPs17xMPGLuBxKMNp7WXiNCsaocWBvhPCMOixU(VMa61fP55ZoCmYjNeGdABqaSXBXdu6jf5Y1FyuPlvvG5igVA1NGXRkQLMbHtDSVPydqFQgWFm5wzhh5Nd6ieQf4vQnE4F0bIbVjvbquQE)QW6og5KtcWzYT(cC56)AcOxxKMNp7WXiNCsaoOTbbWgVfpqPNuKlx)HrLUuvbMJy8QvFcgVQOwAgeo1X(MIna9PAa)XKBLDCKFoOJqOwGxP24H)JjaPjeajggatbLQ3VkSUJro5KaCMCRVaxU(VMa61fP55ZoCmYjNeGdABqaSXBXdu6jf5Y1FyuPlvvG5igVA1NGXRkQLMbHtDSVPydqFQgWFm5wzhh5Nd6ieQf4vQnE4)qY(edQKI3ebIDaLQ3pHUbF(N3yF3IhO0tkYLR)WOsxQQaZrmE1QpbJxvulndcN6yFtXgG(un4h(Jj3k74i)COMBLTs17xMPGLuBNr4Nc5lSEHadmMJagBIlxvyDhJCYjb4m5wFbUChOFphD7nftHhb65m5OvXFMlwp)SQxR6Qpy98PIqlGEX65Zc7qdyDfXAdRvjvsQDc)XKBLDCKFos6DGaMckjNKciSg5aB8xzLQ3plx33IqlGEdQc7qdocWBvh95)iz4pMCRSJJ8ZH0eIGj3k7GOIRsTXd)YmfSKAhXFm5wzhh5NdcDhm5wzhevCvQnE43sqP69BYT(cbOb(cIu(7j(Jj3k74i)CinHiyYTYoiQ4QuB8W)bAGus8h8N5I1ZGC(I1KCTTYg)XKBLD0zj8ZaB9gSMfyG0MuQE)YmfSKA7m1uAIj1i4iaVvDe)XKBLD0zjmYphm4vca)XKBLD0zjmYphGAXa(sQu9(zGTEdwZcmqAtUTKku9zSVMCRVqGLR7bXfivFcut6M9tXXe6g8XtUCj0n4JY(n2)VgPSbb4uZuu9j8ss4yKtoja8htUv2rNLWi)CWaB9gKzjuQE)mWwVbRzbgiTj3wsfQ(mMq3GpEo2)VgPSbb4uZuu9j8ss4yKtoja8htUv2rNLWi)CeLjn5aH4skfaLQ3pdS1BWAwGbsBYTLuHQpJLzkyj12zQP0etQrWraER6i(Jj3k7OZsyKFoKcJA1Nq0RXsQrLQ3pdS1BWAwGbsBYTLuHQpJLzkyj12zQP0etQrWraER6i(Jj3k7OZsyKFoa1Ib8LuP697)xJu2GaCQzkQ(eEjjCmYjNea(Jj3k7OZsyKFoEqCbs1NqCjLcGsYjPacRroWg)vwP69ZGb63Z9G4cKQpbQjDZCX1Kk4ZVYJLzkyj12XaB9gSMfyG0MCeG3QoI)yYTYo6Seg5NJhexGu9jexsPaOu9(xta96gOjXT6tiMei6G2geaBCufeIWAKdSr3anjUvFcXKark)9CmdgOFp3dIlqQ(eOM0nZfxtQGp)kJ)yYTYo6Seg5NdgyR3GmlHs17FG(9CrAgd6altEhbm5oMq3GJbVswlL)ua)XKBLD0zjmYphmWwVbzwcLQ3)a975I0mg0bwM8ocyYDS)FnszdcWPMPO6t4LKWXiNCsaC5QcR7yKtojaNj36lG)yYTYo6Seg5NdgyR3GmlHs17Nq3LmOMubIJbVswRpktHX(kZuWsQTZutPjMuJGJa8w1rkNLlxgmq)EUhexGu9jqnPBMlUMubkPGFJ9)RrkBqao1mfvFcVKeog5Ktca)XKBLD0zjmYphrzstoqiUKsbqP69lZuWsQTJb26nynlWaPn5iaVvDKYrBSV(YGb63Z9G4cKQpbQjDZC0QJLzkyj12zQP0etQrWraER6iLZ6hxUmyG(9CpiUaP6tGAs3mxCnPcusb)glZuWsQTZi8tH8fwVqGbgZraER6iLZI)yYTYo6Seg5NdPWOw9je9ASKAuP69lZuWsQTJb26nynlWaPn5iaVvDKYrBSV(YGb63Z9G4cKQpbQjDZC0QJLzkyj12zQP0etQrWraER6iLZ6hxUmyG(9CpiUaP6tGAs3mxCnPcusb)glZuWsQTZi8tH8fwVqGbgZraER6iLZI)yYTYo6Seg5NdgyR3GmlHs17Nq3LmOMubIJbVswRpEsXX()1iLniaNAMIQpHxschJCYjbG)yYTYo6Seg5NJhexGu9jexsPaOu9(91xF9Lbd0VN7bXfivFcut6M5IRjvWhkm2)b63Zr3EtXu4rGEotoAv)4YLbd0VN7bXfivFcut6M5IRjvWN553yzMcwsTDMAknXKAeCeG3Qo6Z88Jlxgmq)EUhexGu9jqnPBMlUMubFu2VXYmfSKA7mc)uiFH1leyGXCeG3Qos5S4pMCRSJolHr(5Gb26niZsOu9(9)RrkBqao1mfvFcVKeog5Ktca)b)XKBLD0jZuWsQD83i8tH8fwVqGbgd)XKBLD0jZuWsQDCKFom1uAIj1iOu9(zWa975EqCbs1Na1KUzU4AsfO8Nc4pMCRSJozMcwsTJJ8ZbZikewI1Xxs4TTYwP697pXkwa(c96mgl6Gzuf3ixUeRyb4l0RZySORAkvEw8htUv2rNmtblP2Xr(5isZZND4yKtojaLQ3pHUlzqnPcehdELSwFuMc4pMCRSJozMcwsTJJ8ZbD7nftHhb65mPu9(zWa975EqCbs1Na1KUzU4Asf8HcJ93xyuPlvvG5igVA1NGXRkQLMbHtDSVPydqFQg4Y1MdqQfC82HogYxy9cbgymh02Gay(H)yYTYo6Kzkyj1ooYph0T3umfEeONZKs17xMPGLuBNPMstmPgbhb4TQJ(45yFHrLUuvbMJy8QvFcgVQOwAgeo1X(MIna9PAGlxBoaPwWXBh6yiFH1leyGXCqBdcG5h(Jj3k7OtMPGLu74i)Cq3EtXu4rGEotkvVFtU1xianWxqKYFph7RVYmfSKA7yGTEdwZcmqAtocWBvh95)izJ9Fnb0RJbVsaoOTbbW8JlxFLzkyj12XGxjahb4TQJ(8FKSXRjGEDm4vcWbTniaMF(H)yYTYo6Kzkyj1ooYphXKweiGPceLQ3)AKdSUT4HWMbwb(mdhVg5aRBlEiSzGvaLua)XKBLD0jZuWsQDCKFoIjTiqatfikvVFF9NyflaFHEDgJfDWmQIBKlxIvSa8f61zmw0vnLEsr)gtOBWNFFvEMhOFphD7nftHhb65m5Ov9d)XKBLD0jZuWsQDCKFoOBVPykmiQJ3f)b)XKBLD0DGgiL8Nb26niZsOu9(hOFpxKMXGoWYK3ratUJ9)RrkBqao1mfvFcVKeog5KtcGlxvyDhJCYjb4m5wFb8htUv2r3bAGuYr(5Gb26niZsOu9(j0DjdQjvG4yWRK16JYuySVYmfSKA7m1uAIj1i4iaVvDKYz5YLbd0VN7bXfivFcut6M5IRjvGsk43y))AKYgeGtntr1NWljHJro5KaWFm5wzhDhObsjh5NdgyR3G1SadK2Ks17Fnb0RtfIBjGwcoOTbbWglZuWsQTZutPjMuJGJa8w1r8htUv2r3bAGuYr(5GbVsakvVFzMcwsTDMAknXKAeCeG3QoI)yYTYo6oqdKsoYphrzstoqiUKsbqP697RVmyG(9CpiUaP6tGAs3mhT6yzMcwsTDMAknXKAeCeG3Qos5S(XLldgOFp3dIlqQ(eOM0nZfxtQaLuWVXYmfSKA7mc)uiFH1leyGXCeG3Qos5S4pMCRSJUd0aPKJ8ZHuyuR(eIEnwsnQu9(91xgmq)EUhexGu9jqnPBMJwDSmtblP2otnLMysncocWBvhPCw)4YLbd0VN7bXfivFcut6M5IRjvGsk43yzMcwsTDgHFkKVW6fcmWyocWBvhPCw8htUv2r3bAGuYr(5Gb26niZsOu9(j0DjdQjvG4yWRK16JNuCS)FnszdcWPMPO6t4LKWXiNCsa4pMCRSJUd0aPKJ8ZXdIlqQ(eIlPuauQE)(6RV(YGb63Z9G4cKQpbQjDZCX1Kk4dfg7)a975OBVPyk8iqpNjhTQFC5YGb63Z9G4cKQpbQjDZCX1Kk4Z88BSmtblP2otnLMysncocWBvh9zE(XLldgOFp3dIlqQ(eOM0nZfxtQGpk73yzMcwsTDgHFkKVW6fcmWyocWBvhPCw8htUv2r3bAGuYr(5Gb26niZsOu9(9)RrkBqao1mfvFcVKeog5KtcaTOfHa]] )

end
