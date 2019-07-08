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


    spec:RegisterPack( "Unholy", 20190707.2250, [[dG0H(aqicvpsrjBsHAucvDkHkVsOywOuDlfLQDj4xOiddfvhti1Yui9muuAAQk6AQkSnff5Bkk04qrrNtOewNIcmpfI7PQAFOehurP0cfsEOIsXefkr6IOOqBuOe1jvuqTsfvVurbXnrrb2jHYpfkrmuuuqTuuuqEQknvukxvrrXwvuqAVq(lLgmvDyslwbpgvtgXLbBwv(SkgTqCArRwrrPxJsA2uCBISBj)wQHtuhxOKwoupNktxPRtW2vv67OW4vuuDEfz9cLA(eY(rAu0i2qxIUasSrzE0XcMpJmFgdJo6hJgn6UtYa6kRCw1dGULkbO7mtfPntORSozALGydDDTaMdOBKDLDZaMy6KBeHHaVLyYLscgDZU4y9Tm5sjotO7GqA2z4cnGUeDbKyJY8OJfmFgz(mggD0pgL5JIUozGJeB0pgfDJKecuOb0Laoo6olQFMPI0MjQpwkOBeQFgsLNilD(SO(i7k7MbmX0j3icdbElXKlLem6MDXX6BzYLsCMOZNf1pxWmr9Zi7u)Omp6yb1p7u)OJod(KzsNtNplQF2erRd4Mb05ZI6NDQF2siaH6zgKfH6JLXaeBiqNplQF2P(ztxFb8ceQFv8bwB(OEExKCZUCu)2upgocgft98Ui5MD5c05ZI6NDQ)2sa13YBkLXw3SlQVFuFSm4walLNil1Nf1pBJLWmgqxt6whIn0fCoO4GdXgsSOrSHUqPdgGGIcD54CbCQOlwOGWMsGDBB0uplu)HtO(XupwOsUvUzayQFeQ)tMJUkFZUqxjqQXt2(znc8KyjyqLCOfj2Oi2qxO0bdqqrHUCCUaov0nEQN3TH0mQab0nIvlILaCDkGbjnlh1pM6DYGXyxfFG1fiGUrSArSeGRtupluF0uFCuViruF8upVBdPzubc8sdeWGKMLJ6ht9ozWySRIpW6ce4LgG6zH6JM6JJ6fjI6JN65DBinJkOYnxntYoiGbjnlh1pM65DBinJkqaDJy1IyjaxNcyqjtuFCORY3Sl0DW0nX2p7gbSqbstOfjgZIydDHshmabff6YX5c4urxE3gsZOcQCZvZKSdcyqjtORY3Sl09iOysQLTFwn2aU3iOfj2Ni2qxO0bdqqrHUCCUaov0vCQNa6gXQfXsaUof2KZAwh0v5B2f6(AUGdiwn2aoxWoaQeArI9bIn0fkDWaeuuOlhNlGtfDj9g4DXHAX6ce7ZOsGDqaxbmiPz5O(FQN5ORY3Sl0L3fhQfRlqSpJkbOfj2mHydDHshmabff6YX5c4urxXPEcOBeRwelb46uytoRzDqxLVzxORSaoFtzDSdg1TOfj2mIydDHshmabff6YX5c4urxXPEcOBeRwelb46uytoRzDqxLVzxOlJgBiFHSSyW1LwCaTiXyMi2qxO0bdqqrHUCCUaov0vCQNa6gXQfXsaUof2KZAwh0v5B2f6ItzzdyZY6KvoGw0IUe4PcMfXgsSOrSHUkFZUqxPSi2hgGydOlu6GbiOOqlsSrrSHUqPdgGGIcDBz01bl6Q8n7cD)Q4uhma6(vnca6Y72qAgvWjij1L9O4tpzGagK0SCu)iu)hu)yQFvduBWjij1L9O4tpzGau6GbiO7xfBlvcqx5UnzDSVgBpk(0tgaTiXyweBOlu6GbiOOqxooxaNk6IfQKBLBgaoqGxYZL6zH6NPpO(XuF8uVmSHJIp9KbckFZVa1lse1lo1VQbQn4eKK6YEu8PNmqakDWaeQpoQFm1JfkiqGxYZL6z5N6)aDv(MDHUkMRfy3gJHArlsSprSHUqPdgGGIcD54CbCQORmSHJIp9KbckFZVa1lse1lo1VQbQn4eKK6YEu8PNmqakDWae0v5B2f6oy6MyFc4j0Ie7deBOlu6GbiOOqxooxaNk6oi8EbHksBMSpmuXEkiit9Ier9YWgok(0tgiO8n)cuViruV4u)QgO2GtqsQl7rXNEYabO0bdqqxLVzxO7aGDaM1SoOfj2mHydDHshmabff6YX5c4ur3nLaQNfQFuMt9Ier9It9qSkKYYajGvj5Sowvs2KRabSN8OFBZAH6KfGUkFZUqxbhyZfKCOfj2mIydDHshmabff6Q8n7cDXQKCwhRkjBYvGa2tE0VTzTqDYcqxooxaNk6Y72qAgvqLBUAMKDqadsAwoQFeQFuQxKiQFvduBqXst2(z3iGLOsfqcqPdgGq9Ier9ynjw4luBqjexilQFeQ)d0TujaDXQKCwhRkjBYvGa2tE0VTzTqDYcqlsmMjIn0fkDWaeuuORY3Sl0Dy60fyhaWQgjTuo6YX5c4urxE3gsZOcobjPUShfF6jdeWGKMLJ6zH6NjMt9Ier9It9RAGAdobjPUShfF6jdeGshmaH6ht9Bkbuplu)OmN6fjI6fN6HyviLLbsaRsYzDSQKSjxbcyp5r)2M1c1jlaDlvcq3HPtxGDaaRAK0s5OfjwSaXg6cLoyackk0v5B2f6oZcoBKMHbWOlhNlGtfDLHnCu8PNmqq5B(fOErIOEXP(vnqTbNGKux2JIp9KbcqPdgGq9JP(nLaQNfQFuMt9Ier9It9qSkKYYajGvj5Sowvs2KRabSN8OFBZAH6KfGULkbO7ml4SrAggaJwKyrZCeBOlu6GbiOOqxLVzxO7rnaxnga7SdGYk6YX5c4urxzydhfF6jdeu(MFbQxKiQxCQFvduBWjij1L9O4tpzGau6Gbiu)yQFtjG6zH6hL5uViruV4upeRcPSmqcyvsoRJvLKn5kqa7jp632SwOozbOBPsa6EudWvJbWo7aOSIwKyrhnIn0fkDWaeuuORY3Sl09G764SY4usnwSEa0LJZfWPIUyHcO(r(PEML6ht9Xt9Bkbuplu)OmN6fjI6fN6HyviLLbsaRsYzDSQKSjxbcyp5r)2M1c1jlG6JdDlvcq3dURJZkJtj1yX6bqlsSOhfXg6cLoyackk0LJZfWPIU8UnKMrfuS0KTF2ncyjGscyqjtuViruVmSHJIp9KbckFZVa1lse1pi8EbHksBMSpmuXEkiiJUkFZUqx5EZUqlsSOzweBOlu6GbiOOqxooxaNk6s6n8nXcgOwRSrpcqadsAwoQFKFQ)WjORY3Sl0Tf2bmOSIwKyr)jIn0fkDWaeuuORY3Sl0LRgJv5B2L1KUfDnPBTLkbOl4CqXbhArIf9hi2qxO0bdqqrHUkFZUqxUAmwLVzxwt6w01KU1wQeGU8UnKMr5qlsSONjeBOlu6GbiOOqxooxaNk6Q8n)cwOaPeCupl)u)OORY3Sl0fluwLVzxwt6w01KU1wQeGUAdOfjw0ZiIn0fkDWaeuuORY3Sl0LRgJv5B2L1KUfDnPBTLkbO7bkaNC0Iw0vgd8wAqxeBiXIgXg6Q8n7cDL7n7cDHshmabffArInkIn0v5B2f6I10bwcOe0fkDWaeuuOfjgZIydDHshmabff6saJoHUJIUkFZUqxflnz7NDJawcOe0Iw0L3TH0mkhInKyrJydDv(MDHUkwAY2p7gbSeqjOlu6GbiOOqlsSrrSHUqPdgGGIcD54CbCQOlbgeEVWdClGZ6yz0cfj4wLZk1ZYp1)j6Q8n7cDv5MRMjzhGwKymlIn0fkDWaeuuOlhNlGtfDfN6XAsSWxO2GsiUamZt36OErIOESMel8fQnOeIlKf1Zc1h9hORY3Sl0LOywTlwl3RXs6MDHwKyFIydDHshmabff6YX5c4urxSqLCRCZaWbc8sEUu)iuF0FIUkFZUqxNGKux2JIp9KbqlsSpqSHUqPdgGGIcD54CbCQOlbgeEVWdClGZ6yz0cfj4wLZk1pc1)j1pM6fN6JN6HyviLLbsaRsYzDSQKSjxbcyp5r)2M1c1jlG6fjI61yd4CHGKEeC2(z3iGLakjaLoyac1hh6Q8n7cDfQiTzY(Wqf7j0IeBMqSHUqPdgGGIcD54CbCQOlVBdPzubvU5Qzs2bbmiPz5O(rO(rP(XuF8upeRcPSmqcyvsoRJvLKn5kqa7jp632SwOozbuViruVgBaNleK0JGZ2p7gbSeqjbO0bdqO(4qxLVzxORqfPnt2hgQypHwKyZiIn0fkDWaeuuOlhNlGtfDv(MFbluGucoQNLFQFuQFm1hp1hp1Z72qAgvGa6gXQfXsaUofWGKMLJ6h5N6pCc1pM6fN6x1a1giWlnqakDWaeQpoQxKiQpEQN3TH0mQabEPbcyqsZYr9J8t9hoH6ht9RAGAde4LgiaLoyac1hh1hh6Q8n7cDfQiTzY(Wqf7j0IeJzIydDHshmabff6Q8n7cDDTGXIbvgWOlhNlGtfDxfFGnSPey32ssG6hH6zMu)yQFv8b2WMsGDBljbQNfQ)t0LpXnGDv8bwhsSOrlsSybIn0fkDWaeuuOlhNlGtfDJN6fN6XAsSWxO2GsiUamZt36OErIOESMel8fQnOeIlKf1Zc1pkZP(4O(XupwOaQFKFQpEQpAQF2P(bH3liurAZK9HHk2tbbzQpo0v5B2f66AbJfdQmGrlsSOzoIn0v5B2f6kurAZKDWKNil6cLoyackk0Iw0vBaXgsSOrSHUqPdgGGIcD54CbCQOlVBdPzubvU5Qzs2bbmiPz5qxLVzxOlb0nIvlILaCDcTiXgfXg6Q8n7cDjWlna6cLoyackk0IeJzrSHUqPdgGGIcD54CbCQOlb0nIvlILaCDkSjN1Sou)yQhlua1pc1pk1pM6fN6)Q4uhmqqUBtwh7RX2JIp9KbqxLVzxOliNeqk5Ofj2Ni2qxO0bdqqrHUCCUaov0La6gXQfXsaUof2KZAwhQFm1JfkG6hH6hL6ht9It9FvCQdgii3TjRJ91y7rXNEYaORY3Sl0La6gXY70GwKyFGydDHshmabff6YX5c4urxcOBeRwelb46uytoRzDO(XupVBdPzubvU5Qzs2bbmiPz5qxLVzxORJ3c4dyDlozfqlsSzcXg6cLoyackk0LJZfWPIUeq3iwTiwcW1PWMCwZ6q9JPEE3gsZOcQCZvZKSdcyqsZYHUkFZUqxUrzK1X6IOKMHdTiXMreBOlu6GbiOOqxooxaNk6ko1)vXPoyGGC3MSo2xJThfF6jdGUkFZUqxqojGuYrlsmMjIn0fkDWaeuuORY3Sl09bUfWzDSUfNScOlhNlGtfDjWGW7fEGBbCwhlJwOib3QCwP(r(P(OP(XupVBdPzubcOBeRwelb46uadsAwo0LpXnGDv8bwhsSOrlsSybIn0fkDWaeuuOlhNlGtfDx1a1ggeWUnRJ11yWfGshmaH6ht9ozWySRIpW6cdcy3M1X6Am4OEw(P(rP(XupbgeEVWdClGZ6yz0cfj4wLZk1pYp1hn6Q8n7cDFGBbCwhRBXjRaArIfnZrSHUqPdgGGIcD54CbCQO7GW7fCcecuws3sbmO8L6ht9yHcce4L8CPEw(P(prxLVzxOlb0nIL3PbTiXIoAeBOlu6GbiOOqxooxaNk6oi8EbNaHaLL0TuadkFP(XuV4u)xfN6GbcYDBY6yFn2Eu8PNma1lse1ldB4O4tpzGGY38lGUkFZUqxcOBelVtdArIf9Oi2qxO0bdqqrHUCCUaov0fluj3k3maCGaVKNl1pc1h9Nu)yQpEQN3TH0mQGk3C1mj7GagK0SCuplu)huVirupbgeEVWdClGZ6yz0cfj4wLZk1Zc1)j1hh1pM6fN6)Q4uhmqqUBtwh7RX2JIp9KbqxLVzxOlb0nIL3PbTiXIMzrSHUqPdgGGIcD54CbCQOR4uVtgdkjRJLrlueh1pM6JN6JN6jWGW7fEGBbCwhlJwOibbzQFm1Z72qAgvqLBUAMKDqadsAwoQNfQ)dQpoQxKiQNadcVx4bUfWzDSmAHIeCRYzL6zH6)K6JJ6ht98UnKMrfuS0KTF2ncyjGscyqsZYr9Sq9FGUkFZUqxhVfWhW6wCYkGwKyr)jIn0fkDWaeuuOlhNlGtfDfN6DYyqjzDSmAHI4O(XuF8uF8upbgeEVWdClGZ6yz0cfjiit9JPEE3gsZOcQCZvZKSdcyqsZYr9Sq9Fq9Xr9Ier9eyq49cpWTaoRJLrluKGBvoRuplu)NuFCu)yQN3TH0mQGILMS9ZUralbusadsAwoQNfQ)d0v5B2f6YnkJSowxeL0mCOfjw0FGydDHshmabff6YX5c4urxSqLCRCZaWbc8sEUu)iu)OmN6ht9It9FvCQdgii3TjRJ91y7rXNEYaORY3Sl0La6gXY70GwKyrpti2qxO0bdqqrHUCCUaov0nEQpEQpEQpEQNadcVx4bUfWzDSmAHIeCRYzL6hH6)K6ht9It9dcVxqOI0Mj7ddvSNccYuFCuVirupbgeEVWdClGZ6yz0cfj4wLZk1pc1ZSuFCu)yQN3TH0mQGk3C1mj7GagK0SCu)iupZs9Xr9Ier9eyq49cpWTaoRJLrluKGBvoRu)iuF0uFCu)yQN3TH0mQGILMS9ZUralbusadsAwoQNfQ)d0v5B2f6(a3c4Sow3Itwb0Iel6zeXg6cLoyackk0LJZfWPIUIt9FvCQdgii3TjRJ91y7rXNEYaORY3Sl0La6gXY70Gw0IUhOaCYrSHelAeBOlu6GbiOOqxooxaNk6oi8EbNaHaLL0TuadkFP(XuV4u)xfN6GbcYDBY6yFn2Eu8PNma1lse1ldB4O4tpzGGY38lGUkFZUqxcOBelVtdArInkIn0fkDWaeuuOlhNlGtfDXcvYTYndahiWl55s9Jq9r)j1pM6JN65DBinJkOYnxntYoiGbjnlh1Zc1)b1lse1tGbH3l8a3c4SowgTqrcUv5Ss9Sq9Fs9Xr9JPEXP(Vko1bdeK72K1X(AS9O4tpza0v5B2f6saDJy5DAqlsmMfXg6cLoyackk0LJZfWPIURAGAdYGBtduCiaLoyac1pM65DBinJkOYnxntYoiGbjnlh6Q8n7cDjGUrSArSeGRtOfj2Ni2qxO0bdqqrHUCCUaov0L3TH0mQGk3C1mj7GagK0SCORY3Sl0LaV0aOfj2hi2qxO0bdqqrHUCCUaov0nEQpEQNadcVx4bUfWzDSmAHIeeKP(XupVBdPzubvU5Qzs2bbmiPz5OEwO(pO(4OErIOEcmi8EHh4waN1XYOfksWTkNvQNfQ)tQpoQFm1Z72qAgvqXst2(z3iGLakjGbjnlh1Zc1)b6Q8n7cDD8waFaRBXjRaArInti2qxO0bdqqrHUCCUaov0nEQpEQNadcVx4bUfWzDSmAHIeeKP(XupVBdPzubvU5Qzs2bbmiPz5OEwO(pO(4OErIOEcmi8EHh4waN1XYOfksWTkNvQNfQ)tQpoQFm1Z72qAgvqXst2(z3iGLakjGbjnlh1Zc1)b6Q8n7cD5gLrwhRlIsAgo0IeBgrSHUqPdgGGIcD54CbCQOlwOsUvUza4abEjpxQFeQFuMt9JPEXP(Vko1bdeK72K1X(AS9O4tpza0v5B2f6saDJy5DAqlsmMjIn0fkDWaeuuOlhNlGtfDJN6JN6JN6JN6jWGW7fEGBbCwhlJwOib3QCwP(rO(pP(XuV4u)GW7feQiTzY(Wqf7PGGm1hh1lse1tGbH3l8a3c4SowgTqrcUv5Ss9Jq9ml1hh1pM65DBinJkOYnxntYoiGbjnlh1pc1ZSuFCuVirupbgeEVWdClGZ6yz0cfj4wLZk1pc1hn1hh1pM65DBinJkOyPjB)SBeWsaLeWGKMLJ6zH6)aDv(MDHUpWTaoRJ1T4KvaTiXIfi2qxO0bdqqrHUCCUaov0vCQ)RItDWab5UnzDSVgBpk(0tgaDv(MDHUeq3iwENg0Iw0IUFbSl7cj2Omp6ybZ)iAMzi6zIzrxgkUY64q3zyj5gVaH6NjQx5B2f1Bs36c05ORmUFPbq3zr9ZmvK2mr9XsbDJq9ZqQ8ezPZNf1hzxz3mGjMo5gryiWBjMCPKGr3SlowFltUuIZeD(SO(5cMjQFgzN6hL5rhlO(zN6hD0zWNmt6C68zr9ZMiADa3mGoFwu)St9ZwcbiupZGSiuFSmgGydb68zr9Zo1pB66lGxGq9RIpWAZh1Z7IKB2LJ63M6XWrWOyQN3fj3SlxGoFwu)St93wcO(wEtPm26MDr99J6JLb3cyP8ezP(SO(zBSeMXaDoD(SOEMXzoWfwGq9dWRXa1ZBPbDP(b4KLlq9ZwohKxh1xDn7ruS0tWq9kFZUCuFxMPaD(SOELVzxUGmg4T0GU)pJ6yLoFwuVY3Slxqgd8wAq3y(z61nHoFwuVY3Slxqgd8wAq3y(zsfosqT6MDrNplQ)wQSlsVupwtc1pi8EaH6DRUoQFaEngOEElnOl1paNSCuVweQxgdZUCVBwhQpDupPliqNplQx5B2LliJbElnOBm)m5kv2fPxRB11rNR8n7YfKXaVLg0nMFMK7n7Iox5B2LliJbElnOBm)mH10bwcOe6CLVzxUGmg4T0GUX8ZKILMS9ZUralbuc7eWOt)JsNtNplQNzCMdCHfiup8fWtu)Msa1VraQx5BJP(0r96xnn6Gbc05kFZUC)szrSpmaXgOZv(MD5I5NPVko1bdWEPsWVC3MSo2xJThfF6jdW(x1ia)8UnKMrfCcssDzpk(0tgiGbjnl3iFmEvduBWjij1L9O4tpzGau6Gbi05ZI6zgs5PACSt9ZWli5yN61Iq99gbWuFF4ehDUY3Slxm)mPyUwGDBmgQL989JfQKBLBgaoqGxYZLLz6JXXldB4O4tpzGGY38lisK4RAGAdobjPUShfF6jdeGshmajUXyHcce4L8Cz5)d6CLVzxUy(zAW0nX(eWtSNVFzydhfF6jdeu(MFbrIeFvduBWjij1L9O4tpzGau6Gbi05kFZUCX8Z0aGDaM1SoSNV)bH3liurAZK9HHk2tbbzrIKHnCu8PNmqq5B(fejs8vnqTbNGKux2JIp9KbcqPdgGqNplQF2i42wI6xCwScRJ6fC6bOZv(MD5I5NjbhyZfKCSNV)nLawgL5IejoeRcPSmqcyvsoRJvLKn5kqa7jp632SwOozb05kFZUCX8ZKGdS5csSxQe8Jvj5Sowvs2KRabSN8OFBZAH6KfWE((5DBinJkOYnxntYoiGbjnl3iJks0QgO2GILMS9ZUralrLkGeGshmarKiSMel8fQnOeIlK1iFqNR8n7YfZptcoWMliXEPsW)W0PlWoaGvnsAPC2Z3pVBdPzubNGKux2JIp9KbcyqsZYXYmXCrIeFvduBWjij1L9O4tpzGau6GbiJ3ucyzuMlsK4qSkKYYajGvj5Sowvs2KRabSN8OFBZAH6KfqNR8n7YfZptcoWMliXEPsW)ml4SrAggaZE((LHnCu8PNmqq5B(fejs8vnqTbNGKux2JIp9KbcqPdgGmEtjGLrzUirIdXQqkldKawLKZ6yvjztUceWEYJ(TnRfQtwaDUY3Slxm)mj4aBUGe7Lkb)h1aC1yaSZoakRSNVFzydhfF6jdeu(MFbrIeFvduBWjij1L9O4tpzGau6GbiJ3ucyzuMlsK4qSkKYYajGvj5Sowvs2KRabSN8OFBZAH6KfqNR8n7YfZptcoWMliXEPsW)b31XzLXPKASy9aSNVFSqbJ8ZSJJFtjGLrzUirIdXQqkldKawLKZ6yvjztUceWEYJ(TnRfQtwqC05kFZUCX8ZKCVzxSNVFE3gsZOckwAY2p7gbSeqjbmOKjrIKHnCu8PNmqq5B(fejAq49ccvK2mzFyOI9uqqMoFwupZanRvZkRd1pdnXcgOwQNzyJEeaQpDuVs9Y4SX5orNR8n7YfZptTWoGbLv2Z3pP3W3elyGATYg9iabmiPz5g5)Wj05kFZUCX8ZexngRY3SlRjDl7Lkb)GZbfhC05kFZUCX8ZexngRY3SlRjDl7Lkb)8UnKMr5OZv(MD5I5NjSqzv(MDznPBzVuj4xBG989R8n)cwOaPeCS8pkDUY3Slxm)mXvJXQ8n7YAs3YEPsW)bkaNC6C68zr9Z2MzK6X9QB2fDUY3SlxqB4Na6gXQfXsaUoXE((5DBinJkOYnxntYoiGbjnlhDUY3SlxqBiMFMiWlnaDUY3SlxqBiMFMa5KasjN989taDJy1IyjaxNcBYznRZySqbJm6yX)Q4uhmqqUBtwh7RX2JIp9KbOZv(MD5cAdX8Zeb0nIL3PH989taDJy1IyjaxNcBYznRZySqbJm6yX)Q4uhmqqUBtwh7RX2JIp9KbOZv(MD5cAdX8ZKJ3c4dyDlozfypF)eq3iwTiwcW1PWMCwZ6mM3TH0mQGk3C1mj7GagK0SC05kFZUCbTHy(zIBugzDSUikPz4ypF)eq3iwTiwcW1PWMCwZ6mM3TH0mQGk3C1mj7GagK0SC05kFZUCbTHy(zcKtciLC2Z3V4FvCQdgii3TjRJ91y7rXNEYa05kFZUCbTHy(z6bUfWzDSUfNScSZN4gWUk(aR7pA2Z3pbgeEVWdClGZ6yz0cfj4wLZ6i)rpM3TH0mQab0nIvlILaCDkGbjnlhDUY3SlxqBiMFMEGBbCwhRBXjRa757FvduByqa72SowxJbxakDWaKXozWySRIpW6cdcy3M1X6Am4y5F0Xeyq49cpWTaoRJLrluKGBvoRJ8hnDUY3SlxqBiMFMiGUrS8onSNV)bH3l4eieOSKULcyq57ySqbbc8sEUS8)jDUY3SlxqBiMFMiGUrS8onSNV)bH3l4eieOSKULcyq57yX)Q4uhmqqUBtwh7RX2JIp9Kbejsg2WrXNEYabLV5xGox5B2LlOneZpteq3iwENg2Z3pwOsUvUza4abEjp3rI(ZXXZ72qAgvqLBUAMKDqadsAwow(qKicmi8EHh4waN1XYOfksWTkNvw(mUXI)vXPoyGGC3MSo2xJThfF6jdqNR8n7Yf0gI5NjhVfWhW6wCYkWE((f3jJbLK1XYOfkIBC8XtGbH3l8a3c4SowgTqrccYJ5DBinJkOYnxntYoiGbjnlhlFeNireyq49cpWTaoRJLrluKGBvoRS8zCJ5DBinJkOyPjB)SBeWsaLeWGKMLJLpOZv(MD5cAdX8Ze3OmY6yDrusZWXE((f3jJbLK1XYOfkIBC8XtGbH3l8a3c4SowgTqrccYJ5DBinJkOYnxntYoiGbjnlhlFeNireyq49cpWTaoRJLrluKGBvoRS8zCJ5DBinJkOyPjB)SBeWsaLeWGKMLJLpOZv(MD5cAdX8Zeb0nIL3PH989JfQKBLBgaoqGxYZDKrz(yX)Q4uhmqqUBtwh7RX2JIp9KbOZv(MD5cAdX8Z0dClGZ6yDlozfypF)XhF8XtGbH3l8a3c4SowgTqrcUv5SoYNJfFq49ccvK2mzFyOI9uqqoorIiWGW7fEGBbCwhlJwOib3QCwhHzJBmVBdPzubvU5Qzs2bbmiPz5gHzJtKicmi8EHh4waN1XYOfksWTkN1rIoUX8UnKMrfuS0KTF2ncyjGscyqsZYXYh05kFZUCbTHy(zIa6gXY70WE((f)RItDWab5UnzDSVgBpk(0tgGoNox5B2LlW72qAgL7xXst2(z3iGLakHox5B2LlW72qAgLlMFMu5MRMjzhWE((jWGW7fEGBbCwhlJwOib3QCwz5)t6CLVzxUaVBdPzuUy(zIOywTlwl3RXs6MDXE((fhRjXcFHAdkH4cWmpDRtKiSMel8fQnOeIlKflr)bDUY3SlxG3TH0mkxm)m5eKK6YEu8PNma757hluj3k3maCGaVKN7ir)jDUY3SlxG3TH0mkxm)mjurAZK9HHk2tSNVFcmi8EHh4waN1XYOfksWTkN1r(CS4XdXQqkldKawLKZ6yvjztUceWEYJ(TnRfQtwGirASbCUqqspcoB)SBeWsaLeGshmajo6CLVzxUaVBdPzuUy(zsOI0Mj7ddvSNypF)8UnKMrfu5MRMjzheWGKMLBKrhhpeRcPSmqcyvsoRJvLKn5kqa7jp632SwOozbIePXgW5cbj9i4S9ZUralbusakDWaK4OZv(MD5c8UnKMr5I5NjHksBMSpmuXEI989R8n)cwOaPeCS8p644JN3TH0mQab0nIvlILaCDkGbjnl3i)hozS4RAGAde4LgiaLoyasCIefpVBdPzubc8sdeWGKMLBK)dNmEvduBGaV0abO0bdqIlo6CLVzxUaVBdPzuUy(zY1cglguzaZoFIBa7Q4dSU)OzpF)RIpWg2ucSBBjjmcZC8Q4dSHnLa72wscS8jDUY3SlxG3TH0mkxm)m5AbJfdQmGzpF)XlowtIf(c1gucXfGzE6wNirynjw4luBqjexilwgL5XngluWi)Xh9Spi8EbHksBMSpmuXEkiihhDUY3SlxG3TH0mkxm)mjurAZKDWKNilDoDUY3SlxaCoO4G7xcKA8KTFwJapjwcgujh757hluqytjWUTnAwoCYySqLCRCZaWJ8jZPZv(MD5cGZbfhCX8Z0GPBITF2ncyHcKMypF)XZ72qAgvGa6gXQfXsaUofWGKMLBStgmg7Q4dSUab0nIvlILaCDILOJtKO45DBinJkqGxAGagK0SCJDYGXyxfFG1fiWlnalrhNirXZ72qAgvqLBUAMKDqadsAwUX8UnKMrfiGUrSArSeGRtbmOKP4OZv(MD5cGZbfhCX8Z0rqXKulB)SASbCVrypF)8UnKMrfu5MRMjzheWGsMOZv(MD5cGZbfhCX8Z0R5coGy1yd4Cb7aOsSNVFXjGUrSArSeGRtHn5SM1Hox5B2LlaohuCWfZpt8U4qTyDbI9zujG989t6nW7Id1I1fi2NrLa7GaUcyqsZY9ZC6CLVzxUa4CqXbxm)mjlGZ3uwh7GrDl757xCcOBeRwelb46uytoRzDOZv(MD5cGZbfhCX8ZeJgBiFHSSyW1LwCG989lob0nIvlILaCDkSjN1So05kFZUCbW5GIdUy(zcNYYgWML1jRCG989lob0nIvlILaCDkSjN1So0505kFZUCHduao5)eq3iwENg2Z3)GW7fCcecuws3sbmO8DS4FvCQdgii3TjRJ91y7rXNEYaIejdB4O4tpzGGY38lqNR8n7Yfoqb4KhZpteq3iwENg2Z3pwOsUvUza4abEjp3rI(ZXXZ72qAgvqLBUAMKDqadsAwow(qKicmi8EHh4waN1XYOfksWTkNvw(mUXI)vXPoyGGC3MSo2xJThfF6jdqNR8n7Yfoqb4KhZpteq3iwTiwcW1j2Z3)QgO2Gm420afhcqPdgGmM3TH0mQGk3C1mj7GagK0SC05kFZUCHduao5X8ZebEPbypF)8UnKMrfu5MRMjzheWGKMLJox5B2LlCGcWjpMFMC8waFaRBXjRa757p(4jWGW7fEGBbCwhlJwOibb5X8UnKMrfu5MRMjzheWGKMLJLpItKicmi8EHh4waN1XYOfksWTkNvw(mUX8UnKMrfuS0KTF2ncyjGscyqsZYXYh05kFZUCHduao5X8Ze3OmY6yDrusZWXE((JpEcmi8EHh4waN1XYOfksqqEmVBdPzubvU5Qzs2bbmiPz5y5J4ejIadcVx4bUfWzDSmAHIeCRYzLLpJBmVBdPzubflnz7NDJawcOKagK0SCS8bDUY3Slx4afGtEm)mraDJy5DAypF)yHk5w5MbGde4L8ChzuMpw8Vko1bdeK72K1X(AS9O4tpza6CLVzxUWbkaN8y(z6bUfWzDSUfNScSNV)4Jp(4jWGW7fEGBbCwhlJwOib3QCwh5ZXIpi8EbHksBMSpmuXEkiihNireyq49cpWTaoRJLrluKGBvoRJWSXnM3TH0mQGk3C1mj7GagK0SCJWSXjsebgeEVWdClGZ6yz0cfj4wLZ6irh3yE3gsZOckwAY2p7gbSeqjbmiPz5y5d6CLVzxUWbkaN8y(zIa6gXY70WE((f)RItDWab5UnzDSVgBpk(0tgaDvHnsJr3Bkjy0n7A2G13Iw0Iqa]] )

end
