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


    spec:RegisterPack( "Unholy", 20190728, [[dGeTdbqiHKhPOsBsHAucvDkHkVsO0Sie3srv1UOQFHOmmHuDmcvltH0ZesX0uvQRPQKTPOcFtrvzCisX5qKsRtrfzEke3tv1(quDqfvjluO4HkQsnrfvuCrePsBerQQtQOk0kvuEjIuf3urfv7Kq5NisvAOisf1svurPNQktLq6Qisf2kIur2lu)LkdwWHPSyf8yunzKUmyZQ4ZQ0OfItl1Qvuf8AeXSj52e1UL8BrdNihxiLwoKNtQPR01ry7Qk(obgVIQOZRiRhrY8jO9JYyXXIIFuBbSyJgDXjTrF(gL04hv8VMVVNd8BNKa8tY4Kyxa)ktgWpshvKunHFs2Kknkwu8tNeioGFr2vspNiJSBVrig88uMmDltOSTZIJSZsMUL5KHFdeTANhl8a(rTfWInA0fN0g95BusJFuX)A((Eu8tlbCSyJ(1O4xKMsHcpGFuqZXV5YcKoQiPAIfMZa2gHfi9u9nYYMnxwiYUs65ezKD7ncXGNNYKPBzcLTDwCKDwY0TmNm2S5YcZiutSWOKgryHrJU4Kwwy(zHrfFo91CWMXMnxwyEhXQlONtSzZLfMFwyErPaLfMZ7IYcK(iaif4zZMllm)SW8oRpaAbklSg6cRRpSaplAVDwAwytwabxcLHybEw0E7S0E2S5YcZpl8szGfsPTLBszBNflKhwG0h0lGK7BKLf6IfMxKEjD94NQ1Rglk(bAnuCqJfflM4yrXpOSbfqXXGFCuVaQn8druGFBzWTPtCwGCw4YPSWywarun3jLcaelmcl8D0XpJVDw4NmiNOjxECkcEtDueyYA8IfBuSO4hu2GcO4yWpoQxa1g(fplWZurtbLNc2gXzf1rbUn5rGS1LMfgZcAjqPCRHUWQ9uW2ioROokWTjwGCwqCwiowqOqwiEwGNPIMckpfoTc8iq26sZcJzbTeOuU1qxy1EkCAfWcKZcIZcXXccfYcXZc8mv0uq5nPKBQjjn4rGS1LMfgZc8mv0uq5PGTrCwrDuGBtEey0jwio8Z4BNf(nOYK6YJBJaoOa5j8IflAWIIFqzdkGIJb)4OEbuB4hptfnfuEtk5MAssdEey0j8Z4BNf(DjmeTTYLhNrkaLBe8If7BSO4hu2GcO4yWpoQxa1g(nqCoEeWjrbAT7Kio4jKybHczHbIZXJaojkqRDNeXbhpjQfqE9ACsyHrybXfh)m(2zHFBeWrudjrrDNeXb8If7lSO4hu2GcO4yWpoQxa1g(fflqbBJ4SI6Oa3M8BZjPRl(z8TZc)ojNqduNrka1l4gatgVyXMdSO4hu2GcO4yWpoQxa1g(rZ1ZZId1ISfOUJYKb3abQ8iq26sZc)Sq0XpJVDw4hploulYwG6oktgWlwS5dlk(bLnOakog8JJ6fqTHFrXcuW2ioROokWTj)2Cs66IFgF7SWpjcuFM666guMEXlwmsdwu8dkBqbuCm4hh1lGAd)IIfOGTrCwrDuGBt(T5K01f)m(2zHFcsKI(b6YHaDwwXb8IfJ0Iff)GYguafhd(Xr9cO2WVOybkyBeNvuhf42KFBojDDXpJVDw4hQLKuGRlNwY4aEXl(rHJrOwSOyXehlk(z8TZc)K7I6oiaifGFqzdkGIJbVyXgflk(bLnOakog8lLWpnS4NX3ol87JHABqb43htra4hptfnfuEnHSCwURHU5Kc8iq26sZcJWcFXcJzH1uqTEnHSCwURHU5Kc8qzdkGIFFmKRmza)KYu111DsK7AOBoPa8IflAWIIFqzdkGIJb)4OEbuB4hIOAUtkfaipfonVxwGCwyo(IfgZcXZcsW6Vg6MtkWB8T)aSGqHSquSWAkOwVMqwol31q3CsbEOSbfqzH4yHXSaIOapfonVxwG8Fw4l8Z4BNf(ziUvGBtecQfVyX(glk(bLnOakog8JJ6fqTHFsW6Vg6MtkWB8T)aSGqHSquSWAkOwVMqwol31q3CsbEOSbfqXpJVDw43GktQ7qGMWlwSVWIIFqzdkGIJb)4OEbuB43aX54jQiPAYDqqrQjpHeliuilibR)AOBoPaVX3(dWccfYcrXcRPGA9Acz5SCxdDZjf4HYguaf)m(2zHFdasdis66IxSyZbwu8dkBqbuCm4hh1lGAd)2wgybYzHrJoliuileflarlrljbupYKL666mzjvVeuWD7R9jvRdQBxaliuileflarlrljbu)Nw3z5YJJcYTgWpJVDw4hHgC9cYA8IfB(WIIFqzdkGIJb)m(2zHFMoYhRaTdzKkroEImf(Xr9cO2WpkmqCoEKrQe54jYuokmqCoE9ACsyHrybXXVYKb8Z0r(yfODiJujYXtKPWlwmsdwu8dkBqbuCm4NX3ol8Z0r(yfODiJujYXtKPWpoQxa1g(fplWZurtbL3KsUPMK0GhbgDIfgZcuyG4C8hqVaQRRtqsuuVEnojSa5)SW3SWywGcdeNJhzKkroEImLJcdeNJxVgNewG8FwqCwiowqOqwyG4C8evKun5oiOi1KNqc)ktgWpth5JvG2HmsLihprMcVyXiTyrXpOSbfqXXGFgF7SWVpTUZYLhhfKBnGFCuVaQn8lEwGNPIMckVjLCtnjPbpcm6elmMfOWaX54pGEbuxxNGKOOE9ACsybY)zHVzHXSaO1qXb)Nw3z5YJtcqhGVDwEOSbfqzH4ybHczHbIZXturs1K7GGIutEcjwqOqwqcw)1q3CsbEJV9ha)ktgWVpTUZYLhhfKBnGxSyIhDSO4hu2GcO4yWpJVDw4hYKL666mzjvVeuWD7R9jvRdQBxa(Xr9cO2WpEMkAkO8MuYn1KKg8iq26sZcJWcJYccfYcRPGA9gsEYLh3gbCutUaQhkBqbuwqOqwazn1bFGA9gLQ9DXcJWcFHFLjd4hYKL666mzjvVeuWD7R9jvRdQBxaEXIjU4yrXpOSbfqXXGFgF7SWVHPBwGBaaNPKTY44hh1lGAd)4zQOPGYRjKLZYDn0nNuGhbYwxAwGCwyoIoliuileflSMcQ1RjKLZYDn0nNuGhkBqbuwymlSTmWcKZcJgDwqOqwikwaIwIwscOEKjl111zYsQEjOG72x7tQwhu3Ua8Rmza)gMUzbUbaCMs2kJJxSyIpkwu8dkBqbuCm4NX3ol8BEa0UiPafGWpoQxa1g(jbR)AOBoPaVX3(dWccfYcrXcRPGA9Acz5SCxdDZjf4HYguaLfgZcBldSa5SWOrNfekKfIIfGOLOLKaQhzYsDDDMSKQxck4U91(KQ1b1Tla)ktgWV5bq7IKcuacVyXepAWIIFqzdkGIJb)m(2zHFxtbCtPaK2nagj4hh1lGAd)KG1Fn0nNuG34B)bybHczHOyH1uqTEnHSCwURHU5Kc8qzdkGYcJzHTLbwGCwy0OZccfYcrXcq0s0ssa1JmzPUUotws1lbfC3(AFs16G62fGFLjd431ua3ukaPDdGrcEXIj(3yrXpOSbfqXXGFgF7SWVlkRR2jHAzt5q2fWpoQxa1g(HikGfg5NfIgwymleplSTmWcKZcJgDwqOqwikwaIwIwscOEKjl111zYsQEjOG72x7tQwhu3Uawio8Rmza)UOSUANeQLnLdzxaVyXe)lSO4hu2GcO4yWpoQxa1g(XZurtbL3qYtU842iGJcg1JaJoXccfYcsW6Vg6MtkWB8T)aSGqHSWaX54jQiPAYDqqrQjpHe(z8TZc)KYTZcVyXeFoWIIFqzdkGIJb)4OEbuB4hnx)NgrOGADsk7saEeiBDPzHr(zHlNIFgF7SWVKyhqGrcEXIj(8Hff)GYguafhd(z8TZc)4Ms5m(2z5uTEXpvRxxzYa(bAnuCqJxSyItAWIIFqzdkGIJb)m(2zHFCtPCgF7SCQwV4NQ1RRmza)4zQOPGsJxSyItAXIIFqzdkGIJb)4OEbuB4NX3(d4GcKBqZcK)ZcJIFgF7SWper5m(2z5uTEXpvRxxzYa(zjGxSyJgDSO4hu2GcO4yWpJVDw4h3ukNX3olNQ1l(PA96ktgWVluaQ54fV4Nec4P8GTyrXIjowu8Z4BNf(jLBNf(bLnOakog8IfBuSO4NX3ol8dzTgCuWO4hu2GcO4yWlwSOblk(bLnOakog8JckBc)gf)m(2zHFgsEYLh3gbCuWO4fV4hptfnfuASOyXehlk(z8TZc)mK8KlpUnc4OGrXpOSbfqXXGxSyJIff)GYguafhd(Xr9cO2WpkmqCo(dOxa111jijkQxVgNewG8Fw4B8Z4BNf(zsj3utsAaVyXIgSO4hu2GcO4yWpoQxa1g(fflGSM6GpqTEJs1EyE26vZccfYciRPo4duR3OuTVlwGCwq8VWpJVDw4h1qK4wKv6tIKTTZcVyX(glk(bLnOakog8JJ6fqTHFiIQ5oPuaG8u408EzHrybX)g)m(2zHFAcz5SCxdDZjfGxSyFHff)GYguafhd(Xr9cO2WpkmqCo(dOxa111jijkQxVgNewyew4BwymlefleplarlrljbupYKL666mzjvVeuWD7R9jvRdQBxaliuilyKcq9cEz7sOD5XTrahfmQhkBqbuwio8Z4BNf(rurs1K7GGIut4fl2CGff)GYguafhd(Xr9cO2WpEMkAkO8MuYn1KKg8iq26sZcJWcJYcJzH4zbiAjAjjG6rMSuxxNjlP6LGcUBFTpPADqD7cybHczbJuaQxWlBxcTlpUnc4OGr9qzdkGYcXHFgF7SWpIksQMCheuKAcVyXMpSO4hu2GcO4yWpoQxa1g(z8T)aoOa5g0Sa5)SWOSWywiEwiEwGNPIMckpfSnIZkQJcCBYJazRlnlmYplC5uwymleflSMcQ1tHtRapu2GcOSqCSGqHSq8SaptfnfuEkCAf4rGS1LMfg5NfUCklmMfwtb16PWPvGhkBqbuwiowio8Z4BNf(rurs1K7GGIut4flgPblk(bLnOakog8Z4BNf(PtcLdbMeGWpoQxa1g(Tg6cRFBzWTPJ2almclqAyHXSWAOlS(TLb3MoAdSa5SW34hFIRa3AOlSASyIJxSyKwSO4hu2GcO4yWpoQxa1g(fpleflGSM6GpqTEJs1EyE26vZccfYciRPo4duR3OuTVlwGCwy0OZcXXcJzberbSWi)Sq8SG4SW8ZcdeNJNOIKQj3bbfPM8esSqC4NX3ol8tNekhcmjaHxSyIhDSO4NX3ol8JOIKQj3GQVrw8dkBqbuCm4fV4NLawuSyIJff)GYguafhd(Xr9cO2WpEMkAkO8MuYn1KKg8iq26sJFgF7SWpkyBeNvuhf42eEXInkwu8Z4BNf(rHtRa8dkBqbuCm4flw0Gff)GYguafhd(Xr9cO2WpkyBeNvuhf42KFBojDDzHXSaIOawyewyuwymlefl8XqTnOaVuMQUUUtICxdDZjfGFgF7SWpqQPGCZXlwSVXIIFqzdkGIJb)4OEbuB4hfSnIZkQJcCBYVnNKUUSWywarualmclmklmMfIIf(yO2guGxktvxx3jrURHU5KcWpJVDw4hfSnIJNTcVyX(clk(bLnOakog8JJ6fqTHFuW2ioROokWTj)2Cs66YcJzbEMkAkO8MuYn1KKg8iq26sJFgF7SWpnpjqxWPxutcGxSyZbwu8dkBqbuCm4hh1lGAd)OGTrCwrDuGBt(T5K01LfgZc8mv0uq5nPKBQjjn4rGS1Lg)m(2zHFCLjORRthXOPanEXInFyrXpOSbfqXXGFCuVaQn8lkw4JHABqbEPmvDDDNe5Ug6Mtka)m(2zHFGutb5MJxSyKgSO4hu2GcO4yWpJVDw43b0lG6660lQjbWpoQxa1g(rHbIZXFa9cOUUobjrr9614KWcJ8ZcIZcJzbEMkAkO8uW2ioROokWTjpcKTU04hFIRa3AOlSASyIJxSyKwSO4hu2GcO4yWpoQxa1g(TMcQ1pqG0BxxNorG2dLnOaklmMf0sGs5wdDHv7hiq6TRRtNiqZcK)ZcJYcJzbkmqCo(dOxa111jijkQxVgNewyKFwqC8Z4BNf(Da9cOUUo9IAsa8Ift8OJff)GYguafhd(Xr9cO2WVbIZXRjOuOC0mL9iW4llmMfqef4PWP59YcK)ZcFJFgF7SWpkyBehpBfEXIjU4yrXpOSbfqXXGFCuVaQn8BG4C8Ackfkhntzpcm(YcJzHOyHpgQTbf4LYu111DsK7AOBoPawqOqwqcw)1q3CsbEJV9ha)m(2zHFuW2ioE2k8Ift8rXIIFqzdkGIJb)4OEbuB4hIOAUtkfaipfonVxwyewq8VzHXSq8SaptfnfuEtk5MAssdEeiBDPzbYzHVybHczbkmqCo(dOxa111jijkQxVgNewGCw4Bwiowymlefl8XqTnOaVuMQUUUtICxdDZjfGFgF7SWpkyBehpBfEXIjE0Gff)GYguafhd(Xr9cO2WVOybTecmAxxNGKOOAwymlepleplqHbIZXFa9cOUUobjrr9esSWywGNPIMckVjLCtnjPbpcKTU0Sa5SWxSqCSGqHSafgioh)b0lG666eKef1RxJtclqol8nlehlmMf4zQOPGYBi5jxECBeWrbJ6rGS1LMfiNf(c)m(2zHFAEsGUGtVOMeaVyXe)BSO4hu2GcO4yWpoQxa1g(fflOLqGr766eKefvZcJzH4zH4zbkmqCo(dOxa111jijkQNqIfgZc8mv0uq5nPKBQjjn4rGS1LMfiNf(IfIJfekKfOWaX54pGEbuxxNGKOOE9ACsybYzHVzH4yHXSaptfnfuEdjp5YJBJaokyupcKTU0Sa5SWx4NX3ol8JRmbDDD6ignfOXlwmX)clk(bLnOakog8JJ6fqTHFiIQ5oPuaG8u408EzHryHrJolmMfIIf(yO2guGxktvxx3jrURHU5KcWpJVDw4hfSnIJNTcVyXeFoWIIFqzdkGIJb)4OEbuB4x8Sq8Sq8Sq8Safgioh)b0lG666eKef1RxJtclmcl8nlmMfIIfgiohprfjvtUdcksn5jKyH4ybHczbkmqCo(dOxa111jijkQxVgNewyewiAyH4yHXSaptfnfuEtk5MAssdEeiBDPzHryHOHfIJfekKfOWaX54pGEbuxxNGKOOE9ACsyHrybXzH4yHXSaptfnfuEdjp5YJBJaokyupcKTU0Sa5SWx4NX3ol87a6fqDDD6f1Ka4flM4Zhwu8dkBqbuCm4hh1lGAd)IIf(yO2guGxktvxx3jrURHU5KcWpJVDw4hfSnIJNTcV4f)UqbOMJfflM4yrXpOSbfqXXGFCuVaQn8BG4C8Ackfkhntzpcm(YcJzHOyHpgQTbf4LYu111DsK7AOBoPawqOqwqcw)1q3CsbEJV9ha)m(2zHFuW2ioE2k8IfBuSO4hu2GcO4yWpoQxa1g(HiQM7KsbaYtHtZ7LfgHfe)BwymleplWZurtbL3KsUPMK0GhbYwxAwGCw4lwqOqwGcdeNJ)a6fqDDDcsII61RXjHfiNf(MfIJfgZcrXcFmuBdkWlLPQRR7Ki31q3Csb4NX3ol8Jc2gXXZwHxSyrdwu8dkBqbuCm4hh1lGAd)wtb16La92kO4GhkBqbuwymlWZurtbL3KsUPMK0GhbYwxA8Z4BNf(rbBJ4SI6Oa3MWlwSVXIIFqzdkGIJb)4OEbuB4hptfnfuEtk5MAssdEeiBDPXpJVDw4hfoTcWlwSVWIIFqzdkGIJb)4OEbuB4x8Sq8Safgioh)b0lG666eKef1tiXcJzbEMkAkO8MuYn1KKg8iq26sZcKZcFXcXXccfYcuyG4C8hqVaQRRtqsuuVEnojSa5SW3SqCSWywGNPIMckVHKNC5XTrahfmQhbYwxAwGCw4l8Z4BNf(P5jb6co9IAsa8IfBoWIIFqzdkGIJb)4OEbuB4x8Sq8Safgioh)b0lG666eKef1tiXcJzbEMkAkO8MuYn1KKg8iq26sZcKZcFXcXXccfYcuyG4C8hqVaQRRtqsuuVEnojSa5SW3SqCSWywGNPIMckVHKNC5XTrahfmQhbYwxAwGCw4l8Z4BNf(XvMGUUoDeJMc04fl28Hff)GYguafhd(Xr9cO2Wper1CNukaqEkCAEVSWiSWOrNfgZcrXcFmuBdkWlLPQRR7Ki31q3Csb4NX3ol8Jc2gXXZwHxSyKgSO4hu2GcO4yWpoQxa1g(fpleplepleplqHbIZXFa9cOUUobjrr9614KWcJWcFZcJzHOyHbIZXturs1K7GGIutEcjwiowqOqwGcdeNJ)a6fqDDDcsII61RXjHfgHfIgwiowymlWZurtbL3KsUPMK0GhbYwxAwyewiAyH4ybHczbkmqCo(dOxa111jijkQxVgNewyewqCwiowymlWZurtbL3qYtU842iGJcg1JazRlnlqol8f(z8TZc)oGEbuxxNErnjaEXIrAXIIFqzdkGIJb)4OEbuB4xuSWhd12Gc8szQ666ojYDn0nNua(z8TZc)OGTrC8Sv4fV4f)(aiDNfwSrJU4K2OpFJok(jWqvxxn(npklLOfOSWCWcgF7SybvRxTNnd)Kq5Pva(nxwG0rfjvtSWCgW2iSaPNQVrw2S5Ycr2vspNiJSBVrig88uMmDltOSTZIJSZsMUL5KXMnxwygHAIfgL0iclmA0fN0YcZplmQ4ZPVMd2m2S5YcZ7iwDb9CInBUSW8ZcZlkfOSWCExuwG0hbaPapB2CzH5NfM3z9bqlqzH1qxyD9Hf4zr7TZsZcBYci4sOmelWZI2BNL2ZMnxwy(zHxkdSqkTTCtkB7SyH8WcK(GEbKCFJSSqxSW8I0lPRNnJnBUSaP78e4elqzHb4KiGf4P8GTSWaC7s7zH5fNdsRMfQSM)igs(qOybJVDwAwil1KNnBUSGX3olTxcb8uEW2)JY0KWMnxwW4BNL2lHaEkpyBS)KDYKYMnxwW4BNL2lHaEkpyBS)KzexzOwB7SyZMll8ktshjxwaznLfgiohGYc61wnlmaNebSapLhSLfgGBxAwWkkliHG5xk3TRll0AwGMf4zZMlly8TZs7LqapLhSn2FY0LjPJKRtV2QzZm(2zP9siGNYd2g7pzs52zXMz8TZs7LqapLhSn2FYqwRbhfmkBMX3olTxcb8uEW2y)jZqYtU842iGJcgvekOSP)rzZyZMllq6opboXcuwa(aOjwyBzGf2ialy8nrSqRzb7J1kBqbE2mJVDw6F5UOUdcasbSzgF7S0X(t2hd12GcePmz4xktvxx3jrURHU5Kce5JPiGFEMkAkO8Acz5SCxdDZjf4rGS1LEKVgVMcQ1RjKLZYDn0nNuGhkBqbu2S5YcZznEBkTiSW84cYArybROSqUraelKxovZMz8TZsh7pzgIBf42eHGAfPp)iIQ5oPuaG8u408EjFo(AC8sW6Vg6MtkWB8T)acfg1AkOwVMqwol31q3CsbEOSbfqJBmIOapfonVxY))InZ4BNLo2FYguzsDhc0Ki95xcw)1q3CsbEJV9hqOWOwtb161eYYz5Ug6MtkWdLnOakBMX3olDS)KnainGiPRRi95FG4C8evKun5oiOi1KNqsOqjy9xdDZjf4n(2FaHcJAnfuRxtilNL7AOBoPapu2GcOSzZLfM3e6nLzHf1fjWQzbcTDb2mJVDw6y)jJqdUEbzTi95FBzG8rJUqHrbrlrljbupYKL666mzjvVeuWD7R9jvRdQBxGqHrbrlrljbu)Nw3z5YJJcYTgyZm(2zPJ9Nmcn46fKfPmz430r(yfODiJujYXtKPePp)uyG4C8iJujYXtKPCuyG4C8614KmI4SzgF7S0X(tgHgC9cYIuMm8B6iFSc0oKrQe54jYuI0N)45zQOPGYBsj3utsAWJaJonMcdeNJ)a6fqDDDcsII61RXjH8)VhtHbIZXJmsLihprMYrHbIZXRxJtc5)IhNqHdeNJNOIKQj3bbfPM8esSzgF7S0X(tgHgC9cYIuMm8)P1DwU84OGCRbr6ZF88mv0uq5nPKBQjjn4rGrNgtHbIZXFa9cOUUobjrr9614Kq()3JbTgko4)06olxECsa6a8TZYdLnOaACcfoqCoEIksQMCheuKAYtijuOeS(RHU5Kc8gF7paBMX3olDS)KrObxVGSiLjd)itwQRRZKLu9sqb3TV2NuToOUDbI0NFEMkAkO8MuYn1KKg8iq26spYOcfUMcQ1Bi5jxECBeWrn5cOEOSbfqfkezn1bFGA9gLQ9DnYxSzgF7S0X(tgHgC9cYIuMm8pmDZcCda4mLSvgxK(8ZZurtbLxtilNL7AOBoPapcKTU0KphrxOWOwtb161eYYz5Ug6MtkWdLnOa64TLbYhn6cfgfeTeTKeq9itwQRRZKLu9sqb3TV2NuToOUDbSzgF7S0X(tgHgC9cYIuMm8ppaAxKuGcqI0NFjy9xdDZjf4n(2FaHcJAnfuRxtilNL7AOBoPapu2GcOJ3wgiF0Oluyuq0s0ssa1JmzPUUotws1lbfC3(AFs16G62fWMz8TZsh7pzeAW1lilszYW)1ua3ukaPDdGrIi95xcw)1q3CsbEJV9hqOWOwtb161eYYz5Ug6MtkWdLnOa64TLbYhn6cfgfeTeTKeq9itwQRRZKLu9sqb3TV2NuToOUDbSzgF7S0X(tgHgC9cYIuMm8FrzD1ojulBkhYUGi95hruWi)rZ443wgiF0Oluyuq0s0ssa1JmzPUUotws1lbfC3(AFs16G62fehBMX3olDS)KjLBNLi95NNPIMckVHKNC5XTrahfmQhbgDsOqjy9xdDZjf4n(2FaHchiohprfjvtUdcksn5jKyZMllmNBDTwxDDzbsNAeHcQLfiDwzxcGfAnlySGeQtuVtSzgF7S0X(twsSdiWirK(8tZ1)PrekOwNKYUeGhbYwx6r(VCkBMX3olDS)KXnLYz8TZYPA9kszYWpO1qXbnBMX3olDS)KXnLYz8TZYPA9kszYWpptfnfuA2mJVDw6y)jdruoJVDwovRxrktg(TeePp)gF7pGdkqUbn5)JYMz8TZsh7pzCtPCgF7SCQwVIuMm8FHcqnNnJnBUSW8kjDzbuU22zXMz8TZs7Te(PGTrCwrDuGBtI0NFEMkAkO8MuYn1KKg8iq26sZMz8TZs7TeI9NmkCAfWMz8TZs7TeI9NmqQPGCZfPp)uW2ioROokWTj)2Cs66ogruWiJooQpgQTbf4LYu111DsK7AOBoPa2mJVDwAVLqS)KrbBJ44zRePp)uW2ioROokWTj)2Cs66ogruWiJooQpgQTbf4LYu111DsK7AOBoPa2mJVDwAVLqS)KP5jb6co9IAsar6ZpfSnIZkQJcCBYVnNKUUJ5zQOPGYBsj3utsAWJazRlnBMX3olT3si2FY4ktqxxNoIrtbAr6ZpfSnIZkQJcCBYVnNKUUJ5zQOPGYBsj3utsAWJazRlnBMX3olT3si2FYaPMcYnxK(8h1hd12Gc8szQ666ojYDn0nNuaBMX3olT3si2FYoGEbuxxNErnjGi8jUcCRHUWQ)fxK(8tHbIZXFa9cOUUobjrr9614KmYV4J5zQOPGYtbBJ4SI6Oa3M8iq26sZMz8TZs7TeI9NSdOxa111PxutcisF(xtb16hiq6TRRtNiq7HYguaDSwcuk3AOlSA)absVDDD6ebAY)hDmfgioh)b0lG666eKef1RxJtYi)IZMz8TZs7TeI9NmkyBehpBLi95FG4C8Ackfkhntzpcm(ogruGNcNM3l5)FZMz8TZs7TeI9NmkyBehpBLi95FG4C8Ackfkhntzpcm(ooQpgQTbf4LYu111DsK7AOBoPaHcLG1Fn0nNuG34B)byZm(2zP9wcX(tgfSnIJNTsK(8JiQM7KsbaYtHtZ7DeX)EC88mv0uq5nPKBQjjn4rGS1LM8VekKcdeNJ)a6fqDDDcsII61RXjH8VJBCuFmuBdkWlLPQRR7Ki31q3CsbSzgF7S0ElHy)jtZtc0fC6f1KaI0N)O0siWODDDcsIIQhhF8uyG4C8hqVaQRRtqsuupH0yEMkAkO8MuYn1KKg8iq26st(xXjuifgioh)b0lG666eKef1RxJtc5Fh3yEMkAkO8gsEYLh3gbCuWOEeiBDPj)l2mJVDwAVLqS)KXvMGUUoDeJMc0I0N)O0siWODDDcsIIQhhF8uyG4C8hqVaQRRtqsuupH0yEMkAkO8MuYn1KKg8iq26st(xXjuifgioh)b0lG666eKef1RxJtc5Fh3yEMkAkO8gsEYLh3gbCuWOEeiBDPj)l2mJVDwAVLqS)KrbBJ44zRePp)iIQ5oPuaG8u408Ehz0OpoQpgQTbf4LYu111DsK7AOBoPa2mJVDwAVLqS)KDa9cOUUo9IAsar6ZF8XhF8uyG4C8hqVaQRRtqsuuVEnojJ894OgiohprfjvtUdcksn5jKItOqkmqCo(dOxa111jijkQxVgNKrIM4gZZurtbL3KsUPMK0GhbYwx6rIM4ekKcdeNJ)a6fqDDDcsII61RXjzeXJBmptfnfuEdjp5YJBJaokyupcKTU0K)fBMX3olT3si2FYOGTrC8SvI0N)O(yO2guGxktvxx3jrURHU5KcyZyZm(2zP98mv0uqP)nK8KlpUnc4OGrzZm(2zP98mv0uqPJ9Nmtk5MAssdI0NFkmqCo(dOxa111jijkQxVgNeY))MnZ4BNL2ZZurtbLo2FYOgIe3ISsFsKSTDwI0N)OqwtDWhOwVrPApmpB9Qfkezn1bFGA9gLQ9DrU4FXMz8TZs75zQOPGsh7pzAcz5SCxdDZjfisF(revZDsPaa5PWP59oI4FZMz8TZs75zQOPGsh7pzevKun5oiOi1Ki95NcdeNJ)a6fqDDDcsII61RXjzKVhhv8q0s0ssa1JmzPUUotws1lbfC3(AFs16G62fiuOrka1l4LTlH2Lh3gbCuWOEOSbfqJJnZ4BNL2ZZurtbLo2FYiQiPAYDqqrQjr6ZpptfnfuEtk5MAssdEeiBDPhz0XXdrlrljbupYKL666mzjvVeuWD7R9jvRdQBxGqHgPauVGx2UeAxECBeWrbJ6HYguano2mJVDwApptfnfu6y)jJOIKQj3bbfPMePp)gF7pGdkqUbn5)Joo(45zQOPGYtbBJ4SI6Oa3M8iq26spY)Lthh1AkOwpfoTc8qzdkGgNqHXZZurtbLNcNwbEeiBDPh5)YPJxtb16PWPvGhkBqb04IJnZ4BNL2ZZurtbLo2FY0jHYHatcqIWN4kWTg6cR(xCr6Z)AOlS(TLb3MoAdJqAgVg6cRFBzWTPJ2a5FZMz8TZs75zQOPGsh7pz6Kq5qGjbir6ZF8rHSM6GpqTEJs1EyE26vluiYAQd(a16nkv77I8rJECJrefmYF8Ip)deNJNOIKQj3bbfPM8esXXMz8TZs75zQOPGsh7pzevKun5gu9nYYMXMz8TZs7bTgkoO)Lb5en5YJtrWBQJIatwlsF(ref43wgCB6eN8lNogrun3jLca0iFhD2mJVDwApO1qXbDS)KnOYK6YJBJaoOa5jr6ZF88mv0uq5PGTrCwrDuGBtEeiBDPhRLaLYTg6cR2tbBJ4SI6Oa3Mix84ekmEEMkAkO8u40kWJazRl9yTeOuU1qxy1EkCAfqU4Xjuy88mv0uq5nPKBQjjn4rGS1LEmptfnfuEkyBeNvuhf42KhbgDko2mJVDwApO1qXbDS)KDjmeTTYLhNrkaLBer6ZpptfnfuEtk5MAssdEey0j2mJVDwApO1qXbDS)KTrahrnKef1DsehePp)deNJhbCsuGw7ojIdEcjHchiohpc4KOaT2DsehC8KOwa51RXjzeXfNnZ4BNL2dAnuCqh7pzNKtObQZifG6fCdGjlsF(JIc2gXzf1rbUn53Mtsxx2mJVDwApO1qXbDS)KXZId1ISfOUJYKbr6ZpnxpploulYwG6oktgCdeOYJazRl9F0zZm(2zP9Gwdfh0X(tMebQptDDDdktVI0N)OOGTrCwrDuGBt(T5K01LnZ4BNL2dAnuCqh7pzcsKI(b6YHaDwwXbr6ZFuuW2ioROokWTj)2Cs66YMz8TZs7bTgkoOJ9NmuljPaxxoTKXbr6ZFuuW2ioROokWTj)2Cs66YMXMz8TZs7VqbOM)tbBJ44zRePp)deNJxtqPq5Ozk7rGX3Xr9XqTnOaVuMQUUUtICxdDZjfiuOeS(RHU5Kc8gF7paBMX3olT)cfGAES)KrbBJ44zRePp)iIQ5oPuaG8u408Ehr8VhhpptfnfuEtk5MAssdEeiBDPj)lHcPWaX54pGEbuxxNGKOOE9ACsi)74gh1hd12Gc8szQ666ojYDn0nNuaBMX3olT)cfGAES)KrbBJ4SI6Oa3MePp)RPGA9sGEBfuCWdLnOa6yEMkAkO8MuYn1KKg8iq26sZMz8TZs7VqbOMh7pzu40kqK(8ZZurtbL3KsUPMK0GhbYwxA2mJVDwA)fka18y)jtZtc0fC6f1KaI0N)4JNcdeNJ)a6fqDDDcsII6jKgZZurtbL3KsUPMK0GhbYwxAY)koHcPWaX54pGEbuxxNGKOOE9ACsi)74gZZurtbL3qYtU842iGJcg1JazRln5FXMz8TZs7VqbOMh7pzCLjORRthXOPaTi95p(4PWaX54pGEbuxxNGKOOEcPX8mv0uq5nPKBQjjn4rGS1LM8VItOqkmqCo(dOxa111jijkQxVgNeY)oUX8mv0uq5nK8KlpUnc4OGr9iq26st(xSzgF7S0(luaQ5X(tgfSnIJNTsK(8JiQM7KsbaYtHtZ7DKrJ(4O(yO2guGxktvxx3jrURHU5KcyZm(2zP9xOauZJ9NSdOxa111PxutcisF(Jp(4JNcdeNJ)a6fqDDDcsII61RXjzKVhh1aX54jQiPAYDqqrQjpHuCcfsHbIZXFa9cOUUobjrr9614Kms0e3yEMkAkO8MuYn1KKg8iq26sps0eNqHuyG4C8hqVaQRRtqsuuVEnojJiECJ5zQOPGYBi5jxECBeWrbJ6rGS1LM8VyZm(2zP9xOauZJ9NmkyBehpBLi95pQpgQTbf4LYu111DsK7AOBoPa8Zi2ijc)ETmHY2oR5nYolEXlgd]] )

end
