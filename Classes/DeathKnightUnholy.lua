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


    spec:RegisterPack( "Unholy", 20190816, [[dG0RebqibYJui1MuOgLcXPeuELGQzriULIQYUOQFrqggbLJjqTmfvEgcuttvjxtvP2gbv(MIQQXHaX5qG06uiPMNG4EQQ2hHYbvijluq6HkQsnrcQkDrcQsBKGQQtQOk0kvv8sfvbUjbvHDsO6NeuvmucQIAPeuf5PQYujKUQIQO2QIQG2lu)LudwOdtzXk4XOAYiDzWMvXNvPrlGtl1Qvuf51iOztLBtKDl53IgorDCfsSCipNKPR01r02vu(obgVIQKZRiRhbmFeA)OmoySO4h1wal(CclycQWiiblCEHn)FhSW(g)2jza)KnoH2fWVYKa8BEUcKUj8t2MCPrXIIFQKeXb8lWUYQrTqcD7na5GNNscPAjsNTDwCKDwHuTexi8BGSD78yHhWpQTaw85ewWeuHrqcw48cB()wyFjC4Nsg4yXN775WVanLcfEa)OGIJFJMfNNRaPBIff(c2gGfNhu9nWY(mAwmWUYQrTqcD7na5GNNscPAjsNTDwCKDwHuTexi2NrZIJkYlPAzXG)sewCoHfmbLfNpwCoHnQNB(zFyFgnloVdy1fuJA2NrZIZhloQOuGYIcp6IYIc)iaia4zFgnloFS48oRzaAbklUg6cRUpSiplAVDwkwCtwebxsNHyrEw0E7SuE2NrZIZhl(sjGft5TLAcyBNflMhwu4hulGK6BGLf7IfhvcFeE94NRvRclk(bkfuCqHfflEWyrXpOSbhqXHIFCuVaQn8drwGFBjqVPoywumw8YPS4ywerwnxlNcaelgcl(LWWpJVDw4NeiLOjDE0osEt1ueysk8IfFoSO4hu2GdO4qXpoQxa1g(nclYZ0rtbLNc2gqBfvtbUn5rGK1LIfhZIkzW50RHUWQ8uW2aAROAkWTjwumwmywmmwKirwCewKNPJMckpfoTd8iqY6sXIJzrLm4C61qxyvEkCAhWIIXIbZIHXIejYIJWI8mD0uq5n5KBUjzf4rGK1LIfhZI8mD0uq5PGTb0wr1uGBtEey0jwmm8Z4BNf(n4YKQZJEdaAOaPj8IfNGXIIFqzdoGIdf)4OEbuB4hpthnfuEto5MBswbEeizDPyXqyrHd)m(2zHFxsdrBR05rBeaq5gaVyX)clk(bLn4akou8JJ6fqTHFdKNJhbCcDGsPpjIdEszwKirwCG8C8iGtOduk9jrCqZtYAbKxTgNqwmewm4GXpJVDw43ga0K1qswu9jrCaVyX)glk(bLn4akou8JJ6fqTHFbXIuW2aAROAkWTj)2Cc76IFgF7SWVtYjvavBeaq9c6bWKWlwCHdlk(bLn4akou8JJ6fqTHF0C98S4qTiBbQ(4mjqpqIkpcKSUuS4plkm8Z4BNf(XZId1ISfO6JZKa8IfF(XIIFqzdoGIdf)4OEbuB4xqSifSnG2kQMcCBYVnNWUU4NX3ol8tMe1NPUU6bNPw8IfNGGff)GYgCafhk(Xr9cO2WVGyrkyBaTvunf42KFBoHDDXpJVDw4NGe5OZGU0iqLLvCaVyXjOyrXpOSbhqXHIFCuVaQn8liwKc2gqBfvtbUn53Mtyxx8Z4BNf(HAzzhO7sRKnoGx8IFu4yKUflkw8GXIIFgF7SWpPUO6dcaca4hu2GdO4qXlw85WIIFqzdoGIdf)sz8tbl(z8TZc)MzO2gCa(nZCKa(XZ0rtbLxrkjLL(AOBo5apcKSUuSyiS43S4ywCnhuRxrkjLL(AOBo5apu2GdO43mdPltcWp5mDDD1NePVg6MtoaVyXjySO4hu2GdO4qXpoQxa1g(HiRMRLtbaYtHtZ7LffJffUVzXXS4iSOmS(RHU5Kd8gF7zalsKilgelUMdQ1RiLKYsFn0nNCGhkBWbuwmmwCmlIilWtHtZ7Lff7Nf)g)m(2zHFgIBfO3eHGAXlw8VWIIFqzdoGIdf)4OEbuB4NmS(RHU5Kd8gF7zalsKilgelUMdQ1RiLKYsFn0nNCGhkBWbu8Z4BNf(n4YKQpKOj8If)BSO4hu2GdO4qXpoQxa1g(nqEoEYkq6M0heueyYtkZIejYIYW6Vg6MtoWB8TNbSirISyqS4AoOwVIuskl91q3CYbEOSbhqXpJVDw43aGuaIWUU4flUWHff)GYgCafhk(Xr9cO2WVTLawumwCoHXIejYIbXIWOq2YYa1Jmj5UUAts21ljf03(AZs3QH62fWIejYIbXIWOq2YYa1pRvDw68OPGuRa8Z4BNf(rQaDVGKcVyXNFSO4hu2GdO4qXpJVDw4NPcmZkqPrgbsKMNiZHFCuVaQn8JcdKNJhzeirAEImNMcdKNJxTgNqwmewmy8Rmja)mvGzwbknYiqI08ezo8IfNGGff)GYgCafhk(z8TZc)mvGzwbknYiqI08ezo8JJ6fqTHFYW6VKgI2wPZJ2iaGYnG34BpdyrIezXryXbYZXtwbs3K(GGIatEszwCmlgelckfuCWZZIcLcOAxFGtI4GhkBWbuwmmwKirwCewKNPJMckVjNCZnjRapcKSUuSyiS4CS4ywKNPJMckVHKM05rVbanfmQhbswxkwmewKGfoHXIHHFLjb4NPcmZkqPrgbsKMNiZHxS4euSO4hu2GdO4qXpJVDw43Sw1zPZJMcsTcWpoQxa1g(nclYZ0rtbL3KtU5MKvGhbgDIfhZIuyG8C8hqTaQRRwqswuVAnoHSOy)S4xS4yweukO4GFwR6S05rldOdW3olpu2GdOSyySirIS4a554jRaPBsFqqrGjpPmlsKilkdR)AOBo5aVX3EgGFLjb43Sw1zPZJMcsTcWlw8Gfgwu8dkBWbuCO4NX3ol8dzsYDD1MKSRxskOV91MLUvd1Tla)4OEbuB4hpthnfuEto5MBswbEeizDPyXqyX5yrIezX1CqTEdjnPZJEdaAQjva1dLn4aklsKilISMQHzqTEJsv(UyXqyXVXVYKa8dzsYDD1MKSRxskOV91MLUvd1TlaVyXdoySO4hu2GdO4qXpJVDw43W0nlqpaG2CswzC8JJ6fqTHF8mD0uq5vKsszPVg6MtoWJajRlflkglkCcJfjsKfdIfxZb16vKsszPVg6MtoWdLn4akloMf3wcyrXyX5eglsKilgelcJczlldupYKK76QnjzxVKuqF7RnlDRgQBxa(vMeGFdt3Sa9aaAZjzLXXlw8GNdlk(bLn4akou8Z4BNf(npbkDGuGdq4hh1lGAd)KH1Fn0nNCG34BpdyrIezXGyX1CqTEfPKuw6RHU5Kd8qzdoGYIJzXTLawumwCoHXIejYIbXIWOq2YYa1Jmj5UUAts21ljf03(AZs3QH62fGFLjb438eO0bsboaHxS4btWyrXpOSbhqXHIFgF7SWVR5aU5CasPhaJq8JJ6fqTHFYW6Vg6MtoWB8TNbSirISyqS4AoOwVIuskl91q3CYbEOSbhqzXXS42salkgloNWyrIezXGyryuiBzzG6rMKCxxTjj76LKc6BFTzPB1qD7cWVYKa87AoGBohGu6bWieVyXd(lSO4hu2GdO4qXpJVDw43fL1vPLrTK50i7c4hh1lGAd)qKfWIH8ZIemloMfhHf3wcyrXyX5eglsKilgelcJczlldupYKK76QnjzxVKuqF7RnlDRgQBxalgg(vMeGFxuwxLwg1sMtJSlGxS4b)nwu8dkBWbuCO4hh1lGAd)4z6OPGYBiPjDE0BaqtbJ6rGrNyrIezrzy9xdDZjh4n(2ZawKirwCG8C8KvG0nPpiOiWKNug)m(2zHFY52zHxS4blCyrXpOSbhqXHIFCuVaQn8JMRFwJiDqTAzNDjbpcKSUuSyi)S4LtXpJVDw4xsUdiWieVyXdE(XIIFqzdoGIdf)m(2zHFCZ50gF7S0UwT4NRvRUmja)aLckoOWlw8GjiyrXpOSbhqXHIFgF7SWpU5CAJVDwAxRw8Z1QvxMeGF8mD0uqPWlw8GjOyrXpOSbhqXHIFCuVaQn8Z4Bpd0qbsnOyrX(zX5WpJVDw4hIS0gF7S0UwT4NRvRUmja)SeWlw85egwu8dkBWbuCO4NX3ol8JBoN24BNL21Qf)CTA1Ljb43fka1C8Ix8tgb8uAWwSOyXdglk(z8TZc)KZTZc)GYgCafhkEXIphwu8Z4BNf(HSwbAkyu8dkBWbuCO4flobJff)GYgCafhk(vMeGFgbubmKP0NSwDE0YPaaHFgF7SWpJaQagYu6twRopA5uaGWlw8VWIIFqzdoGIdf)OGZMWV5WpJVDw4NHKM05rVbanfmkEXl(XZ0rtbLclkw8GXIIFgF7SWpdjnPZJEdaAkyu8dkBWbuCO4fl(CyrXpOSbhqXHIFCuVaQn8JcdKNJ)aQfqDD1csYI6vRXjKff7Nf)c)m(2zHFMCYn3KScWlwCcglk(bLn4akou8JJ6fqTHFbXIiRPAyguR3OuLhMxTAvSirISiYAQgMb16nkv57IffJfd(B8Z4BNf(rneH6fzL6KijB7SWlw8VWIIFqzdoGIdf)4OEbuB4hISAUwofaipfonVxwmewm4VWpJVDw4NIuskl91q3CYb4fl(3yrXpOSbhqXHIFCuVaQn8dukO4GFwR6S05rldOdW3olpu2GdOSirISifgiph)bulG66QfKKf1RwJtilgcl(floMfdIfhHfHrHSLLbQhzsYDD1MKSRxskOV91MLUvd1TlGfjsKfncaOEbVKDjv68O3aGMcg1dLn4aklgglsKilYZ0rtbL3KtU5MKvGhbswxkwmewCowCmloclcJczlldupYKK76QnjzxVKuqF7RnlDRgQBxalsKilAeaq9cEj7sQ05rVbanfmQhkBWbuwmm8Z4BNf(rwbs3K(GGIat4flUWHff)GYgCafhk(Xr9cO2WpJV9mqdfi1GIff7NfNJfhZIJWIJWI8mD0uq5PGTb0wr1uGBtEeizDPyXq(zXlNYIJzXGyX1CqTEkCAh4HYgCaLfdJfjsKfhHf5z6OPGYtHt7apcKSUuSyi)S4LtzXXS4AoOwpfoTd8qzdoGYIHXIHHFgF7SWpYkq6M0heueycVyXNFSO4hu2GdO4qXpJVDw4NkjDAeyYac)4OEbuB43AOlS(TLa9MAAdSyiSibHfhZIRHUW63wc0BQPnWIIXIFHF8jUd0RHUWQWIhmEXItqWIIFqzdoGIdf)4OEbuB43iSyqSiYAQgMb16nkv5H5vRwflsKilISMQHzqTEJsv(UyrXyX5eglggloMfrKfWIH8ZIJWIbZIZhloqEoEYkq6M0heueyYtkZIHHFgF7SWpvs60iWKbeEXItqXIIFgF7SWpYkq6M0dU(gyXpOSbhqXHIx8IFwcyrXIhmwu8dkBWbuCO4hh1lGAd)4z6OPGYBYj3CtYkWJajRlf(z8TZc)OGTb0wr1uGBt4fl(CyrXpJVDw4hfoTdWpOSbhqXHIxS4emwu8dkBWbuCO4hh1lGAd)OGTb0wr1uGBt(T5e21LfhZIiYcyXqyX5yXXSyqS4md12Gd8Yz666QpjsFn0nNCa(z8TZc)a5McsnhVyX)clk(bLn4akou8JJ6fqTHFuW2aAROAkWTj)2Cc76YIJzrezbSyiS4CS4ywmiwCMHABWbE5mDDD1NePVg6Mtoa)m(2zHFuW2aAE2o8If)BSO4hu2GdO4qXpoQxa1g(rbBdOTIQPa3M8BZjSRlloMf5z6OPGYBYj3CtYkWJajRlf(z8TZc)u8KeDbTArnHaEXIlCyrXpOSbhqXHIFCuVaQn8Jc2gqBfvtbUn53MtyxxwCmlYZ0rtbL3KtU5MKvGhbswxk8Z4BNf(XDMGUUAvaJMcu4fl(8Jff)GYgCafhk(Xr9cO2WVGyXzgQTbh4LZ011vFsK(AOBo5a8Z4BNf(bYnfKAoEXItqWIIFqzdoGIdf)m(2zHFhqTaQRRwTOMqa)4OEbuB4hfgiph)bulG66QfKKf1RwJtilgYplgmloMf5z6OPGYtbBdOTIQPa3M8iqY6sHF8jUd0RHUWQWIhmEXItqXIIFqzdoGIdf)4OEbuB43AoOw)ajsTDD1Qebkpu2GdOS4ywujdoNEn0fwLFGeP2UUAvIaflk2plohloMfPWa554pGAbuxxTGKSOE1ACczXq(zXGXpJVDw43bulG66QvlQjeWlw8Gfgwu8dkBWbuCO4hh1lGAd)giphVIKsHstZuYJaJVS4ywerwGNcNM3llk2pl(f(z8TZc)OGTb08SD4flEWbJff)GYgCafhk(Xr9cO2WVbYZXRiPuO00mL8iW4lloMfdIfNzO2gCGxotxxx9jr6RHU5KdyrIezrzy9xdDZjh4n(2Za8Z4BNf(rbBdO5z7Wlw8GNdlk(bLn4akou8JJ6fqTHFiYQ5A5uaG8u408EzXqyXG)IfhZIJWI8mD0uq5n5KBUjzf4rGK1LIffJf)MfjsKfPWa554pGAbuxxTGKSOE1ACczrXyXVyXWyXXSyqS4md12Gd8Yz666QpjsFn0nNCa(z8TZc)OGTb08SD4flEWemwu8dkBWbuCO4hh1lGAd)cIfvYiWODD1csYIQyXXS4iS4iSifgiph)bulG66QfKKf1tkZIJzrEMoAkO8MCYn3KSc8iqY6sXIIXIFZIHXIejYIuyG8C8hqTaQRRwqswuVAnoHSOyS4xSyyS4ywKNPJMckVHKM05rVbanfmQhbswxkwumw8B8Z4BNf(P4jj6cA1IAcb8Ifp4VWIIFqzdoGIdf)4OEbuB4xqSOsgbgTRRwqswufloMfhHfhHfPWa554pGAbuxxTGKSOEszwCmlYZ0rtbL3KtU5MKvGhbswxkwumw8BwmmwKirwKcdKNJ)aQfqDD1csYI6vRXjKffJf)IfdJfhZI8mD0uq5nK0Kop6naOPGr9iqY6sXIIXIFJFgF7SWpUZe01vRcy0uGcVyXd(BSO4hu2GdO4qXpoQxa1g(HiRMRLtbaYtHtZ7LfdHfNtyS4ywmiwCMHABWbE5mDDD1NePVg6Mtoa)m(2zHFuW2aAE2o8IfpyHdlk(bLn4akou8JJ6fqTHFJWIJWIJWIJWIuyG8C8hqTaQRRwqswuVAnoHSyiS4xS4ywmiwCG8C8KvG0nPpiOiWKNuMfdJfjsKfPWa554pGAbuxxTGKSOE1ACczXqyrcMfdJfhZI8mD0uq5n5KBUjzf4rGK1LIfdHfjywmmwKirwKcdKNJ)aQfqDD1csYI6vRXjKfdHfdMfdJfhZI8mD0uq5nK0Kop6naOPGr9iqY6sXIIXIFJFgF7SWVdOwa11vRwutiGxS4bp)yrXpOSbhqXHIFCuVaQn8liwCMHABWbE5mDDD1NePVg6Mtoa)m(2zHFuW2aAE2o8Ix87cfGAowuS4bJff)GYgCafhk(Xr9cO2WVbYZXRiPuO00mL8iW4lloMfdIfNzO2gCGxotxxx9jr6RHU5KdyrIezrzy9xdDZjh4n(2Za8Z4BNf(rbBdO5z7Wlw85WIIFqzdoGIdf)4OEbuB4hISAUwofaipfonVxwmewm4VyXXS4iSipthnfuEto5MBswbEeizDPyrXyXVzrIezrkmqEo(dOwa11vlijlQxTgNqwumw8lwmmwCmlgeloZqTn4aVCMUUU6tI0xdDZjhGFgF7SWpkyBanpBhEXItWyrXpOSbhqXHIFCuVaQn8BnhuRxguB7GIdEOSbhqzXXSipthnfuEto5MBswbEeizDPWpJVDw4hfSnG2kQMcCBcVyX)clk(bLn4akou8JJ6fqTHF8mD0uq5n5KBUjzf4rGK1Lc)m(2zHFu40oaVyX)glk(bLn4akou8JJ6fqTHFJWIJWIuyG8C8hqTaQRRwqswupPmloMf5z6OPGYBYj3CtYkWJajRlflkgl(nlgglsKilsHbYZXFa1cOUUAbjzr9Q14eYIIXIFXIHXIJzrEMoAkO8gsAsNh9ga0uWOEeizDPyrXyXVXpJVDw4NINKOlOvlQjeWlwCHdlk(bLn4akou8JJ6fqTHFJWIJWIuyG8C8hqTaQRRwqswupPmloMf5z6OPGYBYj3CtYkWJajRlflkgl(nlgglsKilsHbYZXFa1cOUUAbjzr9Q14eYIIXIFXIHXIJzrEMoAkO8gsAsNh9ga0uWOEeizDPyrXyXVXpJVDw4h3zc66QvbmAkqHxS4Zpwu8dkBWbuCO4hh1lGAd)qKvZ1YPaa5PWP59YIHWIZjmwCmlgeloZqTn4aVCMUUU6tI0xdDZjhGFgF7SWpkyBanpBhEXItqWIIFqzdoGIdf)4OEbuB43iS4iS4iS4iSifgiph)bulG66QfKKf1RwJtilgcl(floMfdIfhiphpzfiDt6dckcm5jLzXWyrIezrkmqEo(dOwa11vlijlQxTgNqwmewKGzXWyXXSipthnfuEto5MBswbEeizDPyXqyrcMfdJfjsKfPWa554pGAbuxxTGKSOE1ACczXqyXGzXWyXXSipthnfuEdjnPZJEdaAkyupcKSUuSOyS434NX3ol87aQfqDD1Qf1ec4flobflk(bLn4akou8JJ6fqTHFbXIZmuBdoWlNPRRR(Ki91q3CYb4NX3ol8Jc2gqZZ2Hx8Ix8BgGuDwyXNtybtqfgbryem(jWqvxxf(npkjNOfOSOWXIgF7SyrxRwLN9b)Kr5PDa(nAwCEUcKUjwu4lyBawCEq13al7ZOzXa7kRg1cj0T3aKdEEkjKQLiD22zXr2zfs1sCHyFgnloQiVKQLfd(lryX5ewWeuwC(yX5e2OEU5N9H9z0S48oGvxqnQzFgnloFS4OIsbklk8Olklk8JaGaGN9z0S48XIZ7SMbOfOS4AOlS6(WI8SO92zPyXnzreCjDgIf5zr7TZs5zFgnloFS4lLawmL3wQjGTDwSyEyrHFqTasQVbwwSlwCuj8r41Z(W(mAwu4DEbCYfOS4aCseWI8uAWwwCaUDP8S4OIZb5vXIvwZxadjDiDSOX3olflMLBYZ(mAw04BNLYlJaEkny7)XzkczFgnlA8TZs5LrapLgSn8FHozszFgnlA8TZs5LrapLgSn8FHmYReuRTDwSpJMfFLjRcKllISMYIdKNdqzr1ARIfhGtIawKNsd2YIdWTlflAfLfLrW8jN721LfBflsZc8SpJMfn(2zP8YiGNsd2g(VqQYKvbYvRwBvSpgF7SuEzeWtPbBd)xi5C7SyFm(2zP8YiGNsd2g(VqiRvGMcgL9X4BNLYlJaEknyB4)crQaDVGKiLjb)gbubmKP0NSwDE0YPaaX(y8TZs5LrapLgSn8FHmK0Kop6naOPGrfHcoB6Fo2h2NrZIcVZlGtUaLfHzaAIf3wcyXnaWIgFtel2kw0MzTZgCGN9X4BNL6xQlQ(GaGaa7JX3olv4)cnZqTn4arktc(LZ011vFsK(AOBo5arMzos4NNPJMckVIuskl91q3CYbEeizDPc57XR5GA9ksjPS0xdDZjh4HYgCaL9z0SOWtgVnNsewCECbjLiSOvuwm3aaIfZlNQyFm(2zPc)xidXTc0BIqqTI0NFez1CTCkaqEkCAEVIjCFpEezy9xdDZjh4n(2ZaIedAnhuRxrkjLL(AOBo5apu2GdOHngrwGNcNM3Ry)FZ(y8TZsf(VqdUmP6djAsK(8ldR)AOBo5aVX3EgqKyqR5GA9ksjPS0xdDZjh4HYgCaL9X4BNLk8FHgaKcqe21vK(8pqEoEYkq6M0heueyYtktKOmS(RHU5Kd8gF7zarIbTMdQ1RiLKYsFn0nNCGhkBWbu2NrZIZBs1MsS4I6IqyvSiPYUa7JX3olv4)crQaDVGKsK(8VTei2CcJiXGGrHSLLbQhzsYDD1MKSRxskOV91MLUvd1TlGiXGGrHSLLbQFwR6S05rtbPwbSpgF7SuH)lePc09csIuMe8BQaZScuAKrGeP5jYCI0NFkmqEoEKrGeP5jYCAkmqEoE1ACcdjy2hJVDwQW)fIub6Ebjrktc(nvGzwbknYiqI08ezor6ZVmS(lPHOTv68OncaOCd4n(2ZaIehzG8C8KvG0nPpiOiWKNuECqGsbfh88SOqPaQ21h4Kio4HYgCanmIehHNPJMckVjNCZnjRapcKSUuHm3yEMoAkO8gsAsNh9ga0uWOEeizDPcHGfoHfg7JX3olv4)crQaDVGKiLjb)ZAvNLopAki1kqK(8pcpthnfuEto5MBswbEey0PXuyG8C8hqTaQRRwqswuVAnoHI9)1yqPGId(zTQZsNhTmGoaF7S8qzdoGggrIdKNJNScKUj9bbfbM8KYejkdR)AOBo5aVX3EgW(y8TZsf(VqKkq3lijszsWpYKK76QnjzxVKuqF7RnlDRgQBxGi95NNPJMckVjNCZnjRapcKSUuHmhrIR5GA9gsAsNh9ga0utQaQhkBWbuIerwt1WmOwVrPkFxH8n7JX3olv4)crQaDVGKiLjb)dt3Sa9aaAZjzLXfPp)8mD0uq5vKsszPVg6MtoWJajRlLycNWismO1CqTEfPKuw6RHU5Kd8qzdoGoEBjqS5egrIbbJczlldupYKK76QnjzxVKuqF7RnlDRgQBxa7JX3olv4)crQaDVGKiLjb)ZtGshif4aKi95xgw)1q3CYbEJV9mGiXGwZb16vKsszPVg6MtoWdLn4a64TLaXMtyejgemkKTSmq9itsURR2KKD9ssb9TV2S0TAOUDbSpgF7SuH)lePc09csIuMe8FnhWnNdqk9ayeksF(LH1Fn0nNCG34BpdismO1CqTEfPKuw6RHU5Kd8qzdoGoEBjqS5egrIbbJczlldupYKK76QnjzxVKuqF7RnlDRgQBxa7JX3olv4)crQaDVGKiLjb)xuwxLwg1sMtJSlisF(rKfeYpbpEKTLaXMtyejgemkKTSmq9itsURR2KKD9ssb9TV2S0TAOUDbHX(y8TZsf(VqY52zjsF(5z6OPGYBiPjDE0BaqtbJ6rGrNisugw)1q3CYbEJV9mGiXbYZXtwbs3K(GGIatEsz2NrZIcpSUwRRUUS48Wgr6GAzrHND2LeyXwXIglkJ6e17e7JX3olv4)cLK7acmcfPp)0C9ZAePdQvl7Slj4rGK1LkK)lNY(y8TZsf(VqCZ50gF7S0UwTIuMe8dkfuCqX(y8TZsf(VqCZ50gF7S0UwTIuMe8ZZ0rtbLI9X4BNLk8FHqKL24BNL21QvKYKGFlbr6ZVX3EgOHcKAqj2)CSpgF7SuH)le3CoTX3olTRvRiLjb)xOauZzFyFgnloQsHxweLRTDwSpgF7SuElHFkyBaTvunf42Ki95NNPJMckVjNCZnjRapcKSUuSpgF7SuElHW)fIcN2bSpgF7SuElHW)fcKBki1Cr6ZpfSnG2kQMcCBYVnNWUUJrKfeYCJdAMHABWbE5mDDD1NePVg6MtoG9X4BNLYBje(VquW2aAE2or6ZpfSnG2kQMcCBYVnNWUUJrKfeYCJdAMHABWbE5mDDD1NePVg6MtoG9X4BNLYBje(VqkEsIUGwTOMqqK(8tbBdOTIQPa3M8BZjSR7yEMoAkO8MCYn3KSc8iqY6sX(y8TZs5Tec)xiUZe01vRcy0uGsK(8tbBdOTIQPa3M8BZjSR7yEMoAkO8MCYn3KSc8iqY6sX(y8TZs5Tec)xiqUPGuZfPp)bnZqTn4aVCMUUU6tI0xdDZjhW(y8TZs5Tec)xOdOwa11vRwutiicFI7a9AOlSQ)GfPp)uyG8C8hqTaQRRwqswuVAnoHH8h8yEMoAkO8uW2aAROAkWTjpcKSUuSpgF7SuElHW)f6aQfqDD1Qf1ecI0N)1CqT(bsKA76QvjcuEOSbhqhRKbNtVg6cRYpqIuBxxTkrGsS)5gtHbYZXFa1cOUUAbjzr9Q14egYFWSpgF7SuElHW)fIc2gqZZ2jsF(hiphVIKsHstZuYJaJVJrKf4PWP59k2)xSpgF7SuElHW)fIc2gqZZ2jsF(hiphVIKsHstZuYJaJVJdAMHABWbE5mDDD1NePVg6MtoGirzy9xdDZjh4n(2Za2hJVDwkVLq4)crbBdO5z7ePp)iYQ5A5uaG8u408Edj4VgpcpthnfuEto5MBswbEeizDPe7BIePWa554pGAbuxxTGKSOE1ACcf7RWgh0md12Gd8Yz666QpjsFn0nNCa7JX3olL3si8FHu8KeDbTArnHGi95piLmcmAxxTGKSOQXJmcfgiph)bulG66QfKKf1tkpMNPJMckVjNCZnjRapcKSUuI9DyejsHbYZXFa1cOUUAbjzr9Q14ek2xHnMNPJMckVHKM05rVbanfmQhbswxkX(M9X4BNLYBje(VqCNjORRwfWOPaLi95piLmcmAxxTGKSOQXJmcfgiph)bulG66QfKKf1tkpMNPJMckVjNCZnjRapcKSUuI9DyejsHbYZXFa1cOUUAbjzr9Q14ek2xHnMNPJMckVHKM05rVbanfmQhbswxkX(M9X4BNLYBje(VquW2aAE2or6ZpISAUwofaipfonV3qMtyJdAMHABWbE5mDDD1NePVg6MtoG9X4BNLYBje(VqhqTaQRRwTOMqqK(8pYiJmcfgiph)bulG66QfKKf1RwJtyiFnoObYZXtwbs3K(GGIatEs5WisKcdKNJ)aQfqDD1csYI6vRXjmecoSX8mD0uq5n5KBUjzf4rGK1LkecomIePWa554pGAbuxxTGKSOE1ACcdj4WgZZ0rtbL3qst68O3aGMcg1JajRlLyFZ(y8TZs5Tec)xikyBanpBNi95pOzgQTbh4LZ011vFsK(AOBo5a2h2hJVDwkppthnfuQFdjnPZJEdaAkyu2hJVDwkppthnfuQW)fYKtU5MKvGi95NcdKNJ)aQfqDD1csYI6vRXjuS)VyFm(2zP88mD0uqPc)xiQHiuViRuNejzBNLi95piK1unmdQ1BuQYdZRwTkIerwt1WmOwVrPkFxIf83SpgF7SuEEMoAkOuH)lKIuskl91q3CYbI0NFez1CTCkaqEkCAEVHe8xSpgF7SuEEMoAkOuH)lezfiDt6dckcmjsF(bLcko4N1QolDE0Ya6a8TZYdLn4akrIuyG8C8hqTaQRRwqswuVAnoHH814GgbgfYwwgOEKjj31vBsYUEjPG(2xBw6wnu3UaIencaOEbVKDjv68O3aGMcg1dLn4aAyejYZ0rtbL3KtU5MKvGhbswxQqMB8iWOq2YYa1Jmj5UUAts21ljf03(AZs3QH62fqKOraa1l4LSlPsNh9ga0uWOEOSbhqdJ9X4BNLYZZ0rtbLk8FHiRaPBsFqqrGjr6ZVX3EgOHcKAqj2)CJhzeEMoAkO8uW2aAROAkWTjpcKSUuH8F50XbTMdQ1tHt7apu2GdOHrK4i8mD0uq5PWPDGhbswxQq(VC641CqTEkCAh4HYgCanSWyFm(2zP88mD0uqPc)xivs60iWKbKi8jUd0RHUWQ(dwK(8Vg6cRFBjqVPM2qieKXRHUW63wc0BQPni2xSpgF7SuEEMoAkOuH)lKkjDAeyYasK(8psqiRPAyguR3OuLhMxTAvejISMQHzqTEJsv(UeBoHf2yezbH8psWZ3a554jRaPBsFqqrGjpPCySpgF7SuEEMoAkOuH)lezfiDt6bxFdSSpSpgF7SuEqPGIdQFjqkrt68ODK8MQPiWKuI0NFezb(TLa9M6Gf7YPJrKvZ1YPaafYxcJ9X4BNLYdkfuCqf(VqdUmP68O3aGgkqAsK(8pcpthnfuEkyBaTvunf42KhbswxQXkzW50RHUWQ8uW2aAROAkWTjXcomIehHNPJMckpfoTd8iqY6snwjdoNEn0fwLNcN2bIfCyejocpthnfuEto5MBswbEeizDPgZZ0rtbLNc2gqBfvtbUn5rGrNcJ9X4BNLYdkfuCqf(VqxsdrBR05rBeaq5gqK(8ZZ0rtbL3KtU5MKvGhbswxQqeo2hJVDwkpOuqXbv4)cTbanznKKfvFsehePp)dKNJhbCcDGsPpjIdEszIehiphpc4e6aLsFseh08KSwa5vRXjmKGdM9X4BNLYdkfuCqf(VqNKtQaQ2iaG6f0dGjjsF(dIc2gqBfvtbUn53Mtyxx2hJVDwkpOuqXbv4)cXZId1ISfO6JZKar6ZpnxpploulYwGQpotc0dKOYJajRl1VWyFm(2zP8GsbfhuH)lKmjQptDD1dotTI0N)GOGTb0wr1uGBt(T5e21L9X4BNLYdkfuCqf(VqcsKJod6sJavwwXbr6ZFquW2aAROAkWTj)2Cc76Y(y8TZs5bLckoOc)xiull7aDxALSXbr6ZFquW2aAROAkWTj)2Cc76Y(W(y8TZs5VqbOM)tbBdO5z7ePp)dKNJxrsPqPPzk5rGX3XbnZqTn4aVCMUUU6tI0xdDZjhqKOmS(RHU5Kd8gF7za7JX3olL)cfGAE4)crbBdO5z7ePp)iYQ5A5uaG8u408Edj4VgpcpthnfuEto5MBswbEeizDPe7BIePWa554pGAbuxxTGKSOE1ACcf7RWgh0md12Gd8Yz666QpjsFn0nNCa7JX3olL)cfGAE4)crbBdOTIQPa3MePp)R5GA9YGABhuCWdLn4a6yEMoAkO8MCYn3KSc8iqY6sX(y8TZs5VqbOMh(Vqu40oqK(8ZZ0rtbL3KtU5MKvGhbswxk2hJVDwk)fka18W)fsXts0f0Qf1ecI0N)rgHcdKNJ)aQfqDD1csYI6jLhZZ0rtbL3KtU5MKvGhbswxkX(omIePWa554pGAbuxxTGKSOE1ACcf7RWgZZ0rtbL3qst68O3aGMcg1JajRlLyFZ(y8TZs5VqbOMh(VqCNjORRwfWOPaLi95FKrOWa554pGAbuxxTGKSOEs5X8mD0uq5n5KBUjzf4rGK1LsSVdJirkmqEo(dOwa11vlijlQxTgNqX(kSX8mD0uq5nK0Kop6naOPGr9iqY6sj23SpgF7Su(luaQ5H)lefSnGMNTtK(8JiRMRLtbaYtHtZ7nK5e24GMzO2gCGxotxxx9jr6RHU5KdyFm(2zP8xOauZd)xOdOwa11vRwutiisF(hzKrgHcdKNJ)aQfqDD1csYI6vRXjmKVgh0a554jRaPBsFqqrGjpPCyejsHbYZXFa1cOUUAbjzr9Q14egcbh2yEMoAkO8MCYn3KSc8iqY6sfcbhgrIuyG8C8hqTaQRRwqswuVAnoHHeCyJ5z6OPGYBiPjDE0BaqtbJ6rGK1LsSVzFm(2zP8xOauZd)xikyBanpBNi95pOzgQTbh4LZ011vFsK(AOBo5a8Zi3ajc)ETePZ2oR5nYolEXlgd]] )

end
