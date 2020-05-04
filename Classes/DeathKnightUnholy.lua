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
        resource = "runes",

        reset = function()
            local t = state.runes

            for i = 1, 6 do
                local start, duration, ready = GetRuneCooldown( i )

                start = start or 0
                duration = duration or ( 10 * state.haste )
                
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
                if t.expiry[ 4 ] > state.query_time then
                    t.expiry[ 1 ] = t.expiry[ 4 ] + t.cooldown
                else
                    t.expiry[ 1 ] = state.query_time + t.cooldown
                end
                table.sort( t.expiry )
            end

            if amount > 0 then
                state.gain( amount * 10, "runic_power" )

                if state.set_bonus.tier20_4pc == 1 then
                    state.cooldown.army_of_the_dead.expires = max( 0, state.cooldown.army_of_the_dead.expires - 1 )
                end
            end

            t.actual = nil
        end,

        timeTo = function( x )
            return state:TimeToResource( state.runes, x )
        end,
    }, {
        __index = function( t, k, v )
            if k == 'actual' then
                local amount = 0

                for i = 1, 6 do
                    if t.expiry[ i ] <= state.query_time then
                        amount = amount + 1
                    end
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


            elseif k == 'add' then
                return t.gain

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.RunicPower )


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
                    local actual = debuff.festering_wound.up and debuff.festering_wound.count or 0
                    if buff.unholy_frenzy.down or debuff.festering_wound.down then 
                        return actual
                    end

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
    spec:RegisterPet( "apoc_ghoul", 24207, "apocalypse", 15 )


    spec:RegisterHook( "reset_precast", function ()
        local expires = action.summon_gargoyle.lastCast + 35
        if expires > now then
            summonPet( "gargoyle", expires - now )
        end

        local control_expires = action.control_undead.lastCast + 300
        if control_expires > now and pet.up and not pet.ghoul.up then
            summonPet( "controlled_undead", control_expires - now )
        end

        local apoc_expires = action.apocalypse.lastCast + 15
        if apoc_expires > now then
            summonPet( "apoc_ghoul", apoc_expires - now )
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

        if debuff.outbreak.up and debuff.virulent_plague.down then
            applyDebuff( "target", "virulent_plague" )
        end
    end )


    -- Not actively supporting this since we just respond to the player precasting AOTD as they see fit.
    spec:RegisterStateTable( "death_knight", setmetatable( {
        disable_aotd = false,
        delay = 6,
    }, {
        __index = function( t, k )
            if k == "fwounded_targets" then return state.active_dot.festering_wound end
            return 0
        end,
    } ) )


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
                summonPet( "apoc_ghoul", 15 )

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

            toggle = "interrupts",

            talent = "asphyxiate",

            debuff = "casting",
            readyTime = state.timeToInterrupt,            

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

            targets = {
                count = function () return active_dot.virulent_plague end,
            },

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

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 348565,

            cycle = 'virulent_plague',

            nodebuff = "outbreak",

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


    spec:RegisterPack( "Unholy", 20200503, [[dKutEbqibQhrcLnjKgfjQtrISkHIQ6vcLMLq4wcfYUi8lHOHbK6yaHLbK8meHMgIORrczBcf5Bcf04qeOZHiiRtOO08KICpe1(eihKeQQfce9qHcyIcfv5IicOnIiaNKeQsRer6Lcfv6Mcff7uOQFkuurdfrqzPicQEkkMQqLRscvXwfkQWEP0FrAWK6WuTyP0JHAYO6YQ2mGpJWOLQoTIvtcvEnjy2uCBuA3I(TKHlOJluOwoONt00v66K02LcFxaJxOaDEPY6LIA(a1(HSfe24SmCFVnEqbAqbAqRiqtIcqqcbcqd6yOLz7cVLj0Xk4e3YKo7TmkEY(Y0zzc9ot5CBCwgzPcX3Y0VBOmMnYijMTxTvGl2iLdRQX3Psm0b2iLdlosltR6ywfVPT1YW9924bfObfObTIanjkabjeOJHKKKwgz4X24bLIaLLPF48N2wld)sSLrXqAfpzFz6q6yE33EKoMBoe9lIufdP73nugZgzKeZ2R2kWfBKYHv147ujg6aBKYHfhjIufdPJz8oKMeJaPbfObfOrKIivXq6yGEpjUmMfrQIH0XiKwXNZphPJzMKJ0KaG)nFbIufdPJriDmqLnoCphPxhs8LoainUs(StLsKElKgEcvJdrACL8zNkLcePkgshJqAs4oECJmssavUiDbG0KWQahI0BG7kifisvmKogH0k(gtfaPLtsyEmADiXxKgECXY(K77uPeP3cPdHf(NJ0dasN12pjbshWLin84IL9j)CKgawSi92FKwXpMtsGiTzKRWYyg5kTXzzUu(eFPnoB8GWgNL5P3Ao3csldgo7HJBzGQ5f7WE6wuqG0bH0eyoshfPHQ5GPHvGdr6MqAscAlJJ3Psld7zlyhTaOgv8WPC4DwPDTXdkBCwMNER5CliTmy4ShoULHFF7PEYP8J9oXoyfMKaPbdgPd)k8Wctj6lvJWX704iDuK2X7040NNDUePjJ0GWY44DQ0Y0AQItla62F6ZZ2zxB8KOnolZtV1CUfKwgmC2dh3YOmsJRYWRaPWdlSB6cLxapRpPePBcPJjKoksJRYWRaPWHSD0cGU9NYVZfWZ6tkr6GqACvgEfif4k5pLNtndWbki(c4z9jLiTsinyWinUkdVcKchY2rla62Fk)oxapRpPePBcPbfsdgmsJliunCNkLIjpaG3AoDHQBV4P3Ao3Y44DQ0YqO6q(4jTaOEZhwBVDTXtsBCwMNER5CliTmy4ShoULPvfaqapwbZLskqbXxOgI0GbJ0TQaac4XkyUusbki(uCPM7Hc56yfq6MqAqaclJJ3PslZ2FQA2wQjNcuq8TRnEfzJZY80BnNBbPLbdN9WXTmbJ087Bp1toLFS3j2bRWKewghVtLwgGcRkpN6nF4SN2EN1U24JjBCwMNER5CliTmy4ShoULHxRaxj(5c99CkGXzpTvfMc4z9jLinzKg0wghVtLwgCL4Nl03ZPagN921gFm0gNL5P3Ao3csldgo7HJBzcgP533EQNCk)yVtSdwHjjSmoENkTmHQWbOBscARXLRDTXtcAJZY80BnNBbPLbdN9WXTmRBEUchY2rla62Fk3zZZfp9wZ5iDuK(s5t8fng5ujTaOHhcC8ovkyNSGiDuKUvfaqOM9LPJkx4tITxOgI0GbJ0xkFIVOXiNkPfan8qGJ3Psb7KfePJI0HFfEyHPe9LQr44DACKgmyKEDZZv4q2oAbq3(t5oBEU4P3AohPJI0HFfEyHPe9LQr44DACKoksJRYWRaPWHSD0cGU9NYVZfWZ6tkr6Gq6yc0inyWi96MNRWHSD0cGU9NYD28CXtV1CoshfPd)kCiBhLOVunchVtJBzC8ovAzcuqdVXNKcVSspX3U24jHSXzzE6TMZTG0YGHZE44wMGrA(9TN6jNYp27e7GvyscKoks3QcaiuZ(Y0rLl8jX2ludr6OiDWi9LYN4lAmYPsAbqdpe44DQuWozbr6OiDWi96MNRWHSD0cGU9NYD28CXtV1CosdgmsVoK4Ryh2t3IYNJ0nH04Qm8kqk8Wc7MUq5fWZ6tkTmoENkTmbkOH34tsHxwPN4BxB8Ga024Smp9wZ5wqAzWWzpCCltWin)(2t9Kt5h7DIDWkmjHLXX7uPLboHHMtNKkdD8TRnEqacBCwghVtLwg49WjjOagN9slZtV1CUfK21Uwg(bCvZAJZgpiSXzzC8ovAzyNKtbG)nFlZtV1CUfK21gpOSXzzE6TMZTG0YuHwg5xlJJ3PsltdhoER5wMgUr9wgCvgEfifsvw2kPeoKO6mxapRpPePBcPveshfPx38Cfsvw2kPeoKO6mx80BnNBzA4qA6S3YewLzsckqbPeoKO6m3U24jrBCwMNER5CliTmy4ShoULbQMdMgwbouWpWGNfPdcPJjfH0rrALr6WVcchsuDMlC8onosdgmshmsVU55kKQSSvsjCir1zU4P3AohPvcPJI0q18c(bg8SiDqKrAfzzC8ovAzCi2Zt3ccFU21gpjTXzzE6TMZTG0YGHZE44wMWVcchsuDMlC8onosdgmshmsVU55kKQSSvsjCir1zU4P3Ao3Y44DQ0Y0AQItbuHD21gVISXzzE6TMZTG0YGHZE44wMwvaaHA2xMoka8zZDc1qKgmyKo8RGWHevN5chVtJJ0GbJ0kJ0RBEUchY2rla62Fk3zZZfp9wZ5iDuKo8RWdlmLOVunchVtJJ0kzzC8ovAzApuEOctsyxB8XKnolZtV1CUfKwgmC2dh3YOms3QcaiuZ(Y0rLl8jX2ludr6OiDRkaGa4Y9q2HOFfWZ6tkr6MiJ0kcPvcPbdgPD8ono95zNlr6GiJ0GcPJI0kJ0TQaac1SVmDu5cFsS9c1qKgmyKUvfaqaC5Ei7q0Vc4z9jLiDtKrAfH0kzzC8ovAzmdr)kPkovob7Z1U24JH24Smp9wZ5wqAzWWzpCClJYiD4xbHdjQoZfoENghPJI0RBEUcPklBLuchsuDMlE6TMZrALqAWGr6WVcpSWuI(s1iC8onULXX7uPLXt8Ll0nuSBm21gpjOnolZtV1CUfKwgmC2dh3Y44DAC6ZZoxI0brgPbfsdgmsRmsdvZl4hyWZI0brgPveshfPHQ5GPHvGdf8dm4zr6GiJ0XeOrALSmoENkTmoe75PHQg5TRnEsiBCwMNER5CliTmy4ShoULrzKo8RGWHevN5chVtJJ0rr61npxHuLLTskHdjQoZfp9wZ5iTsinyWiD4xHhwykrFPAeoENg3Y44DQ0YamW3AQIBxB8Ga024Smp9wZ5wqAzWWzpCCltRkaGqn7lthvUWNeBVqnePJI0oENgN(8SZLinzKgeinyWiDRkaGa4Y9q2HOFfWZ6tkr6MqAcmhPJI0oENgN(8SZLinzKgewghVtLwMwNGwa0foyfK21gpiaHnolZtV1CUfKwgmC2dh3YSd7r6GqAqbAKgmyKoyK(Xy1jm8Cb0zdNKG6SHMzv5NsmeEJYS0NetEKgmyKoyK(Xy1jm8CrJrovslak)SJ8wghVtLwgv5PZEwPDTXdcqzJZY80BnNBbPLXX7uPLXBw27qxsbQCPfanScCOLbdN9WXTmkJ0xkFIVOXiNkPfan8qGJ3PsXtV1CoshfPdgPx38CfQzFz6OaWNn3jE6TMZrALqAWGrALr6Gr6lLpXxGRK)uEo1mahOG4lyDfxbr6OiDWi9LYN4lAmYPsAbqdpe44DQu80BnNJ0kzzsN9wgVzzVdDjfOYLwa0WkWH21gpiirBCwMNER5CliTmoENkTmEZYEh6skqLlTaOHvGdTmy4ShoULbxLHxbsHhwy30fkVaEwFsjs3esdcsI0rrALr6lLpXxGRK)uEo1mahOG4lyDfxbrAWGr6lLpXx0yKtL0cGgEiWX7uP4P3AohPJI0RBEUc1SVmDua4ZM7ep9wZ5iTswM0zVLXBw27qxsbQCPfanScCODTXdcsAJZY80BnNBbPLXX7uPLXBw27qxsbQCPfanScCOLbdN9WXTm7WE6wu(CKUjKgxLHxbsHhwy30fkVaEwFsjshlstIK0YKo7TmEZYEh6skqLlTaOHvGdTRnEqOiBCwMNER5CliTmoENkTmUSVHNxsHEZfKIlOBSmy4ShoULH)wvaab0BUGuCbDdL)wvaaHCDSciDtiniSmPZElJl7B45LuO3CbP4c6g7AJheXKnolZtV1CUfKwghVtLwgx23WZlPqV5csXf0nwgmC2dh3Ye(vqO6q(4jTaOEZhwBVWX704iDuKo8RWdlmLOVunchVtJBzsN9wgx23WZlPqV5csXf0n21gpiIH24Smp9wZ5wqAzC8ovAzCzFdpVKc9Mlifxq3yzWWzpCCldUkdVcKcpSWUPluEb8oVdPJI0kJ0xkFIVaxj)P8CQzaoqbXxW6kUcI0rr6DypDlkFos3esJRYWRaPaxj)P8CQzaoqbXxapRpPePJfPbfOrAWGr6Gr6lLpXxGRK)uEo1mahOG4lyDfxbrALSmPZElJl7B45LuO3CbP4c6g7AJheKG24Smp9wZ5wqAzC8ovAzCzFdpVKc9Mlifxq3yzWWzpCClZoSNUfLphPBcPXvz4vGu4Hf2nDHYlGN1NuI0XI0Gc0wM0zVLXL9n88sk0BUGuCbDJDTXdcsiBCwMNER5CliTmoENkTmng5ujTaO8ZoYBzWWzpCClJYinUkdVcKcpSWUPluEb8oVdPJI083QcaiaUCpCscAGsn5c56yfq6GiJ0KePJI0xkFIVOXiNkPfan8qGJ3PsXtV1CosResdgms3QcaiuZ(Y0rbGpBUtOgI0GbJ0HFfeoKO6mx44DAClt6S3Y0yKtL0cGYp7iVDTXdkqBJZY80BnNBbPLXX7uPLb6SHtsqD2qZSQ8tjgcVrzw6tIjVLbdN9WXTm4Qm8kqk8Wc7MUq5fWZ6tkr6MqAqH0GbJ0RBEUchY2rla62Fk3zZZfp9wZ5inyWin0ho9nEUcNZLIjr6MqAfzzsN9wgOZgojb1zdnZQYpLyi8gLzPpjM821gpOaHnolZtV1CUfKwghVtLwM2oIkpT9N6gwpDSLbdN9WXTm4Qm8kqkKQSSvsjCir1zUaEwFsjsheshtGgPbdgPdgPx38Cfsvw2kPeoKO6mx80BnNJ0rr6DypshesdkqJ0GbJ0bJ0pgRoHHNlGoB4KeuNn0mRk)uIHWBuML(KyYBzsN9wM2oIkpT9N6gwpDSDTXdkqzJZY80BnNBbPLXX7uPLrXDjTVcyo0YGHZE44wMWVcchsuDMlC8onosdgmshmsVU55kKQSSvsjCir1zU4P3AohPJI07WEKoiKguGgPbdgPdgPFmwDcdpxaD2WjjOoBOzwv(PedH3Oml9jXK3YKo7TmkUlP9vaZH21gpOirBCwMNER5CliTmoENkTmeU5y3yousBVRGLbdN9WXTmHFfeoKO6mx44DACKgmyKoyKEDZZvivzzRKs4qIQZCXtV1CoshfP3H9iDqinOansdgmshms)yS6egEUa6SHtsqD2qZSQ8tjgcVrzw6tIjVLjD2BziCZXUXCOK2Exb7AJhuK0gNL5P3Ao3cslJJ3PsldbSscjneoSUHcDIBzWWzpCCldunps3ezKMer6OiTYi9oShPdcPbfOrAWGr6Gr6hJvNWWZfqNnCscQZgAMvLFkXq4nkZsFsm5rALSmPZEldbSscjneoSUHcDIBxB8Gsr24Smp9wZ5wqAzWWzpCCldUkdVcKchY2rla62Fk)oxaVZ7qAWGr6WVcchsuDMlC8onosdgms3QcaiuZ(Y0rbGpBUtOgAzC8ovAzcRDQ0U24bvmzJZY80BnNBbPLbdN9WXTm8AfngOQ55sdnoH6fWZ6tkr6MiJ0eyULXX7uPLPu3w4DfSRnEqfdTXzzE6TMZTG0Y44DQ0YGDJH64DQKAg5AzmJCPPZElZLYN4lTRnEqrcAJZY80BnNBbPLXX7uPLb7gd1X7uj1mY1Yyg5stN9wgCvgEfiL21gpOiHSXzzE6TMZTG0YGHZE44wghVtJtFE25sKoiYinOSmoENkTmy3yOoENkPMrUwgZixA6S3Y41TRnEse024Smp9wZ5wqAzC8ovAzWUXqD8ovsnJCTmMrU00zVLH45Hd2U21YecpUyB91gNnEqyJZY44DQ0Yew7uPL5P3Ao3cs7AJhu24SmoENkTmqFKNYVZTmp9wZ5wqAxB8KOnolZtV1CUfKwM0zVLXBw27qxsbQCPfanScCOLXX7uPLXBw27qxsbQCPfanScCODTXtsBCwMNER5CliTm8B8oldOSmoENkTmoKTJwa0T)u(DUDTRLbxLHxbsPnoB8GWgNLXX7uPLXHSD0cGU9NYVZTmp9wZ5wqAxB8GYgNL5P3Ao3csldgo7HJBz4VvfaqaC5E4Ke0aLAYfY1XkG0brgPjjshfPvgPD8ono95zNlr6GiJ0GcPbdgPdgPVu(eFrJrovslaA4HahVtLINER5CKgmyKoyK2B(WzVG1juL0cGU9NYVZfp9wZ5inyWi9LYN4lAmYPsAbqdpe44DQu80BnNJ0rrALr61npxHA2xMoka8zZDINER5CKoksJRYWRaPqn7lthfa(S5ob8S(KsKUjYinjI0GbJ0bJ0RBEUc1SVmDua4ZM7ep9wZ5iTsiTswghVtLwgpSWUPluE7AJNeTXzzE6TMZTG0YGHZE44wMGrAOpC6B8CfoNlfpgCKRePbdgPH(WPVXZv4CUumjshesdcfzzC8ovAz4oub6c9ucuqwFNkTRnEsAJZY80BnNBbPLbdN9WXTmq1CW0WkWHc(bg8SiDtiniiPLXX7uPLrQYYwjLWHevN521gVISXzzE6TMZTG0YGHZE44wMlLpXx0yKtL0cGgEiWX7uP4P3AohPJI0HFfEyHPe9LQr44DACKgmyKM)wvaabWL7HtsqduQjxixhRas3estsKokshmsFP8j(IgJCQKwa0WdboENkfp9wZ5iDuKwzKoyK2B(WzVG1juL0cGU9NYVZfp9wZ5inyWiT38HZEbRtOkPfaD7pLFNlE6TMZr6OiD4xHhwykrFPAeoENghPvYY44DQ0YOM9LPJcaF2CNDTXht24Smp9wZ5wqAzWWzpCClJJ3PXPpp7CjshezKguiDuKwzKwzKgxLHxbsb)(2t9Kt5h7Dc4z9jLiDtKrAcmhPJI0bJ0RBEUc(bgZfp9wZ5iTsinyWiTYinUkdVcKc(bgZfWZ6tkr6MiJ0eyoshfPx38Cf8dmMlE6TMZrALqALSmoENkTmQzFz6OaWNn3zxB8XqBCwMNER5CliTmoENkTmYs1qH3dp0YGHZE44wM1HeFf7WE6wu(CKUjKMeePJI0Rdj(k2H90TO85iDqinjTm4oS501HeFL24bHDTXtcAJZY80BnNBbPLbdN9WXTmkJ0bJ0qF40345kCoxkEm4ixjsdgmsd9HtFJNRW5CPysKoiKguGgPvcPJI0q18iDtKrALrAqG0XiKUvfaqOM9LPJcaF2CNqnePvYY44DQ0YilvdfEp8q7AJNeYgNLXX7uPLrn7lthT1me9RL5P3Ao3cs7AxlJx3gNnEqyJZY80BnNBbPLbdN9WXTm4Qm8kqk8Wc7MUq5fWZ6tkTmoENkTm87Bp1toLFS3zxB8GYgNL5P3Ao3csldgo7HJBzWvz4vGu4Hf2nDHYlGN1NuAzC8ovAz4hym3U24jrBCwMNER5CliTmy4ShoULHFF7PEYP8J9oXoyfMKaPJI0q1CW0WkWHc(bg8SiDtiTYiniijshlsZVV9ufYHOFfabk1KFoDDiXxjshZhPjrKwjKokshms3WHJ3AUiSkZKeuGcsjCir1zULXX7uPL5Hd)Sd2U24jPnolZtV1CUfKwgmC2dh3YWVV9up5u(XENyhSctsG0rrALr6GrA(9TNQqoe9RaiqPM8ZPRdj(kr6Oi96MNROvfk3jjOYcEP4P3AohPvcPJI0bJ0nC44TMlcRYmjbfOGuchsuDMBzC8ovAzE4Wp7GTRnEfzJZY80BnNBbPLbdN9WXTm87Bp1toLFS3j2bRWKeiDuKgQMdMgwbouWpWGNfPBcPbbjr6OiDWiDdhoER5IWQmtsqbkiLWHevN5wghVtLwg(9TNIRXyxB8XKnolZtV1CUfKwgmC2dh3YWVV9up5u(XENyhSctsG0rrACvgEfifEyHDtxO8c4z9jLwghVtLwgjUuHeNkx4OWTRn(yOnolZtV1CUfKwgmC2dh3YWVV9up5u(XENyhSctsG0rrACvgEfifEyHDtxO8c4z9jLwghVtLwgSXdmjbv278kG0U24jbTXzzE6TMZTG0YGHZE44wMGr6goC8wZfHvzMKGcuqkHdjQoZTmoENkTmpC4NDW21gpjKnolZtV1CUfKwghVtLwgGl3dNKGkx4OWTmy4ShoULH)wvaabWL7HtsqduQjxixhRas3ezKguiDuKgxLHxbsb)(2t9Kt5h7Dc4z9jLiDuKgxLHxbsHhwy30fkVaEwFsjshesRiKoksRmsJRYWRaPWHSD0cGU9NYVZfWZ6tkr6GqAfH0GbJ087BpvHCi6xbFKER5uVwosRKLb3HnNUoK4R0gpiSRnEqaABCwMNER5CliTmy4ShoULPvfaqiv58NuEvSc4D8I0rrAOAEXoSNUfLKiDqinbMBzC8ovAz433EkUgJDTXdcqyJZY80BnNBbPLbdN9WXTmTQaacPkN)KYRIvaVJxKokshms3WHJ3AUiSkZKeuGcsjCir1zosdgmsh(vq4qIQZCHJ3PXTmoENkTm87BpfxJXU24bbOSXzzE6TMZTG0YGHZE44wgOAoyAyf4qb)adEwKUjKgeKePJI0kJ04Qm8kqk8Wc7MUq5fWZ6tkr6GqAfH0GbJ083QcaiaUCpCscAGsn5c56yfq6GqAsI0kH0rr6Gr6goC8wZfHvzMKGcuqkHdjQoZTmoENkTm87BpfxJXU24bbjAJZY80BnNBbPLXX7uPLrIlviXPYfokCldgo7HJBzugPvgPXvz4vGu4q2oAbq3(t535c4z9jLiDqiTIqAWGrA(9TNQqoe9RGpsV1CQxlhPvcPJI0kJ04Qm8kqk8Wc7MUq5fWZ6tkr6GqAfH0rrA(BvbaeaxUhojbnqPMCHCDSciDqinOrAWGrA(BvbaeaxUhojbnqPMCHCDSciDqinjrALq6OiTYi9oSNUfLphPBcPXvz4vGuWVV9up5u(XENaEwFsjshlsdcqJ0GbJ07WE6wu(CKoiKgxLHxbsHhwy30fkVaEwFsjsResRKLb3HnNUoK4R0gpiSRnEqqsBCwMNER5CliTmoENkTmyJhyscQS35vaPLbdN9WXTmkJ0kJ04Qm8kqkCiBhTaOB)P87Cb8S(KsKoiKwrinyWin)(2tvihI(vWhP3Ao1RLJ0kH0rrALrACvgEfifEyHDtxO8c4z9jLiDqiTIq6Oin)TQaacGl3dNKGgOutUqUowbKoiKg0inyWin)TQaacGl3dNKGgOutUqUowbKoiKMKiTsiDuKwzKEh2t3IYNJ0nH04Qm8kqk433EQNCk)yVtapRpPePJfPbbOrAWGr6DypDlkFoshesJRYWRaPWdlSB6cLxapRpPePvcPvYYG7WMtxhs8vAJhe21gpiuKnolZtV1CUfKwgmC2dh3YavZbtdRahk4hyWZI0nH0Gc0iDuKoyKUHdhV1CryvMjjOafKs4qIQZClJJ3Psld)(2tX1ySRnEqet24Smp9wZ5wqAzWWzpCClJYiTYiTYiTYin)TQaacGl3dNKGgOutUqUowbKUjKMKiDuKoyKUvfaqOM9LPJcaF2CNqnePvcPbdgP5VvfaqaC5E4Ke0aLAYfY1XkG0nH0KisReshfPXvz4vGu4Hf2nDHYlGN1NuI0nH0KisResdgmsZFRkaGa4Y9WjjObk1KlKRJvaPBcPbbsReshfPvgPXvz4vGu4q2oAbq3(t535c4z9jLiDqiTIqAWGrA(9TNQqoe9RGpsV1CQxlhPvYY44DQ0YaC5E4Keu5chfUDTXdIyOnolZtV1CUfKwgmC2dh3YWVV9up5u(XENyhSctsyzC8ovAzK4sfsCQCHJc3U21Yq88WbBJZgpiSXzzE6TMZTG0YGHZE44wMwvaaHuLZFs5vXkG3XlshfPHQ5f7WE6wusI0bH0eyoshfPdgPB4WXBnxewLzsckqbPeoKO6mhPbdgPd)kiCir1zUWX704wghVtLwg(9TNIRXyxB8GYgNL5P3Ao3csldgo7HJBzGQ5GPHvGdf8dm4zr6MqAqqsKoksdvZl2H90TOKePdcPjWCKokshms3WHJ3AUiSkZKeuGcsjCir1zULXX7uPLHFF7P4Am21gpjAJZY80BnNBbPLbdN9WXTmkJ0kJ083QcaiaUCpCscAGsn5c1qKoksRmsJRYWRaPWdlSB6cLxapRpPePdcPveshfPvgPdgPVu(eFrJrovslaA4HahVtLINER5CKgmyKoyKEDZZvOM9LPJcaF2CN4P3AohPvcPbdgPVu(eFrJrovslaA4HahVtLINER5CKoksVU55kuZ(Y0rbGpBUt80BnNJ0rrACvgEfifQzFz6OaWNn3jGN1NuI0bH0XesResResdgmsZFRkaGa4Y9WjjObk1KlKRJvaPdcPjjsReshfPvgPXvz4vGu4q2oAbq3(t535c4z9jLiDqiTIqAWGrA(9TNQqoe9RGpsV1CQxlhPvYY44DQ0YiXLkK4u5chfUDTXtsBCwMNER5CliTmy4ShoULrzKwzKM)wvaabWL7HtsqduQjxOgI0rrALrACvgEfifEyHDtxO8c4z9jLiDqiTIq6OiTYiDWi9LYN4lAmYPsAbqdpe44DQu80BnNJ0GbJ0bJ0RBEUc1SVmDua4ZM7ep9wZ5iTsinyWi9LYN4lAmYPsAbqdpe44DQu80BnNJ0rr61npxHA2xMoka8zZDINER5CKoksJRYWRaPqn7lthfa(S5ob8S(KsKoiKoMqALqALqAWGrA(BvbaeaxUhojbnqPMCHCDSciDqinjrALq6OiTYinUkdVcKchY2rla62Fk)oxapRpPePdcPvesdgmsZVV9ufYHOFf8r6TMt9A5iTswghVtLwgSXdmjbv278kG0U24vKnolZtV1CUfKwgmC2dh3YavZbtdRahk4hyWZI0nH0Gc0iDuKoyKUHdhV1CryvMjjOafKs4qIQZClJJ3Psld)(2tX1ySRn(yYgNL5P3Ao3csldgo7HJBz4VvfaqaC5E4Ke0aLAYfY1XkG0nH0KePJI0kJ04Qm8kqk8Wc7MUq5fWZ6tkr6MqAsePJI0kJ0bJ0xkFIVOXiNkPfan8qGJ3PsXtV1CosdgmshmsVU55kuZ(Y0rbGpBUt80BnNJ0GbJ0xkFIVOXiNkPfan8qGJ3PsXtV1CoshfPx38CfQzFz6OaWNn3jE6TMZr6OinUkdVcKc1SVmDua4ZM7eWZ6tkr6Mq6yisResResdgmsZFRkaGa4Y9WjjObk1KlKRJvaPBcPbbshfPvgPXvz4vGu4q2oAbq3(t535c4z9jLiDqiTIqAWGrA(9TNQqoe9RGpsV1CQxlhPvYY44DQ0YaC5E4Keu5chfUDTXhdTXzzE6TMZTG0YGHZE44wMGr6goC8wZfHvzMKGcuqkHdjQoZTmoENkTm87BpfxJXU21UwMghkNkTXdkqdkqdAscQyYYeWH5KeslJIx2WcUNJ0Xes74DQePnJCLcePwMqybmMBzumKwXt2xMoKoM39ThPJ5Mdr)IivXq6(DdLXSrgjXS9QTcCXgPCyvn(ovIHoWgPCyXrIivXq6ygVdPjXiqAqbAqbAePisvmKogO3tIlJzrKQyiDmcPv858Zr6yMj5inja4FZxGivXq6yeshduzJd3Zr61HeFPdasJRKp7uPeP3cPHNq14qKgxjF2PsParQIH0XiKMeUJh3iJKeqLlsxainjSkWHi9g4UcsbIuePkgstcmg8y19CKU9af8inUyB9fPBpXKsbsR4JXpCLiDwzmQ3HSaQgK2X7uPePR00jqKQyiTJ3PsPieECX26lzaJlvarQIH0oENkLIq4XfBRVXsosGQ4isvmK2X7uPuecpUyB9nwYr6QeSpxFNkrKQyint6HY(ArAOpCKUvfa4CKwU(kr62duWJ04IT1xKU9etkrAp5iDi8XOWA3jjq6rI08kVarQIH0oENkLIq4XfBRVXsosz6HY(APY1xjIuhVtLsri84IT13yjhzyTtLisD8ovkfHWJl2wFJLCKqFKNYVZrK64DQukcHhxST(gl5ivLNo7zJiD2t2Bw27qxsbQCPfanScCiIuhVtLsri84IT13yjhPdz7OfaD7pLFNhb)gVJmOqKIivXqAsGXGhRUNJ0VXHDi9oShP3(J0oElispsK2B4JXBnxGi1X7uPKm7KCka8V5Ji1X7uPmwYr2WHJ3AEePZEYHvzMKGcuqkHdjQoZJOHBupzCvgEfifsvw2kPeoKO6mxapRpPSjffDDZZvivzzRKs4qIQZCXtV1CoIufdPjH74XnYiqAfV7zLrG0EYr6A7pePlcmxIi1X7uPmwYr6qSNNUfe(CJyaidvZbtdRahk4hyWZgumPOOkh(vq4qIQZCHJ3PXbdo41npxHuLLTskHdjQoZfp9wZ5kffQMxWpWGNniYkcrQJ3PszSKJS1ufNcOc7Iyaih(vq4qIQZCHJ3PXbdo41npxHuLLTskHdjQoZfp9wZ5isD8ovkJLCKThkpuHjjIyai3QcaiuZ(Y0rbGpBUtOgcgC4xbHdjQoZfoENghmyLx38CfoKTJwa0T)uUZMNlE6TMZJg(v4HfMs0xQgHJ3PXvcrQJ3PszSKJ0me9RKQ4u5eSp3igaYk3QcaiuZ(Y0rLl8jX2ludJ2QcaiaUCpKDi6xb8S(KYMiRiLad2X7040NNDUmiYGkQYTQaac1SVmDu5cFsS9c1qWGBvbaeaxUhYoe9RaEwFsztKvKsisD8ovkJLCKEIVCHUHIDJjIbGSYHFfeoKO6mx44DA8ORBEUcPklBLuchsuDMlE6TMZvcm4WVcpSWuI(s1iC8onoIuhVtLYyjhPdXEEAOQr(igaYoENgN(8SZLbrguGbRmunVGFGbpBqKvuuOAoyAyf4qb)adE2GihtGwjePoENkLXsosGb(wtv8igaYkh(vq4qIQZCHJ3PXJUU55kKQSSvsjCir1zU4P3AoxjWGd)k8Wctj6lvJWX704isD8ovkJLCKTobTaOlCWkiJyai3QcaiuZ(Y0rLl8jX2ludJ64DAC6ZZoxsgeGb3QcaiaUCpKDi6xb8S(KYMiW8OoENgN(8SZLKbbIuePkgshdOk3IfPx4Kk8vI0QsN4isD8ovkJLCKQYtN9SYigaY7W(GafObdo4hJvNWWZfqNnCscQZgAMvLFkXq4nkZsFsm5bdo4hJvNWWZfng5ujTaO8ZoYJi1X7uPmwYrQkpD2Zgr6SNS3SS3HUKcu5slaAyf4WigaYkFP8j(IgJCQKwa0WdboENkfp9wZ5rdEDZZvOM9LPJcaF2CN4P3AoxjWGvo4lLpXxGRK)uEo1mahOG4lyDfxbJg8LYN4lAmYPsAbqdpe44DQu80BnNReIuhVtLYyjhPQ80zpBePZEYEZYEh6skqLlTaOHvGdJyaiJRYWRaPWdlSB6cLxapRpPSjqqYOkFP8j(cCL8NYZPMb4afeFbRR4kiyWxkFIVOXiNkPfan8qGJ3PsXtV1CE01npxHA2xMoka8zZDINER5CLqK64DQugl5ivLNo7zJiD2t2Bw27qxsbQCPfanScCyeda5DypDlkFEt4Qm8kqk8Wc7MUq5fWZ6tkJLejjIuhVtLYyjhPQ80zpBePZEYUSVHNxsHEZfKIlOBIyaiZFRkaGa6nxqkUGUHYFRkaGqUowHMabIuhVtLYyjhPQ80zpBePZEYUSVHNxsHEZfKIlOBIyaih(vqO6q(4jTaOEZhwBVWX704rd)k8Wctj6lvJWX704isD8ovkJLCKQYtN9SrKo7j7Y(gEEjf6nxqkUGUjIbGmUkdVcKcpSWUPluEb8oVlQYxkFIVaxj)P8CQzaoqbXxW6kUcgDh2t3IYN3eUkdVcKcCL8NYZPMb4afeFb8S(KYybfObdo4lLpXxGRK)uEo1mahOG4lyDfxbvcrQJ3PszSKJuvE6SNnI0zpzx23WZlPqV5csXf0nrmaK3H90TO85nHRYWRaPWdlSB6cLxapRpPmwqbAePoENkLXsosv5PZE2isN9KBmYPsAbq5NDKpIbGSY4Qm8kqk8Wc7MUq5fW78UO83QcaiaUCpCscAGsn5c56yfcImjJEP8j(IgJCQKwa0WdboENkfp9wZ5kbgCRkaGqn7lthfa(S5oHAiyWHFfeoKO6mx44DACePoENkLXsosv5PZE2isN9KHoB4KeuNn0mRk)uIHWBuML(KyYhXaqgxLHxbsHhwy30fkVaEwFsztGcm41npxHdz7OfaD7pL7S55INER5CWGH(WPVXZv4CUumztkcrQJ3PszSKJuvE6SNnI0zp52oIkpT9N6gwpDCedazCvgEfifsvw2kPeoKO6mxapRpPmOyc0Gbh86MNRqQYYwjLWHevN5INER58O7W(GafObdo4hJvNWWZfqNnCscQZgAMvLFkXq4nkZsFsm5rK64DQugl5ivLNo7zJiD2twXDjTVcyomIbGC4xbHdjQoZfoENghm4Gx38Cfsvw2kPeoKO6mx80BnNhDh2heOanyWb)yS6egEUa6SHtsqD2qZSQ8tjgcVrzw6tIjpIuhVtLYyjhPQ80zpBePZEYeU5y3yousBVRqeda5WVcchsuDMlC8onoyWbVU55kKQSSvsjCir1zU4P3Aop6oSpiqbAWGd(Xy1jm8Cb0zdNKG6SHMzv5NsmeEJYS0NetEePoENkLXsosv5PZE2isN9KjGvsiPHWH1nuOt8igaYq18nrMeJQ8oSpiqbAWGd(Xy1jm8Cb0zdNKG6SHMzv5NsmeEJYS0NetELqK64DQugl5idRDQmIbGmUkdVcKchY2rla62Fk)oxaVZ7ado8RGWHevN5chVtJdgCRkaGqn7lthfa(S5oHAiIufdPJz8jxFYjjq6yogOQ55I0KWmoH6r6rI0oshcNcoBhIuhVtLYyjhzPUTW7keXaqMxROXavnpxAOXjuVaEwFsztKjWCePoENkLXsosSBmuhVtLuZi3isN9KVu(eFjIuhVtLYyjhj2ngQJ3PsQzKBePZEY4Qm8kqkrK64DQugl5iXUXqD8ovsnJCJiD2t2RhXaq2X7040NNDUmiYGcrQJ3PszSKJe7gd1X7uj1mYnI0zpzINhoyePisvmKwXVibI0WA9DQerQJ3PsPWRtMFF7PEYP8J9UigaY4Qm8kqk8Wc7MUq5fWZ6tkrK64DQuk86Xsos(bgZJyaiJRYWRaPWdlSB6cLxapRpPerQJ3PsPWRhl5iF4Wp7GJyaiZVV9up5u(XENyhSctsefQMdMgwbouWpWGNTjLbbjJLFF7PkKdr)kacuQj)C66qIVYy(KOsrdUHdhV1CryvMjjOafKs4qIQZCePoENkLcVESKJ8Hd)SdoIbGm)(2t9Kt5h7DIDWkmjruLdMFF7PkKdr)kacuQj)C66qIVYORBEUIwvOCNKGkl4LINER5CLIgCdhoER5IWQmtsqbkiLWHevN5isD8ovkfE9yjhj)(2tX1yIyaiZVV9up5u(XENyhSctsefQMdMgwbouWpWGNTjqqYOb3WHJ3AUiSkZKeuGcsjCir1zoIuhVtLsHxpwYrkXLkK4u5chfEedaz(9TN6jNYp27e7GvysIO4Qm8kqk8Wc7MUq5fWZ6tkrK64DQuk86XsosSXdmjbv278kGmIbGm)(2t9Kt5h7DIDWkmjruCvgEfifEyHDtxO8c4z9jLisD8ovkfE9yjh5dh(zhCeda5GB4WXBnxewLzsckqbPeoKO6mhrQJ3PsPWRhl5ibUCpCscQCHJcpcCh2C66qIVsYGiIbGm)TQaacGl3dNKGgOutUqUowHMidQO4Qm8kqk433EQNCk)yVtapRpPmkUkdVcKcpSWUPluEb8S(KYGuuuLXvz4vGu4q2oAbq3(t535c4z9jLbPiWG533EQc5q0Vc(i9wZPETCLqK64DQuk86Xsos(9TNIRXeXaqUvfaqiv58NuEvSc4D8gfQMxSd7PBrjzqeyoIuhVtLsHxpwYrYVV9uCnMigaYTQaacPkN)KYRIvaVJ3Ob3WHJ3AUiSkZKeuGcsjCir1zoyWHFfeoKO6mx44DACePoENkLcVESKJKFF7P4AmrmaKHQ5GPHvGdf8dm4zBceKmQY4Qm8kqk8Wc7MUq5fWZ6tkdsrGbZFRkaGa4Y9WjjObk1KlKRJviisQu0GB4WXBnxewLzsckqbPeoKO6mhrQJ3PsPWRhl5iL4sfsCQCHJcpcCh2C66qIVsYGiIbGSYkJRYWRaPWHSD0cGU9NYVZfWZ6tkdsrGbZVV9ufYHOFf8r6TMt9A5kfvzCvgEfifEyHDtxO8c4z9jLbPOO83QcaiaUCpCscAGsn5c56yfcc0GbZFRkaGa4Y9WjjObk1KlKRJviisQuuL3H90TO85nHRYWRaPGFF7PEYP8J9ob8S(KYybbObdEh2t3IYNheUkdVcKcpSWUPluEb8S(KsLucrQJ3PsPWRhl5iXgpWKeuzVZRaYiWDyZPRdj(kjdIigaYkRmUkdVcKchY2rla62Fk)oxapRpPmifbgm)(2tvihI(vWhP3Ao1RLRuuLXvz4vGu4Hf2nDHYlGN1NugKIIYFRkaGa4Y9WjjObk1KlKRJviiqdgm)TQaacGl3dNKGgOutUqUowHGiPsrvEh2t3IYN3eUkdVcKc(9TN6jNYp27eWZ6tkJfeGgm4DypDlkFEq4Qm8kqk8Wc7MUq5fWZ6tkvsjePoENkLcVESKJKFF7P4AmrmaKHQ5GPHvGdf8dm4zBcuGoAWnC44TMlcRYmjbfOGuchsuDMJi1X7uPu41JLCKaxUhojbvUWrHhXaqwzLvwz(BvbaeaxUhojbnqPMCHCDScnrYOb3QcaiuZ(Y0rbGpBUtOgQeyW83QcaiaUCpCscAGsn5c56yfAIevkkUkdVcKcpSWUPluEb8S(KYMirLadM)wvaabWL7HtsqduQjxixhRqtGqPOkJRYWRaPWHSD0cGU9NYVZfWZ6tkdsrGbZVV9ufYHOFf8r6TMt9A5kHi1X7uPu41JLCKsCPcjovUWrHhXaqMFF7PEYP8J9oXoyfMKarkIuhVtLsbUkdVcKsYoKTJwa0T)u(DoIuhVtLsbUkdVcKYyjhPhwy30fkFedaz(BvbaeaxUhojbnqPMCHCDScbrMKrv2X7040NNDUmiYGcm4GVu(eFrJrovslaA4HahVtLINER5CWGd2B(WzVG1juL0cGU9NYVZfp9wZ5GbFP8j(IgJCQKwa0WdboENkfp9wZ5rvEDZZvOM9LPJcaF2CN4P3AopkUkdVcKc1SVmDua4ZM7eWZ6tkBImjcgCWRBEUc1SVmDua4ZM7ep9wZ5kPeIuhVtLsbUkdVcKYyjhj3HkqxONsGcY67uzeda5GH(WPVXZv4CUu8yWrUsWGH(WPVXZv4CUumzqGqrisD8ovkf4Qm8kqkJLCKsvw2kPeoKO6mpIbGmunhmnScCOGFGbpBtGGKisD8ovkf4Qm8kqkJLCKQzFz6OaWNn3fXaq(s5t8fng5ujTaOHhcC8ovkE6TMZJg(v4HfMs0xQgHJ3PXbdM)wvaabWL7HtsqduQjxixhRqtKmAWxkFIVOXiNkPfan8qGJ3PsXtV1CEuLd2B(WzVG1juL0cGU9NYVZfp9wZ5Gb7nF4SxW6eQsAbq3(t535INER58OHFfEyHPe9LQr44DACLqK64DQukWvz4vGugl5ivZ(Y0rbGpBUlIbGSJ3PXPpp7CzqKbvuLvgxLHxbsb)(2t9Kt5h7Dc4z9jLnrMaZJg86MNRGFGXCXtV1CUsGbRmUkdVcKc(bgZfWZ6tkBImbMhDDZZvWpWyU4P3AoxjLqK64DQukWvz4vGugl5iLLQHcVhEye4oS501HeFLKbreda51HeFf7WE6wu(8MibJUoK4Ryh2t3IYNhejrK64DQukWvz4vGugl5iLLQHcVhEyedazLdg6dN(gpxHZ5sXJbh5kbdg6dN(gpxHZ5sXKbbkqRuuOA(MiRmiIrTQaac1SVmDua4ZM7eQHkHi1X7uPuGRYWRaPmwYrQM9LPJ2AgI(frkIuhVtLsXLYN4ljZE2c2rlaQrfpCkhENvgXaqgQMxSd7PBrbrqeyEuOAoyAyf4WMijOrK64DQukUu(eFzSKJS1ufNwa0T)0NNTlIbGm)(2t9Kt5h7DIDWkmjbyWHFfEyHPe9LQr44DA8OoENgN(8SZLKbbIuhVtLsXLYN4lJLCKeQoKpEslaQ38H12hXaqwzCvgEfifEyHDtxO8c4z9jLnftrXvz4vGu4q2oAbq3(t535c4z9jLbHRYWRaPaxj)P8CQzaoqbXxapRpPujWGXvz4vGu4q2oAbq3(t535c4z9jLnbkWGXfeQgUtLsXKhaWBnNUq1Tx80BnNJi1X7uPuCP8j(Yyjh52FQA2wQjNcuq8Jyai3QcaiGhRG5sjfOG4ludbdUvfaqapwbZLskqbXNIl1CpuixhRqtGaeisD8ovkfxkFIVmwYrcuyv55uV5dN9027SrmaKdMFF7PEYP8J9oXoyfMKarQJ3PsP4s5t8LXsosCL4Nl03ZPagN9rmaK51kWvIFUqFpNcyC2tBvHPaEwFsjzqJi1X7uPuCP8j(YyjhzOkCa6MKG2AC5gXaqoy(9TN6jNYp27e7GvyscePoENkLIlLpXxgl5iduqdVXNKcVSspXpIbG86MNRWHSD0cGU9NYD28CXtV1CE0lLpXx0yKtL0cGgEiWX7uPGDYcgTvfaqOM9LPJkx4tITxOgcg8LYN4lAmYPsAbqdpe44DQuWozbJg(v4HfMs0xQgHJ3PXbdEDZZv4q2oAbq3(t5oBEU4P3AopA4xHhwykrFPAeoENgpkUkdVcKchY2rla62Fk)oxapRpPmOyc0GbVU55kCiBhTaOB)PCNnpx80BnNhn8RWHSDuI(s1iC8onoIuhVtLsXLYN4lJLCKbkOH34tsHxwPN4hXaqoy(9TN6jNYp27e7GvysIOTQaac1SVmDu5cFsS9c1WObFP8j(IgJCQKwa0WdboENkfStwWObVU55kCiBhTaOB)PCNnpx80BnNdg86qIVIDypDlkFEt4Qm8kqk8Wc7MUq5fWZ6tkrK64DQukUu(eFzSKJeoHHMtNKkdD8Jyaihm)(2t9Kt5h7DIDWkmjbIuhVtLsXLYN4lJLCKW7Htsqbmo7LisrK64DQukiEE4GjZVV9uCnMigaYTQaacPkN)KYRIvaVJ3Oq18IDypDlkjdIaZJgCdhoER5IWQmtsqbkiLWHevN5Gbh(vq4qIQZCHJ3PXrK64DQukiEE4GJLCK87BpfxJjIbGmunhmnScCOGFGbpBtGGKrHQ5f7WE6wusgebMhn4goC8wZfHvzMKGcuqkHdjQoZrK64DQukiEE4GJLCKsCPcjovUWrHhXaqwzL5VvfaqaC5E4Ke0aLAYfQHrvgxLHxbsHhwy30fkVaEwFszqkkQYbFP8j(IgJCQKwa0WdboENkfp9wZ5Gbh86MNRqn7lthfa(S5oXtV1CUsGbFP8j(IgJCQKwa0WdboENkfp9wZ5rx38CfQzFz6OaWNn3jE6TMZJIRYWRaPqn7lthfa(S5ob8S(KYGIjLucmy(BvbaeaxUhojbnqPMCHCDScbrsLIQmUkdVcKchY2rla62Fk)oxapRpPmifbgm)(2tvihI(vWhP3Ao1RLReIuhVtLsbXZdhCSKJeB8atsqL9oVciJyaiRSY83QcaiaUCpCscAGsn5c1WOkJRYWRaPWdlSB6cLxapRpPmiffv5GVu(eFrJrovslaA4HahVtLINER5CWGdEDZZvOM9LPJcaF2CN4P3AoxjWGVu(eFrJrovslaA4HahVtLINER58ORBEUc1SVmDua4ZM7ep9wZ5rXvz4vGuOM9LPJcaF2CNaEwFszqXKskbgm)TQaacGl3dNKGgOutUqUowHGiPsrvgxLHxbsHdz7OfaD7pLFNlGN1NugKIadMFF7PkKdr)k4J0BnN61YvcrQJ3PsPG45HdowYrYVV9uCnMigaYq1CW0WkWHc(bg8Snbkqhn4goC8wZfHvzMKGcuqkHdjQoZrK64DQukiEE4GJLCKaxUhojbvUWrHhXaqM)wvaabWL7HtsqduQjxixhRqtKmQY4Qm8kqk8Wc7MUq5fWZ6tkBIeJQCWxkFIVOXiNkPfan8qGJ3PsXtV1CoyWbVU55kuZ(Y0rbGpBUt80BnNdg8LYN4lAmYPsAbqdpe44DQu80BnNhDDZZvOM9LPJcaF2CN4P3AopkUkdVcKc1SVmDua4ZM7eWZ6tkBkgQKsGbZFRkaGa4Y9WjjObk1KlKRJvOjqevzCvgEfifoKTJwa0T)u(DUaEwFszqkcmy(9TNQqoe9RGpsV1CQxlxjePoENkLcINho4yjhj)(2tX1yIyaihCdhoER5IWQmtsqbkiLWHevN5wgxD7lOLHzyvn(ovgdaDG1U21Aba]] )

end
