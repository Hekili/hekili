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
            
            elseif k == 'deficit' then
                return t.max - t.current

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
                if settings.cycle and azerite.festermight.enabled and settings.festermight_cycle and dot.festering_wound.stack >= 2 and active_dot.festering_wound < spell_targets.festering_strike then return "festering_wound" end
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
            icd = 3,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 348565,

            cycle = 'virulent_plague',

            nodebuff = "outbreak",
            usable = function () return target.exists or active_dot.outbreak == 0, "requires real target or no other outbreaks up" end,

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
            nomounted = true,

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


    spec:RegisterPack( "Unholy", 20200808, [[dCeHEbqibXJeqSjb1OiHofjYReQAwcWTekv2fr)sqAyKahtkLLjvLNjvvMMqjxJe02eq6BcLIXjvv5CcLswNqPkZtkv3df2hjQdkGkTqPk9qbuQjkGcCrbuInkuQQtkGcTsuKxkukv3uaf1ofkgQqPuwQakYtHQPku5QcOK2QakO9sQ)IyWu6WuTyP4XqMmQUSQnd4Zqz0a50kwTuvvVgf1SP42O0Uf9BjdxihxavTCqpNW0v66K02Ls(UanEbuX5LkRxQI5du7hP1TPJtJZ996y6tb9Paf0FkO)KT1xFXM(fOA8Tl6A8ihXSJDnE6SxJhynbvMonEK3zkNRJtJlkvi6ACq7gjI9cnuSzbP2irfBOIHv147ujc6aBOIHffQgVrDmBGXu3OX5(EDm9PG(uGc6pf0FY26RVytF9tJlIoshtFkSpnoOHZFQB048lqA8aHAdSMGkth1gyW9fe1gBphmqlLPaHAbTBKi2l0qXMfKAJevSHkgwvJVtLiOdSHkgwuOuMceQnWvftvSuB)fa12Nc6tbuMOmfiuBGnipXUi2JYuGqTXoQnWLZpNAdmpjNAJ9H)9CjLPaHAJDuBGDLToCpNAxhI9LmaulQs(StLcQDlQfEmvJdPwuL8zNkfsktbc1g7O2atoACJi0y)kxQTaO2yBvWdP2n4DMfsnUzeRqhNg)cXt0f640X0Moon(tVXCUUxnoco7HJRXHQ5L7WEYwK2OwLPwmeNAdtTq1CqKOk4HuB7uBSuGg3r7uPgN9SfSJuaeJkA4eo8oRqV6y6thNg)P3yox3RghbN9WX1487liINCc)iVtUdI5jXOwWGP2OVspQqemqLQr6ODADQnm16ODADYZZoxqTmO2204oANk14nMQ4KcGSGo55z70RoM(PJtJ)0BmNR7vJJGZE44ACfPwuvgEfmLEuHCtxK4s4z9jfuB7uBGsTHPwuvgEfmLoKTJuaKf0j87Cj8S(KcQvzQfvLHxbtjQs(tX5eZaCGcIUeEwFsb1Qe1cgm1IQYWRGP0HSDKcGSGoHFNlHN1NuqTTtT9rTGbtTOccvJ2PsHCYda4nMtwO6cs(0BmNRXD0ovQXXuDiF8KuaeVNdRfKE1XelDCA8NEJ5CDVACeC2dhxJ3OcaiHhXS5cbbOGOlvJOwWGP2gvaaj8iMnxiiafeDcQuZ9qPyDeZuB7uBBTPXD0ovQXxqNOMnLAYjafeD9QJrH6404p9gZ56E14i4ShoUgpeQLFFbr8Kt4h5DYDqmpjMg3r7uPghOqQIZjEpho7jn3z1RoMavhNg)P3yox3RghbN9WX148ALOkrpxOVNtamo7jnQWucpRpPGAzqTkqJ7ODQuJJQe9CH(EobW4SxV6yIn6404p9gZ56E14i4ShoUgpeQLFFbr8Kt4h5DYDqmpjMg3r7uPgpsfoaDtIrAmUy1RoM(thNg)P3yox3RghbN9WX14RBEUshY2rkaYc6eUZMNlF6nMZP2Wu7fINOlBnIPssbqIoe4ODQuYozbP2WuBJkaGunbvMoIyHpXwqs1iQfmyQ9cXt0LTgXujPairhcC0ovkzNSGuByQn6R0JkebduPAKoANwNAbdMAx38CLoKTJuaKf0jCNnpx(0BmNtTHP2OVspQqemqLQr6ODADQnm1IQYWRGP0HSDKcGSGoHFNlHN1NuqTktTbQcOwWGP21npxPdz7ifazbDc3zZZLp9gZ5uByQn6R0HSDemqLQr6ODADnUJ2PsnEWcA4T(Ke4fv6j66vhtSLoon(tVXCUUxnoco7HJRXdHA53xqep5e(rENCheZtIrTHP2gvaaPAcQmDeXcFITGKQruByQneQ9cXt0LTgXujPairhcC0ovkzNSGuByQneQDDZZv6q2osbqwqNWD28C5tVXCo1cgm1Uoe7RCh2t2IWNtTTtTOQm8kyk9Oc5MUiXLWZ6tk04oANk14blOH36tsGxuPNORxDmTPaDCA8NEJ5CDVACeC2dhxJhc1YVVGiEYj8J8o5oiMNetJ7ODQuJdNOiZjtsero66vhtBTPJtJ7ODQuJdVhnjgbW4SxOXF6nMZ19Qx9QX5hWvnRooDmTPJtJ7ODQuJZojNaa)75A8NEJ5CDV6vhtF6404p9gZ56E14vKgx8vJ7ODQuJ3YHJ3yUgVLBuVghvLHxbtPqLLTscMdXQoZLWZ6tkO22PwfsTHP21npxPqLLTscMdXQoZLp9gZ5A8woKKo714rvzMeJauqcMdXQoZ1RoM(PJtJ)0BmNR7vJJGZE44ACOAoisuf8qj)adAwQvzQnqvi1gMAvKAJ(kXCiw1zU0r706ulyWuBiu76MNRuOYYwjbZHyvN5YNEJ5CQvjQnm1cvZl5hyqZsTkZGAvOg3r7uPg3Hippzli85QxDmXshNg)P3yox3RghbN9WX14rFLyoeR6mx6ODADQfmyQneQDDZZvkuzzRKG5qSQZC5tVXCUg3r7uPgVXufNaOc70RogfQJtJ)0BmNR7vJJGZE44A8gvaaPAcQmDea4ZE6KQrulyWuB0xjMdXQoZLoANwNAbdMAvKAx38CLoKTJuaKf0jCNnpx(0BmNtTHP2OVspQqemqLQr6ODADQvjnUJ2PsnEZHIdzEsm9QJjq1XPXF6nMZ19QXrWzpCCnUIuBJkaGunbvMoIyHpXwqs1iQnm12OcaibUypKDWaTs4z9jfuB7mOwfsTkrTGbtToANwN88SZfuRYmO2(O2WuRIuBJkaGunbvMoIyHpXwqs1iQfmyQTrfaqcCXEi7GbALWZ6tkO22zqTkKAvsJ7ODQuJBgmqRG0)QCm2NRE1XeB0XPXF6nMZ19QXrWzpCCnUIuB0xjMdXQoZLoANwNAdtTRBEUsHklBLemhIvDMlF6nMZPwLOwWGP2OVspQqemqLQr6ODADnUJ2PsnUNOlwOBii3y0RoM(thNg)P3yox3RghbN9WX14oANwN88SZfuRYmO2(OwWGPwfPwOAEj)adAwQvzguRcP2WulunhejQcEOKFGbnl1QmdQnqva1QKg3r7uPg3Hippjs1iUE1XeBPJtJ)0BmNR7vJJGZE44ACfP2OVsmhIvDMlD0oTo1gMAx38CLcvw2kjyoeR6mx(0BmNtTkrTGbtTrFLEuHiyGkvJ0r706AChTtLACGb(gtvC9QJPnfOJtJ)0BmNR7vJJGZE44A8gvaaPAcQmDeXcFITGKQruByQ1r706KNNDUGAzqTTrTGbtTnQaasGl2dzhmqReEwFsb12o1IH4uByQ1r706KNNDUGAzqTTPXD0ovQXBCmsbqw4GywOxDmT1Moon(tVXCUUxnoco7HJRX3H9uRYuBFkGAbdMAdHAFGxDIIoxcD2OjXioBKzwv(jydM3Qml5j2KNAbdMAdHAFGxDIIox2AetLKcGWp7iUg3r7uPgxvCYSNvOxDmT1Noon(tVXCUUxnUJ2PsnU3JaKdDbbOYLuaKOk4HACeC2dhxJRi1EH4j6YwJyQKuaKOdboANkLp9gZ5uByQneQDDZZvQMGkthba(SNo5tVXCo1Qe1cgm1Qi1gc1EH4j6suL8NIZjMb4afeDjR3)fKAdtTHqTxiEIUS1iMkjfaj6qGJ2Ps5tVXCo1QKgpD2RX9EeGCOliavUKcGevbpuV6yARF6404p9gZ56E14oANk14Epcqo0feGkxsbqIQGhQXrWzpCCnoQkdVcMspQqUPlsCj8S(KcQTDQTTyrTHPwfP2leprxIQK)uCoXmahOGOlz9(VGulyWu7fINOlBnIPssbqIoe4ODQu(0BmNtTHP21npxPAcQmDea4ZE6Kp9gZ5uRsA80zVg37raYHUGau5skasuf8q9QJPTyPJtJ)0BmNR7vJ7ODQuJ79ia5qxqaQCjfajQcEOghbN9WX147WEYwe(CQTDQfvLHxbtPhvi30fjUeEwFsb1gp12VyPXtN9ACVhbih6ccqLlPairvWd1RoM2uOoon(tVXCUUxnUJ2PsnUla1YZliqVNcsqf0nACeC2dhxJZFJkaGe69uqcQGUHWFJkaGuSoIzQTDQTnnE6SxJ7cqT88cc07PGeubDJE1X0wGQJtJ)0BmNR7vJ7ODQuJ7cqT88cc07PGeubDJghbN9WX14rFLyQoKpEskaI3ZH1cs6ODADQnm1g9v6rfIGbQunshTtRRXtN9ACxaQLNxqGEpfKGkOB0RoM2In6404p9gZ56E14oANk14UaulpVGa9Ekibvq3OXrWzpCCnoQkdVcMspQqUPlsCj8oVJAdtTksTxiEIUevj)P4CIzaoqbrxY69FbP2Wu7oSNSfHpNABNArvz4vWuIQK)uCoXmahOGOlHN1NuqTXtT9PaQfmyQneQ9cXt0LOk5pfNtmdWbki6swV)li1QKgpD2RXDbOwEEbb69uqcQGUrV6yAR)0XPXF6nMZ19QXD0ovQXDbOwEEbb69uqcQGUrJJGZE44A8DypzlcFo12o1IQYWRGP0JkKB6IexcpRpPGAJNA7tbA80zVg3fGA55feO3tbjOc6g9QJPTylDCA8NEJ5CDVAChTtLA8wJyQKuae(zhX14i4ShoUgxrQfvLHxbtPhvi30fjUeEN3rTHPw(BubaKaxShojgjyPMCPyDeZuRYmO2yrTHP2leprx2AetLKcGeDiWr7uP8P3yoNAvIAbdMABubaKQjOY0raGp7PtQgrTGbtTrFLyoeR6mx6ODADnE6SxJ3AetLKcGWp7iUE1X0Nc0XPXF6nMZ19QXD0ovQXHoB0KyeNnYmRk)eSbZBvML8eBYRXrWzpCCnoQkdVcMspQqUPlsCj8S(KcQTDQTpQfmyQDDZZv6q2osbqwqNWD28C5tVXCo1cgm1c9HtERNR05CHCsQTDQvHA80zVgh6SrtIrC2iZSQ8tWgmVvzwYtSjVE1X0xB6404p9gZ56E14oANk14nDyvEsZpXnSE6inoco7HJRXrvz4vWukuzzRKG5qSQZCj8S(KcQvzQnqva1cgm1gc1UU55kfQSSvsWCiw1zU8P3yoNAdtT7WEQvzQTpfqTGbtTHqTpWRorrNlHoB0KyeNnYmRk)eSbZBvML8eBYRXtN9A8MoSkpP5N4gwpDKE1X0xF6404p9gZ56E14oANk149)feqvqZHACeC2dhxJh9vI5qSQZCPJ2P1PwWGP2qO21npxPqLLTscMdXQoZLp9gZ5uByQDh2tTktT9PaQfmyQneQ9bE1jk6Cj0zJMeJ4SrMzv5NGnyERYSKNytEnE6SxJ3)xqavbnhQxDm91pDCA8NEJ5CDVAChTtLACm3CKBmhkin3zwJJGZE44A8OVsmhIvDMlD0oTo1cgm1gc1UU55kfQSSvsWCiw1zU8P3yoNAdtT7WEQvzQTpfqTGbtTHqTpWRorrNlHoB0KyeNnYmRk)eSbZBvML8eBYRXtN9ACm3CKBmhkin3zwV6y6lw6404p9gZ56E14oANk14yWkXeKi4W6gc0XUghbN9WX14q18uB7mO2(rTHPwfP2Dyp1Qm12NcOwWGP2qO2h4vNOOZLqNnAsmIZgzMvLFc2G5TkZsEIn5PwL04PZEnogSsmbjcoSUHaDSRxDm9PqDCA8NEJ5CDVACeC2dhxJJQYWRGP0HSDKcGSGoHFNlH35DulyWuB0xjMdXQoZLoANwNAbdMABubaKQjOY0raGp7PtQgPXD0ovQXJQDQuV6y6lq1XPXF6nMZ19QXrWzpCCnoVwzRbQAEUKiJJPEj8S(KcQTDgulgIRXD0ovQXl1TbENz9QJPVyJoon(tVXCUUxnUJ2PsnoYngIJ2PsIzeRg3mILKo714xiEIUqV6y6R)0XPXF6nMZ19QXD0ovQXrUXqC0ovsmJy14MrSK0zVghvLHxbtHE1X0xSLoon(tVXCUUxnoco7HJRXD0oTo55zNlOwLzqT9PXflCqRoM204oANk14i3yioANkjMrSACZiws6SxJ711RoM(PaDCA8NEJ5CDVACeC2dhxJ7ODADYZZoxqTmO2204IfoOvhtBAChTtLACKBmehTtLeZiwnUzeljD2RXXEE4G0RoM(1Moon(tVXCUUxnUJ2PsnoWf7HtIrelCy(ACeC2dhxJZFJkaGe4I9WjXibl1KlfRJyMABNAJLgh1HmNSoe7RqhtB6vVA8i4rfBJV640X0MoonUJ2PsnEuTtLA8NEJ5CDV6vhtF6404oANk14qFeNWVZ14p9gZ56E1RoM(PJtJ)0BmNR7vJNo714Epcqo0feGkxsbqIQGhQXD0ovQX9EeGCOliavUKcGevbpuV6yILoon(tVXCUUxno)gVtJ3Ng3r7uPg3HSDKcGSGoHFNRx9QXrvz4vWuOJthtB6404oANk14oKTJuaKf0j87Cn(tVXCUUx9QJPpDCA8NEJ5CDVACeC2dhxJZFJkaGe4I9WjXibl1KlfRJyMAvMb1glQnm1Qi16ODADYZZoxqTkZGA7JAbdMAdHAVq8eDzRrmvskas0HahTtLYNEJ5CQfmyQneQ175WzVK1XufKcGSGoHFNlF6nMZPwWGP2leprx2AetLKcGeDiWr7uP8P3yoNAdtTksTRBEUs1euz6iaWN90jF6nMZP2WulQkdVcMs1euz6iaWN90jHN1NuqTTZGA7h1cgm1gc1UU55kvtqLPJaaF2tN8P3yoNAvIAvsJ7ODQuJ7rfYnDrIRxDm9thNg)P3yox3RghbN9WX14HqTqF4K365kDoxiFGZiwb1cgm1c9HtERNR05CHCsQvzQTnfQXD0ovQX5oKzYc9uauqwFNk1RoMyPJtJ)0BmNR7vJJGZE44ACOAoisuf8qj)adAwQTDQTTyPXD0ovQXfQSSvsWCiw1zUE1XOqDCA8NEJ5CDVACeC2dhxJFH4j6YwJyQKuaKOdboANkLp9gZ5uByQn6R0JkebduPAKoANwNAbdMA5VrfaqcCXE4KyKGLAYLI1rmtTTtTXIAdtTHqTxiEIUS1iMkjfaj6qGJ2Ps5tVXCo1gMAvKAdHA9EoC2lzDmvbPailOt435YNEJ5CQfmyQ175WzVK1XufKcGSGoHFNlF6nMZP2WuB0xPhvicgOs1iD0oTo1QKg3r7uPgxnbvMoca8zpD6vhtGQJtJ)0BmNR7vJJGZE44AChTtRtEE25cQvzguBFuByQvrQvrQfvLHxbtj)(cI4jNWpY7KWZ6tkO22zqTyio1gMAdHAx38CL8dmMlF6nMZPwLOwWGPwfPwuvgEfmL8dmMlHN1NuqTTZGAXqCQnm1UU55k5hymx(0BmNtTkrTkPXD0ovQXvtqLPJaaF2tNE1XeB0XPXF6nMZ19QXD0ovQXfLQHaVhDOghbN9WX14RdX(k3H9KTi85uB7uB)rTHP21HyFL7WEYwe(CQvzQnwACuhYCY6qSVcDmTPxDm9Noon(tVXCUUxnoco7HJRXvKAdHAH(WjV1Zv6CUq(aNrScQfmyQf6dN8wpxPZ5c5KuRYuBFkGAvIAdtTq18uB7mOwfP22O2yh12OcaivtqLPJaaF2tNunIAvsJ7ODQuJlkvdbEp6q9QJj2shNg3r7uPgxnbvMosJzWaTA8NEJ5CDV6vVACSNhoiDC6yAthNg)P3yox3RghbN9WX14nQaasHkN)KWRIvcVJwQnm1cvZl3H9KTiXIAvMAXqCQnm1gc12YHJ3yUmQkZKyeGcsWCiw1zo1cgm1g9vI5qSQZCPJ2P114oANk1487licQgJE1X0Noon(tVXCUUxnoco7HJRXHQ5GirvWdL8dmOzP22P22If1gMAHQ5L7WEYwKyrTktTyio1gMAdHAB5WXBmxgvLzsmcqbjyoeR6mxJ7ODQuJZVVGiOAm6vht)0XPXF6nMZ19QXrWzpCCnUIuRIul)nQaasGl2dNeJeSutUunIAdtTksTOQm8kyk9Oc5MUiXLWZ6tkOwLPwfsTHPwfP2qO2leprx2AetLKcGeDiWr7uP8P3yoNAbdMAdHAx38CLQjOY0raGp7Pt(0BmNtTkrTGbtTxiEIUS1iMkjfaj6qGJ2Ps5tVXCo1gMAx38CLQjOY0raGp7Pt(0BmNtTHPwuvgEfmLQjOY0raGp7PtcpRpPGAvMAduQvjQvjQfmyQL)gvaajWf7HtIrcwQjxkwhXm1Qm12pQvjQnm1Qi1IQYWRGP0HSDKcGSGoHFNlHN1NuqTktTkKAbdMA53xqeMZbd0k5JWBmN41YPwL04oANk14cuPcXorSWH5RxDmXshNg)P3yox3RghbN9WX14ksTksT83OcaibUypCsmsWsn5s1iQnm1Qi1IQYWRGP0JkKB6IexcpRpPGAvMAvi1gMAvKAdHAVq8eDzRrmvskas0HahTtLYNEJ5CQfmyQneQDDZZvQMGkthba(SNo5tVXCo1Qe1cgm1EH4j6YwJyQKuaKOdboANkLp9gZ5uByQDDZZvQMGkthba(SNo5tVXCo1gMArvz4vWuQMGkthba(SNoj8S(KcQvzQnqPwLOwLOwWGPw(BubaKaxShojgjyPMCPyDeZuRYuB)OwLO2WuRIulQkdVcMshY2rkaYc6e(DUeEwFsb1Qm1QqQfmyQLFFbryohmqRKpcVXCIxlNAvsJ7ODQuJJmEWjXicqoVck0RogfQJtJ)0BmNR7vJJGZE44ACOAoisuf8qj)adAwQTDQTpfqTHP2qO2woC8gZLrvzMeJauqcMdXQoZ14oANk1487licQgJE1XeO6404p9gZ56E14i4ShoUgN)gvaajWf7HtIrcwQjxkwhXm12o1glQnm1Qi1IQYWRGP0JkKB6IexcpRpPGABNA7h1gMAvKAdHAVq8eDzRrmvskas0HahTtLYNEJ5CQfmyQneQDDZZvQMGkthba(SNo5tVXCo1cgm1EH4j6YwJyQKuaKOdboANkLp9gZ5uByQDDZZvQMGkthba(SNo5tVXCo1gMArvz4vWuQMGkthba(SNoj8S(KcQTDQn2qTkrTkrTGbtT83OcaibUypCsmsWsn5sX6iMP22P22O2WuRIulQkdVcMshY2rkaYc6e(DUeEwFsb1Qm1QqQfmyQLFFbryohmqRKpcVXCIxlNAvsJ7ODQuJdCXE4KyeXchMVE1XeB0XPXF6nMZ19QXrWzpCCnEiuBlhoEJ5YOQmtIrakibZHyvN5AChTtLAC(9febvJrV6vJ711XPJPnDCA8NEJ5CDVACeC2dhxJJQYWRGP0JkKB6IexcpRpPqJ7ODQuJZVVGiEYj8J8o9QJPpDCA8NEJ5CDVACeC2dhxJJQYWRGP0JkKB6IexcpRpPqJ7ODQuJZpWyUE1X0pDCA8NEJ5CDVACeC2dhxJZVVGiEYj8J8o5oiMNeJAdtTq1CqKOk4Hs(bg0SuB7uBBXIAdtTHqTRBEUYgvOyNeJik4fYNEJ5CQnm1gc12YHJ3yUmQkZKyeGcsWCiw1zUg3r7uPg)rd)SdsV6yILoon(tVXCUUxnoco7HJRX53xqep5e(rENCheZtIrTHPwfP2qOw(9feH5CWaTsGGLAYpNSoe7RGAdtTRBEUYgvOyNeJik4fYNEJ5CQvjQnm1gc12YHJ3yUmQkZKyeGcsWCiw1zUg3r7uPg)rd)SdsV6yuOoon(tVXCUUxnoco7HJRX53xqep5e(rENCheZtIrTHPwuvgEfmLEuHCtxK4s4z9jfAChTtLACbQuHyNiw4W81RoMavhNg)P3yox3RghbN9WX1487liINCc)iVtUdI5jXO2WulQkdVcMspQqUPlsCj8S(KcnUJ2PsnoY4bNeJia58kOqV6yIn6404p9gZ56E14i4ShoUgpeQTLdhVXCzuvMjXiafKG5qSQZCnUJ2Psn(Jg(zhKE1X0F6404p9gZ56E14oANk14axShojgrSWH5RXrWzpCCno)nQaasGl2dNeJeSutUuSoIzQTDguBFuByQfvLHxbtj)(cI4jNWpY7KWZ6tkO2WulQkdVcMspQqUPlsCj8S(KcQvzQvHuByQvrQfvLHxbtPdz7ifazbDc)oxcpRpPGAvMAvi1cgm1YVVGimNdgOvYhH3yoXRLtTkPXrDiZjRdX(k0X0ME1XeBPJtJ)0BmNR7vJJGZE44A8gvaaPqLZFs4vXkH3rl1gMAHQ5L7WEYwKyrTktTyiUg3r7uPgNFFbrq1y0RoM2uGoon(tVXCUUxnoco7HJRXBubaKcvo)jHxfReEhTuByQneQTLdhVXCzuvMjXiafKG5qSQZCQfmyQn6ReZHyvN5shTtRRXD0ovQX53xqeung9QJPT20XPXF6nMZ19QXrWzpCCnounhejQcEOKFGbnl12o12wSO2WuRIulQkdVcMspQqUPlsCj8S(KcQvzQvHulyWul)nQaasGl2dNeJeSutUuSoIzQvzQnwuRsuByQneQTLdhVXCzuvMjXiafKG5qSQZCnUJ2Psno)(cIGQXOxDmT1Noon(tVXCUUxnUJ2PsnUavQqStelCy(ACeC2dhxJRi1Qi1IQYWRGP0HSDKcGSGoHFNlHN1NuqTktTkKAbdMA53xqeMZbd0k5JWBmN41YPwLO2WuRIulQkdVcMspQqUPlsCj8S(KcQvzQvHuByQL)gvaajWf7HtIrcwQjxkwhXm1Qm1QaQfmyQL)gvaajWf7HtIrcwQjxkwhXm1Qm12pQvjQnm1Qi1Ud7jBr4ZP22PwuvgEfmL87liINCc)iVtcpRpPGAJNABtbulyWu7oSNSfHpNAvMArvz4vWu6rfYnDrIlHN1NuqTkrTkPXrDiZjRdX(k0X0ME1X0w)0XPXF6nMZ19QXD0ovQXrgp4KyebiNxbfACeC2dhxJRi1Qi1IQYWRGP0HSDKcGSGoHFNlHN1NuqTktTkKAbdMA53xqeMZbd0k5JWBmN41YPwLO2WuRIulQkdVcMspQqUPlsCj8S(KcQvzQvHuByQL)gvaajWf7HtIrcwQjxkwhXm1Qm1QaQfmyQL)gvaajWf7HtIrcwQjxkwhXm1Qm12pQvjQnm1Qi1Ud7jBr4ZP22PwuvgEfmL87liINCc)iVtcpRpPGAJNABtbulyWu7oSNSfHpNAvMArvz4vWu6rfYnDrIlHN1NuqTkrTkPXrDiZjRdX(k0X0ME1X0wS0XPXF6nMZ19QXrWzpCCnounhejQcEOKFGbnl12o12NcO2WuBiuBlhoEJ5YOQmtIrakibZHyvN5AChTtLAC(9febvJrV6yAtH6404p9gZ56E14i4ShoUgxrQvrQvrQvrQL)gvaajWf7HtIrcwQjxkwhXm12o1glQnm1gc12OcaivtqLPJaaF2tNunIAvIAbdMA5VrfaqcCXE4KyKGLAYLI1rmtTTtT9JAvIAdtTOQm8kyk9Oc5MUiXLWZ6tkO22P2(rTkrTGbtT83OcaibUypCsmsWsn5sX6iMP22P22OwLO2WuRIulQkdVcMshY2rkaYc6e(DUeEwFsb1Qm1QqQfmyQLFFbryohmqRKpcVXCIxlNAvsJ7ODQuJdCXE4KyeXchMVE1X0wGQJtJ)0BmNR7vJJGZE44AC(9feXtoHFK3j3bX8KyAChTtLACbQuHyNiw4W81RoM2In6404p9gZ56E14i4ShoUgpeQTLdhVXCzuvMjXiafKG5qSQZCnUJ2Psno)(cIGQXOx9QxnERdftL6y6tb9PafeOTflnEqhMtIj04bgzJk4Eo1gOuRJ2PsQ1mIviPmPXD1fub144dRQX3PYaBOdSA8iybmMRXdeQnWAcQmDuBGb3xquBS9CWaTuMceQf0UrIyVqdfBwqQnsuXgQyyvn(ovIGoWgQyyrHszkqO2axvmvXsT9xauBFkOpfqzIYuGqTb2G8e7Iypktbc1g7O2axo)CQnW8KCQn2h(3ZLuMceQn2rTb2v26W9CQDDi2xYaqTOk5ZovkO2TOw4XunoKArvYNDQuiPmfiuBSJAdm5OXnIqJ9RCP2cGAJTvbpKA3G3zwiPmrzkqO2albohPUNtTnhOGNArfBJVuBZXMuiP2axe6rRGAZkJDGCilGQHAD0ovkO2knDsktbc16ODQuiJGhvSn(YaW4cMPmfiuRJ2PsHmcEuX24B8mcfOkoLPaHAD0ovkKrWJk2gFJNrOUkg7Z13Psktbc1INEKauTul0ho12OcaCo1kwFfuBZbk4PwuX24l12CSjfuRNCQnc(yxuT7Kyu7iOwELxszkqOwhTtLcze8OITX34zeQi9ibOAjI1xbLjhTtLcze8OITX34zeAuTtLuMC0ovkKrWJk2gFJNrOqFeNWVZPm5ODQuiJGhvSn(gpJqvfNm7zdiD2ZW7raYHUGau5skasuf8qktoANkfYi4rfBJVXZiuhY2rkaYc6e(DEa8B8og9rzIYuGqTbwcCosDpNAFRd7O2Dyp1UGo16OTGu7iOwVLpgVXCjLjhTtLcgStYjaW)EoLjhTtLI4zeAlhoEJ5bKo7zevLzsmcqbjyoeR6mpGwUr9mqvz4vWukuzzRKG5qSQZCj8S(KI2vy41npxPqLLTscMdXQoZLp9gZ5uMceQnWKJg3icGAdmUNvea16jNARf0HuBHH4cktoANkfXZiuhI88KTGWNBadadOAoisuf8qj)adAwLdufgwXOVsmhIvDMlD0oToyWHSU55kfQSSvsWCiw1zU8P3yoxPWq18s(bg0SkZqHuMC0ovkINrOnMQ4eavyxadaJOVsmhIvDMlD0oToyWHSU55kfQSSvsWCiw1zU8P3yoNYKJ2Psr8mcT5qXHmpjwadaJgvaaPAcQmDea4ZE6KQrGbh9vI5qSQZCPJ2P1bdwX1npxPdz7ifazbDc3zZZLp9gZ5HJ(k9OcrWavQgPJ2P1vIYKJ2Psr8mc1myGwbP)v5ySp3agagk2OcaivtqLPJiw4tSfKunkCJkaGe4I9q2bd0kHN1Nu0odfQeyWoANwN88SZfkZOVWk2OcaivtqLPJiw4tSfKuncm4gvaajWf7HSdgOvcpRpPODgkujktoANkfXZiuprxSq3qqUXeWaWqXOVsmhIvDMlD0oTE41npxPqLLTscMdXQoZLp9gZ5kbgC0xPhvicgOs1iD0oToLjhTtLI4zeQdrEEsKQr8agagoANwN88SZfkZOpWGveQMxYpWGMvzgkmmunhejQcEOKFGbnRYmcufOeLjhTtLI4zekWaFJPkEadadfJ(kXCiw1zU0r706Hx38CLcvw2kjyoeR6mx(0BmNReyWrFLEuHiyGkvJ0r706uMC0ovkINrOnogPailCqmlcyay0OcaivtqLPJiw4tSfKunkSJ2P1jpp7CbJ2adUrfaqcCXEi7GbALWZ6tkAhdXd7ODADYZZoxWOnktuMceQnWwvSfl1UWjz(RGAvfo2Pm5ODQuepJqvfNm7zfbmam2H9k3NcadoKh4vNOOZLqNnAsmIZgzMvLFc2G5TkZsEIn5bdoKh4vNOOZLTgXujPai8ZoItzYr7uPiEgHQkoz2Zgq6SNH3JaKdDbbOYLuaKOk4Hbmamu8cXt0LTgXujPairhcC0ovkF6nMZdhY6MNRunbvMoca8zpDYNEJ5CLadwXqUq8eDjQs(tX5eZaCGcIUK17)cgoKleprx2AetLKcGeDiWr7uP8P3yoxjktoANkfXZiuvXjZE2asN9m8EeGCOliavUKcGevbpmGbGbQkdVcMspQqUPlsCj8S(KI2BlwHv8cXt0LOk5pfNtmdWbki6swV)liyWxiEIUS1iMkjfaj6qGJ2Ps5tVXCE41npxPAcQmDea4ZE6Kp9gZ5krzYr7uPiEgHQkoz2Zgq6SNH3JaKdDbbOYLuaKOk4Hbmam2H9KTi85TJQYWRGP0JkKB6IexcpRpPi((flktoANkfXZiuvXjZE2asN9mCbOwEEbb69uqcQGUjGbGb)nQaasO3tbjOc6gc)nQaasX6iMBVnktoANkfXZiuvXjZE2asN9mCbOwEEbb69uqcQGUjGbGr0xjMQd5JNKcG49CyTGKoANwpC0xPhvicgOs1iD0oToLjhTtLI4zeQQ4KzpBaPZEgUaulpVGa9Ekibvq3eWaWavLHxbtPhvi30fjUeEN3fwXleprxIQK)uCoXmahOGOlz9(VGH3H9KTi85TJQYWRGPevj)P4CIzaoqbrxcpRpPi((uayWHCH4j6suL8NIZjMb4afeDjR3)fujktoANkfXZiuvXjZE2asN9mCbOwEEbb69uqcQGUjGbGXoSNSfHpVDuvgEfmLEuHCtxK4s4z9jfX3NcOm5ODQuepJqvfNm7zdiD2ZO1iMkjfaHF2r8agagkIQYWRGP0JkKB6IexcVZ7cZFJkaGe4I9WjXibl1KlfRJywzgXk8fINOlBnIPssbqIoe4ODQu(0BmNReyWnQaas1euz6iaWN90jvJado6ReZHyvN5shTtRtzYr7uPiEgHQkoz2Zgq6SNb0zJMeJ4SrMzv5NGnyERYSKNyt(agagOQm8kyk9Oc5MUiXLWZ6tkAVpWGx38CLoKTJuaKf0jCNnpx(0BmNdgm0ho5TEUsNZfYjBxHuMC0ovkINrOQItM9SbKo7z00Hv5jn)e3W6PJcyayGQYWRGPuOYYwjbZHyvN5s4z9jfkhOkam4qw38CLcvw2kjyoeR6mx(0BmNhEh2RCFkam4qEGxDIIoxcD2OjXioBKzwv(jydM3Qml5j2KNYKJ2Psr8mcvvCYSNnG0zpJ()ccOkO5WagagrFLyoeR6mx6ODADWGdzDZZvkuzzRKG5qSQZC5tVXCE4DyVY9PaWGd5bE1jk6Cj0zJMeJ4SrMzv5NGnyERYSKNytEktoANkfXZiuvXjZE2asN9mWCZrUXCOG0CN5agagrFLyoeR6mx6ODADWGdzDZZvkuzzRKG5qSQZC5tVXCE4DyVY9PaWGd5bE1jk6Cj0zJMeJ4SrMzv5NGnyERYSKNytEktoANkfXZiuvXjZE2asN9mWGvIjirWH1neOJ9agagq18TZOFHvCh2RCFkam4qEGxDIIoxcD2OjXioBKzwv(jydM3Qml5j2KxjktoANkfXZi0OANkdyayGQYWRGP0HSDKcGSGoHFNlH35DGbh9vI5qSQZCPJ2P1bdUrfaqQMGkthba(SNoPAeLPaHAdm7tU(KtIrTbgoqvZZLAJTzCm1tTJGADQncofC2oktoANkfXZi0sDBG3zoGbGbVwzRbQAEUKiJJPEj8S(KI2zGH4uMC0ovkINrOi3yioANkjMrSbKo7zCH4j6cktoANkfXZiuKBmehTtLeZi2asN9mqvz4vWuqzYr7uPiEgHICJH4ODQKygXgGyHdAz0waPZEgE9agagoANwN88SZfkZOpktoANkfXZiuKBmehTtLeZi2aelCqlJ2ciD2Za75HdkGbGHJ2P1jpp7CbJ2Om5ODQuepJqbUypCsmIyHdZpauhYCY6qSVcgTfWaWG)gvaajWf7HtIrcwQjxkwhXC7XIYeLPaHAdCRalulSwFNkPm5ODQui96m43xqep5e(rExadaduvgEfmLEuHCtxK4s4z9jfuMC0ovkKE94zek)aJ5bmamqvz4vWu6rfYnDrIlHN1NuqzYr7uPq61JNrOpA4NDqbmam43xqep5e(rENCheZtIfgQMdIevbpuYpWGMT92Iv4qw38CLnQqXojgruWlKp9gZ5HdPLdhVXCzuvMjXiafKG5qSQZCktoANkfsVE8mc9rd)SdkGbGb)(cI4jNWpY7K7GyEsSWkgc)(cIWCoyGwjqWsn5NtwhI9veEDZZv2Ocf7KyerbVq(0BmNRu4qA5WXBmxgvLzsmcqbjyoeR6mNYKJ2PsH0RhpJqfOsfIDIyHdZpGbGb)(cI4jNWpY7K7GyEsSWOQm8kyk9Oc5MUiXLWZ6tkOm5ODQui96XZiuKXdojgraY5vqradad(9feXtoHFK3j3bX8KyHrvz4vWu6rfYnDrIlHN1NuqzYr7uPq61JNrOpA4NDqbmamcPLdhVXCzuvMjXiafKG5qSQZCktoANkfsVE8mcf4I9WjXiIfom)aqDiZjRdX(ky0wadad(BubaKaxShojgjyPMCPyDeZTZOVWOQm8kyk53xqep5e(rENeEwFsryuvgEfmLEuHCtxK4s4z9jfkRWWkIQYWRGP0HSDKcGSGoHFNlHN1NuOScbdMFFbryohmqRKpcVXCIxlxjktoANkfsVE8mcLFFbrq1ycyay0OcaifQC(tcVkwj8oAddvZl3H9KTiXszmeNYKJ2PsH0RhpJq53xqeunMagagnQaasHkN)KWRIvcVJ2WH0YHJ3yUmQkZKyeGcsWCiw1zoyWrFLyoeR6mx6ODADktoANkfsVE8mcLFFbrq1ycyayavZbrIQGhk5hyqZ2EBXkSIOQm8kyk9Oc5MUiXLWZ6tkuwHGbZFJkaGe4I9WjXibl1KlfRJyw5yPu4qA5WXBmxgvLzsmcqbjyoeR6mNYKJ2PsH0RhpJqfOsfIDIyHdZpauhYCY6qSVcgTfWaWqrfrvz4vWu6q2osbqwqNWVZLWZ6tkuwHGbZVVGimNdgOvYhH3yoXRLRuyfrvz4vWu6rfYnDrIlHN1NuOScdZFJkaGe4I9WjXibl1KlfRJywzfagm)nQaasGl2dNeJeSutUuSoIzL7NsHvCh2t2IWN3oQkdVcMs(9feXtoHFK3jHN1NueFBkam4DypzlcFUYOQm8kyk9Oc5MUiXLWZ6tkusjktoANkfsVE8mcfz8GtIreGCEfueaQdzozDi2xbJ2cyayOOIOQm8kykDiBhPailOt435s4z9jfkRqWG53xqeMZbd0k5JWBmN41YvkSIOQm8kyk9Oc5MUiXLWZ6tkuwHH5VrfaqcCXE4KyKGLAYLI1rmRScadM)gvaajWf7HtIrcwQjxkwhXSY9tPWkUd7jBr4ZBhvLHxbtj)(cI4jNWpY7KWZ6tkIVnfag8oSNSfHpxzuvgEfmLEuHCtxK4s4z9jfkPeLjhTtLcPxpEgHYVVGiOAmbmamGQ5GirvWdL8dmOzBVpfeoKwoC8gZLrvzMeJauqcMdXQoZPm5ODQui96XZiuGl2dNeJiw4W8dyayOOIkQi)nQaasGl2dNeJeSutUuSoI52Jv4qAubaKQjOY0raGp7PtQgPeyW83OcaibUypCsmsWsn5sX6iMBVFkfgvLHxbtPhvi30fjUeEwFsr79tjWG5VrfaqcCXE4KyKGLAYLI1rm3EBkfwruvgEfmLoKTJuaKf0j87Cj8S(KcLviyW87licZ5GbAL8r4nMt8A5krzYr7uPq61JNrOcuPcXorSWH5hWaWGFFbr8Kt4h5DYDqmpjgLjhTtLcPxpEgHYVVGiOAmbmamcPLdhVXCzuvMjXiafKG5qSQZCktuMC0ovkKOQm8kyky4q2osbqwqNWVZPm5ODQuirvz4vWuepJq9Oc5MUiXdyayWFJkaGe4I9WjXibl1KlfRJywzgXkSIoANwN88SZfkZOpWGd5cXt0LTgXujPairhcC0ovkF6nMZbdoeVNdN9swhtvqkaYc6e(DU8P3yohm4leprx2AetLKcGeDiWr7uP8P3yopSIRBEUs1euz6iaWN90jF6nMZdJQYWRGPunbvMoca8zpDs4z9jfTZOFGbhY6MNRunbvMoca8zpDYNEJ5CLuIYKJ2PsHevLHxbtr8mcL7qMjl0tbqbz9DQmGbGriqF4K365kDoxiFGZiwbyWqF4K365kDoxiNu52uiLjhTtLcjQkdVcMI4zeQqLLTscMdXQoZdyayavZbrIQGhk5hyqZ2EBXIYKJ2PsHevLHxbtr8mcvnbvMoca8zpDbmamUq8eDzRrmvskas0HahTtLYNEJ58WrFLEuHiyGkvJ0r706GbZFJkaGe4I9WjXibl1KlfRJyU9yfoKleprx2AetLKcGeDiWr7uP8P3yopSIH49C4SxY6yQcsbqwqNWVZLp9gZ5Gb79C4SxY6yQcsbqwqNWVZLp9gZ5HJ(k9OcrWavQgPJ2P1vIYKJ2PsHevLHxbtr8mcvnbvMoca8zpDbmamC0oTo55zNluMrFHvuruvgEfmL87liINCc)iVtcpRpPODgyiE4qw38CL8dmMlF6nMZvcmyfrvz4vWuYpWyUeEwFsr7mWq8WRBEUs(bgZLp9gZ5kPeLjhTtLcjQkdVcMI4zeQOune49Odda1HmNSoe7RGrBbmamwhI9vUd7jBr4ZBV)cVoe7RCh2t2IWNRCSOm5ODQuirvz4vWuepJqfLQHaVhDyadadfdb6dN8wpxPZ5c5dCgXkadg6dN8wpxPZ5c5Kk3NcukmunF7muSTyxJkaGunbvMoca8zpDs1iLOm5ODQuirvz4vWuepJqvtqLPJ0ygmqlLjktoANkfYleprxWG9SfSJuaeJkA4eo8oRiGbGbunVCh2t2I0MYyiEyOAoisuf8W2JLcOm5ODQuiVq8eDr8mcTXufNuaKf0jppBxadad(9feXtoHFK3j3bX8KyGbh9v6rfIGbQunshTtRh2r706KNNDUGrBuMC0ovkKxiEIUiEgHIP6q(4jPaiEphwlOagagkIQYWRGP0JkKB6IexcpRpPO9anmQkdVcMshY2rkaYc6e(DUeEwFsHYOQm8kykrvYFkoNygGduq0LWZ6tkucmyuvgEfmLoKTJuaKf0j87Cj8S(KI27dmyubHQr7uPqo5ba8gZjluDbjF6nMZPm5ODQuiVq8eDr8mcDbDIA2uQjNauq0dyay0OcaiHhXS5cbbOGOlvJadUrfaqcpIzZfccqbrNGk1CpukwhXC7T1gLjhTtLc5fINOlINrOafsvCoX75WzpP5oBadaJq43xqep5e(rENCheZtIrzYr7uPqEH4j6I4zekQs0Zf675eaJZ(agag8ALOkrpxOVNtamo7jnQWucpRpPGHcOm5ODQuiVq8eDr8mcnsfoaDtIrAmUydyayec)(cI4jNWpY7K7GyEsmktoANkfYleprxepJqdwqdV1NKaVOsprpGbGX6MNR0HSDKcGSGoH7S55YNEJ58WxiEIUS1iMkjfaj6qGJ2Psj7KfmCJkaGunbvMoIyHpXwqs1iWGVq8eDzRrmvskas0HahTtLs2jly4OVspQqemqLQr6ODADWGx38CLoKTJuaKf0jCNnpx(0BmNho6R0JkebduPAKoANwpmQkdVcMshY2rkaYc6e(DUeEwFsHYbQcadEDZZv6q2osbqwqNWD28C5tVXCE4OVshY2rWavQgPJ2P1Pm5ODQuiVq8eDr8mcnybn8wFsc8Ik9e9agagHWVVGiEYj8J8o5oiMNelCJkaGunbvMoIyHpXwqs1OWHCH4j6YwJyQKuaKOdboANkLStwWWHSU55kDiBhPailOt4oBEU8P3yohm41HyFL7WEYwe(82rvz4vWu6rfYnDrIlHN1NuqzYr7uPqEH4j6I4zekCIImNmjre5OhWaWie(9feXtoHFK3j3bX8KyuMC0ovkKxiEIUiEgHcVhnjgbW4SxqzIYKJ2PsHe75HdIb)(cIGQXeWaWOrfaqku58NeEvSs4D0ggQMxUd7jBrILYyiE4qA5WXBmxgvLzsmcqbjyoeR6mhm4OVsmhIvDMlD0oToLjhTtLcj2Zdhu8mcLFFbrq1ycyayavZbrIQGhk5hyqZ2EBXkmunVCh2t2IelLXq8WH0YHJ3yUmQkZKyeGcsWCiw1zoLjhTtLcj2Zdhu8mcvGkvi2jIfom)agagkQi)nQaasGl2dNeJeSutUunkSIOQm8kyk9Oc5MUiXLWZ6tkuwHHvmKleprx2AetLKcGeDiWr7uP8P3yohm4qw38CLQjOY0raGp7Pt(0BmNReyWxiEIUS1iMkjfaj6qGJ2Ps5tVXCE41npxPAcQmDea4ZE6Kp9gZ5Hrvz4vWuQMGkthba(SNoj8S(KcLduLucmy(BubaKaxShojgjyPMCPyDeZk3pLcRiQkdVcMshY2rkaYc6e(DUeEwFsHYkemy(9feH5CWaTs(i8gZjETCLOm5ODQuiXEE4GINrOiJhCsmIaKZRGIagagkQi)nQaasGl2dNeJeSutUunkSIOQm8kyk9Oc5MUiXLWZ6tkuwHHvmKleprx2AetLKcGeDiWr7uP8P3yohm4qw38CLQjOY0raGp7Pt(0BmNReyWxiEIUS1iMkjfaj6qGJ2Ps5tVXCE41npxPAcQmDea4ZE6Kp9gZ5Hrvz4vWuQMGkthba(SNoj8S(KcLduLucmy(BubaKaxShojgjyPMCPyDeZk3pLcRiQkdVcMshY2rkaYc6e(DUeEwFsHYkemy(9feH5CWaTs(i8gZjETCLOm5ODQuiXEE4GINrO87licQgtadadOAoisuf8qj)adA227tbHdPLdhVXCzuvMjXiafKG5qSQZCktoANkfsSNhoO4zekWf7HtIrelCy(bmam4VrfaqcCXE4KyKGLAYLI1rm3EScRiQkdVcMspQqUPlsCj8S(KI27xyfd5cXt0LTgXujPairhcC0ovkF6nMZbdoK1npxPAcQmDea4ZE6Kp9gZ5GbFH4j6YwJyQKuaKOdboANkLp9gZ5Hx38CLQjOY0raGp7Pt(0BmNhgvLHxbtPAcQmDea4ZE6KWZ6tkAp2OKsGbZFJkaGe4I9WjXibl1KlfRJyU92cRiQkdVcMshY2rkaYc6e(DUeEwFsHYkemy(9feH5CWaTs(i8gZjETCLOm5ODQuiXEE4GINrO87licQgtadaJqA5WXBmxgvLzsmcqbjyoeR6mxV6vRba]] )

end
