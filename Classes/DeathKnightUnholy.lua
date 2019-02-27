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

    spec:RegisterPack( "Unholy", 20190226.2310, [[dyeXWaqijOhPQGnjPmkQuDkrOxrLywes3scHDrYVuvAyuj5yuPSmjWZKqAAQk6AsO2gII(MeImoef6CikP1HOuMNi4Ei0(quDqefyHeIhsLu1ePsk6Iujf2iIc6KikvwPKQxsLuYnLqu2jI0qPsk1sruQ6PQ0urqxfrjSvjev7f4VIAWu1HPSyQ4XOmzuDzOnRIpRkJMqDAfRgrj61iWSj62I0UL63cdxswoONtQPR01jy7iIVRQA8ujvoVeTEvfA(IO9J0a3aecUCBraPf4k3iRUQGcitvbf1nx5QIcUBzfcUvgJa7HGBBPi4sw0Idzj4wzLYW4acbxDiazi4kE3knz77xO9REZkwWrqJqw0l2RIfPF1tQG02jAg0o7x9KY(6CSIGJK8TcgNrI6VU2qKS3gU(RRnzF21eTvC21QNN4ntw0IdzPspPmW1ryKlzxdCaxUTiG0cCLBKvxvqbKPQGI6MRCvbGRUczaslO4caxXdNJnWbC5OMbUFG6jlAXHSK6DnrBft9Uw98eV06FG6fVBLMS997BwXcokwK(vpPcsBNOzq7SF1tkJw)dupzi6afmyj1xazkk1xGRCJms9fb1xqrjBU5kADA9pq9UEXw)qnzJw)duFrq9KbCoYP(ISP5upzieXpIkA9pq9fb176JMeeUiN6xd(WnphQNfnF2jAn1Vb1dXNG0GuplA(St0Af4kh9QbecUpSr4Waeci1naHGl2MJe5araxgCweog46iCokTaNJDMhrQcIgBP(AuFHupjgCmhjQQIqo9lFcy(zWxukrQpzsQVcx1ZGVOuIkJTdji4ASDIgC5OTIZSyKGfqAbacbxSnhjYbIaUm4SiCmWfk0dlxf)iuXXZWML6tG6D7tQVg17o1ZIqYJ)wzvbZKLvAubXuBAn1to1xm1Nmj1ZrhHZrDq9IWPF5)qO5k9AmcOEYP(pP(eP(AuFHupjgCmhjQQIqo9lFcy(zWxukrW1y7en4YrBfNzXiblG0IcieCX2CKihic4YGZIWXa31KyVQkuVJeBgQW2CKiN6Rr9SiK84VvwvWmzzLgvqm1MwdUgBNObxoAR4S18mhzwjybK(jGqWfBZrICGiGldolchdCzri5XFRSQGzYYknQGyQnTgCn2ordUC8mseSaslgqi4IT5iroqeWLbNfHJbUUt9Ut9C0r4CuhuViC6x(peAUsOI6Rr9SiK84VvwvWmzzLgvqm1Mwt9Kt9ft9js9jts9C0r4CuhuViC6x(peAUsVgJaQNCQ)tQprQVg1ZIqYJ)wzW0YCCYRymZrJRGyQnTM6jN6lgCn2ordUAwiaFywVWHaeSasjtaHGl2MJe5araxgCweog46o17o1ZrhHZrDq9IWPF5)qO5kHkQVg1ZIqYJ)wzvbZKLvAubXuBAn1to1xm1Ni1Nmj1ZrhHZrDq9IWPF5)qO5k9AmcOEYP(pP(eP(Auplcjp(BLbtlZXjVIXmhnUcIP20AQNCQVyW1y7en4YK2)0VSwSXJFnybKwKaecUyBosKdebCzWzr4yGluOhwUk(rOIJNHnl1Na1xGRO(AuFHupjgCmhjQQIqo9lFcy(zWxukrW1y7en4YrBfNzXiblGuYiGqWfBZrICGiGldolchdCDN6DN6DN6DN65OJW5OoOEr40V8Fi0CLEngbuFcu)NuFnQVqQ3r4CucT4qwMpqS)yPsOI6tK6tMK65OJW5OoOEr40V8Fi0CLEngbuFcuFrP(eP(Auplcjp(BLvfmtwwPrfetTP1uFcuFrP(eP(KjPEo6iCoQdQxeo9l)hcnxPxJra1Na17g1Ni1xJ6zri5XFRmyAzoo5vmM5OXvqm1Mwt9Kt9fdUgBNOb3dQxeo9lRx4qacwaPKvaHGl2MJe5araxgCweog4wi1tIbhZrIQQiKt)YNaMFg8fLseCn2ordUC0wXzwmsWcwWLJhtqUacbK6gGqW1y7en4MonpFGi(reCX2CKihicybKwaGqWfBZrICGiGljMuabxwesE83kTqAA05NbFrPevqm1Mwt9jq9ft91O(1KyVkTqAA05NbFrPevyBosKdUgBNObxsm4yoseCjXG52srWTkc50V8jG5NbFrPeblG0IcieCX2CKihic4YGZIWXaxOqpSCv8JqfhpdBwQNCQNmlM6Rr9Ut9v4QEg8fLsuzSDibP(KjP(cP(1KyVkTqAA05NbFrPevyBosKt9js91OEOqJkoEg2Sup5eP(IbxJTt0GRbzwJ5nGqSxWci9taHGl2MJe5araxgCweog4wHR6zWxukrLX2HeK6tMK6lK6xtI9Q0cPPrNFg8fLsuHT5iro4ASDIgCDKrWZhbyjybKwmGqWfBZrICGiGldolchdCDeohLqloKL5de7pwQeQO(KjP(kCvpd(IsjQm2oKGuFYKuFHu)AsSxLwinn68ZGVOuIkSnhjYbxJTt0GRdc1iKGPFGfqkzcieCn2ordUcAmplMQbxSnhjYbIawaPfjaHGl2MJe5araxJTt0GRt5lAm7Gy2KPwBmWLbNfHJbUSiK84VvAH00OZpd(IsjQGyQnTM6jN6jtxr9jts9fs9RjXEvAH00OZpd(IsjQW2CKihCBlfbxNYx0y2bXSjtT2yGfqkzeqi4IT5iroqeW1y7en4swI6S44xIqWLbNfHJbUv4QEg8fLsuzSDibP(KjP(cP(1KyVkTqAA05NbFrPevyBosKdUTLIGlzjQZIJFjcblGuYkGqWfBZrICGiGRX2jAW9zsKzsjc1zh0iaCzWzr4yGBfUQNbFrPevgBhsqQpzsQVqQFnj2RslKMgD(zWxukrf2MJe5GBBPi4(mjYmPeH6SdAeawaPU5kaHGl2MJe5araxgCweog4YIqYJ)wzW0YCCYRymZrJRGOXlP(KjP(kCvpd(IsjQm2oKGuFYKuVJW5OeAXHSmFGy)XsLqf4ASDIgCRIDIgSasDZnaHGl2MJe5araxgCweog4YJvrYafKyV5kP9eqfetTP1uFceP(hJdUgBNOb3qyDGOraybK6wbacbxSnhjYbIaUgBNObxMjLzJTt0z5OxWvo6n3wkcUSiK84V1GfqQBffqi4IT5iroqeWLbNfHJbUgBhsWm2y6GAQNCIuFbGRX2jAWfk0zJTt0z5OxWvo6n3wkcUwGGfqQBFcieCX2CKihic4ASDIgCzMuMn2orNLJEbx5O3CBPi4(WgHddSGfCRGilsDSfqiGu3aecUyBosKdebSaslaqi4IT5iroqeWciTOacbxSnhjYbIawaPFcieCX2CKihicybKwmGqW1y7en4wf7en4IT5iroqeWciLmbecUgBNObxOnAmZrJdUyBosKdebSaslsacbxSnhjYbIaUCuALGBbGRX2jAW1GPL54KxXyMJghSGfCzri5XFRbeci1naHGRX2jAW1GPL54KxXyMJghCX2CKihicybKwaGqWfBZrICGiGldolchdC5OJW5OoOEr40V8Fi0CLEngbup5eP(pbxJTt0GRvfmtwwPrWciTOacbxSnhjYbIaUm4SiCmWTqQhAdpJKG9QmoxRqx3Oxn1Nmj1dTHNrsWEvgNRvtt9Kt9Uvm4ASDIgC5gKG8cTwFcyQTt0Gfq6NacbxSnhjYbIaUm4SiCmWfk0dlxf)iuXXZWML6tG6D7tW1y7en4QfstJo)m4lkLiybKwmGqWfBZrICGiGldolchdC5OJW5OoOEr40V8Fi0CLEngbuFcu)NGRX2jAWvOfhYY8bI9hlblGuYeqi4IT5iroqeWLbNfHJbUgBhsWm2y6GAQNCIuFbuFnQ3DQ3DQNfHKh)TIJ2koBnpZrMvQGyQnTM6tGi1)yCQVg1xi1VMe7vXXZirf2MJe5uFIuFYKuV7uplcjp(BfhpJevqm1Mwt9jqK6Fmo1xJ6xtI9Q44zKOcBZrICQprQprW1y7en4k0Idzz(aX(JLGfqArcqi4IT5iroqeWLbNfHJbURbF4Q2jfZBK5ds9jq9KrQVg1Vg8HRANumVrMpi1to1)j4ASDIgC1HGmdrRcHGfqkzeqi4IT5iroqeWLbNfHJbUUt9fs9qB4zKeSxLX5Af66g9QP(KjPEOn8msc2RY4CTAAQNCQVaxr9js91OEOqJuFcePE3PE3O(IG6DeohLqloKL5de7pwQeQO(ebxJTt0GRoeKziAvieSasjRacbxJTt0GRqloKLzh58eVGl2MJe5aralybxlqaHasDdqi4IT5iroqeWLbNfHJbUSiK84VvwvWmzzLgvqm1MwdUgBNObxoAR4S18mhzwjybKwaGqW1y7en4YXZirWfBZrICGiGfqArbecUyBosKdebCzWzr4yGlhTvC2AEMJmRuTdJGPFuFnQhk0i1Na1xa1xJ6lK6jXGJ5irvveYPF5taZpd(IsjcUgBNObxSA4y6WalG0pbecUyBosKdebCzWzr4yGlhTvC2AEMJmRuTdJGPFuFnQhk0i1Na1xa1xJ6lK6jXGJ5irvveYPF5taZpd(IsjcUgBNObxoAR4mlgjybKwmGqWfBZrICGiGldolchdC5OTIZwZZCKzLQDyem9J6Rr9SiK84VvwvWmzzLgvqm1MwdUgBNObxnleGpmRx4qacwaPKjGqWfBZrICGiGldolchdC5OTIZwZZCKzLQDyem9J6Rr9SiK84VvwvWmzzLgvqm1MwdUgBNObxM0(N(L1InE8RblG0IeGqWfBZrICGiGldolchdClK6jXGJ5irvveYPF5taZpd(IsjcUgBNObxSA4y6WalGuYiGqWfBZrICGiGldolchdC5OJW5OoOEr40V8Fi0CLEngbuFcePE3O(Auplcjp(BfhTvC2AEMJmRubXuBAn4ASDIgCpOEr40VSEHdbiybKswbecUyBosKdebCzWzr4yG7AsSxLJauVt)Y6aIAf2MJe5uFnQxxHszEn4dxTYraQ3PFzDarn1torQVaQVg1ZrhHZrDq9IWPF5)qO5k9AmcO(eis9UbUgBNOb3dQxeo9lRx4qacwaPU5kaHGl2MJe5araxgCweog46iCokTaNJDMhrQcIgBP(AupuOrfhpdBwQNCIu)NGRX2jAWLJ2koZIrcwaPU5gGqWfBZrICGiGldolchdCDeohLwGZXoZJivbrJTuFnQVqQNedoMJevvriN(Lpbm)m4lkLi1Nmj1xHR6zWxukrLX2HeeCn2ordUC0wXzwmsWci1TcaecUyBosKdebCzWzr4yGluOhwUk(rOIJNHnl1Na172NuFnQ3DQNfHKh)TYQcMjlR0OcIP20AQNCQVyQpzsQNJocNJ6G6fHt)Y)HqZv61yeq9Kt9Fs9js91O(cPEsm4yosuvfHC6x(eW8ZGVOuIGRX2jAWLJ2koZIrcwaPUvuaHGl2MJe5araxgCweog46o17o1ZrhHZrDq9IWPF5)qO5kHkQVg1ZIqYJ)wzvbZKLvAubXuBAn1to1xm1Ni1Nmj1ZrhHZrDq9IWPF5)qO5k9AmcOEYP(pP(eP(Auplcjp(BLbtlZXjVIXmhnUcIP20AQNCQVyW1y7en4QzHa8Hz9chcqWci1TpbecUyBosKdebCzWzr4yGR7uV7uphDeoh1b1lcN(L)dHMReQO(Auplcjp(BLvfmtwwPrfetTP1up5uFXuFIuFYKuphDeoh1b1lcN(L)dHMR0RXiG6jN6)K6tK6Rr9SiK84VvgmTmhN8kgZC04kiMAtRPEYP(IbxJTt0GltA)t)YAXgp(1GfqQBfdieCX2CKihic4YGZIWXaxOqpSCv8JqfhpdBwQpbQVaxr91O(cPEsm4yosuvfHC6x(eW8ZGVOuIGRX2jAWLJ2koZIrcwaPUrMacbxSnhjYbIaUm4SiCmW1DQ3DQ3DQ3DQNJocNJ6G6fHt)Y)HqZv61yeq9jq9Fs91O(cPEhHZrj0Idzz(aX(JLkHkQprQpzsQNJocNJ6G6fHt)Y)HqZv61yeq9jq9fL6tK6Rr9SiK84VvwvWmzzLgvqm1Mwt9jq9fL6tK6tMK65OJW5OoOEr40V8Fi0CLEngbuFcuVBuFIuFnQNfHKh)TYGPL54KxXyMJgxbXuBAn1to1xm4ASDIgCpOEr40VSEHdbiybK6wrcqi4IT5iroqeWLbNfHJbUfs9KyWXCKOQkc50V8jG5NbFrPebxJTt0GlhTvCMfJeSGfSGljiuprdiTax5gz1vfuazQkOOUYnW93G90pn4s2LwfWf5uFXuVX2jAQxo6vRO1bxtyfhqW9oPcsBNOD9q7SGBfmoJeb3pq9KfT4qws9UMOTIPExREEIxA9pq9I3Tst2((9nRybhfls)QNubPTt0mOD2V6jLrR)bQNmeDGcgSK6lGmfL6lWvUrgP(IG6lOOKn3CfToT(hOExVyRFOMSrR)bQViOEYaoh5uFr20CQNmeI4hrfT(hO(IG6D9rtccxKt9RbF4MNd1ZIMp7eTM63G6H4tqAqQNfnF2jATIwNw)duVRHRdzclYPEh8eqK6zrQJTuVd(MwROEYagdRwn13rxeIny6rqs9gBNO1uF0YsfTUX2jATQcISi1XwIhPPjGw3y7eTwvbrwK6yRle)EIGtRBSDIwRQGilsDS1fIFnHxk2RTt006FG6VTvPfhl1dTHt9ocNdYPE9ARM6DWtarQNfPo2s9o4BAn1BnN6RGyruf7o9J6hn1ZJgv06gBNO1QkiYIuhBDH4xDBvAXXM1RTAADJTt0AvfezrQJTUq8BvSt006gBNO1QkiYIuhBDH4xOnAmZrJtRBSDIwRQGilsDS1fIFnyAzoo5vmM5OXfLJsRKyb0606FG6DnCDityro1JKGWsQFNuK6xXi1BSnGu)OPEJeBKMJev06gBNO1etNMNpqe)isRBSDIw7cXVKyWXCKOOTLIeRIqo9lFcy(zWxukrrjXKcirwesE83kTqAA05NbFrPevqm1MwNqX1wtI9Q0cPPrNFg8fLsuHT5iroT(hOEYEJnMulk1t2TyQwuQ3Ao1hRyes9XJX106gBNO1Uq8RbzwJ5nGqSxrNdrOqpSCv8JqfhpdBwYjZIR5EfUQNbFrPevgBhsWKjlCnj2RslKMgD(zWxukrf2MJe5jwdk0OIJNHnl5elMw3y7eT2fIFDKrWZhbyPOZHyfUQNbFrPevgBhsWKjlCnj2RslKMgD(zWxukrf2MJe506gBNO1Uq8Rdc1iKGPFIohIocNJsOfhYY8bI9hlvcvjtwHR6zWxukrLX2HemzYcxtI9Q0cPPrNFg8fLsuHT5iroT(hOExVGEJuQFHttaUAQxqBpKw3y7eT2fIFf0yEwmvtRBSDIw7cXVcAmplMkABPirNYx0y2bXSjtT2yIohISiK84VvAH00OZpd(IsjQGyQnTMCY0vjtw4AsSxLwinn68ZGVOuIkSnhjYP1n2orRDH4xbnMNftfTTuKizjQZIJFjcfDoeRWv9m4lkLOYy7qcMmzHRjXEvAH00OZpd(IsjQW2CKiNw3y7eT2fIFf0yEwmv02srIptImtkrOo7GgbIohIv4QEg8fLsuzSDibtMSW1KyVkTqAA05NbFrPevyBosKtRBSDIw7cXVvXorl6CiYIqYJ)wzW0YCCYRymZrJRGOXltMScx1ZGVOuIkJTdjyYKocNJsOfhYY8bI9hlvcv06FG6lYSPxBAQViFGcsSxQ31wApbKw3y7eT2fIFdH1bIgbIohI8yvKmqbj2BUsApbubXuBADceFmoTUX2jATle)YmPmBSDIolh9kABPirwesE83AADJTt0Axi(fk0zJTt0z5OxrBlfjAbk6CiASDibZyJPdQjNyb06gBNO1Uq8lZKYSX2j6SC0ROTLIeFyJWHrRtR)bQNmiCnOEyS2ortRBSDIwRSajYrBfNTMN5iZkfDoezri5XFRSQGzYYknQGyQnTMw3y7eTwzb6cXVC8msKw3y7eTwzb6cXVy1WX0Hj6CiYrBfNTMN5iZkv7Wiy6xnOqJjuqTcjXGJ5irvveYPF5taZpd(IsjsRBSDIwRSaDH4xoAR4mlgPOZHihTvC2AEMJmRuTdJGPF1GcnMqb1kKedoMJevvriN(Lpbm)m4lkLiTUX2jATYc0fIF1Sqa(WSEHdbOOZHihTvC2AEMJmRuTdJGPF1yri5XFRSQGzYYknQGyQnTMw3y7eTwzb6cXVmP9p9lRfB84xl6CiYrBfNTMN5iZkv7Wiy6xnwesE83kRkyMSSsJkiMAtRP1n2orRvwGUq8lwnCmDyIohIfsIbhZrIQQiKt)YNaMFg8fLsKw3y7eTwzb6cXVhuViC6xwVWHau05qKJocNJ6G6fHt)Y)HqZv61yeKar3QXIqYJ)wXrBfNTMN5iZkvqm1MwtRBSDIwRSaDH43dQxeo9lRx4qak6CiUMe7v5ia170VSoGOwHT5irEnDfkL51GpC1khbOEN(L1be1KtSGAC0r4CuhuViC6x(peAUsVgJGei6gTUX2jATYc0fIF5OTIZSyKIohIocNJslW5yN5rKQGOX2AqHgvC8mSzjN4N06gBNO1klqxi(LJ2koZIrk6Ci6iCokTaNJDMhrQcIgBRvijgCmhjQQIqo9lFcy(zWxukXKjRWv9m4lkLOYy7qcsRBSDIwRSaDH4xoAR4mlgPOZHiuOhwUk(rOIJNHnBcU9zn3zri5XFRSQGzYYknQGyQnTM8ItMKJocNJ6G6fHt)Y)HqZv61yeq(NjwRqsm4yosuvfHC6x(eW8ZGVOuI06gBNO1klqxi(vZcb4dZ6foeGIohIU7ohDeoh1b1lcN(L)dHMReQQXIqYJ)wzvbZKLvAubXuBAn5fNyYKC0r4CuhuViC6x(peAUsVgJaY)mXASiK84VvgmTmhN8kgZC04kiMAtRjVyADJTt0ALfOle)YK2)0VSwSXJFTOZHO7UZrhHZrDq9IWPF5)qO5kHQASiK84VvwvWmzzLgvqm1MwtEXjMmjhDeoh1b1lcN(L)dHMR0RXiG8ptSglcjp(BLbtlZXjVIXmhnUcIP20AYlMw3y7eTwzb6cXVC0wXzwmsrNdrOqpSCv8JqfhpdB2ekWv1kKedoMJevvriN(Lpbm)m4lkLiTUX2jATYc0fIFpOEr40VSEHdbOOZHO7U7U7C0r4CuhuViC6x(peAUsVgJGe(SwHocNJsOfhYY8bI9hlvcvjMmjhDeoh1b1lcN(L)dHMR0RXiiHIMynwesE83kRkyMSSsJkiMAtRtOOjMmjhDeoh1b1lcN(L)dHMR0RXiib3sSglcjp(BLbtlZXjVIXmhnUcIP20AYlMw3y7eTwzb6cXVC0wXzwmsrNdXcjXGJ5irvveYPF5taZpd(IsjsRtRBSDIwRyri5XFRjAW0YCCYRymZrJtRBSDIwRyri5XFRDH4xRkyMSSsJIohIC0r4CuhuViC6x(peAUsVgJaYj(jTUX2jATIfHKh)T2fIF5gKG8cTwFcyQTt0IohIfcTHNrsWEvgNRvORB0RozsOn8msc2RY4CTAAYDRyADJTt0Aflcjp(BTle)QfstJo)m4lkLOOZHiuOhwUk(rOIJNHnBcU9jTUX2jATIfHKh)T2fIFfAXHSmFGy)XsrNdro6iCoQdQxeo9l)hcnxPxJrqcFsRBSDIwRyri5XFRDH4xHwCilZhi2FSu05q0y7qcMXgthutoXcQ5U7SiK84VvC0wXzR5zoYSsfetTP1jq8X41kCnj2RIJNrIkSnhjYtmzs3zri5XFR44zKOcIP206ei(y8ARjXEvC8msuHT5irEIjsRBSDIwRyri5XFRDH4xDiiZq0QqOOZH4AWhUQDsX8gz(GjqgRTg8HRANumVrMpi5FsRBSDIwRyri5XFRDH4xDiiZq0QqOOZHO7fcTHNrsWEvgNRvORB0RozsOn8msc2RY4CTAAYlWvjwdk0yceD3TIWr4CucT4qwMpqS)yPsOkrADJTt0Aflcjp(BTle)k0Idzz2ropXlToTUX2jAT6HnchgroAR4mlgPOZHOJW5O0cCo2zEePkiASTwHKyWXCKOQkc50V8jG5NbFrPetMScx1ZGVOuIkJTdjiTUX2jAT6HnchMle)YrBfNzXifDoeHc9WYvXpcvC8mSztWTpR5olcjp(BLvfmtwwPrfetTP1KxCYKC0r4CuhuViC6x(peAUsVgJaY)mXAfsIbhZrIQQiKt)YNaMFg8fLsKw3y7eTw9WgHdZfIF5OTIZwZZCKzLIohIRjXEvvOEhj2muHT5irEnwesE83kRkyMSSsJkiMAtRP1n2orRvpSr4WCH4xoEgjk6CiYIqYJ)wzvbZKLvAubXuBAnTUX2jAT6HnchMle)QzHa8Hz9chcqrNdr3DNJocNJ6G6fHt)Y)HqZvcv1yri5XFRSQGzYYknQGyQnTM8Itmzso6iCoQdQxeo9l)hcnxPxJra5FMynwesE83kdMwMJtEfJzoACfetTP1KxmTUX2jAT6HnchMle)YK2)0VSwSXJFTOZHO7UZrhHZrDq9IWPF5)qO5kHQASiK84VvwvWmzzLgvqm1MwtEXjMmjhDeoh1b1lcN(L)dHMR0RXiG8ptSglcjp(BLbtlZXjVIXmhnUcIP20AYlMw3y7eTw9WgHdZfIF5OTIZSyKIohIqHEy5Q4hHkoEg2SjuGRQvijgCmhjQQIqo9lFcy(zWxukrADJTt0A1dBeomxi(9G6fHt)Y6foeGIohIU7U7UZrhHZrDq9IWPF5)qO5k9Amcs4ZAf6iCokHwCilZhi2FSujuLyYKC0r4CuhuViC6x(peAUsVgJGekAI1yri5XFRSQGzYYknQGyQnToHIMyYKC0r4CuhuViC6x(peAUsVgJGeClXASiK84VvgmTmhN8kgZC04kiMAtRjVyADJTt0A1dBeomxi(LJ2koZIrk6CiwijgCmhjQQIqo9lFcy(zWxukrWcwaaa]] )

end
