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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( ( pvptalent.necromancers_bargain.enabled and 45 or 90 ) - ( level > 48 and 15 or 0 ) ) end,
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


    spec:RegisterPack( "Unholy", 20200614, [[dCuGEbqibXJirLnjOgfj0PirELqvZsaDlPkIDr0VeKgguWXekTmPQ8mPkyAqHUMuvTnsu6BsvKgNufLZrIQY6KQq18Ks5EqP9jahuQIQwOuLEijQQMOufkDrsufTrsuGtsIc1kHIEjjki3uQIk7uOyOKOkSusuipfftvOYvLQqXwjrb1Ej1FrmykDyQwSu8yitgvxw1Mb8zOA0a50kwnjk61KGztXTrPDl63sgUqoUufYYb9CctxPRtsBxk57c04jrv68sL1lLQ5du7hP1XQJtZW996y6dd9HbmOSXIrzSkBSySh6xZSDrxZe5ifC8RzsN9AMEmjOY0PzI8ot5CDCAgrPcrxZaA3irpEOHIpli1gjQydvmSQgFNkrqhydvmSOq1mnQJzvgN6gnd33RJPpm0hgWGYglgLX2F)9mm0VMreDKoM(6VpndOHZFQB0m8lqAgLJA7XKGkth12J9(cIAvgkhCqlftLJAbTBKOhp0qXNfKAJevSHkgwvJVtLiOdSHkgwuOumvoQTNZ7O2(6pqQTpm0hgOysXu5OwLFqEIFrpoftLJA7juBppNFo12ZnjNAvga)B)skMkh12tOwL)kBD4Eo1Uoe)lzaOwuL8zNkfu7wul84QghsTOk5ZovkKumvoQTNqTkJC04grOkdQCP2cGAvEubpKA3G3vqi1mMrScDCAMleprxOJthtS640mp9gZ56E1mi4ShoUMbQMxUd7jBrILAdGAXrCQnm1cvZbrIQGhsTTrTyedAghTtLAg2ZwWosbqmQOHt4W7Sc9QJPpDCAMNEJ5CDVAgeC2dhxZWVVGiEYj8J8o5oifMeNAbdMAJ(k9OcrWbvQgPJ2P1P2WuRJ2P1jpp7Cb1ILAJvZ4ODQuZ0yQItkaYc6KNNTtV6y6bDCAMNEJ5CDVAgeC2dhxZOi1IQYWRGP0JkKB6IexcpRpPGABJAvwQnm1IQYWRGP0HSDKcGSGoHFNlHN1NuqTbqTOQm8kykrvYFkoNygGduq0LWZ6tkOwLOwWGPwuvgEfmLoKTJuaKf0j87Cj8S(KcQTnQTpQfmyQfvqOA0ovkKtEaaVXCYcvxqYNEJ5CnJJ2PsndUQd5JNKcG4TFyTG0RogmQJtZ80BmNR7vZGGZE44AMgvaaj8ifmxiiafeDPAe1cgm12OcaiHhPG5cbbOGOtqLAUhkfRJuGABJAJnwnJJ2PsnZc6e1SPutobOGORxDm9RJtZ80BmNR7vZGGZE44AMqOw(9feXtoHFK3j3bPWK4AghTtLAgGcPkoN4TF4SN0CNvV6yuwDCAMNEJ5CDVAgeC2dhxZWRvIQe9CH(EobW4SN0Octj8S(KcQfl1IbnJJ2PsndQs0Zf675eaJZE9QJPNQJtZ80BmNR7vZGGZE44AMqOw(9feXtoHFK3j3bPWK4AghTtLAMiv4a0njoPX4IvV6y6z640mp9gZ56E1mi4ShoUMzDZZv6q2osbqwqNWD28C5tVXCo1gMAVq8eDzRrmvskas0HahTtLs2jli1gMABubaKQjOY0rel8j(csQgrTGbtTxiEIUS1iMkjfaj6qGJ2Psj7KfKAdtTrFLEuHi4GkvJ0r706ulyWu76MNR0HSDKcGSGoH7S55YNEJ5CQnm1g9v6rfIGdQunshTtRtTHPwuvgEfmLoKTJuaKf0j87Cj8S(KcQnaQvzXa1cgm1UU55kDiBhPailOt4oBEU8P3yoNAdtTrFLoKTJGdQunshTtRRzC0ovQzcwqdV1NKaVOsprxV6yu(0XPzE6nMZ19QzqWzpCCntiul)(cI4jNWpY7K7GuysCQnm12OcaivtqLPJiw4t8fKunIAdtTHqTxiEIUS1iMkjfaj6qGJ2Psj7KfKAdtTHqTRBEUshY2rkaYc6eUZMNlF6nMZPwWGP21H4FL7WEYwe(CQTnQfvLHxbtPhvi30fjUeEwFsHMXr7uPMjybn8wFsc8Ik9eD9QJjwmOJtZ80BmNR7vZGGZE44AMqOw(9feXtoHFK3j3bPWK4AghTtLAg4efzozsIiYrxV6yInwDCAghTtLAg49OjXjagN9cnZtVXCUUx9Qxnd)aUQz1XPJjwDCAghTtLAg2j5ea4F7xZ80BmNR7vV6y6thNM5P3yox3RMPI0mIVAghTtLAMwoC8gZ1mTCJ61mOQm8kykfQSSvsWDiE1zUeEwFsb12g12p1gMAx38CLcvw2kj4oeV6mx(0BmNRzA5qs6SxZevLzsCcqbj4oeV6mxV6y6bDCAMNEJ5CDVAgeC2dhxZavZbrIQGhk5hyqZsTbqTkB)uByQvrQn6Re3H4vN5shTtRtTGbtTHqTRBEUsHklBLeChIxDMlF6nMZPwLO2WulunVKFGbnl1gawQTFnJJ2PsnJdrEEYwq4ZvV6yWOoonZtVXCUUxndco7HJRzI(kXDiE1zU0r706ulyWuBiu76MNRuOYYwjb3H4vN5YNEJ5CnJJ2PsntJPkobqf2PxDm9RJtZ80BmNR7vZGGZE44AMgvaaPAcQmDea4Z27KQrulyWuB0xjUdXRoZLoANwNAbdMAvKAx38CLoKTJuaKf0jCNnpx(0BmNtTHP2OVspQqeCqLQr6ODADQvjnJJ2PsntZHIdvysC9QJrz1XPzE6nMZ19QzqWzpCCnJIuBJkaGunbvMoIyHpXxqs1iQnm12OcaibUypKDWbTs4z9jfuBByP2(PwLOwWGPwhTtRtEE25cQnaSuBFuByQvrQTrfaqQMGkthrSWN4liPAe1cgm12OcaibUypKDWbTs4z9jfuBByP2(PwL0moANk1mMbh0kiktvoo7ZvV6y6P640mp9gZ56E1mi4ShoUMrrQn6Re3H4vN5shTtRtTHP21npxPqLLTscUdXRoZLp9gZ5uRsulyWuB0xPhvicoOs1iD0oTUMXr7uPMXt0fl0neKBm6vhtpthNM5P3yox3RMbbN9WX1moANwN88SZfuBayP2(OwWGPwfPwOAEj)adAwQnaSuB)uByQfQMdIevbpuYpWGMLAdal1QSyGAvsZ4ODQuZ4qKNNePAexV6yu(0XPzE6nMZ19QzqWzpCCnJIuB0xjUdXRoZLoANwNAdtTRBEUsHklBLeChIxDMlF6nMZPwLOwWGP2OVspQqeCqLQr6ODADnJJ2PsndWaFJPkUE1Xelg0XPzE6nMZ19QzqWzpCCntJkaGunbvMoIyHpXxqs1iQnm16ODADYZZoxqTyP2yPwWGP2gvaajWf7HSdoOvcpRpPGABJAXrCQnm16ODADYZZoxqTyP2y1moANk1mnooPailCqki0RoMyJvhNM5P3yox3RMbbN9WX1m7WEQnaQTpmqTGbtTHqTVhPorrNlHoB0K4eNnYmRk)e8b3BvML8eFYtTGbtTHqTVhPorrNlBnIPssbq4NDexZ4ODQuZOkoz2Zk0RoMy7thNM5P3yox3RMXr7uPMXBxaYHUGau5skasuf8qndco7HJRzuKAVq8eDzRrmvskas0HahTtLYNEJ5CQnm1gc1UU55kvtqLPJaaF2EN8P3yoNAvIAbdMAvKAdHAVq8eDjQs(tX5eZaCGcIUK1vMfKAdtTHqTxiEIUS1iMkjfaj6qGJ2Ps5tVXCo1QKMjD2Rz82fGCOliavUKcGevbpuV6yITh0XPzE6nMZ19QzC0ovQz82fGCOliavUKcGevbpuZGGZE44AguvgEfmLEuHCtxK4s4z9jfuBBuBSyKAdtTksTxiEIUevj)P4CIzaoqbrxY6kZcsTGbtTxiEIUS1iMkjfaj6qGJ2Ps5tVXCo1gMAx38CLQjOY0raGpBVt(0BmNtTkPzsN9AgVDbih6ccqLlPairvWd1RoMyXOoonZtVXCUUxnJJ2PsnJ3UaKdDbbOYLuaKOk4HAgeC2dhxZSd7jBr4ZP22OwuvgEfmLEuHCtxK4s4z9jfuB8uBpGrnt6SxZ4Tla5qxqaQCjfajQcEOE1XeB)640mp9gZ56E1moANk1mUaulpVGa92libvq3OzqWzpCCnd)nQaasO3EbjOc6gc)nQaasX6ifO22O2y1mPZEnJla1YZliqV9csqf0n6vhtSkRoonZtVXCUUxnJJ2PsnJla1YZliqV9csqf0nAgeC2dhxZe9vIR6q(4jPaiE7hwliPJ2P1P2WuB0xPhvicoOs1iD0oTUMjD2RzCbOwEEbb6TxqcQGUrV6yITNQJtZ80BmNR7vZ4ODQuZ4cqT88cc0BVGeubDJMbbN9WX1mOQm8kyk9Oc5MUiXLW78oQnm1Qi1EH4j6suL8NIZjMb4afeDjRRmli1gMA3H9KTi85uBBulQkdVcMsuL8NIZjMb4afeDj8S(KcQnEQTpmqTGbtTHqTxiEIUevj)P4CIzaoqbrxY6kZcsTkPzsN9AgxaQLNxqGE7fKGkOB0RoMy7z640mp9gZ56E1moANk1mUaulpVGa92libvq3OzqWzpCCnZoSNSfHpNABJArvz4vWu6rfYnDrIlHN1NuqTXtT9Hbnt6SxZ4cqT88cc0BVGeubDJE1XeRYNoonZtVXCUUxnJJ2PsntRrmvskac)SJ4AgeC2dhxZOi1IQYWRGP0JkKB6IexcVZ7O2Wul)nQaasGl2dNeNeSutUuSosbQnaSulgP2Wu7fINOlBnIPssbqIoe4ODQu(0BmNtTkrTGbtTnQaas1euz6iaWNT3jvJOwWGP2OVsChIxDMlD0oTUMjD2RzAnIPssbq4NDexV6y6dd640mp9gZ56E1moANk1mqNnAsCIZgzMvLFc(G7TkZsEIp51mi4ShoUMbvLHxbtPhvi30fjUeEwFsb12g12h1cgm1UU55kDiBhPailOt4oBEU8P3yoNAbdMAH(WjV1Zv6CUqoj12g12VMjD2RzGoB0K4eNnYmRk)e8b3BvML8eFYRxDm9fRoonZtVXCUUxnJJ2PsntthELN08tCdRNosZGGZE44AguvgEfmLcvw2kj4oeV6mxcpRpPGAdGAvwmqTGbtTHqTRBEUsHklBLeChIxDMlF6nMZP2Wu7oSNAdGA7ddulyWuBiu77rQtu05sOZgnjoXzJmZQYpbFW9wLzjpXN8AM0zVMPPdVYtA(jUH1thPxDm91NoonZtVXCUUxnJJ2PsnJY8ccOkO5qndco7HJRzI(kXDiE1zU0r706ulyWuBiu76MNRuOYYwjb3H4vN5YNEJ5CQnm1Ud7P2aO2(Wa1cgm1gc1(EK6efDUe6SrtItC2iZSQ8tWhCVvzwYt8jVMjD2RzuMxqavbnhQxDm91d640mp9gZ56E1moANk1m4U5i3youqAURGMbbN9WX1mrFL4oeV6mx6ODADQfmyQneQDDZZvkuzzRKG7q8QZC5tVXCo1gMA3H9uBauBFyGAbdMAdHAFpsDIIoxcD2OjXjoBKzwv(j4dU3Qml5j(KxZKo71m4U5i3youqAURGE1X0hg1XPzE6nMZ19QzC0ovQzWHvIlirWH1neOJFndco7HJRzGQ5P22WsT9a1gMAvKA3H9uBauBFyGAbdMAdHAFpsDIIoxcD2OjXjoBKzwv(j4dU3Qml5j(KNAvsZKo71m4WkXfKi4W6gc0XVE1X0x)640mp9gZ56E1mi4ShoUMbvLHxbtPdz7ifazbDc)oxcVZ7OwWGP2OVsChIxDMlD0oTo1cgm12OcaivtqLPJaaF2ENunsZ4ODQuZev7uPE1X0NYQJtZ80BmNR7vZGGZE44AgETYwdu18Cjrghx9s4z9jfuBByPwCexZ4ODQuZuQBd8Uc6vhtF9uDCAMNEJ5CDVAghTtLAgKBmehTtLeZiwnJzeljD2RzUq8eDHE1X0xpthNM5P3yox3RMXr7uPMb5gdXr7ujXmIvZygXssN9AguvgEfmf6vhtFkF640mp9gZ56E1mi4ShoUMXr706KNNDUGAdal12NMrSWbT6yIvZ4ODQuZGCJH4ODQKygXQzmJyjPZEnJxxV6y6bmOJtZ80BmNR7vZGGZE44AghTtRtEE25cQfl1gRMrSWbT6yIvZ4ODQuZGCJH4ODQKygXQzmJyjPZEnd(ZdhKE1X0dXQJtZ80BmNR7vZ4ODQuZaCXE4K4eXchfUMbbN9WX1m83OcaibUypCsCsWsn5sX6ifO22OwmQzqDiZjRdX)k0XeRE1RMjcEuX24RooDmXQJtZ4ODQuZev7uPM5P3yox3RE1X0NoonJJ2Psnd0hXj87CnZtVXCUUx9QJPh0XPzE6nMZ19QzsN9AgVDbih6ccqLlPairvWd1moANk1mE7cqo0feGkxsbqIQGhQxDmyuhNM5P3yox3RMHFJ3Pz6tZ4ODQuZ4q2osbqwqNWVZ1RE1mOQm8kyk0XPJjwDCAghTtLAghY2rkaYc6e(DUM5P3yox3RE1X0NoonZtVXCUUxndco7HJRz4VrfaqcCXE4K4KGLAYLI1rkqTbGLAXi1gMAvKAD0oTo55zNlO2aWsT9rTGbtTHqTxiEIUS1iMkjfaj6qGJ2Ps5tVXCo1cgm1gc16TF4SxY64QcsbqwqNWVZLp9gZ5ulyWu7fINOlBnIPssbqIoe4ODQu(0BmNtTHPwfP21npxPAcQmDea4Z27Kp9gZ5uByQfvLHxbtPAcQmDea4Z27KWZ6tkO22WsT9a1cgm1gc1UU55kvtqLPJaaF2EN8P3yoNAvIAvsZ4ODQuZ4rfYnDrIRxDm9GoonZtVXCUUxndco7HJRzcHAH(WjV1Zv6CUqEL3rScQfmyQf6dN8wpxPZ5c5KuBauBS9RzC0ovQz4oubYc9uauqwFNk1RogmQJtZ80BmNR7vZGGZE44AgOAoisuf8qj)adAwQTnQnwmQzC0ovQzeQSSvsWDiE1zUE1X0VoonZtVXCUUxndco7HJRzUq8eDzRrmvskas0HahTtLYNEJ5CQnm1g9v6rfIGdQunshTtRtTGbtT83OcaibUypCsCsWsn5sX6ifO22OwmsTHP2qO2leprx2AetLKcGeDiWr7uP8P3yoNAdtTksTHqTE7ho7LSoUQGuaKf0j87C5tVXCo1cgm16TF4SxY64QcsbqwqNWVZLp9gZ5uByQn6R0JkebhuPAKoANwNAvsZ4ODQuZOMGkthba(S9o9QJrz1XPzE6nMZ19QzqWzpCCnJJ2P1jpp7Cb1gawQTpQnm1Qi1Qi1IQYWRGPKFFbr8Kt4h5Ds4z9jfuBByPwCeNAdtTHqTRBEUs(bgZLp9gZ5uRsulyWuRIulQkdVcMs(bgZLWZ6tkO22WsT4io1gMAx38CL8dmMlF6nMZPwLOwL0moANk1mQjOY0raGpBVtV6y6P640mp9gZ56E1moANk1mIs1qG3JouZGGZE44AM1H4FL7WEYwe(CQTnQTNrTHP21H4FL7WEYwe(CQnaQfJAguhYCY6q8VcDmXQxDm9mDCAMNEJ5CDVAgeC2dhxZOi1gc1c9HtERNR05CH8kVJyfulyWul0ho5TEUsNZfYjP2aO2(Wa1Qe1gMAHQ5P22WsTksTXsT9eQTrfaqQMGkthba(S9oPAe1QKMXr7uPMruQgc8E0H6vhJYNoonJJ2PsnJAcQmDKgZGdA1mp9gZ56E1RE1m4ppCq640XeRoonZtVXCUUxndco7HJRzAubaKcvo)jHxfReEhTuByQfQMxUd7jBrWi1ga1IJ4uByQneQTLdhVXCzuvMjXjafKG7q8QZCQfmyQn6Re3H4vN5shTtRRzC0ovQz43xqeung9QJPpDCAMNEJ5CDVAgeC2dhxZavZbrIQGhk5hyqZsTTrTXIrQnm1cvZl3H9KTiyKAdGAXrCQnm1gc12YHJ3yUmQkZK4eGcsWDiE1zUMXr7uPMHFFbrq1y0RoMEqhNM5P3yox3RMbbN9WX1mksTksT83OcaibUypCsCsWsn5s1iQnm1Qi1IQYWRGP0JkKB6IexcpRpPGAdGA7NAdtTksTHqTxiEIUS1iMkjfaj6qGJ2Ps5tVXCo1cgm1gc1UU55kvtqLPJaaF2EN8P3yoNAvIAbdMAVq8eDzRrmvskas0HahTtLYNEJ5CQnm1UU55kvtqLPJaaF2EN8P3yoNAdtTOQm8kykvtqLPJaaF2ENeEwFsb1ga1QSuRsuRsulyWul)nQaasGl2dNeNeSutUuSosbQnaQfJuRsuByQvrQfvLHxbtPdz7ifazbDc)oxcpRpPGAdGA7NAbdMA53xqefYbh0k5JWBmN41YPwL0moANk1mcuPcXprSWrHRxDmyuhNM5P3yox3RMbbN9WX1mksTksT83OcaibUypCsCsWsn5s1iQnm1Qi1IQYWRGP0JkKB6IexcpRpPGAdGA7NAdtTksTHqTxiEIUS1iMkjfaj6qGJ2Ps5tVXCo1cgm1gc1UU55kvtqLPJaaF2EN8P3yoNAvIAbdMAVq8eDzRrmvskas0HahTtLYNEJ5CQnm1UU55kvtqLPJaaF2EN8P3yoNAdtTOQm8kykvtqLPJaaF2ENeEwFsb1ga1QSuRsuRsulyWul)nQaasGl2dNeNeSutUuSosbQnaQfJuRsuByQvrQfvLHxbtPdz7ifazbDc)oxcpRpPGAdGA7NAbdMA53xqefYbh0k5JWBmN41YPwL0moANk1miJhCsCIaKZRGc9QJPFDCAMNEJ5CDVAgeC2dhxZavZbrIQGhk5hyqZsTTrT9HbQnm1gc12YHJ3yUmQkZK4eGcsWDiE1zUMXr7uPMHFFbrq1y0RogLvhNM5P3yox3RMbbN9WX1m83OcaibUypCsCsWsn5sX6ifO22OwmsTHPwfPwuvgEfmLEuHCtxK4s4z9jfuBBuBpqTHPwfP2qO2leprx2AetLKcGeDiWr7uP8P3yoNAbdMAdHAx38CLQjOY0raGpBVt(0BmNtTGbtTxiEIUS1iMkjfaj6qGJ2Ps5tVXCo1gMAx38CLQjOY0raGpBVt(0BmNtTHPwuvgEfmLQjOY0raGpBVtcpRpPGABJA7PuRsuRsulyWul)nQaasGl2dNeNeSutUuSosbQTnQnwQnm1Qi1IQYWRGP0HSDKcGSGoHFNlHN1NuqTbqT9tTGbtT87liIc5GdAL8r4nMt8A5uRsAghTtLAgGl2dNeNiw4OW1RoMEQoonZtVXCUUxndco7HJRzcHAB5WXBmxgvLzsCcqbj4oeV6mxZ4ODQuZWVVGiOAm6vVAgVUooDmXQJtZ80BmNR7vZGGZE44AguvgEfmLEuHCtxK4s4z9jfAghTtLAg(9feXtoHFK3PxDm9PJtZ80BmNR7vZGGZE44AguvgEfmLEuHCtxK4s4z9jfAghTtLAg(bgZ1RoMEqhNM5P3yox3RMbbN9WX1m87liINCc)iVtUdsHjXP2WulunhejQcEOKFGbnl12g1glgP2WuBiu76MNRSrfk2jXjIcEH8P3yoNAdtTHqTTC44nMlJQYmjobOGeChIxDMRzC0ovQzE0Wp7G0RogmQJtZ80BmNR7vZGGZE44Ag(9feXtoHFK3j3bPWK4uByQvrQneQLFFbruihCqReiyPM8ZjRdX)kO2Wu76MNRSrfk2jXjIcEH8P3yoNAvIAdtTHqTTC44nMlJQYmjobOGeChIxDMRzC0ovQzE0Wp7G0RoM(1XPzE6nMZ19QzqWzpCCnd)(cI4jNWpY7K7GuysCQnm1IQYWRGP0JkKB6IexcpRpPqZ4ODQuZiqLke)eXchfUE1XOS640mp9gZ56E1mi4ShoUMHFFbr8Kt4h5DYDqkmjo1gMArvz4vWu6rfYnDrIlHN1NuOzC0ovQzqgp4K4ebiNxbf6vhtpvhNM5P3yox3RMbbN9WX1mHqTTC44nMlJQYmjobOGeChIxDMRzC0ovQzE0Wp7G0RoMEMoonZtVXCUUxnJJ2PsndWf7HtItelCu4AgeC2dhxZWFJkaGe4I9WjXjbl1KlfRJuGABdl12h1gMArvz4vWuYVVGiEYj8J8oj8S(KcQnm1IQYWRGP0JkKB6IexcpRpPGAdGA7NAdtTksTOQm8kykDiBhPailOt435s4z9jfuBauB)ulyWul)(cIOqo4GwjFeEJ5eVwo1QKMb1HmNSoe)RqhtS6vhJYNoonZtVXCUUxndco7HJRzAubaKcvo)jHxfReEhTuByQfQMxUd7jBrWi1ga1IJ4AghTtLAg(9febvJrV6yIfd640mp9gZ56E1mi4ShoUMPrfaqku58NeEvSs4D0sTHP2qO2woC8gZLrvzMeNauqcUdXRoZPwWGP2OVsChIxDMlD0oTUMXr7uPMHFFbrq1y0RoMyJvhNM5P3yox3RMbbN9WX1mq1CqKOk4Hs(bg0SuBBuBSyKAdtTksTOQm8kyk9Oc5MUiXLWZ6tkO2aO2(PwWGPw(BubaKaxShojojyPMCPyDKcuBaulgPwLO2WuBiuBlhoEJ5YOQmtItakib3H4vN5AghTtLAg(9febvJrV6yITpDCAMNEJ5CDVAghTtLAgbQuH4Niw4OW1mi4ShoUMrrQvrQfvLHxbtPdz7ifazbDc)oxcpRpPGAdGA7NAbdMA53xqefYbh0k5JWBmN41YPwLO2WuRIulQkdVcMspQqUPlsCj8S(KcQnaQTFQnm1YFJkaGe4I9WjXjbl1KlfRJuGAdGAXa1cgm1YFJkaGe4I9WjXjbl1KlfRJuGAdGAXi1Qe1gMAvKA3H9KTi85uBBulQkdVcMs(9feXtoHFK3jHN1NuqTXtTXIbQfmyQDh2t2IWNtTbqTOQm8kyk9Oc5MUiXLWZ6tkOwLOwL0mOoK5K1H4Ff6yIvV6yITh0XPzE6nMZ19QzC0ovQzqgp4K4ebiNxbfAgeC2dhxZOi1Qi1IQYWRGP0HSDKcGSGoHFNlHN1NuqTbqT9tTGbtT87liIc5GdAL8r4nMt8A5uRsuByQvrQfvLHxbtPhvi30fjUeEwFsb1ga12p1gMA5VrfaqcCXE4K4KGLAYLI1rkqTbqTyGAbdMA5VrfaqcCXE4K4KGLAYLI1rkqTbqTyKAvIAdtTksT7WEYwe(CQTnQfvLHxbtj)(cI4jNWpY7KWZ6tkO24P2yXa1cgm1Ud7jBr4ZP2aOwuvgEfmLEuHCtxK4s4z9jfuRsuRsAguhYCY6q8VcDmXQxDmXIrDCAMNEJ5CDVAgeC2dhxZavZbrIQGhk5hyqZsTTrT9HbQnm1gc12YHJ3yUmQkZK4eGcsWDiE1zUMXr7uPMHFFbrq1y0RoMy7xhNM5P3yox3RMbbN9WX1mksTksTksTksT83OcaibUypCsCsWsn5sX6ifO22OwmsTHP2qO2gvaaPAcQmDea4Z27KQruRsulyWul)nQaasGl2dNeNeSutUuSosbQTnQThOwLO2WulQkdVcMspQqUPlsCj8S(KcQTnQThOwLOwWGPw(BubaKaxShojojyPMCPyDKcuBBuBSuRsuByQvrQfvLHxbtPdz7ifazbDc)oxcpRpPGAdGA7NAbdMA53xqefYbh0k5JWBmN41YPwL0moANk1maxShojorSWrHRxDmXQS640mp9gZ56E1mi4ShoUMHFFbr8Kt4h5DYDqkmjUMXr7uPMrGkvi(jIfokC9QJj2EQoonZtVXCUUxndco7HJRzcHAB5WXBmxgvLzsCcqbj4oeV6mxZ4ODQuZWVVGiOAm6vV6vZ06qXuPoM(WqFyad93x)AMGomNexOzugZgvW9CQvzPwhTtLuRzeRqsXuZ4QlOcQzygwvJVtLk)qhy1mrWcymxZOCuBpMeuz6O2ES3xquRYq5GdAPyQCulODJe94Hgk(SGuBKOInuXWQA8DQebDGnuXWIcLIPYrTyQMNAJfJbsT9HH(WaftkMkh1Q8dYt8l6XPyQCuBpHA7558ZP2EUj5uRYa4F7xsXu5O2Ec1Q8xzRd3ZP21H4Fjda1IQKp7uPGA3IAHhx14qQfvjF2PsHKIPYrT9eQvzKJg3icvzqLl1wauRYJk4Hu7g8UccjftkMkh1Q8u59i19CQT5af8ulQyB8LABo(Kcj12ZJqpAfuBwzpbKdzbunuRJ2Psb1wPPtsXu5OwhTtLcze8OITXxSagxOaftLJAD0ovkKrWJk2gFJhBOavXPyQCuRJ2PsHmcEuX24B8yd1vXzFU(ovsXu5OwM0JeGQLAH(WP2gvaGZPwX6RGABoqbp1Ik2gFP2MJpPGA9KtTrW3tIQDNeNAhb1YR8skMkh16ODQuiJGhvSn(gp2qfPhjavlrS(kOy6ODQuiJGhvSn(gp2qJQDQKIPJ2PsHmcEuX24B8ydf6J4e(DofthTtLcze8OITX34XgQQ4KzpBGPZESE7cqo0feGkxsbqIQGhsX0r7uPqgbpQyB8nESH6q2osbqwqNWVZdKFJ3HTpkMumvoQv5PY7rQ75u7BDyh1Ud7P2f0PwhTfKAhb16T8X4nMlPy6ODQuGLDsoba(3(Py6ODQuep2qB5WXBmpW0zp2OQmtItakib3H4vN5b2YnQhlQkdVcMsHklBLeChIxDMlHN1Nu0w)Hx38CLcvw2kj4oeV6mx(0BmNtXu5OwLroACJiqQvz8EwrGuRNCQTwqhsTfoIlOy6ODQuep2qDiYZt2ccFUboayHQ5GirvWdL8dmOzdqz7pSIrFL4oeV6mx6ODADWGdzDZZvkuzzRKG7q8QZC5tVXCUsHHQ5L8dmOzdaB)umD0ovkIhBOnMQ4eavyxGda2OVsChIxDMlD0oToyWHSU55kfQSSvsWDiE1zU8P3yoNIPJ2Psr8ydT5qXHkmjEGda2gvaaPAcQmDea4Z27KQrGbh9vI7q8QZCPJ2P1bdwX1npxPdz7ifazbDc3zZZLp9gZ5HJ(k9OcrWbvQgPJ2P1vIIPJ2Psr8yd1m4GwbrzQYXzFUboayvSrfaqQMGkthrSWN4liPAu4gvaajWf7HSdoOvcpRpPOnS9ReyWoANwN88SZfbGTVWk2OcaivtqLPJiw4t8fKuncm4gvaajWf7HSdoOvcpRpPOnS9RefthTtLI4XgQNOlwOBii3ycCaWQy0xjUdXRoZLoANwp86MNRuOYYwjb3H4vN5YNEJ5CLado6R0JkebhuPAKoANwNIPJ2Psr8yd1Hippjs1iEGdawhTtRtEE25IaW2hyWkcvZl5hyqZga2(ddvZbrIQGhk5hyqZgawLfdkrX0r7uPiESHcmW3yQIh4aGvXOVsChIxDMlD0oTE41npxPqLLTscUdXRoZLp9gZ5kbgC0xPhvicoOs1iD0oTofthTtLI4XgAJJtkaYchKcIahaSnQaas1euz6iIf(eFbjvJc7ODADYZZoxGnwWGBubaKaxShYo4Gwj8S(KI2Wr8WoANwN88SZfyJLIjftLJAv(vfBXsTlCsf(kOwvHJFkMoANkfXJnuvXjZEwrGda2DyFa9HbWGd59i1jk6Cj0zJMeN4SrMzv5NGp4ERYSKN4tEWGd59i1jk6CzRrmvskac)SJ4umD0ovkIhBOQItM9SbMo7X6Tla5qxqaQCjfajQcEyGdawfVq8eDzRrmvskas0HahTtLYNEJ58WHSU55kvtqLPJaaF2EN8P3yoxjWGvmKleprxIQK)uCoXmahOGOlzDLzbdhYfINOlBnIPssbqIoe4ODQu(0BmNRefthTtLI4XgQQ4KzpBGPZESE7cqo0feGkxsbqIQGhg4aGfvLHxbtPhvi30fjUeEwFsrBXIXWkEH4j6suL8NIZjMb4afeDjRRmliyWxiEIUS1iMkjfaj6qGJ2Ps5tVXCE41npxPAcQmDea4Z27Kp9gZ5krX0r7uPiESHQkoz2Zgy6ShR3UaKdDbbOYLuaKOk4Hboay3H9KTi85THQYWRGP0JkKB6IexcpRpPi(EaJumD0ovkIhBOQItM9SbMo7X6cqT88cc0BVGeubDtGdaw(BubaKqV9csqf0ne(BubaKI1rk0wSumD0ovkIhBOQItM9SbMo7X6cqT88cc0BVGeubDtGda2OVsCvhYhpjfaXB)WAbjD0oTE4OVspQqeCqLQr6ODADkMoANkfXJnuvXjZE2atN9yDbOwEEbb6TxqcQGUjWbalQkdVcMspQqUPlsCj8oVlSIxiEIUevj)P4CIzaoqbrxY6kZcgEh2t2IWN3gQkdVcMsuL8NIZjMb4afeDj8S(KI47ddGbhYfINOlrvYFkoNygGduq0LSUYSGkrX0r7uPiESHQkoz2Zgy6ShRla1YZliqV9csqf0nboay3H9KTi85THQYWRGP0JkKB6IexcpRpPi((WafthTtLI4XgQQ4KzpBGPZESTgXujPai8ZoIh4aGvruvgEfmLEuHCtxK4s4DExy(BubaKaxShojojyPMCPyDKcbGfJHVq8eDzRrmvskas0HahTtLYNEJ5CLadUrfaqQMGkthba(S9oPAeyWrFL4oeV6mx6ODADkMoANkfXJnuvXjZE2atN9yHoB0K4eNnYmRk)e8b3BvML8eFYh4aGfvLHxbtPhvi30fjUeEwFsrB9bg86MNR0HSDKcGSGoH7S55YNEJ5CWGH(WjV1Zv6CUqozB9tX0r7uPiESHQkoz2Zgy6ShBthELN08tCdRNokWbalQkdVcMsHklBLeChIxDMlHN1NueGYIbWGdzDZZvkuzzRKG7q8QZC5tVXCE4DyFa9HbWGd59i1jk6Cj0zJMeN4SrMzv5NGp4ERYSKN4tEkMoANkfXJnuvXjZE2atN9yvMxqavbnhg4aGn6Re3H4vN5shTtRdgCiRBEUsHklBLeChIxDMlF6nMZdVd7dOpmagCiVhPorrNlHoB0K4eNnYmRk)e8b3BvML8eFYtX0r7uPiESHQkoz2Zgy6ShlUBoYnMdfKM7ke4aGn6Re3H4vN5shTtRdgCiRBEUsHklBLeChIxDMlF6nMZdVd7dOpmagCiVhPorrNlHoB0K4eNnYmRk)e8b3BvML8eFYtX0r7uPiESHQkoz2Zgy6ShloSsCbjcoSUHaD8h4aGfQMVnS9qyf3H9b0hgadoK3JuNOOZLqNnAsCIZgzMvLFc(G7TkZsEIp5vIIPJ2Psr8ydnQ2PYahaSOQm8kykDiBhPailOt435s4DEhyWrFL4oeV6mx6ODADWGBubaKQjOY0raGpBVtQgrXu5O2EoFY1NCsCQvz4bQAEUuRYdJJREQDeuRtTrWPGZ2rX0r7uPiESHwQBd8Ucboay51kBnqvZZLezCC1lHN1Nu0gwCeNIPJ2Psr8ydf5gdXr7ujXmInW0zp2leprxqX0r7uPiESHICJH4ODQKygXgy6ShlQkdVcMckMoANkfXJnuKBmehTtLeZi2aflCql2ydmD2J1Rh4aG1r706KNNDUiaS9rX0r7uPiESHICJH4ODQKygXgOyHdAXgBGPZES4ppCqboayD0oTo55zNlWglfthTtLI4XgkWf7HtItelCu4bI6qMtwhI)vGn2ahaS83OcaibUypCsCsWsn5sX6ifAdJumPyQCuBpFP8KAH167ujfthTtLcPxhl)(cI4jNWpY7cCaWIQYWRGP0JkKB6IexcpRpPGIPJ2PsH0Rhp2q5hympWbalQkdVcMspQqUPlsCj8S(KckMoANkfsVE8yd9rd)SdkWbal)(cI4jNWpY7K7Guys8Wq1CqKOk4Hs(bg0STflgdhY6MNRSrfk2jXjIcEH8P3yopCiTC44nMlJQYmjobOGeChIxDMtX0r7uPq61JhBOpA4NDqboay53xqep5e(rENChKctIhwXq43xqefYbh0kbcwQj)CY6q8VIWRBEUYgvOyNeNik4fYNEJ5CLchslhoEJ5YOQmtItakib3H4vN5umD0ovkKE94XgQavQq8telCu4boay53xqep5e(rENChKctIhgvLHxbtPhvi30fjUeEwFsbfthTtLcPxpESHImEWjXjcqoVckcCaWYVVGiEYj8J8o5oifMepmQkdVcMspQqUPlsCj8S(KckMoANkfsVE8yd9rd)SdkWbaBiTC44nMlJQYmjobOGeChIxDMtX0r7uPq61JhBOaxShojorSWrHhiQdzozDi(xb2ydCaWYFJkaGe4I9WjXjbl1KlfRJuOnS9fgvLHxbtj)(cI4jNWpY7KWZ6tkcJQYWRGP0JkKB6IexcpRpPiG(dRiQkdVcMshY2rkaYc6e(DUeEwFsra9dgm)(cIOqo4GwjFeEJ5eVwUsumD0ovkKE94Xgk)(cIGQXe4aGTrfaqku58NeEvSs4D0ggQMxUd7jBrWya4iofthTtLcPxpESHYVVGiOAmboayBubaKcvo)jHxfReEhTHdPLdhVXCzuvMjXjafKG7q8QZCWGJ(kXDiE1zU0r706umD0ovkKE94Xgk)(cIGQXe4aGfQMdIevbpuYpWGMTTyXyyfrvz4vWu6rfYnDrIlHN1Nueq)GbZFJkaGe4I9WjXjbl1KlfRJuiamQu4qA5WXBmxgvLzsCcqbj4oeV6mNIPJ2PsH0Rhp2qfOsfIFIyHJcpquhYCY6q8VcSXg4aGvrfrvz4vWu6q2osbqwqNWVZLWZ6tkcOFWG53xqefYbh0k5JWBmN41YvkSIOQm8kyk9Oc5MUiXLWZ6tkcO)W83OcaibUypCsCsWsn5sX6ifcadGbZFJkaGe4I9WjXjbl1KlfRJuiamQuyf3H9KTi85THQYWRGPKFFbr8Kt4h5Ds4z9jfXhlgadEh2t2IWNhaQkdVcMspQqUPlsCj8S(KcLuIIPJ2PsH0Rhp2qrgp4K4ebiNxbfbI6qMtwhI)vGn2ahaSkQiQkdVcMshY2rkaYc6e(DUeEwFsra9dgm)(cIOqo4GwjFeEJ5eVwUsHvevLHxbtPhvi30fjUeEwFsra9hM)gvaajWf7HtItcwQjxkwhPqayamy(BubaKaxShojojyPMCPyDKcbGrLcR4oSNSfHpVnuvgEfmL87liINCc)iVtcpRpPi(yXayW7WEYwe(8aqvz4vWu6rfYnDrIlHN1NuOKsumD0ovkKE94Xgk)(cIGQXe4aGfQMdIevbpuYpWGMTT(Wq4qA5WXBmxgvLzsCcqbj4oeV6mNIPJ2PsH0Rhp2qbUypCsCIyHJcpWbaRIkQOI83OcaibUypCsCsWsn5sX6ifAdJHdPrfaqQMGkthba(S9oPAKsGbZFJkaGe4I9WjXjbl1KlfRJuOTEqPWOQm8kyk9Oc5MUiXLWZ6tkARhucmy(BubaKaxShojojyPMCPyDKcTfRsHvevLHxbtPdz7ifazbDc)oxcpRpPiG(bdMFFbruihCqRKpcVXCIxlxjkMoANkfsVE8ydvGkvi(jIfok8ahaS87liINCc)iVtUdsHjXPy6ODQui96XJnu(9febvJjWbaBiTC44nMlJQYmjobOGeChIxDMtXKIPJ2PsHevLHxbtbwhY2rkaYc6e(DofthTtLcjQkdVcMI4XgQhvi30fjEGdaw(BubaKaxShojojyPMCPyDKcbGfJHv0r706KNNDUiaS9bgCixiEIUS1iMkjfaj6qGJ2Ps5tVXCoyWH4TF4SxY64QcsbqwqNWVZLp9gZ5GbFH4j6YwJyQKuaKOdboANkLp9gZ5HvCDZZvQMGkthba(S9o5tVXCEyuvgEfmLQjOY0raGpBVtcpRpPOnS9ayWHSU55kvtqLPJaaF2EN8P3yoxjLOy6ODQuirvz4vWuep2q5oubYc9uauqwFNkdCaWgc0ho5TEUsNZfYR8oIvagm0ho5TEUsNZfYjdi2(Py6ODQuirvz4vWuep2qfQSSvsWDiE1zEGdawOAoisuf8qj)adA22IfJumD0ovkKOQm8kykIhBOQjOY0raGpBVlWba7fINOlBnIPssbqIoe4ODQu(0BmNho6R0JkebhuPAKoANwhmy(BubaKaxShojojyPMCPyDKcTHXWHCH4j6YwJyQKuaKOdboANkLp9gZ5HvmeV9dN9swhxvqkaYc6e(DU8P3yohmyV9dN9swhxvqkaYc6e(DU8P3yopC0xPhvicoOs1iD0oTUsumD0ovkKOQm8kykIhBOQjOY0raGpBVlWbaRJ2P1jpp7Cray7lSIkIQYWRGPKFFbr8Kt4h5Ds4z9jfTHfhXdhY6MNRKFGXC5tVXCUsGbRiQkdVcMs(bgZLWZ6tkAdloIhEDZZvYpWyU8P3yoxjLOy6ODQuirvz4vWuep2qfLQHaVhDyGOoK5K1H4FfyJnWba76q8VYDypzlcFEB9SWRdX)k3H9KTi85bGrkMoANkfsuvgEfmfXJnurPAiW7rhg4aGvXqG(WjV1Zv6CUqEL3rScWGH(WjV1Zv6CUqoza9HbLcdvZ3gwfJTN0OcaivtqLPJaaF2ENunsjkMoANkfsuvgEfmfXJnu1euz6inMbh0sXKIPJ2PsH8cXt0fyzpBb7ifaXOIgoHdVZkcCaWcvZl3H9KTiXgaoIhgQMdIevbpSnmIbkMoANkfYleprxep2qBmvXjfazbDYZZ2f4aGLFFbr8Kt4h5DYDqkmjoyWrFLEuHi4GkvJ0r706HD0oTo55zNlWglfthTtLc5fINOlIhBO4QoKpEskaI3(H1ckWbaRIOQm8kyk9Oc5MUiXLWZ6tkAtzdJQYWRGP0HSDKcGSGoHFNlHN1NueaQkdVcMsuL8NIZjMb4afeDj8S(KcLadgvLHxbtPdz7ifazbDc)oxcpRpPOT(adgvqOA0ovkKtEaaVXCYcvxqYNEJ5CkMoANkfYleprxep2qxqNOMnLAYjafe9ahaSnQaas4rkyUqqaki6s1iWGBubaKWJuWCHGauq0jOsn3dLI1rk0wSXsX0r7uPqEH4j6I4XgkqHufNt82pC2tAUZg4aGne(9feXtoHFK3j3bPWK4umD0ovkKxiEIUiESHIQe9CH(EobW4SpWbalVwjQs0Zf675eaJZEsJkmLWZ6tkWIbkMoANkfYleprxep2qJuHdq3K4KgJl2ahaSHWVVGiEYj8J8o5oifMeNIPJ2PsH8cXt0fXJn0Gf0WB9jjWlQ0t0dCaWUU55kDiBhPailOt4oBEU8P3yop8fINOlBnIPssbqIoe4ODQuYozbd3OcaivtqLPJiw4t8fKuncm4leprx2AetLKcGeDiWr7uPKDYcgo6R0JkebhuPAKoANwhm41npxPdz7ifazbDc3zZZLp9gZ5HJ(k9OcrWbvQgPJ2P1dJQYWRGP0HSDKcGSGoHFNlHN1NueGYIbWGx38CLoKTJuaKf0jCNnpx(0BmNho6R0HSDeCqLQr6ODADkMoANkfYleprxep2qdwqdV1NKaVOsprpWbaBi87liINCc)iVtUdsHjXd3OcaivtqLPJiw4t8fKunkCixiEIUS1iMkjfaj6qGJ2Psj7KfmCiRBEUshY2rkaYc6eUZMNlF6nMZbdEDi(x5oSNSfHpVnuvgEfmLEuHCtxK4s4z9jfumD0ovkKxiEIUiESHcNOiZjtsero6boaydHFFbr8Kt4h5DYDqkmjofthTtLc5fINOlIhBOW7rtItamo7fumPy6ODQuiXFE4GWYVVGiOAmboayBubaKcvo)jHxfReEhTHHQ5L7WEYwemgaoIhoKwoC8gZLrvzMeNauqcUdXRoZbdo6Re3H4vN5shTtRtX0r7uPqI)8Wbfp2q53xqeunMahaSq1CqKOk4Hs(bg0STflgddvZl3H9KTiymaCepCiTC44nMlJQYmjobOGeChIxDMtX0r7uPqI)8Wbfp2qfOsfIFIyHJcpWbaRIkYFJkaGe4I9WjXjbl1KlvJcRiQkdVcMspQqUPlsCj8S(KIa6pSIHCH4j6YwJyQKuaKOdboANkLp9gZ5GbhY6MNRunbvMoca8z7DYNEJ5CLad(cXt0LTgXujPairhcC0ovkF6nMZdVU55kvtqLPJaaF2EN8P3yopmQkdVcMs1euz6iaWNT3jHN1NueGYQKsGbZFJkaGe4I9WjXjbl1KlfRJuiamQuyfrvz4vWu6q2osbqwqNWVZLWZ6tkcOFWG53xqefYbh0k5JWBmN41YvIIPJ2PsHe)5HdkESHImEWjXjcqoVckcCaWQOI83OcaibUypCsCsWsn5s1OWkIQYWRGP0JkKB6IexcpRpPiG(dRyixiEIUS1iMkjfaj6qGJ2Ps5tVXCoyWHSU55kvtqLPJaaF2EN8P3yoxjWGVq8eDzRrmvskas0HahTtLYNEJ58WRBEUs1euz6iaWNT3jF6nMZdJQYWRGPunbvMoca8z7Ds4z9jfbOSkPeyW83OcaibUypCsCsWsn5sX6ifcaJkfwruvgEfmLoKTJuaKf0j87Cj8S(KIa6hmy(9ferHCWbTs(i8gZjETCLOy6ODQuiXFE4GIhBO87licQgtGdawOAoisuf8qj)adA226ddHdPLdhVXCzuvMjXjafKG7q8QZCkMoANkfs8NhoO4XgkWf7HtItelCu4boay5VrfaqcCXE4K4KGLAYLI1rk0ggdRiQkdVcMspQqUPlsCj8S(KI26HWkgYfINOlBnIPssbqIoe4ODQu(0BmNdgCiRBEUs1euz6iaWNT3jF6nMZbd(cXt0LTgXujPairhcC0ovkF6nMZdVU55kvtqLPJaaF2EN8P3yopmQkdVcMs1euz6iaWNT3jHN1Nu0wpvjLadM)gvaajWf7HtItcwQjxkwhPqBXgwruvgEfmLoKTJuaKf0j87Cj8S(KIa6hmy(9ferHCWbTs(i8gZjETCLOy6ODQuiXFE4GIhBO87licQgtGda2qA5WXBmxgvLzsCcqbj4oeV6mxV6vRb]] )

end
