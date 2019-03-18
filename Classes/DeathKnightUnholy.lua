-- DeathKnightUnholy.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

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

                    local slot_time = now + offset
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
            duration = 21,
            tick_time = function () return 3 * haste end,
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

            handler = function ()
                applyDebuff( "target", "outbreak" )
                applyDebuff( "target", "virulent_plague", talent.ebon_fever.enabled and 10.5 or 21 )
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

            --[[ 20181230:  Remove Festering Wounds requirement, improves AOE.
            usable = function ()
                if debuff.festering_wound.down then return false, "requires festering_wound" end
                return true
            end, ]]
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

        potion = "battle_potion_of_strength",

        package = "Unholy",
    } )

    spec:RegisterPack( "Unholy", 20190317.2041, [[dC0M3aqiQepsLQSjvWOOs1PKs8kPKMfrQBjLI2fP(LkLHrK4yuPSmQKEMuQmnvQCnviBtkv5BQqLXPsv15uPQSoPuW8OI6EiyFOchufQQfsf5HsPunrPuvUOukHnkLcXjLsjALQeVufQYnLsv1orLAOejXsjsspvvnvurxvkLYwLsH0EH8xbdMQomLflfpMKjJYLbBwv(SunAQWPLSAPuOEnQKzt42OQDR43IgorDCIKA5q9CHMUsxhrBxL03rOXlLs68QO1RcL5te7hPrUH4e9z2ciUDvkUDFsPDUDCAxLYDU5A7q)9ugqFztXL1b0FmEa9BBJJuCI(Y2PingIt0pMKyfG(o2vo2gUDdBe19ADq2qgbSkNfMvRs(BXINuyBLJcBV9wS4v3AEwBYGR3KX5Req8MubdsvRyXBsfPAO9b26iC8MQ7ydTTXrko1XIxH(nKLyBlhud6ZSfqC7QuC7(Ks7C740UkL7CZv0pkdke3UEKROVJIXGb1G(miQq)7r9TTXrkoP(2hyRdQ)4nv3XsVCpQ3XUYX2WTB9ADq2Ovj)TyXtkSTYrHT3Elw8QBnIS5wZZAtgC9MmoFLaI3KkyqQAflEtQivdTpWwhHJ3uDhBOTnosXPow8k6L7r9TFdRCq9UDCst9Ukf3UFQVnPExLsBOD3h9c9Y9O(2UdB6qSnqVCpQVnP(JpJbmQV9xdJ6BJGb4yGME5EuFBs9T9CUc4fyu)A4oSH6r9QCy1w5eP(nPEm0jfgM6v5WQTYjQrFrf3iIt0VddGlfIte3UH4e9HXAead5e6RW1c4Yq)gY3thjzmycSm51yWul1FG6DH6VA4YAeGwotrn9WlXHUH75PaOEjsOEzy1Dd3ZtbOn1wxb03uBLd6ZaBDeuzjqlIBxrCI(WyncGHCc9v4AbCzOpMCkvqojcyndELQwQ3zQ3T7O(duV7uVktbljoAtovM4uocAmWB1ePEoO(JOEjsOEg0q(E6hexaxtpqmjhMoUMIlQNdQ)oQVfQ)a17c1F1WL1iaTCMIA6HxIdDd3ZtbG(MARCqFgyRJGklbArC3oeNOpmwJayiNqFfUwaxg6VMaMvldXTeWOanmwJayu)bQxLPGLehTjNktCkhbng4TAIOVP2kh0Nb26iydlWaLDIwe33H4e9HXAead5e6RW1c4YqFvMcwsC0MCQmXPCe0yG3QjI(MARCqFg8kbGwe3hH4e9HXAead5e6RW1c4YqF3PE3PEg0q(E6hexaxtpqmjhMMuM6pq9QmfSK4On5uzIt5iOXaVvtK65G6pI6BH6LiH6zqd57PFqCbCn9aXKCy64AkUOEoO(7O(wO(duVktbljoAdZFgYxyDabgymng4TAIuphu)rOVP2kh0pQssChcXfxCbOfXD7H4e9HXAead5e6RW1c4YqF3PE3PEg0q(E6hexaxtpqmjhMMuM6pq9QmfSK4On5uzIt5iOXaVvtK65G6pI6BH6LiH6zqd57PFqCbCn9aXKCy64AkUOEoO(7O(wO(duVktbljoAdZFgYxyDabgymng4TAIuphu)rOVP2kh0xjmI10drhgljgrlI7JdXj6dJ1iagYj0xHRfWLH(yYPub5KiG1m4vQAPENPExLc1FG6DH6VA4YAeGwotrn9WlXHUH75PaqFtTvoOpdS1rqLLaTiUVFeNOpmwJayiNqFfUwaxg67o17o17o17o1ZGgY3t)G4c4A6bIj5W0X1uCr9ot93r9hOExO(gY3ttoosXz4HH5yNAszQVfQxIeQNbnKVN(bXfW10detYHPJRP4I6DM6Bh13c1FG6vzkyjXrBYPYeNYrqJbERMi17m13oQVfQxIeQNbnKVN(bXfW10detYHPJRP4I6DM6DJ6BH6pq9QmfSK4Onm)ziFH1beyGX0yG3Qjs9Cq9hH(MARCq)hexaxtpexCXfGwe33hIt0hgRramKtOVcxlGld9DH6VA4YAeGwotrn9WlXHUH75PaqFtTvoOpdS1rqLLaTOf9zWZiflIte3UH4e9n1w5G(81WcpmahdqFySgbWqoHwe3UI4e9HXAead5e6F1eKa6RYuWsIJosYZNtOB4EEkang4TAIuVZu)ru)bQFnbmRosYZNtOB4EEkanmwJayOVP2kh0)QHlRraO)vdhgJhqF5mf10dVeh6gUNNcaTiUBhIt0hgRramKtOVcxlGld9XKtPcYjraRzWRu1s9Cq9T3ru)bQ3DQxLPGLehDKKNpNq3W98uaAmWB1ePEjsOExO(1eWS6ijpFoHUH75Pa0WyncGr9Tq9hOEm5aAg8kvTupheO(JqFtTvoOVHv2aHnXyyw0I4(oeNOpmwJayiNqFfUwaxg6ldRUB4EEkaTP26kq9sKq9Uq9RjGz1rsE(CcDd3ZtbOHXAead9n1w5G(nImzHhj(eTiUpcXj6dJ1iagYj0xHRfWLH(YWQ7gUNNcqBQTUcuVejuVlu)AcywDKKNpNq3W98uaAySgbWqFtTvoOFdGJaMRA6OfXD7H4e9HXAead5e6RW1c4Yq)T4bQNdQ3vPq9sKq9Uq9GutwYYatJnE5A6bJxwuljdc9QBxtXgGPxdG(MARCqFYieQf4JOfX9XH4e9HXAead5e6BQTYb9XgVCn9GXllQLKbHE1TRPydW0RbqFfUwaxg6RYuWsIJ2KtLjoLJGgd8wnrQ3zQ3vQxIeQFnbmR2W8NH8fwhqGz8dW0WyncGr9sKq9yRyb4kmR2ySOUgQ3zQ)i0FmEa9XgVCn9GXllQLKbHE1TRPydW0RbqlI77hXj6dJ1iagYj03uBLd63C2ZbcnaembVnMc9v4AbCzOVktbljo6ijpFoHUH75Pa0yG3Qjs9Cq9TNuOEjsOExO(1eWS6ijpFoHUH75Pa0WyncGr9hO(T4bQNdQ3vPq9sKq9Uq9GutwYYatJnE5A6bJxwuljdc9QBxtXgGPxdG(JXdOFZzphi0aqWe82yk0I4((qCI(WyncGHCc9n1w5G(TXqm4ijkam6RW1c4YqFzy1Dd3ZtbOn1wxbQxIeQ3fQFnbmRosYZNtOB4EEkanmwJayu)bQFlEG65G6DvkuVejuVlupi1KLSmW0yJxUMEW4Lf1sYGqV621uSby61aO)y8a63gdXGJKOaWOfXTBsbXj6dJ1iagYj03uBLd63nbOmHaWXqdyCH(kCTaUm0xgwD3W98uaAtT1vG6LiH6DH6xtaZQJK885e6gUNNcqdJ1iag1FG63IhOEoOExLc1lrc17c1dsnzjldmn24LRPhmEzrTKmi0RUDnfBaMEna6pgpG(DtaktiaCm0agxOfXTBUH4e9HXAead5e6BQTYb974C6XGmU4nraBDa9v4AbCzOpMCaQ3zcuF7O(duV7u)w8a1Zb17QuOEjsOExOEqQjlzzGPXgVCn9GXllQLKbHE1TRPydW0RbO(wq)X4b0VJZPhdY4I3ebS1b0I42nxrCI(WyncGHCc9v4AbCzOVktbljoAdZFgYxyDabgymngm2j1lrc1ldRUB4EEkaTP26kq9sKq9nKVNMCCKIZWddZXo1KYOVP2kh0xo3kh0I42T2H4e9HXAead5e6RW1c4YqFwU6RfMuaZgKfwNe0yG3Qjs9otG67kg6BQTYb9tYTbdgxOfXTB3H4e9HXAead5e6BQTYb9vMqem1w5eevCrFrf3Wy8a6RYuWsIteTiUD7ieNOpmwJayiNqFfUwaxg6BQTUcbya(cIupheOExrFtTvoOpMCcMARCcIkUOVOIBymEa9TeqlIB3ApeNOpmwJayiNqFtTvoOVYeIGP2kNGOIl6lQ4ggJhq)omaUuOfTOVmgujFJTiorC7gIt0hgRramKtOfXTRiorFySgbWqoHwe3TdXj6dJ1iagYj0I4(oeNOpmwJayiNqlI7JqCI(MARCqF5CRCqFySgbWqoHwe3ThIt03uBLd6JTkcbgym0hgRramKtOfX9XH4e9HXAead5e6ZaHDI(UI(MARCqFdZFgYxyDabgym0Iw0xLPGLeNiIte3UH4e9n1w5G(gM)mKVW6acmWyOpmwJayiNqlIBxrCI(WyncGHCc9v4AbCzOpdAiFp9dIlGRPhiMKdthxtXf1ZbbQ)o03uBLd6BYPYeNYraTiUBhIt0hgRramKtOVcxlGld9DH6XwXcWvywTXyrn0wR4gPEjsOESvSaCfMvBmwuxd1Zb172rOVP2kh0NzyUcl2M4lX82w5Gwe33H4e9HXAead5e6RW1c4YqFm5uQGCseWAg8kvTuVZuVB3H(MARCq)ijpFoHUH75PaqlI7JqCI(WyncGHCc9v4AbCzOpdAiFp9dIlGRPhiMKdthxtXf17m1Fh1FG6DH6DN6bPMSKLbMgB8Y10dgVSOwsge6v3UMInatVgG6LiH6TJb4AbnV1jJH8fwhqGbgtdJ1iag13c6BQTYb9jhhP4m8WWCSt0I4U9qCI(WyncGHCc9v4AbCzOVktbljoAtovM4uocAmWB1ePENPExP(duV7upi1KLSmW0yJxUMEW4Lf1sYGqV621uSby61auVejuVDmaxlO5TozmKVW6acmWyAySgbWO(wqFtTvoOp54ifNHhgMJDIwe3hhIt0hgRramKtOVcxlGld9n1wxHamaFbrQNdcuVRu)bQ3DQ3DQxLPGLehndS1rWgwGbk7uJbERMi17mbQVRyu)bQ3fQFnbmRMbVsaAySgbWO(wOEjsOE3PEvMcwsC0m4vcqJbERMi17mbQVRyu)bQFnbmRMbVsaAySgbWO(wO(wqFtTvoOp54ifNHhgMJDIwe33pIt0hgRramKtOVcxlGld9xd3HvVfpe2mWkG6DM6VFQ)a1VgUdRElEiSzGva1Zb1Fh6BQTYb9JjPiGbtgWOfX99H4e9HXAead5e6RW1c4YqF3PExOESvSaCfMvBmwudT1kUrQxIeQhBflaxHz1gJf11q9Cq9UkfQVfQ)a1JjhG6DMa17o17g13MuFd57PjhhP4m8WWCStnPm13c6BQTYb9JjPiGbtgWOfXTBsbXj6BQTYb9jhhP4m0iQUJf9HXAead5eArl6BjG4eXTBiorFySgbWqoH(kCTaUm0xLPGLehTjNktCkhbng4TAIOVP2kh0Nb26iydlWaLDIwe3UI4e9n1w5G(m4vca9HXAead5eArC3oeNOpmwJayiNqFfUwaxg6ZaBDeSHfyGYo1BP4QMo1FG6XKdq9ot9Us9hOExO(RgUSgbOLZuutp8sCOB4EEka03uBLd6dYfd4lfArCFhIt0hgRramKtOVcxlGld9zGToc2WcmqzN6TuCvtN6pq9yYbOENPExP(duVlu)vdxwJa0YzkQPhEjo0nCppfa6BQTYb9zGTocQSeOfX9riorFySgbWqoH(kCTaUm0Nb26iydlWaLDQ3sXvnDQ)a1RYuWsIJ2KtLjoLJGgd8wnr03uBLd6hvjjUdH4IlUa0I4U9qCI(WyncGHCc9v4AbCzOpdS1rWgwGbk7uVLIRA6u)bQxLPGLehTjNktCkhbng4TAIOVP2kh0xjmI10drhgljgrlI7JdXj6dJ1iagYj0xHRfWLH(Uq9xnCzncqlNPOME4L4q3W98uaOVP2kh0hKlgWxk0I4((rCI(WyncGHCc9v4AbCzOpdAiFp9dIlGRPhiMKdthxtXf17mbQ3nQ)a1RYuWsIJMb26iydlWaLDQXaVvte9n1w5G(piUaUMEiU4IlaTiUVpeNOpmwJayiNqFfUwaxg6VMaMv3qIJBn9qmXqudJ1iag1FG6JYGqewd3HnQBiXXTMEiMyis9CqG6DL6pq9mOH890piUaUMEGysomDCnfxuVZeOE3qFtTvoO)dIlGRPhIlU4cqlIB3KcIt0hgRramKtOVcxlGld9BiFpDKKXGjWYKxJbtTu)bQhtoGMbVsvl1ZbbQ)o03uBLd6ZaBDeuzjqlIB3CdXj6dJ1iagYj0xHRfWLH(nKVNosYyWeyzYRXGPwQ)a17c1F1WL1iaTCMIA6HxIdDd3Ztbq9sKq9YWQ7gUNNcqBQTUcOVP2kh0Nb26iOYsGwe3U5kIt0hgRramKtOVcxlGld9XKtPcYjraRzWRu1s9ot9UDh1FG6DN6vzkyjXrBYPYeNYrqJbERMi1Zb1Fe1lrc1ZGgY3t)G4c4A6bIj5W0X1uCr9Cq93r9Tq9hOExO(RgUSgbOLZuutp8sCOB4EEka03uBLd6ZaBDeuzjqlIB3AhIt0hgRramKtOVcxlGld9DN6DN6zqd57PFqCbCn9aXKCyAszQ)a1RYuWsIJ2KtLjoLJGgd8wnrQNdQ)iQVfQxIeQNbnKVN(bXfW10detYHPJRP4I65G6VJ6BH6pq9QmfSK4Onm)ziFH1beyGX0yG3Qjs9Cq9hH(MARCq)OkjXDiexCXfGwe3UDhIt0hgRramKtOVcxlGld9DN6DN6zqd57PFqCbCn9aXKCyAszQ)a1RYuWsIJ2KtLjoLJGgd8wnrQNdQ)iQVfQxIeQNbnKVN(bXfW10detYHPJRP4I65G6VJ6BH6pq9QmfSK4Onm)ziFH1beyGX0yG3Qjs9Cq9hH(MARCqFLWiwtpeDySKyeTiUD7ieNOpmwJayiNqFfUwaxg6JjNsfKtIawZGxPQL6DM6Dvku)bQ3fQ)QHlRraA5mf10dVeh6gUNNca9n1w5G(mWwhbvwc0I42T2dXj6dJ1iagYj0xHRfWLH(Ut9Ut9Ut9Ut9mOH890piUaUMEGysomDCnfxuVZu)Du)bQ3fQVH890KJJuCgEyyo2PMuM6BH6LiH6zqd57PFqCbCn9aXKCy64AkUOENP(2r9Tq9hOEvMcwsC0MCQmXPCe0yG3Qjs9ot9TJ6BH6LiH6zqd57PFqCbCn9aXKCy64AkUOENPE3O(wO(duVktbljoAdZFgYxyDabgymng4TAIuphu)rOVP2kh0)bXfW10dXfxCbOfXTBhhIt0hgRramKtOVcxlGld9DH6VA4YAeGwotrn9WlXHUH75PaqFtTvoOpdS1rqLLaTOfTO)vahRCqC7QuC7(KIRU2EAxBNBOprdp10JOFBjVCIxGr9hr9MARCOErf3OMEb9LX5Rea6FpQVTnosXj13(aBDq9hVP6ow6L7r9o2vo2gUDRxRdYgTk5VflEsHTvokS92BXIxDRrKn3AEwBYGR3KX5Req8MubdsvRyXBsfPAO9b26iC8MQ7ydTTXrko1XIxrVCpQV9ByLdQ3TJtAQ3vP429t9Tj17QuAdT7(OxOxUh132DythITb6L7r9Tj1F8zmGr9T)AyuFBemahd00l3J6BtQVTNZvaVaJ6xd3HnupQxLdR2kNi1Vj1JHoPWWuVkhwTvorn9c9Y9O(2I2kOixGr9nWlXa1Rs(gBP(gOxtut9hFLcK3i1p50Momm)Juq9MARCIuFoItn9IP2kNOwgdQKVXwcpHf5IEXuBLtulJbvY3yBReU9YKrVyQTYjQLXGk5BSTvc3mYopmRTvo0l3J6)JjhDKl1JTIr9nKVhWO(4ABK6BGxIbQxL8n2s9nqVMi1BdJ6LXqBkN7wtN6Ri1ZYb00lMARCIAzmOs(gBBLWT4yYrh5gIRTr6ftTvorTmgujFJTTs4MCUvo0lMARCIAzmOs(gBBLWnSvriWaJrVyQTYjQLXGk5BSTvc3mm)ziFH1beyGXKMbc7KGR0l0l3J6BlARGICbg1dxb8j1Vfpq9RdG6n1MyQVIuVD1kH1ian9IP2kNib(AyHhgGJb0lMARCITs42vdxwJaKEmEGGCMIA6HxIdDd3Ztbi9vtqceuzkyjXrhj55Zj0nCppfGgd8wnrNp6WAcywDKKNpNq3W98uaAySgbWOxUh1lvnvzIO0uFB5c8rPPEByuFUoam1NDflsVyQTYj2kHBgwzde2eJHzLUEeWKtPcYjraRzWRu1Yr7D0b3vzkyjXrhj55Zj0nCppfGgd8wnrjsCznbmRosYZNtOB4EEkanmwJayTCatoGMbVsvlheoIEXuBLtSvc3AezYcps8P01JGmS6UH75Pa0MARRGejUSMaMvhj55Zj0nCppfGggRram6ftTvoXwjCRbWraZvnDPRhbzy1Dd3ZtbOn1wxbjsCznbmRosYZNtOB4EEkanmwJay0l3J6B7KXn5P(fxdxWgPEYO1b6ftTvoXwjCJmcHAb(O01JWw8ahUkfjsCbKAYswgyASXlxtpy8YIAjzqOxD7Ak2am9Aa6ftTvoXwjCJmcHAbEPhJhiGnE5A6bJxwuljdc9QBxtXgGPxdiD9iOYuWsIJ2KtLjoLJGgd8wnrNDvIK1eWSAdZFgYxyDabMXpatdJ1iaMejyRyb4kmR2ySOUgNpIEXuBLtSvc3iJqOwGx6X4bcnN9CGqdabtWBJPKUEeuzkyjXrhj55Zj0nCppfGgd8wnroApPirIlRjGz1rsE(CcDd3ZtbOHXAea7Ww8ahUkfjsCbKAYswgyASXlxtpy8YIAjzqOxD7Ak2am9Aa6ftTvoXwjCJmcHAbEPhJhi0gdXGJKOaWsxpcYWQ7gUNNcqBQTUcsK4YAcywDKKNpNq3W98uaAySgbWoSfpWHRsrIexaPMSKLbMgB8Y10dgVSOwsge6v3UMInatVgGEXuBLtSvc3iJqOwGx6X4bcDtaktiaCm0agxsxpcYWQ7gUNNcqBQTUcsK4YAcywDKKNpNq3W98uaAySgbWoSfpWHRsrIexaPMSKLbMgB8Y10dgVSOwsge6v3UMInatVgGEXuBLtSvc3iJqOwGx6X4bcDCo9yqgx8MiGToiD9iGjhWzcT7G7BXdC4QuKiXfqQjlzzGPXgVCn9GXllQLKbHE1TRPydW0RbAHEXuBLtSvc3KZTYr66rqLPGLehTH5pd5lSoGadmMgdg7uIezy1Dd3ZtbOn1wxbjsAiFpn54ifNHhgMJDQjLPxUh13(TAwRMA6uFB0ctkGzPEPIW6Ka1xrQ3OEzCL4ApPxm1w5eBLWTKCBWGXL0RH7WgQhbwU6RfMuaZgKfwNe0yG3Qj6mHUIrVyQTYj2kHBkticMARCcIkUspgpqqLPGLeNi9IP2kNyReUHjNGP2kNGOIR0JXdeSeKUEem1wxHamaFbroi4k9IP2kNyReUPmHiyQTYjiQ4k9y8aHomaUu0l0l3J6p(zBb1JZ12kh6ftTvorTLabgyRJGnSadu2P01JGktbljoAtovM4uocAmWB1ePxm1w5e1wcTs4gdELaOxm1w5e1wcTs4gixmGVusxpcmWwhbBybgOSt9wkUQPFatoGZUEWLRgUSgbOLZuutp8sCOB4EEka6ftTvorTLqReUXaBDeuzjKUEeyGToc2WcmqzN6TuCvt)aMCaND9GlxnCzncqlNPOME4L4q3W98ua0lMARCIAlHwjClQssChcXfxCbsxpcmWwhbBybgOSt9wkUQPFqLPGLehTjNktCkhbng4TAI0lMARCIAlHwjCtjmI10drhgljgLUEeyGToc2WcmqzN6TuCvt)GktbljoAtovM4uocAmWB1ePxm1w5e1wcTs4gixmGVusxpcUC1WL1iaTCMIA6HxIdDd3ZtbqVyQTYjQTeALWThexaxtpexCXfiD9iWGgY3t)G4c4A6bIj5W0X1uC5mb3oOYuWsIJMb26iydlWaLDQXaVvtKEXuBLtuBj0kHBpiUaUMEiU4Ilq66rynbmRUHeh3A6HyIHOggRraSdrzqicRH7Wg1nK44wtpetme5GGRhyqd57PFqCbCn9aXKCy64AkUCMGB0lMARCIAlHwjCJb26iOYsiD9i0q(E6ijJbtGLjVgdMApGjhqZGxPQLdc3rVyQTYjQTeALWngyRJGklH01Jqd57PJKmgmbwM8AmyQ9GlxnCzncqlNPOME4L4q3W98uasKidRUB4EEkaTP26kqVyQTYjQTeALWngyRJGklH01JaMCkvqojcyndELQwND7UdURYuWsIJ2KtLjoLJGgd8wnroosIeg0q(E6hexaxtpqmjhMoUMIloURLdUC1WL1iaTCMIA6HxIdDd3ZtbqVyQTYjQTeALWTOkjXDiexCXfiD9i4U7mOH890piUaUMEGysomnP8bvMcwsC0MCQmXPCe0yG3QjYXrTircdAiFp9dIlGRPhiMKdthxtXfh31YbvMcwsC0gM)mKVW6acmWyAmWB1e54i6ftTvorTLqReUPegXA6HOdJLeJsxpcU7odAiFp9dIlGRPhiMKdttkFqLPGLehTjNktCkhbng4TAICCulsKWGgY3t)G4c4A6bIj5W0X1uCXXDTCqLPGLehTH5pd5lSoGadmMgd8wnrooIEXuBLtuBj0kHBmWwhbvwcPRhbm5uQGCseWAg8kvTo7Quo4YvdxwJa0YzkQPhEjo0nCppfa9IP2kNO2sOvc3EqCbCn9qCXfxG01JG7U7U7mOH890piUaUMEGysomDCnfxoF3bxAiFpn54ifNHhgMJDQjLBrIeg0q(E6hexaxtpqmjhMoUMIlNBxlhuzkyjXrBYPYeNYrqJbERMOZTRfjsyqd57PFqCbCn9aXKCy64AkUC2TwoOYuWsIJ2W8NH8fwhqGbgtJbERMihhrVyQTYjQTeALWngyRJGklH01JGlxnCzncqlNPOME4L4q3W98ua0l0lMARCIAvMcwsCIemm)ziFH1beyGXOxm1w5e1QmfSK4eBLWntovM4uocsxpcmOH890piUaUMEGysomDCnfxCq4o6ftTvorTktbljoXwjCJzyUcl2M4lX82w5iD9i4c2kwaUcZQnglQH2Af3OejyRyb4kmR2ySOUgoC7i6ftTvorTktbljoXwjClsYZNtOB4EEkaPRhbm5uQGCseWAg8kvTo72D0lMARCIAvMcwsCITs4g54ifNHhgMJDkD9iWGgY3t)G4c4A6bIj5W0X1uC58DhCXDqQjlzzGPXgVCn9GXllQLKbHE1TRPydW0RbKiXogGRf08wNmgYxyDabgymnmwJayTqVyQTYjQvzkyjXj2kHBKJJuCgEyyo2P01JGktbljoAtovM4uocAmWB1eD21dUdsnzjldmn24LRPhmEzrTKmi0RUDnfBaMEnGej2XaCTGM36KXq(cRdiWaJPHXAeaRf6ftTvorTktbljoXwjCJCCKIZWddZXoLUEem1wxHamaFbroi46b3DxLPGLehndS1rWgwGbk7uJbERMOZe6k2bxwtaZQzWReGggRraSwKiXDvMcwsC0m4vcqJbERMOZe6k2H1eWSAg8kbOHXAeaRLwOxm1w5e1QmfSK4eBLWTyskcyWKbS01JWA4oS6T4HWMbwboF)hwd3HvVfpe2mWkGJ7Oxm1w5e1QmfSK4eBLWTyskcyWKbS01JG7UGTIfGRWSAJXIAOTwXnkrc2kwaUcZQnglQRHdxLslhWKd4mb3DRnBiFpn54ifNHhgMJDQjLBHEXuBLtuRYuWsItSvc3ihhP4m0iQUJLEHEXuBLtu3HbWLIadS1rqLLq66rOH890rsgdMaltEngm1EWLRgUSgbOLZuutp8sCOB4EEkajsKHv3nCppfG2uBDfOxm1w5e1DyaCPALWngyRJGklH01JaMCkvqojcyndELQwND7UdURYuWsIJ2KtLjoLJGgd8wnroosIeg0q(E6hexaxtpqmjhMoUMIloURLdUC1WL1iaTCMIA6HxIdDd3ZtbqVyQTYjQ7Wa4s1kHBmWwhbBybgOStPRhH1eWSAziULagfOHXAea7GktbljoAtovM4uocAmWB1ePxm1w5e1DyaCPALWng8kbiD9iOYuWsIJ2KtLjoLJGgd8wnr6ftTvorDhgaxQwjClQssChcXfxCbsxpcU7odAiFp9dIlGRPhiMKdttkFqLPGLehTjNktCkhbng4TAICCulsKWGgY3t)G4c4A6bIj5W0X1uCXXDTCqLPGLehTH5pd5lSoGadmMgd8wnrooIEXuBLtu3HbWLQvc3ucJyn9q0HXsIrPRhb3DNbnKVN(bXfW10detYHPjLpOYuWsIJ2KtLjoLJGgd8wnrooQfjsyqd57PFqCbCn9aXKCy64AkU44UwoOYuWsIJ2W8NH8fwhqGbgtJbERMihhrVyQTYjQ7Wa4s1kHBmWwhbvwcPRhbm5uQGCseWAg8kvTo7Quo4YvdxwJa0YzkQPhEjo0nCppfa9IP2kNOUddGlvReU9G4c4A6H4IlUaPRhb3D3D3zqd57PFqCbCn9aXKCy64AkUC(UdU0q(EAYXrkodpmmh7utk3IejmOH890piUaUMEGysomDCnfxo3UwoOYuWsIJ2KtLjoLJGgd8wnrNBxlsKWGgY3t)G4c4A6bIj5W0X1uC5SBTCqLPGLehTH5pd5lSoGadmMgd8wnrooIEXuBLtu3HbWLQvc3yGTocQSesxpcUC1WL1iaTCMIA6HxIdDd3ZtbG(g56iXO)V4jf2w502X2BrlAri]] )

end
