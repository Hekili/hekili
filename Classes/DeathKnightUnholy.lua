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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( pvptalent.necromancers_bargain.enabled and 45 or 90 ) end,
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

        potion = "superior_battle_potion_of_strength",

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


    spec:RegisterPack( "Unholy", 20190803, [[dGKpebqibQhPOOnPqnkbvNsq5vcsZIqClfLYUOQFradtG4yeQwMcPNHiX0uvY1qKABkkvFtrbghIKCoffADkkO5PqCpvv7JaDqbsAHcIhQOKAIkkbUiIKQnkqIoPIsuRur1lfib3urj0oju(Paj0qrKuQLQOe0tvLPsiDvejfBfrsj7fQ)sLbl0HPSyf8yuMmsxgSzv8zvA0c40sTAfLiVgrmBsDBIA3s(TOHtKJlqQLd55KmDLUocBxvX3ruJxrj58kY6vvQ5tq7hvJfhlk(rTfWInAqeFgdcPkiKIFuX)s8rjn(Ttsa(jzmsSlGFLjd4hPMkqQNWpjBsNgflk(PscedWVa7kPMHciWT3aedEwklGQLj022zXq2zfq1YmbWVbIwVZYfEa)O2cyXgniIpJbHufesXpQ4Fj(OJIFkjGHfBuspk(fOPuOWd4hfum8BM8iPMkqQN4XzbGTb4XGcvFdS85ZKhdSRKAgkGa3Edqm4zPSaQwMqBBNfdzNvavlZeGpFM8yqL4sOwEKueHhhniIpJ84SXJZ4m8RGWNZNptECwhWQlOMH85ZKhNnEmOsPaLhNf7IYJbLia(g885ZKhNnECwN1haTaLhxdDH11hEKLfT3olfpUjpIGlH2q8illAVDwkpF(m5XzJhFPmWJP02Y9322zXJ5Hhdkb1ci5(gy5XU4XGAqrsDp(PB1QWIIFGsbfduyrXIjowu8dkBqduCi4hd1lGAd)qef43wgCB6eNhfKhVmkpoMhrevZCsjzaXJJWJFfe8ZyBNf(jdYjAYLhNMG1uhfbMScVyXgflk(bLnObkoe8JH6fqTHFHZJSm10KC5PGTbCwrDuGztEeiBDP4XX8Osc0A3AOlSkpfSnGZkQJcmBIhfKhfNhdJhfkKhdNhzzQPj5YtHtRbpcKTUu84yEujbATBn0fwLNcNwd8OG8O48yy8OqH8y48iltnnjxEtkzMEssbEeiBDP4XX8iltnnjxEkyBaNvuhfy2KhbgDIhdd)m22zHFd6mPU842aGdkqEcVyXifSO4hu2GgO4qWpgQxa1g(XYuttYL3KsMPNKuGhbgDc)m22zHFxcdrBRC5XzFdOCdGxSyFHff)GYg0afhc(Xq9cO2WVbIZXJagjAqPCNeXapHepkuipoqCoEeWirdkL7Kig4yjrTaYRwJrcpocpkU44NX2ol8BdaoIAijkQ7KigGxSyKglk(bLnObkoe8JH6fqTHFbZJuW2aoROokWSj)2ms66IFgB7SWVtYiua1zFdOEb3ayY4fl2SJff)GYg0afhc(Xq9cO2WpAUEwwmOwKTa1D0Mm4giqLhbYwxkE8Nhdc(zSTZc)yzXGAr2cu3rBYaEXIndWIIFqzdAGIdb)yOEbuB4xW8ifSnGZkQJcmBYVnJKUU4NX2ol8tIa1NPUUUbTPw8IfJuHff)GYg0afhc(Xq9cO2WVG5rkyBaNvuhfy2KFBgjDDXpJTDw4h5ePPFGUCiqLLvmaVyXMrSO4hu2GgO4qWpgQxa1g(fmpsbBd4SI6OaZM8BZiPRl(zSTZc)qTKKgCD5usgdWlEXpkCmc9IfflM4yrXpJTDw4NCxu3bbW3a(bLnObkoe8IfBuSO4hu2GgO4qWVuc)uWIFgB7SWVpgQTbnGFFmnbGFSm10KC5veYYz5Ug6MtAWJazRlfpocpsAECmpUMgQ1RiKLZYDn0nN0GhkBqdu87JHCLjd4NuM6UUUtICxdDZjnGxSyKcwu8dkBqduCi4hd1lGAd)qevZCsjza5PWPz9YJcYJZoP5XX8y48OeS(RHU5Kg8gB7papkuipgmpUMgQ1RiKLZYDn0nN0GhkBqduEmmECmpIikWtHtZ6Lhf8Nhjn(zSTZc)meZkWTjcb1IxSyFHff)GYg0afhc(Xq9cO2Wpjy9xdDZjn4n22FaEuOqEmyECnnuRxrilNL7AOBoPbpu2GgO4NX2ol8BqNj1Diqt4flgPXIIFqzdAGIdb)yOEbuB43aX54jQaPEYDqq99KNqIhfkKhLG1Fn0nN0G3yB)b4rHc5XG5X10qTEfHSCwURHU5Kg8qzdAGIFgB7SWVbaPaejDDXlwSzhlk(bLnObkoe8JH6fqTHFBld8OG84ObHhfkKhdMhHGMOLKaQhzYsDDDMSKUxck4U91(K61b1TlGhfkKhdMhHGMOLKaQ)tR6SC5Xrb5wb4NX2ol8JqbUEbzfEXIndWIIFqzdAGIdb)m22zHFMkWhRaLdzFNihlrMg)yOEbuB4hfgiohpY(orowImTJcdeNJxTgJeECeEuC8Rmza)mvGpwbkhY(orowImnEXIrQWIIFqzdAGIdb)m22zHFMkWhRaLdzFNihlrMg)yOEbuB4x48iltnnjxEtkzMEssbEey0jECmpsHbIZXFa1cOUUoYjrr9Q1yKWJc(ZJFXJJ5rkmqCoEK9DICSezAhfgiohVAngj8OG)8O48yy8OqH84aX54jQaPEYDqq99KNqc)ktgWptf4JvGYHSVtKJLitJxSyZiwu8dkBqduCi4NX2ol87tR6SC5Xrb5wb4hd1lGAd)cNhzzQPj5YBsjZ0tskWJaJoXJJ5rkmqCo(dOwa111rojkQxTgJeEuWFE8lECmpckfumW)PvDwU84Ka0byBNLhkBqduEmmEuOqECG4C8evGup5oiO(EYtiXJcfYJsW6Vg6MtAWBST)a4xzYa(9PvDwU84OGCRa8Ift8GGff)GYg0afhc(zSTZc)qMSuxxNjlP7LGcUBFTpPEDqD7cWpgQxa1g(XYuttYL3KsMPNKuGhbYwxkECeECuEuOqECnnuR3qYtU842aGJAYfq9qzdAGYJcfYJiRPo4duR3OuLVlECeEK04xzYa(HmzPUUotws3lbfC3(AFs96G62fGxSyIlowu8dkBqduCi4NX2ol8By6Mf4gaWzAzRmg(Xq9cO2WpwMAAsU8kcz5SCxdDZjn4rGS1LIhfKhN9GWJcfYJbZJRPHA9kcz5SCxdDZjn4HYg0aLhhZJBld8OG84ObHhfkKhdMhHGMOLKaQhzYsDDDMSKUxck4U91(K61b1Tla)ktgWVHPBwGBaaNPLTYy4flM4JIff)GYg0afhc(zSTZc)MLaLlqswdi8JH6fqTHFsW6Vg6MtAWBST)a8OqH8yW84AAOwVIqwol31q3CsdEOSbnq5XX842YapkipoAq4rHc5XG5riOjAjjG6rMSuxxNjlP7LGcUBFTpPEDqD7cWVYKb8BwcuUajznGWlwmXjfSO4hu2GgO4qWpJTDw4310aZ0AaPCdGrc(Xq9cO2Wpjy9xdDZjn4n22FaEuOqEmyECnnuRxrilNL7AOBoPbpu2GgO84yECBzGhfKhhni8OqH8yW8ie0eTKeq9itwQRRZKL09sqb3TV2NuVoOUDb4xzYa(DnnWmTgqk3ayKGxSyI)fwu8dkBqduCi4NX2ol87IY6QCsOw20oKDb8JH6fqTHFiIc4Xr(5rsHhhZJHZJBld8OG84ObHhfkKhdMhHGMOLKaQhzYsDDDMSKUxck4U91(K61b1TlGhdd)ktgWVlkRRYjHAzt7q2fWlwmXjnwu8dkBqduCi4hd1lGAd)yzQPj5YBi5jxECBaWrbJ6rGrN4rHc5rjy9xdDZjn4n22FaEuOqECG4C8evGup5oiO(EYtiHFgB7SWpPC7SWlwmXNDSO4hu2GgO4qWpgQxa1g(rZ1)PreAOwNK2UeGhbYwxkECKFE8YO4NX2ol8lj2beyKGxSyIpdWIIFqzdAGIdb)m22zHFmtRDgB7SC6wT4NUvRRmza)aLckgOWlwmXjvyrXpOSbnqXHGFgB7SWpMP1oJTDwoDRw8t3Q1vMmGFSm10KCPWlwmXNrSO4hu2GgO4qWpgQxa1g(zST)aoOa5gu8OG)84O4NX2ol8druoJTDwoDRw8t3Q1vMmGFwc4fl2Obblk(bLnObkoe8ZyBNf(XmT2zSTZYPB1IF6wTUYKb87cfGAgEXl(jHawkpylwuSyIJff)m22zHFs52zHFqzdAGIdbVyXgflk(zSTZc)qwRahfmk(bLnObkoe8IfJuWIIFqzdAGIdb)ktgWp7Bvadzk3jR1LhNusgq4NX2ol8Z(wfWqMYDYAD5XjLKbeEXI9fwu8dkBqduCi4hf02e(nk(zSTZc)mK8KlpUna4OGrXlEXpwMAAsUuyrXIjowu8ZyBNf(zi5jxECBaWrbJIFqzdAGIdbVyXgflk(bLnObkoe8JH6fqTHFuyG4C8hqTaQRRJCsuuVAngj8OG)84x4NX2ol8ZKsMPNKuaEXIrkyrXpOSbnqXHGFmuVaQn8lyEezn1bFGA9gLQ8WSQvRIhfkKhrwtDWhOwVrPkFx8OG8O4Kg)m22zHFudrIBrwPojs22ol8If7lSO4hu2GgO4qWpgQxa1g(HiQM5KsYaYtHtZ6LhhHhf)l8ZyBNf(PiKLZYDn0nN0aEXIrASO4hu2GgO4qWpgQxa1g(rHbIZXFa1cOUUoYjrr9Q1yKWJJWJFXJJ5XG5XW5riOjAjjG6rMSuxxNjlP7LGcUBFTpPEDqD7c4rHc5r7Ba1l4LTlHYLh3gaCuWOEOSbnq5XWWpJTDw4hrfi1tUdcQVNWlwSzhlk(bLnObkoe8JH6fqTHFSm10KC5nPKz6jjf4rGS1LIhhHhhLhhZJHZJqqt0ssa1JmzPUUotws3lbfC3(AFs96G62fWJcfYJ23aQxWlBxcLlpUna4OGr9qzdAGYJHHFgB7SWpIkqQNCheuFpHxSyZaSO4hu2GgO4qWpgQxa1g(zST)aoOa5gu8OG)84O84yEmCEmCEKLPMMKlpfSnGZkQJcmBYJazRlfpoYppEzuECmpgmpUMgQ1tHtRbpu2GgO8yy8OqH8y48iltnnjxEkCAn4rGS1LIhh5NhVmkpoMhxtd16PWP1GhkBqduEmmEmm8ZyBNf(rubs9K7GG67j8IfJuHff)GYg0afhc(zSTZc)ujH2Hatcq4hd1lGAd)wdDH1VTm420rBGhhHhjv84yECn0fw)2YGBthTbEuqE8l8JnX0GBn0fwfwmXXlwSzelk(bLnObkoe8JH6fqTHFHZJbZJiRPo4duR3OuLhMvTAv8OqH8iYAQd(a16nkv57IhfKhhni8yy84yEeruapoYppgopkopoB84aX54jQaPEYDqq99KNqIhdd)m22zHFQKq7qGjbi8Ift8GGff)m22zHFevGup5g09nWIFqzdAGIdbV4f)SeWIIftCSO4hu2GgO4qWpgQxa1g(XYuttYL3KsMPNKuGhbYwxk8ZyBNf(rbBd4SI6OaZMWlwSrXIIFgB7SWpkCAnGFqzdAGIdbVyXifSO4hu2GgO4qWpgQxa1g(rbBd4SI6OaZM8BZiPRlpoMhrefWJJWJJYJJ5XG5XpgQTbn4LYu311DsK7AOBoPb8ZyBNf(bsnfKBgEXI9fwu8dkBqduCi4hd1lGAd)OGTbCwrDuGzt(TzK01LhhZJiIc4Xr4Xr5XX8yW84hd12Gg8szQ766ojYDn0nN0a(zSTZc)OGTbCSS14flgPXIIFqzdAGIdb)yOEbuB4hfSnGZkQJcmBYVnJKUU84yEKLPMMKlVjLmtpjPapcKTUu4NX2ol8tXsc0fCQf1Ka4fl2SJff)GYg0afhc(Xq9cO2WpkyBaNvuhfy2KFBgjDD5XX8iltnnjxEtkzMEssbEeiBDPWpJTDw4htBK766ubmAswHxSyZaSO4hu2GgO4qWpgQxa1g(fmp(XqTnObVuM6UUUtICxdDZjnGFgB7SWpqQPGCZWlwmsfwu8dkBqduCi4NX2ol87aQfqDDDQf1Ka4hd1lGAd)OWaX54pGAbuxxh5KOOE1Ams4Xr(5rX5XX8iltnnjxEkyBaNvuhfy2KhbYwxk8JnX0GBn0fwfwmXXlwSzelk(bLnObkoe8JH6fqTHFRPHA9dei1211PseO8qzdAGYJJ5rLeO1U1qxyv(bcKA766ujcu8OG)84O84yEKcdeNJ)aQfqDDDKtII6vRXiHhh5Nhfh)m22zHFhqTaQRRtTOMeaVyXepiyrXpOSbnqXHGFmuVaQn8BG4C8kckfkhntzpcm2YJJ5rerbEkCAwV8OG)84x4NX2ol8Jc2gWXYwJxSyIlowu8dkBqduCi4hd1lGAd)giohVIGsHYrZu2JaJT84yEmyE8JHABqdEPm1DDDNe5Ug6MtAGhfkKhLG1Fn0nN0G3yB)bWpJTDw4hfSnGJLTgVyXeFuSO4hu2GgO4qWpgQxa1g(HiQM5KsYaYtHtZ6LhhHhf)lECmpgopYYuttYL3KsMPNKuGhbYwxkEuqEK08OqH8ifgioh)bulG666iNef1RwJrcpkip(fpggpoMhdMh)yO2g0GxktDxx3jrURHU5KgWpJTDw4hfSnGJLTgVyXeNuWIIFqzdAGIdb)yOEbuB4xW8OscbgTRRJCsuufpoMhdNhdNhPWaX54pGAbuxxh5KOOEcjECmpYYuttYL3KsMPNKuGhbYwxkEuqEK08yy8OqH8ifgioh)bulG666iNef1RwJrcpkip(fpggpoMhzzQPj5YBi5jxECBaWrbJ6rGS1LIhfKhjn(zSTZc)uSKaDbNArnjaEXIj(xyrXpOSbnqXHGFmuVaQn8lyEujHaJ211rojkQIhhZJHZJHZJuyG4C8hqTaQRRJCsuupHepoMhzzQPj5YBsjZ0tskWJazRlfpkipsAEmmEuOqEKcdeNJ)aQfqDDDKtII6vRXiHhfKh)IhdJhhZJSm10KC5nK8KlpUna4OGr9iq26sXJcYJKg)m22zHFmTrURRtfWOjzfEXIjoPXIIFqzdAGIdb)yOEbuB4hIOAMtkjdipfonRxECeEC0GWJJ5XG5XpgQTbn4LYu311DsK7AOBoPb8ZyBNf(rbBd4yzRXlwmXNDSO4hu2GgO4qWpgQxa1g(fopgopgopgopsHbIZXFa1cOUUoYjrr9Q1yKWJJWJFXJJ5XG5XbIZXtubs9K7GG67jpHepggpkuipsHbIZXFa1cOUUoYjrr9Q1yKWJJWJKcpggpoMhzzQPj5YBsjZ0tskWJazRlfpocpsk8yy8OqH8ifgioh)bulG666iNef1RwJrcpocpkopggpoMhzzQPj5YBi5jxECBaWrbJ6rGS1LIhfKhjn(zSTZc)oGAbuxxNArnjaEXIj(malk(bLnObkoe8JH6fqTHFbZJFmuBdAWlLPURR7Ki31q3Csd4NX2ol8Jc2gWXYwJx8IFxOauZWIIftCSO4hu2GgO4qWpgQxa1g(nqCoEfbLcLJMPShbgB5XX8yW84hd12Gg8szQ766ojYDn0nN0apkuipkbR)AOBoPbVX2(dGFgB7SWpkyBahlBnEXInkwu8dkBqduCi4hd1lGAd)qevZCsjza5PWPz9YJJWJI)fpoMhdNhzzQPj5YBsjZ0tskWJazRlfpkipsAEuOqEKcdeNJ)aQfqDDDKtII6vRXiHhfKh)IhdJhhZJbZJFmuBdAWlLPURR7Ki31q3Csd4NX2ol8Jc2gWXYwJxSyKcwu8dkBqduCi4hd1lGAd)wtd16La12AOyGhkBqduECmpYYuttYL3KsMPNKuGhbYwxk8ZyBNf(rbBd4SI6OaZMWlwSVWIIFqzdAGIdb)yOEbuB4hltnnjxEtkzMEssbEeiBDPWpJTDw4hfoTgWlwmsJff)GYg0afhc(Xq9cO2WVW5XW5rkmqCo(dOwa111rojkQNqIhhZJSm10KC5nPKz6jjf4rGS1LIhfKhjnpggpkuipsHbIZXFa1cOUUoYjrr9Q1yKWJcYJFXJHXJJ5rwMAAsU8gsEYLh3gaCuWOEeiBDP4rb5rsJFgB7SWpfljqxWPwutcGxSyZowu8dkBqduCi4hd1lGAd)cNhdNhPWaX54pGAbuxxh5KOOEcjECmpYYuttYL3KsMPNKuGhbYwxkEuqEK08yy8OqH8ifgioh)bulG666iNef1RwJrcpkip(fpggpoMhzzQPj5YBi5jxECBaWrbJ6rGS1LIhfKhjn(zSTZc)yAJCxxNkGrtYk8IfBgGff)GYg0afhc(Xq9cO2Wper1mNusgqEkCAwV84i84ObHhhZJbZJFmuBdAWlLPURR7Ki31q3Csd4NX2ol8Jc2gWXYwJxSyKkSO4hu2GgO4qWpgQxa1g(fopgopgopgopsHbIZXFa1cOUUoYjrr9Q1yKWJJWJFXJJ5XG5XbIZXtubs9K7GG67jpHepggpkuipsHbIZXFa1cOUUoYjrr9Q1yKWJJWJKcpggpoMhzzQPj5YBsjZ0tskWJazRlfpocpsk8yy8OqH8ifgioh)bulG666iNef1RwJrcpocpkopggpoMhzzQPj5YBi5jxECBaWrbJ6rGS1LIhfKhjn(zSTZc)oGAbuxxNArnjaEXInJyrXpOSbnqXHGFmuVaQn8lyE8JHABqdEPm1DDDNe5Ug6MtAa)m22zHFuW2aow2A8Ix8IFFaKQZcl2Obr8zmiZGrjv4hzdvDDv43SSSuIwGYJZopASTZIh1TAvE(C8tcLNwd43m5rsnvGupXJZcaBdWJbfQ(gy5ZNjpgyxj1muabU9gGyWZszbuTmH22olgYoRaQwMjaF(m5XGkXLqT8iPicpoAqeFg5XzJhNXz4xbHpNpFM84SoGvxqnd5ZNjpoB8yqLsbkpol2fLhdkra8n45ZNjpoB84SoRpaAbkpUg6cRRp8illAVDwkECtEebxcTH4rww0E7SuE(8zYJZgp(szGhtPTL7VTTZIhZdpgucQfqY9nWYJDXJb1GIK6E(C(8zYJK6ZkGrSaLhhGtIaEKLYd2YJdWTlLNhdQmgiTkESYA2cyi5dHMhn22zP4XS0tE(8zYJgB7SuEjeWs5bB)pAtrcF(m5rJTDwkVecyP8GTH(lWjtkF(m5rJTDwkVecyP8GTH(lGrCLHATTZIpFM84RmjvGC5rK1uECG4CakpQwBv84aCseWJSuEWwECaUDP4rRO8OecMnPC3UU8yR4rAwGNpFM8OX2olLxcbSuEW2q)fqvMKkqUo1ARIp3yBNLYlHawkpyBO)ciLBNfFUX2olLxcbSuEW2q)fazTcCuWO85gB7SuEjeWs5bBd9xacf46fKfPmz43(wfWqMYDYAD5XjLKbeFUX2olLxcbSuEW2q)fWqYtU842aGJcgvekOTP)r5Z5ZNjpsQpRagXcuEe(aOjECBzGh3aapASnr8yR4r7J1ABqdE(CJTDwQF5UOUdcGVb(CJTDwQq)f4JHABqdIuMm8lLPURR7Ki31q3CsdI8X0eWpltnnjxEfHSCwURHU5Kg8iq26sncPhVMgQ1RiKLZYDn0nN0GhkBqdu(8zYJZcnwBALi84S8cYkr4rRO8yUbaepMxgvXNBSTZsf6VagIzf42eHGAfPp)iIQzoPKmG8u40SEfC2j94WLG1Fn0nN0G3yB)bekm410qTEfHSCwURHU5Kg8qzdAGg2yerbEkCAwVc(tA(CJTDwQq)fyqNj1DiqtI0NFjy9xdDZjn4n22FaHcdEnnuRxrilNL7AOBoPbpu2GgO85gB7SuH(lWaGuaIKUUI0N)bIZXtubs9K7GG67jpHKqHsW6Vg6MtAWBST)acfg8AAOwVIqwol31q3CsdEOSbnq5ZNjpoRjuBkZJlQlsGvXJek7c85gB7SuH(laHcC9cYkr6Z)2YGGJgeHcdgcAIwscOEKjl111zYs6EjOG72x7tQxhu3UaHcdgcAIwscO(pTQZYLhhfKBfWNBSTZsf6VaekW1lilszYWVPc8Xkq5q23jYXsKPfPp)uyG4C8i77e5yjY0okmqCoE1AmsgrC(CJTDwQq)fGqbUEbzrktg(nvGpwbkhY(orowImTi95pCwMAAsU8MuYm9KKc8iWOtJPWaX54pGAbuxxh5KOOE1Amse8)RXuyG4C8i77e5yjY0okmqCoE1Amse8x8WekCG4C8evGup5oiO(EYtiXNBSTZsf6VaekW1lilszYW)Nw1z5YJJcYTcePp)HZYuttYL3KsMPNKuGhbgDAmfgioh)bulG666iNef1RwJrIG)FngukOyG)tR6SC5XjbOdW2olpu2GgOHju4aX54jQaPEYDqq99KNqsOqjy9xdDZjn4n22Fa(CJTDwQq)fGqbUEbzrktg(rMSuxxNjlP7LGcUBFTpPEDqD7cePp)Sm10KC5nPKz6jjf4rGS1LAKrfkCnnuR3qYtU842aGJAYfq9qzdAGkuiYAQd(a16nkv57AesZNBSTZsf6VaekW1lilszYW)W0nlWnaGZ0Ywzmr6ZpltnnjxEfHSCwURHU5Kg8iq26sj4SheHcdEnnuRxrilNL7AOBoPbpu2GgOJ3wgeC0GiuyWqqt0ssa1JmzPUUotws3lbfC3(AFs96G62fWNBSTZsf6VaekW1lilszYW)SeOCbsYAajsF(LG1Fn0nN0G3yB)bekm410qTEfHSCwURHU5Kg8qzdAGoEBzqWrdIqHbdbnrljbupYKL666mzjDVeuWD7R9j1RdQBxaFUX2olvO)cqOaxVGSiLjd)xtdmtRbKYnagjI0NFjy9xdDZjn4n22FaHcdEnnuRxrilNL7AOBoPbpu2GgOJ3wgeC0GiuyWqqt0ssa1JmzPUUotws3lbfC3(AFs96G62fWNBSTZsf6VaekW1lilszYW)fL1v5KqTSPDi7cI0NFerbJ8tkJdFBzqWrdIqHbdbnrljbupYKL666mzjDVeuWD7R9j1RdQBxqy85gB7SuH(lGuUDwI0NFwMAAsU8gsEYLh3gaCuWOEey0jHcLG1Fn0nN0G3yB)bekCG4C8evGup5oiO(EYtiXNptECw06ATU66YJKA1icnulpsQT2Ueap2kE04rjuNOEN4Zn22zPc9xGKyhqGrIi95NMR)tJi0qTojTDjapcKTUuJ8Fzu(CJTDwQq)fGzATZyBNLt3QvKYKHFqPGIbk(CJTDwQq)fGzATZyBNLt3QvKYKHFwMAAsUu85gB7SuH(laIOCgB7SC6wTIuMm8BjisF(n22FahuGCdkb)hLp3yBNLk0FbyMw7m22z50TAfPmz4)cfGAgFoF(m5XGAsQZJOCTTZIp3yBNLYBj8tbBd4SI6OaZMePp)Sm10KC5nPKz6jjf4rGS1LIp3yBNLYBje6Vau40AGp3yBNLYBje6VaGutb5MjsF(PGTbCwrDuGzt(TzK01DmIOGrgDCWFmuBdAWlLPURR7Ki31q3Csd85gB7SuElHq)fGc2gWXYwlsF(PGTbCwrDuGzt(TzK01DmIOGrgDCWFmuBdAWlLPURR7Ki31q3Csd85gB7SuElHq)fqXsc0fCQf1KaI0NFkyBaNvuhfy2KFBgjDDhZYuttYL3KsMPNKuGhbYwxk(CJTDwkVLqO)cW0g5UUovaJMKvI0NFkyBaNvuhfy2KFBgjDDhZYuttYL3KsMPNKuGhbYwxk(CJTDwkVLqO)casnfKBMi95p4pgQTbn4LYu311DsK7AOBoPb(CJTDwkVLqO)cCa1cOUUo1IAsarytmn4wdDHv9lUi95NcdeNJ)aQfqDDDKtII6vRXizKFXhZYuttYLNc2gWzf1rbMn5rGS1LIp3yBNLYBje6VahqTaQRRtTOMeqK(8VMgQ1pqGuBxxNkrGYdLnOb6yLeO1U1qxyv(bcKA766ujcuc(p6ykmqCo(dOwa111rojkQxTgJKr(fNp3yBNLYBje6VauW2aow2Ar6Z)aX54veukuoAMYEeySDmIOapfonRxb))Ip3yBNLYBje6VauW2aow2Ar6Z)aX54veukuoAMYEeySDCWFmuBdAWlLPURR7Ki31q3CsdcfkbR)AOBoPbVX2(dWNBSTZs5Tec9xakyBahlBTi95hrunZjLKbKNcNM17iI)14WzzQPj5YBsjZ0tskWJazRlLGKwOqkmqCo(dOwa111rojkQxTgJeb)kSXb)XqTnObVuM6UUUtICxdDZjnWNBSTZs5Tec9xafljqxWPwutcisF(dwjHaJ211rojkQAC4HtHbIZXFa1cOUUoYjrr9esJzzQPj5YBsjZ0tskWJazRlLGKomHcPWaX54pGAbuxxh5KOOE1Amse8RWgZYuttYL3qYtU842aGJcg1JazRlLGKMp3yBNLYBje6VamTrURRtfWOjzLi95pyLecmAxxh5KOOQXHhofgioh)bulG666iNef1tinMLPMMKlVjLmtpjPapcKTUucs6WekKcdeNJ)aQfqDDDKtII6vRXirWVcBmltnnjxEdjp5YJBdaokyupcKTUucsA(CJTDwkVLqO)cqbBd4yzRfPp)iIQzoPKmG8u40SEhz0Gmo4pgQTbn4LYu311DsK7AOBoPb(CJTDwkVLqO)cCa1cOUUo1IAsar6ZF4HhE4uyG4C8hqTaQRRJCsuuVAngjJ814Ghiohprfi1tUdcQVN8esHjuifgioh)bulG666iNef1RwJrYiKsyJzzQPj5YBsjZ0tskWJazRl1iKsycfsHbIZXFa1cOUUoYjrr9Q1yKmI4HnMLPMMKlVHKNC5XTbahfmQhbYwxkbjnFUX2olL3si0FbOGTbCSS1I0N)G)yO2g0GxktDxx3jrURHU5Kg4Z5Zn22zP8Sm10KCP(nK8KlpUna4OGr5Zn22zP8Sm10KCPc9xatkzMEssbI0NFkmqCo(dOwa111rojkQxTgJeb))Ip3yBNLYZYuttYLk0FbOgIe3ISsDsKSTDwI0N)GrwtDWhOwVrPkpmRA1Qekezn1bFGA9gLQ8DjO4KMp3yBNLYZYuttYLk0FbueYYz5Ug6MtAqK(8JiQM5KsYaYtHtZ6DeX)Ip3yBNLYZYuttYLk0FbiQaPEYDqq99Ki95NcdeNJ)aQfqDDDKtII6vRXizKVghC4qqt0ssa1JmzPUUotws3lbfC3(AFs96G62fiuO9nG6f8Y2Lq5YJBdaokyupu2GgOHXNBSTZs5zzQPj5sf6VaevGup5oiO(EsK(8ZYuttYL3KsMPNKuGhbYwxQrgDC4qqt0ssa1JmzPUUotws3lbfC3(AFs96G62fiuO9nG6f8Y2Lq5YJBdaokyupu2GgOHXNBSTZs5zzQPj5sf6VaevGup5oiO(EsK(8BST)aoOa5guc(p64WdNLPMMKlpfSnGZkQJcmBYJazRl1i)xgDCWRPHA9u40AWdLnObAycfgoltnnjxEkCAn4rGS1LAK)lJoEnnuRNcNwdEOSbnqdlm(CJTDwkpltnnjxQq)fqLeAhcmjajcBIPb3AOlSQFXfPp)RHUW63wgCB6OnmcPA8AOlS(TLb3MoAdc(fFUX2olLNLPMMKlvO)cOscTdbMeGePp)HhmYAQd(a16nkv5HzvRwLqHiRPo4duR3OuLVlbhniHngruWi)Hl(SnqCoEIkqQNCheuFp5jKcJp3yBNLYZYuttYLk0FbiQaPEYnO7BGLpNp3yBNLYdkfumq9ldYjAYLhNMG1uhfbMSsK(8JikWVTm420jUGxgDmIOAMtkjdOr(ki85gB7SuEqPGIbQq)fyqNj1Lh3gaCqbYtI0N)WzzQPj5YtbBd4SI6OaZM8iq26snwjbATBn0fwLNc2gWzf1rbMnjO4Hjuy4Sm10KC5PWP1GhbYwxQXkjqRDRHUWQ8u40AqqXdtOWWzzQPj5YBsjZ0tskWJazRl1ywMAAsU8uW2aoROokWSjpcm6uy85gB7SuEqPGIbQq)f4syiABLlpo7BaLBar6ZpltnnjxEtkzMEssbEey0j(CJTDwkpOuqXavO)cSbahrnKef1DsedePp)deNJhbms0Gs5ojIbEcjHchiohpcyKObLYDsedCSKOwa5vRXizeXfNp3yBNLYdkfumqf6VaNKrOaQZ(gq9cUbWKfPp)btbBd4SI6OaZM8BZiPRlFUX2olLhukOyGk0FbyzXGAr2cu3rBYGi95NMRNLfdQfzlqDhTjdUbcu5rGS1L6pi85gB7SuEqPGIbQq)fqIa1NPUUUbTPwr6ZFWuW2aoROokWSj)2ms66YNBSTZs5bLckgOc9xaYjst)aD5qGklRyGi95pykyBaNvuhfy2KFBgjDD5Zn22zP8GsbfduH(laQLK0GRlNsYyGi95pykyBaNvuhfy2KFBgjDD5Z5Zn22zP8xOauZ(PGTbCSS1I0N)bIZXRiOuOC0mL9iWy74G)yO2g0GxktDxx3jrURHU5Kgekucw)1q3CsdEJT9hGp3yBNLYFHcqnl0FbOGTbCSS1I0NFer1mNusgqEkCAwVJi(xJdNLPMMKlVjLmtpjPapcKTUucsAHcPWaX54pGAbuxxh5KOOE1Amse8RWgh8hd12Gg8szQ766ojYDn0nN0aFUX2olL)cfGAwO)cqbBd4SI6OaZMePp)RPHA9sGABnumWdLnOb6ywMAAsU8MuYm9KKc8iq26sXNBSTZs5VqbOMf6Vau40AqK(8ZYuttYL3KsMPNKuGhbYwxk(CJTDwk)fka1Sq)fqXsc0fCQf1KaI0N)WdNcdeNJ)aQfqDDDKtII6jKgZYuttYL3KsMPNKuGhbYwxkbjDycfsHbIZXFa1cOUUoYjrr9Q1yKi4xHnMLPMMKlVHKNC5XTbahfmQhbYwxkbjnFUX2olL)cfGAwO)cW0g5UUovaJMKvI0N)WdNcdeNJ)aQfqDDDKtII6jKgZYuttYL3KsMPNKuGhbYwxkbjDycfsHbIZXFa1cOUUoYjrr9Q1yKi4xHnMLPMMKlVHKNC5XTbahfmQhbYwxkbjnFUX2olL)cfGAwO)cqbBd4yzRfPp)iIQzoPKmG8u40SEhz0Gmo4pgQTbn4LYu311DsK7AOBoPb(CJTDwk)fka1Sq)f4aQfqDDDQf1KaI0N)Wdp8WPWaX54pGAbuxxh5KOOE1Amsg5RXbpqCoEIkqQNCheuFp5jKctOqkmqCo(dOwa111rojkQxTgJKriLWgZYuttYL3KsMPNKuGhbYwxQriLWekKcdeNJ)aQfqDDDKtII6vRXizeXdBmltnnjxEdjp5YJBdaokyupcKTUucsA(CJTDwk)fka1Sq)fGc2gWXYwlsF(d(JHABqdEPm1DDDNe5Ug6MtAa)mInqIWVxltOTTZAwJSZIx8IXa]] )

end
