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
                if essence.conflict_and_strike.major then return end
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


    spec:RegisterPack( "Unholy", 20190722, [[dGKwbbqicvpsrL2Kc1OeQ6ucvELqPzriDlfvLDrv)IGmmeOJjKSmfsptvPmnvLCneW2uuL(MIQQXjuqNtvPQ1POcMNcX9uvTpcQdQOkAHcPEOIQWefkGUOQsL2Oqb6KkQqTsfLxQOcXnvvQWoju(PqbyOQkvulvvPI8uvzQeIRQOIyRkQqAVq(lvgSGdtzXk4XOAYiDzWMvPpRIrleNw0Qvur61iOztYTjQDl1VLmCICCHcTCOEoPMUsxhrBxvX3rOXROI68kY6fkA(ey)OmkkKiOh1waj2OemQVNGZ)OJ6jib)2OF7l0BNKa0tY4eAha9AtgqV5KosPMqpjBsvgfjc6PlsmhqVi7kPNdcj0j3iKdEEjlKoLjv2MvZX2DfsNYCHqVbYuTZXnAa9O2ciXgLGr99eC(hDupbj43g9BFd90sahj2Oeyu0lssPqJgqpkO5O3CzH5KosPMyHyGGTryH5iDEISSzZLfISRKEoiKqNCJqo45LSq6uMuzBwnhB3viDkZfInBUSWms1elmAuIYcJsWO(Ewy(yHrJAo8fbzZyZMllmpIy9b0Zb2S5YcZhlmpPuGYcFhztzHyqmaXe8SzZLfMpwyEu9haVaLfwdFG1LxwGxnn3SAnlSflGHdPYWSaVAAUz1ApB2CzH5JfELmWcL0MYzmTnRMfQlledc6fWY5jYYczZcZZyaFxp6Ps9QrIGEGwdnh0irqIffse0dABqbuu0OhhNlGtd9WKn43ugCB5IIfeMfoCklmMfWKDYDsfraZcJWcFrq0Z4Bwn6jdYfEYvxNIKNuhfdMSgTiXgfjc6bTnOakkA0JJZfWPHEXZc8Qu0Iy7PGTrCwtDuGBtEmiBzRzHXSGwcuk3A4dSApfSnIZAQJcCBIfeMfIIfIJfeiGfINf4vPOfX2tHBQapgKTS1SWywqlbkLBn8bwTNc3ubSGWSquSqCSGabSq8SaVkfTi2EtQ4MAssdEmiBzRzHXSaVkfTi2EkyBeN1uhf42KhdgDIfId9m(MvJEdQQOU662iGdAqEcTiX(gse0dABqbuu0OhhNlGtd94vPOfX2Bsf3utsAWJbJoHEgFZQrVdPHPP1U66Syc4AJGwKyFHeb9G2guaffn6XX5c40qVbY71JboHkqRD3cZbpPeliqalmqEVEmWjubAT7wyo44fzVa2RxJtilmclevuONX3SA0BJaoYEOiBQ7wyoGwKyeajc6bTnOakkA0JJZfWPHEIZcuW2ioRPokWTj)MCcZ(GEgFZQrVBXj1a1zXeW5cUbWKrlsS5fjc6bTnOakkA0JJZfWPHE0A98Q5qVyBbQ7QmzWnqIBpgKTS1SWplqq0Z4Bwn6XRMd9ITfOURYKb0IeB(rIGEqBdkGIIg944CbCAON4SafSnIZAQJcCBYVjNWSpONX3SA0tIeN3PSpUbLPx0IelgIeb9G2guaffn6XX5c40qpXzbkyBeN1uhf42KFtoHzFqpJVz1OhXcROFGSDyqxT1CaTiX(EKiOh02GcOOOrpooxaNg6jolqbBJ4SM6Oa3M8BYjm7d6z8nRg9WPKKcCz70sghqlArpkCns1IebjwuirqpJVz1ONC2u3fdqmb0dABqbuu0Ofj2OirqpOTbfqrrJELe6PHf9m(MvJEFmCAdka9(yksa94vPOfX2RjLLR2Dm8PMuGhdYw2AwyewGaSWywynf0RxtklxT7y4tnPap02GcOO3hd7AtgqpPQuzFC3c7og(utkaTiX(gse0dABqbuu0OhhNlGtd9WKDYDsfra7PWn55YccZcZlbyHXSq8SGeS(JHp1Kc8gFZpaliqaliolSMc61RjLLR2Dm8PMuGhABqbuwiowymlGjBWtHBYZLfe(Nfia6z8nRg9mm3AWTfgd9IwKyFHeb9G2guaffn6XX5c40qpjy9hdFQjf4n(MFawqGawqCwynf0RxtklxT7y4tnPap02GcOONX3SA0Bqvf1DjXtOfjgbqIGEqBdkGIIg944CbCAO3a596j7iLAYDXqhZjpPeliqalibR)y4tnPaVX38dWcceWcIZcRPGE9Asz5QDhdFQjf4H2guaf9m(MvJEdawdycZ(GwKyZlse0dABqbuu0OhhNlGtd92ugybHzHrjiliqaliolaXizkjbup2KLY(4mzjvUKuWDYJ9PuRd6t2aliqaliolaXizkjbu)NuNv7QRJcYPgqpJVz1OhPgC5cYA0IeB(rIGEqBdkGIIg9m(MvJEFsDwTRUokiNAa944CbCAOx8SaVkfTi2EtQ4MAssdEmy0jwymlqHbY71Fb9c4SpoIfzt9614eYcc)ZcFXcJzbqRHMd(pPoR2vxNeGVaFZQ9qBdkGYcXXcceWcdK3RNSJuQj3fdDmN8KsSGabSGeS(JHp1Kc8gFZpa61MmGEFsDwTRUokiNAaTiXIHirqpOTbfqrrJEgFZQrpSjlL9XzYsQCjPG7Kh7tPwh0NSb0JJZfWPHE8Qu0Iy7nPIBQjjn4XGSLTMfgHfgLfeiGfwtb96nS8KRUUnc4OMCdup02GcOSGabSa2sQd(a96nkv7ZMfgHfia61MmGEytwk7JZKLu5ssb3jp2NsToOpzdOfj23Jeb9G2guaffn6z8nRg9gMovdUbaCMs2AJJECCUaon0JxLIweBVMuwUA3XWNAsbEmiBzRzbHzH5LGSGabSG4SWAkOxVMuwUA3XWNAsbEOTbfqzHXSWMYalimlmkbzbbcybXzbigjtjjG6XMSu2hNjlPYLKcUtESpLADqFYgqV2Kb0By6un4gaWzkzRnoArIffbrIGEqBdkGIIg9m(MvJEZPG2fPiQam6XX5c40qpjy9hdFQjf4n(MFawqGawqCwynf0RxtklxT7y4tnPap02GcOSWywytzGfeMfgLGSGabSG4SaeJKPKeq9ytwk7JZKLu5ssb3jp2NsToOpzdOxBYa6nNcAxKIOcWOfjwurHeb9G2guaffn6z8nRg9oMc4MsbyTBamcrpooxaNg6jbR)y4tnPaVX38dWcceWcIZcRPGE9Asz5QDhdFQjf4H2guaLfgZcBkdSGWSWOeKfeiGfeNfGyKmLKaQhBYszFCMSKkxsk4o5X(uQ1b9jBa9AtgqVJPaUPuaw7gaJq0IelQrrIGEqBdkGIIg9m(MvJEhC1hTtcNYMYHTdGECCUaon0dt2almYpl8nwymleplSPmWccZcJsqwqGawqCwaIrYuscOESjlL9XzYsQCjPG7Kh7tPwh0NSbwio0Rnza9o4QpANeoLnLdBhaTiXI6BirqpOTbfqrrJECCUaon0JxLIweBVHLNC11TrahfmQhdgDIfeiGfKG1Fm8PMuG34B(bybbcyHbY71t2rk1K7IHoMtEsj0Z4Bwn6jvBwnArIf1xirqpOTbfqrrJECCUaon0JwR)tIjvqVojLDibpgKTS1SWi)SWHtrpJVz1OxrUdyWieTiXIIairqpOTbfqrrJEgFZQrpUPuoJVz1ovQx0tL611MmGEGwdnh0OfjwuZlse0dABqbuu0ONX3SA0JBkLZ4BwTtL6f9uPEDTjdOhVkfTi2A0IelQ5hjc6bTnOakkA0JJZfWPHEgFZpGdAqobnli8plmk6z8nRg9WKTZ4BwTtL6f9uPEDTjdONvaArIfvmejc6bTnOakkA0Z4Bwn6XnLYz8nR2Ps9IEQuVU2Kb07anGtoArl6jHbEjpylseKyrHeb9m(MvJEs1MvJEqBdkGIIgTiXgfjc6z8nRg9WwQbhfmk6bTnOakkA0Ie7BirqpOTbfqrrJEuqztO3OONX3SA0ZWYtU662iGJcgfTOf94vPOfXwJebjwuirqpJVz1ONHLNC11Trahfmk6bTnOakkA0IeBuKiOh02GcOOOrpooxaNg6rHbY71Fb9c4SpoIfzt9614eYcc)ZcFHEgFZQrptQ4MAssdOfj23qIGEqBdkGIIg944CbCAON4Sa2sQd(a96nkv7H5CQxnliqalGTK6GpqVEJs1(SzbHzHOia6z8nRg9OgMq3ITwFlSSTz1Ofj2xirqpOTbfqrrJECCUaon0dt2j3jvebSNc3KNllmcle1xONX3SA0ttklxT7y4tnPa0IeJairqpOTbfqrrJECCUaon0JcdK3R)c6fWzFCelYM61RXjKfgHf(IfgZcIZcXZcqmsMssa1JnzPSpotwsLljfCN8yFk16G(KnWcceWcwmbCUGx2oKAxDDBeWrbJ6H2guaLfId9m(MvJEKDKsn5UyOJ5eArInVirqpOTbfqrrJECCUaon0JxLIweBVjvCtnjPbpgKTS1SWiSWOSWywiEwaIrYuscOESjlL9XzYsQCjPG7Kh7tPwh0NSbwqGawWIjGZf8Y2Hu7QRBJaokyup02GcOSqCONX3SA0JSJuQj3fdDmNqlsS5hjc6bTnOakkA0JJZfWPHEgFZpGdAqobnli8plmklmMfINfINf4vPOfX2tbBJ4SM6Oa3M8yq2YwZcJ8ZchoLfgZcIZcRPGE9u4MkWdTnOaklehliqaleplWRsrlITNc3ubEmiBzRzHr(zHdNYcJzH1uqVEkCtf4H2guaLfIJfId9m(MvJEKDKsn5UyOJ5eArIfdrIGEqBdkGIIg9m(MvJE6Iu5WGjby0JJZfWPHERHpW63ugCB5OjWcJWcXqwymlSg(aRFtzWTLJMaliml8f6XN4kWTg(aRgjwuOfj23Jeb9G2guaffn6XX5c40qV4zbXzbSLuh8b61BuQ2dZ5uVAwqGawaBj1bFGE9gLQ9zZccZcJsqwiowymlGjBGfg5NfINfIIfMpwyG8E9KDKsn5UyOJ5KNuIfId9m(MvJE6Iu5WGjby0IelkcIeb9m(MvJEKDKsn5gu5jYIEqBdkGIIgTOf9oqd4KJebjwuirqpOTbfqrrJECCUaon0BG8E9AskfAhTkzpgm(YcJzbXzHpgoTbf4LQsL9XDlS7y4tnPawqGawqcw)XWNAsbEJV5ha9m(MvJEuW2ioELk0IeBuKiOh02GcOOOrpooxaNg6Hj7K7KkIa2tHBYZLfgHfI6lwymleplWRsrlIT3KkUPMK0GhdYw2AwqywGaSGabSafgiVx)f0lGZ(4iwKn1RxJtiliml8flehlmMfeNf(y40guGxQkv2h3TWUJHp1KcqpJVz1OhfSnIJxPcTiX(gse0dABqbuu0OhhNlGtd9wtb96La9MkO5GhABqbuwymlWRsrlIT3KkUPMK0GhdYw2A0Z4Bwn6rbBJ4SM6Oa3MqlsSVqIGEqBdkGIIg944CbCAOhVkfTi2EtQ4MAssdEmiBzRrpJVz1OhfUPcqlsmcGeb9G2guaffn6XX5c40qV4zH4zbkmqEV(lOxaN9XrSiBQNuIfgZc8Qu0Iy7nPIBQjjn4XGSLTMfeMfialehliqalqHbY71Fb9c4SpoIfzt9614eYccZcFXcXXcJzbEvkArS9gwEYvx3gbCuWOEmiBzRzbHzbcGEgFZQrpnViXhWPxCsiGwKyZlse0dABqbuu0OhhNlGtd9INfINfOWa596VGEbC2hhXISPEsjwymlWRsrlIT3KkUPMK0GhdYw2AwqywGaSqCSGabSafgiVx)f0lGZ(4iwKn1RxJtiliml8flehlmMf4vPOfX2By5jxDDBeWrbJ6XGSLTMfeMfia6z8nRg94kJy2hNoIrlIA0IeB(rIGEqBdkGIIg944CbCAOhMStUtQicypfUjpxwyewyucYcJzbXzHpgoTbf4LQsL9XDlS7y4tnPa0Z4Bwn6rbBJ44vQqlsSyise0dABqbuu0OhhNlGtd9INfINfINfINfOWa596VGEbC2hhXISPE9ACczHryHVyHXSG4SWa596j7iLAYDXqhZjpPelehliqalqHbY71Fb9c4SpoIfzt9614eYcJWcFJfIJfgZc8Qu0Iy7nPIBQjjn4XGSLTMfgHf(glehliqalqHbY71Fb9c4SpoIfzt9614eYcJWcrXcXXcJzbEvkArS9gwEYvx3gbCuWOEmiBzRzbHzbcGEgFZQrVlOxaN9XPxCsiGwKyFpse0dABqbuu0OhhNlGtd9eNf(y40guGxQkv2h3TWUJHp1KcqpJVz1OhfSnIJxPcTOf9ScqIGelkKiOh02GcOOOrpooxaNg6XRsrlIT3KkUPMK0GhdYw2A0Z4Bwn6rbBJ4SM6Oa3MqlsSrrIGEgFZQrpkCtfGEqBdkGIIgTiX(gse0dABqbuu0OhhNlGtd9OGTrCwtDuGBt(n5eM9HfgZcyYgyHryHrzHXSG4SWhdN2Gc8svPY(4Uf2Dm8PMua6z8nRg9aPKcYjhTiX(cjc6bTnOakkA0JJZfWPHEuW2ioRPokWTj)MCcZ(WcJzbmzdSWiSWOSWywqCw4JHtBqbEPQuzFC3c7og(utka9m(MvJEuW2ioELk0IeJairqpOTbfqrrJECCUaon0Jc2gXzn1rbUn53Kty2hwymlWRsrlIT3KkUPMK0GhdYw2A0Z4Bwn6P5fj(ao9Itcb0IeBErIGEqBdkGIIg944CbCAOhfSnIZAQJcCBYVjNWSpSWywGxLIweBVjvCtnjPbpgKTS1ONX3SA0JRmIzFC6igTiQrlsS5hjc6bTnOakkA0JJZfWPHEIZcFmCAdkWlvLk7J7wy3XWNAsbONX3SA0dKskiNC0IelgIeb9G2guaffn6z8nRg9UGEbC2hNEXjHa6XX5c40qpkmqEV(lOxaN9XrSiBQxVgNqwyKFwikwymlWRsrlITNc2gXzn1rbUn5XGSLTg94tCf4wdFGvJelk0Ie77rIGEqBdkGIIg944CbCAO3AkOx)ajwVzFC6cdAp02GcOSWywqlbkLBn8bwTFGeR3SpoDHbnli8plmklmMfOWa596VGEbC2hhXISPE9ACczHr(zHOqpJVz1O3f0lGZ(40lojeqlsSOiise0dABqbuu0OhhNlGtd9giVxVMKsH2rRs2JbJVSWywat2GNc3KNlli8pl8f6z8nRg9OGTrC8kvOfjwurHeb9G2guaffn6XX5c40qVbY71RjPuOD0QK9yW4llmMfeNf(y40guGxQkv2h3TWUJHp1Kcybbcybjy9hdFQjf4n(MFa0Z4Bwn6rbBJ44vQqlsSOgfjc6bTnOakkA0JJZfWPHEyYo5oPIiG9u4M8CzHryHO(IfgZcXZc8Qu0Iy7nPIBQjjn4XGSLTMfeMfialiqalqHbY71Fb9c4SpoIfzt9614eYccZcFXcXXcJzbXzHpgoTbf4LQsL9XDlS7y4tnPa0Z4Bwn6rbBJ44vQqlsSO(gse0dABqbuu0OhhNlGtd9eNf0syWOzFCelYMQzHXSq8Sq8SafgiVx)f0lGZ(4iwKn1tkXcJzbEvkArS9MuXn1KKg8yq2YwZccZceGfIJfeiGfOWa596VGEbC2hhXISPE9ACczbHzHVyH4yHXSaVkfTi2Edlp5QRBJaokyupgKTS1SGWSabqpJVz1ONMxK4d40lojeqlsSO(cjc6bTnOakkA0JJZfWPHEIZcAjmy0SpoIfzt1SWywiEwiEwGcdK3R)c6fWzFCelYM6jLyHXSaVkfTi2EtQ4MAssdEmiBzRzbHzbcWcXXcceWcuyG8E9xqVao7JJyr2uVEnoHSGWSWxSqCSWywGxLIweBVHLNC11TrahfmQhdYw2AwqywGaONX3SA0JRmIzFC6igTiQrlsSOiase0dABqbuu0OhhNlGtd9WKDYDsfra7PWn55YcJWcJsqwymliol8XWPnOaVuvQSpUBHDhdFQjfGEgFZQrpkyBehVsfArIf18Ieb9G2guaffn6XX5c40qV4zH4zH4zH4zbkmqEV(lOxaN9XrSiBQxVgNqwyew4lwymliolmqEVEYosPMCxm0XCYtkXcXXcceWcuyG8E9xqVao7JJyr2uVEnoHSWiSW3yH4yHXSaVkfTi2EtQ4MAssdEmiBzRzHryHVXcXXcceWcuyG8E9xqVao7JJyr2uVEnoHSWiSquSqCSWywGxLIweBVHLNC11TrahfmQhdYw2AwqywGaONX3SA07c6fWzFC6fNecOfjwuZpse0dABqbuu0OhhNlGtd9eNf(y40guGxQkv2h3TWUJHp1KcqpJVz1OhfSnIJxPcTOfTO3haRZQrInkbJ67j48tW53p6Oea9iA4o7Jg9MJLLk8cuwyEzbJVz1SGk1R2ZMHEg5gPWO3lLjv2MvppW2DrpjCDtfGEZLfMt6iLAIfIbc2gHfMJ05jYYMnxwiYUs65GqcDYnc5GNxYcPtzsLTz1CSDxH0Pmxi2S5YcZivtSWOrjklmkbJ67zH5JfgnQ5WxeKnJnBUSW8iI1hqphyZMllmFSW8Ksbkl8DKnLfIbXaetWZMnxwy(yH5r1Fa8cuwyn8bwxEzbE10CZQ1SWwSagoKkdZc8QP5MvR9SzZLfMpw4vYalusBkNX02SAwOUSqmiOxalNNillKnlmpJb8D9SzSzZLf(UZzGtUaLfgGBHbwGxYd2YcdWjBTNfMNCoiTAwORE(Iyy5lPIfm(MvRzHQvtE2S5YcgFZQ1EjmWl5bB)VkttiB2CzbJVz1AVeg4L8GTX(l0TkkB2CzbJVz1AVeg4L8GTX(lKrEKHETnRMnBUSWRnjDKAzbSLuwyG8EbklOxB1SWaClmWc8sEWwwyaozRzbRPSGegMpPA3SpSqQzbA1GNnBUSGX3SATxcd8sEW2y)fs3MKosTo9ARMnZ4BwT2lHbEjpyBS)cjvBwnBMX3SATxcd8sEW2y)fcBPgCuWOSzgFZQ1EjmWl5bBJ9xidlp5QRBJaokyurPGYM(hLnJnBUSW3DodCYfOSa8bWtSWMYalSrawW4BHzHuZc2hlv2Gc8SzgFZQ1)YztDxmaXeyZm(MvRJ9xOpgoTbfiABYWVuvQSpUBHDhdFQjfi6htrc)8Qu0Iy71KYYv7og(utkWJbzlB9iey8AkOxVMuwUA3XWNAsbEOTbfqzZMll8DY4PP0IYcZXliRfLfSMYc1gbWSqD4unBMX3SADS)czyU1GBlmg6v08(Jj7K7KkIa2tHBYZv45LaJJxcw)XWNAsbEJV5hqGaXxtb961KYYv7og(utkWdTnOaACJXKn4PWn55k8pbyZm(MvRJ9xObvvu3LepjAE)LG1Fm8PMuG34B(beiq81uqVEnPSC1UJHp1Kc8qBdkGYMz8nRwh7VqdawdycZ(iAE)hiVxpzhPutUlg6yo5jLeiqcw)XWNAsbEJV5hqGaXxtb961KYYv7og(utkWdTnOakB2CzH5bPElzwyXztiSAwGuBhGnZ4BwTo2FHi1GlxqwlAE)3ugeEuckqG4qmsMssa1JnzPSpotwsLljfCN8yFk16G(KniqG4qmsMssa1)j1z1U66OGCQb2mJVz16y)fIudUCbzrBtg()K6SAxDDuqo1GO59pEEvkArS9MuXn1KKg8yWOtJPWa596VGEbC2hhXISPE9ACcf()RXGwdnh8FsDwTRUojaFb(Mv7H2guanobcgiVxpzhPutUlg6yo5jLeiqcw)XWNAsbEJV5hGnZ4BwTo2FHi1Glxqw02KHFSjlL9XzYsQCjPG7Kh7tPwh0NSbrZ7pVkfTi2EtQ4MAssdEmiBzRhzubcwtb96nS8KRUUnc4OMCdup02GcOceGTK6GpqVEJs1(ShHaSzgFZQ1X(lePgC5cYI2Mm8pmDQgCda4mLS1gx08(ZRsrlITxtklxT7y4tnPapgKTS1cpVeuGaXxtb961KYYv7og(utkWdTnOa64nLbHhLGceioeJKPKeq9ytwk7JZKLu5ssb3jp2NsToOpzdSzgFZQ1X(lePgC5cYI2Mm8pNcAxKIOcWIM3Fjy9hdFQjf4n(MFabceFnf0RxtklxT7y4tnPap02GcOJ3ugeEuckqG4qmsMssa1JnzPSpotwsLljfCN8yFk16G(KnWMz8nRwh7VqKAWLlilABYW)Xua3ukaRDdGrOO59xcw)XWNAsbEJV5hqGaXxtb961KYYv7og(utkWdTnOa64nLbHhLGceioeJKPKeq9ytwk7JZKLu5ssb3jp2NsToOpzdSzgFZQ1X(lePgC5cYI2Mm8FWvF0ojCkBkh2oGO59ht2Wi)FBC8BkdcpkbfiqCigjtjjG6XMSu2hNjlPYLKcUtESpLADqFYgIJnZ4BwTo2FHKQnRw08(ZRsrlIT3WYtU662iGJcg1JbJojqGeS(JHp1Kc8gFZpGabdK3RNSJuQj3fdDmN8KsSzZLf(oSSxl7SpSWC0etQGEzHVZk7qcSqQzbJfKWzHZDInZ4BwTo2FHkYDadgHIM3FAT(pjMub96Ku2He8yq2YwpY)HtzZm(MvRJ9xiUPuoJVz1ovQxrBtg(bTgAoOzZm(MvRJ9xiUPuoJVz1ovQxrBtg(5vPOfXwZMz8nRwh7VqyY2z8nR2Ps9kABYWVvGO5934B(bCqdYjOf(Fu2mJVz16y)fIBkLZ4BwTtL6v02KH)d0ao5SzSzZLfMN13LfW1ABwnBMX3SAT3k4Nc2gXzn1rbUnjAE)5vPOfX2Bsf3utsAWJbzlBnBMX3SAT3ki2FHOWnvaBMX3SAT3ki2FHaPKcYjx08(tbBJ4SM6Oa3M8BYjm7ZymzdJm6yX)y40guGxQkv2h3TWUJHp1KcyZm(MvR9wbX(lefSnIJxPs08(tbBJ4SM6Oa3M8BYjm7ZymzdJm6yX)y40guGxQkv2h3TWUJHp1KcyZm(MvR9wbX(lKMxK4d40lojeenV)uW2ioRPokWTj)MCcZ(mMxLIweBVjvCtnjPbpgKTS1SzgFZQ1ERGy)fIRmIzFC6igTiQfnV)uW2ioRPokWTj)MCcZ(mMxLIweBVjvCtnjPbpgKTS1SzgFZQ1ERGy)fcKskiNCrZ7V4FmCAdkWlvLk7J7wy3XWNAsbSzgFZQ1ERGy)f6c6fWzFC6fNecIYN4kWTg(aR(pkrZ7pfgiVx)f0lGZ(4iwKn1RxJt4i)rnMxLIweBpfSnIZAQJcCBYJbzlBnBMX3SAT3ki2FHUGEbC2hNEXjHGO59Fnf0RFGeR3SpoDHbThABqb0XAjqPCRHpWQ9dKy9M9XPlmOf(F0XuyG8E9xqVao7JJyr2uVEnoHJ8hfBMX3SAT3ki2FHOGTrC8kvIM3)bY71RjPuOD0QK9yW47ymzdEkCtEUc))fBMX3SAT3ki2FHOGTrC8kvIM3)bY71RjPuOD0QK9yW47yX)y40guGxQkv2h3TWUJHp1Kceiqcw)XWNAsbEJV5hGnZ4BwT2Bfe7VquW2ioELkrZ7pMStUtQicypfUjp3rI6RXXZRsrlIT3KkUPMK0GhdYw2AHjGabuyG8E9xqVao7JJyr2uVEnoHc)vCJf)JHtBqbEPQuzFC3c7og(utkGnZ4BwT2Bfe7VqAErIpGtV4Kqq08(lUwcdgn7JJyr2u944JNcdK3R)c6fWzFCelYM6jLgZRsrlIT3KkUPMK0GhdYw2AHjqCceqHbY71Fb9c4SpoIfzt9614ek8xXnMxLIweBVHLNC11TrahfmQhdYw2AHjaBMX3SAT3ki2FH4kJy2hNoIrlIArZ7V4Ajmy0SpoIfzt1JJpEkmqEV(lOxaN9XrSiBQNuAmVkfTi2EtQ4MAssdEmiBzRfMaXjqafgiVx)f0lGZ(4iwKn1RxJtOWFf3yEvkArS9gwEYvx3gbCuWOEmiBzRfMaSzgFZQ1ERGy)fIc2gXXRujAE)XKDYDsfra7PWn55oYOeCS4FmCAdkWlvLk7J7wy3XWNAsbSzgFZQ1ERGy)f6c6fWzFC6fNecIM3)4Jp(4PWa596VGEbC2hhXISPE9ACch5RXIpqEVEYosPMCxm0XCYtkfNabuyG8E9xqVao7JJyr2uVEnoHJ8T4gZRsrlIT3KkUPMK0GhdYw26r(wCceqHbY71Fb9c4SpoIfzt9614eosuXnMxLIweBVHLNC11TrahfmQhdYw2AHjaBMX3SAT3ki2FHOGTrC8kvIM3FX)y40guGxQkv2h3TWUJHp1KcyZyZm(MvR98Qu0IyR)nS8KRUUnc4OGrzZm(MvR98Qu0IyRJ9xitQ4MAssdIM3FkmqEV(lOxaN9XrSiBQxVgNqH))InZ4BwT2ZRsrlITo2FHOgMq3ITwFlSSTz1IM3FXXwsDWhOxVrPApmNt9QfiaBj1bFGE9gLQ9zlCueGnZ4BwT2ZRsrlITo2FH0KYYv7og(utkq08(Jj7K7KkIa2tHBYZDKO(InZ4BwT2ZRsrlITo2FHi7iLAYDXqhZjrZ7pfgiVx)f0lGZ(4iwKn1RxJt4iFnw84HyKmLKaQhBYszFCMSKkxsk4o5X(uQ1b9jBqGalMaoxWlBhsTRUUnc4OGr9qBdkGghBMX3SATNxLIweBDS)cr2rk1K7IHoMtIM3FEvkArS9MuXn1KKg8yq2YwpYOJJhIrYuscOESjlL9XzYsQCjPG7Kh7tPwh0NSbbcSyc4CbVSDi1U662iGJcg1dTnOaACSzgFZQ1EEvkArS1X(lezhPutUlg6yojAE)n(MFah0GCcAH)hDC8XZRsrlITNc2gXzn1rbUn5XGSLTEK)dNow81uqVEkCtf4H2guanobcINxLIweBpfUPc8yq2YwpY)HthVMc61tHBQap02GcOXfhBMX3SATNxLIweBDS)cPlsLddMeGfLpXvGBn8bw9FuIM3)1Why9BkdUTC0egjgoEn8bw)MYGBlhnbH)InZ4BwT2ZRsrlITo2FH0fPYHbtcWIM3)4fhBj1bFGE9gLQ9WCo1RwGaSLuh8b61BuQ2NTWJsW4gJjByK)4JA(giVxpzhPutUlg6yo5jLIJnZ4BwT2ZRsrlITo2FHi7iLAYnOYtKLnJnZ4BwT2dAn0Cq)ldYfEYvxNIKNuhfdMSw08(JjBWVPm42YfLWhoDmMStUtQic4r(IGSzgFZQ1EqRHMd6y)fAqvf1vx3gbCqdYtIM3)45vPOfX2tbBJ4SM6Oa3M8yq2YwpwlbkLBn8bwTNc2gXzn1rbUnjCuXjqq88Qu0Iy7PWnvGhdYw26XAjqPCRHpWQ9u4Mkq4OItGG45vPOfX2Bsf3utsAWJbzlB9yEvkArS9uW2ioRPokWTjpgm6uCSzgFZQ1EqRHMd6y)f6qAyAATRUolMaU2iIM3FEvkArS9MuXn1KKg8yWOtSzgFZQ1EqRHMd6y)fAJaoYEOiBQ7wyoiAE)hiVxpg4eQaT2Dlmh8KscemqEVEmWjubAT7wyo44fzVa2RxJt4irffBMX3SATh0AO5Go2FHUfNuduNftaNl4gatw08(lofSnIZAQJcCBYVjNWSpSzgFZQ1EqRHMd6y)fIxnh6fBlqDxLjdIM3FATEE1COxSTa1DvMm4giXThdYw26FcYMz8nRw7bTgAoOJ9xijsCENY(4guMEfnV)ItbBJ4SM6Oa3M8BYjm7dBMX3SATh0AO5Go2FHiwyf9dKTdd6QTMdIM3FXPGTrCwtDuGBt(n5eM9HnZ4BwT2dAn0Cqh7Vq4ussbUSDAjJdIM3FXPGTrCwtDuGBt(n5eM9HnJnZ4BwT2FGgWj)Nc2gXXRujAE)hiVxVMKsH2rRs2JbJVJf)JHtBqbEPQuzFC3c7og(utkqGajy9hdFQjf4n(MFa2mJVz1A)bAaN8y)fIc2gXXRujAE)XKDYDsfra7PWn55osuFnoEEvkArS9MuXn1KKg8yq2YwlmbeiGcdK3R)c6fWzFCelYM61RXju4VIBS4FmCAdkWlvLk7J7wy3XWNAsbSzgFZQ1(d0ao5X(lefSnIZAQJcCBs08(VMc61lb6nvqZbp02GcOJ5vPOfX2Bsf3utsAWJbzlBnBMX3SAT)anGtES)crHBQarZ7pVkfTi2EtQ4MAssdEmiBzRzZm(MvR9hObCYJ9xinViXhWPxCsiiAE)JpEkmqEV(lOxaN9XrSiBQNuAmVkfTi2EtQ4MAssdEmiBzRfMaXjqafgiVx)f0lGZ(4iwKn1RxJtOWFf3yEvkArS9gwEYvx3gbCuWOEmiBzRfMaSzgFZQ1(d0ao5X(lexzeZ(40rmArulAE)JpEkmqEV(lOxaN9XrSiBQNuAmVkfTi2EtQ4MAssdEmiBzRfMaXjqafgiVx)f0lGZ(4iwKn1RxJtOWFf3yEvkArS9gwEYvx3gbCuWOEmiBzRfMaSzgFZQ1(d0ao5X(lefSnIJxPs08(Jj7K7KkIa2tHBYZDKrj4yX)y40guGxQkv2h3TWUJHp1KcyZm(MvR9hObCYJ9xOlOxaN9XPxCsiiAE)Jp(4JNcdK3R)c6fWzFCelYM61RXjCKVgl(a596j7iLAYDXqhZjpPuCceqHbY71Fb9c4SpoIfzt9614eoY3IBmVkfTi2EtQ4MAssdEmiBzRh5BXjqafgiVx)f0lGZ(4iwKn1RxJt4irf3yEvkArS9gwEYvx3gbCuWOEmiBzRfMaSzgFZQ1(d0ao5X(lefSnIJxPs08(l(hdN2Gc8svPY(4Uf2Dm8PMuaArlcb]] )

end
